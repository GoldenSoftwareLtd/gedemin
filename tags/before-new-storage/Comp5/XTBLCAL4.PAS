
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xtblcal4.pas

  Abstract

    Part of xTblCal component.

  Author

    Andrei Kireev

  Contact address

  Revisions history

    1.00    09-Sep-1996    andreik    Initial version.
    1.01    30-Jan-1998    andreik    Bug fixed. 

--}

unit xTblCal4;

interface

type
  TWeekDay = (
    wdSunday,
    wdMonday,
    wdTuesday,
    wdWednesday,
    wdThursday,
    wdFriday,
    wdSaturday);

  TWeekDays = set of TWeekDay;

const
  ShortDayOfWeekNames: array[TWeekDay] of String[2] = (
    'Bc',
    'Ïí',
    'Âò',
    'Ñð',
    '×ò',
    'Ïò',
    'Ñá'
  );

function GetWeekDay(Date: TDateTime): TWeekDay;

implementation

uses
  SysUtils;

function GetWeekDay(Date: TDateTime): TWeekDay;
begin
  Result := TWeekDay(DayOfWeek(Date) - 1);
end;

end.

