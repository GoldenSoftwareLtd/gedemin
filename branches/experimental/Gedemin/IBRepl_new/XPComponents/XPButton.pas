unit XPButton;

interface

uses
  Windows, Messages, Graphics, Classes, Controls, Forms, ActnList;

const
  XP_BTN_BORDER_COLOR = $00733C00;
  XP_BTN_CORNERS_COLOR = $00AD967B;
  XP_BTN_BKGRD_BDR_COLOR = $00EFF7F0;
  XP_BTN_DSBL_BDR_COLOR = $00BFC7CF;
  XP_BTN_FACE_START = $00FFFFFF;
  XP_BTN_FACE_END = $00E7EBEF;
  XP_BTN_PRESS_START = $00C6CFD6;
  XP_BTN_PRESS_END = $00EBF3F7;
  XP_BTN_BDR_MOUSE_START = $00CEF3FF;
  XP_BTN_BDR_MOUSE_END = $000096E7;
  XP_BTN_BDR_NOMOUSE_START = $00FFE7CE;
  XP_BTN_BDR_NOMOUSE_END = $00EF846D;

type
  TBoundLines = set of (blLeft, blTop, blRight, blBottom);
  TColorSteps = 2..255;
  TXPGradientStyle = (gsLeft, gsTop, gsRight, gsBottom);

  TXPButton = class;

  TXPButtonActionLink = class(TWinControlActionLink)
  protected
    FClient: TXPButton;
    procedure AssignClient(AClient: TObject); override;
    function IsCheckedLinked: Boolean; override;
    procedure SetChecked(Value: Boolean); override;
  end;

  TXPButton = class(TCustomControl)
  private
    { Private desclarations }
    FLocked: Boolean;
    FModalResult: TModalResult;
    FOnMouseLeave: TNotifyEvent;
    FOnMouseEnter: TNotifyEvent;
    FBgGradient: TBitmap;
    FCkGradient: TBitmap;
    FDefault: Boolean;
    FCancel: Boolean;
    FFcGradient: TBitmap;
    FGlyph: TPicture;
    FHlGradient: TBitmap;
    FShowFocusRect: Boolean;
    FFocusRectOffset: Integer;
    FMouseBorderWidth: Integer;
    FOffsetOnClick: Integer;
    FImageList: TImageList;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFocusChanged(var Message: TMessage); message CM_FOCUSCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMParentColorChanged(var Message: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure SetImageList(const Value: TImageList);
  protected
    { Protected desclarations }
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure HookEnabledChanged; dynamic;
    procedure HookFocusedChanged; dynamic;
    procedure HookMouseDown; dynamic;
    procedure HookMouseEnter; dynamic;
    procedure HookMouseLeave; dynamic;
    procedure HookMouseMove; dynamic;
    procedure HookMouseUp; dynamic;
    procedure HookParentColorChanged; dynamic;
    procedure HookResized; dynamic;
    procedure HookTextChanged; dynamic;
    function IsSpecialDrawState(IgnoreDefault: Boolean = False): Boolean;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure SetDefault(NewDefault: Boolean); virtual;
    procedure SetGlyph(NewGlyph: TPicture); virtual;
    procedure SetShowFocusRect(NewShowFocusRect: Boolean); virtual;
    procedure SetFocusRectOffset(NewFocusRectOffset: Integer); virtual;
    procedure SetMouseBorderWidth(NewMouseBorderWidth: Integer); virtual;
    procedure SetOffsetOnClick(NewOffsetOnClick: Integer); virtual;
    procedure Paint; override;
    function GetActionLinkClass: TControlActionLinkClass; override;
  public
    { Public declarations }
    DrawState: TOwnerDrawState;
    IsSibling: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LockUpdate;
    procedure UnlockUpdate;
  published
    { Published declarations }
    property Action;
    property Align;
    property Anchors;
    property Caption;
    property Color;
    property Cursor;
    property Default: Boolean read FDefault write SetDefault default False;
    property Enabled;
    property Font;
    property Hint;
    property ImageList: TImageList read FImageList write SetImageList;
    property FocusRectOffset: Integer read FFocusRectOffset write SetFocusRectOffset default 3;
    property Glyph: TPicture read FGlyph write SetGlyph;
    property Height default 25;
    property ModalResult: TModalResult read FModalResult write FModalResult default 0;
    property MouseBorderWidth: Integer read FMouseBorderWidth write SetMouseBorderWidth default 2;
    property PopupMenu;
    property ShowFocusRect: Boolean read FShowFocusRect write SetShowFocusRect default True;
    property ShowHint;
    property OffsetOnClick: Integer read FOffsetOnClick write SetOffsetOnClick default 0;
    property OnClick;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property Visible;
    property TabStop default True;
    property TabOrder;
    property Width default 73;
  end;

{ TGradient }

  TGradient = class(TPersistent)
  private
    { Private declarations }
    FColorSteps: TColorSteps;
    FDithered: Boolean;
    FEnabled: Boolean;
    FEndColor: TColor;
    FStartColor: TColor;
    FXPGradientStyle: TXPGradientStyle;
  protected
    { Protected declarations }
    Parent: TControl;
    procedure SetDithered(NewDithered: Boolean); virtual;
    procedure SetColorSteps(NewColorSteps: TColorSteps); virtual;
    procedure SetEnabled(NewEnabled: Boolean); virtual;
    procedure SetEndColor(NewEndColor: TColor); virtual;
    procedure SetXPGradientStyle(NewXPGradientStyle: TXPGradientStyle); virtual;
    procedure SetStartColor(NewStartColor: TColor); virtual;
  public
    { Public declarations }
    Bitmap: TBitmap;
    constructor Create(AOwner: TControl);
    destructor Destroy; override;
    procedure RecreateBands; virtual;
  published
    { Published declarations }
    property Dithered: Boolean read FDithered write SetDithered default True;
    property ColorSteps: TColorSteps read FColorSteps write SetColorSteps default 16;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property EndColor: TColor read FEndColor write SetEndColor default clSilver;
    property StartColor: TColor read FStartColor write SetStartColor default clGray;
    property Style: TXPGradientStyle read FXPGradientStyle write SetXPGradientStyle default gsLeft;
  end;

procedure DrawLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer);
procedure DrawBoundLines(ACanvas: TCanvas; ABoundLines: TBoundLines; const AColor: TColor; const R: TRect);
procedure CreateGradientRect(Width, Height: Integer; StartColor, EndColor: TColor; ColorSteps: TColorSteps; Style: TXPGradientStyle; Dithered: Boolean; var Bitmap: TBitmap);
procedure RenderText(Parent: TControl; Canvas: TCanvas; AText: string; AFont: TFont; Enabled, ShowAccelChar: Boolean; var Rect: TRect; Flags: Integer); overload;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('XPComponents', [TXPButton]);
end;

{ TXPButton }

constructor TXPButton.Create(AOwner: TComponent);
begin
  inherited;
  DoubleBuffered := True;
  DrawState := [odDefault];
  IsSibling := False;
  FLocked := False;
  FModalResult := 0;
  Height := 25;
  TabStop := True;
  Width := 73;
  FCancel := False;
  FDefault := False;
  FGlyph := TPicture.Create;
  FShowFocusRect := True;
  FFocusRectOffset := 3;
  FMouseBorderWidth := 2;
  FOffsetOnClick := 0;
  FBgGradient := TBitmap.Create;
  FCkGradient := TBitmap.Create;
  FFcGradient := TBitmap.Create;
  FHlGradient := TBitmap.Create;
end;

destructor TXPButton.Destroy;
begin
  FBgGradient.Free;
  FCkGradient.Free;
  FFcGradient.Free;
  FHlGradient.Free;
  FGlyph.Free;
  inherited;
end;

procedure TXPButton.LockUpdate;
begin
  FLocked := True;
end;

procedure TXPButton.UnlockUpdate;
begin
  FLocked := False;
  Invalidate;
end;

procedure TXPButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
  if IsAccel(CharCode, Caption) and CanFocus and (Focused or
    ((GetKeyState(VK_MENU) and $8000) <> 0)) then Click
  else
    inherited;
end;

procedure TXPButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  HookEnabledChanged;
end;

procedure TXPButton.CMFocusChanged(var Message: TMessage);
begin
  inherited;
  HookFocusedChanged;
end;

procedure TXPButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  HookMouseEnter;
end;

procedure TXPButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  HookMouseLeave;
end;

procedure TXPButton.CMParentColorChanged(var Message: TMessage);
begin
  inherited;
  HookParentColorChanged;
end;

procedure TXPButton.CMTextChanged(var Message: TMessage);
begin
  inherited;
  HookTextChanged;
end;

procedure TXPButton.WMSize(var Message: TWMSize);
begin
  HookResized;
end;

procedure TXPButton.CMDialogKey(var Message: TCMDialogKey);
begin
  inherited;
  with Message do
  if (((CharCode = VK_RETURN) and (Focused or (FDefault and not(IsSibling)))) or
     ((CharCode = VK_ESCAPE) and FCancel) and (KeyDataToShiftState(KeyData) = [])) and
     CanFocus then
  begin
    Click;
    Result := 1;
  end
  else
    inherited;
end;

procedure TXPButton.Click;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if Form <> nil then
    Form.ModalResult := ModalResult;
  inherited;
end;

procedure TXPButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
    HookMouseDown;
end;

procedure TXPButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  HookMouseMove;
end;

procedure TXPButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  HookMouseUp;
end;

procedure TXPButton.HookEnabledChanged;
begin
  if not FLocked then
    Invalidate;
end;

procedure TXPButton.HookFocusedChanged;
begin
  if Focused then
    Include(DrawState, odFocused)
  else
  begin
    Exclude(DrawState, odFocused);
    Exclude(DrawState, odSelected);
  end;
  IsSibling := GetParentForm(Self).ActiveControl is TXPButton;
  if not FLocked then
    Invalidate;
end;

procedure TXPButton.HookMouseDown;
begin
  SetFocus;
  Include(DrawState, odSelected);
  if not FLocked then
    Invalidate;
end;

procedure TXPButton.HookMouseEnter;
begin
  Include(DrawState, odHotLight);
  if not FLocked then
    Invalidate;
  if assigned(FOnMouseEnter) then
    FOnMouseEnter(Self);
end;

procedure TXPButton.HookMouseLeave;
begin
  Exclude(DrawState, odHotLight);
  if not FLocked then
    Invalidate;
  if assigned(FOnMouseLeave) then
    FOnMouseLeave(Self);
end;

procedure TXPButton.HookMouseMove;
begin
  ;
end;

procedure TXPButton.HookMouseUp;
//var
//  ValidClick: Boolean;
begin
  if odSelected in DrawState then
  begin
//    ValidClick := (odHotLight in DrawState) and (odFocused in DrawState);
    Exclude(DrawState, odSelected);
    if not FLocked then
      Invalidate;
//    if ValidClick then
//      Click;
  end;
end;

procedure TXPButton.HookParentColorChanged;
begin
  Invalidate;
end;

procedure TXPButton.HookResized;
var
  Offset, ColSteps: Integer;
begin
    ColSteps := 32;
  Offset := 4 * (Integer(IsSpecialDrawState(True)));
  CreateGradientRect(Width - (2 + Offset), Height - (2 + Offset),
    XP_BTN_FACE_START, XP_BTN_FACE_END, ColSteps, gsTop, True, FBgGradient);
  CreateGradientRect(Width - 2, Height - 2, XP_BTN_PRESS_START, XP_BTN_PRESS_END, ColSteps,
    gsTop, True, FCkGradient);
  CreateGradientRect(Width - 2, Height - 2, XP_BTN_BDR_MOUSE_START, XP_BTN_BDR_MOUSE_END, ColSteps,
    gsTop, True, FHlGradient);
  CreateGradientRect(Width - 2, Height - 2, XP_BTN_BDR_NOMOUSE_START, XP_BTN_BDR_NOMOUSE_END, ColSteps,
    gsTop, True, FFcGradient);
end;

procedure TXPButton.HookTextChanged;
begin
  if not FLocked then
    Invalidate;
end;

function TXPButton.IsSpecialDrawState(IgnoreDefault: Boolean = False): Boolean;
begin
  if (odSelected in DrawState)  then
    Result := not(odHotLight in DrawState)
  else
    Result := (odHotLight in DrawState) or (odFocused in DrawState);
  if not IgnoreDefault then
    Result := Result or FDefault and not IsSibling;
end;

procedure TXPButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Shift = []) and (Key = VK_SPACE) then
  begin
    LockUpdate;
    try
      HookMouseEnter;;
      HookMouseDown;
    finally
      UnlockUpdate;
    end;
  end;
end;

procedure TXPButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if not(odSelected in DrawState) then
    Exit;
  HookMouseUp;
  HookMouseLeave;
  inherited;
end;

procedure TXPButton.SetDefault(NewDefault: Boolean);
begin
  if NewDefault <> FDefault then
  begin
    FDefault := NewDefault;
    with GetParentForm(Self) do
      Perform(CM_FOCUSCHANGED, 0, LongInt(ActiveControl));
  end;
end;

procedure TXPButton.SetGlyph(NewGlyph: TPicture);
begin
  FGlyph.Assign(NewGlyph);
  Invalidate;
end;

procedure TXPButton.SetShowFocusRect(NewShowFocusRect: Boolean);
begin
  if NewShowFocusRect <> FShowFocusRect then
  begin
    FShowFocusRect := NewShowFocusRect;
    Invalidate;
  end;
end;

procedure TXPButton.SetFocusRectOffset(NewFocusRectOffset: Integer);
begin
  if NewFocusRectOffset <> FFocusRectOffset then
  begin
    FFocusRectOffset := NewFocusRectOffset;
    Invalidate;
  end;
end;

procedure TXPButton.SetMouseBorderWidth(NewMouseBorderWidth: Integer);
begin
  if NewMouseBorderWidth <> FMouseBorderWidth then
  begin
    FMouseBorderWidth := NewMouseBorderWidth;
    Invalidate;
  end;
end;

procedure TXPButton.SetOffsetOnClick(NewOffsetOnClick: Integer);
begin
  if NewOffsetOnClick <> FOffsetOnClick then
  begin
    FOffsetOnClick := NewOffsetOnClick;
    Invalidate;
  end;
end;

procedure TXPButton.Paint;
var
  R: TRect;
  Offset, Flags: Integer;
  Bitmap: TBitmap;
begin
 if Enabled then
 begin
  with Canvas do
  begin
    R := GetClientRect;
    Brush.Color := Self.Color;
    FillRect(R);
    if IsSpecialDrawState then
    begin
      Bitmap := TBitmap.Create;
      try
        if odHotLight in DrawState then
          Bitmap.Assign(FHlGradient)
        else
          Bitmap.Assign(FFcGradient);
        BitBlt(Handle, 1, 1, Width, Height, Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
      finally
        Bitmap.Free;
      end;
    end;
    if not((odHotLight in DrawState) and (odSelected in DrawState)) then
    begin
      Offset := MouseBorderWidth+1;
      if IsSpecialDrawState then
      BitBlt(Handle, Offset, Offset, Width - Offset*2, Height - Offset*2,
        FBgGradient.Canvas.Handle, 0, 0, SRCCOPY);
      if not IsSpecialDrawState then
      BitBlt(Handle, 1, 1, Width - 1*2, Height - 1*2,
        FBgGradient.Canvas.Handle, 0, 0, SRCCOPY);
    end
    else
      BitBlt(Handle, 1, 1, Width, Height, FCkGradient.Canvas.Handle, 0, 0, SRCCOPY);
    if (odFocused in DrawState) and (FShowFocusRect) then
      DrawFocusRect(Bounds(FFocusRectOffset, FFocusRectOffset, Width - (FFocusRectOffset * 2), Height - (FFocusRectOffset * 2)));
    Pen.Color := XP_BTN_BORDER_COLOR;
    Brush.Style := bsClear;
    RoundRect(0, 0, Width, Height, 5, 5);
    Pen.Color := XP_BTN_CORNERS_COLOR;
    SetPixel(Canvas.Handle, 0, 1, Pen.Color);
    SetPixel(Canvas.Handle, 1, 0, Pen.Color);
    DrawLine(Canvas, Width - 2, 0, Width, 2);
    DrawLine(Canvas, 0, Height - 2, 2, Height);
    DrawLine(Canvas, Width - 3, Height, Width, Height - 3);
    InflateRect(R, -4, 0);
    if (odHotLight in DrawState) and (odSelected in DrawState) then
      OffsetRect(R, OffsetOnClick, OffsetOnClick);

    if FGlyph.Graphic <> nil then
    begin
      FGlyph.Graphic.Transparent := True;
      Draw(R.Left + 3, (Height - FGlyph.Height) div 2 + R.Top, FGlyph.Graphic);
      Inc(R.Left, FGlyph.Width + 3);
    end else
    begin
      if (Action <> nil) and (ImageList <> nil) and (TAction(Action).ImageIndex > - 1) then
      begin
        ImageList.Draw(Canvas, R.Left, (Height - ImageList.Height) div 2 + R.Top,
          TAction(Action).ImageIndex, Enabled);
      end;
    end;
    Flags := DT_SINGLELINE or DT_CENTER or DT_VCENTER or DT_END_ELLIPSIS;
    Font.Assign(Self.Font);
    RenderText(Self, Canvas, Caption, Font, True, True, R, Flags);
  end;
 end else
 begin
  R := GetClientRect;
  Canvas.Brush.Color := Color;
  Canvas.FillRect(R);
  Canvas.Brush.Color := XP_BTN_BKGRD_BDR_COLOR;
  Canvas.FillRect(Rect(2, 2, Width-2, Height-2));
  Canvas.Pen.Color := XP_BTN_DSBL_BDR_COLOR;
  Canvas.RoundRect(0, 0, Width, Height, -6, -6);
  Canvas.Font.Color := $0090A0A0;
//  R := Rect(2, 2, Width-2, Height-2);
    InflateRect(R, -4, 0);
  if FGlyph.Graphic <> nil then
  begin
    FGlyph.Graphic.Transparent := True;
    Canvas.Draw(R.Left + 3, (Height - FGlyph.Height) div 2 + R.Top - 2, FGlyph.Graphic);
    Inc(R.Left, FGlyph.Width + 3);
  end else
  begin
    if (Action <> nil) and (ImageList <> nil) and (TAction(Action).ImageIndex > - 1) then
    begin
      ImageList.Draw(Canvas, R.Left, (Height - ImageList.Height) div 2 + R.Top,
        TAction(Action).ImageIndex, Enabled);
    end;
  end;
  Canvas.Brush.Style := bsClear;
  Flags := DT_SINGLELINE or DT_CENTER or DT_VCENTER or DT_END_ELLIPSIS;
  RenderText(Self, Canvas, Caption, Font, False, True, R, Flags);
 end;
end;

procedure TXPButton.SetImageList(const Value: TImageList);
begin
  FImageList := Value;
end;

function TXPButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TXPButtonActionLink;
end;

{ TGradient }

constructor TGradient.Create(AOwner: TControl);
begin
  inherited Create;
  Parent := AOwner;
  Bitmap := TBitmap.Create;
  FDithered := True;
  FColorSteps := 16;
  FEnabled := True;
  FEndColor := clSilver;
  FStartColor := clGray;
  FXPGradientStyle := gsLeft;
end;

destructor TGradient.Destroy;
begin
  Bitmap.Free;
  inherited Destroy;
end;

procedure TGradient.RecreateBands;
begin
  if Assigned(Bitmap) then
    CreateGradientRect(Parent.Width, Parent.Height, FStartColor, FEndColor, FColorSteps, FXPGradientStyle, FDithered, Bitmap);
end;

procedure TGradient.SetDithered(NewDithered: Boolean);
begin
  if FDithered <> NewDithered then
  begin
    FDithered := NewDithered;
    RecreateBands;
    Parent.Invalidate;
  end;
end;

procedure TGradient.SetColorSteps(NewColorSteps: TColorSteps);
begin
  if FColorSteps <> NewColorSteps then
  begin
    FColorSteps := NewColorSteps;
    if FEnabled then
      RecreateBands;
    Parent.Invalidate;
  end;
end;

procedure TGradient.SetEnabled(NewEnabled: Boolean);
begin
  if FEnabled <> NewEnabled then
  begin
    FEnabled := NewEnabled;
    if FEnabled then
      RecreateBands;
    Parent.Invalidate;
  end;
end;

procedure TGradient.SetEndColor(NewEndColor: TColor);
begin
  if FEndColor <> NewEndColor then
  begin
    FEndColor := NewEndColor;
    if FEnabled then
      RecreateBands;
    Parent.Invalidate;
  end;
end;

procedure TGradient.SetXPGradientStyle(NewXPGradientStyle: TXPGradientStyle);
begin
  if FXPGradientStyle <> NewXPGradientStyle then
  begin
    FXPGradientStyle := NewXPGradientStyle;
    if FEnabled then
      RecreateBands;
    Parent.Invalidate;
  end;
end;

procedure TGradient.SetStartColor(NewStartColor: TColor);
begin
  if FStartColor <> NewStartColor then
  begin
    FStartColor := NewStartColor;
    if FEnabled then
      RecreateBands;
    Parent.Invalidate;
  end;
end;

procedure DrawLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer);
begin
  ACanvas.MoveTo(X1, Y1);
  ACanvas.LineTo(X2, Y2);
end;

procedure DrawBoundLines(ACanvas: TCanvas; ABoundLines: TBoundLines; const AColor: TColor; const R: TRect); overload;
begin
  with ACanvas do
  begin
    Pen.Color := AColor;
    if blLeft in ABoundLines then
      DrawLine(ACanvas, R.Left, R.Top, R.Left, R.Bottom - 1);
    if blTop in ABoundLines then
      DrawLine(ACanvas, R.Left, R.Top, R.Right, R.Top);
    if blRight in ABoundLines then
      DrawLine(ACanvas, R.Right - 1, R.Top, R.Right - 1, R.Bottom - 1);
    if blBottom in ABoundLines then
      DrawLine(ACanvas, R.Top, R.Bottom - 1, R.Right, R.Bottom - 1);
  end;
end;

procedure CreateGradientRect(Width, Height: Integer; StartColor, EndColor: TColor; ColorSteps: TColorSteps; Style: TXPGradientStyle; Dithered: Boolean; var Bitmap: TBitmap); overload;
type
  TGradientBand = array[0..255] of TColor;
  TRGBMap = packed record
    case boolean of
      True: (RGBVal: DWord);
      False: (R, G, B, D: Byte);
  end;
const
  DitherDepth = 16;
var
  iLoop, xLoop, yLoop: Integer;
  iBndS, iBndE: Integer;
  GBand: TGradientBand;
  procedure CalculateGradientBand;
  var
    rR, rG, rB: Real;
    lCol, hCol: TRGBMap;
    iStp: Integer;
  begin
    if Style in [gsLeft, gsTop] then
    begin
      lCol.RGBVal := ColorToRGB(StartColor);
      hCol.RGBVal := ColorToRGB(EndColor);
    end
    else
    begin
      lCol.RGBVal := ColorToRGB(EndColor);
      hCol.RGBVal := ColorToRGB(StartColor);
    end;
    rR := (hCol.R - lCol.R) / (ColorSteps - 1);
    rG := (hCol.G - lCol.G) / (ColorSteps - 1);
    rB := (hCol.B - lCol.B) / (ColorSteps - 1);
    for iStp := 0 to (ColorSteps - 1) do
      GBand[iStp] := RGB(
        lCol.R + Round(rR * iStp),
        lCol.G + Round(rG * iStp),
        lCol.B + Round(rB * iStp)
        );
  end;
begin
  Bitmap.Height := Height;
  Bitmap.Width := Width;
  CalculateGradientBand;
  with Bitmap.Canvas do
  begin
    Brush.Color := StartColor;
    FillRect(Bounds(0, 0, Width, Height));
    if Style in [gsLeft, gsRight] then
    begin
      for iLoop := 0 to ColorSteps - 1 do
      begin
        iBndS := MulDiv(iLoop, Width, ColorSteps);
        iBndE := MulDiv(iLoop + 1, Width, ColorSteps);
        Brush.Color := GBand[iLoop];
        PatBlt(Handle, iBndS, 0, iBndE, Height, PATCOPY);
        if (iLoop > 0) and (Dithered) then
          for yLoop := 0 to DitherDepth - 1 do
            for xLoop := 0 to Width div (ColorSteps - 1) do
              Pixels[iBndS + Random(xLoop), yLoop] := GBand[iLoop - 1];
      end;
      for yLoop := 1 to Height div DitherDepth do
        CopyRect(Bounds(0, yLoop * DitherDepth, Width, DitherDepth), Bitmap.Canvas, Bounds(0, 0, Width, DitherDepth));
    end
    else
    begin
      for iLoop := 0 to ColorSteps - 1 do
      begin
        iBndS := MulDiv(iLoop, Height, ColorSteps);
        iBndE := MulDiv(iLoop + 1, Height, ColorSteps);
        Brush.Color := GBand[iLoop];
        PatBlt(Handle, 0, iBndS, Width, iBndE, PATCOPY);
        if (iLoop > 0) and (Dithered) then
          for xLoop := 0 to DitherDepth - 1 do
            for yLoop := 0 to Height div (ColorSteps - 1) do
              Pixels[xLoop, iBndS + Random(yLoop)] := GBand[iLoop - 1];
      end;
      for xLoop := 0 to Width div DitherDepth do
        CopyRect(Bounds(xLoop * DitherDepth, 0, DitherDepth, Height), Bitmap.Canvas, Bounds(0, 0, DitherDepth, Height));
    end;
  end;
end;

procedure RenderText(Parent: TControl; Canvas: TCanvas; AText: string; AFont: TFont; Enabled, ShowAccelChar: Boolean; var Rect: TRect; Flags: Integer); overload;
begin
  if (Flags and DT_CALCRECT <> 0) and ((AText = '') or ShowAccelChar and (AText[1] = '&') and (AText[2] = #0)) then
    AText := AText + ' ';
  if not ShowAccelChar then
    Flags := Flags or DT_NOPREFIX;
  Flags := Parent.DrawTextBiDiModeFlags(Flags);
  with Canvas do
  begin
    Font.Assign(AFont);
    if not Enabled then
    begin
      Font.Color := $0090A0A0;
      DrawText(Handle, PChar(AText), -1, Rect, Flags);
    end
    else
      DrawText(Handle, PChar(AText), -1, Rect, Flags);
  end;
end;

{ TXPButtonActionLink }

procedure TXPButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited;
  FClient := AClient as TXPButton;
end;

function TXPButtonActionLink.IsCheckedLinked: Boolean;
begin
{  Result := inherited IsCheckedLinked and
    (FClient.Checked = (Action as TCustomAction).Checked);}
  Result := False;
end;

procedure TXPButtonActionLink.SetChecked(Value: Boolean);
begin
  inherited;
{  if IsCheckedLinked then
  begin
    FClient.ClicksDisabled := True;
    try
      FClient.Checked := Value;
    finally
      FClient.ClicksDisabled := False;
    end;
  end;}
end;

end.
