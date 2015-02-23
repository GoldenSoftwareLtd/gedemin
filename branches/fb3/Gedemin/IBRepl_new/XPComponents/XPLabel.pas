unit XPLabel;

interface

uses Windows, Messages, Forms, Graphics, Controls, Classes;

type
  TCaptionAlignment = (caLeft, caRight, caCenter);

const
  XP_AUTO_SIZE = True;
  XP_CAPTION_ALIGNMENT = caLeft;
  XP_FOREGROUND_COLOR = $00FFFFFF;
  XP_BACKGROUND_COLOR = $00881C10;
  XP_OFFSET = 1;
  Alignments: array[TCaptionAlignment] of Longint =
    (DT_LEFT, DT_RIGHT, DT_CENTER);

type
  TXPLabel = class(TGraphicControl)
  private
    FMouseEnter: TNotifyEvent;
    FMouseLeave: TNotifyEvent;
    FAutoSize: boolean;
    FCaptionAlignment: TCaptionAlignment;
    FForegroundColor: TColor;
    FBackgroundColor: TColor;
    FOffset: Integer;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure MouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure MouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    procedure SetAutoSize(NewAutoSize: boolean); reintroduce;
    procedure SetCaptionAlignment(NewCaptionAlignment: TCaptionAlignment);
    procedure SetForegroundColor(NewForegroundColor: TColor);
    procedure SetBackgroundColor(NewBackgroundColor: TColor);
    procedure SetOffset(NewOffset: Integer);
    procedure ReAlign;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property AutoSize: boolean read FAutoSize write SetAutoSize default XP_AUTO_SIZE;
    property Caption;
    property CaptionAlignment: TCaptionAlignment read FCaptionAlignment write SetCaptionAlignment default XP_CAPTION_ALIGNMENT;
    property Font;
    property ForegroundColor: TColor read FForegroundColor write SetForegroundColor default XP_FOREGROUND_COLOR;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default XP_BACKGROUND_COLOR;
    property Offset: Integer read FOffset write SetOffset default XP_OFFSET;
    property Hint;
    property Height default 14;
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
    property OnMouseEnter: TNotifyEvent read FMouseEnter write FMouseEnter;
    property OnMouseLeave: TNotifyEvent read FMouseLeave write FMouseLeave;
    property Width default 47;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('XPComponents', [TXPLabel]);
end;

constructor TXPLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csDoubleClicks, csReplicatable];
  Height := 14;
  Width := 47;
  FAutoSize := XP_AUTO_SIZE;
  FCaptionAlignment := XP_CAPTION_ALIGNMENT;
  FForegroundColor := XP_FOREGROUND_COLOR;
  FBackgroundColor := XP_BACKGROUND_COLOR;
  FOffset := XP_OFFSET;
end;

procedure TXPLabel.CMDialogChar(var Message: TCMDialogChar);
begin
with Message do
  if IsAccel(CharCode, Caption) then
    Result := 1
else
  inherited;
end;

procedure TXPLabel.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TXPLabel.MouseEnter(var Message: TMessage);
begin
  if Assigned(FMouseEnter) then
    FMouseEnter(Self);
end;

procedure TXPLabel.MouseLeave(var Message: TMessage);
begin
  if Assigned(FMouseLeave) then
    FMouseLeave(Self);
end;

procedure TXPLabel.WMSize(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TXPLabel.SetAutoSize(NewAutoSize: boolean);
begin
  if NewAutoSize <> FAutoSize then
    begin
      FAutoSize := NewAutoSize;
      Invalidate;
    end;
end;

procedure TXPLabel.SetCaptionAlignment(NewCaptionAlignment: TCaptionAlignment);
begin
  if NewCaptionAlignment <> FCaptionAlignment then
    begin
      FCaptionAlignment := NewCaptionAlignment;
      Invalidate;
    end;
end;

procedure TXPLabel.SetForegroundColor(NewForegroundColor: TColor);
begin
  if NewForegroundColor <> FForegroundColor then
    begin
      FForegroundColor := NewForegroundColor;
      Invalidate;
    end;
end;

procedure TXPLabel.SetBackgroundColor(NewBackgroundColor: TColor);
begin
  if NewBackgroundColor <> FBackgroundColor then
    begin
      FBackgroundColor := NewBackgroundColor;
      Invalidate;
    end;
end;

procedure TXPLabel.SetOffset(NewOffset: Integer);
begin
  if NewOffset <> FOffset then
    begin
      FOffset := NewOffset;
      Invalidate;
    end;
end;

procedure TXPLabel.ReAlign;
begin
  if not AutoSize then
    Exit;
  Height := Canvas.TextHeight(Caption)+Offset;
  Width := Canvas.TextWidth(Caption)+Offset;
end;

procedure TXPLabel.Paint;
var Rector: TRect;
    Flag: LongInt;
begin
  ReAlign;
  Rector := GetClientRect;
  Canvas.Brush.Style := bsClear;
  Flag := Alignments[CaptionAlignment];
  Canvas.Font := Font;
  Canvas.Font.Color := BackgroundColor;
  Rector.Top := Rector.Top+Offset;
  Rector.Left := Rector.Left+Offset;
  DrawText(Canvas.handle, PChar(Caption), Length(Caption), Rector, Flag);
  Canvas.Font.Color := ForegroundColor;
  Rector := GetClientRect;
  Case CaptionAlignment of
    caCenter:
      begin
        Rector.Left := Rector.Left - (Offset div 2);
        Rector.Right := Rector.Right - (Offset div 2);
      end;
    caRight:
      begin
        Rector.Left := Rector.Left - Offset;
        Rector.Right := Rector.Right - Offset;
      end;
  end;
  DrawText(Canvas.handle, PChar(Caption), Length(Caption), Rector, Flag);
end;

end.
