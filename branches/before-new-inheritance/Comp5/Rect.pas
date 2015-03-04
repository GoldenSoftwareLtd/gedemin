
{++ BUILD 0002

  Copyright (c) 1995-98 by Golden Software

  Module

    rect.pas

  Abstract

    A set of routines to work with TRects.

  Author

    Andrei Kireev (23-Sep-95)

  Contact address



  Revisions history

    1.00    23-Sep-95    andreik    Initial version.
    1.01    26-Sep-95    andreik    Added RectSet function.
    1.02    27-Sep-95    andreik    Added RectInclude function.
    1.03    27-Nov-95    andreik    Added RectIntersection, RectNull, RectIsNull,
                                    RectValid and other functions.
    1.04    01-Dec-95    andreik    Added RectCentralPoint function.
    1.05    20-Oct-97    andreik    Ported to Delphi32.
    1.06    11-Oct-98    andreik    NullRect added. RectCenter added.

--}

unit Rect;

interface

uses
  WinTypes;

const
  NullRect: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);  

{ height = bottom - top }
function RectHeight(const R: TRect): Integer;

{ width = right - left }
function RectWidth(const R: TRect): Integer;

{ returns area of the given rect }
function RectArea(const R: TRect): LongInt;

{ expands rect in all directions }
procedure RectGrow(var R: TRect; Delta: Integer);

{ moves rect relative to its current position }
procedure RectRelativeMove(var R: TRect; DX, DY: Integer);

{ sets new coordinates to the rect's left-upper corner }
procedure RectMoveTo(var R: TRect; X, Y: Integer);

{ fills TRect record with given values }
function RectSet(Left, Top, Right, Bottom: Integer): TRect;

{ initializes TRect by two given points }
function RectSetPoint(const TopLeft, BottomRight: TPoint): TRect;

{ returns True if R1 includes R2 }
function RectInclude(const R1, R2: TRect): Boolean;

{ returns the intersection of two rects or null rect
  if they don't intersect }
function RectIntersection(const R1, R2: TRect): TRect;

{ returns True if R1 intersect R2 and False otherwise }
function RectIsIntersection(const R1, R2: TRect): Boolean;

{ a rect is valid if the following conditions are valid:
  left <= right & top <= bottom }
function RectIsValid(const R: TRect): Boolean;

{ tests given array of TRect for the validity }
function RectsAreValid(const Arr: array of TRect): Boolean;

{ returns rect with zeroed all fields }
function RectNull: TRect;

{ tests whether given rect is null or not }
function RectIsNull(const R: TRect): Boolean;

{ tests whether given rect is square or not }
function RectIsSquare(const R: TRect): Boolean;

{ returns central point of the given Rect }
function RectCentralPoint(const R: TRect): TPoint;

{ returns True if R1 cover R2 and False otherwise }
function RectCover(const R1, R2: TRect): Boolean;

// centers R2 inside R1
function RectCenter(const R1, R2: TRect): TRect;

// centers R2 inside R1 vertically
function RectVCenter(const R1, R2: TRect): TRect;

implementation

{ Auxiliry functions -------------------------------------}

function GetMin(A, B: Integer): Integer;
begin
  if A < B then Result := A else Result := B;
end;

function GetMax(A, B: Integer): Integer;
begin
  if A > B then Result := A else Result := B;
end;

{ Implementation -----------------------------------------}

function RectHeight(const R: TRect): Integer;
begin
  Result := R.Bottom - R.Top;
end;

function RectWidth(const R: TRect): Integer;
begin
  Result := R.Right - R.Left;
end;

function RectArea(const R: TRect): LongInt;
begin
  Result := RectHeight(R) * RectWidth(R);
end;

procedure RectGrow(var R: TRect; Delta: Integer);
begin
  with R do
  begin
    Dec(Left, Delta);
    Dec(Top, Delta);
    Inc(Right, Delta);
    Inc(Bottom, Delta);
  end;
end;

procedure RectRelativeMove(var R: TRect; DX, DY: Integer);
begin
  with R do
  begin
    Inc(Left, DX);
    Inc(Right, DX);
    Inc(Top, DY);
    Inc(Bottom, DY);
  end;
end;

procedure RectMoveTo(var R: TRect; X, Y: Integer);
begin
  with R do
  begin
    Right := X + Right - Left;
    Bottom := Y + Bottom - Top;
    Left := X;
    Top := Y;
  end;
end;

function RectSet(Left, Top, Right, Bottom: Integer): TRect;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Right;
  Result.Bottom := Bottom;
end;

function RectSetPoint(const TopLeft, BottomRight: TPoint): TRect;
begin
  Result.TopLeft := TopLeft;
  Result.BottomRight := BottomRight;
end;

function RectInclude(const R1, R2: TRect): Boolean;
begin
  Result := (R1.Left <= R2.Left) and (R1.Top <= R2.Top)
    and (R1.Right >= R2.Right) and (R1.Bottom >= R2.Bottom);
end;

function RectIntersection(const R1, R2: TRect): TRect;
begin
  with Result do
  begin
    Left := GetMax(R1.Left, R2.Left);
    Top := GetMax(R1.Top, R2.Top);
    Right := GetMin(R1.Right, R2.Right);
    Bottom := GetMin(R1.Bottom, R2.Bottom);
  end;

  if not RectIsValid(Result) then
    Result := RectSet(0, 0, 0, 0);
end;

function RectIsIntersection(const R1, R2: TRect): Boolean;
begin
  Result := not RectIsNull(RectIntersection(R1, R2));
end;

function RectIsValid(const R: TRect): Boolean;
begin
  with R do
    Result := (Left <= Right) and (Top <= Bottom);
end;

function RectsAreValid(const Arr: array of TRect): Boolean;
var
  I: Integer;
begin
  for I := Low(Arr) to High(Arr) do
    if not RectIsValid(Arr[I]) then
    begin
      Result := False;
      exit;
    end;
  Result := True;
end;

function RectNull: TRect;
begin
  Result := RectSet(0, 0, 0, 0);
end;

function RectIsNull(const R: TRect): Boolean;
begin
  with R do
    Result := (Left = 0) and (Right = 0) and (Top = 0) and (Bottom = 0);
end;

function RectIsSquare(const R: TRect): Boolean;
begin
  Result := RectHeight(R) = RectWidth(R);
end;

function RectCentralPoint(const R: TRect): TPoint;
begin
  Result.X := R.Left + (RectWidth(R) div 2);
  Result.Y := R.Top + (RectHeight(R) div 2);
end;

function RectCover(const R1, R2: TRect): Boolean;
begin
  Result := (RectWidth(R1) >= RectWidth(R2))
    and (RectHeight(R1) >= RectHeight(R2));
end;

function RectCenter(const R1, R2: TRect): TRect;
begin
  Result.Left := R1.Left + ((RectWidth(R1) - RectWidth(R2)) div 2);
  Result.Right := Result.Left + RectWidth(R2);
  Result.Top := R1.Top + ((RectHeight(R1) - RectHeight(R2)) div 2);
  Result.Bottom := Result.Top + RectHeight(R2);
end;

function RectVCenter(const R1, R2: TRect): TRect;
begin
  Result.Top := R1.Top + ((RectHeight(R1) - RectHeight(R2)) div 2);
  Result.Bottom := Result.Top + RectHeight(R2);
end;

end.
