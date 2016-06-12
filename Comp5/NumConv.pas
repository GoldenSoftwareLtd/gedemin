
{++

  Copyright (c) 1995-2016 by Golden Software of Belarus, Ltd

  Module

    numconv.pas

  Abstract

    A Delphi component. Number convertation.

  Author

    Andrei Kireev (21-Oct-95)

  Revisions history

    1.00    29-Nov-95    andreik    Initial version.
    1.01    08-Jan-96    andreik    Type of Value property changed to Double.
    1.02    20-Oct-97    andreik    Delphi32 version.
    1.03    24-Jun-99    andreik    Fixed incompatibility with Delphi4.

--}

unit NumConv;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics,
  Controls, Forms, Dialogs;

type
  TLanguage = (lEnglish, lRussian);
  TGender = (gMale, gFemale, gNeuter);

const
  DefValue = 0;
  DefWidth = 0;
  DefBlankChar = #32;
  DefUpperCase = True;
  DefLanguage = lEnglish;
  DefGender = gMale;
  DefSignBeforePrefix = True;
  DefPrefixBeforeBlank = False;
  DefFreeStyleDigits = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  DefDecPrefix = '';
  DefHexPrefix = '$';
  DefOctPrefix = '0';
  DefBinPrefix = '';
  DefRomanPrefix = '';
  DefFreeStylePrefix = '';
  DefNumPrefix = '';

  DefDecPostfix = '';
  DefHexPostfix = '';
  DefOctPostfix = '';
  DefBinPostfix = 'b';
  DefRomanPostfix = '';
  DefFreeStylePostfix = '';
  DefNumPostfix = '';

const
  iDec = 1;
  iHex = 2;
  iOct = 3;
  iBin = 4;
  iFreeStyle = 5;

const
  HexDigits = '0123456789ABCDEF';
  DecDigits = '0123456789';
  OctDigits = '01234567';
  BinDigits = '01';

const
  MaxRoman = 3998;

type
  TPrefix = String;
  TPostfix = String;

type
  TNumberConvert = class(TComponent)
  private
    FValue: Double;
    FWidth: Integer;
    FBlankChar: Char;
    FUpperCase: Boolean;
    FLanguage: TLanguage;
    FGender: TGender;
    FSignBeforePrefix: Boolean;
    FPrefixBeforeBlank: Boolean;
    FFreeStyleDigits: String;
    FDecPrefix, FHexPrefix, FOctPrefix, FBinPrefix,
      FRomanPrefix, FFreeStylePrefix, FNumPrefix: TPrefix;
    FDecPostfix, FHexPostfix, FOctPostfix, FBinPostfix,
      FRomanPostfix, FFreeStylePostfix, FNumPostfix: TPostfix;
    FOnChange: TNotifyEvent;
    FPrecision: Byte;

    function GetValue(Index: Integer): String;
    procedure SetValue(Index: Integer; AValue: String);
    function GetRoman: String;
    procedure SetRoman(S: String);
    function GetNumeral: String;
    procedure SetNumeral(S: String);
    procedure SetFreeStyleDigits(AFreeStyleDigits: String);
    procedure SetVal(AValue: Double);
    procedure SetFPrecision(const Value: Byte);

  public
    constructor Create(AnOwner: TComponent); override;

    class function GenderOf(const ANominative, AGenitive: String): TGender;

    function ConvertToString(Digits: String; UpCase: Boolean;
      Prefix: TPrefix; Postfix: TPostfix): String;
    function ConvertFromString(S: String; Digits: String;
      Prefix: TPrefix; Postfix: TPostfix): Double;

  published
    property Value: Double read FValue write SetVal;
    property Width: Integer read FWidth write FWidth default DefWidth;
    property BlankChar: Char read FBlankChar write FBlankChar
      default DefBlankChar;
    property UpperCase: Boolean read FUpperCase write FUpperCase
      default DefUpperCase;
    property Language: TLanguage read FLanguage write FLanguage
      default DefLanguage;
    property Gender: TGender read FGender write FGender
      default DefGender;
    property SignBeforePrefix: Boolean read FSignBeforePrefix
      write FSignBeforePrefix default DefSignBeforePrefix;
    property PrefixBeforeBlank: Boolean read FPrefixBeforeBlank
      write FPrefixBeforeBlank default DefPrefixBeforeBlank;
    property FreeStyleDigits: String read FFreeStyleDigits write SetFreeStyleDigits;

    property Dec: String index iDec read GetValue write SetValue stored False;
    property Hex: String index iHex read GetValue write SetValue stored False;
    property Oct: String index iOct read GetValue write SetValue stored False;
    property Bin: String index iBin read GetValue write SetValue stored False;
    property Roman: String read GetRoman write SetRoman stored False;
    property FreeStyle: String index iFreeStyle read GetValue write SetValue stored False;

    property DecPrefix: TPrefix read FDecPrefix write FDecPrefix;
    property HexPrefix: TPrefix read FHexPrefix write FHexPrefix;
    property OctPrefix: TPrefix read FOctPrefix write FOctPrefix;
    property BinPref: TPrefix read FBinPrefix write FBinPrefix;
    property RomPrefix: TPrefix read FRomanPrefix write FRomanPrefix;
    property FreeStylePref: TPrefix read FFreeStylePrefix write FFreeStylePrefix;
    property NumPrefix: TPrefix read FNumPrefix write FNumPrefix;

    property DecPostfix: TPostfix read FDecPostfix write FDecPostfix;
    property HexPostfix: TPostfix read FHexPostfix write FHexPostfix;
    property OctPostfix: TPostfix read FOctPostfix write FOctPostfix;
    property BinPostfix: TPostfix read FBinPostfix write FBinPostfix;
    property RomPostfix: TPostfix read FRomanPostfix write FRomanPostfix;
    property FreeStylePostfix: TPostfix read FFreeStylePostfix write FFreeStylePostfix;
    property NumPostfix: TPostfix read FNumPostfix write FNumPostfix;

    property Numeral: String read GetNumeral write SetNumeral stored False;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    //Количество знаков после запятой
    property Precision: Byte read FPrecision write SetFPrecision;
  end;

  ENumberConvertError = class(Exception);

procedure Register;

implementation

uses
  Num2StrE, Num2StrR, Str2NumE;

{ Auxiliry funcxtions ------------------------------------}

function RepeatChar(Count: Integer; Ch: Char): String;
begin
  if (Count < 1) or (Count > 255) then
    Result := ''
  else begin
    FillChar(Result[1], Count, Ch);
    SetLength(Result, Count);
  end;
end;

function StripStr(S: String): String;
var
  B, E: Integer;
begin
  B := 1;
  while (B < Length(S)) and (S[B] in [#32, #9]) do Inc(B);
  E := Length(S);
  while (E >= B) and (S[E] in [#32, #9]) do Dec(E);
  Result := Copy(S, B, E - B + 1);
end;

{ TNumberConvert -----------------------------------------}

constructor TNumberConvert.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  { set defaults }
  FValue := DefValue;
  FWidth := DefWidth;
  FBlankChar := DefBlankChar;
  FUpperCase := DefUpperCase;
  FLanguage := DefLanguage;
  FGender := DefGender;
  FSignBeforePrefix := DefSignBeforePrefix;
  FPrefixBeforeBlank := DefPrefixBeforeBlank;
  FFreeStyleDigits := DefFreeStyleDigits;

  FDecPrefix := DefDecPrefix;
  FHexPrefix := DefHexPrefix;
  FOctPrefix := DefOctPrefix;
  FBinPrefix := DefBinPrefix;
  FRomanPrefix := DefRomanPrefix;
  FFreeStylePrefix := DefFreeStylePrefix;
  FNumPrefix := DefNumPrefix;

  FDecPostfix := DefDecPostfix;
  FHexPostfix := DefHexPostfix;
  FOctPostfix := DefOctPostfix;
  FBinPostfix := DefBinPostfix;
  FRomanPostfix := DefRomanPostfix;
  FFreeStylePostfix := DefFreeStylePostfix;
  FNumPostfix := DefNumPostfix;

  FOnChange := nil;
  FPrecision := 0;
end;

class function TNumberConvert.GenderOf(const ANominative, AGenitive: String): TGender;
begin
  if (ANominative > '') and (AGenitive > '') then
  begin
    case ANominative[Length(ANominative)] of
      'а', 'я', 'А', 'Я': Result := gFemale;
      'о', 'О', 'ё', 'Ё', 'е', 'Е': Result := gNeuter;
      'ь', 'Ь':
        if AGenitive[Length(AGenitive)] in ['я', 'Я'] then
          Result := gMale
        else
          Result := gFemale;
    else
      Result := gMale;
    end;
  end else
    Result := gNeuter;
end;

function TNumberConvert.ConvertToString(Digits: String; UpCase: Boolean;
  Prefix: TPrefix; Postfix: TPostfix): String;

  function _Div(X, Y: Double): Double;
  begin
    if (Frac(X) <> 0) or (Frac(Y) <> 0) then
      raise ENumberConvertError.Create('Numbers must be integer');

    Result := Int(X / Y);
  end;

  function _Mod(X, Y: Double): Double;
  begin
    if (Frac(X) <> 0) or (Frac(Y) <> 0) then
      raise ENumberConvertError.Create('Numbers must be integer');

    Result := X - Int(X / Y) * Y;
  end;

var
  Val: Double;
  Base: Integer;
  Pref: String;
begin
  Val := Abs(FValue);
  Base := Length(Digits);
  Result := '';

  repeat
    Result := Digits[Round(_Mod(Val, Base)) + 1] + Result;
    Val := _Div(Val, Base);
  until Val = 0;

  if UpCase then Result := SysUtils.UpperCase(Result)
    else Result := LowerCase(Result);

  Result := Result + Postfix;

  if FValue < 0 then
  begin
    if FSignBeforePrefix then
      Pref := '-' + Prefix
    else
      Pref := Prefix + '-';
  end else
    Pref := Prefix;

  if FPrefixBeforeBlank then
    Result := Pref + RepeatChar(FWidth - Length(Pref + Result),
      FBlankChar) + Result
  else
    Result := RepeatChar(FWidth - Length(Pref + Result),
      FBlankChar) + Pref + Result;
end;

function TNumberConvert.ConvertFromString(S: String; Digits: String;
  Prefix: TPrefix; Postfix: TPostfix): Double;
var
  I, Base, N: Integer;
begin
  Base := Length(Digits);

  S := SysUtils.UpperCase(StripStr(S));
  Prefix := SysUtils.UpperCase(Prefix);
  Postfix := SysUtils.UpperCase(Postfix);

  if S[1] = '-' then
  begin
    N := -1;
    Delete(S, 1, 1);
    S := StripStr(S);
  end else
    N := 1;

  if Pos(Prefix, S) = 1 then
  begin
    Delete(S, 1, Length(Prefix));
    S := StripStr(S);
    if S[1] = '-' then
    begin
      N := -1;
      Delete(S, 1, 1);
      S := StripStr(S);
    end;
  end;

  if Pos(Postfix, S) = Length(S) - Length(Postfix) + 1 then
    Delete(S, Length(S) - Length(Postfix) + 1, Length(Postfix));

  Result := 0;
  for I := 1 to Length(S) do
  begin
    if Pos(S[I], Digits) = 0 then
      raise ENumberConvertError.Create('Invalid number');
    Result := Result * Base + Pos(S[I], Digits) - 1;
  end;
  Result := Result * N;
end;

function TNumberConvert.GetValue(Index: Integer): String;
begin
  case Index of
    iDec: Result := ConvertToString(DecDigits, FUpperCase, FDecPrefix, FDecPostfix);
    iHex: Result := ConvertToString(HexDigits, FUpperCase, FHexPrefix, FHexPostfix);
    iOct: Result := ConvertToString(OctDigits, FUpperCase, FOctPrefix, FOctPostfix);
    iBin: Result := ConvertToString(BinDigits, FUpperCase, FBinPrefix, FBinPostfix);
    iFreeStyle: Result := ConvertToString(FFreeStyleDigits, FUpperCase, FFreeStylePrefix, FFreeStylePostfix);
  end;
end;

procedure TNumberConvert.SetValue(Index: Integer; AValue: String);
begin
  if AValue = '' then
    AValue := '0';

  case Index of
    iDec: FValue := ConvertFromString(AValue, DecDigits, FDecPrefix, FDecPostfix);
    iHex: FValue := ConvertFromString(AValue, HexDigits, FHexPrefix, FHexPostfix);
    iOct: FValue := ConvertFromString(AValue, OctDigits, FOctPrefix, FOctPostfix);
    iBin: FValue := ConvertFromString(AValue, BinDigits, FBinPrefix, FBinPostfix);
    iFreeStyle: FValue := ConvertFromString(AValue, FFreeStyleDigits, FFreeStylePrefix, FFreeStylePostfix);
  end;

  if Assigned(FOnChange) then FOnChange(Self);
end;

function TNumberConvert.GetRoman: String;
const
  RomDigs: array[1..9, 1..4] of String[4] =
    (
      ('M',    'C',    'X',    'I'),
      ('MM',   'CC',   'XX',   'II'),
      ('MMM',  'CCC',  'XXX',  'III'),
      ('',     'CD',   'XL',   'IV'),
      ('',     'D',    'L',    'V'),
      ('',     'DC',   'LX',   'VI'),
      ('',     'DCC',  'LXX',  'VII'),
      ('',     'DCCC', 'LXXX', 'VIII'),
      ('',     'CM',   'XC',   'IX')
    );
var
  S, Pref: String;
  I: Integer;
begin
  Result := '';
  if Abs(FValue) > MaxRoman then exit;

  S := Format('%4d', [Round(Abs(FValue))]);
  for I := 1 to Length(S) do
    if (S[I] <> '0') and (S[I] <> ' ') then
      Result := Result + RomDigs[Ord(S[I]) - Ord('0'), I];

  Result := Result + FRomanPostfix;

  if FValue < 0 then
  begin
    if FSignBeforePrefix then
      Pref := '-' + FRomanPrefix
    else
      Pref := FRomanPrefix + '-';
  end else
    Pref := FRomanPrefix;

  if FPrefixBeforeBlank then
    Result := Pref + RepeatChar(FWidth - Length(Pref + Result),
      FBlankChar) + Result
  else
    Result := RepeatChar(FWidth - Length(Pref + Result),
      FBlankChar) + Pref + Result;
end;

procedure TNumberConvert.SetRoman(S: String);

  function RomanDigit(D: Char): Integer;
  begin
    case UpCase(D) of
      'I': Result := 1;
      'V': Result := 5;
      'X': Result := 10;
      'L': Result := 50;
      'C': Result := 100;
      'D': Result := 500;
      'M': Result := 1000;
    else
      raise ENumberConvertError.Create('Invalid roman digit');
    end;
  end;

var
  I, Curr, N, Prev, Qty: Integer;
  Prefix, Postfix: String;
begin
  S := SysUtils.UpperCase(StripStr(S));
  Prefix := SysUtils.UpperCase(FRomanPrefix);
  Postfix := SysUtils.UpperCase(FRomanPostfix);

  if S[1] = '-' then
  begin
    N := -1;
    Delete(S, 1, 1);
    S := StripStr(S);
  end else
    N := 1;

  if Pos(Prefix, S) = 1 then
  begin
    Delete(S, 1, Length(Prefix));
    S := StripStr(S);
    if S[1] = '-' then
    begin
      N := -1;
      Delete(S, 1, 1);
      S := StripStr(S);
    end;
  end;

  if Pos(Postfix, S) = Length(S) - Length(Postfix) + 1 then
    Delete(S, Length(S) - Length(Postfix) + 1, Length(Postfix));

  FValue := 0;
  I := 1;
  Prev := -1;
  Qty := 0; {!!!}
  while I <= Length(S) do
  begin
    Curr := RomanDigit(S[I]);
    if I = Length(S) then
    begin
      if (Curr = Prev) and (Qty = 2) then
        raise ENumberConvertError.Create('Invalid roman number');
      FValue := FValue + Curr;
      break;
    end else
      if Curr >= RomanDigit(S[I + 1]) then
      begin
        if Curr = Prev then
        begin
          if Qty = 2 then
            raise ENumberConvertError.Create('Invalid roman number')
          else
            Inc(Qty);
        end else
        begin
          Prev := Curr;
          Qty := 0;
        end;
        FValue := FValue + Curr;
        Inc(I);
      end else begin
        FValue := FValue + RomanDigit(S[I + 1]) - Curr;
        Inc(I, 2);
      end;
  end; { while }

  FValue := FValue * N;

  if Assigned(FOnChange) then FOnChange(Self);
end;

function TNumberConvert.GetNumeral: String;
var
  S: array[0..255] of Char;
begin
  case FLanguage of
    lEnglish: Result := Int2StrE(FValue);
    lRussian:
      if FPrecision = 0 then
        Result := StrPas(Int2StrR(S, FValue, Byte(FGender)))
      else
      begin
        if Frac(FValue) = 0 then
          Result := StrPas(Int2StrR(S, FValue, Byte(FGender)))
        else
          Result := StrPas(Int2StrR(S, FValue, Byte(FGender))) + ' ' +
            StrPas(GetWholeWordR(S, FValue, Byte(FGender))) + ' ' +
            StrPas(GetPrecisionStrR(S, FValue, FPrecision, Byte(FGender)));
      end;
  end;

  if FUpperCase then Result := SysUtils.UpperCase(Result);

  Result := Result + FNumPostfix;

  if FPrefixBeforeBlank then
    Result := Trim(FNumPrefix + RepeatChar(FWidth - Length(Result)
      - Length(FNumPrefix), FBlankChar) + Result)
  else
    Result := Trim(RepeatChar(FWidth - Length(Result) - Length(FNumPrefix), FBlankChar)
      + FNumPrefix + Result);
end;

procedure TNumberConvert.SetNumeral(S: String);
begin
  S := StripStr(S);
  if Pos(FNumPrefix, S) = 1 then
    Delete(S, 1, Length(FNumPrefix));
  if Pos(FNumPostfix, S) = Length(S) - Length(FNumPostfix) then
    Delete(S, Pos(FNumPostfix, S), Length(FNumPostfix));

  case FLanguage of
    lEnglish: FValue := ConvertEnglNumeral(S);
  else
    raise ENumberConvertError.Create('Sorry, this language isn''t supported');
  end;

  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TNumberConvert.SetFreeStyleDigits(AFreeStyleDigits: String);
var
  A, B: Integer;
begin
  AFreeStyleDigits := SysUtils.UpperCase(AFreeStyleDigits);
  if AFreeStyleDigits <> FFreeStyleDigits then
  begin
    for A := 1 to Length(AFreeStyleDigits) - 1 do
      for B := A + 1 to Length(AFreeStyleDigits) do
        if AFreeStyleDigits[A] = AFreeStyleDigits[B] then
          raise ENumberConvertError.Create('Invalid FreeStyle digits');
    FFreeStyleDigits := AFreeStyleDigits;
  end;
end;

procedure TNumberConvert.SetVal(AValue: Double);
begin
  if AValue <> FValue then
  begin
    FValue := AValue;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('x-NonVisual', [TNumberConvert]);
end;

procedure TNumberConvert.SetFPrecision(const Value: Byte);
begin
  if Value > 4 then
    raise Exception.Create('Поддерживается не более четырех знаков после запятой!');
  FPrecision := Value;
end;

end.
