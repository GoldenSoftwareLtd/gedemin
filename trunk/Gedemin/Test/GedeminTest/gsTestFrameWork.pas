unit gsTestFrameWork;

interface

uses
  TestFrameWork, IBDatabase;

type
  TgsDBTestCase = class(TTestCase)
  protected
    procedure SetUp; override;
  end;

implementation

uses
  gd_security, jclStrings;

procedure TgsDBTestCase.SetUp;
begin
  inherited;

  if not IBLogin.LoggedIn then
    StopTests('��� ����������� � ���� ������');

  if StrIPos('test.fdb', IBLogin.Database.DatabaseName) = 0 then
    StopTests('���������� �������� ������ �� �������� ��');
end;

end.