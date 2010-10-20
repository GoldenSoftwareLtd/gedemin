unit gsDatePeriod;

interface

uses
  Controls, SysUtils;

type
  TgsDatePeriodKind = (dpkYear, dpkQuarter, dpkMonth, dpkWeek, dpkDay, dpkFree);

  EgsDatePeriod = class(Exception);

  TgsDatePeriod = class(TObject)
  private
    FDate, FEndDate, FMaxDate, FMinDate: TDate;
    FKind: TgsDatePeriodKind;

    procedure Validate;
    procedure SetDate(const Value: TDate);
    procedure SetEndDate(const Value: TDate);
    procedure DecodeOneDate(S: String; out Left, Right: TDate;
      out AKind: TgsDatePeriodKind);
    function GetDurationDays: Integer;
    procedure SetKind(const Value: TgsDatePeriodKind);

  public
    constructor Create;

    procedure Assign(const ASource: TgsDatePeriod);
    function ProcessShortCut(const Key: Char): Boolean;
    function EncodeString: String;
    procedure DecodeString(const AString: String);

    procedure SetPeriod(const AYear: Integer); overload;
    procedure SetPeriod(const AYear, AMonth: Integer); overload;
    procedure SetPeriod(const AYear, AMonth, ADay: Integer); overload;
    procedure SetPeriod(const ADate, AnEndDate: TDate); overload;

    property Kind: TgsDatePeriodKind read FKind write SetKind;
    property MaxDate: TDate read FMaxDate write FMaxDate;
    property MinDate: TDate read FMinDate write FMinDate;
    property Date: TDate read FDate write SetDate;
    property EndDate: TDate read FEndDate write SetEndDate;
    property DurationDays: Integer read GetDurationDays;
  end;

function DateAdd(DatePart: Char; AddNumber: Integer; CurrentDate: TDate): TDate;

implementation

uses
  jclDateTime;

constructor TgsDatePeriod.Create;
begin
  inherited;
  FKind := dpkFree;
end;

function TgsDatePeriod.ProcessShortCut(const Key: Char): boolean;
var
  Year, Month, Day: Word;
  NumberWeek: Integer;
begin
  Result := True;
  DecodeDate(SysUtils.Date, Year, Month, Day);

  case AnsiUpperCase(Key)[1] of
    'Ñ', 'T':
      begin
        FKind := dpkDay;
        FDate := SysUtils.Date;
        FEndDate := FDate;
      end;

    'Â', 'Y':
      begin
        FKind := dpkDay;
        FDate := SysUtils.Date - 1;
        FEndDate := FDate;
      end;

    'Ç', 'O':
      begin
        FKind := dpkDay;
        FDate := SysUtils.Date + 1;
        FEndDate := FDate;
      end;

    'Í', 'W':
      begin
        FKind := dpkWeek;
        NumberWeek := ISOWeekNumber(SysUtils.Now);
        FDate := ISOWeekToDateTime(Year, NumberWeek, 1);
        FEndDate := ISOWeekToDateTime(Year, NumberWeek, 7);
      end;

    'ß', 'L':
      begin
        FKind := dpkWeek;
        NumberWeek := ISOWeekNumber(SysUtils.Now);
        FDate := ISOWeekToDateTime(Year, NumberWeek - 1, 1);
        FEndDate := ISOWeekToDateTime(Year, NumberWeek - 1, 7);
      end;

    'Þ', 'N':
      begin
        FKind := dpkWeek;
        NumberWeek := ISOWeekNumber(SysUtils.Now);
        FDate := ISOWeekToDateTime(Year, NumberWeek + 1, 1);
        FEndDate := ISOWeekToDateTime(Year, NumberWeek + 1, 7);
      end;

    'Ì', 'M':
      begin
        Fkind := dpkMonth;
        FDate := EncodeDate(Year, Month, 1);
        FEndDate := IncMonth(EncodeDate(Year, Month, 1), 1) - 1;
      end;

    'Ë', 'X':
      begin
        FKind := dpkMonth;
        FDate := DateAdd('M', 1, EncodeDate(Year, Month, 1));
        FEndDate := DateAdd('M', 1, FDate) - 1;
      end;

    'Ð', 'H':
      begin
         FKind := dpkMonth;
         FDate := IncMonth(EncodeDate(Year, Month, 1), -1);
         FEndDate := EncodeDate(Year, Month, 1) - 1;
      end;

    'Ê', 'Q':
      begin
        FKind := dpkQuarter;
        case Month of
          1..3:
          begin
            FDate := EncodeDate(Year, 01, 01);
            FEndDate := EncodeDate(Year, 03, 30);
          end;
          4..6:
          begin
            FDate := EncodeDate(Year, 04, 01);
            FEndDate := EncodeDate(Year, 06, 30);
          end;
          7..9:
          begin
            FDate := EncodeDate(Year, 07, 01);
            FEndDate := EncodeDate(Year, 09, 30);
          end;
          10..12:
          begin
            FDate := EncodeDate(Year, 10, 01);
            FEndDate := EncodeDate(Year, 12, 31);
          end;
        end;
      end;

    'È', 'R':
      begin
        FKind := dpkQuarter;
        case Month of
         1..3:
         begin
           FDate := EncodeDate(Year - 1, 10, 01);
           FEndDate := EncodeDate(Year - 1, 12, 31);
         end;
         4..6:
         begin
           FDate := EncodeDate(Year, 01, 01);
           FEndDate := EncodeDate(Year, 03, 31);
         end;
         7..9:
         begin
           FDate := EncodeDate(Year, 04, 01);
           FEndDate := EncodeDate(Year, 06, 30);
         end;
         10..12:
         begin
           FDate := EncodeDate(Year, 07, 01);
           FEndDate := EncodeDate(Year, 09, 30);
         end;
        end
      end;

    'É', 'G':
      begin
        FKind := dpkQuarter;
        case Month of
          1..3:
          begin
            FDate := EncodeDate(Year, 04, 01);
            FEndDate := EncodeDate(Year, 06, 30);
          end;
          4..6:
          begin
            FDate := EncodeDate(Year, 07, 01);
            FEndDate := EncodeDate(Year, 09, 30);
          end;
          7..9:
          begin
            FDate := EncodeDate(Year, 10, 01);
            FEndDate := EncodeDate(Year, 12, 31);
          end;
          10..12:
          begin
            FDate := EncodeDate(Year + 1, 01, 01);
            FEndDate := EncodeDate(Year + 1, 03, 31);
          end;
        end;
      end;

    'Ã', 'A':
      begin
        FKind := dpkYear;
        FDate := EncodeDate(Year, 01, 01);
        FEndDate := EncodeDate(Year, 12, 31);
      end;

    'Î', 'J':
      begin
        FKind := dpkYear;
        FDate := EncodeDate(Year - 1, 01, 01);
        FEndDate := EncodeDate(Year - 1, 12, 31);
      end;

    'Å', 'V':
      begin
        FKind := dpkYear;
        FDate := EncodeDate(Year + 1, 01, 01);
        FEndDate := EncodeDate(Year + 1, 12, 31);
      end;
  else
    Result := False;
  end;
end;

procedure TgsDatePeriod.Assign(const ASource: TgsDatePeriod);
begin
  FKind := ASource.Kind;
  FMaxDate := ASource.MaxDate;
  FMinDate := ASource.MinDate;
  Date := ASource.Date;
  EndDate := ASource.EndDate;
end;

function TgsDatePeriod.EncodeString: String;
begin
  if (FDate = 0) and (FEndDate = 0) then
    Result := ''
  else
    case FKind of
      dpkYear: Result := FormatDateTime('yyyy', FDate);
      dpkMonth: Result := FormatDateTime('mm.yyyy', FDate);
      dpkDay: Result := FormatDateTime('dd.mm.yyyy', FDate);
    else
      Result := FormatDateTime('dd.mm.yyyy', FDate) + '-' +
        FormatDateTime('dd.mm.yyyy', FEndDate);
    end;
end;

procedure TgsDatePeriod.DecodeString(const AString: String);
var
  P: Integer;
  Dummy: TDate;
begin
  P := Pos('-', AString);
  if P = 0 then
    DecodeOneDate(AString, FDate, FEndDate, FKind)
  else
  begin
    DecodeOneDate(Copy(AString, 1, P - 1), FDate, Dummy, FKind);
    DecodeOneDate(Copy(AString, P + 1, 255), Dummy, FEndDate, FKind);

    if (FDate = 0) and (FEndDate <> 0) then
    begin
      FDate := FEndDate;
      FKind := dpkDay;
    end
    else if (FDate <> 0) and (FEndDate = 0) then
    begin
      FEndDate := FDate;
      FKind := dpkDay;
    end else
    begin
      if FDate > FEndDate then
      begin
        Dummy := FDate;
        FDate := FEndDate;
        FEndDate := Dummy;
      end;

      FKind := dpkFree;
    end;  
  end;
end;

function DateAdd(DatePart: Char; AddNumber: Integer; CurrentDate: TDate): TDate;
var
  iYear, iMonth, iDay: Word;
begin
  case UpCase(DatePart) of
    'Y':
      begin
        DecodeDate(CurrentDate, iYear, iMonth, iDay);
        if (iMonth = 2) and IsLeapYear(iYear) and (iDay = 29)
          and (not IsLeapYear(iYear + AddNumber)) then iDay := 28;
        Result := EncodeDate(iYear + AddNumber, iMonth, iDay);
      end;
    'M': Result := IncMonth(CurrentDate, AddNumber);
    'W': Result := DateAdd('D', AddNumber * 7, CurrentDate);
    'D': Result := CurrentDate + AddNumber;
  else
    raise EgsDatePeriod.Create('Invalid date part');
  end;
end;

procedure TgsDatePeriod.Validate;
begin
  if (MaxDate = 0) and (MinDate = 0) then
    exit;

  if (FDate < FMinDate) or (FEndDate > FMaxDate) then
    raise EgsDatePeriod.Create('Out of range');
end;

procedure TgsDatePeriod.SetDate(const Value: TDate);
var
  Y, M, D: Word;
begin
  DecodeDate(Value, Y, M, D);
  case FKind of
    dpkYear:
      if (M <> 1) or (D <> 1) then
        raise EgsDatePeriod.Create('Invalid date period');
    dpkQuarter, dpkMonth:
      if D <> 1 then
        raise EgsDatePeriod.Create('Invalid date period');
    dpkWeek:
      if ISODayOfWeek(Value) <> 1 then
        raise EgsDatePeriod.Create('Invalid date period');
  end;

  FDate := Value;
  Validate;
end;

procedure TgsDatePeriod.SetEndDate(const Value: TDate);
var
  Y, M, D: Word;
begin
  DecodeDate(Value, Y, M, D);
  case FKind of
    dpkYear:
      if (M <> 12) or (D <> 31) then
        raise EgsDatePeriod.Create('Invalid date period');
    dpkQuarter, dpkMonth:
      if Value <> (IncMonth(EncodeDate(Y, M, 1), 1) - 1) then
        raise EgsDatePeriod.Create('Invalid date period');
    dpkWeek:
      if ISODayOfWeek(Value) <> 7 then
        raise EgsDatePeriod.Create('Invalid date period');
  end;

  FEndDate := Value;
  Validate;
end;

procedure TgsDatePeriod.DecodeOneDate(S: String; out Left, Right: TDate;
  out AKind: TgsDatePeriodKind);
var
  B, E, Year, Month, Day: Integer;
  _Y, _M, _D: Word;
begin
  S := Trim(S);

  if S = '' then
  begin
    Left := SysUtils.Date;
    Right := SysUtils.Date;
    AKind := dpkFree;
    exit;
  end;

  DecodeDate(SysUtils.Date, _Y, _M, _D);
  Year := 0;
  Month := 0;
  Day := 0;
  E := Length(S);
  B := E;
  while B >= 0 do
  begin
    if (B = 0) or (S[B] = '.') then
    begin
      if Year = 0 then
        Year := StrToIntDef(Copy(S, B + 1, E - B), 0)
      else if Month = 0 then
        Month := StrToIntDef(Copy(S, B + 1, E - B), 0)
      else if Day = 0 then
        Day := StrToIntDef(Copy(S, B + 1, E - B), 0)
      else
        break;

      E := B - 1;
    end;

    Dec(B);
  end;

  if Year <= 0 then Year := _Y;

  if Month = 0 then
  begin
    if Year in [1..12] then
    begin
      AKind := dpkMonth;
      Month := Year;
      Year := _Y;
      Left := EncodeDate(Year, Month, 1);
      Right := IncMonth(EncodeDate(Year, Month, 1), 1) - 1;
    end else
    begin
      AKind := dpkYear;
      Left := EncodeDate(Year, 1, 1);
      Right := EncodeDate(Year, 12, 31);
    end;
  end else
  begin
    if (Month <= 0) or (Month > 12) then
      Month := _M;
    if Day <= 0 then
    begin
      AKind := dpkMonth;
      Left := EncodeDate(Year, Month, 1);
      Right := IncMonth(EncodeDate(Year, Month, 1), 1) - 1;
    end else
    begin
      AKind := dpkDay;
      if (Day >= 31) and (Month in [4, 6, 9, 11]) then
        Day := 30;
      if (Day > 28) and (Month = 2) and (not IsLeapYear(Year)) then
        Day := 28;
      Left := EncodeDate(Year, Month, Day);
      Right := Left;
    end;
  end;
end;

function TgsDatePeriod.GetDurationDays: Integer;
begin
  Result := Trunc(FEndDate - FDate + 1);
end;

procedure TgsDatePeriod.SetPeriod(const AYear, AMonth: Integer);
begin
  FKind := dpkMonth;
  FDate := EncodeDate(AYear, AMonth, 1);
  FEndDate := IncMonth(EncodeDate(AYear, AMonth, 1), 1) - 1;
  Validate;
end;

procedure TgsDatePeriod.SetPeriod(const AYear: Integer);
begin
  FKind := dpkYear;
  FDate := EncodeDate(AYear, 1, 1);
  FEndDate := EncodeDate(AYear, 12, 31);
  Validate;
end;

procedure TgsDatePeriod.SetPeriod(const ADate, AnEndDate: TDate);
begin
  FKind := dpkFree;
  FDate := ADate;
  FEndDate := AnEndDate;
  Validate;
end;

procedure TgsDatePeriod.SetPeriod(const AYear, AMonth, ADay: Integer);
begin
  FKind := dpkDay;
  FDate := EncodeDate(AYear, AMonth, ADay);
  FEndDate := FDate;
  Validate;
end;

procedure TgsDatePeriod.SetKind(const Value: TgsDatePeriodKind);
var
  Y, M, D: Word;
begin
  if FKind <> Value then
  begin
    FKind := Value;
    DecodeDate(FDate, Y, M, D);
    case FKind of
      dpkYear:
      begin
        FDate := EncodeDate(Y, 1, 1);
        FEndDate := EncodeDate(Y, 12, 31);
      end;

      dpkMonth:
      begin
        FDate := EncodeDate(Y, M, 1);
        FEndDate := IncMonth(EncodeDate(Y, M, 1), 1) - 1;
      end;

      dpkWeek:
      begin
        FDate := FDate - ISODayOfWeek(FDate) + 1;
        FEndDate := FDate + 6;
      end;

      dpkQuarter:
      begin
        case M of
          1..3:
          begin
            FDate := EncodeDate(Y, 1, 1);
            FEndDate := EncodeDate(Y, 3, 31);
          end;
          4..6:
          begin
            FDate := EncodeDate(Y, 4, 1);
            FEndDate := EncodeDate(Y, 6, 30);
          end;
          7..9:
          begin
            FDate := EncodeDate(Y, 7, 1);
            FEndDate := EncodeDate(Y, 9, 30);
          end;
          10..12:
          begin
            FDate := EncodeDate(Y, 10, 1);
            FEndDate := EncodeDate(Y, 12, 31);
          end;
        end;
      end;

      dpkFree: ;
    else
      FEndDate := FDate;
    end;
  end;
end;

end.
