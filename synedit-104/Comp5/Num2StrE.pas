
{++

  Copyright (c) 1994-97 by Golden Software of Belarus

  Module

    num2stre.pas

  Abstract

    Converts numbers to english numerals.

  Author

    Andrei Kireev (1994)

  Revisions history

    1.00    1994         andreik    Initial version.
    1.01    28-Oct-95    andreik    Added this header;
                                    ported to Delphi.
    1.02    07-Nov-95    andreik    Fixed bug with plurals.

--}

unit Num2StrE;

interface

uses
  SysUtils, WinProcs;

{ converts integer value }
function Int2StrE(N: Double): String;

implementation

{ converts one digit 1..9, 0 (zero) returns empty string }
function Dig2StrE(Digit: Word): String;
const
  Digs: array[0..9] of String = ('', 'one', 'two', 'three',
    'four', 'five', 'six', 'seven', 'eight', 'nine');
begin
  Result := Digs[Digit];
end;

{ converts teens: 1 -- eleven, 2 -- twelve, and so on }
function Teen2StrE(Teen: Word): String;
const
  TeenArr: array[1..9] of String = ('eleven', 'twelve', 'thirteen',
    'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen');
begin
  Result := TeenArr[Teen];
end;

{ converts tens: 1 -- ten, 2 -- twenty, 3 -- thirty... }
function Tens2StrE(Tens: Word): String;
const
  TensArr: array[1..9] of String = ('ten', 'twenty', 'thirty', 'forty',
    'fifty', 'sixty', 'seventy', 'eighty', 'ninety');
begin
  Result := TensArr[Tens];
end;

{ converts numbers below one thousand, exclude zero }
function Spec2StrE(N: Word): String;
var
  H, T, D: Word;  { hundreds, tens and digits }
begin
  H := Trunc(N / 100);
  N := N - H * 100;
  T := Trunc(N / 10);
  D := N - T * 10;

  Result := '';

  if H <> 0 then
  begin
    Result := Dig2StrE(H) + ' hundred';
    if H > 1 then Result := Result + 's';
    if (T <> 0) or (D <> 0) then
      Result := Result + ' and ';
  end;

  if (T = 1) and (D <> 0) then
    Result := Result + Teen2StrE(D)
  else
    if T <> 0 then
    begin
      if D <> 0 then
        Result := Result + Tens2StrE(T) + ' ' + Dig2StrE(D)
      else
        Result := Result + Tens2StrE(T);
    end else
      Result := Result + Dig2StrE(D);
end;

function Int2StrE(N: Double): String;
const
  Categories: array[0..3] of String = ('', ' thousand',
    ' million', ' milliard');
var
  A, I: Word;
  S, Tmp: String;
  D: Double;
  Neg: Boolean;
begin
  if N = 0 then
  begin
    Result := 'zero';
    exit;
  end;

  if N < 0 then
  begin
    N := -1 * N;
    Neg := true;
  end else
    Neg := false;

  S := '';
  for I := 0 to 3 do
  begin
    D := Frac(N / 1000) * 1000;
    A := Round(D);
    N := Int(N / 1000);
    if A <> 0 then
    begin
      Tmp := Spec2StrE(A) + Categories[I];
      if (A > 1) and (I <> 0) then Tmp := Tmp + 's '
        else Tmp := Tmp + ' ';
      Tmp := Tmp + S;
      S := Tmp;
    end;
  end;

  if Neg then
    Result := 'minus '
  else
    Result := '';

  if S[Length(S)] = ' ' then SetLength(S, Length(S) - 1); {Dec(Byte(S[0]));}

  Result := Result + S;
end;

end.
