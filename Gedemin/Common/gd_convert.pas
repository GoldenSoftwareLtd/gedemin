// ShlTanya, 24.02.2019

unit gd_convert;

interface

uses
  NumConv, gdcBaseInterface;

const
  CacheFlushInterval   = 120 * 60 * 1000; //2 hrs in msec

  caseName             = 0;
  caseLower            = 1;
  caseUpper            = 2;
  caseMixed            = 3;

  partSubstWhenZero    = 1;
  partHideFracWhenZero = 2;
  partHideWholeWhenZero= 4;

{

  @N         -- числительное
  @N#,##0.00 -- отформатированное число
  @NG        -- число
  @W         -- целая часть, числительное
  @W#,##0.00 -- отформатированное число
  @WG        -- число
  @D         -- дробная часть, числительное
  @D#,##0.00 -- отформатированное число
  @DG        -- число

  @F         -- полное наименование целых единиц
  @B         -- сокращенное наименование целых единиц
  @C         -- полное наименование дробных единиц
  @K         -- сокращенное наименование дробных единиц

  @S         -- знак валюты
  @I         -- ISO валюты
  @O         -- код валюты
}

function GetNumeral(const AFormat: String; AValue: Double; const ARounding: Double;
  const AFracBase: Integer; const ACase: Integer; const AParts: Integer; const ANames: String): String;
function GetCurrNumeral(const ACurrKey: TID; const AFormat: String; AValue: Double; const ARounding: Double;
  const ACase: Integer = caseName; const AParts: Integer = 0; const ASubst: String = '';
  const ADecimalSeparator: String = ''; const AThousandSeparator: String = ''): String;

function GetSumCurr(const ACurrKey: TID; const AValue: Double; const ACentAsString: Boolean;
  const AnIncludeCent: Boolean): String;
function GetSumStr(const AValue: Double; const APrecision: Byte = 0): String;
function GetSumStr2(const AValue: Double; const AGender: TGender): String;
function GetRubSumStr(const AValue: Double): String;
function GetFullRubSumStr(const AValue: Double): String;

function MulDiv(const ANumber: Double; const ANumerator: Double; const ADenominator: Double;
  const ARoundMethod: Integer; const ADecPlaces: Integer): Double;

implementation

uses
  Classes, Windows, Forms, SysUtils, gdcCurr, IBSQL,
  gd_security, gd_common_functions, StDecMth;

type
  TNameSelector = (nsName, nsCentName);

var
  NumberConvert: TNumberConvert;
  FCurrCachedKey: TID;
  FCurrCachedDBID: Integer;
  FCurrCachedTime: DWORD;
  CacheName, CacheCentName,
  CacheShortName, CacheShortCentName,
  CacheName_0, CacheName_1,
  CacheCentName_0, CacheCentName_1,
  CacheSign, CacheISO, CacheCode: String;
  CacheDecDigits: Integer;

function UpdateCache(const AnID: TID; const AForce: Boolean = False): Boolean;
var
  q: TIBSQL;
begin
  Assert(Assigned(IBLogin));

  if AForce or (AnID <> FCurrCachedKey)
    or (FCurrCachedDBID <> IBLogin.DBID)
    or (GetTickCount - FCurrCachedTime > CacheFlushInterval) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT * FROM gd_curr WHERE id = :ID';
      SetTID(q.ParamByName('ID'), AnID);
      q.ExecQuery;
      if not q.EOF then
      begin
        CacheCentName := AnsiLowerCase(q.FieldByName('fullcentname').AsString);
        CacheName := AnsiLowerCase(q.FieldByName('name').AsString);
        CacheCentName_0 := AnsiLowerCase(q.FieldByName('centname_0').AsString);
        CacheCentName_1 := AnsiLowerCase(q.FieldByName('centname_1').AsString);
        CacheName_0 := AnsiLowerCase(q.FieldByName('name_0').AsString);
        CacheName_1 := AnsiLowerCase(q.FieldByName('name_1').AsString);
        CacheShortName := AnsiLowerCase(q.FieldByName('shortname').AsString);
        CacheShortCentName := AnsiLowerCase(q.FieldByName('shortcentname').AsString);
        CacheSign := q.FieldByName('sign').AsString;
        CacheISO := q.FieldByName('ISO').AsString;
        CacheCode := q.FieldByName('code').AsString;
        CacheDecDigits := q.FieldByName('decdigits').AsInteger;

        FCurrCachedKey := AnID;
      end else
        FCurrCachedKey := -1;

      FCurrCachedDBID := IBLogin.DBID;
      FCurrCachedTime := GetTickCount;
    finally
      q.Free;
    end;
  end;

  Result := FCurrCachedKey <> -1;
end;

function GetNumeral(const AFormat: String; AValue: Double; const ARounding: Double;
  const AFracBase: Integer; const ACase: Integer; const AParts: Integer;
  const ANames: String): String;

  function PeekNextChar(const S: String; I: Integer): Char;
  begin
    if I < Length(S) then
      Result := S[I + 1]
    else
      Result := #0;
  end;

  function PeekFormat(const S: String; I: Integer): String;
  begin
    Result := '';
    while (I <= Length(S)) and (S[I] in ['#', ',', '0', '.', ';', '+', 'E']) do
    begin
      Result := Result + S[I];
      Inc(I);
    end;
  end;

  function ConvertNumber(const AFormat: String; const AValue: TStDecimal;
    const ANominative, AGenitive: String; const AHideWhenZero: Boolean;
    const ADecimalSeparator: String; const AThousandSeparator: String;
    var Idx: Integer): String;
  var
    Fmt: String;
    RepSeparators: Boolean;
  begin
    RepSeparators := False;
    if PeekNextChar(AFormat, Idx + 1) = 'G' then
    begin
      if AValue.IsZero and AHideWhenZero then
        Result := ''
      else begin
        Result := AValue.AsString;
        RepSeparators := True;
      end;
      Inc(Idx, 3);
    end else
    begin
      Fmt := PeekFormat(AFormat, Idx + 2);
      if Fmt > '' then
      begin
        if AValue.IsZero and AHideWhenZero then
          Result := ''
        else begin
          Result := FormatFloat(Fmt, AValue.AsFloat);
          RepSeparators := True;
        end;
        Inc(Idx, Length(Fmt) + 2);
      end else
      begin
        if AValue.IsZero and AHideWhenZero then
          Result := ''
        else begin
          NumberConvert.Value := AValue.AsFloat;
          NumberConvert.Gender := TNumberConvert.GenderOf(ANominative, AGenitive);
          NumberConvert.Precision := AValue.DecDigits;
          Result := NumberConvert.Numeral;
        end;
        Inc(Idx, 2);
      end;
    end;

    if RepSeparators then
    begin
      if ADecimalSeparator > '' then
        Result := StringReplace(Result, DecimalSeparator, ADecimalSeparator, []);
      if AThousandSeparator > '' then
        Result := StringReplace(Result, ThousandSeparator, AThousandSeparator, [rfReplaceAll]);
    end;
  end;

var
  I: Integer;
  SL: TStringList;
  HideWhole, HideFrac: Boolean;
  S: String;
  SValue, SRounding, W, F, Fr, S10: TStDecimal;
begin
  if NumberConvert = nil then
  begin
    NumberConvert := TNumberConvert.Create(nil);
    NumberConvert.Language := lRussian;
  end;

  Result := '';

  SValue := TStDecimal.Create;
  SRounding := TStDecimal.Create;
  W := TStDecimal.Create;
  F := TStDecimal.Create;
  Fr := TStDecimal.Create;
  S10 := TStDecimal.Create;
  SL := TStringList.Create;
  try
    SValue.AssignFromFloat(AValue);
    SRounding.AssignFromFloat(ARounding);

    SL.CommaText := ANames;

    while SL.Count < 14 do
      SL.Add('');

    {
      Whole Nominative,     0
      Whole Genitive,       1
      Whole Plural,         2
      Whole Short,          3
      Frac Nominative,      4
      Frac Genitive,        5
      Frac Plural,          6
      Frac Short,           7
      Substitute,           8
      Decimal sign,         9
      Thousand separator    10
      Currency sign         11
      Currency ISO          12
      Currency Code         13
    }

    if SRounding.IsPositive then
    begin
      SValue.Divide(SRounding);
      SValue.Round(rmNormal, 0);
      SValue.Multiply(SRounding);
    end;

    W.Assign(SValue);
    W.Round(rmTrunc, 0);

    Fr.Assign(SValue);
    Fr.Subtract(W);

    S10.AssignFromInt(10);
    for I := 1 to AFracBase do
      Fr.Multiply(S10);

    F.Assign(Fr);
    F.Round(rmNormal, 0);

    if (AValue = 0) and ((partSubstWhenZero and AParts) <> 0) then
      Result := SL[8]
    else begin
      HideWhole := W.IsZero and ((partHideWholeWhenZero and AParts) <> 0);
      HideFrac := Fr.IsZero and ((partHideFracWhenZero and AParts) <> 0);
      I := 1;
      while I <= Length(AFormat) do
      begin
        if AFormat[I] = '@' then
        begin
          case PeekNextChar(AFormat, I) of
            'N': Result := Result + ConvertNumber(AFormat, SValue, SL[0], SL[1], False, SL[9], SL[10], I);
            'W': Result := Result + ConvertNumber(AFormat, W, SL[0], SL[1], HideWhole, SL[9], SL[10], I);
            'D':
            begin
              S := ConvertNumber(AFormat, Fr, SL[4], SL[5], HideFrac, SL[9], SL[10], I);
              if AFracBase > 0 then
                Result := Result + S;
            end;
            'F':
            begin
              if not HideWhole then
              begin
                if (W._mod(100) >= 20) or (W._mod(100) <= 10) then
                begin
                  case W._mod(10) of
                    1: Result := Result + SL[0];
                    2, 3, 4: Result := Result + SL[1];
                  else
                    Result := Result + SL[2];
                  end
                end else
                  Result := Result + SL[2];
              end;
              Inc(I, 2);
            end;
            'B':
            begin
              if not HideWhole then
                Result := Result + SL[3];
              Inc(I, 2);
            end;
            'C':
            begin
              if (AFracBase > 0) and (not HideFrac) then
              begin
                if (F._mod(100) >= 20) or (F._mod(100) <= 10) then
                begin
                  case F._mod(10) of
                    1: Result := Result + SL[4];
                    2, 3, 4: Result := Result + SL[5];
                  else
                    Result := Result + SL[6];
                  end
                end else
                  Result := Result + SL[6];
              end;
              Inc(I, 2);
            end;
            'K':
            begin
              if (AFracBase > 0) and (not HideFrac) then
                Result := Result + SL[7];
              Inc(I, 2);
            end;
          else
            Result := Result + AFormat[I];
            Inc(I);
          end;
        end
        else if AFormat[I] = '\' then
        begin
          if I < Length(AFormat) then
            Result := Result + AFormat[I + 1];
          Inc(I, 2);
        end else
        begin
          Result := Result + AFormat[I];
          Inc(I);
        end;
      end;
      if (AFracBase= 0) or HideWhole or HideFrac then
        Result := Trim(Result);
    end;

    case ACase of
      caseName: Result := NameCase(Result);
      caseLower: Result := AnsiLowerCase(Result);
      caseUpper: Result := AnsiUpperCase(Result);
    end;

    Result := StringReplace(Result, '@S', SL[11], [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '@I', SL[12], [rfReplaceAll, rfIgnoreCase]);
    Result := StringReplace(Result, '@O', SL[13], [rfReplaceAll, rfIgnoreCase]);
  finally
    SValue.Free;
    SRounding.Free;
    W.Free;
    F.Free;
    Fr.Free;
    S10.Free;
    SL.Free;
  end;
end;

function GetCurrNumeral(const ACurrKey: TID; const AFormat: String; AValue: Double; const ARounding: Double;
  const ACase: Integer; const AParts: Integer; const ASubst, ADecimalSeparator, AThousandSeparator: String): String;
begin
  if not UpdateCache(ACurrKey) then
    raise Exception.Create('Invalid currency key');

  Result := GetNumeral(AFormat, AValue, ARounding, CacheDecDigits, ACase, AParts,
    '"' + CacheName + '","' + CacheName_1 + '","' + CacheName_0 + '","' + CacheShortName + '","' +
    CacheCentName + '","' + CacheCentName_1 + '","' + CacheCentName_0 + '","' + CacheShortCentName + '","' +
    ASubst + '","' + ADecimalSeparator + '","' + AThousandSeparator + '","' + CacheSign + '","' +
    CacheISO + '","' + CacheCode + '"');
end;

function GetRubbleWord(const Value: Double): String;
var
  Num: Int64;
begin
  Num := Trunc(Abs(Value));

  if (Num mod 100 >= 20) or (Num mod 100 <= 10) then
    case Num mod 10 of
      1: Result := 'рубль';
      2, 3, 4: Result := 'рубля';
    else
      Result := 'рублей';
    end
  else
    Result := 'рублей';
end;

function GetKopWord(const Value: Double): String;
var
  Num: Int64;
begin
  Num := Trunc(Abs(Value));

  if (Num mod 100 >= 20) or (Num mod 100 <= 10) then
    case Num mod 10 of
      1: Result := 'копейка';
      2, 3, 4: Result := 'копейки';
    else
      Result := 'копеек';
    end
  else
    Result := 'копеек';
end;

function GetSumStr(const AValue: Double; const APrecision: Byte = 0): String;
begin
  if NumberConvert = nil then
  begin
    NumberConvert := TNumberConvert.Create(nil);
    NumberConvert.Language := lRussian;
  end;

  NumberConvert.Value := AValue;
  NumberConvert.Precision := APrecision;
  if (APrecision > 0)  then
    NumberConvert.Gender := gFemale
  else
    NumberConvert.Gender := gMale;

  Result := NumberConvert.Numeral;
end;

function GetSumStr2(const AValue: Double; const AGender: TGender): String;
begin
  if NumberConvert = nil then
  begin
    NumberConvert := TNumberConvert.Create(nil);
    NumberConvert.Language := lRussian;
  end;

  NumberConvert.Value := AValue;
  NumberConvert.Gender := AGender;
  Result := NumberConvert.Numeral;
end;

function GetSumCurr(const ACurrKey: TID; const AValue: Double; const ACentAsString: Boolean;
  const AnIncludeCent: Boolean): String;
{
  function GetName(const Num: Int64; const Name: TNameSelector): String;
  var
    gdcCurr: TgdcCurr;
  begin
    repeat
      if (Num mod 100 >= 20) or (Num mod 100 <= 10) then
      begin
        case Num mod 10 of
          1:
             if Name = nsCentName then
               Result := CacheCentName
             else
               Result := CacheName;
          2, 3, 4:
             if Name = nsCentName then
               Result := CacheCentName_1
             else
               Result := CacheName_1
        else
          begin
           if Name = nsCentName then
             Result := CacheCentName_0
           else
             Result := CacheName_0
          end;
        end
      end else
      begin
        if Name = nsCentName then
          Result := CacheCentName_0
        else
          Result := CacheName_0
      end;

      if Result > '' then
        break;

      if (Screen.ActiveCustomForm = nil) or (not Screen.ActiveCustomForm.Visible) then
        break;

      MessageBox(0,
        PChar('Укажите наименование целых и разменных единиц валюты ' + CacheName + '.'),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

      gdcCurr := TgdcCurr.Create(nil);
      try
        gdcCurr.SubSet := 'ByID';
        gdcCurr.ParamByName('ID').AsInteger := FCurrCachedKey;
        gdcCurr.Open;
        if gdcCurr.EOF or (not gdcCurr.EditDialog)
          or (not UpdateCache(FCurrCachedKey, True)) then
        begin
          break;
        end;  
      finally
        gdcCurr.Free;
      end;
    until False;
  end;

var
  Whole, Cent: Int64;
  S: String;
}
begin
  if UpdateCache(ACurrKey) then
  begin
    if (AnIncludeCent or (Frac(AValue) <> 0)) and ACentAsString then
      Result := GetCurrNumeral(ACurrKey, '@W @F @D @C', AValue, 0.01)
    else if (AnIncludeCent or (Frac(AValue) <> 0)) and (not ACentAsString) then
      Result := GetCurrNumeral(ACurrKey, '@W @F @D00 @C', AValue, 0.01)
    else
      Result := GetCurrNumeral(ACurrKey, '@W @F', AValue, 0.01)

    {
    Whole := Trunc(Abs(AValue));
    Cent := Round(Frac(Abs(AValue))  * 100);

    Result := GetSumStr2(Whole, TNumberConvert.GenderOf(CacheName, CacheName_1)) + ' ' + GetName(Whole, nsName);

    if (Cent <> 0) or AnIncludeCent then
    begin
      if ACentAsString then
        S := GetSumStr2(Cent, TNumberConvert.GenderOf(CacheCentName, CacheCentName_1))
      else
      begin
        S := IntToStr(Cent);
        if Length(S) = 1 then
          S := '0' + S;
      end;
      Result := Result + ' ' + S + ' ' + GetName(Cent, nsCentName);
    end;

    Result := NameCase(Result);
    }
  end else
    Result := '';
end;

function GetRubSumStr(const AValue: Double): String;
begin
  //Result := NameCase(GetSumStr2(AValue, gMale) + ' ' + GetRubbleWord(AValue));
  Result := GetCurrNumeral(200010, '@W @F', AValue, 0.01);
end;

function GetFullRubSumStr(const AValue: Double): String;
{var
  N: Int64;}
begin
  {Result := GetRubSumStr(AValue);
  N := Round(Frac(Abs(AValue)) * 100);
  if N <> 0 then
    Result := Result + ' ' + GetSumStr2(N, gFemale) + ' ' + GetKopWord(N);}
  Result := GetCurrNumeral(200010, '@W @F @D @C', AValue, 0.01);
end;

function MulDiv(const ANumber: Double; const ANumerator: Double; const ADenominator: Double;
  const ARoundMethod: Integer; const ADecPlaces: Integer): Double;
var
  Number, Numerator, Denominator: TStDecimal;
begin
  Number := TStDecimal.Create;
  Numerator := TStDecimal.Create;
  Denominator := TStDecimal.Create;
  try
    Number.AssignFromFloat(ANumber);
    Numerator.AssignFromFloat(ANumerator);
    Denominator.AssignFromFloat(ADenominator);
    if not Numerator.IsOne then
      Number.Multiply(Numerator);
    if not Denominator.IsOne then
      Number.Divide(Denominator);
    if (ARoundMethod > 0) and (ARoundMethod < 5) then
      Number.Round(TStRoundMethod(ARoundMethod - 1), ADecPlaces);
    Result := Number.AsFloat;
  finally
    Number.Free;
    Numerator.Free;
    Denominator.Free;
  end;
end;

initialization
  NumberConvert := nil;
  FCurrCachedKey := -1;

finalization
  FreeAndNil(NumberConvert);
end.