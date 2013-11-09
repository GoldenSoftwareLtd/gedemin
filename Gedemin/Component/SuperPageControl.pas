unit SuperPageControl;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ComCtrls, ComStrs, ImgList,
  Graphics, Dialogs,
  {$IFDEF VER130}
  DsgnIntf,
  {$ELSE}
  DesignEditors, DesignIntf,
  {$ENDIF}
  Forms;

type
  TSuperPageControl = class;

  TDrawTabEvent = procedure(Control: TSuperPageControl; TabIndex: Integer;
    const Rect: TRect; Active: Boolean) of object;

  TCursorButton = class(TCustomControl)
  private
    FBitmapName: string;
    FBitMap: TBitmap;
    FMouseOn: Boolean;
    FMouseDown: Boolean;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMDesignHitTest(var Message: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure SetBitmapName(const Value: string);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property BitmapName: string read FBitmapName write SetBitmapName;
  end;

  TSuperTabSheet = class(TCustomControl)
  private
    FPageControl: TSuperPageControl;
    FTabVisible: Boolean;
    FHighlighted: Boolean;
    FImageIndex: TImageIndex;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FTabShowing: Boolean;
    function GetPageIndex: Integer;
    procedure SetHighlighted(const Value: Boolean);
    procedure SetImageIndex(const Value: TImageIndex);
    procedure SetPageIndex(const Value: Integer);
    procedure SetTabVisible(const Value: Boolean);
    procedure SetTabShowing(Value: Boolean);
    procedure UpdateTabShowing;
    procedure TextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure ShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure SetPageControl(const Value: TSuperPageControl);
  protected
    procedure DoHide; dynamic;
    procedure DoShow; dynamic;
    procedure ReadState(Reader: TReader); override;
    function GetClientRect: TRect; override;
    procedure SetName(const Value: TComponentName); override;
    procedure CreateWnd; override;
    function IsChild(WinControl: TWinControl; AHandle: HWND): Boolean;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property PageControl: TSuperPageControl read FPageControl write SetPageControl;
  published
    property BorderWidth;
    property Caption;
    property DragMode;
    property Enabled;
    property Font;
    property Height stored False;
    property Highlighted: Boolean read FHighlighted write SetHighlighted default False;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default 0;
    property Left stored False;
    property Constraints;
    property PageIndex: Integer read GetPageIndex write SetPageIndex stored False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabVisible: Boolean read FTabVisible write SetTabVisible default True;
    property Top stored False;
    property Visible stored False;
    property Width stored False;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property OnStartDrag;
  end;

  TSuperPageControl = class(TCustomControl)
  private
    FHotTrack: Boolean;
    FImageChangeLink: TChangeLink;
    FImages: TCustomImageList;
    FOwnerDraw: Boolean;
    FRaggedRight: Boolean;
    FStyle: TTabStyle;
    FTabPosition: TTabPosition;
    FTabSize: TSmallPoint;
    FOnChange: TNotifyEvent;
    FOnChanging: TTabChangingEvent;
    FOnGetImageIndex: TTabGetImageEvent;
    FOnDrawTab: TDrawTabEvent;
    FOnPaint: TNotifyEvent;
    FPages: TList;
    FActivePage: TSuperTabSheet;
    FNewDockSheet: TSuperTabSheet;
    FUndockingPage: TSuperTabSheet;
    FTabIndex: Integer;
    FLeftButton, FRightButton: TCursorButton;
    //Индекс первого видимой закладки
    FFirstVisibleTabIndex: Integer;
    FTabsVisible: Boolean;
    FBorderStyle: TBorderStyle;
    FBorder: Integer;
    procedure ChangeActivePage(Page: TSuperTabSheet);
    procedure ImageListChange(Sender: TObject);
    function GetActivePageIndex: Integer;
    function GetDockClientFromMousePos(MousePos: TPoint): TControl;
    procedure SetOnPaint(const Value: TNotifyEvent);
    function GetPages(Index: Integer): TSuperTabSheet;
    function GetPageCount: Integer;
    procedure InsertPage(Page: TSuperTabSheet);
    procedure RemovePage(Page: TSuperTabSheet);
    procedure SetActivePage(Page: TSuperTabSheet);
    procedure SetActivePageIndex(const Value: Integer);
    procedure UpdateTab(Page: TSuperTabSheet);
    procedure UpdateTabHighlights;

    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMDockClient(var Message: TCMDockClient); message CM_DOCKCLIENT;
    procedure CMDockNotification(var Message: TCMDockNotification); message CM_DOCKNOTIFICATION;
    procedure CMUnDockClient(var Message: TCMUnDockClient); message CM_UNDOCKCLIENT;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;

    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure CMDesignHitTest(var Message: TCMDesignHitTest); message CM_DESIGNHITTEST;

    function GetDisplayRect: TRect;
    procedure SetHotTrack(const Value: Boolean);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetOwnerDraw(const Value: Boolean);
    procedure SetRaggedRight(const Value: Boolean);
    procedure SetStyle(const Value: TTabStyle);
    procedure SetTabHeight(const Value: Smallint);
    procedure SetTabPosition(const Value: TTabPosition);
    procedure SetTabWidth(const Value: Smallint);
    procedure OnLeftButtonClick(Sender: TObject);
    procedure OnRightButtonClick(Sender: TObject);
    function NextVisibleTabIndex: Integer;
    function PrevVisibleTabIndex: Integer;
    procedure SetTabsVisible(const Value: Boolean);
    procedure SetBorderStyle(const Value: TBorderStyle);
  protected
    { Protected declarations }
    function CanShowTab(TabIndex: Integer): Boolean; virtual;
    procedure Change; dynamic;
    procedure DoAddDockClient(Client: TControl; const ARect: TRect); override;
    procedure DockOver(Source: TDragDockObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
    procedure DoRemoveDockClient(Client: TControl); override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function GetImageIndex(TabIndex: Integer): Integer; virtual;
    function GetPageFromDockClient(Client: TControl): TSuperTabSheet;
    procedure GetSiteInfo(Client: TControl; var InfluenceRect: TRect;
      MousePos: TPoint; var CanDock: Boolean); override;
    procedure Loaded; override;
    procedure SetChildOrder(Child: TComponent; Order: Integer); override;
    procedure UpdateActivePage; virtual;
    procedure DoPaint; virtual;
    procedure DoDrawTab(TabIndex: Integer;
      const Rect: TRect; Active: Boolean); virtual;
    function CanChange: Boolean; dynamic;
    procedure ShowControl(AControl: TControl); override;

    property DisplayRect: TRect read GetDisplayRect;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure PaintTabs; virtual;
    function GetClientRect: TRect; override;
    function GetTabsRect: TRect; virtual;
    function GetTabRect(Index: Integer): TRect;
    function GetLastVisibleTabIndex: Integer;
    function CalcTabWidth(Index: Integer): Integer;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Resize; override;
    procedure OnFontChange(Sender: TObject);
    //Возвращает координаты кнопок скролинга
    function GetLeftRect: TRect;
    function GetRightRect: TRect;
    procedure CheckButtonsVisible;
    procedure CreateWnd; override;
    procedure MakeTabVisible(Index: Integer);
    function IsChild(AHandle: HWND): Boolean;
    procedure ConstrainedResize(var MinWidth, MinHeight, MaxWidth,
      MaxHeight: Integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function FindNextPage(CurPage: TSuperTabSheet;
      GoForward, CheckTabVisible: Boolean): TSuperTabSheet;
    procedure SelectNextPage(GoForward: Boolean; CheckTabVisible: Boolean = True);

    function AddPage(TabSheet: TSuperTabSheet): Integer;
    function GetTabIndexFromXY(X, Y: Integer): Integer;
    procedure InvalidateTabs;

    property ActivePageIndex: Integer read GetActivePageIndex
      write SetActivePageIndex;
    property PageCount: Integer read GetPageCount;
    property Pages[Index: Integer]: TSuperTabSheet read GetPages;
    property Canvas;

  published
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle;
    property TabsVisible: Boolean read FTabsVisible write SetTabsVisible;
    property OnPaint: TNotifyEvent read FOnPaint write SetOnPaint;
    property ActivePage: TSuperTabSheet read FActivePage write SetActivePage;
    property OnDrawTab: TDrawTabEvent read FOnDrawTab write FOnDrawTab;
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HotTrack: Boolean read FHotTrack write SetHotTrack default False;
    property Images: TCustomImageList read FImages write SetImages;
    property OwnerDraw: Boolean read FOwnerDraw write SetOwnerDraw default False;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RaggedRight: Boolean read FRaggedRight write SetRaggedRight default False;
    property ShowHint;
    property Style: TTabStyle read FStyle write SetStyle default tsTabs;
    property TabHeight: Smallint read FTabSize.Y write SetTabHeight default 0;
    property TabOrder;
    property TabPosition: TTabPosition read FTabPosition write SetTabPosition
      default tpTop;
    property TabStop default True;
    property TabWidth: Smallint read FTabSize.X write SetTabWidth default 0;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TTabChangingEvent read FOnChanging write FOnChanging;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex: TTabGetImageEvent read FOnGetImageIndex write FOnGetImageIndex;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

  TSuperPageEditor = class(TComponentEditor)
  protected
    procedure AddPage; virtual;
    procedure NextPage; virtual;
    procedure PrevPage; virtual;
  public
    procedure Edit; override;
    function GetVerbCount: Integer; override;
    function GetVerb(Index: Integer): string; override;
    procedure ExecuteVerb(Index: Integer); override;
  end;

var
  PCLightBrushColor: TColor;

procedure Register;

{const
  clSilver = TColor($C0C0C0);}

implementation

{$R SuperPageControl}
const
  cExtraSpace = 5;
  cHalfExtraSpace = 5 div 2;
  cDobleExtraSpace = 2 * cExtraSpace;
  cDivExtraSpace = cExtraSpace div 2;
  cMinTabWidth = 20;
  ColorDelta = 17;

procedure Register;
begin
  RegisterComponents('Samples', [TSuperPageControl]);
  RegisterClass(TSuperTabSheet);
  RegisterComponentEditor(TSuperPageControl, TSuperPageEditor);
end;

procedure CalculateLightBrushColor;
var
  R, G, B: Integer;
  Color: Integer;
begin
  Color := ColorToRGB(clBtnFace);
  R := GetRValue(Color) + ColorDelta;
  if R > 255 then R := 255;
  G := GetGValue(Color) + ColorDelta;
  if G > 255 then G := 255;
  B := GetBValue(Color) + ColorDelta;
  if B > 255 then B := 255;
  PCLightBrushColor := RGB(R, G, B);
end;

{ TSuperPageControl }
{ TODO -oAlexander -cTask : Неправильное выделение жирным шрифтом
выбранной страницы }
function TSuperPageControl.AddPage(TabSheet: TSuperTabSheet): Integer;
begin
  Result := FPages.Add(TabSheet);
end;

function TSuperPageControl.CalcTabWidth(Index: Integer): Integer;
begin
  if Focused and (Index = ActivePageIndex) then
    Canvas.Font.Style := [fsBold]
  else
    Canvas.Font.Style := [];

  if TabWidth = 0 then
    Result := Canvas.TextWidth(TSuperTabSheet(FPages[Index]).Caption) +
      2 * cExtraSpace  + cDivExtraSpace
  else
    Result := TabWidth;

  if Result < cMinTabWidth then
    Result := cMinTabWidth;
end;

function TSuperPageControl.CanChange: Boolean;
begin
  Result := True;
  if Assigned(FOnChanging) then FOnChanging(Self, Result);
end;

function TSuperPageControl.CanShowTab(TabIndex: Integer): Boolean;
begin
  Result := TSuperTabSheet(FPages[TabIndex]).Enabled;
end;

procedure TSuperPageControl.Change;
var
  Form: TCustomForm;
begin
  if FTabIndex >= 0 then UpdateActivePage;
  if csDesigning in ComponentState then
  begin
    Form := GetParentForm(Self);
    if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
  end;
end;

procedure TSuperPageControl.ChangeActivePage(Page: TSuperTabSheet);
var
  ParentForm: TCustomForm;
begin
  if FActivePage <> Page then
  begin
    if not CanChange then Exit;
    ParentForm := GetParentForm(Self);
    if (ParentForm <> nil) and (FActivePage <> nil) and
      FActivePage.ContainsControl(ParentForm.ActiveControl) then
    begin
      ParentForm.ActiveControl := FActivePage;
      if ParentForm.ActiveControl <> FActivePage then
      begin
        FTabIndex := FActivePage.GetPageIndex;
        Exit;
      end;
    end;
    if Page <> nil then
    begin
      Page.BringToFront;
      Page.Visible := True;
      if (ParentForm <> nil) and (FActivePage <> nil) and
        (ParentForm.ActiveControl = FActivePage) then
        if Page.CanFocus then
          ParentForm.ActiveControl := Page else
          ParentForm.ActiveControl := Self;
    end;
    if FActivePage <> nil then FActivePage.Visible := False;
    FActivePage := Page;
    if (ParentForm <> nil) and (FActivePage <> nil) and
      (ParentForm.ActiveControl = FActivePage) then
      FActivePage.SelectFirst;
    if Assigned(FOnChange) then FOnChange(Self);
    MakeTabVisible(GetActivePageIndex);
    Invalidate;
    InvalidateTabs;
  end;
end;

procedure TSuperPageControl.CheckButtonsVisible;
var
  I: Integer;
  R: TRect;
begin
  I := GetLastVisibleTabIndex;
  if I > - 1 then
  begin
    R := GetTabRect(I);
    if (R.Right > GetTabsRect.Right) or (FFirstVisibleTabIndex > 0) then
    begin
      R := GetLeftRect;
      FLeftButton.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
      R := GetRightRect;
      FRightButton.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
      FLeftButton.Visible := True;
      FRightButton.Visible := True;
    end else
    begin
      FLeftButton.Visible := False;
      FRightButton.Visible := False;
    end;
  end else
  begin
    FLeftButton.Visible := False;
    FRightButton.Visible := False;
  end;
end;

procedure TSuperPageControl.CMDesignHitTest(var Message: TCMDesignHitTest);
var
  X, Y: Integer;
  Index: Integer;
begin
  if Message.Keys = MK_LBUTTON then
  begin
    X := Message.XPos;
    Y := Message.YPos;
    Index := GetTabIndexFromXY(X, Y);
    if Index > - 1 then
    begin
      FTabIndex := Index;
      Change;
    end;
  end;  
end;

procedure TSuperPageControl.CMDialogChar(var Message: TCMDialogChar);
var
  I: Integer;
begin
  for I := 0 to FPages.Count - 1 do
    if IsAccel(Message.CharCode, TSuperTabSheet(FPages[I]).Caption) and
      CanShowTab(I) and CanFocus then
    begin
      Message.Result := 1;
      if CanChange then
      begin
        FTabIndex := I;
        Change;
      end;
      Exit;
    end;
  inherited;
end;

procedure TSuperPageControl.CMDialogKey(var Message: TCMDialogKey);
begin
  if (Focused or IsChild(Windows.GetFocus)) and
    (Message.CharCode = VK_TAB) and (GetKeyState(VK_CONTROL) < 0) then
  begin
    SelectNextPage(GetKeyState(VK_SHIFT) >= 0);
    Message.Result := 1;
  end else
    inherited;
end;

procedure TSuperPageControl.CMDockClient(var Message: TCMDockClient);
var
  IsVisible: Boolean;
  DockCtl: TControl;
begin
  Message.Result := 0;
  FNewDockSheet := TSuperTabSheet.Create(Self);
  try
    FNewDockSheet.BorderWidth := 3;
    try
      DockCtl := Message.DockSource.Control;
      if DockCtl is TCustomForm then
        FNewDockSheet.Caption := TCustomForm(DockCtl).Caption;
      FNewDockSheet.PageControl := Self;
      DockCtl.Dock(Self, Message.DockSource.DockRect);
    except
      FNewDockSheet.Free;
      raise;
    end;
    IsVisible := DockCtl.Visible;
    FNewDockSheet.TabVisible := IsVisible;
    if IsVisible then ActivePage := FNewDockSheet;
    DockCtl.Align := alClient;
  finally
    FNewDockSheet := nil;
  end;
end;

procedure TSuperPageControl.CMDockNotification(
  var Message: TCMDockNotification);
var
  I: Integer;
  S: string;
  Page: TSuperTabSheet;
begin
  Page := GetPageFromDockClient(Message.Client);
  if Page <> nil then
    case Message.NotifyRec.ClientMsg of
      WM_SETTEXT:
        begin
          S := PChar(Message.NotifyRec.MsgLParam);
          { Search for first CR/LF and end string there }
          for I := 1 to Length(S) do
            if S[I] in [#13, #10] then
            begin
              SetLength(S, I - 1);
              Break;
            end;
          Page.Caption := S;
        end;
      CM_VISIBLECHANGED:
      begin
        if (not Boolean(Message.NotifyRec.MsgWParam)) and (Page = ActivePage) then
        begin
          Page.TabVisible := Boolean(Message.NotifyRec.MsgWParam);
          SelectNextPage(True);
        end else
          Page.TabVisible := Boolean(Message.NotifyRec.MsgWParam);
      end;
    end;
  inherited;
end;

procedure TSuperPageControl.CMUnDockClient(var Message: TCMUnDockClient);
var
  Page: TSuperTabSheet;
begin
  Message.Result := 0;
  Page := GetPageFromDockClient(Message.Client);
  if Page <> nil then
  begin
    FUndockingPage := Page;
    Message.Client.Align := alNone;
  end;
end;

procedure TSuperPageControl.CNKeyDown(var Message: TWMKeyDown);
begin
  with Message do
  begin
    if (CharCode in [VK_LEFT, VK_RIGHT]) then
    begin
      SelectNextPage(CharCode = VK_RIGHT);
      Result := 1;
    end else
      inherited;
  end;
end;

procedure TSuperPageControl.ConstrainedResize(var MinWidth, MinHeight,
  MaxWidth, MaxHeight: Integer);
var
  I: Integer;
begin
  for I := 0 to PageCount - 1 do
  begin
    Pages[I].ConstrainedResize(MinWidth, MinHeight, MaxWidth, MaxHeight);
  end;
  if MinWidth > 0 then
    Inc(MinWidth, 2 * FBorder);
  if MinHeight > 0 then
    Inc(MinHeight, 2 * FBorder);
      
  inherited;
end;

constructor TSuperPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 200;
  Height := 100;
  TabStop := True;
  FTabIndex := -1;
  ControlStyle := [csAcceptsControls, csDoubleClicks, csOpaque];
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FPages := TList.Create;
  Font.OnChange := OnFontChange;
  OnFontChange(nil);
  FLeftButton := TCursorButton.Create(Self);
  FLeftButton.Parent := Self;
  FLeftButton.Visible := False;
  FLeftButton.BitmapName := 'LEFT';
  FLeftButton.OnClick := OnLeftButtonClick;
  FLeftButton.Anchors := [akRight, akTop];
  FRightButton := TCursorButton.Create(Self);
  FRightButton.Parent := Self;
  FRightButton.Visible := False;
  FRightButton.BitmapName := 'RIGHT';
  FRightButton.OnClick := OnRightButtonClick;
  FRightButton.Anchors := [akRight, akTop];
  FTabsVisible := True;
end;

procedure TSuperPageControl.CreateWnd;
{var
  I: Integer;}
begin
  inherited;
  //Удостоверяемся что все сртаницы созданы
{  for I := 0 to FPages.Count - 1 do
  begin
    if not TSuperTabSheet(FPages[I]).HandleAllocated then
    begin
      TSuperTabSheet(FPages[I]).HandleNeeded;
    end;
  end;}
end;

destructor TSuperPageControl.Destroy;
var
  I: Integer;
begin
  for I := 0 to FPages.Count - 1 do TSuperTabSheet(FPages[I]).FPageControl := nil;
  FPages.Free;
  FImageChangeLink.Free;
  
  inherited;
end;

procedure TSuperPageControl.DoAddDockClient(Client: TControl;
  const ARect: TRect);
begin
  if FNewDockSheet <> nil then Client.Parent := FNewDockSheet;
end;

procedure TSuperPageControl.DockOver(Source: TDragDockObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  R: TRect;
begin
  GetWindowRect(Handle, R);
  Source.DockRect := R;
  DoDockOver(Source, X, Y, State, Accept);
end;

procedure TSuperPageControl.DoDrawTab(TabIndex: Integer; const Rect: TRect;
  Active: Boolean);
begin
  if Assigned(OnDrawTab) then
    OnDrawTab(Self, TabIndex, Rect, Active);
end;

procedure TSuperPageControl.DoPaint;
begin
  if Assigned(OnPaint) then
    OnPaint(Self);
end;

procedure TSuperPageControl.DoRemoveDockClient(Client: TControl);
begin
  if (FUndockingPage <> nil) and not (csDestroying in ComponentState) then
  begin
    SelectNextPage(True);
    FUndockingPage.Free;
    FUndockingPage := nil;
  end;
end;

function TSuperPageControl.FindNextPage(CurPage: TSuperTabSheet; GoForward,
  CheckTabVisible: Boolean): TSuperTabSheet;
var
  I, StartIndex: Integer;
begin
  if FPages.Count <> 0 then
  begin
    StartIndex := FPages.IndexOf(CurPage);
    if StartIndex = -1 then
      if GoForward then StartIndex := FPages.Count - 1 else StartIndex := 0;
    I := StartIndex;
    repeat
      if GoForward then
      begin
        Inc(I);
        if I = FPages.Count then I := 0;
      end else
      begin
        if I = 0 then I := FPages.Count;
        Dec(I);
      end;
      Result := FPages[I];
      if not CheckTabVisible or Result.TabVisible then Exit;
    until I = StartIndex;
  end;
  Result := nil;
end;

function TSuperPageControl.GetActivePageIndex: Integer;
begin
  if ActivePage <> nil then
    Result := ActivePage.GetPageIndex
  else
    Result := -1;
end;

procedure TSuperPageControl.GetChildren(Proc: TGetChildProc;
  Root: TComponent);
var
  I: Integer;
begin
  for I := 0 to FPages.Count - 1 do Proc(TComponent(FPages[I]));
end;

function TSuperPageControl.GetClientRect: TRect;
begin
  ZeroMemory(@Result, SizeOf(Result));
  case TabPosition of
    tpTop:
    begin
      if TabsVisible then
        Result.Top := TabHeight;
      Result.Top := Result.Top + FBorder;
      Result.Left := {Left + }FBorder;
      Result.Right := Width - FBorder;
      Result.Bottom := Height - FBorder;
    end;
{    tpBottom:
    begin
      Result.Right := Width;
      if TabsVisible then
        Result.Bottom := Height - TabHeight
      else
        Result := Height;
    end;
    tpLeft:
    begin
      Result.Left := TabHeight;
      Result.Right := Width;
      Result.Bottom := Height;
    end;
    tpRight:
    begin
      Result.Right := Width - TabHeight;
      Result.Bottom := Height;
    end;}
  end;
end;

function TSuperPageControl.GetDisplayRect: TRect;
begin
  Result := ClientRect;
end;

function TSuperPageControl.GetDockClientFromMousePos(
  MousePos: TPoint): TControl;
var
  i, HitIndex: Integer;
  Page: TSuperTabSheet;
begin
  Result := nil;
  if DockSite then
  begin
    HitIndex := GetTabIndexFromXY(MousePos.X, MousePos.Y);
    if HitIndex >= 0 then
    begin
      Page := nil;
      for i := 0 to HitIndex do
        Page := FindNextPage(Page, True, True);
      if (Page <> nil) and (Page.ControlCount > 0) then
      begin
        Result := Page.Controls[0];
        if Result.HostDockSite <> Self then Result := nil;
      end;
    end;
  end;
end;

function TSuperPageControl.GetImageIndex(TabIndex: Integer): Integer;
var
  I,
  Visible,
  NotVisible: Integer;
begin
  if Assigned(FOnGetImageIndex) then
  begin
    Result := TabIndex;
    if Assigned(FOnGetImageIndex) then FOnGetImageIndex(Self, TabIndex, Result);
  end else
  begin
    Visible := 0;
    NotVisible := 0;
    for I := 0 to FPages.Count - 1 do
    begin
      if not GetPages(I).TabVisible then Inc(NotVisible)
      else Inc(Visible);
      if Visible = TabIndex + 1 then Break;
    end;
    Result := GetPages(TabIndex + NotVisible).ImageIndex;
  end;
end;

function TSuperPageControl.GetLastVisibleTabIndex: Integer;
var
  I: Integer;
begin
  Result := - 1;
  if FPages <> nil then
  begin
    for I := 0 to FPages.Count - 1 do
      if TSuperTabSheet(FPages[I]).FTabVisible then
        Result := I;
  end;      
end;

function TSuperPageControl.GetLeftRect: TRect;
var
  R: TRect;
begin
  R := GetTabsRect;
  case TabPosition of
    tpTop:
    begin
      Result.Left := R.Right - 2 * 16 - 2;
      Result.Top := R.Top + (R.Bottom - R.Top - 16) div 2;
      Result.Right := Result.Left + 16;
      Result.Bottom := Result.Top + 16;
    end;
    tpBottom:
    begin
      Assert(False, 'Реализовать')
    end;
    tpLeft:
    begin
      Assert(False, 'Реализовать')
    end;
    tpRight:
    begin
      Assert(False, 'Реализовать')
    end;
  end;
end;

function TSuperPageControl.GetPageCount: Integer;
begin
  if FPages <> nil then
    Result := FPages.Count
  else
    Result := 0;  
end;

function TSuperPageControl.GetPageFromDockClient(
  Client: TControl): TSuperTabSheet;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to PageCount - 1 do
  begin
    if (Client.Parent = Pages[I]) and (Client.HostDockSite = Self) then
    begin
      Result := Pages[I];
      Exit;
    end;
  end;
end;

function TSuperPageControl.GetPages(Index: Integer): TSuperTabSheet;
begin
  Result := TSuperTabSheet(FPages.Items[Index]);
end;

function TSuperPageControl.GetRightRect: TRect;
begin
  case TabPosition of
    tpTop:
    begin
      Result := GetLeftRect;
      Result.Left := Result.Right + 1;
      Result.Right := Result.Left + 16;
    end;
    tpBottom:
    begin
      Assert(False, 'Реализовать')
    end;
    tpLeft:
    begin
      Assert(False, 'Реализовать')
    end;
    tpRight:
    begin
      Assert(False, 'Реализовать')
    end;
  end;
end;

procedure TSuperPageControl.GetSiteInfo(Client: TControl;
  var InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
begin
  CanDock := GetPageFromDockClient(Client) = nil;
  inherited GetSiteInfo(Client, InfluenceRect, MousePos, CanDock);
end;

function TSuperPageControl.GetTabIndexFromXY(X, Y: Integer): Integer;
var
  I, Offset: Integer;
  R: TRect;
begin
  Result := - 1;
  if (Y >= cDivExtraSpace) and (Y <= TabHeight) then
  begin
    Offset := cHalfExtraSpace;
    for I := FFirstVisibleTabIndex to FPages.Count - 1 do
    begin
      if TSuperTabSheet(FPages[I]).FTabVisible then
      begin
        R.Left := Offset;
        R.Right := R.Left + CalcTabWidth(I);
        Offset := R.Right;
        if (X >= R.Left) and (X < R.Right) then
        begin
          Result := I;
          Break;
        end;
      end;
    end;
  end;
end;

function TSuperPageControl.GetTabRect(Index: Integer): TRect;
var
  I, Offset: Integer;
begin
{!!!!!!}
  Offset := cHalfExtraSpace; //cExtraSpace;
{!!!!!!}
  ZeroMemory(@Result, SizeOf(Result));
  for I := FFirstVisibleTabIndex to FPages.Count - 1 do
  begin
    if TSuperTabSheet(FPages[I]).FTabVisible then
    begin
      Result.Top := cDivExtraSpace;
      Result.Bottom := TabHeight;
      Result.Left := Offset;
      Result.Right := Result.Left + CalcTabWidth(I);
      Offset := Result.Right;
    end;
    if I = Index then Exit;
  end;
end;

function TSuperPageControl.GetTabsRect: TRect;
begin
  ZeroMemory(@Result, SizeOf(Result));
  if not TabsVisible then Exit;
  case TabPosition of
    tpTop:
    begin
      Result.Left := FBorder;
      Result.Right := Width - FBorder;
      Result.Top := FBorder;
      Result.Bottom := Result.Top + TabHeight;
    end;
{    tpBottom:
    begin
      Result.Top := Height - TabHeight;
      Result.Right := Width;
      Result.Bottom := Height;
    end;
    tpLeft:
    begin
      Result.Right := TabHeight;
      Result.Bottom := Height;
    end;
    tpRight:
    begin
      Result.Left := Width - TabHeight;
      Result.Right := Width;
      Result.Bottom := Height;
    end;}
  end;
end;

procedure TSuperPageControl.ImageListChange(Sender: TObject);
begin

end;

procedure TSuperPageControl.InsertPage(Page: TSuperTabSheet);
begin
  FPages.Add(Page);
  Page.FPageControl := Self;
  Page.Parent := Self;
  Invalidate;
  InvalidateTabs;
end;

procedure TSuperPageControl.InvalidateTabs;
begin
  PaintTabs;
end;

function TSuperPageControl.IsChild(AHandle: HWND): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FPages.Count - 1 do
  begin
    if TSuperTabSheet(FPages[I]).TabVisible then
      Result := (TSuperTabSheet(FPages[I]).Handle = AHandle) or
        TSuperTabSheet(FPages[I]).IsChild(FPages[I], AHandle);
    if Result then Exit;  
  end;
end;

procedure TSuperPageControl.Loaded;
begin
  inherited Loaded;
  UpdateTabHighlights;
end;

procedure TSuperPageControl.MakeTabVisible(Index: Integer);
var
  R, T: TRect;
  L: Integer;
begin
  if (FFirstVisibleTabIndex > Index) then
  begin
    if Index > 0 then
      FFirstVisibleTabIndex := Index
    else
      FFirstVisibleTabIndex := 0;
    Exit;
  end;

  T := GetTabRect(Index);
  R := GetTabsRect;
  L := R.Right;
  if FLeftButton.Visible then
    L := FLeftButton.Left;
  while (T.Right > L) and (FFirstVisibleTabIndex < Index) do
  begin
    Inc(FFirstVisibleTabIndex);
    T := GetTabRect(Index);
  end;
end;

procedure TSuperPageControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  inherited;
  if ssLeft in Shift then
  begin
    Index := GetTabIndexFromXY(X, Y);
    if Index > - 1 then FTabIndex := Index;
    Change;
  end;
end;

function TSuperPageControl.NextVisibleTabIndex: Integer;
var
  I: Integer;
begin
  Result := FFirstVisibleTabIndex;
  for I := FFirstVisibleTabIndex + 1 to FPages.Count - 1 do
  begin
    if TSuperTabSheet(FPages[I]).TabVisible then
    begin
      Result := I;
      Break;
    end
  end;
end;

procedure TSuperPageControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

end;

procedure TSuperPageControl.OnFontChange(Sender: TObject);
begin
  TabHeight := Abs(Font.Height) + cDobleExtraSpace + cDivExtraSpace;
end;

procedure TSuperPageControl.OnLeftButtonClick(Sender: TObject);
var
  I: Integer;
begin
  I := PrevVisibleTabIndex;
  if I <> FFirstVisibleTabIndex then
  begin
    FFirstVisibleTabIndex := I;
    CheckButtonsVisible;
    InvalidateTabs;
  end;
end;

procedure TSuperPageControl.OnRightButtonClick(Sender: TObject);
var
  I: Integer;
  R: TRect;
begin
  R := GetTabRect(GetLastVisibleTabIndex);
  if R.Right > FLeftButton.Left then
  begin
    I := NextVisibleTabIndex;
    if I <> FFirstVisibleTabIndex then
    begin
      FFirstVisibleTabIndex := I;
      CheckButtonsVisible;
      InvalidateTabs;
    end;
  end;  
end;

procedure TSuperPageControl.Paint;
begin
  DoPaint;
  PaintTabs;
  //paint border of page control
  if FBorderStyle = bsSingle then
  begin
    with Canvas do
    begin
      Brush.Color := clGray;
      FrameRect(Rect(0, 0, Width, Height));
    end;
  end;
end;

procedure TSuperPageControl.PaintTabs;
var
 I: Integer;
 R, TR: TRect;
 Offset: Integer;
 ClipRgn: HRgn;

 procedure ActiveBorder(ARect: TRect);
 begin
  Canvas.Pen.Color := clWhite;
  Canvas.MoveTo(ARect.Left, ARect.Bottom - 1);
  Canvas.LineTo(ARect.Left, ARect.Top);
  Canvas.LineTo(ARect.Right, ARect.Top);
  Canvas.Pen.Color := clBtnShadow;
  Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
 end;

 procedure DisableBorder(Arect: Trect);
 begin
  Canvas.Pen.Color := Color;
  Canvas.MoveTo(ARect.Right, ARect.Top);
  Canvas.LineTo(ARect.Right, ARect.Bottom - 1);
 end;
begin
  if not FTabsVisible then Exit;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := PCLightBrushColor;
  TR := GetTabsRect;
  ClipRgn := CreateRectRgnIndirect(TR);
  SelectClipRgn(Canvas.Handle, ClipRgn);
  try
    Canvas.FillRect(TR);
    Canvas.Pen.Color := clWhite;
    Canvas.MoveTo(TR.Left, TR.Bottom - 1);
    Canvas.LineTo(TR.Right, TR.Bottom - 1);
    if (FPages.Count > 0) then
    begin
      CheckButtonsVisible;
      DoPaint;
  {!!!!!!}
      Offset := cHalfExtraSpace; //cExtraSpace;
  {!!!!!!}
      for I := FFirstVisibleTabIndex to FPages.Count - 1 do
      begin
        if Offset >= Width - FBorder then Break;
        if TSuperTabSheet(FPages[I]).FTabVisible then
        begin
          R.Left := Offset;
          R.Right := R.Left + CalcTabWidth(I);
          Offset := R.Right;

          if R.Right >= Width then
            R.Right := Width - FBorder;

          R.Top := cDivExtraSpace + FBorder;
          R.Bottom := TabHeight + FBorder;


          if I = ActivePageIndex then
          begin
            Canvas.Brush.Color := Color;
            Canvas.FillRect(R);
            ActiveBorder(R);
          end else
          begin
            Canvas.Brush.Color := PCLightBrushColor;
            DisableBorder(R);
          end;

          if OwnerDraw then
            DoDrawTab(I, R, I = ActivePageIndex)
          else
          begin
            if Focused and (I = ActivePageIndex) then
              Canvas.Font.Style := [fsBold]
            else
              Canvas.Font.Style := [];

            Canvas.TextOut(R.Left + cExtraSpace, cExtraSpace + cDivExtraSpace,
              TSuperTabSheet(FPages[I]).Caption);
          end;
        end;
      end;
      if FLeftButton.Visible then
      begin
        R := GetTabsRect;
        R.Left := FLeftButton.Left;
        R.Bottom := R.Bottom - 1;
        Canvas.Brush.Color := PCLightBrushColor;
        Canvas.FillRect(R);
        Canvas.Pen.Color := clWhite;
        Canvas.MoveTo(R.Left, R.Bottom);
        Canvas.LineTo(R.Right, R.Bottom);
      end;
      FLeftButton.Invalidate;
      FRightButton.Invalidate;
    end;
  finally
    DeleteObject(ClipRgn);
    ClipRgn := CreateRectRgnIndirect(Rect(0, 0, Width, Height));
    SelectClipRgn(Canvas.Handle, ClipRgn);
    DeleteObject(ClipRgn);
  end;
end;

function TSuperPageControl.PrevVisibleTabIndex: Integer;
var
  I: Integer;
begin
  Result := FFirstVisibleTabIndex;
  for I := FFirstVisibleTabIndex - 1 downto 0 do
  begin
    if TSuperTabSheet(FPages[I]).TabVisible then
    begin
      Result := I;
      Break;
    end
  end;
end;

procedure TSuperPageControl.RemovePage(Page: TSuperTabSheet);
var
  NextSheet: TSuperTabSheet;
  I: Integer;
begin
  NextSheet := FindNextPage(Page, True, not (csDesigning in ComponentState));
  if NextSheet = Page then NextSheet := nil;
  Page.SetTabShowing(False);
  Page.FPageControl := nil;
  I := FPages.IndexOf(Page);
  FPages.Remove(Page);
  if (FFirstVisibleTabIndex >= I) and (FFirstVisibleTabIndex > 0) then
    Dec(FFirstVisibleTabIndex);
  SetActivePage(NextSheet);
end;

procedure TSuperPageControl.Resize;
begin
  inherited;
  CheckButtonsVisible;
end;

procedure TSuperPageControl.SelectNextPage(GoForward,
  CheckTabVisible: Boolean);
var
  Page: TSuperTabSheet;
begin
  Page := FindNextPage(ActivePage, GoForward, CheckTabVisible);
  SetActivePage(Page);
  if (Page <> nil) and (Page <> ActivePage) and CanChange then
    Change;
end;

procedure TSuperPageControl.SetActivePage(Page: TSuperTabSheet);
begin
  ChangeActivePage(Page);
  if Page = nil then
    FTabIndex := -1
  else if Page = FActivePage then
    FTabIndex := Page.GetPageIndex;
end;

procedure TSuperPageControl.SetActivePageIndex(const Value: Integer);
begin
  if (Value > -1) and (Value < PageCount) then
    ActivePage := Pages[Value]
  else
    ActivePage := nil;
end;

procedure TSuperPageControl.SetBorderStyle(const Value: TBorderStyle);
begin
  FBorderStyle := Value;
  if Value = bsSingle then
    FBorder := 1
  else
    FBorder := 0;
  Repaint;
end;

procedure TSuperPageControl.SetChildOrder(Child: TComponent;
  Order: Integer);
begin
end;

procedure TSuperPageControl.SetHotTrack(const Value: Boolean);
begin
  FHotTrack := Value;
end;

procedure TSuperPageControl.SetImages(const Value: TCustomImageList);
begin
  FImages := Value;
end;

{procedure TSuperPageControl.SetOnDrawTab(const Value: TDrawTabEvent);
begin
  FOnDrawTab := Value;
end;}

procedure TSuperPageControl.SetOnPaint(const Value: TNotifyEvent);
begin
  FOnPaint := Value;
end;

procedure TSuperPageControl.SetOwnerDraw(const Value: Boolean);
begin
  FOwnerDraw := Value;
end;

procedure TSuperPageControl.SetRaggedRight(const Value: Boolean);
begin
  FRaggedRight := Value;
end;

procedure TSuperPageControl.SetStyle(const Value: TTabStyle);
begin
  FStyle := Value;
end;

procedure TSuperPageControl.SetTabHeight(const Value: Smallint);
begin
  FTabSize.Y := Value;
end;

procedure TSuperPageControl.SetTabPosition(const Value: TTabPosition);
begin
  FTabPosition := Value;
end;


procedure TSuperPageControl.SetTabsVisible(const Value: Boolean);
begin
  FTabsVisible := Value;
end;

procedure TSuperPageControl.SetTabWidth(const Value: Smallint);
begin
  FTabSize.X := Value;
end;

procedure TSuperPageControl.ShowControl(AControl: TControl);
begin
  if (AControl is TSuperTabSheet) and (TSuperTabSheet(AControl).PageControl = Self) then
    SetActivePage(TSuperTabSheet(AControl));
  inherited ShowControl(AControl);
end;

procedure TSuperPageControl.UpdateActivePage;
begin
  if FTabIndex >= 0 then
    SetActivePage(TSuperTabSheet(FPages[FTabIndex]))
  else
    SetActivePage(nil);
end;

procedure TSuperPageControl.UpdateTab(Page: TSuperTabSheet);
begin
  InvalidateTabs;
end;

procedure TSuperPageControl.UpdateTabHighlights;
var
  I: Integer;
begin
  for I := 0 to PageCount - 1 do
    Pages[I].SetHighlighted(Pages[I].FHighlighted);
end;

procedure TSuperPageControl.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  if FActivePage = nil then
    inherited;
end;

procedure TSuperPageControl.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  InvalidateTabs;
end;

procedure TSuperPageControl.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  DockCtl: TControl;
begin
  inherited;
  DockCtl := GetDockClientFromMousePos(SmallPointToPoint(Message.Pos));
  if DockCtl <> nil then DockCtl.ManualDock(nil, nil, alNone);
end;

procedure TSuperPageControl.WMLButtonDown(var Message: TWMLButtonDown);
var
  DockCtl: TControl;
begin
  inherited;
  DockCtl := GetDockClientFromMousePos(SmallPointToPoint(Message.Pos));
  if (DockCtl <> nil) and (Style = tsTabs) then DockCtl.BeginDrag(False);
end;

procedure TSuperPageControl.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  InvalidateTabs;
end;

{ TSuperTabSheet }

constructor TSuperTabSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alClient;
  ControlStyle := ControlStyle + [csAcceptsControls, csNoDesignVisible];
  Visible := False;
  FTabVisible := True;
  FHighlighted := False;
end;

procedure TSuperTabSheet.CreateWnd;
begin
  inherited;
end;

destructor TSuperTabSheet.Destroy;
begin
  if FPageControl <> nil then SetPageControl(nil);
  inherited;
end;

procedure TSuperTabSheet.DoHide;
begin
  if Assigned(FOnHide) then FOnHide(Self);
end;

procedure TSuperTabSheet.DoShow;
begin
  if Assigned(FOnShow) then FOnShow(Self);
end;

function TSuperTabSheet.GetClientRect: TRect;
begin
  Result := inherited GetClientRect
end;

function TSuperTabSheet.GetPageIndex: Integer;
begin
  if FPageControl <> nil then
    Result := FPageControl.FPages.IndexOf(Self) else
    Result := -1;
end;

function TSuperTabSheet.IsChild(WinControl: TWinControl; AHandle: HWND): Boolean;
var
  I: Integer;
begin
  Result := (WinControl.Handle = AHandle) and not ((WinControl is TSuperPageControl) or
    (WinControl is TSuperTabSheet));
  if Result then Exit;
  for I := 0 to WinControl.ControlCount - 1 do
  begin
    if (WinControl.Controls[I] is TWinControl) and
      not ((WinControl.Controls[I] is TSuperPageControl) or
      (WinControl.Controls[I] is TSuperTabSheet)) then
    begin
      Result := IsChild(TWinControl(WinControl.Controls[I]), AHandle);
      if Result then Exit;
    end;
  end;
end;

procedure TSuperTabSheet.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
  if Reader.Parent is TSuperPageControl then
    PageControl := TSuperPageControl(Reader.Parent);
end;

procedure TSuperTabSheet.SetHighlighted(const Value: Boolean);
begin
  FHighlighted := Value;
  if FTabShowing then FPageControl.UpdateTab(Self);
end;

procedure TSuperTabSheet.SetImageIndex(const Value: TImageIndex);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    if FTabShowing then FPageControl.UpdateTab(Self);
  end;
end;

procedure TSuperTabSheet.SetName(const Value: TComponentName);
begin
  inherited;
end;

procedure TSuperTabSheet.SetPageControl(const Value: TSuperPageControl);
begin
  if FPageControl <> Value then
  begin
    if FPageControl <> nil then FPageControl.RemovePage(Self);
//    Parent := Value;
    if Value <> nil then
    begin
      Value.InsertPage(Self);
      if Value.ActivePage = nil then Value.ActivePage := Self;
    end;
  end;
end;

procedure TSuperTabSheet.SetPageIndex(const Value: Integer);
var
  MaxPageIndex: Integer;
begin
  if FPageControl <> nil then
  begin
    MaxPageIndex := FPageControl.FPages.Count - 1;
    if Value > MaxPageIndex then
      raise EListError.CreateResFmt(@SPageIndexError, [Value, MaxPageIndex]);
    FPageControl.FPages.Move(PageIndex, Value);
  end;
end;

procedure TSuperTabSheet.SetParent(AParent: TWinControl);
begin
//  if (AParent is TSuperPageControl) or (AParent = nil) then
    inherited
//  else
//    raise Exception.Create('Parent must be TSuperPageControl');
end;

procedure TSuperTabSheet.SetTabShowing(Value: Boolean);
begin
  if FTabShowing <> Value then
  begin
    FTabShowing := Value;
    FPageControl.InvalidateTabs;
  end;
end;

procedure TSuperTabSheet.SetTabVisible(const Value: Boolean);
begin
  if FTabVisible <> Value then
  begin
    FTabVisible := Value;
    UpdateTabShowing;
  end;
end;

procedure TSuperTabSheet.ShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then
  begin
    try
      DoShow
    except
      Application.HandleException(Self);
    end;
  end else if not Showing then
  begin
    try
      DoHide;
    except
      Application.HandleException(Self);
    end;
  end;
end;

procedure TSuperTabSheet.TextChanged(var Message: TMessage);
begin
  if FTabShowing then FPageControl.UpdateTab(Self);
end;

procedure TSuperTabSheet.UpdateTabShowing;
begin
  SetTabShowing((FPageControl <> nil) and FTabVisible);
end;


{ TCursorButton }

procedure TCursorButton.CMDesignHitTest(var Message: TCMDesignHitTest);
begin
 if Message.Keys = MK_LBUTTON then
 begin
   if Assigned(OnClick) then
     OnClick(Self);
 end;
end;

procedure TCursorButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FMouseOn := True;
  Invalidate;
end;

procedure TCursorButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FMouseOn := False;
  Invalidate;
end;

constructor TCursorButton.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csOpaque];
  FBitMap := TBitmap.Create;
  FBitmap.Transparent := True;  
end;

destructor TCursorButton.Destroy;
begin
  FBitMap.Free;
  inherited;
end;

procedure TCursorButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  FMouseDown := True;
  Invalidate;
end;

procedure TCursorButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  FMouseDown := False;
  Invalidate;
end;

procedure TCursorButton.Paint;
var
  R: TRect;
begin
  inherited;
  R := GetClientRect;
  Canvas.Brush.Color := PCLightBrushColor;
  Canvas.FillRect(R);
  if FMouseOn or (csDesigning in ComponentState) then
  begin
    if FMouseDown  or (csDesigning in ComponentState) then
    begin
      Canvas.MoveTo(1, 1);
      Canvas.LineTo(R.Right - 1, 1);
      Canvas.LineTo(R.Right - 1, R.Bottom - 1);
      Canvas.LineTo(1, R.Bottom - 1);
      Canvas.LineTo(1, 1);
      Canvas.Draw(2, 2, FBitMap);
    end else
    begin
      Canvas.MoveTo(0, 0);
      Canvas.LineTo(R.Right - 2, 0);
      Canvas.LineTo(R.Right - 2, R.Bottom - 2);
      Canvas.LineTo(0, R.Bottom - 2);
      Canvas.LineTo(0, 0);

      Canvas.MoveTo(R.Right - 1, 2);
      Canvas.LineTo(R.Right - 1, R.Bottom - 1);
      Canvas.LineTo(2, R.Bottom - 1);

      Canvas.Draw(1, 1, FBitMap);
    end;
  end else
  begin
    Canvas.Draw(2, 2, FBitMap);
  end;
end;

procedure TCursorButton.SetBitmapName(const Value: string);
begin
  FBitmapName := Value;
  FBitMap.LoadFromResourceName(HInstance, Value);
end;

{ TSuperPageEditor }

procedure TSuperPageEditor.AddPage;
var
  TS: TSuperTabSheet;
begin
  {$IFDEF VER130}
  TS := TSuperTabSheet.Create(Designer.ContainerWindow);
  {$ELSE}
  TS := TSuperTabSheet.Create(Designer.Root);
  {$ENDIF}
  TS.PageControl := TSuperPageControl(Component);
  TS.Name := Designer.UniqueName('SuperTabSheet');
end;

procedure TSuperPageEditor.Edit;
begin

end;

procedure TSuperPageEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: AddPage;
    1: NextPage;
    2: PrevPage;
  end;
end;

function TSuperPageEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Добавить страницу';
    1: Result := 'Следующая страница';
    2: Result := 'Предыдущая страница';
  else
    Result := '';
  end;
end;

function TSuperPageEditor.GetVerbCount: Integer;
begin
  Result := 3;
end;

procedure TSuperPageEditor.NextPage;
begin
  TSuperPageControl(Component).SelectNextPage(True, False);
end;

procedure TSuperPageEditor.PrevPage;
begin
  TSuperPageControl(Component).SelectNextPage(False, False);
end;

initialization
  CalculateLightBrushColor;

end.
