
{++

  Copyright (c) 1995-97 by Golden Software of Belarus

  Module

    str2nume.pas

  Abstract

    English numerals to number convertation.

  Author

    Andrei Kireev (7-Nov-95)

  Revisions history

    1.00    29-Nov-95    andreik    Initial version.

--}

unit Str2NumE;

interface

function ConvertEnglNumeral(S: String): LongInt;

implementation

uses
  SysUtils;

{ Auxiliry functions -------------------------------------}

procedure StripStr(var S: String);
var
  B, E: Integer;
begin
  B := 1;
  while (B <= Length(S)) and (S[B] in [#32, #9]) do
    Inc(B);

  E := Length(S);
  while (E >= B) and (S[E] in [#32, #9]) do
    Dec(E);

  S := Copy(S, B, E - B + 1);
end;

procedure DeleteSpaces(var S: String);
var
  I, C: Integer;
begin
  I := 1;
  C := 0;
  while I <= Length(S) do
  begin
    if S[I] = #9 then S[I] := #32;
    if S[I] = #32 then Inc(C) else
      if C <> 0 then
      begin
        if C > 1 then Delete(S, I - C, C - 1);
        C := 0;
        Dec(I, C - 2);
      end;
    Inc(I);
  end;
end;

function Pow1000(N: Integer): LongInt;
const
  A: array[1..3] of LongInt = (1000, 1000000, 1000000000);
begin
  Result := A[N];
end;

function Convert100(S: String): Integer;
const
  Digits: array[1..9] of String[5] = ('one', 'two', 'three', 'four',
    'five', 'six', 'seven', 'eight', 'nine');
  Teens: array[1..10] of String[20] = ('ten', 'eleven', 'twelve', 'thirteen',
    'fourteen', 'fifteen', 'sixteen', 'seventeen', 'eighteen', 'nineteen');
  Tens: array[1..8] of String = ('twenty', 'thirty', 'fourty', 'fifty', 'sixty',
    'seventy', 'eighty', 'ninety');
var
  I: Integer;
begin
  for I := 1 to 10 do
    if Teens[I] = S then
    begin
      Result := I + 9;
      exit;
    end;

  Result := 0;

  for I := 1 to 8 do
    if Pos(Tens[I], S) <> 0 then
    begin
      Result := (I + 1) * 10;
      Delete(S, 1, Length(Tens[I]) + 1);
      break;
    end;

  if (Length(S) = 0) or (S = 'zero') or (S = 'null') then
    exit;

  for I := 1 to 9 do
    if Digits[I] = S then
    begin
      Result := Result + I;
      exit;
    end
    else if I = 9 then
      raise Exception.Create('Invalid numeral');

  if Result = 0 then
    raise Exception.Create('Invalid numeral');
end;

function Convert1000(S: String): Integer;
var
  P: Integer;
begin
  P := Pos('hundred', S);
  if P <> 0 then
  begin
    Result := Convert100(Copy(S, 1, P - 2)) * 100;
    Delete(S, 1, P + Length('hundred'));
    if S[1] = ' ' then Delete(S, 1, 1);
    if Pos('and', S) = 1 then
      Delete(S, 1, 4);
  end else
    Result := 0;

  if Length(S) <> 0 then
    Result := Result + Convert100(S);
end;

{ Implementation -----------------------------------------}

function ConvertEnglNumeral(S: String): LongInt;
const
  Cats: array[1..3] of String = ('milliard', 'million', 'thousand');
var
  I, N, P: Integer;
  WasBillion: Boolean;
begin
  StripStr(S);
  DeleteSpaces(S);
  S := LowerCase(S);

  N := 1;
  if Pos('minus', S) = 1 then
  begin
    N := -1;
    Delete(S, 1, Length('minus') + 1);
  end
  else if Pos('plus', S) = 1 then
    Delete(S, 1, Length('plus') + 1);

  Result := 0;

  for I := 1 to 3 do
  begin
    if (I = 1) and (Pos('billion', S) <> 0) then
    begin
      P := Pos('billion', S);
      WasBillion := True;
    end else
    begin
      P := Pos(Cats[I], S);
      WasBillion := False;
    end;
    if P <> 0 then
    begin
      Result := Result + Convert1000(Copy(S, 1, P - 2)) * Pow1000(4 - I);
      if WasBillion then
        Delete(S, 1, P + Length('billion'))
      else
        Delete(S, 1, P + Length(Cats[I]));
      if S[1] = ' ' then Delete(S, 1, 1);
    end;
  end;

  if Length(S) <> 0 then
    Result := Result + Convert1000(S);

  Result := Result * N;
end;

end.
