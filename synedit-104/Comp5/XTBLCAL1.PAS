{$DEFINE xTool}

{*******************************************************}
{                                                       }
{       xTool - Component Collection                    }
{                                                       }
{       Copyright (c) 1995,96 Stefan Bother             }
{                                                       }
{*******************************************************}

{++

  Copyright (c) 1996 by Golden Software of Belarus

  Module

    xtblcal1.pas

  Abstract

    Part of xTblCal component.

  Author

    Andrei Kireev

  Contact address

  Revisions history

    1.00    09-Sep-1996    andreik    Initial version.

--}

unit xTblCal1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, xSpin, ExtCtrls, xTblCal5;

type
  TRegion = (rThisDayOnly, rThisWeek, rThisMonth, rThisQuarter,
    rThisYear, rUntilThisYearEnd, rSuchDaysOfWeek);

type
  TDayProperties = class(TForm)
    rgDayType: TRadioGroup;
    DurationLabel1: TLabel;
    rgRegion: TRadioGroup;
    DurationLabel2: TLabel;
    DurationLabel3: TLabel;
    Button1: TButton;
    Button2: TButton;
    chkThisDayOnly: TCheckBox;
    Bevel1: TBevel;
    lblDate: TLabel;
    seDurationMinutes: TxSpinEdit;
    seDurationHours: TxSpinEdit;

    procedure rgDayTypeClick(Sender: TObject);
    procedure chkThisDayOnlyClick(Sender: TObject);

  private
    FDate: TDateTime;

    function GetDate: TDateTime;
    procedure SetDate(ADate: TDateTime);
    function GetIsWorkDay: Boolean;
    procedure SetIsWorkDay(AnIsWorkDay: Boolean);
    function GetWorkTime: TWorkTime;
    procedure SetWorkTime(AWorkTime: TWorkTime);
    function GetRegion: TRegion;
    procedure SetRegion(ARegion: TRegion);

  public
    constructor Create(AnOwner: TComponent); override;

    property Date: TDateTime read GetDate write SetDate;
    property IsWorkDay: Boolean read GetIsWorkDay write SetIsWorkDay;
    property WorkTime: TWorkTime read GetWorkTime write setWorkTime;
    property Region: TRegion read GetRegion write SetRegion;
  end;

var
  DayProperties: TDayProperties;

implementation

{$R *.DFM}

const
  LongWeekDaysNames: array[1..7] of String = (
    'Воскресенье',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота'
  );

  MonthNames: array[1..12] of String = (
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря'
  );

constructor TDayProperties.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FDate := -1;
end;

procedure TDayProperties.rgDayTypeClick(Sender: TObject);
var
  B: Boolean;
begin
  B := rgDayType.ItemIndex = 0;
  DurationLabel1.Enabled := B;
  DurationLabel2.Enabled := B;
  DurationLabel3.Enabled := B;
  seDurationHours.Enabled := B;
  seDurationMinutes.Enabled := B;
end;

procedure TDayProperties.chkThisDayOnlyClick(Sender: TObject);
begin
  rgRegion.Enabled := not chkThisDayOnly.Checked;
end;

function TDayProperties.GetDate: TDateTime;
begin
  Result := FDate;
end;

procedure TDayProperties.SetDate(ADate: TDateTime);
var
  Y, M, D: Word;
begin
  if ADate <= 0 then
    raise Exception.Create('Invalid date specified');

  DecodeDate(ADate, Y, M, D);
  lblDate.Caption := Format('%s, %d %s %dг.',
    [LongWeekDaysNames[DayOfWeek(ADate)], D, MonthNames[M], Y]);

  FDate := ADate;
end;

function TDayProperties.GetIsWorkDay: Boolean;
begin
  Result := rgDayType.ItemIndex = 0;
end;

procedure TDayProperties.SetIsWorkDay(AnIsWorkDay: Boolean);
begin
  if AnIsWorkDay then
    rgDayType.ItemIndex := 0
  else
    rgDayType.ItemIndex := 1;
end;

function TDayProperties.GetWorkTime: TWorkTime;
begin
  if IsWorkDay then
    Result := EncodeWorkTime(seDurationHours.IntValue, seDurationMinutes.IntValue)
  else
    raise Exception.Create('Not a workday');
end;

procedure TDayProperties.SetWorkTime(AWorkTime: TWorkTime);
var
  WorkHours, WorkMinutes: LongInt;
begin
  DecodeWorkTime(AWorkTime, WorkHours, WorkMinutes);
  seDurationHours.Value := WorkHours;
  seDurationMinutes.Value := WorkMinutes;
end;

function TDayProperties.GetRegion: TRegion;
begin
  if chkThisDayOnly.Checked then
    Result := rThisDayOnly
  else
    Result := TRegion(rgRegion.ItemIndex + 1);
end;

procedure TDayProperties.SetRegion(ARegion: TRegion);
begin
  if ARegion = rThisDayOnly then
    chkThisDayOnly.Checked := True
  else
  begin
    chkThisDayOnly.Checked := False;
    rgRegion.ItemIndex := Ord(ARegion) - 1;
  end;
end;

end.

