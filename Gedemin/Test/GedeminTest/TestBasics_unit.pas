
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
    procedure TestgdFSOCollection;
  end;

implementation

uses
  gd_CmdLineParams_unit, gd_common_functions, gsHugeIntSet, gd_FileList_unit;

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
begin
  Check(ExtractServerName('c:\test\test.fdb') = '');
  Check(ExtractServerName('host:c:\test\test.fdb') = 'host');
  Check(ExtractServerName('server/3030:c:\test\test.fdb') = 'server/3030');
end;

procedure TBasicsTest.TestgdFSOCollection;
var
  S: String;
  C1, C2: TgdFSOCollection;
begin
  C1 := TgdFSOCollection.Create;
  C2 := TgdFSOCollection.Create;
  try
    C1.Build;
    S := C1.GetXML;
    Check(S > '');
    C2.ParseXML(S);
    Check(S = C2.GetXML);
  finally
    C1.Free;
    C2.Free;
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

initialization
  RegisterTest('Internals', TBasicsTest.Suite);
end.

