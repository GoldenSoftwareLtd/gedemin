
unit xmsButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

const
  DefFrameColor = $E7F3F7;
  DefFocusFrameColor = $525152;
  DefNormalColor = $94A2A5;
  DefPressedColor = clBlack;
  DefNormalTextColor = clBlack;
  DefHighlightTextColor = clWhite;

type
  TColorSchema = (clsFirst, clsSecond);

type
  TxmsButton = class(TCustomControl)
  private
    FDefault: Boolean;
    FCaption: String;
    FPressedColor: TColor;
    FFocusFrameColor: TColor;
    FNormalTextColor: TColor;
    FNormalColor: TColor;
    FHighlightTextColor: TColor;
    FFrameColor: TColor;
    FFont: TFont;
    FEnabled: Boolean;
    FOnClick: TNotifyEvent;
    FColorSchema: TColorSchema;
    procedure SetCaption(const Value: String);
    procedure SetDefault(const Value: Boolean);
    procedure SetFocusFrameColor(const Value: TColor);
    procedure SetFrameColor(const Value: TColor);
    procedure SetHighlightTextColor(const Value: TColor);
    procedure SetNormalColor(const Value: TColor);
    procedure SetNormalTextColor(const Value: TColor);
    procedure SetPressedColor(const Value: TColor);
    procedure SetFont(const Value: TFont);
    procedure SetColorSchema(const Value: TColorSchema);

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DrawCaption;
    procedure Paint; override;
    function IsMouseDown: Boolean;
    function IsMouseInRect: Boolean;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TWMSetFocus);
      message WM_SETFOCUS;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
      message WM_ERASEBKGND;
    procedure CMFontChanged(var Message: TMessage);
      message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage);
      message CM_EnabledCHANGED;
    procedure CNCommand(var Message: TWMCommand);
      message CN_COMMAND;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Caption: String read FCaption write SetCaption;
    property Default: Boolean read FDefault write SetDefault
      default False;
    property FrameColor: TColor read FFrameColor write SetFrameColor
      default DefFrameColor;
    property FocusFrameColor: TColor read FFocusFrameColor write SetFocusFrameColor
      default DefFocusFrameColor;
    property NormalColor: TColor read FNormalColor write SetNormalColor
      default DefNormalColor;
    property PressedColor: TColor read FPressedColor write SetPressedColor
      default DefPressedColor;
    property NormalTextColor: TColor read FNormalTextColor write SetNormalTextColor
      default DefNormalTextColor;
    property HighlightTextColor: TColor read FHighlightTextColor write SetHighlightTextColor
      default DefHighlightTextColor;
    property Font: TFont read FFont write SetFont;
    property ColorSchema: TColorSchema read FColorSchema write SetColorSchema
      default clsFirst;

    property OnClick: TNotifyEvent read FOnClick write FOnClick;

    property Width default 64;
    property Height default 22;
    property Visible;
    property ShowHint;
    property Enabled;
  end;

procedure Register;

implementation

uses
  Rect;

{ TxmsButton }

constructor TxmsButton.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FDefault := False;
  FFrameColor := DefFrameColor;
  FFocusFrameColor := DefFocusFrameColor;
  FNormalColor := DefNormalColor;
  FPressedColor := DefPressedColor;
  FNormalTextColor := DefNormalTextColor;
  FHighlightTextColor := DefHighlightTextColor;
  FEnabled := True;
  FFont := TFont.Create;
  FFont.CharSet := RUSSIAN_CHARSET;
  FFont.Name := 'Tahoma';
  Width := 64;
  Height := 40;
  FColorSchema := clsFirst;
end;

destructor TxmsButton.Destroy;
begin
  inherited Destroy;
  FFont.Free;
end;

procedure TxmsButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WindowClass.hbrBackground := 0;
end;

procedure TxmsButton.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := -1;
end;

procedure TxmsButton.DrawCaption;
var
  R: TRect;
  Ch: array[0..255] of Char;
begin
  R := GetClientRect;
  R.Left := R.Left + 8;
  Canvas.Font.Assign(Font);
  if MouseCapture then
    Canvas.Font.Color := FHighlightTextColor
  else
    Canvas.Font.Color := FNormalTextColor;
  Canvas.Brush.Style := bsClear;
  DrawText(Canvas.Handle, StrPCopy(Ch, FCaption), Length(FCaption), R, DT_LEFT or DT_VCENTER or DT_SINGLELINE);
end;

function TxmsButton.IsMouseDown: Boolean;
begin
  Result := Integer(GetAsyncKeyState(VK_LBUTTON)) < 0;
end;

function TxmsButton.IsMouseInRect: Boolean;
var
  P: TPoint;
begin
  GetCursorPos(P);
  Windows.ScreenToClient(Handle, P);
  Result := (P.Y >= 0) and (P.Y < Height) and (P.X >= 0) and (P.X < Width);
end;

procedure TxmsButton.Paint;
var
  R: TRect;
begin
  R := GetClientRect;
  Canvas.Brush.Color := FrameColor;
  Canvas.Brush.Style := bsSolid;
  Canvas.FrameRect(R);
  RectGrow(R, -1);
  if Focused or FDefault then
  begin
    Canvas.FrameRect(R);
    RectGrow(R, -1);
  end;
  if IsMouseDown and IsMouseInRect then
    Canvas.Brush.Color := FPressedColor
  else
    Canvas.Brush.Color := FNormalColor;
  Canvas.FillRect(R);
  if Focused then
  begin
    RectGrow(R, -2);
    Canvas.Brush.Color := FFocusFrameColor;
    Canvas.FrameRect(R);
  end;
  DrawCaption;
end;

procedure TxmsButton.SetCaption(const Value: String);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Invalidate;
  end;  
end;

procedure TxmsButton.SetColorSchema(const Value: TColorSchema);
begin
  FColorSchema := Value;
  Invalidate;
end;

procedure TxmsButton.SetDefault(const Value: Boolean);
begin
  if FDefault <> Value then
  begin
    FDefault := Value;
    Invalidate;
  end;  
end;

procedure TxmsButton.SetFocusFrameColor(const Value: TColor);
begin
  if FFocusFrameColor <> Value then
  begin
    FFocusFrameColor := Value;
    Invalidate;
  end;
end;

procedure TxmsButton.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  Invalidate;
end;

procedure TxmsButton.SetFrameColor(const Value: TColor);
begin
  if FFrameColor <> Value then
  begin
    FFrameColor := Value;
    Invalidate;
  end;
end;

procedure TxmsButton.SetHighlightTextColor(const Value: TColor);
begin
  if FHighlightTextColor <> Value then
  begin
    FHighlightTextColor := Value;
    Invalidate;
  end;
end;

procedure TxmsButton.SetNormalColor(const Value: TColor);
begin
  if FNormalColor <> Value then
  begin
    FNormalColor := Value;
    Invalidate;
  end;
end;

procedure TxmsButton.SetNormalTextColor(const Value: TColor);
begin
  if FNormalTextColor <> Value then
  begin
    FNormalTextColor := Value;
    Invalidate;
  end;  
end;

procedure TxmsButton.SetPressedColor(const Value: TColor);
begin
  if FPressedColor <> Value then
  begin
    FPressedColor := Value;
    Invalidate;
  end;
end;

procedure TxmsButton.WMKillFocus(var Message: TWMKillFocus);
begin
  Windows.SetFocus(Message.FocusedWnd);
  Message.Result := 0;
  Invalidate;
end;

procedure TxmsButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  with Message do
    if (YPos < 0) or (YPos >= Height) or (XPos < 0) or (XPos >= Width) then
    begin
      MouseCapture := False
    end else
    begin
      MouseCapture := True;
      FDefault := True;
    end;
//  DrawCaption;
  Paint;
end;

procedure TxmsButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  with Message do
    if (YPos < 0) or (YPos >= Height) or (XPos < 0) or (XPos >= Width) then
    begin
      MouseCapture := False
    end else
    begin
      MouseCapture := True;
      if not Focused then
        SetFocus;
      if Assigned(FOnClick) then
        FOnClick(Self);  
    end;
//  DrawCaption;
  Paint;
end;

procedure TxmsButton.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  with Message do
    if (YPos < 0) or (YPos >= Height) or (XPos < 0) or (XPos >= Width) then
    begin
      if not IsMouseDown then
        MouseCapture := False
    end else
    begin
      MouseCapture := True;
    end;
//  DrawCaption;
  Paint;
end;

// Register ----------------------------------------------

procedure Register;
begin
  RegisterComponents('gsBtn', [TxmsButton]);
end;

procedure TxmsButton.WMSetFocus(var Message: TWMSetFocus);
begin
  Windows.SetFocus(Handle);
  Message.Result := 0;
  Invalidate;
end;

procedure TxmsButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TxmsButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TxmsButton.CNCommand(var Message: TWMCommand);
begin
  if Message.NotifyCode = BN_CLICKED then Click;
end;

end.
