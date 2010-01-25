
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xslider.pas

  Abstract

    A scroll-bar like control.

  Author

    Anton Smirnov (1-Jan-96)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    19-Feb-96    anton,     Initial version.
                         andreik
    1.01    10-Dec-96    anton,     Draw error thumb.
    1.02    20-Oct-97    andreik    Ported to Delphi32.

--}

unit xSlider;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus;

const
  Def_Min = 0;
  Def_Max = 1;
  Def_Value = 0;
  Def_StrikeCount = 10;
  Def_ScaleGap = 8;
  Def_RailBevelWidth = 1;
  Def_RailWidth = 3;
  Def_ScaleWidth = 6;
  BorderBevel = 5;

type
  TLayout = (loVertLeft, loVertRight, loVertCenter, loHorzTop, loHorzBottom, loHorzCenter);
  TOrientation = (oVert, oHorz);
  TScaleView = (svNone, svStrikes, svTriangle, svStrikes3D);
  TScaleBevel = (sbNone, sbLowered, sbRaised);

type
  TxSlider = class(TCustomControl)
  private
    FLayout: TLayout;
    FOnChange: TNotifyEvent;
    FMax, FMin, FValue: Double;
    FScale: TScaleView;
    FStrikeCount: Word;
    FRailWidth, FRailBevelWidth: Integer;
    FRailRaised, FScaleRaised: Boolean;
    FScaleGap, FScaleWidth: Integer;
    FBevelInner, FBevelOuter: TScaleBevel;
    FThumbBitmap: TBitmap;
    FConvertColors: Boolean;
    FColor: TColor;

    Range: Double;
    Orientation: TOrientation;
    ScaleCoord, OrientationCoord: Integer;
    Press: Boolean;
    OldValue: Double;
    BorderRect: TRect;
    Margine, CursorHalfLong, CursorHalfShoat: Integer;
    Border: Integer;
    BMPSpace, OldBitmap: TBitmap;
    TestBMP, Space: Boolean;
    ScaleCenter : Integer;
    ColBtnFace, ColBtnShadow, ColBtnHighLight: TColor;

    procedure SetLayout(ALayout: TLayout);
    procedure SetMin(AMin: Double);
    procedure SetMax(AMax: Double);
    procedure SetValue(AValue: Double);
    procedure SetScale(AScale: TScaleView);
    procedure SetStrikeCount(AStrikeCount: Word);
    procedure SetRailBevelWidth(ARailBevelWidth: Integer);
    procedure SetRailWidth(ARailWidth: Integer);
    procedure SetIntValue(AnIntValue: LongInt);
    procedure SetRailRaised(ARailRaised: Boolean);
    procedure SetScaleRaised(AScaleRaised: Boolean);
    procedure SetScaleGap(AScaleGap: Integer);
    procedure SetScaleWidth(AScaleWidth: Integer);
    procedure SeTScaleBevelInner(ABevelInner: TScaleBevel);
    procedure SeTScaleBevelOuter(ABevelOuter: TScaleBevel);
    procedure SetThumbBitmap(AThumbBitmap: TBitmap);
    procedure SetConvertColors(AConvertColors: Boolean);
    procedure SetColor(AColor: TColor);
    function GetIntValue: LongInt;

    procedure DrawCursor;
    procedure DrawFocus;
    procedure DrawHorzScale;
    procedure DrawVertScale;
    procedure SizeCursor;
    procedure DoOnExit(Sender: TObject);
    procedure DoOnEnter(Sender: TObject);
    procedure Convert;

    procedure LoadBmp(Id: PChar);

    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LButtonUp;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KeyDown;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode);
      message WM_GetDlgCode;

  protected
    procedure WNDProc(var Message: TMessage); override;
    procedure Loaded; override;
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure ThumbSize;
    procedure Repaint; override;

  published
    property Layout: TLayout read FLayout write SetLayout default loVertLeft;
    property Min: Double read FMin write SetMin;
    property Max: Double read FMax write SetMax;
    property Value: Double read FValue write SetValue;
    property IntValue: LongInt read GetIntValue write SetIntValue;
    property Scale: TScaleView read FScale write SetScale default svNone;
    property StrikeCount: Word read FStrikeCount write SetStrikeCount;
    property RailWidth: Integer read FRailWidth write SetRailWidth;
    property RailBevelWidth: Integer read FRailBevelWidth write SetRailBevelWidth;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property RailRaised: Boolean read FRailRaised write SetRailRaised default True;
    property ScaleRaised: Boolean read FScaleRaised write SetScaleRaised default True;
    property ScaleGap: Integer read FScaleGap write SetScaleGap;
    property ScaleWidth: Integer read FScaleWidth write SetScaleWidth;
    property BevelInner: TScaleBevel read FBevelInner write SeTScaleBevelInner default sbNone;
    property BevelOuter: TScaleBevel read FBevelOuter write SeTScaleBevelOuter default sbNone;
    property TabOrder;
    property TabStop;
    property ThumbBitmap: TBitmap read FThumbBitmap write SetThumbBitmap;
    property ConvertColors: Boolean read FConvertColors write SetConvertColors
      default True;
    property Color: TColor read FColor write SetColor;
    property Visible;
    property PopupMenu;
  end;

  ESliderError = class(Exception);

procedure Register;

{var
  WM_XHINTMESSAGE: Word;}

implementation

{$R XSLIDER.RES}

uses Rect, ExtCtrls;

{TxSlider ------------------------------------------------}

constructor TxSlider.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle:= ControlStyle + [csCaptureMouse];

  FLayout := loVertLeft;
  FMin := Def_Min;
  FMax := Def_Max;
  FValue := Def_Value;
  FScale := svNone;
  FStrikeCount := Def_StrikeCount;
  FRailWidth := Def_RailWidth;
  FRailBevelWidth := Def_RailBevelWidth;
  FRailRaised := True;
  FScaleRaised := True;
  FScaleGap := Def_ScaleGap;
  FScaleWidth := Def_ScaleWidth;
  FColor := clBtnFace;

  FThumbBitmap := TBitmap.Create;
  FConvertColors := True;

  ColBtnFace := clBtnFace;
  ColBtnShadow := clBtnShadow;
  ColBtnHighLight := clBtnHighLight;
  ScaleCenter := FScaleGap + FScaleWidth;
  BMPSpace := TBitmap.Create;
  Space := True;
  Orientation := oVert;
  Height := 100;
  Width := 50;
  Press := False;
  Range := FMax - FMin;
  TabStop := True;
  TestBMP := False;
  BorderRect := RectSet(0, 0, Width, Height);
  LoadBMP('XREG_VLEFT');
  SizeCursor;
  OldBitmap := TBitmap.Create;

  OnExit := DoOnExit;
  OnEnter := DoOnEnter;
  FLayout := loVertLeft;
  Layout := Layout;

end;

destructor TxSlider.Destroy;
begin
  FThumbBitmap.Free;
  BMPSpace.Free;
  OldBitmap.Free;
  inherited Destroy;
end;

procedure TxSlider.ThumbSize;
begin
  SizeCursor;
  Repaint;
end;

procedure TxSlider.Loaded;
var
  L: TLayout;
begin
  inherited Loaded;
  if FThumbBitmap.Empty then
  begin
    FThumbBitmap.Free;
    LoadBMP('XREG_VLEFT');
  end
  else
  begin
    if not (((FThumbBitmap.Width <> 44) and (FThumbBitmap.Height <> 24)) and
       ((FThumbBitmap.Width <> 24) and (FThumbBitmap.Height <> 22))) then
    begin
      TestBMP := False;
      L := FLayout;
      Layout := loHorzTop;
      Layout := L;
    end
    else
      TestBMP := True;
  end;
  Convert;
  SizeCursor;
end;

procedure TxSlider.Repaint;
begin
  if HandleAllocated then
    InvalidateRect(Handle, nil, True);
end;

procedure TxSlider.Paint;
var
  WSS, SC: Integer;

  procedure HorzDraw;
  var
    I, Coord: Integer;

    procedure HTop;
    begin
      with Canvas do
      begin
        if FScaleRaised then
          Pen.Color := ColBtnHighLight
        else
          Pen.Color := ColBtnShadow;
        MoveTo(Margine, ScaleCoord - FScaleWidth );
        LineTo(Width - Margine, ScaleCoord - FScaleWidth);
        if FScaleRaised then
          Pen.Color := ColBtnShadow
        else
          Pen.Color := ColBtnHighLight;
        LineTo(Width - Margine, ScaleCoord + FScaleWidth);
        LineTo(Margine, ScaleCoord - FScaleWidth);
      end;
    end;

    procedure HBottom;
    begin
      with Canvas do
      begin
        if FScaleRaised then
          Pen.Color := ColBtnShadow
        else
          Pen.Color := ColBtnHighLight;
        MoveTo(Width - Margine, ScaleCoord - FScaleWidth);
        LineTo(Width - Margine, ScaleCoord + FScaleWidth);
        LineTo(Margine, ScaleCoord + FScaleWidth);
        if FScaleRaised then
          Pen.Color := ColBtnHighLight
        else
          Pen.Color := ColBtnShadow;
        LineTo(Width - Margine, ScaleCoord - FScaleWidth);
      end;
    end;

  begin
    with Canvas do
    begin
      DrawHorzScale;
      Pen.Color := ColBtnShadow;
      Pen.Width := 1;
      case FScale of
        svStrikes, svStrikes3D:
        for I := 1 to FStrikeCount do
        begin
          Coord := Round(Margine + (I - 1) * (Width - Margine * 2) / (FStrikeCount - 1)) - BorderBevel div 2;
          if FScaleRaised or (FScale = svStrikes) then
            Pen.Color := ColBtnShadow
          else
            Pen.Color := ColBtnHighLight;
          if (I = 1) or (I = FStrikeCount) then
          begin
            WSS := FScaleWidth;
            if FLayout = loHorzTop then
              SC := ScaleCoord - Round(1 / 3 * FScaleWidth)
            else
              SC := ScaleCoord + Round(1 / 3 * FScaleWidth);
          end
          else
          begin
            SC := ScaleCoord;
            WSS := Round(2 / 3 * FScaleWidth);
          end;
          MoveTo(Coord, SC - WSS);
          LineTo(Coord, SC + WSS);
          if FScale = svStrikes3D then
          begin
            if FScaleRaised then
              Pen.Color := ColBtnHighLight
            else
              Pen.Color := ColBtnShadow;
            MoveTo(Coord + 1, SC - WSS);
            LineTo(Coord + 1, SC + WSS);
          end;
          if FLayout = loHorzCenter then
          begin
          if FScaleRaised or (FScale = svStrikes) then
            Pen.Color := ColBtnShadow
          else
            Pen.Color := ColBtnHighLight;
            MoveTo(Coord, Height - SC - WSS);
            LineTo(Coord, Height - SC + WSS);
            if FScale = svStrikes3D then
            begin
              if FScaleRaised then
                Pen.Color := ColBtnHighLight
              else
                Pen.Color := ColBtnShadow;
              MoveTo(Coord + 1, Height - SC - WSS);
              LineTo(Coord + 1, Height - SC + WSS);
            end;
          end;
        end;
        svTriangle:
          case Layout of
            loHorzTop: HTop;
            loHorzBottom: HBottom;
            loHorzCenter:
            begin
              HBottom;
              ScaleCoord := Height - ScaleCoord;
              HTop;
            end;
          end;
      end;
   end;
  end;

  procedure VertDraw;
  var
    I, Coord: Integer;

    procedure VLeft;
    begin
      with Canvas do
      begin
        if FScaleRaised then
          Pen.Color := ColBtnShadow
        else
          Pen.Color := ColBtnHighLight;
        MoveTo(ScaleCoord + FScaleWidth, Margine);
        LineTo(ScaleCoord + FScaleWidth, Height - Margine);
        if FScaleRaised then
          Pen.Color := ColBtnHighLight
        else
          Pen.Color := ColBtnShadow;
        LineTo(ScaleCoord - FScaleWidth, Margine);
        LineTo(ScaleCoord + FScaleWidth, Margine);
      end;
    end;

    procedure VRight;
    begin
      with Canvas do
      begin
        if FScaleRaised then
          Pen.Color := ColBtnHighLight
        else
          Pen.Color := ColBtnShadow;
        MoveTo(ScaleCoord + FScaleWidth, Margine);
        LineTo(ScaleCoord - FScaleWidth, Margine);
        LineTo(ScaleCoord - FScaleWidth, Height - Margine);
        if FScaleRaised then
          Pen.Color := ColBtnShadow
        else
          Pen.Color := ColBtnHighLight;
        LineTo(ScaleCoord + FScaleWidth, Margine);
      end;
    end;

  begin
    with Canvas do
    begin
      DrawVertScale;
      Pen.Color := ColBtnShadow;
      Pen.Width := 1;
      case Scale of
      svStrikes, svStrikes3D:
        for I := 1 to FStrikeCount do
        begin
          Coord := Round(Margine + (I - 1) * (Height - Margine * 2) / (FStrikeCount - 1)) - BorderBevel div 2;
          if FScaleRaised or (FScale = svStrikes) then
            Pen.Color := ColBtnShadow
          else
            Pen.Color := ColBtnHighLight;

          if (I = 1) or (I = FStrikeCount) then
          begin
            WSS := FScaleWidth;
            if FLayout = loVertRight then
              SC := ScaleCoord - Round(1 / 3 * FScaleWidth)
            else
              SC := ScaleCoord + Round(1 / 3 * FScaleWidth);
          end
          else
          begin
            SC := ScaleCoord;
            WSS := Round(2 / 3 * FScaleWidth);
          end;

          MoveTo(SC - WSS, Coord);
          LineTo(SC + WSS, Coord);
          if FScale = svStrikes3D then
          begin
            if FScaleRaised then
              Pen.Color := ColBtnHighLight
            else
              Pen.Color := ColBtnShadow;
            MoveTo(SC - WSS, Coord + 1);
            LineTo(SC + WSS, Coord + 1);
          end;
          if FLayout = loVertCenter then
          begin
          if FScaleRaised or (FScale = svStrikes) then
            Pen.Color := ColBtnShadow
          else
            Pen.Color := ColBtnHighLight;
            MoveTo(Width - SC - WSS, Coord);
            LineTo(Width - SC + WSS, Coord);
            if FScale = svStrikes3D then
            begin
              if FScaleRaised then
                Pen.Color := ColBtnHighLight
              else
                Pen.Color := ColBtnShadow;
              MoveTo(Width - SC - WSS, Coord + 1);
              LineTo(Width - SC + WSS, Coord + 1);
            end;
          end;

        end;
      svTriangle:
          case Layout of
            loVertLeft: VLeft;
            loVertRight: VRight;
            loVertCenter:
            begin
              VLeft;
              ScaleCoord := Width - ScaleCenter;
              VRight;
            end;
          end;
      end;
    end;
  end;

  procedure DrawFrame3D;
  begin
    with Canvas do
    begin
      if FBevelInner = sbLowered then
        Frame3D(Canvas, BorderRect, ColBtnShadow, ColBtnHighLight, 1);
      if FBevelInner = sbRaised then
        Frame3D(Canvas, BorderRect, ColBtnHighLight, ColBtnShadow, 1);
      if FBevelOuter = sbLowered then
        Frame3D(Canvas, BorderRect, ColBtnShadow, ColBtnHighLight, 1);
      if FBevelOuter = sbRaised then
        Frame3D(Canvas, BorderRect, ColBtnHighLight, ColBtnShadow, 1);
      RectGrow(BorderRect, - 1);
    end;
  end;

begin
  with Canvas do
  begin
    BorderRect := RectSet(0, 0, Width, Height);
    Brush.Color:= Color;
    FillRect(BorderRect);
    case FLayout of
      loVertLeft:
      begin
        ScaleCoord := ScaleCenter;
        OrientationCoord := Width - Border;
      end;
      loVertRight:
      begin
        ScaleCoord := Width - ScaleCenter;
        OrientationCoord := Border;
      end;
      loVertCenter:
      begin
        ScaleCoord := ScaleCenter;
        OrientationCoord := Width div 2;
      end;
      loHorzTop:
      begin
        ScaleCoord := Height - ScaleCenter;
        OrientationCoord := Border;
      end;
      loHorzBottom:
      begin
        ScaleCoord := ScaleCenter;
        OrientationCoord := Height - Border;
      end;
      loHorzCenter:
      begin
        ScaleCoord := ScaleCenter;
        OrientationCoord := Height div 2;
      end;
    end;

    case Orientation of
      oVert:
        VertDraw;
      oHorz:
        HorzDraw;
    end;

    if Orientation = oVert then
    begin
      BMPSpace.Width := CursorHalfLong * 2;
      BMPSpace.Height := CursorHalfShoat * 2;
      BMPSpace.Canvas.CopyRect(RectSet(0, 0, BMPSpace.Width, BMPSpace.Height), Canvas,
               RectSet(OrientationCoord - CursorHalfLong, Margine + FRailBevelWidth,
                       OrientationCoord + CursorHalfLong,
                       Margine + FRailBevelWidth + CursorHalfShoat * 2));
    end
    else
    begin
      BMPSpace.Width := CursorHalfShoat * 2;
      BMPSpace.Height := CursorHalfLong * 2;
      BMPSpace.Canvas.CopyRect(RectSet(0, 0, BMPSpace.Width, BMPSpace.Height), Canvas,
               RectSet(Margine + FRailBevelWidth, OrientationCoord - CursorHalfLong,
                       Margine + FRailBevelWidth + CursorHalfShoat * 2,
                       OrientationCoord + CursorHalfLong));
    end;
    Space := False;
    DrawFrame3D;
    DrawCursor;
    if Focused then DrawFocus;
  end;
end;

procedure TxSlider.WNDProc(var Message: TMessage);
begin
{  if Message.Msg = WM_XHINTMESSAGE then
  begin
    TPopupMenu(Pointer(Message.LParam)^) := PopupMenu;
    Message.Result := 1;
  end
  else}
    inherited WNDProc(Message);
end;

procedure TxSlider.SetLayout(ALayout: TLayout);

  procedure ChandeWidtdAndHeight;
  var
    ChandeWH: Integer;
  begin
    ChandeWH := Width;
    Width := Height;
    Height := ChandeWH;
  end;

begin
  FLayout := ALayout;
  if not TestBMP then FThumbBitmap.Free;
  case FLayout of
    loVertLeft:
    begin
      if not TestBMP then LoadBMP('XREG_VLEFT');
      if (Orientation = oHorz) and (csDesigning in ComponentState) and
         not(csLoading in ComponentState) then
           ChandeWidtdAndHeight;
      Orientation := oVert;
    end;
    loVertRight:
    begin
      if not TestBMP then LoadBMP('XREG_VRIGHT');
      if (Orientation = oHorz) and (csDesigning in ComponentState) and
         not(csLoading in ComponentState) then
           ChandeWidtdAndHeight;
      Orientation := oVert;
    end;
    loVertCenter:
    begin
      if not TestBMP then LoadBMP('XREG_VCENTER');
      if (Orientation = oHorz) and (csDesigning in ComponentState) and
         not(csLoading in ComponentState) then
           ChandeWidtdAndHeight;
      Orientation := oVert;
    end;
    loHorzTop:
    begin
      if not TestBMP then LoadBMP('XREG_HTOP');
      if (Orientation = oVert) and (csDesigning in ComponentState) and
         not(csLoading in ComponentState) then
           ChandeWidtdAndHeight;
      Orientation := oHorz;
    end;
    loHorzBottom:
    begin
      if not TestBMP then LoadBMP('XREG_HBOTTOM');
      if (Orientation = oVert) and (csDesigning in ComponentState) and
         not(csLoading in ComponentState) then
        ChandeWidtdAndHeight;
      Orientation := oHorz;
    end;
    loHorzCenter:
    begin
      if not TestBMP then LoadBMP('XREG_HCENTER');
      if (Orientation = oVert) and (csDesigning in ComponentState) and
         not(csLoading in ComponentState) then
        ChandeWidtdAndHeight;
      Orientation := oHorz;
    end;
  end;
  SizeCursor;
  Convert;
  Repaint;
end;

procedure TxSlider.SetMin(AMin: Double);
begin
  if AMin <> FMin then
  begin
    if (csDesigning in ComponentState) and
       (csLoading in ComponentState) and (AMin > FMax) then
      raise ESliderError.Create('Minium can not be more tnan Maximum');
    if AMin > FValue then
      Value := AMin;
    FMin := AMin;
    Range := FMax - FMin;
    OldValue := FValue;
    Repaint;
  end;
end;

procedure TxSlider.SetMax(AMax: Double);
begin
  if AMax <> FMax then
  begin
    if (csDesigning in ComponentState) and
       (csLoading in ComponentState) and (AMax < FMin) then
      raise ESliderError.Create('Minium can not be more tnan Maximum');
    if AMax < FValue then
      Value := AMax;
    FMax := AMax;
    Range := FMax - FMin;
    OldValue := FValue;
    Repaint;
  end;
end;

procedure TxSlider.SetValue(AValue: Double);
begin
  if AValue <> FValue then
  begin
    if (csDesigning in ComponentState) and
       (csLoading in ComponentState) and ((AValue > FMax) or (AValue < FMin)) then
      raise ESliderError.Create('Value out of range');
    OldValue := FValue;
    FValue := AValue;
    DrawCursor;
  end;
end;

procedure TxSlider.SetScale(AScale: TScaleView);
begin
  if AScale <> FScale then
  begin
    FScale := AScale;
    Repaint;
  end;
end;

procedure TxSlider.SetStrikeCount(AStrikeCount: Word);
begin
  if AStrikeCount <> FStrikeCount then
  begin
    FStrikeCount := AStrikeCount;
    Repaint;
  end;
end;
              
procedure TxSlider.SetRailBevelWidth(ARailBevelWidth: Integer);
begin
  if ARailBevelWidth <> FRailBevelWidth then
  begin
    FRailBevelWidth := ARailBevelWidth;
    if ARailBevelWidth < 0 then
      FRailBevelWidth := 0;
    if ARailBevelWidth > 10 then
      FRailBevelWidth := 10;
    Repaint;
  end;
end;

procedure TxSlider.SetRailWidth(ARailWidth: Integer);
begin
  if ARailWidth <> FRailWidth then
  begin
    FRailWidth := ARailWidth;
    if ARailWidth < 0 then
      FRailWidth := 0;
    if ARailWidth > 10 then
      FRailWidth := 10;
    Repaint;
  end;
end;

procedure TxSlider.SetIntValue(AnIntValue: LongInt);
begin
  if IntValue <> AnIntValue then
    Value := AnIntValue;
end;

procedure TxSlider.SetRailRaised(ARailRaised: Boolean);
begin
  if ARailRaised <> FRailRaised then
  begin
    FRailRaised := ARailRaised;
    Repaint;
  end;
end;

procedure TxSlider.SetScaleRaised(AScaleRaised: Boolean);
begin
  if AScaleRaised <> FScaleRaised then
  begin
    FScaleRaised := AScaleRaised;
    Repaint;
  end;
end;

procedure TxSlider.SetScaleGap(AScaleGap: Integer);
begin
  if AScaleGap <> FScaleGap then
  begin
    FScaleGap := AScaleGap;
    ScaleCenter := FScaleGap + FScaleWidth;
    Repaint;
  end;
end;

procedure TxSlider.SetScaleWidth(AScaleWidth: Integer);
begin
  if AScaleWidth <> FScaleWidth then
  begin
    FScaleWidth := AScaleWidth;
    ScaleCenter := FScaleGap + FScaleWidth;
    Repaint;
  end;
end;

procedure TxSlider.SeTScaleBevelInner(ABevelInner: TScaleBevel);
begin
  if ABevelInner <> FBevelInner then
  begin
    FBevelInner := ABevelInner;
    Repaint;
  end;
end;

procedure TxSlider.SetScaleBevelOuter(ABevelOuter: TScaleBevel);
begin
  if ABevelOuter <> FBevelOuter then
  begin
    FBevelOuter := ABevelOuter;
    Repaint;
  end;
end;

procedure TxSlider.SetThumbBitmap(AThumbBitmap: TBitmap);
begin
  FThumbBitmap.Assign(AThumbBitmap);
  if FThumbBitmap.Empty then
  begin
    TestBMP := False;
    SetLayout(FLayout);
  end
  else
  begin
    TestBMP := True;
    OldBitmap.Assign(AThumbBitmap);
  end;
  SizeCursor;
  Convert;
  Repaint;
end;

procedure TxSlider.SetConvertColors(AConvertColors: Boolean);
begin
  FConvertColors := AConvertColors;
  Convert;
  Repaint;
end;

procedure TxSlider.SetColor(AColor: TColor);

const
  Delta = 96;

  function AdjustColor(C: Integer): Byte;
  begin
    if C < 0 then
      Result := 0
    else
      if C > 255 then
        Result := 255
      else
        Result := C;
  end;

  function MyRGB(R, G, B: Integer): LongInt;
  begin
    Result := RGB(AdjustColor(R), AdjustColor(G), AdjustColor(B));
  end;

begin
  if AColor <> FColor then
  begin
    if (FColor = clBtnFace) and (((FThumbBitmap.Width <> 22) and (FThumbBitmap.Height <> 24)) or
       ((FThumbBitmap.Width <> 24) and (FThumbBitmap.Height <> 22))) then
    begin
      TestBMP := True;
      OldBitmap.Assign(FThumbBitmap);
    end;
    FColor := AColor;
    ColBtnFace := FColor;
    ColBtnShadow := MyRGB(GetRValue(FColor) - Delta, GetGValue(FColor) - Delta, GetBValue(FColor) - Delta);
    ColBtnHighLight := MyRGB(GetRValue(FColor) + Delta, GetGValue(FColor) + Delta, GetBValue(FColor) + Delta);
    if TestBMP then
    begin
      FThumbBitmap.Assign(OldBitmap);
      Convert;
      Repaint;
    end
    else
      SetLayout(FLayout);
  end;
end;

function TxSlider.GetIntValue: LongInt;
begin
  Result := Round(FValue);
end;

procedure TxSlider.DrawHorzScale;
var
  Coord: Integer;
  Rct: TRect;
begin
  with Canvas do
  begin
    if Odd(FRailWidth) then
      Coord := FRailWidth div 2 + 1
    else
      Coord := FRailWidth div 2;
    Rct := RectSet(BorderBevel, OrientationCoord + FRailWidth div 2, Width - BorderBevel, OrientationCoord - Coord);
    if FRailRaised then
      Frame3D(Canvas, Rct, ColBtnShadow, ColBtnHighLight, FRailBevelWidth)
    else
      Frame3D(Canvas, Rct, ColBtnHighLight, ColBtnShadow, FRailBevelWidth);
  end;
end;

procedure TxSlider.DrawVertScale;
var
  Coord: Integer;
  Rct: TRect;
begin
  with Canvas do
  begin
      if Odd(FRailWidth) then
        Coord := FRailWidth div 2 + 1
      else
        Coord := FRailWidth div 2;
      Rct := RectSet(OrientationCoord + FRailWidth div 2, BorderBevel, OrientationCoord - Coord, Height - BorderBevel);
      if FRailRaised then
        Frame3D(Canvas, Rct, ColBtnShadow, ColBtnHighLight, FRailBevelWidth)
      else
        Frame3D(Canvas, Rct, ColBtnHighLight, ColBtnShadow, FRailBevelWidth);
  end;
end;

procedure TxSlider.DrawCursor;
var
  Coord: Integer;

  procedure HorzDrawCursor;
  begin
    with Canvas do
    begin
      Coord := Round((OldValue - FMin) / Range * (Width - Margine * 2)) + BorderBevel;
      if OldValue <> FValue then
        if (Coord < Margine + FRailBevelWidth) or
           (Coord > Width - Margine - FRailBevelWidth - CursorHalfShoat) then

        begin
          Brush.Color := ColBtnFace;
          FillRect(RectSet(Coord, OrientationCoord - CursorHalfLong, Coord + CursorHalfShoat * 2,
                                  OrientationCoord + CursorHalfLong));
          DrawHorzScale;
        end
        else
        CopyRect(RectSet(Coord, OrientationCoord - CursorHalfLong, Coord + CursorHalfShoat * 2,
                                OrientationCoord + CursorHalfLong),
                 BMPSpace.Canvas,
                 RectSet(0, 0, BMPSpace.Width, BMPSpace.Height));


      Coord := Round((FValue - FMin) / Range * (Width - Margine * 2)) + BorderBevel;
      if Press then
        CopyRect(RectSet(Coord, OrientationCoord - CursorHalfLong, Coord + CursorHalfShoat * 2,
                                OrientationCoord + CursorHalfLong),
                 FThumbBitmap.Canvas,
                 RectSet(CursorHalfShoat * 2, 0, CursorHalfShoat * 4, FThumbBitmap.Height))
      else
        CopyRect(RectSet(Coord, OrientationCoord - CursorHalfLong, Coord + CursorHalfShoat * 2,
                         OrientationCoord + CursorHalfLong),
                 FThumbBitmap.Canvas,
                 RectSet(0, 0, CursorHalfShoat * 2 , FThumbBitmap.Height))
    end;
  end;

  procedure VertDrawCursor;
  begin
    with Canvas do
    begin
      Coord := Round(Height - Margine * 2 - (OldValue - FMin) / Range * (Height - Margine * 2) + BorderBevel);
      if OldValue <> FValue then
        if (Coord < Margine + FRailBevelWidth + FRailWidth) or
           (Coord > Height - Margine - FRailBevelWidth - FRailWidth - CursorHalfShoat)
        then
        begin
          Brush.Color := ColBtnFace;
          FillRect(RectSet(OrientationCoord - CursorHalfLong, Coord,
                             OrientationCoord + CursorHalfLong,
                             Coord + CursorHalfShoat * 2));
          DrawVertScale;
        end
        else
        CopyRect(RectSet(OrientationCoord - CursorHalfLong, Coord,
                         OrientationCoord + CursorHalfLong,
                         Coord + CursorHalfShoat * 2),
                 BMPSpace.Canvas,
                 RectSet(0, 0, BMPSpace.Width, BMPSpace.Height));

      Coord := Round(Height - Margine * 2 - (FValue - FMin) / Range * (Height - Margine * 2) + BorderBevel);
      if Press then
        CopyRect(RectSet(OrientationCoord - CursorHalfLong, Coord,
                         OrientationCoord + CursorHalfLong,
                         Coord + CursorHalfShoat * 2),
                 FThumbBitmap.Canvas,
                 RectSet(CursorHalfLong * 2, 0, FThumbBitmap.Width, ThumbBitmap.Height))
      else
        CopyRect(RectSet(OrientationCoord - CursorHalfLong, Coord, OrientationCoord + CursorHalfLong,
                         Coord + CursorHalfShoat * 2),
                 FThumbBitmap.Canvas,
                 RectSet(0, 0, CursorHalfLong * 2, ThumbBitmap.Height));
    end;
  end;

begin
  if not Space then
  begin
    Canvas.Pen.Color := ColBtnFace;
    Canvas.Brush.Color := ColBtnFace;
    case Orientation of
      oVert:
        VertDrawCursor;
      oHorz:
        HorzDrawCursor;
    end;
  end;
end;

procedure TxSlider.DrawFocus;
begin
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Width := 1;
  if Focused then
    Canvas.Pen.Color := ColBtnShadow
  else
    Canvas.Pen.Color := ColBtnFace;
  Canvas.Rectangle(BorderRect.Left, BorderRect.Top, BorderRect.Right, BorderRect.Bottom)
end;

procedure TxSlider.SizeCursor;
begin
  if Orientation = oVert then
  begin
    CursorHalfLong := FThumbBitmap.Width div 4;
    CursorHalfShoat := FThumbBitmap.Height div 2;
  end
  else
  begin
    CursorHalfLong := FThumbBitmap.Height div 2;
    CursorHalfShoat := FThumbBitmap.Width div 4;
  end;
    Margine := CursorHalfShoat + BorderBevel;
    Border := CursorHalfLong + BorderBevel;
end;

procedure TxSlider.DoOnExit(Sender: TObject);
begin
  DrawFocus;
end;

procedure TxSlider.DoOnEnter(Sender: TObject);
begin
  DrawFocus;
end;

procedure TxSlider.Convert;
var
  X, Y: Integer;
begin
  if FConvertColors then
  begin
    with FThumbBitmap.Canvas do
      for X := -1 to FThumbBitmap.Width do
        for Y := -1 to FThumbBitmap.Height do
        begin
          if Pixels[X, Y] = clBlack then
            Pixels[X, Y] := clBtnText;
          if Pixels[X, Y] = clGray then
            Pixels[X, Y] := ColBtnShadow;
          if Pixels[X, Y] = clSilver then
            Pixels[X, Y] := ColBtnFace;
          if Pixels[X, Y] = clWhite then
            Pixels[X, Y] := ColBtnHighLight;
        end;
  end;
end;

procedure TxSlider.LoadBmp(Id: PChar);
begin
  FThumbBitmap := TBitmap.Create;
  FThumbBitmap.Handle := LoadBitmap(hInstance, Id);
  if FThumbBitmap.Handle = 0 then
    raise Exception.Create('Can''t load resource bitmap');
  TestBMP := False;
end;

procedure TxSlider.WMSize(var Message: TWMSize);
begin
  inherited;
  InvalidateRect(Handle, nil, True);
end;

procedure TxSlider.WMLButtonDown(var Message: TWMLButtonDown);
var
  Coord: Integer;
begin
  inherited;
  if not Focused then SetFocus;
  with Message do
    case Orientation of
      oHorz:
      begin
        Coord := Round((FValue - FMin) / Range * (Width - Margine * 2) + BorderBevel);
        if (XPos > Coord) and (XPos < Coord + CursorHalfShoat * 2) and (YPos > OrientationCoord - CursorHalfLong)
           and (YPos < OrientationCoord + CursorHalfLong) then
        begin
          Press := True;
          DrawCursor;
          if Assigned(FOnChange) then FOnChange(Self);
        end
        else
          if (XPos >= Margine) and (XPos <= Width - Margine) and (YPos > OrientationCoord - CursorHalfLong)
             and (YPos < OrientationCoord + CursorHalfLong) then
          begin
            OldValue := FValue;
            FValue := (XPos - Margine) / (Width - Margine * 2) * Range + FMin;
            DrawCursor;
            if Assigned(FOnChange) then FOnChange(Self);
          end;
      end;
      oVert:
      begin
        Coord := Round(Height - Margine * 2 - ((FValue - FMin) / Range * (Height - Margine * 2)) + BorderBevel);
        if (YPos > Coord) and (YPos < Coord + CursorHalfShoat * 2) and (XPos > OrientationCoord - CursorHalfLong)
           and (XPos < OrientationCoord + CursorHalfLong) then
        begin
          Press := True;
          DrawCursor;
          if Assigned(FOnChange) then FOnChange(Self);
        end
        else
          if (YPos >= Margine) and (YPos <= Height - Margine) and (XPos > OrientationCoord - CursorHalfLong)
             and (XPos < OrientationCoord + CursorHalfLong) then
          begin
            OldValue := FValue;
            FValue := Range - (YPos - Margine) / (Height - Margine * 2) * Range + FMin;
            DrawCursor;
            if Assigned(FOnChange) then FOnChange(Self);
          end;
      end;
    end;
end;

procedure TxSlider.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  Press := False;
  DrawCursor;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TxSlider.WMMouseMove(var Message: TWMMouseMove);
var
  Coord: Integer;
begin
  inherited;
  if Press then
    with Message do
    begin
      case Orientation of
        oVert:
        begin
          Coord := YPos;
          if Coord < Margine then Coord := Margine;
          if Coord > Height - Margine then Coord := Height - Margine;
          OldValue := FValue;
          FValue := Range - (Coord - Margine) / (Height - Margine * 2) * Range + FMin;
          DrawCursor;
          if Assigned(FOnChange) then FOnChange(Self);
        end;
        oHorz:
        begin
          Coord := XPos;
          if Coord < Margine then Coord := Margine;
          if Coord > Width - Margine then Coord := Width - Margine;
          OldValue := FValue;
          FValue := (Coord - Margine) / (Width - Margine * 2) * Range + FMin;
          DrawCursor;
          if Assigned(FOnChange) then FOnChange(Self);
        end;
      end;
    end;
end;

procedure TxSlider.WMKeyDown(var Message: TWMKeyDown);
var
  V: Double;
begin
  inherited;
  if Focused then
    with Message do
    begin
      OldValue := FValue;

      if Orientation = oVert then
        V := 1 / (Height - Margine * 2) * Range
      else
        V := 1 / (Width - Margine * 2) * Range;

      if (CharCode = VK_RIGHT) or (CharCode = VK_UP) then
      begin
        FValue := FValue + V;
        if FValue > FMax then
          FValue := FMax;
      end
      else if (CharCode = VK_LEFT) or (CharCode = VK_DOWN) then
      begin
        FValue := FValue - V;
        if FValue < FMin then
          FValue := FMin;
      end
      else if CharCode = VK_HOME then
      begin
        if Orientation = oVert then
          FValue := FMax
        else
          FValue := FMin;
      end
      else if CharCode = VK_END then
      begin
        if Orientation = oVert then
          FValue := FMin
        else
          FValue := FMax;
      end;

      DrawCursor;
      if Assigned(FOnChange) then FOnChange(Self);
    end;
end;

procedure TxSlider.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := DLGC_WANTARROWS;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsVC', [TxSlider]);
end;

{Initialization ------------------------------------------}

initialization

{  WM_XHINTMESSAGE := RegisterWindowMessage('WM_XHINTMESSAGE');}

end.
