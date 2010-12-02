
{******************************************}
{                                          }
{             FastReport v2.53             }
{           Shape Add-In Object            }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Shape;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, FR_Class, StdCtrls,
  Controls, Forms, ExtCtrls, Menus;


const
  skRectangle = 0;
  skRoundRectangle = 1;
  skEllipse = 2;
  skTriangle = 3;
  skDiagonal1 = 4;
  skDiagonal2 = 5;

type
  TfrShapeObject = class(TComponent)  // fake component
  end;

  TfrShapeView = class(TfrView)
  private
    procedure DrawShape;
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
  public
    ShapeType: Byte;
    constructor Create; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToFR3Stream(Stream: TStream); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    procedure DefineProperties; override;
  end;


implementation

uses FR_Utils, FR_Const
{$IFDEF Delphi6}
, Variants
{$ENDIF};

{$R *.RES}


constructor TfrShapeView.Create;
begin
  inherited Create;
  ShapeType := skRectangle;
  BaseName := 'Shape';

  frConsts['skRectangle'] := skRectangle;
  frConsts['skRoundRectangle'] := skRoundRectangle;
  frConsts['skEllipse'] := skEllipse;
  frConsts['skTriangle'] := skTriangle;
  frConsts['skDiagonal1'] := skDiagonal1;
  frConsts['skDiagonal2'] := skDiagonal2;
end;

procedure TfrShapeView.DefineProperties;
begin
  inherited DefineProperties;
  AddEnumProperty('Shape',
    'skRectangle;skRoundRectangle;skEllipse;skTriangle;skDiagonal1;skDiagonal2',
    [skRectangle,skRoundRectangle,skEllipse,skTriangle,skDiagonal1,skDiagonal2]);
end;

procedure TfrShapeView.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'SHAPE' then
    ShapeType := Value;
end;

function TfrShapeView.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'SHAPE' then
    Result := ShapeType
end;

procedure TfrShapeView.DrawShape;
var
  x1, y1, min: Integer;
begin
  x1 := Round((SaveX + SaveDX) * ScaleX + OffsX);
  y1 := Round((SaveY + SaveDY) * ScaleY + OffsY);
  min := dx;
  if dy < dx then
    min := dy;
  with Canvas do
  begin
    Pen.Width := Round(FrameWidth);
    Pen.Color := FrameColor;
    Pen.Style := psSolid;
    SetBkMode(Handle, Opaque);
    Brush.Style := bsClear;
    if FillColor <> clNone then
      Brush.Color := FillColor;
    case ShapeType of
      skRectangle:
        Rectangle(x, y, x1 + 1, y1 + 1);
      skRoundRectangle:
        RoundRect(x, y, x1 + 1, y1 + 1, min div 4, min div 4);
      skEllipse:
        Ellipse(x, y, x1 + 1, y1 + 1);
      skTriangle:
          Polygon([Point(x1, y1), Point(x, y1), Point(x + (x1 - x) div 2, y), Point(x1, y1)]);
      skDiagonal1:
        begin
          MoveTo(x, y1);
          LineTo(x1, y);
        end;
      skDiagonal2:
        begin
          MoveTo(x, y);
          LineTo(x1, y1);
        end;
    end;
  end;
end;

procedure TfrShapeView.Draw(Canvas: TCanvas);
var
  FillC: Integer;
begin
  BeginDraw(Canvas);
  Memo1.Assign(Memo);
  CalcGaps;
  FillC := FillColor;
  FillColor := clNone;
  ShowBackground;
  ShowFrame;
  FillColor := FillC;
  DrawShape;
  RestoreCoord;
end;

procedure TfrShapeView.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  Stream.Read(ShapeType, 1);
end;

procedure TfrShapeView.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  Stream.Write(ShapeType, 1);
end;

procedure TfrShapeView.DefinePopupMenu(Popup: TPopupMenu);
begin
  // no specific items in popup menu
end;

procedure TfrShapeView.SaveToFR3Stream(Stream: TStream);

  procedure WriteStr(const s: String);
  begin
    Stream.Write(s[1], Length(s));
  end;

begin
  inherited;

  WriteStr(' Shape="' + IntToStr(ShapeType) + '"');
end;


var
  Bmp: TBitmap;

initialization
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_SHAPE');
  frRegisterObject(TfrShapeView, Bmp, IntToStr(SInsShape));

finalization
  Bmp.Free;

end.

