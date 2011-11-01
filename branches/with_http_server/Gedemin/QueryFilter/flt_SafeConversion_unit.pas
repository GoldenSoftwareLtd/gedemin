
unit flt_SafeConversion_unit;

interface

function SafeDateTimeToStr(const ADateTime: TDateTime): String;
function SafeStrToDateTime(const S: String): TDateTime;
function SafeFloatToStr(const AFloat: Double): String;
function SafeStrToFloat(const S: String): Double;
function ConvertSysChars(const S: String): String;
function RestoreSysChars(const S: String): String;

implementation

uses
  SysUtils;

function SafeDateTimeToStr(const ADateTime: TDateTime): String;
begin
  Result := FormatDateTime('dd"."mm"."yyyy hh":"nn":"ss', ADateTime);
end;

function SafeStrToDateTime(const S: String): TDateTime;
begin
  Result :=
    EncodeDate(
      StrToIntDef(Copy(S, 7, 4), 1980),
      StrToIntDef(Copy(S, 4, 2), 1),
      StrToIntDef(Copy(S, 1, 2), 1)) +
    EncodeTime(
      StrToIntDef(Copy(S, 12, 2), 0),
      StrToIntDef(Copy(S, 15, 2), 0),
      StrToIntDef(Copy(S, 18, 2), 0),
      0);
end;

function SafeFloatToStr(const AFloat: Double): String;
var
  DSep: Char;
begin
  DSep := DecimalSeparator;
  try
    DecimalSeparator := '.';
    Result := FloatToStrF(AFloat, ffGeneral, 15, 4);
  finally
    DecimalSeparator := DSep;
  end;
end;

function SafeStrToFloat(const S: String): Double;
var
  DSep: Char;
begin
  DSep := DecimalSeparator;
  try
    DecimalSeparator := '.';
    try
      Result := StrToFloat(S);
    except
      Result := 0;
    end;
  finally
    DecimalSeparator := DSep;
  end;
end;

function ConvertSysChars(const S: String): String;
begin
  Result := StringReplace(S,      #13, '#13', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '#10', [rfReplaceAll]);
  Result := StringReplace(Result, #09, '#09', [rfReplaceAll]);
end;

function RestoreSysChars(const S: String): String;
begin
  Result := StringReplace(S,      '#13', #13, [rfReplaceAll]);
  Result := StringReplace(Result, '#10', #10, [rfReplaceAll]);
  Result := StringReplace(Result, '#09', #09, [rfReplaceAll]);
end;

end.