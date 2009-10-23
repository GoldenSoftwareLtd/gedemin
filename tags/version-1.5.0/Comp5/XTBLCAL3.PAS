
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xtblcal3.pas

  Abstract

    Part of xTblCal component.

  Author

    Andrei Kireev

  Contact address

  Revisions history

    1.00    09-Sep-1996    andreik    Initial version.
    1.01    30-01-1998     andreik    Bug fixed.

--}

unit xTblCal3;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, xSpin, xTblCal4, xTblCal5;

type
  TCreateTableCalendar = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    edAlias: TEdit;
    edName: TEdit;
    Label2: TLabel;
    DurationLabel1: TLabel;
    DurationLabel2: TLabel;
    DurationLabel3: TLabel;
    GroupBox1: TGroupBox;
    chkMonday: TCheckBox;
    chkTuesday: TCheckBox;
    chkWednesday: TCheckBox;
    chkThursday: TCheckBox;
    chkSunday: TCheckBox;
    chkSaturday: TCheckBox;
    chkFriday: TCheckBox;
    Bevel1: TBevel;
    btnOk: TButton;
    btnCancel: TButton;
    chkHolidays: TCheckBox;
    seYear: TxSpinEdit;
    seDurationMinutes: TxSpinEdit;
    seDurationHours: TxSpinEdit;
    chk1HourLess: TCheckBox;

    procedure FormCreate(Sender: TObject);

  private
    function GetName: String;
    function GetAlias: String;
    function GetYear: Integer;
    function GetWorkTime: TWorkTime;
    function GetDayoffs: TWeekDays;
    function GetHolidays: Boolean;

  public
    property Name: String read GetName;
    property Alias: String read GetAlias;
    property Year: Integer read GetYear;
    property WorkTime: TWorkTime read GetWorkTime;
    property Dayoffs: TWeekDays read GetDayoffs;
    property Holidays: Boolean read GetHolidays;
  end;

var
  CreateTableCalendar: TCreateTableCalendar;

implementation

{$R *.DFM}

function TCreateTableCalendar.GetName: String;
begin
  Result := edName.Text;
  if Result = '' then
    Result := 'без названия';
end;

function TCreateTableCalendar.GetAlias: String;
begin
  Result := edAlias.Text;
end;

function TCreateTableCalendar.GetYear: Integer;
begin
  Result := seYear.IntValue;
end;

function TCreateTableCalendar.GetWorkTime: TWorkTime;
begin
  Result := EncodeWorkTime(seDurationHours.IntValue, seDurationMinutes.IntValue);
end;

function TCreateTableCalendar.GetDayoffs: TWeekDays;
begin
  Result := [];
  if chkMonday.Checked then Include(Result, wdMonday);
  if chkTuesday.Checked then Include(Result, wdTuesday);
  if chkWednesday.Checked then Include(Result, wdWednesday);
  if chkThursday.Checked then Include(Result, wdThursday);
  if chkFriday.Checked then Include(Result, wdFriday);
  if chkSaturday.Checked then Include(Result, wdSaturday);
  if chkSunday.Checked then Include(Result, wdSunday);
end;

function TCreateTableCalendar.GetHolidays: Boolean;
begin
  Result := chkHolidays.Checked;
end;

procedure TCreateTableCalendar.FormCreate(Sender: TObject);
var
  Y, M, D: Word;
begin
  DecodeDate(Now, Y, M, D);
  seYear.IntValue := Y;
end;

end.

