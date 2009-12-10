
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    winhelp.pas

  Abstract

    Help windows like in Win95.

  Author

    Anton Smirnov (12-dec-96)

  Contact address

  Revisions history

    1.00   27-jan-97     sai    Initial version.
    1.01    4-feb-97     sai    Minor Change.
    1.01    2-jun-97     sai    Little change.
    1.02   13-mar-98     sai    Delphi-32

--}

unit xHint;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, StdCtrls, ExtCtrls, Buttons,

  Mask, Grids, DBGrids, DBCtrls, Tabs, TabNotBk,
  Spin, Gauges, Calendar, ColorGrd, DirOutLn, comctrls, CheckLst, xBulbBtn

  ;

type
  TAppearance = (apBubble, apRect, apApproachingBubble, apRoundRect, apCallout);
  TAnimation = (anNone, anSlideTop, anSlideLeftTop, anUnfold, anRandom);

const
  DefAppearance = apCallout;
  DefMenuItemName = 'Help';
  DefDivideSymbol = '\n';
  DefSpeed = 1; { max speed }
  DefBorderWidth = 1;

  DefColor = $C0FFFF; { light yellow }
  DefBorderColor = clBlack;
  DefShadowDepth = 4;
  DefFontName = 'Arial';
  DefFontSize = 8;
  DefFontStyle = [];

type
  TWindowHint = class(TCustomControl)
  private
    FShadow: Boolean;
    Color: TColor;
    LineFeedStr: String;
    Caption: String;
    Lines, W, H, X, Y, HStep, VStep: Integer;
    MaxStr: String;
    Appearance: TAppearance;
    Animation: TAnimation;
    BMPResurce, RectBMP: TBitmap;
    Font: TFont;
    Time: Integer;
    Speed: Integer;
    BorderColor: TColor;
    BorderWidth: Integer;
    ShadowDepth: Integer;
    FlagBMP: Boolean;
    NumberAnimation: Integer;

    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
      message WM_ERASEBKGND;

    procedure DrawWindowHint;
    procedure DrawShade;
    procedure DrawBubble;

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Repaint; override;
  end;

type
  TxHint = class(TComponent)
  private
    FEnabled: Boolean;
    FFont: TFont;
    FAppearance: TAppearance;
    FMenuItemName: String;
    FShadow: Boolean;
    FLineFeedStr: String;
    FAnimation: TAnimation;
    FSpeed, FBorderWidth: Integer;
    FColor, FBorderColor: TColor;
    FShadowDepth: Integer;
    TestWindow: Boolean;

    HelpStr: String;
    HelpHandle: THandle;
    WinControl: TWinControl;
    IndexItem: Integer;
    WindowHint: TWindowHint;
    LLeft, TTop: Integer;
    Popup: Boolean;
    VerSB, HorSB: Boolean;
    MyPopup: TPopupMenu;
    Active: Boolean;
    SavedBitmap: TBitmap;
    RestoreFlag: Boolean;

    OldOnDeActivate: TNotifyEvent;
    procedure SetFont(AFont: TFont);

    procedure SetHelpHandle(AHelpHandle: THandle);
    procedure ActivateWindow;
    procedure CancelWindow;
    procedure MyOnClick(Sender: TObject);
    procedure DeleteItem;
    procedure DoDeActivate(Sender: TObject);
    procedure SaveBitmap;
    procedure RestoreBitmap;
    procedure DoOnDeActivate(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Enabled: Boolean read FEnabled write FEnabled;
    property Font: TFont read FFont write SetFont;
    property Appearance: TAppearance read FAppearance write FAppearance
      default DefAppearance;
    property MenuItemName: String read FMenuItemName write FMenuItemName;
    property Shadow: Boolean read FShadow write FShadow;
    property Color: TColor read FColor write FColor;
    property LineFeedStr: String read FLineFeedStr write FLineFeedStr;
    property Animation: TAnimation read FAnimation write FAnimation;
    property Speed: Integer read FSpeed write FSpeed;
    property BorderColor: TColor read FBorderColor write FBorderColor;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property ShadowDepth: Integer read FShadowDepth write FShadowDepth;
  end;

  ExHintError = class(Exception);

procedure Register;

var
  xxHint: TxHint;
  WM_XHINTMESSAGE: Word;

implementation

{$R XHINT.RES}

uses
  Rect, gsMultilingualSupport;

{ Hooks --------------------------------------------------}

var
  MouseHook: HHook;
  MessageHook: HHook;

function MouseProc(Code: Integer; WParam: Word; LParam: Longint): Longint;
  stdcall;
begin
  { if xxHint is not assigned ... }
  if (xxHint <> nil) and not (csDesigning in xxHint.ComponentState) then
  begin
    try
      if LParam <> 0 then
      begin
        if WParam = wm_RButtonDown then
        begin
           if xxHint.WindowHint.Visible then
             xxHint.CancelWindow;
           if xxHint.Popup then
             xxHint.DeleteItem;
          xxHint.LLeft := PMouseHookStruct(LParam)^.Pt.X;
          xxHint.TTop := PMouseHookStruct(LParam)^.Pt.Y;
          xxHint.SetHelpHandle(PMouseHookStruct(LParam)^.hWnd);
        end;
        if (WParam = wm_LButtonDown) or (WParam = wm_LButtonUP) or (WParam = WM_NCLBUTTONDOWN) then
        begin
           if xxHint.WindowHint.Visible then
           begin
             xxHint.CancelWindow;
             if xxHint.Popup then
               xxHint.DeleteItem;
             xxHint.Popup := False;
           end;
        end;
      end;
    except
      on Exception do
        { it seems that xxHint is damaged }
        raise Exception.Create('Hint instance has been disposed');
    end;
  end;

  // call previous 
  Result :=  CallNextHookEx(MouseHook, Code, WParam, LParam);
end;

function MessageProc(Code: Integer; WParam: Word; LParam: LongInt): Longint;
  stdcall;
var
  PMSG: ^TMSG;
begin
  PMSG := Pointer(LParam);

  // if xxHint is not assigned...
  if (PMSG <> nil) and (xxHint <> nil) and (not (csDesigning in xxHint.ComponentState)) then
  begin
    try
      if (PMSG^.Message = WM_KEYDOWN) or (PMSG^.Message = WM_ACTIVATE) then
      begin
        xxHint.CancelWindow;
        if xxHint.Popup then
          xxHint.DeleteItem;
        xxHint.Popup := False;
      end;
    except
      on Exception do
        { it seems that xxHint is damaged }
        raise Exception.Create('Hint instance has been disposed');
    end;
  end;
  Result := CallNextHookEx(MessageHook, Code, WParam, LParam);
end;

{TWindowHint----------------------------------------------}

constructor TWindowHint.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := [];
  Visible := False;

  BmpResurce := TBitMap.Create;
  RectBMP := TBitMap.Create;
  BmpResurce.Handle := LoadBitmap(hInstance, 'XHINT_SHADOW');
  if BmpResurce.Handle = 0 then
    raise ExHintError.Create('Can''t load resource bitmap');
  Font := TFont.Create;
end;

destructor TWindowHint.Destroy;
begin
  Font.Free;
  BMPResurce.Free;
  RectBMP.Free;

  inherited Destroy;
end;

procedure TWindowHint.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style:= WS_POPUP;
    WindowClass.hbrBackground := 0;
  end;
end;

procedure TWindowHint.Repaint;
begin
  Invalidate;
end;

procedure TWindowHint.Paint;

  // pause in milliseconds
  procedure DoDelay(Pause: LongWord);
  var
    OldTime: LongWord;
  begin
    OldTime := GetTickCount;
    while GetTickCount - OldTime <= Pause do { nothing };
  end;

var
  I: LongInt;
begin
  RectBMP.Width := W;
  RectBMP.Height := H;
  if (Animation <> anNone) or (Appearance = apApproachingBubble) then
  begin
    case Animation of
      anSlideLeftTop: NumberAnimation := 1;
      anSlideTop: NumberAnimation := 2;
      anUnfold: NumberAnimation := 3;
      anRandom: NumberAnimation := Random(3) + 1;
    end;
    if (Appearance = apRect) or (Appearance = apRoundRect) then
    begin
      FlagBMP := True;
      Time := 8;
      DrawWindowHint;
      FlagBMP := False;
    end;
    for I := 0 to 8 do
    begin
      if (Appearance <> apApproachingBubble) or
         ((Appearance = apApproachingBubble) and (Animation <> anNone)) then
        DoDelay(Speed);
      Time := I;
      DrawWindowHint;
    end;
  end
  else
  begin
    Time := 8;
    if (Appearance = apRect) or (Appearance = apRoundRect) then
    begin
      FlagBMP := True;
      DrawWindowHint;
      FlagBMP := False;
    end;
    DrawWindowHint;
  end;
end;

procedure TWindowHint.DrawBubble;
var
  I, T, DeltaX, DeltaY, DX, DY, X1, X2, Y1, Y2, SX, SY: Integer;
  S, SS: String;
  R: TRect;
  Alpha: Double;

  procedure TextDraw;
  var
    XX, YY: Integer;
  begin
    if (Appearance = apRect) or (Appearance = apRoundRect) then
    begin
      R.Left := 2 + BorderWidth;
      R.Right := W - 2 - BorderWidth;
    end
    else
    begin
      R.Left :=  X + (20 + W div 2 - Canvas.TextWidth(SS) div 2 - 1) * VStep;
      R.Right := X + (W div 2 + Canvas.TextWidth(SS) div 2 + 1 + 20) * VStep;
    end;
    if Lines <> 1 then
    begin
      R.Top := T;
      R.Bottom := T + Canvas.TextHeight(SS);
    end
    else
      if (Appearance = apRect) or (Appearance = apRoundRect) then
      begin
        R.Top := 2 + BorderWidth;
        R.Bottom := H - 2 - BorderWidth;
      end
      else
      begin
        R.Top := Y + (10 + H div 2 - Canvas.TextHeight(SS) div 2) * HStep;
        R.Bottom :=  Y + (H div 2 + Canvas.TextHeight(SS) div 2 + 10) * HStep;
      end;
    T := R.Bottom;
    if R.Left < R.Right then
      XX := R.Left
    else
      XX := R.Right;
    if R.Top < R.Bottom then
      YY := R.Top
    else
      YY := R.Bottom;
      if (Appearance = apRect) or (Appearance = apRoundRect) then
      begin
        RectBMP.Canvas.Brush.Style := bsClear;
        RectBMP.Canvas.TextRect(R, XX, YY, SS);
      end
      else
      begin
        Canvas.Brush.Style := bsClear;
        Canvas.TextRect(R, XX, YY, SS);
      end;
  end;

  procedure DrawRectHint(Index: Integer);
  var
    DX, DY: Integer;
    DeltaXX: Integer;

    procedure DrawRoundRect;
    var
      K: Integer;
    begin
      Canvas.RoundRect(0, 0, W - DeltaXX, H - DeltaY, 10, 10);
      for K := 0 to BorderWidth - 1 do
        Canvas.RoundRect(K, K, W - DeltaXX - K, H - DeltaY - K, 10, 10);
      DX := 1;
      DY := 3;
    end;

  begin
    DX := 0;
    DY := 0;
    case Index of
      1:
      begin
        DeltaXX := DeltaX;
        if Appearance = apRoundRect then
          DrawRoundRect;
        Canvas.CopyRect(RectSet(DX, DY, W - DeltaX - DX, H - DeltaY - DY),
             RectBMP.Canvas,
             RectSet(DeltaX + DX, DeltaY + DY,
             RectBMP.Width - DX, RectBMP.Height - DY));
      end;
      2:
      begin
        DeltaXX := 0;
        if Appearance = apRoundRect then
          DrawRoundRect;
        Canvas.CopyRect(RectSet(DX, DY, W - DX, H - DeltaY - DY),
             RectBMP.Canvas,
             RectSet(DX, DeltaY + DY,
             RectBMP.Width - DX, RectBMP.Height - DY));
      end;
      3:
      begin
        DeltaXX := DeltaX;
        if Appearance = apRoundRect then
          DrawRoundRect;
        Canvas.CopyRect(RectSet(DX, DY, W - DeltaX - DX, H - DeltaY - DY),
             RectBMP.Canvas,
             RectSet(DX, DeltaY + DY,
             RectBMP.Width - DX - DeltaX, RectBMP.Height - DY));
      end;
    end;
  end;


begin
  if X > 0 then
    SX := ShadowDepth
  else
    SX := 0;
  if Y > 0 then
    SY := ShadowDepth
  else
    SY := 0;

  Canvas.Brush.Color := Color;
  with Canvas do
  begin
    Brush.Color := Color;
    Pen.Color := BorderColor;
    if (Appearance <> apRect) and (Appearance <> apRoundRect) then
      Pen.Width := BorderWidth
    else
      Pen.Width := 1;
    case Appearance of
      apBubble:
      begin
        if Time > 0 then
          Ellipse(X - SX, Y - SY, X - SX + 7 * VStep, Y - SY + 5 * HStep);
        if Time > 1 then
          Ellipse(X - SX + 8 * VStep, Y - SY + 5 * HStep,
                  X - SX + 22 * VStep, Y - SY + 12 * HStep);
        if Time > 3 then
        begin
          DeltaX := Trunc((W * (8 - Time) / 8));
          DeltaY := Trunc((H * (8 - Time) / 8));
          Ellipse(X - SX + (20 +  DeltaX) * VStep, Y - SY + (10 + DeltaY) * HStep,
                  X - SX + (W + 20 - DeltaX) * VStep, Y - SY + (10 + H - DeltaY) * HStep);
        end;
      end;

      apCallout:
      begin
        Pen.Color := BorderColor;
        if Time = 8 then
        begin

          Ellipse(X - SX + 20 * VStep, Y - SY + 10 * HStep,
                  X - SX + (W + 20) * VStep, Y - SY + (10 + H) * HStep);
          Alpha := ArcTan((H / 2 + 10)/ (W / 2 + 20));
          X1 := Trunc(X - SX + (20 + W / 2 * (1 - cos(Alpha - Pi / 12))) * VStep);
          X2 := Trunc(X - SX + (20 + W / 2 * (1 - cos(Alpha + Pi / 9))) * VStep);
          Y1 := Trunc(Y - SY + (10 + H / 2 * (1 - sin(Alpha - Pi / 12))) * HStep);
          Y2 := Trunc(Y - SY + (10 + H / 2 * (1 - sin(Alpha + Pi / 9))) * HStep);
          Pen.Color := Color;
          Pen.Style := psClear;
          Polygon([Point(X - SX, Y - SY), Point(X1, Y1), Point(X2, Y2), Point(X - SX, Y - SY)]);
          Pen.Style := psSolid;
          Pen.Color := BorderColor;
          MoveTo(X1, Y1);
          LineTo(X - SX, Y - SY);
          LineTo(X2, Y2);
        end
        else
        begin
          DeltaX := Trunc((W * (8 - Time) / 14));
          DeltaY := Trunc((H * (8 - Time) / 14));
          Ellipse(X + (20 +  DeltaX) * VStep, Y + (10 + DeltaY) * HStep,
                  X + (W + 20 - DeltaX) * VStep, Y + (10 + H - DeltaY) * HStep);
        end;
      end;

      apApproachingBubble:
      begin
        DeltaX := Trunc((W * (8 - Time) / 7));
        DeltaY := Trunc((H * (8 - Time) / 7));
        DX := Trunc(5 * Time / 2);
        DY := Trunc(5 * Time / 4);
        Ellipse(X - SX + DX * VStep, Y - SY + DY * HStep,
                X - SX + (W + DX - DeltaX) * VStep, Y - SY + (H + DY - DeltaY) * HStep);
      end;

      apRect:
      begin
        RectBMP.Canvas.Brush.Color := Color;
        RectBMP.Canvas.Pen.Color := Canvas.Pen.Color;
        RectBMP.Canvas.Pen.Width := Canvas.Pen.Width;
        RectBMP.Canvas.Font.Assign(Font);

        DeltaX := Trunc((W * (8 - Time) / 7));
        DeltaY := Trunc((H * (8 - Time) / 7));

        if FlagBMP then
        begin
          RectBMP.Canvas.Rectangle(0, 0, W, H);
          for I := 0 to BorderWidth - 1 do
            RectBMP.Canvas.Rectangle(I, I, W - I, H - I);
        end
        else
          DrawRectHint(NumberAnimation);
      end;
      apRoundRect:
      begin
        RectBMP.Canvas.Brush.Color := Color;
        RectBMP.Canvas.Pen.Color := Canvas.Pen.Color;
        RectBMP.Canvas.Pen.Width := Canvas.Pen.Width;
        RectBMP.Canvas.Font.Assign(Font);
        DeltaX := Trunc((W * (8 - Time) / 7));
        DeltaY := Trunc((H * (8 - Time) / 7));
        RectBMP.Canvas.Pen.Style := psClear;
        if FlagBMP then
          RectBMP.Canvas.Rectangle(0, 0, W, H)
        else
          DrawRectHint(NumberAnimation);
      end;
    end;
  end;
  if Time = 8 then
  begin
    S := Caption;
    if (Appearance = apRect) or (Appearance = apRoundRect) then
      T := 2 + BorderWidth
    else
      if HStep > 0 then
        T := 20 + BorderWidth
      else
        T := 10 + BorderWidth;
    while True do
    begin
      if Pos(LineFeedStr, S) = 0 then
      begin
        SS := S;
        TextDraw;
        exit;
      end
      else
      begin
        SS := Copy(S, 0, Pos(LineFeedStr, S) - 1);
        S := Copy(S, Pos(LineFeedStr, S) + Length(LineFeedStr), 255);
        TextDraw;
      end;
    end;
  end;
end;

procedure TWindowHint.DrawShade;
var
  A, B, DeltaX, DeltaY, DX, DY, X1, X2, Y1, Y2, SX, SY: Integer;
  BmpWindow, Bmp, GridBmp: TBitmap;
  Alpha: Double;
begin
  if X > 0 then
    SX := ShadowDepth
  else
    SX := 0;
  if Y > 0 then
    SY := ShadowDepth
  else
    SY := 0;
  Bmp := TBitMap.Create;
  GridBmp := TBitMap.Create;
  BmpWindow := TBitMap.Create;
  try
    Bmp.Width := Width - ShadowDepth;
    Bmp.Height := Height - ShadowDepth;
    GridBmp.Width := Bmp.Width;
    GridBmp.Height := Bmp.Height;
    BMPWindow.Width := Bmp.Width + ShadowDepth;
    BMPWindow.Height := Bmp.Height + ShadowDepth;
    with Bmp.Canvas do
    begin
      Brush.Color := clBlack;
      Rectangle(0, 0, Bmp.Width, Bmp.Height);
      Brush.Color := clWhite;
      if (not FlagBMP) and (Time = 8) then
        case Appearance of
          apRect:
            Rectangle(0, 0, W, H);
          apRoundRect:
            RoundRect(0, 0, W, H, 10, 10);
          apBubble:
          begin
            Ellipse(X - SX, Y - SY, X - SX + 7 * VStep, Y - SY + 5 * HStep);
            Ellipse(X - SX + 8 * VStep, Y - SY + 5 * HStep,
                    X - SX + 22 * VStep, Y - SY + 12 * HStep);
            Ellipse(X - SX + 20 * VStep, Y - SY + 10 * HStep,
                    X - SX + (W + 20) * VStep, Y - SY + (10 + H) * HStep);
          end;
          apCallout:
          begin
            Ellipse(X - SX + 20 * VStep, Y - SY + 10 * HStep,
                    X - SX + (W + 20) * VStep, Y - SY + (10 + H) * HStep);
            Alpha := ArcTan((H / 2 + 10)/ (W / 2 + 20));
            X1 := Trunc(X - SX + (20 + W / 2 * (1 - cos(Alpha - Pi / 12))) * VStep);
            X2 := Trunc(X - SX + (20 + W / 2 * (1 - cos(Alpha + Pi / 9))) * VStep);
            Y1 := Trunc(Y - SY + (10 + H / 2 * (1 - sin(Alpha - Pi / 12))) * HStep);
            Y2 := Trunc(Y - SY + (10 + H / 2 * (1 - sin(Alpha + Pi / 9))) * HStep);
            Polygon([Point(X - SX, Y - SY), Point(X1, Y1), Point(X2, Y2), Point(X - SX, Y - SY)]);
          end;
          apApproachingBubble:
          begin
            DeltaX := Trunc((W * (8 - Time) / 7));
            DeltaY := Trunc((H * (8 - Time) / 7));
            DX := Trunc(5 * Time / 2);
            DY := Trunc(5 * Time / 4);
            Ellipse(X - SX + DX * VStep, Y - SY + DY * HStep,
                    X - SX + (W + DX - DeltaX) * VStep, Y - SY + (H + DY - DeltaY) * HStep);
          end;
        end;
    end;
    for A := 1 to (Bmp.Width div BMPResurce.Width) + 1 do
      for B := 1 to (Bmp.Height div BMPResurce.Height)  + 1 do
        GridBmp.Canvas.CopyRect(RectSet((A - 1) * BMPResurce.Width, (B - 1) * BMPResurce.Height,
                            A * BMPResurce.Width, B * BMPResurce.Height),
                            BMPResurce.Canvas,
                            RectSet(0, 0, BMPResurce.Width, BMPResurce.Height));
    BitBlt(GridBmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
           Bmp.Canvas.Handle, 0, 0, SrcAnd);
    BitBlt(GridBmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
           GridBmp.Canvas.Handle, 0, 0, NOTSRCCOPY);
    BitBlt(Canvas.Handle, 0 + ShadowDepth, 0 + ShadowDepth, BmpWindow.Width, BmpWindow.Height,
      GridBmp.Canvas.Handle, 0, 0, SRCAND);
    DrawBubble;
  finally
    Bmp.Free;
    GridBmp.Free;
    BMPWindow.Free;
  end;
end;


procedure TWindowHint.DrawWindowHint;
begin
  if FShadow then DrawShade
    else DrawBubble;
end;

procedure TWindowHint.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := -1;
end;

function GetSubCount(const Str, SubStr: String): Integer;
var
  I: Integer;
begin
  Result := 1;
  I := 1;
  while I <= Length(Str) do
  begin
    if Copy(Str, I, Length(SubStr)) = SubStr then
    begin
      Result := Result + 1;
      Inc(I, Length(SubStr));
    end else
      Inc(I);
  end;    
end;

function GetMaxStr(Str, SubStr: String): String;
var
  S: String;
begin
  Result := '';
  while True do
  begin
    if Pos(SubStr, Str) = 0 then
    begin
      if Result = '' then
        Result := Str;
      exit
    end
    else
    begin
      S := Copy(Str, 0, Pos(SubStr, Str) - 1);
      if Length(S) > Length(Result) then
        Result := S;
      Str := Copy(Str, Pos(SubStr, Str) + Length(SubStr), 255);
    end;
  end;
end;


{TxHint ---------------------------------------------}

constructor TxHint.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  if Assigned(xxHint) then
    raise ExHintError.Create('Only one instance of TxHint allowed');

  Application.OnDeActivate := DoDeActivate;
  RestoreFlag := True;
  FColor := DefColor;
  FBorderColor := DefBorderColor;
  FBorderWidth := DefBorderWidth;
  FAppearance := DefAppearance;
  FFont := TFont.Create;
  FFont.Name := DefFontName;
  FFont.Size := DefFontSize;
  FFont.Style := DefFontStyle;
  FEnabled := True;
  FMenuItemName := DefMenuItemName;
  FAnimation := anUnfold;
  FSpeed := DefSpeed;
  FShadowDepth := DefShadowDepth;
  TestWindow := False;

  FShadow := True;
  FLineFeedStr := DefDivideSymbol;
  WindowHint := TWindowHint.Create(nil);
  xxHint := Self;
  Popup := False;
  SavedBitmap := TBitmap.Create;
  if not (csDesigning in ComponentState) then
  begin
    OldOnDeActivate := Application.OnDeActivate;
    Application.OnDeActivate := DoOnDeActivate;
  end;
end;

destructor TxHint.Destroy;
begin
  FFont.Free;
  xxHint := nil;
  SavedBitmap.Free;
  if not (csDesigning in ComponentState) then
    Application.OnDeActivate := OldOnDeActivate;
  inherited Destroy;
end;

procedure TxHint.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
end;

procedure TxHint.SetHelpHandle(AHelpHandle: THandle);

var
  StandartComponent: Boolean;

  function TestItem(APopupMenu: TPopupMenu): Boolean;
  var
    I: Integer;
  begin
    StandartComponent := True;
    Result := False;
    if (APopupMenu <> nil) then
    begin
      I := APopupMenu.Items.IndexOf(NewItem(FMenuItemName,
        0, False, True, MyOnClick, 0, 'Name'));
    if I = -1 then
      begin
        Result := True;
        APopupMenu.Items.Add(NewLine);
        APopupMenu.Items.Add(NewItem(FMenuItemName, 0, False, True, MyOnClick, 0,
                                     'Name'));
        Popup := True;
        IndexItem := APopupMenu.Items.Count - 1;
      end;
    end;
  end;

begin
  if FEnabled then
  begin
    IndexItem := -1;
    HelpHandle := AHelpHandle;
    WinControl := FindControl(HelpHandle);
    if WinControl <> nil then
    begin
      HelpStr := WinControl.Hint;
      VerSB := True;
      HorSB := True;
      StandartComponent := False;
      if HelpStr <> '' then
      begin
        Popup := False;
        if WinControl is TForm then
        begin
          if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_VSCROLL <> 0) and
             TForm(WinControl).VertScrollBar.Visible then
          begin
            TForm(WinControl).VertScrollBar.Visible := False;
            VerSB := False;
          end;
          if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_HSCROLL <> 0) and
             TForm(WinControl).HorzScrollBar.Visible then
          begin
            TForm(WinControl).HorzScrollBar.Visible := False;
            HorSB := False;
          end;
          TestItem(TForm(WinControl).PopupMenu);
        end;
        if (WinControl is TEdit) then TestItem(TEdit(WinControl).PopupMenu);
        if (WinControl is TCheckListBox) then TestItem(TCheckListBox(WinControl).PopupMenu);
        if (WinControl is TMemo) then TestItem(TMemo(WinControl).PopupMenu);
        if (WinControl is TRichEdit) then TestItem(TRichEdit(WinControl).PopupMenu);
        if (WinControl is TDateTimePicker) then TestItem(TDateTimePicker(WinControl).PopupMenu);
        if (WinControl is TButton) then TestItem(TButton(WinControl).PopupMenu);
        if (WinControl is TCheckBox) then TestItem(TCheckBox(WinControl).PopupMenu);
        if (WinControl is TRadioButton) then TestItem(TRadioButton(WinControl).PopupMenu);
        if (WinControl is TListBox) then TestItem(TListBox(WinControl).PopupMenu);
        if (WinControl is TScrollBar) then TestItem(TScrollBar(WinControl).PopupMenu);
        if (WinControl is TGroupBox) then TestItem(TGroupBox(WinControl).PopupMenu);
        if (WinControl is TRadioGroup) then TestItem(TRadioGroup(WinControl).PopupMenu);
        if (WinControl is TPanel) then TestItem(TPanel(WinControl).PopupMenu);
        if (WinControl is TNoteBook) then TestItem(TNoteBook(WinControl).PopupMenu);
        if (WinControl is TMaskEdit) then TestItem(TMaskEdit(WinControl).PopupMenu);
//        if (WinControl is TOutline) then TestItem(TOutLine(WinControl).PopupMenu);
        if (WinControl is TStringGrid) then TestItem(TStringGrid(WinControl).PopupMenu);
        if (WinControl is TDrawGrid) then TestItem(TDrawGrid(WinControl).PopupMenu);
        if WinControl is TScrollBox then
        begin
          if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_VSCROLL <> 0) and
             TScrollBox(WinControl).VertScrollBar.Visible then
          begin
            TScrollBox(WinControl).VertScrollBar.Visible := False;
            VerSB := False;
          end;
          if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_HSCROLL <> 0) and
             TScrollBox(WinControl).HorzScrollBar.Visible then
          begin
            TScrollBox(WinControl).HorzScrollBar.Visible := False;
            HorSB := False;
          end;
          TestItem(TScrollBox(WinControl).PopupMenu);
        end;
        if (WinControl is TDBGrid) then TestItem(TDBGRid(WinControl).PopupMenu);
        if (WinControl is TDBNavigator) then TestItem(TDBNavigator(WinControl).PopupMenu);
        if (WinControl is TDBEdit) then TestItem(TDBEdit(WinControl).PopupMenu);
        if (WinControl is TDBMemo) then TestItem(TDBMemo(WinControl).PopupMenu);
        if (WinControl is TDBImage) then TestItem(TDBImage(WinControl).PopupMenu);
        if (WinControl is TDBListBox) then TestItem(TDBListBox(WinControl).PopupMenu);
        if (WinControl is TDBComboBox) then TestItem(TDBComboBox(WinControl).PopupMenu);
        if (WinControl is TDBCheckBox) then TestItem(TDBCheckBox(WinControl).PopupMenu);
        if (WinControl is TDBRadioGroup) then TestItem(TDBRadioGroup(WinControl).PopupMenu);
        if (WinControl is TTabSet) or (WinControl is TTabbedNotebook) or
           (WinControl is THeader) or (WinControl is TColorGrid) or
           (WinControl is TSpinButton) or (WinControl is TSpinEdit) or
           (WinControl is TDirectoryOutLine) or (WinControl is TCalendar) or
           (WinControl is TxBulbButton)then
          StandartComponent := True;
        Active := False;
        if not Popup then
          if StandartComponent then
          begin
            Active := True;
            ActivateWindow
          end
          else
            if SendMessage(WinControl.Handle, WM_XHINTMESSAGE, 0, Longint(@MyPopup)) = 1 then
              if MyPopup <> nil then
              begin
                TestItem(MyPopup);
                Popup := True;
              end
              else
              begin
                ActivateWindow;
                Active := True;
              end;
      end;
    end;
  end;
end;

procedure TxHint.ActivateWindow;
var
  WW, HH, LL, TT: Integer;
  R: TRect;
begin
  WindowHint.Parent:= WinControl;
  WindowHint.Canvas.Font.Assign(Font);
  WindowHint.Appearance := FAppearance;
  WindowHint.FShadow := FShadow;
  WindowHint.Color := FColor;
  WindowHint.Caption := TranslateText(HelpStr);
  WindowHint.LineFeedStr := FLineFeedStr;
  WindowHint.Speed := FSpeed;
  WindowHint.BorderColor := FBorderColor;
  WindowHint.BorderWidth := FBorderWidth;
  WindowHint.ShadowDepth := FShadowDepth;
  WindowHint.Animation := FAnimation;
  with WindowHint do
  begin
    Lines := GetSubCount(Caption, LineFeedStr);
    MaxStr := GetMaxStr(Caption, LineFeedStr);
    HStep := 1;
    VStep := 1;
    X := 0;
    Y := 0;
    WW := 0;
    HH := 0;
    GetWindowRect(GetDeskTopWindow, R);
    case FAppearance of
      apRect, apRoundRect:
      begin
        W := Trunc(Canvas.TextWidth(MaxStr) * 1.1 + BorderWidth * 2);
        H := Canvas.TextHeight(MaxStr) * Lines + 5 + BorderWidth * 2;
        WW := W + FShadowDepth;
        HH := H + FShadowDepth;
      end;
      apBubble, apApproachingBubble, apCallout:
      begin
        W := Canvas.TextWidth(MaxStr) + 50;
        H := Canvas.TextHeight(MaxStr) * Lines + 20;
        WW := W + FShadowDepth + 20;;
        HH := H + FShadowDepth + 10;
      end;
    end;
    if (LLeft + WW) > R.Right then
    begin
      LL := LLeft - WW;
      X := Width;
      VStep := -1;
    end
    else
      LL := LLeft;
    if (TTop + HH) > R.Bottom then
    begin
      TT := TTop - HH;
      Y := Height;
      HStep := -1;
    end
    else
      TT := TTop;
    Font.Assign(FFont);
    SetBounds(LL, TT, WW, HH);
    SaveBitmap; { saves screen under the hint }
    TestWindow := True;
{    Application.ProcessMessages;}
    Show;
  end;
end;

procedure TxHint.CancelWindow;
begin
  if WindowHint.Visible then
  begin
    WindowHint.Hide;
    if RestoreFlag then
    begin
      RestoreBitmap;
{      if (WinControl <> nil) and (GetParentForm(WinControl) <> nil) and Active then
        WinControl.Repaint;}
    end;
    RestoreFlag := True;
    if WinControl is TForm then
    begin
      if not VerSB then
        TForm(WinControl).VertScrollBar.Visible := not VerSB;
      if not HorSb then
        TForm(WinControl).HorzScrollBar.Visible := not HorSB;
    end;
    if WinControl is TScrollBox then
    begin
      if not VerSB then
        TScrollBox(WinControl).VertScrollBar.Visible := not VerSB;
      if not HorSb then
        TScrollBox(WinControl).HorzScrollBar.Visible := not HorSB;
    end;
    TestWindow := False;
    WindowHint.Parent:= nil;
  end;
end;

procedure TxHint.DeleteItem;

  procedure DeleteItems(APopupMenu: TPopupMenu);
  begin
    if (APopupMenu <> nil) and (IndexItem <> -1) then
    begin
      APopupMenu.Items.Delete(IndexItem - 1);
      APopupMenu.Items.Delete(IndexItem - 1);
    end;
    IndexItem := -1;
  end;

begin
  if WinControl <> nil then
  begin
    if (WinControl is TForm) then DeleteItems(TForm(WinControl).PopupMenu);
    if (WinControl is TEdit) then DeleteItems(TEdit(WinControl).PopupMenu);
    if (WinControl is TCheckListBox) then DeleteItems(TCheckListBox(WinControl).PopupMenu);
    if (WinControl is TMemo) then DeleteItems(TMemo(WinControl).PopupMenu);
    if (WinControl is TRichEdit) then DeleteItems(TRichEdit(WinControl).PopupMenu);
    if (WinControl is TButton) then DeleteItems(TButton(WinControl).PopupMenu);
    if (WinControl is TDateTimePicker) then DeleteItems(TDateTimePicker(WinControl).PopupMenu);
    if (WinControl is TCheckBox) then DeleteItems(TCheckBox(WinControl).PopupMenu);
    if (WinControl is TRadioButton) then DeleteItems(TRadioButton(WinControl).PopupMenu);
    if (WinControl is TListBox) then DeleteItems(TListBox(WinControl).PopupMenu);
    if (WinControl is TScrollBar) then DeleteItems(TScrollBar(WinControl).PopupMenu);
    if (WinControl is TGroupBox) then DeleteItems(TGroupBox(WinControl).PopupMenu);
    if (WinControl is TRadioGroup) then DeleteItems(TRadioGroup(WinControl).PopupMenu);
    if (WinControl is TPanel) then DeleteItems(TPanel(WinControl).PopupMenu);
    if (WinControl is TNotebook) then DeleteItems(TNotebook(WinControl).PopupMenu);
    if (WinControl is TMaskEdit) then DeleteItems(TMaskEdit(WinControl).PopupMenu);
//    if (WinControl is TOutline) then DeleteItems(TOutLine(WinControl).PopupMenu);
    if (WinControl is TStringGrid) then DeleteItems(TStringGrid(WinControl).PopupMenu);
    if (WinControl is TDrawGrid) then DeleteItems(TDrawGrid(WinControl).PopupMenu);
    if (WinControl is TScrollBox) then DeleteItems(TScrollBox(WinControl).PopupMenu);
    if (WinControl is TDBGrid) then DeleteItems(TDBGrid(WinControl).PopupMenu);
    if (WinControl is TDBNavigator) then DeleteItems(TDBNavigator(WinControl).PopupMenu);
    if (WinControl is TDBEdit) then DeleteItems(TDBEdit(WinControl).PopupMenu);
    if (WinControl is TDBMemo) then DeleteItems(TDBMemo(WinControl).PopupMenu);
    if (WinControl is TDBImage) then DeleteItems(TDBImage(WinControl).PopupMenu);
    if (WinControl is TDBListBox) then DeleteItems(TDBListBox(WinControl).PopupMenu);
    if (WinControl is TDBComboBox) then DeleteItems(TDBComboBox(WinControl).PopupMenu);
    if (WinControl is TDBCheckBox) then DeleteItems(TDBCheckBox(WinControl).PopupMenu);
    if (WinControl is TDBRadioGroup) then DeleteItems(TDBRadioGroup(WinControl).PopupMenu);
    if MyPopup <> nil then DeleteItems(MyPopup);
  end;
end;

procedure TxHint.MyOnClick(Sender: TObject);
begin
  DeleteItem;
  if (WinControl <> nil) and (GetParentForm(WinControl) <> nil) then
    WinControl.Repaint;
  CancelWindow;
  if WinControl is TForm then
  begin
    if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_VSCROLL <> 0) and
       TForm(WinControl).VertScrollBar.Visible then
    begin
      TForm(WinControl).VertScrollBar.Visible := False;
      VerSB := False;
    end;
    if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_HSCROLL <> 0) and
       TForm(WinControl).HorzScrollBar.Visible then
    begin
      TForm(WinControl).HorzScrollBar.Visible := False;
      HorSB := False;
    end;
  end;

  if WinControl is TScrollBox then
  begin
    if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_VSCROLL <> 0) and
       TForm(WinControl).VertScrollBar.Visible then
    begin
      TForm(WinControl).VertScrollBar.Visible := False;
      VerSB := False;
    end;
    if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_HSCROLL <> 0) and
       TForm(WinControl).HorzScrollBar.Visible then
    begin
      TForm(WinControl).HorzScrollBar.Visible := False;
      HorSB := False;
    end;
  end;
  if WinControl is TForm then
  begin
    if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_VSCROLL <> 0) and
       TForm(WinControl).VertScrollBar.Visible then
    begin
      TForm(WinControl).VertScrollBar.Visible := False;
      VerSB := False;
    end;
    if not (GetWindowLong(WinControl.Handle, GWL_STYLE) and WS_HSCROLL <> 0) and
       TForm(WinControl).HorzScrollBar.Visible then
    begin
      TForm(WinControl).HorzScrollBar.Visible := False;
      HorSB := False;
    end;
  end;
  ActivateWindow;
  Popup := False;
end;

procedure TxHint.DoDeActivate(Sender: TObject);
begin
  RestoreFlag := False;
  CancelWindow;
  Popup := False;
end;

procedure TxHint.SaveBitmap;
var
  R: TRect;
  Canvas: TCanvas;
begin
  { assumes that WindowHint has valid coordinates }
  GetWindowRect(WindowHint.Handle, R);
  SavedBitmap.Width := R.Right - R.Left{ + 1};
  SavedBitmap.Height := R.Bottom - R.Top{ + 1};
  Canvas := TCanvas.Create;
  try
    Canvas.Handle := GetDC(0);
    SavedBitmap.Canvas.CopyRect(Classes.Rect(0, 0, SavedBitmap.Width, SavedBitmap.Height),
      Canvas, R);
  finally
    ReleaseDC(0, Canvas.Handle);
    Canvas.Handle := 0;
    Canvas.Free;
  end;
end;

procedure TxHint.DoOnDeActivate(Sender: TObject);
begin
  if Popup then
    DeleteItem;
  Popup := False;
  if Assigned(OldOnDeActivate) then OldOnDeActivate(Sender);
end;

procedure TxHint.RestoreBitmap;
var
  R: TRect;
  Canvas: TCanvas;
begin
  { assumes that WindowHint has valid coordinates }
  { and these coordinates has not been changed since }
  { SaveBitmap call }
  GetWindowRect(WindowHint.Handle, R);
  Canvas := TCanvas.Create;
  try
    Canvas.Handle := GetDC(0);
    Canvas.Draw(R.Left, R.Top, SavedBitmap);
  finally
    ReleaseDC(0, Canvas.Handle);
    Canvas.Handle := 0;
    Canvas.Free;
  end;
end;

{Registration --------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-NonVisual', [TxHint]);
end;

{---------------------------------------------------------}

initialization

  WM_XHINTMESSAGE := RegisterWindowMessage('WM_XHINTMESSAGE');
  xxHint := nil;

  MouseHook := SetWindowsHookEx(WH_MOUSE, @MouseProc, hInstance,
    GetCurrentThreadID);

  MessageHook := SetWindowsHookEx(WH_GETMESSAGE, @MessageProc,
    hInstance, GetCurrentThreadID);

  Randomize;


finalization
  if Assigned(xxHint) then
  begin
    xxHint.Free;
    xxHint := nil;
  end;

  UnHookWindowsHookEx(MouseHook);
  UnHookWindowsHookEx(MessageHook);
end.
