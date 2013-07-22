
unit gsTestFrameWork;

interface

uses
  TestFrameWork, IBDatabase, IBSQL;

type
  TgsTestCase = class(TTestCase)
  private
    function GetTestDataPath: String;
    function GetTempPath: String;

  protected
    procedure SetUp; override;

  public
    property TestDataPath: String read GetTestDataPath;
    property TempPath: String read GetTempPath;
  end;

  TgsDBTestCase = class(TgsTestCase)
  protected
    FSettingsLoaded: Boolean;
    FQ, FQ2: TIBSQL;
    FTr: TIBTransaction;

    procedure SetUp; override;
    procedure TearDown; override;

    function GetDBState: String;
    procedure ReConnect;
    procedure ActivateSettings(const ASettings: String);
    procedure SaveStringToFile(const S: String; const FN: String);

  public
    property SettingsLoaded: Boolean read FSettingsLoaded;
  end;

implementation

uses
  Classes, Forms, Windows, FileCtrl, gd_security, jclStrings, SysUtils,
  gdcBaseInterface, at_frmSQLProcess, at_ActivateSetting_unit;

procedure TgsDBTestCase.ActivateSettings(const ASettings: String);
var
  ActiveForm: TActivateSetting;
begin
  ActiveForm := TActivateSetting.Create(nil);
  try
    ActiveForm.SettingKeys := ASettings;
    ActiveForm.Perform(WM_ACTIVATESETTING, 0, 1);

    Check(not frmSQLProcess.IsError);

    if not FTr.InTransaction then
      FTr.StartTransaction;
  finally
    ActiveForm.Free;
  end;
end;

function TgsDBTestCase.GetDBState: String;
var
  q: TIBSQL;
begin
  Result := '';

  q := TIBSQL.Create(nil);
  try
    q.Transaction := FTr;

    q.SQL.Text := 'SELECT LIST(TRIM(rdb$field_name), '','') FROM rdb$relation_fields';
    q.ExecQuery;
    Result := Result + q.Fields[0].AsTrimString;
    q.Close;

    q.SQL.Text := 'SELECT LIST(TRIM(rdb$procedure_name), '','') FROM rdb$procedures';
    q.ExecQuery;
    Result := Result + q.Fields[0].AsTrimString;
    q.Close;

    q.SQL.Text := 'SELECT LIST(TRIM(rdb$trigger_name), '','') FROM rdb$triggers WHERE rdb$system_flag = 0';
    q.ExecQuery;
    Result := Result + q.Fields[0].AsTrimString;
    q.Close;

    q.SQL.Text := 'SELECT LIST(TRIM(rdb$exception_name), '','') FROM rdb$exceptions ';
    q.ExecQuery;
    Result := Result + q.Fields[0].AsTrimString;
    q.Close;
  finally
    q.Free;
  end;
end;

procedure TgsDBTestCase.ReConnect;
begin
  IBLogin.Relogin;

  if Assigned(frmSQLProcess) then
    Check(not frmSQLProcess.IsError);

  if not FTr.InTransaction then
    FTr.StartTransaction;  
end;

procedure TgsDBTestCase.SaveStringToFile(const S, FN: String);
var
  St: TStringStream;
  FS: TFileStream;
begin
  St := TStringStream.Create(S);
  try
    FS := TFileStream.Create(FN, fmCreate);
    try
      FS.CopyFrom(St, 0);
    finally
      FS.Free;
    end;
  finally
    St.Free;
  end;
end;

procedure TgsDBTestCase.SetUp;
begin
  inherited;

  if (gdcBaseManager = nil)
    or (gdcBaseManager.Database = nil)
    or (not gdcBaseManager.Database.Connected)
    or (IBLogin = nil)
    or (not IBLogin.LoggedIn) then
  begin
    StopTests('Нет подключения к базе данных');
  end;

  if StrIPos('test.fdb', IBLogin.Database.DatabaseName) = 0 then
    StopTests('Выполнение возможно только на тестовой БД');

  FTr := TIBTransaction.Create(nil);
  FTr.DefaultDatabase := IBLogin.Database;
  FTr.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait';
  FTr.StartTransaction;

  FQ := TIBSQL.Create(nil);
  FQ.Transaction := FTr;

  FQ2 := TIBSQL.Create(nil);
  FQ2.Transaction := FTr;

  FQ.SQL.Text := 'SELECT * FROM at_settingpos';
  FQ.ExecQuery;
  FSettingsLoaded := not FQ.EOF;
  FQ.Close;
end;

procedure TgsDBTestCase.TearDown;
begin
  FreeAndNil(FQ2);
  FreeAndNil(FQ);
  FreeAndNil(FTr);
  inherited;
end;

{ TgsTestCase }

function TgsTestCase.GetTempPath: String;
var
  Buff: array[0..1024] of Char;
begin
  Windows.GetTempPath(SizeOf(Buff), Buff);
  Result := ExcludeTrailingBackslash(Buff);
end;

function TgsTestCase.GetTestDataPath: String;
begin
  Result := ExtractFilePath(Application.EXEName) + '\Data';

  if not DirectoryExists(Result) then
    Result := ExtractFileDrive(Application.EXEName) +
      '\Golden\Gedemin\Test\GedeminTest\Data';
end;

procedure TgsTestCase.SetUp;
begin
  inherited;

  if not DirectoryExists(TestDataPath) then
    StopTests('Путь к тестовым данным не найден.');
end;

end.