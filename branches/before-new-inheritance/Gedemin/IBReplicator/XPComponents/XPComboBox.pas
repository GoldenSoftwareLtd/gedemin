unit XPComboBox;

interface
uses StdCtrls, XPEdit, Messages, Types, Controls, Windows, Graphics,
  Classes, XPButton;
type
  TXPComboBox = class(TCustomComboBox)
  private
    FDisabledBorderWidth: Integer;
    FEnabledBorderWidth: Integer;
    FDisabledBorderColor: TColor;
    FEnabledBorderColor: TColor;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure SetDisabledBorderColor(const Value: TColor);
    procedure SetDisabledBorderWidth(const Value: Integer);
    procedure SetEnabledBorderColor(const Value: TColor);
    procedure SetEnabledBorderWidth(const Value: Integer);
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
  protected
    procedure HookMouseEnter; dynamic;
    procedure HookMouseLeave; dynamic;
  public
    DrawState: TOwnerDrawState;
    constructor Create(AOwner: TComponent); override;
  published
    property EnabledBorderColor: TColor read FEnabledBorderColor write SetEnabledBorderColor default BORDER_ENABLED;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default BORDER_DISABLED;
    property EnabledBorderWidth: Integer read FEnabledBorderWidth write SetEnabledBorderWidth default ENABLED_WIDTH;
    property DisabledBorderWidth: Integer read FDisabledBorderWidth write SetDisabledBorderWidth default DISABLED_WIDTH;
    property AutoComplete default True;
    property AutoDropDown default False;
//    property AutoCloseUp default False;
    property Style; {Must be published before Items}
    property Anchors;
    property BiDiMode;
    property CharCase;
    property Color;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ItemHeight;
    property ItemIndex default -1;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Sorted;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnCloseUp;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnDropDown;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnSelect;
    property OnStartDock;
    property OnStartDrag;
    property Items; { Must be published after OnMeasureItem }
  end;

procedure Register;  
implementation

procedure Register;
begin
  RegisterComponents('XPComponents', [TXPComboBox]);
end;

{ TXPComboBox }

procedure TXPComboBox.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  HookMouseEnter;
end;

procedure TXPComboBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  HookMouseLeave;
end;

procedure TXPComboBox.CNCommand(var Message: TWMCommand);
begin
  inherited;
  case Message.NotifyCode of
    CBN_SETFOCUS:
    begin
      Invalidate;
    end;
    CBN_KILLFOCUS:
    begin
      Invalidate;
    end;
  end;
end;

constructor TXPComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FEnabledBorderColor := BORDER_ENABLED;
  FDisabledBorderColor := BORDER_DISABLED;
  FEnabledBorderWidth := ENABLED_WIDTH;
  FDisabledBorderWidth := DISABLED_WIDTH;
end;

procedure TXPComboBox.HookMouseEnter;
begin
  Include(DrawState, odHotLight);
  Invalidate;
end;

procedure TXPComboBox.HookMouseLeave;
begin
  Exclude(DrawState, odHotLight);
  Invalidate;
end;

procedure TXPComboBox.SetDisabledBorderColor(const Value: TColor);
begin
  if FDisabledBorderColor <> Value then
  begin
    FDisabledBorderColor := Value;
    Invalidate;
  end;
end;

procedure TXPComboBox.SetDisabledBorderWidth(const Value: Integer);
begin
  if FDisabledBorderWidth <> Value then
  begin
    FDisabledBorderWidth := Value;
    Invalidate;
  end;
end;

procedure TXPComboBox.SetEnabledBorderColor(const Value: TColor);
begin
  if Value <> FEnabledBorderColor then
  begin
    FEnabledBorderColor := Value;
    Invalidate;
  end;
end;

procedure TXPComboBox.SetEnabledBorderWidth(const Value: Integer);
begin
  if FEnabledBorderWidth <> Value then
  begin
    FEnabledBorderWidth := Value;
    Invalidate;
  end;
end;

procedure TXPComboBox.WMPaint(var Message: TWMPaint);
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

    if not FIsFocused then
    begin
      if (odHotLight in DrawState) then
        Frame3D(Canvas, R, XP_BTN_BDR_MOUSE_END, XP_BTN_BDR_MOUSE_END, 1)
      else
        Frame3D(Canvas, R, Color, Color, 1);
    end else
      Frame3D(Canvas, R, XP_BTN_BDR_NOMOUSE_START, XP_BTN_BDR_NOMOUSE_START, 1);

    R.Left := R.Right - (R.Bottom - R.Top);
    if Style <> csSimple then
    begin
      if DroppedDown then
        DrawFrameControl(Canvas.Handle, R, DFC_SCROLL, DFCS_FLAT or DFCS_SCROLLCOMBOBOX)
      else
        DrawFrameControl(Canvas.Handle, R, DFC_SCROLL, DFCS_FLAT or DFCS_SCROLLCOMBOBOX);
    end;
  finally
    Canvas.Free;
  end;
end;
end.
