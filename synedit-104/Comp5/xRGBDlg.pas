
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xrgbdlg.pas

  Abstract

    An enhanced RGB color dialog.

  Author

    Anton Smirnov (Jan 96)

  Contact address


  Revisions history

    1.00    19-Feb-96    anton      Initial version.
    1.01    09-Dec-96    andreik    Minor changes.
    1.02    13-Dec-96    andreik    Minor change.
    1.03    20-Oct-97    andreik    Ported to Delphi32.
    1.04    22-Aug-98    andreik    Minor bug fixed.

--}

unit xRGBDlg;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Buttons, StdCtrls, Dialogs, xSpin, xSlider, xClrEdit, IniFiles;

type
  TCubeAx = (caRed, caBlue, caGreen, caNone);

type
  TRGBCube = class(TCustomControl)
  private
    FColor: TColor;
    OffScreen: TBitmap;
    X, Y: Integer;
    CubeAx: TCubeAx;
    R, G, B: LongInt;
    FOnChange: TNotifyEvent;
    Side: Double;

    procedure SetColor(AColor: TColor);

    procedure Draw3DAxes;

    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LButtonUp;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Repaint; override;

  published
    property Color: TColor read FColor write SetColor;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

type
  TDoubleColor = class(TCustomControl)
  private
    FColor: TColor;

    procedure SetColor(AColor: TColor);

  protected
    procedure Paint; override;

  public
    procedure Repaint; override;

  published
    property Color: TColor read FColor write SetColor;
  end;

  THueBar = class(TCustomControl)
  private
    FColor: TColor;

    Y: Integer;
    Press: Boolean;
    R, G, B, MaxR, MaxG, MaxB: LongInt;
    FOnChange: TNotifyEvent;

    procedure SetColor(AColor: TColor);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LButtonUp;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;

  protected
    procedure Paint; override;

  public
    procedure Repaint; override;
    procedure SetupColor(X: Integer);
    function GetMaxColor: LongInt;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Color: TColor read FColor write SetColor;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

type
  TRGBEdit = class(TCustomControl)
  private
    FColor: TColor;
    FOnChange: TNotifyEvent;

    REdit, GEdit, BEdit: TxSpinEdit;
    RLabel, GLabel, BLabel: TLabel;
    Test: Boolean;
    FFont: TFont;

    procedure SetColor(AColor: TColor);
    procedure MyChange(Sender: TObject);
    procedure SetFont(AFont: TFont);

  protected
    procedure CreateWnd; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Color: TColor read FColor write SetColor;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Font: TFont read FFont write SetFont;
  end;

type
  TExGridColor = class(TCustomControl)
  private
    FOnChange: TNotifyEvent;
    FColor: TColor;
    FFont: TFont;

    IniFile: TIniFile;
    UserColor: array [0..19] of TColor;
    AddColor: TButton;
    Number: Integer;

    procedure DrawFocus;
    procedure DrawUserColor(I: Integer);
    procedure SetColor(AColor: TColor);
    procedure SetFont(AFont: TFont);

    procedure DoButtonClick(Sender: TObject);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;

  protected

    procedure Paint; override;
    procedure CreateWnd; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Repaint; override;

  published
    property Color: TColor read FColor write SetColor;
    property Font: TFont read FFont write SetFont;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

type
  TGridColor = class(TCustomControl)
  private
    FOnChange: TNotifyEvent;
    FColor: TColor;
    ColorRct: TRect;
    NumerColor: Integer;
    SqrColor: array [0..19] of TPaletteEntry;
    procedure SetColor(AColor: TColor);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;

    procedure DrawFocus;
  protected
    procedure Paint; override;
    procedure CreateWnd; override;

  public
    constructor Create(AOwner: TComponent); override;

  published
    property Color: TColor read FColor write SetColor;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;


type
  TxRGBBox = class(TForm)
  private
    RGBCube: TRGBCube;
    DoubleColor: TDoubleColor;
    HueBar: THueBar;
    RGBEdit: TRGBEdit;
    GridColor: TGridColor;
    xColorEdit: TxColorEdit;
{    BitBtnOk: TBitBtn;
    BitBtnCancel: TBitBtn; }
    BitBtnOk, BitBtnCancel: TButton;
    xSlider1: TxSlider;
    ExGridColor: TExGridColor;
    Label1, Label2, Label3, Label4, Label5: TLabel;

    procedure RGBEditChange(Sender: TObject);
    procedure GridColorChange(Sender: TObject);
    procedure ExGridColorChange(Sender: TObject);
    procedure HueBarChange(Sender: TObject);
    procedure RGBCubeChange(Sender: TObject);
    procedure xColorEditChange(Sender: TObject);
    procedure xSliderChange(Sender: TObject);
  public
    BoxColor: TColor;
    constructor CreateNew(AnOwner: TComponent; AColor: TColor; AFont: TFont;
                          ACaption: String); reintroduce;
  end;

  TxRGBDialog = class(TComponent)
  private
    FColor: TColor;
    FFont: TFont;
    FCaption: String;

    procedure SetColor(AColor: TColor);
    procedure SetFont(AFont: TFont);
    procedure SetCaption(ACaption: String);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function Execute: Boolean;

  published
    property Color: TColor read FColor write SetColor;
    property Font: TFont read FFont write SetFont;
    property Caption: String read FCaption write SetCaption;
  end;

procedure Register;

implementation

uses
  ExtCtrls, Rect;

{$R XRGBDLG.RES}

const
  StepsCount = 32;
  XCos = 0.888;
  YSin = 0.444;   
  Step = 2.25;
  XC = XCos * Step;
  YS = YSin * Step;
  CountStep = 32;
  S = CountStep * Step;
  D = 10;
  SqrSide = 4;

  MaxCol = 255;

  SqrSize = 16;
  SqrX = 2;
  SqrY = 2;

  ColorsSection = 'RGB_Dialog_Colors';

  Def_FontName = 'Arial';
  Def_FontSize = 9;

(*
function LoadDIBitmap(ResId: PChar): TBitmap;
var
  Mem: TMemoryStream;
  Ptr: Pointer;
  ResHandle, H: THANDLE;
  Bmf: TBitmapFileHeader;
function LoadDIBitmap(ResId: String): TBitmap;
begin
  Result := nil;

  ResHandle := FindResource(hInstance, ResId, RT_BITMAP);
  H := LoadResource(hInstance, ResHandle);
  try
    Ptr := LockResource(H);

    if (ResHandle = 0) or (H = 0) or (Ptr = nil) then
      raise Exception.Create('Can''t load resource bitmap');

    Mem := TMemoryStream.Create;
    try
      Mem.SetSize(SizeOf(Bmf) + GlobalSize(H));
      Bmf.bfType := $4D42; { the only field that will be checked }
      Mem.Write(Bmf, SizeOf(Bmf));
      Mem.Write(Ptr^, GlobalSize(H));
      Mem.Position := 0; { return back }

      Result := TBitmap.Create;
      Result.LoadFromStream(Mem);
    finally
      Mem.Free;
    end;
  finally
    UnlockResource(H);
    FreeResource(H);
  end;
end;
*)  

{ TRGBCube ------------------------------------------}

constructor TRGBCube.Create(AnOwner: TComponent);
var
  DC: HDC;
begin
  inherited Create(AnOwner);
  OffScreen := TBitmap.Create;
  DC := GetDC(0);
  try
    if GetDeviceCaps(DC, BITSPIXEL) >= 8 then
    begin
      OffScreen.LoadFromResourceName(hInstance, 'RGB_DLG_256_COLOR');
      X := 75;
      y := 76;
    end
    else
    begin
      OffScreen.LoadFromResourceName(hInstance, 'RGB_DLG_16_COLOR');
      X := 74;
      Y := 76;
    end;
  finally
    ReleaseDC(0, DC);
  end;
 Width := OffScreen.Width + SqrSide;
 Height := OffScreen.Height + SqrSide;
 if OffScreen.Handle = 0 then
   raise Exception.Create('Can''t load resource bitmap');
  CubeAx := caNone;
  ControlStyle:= ControlStyle + [csCaptureMouse];
  Side := Step * CountStep;
end;

destructor TRGBCube.Destroy;
begin
  if Assigned(OffScreen) then OffScreen.Free;
  inherited Destroy;
end;

procedure TRGBCube.Paint;
var
  R: TRect;
begin
  R := Canvas.ClipRect;
  if (R.Left = 0) or (R.Right = 0) or (R.Top = 0) or (R.Bottom = 0) then begin
    R := ClientRect;
    Frame3D(Canvas, R, clBtnShadow, clBtnHighLight, 1);
  end;
  Canvas.Draw(2, 2, OffScreen);
  Draw3DAxes;
end;

procedure TRGBCube.Repaint;
var
  R: TRect;
begin
  if HandleAllocated then
  begin
    R := ClientRect;
    RectGrow(R, - 2);
    InvalidateRect(Handle, @R, False);
  end;
end;

procedure TRGBCube.SetColor(AColor: TColor);
begin
  if FColor <> AColor then
  begin
    FColor := AColor;
    Repaint;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TRGBCube.Draw3DAxes;
var
  XR, XG, XB, YR, YG, YB: Integer;
begin
  with Canvas do
  begin
    Pen.Style := psSolid;
    Pen.Color := clWhite;
    Brush.Style := bsClear;
    R := GetRValue(FColor);
    G := GetGValue(FColor);
    B := GetBValue(FColor);
    XR := X;
    YR := Y - Round(R *  Side / MaxCol * XCos);
    XG := X - Round(G * Side / MaxCol * XCos);
    YG := Y + Round(G * Side / MaxCol * YSin);
    XB := X + Round(B * Side / MaxCol * XCos);
    YB := Y + Round(B * Side / MaxCol * YSin);

    Rectangle(XR - SqrSide, YR - SqrSide, XR + SqrSide, YR + SqrSide);
    Rectangle(XG - SqrSide, YG - SqrSide, XG + SqrSide, YG + SqrSide);
    Rectangle(XB - SqrSide, YB - SqrSide, XB + SqrSide, YB + SqrSide);
    MoveTo(XB, YB);
    LineTo(XB, YB - (Y - YR));
    LineTo(XR, YR);
    LineTo(XG, YG - (Y - YR));
    LineTo(XG, YG);
    LineTo(XG - X + XB, YG - Y + YB);
    LineTo(XB, YB);
    MoveTo(XG - X + XB, YG - Y + YB);
    LineTo(XG - X + XB, YG + YB + YR - 2 * Y);
    LineTo(XG, YG - (Y - YR));
    LineTo(XG - X + XB, YG + YB + YR - 2 * Y);
    LineTo(XB, YB - (Y - YR));
  end;
end;

procedure TRGBCube.WMLButtonDown(var Message: TWMLButtonDown);
var
  XR, YR, XG, YG, XB, YB: Integer;
  A, D, C, Al, Bt, Gm: Double;
begin
  inherited;
  XR := X;
  YR := Y - Round(R * Side / MaxCol * XCos);
  XG := X - Round(G * Side / MaxCol * XCos);
  YG := Y + Round(G * Side / MaxCol * YSin);
  XB := X + Round(B * Side / MaxCol * XCos);
  YB := Y + Round(B * Side / MaxCol * YSin);
  with Message do
    if (XPos <= XR + SqrSide) and (XPos >= XR - SqrSide) and
       (YPos <= YR + SqrSide) and (YPos >= YR - SqrSide) then
      CubeAx := caRed
    else
      if (XPos <= XG + SqrSide) and (XPos >= XG - SqrSide) and
         (YPos <= YG + SqrSide) and (YPos >= YG - SqrSide) then
        CubeAx := caGreen
      else
        if (XPos <= XB + SqrSide) and (XPos >= XB - SqrSide) and
           (YPos <= YB + SqrSide) and (YPos >= YB - SqrSide) then
          CubeAx := caBlue
        else
        begin
          if (XPos >= X) and (XPos <= X + Side * XCos) and
             (YPos <= Y + (XPos - X) * YSin / XCos) and
             (YPos >= Y + (XPos - X) * YSin / XCos - Side * XCos) then
           begin
             R := Round((Y + (XPos - X) * YSin / XCos - YPos) / Side * MaxCol / XCos);
             G := 0;
             B := Round((XPos - (X + Side * XCos)) / Side * MaxCol / XCos);
             FColor := RGB(R, G, B);
             Repaint;
           end
           else
             if (XPos <= X) and (XPos >= X - Side * XCos) and
                (YPos <= Y + (X - XPos) * YSin / XCos) and
                (YPos >= Y + (X - XPos) * YSin / XCos - Side * XCos) then
              begin
                R := Round((Y + (X - XPos) * YSin / XCos - YPos) / Side * MaxCol / XCos);
                G := Round((X - (XPos + Side * XCos)) / Side * MaxCol / XCos);
                B := 0;
                FColor := RGB(R, G, B);
                Repaint;
              end
              else
                if ((YPos >= Y) and (YPos <= Y + Side * YSin) and
                    (XPos >= X - (YPos - Y) / YSin * XCos) and (XPos <= X + (YPos - Y) / YSin * XCos)) or
                   ((YPos >= Y + Side * YSin) and (YPos <= Y + 2 * Side * YSin) and
                    (XPos >= X - (2 * Side * YSin - YPos + Y) / YSin * XCos) and
                    (XPos <= X + (2 * Side * YSin - YPos + Y) / YSin * XCos))
                then
                begin
                  R := 0;
                  Al := ArcTan(YSin / XCos);
                  A := Abs(XPos - X);
                  D := YPos - Y;
                  C := Sqrt(A * A + D * D);
                  Bt := ArcTan(A / D);
                  Gm := (Pi / 2 - Al - Bt);
                  if XPos <= X then
                  begin
                    B := Round(Sin(Gm) * C / Sin(2 * Al) / Side * MaxCol);
                    G := Round(Sin(Pi - 2 * Al - Gm) * C / Sin(2 * Al) / Side * MaxCol);
                  end
                  else
                  begin
                    G := Round(Sin(Gm) * C / Sin(2 * Al) / Side * MaxCol);
                    B := Round(Sin(Pi - 2 * Al - Gm) * C / Sin(2 * Al) / Side * MaxCol);
                  end;
                    FColor := RGB(R, G, B);
                  Repaint;
                end;
        end;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TRGBCube.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  CubeAx := caNone;
end;

procedure TRGBCube.WMMouseMove(var Message: TWMMouseMove);
var
  RR, GG, BB: Integer;
  XX, YY: Double;
begin
  inherited;
  case CubeAx of
    caRed:
    begin
      YY := Message.YPos;
      if YY > Y then YY := Y;
      if YY < Y - Side * XCos then YY := Round(Y - Side * XCos);
      if YY <> 0 then
        RR := Round((Y - YY) / Side / XCos * MaxCol)
      else
        RR := 0;
      FColor := RGB(RR, G, B);
      Repaint;
    end;
    caGreen:
    begin
      YY := Message.YPos;
      XX := Message.XPos;
      if YY < Y then YY := Y;
      if YY > Y + Side * YSin then YY := Y + Side * YSin;
      if XX > X then XX := X;
      if XX < X - Side * XCos then XX := X - Side * XCos;
      if (YY <> 0) and (XX <> 0) then
        GG := Round(Sqrt((YY - Y) * (YY - Y) + (X - XX) * (X - XX)) / Side * MaxCol)
      else
        GG := 0;
      if GG >= 253 then GG := MaxCol;
      FColor := RGB( R, GG, B);
      Repaint;
    end;
    caBlue:
    begin
      YY := Message.YPos;
      XX := Message.XPos;
      if YY < Y then YY := Y;
      if YY > Y + Side * YSin then YY := Y + Side * YSin;
      if XX < X then XX := X;
      if XX > X + Side * XCos then XX := X + Side * XCos;
      if (YY <> 0) and (XX <> 0) then
        BB := Round(Sqrt((YY - Y) * (YY - Y) + (XX - X) * (XX - X)) / Side * MaxCol)
      else
        BB := 0;
      if BB >= 253 then BB := MaxCol;
      FColor := RGB( R, G, BB);
      Repaint;
    end;
  end;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TRGBCube.WMSize(var Message: TWMSize);
begin
  inherited;
  Width := OffScreen.Width + 4;
  Height := OffScreen.Height + 4;
end;

{ TDoubleColor ------------------------------------------------}

procedure TDoubleColor.Paint;
var
  R: TRect;
begin
  with Canvas do
  begin
    Brush.Style := bsSolid;

    Brush.Color := GetNearestColor(Canvas.Handle, FColor);
    R := GetClientRect;
    R.Bottom := R.Bottom div 2;
    Frame3D(Canvas, R, clBtnShadow, clBtnHighlight, 1);
    FillRect(R);

    Brush.Color := FColor;
    R := GetClientRect;
    R.Top := R.Bottom div 2;
    Frame3D(Canvas, R, clBtnShadow, clBtnHighlight, 1);
    FillRect(R);
  end;
end;

procedure TDoubleColor.Repaint;
begin
  if HandleAllocated then
    InvalidateRect(Handle, nil, False);
end;

procedure TDoubleColor.SetColor(AColor: TColor);
begin
  if FColor <> AColor then
  begin
    FColor := AColor;
    Repaint;
  end;
end;

{ THueBar -------------------------------------------}

constructor THueBar.Create(AnOwner: TComponent);

begin
  inherited Create(AnOwner);
  ControlStyle:= ControlStyle + [csCaptureMouse];
  Press := False;
  MaxR := MaxCol;
  MaxG := MaxCol;
  MaxB := MaxCol;
end;

destructor THueBar.Destroy;
begin
  inherited Destroy;
end;


procedure THueBar.Paint;

const
  StepBorder = 4;

var
  Rct: TRect;
  I: LongInt;
begin
  Rct := GetClientRect;
  with Canvas do
  begin
    Brush.Style := bsSolid;
    R := GetRValue(FColor);
    G := GetGValue(FColor);
    B := GetBValue(FColor);
    for I := 0 to StepsCount - 1 do
    begin
      Brush.Color := RGB(Round(MaxR / StepsCount * I),
                         Round(MaxG / StepsCount * I),
                         Round(MaxB / StepsCount * I));

      FillRect(RectSet( 0, Height - Round(I * Height / StepsCount),
               Width, Height - Round((I + 1) * Height / StepsCount)));
    end;
    Y := Height - Round((Height * Sqrt((R * R + G * G + B * B) / (MaxR * MaxR + MaxG * MaxG + MaxB * MaxB))));
    Frame3D(Canvas, Rct, clBtnShadow, clBtnHighLight, 1);
  end;
end;

procedure THueBar.Repaint;
var
  R: TRect;
begin
  if HandleAllocated then begin
    R:= ClientRect;
    RectGrow(R, - 1);
    InvalidateRect(Handle, @R, False);
  end;
end;

function THueBar.GetMaxColor: LongInt;
begin
  GetMaxColor := RGB(MaxR, MaxG, MaxB);
end;

procedure THueBar.SetupColor(X: Integer);
var
  RR, GG, BB: Integer;
begin
  if X < 0 then X := 0;
  if X > Height then X := Height;
  RR := MaxR - Round(MaxR / Height * X);
  GG := MaxG - Round(MaxG / Height * X);
  BB := MaxB - Round(MaxB / Height * X);
  FColor := RGB(RR, GG, BB);
end;

procedure THueBar.SetColor(AColor: TColor);
begin
  if FColor <> AColor then
  begin
    FColor := AColor;
    Repaint;
    R := GetRValue(FColor);
    G := GetGValue(FColor);
    B := GetBValue(FColor);
    if (R >= G) and (R >= B) then
    begin
      MaxR := MaxCol;
      if R <> 0 then
      begin
        MaxG := Round(MaxCol / R * G);
        MaxB := Round(MaxCol / R * B);
      end
      else
      begin
        MaxG := MaxCol;
        MaxB := MaxCol;
      end;
    end
    else
      if (G >= R) and (G >= B) then
      begin
        MaxG := MaxCol;
        MaxR := Round(MaxCol / G * R);
        MaxB := Round(MaxCol / G * B);
      end
      else
        if (B >= G) and (B >= R) then
        begin
          MaxB := MaxCol;
          MaxG := Round(MaxCol / B * G);
          MaxR := Round(MaxCol / B * R);
        end;

  end;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure THueBar.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  with Message do
    if (YPos >= Y - 6) and (YPos <= Y + 6) then
      Press := True
    else
      SetupColor(YPos);
end;

procedure THueBar.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  Press := False;
end;

procedure THueBar.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if Press then SetupColor(Message.YPos);
  Repaint;
  if Assigned(FOnChange) then FOnChange(Self);
end;

{ TRGBEdit -----------------------------------------------}

constructor TRGBEdit.Create(AOwner: TComponent);

  function CreateSpinEdit(InitValue: Integer): TxSpinEdit;
  begin
    Result := TxSpinEdit.Create(Self);
    Result.Parent:= Self;
    Result.Width := 50;
    Result.Top := 0;
    Result.MaxValue := MaxCol;
    Result.MinValue := 0;
    Result.Value := InitValue;
    Result.OnChange:= MyChange;
    Result.Font.Assign(FFont);
    Result.ParentFont := True;
    Result.SpinGap := 2;
    Test := True;
  end;

  function CreateLabel(Letter: Char): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent:= Self;
    Result.Top := REdit.Height div 2 - Result.Height div 2;
    Result.Caption := Letter;
    Result.Alignment := taCenter;
    Result.Font.Assign(FFont);
    Result.ParentFont := True;
  end;

begin
  inherited Create(AOwner);

  FFont := TFont.Create;
  FFont.Name := Def_FontName;
  FFont.Size := Def_FontSize;

  REdit := CreateSpinEdit(GetRvalue(FColor));
  GEdit := CreateSpinEdit(GetGValue(FColor));
  BEdit := CreateSpinEdit(GetBvalue(FColor));

  RLabel := CreateLabel('R');
  GLabel := CreateLabel('G');
  BLabel := CreateLabel('B');
end;

destructor TRGBEdit.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TRGBEdit.CreateWnd;
var
  X: Integer;
begin
  inherited CreateWnd;

  Width := REdit.Width + GEdit.Width + BEdit.Width
    + RLabel.Width + GLabel.Width + BLabel.Width + 12;
  Height := REdit.Height + 2; { assume all edits have equal height }

  RLabel.Left := 0;
  X := RLabel.Width + 2;

  REdit.Left := X;
  Inc(X, REdit.Width + 2);

  GLabel.Left := X;
  Inc(X, GLabel.Width + 2);

  GEdit.Left := X;
  Inc(X, GEdit.Width + 2);

  BLabel.Left := X;
  Inc(X, BLabel.Width + 2);

  BEdit.Left := X;
end;

procedure TRGBEdit.SetColor(AColor: TColor);
begin
  if FColor <> AColor then
  begin
    FColor := AColor;
    Test := False;
    GEdit.Value := GetGvalue(FColor);
    BEdit.Value := GetBvalue(FColor);
    REdit.Value := GetRvalue(FColor);
    Test := True;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TRGBEdit.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
  REdit.Font.Assign(AFont);
  GEdit.Font.Assign(AFont);
  BEdit.Font.Assign(AFont);
  RLabel.Font.Assign(AFont);
  GLabel.Font.Assign(AFont);
  BLabel.Font.Assign(AFont);
end;

procedure TRGBEdit.MyChange(Sender: TObject);
begin
  if not(Test) then exit;
  if REdit.Value > REdit.MaxValue then REdit.Value := REdit.MaxValue;
  if REdit.Value < REdit.MinValue then REdit.Value := REdit.MinValue;
  if GEdit.Value > GEdit.MaxValue then GEdit.Value := GEdit.MaxValue;
  if GEdit.Value < GEdit.MinValue then GEdit.Value := GEdit.MinValue;
  if BEdit.Value > BEdit.MaxValue then BEdit.Value := BEdit.MaxValue;
  if BEdit.Value < BEdit.MinValue then BEdit.Value := BEdit.MinValue;
  FColor := RGB(Round(REdit.Value), Round(GEdit.Value), Round(BEdit.Value));
  if Assigned(FOnChange) then FOnChange(Self);
end;

{TExGridColor ---------------------------------------------}
constructor TExGridColor.Create(AOwner: TComponent);
var
  I: Integer;
  S: String;
  IniFileName: array[0..260] of Char;
begin
  inherited Create(AOwner);
  Height := 65;
  Width := 188;
  FFont := TFont.Create;
  FFont.Name := Def_FontName;
  FFont.Size := Def_FontSize;
  AddColor := TButton.Create(Self);
  AddColor.Font.Assign(FFont);
  AddColor.ParentFont := True;
  AddColor.Parent := Self;
  AddColor.Width := 100;
  AddColor.Height := 20;
  AddColor.Left := 80;
  AddColor.Top := 37;
  AddColor.Caption := 'Add Color';
  AddColor.OnClick := DoButtonClick;

  GetModuleFileName(hInstance, IniFileName, SizeOf(IniFileName));
  StrCopy(StrRScan(IniFileName, '.') + 1, 'INI');
  IniFile := TIniFile.Create(StrPas(IniFileName));
  for I := 0 to 19 do
  begin
    Str(I, S);
    UserColor[I] := IniFile.ReadInteger(ColorsSection, S, clBtnFace);
  end;

  Number := 0;
end;

destructor TExGridColor.Destroy;
begin
  IniFile.Destroy;
  FFont.Free;
  inherited Destroy;
end;


procedure TExGridColor.Repaint;
begin
  if HandleAllocated then
    InvalidateRect(Handle, nil, False);
end;

procedure TExGridColor.Paint;
var
  I: Integer;
  Rct: TRect;
begin
  with Canvas do
    for I := 1 to 10 do
    begin
      Rct := RectSet(I * SqrX + (I - 1) * SqrSize, SqrY,
                           I * (SqrX + SqrSize), Round(SqrY + SqrSize * 0.9));
      Brush.Color := UserColor[I - 1];
      Frame3D(Canvas, Rct, clBtnShadow, clBtnHighlight, 1);
      FillRect(Rct);

      Rct := RectSet(I * SqrX + (I - 1) * SqrSize, Round(2 * SqrY + SqrSize * 0.9),
                     I * (SqrX + SqrSize), Round(2 * (SqrY + SqrSize * 0.9)));
      Brush.Color := UserColor[I + 9];
      Frame3D(Canvas, Rct, clBtnShadow, clBtnHighlight, 1);
      FillRect(Rct);
    end;
  DrawFocus;
end;

procedure TExGridColor.CreateWnd;
begin
  inherited CreateWnd;
  Height := 65;
  Width := 188;
end;

procedure TExGridColor.SetColor(AColor: TColor);
begin
  if FColor <> AColor then FColor := AColor;
end;

procedure TExGridColor.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
  AddColor.Font.Assign(AFont);
end;

procedure TExGridColor.DoButtonClick(Sender: TObject);
var
  S: String;
begin
  UserColor[Number] := FColor;
  DrawUserColor(Number);
  Str(Number, S);
  IniFile.WriteInteger(ColorsSection, S, FColor);
  Inc(Number);
  if Number > 19 then Number := 0;
  DrawUserColor(Number);
  DrawFocus;
end;

procedure TExGridColor.WMLButtonDown(var Message: TWMLButtonDown);
var
  I: Integer;
begin
  inherited;
  with Message do
  begin
    I := YPos div (SqrSize + SqrX) * 10 + XPos div (SqrSize + SqrX);
    DrawUserColor(Number);
    if (I >= 0) and  (I <= 19) then
    begin
      Number := I;
      FColor := UserColor[I]
    end;
    DrawFocus;
  end;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TExGridColor.DrawUserColor(I: Integer);
var
  Rct: TRect;
begin
  with Canvas do
  begin
    if I < 10 then
      Rct := RectSet((I + 1) * SqrX + I * SqrSize, SqrY,
                           (I + 1) * (SqrX + SqrSize), Round(SqrY + SqrSize * 0.9))
    else
      Rct := RectSet((I - 9) * SqrX + (I - 10) * SqrSize, Round(2 * SqrY + SqrSize * 0.9),
                           (I - 9) * (SqrX + SqrSize), Round(2 * (SqrY + SqrSize * 0.9)));
    Brush.Color := UserColor[I];
    Frame3D(Canvas, Rct, clBtnShadow, clBtnHighlight, 1);
    FillRect(Rct);
  end;
end;

procedure TExGridColor.DrawFocus;
var
  I: Integer;
  Rct: TRect;
begin
  with Canvas do
  begin
    if Number < 10 then
      Rct := RectSet((Number + 1) * SqrX + Number * SqrSize, SqrY,
                     (Number + 1) * (SqrX + SqrSize), Round(SqrY + SqrSize * 0.9))
    else
      Rct := RectSet((Number - 9) * SqrX + (Number - 10) * SqrSize, Round(2 * SqrY + SqrSize * 0.9),
                     (Number - 9) * (SqrX + SqrSize), Round(2 * (SqrY + SqrSize * 0.9)));

    Brush.Style := bsClear;
    Pen.Style := psSolid;
    Pen.Color := clGreen;
    for I := 1 to 3 do
    begin
      if I <> 2 then
        Pen.Color := clBlack
      else
        Pen.Color := clWhite;
      Rectangle(Rct.Left, Rct.Top, Rct.Right, Rct.Bottom);
      RectGrow(Rct, - 1);
    end;
  end;
end;


{TGridColor -----------------------------------------------}

constructor TGridColor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  GetPaletteEntries(GetStockObject(DEFAULT_PALETTE), 0, 20, SqrColor);
end;

procedure TGridColor.Paint;
var
  I: Integer;
  Rct: TRect;
begin
  with Canvas do
  begin
    for I := 1 to 10 do
    begin
      with SqrColor[I - 1] do
      begin
        Rct := RectSet(I * SqrX + (I - 1) * SqrSize, SqrY,
                             I * (SqrX + SqrSize), Round(SqrY + SqrSize * 0.9));
        Brush.Color := RGB(peRed, peGreen, peBlue);
        Frame3D(Canvas, Rct, clBtnShadow, clBtnHighlight, 1);
        FillRect(Rct);
      end;
      with SqrColor[I + 9] do
      begin
        Rct := RectSet(I * SqrX + (I - 1) * SqrSize, Round(2 * SqrY + SqrSize * 0.9),
                             I * (SqrX + SqrSize), Round(2 * (SqrY + SqrSize * 0.9)));
        Brush.Color := RGB(peRed, peGreen, peBlue);
        Frame3D(Canvas, Rct, clBtnShadow, clBtnHighlight, 1);
        FillRect(Rct);
      end;
    end;
  end;
  DrawFocus;
end;

procedure TGridColor.CreateWnd;
begin
  inherited CreateWnd;
  Height := 42;
  Width := 204
end;

procedure TGridColor.SetColor(AColor: TColor);
begin
  if AColor <> FColor then
  begin
    FColor := AColor;
    DrawFocus;
  end;
end;

procedure TGridColor.DrawFocus;
var
  I, K: Integer;
  Rct: TRect;
begin
  with Canvas do
  begin
    with SqrColor[NumerColor] do Brush.Color := RGB(peRed, peGreen, peBlue);
    Frame3D(Canvas, ColorRct, clBtnShadow, clBtnHighlight, 1);
    FillRect(ColorRct);
    RectGrow(ColorRct, + 1);
    for I := 1 to 10 do
    begin
      with SqrColor[I - 1] do
        if COLORREF(ColorToRGB(FColor)) = RGB(peRed, peGreen, peBlue) then
        begin
          Rct := RectSet(I * SqrX + (I - 1) * SqrSize, SqrY,
                         I * (SqrX + SqrSize), Round(SqrY + SqrSize * 0.9));
          ColorRct := Rct;
          NumerColor := I - 1;
          Brush.Style := bsClear;
          for K := 1 to 3 do
          begin
            if K <> 2 then
              Pen.Color := clBlack
            else
              Pen.Color := clWhite;
            Rectangle(Rct.Left, Rct.Top, Rct.Right, Rct.Bottom);
            RectGrow(Rct, - 1);
          end;
        end;
      with SqrColor[I + 9] do
        if COLORREF(ColorToRGB(FColor)) = RGB(peRed, peGreen, peBlue) then
        begin
          Rct := RectSet(I * SqrX + (I - 1) * SqrSize, Round(2 * SqrY + SqrSize * 0.9),
                         I * (SqrX + SqrSize), Round(2 * (SqrY + SqrSize * 0.9)));
          ColorRct := Rct;
          NumerColor := I + 9;
          Brush.Style := bsClear;
          for K := 1 to 3 do
          begin
            if K <> 2 then
              Pen.Color := clBlack
            else
              Pen.Color := clWhite;
            Rectangle(Rct.Left, Rct.Top, Rct.Right, Rct.Bottom);
            RectGrow(Rct, - 1);
          end;
        end;
    end;
  end;
end;

procedure TGridColor.WMLButtonDown(var Message:  TWMLButtonDown);
var
  I: Integer;
begin
  inherited;
  with Message do
  begin
    I := YPos div (SqrSize + SqrX) * 10 + XPos div (SqrSize + SqrX);
    if (I >= 0) and  (I <= 19) then
      with SqrColor[I] do
        FColor:= RGB(peRed, peGreen, peBlue);
    DrawFocus;
  end;
  if Assigned(FOnChange) then FOnChange(Self);
end;

{TxRGBDialog ----------------------------------------------}

constructor TxRGBDialog.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FFont := TFont.Create;
  FCaption := 'RGB Dialog';
end;

destructor TxRGBDialog.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

function TxRGBDialog.Execute: Boolean;
var
  xRGBBox: TxRGBBox;
begin
  xRGBBox := TxRGBBox.CreateNew(Self, FColor, FFont, FCaption);
  try
    if xRGBBox.ShowModal = id_Ok then
    begin
      xRGBBox.Font:= Font;
      FColor:= xRGBBox.BoxColor;
      Result := True;
    end else
      Result := False;
  finally
    xRGBBox.Free;
  end;
end;

procedure TxRGBDialog.SetColor(AColor: TColor);
begin
  FColor := AColor;
end;

procedure TxRGBDialog.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
end;

procedure TxRGBDialog.SetCaption(ACaption: String);
begin
  FCaption := ACaption;
end;

{TxRGBBox -------------------------------------------------}

constructor TxRGBBox.CreateNew(AnOwner: TComponent; AColor: TColor;
  AFont: TFont; ACaption: String);
begin
  inherited CreateNew(AnOwner);
  Font.Assign(AFont);
  BoxColor := AColor;

  RGBCube := TRGBCube.Create(Self);
  RGBCube.Parent := Self;
  RGBCube.Left := 8;
  RGBCube.Top := 8;
  RGBCube.Color := AColor;
  RGBCube.OnChange := RGBCubeChange;

  DoubleColor := TDoubleColor.Create(Self);
  DoubleColor.Parent := Self;
  DoubleColor.Top := 80;
  DoubleColor.Left := 306;
  DoubleColor.Width := 89;
  DoubleColor.Height := 49;
  DoubleColor.Color := AColor;

  HueBar := THueBar.Create(Self);
  HueBar.Parent := Self;
  HueBar.Top := 8;
  HueBar.Left := 167;
  HueBar.Width := 33;
  HueBar.Height := RGBCube.Height;
  HueBar.Color := AColor;
  HueBar.OnChange := HueBarChange;

  RGBEdit := TRGBEdit.Create(Self);
  RGBEdit.Parent := Self;
  RGBEdit.Top := 176;
  RGBEdit.Left := 8;
  RGBEdit.Width := 178;
  RGBEdit.Color := AColor;
  RGBEdit.Font.Assign(AFont);
  RGBEdit.OnChange := RGBEditChange;

  GridColor := TGridColor.Create(Self);
  GridColor.Parent := Self;
  GridColor.Top := 222;
  GridColor.Left := 8;
  GridColor.Color := AColor;
  GridColor.OnChange := GridColorChange;

  ExGridColor := TExGridColor.Create(Self);
  ExGridColor.Parent := Self;
  ExGridColor.Top := 222;
  ExGridColor.Left := 215;
  ExGridColor.Color := AColor;
  ExGridColor.OnChange := ExGridColorChange;
  ExGridColor.Font.Assign(AFont);

  xColorEdit := TxColorEdit.Create(Self);
  xColorEdit.Parent := Self;
  xColorEdit.Top := 138;
  xColorEdit.Left := 306;
  xColorEdit.Width := 89;
  xColorEdit.Color := AColor;
  xColorEdit.Font.Assign(AFont);
  xColorEdit.OnChange := xColorEditChange;

{  BitBtnOk := TBitBtn.Create(Self); }
  BitBtnOk := TButton.Create(Self);
  BitBtnOk.Parent := Self;
  BitBtnOk.Caption := '&Ok';
  BitBtnOk.Default := True;
{  BitBtnOk.Kind:= bkOk; }
  BitBtnOk.ModalResult := mrOk;
  BitBtnOk.Width := 89;
  BitBtnOk.Height := 25;
  BitBtnOk.Top := 8;
  BitBtnOk.Left := 306;
  BitBtnOk.Font.Assign(AFont);

{  BitBtnCancel := TBitBtn.Create(Self); }
  BitBtnCancel := TButton.Create(Self);
  BitBtnCancel.Parent := Self;
  BitBtnCancel.Caption := '&Cancel';
  BitBtnCancel.Cancel := True;
{  BitBtnCancel.Kind:= bkCancel; }
  BitBtnCancel.ModalResult := mrCancel;
  BitBtnCancel.Width := 89;
  BitBtnCancel.Height := 25;
  BitBtnCancel.Top := 40;
  BitBtnCancel.Left := 306;
  BitBtnCancel.Font.Assign(AFont);

  xSlider1 := TxSlider.Create(Self);
  xSlider1.Parent := Self;
  xSlider1.Left := 200;
  xSlider1.Height := HueBar.Height + 16;
  xSlider1.Layout := loVertLeft;
  xSlider1.ThumbBitmap.Handle := LoadBitmap(hInstance, 'RGB_DLG_THUMB');
  xSlider1.RailWidth := 0;
  xSlider1.RailBevelWidth := 1;
  xSlider1.Top := HueBar.Top - 8;
  xSlider1.Width := 20;
  xSlider1.Max := HueBar.Height;
  xSlider1.Value := HueBar.Color / HueBar.GetMaxColor * HueBar.Height;
  xSlider1.OnChange := xSliderChange;
  xSlider1.ThumbSize;
  xSlider1.RailRaised := False;

  Label1 := TLabel.Create(Self);
  Label1.Parent := Self;
  Label1.Caption := 'Solid';
  Label1.Left := 259;
  Label1.Top := DoubleColor.Top + DoubleColor.Height div 4 - Label1.Height div 2;
  Label1.Font.Assign(AFont);

  Label2 := TLabel.Create(Self);
  Label2.Parent := Self;
  Label2.Caption := 'Default Pallette';
  Label2.Top := 206;
  Label2.Left := 10;
  Label2.Font.Assign(AFont);

  Label3 := TLabel.Create(Self);
  Label3.Parent := Self;
  Label3.Caption := 'User Palette';
  Label3.Top := 206;
  Label3.Left := 217;
  Label3.Font.Assign(AFont);

  Label4 := TLabel.Create(Self);
  Label4.Parent := Self;
  Label4.Caption := 'Pattern';
  Label4.Top := DoubleColor.Top + 3 * DoubleColor.Height div 4 - Label4.Height div 2;
  Label4.Left := 259;
  Label4.Font.Assign(AFont);

  Label5 := TLabel.Create(Self);
  Label5.Parent := Self;
  Label5.Caption := 'Name';
  Label5.Top := xColorEdit.Top + xColorEdit.Height div 2 - Label5.Height div 2;
  Label5.Left := 259;
  Label5.Font.Assign(AFont);

  Top := 101;
  Left := 234;
  Width := 410;
  Height := 315;

  BorderStyle := bsDialog;
  BorderIcons := BorderIcons - [biMinimize, biMaximize];
  Caption := ACaption;
end;

procedure TxRGBBox.RGBEditChange(Sender: TObject);
begin
  RGBCube.Color := RGBEdit.Color;
  DoubleColor.Color := RGBEdit.Color;
  HueBar.Color := RGBEdit.Color;
  GridColor.Color := HueBar.Color;
  ExGridColor.Color := HueBar.Color;
  BoxColor := HueBar.Color;
  xColorEdit.Color := HueBar.Color;
  xSlider1.IntValue := Round(ColorToRGB(RGBCube.Color) / HueBar.GetMaxColor * HueBar.Height);
end;

procedure TxRGBBox.GridColorChange(Sender: TObject);
begin
  RGBCube.Color := GridColor.Color;
  DoubleColor.Color := GridColor.Color;
  HueBar.Color := GridColor.Color;
  RGBEdit.Color := GridColor.Color;
  xColorEdit.Color := GridColor.Color;
  BoxColor := GridColor.Color;
  ExGridColor.Color := GridColor.Color;
  xSlider1.IntValue := Round(ColorToRGB(RGBCube.Color) / HueBar.GetMaxColor * HueBar.Height);
end;

procedure TxRGBBox.ExGridColorChange(Sender: TObject);
begin
  RGBCube.Color := ExGridColor.Color;
  DoubleColor.Color := ExGridColor.Color;
  HueBar.Color := ExGridColor.Color;
  RGBEdit.Color := ExGridColor.Color;
  xColorEdit.Color := ExGridColor.Color;
  BoxColor := ExGridColor.Color;
  GridColor.Color := ExGridColor.Color;
  xSlider1.IntValue := Round(ColorToRGB(RGBCube.Color) / HueBar.GetMaxColor * HueBar.Height);
end;

procedure TxRGBBox.HueBarChange(Sender: TObject);
begin
  RGBCube.Color := HueBar.Color;
  DoubleColor.Color := HueBar.Color;
  GridColor.Color := HueBar.Color;
  ExGridColor.Color := HueBar.Color;
  RGBEdit.Color := HueBar.Color;
  xColorEdit.Color := HueBar.Color;
  BoxColor := HueBar.Color;
  xSlider1.IntValue := Round(ColorToRGB(RGBCube.Color) / HueBar.GetMaxColor * HueBar.Height);
end;

procedure TxRGBBox.RGBCubeChange(Sender: TObject);
begin
  HueBar.Color := RGBCube.Color;
  DoubleColor.Color := RGBCube.Color;
  GridColor.Color := RGBCube.Color;
  ExGridColor.Color := RGBCube.Color;
  RGBEdit.Color := RGBCube.Color;
  xColorEdit.Color := RGBCube.Color;
  BoxColor := RGBCube.Color;
  xSlider1.IntValue := Round(ColorToRGB(RGBCube.Color) / HueBar.GetMaxColor * HueBar.Height);
end;

procedure TxRGBBox.xColorEditChange(Sender: TObject);
begin
  HueBar.Color := xColorEdit.Color;
  DoubleColor.Color := xColorEdit.Color;
  GridColor.Color := xColorEdit.Color;
  ExGridColor.Color := xColorEdit.Color;
  RGBEdit.Color := xColorEdit.Color;
  RGBCube.Color := xColorEdit.Color;
  BoxColor := xColorEdit.Color;
  xSlider1.IntValue := Round(ColorToRGB(RGBCube.Color) / HueBar.GetMaxColor * HueBar.Height);
end;

procedure TxRGBBox.xSliderChange(Sender: TObject);
begin
  HueBar.SetupColor(HueBar.Height - xSlider1.IntValue);
  HueBarChange(Sender);
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsDlg', [TxRGBDialog]);
end;

end.
