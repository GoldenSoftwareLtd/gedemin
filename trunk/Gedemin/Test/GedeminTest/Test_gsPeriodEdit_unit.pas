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
  SysUtils, gsPeriodEdit, jclDateTime;

{ TgsPeriodEditTest }

procedure TgsPeriodEditTest.TestPeriodEdit;
var
  S: TgsDataPeriod;
  Y, M, D, MN, YN, MP, YP: Word;

  procedure TestShortCut(const AShortCut: String; const ADate, ADateEnd: TDateTime;
    const AKind: TgsDatePeriodKind);
  var
    Ch: String;
  begin
    Ch := AShortCut;
    S.ProcessShortCut(Ch);
    Check(S.Date = ADate, '������ ��������� �������� ' + AShortCut);
    Check(S.EndDate = ADateEnd, '������ ��������� �������� ' + AShortCut);
    Check(S.Kind = AKind, '������ ��������� �������� ' + AShortCut);
  end;

begin
  S := TgsDataPeriod.Create;
  try
    S.DecodeString('01.02.2010-02.06.2010');
    Check(S.Date = EncodeDate(2010, 02, 01), '������ DecodeString');
    Check(S.EndDate = EncodeDate(2010, 06, 02), '������ DecodeString');
    Check(S.Kind = dpkFree, '������ DecodeString');

    Check(S.ProcessShortCut('X') = False);
    Check(S.ProcessShortCut('XX') = False);

    DecodeDate(Date, Y, M, D);
    case M of
      1:
        begin
          MN := M + 1;
          YN := Y;
          MP := 12;
          YP := Y - 1;
        end;
      12:
        begin
          MN := 1;
          YN := Y + 1;
          MP := M - 1;
          YP := Y;
        end;
    else
      begin
        MN := M + 1;
        YN := Y;
        MP := M - 1;
        YP := Y;
      end;
    end;

    TestShortCut('�', Date, Date, dpkDay);
    TestShortCut('�', Date + 1, Date + 1, dpkDay);
    TestShortCut('�', Date - 1, Date - 1, dpkDay);
    TestShortCut('�', Date - ISODayOfWeek(Date) + 1, Date - ISODayOfWeek(Date) - 1 + 7, dpkWeek);
    TestShortCut('��', Date - ISODayOfWeek(Date) + 1 - 7, Date - ISODayOfWeek(Date) - 1 + 7 - 7, dpkWeek);
    TestShortCut('��', Date - ISODayOfWeek(Date) + 1 + 7, Date - ISODayOfWeek(Date) - 1 + 7 + 7, dpkWeek);
    TestShortCut('�', EncodeDate(Y, M, 1), EncodeDate(YN, MN, 1) - 1, dpkMonth);
    TestShortCut('��', EncodeDate(YP, MP, 1), EncodeDate(Y, M, 1) - 1, dpkMonth);


    {
   9. �� -- ��������� �����
  10. � -- ������� �������
  11. �� -- ������� �������
  12. �� -- ��������� �������
  13. � -- ������� ���
  14. �� -- ������� ���
  15. �� -- ��������� ���}

  finally
    S.Free;
  end;
end;

initialization
  RegisterTest('', TgsPeriodEditTest.Suite);
end.
