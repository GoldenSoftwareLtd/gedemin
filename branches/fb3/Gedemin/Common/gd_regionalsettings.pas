
unit gd_regionalsettings;

interface

uses
  Windows, SysUtils;

const
  // Константы хранилища
  st_rs_RegionalSettingsPath    = 'RegionalSettings';
  st_rs_UseSystemSettings       = 'UseSystemSettings';
  st_rs_CurrencyString          = 'CurrencyString';
  st_rs_CurrencyFormat          = 'CurrencyFormat';
  st_rs_NegCurrFormat           = 'NegCurrFormat';
  st_rs_ThousandSeparator       = 'ThousandSeparator';
  st_rs_DecimalSeparator        = 'DecimalSeparator';
  st_rs_CurrencyDecimals        = 'CurrencyDecimals';
  st_rs_DateSeparator           = 'DateSeparator';
  st_rs_ShortDateFormat         = 'ShortDateFormat';
  st_rs_LongDateFormat          = 'LongDateFormat';
  st_rs_TimeSeparator           = 'TimeSeparator';
  st_rs_TimeAMString            = 'TimeAMString';
  st_rs_TimePMString            = 'TimePMString';
  st_rs_ShortTimeFormat         = 'ShortTimeFormat';
  st_rs_ListSeparator           = 'ListSeparator';

  st_rs_NumberDecimals          = 'NumberDecimals';
  st_rs_NumberGroupCount        = 'NumberGroupCount';
  st_rs_NegativeChar            = 'NegativeChar';
  st_rs_NegativeFormat          = 'NegativeFormat_I';
  st_rs_LeadingZero             = 'LeadingZero_I';
  st_rs_CurrSeparator           = 'CurrSeparator';
  st_rs_CurrThousandSeparator   = 'CurrThousandSeparator';
  st_rs_CurrGroup               = 'CurrGroup';

  //Константы форматов региональных установок

  //Формат валюты
  CurrencyFormatCount = 4;
  CurrencyFormatConstants: array[0..CurrencyFormatCount - 1] of String = (
    '$1.1',
    '1.1$',
    '$ 1.1',
    '1.1 $');

  //Формат отрицательной валюты
  NegCurrencyFormatCount = 16;
  NegCurrencyFormatConstants: array[0..NegCurrencyFormatCount - 1] of String = (
    '($1.1)',
    '-$1.1',
    '$-1.1',
    '$1.1-',
    '(1.1$)',
    '-1.1$',
    '1.1-$',
    '1.1$-',
    '-1.1 $',
    '-$ 1.1',
    '1.1 $-',
    '$ 1.1-',
    '$ -1.1',
    '1.1- $',
    '($ 1.1)',
    '(1.1 $)');

  Def_NumberDecimals: Integer = 2;
  Def_NumberGroupCount: Integer = 3;
  Def_CurrGroup: Integer = 3;
  Def_NegativeChar: Char = ' ';
  Def_CurrSeparator: Char = ' ';
  Def_CurrThousandSeparator: Char = ' ';

var
  NumberDecimals: Integer;
  NumberGroupCount: Integer;
  NegativeChar: Char;
  CurrSeparator: Char;
  CurrThousandSeparator: Char;
  NegativeFormat: Integer;
  LeadingZero: Integer;
  CurrGroup: Integer;

procedure LoadSystemLocalSettingsIntoDelphiVars;

implementation

//Загрузка системных настроек в переменные Delphi
procedure LoadSystemLocalSettingsIntoDelphiVars;

  function GetLocaleSetting(const LocaleParam: LCTYPE): String;
  var
    Buff: PChar;
    Size: Integer;
  begin
    Size := GetLocaleInfo(LOCALE_USER_DEFAULT, LocaleParam, nil, 0);
    GetMem(Buff, Size);
    try
      GetLocaleInfo(LOCALE_USER_DEFAULT, LocaleParam, Buff, Size);
      Result := StrPas(Buff);
    finally
      FreeMem(Buff);
    end;
  end;

begin
  CurrencyString := GetLocaleSetting(LOCALE_SCURRENCY);
  CurrencyFormat := StrToIntDef(GetLocaleSetting(LOCALE_ICURRENCY), 1);
  NegCurrFormat := StrToIntDef(GetLocaleSetting(LOCALE_INEGCURR), 5);
  if GetLocaleSetting(LOCALE_STHOUSAND) > '' then
    ThousandSeparator := GetLocaleSetting(LOCALE_STHOUSAND)[1];
  if GetLocaleSetting(LOCALE_SDECIMAL) > '' then
    DecimalSeparator := GetLocaleSetting(LOCALE_SDECIMAL)[1];
  CurrencyDecimals := StrToIntDef(GetLocaleSetting(LOCALE_ICURRDIGITS), 2);
  if GetLocaleSetting(LOCALE_SDATE) > '' then
    DateSeparator := GetLocaleSetting(LOCALE_SDATE)[1];
  ShortDateFormat := GetLocaleSetting(LOCALE_SSHORTDATE);
  LongDateFormat := GetLocaleSetting(LOCALE_SLONGDATE);
  if GetLocaleSetting(LOCALE_STIME) > '' then
    TimeSeparator := GetLocaleSetting(LOCALE_STIME)[1];
  TimeAMString := GetLocaleSetting(LOCALE_S1159);
  TimePMString := GetLocaleSetting(LOCALE_S2359);
  ShortTimeFormat := GetLocaleSetting(LOCALE_STIMEFORMAT);
  if GetLocaleSetting(LOCALE_SLIST) > '' then
    ListSeparator := GetLocaleSetting(LOCALE_SLIST)[1];

  NumberDecimals := Def_NumberDecimals;
  NumberGroupCount := Def_NumberGroupCount;
  CurrGroup := Def_CurrGroup;

  NegativeChar := Def_NegativeChar;
  CurrSeparator := Def_CurrSeparator;
  CurrThousandSeparator := Def_CurrThousandSeparator;
end;

end.
