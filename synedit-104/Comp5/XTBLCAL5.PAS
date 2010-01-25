
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xtblcal5.pas

  Abstract

    Part of xTblCal component.

  Author

    Andrei Kireev

  Contact address

  Revisions history

    1.00    09-Sep-1996    andreik    Initial version.
    1.01
    1.02    30-01-1998     andreik    Bug fixed.

--}

unit xTblCal5;

interface

type
  TWorkTime = Double;

const
  Dayoff = -1;
  Holiday = 100;  {!!!}
  DefaultWorkTime: TWorkTime = 8.0;

procedure DecodeWorkTime(AWorkTime: TWorkTime; var H, M: LongInt);
function EncodeWorkTime(H, M: LongInt): TWorkTime;

function FormatWorkTime(AWorkTime: TWorkTime): String;

implementation

uses
  SysUtils;

procedure DecodeWorkTime(AWorkTime: TWorkTime; var H, M: LongInt);
begin
  if AWorkTime < 0 then
    raise Exception.Create('Invalid time value');
  {!!!
  if AWorkTime >= Holiday then
    AWorkTime := AWorkTime - Holiday;
  }
  H := Trunc(AWorkTime);
  M := Round(Frac(AWorkTime) * 60);
end;

function EncodeWorkTime(H, M: LongInt): TWorkTime;
begin
  if (H < 0) or (not (M in [0..59])) then
    raise Exception.Create('Invalid time value');
  Result := H + M / 60;
end;

function FormatWorkTime(AWorkTime: TWorkTime): String;
var
  WorkHours, WorkMinutes: LongInt;
begin
  DecodeWorkTime(AWorkTime, WorkHours, WorkMinutes);
  if WorkMinutes = 0 then
    Result := Format('%d', [WorkHours])
  else if WorkMinutes < 10 then
    Result := Format('%d:0%d', [WorkHours, WorkMinutes])
  else
    Result := Format('%d:%d', [WorkHours, WorkMinutes]);
end;

end.

