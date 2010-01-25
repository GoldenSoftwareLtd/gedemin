
{++

  Copyright (c) 1995-97 by Golden Software of Belarus

  Module

    bkground.pas

  Abstract

    Delphi visual components that allow to set
    bitmapped and gradientually filled backgrounds.

  Author

    Andrei Kireev (6-Oct-95)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    9-Oct-95    andreik      Initial version.
    1.01   11-Oct-95    andreik      Optimized gradient filling;
                                     Added Repaint method.
    2.00   11-Nov-95    andreik      A lot of changes.
    2.01   16-Nov-95    andreik      Used inherited Align property
                                     instead of hands-written.
    2.02   05-Jul-96    andreik      Parent has been changed to TGraphicControl.

    2.03   20-Oct-97    andreik      32bit version.
    2.04   20-Nov-97    sai,andreik  Added WallImages property.

--}

unit Bkground;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

{$R BKGROUND.RES}

type
  TImageAlign = (taLeftUpper, taTop, taRightUpper, taRight,
    taRightLower, taBottom, taLeftLower, taLeft, taCenter);

  { predefined wall images }
  TWallImages = (wiCustom, wiLightMarble, wiDarkMarble);

const
  DefFrame = False;
  DefImageAlign = taLeftUpper;
  DefImageTranspColor = clOlive;
  DefImageShadow = True;
  DefImageShadDepth = 3;
  DefImageGap = 20;
  DefColor = clBtnFace;
  DefWallImages = wiCustom;

type
  TBackgroundBase = class(TGraphicControl)
  private
    FFrame: Boolean;
    FImage: TBitmap;
    FImageAlign: TImageAlign;
    FImageTranspColor: TColor;
    FImageShadow: Boolean;
    FImageShadDepth: Integer;
    FImageGap: Integer;
    FColor: TColor;

    procedure SetFrame(AFrame: Boolean);
    procedure SetImage(AImage: TBitmap);
    procedure SetImageAlign(AImageAlign: TImageAlign);
    procedure SetImageTranspColor(AImageTranspColor: TColor);
    procedure SetImageShadow(AImageShadow: Boolean);
    procedure SetImageShadDepth(AImageShadDepth: Integer);
    procedure SetImageGap(AImageGap: Integer);
    procedure SetColor(AColor: TColor);

    procedure CalculateMasks;

  protected
    procedure Paint; override;

    procedure PaintBackground; virtual; abstract;
    procedure PaintImage; virtual;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Frame: Boolean read FFrame write SetFrame
      default DefFrame;
    property Image: TBitmap read FImage write SetImage;
    property ImageAlign: TImageAlign read FImageAlign write SetImageAlign
      default DefImageAlign;
    property ImageTranspColor: TColor read FImageTranspColor
      write SetImageTranspColor default DefImageTranspColor;
    property ImageShadow: Boolean read FImageShadow write SetImageShadow
      default DefImageShadow;
    property ImageShadDepth: Integer read FImageShadDepth
      write SetImageShadDepth default DefImageShadDepth;
    property ImageGap: Integer read FImageGap write SetImageGap
      default DefImageGap;
    property Color: TColor read FColor write SetColor
      default DefColor;

    { publish inherited properties }
    property Left nodefault;
    property Top nodefault;
    property Width nodefault;
    property Height nodefault;
    property Visible;
    property Align;
  end;

  EBackgroundBaseError = class(Exception);

type
  TBkStyle = (bsTile, bsCenter, bsStretch);

const
  DefBkStyle = bsTile;
  DefEnableBitmap = True;

type
  TBackground = class(TBackgroundBase)
  private
    FBitmap: TBitmap;
    FBkStyle: TBkStyle;
    FEnableBitmap: Boolean;
    FWallImages: TWallImages;

    procedure SetBitmap(ABitmap: TBitmap);
    procedure SetBkStyle(ABkStyle: TBkStyle);
    procedure SetEnableBitmap(AnEnableBitmap: Boolean);
    procedure SetWallImages(AWallImages: TWallImages);

    procedure FreeBitmap;

  protected
    procedure PaintBackground; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Bitmap: TBitmap read FBitmap write SetBitmap;
    property BkStyle: TBkStyle read FBkStyle write SetBkStyle
      default DefBkStyle;
    property EnableBitmap: Boolean read FEnableBitmap write SetEnableBitmap
      default DefEnableBitmap;
    property WallImages: TWallImages read FWallImages write SetWallImages
      default DefWallImages;
  end;

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
  TGradientFill = class(TBackgroundBase)
  private
    FFromColor: TColor;
    FToColor: TColor;
    FSteps: TSteps;
    FOrigin: TOrigin;

    procedure SetFromColor(AFromColor: TColor);
    procedure SetToColor(AToColor: TColor);
    procedure SetSteps(ASteps: TSteps);
    procedure SetOrigin(AnOrigin: TOrigin);

  protected
    procedure PaintBackground; override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property FromColor: TColor read FFromColor write SetFromColor
      default DefFromColor;
    property ToColor: TColor read FToColor write SetToColor
      default DefToColor;
    property Steps: TSteps read FSteps write SetSteps
      default DefSteps;
    property Origin: TOrigin read FOrigin write SetOrigin
      default DefOrigin;
  end;

procedure Register;

implementation

uses
  ExtCtrls, gs_exception;
  
var
  BmpDarkBackground, BmpLightBackground: TBitmap;

{---------------------------------------------------------}

procedure LoadDarkBackground;
begin
  if BmpDarkBackground.Empty then
    BmpDarkBackground.LoadFromResourceName(hInstance, 'XBACKGROUND_DARKBACKGROUND');
end;

procedure LoadLightBackground;
begin
  if BmpLightBackground.Empty then
    BmpLightBackground.LoadFromResourceName(hInstance, 'XBACKGROUND_LIGHTBACKGROUND');
end;

{ TBackgroundBase ----------------------------------------}

constructor TBackgroundBase.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := ControlStyle - [csFramed, csCaptureMouse];

  FFrame := DefFrame; { keep in touch with ControlStyle }
  FImage := TBitmap.Create;
  FImageAlign := DefImageAlign;
  FImageTranspColor := DefImageTranspColor;
  FImageShadow := DefImageShadow;
  FImageShadDepth := DefImageShadDepth;
  FImageGap := DefImageGap;
  FColor := DefColor;
end;

destructor TBackgroundBase.Destroy;
begin
  FImage.Free;
  inherited Destroy;
end;

procedure TBackgroundBase.Paint;
begin
  PaintBackground;
  PaintImage;
end;

procedure TBackgroundBase.PaintImage;
var
  Bm: TBitmap;
  R1, R2: TRect;
  X, Y, H, W, FullW, FullH: Integer;
begin
  if not FImage.Empty then
  begin
    W := FImage.Width;
    H := FImage.Height div 3;
    FullW := W + FImageShadDepth;
    FullH := H + FImageShadDepth;

    case FImageAlign of
      taLeftUpper:
        begin
          X := FImageGap;
          Y := FImageGap;
        end;
      taTop:
        begin
          X := (Width - FullW) div 2;
          Y := FImageGap;
        end;
      taRightUpper:
        begin
          X := Width - FullW - FImageGap;
          Y := FImageGap;
        end;
      taRight:
        begin
          X := Width - FullW - FImageGap;
          Y := (Height - FullH) div 2;
        end;
      taRightLower:
        begin
          X := Width - FullW - FImageGap;
          Y := Height - FullH - FImageGap;
        end;
      taBottom:
        begin
          X := (Width - FullW) div 2;
          Y := Height - FullH - FImageGap;
        end;
      taLeftLower:
        begin
          X := FImageGap;
          Y := Height - FullH - FImageGap;
        end;
      taLeft:
        begin
          X := FImageGap;
          Y := (Height - FullH) div 2;
        end;
      taCenter:
        begin
          X := (Width - FullW) div 2;
          Y := (Height - FullH) div 2;
        end;
    else
      raise Exception.Create(GetGsException(Self, 'Invalid layout'));
    end;

    Bm := TBitmap.Create;
    try
      Bm.Width := W;
      Bm.Height := H;
      R1 := Rect(X, Y, X + W, Y + H);
      R2 := Rect(0, 0, W, H);

      if FImageShadow then
        BitBlt(Canvas.Handle, X + FImageShadDepth, Y + FImageShadDepth,
          W, H, FImage.Canvas.Handle, 0, H, SRCAND);

      Bm.Canvas.CopyRect(R2, Canvas, R1);
      BitBlt(Bm.Canvas.Handle, 0, 0, W, H, FImage.Canvas.Handle, 0, H, SRCAND);
      BitBlt(Bm.Canvas.Handle, 0, 0, W, H, FImage.Canvas.Handle, 0, H * 2, SRCPAINT);
      Canvas.CopyRect(R1, Bm.Canvas, R2);
    finally
      Bm.Free;
    end;
  end;
end;

procedure TBackgroundBase.SetFrame(AFrame: Boolean);
begin
  if AFrame <> FFrame then
  begin
    FFrame := AFrame;
    if FFrame then ControlStyle := ControlStyle + [csFramed]
      else ControlStyle := ControlStyle - [csFramed];
{    RecreateWnd;
    if Owner is TWinControl then
      TWinControl(Owner).Invalidate; }
    Invalidate;
  end;
end;

procedure TBackgroundBase.SetImage(AImage: TBitmap);
var
  R: TRect;
begin
  if Assigned(AImage) and (not AImage.Empty) then
  begin
    FImage.Width := AImage.Width;
    FImage.Height := AImage.Height * 3;

    { copy image }
    R := Rect(0, 0, AImage.Width, AImage.Height);
    FImage.Canvas.CopyRect(R, AImage.Canvas, R);
    CalculateMasks;
  end else
    FImage.Assign(AImage);

  Invalidate;
end;

procedure TBackgroundBase.SetImageAlign(AImageAlign: TImageAlign);
begin
  if AImageAlign <> FImageAlign then
  begin
    FImageAlign := AImageAlign;
    Invalidate;
  end;
end;

procedure TBackgroundBase.SetImageTranspColor(AImageTranspColor: TColor);
begin
  if AImageTranspColor <> FImageTranspColor then
  begin
    FImageTranspColor := AImageTranspColor;
    if not (csLoading in ComponentState) then
    begin
      CalculateMasks;
      Invalidate;
    end;
  end;
end;

procedure TBackgroundBase.SetImageShadow(AImageShadow: Boolean);
begin
  if AImageShadow <> FImageShadow then
  begin
    FImageShadow := AImageShadow;
    Invalidate;
  end;
end;

procedure TBackgroundBase.SetImageShadDepth(AImageShadDepth: Integer);
begin
  if AImageShadDepth <> FImageShadDepth then
  begin
    FImageShadDepth := AImageShadDepth;
    Invalidate;
  end;
end;

procedure TBackgroundBase.SetImageGap(AImageGap: Integer);
begin
  if AImageGap <> FImageGap then
  begin
    FImageGap := AImageGap;
    Invalidate;
  end;
end;

procedure TBackgroundBase.SetColor(AColor: TColor);
begin
  if AColor <> FColor then
  begin
    FColor := AColor;
    Invalidate;
  end;
end;

procedure TBackgroundBase.CalculateMasks;
var
  X, Y, W, H: Integer;
  R, R2: TRect;
begin
  if not FImage.Empty then
  begin
    W := FImage.Width;
    H := FImage.Height div 3;
    R := Rect(0, 0, W, H);

    { making AND mask }
    R2 := Rect(0, H, W, H * 2);
    FImage.Canvas.CopyRect(R2, FImage.Canvas, R);
    for X := 0 to FImage.Width - 1 do
      for Y := H to H * 2 - 1 do
        if FImage.Canvas.Pixels[X, Y] = FImageTranspColor then
          FImage.Canvas.Pixels[X, Y] := clWhite
        else
          FImage.Canvas.Pixels[X, Y] := clBlack;

    { making OR mask }
    R2 := Rect(0, H * 2, W, H * 3);
    FImage.Canvas.Brush.Color := clBlack;
    FImage.Canvas.Brush.Style := bsSolid;
    FImage.Canvas.BrushCopy(R2, FImage, R, FImageTranspColor);
  end;
end;

{ TBackground --------------------------------------------}

constructor TBackground.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  ControlStyle := ControlStyle - [csOpaque];
  FBitmap := TBitmap.Create;
  FBkStyle := DefBkStyle;
  FEnableBitmap := DefEnableBitmap;
  FWallImages := DefWallImages;
end;

destructor TBackground.Destroy;
begin
  FreeBitmap;
  inherited Destroy;
end;

procedure TBackground.PaintBackground;
var
  R: TRect;
  X, Y: Integer;
begin
  if not FEnableBitmap then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := FColor;
    Canvas.FillRect(GetClientRect);
    exit;
  end;

  if FBitmap.Empty or (Width = 0) or (Height = 0) then
    exit; { nothing or nowhere to do }

  case FBkStyle of
    bsTile:
      begin
        for X := 0 to Width div FBitmap.Width do
          for Y := 0 to Height div FBitmap.Height do
            Canvas.Draw(X * FBitmap.Width, Y * FBitmap.Height, FBitmap);
      end;

    bsCenter:
      begin
        Canvas.Draw((Width - FBitmap.Width) div 2,
          (Height - FBitmap.Height) div 2, FBitmap);
      end;

    bsStretch:
      begin
        SetRect(R, 0, 0, Width, Height);
        Canvas.StretchDraw(R, FBitmap);
      end;
  end;

  if csFramed in ControlStyle then
  begin
    R := GetClientRect;
    Frame3D(Canvas, R, clBtnShadow, clBtnHighlight, 1);
  end;
end;

procedure TBackground.SetBitmap(ABitmap: TBitmap);
begin
(*
  if FWallImages <> wiCustom then
    raise EBackgroundBaseError.Create('Property WallImages must be set to wiCustom');
*)

  WallImages := wiCustom;    

  if not Assigned(ABitmap) then
  begin
    FBitmap.Assign(nil);
    exit;
  end;

  if FBitmap.Empty and (Align = alNone) then
  begin
    Width := ABitmap.Width;
    Height := ABitmap.Height;
  end;

  FBitmap.Assign(ABitmap);
  Invalidate;
end;

procedure TBackground.SetBkStyle(ABkStyle: TBkStyle);
begin
  if ABkStyle <> FBkStyle then
  begin
    FBkStyle := ABkStyle;
    Invalidate;
  end;
end;

procedure TBackground.SetEnableBitmap(AnEnableBitmap: Boolean);
begin
  if AnEnableBitmap <> FEnableBitmap then
  begin
    FEnableBitmap := AnEnableBitmap;
    Invalidate;
  end;
end;

procedure TBackground.SetWallImages(AWallImages: TWallImages);
begin
  if FWallImages <> AWallImages then
  begin
    FWallImages := AWallImages;
    case FWallImages of
      wiCustom:
      begin
        FreeBitmap;
        FBitmap := TBitmap.Create;
      end;

      wiLightMarble:
      begin
        LoadLightBackground;
        FreeBitmap;
        FBitmap := BmpLightBackground;
      end;

      wiDarkMarble:
      begin
        LoadDarkBackground;
        FreeBitmap;
        FBitmap := BmpDarkBackground;
      end;
    end;
    Repaint;
  end;
end;

procedure TBackground.FreeBitmap;
begin
  if (FBitmap <> nil) and (FBitmap <> BmpLightBackground) and
    (FBitmap <> BmpDarkBackground) then
  begin
    FBitmap.Free;
    FBitmap := nil;
  end;
end;

{ TGradientFill ------------------------------------------}

constructor TGradientFill.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := ControlStyle + [csOpaque];
  FFromColor := DefFromColor;
  FToColor := DefToColor;
  FSteps := DefSteps;
  FOrigin := DefOrigin;
end;

procedure TGradientFill.PaintBackground;
var
  From, LTo: Longint;
  FromR, FromG, FromB, DeltaR, DeltaG, DeltaB: Integer;
  I: Word;
  DeltaY, DeltaX: Integer;
  R: TRect;
begin
  From := ColorToRGB(FFromColor);
  LTo := ColorToRGB(FToColor);
  FromR := GetRValue(From);
  FromG := GetGValue(From);
  FromB := GetBValue(From);
  DeltaR := GetRValue(LTo) - FromR;
  DeltaG := GetGValue(LTo) - FromG;
  DeltaB := GetBValue(LTo) - FromB;

  Canvas.Brush.Style := bsSolid;

  case FOrigin of
  oTop:
    with Canvas do
    begin
      DeltaY := (Height div Steps) + 1;
      for I := 0 to Steps do
      begin
        R := Rect(0, DeltaY * I, Width, DeltaY * (I + 1));
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
        R := Rect(DeltaX * I, 0, DeltaX * (I + 1), Height);
        Brush.Color := RGB(MulDiv(DeltaR, I, Steps) + FromR,
          MulDiv(DeltaG, I, Steps) + FromG, MulDiv(DeltaB, I, Steps) + FromB);
        FillRect(R);
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
        case FOrigin of
          oLeftUpper:
            R := Rect(DeltaX * I, DeltaY * I, DeltaX * (I + 1), Height);
          oRightUpper:
            R := Rect(Width - DeltaX * (I + 1), DeltaY * I, Width - DeltaX * I, Height);
          oRightLower:
            R := Rect(Width - DeltaX * (I + 1), 0, Width - DeltaX * I, Height - DeltaY * I);
          oLeftLower:
            R := Rect(DeltaX * I, 0, DeltaX * (I + 1), Height - DeltaY * I);
        end;
        FillRect(R);
        case FOrigin of
          oLeftUpper:
            R := Rect(DeltaX * (I + 1), DeltaY * I, Width, DeltaY * (I + 1));
          oRightUpper:
            R := Rect(0, DeltaY * I, Width - DeltaX * (I + 1), DeltaY * (I + 1));
          oRightLower:
            R := Rect(0, Height - DeltaY * (I + 1), Width - DeltaX * (I + 1),
              Height - DeltaY * I);
          oLeftLower:
            R := Rect(DeltaX * (I + 1), Height - DeltaY * (I + 1), Width,
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
        R := Rect(DeltaX * I, DeltaY * I, Width - DeltaX * I, Height - DeltaY * I);
        Brush.Color := RGB(MulDiv(DeltaR, I, Steps) + FromR,
          MulDiv(DeltaG, I, Steps) + FromG, MulDiv(DeltaB, I, Steps) + FromB);
        FillRect(R);
      end;
    end;
  end;

  if csFramed in ControlStyle then
  begin
    R := GetClientRect;
    Frame3D(Canvas, R, clBtnShadow, clBtnHighlight, 1);
  end;
end;

procedure TGradientFill.SetFromColor(AFromColor: TColor);
begin
  if AFromColor <> FFromColor then
  begin
    FFromColor := AFromColor;
    Invalidate;
  end;
end;

procedure TGradientFill.SetToColor(AToColor: TColor);
begin
  if AToColor <> FToColor then
  begin
    FToColor := AToColor;
    Invalidate;
  end;
end;

procedure TGradientFill.SetSteps(ASteps: TSteps);
begin
  if ASteps <> FSteps then
  begin
    FSteps := ASteps;
    Invalidate;
  end;
end;

procedure TGradientFill.SetOrigin(AnOrigin: TOrigin);
begin
  if AnOrigin <> FOrigin then
  begin
    FOrigin := AnOrigin;
    Invalidate;
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsMisc', [TBackground]);
  RegisterComponents('gsMisc', [TGradientFill]);
end;

initialization
  BmpDarkBackground := TBitmap.Create;
  BmpLightBackground := TBitmap.Create;

finalization
  if Assigned(BmpDarkBackground) then
    BmpDarkBackground.Free;
  if Assigned(BmpLightBackground) then
    BmpLightBackground.Free;
end.

