
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
  end;

implementation

uses
  SysUtils, gd_CmdLineParams_unit, gd_common_functions, gsHugeIntSet,
  gdNotifierThread_unit, gd_encryption;

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
  gdNotifierThread.Add('Это сообщение с таймером и будет показываться 60 сек... <tmr>', 0, 60000);
  gdNotifierThread.Add('Это сообщение будет показываться 30 сек...', 0, 30000);
  Check(gdNotifierThread.Suspended = False);
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

initialization
  RegisterTest('Internals', TBasicsTest.Suite);
end.

