unit Test_gsPeriodEdit_unit;

interface

uses
 Classes, TestFrameWork;

type
  TgsPeriodEditTest = class(TTestCase)
  published
    procedure TestPeriodEdit;
  end;

implementation

uses
 SysUtils, gsPeriodEdit;

{ TgsPeriodEditTest }

procedure TgsPeriodEditTest.TestPeriodEdit;
var
  S: TgsDataPeriod;
begin
  S := TgsDataPeriod.Create;
  try
{  S.DecodeString('01.02.2010-02.06.2010');
  Check(S.Date = StrToDate('01.02.2010'));
  Check(S.Date = StrToDate('02.06.2010'));
  Check(S.Kind = dpkFree);
  Check(S.ProcessShortCut('Ç',''));
  Check(S.Date = StrToDate('23.09.2010'));}


  finally
    S.Free;
  end;
end;

end.
 