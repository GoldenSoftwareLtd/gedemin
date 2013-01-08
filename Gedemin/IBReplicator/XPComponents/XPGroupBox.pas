unit XPGroupBox;

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
  XP_GROUPBOX_CAPTION_ALIGNMENT = caLeft;
  MAX_BORDER_WIDTH = 10;
  MIN_BORDER_WIDTH = 1;
  MAX_CAPTION_OFFSET = 30;
  MIN_CAPTION_OFFSET = 1;
  MAX_CORNERS_OFFSET = 30;
  MIN_CORNERS_OFFSET = 1;
  Alignments: array[TCaptionAlignment] of Longint =
    (DT_LEFT, DT_RIGHT, DT_CENTER);

type
  TXPGroupBox = class(TCustomControl)
  private
    FBorderWidth: Integer;
    FBorderColor: TColor;
    FCornersOffset: Integer;
    FCaptionOffset: Integer;
    FCaptionAlignment: TCaptionAlignment;
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
    property CaptionAlignment: TCaptionAlignment read FCaptionAlignment write SetCaptionAlignment default XP_GROUPBOX_CAPTION_ALIGNMENT;
    property CaptionOffset: Integer read FCaptionOffset write SetCaptionOffset default XP_CAPTION_OFFSET;
    property Color;
    property CornersOffset: Integer read FCornersOffset write SetCornersOffset default XP_CORNERS_OFFSET;
    property Enabled;
    property Font;
    property Hint;
    property Height default 105;
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
  RegisterComponents('XPComponents', [TXPGroupBox]);
end;

constructor TXPGroupBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csDoubleClicks, csReplicatable];
  Width := 185;
  Height := 105;
  FBorderWidth := XP_BORDER_WIDTH;
  FBorderColor := XP_BORDER_COLOR;
  FCornersOffset := XP_CORNERS_OFFSET;
  FCaptionOffset := XP_CAPTION_OFFSET;
  FCaptionAlignment := XP_GROUPBOX_CAPTION_ALIGNMENT;
  Font.Color := XP_CAPTION_COLOR;
end;

procedure TXPGroupBox.Paint;
var Rector: TRect;
    Flag: LongInt;
begin
  Rector := Rect(CaptionOffset, 0,
    Width-CaptionOffset, Height-BorderWidth);
  Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect(0, 0, Width, Height));
  Canvas.Pen.Color := BorderColor;
  Canvas.Pen.Width := BorderWidth;
  Canvas.Font := Font;
  Canvas.Brush.Color := Color;
  Flag := Alignments[CaptionAlignment];
  Canvas.RoundRect(0, Canvas.TextHeight('W') div 2, Width, Height, -CornersOffset+BorderWidth-1, -CornersOffset+BorderWidth-1);
  DrawText(Canvas.handle, PChar(Caption), Length(Caption), Rector, Flag);
end;

procedure TXPGroupBox.CMDialogChar(var Message: TCMDialogChar);
begin
with Message do
  if IsAccel(CharCode, Caption) then
    Result := 1
else
  inherited;
end;

procedure TXPGroupBox.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TXPGroupBox.MouseEnter(var Message: TMessage);
begin
  if Assigned(FMouseEnter) then
    FMouseEnter(Self);
end;

procedure TXPGroupBox.MouseLeave(var Message: TMessage);
begin
  if Assigned(FMouseLeave) then
    FMouseLeave(Self);
end;

procedure TXPGroupBox.WMSize(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TXPGroupBox.SetBorderColor(NewBorderColor: TColor);
begin
  if FBorderColor <> NewBorderColor then
    begin
      FBorderColor := NewBorderColor;
      Invalidate;
    end;
end;

procedure TXPGroupBox.SetBorderWidth(NewBorderWidth: Integer);
begin
  if NewBorderWidth = FBorderWidth then
    Exit;
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

procedure TXPGroupBox.SetCaptionAlignment(NewCaptionAlignment: TCaptionAlignment);
begin
  if FCaptionAlignment <> NewCaptionAlignment then
    begin
      FCaptionAlignment := NewCaptionAlignment;
      Invalidate;
    end;
end;

procedure TXPGroupBox.SetCaptionOffset(NewCaptionOffset: Integer);
begin
  if NewCaptionOffset = FCaptionOffset then
    Exit;
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

procedure TXPGroupBox.SetCornersOffset(NewCornersOffset: Integer);
begin
  if NewCornersOffset = FCornersOffset then
    Exit;
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

end.