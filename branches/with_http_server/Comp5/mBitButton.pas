
{

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    mBitButton.pas

  Abstract

    visual Component - Button with flat interface (like buttons from Microsoft Money)

  Author

    Alex Tsobkalo (December-1998)

  Revisions history

    15-Dec-98  Initial Version (without ability to represent images)
    2_-Dec-98  Change the principle of component's work when the mouse is over it
    10-Jan-99  Ability to represent images was added. Now the component can rep-
               resent up to three images:
                first - when Enabled = True, but mouse is not over it.
               second - when Enabled = True and mouse is over it.
                third - when Enabled = False.

}

unit mBitButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, extctrls;

const
  { Defaults Colors }
  DefLightLiter = $FFFFFF;
  DefLowLiter   = $000000;
  DefLightBkgr  = $94A5A5;
  DefLowBkgr    = $000000;
  DefFocusRect  = $6E6E6E;
  DefFrame      = $000000;
  DefUnEnabled  = $707070;
  { Defaults Sizes }
  DefHeight = 21;
  DefWidth  = 76;

type
  { Custom Types }
  BorderStyleType = (bstNone, bstSingle);
  LayOutType      = (tlTop, tlCenter, tlBottom);
  TGlyphLayout    = (blGlyphLeft, blGlyphRight, blGlyphTop, blGlyphBottom);

{ TmBitButton }
  TmBitButton = class(TCustomControl)
  private                
    FAlignment          : TAlignment;
    FColorLightLiter    : TColor;
    FColorLightBkgr     : TColor;
    FColorLowLiter      : TColor;
    FColorLowBkgr       : TColor;
    FColorFrame         : TColor;
    FColorFocusRect     : TColor;
    FColorUnEnabledLiter: TColor;
    FMouseHere          : Boolean;
    FBorderStyle        : BorderStyleType;
    FMouseDown          : Boolean;
    FFocused            : Boolean;
    FKeyDown            : Boolean;
    Flag                : Boolean;
    FModalResult        : TModalResult;
    FLayOut             : LayOutType;
    FActive             : Boolean;
    FDefault            : Boolean;
    FCancel             : Boolean;

    FGlyph              : TBitMap;
    CurrentGlyph        : TBitMap;
    FNumGlyphs          : Byte;
    FSpacing            : Integer;
    FMargin             : Integer;
    FGlyphLayOut        : TGlyphLayOut;
    GlyphNumber         : Byte;

    procedure SetAlignment(Value: TAlignment);
    procedure SetColorFrame(const Value: TColor);
    procedure SetColorLowLiter(const Value: TColor);
    procedure SetColorLightBkgr(const Value: TColor);
    procedure SetBorderStyle(const Value: BorderStyleType);
    procedure SetDefault(const Value: Boolean);
    procedure SetCancel(const Value: Boolean);
    procedure SetLayOut(const Value: LayOutType);
    procedure SetActive(AnActive: Boolean);

    { Mouse Events }
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk);
      message WM_LBUTTONDBLCLK;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMRButtonUp(var Message: TWMRButtonUp);
      message WM_RBUTTONUP;
    { Kbd Events }
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp);
      message WM_KEYUP;

    procedure CMDialogKey(var Message: TCMDialogKey);
      message CM_DIALOGKEY;
    procedure CMDialogChar(var Message: TCMDialogChar);
      message CM_DIALOGCHAR;
    procedure CNCommand(var Message: TWMCommand);
      message CN_COMMAND;
    procedure CMFocusChanged(var Message: TCMFocusChanged);
      message CM_FOCUSCHANGED;
    procedure CMEnabledChanged(var Message: TMessage);
      message CM_ENABLEDCHANGED;
    procedure CMEnter(var Message: TCMEnter);
      message CM_ENTER;
    procedure CMExit(var Message: TCMExit);
      message CM_EXIT;
    procedure CMMouseEnter(var Message: TMessage);
      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;
    procedure WMKILLFOCUS(var Message: TWMKILLFOCUS);
      message WM_KILLFOCUS;
    procedure WMSETFOCUS(var Message: TWMSETFOCUS);
      message WM_SETFOCUS;


    property Active: Boolean read FActive write SetActive;

    procedure SetGlyph(const Value: TBitMap);
    procedure SetMargin(const Value: Integer);
    procedure SetSpacing(const Value: Integer);
    procedure SetGlyphLayOut(const Value: TGlyphLayout);
    procedure SetNumGlyphs(const Value: Byte);
    function GetCaption: TCaption;
    procedure SetCaption(const Value: TCaption);
    procedure SetColorUnEnabledLiter(const Value: TColor);

  protected
    procedure Paint; override;
    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    function ShowGlyph: TRect;
    procedure ShowCaption;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Click; override;
    
  published
    property Align;
    property Alignment: TAlignment read FAlignment write SetAlignment
      default taCenter;
    property Anchors;
    property Height default DefHeight;
    property Width default DefWidth;
    property BorderStyle: BorderStyleType read FBorderStyle write SetBorderStyle
      default bstSingle;

    property Caption: TCaption read GetCaption write SetCaption;

    property ColorFrame: TColor read FColorFrame write SetColorFrame
      default DefFrame;
    property ColorLightLiter: TColor read FColorLightLiter write FColorLightLiter
      default DefLightLiter;
    property ColorLightBkgr: TColor read FColorLightBkgr write SetColorLightBkgr
      default DefLightBkgr;
    property ColorLowLiter: TColor read FColorLowLiter write SetColorLowLiter
      default DefLowLiter;
    property ColorLowBkgr: TColor read FColorLowBkgr write FColorLowBkgr
      default DefLowBkgr;
    property ColorFocusRect: TColor read FColorFocusRect write FColorFocusRect
      default DefFocusRect;
    property ColorUnEnabledLiter: TColor read FColorUnEnabledLiter write SetColorUnEnabledLiter
      default DefUnEnabled;

    property Glyph: TBitMap read FGlyph write SetGlyph;
    property GlyphLayout: TGlyphLayout read FGlyphLayout write SetGlyphLayOut
      default blGlyphLeft;
    property NumGlyphs: Byte read FNumGlyphs write SetNumGlyphs
      default 1;
    property Margin: Integer read FMargin write SetMargin
      default -1;
    property Spacing: Integer read FSpacing write SetSpacing
      default 4;

    property ModalResult: TModalResult read FModalResult write FModalResult default 0;
    property Action;
    property Enabled;
    property LayOut: LayOutType read FLayOut write SetLayOut
      default tlCenter;
    property Default: Boolean read FDefault write SetDefault
      default False;
    property Cancel: Boolean read FCancel write SetCancel
      default False;

    property Constraints;
    property Font;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnClick;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('x-Button', [TmBitButton]);
end;


//   CREATE
constructor TmBitButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FAlignment := taCenter;
  TabStop := True;
  FLayOut := tlCenter;
  Enabled := True;
  Height := DefHeight;
  Width := DefWidth;

  Flag := True;
  FModalResult := 0;

  FMouseDown := False;
  FKeyDown := False;
  FDefault := False;
  FCancel := False;

  FColorLightLiter := DefLightLiter;
  SetColorLowLiter(DefLowLiter);
  FColorLowBkgr := DefLowBkgr;
  SetColorLightBkgr(DefLightBkgr);
  Color := FColorlightBkgr;

  FColorFrame := DefFrame;
  FColorFocusRect := DefFocusRect;
  FColorUnEnabledLiter := DefUnEnabled;

  Font.Color := FColorLowLiter;
  FBorderStyle := bstSingle;

  FGlyph := TBitMap.Create;
  CurrentGlyph := TBitMap.Create;
  FGlyphLayout := blGlyphLeft;
  FNumGlyphs := 1;
  GlyphNumber := 1;
  FMargin := -1;
  FSpacing := 4;

  // шрифт по умолчанию
  Font.Name := 'Tahoma';
  Font.Style := [];
  Font.CharSet := RUSSIAN_CHARSET;
end;


//   DESTROY
destructor TmBitButton.Destroy;
begin
  inherited Destroy;
  FGlyph.Free;
  CurrentGlyph.Free;
end;


//   SET_ALIGNMENT
procedure TmBitButton.SetAlignment(Value: TAlignment);
begin
  if Value <> FAlignment then
  begin
    FAlignment := Value;
    Invalidate;
  end;
end;


//   SET_BORDER_STYLE
procedure TmBitButton.SetBorderStyle(const Value: BorderStyleType);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    Repaint;
  end;
end;


//   SET_COLOR_FRAME
procedure TmBitButton.SetColorFrame(const Value: TColor);
begin
  if Value <> FColorFrame then
  begin
    FColorFrame := Value;
    Repaint;
  end;
end;


//   SET_COLOR_LOW_LITER
procedure TmBitButton.SetColorLowLiter(const Value: TColor);
begin
  if Value <> FColorLowLiter then
  begin
    FColorLowLiter := Value;
    Font.Color := FColorLowLiter;
    Repaint;
  end;
end;


//   SET_COLOR_LIGHT_BKGR
procedure TmBitButton.SetColorLightBkgr(const Value: TColor);
begin
  if Value <> FColorLightBkgr then
  begin
    FColorLightBkgr := Value;
    Color := FColorLightBkgr;
    Repaint;
  end;
end;


//   SET_COLOR_UN_ENABLED_LITER
procedure TmBitButton.SetColorUnEnabledLiter(const Value: TColor);
begin
{  if FColorUnEnabledLiter := Value then
  begin
    FColorUnEnabledLiter := Value;
    Invalidate;
  end;}  
end;


//   PAINT
procedure TmBitButton.Paint;
begin
  Canvas.Font := Font;

  if not Enabled then
    Canvas.Font.Color := FColorUnEnabledLiter;

  with Canvas do
  begin
    Pen.Color := FColorFrame;
    Brush.Color := Color;
    Brush.Style := bsSolid;

    { рассчитываем данные для показа картинки }
    if (Font.Color = ColorLightLiter) and (FNumGlyphs > 1) then
      GlyphNumber := 2;

    if (Font.Color = ColorLowLiter) and (FNumGlyphs > 0) then
      GlyphNumber := 1;

    if not Enabled then
      if FNumGlyphs > 2 then
        GlyphNumber := 3
      else
        GlyphNumber := 1;

    { показываем надпись и картинку }    
    ShowCaption;

    { обрисовываем кнопку }
    case BorderStyle of
    bstNone: FillRect(ClientRect);
    bstSingle:
      begin
        if (Default and Enabled and Active) or (Focused and Enabled) then
        begin
          Pen.Width := 2;
          Rectangle(1, 1, Width, Height);
        end
        else begin
          Pen.Width := 1;
          Rectangle(0, 0, Width, Height);
        end;
      end;
    end;

    { показываем фокусный прямоугольник в самом конце, чтобы рисовался по верх всего }
    if Enabled then
      if Focused then
      begin
        Brush.Style := bsClear;
        Pen.Color := FColorFocusRect;
        Pen.Width := 1;
        Rectangle(3, 3, Width - 3, Height - 3);
      end;
  end;
end;


//   WM_KEY_DOWN
procedure TmBitButton.WMKeyDown(var Message: TWMKeyDown);
begin
  if (not Enabled) or FKeyDown then
    exit;

  with Message do
    if (CharCode = 32) and Flag then
    begin
      FKeyDown := True;
      Font.Color := FColorLightLiter;
      Color := FColorLowBkgr;
    end;

  inherited;
end;


//   WM_KEY_UP
procedure TmBitButton.WMKeyUp(var Message: TWMKeyUp);
begin
  if not Enabled then
    exit;

  with Message do
    if CharCode = 32 then begin
      Font.Color := FColorLowLiter;
      Color := FColorLightBkgr;
      Flag := True;
      FMouseDown := False;
      if FKeyDown or FMouseHere then
      begin
        FKeyDown := False;
        Invalidate;
        Click;
      end;
    end;

  inherited;
end;


//   WM_L_BUTTON_DOWN
procedure TmBitButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if (not FMouseHere) or (not Enabled) then
    exit;

  FMouseDown := True;
  Color := FColorLowBkgr;
  if (not FFocused) and TabStop then
    SetFocus;

  inherited;
end;


//   WM_L_BUTTON_UP
procedure TmBitButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  FMouseDown := False;
  Color := FColorLightBkgr;
  Font.Color := FColorLowLiter;
  inherited;
  SetDefault(FDefault);
end;


//   WM_L_BUTTON_DBL_CLK
procedure TmBitButton.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  WMLButtonDown(Message);
end;


//   WM_R_BUTTON_UP
procedure TmBitButton.WMRButtonUp(var Message: TWMRButtonUp);
begin
  Color := FColorLightBkgr;
  Font.Color := FColorLowLiter;
  inherited;
end;


//   CM_MOUSE_ENTER
procedure TmBitButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Enabled and (GetCapture = 0) then
  begin
    FMouseHere := True;
    Font.Color := FColorLightLiter;
  end;
end;


//   CM_MOUSE_LEAVE
procedure TmBitButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FMouseHere and Enabled then
  begin
    FMouseHere := False;
    Color := FColorLightBkgr;
    if FMouseDown then 
      Font.Color := FColorLightLiter
    else 
      Font.Color := FColorLowLiter;
  end
end;


//   WM_KILL_FOCUS
procedure TmBitButton.WMKILLFOCUS(var Message: TWMKILLFOCUS);
begin
  inherited;
  Invalidate;
end;


//   WM_SET_FOCUS
procedure TmBitButton.WMSETFOCUS(var Message: TWMSETFOCUS);
begin
  inherited;
  Invalidate;
end;


//   WM_MOUSE_MOVE
procedure TmBitButton.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  
  if not Enabled then
    exit;

  if FKeyDown then
  begin
    FKeyDown := False;
    FMouseDown := True;
    Flag := False;
  end;

  with Message do
    if (XPos >= 0) and (XPos < ClientWidth) and (YPos >= 0) and (YPos <= ClientHeight) then begin
      if not FMouseHere then FMouseHere := True;
      Font.Color := FColorLightLiter;
      if FMouseDown then Color := FColorLowBkgr
      else Color := FColorLightBkgr;
    end
    else begin
      Color := FColorLightBkgr;
      if FMouseDown then Font.Color := FColorLightLiter
      else Font.Color := FColorLowLiter;
    end;
end;


//   CLICK
procedure TmBitButton.Click;
var
  Form: TCustomForm;
begin
  Invalidate;

  Form := GetParentForm(Self) as TForm;
  if Form <> nil then Form.ModalResult := FModalResult;

  inherited Click;
end;


//   CM_ENTER
procedure TmBitButton.CMEnter(var Message: TCMEnter);
begin
  FFocused := True;
  Invalidate;
end;


//   CM_EXIT
procedure TmBitButton.CMExit(var Message: TCMExit);
begin
  FFocused := False;
  FKeyDown := False;
  Color := FColorLightBkgr;
  Font.Color := FColorLowLiter;
  Invalidate;
end;


//   SET_DEFAULT
procedure TmBitButton.SetDefault(const Value: Boolean);
begin
  if FDefault <> Value then
  begin
    FDefault := Value;
    Invalidate;
  end;
  if HandleAllocated then
    with GetParentForm(Self) do
      Perform(CM_FOCUSCHANGED, 0, Longint(ActiveControl));
end;


//   SET_LAY_OUT
procedure TmBitButton.SetLayOut(const Value: LayOutType);
begin
  if FLayOut <> Value then begin
    FLayOut := Value;
    Invalidate;
  end;
end;


//   CREATE_PARAMS
procedure TmBitButton.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WindowClass.hbrBackground := 0;
end;


//  CREATE_WND
procedure TmBitButton.CreateWnd;
begin
  inherited CreateWnd;
  Active := FDefault;
end;


//   SET_CANCEL
procedure TmBitButton.SetCancel(const Value: Boolean);
begin
  if FCancel <> Value then
    FCancel := Value;
end;


//   SET_ACTIVE
procedure TmBitButton.SetActive(AnActive: Boolean);
begin
  if AnActive <> FActive then
    FActive := AnActive;
end;


//   CM_DIALOG_KEY
procedure TmBitButton.CMDialogKey(var Message: TCMDialogKey);
begin
  with Message do
  begin
    if  (((CharCode = VK_RETURN) and FActive) or
      ((CharCode = VK_ESCAPE) and FCancel)) and
      (KeyDataToShiftState(Message.KeyData) = []) and CanFocus then
    begin
      Click;
      Result := 1;
    end else
      inherited;
  end;
end;


//  CM_DIALOG_CHAR
procedure TmBitButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, Caption) and CanFocus then
    begin
      Click;
      Result := 1;
    end else
      inherited;
end;


//   CN_COMMAND
procedure TmBitButton.CNCommand(var Message: TWMCommand);
begin
  if Message.NotifyCode = BN_CLICKED then Click;
end;


//   CN_FOCUSE_CHANGED
procedure TmBitButton.CMFocusChanged(var Message: TCMFocusChanged);
begin
  with Message do
    if Sender is TmBitButton then
      Active := Sender = Self
    else
      Active := FDefault;

  Invalidate;
  inherited;
end;


//   CM_ENABLED_CHANGED
procedure TmBitButton.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  
  Font.Color := FColorLowLiter;
  Invalidate;
end;


//   SET_GLYPH
procedure TmBitButton.SetGlyph(const Value: TBitMap);
begin
  Invalidate;
  FGlyph.Assign(Value);
  if (Value <> nil) and (Value.Height > 0) then
  begin
    FGlyph.TransparentColor := Value.TransparentColor;
    if Value.Width mod Value.Height = 0 then
    begin
      FNumGlyphs := Value.Width div Value.Height;
      if FNumGlyphs > 3 then FNumGlyphs := 1;
    end;
  end
  else
    FNumGlyphs := 1;
end;


//   SHOW_CAPTION
procedure TmBitButton.ShowCaption;
var
  R: TRect;
  Hor, Ver: Integer;
  Ch: array [0..255] of Char;
begin
  Hor := 0;
  Ver := 0;

  if FGlyph.Empty then begin
    with Canvas do begin
      Brush.Style := bsClear;
      R := ClientRect;
      Dec(R.Right, 3);
      Inc(R.Left, 3);
      case FLayOut of
           tlTop: Ver := DT_TOP;
        tlCenter: Ver := DT_VCENTER;
        tlBottom: Ver := DT_BOTTOM;
      end;
      case Alignment of
         taLeftJustify: Hor := DT_LEFT;
              taCenter: Hor := DT_CENTER;
        taRightJustify: Hor := DT_RIGHT;
      end;

      DrawText (Canvas.Handle, StrPCopy(Ch, Caption), Length(Caption), R, Hor or Ver or DT_SINGLELINE);
    end;
  end
  else
    with Canvas do begin
      Brush.Style := bsClear;
      R := ClientRect;
      Dec(R.Right, 3);
      Inc(R.Left, 3);
      case FGlyphLayOut of
        blGlyphLeft:
          begin
            Hor := DT_LEFT;
            Ver := DT_VCENTER;
          end;
        blGlyphRight:
          begin
            Hor := DT_RIGHT;
            Ver := DT_VCENTER;
          end;
        blGlyphBottom:
          begin
            Hor := DT_CENTER;
            Ver := DT_BOTTOM;
          end;
        blGlyphTop:
          begin
            Hor := DT_CENTER;
            Ver := DT_TOP;
          end;
      end;

      R := ShowGlyph;

      DrawText (Canvas.Handle, StrPCopy(Ch, Caption), Length(Caption), R,
        Hor or Ver or DT_SINGLELINE);
    end;
end;


//   SHOW_GLYPH
function TmBitButton.ShowGlyph: TRect;
var
  X1, Y1, X2, Y2, Ys, Xs: Integer;
  destRect, sourRect: TRect;
begin
  Xs := Width div 2;
  Ys := Height div 2;

  CurrentGlyph.Width := FGlyph.Width div FNumGlyphs;
  CurrentGlyph.Height := FGlyph.Height;
  CurrentGlyph.TransparentColor := FGlyph.TransparentColor;

  destRect := Rect(0, 0, CurrentGlyph.Width, CurrentGlyph.Height);
  sourRect := Rect((GlyphNumber - 1) * CurrentGlyph.Width, 0,
    (GlyphNumber) * CurrentGlyph.Width, CurrentGlyph.Height);

  CurrentGlyph.Canvas.Brush.Color := Color;
  CurrentGlyph.Canvas.BrushCopy(destRect, FGlyph,
    sourRect, FGlyph.TransparentColor);

  if FMargin > -1 then
    case FGlyphLayOut of
      blGlyphLeft:
        begin
          Y1 := Ys - FGlyph.Height div 2;
          X1 := Margin;
          X2 := X1 + (FGlyph.Width div FNumGlyphs);
          Canvas.Draw(X1, Y1, CurrentGlyph);
          Result := Rect(X2 + FSpacing, 3, Width - 3, Height - 3);
        end;
      blGlyphRight:
        begin
          Y1 := Ys - FGlyph.Height div 2;
          X1 := Width - Margin - FGlyph.Width div FNumGlyphs;
          Canvas.Draw(X1, Y1, CurrentGlyph);
          Result := Rect(3, 3, X1 - FSpacing, Height - 3);
        end;
      blGlyphBottom:
        begin
          Y1 := Height - Margin - FGlyph.Height;
          X1 := Xs - (FGlyph.Width div FNumGlyphs) div 2;
          Canvas.Draw(X1, Y1, CurrentGlyph);
          Result := Rect(3, 3, Width - 3, Y1 - FSpacing);
        end;
      blGlyphTop:
        begin
          Y1 := Margin;
          Y2 := Margin + FGlyph.Height;
          X1 := Xs - (FGlyph.Width div FNumGlyphs) div 2;
          Canvas.Draw(X1, Y1, CurrentGlyph);
          Result := Rect(3, Y2 + FSpacing, Width - 3, Height - 3);
        end;
    end
  else
    case FGlyphLayOut of
      blGlyphLeft:
        begin
          Y1 := Ys - FGlyph.Height div 2;
          X1 := (Width - FGlyph.Width div FNumGlyphs -
            Canvas.TextWidth(Caption) - FSpacing) div 2;
          X2 := X1 + (FGlyph.Width div FNumGlyphs);
          Canvas.Draw(X1, Y1, CurrentGlyph);
          Result := Rect(X2 + FSpacing, 3, Width - 3, Height - 3);
        end;
      blGlyphRight:
        begin
          Y1 := Ys - FGlyph.Height div 2;
          X1 := Width - (Width - FGlyph.Width div FNumGlyphs -
            Canvas.TextWidth(Caption) - FSpacing) div 2 - FGlyph.Width div FNumGlyphs;
          Canvas.Draw(X1, Y1, CurrentGlyph);
          Result := Rect(3, 3, X1 - FSpacing, Height - 3);
        end;
      blGlyphBottom:
        begin
          Y1 := Height - (Height - FGlyph.Height - Canvas.TextHeight(Caption) -
            FSpacing) div 2 - FGlyph.Height;
          X1 := Xs - (FGlyph.Width div FNumGlyphs) div 2;
          Canvas.Draw(X1, Y1, CurrentGlyph);
          Result := Rect(3, 3, Width - 3, Y1 - FSpacing);
        end;
      blGlyphTop:
        begin
          Y1 := (Height - FGlyph.Height - Canvas.TextHeight(Caption) -
            FSpacing) div 2;
          Y2 := Y1 + FGlyph.Height;
          X1 := Xs - (FGlyph.Width div FNumGlyphs) div 2;
          Canvas.Draw(X1, Y1, CurrentGlyph);
          Result := Rect(3, Y2 + FSpacing, Width - 3, Height - 3);
        end;
    end;
end;


//   SET_MARGIN
procedure TmBitButton.SetMargin(const Value: Integer);
begin
  if (Value <> FMargin) and (Value >= -1) then
  begin
    FMargin := Value;
    Invalidate;
  end;
end;

//   SET_SPACING
procedure TmBitButton.SetSpacing(const Value: Integer);
begin
  if Value <> FSpacing then
  begin
    FSpacing := Value;
    Invalidate;
  end;
end;


//   SET_GLYPH_LAYOUT
procedure TmBitButton.SetGlyphLayOut(const Value: TGlyphLayout);
begin
  if FGlyphLayout <> Value then begin
    FGlyphLayout := Value;
    Invalidate;
  end;
end;


//   SET_NUM_GLYPHS
procedure TmBitButton.SetNumGlyphs(const Value: Byte);
begin
  if FNumGlyphs <> Value then begin
    FNumGlyphs := Value;
    Invalidate;
  end;
end;


//   GET_CAPTION
function TmBitButton.GetCaption: TCaption;
begin
  Result := inherited Caption;
end;


//   SET_CAPTION
procedure TmBitButton.SetCaption(const Value: TCaption);
begin
  inherited Caption := Value;
  Invalidate;
end;

end.
