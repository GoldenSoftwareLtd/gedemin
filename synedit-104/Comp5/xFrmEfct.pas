
{++

  Copyright (c) 1997 by Golden Software of Belarus

  Module

    xdatedlg.pas

  Abstract

    Exploding effect for form creation.

  Author

    Anton Smirnov (1-sep-97)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00     4-sep-97    sai      Initial version.
    1.01     8-sep-97    sai      Small Changes.
    1.02    11-oct-97    andreik  Changes.
    1.03    14-oct-97    sai      Changes.
    1.04    09-feb-98    andreik  Bug fixed.
    1.05    5-apr-98     sai      For Delphi 32
--}

unit xFrmEfct;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TxFormEffect = class(TComponent)
  private
    FSnapShot: TBitmap;
    OldOnCreate: TNotifyEvent;

    function GetSnapShot: TBitmap;
    procedure SetSnapShot(const Value: TBitmap);

    procedure DoOnCreate(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property SnapShot: TBitmap read GetSnapShot write SetSnapShot;
  end;

  ExFormEffectError = class(Exception);

procedure Register;

implementation

const
  CountLine = 10;
  StepCount = 20;
  MaxSize = 20;

procedure DoDelay(Pause: LongWord);
var
  OldTime: LongWord;
begin
  OldTime := GetTickCount;
  while GetTickCount - OldTime <= Pause do { nothing };
end;

{TxFormEffect --------------------------------------------}

constructor TxFormEffect.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  if not (Owner is TForm) then
    raise ExFormEffectError.Create('The Owner must be TForm');

  FSnapShot := TBitmap.Create;

  if not (csDesigning in ComponentState) then
  begin
    OldOnCreate := (Owner as TForm).OnCreate;
    (Owner as TForm).OnCreate := DoOnCreate;
  end;
end;

destructor TxFormEffect.Destroy;
begin
  FSnapShot.Free;

  if (not (csDesigning in ComponentState)) and (Owner <> nil) then
    (Owner as TForm).OnCreate := OldOnCreate;

  inherited Destroy;
end;

procedure TxFormEffect.DoOnCreate(Sender: TObject);

var
  W, H, LL, TT, WW, HH, KW, KH: LongInt;
  P: TPoint;
  C: TCanvas;
  Cl: TColor;
  TypeCard: Integer;

  procedure DrawEffect(Delta: TColor);
  var
    I: Integer;

  procedure DrawLine(X1, Y1, X2, Y2: Integer);
  var
    X, Y, K: Integer;
    TestCoord: Boolean;
    ScreenX, ScreenY: Integer;
    DC: HDC;

    function ChangeDelta(cl: TColor; CD: TColor): TColor;
    var
      Res: TColor;
    begin
      Res := cl + cd;
      if Res > $FFFFFF then
        Res := Res - $FFFFFF - (COLOR_ENDCOLORS + 1);
      if Res < - (COLOR_ENDCOLORS + 1) then
        Res := Res + $FFFFFF + (COLOR_ENDCOLORS + 1);
      Result := Res;
    end;

  begin
    // узнаем размерность экрана
    DC := GetDC(0);
    try
      ScreenX := GetDeviceCaps(DC, HORZRES);
      ScreenY := GetDeviceCaps(DC, VERTRES);
    finally
      ReleaseDC(0, DC);
    end;

    K := 3;
    TestCoord := True;
    if X1 = X2 then
      TestCoord := False;
    with C do
      if not TestCoord then
      begin
        for Y := 0 to (Abs(Y2 - Y1) div K) do
        begin
          // попытка исправить ошибку с выходом за границы экрана
          try
            if (X1 >= 0) and (X1 < ScreenX) and (Y * K + Y1 >= 0)
              and (Y * K + Y1 < ScreenY) then
              begin
                Cl := Pixels[X1, Y * K + Y1] xor $FFFFFF;
                Pixels[X1, Y * K + Y1] := Cl;
              end;
          except
            on Exception do ;
          end;
        end;
      end
      else
        for X := 0 to Abs(X2 - X1) div K do
        begin
          Cl := ColorToRGB(Pixels[X * K + X1, Y1]) xor $FFFFFF;
          Pixels[X * K + X1, Y1] := Cl;
        end;
  end;

  procedure PointRectangle(XL, YL, XR, YR: Integer);
  begin
    DrawLine(XL, YL, XL, YR);
    DrawLine(XR, YL, XR, YR);
    DrawLine(XL, YL, XR, YL);
    DrawLine(XL, YR, XR, YR);
  end;

  begin
    if W > H then
    begin
      for I := 0 to W do
      begin
        PointRectangle(P.X + KW * I * StepCount,
                      P.Y + Trunc(KH * I * StepCount * H / W),
                      P.X + KW * I * StepCount + MaxSize - Trunc(MaxSize / W * I),
                      P.Y + Trunc(KH * I * StepCount * H / W) + MaxSize -
                      Trunc(MaxSize / W * I));
      end;
    end
    else
    begin
      for I := 0 to H do
      begin
        PointRectangle(P.X + Trunc(KW * I * StepCount * W / H),
                      P.Y + KH * I * StepCount,
                      P.X + Trunc(KW * I * StepCount * W / H) + MaxSize -
                      Trunc(MaxSize / H * I),
                      P.Y + KH * I * StepCount + MaxSize - Trunc(MaxSize / H * I));
      end;
    end;
    for I := 0 to HH div StepCount do
    begin
      PointRectangle(LL + WW div 2 - Trunc(I * StepCount * (WW / 2) / HH),
                     TT + HH - I * StepCount,
                     LL + WW div 2 + Trunc(I * StepCount * (WW / 2) / HH),
                     TT + HH);

    end;
  end;

var
  DC: HDC;

begin
  if Assigned(OldOnCreate) then
    OldOnCreate(Sender);

  DC := GetDC(0);
  try
    TypeCard := GetDeviceCaps(DC, BITSPIXEL);
  finally
    ReleaseDC(0, DC);
  end;

  if TypeCard <> 8 then
  begin
    LL := (Owner as TForm).Left;
    TT := (Owner as TForm).Top;
    WW := (Owner as TForm).Width;
    HH := (Owner as TForm).Height - 2;

    GetCursorPos(P);

    C := TCanvas.Create;
    try
      C.Handle := GetDC(0);
      try
        W := Abs((- P.X + LL + WW div 2) div StepCount);
        H := Abs((- P.Y + TT + HH - StepCount) div StepCount);

        if P.X < (LL + WW div 2) then
          KW := 1
        else
          KW := -1;

        if P.Y < (TT + HH)  then
          KH := 1
        else
          KH := -1;

        DrawEffect(clRed);
        DoDelay(20);
        DrawEffect(clRed);
      finally
        ReleaseDC(0, C.Handle);
        C.Handle := 0;
      end;
    finally
      C.Free;
    end;
  end;
end;



function TxFormEffect.GetSnapShot: TBitmap;
begin
  Result := FSnapShot;
end;

procedure TxFormEffect.SetSnapShot(const Value: TBitmap);
begin
  FSnapShot.Assign(Value);
end;

{procedure TxFormEffect.DoOnCreate(Sender: TObject);
var
  Canv: TCanvas;
  DR, SR, SaveR: TRect;
  SaveBits: TBitmap;
begin
  if Assigned(OldOnCreate) then
    OldOnCreate(Sender);

  if FSnapShot.Empty then
    exit;

  DR.Left := (Owner as TForm).Left;
  DR.Right := (Owner as TForm).Left + (Owner as TForm).Width;
  DR.Top := (Owner as TForm).Top;
  DR.Bottom := (Owner as TForm).Top + 10;

  SR.Left := 0;
  SR.Right := FSnapShot.Width;
  SR.Top := FSnapShot.Height - 10;
  SR.Bottom := FSnapShot.Height;

  SaveR := DR;
  SaveR.Bottom := (Owner as TForm).Top + (Owner as TForm).Height;

  SaveBits := TBitmap.Create;
  SaveBits.Assign(FSnapShot);

  Canv := TCanvas.Create;
  Canv.Handle := GetDC(0);
  try
    SaveBits.Canvas.CopyRect(Rect(0, 0, SaveR.Right - SaveR.Left, SaveR.Bottom - SaveR.Top),
      Canv, SaveR);

    while SR.Top > 10 do
    begin
      Canv.CopyRect(DR, FSnapShot.Canvas, SR);
      DoDelay(5);
      SR.Top := SR.Top - 10;
      DR.Bottom := DR.Bottom + 10;
    end;

//    Canv.Draw(SaveR.Left, SaveR.Top, SaveBits);
  finally
    ReleaseDC(0, Canv.Handle);
    Canv.Free;
    SaveBits.Free;
  end;

//  InvalidateRect(0, @DR, False);
end;}

{TEffect ------------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-NonVisual', [TxFormEffect]);
end;

end.
