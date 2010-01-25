{++

  Basic functions to work with formated text drawing and printing.
  Copyright c) 1996 - 97 by Golden Software

  Module

    xText.pas

  Abstract

    Basic functions to work with formated text drawing and printing.

  Author

    Vladimir Belyi (January, 1997)

  Contact address

    andreik@gs.minsk.by

  Uses

    Units:

      xBasics

    Forms:

    Other files:

  Revisions history

    1.00  10-jan-1997  belyi   Initial version

  Known bugs

    -

  Wishes

    -

  Notes/comments

    -

--}

unit xText;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs,
  xBasics;

type
  TFontScript = (fsNormal, fsSubscript, fsSuperscript);

  PHyperText = ^THyperText;
  THyperText = record
    Text: string;
    Script: TFontScript;
    Style: TFontStyles;
  end;

  THyperArray = class
  private
    FList: TList;
    function Get(Index: Integer): THyperText;
    function GetCount: Integer;
    function GetLast: THyperText;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Item: THyperText): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: THyperText read Get; default;
    property Last: THyperText read GetLast;
  end;

{ DrawHyperText procedure
  Draw a hyper text elements on a specified Canvas at the specified
  location. (Hyper text is a text with specified script and style.) }

  { this func creates a hyper text element }
function HyperText(Text: string; Script: TFontScript;
  Style: TFontStyles): THyperText;

  { and this one draws it on the Canvas }
procedure DrawHyperText(ACanvas: TCanvas; X, Y: Integer;
  Elements: array of THyperText);

{ returns Width of HyperText }
function HyperTextWidth(ACanvas: TCanvas; Elements: array of THyperText):
  Integer;

{ returns Height of HyperText }
function HyperTextHeight(ACanvas: TCanvas; Elements: array of THyperText):
  Integer;

{ returns the topest point of HyperText after having been drawn }
function HyperTextTop(ACanvas: TCanvas; X, Y: Integer;
  Elements: array of THyperText): Integer;

{ DrawFloat procedure draws a float value on the given Canvas at the given
  location. The number format is presented by two parameters:
    AfterPoint - number of digits after decimal point
    InExponent - number of digits in Exponential part
                 (zero - no exponential part) }
procedure DrawFloat(ACanvas: TCanvas; X, Y: Integer; Value: Extended;
  AfterPoint, InExponent: Integer);

procedure DrawCenteredFloat(ACanvas: TCanvas; XCenter, YCenter: Integer;
  Value: Extended; AfterPoint, InExponent: Integer);

function FloatWidth(ACanvas: TCanvas; Value: Extended; AfterPoint,
  InExponent: Integer): Integer;

function FloatHeight(ACanvas: TCanvas; Value: Extended; AfterPoint,
  InExponent: Integer): Integer;

{ DrawHyperText procedure
  Draw a hyper text elements on a specified Canvas at the specified
  location. (Hyper text is a text with specified script and style.) }
{ This function prints text under any angle.
  NOTE: Font must be a TrueType font! }
procedure zTextOut(ACanvas: TCanvas; xCenter, yCenter: Integer;
  Angle: Extended; Text: string);


implementation

function HyperText(Text: string; Script: TFontScript;
  Style: TFontStyles): THyperText;
begin
  Result.Text := text;
  Result.Script := Script;
  Result.Style := Style;
end;

type
  THypTextCmd = (htDraw, htWidth, htHeight, htTop);
  { htDraw - draw Text
    htWidth - calc its width
    htHeight - calc its height
    htTop - find the topest point (if Superscript is present, this may be
            less than Y
  }

{ Internal function for drawing Hyper Text. Only if Command=htDraw, the
  text is realy displayed; otherwise only its sizes are calculated }
function DrawHypText(ACanvas: TCanvas; X, Y: Integer;
  Elements: array of THyperText; Command: THypTextCmd): Integer;
var
  CurrentX, CurrentY: Integer;
  OldFont: TFont;
  i: Integer;
  R: TRect;
begin
  SetRect(R, X, Y, X, Y);
  OldFont := TFont.Create;
  OldFont.Assign(ACanvas.Font);
  try
    CurrentX := X;
    CurrentY := Y;
    for i := Low(Elements) to High(Elements) do
    begin
      ACanvas.Font.Style := Elements[i].Style;
      case Elements[i].Script of
        fsNormal:
          begin
            CurrentY := Y;
            ACanvas.Font.Size := OldFont.Size;
          end;
        fsSuperscript:
          begin
            ACanvas.Font.Size := OldFont.Size * 3 div 4;
            CurrentY := Y + abs(OldFont.Height div 2) -
              abs(ACanvas.Font.Height);
          end;
        fsSubscript:
          begin
            ACanvas.Font.Size := OldFont.Size * 3 div 4;
            CurrentY := Y + abs(OldFont.Height div 2);
          end;
      end;
      if Command = htDraw then
        ACanvas.TextOut(CurrentX, CurrentY, Elements[i].Text);
      CurrentX := CurrentX + ACanvas.TextWidth(Elements[i].Text);
      R.Top := MinInt(R.Top, CurrentY);
      R.Bottom := MaxInt(R.Bottom, CurrentY + abs(ACanvas.Font.Height));
      R.Right := CurrentX;
    end;
    case Command of
      htWidth: Result := R.Right - R.Left;
      htHeight: Result := R.Bottom - R.Top;
      htTop: Result := R.Top;
      else
        Result := 0;
    end;
  finally
    ACanvas.Font := OldFont;
    OldFont.Free;
  end;
end;

procedure DrawHyperText(ACanvas: TCanvas; X, Y: Integer;
  Elements: array of THyperText);
begin
  DrawHypText(ACanvas, X, Y, Elements, htDraw);
end;

procedure DrawCenteredHyperText(ACanvas: TCanvas; X, Y: Integer;
  Elements: array of THyperText);
var
  Width, Height: Integer;
begin
  Width := DrawHypText(ACanvas, X, Y, Elements, htWidth);
  Height := DrawHypText(ACanvas, X, Y, Elements, htHeight);
  DrawHypText(ACanvas, X - Width div 2, Y - Height div 2, Elements, htDraw);
end;

function HyperTextWidth(ACanvas: TCanvas; Elements: array of THyperText):
  Integer;
begin
  Result := DrawHypText(ACanvas, 0, 0, Elements, htWidth);
end;

function HyperTextHeight(ACanvas: TCanvas; Elements: array of THyperText):
  Integer;
begin
  Result := DrawHypText(ACanvas, 0, 0, Elements, htHeight);
end;

function HyperTextTop(ACanvas: TCanvas; X, Y: Integer;
  Elements: array of THyperText): Integer;
begin
  Result := DrawHypText(ACanvas, X, Y, Elements, htTop);
end;

function DrawFlt(ACanvas: TCanvas; X, Y: Integer; Value: Extended;
  AfterPoint, InExponent: Integer; Centered: Boolean;
  Command: THypTextCmd): Integer;
var
  ExpVal: LongInt;
  MainStr, ExpStr: string;
begin
  Result := 0; { 'cause htDraw returns nothing }
  if InExponent > 0 then
   begin
     if Value <> 0 then
       ExpVal := Trunc( Ln(Abs(Value)) / Ln(10) )
     else
       ExpVal := 0;
     if ExpVal < 0 then ExpVal := ExpVal - 1;

     Value := Value / FindPower(10, ExpVal);

     ExpStr := IntToStr(ExpVal);
     while Length(ExpStr) < InExponent do
       ExpStr := '0' + ExpStr;

     str(Value:(2 + AfterPoint):AfterPoint, MainStr);

     case Command of
       htDraw:
         if Centered then
           DrawCenteredHyperText(ACanvas, X, Y,
             [
               HyperText(MainStr, fsNormal, []),
               HyperText(#183'10', fsNormal, []),
               HyperText(ExpStr, fsSuperScript, [])
             ])
         else
           DrawHyperText(ACanvas, X, Y,
             [
               HyperText(MainStr, fsNormal, []),
               HyperText(#183'10', fsNormal, []),
               HyperText(ExpStr, fsSuperScript, [])
             ]);
       else
         Result := DrawHypText(ACanvas, X, Y,
             [
               HyperText(MainStr, fsNormal, []),
               HyperText(#183'10', fsNormal, []),
               HyperText(ExpStr, fsSuperScript, [])
             ], Command);
     end;
   end
  else { InExponent = 0 }
   begin
     str(Value:(2 + AfterPoint):AfterPoint, MainStr);
     case Command of
       htDraw:
         if Centered then
           DrawCenteredHyperText(ACanvas, X, Y,
             [ HyperText(MainStr, fsNormal, []) ])
         else
           DrawHyperText(ACanvas, X, Y, [ HyperText(MainStr, fsNormal, []) ]);
       else
         Result := DrawHypText(ACanvas, X, Y,
           [ HyperText(MainStr, fsNormal, []) ], Command);
     end;
   end;
end;

procedure DrawFloat(ACanvas: TCanvas; X, Y: Integer; Value: Extended;
  AfterPoint, InExponent: Integer);
begin
  DrawFlt(ACanvas, X, Y, Value, AfterPoint, InExponent, false, htDraw);
end;

function FloatWidth(ACanvas: TCanvas; Value: Extended; AfterPoint,
  InExponent: Integer): Integer;
begin
  Result := DrawFlt(ACanvas, 0, 0, Value, AfterPoint, InExponent, false,
    htWidth);
end;

function FloatHeight(ACanvas: TCanvas; Value: Extended; AfterPoint,
  InExponent: Integer): Integer;
begin
  Result := DrawFlt(ACanvas, 0, 0, Value, AfterPoint, InExponent, false,
    htHeight);
end;

procedure DrawCenteredFloat(ACanvas: TCanvas; XCenter, YCenter: Integer;
  Value: Extended; AfterPoint, InExponent: Integer);
begin
  DrawFlt(ACanvas, XCenter, YCenter, Value, AfterPoint, InExponent, true,
    htDraw);
end;

procedure zTextOut(ACanvas: TCanvas; xCenter, yCenter: Integer;
  Angle: Extended; Text: string);
var
  aLogRec: TLogFont;
  aFont, oldFont: hFont;
  aWidth, aHeight: Integer;
  x, y: Integer;
  aCos, aSin: Extended;
begin
  aSin := sin(Angle * Pi / 180);
  aCos := cos(Angle * Pi / 180);
  aWidth := ACanvas.TextWidth(Text);
  aHeight := ACanvas.TextHeight(Text);
  x := xCenter - Trunc(aWidth / 2 * aCos) - Trunc(aHeight / 2 * aSin);
  y := yCenter + Trunc(aWidth / 2 * aSin) - Trunc(aHeight / 2 * aCos);

  GetObject(ACanvas.Font.Handle, SizeOf(aLogRec), @aLogRec);
  aLogRec.lfEscapement := Round( Angle * 10 );
  aLogRec.lfOutPrecision := OUT_TT_ONLY_PRECIS;

  aFont := CreateFontIndirect(aLogRec);
  try
    ACanvas.Brush.Style := bsClear;
    oldFont := SelectObject(ACanvas.Handle, aFont);
    SetTextColor(ACanvas.Handle, ACanvas.Pen.Color);
    ACanvas.TextOut(x, y, Text);
    SelectObject(ACanvas.Handle, oldFont)
  finally
    DeleteObject(aFont);
  end;
end;

{ THyperArray ------------------------ }

constructor THyperArray.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor THyperArray.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

function THyperArray.Get(Index: Integer): THyperText;
begin
  Result := PHyperText(FList[Index])^;
end;

function THyperArray.GetCount: Integer;
begin
  Result := FList.Count;
end;

function THyperArray.Add(Item: THyperText): Integer;
var
  p: PHyperText;
begin
  New(p);
  p^ := Item;
  Result := FList.Add(p);
end;

procedure THyperArray.Clear;
var
  i: Integer;
begin
  for i := 0 to count - 1 do
    Dispose(PHyperText(FList[i]));
  FList.Clear;
end;

procedure THyperArray.Delete(Index: Integer);
begin
  if (Index > Count - 1) or (Index < 0 ) then
    raise ExClassList.Create('Index out of bounds.');
  Dispose(PHyperText(FList[Index]));
  FList.Delete(Index);
end;

function THyperArray.GetLast: THyperText;
begin
  Result := Get(Count - 1);
end;


end.
