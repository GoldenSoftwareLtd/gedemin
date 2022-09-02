// ShlTanya, 11.02.2019

unit gsCalendar;

interface

uses
  Windows, Forms, Controls, Classes, Graphics, Buttons, ComCtrls, Menus,
  Messages, SysUtils, DsgnIntf, Extctrls, Stdctrls, Dialogs;

type
  TgsCalendar = class;

  TDay = 1..31;
  TMonth = 1..12;

  TButtonDirection = (bdMonthUp, bdMonthDown, bdYearUp, bdYearDown);
  TSelectedShape = (ssEllipse, ssRectangle);
  TSelectType = (stDateSelect, stBlockSelect);
  TDayOfWeek = (dwMonday, dwTuesday, dwWednesday, dwThursday, dwFriday, dwSaturday, dwSunday);

  TSelectedColor = (scNone, scDate, scSelected);

  TOnDateChange = procedure(Sender: TObject; FromDate, ToDate: TDateTime) of object;

//  THoliday = class(TCollectionItem)
//  private
//    FDay: TDay;
//    FMonth: TMonth;
//    FName: String;
//  protected
//    function GetDisplayName: String; override;
//  published
//    property Day: TDay read FDay write FDay;
//    property Month: TMonth read FMonth write FMonth;
//    property Name: String read FName write FName;
//  end;
//
//  THolidays = class(TCollection)
//  private
//    FCalendar: TgsCalendar;
//
//    function GetHoliday(index: Integer): THoliday;
//    procedure SetHoliday(index: Integer; Value: THoliday);
//  protected
//    function GetOwner: TPersistent; override;
//  public
//    constructor Create(AOwner: TgsCalendar);
//    function Add(ADay, AMonth: Word): THoliday;
//    property Items[index: integer]: THoliday read GetHoliday write SetHoliday;
//  end;

  TgsMonthsColors = class(TPersistent)
  private
    FControl: TControl;

    FMonthBackColor: TColor;    //background
    FTitleBackColor: TColor;    //title, days names, lines, cursor
    FCircleColor: TColor;       //today's circle

    FTitleTextColor: TColor;//~~
    FTextColor: TColor;//~~
    FHighLightColor: TColor;//~~

    procedure SetMonthBackColor(Value: TColor);
    procedure SetTitleBackColor(Value: TColor);
    //-procedure SetCircleColor(Value: TColor);

    procedure SetTitleTextColor(Value: TColor);//~~
    procedure SetTextColor(Value: TColor);//~~
    procedure SetHighLightColor(Value: TColor);//~~
  public
    constructor Create(AControl: TControl);
  published
    property MonthBackColor: TColor read FMonthBackColor write SetMonthBackColor;
    property TitleBackColor: TColor read FTitleBackColor write SetTitleBackColor;
    //-property CircleColor: TColor read FCircleColor write SetCircleColor;

    property TitleTextColor: TColor read FTitleTextColor write SetTitleTextColor;//~~
    property TextColor: TColor read FTextColor write SetTextColor;//~~
    property HighLightColor: TColor read FHighLightColor write SetHighLightColor;//~~
  end;

  TgsCalendarColors = class(TgsMonthsColors)
  private
    FFreeDayColor: TColor;      //sundays, holidays
    FSelectedColor: TColor;     //selected dates
    FTrailingTextColor: TColor; //trailing days

    //-procedure SetFreeDayColor(Value: TColor);
    //-procedure SetSelectedColor(Value: TColor);
    procedure SetTrailingDaysColor(Value: TColor);
  public
    constructor Create(AControl: TControl);
  published
    //-property FreeDayColor: TColor read FFreeDayColor write SetFreeDayColor;
    //-property SelectedColor: TColor read FSelectedColor write SetSelectedColor;
    property TrailingTextColor: TColor read FTrailingTextColor write SetTrailingDaysColor;
  end;

  TgsCustomCalendar = class(TCustomControl)
  private
    FYear: Word;
    FMonth: Word;
    FDay: Word;

    FCellHeight: Integer;

    FUpM: TSpeedButton;   //up button
    FDownM: TSpeedButton; //down button

    FUpY: TSpeedButton;   //up button year
    FDownY: TSpeedButton; //down button  year

    FTimer: TTimer;                    //timer for up/down button
    FTimerDirection: TButtonDirection; //which button is holded down

    FTextFont: TFont;  //font for days
    FTitleFont: TFont; //font for title (month and year)

    FSelectedShape: TSelectedShape; //shape for selection

    FTransparentCursor: Boolean;

    FMinDate: TDate; //min date, that can be selected
    FMaxDate: TDate; //max date, that can be selected

    FBorderStyle: TBorderStyle; //border

    //FShowFocusRect: Boolean; //draw focus rect when calendar has focus

    procedure SetTextFont(Value: TFont);
    procedure SetTitleFont(Value: TFont);
    procedure SetBorder(Value: TBorderStyle);
    procedure SetSelectedShape(Value: TSelectedShape);
    procedure SetTransparentCursor(Value: Boolean);

    procedure FontChanged(Sender: TObject);
    procedure BtnPress(Sender: TObject);
    procedure BtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BtnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnTimerEvent(Sender: TObject);
    procedure PositionButtons;
    procedure SetButtonsParent(ToSelf: Boolean);
    procedure RecalculateSize;

    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    function IncTitleHeight: Integer;

  protected
    procedure BtnUpM; virtual; abstract;
    procedure BtnDownM; virtual; abstract;

    procedure BtnUpY; virtual; abstract;
    procedure BtnDownY; virtual; abstract;

    procedure DrawBorder; virtual;
    //procedure DrawFocusRect; virtual;

    function CanChangeDate(ToDate: TDate): Boolean; virtual;

    procedure Paint; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property SelectedShape: TSelectedShape read FSelectedShape write SetSelectedShape default ssRectangle;
    property TextFont: TFont read FTextFont write SetTextFont;
    property TitleFont: TFont read FTitleFont write SetTitleFont;
    property MinDate: TDate read FMinDate write FMinDate;
    property MaxDate: TDate read FMaxDate write FMaxDate;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorder default bsNone;
    //property ShowFocusRect: Boolean read FShowFocusRect write FShowFocusRect default true;
    property TransparentCursor: Boolean read FTransparentCursor write SetTransparentCursor;

    property Visible;

    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnDblClick;//: TNotifyEvent read FOnDblClick write FOnDblClick;
  end;

  TgsCalendar = class(TgsCustomCalendar)
  private
//u    FUpDown: TUpDown;       //year up and down spin button
    FPopUpMonth: TPopupMenu;   //month popup menu

    FCalColors: TgsCalendarColors;
//h    FHolidays: THolidays;

    FShowTodayCircle: Boolean;
    FShowYear: Boolean;
    FShowTitle: Boolean;
    FShowToday: Boolean;

    FWeekNumbers: Boolean;

    FCellWidth: Integer;

    FNumCols: Byte;
    FNumRows: Byte;

    FFirstDayOfWeekByte: Byte;
    FFirstDayOfWeek: TDayOfWeek;

    FDayOffset: Word; //number of days from the previous month visible in this month

    FTodayString: String;

    FMouseDown: Boolean;
    FStartDate, FEndDate: TDate;

    FSelectType: TSelectType;

    FCanChangeMonthYear: Boolean;

    FOnDateSelect: TNotifyEvent;  //occurs when date is selected with a mouse
    FOnBlockSelect: TNotifyEvent; //occurs when block select is finished with a mouse
    FOnDateChange: TOnDateChange; //occurs when date changes

//u    procedure UpDownPress(Sender: TObject; Button: TUDBtnType);
    procedure PopupMonthClick(Sender: TObject);
    procedure JumpToToday;
    procedure SetMinMaxForMultiSelect(var min, max: TDate);
    procedure ResetStartEndDate;
    procedure SetNumRows;
    procedure SetNumCols;
    procedure GetPrevMonth(var AYear, AMonth: Word);
    procedure GetNextMonth(var AYear, AMonth: Word);

    function RectOfToday: TRect;
    function RectOfDay(ADay: Word): TRect;
    function RectOfMonth: TRect;
//u    function RectOfYear: TRect;
    function RectOfCell(row, col: Word): TRect;
    function RectOfDays: TRect;

//h    function IsDateHoliday(ADay, AMonth: Word): Boolean;
    function GetDate: TDate;
    function GetDayRow(y: Integer): Integer;
    function GetDayCol(x: Integer): Integer;
    function GetFirstDayCell: Integer;
    function GetStartDate: TDate;
    function GetEndDate: TDate;

    procedure SetCellWidth(Value: Integer);
    procedure SetCellHeight(Value: Integer);
    procedure SetWeekNumbers(Value: Boolean);
    procedure SetShowToday(Value: Boolean);
    procedure SetShowTodayCircle(Value: Boolean);
    procedure SetShowYear(Value: Boolean);
    procedure SetShowTitle(Value: Boolean);
//h    procedure SetHolidays(Value: THolidays);
    procedure SetFirstDayOfWeek(Value: TDayOfWeek);
    procedure SetDate(Value: TDate);
    procedure SetCalColors(Value: TgsCalendarColors);
    procedure SetSelectType(Value: TSelectType);
    procedure SetCanChangeMonthYear(Value: Boolean);
    procedure SetYear(Value: Word);
    procedure SetMonth(Value: Word);
    procedure SetDay(Value: Word);

    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
  protected
    function DoDateChange(FromDate, ToDate: TDateTime; MoveMouse, ResetStartEnd: Boolean): Boolean; virtual;
    function AllowMultiSelect: Boolean; virtual;

    function CanChangeDate(ToDate: TDate): Boolean; override;

    procedure BtnUpM; override;
    procedure BtnDownM; override;
    procedure BtnUpY; override;
    procedure BtnDownY; override;

    procedure DoOnSelectDate; virtual;
    procedure DoOnBlockSelect; virtual;

    procedure SetNormalCanvas(AYear, AMonth, ADay: Word); virtual;
    procedure SetSelectedCanvas(AYear, AMonth, ADay: Word; Grayed: Boolean); virtual;

    procedure DrawMonth;
    procedure DrawDayNames;
    procedure DrawDays;
    procedure DrawMultiSelect(selected: Boolean);
    procedure DrawWeekNumbers;
    procedure DrawToday;
    procedure DrawTodayCircle;
    procedure DrawDatePosition;

    procedure DrawDayText(R: TRect; const s: String);
    procedure DrawNormalDay(R: TRect; AYear, AMonth, ADay: Word);
    procedure DrawSelectedDay(R: TRect; AYear, AMonth, ADay: Word);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Paint; override;
    procedure DoExit; override;

    procedure DoSize;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function DayNumber: Word; //which day number is selected day
    function WeekNumber(ADate: TDate): Integer; //which week number is selected day
//h    function IsHoliday(ADate: TDate): Boolean;

    property Year: Word read FYear write SetYear;
    property Month: Word read FMonth write SetMonth;
    property Day: Word read FDay write SetDay;

    property StartDate: TDate read GetStartDate;
    property EndDate: TDate read GetEndDate;
  published
    property CalColors: TgsCalendarColors read FCalColors write SetCalColors;

    property Date: TDate read GetDate write SetDate;
    property FirstDayOfWeek: TDayOfWeek read FFirstDayOfWeek write SetFirstDayOfWeek default dwMonday;

    property ShowToday: Boolean read FShowToday write SetShowToday default false;
    property ShowTodayCircle: Boolean read FShowTodayCircle write SetShowTodayCircle default false;
    property WeekNumbers: Boolean read FWeekNumbers write SetWeekNumbers default true;
    property ShowYear: Boolean read FShowYear write SetShowYear default true;
    property ShowTitle: Boolean read FShowTitle write SetShowTitle default true;
    property TodayString: String read FTodayString write FTodayString;

//h    property Holidays: THolidays read FHolidays write SetHolidays;

    property CellWidth: Integer read FCellWidth write SetCellWidth default 28;
    property CellHeight: Integer read FCellHeight write SetCellHeight default 22;

    property SelectType: TSelectType read FSelectType write SetSelectType default stDateSelect;

    property CanChangeMonthYear: Boolean read FCanChangeMonthYear write SetCanChangeMonthYear default true;

    property OnDateSelect: TNotifyEvent read FOnDateSelect write FOnDateSelect;
    property OnBlockSelect: TNotifyEvent read FOnBlockSelect write FOnBlockSelect;
    property OnDateChange: TOnDateChange read FOnDateChange write FOnDateChange;
  end;

function DaysInMonth2(AYear, AMonth: Word): Word;
function DayOfWeek2(Date: TDateTime): TDayOfWeek;
function LocaleFirstDayOfWeek: TDayOfWeek;

procedure Register;

implementation

{$RESOURCE gsCalendar.res}

function ByteToDayOfWeek(Value: Byte): TDayOfWeek;
begin
  case Value of
    1: Result := dwSunday;
    2: Result := dwMonday;
    3: Result := dwTuesday;
    4: Result := dwWednesday;
    5: Result := dwThursday;
    6: Result := dwFriday;
    7: Result := dwSaturday;
    else raise Exception.Create('');
  end;
end;

function DaysInMonth2(AYear, AMonth: Word): Word;
const
  c_DaysInMonth: array[1..12] of Integer = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  //how many days are in AMonth depends on AYear, as it could be leap year
  Result := c_DaysInMonth[AMonth];
  if (AMonth = 2) and IsLeapYear(AYear) then Inc(Result); //leap-year Feb is special
end;

function DayOfWeek2(Date: TDateTime): TDayOfWeek;
begin
  Result := ByteToDayOfWeek(SysUtils.DayOfWeek(Date));
end;

function LocaleFirstDayOfWeek: TDayOfWeek;
var
  fdw: Integer;
  c: array[0..1] of Char;
begin
  GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_IFIRSTDAYOFWEEK, c, SizeOf(c));
  fdw := Ord(c[0]) - Ord('0'); //0 for Monday...6 for Sunday
  Result := ByteToDayOfWeek((fdw + 2) mod 7);   //1 for Sunday...7 for Saturday
end;

procedure DrawSelectedShape(ACanvas: TCanvas; AShape: TSelectedShape; x1, y1, x2, y2: Integer);
begin
  case AShape of
    ssRectangle: ACanvas.Rectangle(x1 - 1, y1 - 1, x2 + 2, y2 + 1);
    ssEllipse: ACanvas.Ellipse(x1, y1, x2, y2);
  end;
end;

//**********************************************************************************
// TgsMonthsColors and TgsCalendarColors
//**********************************************************************************
constructor TgsMonthsColors.Create(AControl: TControl);
begin
  inherited Create;

  FControl := AControl;

  FMonthBackColor := clInfoBk;
  FTitleBackColor := clNavy;
  FCircleColor := clRed;

  FTextColor := clWindowText;
  FHighLightColor := $00FDD8CA;
end;

procedure TgsMonthsColors.SetMonthBackColor(Value: TColor);
begin
  if Value <> FMonthBackColor then
  begin
    FMonthBackColor := Value;
    FControl.Refresh;
  end;
end;

procedure TgsMonthsColors.SetTitleBackColor(Value: TColor);
begin
  if Value <> FTitleBackColor then
  begin
    FTitleBackColor := Value;
    FControl.Refresh;
  end;
end;

//procedure TgsMonthsColors.SetCircleColor(Value: TColor);
//begin
//  if Value <> FCircleColor then
//  begin
//    FCircleColor := Value;
//    FControl.Refresh;
//  end;
//end;

procedure TgsMonthsColors.SetTitleTextColor(Value: TColor);
begin
  if Value <> FTitleTextColor then
  begin
    FTitleTextColor := Value;
    FControl.Refresh;
  end;
end;

procedure TgsMonthsColors.SetTextColor(Value: TColor);
begin
  if Value <> FTextColor then
  begin
    FTextColor := Value;
    FControl.Refresh;
  end;
end;

procedure TgsMonthsColors.SetHighLightColor(Value: TColor);
begin
  if Value <> FHighLightColor then
  begin
    FHighLightColor := Value;
    FControl.Refresh;
  end;
end;

constructor TgsCalendarColors.Create(AControl: TControl);
begin
  inherited;
  FFreeDayColor := clRed;
  FSelectedColor := clGreen;
  FTrailingTextColor := clSilver;
end;

//procedure TgsCalendarColors.SetFreeDayColor(Value: TColor);
//begin
//  if Value <> FFreeDayColor then
//  begin
//    FFreeDayColor := Value;
//    FControl.Refresh;
//  end;
//end;

//procedure TgsCalendarColors.SetSelectedColor(Value: TColor);
//begin
//  if Value <> FSelectedColor then
//  begin
//    FSelectedColor := Value;
//    FControl.Refresh;
//  end;
//end;

procedure TgsCalendarColors.SetTrailingDaysColor(Value: TColor);
begin
  if Value <> FTrailingTextColor then
  begin
    FTrailingTextColor := Value;
    FControl.Refresh;
  end;
end;

//**********************************************************************************
// THolidays
//**********************************************************************************
//function THoliday.GetDisplayName: String;
//begin
//  Result := FName;
//  if Result = '' then
//    Result := inherited GetDisplayName;
//end;
//
//
//constructor THolidays.Create(AOwner: TgsCalendar);
//begin
//  inherited Create(THoliday);
//  FCalendar := AOwner;
//end;
//
//function THolidays.GetOwner: TPersistent;
//begin
//  Result := FCalendar;
//end;
//
//function THolidays.Add(ADay, AMonth: Word): THoliday;
//begin
//  Result := THoliday(inherited Add);
//
//  Result.Day := ADay;
//  Result.Month := AMonth;
//end;
//
//function THolidays.GetHoliday(index: Integer): THoliday;
//begin
//  Result := THoliday(inherited Items[index]);
//end;
//
//procedure THolidays.SetHoliday(index: Integer; Value: THoliday);
//begin
//  Items[index].Assign(Value);
//end;

//**********************************************************************************
// TgsCustomCalendar
//**********************************************************************************
constructor TgsCustomCalendar.Create(AOwner: TComponent);
begin
  inherited;

  //control takes whole canvas of the control
  ControlStyle := ControlStyle + [csOpaque];

  //create font for days and title
  FTextFont := TFont.Create;
  FTextFont.OnChange := FontChanged;

  FTitleFont := TFont.Create;
  FTitleFont.Color := clWhite;
  FTitleFont.Style := [fsBold];
  FTitleFont.OnChange := FontChanged;

  FSelectedShape := ssEllipse;
  //FShowFocusRect := true;

  FUpM := TSpeedButton.Create(Self);
  with FUpM do
  begin
    Parent := Self;
    Glyph.LoadFromResourceName(hInstance, 'NEXTMONTHBUTTON');
    OnClick := BtnPress;
    OnMouseDown := BtnMouseDown;
    OnMouseUp := BtnMouseUp;
    Flat := True;
  end;

  FDownM := TSpeedButton.Create(Self);
  with FDownM do
  begin
    Parent := Self;
    Glyph.LoadFromResourceName(hInstance, 'PREVMONTHBUTTON');
    OnClick := BtnPress;
    OnMouseDown := BtnMouseDown;
    OnMouseUp := BtnMouseUp;
    Flat := True;
  end;

  FUpY := TSpeedButton.Create(Self);
  with FUpY do
  begin
    Parent := Self;
    Glyph.LoadFromResourceName(hInstance, 'NEXTMONTHBUTTON');
    OnClick := BtnPress;
    OnMouseDown := BtnMouseDown;
    OnMouseUp := BtnMouseUp;
    Flat := True;
  end;

  FDownY := TSpeedButton.Create(Self);
  with FDownY do
  begin
    Parent := Self;
    Glyph.LoadFromResourceName(hInstance, 'PREVMONTHBUTTON');
    OnClick := BtnPress;
    OnMouseDown := BtnMouseDown;
    OnMouseUp := BtnMouseUp;
    Flat := True;
  end;

  FTimer := TTimer.Create(Self);
  with FTimer do
  begin
    Enabled := false;
    Interval := 600;
    OnTimer := OnTimerEvent;
  end;

  TabStop := true;
end;

destructor TgsCustomCalendar.Destroy;
begin
  FTextFont.Free;
  FTitleFont.Free;
  inherited;
end;

procedure TgsCustomCalendar.WMGetDlgCode;
begin
  //accept cursor keys
  Message.Result := Message.Result or DLGC_WANTARROWS;
end;

procedure TgsCustomCalendar.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Repaint;
end;

procedure TgsCustomCalendar.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  Repaint;
end;

procedure TgsCustomCalendar.SetTextFont(Value: TFont);
begin
  FTextFont.Assign(Value);
end;

procedure TgsCustomCalendar.SetTitleFont(Value: TFont);
begin
  FTitleFont.Assign(Value);
end;

procedure TgsCustomCalendar.SetBorder(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    Invalidate;
  end;
end;

procedure TgsCustomCalendar.SetSelectedShape(Value: TSelectedShape);
begin
  if Value <> FSelectedShape then
  begin
    FSelectedShape := Value;
    Invalidate;
  end;
end;

procedure TgsCustomCalendar.SetTransparentCursor(Value: Boolean);
begin
  if Value <> FTransparentCursor then
  begin
    FTransparentCursor := Value;
    Invalidate;
  end;
end;

procedure TgsCustomCalendar.FontChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TgsCustomCalendar.BtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender = FUpM then
    FTimerDirection := bdMonthUp
  else if Sender = FDownM then
    FTimerDirection := bdMonthDown
  else if Sender = FUpY then
    FTimerDirection := bdYearDown
  else if Sender = FDownY then
    FTimerDirection := bdYearDown;

  FTimer.Interval := 500; //before timer starts, interval is longer
  FTimer.Enabled := true;
end;

procedure TgsCustomCalendar.BtnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FTimer.Enabled := false;
end;

procedure TgsCustomCalendar.OnTimerEvent(Sender: TObject);
begin
  case FTimerDirection of
    bdMonthUp:
      if PtInRect(FUpM.BoundsRect, ScreenToClient(Mouse.CursorPos)) then
      begin
        FTimer.Interval := 200; //when timer starts, shorten interval
        BtnUpM;
      end;

    bdMonthDown:
      if PtInRect(FDownM.BoundsRect, ScreenToClient(Mouse.CursorPos)) then
      begin
        FTimer.Interval := 200; //when timer starts, shorten interval
        BtnDownM;
      end;

    bdYearUp:
      if PtInRect(FUpY.BoundsRect, ScreenToClient(Mouse.CursorPos)) then
      begin
        FTimer.Interval := 200;
        BtnUpY;
      end;

    bdYearDown:
      if PtInRect(FDownY.BoundsRect, ScreenToClient(Mouse.CursorPos)) then
      begin
        FTimer.Interval := 200;
        BtnDownY;
      end;
  end;
end;

function TgsCustomCalendar.IncTitleHeight: Integer;
begin
  //result := FCellHeight div 4;
  result := 4;
end;

procedure TgsCustomCalendar.PositionButtons;
var
  NewWidth: Integer;
begin
//  FUpM.SetBounds((Width - FUpM.Width - 5), (2 * FCellHeight div 2 - FUpM.Height div 2), 20, 20);
//  FDownM.SetBounds((FUpM.Left - FDownM.Width - 5), FUpM.Top, 20, 20);
  NewWidth := Width div 2 - 10;

  FUpM.SetBounds(  5, 1,                    NewWidth, 9);
  FDownM.SetBounds(5, 2 * FCellHeight - 10 + IncTitleHeight, NewWidth, 9);

  FUpY.SetBounds(Width div 2 + 5,   1,                    NewWidth, 11);
  FDownY.SetBounds(Width div 2 + 5, 2 * FCellHeight - FUpY.Height + IncTitleHeight, NewWidth, 9);
end;

procedure TgsCustomCalendar.SetButtonsParent(ToSelf: Boolean);
begin
  if (csDesigning in ComponentState) then
    if ToSelf then
    begin
      FUpM.Parent := Self;
      FDownM.Parent := Self;
      FUpY.Parent := Self;
      FDownY.Parent := Self;
    end
    else
    begin
      FUpM.Parent := nil;
      FDownM.Parent := nil;
      FUpY.Parent := nil;
      FDownY.Parent := nil;
    end;
end;

procedure TgsCustomCalendar.RecalculateSize;
begin
  //this will cause WMSize to be called
  //that means width and height will be recalculated
  Width := Width + 1;
end;

procedure TgsCustomCalendar.BtnPress(Sender: TObject);
begin
  if not Focused then SetFocus;

  if Sender = FUpM then
    BtnUpM
  else if Sender = FDownM then
    BtnDownM
  else if Sender = FUpY then
    BtnUpY
  else if Sender = FDownY then
    BtnDownY;

end;

procedure TgsCustomCalendar.DrawBorder;
begin
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := clBlack;
  Canvas.Pen.Width := 1;
  Canvas.Rectangle(0, 0, Width, Height);
end;
{
procedure TgsCustomCalendar.DrawFocusRect;
var
  R: TRect;
begin
  R := Rect(1, 1, ClientWidth - 1, ClientHeight - 1);
  Canvas.Pen.Color := clWindowFrame;
  Canvas.Brush.Color := clBtnFace;
  Canvas.DrawFocusRect(R);
end;
}
function TgsCustomCalendar.CanChangeDate(ToDate: TDate): Boolean;
begin
  if FMinDate <> 0 then
    Result := ToDate >= FMinDate
  else
    Result := true;

  if FMaxDate <> 0 then
    Result := Result and (ToDate <= FMaxDate);
end;

procedure TgsCustomCalendar.Paint;
begin
  if BorderStyle = bsSingle then DrawBorder;
  //if Focused and ShowFocusRect then DrawFocusRect;
end;

//**********************************************************************************
// TgsCalendar
//**********************************************************************************
constructor TgsCalendar.Create(AOwner: TComponent);
var
  i: Integer;
  mi: TMenuItem;
begin
  inherited;

  FCellWidth := 23;//~~28;
  FCellHeight := 16;//~~22;

  FTodayString := 'Today: ';

  FNumCols := 7;
  FNumRows := 10;

  FShowTodayCircle := false;
  FShowYear := true;
  FShowTitle := false; ShowTitle := true;{!!}
  FShowToday := false;
  FCanChangeMonthYear := true;

  FSelectedShape := ssRectangle;

  DecodeDate(SysUtils.Date, FYear, FMonth, FDay); //by default, date is today

  FFirstDayOfWeekByte := 2;
  FirstDayOfWeek := LocaleFirstDayOfWeek; //get locale first day of the week

  FCalColors := TgsCalendarColors.Create(Self);
//h  FHolidays := THolidays.Create(Self);

//u  FUpDown := TUpDown.Create(Self);
//  with FUpDown do
//  begin
//    //we don't want to show UpDown at design time
//    if not (csDesigning in ComponentState) then Parent := Self;
//    Visible := false;
//    Min := 1800;
//    Max := 9999;
//    Position := FYear;
//    OnClick := UpDownPress;
//u  end;

  FPopUpMonth := TPopupMenu.Create(Self);
  for i := 1 to 12 do
  begin
    mi := TMenuItem.Create(FPopupMonth);
    mi.Caption := LongMonthNames[i];
    mi.Tag := i;
    mi.OnClick := PopupMonthClick;
    FPopUpMonth.Items.Add(mi);
  end;

  RecalculateSize;
  PositionButtons;
end;

destructor TgsCalendar.Destroy;
begin
  FCalColors.Free;
//h  FHolidays.Free;
  inherited;
end;

procedure TgsCalendar.KeyDown(var Key: Word; Shift: TShiftState);

  procedure SetStartEndDate;
  begin
    if (FStartDate = 0) then
    begin
      FStartDate := Date;
      FEndDate := FStartDate;
    end;
  end;

begin
  inherited;

//u  FUpDown.Visible := false;

  case Key of
    VK_NEXT:  //PageUp - month up, if Ctrl is pressed, year up
      if CanChangeMonthYear then
        if ssCtrl in Shift then
          DoDateChange(Date, EncodeDate(FYear - 1, FMonth, FDay), false, true)
        else
          DoDateChange(Date, IncMonth(Date, -1), false, true);

    VK_PRIOR: //PageDown - month down, if Ctrl is pressed, year down
      if CanChangeMonthYear then
        if ssCtrl in Shift then
          DoDateChange(Date, EncodeDate(FYear + 1, FMonth, FDay), false, true)
        else
          DoDateChange(Date, IncMonth(Date, 1), false, true);

    VK_LEFT:
      if (SelectType = stBlockSelect) and (ssShift in Shift) then
      begin
        SetStartEndDate;
        DoDateChange(Date, Date - 1, false, false);
      end
      else
      begin
        if CanChangeDate(Date - 1) then
          DrawMultiSelect(false);
        DoDateChange(Date, Date - 1, false, true);
      end;

    VK_RIGHT:
      if (SelectType = stBlockSelect) and (ssShift in Shift) then
      begin
        SetStartEndDate;
        DoDateChange(Date, Date + 1, false, false);
      end
      else
      begin
        if CanChangeDate(Date + 1) then
          DrawMultiSelect(false);
        DoDateChange(Date, Date + 1, false, true);
      end;

    VK_UP:
      if (SelectType = stBlockSelect) and (ssShift in Shift) then
      begin
        SetStartEndDate;
        DoDateChange(Date, Date - 7, false, false);
      end
      else
      begin
        if CanChangeDate(Date - 7) then
          DrawMultiSelect(false);
        DoDateChange(Date, Date - 7, false, true);
      end;

    VK_DOWN:
      if (SelectType = stBlockSelect) and (ssShift in Shift) then
      begin
        SetStartEndDate;
        DoDateChange(Date, Date + 7, false, false);
      end
      else
      begin
        if CanChangeDate(Date + 7) then
          DrawMultiSelect(false);
        DoDateChange(Date, Date + 7, false, true);
      end;

    VK_SPACE: JumpToToday;
    VK_RETURN:
      case SelectType of
        stDateSelect: DoOnSelectDate;
        stBlockSelect: DoOnBlockSelect;
      end;
  end;

  if (SelectType = stBlockSelect) and (FStartDate > 0) and (FEndDate > 0) and (FEndDate <> Date) then
  begin
    DrawMultiSelect(false);
    FEndDate := Date;
    DrawMultiSelect(true);
  end;
end;

procedure TgsCalendar.BtnUpM;
begin
//u  FUpDown.Visible := false;
  DoDateChange(Date, IncMonth(Date, 1), false, true);
end;

procedure TgsCalendar.BtnDownM;
begin
//u  FUpDown.Visible := false;
  DoDateChange(Date, IncMonth(Date, -1), false, true);
end;

procedure TgsCalendar.BtnUpY;
begin
//u  FUpDown.Visible := false;
  DoDateChange(Date, EncodeDate(FYear + 1, FMonth, FDay), false, true);
end;

procedure TgsCalendar.BtnDownY;
begin
//u  FUpDown.Visible := false;
  DoDateChange(Date, EncodeDate(FYear - 1, FMonth, FDay), false, true);
end;

//u
//procedure TgsCalendar.UpDownPress(Sender: TObject; Button: TUDBtnType);
//begin
//  case Button of
//    btNext: DoDateChange(Date, EncodeDate(FYear + 1, FMonth, FDay), false, true);
//    btPrev: DoDateChange(Date, EncodeDate(FYear - 1, FMonth, FDay), false, true);
//  end;
//end;

procedure TgsCalendar.PopupMonthClick(Sender: TObject);
var
  y, m, d: Word;
begin
  DecodeDate(Date, y, m, d);

  m := TMenuItem(Sender).Tag;
  if d > DaysInMonth2(y, m) then d := DaysInMonth2(y, m);

  DoDateChange(Date, EncodeDate(y, m, d), false, true);
end;

function TgsCalendar.GetDate: TDate;
begin
  Result := EncodeDate(FYear, FMonth, FDay);
end;

function TgsCalendar.GetDayRow(y: Integer): Integer;
begin
  if ShowTitle then
    Result := y div FCellHeight - 3
  else
    Result := y div FCellHeight - 1;
end;

function TgsCalendar.GetDayCol(x: Integer): Integer;
begin
  if WeekNumbers then
    Result := (x - 5) div FCellWidth - 1
  else
    Result := (x - 5) div FCellWidth;
end;

function TgsCalendar.GetFirstDayCell: Integer;
var
  FirstDay: Integer;
begin
  FirstDay := SysUtils.DayOfWeek(EncodeDate(FYear, FMonth, 1)); //1=sunday do 7=Saturday

  if FFirstDayOfWeekByte < FirstDay then
    Result := FirstDay - FFirstDayOfWeekByte
  else
    Result := 7 - FFirstDayOfWeekByte + FirstDay;
end;

function TgsCalendar.GetStartDate: TDate;
begin
  if FStartDate > FEndDate then
    Result := FEndDate
  else
    Result := FStartDate;
end;

function TgsCalendar.GetEndDate: TDate;
begin
  if FEndDate > FStartDate then
    Result := FEndDate
  else
    Result := FStartDate;
end;


procedure TgsCalendar.DoSize;
begin
  Width := FNumCols * FCellWidth + 10;
  Height := FNumRows * FCellHeight + 6
end;

procedure TgsCalendar.WMSize(var Msg: TWMSize);
begin
  inherited;
  DoSize;
end;
//!! эту процедуру наверное можно удалить
function TgsCalendar.RectOfToday: TRect;
begin
  Canvas.Font.Assign(FTitleFont);
  Canvas.Font.Color := FCalColors.TitleTextColor;
  Result.Left := 5;
  Result.Right := 5 + FCellWidth + 5 + Canvas.TextWidth(FTodayString + DateTimeToStr(Date)) + 5;
  Result.Bottom := Height - 3;
  Result.Top := Result.Bottom - FCellHeight;
end;

function TgsCalendar.RectOfDay(ADay: Word): TRect;
var
  row, col: Word;
begin
  row := (FDayOffset + ADay - 1) div 7;
  col := (FDayOffset + ADay - 1) mod 7;
  Result := RectOfCell(row, col);
end;

function TgsCalendar.RectOfMonth: TRect;
begin
  Canvas.Font.Assign(FTitleFont);
  Canvas.Font.Color := FCalColors.TitleTextColor;
  Result.Left := 5;
//  Result.Right := Result.Left + Canvas.TextWidth(LongMonthNames[FMonth]);
  Result.Right := 5 + Width div 2 - 10;
  Result.Top := FCellHeight - (Canvas.TextHeight(LongMonthNames[FMonth]) div 2);
  Result.Bottom := Result.Top + FCellHeight + IncTitleHeight;
end;

//ufunction TgsCalendar.RectOfYear: TRect;
//begin
//  Canvas.Font.Assign(FTitleFont);
//  Canvas.Font.Color := FCalColors.TitleTextColor;
////  Result.Left := Canvas.TextWidth(LongMonthNames[FMonth]) + 6;
////  Result.Right := Result.Left + Canvas.TextWidth(IntToStr(FYear));
////  Result.Top := FCellHeight - (Canvas.TextHeight(LongMonthNames[FMonth]) div 2);
////  Result.Bottom := Result.Top + FCellHeight;
//
//  Result.Left := Width div 2 + 10;
//  Result.Right := Width - 5;
//  Result.Top := 0;
//  Result.Bottom := Result.Top + 2*FCellHeight;
//uend;

function TgsCalendar.RectOfCell(row, col: Word): TRect;
begin
  if WeekNumbers then
    Result.Left := (col + 1) * FCellWidth + 5
  else
    Result.Left := col * FCellWidth + 5;

  Result.Right := Result.Left + FCellWidth;

  if ShowTitle then
    Result.Top := (FCellHeight * 3 + IncTitleHeight) + row * FCellHeight
  else
    Result.Top := FCellHeight + row * FCellHeight;

  Result.Bottom := Result.Top + FCellHeight;
end;

function TgsCalendar.RectOfDays: TRect;
begin
  if ShowTitle then
    Result.Top := 3 * FCellHeight + IncTitleHeight
  else
    Result.Top := FCellHeight;

  Result.Bottom := Result.Top + 6 * FCellHeight;

  if WeekNumbers then
    Result.Left := FCellWidth + 5
  else
    Result.Left := 5;

  Result.Right := Width - 5;
end;

function TgsCalendar.DoDateChange(FromDate, ToDate: TDateTime; MoveMouse, ResetStartEnd: Boolean): Boolean;
var
  OldYear, OldMonth, OldDay: Word;
  p: TPoint;
  r: TRect;
begin
  if CanChangeDate(ToDate) then
  begin
    Result := true;

    if ResetStartEnd then ResetStartEndDate;

    DecodeDate(ToDate, FYear, FMonth, FDay);
    DecodeDate(FromDate, OldYear, OldMonth, OldDay); //get old year, month and day

    if (OldMonth <> FMonth) or (OldYear <> FYear) then
    begin
      Refresh;

      if MoveMouse then
      begin
        r := RectOfDay(FDay);
        p.x := r.Left + ((r.Right - r.Left) div 2) + ClientOrigin.x;
        p.y := r.Top + ((r.Bottom - r.Top) div 2) + ClientOrigin.y;
        Mouse.CursorPos := p;
      end;
    end
    else
    begin
      DrawNormalDay(RectOfDay(OldDay), OldYear, OldMonth, OldDay);
      DrawSelectedDay(RectOfDay(FDay), FYear, FMonth, FDay);
      DrawTodayCircle;
    end;

    if Assigned(FOnDateChange) then FOnDateChange(Self, FromDate, ToDate);

    if ResetStartEnd and (SelectType = stBlockSelect) then
    begin
      FStartDate := Date;
      FEndDate := FStartDate;
    end;
  end
  else
  begin
    Result := false;
    DecodeDate(FromDate, FYear, FMonth, FDay); //set date back to old date
  end;
end;

function TgsCalendar.AllowMultiSelect: Boolean;
begin
  Result := SelectType = stBlockSelect;
end;

function TgsCalendar.CanChangeDate(ToDate: TDate): Boolean;

  function DateInThisMonth: Boolean;
  var
    y, m, d: Word;
  begin
    DecodeDate(ToDate, y, m, d);
    Result := (m = FMonth);
  end;

begin
  Result := inherited CanChangeDate(ToDate);

  if not CanChangeMonthYear then
    Result := Result and DateInThisMonth;
end;

procedure TgsCalendar.DoOnSelectDate;
begin
  if Assigned(FOnDateSelect) then FOnDateSelect(Self);
end;

procedure TgsCalendar.DoOnBlockSelect;
begin
  if Assigned(FOnBlockSelect) then FOnBlockSelect(Self);
end;

procedure TgsCalendar.SetCellWidth(Value: Integer);
begin
  if FCellWidth <> Value then
  begin
    FCellWidth := Value;
    RecalculateSize;
  end;
end;

procedure TgsCalendar.SetCellHeight(Value: Integer);
begin
  if FCellHeight <> Value then
  begin
    FCellHeight := Value;
    RecalculateSize;
  end;
end;

procedure TgsCalendar.SetShowToday(Value: Boolean);
begin
  if ShowToday <> Value then
  begin
    FShowToday := Value;
    SetNumRows;
    RecalculateSize;
  end;
end;

procedure TgsCalendar.SetWeekNumbers(Value: Boolean);
begin
  if FWeekNumbers <> Value then
  begin
    FWeekNumbers := Value;
    SetNumCols;
    RecalculateSize;
  end;
end;

procedure TgsCalendar.SetShowTodayCircle(Value: Boolean);
begin
  if FShowTodayCircle <> Value then
  begin
    FShowTodayCircle := Value;
    Refresh;
  end;
end;

procedure TgsCalendar.SetShowYear(Value: Boolean);
begin
  if FShowYear <> Value then
  begin
    FShowYear := Value;
    Invalidate;
  end;
end;

procedure TgsCalendar.SetShowTitle(Value: Boolean);
begin
  if FShowTitle <> Value then
  begin
    FShowTitle := Value;
    SetButtonsParent(FShowTitle);
    SetNumRows;
    RecalculateSize;
  end;
end;

//h procedure TgsCalendar.SetHolidays(Value: THolidays);
// begin
//  FHolidays.Assign(Value);
//h end;

procedure TgsCalendar.SetFirstDayOfWeek(Value: TDayOfWeek);
begin
  if FirstDayOfWeek <> Value then
  begin
    FFirstDayOfWeek := Value;
    case Value of
      dwMonday:        FFirstDayOfWeekByte := 2;
      dwTuesday:       FFirstDayOfWeekByte := 3;
      dwWednesday:     FFirstDayOfWeekByte := 4;
      dwThursday:      FFirstDayOfWeekByte := 5;
      dwFriday:        FFirstDayOfWeekByte := 6;
      dwSaturday:      FFirstDayOfWeekByte := 7;
      dwSunday:        FFirstDayOfWeekByte := 1;
    end;
    Refresh;
  end;
end;

procedure TgsCalendar.JumpToToday;
begin
  if DoDateChange(Date, SysUtils.Date, false, false) then
    if SelectType = stBlockSelect then
    begin
      DrawMultiSelect(false);
      FStartDate := Date;
      FEndDate := Date;
      DoOnBlockSelect;
    end;
end;

procedure TgsCalendar.SetMinMaxForMultiSelect(var min, max: TDate);
begin
  if FStartDate < FEndDate then
  begin
    min := FStartDate;
    max := FEndDate;
  end
  else
  begin
    min := FEndDate;
    max := FStartDate;
  end;
end;

procedure TgsCalendar.ResetStartEndDate;
begin
  FStartDate := 0;
  FEndDate := 0;
end;

procedure TgsCalendar.SetNumRows;
var
  i: Integer;
begin
  if ShowTitle then
    i := 8
  else
    i := 6;

  Inc(i);
  if ShowToday then Inc(i);

  FNumRows := i;
end;

procedure TgsCalendar.SetNumCols;
begin
  if FWeekNumbers then
    FNumCols := 8
  else
    FNumCols := 7;
end;

procedure TgsCalendar.GetPrevMonth(var AYear, AMonth: Word);
begin
  AMonth := AMonth - 1;
  if AMonth < 1 then
  begin
    AMonth := 12;
    AYear := AYear - 1;
  end;
end;

procedure TgsCalendar.GetNextMonth(var AYear, AMonth: Word);
begin
  AMonth := AMonth + 1;
  if AMonth > 12 then
  begin
    AMonth := 1;
    AYear := AYear + 1;
  end;
end;

procedure TgsCalendar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;

  procedure DoMonth;
  begin
//u    FUpDown.Visible := false;

    if CanChangeMonthYear then
    begin
      p := ClientToScreen(p);
      FPopupMonth.Popup(p.x, p.y);
    end;
  end;

  procedure DoToday;
  begin
//u    FUpDown.Visible := false;
    JumpToToday;
  end;

//u  procedure DoYear;
//  var
//    R: TRect;
//  begin
//    if CanChangeMonthYear {//u and not FUpDown.Visible} then
//    begin
//     R := RectOfYear;
//     // FUpDown.SetBounds(R.Right + 5, FCellHeight - 12, 20, 24);
//
//     FUpDown.SetBounds(R.Right-15, FCellHeight - 12, 20, 24);
//     FUpDown.BringToFront;
//     FUpDown.Visible := true;
//    end;
//u  end;

  procedure DoDay;
  var
    diff: Integer;
    col, row: Integer;
    OldMonth: Word;
    b: Boolean;
  begin
//u    FUpDown.Visible := false;

    OldMonth := FMonth;

    row := GetDayRow(y);
    col := GetDayCol(x);

    diff := (row * 7 + (col + 1) - FDayOffset) - FDay;

    if (FStartDate <> FEndDate) and CanChangeDate(Date + diff) then
      DrawMultiSelect(false);

    b := DoDateChange(Date, Date + diff, SelectType = stBlockSelect, true);

    if (FMonth = OldMonth) and (SelectType = stDateSelect) then DoOnSelectDate;

    if b and AllowMultiSelect then
      FMouseDown := true;
  end;

begin
  inherited;

  //if ssDouble in Shift then
  if (Owner<>nil) and TWinControl(Owner).Visible and not Focused then
    SetFocus;

  p.x := x;
  p.y := y;

  if ShowTitle and PtInRect(RectOfMonth, p) then DoMonth                 //if user clicked onto month, bring up pop up menu to select month
  //u else if ShowTitle and ShowYear and PtInRect(RectOfYear, p) then DoYear //if user clicked onto year, bring up spin edit to change year
  else if PtInRect(RectOfDays, p) then DoDay                             //if user clicked onto one of the days, switch to that day
  else if ShowToday and PtInRect(RectOfToday, p) then DoToday            //if user clicked onto today, switch to today
end;

procedure TgsCalendar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
  diff: Integer;
  col, row: Integer;
begin
  inherited;

  if FMouseDown then
  begin
    p.x := x;
    p.y := y;

    if PtInRect(RectOfDays, p) then
    begin
      row := GetDayRow(y);
      col := GetDayCol(x);

      diff := (row * 7 + (col + 1) - FDayOffset) - FDay;

      if diff <> 0 then
        DoDateChange(Date, Date + diff, true, false);
    end;

    if FEndDate <> Date then
    begin
      DrawMultiSelect(false);
      FEndDate := Date;
      DrawMultiSelect(true);
    end;
  end;
end;

procedure TgsCalendar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if FMouseDown then
  begin
    FMouseDown := false;
    DoOnBlockSelect;
  end;
end;

procedure TgsCalendar.DoExit;
begin
//u  FUpDown.Visible := false;
  inherited;
end;

//function TgsCalendar.IsHoliday(ADate: TDate): Boolean;
//var
//  y, m, d: Word;
//h begin
//  DecodeDate(ADate, y, m, d);
//  Result := IsDateHoliday(d, m);
//h end;

//function TgsCalendar.IsDateHoliday(ADay, AMonth: Word): Boolean;
//var
//  i: Integer;
//h begin
//  Result := false;
//  for i := 0 to FHolidays.Count - 1 do
//    if (FHolidays.Items[i].Month = AMonth) and (FHolidays.Items[i].Day = ADay) then
//    begin
//      Result := true;
//      Break;
//    end;
//h end;

function TgsCalendar.DayNumber: Word;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to FMonth - 1 do
    Result := Result + DaysInMonth2(FYear, i);
  Result := Result + FDay;
end;

procedure TgsCalendar.SetDate(Value: TDate);
begin
  if Date <> Value then
  begin
    DecodeDate(Value, FYear, FMonth, FDay);
    Invalidate;
  end;
end;

procedure TgsCalendar.SetCalColors(Value: TgsCalendarColors);
begin
  FCalColors.Assign(Value);
end;

procedure TgsCalendar.SetSelectType(Value: TSelectType);
begin
  if FSelectType <> Value then
  begin
    FSelectType := Value;
    Invalidate;
  end;
end;

procedure TgsCalendar.SetCanChangeMonthYear(Value: Boolean);
begin
  if FCanChangeMonthYear <> Value then
  begin
    FCanChangeMonthYear := Value;
    SetButtonsParent(FCanChangeMonthYear);
  end;
end;

procedure TgsCalendar.SetYear(Value: Word);
begin
  if Value <> FMonth then
  begin
    FYear := Value;
    Invalidate;
  end;
end;

procedure TgsCalendar.SetMonth(Value: Word);
begin
  if Value <> FMonth then
  begin
    FMonth := Value;
    Invalidate;
  end;
end;

procedure TgsCalendar.SetDay(Value: Word);
begin
  if Value <> FMonth then
  begin
    FDay := Value;
    Invalidate;
  end;
end;

function TgsCalendar.WeekNumber(ADate: TDate): Integer;
var
  AYear, AMonth, ADay: Word;
  StartOfYear:  TDate;
  plus: Integer;
  DaysToEndOfWeek: Integer;


  function GetDaysToEndOfWeek: Integer;
  var
    ADay: Integer;
  begin
    Result := 0;
    ADay := SysUtils.DayOfWeek(StartOfYear);
    while ADay <> FFirstDayOfWeekByte do
    begin
      Inc(Result);
      Inc(ADay);
      if ADay > 7 then ADay := 1;
    end;
  end;

begin
  DecodeDate(ADate, AYear, AMonth, ADay);
  StartOfYear := EncodeDate(AYear, 1, 1);

  DaysToEndOfWeek := GetDaysToEndOfWeek;

  if DaysToEndOfWeek > 3 then
    plus := 6 + SysUtils.DayOfWeek(StartOfYear) - FFirstDayOfWeekByte
  else
    plus := 7 - DaysToEndOfWeek;

  Result := (Trunc(ADate - StartOfYear) + 1 + plus) div 7;
  if Result = 53 then
  begin
    //if we have week number 53, it can very much be first week in the next year
    //it's easy to check
    //if next week is number 2 that means that this week is number 1
    //in next year and not number 53 in this year
    if WeekNumber(ADate + 7) = 2 then Result := 1;
  end;
end;

procedure TgsCalendar.DrawMonth;
var
  R: TRect;
  str: String;
begin
  FUpM.Visible := CanChangeMonthYear and ShowTitle;
  FDownM.Visible := FUpM.Visible;
  FUpY.Visible := FUpM.Visible;
  FDownY.Visible := FUpM.Visible;

  if ShowTitle then
  begin
    R := ClientRect;
    R.Bottom := 2 * FCellHeight + IncTitleHeight; //this rect will paint across first two rows
    Canvas.Brush.Color := FCalColors.TitleBackColor;
    Canvas.FillRect(R);

   //dbg Canvas.Brush.Color := clLime;
    R.Left := 5; //We want a bit of a margin at the left
    R.Right:= Width div 2 + 5;
    Canvas.Font.Assign(FTitleFont);
    Canvas.Font.Color := FCalColors.TitleTextColor;
    str := LongMonthNames[FMonth];
    Canvas.FillRect(R);
    DrawText(Canvas.Handle, PChar(str), Length(str), R, DT_SINGLELINE + DT_CENTER + DT_VCENTER);
    PositionButtons;

    if FShowYear then begin
      str := IntToStr(FYear);
      R.Left := Width div 2 + 10;
      R.Right := Width - 5;
   //dbg Canvas.Brush.Color := clYellow;
      DrawText(Canvas.Handle, PChar(str), Length(str), R, DT_SINGLELINE + DT_CENTER + DT_VCENTER);
    end;

  end;
end;

procedure TgsCalendar.DrawDayNames;
var
  R: TRect;
  str: String;
  col: Integer;
begin
  R := ClientRect;
  if ShowTitle then
    R.Top := 2 * FCellHeight + IncTitleHeight
  else
    R.Top := 0;
  R.Bottom := R.Top + FCellHeight;
  Canvas.Brush.Color := FCalColors.MonthBackColor;
  Canvas.FillRect(R);

  Canvas.Pen.Width := 1;
  Canvas.Pen.Color := FCalColors.TitleBackColor;
  Canvas.MoveTo(5, R.Bottom - 1);
  Canvas.LineTo(Width - 5, R.Bottom - 1);

  Canvas.Font.Assign(FTextFont);
  Canvas.Font.Color := FCalColors.TextColor;//~~TitleBackColor; {DrawDayNames}

  for col := 0 to 6 do
  begin
    if (col in [5,6]) then
      Canvas.Font.Color := FCalColors.FFreeDayColor//!!
    else
      Canvas.Font.Color := FCalColors.TextColor;

    R.Left := (col + (FNumCols - 7)) * FCellWidth + 5;
    R.Right := R.Left + FCellWidth;
    str := ShortDayNames[(col + FFirstDayOfWeekByte - 1) mod 7 + 1];
    DrawText(Canvas.Handle, PChar(str), Length(str), R, DT_SINGLELINE + DT_VCENTER + DT_CENTER);
  end;
end;{<- TgsCalendar.DrawDayNames}

procedure TgsCalendar.DrawDays;
var
  R: TRect;
  i: Integer;
  cell: Byte;
  TmpMonth, TmpYear: Word;
begin
  R := ClientRect;
  if WeekNumbers then
    R.Left := FCellWidth;
  if ShowTitle then
    R.Top := 3 * FCellHeight + IncTitleHeight
  else
    R.Top := FCellHeight;
  R.Bottom := R.Top + 6 * FCellHeight + 2;

  Canvas.Brush.Color := FCalColors.MonthBackColor;
  Canvas.FillRect(R);

  cell := 0;
  FDayOffset := GetFirstDayCell;

  //draw days of previous month
  TmpYear := FYear;
  TmpMonth := FMonth;
  GetPrevMonth(TmpYear, TmpMonth);

  for i := DaysInMonth2(TmpYear, TmpMonth) - FDayOffset + 1 to DaysInMonth2(TmpYear, TmpMonth) do
  begin
    DrawNormalDay(RectOfCell(cell div 7, cell mod 7), TmpYear, TmpMonth, i);
    Inc(cell);
  end;

  //draw days of this month
  for i := 1 to DaysInMonth2(FYear, FMonth) do
  begin
    DrawNormalDay(RectOfCell(cell div 7, cell mod 7), FYear, FMonth, i);
    Inc(cell);
  end;

  //draw days of next month
  TmpYear := FYear;
  TmpMonth := FMonth;
  GetNextMonth(TmpYear, TmpMonth);

  for i := 1 to 42 - cell do
  begin
    DrawNormalDay(RectOfCell(cell div 7, cell mod 7), TmpYear, TmpMonth, i);
    Inc(cell);
  end;

  if SelectType = stBlockSelect then
    DrawMultiSelect(true);

  DrawDatePosition;
end;

procedure TgsCalendar.DrawMultiSelect(selected: Boolean);
var
  i, min, max: TDate;
  AYear, AMonth, ADay: Word;
  cell: Integer;

  function PrevMonth(AMonth: Word): Word;
  var
    TmpYear: Word;
  begin
    TmpYear := FYear;
    Result := AMonth;
    GetPrevMonth(TmpYear, Result);

    if (Result = 12) and not (TmpYear = FYear - 1) then
      Result := 0;
  end;

  function NextMonth(AMonth: Word): Word;
  var
    TmpYear: Word;
  begin
    TmpYear := FYear;
    Result := AMonth;
    GetNextMonth(TmpYear, Result);

    if (Result = 1) and not (TmpYear = FYear + 1) then
      Result := 0;
  end;

  procedure Draw(R: TRect; Grayed: Boolean);
  begin
    if selected then
      DrawSelectedDay(R, AYear, AMonth, ADay)
    else
      DrawNormalDay(R, AYear, AMonth, ADay)
  end;

begin
  SetMinMaxForMultiSelect(min, max);

  if (min <> 0) and (max <> 0) then
  begin
    i := min;

    while i <= max do
    begin
      DecodeDate(i, AYear, AMonth, ADay);

      if (AYear = FYear) and (AMonth = FMonth) then
        Draw(RectOfDay(ADay), false)
      else
      begin
        if (AMonth = PrevMonth(FMonth)) and (ADay > DaysInMonth2(FYear, AMonth) - GetFirstDayCell) then
        begin
          cell := ADay - DaysInMonth2(FYear - 1, AMonth) + GetFirstDayCell - 1;
          Draw(RectOfCell(cell div 7, cell mod 7), true);
        end
        else if (AMonth = NextMonth(FMonth)) and (ADay + DaysInMonth2(FYear, AMonth) + GetFirstDayCell < 42) then
        begin
          cell := GetFirstDayCell + DaysInMonth2(FYear, FMonth) + ADay - 1;
          Draw(RectOfCell(cell div 7, cell mod 7), true);
        end;
      end;

      i := i + 1;
    end;

    DrawTodayCircle;
  end;
end;

procedure TgsCalendar.DrawWeekNumbers;
var
  R: TRect;
  str: String;
  row: Integer;
  ADate: TDate;
begin
  if WeekNumbers then
  begin
    R := ClientRect;
    if ShowTitle then
      R.Top := 3 * FCellHeight + IncTitleHeight
    else
      R.Top := FCellHeight;
    R.Right := FCellWidth;
    R.Bottom := R.Top + 6 * FCellHeight + 2{6};
    Canvas.Brush.Color := FCalColors.MonthBackColor;
    Canvas.FillRect(R);

    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := FCalColors.TitleBackColor;
    Canvas.MoveTo(FCellWidth - 1, R.Top + 2);
    Canvas.LineTo(FCellWidth - 1, R.Bottom + 1);

    Canvas.Brush.Color := FCalColors.MonthBackColor;
    Canvas.Font.Color := FCalColors.TextColor; //~~TitleBackColor; {DrawWeekNumbers}
    Canvas.Font.Style := [];

    //first day on the calendar
    ADate := EncodeDate(FYear, FMonth, 1) - FDayOffset;

    if ShowTitle then
      row := 3
    else
      row := 1;

    for row := row to row + 5 do
    begin
      R.Top := row * FCellHeight;
      R.Bottom := R.Top + FCellHeight;

      str := IntToStr(WeekNumber(ADate));
      ADate := ADate + 7;

      DrawText(Canvas.Handle, PChar(str), Length(str), R, DT_SINGLELINE + DT_VCENTER + DT_CENTER);
    end;
  end;
end;
//!! Эту процедуру можно наверное удалить
procedure TgsCalendar.DrawToday;
var
  R: TRect;
  str: String;
begin
  if ShowToday then
  begin
    R := ClientRect;
    R.Top := (FNumRows - 1) * FCellHeight;
    R.Bottom := FNumRows * FCellHeight + 6;
    Canvas.Brush.Color := FCalColors.MonthBackColor;
    Canvas.FillRect(R);

    R := RectOfToday;
    str := FTodayString + DateTimeToStr(SysUtils.Date);

    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := FCalColors.TitleBackColor;
    Canvas.MoveTo(5, R.Top - 1);
    Canvas.LineTo(FNumCols * FCellWidth + 5, R.Top - 1);

    Canvas.Pen.Width := 3;
    Canvas.Pen.Color := FCalColors.FCircleColor;
    DrawSelectedShape(Canvas, FSelectedShape, R.Left + 1, R.Top + 3, R.Left + FCellWidth - 1, R.Bottom - 1);
    Canvas.Font.Color := FTextFont.Color;
    Canvas.Font.Style := [fsBold];
    Canvas.TextOut(R.Left + FCellWidth + 5, (R.Top + (R.Bottom - R.Top) div 2) - Canvas.TextHeight(str) div 2 + 1, str);
    Canvas.Font.Style := [];
  end;
end; {<- TgsCalendar.DrawToday}
//!! Эту процедуру можно наверное удалить
procedure TgsCalendar.DrawTodayCircle;
var
  R: TRect;
  AYear, AMonth, ADay: Word;
begin
  if FShowTodayCircle then
  begin
    DecodeDate(SysUtils.Date, AYear, AMonth, ADay);
    if (AYear = FYear) and (AMonth = FMonth) then
    begin
      Canvas.Brush.Style := bsClear;
      Canvas.Pen.Width := 3;
      Canvas.Pen.Color := FCalColors.FCircleColor;
      R := RectOfDay(ADay);
      InflateRect(R, 1, 1);
      DrawSelectedShape(Canvas, FSelectedShape, R.Left + 1, R.Top + 1, R.Right - 1, R.Bottom - 1)
    end;
  end;
end;

procedure TgsCalendar.DrawDatePosition;
var
  cell: Byte;
  R: TRect;
begin
  cell := FDay + FDayOffset - 1;
  R := RectOfCell(cell div 7, cell mod 7);
  DrawSelectedDay(R, FYear, FMonth, FDay);
end;

procedure TgsCalendar.SetNormalCanvas(AYear, AMonth, ADay: Word);
begin
  Canvas.Font.Assign(FTextFont);
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FCalColors.MonthBackColor;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Color := FCalColors.TitleBackColor;

  if AMonth <> Month then
    Canvas.Font.Color := FCalColors.TrailingTextColor
  else
  {выделение выходных дней недели перенесено в DrawDayNames}
//h    if {(SysUtils.DayOfWeek(EncodeDate(AYear, AMonth, ADay)) in [1,7])
//h      or} IsDateHoliday(ADay, AMonth) then
//h      Canvas.Font.Color := FCalColors.FreeDayColor
//h    else
    Canvas.Font.Color := FCalColors.TextColor;
end;

procedure TgsCalendar.SetSelectedCanvas(AYear, AMonth, ADay: Word; Grayed: Boolean);
begin
  Canvas.Font.Assign(FTextFont);
  Canvas.Pen.Color := FCalColors.TitleBackColor;
  //~~- Canvas.Brush.Color := FCalColors.TitleBackColor;
  Canvas.Brush.Color := FCalColors.HighLightColor;

  if TransparentCursor then
    Canvas.Brush.Style := bsClear;

  if Grayed then
    Canvas.Font.Color := FCalColors.TrailingTextColor
  else
    if TransparentCursor then
      Canvas.Font.Color := clBlack
    else begin
      Canvas.Brush.Color := FCalColors.HighLightColor;
      if Focused then begin
        Canvas.Font.Color := clBlue;
        Canvas.Brush.Style := bsSolid;
      end else begin
        Canvas.Font.Color := clBlack{clWhite~~};
        Canvas.Brush.Style := bsClear;
      end;
    end;
end;

procedure TgsCalendar.DrawDayText(R: TRect; const s: String);
begin
  Canvas.Brush.Style := bsClear;
  DrawText(Canvas.Handle, PChar(s), Length(s), R, DT_SINGLELINE + DT_VCENTER + DT_CENTER);
end;

procedure TgsCalendar.DrawNormalDay(R: TRect; AYear, AMonth, ADay: Word);
begin
  SetNormalCanvas(AYear, AMonth, ADay);
  Canvas.FillRect(R);
  DrawDayText(R, IntToStr(ADay));
end;

procedure TgsCalendar.DrawSelectedDay(R: TRect; AYear, AMonth, ADay: Word);
begin
  SetNormalCanvas(AYear, AMonth, ADay);
  Canvas.FillRect(R);
  SetSelectedCanvas(AYear, AMonth, ADay, AMonth <> Month);
  DrawSelectedShape(Canvas, FSelectedShape, R.Left + 2, R.Top + 2, R.Right - 2, R.Bottom - 2);
  DrawDayText(R, IntToStr(ADay));
end;

procedure TgsCalendar.Paint;
begin
  DrawMonth;
  DrawDayNames;
  DrawDays;
  DrawTodayCircle;
  DrawWeekNumbers;
  DrawToday;
  inherited;
end;


procedure Register;
begin
  RegisterComponents('x-VisualControl', [TgsCalendar]);
end;

end.
