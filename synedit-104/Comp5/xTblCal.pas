
{++

  Copyright (c) 1996-98 by Golden Software of Belarus

  Module

    xtblcal.pas

  Abstract

    Table-calendar component.

  Author

    Andrei Kireev (23-Aug-96)

  Contact address


  Uses

    Holiday from xTool v1.08.

  Revisions history

    1.00    09-Sep-96    andreik    Initial version.
    1.02

--}

unit xTblCal;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DBTables, DB, StdCtrls, Holidays, xTblCal4, xTblCal5;

const
  DaysInYear = 366; { leap year }

type
  PYearDays = ^TYearDays;
  TYearDays = array[1..DaysInYear] of TWorkTime;

type
  TxTableCalendarData = class(TComponent)
  private
    Table: TTable;
    YearDays: TYearDays;
    ListOfTableCalendars: TList;

    FStartDate, FEndDate: TDateTime;
    FStartDateExclusive, FEndDateExclusive: Boolean;
    FEOP, FBOP: Boolean;
    FDay: TDateTime;
    FAutoSave: Boolean;

    FOnOpened, FOnClosed: TNotifyEvent;

    function GetActive: Boolean;
    procedure SetDatabaseName(const DatabaseName: TFileName);
    function GetDatabaseName: TFileName;
    procedure SetTableName(const TableName: TFileName);
    function GetTableName: TFileName;

    function GetCalendarKey: LongInt;
    function GetCalendarIndex: LongInt;
    procedure SetCalendarIndex(Index: LongInt);
    function GetCalendarYear: Integer;
    procedure SetCalendarYear(const AYear: Integer);
    function GetCalendarAlias: String;
    procedure SetCalendarAlias(const AnAlias: String);
    function GetCalendarName: String;
    procedure SetCalendarName(const AName: String);
    function GetCalendarFirstDay: TDateTime;
    function GetCalendarLastDay: TDateTime;
    function GetCalendarCount: LongInt;

    function GetDay: TDateTime;
    procedure SetDay(ADay: TDateTime);
    function GetDayOrd: Integer;
    procedure SetDayOrd(ADayOrd: Integer);
    function GetWeekDay: TWeekDay;
    function GetDayData: TDateTime;
    function GetIsWorkDay: Boolean;
    procedure SetIsWorkDay(AnIsWorkDay: Boolean);
    function GetIsHoliday: Boolean;
    procedure SetIsHoliday(AnIsHoliday: Boolean);
    function GetWorkTime: TWorkTime;
    procedure SetWorkTime(AWorkTime: TWorkTime);

    procedure SetStartDate(AStartDate: TDateTime);
    procedure SetEndDate(AnEndDate: TDateTime);

    procedure TestDateInterval;

    procedure LoadYearDays;

{    procedure DoOnHolidayCalcDays(Sender: TObject; Year: Integer;
      Items: THolidayDefs);}

  protected
    procedure Loaded; override;

    procedure RegisterTableCalendar(ATableCalendar: TComponent);
    procedure UnRegisterTableCalendar(ATableCalendar: TComponent);
    procedure UpdateTableCalendars;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Open;
    procedure Close;

    procedure CommitYearDays;

    procedure AppendCalendar(AYear: Integer; const AnAlias, AName: String;
      SetHolidays: Boolean);
    procedure DeleteCalendar;
    procedure CopyCalendar;
    function FindKey(Key: LongInt): Boolean;

    function GetBookmark: TBookmark;
    procedure GotoBookmark(Bookmark: TBookmark);
    procedure FreeBookmark(Bookmark: TBookmark);

    procedure FirstCalendar;
    procedure LastCalendar;
    procedure NextCalendar;
    procedure PriorCalendar;
    function EOF: Boolean;
    function BOF: Boolean;

    procedure First;
    procedure Last;
    procedure Next;
    procedure Prior;
    function EOP: Boolean;
    function BOP: Boolean;

    function GetDaysBetween: Integer;
    function GetWorkDaysBetween: Integer;
    function GetWorkTimeBetween: TWorkTime;
    function GetWeekDaysBetween(WeekDay: TWeekDay): Integer;
    function GetHospitalDaysBetween: Integer;
    function GetHospitalTimeBetween: TWorkTime;
    function GetVacationDaysBetween: Integer;

    function EncodeDate(AMonth, ADay: Integer): TDateTime;

    property Active: Boolean read GetActive;
    property AutoSave: Boolean read FAutoSave write FAutoSave;

    property CalendarKey: LongInt read GetCalendarKey;
    property CalendarIndex: LongInt read GetCalendarIndex write SetCalendarIndex;
    property CalendarYear: Integer read GetCalendarYear write SetCalendarYear;
    property CalendarName: String read GetCalendarName write SetCalendarName;
    property CalendarAlias: String read GetCalendarAlias write SetCalendarAlias;
    property CalendarFirstDay: TDateTime read GetCalendarFirstDay;
    property CalendarLastDay: TDateTime read GetCalendarLastDay;
    property CalendarCount: LongInt read GetCalendarCount;

    property Day: TDateTime read GetDay write SetDay;
    property DayOrd: Integer read GetDayOrd write SetDayOrd;
    property WeekDay: TWeekDay read GetWeekDay;
    property DayData: TDateTime read GetDayData;
    property IsWorkDay: Boolean read GetIsWorkDay write SetIsWorkDay;
    property IsHoliday: Boolean read GetIsHoliday write SetIsHoliday;
    property WorkTime: TWorkTime read GetWorkTime write SetWorkTime;

    property StartDate: TDateTime read FStartDate write SetStartDate;
    property EndDate: TDateTime read FEndDate write SetEndDate;
    property StartDateExclusive: Boolean read FStartDateExclusive
      write FStartDateExclusive;
    property EndDateExclusive: Boolean read FEndDateExclusive
      write FEndDateExclusive;

  published
    property DatabaseName: TFileName read GetDatabaseName write SetDatabaseName;
    property TableName: TFileName read GetTableName write SetTableName;

    property OnOpened: TNotifyEvent read FOnOpened write FOnOpened;
    property OnClosed: TNotifyEvent read FOnClosed write FOnClosed;
  end;

  ETableCalendarError = class(Exception);

const
  WM_CELLPRESS = WM_USER + 17;

type
  TSeason = (sWinter, sSpring, sSummer, sAutumn);
  TMonth = (mJan, mFeb, mMar, mApr, mMay, mJun, mJul, mAug,
    mSep, mOct, mNov, mDec);
  TQuarter = (qFirst, qSecond, qThird, qFourth);

type
  TCell = class(TGraphicControl)
  protected
    AllowPress: Boolean;
    Down: Boolean;

    procedure Paint; override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState;
      X, Y: Integer); override;

    function DX: Integer;
    function DY: Integer;
    function DrawButton: TRect;

  public
    constructor Create(AnOwner: TComponent); override;
  end;

type
  TIconCell = class(TCell)
  private
    FIcon: TIcon;

    procedure SetIcon(AnIcon: TIcon);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

    property Icon: TIcon read FIcon write SetIcon;
  end;

type
  TMonthCell = class(TIconCell)
  private
    FMonth: TMonth;
    FDays, FWorkDays: Integer;
    FWorkTime: TWorkTime;

    procedure SetMonth(AMonth: TMonth);
    procedure SetParam(Index: Integer; Value: Integer);
    procedure SetWorkTime(AWorkTime: TWorkTime);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

    property Month: TMonth read FMonth write SetMonth;
    property Days: Integer index 1 read FDays write SetParam;
    property WorkDays: Integer index 2 read FWorkDays write SetParam;
    property WorkTime: TWorkTime read FWorkTime write SetWorkTime;
  end;

type
  TQuarterCell = class(TIconCell)
  private
    FQuarter: TQuarter;
    FDays, FWorkDays: Integer;
    FWorkTime: TWorkTime;

    procedure SetQuarter(AQuarter: TQuarter);
    procedure SetParam(Index: Integer; Value: Integer);
    procedure SetWorkTime(AWorkTime: TWorkTime);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

    property Quarter: TQuarter read FQuarter write SetQuarter;
    property Days: Integer index 1 read FDays write SetParam;
    property WorkDays: Integer index 2 read FWorkDays write SetParam;
    property WorkTime: TWorkTime read FWorkTime write SetWorkTime;
  end;

type
  TDayCell = class(TIconCell)
  private
    FDay: TDateTime;
    FWorkTime: TWorkTime;
    FIsWorkDay: Boolean;

    procedure SetDay(ADay: TDateTime);
    procedure SetWorkTime(AWorkTime: TWorkTime);
    procedure SetIsWorkDay(AnIsWorkDay: Boolean);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

    property Day: TDateTime read FDay write SetDay;
    property WorkTime: TWorkTime read FWorkTime write SetWorkTime;
    property IsWorkDay: Boolean read FIsWorkDay write SetIsWorkDay;
  end;

type
  TTextCell = class(TCell)
  public
    constructor Create(AnOwner: TComponent); override;
  end;

type
  THelpCell = class(TTextCell)
  protected
    procedure Paint; override;
  end;

type
  TDayHelpCell = class(TTextCell)
  protected
    procedure Paint; override;
  end;

type
  TNameCell = class(TCell)
  private
    FName: String;

    procedure SetName(const AName: String);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

    property Name: String read FName write SetName;
  end;

type
  TMonthNameCell = class(TNameCell)
  private
    FIcon: TIcon;

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

type
  TBottomCell = class(TTextCell)
  private
    FDays, FWorkDays: Integer;
    FWorkTime: TWorkTime;

    procedure SetParam(Index: Integer; Param: Integer);
    procedure SetWorkTime(AWorkTime: TWorkTime);

  protected
    procedure Paint; override;

  public
    property Days: Integer index 1 read FDays write SetParam;
    property WorkDays: Integer index 2 read FWorkDays write SetParam;
    property WorkTime: TWorkTime read FWorkTime write SetWorkTime;
  end;

type
  TToolBar = class(TCell)
  private
    FComboBox: TComboBox;
    btnAdd, btnCopy, btnDelete: TButton;

    procedure DoOnAddClick(Sender: TObject);
    procedure DoOnCopyClick(Sender: TObject);
    procedure DoOnDeleteClick(Sender: TObject);
    procedure DoOnComboChange(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); override;

    procedure Update(ACalendarData: TxTableCalendarData);
    procedure SetSize(ALeft, ATop, AWidth, AHeight: Integer); 
  end;

type
  TBaseCalendar = class(TCustomControl)
  private
    FCalendarData: TxTableCalendarData;

    procedure SetCalendarData(ACalendarData: TxTableCalendarData);

  protected
    procedure SetSize(ALeft, ATop, AWidth, AHeight: Integer); virtual;
    procedure UpdateButtons; virtual; abstract;

    property CalendarData: TxTableCalendarData read FCalendarData
      write SetCalendarData;
  end;

type
  TYearCalendar = class(TBaseCalendar)
  private
    MonthIcons: array[TSeason] of TIcon;
    MonthButtons: array[TMonth] of TMonthCell;
    QuarterIcons: array[TQuarter] of TIcon;
    QuarterButtons: array[TQuarter] of TQuarterCell;
    HelpButtons: array[TQuarter] of THelpCell;
    Toolbar: TToolbar;
    NameButton: TNameCell;
    BottomButton: TBottomCell;

  protected
    procedure SetSize(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure UpdateButtons; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

type
  TMonthCalendar = class(TBaseCalendar)
  private
    HolidayIcon: TIcon;
    WorkdayIcon: TIcon;
    DayButtons: array[1..31] of TDayCell;
    HelpButtons: array[1..6] of TCell;
    NameButton: TMonthNameCell;
    BottomButton: TBottomCell;

    FMonth: TMonth;
    MonthAssigned: Boolean;
    DaysInMonth: Integer;

    procedure SetMonth(AMonth: TMonth);

  protected
    procedure SetSize(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure UpdateButtons; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property Month: TMonth read FMonth write SetMonth;
  end;

type
  TxTableCalendar = class(TCustomControl)
  private
    FCalendarData: TxTableCalendarData;
    Calendar: TBaseCalendar;
    OldOnCalendarDataOpened: TNotifyEvent;

    procedure SetCalendarData(ACalendarData: TxTableCalendarData);

    procedure DoOnCalendarDataOpened(Sender: TObject);

  protected
    procedure Loaded; override;
    procedure TableCalendarDataChanged;

    procedure WMSize(var Message: TMessage);
      message WM_SIZE;

    procedure WMCellPress(var Message: TMessage);
      message WM_CELLPRESS;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property Align;
    property Width;
    property Height;
    property Font;

    property CalendarData: TxTableCalendarData read FCalendarData
      write SetCalendarData;
  end;

procedure Register;

implementation

{$R XTBLCAL.RES}

uses
  ExtCtrls, DBIProcs, DBITypes, xTblCal1, xTblCal2, xTblCal3;

const
  MonthNames: array[TMonth] of String[15] = (
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь'
  );

  Gap = 5;

const
  cmAdd = 1;
  cmCopy = 2;
  cmDel = 3;
  cmCombo = 4;

const
  crFinger = 17779;

{ Auxiliry routines --------------------------------------}

function GetSeason(Month: TMonth): TSeason;
begin
  if Month = mDec then Result := sWinter
    else Result := TSeason((Ord(Month) + 1) div 3);
end;

function GetQuarter(Month: TMonth): TQuarter;
begin
  Result := TQuarter(Ord(Month) div 3);
end;

function GetQuarterRoman(Quarter: TQuarter): String;
begin
  case Quarter of
    qFirst: Result := 'I';
    qSecond: Result := 'II';
    qThird: Result := 'III';
    qFourth: Result := 'IV';
  end;
end;

function GetMonthOrd(M: TMonth): Integer;
begin
  Result := Ord(M) + 1;
end;

procedure GetWeek(Day: TDateTime; var StartDate, EndDate: TDateTime);
var
  D, M, Y, _D, _M, _Y: Word;
begin
  DecodeDate(Day, Y, M, D);

  StartDate := Day;
  DecodeDate(StartDate, _Y, _M, _D);
  while (DayOfWeek(StartDate) <> 2)
    and (_Y = Y) and (_M = M) do
  begin
    StartDate := StartDate - 1;
    DecodeDate(StartDate, _Y, _M, _D);
  end;
  if (_Y <> Y) or (_M <> M) then
    StartDate := StartDate + 1;

  EndDate := Day;
  DecodeDate(EndDate, _Y, _M, _D);
  while (DayOfWeek(EndDate) <> 1)
    and (_Y = Y) and (_M = M) do
  begin
    EndDate := EndDate + 1;
    DecodeDate(EndDate, _Y, _M, _D);
  end;
  if (_Y <> Y) or (_M <> M) then
    EndDate := EndDate - 1;
end;

{ TxTableCalendarData ------------------------------------}

constructor TxTableCalendarData.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Table := TTable.Create(Self);
  ListOfTableCalendars := TList.Create;

  FAutoSave := True;
  FStartDate := 0;
  FEndDate := 0;
  FStartDateExclusive := False;
  FEndDateExclusive := True;
  FDay := 0;
  FEOP := False;
  FBOP := False;
end;

destructor TxTableCalendarData.Destroy;
var
  I: Integer;
begin
  Close;
  Table.Free;

  { disconnect all associated controls }
  for I := 0 to ListOfTableCalendars.Count - 1 do
  begin
    try
      TxTableCalendar(ListOfTableCalendars[I]).CalendarData := nil;
    except
      on Exception do ;
    end;
  end;

  ListOfTableCalendars.Free;
  inherited Destroy;
end;

procedure TxTableCalendarData.Loaded;
begin
  inherited Loaded;
  Open;
end;

procedure TxTableCalendarData.RegisterTableCalendar(ATableCalendar: TComponent);
var
  I: Integer;
begin
  if not (ATableCalendar is TxTableCalendar) then
    raise ETableCalendarError.Create('Not a table calendar');

  for I := 0 to ListOfTableCalendars.Count - 1 do
  begin
    if ListOfTableCalendars[I] = ATableCalendar then
      exit; { already in the list }
  end;

  ListOfTableCalendars.Add(ATableCalendar);
end;

procedure TxTableCalendarData.UnRegisterTableCalendar(ATableCalendar: TComponent);
var
  I: Integer;
begin
  for I := 0 to ListOfTableCalendars.Count - 1 do
  begin
    if ListOfTableCalendars[I] = ATableCalendar then
    begin
      ListOfTableCalendars.Remove(ATableCalendar);
      ListOfTableCalendars.Pack;
      exit;
    end;
  end;
end;

procedure TxTableCalendarData.UpdateTableCalendars;
var
  I: Integer;
begin
  for I := 0 to ListOfTableCalendars.Count - 1 do
  begin
    if ListOfTableCalendars[I] <> nil then
      TxTableCalendar(ListOfTableCalendars[I]).TableCalendarDataChanged;
  end;
end;

procedure TxTableCalendarData.Open;
var
  _Y, _M, _D: Word;
begin
  if not Table.Active then
  begin
    Table.Open;
    Table.First;
  end;

  if Table.RecordCount > 0 then
    LoadYearDays
  else
  begin
    SysUtils.DecodeDate(Now, _Y, _M, _D);
    AppendCalendar(_Y, '1', 'односменный', True);
    StartDate := EncodeDate(1, 1);
    StartDateExclusive := False;
    EndDate := EncodeDate(12, 31);
    EndDateExclusive := False;
    First;
    while not EOP do
    begin
      if WeekDay in [wdSaturday, wdSunday] then
        IsWorkDay := False;
      Next;
    end;
  end;

  if Assigned(FOnOpened) then
    FOnOpened(Self);
end;

procedure TxTableCalendarData.Close;
begin
  Table.Close;
  if Assigned(FOnClosed) then
    FOnClosed(Self);
end;

procedure TxTableCalendarData.AppendCalendar(AYear: Integer;
  const AnAlias, AName: String; SetHolidays: Boolean);
var
  I: LongInt;
  F: TBlobStream;
{  Holiday: THoliday;}
  OldAutoSave: Boolean;
begin
  Table.Append;

  Table.FieldByName('CalendarYear').AsInteger := AYear;
  Table.FieldByName('CalendarAlias').AsString := AnAlias;
  Table.FieldByName('CalendarName').AsString := AName;

  F := TBlobStream.Create(Table.FieldByName('CalendarData') as TBlobField, bmWrite);
  OldAutoSave := AutoSave;
  AutoSave := False;
  try
    for I := 1 to DaysInYear do
      YearDays[I] := EncodeWorkTime(8, 0);

    if SetHolidays then
    begin
{      Holiday := THoliday.Create(Self);
      try
        Holiday.OnCalcDays := DoOnHolidayCalcDays;
        Holiday.Year := AYear;}
         { must follow OnCalcDays }

{        StartDate := EncodeDate(1, 1);
        StartDateExclusive := False;
        EndDate := EncodeDate(12, 31);
        EndDateExclusive := False;

        for I := 0 to Holiday.Holidays.Count - 1 do
        begin
          Day := Holiday.Holidays.Items[I].Date;
          IsWorkDay := False;
        end;
      finally
        Holiday.Free;
      end;}
    end;

    F.Write(YearDays, SizeOf(YearDays));
  finally
    F.Free;
    AutoSave := OldAutoSave;
  end;

  try
    I := CalendarKey + 1;
  except
    I := 0;
  end;

  Table.FieldByName('CalendarKey').AsInteger := I;

  while True do
  begin
    try
      Table.Post;
    except
      on EDatabaseError do
      begin
        Inc(I);
        Table.FieldByName('CalendarKey').AsInteger := I;
        continue;
      end;
    end;
    break;
  end;

  UpdateTableCalendars;
end;

procedure TxTableCalendarData.DeleteCalendar;
begin
  Table.Delete;
  UpdateTableCalendars;
end;

procedure TxTableCalendarData.CopyCalendar;
var
  P: PYearDays;
begin
  P := New(PYearDays);
  try
    P^ := YearDays;
    AppendCalendar(CalendarYear, CalendarAlias, CalendarName, False);
    YearDays := P^;
    CommitYearDays;
  finally
    Dispose(P);
  end;

  UpdateTableCalendars;
end;

function TxTableCalendarData.FindKey(Key: LongInt): Boolean;
var
  BlobStream: TBlobStream;
begin
  Result := Table.FindKey([Key]);

  if Result then
    LoadYearDays;

  UpdateTableCalendars;
end;

function TxTableCalendarData.GetBookmark: TBookmark;
begin
  Result := Table.GetBookmark;
end;

procedure TxTableCalendarData.GoToBookmark(Bookmark: TBookmark);
begin
  Table.GoToBookmark(Bookmark);
end;

procedure TxTableCalendarData.FreeBookmark(Bookmark: TBookmark);
begin
  Table.FreeBookmark(Bookmark);
end;

procedure TxTableCalendarData.FirstCalendar;
begin
  Table.First;
end;

procedure TxTableCalendarData.LastCalendar;
begin
  Table.Last;
end;

procedure TxTableCalendarData.NextCalendar;
begin
  Table.Next;
end;

procedure TxTableCalendarData.PriorCalendar;
begin
  Table.Prior;
end;

function TxTableCalendarData.EOF: Boolean;
begin
  Result := Table.EOF;
end;

function TxTableCalendarData.BOF: Boolean;
begin
  Result := Table.BOF;
end;

procedure TxTableCalendarData.First;
begin
  TestDateInterval;

  if FStartDateExclusive then
    FDay := FStartDate + 1
  else
    FDay := FStartDate;

  FEOP := (FEndDateExclusive and (FDay = FEndDate)) or
    ((not FEndDateExclusive) and (FDay > FEndDate));

  FBOP := True;
end;

procedure TxTableCalendarData.Last;
begin
  TestDateInterval;

  if FEndDateExclusive then
    FDay := FEndDate - 1
  else
    FDay := FEndDate;

  FBOP := (FStartDateExclusive and (FDay = FStartDate)) or
    ((not FStartDateExclusive) and (FDay < FStartDate));

  FEOP := True;
end;

procedure TxTableCalendarData.Next;
begin
  TestDateInterval;

  if EOP then
    raise ETableCalendarError.Create('End of period');

  FDay := FDay + 1;

  FEOP := (FEndDateExclusive and (FDay = FEndDate)) or
    ((not FEndDateExclusive) and (FDay > FEndDate));

  FBOP := False;
end;

procedure TxTableCalendarData.Prior;
begin
  TestDateInterval;

  if BOP then
    raise ETableCalendarError.Create('Begining of period');

  FDay := FDay - 1;

  FBOP := (FStartDateExclusive and (FDay = FStartDate)) or
    ((not FStartDateExclusive) and (FDay < FStartDate));

  FEOP := False;
end;

function TxTableCalendarData.EOP: Boolean;
begin
  TestDateInterval;
  Result := FEOP;
end;

function TxTableCalendarData.BOP: Boolean;
begin
  TestDateInterval;
  Result := FBOP;
end;

function TxTableCalendarData.GetDaysBetween: Integer;
begin
  Result := 0;
  First;
  while not EOP do
  begin
    Inc(Result);
    Next;
  end;
end;

function TxTableCalendarData.GetWorkDaysBetween: Integer;
begin
  Result := 0;
  First;
  while not EOP do
  begin
    if IsWorkDay then Inc(Result);
    Next;
  end;
end;

function TxTableCalendarData.GetWorkTimeBetween: TWorkTime;
begin
  Result := 0;
  First;
  while not EOP do
  begin
    if IsWorkDay then
      Result := Result + WorkTime;
    Next;
  end;
end;

function TxTableCalendarData.GetWeekDaysBetween(WeekDay: TWeekDay): Integer;
begin
  Result := 0;
  First;
  while not EOP do
  begin
    if DayOfWeek(Day) = Ord(WeekDay) + 1 then Inc(Result);
    Next;
  end;
end;

function TxTableCalendarData.GetHospitalDaysBetween: Integer;
begin
  Result := 0;
  First;
  while not EOP do
  begin
    if IsWorkDay {and (not (xTblCal4.GetWeekDay(Day) in [wdSunday, wdSaturday]))} then
      Inc(Result);
    Next;
  end;
end;

function TxTableCalendarData.GetHospitalTimeBetween: TWorkTime;
begin
  Result := 0;
  First;
  while not EOP do
  begin
    if IsWorkDay {and (not (xTblCal4.GetWeekDay(Day) in [wdSunday, wdSaturday]))} then
      Result := Result + WorkTime;
    Next;
  end;
end;

function TxTableCalendarData.GetVacationDaysBetween: Integer;
begin
  Result := 0;
  First;
  while not EOP do
  begin
    if IsWorkDay or (xTblCal4.GetWeekDay(Day) = wdSaturday) then
      Inc(Result);
    Next;
  end;
end;

function TxTableCalendarData.EncodeDate(AMonth, ADay: Integer): TDateTime;
begin
  Result := SysUtils.EncodeDate(CalendarYear, AMonth, ADay);
end;

function TxTableCalendarData.GetActive: Boolean;
begin
  Result := Table.Active;
end;

procedure TxTableCalendarData.SetDatabaseName(const DatabaseName: TFileName);
begin
  Table.DatabaseName := DatabaseName;
end;

function TxTableCalendarData.GetDatabaseName: TFileName;
begin
  Result := Table.DatabaseName;
end;

procedure TxTableCalendarData.SetTableName(const TableName: TFileName);
begin
  Table.TableName := TableName;
end;

function TxTableCalendarData.GetTableName: TFileName;
begin
  Result := Table.TableName;
end;

function TxTableCalendarData.GetCalendarKey: LongInt;
begin
  if not Table.Active then
    raise ETableCalendarError.Create('Dataset not ready');
  Result := Table.FieldByName('CalendarKey').AsInteger;
end;

function TxTableCalendarData.GetCalendarIndex: LongInt;
var
  I: LongInt;
begin
  if not Table.Active then
    raise ETableCalendarError.Create('Dataset not ready');
  DbiGetSeqNo(Table.Handle, I);
  Result := I - 1;
end;

procedure TxTableCalendarData.SetCalendarIndex(Index: LongInt);
begin
  if not Table.Active then
    raise ETableCalendarError.Create('Dataset not ready');

  if (Index < 0) or (Index >= Table.RecordCount) then
    raise ETableCalendarError.Create('Invalid index');

  Table.First;
  while Index > 0 do
  begin
    Table.Next;
    Dec(Index);
  end;

  LoadYearDays;
end;

function TxTableCalendarData.GetCalendarYear: Integer;
begin
  if not Table.Active then
    raise ETableCalendarError.Create('Dataset not ready');
  Result := Table.FieldByName('CalendarYear').AsInteger;
end;

procedure TxTableCalendarData.SetCalendarYear(const AYear: Integer);
begin
  Table.Edit;
  Table.FieldByName('CalendarYear').AsInteger := AYear;
  Table.Post;
end;

function TxTableCalendarData.GetCalendarName: String;
begin
  if not Table.Active then
    raise ETableCalendarError.Create('Dataset not ready');
  Result := Table.FieldByName('CalendarName').AsString;
end;

procedure TxTableCalendarData.SetCalendarName(const AName: String);
begin
  Table.Edit;
  Table.FieldByName('CalendarName').AsString := AName;
  Table.Post;
end;

function TxTableCalendarData.GetCalendarAlias: String;
begin
  if not Table.Active then
    raise ETableCalendarError.Create('Dataset not ready');
  Result := Table.FieldByName('CalendarAlias').AsString;
end;

procedure TxTableCalendarData.SetCalendarAlias(const AnAlias: String);
begin
  Table.Edit;
  Table.FieldByName('CalendarAlias').AsString := AnAlias;
  Table.Post;
end;

function TxTableCalendarData.GetCalendarFirstDay: TDateTime;
begin
  Result := SysUtils.EncodeDate(CalendarYear, 1, 1);
end;

function TxTableCalendarData.GetCalendarLastDay: TDateTime;
begin
  Result := SysUtils.EncodeDate(CalendarYear, 12, 31);
end;

function TxTableCalendarData.GetCalendarCount: LongInt;
begin
  Result := Table.RecordCount;
end;

function TxTableCalendarData.GetDay: TDateTime;
begin
  TestDateInterval;
  Result := FDay;
end;

procedure TxTableCalendarData.SetDay(ADay: TDateTime);
begin
  TestDateInterval;
  if (ADay >= StartDate) and (ADay <= EndDate) then
    FDay := ADay
  else
    raise ETableCalendarError.Create('Day is not within range');
end;

function TxTableCalendarData.GetDayOrd;
begin
  Result := Round(Day - CalendarFirstDay) + 1;
end;

procedure TxTableCalendarData.SetDayOrd(ADayOrd: Integer);
begin
  if (ADayOrd <= 0) or (ADayOrd > DaysInYear) then
    raise ETableCalendarError.Create('Invalid day specified');
  FDay := CalendarFirstDay + ADayOrd - 1;
end;

function TxTableCalendarData.GetWeekDay: TWeekDay;
begin
  Result := TWeekDay(DayOfWeek(Day) - 1);
end;

function TxTableCalendarData.GetDayData: TDateTime;
begin
{  TestDateInterval; }
  Result := YearDays[DayOrd];
end;

function TxTableCalendarData.GetIsWorkDay: Boolean;
begin
{  TestDateInterval; }
  Result := YearDays[DayOrd] > 0;
end;

procedure TxTableCalendarData.SetIsWorkDay(AnIsWorkDay: Boolean);
begin
  if AnIsWorkDay then
    YearDays[DayOrd] := DefaultWorkTime
  else
    YearDays[DayOrd] := Dayoff;

  if FAutoSave then CommitYearDays;
end;

{!!!}

function TxTableCalendarData.GetIsHoliday: Boolean;
begin
{  TestDateInterval; }
  Result := YearDays[DayOrd] >= xTblCal5.Holiday;
end;

procedure TxTableCalendarData.SetIsHoliday(AnIsHoliday: Boolean);
begin
  if AnIsHoliday then
    YearDays[DayOrd] := xTblCal5.Holiday;
{  else
    YearDays[DayOrd] := Dayoff; }

  if FAutoSave then CommitYearDays;
end;

function TxTableCalendarData.GetWorkTime: TWorkTime;
begin
  if YearDays[DayOrd] <= 0 then
    raise ETableCalendarError.Create('Not a workday');
  Result := YearDays[DayOrd];
end;

procedure TxTableCalendarData.SetWorkTime(AWorkTime: TWorkTime);
begin
  YearDays[DayOrd] := AWorkTime;
  if FAutoSave then CommitYearDays;
end;

procedure TxTableCalendarData.SetStartDate(AStartDate: TDateTime);
begin
  if AStartDate < CalendarFirstDay then
    raise ETableCalendarError.Create('Invalid start date');
  FStartDate := AStartDate;
end;

procedure TxTableCalendarData.SetEndDate(AnEndDate: TDateTime);
begin
  if AnEndDate > CalendarLastDay then
    raise ETableCalendarError.Create('Invalid end date');
  FEndDate := AnEndDate;
end;

procedure TxTableCalendarData.TestDateInterval;
var
  I: Integer;
begin
  I := Round(EndDate - StartDate);
  if StartDateExclusive and EndDateExclusive then
    Dec(I)
  else if not (StartDateExclusive or EndDateExclusive) then
    Inc(I);
  if I <= 0 then
    raise ETableCalendarError.Create('Invalid dateinterval');
end;

procedure TxTableCalendarData.LoadYearDays;
var
  BlobStream: TBlobStream;
begin
  if not Table.Active then
    raise ETableCalendarError.Create('Dataset not ready');

  BlobStream := TBlobStream.Create(Table.FieldByName('CalendarData') as TBlobField,
    bmRead);
  try
    BlobStream.Read(YearDays, SizeOf(YearDays));
  finally
    BlobStream.Free;
  end;
end;

procedure TxTableCalendarData.CommitYearDays;
var
  BlobStream: TBlobStream;
begin
  Table.Edit;
  BlobStream := TBlobStream.Create(Table.FieldByName('CalendarData') as TBlobField,
    bmWrite);
  try
    BlobStream.Write(YearDays, SizeOf(YearDays));
  finally
    BlobStream.Free;
  end;
  Table.Post;
end;

{procedure TxTableCalendarData.DoOnHolidayCalcDays(Sender: TObject;
  Year: Integer; Items: THolidayDefs);
var
  aDate: TDateTime;
begin
  with Items do
  begin}
    { fixed holidays }
{    Add('New Year''s Day', SysUtils.EncodeDate(Year, 1, 1));
    Add('Orthodox Christmas', SysUtils.EncodeDate(Year, 1, 7));
    Add('Women''s day', SysUtils.EncodeDate(Year, 3, 8));
    Add('Constitution day', SysUtils.EncodeDate(Year, 3, 15));
    Add('May day', SysUtils.EncodeDate(Year, 5, 1));
    Add('Victory day', SysUtils.EncodeDate(Year, 5, 9));
    Add('Independence day', SysUtils.EncodeDate(Year, 7, 27));
    Add('Memorial day', SysUtils.EncodeDate(Year, 11, 2));
    Add('October Revolution day', SysUtils.EncodeDate(Year, 11, 7));
    Add('Christmas', SysUtils.EncodeDate(Year, 12, 25));
 }
    { moveable holidays }
  {  aDate := (Sender as THoliday).Easter(Year);
    Add('Easter', aDate);
    Add('Easter (second day)', aDate + 1);

    Add('Orthodox Easter', aDate + 7);
    Add('Orthodox Easter (second day)', aDate + 8);

    Add('Radunitsa', aDate + 16 );
  end;
end;}

{ TCell --------------------------------------------------}

constructor TCell.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := [csOpaque];

  Down := False;
  AllowPress := True;
end;

procedure TCell.Paint;
begin
  DrawButton;

  try
    if (Parent <> nil) and (Parent.Parent <> nil) then
      Canvas.Font.Assign((Parent.Parent as TxTableCalendar).Font);
  except
  end;
end;

procedure TCell.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Button <> mbLeft) or (not AllowPress) then
    exit;
  MouseCapture := True;
  Down := True;
  Invalidate;
end;

procedure TCell.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if MouseCapture then
  begin
    MouseCapture := False;
    Down := False;
    Invalidate;

    if (X > 0) and (X < Width) and (Y > 0) and (Y < Height) then
      if (Parent <> nil) and (Parent.Parent <> nil) then
        PostMessage((Parent.Parent as TWinControl).Handle, WM_CELLPRESS, 0, LongInt(Self));
  end;
end;

procedure TCell.MouseMove(Shift: TShiftState;
  X, Y: Integer);
var
  IsIn: Boolean;
begin
  if MouseCapture then
  begin
    IsIn := (X > 0) and (X < Width) and (Y > 0) and (Y < Height);
    if IsIn xor Down then
    begin
      Down := IsIn;
      Invalidate;
    end;
  end;
end;

function TCell.DX: Integer;
begin
  if Down then
    Result := 1
  else
    Result := 0;
end;

function TCell.DY: Integer;
begin
  Result := DX;
end;

function TCell.DrawButton: TRect;
begin
  Result := Rect(0, 0, Width, Height);

  if Down then
    Frame3D(Canvas, Result, clBtnShadow, clBtnFace, 1)
  else
    Frame3D(Canvas, Result, clBtnHighlight, clBtnShadow, 1);

  Canvas.Brush.Color := clBtnFace;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Result);

  Inc(Result.Left, DX);
  Inc(Result.Top, DY);
  Inc(Result.Right, DX);
  Inc(Result.Bottom, DY);
end;

{ TIconCell ----------------------------------------------}

constructor TIconCell.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FIcon := nil;
end;

procedure TIconCell.Paint;
begin
  inherited Paint;

  if Assigned(FIcon) and (FIcon.Width + Gap < Width) and
     (FIcon.Height + Gap < Height) then
    Canvas.Draw(Width - FIcon.Width - Gap + DX, Height - FIcon.Height - Gap + DY, FIcon);
end;

procedure TIconCell.SetIcon(AnIcon: TIcon);
begin
  FIcon := AnIcon;
  Invalidate;
end;

{ TMonthCell ---------------------------------------------}

constructor TMonthCell.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Cursor := crFinger;

  FMonth := mJan;
  FDays := 31;
  FWorkDays := 31;
  FWorkTime := FWorkDays * DefaultWorkTime;
end;

procedure TMonthCell.Paint;
var
  S: String;
  R: TRect;
  H: Integer;
begin
  inherited Paint;

  Canvas.Brush.Style := bsClear;

  Canvas.Font.Color := clBlue;
  S := Format('%d', [Ord(FMonth) + 1]) + #0;
  R := Rect(Gap + DX, Gap + DY, Width - Gap + DX, Height - Gap + DY);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_LEFT or DT_TOP);

  Canvas.Font.Color := clRed;
  S := MonthNames[FMonth] + #0;
  R := Rect(Gap + DX, Gap + DY, Width - Gap + DX, Height - Gap + DY);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_RIGHT or DT_TOP);

  Canvas.Font.Color := clBlack;
  S := Format('%d'#13'%d'#13'%s'#0, [FDays, FWorkDays, FormatWorkTime(FWorkTime)]);
  R := Rect(Gap + DX, Gap + DY, Width - Gap + DX, Height - Gap + DY);
  H := DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_CALCRECT);

  R := Rect(Gap + DX, Height - Gap + DY - H, Width - Gap + DX, Height - Gap + DY);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, 0);
end;

procedure TMonthCell.SetMonth(AMonth: TMonth);
begin
  FMonth := AMonth;
  Invalidate;
end;

procedure TMonthCell.SetParam(Index: Integer; Value: Integer);
begin
  case Index of
    1: FDays := Value;
    2: FWorkDays := Value;
  else
    raise ETableCalendarError.Create('Invalid index');
  end;

  Invalidate;
end;

procedure TMonthCell.SetWorkTime(AWorkTime: TWorkTime);
begin
  FWorkTime := AWorkTime;
  Invalidate;
end;

{ TQuarterCell ---------------------------------------------}

constructor TQuarterCell.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  AllowPress := False;

  FQuarter := qFirst;
  FDays := -1;
  FWorkDays := -1;
  FWorkTime := -1;
end;

procedure TQuarterCell.Paint;
var
  S: String;
  R: TRect;
  H: Integer;
begin
  inherited Paint;

  Canvas.Brush.Style := bsClear;

  Canvas.Font.Color := clBlack;
  S := GetQuarterRoman(FQuarter) + ' квартал' + #0;
  R := Rect(Gap + DX, Gap + DY, Width - Gap + DX, Height - Gap + DY);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_LEFT or DT_TOP);

  Canvas.Font.Color := clBlack;
  S := Format('%d'#13'%d'#13'%s'#0, [FDays, FWorkDays, FormatWorkTime(FWorkTime)]);
  R := Rect(Gap + DX, Gap + DY, Width - Gap + DX, Height - Gap + DY);
  H := DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_CALCRECT);

  R := Rect(Gap + DX, Height - Gap + DY - H, Width - Gap + DX, Height - Gap + DY);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, 0);
end;

procedure TQuarterCell.SetQuarter(AQuarter: TQuarter);
begin
  FQuarter := AQuarter;
  Invalidate;
end;

procedure TQuarterCell.SetParam(Index: Integer; Value: Integer);
begin
  case Index of
    1: FDays := Value;
    2: FWorkDays := Value;
  end;
  Invalidate;
end;

procedure TQuarterCell.SetWorkTime(AWorkTime: TWorkTime);
begin
  FWorkTime := AWorkTime;
  Invalidate;
end;

{ TDayCell -----------------------------------------------}

constructor TDayCell.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Cursor := crFinger;

  FDay := 1;
  FWorkTime := -1;
  FIsWorkDay := True;
end;

procedure TDayCell.Paint;
var
  Y, M, D: Word;
  S: String;
  R: TRect;
begin
  inherited Paint;

  SysUtils.DecodeDate(Day, Y, M, D);

  Canvas.Brush.Style := bsClear;

  Canvas.Font.Color := clBlue;
  S := Format('%d', [D]) + #0;
  R := Rect(Gap + DX, Gap + DY, Width - Gap + DX, Height - Gap + DY);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_LEFT or DT_TOP);

  Canvas.Font.Color := clRed;
  S := ShortDayOfWeekNames[TWeekDay(DayOfWeek(FDay) - 1)] + #0;
  R := Rect(Gap + DX, Gap + DY, Width - Gap + DX, Height - Gap + DY);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_RIGHT or DT_TOP);

  if FIsWorkDay then
  begin
    Canvas.Font.Color := clBlack;
    S := FormatWorkTime(FWorkTime) + #0;
    R := Rect(Gap + DX, Gap + DY, Width - Gap + DX, Height - Gap + DY);
    DrawText(Canvas.Handle, @S[1], Length(S) - 1, R,
      DT_LEFT or DT_BOTTOM or DT_SINGLELINE);
  end;
end;

procedure TDayCell.SetDay(ADay: TDateTime);
begin
  FDay := ADay;
  Invalidate;
end;

procedure TDayCell.SetWorkTime(AWorkTime: TWorkTime);
begin
  FWorkTime := AWorkTime;
  Invalidate;
end;

procedure TDayCell.SetIsWorkDay(AnIsWorkDay: Boolean);
begin
  FIsWorkDay := AnIsWorkDay;
  Invalidate;
end;

{ TTextCell ----------------------------------------------}

constructor TTextCell.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  AllowPress := False;
end;

{ THelpCell ----------------------------------------------}

procedure THelpCell.Paint;
var
  S: String;
  R: TRect;
  H: Integer;
begin
  inherited Paint;

  Canvas.Brush.Style := bsClear;

  Canvas.Font.Color := clBlack;
  S := 'месяц'#0;
  R := Rect(Gap, Gap, Width - Gap, Height - Gap);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_RIGHT or DT_TOP);

  Canvas.Font.Color := clBlack;
  S := 'дни'#13'раб. дни'#13'часы'#0;
  R := Rect(Gap, Gap, Width - Gap, Height - Gap);
  H := DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_CALCRECT);

  R := Rect(Gap, Height - Gap - H, Width - Gap, Height - Gap);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, 0);
end;

{ TDayHelpCell -------------------------------------------}

procedure TDayHelpCell.Paint;
var
  S: String;
  R: TRect;
  H: Integer;
begin
  inherited Paint;

  Canvas.Brush.Style := bsClear;

  Canvas.Font.Color := clBlack;
  S := 'число'#0;
  R := Rect(Gap, Gap, Width - Gap, Height - Gap);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_LEFT or DT_TOP);

  Canvas.Font.Color := clBlack;
  S := 'рабочее'#13'время'#0;
  R := Rect(Gap, Gap, Width - Gap, Height - Gap);
  H := DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_CALCRECT);

  R := Rect(Gap, Height - Gap - H, Width - Gap, Height - Gap);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, 0);
end;

{ TNameCell ----------------------------------------------}

constructor TNameCell.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Cursor := crFinger;
  FName := '';
end;

procedure TNameCell.Paint;
var
  S: String;
  R: TRect;
begin
  inherited Paint;

  Canvas.Brush.Style := bsClear;

  Canvas.Font.Color := clBlack;
  Canvas.Font.Style := [];
  S := FName + #0;
  R := Rect(Gap + DX, Gap + DY, Width - Gap + DX, Height - Gap + DY);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_LEFT or DT_VCENTER);
end;

procedure TNameCell.SetName(const AName: String);
begin
  FName := AName;
  Invalidate;
end;

{ TMonthNameCell -----------------------------------------}

constructor TMonthNameCell.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FIcon := TIcon.Create;
  FIcon.Handle := LoadIcon(hInstance, 'XTBLCAL_BACK');
  if FIcon.Handle = 0 then
    raise ETableCalendarError.Create('Invalid resource');
end;

destructor TMonthNameCell.Destroy;
begin
  inherited Destroy;
  FIcon.Free;
end;

procedure TMonthNameCell.Paint;
begin
  inherited Paint;

  Canvas.Draw(Width - Gap - 15 + DX, (Height - 14) div 2 + DY,
    FIcon);
end;

{ TBottomCell --------------------------------------------}

procedure TBottomCell.Paint;
var
  S: String;
  R: TRect;
begin
  inherited Paint;

  Canvas.Brush.Style := bsClear;

  Canvas.Font.Color := clBlack;
  Canvas.Font.Style := [];

  S := Format('Всего дней: %d   Из них рабочих: %d   Всего рабочих часов: %s'#0,
    [FDays, FWorkDays, FormatWorkTime(FWorkTime)]);
  R := Rect(Gap, Gap, Width - Gap, Height - Gap);
  DrawText(Canvas.Handle, @S[1], Length(S) - 1, R, DT_LEFT or DT_VCENTER);
end;

procedure TBottomCell.SetParam(Index: Integer; Param: Integer);
begin
  case Index of
    1: FDays := Param;
    2: FWorkDays := Param;
  end;

  Invalidate;
end;

procedure TBottomCell.SetWorkTime(AWorkTime: TWorkTime);
begin
  FWorkTime := AWorkTime;
  Invalidate;
end;

{ TToolbar -----------------------------------------------}

constructor TToolbar.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  AllowPress := False;
  Height := 37;

  FComboBox := TComboBox.Create(Self);
  FComboBox.Style := csDropDownList;
  FComboBox.Sorted := False;
  FComboBox.Parent := AnOwner as TWinControl;
  {
  FComboBox.Left := 8;
  FComboBox.Top := 8;
  FComboBox.Width := 240;
  }
  FComboBox.OnChange := DoOnComboChange;

  btnAdd := TButton.Create(Self);
  btnAdd.Parent := AnOwner as TWinControl;
{  btnAdd.SetBounds(260, 8, 80, 21); }
  btnAdd.Caption := 'Создать';
  btnAdd.OnClick := DoOnAddClick;

  btnCopy := TButton.Create(Self);
  btnCopy.Parent := AnOwner as TWinControl;
{  btnCopy.SetBounds(339, 8, 80, 21); }
  btnCopy.Caption := 'Копировать';
  btnCopy.OnClick := DoOnCopyClick;

  btnDelete := TButton.Create(Self);
  btnDelete.Parent := AnOwner as TWinControl;
{  btnDelete.SetBounds(418, 8, 80, 21); }
  btnDelete.Caption := 'Удалить';
  btnDelete.OnClick := DoOnDeleteClick;
end;

procedure TToolbar.Update(ACalendarData: TxTableCalendarData);
var
  Bm: TBookmark;
begin
  if (not Assigned(ACalendarData)) or (not ACalendarData.Active) or
    (ACalendarData.CalendarCount < 1) then
   exit;

  Bm := ACalendarData.GetBookmark;
  try
    FComboBox.Items.Clear;
    with ACalendarData do
    begin
      FirstCalendar;
      while not EOF do
      begin
        FComboBox.Items.Add(Format('%d   %s', [CalendarYear, CalendarName]));
        NextCalendar;
      end;
    end;
  finally
    ACalendarData.GoToBookmark(Bm);
    ACalendarData.FreeBookmark(Bm);
  end;

  FComboBox.ItemIndex := ACalendarData.CalendarIndex;
end;

procedure TToolbar.SetSize(ALeft, ATop, AWidth, AHeight: Integer);
var
  W: Integer;
begin
  SetBounds(ALeft, ATop, AWidth, AHeight);

  W := (Width - 8 - 240 - 8 - 8) div 3;

  FComboBox.Left := 8;
  FComboBox.Top := 8;
  FComboBox.Width := 240;

  btnAdd.SetBounds(240 + 8 + 8, 8, W, 21);
  btnCopy.SetBounds(240 + 8 + 8 + W, 8, W, 21);
  btnDelete.SetBounds(240 + 8 + 8 + W + W, 8, W, 21);
end;

procedure TToolbar.DoOnAddClick(Sender: TObject);
begin
  PostMessage((Parent.Parent as TxTableCalendar).Handle,
    WM_CELLPRESS, cmAdd, LongInt(Self));
end;

procedure TToolbar.DoOnCopyClick(Sender: TObject);
begin
  PostMessage((Parent.Parent as TxTableCalendar).Handle,
    WM_CELLPRESS, cmCopy, LongInt(Self));
end;

procedure TToolbar.DoOnDeleteClick(Sender: TObject);
begin
  PostMessage((Parent.Parent as TxTableCalendar).Handle,
    WM_CELLPRESS, cmDel, LongInt(Self));
end;

procedure TToolbar.DoOnComboChange(Sender: TObject);
begin
  PostMessage((Parent.Parent as TxTableCalendar).Handle,
    WM_CELLPRESS, cmCombo, FComboBox.ItemIndex);
end;

{ TBaseCalendar ------------------------------------------}

procedure TBaseCalendar.SetSize(ALeft, ATop, AWidth, AHeight: Integer);
begin
  SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TBaseCalendar.SetCalendarData(ACalendarData: TxTableCalendarData);
begin
  FCalendarData := ACalendarData;
  UpdateButtons;
end;

{ TYearCalendar ------------------------------------------}

constructor TYearCalendar.Create(AnOwner: TComponent);
var
  M: TMonth;
  S: TSeason;
  Q: TQuarter;
begin
  inherited Create(AnOwner);

  for S := sWinter to sAutumn do
    MonthIcons[S] := TIcon.Create;

  MonthIcons[sWinter].Handle := LoadIcon(hInstance, 'XTBLCAL_WINTER');
  MonthIcons[sSpring].Handle := LoadIcon(hInstance, 'XTBLCAL_SPRING');
  MonthIcons[sSummer].Handle := LoadIcon(hInstance, 'XTBLCAL_SUMMER');
  MonthIcons[sAutumn].Handle := LoadIcon(hInstance, 'XTBLCAL_AUTUMN');

  for S := sWinter to sAutumn do
    if MonthIcons[S].Handle = 0 then
      raise ETableCalendarError.Create('Table-calendar resources are damaged');

  for Q := qFirst to qFourth do
    QuarterIcons[Q] := TIcon.Create;

  QuarterIcons[qFirst].Handle := LoadIcon(hInstance, 'XTBLCAL_1QTR');
  QuarterIcons[qSecond].Handle := LoadIcon(hInstance, 'XTBLCAL_2QTR');
  QuarterIcons[qThird].Handle := LoadIcon(hInstance, 'XTBLCAL_3QTR');
  QuarterIcons[qFourth].Handle := LoadIcon(hInstance, 'XTBLCAL_4QTR');

  for Q := qFirst to qFourth do
    if QuarterIcons[Q].Handle = 0 then
      raise ETableCalendarError.Create('Table-calendar resources are damaged');

  for M := mJan to mDec do
  begin
    MonthButtons[M] := TMonthCell.Create(Self);
    MonthButtons[M].Parent := Self;
    MonthButtons[M].Icon := MonthIcons[GetSeason(M)];
    MonthButtons[M].Month := M;
  end;

  for Q := qFirst to qFourth do
  begin
    QuarterButtons[Q] := TQuarterCell.Create(Self);
    QuarterButtons[Q].Parent := Self;
    QuarterButtons[Q].Icon := QuarterIcons[Q];
    QuarterButtons[Q].Quarter := Q;

    HelpButtons[Q] := THelpCell.Create(Self);
    HelpButtons[Q].Parent := Self;
  end;

  NameButton := TNameCell.Create(Self);
  NameButton.Parent := Self;

  BottomButton := TBottomCell.Create(Self);
  BottomButton.Parent := Self;

  Toolbar := TToolbar.Create(Self);
  Toolbar.Parent := Self;
end;

destructor TYearCalendar.Destroy;
var
  S: TSeason;
  Q: TQuarter;
begin
  for S := sWinter to sAutumn do
    if Assigned(MonthIcons[S]) then MonthIcons[S].Free;

  for Q := qFirst to qFourth do
    if Assigned(QuarterIcons[Q]) then QuarterIcons[Q].Free;

  inherited Destroy;
end;

procedure TYearCalendar.SetSize(ALeft, ATop, AWidth, AHeight: Integer);
const
  FixedHeight = 24;

var
  M: TMonth;
  Q: TQuarter;
  W, H: Integer;
begin
  inherited SetSize(ALeft, ATop, AWidth, AHeight);

  Toolbar.SetSize(0, 0, AWidth, Toolbar.Height);

  H := (Height - Toolbar.Height - FixedHeight * 2) div 4;
  W := Width div 5;

  NameButton.SetBounds(0, Toolbar.Height, Width, FixedHeight);
  BottomButton.SetBounds(0, Toolbar.Height + FixedHeight + H * 4,
    Width, Height - Toolbar.Height - FixedHeight - H * 4);

  for Q := qFirst to qFourth do
    HelpButtons[Q].SetBounds(0, Toolbar.Height + FixedHeight + Ord(Q) * H, W, H);

  for M := mJan to mDec do
    MonthButtons[M].SetBounds(W + (Ord(M) mod 3) * W, Toolbar.Height + FixedHeight + Ord(GetQuarter(M)) * H,
      W, H);

  for Q := qFirst to qFourth do
    QuarterButtons[Q].SetBounds(W + 3 * W, Toolbar.Height + FixedHeight + Ord(Q) * H, Width - W - W * 3, H);
end;

procedure TYearCalendar.UpdateButtons;
var
  M: TMonth;
  Q: TQuarter;
begin
  if (not Assigned(FCalendarData)) or (not FCalendarData.Active)
    or (FCalendarData.CalendarCount < 1) then
   exit;

  Toolbar.Update(FCalendarData);

  with FCalendarData do
  begin
    NameButton.Name := Format('График работы: %s на %d год',
      [CalendarName, CalendarYear]);

    StartDate := EncodeDate(1, 1);
    StartDateExclusive := False;
    EndDate := EncodeDate(12, 31);
    EndDateExclusive := False;

    BottomButton.Days := GetDaysBetween;
    BottomButton.WorkDays := GetWorkDaysBetween;
    BottomButton.WorkTime := GetWorkTimeBetween;
  end;

  for M := mJan to mDec do
  begin
    FCalendarData.StartDate := FCalendarData.EncodeDate(Ord(M) + 1, 1);
    FCalendarData.StartDateExclusive := False;
    if M < mDec then
    begin
      FCalendarData.EndDate := FCalendarData.EncodeDate(Ord(M) + 2, 1);
      FCalendarData.EndDateExclusive := True;
    end else
    begin
      FCalendarData.EndDate := FCalendarData.EncodeDate(12, 31);
      FCalendarData.EndDateExclusive := False;
    end;

    MonthButtons[M].Days := FCalendarData.GetDaysBetween;
    MonthButtons[M].WorkDays := FCalendarData.GetWorkDaysBetween;
    MonthButtons[M].WorkTime := FCalendarData.GetWorkTimeBetween;
  end;

  for Q := qFirst to qFourth do
  begin
    FCalendarData.StartDate := FCalendarData.EncodeDate(Ord(Q) * 3 + 1, 1);
    FCalendarData.StartDateExclusive := False;
    if Q < qFourth then
    begin
      FCalendarData.EndDate := FCalendarData.EncodeDate((Ord(Q) + 1) * 3 + 1, 1);
      FCalendarData.EndDateExclusive := True;
    end else
    begin
      FCalendarData.EndDate := FCalendarData.EncodeDate(12, 31);
      FCalendarData.EndDateExclusive := False;
    end;

    QuarterButtons[Q].Days := FCalendarData.GetDaysBetween;
    QuarterButtons[Q].WorkDays := FCalendarData.GetWorkDaysBetween;
    QuarterButtons[Q].WorkTime := FCalendarData.GetWorkTimeBetween;
  end;
end;

{ TMonthCalendar -----------------------------------------}

constructor TMonthCalendar.Create(AnOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AnOwner);

  HolidayIcon := TIcon.Create;
  WorkdayIcon := TIcon.Create;
  HolidayIcon.Handle := LoadIcon(hInstance, 'XTBLCAL_HOLIDAY');
  WorkdayIcon.Handle := LoadIcon(hInstance, 'XTBLCAL_WORKDAY');
  if (HolidayIcon.Handle = 0) or (WorkdayIcon.Handle = 0) then
    raise ETableCalendarError.Create('Resource missing');

  for I := 1 to 31 do
  begin
    DayButtons[I] := TDayCell.Create(Self);
    DayButtons[I].Parent := Self;
  end;

  for I := 1 to 6 do
  begin
    HelpButtons[I] := TDayHelpCell.Create(Self);
    HelpButtons[I].Parent := Self;
  end;

  NameButton := TMonthNameCell.Create(Self);
  NameButton.Parent := Self;

  BottomButton := TBottomCell.Create(Self);
  BottomButton.Parent := Self;

  MonthAssigned := False;
end;

destructor TMonthCalendar.Destroy;
begin
  if Assigned(HolidayIcon) then HolidayIcon.Free;
  if Assigned(WorkdayIcon) then WorkdayIcon.Free;
  inherited Destroy;
end;

procedure TMonthCalendar.SetSize(ALeft, ATop, AWidth, AHeight: Integer);
const
  FixedHeight = 24;

var
  W, H: Integer;
  I, K, J: Integer;
begin
  if (not Assigned(FCalendarData)) or (not MonthAssigned) then
    exit;

  inherited SetSize(ALeft, ATop, AWidth, AHeight);

  H := (Height - FixedHeight * 2) div 6;
  W := Width div 8;

  NameButton.SetBounds(0, 0, Width, FixedHeight);
  BottomButton.SetBounds(0, FixedHeight + H * 6, Width, Height - FixedHeight - H * 6);

  for I := 1 to 6 do
    HelpButtons[I].SetBounds(0, FixedHeight + (I - 1) * H, Width - W * 7, H);

  I := 1;
  for K := 1 to 6 do
    for J := 1 to 7 do
      if ((J < 7) and (DayOfWeek(DayButtons[I].Day) = J + 1)) or
        ((J = 7) and (DayOfWeek(DayButtons[I].Day) = 1)) then
      begin
        DayButtons[I].SetBounds(HelpButtons[1].Width + (J - 1) * W, FixedHeight + (K - 1) * H, W, H);
        Inc(I);
        if I >= DaysInMonth then exit;
      end;
end;

procedure TMonthCalendar.UpdateButtons;
begin
  if (not Assigned(FCalendarData)) or (not FCalendarData.Active)
    or (FCalendarData.CalendarCount < 1) or (not MonthAssigned) then
   exit;

  with FCalendarData do
  begin
    NameButton.Name := Format('%s, %d год', [MonthNames[Month], CalendarYear]);

    StartDate := EncodeDate(GetMonthOrd(Month), 1);
    StartDateExclusive := False;
    if Month < mDec then
    begin
      EndDate := EncodeDate(GetMonthOrd(Succ(Month)), 1);
      EndDateExclusive := True;
    end else
    begin
      EndDate := EncodeDate(12, 31);
      EndDateExclusive := False;
    end;

    BottomButton.Days := GetDaysBetween;
    BottomButton.WorkDays := GetWorkDaysBetween;
    BottomButton.WorkTime := GetWorkTimeBetween;
  end;

  FCalendarData.StartDate := FCalendarData.EncodeDate(GetMonthOrd(Month), 1);
  FCalendarData.StartDateExclusive := False;

  if Month = mDec then
  begin
    FCalendarData.EndDate := FCalendarData.EncodeDate(12, 31);
    FCalendarData.EndDateExclusive := False;
  end else
  begin
    FCalendarData.EndDate := FCalendarData.EncodeDate(GetMonthOrd(Month) + 1, 1);
    FCalendarData.EndDateExclusive := True;
  end;

  FCalendarData.First;

  DaysInMonth := 1;
  while not FCalendarData.EOP do
  begin
    DayButtons[DaysInMonth].Day := FCalendarData.Day;
    if FCalendarData.IsWorkDay then
    begin
      DayButtons[DaysInMonth].WorkTime := FCalendarData.WorkTime;
      DayButtons[DaysInMonth].IsWorkDay := True;
      DayButtons[DaysInMonth].Icon := WorkdayIcon;
    end else
    begin
      DayButtons[DaysInMonth].IsWorkDay := False;
      DayButtons[DaysInMonth].Icon := HolidayIcon;
    end;

    Inc(DaysInMonth);
    FCalendarData.Next;
  end;
end;

procedure TMonthCalendar.SetMonth(AMonth: TMonth);
begin
  FMonth := AMonth;
  MonthAssigned := True;
  UpdateButtons;
end;

{ TTableCalendar -----------------------------------------}

constructor TxTableCalendar.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Calendar := TYearCalendar.Create(Self);
  InsertControl(Calendar);
end;

destructor TxTableCalendar.Destroy;
begin
  if Assigned(FCalendarData) then
  begin
    try
      FCalendarData.UnRegisterTableCalendar(Self);
    except
      on Exception do ;
    end;
  end;

  Calendar.Free;
  inherited Destroy;
end;

procedure TxTableCalendar.Loaded;
begin
  inherited Loaded;

  OldOnCalendarDataOpened := FCalendarData.OnOpened;
  FCalendarData.OnOpened := DoOnCalendarDataOpened;

  Calendar.CalendarData := FCalendarData;
end;

procedure TxTableCalendar.TableCalendarDataChanged;
begin
{  Invalidate; }
  Calendar.UpdateButtons;
end;

procedure TxTableCalendar.WMSize(var Message: TMessage);
begin
  inherited;
  Calendar.SetSize(0, 0, Width, Height);
end;

procedure TxTableCalendar.WMCellPress(var Message: TMessage);
var
  T: TCell;
  M: TMonth;
  Dayoffs: TWeekDays;
  _Year, _Month, _Day: Word;
  OldAutoSave: Boolean;
  _StartDate, _EndDate: TDateTime;
begin
  if Message.wParam <> 0 then
  begin
    case Message.wParam of
    cmAdd:
      begin
        CreateTableCalendar := TCreateTableCalendar.Create(Self);
        try
          if CreateTableCalendar.ShowModal = mrOk then
          begin
            OldAutoSave := FCalendarData.AutoSave;
            FCalendarData.AutoSave := False;

            FCalendarData.AppendCalendar(CreateTableCalendar.Year,
              CreateTableCalendar.Alias, CreateTableCalendar.Name,
              CreateTableCalendar.Holidays);

            Dayoffs := CreateTableCalendar.Dayoffs;

            with FCalendarData do
            begin
              StartDate := EncodeDate(1, 1);
              StartDateExclusive := False;

              EndDate := EncodeDate(12, 31);
              EndDateExclusive := False;

              First;
              while not EOP do
              begin
                if IsWorkDay then
                begin
                  if WeekDay in Dayoffs then
                    IsWorkDay := False
                  else begin
                    IsWorkDay := True;
                    WorkTime := CreateTableCalendar.WorkTime;
                  end;
                end;

                (* здесь могла бы быть ваша реклама *)

                Next;
              end;
            end;

            FCalendarData.AutoSave := OldAutoSave;
            FCalendarData.CommitYearDays;

            Calendar.UpdateButtons;
          end;
        finally
          CreateTableCalendar.Free;
        end;
      end;

    cmCopy:
      begin
        FCalendarData.CopyCalendar;

        TableCalendarProperties := TTableCalendarProperties.Create(Self);
        try
          TableCalendarProperties.Name := FCalendarData.CalendarName;
          TableCalendarProperties.Year := FCalendarData.CalendarYear;
          TableCalendarProperties.Alias := FCalendarData.CalendarAlias;

          if TableCalendarProperties.ShowModal = mrOk then
          begin
            FCalendarData.CalendarName := TableCalendarProperties.Name;
            FCalendarData.CalendarYear := TableCalendarProperties.Year;
            FCalendarData.CalendarAlias := TableCalendarProperties.Alias;

            Calendar.UpdateButtons;
          end;
        finally
          TableCalendarProperties.Free;
        end;
      end;

    cmDel:
      begin
        if FCalendarData.CalendarCount <= 1 then
        begin
          MessageBox(Handle, 'Нельзя удалить единственный рабочий график',
            'Внимание', MB_OK or MB_ICONHAND);
        end else
        begin
          if MessageBox(Handle, 'Удалить текущий график?', 'Внимание',
            MB_YESNO or MB_ICONQUESTION) = ID_YES then
          begin
            FCalendarData.DeleteCalendar;
            FCalendarData.FirstCalendar;
            Calendar.UpdateButtons;
          end;
        end;
      end;

    cmCombo:
      begin
        FCalendarData.CalendarIndex := Message.LParam;
        Calendar.UpdateButtons;
      end;
    end;

    exit;
  end;

  T := TCell(Message.LParam);

  if not Assigned(T) then
    raise ETableCalendarError.Create('Unknown sender');

  if T is TMonthCell then
  begin
    M := (T as TMonthCell).Month;
    Calendar.Free;
    Calendar := TMonthCalendar.Create(Self);
    InsertControl(Calendar);
    Calendar.CalendarData := FCalendarData;
    (Calendar as TMonthCalendar).Month := M;
    Calendar.SetSize(0, 0, Width, Height);
  end { T is TMonthCell }
  else if T is TDayCell then
  begin
    DayProperties := TDayProperties.Create(Self);
    try
      DayProperties.Date := (T as TDayCell).Day;
      if (T as TDayCell).IsWorkDay then
      begin
        DayProperties.WorkTime := (T as TDayCell).WorkTime;
        DayProperties.IsWorkDay := True;
      end else
      begin
        DayProperties.WorkTime := DefaultWorkTime;
        DayProperties.IsWorkDay := False;
      end;

      if DayProperties.ShowModal = mrOk then
        with FCalendarData do
      begin
        case DayProperties.Region of
          rThisDayOnly:
          begin
            StartDate := DayProperties.Date;
            StartDateExclusive := False;
            EndDate := StartDate;
            EndDateExclusive := False;
          end;

          rThisWeek:
          begin
            GetWeek(DayProperties.Date, _StartDate, _EndDate);
            StartDate := _StartDate;
            StartDateExclusive := False;
            EndDate := _EndDate;
            EndDateExclusive := False;
          end;

          rThisMonth:
          begin
            DecodeDate(DayProperties.Date, _Year, _Month, _Day);
            StartDate := EncodeDate(_Month, 1);
            StartDateExclusive := False;
            if _Month < 12 then
            begin
              EndDate := EncodeDate(_Month + 1, 1);
              EndDateExclusive := True;
            end else
            begin
              EndDate := EncodeDate(12, 31);
              EndDateExclusive := False;
            end;
          end;

          rThisQuarter:
          begin
            DecodeDate(DayProperties.Date, _Year, _Month, _Day);
            StartDate := EncodeDate((_Month div 4) * 3 + 1, 1);
            StartDateExclusive := False;
            if _Month < 10 then
            begin
              EndDate := EncodeDate(((_Month div 4) + 1) * 3 + 1, 1);
              EndDateExclusive := True;
            end else
            begin
              EndDate := EncodeDate(12, 31);
              EndDateExclusive := False;
            end;
          end;

          rThisYear, rSuchDaysOfWeek:
          begin
            StartDate := EncodeDate(1, 1);
            StartDateExclusive := False;
            EndDate := EncodeDate(12, 31);
            EndDateExclusive := False;
          end;

          rUntilThisYearEnd:
          begin
            StartDate := DayProperties.Date;
            StartDateExclusive := False;
            EndDate := EncodeDate(12, 31);
            EndDateExclusive := False;
          end;

        else
          raise ETableCalendarError.Create('Invalid region');
        end;

        OldAutoSave := AutoSave;
        AutoSave := False;
        First;

        if DayProperties.Region = rSuchDaysOfWeek then
          while not EOP do
          begin
            if WeekDay = xTblCal4.GetWeekDay(DayProperties.Date) then
              if DayProperties.IsWorkDay then
              begin
                IsWorkDay := True;
                WorkTime := DayProperties.WorkTime;
              end else
                IsWorkDay := False;

            Next;
          end
        else { !rSuchDayOfWeek }
          while not EOP do
          begin
            if DayProperties.IsWorkDay then
            begin
              IsWorkDay := True;
              WorkTime := DayProperties.WorkTime;
            end else
              IsWorkDay := False;

            Next;
          end;

        AutoSave := OldAutoSave;
        CommitYearDays;

        Calendar.UpdateButtons;
      end; { ShowModal = mrOk }
    finally
      DayProperties.Free;
    end;
  end { T is TDayCell }
  else if T is TMonthNameCell then
  begin
    Calendar.Free;
    Calendar := TYearCalendar.Create(Self);
    InsertControl(Calendar);
    Calendar.CalendarData := FCalendarData;
    Calendar.SetSize(0, 0, Width, Height);
  end { T is TMonthNameCell }
  else if T is TNameCell then
  begin
    TableCalendarProperties := TTableCalendarProperties.Create(Self);
    try
      TableCalendarProperties.Name := FCalendarData.CalendarName;
      TableCalendarProperties.Year := FCalendarData.CalendarYear;
      TableCalendarProperties.Alias := FCalendarData.CalendarAlias;

      if TableCalendarProperties.ShowModal = mrOk then
      begin
        FCalendarData.CalendarName := TableCalendarProperties.Name;
        FCalendarData.CalendarYear := TableCalendarProperties.Year;
        FCalendarData.CalendarAlias := TableCalendarProperties.Alias;

        Calendar.UpdateButtons;
      end;
    finally
      TableCalendarProperties.Free;
    end;
  end;
end;

procedure TxTableCalendar.SetCalendarData(ACalendarData: TxTableCalendarData);
begin
  if Assigned(FCalendarData) then
    FCalendarData.UnRegisterTableCalendar(Self);

  FCalendarData := ACalendarData;
  Calendar.CalendarData := ACalendarData;

  if Assigned(FCalendarData) then
    FCalendarData.RegisterTableCalendar(Self);
end;

procedure TxTableCalendar.DoOnCalendarDataOpened(Sender: TObject);
begin
  Calendar.UpdateButtons;
  if Assigned(OldOnCalendarDataOpened) then
    OldOnCalendarDataOpened(Sender);
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('xTool-2', [TxTableCalendar]);
  RegisterComponents('xTool-2', [TxTableCalendarData]);
end;

initialization
  Screen.Cursors[crFinger] := LoadCursor(hInstance, MakeIntResource(crFinger));
end.

