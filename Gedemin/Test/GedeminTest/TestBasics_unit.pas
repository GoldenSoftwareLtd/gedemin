
unit TestBasics_unit;

interface

uses
  TestFrameWork;

type
  TBasicsTest = class(TTestCase)
  published
    procedure TestBasics;
    procedure TestCmdLine;
    procedure TestCommonFunctions;
    procedure TestHugeIntSet;
    procedure TestNotifierThread;
    procedure TestParseOrigin;
    procedure TestEncryption;
    procedure TestEncryptionMaxLength;
    procedure TestEncryptionWrongPassword;
    procedure TestFastReportFunctions;
    procedure TestConvertFunctions;
    procedure TestMulDiv;
    procedure TestStDecMath;
  end;

implementation

uses
  SysUtils, gd_CmdLineParams_unit, gd_common_functions, gsHugeIntSet,
  gdNotifierThread_unit, gd_encryption, fs_iinterpreter, rp_FR4Functions,
  gd_convert, StDecMth;

type
  Tgd_CmdLineParamsCrack = class(Tgd_CmdLineParams)
  end;

{ TBasicsTest }

procedure TBasicsTest.TestBasics;
begin
  Check(2 = 2, 'ok');
end;

procedure TBasicsTest.TestCmdLine;
var
  C: Tgd_CmdLineParams;
begin
  C := Tgd_CmdLineParams.Create;
  try
    Tgd_CmdLineParamsCrack(C).ReadCmdLine('');
    Check(not C.TraceSQL);
    Check(C.UILanguage = '');
    Check(not C.LangSave);
    Check(C.LangFile = '');
    Check(not C.NoGarbageCollect);
    Check(not C.NoSplash);
    Check(not C.QuietMode);
    Check(not C.NoCache);
    Check(not C.ClearDBID);
    Check(not C.Unmethod);
    Check(not C.Unevent);
    Check(C.UserPassword = '');
    Check(C.UserName = '');
    Check(C.ServerName = '');
    Check(not C.UseLog);
    Check(not C.SaveLogToFile);
    Check(C.LoadSettingPath = '');
    Check(C.LoadSettingFileName = '');
    Check(not C.Embedding);
    Check(C.RestoreServer = '');
    Check(C.RestoreBKFile = '');
    Check(C.RestoreDBFile = '');
    Check(C.RestoreUser = '');
    Check(C.RestorePassword = '');
    Check(C.RestorePageSize = 0);
    Check(C.RestoreBufferSize = 0);
    Check(C.Warning = '');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/sn "aaa:bbb ccc"');
    Check(C.ServerName = 'aaa:bbb ccc');
    Check(C.Warning = '');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('-sn "aaa:bbb ccc"');
    Check(C.ServerName = 'aaa:bbb ccc');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/trace');
    Check(C.TraceSQL);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/lang:by');
    Check(C.UILanguage = 'by');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/langsave');
    Check(C.LangSave);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/langfile:c:\test.xml');
    Check(C.LangFile = 'c:\test.xml');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('"-langfile:c:\test test\test.xml"');
    Check(C.LangFile = 'c:\test test\test.xml');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/ngc');
    Check(C.NoGarbageCollect);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/ns');
    Check(C.NoSplash);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/q');
    Check(C.QuietMode);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/nc');
    Check(C.NoCache);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/rd');
    Check(C.ClearDBID);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/unmethod');
    Check(C.Unmethod);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/unevent');
    Check(C.Unevent);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('"/password" "xyz d"');
    Check(C.UserPassword = 'xyz d');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('"/user" "xyz d"');
    Check(C.UserName = 'xyz d');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/log');
    Check(C.UseLog);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/logfile');
    Check(C.UseLog);
    Check(C.SaveLogToFile);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/sp "aaa:bbb ccc"');
    Check(C.LoadSettingPath = 'aaa:bbb ccc');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('-settingpath "aaa:bbb ccc"');
    Check(C.LoadSettingPath = 'aaa:bbb ccc');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/sfn "aaa:bbb ccc"');
    Check(C.LoadSettingFileName = 'aaa:bbb ccc');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('-settingfilename "aaa:bbb ccc"');
    Check(C.LoadSettingFileName = 'aaa:bbb ccc');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/r "localhost/3052" c:\test\test.bk c:\test\test.fdb user password 8192 8192 -embedding');
    Check(C.Embedding);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/r "localhost/3052" c:\test\test.bk c:\test\test.fdb user password 8192 8192');
    Check(C.RestoreServer = 'localhost/3052');
    Check(C.RestoreBKFile = 'c:\test\test.bk');
    Check(C.RestoreDBFile = 'c:\test\test.fdb');
    Check(C.RestoreUser = 'user');
    Check(C.RestorePassword = 'password');
    Check(C.RestorePageSize = 8192);
    Check(C.RestoreBufferSize = 8192);

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/r "localhost/3052" c:\test\test.bk c:\test\test.fdb user password 8192');
    Check(C.Warning > '');

    Tgd_CmdLineParamsCrack(C).ReadCmdLine('/unknown');
    Check(C.Warning > '');
  finally
    C.Free;
  end;
end;

procedure TBasicsTest.TestCommonFunctions;
var
  Server, FileName: String;
  Port: Integer;
begin
  ParseDatabaseName('', Server, Port, FileName);
  Check(Server = '');
  Check(FileName = '');
  Check(Port = 0);

  ParseDatabaseName('c:\test\test.fdb', Server, Port, FileName);
  Check(Server = '');
  Check(Port = 0);
  Check(FileName = 'c:\test\test.fdb');

  ParseDatabaseName('host:alias', Server, Port, FileName);
  Check(Server = 'host');
  Check(Port = 0);
  Check(FileName = 'alias');

  ParseDatabaseName('host:c:\test\test.fdb', Server, Port, FileName);
  Check(Server = 'host');
  Check(Port = 0);
  Check(FileName = 'c:\test\test.fdb');

  ParseDatabaseName('server/3030:c:\test\test.fdb', Server, Port, FileName);
  Check(Server = 'server/3030');
  Check(Port = 3030);
  Check(FileName = 'c:\test\test.fdb');

  try
    ParseDatabaseName('server/d:c:\test\test.fdb', Server, Port, FileName);
    Check(False);
  except
  end;

  try
    ParseDatabaseName('server/-2:c:\test\test.fdb', Server, Port, FileName);
    Check(False);
  except
  end;

  try
    ParseDatabaseName('server/65536:c:\test\test.fdb', Server, Port, FileName);
    Check(False);
  except
  end;

  try
    ParseDatabaseName('server:', Server, Port, FileName);
    Check(False);
  except
  end;

  try
    ParseDatabaseName('server/:c', Server, Port, FileName);
    Check(False);
  except
  end;
end;

procedure TBasicsTest.TestHugeIntSet;
const
  LoopCount = 10000000;
var
  H, H2: TgsHugeIntSet;
  I, V: Integer;
begin
  H2 := TgsHugeIntSet.Create;;
  try
    H := TgsHugeIntSet.Create;
    try
      // обязательно проверяем граничные значения
      H.Include(0);
      H.Include(High(Integer));
      Check(H.Has(0));
      Check(H.Has(High(Integer)));
      H.Exclude(0);
      H.Exclude(High(Integer));
      Check(not H.Has(0));
      Check(not H.Has(High(Integer)));

      // выборочный тест
      for I := 1 to LoopCount do
      begin
        V := Random(High(Integer)) + Random(2);
        H.Include(V);
        Check(H.Has(V));
      end;

      for I := 1 to LoopCount do
      begin
        V := Random(High(Integer)) + Random(2);
        H.Exclude(V);
        Check(not H.Has(V));
      end;

      // проверяем область определения
      StartExpectingException(EgsHugeIntSet);
      H.Has(-1);
      StopExpectingException;
    finally
      H.Free;
    end;
  finally
    H2.Free;
  end;
end;

procedure TBasicsTest.TestNotifierThread;
begin
  if gdNotifierThread <> nil then
  begin
    gdNotifierThread.Add('Это сообщение с таймером и будет показываться 60 сек... <tmr>', 0, 60000);
    gdNotifierThread.Add('Это сообщение будет показываться 30 сек...', 0, 30000);
    Check(gdNotifierThread.Suspended = False);
  end;
end;

procedure TBasicsTest.TestParseOrigin;
var
  RN, FN: String;
begin
  Check(ParseFieldOrigin('', RN, FN) = False);
  Check((RN = '') and (FN = ''));
  Check(ParseFieldOrigin('gd_contact.name', RN, FN));
  Check((RN = 'gd_contact') and (FN = 'name'));
  Check(ParseFieldOrigin('name', RN, FN));
  Check((RN = '') and (FN = 'name'));
  Check(ParseFieldOrigin('"gd_contact"."name"', RN, FN));
  Check((RN = 'gd_contact') and (FN = 'name'));
  Check(ParseFieldOrigin('"name"', RN, FN));
  Check((RN = '') and (FN = 'name'));
  Check(not ParseFieldOrigin('"gd_contact".', RN, FN));
  Check((RN = 'gd_contact') and (FN = ''));

  Check(ParseFieldOrigin(' ', RN, FN) = True);
  Check((RN = '') and (FN = ' '));
  Check(ParseFieldOrigin('gd_contact . name', RN, FN));
  Check((RN = 'gd_contact ') and (FN = ' name'));
  Check(ParseFieldOrigin(' name', RN, FN));
  Check((RN = '') and (FN = ' name'));
  Check(ParseFieldOrigin(' "gd_contact"."name"', RN, FN));
  Check((RN = ' "gd_contact"') and (FN = '"name"'));
  Check(ParseFieldOrigin(' "name" ', RN, FN));
  Check((RN = '') and (FN = ' "name" '));
  Check(ParseFieldOrigin(' "gd_contact". ', RN, FN));
  Check((RN = ' "gd_contact"') and (FN = ' '));
end;

procedure TBasicsTest.TestEncryption;
var
  I: Integer;
  S: AnsiString;
begin
  S := '';
  Check(S = DecryptString(EncryptString(S, 'PAssWord'), 'PAssWord'));

  S := 'A';
  Check(S = DecryptString(EncryptString(S, 'PAssWord'), 'PAssWord'));

  SetLength(S, 124);
  for I := 1 to 124 do
    S[I] := Chr(Random($FF));
  Check(S = DecryptString(EncryptString(S, 'PAssWord'), 'PAssWord'));

  S := EncryptString(S, 'PAssWord');
  if S[1] = #01 then
    S[1] := #07
  else
    S[1] := #01;

  StartExpectingException(Exception);
  DecryptString(S, 'PAssWord');
  StopExpectingException;
end;

procedure TBasicsTest.TestEncryptionMaxLength;
var
  S: AnsiString;
begin
  SetLength(S, 125);
  StartExpectingException(Exception);
  EncryptString(S, 'PAssWord');
  StopExpectingException;
end;

procedure TBasicsTest.TestEncryptionWrongPassword;
begin
  StartExpectingException(Exception);
  DecryptString(EncryptString('str', 'A'), 'B');
  StopExpectingException;
end;

procedure TBasicsTest.TestFastReportFunctions;
var
  Scr: TfsScript;
  F: TFR4Functions;
begin
  Scr := TfsScript.Create(nil);
  F := TFR4Functions.Create(Scr);
  try
    Check(F.GetSumCurr(200010, 0, 1, True) = 'Ноль белорусских рублей ноль копеек');
    Check(F.GetSumCurr(200010, 0, 0, True) = 'Ноль белорусских рублей 00 копеек');

    Check(F.GetSumCurr(200010, 1.01, 1, True) = 'Один белорусский рубль одна копейка');
    Check(F.GetSumCurr(200010, 1.01, 0, True) = 'Один белорусский рубль 01 копейка');

    Check(F.GetSumCurr(200010, 2.02, 1, True) = 'Два белорусских рубля две копейки');
    Check(F.GetSumCurr(200010, 2.02, 0, True) = 'Два белорусских рубля 02 копейки');

    Check(F.GetSumCurr(200010, 14.96, 1, True) = 'Четырнадцать белорусских рублей девяносто шесть копеек');
    Check(F.GetSumCurr(200010, 14.96, 0, True) = 'Четырнадцать белорусских рублей 96 копеек');

    Check(F.GetSumCurr(200010, 9783542912.86, 1, True) = 'Девять миллиардов семьсот восемьдесят три миллиона пятьсот сорок две тысячи девятьсот двенадцать белорусских рублей восемьдесят шесть копеек');
    Check(F.GetSumCurr(200010, 9783542912.86, 0, True) = 'Девять миллиардов семьсот восемьдесят три миллиона пятьсот сорок две тысячи девятьсот двенадцать белорусских рублей 86 копеек');

    Check(F.GetSumCurr(200010, 26401, 1, False) = 'Двадцать шесть тысяч четыреста один белорусский рубль');
    Check(F.GetSumCurr(200010, 26401, 0, False) = 'Двадцать шесть тысяч четыреста один белорусский рубль');

    Check(F.GetSumCurr(999, 26401, 0, False) = '');

    Check(F.GetRubSumStr(2484.97) = 'Две тысячи четыреста восемьдесят четыре белорусских рубля');
  finally
    F.Free;
    Scr.Free;
  end;
end;

procedure TBasicsTest.TestConvertFunctions;
begin
  Check(GetNumeral('@W @F @D0 @K', 14.96, 0.01, 0, caseName, partHideFracWhenZero, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Четырнадцать тонн');
  Check(GetNumeral('@W @F @D @K', 14.96, 0.01, 0, caseName, partHideFracWhenZero, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Четырнадцать тонн');
  Check(GetNumeral('@W @F @D @C', 14.96, 0.01, 0, caseName, partHideFracWhenZero, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Четырнадцать тонн');

  Check(GetNumeral('@W#,##0.### @B @D0.#### @K', 0, 0, 3, 0, caseName, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '0 т 0 кг');
  Check(GetNumeral('@W0 @F @D0 @C', 0, 0, 3, 0, caseName, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '0 тонн 0 килограмм');
  Check(GetNumeral('@W @F @D @C', 0, 0, 3, 0, caseName, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Ноль тонн ноль килограмм');
  Check(GetNumeral('@W @F @D @C', 0, 0, 3, caseName, partSubstWhenZero, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '--');
  Check(GetNumeral('@W @F @D @C', 0, 0, 3, caseName, partHideFracWhenZero + partHideWholeWhenZero, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '');
  Check(GetNumeral('@W @F @D0 @K', 0, 0, 3, caseName, partHideWholeWhenZero, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '0 кг');
  Check(GetNumeral('@W @F @D0 @K', 0, 0, 3, caseName, partHideFracWhenZero, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Ноль тонн');

  Check(GetNumeral('@N#,##0.###', 5687.3694, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '5 687.369');
  Check(GetNumeral('@N#,##0.### @B', 5687.3694, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '5 687.369 т');
  Check(GetNumeral('@W#,##0.### @B @D000 @K', 5687.3694, 0.001, 3, 0, caseName, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '5 687 т 369 кг');
  Check(GetNumeral('@W#,##0.### @B @D#.## @K', 5687.3694, 0, 3, 0, caseName, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '5 687 т 369.4 кг');
  Check(GetNumeral('@W#,##0.### @B @D#.#### @K', 5687.36944, 0, 3, 0, caseName, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = '5 687 т 369.44 кг');
  Check(GetNumeral('@W @F', 5687.3694, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Пять тысяч шестьсот восемьдесят семь тонн');
  Check(GetNumeral('@W @F @D @C', 5687.3694, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Пять тысяч шестьсот восемьдесят семь тонн триста шестьдесят девять килограмм');
  Check(GetNumeral('@W @F @D000 @K', 5687.3694, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Пять тысяч шестьсот восемьдесят семь тонн 369 кг');
  Check(GetNumeral('@W @F @D000.# @K', 5687.3694, 0, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Пять тысяч шестьсот восемьдесят семь тонн 369.4 кг');
  Check(GetNumeral('@W @F @D000 @K', 5687.3694, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Пять тысяч шестьсот восемьдесят семь тонн 369 кг');
  Check(GetNumeral('@W @F @D000 @C', 5687.3694, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Пять тысяч шестьсот восемьдесят семь тонн 369 килограмм');
  Check(GetNumeral('@W @F @D000.#### @K', 5687.3694, 0, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Пять тысяч шестьсот восемьдесят семь тонн 369.4 кг');

  Check(GetCurrNumeral(200010, '@W @F @D @C', 1, 0, caseName, 0, '', '.', ' ') = 'Один белорусский рубль ноль копеек');
  Check(GetCurrNumeral(200010, '@W @F @D @C', 1, 0, caseName, partHideFracWhenZero, '', '.', ' ') = 'Один белорусский рубль');
  Check(GetCurrNumeral(200010, '@W @F @D @C', 0.15, 0, caseName, partHideWholeWhenZero + partHideFracWhenZero, '', '.', ' ') = 'Пятнадцать копеек');
  Check(GetCurrNumeral(200010, '@W @F @D @C', 1.15, 0.01, caseName, 0, '', '.', ' ') = 'Один белорусский рубль пятнадцать копеек');
  Check(GetCurrNumeral(200010, '@W @B @D @K', 1.15, 0.01, caseName, 0, '', '.', ' ') = 'Один руб. пятнадцать коп.');
  Check(GetCurrNumeral(200010, '@W @B @D00 @K', 1.15, 0.01, caseName, 0, '', '.', ' ') = 'Один руб. 15 коп.');
  Check(GetCurrNumeral(200010, '@W @F @D00 @C', 3561.15, 0.01, caseName, 0, '', '.', ' ') = 'Три тысячи пятьсот шестьдесят один белорусский рубль 15 копеек');
  Check(GetCurrNumeral(200010, '@W @F @D00.## @K', 3561.1586, 0, caseName, 0, '', '.', ' ') = 'Три тысячи пятьсот шестьдесят один белорусский рубль 15.86 коп.');
  Check(GetCurrNumeral(200010, '@W @F @D00.## @K', 3561.0586, 0, caseName, 0, '', '.', ' ') = 'Три тысячи пятьсот шестьдесят один белорусский рубль 05.86 коп.');
  Check(GetCurrNumeral(200010, '@W @F @D0.## @K', 3561.0586, 0, caseName, 0, '', '.', ' ') = 'Три тысячи пятьсот шестьдесят один белорусский рубль 5.86 коп.');
  Check(GetCurrNumeral(200010, '@W @F @D0.## @K', 3561.05, 0, caseName, 0, '', '.', ' ') = 'Три тысячи пятьсот шестьдесят один белорусский рубль 5 коп.');
  Check(GetCurrNumeral(200010, '@W#,##0 @F @D0.## @K', 3561.05, 0, caseName, 0, '', '.', ' ') = '3 561 белорусский рубль 5 коп.');
  Check(GetCurrNumeral(200010, '@N#,##0.00 @B @ \\ \@N', 3561.05, 0, caseName, 0, '', '.', ' ') = '3 561.05 руб. @ \ @n');

  Check(GetCurrNumeral(200010, '@S @I @O', 1.15, 0.01, caseName, 0, '', '.', ' ') = 'Br 933 BYN');

  Check(GetNumeral('@N', 13.365, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Тринадцать целых триста шестьдесят пять тысячных');
  Check(GetNumeral('@W @F @D @C', 5687.3694, 0.0001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Пять тысяч шестьсот восемьдесят семь тонн триста шестьдесят девять целых четыре десятых килограмм');

  Check(GetNumeral('@N', -1, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Минус одна');
  Check(GetNumeral('@N', -1.1, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Минус одна целая одна десятая');
  Check(GetNumeral('@N', -285.324, 0.001, 3, caseName, 0, 'тонна,тонны,тонн,т,килограмм,килограмма,килограмм,кг,--,.," "') = 'Минус двести восемьдесят пять целых триста двадцать четыре тысячных');

  Check(GetSumStr(149.908, 3) = 'сто сорок девять целых девятьсот восемь тысячных');
end;

procedure TBasicsTest.TestMulDiv;
begin
  CheckEqualsString(FloatToStr(MulDiv(9.45, 100 + 10, 100, 1, 2)), '10.4');
end;

procedure TBasicsTest.TestStDecMath;
var
  N: TStDecimal;
begin
  N := TStDecimal.Create;
  try
    N.AsString := '45657897E+3';
    Check(N.AsFloat = 45657897000);
    N.AsString := '45657897.221E+3';
    Check(N.AsFloat = 45657897221);
    N.AsString := '78945657897E-2';
    Check(N.AsString = '789456578.9700000000000000');
    N.AsString := '7894565789.7E-1';
    Check(N.AsString = '789456578.9700000000000000');
  finally
    N.Free;
  end;
end;

initialization
  RegisterTest('Internals', TBasicsTest.Suite);
end.

