
unit Test_gd_Security_unit;

interface

uses
  TestFrameWork, gsTestFrameWork;

type
  Tgd_SecurityTest = class(TgsDBTestCase)
  published
    procedure Test;
  end;

implementation

uses
  SysUtils, gd_Security;

procedure Tgd_SecurityTest.Test;
begin
  Check(IBLogin <> nil);

  FQ.SQL.Text := 'SELECT * FROM gd_holding';
  try
    FQ.ExecQuery;
    if FQ.EOF then
      Check(StrToInt(IBLogin.HoldingList) >= 0)
    else
      Check(Pos(',', IBLogin.HoldingList) > 0);
  finally
    FQ.Close;
  end;
end;

initialization
  RegisterTest('DB', Tgd_SecurityTest.Suite);
end.

