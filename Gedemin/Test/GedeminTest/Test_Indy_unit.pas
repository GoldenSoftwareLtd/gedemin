
unit Test_Indy_unit;

interface

uses
  Classes, SysUtils, TestFrameWork;

type
  TgsIndyTest = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure Test;
  end;

implementation

uses
  Forms, gd_WebClientControl_unit;

procedure TgsIndyTest.SetUp;
begin
  inherited;
end;

procedure TgsIndyTest.TearDown;
begin
  inherited;
end;

procedure TgsIndyTest.Test;
begin
  Check(gdWebClientThread.gdWebServerURL > '');
end;

initialization
  RegisterTest('Internals/Indy', TgsIndyTest.Suite);
end.

