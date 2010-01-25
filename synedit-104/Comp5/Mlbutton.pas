
{++

  Copyright (c) 1995-97 by Golden Software of Belarus

  Module

    mlbutton.pas

  Abstract

    Delphi visual component. A special button that
    allows caption text to be splitted into several lines
    (multi-line button).

  Author

    Andrei Kireev (22-Sep-95)

  Contact address

    goldsoft%swatogor.belpak.minsk.by@demos.su

  Revisions history

    1.00    25-Sep-95    andreik    Initial version.
    1.01    26-Sep-95    andreik    Minor change in the Paint method.
    1.02    27-Sep-95    andreik    Fixed bug with determining of number
                                    images in the glyph bitmap.
    1.03    30-Sep-95    andreik    Fixed bug with determining of GlyphWidth
                                    after component has been loaded.
    1.04    14-Oct-95    andreik    Win95 style lowered text for disabled button.
    1.05    16-Nov-95    andreik    Added response to CM_ENABLEDCHANGED message.
    1.06    13-Dec-95    andreik    Minor change.
    1.07    20-Oct-97    andreik    Ported to Delphi32.

--}

unit MLButton;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons;

type
  TCaptionAlign = (caLeft, caRight, caCenter);
  TBevelWidth = 1..1000;
  TSpacing = 0..1000;

const
  DefBevelWidth = 1;
  DefStyle = bsAutoDetect;
  DefCaptionAlign = caCenter;
  DefLayout = blGlyphTop;
  DefSpacing = 4;
  DefNumGlyphs = 1;
  DefRounded = True;
  DefCancel = False;
  DefDefault = False;
  DefModalResult = 0;
  DefWidth = 100;
  DefHeight = 60;

type
  TMLButton = class(TCustomControl)
  private
    FBevelWidth: TBevelWidth;
    FStyle: TButtonStyle;
    FCaption: TStringList;
    FCaptionAlign: TCaptionAlign;
    FGlyph: TBitmap;
    FLayout: TButtonLayout;
    FSpacing: TSpacing;
    FNumGlyphs: TNumGlyphs;
    FRounded: Boolean;
    FActive: Boolean;
    FDefault: Boolean;
    FCancel: Boolean;
    FModalResult: TModalResult;
    FDown: Boolean;
    GlyphWidth: Integer;
    KeyPressed: Boolean;

    procedure SetBevelWidth(ABevelWidth: TBevelWidth);
    procedure SetStyle(AStyle: TButtonStyle);
    procedure SetCaption(ACaption: TStringList);
    procedure SetCaptionAlign(ACaptionAlign: TCaptionAlign);
    procedure SetGlyph(AGlyph: TBitmap);
    procedure SetLayout(ALayout: TButtonLayout);
    procedure SetSpacing(ASpacing: TSpacing);
    procedure SetNumGlyphs(ANumGlyphs: TNumGlyphs);
    procedure SetRounded(ARounded: Boolean);
    procedure SetDefault(ADefault: Boolean);
    procedure SetActive(AnActive: Boolean);
    procedure SetDown(ADown: Boolean);

    procedure DrawGlyph(ACanvas: TCanvas; X, Y: Integer; GlyphNum: TNumGlyphs);

    procedure CMEnabledChanged(var Message: TMessage);
      message CM_ENABLEDCHANGED;

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp);
      message WM_KEYUP;
    procedure CMDialogKey(var Message: TCMDialogKey);
      message CM_DIALOGKEY;
    procedure CMDialogChar(var Message: TCMDialogChar);
      message CM_DIALOGCHAR;
    procedure CMFocusChanged(var Message: TCMFocusChanged);
      message CM_FOCUSCHANGED;
    procedure CNCommand(var Message: TWMCommand);
      message CN_COMMAND;

    property Active: Boolean read FActive write SetActive;
    property Down: Boolean read FDown write SetDown;

  protected
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;

  published
    property BevelWidth: TBevelWidth read FBevelWidth write SetBevelWidth
      default DefBevelWidth;
    property Style: TButtonStyle read FStyle write SetStyle
      default DefStyle;
    property Caption: TStringList read FCaption write SetCaption;
    property CaptionAlign: TCaptionAlign read FcaptionAlign
      write SetCaptionAlign default DefCaptionAlign;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property Layout: TButtonLayout read FLayout write SetLayout
      default DefLayout;
    property Spacing: TSpacing read FSpacing write SetSpacing
      default DefSpacing;
    property NumGlyphs: TNumGlyphs read FNumGlyphs write SetNumGlyphs
      default DefNumGlyphs;
    property Rounded: Boolean read FRounded write SetRounded
      default DefRounded;
    property Cancel: Boolean read FCancel write FCancel
      default DefCancel;
    property Default: Boolean read FDefault write SetDefault
      default DefDefault;
    property ModalResult: TModalResult read FModalResult write FModalResult
      default DefModalResult;
    property Enabled;
    property Font;
    property DragCursor;
    property DragMode;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property Width default DefWidth;
    property Height default DefHeight;
    property OnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

uses
  Rect, StdCtrls;

{ MLButton -----------------------------------------------}

constructor TMLButton.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := ControlStyle + [csOpaque, csSetCaption, csDoubleClicks];
  FBevelWidth := DefBevelWidth;
  FStyle := DefStyle;
  FCaption := TStringList.Create;
  FCaption.Sorted := False;
  FCaptionAlign := DefCaptionAlign;
  FGlyph := TBitmap.Create;
  FLayout := DefLayout;
  FSpacing := DefSpacing;
  FNumGlyphs := DefNumGlyphs;
  TabStop := True;
  FRounded := DefRounded;
  FCancel := DefCancel;
  FDefault := DefDefault;
  FModalResult := DefModalResult;
  FDown := False;
  Width := DefWidth;
  Height := DefHeight;
  KeyPressed := False;
end;

destructor TMLButton.Destroy;
begin
  FCaption.Free;
  FGlyph.Free;
  inherited Destroy;
end;

procedure TMLButton.Click;
var
  Form: TForm;
begin
  Form := GetParentForm(Self) as TForm;
  if Form <> nil then Form.ModalResult := ModalResult;
  inherited Click;
end;

procedure TMLButton.Loaded;
begin
  inherited Loaded;
  if FGlyph.Empty then GlyphWidth := -1
    else GlyphWidth := FGlyph.Width div NumGlyphs;
end;

procedure TMLButton.CreateWnd;
begin
  inherited CreateWnd;
  Active := FDefault;
end;

procedure TMLButton.Paint;
var
  R, TextR: TRect;
  Format: Word;
  X, Y, TextHeight, TextWidth: Integer;
  Bitmap: TBitmap;
begin
  R := GetClientRect;
  { create offscreen bitmap to prevent flicker }
  Bitmap := TBitmap.Create;

  try
    Bitmap.Width := RectWidth(R);
    Bitmap.Height := RectHeight(R);

    if FActive and (not Focused) then
    begin
      Bitmap.Canvas.Pen.Color := clBtnText;
      Bitmap.Canvas.Pen.Width := 1;
      Bitmap.Canvas.Pen.Style := psSolid;
      Bitmap.Canvas.Brush.Style := bsClear;
      Bitmap.Canvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
      RectGrow(R, -1);
    end;

    R := DrawButtonFace(Bitmap.Canvas, R, FBevelWidth, FStyle,
      FRounded, FDown, False);

    RectGrow(R, -2);
    if Focused then Bitmap.Canvas.DrawFocusRect(R);

    { determine text's width and height }
    TextR := R;

    if not FGlyph.Empty then
      case FLayout of
        blGlyphLeft: Inc(TextR.Left, GlyphWidth + FSpacing);
        blGlyphRight: Dec(TextR.Right, GlyphWidth + FSpacing);
        blGlyphTop: Inc(TextR.Top, FGlyph.Height + FSpacing);
        blGlyphBottom: Dec(TextR.Bottom, FGlyph.Height + FSpacing);
      end;

    Bitmap.Canvas.Font := Font;
    SetBkMode(Bitmap.Canvas.Handle, TRANSPARENT);

    case FCaptionAlign of
      {caLeft: Format := DT_LEFT;}
      caRight: Format := DT_RIGHT;
      caCenter: Format := DT_CENTER;
    else  
      Format := DT_LEFT;  
    end;
    Format := Format or DT_CALCRECT;

    DrawText(Bitmap.Canvas.Handle, FCaption.GetText, -1, TextR, Format);
    TextHeight := (RectHeight(TextR) div (FCaption.Count + 1))
      * FCaption.Count;
    TextWidth := RectWidth(TextR);

    X := 0;
    Y := 0;
    
    { draw glyph }
    if not FGlyph.Empty then
    begin
      case FLayout of
        blGlyphLeft:
          begin
            X := R.Left + (RectWidth(R) - GlyphWidth - FSpacing - TextWidth) div 2;
            Y := (RectHeight(R) - FGlyph.Height) div 2 + R.Top;
          end;
        blGlyphRight:
          begin
            X := R.Right - GlyphWidth -
              (RectWidth(R) - GlyphWidth - FSpacing - TextWidth) div 2;
            Y := (RectHeight(R) - FGlyph.Height) div 2 + R.Top;
          end;
        blGlyphTop:
          begin
            X := (RectWidth(R) - GlyphWidth) div 2 + R.Left;
            Y := R.Top + (RectHeight(R) - FGlyph.Height - FSpacing - TextHeight) div 2;
          end;
        blGlyphBottom:
          begin
            X := (RectWidth(R) - GlyphWidth) div 2 + R.Left;
            Y := R.Bottom - FGlyph.Height -
              (RectHeight(R) - FGlyph.Height - FSpacing - TextHeight) div 2;
          end;
      else
        raise Exception.Create('Invalid layout');
      end;

      if not Enabled then
        DrawGlyph(Bitmap.Canvas, X, Y, 2)
      else if Down then
        DrawGlyph(Bitmap.Canvas, X, Y, 3)
      else
        DrawGlyph(Bitmap.Canvas, X, Y, 1)
    end;

    { compute the rect for a caption text }
    if not FGlyph.Empty then
      if Layout in [blGlyphLeft, blGlyphRight] then
      begin
        if Layout = blGlyphLeft then
          TextR.Left := X + GlyphWidth + FSpacing
        else
          TextR.Left := X - FSpacing - TextWidth;
        TextR.Right := TextR.Left + TextWidth;
        TextR.Top := (RectHeight(R) - TextHeight) div 2 + R.Top;
        TextR.Bottom := TextR.Top + TextHeight;
      end else
      begin
        if Layout = blGlyphTop then
          TextR.Top := Y + FGlyph.Height + FSpacing
        else
          TextR.Top := Y - FSpacing - TextHeight;
        TextR.Bottom := TextR.Top + TextHeight;
        TextR.Left := (RectWidth(R) - TextWidth) div 2 + R.Left;
        TextR.Right := TextR.Left + TextWidth;
      end
    else
    begin
      TextR.Left := R.Left + (RectWidth(R) - TextWidth) div 2;
      TextR.Right := TextR.Left + TextWidth;
      TextR.Top := R.Top + (RectHeight(R) - TextHeight) div 2;
      TextR.Bottom := TextR.Top + TextHeight;
    end;

    { draw caption text }
    Format := Format and (not DT_CALCRECT);
    if Enabled then
      DrawText(Bitmap.Canvas.Handle, FCaption.GetText, -1, TextR, Format)
    else begin
      Bitmap.Canvas.Font.Color := clBtnHighlight;
      DrawText(Bitmap.Canvas.Handle, FCaption.GetText, -1, TextR, Format);
      Bitmap.Canvas.Font.Color := clBtnShadow;
      RectRelativeMove(TextR, -1, -1);
      DrawText(Bitmap.Canvas.Handle, FCaption.GetText, -1, TextR, Format);
    end;

    Canvas.Draw(0, 0, Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure TMLButton.SetBevelWidth(ABevelWidth: TBevelWidth);
begin
  if ABevelWidth <> FBevelWidth then
  begin
    FBevelWidth := ABevelWidth;
    Invalidate;
  end;
end;

procedure TMLButton.SetStyle(AStyle: TButtonStyle);
begin
  if AStyle <> FStyle then
  begin
    FStyle := AStyle;
    Invalidate;
  end;
end;

procedure TMLButton.SetCaption(ACaption: TStringList);
begin
  FCaption.Assign(ACaption);
  Invalidate;
end;

procedure TMLButton.SetCaptionAlign(ACaptionAlign: TCaptionAlign);
begin
  if ACaptionAlign <> FCaptionAlign then
  begin
    FCaptionAlign := ACaptionAlign;
    Invalidate;
  end;
end;

procedure TMLButton.SetGlyph(AGlyph: TBitmap);
var
  R: TRect;
begin
  if not AGlyph.Empty then
  begin
    FGlyph.Width := AGlyph.Width;
    FGlyph.Height := AGlyph.Height;
    R := RectSet(0, 0, FGlyph.Width, FGlyph.Height);
    FGlyph.Canvas.Brush.Style := bsSolid;
    FGlyph.Canvas.Brush.Color := clBtnFace;
    FGlyph.Canvas.BrushCopy(R, AGlyph, R, clOlive);
  end else
    FGlyph.Assign(AGlyph);
  Invalidate;
end;

procedure TMLButton.SetLayout(ALayout: TButtonLayout);
begin
  if ALayout <> FLayout then
  begin
    FLayout := ALayout;
    Invalidate;
  end;
end;

procedure TMLButton.SetSpacing(ASpacing: TSpacing);
begin
  if ASpacing <> FSpacing then
  begin
    FSpacing := ASpacing;
    Invalidate;
  end;
end;

procedure TMLButton.SetNumGlyphs(ANumGlyphs: TNumGlyphs);
begin
  if ANumGlyphs <> FNumGlyphs then
  begin
    FNumGlyphs := ANumGlyphs;
    if FGlyph.Empty then GlyphWidth := -1
      else GlyphWidth := FGlyph.Width div FNumGlyphs;
    Invalidate;
  end;
end;

procedure TMLButton.SetRounded(ARounded: Boolean);
begin
  if ARounded <> FRounded then
  begin
    FRounded := ARounded;
    Invalidate;
  end;
end;

procedure TMLButton.SetDefault(ADefault: Boolean);
begin
  FDefault := ADefault;
  if HandleAllocated then
    with GetParentForm(Self) do
      Perform(CM_FOCUSCHANGED, 0, Longint(ActiveControl));
end;

procedure TMLButton.SetActive(AnActive: Boolean);
begin
  if AnActive <> FActive then
  begin
    FActive := AnActive;
    Invalidate;
  end;
end;

procedure TMLButton.SetDown(ADown: Boolean);
begin
  if ADown <> FDown then
  begin
    FDown := ADown;
    Invalidate;
  end;
end;

procedure TMLButton.DrawGlyph(ACanvas: TCanvas; X, Y: Integer; GlyphNum: TNumGlyphs);
var
  Dest, Source: TRect;
begin
  if GlyphNum > FNumGlyphs then
    GlyphNum := 1;
  SetRect(Dest, X, Y, X + GlyphWidth, Y + FGlyph.Height);
  SetRect(Source, (GlyphNum - 1) * GlyphWidth, 0, GlyphNum * GlyphWidth,
    FGlyph.Height);
  ACanvas.CopyRect(Dest, FGlyph.Canvas, Source);
end;

procedure TMLButton.CMEnabledChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TMLButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if not KeyPressed then
  begin
    MouseCapture := True;
    SetFocus;
    Down := True;
  end;
end;

procedure TMLButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if not KeyPressed then
  begin
    if MouseCapture then MouseCapture := False;
    if Down then Down := False;
  end;
end;

procedure TMLButton.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if (not KeyPressed) and MouseCapture then
    Down := (Message.XPos >= 0) and (Message.XPos < Width)
      and (Message.YPos >= 0) and (Message.YPos < Height);
end;

procedure TMLButton.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
  if (not MouseCapture) and (Message.CharCode = vk_Space) then
  begin
    MouseCapture := True;
    KeyPressed := True;
    Down := True;
  end;
end;

procedure TMLButton.WMKeyUp(var Message: TWMKeyUp);
begin
  inherited;
  if KeyPressed and (Message.CharCode = vk_Space) then
  begin
    MouseCapture := False;
    KeyPressed := False;
    Down := False;
    Click;
  end;
end;

procedure TMLButton.CNCommand(var Message: TWMCommand);
begin
  if Message.NotifyCode = BN_CLICKED then Click;
end;

procedure TMLButton.CMDialogKey(var Message: TCMDialogKey);
begin
  with Message do
    if  (((CharCode = VK_RETURN) and FActive) or
      ((CharCode = VK_ESCAPE) and FCancel)) and
      (KeyDataToShiftState(Message.KeyData) = []) and CanFocus then
    begin
      Click;
      Result := 1;
    end else
      inherited;
end;

procedure TMLButton.CMDialogChar(var Message: TCMDialogChar);
var
  I: Integer;
begin
  with Message do
    for I := 0 to FCaption.Count - 1 do
    if IsAccel(CharCode, FCaption[I]) and CanFocus then
    begin
      Click;
      Result := 1;
      exit;
    end;
  inherited;
end;

procedure TMLButton.CMFocusChanged(var Message: TCMFocusChanged);
begin
  with Message do
    if (Sender is TButton) or (Sender is TMLButton) then
      Active := Sender = Self
    else
      Active := FDefault;
  inherited;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-Button', [TMLButton]);
end;

end.
