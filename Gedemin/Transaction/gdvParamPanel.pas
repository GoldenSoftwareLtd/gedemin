unit gdvParamPanel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TOrigin = (oTop, oLeft, oCenter, oLeftUpper, oRightUpper,
    oRightLower, oLeftLower);

type
  TSteps = 1..65535;

const
  DefFromColor = clBlue;
  DefToColor = $00200000; { dark, dark blue }
  DefSteps = 64;
  DefOrigin = oTop;

type
  TgdvParamScrolBox = class(TScrollBox)
  protected
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
  end;

  TgdvParamPanel = class(TPanel)
  private
    FUnwraped: Boolean;
    FWrapping: Boolean;
    FCaptionHeight: Integer;
    FUnwrapedHeight: Integer;
    FVerticalOffset: Integer;
    FHorisontalOffset: Integer;
    FFillColor: TColor;
    FStripeOdd: TColor;
    FOrigin: TOrigin;
    FSteps: TSteps;
    FStripeEven: TColor;
    procedure SetUnwraped(const Value: Boolean);
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure SetHorisontalOffset(const Value: Integer);
    procedure SetVerticalOffset(const Value: Integer);
    procedure SetFillColor(const Value: TColor);
    procedure SetOrigin(const Value: TOrigin);
    procedure SetSteps(const Value: TSteps);
    procedure SetStripeOdd(const Value: TColor);
    procedure SetStripeEven(const Value: TColor);
  protected
    { Protected declarations }
    function HeaderHeight: Integer;
    function GetClientRect: TRect; override;
    procedure Paint; override;
    function PntInCaption(Pont: TPoint): boolean;
    function PntInButton(Point: TPoint): boolean;
    function GetButtonRect: TRect;
    function GetCaptionTextRect: TRect;

    procedure UpdateCaptionBounds;
    procedure SetParent(AParent: TWinControl); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure AdjustClientRect(var ARect: TRect); override;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure UpdateHeight(Value: Integer);
    procedure GetTabOrderList(List: TList); override;
  published
    { Published declarations }
    property Unwraped: Boolean read FUnwraped write SetUnwraped;
    property HorisontalOffset: Integer read FHorisontalOffset write SetHorisontalOffset;
    property VerticalOffset: Integer read FVerticalOffset write SetVerticalOffset;
    property FillColor: TColor read FFillColor write SetFillColor
      default DefFromColor;
    property StripeOdd: TColor read FStripeOdd write SetStripeOdd
      default DefToColor;
    property StripeEven: TColor read FStripeEven write SetStripeEven;
    property Steps: TSteps read FSteps write SetSteps
      default DefSteps;
    property Origin: TOrigin read FOrigin write SetOrigin
      default DefOrigin;
  end;

procedure Register;

const
  cMinUnwrapedHeight = 30;
implementation
uses Math;
{$R *.RES}
const
  cExtraSpace = 2;

type
  TCrackWinControl = class(TWinControl)
  end;

procedure Register;
begin
  RegisterComponents('Standard', [TgdvParamPanel, TgdvParamScrolBox]);
end;


procedure GradientFill(Canvas: TCanvas; ARect: TRect; FromColor, ToColor: TColor;
  Origin: TOrigin; Steps: TSteps);
var
  From, LTo: Longint;
  FromR, FromG, FromB, DeltaR, DeltaG, DeltaB: Integer;
  I: Word;
  DeltaY, DeltaX: Integer;
  R: TRect;
  Height, Width: Integer;
begin
  From := ColorToRGB(FromColor);
  LTo := ColorToRGB(ToColor);
  FromR := GetRValue(From);
  FromG := GetGValue(From);
  FromB := GetBValue(From);
  DeltaR := GetRValue(LTo) - FromR;
  DeltaG := GetGValue(LTo) - FromG;
  DeltaB := GetBValue(LTo) - FromB;
  Height := ARect.Bottom - ARect.Top;
  Width := ARect.Right - ARect.Left;

  Canvas.Brush.Style := bsSolid;

  case Origin of
  oTop:
    with Canvas do
    begin
      DeltaY := (Height div Steps) + 1;
      for I := 0 to Steps do
      begin
        R := Rect(ARect.Left, DeltaY * I + ARect.Top, Width, DeltaY * (I + 1));
        Brush.Color := RGB(MulDiv(DeltaR, I, Steps) + FromR,
          MulDiv(DeltaG, I, Steps) + FromG, MulDiv(DeltaB, I, Steps) + FromB);
        FillRect(R);
      end;
    end;

  oLeft:
    with Canvas do
    begin
      DeltaX := (Width div Steps) + 1;
      for I := 0 to Steps do
      begin
        R := Rect(DeltaX * I + ARect.Left, ARect.Top, DeltaX * (I + 1) + ARect.Left, ARect.Top + Height);
        R.Right := Min(R.Right, ARect.Right);
        Brush.Color := RGB(MulDiv(DeltaR, I, Steps) + FromR,
          MulDiv(DeltaG, I, Steps) + FromG, MulDiv(DeltaB, I, Steps) + FromB);
        FillRect(R);
        if R.Right = ARect.Right then
          Exit;
      end;
    end;

  oLeftUpper, oLeftLower, oRightUpper, oRightLower:
    with Canvas do
    begin
      DeltaX := (Width div Steps) + 1;
      DeltaY := (Height div Steps) + 1;

      for I := 0 to Steps do
      begin
        Brush.Color := RGB(MulDiv(DeltaR, I, Steps) + FromR,
          MulDiv(DeltaG, I, Steps) + FromG, MulDiv(DeltaB, I, Steps) + FromB);
        case Origin of
          oLeftUpper:
            R := Rect(DeltaX * I + Arect.Left, DeltaY * I + ARect.Top, DeltaX * (I + 1), Height);
          oRightUpper:
            R := Rect(Width - DeltaX * (I + 1)+ Arect.Left, DeltaY * I + ARect.Top, Width - DeltaX * I, Height);
          oRightLower:
            R := Rect(Width - DeltaX * (I + 1) + Arect.Left, ARect.Top, Width - DeltaX * I, Height - DeltaY * I);
          oLeftLower:
            R := Rect(DeltaX * I + ARect.Left, ARect.Top, DeltaX * (I + 1), Height - DeltaY * I);
        end;
        FillRect(R);
        case Origin of
          oLeftUpper:
            R := Rect(DeltaX * (I + 1) + ARect.Left, DeltaY * I + ARect.Top, Width, DeltaY * (I + 1));
          oRightUpper:
            R := Rect(ARect.Left, DeltaY * I + ARect.Top, Width - DeltaX * (I + 1), DeltaY * (I + 1));
          oRightLower:
            R := Rect(ARect.Left, Height - DeltaY * (I + 1) + ARect.Top, Width - DeltaX * (I + 1),
              Height - DeltaY * I);
          oLeftLower:
            R := Rect(DeltaX * (I + 1) + ARect.Left, Height - DeltaY * (I + 1) + ARect.Top, Width,
              Height - DeltaY * I);
        end;
        FillRect(R);
      end;
    end;

  oCenter:
    with Canvas do
    begin
      DeltaX := (Width div ((Steps + 1) * 2));
      DeltaY := (Height div ((Steps + 1) * 2));
      for I := 0 to Steps do
      begin
        R := Rect(DeltaX * I + ARect.Left, DeltaY * I +  ARect.Top, Width - DeltaX * I, Height - DeltaY * I);
        Brush.Color := RGB(MulDiv(DeltaR, I, Steps) + FromR,
          MulDiv(DeltaG, I, Steps) + FromG, MulDiv(DeltaB, I, Steps) + FromB);
        FillRect(R);
      end;
    end;
  end;
end;
{ TgdvParamPanel }

procedure TgdvParamPanel.AdjustClientRect(var ARect: TRect);
begin
  ARect := GetClientRect;
end;

function TgdvParamPanel.CanAutoSize(var NewWidth,
  NewHeight: Integer): Boolean;
begin
  Result := FUnwraped and inherited CanAutoSize(NewWidth, NewHeight)
end;

procedure TgdvParamPanel.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateCaptionBounds;
end;

procedure TgdvParamPanel.CMTextChanged(var Message: TMessage);
begin
  inherited;
  UpdateCaptionBounds;
end;

procedure TgdvParamPanel.CNKeyDown(var Message: TWMKeyDown);
var
  C: TWinControl;
  L: TList;
  P: TWinControl;
begin
  if not FUnwraped and (Message.CharCode = VK_TAB) and Focused then
  begin
    if Parent <> nil then
    begin
      P := Parent;
      while P.Parent <> nil do
        P := P.Parent;

      if P <> nil then
      begin
        L := TList.Create;
        try
          GetTabOrderList(L);
          C := TCrackWinControl(P).FindNextControl(Self, GetKeyState(VK_SHIFT) >= 0,
            True, False);
          while (C <> Self) and (L.IndexOf(C) > - 1) do
          begin
            C := TCrackWinControl(P).FindNextControl(C, GetKeyState(VK_SHIFT) >= 0,
              True, False);
          end;
          if C <> nil then
            C.SetFocus;
        finally
          L.Free;
        end;
      end;
    end;
  end else
    inherited;
end;

constructor TgdvParamPanel.Create(AOwner: TComponent);
begin
  inherited;
  FUnwraped := True;
  FUnwrapedHeight := Height;
  FSteps := 64;
  FOrigin := oLeft;
  FFillColor := Color;
  FStripeOdd := PaletteRGB(168, 186, 212);
  FStripeEven := PaletteRGB(234, 239, 244);
end;

function TgdvParamPanel.GetButtonRect: TRect;
begin
  Result.Left := Width - FHorisontalOffset - cExtraSpace * 2 - HeaderHeight;
  Result.Top := FVerticalOffset;
  Result.Bottom := Result.Top + HeaderHeight;
  Result.Right := Result.Left + HeaderHeight;
end;

function TgdvParamPanel.GetCaptionTextRect: TRect;
var
  R: TRect;
begin
  R := GetButtonRect;
  Result.Left := FHorisontalOffset + cExtraSpace;
  Result.Top := FVerticalOffset + cExtraSpace;
  Result.Bottom := Result.Top + HeaderHeight;
  Result.Right := R.Left - cExtraSpace;
end;

function TgdvParamPanel.GetClientRect: TRect;
begin
  Result := Rect(0, 0, Width, Height);
  Result.Top := Result.Top + HeaderHeight + FVerticalOffset;
  if (FUnwraped) then
  begin
    Result.Left := Result.Left + 1 + FHorisontalOffset;
    Result.Right := Result.Right - 1 - FHorisontalOffset;
    Result.Bottom := Result.Bottom - 1 - FVerticalOffset;
  end else
    Result.Bottom := Result.Top;
end;

procedure TgdvParamPanel.GetTabOrderList(List: TList);
begin
  if FUnwraped then
  begin
    inherited GetTabOrderList(List);
  end;
end;

function TgdvParamPanel.HeaderHeight: Integer;
begin
  Result := FCaptionHeight + 2 * cExtraSpace;
end;

procedure TgdvParamPanel.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Focused and (Key = VK_SPACE) then
    SetUnwraped(not FUnwraped);
end;

procedure TgdvParamPanel.Paint;
var
  R, aR: TRect;
  Q, I: Integer;
  BitMap: TBitMap;
  W: Integer;
  S, S1: string;
begin
  R := Rect(0, 0, Width, Height);
  Canvas.Brush.Color := Color;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(R);
  R.Top := R.Top + FVerticalOffset;
  R.Bottom := R.Bottom - FVerticalOffset;
  R.Left := R.Left + FHorisontalOffset;
  R.Right := R.Right - FHorisontalOffset;

  R.Bottom := R.Top + HeaderHeight;

  Q := Trunc(HeaderHeight  / 3);
  for I := 0 to Q do
  begin
    aR := Rect(R.Left, R.Top + I * 3, R.Right, R.Top + I * 3 + 2);
    aR.Bottom := Min(aR.Bottom, R.Bottom);
    GradientFill(Canvas, aR, Color, FStripeOdd, FOrigin, FSteps);
    if aR.Bottom >= R.Bottom then Break;
    aR.Top := aR.Top + 2;
    aR.Bottom := aR.Bottom + 1;
    aR.Bottom := Min(aR.Bottom, R.Bottom);
    GradientFill(Canvas, aR, Color, FStripeEven, FOrigin, FSteps);
    if aR.Bottom >= R.Bottom then Break;
  end;

  Canvas.MoveTo(R.Left, R.Bottom - 2);
  Canvas.Pen.Color := clBtnShadow;
  Canvas.LineTo(R.Right, R.Bottom - 2);
  Canvas.MoveTo(R.Left, R.Bottom -1);
  Canvas.Pen.Color := FStripeEven;
  Canvas.LineTo(R.Right, R.Bottom -1);

  Canvas.Font.Assign(Font);
  Canvas.Brush.Style := bsClear;

  R := GetCaptionTextRect;
  W := R.Right - R.Left;
  S := Caption;
  S1 := S;
  while (W < Canvas.TextWidth(S)) and (S > '') do
  begin
    SetLength(S1, Length(S1) - 1);
    S := S1 + '...';
  end;

  Canvas.TextRect(R, R.Left, R.Top, S);

  R := GetClientRect;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FFillColor;
  Canvas.FillRect(R);

  R := GetButtonRect;
  if Focused then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := clBtnShadow;
    Canvas.FrameRect(R);
  end;

  BitMap := TBitMap.Create;
  try
    BitMap.Transparent := True;
    BitMap.TransparentMode := tmAuto;
    if FUnwraped then
    begin
      BitMap.LoadFromResourceName(HInstance, 'CLOSEPANEL');
    end else
    begin
      BitMap.LoadFromResourceName(HInstance, 'OPENPANEL');
    end;
    Canvas.Draw(R.Left + 1, R.Top + 1, BitMap);
  finally
    BitMap.Free;
  end;
end;

function TgdvParamPanel.PntInButton(Point: TPoint): boolean;
var
  R: TRect;
begin
  R := GetButtonRect;
  Result := PtInRect(R, Point);
end;

function TgdvParamPanel.PntInCaption(Pont: TPoint): Boolean;
var
  R: TRect;
begin
  R := GetCaptionTextRect;
  Result := PtInRect(R, Pont);
end;

procedure TgdvParamPanel.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if csLoading in ComponentState then
    FUnwrapedHeight := AHeight;

  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TgdvParamPanel.SetFillColor(const Value: TColor);
begin
  if FFillColor <> Value then
  begin
    FFillColor := Value;
    Invalidate;
  end;
end;

procedure TgdvParamPanel.SetHorisontalOffset(const Value: Integer);
begin
  if FHorisontalOffset <> Value then
  begin
    FHorisontalOffset := Value;
    Realign;
    Repaint;
  end;
end;

procedure TgdvParamPanel.SetOrigin(const Value: TOrigin);
begin
  if FOrigin <> Value then
  begin
    FOrigin := Value;
    Invalidate;
  end;
end;

procedure TgdvParamPanel.SetParent(AParent: TWinControl);
begin
  inherited;
  if AParent <> nil then
    UpdateCaptionBounds;
end;

procedure TgdvParamPanel.SetSteps(const Value: TSteps);
begin
  if FSteps <> Value then
  begin
    FSteps := Value;
    Invalidate;
  end;  
end;

procedure TgdvParamPanel.SetStripeEven(const Value: TColor);
begin
  if FStripeEven <> Value then
  begin
    FStripeEven := Value;
    Invalidate;
  end;  
end;

procedure TgdvParamPanel.SetStripeOdd(const Value: TColor);
begin
  if FStripeOdd <> Value then
  begin
    FStripeOdd := Value;
    Invalidate;
  end;
end;

procedure TgdvParamPanel.SetUnwraped(const Value: Boolean);
begin
  FUnwraped := Value;

  FWrapping := True;
  try
    if not Value then
    begin
      FUnwrapedHeight := Height;

      if IsChild(Handle, Windows.GetFocus) then
        SetFocus;

      Height := HeaderHeight + 1;
    end else
    begin
      Height := Max(FUnwrapedHeight, cMinUnwrapedHeight);
    end;
  finally
    FWrapping := False;
  end;
end;

procedure TgdvParamPanel.SetVerticalOffset(const Value: Integer);
begin
  if FVerticalOffset <> Value then
  begin
    FVerticalOffset := Value;
    Realign;
    Repaint;
  end;  
end;

procedure TgdvParamPanel.UpdateCaptionBounds;
begin
  if Parent <> nil then
  begin
    FCaptionHeight := Canvas.TextHeight('Lp');
  end;
end;

procedure TgdvParamPanel.UpdateHeight(Value: Integer);
begin
  if FUnwraped then
    Height := Value
  else
    FUnwrapedHeight := Value;
end;

procedure TgdvParamPanel.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

procedure TgdvParamPanel.WMLButtonUp(var Message: TWMLButtonUp);
begin
  if PntInButton(Point(Message.XPos, Message.YPos)) then
  begin
    SetUnwraped(not FUnwraped);
  end;
  inherited;
end;

procedure TgdvParamPanel.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if PntInButton(Point(Message.XPos, Message.YPos)) then
  begin
    if Cursor <> crHandPoint then
      Cursor := crHandPoint;
  end else
  begin
    if Cursor <> crDefault then
      Cursor := crDefault;
  end;
end;

procedure TgdvParamPanel.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
end;

{ TgdvParamScrolBox }

procedure TgdvParamScrolBox.AlignControls(AControl: TControl;
  var ARect: TRect);
begin
  inherited AlignControls(nil, ARect);
end;

end.
