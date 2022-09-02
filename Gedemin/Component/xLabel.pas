// ShlTanya, 20.02.2019

{++

  Copyright (c) 1995-98 by Golden Software of Belarus

  Module

    xlabel.pas

  Abstract

    Pretty label looks like those in Corel8.

  Author

    Andrei Kireev (19-Jan-98)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    19-Jan-98    andreik      Initial version.

  Known bugs

    –аст€жки рисуютс€ не слишком хорошо.
    ќсобенно если ширина мала.

--}


unit xLabel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Bkground;

const
  DefFromColor = clActiveCaption;
  DefGradientFill = True;
  DefOrigin = oLeft;
  DefToColor = clBtnFace;

  DefAutoSize = False;
  DefParentFont = False;
  DefTransparent = True;

type
  TxLabel = class(TLabel)
  private
    FFromColor: TColor;
    FGradientFill: Boolean;
    FOrigin: TOrigin; // использует тип из Bkground
    FToColor: TColor;

    procedure SetFromColor(const AFromColor: TColor);
    procedure SetGradientFill(const AGradientFill: Boolean);
    procedure SetOrigin(const AnOrigin: TOrigin);
    procedure SetToColor(const AToColor: TColor);

  protected
    procedure Paint; override;
    procedure PaintBackground; virtual;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property FromColor: TColor read FFromColor write SetFromColor
      default DefFromColor;
    property GradientFill: Boolean read FGradientFill write SetGradientFill
      default DefGradientFill;
    property Origin: TOrigin read FOrigin write SetOrigin
      default DefOrigin;
    property ToColor: TColor read FToColor write SetToColor
      default DefToColor;

    // переопредел€ем наследованные
    property AutoSize default DefAutoSize;
    property ParentFont default DefParentFont;
    property Transparent default DefTransparent; // new default
  end;

procedure Register;

implementation

{ TxLabel ------------------------------------------------}

constructor TxLabel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  AutoSize := DefAutoSize;
  ParentFont := DefParentFont;
  Transparent := DefTransparent;

  FFromColor := DefFromColor;
  FGradientFill := DefGradientFill;
  FOrigin := DefOrigin;
  FToColor := DefToColor;

  Font.Color := clCaptionText;
end;

procedure TxLabel.Paint;
begin
  if FGradientFill then
  try
    PaintBackground;
  except
    on Exception do ;
  end;

  inherited Paint;
end;

procedure TxLabel.PaintBackground;
var
  From, LTo: Longint;
  FromR, FromG, FromB, DeltaR, DeltaG, DeltaB: Integer;
  I: Word;
  DeltaY, DeltaX: Integer;
  R: TRect;
  Steps: Integer;
begin
  From := ColorToRGB(FFromColor);
  LTo := ColorToRGB(FToColor);
  FromR := GetRValue(From);
  FromG := GetGValue(From);
  FromB := GetBValue(From);
  DeltaR := GetRValue(LTo) - FromR;
  DeltaG := GetGValue(LTo) - FromG;
  DeltaB := GetBValue(LTo) - FromB;

  if (Width > 0) and ((Width div 8) < 256) then
    Steps := Width div 8
  else
    Steps := 255;

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
      if Steps > 0 then
        DeltaX := (Width div Steps) + 1
      else
        DeltaX := 1;
        
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
end;

procedure TxLabel.SetFromColor(const AFromColor: TColor);
begin
  if AFromColor <> FFromColor then
  begin
    FFromColor := AFromColor;
    Invalidate;
  end;
end;

procedure TxLabel.SetGradientFill(const AGradientFill: Boolean);
begin
  if AGradientFill <> FGradientFill then
  begin
    FGradientFill := AGradientFill;
    Invalidate;
  end;
end;

procedure TxLabel.SetOrigin(const AnOrigin: TOrigin);
begin
  if FOrigin <> AnOrigin then
  begin
    FOrigin := AnOrigin;
    Invalidate;
  end;
end;

procedure TxLabel.SetToColor(const AToColor: TColor);
begin
  if AToColor <> FToColor then
  begin
    FToColor := AToColor;
    Invalidate;
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('gsVC', [TxLabel]);
end;

end.






