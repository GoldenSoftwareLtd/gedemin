unit XPBevel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TxpBevelStyle = (bsLowered, bsRaised, bsFlat);
  TXPBevel = class(TBevel)
  private
    FStyle: TxpBevelStyle;
    FShape: TBevelShape;
    procedure SetStyle(const Value: TxpBevelStyle);
    procedure SetShape(const Value: TBevelShape);
  protected
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
  published
    property Style: TxpBevelStyle read FStyle write SetStyle default bsFlat;
    property Shape: TBevelShape read FShape write SetShape default bsBox;
    property Align;
    property Anchors;
    property Constraints;
    property ParentShowHint;
    property ShowHint;
    property Visible;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Win32', [TXPBevel]);
end;

{ TXPBevel }

constructor TXPBevel.Create(AOwner: TComponent);
begin
  inherited;
  FStyle := bsFlat;
end;

procedure TXPBevel.Paint;
const
  XorColor = $00FFD8CE;
var
  Color1, Color2: TColor;
  Temp: TColor;

  procedure BevelRect(const R: TRect);
  begin
    with Canvas do
    begin
      Pen.Color := Color1;
      PolyLine([Point(R.Left, R.Bottom), Point(R.Left, R.Top),
        Point(R.Right, R.Top)]);
      PolyLine([Point(R.Right, R.Top), Point(R.Right, R.Bottom),
        Point(R.Left, R.Bottom)]);
    end;
  end;

  procedure BevelLine(C: TColor; X1, Y1, X2, Y2: Integer);
  begin
    with Canvas do
    begin
      Pen.Color := C;
      MoveTo(X1, Y1);
      LineTo(X2, Y2);
    end;
  end;

begin
  with Canvas do
  begin
    if (csDesigning in ComponentState) then
    begin
      if (FShape = bsSpacer) then
      begin
        Pen.Style := psDot;
        Pen.Mode := pmXor;
        Pen.Color := XorColor;
        Brush.Style := bsClear;
        Rectangle(0, 0, ClientWidth, ClientHeight);
        Exit;
      end
      else
      begin
        Pen.Style := psSolid;
        Pen.Mode  := pmCopy;
        Pen.Color := clBlack;
        Brush.Style := bsSolid;
      end;
    end;

    Pen.Width := 1;

    case FStyle of
      bsLowered:
      begin
        Color1 := clBtnShadow;
        Color2 := clBtnHighlight;
      end;
      bsRaised:
      begin
        Color1 := clBtnHighlight;
        Color2 := clBtnShadow;
      end;
    else
      begin
        Color1 := clBtnShadow;
        Color2 := clBtnShadow;
      end;
    end;
    case FShape of
      bsBox: BevelRect(Rect(0, 0, Width - 1, Height - 1));
      bsFrame:
        begin
          Temp := Color1;
          Color1 := Color2;
          BevelRect(Rect(1, 1, Width - 1, Height - 1));
          if FStyle <> bsFlat then
          begin
 //           Color2 := Temp;
            Color1 := Temp;
            BevelRect(Rect(0, 0, Width - 2, Height - 2));
          end;
        end;
      bsTopLine:
        begin
          BevelLine(Color1, 0, 0, Width, 0);
          if FStyle <> bsFlat then
            BevelLine(Color2, 0, 1, Width, 1);
        end;
      bsBottomLine:
        begin
          BevelLine(Color1, 0, Height - 2, Width, Height - 2);
          if FStyle <> bsFlat then
            BevelLine(Color2, 0, Height - 1, Width, Height - 1);
        end;
      bsLeftLine:
        begin
          BevelLine(Color1, 0, 0, 0, Height);
          if FStyle <> bsFlat then
            BevelLine(Color2, 1, 0, 1, Height);
        end;
      bsRightLine:
        begin
          BevelLine(Color1, Width - 2, 0, Width - 2, Height);
          if FStyle <> bsFlat then
            BevelLine(Color2, Width - 1, 0, Width - 1, Height);
        end;
    end;
  end;
end;

procedure TXPBevel.SetShape(const Value: TBevelShape);
begin
  if FShape <> Value then
  begin
    FShape := Value;
    Invalidate;
  end;  
end;

procedure TXPBevel.SetStyle(const Value: TxpBevelStyle);
begin
  if Value <> FStyle then
  begin
    FStyle := Value;
    Invalidate;
  end;
end;

end.
