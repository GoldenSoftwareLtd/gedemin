unit Inform;

interface

uses
  SysUtils, WinTypes, WinProcs, DBTables, xAppReg, DB, Graphics, Dialogs, xOption;

type
   TStateEnter = (seAppend, seEdit, seCopy);
   TSumState = (ssHolidPay, ssIllPay);

type
   TDocType = (dRaschPlat, dPlatVed, dRashList, dYearAddPayment, dStagAccount,
     dMediumWage, dTransVed, dChildVed, dTransDisk);

   TPrevAcc = (paMonthSalary, paTimePay, paAvansy, paGiveBack, paIllSum, paHolidSum,
     paMilkOrd, paAnimOrd, paSvodVed);

Const
   Version = '1.71';
   CurrentFirm: Integer = 0;
   { 0 - постоянный работник, 1 - совместитель, 2 - договора подряда }

   Monthes: array [1..12] of String[10] =
       ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль',
        'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь');

   SizeiAddPSignName = 9;

   iAddPSignName: array [0..SizeiAddPSignName] of string[25] =
      ('абс. число',
       '% от оклада',
       '% от мин. зарплаты',
       '% от всего начисл.',
       '% от суммы за отр. время', {Расчет КТУ}
       'ср. заработок в день', {Детский день} {Начисляется}
       '% от ср. заработка',
       '% от заработка прошл. мес',
       {новое}
       '% от ставки 1-го разряда',
       'часовая тарифная ставка');

   SizeiDedSignName = 3;
   iDedSignName: array [0..SizeiDedSignName] of string[25] =
      ('абс. число',
       '% от оклада',
       '% от мин. зарплаты',
       '% от з/п для Алиментов');

   SizeiPaymentName = 2;
   iPaymentName: array [0..SizeiPaymentName] of string[15] =
     ('Оклад', 'Сдельно', 'Повременно');
   psOklad  = 0;  psSdelno = 1;  psByTime = 2;

   CatSize = 23;
   CatCoef : array[1..CatSize] of real =
     ( 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

   AccountingDay: Integer = 15;  {День расчета}

   HoliMonthes: Integer = 12; {Период (в мес.) для расчета отпускных}
   DaysInMonth: Double = 25.3; {Среднее количество дней в месяце}
   IllMonthes: Integer = 2; {Период (в мес.)для расчета больничных}

   ReIncome: Boolean = True; {Пересчитывать подоходный налог}
   VeteranState: Boolean = False; {Удерживать соцстрах за этот месяц}

   HighChildYear: Word = 18;
   HourInDay: Word = 8;
   RoundValue: Integer = 1000; {Константа для округления начислений}
   RoundTaxValue: Integer = 1000; {Константа для округления налогов}

   OverTimeCoef1: Double = 1.5;
   OverTimeCoef2: Double = 2;
   NightCoef: Double = 2;
   HolidCoef: Double = 2;

   MatHelpForIncome: Integer = 30;
   MatHelpForVeteran: Integer = 0;
   PresentForIncome: Integer = 30;

   mBeginSaldo: Boolean = True;
   mGiveWage: Boolean = True;
   mIncSum: Boolean = True;
   mEndSaldo: Boolean = True;
   mOrientation: Integer = 1;
   mPageFooter: Boolean = False;



   ShortFieldsLength: Integer = 8;
   LongFieldsLength: Integer = 12;

   StagPeriod: Integer = 1;
   YPPeriod: Integer = 12;

   GiveAllWage: Boolean = True;
   GiveOnlyPlusSum: Boolean = True;
   GiveOnlyWage: Boolean = False;
   GiveWageRound: Boolean = False;
   GiveWageRoundValue: Integer = 1;

   IllFormKey: Word = 1;
   HolidFormKey: Word = 2;
   StagFormKey: Word = 3;
   AllFormKey: Word = 4;
   PeriodFormKey: Word = 5;

   Remainder: Boolean = True;
   ExistCaption: Boolean = False;

   CalcIllPeriod: Boolean = True;

   PiecWorkByHours: Boolean = True;
   RLOrderList: Boolean = True;
   RLDebt: Boolean = False;

   DenominationDate: TDateTime = 730120;
   DenominationKoef: LongInt = 1000;

var
  CurrentCode: Integer;
  RVFont: TFont;

  SaveExit: Pointer;


function GetAccountDate(ADate : TDateTime):TDateTime;
function GetLastDate(CurrentDate : TDateTime) : TDateTime;
function GetFirstDate(CurrentDate: TDateTime): TDAteTime;

function GetNextDay(CurrentDate: TDateTime): TDateTime;
function GetPriorDay(CurrentDate: TDateTime): TDateTime;

function GetNextMonth(CurrentDate: TDateTime): TDateTime;
function GetPrevMonth(CurrentDate: TDateTime): TDateTime;

procedure SetTarSetka(aDate: TDateTime; aTable: TTable);

function CurrencyRound(aValue: Double; aRoundValue: Integer): Longint;

function ExCurrencyRound(aValue: Double; aRoundValue: Integer): Double;

function DayMonthYear(aDate: TDateTime): String;
function MonthYear(aDate: TDatetime): String;
function MonthYearInNumber(ADate: TDatetime): String;
function PeriodInMonth(FromDate, ToDate: TDateTime): Word;
function HowDayInMonth(aDate: TDateTime): Word;
function GetMonthStr(ADate: TDateTime): String;
function GetMonth(ADate: TDateTime): Word;
function GetYear(ADate: TDateTime): Word;
function GetYearStr(ADate: TDateTime): String;
function GetFirstMonth(aDate: TDateTime): TDateTime;
function GetLastMonth(aDate: TDateTime): TDateTime;
procedure ReadParams;
procedure WriteParams;
function xFormat(FormatString : String; Summ: Double): String;
function TimeInDecimal(HMValue: Double): Double;
function InRub(aDataSet: TTable; aMany: Double; aDate:TDateTime): Double;
function FirstInYear(aDate: TDateTime): TDateTime;
function LastInYear(aDate: TDateTime): TDateTime;

function DaysInYear(AYear: TDateTime): Word;
function GetAge(FromDate, ToDate: TDateTime): Double;
function GetAgeAsDateStr(FromDate, ToDate: TDateTime): String;
function DeleteMonthFromDate(Value: String; MonthCount: Word): String;
function FinishedAge(FromDate: TDateTime; Age: Double): Double;

function DaysBetween(FromDate, ToDate: TDateTime): Integer;

function xMessageBox(HANDLE: THandle; const Dest: String; const Title: String;
  TextType: Word): Integer;

function GetQuarter(ADate: TDateTime): Word;
procedure StartEndQuarter(var StartQuarter, EndQuarter: TDateTime; ADate: TDateTime;
  AState: Boolean);
function DenominationSum(Value: Double; CurrentDate, PriorDate: TDateTime): Double;

implementation

function xMessageBox(HANDLE: THandle; const Dest: String; const Title: String;
  TextType: Word): Integer;
var
  Temp, Temp1: array[0..255] of Char;
begin
  StrPCopy(Temp, Dest);
  StrPCopy(Temp1, Title);
  Result:= MessageBox(HANDLE, Temp, Temp1, TextType);
end;


function DenominationSum(Value: Double; CurrentDate, PriorDate: TDateTime): Double;
begin
  if (CurrentDate >= DenominationDate)
    and  (PriorDate < DenominationDate)
  then
    Result := Value / DenominationKoef
  else
    Result := Value;
end;

function GetAccountDate(ADate : TDateTime):TDateTime;
 var
  vDay,vMonth,vYear : word;
begin
  DecodeDate(ADate,vYear, vMonth, vDay);
  vDay := AccountingDay;
  Result := EncodeDate(vYear, vMonth, vDay);
end;

function GetFirstDate(CurrentDate: TDateTime): TDAteTime;
var
  vDay,vMonth,vYear : word;
begin
  try
    DecodeDate(CurrentDate,vYear,vMonth,vDay);
    vDay := 1;
    result := EncodeDate(vYear, vMonth, vDay);
  except
    result := CurrentDate;
  end;
end;

function GetLastDate(CurrentDate: TDateTime): TDAteTime;
var
  vDay,vMonth,vYear : word;
begin
  try
    DecodeDate(CurrentDate,vYear,vMonth,vDay);
    case vMonth of
     1,3,5,7,8,10,12: vDay:= 31;
     2:
      begin
       if  (vYear mod 4) <> 0  then vDay:= 28
       else
         if (vYear <> 2000) then vDay:= 29
         else vDay:= 30;
      end;
     4,6,9,11: vDay:= 30;
    end;
     result:= EncodeDate(vYear, vMonth, vDay);
  except
    Result := CurrentDate;
  end;
end;
                                                             
function GetNextDay(CurrentDate: TDateTime): TDateTime;
var
  vYear,vMonth,vDay : word;
begin
  DecodeDate(CurrentDate,vYear,vMonth,vDay);
  case vMonth of
    1,3,5,7,8,10:
      if vDay = 31 then
      begin
        vDay:= 1;
        inc(vMonth);
      end
      else
        inc(vDay);
    2:
      if (vDay = 28) and ((vYear mod 4) <> 0 ) then
      begin
        vDay:= 1;
        inc(vMonth);
      end
      else
        if (vDay = 29) and (vYear <> 2000) then
        begin
          vDay:= 1;
          inc(vMonth);
        end
        else
          if (vDay = 30) then
          begin
            vDay:= 1;
            inc(vMonth);
          end
          else inc(vDay);
    4,6,9,11:
      if vDay = 30 then
      begin
        vDay := 1;
        inc(vMonth);
      end
      else
        inc(vDay);
    12:
      if vDay = 31 then
      begin
        vDay := 1;
        vMonth := 1;
        inc(vYear);
      end
      else
        inc(vDay);
  end;
  result:= EncodeDate(vYear,vMonth,vDay);
end;

function GetPriorDay(CurrentDate: TDateTime): TDateTime;
var
  Year, Month, Day : Word;

  S : String;

begin
  S := DateToStr(CurrentDate);
  DecodeDate(CurrentDate, Year, Month, Day);
  case Month of
    {first month of year}
    1:
      if Day = 1 then
      begin
        Dec(Year);
        Month := 12;
        Day := 31;
      end
      else Dec(Day);

    {There are 30 days in monthes.}
    2,4,6,9,11:
      if Day = 1 then
      begin
        Dec(Month);
        Day := 31;
      end
      else Dec(Day);

    {Previous month is February.}
    3:
      if Day = 1 then
      begin
        Dec(Month);
        if (Year mod 4) <> 0 then Day := 28
        else
          if Year = 2000 then Day := 30
          else Day := 29;
      end
      else Dec(Day);

     {There are 31 days in the monthes.}
    5,7,8,10,12:
      if Day = 1 then
      begin
        Day := 30;
        Dec(Month)
      end
      else Dec(Day);
  end;

  Result:= EncodeDate(Year, Month, Day);
end;


function GetNextMonth(CurrentDate: TDateTime): TDateTime;
var
  vYear,vMonth,vDay: word;
begin
  DecodeDate(CurrentDate,vYear,vMonth,vDay);
  if vMonth = 12 then
  begin
    inc(vYear);
    vMonth := 1;
  end
  else
    inc(vMonth);
  Result := EncodeDate(vYear,vMonth,15);
end;

function GetPrevMonth(CurrentDate: TDateTime): TDateTime;
var
  vYear,vMonth,vDay: word;
begin
  DecodeDate(CurrentDate,vYear,vMonth,vDay);
  if vMonth = 1 then
  begin
    dec(vYear);
    vMonth := 12;
  end
  else
    dec(vMonth);
  Result := EncodeDate(vYear,vMonth,15);
end;

procedure SetTarSetka(aDate: TDateTime; aTable: TTable);
var
  i: Integer;
  CatStr: string;
begin
  aTable.Open;
  aTable.First;
  while not aTable.Eof do
  begin
    if aTable.FieldByName('TarDate').AsDateTime > GetLastDate(aDate) then Exit;
    for i := 1 to CatSize do
    begin
      Str(i,CatStr);
      CatCoef[i] := aTable.FieldByName(CatStr).AsFloat;
    end;
    aTable.Next;
  end;
  aTable.Close;
end;

function CurrencyRound(aValue: Double; ARoundValue: Integer): Longint;
begin
  aValue := aValue / ARoundValue;
  if Frac(AValue) = 0.5 then AValue := AValue + 0.1;

  Result := Round(aValue) * ARoundValue;
end;

function ExCurrencyRound(aValue: Double; ARoundValue: Integer): Double;
var
  S, S1, S2: String;
  D, D1, D2: Double;
begin
  Result := aValue;
  (* Число в строку *)
  S := FloatToStr(aValue);

  (* Если есть после запятой, то их отсечь *)
  if Pos('.', S) > 0 then S := Copy(S, 1, Pos('.', S) - 1);

  (* отсечены после запятой *)
  aValue := StrToFloat(S);

  (* До чего округлять *)
  S1 := IntToStr(ARoundValue);

  (* Выделить последнние символы *)
  S2 := Copy(S, Length(S) - Length(S1) + 1, Length(S1));

  D2 := StrToFloat(S2);

  (* Вычесть последние цифры *)
  aValue := aValue - D2;

  (* округлить последние цифры*)
  D := CurrencyRound(D2, ARoundValue);

  Result := AValue + D;
end;


function DayMonthYear(aDate: TDateTime): String;
var
  Year, Month, Day: Word;
  sYear, sMonth, sDay: String;
begin
  Result := '';
  DecodeDate(aDate, Year, Month, Day);
  Str(Year, Result);
  Result := '"' + IntToStr(Day) + '" ' + Monthes[Month] + ' ' + Result;
end;

function MonthYear(aDate: TDateTime): String;
var
  Year, Month, Day: Word;
  sYear, sMonth, sDay: String;
begin
  Result := '';
  DecodeDate(aDate, Year, Month, Day);
  Str(Year, Result);
  Result := Monthes[Month] + ' ' + Result;
end;

function MonthYearInNumber(ADate: TDateTime): String;
var
  Year, Month, Day: Word;
  S: String[10];
begin
  Result := '';
  if ADate <> 0 then
  begin
    DecodeDate(aDate, Year, Month, Day);
    S := IntToStr(Year);
    if Length(S) = 4 then
      S := Copy(S, 3, 2);
    Result := IntToStr(Month)+ '.' + S;
  end;
end;

function PeriodInMonth(FromDate, ToDate: TDateTime): Word;
var
  FromYear, FromMonth, FromDay: Word;
  ToYear, ToMonth, ToDay: Word;
  Month: Word;
  Year: Word;
begin
  Result := 0;
  if GetLastDate(FromDate) > GetLastDate(ToDate) then Exit;
  DecodeDate(FromDate, FromYear, FromMonth, FromDay);
  DecodeDate(ToDate, ToYear, ToMonth, ToDay);
  Month := ToMonth - FromMonth + 1;
  Year := ToYear - FromYear;
  Month := Month + 12*Year;
  Result := Month;
end;

function HowDayInMonth(aDate: TDateTime): Word;
var
  Year, Month, Day: Word;
begin
  aDate := GetLastDate(aDate);
  DecodeDate(aDate, Year, Month, Day);
  Result := Day;
end;

function GetMonthStr(ADate: TDateTime): string;
var
  Day, Month, Year: word;
begin
  DecodeDate(ADate, Year, Month, Day);
  Str(Month, Result);
end;

function GetMonth(ADate: TDateTime): Word;
var
  Day, Month, Year: word;
begin
  DecodeDate(ADate, Year, Month, Day);
  Result := Month;
end;

procedure ReadParams;
begin
  HoliMonthes := Option.ReadGlobalInteger('Params', 'HoliMonthes', 12);
  DaysInMonth := StrToFloat(Option.ReadString('Params', 'DaysInMonth', '25.3'));
  IllMonthes := Option.ReadGlobalInteger('Params', 'IllMonthes', 2);
  DenominationDate := Option.ReadGlobalDate('Params', 'DenominationDate', StrToDate('01.01.2000'));
  DenominationKoef := Option.ReadGlobalInteger('Params', 'DenominationKoef', 1000);


  ReIncome := Option.ReadGlobalBoolean('Params', 'ReIncome', True);
  VeteranState := Option.ReadGlobalBoolean('Params', 'VeteranState', False);

  HourInDay := Option.ReadGlobalInteger('Params', 'HourInDay', 8);
  HighChildYear := Option.ReadGlobalInteger('Params', 'HighChildYear', 18);
  RoundValue := Option.ReadGlobalInteger('Params', 'RoundValue', 1000);
  RoundTaxValue := Option.ReadGlobalInteger('Params', 'RoundTaxValue', 1000);

  OverTimeCoef1 := StrToFloat(Option.ReadGlobalString('Params', 'OverTimeCoef1', '1.5'));
  OverTimeCoef2 := StrToFloat(Option.ReadGlobalString('Params', 'OverTimeCoef2', '2'));
  NightCoef := StrToFloat(Option.ReadGlobalString('Params', 'NightCoef', '2'));
  HolidCoef := StrToFloat(Option.ReadGlobalString('Params', 'HolidCoef', '2'));

  MatHelpForIncome := Option.ReadGlobalInteger('Params', 'MatHelpForIncome', 30);
  MatHelpForVeteran := Option.ReadGlobalInteger('Params', 'MatHelpForVeteran', 0);

  PresentForIncome := Option.ReadGlobalInteger('Params', 'PresentForIncome', 30);

  mBeginSaldo := Option.ReadGlobalBoolean('Params', 'mBeginSaldo', True);
  mGiveWage := Option.ReadGlobalBoolean('Params', 'mGiveWage', True);
  mIncSum := Option.ReadGlobalBoolean('Params', 'mIncSum', True);
  mEndSaldo := Option.ReadGlobalBoolean('Params', 'mEndSaldo', True);
  mOrientation := Option.ReadGlobalInteger('Params', 'mOrientation', 1);
  mPageFooter := Option.ReadGlobalBoolean('Params', 'mPageFooter', False);


  ShortFieldsLength := Option.ReadGlobalInteger('Params', 'ShortFieldsLength', 8);
  LongFieldsLength := Option.ReadGlobalInteger('Params', 'LongFieldsLength', 12);

  AppRegistry.ReadFont('Params', 'RVFont', RVFont);

  StagPeriod := Option.ReadGlobalInteger('Params', 'StagPeriod', 1);
  YPPeriod := Option.ReadGlobalInteger('Params', 'YPPeriod', 12);

  GiveAllWage := Option.ReadGlobalBoolean('Params', 'GiveAllWage', False);
  GiveOnlyPlusSum := Option.ReadGlobalBoolean('Params', 'GiveOnlyPlusSum', False);
  GiveOnlyWage := Option.ReadGlobalBoolean('Params', 'GiveOnlyWage', False);
  GiveWageRound := Option.ReadGlobalBoolean('Params', 'GiveWageRound', False);
  GiveWageRoundValue := Option.ReadGlobalInteger('Params', 'GiveWageRoundValue', 1);



  Remainder := Option.ReadGlobalBoolean('Params', 'Remainder', True);
  ExistCaption := Option.ReadGlobalBoolean('Params', 'ExistCaption', False);

  CalcIllPeriod := Option.ReadGlobalBoolean('Params', 'CalcIllPeriod', True);

  PiecWorkByHours := Option.ReadGlobalBoolean('Params', 'PiecWorkByHours', True);
  RLOrderList := Option.ReadGlobalBoolean('Params', 'RLOrderList', True);
  RLDebt := Option.ReadGlobalBoolean('Params', 'RLDebt', False);
end;

procedure WriteParams;
var
  DaysInMonthStr: String;
begin
  Str(DaysInMonth:5:2, DaysInMonthStr);


  Option.WriteGlobalDate('Params', 'DenominationDate', DenominationDate);
  Option.WriteGlobalInteger('Params', 'DenominationKoef', DenominationKoef);


  Option.WriteGlobalString('Params', 'DaysInMonth', DaysInMonthStr);
  Option.WriteGlobalInteger('Params', 'HoliMonthes', HoliMonthes);
  Option.WriteGlobalInteger('Params', 'IllMonthes', IllMonthes);

  Option.WriteGlobalBoolean('Params', 'ReIncome', ReIncome);
  Option.WriteGlobalBoolean('Params', 'VeteranState', VeteranState);

  Option.WriteGlobalInteger('Params', 'HourInDay', HourInDay);
  Option.WriteGlobalInteger('Params', 'HighChildYear', HighChildYear);
  Option.WriteGlobalInteger('Params', 'RoundValue', RoundValue);
  Option.WriteGlobalInteger('Params', 'RoundTaxValue', RoundTaxValue);

  Option.WriteGlobalString('Params', 'OverTimeCoef1', Format('%.2f', [OverTimeCoef1]));
  Option.WriteGlobalString('Params', 'OverTimeCoef2', Format('%.2f', [OverTimeCoef2]));
  Option.WriteGlobalString('Params', 'NightCoef', Format('%.2f', [NightCoef]));
  Option.WriteGlobalString('Params', 'HolidCoef', Format('%.2f', [HolidCoef]));

  Option.WriteGlobalInteger('Params', 'MatHelpForIncome', MatHelpForIncome);
  Option.WriteGlobalInteger('Params', 'MatHelpForVeteran', MatHelpForVeteran);
  Option.WriteGlobalInteger('Params', 'PresentForIncome', PresentForIncome);

  Option.WriteGlobalBoolean('Params', 'mBeginSaldo', mBeginSaldo);
  Option.WriteGlobalBoolean('Params', 'mGiveWage', mGiveWage);
  Option.WriteGlobalBoolean('Params', 'mIncSum', mIncSum);
  Option.WriteGlobalBoolean('Params', 'mEndSaldo', mEndSaldo);
  Option.WriteGlobalInteger('Params', 'mOrientation', mOrientation);
  Option.WriteGlobalBoolean('Params', 'mPageFooter', mPageFooter);



  Option.WriteGlobalInteger('Params', 'ShortFieldsLength', ShortFieldsLength);
  Option.WriteGlobalInteger('Params', 'LongFieldsLength', LongFieldsLength);

  AppRegistry.WriteFont('Params', 'RVFont', RVFont);

  Option.WriteGlobalInteger('Params', 'StagPeriod', StagPeriod);
  Option.WriteGlobalInteger('Params', 'YPPeriod', YPPeriod);

  Option.WriteGlobalBoolean('Params', 'GiveAllWage', GiveAllWage);
  Option.WriteGlobalBoolean('Params', 'GiveOnlyPlusSum', GiveOnlyPlusSum);
  Option.WriteGlobalBoolean('Params', 'GiveOnlyWage', GiveOnlyWage);
  Option.WriteGlobalBoolean('Params', 'GiveWageRound', GiveWageRound);
  Option.WriteGlobalInteger('Params', 'GiveWageRoundValue', GiveWageRoundValue);

  Option.WriteGlobalBoolean('Params', 'Remainder', Remainder);
  Option.WriteGlobalBoolean('Params', 'ExistCaption', ExistCaption);

  Option.WriteGlobalBoolean('Params', 'CalcIllPeriod', CalcIllPeriod);

  Option.WriteGlobalBoolean('Params', 'PiecWorkByHours', PiecWorkByHours);
  Option.WriteGlobalBoolean('Params', 'RLOrderList', RLOrderList);
  Option.WriteGlobalBoolean('Params', 'RLDebt', RLDebt);
end;

function GetFirstMonth(aDate: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(aDate, Year, Month, Day);
  Month := 1;
  Result := EncodeDate(Year, Month, Day);
end;

function GetLastMonth(aDate: TDateTime): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(aDate, Year, Month, Day);
  Month := 12;
  Result := EncodeDate(Year, Month, Day);
end;

function xFormat(FormatString : String; Summ: Double): String;
begin
  Result := '';
  if Summ = 0 then Exit;
  if Frac(Summ) > 0 then Result := FormatString + Format('%f', [Summ])
  else Result := FormatString + Format('%.0f', [Summ]);
end;

function TimeInDecimal(HMValue: Double): Double;
var
  Hour, Minute: Double;
begin
  Hour := Int(HMValue);
  Minute := Frac(HMValue) / 60;
  Result := Hour + Minute;
end;

function InRub(aDataSet: TTable; aMany: Double; aDate: TDateTime): Double;
begin
  Result := aMany;
  aDataSet.Last;
  while not aDataSet.Bof do
  begin
    if aDataSet.FieldByName('Date').AsDateTime <= GetLastDate(aDate) then
    begin
      Result := aMany * aDataSet.FieldByName('Curs').AsFloat;
      Break;
    end;
    aDataSet.Prior;
  end
end;

function FirstInYear(aDate: TDateTime): TDateTime;
var
  Year, Month, Day: word;
begin
  DecodeDate(aDate, Year, Month, Day);
  Month := 1;
  Day := 1;
  Result := EncodeDate(Year, Month, Day);
end;

function LastInYear(aDate: TDateTime): TDateTime;
var
  Year, Month, Day: word;
begin
  DecodeDate(aDate, Year, Month, Day);
  Month := 12;
  Day := 31;
  Result := EncodeDate(Year, Month, Day);
end;

function GetYear(ADate: TDateTime): Word;
var
  Month, Day: word;
begin
  DecodeDate(aDAte, Result, Month, Day);
end;

function GetYearStr(ADate: TDateTime): String;
var
  Year, Month, Day: word;
begin
  DecodeDate(aDAte, Year, Month, Day);
  Result := IntToStr(Year);
end;

function DaysInYear(AYear: TDateTime): Word;
var
  Year, Month, Day: Word;
begin
  Result := 365;

  {
  DecodeDate(AYear, Year, Month, Day);

  if (Year mod 4) <> 0 then Result := 365
  else
    if Year = 2000 then Result := 367
    else Result := 366;
 }
end;

function GetAge(FromDate, ToDate: TDateTime): Double;
var
  fYear, fMonth, fDay: Word;
  tYear, tMonth, tDay: Word;
  Month, Year: Integer;
begin
  Result := 0;
  if FromDate > ToDate then Exit;
  try
    DecodeDate(FromDate, fYear, fMonth, fDay);
    DecodeDate(ToDate, tYear, tMonth, tDay);
    Month := tMonth - fMonth;
    Year := tYear - fYear;
    Month := Month + Year * 12;
    Result := Month / 12;
  except
    Result := 100;
  end;
end;

(* Получить возрасть в формате *)
function GetAgeAsDateStr(FromDate, ToDate: TDateTime): String;
var
  FromDay, FromMonth, FromYear: Word;
  ToDay, ToMonth, ToYear: Word;
  Day, Year, Month: Integer;
begin
  Result := '';
  if FromDate > ToDate then Exit;
  try
    DecodeDate(FromDate, FromYear, FromMonth, FromDay);
    DecodeDate(ToDate, ToYear, ToMonth, ToDay);

    Day := ToDay - FromDay;
    Month := ToMonth - FromMonth;
    Year := ToYear - FromYear;

    if Day < 0 then
    begin
      (* Количетсво дней до конца месяца *)
      Day := DaysBetween(FromDate, GetLastDate(FromDate));
      Month := Month - 1;
    end;

    if Month < 0 then
    begin
      (* Количество месяцев *)
      Month := 12 + Month;
      Year := Year - 1;
    end;

    Result := IntToStr(Year)+ '.' +IntToStr(Month)+ '.'+ IntToStr(Day);
  except
    Result := '';
  end;
end;

(* Удалить месяцы *)
function DeleteMonthFromDate(Value: String; MonthCount: Word): String;
var
  Day, Year, Month: Integer;
  P1: Word;
begin
  Result := '00.00.00';

  (* Выделить год, месяц, день *)
  P1 := Pos('.', Value);
  Year := StrToInt(Copy(Value, 1, P1 - 1));
  Delete(Value, 1, P1);

  P1 := Pos('.', Value);
  Month := StrToInt(Copy(Value, 1, P1 - 1)) - MonthCount;
  Delete(Value, 1, P1);

  Day := StrToInt(Value);

  if Month < 0 then
  begin
    if Year <= 0 then  Exit;
    Dec(Year);
    Month := Month + 12;
  end;

  Result := IntToStr(Year)+ '.' + IntToStr(Month)+ '.' + IntToStr(Day);
end;

function FinishedAge(FromDate: TDateTime; Age: Double): Double;
var
  Year, Month, Day, I: Word;
  AgeYear, AgeMonth, AgeDay: Word;

begin
  DecodeDate(FromDate, Year, Month, Day);

  Year := Year + Round(Int(Age));
  Age := Age - Int(Age);
  AgeDay := Round(Int(Age * 365));

  if (Month = 2) and (Day = 29) then Result := EncodeDate(Year, Month, Day - 1)
  else Result := EncodeDate(Year, Month, Day);

  for I := 1 to AgeDay do Result := GetNextDay(Result);
end;

function DaysBetween(FromDate, ToDate: TDateTime): Integer;
begin
  Result := 0;
  while FromDate <= ToDate do
  begin
    Inc(Result);
    FromDate := GetNextDay(FromDate);
  end;
end;

(* По дате опредляет, к какому кварталу относится*)
function GetQuarter(ADate: TDateTime): Word;
var
  Month: Word;
begin
  Month := GetMonth(ADate);
  if Month <= 3 then Result := 1
  else
    if Month <= 6 then Result := 2
    else
      if Month <= 9 then Result := 3
      else
        if Month <= 12 then Result := 4
end;

(*
    Устанавливает в StartQuarter, EndQuarter начало и конец кваратла,
  по месяцу, определяемому ADate.
    AState - включать последний месяц (True), включать предпоследний (False)
  *)

procedure StartEndQuarter(var StartQuarter, EndQuarter: TDateTime; ADate: TDateTime;
  AState: Boolean);
var
  Day, Month, Year, Quarter: Word;
begin
  (* Месяц квараьала*)

  Quarter := GetQuarter(ADate);

  (* Определить первый и предпоследний месяц квартала*)
  case Quarter of
    1:
    begin
      DecodeDate(ADate, Year, Month, Day);
      Day := 1; Month := 1;
      StartQuarter := EncodeDate(Year, Month, Day);
      Day := 28; Month := 2;
      EndQuarter := GetLastDate(EncodeDate(Year, Month, Day));
    end;
    2:
    begin
      DecodeDate(ADate, Year, Month, Day);
      Day := 1; Month := 4;
      StartQuarter := EncodeDate(Year, Month, Day);
      Day := 30; Month := 5;
      EndQuarter := GetLastDate(EncodeDate(Year, Month, Day));
    end;
    3:
    begin
      DecodeDate(ADate, Year, Month, Day);
      Day := 1; Month := 7;
      StartQuarter := EncodeDate(Year, Month, Day);
      Day := 30; Month := 8;
      EndQuarter := GetLastDate(EncodeDate(Year, Month, Day));
    end;
    4:
    begin
      DecodeDate(ADate, Year, Month, Day);
      Day := 1; Month := 10;
      StartQuarter := EncodeDate(Year, Month, Day);
      Day := 30; Month := 11;
      EndQuarter := GetLastDate(EncodeDate(Year, Month, Day));
    end;
  end;

  if AState then
    (* Установить последний месяц кваратала *)
    EndQuarter := GetLastDate(GetNextMonth(EndQuarter));
end;

procedure NetwageExit; far;
begin
  ExitProc := SaveExit;
  if Assigned(RVFont) then RVFont.Free;
end;


initialization

  RVFont := TFont.Create;
  RVFont.Name:= 'Pragmatica';
  RVFont.Size:= 8;
  RVFont.Style:= [];
  RVFont.Color:= clWindowText;

  SaveExit := ExitProc;
  ExitProc := @NetwageExit;
end.
