{

  TBSkinShared.Pas
  Copyright 2001-2002 by Haralabos Michael. All rights reserved.

  See "lincense.txt" before modifing/copying this code

  Contributors:
  ColorDarker, ColorLighter functions (C) Aaron Chan

  Floating Windows OfficeXP & WindowsXP Style (C) Andreas Holstenson
  Windows XP Shadows (C) Andreas Holstenson

  Skin Manager, Docked Captions, Component Additions & Changes (C) Dean Harmon
  BlendTBXIcon, DrawTBXIconShadow (C) Alex Denisov

}

unit TBSkinShared;

interface

Uses
  Windows, ImgList, Graphics, TB2Item, TBSkinPlus;

const
  ROP_DSPDxax = $00E20746;

type
  _TRIVERTEX = record
    X: Integer;
    Y: Integer;
    Red  : Word;
    Green: Word;
    Blue : Word;
    Alpha: Word;
  end;

  TTBData = record
    Window: TTBPopupWindow;
    Skin: TTBBaseSkin;
    View: TTBView;
    MDI: Boolean;
  end;

  PTBData = ^TTBData;

  ItemViewerAccess = class(TTBItemViewer);
  ViewAccess = class(TTBView);

procedure PolylineEx(const DC: HDC; const Points: array Of TPoint);
function GetImgListMargin(const Viewer: TTBItemViewer): Integer;

function ColorLighter(const Color: TColor; const Percent: Byte):TColor;
function ColorDarker(const OriginalColor: TColor; const Percent: Byte): TColor;
function ColorLighterRGB(const Color: TColorRef; const Percent: Byte): TColorRef;
function ColorDarkerRGB(const Color: TColorRef; const Percent: Byte): TColorRef;
function BlendColors(const Color1, Color2: TColor; Amount: Extended): TColor;

procedure FillGradient(const DC: HDC; const ARect: TRect;
  const StartColor, EndColor: TColorRef; const Direction: TTBGradDir);
procedure FillGradient2(const DC: HDC; const ARect: TRect;
  const StartColor, EndColor: TColorRef; const Direction: TTBGradDir);

procedure BlendTBXIcon(Canvas: TCanvas; const R: TRect;
  ImageList: TCustomImageList; ImageIndex: Integer; Opacity: Byte);
procedure DrawTBXIconShadow(Canvas: TCanvas; const R: TRect;
  ImageList: TCustomImageList; ImageIndex: Integer; Light: Boolean = False);

var
  tbChevronSize: Integer = 12;
  StockBitmap1, StockBitmap2: TBitmap;
  GradientFill: function(DC: HDC; PVertex: Pointer; NumVertex: Cardinal;
    PMesh: Pointer;  dwNumMesh, dwMode: Cardinal): Boolean; stdcall;

implementation

Uses Classes, TB2Common;

procedure PolylineEx(const DC: HDC; const Points: array Of TPoint);
type
  PPoints = ^TPoints;
  TPoints = array[0..0] of TPoint;
begin
  Windows.Polyline(DC, PPoints(@Points)^, High(Points) + 1);
end;

function BlendColors(const Color1, Color2: TColor; Amount: Extended): TColor;
Var
  R,R2,G,G2,B,B2: Integer;
  win1, win2: Integer;
begin
  win1 := ColorToRGB(color1);
  win2 := ColorToRGB(color2);

  // Convert first
  R := GetRValue(win1);
  G := GetGValue(win1);
  B := GetBValue(win1);
  // Convert second
  R2 := GetRValue(win2);
  G2 := GetGValue(win2);
  B2 := GetBValue(win2);

  // Mix them into color1

  b2:=round((1-amount)*b+amount*b2);
  g2:=round((1-amount)*g+amount*g2);
  r2:=round((1-amount)*r+amount*r2);

  // Just to make sure...
  if R2 < 0 then R2 := 0;
  if G2 < 0 then G2 := 0;
  if B2 < 0 then B2 := 0;

  // If we ever reach white we should revert to first color
  if R2 > 255 then R2 := r;
  if G2 > 255 then G2 := r;
  if B2 > 255 then B2 := r;

  Result := TColor(RGB(R2, G2, B2));
end;

procedure FillGradient(const DC: HDC; const ARect: TRect;
  const StartColor, EndColor: TColorRef; const Direction: TTBGradDir);
var
  GRect : TGradientRect;
  Vertex: array[0..1] of _TRIVERTEX;
begin
  if not Assigned(GradientFill) then
  begin
    FillGradient2(DC, ARect, StartColor, EndColor, Direction);
    Exit;
  end;

  with Vertex[0] do
  begin
    X := ARect.Left;
    Y := ARect.Top;

    Red := GetRValue(StartColor) shl 8;
    Green := GetGValue(StartColor) shl 8;
    Blue := GetBValue(StartColor) shl 8;
    Alpha := 0;
  end;

  with Vertex[1] do
  begin
    X := ARect.Right;
    Y := ARect.Bottom;

    Red := GetRValue(EndColor) shl 8;
    Green := GetGValue(EndColor) shl 8;
    Blue := GetBValue(EndColor) shl 8;
    Alpha := 0;
  end;

  GRect.UpperLeft := 0;
  GRect.LowerRight := 1;

  GradientFill(DC, @Vertex, 2, @GRect, 1, Integer(Direction));
end;

procedure FillGradient2(const DC: HDC; const ARect: TRect;
                        const StartColor, EndColor: TColorRef;
                        const Direction: TTBGradDir);
var
 rc1, rc2, gc1, gc2,
 bc1, bc2, Counter: Integer;
 Brush: HBrush;
begin
  rc1 := GetRValue(StartColor);
  gc1 := GetGValue(StartColor);
  bc1 := GetBValue(StartColor);
  rc2 := GetRValue(EndColor);
  gc2 := GetGValue(EndColor);
  bc2 := GetBValue(EndColor);

  if Direction = tbgTopBottom then
  for Counter := ARect.Top to ARect.Bottom do
  begin
    Brush := CreateSolidBrush(
     RGB((rc1 + (((rc2 - rc1) * (ARect.Top + Counter)) div ARect.Bottom)),
                  (gc1 + (((gc2 - gc1) * (ARect.Top + Counter)) div ARect.Bottom)),
                  (bc1 + (((bc2 - bc1) * (ARect.Top + Counter)) div ARect.Bottom))));
    FillRect(DC, Rect(0, ARect.Top, ARect.Right, ARect.Bottom - Counter + 1), Brush);
    DeleteObject(Brush);
  end
  else
  for Counter := ARect.Left to ARect.Right do
  begin
    Brush := CreateSolidBrush(
     RGB((rc1 + (((rc2 - rc1) * (ARect.Left + Counter)) div ARect.Right)),
                  (gc1 + (((gc2 - gc1) * (ARect.Left + Counter)) div ARect.Right)),
                  (bc1 + (((bc2 - bc1) * (ARect.Left + Counter)) div ARect.Right))));
    FillRect(DC, Rect(ARect.Left, ARect.Top, ARect.Right - Counter +1, ARect.Bottom), Brush);
    DeleteObject(Brush);
  end;
end;

function ColorLighter(const Color: TColor; const Percent: Byte):TColor;
var
  R, G, B: Byte;
  FColor: TColorRef;
begin
  FColor := ColorToRGB(Color);

  R := GetRValue(FColor);
  G := GetGValue(FColor);
  B := GetBValue(FColor);

  R := R + (((255 -r) * Percent) div 100);
  G := G + (((255 -g) * Percent) div 100);
  B := B + (((255 -b) * Percent) div 100);

  Result := TColor(RGB(R, G, B));
end;

function ColorDarker(const OriginalColor: TColor; const Percent: Byte): TColor;
var
  R, G, B: Integer;
  WinColor: Integer;
begin
  WinColor := ColorToRGB(OriginalColor);

  R := GetRValue(WinColor);
  G := GetGValue(WinColor);
  B := GetBValue(WinColor);

  R := R - Percent;
  G := G - Percent;
  B := B - Percent;

  if R < 0 then R := 0;
  if G < 0 then G := 0;
  if B < 0 then B := 0;

  Result := TColor(RGB(R, G, B));
end;

function ColorLighterRGB(const Color: TColorRef; const Percent: Byte): TColorRef;
var
  R, G, B: Byte;
begin
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);

  R := R + (((255 -r) * Percent) div 100);
  G := G + (((255 -g) * Percent) div 100);
  B := B + (((255 -b) * Percent) div 100);

  Result := RGB(R, G, B);
end;

function ColorDarkerRGB(const Color: TColorRef; const Percent: Byte): TColorRef;
var
  R, G, B: Integer;
begin
  R := GetRValue(Color);
  G := GetGValue(Color);
  B := GetBValue(Color);

  R := R - Percent;
  G := G - Percent;
  B := B - Percent;

  if R < 0 then R := 0;
  if G < 0 then G := 0;
  if B < 0 then B := 0;

  Result := RGB(R, G, B);
end;

{$WARNINGS OFF}
procedure BlendTBXIcon(Canvas: TCanvas; const R: TRect;
  ImageList: TCustomImageList; ImageIndex: Integer; Opacity: Byte);
const
  CWeirdColor = $00203241;
var
  ImageWidth, ImageHeight: Integer;
  I, J: Integer;
  Src, Dst: ^Cardinal;
  S, C, CBRB, CBG: Cardinal;
  Wt1, Wt2: Cardinal;
begin
  Wt2 := Opacity;
  Wt1 := 255 - Wt2;
  ImageWidth := R.Right - R.Left;
  ImageHeight := R.Bottom - R.Top;
  with ImageList do
  begin
    if Width < ImageWidth then ImageWidth := Width;
    if Height < ImageHeight then ImageHeight :=  Height;
  end;

  StockBitmap1.Width := ImageWidth;
  StockBitmap1.Height := ImageHeight;
  StockBitmap2.Width := ImageWidth;
  StockBitmap2.Height := ImageHeight;

  BitBlt(StockBitmap1.Canvas.Handle, 0, 0, ImageWidth, ImageHeight,
    Canvas.Handle, R.Left, R.Top, SRCCOPY);
  BitBlt(StockBitmap2.Canvas.Handle, 0, 0, ImageWidth, ImageHeight,
    StockBitmap1.Canvas.Handle, 0, 0, SRCCOPY);
  ImageList.Draw(StockBitmap2.Canvas, 0, 0, ImageIndex, True);

  for J := 0 to ImageHeight - 1 do
  begin
    Src := StockBitmap2.ScanLine[J];
    Dst := StockBitmap1.ScanLine[J];
    for I := 0 to ImageWidth - 1 do
    begin
      S := Src^;
      if S <> Dst^ then
      begin
        CBRB := (Dst^ and $00FF00FF) * Wt1;
        CBG  := (Dst^ and $0000FF00) * Wt1;
        C := ((S and $FF00FF) * Wt2 + CBRB) and $FF00FF00 + ((S and $00FF00) * Wt2 + CBG) and $00FF0000;
        Dst^ := C shr 8;
      end;
      Inc(Src);
      Inc(Dst);
    end;
  end;
  BitBlt(Canvas.Handle, R.Left, R.Top, ImageWidth, ImageHeight,
    StockBitmap1.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure DrawTBXIconShadow(Canvas: TCanvas; const R: TRect;
  ImageList: TCustomImageList; ImageIndex: Integer; Light: Boolean);
var
  ImageWidth, ImageHeight: Integer;
  I, J: Integer;
  Src, Dst: ^Cardinal;
  S, C, CBRB, CBG: Cardinal;
begin
  ImageWidth := R.Right - R.Left;
  ImageHeight := R.Bottom - R.Top;
  with ImageList do
  begin
    if Width < ImageWidth then ImageWidth := Width;
    if Height < ImageHeight then ImageHeight :=  Height;
  end;

  StockBitmap1.Width := ImageWidth;
  StockBitmap1.Height := ImageHeight;
  StockBitmap2.Width := ImageWidth;
  StockBitmap2.Height := ImageHeight;

  BitBlt(StockBitmap1.Canvas.Handle, 0, 0, ImageWidth, ImageHeight,
    Canvas.Handle, R.Left, R.Top, SRCCOPY);
  BitBlt(StockBitmap2.Canvas.Handle, 0, 0, ImageWidth, ImageHeight,
    StockBitmap1.Canvas.Handle, 0, 0, SRCCOPY);
  ImageList.Draw(StockBitmap2.Canvas, 0, 0, ImageIndex, True);

  for J := 0 to ImageHeight - 1 do
  begin
    Src := StockBitmap2.ScanLine[J];
    Dst := StockBitmap1.ScanLine[J];
    for I := 0 to ImageWidth - 1 do
    begin
      S := Src^;
      if S <> Dst^ then
      begin
        CBRB := Dst^ and $00FF00FF;
        CBG  := Dst^ and $0000FF00;
        C := ((S and $FF0000) shr 16 * 29 + (S and $00FF00) shr 8 * 150 +
          (S and $0000FF) * 76) shr 8;
        if Light then C := C div 8 + 223
        else C := C div 3 + 170;
        Dst^ := ((CBRB * C and $FF00FF00) or (CBG * C and $00FF0000)) shr 8;
      end;
      Inc(Src);
      Inc(Dst);
    end;
  end;
  BitBlt(Canvas.Handle, R.Left, R.Top, ImageWidth, ImageHeight,
    StockBitmap1.Canvas.Handle, 0, 0, SRCCOPY);
end;
{$WARNINGS ON}

function GetImgListMargin(const Viewer: TTBItemViewer): Integer;
var
  DC: HDC;
  W, H: Integer;
  Canvas: TCanvas;
begin
  DC := GetWindowDC(ViewAccess(Viewer.View).Window.Handle);

  Canvas := TCanvas.Create;
  Canvas.Handle := DC;
  Canvas.Font.Assign(ViewAccess(Viewer.View).GetFont);
  ItemViewerAccess(Viewer).CalcSize(Canvas, W, H);
  Canvas.Free;

  ReleaseDC(ViewAccess(Viewer.View).Window.Handle, DC);
  Result := H +2;
end;

var
  LibHandle: THandle;
initialization
  LibHandle := LoadLibrary('msimg32.dll');

  if LibHandle <> 0 then
    @GradientFill := GetProcAddress(LibHandle, 'GradientFill')
  else
  begin
    FreeLibrary(LibHandle);
    LibHandle := 0;
  end;

  StockBitmap1 := TBitmap.Create;
  StockBitmap1.PixelFormat := pf32bit;
  StockBitmap2 := TBitmap.Create;
  StockBitmap2.PixelFormat := pf32bit;
finalization
  StockBitmap1.Free;
  StockBitmap2.Free;

  if LibHandle <> 0 then
    FreeLibrary(LibHandle);
end.
