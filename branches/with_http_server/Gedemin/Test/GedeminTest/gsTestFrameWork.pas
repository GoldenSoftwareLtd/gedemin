
unit gsTestFrameWork;

interface

uses
  TestFrameWork, IBDatabase, IBSQL;

type
  TgsDBTestCase = class(TTestCase)
  protected
    FSettingsLoaded: Boolean;
    FQ, FQ2: TIBSQL;
    FTr: TIBTransaction;

    procedure SetUp; override;
    procedure TearDown; override;

  public
    property SettingsLoaded: Boolean read FSettingsLoaded;  
  end;

implementation

uses
  gd_security, jclStrings, SysUtils, gdcBaseInterface;

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

end.