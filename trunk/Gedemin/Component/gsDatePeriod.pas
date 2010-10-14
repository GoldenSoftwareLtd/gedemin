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

  public
    constructor Create;

    procedure Assign(const ASource: TgsDatePeriod);
    function ProcessShortCut(const Key: Char): Boolean;
    function EncodeString: String;
    procedure DecodeString(const AString: String);

    property Kind: TgsDatePeriodKind read FKind write FKind;
    property MaxDate: TDate read FMaxDate write FMaxDate;
    property MinDate: TDate read FMinDate write FMinDate;
    property Date: TDate read FDate write SetDate;
    property EndDate: TDate read FEndDate write SetEndDate;
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

    'Ó', 'J':
      begin
        FKind := dpkYear;
        FDate := EncodeDate(Year - 1, 01, 01);
        FEndDate := EncodeDate(Year - 1, 12, 31);
      end;

    'Ò', 'V':
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
  FDate := ASource.Date;
  FEndDate := ASource.EndDate;
  FMaxDate := ASource.MaxDate;
  FMinDate := ASource.MinDate;
  FKind := ASource.Kind;
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

    if FDate > FEndDate then
    begin
      Dummy := FDate;
      FDate := FEndDate;
      FEndDate := Dummy;
    end;

    FKind := dpkFree;
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
begin
  FDate := Value;
  Validate;
end;

procedure TgsDatePeriod.SetEndDate(const Value: TDate);
begin
  FEndDate := Value;
  Validate;
end;

procedure TgsDatePeriod.DecodeOneDate(S: String; out Left, Right: TDate;
  out AKind: TgsDatePeriodKind);
var
  B, E, Year, Month, Day: Integer;
begin
  S := Trim(S);

  if S = '' then
  begin
    Left := 0;
    Right := 0;
    AKind := dpkFree;
    exit;
  end;

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

  if Year <= 0 then
    raise EgsDatePeriod.Create('Invalid date string')
  else if Year < 70 then
    Year := Year + 2000
  else if Year < 100 then
    Year := Year + 1900;

  if Month = 0 then
  begin
    AKind := dpkYear;
    Left := EncodeDate(Year, 1, 1);
    Right := EncodeDate(Year, 12, 31);
  end else
  begin
    if Day = 0 then
    begin
      AKind := dpkMonth;
      Left := EncodeDate(Year, Month, 1);
      Right := IncMonth(EncodeDate(Year, Month, 1), 1) - 1;
    end else
    begin
      AKind := dpkDay;
      Left := EncodeDate(Year, Month, Day);
      Right := Left;
    end;
  end;
end;

end.
