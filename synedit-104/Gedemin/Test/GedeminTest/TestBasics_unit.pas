
unit TestBasics_unit;

interface

uses
  TestFrameWork;

type
  TBasicsTest = class(TTestCase)
  published
    procedure TestBasics;
  end;


implementation

{ TBasicsTest }

procedure TBasicsTest.TestBasics;
begin
  Check(2 = 2, 'ok');
end;

initialization
  RegisterTest('', TBasicsTest.Suite);
end.

