
{++

  Copyright (c) 1995-97 by Golden Software of Belarus

  Module

    splitbar.pas

  Abstract

    A Delphi visual component. A split bar.

  Author

    Denis Romanovski (14-Nov-95)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    29-Nov-95    andreik,   Initial version.
                         dennis
    1.01    19-May-96    andreik    Fixed minor bugs.
                                    Added several properties.
    1.02    02-Jun-96    andreik    Fixed minor bug.
    1.03    29-Jun-96    andreik    Added notification method.
    1.04    20-Feb-97    andreik    Added animation effect.
    1.05    14-Mar-97    andreik    Default animation changed to false.
    1.06    20-Oct-97    andreik    Delphi32 version.

--}

unit SplitBar;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms,    Dialogs,  ExtCtrls, Menus;

type
  TSplitBarStyle = (sbHorizontal, sbVertical);
  TAppearance = (apRaised, apRecessed, apFlat, apTransparent, apCustom);
  TAlign = (alNone, alTop, alBottom, alLeft, alRight, alClient);

type
  TPaintSBEvent = procedure(Sender: TObject; Canvas: TCanvas;
    ClientRect: TRect) of object;
  TSBEvent = procedure(Sender: TObject; FirstRect, SecondRect: TRect) of object;
  TStartMovingSBEvent = procedure(Sender: TObject;
    var FirstRect, SecondRect: TRect) of object;

const
  DefAppearance = apRaised;
  DefStyle = sbHorizontal;
  DefFrame = True;
  DefBevelWidth = 1;
  DefAlign = alClient;
  DefDragSplitBar = False;
  DefThickness = 8;
  DefOverlaping = False;
  DefCursor = crVSplit;
  DefFrameColor = clWindowFrame;
  DefAnimation = False;

type
  TSplitBar = class(TCustomControl)
  private
    FAppearance: TAppearance;
    FStyle: TSplitBarStyle;
    FFrame: Boolean;
    FBevelWidth: Integer;
    FAlign: TAlign;
    FDragSplitBar: Boolean;
    FThickness: Integer;
    FOverlaping: Boolean;
    FFrameColor: TColor;
    FFirstControl, FSecondControl: TControl;
    FAnimation: Boolean;

    FOnPaint: TPaintSBEvent;
    FOnStartMoving: TStartMovingSBEvent;
    FOnMoving: TSBEvent;
    FOnMoved: TSBEvent;

    SplitBarRect: TRect;
    FirstRect, SecondRect: TRect;
    InitMousePos: Integer;
    OldParentStyle: LongInt;
    WasLButtonDown: Boolean;
    OldOnResize: TNotifyEvent;

    procedure SetStyle(AStyle: TSplitBarStyle);
    procedure SetAppearance(AnAppearance: TAppearance);
    procedure SetFrame(AFrame: Boolean);
    procedure SetBevelWidth(ABevelWidth: Integer);
    procedure SetAlign(AnAlign: TAlign);
    procedure SetThickness(AThickness: Integer);
    procedure SetOverlaping(AnOverlaping: Boolean);
    procedure SetFrameColor(AFrameColor: TColor);
    procedure SetOnPaint(AnOnPaint: TPaintSBEvent);
    function GetParentClientRect: TRect;

    procedure CalcBoundingRects;
    procedure CalcVertRects;
    procedure CalcHorizRects;
    procedure DoAlign;
    function NeedInAlign: Boolean;
    procedure WipeOverlaping;
    procedure RedrawSplitBars;

    procedure DoOnResize(Sender: TObject);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMMove(var Message: TWMMove);
      message WM_MOVE;

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Loaded; override;
    procedure Paint; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    property ParentClientRect: TRect read GetParentClientRect;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Appearance: TAppearance read FAppearance write SetAppearance
      default DefAppearance;
    property Style: TSplitBarStyle read FStyle write SetStyle default DefStyle;
    property Frame: Boolean read FFrame write SetFrame default DefFrame;
    property BevelWidth: Integer read FBevelWidth write SetBevelWidth
      default DefBevelWidth;
    property Align: TAlign read FAlign write SetAlign default DefAlign;
    property DragSplitBar: Boolean read FDragSplitBar write FDragSplitBar
      default DefDragSplitBar;
    property Thickness: Integer read FThickness write SetThickness
      default DefThickness;
    property Overlaping: Boolean read FOverlaping write SetOverlaping
      default DefOverlaping;
    property FrameColor: TColor read FFrameColor write SetFrameColor
      default DefFrameColor;
    property FirstControl: TControl read FFirstControl write FFirstControl;
    property SecondControl: TControl read FSecondControl write FSecondControl;
    property Animation: Boolean read FAnimation write FAnimation
      default DefAnimation;

    property OnPaint: TPaintSBEvent read FOnPaint write SetOnPaint;
    property OnStartMoving: TStartMovingSBEvent read FOnStartMoving write FOnStartMoving;
    property OnMoving: TSBEvent read FOnMoving write FOnMoving;
    property OnMoved: TSBEvent read FOnMoved write FOnMoved;

    property Color;
    property ShowHint;
    property ParentShowHint;
    property Width;
    property Height;
    property Enabled;
    property Visible;
    property ParentColor;
    property Cursor;
    property PopupMenu;

    property OnClick;
    property OnDblClick;
  end;

  ESplitBarError = class(Exception);

procedure Register;

implementation

uses
  Rect;

{ TSplitBar ----------------------------------------------}

constructor TSplitBar.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := [csCaptureMouse];

  FStyle := DefStyle;
  FAppearance := DefAppearance;
  FFrame := DefFrame;
  FBevelWidth := DefBevelWidth;
  FAlign := DefAlign;
  FDragSplitBar := DefDragSplitBar;
  FThickness := DefThickness;
  FOverlaping := DefOverlaping;
  FFrameColor := DefFrameColor;
  FAnimation := DefAnimation;

  Width := FThickness;
  Height := FThickness;
  Cursor := DefCursor;

  WasLButtonDown := False;
  OldOnResize := nil;
end;

destructor TSplitBar.Destroy;
begin
  if Parent is TForm then
    TForm(Parent).OnResize := OldOnResize
  else if Parent is TPanel then
    TPanel(Parent).OnResize := OldOnResize;

  inherited Destroy;
end;

procedure TSplitBar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    if FAppearance = apTransparent then
    begin
      WindowClass.hbrBackground := 0;
      ExStyle := WS_EX_TRANSPARENT;
      Style := Style and (not WS_CLIPSIBLINGS);
    end else
      Style := Style or WS_CLIPSIBLINGS;

    if Assigned(FOnPaint) then
      WindowClass.hbrBackground := 0;
  end;
end;

procedure TSplitBar.Loaded;
begin
  inherited Loaded;

  if not (csDesigning in ComponentState) then
  begin
    if Parent is TForm then
    begin
      OldOnResize := TForm(Parent).OnResize;
      TForm(Parent).OnResize := DoOnResize;
    end
    else if Parent is TPanel then
    begin
      OldOnResize := TPanel(Parent).OnResize;
      TPanel(Parent).OnResize := DoOnResize;
    end;
  end;
end;

procedure TSplitBar.Paint;

  function AdjustColor(C: Integer): Byte;
  begin
    if C < 0 then Result := 0
    else if C > 255 then Result := 255
    else Result := C;
  end;

  function MyRGB(R, G, B: Integer): LongInt;
  begin
    Result := RGB(AdjustColor(R), AdjustColor(G), AdjustColor(B));
  end;

const
  Delta = 96;

var
  R: TRect;

begin
  if FAppearance = apTransparent then exit;

  if FAppearance = apCustom then
    if Assigned(FOnPaint) then
    begin
      FOnPaint(Self, Canvas, GetClientRect);
      exit;
    end else
      if ComponentState = [] then
        raise ESplitBarError.Create('Not assigned OnPaint event');

  R := GetClientRect;

  if FFrame then
    Frame3D(Canvas, R, FFrameColor, FFrameColor, 1);

  case FAppearance of
    apRaised:
      Frame3D(Canvas, R, MyRGB(GetRValue(Color) + Delta, GetGValue(Color) + Delta,
        GetBValue(Color) + Delta), MyRGB(GetRValue(Color) - Delta, GetGValue(Color) - Delta,
        GetBValue(Color) - Delta), FBevelWidth);
    apRecessed:
      Frame3D(Canvas, R, MyRGB(GetRValue(Color) - Delta, GetGValue(Color) - Delta,
        GetBValue(Color) - Delta), MyRGB(GetRValue(Color) + Delta, GetGValue(Color) + Delta,
        GetBValue(Color) + Delta), FBevelWidth);
    apFlat: ;
  end;

  if not FOverlaping then WipeOverlaping;
end;

procedure TSplitBar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FFirstControl then
      FFirstControl := nil
    else if AComponent = FSecondControl then
      FSecondControl := nil;
  end;    

  inherited Notification(AComponent, Operation);
end;

procedure TSplitBar.SetStyle(AStyle: TSplitBarStyle);
begin
  if AStyle <> FStyle then
  begin
    FStyle := AStyle;

    if FAlign <> alNone then
      FAlign := alClient;

    if (FStyle = sbVertical) then
    begin
      if Cursor = crVSplit then Cursor := crHSplit;
      SetBounds(Left, Top, FThickness, Height);
    end else begin
      if Cursor = crHSplit then Cursor := crVSplit;
      SetBounds(Left, Top, Width, FThickness);
    end;
  end;
end;

procedure TSplitBar.SetAppearance(AnAppearance: TAppearance);
begin
  if AnAppearance <> FAppearance then
  begin
    if (AnAppearance = apCustom) and (not Assigned(FOnPaint))
      and (not (csLoading in ComponentState))  then
     raise ESplitBarError.Create('Assign OnPaint event first');
    FAppearance := AnAppearance;
    if FAppearance = apTransparent then
      FFrame := False;
    RecreateWnd;
  end;
end;

procedure TSplitBar.SetFrame(AFrame: Boolean);
begin
  if AFrame <> FFrame then
  begin
    FFrame := AFrame;
    Invalidate;
  end;
end;

procedure TSplitBar.SetBevelWidth(ABevelWidth: Integer);
begin
  if ABevelWidth <> FBevelWidth then
  begin
    FBevelWidth := ABevelWidth;
    Invalidate;
  end;
end;

procedure TSplitBar.SetAlign(AnAlign: TAlign);
begin
  if ((FStyle = sbVertical) and ((AnAlign = alLeft) or (AnAlign = alRight)))
    or ((FStyle = sbHorizontal) and ((AnAlign = alTop) or (AnAlign = alBottom))) then
   raise ESplitBarError.Create('Invalid align for this style');

  FAlign := AnAlign;

  DoAlign;
end;

procedure TSplitBar.SetThickness(AThickness: Integer);
begin
  if AThickness <> FThickness then
  begin
    FThickness := AThickness;
    case FStyle of
      sbVertical: Width := FThickness;
      sbHorizontal: Height := FThickness;
    end;
  end;
end;

procedure TSplitBar.SetOverlaping(AnOverlaping: Boolean);
begin
  if AnOverlaping <> FOverlaping then
  begin
    FOverlaping := AnOverlaping;
    Invalidate;
  end;
end;

procedure TSplitBar.SetFrameColor(AFrameColor: TColor);
begin
  if AFrameColor <> FFrameColor then
  begin
    FFrameColor := AFrameColor;
    Invalidate;
  end;
end;

procedure TSplitBar.SetOnPaint(AnOnPaint: TPaintSBEvent);
begin
  if @AnOnPaint <> @FOnPaint then
  begin
    FOnPaint := AnOnPaint;
    FAppearance := apCustom;
  end;
end;

function Ternary(Cond: Boolean; A, B: Integer): Integer;
begin
  if Cond then Result := A
    else Result := B;
end;

function TSplitBar.GetParentClientRect: TRect;
var
  T: TPanel;
begin
  Result := Parent.ClientRect;

  if Parent is TPanel then
  begin
    T := Parent as TPanel;
    Result.Left := Result.Left + T.BevelWidth *
      (Ternary(T.BevelInner <> bvNone, 1, 0) + Ternary(T.BevelOuter <> bvNone, 1, 0)) +
      T.BorderWidth;
    Result.Right := Result.Right - T.BevelWidth *
      (Ternary(T.BevelInner <> bvNone, 1, 0) + Ternary(T.BevelOuter <> bvNone, 1, 0)) -
      T.BorderWidth;
    Result.Top := Result.Top + T.BevelWidth *
      (Ternary(T.BevelInner <> bvNone, 1, 0) + Ternary(T.BevelOuter <> bvNone, 1, 0)) +
      T.BorderWidth;
    Result.Bottom := Result.Bottom - T.BevelWidth *
      (Ternary(T.BevelInner <> bvNone, 1, 0) + Ternary(T.BevelOuter <> bvNone, 1, 0)) -
      T.BorderWidth;
  end;
end;

procedure TSplitBar.CalcBoundingRects;
begin
  case FStyle of
    sbVertical: CalcVertRects;
    sbHorizontal: CalcHorizRects;
  end;
end;

procedure TSplitBar.CalcVertRects;
var
  I: Integer;
  R, MaxRect: TRect;
  SB: TSplitBar;
begin
  MaxRect := RectSet(ParentClientRect.Left, Top, ParentClientRect.Right, Top + Height);

  for I := 0 to Parent.ControlCount - 1 do
    if (Parent.Controls[I] is TSplitBar) and (Parent.Controls[I] <> Self) and
      (TSplitBar(Parent.Controls[I]).Style = FStyle) then
    begin
      SB := TSplitBar(Parent.Controls[I]);
      R := RectSet(SB.Left, SB.Top, SB.Left + SB.Width, SB.Top + SB.Height);

      if RectIsIntersection(R, MaxRect) then
      begin
        if Left < R.Left then
          MaxRect.Right := R.Left
        else
          MaxRect.Left := R.Right;
      end;
    end;

  FirstRect := RectSet(MaxRect.Left, MaxRect.Top, Left, MaxRect.Bottom);
  SecondRect := RectSet(Left + Width, MaxRect.Top, MaxRect.Right, MaxRect.Bottom);
end;

procedure TSplitBar.CalcHorizRects;
var
  I: Integer;
  R, MaxRect: TRect;
  SB: TSplitBar;
begin
  MaxRect := RectSet(Left, ParentClientRect.Top, Left + Width, ParentClientRect.Bottom);

  for I := 0 to Parent.ControlCount - 1 do
    if (Parent.Controls[I] is TSplitBar) and (Parent.Controls[I] <> Self) and
    (TSplitBar(Parent.Controls[I]).Style = FStyle) then
    begin
      SB := TSplitBar(Parent.Controls[I]);
      R := RectSet(SB.Left, SB.Top, SB.Left + SB.Width, SB.Top + SB.Height);

      if RectIsIntersection(R, MaxRect) then
      begin
        if Top < R.Top then
          MaxRect.Bottom := R.Top
        else
          MaxRect.Top := R.Bottom;
      end;
    end;

  FirstRect := RectSet(Left, MaxRect.Top, Left + Width, Top);
  SecondRect := RectSet(Left, Top + Height, Left + Width, MaxRect.Bottom);
end;

procedure TSplitBar.DoAlign;
begin
  case Align of
    alLeft: Left := ParentClientRect.Left;
    alRight: Left := ParentClientRect.Right - Width;
    alTop: Top := ParentClientRect.Top;
    alBottom: Top := ParentClientRect.Bottom - Height;
    alClient:
      case Style of
        sbVertical:
          begin
            Top := ParentClientRect.Top;
            Height := ParentClientRect.Bottom - ParentClientRect.Top;
          end;
        sbHorizontal:
          begin
            Left := ParentClientRect.Left;
            Width := ParentClientRect.Right - ParentClientRect.Left;
          end;
      end;
  end;
end;

function TSplitBar.NeedInAlign: Boolean;
begin
  case FAlign of
    alLeft: Result := Left <> 0;
    alRight: Result := Left <> ParentClientRect.Right - Width;
    alTop: Result := Top <> 0;
    alBottom: Result := Top <> ParentClientRect.Bottom - Height;
    alClient:
        if (FStyle = sbVertical) then
          Result := (Top <> 0) or (Top + Height <> ParentClientRect.Bottom)
        else
          Result := (Left <> 0) or (Left + Width <> ParentClientRect.Right);
    alNone: Result := False;
  else
    Result := True;  
  end;
end;

procedure TSplitBar.WipeOverlaping;
var
  I, FrameThickness: Integer;
  SB: TSplitBar;
  R, R2: TRect;
begin
  for I := 0 to Parent.ControlCount - 1 do
    if (Parent.Controls[I] is TSplitBar) and (Parent.Controls[I] <> Self) and
      (TSplitBar(Parent.Controls[I]).Style <> FStyle) then
    begin
      SB := TSplitBar(Parent.Controls[I]);
      R := RectSet(Left, Top, Left + Width, Top + Height);
      R2 := RectSet(SB.Left, SB.Top, SB.Left + SB.Width, SB.Top + SB.Height);

      R := RectIntersection(R2, R);
      if not RectIsNull(R) then
      begin
        R := RectSetPoint(ScreenToClient(Parent.ClientToScreen(R.TopLeft)),
          ScreenToClient(Parent.ClientToScreen(R.BottomRight)));

        if FFrame then FrameThickness := 1
          else FrameThickness := 0;

        if ParentClientRect.Right = Left + Width then
          Dec(R.Right, FBevelWidth + FrameThickness);

        if ParentClientRect.Bottom = Top + Height then
          Dec(R.Bottom, FBevelWidth + FrameThickness);

        if Top = 0 then
          Inc(R.Top, FBevelWidth + FrameThickness);

        if Left = 0 then
          Inc(R.Left, FBevelWidth + FrameThickness);

        Canvas.Brush.Color := Color;
        Canvas.Brush.Style := bsSolid;
        Canvas.FillRect(R);
      end;
    end;
end;

procedure TSplitBar.RedrawSplitBars;
var
  I: Integer;
begin
  for I := 0 to Parent.ControlCount - 1 do
    if (Parent.Controls[I] is TSplitBar) and
      (not TSplitBar(Parent.Controls[I]).FOverlaping) then
     Parent.Controls[I].Invalidate;
end;

procedure TSplitBar.DoOnResize(Sender: TObject);
begin
  if Assigned(OldOnResize) then OldOnResize(Sender);

  DoAlign;

  if not FOverlaping then RedrawSplitBars;

  if FStyle = sbVertical then
  begin
    FirstRect := RectSet(ParentClientRect.Left, Top, Left, Top + Height);
    SecondRect := RectSet(Left + Width, Top, ParentClientRect.Right, Top + Height);
  end else begin
    { sbHorizontal }
    FirstRect := RectSet(Left, ParentClientRect.Top, Left + Width, Top);
    SecondRect := RectSet(Left, Top + Height, Left + Width, ParentClientRect.Bottom);
  end;

  if Assigned(FFirstControl) then
    FFirstControl.SetBounds(FirstRect.Left, FirstRect.Top,
      FirstRect.Right - FirstRect.Left, FirstRect.Bottom - FirstRect.Top);

  if Assigned(FSecondControl) then
    FSecondControl.SetBounds(SecondRect.Left, SecondRect.Top,
      SecondRect.Right - SecondRect.Left, SecondRect.Bottom - SecondRect.Top);

  if Assigned(FOnMoved) then
    FOnMoved(Self, SecondRect, SecondRect);
end;

procedure TSplitBar.WMLButtonDown(var Message: TWMLButtonDown);
var
  DC: HDC;
  R: TRect;
begin
  inherited;

  WasLButtonDown := True;

  with Message do
  begin
    if FStyle = sbVertical then
    begin
      OldParentStyle := SetWindowLong(Parent.Handle, GWL_STYLE,
        GetWindowLong(Parent.Handle, GWL_STYLE) and (not WS_CLIPCHILDREN));

      InitMousePos := Message.XPos;
      CalcBoundingRects;

      if Assigned(FOnStartMoving) then
      begin
        FOnStartMoving(Self, FirstRect, SecondRect);
        if (not RectsAreValid([FirstRect, SecondRect]))
          or (RectIsIntersection(FirstRect, SecondRect))
          or (not RectInclude(ParentClientRect, FirstRect))
          or (not RectInclude(ParentClientRect, SecondRect)) then
         raise ESplitBarError.Create('Invalid rectangles are specified');
      end;

      GetWindowRect(Parent.Handle, R);
      R := RectSet(FirstRect.Left, FirstRect.Top, SecondRect.Right, SecondRect.Bottom);

      R.TopLeft := Parent.ClientToScreen(Point(R.Left, R.Top));
      R.BottomRight := Parent.ClientToScreen(Point(R.Right, R.Bottom));

      Inc(R.Left, InitMousePos);
      Dec(R.Right, Width - InitMousePos - 1);
      ClipCursor(@R);

      SplitBarRect := RectSet(Left, Top, Left + Width, Top + Height);

      if not FDragSplitBar then
      begin
        DC := GetDC(Parent.Handle);
        InvertRect(DC, SplitBarRect);
        ReleaseDC(Parent.Handle, DC);
      end;
    end else
    begin
      OldParentStyle := SetWindowLong(Parent.Handle, GWL_STYLE,
        GetWindowLong(Parent.Handle, GWL_STYLE) and not WS_CLIPCHILDREN);

      InitMousePos := Message.YPos;
      CalcBoundingRects;

      if Assigned(FOnStartMoving) then FOnStartMoving(Self, FirstRect, SecondRect);

      R := RectSet(FirstRect.Left, FirstRect.Top, SecondRect.Right, SecondRect.Bottom);

      R.TopLeft := Parent.ClientToScreen(Point(R.Left, R.Top));
      R.BottomRight := Parent.ClientToScreen(Point(R.Right, R.Bottom));

      Inc(R.Top, InitMousePos);
      Dec(R.Bottom, Height - InitMousePos - 1);
      ClipCursor(@R);

      SplitBarRect := RectSet(Left, Top, Left + Width, Top + Height);

      if not FDragSplitBar then
      begin
        DC := GetDC(Parent.Handle);
        InvertRect(DC, SplitBarRect);
        ReleaseDC(Parent.Handle, DC);
      end;
    end;
  end;
end;

procedure TSplitBar.WMLButtonUp(var Message: TWMLButtonUp);
var
  DC: HDC;
  DX, DY: Integer;
begin
  inherited;

  if WasLButtonDown then WasLButtonDown := False
    else exit;

  with Message do
    if not FDragSplitBar then
    begin
      DC := GetDC(Parent.Handle);
      InvertRect(DC, SplitBarRect);
      ReleaseDC(Parent.Handle, DC);
    end;

  SetWindowLong(Parent.Handle, GWL_STYLE, OldParentStyle);
  ClipCursor(nil);

  if not FDragSplitBar then
  begin
    if FAnimation then
    begin
      if FStyle = sbVertical then
      begin
        if SplitBarRect.Left < Left then DX := -1
          else DX := 1;

        while (SplitBarRect.Left - Left) * DX > 30 do
          Left := Left + 30 * DX;
      end else
      begin
        if SplitBarRect.Top < Top then DY := -1
          else DY := 1;

        while (SplitBarRect.Top - Top) * DY > 20 do
          Top := Top + 20 * DY;
      end;
    end;

    SetBounds(SplitBarRect.Left, SplitBarRect.Top, Width, Height);
  end;
end;

procedure TSplitBar.WMMouseMove(var Message: TWMMouseMove);
var
  DC: HDC;
begin
  inherited;

  if not WasLButtonDown then exit;

  with Message do
  begin
    if FStyle = sbVertical then
    begin
      if SplitBarRect.Left = Left + Message.XPos - InitMousePos then
        exit;

      if not FDragSplitBar then
      begin
        DC := GetDC(Parent.Handle);
        InvertRect(DC, SplitBarRect);
        ReleaseDC(Parent.Handle, DC);
      end;

      SplitBarRect := RectSet(Left + XPos - InitMousePos, Top,
        Left + XPos + Width - InitMousePos, Top + Height);

      if not FDragSplitBar then
      begin
        DC := GetDC(Parent.Handle);
        InvertRect(DC, SplitBarRect);
        ReleaseDC(Parent.Handle, DC);
      end else
        SetBounds(SplitBarRect.Left, SplitBarRect.Top, Width, Height);

      FirstRect := RectSet(ParentClientRect.Left, SplitBarRect.Top, SplitBarRect.Left,
        SplitBarRect.Bottom);
      SecondRect := RectSet(SplitBarRect.Right, Top, ParentClientRect.Right,
        SplitBarRect.Bottom);

      if Assigned(FOnMoving) then FOnMoving(Self, FirstRect, SecondRect);
    end else
    begin
      if SplitBarRect.Top = Top + Message.YPos - InitMousePos then
        exit;

      if not FDragSplitBar then
      begin
        DC := GetDC(Parent.Handle);
        InvertRect(DC, SplitBarRect);
        ReleaseDC(Parent.Handle, DC);
      end;

      SplitBarRect := RectSet(Left, Top + YPos - InitMousePos,
        Left + Width, Top + Height + YPos - InitMousePos);

      if not FDragSplitBar then
      begin
        DC := GetDC(Parent.Handle);
        InvertRect(DC, SplitBarRect);
        ReleaseDC(Parent.Handle, DC);
      end else
        SetBounds(SplitBarRect.Left, SplitBarRect.Top, Width, Height);

      FirstRect := RectSet(SplitBarRect.Left, ParentClientRect.Top, SplitBarRect.Right,
        SplitBarRect.Top);
      SecondRect := RectSet(SplitBarRect.Left, SplitBarRect.Bottom, SplitBarRect.Right,
        ParentClientRect.Bottom);

      if Assigned(FOnMoving) then FOnMoving(Self, FirstRect, SecondRect);
    end;
  end;
end;

procedure TSplitBar.WMSize(var Message: TWMSize);
begin
  inherited;

  if NeedInAlign then DoAlign;

  case FStyle of
    sbVertical: FThickness := Width;
    sbHorizontal: FThickness := Height;
  end;

  if not FOverlaping then RedrawSplitBars;
end;

procedure TSplitBar.WMMove(var Message: TWMMove);
begin
  inherited;

  if NeedInAlign then DoAlign;

  if not FOverlaping then RedrawSplitBars;

  if FStyle = sbVertical then
  begin
    FirstRect := RectSet(ParentClientRect.Left, Top, Left, Top + Height);
    SecondRect := RectSet(Left + Width, Top, ParentClientRect.Right, Top + Height);
  end else begin
    FirstRect := RectSet(Left, ParentClientRect.Top, Left + Width, Top);
    SecondRect := RectSet(Left, Top + Height, Left + Width, ParentClientRect.Bottom);
  end;

  if Assigned(FFirstControl) then
    FFirstControl.SetBounds(FirstRect.Left, FirstRect.Top,
      FirstRect.Right - FirstRect.Left, FirstRect.Bottom - FirstRect.Top);

  if Assigned(FSecondControl) then
    FSecondControl.SetBounds(SecondRect.Left, SecondRect.Top,
      SecondRect.Right - SecondRect.Left, SecondRect.Bottom - SecondRect.Top);

  if Assigned(FOnMoved) then
    FOnMoved(Self, SecondRect, SecondRect);
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-VisualControl', [TSplitBar]);
end;

end.
