
unit gsTestFrameWork;

interface

uses
  TestFrameWork, IBDatabase, IBSQL;

type
  TgsDBTestCase = class(TTestCase)
  protected
    FQ: TIBSQL;
    FTr: TIBTransaction;

    procedure SetUp; override;
    procedure TearDown; override;
  end;

implementation

uses
  gd_security, jclStrings, SysUtils;

procedure TgsDBTestCase.SetUp;
begin
  inherited;

  if not IBLogin.LoggedIn then
    StopTests('Нет подключения к базе данных');

  if StrIPos('test.fdb', IBLogin.Database.DatabaseName) = 0 then
    StopTests('Выполнение возможно только на тестовой БД');

  FTr := TIBTransaction.Create(nil);
  FTr.DefaultDatabase := IBLogin.Database;
  FTr.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait';
  FTr.StartTransaction;

  FQ := TIBSQL.Create(nil);
  FQ.Transaction := FTr;
end;

procedure TgsDBTestCase.TearDown;
begin
  FreeAndNil(FQ);
  FreeAndNil(FTr);
  inherited;
end;

end.