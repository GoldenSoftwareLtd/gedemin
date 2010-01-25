
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xprogr.pas

  Abstract

    Extended progress bar.

  Author

    Andrei Kireev (11-Sep-96)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    13-Sep-96    andreik    Initial version.
    1.01    28-Sep-96    andreik    Running man added.
    1.02    24-Dec-96    andreik    Parent changed to TPanel;
                                    Added some new effects.
    1.03     3-Feb-97    belyi      LongInt instead of Integer.
    1.04    15-Feb-97    andreik    Minor bug fixed.
    1.02    20-Oct-97    andreik    Delphi32 version.

--}

unit xProgr;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DB, ExtCtrls;

const
  DefaultHeight = 12;
  DefaultWidth = 160;
  DefaultCursor = crHourGlass;
  DefaultBevelOuter = bvNone;

  DefaultValue = 50;
  DefaultMin = 0;
  DefaultMax = 100;

  DefGap = 2;

type
  TxProgressBase = class(TPanel)
  private
    FValue, FMin, FMax: LongInt;

    procedure SetParam(Index: Integer; AParam: LongInt);

  protected
    procedure DrawProgress; virtual; abstract;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property Value: LongInt index 1 read FValue write SetParam
      default DefaultValue;
    property Min: LongInt index 2 read FMin write SetParam
      default DefaultMin;
    property Max: LongInt index 3 read FMax write SetParam
      default DefaultMax;

    property Width default DefaultWidth;
    property Height default DefaultHeight;
    property Cursor default DefaultCursor;
    property BevelOuter default DefaultBevelOuter;
  end;

type
  TxProgressBar = class(TxProgressBase)
  private
    FGap: Integer;

    procedure SetGap(AGap: Integer);

  protected
    procedure Paint; override;
    procedure DrawProgress; override;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property Gap: Integer read FGap write SetGap default DefGap;
  end;

type
  TxRunningMan = class(TxProgressBase)
  private
    Icons: array[1..4] of TIcon;
    Timer: TTimer;
    CurrentIcon: Integer;
    Image: TImage;

    procedure DoTimer(Sender: TObject);

  protected
    procedure Paint; override;
    procedure DrawProgress; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Width nodefault;
    property Height default 32 + 2;
  end;

procedure Register;

implementation

{$R XPROGR.RES}

{ xProgressBase ------------------------------------------}

constructor TxProgressBase.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Width := DefaultWidth;
  Height := DefaultHeight;
  Cursor := DefaultCursor;
  BevelOuter := DefaultBevelOuter;

  Caption := '';

  FMin := DefaultMin;
  FMax := DefaultMax;
  FValue := DefaultValue;
end;

procedure TxProgressBase.SetParam(Index: Integer; AParam: LongInt);
begin
  case Index of
    1: FValue := AParam;
    2: FMin := AParam;
    3: FMax := AParam;
  end;
  DrawProgress;
  if Index = 1 then
    Application.ProcessMessages; {!!!}
end;

{ xProgressBar -------------------------------------------}

constructor TxProgressBar.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FGap := DefGap;
end;

procedure TxProgressBar.Paint;
begin
  inherited Paint;
  DrawProgress;
end;

procedure TxProgressBar.DrawProgress;
var
  R, R1: TRect;
  W, H, I, C, TotalC: LongInt;
  Rgn: HRgn;
begin
  if (FMax <= FMin) or (FValue < FMin) or (FValue > FMax) then
    exit;

  R := GetClientRect;

  Inc(R.Left, Gap + 1);
  Inc(R.Top, Gap + 1);
  Dec(R.Right, Gap + 1);
  Dec(R.Bottom, Gap + 1);

  Rgn := CreateRectRgnIndirect(R);
  try
    SelectClipRgn(Canvas.Handle, Rgn);
    try
      H := R.Bottom - R.Top;
      TotalC := ((R.Right - R.Left) div (H + Gap));
      W := Trunc((R.Right - R.Left - TotalC * Gap + Gap) / TotalC);
      C := Round(TotalC  * ( (FValue - FMin) / (FMax - FMin) ));

      for I := 0 to TotalC - 1 do
      begin
        R1 := Rect(
          R.Left + I * W + I * Gap,
          R.Top,
          R.Left + (I + 1) * W + I * Gap,
          R.Bottom);

        if I < C then
        begin
          Canvas.Brush.Color := clHighLight;
          if Ctl3D then
            Frame3D(Canvas, R1, clBtnHighlight, clBtnShadow, 1)
          else
            Frame3D(Canvas, R1, clBlack, clBlack, 1);

          Canvas.FillRect(R1);
        end else
        begin
          Canvas.Brush.Color := Color;
          if Ctl3D then
            Frame3D(Canvas, R1, clBtnShadow, clBtnHighlight, 1)
          else
            Frame3D(Canvas, R1, clBlack, clBlack, 1);
          Canvas.FillRect(R1);
        end;

        Canvas.Brush.Color := Color;
        R1 := Rect(
          R.Left + (I + 1) * W + I * Gap,
          R.Top,
          R.Left + (I + 1) * W + (I + 1) * Gap,
          R.Bottom);
        Canvas.FillRect(R1);
      end;

      Canvas.Brush.Color := Color;
      R1 := Rect(
        R.Left + TotalC * W + (TotalC - 1) * Gap,
        R.Top,
        R.Right,
        R.Bottom);
        Canvas.FillRect(R1);

    finally
      SelectClipRgn(Canvas.Handle, 0);
    end;
  finally
    DeleteObject(Rgn);
  end;
end;

procedure TxProgressBar.SetGap(AGap: Integer);
begin
  Assert((AGap >= 0) and (AGap < 200));

  if FGap <> AGap then
  begin
    FGap := AGap;
    Invalidate;  
  end;
end;

{ TxRunningMan -------------------------------------------}

constructor TxRunningMan.Create(AnOwner: TComponent);
var
  I: Integer;
  S: array[0..15] of Char;
begin
  inherited Create(AnOwner);

  for I := 1 to 4 do
  begin
    Icons[I] := TIcon.Create;
    Icons[I].Handle := LoadIcon(hInstance, StrFmt(S, 'XPROGR_%d', [I]));
    if Icons[I].Handle = 0 then
      raise Exception.Create('Resource missing');
  end;

  Image := TImage.Create(Self);
  Image.Parent := Self;
  Image.AutoSize := True;
  Image.Picture.Icon := Icons[1];
  Image.Left := 0;
  Image.Top := 0;
  Image.Visible := True;

  Width := 200;
  Height := 32 + 2;

  CurrentIcon := 1;

  Timer := TTimer.Create(Self);
  Timer.OnTimer := DoTimer;
  Timer.Interval := 100;
  Timer.Enabled := not (csDesigning in ComponentState);
end;

destructor TxRunningMan.Destroy;
var
  I: Integer;
begin
  Timer.Free;
  Image.Free;

  for I := 1 to 4 do
    if Assigned(Icons[I]) then Icons[I].Free;

  inherited Destroy;
end;

procedure TxRunningMan.Paint;
var
  R: TRect;
begin
  inherited Paint;

  R := GetClientRect;
  R := Rect(R.Left, R.Bottom - 2, R.Right, R.Bottom);
  Frame3D(Canvas, R, clBtnShadow, clBtnHighlight, 1);

  DrawProgress;
end;

procedure TxRunningMan.DrawProgress;
begin
  if Max = Min then
    Image.Left := 0
  else
    Image.Left := Trunc((Width - Image.Width) *
      ((Value - Min) / (Max - Min)));
end;

procedure TxRunningMan.DoTimer(Sender: TObject);
begin
  Inc(CurrentIcon);
  if CurrentIcon > 4 then CurrentIcon := 1;
  Image.Picture.Icon := Icons[CurrentIcon];
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsVC', [TxProgressBar]);
  RegisterComponents('gsVC', [TxRunningMan]);
end;

end.

