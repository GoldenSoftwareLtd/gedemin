
{++

  Copyright (c) 1992-97 by Golden Software of Belarus

  Module

    num2strr.pas

  Abstract

    Russian numerals.

  Author

    Andrei Kireev (15-Jul-92)

  Revisions history

    1.00    15-Jul-92    andreik    Initial version.
    1.01    06-Apr-94    andreik    Revised.
    1.02    01-Nov-95    andreik    Minor changes.

--}

unit Num2StrR;

interface

const
  gdMale   = 0;   { Here prefix gd means gender }
  gdFemale = 1;
  gdNeuter = 2;

function Int2StrR(Dest: PChar; N: Double; Gender: Byte): PChar;
function GetPrecisionStrR(Dest: PChar; N: Double; Prec: Integer; Gender: Byte): PChar;
function GetWholeWordR(Dest: PChar; N: Double; Gender: Byte): PChar;

implementation

uses
  SysUtils, Math;

function StrStrip(Dest, Source: PChar): PChar;
var
  B, E: PChar;
begin
  B := Source;
  while (B^ <> #0) and (B^ in [#32, #9]) do Inc(B);
  E := StrEnd(Source);
  while (E > B) and (E^ in [#32, #9]) do Dec(E);
  Result := StrLCopy(Dest, B, StrLen(B) - StrLen(E));
end;

function GetLastDigit(N: LongInt): Byte;
begin
  GetLastDigit := Round(Frac(N / 10) * 10);
end;

function GetTwoLastDigit(N: LongInt): Byte;
begin
  GetTwoLastDigit := Round(Frac(N / 100) * 100);
end;

function Convert10(Dest: PChar; Dig: Byte; Gender: Byte): PChar;
begin
  case Dig of
    0: StrCopy(Dest, '����');
    1: case Gender of
         gdMale: StrCopy(Dest, '����');
         gdFemale: StrCopy(Dest, '����');
         gdNeuter: StrCopy(Dest, '����');
       end;
    2: case Gender of
         gdMale, gdNeuter: StrCopy(Dest, '���');
         gdFemale: StrCopy(Dest, '���');
       end;
    3: StrCopy(Dest, '���');
    4: StrCopy(Dest, '������');
    5: StrCopy(Dest, '����');
    6: StrCopy(Dest, '�����');
    7: StrCopy(Dest, '����');
    8: StrCopy(Dest, '������');
    9: StrCopy(Dest, '������');
  end;
  Convert10 := Dest;
end;

function TensAsStr(Dest: PChar; N: Byte): PChar;
begin
  case N of
    0: StrCopy(Dest, '');
    1: StrCopy(Dest, '������');
    2, 3: StrCat(Convert10(Dest, N, gdMale), '�����');
    4: StrCopy(Dest, '�����');
    5..8: StrCat(Convert10(Dest, N, gdMale), '�����');
    9: StrCopy(Dest, '���������');
  end;
  TensAsStr := Dest;
end;

function TinsAsStr(Dest: PChar; N: Byte): PChar;
begin
  case N of
    0: StrCopy(Dest, '������');
    1: StrCopy(Dest, '�����������');
    2: StrCopy(Dest, '����������');
    3: StrCopy(Dest, '����������');
    4: StrCopy(Dest, '������������');
    5: StrCopy(Dest, '����������');
    6: StrCopy(Dest, '�����������');
    7: StrCopy(Dest, '����������');
    8: StrCopy(Dest, '������������');
    9: StrCopy(Dest, '������������');
  end;
  TinsAsStr := Dest;
end;

function HundredsAsStr(Dest: PChar; N: Byte): PChar;
begin
  case N of
    0: StrCopy(Dest, '');
    1: StrCopy(Dest, '���');
    2: StrCopy(Dest, '������');
    3, 4: StrCat(Convert10(Dest, N, gdMale), '���');
    5..9: StrCat(Convert10(Dest, N, gdMale), '���');
  end;
  HundredsAsStr := Dest;
end;

function Convert1000(Dest: PChar; N: Integer; Gender: Byte): PChar;
var
  S: array[0..64] of Char;
begin
  Dest[0] := #0;
  if (N div 100) <> 0 then begin
    HundredsAsStr(Dest, N div 100);
    N := N - (N div 100) * 100;
  end;
  if (N div 10) = 1 then begin
    N := N - 10;
    StrCat(StrCat(Dest, ' '), TinsAsStr(S, N));
  end else begin
    if (N div 10) <> 0 then begin
      StrCat(StrCat(Dest, ' '), TensAsStr(S, N div 10));
      N := N - (N div 10) * 10;
    end;
    if N <> 0 then
      StrCat(StrCat(Dest, ' '), Convert10(S, N, Gender));
  end;
  StrStrip(Dest, Dest);
  Convert1000 := Dest;
end;

function Int2StrR(Dest: PChar; N: Double; Gender: Byte): PChar;
var
  Trillions,
  Billions,
  Millions,
  Thousands,
  Others: LongInt;
  S: array[0..64] of Char;
  St: String;
begin
  if N < 0 then begin
    N := - N;
    StrCopy(Dest, '����� ');
  end else
    Dest[0] := #0;

  St := FormatFloat('000000000000000', Trunc(N));

  Assert(Length(St) = 15);

  Others := StrToInt(Copy(St, Length(St) - 2, 3));
  Thousands := StrToInt(Copy(St, Length(St) - 5, 3));
  Millions := StrToInt(Copy(St, Length(St) - 8, 3));
  Billions := StrToInt(Copy(St, Length(St) - 11, 3));
  Trillions := StrToInt(Copy(St, Length(St) - 14, 3));

  case GetLastDigit(Trillions) of
    1:
      if GetTwoLastDigit(Trillions) <> 11 then
        StrCat(Dest, StrCat(Convert1000(S, Trillions, gdMale),
          ' �������� '))
      else
        StrCat(Dest, StrCat(Convert1000(S, Trillions, gdMale),
          ' ���������� '));
    2..4:
      if not (GetTwoLastDigit(Trillions) in [12..14]) then
        StrCat(Dest, StrCat(Convert1000(S, Trillions, gdMale),
          ' ��������� '))
      else
        StrCat(Dest, StrCat(Convert1000(S, Trillions, gdMale),
          ' ���������� '));
    else
      if Trillions <> 0 then
        StrCat(Dest, StrCat(Convert1000(S, Trillions, gdMale),
          ' ���������� '));
  end;

  case GetLastDigit(Billions) of
    1:
      if GetTwoLastDigit(Billions) <> 11 then
        StrCat(Dest, StrCat(Convert1000(S, Billions, gdMale),
          ' �������� '))
      else
        StrCat(Dest, StrCat(Convert1000(S, Billions, gdMale),
          ' ���������� '));
    2..4:
      if not (GetTwoLastDigit(Billions) in [12..14]) then
        StrCat(Dest, StrCat(Convert1000(S, Billions, gdMale),
          ' ��������� '))
      else
        StrCat(Dest, StrCat(Convert1000(S, Billions, gdMale),
          ' ���������� '));
    else
      if Billions <> 0 then
        StrCat(Dest, StrCat(Convert1000(S, Billions, gdMale),
          ' ���������� '));
  end;

  case GetLastDigit(Millions) of
    1:
      if GetTwoLastDigit(Millions) <> 11 then
        StrCat(Dest, StrCat(Convert1000(S, Millions, gdMale),
          ' ������� '))
      else
        StrCat(Dest, StrCat(Convert1000(S, Millions, gdMale),
          ' ��������� '));
    2..4:
      if not (GetTwoLastDigit(Millions) in [12..14]) then
        StrCat(Dest, StrCat(Convert1000(S, Millions, gdMale),
          ' �������� '))
      else
        StrCat(Dest, StrCat(Convert1000(S, Millions, gdMale),
          ' ��������� '));
    else
      if Millions <> 0 then
        StrCat(Dest, StrCat(Convert1000(S, Millions, gdMale),
          ' ��������� '));
  end;

  case GetLastDigit(Thousands) of
    1:
      if GetTwoLastDigit(Thousands) <> 11 then
        StrCat(Dest, StrCat(Convert1000(S, Thousands, gdFemale),
          ' ������ '))
      else
        StrCat(Dest, StrCat(Convert1000(S, Thousands, gdFemale),
          ' ����� '));
    2..4:
      if not (GetTwoLastDigit(Thousands) in [12..14]) then
        StrCat(Dest, StrCat(Convert1000(S, Thousands, gdFemale),
          ' ������ '))
      else
        StrCat(Dest, StrCat(Convert1000(S, Thousands, gdFemale),
          ' ����� '));
    else
      if Thousands <> 0 then
        StrCat(Dest, StrCat(Convert1000(S, Thousands, gdFemale),
          ' ����� '));
  end;

  if Others <> 0 then begin
    StrCat(Dest, Convert1000(S, Others, Gender));
    StrStrip(Dest, Dest);
  end else begin
    StrStrip(Dest, Dest);
    if Dest[0] = #0 then StrCopy(Dest, '����');
  end;
  Int2StrR := Dest;
end;

function GetPrecisionStrR(Dest: PChar; N: Double; Prec: Integer; Gender: Byte): PChar;
var
  FValue: Integer;
  S: array[0..64] of Char;
begin
  Dest[0] := #0;

  FValue := Round(Frac(Abs(N)) * Power(10, Prec) + 0.0000001);

  if FValue <> 0 then
  begin
    while (FValue mod 10 = 0) and (Prec > 1) do
    begin
      Dec(Prec);
      FValue := FValue div 10;
    end;

    if Prec = 4 then
    begin
      case GetLastDigit(FValue) of
      1:if GetTwoLastDigit(FValue) = 11 then
          StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' �������������� '))
        else
          StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' �������������� '));
      0, 2..9: StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' �������������� '));
      end;
    end else if Prec = 3 then
    begin
      case GetLastDigit(FValue) of
      1:if GetTwoLastDigit(FValue) = 11 then
          StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' �������� '))
        else
          StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' �������� '));
      0, 2..9: StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' �������� '));
      end;
    end else if Prec = 2 then
    begin
      case GetLastDigit(FValue) of
      1:if GetTwoLastDigit(FValue) = 11 then
          StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' ����� '))
        else
          StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' ����� '));
      0, 2..9: StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' ����� '));
      end;
    end else if Prec = 1 then
    begin
      case GetLastDigit(FValue) of
      1: StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' ������� '));
      0, 2..9: StrCat(Dest, StrCat(Convert1000(S, FValue, gdFemale),
            ' ������� '));
      end;
    end;
  end;

  Result := Dest;
end;

function GetWholeWordR(Dest: PChar; N: Double; Gender: Byte): PChar;
var
  FValue: Integer;
begin
  Dest[0] := #0;
  //���� � ��� ���� ����� ����� �������, �� ���������� ����� "�����"
  if (N - Int(N) <> 0) then
  begin
    if Abs(N) > 999 then
      FValue := StrToInt(Copy(FloatToStr(Int(N)), Length(FloatToStr(Int(N))) - 2, 3))
    else
      FValue := Abs(Trunc(N));
    case GetLastDigit(FValue) of
      1:
        if GetTwoLastDigit(FValue) = 11 then
          StrCat(Dest, '�����')
        else if Gender = gdFemale then
          StrCat(Dest, '�����')
        else if Gender = gdNeuter then
          StrCat(Dest, '���oe')
        else
          StrCat(Dest, '�����');

      0, 2..9: StrCat(Dest, '�����');
    end;
  end;
  Result := Dest;
end;

end.
