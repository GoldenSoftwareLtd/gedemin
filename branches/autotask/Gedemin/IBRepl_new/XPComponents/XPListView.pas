unit XPListView;

interface
uses ComCtrls, Messages, Windows, XPEdit, Graphics, Controls, Classes, XPButton,
  Forms;

type
  TXPListView = class(TCustomListView)
  private
    FDisabledBorderWidth: Integer;
    FEnabledBorderWidth: Integer;
    FDisabledBorderColor: TColor;
    FEnabledBorderColor: TColor;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure SetDisabledBorderColor(const Value: TColor);
    procedure SetDisabledBorderWidth(const Value: Integer);
    procedure SetEnabledBorderColor(const Value: TColor);
    procedure SetEnabledBorderWidth(const Value: Integer);
  protected
  public
    DrawState: TOwnerDrawState;
    constructor Create(AOwner: TComponent); override;
  published
    property EnabledBorderColor: TColor read FEnabledBorderColor write SetEnabledBorderColor default BORDER_ENABLED;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default BORDER_DISABLED;
    property EnabledBorderWidth: Integer read FEnabledBorderWidth write SetEnabledBorderWidth default ENABLED_WIDTH;
    property DisabledBorderWidth: Integer read FDisabledBorderWidth write SetDisabledBorderWidth default DISABLED_WIDTH;
    property Action;
    property Align;
    property AllocBy;
    property Anchors;
    property BiDiMode;
    property Checkboxes;
    property Color;
    property Columns;
    property ColumnClick;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property FlatScrollBars;
    property FullDrag;
    property GridLines;
    property HideSelection;
    property HotTrack;
    property HotTrackStyles;
    property HoverTime;
    property IconOptions;
    property Items;
    property LargeImages;
    property MultiSelect;
    property OwnerData;
    property OwnerDraw;
    property ReadOnly default False;
    property RowSelect;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowColumnHeaders;
    property ShowWorkAreas;
    property ShowHint;
    property SmallImages;
    property SortType;
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property ViewStyle;
    property Visible;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnAdvancedCustomDrawSubItem;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnColumnClick;
    property OnColumnDragged;
    property OnColumnRightClick;
    property OnCompare;
    property OnContextPopup;
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnCustomDrawSubItem;
    property OnData;
    property OnDataFind;
    property OnDataHint;
    property OnDataStateChange;
    property OnDblClick;
    property OnDeletion;
    property OnDrawItem;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSubItemImage;
    property OnDragDrop;
    property OnDragOver;
    property OnInfoTip;
    property OnInsert;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnSelectItem;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;  
implementation

{ TXPListView }
procedure Register;
begin
  RegisterComponents('XPComponents', [TXPListView]);
end;

procedure TXPListView.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  Include(DrawState, odHotLight);
  Invalidate;
end;

procedure TXPListView.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  Exclude(DrawState, odHotLight);
  Invalidate;
end;

constructor TXPListView.Create(AOwner: TComponent);
begin
  inherited;
  BorderStyle := bsNone;
  BorderWidth := 0;
  FEnabledBorderColor := BORDER_ENABLED;
  FDisabledBorderColor := BORDER_DISABLED;
  FEnabledBorderWidth := ENABLED_WIDTH;
  FDisabledBorderWidth := DISABLED_WIDTH;
end;

procedure TXPListView.SetDisabledBorderColor(const Value: TColor);
begin
  FDisabledBorderColor := Value;
end;

procedure TXPListView.SetDisabledBorderWidth(const Value: Integer);
begin
  FDisabledBorderWidth := Value;
end;

procedure TXPListView.SetEnabledBorderColor(const Value: TColor);
begin
  FEnabledBorderColor := Value;
end;

procedure TXPListView.SetEnabledBorderWidth(const Value: Integer);
begin
  FEnabledBorderWidth := Value;
end;

procedure TXPListView.WMPaint(var Message: TWMPaint);
var
  R: TRect;
  Canvas: TControlCanvas;
begin
  inherited;
  Canvas := TControlCanvas.Create;
  Canvas.Control:=Self;
  try
    GetWindowRect(Handle, R);
    OffsetRect(R, -R.Left, -R.Top);
    if Enabled then
      Frame3D(Canvas, R, EnabledBorderColor, EnabledBorderColor, EnabledBorderWidth)
    else
      Frame3D(Canvas, R, DisabledBorderColor, DisabledBorderColor, DisabledBorderWidth);

    if not Focused then
    begin
      if (odHotLight in DrawState) then
        Frame3D(Canvas, R, XP_BTN_BDR_MOUSE_END, XP_BTN_BDR_MOUSE_END, 1)
      else
        Frame3D(Canvas, R, Color, Color, 1);
    end else
      Frame3D(Canvas, R, XP_BTN_BDR_NOMOUSE_START, XP_BTN_BDR_NOMOUSE_START, 1);
  finally
    Canvas.Free;
  end;
end;

end.
