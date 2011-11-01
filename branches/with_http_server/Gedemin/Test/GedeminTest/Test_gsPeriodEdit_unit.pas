unit Test_gsPeriodEdit_unit;

interface

uses
 Classes, TestFrameWork, Messages, StdCtrls, Dialogs,
 gsPeriodEdit, gsDatePeriod;

type
  TgsPeriodEditTest = class(TTestCase)
  private
    S, S2: TgsDatePeriod;

  protected
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestDecodeString;
    procedure TestEncodeString;
    procedure TestShortCuts;
    procedure TestAssign;
  end;

implementation

uses
  SysUtils, jclDateTime;

{ TgsPeriodEditTest }

procedure TgsPeriodEditTest.SetUp;
begin
  S := TgsDatePeriod.Create;
  S2 := TgsDatePeriod.Create;
end;

procedure TgsPeriodEditTest.TearDown;
begin
  S2.Free;
  S.Free;
end;

procedure TgsPeriodEditTest.TestAssign;
begin
  S.Kind := dpkYear;
  S.Date := EncodeDate(1976, 1, 1);
  S.EndDate := EncodeDate(1976, 12, 31);
  S.MaxDate := EncodeDate(1976, 12, 31);
  S.MinDate := EncodeDate(1976, 1, 1);

  S2.Assign(S);

  Check(S.Kind = S2.Kind);
  Check(S.Date = S2.Date);
  Check(S.EndDate = S2.EndDate);
  Check(S.MaxDate = S2.MaxDate);
  Check(S.MinDate = S2.MinDate);
end;

procedure TgsPeriodEditTest.TestDecodeString;

  procedure TestDecodeString(const St: String; const ADate, ADateEnd: TDateTime;
    const AKind: TgsDatePeriodKind);
  begin
    S.DecodeString(St);
    Check(S.Date = ADate, 'Ошибка DecodeString ' + St);
    Check(S.EndDate = ADateEnd, 'Ошибка DecodeString ' + St);
    Check(S.Kind = AKind, 'Ошибка DecodeString ' + St);
  end;

begin
  TestDecodeString('01.02.2010-02.06.2010', EncodeDate(2010, 02, 01),
    EncodeDate(2010, 06, 02), dpkFree);
  TestDecodeString('30.10.2010', EncodeDate(2010, 10, 30),
    EncodeDate(2010, 10, 30), dpkDay);
  TestDecodeString('01.2010', EncodeDate(2010, 01, 01),
    EncodeDate(2010, 01, 31), dpkMonth);
  TestDecodeString('01.09.1960-30.09.1960', EncodeDate(1960, 09, 01),
    EncodeDate(1960, 09, 30), dpkFree);
  TestDecodeString('7.2010', EncodeDate(2010, 07, 01),
    EncodeDate(2010, 07, 31), dpkMonth);
  TestDecodeString('2010', EncodeDate(2010, 01, 01),
    EncodeDate(2010, 12, 31), dpkYear);
  TestDecodeString('2005-2009', EncodeDate(2005, 01, 01),
    EncodeDate(2009, 12, 31), dpkFree);
end;

procedure TgsPeriodEditTest.TestEncodeString;
begin
  S.Date := EncodeDate(1980, 5, 15);
  S.EndDate := EncodeDate(1980, 5, 16);
  S.Kind := dpkFree;
  Check(S.EncodeString = '15.05.1980-16.05.1980');
  S.Date := EncodeDate(1976, 1, 1);
  S.EndDate := EncodeDate(1976, 12, 31);
  S.Kind := dpkYear;
  Check(S.EncodeString = '1976');
end;

procedure TgsPeriodEditTest.TestShortCuts;
var
  Y, M, D, MN, YN, MP, YP, MNN, YNN: Word;

  procedure TestShortCut(const AShortCut: Char; const ADate, ADateEnd: TDateTime;
    const AKind: TgsDatePeriodKind);
  begin
    S.ProcessShortCut(AShortCut);
    Check(S.Date = ADate, 'Ошибка обработки шортката ' + AShortCut);
    Check(S.EndDate = ADateEnd, 'Ошибка обработки шортката ' + AShortCut);
    Check(S.Kind = AKind, 'Ошибка обработки шортката ' + AShortCut);
  end;

begin
  Check(S.ProcessShortCut('X') = False);

  DecodeDate(Date, Y, M, D);
  case M of
    1:
      begin
        MN := M + 1;
        YN := Y;
        MP := 12;
        YP := Y - 1;

        MNN := M + 2;
        YNN := Y;
      end;

    2:
      begin
        MN := M + 1;
        YN := Y;
        MP := 1;
        YP := Y;

        MNN := M + 2;
        YNN := Y;
      end;

    11:
      begin
        MN := 12;
        YN := Y;
        MP := M - 1;
        YP := Y;

        MNN := 1;
        YNN := Y + 1;
      end;

    12:
      begin
        MN := 1;
        YN := Y + 1;
        MP := M - 1;
        YP := Y;

        MNN := 2;
        YNN := Y + 1;
      end;
  else
    begin
      MN := M + 1;
      YN := Y;
      MP := M - 1;
      YP := Y;

      MNN := M + 2;
      YNN := Y;
    end;
  end;

  TestShortCut('С', Date, Date, dpkDay);
  TestShortCut('З', Date + 1, Date + 1, dpkDay);
  TestShortCut('В', Date - 1, Date - 1, dpkDay);
  TestShortCut('Н', Date - ISODayOfWeek(Date) + 1, Date - ISODayOfWeek(Date) + 7, dpkWeek);
  TestShortCut('Я', Date - ISODayOfWeek(Date) + 1 - 7, Date - ISODayOfWeek(Date) + 7 - 7, dpkWeek);
  TestShortCut('Щ', Date - ISODayOfWeek(Date) + 1 + 7, Date - ISODayOfWeek(Date) + 7 + 7, dpkWeek);
  TestShortCut('М', EncodeDate(Y, M, 1), EncodeDate(YN, MN, 1) - 1, dpkMonth);
  TestShortCut('Л', EncodeDate(YN, MN, 1), EncodeDate(YNN, MNN, 1) - 1, dpkMonth);
  TestShortCut('Р', EncodeDate(YP, MP, 1), EncodeDate(Y, M, 1) - 1, dpkMonth);
  {TestShortCut('Г', EncodeDate(Y, 1, 1), EncodeDate(Y, 12, 31), dpkYear);
  TestShortCut('Г', EncodeDate(Y, 1, 1), EncodeDate(Y, 12, 31), dpkYear);
  TestShortCut('Г', EncodeDate(Y, 1, 1), EncodeDate(Y, 12, 31), dpkYear);}
  TestShortCut('Г', EncodeDate(Y, 1, 1), EncodeDate(Y, 12, 31), dpkYear);
  TestShortCut('О', EncodeDate(Y - 1, 1, 1), EncodeDate(Y - 1, 12, 31), dpkYear);
  TestShortCut('Е', EncodeDate(Y + 1, 1, 1), EncodeDate(Y + 1, 12, 31), dpkYear);

  TestShortCut('C', Date, Date, dpkDay);
  TestShortCut('P', Date + 1, Date + 1, dpkDay);
  TestShortCut('D', Date - 1, Date - 1, dpkDay);
  TestShortCut('Y', Date - ISODayOfWeek(Date) + 1, Date - ISODayOfWeek(Date) + 7, dpkWeek);
  TestShortCut('Z', Date - ISODayOfWeek(Date) + 1 - 7, Date - ISODayOfWeek(Date) + 7 - 7, dpkWeek);
  TestShortCut('O', Date - ISODayOfWeek(Date) + 1 + 7, Date - ISODayOfWeek(Date) + 7 + 7, dpkWeek);
  TestShortCut('V', EncodeDate(Y, M, 1), EncodeDate(YN, MN, 1) - 1, dpkMonth);
  TestShortCut('K', EncodeDate(YN, MN, 1), EncodeDate(YNN, MNN, 1) - 1, dpkMonth);
  TestShortCut('H', EncodeDate(YP, MP, 1), EncodeDate(Y, M, 1) - 1, dpkMonth);
  {TestShortCut('Г', EncodeDate(Y, 1, 1), EncodeDate(Y, 12, 31), dpkYear);
  TestShortCut('Г', EncodeDate(Y, 1, 1), EncodeDate(Y, 12, 31), dpkYear);
  TestShortCut('Г', EncodeDate(Y, 1, 1), EncodeDate(Y, 12, 31), dpkYear);}
  TestShortCut('U', EncodeDate(Y, 1, 1), EncodeDate(Y, 12, 31), dpkYear);
  TestShortCut('J', EncodeDate(Y - 1, 1, 1), EncodeDate(Y - 1, 12, 31), dpkYear);
  TestShortCut('T', EncodeDate(Y + 1, 1, 1), EncodeDate(Y + 1, 12, 31), dpkYear);
  {
с 	c 	Сегодня
з 	p 	Завтра
в 	d 	Вчера
н 	y 	Текущая неделя
я 	z 	Прошедшая неделя
щ 	o 	Следующая неделя
м 	v 	Текущий месяц
л 	k 	Следующий месяц
р 	h 	Прошедший месяц
к 	r 	Текущий квартал
и 	b 	Прошедший квартал
й 	q 	Следующий квартал
г 	u 	Текущий год
о 	j 	Прошедший год
е 	t 	Следующий год
}
end;

initialization
  RegisterTest('UI', TgsPeriodEditTest.Suite);
end.
