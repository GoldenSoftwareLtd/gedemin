unit XPTreeView;

interface
uses CheckTreeView, XPEdit, Graphics, Messages, Windows, Controls, Classes,
  XPButton;

type
  TXPTreeView = class(TCheckTreeView)
  private
    FDisabledBorderWidth: Integer;
    FEnabledBorderWidth: Integer;
    FDisabledBorderColor: TColor;
    FEnabledBorderColor: TColor;
    procedure Paint(var Message: TMessage); message WM_Paint;
    procedure SetDisabledBorderColor(const Value: TColor);
    procedure SetDisabledBorderWidth(const Value: Integer);
    procedure SetEnabledBorderColor(const Value: TColor);
    procedure SetEnabledBorderWidth(const Value: Integer);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
  public
    DrawState: TOwnerDrawState;
    constructor Create(AOwner: TComponent); override;
  published
    property EnabledBorderColor: TColor read FEnabledBorderColor write SetEnabledBorderColor default BORDER_ENABLED;
    property DisabledBorderColor: TColor read FDisabledBorderColor write SetDisabledBorderColor default BORDER_DISABLED;
    property EnabledBorderWidth: Integer read FEnabledBorderWidth write SetEnabledBorderWidth default ENABLED_WIDTH;
    property DisabledBorderWidth: Integer read FDisabledBorderWidth write SetDisabledBorderWidth default DISABLED_WIDTH;
  end;

procedure Register;
implementation
procedure Register;
begin
  RegisterComponents('XPComponents', [TXPTreeView]);
end;

{ TXPTreeView }

procedure TXPTreeView.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  Include(DrawState, odHotLight);
  Invalidate;
end;

procedure TXPTreeView.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  Exclude(DrawState, odHotLight);
  Invalidate;
end;

constructor TXPTreeView.Create(AOwner: TComponent);
begin
  inherited;
  FEnabledBorderColor := BORDER_ENABLED;
  FDisabledBorderColor := BORDER_DISABLED;
  FEnabledBorderWidth := ENABLED_WIDTH;
  FDisabledBorderWidth := DISABLED_WIDTH;
end;

procedure TXPTreeView.Paint(var Message: TMessage);
var DC: HDC;
    R: TRect;
    Canvas: TCanvas;
begin
  inherited;
  Canvas := TCanvas.Create;
  DC := GetWindowDC(Handle);
  Canvas.Handle := DC;
  try
    GetWindowRect(Handle, R);
    OffsetRect(R, -R.Left, -R.Top);
    if Enabled  then
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
    ReleaseDC(Handle, DC);
    Canvas.Handle := 0;
    Canvas.Free;
  end;
end;

procedure TXPTreeView.SetDisabledBorderColor(const Value: TColor);
begin
  FDisabledBorderColor := Value;
end;

procedure TXPTreeView.SetDisabledBorderWidth(const Value: Integer);
begin
  FDisabledBorderWidth := Value;
end;

procedure TXPTreeView.SetEnabledBorderColor(const Value: TColor);
begin
  FEnabledBorderColor := Value;
end;

procedure TXPTreeView.SetEnabledBorderWidth(const Value: Integer);
begin
  FEnabledBorderWidth := Value;
end;

end.
