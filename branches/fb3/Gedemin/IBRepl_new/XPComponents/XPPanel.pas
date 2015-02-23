unit XPPanel;

interface

uses Windows, Messages, Forms, Graphics, Controls, Classes;

type
  TCaptionAlignment = (caLeft, caRight, caCenter);

const
  XP_BORDER_COLOR = $00B8D8D7;
  XP_BORDER_WIDTH = 1;
  XP_CAPTION_COLOR = $00D05300;
  XP_CAPTION_OFFSET = 10;
  XP_CORNERS_OFFSET = 10;
  XP_PANEL_CAPTION_ALIGNMENT = caCenter;
  MAX_BORDER_WIDTH = 10;
  MIN_BORDER_WIDTH = 1;
  MAX_CAPTION_OFFSET = 30;
  MIN_CAPTION_OFFSET = 1;
  MAX_CORNERS_OFFSET = 30;
  MIN_CORNERS_OFFSET = 1;
  Alignments: array[TCaptionAlignment] of Longint =
    (DT_LEFT, DT_RIGHT, DT_CENTER);

type
  TXPPanel = class(TCustomControl)
  private
    FBorderColor: TColor;
    FBorderWidth: Integer;
    FCaptionAlignment: TCaptionAlignment;
    FCaptionOffset: Integer;
    FCornersOffset: Integer;
    FMouseEnter: TNotifyEvent;
    FMouseLeave: TNotifyEvent;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure MouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure MouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    procedure SetBorderColor(NewBorderColor: TColor);
    procedure SetBorderWidth(NewBorderWidth: Integer);
    procedure SetCaptionAlignment(NewCaptionAlignment: TCaptionAlignment);
    procedure SetCaptionOffset(NewCaptionOffset: Integer);
    procedure SetCornersOffset(NewCornersOffset: Integer);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property BorderColor: TColor read FBorderColor write SetBorderColor default XP_BORDER_COLOR;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default XP_BORDER_WIDTH;
    property Caption;
    property CaptionAlignment: TCaptionAlignment read FCaptionAlignment write SetCaptionAlignment default XP_PANEL_CAPTION_ALIGNMENT;
    property CaptionOffset: Integer read FCaptionOffset write SetCaptionOffset default XP_CAPTION_OFFSET;
    property Color;
    property CornersOffset: Integer read FCornersOffset write SetCornersOffset default XP_CORNERS_OFFSET;
    property Font;
    property Hint;
    property Height default 41;
    property Enabled;
    property PopupMenu;
    property ShowHint;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnEnter;
    property OnExit;
    property OnMouseEnter: TNotifyEvent read FMouseEnter write FMouseEnter;
    property OnMouseLeave: TNotifyEvent read FMouseLeave write FMouseLeave;
    property Width default 185;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('XPComponents', [TXPPanel]);
end;

constructor TXPPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csDoubleClicks, csReplicatable];
  Height := 41;
  Width := 185;
  FBorderWidth := XP_BORDER_WIDTH;
  FBorderColor := XP_BORDER_COLOR;
  FCornersOffset := XP_CORNERS_OFFSET;
  FCaptionAlignment := XP_PANEL_CAPTION_ALIGNMENT;
  FCaptionOffset := XP_CAPTION_OFFSET;
  Font.Color := XP_CAPTION_COLOR;
end;

procedure TXPPanel.CMDialogChar(var Message: TCMDialogChar);
begin
with Message do
  if IsAccel(CharCode, Caption) then
    Result := 1
else
  inherited;
end;

procedure TXPPanel.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TXPPanel.MouseEnter(var Message: TMessage);
begin
  if Assigned(FMouseEnter) then
    FMouseEnter(Self);
end;

procedure TXPPanel.MouseLeave(var Message: TMessage);
begin
  if Assigned(FMouseLeave) then
    FMouseLeave(Self);
end;

procedure TXPPanel.WMSize(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TXPPanel.SetBorderColor(NewBorderColor: TColor);
begin
  FBorderColor := NewBorderColor;
  Invalidate;
end;

procedure TXPPanel.SetBorderWidth(NewBorderWidth: Integer);
begin
  if NewBorderWidth > MAX_BORDER_WIDTH then
    begin
      FBorderWidth := MAX_BORDER_WIDTH;
      Invalidate;
      Exit;
    end;
  if NewBorderWidth < MIN_BORDER_WIDTH then
    begin
      FBorderWidth := MIN_BORDER_WIDTH;
      Invalidate;
      Exit;
    end;
  FBorderWidth := NewBorderWidth;
  Invalidate;
end;

procedure TXPPanel.SetCaptionAlignment(NewCaptionAlignment: TCaptionAlignment);
begin
  FCaptionAlignment := NewCaptionAlignment;
  Invalidate;
end;

procedure TXPPanel.SetCaptionOffset(NewCaptionOffset: Integer);
begin
  if NewCaptionOffset > MAX_CAPTION_OFFSET then
    begin
      FCaptionOffset := MAX_CAPTION_OFFSET;
      Invalidate;
      Exit;
    end;
  if NewCaptionOffset < MIN_CAPTION_OFFSET then
    begin
      FCaptionOffset := MIN_CAPTION_OFFSET;
      Invalidate;
      Exit;
    end;
  FCaptionOffset := NewCaptionOffset;
  Invalidate;
end;

procedure TXPPanel.SetCornersOffset(NewCornersOffset: Integer);
begin
  if NewCornersOffset > MAX_CORNERS_OFFSET then
    begin
      FCornersOffset := MAX_CORNERS_OFFSET;
      Invalidate;
      Exit;
    end;
  if NewCornersOffset < MIN_CORNERS_OFFSET then
    begin
      FCornersOffset := MIN_CORNERS_OFFSET;
      Invalidate;
      Exit;
    end;
  FCornersOffset := NewCornersOffset;
  Invalidate;
end;

procedure TXPPanel.Paint;
var Rector: TRect;
    Flag: LongInt;
begin
  Rector := Rect(BorderWidth+CaptionOffset, BorderWidth+CaptionOffset,
    Width-BorderWidth-CaptionOffset, Height-BorderWidth-CaptionOffset);
  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect(0, 0, Width, Height));
  Canvas.Pen.Color := BorderColor;
  Canvas.Pen.Width := BorderWidth;
  Canvas.Font := Font;
  Canvas.Brush.Color := Color;
  Canvas.RoundRect(0, 0, Width, Height, -CornersOffset+BorderWidth-1, -CornersOffset+BorderWidth-1);
  Flag := Alignments[CaptionAlignment];
  Rector.Top := ((Rector.Bottom + Rector.Top) - Canvas.TextHeight('W')) div 2;
  Rector.Bottom := Rector.Top + Canvas.TextHeight('W');
  DrawText(Canvas.handle, PChar(Caption), Length(Caption), Rector, Flag);
end;

end.
