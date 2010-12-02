
unit Test_dlgAbout_unit;

interface

uses
  TestFrameWork;

type
  TdlgAboutTest = class(TTestCase)
  published
    procedure Test;
  end;

implementation

uses
  gd_dlgAbout_unit;

{ TdlgAboutTest }

procedure TdlgAboutTest.Test;
var
  d: Tgd_dlgAbout;
begin
  d := Tgd_dlgAbout.Create(nil);
  try
    d.Show;
  finally
    d.Free;
  end;
end;

initialization
  RegisterTest('', TdlgAboutTest.Suite);
end.

