
{++

  Components TxCalendar and etc.
  Copyright (c) 1996-97 by Golden Software of Belarus

Module

  xcalend.pas

Abstract

  Different kinds of calendars and date inputs. Databases connection.
  Multilangual support.

Author

  Vladimir Belyi (1-April-1996)

Contact address

  support@gsbelarus.com
  www.gsbelarus.com

Uses

  xCalenF.pas, xCalendF.dfm - additional form to add holidays
  xSpin                     - component to draw SpinButton
  xWorld                    - component providing unique multilangual support

Revisions history

  1.00   1-Apr-1996  Belyi    Basic version.
  1.0x               belyi    No comments for versions 1.01 through 1.09.
  1.10   1-Jul-1996  Belyi    Minor modifications (comparing with 1.09)
  1.11   2-Jul-1996  Belyi    3D properties added
                              null date added
  1.12   5-Jul-1996  Belyi    Popup menu for holidays
  1.13   9-Jul-1996  Belyi    A lot of waste code (with bugs)
                              was deleted. A lot of was optimized.
  1.14  11-Jul-1996  Belyi    Min & MaxDates added + minor changes
  1.15  16-Jul-1996  Belyi    default values added + minor changes
  1.16  16-Jul-1996  andreik  HasValidDate function added;
                              Defaults changed.
  1.17  20-Jul-1996  andreik  Fixed bug with current date substitution.
  1.18  30-Jul-1996  andreik  Fixed bug with saving date in TxDBCalendarCombo.
  1.19  21-Aug-1996  Belyi    International support basics.
  1.20  27-Aug-1996  Belyi    Complete multilangual support.
  1.21  29-Aug-1996  Belyi    HolidaysDatabaseName & HolidaysTableName. +
                              Revision and updating.
  1.22  03-sep-1996  andreik  Fixed bug with NULL dates.
  1.23  10-sep-1996  Belyi    Fixed bug in combo for HolidaysTableName property.
  1.24  11-sep-1996  andreik  Fixed bug with focusing of disabled window.
  1.25  13-sep-1996  Belyi    Icons added. Moduls modifications.
  1.26  30-sep-1996  Belyi    Fixed bug with forcing table to edit mode and
                              calling UpdateRecord method.
  1.27  12-oct-1996  belyi    DateIsValid in TxDateEdit added. Less internal
                              exceptions are raised. First attempt to
                              recompile with Delphi 2.0 - internal error
                              C1217 (on-line help asked to contact Borland).
  2.00   8-dec-1996    >      I've recompiled this unit with Delphi 2.0 - but
                              now holidays may not be displayed in some cases.
                              Let's wait for newer versions of Delphi.
  2.01   5-mar-1997  andreik  Fixed bug with typecasting.
  2.02  30-oct-1997  andreik  Fixed minor bug.
  2.03  25-nov-1997  andreik  xcalend.res file added. String resource base 19600.
  2.04  21-dec-1997  andreik  property Visible added to xCalendarCombo.

--}

{$A+,B-,D+,K+,L-,P+,Q-,T-,V+,W-,X+}

unit xCalend;

interface

{*$R XCALEND.RES*}

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Menus, Buttons, DB, DBTables,
  Mask, xSpin, xWorld, DsgnIntF, xCalInit, dbctrls;

type
  TForMonth = (tLast, tThis, tNext);
  TShowOnMouse = (msRect, msLeft, msRight);
  TShowsOnMouse = set of TShowOnMouse;

  TFullShape = class(TShape) {for internal use only}
    private
      NextTic: Integer;
      OldCapture: TControl;
      DoCapture: Boolean;
      MouseIsDown: Boolean;

    protected
      procedure Paint; override;
      procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

      procedure WMLButtonDown(var Message: TWMLButtonDown);
        message WM_LBUTTONDOWN;
      procedure WMLButtonUp(var Message: TWMLButtonUp);
        message WM_LBUTTONUP;

    public
      HasDate: Boolean;
      UnderMouse: Boolean;
      MDelta: Integer;
      MColor: TColor;
      TColorNonfocused, TColorFocused: TColor;
      OutColor: TColor;
      ShowOnMouse: TShowsOnMouse;
      AMonth: TForMonth;
      BoxColor: TColor;
      Aday: Integer;
      CText: String;
      CColor: TColor;
      OnTics: Boolean;
      MousePress: TNotifyEvent;

      property Canvas;

      constructor Create(AOwner: TComponent); override;

      procedure TimerTic;
      procedure GetDate(const Year, Month, Day: Integer;
                        var TheYear, TheMonth, TheDay: Integer);
  end;

type
  TMonth = array[1..7, 0..6] of TFullShape;
  TYear = array[1..4, 1..3] of TFullShape;

type
  TPanels = (pYear, pMonth);
  TWeekDays = (wSunday, wMonday, wTuesday, wWednesday,
               wThursday, wFriday, wSaturday);
  TDayType = (dtWorkingDay, dtWeekend, dtHoliday);

const
  PermanentHoliday = 1900;

const
  { properties' defaults }
  DefButtonHeight          = 18;
  DefCalWidth              = 200;
  DefCalHeight             = 200;
  DefEditWidth             = 121;
  DefEditHeight            = 22;
  DefCtl3D                 = True;
  DefParentFont            = False;
  DefArrowFocusedColor     = clRed;
  DefArrowColor            = clBlack;
  DefArrowWidth            = 14;
  DefAutoShowMonth         = True;
  DefBevelInner            = bvNone;
  DefBevelOuter            = bvRaised;
  DefBevelWidth            = 2;
  DefFontName              = 'MS Sans Serif';
  DefFontSize              = 8;
  DefFontStyle             = [];
  DefBorderStyle           = bsNone;
  DefBorderWidth           = 2;
  DefColorOfThisMonthDays  = clBtnText;
  DefColorOfOtherMonthDays = clGrayText;
  DefComboEditCtl3D        = True;
  DefComboCtl3D            = True;
  DefComboHeight           = 130;
  DefComboWidth            = 140;
  DefCurBKColor            = clRed;
  DefCurColor              = clBlue;
  DefHeadColor             = clNavy;
  DefHeadBKColor           = $C0FFFF;
  DefHeadOuterColor        = $C0FFFF;
  DefBKColor               = $C0FFFF;
  DefOuterColor            = clBlack;
  DefHolidayColor          = clRed;
  DefGapActiveColor        = $C0FFFF;
  DefGapInactiveColor      = $C0FFFF;
  DefGapColor              = DefGapActiveColor;
  DefDelay                 = 84;
  DefMonthRectColor        = clRed;
  DefGapWidth              = 0;
  DefStartOfWeek           = 2;       { !! correlate with DefStartOfWeekDay }
  DefStartOfWeekDay        = wMonday; { !! correlate with DefStartOfWeek    }
  DefForceToday            = True;
  DefButtonBKColor         = $C0FFFF;

type
  TxCalendar = class(TCustomControl)
  private
    MainPanel: TPanel;
    InRefreshing: Boolean;
    NewPage: Boolean;
    NewDate: Boolean;
    PrevMonth: TFullShape;
    NextMonth: TFullShape;
    TheMonth: TFullShape;
    MPanel: TPanel;
    MShape: TMonth;
    YPanel: TPanel;
    YShape: TYear;
    IsHiding: Integer;
    UpdateWasCalled: Boolean;
    ChangeOnMove: Boolean;
    HaveDB: Boolean;
    HTable: TTable;
    HDataSource: TDataSource;
    DateOnPress: TDateTime;
    Timer: TTimer;
    ChangingOnKey: Boolean;
    FInCombo: Boolean; { True when a part of a combo }
    PMenu: TPopupMenu;

    FMinDate: TDateTime;
    FMaxDate: TDateTime;
    FStartOfWeek: Integer;
{    FHolidaysDatabaseName: TFileName;
    FHolidaysTableName: TFileName;}
    FDate: TDateTime;
    FForceTodayOnStart: Boolean;
    FRememberDate: Boolean; { = not ForceTodayOnStart }
    FHolidayColor: TColor;
    FColorOfThisMonthDays: TColor;
    FColorOfOtherMonthDays: TColor;
    FCurColor: TColor;
    FCurBKColor: TColor;
    FHeadColor: TColor;
    FHeadBKColor: TColor;
    FHeadOuterColor: TColor;
    FBKColor: TColor;
    FOuterColor: TColor;
    FFont: TFont;
    FHeadFont: TFont;
    FButtonFont: TFont;
    FGapWidth: Integer;
    MLastI, MLastJ: Integer;
    YLastI, YLastJ: Integer;
    FPanel: TPanels;
    FOnPageChange: TNotifyEvent;
    FOnDateChanging: TNotifyEvent;
    FOnDateChanged: TNotifyEvent;
    FButtonHeight: Integer;
    FArrowWidth: Integer;
    FAutoShowMonth: Boolean;
    FGapActiveColor: TColor;
    FGapInactiveColor: TColor;
    FButtonBKColor: TColor;
    FOnClick: TNotifyEvent;
    function GetYear: Integer;
    function GetDay: Integer;
    function GetMonth: Integer;
    function GetMonthName: String;
    function GetBevelInner: TPanelBevel;
    function GetBevelOuter: TPanelBevel;
    function GetBevelWidth: TBevelWidth;
    function GetBorderWidth: TBorderWidth;
    function GetBorderStyle: TBorderStyle;
    function GetArrowFocusedColor: TColor;
    function GetArrowColor: TColor;
    function GetMonthRectColor: TColor;
    function GetDayTypeStr: String;
    function GetDelay: Integer;
    procedure SetDelay(Value: Integer);
    procedure SetMonthRectColor(Value: TColor);
    procedure SetArrowFocusedColor(Value: TColor);
    procedure SetArrowColor(Value: TColor);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetGapActiveColor(AColor: TColor);
    procedure SetGapInactiveColor(AColor: TColor);
    procedure SetBevelInner(Value: TPanelBevel);
    procedure SetBevelOuter(Value: TPanelBevel);
    procedure SetBevelWidth(Value: TBevelWidth);
    procedure SetBorderWidth(Value: TBorderWidth);
    procedure SetGapWidth(W: Integer);
    procedure SetButtonHeight(H: Integer);
    procedure SetArrowWidth(W: Integer);
    procedure SetHolidayColor(AColor: TColor);
    procedure SetColorOfThisMonthDays(AColor: TColor);
    procedure SetColorOfOtherMonthDays(AColor: TColor);
    procedure SetCurColor(AColor: TColor);
    procedure SetCurBKColor(AColor: TColor);
    procedure SetHeadColor(AColor: TColor);
    procedure SetHeadBKColor(AColor: TColor);
    procedure SetHeadOuterColor(AColor: TColor);
    procedure SetBKColor(AColor: TColor);
    procedure SetOuterColor(AColor: TColor);
    procedure SetFont(AFont: TFont);
    procedure SetHeadFont(AFont: TFont);
    procedure SetButtonFont(AFont: TFont);
    procedure SetPanel(APanel: TPanels);
    procedure SetMonth(AMonth: Integer);
    procedure SetMonthName(AName: String);
    procedure SetYear(AYear: Integer);
    procedure SetDay(ADay: Integer);
    procedure SetDate(ADate: TDateTime);
    function GetHolidaysDatabaseName: TFileName;
    function GetHolidaysTableName: TFileName;
    procedure SetHolidaysDatabaseName(Value: TFileName);
    procedure SetHolidaysTableName(Value: TFileName);
    function GetMinDate: String;
    procedure SetMinDate(Value: String);
    function GetMaxDate: String;
    procedure SetMaxDate(Value: String);
    function GetStartOfWeek: TWeekDays;
    procedure SetStartOfWeek(Value: TWeekDays);
    procedure SetInCombo(Value: Boolean);
    procedure SetForceTodayOnStart(Value: Boolean);
    function GetCalendarDate: String;
    procedure SetCalendarDate(Value: String);
    function GetDayType: TDayType;
    procedure SetButtonBKColor(Value: TColor);

    procedure ActivateTable;
    procedure MonthShapePressed(Sender: TObject);
    procedure SetSizes;
    procedure ShapeMouseMoved(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure ShapeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShapeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FontChanged(Sender: TObject);
    procedure RefreshMonth;
    procedure UpdateMonth;
    procedure UpdateYear;
    procedure SetRect(Shape: TFullShape);
    procedure TimerTic(Sender: TObject);
    procedure SetParentFont(Value: Boolean);
    procedure SetCtl3D(Value: Boolean);
    procedure AddHoliday(Sender: TObject);
    procedure DeleteHoliday(Sender: TObject);
    procedure InfoHoliday(Sender: TObject);
    procedure MenuPopup(Sender: TObject);

    property InCombo: Boolean read FInCombo write SetInCombo;

  protected
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMSetFocus(var Message: TWMSetFocus);
      message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_SYSKEYDOWN;
    procedure WMGetDlgCode(var Message: TMessage);
      message WM_GETDLGCODE;
    procedure WMLanguageChange(var Message: TMessage);
      message WM_LANGUAGECHANGE;

    procedure PageChanged; virtual;
    procedure DateChanging; virtual;
    procedure DateChanged; virtual;
    procedure UpdateHead;
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Click; override;{ called whenever user tries to influence
                                the data }
    procedure CutDates(var ADate: TDateTime);

  public
    procedure Update; override;
    procedure Repaint; override;
    procedure DefaultHandler(var Message); override;

    constructor Create(AOwner: TComponent); override;
    destructor destroy; override;
    function DaysPerMonth(AYear, AMonth: Integer): Integer; virtual;
    function DaysThisMonth: Integer; virtual;
    function DaysLastMonth: Integer; virtual;
    function IsLeapYear(AYear: Integer): Boolean; virtual;
    function IsItHoliday(AYear, AMonth, ADay: Integer): Boolean;
    procedure Paint; override;

    procedure HiDechanges; virtual;
    procedure ShowChanges; virtual;
    property Date: TDateTime read FDate write SetDate;
    procedure GoNextYear;
    procedure GoPrevYear;
    procedure GoNextMonth;
    procedure GoPrevMonth;
    procedure GoNextDay;
    procedure GoPrevDay;
    procedure ShiftDay(Step: Integer);
    procedure ShiftMonth(Step: Integer);

    function TypeOfDayStr(ADate: TDateTime): String;
    function TypeOfDay(ADate: TDateTime): TDayType;

  published
    property ButtonBKColor: TColor read FButtonBKColor write SetButtonBKColor
      default DefButtonBKColor;
    property CalendarDate: String read GetCalendarDate write SetCalendarDate
      stored False;
    property MinDate: String read GetMinDate write SetMinDate;
    property MaxDate: String read GetMaxDate write SetMaxDate;
    property StartOfWeek: TWeekDays read GetStartOfWeek write SetStartOfWeek;
    property Delay: Integer read GetDelay write SetDelay default DefDelay;
    property DayType: TDayType read GetDayType;
    property DayTypeStr: String read GetDayTypeStr;
    property HolidaysDatabaseName: TFileName read GetHolidaysDatabaseName
      write SetHolidaysDatabaseName;
    property HolidaysTableName: TFileName read GetHolidaysTableName
      write SetHolidaysTableName;
    property ArrowFocusedColor: TColor read GetArrowFocusedColor
      write SetArrowFocusedColor default DefArrowFocusedColor;
    property ArrowColor: TColor read GetArrowColor
      write SetArrowColor default DefArrowColor;
    property MonthRectColor: TColor read getMonthRectColor
      write SetMonthRectColor default DefMonthRectColor;
    property GapActiveColor: TColor read FGapActiveColor
      write SetGapActiveColor default DefGapActiveColor;
    property GapInactiveColor: TColor read FGapInactiveColor
      write SetGapInactiveColor default DefGapInactiveColor;
    property HolidayColor: TColor read FHolidayColor write SetHolidayColor
      default DefHolidayColor;
    property BevelInner: TPanelBevel read GetBevelInner write SetBevelInner
      default DefBevelInner;
    property BevelOuter: TPanelBevel read GetBevelOuter write SetBevelOuter
      default DefBevelOuter;
    property BevelWidth: TBevelWidth read GetBevelWidth write SetBevelWidth
      default DefBevelWidth;
    property BorderWidth: TBorderWidth read GetBorderWidth
      write SetBorderWidth default DefBorderWidth;
    property BorderStyle: TBorderStyle read GetBorderStyle
      write SetBorderStyle default DefBorderStyle;
    property AutoShowMonth: Boolean read FAutoShowMonth
      write FAutoShowMonth default DefAutoShowMonth;
    property GapWidth: Integer read FGapWidth write SetGapWidth
      default DefGapWidth;
    property ButtonHeight: Integer read FButtonHeight write SetButtonHeight
      default DefButtonHeight;
    property ArrowWidth: Integer read FArrowWidth write SetArrowWidth
      default DefArrowWidth;
    property ForceTodayOnStart: Boolean read FForceTodayOnStart
      write SetForceTodayOnStart default DefForceToday;
    property MonthName: String read GetMonthName write SetMonthName
      stored False;
    property Month: Integer read GetMonth write SetMonth
      stored FRememberDate;
    property Year: Integer read GetYear write SetYear stored FRememberDate;
    property Day: Integer read GetDay write SetDay  stored FRememberDate;
    property ColorOfThisMonthDays: TColor read FColorOfThisMonthDays
      write SetColorOfThisMonthDays default DefColorOfThisMonthdays;
    property ColorOfOtherMonthDays: TColor read FColorOfOtherMonthDays
      write SetColorOfOtherMonthDays default DefColorOfOtherMonthDays;
    property CurColor: TColor read FCurColor write SetCurColor
      default DefCurColor;
    property CurBKColor: TColor read FCurBKColor write SetCurBKColor
      default DefCurBKColor;
    property HeadColor: TColor read FHeadColor write SetHeadColor
      default DefHeadColor;
    property HeadBKColor: TColor read FHeadBKColor write SetHeadBKColor
      default DefHeadBKColor;
    property HeadOuterColor: TColor read FHeadOuterColor
      write SetHeadOuterColor default DefHeadOuterColor;
    property BKColor: TColor read FBKColor write SetBKColor
      default DefBKColor;
    property OuterColor: TColor read FOuterColor write SetOuterColor
      default DefOuterColor;
    property Font: TFont read FFont write SetFont;
    property HeadFont: TFont read FHeadFont write SetHeadFont;
    property ButtonFont: TFont read FButtonFont write SetButtonFont;
    property Panel: TPanels read FPanel write SetPanel;

    property OnPageChange: TNotifyEvent read FOnPageChange
      write FOnPageChange;
    property OnDateChanging: TNotifyEvent read FOnDateChanging
      write FOnDateChanging;
    property OnDateChanged: TNotifyEvent read FOnDateChanged
      write FOnDateChanged;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;

    property PopupMenu;
    property Align;
    property TabOrder;
    property TabStop;
    property Width default DefCalWidth;
    property Height default DefCalHeight;
    property Ctl3D write SetCtl3D stored True default DefCtl3D ;
    property ParentFont write SetParentFont stored True
      default DefParentFont;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;

    property OnEnter;
    property OnExit;
  end;

type
  TFullCalendarWnd = class(TCustomControl) { for INTERNAL use ONLY}
  private
    Calendar: TxCalendar;
    ForceCapture: Boolean;

    procedure DateChanging(Sender: TObject); virtual;
    procedure DateChanged(Sender: TObject); virtual;
    procedure PageChanged(Sender: TObject);
    procedure CalendarKeyPress(Sender: TObject; var Key: Char);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMSetFocus(var Message: TWMSetFocus);
      message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMMOUSEACTIVATE(var Message: TMessage);
      message WM_MOUSEACTIVATE;
    procedure WMACTIVATE(var Message: TMessage);
      message WM_ACTIVATE;

  protected
    procedure CreateParams(var Params: TCreateParams); override;

  public
    OnDateChanging: TNotifyEvent;
    OnDateChanged: TNotifyEvent;
    OnPageChange: TNotifyEvent;
    constructor Create(AnOwner: TComponent); override;
  end;

type
  TDisplayFormat = (dfShortDate, dfLongDate);

const
  ShortDateFormat = '!99/99/9999;1;_';
  LongDateFormat = '!99\->l<ll\-9999;1;_';
 
type
  TxxDateEdit = class(TCustomMaskEdit)
  private
    { Private Declarations }
    FMinDate: TDateTime;
    FMaxDate: TDateTime;
    FForceTodayOnStart: Boolean;
    FRememberDate: Boolean; { = not ForceTodayOnStart }
    InCombo: Boolean;
    DateWasChanged: Boolean;
    FOnDateChange: TNotifyEvent;
    FOnDateChanging: TNotifyEvent;
    FDisplayFormat: TDisplayFormat;
    FOnKeyPress: TKeyPressEvent;
    GettingCreated: Boolean; { internal - set while in create method }
    procedure SetDisplayFormat(Value: TDisplayFormat);
    procedure SetText(s: String);
    function GetYear: Integer;
    function GetDay: Integer;
    function GetMonth: Integer;
    procedure SetYear(Value: Integer);
    procedure SetDay(Value: Integer);
    procedure SetMonth(Value: Integer);
    function GetMinDate: String;
    procedure SetMinDate(Value: String);
    function GetMaxDate: String;
    procedure SetMaxDate(Value: String);
    procedure SetForceTodayOnStart(Value: Boolean);
    procedure SetOnKeyPress(Value: TKeyPressEvent);
    function GetDateIsValid: Boolean;

  protected
    { Protected Declarations }
    procedure KeyPress(var Key: Char); override;
    procedure Change; override;
    function GetDate: TDateTime;
    procedure SetDate(Value: TDateTime);
    procedure DoExit; override;
    procedure DateChange; virtual;
    procedure DateChanging; virtual;
    function CheckDateLimits: Boolean;

  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
    property DateIsValid: Boolean read GetDateIsValid;
    property Date: TDateTime read GetDate write SetDate;

  published
    { Published Declarations }
    property MinDate: String read GetMinDate write SetMinDate;
    property MaxDate: String read GetMaxDate write SetMaxDate;
    property DisplayFormat: TDisplayFormat read FDisplayFormat
      write SetDisplayFormat stored True;
    property ForceTodayOnStart: Boolean read FForceTodayOnStart
      write SetForceTodayOnStart default DefForceToday;
    property Month: Integer read GetMonth write SetMonth
      stored FRememberDate;
    property Year: Integer read GetYear write SetYear
      stored FRememberDate;
    property Day: Integer read GetDay write SetDay
      stored FRememberDate;

    property OnDateChange: TNotifyEvent read FOnDateChange
      write FOnDateChange;
    property OnDateChanging: TNotifyEvent read FOnDateChanging
      write FOnDateChanging;

    { encapsulated properties }
    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property CharCase;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont default DefParentFont;
    property ParentShowHint;
    property PassWordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text write SetText stored False;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress write SetOnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

type
  TxCalendarCombo = class(TCustomControl)
  private
    FShowCalendarWnd: Boolean;
    FDown: Boolean;
    FComboWidth: Integer;
    FComboHeight: Integer;
    FForceTodayOnStart: Boolean;
    FRememberDate: Boolean; { = not ForceTodayOnStart }

    Starting: Boolean;
    EditBox: TxxDateEdit;
    SpinButton: TxSpinButton;
    CalendarWnd: TFullCalendarWnd;
    CaptureFocus: Boolean;

    procedure SetComboWidth(Value: Integer);
    procedure SetComboHeight(Value: Integer);
    procedure SetDate(ADate: TDateTime);
    procedure SetState(NewState: Boolean);
    procedure SetDown(ADown: Boolean);
    function GetDisplayFormat: TDisplayFormat;
    procedure SetDisplayFormat(Value: TDisplayFormat);
    function GetEditBoxFont: TFont;
    procedure SetEditBoxFont(Value: TFont);
    procedure SetTabStop(Value: Boolean);
    function GetTabStop: Boolean;
    function GetText: string;
    procedure SetText(Value: string);

    { for calendar combo}
    function GetGapColor: TColor;
    function GetBevelInner: TPanelBevel;
    function GetBevelOuter: TPanelBevel;
    function GetBevelWidth: TBevelWidth;
    function GetBorderWidth: TBorderWidth;
    function GetGapWidth: Integer;
    function GetButtonHeight: Integer;
    function GetArrowWidth: Integer;
    function GetColorOfThisMonthDays: TColor;
    function GetColorOfOtherMonthDays: TColor;
    function GetCurColor: TColor;
    function GetCurBKColor: TColor;
    function GetHeadColor: TColor;
    function GetHeadBKColor: TColor;
    function GetHeadOuterColor: TColor;
    function GetBKColor: TColor;
    function GetOuterColor: TColor;
    function GetFont: TFont;
    function GetHeadFont: TFont;
    function GetButtonFont: TFont;
    function GetPanel: TPanels;
    function GetMonth: Integer;
    function GetYear: Integer;
    function GetDay: Integer;
    function GetDate: TDateTime;
    function GetBorderStyle: TBorderStyle;
    function GetAutoShowMonth: Boolean;
    function GetOnDateChanging: TNotifyEvent;
    function GetOnDateChanged: TNotifyEvent;
    function GetOnPageChange: TNotifyEvent;
    function GetArrowFocusedColor: TColor;
    function GetArrowColor: TColor;
    function GetMonthRectColor: TColor;
    function GetHolidayColor: TColor;
    function GetDayType: TDayType;
    function GetDayTypeStr: String;
    function GetHolidaysDatabaseName: TFileName;
    function GetHolidaysTableName: TFileName;
    function GetDelay: Integer;
    function GetParentFont: Boolean;
    function GetCtl3D: Boolean;
    function GetComboCtl3D: Boolean;
    function GetMouseMove: TMouseMoveEvent;
    function GetMinDate: String;
    function GetMaxDate: String;
    function GetStartOfWeek: TWeekDays;
    function GetButtonBKColor: TColor;
    procedure SetButtonBKColor(Value: TColor);
    procedure SetStartOfWeek(Value: TWeekDays);
    procedure SetMinDate(Value: String);
    procedure SetMaxDate(Value: String);
    procedure SetMouseMove(Value: TMouseMoveEvent);
    procedure SetComboCtl3D(Value: Boolean);
    procedure SetCtl3D(Value: Boolean);
    procedure SetParentFont(Value: Boolean);
    procedure SetDelay(Value: Integer);
    procedure SetHolidaysDatabaseName(Value: TFileName);
    procedure SetHolidaysTableName(Value: TFileName);
    procedure SetHolidayColor(Value: TColor);
    procedure SetGapColor(AColor: TColor);
    procedure SetBevelInner(Value: TPanelBevel);
    procedure SetBevelOuter(Value: TPanelBevel);
    procedure SetBevelWidth(Value: TBevelWidth);
    procedure SetBorderWidth(Value: TBorderWidth);
    procedure SetGapWidth(W: Integer);
    procedure SetButtonHeight(H: Integer);
    procedure SetArrowWidth(W: Integer);
    procedure SetColorOfThisMonthDays(AColor: TColor);
    procedure SetColorOfOtherMonthDays(AColor: TColor);
    procedure SetCurColor(AColor: TColor);
    procedure SetCurBKColor(AColor: TColor);
    procedure SetHeadColor(AColor: TColor);
    procedure SetHeadBKColor(AColor: TColor);
    procedure SetHeadOuterColor(AColor: TColor);
    procedure SetBKColor(AColor: TColor);
    procedure SetOuterColor(AColor: TColor);
    procedure SetFont(AFont: TFont);
    procedure SetHeadFont(AFont: TFont);
    procedure SetButtonFont(AFont: TFont);
    procedure SetPanel(APanel: TPanels);
    procedure SetMonth(AMonth: Integer);
    procedure SetYear(AYear: Integer);
    procedure SetDay(ADay: Integer);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetAutoShowMonth(Value: Boolean);
    procedure SetOnDateChanging(Value: TNotifyEvent);
    procedure SetOnDateChanged(Value: TNotifyEvent);
    procedure SetOnPageChange(Value: TNotifyEvent);
    procedure SetMonthRectColor(Value: TColor);
    procedure SetArrowFocusedColor(Value: TColor);
    procedure SetArrowColor(Value: TColor);
    procedure SetForceTodayOnStart(Value: Boolean);
    function GetCalendarDate: String;
    procedure SetCalendarDate(Value: String);

    function GetWidth: Integer;
    procedure SetWidth(Value: Integer);
    function GetHeight: Integer;
    procedure Setheight(Value: Integer);
    function GetLeft: Integer;
    procedure SetLeft(Value: Integer);
    function GetTop: Integer;
    procedure SetTop(Value: Integer);

    procedure DrawComboButton;
    procedure MoveCalendarWnd;
    procedure EditBoxChange(Sender: TObject);
    procedure EditBoxChanging(Sender: TObject);
    procedure DoOnMoveSpin(Sender: TObject; Delta: Integer);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure CNCommand(var Message: TWMCommand);
      message CN_COMMAND;
    procedure WMMove(var Message: TWMMove);
      message WM_MOVE;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMSetFocus(var Message: TWMSetFocus);
      message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure WMActivate(var Message: TMessage);
      message WM_ACTIVATE;

    property Down: Boolean read FDown write SetDown;

  protected
    { Protected Declarations }
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure DateChanging; virtual;
    procedure DateChanged; virtual;
    procedure DoExit; override;

    { EditKeyDown, EditKeyPress, EditKeyUp is Assigned to
      OnKeyDown, OnKeyPress, OnKeyUp of EditBox(=TxxDateEdit) }
    procedure EditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState); virtual;
    procedure EditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState); virtual;
    procedure EditKeyPress(Sender: TObject; var Key: Char); virtual;

  public
    { Public Declarations }
    constructor Create(AnOwner: TComponent); override;

    procedure Click; override;
    function HasValidDate: Boolean;

    property Date: TDateTime read GetDate write SetDate;
    property ShowCalendarWnd: Boolean read FShowCalendarWnd write SetState;

  published
    { Published Declarations }
    property Delay: Integer read GetDelay write SetDelay default DefDelay;
    property HolidayColor: TColor read GetHolidayColor
      write SetHolidayColor default DefHolidayColor;
    property DayType: TDayType read GetDayType;
    property DayTypeStr: String read GetDayTypeStr;
    property HolidaysDatabaseName: TFileName read GetHolidaysDatabaseName
      write SetHolidaysDatabaseName;
    property HolidaysTableName: TFileName read GetHolidaysTableName
      write SetHolidaysTableName;
    property ArrowFocusedColor: TColor read GetArrowFocusedColor
      write SetArrowFocusedColor default DefArrowFocusedColor;
    property ArrowColor: TColor read GetArrowColor
      write SetArrowColor default DefArrowColor;
    property MonthRectColor: TColor read getMonthRectColor
      write SetMonthRectColor default DefMonthRectColor;
    property ComboWidth: Integer read FComboWidth write SetComboWidth
      default DefComboWidth;
    property ComboHeight: Integer read FComboHeight write SetComboHeight
      default DefComboHeight;
    property DisplayFormat: TDisplayFormat read GetDisplayFormat
      write SetDisplayFormat stored True;
    property EditBoxFont: TFont read GetEditBoxFont write SetEditBoxFont;

    property ButtonBKColor: TColor read GetButtonBKColor
      write SetButtonBKColor default DefButtonBKColor;
    property CalendarDate: String read GetCalendarDate write SetCalendarDate
      stored False;
    property Text: string read getText write SetText stored false;
    property MinDate: String read GetMinDate write SetMinDate;
    property MaxDate: String read GetMaxDate write SetMaxDate;
    property StartOfWeek: TWeekDays read GetStartOfWeek write SetStartOfWeek
      default DefStartOfWeekDay;
    property GapColor: TColor read GetGapColor write SetGapColor
      default DefGapColor;
    property BevelInner: TPanelBevel read GetBevelInner write SetBevelInner
      default DefBevelInner;
    property BevelOuter: TPanelBevel read GetBevelOuter write SetBevelOuter
      default DefBevelOuter;
    property BevelWidth: TBevelWidth read GetBevelWidth write SetBevelWidth
      default DefBevelWidth;
    property BorderWidth: TBorderWidth read GetBorderWidth
      write SetBorderWidth default DefBorderWidth;
    property BorderStyle: TBorderStyle read GetBorderStyle
      write SetBorderStyle default DefBorderStyle;
    property AutoShowMonth: Boolean read GetAutoShowMonth
      write SetAutoShowMonth default DefAutoShowMonth;
    property GapWidth: Integer read GetGapWidth write SetGapWidth
      default DefGapWidth;
    property ButtonHeight: Integer read GetButtonHeight
      write SetButtonHeight default DefButtonHeight;
    property ArrowWidth: Integer read GetArrowWidth write SetArrowWidth
      default DefArrowWidth;
    property ForceTodayOnStart: Boolean read FForceTodayOnStart
      write SetForceTodayOnStart default DefForceToday;
    property Month: Integer read GetMonth write SetMonth
      stored FRememberDate;
    property Year: Integer read GetYear write SetYear stored FRememberDate;
    property Day: Integer read GetDay write SetDay  stored FRememberDate;
    property ColorOfThisMonthDays: TColor read GetColorOfThisMonthDays
      write SetColorOfThisMonthDays default DefColorOfThisMonthDays;
    property ColorOfOtherMonthDays: TColor read GetColorOfOtherMonthDays
      write SetColorOfOtherMonthDays default DefColorOfOtherMonthDays;
    property CurColor: TColor read GetCurColor write SetCurColor
      default DefCurColor;
    property CurBKColor: TColor read GetCurBKColor write SetCurBKColor
      default DefBKColor;
    property HeadColor: TColor read GetHeadColor write SetHeadColor
      default DefheadColor;
    property HeadBKColor: TColor read GetHeadBKColor write SetHeadBKColor
      default DefHeadBKColor;
    property HeadOuterColor: TColor read GetHeadOuterColor
      write SetHeadOuterColor default DefHEadOuterColor;
    property BKColor: TColor read GetBKColor write SetBKColor
      default DefBKColor;
    property OuterColor: TColor read GetOuterColor write SetOuterColor
      default DefOuterColor;
    property Font: TFont read GetFont write SetFont;
    property HeadFont: TFont read GetHeadFont write SetHeadFont;
    property ButtonFont: TFont read GetButtonFont write SetButtonFont;
    property Panel: TPanels read GetPanel write SetPanel
      stored True;
    property ComboCtl3D: Boolean read GetComboCtl3D write SetComboCtl3D
      stored True default DefComboCtl3D;

    property OnPageChange: TNotifyEvent read GetOnPageChange
      write SetOnPageChange;
    property OnDateChanging: TNotifyEvent read GetOnDateChanging
      write SetOnDateChanging;
    property OnDateChanged: TNotifyEvent read GetOnDateChanged
      write SetOnDateChanged;

    property TabStop read GetTabStop write SetTabStop stored True;
    property TabOrder;
    property Top read GetTop write SetTop;
    property Left read GetLeft write SetLeft;
    property Width read GetWidth write SetWidth default DefEditWidth;
    property Height read GetHeight write SetHeight default DefEditHeight;
    property ShowHint;
    property ParentShowHint;
    property ParentFont read GetParentFont write SetParentFont stored True
      default DefParentFont;
    property Ctl3D read GetCtl3D write SetCtl3D;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove read GetMouseMove write SetMouseMove;
    property OnMouseUp;

    property OnEnter;
    property OnExit;

    property Visible;
  end;

  TxDBCalendar = class(TxCalendar)
  private
    FDataLink: TFieldDataLink;
    ForcingEdit: Boolean;

    procedure DataChange(Sender: TObject);
    function GetDataField: String;
    function GetDataSource: TDataSource;
    function GetField: TField;
    procedure SetDataField(const Value: String);
    procedure SetDataSource(Value: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    procedure CMExit(var Message: TCMExit); message CM_EXIT;

  protected
    procedure Click; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;

  published
    property DataField: String read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
  end;

  TxDBCalendarCombo = class(TxCalendarCombo)
  private
    FDataLink: TFieldDataLink;
    ForcingEdit: Boolean;
    ReadingData: Boolean;
    OldOnDateChanged: TNotifyEvent;

    procedure DataChange(Sender: TObject);
    function GetDataField: String;
    function GetDataSource: TDataSource;
    function GetField: TField;
    procedure SetDataField(const Value: String);
    procedure SetDataSource(Value: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    procedure CMExit(var Message: TCMExit); message CM_EXIT;

    procedure DoOnDateChanged(Sender: TObject);

  protected
    procedure Loaded; override;
    procedure DateChanging; override;
    procedure DateChanged; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure EditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState); override;
    procedure EditKeyPress(Sender: TObject; var Key: Char); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;

  published
    property DataField: String read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
  end;
 
type
  TxDBDateEdit = class(TxxDateEdit)
  private
    SkipChange: Integer;
    FDataLink: TFieldDataLink;
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: String;
    function GetDataSource: TDataSource;
    function GetField: TField;
    function GetReadOnly: Boolean;
    procedure SetDataField(const Value: String);
    procedure SetDataSource(Value: TDataSource);
    procedure SetReadOnly(Value: Boolean);
    procedure UpdateData(Sender: TObject);
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;

  protected
    procedure DateChange; override;
    procedure DateChanging; override;
    function EditCanModify: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Reset; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;

  published
    property DataField: String read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly
      default False;

    property Day stored False;
    property Month stored False;
    property Year stored False;
    property Text stored False;
  end;

type
  ECalendar = class(Exception);

procedure Register;

implementation

uses
  xCalendF;

const
  TicsToSkip = 6; { identifies the number of tics of timer to skip before
                    starting to change the page in calendar }

const
  COMBO_BTN_WIDTH = 20;
  SPIN_BTN_WIDTH = 13;

function Trim(s: String):String;
begin
  while (s[1]=' ') and (Length(s)>0) do delete(s, 1, 1);
  while (s[length(s)]=' ') and (Length(s)>0) do delete(s, length(s), 1);
  Result := s;
end;

{------------------------------ TFullShape --------------------}
constructor TFullShape.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  DoCapture := True;
  ControlStyle := ControlStyle -
    [csCaptureMouse, csClickEvents, csDoubleClicks];
  BoxColor := clYellow;
  UnderMouse := False;
  ShowOnMouse := [];
  MDelta := 2;
  MColor := DefMonthRectColor;
  TColorNonfocused := DefArrowColor;
  TColorFocused := DefArrowFocusedColor;
  OutColor := clBlack;
  OnTics := False;
  MouseIsDown := False;
  HasDate := False;
end;

procedure TFullShape.TimerTic;
begin
  if MouseIsDown then
  begin
    if OnTics and Assigned(MousePress) then
      if NextTic > TicsToSkip then
        MousePress(Self)
      else Inc(NextTic);
  end else
    NextTic := 0;
end;

procedure TFullShape.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if Assigned(MousePress) then MousePress(Self);
  MouseIsDown := True;
end;

procedure TFullShape.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  MouseIsDown := False;
end;

procedure TFullShape.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  inherited MouseMove(Shift, x, y);
  if (ShowOnMouse<>[]) and not(UnderMouse) then
    begin
      UnderMouse := True;
      if DoCapture then
        begin
          OldCapture := getcapturecontrol;
          MouseCapture := True;
          NextTic := 0;
        end;
      invalidate;
    end
  else
    if UnderMouse then
    begin
      GetCursorPos(p);
      p.x := p.x - ClientOrigin.X;
      p.y := p.y - ClientOrigin.Y;
      if (p.x<0) or (p.y<0) or (p.x>Width) or (p.Y>Height) then
        begin
          if Oldcapture<>nil then
            try
              SetCaptureControl(OldCapture)
            except
              on exception do MouseCapture := False;
            end
          else
            MouseCapture := False;
          MouseIsDown := False;
          UnderMouse := False;
          invalidate;
        end;
    end;
end;

procedure TFullShape.Paint;
var
  a: TPoint;
  l, l1, l2, l3: Integer;
  R: TRect;
begin
  if (Parent as TPanel).Ctl3D then
  begin
    Canvas.Brush.Color := clBtnFace;
    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Color := clBtnFace;
    Canvas.FillRect(Rect(0, 0, Width - 1, Height - 1));

    if HasDate then
    begin
      R := Rect(1, 1, Width - 1, Height - 1);
      Frame3D(Canvas, R, clBtnShadow, clBtnHighlight, 1);
    end;
  end
  else
  begin
    Canvas.Brush.Color := Self.Brush.Color;
    Canvas.Pen.Color := OutColor;
    Canvas.FillRect(Rect(0, 0, Width - 1, Height - 1));
  end;

  with Canvas do
    begin
      if CText <> '' then
        begin
          if (Parent as TPanel).ParentFont then
            Font.Assign((Parent as TPanel).Font);
          Font.Color := CColor;
          Brush.Style := bsClear;

          if (Parent as TPanel).Ctl3D and HasDate then
            TextOut((Width - TextWidth(CText)) div 2,
                    ((Height - TextHeight(CText)) div 2),
                    CText)
          else
            TextOut(((Width - TextWidth(CText)) div 2) - 1,
                    (Height - TextHeight(CText)) div 2,
                    CText);
        end;
      if not (Parent as TPanel).Ctl3D then
        begin
          Pen.Color := OutColor;
          PolyLine([Point(0,0), Point(0, Height)]);
          PolyLine([Point(0,0), Point(Width, 0)]);
          PolyLine([Point(Width-1, 0),
                    Point(Width-1, Height)]);
          PolyLine([Point(0, Height - 1),
                    Point(Width-1, Height - 1)]);
        end;

      if UnderMouse then
      begin
        if msRect in ShowOnMouse then
          begin
            Pen.Color := MColor;
            Pen.Style := psSolid;
            PolyLine([Point(Mdelta,Mdelta),
                      Point(Mdelta, Height - MDelta - 1)]);
            PolyLine([Point(Mdelta,Mdelta),
                      Point(Width - MDelta, 0 + Mdelta)]);
            PolyLine([Point(Width - 1 - Mdelta, 0 + MDelta),
                      Point(Width - 1 - Mdelta, Height - 1 - MDelta)]);
            PolyLine([Point(0 + Mdelta, Height - 1 - MDelta),
                      Point(Width - 1 - MDelta, Height - 1 - MDelta)]);
          end;

        if msRight in ShowOnMouse then
        begin
          Brush.Color := Self.Color;
          FillRect(Rect(0, 0, Width, Height));

          Pen.Color := TColorFocused;
          Brush.Color := TColorFocused;

          a.x := Width div 2;
          a.y := Height div 2;
          l := Width div 2;
          l := l * 10 div 15;
          l1 := l div 2;
          l2 := l * 17 div 20;
          l3 := l * 10 div 15;
          Polygon([Point(a.x - l1, a.y - l2),
                   Point(a.x + l3, a.y),
                   Point(a.x - l1, a.y + l2)]);
        end;

        if msLeft in ShowOnMouse then
        begin
          Brush.Color := Self.Color;
          FillRect(Rect(0, 0, Width, Height));

          Pen.Color := TColorFocused;
          Brush.Color := TColorFocused;
        end;
      end
      else { not UnderMouse }
      begin
        if msRight in ShowOnMouse then
        begin
          Brush.Color := Self.Color;
          FillRect(Rect(0, 0, Width, Height));

          Pen.Color := TColorNonfocused;
          Brush.Color := TColorNonfocused;

          a.x := Width div 2;
          a.y := Height div 2;
          l := Width div 2;
          l := l * 10 div 15;
          l1 := l div 2;
          l2 := l * 17 div 20;
          l3 := l * 10 div 15;
          Polygon([Point(a.x - l1, a.y - l2),
                   Point(a.x + l3, a.y),
                   Point(a.x - l1, a.y + l2)]);
        end;

        if msLeft in ShowOnMouse then
        begin
          Brush.Color := Self.Color;
          FillRect(Rect(0, 0, Width, Height));

          Pen.Color := TColorNonfocused;
          Brush.Color := TColorNonfocused;
        end;
      end; { if UnderMouse }

      if msLeft in ShowOnMouse then
      begin
        a.x := Width div 2;
        a.y := Height div 2;
        l := Width div 2;
        l := l * 10 div 15;
        l1 := l div 2;
        l2 := l * 17 div 20;
        l3 := l * 10 div 15;
        Polygon([Point(a.x + l1, a.y - l2),
                 Point(a.x - l3, a.y),
                 Point(a.x + l1, a.y + l2)]);
      end;
    end;
end;

procedure TFullShape.GetDate(const Year, Month, Day: Integer;
                  var TheYear, TheMonth, TheDay: Integer);
begin
  TheMonth := Month;
  TheYear := Year;
  if AMonth = tLast then Dec(TheMonth);
  if TheMonth = 0 then
    begin
      TheMonth := 12;
      Dec(TheYear);
    end;
  if AMonth = tNext then Inc(TheMonth);
  if TheMonth = 13 then
    begin
      TheMonth := 1;
      Inc(TheYear);
    end;
  TheDay := ADay;
end;

{-------------------------- TxCalendar --------------------------}
constructor TxCalendar.Create(AOwner: TComponent);
var
  i, j: Integer;
begin
  inherited Create(AOwner);
  FPanel := pMonth;

  IsHiding := 0;
  UpdateWasCalled := False;
  ChangingOnKey := False;

  FMinDate := 0;
  FMaxDate := 0;

  MainPanel := TPanel.create(Self);
  MainPanel.Width := Width;
  MainPanel.Height := Height;
  MainPanel.left := 0;
  MainPanel.top := 0;
  MainPanel.BevelInner := DefBevelInner;
  MainPanel.BevelOuter := DefBevelOuter;
  MainPanel.BevelWidth := DefBevelWidth;
  MainPanel.BorderStyle := DefBorderStyle;
  MainPanel.BorderWidth := DefBorderWidth;
  MainPanel.Color := clPurple;
  MainPanel.ParentCtl3D := False;
  MainPanel.Ctl3D := Ctl3D;
  insertControl(MainPanel);

  FFont := TFont.Create;
    FFont.Name := DefFontName;
    FFont.Style := DefFontStyle;
    FFont.Size := DefFontSize;
  FHeadFont := TFont.Create;
    FHeadFont.Name := DefFontName;
    FHeadFont.Style := DefFontStyle;
    FHeadFont.Size := DefFontSize;
  FButtonFont := TFont.Create;
    FButtonFont.Name := DefFontName;
    FButtonFont.Style := DefFontStyle;
    FButtonFont.Size := DefFontSize;
  FFont.OnChange := FontChanged;
  FHeadFont.OnChange := FontChanged;
  FButtonFont.OnChange := FontChanged;

  FGapWidth := DefGapWidth;

  FAutoShowMonth := DefAutoShowMonth;

  Width := DefCalWidth;
  Height := DefCalHeight;
  FButtonHeight := DefButtonHeight;
  FArrowWidth := DefArrowWidth;

{  FHolidaysDatabaseName := '';
  FHolidaysTableName := '';}
  HTable := TTable.Create(Self);
  HDataSource := TDataSource.Create(Self);
  HaveDB := False;

  FStartOfWeek := DefStartOfWeek; { = Sunday }

  FColorOfThisMonthDays := DefColorOfThisMonthdays;
  FColorOfOtherMonthDays := DefColorOfOtherMonthDays;
  FCurColor := DefCurColor;
  FCurBKColor := DefCurBKColor;
  FHeadColor := DefHeadColor;
  FHeadBKColor := DefHeadBKColor;
  FHeadOuterColor := DefHeadOuterColor;
  FBKColor := DefBKColor;
  FOuterColor := DefOuterColor;
  FGapActiveColor := DefGapActiveColor;
  FGapInactiveColor := DefGapInactiveColor;
  FHolidayColor := DefHolidayColor;
  MainPanel.Color := FGapInactiveColor;;

  MLastI := 1; MLastJ := 1;
  YLastI := 1; YLastJ := 1;
  PrevMonth := TFullShape.Create(Self);
  with PrevMonth do
    begin
      Ctext := '<';
      OutColor := Brush.Color;
      MousePress := MonthShapePressed;
      ShowOnMouse := [msLeft];
      OnTics := True;
    end;
  MainPanel.InsertControl(PrevMonth);
  NextMonth := TFullShape.Create(Self);
  with NextMonth do
    begin
      Ctext := '>';
      OutColor := Brush.Color;
      MousePress := MonthShapePressed;
      ShowOnMouse := [msRight];
      OnTics := True;
    end;
  MainPanel.InsertControl(NextMonth);
  TheMonth := TFullShape.Create(Self);
  with TheMonth do
    begin
      Caption := '';
      Brush.Color := FBKColor;
      OutColor := Brush.Color;
      MousePress := MonthShapePressed;
      ShowOnMouse := [msRect];
    end;
  MainPanel.InsertControl(TheMonth);
  { panel for a single year }
  YPanel := TPanel.Create(Self);
  with YPanel do
    begin
      BevelInner := bvNone;
      BevelOuter := bvNone;
      BevelWidth := 1;
      BorderWidth := 0;
      BorderStyle := bsNone;
      Caption := '';
      Visible := False;
    end;
  YPanel.ParentCtl3D := False;
  YPanel.Ctl3D := Ctl3D;
  MainPanel.InsertControl(YPanel);
  for i:=1 to 4 do
    for j:=1 to 3 do
      begin
        YShape[i, j] := TFullShape.Create(Self);
        YShape[i, j].OnMouseDown := ShapeMouseDown;
        YShape[i, j].OnMouseUp := ShapeMouseUp;
        YShape[i, j].OnMouseMove := ShapeMouseMoved;
        YPanel.InsertControl(YShape[i, j]);
      end;
  { panel for a single month }
  MPanel := TPanel.Create(Self);
  with MPanel do
    begin
      BevelInner := bvNone;
      BevelOuter := bvNone;
      BevelWidth := 1;
      BorderWidth := 0;
      BorderStyle := bsNone;
      Caption := '';
    end;
  MPanel.ParentCtl3D := False;
  MPanel.Ctl3D := Ctl3D;
  MainPanel.InsertControl(MPanel);
  PMenu := NewPopupMenu(Self, { see also MenuPopup method below }
              'Popup', paLeft, True,
              [NewItem(Phrases[lnAddHoliday], 0, False, True, AddHoliday,
                       0, 'itemAdd'),
              NewItem(Phrases[lnRemoveHoliday], 0, False, True,
                      DeleteHoliday, 0, 'itemRemove'),
              NewItem(Phrases[lnInfoHoliday], 0, False, True, InfoHoliday,
                      0, 'itemInfo')]);
  PMenu.OnPopup := MenuPopup;
  for i:=1 to 7 do
    for j:=0 to 6 do
      begin
        MShape[i, j] := TFullShape.Create(Self);
        if j <> 0 then
          begin
            MShape[i, j].OnMouseDown := ShapeMouseDown;
            MShape[i, j].OnMouseUp := ShapeMouseUp;
            MShape[i, j].OnMouseMove := ShapeMouseMoved;
            MShape[i, j].PopupMenu := PMenu;
          end;
        MPanel.InsertControl(MShape[i, j]);
      end;
  SetSizes;

  FDate := SysUtils.Date;
  FForceTodayOnStart := DefForceToday;
  FRememberDate := not DefForceToday;
  NewPage := False;
  NewDate := False;
  InRefreshing := True;

  InCombo := False;

  TabStop := True;

  Timer := TTimer.Create(Self);
  Timer.Interval := DefDelay;
  Timer.OnTimer := TimerTic;

  Ctl3D := DefCtl3D;
  ParentFont := DefParentFont;
  ButtonBKColor := DefButtonBKColor;
end;

procedure TxCalendar.Loaded;
begin
  inherited Loaded;
  UpdateHead;
  Update;
end;

procedure TxCalendar.SetSizes;
var
  i, j: Integer;
  H, W: Integer;
  MainL, MainT: Integer;
begin
  MainPanel.Width := Width;
  MainPanel.Height := Height;
  MainL := FGapWidth + MainPanel.BorderWidth;
  if MainPanel.BevelInner<>bvNone then MainL := MainL + MainPanel.BevelWidth;
  if MainPanel.BevelOuter<>bvNone then MainL := MainL + MainPanel.BevelWidth;
  MainT := FGapWidth + MainPanel.BorderWidth;
  if MainPanel.BevelInner<>bvNone then MainT := MainT + MainPanel.BevelWidth;
  if MainPanel.BevelOuter<>bvNone then MainT := MainT + MainPanel.BevelWidth;

  PrevMonth.Width := FArrowWidth;
  PrevMonth.Height := FButtonHeight;
  PrevMonth.Left := MainL;
  PrevMonth.Top := MainT;

  NextMonth.Width := FArrowWidth;
  NextMonth.Height := FButtonHeight;
  NextMonth.Left := Width - FArrowWidth - MainL;
  NextMonth.Top := MainT;

  TheMonth.Width := Width - 2 * (FArrowWidth + (MainL));
  TheMonth.Height := FButtonHeight;
  TheMonth.Left := FArrowWidth + MainL;
  TheMonth.Top := MainT;

  { panel for a single year }
  YPanel.Width := Width - 2 * MainL;
  YPanel.Height := Height - FButtonHeight - 2 * MainT;
  YPanel.Left := MainL;
  YPanel.Top := FButtonHeight + MainT;

  H := YPanel.Height - 1;
  W := YPanel.Width - 1;
  for i:=1 to 4 do
    for j:=1 to 3 do
      begin
        YShape[i, j].Width := W div 4 + 1;
        YShape[i, j].Height := H div 3 + 1;
        YShape[i, j].Left := (W div 4) * (i-1) + (W mod 4) div 2;
        YShape[i, j].Top := (H div 3) * (j - 1)  + (H mod 3) div 2;
      end;

  { panel for a single month }
  MPanel.Width := Width - 2 * MainL;
  MPanel.Height := Height - FButtonHeight - 2 * MainT;
  MPanel.Left := MainL;
  MPanel.Top := FButtonHeight + MainT;

  H := MPanel.Height - 1;
  W := MPanel.Width - 1;
  for i:=1 to 7 do
    for j:=0 to 6 do
      begin
        MShape[i, j].Width := W div 7 + 1;
        MShape[i, j].Height := H div 7 + 1;
        MShape[i, j].Left := (W div 7) * (i-1) + (W mod 7) div 2;
        MShape[i, j].Top := (H div 7) * j + (H mod 7) div 2;
      end;
end;

procedure TxCalendar.MenuPopup(Sender: TObject);
var
  y, m, d: Integer;
begin
  PMenu.Items[0].Caption := Phrases[ lnAddHoliday ];
  PMenu.Items[1].Caption := Phrases[ lnRemoveHoliday ];
  PMenu.Items[2].Caption := Phrases[ lnInfoHoliday ];
  (PMenu.PopupComponent as TFullShape).GetDate(Year, Month, Day, y, m, d);
  PMenu.Items[0].Enabled := not IsItHoliday( y, m, d );
  PMenu.Items[1].Enabled := IsItHoliday( y, m, d );
end;

procedure TxCalendar.AddHoliday(Sender: TObject);
var
  m, y, d: Integer;
  AShape: TFullShape;
begin
  if not HaveDB then exit;
  AShape := PMenu.PopupComponent as TFullShape;
  AShape.GetDate(Year, Month, Day, y, m, d);
  if IsItHoliday(y, m, d) then
    MessageDlg(IntToStr(d) + '.' + IntToStr(m) + '.' + IntToStr(y) +
      Phrases[ lnAlreadyHoliday ], mtError, [mbOk], 0)
  else
    begin
      Application.CreateForm(TNewHoliday, NewHoliday);
      try
        NewHoliday.Label1.Caption := IntToStr(d) + '.'
          + IntToStr(m) + '.' + IntToStr(y);
        NewHoliday.Every.Checked := True;
        if NewHoliday.ShowModal = mrOk then
          begin
            if NewHoliday.Every.Checked then y := PermanentHoliday;
            HTable.Insert;
            try
              (HTable.FieldByName('Date') as TDateField).Value :=
                EncodeDate(y, m, d);
              HTable.FieldByName('Holiday').AsString :=
                NewHoliday.Edit1.Text;
            finally
              HTable.post;
            end;
          end;
      finally
        NewHoliday.Free;
      end;
    end;
  Refresh;
end;

procedure TxCalendar.DeleteHoliday(Sender: TObject);
var
  m, y, d: Integer;
  dy: Integer;
  AShape: TFullShape;
  s: String;
begin
  if not HaveDB then exit;
  AShape := PMenu.PopupComponent as TFullShape;
  AShape.GetDate(Year, Month, Day, y, m, d);
  if IsItHoliday(y, m, d) then
    begin
      if IsItHoliday(PermanentHoliday, m, d) then
        begin
          s := Phrases[ lnDeleteEvery ] +
               IntToStr(d) + '.' + IntToStr(m) + '?';
          dy := PermanentHoliday;
        end
      else
        begin
          s := Phrases[ lnDeleteSingle ] + IntToStr(d) + '.'
               + IntToStr(m) + '.' + IntToStr(y) + '?';
          dy := y;
        end;
      if MessageDlg(s, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          HTable.SetKey;
          (HTable.FieldByName('Date') as TDateField).Value :=
            EncodeDate(dy, m, d);
          if HTable.GotoKey then
            begin
              HTable.Delete;
            end
          else
            raise ECalendar.Create(Phrases[ lnDeleteFault ]);
        end
      else
    end
  else
    MessageDlg(IntToStr(d) + '.' + IntToStr(m) + '.' + IntToStr(y) +
      Phrases[ lnNotAHoliday ], mtError, [mbOk], 0);
  Refresh;
end;

procedure TxCalendar.InfoHoliday(Sender: TObject);
var
  m, y, d: Integer;
  AShape: TFullShape;
  s: String;
begin
  if not HaveDB then exit;
  AShape := PMenu.PopupComponent as TFullShape;
  AShape.GetDate(Year, Month, Day, y, m, d);
  if IsItHoliday(y, m, d) then
    begin
      if IsItHoliday(PermanentHoliday, m, d) then
        begin
          s := IntToStr(d) + '.' + IntToStr(m) + Phrases[ lnEveryYear ];
          s := s + Phrases[ lnIsNamed ] + '''' +
            TypeOfDayStr( EncodeDate(y, m, d) ) + '''';
        end
      else
        begin
          s := IntToStr(d) + '.' + IntToStr(m) + '.' + IntToStr(y) +
            Phrases[ lnThisYear ];
          s := s + Phrases[ lnIsNamed ] + '''' +
            TypeOfDayStr( EncodeDate(y, m, d) ) + '''';
        end;
      MessageDlg(s, mtInformation, [mbOk], 0);
    end
  else
    MessageDlg(IntToStr(d) + '.' + IntToStr(m) + '.' + IntToStr(y) +
      Phrases[ lnNotAHoliday ], mtError, [mbOk], 0);
  Refresh;
end;

procedure TxCalendar.WMSize(var Msg: TWMSize);
begin
  inherited;
  SetSizes;
  Refresh;
end;

procedure TxCalendar.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if Ctl3D then
    MainPanel.Color := clBtnFace
  else
    MainPanel.Color := FGapActiveColor
end;

procedure TxCalendar.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if Ctl3D then
    MainPanel.Color := clBtnFace
  else
    MainPanel.Color := FGapInactiveColor;
end;

procedure TxCalendar.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
end;

procedure TxCalendar.KeyDown(var Key: Word; Shift: TShiftState);
var
  FreeKey: Boolean;
  P: TPoint;
begin
  inherited KeyDown(Key, Shift);
  ChangingOnKey := True;
  try
    FreeKey := True;
    if Panel = pMonth then
      begin
        if not(ssCtrl in Shift) then
          case chr(Key) of
            '-': if not InCombo then
              begin
                P.X := MShape[MLastI, MLastJ].Left +
                       MShape[MLastI, MLastJ].Width;
                P.Y := MShape[MLastI, MLastJ].Top;
                MapWindowPoints(MPanel.Handle,
                  GetDesktopWindow, P, 1);
                PMenu.PopupComponent := MShape[MLastI, MLastJ];
                PMenu.Popup(P.X, P.Y);
              end;
            '(': ShiftDay(7);
            '&': ShiftDay(-7);
            #39: GoNextDay;
            '%': GoPrevDay;
            #12, ' ': Panel := pYear;
            #13: DateChanged;
            else
              Freekey := False;
          end
        else
          case chr(Key) of
            #39: GoNextMonth;
            '%': GoPrevMonth;
            else
              Freekey := False;
          end
      end
    else
      begin
        if not(ssCtrl in Shift) then
          case chr(Key) of
            '(': ShiftMonth(4);
            '&': ShiftMonth(-4);
            #39: GoNextMonth;
            '%': GoPrevMonth;
            ' ', #12, #13: Panel := pMonth;
            else
              Freekey := False;
          end
        else
          case chr(Key) of
            #39: Year := Year + 1;
            '%': Year := Year - 1;
            else
              Freekey := False;
          end
      end;
    if FreeKey then
      begin
        Click;
        Key := 0;
      end;
  finally
    ChangingOnKey := False;
  end;
end;

procedure TxCalendar.DefaultHandler(var Message);
begin
  inherited DefaultHandler(Message);
end;

destructor TxCalendar.Destroy;
begin
  FFont.Free;
  FHeadFont.Free;
  FButtonFont.Free;
  inherited Destroy;
end;

procedure TxCalendar.WMGetDlgCode(var Message: TMessage);
begin
  Message.Result := DLGC_WANTARROWS;
end;

procedure TxCalendar.TimerTic(Sender: TObject);
begin
  if NextMonth.UnderMouse then NextMonth.TimerTic;
  if PrevMonth.UnderMouse then PrevMonth.TimerTic;
end;


procedure TxCalendar.Click;
begin
  if Assigned(FOnClick) then FOnClick(Self);
end;

procedure TxCalendar.Paint;
begin
  inherited Paint;
  InRefreshing := False;
end;

procedure TxCalendar.Repaint;
begin
  InRefreshing := True;
  if Ctl3D then
    begin
      MainPanel.Color := clBtnFace;
      MPanel.Color := clBtnFace;
      YPanel.Color := clBtnFace;
    end
  else
    begin
      MainPanel.Color := BKColor;
      MPanel.Color := BKColor;
      YPanel.Color := BKColor;
    end;
  UpdateHead;
  Update;
  inherited Repaint;
end;

procedure TxCalendar.UpdateHead;
var
 i: Integer;
begin
  for i := 1 to 7 do
    with MShape[i, 0] do
      begin
        Canvas.Font.Assign(FHeadFont);
        Shape := stRectangle;
        OutColor := HeadOuterColor;
        Brush.Color := HeadBKColor;
        CText := Phrases[ lnShortDayNames[(i + FStartOfWeek - 2) mod 7] ];
        if (i + FStartOfWeek - 2) mod 7 = 0 then
          CColor := HolidayColor
        else
          CColor := HeadColor;
        invalidate;
      end;
end;

procedure TxCalendar.HiDechanges;
begin
  Inc(IsHiding);
end;

procedure TxCalendar.ShowChanges;
begin
  if IsHiding<>0 then Dec(IsHiding);
  if (IsHiding=0) and (UpdateWasCalled) then Update;
end;

procedure TxCalendar.Update;
begin
  UpdateWasCalled := True;
  if IsHiding<>0 then exit;
  if NewPage and not(InCombo) then
    begin
      UpdateHead;
      PageChanged;
    end;
  if NewDate then
    if (ChangingOnKey and InCombo) or (ChangeOnMove) then
      DateChanging
    else
      DateChanged;
  case FPanel of
    pMonth: UpdateMonth;
    pYear: UpdateYear;
  end;
  Newdate := False;
  NewPage := False;
  UpdateWasCalled := False;
end;

function TxCalendar.IsItHoliday(AYear, AMonth, ADay: Integer): Boolean;
begin
  Result := False;
  if HaveDB then
    if ( HTable.FindKey([EncodeDate(AYear, AMonth, ADay)]) or
         (not((AMonth = 2) and (ADay = 29)) and
          HTable.FindKey([EncodeDate(PermanentHoliday, AMonth, ADay)]) ) ) then
         Result := True;
end;

procedure TxCalendar.RefreshMonth;
var
  i, j: Integer;
  AaYear, AaMonth, AaDay: Word;
  FirstDate: TDateTime;
  NextDate: Word;
  NewI, NewJ: Integer;
  ThisDay: Integer;
begin
  NewI := 0;
  NewJ := 0;
  if HaveDB then HTable.Refresh;
  TheMonth.ctext := MonthName + ', ' + IntToStr(Year);
  TheMonth.invalidate;
  DecodeDate(FDate, AaYear, AaMonth, AaDay);
  FirstDate := EncodeDate(AaYear, AaMonth, 1);
  NextDate := 1;
  i := DayOfWeek(FirstDate);
  if i < FStartOfWeek then i := i + 7;
{  if i = 1 then i := 7 else Dec(i);}
  for j := 1 to i - FStartOfWeek do
    with MShape[j, 1] do
      begin
        Canvas.Font.Assign(FFont);
        Shape := stRectangle;
        CColor := ColorOfOtherMonthDays;
        Ctext := IntToStr(DaysLastMonth - i + j + FStartOfWeek);
        AMonth := tLast;
        ADay := DaysLastMonth - i + j + FStartOfWeek;
        OutColor := OuterColor;
        Brush.Color := BKColor;
        HasDate := False;
      end;
  j := 1;
  i := i - FStartOfWeek + 1;
  ThisDay := day;
  while NextDate <= DaysThisMonth do
    begin
      with MShape[i, j] do
        begin
          Canvas.Font.Assign(FFont);
          if NextDate = thisDay then
            begin
              Shape := stRectangle;
              CColor := CurColor;
              Brush.Color := CurBKColor;
              NewI := i;
              NewJ := j;
              HasDate := True;
            end
          else
            begin
              Shape := stRectangle;
              try
                if (DayOfWeek(EncodeDate(Year, Month, NextDate)) = 1) or
                   IsItHoliday(AaYear, AaMonth, NextDate)
                then
                  CColor := HolidayColor
                else
                  CColor := ColorOfThisMonthDays;
              except
                on exception do CColor := ColorOfThisMonthDays;
              end;
              Brush.Color := BKColor;
              HasDate := False;
            end;
          CText := IntToStr(NextDate);
          OutColor := OuterColor;
          AMonth := tThis;
          ADay := NextDate;
        end;
      Inc(NextDate);
      Inc(i);
      if i>7 then
        begin
          i := 1;
          Inc(j);
        end;
    end;
  NextDate := 1;
  while (i<=7) and (j<7) do
    begin
      with MShape[i, j] do
        begin
          Canvas.Font.Assign(FFont);
          CColor := ColorOfOtherMonthDays;
          Shape := stRectangle;
          CText := IntToStr(NextDate);
          AMonth := tNext;
          Aday := nextDate;
          OutColor := OuterColor;
          Brush.Color := BKColor;
          HasDate := False;
        end;
      Inc(NextDate);
      Inc(i);
      if i>7 then
        begin
          i := 1;
          Inc(j);
        end;
    end;
  for i:=1 to 7 do
    for j:=1 to 6 do
      if MShape[i, j].Visible then MShape[i, j].invalidate;
  MLastI := NewI;
  MLastJ := NewJ;
end;

procedure TxCalendar.UpdateMonth;
var
  i, j: Integer;
  AaYear, AaMonth, AaDay: Word;
  LastDate: TDateTime;
  NewI, NewJ: Integer;
  ThisDay: Integer;
  LastDay: Integer;
begin
  NewI := 0;
  NewJ := 0;
  if NewPage or InRefreshing then
    RefreshMonth
  else
  begin
    DecodeDate(FDate, AaYear, AaMonth, AaDay);
    LastDay := MShape[MLastI, MLastJ].ADay;
    LastDate := EncodeDate(AaYear, AaMonth, LastDay);
    ThisDay := Day;
    for i:=1 to 7 do
      for j:=1 to 6 do
        if (MShape[i, j].ADay = ThisDay) and
           (MShape[i, j].AMonth = tThis) then
          begin
            NewI := i;
            NewJ := j;
          end;
    with MShape[MLastI, MLastJ] do
      begin
        Canvas.Font.Assign(FFont);
        Shape := stRectangle;
        try
          if (DayOfWeek(LastDate) = 1)
{$IFDEF VER90}
{$ELSE}
           or IsItHoliday(AaYear, AaMonth, LastDay)
{$ENDIF}
           then
              CColor := HolidayColor
            else
              CColor := ColorOfThisMonthDays;
        except
          on exception do CColor := ColorOfThisMonthDays;
        end;
        Brush.Color := BKColor;
        OutColor := OuterColor;
        HasDate := False;
        invalidate;
      end;
    with MShape[NewI, NewJ] do
      begin
        Canvas.Font.Assign(FFont);
        Shape := stRectangle;
        CColor := CurColor;
        Brush.Color := CurBKColor;
        OutColor := OuterColor;
        HasDate := True;
        invalidate;
      end;
    MLastI := NewI;
    MLastJ := NewJ;
  end;
end;

function TxCalendar.GetMinDate: String;
begin
  if FMinDate = 0 then
    Result := ''
  else
    DateTimeToString(Result, 'dd.mm.yyyy', FMinDate);
end;

procedure TxCalendar.SetMinDate(Value: String);
begin
  if Value<>'' then
    FMinDate := StrToDate(Value)
  else
    FMinDate := 0;
  Refresh;
end;

function TxCalendar.GetMaxDate: String;
begin
  if FMaxDate = 0 then
    Result := ''
  else
    DateTimeToString(Result, 'dd.mm.yyyy', FMaxDate);
end;

procedure TxCalendar.SetMaxDate(Value: String);
begin
  if Value <> '' then
    FMaxDate := StrToDate(Value)
  else
    FMaxDate := 0;
  Refresh;
end;

procedure TxCalendar.SetRect(Shape: TFullShape);
var
  i, j: Integer;
  AaYear, AaMonth, AaDay: Integer;
  AaDate: TDateTime;
////  LastDate: TDateTime;
////  NextDate: Word;
  NewI, NewJ: Integer;
////  ThisDay: Integer;
///  LastDay: Integer;
begin
  NewI := 0;
  NewJ := 0;

  Shape.GetDate(Year, Month, day, AaYear, AaMonth, AaDay);

  { voila! this is one of known bugs
    you can't jump from the last day of the month
    to the day of another month which has
    less days than first month }
  try
    AaDate := EncodeDate(AaYear, AaMonth, AaDay);
  except
    exit;
  end;

  if ((FMinDate <> 0) and (AaDate < FMinDate)) or
     ((FMaxDate <> 0) and (AaDate > FMaxDate)) then
    exit;

  AaDay := Shape.ADay;
  AaMonth := Month;
  if Shape.AMonth = tLast then Dec(AaMonth);
  if Shape.AMonth = tNext then Inc(AaMonth);
  if MShape[MLastI, MLastJ].AMonth = tLast then Inc(AaMonth);
  if MShape[MLastI, MLastJ].AMonth = tNext then Dec(AaMonth);
  AaYear := Year;
  if AaMonth = 0 then
    begin
      AaMonth := 12;
      Dec(AaYear);
    end;
  if AaMonth = 13 then
    begin
      AaMonth := 1;
      Inc(AaYear);
    end;
  if (AaDay = Day) and (AaMonth = Month) and (AaYear = Year) then exit;
  for i:=1 to 7 do
    for j:=1 to 6 do
      if (MShape[i, j] = Shape) then
        begin
          NewI := i;
          NewJ := j;
        end;
  if MShape[MLastI, MLastJ].AMonth = tThis then
    with MShape[MLastI, MLastJ] do
      begin
        Canvas.Font.Assign(FFont);
        Shape := stRectangle;
        try
          if (DayOfWeek(Date) = 1) or
             IsItHoliday(Year, Month, Day) then
              CColor := HolidayColor
            else
              CColor := ColorOfThisMonthDays;
        except
          on exception do CColor := ColorOfThisMonthDays;
        end;
        Brush.Color := BKColor;
        OutColor := OuterColor;
        HasDate := False;
        invalidate;
      end
  else
    with MShape[MLastI, MLastJ] do
      begin
        Canvas.Font.Assign(FFont);
        Shape := stRectangle;
        CColor := ColorOfOtherMonthDays;
        OutColor := OuterColor;
        Brush.Color := BKColor;
        HasDate := False;
        invalidate;
      end;
  with MShape[NewI, NewJ] do
    begin
      Canvas.Font.Assign(FFont);
      Shape := stRectangle;
      CColor := CurColor;
      Brush.Color := CurBKColor;
      OutColor := OuterColor;
      HasDate := True;
      invalidate;
    end;
  MLastI := NewI;
  MLastJ := NewJ;
  FDate := EncodeDate(AaYear, AaMonth, AaDay);
  DateChanging;
end;

procedure TxCalendar.UpdateYear;
var
  i, j: Integer;
  AYear, AMonth, ADay: Word;
////  FirstDate: TDateTime;
////  NextDate: Word;
  NewI, NewJ: Integer;
////  a: TREct;
begin
  NewI := 0;
  NewJ := 0;

  if NewPage or InRefreshing then
    begin
      TheMonth.ctext := IntToStr(Year);
      TheMonth.invalidate;
    end;
  DecodeDate(FDate, AYear, AMonth, ADay);
////  FirstDate := EncodeDate(AYear, AMonth, 1);
  for i:=1 to 4 do
    for j:=1 to 3 do
      with YShape[i, j] do
        begin
          CText := Phrases[ lnShortMonthNames[(j-1)*4 + i] ];
          if (j-1)*4 + i = Month then
            begin
              Shape := stRectangle;
              CColor := CurColor;
              Brush.Color := CurBKColor;
              NewI := i;
              NewJ := j;
              HasDate := True;
            end
          else
            begin
              Shape := stRectangle;
              CColor := ColorOfThisMonthDays;
              Brush.Color := BKColor;
              HasDate:= False;
            end;
          Canvas.Font.Assign(FFont);
          OutColor := OuterColor;
          ADay := ( j - 1 ) * 4 + i;
        end;
  if Newpage or InRefreshing then
    begin
      for i:=1 to 4 do
        for j:=1 to 3 do
          if YShape[i, j].Visible then YShape[i, j].Paint;
    end
  else
    begin
      YShape[YLastI, YLastJ].invalidate;
      YShape[NewI, NewJ].invalidate;
    end;
  YLastI := NewI;
  YLastJ := NewJ;
end;

procedure TxCalendar.SetInCombo(Value: Boolean);
begin
  FInCombo := Value;
  if PMenu <> nil then
    PMenu.AutoPopup := not Value;
end;

procedure TxCalendar.WMLanguageChange(var Message: TMessage);
begin
  inherited;
  Refresh;
end;

procedure TxCalendar.SetParentFont(Value: Boolean);
begin
  inherited ParentFont := Value;
  if Assigned(MainPanel) and Assigned(YPanel) and Assigned(MPanel) then
    begin
      MainPanel.ParentFont := Value;
      YPanel.ParentFont := Value;
      MPanel.ParentFont := Value;
      if not Value then
        begin
          TheMonth.Canvas.Font.Assign(FButtonFont);
          PrevMonth.Canvas.Font.Assign(FButtonFont);
          NextMonth.Canvas.Font.Assign(FButtonFont);
        end;
      Refresh;
    end;
end;

procedure TxCalendar.SetCtl3D(Value: Boolean);
begin
  inherited Ctl3D := Value;
  if Assigned(MainPanel) and Assigned(YPanel) and Assigned(MPanel) then
    begin
      MainPanel.Ctl3D := Value;
      YPanel.Ctl3D := Value;
      MPanel.Ctl3D := Value;
      Refresh;
    end;
end;

procedure TxCalendar.PageChanged;
begin
  if Assigned(FOnPageChange) then
    FOnPageChange(Self);
end;

procedure TxCalendar.DateChanging;
begin
  if Assigned(FOnDateChanging) then
    FOnDateChanging(Self);
end;

procedure TxCalendar.DateChanged;
begin
  if Assigned(FOnDateChanged) then
    FOnDateChanged(Self);
end;

procedure TxCalendar.GoNextYear;
begin
  Year := Year + 1;
end;

procedure TxCalendar.GoPrevYear;
begin
  Year := Year - 1;
end;

procedure TxCalendar.GoNextMonth;
begin
  if Month < 12 then Month := Month + 1
    else
      begin
        HiDechanges;
        Month := 1;
        Year := Year + 1;
        ShowChanges;
      end;
end;

procedure TxCalendar.GoPrevMonth;
begin
  if Month > 1 then Month := Month - 1
    else
      begin
        HiDechanges;
        Month := 12;
        Year := Year - 1;
        ShowChanges;
      end;
end;

procedure TxCalendar.ShiftDay(Step: Integer);
var
  x: Integer;
begin
  HiDechanges;
  x := Step;
  if x>0 then
    begin
      while (x + Day > DaysThisMonth) do
        begin
          x := x - (DaysThisMonth - Day + 1);
          GoNextMonth;
          Day := 1;
        end;
      if x>0 then Day := Day + x;
    end
  else
    begin
      x := 0 - x;
      while (x >= Day) do
        begin
          x := x - Day;
          GoPrevMonth;
          Day := DaysThisMonth;
        end;
      if x>0 then Day := Day - x;
    end;
  ShowChanges;
end;

procedure TxCalendar.ShiftMonth(Step: Integer);
var
  x: Integer;
begin
  HiDechanges;
  x := Step;
  if x>0 then
    begin
      while (x + Month > 12) do
        begin
          x := x - (11 - Month);
          Year := Year + 1;
          Month := 1;
        end;
      if x>0 then Month := Month + x;
    end
  else
    begin
      x := 0 - x;
      while (x >= Month) do
        begin
          x := x - Month;
          Year := Year - 1;
          Month := 12;
        end;
      if x>0 then Month := Month - x;
    end;
  ShowChanges;
end;

procedure TxCalendar.GoNextDay;
begin
  if Day < DaysThisMonth then Day := Day + 1
    else
      begin
        HiDechanges;
        Day := 1;
        GoNextMonth;
        ShowChanges;
      end;
end;

procedure TxCalendar.GoPrevDay;
begin
  if Day > 1 then Day := Day - 1
    else
      begin
        HideChanges;
        GoPrevMonth;
        Day := DaysThisMonth;
        ShowChanges;
      end;
end;

function TxCalendar.GetHolidaysDatabaseName: TFileName;
begin
  Result := HTable.DatabaseName;
end;

function TxCalendar.GetHolidaysTableName: TFileName;
begin
  Result := HTable.TableName;
end;

procedure TxCalendar.ActivateTable;
begin
  HDataSource.DataSet := HTable;
  try
    HTable.Active := True;
  except
    HTable.TableName := '';
    exit;
  end;
  if HTable.FindField('Date') = nil then
    begin
      HTable.Active := false;
      HTable.TableName := '';
      raise ECalendar.Create('No Date field in table specified');
    end;
  HaveDB := True;
end;

procedure TxCalendar.SetHolidaysDatabaseName(Value: TFileName);
////var s: string;
begin
  HaveDB := False;
  HTable.Active := False;
  HTable.ReadOnly := False;
  HTable.Exclusive := False;
  HTable.DatabaseName := Value;
  ActivateTable;
end;

procedure TxCalendar.SetHolidaysTableName(Value: TFileName);
////var  s: string;
begin
  HaveDB := False;
  HTable.Active := False;
  HTable.ReadOnly := False;
  HTable.Exclusive := False;
  HTable.TableName := Value;
  HDataSource.DataSet := HTable;
  ActivateTable;
end;

procedure TxCalendar.MonthShapePressed(Sender: TObject);
begin
  ChangeOnMove := True;
  if not Focused then SetFocus;
  if Panel = pMonth then
    begin
      if Sender = PrevMonth then GoPrevMonth;
      if Sender = NextMonth then GoNextMonth;
      if Sender = TheMonth then Panel := pYear;
    end
  else if Panel = pYear then
    begin
      if Sender = PrevMonth then Year := Year - 1;
      if Sender = NextMonth then Year := Year + 1;
      if Sender = TheMonth then Panel := pMonth;
    end;
  ChangeOnMove := False;
end;

function TxCalendar.IsLeapYear(AYear: Integer): Boolean;
begin
  Result := (AYear mod 4 = 0) and
            ( (AYear mod 100 <> 0) or (AYear mod 400 = 0) );
end;

function TxCalendar.DaysPerMonth(AYear, AMonth: Integer): Integer;
const
  DaysInMonth: array[1..12] of Integer =
    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  if (AMonth<1) or (AMonth>12) then
    raise EConvertError.Create('Wrong month');
  Result := DaysInMonth[AMonth];
  if (AMonth = 2) and IsLeapYear(AYear) then
    Inc(Result); { leap-year Feb is special }
end;

function TxCalendar.DaysThisMonth: Integer;
begin
  Result := DaysPerMonth(Year, Month);
end;

function TxCalendar.DaysLastMonth: Integer;
begin
  if Month = 1 then Result := 31
    else Result := DaysPerMonth(Year, Month - 1 );
end;

procedure TxCalendar.CutDates(var ADate: TDateTime);
begin
  if ADate < FMinDate then ADate := FMinDate;
  if (FMaxDate <> 0) and (ADate > FMaxDate) then ADate := FMaxDate;
end;

procedure TxCalendar.SetDate(ADate: TDateTime);
var
  AMonth, AYear, ADay: Word;
begin
  if ADate = 0 then ADate := SysUtils.Date;
  CutDates(ADate);
  if ADate <> FDate then
    begin
      DecodeDate(ADate, AYear, AMonth, ADay);
      if Year<>AYear then NewPage := True;
      if (Month <> AMonth) and (panel = pMonth) then NewPage := True;
      Newdate := True;
      FDate := ADate;
      Update;
    end;
end;

function TxCalendar.GetMonth: Integer;
var
  AMonth, AYear, ADay: Word;
begin
  DecodeDate(FDate, AYear, AMonth, ADay);
  Result := AMonth;
end;

function TxCalendar.GetMonthName: String;
var
  AMonth, AYear, ADay: Word;
begin
  DecodeDate(FDate, AYear, AMonth, ADay);
  Result := Phrases[ lnLongMonthNames[AMonth] ];
end;

procedure TxCalendar.SetMonth(AMonth: Integer);
var
  OldMonth, AaMonth, AYear, ADay: Word;
begin
  DecodeDate(FDate, AYear, OldMonth, ADay);
  if ADay > DaysPerMonth(AYear, AMonth) then
    ADay := DaysPerMonth(AYear, AMonth);
  FDate := EncodeDate(AYear, AMonth, ADay);
  CutDates(FDate);
  DecodeDate(FDate, AYear, AaMonth, ADay);
  if AaMonth = OldMonth then exit;
  if panel <> pYear then NewPage := True;
  Newdate := True;
  Update;
end;

procedure TxCalendar.SetMonthName(AName: String);
var 
  AMonth: Word;
begin
  AMonth := 1;
  while (Comparetext(UpperCase(Copy(Phrases[ lnLongMonthNames[AMonth] ], 1,
         length(AName))), UpperCase(AName))<>0)
         and (AMonth<=12) do Inc(Amonth);
  Month := AMonth;
end;

function TxCalendar.GetYear: Integer;
var
  AMonth, AYear, ADay: Word;
begin
  DecodeDate(FDate, AYear, AMonth, ADay);
  Result := AYear;
end;

procedure TxCalendar.SetYear(AYear: Integer);
var
  AMonth, OldYear, AaYear, ADay: Word;
begin
  DecodeDate(FDate, oldYear, AMonth, ADay);
  if ADay > DaysPerMonth(AYear, AMonth) then
    ADay := DaysPerMonth(AYear, AMonth);
  FDate := EncodeDate(AYear, AMonth, ADay);
  CutDates(FDate);
  DecodeDate(FDate, AaYear, AMonth, ADay);
  if AaYear = OldYear then exit;
  NewPage := True;
  NewDate := True;
  Update;
end;

function TxCalendar.GetDay: Integer;
var
  AMonth, AYear, ADay: Word;
begin
  DecodeDate(FDate, AYear, AMonth, ADay);
  Result := ADay;
end;

procedure TxCalendar.SetDay(ADay: Integer);
var
  AMonth, AYear, OldDay, AaDay: Word;
begin
  DecodeDate(FDate, AYear, AMonth, OldDay);
  if ADay <> OldDay then
    begin
      FDate := EncodeDate(AYear, AMonth, ADay);
      CutDates(FDate);
      DecodeDate(FDate, AYear, AMonth, AaDay);
      if AaDay <> ADay then NewDate := True;
      Update;
    end;
end;

function TxCalendar.GetDayTypeStr: String;
begin
  Result := TypeOfDayStr(Date);
end;

function TxCalendar.TypeOfDayStr(ADate: TDateTime): String;
var
  y, m, d: Word;
begin
  DecodeDate(ADate, y, m, d);
  Result := '';
  try
    if HaveDB then
      with Htable do
        begin
          SetKey;
          (FieldByName('Date') as TDateField).Value := ADate;
          if GotoKey then
            Result := FieldByName('Holiday').AsString
          else
            begin
              SetKey;
              (FieldByName('Date') as TDateField).Value :=
                EncodeDate(PermanentHoliday, m, d);
              if GotoKey then
                  Result := FieldByName('Holiday').AsString;
            end;
        end;
  except
    on exception do { nothing };
  end;
  if Result='' then
    begin
      if DayOfWeek(FDate) mod 7 < 2 then Result := Phrases[ lnWeekend ]
        else Result := Phrases[ lnWorkingDay ];
    end;
end;

function TxCalendar.GetDayType: TDayType;
begin
  Result := TypeOfDay(Date);
end;

function TxCalendar.TypeOfDay(ADate: TDateTime): TDayType;
var
  y, m, d: Word;
begin
  DecodeDate(ADate, y, m, d);
  Result := dtWorkingDay;
  try
    if HaveDB then
      with Htable do
        begin
          SetKey;
          (FieldByName('Date') as TDateField).Value := ADate;
          if GotoKey then
            Result := dtHoliday { this year holiday }
          else
            begin
              SetKey;
              (FieldByName('Date') as TDateField).Value :=
                EncodeDate(PermanentHoliday, m, d);
              if GotoKey then
                  Result := dtHoliday; { permanent holiday }
            end;
        end;
  except
    on exception do { nothing };
  end;
  if Result = dtWorkingDay then
    if DayOfWeek(FDate) mod 7 < 2 then Result := dtWeekend;
end;

procedure TxCalendar.SetColorOfThisMonthDays(AColor: TColor);
begin
  FColorOfThisMonthDays := AColor;
  Repaint;
end;

procedure TxCalendar.SetHolidayColor(AColor: TColor);
begin
  FHolidayColor := AColor;
  Refresh;
end;

procedure TxCalendar.SetColorOfOtherMonthDays(AColor: TColor);
begin
  if AColor <> FColorOfOtherMonthDays then
  begin
    FColorOfOtherMonthDays := AColor;
    Update;
    Refresh;
  end;
end;

procedure TxCalendar.SetCurColor(AColor: TColor);
begin
  if FCurColor <> AColor then
  begin
    FCurColor := AColor;
    Refresh;
  end;
end;

procedure TxCalendar.SetCurBKColor(AColor: TColor);
begin
  if AColor <> FCurBKColor then
  begin
    FCurBKColor := AColor;
    Refresh;
  end;
end;

procedure TxCalendar.SetHeadColor(AColor: TColor);
begin
  if AColor <> FHeadColor then
  begin
    FHeadColor := AColor;
    Refresh;
  end;
end;

procedure TxCalendar.SetHeadBKColor(AColor: TColor);
begin
  if AColor <> FHeadBKColor then
  begin
    FHeadBKColor := AColor;
    Refresh;
  end;
end;

procedure TxCalendar.SetHeadOuterColor(AColor: TColor);
begin
  if AColor <> FHeadOuterColor then
  begin
    FHeadOuterColor := AColor;
    Refresh;
  end;
end;

procedure TxCalendar.SetBKColor(AColor: TColor);
begin
  MPanel.Color := AColor;
  YPanel.Color := AColor;
  FBKColor := AColor;
  Refresh;
end;

function TxCalendar.GetDelay: Integer;
begin
  Result := Timer.Interval;
end;

procedure TxCalendar.SetDelay(Value: Integer);
begin
  Timer.Interval := Value;
end;

procedure TxCalendar.SetOuterColor(AColor: TColor);
begin
  if AColor <> FOuterColor then
  begin
    FOuterColor := AColor;
    Refresh;
  end;
end;

procedure TxCalendar.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
  Refresh;
end;

procedure TxCalendar.SetHeadFont(AFont: TFont);
begin
  FHeadFont.Assign(AFont);
  Refresh;
end;

procedure TxCalendar.SetButtonFont(AFont: TFont);
begin
  FButtonFont.Assign(AFont);
  TheMonth.Canvas.Font.Assign(FButtonFont);
  PrevMonth.Canvas.Font.Assign(FButtonFont);
  NextMonth.Canvas.Font.Assign(FButtonFont);
  Refresh;
end;

procedure TxCalendar.ShapeMouseMoved(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
////var  TheDay: Integer;
begin
  if (ssLeft in Shift) and ChangeOnMove then
    begin
      if Panel = pMonth then
        SetRect(Sender as TFullShape)
      else
        begin
          with Sender as TFullShape do Month := ADay;
        end;
    end
  else ChangeOnMove := False;
end;

procedure TxCalendar.ShapeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
////var  TheDay: Integer;
begin
  DateOnPress := FDate;
  ChangeOnMove := True;
  if not Focused then SetFocus;
  if Panel = pMonth then
    SetRect(Sender as TFullShape)
  else
    begin
      with Sender as TFullShape do Month := ADay;
    end;
end;

procedure TxCalendar.ShapeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TheDay: Integer;
begin
  if not(ChangeOnMove) then exit;
  ChangeOnMove := False;
  if Panel = pMonth then
    with Sender as TFullShape do
      begin
        if AMonth = tThis then
          begin
            SetRect(Sender as TFullShape)
          end
        else
          begin
            FDate := DateOnPress;
            HiDechanges;
            TheDay := ADay;
            if AMonth = tLast then GoPrevMonth;
            if AMonth = tNext then GoNextMonth;
            Day := TheDay;
            ShowChanges;
          end;
        DateChanged;
      end
  else
    begin
      HiDechanges;
      with Sender as TFullShape do Month := ADay;
      if FAutoShowMonth then panel := pMonth;
      ShowChanges;
    end;
  Click;
end;

procedure TxCalendar.FontChanged(Sender: TObject);
begin
  if Sender as TFont = FFont then
    begin
      FFont.Assign(Sender as TFont);
    end
  else if Sender as TFont = FHeadFont then
    begin
      FHeadFont.Assign(Sender as TFont);
    end
  else if Sender as TFont = FButtonFont then
    begin
      FButtonFont.Assign(Sender as TFont);
      TheMonth.Canvas.Font.Assign(FButtonFont);
      NextMonth.Canvas.Font.Assign(FButtonFont);
      PrevMonth.Canvas.Font.Assign(FButtonFont);
      TheMonth.Refresh;
    end;
  Refresh;
end;

function TxCalendar.GetStartOfWeek: TWeekDays;
begin
  Result := wMonday;
  case FStartOfWeek of
    1: Result := wSunday;
    2: Result := wMonday;
    3: Result := wTuesday;
    4: Result := wWednesday;
    5: Result := wThursday;
    6: Result := wFriday;
    7: Result := wSaturday;
  end;
end;

procedure TxCalendar.SetStartOfWeek(Value: TWeekDays);
begin
  case Value of
    wSunday    : FStartOfWeek := 1;
    wMonday    : FStartOfWeek := 2;
    wTuesday   : FStartOfWeek := 3;
    wWednesday : FStartOfWeek := 4;
    wThursday  : FStartOfWeek := 5;
    wFriday    : FStartOfWeek := 6;
    wSaturday  : FStartOfWeek := 7;
  end;
  Refresh;
end;


procedure TxCalendar.SetPanel(APanel: TPanels);
begin
  ChangeOnMove := False;
  if APanel<>FPanel then
    begin
      NewPage := True;
      FPanel := APanel;
      case APanel of
        pYear:
          begin
            MPanel.Visible := False;
            YPanel.Visible := True;
          end;
        pMonth:
          begin
            YPanel.Visible := False;
            MPanel.Visible := True;
          end;
      end;
      Update;
    end;
end;

procedure TxCalendar.SetButtonHeight(H: Integer);
begin
  FButtonHeight := H;
  SetSizes;
  Refresh;
end;

procedure TxCalendar.SetArrowWidth(W: Integer);
begin
  if FArrowWidth <> W then
  begin
    FArrowWidth := W;
    SetSizes;
    Refresh;
  end;
end;

procedure TxCalendar.SetGapWidth(W: Integer);
begin
  FGapWidth := W;
  SetSizes;
  Refresh;
end;

procedure TxCalendar.SetBevelInner(Value: TPanelBevel);
begin
  MainPanel.BevelInner := Value;
  SetSizes;
  Refresh;
end;

procedure TxCalendar.SetBevelOuter(Value: TPanelBevel);
begin
  MainPanel.BevelOuter := Value;
  SetSizes;
  Refresh;
end;

procedure TxCalendar.SetBevelWidth(Value: TBevelWidth);
begin
  MainPanel.BevelWidth := Value;
  SetSizes;
  Refresh;
end;

procedure TxCalendar.SetBorderWidth(Value: TBorderWidth);
begin
  MainPanel.BorderWidth := Value;
  SetSizes;
  Refresh;
end;

procedure TxCalendar.SetBorderStyle(Value: TBorderStyle);
begin
  MainPanel.BorderStyle := Value;
  SetSizes;
  Refresh;
end;

function TxCalendar.GetBevelInner: TPanelBevel;
begin
  Result := MainPanel.BevelInner;
end;

function TxCalendar.GetBevelOuter: TPanelBevel;
begin
  Result := MainPanel.BevelOuter;
end;

function TxCalendar.GetBevelWidth: TBevelWidth;
begin
  Result := MainPanel.BevelWidth;
end;

function TxCalendar.GetBorderWidth: TBorderWidth;
begin
  Result := MainPanel.BorderWidth;
end;

function TxCalendar.GetBorderStyle: TBorderStyle;
begin
  Result := MainPanel.BorderStyle;
end;

procedure TxCalendar.SetGapActiveColor(AColor: TColor);
begin
  FGapActiveColor := AColor;
  if Focused then MainPanel.Color := AColor;
end;

procedure TxCalendar.SetGapInactiveColor(AColor: TColor);
begin
  FGapinactiveColor := AColor;
  if not Focused then MainPanel.Color := AColor;
end;

procedure TxCalendar.WMLButtonDown(var Message: TWMLButtonDown);
var
  R: TPoint;
////  m: TWMLButtonDown;
////  H: Integer;
  j: Integer;
begin
  inherited;
  broadcast(Message);
  with Message do
    begin
      R := Point(XPos, YPos);
      MapWindowPoints(Handle, GetDesktopWindow, R, 1);
      if WindowFromPoint(R) = MPanel.Handle then
        begin
          R := Point(XPos, YPos);
          MapWindowPoints(Handle, MPanel.Handle, R, 1);
          for j:=0 to MPanel.ControlCount-1 do
            with MPanel.controls[j] do
              if (left<=r.x) and (Left+Width>=r.x) and
                 (top<=r.y) and (top+Height>=r.y) then
                   begin
                     perform(WM_LButtonDown, keys, MakeLong(r.x, r.y));
                   end;
        end;
      if WindowFromPoint(R) = YPanel.Handle then
        begin
          R := Point(XPos, YPos);
          MapWindowPoints(Handle, YPanel.Handle, R, 1);
          for j:=0 to YPanel.ControlCount-1 do
            with YPanel.controls[j] do
              if (left<=r.x) and (Left+Width>=r.x) and
                 (top<=r.y) and (top+Height>=r.y) then
                   begin
                     perform(WM_LButtonDown, keys, MakeLong(r.x, r.y));
                   end;
        end;
    end;
end;

procedure TxCalendar.WMLButtonUp(var Message: TWMLButtonUp);
var
  R: TPoint;
////  m: TWMLButtonDown;
////  H: Integer;
  j: Integer;
begin
  inherited;
  broadcast(Message);
  with Message do
    begin
      R := Point(XPos, YPos);
      MapWindowPoints(Handle, GetDesktopWindow, R, 1);
      if WindowFromPoint(R) = MPanel.Handle then
        begin
          R := Point(XPos, YPos);
          MapWindowPoints(Handle, MPanel.Handle, R, 1);
          for j:=0 to MPanel.ControlCount-1 do
            with MPanel.controls[j] do
              if (left<=r.x) and (Left+Width>=r.x) and
                 (top<=r.y) and (top+Height>=r.y) then
                   begin
                     perform(WM_LButtonUp, keys, MakeLong(r.x, r.y));
                   end;
        end;
      if WindowFromPoint(R) = YPanel.Handle then
        begin
          R := Point(XPos, YPos);
          MapWindowPoints(Handle, YPanel.Handle, R, 1);
          for j:=0 to YPanel.ControlCount-1 do
            with YPanel.controls[j] do
              if (left<=r.x) and (Left+Width>=r.x) and
                 (top<=r.y) and (top+Height>=r.y) then
                   begin
                     perform(WM_LButtonUp, keys, MakeLong(r.x, r.y));
                   end;
        end;
    end;
end;

procedure TxCalendar.WMMouseMove(var Message: TWMMouseMove);
var
  R: TPoint;
////  m: TWMLButtonDown;
////  H: Integer;
  j: Integer;
begin
  inherited;
  broadcast(Message);
  with Message do
    begin
      R := Point(XPos, YPos);
      MapWindowPoints(Handle, GetDesktopWindow, R, 1);
      if WindowFromPoint(R) = MPanel.Handle then
        begin
          R := Point(XPos, YPos);
          MapWindowPoints(Handle, MPanel.Handle, R, 1);
          for j:=0 to MPanel.ControlCount-1 do
            with MPanel.controls[j] do
              if (left<=r.x) and (Left+Width>=r.x) and
                 (top<=r.y) and (top+Height>=r.y) then
                   begin
                     perform(WM_MouseMove, keys, MakeLong(r.x, r.y));
                   end;
        end;
      if WindowFromPoint(R) = YPanel.Handle then
        begin
          R := Point(XPos, YPos);
          MapWindowPoints(Handle, YPanel.Handle, R, 1);
          for j:=0 to YPanel.ControlCount-1 do
            with YPanel.controls[j] do
              if (left<=r.x) and (Left+Width>=r.x) and
                 (top<=r.y) and (top+Height>=r.y) then
                   begin
                     perform(WM_MouseMove, keys, MakeLong(r.x, r.y));
                   end;
        end;
    end;
end;

function TxCalendar.GetArrowFocusedColor: TColor;
begin
  Result := PrevMonth.TColorFocused;
end;

function TxCalendar.GetArrowColor: TColor;
begin
  Result := PrevMonth.TColorNonfocused;
end;

procedure TxCalendar.SetArrowFocusedColor(Value: TColor);
begin
  PrevMonth.TColorFocused := value;
  nextMonth.TColorFocused := value;
  Refresh;;
end;

procedure TxCalendar.SetArrowColor(Value: TColor);
begin
  PrevMonth.TColorNonfocused := value;
  NextMonth.TColorNonfocused := value;
  Refresh;
end;

function TxCalendar.GetMonthRectColor: TColor;
begin
  Result := TheMonth.MColor;
end;

procedure TxCalendar.SetMonthRectColor(Value: TColor);
begin
  TheMonth.MColor := Value;
  Refresh;;
end;

procedure TxCalendar.SetForceTodayOnStart(Value: Boolean);
begin
  FForceTodayOnStart := Value;
  FRememberDate := not Value;
end;

function TxCalendar.GetCalendarDate: String;
begin
  DateTimeToString( Result, 'ddddd', Date );
end;

procedure TxCalendar.SetCalendarDate(Value: String);
begin
  Date := StrToDate(Value)
end;

procedure TxCalendar.SetButtonBKColor(Value: TColor);
begin
  FButtonBKColor := Value;
  TheMonth.Brush.Color := value;
  NextMonth.Brush.Color := value;
  PrevMonth.Brush.Color := value;
  TheMonth.OutColor := value;
  NextMonth.OutColor := value;
  PrevMonth.OutColor := value;
  Refresh;
end;


{ TFullCalendarWnd -------------------------------------------}

constructor TFullCalendarWnd.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := [csOpaque];

  ParentShowHint := False;

  Calendar := TxCalendar.create(Self);
  InsertControl(calendar);

  Calendar.InCombo := True;
  Calendar.Align := alClient;
  Calendar.OnDateChanging := DateChanging;
  Calendar.OnPageChange := PageChanged;
  Calendar.OnDateChanged := DateChanged;
  Calendar.BevelInner := DefBevelInner;
  Calendar.BevelOuter := DefBevelOuter;
  Calendar.BevelWidth := DefBevelWidth;
  Calendar.BorderWidth := DefBorderWidth;
  Calendar.OnKeyPress := Calendarkeypress;

  Cursor := crArrow;
  Visible := False;
end;

procedure TFullCalendarWnd.DateChanging(Sender: TObject);
begin
  if not Visible then exit;
  if not(Parent as TxCalendarCombo).Starting then
    (Parent as TxCalendarCombo).DateChanging;
end;

procedure TFullCalendarWnd.DateChanged(Sender: TObject);
begin
  if not Visible then exit;
  MouseCapture := False;
  ForceCapture := False;
  if (Parent as TxCalendarCombo).Starting then exit;
  (Parent as TxCalendarCombo).Date := Calendar.Date;
  (Parent as TxCalendarCombo).ShowCalendarWnd := False;
  if Assigned(OnDateChanged) then OnDateChanged(Parent);
end;

procedure TFullCalendarWnd.CalendarKeyPress(Sender: TObject; var Key: Char);
begin
  If key = #27 then
    begin
      Key := #0;
      (Parent as TxCalendarCombo).ShowCalendarWnd := False;
    end;
end;

procedure TFullCalendarWnd.PageChanged(Sender: TObject);
begin
  if not Visible then exit;
  if Assigned(OnPageChange) then OnPageChange(Parent);
end;

procedure TFullCalendarWnd.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  with Params do
  begin
    if (csDesigning in Parent.ComponentState) then
      Style := ws_Child
    else
      Style := ws_popup;
  end;
end;

procedure TFullCalendarWnd.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Calendar.SetFocus;
end;

procedure TFullCalendarWnd.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
end;

procedure TFullCalendarWnd.WMLButtonUp(var Message: TWMLButtonUp);
var
  R: TPoint;
begin
  if MouseCapture then
    with Message do
      begin
        R := Point(XPos, YPos);
        if (R.X<0) or (R.X > Width) or (R.Y<0) or (R.Y > Height) then
          begin
          end
        else
          begin
            MouseCapture := False;
            ForceCapture := True;
            MapWindowPoints(Handle, GetDesktopWindow, R, 1);
            Calendar.Perform(wm_LButtonUp, Keys, MakeLong(XPos, YPos));
            MouseCapture := ForceCapture;
          end;
      end
  else
    inherited;
end;

procedure TFullCalendarWnd.WMMOUSEACTIVATE(var Message: TMessage);
begin
  inherited;
end;

const Lastw : Word = 0;

procedure TFullCalendarWnd.WMACTIVATE(var Message: TMessage);
begin
  if Message.wParam = 0 then
    begin
      (Parent as TxCalendarCombo).CaptureFocus := False;
      (Parent as TxCalendarCombo).ShowCalendarWnd := False;
    end;
  inherited;
end;

procedure TFullCalendarWnd.WMLButtonDown(var Message: TWMLButtonDown);
var
  R: TPoint;
begin
  if MouseCapture then
    with Message do
      begin
        R := Point(XPos, YPos);
        if (R.X<0) or (R.X > Width) or (R.Y<0) or (R.Y > Height) then
          begin
            MouseCapture := False;
            TxCalendarCombo(Parent).ShowCalendarWnd := False;
{            Msg1 := TWMLButtonDown(Message);
            Msg1.XPos := 10;
            Msg1.YPos := 10;
            Owner.Dispatch(Message);
            PostMessage(0, Msg1.Msg, TMessage(Msg1).wParam,
              TMessage(Msg1).lParam);}
          end
        else
          begin
            MouseCapture := False;
            ForceCapture := True;
            MapWindowPoints(Handle, GetDesktopWindow, R, 1);
            Calendar.Perform(wm_LButtonDown, Keys, MakeLong(XPos, YPos));
            MouseCapture := ForceCapture;
          end;
      end
  else
    inherited;
end;

procedure TFullCalendarWnd.WMMouseMove(var Message: TWMMouseMove);
var
  R: TPoint;
begin
  if MouseCapture then
    with Message do begin
      R:= Point(XPos, YPos);
      if not((R.X<0) or (R.X > Width) or (R.Y<0) or (R.Y > Height)) then
        begin
          MapWindowPoints(Handle, GetDesktopWindow, R, 1);
          Calendar.Perform(wm_MouseMove, Keys, MakeLong(XPos, YPos));
        end
      else inherited;
    end
  else
    inherited;
end;


{ ----------- TxCalendarCombo component -------------------------------}

constructor TxCalendarCombo.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  
  Starting := True;
  ControlStyle := ControlStyle + [csCaptureMouse];

  CalendarWnd := TFullCalendarWnd.Create(Self);
  CalendarWnd.Parent := Self;

  FForceTodayOnStart := DefForceToday;
  FRememberDate := not DefForceToday;
  FShowCalendarWnd := False;
  FDown := False;
  FComboWidth := DefComboWidth;
  FComboHeight := DefComboHeight;
  Width := DefEditWidth;
  Height := DefEditHeight;

  CalendarWnd.Width := FComBoWidth;
  CalendarWnd.Height := FComboHeight;

  EditBox := TxxDateEdit.Create(Self);
  EditBox.InCombo := True;
  InsertControl(EditBox);

  EditBox.AutoSize := False;
  EditBox.Top := 1;
  EditBox.Left := 1;
  EditBox.Width := Width - COMBO_BTN_WIDTH - SPIN_BTN_WIDTH - 1;
  EditBox.Height := Height - 1;
  EditBox.TabStop := True;
  EditBox.ParentCtl3D := False;
  EditBox.ReadOnly := False;
  EditBox.OnDateChange := EditBoxChange;
  EditBox.OnDateChanging := EditBoxChanging;
  EditBox.OnKeyDown := EditKeyDown;
  EditBox.OnKeyPress := EditKeyPress;

  SpinButton := TxSpinButton.Create(Self);
  SpinButton.Ctl3D := True;
  SpinButton.Height := Height - 1;
  SpinButton.Width := SPIN_BTN_WIDTH;
  SpinButton.Left := EditBox.Left + EditBox.Width;
  SpinButton.Top := 1;
  SpinButton.SpinGap := 1;
  SpinButton.OnUpClick := DoOnMoveSpin;
  SpinButton.OnDownClick := DoOnMoveSpin;
  SpinButton.OnMoveSpin := DoOnMoveSpin;
  InsertControl(SpinButton);

  inherited TabStop := False;

  ParentCtl3D := False;
  Ctl3D := DefComboEditCtl3D;
  ComboCtl3D := DefComboCtl3D;

  SetDate(CalendarWnd.Calendar.Date);

  ParentFont := DefParentFont;
  GapColor := DefGapColor;

  Starting := False;
end;

procedure TxCalendarCombo.SetState(NewState: Boolean);
begin
  if NewState <> FShowCalendarWnd then
    begin
      FShowCalendarWnd := NewState;
      if FShowCalendarWnd then
        begin
          CaptureFocus := True;
          MoveCalendarWnd;
          try
            CalendarWnd.Calendar.Date := Date;
          except
            on EConvertError do
              CalendarWnd.Calendar.Date := SysUtils.Date;
          end;
          CalendarWnd.MouseCapture := True;
          CalendarWnd.Show;
          CalendarWnd.SetFocus;
          Invalidate;
        end
      else
        begin
          CalendarWnd.MouseCapture := False;
          CalendarWnd.Hide;
          if CaptureFocus then
            EditBox.SetFocus;
          Invalidate;
        end;
    end;
end;

procedure TxCalendarCombo.SetDown(ADown: Boolean);
begin
  if FDown <> ADown then
  begin
    FDown := ADown;
    Invalidate;
  end;
end;

procedure TxCalendarCombo.MoveCalendarWnd;
var
  P, P1: TPoint;
  MX, MY: Integer;
begin
  MX := GetSystemMetrics(SM_CXFULLSCREEN);
  MY := GetSystemMetrics(SM_CYFULLSCREEN);
  P := Point(Left, Top);
  MapWindowPoints(Parent.Handle, GetDesktopWindow, P, 1);

  if P.Y + Height + ComboHeight < MY then P1.Y := P.Y + Height
    else P1.Y := P.Y - ComboHeight;
  if P1.Y < 0 then P1.Y := 0;

  if P.X + ComboWidth < MX then P1.X := P.X
    else P1.X := P.X + Width - ComboWidth;
  if P1.X < 0 then P1.X := 0;
  if P1.X + ComboWidth > MX then P1.X := MX - ComboWidth;

  if CalendarWnd.Parent <> nil then
    MoveWindow(CalendarWnd.HANDLE, P1.X, P1.Y, FComboWidth, FComboHeight,
      True);
end;

procedure TxCalendarCombo.DrawComboButton;
var
  R: TRect;
  Bitmap: TBitmap;
  bmp: TBitmap;
begin
  Bitmap := TBitmap.Create;
  bmp := TBitmap.Create;
  try
    R := Rect(0, 0, COMBO_BTN_WIDTH, Height);

    Bitmap.Width := COMBO_BTN_WIDTH;
    Bitmap.Height := Height;

    R := DrawButtonFace(Bitmap.Canvas, R, 1, bsNew, False,
      FDown or CalendarWnd.Visible, False);

    Inc(R.Right, -2);
    Inc(R.Left, 2);
    Inc(R.Top, 2);
    Inc(R.Bottom, -2);

    Bitmap.Canvas.Pen.Color := clBtnShadow;
    Bitmap.Canvas.MoveTo(R.right + 3, R.top + 1);
    Bitmap.Canvas.LineTo(R.right + 3, R.bottom - 1);

    Bitmap.Canvas.Pen.Color := clBtnHighlight;
    Bitmap.Canvas.MoveTo(R.right + 4, R.top + 1);
    Bitmap.Canvas.LineTo(R.right + 4, R.bottom - 1);

{$IFDEF VER90}
{$ELSE}
    Bmp.Handle := LoadBitmap(0, PChar(OBM_COMBO));
{$ENDIF}

    if Enabled then begin
      Bitmap.Canvas.Pen.Color := clBtnText;
      Bitmap.Canvas.Brush.Color := clBtnText;
    end
    else begin
      Bitmap.Canvas.Pen.Color := clBtnShadow;
      Bitmap.Canvas.Brush.Color := clBtnShadow;
    end;

    if FDown or CalendarWnd.Visible then
      Bitmap.Canvas.Draw(((COMBO_BTN_WIDTH - BMP.Width + 1) div 2) + 1,
                         ((Height - BMP.Height + 1) div 2) + 1, BMP)
    else
      Bitmap.Canvas.Draw((COMBO_BTN_WIDTH - BMP.Width + 1) div 2,
                         (Height - BMP.Height + 1) div 2, BMP);

    Canvas.Draw(Width - COMBO_BTN_WIDTH, 0, Bitmap);

    if EditBox.Focused then
    begin
      R := Rect(Width - COMBO_BTN_WIDTH + 2, 2, Width - 2, Height - 2);
      DrawFocusRect(Canvas.Handle, R);
    end;
  finally
    BMP.Free;
    Bitmap.Free;
  end;
end;

procedure TxCalendarCombo.EditBoxChange(Sender: TObject);
begin
  if Starting then exit;
  DateChanged;
end;

procedure TxCalendarCombo.EditBoxChanging(Sender: TObject);
begin
  if Starting then exit;
  DateChanging;
end;

procedure TxCalendarCombo.DoOnMoveSpin(Sender: TObject; Delta: Integer);
begin
  try
    Date := Date + Delta;
    DateChanged;
  except
  end;
end;

procedure TxCalendarCombo.DoExit;
var
  Ok: Boolean;
begin
  Ok := False;
  try
    GetDate;
    Ok := True;
  except
    on EConvertError do ;
  end;
  
  if Ok then
    begin
      if EditBox.CheckDateLimits then
        begin
          if EditBox.DateWasChanged then DateChanged;
          inherited DoExit
        end
      else
        SetFocus;
    end
  else
    begin
      MessageDlg(EditBox.Text + Phrases[lnNotValidDate], mtError, [mbOk], 0);
      SetFocus;
    end;
end;

procedure TxCalendarCombo.CreateWnd;
begin
  inherited CreateWnd;
  MoveCalendarWnd;
end;

procedure TxCalendarCombo.Paint;
begin
  inherited Paint;
  DrawComboButton;
end;

procedure TxCalendarCombo.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  Down := True;
end;

procedure TxCalendarCombo.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  Down := False;
end;

procedure TxCalendarCombo.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  if MouseCapture then
    Down := (Message.XPos >= Width - COMBO_BTN_WIDTH) and
      (Message.XPos <= Width) and (Message.YPos >= 0) and
      (Message.YPos <= Height);
end;

procedure TxCalendarCombo.CNCommand(var Message: TWMCommand);
begin
end;

procedure TxCalendarCombo.WMMove(var Message: TWMMove);
begin
  inherited;
  MoveCalendarWnd;
end;

procedure TxCalendarCombo.WMSize(var Message: TWMSize);
begin
  inherited;
  EditBox.Width := Width - COMBO_BTN_WIDTH - SPIN_BTN_WIDTH - 1;
  EditBox.Height := Height - 1;
  SpinButton.SetBounds(EditBox.Left + EditBox.Width, 1,
                       SPIN_BTN_WIDTH, Height - 1);
end;

procedure TxCalendarCombo.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if GetParentForm(Self).Visible then
  begin
    EditBox.SetFocus;
    Invalidate;
  end;
end;

procedure TxCalendarCombo.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  Invalidate;
end;

procedure TxCalendarCombo.Click;
begin
  inherited Click;
  ShowCalendarWnd := not ShowCalendarWnd;
end;

{ returns True if edit contains valid not null date }
function TxCalendarCombo.HasValidDate: Boolean;
begin
  try
    Result := Date <> 0;
  except
    Result := False;
  end;
end;

procedure TxCalendarCombo.SetDate(ADate: TDateTime);
begin
  if ShowCalendarWnd and not(Starting) then
    if ADate = 0 then
      CalendarWnd.Calendar.Date := SysUtils.Date
    else
      CalendarWnd.Calendar.Date := ADate;
  EditBox.GettingCreated := Starting;
  EditBox.Date := ADate;
  EditBox.GettingCreated := false;
end;

procedure TxCalendarCombo.SetComboWidth(Value: Integer);
begin
  FComboWidth := Value;
  MoveCalendarWnd;
end;

procedure TxCalendarCombo.SetComboHeight(Value: Integer);
begin
  FComboHeight := Value;
  MoveCalendarWnd;
end;

function TxCalendarCombo.GetGapColor: TColor;
begin
  Result := CalendarWnd.Calendar.GapActiveColor;
end;

function TxCalendarCombo.GetBevelInner: TPanelBevel;
begin
  Result := CalendarWnd.Calendar.BevelInner;
end;

function TxCalendarCombo.GetBevelOuter: TPanelBevel;
begin
  Result := CalendarWnd.Calendar.BevelOuter;
end;

function TxCalendarCombo.GetBevelWidth: TBevelWidth;
begin
  Result := CalendarWnd.Calendar.BevelWidth;
end;

function TxCalendarCombo.GetBorderWidth: TBorderWidth;
begin
  Result := CalendarWnd.Calendar.BorderWidth;
end;

function TxCalendarCombo.GetGapWidth: Integer;
begin
  Result := CalendarWnd.Calendar.GapWidth;
end;

function TxCalendarCombo.GetButtonHeight: Integer;
begin
  Result := CalendarWnd.Calendar.ButtonHeight;
end;

function TxCalendarCombo.GetArrowWidth: Integer;
begin
  Result := CalendarWnd.Calendar.ArrowWidth;
end;

function TxCalendarCombo.GetColorOfThisMonthDays: TColor;
begin
  Result := CalendarWnd.Calendar.ColorOfThisMonthDays;
end;

function TxCalendarCombo.GetColorOfOtherMonthDays: TColor;
begin
  Result := CalendarWnd.Calendar.ColorOfOtherMonthDays;
end;

function TxCalendarCombo.GetCurColor: TColor;
begin
  Result := CalendarWnd.Calendar.CurColor;
end;

function TxCalendarCombo.GetCurBKColor: TColor;
begin
  Result := CalendarWnd.Calendar.CurBKColor;
end;

function TxCalendarCombo.GetHeadColor: TColor;
begin
  Result := CalendarWnd.Calendar.HeadColor;
end;

function TxCalendarCombo.GetHeadBKColor: TColor;
begin
  Result := CalendarWnd.Calendar.HeadBKColor;
end;

function TxCalendarCombo.GetHeadOuterColor: TColor;
begin
  Result := CalendarWnd.Calendar.HeadOuterColor;
end;

function TxCalendarCombo.GetBKColor: TColor;
begin
  Result := CalendarWnd.Calendar.BKColor;
end;

function TxCalendarCombo.GetOuterColor: TColor;
begin
  Result := CalendarWnd.Calendar.OuterColor;
end;

function TxCalendarCombo.GetFont: TFont;
begin
  Result := CalendarWnd.Calendar.Font;
end;

function TxCalendarCombo.GetHeadFont: TFont;
begin
  Result := CalendarWnd.Calendar.HeadFont;
end;

function TxCalendarCombo.GetButtonFont: TFont;
begin
  Result := CalendarWnd.Calendar.ButtonFont;
end;

function TxCalendarCombo.GetPanel: TPanels;
begin
  Result := CalendarWnd.Calendar.Panel;
end;

function TxCalendarCombo.GetMonth: Integer;
begin
  Result := EditBox.Month;
end;

function TxCalendarCombo.GetYear: Integer;
begin
  Result := EditBox.Year;
end;

function TxCalendarCombo.GetDay: Integer;
begin
  Result := EditBox.Day;
end;

function TxCalendarCombo.GetDate: TDateTime;
begin
  Result := EditBox.Date;
end;

function TxCalendarCombo.GetBorderStyle: TBorderStyle;
begin
  Result := CalendarWnd.Calendar.BorderStyle;
end;

function TxCalendarCombo.GetAutoShowMonth: Boolean;
begin
  Result := CalendarWnd.Calendar.AutoShowMonth;
end;

function TxCalendarCombo.GetOnDateChanging: TNotifyEvent;
begin
  Result := CalendarWnd.OnDateChanging;
end;

function TxCalendarCombo.GetOnDateChanged: TNotifyEvent;
begin
  Result := CalendarWnd.OnDateChanged;
end;

function TxCalendarCombo.GetOnPageChange: TNotifyEvent;
begin
  Result := CalendarWnd.OnPageChange;
end;

function TxCalendarCombo.GetArrowFocusedColor: TColor;
begin
  Result := CalendarWnd.Calendar.ArrowFocusedColor;
end;

function TxCalendarCombo.GetArrowColor: TColor;
begin
  Result := CalendarWnd.Calendar.ArrowColor;
end;

function TxCalendarCombo.GetMonthRectColor: TColor;
begin
  Result := CalendarWnd.Calendar.MonthRectColor;
end;

procedure TxCalendarCombo.SetGapColor(AColor: TColor);
begin
  CalendarWnd.Calendar.GapActiveColor := AColor;
  CalendarWnd.Calendar.GapInactiveColor := AColor;
end;

procedure TxCalendarCombo.SetBevelInner(Value: TPanelBevel);
begin
  CalendarWnd.Calendar.BevelInner := Value;
end;

procedure TxCalendarCombo.SetBevelOuter(Value: TPanelBevel);
begin
  CalendarWnd.Calendar.BevelOuter := Value;
end;

procedure TxCalendarCombo.SetBevelWidth(Value: TBevelWidth);
begin
  CalendarWnd.Calendar.BevelWidth := Value;
end;

procedure TxCalendarCombo.SetBorderWidth(Value: TBorderWidth);
begin
  CalendarWnd.Calendar.BorderWidth := Value;
end;

procedure TxCalendarCombo.SetGapWidth(W: Integer);
begin
  CalendarWnd.Calendar.GapWidth := W;
end;

procedure TxCalendarCombo.SetButtonHeight(H: Integer);
begin
  CalendarWnd.Calendar.Buttonheight := H;
end;

procedure TxCalendarCombo.SetArrowWidth(W: Integer);
begin
  CalendarWnd.Calendar.ArrowWidth := W;
end;

procedure TxCalendarCombo.SetColorOfThisMonthDays(AColor: TColor);
begin
  CalendarWnd.Calendar.ColorOfThisMonthDays := AColor;
end;

procedure TxCalendarCombo.SetColorOfOtherMonthDays(AColor: TColor);
begin
  CalendarWnd.Calendar.ColorOfOtherMonthDays := AColor;
end;

procedure TxCalendarCombo.SetCurColor(AColor: TColor);
begin
  CalendarWnd.Calendar.CurColor := AColor;
end;

procedure TxCalendarCombo.SetCurBKColor(AColor: TColor);
begin
  CalendarWnd.Calendar.CurBKColor := AColor;
end;

procedure TxCalendarCombo.SetHeadColor(AColor: TColor);
begin
  CalendarWnd.Calendar.HeadColor := AColor;
end;

procedure TxCalendarCombo.SetHeadBKColor(AColor: TColor);
begin
  CalendarWnd.Calendar.HeadBKColor := AColor;
end;

procedure TxCalendarCombo.SetHeadOuterColor(AColor: TColor);
begin
  CalendarWnd.Calendar.HeadOuterColor := AColor;
end;

procedure TxCalendarCombo.SetBKColor(AColor: TColor);
begin
  CalendarWnd.Calendar.BKColor := AColor;
end;

procedure TxCalendarCombo.SetOuterColor(AColor: TColor);
begin
  CalendarWnd.Calendar.OuterColor := AColor;
end;

procedure TxCalendarCombo.SetFont(AFont: TFont);
begin
  CalendarWnd.Calendar.Font := AFont;
end;

procedure TxCalendarCombo.SetHeadFont(AFont: TFont);
begin
  CalendarWnd.Calendar.HeadFont := AFont;
end;

procedure TxCalendarCombo.SetButtonFont(AFont: TFont);
begin
  CalendarWnd.Calendar.ButtonFont := AFont;
end;

procedure TxCalendarCombo.SetPanel(APanel: TPanels);
begin
  CalendarWnd.Calendar.Panel := APanel;
end;

procedure TxCalendarCombo.SetMonth(AMonth: Integer);
begin
  EditBox.Month := AMonth;
end;

procedure TxCalendarCombo.SetYear(AYear: Integer);
begin
  EditBox.Year := AYear;
end;

procedure TxCalendarCombo.SetDay(ADay: Integer);
begin
  EditBox.Day := ADay;
end;

procedure TxCalendarCombo.SetBorderStyle(Value: TBorderStyle);
begin
  CalendarWnd.Calendar.BorderStyle := Value;
end;

procedure TxCalendarCombo.SetAutoShowMonth(Value: Boolean);
begin
  CalendarWnd.Calendar.AutoShowMonth := Value;
end;

procedure TxCalendarCombo.SetOnDateChanging(Value: TNotifyEvent);
begin
  CalendarWnd.OnDateChanging := Value;
end;

procedure TxCalendarCombo.SetOnDateChanged(Value: TNotifyEvent);
begin
  CalendarWnd.OnDateChanged := Value;
end;

procedure TxCalendarCombo.SetOnPageChange(Value: TNotifyEvent);
begin
  CalendarWnd.OnPageChange := Value;
end;

procedure TxCalendarCombo.SetDisplayFormat(Value: TDisplayFormat);
begin
  EditBox.displayformat := Value;
end;

function TxCalendarCombo.GetDisplayFormat: TDisplayFormat;
begin
  Result := EditBox.displayformat;
end;

function TxCalendarCombo.GetEditBoxFont: TFont;
begin
  Result := EditBox.Font;
end;

procedure TxCalendarCombo.SetEditBoxFont(Value: TFont);
begin
  EditBox.Font := Value;
  EditBox.ParentFont := ParentFont;
  Height := EditBox.Height;
end;

procedure TxCalendarCombo.SetMonthRectColor(Value: TColor);
begin
  CalendarWnd.Calendar.MonthRectColor := Value;
end;

procedure TxCalendarCombo.SetArrowFocusedColor(Value: TColor);
begin
  CalendarWnd.Calendar.ArrowFocusedColor := Value;
end;

procedure TxCalendarCombo.SetArrowColor(Value: TColor);
begin
  CalendarWnd.Calendar.ArrowColor := Value;
end;

procedure TxCalendarCombo.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
end;

procedure TxCalendarCombo.KeyDown(var Key: Word; Shift: TShiftState);
var
  Used: Boolean;
begin
  if not(ShowCalendarWnd) then
    begin
      Used := True;
      case chr(Key) of
        '(': ShowCalendarWnd := True;
        else Used := False;
      end;
      if Used then
        begin
          Key := 0;
          exit;
        end;
    end;
  inherited keyDown(Key, Shift);
end;

procedure TxCalendarCombo.SetTabStop(Value: Boolean);
begin
  inherited TabStop := False;
  EditBox.TabStop := Value;
end;

function TxCalendarCombo.GetTabStop: Boolean;
begin
  Result := EditBox.TabStop;
end;

procedure TxCalendarCombo.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case chr(key) of
    '(':
      begin
        ShowCalendarWnd := True;
        Key := 0;
      end;
  end;
end;

procedure TxCalendarCombo.EditKeyPress(Sender: TObject; var Key: Char);
begin
  inherited KeyPress(Key);
end;

procedure TxCalendarCombo.EditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited KeyUp(Key, Shift);
end;

function TxCalendarCombo.GetHolidayColor: TColor;
begin
  Result := CalendarWnd.Calendar.HolidayColor;
end;

function TxCalendarCombo.GetDayType: TDayType;
begin
  Result := CalendarWnd.Calendar.TypeOfDay(Date);
end;

function TxCalendarCombo.GetDayTypeStr: String;
begin
  Result := CalendarWnd.Calendar.TypeOfDayStr(Date);
end;

function TxCalendarCombo.GetHolidaysDatabaseName: TFileName;
begin
  Result := CalendarWnd.Calendar.HolidaysDatabaseName;
end;

procedure TxCalendarCombo.SetHolidaysDatabaseName(Value: TFileName);
begin
  CalendarWnd.Calendar.HolidaysDatabaseName := Value;
end;

function TxCalendarCombo.GetHolidaysTableName: TFileName;
begin
  Result := CalendarWnd.Calendar.HolidaysTableName;
end;

procedure TxCalendarCombo.SetHolidaysTableName(Value: TFileName);
begin
  CalendarWnd.Calendar.HolidaysTableName := Value;
end;

procedure TxCalendarCombo.SetHolidayColor(Value: TColor);
begin
  CalendarWnd.Calendar.HolidayColor := Value;
end;

procedure TxCalendarCombo.DateChanged;
begin
  if Assigned(CalendarWnd.OnDateChanged) then
    CalendarWnd.OnDateChanged(Self);
end;

procedure TxCalendarCombo.DateChanging;
begin
  if Assigned(CalendarWnd.OnDateChanging) then
    CalendarWnd.OnDateChanging(Self);
end;

function TxCalendarCombo.GetDelay: Integer;
begin
  Result := CalendarWnd.Calendar.Delay;
end;

procedure TxCalendarCombo.SetDelay(Value: Integer);
begin
  CalendarWnd.Calendar.Delay := Value;
end;

function TxCalendarCombo.GetParentFont: Boolean;
begin
  Result := CalendarWnd.Calendar.ParentFont;
end;

procedure TxCalendarCombo.SetParentFont(Value: Boolean);
begin
  CalendarWnd.Calendar.ParentFont := Value;
  EditBox.ParentFont := Value;
end;

function TxCalendarCombo.GetCtl3D: Boolean;
begin
  Result := EditBox.Ctl3D;
end;

procedure TxCalendarCombo.SetCtl3D(Value: Boolean);
begin
  EditBox.Ctl3D := Value;
end;

function TxCalendarCombo.GetComboCtl3D: Boolean;
begin
  Result := CalendarWnd.Calendar.Ctl3D;
end;

procedure TxCalendarCombo.SetComboCtl3D(Value: Boolean);
begin
  CalendarWnd.Calendar.Ctl3D := Value;
end;

function TxCalendarCombo.GetMouseMove: TMouseMoveEvent;
begin
  Result := EditBox.OnMouseMove;
end;

procedure TxCalendarCombo.SetMouseMove(Value: TMouseMoveEvent);
begin
  EditBox.OnMouseMove := Value;
end;

function TxCalendarCombo.GetMinDate: String;
begin
  Result := CalendarWnd.Calendar.MinDate;
end;

procedure TxCalendarCombo.SetMinDate(Value: String);
begin
  CalendarWnd.Calendar.MinDate := Value;
  EditBox.MinDate := Value;
end;

function TxCalendarCombo.GetMaxDate: String;
begin
  Result := CalendarWnd.Calendar.MaxDate;
end;

procedure TxCalendarCombo.SetMaxDate(Value: String);
begin
  CalendarWnd.Calendar.MaxDate := Value;
  EditBox.MaxDate := Value;
end;

function TxCalendarCombo.GetStartOfWeek: TWeekDays;
begin
  Result := CalendarWnd.Calendar.StartOfWeek;
end;

procedure TxCalendarCombo.SetStartOfWeek(Value: TWeekDays);
begin
  CalendarWnd.Calendar.StartOfWeek := Value;
end;

procedure TxCalendarCombo.SetForceTodayOnStart(Value: Boolean);
begin
  FForceTodayOnStart := Value;
  FRememberDate := not Value;
end;

function TxCalendarCombo.GetCalendarDate: String;
begin
  Result := CalendarWnd.Calendar.CalendarDate;
end;

procedure TxCalendarCombo.SetCalendarDate(Value: String);
begin
  CalendarWnd.Calendar.CalendarDate := Value;
end;

procedure TxCalendarCombo.WMActivate(var Message: TMessage);
begin
  ShowCalendarWnd := False;
  inherited;
end;

function TxCalendarCombo.GetWidth: Integer;
begin
  Result := inherited Width;
  Dec(Result, 2);
end;

procedure TxCalendarCombo.SetWidth(Value: Integer);
begin
  inherited Width := Value + 2
end;

function TxCalendarCombo.GetHeight: Integer;
begin
  Result := inherited Height;
  Dec(Result, 2);
end;

procedure TxCalendarCombo.SetHeight(Value: Integer);
begin
  inherited Height := Value + 2
end;

function TxCalendarCombo.GetLeft: Integer;
begin
  Result := inherited Left;
  Inc(Result);
end;

procedure TxCalendarCombo.SetLeft(Value: Integer);
begin
  inherited Left := Value - 1;
end;

function TxCalendarCombo.GetTop: Integer;
begin
  Result := inherited Top;
  Inc(Result);
end;

procedure TxCalendarCombo.SetTop(Value: Integer);
begin
  inherited Top := Value - 1;
end;

function TxCalendarCombo.GetButtonBKColor: TColor;
begin
  Result := CalendarWnd.Calendar.ButtonBKColor;
end;

procedure TxCalendarCombo.SetButtonBKColor(Value: TColor);
begin
  CalendarWnd.Calendar.ButtonBKColor := Value;
end;

function TxCalendarCombo.GetText: string;
begin
  Result := EditBox.Text;
end;

procedure TxCalendarCombo.SetText(Value: string);
begin
  EditBox.Text := Value;
end;


{-------------------------- TxxDateEdit -----------------------}
function ReadLongDate(SDate: String): TDateTime;
var
  s: string;
  ADay, AYear, AMonth: Integer;
  i: Integer;
begin
  try
    s := Copy(SDate, 1, 2);
    ADay := StrToInt(s);
    AMonth := 0;
    s := Copy(SDate, 4, 3);
    for i:=1 to 12 do
      if (s = Phrases[ lnShortMonthNames[i] ]) or
         (s = Phrases.GetPhrase(lnShortMonthNames[i], lEnglish ) )
         then AMonth := i;
    s := Copy(SDate, 8, length(SDate)-7);
    AYear := StrToInt(s);
    if AYear<100 then Inc(AYear, 1900);
    Result := Encodedate(Ayear, AMonth, ADay);
  except
    raise EconvertError.Create('Invalid date.');
  end;
end;

function TranslateLongDate(SDate: String): String;
var
  s: string;
  AMonth: Integer;
  i: Integer;
begin
  AMonth := 0;
  s := Copy(SDate, 4, 3);
  for i := 1 to 12 do
    if UpperCase(s) =
       UpperCase( Phrases.GetPhrase( lnShortMonthNames[i], lEnglish) )
       then AMonth := i;
  if AMonth > 0 then
    Result := Copy(SDate, 1, 3) + Phrases[ lnShortMonthNames[AMonth] ] +
              Copy(SDate, 7, 5)
  else Result := SDate;
end;

constructor TxxDateEdit.Create(AOwner: TComponent);
var
  s: string;
begin
  inherited Create(AOwner);

  GettingCreated := true;

  FForceTodayOnStart := DefForceToday;
  FRememberDate := not DefForceToday;

  DateWasChanged := False;

  FMinDate := 0;
  FMaxDate := 0;

  InCombo := False;

  FDisplayFormat := dfShortDate;

  EditMask := ShortDateFormat;
  case FDisplayFormat of
    dfShortDate: DateTimeToString(s, 'dd.mm.yyyy', SysUtils.Date);
    dfLongDate:
      begin
        DateTimeToString(s, 'dd-mmm-yyyy', SysUtils.Date);
        s := TranslateLongDate(s);
      end;
  end;
  EditText := s;

  Font.Name := DefFontName;
  Font.Style := DefFontStyle;
  Font.Size := DefFontSize;

  ParentFont := DefParentFont;

  GettingCreated := false;
end;

function TxxDateEdit.CheckDateLimits: Boolean;
begin
  Result := False;
  if (Date < FMinDate) then
    begin
      MessageDlg(Phrases[ lnDateAfter ] + MinDate, mtError, [mbOk], 0);
      exit;
    end;
  if ( FMaxDate <> 0 ) and ( Date > FMaxDate ) then
    begin
      MessageDlg(Phrases[ lnDateBefore ] + MaxDate, mtError, [mbOk], 0);
      exit;
    end;
  Result := True;
end;

procedure TxxDateEdit.KeyPress(var Key: Char);
var
  s: string;
  x: Integer;
  OldStart: Integer;
begin
  if not(Key in [#0, #13, ' '])  then
    inherited KeyPress(Key)
  else
    if Assigned(FOnKeyPress) then
      FOnKeyPress(self, Key);

  case Key of
    #13:
      begin
        if DateWasChanged and CheckDateLimits then DateChange;
      end;
    ' ':
      begin
        if CompareText(Copy(SysUtils.ShortDateFormat, 1, 1), 'd') <> 0 then
          begin
            { this not a good way but it works }
            DateTimeToString(S, SysUtils.ShortDateFormat, SysUtils.Date);
            Text := S;
            SelStart := 0;
            SelLength := Length(Text);
          end
        else
          begin
            x := SelStart;
            if (FDisplayFormat = dfLongDate) and (x > 4) then Dec(x);
            case x of
              0..1:
                begin
                  DateTimeToString(s, 'dd', SysUtils.Date);
                  Text := s;
                  SelLength := 1;
                  SelStart := 3;
                end;
              2..4:
                begin
                  case FDisplayFormat of
                    dfShortDate: DateTimeToString(s, 'mm', SysUtils.Date);
                    dfLongDate: DateTimeToString(s, 'mmm', SysUtils.Date);
                  end;
                  Text := Copy(Text, 1, 3) + s;
                  Text := TranslateLongDate(Text);
                  SelLength := 1;
                  SelStart := 4 + Length(s);
                end;
              5..9:
                begin
                  DateTimeToString(s, 'yyyy', SysUtils.Date);
                  case FDisplayFormat of
                    dfShortDate:
                      begin
                        Text := Copy(Text, 1, 6) + s;
                        SelLength := 0;
                        SelStart := 10;
                      end;
                    dfLongDate:
                      begin
                        Text := Copy(Text, 1, 7) + s;
                        SelLength := 0;
                        SelStart := 11;
                      end;
                  end;
                end;
            end{ of case};
          end;
{        Change; { report date changing }
      end;
  end;

  if ((SelStart < 3) or (SelStart > 5)) and
     (FDisplayFormat = dfLongDate)
     then
       begin
         OldStart := SelStart;
         Text := TranslateLongDate(Text);
         SelStart := OldStart;
       end;

  Key := #0;
end;

procedure TxxDateEdit.SetOnKeyPress(Value: TKeyPressEvent);
begin
  inherited OnKeyPress := Value;
  FOnKeyPress := inherited OnKeyPress;
end;

function TxxDateEdit.GetDateIsValid: Boolean;
begin
  try
    if (Text = '  .  .    ') or (Text = '  -   -    ') then
      Result := true
    else
      begin
        Date;
        Result := true;
      end;
  except
    Result := false;
  end;
end;

function TxxDateEdit.GetDate;
begin
  Result := 0;
  
  if (Text = '  .  .    ') or (Text = '  -   -    ') then
    Result := 0
  else
    case FDisplayFormat of
        dfShortDate: Result := StrToDate(Trim(Text));
      dfLongDate: Result := ReadLongDate(Trim(Text));
    end;
end;

procedure TxxDateEdit.SetDate(Value: TDateTime);
var
  s: String;
begin
  if Value = 0 then
    case DisplayFormat of
      dfShortDate: s := '  .  .    ';
      dfLongDate: s := '  -   -    ';
    end
  else
    case DisplayFormat of
      dfShortDate: DateTimeToString(s, 'dd.mm.yyyy', Value);
      dfLongDate:
        begin
          DateTimeToString(s, 'dd-mmm-yyyy', Value);
          s := TranslateLongDate(s);
        end;
    end;
  Text := s;
  DateWasChanged := False;
end;

function TxxDateEdit.GetMinDate: String;
begin
  if FMinDate = 0 then
    Result := ''
  else
    DateTimeToString(Result, 'ddddd', FMinDate);
end;

procedure TxxDateEdit.SetMinDate(Value: String);
begin
  if Value<>'' then
    FMinDate := StrToDate(Value)
  else
    FMinDate := 0;
end;

function TxxDateEdit.GetMaxDate: String;
begin
  if FMaxDate = 0 then
    Result := ''
  else
    DateTimeToString(Result, 'ddddd', FMaxDate);
end;

procedure TxxDateEdit.SetMaxDate(Value: String);
begin
  if Value<>'' then
    FMaxDate := StrToDate(Value)
  else
    FMaxDate := 0;
end;

procedure TxxDateEdit.DoExit;
var
  Ok: Boolean;
begin
  Ok := False;
  try
    if not InCombo then
      Date;
    Ok := True;
  except
    on EConvertError do ;
  end;
{$B-}
  if Ok then
    begin
      if InCombo or CheckDateLimits then
        begin
          if DateWasChanged and not InCombo then DateChange;
          inherited DoExit
        end
      else
        SetFocus;
    end
  else
    begin
      MessageDlg(Text + Phrases[ lnNotValidDate ], mtError, [mbOk], 0);
      SetFocus;
    end;
end;

procedure TxxDateEdit.SetDisplayFormat(Value: TDisplayFormat);
var
  d: TDateTime;
  f: Boolean;
begin
  f := False;
  d := Now;

  if FDisplayFormat <> Value then
    begin
      try
        f := False;
        d := Date;
        f := True;
      except
        on EConvertError do;
      end;

      FDisplayFormat := Value;

      case Value of
        dfShortdate: EditMask := ShortDateFormat;
        dfLongdate: EditMask := LongDateFormat;
      end;

      if f then Date := d
      else
        begin
          case FDisplayFormat of
            dfShortDate: EditText := '__.__.____';
            dfLongDate: EditText := '__-___-____';
          end;
        end;
    end;
end;

procedure TxxDateEdit.Change;
begin
  inherited Change;
  if not(csDesigning in ComponentState) and not(GettingCreated) then
    try
      Date; {check for correct date}
      DateChanging;
    except
      on EConvertError do ;
    end;
end;

procedure TxxDateEdit.DateChange;
begin
  DateWasChanged := False;
  if Assigned(FOnDateChange) then
    FOnDateChange(Self);
end;

procedure TxxDateEdit.DateChanging;
begin
  DateWasChanged := True;
  if Assigned(FOnDateChanging) then
    FOnDateChanging(Self);
end;

procedure TxxDateEdit.SetText(s: String);
begin
  inherited Text := s;
  if FDisplayFormat = dfLongDate then
    inherited Text := TranslateLongDate(inherited Text);
end;

function TxxDateEdit.GetYear: Integer;
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(Date, AYear, AMonth, ADay);
  Result := AYear;
end;

function TxxDateEdit.GetMonth: Integer;
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(Date, AYear, AMonth, ADay);
  Result := AMonth;
end;

function TxxDateEdit.GetDay: Integer;
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(Date, AYear, AMonth, ADay);
  Result := ADay;
end;

procedure TxxDateEdit.SetYear(Value: Integer);
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(Date, AYear, AMonth, ADay);
  AYear := Value;
  Date := EncodeDate(AYear, AMonth, ADay);
end;

procedure TxxDateEdit.SetMonth(Value: Integer);
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(Date, AYear, AMonth, ADay);
  AMonth := Value;
  try
    Date := EncodeDate(AYear, AMonth, ADay);
  except
    on Exception do Date := Now;
  end;
end;

procedure TxxDateEdit.SetDay(Value: Integer);
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(Date, AYear, AMonth, ADay);
  ADay := Value;
  Date := EncodeDate(AYear, AMonth, ADay);
end;

procedure TxxDateEdit.SetForceTodayOnStart(Value: Boolean);
begin
  FForceTodayOnStart := Value;
  FRememberDate := not Value;
end;



{ TxDBCalendar ---------------------------------------}

constructor TxDBCalendar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  ForcingEdit := False;
end;

destructor TxDBCalendar.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  inherited Destroy;
end;

procedure TxDBCalendar.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TxDBCalendar.DataChange(Sender: TObject);
begin
  if (not ForcingEdit) and (FDataLink.Field <> nil)
    {and (FDataLink.Field is TDateField)} then
  begin
    if FDataLink.Field.IsNull then
      Date := 0
    else
      Date := FDataLink.Field.AsDateTime;
  end;
end;

procedure TxDBCalendar.UpdateData(Sender: TObject);
begin
{  if FDataLink.Field is TDateField then }
  begin
    if Date = 0 then
      FDataLink.Field.Clear
    else
      FDataLink.Field.AsDateTime := Date;
  end;
end;

procedure TxDBCalendar.EditingChange(Sender: TObject);
begin
end;

procedure TxDBCalendar.Click;
begin
  ForcingEdit := True;
  FDataLink.Edit;
  ForcingEdit := False;
  inherited Click;
  FDataLink.Modified;
end;

function TxDBCalendar.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TxDBCalendar.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TxDBCalendar.GetDataField: String;
begin
  Result := FDataLink.FieldName;
end;

procedure TxDBCalendar.SetDataField(const Value: String);
begin
  FDataLink.FieldName := Value;
end;

function TxDBCalendar.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TxDBCalendar.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;
  inherited;
end;

{ TxDBCalendarCombo ---------------------------------------}

constructor TxDBCalendarCombo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  ForcingEdit := False;
  ReadingData := False;
end;

destructor TxDBCalendarCombo.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  inherited Destroy;
end;

procedure TxDBCalendarCombo.Loaded;
begin
  inherited Loaded;

  OldOnDateChanged := OnDateChanged;
  OnDateChanged := DoOnDateChanged;
end;

procedure TxDBCalendarCombo.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TxDBCalendarCombo.DataChange(Sender: TObject);
begin
  if not ForcingEdit then
    if FDataLink.Field <> nil then
{      if FDataLink.Field is TDateField then }
        begin
          ReadingData := True;
          try
            Date := FDataLink.Field.AsDateTime;
          finally
            ReadingData := False;
          end;
        end;
end;

procedure TxDBCalendarCombo.UpdateData(Sender: TObject);
begin
{  if FDataLink.Field is TDateField then }
    begin
      if Date = 0 then
        FDataLink.Field.Clear
      else
        FDataLink.Field.AsDateTime := Date;
    end;
end;

procedure TxDBCalendarCombo.EditingChange(Sender: TObject);
begin
  if {(FDataLink.Field is TDateField) and }(DataSource.State in [dsEdit]) then
  begin
    if Date = 0 then
      FDataLink.Field.Clear
    else
      FDataLink.Field.AsDateTime := Date;
  end;

  if {(FDataLink.Field is TDateField) and }(DataSource.State in [dsInsert]) then
    FDataLink.Field.Clear;
end;

procedure TxDBCalendarCombo.EditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited EditKeyDown(Sender, Key, Shift);
end;

procedure TxDBCalendarCombo.EditKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    ' '..#255:
      if not ForcingEdit then
       begin
         ForcingEdit := True;
         try
           FDataLink.Edit;
         finally
           ForcingEdit := False;
         end;
         FDataLink.Modified;
       end;
  end;
  inherited EditKeyPress(Sender, Key);
end;

procedure TxDBCalendarCombo.DateChanged;
begin
  if not ReadingData then
    begin
      ForcingEdit := True;
      try
        FDataLink.Edit;
      finally
        ForcingEdit := False;
      end;
      inherited DateChanged;
      FDataLink.Modified;
      FDataLink.UpdateRecord;
    end;
end;

procedure TxDBCalendarCombo.DateChanging;
begin
  if not ReadingData then
    begin
      ForcingEdit := True;
      try
        FDataLink.Edit;
      finally
        ForcingEdit := False;
      end;
      inherited DateChanging;
      FDataLink.Modified;
    end;
end;

function TxDBCalendarCombo.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TxDBCalendarCombo.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TxDBCalendarCombo.GetDataField: String;
begin
  Result := FDataLink.FieldName;
end;

procedure TxDBCalendarCombo.SetDataField(const Value: String);
begin
  FDataLink.FieldName := Value;
end;

function TxDBCalendarCombo.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TxDBCalendarCombo.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;
  inherited;
end;

procedure TxDBCalendarCombo.DoOnDateChanged(Sender: TObject);
begin
  if not ForcingEdit then
  begin
    ForcingEdit := True;
    try
      FDataLink.Edit;
    finally
      ForcingEdit := False;
    end;
    FDataLink.Modified;
  end;

  if Assigned(OldOnDateChanged) then
    OldOnDateChanged(Sender);
end;

{ ------------------------- TxDBDateEdit ---------------------}

constructor TxDBDateEdit.Create(AOwner: TComponent);
begin
  SkipChange := 1;
  inherited Create(AOwner);
  inherited ReadOnly := false;
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  SkipChange := 0;
end;

destructor TxDBDateEdit.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;
  inherited Destroy;
end;

procedure TxDBDateEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TxDBDateEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
    FDataLink.Edit;
end;

procedure TxDBDateEdit.KeyPress(var Key: Char);
begin
  case Key of
    ^H, ^V, ^X, #32..#255:
       FDataLink.Edit;
    #27:
      begin
        FDataLink.Reset;
        SelectAll;
        Key := #0;
      end;
  end;
  inherited KeyPress(Key);
end;

function TxDBDateEdit.EditCanModify: Boolean;
begin
  Result := FDataLink.Edit;
end;

procedure TxDBDateEdit.Reset;
begin
  FDataLink.Reset;
  SelectAll;
end;

procedure TxDBDateEdit.DateChange;
begin
  if SkipChange = 0 then
    begin
      FDataLink.Modified;
      FDataLink.UpdateRecord;
    end;
  inherited DateChange;
end;

procedure TxDBDateEdit.DateChanging;
begin
  if SkipChange = 0 then
    FDataLink.Modified;
  inherited DateChanging;
end;

function TxDBDateEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TxDBDateEdit.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

function TxDBDateEdit.GetDataField: String;
begin
  Result := FDataLink.FieldName;
end;

procedure TxDBDateEdit.SetDataField(const Value: String);
begin
  FDataLink.FieldName := Value;
end;

function TxDBDateEdit.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TxDBDateEdit.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

function TxDBDateEdit.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TxDBDateEdit.DataChange(Sender: TObject);
begin
  if FDataLink <> nil then
   if FDataLink.Field <> nil then
{    if FDataLink.Field is TDateField then }
      begin
        Inc(SkipChange);
        date := FDataLink.Field.AsDateTime;
        Dec(SkipChange);
      end;
end;

procedure TxDBDateEdit.EditingChange(Sender: TObject);
begin
  if {(FDataLink.Field is TDateField) and} (DataSource.State in [dsEdit]) then
  begin
    if Date = 0 then
      FDataLink.Field.Clear
    else
      FDataLink.Field.AsDateTime := Date;
  end;

  if {(FDataLink.Field is TDateField) and }(DataSource.State in [dsInsert]) then
    FDataLink.Field.Clear;
{  inherited ReadOnly := not FDataLink.Editing;}
end;

procedure TxDBDateEdit.UpdateData(Sender: TObject);
begin
  ValidateEdit;
  if Date = 0 then
    FDataLink.Field.Clear
  else
    FDataLink.Field.AsDateTime := Date;
end;

procedure TxDBDateEdit.WMPaste(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TxDBDateEdit.WMCut(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TxDBDateEdit.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    SelectAll;
    SetFocus;
    raise;
  end;
  SetCursor(0);
  DoExit;
end;

{ property editors ---------------------------------------}

{ TDBStringProperty }

type
  TDBStringProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual; abstract;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

function TDBStringProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

procedure TDBStringProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

{ TDatabaseNameProperty }

type
  TDatabaseNameProperty = class(TDBStringProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

procedure TDatabaseNameProperty.GetValueList(List: TStrings);
begin
  Session.GetDatabaseNames(List);
end;

{ TTableNameProperty }

type
  TTableNameProperty = class(TDBStringProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

procedure TTableNameProperty.GetValueList(List: TStrings);
const
  Masks: array[TTableType] of string[5] = ('', '*.DB', '*.DBF', '*.TXT', '');
  Which = ttDefault;
var
  Comp: TPersistent;//TComponent;
begin
  Comp := GetComponent(0);
  if Comp is TxCalendar then
    Session.GetTableNames((Comp as TxCalendar).HolidaysDatabaseName,
      Masks[Which], Which = ttDefault, False, List)
  else if Comp is TxCalendarCombo then
    Session.GetTableNames((Comp as TxCalendarCombo).HolidaysDatabaseName,
      Masks[Which], Which = ttDefault, False, List)
  else
    raise ECalendar.Create('xCalend.pas source code error. ' +
                           'Unknown component called TTableNameProperty.');
end;


{Registration --------------------------------------------}

procedure Register;
begin
  RegisterComponents('xStorm', [TxCalendar, TxCalendarCombo,
    TxDBCalendar, TxDBCalendarCombo, TxxDateEdit, TxDBDateEdit]);

  RegisterPropertyEditor(TypeInfo(TFileName), TxCalendar,
    'HolidaysDatabaseName', TDatabaseNameProperty);
  RegisterPropertyEditor(TypeInfo(TFileName), TxCalendarCombo,
    'HolidaysDatabaseName', TDatabaseNameProperty);
  RegisterPropertyEditor(TypeInfo(TFileName), TxCalendar,
    'HolidaysTableName', TTableNameProperty);
  RegisterPropertyEditor(TypeInfo(TFileName), TxCalendarCombo,
    'HolidaysTableName', TTableNameProperty);
end;

{ TODO : 1. передавать сообщение мыши из комбо }
{ TODO : 2. review pressing of '.' in DateEdit. }

end.


