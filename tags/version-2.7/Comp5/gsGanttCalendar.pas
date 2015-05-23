
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    gsGanttCalendar.pas

  Abstract

    A visual component. Calendar with marked periods of time.

  Author

    Romanovski Denis (04-Nov-1999)

  Contact address

    dionik@usa.net
    goldensoftware@usa.net

  Revisions history

    1.00   04-Nov-1999    dennis          Initial version.
    2.00   07-dec-1999    dennis          Beta1. Tree added and connected to gantt.

--}

unit gsGanttCalendar;

interface

uses
  Windows,            Messages,           SysUtils,           Classes,
  Graphics,           Controls,           Forms,              Dialogs,
  ExtCtrls,           StdCtrls,           ExList,             Grids,
  xSpin,              ComCtrls,           CommCtrl,           Buttons;


/////////////////////////////////////////////
// Курсоры, необходимые для работы компоненты

const
  crGanttMiddle = 16345; // Курсор для переноса всего периода
  crGanttRightMove = 16346; // Курсор для продления периода вправо
  crGanttLeftMove = 16347; // Курсор для продления периода влево
  crGanttPercent = 16348; // Курсор для установления процента выполнения
  crGanttConnect = 16349; // Курсор для установления процента выполнения

/////////////////////////////
//  Установки для скроллбаров

const
  SCROLL_MAX = 100;
  SCROLL_MINSTEP = 1;
  SCROLL_MAXSTEP = 10;

type
  TgsGanttLanguage = (glRussian, glEnglish);


/////////////////////////////////
//  Временные интервалы просмотра
//  tsHour - час
//  tsDay - день
//  tsWeek - неделя
//  tsMonth - месяц
//  tsQuarter - квартал
//  tsHalfYear - полугодие
//  tsYear - год

type
  TTimeScale = (tsMinute, tsHour, tsDay, tsWeek, tsMonth, tsQuarter, tsHalfYear, tsYear);


////////////////////////////////////////////////////////////////////////////////////////
//  itPeriod - означает, что за промежуток времени что-либо должно произойти
//  itAction - означает, что действие должно быть совершено именно в этот момент времени

type
  TIntervalType = (itPeriod, itAction);


///////////////////////////
// Предыдущая шкала времени

const
  PrevScale: array[TTimeScale] of TTimeScale =
    (tsMinute, tsMinute, tsHour, tsDay, tsDay, tsMonth, tsMonth, tsMonth);


///////////////////
// Названия месяцев

const
  MonthNames: array[TgsGanttLanguage, 0..11] of String =
    (
      (
        'янв.', 'фев.', 'мар.',
        'апр.', 'май.', 'июн.',
        'июл.', 'авг.', 'сен.',
        'окт.', 'ноя.', 'дек.'
      ),
      (
        'jan', 'feb', 'mar',
        'apr', 'may', 'jun',
        'jul', 'aug', 'sep',
        'oct', 'nov', 'dec'
      )
    );


///////////////////////
// Названия дней недели

const
  WeekDays: array[TgsGanttLanguage, 0..6] of String =
    (
      ('вос.', 'пон.', 'вто.', 'сре.', 'чет.', 'пят.', 'суб.'),
      ('sun', 'mon', 'tus', 'wed', 'thu', 'fri', 'sat')
    );


/////////////////////////////////////////////
// Виды перемещений интервалов с помощью мыши

type
  TDragIntervalType = (ditMiddle, ditRightMove, ditLeftMove, ditPercent, ditConnect, ditNone);

// Вид колонки
type
  TGanttColumnType =
  (
    gctInfo, gctTask, gctDuration, gctStart,
    gctFinish, gctConnection, gctResources, gctNone
  );

type
  TgsMonthCalendar = class(TMonthCalendar)
  private
    FOnSelectDate: TNotifyEvent; // Выбор даты

    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;

  public
    constructor Create(AnOwner: TComponent); override;

  published
    property OnSelectDate: TNotifyEvent read FOnSelectDate write FOnSelectDate;

  end;

type
  TGanttCalendar = class;
  TGanttTree = class;
  TgsGantt = class;

  TInterval = class
  private
    FGantt: TgsGantt; // Класс календаря

    FStartDate: TDateTime; // Начало периода
    FFinishDate: TDateTime; // Начало периода
    FTask: String; // Название
    FParent: TInterval; // Интервал, частью которого является данный

    FDrawRect: TRect; // Координаты для рисования
    FVisible: Boolean; // Выводить на экране или нет
    FIntervalDone: TDateTime; // выполнения плана (дата, до которой дошли)

    FIntervals: TExList; // Список интервалов, из которых состоит данный

    FConnections: TList; // Список связей
    FCanUpdate: Boolean; // Можно ли изменять

    // property procedures and functions
    function GetStartDate: TDateTime;
    function GetFinishDate: TDateTime;

    procedure SetStartDate(const Value: TDateTime);
    procedure SetFinishDate(const Value: TDateTime);

    function GetDuration: TDateTime;
    procedure SetDuration(const Value: TDateTime);

    function GetStampDuration: TTimeStamp;

    procedure SetTask(const Value: String);

    function GetIntervalType: TIntervalType;
    function GetLevel: Integer;

    function GetIntervalCount: Integer;
    function GetInterval(AnIndex: Integer): TInterval;

    function GetConnectionCount: Integer;
    function GetConnection(AnIndex: Integer): TInterval;

    function GetIsCollection: Boolean;

    function GetIntervalDone: TDateTime;
    procedure SetIntervalDone(const Value: TDateTime);

    function GetIsDrawRectClear: Boolean;

    function GetDoneRect: TRect;
    function GetPercentMoveRect: TRect;

    function GetLeftMoveRect: TRect;
    function GetRightMoveRect: TRect;

    function GetVisible: Boolean;
    procedure SetVisible(const Value: Boolean);

    function GetOpened: Boolean;
    procedure SetOpened(const Value: Boolean);

    // other usefull procedures and functions
    function CountStartDate: TDateTime;
    function CountFinishDate: TDateTime;

  protected
    procedure PrepareDrawRect;

    // Чисты ли границы для рисования
    property IsDrawRectClear: Boolean read GetIsDrawRectClear;

  public
    constructor Create(AGantt: TgsGantt);
    destructor Destroy; override;

    procedure AddConnection(AConnection: TInterval);
    procedure DeleteConnection(AnIndex: Integer);
    procedure RemoveConnection(AConnection: TInterval);

    procedure AddInterval(AnInterval: TInterval);
    procedure InsertInterval(AnIndex: Integer; AnInterval: TInterval);
    procedure DeleteInterval(AnIndex: Integer);
    procedure RemoveInterval(AnInterval: TInterval);

    procedure ClearDrawRect;
    procedure MakeIntervalList(AList: TList);

    function ConnectionExists(AConnection: TInterval): Boolean;
    function IntervalExists(AnInterval: TInterval): Boolean;

    procedure UpdateIntervalStart(Delta: TDateTime);
    procedure PrepareToUpdate;

    // Начало периода
    property StartDate: TDateTime read GetStartDate write SetStartDate;
    // Начало периода
    property FinishDate: TDateTime read GetFinishDate write SetFinishDate;
    // Продолжительность
    property Duration: TDateTime read GetDuration write SetDuration;
    // Продолжительность в виде записи дней и милисекунд
    property StampDuration: TTimeStamp read GetStampDuration;
    // Задание
    property Task: String read FTask write SetTask;
    // период, частью которого является данный
    property Parent: TInterval read FParent write FParent;

    // Вид интервала
    property IntervalType: TIntervalType read GetIntervalType;
    // Уровень вложенности периода
    property Level: Integer read GetLevel;

    // Координаты для рисования
    property DrawRect: TRect read FDrawRect write FDrawRect;
    // Возвращает область выполненного процента
    property DoneRect: TRect read GetDoneRect;
    // Возвращает область для передвижения выполненного процента
    property PercentMoveRect: TRect read GetPercentMoveRect;
    // Область для сдвига рисунка влево
    property LeftMoveRect: TRect read GetLeftMoveRect;
    // Область для сдвига рисунка вправо
    property RightMoveRect: TRect read GetRightMoveRect;

    // Левая граница
    property Left: Integer read FDrawRect.Left write FDrawRect.Left;
    // Правая граница
    property Right: Integer read FDrawRect.Right write FDrawRect.Right;
    // Верхняя граница
    property Top: Integer read FDrawRect.Top write FDrawRect.Top;
    // Нижняя граница
    property Bottom: Integer read FDrawRect.Bottom write FDrawRect.Bottom;

    // Выводить на экране или нет
    property Visible: Boolean read GetVisible write SetVisible;
    // Открыт промежуток или нет
    property Opened: Boolean read GetOpened write SetOpened;
    // Кол-во интервалов в данном
    property IntervalCount: Integer read GetIntervalCount;
    // Интервал по иендексу
    property Interval[Index: Integer]: TInterval read GetInterval;
    // Кол-во связей
    property ConnectionCount: Integer read GetConnectionCount;
    // Связь по индексу
    property Connection[Index: Integer]: TInterval read GetConnection;

    // Является интервалом или же набором последних
    property IsCollection: Boolean read GetIsCollection;
    // Дата на которую задание выполнено
    property IntervalDone: TDateTime read GetIntervalDone write SetIntervalDone;

  end;

  TGanttCalendar = class(TCustomControl)
  private
    FVertScrollBar: TScrollBar; // Вертикальный скролл бар
    FHorzScrollBar: TScrollBar; // Горизонтальный скролл бар

    FMajorScale: TTimeScale; // Временной интервал просмотра - верхний
    FMinorScale: TTimeScale; // Временной интервал просмотра - нижнй
    FPixelsPerMinorScale: Integer; // Количество точек на единицу отображаемого времени
    FPixelsPerLine: Integer; // Кол-во точек на одну горизонтальную линию

    FStartDate: TDateTime; // Дата начала просмотра
    FVisibleStart: TDateTime; // Начало видимой части

    FCurrentDate: TDateTime; // Текущая дата

    FMajorColor: TColor; // Цвет верхней шкалы
    FMinorColor: TColor; // Цвет нижней шкалы

    FIntervals: TExList; // Список главных интервалов
    FGantt: TgsGantt; // Главный класс

    FBeforeStartDateCount: Integer; // Пропущено с лева от начала периода при скроллировании

    FDragRect: TRect; // Область передвижения интервала
    FDragType: TDragIntervalType; // Вид перемещения интервала
    FDragInterval: TInterval; // Интервал, который перемещаем
    FConnectInterval: TInterval; // Интервал, соединяемый с данным
    FDragStarted: Boolean; // Начато ли изменение периода
    FFromDragPoint: Integer; // Точка от начала периода до курсора
    FConnectFromPoint: TPoint; // При связи откуда начинаем
    FConnectToPoint: TPoint; // При связи, где заканчиваем

    // Property Procedures and functions
    procedure SetMajorScale(const Value: TTimeScale);
    procedure SetMinorScale(const Value: TTimeScale);

    procedure SetPixelsPerMinorScale(const Value: Integer);

    procedure SetPixelsPerLine(const Value: Integer);

    procedure SetStartDate(const Value: TDateTime);

    function GetVisibleFinish: TDateTime;
    function GetMinorVisibleUnitsCount: Integer;

    function GetMajorScale: Integer;
    function GetMinorScale: Integer;

    function GetSeconds: Integer;
    function GetMinutes: Integer;
    function GetHours: Integer;
    function GetDays: Integer;
    function GetDayOfWeek: Integer;
    function GetWeeks: Integer;
    function GetMonthes: Integer;
    function GetQuarters: Integer;
    function GetHalfYears: Integer;
    function GetYears: Integer;
    function GetTimeUnitByScale(ATimeScale: TTimeScale): Integer;

    procedure SetMajorColor(const Value: TColor);
    procedure SetMinorColor(const Value: TColor);

    function GetIntervalCount: Integer;
    function GetInterval(AnIndex: Integer): TInterval;

    function GetStartDrawIntervals: Integer;
    function GetIntervalHeight: Integer;

    // Other usefull methods
    procedure DrawHeaderLines;
    procedure ConnectIntervals(FromInterval, ToInterval: TInterval);

    procedure DrawMinorScale;
    procedure DrawMajorScale;

    function IsNewPeriod(AScale: TTimeScale; AUseSub: Boolean = False): Boolean;

    procedure UpdateScrollbars;
    procedure DoOnHorzScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);

    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure CMMouseEnter(var Message: TMessage);
      message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMRButtonDown);
      message WM_LBUTTONUP;

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TgsGantt); reintroduce;
    destructor Destroy; override;

    procedure AddInterval(AnInterval: TInterval);
    procedure InsertInterval(AnIndex: Integer; AnInterval: TInterval);
    procedure DeleteInterval(AnIndex: Integer);
    procedure RemoveInterval(AnInterval: TInterval);

    // Кол-во секунд
    property Seconds: Integer read GetSeconds;
    // Кол-во мниут
    property Minutes: Integer read GetMinutes;
    // Кол-во часов
    property Hours: Integer read GetHours;
    // Кол-во дней
    property Days: Integer read GetDays;
    // Возвращает день недели
    property DayOfWeek: Integer read GetDayOfWeek;
    // Кол-во недель
    property Weeks: Integer read GetWeeks;
    // Кол-во месяцев
    property Monthes: Integer read GetMonthes;
    // Кол-во кварталов
    property Quarters: Integer read GetQuarters;
    // Кол-во полугодий
    property HalfYears: Integer read GetHalfYears;
    // Кол-во лет
    property Years: Integer read GetYears;
    // Возвращает время по указанной временной единице
    property TimeUnitByScale[ATimeScale: TTimeScale]: Integer read GetTimeUnitByScale;

    // Начальная координата по оси Y для рисования интервалов
    property StartDrawIntervals: Integer read GetStartDrawIntervals;
    // Возвращает высоту одного интервала
    property IntervalHeight: Integer read GetIntervalHeight;

    // Кол-во видимых элементов
    property MinorVisibleUnits: Integer read GetMinorVisibleUnitsCount;
    // Высота предыдущего элемента
    property MajorScaleHeight: Integer read GetMajorScale;
    // Высота данного элемента
    property MinorScaleHeight: Integer read GetMinorScale;
    // Начало видимой части
    property VisibleStart: TDateTime read FVisibleStart;
    // Окончание видимой части
    property VisibleFinish: TDateTime read GetVisibleFinish;
    // Кол-во интервалов
    property IntervalCount: Integer read GetIntervalCount;
    // Интервал по индексу
    property Interval[Index: Integer]: TInterval read GetInterval;

  published
    // Шрифт всего текста
    property Font;
    // Цвет фона
    property Color;
    // Выранивание
    property Align;
    // Цвет верхней шкалы
    property MajorColor: TColor read FMajorColor write SetMajorColor;
    // Цвет нижней шкалы
    property MinorColor: TColor read FMinorColor write SetMinorColor;

    // Временной интервал просмотра
    property MajorScale: TTimeScale read FMajorScale write SetMajorScale default tsWeek;
    // Временной интервал просмотра
    property MinorScale: TTimeScale read FMinorScale write SetMinorScale default tsDay;
    // Количество точек на единицу отображаемого времени нижней шкалы
    property PixelsPerMinorScale: Integer read FPixelsPerMinorScale write SetPixelsPerMinorScale default 30;
    // Кол-во точек на одну горизонтальную линию
    property PixelsPerLine: Integer read FPixelsPerLine write SetPixelsPerLine default 24;

    // Начальная дата просмотра
    property StartDate: TDateTime read FStartDate write SetStartDate;

  end;

  TGanttTree = class(TStringGrid)
  private
    FIntervals: TExList; // Список интервалов
    FGantt: TgsGantt; // Главный класс
    FIndent: Integer; // Расстояние между ветвями
    FBranchFont: TFont; // Шрифт ветви

    FTextEdit: TEdit;
    FDurationEdit: TxSpinEdit;
    FDateEdit: TDateTimePicker;
    FComboEdit: TComboBox;
    FUpDown: TUpDown;
    FMonthCalendar: TgsMonthCalendar;
    FDownButton: TSpeedButton;
    FEditInterval: TInterval; // Редатируемый интервал

    // property procedures and functions
    function GetColumnType(AnIndex: Integer): TGanttColumnType;
    procedure SetIndent(const Value: Integer);

    procedure DrawMinus(X, Y: Integer);
    procedure DrawPlus(X, Y: Integer);

    function GetBrachFont: TFont;
    procedure SetBranchFont(const Value: TFont);

    // other usefull procedures and functions
    procedure OnEditKeyPress(Sender: TObject; var Key: Char);
    procedure OnEditExit(Sender: TObject);
    procedure OnDownButtonClick(Sender: TObject);
    procedure OnMonthCalendarClick(Sender: TObject);
    procedure OnUpDownButtonClick(Sender: TObject; Button: TUDBtnType);

    procedure UpdateCurrentControl(ACol, ARow: Integer);
    procedure ShowTaskEditor;

    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;

  protected
    procedure CreateWnd; override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    procedure MouseDown(Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    function SelectCell(ACol, ARow: Longint): Boolean; override;
    procedure TopLeftChanged; override;
    procedure ColWidthsChanged; override;
    procedure DoExit; override;

    procedure UpdateCommonSettings;
    procedure UpdateTreeList;

  public
    constructor Create(AnOwner: TgsGantt); reintroduce;
    destructor Destroy; override;

  published
    // Расстояние между ветвями
    property Indent: Integer read FIndent write SetIndent;
    // Шрифт обычного текста
    property Font;
    // Шрифт ветви
    property BranchFont: TFont read GetBrachFont write SetBranchFont;

  end;

  TgsGantt = class(TCustomControl)
  private
    FIntervals: TExList; // Список интервалов
    FLanguage: TgsGanttLanguage; // Язык

    FCalendar: TGanttCalendar; // Календарь
    FTree: TGanttTree; // Дерево
    FSplitter: TSplitter; // Полоса изменения расстояний

    function GetIntervalCount: Integer;
    function GetInterval(AnIndex: Integer): TInterval;

    function GetCalendarFont: TFont;
    procedure SetCalendarFont(const Value: TFont);
    function GetCalendarColor: TColor;
    procedure SetCalendarColor(const Value: TColor);
    function GetMajorColor: TColor;
    procedure SetMajorColor(const Value: TColor);
    function GetMinorColor: TColor;
    procedure SetMinorColor(const Value: TColor);
    function GetMajorScale: TTimeScale;
    procedure SetMajorScale(const Value: TTimeScale);
    function GetMinorScale: TTimeScale;
    procedure SetMinorScale(const Value: TTimeScale);
    function GetPixelsPerMinorScale: Integer;
    procedure SetPixelsPerMinorScale(const Value: Integer);
    function GetPixelsPerLine: Integer;
    procedure SetPixelsPerLine(const Value: Integer);
    function GetStartDate: TDateTime;
    procedure SetStartDate(const Value: TDateTime);

    function GetTreeIndent: Integer;
    procedure SetTreeIndent(const Value: Integer);
    function GetTreeFont: TFont;
    procedure SetTreeFont(const Value: TFont);
    function GetTreeBranchFont: TFont;
    procedure SetTreeBranchFont(const Value: TFont);
    procedure SetLanguage(const Value: TgsGanttLanguage);

  protected
    procedure MakeIntervalList(AList: TList);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddInterval(AnInterval: TInterval);
    procedure InsertInterval(AnIndex: Integer; AnInterval: TInterval);
    procedure DeleteInterval(AnIndex: Integer);
    procedure RemoveInterval(AnInterval: TInterval);

    procedure UpdateInterval;

    // Дерево
    property Tree: TGanttTree read FTree;
    // Календарь
    property Calendar: TGanttCalendar read FCalendar;

    // Кол-во интервалов
    property IntervalCount: Integer read GetIntervalCount;
    // Интервал по индексу
    property Interval[Index: Integer]: TInterval read GetInterval;

  published
    // Выравнивание
    property Align;

    // Шрифт всего текста
    property CalendarFont: TFont read GetCalendarFont write SetCalendarFont;
    // Цвет фона
    property CalendarColor: TColor read GetCalendarColor write SetCalendarColor;
    // Цвет верхней шкалы
    property MajorColor: TColor read GetMajorColor write SetMajorColor;
    // Цвет нижней шкалы
    property MinorColor: TColor read GetMinorColor write SetMinorColor;

    // Временной интервал просмотра
    property MajorScale: TTimeScale read GetMajorScale write SetMajorScale default tsWeek;
    // Временной интервал просмотра
    property MinorScale: TTimeScale read GetMinorScale write SetMinorScale default tsDay;
    // Количество точек на единицу отображаемого времени нижней шкалы
    property PixelsPerMinorScale: Integer read GetPixelsPerMinorScale write SetPixelsPerMinorScale default 30;
    // Кол-во точек на одну горизонтальную линию
    property PixelsPerLine: Integer read GetPixelsPerLine write SetPixelsPerLine default 24;
    // Начальная дата просмотра
    property StartDate: TDateTime read GetStartDate write SetStartDate;

    // Расстояние между ветвями
    property TreeIndent: Integer read GetTreeIndent write SetTreeIndent;
    // Шрифт обычного текста
    property TreeFont: TFont read GetTreeFont write SetTreeFont;
    // Шрифт ветви
    property TreeBranchFont: TFont read GetTreeBranchFont write SetTreeBranchFont;
    // Язык, используемый в тексте
    property Language: TgsGanttLanguage read FLanguage write SetLanguage;

  end;

//procedure Register;

implementation

{$R gsGantt.res}

uses Math;

// Bitmap для ускоренного рисования текста
var
  DrawBitmap: TBitmap = nil;

{
  --------------------------------------------------------
  ------                                            ------
  ------      Usefull procedures and functions      ------
  ------                                            ------
  --------------------------------------------------------
}

{
  Возвращает кол-во единиц на указанное время и тип времени.
  Если необходимо указывается год и месяц
}

function GetTimeScaleUnits(TimeScale: TTimeScale; Year, Month: Integer): Integer;
begin
  case TimeScale of
    tsMinute: // В часе 60 минут
    begin
      Result := 60;
    end;
    tsHour: // В часе 60 минут
    begin
      Result := 60;
    end;
    tsDay: // В дне 24 часа
    begin
      Result := 24;
    end;
    tsWeek: // В неделе 7 дней
    begin
      Result := 7;
    end;
    tsMonth: // В месяце 31 или 30 или 29 или 28 дней
    begin
      // В зависимости от того, высокосный год или нет берем кол-во дней в месяце
      Result := MonthDays[IsLeapYear(Year)][Month];
    end;
    tsQuarter: // Кол-во месяцев в квартале - 3 месяца
    begin
      Result := 3;
    end;
    tsHalfYear: // В полугодии 2 квартала
    begin
      Result := 2;
    end;
    tsYear: // В годе 2 полугодия
    begin
      Result := 2;
    end;
    else // Иначе значит секунды
      Result := 60;
  end;
end;

{
  Увеличивает время на определенное число единиц.
}

function IncTime(D: TDateTime; TimeScale: TTimeScale; IncAmount: Integer): TDateTime;
var
  S: TTimeStamp;
begin
  S := DateTimeToTimeStamp(D);

  case TimeScale of
    tsMinute:
    begin
      if IncAmount > 24 * 60 then
      begin
        Inc(S.Date, IncAmount div 24 * 60);
        IncAmount := IncAmount - IncAmount div (24 * 60) * (24 * 60);
      end;

      Inc(S.Time, IncAmount * 60 * 1000);
      while S.Time < 0 do
      begin
        Dec(S.Date);
        S.Time := MSecsPerDay + S.Time;
      end;
    end;
    tsHour:
    begin
      if IncAmount > 24 then
      begin
        Inc(S.Date, IncAmount div 24);
        IncAmount := IncAmount - IncAmount div 24 * 24;
      end;

      Inc(S.Time, IncAmount * 60 * 60 * 1000);
      while S.Time < 0 do
      begin
        Dec(S.Date);
        S.Time := MSecsPerDay + S.Time;
      end;
    end;
    tsDay:
    begin
      Inc(S.Date, IncAmount);
    end;
    tsWeek:
    begin
      Inc(S.Date, IncAmount * 7);
    end;
    tsMonth:
    begin
      S := DateTimeToTimeStamp(IncMonth(D, IncAmount));
    end;
    tsQuarter:
    begin
      S := DateTimeToTimeStamp(IncMonth(D, IncAmount * 3));
    end;
    tsHalfYear:
    begin
      S := DateTimeToTimeStamp(IncMonth(D, IncAmount * 6));
    end;
    tsYear:
    begin
      S := DateTimeToTimeStamp(IncMonth(D, IncAmount * 12));
    end;
    else begin
      if IncAmount > 24 * 60 * 60 then
      begin
        Inc(S.Date, IncAmount div 24 * 60 * 60);
        IncAmount := IncAmount - IncAmount div 24 * 60 * 60;
      end;

      Inc(S.Time, IncAmount * 1000);
      while S.Time < 0 do
      begin
        Dec(S.Date);
        S.Time := MSecsPerDay + S.Time;
      end;
    end;
  end;

  Result := TimeStampToDateTime(S);
end;

{
  Увеличивает время на определенное число дробных единиц.
}

function IncTimeEx(D: TDateTime; TimeScale: TTimeScale; IncAmount: Double): TDateTime;
var
  S: TTimeStamp;
  Year, Month, Day: Word;
begin
  S := DateTimeToTimeStamp(D);

  case TimeScale of
    tsMinute:
    begin
      if IncAmount > 24 * 60 then
      begin
        Inc(S.Date, Trunc(IncAmount / 24 * 60));
        IncAmount := IncAmount - Trunc(IncAmount / 24 * 60) * (24 * 60);
      end;

      Inc(S.Time, Trunc(IncAmount * 60 * 1000));

      while S.Time < 0 do
      begin
        Dec(S.Date);
        S.Time := MSecsPerDay + S.Time;
      end;
    end;
    tsHour:
    begin
      if IncAmount > 24 then
      begin
        Inc(S.Date, Trunc(IncAmount / 24));
        IncAmount := IncAmount - Trunc(IncAmount / 24) * 24;
      end;

      Inc(S.Time, Trunc(IncAmount * 60 * 60 * 1000));

      while S.Time < 0 do
      begin
        Dec(S.Date);
        S.Time := MSecsPerDay + S.Time;
      end;
    end;
    tsDay:
    begin
      Inc(S.Date, Trunc(IncAmount));

      S :=
        DateTimeToTimeStamp
        (
          IncTimeEx
          (
            TimeStampToDateTime(S), tsHour, Frac(IncAmount) * 24
          )
        );
    end;
    tsWeek:
    begin
      Inc(S.Date, Trunc(IncAmount) * 7);

      S :=
        DateTimeToTimeStamp
        (
          IncTimeEx
          (
            TimeStampToDateTime(S), tsDay, Frac(IncAmount) * 7
          )
        );
    end;
    tsMonth:
    begin
      S := DateTimeToTimeStamp(IncMonth(D, Trunc(IncAmount)));
      DecodeDate(TimeStampToDateTime(S), Year, Month, Day);

      S :=
        DateTimeToTimeStamp
        (
          IncTimeEx
          (
            TimeStampToDateTime(S), tsDay,
            Frac(IncAmount) * MonthDays[IsLeapYear(Year)][Month]
          )
        );
    end;
    tsQuarter:
    begin
      S := DateTimeToTimeStamp(IncMonth(D, Trunc(IncAmount) * 3));

      S :=
        DateTimeToTimeStamp
        (
          IncTimeEx
          (
            TimeStampToDateTime(S), tsMonth, Frac(IncAmount) * 3
          )
        );
    end;
    tsHalfYear:
    begin
      S := DateTimeToTimeStamp(IncMonth(D, Trunc(IncAmount) * 6));

      S :=
        DateTimeToTimeStamp
        (
          IncTimeEx
          (
            TimeStampToDateTime(S), tsMonth, Frac(IncAmount) * 6
          )
        );
    end;
    tsYear:
    begin
      S := DateTimeToTimeStamp(IncMonth(D, Trunc(IncAmount) * 12));

      S :=
        DateTimeToTimeStamp
        (
          IncTimeEx
          (
            TimeStampToDateTime(S), tsMonth, Frac(IncAmount) * 12
          )
        );
    end;
    else begin
      if IncAmount > 24 * 60 * 60 then
      begin
        Inc(S.Date, Trunc(IncAmount / 24 * 60 * 60));
        IncAmount := IncAmount - IncAmount / 24 * 60 * 60;
      end;

      Inc(S.Time, Trunc(IncAmount * 1000));
      while S.Time < 0 do
      begin
        Dec(S.Date);
        S.Time := MSecsPerDay + S.Time;
      end;
    end;
  end;

  Result := TimeStampToDateTime(S);
end;


{
  Очищает до начала периода.
}

function ClearToPeriodStart(MinorScale: TTimeScale; D: TDateTime): TDateTime;
var
  S: TTimeStamp;
  Year, Month, Day: Word;
begin
  S := DateTimeToTimeStamp(D);
  DecodeDate(D, Year, Month, Day);

  case MinorScale of
    tsMinute: // На начало минуты
    begin
      S.Time := (S.Time div (60 * 1000)) * (60 * 1000);
    end;
    tsHour: // На начало часа
    begin
      S.Time := (S.Time div (60 * 60 * 1000)) * (60 * 60 * 1000);
    end;
    tsDay: // на начало дня
    begin
      S.Time := 0;
    end;
    tsWeek: // на начало недели
    begin
      S.Date := (S.Date div 7) * 7 + 1;
      S.Time := 0;
    end;
    tsMonth: // на начало месяца
    begin
      Day := 1;
      D := EncodeDate(Year, Month, Day);
      S := DateTimeToTimeStamp(D);
      S.Time := 0;
    end;
    tsQuarter: // на начало квартала
    begin
      Day := 1;
      Month := (Month div 3) * 3 + 1;

      if Month > 12 then
      begin
        Month := 1;
        Inc(Year);
      end;

      D := EncodeDate(Year, Month, Day);
      S := DateTimeToTimeStamp(D);
      S.Time := 0;
    end;
    tsHalfYear: // на начало полугодия
    begin
      Day := 1;
      Month := (Month div 6) * 6 + 1;

      if Month > 12 then
      begin
        Month := 1;
        Inc(Year);
      end;
      
      D := EncodeDate(Year, Month, Day);
      S := DateTimeToTimeStamp(D);
      S.Time := 0;
    end;
    tsYear: // на начало года
    begin
      Day := 1;
      Month := 1;
      D := EncodeDate(Year, Month, Day);
      S := DateTimeToTimeStamp(D);
      S.Time := 0;
    end;
    else begin
      S.Time := (S.Time div 1000) * 1000;
    end;
  end;

  Result := TimeStampToDateTime(S);
//  if MinorScale > tsMinute then
//    Result := ClearToPeriodStart(PrevScale[MinorScale], Result);
end;

{
  Возвращает название
}

function GetTimeScaleName(TimeScale: TTimeScale; D: TDateTime; Lang: TgsGanttLanguage): String;
var
  Hour, Min, Sec, MSec: Word;
  Year, Month, Day: Word;
  S: TTimeStamp;
begin
  DecodeDate(D, Year, Month, Day);
  DecodeTime(D, Hour, Min, Sec, MSec);
  S := DateTimeToTimeStamp(D);

  case TimeScale of
    tsMinute:
    begin
      Result := IntToStr(Min);
    end;
    tsHour:
    begin
      Result := IntToStr(Hour);
    end;
    tsDay:
    begin
      Result := WeekDays[Lang, DayOfWeek(D) - 1];
    end;
    tsWeek:
    begin
      Result := IntToStr(Day) + '.' + IntToStr(Month);
    end;
    tsMonth:
    begin
      Result := MonthNames[Lang, Month - 1];
    end;
    tsQuarter:
    begin
      Result := IntToStr((Month) div 3 + 1);
    end;
    tsHalfYear:
    begin
      Result := IntToStr((Month) div 6 + 1);
    end;
    tsYear:
    begin
      Result := IntToStr(Year);
    end;
  end;
end;

{
  Кол-во временных единиц между датами.
}

function UnitsBetweenDates(Start, Finish: TdateTime; TimeScale: TTimeScale): Double;
var
  StartStamp, FinishStamp: TTimeStamp;
  StartDay, StartMonth, StartYear: Word;
  FinishDay, FinishMonth, FinishYear: Word;
begin
  StartStamp := DateTimeToTimeStamp(Start);
  FinishStamp := DateTimeToTimeStamp(Finish);
  
  DecodeDate(Start, StartYear, StartMonth, StartDay);
  DecodeDate(Finish, FinishYear, FinishMonth, FinishDay);

  case TimeScale of
    tsMinute:
    begin
      Result :=
        (FinishStamp.Time / 1000 / 60 + FinishStamp.Date * 24 * 60) -
        (StartStamp.Time / 1000 / 60 + StartStamp.Date * 24 * 60);
    end;
    tsHour:
    begin
      Result :=
        (FinishStamp.Time / 1000 / 60 / 60 + FinishStamp.Date * 24) -
        (StartStamp.Time / 1000 / 60 / 60 + StartStamp.Date * 24);
    end;
    tsDay:
    begin
      Result :=
        (FinishStamp.Time / 1000 / 60 / 60 / 24 + FinishStamp.Date) -
        (StartStamp.Time / 1000 / 60 / 60 / 24 + StartStamp.Date);
    end;
    tsWeek:
    begin
      Result :=
        (FinishStamp.Time / 1000 / 60 / 60 / 24 / 7 + FinishStamp.Date / 7) -
        (StartStamp.Time / 1000 / 60 / 60 / 24 / 7 + StartStamp.Date / 7);
    end;
    tsMonth:
    begin
      Result :=
        (
          FinishMonth
            +
          (FinishDay + FinishStamp.Time / 1000 / 60 / 60 / 24)
            /
          MonthDays[IsLeapYear(FinishYear)][FinishMonth]
        )
          -
        (
          StartMonth
            +
          (StartDay + StartStamp.Time / 1000 / 60 / 60 / 24)
            /
          MonthDays[IsLeapYear(FinishYear)][FinishMonth]
        )
          +
        (FinishYear - StartYear)
          *
        12;
    end;
    tsQuarter:
    begin
      Result :=
        (
          (
            FinishMonth
              +
            (FinishDay + FinishStamp.Time / 1000 / 60 / 60 / 24)
              /
            MonthDays[IsLeapYear(FinishYear)][FinishMonth]
          )
            -
          (
            StartMonth
              +
            (StartDay + StartStamp.Time / 1000 / 60 / 60 / 24)
              /
            MonthDays[IsLeapYear(FinishYear)][FinishMonth]
          )
        )
          /
        3
          +
        (FinishYear - StartYear)
          *
        3;
    end;
    tsHalfYear:
    begin
      Result :=
        (
          (
            FinishMonth
              +
            (FinishDay + FinishStamp.Time / 1000 / 60 / 60 / 24)
              /
            MonthDays[IsLeapYear(FinishYear)][FinishMonth]
          )
            -
          (
            StartMonth
              +
            (StartDay + StartStamp.Time / 1000 / 60 / 60 / 24)
              /
            MonthDays[IsLeapYear(FinishYear)][FinishMonth]
          )
        )
          /
        6
          +
        (FinishYear - StartYear)
          *
        6;
    end;
    tsYear:
    begin
      Result :=
        (
          (
            FinishMonth
              +
            (FinishDay + FinishStamp.Time / 1000 / 60 / 60 / 24)
              /
            MonthDays[IsLeapYear(FinishYear)][FinishMonth]
          )
            -
          (
            StartMonth
              +
            (StartDay + StartStamp.Time / 1000 / 60 / 60 / 24)
              /
            MonthDays[IsLeapYear(FinishYear)][FinishMonth]
          )
          /
          12
        )
          +
        (FinishYear - StartYear);
    end;
    else begin
      Result :=
        FinishStamp.Time / 1000 + FinishStamp.Date * 24 * 60 * 60 -
        StartStamp.Time / 1000 + StartStamp.Date * 24 * 60 * 60;
    end;
  end;
end;


// Входит ли точка в область
function IsInRect(X, Y: Integer; R: TRect): Boolean;
begin
  Result := (X >= R.Left) and (X <= R.Right) and (Y >= R.Top) and (Y <= R.Bottom);
end;

// Производит рисование текста по заданным параметрам
// Взята у Borland из файла DBGrids.
procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: string; Alignment: TAlignment; ARightToLeft: Boolean);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
  RTL: array [Boolean] of Integer = (0, DT_RTLREADING);
var
  B, R: TRect;
  Hold, Left: Integer;
  I: TColorRef;
begin
  I := ColorToRGB(ACanvas.Brush.Color);
  if GetNearestColor(ACanvas.Handle, I) = I then
  begin                       { Use ExtTextOut for solid colors }
    { In BiDi, because we changed the window origin, the text that does not
      change alignment, actually gets its alignment changed. }
    if (ACanvas.CanvasOrientation = coRightToLeft) and (not ARightToLeft) then
      ChangeBiDiModeAlignment(Alignment);
    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - ACanvas.TextWidth(Text) - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1
        - (ACanvas.TextWidth(Text) shr 1);
    end;
    ACanvas.TextRect(ARect, Left, ARect.Top + DY, Text);
  end
  else begin                  { Use FillRect and Drawtext for dithered colors }
    DrawBitmap.Canvas.Lock;
    try
      with DrawBitmap, ARect do { Use offscreen bitmap to eliminate flicker and }
      begin                     { brush origin tics in painting / scrolling.    }
        Width := Max(Width, Right - Left);
        Height := Max(Height, Bottom - Top);
        R := Rect(DX, DY, Right - Left - 1, Bottom - Top - 1);
        B := Rect(0, 0, Right - Left, Bottom - Top);
      end;
      with DrawBitmap.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);
        if (ACanvas.CanvasOrientation = coRightToLeft) then
          ChangeBiDiModeAlignment(Alignment);
        DrawText(Handle, PChar(Text), Length(Text), R,
          AlignFlags[Alignment] or RTL[ARightToLeft]);
      end;
      if (ACanvas.CanvasOrientation = coRightToLeft) then  
      begin
        Hold := ARect.Left;
        ARect.Left := ARect.Right;
        ARect.Right := Hold;
      end;
      ACanvas.CopyRect(ARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
end;

{
  ----------------------------------------------
  ------                                  ------
  ------      TgsMonthCalendar Class      ------
  ------                                  ------
  ----------------------------------------------
}

{
  Длеаем начальные утановки.
}

constructor TgsMonthCalendar.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FOnSelectDate := nil;
end;

{
  Ловим сообщение о выборе даты.
}

procedure TgsMonthCalendar.CNNotify(var Message: TWMNotify);
begin
  inherited;
  with Message, NMHdr^ do
  begin
    case code of
      MCN_GETDAYSTATE:
      begin
      end;
      MCN_SELECT:
      begin
        if Assigned(FOnSelectDate) then
          FOnSelectDate(Self);
      end;
    end;
  end;
end;


{
  ---------------------------------------
  ------                           ------
  ------      TInterval Class      ------
  ------                           ------
  ---------------------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}


{
  Делаем начальные установки.
}

constructor TInterval.Create(AGantt: TgsGantt);
begin
  FGantt := AGantt;
  FStartDate := 0;
  FFinishDate := 0;
  FDrawRect := Rect(-1, -1, -1, -1);
  FVisible := False;
  FParent := nil;

  FIntervals := TExList.Create;
  FConnections := Tlist.Create;
  FCanUpdate := True;
end;

{
  Высвобождаем память.
}

destructor TInterval.Destroy;
begin
  FConnections.Free;
  FIntervals.Free;

  inherited Destroy;
end;

{
  Добавление связи.
}

procedure TInterval.AddConnection(AConnection: TInterval);
begin
  if FConnections.IndexOf(AConnection) = -1 then
  begin
    // Рекурсивная связь невозможна
    if AConnection.ConnectionExists(Self) then Exit;
    if ConnectionExists(AConnection) then Exit;

    if AConnection.StartDate < FinishDate then
      AConnection.UpdateIntervalStart(FinishDate - AConnection.StartDate);

    FConnections.Add(AConnection);
    FGantt.UpdateInterval;
  end;
end;

{
  Удаление связи.
}

procedure TInterval.DeleteConnection(AnIndex: Integer);
begin
  FConnections.Delete(AnIndex);
  FGantt.UpdateInterval;
end;

{
  Удаление связи.
}

procedure TInterval.RemoveConnection(AConnection: TInterval);
begin
  FConnections.Remove(AConnection);
  FGantt.UpdateInterval;
end;

{
  Добавляет интервал в самый конец списка.
}

procedure TInterval.AddInterval(AnInterval: TInterval);
begin
  FIntervals.Add(AnInterval);
  AnInterval.FParent := Self;
  FGantt.UpdateInterval;
end;

{
  Вставка интервала на определенную позицию.
}

procedure TInterval.InsertInterval(AnIndex: Integer; AnInterval: TInterval);
begin
  FIntervals.Insert(AnIndex, AnInterval);
  AnInterval.FParent := Self;
  FGantt.UpdateInterval;
end;

{
  Удаление интервала по индексу.
}

procedure TInterval.DeleteInterval(AnIndex: Integer);
begin
  FIntervals.Delete(AnIndex);
  FGantt.UpdateInterval;
end;

{
  Удаление интервала по классу удаляемого интервала.
}

procedure TInterval.RemoveInterval(AnInterval: TInterval);
begin
  FIntervals.Remove(AnInterval);
  FGantt.UpdateInterval;
end;

{
  Очищает рисуемую область
}

procedure TInterval.ClearDrawRect;
begin
  FDrawRect := Rect(-1, -1, -1, -1);
end;

{
  Создает список интервалов.
}

procedure TInterval.MakeIntervalList(AList: TList);
var
  I: Integer;
begin
  for I := 0 to IntervalCount - 1 do
  begin
    if Interval[I].Visible then
    begin
      AList.Add(Interval[I]);
      Interval[I].MakeIntervalList(AList);
    end;
  end;
end;

{
  Есть ли такая связь уже в списке.
}

function TInterval.ConnectionExists(AConnection: TInterval): Boolean;
var
  I: Integer;
begin
  Result := False;

  if IntervalExists(AConnection) then
  begin
    Result := True;
    Exit;
  end;

  for I := 0 to ConnectionCount - 1 do
    if AConnection = Connection[I] then
    begin
      Result := True;
      Exit;
    end else if Connection[I].ConnectionExists(AConnection) then
    begin
      Result := True;
      Exit;
    end;

  if IsCollection then
    for I := 0 to IntervalCount - 1 do
      if Interval[I].ConnectionExists(AConnection) then
      begin
        Result := True;
        Break; 
      end;
end;

{
  Существует такой интервал или нет.
}

function TInterval.IntervalExists(AnInterval: TInterval): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 0 to IntervalCount - 1 do
    if AnInterval = Interval[I] then
    begin
      Result := True;
      Exit;
    end else if Interval[I].IntervalExists(AnInterval) then
    begin
      Result := True;
      Exit;
    end;
end;

{
  Производит перенос всех промежутков до определенной даты.
}

procedure TInterval.UpdateIntervalStart(Delta: TDateTime);
var
  I: Integer;
begin
  for I := 0 to ConnectionCount - 1 do
    Connection[I].UpdateIntervalStart(Delta);

  if IsCollection then
  begin
    for I := 0 to IntervalCount - 1 do
      Interval[I].UpdateIntervalStart(Delta);
  end else begin
    if FCanUpdate then
    begin
      FStartDate := FStartDate + Delta;
      FFinishDate := FFinishDate + Delta;
      FIntervalDone := FIntervalDone + Delta;
      FCanUpdate := False;
    end;  
  end;
end;

{
  Приготавливает интервал к изменению промежутка.
}

procedure TInterval.PrepareToUpdate;
var
  I: Integer;
begin
  FCanUpdate := True;

  for I := 0 to IntervalCount - 1 do
    Interval[I].PrepareToUpdate;

  for I := 0 to ConnectionCount - 1 do
    Connection[I].PrepareToUpdate;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Проготавливаем границы рисования.
}

procedure TInterval.PrepareDrawRect;
begin
  FDrawRect.Left :=
    Round
    (
      UnitsBetweenDates
      (
        FGantt.Calendar.VisibleStart,
        StartDate,
        FGantt.Calendar.MinorScale
      )
        *
      FGantt.Calendar.PixelsPerMinorScale
    );

  FDrawRect.Right :=
    Round
    (
      UnitsBetweenDates(
        FGantt.Calendar.VisibleStart,
        FinishDate,
        FGantt.Calendar.MinorScale
      )
        *
      FGantt.Calendar.PixelsPerMinorScale
    );
  if FDrawRect.Left < 0 then ;
end;


{
  ************************
  ***   Private Part   ***
  ************************
}


{
  Начало периода.
}

function TInterval.GetStartDate: TDateTime;
begin
  Result := CountStartDate;
end;

{
  Окончание периода.
}

function TInterval.GetFinishDate: TDateTime;
begin
  Result := CountFinishDate;
end;

{
  Установка начала периода.
}

procedure TInterval.SetStartDate(const Value: TDateTime);
begin
  FStartDate := Value;
  
  if FIntervalDone < FStartDate then
    FIntervalDone := FStartDate;
end;

{
  Установка окончания периода.
}

procedure TInterval.SetFinishDate(const Value: TDateTime);
begin
  FFinishDate := Value;
  if FIntervalDone > FFinishDate then
    FIntervalDone := FFinishDate;
end;

{
  Возвращает продолжительность.
}

function TInterval.GetDuration: TDateTime;
begin
  Result := FinishDate - StartDate;
end;

{
  Устанавливает продолжительность.
}

procedure TInterval.SetDuration(const Value: TDateTime);
begin
  FinishDate := StartDate + Value;
end;

{
  Вовзращает продолжительность в формате
  кол-во дней и милисекунд
}

function TInterval.GetStampDuration: TTimeStamp;
var
  StartStamp, FinishStamp: TTimeStamp;
begin
  StartStamp := DateTimeToTimeStamp(StartDate);
  FinishStamp := DateTimeToTimeStamp(FinishDate);

  Result.Date := FinishStamp.Date - StartStamp.Date;
  Result.Time := FinishStamp.Time - StartStamp.Time;

  if Result.Time < 0 then
  begin
    Dec(Result.Date);
    Result.Time := MSecsPerDay + Result.Time;
  end;
end;

{
  Устанавливает задание.
}

procedure TInterval.SetTask(const Value: String);
begin
  FTask := Value;
  FGantt.UpdateInterval;
end;

{
  Возвращает тип интервала.
}

function TInterval.GetIntervalType: TIntervalType;
begin
  if (IntervalCount = 0) and (FStartDate = FFinishDate) then
    Result := itAction
  else
    Result := itPeriod;
end;

{
  Возвращает интервал вложенности периода.
}

function TInterval.GetLevel: Integer;
begin
  if Parent = nil then
    Result := 1
  else
    Result := FParent.GetLevel + 1;
end;

{
  Возвращает кол-во интервалов.
}

function TInterval.GetIntervalCount: Integer;
begin
  Result := FIntervals.Count;
end;

{
  Возвращает интервал по индексу.
}

function TInterval.GetInterval(AnIndex: Integer): TInterval;
begin
  Result := FIntervals[AnIndex];
end;

{
  Возвращает кол-во связей.
}

function TInterval.GetConnectionCount: Integer;
begin
  Result := FConnections.Count;
end;

{
  Возвращает связь по индексу.
}

function TInterval.GetConnection(AnIndex: Integer): TInterval;
begin
  Result := FConnections[AnIndex];
end;

{
  Является интервалом или же набором последних.
}

function TInterval.GetIsCollection: Boolean;
begin
  Result := FIntervals.Count > 0;
end;

{
  Возвращает процент выполнения плана.
}

function TInterval.GetIntervalDone: TDateTime;
begin
  Result := FIntervalDone;
end;

{
  Устанавливает процент выполнения плана.
}

procedure TInterval.SetIntervalDone(const Value: TDateTime);
begin
  FIntervalDone := Value;
  
  if FIntervalDone > FinishDate then
    FIntervalDone := FinishDate
  else if FIntervalDone < StartDate then
    FIntervalDone := StartDate;
end;

{
  Чисты ли границы для рисования.
}

function TInterval.GetIsDrawRectClear: Boolean;
begin
  Result :=
    (DrawRect.Left = -1)
      and
    (DrawRect.Right = -1)
      and
    (DrawRect.Top = -1)
      and
    (DrawRect.Bottom = -1);  
end;

{
  Возвращает область выполненного задания.
}

function TInterval.GetDoneRect: TRect;
begin
  if IsDrawRectClear then
  begin
    Result := DrawRect;
    Exit;
  end;

  Result.Top := FDrawRect.Top + (FDrawRect.Bottom - FDrawRect.Top) div 3;
  Result.Bottom := FDrawRect.Bottom - (FDrawRect.Bottom - FDrawRect.Top) div 3;

  Result.Left := FDrawRect.Left;
  Result.Right :=
    Round
    (
      UnitsBetweenDates
      (
        FGantt.Calendar.VisibleStart,
        FIntervalDone,
        FGantt.Calendar.MinorScale
      )
        *
      FGantt.Calendar.PixelsPerMinorScale
    );

end;

{
  Область для установки процента выполнения.
}

function TInterval.GetPercentMoveRect: TRect;
begin
  Result := DoneRect;

  // Если процент выполнения
  if (Result.Left >= 0) or (Result.Right >= 0) then
  begin
    if Result.Left = Result.Right then
      Result.Right := Result.Left + 8
    else
      Result.Left := Result.Right - 8;
  end;
end;

{
  Область для сдвига периода влево.
}

function TInterval.GetLeftMoveRect: TRect;
begin
  if IsDrawRectClear then
  begin
    Result := DrawRect;
    Exit;
  end;

  Result := Rect
  (
    FDrawRect.Left,
    FDrawRect.Top,
    FDrawRect.Left + 8,
    FDrawRect.Bottom
  );
end;

{
  Область для сдвига периода вправо.
}

function TInterval.GetRightMoveRect: TRect;
begin
  if IsDrawRectClear then
  begin
    Result := DrawRect;
    Exit;
  end;

  Result := Rect
  (
    FDrawRect.Right - 8,
    FDrawRect.Top,
    FDrawRect.Right,
    FDrawRect.Bottom
  );
end;

{
  Возвращает видимость.
}

function TInterval.GetVisible: Boolean;
begin
  Result :=
    FVisible and
    (
      (Parent = nil)
        or
      ((Parent <> nil) and Parent.Visible)
    );
end;

{
  Устанавливает видимость.
}

procedure TInterval.SetVisible(const Value: Boolean);
//var
//  I: Integer;
begin
  FVisible := Value;
{
  if not Value then
    for I := 0 to IntervalCount - 1 do
      Interval[I].Visible := Value;
}
end;

{
  Открыт промежуток или нет.
}

function TInterval.GetOpened: Boolean;
begin
  Result :=
    ((IntervalCount = 0) and FVisible)
      or
    ((IntervalCount > 0) and Interval[0].Visible);
end;

{
  Открываем или закрываем интервал.
}

procedure TInterval.SetOpened(const Value: Boolean);
var
  I: Integer;
begin
  for I := 0 to IntervalCount - 1 do
    Interval[I].Visible := Value;
end;

{
  Рассчитывает начало периода.
}

function TInterval.CountStartDate: TDateTime;
var
  I: Integer;
  CurrStartDate: TDateTime;
begin
  // Если работаем с периодом
  if IntervalType = itPeriod then
  begin
    if IsCollection then // Если список интервалов
    begin
      Result := Interval[0].CountStartDate;

      // Просматриваем все интервалы времени
      for I := 1 to IntervalCount - 1 do
      begin
        CurrStartDate := Interval[I].CountStartDate;

        // Если интервал больше, то берем меньший
        if Result > CurrStartDate then Result := CurrStartDate;
      end;
    end else begin // Если окончательный интервал времени
      Result := FStartDate;
    end;
  end else begin // Если работаем с действием
    Result := FStartDate;
  end;
end;

{
  Рассчитывает окончание периода.
}

function TInterval.CountFinishDate: TDateTime;
var
  I: Integer;
begin
  // Если работаем с периодом
  if IntervalType = itPeriod then
  begin
    if IsCollection then // Если список интервалов
    begin
      Result := Interval[0].CountFinishDate;

      // Просматриваем все интервалы времени
      for I := 1 to IntervalCount - 1 do
        if // Если интервал меньше, то берем больший
          Result < Interval[I].CountFinishDate
        then
          Result := Interval[I].CountFinishDate;
    end else begin // Если окончательный интервал времени
      Result := FFinishDate;
    end;
  end else begin // Если работаем с действием
    Result := FFinishDate;
  end;
end;



{
  -------------------------------------------
  ------                               ------
  ------      TGanttCalendar Class      ------
  ------                               ------
  -------------------------------------------
}


{
  ***********************
  ***   Public Part   ***
  ***********************
}

{TGanttCalendar}

{
  Начальные установки.
}

{DONE 4 -oDenis -cScrollBar: Создание скролл баров}
constructor TGanttCalendar.Create(AnOwner: TgsGantt);
begin
  inherited Create(AnOwner);

  // Создание вертикального скроллбара
  FVertScrollBar := TScrollBar.Create(Self);
  FVertScrollBar.Kind := sbVertical;
  FVertScrollBar.Enabled := True;
  FVertScrollBar.Visible := True;
  FVertScrollBar.Align := alNone;
  FVertScrollBar.TabStop := False;
  InsertControl(FVertScrollBar);

  // Создание горизонтального скроллбара
  FHorzScrollBar := TScrollBar.Create(Self);
  FHorzScrollBar.Kind := sbHorizontal;
  FHorzScrollBar.Enabled := True;
  FHorzScrollBar.Visible := True;
  FHorzScrollBar.Align := alNone;
  FHorzScrollBar.TabStop := False;
  InsertControl(FHorzScrollBar);

  // Установки для горизонтального скроллбара
  FHorzScrollBar.SetParams(0, 0, SCROLL_MAX);
  FHorzScrollBar.LargeChange := SCROLL_MAXSTEP;
  FHorzScrollBar.PageSize := SCROLL_MAXSTEP;
  FHorzScrollBar.SmallChange := SCROLL_MINSTEP;

  // Установки для вертикального скроллбара
  FVertScrollBar.SetParams(0, 0, SCROLL_MAX);
  FVertScrollBar.LargeChange := SCROLL_MAXSTEP;
  FVertScrollBar.PageSize := SCROLL_MAXSTEP;
  FVertScrollBar.SmallChange := SCROLL_MINSTEP;

  // Установки по умолчанию
  FMajorScale := tsMonth;
  FMinorScale := tsWeek;

  // Временные установки
  FStartDate := Now;
  FCurrentDate := 0;
  FVisibleStart := ClearToPeriodStart(MinorScale, FStartDate);

  // Кол-во точек на единицу времени
  FPixelsPerMinorScale := 30;
  FPixelsPerLine := 20; {24}

  // Цвета по умолчанию
  Color := clWhite;
  FMajorColor := clBtnFace;
  FMinorColor := clBtnFace;

  FIntervals := AnOwner.FIntervals;
  FGantt := AnOwner;

  // Обнуление свойств
  FBeforeStartDateCount := 0;
  FDragRect := Rect(-1, -1, -1, -1);
  FDragType := ditNone;
  FDragInterval := nil;
  FDragStarted := False;
  FFromDragPoint := 0;
  FConnectInterval := nil;

  FConnectFromPoint := Point(0, 0);
  FConnectToPoint := Point(0, 0);
end;

{
  Высвобождение памяти.
}

destructor TGanttCalendar.Destroy;
begin
  inherited Destroy;
end;

{
  Добавляет интервал в самый конец списка.
}

procedure TGanttCalendar.AddInterval(AnInterval: TInterval);
begin
  FGantt.AddInterval(AnInterval)
end;

{
  Вставка интервала на определенную позицию.
}

procedure TGanttCalendar.InsertInterval(AnIndex: Integer; AnInterval: TInterval);
begin
  FGantt.InsertInterval(AnIndex, AnInterval);
end;

{
  Удаление интервала по индексу.
}

procedure TGanttCalendar.DeleteInterval(AnIndex: Integer);
begin
  FGantt.DeleteInterval(AnIndex);
end;

{
  Удаление интервала по классу удаляемого интервала.
}

procedure TGanttCalendar.RemoveInterval(AnInterval: TInterval);
begin
  FGantt.RemoveInterval(AnInterval);
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}


{
  Производит рисование календаря.
}

{DONE 2 -oDenis -cDrawing: Рисование календаря}
procedure TGanttCalendar.Paint;
var
  ClipRgn: hRgn;
  List: TList;
  CurrInterval: TInterval;
  I, K: Integer;
  BMP: TBitmap;
  DoneRect: TRect;
begin
  // Регион где, можно рисовать
  ClipRgn := CreateRectRgn
  (
    0,
    0,
    Width - FVertScrollBar.Width * Integer(FVertScrollBar.Visible),
    Height - FHorzScrollBar.Height * Integer(FHorzScrollBar.Visible)
  );

  List := TList.Create;

  // Создаем рисунок для промежутков
  BMP := TBitmap.Create;
  BMP.Width := 2;
  BMP.Height := 2;
  BMP.Canvas.Pixels[0, 0] := clBlue;
  BMP.Canvas.Pixels[1, 1] := clBlue;
  BMP.Canvas.Pixels[0, 1] := Color;
  BMP.Canvas.Pixels[1, 0] := Color;

  try
    // Устаанвливаем регион, где можно производить рисование
    SelectClipRgn(Canvas.Handle, ClipRgn);

    // Зарисовываем регион
    Brush.Color := Color;
    Canvas.FillRect(Rect(
      0, Width - FVertScrollBar.Width * Integer(FVertScrollBar.Visible),
      0, Height - FHorzScrollBar.Height * Integer(FHorzScrollBar.Visible)));

    // Зарисовываем верхнюю шкалу
    Canvas.Brush.Color := FMajorColor;
    Canvas.FillRect(Rect(0, 0, Width, MajorScaleHeight));

    // Зарисовываем нижнюю шкалу
    Canvas.Brush.Color := FMajorColor;
    Canvas.FillRect(Rect(0, MajorScaleHeight, Width, MajorScaleHeight + MinorScaleHeight));

    // Получаем полный список интервалов
    FGantt.MakeIntervalList(List);

    // Очищаем границы для рисования
    for I := 0 to List.Count - 1 do TInterval(List[I]).ClearDrawRect;

    // Устаанвливаем начальный период рисования
    FCurrentDate := VisibleStart;

    while FCurrentDate < VisibleFinish do
    begin
      // Рисование шкалы нижней
      DrawMinorScale;
      // Переход на следующий период
      FCurrentDate := IncTime(FCurrentDate, MinorScale, 1);
    end;

    // Устаанвливаем начальный период рисования
    FCurrentDate := ClearToPeriodStart(MajorScale, VisibleStart);

    while FCurrentDate < VisibleFinish do
    begin
      // Рисование шкалы нижней
      DrawMajorScale;
      // Переход на следующий период
      FCurrentDate := IncTime(FCurrentDate, MajorScale, 1);
    end;

    // Рассчитываем координаты интервалов
    for I := 0 to List.Count - 1 do TInterval(List[I]).PrepareDrawRect;

    // Линии заголовка
    DrawHeaderLines;

    for I := 0 to List.Count - 1 do
    begin
      CurrInterval := List[I];

      // Если границы для рисования введены
      if not CurrInterval.IsDrawRectClear then
      begin
        // Производим рисование
        with Canvas do
        begin
          if CurrInterval.IntervalType = itAction then
          begin
            CurrInterval.Top :=
              I * PixelsPerLine + 1 + StartDrawIntervals + PixelsPerLine div 2 - PixelsPerLine div 4;
            CurrInterval.Bottom := CurrInterval.Top + PixelsPerLine div 4 * 2;

            CurrInterval.Left := CurrInterval.Left - PixelsPerLine div 4;
            CurrInterval.Right := CurrInterval.Right + PixelsPerLine div 4;

            // Рисование самого промежутка
            Brush.Color := clBlue;

            //Ellipse(CurrInterval.DrawRect);
            with CurrInterval.DrawRect do
              Polygon
              (
                [
                  Point(Left + (Right - Left) div 2, Top),
                  Point(Right, Top + (Bottom - Top) div 2),
                  Point(Left + (Right - Left) div 2, Bottom),
                  Point(Left, Top + (Bottom - Top) div 2),
                  Point(Left + (Right - Left) div 2, Top)
                ]
              );

            // Обрамление
            Brush.Color := clBlue;
            Brush.Style := bsClear;

            Pen.Color := clBlack;
            Pen.Style := psSolid;

            //Ellipse(CurrInterval.DrawRect);
            with CurrInterval.DrawRect do
              Polygon
              (
                [
                  Point(Left + (Right - Left) div 2, Top),
                  Point(Right, Top + (Bottom - Top) div 2),
                  Point(Left + (Right - Left) div 2, Bottom),
                  Point(Left, Top + (Bottom - Top) div 2),
                  Point(Left + (Right - Left) div 2, Top)
                ]
              );

            Brush.Style := bsSolid;
            Brush.Color := clBlue;
          end else if CurrInterval.IsCollection then // Если список периодов
          begin
            CurrInterval.Top := I * PixelsPerLine + 1 + StartDrawIntervals;
            CurrInterval.Bottom := I * PixelsPerLine + 1 + StartDrawIntervals + 4;
            CurrInterval.Left := CurrInterval.Left - 4;
            CurrInterval.Right := CurrInterval.Right + 4;

            Brush.Color := clBlack;
            Brush.Style := bsSolid;
            FillRect(CurrInterval.DrawRect);

            with CurrInterval.DrawRect do
            begin
              Polygon
              (
                [
                  Point(Left, Bottom),
                  Point(Left + 4, Bottom + 4),
                  Point(Left + 8, Bottom)
                ]
              );

              Polygon
              (
                [
                  Point(Right - 1, Bottom),
                  Point(Right - 5, Bottom + 4),
                  Point(Right - 9, Bottom)
                ]
              );
            end;

          end else begin // Если обычный период
            CurrInterval.Top := I * PixelsPerLine + StartDrawIntervals + IntervalHeight div 4;
            CurrInterval.Bottom := (I + 1) * PixelsPerLine + StartDrawIntervals - IntervalHeight div 4;

            // Рисование самого промежутка
            Brush.Color := clBlue;
            Brush.Bitmap := BMP;
            FillRect(CurrInterval.DrawRect);

            // Обрамление
            Brush.Bitmap := nil;
            Brush.Color := clBlue;
            Brush.Style := bsSolid;
            FrameRect(CurrInterval.DrawRect);

            // Рисование процента выполнения
            if CurrInterval.IntervalDone > CurrInterval.StartDate then
            begin
              DoneRect := CurrInterval.DoneRect;

              Brush.Style := bsSolid;
              Brush.Color := clBlack;
              FillRect(DoneRect);
            end;
          end;
        end;
      end;
    end;

  for I := 0 to List.Count - 1 do
  begin
    CurrInterval := List[I];
    // Рисование связей интервалов
    for K := 0 to CurrInterval.ConnectionCount - 1 do
      ConnectIntervals(CurrInterval, CurrInterval.Connection[K]);
  end;

  finally
    BMP.Free;
    List.Free;
    // Возвращает полный регион
    SelectClipRgn(Canvas.Handle, 0);
    // Удаляем регион
    DeleteObject(ClipRgn);
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}


{
  Установка временного интервала просмотра данных - верхнего.
}

procedure TGanttCalendar.SetMajorScale(const Value: TTimeScale);
begin
  if csReading in ComponentState then
    FMajorScale := Value
  else if Value < MinorScale then
    raise Exception.Create('MajorScale should by higher than MinorScale')
  else if Value = MinorScale then
    raise Exception.Create('MajorScale should by different from MinorScale')
  else begin
    FMajorScale := Value;
    Invalidate;
  end;
end;

{
  Установка временного интервала просмотра данных - нижнего.
}

procedure TGanttCalendar.SetMinorScale(const Value: TTimeScale);
begin
  if csReading in ComponentState then
    FMinorScale := Value
  else if Value > MajorScale then
    raise Exception.Create('MinorScale should by lower than MajorScale')
  else if Value = MajorScale then
    raise Exception.Create('MinorScale should by different from MajorScale')
  else begin
    FMinorScale := Value;
    Invalidate;
  end;
end;

{
  Количество точек на единицу отображаемого времени устанавливаем.
}

procedure TGanttCalendar.SetPixelsPerMinorScale(const Value: Integer);
begin
  if Value < 10 then // Минимальный размер - 10 точек
    FPixelsPerMinorScale := 10
  else
    FPixelsPerMinorScale := Value;

  FGantt.UpdateInterval;
end;

{
  Устанавливаем кол-во точек на одну горизонтальную линию.
}

procedure TGanttCalendar.SetPixelsPerLine(const Value: Integer);
begin
{  if Value < 1 then // Минимальный размер - 1 точка
    FPixelsPerMinorScale := 1
  else
    FPixelsPerMinorScale := Value;}

  if Value < 1 then // Минимальный размер - 1 точка
    FPixelsPerLine := 1
  else
    FPixelsPerLine := Value;

  FGantt.UpdateInterval;
end;

{
  Дата начала просмотра.
}

procedure TGanttCalendar.SetStartDate(const Value: TDateTime);
begin
  FStartDate := Value;
  // Переносим на начало периода
  FVisibleStart := ClearToPeriodStart(MinorScale, FStartDate);
  Invalidate;
end;

{
  Окончание отображаемой части.
}

{DONE 5 -oDenis -cVisibleDate: Рассчитать окончание видимой части}
function TGanttCalendar.GetVisibleFinish: TDateTime;
begin
  Result := IncTime(VisibleStart, MinorScale, MinorVisibleUnits + 1);
end;

{
  Возвращает кол-во видимых элементов.
}

function TGanttCalendar.GetMinorVisibleUnitsCount: Integer;
begin
  Result := ClientWidth div PixelsPerMinorScale;
  Inc(Result, Integer(ClientWidth mod PixelsPerMinorScale <> 0));
end;

{
  Высота предыдущего элемента.
}

function TGanttCalendar.GetMajorScale: Integer;
begin
  Canvas.Font := Font;
  Result := Trunc(Canvas.TextHeight('A') * 1.5);
end;

{
  Высота последующего элемента.
}

function TGanttCalendar.GetMinorScale: Integer;
begin
  Canvas.Font := Font;
  Result := Trunc(Canvas.TextHeight('A') * 1.5);
end;

{
  Возвращает кол-во секунд
}

function TGanttCalendar.GetSeconds: Integer;
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(FCurrentDate, Hour, Min, Sec, MSec);
  Result := Sec;
end;

{
  Возвращает кол-во минут.
}

function TGanttCalendar.GetMinutes: Integer;
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(FCurrentDate, Hour, Min, Sec, MSec);
  Result := Min;
end;

{
  Возвращает кол-во часов.
}

function TGanttCalendar.GetHours: Integer;
var
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(FCurrentDate, Hour, Min, Sec, MSec);
  Result := Hour;
end;

{
  Возвращает кол-во дней.
}

function TGanttCalendar.GetDays: Integer;
var
  Year, Month, Day: Word;
begin
  DecodeDate(FCurrentDate, Year, Month, Day);
  Result := Day;
end;

{
  Возвращает день недели.
}

function TGanttCalendar.GetDayOfWeek: Integer;
var
  S: TTimeStamp;
begin
  S := DateTimeToTimeStamp(FCurrentDate);
  Result := (S.Date - 1) mod 7 + 1;
end;

{
  Возвращает кол-во недель.
}

function TGanttCalendar.GetWeeks: Integer;
var
  S: TTimeStamp;
begin
  S := DateTimeToTimeStamp(FCurrentDate);
  Result := (S.Date - 1) div 7;
end;

{
  Возвращает кол-во месяцев.
}

function TGanttCalendar.GetMonthes: Integer;
var
  Year, Month, Day: Word;
begin
  DecodeDate(FCurrentDate, Year, Month, Day);
  Result := Month;
end;

{
  Возвращает кол-во кварталов.
}

function TGanttCalendar.GetQuarters: Integer;
var
  Year, Month, Day: Word;
begin
  DecodeDate(FCurrentDate, Year, Month, Day);
  Result := Month div 3 + 1;
end;

{
  Возвращает кол-во полугодий.
}

function TGanttCalendar.GetHalfYears: Integer;
var
  Year, Month, Day: Word;
begin
  DecodeDate(FCurrentDate, Year, Month, Day);
  Result := Month div 6 + 1;
end;

{
  Возвращает кол-во лет.
}

function TGanttCalendar.GetYears: Integer;
var
  Year, Month, Day: Word;
begin
  DecodeDate(FCurrentDate, Year, Month, Day);
  Result := Year;
end;

{
  Возвращает время по указанной временной единице.
}

function TGanttCalendar.GetTimeUnitByScale(ATimeScale: TTimeScale): Integer;
begin
  case ATimeScale of
    tsMinute:
      Result := Minutes;
    tsHour:
      Result := Hours;
    tsDay:
      Result := Days;
    tsWeek:
      Result := Weeks;
    tsMonth:
      Result := Monthes;
    tsQuarter:
      Result := Quarters;
    tsHalfYear:
      Result := HalfYears;
    tsYear:
      Result := Years;
    else
      Result := 0;
  end;
end;

{
  Цвет верхней шкалы.
}

procedure TGanttCalendar.SetMajorColor(const Value: TColor);
begin
  FMajorColor := Value;
  Repaint;
end;

{
  Цвет нижней шкалы.
}

procedure TGanttCalendar.SetMinorColor(const Value: TColor);
begin
  FMinorColor := Value;
  Repaint;
end;

{
  Возвращает кол-во интервалов.
}

function TGanttCalendar.GetIntervalCount: Integer;
begin
  Result := FIntervals.Count;
end;

{
  Возвращает интервал по индексу.
}

function TGanttCalendar.GetInterval(AnIndex: Integer): TInterval;
begin
  Result := Fintervals[AnIndex];
end;

{
  Возвращает начальную координату по оси Y для рисования интервалов
}

function TGanttCalendar.GetStartDrawIntervals: Integer;
begin
  Result := MajorScaleHeight + MinorScaleHeight;
end;

{
  Возвращает высоту интервала.
}

function TGanttCalendar.GetIntervalHeight: Integer;
begin
  Result := PixelsPerLine;
end;

{
  Производит рисование линий заголовков.
}

{DONE 1 -oDenis -cHeader: Рисование шкалы}
procedure TGanttCalendar.DrawHeaderLines;
begin
  with Canvas do
  begin
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Color := clBlack;

    // Первый заголовок
    MoveTo(0, MajorScaleHeight);
    LineTo(ClientWidth, MajorScaleHeight);

    // Второй заголовок
    MoveTo(0, MajorScaleHeight + MinorScaleHeight);
    LineTo(ClientWidth, MajorScaleHeight + MinorScaleHeight);
  end;
end;

{
  Производит связь интервалов.
}

procedure TGanttCalendar.ConnectIntervals(FromInterval, ToInterval: TInterval);
var
  Plus: Integer;
  FromRect, ToRect: TRect;
begin
  with Canvas do
  begin
    Brush.Style := bsSolid;
    Brush.Color := clBlack;
    Pen.Color := clBlack;
    Pen.Style := psSolid;

    FromRect := FromInterval.DrawRect;
    ToRect := ToInterval.DrawRect;

    if ToInterval.IsCollection then
      ToRect.Left := ToRect.Left + 4;

    Plus := 3 * Integer((ToRect.Left - FromRect.Right) in [0, 1, 2]);

    MoveTo
    (
      FromRect.Right,
      FromRect.Top + (FromRect.Bottom - FromRect.Top) div 2
    );

    ////////////////////////////////////////////////////////////
    // Если начало связываемого периода раньше окончания данного

    if FromRect.Right > ToRect.Left + Plus then
    begin
      LineTo
      (
        FromRect.Right + 10,
        FromRect.Top + (FromRect.Bottom - FromRect.Top) div 2
      );

      LineTo
      (
        FromRect.Right + 10,
        FromRect.Top
          +
        (
          ToRect.Top + (ToRect.Bottom - ToRect.Top) div 2
            -
          FromRect.Top + (FromRect.Bottom - FromRect.Top) div 2
        )
          div
        2
      );

      LineTo
      (
        ToRect.Left - 10,
        FromRect.Top
          +
        (
          ToRect.Top + (ToRect.Bottom - ToRect.Top) div 2
            -
          FromRect.Top + (FromRect.Bottom - FromRect.Top) div 2
        )
          div
        2
      );

      LineTo
      (
        ToRect.Left - 10,
        ToRect.Top + (ToRect.Bottom - ToRect.Top) div 2
      );

      LineTo
      (
        ToRect.Left,
        ToRect.Top + (ToRect.Bottom - ToRect.Top) div 2
      );

      Polygon
      (
        [
          Point(ToRect.Left, ToRect.Top + (ToRect.Bottom - ToRect.Top) div 2),
          Point(ToRect.Left - 5, ToRect.Top + (ToRect.Bottom - ToRect.Top) div 2 + 5),
          Point(ToRect.Left - 5, ToRect.Top + (ToRect.Bottom - ToRect.Top) div 2 - 5),
          Point(ToRect.Left, ToRect.Top + (ToRect.Bottom - ToRect.Top) div 2)
        ]
      );
    end else begin

      ////////////////////////////
      // Если стандартная ситуация

      LineTo
      (
        ToRect.Left + Plus,
        FromRect.Top + (FromRect.Bottom - FromRect.Top) div 2
      );

      if FromRect.Top > ToRect.Top then
      begin
        LineTo
        (
          ToRect.Left + Plus,
          ToRect.Bottom + 6
        );

        Polygon
        (
          [
            Point(ToRect.Left + Plus, ToRect.Bottom + 6),
            Point(ToRect.Left + Plus - 5, ToRect.Bottom + 6),
            Point(ToRect.Left + Plus, ToRect.Bottom + 1),
            Point(ToRect.Left + Plus + 5, ToRect.Bottom + 6),
            Point(ToRect.Left + Plus, ToRect.Bottom + 6)
          ]
        );
      end else begin
        LineTo
        (
          ToRect.Left + Plus,
          ToRect.Top - 6
        );

        Polygon
        (
          [
            Point(ToRect.Left + Plus, ToRect.Top - 6),
            Point(ToRect.Left + Plus - 5, ToRect.Top - 6),
            Point(ToRect.Left + Plus, ToRect.Top - 1),
            Point(ToRect.Left + Plus + 5, ToRect.Top - 6),
            Point(ToRect.Left + Plus, ToRect.Top - 6)
          ]
        );
      end;
    end;
  end;
end;

{
  Производит рисование текущей нижней шкалы.
}

procedure TGanttCalendar.DrawMinorScale;
var
  R, TextR: TRect;
  OldTransparent: Integer;
begin
  with Canvas do
  begin
    if IsNewPeriod(MinorScale) then
    begin
      OldTransparent := SetBKMode(Handle, TRANSPARENT);

      R.Left := {Trunc}Round
        (
          UnitsBetweenDates(VisibleStart, FCurrentDate, MinorScale)
            *
          PixelsPerMinorScale
        );
      R.Right := R.Left + PixelsPerMinorScale;

      R.Top := MajorScaleHeight + 1;
      R.Bottom := MajorScaleHeight + MinorScaleHeight - 1;

      TextR := Rect(R.Left + 2, R.Top + 2, R.Right - 2, R.Bottom - 2);

      DrawTextEx
      (
        Handle,
        PChar(GetTimeScaleName(MinorScale, FCurrentDate, FGantt.Language)),
        -1,
        TextR,
        DT_LEFT or DT_VCENTER or DT_SINGLELINE,
        nil
      );

      SetBKMode(Handle, OldTransparent);

      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Color := clBlack;

      MoveTo(R.Left, MajorScaleHeight);
      LineTo(R.Left, MajorScaleHeight + MinorScaleHeight);
    end;
  end;
end;

{
  Производит рисование текущей верхней шкалы.
}

procedure TGanttCalendar.DrawMajorScale;
var
  OldTransparent: Integer;
  R: TRect;
  TextR: TRect;
begin
  with Canvas do
  begin
    OldTransparent := SetBKMode(Handle, TRANSPARENT);

    R.Left := {Trunc}Round
      (
        UnitsBetweenDates(VisibleStart, FCurrentDate, MinorScale)
          *
        PixelsPerMinorScale
      );
    R.Right := {Trunc}Round
      (
        UnitsBetweenDates(VisibleStart, IncTime(FCurrentDate, MajorScale, 1), MinorScale)
          *
        PixelsPerMinorScale
      );

    R.Top := 1;
    R.Bottom := MajorScaleHeight - 1;

    TextR := Rect(R.Left + 2, R.Top + 2, R.Right - 2, R.Bottom - 2);

    DrawTextEx
    (
      Handle,
      PChar(GetTimeScaleName(MajorScale, FCurrentDate, FGantt.Language)),
      -1,
      TextR,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_LEFT,
      nil
    );

    SetBKMode(Handle, OldTransparent);

    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Color := clBlack;

    MoveTo(R.Left, 0);
    LineTo(R.Left, MajorScaleHeight);

    // Рисуем линии до конца экрана
    Canvas.Pen.Style := psDot;
    Canvas.Pen.Color := clWhite;
    Canvas.Brush.Color := clBlack;

    MoveTo(R.Left, MajorScaleHeight + MinorScaleHeight);
    LineTo(R.Left, Height);
  end;
end;

{
  Начат ли новый период времени.
}

function TGanttCalendar.IsNewPeriod(AScale: TTimeScale; AUseSub: Boolean = False): Boolean;
begin
  case AScale of
    tsMinute:
      Result := Seconds = 0;
    tsHour:
      Result := (Minutes = 0) and (not AUseSub or AUseSub and IsNewPeriod(tsMinute, True));
    tsDay:
      Result := (Hours = 0) and (not AUseSub or AUseSub and IsNewPeriod(tsHour, True));
    tsWeek:
      Result := (DayOfWeek = 1) and (not AUseSub or AUseSub and IsNewPeriod(tsDay, True));
    tsMonth:
      Result := (Days = 1) and (not AUseSub or AUseSub and IsNewPeriod(tsDay, True));
    tsQuarter:
      Result := ((Monthes - 1) mod 3 = 0) and (not AUseSub or AUseSub and IsNewPeriod(tsMonth, True));
    tsHalfYear:
      Result := ((Monthes - 1) mod 6 = 0) and (not AUseSub or AUseSub and IsNewPeriod(tsMonth, True));
    tsYear:
      Result := (Monthes = 1) and (not AUseSub or AUseSub and IsNewPeriod(tsMonth, True));
    else
      Result := True;
  end;
end;

{
  Установка параметров для скроллбаров.
}

procedure TGanttCalendar.UpdateScrollbars;
begin
  // Пока работаем без вертикального скролла 
  if FVertScrollBar.Visible then
  begin
    RemoveControl(FVertScrollBar);
    FVertScrollBar.Enabled := False;
    FVertScrollBar.Visible := False;
  end;

  FHorzScrollBar.Enabled := True;
  FHorzScrollBar.OnScroll := DoOnHorzScroll;
end;

{
  Изменение позиции скроллбаров.
}

procedure TGanttCalendar.DoOnHorzScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
var
  R: TRect;
begin
  if
    (ScrollCode in [scLineUp, scPageUp, scEndScroll])
      and
    (ScrollPos = 0)
      and
    (FHorzScrollBar.Position = 0)
  then begin // Если нужен просмотр до начала указанного периода
    if ScrollCode = scLineUp then
    begin
      FVisibleStart := ClearToPeriodStart(MinorScale, IncTime(FVisibleStart, MinorScale, -1));
      Inc(FBeforeStartDateCount);

      R := Rect
      (
        0,
        0,
        Width - FVertScrollBar.Width * Integer(FVertScrollBar.Visible),
        Height - FHorzScrollBar.Height * Integer(FHorzScrollBar.Visible)
      );

      InvalidateRect(Handle, @R, True);
    end;
  end else begin
    // Если прокрутка по периоду
    if ClearToPeriodStart(MinorScale, FStartDate) > FVisibleStart then
    begin
      FVisibleStart := ClearToPeriodStart(MinorScale, IncTime(FVisibleStart, MinorScale, ScrollPos));
      ScrollPos := ScrollPos - FBeforeStartDateCount;

      if ScrollPos < 0 then
      begin
        FBeforeStartDateCount := Abs(ScrollPos);
        ScrollPos := 0;
      end;
    end else begin
      FVisibleStart := ClearToPeriodStart(MinorScale, IncTime(FStartDate, MinorScale, ScrollPos));
      FBeforeStartDateCount := 0;
    end;

    if (ScrollCode <> scTrack) and (ScrollCode <> scEndScroll) then
    begin
      R := Rect
      (
        0,
        0,
        Width - FVertScrollBar.Width * Integer(FVertScrollBar.Visible),
        Height - FHorzScrollBar.Height * Integer(FHorzScrollBar.Visible)
      );

      InvalidateRect(Handle, @R, True);
    end;

    // Если достигнут предел
    if
      (
        (ScrollCode = scPosition)
          and
        (FHorzScrollBar.Max - SCROLL_MAXSTEP < ScrollPos)
      )
        or
      (
        (ScrollCode in [scLineDown, scPageDown, scBottom])
          and
        (FHorzScrollBar.Max = ScrollPos)
      )
    then begin
      FHorzScrollBar.Max := FHorzScrollBar.Max + SCROLL_MAXSTEP;
      ScrollPos := FHorzScrollBar.Max - SCROLL_MAXSTEP;
    end else if
      (ScrollPos <= FHorzScrollBar.Max - SCROLL_MAXSTEP)
        and
      (ScrollCode in [scLineUp, scPageUp, scPosition, scTop])
    then begin
      if ScrollPos > SCROLL_MAX then
        FHorzScrollBar.Max := FHorzScrollBar.Position
      else
        FHorzScrollBar.Max := SCROLL_MAX;
    end;
  end;
end;

{
  Рассчитывает координаты скроллбаров.
}

procedure TGanttCalendar.WMSize(var Message: TWMSize);
begin
  UpdateScrollbars;

  if FVertScrollBar.Visible then
  begin
    if FHorzScrollBar.Visible then
      SetWindowPos
      (
        FVertScrollBar.Handle,
        0,
        Width - FVertScrollBar.Width,
        0,
        FVertScrollBar.Width,
        Height - FHorzScrollBar.Height,
        SWP_SHOWWINDOW or SWP_NOZORDER or  SWP_NOSENDCHANGING or SWP_NOACTIVATE
      )
    else
      SetWindowPos
      (
        FVertScrollBar.Handle,
        0,
        Width - FVertScrollBar.Width,
        0,
        FVertScrollBar.Width,
        Height,
        SWP_SHOWWINDOW or SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE
      );
  end;

  if FHorzScrollBar.Visible then
  begin
    if FVertScrollBar.Visible then
      SetWindowPos
      (
        FHorzScrollBar.Handle,
        0,
        0,
        Height - FHorzScrollBar.Height,
        Width - FVertScrollBar.Width,
        FHorzScrollBar.Height,
        SWP_SHOWWINDOW or SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE
      )
    else
      SetWindowPos
      (
        FHorzScrollBar.Handle,
        0,
        0,
        Height - FHorzScrollBar.Height,
        Width,
        FHorzScrollBar.Height,
        SWP_SHOWWINDOW or SWP_NOZORDER or SWP_NOSENDCHANGING or SWP_NOACTIVATE
      );
  end;

  inherited;
end;

{
  Курсор входит в область компоненты.
}

procedure TGanttCalendar.CMMouseEnter(var Message: TMessage);
begin
  inherited;
end;

{
  Курсор выходит из области компоненты.
}

procedure TGanttCalendar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
end;

{
  Курсор движется в области компоненты.
}

{DONE 3 -oDenis -cMouseMoving: Движение мыши по области рисования}
procedure TGanttCalendar.WMMouseMove(var Message: TWMMouseMove);
var
  List: TList;
  CurrInterval: TInterval;
  I: Integer;
  Found: Boolean;
begin
  List := TList.Create;
  try
    FGantt.MakeIntervalList(List);

    // Если изменение периода еще не начато, то подготавливаем курсор
    if not FDragStarted then
    begin
      Found := False;

      for I := 0 to List.Count - 1 do
      begin
        CurrInterval := List[I];

        // Со списками интервалов не работаем
        if CurrInterval.IsCollection then Continue;

        // Если курсор находится в данном интервале, то работаем над выбором интервала
        if IsInRect(Message.XPos,  Message.YPos, CurrInterval.DrawRect) then
        begin
          // Если входит в область изменения процента выполнения
          if
            (CurrInterval.IntervalType = itPeriod)
              and
            IsInRect(Message.XPos,  Message.YPos, CurrInterval.PercentMoveRect)
          then begin
            Cursor := crGanttPercent;
            FDragType := ditPercent;
            FDragRect := CurrInterval.DoneRect;
          // Если входит в область сдвига периода влево
          end else if
            (CurrInterval.IntervalType = itPeriod)
              and
            IsInRect(Message.XPos,  Message.YPos, CurrInterval.LeftMoveRect)
          then begin
            Cursor := crGanttLeftMove;
            FDragType := ditLeftMove;
            FDragRect := CurrInterval.DrawRect;
          // Если входит в область сдвига периода вправо
          end else if
            (CurrInterval.IntervalType = itPeriod)
              and
            IsInRect(Message.XPos,  Message.YPos, CurrInterval.RightMoveRect)
          then begin
            Cursor := crGanttRightMove;
            FDragType := ditRightMove;
            FDragRect := CurrInterval.DrawRect;
          end else begin // В другом случае - область для сдвига всего периода
            Cursor := crGanttMiddle;
            FDragType := ditMiddle;
            FDragRect := CurrInterval.DrawRect;
          end;

          Found := True;
          FDragInterval := CurrInterval;
          FDragStarted := False;
          Break;
        end;
      end;

      if not Found then
      begin
        Cursor := crDefault;
        FDragInterval := nil;
        FDragType := ditNone;
        FDragRect := Rect(-1, -1, -1, -1);
        FDragStarted := False;
      end;
    // Если изменение интервала начато, то работаем с ним
    end else if Assigned(FDragInterval) and (FDragType <> ditNone) and FDragStarted then
    begin
      Canvas.Brush.Color := clWhite;
      Canvas.DrawFocusRect(FDragRect);
      Canvas.Brush.Color := clBlue;
      Canvas.DrawFocusRect(
        Rect(FDragRect.Left + 1, FDragRect.Top + 1, FDragRect.Right - 1, FDragRect.Bottom - 1));

      case FDragType of
        ditMiddle:
        begin
          if (Message.YPos < FDragRect.Top) or (Message.YPos > FDragRect.Bottom) then
          begin
            FDragType := ditConnect;
            Screen.Cursor := crGanttConnect;
            //Cursor := crGanttConnect;
            FDragRect := FDragInterval.DrawRect;
          end else begin
            FDragRect := Rect
            (
              Message.XPos - FFromDragPoint,
              FDragRect.Top,
              Message.XPos - FFromDragPoint + FDragRect.Right - FDragRect.Left,
              FDragRect.Bottom
            );
          end;  
        end;
        ditRightMove:
          FDragRect.Right := Message.XPos;
        ditLeftMove:
          FDragRect.Left := Message.XPos;
        ditPercent:
        begin
          if FDragInterval.DrawRect.Right < Message.XPos then
            FDragRect.Right := FDragInterval.DrawRect.Right
          else
            FDragRect.Right := Message.XPos;
        end;
        ditConnect:
        begin
          Canvas.Brush.Color := clWhite;
          Canvas.Pen.Style := psSolid;
          Canvas.Pen.Mode := pmNotXor;
          Canvas.MoveTo(FConnectFromPoint.X, FConnectFromPoint.Y);
          Canvas.LineTo(FConnectToPoint.X, FConnectToPoint.Y);

          FConnectToPoint := Point(Message.XPos, Message.YPos);
          Canvas.Pen.Mode := pmNotXor;
          Canvas.MoveTo(FConnectFromPoint.X, FConnectFromPoint.Y);
          Canvas.LineTo(FConnectToPoint.X, FConnectToPoint.Y);
          Canvas.Pen.Mode := pmCopy;

          if FConnectInterval <> nil then
          begin
            Canvas.Brush.Color := clWhite;
            Canvas.DrawFocusRect(FConnectInterval.DrawRect);
            Canvas.Brush.Color := clBlue;
            Canvas.DrawFocusRect(
              Rect(
                FConnectInterval.DrawRect.Left + 1,
                FConnectInterval.DrawRect.Top + 1,
                FConnectInterval.DrawRect.Right - 1,
                FConnectInterval.DrawRect.Bottom - 1
              )
            );
          end;

          FConnectInterval := nil;

          for I := 0 to List.Count - 1 do
          begin
            CurrInterval := List[I];
            if CurrInterval = FDragInterval then Continue;

            // Если курсор находится в данном интервале, то работаем над выбором интервала
            if IsInRect(Message.XPos,  Message.YPos, CurrInterval.DrawRect) then
            begin
              FConnectInterval := CurrInterval;
              Break;
            end;
          end;

          if FConnectInterval <> nil then
          begin
            Canvas.Brush.Color := clWhite;
            Canvas.DrawFocusRect(FConnectInterval.DrawRect);
            Canvas.Brush.Color := clBlue;
            Canvas.DrawFocusRect(
              Rect(
                FConnectInterval.DrawRect.Left + 1,
                FConnectInterval.DrawRect.Top + 1,
                FConnectInterval.DrawRect.Right - 1,
                FConnectInterval.DrawRect.Bottom - 1
              ));
          end;
        end;
      end;

      Canvas.Brush.Color := clWhite;
      Canvas.DrawFocusRect(FDragRect);
      Canvas.Brush.Color := clBlue;
      Canvas.DrawFocusRect(
        Rect(FDragRect.Left + 1, FDragRect.Top + 1, FDragRect.Right - 1, FDragRect.Bottom - 1));
    end;
  finally
    List.Free;
  end;
  inherited;
end;

{
  Начинаем изменение периода.
}

procedure TGanttCalendar.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if Assigned(FDragInterval) and (FDragType <> ditNone) and not FDragStarted then
  begin
    FDragStarted := True;
    FFromDragPoint := Message.XPos - FDragRect.Left;

    FConnectFromPoint := Point(Message.XPos, Message.YPos);
    FConnectToPoint := Point(Message.XPos, Message.YPos);

    Canvas.Brush.Color := clWhite;
    Canvas.DrawFocusRect(FDragRect);
    Canvas.Brush.Color := clBlue;
    Canvas.DrawFocusRect(
      Rect(FDragRect.Left + 1, FDragRect.Top + 1, FDragRect.Right - 1, FDragRect.Bottom - 1));
  end;

  inherited;
end;

{
  Заканчиваем изменение периода.
}

procedure TGanttCalendar.WMLButtonUp(var Message: TWMRButtonDown);
var
  NewDate: TDateTime;
  R: TRect;
  I: Integer;
begin
  if Assigned(FDragInterval) and (FDragType <> ditNone) and FDragStarted then
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.DrawFocusRect(FDragRect);
    Canvas.Brush.Color := clBlue;
    Canvas.DrawFocusRect(
      Rect(FDragRect.Left + 1, FDragRect.Top + 1, FDragRect.Right - 1, FDragRect.Bottom - 1));

    case FDragType of
      ditMiddle:
      begin
        if FDragInterval.IntervalType = itPeriod then
        begin
          R := FDragInterval.DoneRect;

          FDragInterval.StartDate :=
            IncTimeEx(VisibleStart, MinorScale, FDragRect.Left / PixelsPerMinorScale);

          FDragInterval.FinishDate :=
            IncTimeEx(VisibleStart, MinorScale, FDragRect.Right / PixelsPerMinorScale);

          FDragInterval.IntervalDone :=
            IncTimeEx
            (
              VisibleStart,
              MinorScale,
              (FDragRect.Left + (R.Right - R.Left)) / PixelsPerMinorScale
            );
        end else begin
          FDragInterval.StartDate :=
            IncTimeEx(
              VisibleStart,
              MinorScale,
              (FDragRect.Left + (FDragRect.Right - FDragRect.Left) div 2) / PixelsPerMinorScale);

          FDragInterval.FinishDate := FDragInterval.StartDate;
        end;
      end;
      ditRightMove:
      begin
        NewDate :=
          IncTimeEx(VisibleStart, MinorScale, FDragRect.Right / PixelsPerMinorScale);

        if FDragInterval.StartDate > NewDate then
          FDragInterval.FinishDate := FDragInterval.StartDate
        else
          FDragInterval.FinishDate := NewDate;
      end;
      ditLeftMove:
      begin
        NewDate :=
          IncTimeEx(VisibleStart, MinorScale, FDragRect.Left / PixelsPerMinorScale);

        if FDragInterval.FinishDate < NewDate then
        begin
          FDragInterval.StartDate := FDragInterval.FinishDate;
        end else
          FDragInterval.StartDate := NewDate;
      end;
      ditPercent:
      begin
        FDragInterval.IntervalDone :=
          IncTimeEx(VisibleStart, MinorScale, FDragRect.Right / PixelsPerMinorScale);
      end;
      ditConnect:
      begin
        // Если есть связь, то добавляем ее
        if FConnectInterval <> nil then
        begin
          for I := 0 to IntervalCount - 1 do
            Interval[I].PrepareToUpdate;

          FDragInterval.AddConnection(FConnectInterval);
        end;
      end;
    end;

    Cursor := crDefault;
    Screen.Cursor := crDefault;

    FConnectInterval := nil;
    FConnectFromPoint := Point(-1, -1);
    FConnectToPoint := Point(-1, -1);
    FDragInterval := nil;
    FDragType := ditNone;
    FDragStarted := False;
    FFromDragPoint := 0;
    FDragRect := Rect(-1, -1, -1, -1);

    FGantt.UpdateInterval;
  end;

  inherited;
end;

{
  ----------------------------------------
  ------                            ------
  ------      TGanttTree Class      ------
  ------                            ------
  ----------------------------------------
}

{TGanttTree}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TGanttTree.Create(AnOwner: TgsGantt);
begin
  inherited Create(AnOwner);

  // Присваиваем родителей и др.
  FGantt := AnOwner;
  FIntervals := FGantt.FIntervals;

  // Общие интерфейсные установки
  ParentCtl3d := False;
  Ctl3d := False;
  BorderStyle := bsNone;
  DefaultDrawing := False;

  // Первоначальное кол-во колонок и строк
  ColCount := 8;
  RowCount := 100;
  // Высота и ширина по умолчанию для ячеек
  DefaultColWidth := 40;
  DefaultRowHeight := 24;

  // Значение расстояния между интервалами по умолчанию
  FIndent := 10;

  // Общие установки для таблицы
  Options :=
  [
    goFixedVertLine, goFixedHorzLine, goVertLine,
    goHorzLine, {goEditing,} goColSizing
  ];

  // Создаем шрифт для ветвей
  FBranchFont := TFont.Create;
  FBranchFont.Name := 'Tahoma';
  FBranchFont.Charset := RUSSIAN_CHARSET;
  FBranchFont.Size := 8;
  FBranchFont.Style := [fsBold];

  // Шрифт для обычных записей
  Font.Name := 'Tahoma';
  Font.Charset := RUSSIAN_CHARSET;
  Font.Size := 8;
  Font.Style := [];

  FEditInterval := nil;

  // Контролы для редактирования информации
  if not (csDesigning in ComponentState) then
  begin
    FTextEdit := TEdit.Create(Owner);
    (Owner as TWinControl).InsertControl(FTextEdit);
    FTextEdit.Ctl3D := False;
    FTextEdit.BorderStyle := bsNone;
    FTextEdit.Visible := False;
    FTextEdit.OnKeyPress := OnEditKeyPress;
    FTextEdit.OnExit := OnEditExit;

    FDurationEdit := TxSpinEdit.Create(Owner);
    (Owner as TWinControl).InsertControl(FDurationEdit);
    FDurationEdit.Visible := False;
    FDurationEdit.OnExit := OnEditExit;

    FDateEdit := TDateTimePicker.Create(Owner);
    (Owner as TWinControl).InsertControl(FDateEdit);
    FDateEdit.Visible := False;
    FDateEdit.OnExit := OnEditExit;

    FComboEdit := TComboBox.Create(Owner);
    (Owner as TWinControl).InsertControl(FComboEdit);
    FComboEdit.Visible := False;
    FComboEdit.OnExit := OnEditExit;

    FUpDown := TUpDown.Create(Owner);
    (Owner as TWinControl).InsertControl(FUpDown);
    FUpDown.Visible := False;
    FUpDown.OnExit := OnEditExit;
    FUpDown.OnClick := OnUpDownButtonClick;

    FMonthCalendar := TgsMonthCalendar.Create(Owner);
    (Owner as TWinControl).InsertControl(FMonthCalendar);
    FMonthCalendar.Visible := False;
    FMonthCalendar.AutoSize := True;
    FMonthCalendar.OnExit := OnEditExit;
    FMonthCalendar.BorderWidth := 1;
    FMonthCalendar.CalColors.BackColor := clBlack;
    FMonthCalendar.OnSelectDate := OnMonthCalendarClick;

    FDownButton := TSpeedButton.Create(Self);
    FDownButton.GroupIndex := 1;
    FDownButton.AllowAllUp := True;
    InsertControl(FDownButton);
    FDownButton.Visible := False;
    FDownButton.Glyph.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_COMBO));
    FDownButton.OnClick := OnDownButtonClick;
  end else begin
    FTextEdit := nil;
    FDurationEdit := nil;
    FDateEdit := nil;
    FComboEdit := nil;
    FUpDown := nil;
    FMonthCalendar := nil;
    FDownButton := nil;
  end;
end;

{
  Высвобождаем память.
}

destructor TGanttTree.Destroy;
begin
  FBranchFont.Free;

  inherited Destroy;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}


{
  После создания окна делаем свои установки.
}

procedure TGanttTree.CreateWnd;
begin
  inherited CreateWnd;
  // Производим общие установки для окна
  if not (csDesigning in ComponentState) then
    UpdateCommonSettings;
end;

{
  Производит рисование ячеек.
}

procedure TGanttTree.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
var
  CurrInterval: TInterval;
  DeltaX: Integer;
  Stamp: TTimeStamp;
  S: String;
begin
  inherited DrawCell(ACol, ARow, ARect, AState);
  if csDesigning in ComponentState then Exit;

  with Canvas do
  begin
    if gdFixed in AState then
    begin
      /////////////////////////////
      // Рисование заглавий колонок

      Brush.Color := FixedColor;
      Canvas.Font := Self.Font;

      WriteText(Canvas, ARect, 2, (ARect.Bottom - ARect.Top - TextHeight('A')) div 2,
        Cells[ACol, ARow], taCenter, True);

    end else begin
      /////////////////////////
      // Рисование ячеек дерева

      Brush.Color := Color;
      CurrInterval := TInterval(Objects[0, ARow]);

      // Устаналвиаем шрифт для ветви
      if (CurrInterval <> nil) and CurrInterval.IsCollection then
        Canvas.Font := FBranchFont
      else
        Canvas.Font := Self.Font;

      ///////////////////////////////////////////////////////////
      // Если ячейка задания, то в ней необходимо рисовать дерево

      if GetColumnType(ACol) = gctTask then
      begin

        /////////////////////
        // Если интервал есть

        if CurrInterval <> nil then
        begin
          DeltaX := (CurrInterval.Level - 1) * FIndent + 14;

          WriteText
          (
            Canvas,
            ARect,
            DeltaX + 2,
            (ARect.Bottom - ARect.Top - TextHeight('A')) div 2,
            CurrInterval.Task,
            taLeftJustify,
            True
          );

          if CurrInterval.IsCollection then
          begin
            if CurrInterval.Opened then
              DrawMinus
              (
                ARect.Left + DeltaX - 9,
                ARect.Top + (ARect.Bottom - ARect.Top) div 2 - 5
              )
            else
              DrawPlus
              (
                ARect.Left + DeltaX - 9,
                ARect.Top + (ARect.Bottom - ARect.Top) div 2 - 5
              );
          end;
        end else // Если его нет - рисуем пустуя область
          FillRect(ARect);
      end else if
        (GetColumnType(ACol) = gctDuration)
          and
        (CurrInterval <> nil)
      then begin
        Stamp := CurrInterval.StampDuration;
        S := IntToStr(Stamp.Date);

        {if StrToInt(S[Length(S)]) = 1 then
          S := S + ' день'
        else if
          (StrToInt(S[Length(S)]) in [2, 3, 4])
            and not
          (Stamp.Date in [12, 13, 14])
        then
          S := S + ' дня'
        else
          S := S + ' дней';}

        if FGantt.Language = glRussian then
          S := S + ' дн.'
        else
          S := S + ' day(s)';

        WriteText
        (
          Canvas,
          ARect,
          2,
          (ARect.Bottom - ARect.Top - TextHeight('A')) div 2,
          S,
          taLeftJustify,
          True
        );
      end else if
        (GetColumnType(ACol) = gctStart)
          and
        (CurrInterval <> nil)
      then begin
        WriteText
        (
          Canvas,
          ARect,
          2,
          (ARect.Bottom - ARect.Top - TextHeight('A')) div 2,
          DateToStr(CurrInterval.StartDate),
          taLeftJustify,
          True
        );
      end else if
        (GetColumnType(ACol) = gctFinish)
          and
        (CurrInterval <> nil)
      then begin
        WriteText
        (
          Canvas,
          ARect,
          2,
          (ARect.Bottom - ARect.Top - TextHeight('A')) div 2,
          DateToStr(CurrInterval.FinishDate),
          taLeftJustify,
          True
        );
      end else
        FillRect(ARect);

      //////////////////////////////////////////
      // Рисуем обрамление, если ячейка выделена


      if gdSelected in AState then
      begin
        Brush.Color := clBlack;
        FrameRect(ARect);
        FrameRect(Rect(ARect.Left + 1, ARect.Top + 1, ARect.Right - 1, ARect.Bottom - 1));
      end;
    end;
  end;
end;

{
  Нажатие кнопки мыши. Производим открытие или зарытие периодов.
}

procedure TGanttTree.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  CurrInterval: TInterval;
  R: TRect;
  ACol, ARow: Integer;
begin
  if csDesigning in ComponentState then Exit;

  MouseToCell(X, Y, ACol, ARow);
  R := CellRect(ACol, ARow);
  CurrInterval := TInterval(Objects[0, ARow]);

  ////////////////////////////////
  // Если нажата левая кнопка мыши
  // в плюсике или минусике

  if
    (Button = mbLeft)
      and
    (GetColumnType(ACol) = gctTask)
      and
    (CurrInterval <> nil)
  then begin
    R.Left := R.Left + (CurrInterval.Level - 1) * FIndent + 5;
    R.Right := R.Left + 9;
    R.Top := R.Top + (R.Bottom - R.Top) div 2 - 5;
    R.Bottom := R.Top + 9;

    if IsInRect(X, Y, R) then
    begin
      CurrInterval.Opened := not CurrInterval.Opened;
      FGantt.UpdateInterval;
    end else begin
      ///////////////////////////////////
      // Вызываем редактирование названия

      if (ACol = Col) and (ARow = Row) then
      begin
        ShowTaskEditor;
      end else
        inherited MouseDown(Button, Shift, X, Y);
    end;
  end else
    inherited MouseDown(Button, Shift, X, Y);
end;

{
  Выделяет определенную ячейку.
}

function TGanttTree.SelectCell(ACol, ARow: Longint): Boolean;
begin
  Result := inherited SelectCell(ACol, ARow);

  if not (csDesigning in ComponentState) then
  begin
    if Result then
      UpdateCurrentControl(ACol, ARow)
    else
      UpdateCurrentControl(Col, Row);
  end;    
end;

{
  Изменился индекс верхней или левой ячейки.
}

procedure TGanttTree.TopLeftChanged;
begin
  inherited TopLeftChanged;

  if not (csDesigning in ComponentState) then
    UpdateCurrentControl(Col, Row);
end;

{
  Изменились размеры колонок
}

procedure TGanttTree.ColWidthsChanged;
begin
  inherited ColWidthsChanged;

  if not (csDesigning in ComponentState) then
  begin
    if Parent <> nil then
      UpdateCurrentControl(Col, Row);
  end;    
end;

{
  Производит автоматическое скрывание контролов.
}

procedure TGanttTree.DoExit;
begin
  if not (csDesigning in ComponentState) then
  begin
    FMonthCalendar.Visible := False;
    FDownButton.Down := False;
  end;  

  inherited DoExit;
end;

{
  Обновляем общие установки ячеек.
}

procedure TGanttTree.UpdateCommonSettings;
var
  I: Integer;
begin
  ////////////////
  // Длины колонок

  DefaultRowHeight := FGantt.Calendar.PixelsPerLine;

  RowHeights[0] :=
    FGantt.Calendar.MajorScaleHeight
      +
    FGantt.Calendar.MajorScaleHeight;

  // № п/п
  if FGantt.Language = glRussian then
  begin
    Cells[0, 0] := '№';
    ColWidths[0] := 28;
    // Информация
    Cells[1, 0] := 'Инфо.';
    ColWidths[1] := 37;
    // Название ветви
    Cells[2, 0] := 'Задание';
    ColWidths[2] := 115;
    // Продолжительность
    Cells[3, 0] := 'Время';
    ColWidths[3] := 55;
    // Начало промежутка
    Cells[4, 0] := 'Начало';
    ColWidths[4] := 73;
    // Окончание промежутка
    Cells[5, 0] := 'Окончание';
    ColWidths[5] := 73;
    // Список связей
    Cells[6, 0] := 'Связи';
    ColWidths[6] := 85;
    // Список ресурсов выполнения
    Cells[7, 0] := 'Ресурсы';
    ColWidths[7] := 85;
  end else begin
    Cells[0, 0] := 'Num';
    ColWidths[0] := 28;
    // Информация
    Cells[1, 0] := 'Info';
    ColWidths[1] := 37;
    // Название ветви
    Cells[2, 0] := 'Task';
    ColWidths[2] := 115;
    // Продолжительность
    Cells[3, 0] := 'Time';
    ColWidths[3] := 55;
    // Начало промежутка
    Cells[4, 0] := 'Start';
    ColWidths[4] := 73;
    // Окончание промежутка
    Cells[5, 0] := 'Finish';
    ColWidths[5] := 73;
    // Список связей
    Cells[6, 0] := 'Ties';
    ColWidths[6] := 85;
    // Список ресурсов выполнения
    Cells[7, 0] := 'Resourses';
    ColWidths[7] := 85;
  end;

  for I := 1 to RowCount - 1 do
    Cells[0, I] := IntToStr(I);

  UpdateTreeList;
end;

{
  Подставляем объекты видимых элементов в дерево.
}

procedure TGanttTree.UpdateTreeList;
var
  List: TList;
  I: Integer;
begin
  List := TList.Create;

  try
    FGantt.MakeIntervalList(List);

    if RowCount < List.Count + 1 then
      RowCount := List.Count + 1;

    for I := 0 to List.Count - 1 do
      Objects[0, I + 1] := List[I];

    for I := List.Count + 1 to RowCount - 1 do
      Objects[0, I] := nil;
  finally
    List.Free;
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

function TGanttTree.GetColumnType(AnIndex: Integer): TGanttColumnType;
begin
  case AnIndex of
    1: Result := gctInfo;
    2: Result := gctTask;
    3: Result := gctDuration;
    4: Result := gctStart;
    5: Result := gctFinish;
    6: Result := gctConnection;
    7: Result := gctResources;
  else
    Result := gctNone;
  end;
end;

{
  Устатавливает расстояние между ветвями.
}

procedure TGanttTree.SetIndent(const Value: Integer);
begin
  FIndent := Value;
  Repaint;
end;

{
  Рисует плюс.
}

procedure TGanttTree.DrawMinus(X, Y: Integer);
var
  OldBrushColor, OldPenColor: TColor;
begin
  with Canvas do
  begin
    OldBrushColor := Brush.Color;
    OldPenColor := Pen.Color;

    Pen.Style := psSolid;
    Pen.Color := clGray;
    Brush.Color := clGray;
    FrameRect(Rect(X, Y, X + 9, Y + 9));

    Pen.Color := clBlack;
    MoveTo(X + 2, Y + 4);
    LineTo(X + 7, Y + 4);

    Brush.Color := OldBrushColor;
    Pen.Color := OldPenColor;
  end;
end;

{
  Рисует минус
}

procedure TGanttTree.DrawPlus(X, Y: Integer);
var
  OldBrushColor, OldPenColor: TColor;
begin
  with Canvas do
  begin
    OldBrushColor := Brush.Color;
    OldPenColor := Pen.Color;

    Pen.Color := clGray;
    Brush.Color := clGray;

    FrameRect(Rect(X, Y, X + 9, Y + 9));

    Pen.Color := clBlack;
    MoveTo(X + 2, Y + 4);
    LineTo(X + 7, Y + 4);

    MoveTo(X + 4, Y + 2);
    LineTo(X + 4, Y + 7);

    Brush.Color := OldBrushColor;
    Pen.Color := OldPenColor;
  end;
end;

{
  Возвращает шрифт ветви.
}

function TGanttTree.GetBrachFont: TFont;
begin
  Result := FBranchFont;
end;

{
  Устанавливает шрифт ветви.
}

procedure TGanttTree.SetBranchFont(const Value: TFont);
begin
  FBranchFont.Assign(Value);
end;

{
  Нажатие клавиши в активированном контроле
  редактирования.
}

procedure TGanttTree.OnEditKeyPress(Sender: TObject; var Key: Char);
var
  R: TRect;
  CurrInterval: TInterval;
begin
  R := CellRect(Col, Row);
  CurrInterval := TInterval(Objects[0, Row]);

  case Ord(Key) of
    VK_ESCAPE:
    begin
      FTextEdit.Visible := False;
      Key := #0;
      SetFocus;
    end;
    VK_RETURN:
    begin
      CurrInterval.Task := FTextEdit.Text;
      FTextEdit.Visible := False;
      Key := #0;
      SetFocus;
    end;
  end;
end;

{
  Во потере фокуса в контроле редактирования.
}

procedure TGanttTree.OnEditExit(Sender: TObject);
begin
  if Sender = FTextEdit then
  begin
    if FTextEdit.Visible and Assigned(FEditInterval) then
    begin
      FEditInterval.Task := FTextEdit.Text;
      FEditInterval := nil;
      FTextEdit.Visible := False;
    end;
  end;
end;

{
  Нажатие кнопки вызова календаря.
}

procedure TGanttTree.OnDownButtonClick(Sender: TObject);
var
  R: TRect;
  CurrInterval: TInterval;
begin
  SetFocus;
  R := CellRect(Col, Row);
  CurrInterval := TInterval(Objects[0, Row]);

  if FDownButton.Down then
  begin
    if GetColumnType(Col) = gctStart then
    begin
      FMonthCalendar.MinDate := EncodeDate(1900, 01, 01);
      FMonthCalendar.MaxDate := CurrInterval.FinishDate;
      FMonthCalendar.DateTime := CurrInterval.StartDate;
    end else begin
      FMonthCalendar.MinDate := CurrInterval.StartDate;
      FMonthCalendar.MaxDate := EncodeDate(9000, 01, 01);
      FMonthCalendar.DateTime := CurrInterval.FinishDate;
    end;

    FMonthCalendar.SendToBack;
    FMonthCalendar.Visible := True;
    FMonthCalendar.Left := R.Right - FMonthCalendar.Width;
    FMonthCalendar.Top := R.Bottom;
    FMonthCalendar.BringToFront;
  end else
    FMonthCalendar.Visible := False;
end;

{
  По нажатию календаря производим изменение временных установок.
}

procedure TGanttTree.OnMonthCalendarClick(Sender: TObject);
var
  CurrInterval: TInterval;
begin
  CurrInterval := TInterval(Objects[0, Row]);

  if CurrInterval <> nil then
  begin
    if GetColumnType(Col) = gctStart then
    begin
      CurrInterval.StartDate := FMonthCalendar.DateTime;
    end else begin
      CurrInterval.FinishDate := FMonthCalendar.DateTime;
    end;

    FGantt.UpdateInterval;
  end;

  FMonthCalendar.Visible := False;
  FDownButton.Down := False;
end;

{
  Нажатие кнопки увеличения, уменьшения продолжительности.
}

procedure TGanttTree.OnUpDownButtonClick(Sender: TObject; Button: TUDBtnType);
var
  CurrInterval: TInterval;
begin
  CurrInterval := TInterval(Objects[0, Row]);

  if CurrInterval <> nil then
  begin
    if Button = btNext then
    begin
      CurrInterval.Duration := CurrInterval.Duration + 1;
    end else begin
      if CurrInterval.StampDuration.Date > 0 then
        CurrInterval.Duration := CurrInterval.Duration - 1;
    end;

    FGantt.UpdateInterval;
  end;
end;

{
  Производит обновлениесостояния контролов.
}

procedure TGanttTree.UpdateCurrentControl(ACol, ARow: Integer);
var
  R: TRect;
  CurrInterval: TInterval;

  procedure HideAllControls;
  begin
    FTextEdit.Hide;
    FDurationEdit.Hide;
    FDateEdit.Hide;
    FComboEdit.Hide;
    FUpDown.Hide;
    FMonthCalendar.Hide;
    FDownButton.Hide;
    FDownButton.Down := False;
    SetFocus;
  end;

begin
  R := CellRect(ACol, ARow);
  CurrInterval := TInterval(Objects[0, ARow]);

  if FTextEdit.Visible and Assigned(FEditInterval) then
    FEditInterval.Task := FTextEdit.Text;

  FEditInterval := nil;
  HideAllControls;

  case GetColumnType(ACol) of
    gctDuration:
    begin
      FUpDown.Min := 0;
      FUpDown.Max := 32767;

      if CurrInterval <> nil then
      begin
        FUpDown.Position := CurrInterval.StampDuration.Date;
        FUpDown.Enabled := not CurrInterval.IsCollection;
      end else begin
        FUpDown.Position := 0;
        FUpDown.Enabled := False;
      end;

      FUpDown.Height := R.Bottom - R.Top - 4;
      FUpDown.Width := 16;
      FUpDown.Left := R.Right - 16 - 2;
      FUpDown.Top := R.Top + 2;
      FUpDown.Visible := True;
      FUpDown.BringToFront;

      FEditInterval := CurrInterval;
    end;
    gctStart, gctFinish:
    begin
      if CurrInterval <> nil then
      begin
        FDownButton.Enabled := not CurrInterval.IsCollection;
        FEditInterval := CurrInterval;
      end else begin
        FDownButton.Enabled := False;
        FEditInterval := nil;
      end;

      FDownButton.Height := R.Bottom - R.Top - 4;
      FDownButton.Width := 16;
      FDownButton.Left := R.Right - 16 - 2;
      FDownButton.Top := R.Top + 2;
      FDownButton.Visible := True;
      FDownButton.BringToFront;
    end;
    else begin
      HideAllControls;
      FEditInterval := nil;
    end;
  end;
end;

{
  Показывает редактор текста названия промежутка.
}

procedure TGanttTree.ShowTaskEditor;
var
  R: TRect;
  CurrInterval: TInterval;
begin
  R := CellRect(Col, Row);
  CurrInterval := TInterval(Objects[0, Row]);

  if CurrInterval <> nil then
  begin
    FTextEdit.SendToBack;
    FTextEdit.Visible := True;
    FTextEdit.AutoSize := False;
    FTextEdit.Left := R.Left + 2;
    FTextEdit.Top := R.Top + 2;
    FTextEdit.Width := R.Right - R.Left - 4;
    FTextEdit.Height := R.Bottom - R.Top - 4;
    FTextEdit.Text := CurrInterval.Task;
    FTextEdit.SelectAll;
    FTextEdit.BringToFront;
    FTextEdit.SetFocus;
    FEditInterval := CurrInterval;
  end;  
end;

{
  Была нажата одна из кнопок.
}

procedure TGanttTree.WMChar(var Message: TWMChar);
begin

  if GetColumnType(Col) = gctTask then
  begin
    if Message.CharCode = VK_ESCAPE then
    begin
      FTextEdit.Visible := False;
      SetFocus;
    end else if not FTextEdit.Visible then
    begin
      ShowTaskEditor;
    end;

    SendMessage(FTextEdit.HANDLE, WM_CHAR, Message.CharCode, Message.KeyData);
  end else
    inherited;
end;

{
  --------------------------------------
  ------                          ------
  ------      TgsGantt Class      ------
  ------                          ------
  --------------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TgsGantt.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Width := 300;
  Height := 150;

  FLanguage := glEnglish;

  // Создаем список интервалов
  FIntervals := TExList.Create;

  // Создаем дерево интервалов
  FTree := TGanttTree.Create(Self);
  InsertControl(FTree);
  FTree.Align := alLeft;
  FTree.Width := 200;

  // Создаем полосу изменения размеров
  FSplitter := TSplitter.Create(Self);
  InsertControl(FSplitter);
  FSplitter.Left := FTree.Left + FTree.Width + 1;
  FSplitter.Align := alLeft;
  FSplitter.Width := 6;
  FSplitter.Color := clBlack;
  FSplitter.Beveled := True;

  // Создаем календарь интервалов
  FCalendar := TGanttCalendar.Create(Self);
  InsertControl(FCalendar);
  FCalendar.Align := alClient;
end;

{
  Высвобождаем память.
}

destructor TgsGantt.Destroy;
begin
  FCalendar.Free;
  FTree.Free;
  FSplitter.Free;
  FIntervals.Free;

  inherited Destroy;
end;

{
  Добавляет интервал в самый конец списка.
}

procedure TgsGantt.AddInterval(AnInterval: TInterval);
begin
  FIntervals.Add(AnInterval);
  UpdateInterval;
end;

{
  Вставка интервала на определенную позицию.
}

procedure TgsGantt.InsertInterval(AnIndex: Integer; AnInterval: TInterval);
begin
  FIntervals.Insert(AnIndex, AnInterval);
  UpdateInterval;
end;

{
  Удаление интервала по индексу.
}

procedure TgsGantt.DeleteInterval(AnIndex: Integer);
begin
  FIntervals.Delete(AnIndex);
  UpdateInterval;
end;

{
  Удаление интервала по классу удаляемого интервала.
}

procedure TgsGantt.RemoveInterval(AnInterval: TInterval);
begin
  FIntervals.Remove(AnInterval);
  UpdateInterval;
end;

{
  Производит обновление дерева и календаря для
  определенного интервала.
}

{DONE 3 -oDenis -cMainUpdate: Обновление}
procedure TgsGantt.UpdateInterval;
begin
  FTree.UpdateTreeList;
  FTree.Repaint;
  FCalendar.Repaint;
end;


{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Создает список интервалов.
}

procedure TgsGantt.MakeIntervalList(AList: TList);
var
  I: Integer;
begin
  for I := 0 to IntervalCount - 1 do
  begin
    if Interval[I].Visible then
    begin
      AList.Add(Interval[I]);
      Interval[I].MakeIntervalList(AList);
    end;
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}


{
  Возвращает кол-во интервалов.
}

function TgsGantt.GetIntervalCount: Integer;
begin
  Result := FIntervals.Count;
end;

{
  Возвращает интервал по индексу.
}

function TgsGantt.GetInterval(AnIndex: Integer): TInterval;
begin
  Result := FIntervals[AnIndex];
end;

{
  Возвращает шрифт календаря.
}

function TgsGantt.GetCalendarFont: TFont;
begin
  Result := FCalendar.Font;
end;

{
  Устанавливает шрифт календаря.
}

procedure TgsGantt.SetCalendarFont(const Value: TFont);
begin
  FCalendar.Font := Value;
end;

{
  Возвращает цвет календаря.
}

function TgsGantt.GetCalendarColor: TColor;
begin
  Result := FCalendar.Color;
end;

{
  Устанавливает цвет календаря.
}

procedure TgsGantt.SetCalendarColor(const Value: TColor);
begin
  FCalendar.Color := Value;
end;

{
  Возвращает цвет верхней шкалы.
}

function TgsGantt.GetMajorColor: TColor;
begin
  Result := FCalendar.MajorColor;
end;

{
  Устанавливает цвет верхней шкалы.
}

procedure TgsGantt.SetMajorColor(const Value: TColor);
begin
  FCalendar.MajorColor := Value;
end;

{
  Возваращет цвет нижней шкалы.
}

function TgsGantt.GetMinorColor: TColor;
begin
  Result := FCalendar.MinorColor;
end;

{
  Устанавливает цвет нижней шкалы.
}

procedure TgsGantt.SetMinorColor(const Value: TColor);
begin
  FCalendar.MinorColor := Value;
end;

{
  Возвращает верхнюю шкалу.
}

function TgsGantt.GetMajorScale: TTimeScale;
begin
  Result := FCalendar.MajorScale;
end;

{
  Устанавливает верхнюю шкалу.
}

procedure TgsGantt.SetMajorScale(const Value: TTimeScale);
begin
  FCalendar.MajorScale := Value;
end;

{
  Возвращает нижнюю шкалу.
}

function TgsGantt.GetMinorScale: TTimeScale;
begin
  Result := FCalendar.MinorScale;
end;

{
  Устанавливает нижнюю шкалу.
}

procedure TgsGantt.SetMinorScale(const Value: TTimeScale);
begin
  FCalendar.MinorScale := Value;
end;

{
  Возвращает кол-во точек нижней шкалы.
}

function TgsGantt.GetPixelsPerMinorScale: Integer;
begin
  Result := FCalendar.PixelsPerMinorScale;
end;

{
  Устанавливает кол-во точек нижней шкалы.
}

procedure TgsGantt.SetPixelsPerMinorScale(const Value: Integer);
begin
  FCalendar.PixelsPerMinorScale := Value;
end;

{
  Возвращает кол-во точек на линию.
}

function TgsGantt.GetPixelsPerLine: Integer;
begin
  Result := FCalendar.PixelsPerLine;
end;

{
  Устанавливает кол-во точек на линию.
}

procedure TgsGantt.SetPixelsPerLine(const Value: Integer);
begin
  FCalendar.PixelsPerLine := Value;
end;

{
  Возвращает дату начала просмотра.
}

function TgsGantt.GetStartDate: TDateTime;
begin
  Result := FCalendar.StartDate;
end;

{
  Устанавливает дату начала просмотра.
}

procedure TgsGantt.SetStartDate(const Value: TDateTime);
begin
  FCalendar.StartDate := Value;
end;

{
  Возвращает отступ для ветви.
}

function TgsGantt.GetTreeIndent: Integer;
begin
  Result := FTree.Indent;
end;

{
  Устанавливает отступ для ветви.
}

procedure TgsGantt.SetTreeIndent(const Value: Integer);
begin
  FTree.Indent := Value;
end;

{
  Возвращает шрифт дерева.
}

function TgsGantt.GetTreeFont: TFont;
begin
  Result := FTree.Font;
end;

{
  Устанавливает шрифт дерева.
}

procedure TgsGantt.SetTreeFont(const Value: TFont);
begin
  FTree.Font := Value;
end;

{
  Возвращает шрифт ветви дерева.
}

function TgsGantt.GetTreeBranchFont: TFont;
begin
  Result := FTree.BranchFont;
end;

{
  Устанавливает шрифт ветви дерева.
}

procedure TgsGantt.SetTreeBranchFont(const Value: TFont);
begin
  FTree.BranchFont := Value;
end;

{
  Устанавливаем язык.
}

procedure TgsGantt.SetLanguage(const Value: TgsGanttLanguage);
begin
  FLanguage := Value;
  UpdateInterval;
end;

{
   -----------------------------------------------------------
   ------                                               ------
   ------      Register TGanttCalendar as component      ------
   ------                                               ------
   -----------------------------------------------------------
}

{procedure Register;
begin
  RegisterComponents('gsNV', [TgsGantt]);
end;}


initialization

  // Производим добавление курсоров, необходимых для работы компоненты

  // Курсор для переноса всего периода
  Screen.Cursors[crGanttMiddle] := LoadCursor(hInstance, 'GANTT_MIDDLE');

  // Курсор для продления периода вправо
  Screen.Cursors[crGanttRightMove] := LoadCursor(hInstance, 'GANTT_RIGHTMOVE');

  // Курсор для продления периода влево
  Screen.Cursors[crGanttLeftMove] := LoadCursor(hInstance, 'GANTT_LEFTMOVE');

  // Курсор для установления процента выполнения
  Screen.Cursors[crGanttPercent] := LoadCursor(hInstance, 'GANTT_PERCENT');

  // Курсор для связи периодов
  Screen.Cursors[crGanttConnect] := LoadCursor(hInstance, 'GANTT_CONNECT');

  DrawBitmap := TBitmap.Create;

finalization

  DrawBitmap.Free;

end.

