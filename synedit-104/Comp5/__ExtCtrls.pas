
{*******************************************************}
{                                                       }
{       Borland Delphi Visual Component Library         }
{                                                       }
{       Copyright (c) 1995,98 Inprise Corporation       }
{                                                       }
{       Произведены исправления Денисом                 }
{                                                       }
{*******************************************************}

unit ExtCtrls;

{$S-,W-,R-}
{$C PRELOAD}

interface

uses Messages, Windows, SysUtils, Classes, Controls, Forms, Menus, Graphics,
  StdCtrls;

type

  TShapeType = (stRectangle, stSquare, stRoundRect, stRoundSquare,
    stEllipse, stCircle);

  TShape = class(TGraphicControl)
  private
    FPen: TPen;
    FBrush: TBrush;
    FShape: TShapeType;
    procedure SetBrush(Value: TBrush);
    procedure SetPen(Value: TPen);
    procedure SetShape(Value: TShapeType);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    procedure StyleChanged(Sender: TObject);
    property Align;
    property Anchors;
    property Brush: TBrush read FBrush write SetBrush;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Constraints;
    property ParentShowHint;
    property Pen: TPen read FPen write SetPen;
    property Shape: TShapeType read FShape write SetShape default stRectangle;
    property ShowHint;
    property Visible;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TPaintBox = class(TGraphicControl)
  private
    FOnPaint: TNotifyEvent;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Canvas;
  published
    property Align;
    property Anchors;
    property Color;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnStartDock;
    property OnStartDrag;
  end;

  TImage = class(TGraphicControl)
  private
    FPicture: TPicture;
    FOnProgress: TProgressEvent;
    FStretch: Boolean;
    FCenter: Boolean;
    FIncrementalDisplay: Boolean;
    FTransparent: Boolean;
    FDrawing: Boolean;
    function GetCanvas: TCanvas;
    procedure PictureChanged(Sender: TObject);
    procedure SetCenter(Value: Boolean);
    procedure SetPicture(Value: TPicture);
    procedure SetStretch(Value: Boolean);
    procedure SetTransparent(Value: Boolean);
  protected
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    function DestRect: TRect;
    function DoPaletteChange: Boolean;
    function GetPalette: HPALETTE; override;
    procedure Paint; override;
    procedure Progress(Sender: TObject; Stage: TProgressStage;
      PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Canvas: TCanvas read GetCanvas;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property Center: Boolean read FCenter write SetCenter default False;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property IncrementalDisplay: Boolean read FIncrementalDisplay write FIncrementalDisplay default False;
    property ParentShowHint;
    property Picture: TPicture read FPicture write SetPicture;
    property PopupMenu;
    property ShowHint;
    property Stretch: Boolean read FStretch write SetStretch default False;
    property Transparent: Boolean read FTransparent write SetTransparent default False;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
    property OnStartDock;
    property OnStartDrag;
  end;

  TBevelStyle = (bsLowered, bsRaised);
  TBevelShape = (bsBox, bsFrame, bsTopLine, bsBottomLine, bsLeftLine,
    bsRightLine, bsSpacer);

  TBevel = class(TGraphicControl)
  private
    FStyle: TBevelStyle;
    FShape: TBevelShape;
    procedure SetStyle(Value: TBevelStyle);
    procedure SetShape(Value: TBevelShape);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Constraints;
    property ParentShowHint;
    property Shape: TBevelShape read FShape write SetShape default bsBox;
    property ShowHint;
    property Style: TBevelStyle read FStyle write SetStyle default bsLowered;
    property Visible;
  end;

  TTimer = class(TComponent)
  private
    FInterval: Cardinal;
    FWindowHandle: HWND;
    FOnTimer: TNotifyEvent;
    FEnabled: Boolean;
    procedure UpdateTimer;
    procedure SetEnabled(Value: Boolean);
    procedure SetInterval(Value: Cardinal);
    procedure SetOnTimer(Value: TNotifyEvent);
    procedure WndProc(var Msg: TMessage);
  protected
    procedure Timer; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Interval: Cardinal read FInterval write SetInterval default 1000;
    property OnTimer: TNotifyEvent read FOnTimer write SetOnTimer;
  end;

  TPanelBevel = TBevelCut;

  TCustomPanel = class(TCustomControl)
  private
    FAutoSizeDocking: Boolean;
    FBevelInner: TPanelBevel;
    FBevelOuter: TPanelBevel;
    FBevelWidth: TBevelWidth;
    FBorderWidth: TBorderWidth;
    FBorderStyle: TBorderStyle;
    FFullRepaint: Boolean;
    FLocked: Boolean;
    FAlignment: TAlignment;
    procedure CMBorderChanged(var Message: TMessage); message CM_BORDERCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMIsToolControl(var Message: TMessage); message CM_ISTOOLCONTROL;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure SetAlignment(Value: TAlignment);
    procedure SetBevelInner(Value: TPanelBevel);
    procedure SetBevelOuter(Value: TPanelBevel);
    procedure SetBevelWidth(Value: TBevelWidth);
    procedure SetBorderWidth(Value: TBorderWidth);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure CMDockClient(var Message: TCMDockClient); message CM_DOCKCLIENT;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AdjustClientRect(var Rect: TRect); override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Paint; override;
    property Alignment: TAlignment read FAlignment write SetAlignment default taCenter;
    property BevelInner: TPanelBevel read FBevelInner write SetBevelInner default bvNone;
    property BevelOuter: TPanelBevel read FBevelOuter write SetBevelOuter default bvRaised;
    property BevelWidth: TBevelWidth read FBevelWidth write SetBevelWidth default 1;
    property BorderWidth: TBorderWidth read FBorderWidth write SetBorderWidth default 0;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsNone;
    property Color default clBtnFace;
    property FullRepaint: Boolean read FFullRepaint write FFullRepaint default True;
    property Locked: Boolean read FLocked write FLocked default False;
    property ParentColor default False;
  public
    constructor Create(AOwner: TComponent); override;
    function GetControlsAlignment: TAlignment; override;
  end;

  TPanel = class(TCustomPanel)
  public
    property DockManager;
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderWidth;
    property BorderStyle;
    property Caption;
    property Color;
    property Constraints;
    property Ctl3D;
    property UseDockManager default True;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FullRepaint;
    property Font;
    property Locked;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

  TPage = class(TCustomControl)
  private
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  protected
    procedure ReadState(Reader: TReader); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property Height stored False;
    property TabOrder stored False;
    property Visible stored False;
    property Width stored False;
  end;

  TNotebook = class(TCustomControl)
  private
    FPageList: TList;
    FAccess: TStrings;
    FPageIndex: Integer;
    FOnPageChanged: TNotifyEvent;
    procedure SetPages(Value: TStrings);
    procedure SetActivePage(const Value: string);
    function GetActivePage: string;
    procedure SetPageIndex(Value: Integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetChildOwner: TComponent; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure ReadState(Reader: TReader); override;
    procedure ShowControl(AControl: TControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ActivePage: string read GetActivePage write SetActivePage stored False;
    property Align;
    property Anchors;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Font;
    property Enabled;
    property Constraints;
    property PageIndex: Integer read FPageIndex write SetPageIndex default 0;
    property Pages: TStrings read FAccess write SetPages stored False;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPageChanged: TNotifyEvent read FOnPageChanged write FOnPageChanged;
    property OnStartDock;
    property OnStartDrag;
  end;

{ THeader
  Purpose  - Creates sectioned visual header that allows each section to be
             resized with the mouse.
  Features - This is a design-interactive control.  In design mode, the
             sections are named using the string-list editor.  Each section
             can now be manually resized using the right mouse button the grab
             the divider and drag to the new size.  Changing the section list
             at design (or even run-time), will attempt to maintain the
             section widths for sections that have not been changed.
  Properties:
    Align - Standard property.
    AllowResize - If True, the control allows run-time mouse resizing of the
                  sections.
    BorderStyle - Turns the border on and off.
    Font - Standard property.
    Sections - A special string-list that contains the section text.
    ParentFont - Standard property.
    OnSizing - Event called for each mouse move during a section resize
               operation.
    OnSized - Event called once the size operation is complete.

    SectionWidth - Array property allowing run-time getting and setting of
                   each section's width. }

  TSectionEvent = procedure(Sender: TObject;
    ASection, AWidth: Integer) of object;

  THeader = class(TCustomControl)
  private
    FSections: TStrings;
    FHitTest: TPoint;
    FCanResize: Boolean;
    FAllowResize: Boolean;
    FBorderStyle: TBorderStyle;
    FResizeSection: Integer;
    FMouseOffset: Integer;
    FOnSizing: TSectionEvent;
    FOnSized: TSectionEvent;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure FreeSections;
    procedure SetSections(Strings: TStrings);
    function GetWidth(X: Integer): Integer;
    procedure SetWidth(X: Integer; Value: Integer);
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  protected
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Sizing(ASection, AWidth: Integer); dynamic;
    procedure Sized(ASection, AWidth: Integer); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property SectionWidth[X: Integer]: Integer read GetWidth write SetWidth;
  published
    property Align;
    property AllowResize: Boolean read FAllowResize write FAllowResize default True;
    property Anchors;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Sections: TStrings read FSections write SetSections;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnSizing: TSectionEvent read FOnSizing write FOnSizing;
    property OnSized: TSectionEvent read FOnSized write FOnSized;
  end;

  TCustomRadioGroup = class(TCustomGroupBox)
  private
    FButtons: TList;
    FItems: TStrings;
    FItemIndex: Integer;
    FColumns: Integer;
    FReading: Boolean;
    FUpdating: Boolean;
    procedure ArrangeButtons;
    procedure ButtonClick(Sender: TObject);
    procedure ItemsChange(Sender: TObject);
    procedure SetButtonCount(Value: Integer);
    procedure SetColumns(Value: Integer);
    procedure SetItemIndex(Value: Integer);
    procedure SetItems(Value: TStrings);
    procedure UpdateButtons;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    procedure ReadState(Reader: TReader); override;
    function CanModify: Boolean; virtual;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    property Columns: Integer read FColumns write SetColumns default 1;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property Items: TStrings read FItems write SetItems;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FlipChildren(AllLevels: Boolean); override;
  end;

  TRadioGroup = class(TCustomRadioGroup)
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Caption;
    property Color;
    property Columns;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ItemIndex;
    property Items;
    property Constraints;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnStartDock;
    property OnStartDrag;
  end;

  NaturalNumber = 1..High(Integer);

  TCanResizeEvent = procedure(Sender: TObject; var NewSize: Integer;
    var Accept: Boolean) of object;

  TResizeStyle = (rsNone, rsLine, rsUpdate, rsPattern);

  TSplitter = class(TGraphicControl)
  private
    FActiveControl: TWinControl;
    FBeveled: Boolean;
    FBrush: TBrush;
    FControl: TControl;
    FDownPos: TPoint;
    FLineDC: HDC;
    FLineVisible: Boolean;
    FMinSize: NaturalNumber;
    FMaxSize: Integer;
    FNewSize: Integer;
    FOldKeyDown: TKeyEvent;
    FOldSize: Integer;
    FPrevBrush: HBrush;
    FResizeStyle: TResizeStyle;
    FSplit: Integer;
    FOnCanResize: TCanResizeEvent;
    FOnMoved: TNotifyEvent;
    FOnPaint: TNotifyEvent;
    procedure AllocateLineDC;
    procedure CalcSplitSize(X, Y: Integer; var NewSize, Split: Integer);
    procedure DrawLine;
    function FindControl: TControl;
    procedure FocusKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ReleaseLineDC;
    procedure SetBeveled(Value: Boolean);
    procedure UpdateControlSize;
    procedure UpdateSize(X, Y: Integer);
  protected
    function CanResize(var NewSize: Integer): Boolean; reintroduce; virtual;
    function DoCanResize(var NewSize: Integer): Boolean; virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    procedure RequestAlign; override;
    procedure StopSizing; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align default alLeft;
    property Beveled: Boolean read FBeveled write SetBeveled default False;
    property Color;
    property Constraints;
    property MinSize: NaturalNumber read FMinSize write FMinSize default 30;
    property ParentColor;
    property ResizeStyle: TResizeStyle read FResizeStyle write FResizeStyle
      default rsPattern;
    property Visible;
    property OnCanResize: TCanResizeEvent read FOnCanResize write FOnCanResize;
    property OnMoved: TNotifyEvent read FOnMoved write FOnMoved;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

{ TControlBar }

  TBandPaintOption = (bpoGrabber, bpoFrame);
  TBandPaintOptions = set of TBandPaintOption;

  TBandDragEvent = procedure (Sender: TObject; Control: TControl;
    var Drag: Boolean) of object;
  TBandInfoEvent = procedure (Sender: TObject; Control: TControl;
    var Insets: TRect; var PreferredSize, RowCount: Integer) of object;
  TBandMoveEvent = procedure (Sender: TObject; Control: TControl;
    var ARect: TRect) of object;
  TBandPaintEvent = procedure (Sender: TObject; Control: TControl;
    Canvas: TCanvas; var ARect: TRect; var Options: TBandPaintOptions) of object;

  TRowSize = 1..MaxInt;

  TCustomControlBar = class(TCustomControl)
  private
    FAligning: Boolean;
    FAutoDrag: Boolean;
    FDockingControl: TControl;
    FDragControl: TControl;
    FDragOffset: TPoint;
    FDrawing: Boolean;
    FFloating: Boolean;
    FItems: TList;
    FPicture: TPicture;
    FRowSize: TRowSize;
    FRowSnap: Boolean;
    FOnBandDrag: TBandDragEvent;
    FOnBandInfo: TBandInfoEvent;
    FOnBandMove: TBandMoveEvent;
    FOnBandPaint: TBandPaintEvent;
    FOnPaint: TNotifyEvent;
    procedure DoAlignControl(AControl: TControl);
    function FindPos(AControl: TControl): Pointer;
    function HitTest2(X, Y: Integer): Pointer;
    procedure DockControl(AControl: TControl; const ARect: TRect;
      BreakList, IndexList, SizeList: TList; Parent: Pointer;
      ChangedPriorBreak: Boolean; Insets: TRect; PreferredSize,
      RowCount: Integer; Existing: Boolean);
    procedure PictureChanged(Sender: TObject);
    procedure SetPicture(const Value: TPicture);
    procedure SetRowSize(Value: TRowSize);
    procedure SetRowSnap(Value: Boolean);
    procedure UnDockControl(AControl: TControl);
    function UpdateItems(AControl: TControl): Boolean;
    procedure CMControlListChange(var Message: TCMControlListChange); message CM_CONTROLLISTCHANGE;
    procedure CMDesignHitTest(var Message: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
  protected
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoBandMove(Control: TControl; var ARect: TRect); virtual;
    procedure DoBandPaint(Control: TControl; Canvas: TCanvas; var ARect: TRect;
      var Options: TBandPaintOptions); virtual;
    procedure DockOver(Source: TDragDockObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    function DoPaletteChange: Boolean;
    function DragControl(AControl: TControl; X, Y: Integer;
      KeepCapture: Boolean = False): Boolean; virtual;
    procedure GetControlInfo(AControl: TControl; var Insets: TRect;
      var PreferredSize, RowCount: Integer); virtual;
    function GetPalette: HPALETTE; override;
    procedure GetSiteInfo(Client: TControl; var InfluenceRect: TRect;
      MousePos: TPoint; var CanDock: Boolean); override;
    function HitTest(X, Y: Integer): TControl;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    procedure PaintControlFrame(Canvas: TCanvas; AControl: TControl;
      var ARect: TRect); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FlipChildren(AllLevels: Boolean); override;
    procedure StickControls; virtual;
    property Picture: TPicture read FPicture write SetPicture;
  protected
    property AutoDrag: Boolean read FAutoDrag write FAutoDrag default True;
    property AutoSize;
    property BevelKind default bkTile;
    property DockSite default True;
    property RowSize: TRowSize read FRowSize write SetRowSize default 26;
    property RowSnap: Boolean read FRowSnap write SetRowSnap default True;
    property OnBandDrag: TBandDragEvent read FOnBandDrag write FOnBandDrag;
    property OnBandInfo: TBandInfoEvent read FOnBandInfo write FOnBandInfo;
    property OnBandMove: TBandMoveEvent read FOnBandMove write FOnBandMove;
    property OnBandPaint: TBandPaintEvent read FOnBandPaint write FOnBandPaint;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

  TControlBar = class(TCustomControlBar)
  public
    property Canvas;
  published
    property Align;
    property Anchors;
    property AutoDrag;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind;
    property BevelWidth;
    property BorderWidth;
    property Color;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property Picture;
    property PopupMenu;
    property RowSize;
    property RowSnap;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnBandDrag;
    property OnBandInfo;
    property OnBandMove;
    property OnBandPaint;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

procedure Frame3D(Canvas: TCanvas; var Rect: TRect;
  TopColor, BottomColor: TColor; Width: Integer);

implementation

uses Consts;

{ Utility routines }

procedure Frame3D(Canvas: TCanvas; var Rect: TRect; TopColor, BottomColor: TColor;
  Width: Integer);

  procedure DoRect;
  var
    TopRight, BottomLeft: TPoint;
  begin
    with Canvas, Rect do
    begin
      TopRight.X := Right;
      TopRight.Y := Top;
      BottomLeft.X := Left;
      BottomLeft.Y := Bottom;
      Pen.Color := TopColor;
      PolyLine([BottomLeft, TopLeft, TopRight]);
      Pen.Color := BottomColor;
      Dec(BottomLeft.X);
      PolyLine([TopRight, BottomRight, BottomLeft]);
    end;
  end;

begin
  Canvas.Pen.Width := 1;
  Dec(Rect.Bottom); Dec(Rect.Right);
  while Width > 0 do
  begin
    Dec(Width);
    DoRect;
    InflateRect(Rect, -1, -1);
  end;
  Inc(Rect.Bottom); Inc(Rect.Right);
end;

{ TShape }

constructor TShape.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 65;
  Height := 65;
  FPen := TPen.Create;
  FPen.OnChange := StyleChanged;
  FBrush := TBrush.Create;
  FBrush.OnChange := StyleChanged;
end;

destructor TShape.Destroy;
begin
  FPen.Free;
  FBrush.Free;
  inherited Destroy;
end;

procedure TShape.Paint;
var
  X, Y, W, H, S: Integer;
begin
  with Canvas do
  begin
    Pen := FPen;
    Brush := FBrush;
    X := Pen.Width div 2;
    Y := X;
    W := Width - Pen.Width + 1;
    H := Height - Pen.Width + 1;
    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;
    if W < H then S := W else S := H;
    if FShape in [stSquare, stRoundSquare, stCircle] then
    begin
      Inc(X, (W - S) div 2);
      Inc(Y, (H - S) div 2);
      W := S;
      H := S;
    end;
    case FShape of
      stRectangle, stSquare:
        Rectangle(X, Y, X + W, Y + H);
      stRoundRect, stRoundSquare:
        RoundRect(X, Y, X + W, Y + H, S div 4, S div 4);
      stCircle, stEllipse:
        Ellipse(X, Y, X + W, Y + H);
    end;
  end;
end;

procedure TShape.StyleChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TShape.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TShape.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TShape.SetShape(Value: TShapeType);
begin
  if FShape <> Value then
  begin
    FShape := Value;
    Invalidate;
  end;
end;

{ TPaintBox }

constructor TPaintBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 105;
  Height := 105;
end;

procedure TPaintBox.Paint;
begin
  Canvas.Font := Font;
  Canvas.Brush.Color := Color;
  if csDesigning in ComponentState then
    with Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
  if Assigned(FOnPaint) then FOnPaint(Self);
end;

{ TImage }

constructor TImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FPicture.OnProgress := Progress;
  Height := 105;
  Width := 105;
end;

destructor TImage.Destroy;
begin
  FPicture.Free;
  inherited Destroy;
end;

function TImage.GetPalette: HPALETTE;
begin
  Result := 0;
  if FPicture.Graphic <> nil then
    Result := FPicture.Graphic.Palette;
end;

function TImage.DestRect: TRect;
begin
  if Stretch then
    Result := ClientRect
  else if Center then
    Result := Bounds((Width - Picture.Width) div 2, (Height - Picture.Height) div 2,
      Picture.Width, Picture.Height)
  else
    Result := Rect(0, 0, Picture.Width, Picture.Height);
end;

procedure TImage.Paint;
var
  Save: Boolean;
begin
  if csDesigning in ComponentState then
    with inherited Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
  Save := FDrawing;
  FDrawing := True;
  try
    with inherited Canvas do
      StretchDraw(DestRect, Picture.Graphic);
  finally
    FDrawing := Save;
  end;
end;

function TImage.DoPaletteChange: Boolean;
var
  ParentForm: TCustomForm;
  Tmp: TGraphic;
begin
  Result := False;
  Tmp := Picture.Graphic;
  if Visible and (not (csLoading in ComponentState)) and (Tmp <> nil) and
    (Tmp.PaletteModified) then
  begin
    if (Tmp.Palette = 0) then
      Tmp.PaletteModified := False
    else
    begin
      ParentForm := GetParentForm(Self);
      if Assigned(ParentForm) and ParentForm.Active and Parentform.HandleAllocated then
      begin
        if FDrawing then
          ParentForm.Perform(wm_QueryNewPalette, 0, 0)
        else
          PostMessage(ParentForm.Handle, wm_QueryNewPalette, 0, 0);
        Result := True;
        Tmp.PaletteModified := False;
      end;
    end;
  end;
end;

procedure TImage.Progress(Sender: TObject; Stage: TProgressStage;
  PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
begin
  if FIncrementalDisplay and RedrawNow then
  begin
    if DoPaletteChange then Update
    else Paint;
  end;
  if Assigned(FOnProgress) then FOnProgress(Sender, Stage, PercentDone, RedrawNow, R, Msg);
end;

function TImage.GetCanvas: TCanvas;
var
  Bitmap: TBitmap;
begin
  if Picture.Graphic = nil then
  begin
    Bitmap := TBitmap.Create;
    try
      Bitmap.Width := Width;
      Bitmap.Height := Height;
      Picture.Graphic := Bitmap;
    finally
      Bitmap.Free;
    end;
  end;
  if Picture.Graphic is TBitmap then
    Result := TBitmap(Picture.Graphic).Canvas
  else
    raise EInvalidOperation.Create(SImageCanvasNeedsBitmap);
end;

procedure TImage.SetCenter(Value: Boolean);
begin
  if FCenter <> Value then
  begin
    FCenter := Value;
    PictureChanged(Self);
  end;
end;

procedure TImage.SetPicture(Value: TPicture);
begin
  FPicture.Assign(Value);
end;

procedure TImage.SetStretch(Value: Boolean);
begin
  if Value <> FStretch then
  begin
    FStretch := Value;
    PictureChanged(Self);
  end;
end;

procedure TImage.SetTransparent(Value: Boolean);
begin
  if Value <> FTransparent then
  begin
    FTransparent := Value;
    PictureChanged(Self);
  end;
end;

procedure TImage.PictureChanged(Sender: TObject);
var
  G: TGraphic;
begin
  if AutoSize and (Picture.Width > 0) and (Picture.Height > 0) then
    SetBounds(Left, Top, Picture.Width, Picture.Height);
  G := Picture.Graphic;
  if G <> nil then
  begin
    if not ((G is TMetaFile) or (G is TIcon)) then
      G.Transparent := FTransparent;
    if (not G.Transparent) and (Stretch or (G.Width >= Width)
      and (G.Height >= Height)) then
      ControlStyle := ControlStyle + [csOpaque]
    else
      ControlStyle := ControlStyle - [csOpaque];
    if DoPaletteChange and FDrawing then Update;
  end
  else ControlStyle := ControlStyle - [csOpaque];
  if not FDrawing then Invalidate;
end;

function TImage.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := True;
  if not (csDesigning in ComponentState) or (Picture.Width > 0) and
    (Picture.Height > 0) then
  begin
    if Align in [alNone, alLeft, alRight] then
      NewWidth := Picture.Width;
    if Align in [alNone, alTop, alBottom] then
      NewHeight := Picture.Height;
  end;
end;

{ TBevel }

constructor TBevel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  FStyle := bsLowered;
  FShape := bsBox;
  Width := 50;
  Height := 50;
end;

procedure TBevel.SetStyle(Value: TBevelStyle);
begin
  if Value <> FStyle then
  begin
    FStyle := Value;
    Invalidate;
  end;
end;

procedure TBevel.SetShape(Value: TBevelShape);
begin
  if Value <> FShape then
  begin
    FShape := Value;
    Invalidate;
  end;
end;

procedure TBevel.Paint;
const
  XorColor = $00FFD8CE;
var
  Color1, Color2: TColor;
  Temp: TColor;

  procedure BevelRect(const R: TRect);
  begin
    with Canvas do
    begin
      Pen.Color := Color1;
      PolyLine([Point(R.Left, R.Bottom), Point(R.Left, R.Top),
        Point(R.Right, R.Top)]);
      Pen.Color := Color2;
      PolyLine([Point(R.Right, R.Top), Point(R.Right, R.Bottom),
        Point(R.Left, R.Bottom)]);
    end;
  end;

  procedure BevelLine(C: TColor; X1, Y1, X2, Y2: Integer);
  begin
    with Canvas do
    begin
      Pen.Color := C;
      MoveTo(X1, Y1);
      LineTo(X2, Y2);
    end;
  end;

begin
  with Canvas do
  begin
    if (csDesigning in ComponentState) then
    begin
      if (FShape = bsSpacer) then
      begin
        Pen.Style := psDot;
        Pen.Mode := pmXor;
        Pen.Color := XorColor;
        Brush.Style := bsClear;
        Rectangle(0, 0, ClientWidth, ClientHeight);
        Exit;
      end
      else
      begin
        Pen.Style := psSolid;
        Pen.Mode  := pmCopy;
        Pen.Color := clBlack;
        Brush.Style := bsSolid;
      end;
    end;

    Pen.Width := 1;

    if FStyle = bsLowered then
    begin
      Color1 := clBtnShadow;
      Color2 := clBtnHighlight;
    end
    else
    begin
      Color1 := clBtnHighlight;
      Color2 := clBtnShadow;
    end;

    case FShape of
      bsBox: BevelRect(Rect(0, 0, Width - 1, Height - 1));
      bsFrame:
        begin
          Temp := Color1;
          Color1 := Color2;
          BevelRect(Rect(1, 1, Width - 1, Height - 1));
          Color2 := Temp;
          Color1 := Temp;
          BevelRect(Rect(0, 0, Width - 2, Height - 2));
        end;
      bsTopLine:
        begin
          BevelLine(Color1, 0, 0, Width, 0);
          BevelLine(Color2, 0, 1, Width, 1);
        end;
      bsBottomLine:
        begin
          BevelLine(Color1, 0, Height - 2, Width, Height - 2);
          BevelLine(Color2, 0, Height - 1, Width, Height - 1);
        end;
      bsLeftLine:
        begin
          BevelLine(Color1, 0, 0, 0, Height);
          BevelLine(Color2, 1, 0, 1, Height);
        end;
      bsRightLine:
        begin
          BevelLine(Color1, Width - 2, 0, Width - 2, Height);
          BevelLine(Color2, Width - 1, 0, Width - 1, Height);
        end;
    end;
  end;
end;

{ TTimer }

constructor TTimer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabled := True;
  FInterval := 1000;
  FWindowHandle := AllocateHWnd(WndProc);
end;

destructor TTimer.Destroy;
begin
  FEnabled := False;
  UpdateTimer;
  DeallocateHWnd(FWindowHandle);
  inherited Destroy;
end;

procedure TTimer.WndProc(var Msg: TMessage);
begin
  with Msg do
    if Msg = WM_TIMER then
      try
        Timer;
      except
        Application.HandleException(Self);
      end
    else
      Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end;

procedure TTimer.UpdateTimer;
begin
  KillTimer(FWindowHandle, 1);
  if (FInterval <> 0) and FEnabled and Assigned(FOnTimer) then
    if SetTimer(FWindowHandle, 1, FInterval, nil) = 0 then
      raise EOutOfResources.Create(SNoTimers);
end;

procedure TTimer.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    UpdateTimer;
  end;
end;

procedure TTimer.SetInterval(Value: Cardinal);
begin
  if Value <> FInterval then
  begin
    FInterval := Value;
    UpdateTimer;
  end;
end;

procedure TTimer.SetOnTimer(Value: TNotifyEvent);
begin
  FOnTimer := Value;
  UpdateTimer;
end;

procedure TTimer.Timer;
begin
  if Assigned(FOnTimer) then FOnTimer(Self);
end;

{ TCustomPanel }

constructor TCustomPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
  Width := 185;
  Height := 41;
  FAlignment := taCenter;
  BevelOuter := bvRaised;
  BevelWidth := 1;
  FBorderStyle := bsNone;
  Color := clBtnFace;
  FFullRepaint := True;
  UseDockManager := True;
end;

procedure TCustomPanel.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or BorderStyles[FBorderStyle];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TCustomPanel.CMBorderChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TCustomPanel.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TCustomPanel.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

procedure TCustomPanel.CMIsToolControl(var Message: TMessage);
begin
  if not FLocked then Message.Result := 1;
end;

procedure TCustomPanel.WMWindowPosChanged(var Message: TWMWindowPosChanged);
var
  BevelPixels: Integer;
  Rect: TRect;
begin
  if FullRepaint or (Caption <> '') then
    Invalidate
  else
  begin
    BevelPixels := BorderWidth;
    if BevelInner <> bvNone then Inc(BevelPixels, BevelWidth);
    if BevelOuter <> bvNone then Inc(BevelPixels, BevelWidth);
    if BevelPixels > 0 then
    begin
      Rect.Right := Width;
      Rect.Bottom := Height;
      if Message.WindowPos^.cx <> Rect.Right then
      begin
        Rect.Top := 0;
        Rect.Left := Rect.Right - BevelPixels - 1;
        InvalidateRect(Handle, @Rect, True);
      end;
      if Message.WindowPos^.cy <> Rect.Bottom then
      begin
        Rect.Left := 0;
        Rect.Top := Rect.Bottom - BevelPixels - 1;
        InvalidateRect(Handle, @Rect, True);
      end;
    end;
  end;
  inherited;
end;

procedure TCustomPanel.Paint;
const
  Alignments: array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  Rect: TRect;
  TopColor, BottomColor: TColor;
  FontHeight: Integer;
  Flags: Longint;

  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

begin
  Rect := GetClientRect;
  if BevelOuter <> bvNone then
  begin
    AdjustColors(BevelOuter);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  Frame3D(Canvas, Rect, Color, Color, BorderWidth);
  if BevelInner <> bvNone then
  begin
    AdjustColors(BevelInner);
    Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
  end;
  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect);
    Brush.Style := bsClear;
    Font := Self.Font;
    FontHeight := TextHeight('W');
    with Rect do
    begin
      Top := ((Bottom + Top) - FontHeight) div 2;
      Bottom := Top + FontHeight;
    end;
    Flags := DT_EXPANDTABS or DT_VCENTER or Alignments[FAlignment];
    Flags := DrawTextBiDiModeFlags(Flags);
    DrawText(Handle, PChar(Caption), -1, Rect, Flags);
  end;
end;

procedure TCustomPanel.SetAlignment(Value: TAlignment);
begin
  FAlignment := Value;
  Invalidate;
end;

procedure TCustomPanel.SetBevelInner(Value: TPanelBevel);
begin
  FBevelInner := Value;
  Realign;
  Invalidate;
end;

procedure TCustomPanel.SetBevelOuter(Value: TPanelBevel);
begin
  FBevelOuter := Value;
  Realign;
  Invalidate;
end;

procedure TCustomPanel.SetBevelWidth(Value: TBevelWidth);
begin
  FBevelWidth := Value;
  Realign;
  Invalidate;
end;

procedure TCustomPanel.SetBorderWidth(Value: TBorderWidth);
begin
  FBorderWidth := Value;
  Realign;
  Invalidate;
end;

procedure TCustomPanel.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

function TCustomPanel.GetControlsAlignment: TAlignment;
begin
  Result := FAlignment;
end;

procedure TCustomPanel.AdjustClientRect(var Rect: TRect);
var
  BevelSize: Integer;
  I: Integer;
begin
  inherited AdjustClientRect(Rect);

  InflateRect(Rect, -BorderWidth, -BorderWidth);
  BevelSize := 0;
  if BevelOuter <> bvNone then Inc(BevelSize, BevelWidth);
  if BevelInner <> bvNone then Inc(BevelSize, BevelWidth);
  InflateRect(Rect, -BevelSize, -BevelSize);

  // Мое исправление

  for I := 0 to ControlCount - 1 do
    if
      (Controls[I] is TPanel)
        and
      (
        ((Controls[I] as TPanel).Width <> ClientWidth)
          or
        ((Controls[I] as TPanel).Height <> ClientHeight)
      )
        and
      ((Controls[I] as TPanel).Align = alClient)
    then
      (Controls[I] as TPanel).Realign;

end;

{ TPageAccess }

type
  TPageAccess = class(TStrings)
  private
    PageList: TList;
    Notebook: TNotebook;
  protected
    function GetCount: Integer; override;
    function Get(Index: Integer): string; override;
    procedure Put(Index: Integer; const S: string); override;
    function GetObject(Index: Integer): TObject; override;
    procedure SetUpdateState(Updating: Boolean); override;
  public
    constructor Create(APageList: TList; ANotebook: TNotebook);
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure Move(CurIndex, NewIndex: Integer); override;
  end;

constructor TPageAccess.Create(APageList: TList; ANotebook: TNotebook);
begin
  inherited Create;
  PageList := APageList;
  Notebook := ANotebook;
end;

function TPageAccess.GetCount: Integer;
begin
  Result := PageList.Count;
end;

function TPageAccess.Get(Index: Integer): string;
begin
  Result := TPage(PageList[Index]).Caption;
end;

procedure TPageAccess.Put(Index: Integer; const S: string);
begin
  TPage(PageList[Index]).Caption := S;
end;

function TPageAccess.GetObject(Index: Integer): TObject;
begin
  Result := PageList[Index];
end;

procedure TPageAccess.SetUpdateState(Updating: Boolean);
begin
  { do nothing }
end;

procedure TPageAccess.Clear;
var
  I: Integer;
begin
  for I := 0 to PageList.Count - 1 do
    TPage(PageList[I]).Free;
  PageList.Clear;
end;

procedure TPageAccess.Delete(Index: Integer);
var
  Form: TCustomForm;
begin
  TPage(PageList[Index]).Free;
  PageList.Delete(Index);
  NoteBook.PageIndex := 0;

  if csDesigning in NoteBook.ComponentState then
  begin
    Form := GetParentForm(NoteBook);
    if (Form <> nil) and (Form.Designer <> nil) then
      Form.Designer.Modified;
  end;
end;

procedure TPageAccess.Insert(Index: Integer; const S: string);
var
  Page: TPage;
  Form: TCustomForm;
begin
  Page := TPage.Create(Notebook);
  with Page do
  begin
    Parent := Notebook;
    Caption := S;
  end;
  PageList.Insert(Index, Page);

  NoteBook.PageIndex := Index;

  if csDesigning in NoteBook.ComponentState then
  begin
    Form := GetParentForm(NoteBook);
    if (Form <> nil) and (Form.Designer <> nil) then
      Form.Designer.Modified;
  end;
end;

procedure TPageAccess.Move(CurIndex, NewIndex: Integer);
var
  AObject: TObject;
begin
  if CurIndex <> NewIndex then
  begin
    AObject := PageList[CurIndex];
    PageList[CurIndex] := PageList[NewIndex];
    PageList[NewIndex] := AObject;
  end;
end;

procedure TCustomPanel.CMDockClient(var Message: TCMDockClient);
var
  R: TRect;
  Dim: Integer;
begin
  if AutoSize then
  begin
    FAutoSizeDocking := True;
    try
      R := Message.DockSource.DockRect;
      case Align of
        alLeft: if Width = 0 then Width := R.Right - R.Left;
        alRight: if Width = 0 then
          begin
            Dim := R.Right - R.Left;
            SetBounds(Left - Dim, Top, Dim, Height);
          end;
        alTop: if Height = 0 then Height := R.Bottom - R.Top;
        alBottom: if Height = 0 then
          begin
            Dim := R.Bottom - R.Top;
            SetBounds(Left, Top - Dim, Width, Dim);
          end;
      end;
      inherited;
      Exit;
    finally
      FAutoSizeDocking := False;
    end;
  end;
  inherited;
end;

function TCustomPanel.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := (not FAutoSizeDocking) and inherited CanAutoSize(NewWidth, NewHeight);
end;

{ TPage }

constructor TPage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Visible := False;
  ControlStyle := ControlStyle + [csAcceptsControls];
  Align := alClient;
end;

procedure TPage.Paint;
begin
  inherited Paint;
  if csDesigning in ComponentState then
    with Canvas do
    begin
      Pen.Style := psDash;
      Brush.Style := bsClear;
      Rectangle(0, 0, Width, Height);
    end;
end;

procedure TPage.ReadState(Reader: TReader);
begin
  if Reader.Parent is TNotebook then
    TNotebook(Reader.Parent).FPageList.Add(Self);
  inherited ReadState(Reader);
end;

procedure TPage.WMNCHitTest(var Message: TWMNCHitTest);
begin
  if not (csDesigning in ComponentState) then
    Message.Result := HTTRANSPARENT
  else
    inherited;
end;

{ TNotebook }

var
  Registered: Boolean = False;

constructor TNotebook.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 150;
  Height := 150;
  FPageList := TList.Create;
  FAccess := TPageAccess.Create(FPageList, Self);
  FPageIndex := -1;
  FAccess.Add(SDefault);
  PageIndex := 0;
  Exclude(FComponentStyle, csInheritable);
  if not Registered then
  begin
    Classes.RegisterClasses([TPage]);
    Registered := True;
  end;
end;

destructor TNotebook.Destroy;
begin
  FAccess.Free;
  FPageList.Free;
  inherited Destroy;
end;

procedure TNotebook.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_CLIPCHILDREN;
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

function TNotebook.GetChildOwner: TComponent;
begin
  Result := Self;
end;

procedure TNotebook.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  for I := 0 to FPageList.Count - 1 do Proc(TControl(FPageList[I]));
end;

procedure TNotebook.ReadState(Reader: TReader);
begin
  Pages.Clear;
  inherited ReadState(Reader);
  if (FPageIndex <> -1) and (FPageIndex >= 0) and (FPageIndex < FPageList.Count) then
    with TPage(FPageList[FPageIndex]) do
    begin
      BringToFront;
      Visible := True;
      Align := alClient;
    end
  else FPageIndex := -1;
end;

procedure TNotebook.ShowControl(AControl: TControl);
var
  I: Integer;
begin
  for I := 0 to FPageList.Count - 1 do
    if FPageList[I] = AControl then
    begin
      SetPageIndex(I);
      Exit;
    end;
  inherited ShowControl(AControl);
end;

procedure TNotebook.SetPages(Value: TStrings);
begin
  FAccess.Assign(Value);
end;

procedure TNotebook.SetPageIndex(Value: Integer);
var
  ParentForm: TCustomForm;
begin
  if csLoading in ComponentState then
  begin
    FPageIndex := Value;
    Exit;
  end;
  if (Value <> FPageIndex) and (Value >= 0) and (Value < FPageList.Count) then
  begin
    ParentForm := GetParentForm(Self);
    if ParentForm <> nil then
      if ContainsControl(ParentForm.ActiveControl) then
        ParentForm.ActiveControl := Self;
    with TPage(FPageList[Value]) do
    begin
      BringToFront;

      Visible := True;
      Align := alClient;

      // Мое исправление
      if (ControlCount > 0) and (Controls[0] is TPanel) and
        ((Controls[0] as TPanel).Align = alClient) then
      begin
        (Controls[0] as TPanel).Realign;
      end;
    end;
    if (FPageIndex >= 0) and (FPageIndex < FPageList.Count) then
      TPage(FPageList[FPageIndex]).Visible := False;
    FPageIndex := Value;
    if ParentForm <> nil then
      if ParentForm.ActiveControl = Self then SelectFirst;
    if Assigned(FOnPageChanged) then
      FOnPageChanged(Self);
  end;
end;

procedure TNotebook.SetActivePage(const Value: string);
begin
  SetPageIndex(FAccess.IndexOf(Value));
end;

function TNotebook.GetActivePage: string;
begin
  Result := FAccess[FPageIndex];
end;

{ THeaderStrings }

const
  DefaultSectionWidth = 75;

type
  PHeaderSection = ^THeaderSection;
  THeaderSection = record
    FObject: TObject;
    Width: Integer;
    Title: string;
  end;

type
  THeaderStrings = class(TStrings)
  private
    FHeader: THeader;
    FList: TList;
    procedure ReadData(Reader: TReader);
    procedure WriteData(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: string); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetUpdateState(Updating: Boolean); override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure Clear; override;
  end;

procedure FreeSection(Section: PHeaderSection);
begin
  if Section <> nil then Dispose(Section);
end;

function NewSection(const ATitle: string; AWidth: Integer; AObject: TObject): PHeaderSection;
begin
  New(Result);
  with Result^ do
  begin
    Title := ATitle;
    Width := AWidth;
    FObject := AObject;
  end;
end;

constructor THeaderStrings.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor THeaderStrings.Destroy;
begin
  if FList <> nil then
  begin
    Clear;
    FList.Free;
  end;
  inherited Destroy;
end;

procedure THeaderStrings.Assign(Source: TPersistent);
var
  I, J: Integer;
  Strings: TStrings;
  NewList: TList;
  Section: PHeaderSection;
  TempStr: string;
  Found: Boolean;
begin
  if Source is TStrings then
  begin
    Strings := TStrings(Source);
    BeginUpdate;
    try
      NewList := TList.Create;
      try
        { Delete any sections not in the new list }
        I := FList.Count - 1;
        Found := False;
        while I >= 0 do
        begin
          TempStr := Get(I);
          for J := 0 to Strings.Count - 1 do
          begin
            Found := AnsiCompareStr(Strings[J], TempStr) = 0;
            if Found then Break;
          end;
          if not Found then Delete(I);
          Dec(I);
        end;

        { Now iterate over the lists and maintain section widths of sections in
          the new list }
        I := 0;
        for J := 0 to Strings.Count - 1 do
        begin
          if (I < FList.Count) and (AnsiCompareStr(Strings[J], Get(I)) = 0) then
          begin
            Section := NewSection(Get(I), PHeaderSection(FList[I])^.Width, GetObject(I));
            Inc(I);
          end else
            Section := NewSection(Strings[J],
              FHeader.Canvas.TextWidth(Strings[J]) + 8, Strings.Objects[J]);
          NewList.Add(Section);
        end;
        Clear;
        FList.Destroy;
        FList := NewList;
        FHeader.Invalidate;
      except
        for I := 0 to NewList.Count - 1 do
          FreeSection(NewList[I]);
        NewList.Destroy;
        raise;
      end;
    finally
      EndUpdate;
    end;
    Exit;
  end;
  inherited Assign(Source);
end;

procedure THeaderStrings.DefineProperties(Filer: TFiler);
begin
  { This will allow the old file image read in }
  if Filer is TReader then inherited DefineProperties(Filer);
  Filer.DefineProperty('Sections', ReadData, WriteData, Count > 0);
end;

procedure THeaderStrings.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreeSection(FList[I]);
  FList.Clear;
end;

procedure THeaderStrings.Delete(Index: Integer);
begin
  FreeSection(FList[Index]);
  FList.Delete(Index);
  if FHeader <> nil then FHeader.Invalidate;
end;

function THeaderStrings.Get(Index: Integer): string;
begin
  Result := PHeaderSection(FList[Index])^.Title;
end;

function THeaderStrings.GetCount: Integer;
begin
  Result := FList.Count;
end;

function THeaderStrings.GetObject(Index: Integer): TObject;
begin
  Result := PHeaderSection(FList[Index])^.FObject;
end;

procedure THeaderStrings.Insert(Index: Integer; const S: string);
var
  Width: Integer;
begin
  if FHeader <> nil then
    Width := FHeader.Canvas.TextWidth(S) + 8
  else Width := DefaultSectionWidth;
  FList.Expand.Insert(Index, NewSection(S, Width, nil));
  if FHeader <> nil then FHeader.Invalidate;
end;

procedure THeaderStrings.Put(Index: Integer; const S: string);
var
  P: PHeaderSection;
  Width: Integer;
begin
  P := FList[Index];
  if FHeader <> nil then
    Width := FHeader.Canvas.TextWidth(S) + 8
  else Width := DefaultSectionWidth;
  FList[Index] := NewSection(S, Width, P^.FObject);
  FreeSection(P);
  if FHeader <> nil then FHeader.Invalidate;
end;

procedure THeaderStrings.PutObject(Index: Integer; AObject: TObject);
begin
  PHeaderSection(FList[Index])^.FObject := AObject;
  if FHeader <> nil then FHeader.Invalidate;
end;

procedure THeaderStrings.ReadData(Reader: TReader);
var
  Width, I: Integer;
  Str: string;
begin
  Reader.ReadListBegin;
  Clear;
  while not Reader.EndOfList do
  begin
    Str := Reader.ReadString;
    Width := DefaultSectionWidth;
    I := 1;
    if Str[1] = #0 then
    begin
      repeat
        Inc(I);
      until (I > Length(Str)) or (Str[I] = #0);
      Width := StrToIntDef(Copy(Str, 2, I - 2), DefaultSectionWidth);
      System.Delete(Str, 1, I);
    end;
    FList.Expand.Insert(FList.Count, NewSection(Str, Width, nil));
  end;
  Reader.ReadListEnd;
end;

procedure THeaderStrings.SetUpdateState(Updating: Boolean);
begin
  if FHeader <> nil then
  begin
    SendMessage(FHeader.Handle, WM_SETREDRAW, Ord(not Updating), 0);
    if not Updating then FHeader.Refresh;
  end;
end;

procedure THeaderStrings.WriteData(Writer: TWriter);
var
  I: Integer;
  HeaderSection: PHeaderSection;
begin
  Writer.WriteListBegin;
  for I := 0 to Count - 1 do
  begin
    HeaderSection := FList[I];
    with HeaderSection^ do
      Writer.WriteString(Format(#0'%d'#0'%s', [Width, Title]));
  end;
  Writer.WriteListEnd;
end;

{ THeader }

constructor THeader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csDesignInteractive, csOpaque];
  Width := 250;
  Height := 25;
  FSections := THeaderStrings.Create;
  THeaderStrings(FSections).FHeader := Self;
  FAllowResize := True;
  FBorderStyle := bsSingle;
end;

destructor THeader.Destroy;
begin
  FreeSections;
  FSections.Free;
  inherited Destroy;
end;

procedure THeader.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or BorderStyles[FBorderStyle];
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure THeader.Paint;
var
  I, Y, W: Integer;
  S: string;
  R: TRect;
begin
  with Canvas do
  begin
    Font := Self.Font;
    Brush.Color := clBtnFace;
    I := 0;
    Y := (ClientHeight - Canvas.TextHeight('T')) div 2;
    R := Rect(0, 0, 0, ClientHeight);
    W := 0;
    S := '';
    repeat
      if I < FSections.Count then
      begin
        with PHeaderSection(THeaderStrings(FSections).FList[I])^ do
        begin
          W := Width;
          S := Title;
        end;
        Inc(I);
      end;
      R.Left := R.Right;
      Inc(R.Right, W);
      if (ClientWidth - R.Right < 2) or (I = FSections.Count) then
        R.Right := ClientWidth;
      TextRect(Rect(R.Left + 1, R.Top + 1, R.Right - 1, R.Bottom - 1),
        R.Left + 3, Y, S);
      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_TOPLEFT);
      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_BOTTOMRight);
    until R.Right = ClientWidth;
  end;
end;

procedure THeader.FreeSections;
begin
  if FSections <> nil then
    FSections.Clear;
end;

procedure THeader.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure THeader.SetSections(Strings: TStrings);
begin
  FSections.Assign(Strings);
end;

function THeader.GetWidth(X: Integer): Integer;
var
  I, W: Integer;
begin
  if X = FSections.Count - 1 then
  begin
    W := 0;
    for I := 0 to X - 1 do
      Inc(W, PHeaderSection(THeaderStrings(FSections).FList[I])^.Width);
    Result := ClientWidth - W;
  end
  else if (X >= 0) and (X < FSections.Count) then
    Result := PHeaderSection(THeaderStrings(FSections).FList[X])^.Width
  else
    Result := 0;
end;

procedure THeader.SetWidth(X: Integer; Value: Integer);
begin
  if X < 0 then Exit;
  PHeaderSection(THeaderStrings(FSections).FList[X])^.Width := Value;
  Invalidate;
end;

procedure THeader.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  FHitTest := SmallPointToPoint(Msg.Pos);
end;

procedure THeader.WMSetCursor(var Msg: TWMSetCursor);
var
  Cur: HCURSOR;
  I: Integer;
  X: Integer;
begin
  Cur := 0;
  FResizeSection := 0;
  FHitTest := ScreenToClient(FHitTest);
  X := 2;
  with Msg do
    if HitTest = HTCLIENT then
      for I := 0 to FSections.Count - 2 do  { don't count last section }
      begin
        Inc(X, PHeaderSection(THeaderStrings(FSections).FList[I])^.Width);
        FMouseOffset := X - (FHitTest.X + 2);
        if Abs(FMouseOffset) < 4 then
        begin
          Cur := LoadCursor(0, IDC_SIZEWE);
          FResizeSection := I;
          Break;
        end;
      end;
  FCanResize := (FAllowResize or (csDesigning in ComponentState)) and (Cur <> 0);
  if FCanResize then SetCursor(Cur)
  else inherited;
end;

procedure THeader.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if ((csDesigning in ComponentState) and (Button = mbRight)) or (Button = mbLeft) then
    if FCanResize then SetCapture(Handle);
end;

procedure THeader.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  AbsPos: Integer;
  MinPos: Integer;
  MaxPos: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if (GetCapture = Handle) and FCanResize then
  begin
    { absolute position of this item }
    AbsPos := 2;
    for I := 0 to FResizeSection do
      Inc(AbsPos, PHeaderSection(THeaderStrings(FSections).FList[I])^.Width);

    if FResizeSection > 0 then MinPos := AbsPos -
      PHeaderSection(THeaderStrings(FSections).FList[FResizeSection])^.Width + 2
    else MinPos := 2;
    MaxPos := ClientWidth - 2;
    if X < MinPos then X := MinPos;
    if X > MaxPos then X := MaxPos;

    Dec(PHeaderSection(THeaderStrings(FSections).FList[FResizeSection])^.Width,
      (AbsPos - X - 2) - FMouseOffset);
    Sizing(FResizeSection,
      PHeaderSection(THeaderStrings(FSections).FList[FResizeSection])^.Width);
    Refresh;
  end;
end;

procedure THeader.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if FCanResize then
  begin
    ReleaseCapture;
    Sized(FResizeSection,
      PHeaderSection(THeaderStrings(FSections).FList[FResizeSection])^.Width);
    FCanResize := False;
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure THeader.Sizing(ASection, AWidth: Integer);
begin
  if Assigned(FOnSizing) then FOnSizing(Self, ASection, AWidth);
end;

procedure THeader.Sized(ASection, AWidth: Integer);
var
  Form: TCustomForm;
begin
  if Assigned(FOnSized) then FOnSized(Self, ASection, AWidth);
  if csDesigning in ComponentState then
  begin
    Form := GetParentForm(Self);
    if Form <> nil then
      Form.Designer.Modified;
  end;
end;

procedure THeader.WMSize(var Msg: TWMSize);
begin
  inherited;
  Invalidate;
end;

{ TGroupButton }

type
  TGroupButton = class(TRadioButton)
  private
    FInClick: Boolean;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
  public
    constructor InternalCreate(RadioGroup: TCustomRadioGroup);
    destructor Destroy; override;
  end;

constructor TGroupButton.InternalCreate(RadioGroup: TCustomRadioGroup);
begin
  inherited Create(RadioGroup);
  RadioGroup.FButtons.Add(Self);
  Visible := False;
  Enabled := RadioGroup.Enabled;
  ParentShowHint := False;
  OnClick := RadioGroup.ButtonClick;
  Parent := RadioGroup;
end;

destructor TGroupButton.Destroy;
begin
  TCustomRadioGroup(Owner).FButtons.Remove(Self);
  inherited Destroy;
end;

procedure TGroupButton.CNCommand(var Message: TWMCommand);
begin
  if not FInClick then
  begin
    FInClick := True;
    try
      if ((Message.NotifyCode = BN_CLICKED) or
        (Message.NotifyCode = BN_DOUBLECLICKED)) and
        TCustomRadioGroup(Parent).CanModify then
        inherited;
    except
      Application.HandleException(Self);
    end;
    FInClick := False;
  end;
end;

procedure TGroupButton.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  TCustomRadioGroup(Parent).KeyPress(Key);
  if (Key = #8) or (Key = ' ') then
  begin
    if not TCustomRadioGroup(Parent).CanModify then Key := #0;
  end;
end;

procedure TGroupButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  TCustomRadioGroup(Parent).KeyDown(Key, Shift);
end;

{ TCustomRadioGroup }

constructor TCustomRadioGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csSetCaption, csDoubleClicks];
  FButtons := TList.Create;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := ItemsChange;
  FItemIndex := -1;
  FColumns := 1;
end;

destructor TCustomRadioGroup.Destroy;
begin
  SetButtonCount(0);
  TStringList(FItems).OnChange := nil;
  FItems.Free;
  FButtons.Free;
  inherited Destroy;
end;

procedure TCustomRadioGroup.FlipChildren(AllLevels: Boolean); 
begin
  { The radio buttons are flipped using BiDiMode }
end;

procedure TCustomRadioGroup.ArrangeButtons;
var
  ButtonsPerCol, ButtonWidth, ButtonHeight, TopMargin, I: Integer;
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
  DeferHandle: THandle;
  ALeft: Integer;
begin
  if (FButtons.Count <> 0) and not FReading then
  begin
    DC := GetDC(0);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
    ReleaseDC(0, DC);
    ButtonsPerCol := (FButtons.Count + FColumns - 1) div FColumns;
    ButtonWidth := (Width - 10) div FColumns;
    I := Height - Metrics.tmHeight - 5;
    ButtonHeight := I div ButtonsPerCol;
    TopMargin := Metrics.tmHeight + 1 + (I mod ButtonsPerCol) div 2;
    DeferHandle := BeginDeferWindowPos(FButtons.Count);
    try
      for I := 0 to FButtons.Count - 1 do
        with TGroupButton(FButtons[I]) do
        begin
          BiDiMode := Self.BiDiMode;
          ALeft := (I div ButtonsPerCol) * ButtonWidth + 8;
          if UseRightToLeftAlignment then
            ALeft := Self.ClientWidth - ALeft - ButtonWidth;
          DeferHandle := DeferWindowPos(DeferHandle, Handle, 0,
            ALeft,
            (I mod ButtonsPerCol) * ButtonHeight + TopMargin,
            ButtonWidth, ButtonHeight,
            SWP_NOZORDER or SWP_NOACTIVATE);
          Visible := True;
        end;
    finally
      EndDeferWindowPos(DeferHandle);
    end;
  end;
end;

procedure TCustomRadioGroup.ButtonClick(Sender: TObject);
begin
  if not FUpdating then
  begin
    FItemIndex := FButtons.IndexOf(Sender);
    Changed;
    Click;
  end;
end;

procedure TCustomRadioGroup.ItemsChange(Sender: TObject);
begin
  if not FReading then
  begin
    if FItemIndex >= FItems.Count then FItemIndex := FItems.Count - 1;
    UpdateButtons;
  end;
end;

procedure TCustomRadioGroup.ReadState(Reader: TReader);
begin
  FReading := True;
  inherited ReadState(Reader);
  FReading := False;
  UpdateButtons;
end;

procedure TCustomRadioGroup.SetButtonCount(Value: Integer);
begin
  while FButtons.Count < Value do TGroupButton.InternalCreate(Self);
  while FButtons.Count > Value do TGroupButton(FButtons.Last).Free;
end;

procedure TCustomRadioGroup.SetColumns(Value: Integer);
begin
  if Value < 1 then Value := 1;
  if Value > 16 then Value := 16;
  if FColumns <> Value then
  begin
    FColumns := Value;
    ArrangeButtons;
    Invalidate;
  end;
end;

procedure TCustomRadioGroup.SetItemIndex(Value: Integer);
begin
  if FReading then FItemIndex := Value else
  begin
    if Value < -1 then Value := -1;
    if Value >= FButtons.Count then Value := FButtons.Count - 1;
    if FItemIndex <> Value then
    begin
      if FItemIndex >= 0 then
        TGroupButton(FButtons[FItemIndex]).Checked := False;
      FItemIndex := Value;
      if FItemIndex >= 0 then
        TGroupButton(FButtons[FItemIndex]).Checked := True;
    end;
  end;
end;

procedure TCustomRadioGroup.SetItems(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TCustomRadioGroup.UpdateButtons;
var
  I: Integer;
begin
  SetButtonCount(FItems.Count);
  for I := 0 to FButtons.Count - 1 do
    TGroupButton(FButtons[I]).Caption := FItems[I];
  if FItemIndex >= 0 then
  begin
    FUpdating := True;
    TGroupButton(FButtons[FItemIndex]).Checked := True;
    FUpdating := False;
  end;
  ArrangeButtons;
  Invalidate;
end;

procedure TCustomRadioGroup.CMEnabledChanged(var Message: TMessage);
var
  I: Integer;
begin
  inherited;
  for I := 0 to FButtons.Count - 1 do
    TGroupButton(FButtons[I]).Enabled := Enabled;
end;

procedure TCustomRadioGroup.CMFontChanged(var Message: TMessage);
begin
  inherited;
  ArrangeButtons;
end;

procedure TCustomRadioGroup.WMSize(var Message: TWMSize);
begin
  inherited;
  ArrangeButtons;
end;

function TCustomRadioGroup.CanModify: Boolean;
begin
  Result := True;
end;

procedure TCustomRadioGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

{ TSplitter }

type
  TWinControlAccess = class(TWinControl);

constructor TSplitter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alLeft;
  Width := 3;
  Cursor := crHSplit;
  FMinSize := 30;
  FResizeStyle := rsPattern;
  FOldSize := -1;
end;

destructor TSplitter.Destroy;
begin
  FBrush.Free;
  inherited Destroy;
end;

procedure TSplitter.AllocateLineDC;
begin
  FLineDC := GetDCEx(Parent.Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS
    or DCX_LOCKWINDOWUPDATE);
  if ResizeStyle = rsPattern then
  begin
    if FBrush = nil then
    begin
      FBrush := TBrush.Create;
      FBrush.Bitmap := AllocPatternBitmap(clBlack, clWhite);
    end;
    FPrevBrush := SelectObject(FLineDC, FBrush.Handle);
  end;
end;

procedure TSplitter.DrawLine;
var
  P: TPoint;
begin
  FLineVisible := not FLineVisible;
  P := Point(Left, Top);
  if Align in [alLeft, alRight] then
    P.X := Left + FSplit else
    P.Y := Top + FSplit;
  with P do PatBlt(FLineDC, X, Y, Width, Height, PATINVERT);
end;

procedure TSplitter.ReleaseLineDC;
begin
  if FPrevBrush <> 0 then
    SelectObject(FLineDC, FPrevBrush);
  ReleaseDC(Parent.Handle, FLineDC);
  if FBrush <> nil then
  begin
    FBrush.Free;
    FBrush := nil;
  end;
end;

function TSplitter.FindControl: TControl;
var
  P: TPoint;
  I: Integer;
  R: TRect;
begin
  Result := nil;
  P := Point(Left, Top);
  case Align of
    alLeft: Dec(P.X);
    alRight: Inc(P.X, Width);
    alTop: Dec(P.Y);
    alBottom: Inc(P.Y, Height);
  else
    Exit;
  end;
  for I := 0 to Parent.ControlCount - 1 do
  begin
    Result := Parent.Controls[I];
    if Result.Visible and Result.Enabled then
    begin
      R := Result.BoundsRect;
      if (R.Right - R.Left) = 0 then
        Dec(R.Left);
      if (R.Bottom - R.Top) = 0 then
        Dec(R.Top);
      if PtInRect(R, P) then Exit;
    end;
  end;
  Result := nil;
end;

procedure TSplitter.RequestAlign;
begin
  inherited RequestAlign;
  if (Cursor <> crVSplit) and (Cursor <> crHSplit) then Exit;
  if Align in [alBottom, alTop] then
    Cursor := crVSplit
  else
    Cursor := crHSplit;
end;

procedure TSplitter.Paint;
var
  FrameBrush: HBRUSH;
  R: TRect;
begin
  R := ClientRect;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);
  if Beveled then
  begin
    if Align in [alLeft, alRight] then
      InflateRect(R, -1, 2) else
      InflateRect(R, 2, -1);
    OffsetRect(R, 1, 1);
    FrameBrush := CreateSolidBrush(ColorToRGB(clBtnHighlight));
    FrameRect(Canvas.Handle, R, FrameBrush);
    DeleteObject(FrameBrush);
    OffsetRect(R, -2, -2);
    FrameBrush := CreateSolidBrush(ColorToRGB(clBtnShadow));
    FrameRect(Canvas.Handle, R, FrameBrush);
    DeleteObject(FrameBrush);
  end;
  if Assigned(FOnPaint) then FOnPaint(Self);
end;

function TSplitter.DoCanResize(var NewSize: Integer): Boolean;
begin
  Result := CanResize(NewSize);
  if Result and (NewSize <= MinSize) then
    NewSize := 0;
end;

function TSplitter.CanResize(var NewSize: Integer): Boolean;
begin
  Result := True;
  if Assigned(FOnCanResize) then FOnCanResize(Self, NewSize, Result);
end;

procedure TSplitter.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  I: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    FControl := FindControl;
    FDownPos := Point(X, Y);
    if Assigned(FControl) then
    begin
      if Align in [alLeft, alRight] then
      begin
        FMaxSize := Parent.ClientWidth - FMinSize;
        for I := 0 to Parent.ControlCount - 1 do
          with Parent.Controls[I] do
            if Align in [alLeft, alRight] then Dec(FMaxSize, Width);
        Inc(FMaxSize, FControl.Width);
      end
      else
      begin
        FMaxSize := Parent.ClientHeight - FMinSize;
        for I := 0 to Parent.ControlCount - 1 do
          with Parent.Controls[I] do
            if Align in [alTop, alBottom] then Dec(FMaxSize, Height);
        Inc(FMaxSize, FControl.Height);
      end;
      UpdateSize(X, Y);
      AllocateLineDC;
      with ValidParentForm(Self) do
        if ActiveControl <> nil then
        begin
          FActiveControl := ActiveControl;
          FOldKeyDown := TWinControlAccess(FActiveControl).OnKeyDown;
          TWinControlAccess(FActiveControl).OnKeyDown := FocusKeyDown;
        end;
      if ResizeStyle in [rsLine, rsPattern] then DrawLine;
    end;
  end;
end;

procedure TSplitter.UpdateControlSize;
begin
  if FNewSize <> FOldSize then
  begin
    case Align of
      alLeft: FControl.Width := FNewSize;
      alTop: FControl.Height := FNewSize;
      alRight:
        begin
          Parent.DisableAlign;
          try
            FControl.Left := FControl.Left + (FControl.Width - FNewSize);
            FControl.Width := FNewSize;
          finally
            Parent.EnableAlign;
          end;
        end;
      alBottom:
        begin
          Parent.DisableAlign;
          try
            FControl.Top := FControl.Top + (FControl.Height - FNewSize);
            FControl.Height := FNewSize;
          finally
            Parent.EnableAlign;
          end;
        end;
    end;
    Update;
    if Assigned(FOnMoved) then FOnMoved(Self);
    FOldSize := FNewSize;
  end;
end;

procedure TSplitter.CalcSplitSize(X, Y: Integer; var NewSize, Split: Integer);
var
  S: Integer;
begin
  if Align in [alLeft, alRight] then
    Split := X - FDownPos.X
  else
    Split := Y - FDownPos.Y;
  S := 0;
  case Align of
    alLeft: S := FControl.Width + Split;
    alRight: S := FControl.Width - Split;
    alTop: S := FControl.Height + Split;
    alBottom: S := FControl.Height - Split;
  end;
  NewSize := S;
  if S < FMinSize then
    NewSize := FMinSize
  else if S > FMaxSize then
    NewSize := FMaxSize;
  if S <> NewSize then
  begin
    if Align in [alRight, alBottom] then
      S := S - NewSize else
      S := NewSize - S;
    Inc(Split, S);
  end;
end;

procedure TSplitter.UpdateSize(X, Y: Integer);
begin
  CalcSplitSize(X, Y, FNewSize, FSplit);
end;

procedure TSplitter.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewSize, Split: Integer;
begin
  inherited;
  if (ssLeft in Shift) and Assigned(FControl) then
  begin
    CalcSplitSize(X, Y, NewSize, Split);
    if DoCanResize(NewSize) then
    begin
      if ResizeStyle in [rsLine, rsPattern] then DrawLine;
      FNewSize := NewSize;
      FSplit := Split;
      if ResizeStyle = rsUpdate then UpdateControlSize;
      if ResizeStyle in [rsLine, rsPattern] then DrawLine;
    end;
  end;
end;

procedure TSplitter.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Assigned(FControl) then
  begin
    if ResizeStyle in [rsLine, rsPattern] then DrawLine;
    UpdateControlSize;
    StopSizing;
  end;
end;

procedure TSplitter.FocusKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    StopSizing
  else if Assigned(FOldKeyDown) then
    FOldKeyDown(Sender, Key, Shift);
end;

procedure TSplitter.SetBeveled(Value: Boolean);
begin
  FBeveled := Value;
  Repaint;
end;

procedure TSplitter.StopSizing;
begin
  if Assigned(FControl) then
  begin
    if FLineVisible then DrawLine;
    FControl := nil;
    ReleaseLineDC;
    if Assigned(FActiveControl) then
    begin
      TWinControlAccess(FActiveControl).OnKeyDown := FOldKeyDown;
      FActiveControl := nil;
    end;
  end;
  if Assigned(FOnMoved) then
    FOnMoved(Self);
end;

{ TCustomControlBar }

type
  PDockPos = ^TDockPos;
  TDockPos = record
    Control: TControl;
    Insets: TRect;
    Visible: Boolean;
    Break: Boolean;
    Pos: TPoint;
    Width: Integer;

    Height: Integer;
    RowCount: Integer;
    TempRow: Integer;
    Parent: PDockPos;
    SubItem: PDockPos;

    TempBreak: Boolean;
    TempPos: TPoint;
    TempWidth: Integer;
  end;

function CreateDockPos(AControl: TControl; Break: Boolean; Visible: Boolean;
  const APos: TPoint; AWidth, AHeight: Integer; Parent: PDockPos;
  const Insets: TRect; RowCount: Integer): PDockPos;
begin
  GetMem(Result, SizeOf(TDockPos));
  Result.Control := AControl;
  Result.Insets := Insets;
  Result.Visible := Visible;
  Result.Break := Break;
  Result.Pos := APos;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.RowCount := RowCount;
  Result.TempRow := 1;
  Result.TempBreak := Break;
  Result.TempPos := APos;
  Result.TempWidth := AWidth;
  Result.Parent := Parent;
  Result.SubItem := nil;
end;

procedure FreeDockPos(Items: TList; DockPos: PDockPos);
var
  Tmp: PDockPos;
begin
  { Remove all subitems }
  while DockPos <> nil do
  begin
    Tmp := DockPos;
    Items.Remove(DockPos);
    DockPos := DockPos.SubItem;
    FreeMem(Tmp, SizeOf(TDockPos));
  end;
end;

procedure AdjustControlRect(var ARect: TRect; const Insets: TRect);
begin
  with Insets do
  begin
    Dec(ARect.Left, Left);
    Dec(ARect.Top, Top);
    Inc(ARect.Right, Right);
    Inc(ARect.Bottom, Bottom);
  end;
end;

constructor TCustomControlBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csDoubleClicks, csOpaque];
  Width := 100;
  Height := 50;
  FAutoDrag := True;
  FItems := TList.Create;
  FPicture := TPicture.Create;
  FPicture.OnChange := PictureChanged;
  FRowSize := 26;
  FRowSnap := True;
  BevelKind := bkTile;
  DoubleBuffered :=True;
  DockSite := True;
end;

destructor TCustomControlBar.Destroy;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I] <> nil then
      FreeMem(PDockPos(FItems[I]), SizeOf(TDockPos));
  FItems.Free;
  FPicture.Free;
  inherited Destroy;
end;

procedure TCustomControlBar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do
    style := style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TCustomControlBar.AlignControls(AControl: TControl; var ARect: TRect);
var
  I, J, X: Integer;
  DockPos: PDockPos;
  TotalSize, RowSize, RowSpace, Shift: Integer;
  RowHeight, PrevRowHeight: Integer;
  MoveBy: Integer;
  Pos: TPoint;
  CX: Integer;
  Control: TControl;
  UseTemp: Boolean;

  Row: Integer;
  RowCount: Integer;
  FirstIndex, LastIndex: Integer;
  InsertingControl: Boolean;
  Dirty: Boolean;
  R: TRect;

  TempRowSize, TempRowSpace: Integer;
  AdjustX: Integer;
  DockRect: TRect;
  PreferredSize: Integer;

  TmpDockPos: PDockPos;
  Redo: PDockPos;
  RedoCount: Integer;
  SkipRedo: Boolean;

  function ShouldRedo(DockPos: PDockPos; const Pos: TPoint; Width: Integer): Boolean;
  begin
    { Determine whether this subitem has changed and will affect its
      parent(s). }
    if (DockPos^.Parent <> nil) and ((Pos.X <> DockPos^.Parent^.TempPos.X) or
      (Width <> DockPos^.Parent^.TempWidth)) then
    begin
      DockPos := DockPos^.Parent;
      { Update parents and re-perform align logic }
      repeat
        DockPos^.TempPos.X := Pos.X;
        DockPos^.TempWidth := Width;
        Redo := DockPos;
        DockPos := DockPos^.Parent;
      until DockPos = nil;
      Result := True;
    end
    else
      Result := False;
  end;

begin
  if FAligning then Exit;
  FAligning := True;
  try
    { Update items }
    InsertingControl := UpdateItems(AControl);
    if FItems.Count = 0 then Exit;
    RowCount := 0;
    FirstIndex := 0;
    LastIndex := FItems.Count - 1;

    { Find number of rows }
    for I := FirstIndex to LastIndex do
    begin
      DockPos := PDockPos(FItems[I]);
      { First item can't have Break set! }
      DockPos^.TempBreak := DockPos^.Break;
      if DockPos^.Break then
        Inc(RowCount);
    end;

    Redo := nil;
    SkipRedo := False;
    RedoCount := 2;
    repeat

      if Redo <> nil then
      begin
        SkipRedo := True;
        Dec(RedoCount);
      end;
      if RedoCount = 0 then Exit;

      RowHeight := 0;
      PrevRowHeight := 0;
      Row := 1;

      while Row <= RowCount do
      begin

        if Row = 1 then
          RowHeight := 0;

        { Find first and last index for current row }
        if Row = 1 then
          FirstIndex := 0
        else
          FirstIndex := LastIndex + 1;
        LastIndex := FItems.Count - 1;
        for I := FirstIndex to LastIndex - 1 do
        begin
          DockPos := PDockPos(FItems[I + 1]);
          { First item can't have Break set }
          if DockPos^.Break or DockPos^.TempBreak then
          begin
            LastIndex := I;
            Break;
          end;
        end;

        { Set temp values for all controls }
        TotalSize := ARect.Right - ARect.Left;
        RowSize := 0;
        RowSpace := 0;

        for I := FirstIndex to LastIndex do
        begin
          DockPos := PDockPos(FItems[I]);

          if DockPos^.Break or DockPos^.TempBreak then
          begin
            RowSize := 0;
            RowSpace := 0;
            UseTemp := False;
            if UseTemp then
              DockPos^.TempPos.Y := RowHeight else
              DockPos^.Pos.Y := RowHeight;
            PrevRowHeight := RowHeight;
          end
          else UseTemp := False;

          Control := DockPos^.Control;
          if (csDesigning in ComponentState) or Control.Visible then
          begin
            { If control was moved/resized, update our info }
            if DockPos^.Parent = nil then
            begin
              PreferredSize := DockPos^.Width;
              Dec(PreferredSize, DockPos^.Insets.Left + DockPos^.Insets.Right);
              GetControlInfo(Control, DockPos^.Insets, PreferredSize,
                DockPos^.RowCount);
              DockPos^.Width := PreferredSize + DockPos^.Insets.Left +
                DockPos^.Insets.Right;
              if not InsertingControl and (DockPos^.Parent = nil) and
                (AControl = DockPos^.Control) then
              begin
                if UseTemp then
                begin
                  DockPos^.TempPos := Point(AControl.Left - ARect.Left -
                    DockPos^.Insets.Left, AControl.Top - ARect.Top - DockPos^.Insets.Top);
                  DockPos^.TempWidth := AControl.Width + DockPos^.Insets.Left +
                    DockPos^.Insets.Right;
                  DockRect := Bounds(DockPos^.TempPos.X, DockPos^.TempPos.Y,
                    DockPos^.TempWidth, DockPos^.Height);
                end
                else
                  DockRect := Bounds(DockPos^.Pos.X, DockPos^.Pos.Y,
                    DockPos^.Width, DockPos^.Height);
              end;

              { Let user adjust sizes }
              if DockPos = Redo then
                DockRect := Bounds(DockPos^.TempPos.X, DockPos^.TempPos.Y,
                  DockPos^.TempWidth, DockPos^.Height)
              else
                DockRect := Bounds(DockPos^.Pos.X, DockPos^.Pos.Y,
                  DockPos^.Width, DockPos^.Height);
              DoBandMove(Control, DockRect);
              DockPos^.TempWidth := DockRect.Right - DockRect.Left;
            end
            else
            begin
              { Use parent's position }
              with DockPos^.Parent^ do
              begin
                DockPos^.Pos := Pos;
                DockPos^.TempPos := TempPos;
                Inc(DockPos^.Pos.Y, Height);
                Inc(DockPos^.TempPos.Y, Height);
                DockPos^.Width := Width;
                DockPos^.TempWidth := TempWidth;
                DockRect := Bounds(DockPos^.TempPos.X, DockPos^.TempPos.Y,
                  DockPos^.TempWidth, DockPos^.Height);
              end;
            end;

            if DockPos = Redo then
            begin
              with DockPos^ do
              begin
                TempPos.X := DockRect.Left;
                TempPos.Y := DockRect.Top;
                TempWidth := DockRect.Right - DockRect.Left;
                Redo := nil;
                SkipRedo := False;
              end;
            end
            else
            begin
              with DockPos^ do
              begin
                Pos.X := DockRect.Left;
                Pos.Y := DockRect.Top;
              end;
            end;

            if UseTemp then
            begin
              Pos := DockPos^.TempPos;
              CX := DockPos^.TempWidth;
            end
            else
            begin
              Pos := DockRect.TopLeft;
              CX := DockRect.Right - DockRect.Left;
            end;

            { Make sure Pos is within bounds }
            if Pos.X < RowSize then
            begin
              { If a control is being resized/moved then adjust any controls to
                its left }
              if (RowSpace > 0) then
              begin
                TempRowSize := Pos.X;
                AdjustX := Pos.X;
                TempRowSpace := RowSpace;
                for J := I - 1 downto FirstIndex do
                begin
                  with PDockPos(FItems[J])^ do
                  begin
                    if (csDesigning in ComponentState) or Control.Visible then
                    begin
                      if TempPos.X + TempWidth > TempRowSize then
                      begin
                        X := TempPos.X + TempWidth - TempRowSize;
                        { Calculate adjusted rowspace }
                        if J < I - 1 then
                          Dec(TempRowSpace, AdjustX - (TempPos.X + TempWidth));
                        if X > TempRowSpace then
                          X := TempRowSpace;
                        AdjustX := TempPos.X;
                        Dec(TempPos.X, X);
                        Dec(TempRowSize, TempWidth);

                        TmpDockPos := PDockPos(FItems[J]);
                        if ShouldRedo(TmpDockPos, TmpDockPos^.TempPos,
                          TmpDockPos^.TempWidth) then
                          System.Break;

                        TmpDockPos := SubItem;
                        while TmpDockPos <> nil do
                          with TmpDockPos^ do
                          begin
                            Pos := PDockPos(FItems[J])^.Pos;
                            TempPos := PDockPos(FItems[J])^.TempPos;
                            Inc(Pos.Y, Parent.Height);
                            Inc(TempPos.Y, Parent.Height);
                            Width := PDockPos(FItems[J])^.Width;
                            TempWidth := PDockPos(FItems[J])^.TempWidth;
                            TmpDockPos := SubItem;
                          end;

                      end
                      else System.Break;
                    end;
                  end;
                end;
                AdjustX := RowSize - Pos.X;
                if AdjustX > RowSpace then
                  AdjustX := RowSpace;
                Dec(RowSpace, AdjustX);
                Dec(RowSize, AdjustX);
              end;
              Pos.X := RowSize;
            end;

            if (Redo <> nil) and not SkipRedo then Break;

            if Pos.Y <> PrevRowHeight then
              Pos.Y := PrevRowHeight;

            if Pos.Y + DockPos^.Height > RowHeight then
              RowHeight := Pos.Y + DockPos^.Height;

            Inc(RowSpace, Pos.X - RowSize);
            Inc(RowSize, Pos.X - RowSize + CX);

            if DockPos^.Parent = nil then
            begin
              DockPos^.TempPos := Pos;
              DockPos^.TempWidth := CX;
            end
            else
            begin
              if ShouldRedo(DockPos, Pos, CX) then
                System.Break
              else if not DockPos^.Break and (DockPos^.TempPos.X < Pos.X) then
              begin
                DockPos^.TempPos := Pos;
                DockPos^.TempWidth := CX;
              end;
            end;

            TmpDockPos := DockPos^.SubItem;
            while TmpDockPos <> nil do
              with TmpDockPos^ do
              begin
                Pos := DockPos^.Pos;
                TempPos := DockPos^.TempPos;
                Inc(Pos.Y, Parent.Height);
                Inc(TempPos.Y, Parent.Height);
                Width := DockPos^.Width;
                TempWidth := DockPos^.TempWidth;
                TmpDockPos := SubItem;
              end;
          end;
        end;

        if (Redo <> nil) and not SkipRedo then Break;

        { Determine whether controls on this row can fit }
        Shift := TotalSize - RowSize;
        if Shift < 0 then
        begin
          TotalSize := ARect.Right - ARect.Left;
          { Try to move all controls to fill space }
          AdjustX := RowSize;
          TempRowSpace := RowSpace;
          for I := LastIndex downto FirstIndex do
          begin
            DockPos := PDockPos(FItems[I]);
            Control := DockPos^.Control;
            if (csDesigning in ComponentState) or Control.Visible then
            begin
              if (DockPos^.TempPos.X + DockPos^.TempWidth) > TotalSize then
              begin
                MoveBy := (DockPos^.TempPos.X + DockPos^.TempWidth) - TotalSize;
                if I < LastIndex then
                  Dec(TempRowSpace, AdjustX - (DockPos^.TempPos.X +
                    DockPos^.TempWidth));
                if MoveBy <= TempRowSpace then
                  Shift := MoveBy else
                  Shift := TempRowSpace;
                if Shift <= TempRowSpace then
                begin
                  AdjustX := DockPos^.TempPos.X;
                  Dec(DockPos^.TempPos.X, Shift);
                  Dec(TotalSize, DockPos^.TempWidth);

                  if ShouldRedo(DockPos, DockPos^.TempPos, DockPos^.TempWidth) then
                    Break;

                  TmpDockPos := DockPos^.SubItem;
                  while TmpDockPos <> nil do
                    with TmpDockPos^ do
                    begin
                      TempPos := DockPos^.TempPos;
                      Inc(TempPos.Y, Parent.Height);
                      TmpDockPos := SubItem;
                    end;
                end
                else
                  Break;
              end;
            end;
          end;

          if (Redo <> nil) and not SkipRedo then Break;

          { Try to minimize all controls to fill space }
          if TotalSize < 0 then
          begin
            TotalSize := ARect.Right - ARect.Left;
            for I := LastIndex downto FirstIndex do
            begin
              DockPos := PDockPos(FItems[I]);
              Control := DockPos^.Control;
              if (csDesigning in ComponentState) or Control.Visible then
              begin
                if DockPos^.TempPos.X + DockPos^.TempWidth > TotalSize then
                begin
                  { Try to minimize control, move if it can't be resized }
                  DockPos^.TempWidth := DockPos^.TempWidth -
                    ((DockPos^.TempPos.X + DockPos^.TempWidth) - TotalSize);
                  if DockPos^.TempWidth < Control.Constraints.MinWidth +
                    DockPos^.Insets.Left + DockPos^.Insets.Right then
                    DockPos^.TempWidth := Control.Constraints.MinWidth +
                      DockPos^.Insets.Left + DockPos^.Insets.Right;
                  { Move control }
                  if DockPos^.TempPos.X + DockPos^.TempWidth > TotalSize then
                  begin
                    Dec(DockPos^.TempPos.X, (DockPos^.TempPos.X +
                      DockPos^.TempWidth) - TotalSize);
                    if DockPos^.TempPos.X < ARect.Left then
                      DockPos^.TempPos.X := ARect.Left;
                  end;

                  if ShouldRedo(DockPos, DockPos^.TempPos, DockPos^.TempWidth) then
                    Break;

                  TmpDockPos := DockPos^.SubItem;
                  while TmpDockPos <> nil do
                    with TmpDockPos^ do
                    begin
                      Pos := DockPos^.Pos;
                      TempPos := DockPos^.TempPos;
                      Inc(TempPos.Y, Parent.Height);
                      TempWidth := DockPos^.TempWidth;
                      TmpDockPos := SubItem;
                    end;
                end;
                Dec(TotalSize, DockPos^.TempWidth);
              end;
            end;
          end;

          if (Redo <> nil) and not SkipRedo then Break;

          { Done with first pass at minimizing. If we're still cramped for
            space then wrap last control if there are more than 1 controls on
            this row. }
          if (TotalSize < 0) and (FirstIndex <> LastIndex) then
          begin
            DockPos := PDockPos(FItems[LastIndex]);
            DockPos^.TempPos.X := 0;
            DockPos^.TempWidth := DockPos^.Width;
            DockPos^.TempBreak := True;
            Inc(RowCount);

            if ShouldRedo(DockPos, DockPos^.TempPos, DockPos^.TempWidth) then
              Break;

            TmpDockPos := DockPos^.SubItem;
            while TmpDockPos <> nil do
              with TmpDockPos^ do
              begin
                TempPos := DockPos^.TempPos;
                Inc(TempPos.Y, Parent.Height);
                TempWidth := DockPos^.TempWidth;
                TmpDockPos := SubItem;
              end;
          end
          else
            Inc(Row);
        end
        else
          Inc(Row);

      end;

    until Redo = nil;

    { Now position controls }
    for I := 0 to FItems.Count - 1 do
    begin
      DockPos := PDockPos(FItems[I]);
      with DockPos^ do
        if (Parent = nil) and ((csDesigning in ComponentState) or
          Control.Visible) then
        begin
          with Insets do
            R := Rect(Left + TempPos.X, Top + TempPos.Y,
              TempPos.X + TempWidth - Right,
              TempPos.Y + DockPos^.Height - Bottom);
          TmpDockPos := SubItem;
          while TmpDockPos <> nil do
          begin
            Inc(R.Bottom, TmpDockPos^.Height);
            TmpDockPos := TmpDockPos^.SubItem;
          end;
          if (R.Left <> Control.Left) or (R.Top <> Control.Top) or
            (R.Right - R.Left <> Control.Width) or
            (R.Bottom - R.Top <> Control.Height) then
          begin
            Dirty := True;
            Control.BoundsRect := R;
          end;
        end;
    end;
    if Dirty or (AControl <> nil) then Repaint;
    { Apply any constraints }
    AdjustSize;
  finally
    FAligning := False;
  end;
end;

const
  DefaultInsets: TRect = (Left: 11; Top: 2; Right: 2; Bottom: 2);

function TCustomControlBar.UpdateItems(AControl: TControl): Boolean;
var
  I, J, Tmp, RepositionIndex: Integer;
  PrevBreak: Boolean;
  Control: TControl;
  Exists: Boolean;
  AddControls: TList;
  DockRect, R: TRect;
  Dirty: Boolean;
  IsVisible: Boolean;
  DockPos, TmpDockPos1, TmpDockPos2: PDockPos;
  BreakList: TList;
  IndexList: TList;
  SizeList: TList;
  ChangedPriorBreak: Boolean;

  procedure AddControl(List: TList; Control: TControl);
  var
     I: Integer;
  begin
    for I := 0 to List.Count - 1 do
      with TControl(List[I]) do
        if (Control.Top < Top) or (Control.Top = Top) and
          (Control.Left < Left) then
        begin
          List.Insert(I, Control);
          Exit;
        end;
    List.Add(Control);
  end;

begin
  Result := False;
  ChangedPriorBreak := False;
  AddControls := TList.Create;
  BreakList := TList.Create;
  IndexList := TList.Create;
  SizeList := TList.Create;
  try
    AddControls.Capacity := ControlCount;
    RepositionIndex := -1;
    Dirty := False;
    for I := 0 to ControlCount - 1 do
    begin
      Control := Controls[I];
      IsVisible := (csDesigning in ComponentState) or Control.Visible;
      Exists := False;
      for J := 0 to FItems.Count - 1 do
        if (PDockPos(FItems[J])^.Parent = nil) and
          (PDockPos(FItems[J])^.Control = Control) then
        begin
          Dirty := Dirty or PDockPos(FItems[J])^.Visible <> IsVisible;
          PDockPos(FItems[J])^.Visible := IsVisible;
          Exists := True;
          Break;
        end;
      if Exists and (Control = AControl) then
      begin
        RepositionIndex := J;
        DockPos := PDockPos(FItems[J]);
        with DockPos^ do
        begin
          SizeList.Add(TObject(Insets.Top + Insets.Bottom));
          if FDragControl <> nil then
            DockRect := Rect(Pos.X + Insets.Left, Pos.Y + Insets.Top,
              Pos.X + Width - Insets.Right, Pos.Y + Insets.Top + Control.Height)
          else
            DockRect := Control.BoundsRect;
          PrevBreak := Break;
        end;
        { If we were starting a row, then update any items to the right to
          begin starting the row. }
        if PrevBreak and (J + 1 < FItems.Count) then
        begin
          TmpDockPos1 := FItems[J + 1];
          if not TmpDockPos1.Break then
          begin
            TmpDockPos1.Break := True;
            TmpDockPos1.TempBreak := True;
            ChangedPriorBreak := True;
          end;
        end;

        { Remember the state of this item and its subitems }
        BreakList.Add(TObject(Ord(PrevBreak)));
        IndexList.Add(TObject(J));
        TmpDockPos1 := DockPos^.SubItem;
        while TmpDockPos1 <> nil do
        begin
          Tmp := FItems.IndexOf(TmpDockPos1);
          BreakList.Add(TObject(Ord(TmpDockPos1.Break)));
          IndexList.Add(TObject(Tmp));
          with TmpDockPos1^ do
            SizeList.Add(TObject(Insets.Top + Insets.Bottom));
          { If we were starting a row, then update any items to the right to
            begin starting the row. }
          if TmpDockPos1.Break then
          begin
            if Tmp + 1 < FItems.Count then
            begin
              TmpDockPos2 := FItems[Tmp + 1];
              if not TmpDockPos2.Break then
                TmpDockPos2.Break := True;
            end;
          end;
          TmpDockPos1 := TmpDockPos1^.SubItem;
        end;

        { Remove this item from consideration in DockControl. It's as if we are
          adding a new control. }
        FreeDockPos(FItems, DockPos);
      end
      else if not Exists then
      begin
        if Control = AControl then Result := True;
        AddControl(AddControls, Control);
      end;
    end;
    for I := 0 to AddControls.Count - 1 do
    begin
      R := TControl(AddControls[I]).BoundsRect;
      DockControl(TControl(AddControls[I]), R, BreakList, IndexList, SizeList,
        nil, ChangedPriorBreak, DefaultInsets, -1, -1, False);
    end;
    if RepositionIndex >= 0 then
      DockControl(AControl, DockRect, BreakList, IndexList, SizeList, nil,
        ChangedPriorBreak, DefaultInsets, -1, -1, True);
    if Dirty then Invalidate;
  finally
    AddControls.Free;
    BreakList.Free;
    IndexList.Free;
    SizeList.Free;
  end;
end;

procedure TCustomControlBar.SetRowSize(Value: TRowSize);
begin
  if Value <> RowSize then
  begin
    FRowSize := Value;
  end;
end;

procedure TCustomControlBar.SetRowSnap(Value: Boolean);
begin
  if Value <> RowSnap then
  begin
    FRowSnap := Value;
  end;
end;

procedure TCustomControlBar.FlipChildren(AllLevels: Boolean);
begin
  { Do not flip controls }
end;

procedure TCustomControlBar.StickControls;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    if FItems[I] <> nil then
      with PDockPos(FItems[I])^ do
      begin
        if Parent <> nil then
          Pos := Point(Parent^.Pos.X, Parent^.Pos.Y + Parent.Height)
        else
        begin
          Pos := Control.BoundsRect.TopLeft;
          Dec(Pos.X, Insets.Left);
          Dec(Pos.Y, Insets.Top);
        end;
        Width := Control.Width + Insets.Left + Insets.Right;
        Break := TempBreak;
      end;
end;

function TCustomControlBar.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
var
  I: Integer;
  DockPos: PDockPos;
begin
  Result := True;
  if HandleAllocated and (not (csDesigning in ComponentState) or
    (ControlCount > 0)) then
  begin
    if Align in [alLeft, alRight] then
    begin
      NewWidth := 0;
      for I := 0 to FItems.Count - 1 do
      begin
        DockPos := PDockPos(FItems[I]);
        with DockPos^ do
        begin
          if (Parent = nil) and ((csDesigning in ComponentState) or Control.Visible) then
          begin
            if TempPos.X + Control.Width + Insets.Left + Insets.Right > NewWidth then
              NewWidth := TempPos.X + Control.Width + Insets.Left + Insets.Right;
          end;
        end;
      end;
      Inc(NewWidth, Width - ClientWidth);
    end
    else
    begin
      NewHeight := 0;
      for I := 0 to FItems.Count - 1 do
      begin
        DockPos := PDockPos(FItems[I]);
        with DockPos^ do
        begin
          if (Parent = nil) and ((csDesigning in ComponentState) or Control.Visible) then
          begin
            if TempPos.Y + Control.Height + Insets.Top + Insets.Bottom > NewHeight then
              NewHeight := TempPos.Y + Control.Height + Insets.Top + Insets.Bottom;
          end;
        end;
      end;
      Inc(NewHeight, Height - ClientHeight);
    end;
  end;
end;

procedure TCustomControlBar.DockControl(AControl: TControl;
  const ARect: TRect; BreakList, IndexList, SizeList: TList; Parent: Pointer;
  ChangedPriorBreak: Boolean; Insets: TRect; PreferredSize, RowCount: Integer;
  Existing: Boolean);
var
  I, InsPos, Size, TotalSize: Integer;
  DockPos: PDockPos;
  MidPoint: TPoint;
  NewControlRect, ControlRect: TRect;
  IsVisible, DockBreak: Boolean;
  PrevBreak: Boolean;
  PrevIndex: Integer;
  NewHeight, PrevInsetHeight: Integer;
  NewLine: Boolean;

  procedure AddItem;
  var
    DockPos: PDockPos;
    H: Integer;
  begin
    if InsPos = 0 then DockBreak := True;
    if (PrevIndex <> InsPos) or ChangedPriorBreak then
    begin
      if DockBreak and (InsPos < FItems.Count) then
      begin
        DockPos := FItems[InsPos];
        if not NewLine and DockPos^.Break then
        begin
          DockPos^.Break := False;
          DockPos^.TempBreak := False;
        end;
      end;
    end;
    if RowSnap then
      H := RowSize else
      H := NewControlRect.Bottom - NewControlRect.Top;
    DockPos := CreateDockPos(AControl, DockBreak, IsVisible,
      NewControlRect.TopLeft, NewControlRect.Right - NewControlRect.Left,
      H, Parent, Insets, RowCount);
    if Parent <> nil then
      PDockPos(Parent).SubItem := DockPos;
    FItems.Insert(InsPos, DockPos);
    { If we're adding an item that spans more than one row, we need to add
      pseudo items which are linked to this item. }
    if RowCount > 1 then
    begin
      Dec(RowCount);
      Inc(NewControlRect.Top, RowSize);
      DockControl(AControl, NewControlRect, BreakList, IndexList, SizeList,
        DockPos, False, Insets, PreferredSize, RowCount, False);
    end;
  end;

begin
  FDockingControl := AControl;
  if BreakList.Count > 0 then
  begin
    PrevBreak := Boolean(BreakList[0]);
    BreakList.Delete(0);
  end
  else
    PrevBreak := False;
  if IndexList.Count > 0 then
  begin
    PrevIndex := Integer(IndexList[0]);
    IndexList.Delete(0);
  end
  else
    PrevIndex := -1;
  if SizeList.Count > 0 then
  begin
    PrevInsetHeight := Integer(SizeList[0]);
    SizeList.Delete(0);
  end
  else
    PrevInsetHeight := -1;

  InsPos := 0;
  Size := -MaxInt;
  TotalSize := -MaxInt;

  NewControlRect := ARect;
  if RowCount < 0 then
    with AControl do
    begin
      PreferredSize := ARect.Right - ARect.Left;
      Insets := DefaultInsets;
      if PrevInsetHeight < 0 then
        PrevInsetHeight := Insets.Top + Insets.Bottom;
      { Try to fit control into row size }
      NewHeight := PrevInsetHeight + NewControlRect.Bottom - NewControlRect.Top;
      if RowSnap then
      begin
        RowCount := NewHeight div RowSize;
        if RowCount = 0 then
          Inc(RowCount);
        if Existing and (NewHeight > RowSize * RowCount) then
          Inc(RowCount);
      end
      else
        RowCount := 1;
      GetControlInfo(AControl, Insets, PreferredSize, RowCount);
      if RowCount = 0 then RowCount := 1;
      if RowSnap and Existing and (NewHeight > RowSize * RowCount) then
        RowCount := NewHeight div RowSize + 1;
      NewControlRect.Right := NewControlRect.Left + PreferredSize;
      AdjustControlRect(NewControlRect, Insets);
      if RowSnap then
        NewControlRect.Bottom := NewControlRect.Top + RowSize * RowCount;
    end;

  IsVisible := (csDesigning in Self.ComponentState) or AControl.Visible;
  MidPoint.Y := NewControlRect.Top + RowSize div 2;
  DockBreak := False;
  NewLine := False;

  for I := 0 to FItems.Count - 1 do
  begin
    DockPos := PDockPos(FItems[I]);
    ControlRect := Rect(DockPos^.Pos.X, DockPos^.Pos.Y, DockPos^.Pos.X +
      DockPos^.Width, DockPos^.Pos.Y + DockPos^.Height );
    with ControlRect do
    begin
      if Bottom - Top > Size then
        Size := Bottom - Top;
      if Bottom > TotalSize then
        TotalSize := Bottom;

      if (NewControlRect.Left > Left) and (MidPoint.Y > Top) then
      begin
        DockBreak := False;
        InsPos := I + 1;
      end;
    end;

    if (I = FItems.Count - 1) or ((I + 1 = PrevIndex) and (PrevBreak)) or
      PDockPos(FItems[I + 1])^.Break then
    begin
      if MidPoint.Y < TotalSize then
      begin
        NewLine := (InsPos = 0) and (MidPoint.Y < ControlRect.Top);
        AddItem;
        Exit;
      end
      else
      begin
        DockBreak := (ControlRect.Left > NewControlRect.Left) or
          ((DockPos^.SubItem = nil));
        InsPos := I + 1;
      end;
      if RowSnap then
        Size := RowSize else
        Size := 0;
    end;
  end;
  AddItem;
end;

procedure TCustomControlBar.UnDockControl(AControl: TControl);
var
  I: Integer;
  DockPos: PDockPos;
begin
  FDockingControl := AControl;
  for I := 0 to FItems.Count - 1 do
  begin
    DockPos := PDockPos(FItems[I]);
    if DockPos^.Control = AControl then
    begin
      if DockPos^.Break and (I < FItems.Count - 1) then
        PDockPos(FItems[I + 1])^.Break := True;
      FreeDockPos(FItems, DockPos);
      Break;
    end;
  end;
end;

procedure TCustomControlBar.GetControlInfo(AControl: TControl; var Insets: TRect;
  var PreferredSize, RowCount: Integer);
begin
  if RowCount = 0 then RowCount := 1;
  if Assigned(FOnBandInfo) then FOnBandInfo(Self, AControl, Insets,
    PreferredSize, RowCount);
end;

procedure TCustomControlBar.PaintControlFrame(Canvas: TCanvas; AControl: TControl;
  var ARect: TRect);
const
  Offset = 3;
var
  R: TRect;
  Options: TBandPaintOptions;

  procedure DrawGrabber;
  begin
    with Canvas, R do
    begin
      Pen.Color := clBtnHighlight;
      MoveTo(R.Left+2, R.Top);
      LineTo(R.Left, R.Top);
      LineTo(R.Left, R.Bottom+1);
      Pen.Color := clBtnShadow;
      MoveTo(R.Right, R.Top);
      LineTo(R.Right, R.Bottom);
      LineTo(R.Left, R.Bottom);
    end;
  end;

begin
  Options := [bpoGrabber, bpoFrame];
  DoBandPaint(AControl, Canvas, ARect, Options);
  with Canvas do
  begin
    if bpoFrame in Options then
      DrawEdge(Handle, ARect, BDR_RAISEDINNER, BF_RECT);
    if bpoGrabber in Options then
    begin
      R := Rect(ARect.Left + Offset, ARect.Top + 2, ARect.Left + Offset + 2,
        ARect.Bottom - 3);
      DrawGrabber;
      OffsetRect(R, 3, 0);
      DrawGrabber;
    end;
  end;
end;

procedure TCustomControlBar.Paint;
var
  I, J: Integer;
  DockPos: PDockPos;
  Control: TControl;
  R: TRect;
  Save: Boolean;
begin
  with Canvas do
  begin
    Brush.Color := Color;
    R := ClientRect;
    if Picture.Graphic <> nil then
    begin
      Save := FDrawing;
      FDrawing := True;
      try
        { Tile image across client area }
        for I := 0 to (R.Right - R.Left) div Picture.Width do
          for J := 0 to (R.Bottom - R.Top) div Picture.Height do
            Draw(I * Picture.Width, J * Picture.Height, Picture.Graphic);
      finally
        FDrawing := Save;
      end
    end
    else
      FillRect(R);
    if Assigned(FOnPaint) then FOnPaint(Self);
    { Draw grabbers and frames for each control }
    for I := 0 to FItems.Count - 1 do
    begin
      DockPos := PDockPos(FItems[I]);
      Control := DockPos^.Control;
      if (DockPos^.Parent = nil) and ((csDesigning in ComponentState) or
        Control.Visible) then
      begin
        R := Control.BoundsRect;
        with DockPos^.Insets do
        begin
          Dec(R.Left, Left);
          Dec(R.Top, Top);
          Inc(R.Right, Right);
          Inc(R.Bottom, Bottom);
        end;
        PaintControlFrame(Canvas, Control, R);
      end;
    end;
  end;
end;

function TCustomControlBar.HitTest(X, Y: Integer): TControl;
var
  DockPos: PDockPos;
begin
  DockPos := HitTest2(X, Y);
  if DockPos <> nil then
    Result := DockPos^.Control else
    Result := nil;
end;

function TCustomControlBar.HitTest2(X, Y: Integer): Pointer;
var
  I: Integer;
  R: TRect;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Result := PDockPos(FItems[I]);
    with PDockPos(Result)^ do
      if (Parent = nil) and ((csDesigning in ComponentState) or
        Control.Visible) then
      begin
        R := Control.BoundsRect;
        with Insets do
        begin
          Dec(R.Left, Left);
          Dec(R.Top, Top);
          Inc(R.Right, Right);
          Inc(R.Bottom, Bottom);
        end;
        if PtInRect(R, Point(X, Y)) then Exit;
      end;
  end;
  Result := nil;
end;

procedure TCustomControlBar.DoAlignControl(AControl: TControl);
var
  Rect: TRect;
begin
  if not HandleAllocated or (csDestroying in ComponentState) then Exit;
  DisableAlign;
  try
    Rect := GetClientRect;
    AlignControls(AControl, Rect);
  finally
    ControlState := ControlState - [csAlignmentNeeded];
    EnableAlign;
  end;
end;

procedure TCustomControlBar.CNKeyDown(var Message: TWMKeyDown);
var
  DockPos: PDockPos;
  P: TPoint;
begin
  inherited;
  if (Message.CharCode = VK_CONTROL) and not (csDesigning in ComponentState) and
    AutoDrag and (FDragControl <> nil) then
  begin
    DockPos := FindPos(FDragControl);
    if (DockPos <> nil) and (DockPos^.Control <> nil) then
      with DockPos^ do
      begin
        GetCursorPos(P);
        MapWindowPoints(0, Handle, P, 1);
        DragControl(Control, P.X, P.Y, True);
        Exit;
      end;
  end;
end;

procedure TCustomControlBar.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  DockPos: PDockPos;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if MouseCapture then
  begin
    if FDragControl <> nil then
      DockPos := FindPos(FDragControl) else
      DockPos := HitTest2(X, Y);
    if (DockPos <> nil) and (not (ssDouble in Shift) or not AutoDrag or
      (csDesigning in ComponentState) or
      not DragControl(DockPos^.Control, X, Y, False)) then
    begin
      FDragControl := DockPos^.Control;
      if FDockingControl = FDragControl then
        FDockingControl := nil
      else
        StickControls;
      FDragOffset := Point(DockPos^.TempPos.X - X, DockPos^.TempPos.Y - Y);
    end;
  end;
end;

procedure TCustomControlBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DockPos: PDockPos;
  Delta: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if MouseCapture then
  begin
    if FDragControl <> nil then
    begin
      DockPos := FindPos(FDragControl);
      if DockPos <> nil then
        with DockPos^ do
        begin
          Pos.X := X + FDragOffset.X;
          Pos.Y := Y + FDragOffset.Y;
          TempPos := Pos;
          TempWidth := Control.Width + Insets.Left + Insets.Right;
          { Detect a float operation }
          if not (csDesigning in ComponentState) and AutoDrag then
          begin
            Delta := Control.Height;
            if (Pos.X < -Delta) or (Pos.Y < -Delta) or
              (Pos.X > ClientWidth + Delta) or (Pos.Y > ClientHeight + Delta) then
            begin
              if DragControl(Control, X, Y, True) then Exit;
            end;
          end;
          DoAlignControl(Control);
        end;
    end;
  end;
end;

procedure TCustomControlBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  Control: TControl;
begin
  if FDragControl <> nil then
  begin
    Control := FDragControl;
    FDragControl := nil;
    if FDockingControl = Control then
      FDockingControl := nil
    else
      StickControls;
  end;
  inherited MouseUp(Button, Shift, X, Y);
end;

function TCustomControlBar.FindPos(AControl: TControl): Pointer;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
    with PDockPos(FItems[I])^ do
    begin
      if (Parent = nil) and (Control = AControl) then
      begin
        Result := FItems[I];
        Exit;
      end;
    end;
  Result := nil;
end;

function TCustomControlBar.DragControl(AControl: TControl; X, Y: Integer;
  KeepCapture: Boolean): Boolean;
begin
  Result := True;
  if (AControl <> nil) and Assigned(FOnBandDrag) then
    FOnBandDrag(Self, AControl, Result);
  if Result then
    AControl.BeginDrag(True);
end;

procedure TCustomControlBar.DockOver(Source: TDragDockObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  inherited DockOver(Source, X, Y, State, Accept);
  if Accept and (State = dsDragEnter) and Source.Control.Floating then
  begin
	FDragControl := Source.Control;
	FDragControl.EndDrag(True);
	PostMessage(Handle, WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(FDragControl.Left,
	  FDragControl.Top));
  end;
end;

procedure TCustomControlBar.GetSiteInfo(Client: TControl; var InfluenceRect: TRect;
  MousePos: TPoint; var CanDock: Boolean);
begin
  inherited GetSiteInfo(Client, InfluenceRect, MousePos, CanDock);
  CanDock := CanDock and not FFloating;
end;

procedure TCustomControlBar.DoBandMove(Control: TControl; var ARect: TRect);
begin
  if Assigned(FOnBandMove) then FOnBandMove(Self, Control, ARect);
end;

procedure TCustomControlBar.DoBandPaint(Control: TControl; Canvas: TCanvas;
  var ARect: TRect; var Options: TBandPaintOptions);
begin
  if Assigned(FOnBandPaint) then FOnBandPaint(Self, Control, Canvas, ARect, Options);
end;

function TCustomControlBar.GetPalette: HPALETTE;
begin
  Result := 0;
  if FPicture.Graphic <> nil then
    Result := FPicture.Graphic.Palette;
end;

procedure TCustomControlBar.SetPicture(const Value: TPicture);
begin
  FPicture.Assign(Value);
end;

function TCustomControlBar.DoPaletteChange: Boolean;
var
  ParentForm: TCustomForm;
  Tmp: TGraphic;
begin
  Result := False;
  Tmp := Picture.Graphic;
  if Visible and (not (csLoading in ComponentState)) and (Tmp <> nil) and
    (Tmp.PaletteModified) then
  begin
    if (Tmp.Palette = 0) then
      Tmp.PaletteModified := False
    else
    begin
      ParentForm := GetParentForm(Self);
      if Assigned(ParentForm) and ParentForm.Active and Parentform.HandleAllocated then
      begin
        if FDrawing then
          ParentForm.Perform(WM_QUERYNEWPALETTE, 0, 0)
        else
          PostMessage(ParentForm.Handle, WM_QUERYNEWPALETTE, 0, 0);
        Result := True;
        Tmp.PaletteModified := False;
      end;
    end;
  end;
end;

procedure TCustomControlBar.PictureChanged(Sender: TObject);
begin
  if Picture.Graphic <> nil then
    if DoPaletteChange and FDrawing then Update;
  if not FDrawing then Invalidate;
end;

procedure TCustomControlBar.CMControlListChange(var Message: TCMControlListChange);
begin
  inherited;
  if not Message.Inserting then
  begin
    if Message.Control = FDragControl then
      FDragControl := nil;
    UnDockControl(Message.Control);
    if AutoSize then AdjustSize;
    Invalidate;
  end;
end;

procedure TCustomControlBar.CMDesignHitTest(var Message: TCMDesignHitTest);
begin
  Message.Result := Ord((FDragControl <> nil) or
    (HitTest(Message.XPos, Message.YPos) <> nil));
end;

end.
