unit gsPeriodEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, extctrls,
  stdctrls, comctrls, Forms, buttons, Commctrl
  ,dialogs{ для вывода отладочных сообщений }
  {$IFNDEF MCALENDAR},gsCalendar{$ENDIF};

type
  TDMY = record
    D,M,Y: Word;
  end;
  T2DMY = array[1..2] of TDMY;

  TTypePeriod = (tpYear, tpQuarter, tpMonth, tpWeek, tpDay);

  TPeriod = class(TObject)
  private
    DMY: T2DMY;
    FAllowDateEnd: Boolean;
    FLenYear: Integer;
  public
    DBeg, DEnd: TDateTime;
    constructor Create;
    procedure SetDates(ADate1: TDateTime; TypePeriod: TTypePeriod; Offset: Integer = 0);
    //- function GetTwoDates: T2DMY;
    procedure TwoYMDtoDates(ADate1, ADate2: TDMY);
    //- procedure DatesToTwoYMD(ADate1, ADate2: TDateTime);
    procedure SetOrdPeriod(OrdPeriod,Year: Integer; TypePeriod: TTypePeriod);
    //- function GetType: TTypePeriod;
    function GetTextPeriod(Part: Integer = 0): string;
    function DatesToText: string;
  end;

function GetOrdPeriod(ADate: TDateTime; TypePeriod: TTypePeriod): Integer;
//function GetTypePeriod(ADate1, ADate2: TDateTime): TTypePeriod;

type
  TgsPeriodEdit = class;
  TgsDropWindow = class;

  TgsPageControl = class(TPageControl)
  protected
    procedure WndProc(var Msg: TMessage); override;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KillFocus;
//    property OnKeyDown;
  end;

  {$IFDEF MCALENDAR}
  TgsMonthCalendar = class(TMonthCalendar)
  {$ELSE}
  TgsMonthCalendar = class(TgsCalendar)
  {$ENDIF}
  private
  protected
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KillFocus;
    procedure CMCancelMode(var Message: TCMCancelMode);  message CM_CANCELMODE;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TgsCustomListBox = class(TListBox)
  private
    FPeriodEdit: TgsPeriodEdit; // Класс диапазона
    FLayout: Integer;
  protected
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMMouseWheel(var Message: TWMMouseWheel); message WM_MOUSEWHEEL;
//    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SetFocus;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KillFocus;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

    procedure DoOnDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TgsListBox = class(TgsCustomListBox)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    //constructor Create(AOwner: TComponent); override;
  end;

  TgsButton = class(TBitBtn)
  private
    //IsActive, IsPressed: Boolean;
    //Is3D: Boolean;

    FDropWindow: TgsDropWindow;
    //IsDropped: Boolean;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    //procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  {TODO: TgsDropWindow  1}
  TgsDropWindow = class(TCustomControl)
  private
    FPeriodEdit: TgsPeriodEdit; // Класс диапазона
    //-IsFirst: Boolean;

    FPages: TgsPageControl;
    FTabHistory: TTabSheet;
    FTabCal: TTabSheet;
    FTabDpz: TTabSheet;
    FTabHelp: TTabSheet;

    lbHistory: TgsCustomListBox;
    lbMeta: TgsCustomListBox;

    FCal1: TgsMonthCalendar;
    FCal2: TgsMonthCalendar;
//    lbDbg: TListBox;
//    FBtDbg: TSpeedButton;

    lbYear: TgsListBox;
    lbQuarter: TgsListBox;
    lbMonth: TgsListBox;
    lbWeek: TgsListBox;

    FBtnUp: TSpeedButton;
    FBtnDn: TSpeedButton;
    FBtnCancel: TSpeedButton;
    FBtnOk: TSpeedButton;

    FDropText: string;

    FSkipKillFocus: Boolean;
    FTimeKillFocus: TDateTime;
//-    procedure WMMouseActivate(var Message: TWMMouseActivate);  message WM_MouseActivate;
//-    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging);  message WM_WINDOWPOSCHANGING;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KillFocus;

    procedure DoOnBtnUpClick(Sender: TObject);
    procedure DoOnBtnDnClick(Sender: TObject);
    procedure DoOnBtnCancelClick(Sender: TObject);
    procedure DoOnBtnOkClick(Sender: TObject);

    procedure DoOnCalendarChange(Sender: TObject; CloseDropWindow: Boolean);
    {$IFNDEF MCALENDAR}
    procedure DoOnDateChangeCalendar(Sender: TObject; FromDate, ToDate: TDateTime);
    {$ENDIF}
    procedure DoOnClickCalendar(Sender: TObject);
    procedure DoOnDblClickCalendar(Sender: TObject);

    procedure DoOnChangePeriod(Sender: TObject; CloseDropWindow: Boolean);
    procedure DoOnClickPeriod(Sender: TObject);
    procedure DoOnDblClickPeriod(Sender: TObject);

    procedure DoOnKeyDownDropWindow(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoOnChildKeyPress(Sender: TObject; var Key: Char);
    procedure DoOnPageChange(Sender: TObject);

    procedure BackDates; //возврат дат(ы) до открытия окошка после его закрытия без подтверждения изменений
    procedure AssignCalDate(ACal: TgsMonthCalendar);
  protected
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  {TODO: TgsPeriodEdit  1}
  //TDateTimeKind = (dtkDate, dtkTime);
  TDTDateFormat = (dfDefault, dfShort, dfLong);

  TgsPeriodEdit = class(TCustomEdit)
  private
    FPeriod:     TPeriod;   {класс периода}

    FDateFormat: TDTDateFormat;{4 или 2 цифры для года}
    FLenY:       Integer;   {длина года 2008 или 08}
    FLenDate:    Integer;   {длина даты периода (10 или 8), можно и без неё, но с ней понятней{имхо}

    FDiapason:    Boolean;   {только одна дата используется}

    FPageIndex: Integer;
    FTraceItems: TStrings;
    FCalBegDate: TDate;
    FCalEndDate: TDate;
    FYearPeriod: Integer;
    //FQuarterIndex: Integer;
    //FMonthIndex: Integer;
    //FWeekIndex: Integer;

    FDropButton: TgsButton;     {кнопка для отображения выпад}
    FDropWindow: TgsDropWindow; {выпадающее окошко}

    FKeepText: string;
    FKeepDate: TDate;
    FKeepEndDate: TDate;
    FOK: Boolean;

    FTimer: TTimer;
    FMetaStr: string;
    FMetaStrLast: string;

    FAllowHistoryLoad: Boolean;

    //FSelStart: Integer;
    //FSelLen: Integer;

    procedure WMSize(var Message: TWMSize);  message WM_SIZE;
    //-procedure WMMouseMove(var Message: TWMMouseMove); message WM_MouseMove;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SetFocus;
    //-procedure WMKillFocus(var Message: TWMKillFocus); message WM_KillFocus;
    //-procedure CMCancelMode(var Message: TCMCancelMode);  message CM_CANCELMODE;
    //procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;

    procedure DoOnDropDownClick(Sender: TObject);
    procedure DoOnTimer(Sender: TObject);

    procedure SetEditRect;
    function GetEditHeight: Integer;
    {$HINTS OFF}{чтобы не было хинта "нигде не используется", может ещё пригодится}
    function GetText1: String;
    function GetText2: String;
    {$HINTS ON}
    function GetDate1: TDate;
    function GetDate2: TDate;

    procedure SetDate1(Value: TDate);
    procedure SetDate2(Value: TDate);

    procedure SetDateFormat(const Value: TDTDateFormat);
    procedure SetDiapason(const Value: Boolean);
    procedure SetPageIndex(const Value: Integer);
    procedure SetTraceItems(Values: TStrings);
    procedure SetYearPeriod(const Value: Integer);

    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
  protected
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Loaded; override;

    procedure WndProc(var Message: TMessage); override;

    procedure ListDateText(DateText: string; var Y, M, D: Integer; Part: Integer);
    function ReadyDate(Part: Integer): Boolean;

//-    function  PartInText(BegP: Integer; Offs: Integer = 0): Integer;
    procedure ArrangePeriodText(BegSel: Integer = -1);
    procedure PeriodTextToHistory;

    function FurtherSelLen(CurBeg: Integer; Offs: Integer;
      var Beg,Len: Integer; Forw: Integer = 0): Integer;
    procedure SelRange(AStart, ALength: Integer);

    function ValidTraceItem(Item: String; var PeriodAsStr: string): Boolean;
    procedure HistoryLoad;
    //~property BorderStyle;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Period: TPeriod read FPeriod;

    procedure SetDates(ADate: TDateTime; TypePeriod: TTypePeriod; Offset: Integer = 0);
    procedure AssignOrdPeriod(OrdPeriod,Year: Integer; TypePeriod: TTypePeriod);

    property CalBegDate: TDate read FCalBegDate;
    property CalEndDate: TDate read FCalEndDate;

    //property QuarterIndex: Integer read FQuarterIndex default -1;
    //property MonthIndex: Integer read FMonthIndex default -1;
    //property WeekIndex: Integer read FWeekIndex default -1;

    property MaxLength;
  published
    property Date{PE}: TDate read GetDate1 write SetDate1;
    property EndDate: TDate read GetDate2 write SetDate2;
    property DateFormat: TDTDateFormat read FDateFormat write SetDateFormat default dfDefault;
    property Diapason: Boolean read FDiapason write SetDiapason default false;
    property PageIndex: Integer read FPageIndex write SetPageIndex default 0;
    property TraceItems: TStrings read FTraceItems write SetTraceItems;
    property YearPeriod: Integer read FYearPeriod  write SetYearPeriod;

    property Anchors;
//    property AutoSelect;
//    property AutoSize;
//    property BiDiMode;
//    property BorderStyle;
//    property CharCase;
    property Color;
    property Constraints;
//    property Ctl3D;
//    property DragCursor;
//    property DragKind;
//    property DragMode;
    property Enabled;
    property Font;
//    property HideSelection;
//    property ImeMode;
//    property ImeName;
//~   property MaxLength;
//    property OEMConvert;
//    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
//    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
  //property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
//    property OnDragDrop;
//    property OnDragOver;
//    property OnEndDock;
//    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
//    property OnStartDock;
//    property OnStartDrag;
  end;

  TObjStr = class(TObject)
  public
    Text: string;
    constructor Create(s: string='');
  end;

procedure Register;

implementation

{$R GSPERIODEDIT.RES}

{
  Регистрация компоненты
}

procedure Register;
begin
  RegisterComponents('x-VisualControl', [TgsPeriodEdit]);
end;


// размер кнопки для выпадающего окна в правой части элемента
const
  DropBtnWidth  = 17;
  DropBtnHeight = 17;

const
  FmtYear    = '%d год';
  FmtQuarter = '%s-й квартал %d года';
  FmtMonth   = '%s %d года';
  FmtWeek    = '%d-ая неделя %d года';

  _B = ' ';

  ArQuarter: array[1..4] of string[3] = ('I','II','III','IV');

  //Метасимволы
  ArMetaConst: array[1..15] of string = (
    'с',  //сегодня
    'з',  //завтра
    'в',  //вчера
    'н',  //текущая неделя
    'пн', //прошлая неделя
    'сн', //следующая неделя
    'м',  //текущий месяц
    'пм', //прошлый месяц
    'см', //следующий месяц
    'к',  //текущий квартал
    'пк', //прошлый квартал
    'ск', //следующий квартал
    'г',  //текущий год
    'пг', //прошлый год
    'сг'  {следующий год}
  );
var
  ArMeta: array[1..2, 1..15] of string;

  //Ниже массивы начал и длин частей дат(ы) в тексте компоненты:
  //первый массив для года из 4-х цифр, второй для 2-х
  //по всей видимости это временное решение, избыточное ради
  //двойного представления года

  //день.месяц.год-день.месяц.год    {нач. дата -кон. дата }
  ar1Beg: array[1..6] of Integer =   {0  3  6    11 14 17  21}
    (0, 3, 6, 11, 14, 17);           {^  ^  ^    ^  ^  ^   ^}
  ar1Len: array[1..6] of Integer =   {01.01.2008-01.11.2008}
    (2, 2, 4,  2, 2, 4);
                                     {нач.дата-кон.дата}
  ar2Beg: array[1..6] of Integer =   {0  3  6  9  12 1517}
    (0, 3, 6,  9, 12, 15);           {^  ^  ^  ^  ^  ^ ^}
  ar2Len: array[1..6] of Integer =   {01.01.08-01.11.08}
    (2, 2, 2,  2, 2, 2);

const
  ArFmtPeriod: array[1..4] of string = ('%d год', '%s-й квартал %d года',
    '%s %d года', '%d-ая неделя %d года');

function FmtPeriod(TxtPeriod: string; I: Integer; Period: TPeriod): string;
var
  J,JY,p1,p2: Integer;
  Y, OrdTxt,Fmt,Txt,z: string;
  IPeriod: Integer;
  ok: boolean;
  V,K: Integer;
  TmpPeriod: TPeriod;
  TypePeriod: TTypePeriod;
begin
  Result := '';
  TypePeriod := tpDay;{чтобы не было warning}
  Txt := TxtPeriod;

  Fmt := StringReplace(ArFmtPeriod[I], '%s', '', [rfReplaceAll]);
  Fmt := StringReplace(Fmt, '%d', '', [rfReplaceAll]);

  if I=1 then z:='год' else z:='года';
  p2 := pos(' '+z, Txt);
  if p2 = 0 then exit;
//if p2 > 0 then delete(Txt, p2, Length(z)+1) else exit;

  Y := ''; JY := 1;
  for J := p2 - 1 downto 1 do
    if Txt[J] in ['0'..'9'] then begin
      Y := Txt[J] + Y;
      JY := J;
    end else
      break;
  if Length(Y) in [2,4] then IPeriod := StrToInt(Y)
                        else exit;
  delete(Txt, JY, Length(Y));

  p1:=0;
  if I > 1 then begin
    OrdTxt := '';
    case I of
      2: p1:= pos('-й ',TxtPeriod);
      3: p1:= pos(' ',TxtPeriod);
      4: p1:= pos('-ая ',TxtPeriod);
    end;
    if p1>0 then begin
      OrdTxt := copy(Txt, 1, p1-1);
      delete(Txt, 1, p1-1);
    end;

    ok := false;
    case I of
      2: for J := 1 to 4 do
           if OrdTxt = ArQuarter[J] then begin
             IPeriod := J;
             ok := True; break;
           end;
      3: for J := 1 to 12 do
           if OrdTxt = LongMonthNames[J] then begin
             IPeriod := J;
             ok := True; break;
           end;
      4: begin
           val(OrdTxt, V,K);
           if (K=0) and (V in [1..53]) then begin
             IPeriod := V;
             ok := True;
           end;
         end;
    end;{<- case}

    if not ok then
      exit;
  end;
  if Fmt <> Txt then
    exit;

  TmpPeriod := TPeriod.Create;
  try
    TmpPeriod.FLenYear := Period.FLenYear;
    TmpPeriod.FAllowDateEnd := True;
    case I of 1: TypePeriod := tpYear;  2: TypePeriod := tpQuarter;
              3: TypePeriod := tpMonth; 4: TypePeriod := tpWeek;
    end;
    TmpPeriod.SetOrdPeriod(IPeriod, StrToInt(Y), TypePeriod);
    Result := TmpPeriod.DatesToText;
  finally
    TmpPeriod.Free;
  end;

end;{<- FmtPeriod}

function BlankDate(YearDigits: Integer): string;
begin
  if YearDigits = 4 then
    Result := '__.__.____'
  else
    Result := '__.__.__';
end;

{ TObjStr }
constructor TObjStr.Create(s: string='');
begin
  Text := s;
end;
function objstrText(ss: TStrings; ix: integer; FLenY: Integer): string;
begin
  if (ss.Objects[Ix]<>nil) and (ss.Objects[Ix] is TObjStr) then
    result:=TObjStr(ss.Objects[ix]).Text
  else
    result:=BlankDate(FLenY);
end;
//function IndexOfObjStr(ss: TStrings; Txt: string): Integer;
//var
//  I: Integer;
//begin
//  Result := -1;
//  for I := 0 to ss.Count - 1 do
//    if (ss.Objects[I]<>nil) and (ss.Objects[I] is TObjStr)
//      and (Txt = TObjStr(ss.Objects[I]).Str) then
//    begin
//      Result := I;
//      Break;
//    end;
//
//end;
{$IFDEF DBGWND}
function WndClass(Wnd: HWND): string;
begin
  SetLength(Result, 80);
  SetLength(Result, GetClassName(WND, PChar(Result), Length(Result)) );
end;

function WndText(Wnd: HWND): string;
begin
  SetLength(Result, 80);
  SetLength(Result, GetWindowText(WND, PChar(Result), Length(Result)) );
end;
{$ENDIF}

procedure ArMetaFill;
const
  txtEn = '`qwertyuiop[]asdfghjkl;'''+'zxcvbnm,.';
  txtRu = 'ёйцукенгшщзхъфывапролджэ' +'ячсмитьбю';
var
  I,J,p: Integer;
begin           {TODO: Задание 5}
 for I:=1 to Length(ArMetaConst) do begin
   ArMeta[1][I] := ArMetaConst[I];//для русской раскладки
   for J := 1 to Length(ArMetaConst[I]) do
   begin
     p := pos(ArMetaConst[I][J],txtRu);
     if p > 0 then ArMeta[2][I] := ArMeta[2][I] + txtEn[p] //для английской раскладки
     else ArMeta[2][I] := ArMeta[2][I] + ArMetaConst[I][J];
   end;
 end;
end;

function _DayOfWeek(ADate: TDateTime; MondayFirst: Boolean = True): Integer;
begin
  Result := DayOfWeek(ADate);
  if MondayFirst then
    if Result = 1 then
      Result := 7
    else
      Result := Result - 1;
end;

function _DaysPerMonth(AYear, AMonth: Integer): Integer;
const
  DaysInMonth: array[1..12] of Integer =
    (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  Result := DaysInMonth[AMonth];
  if (AMonth = 2) and IsLeapYear(AYear) then Inc(Result);
end;

function _getYear(ADate: TDateTime = 0): Integer;
var  D,M,Y: Word;
begin
  if ADate = 0 then
    ADate := now;
  DecodeDate(ADate, Y, M, D);
  Result := Y;
end;

{  TPeriod  }

function GetOrdPeriod(ADate: TDateTime; TypePeriod: TTypePeriod): Integer;
var
 D,M,Y: Word;
 //DMY: T2DMY;
begin
  //with DMY[1] do
  begin
    DecodeDate(ADate, Y, M, D);
    case TypePeriod of
      tpYear: Result := Y;
      tpQuarter: Result := ((M-1) div 3) + 1;
      tpMonth: Result := M;
      tpWeek: Result := Trunc( ADate - EncodeDate(Y,1,1)
             + _DayOfWeek( EncodeDate(Y, 1, 1) - _DayOfWeek(ADate) )
                              ) div 7  {+ 1};   {TODO: Задание 4}
      tpDay: Result := Trunc( ADate - EncodeDate(Y, 1, 1) ) + 1;
      else
        Result := 0;
    end;
  end;
end;

function TPeriod.GetTextPeriod(Part: Integer = 0): string;
var
  Txt1, Txt2: String;
  fmt: string;
  ADate1, ADate2: TDateTime;
begin
  ADate1 := DBeg; ADate2 := DEnd;

  Txt1 := ''; Txt2 := '';
  if FLenYear = 4 then Fmt := 'dd.mm.yyyy'
  else
    Fmt := 'dd.mm.yy';

  if ADate1 <> 0 then
    Txt1 := FormatDateTime(Fmt, ADate1)
  else
    Txt1 := BlankDate(FLenYear);

  if FAllowDateEnd then
    if (ADate2 <> 0) then
      Txt2 := FormatDateTime(Fmt, ADate2)
    else
      Txt2 := BlankDate(FLenYear);

  case Part of
    1: Result := Txt1;
    2: Result := Txt2;
    else
      if FAllowDateEnd then
        Result := Txt1 + '-' + Txt2
      else
        Result := Txt1;
  end;

end;

constructor TPeriod.Create;
begin
  FAllowDateEnd := false;
end;

procedure TPeriod.TwoYMDtoDates(ADate1, ADate2: TDMY);
begin
  with ADate1 do DBeg := EncodeDate(Y, M, D);
  with ADate2 do DEnd := EncodeDate(Y, M, D);
end;

//-procedure TPeriod.DatesToTwoYMD(ADate1, ADate2: TDateTime);
//var
//  Y, M, D: Word;
//begin
//  if ADate1 <> 0 then begin
//    DecodeDate(ADate1, Y, M, D);
//    DMY[1].Y := Y; DMY[1].M := M; DMY[1].D := D;
//  end;
//  if ADate2 <> 0 then begin
//    DecodeDate(ADate2, Y, M, D);
//    DMY[2].Y := Y; DMY[1].M := M; DMY[1].D := D;
//  end;
//end;

procedure TPeriod.SetOrdPeriod(OrdPeriod, Year: Integer; TypePeriod: TTypePeriod);
begin
  with DMY[1] do begin
    D := 1;
    Y := Year;
    DMY[2].Y := Year;
    case TypePeriod of
      tpYear: begin
         DMY[2].D := 31;
         M := 1;
         DMY[2].M := 12;
      end;
      tpQuarter: begin
         DMY[2].M := OrdPeriod * 3;
         M := DMY[2].M - 2;
         DMY[2].D := _DaysPerMonth(Y, DMY[2].M);
      end;
      tpMonth: begin
         DMY[2].M := OrdPeriod;
         M := DMY[2].M;
         DMY[2].D := _DaysPerMonth(Y, DMY[2].M);
      end;
      tpWeek: begin
         DBeg := EncodeDate(Y,1,1) - _DayOfWeek(EncodeDate(Y, 1, 1)) +
               (OrdPeriod - 1) * 7 + 1;
         DEnd := DBeg + 6;
         exit;
      end;
      tpDay: begin
         DBeg := EncodeDate(Y, 1, 1) + OrdPeriod - 1;
         if FAllowDateEnd or (DEnd <> 0) then {1'}
           DEnd := DBeg;
         exit;
      end;
      else
        exit;
    end;
  end;
  TwoYMDtoDates(DMY[1], DMY[2]);
end;

function NextDate(ADate1: TDateTime; TypePeriod: TTypePeriod; Offset: Integer = 0): TDateTime;
var
  TmpM,TmpD: Integer;
  D,M,Y: Word;
begin
    Result := ADate1;
    DecodeDate(Result, Y, M, D);

    if Offset <> 0 then{ Смещаем дату на определённый диапазон }
    begin
      TmpM := M;
      case TypePeriod of
            tpYear: Inc(Y, Offset);
         tpQuarter,
           tpMonth: begin
                      if tpQuarter=TypePeriod then
                        Offset := Offset * 3;
                      Y := Y + (Offset div 12);
                      TmpM := M + (Offset mod 12);
                      if TmpM < 1 then begin
                        Dec(Y);
                        TmpM := 12 + TmpM;
                      end else if TmpM > 12 then begin
                        Inc(Y);
                        TmpM := TmpM - 12;
                      end;
                    end;
            tpWeek: begin
                      Result := Result + Offset * 7;
                      DecodeDate(Result, Y, M, D);
                      TmpM := M;
                    end;
            tpDay:  begin
                      Result := Result + Offset;
                      exit;
                      {DecodeDate(Result, Y, M, D); TmpM := M;}
                     end;
      end; { <- case TypePeriod}
      TmpD := _DaysPerMonth(Y, TmpM);
      if TmpD < D then
        D := TmpD;
      Result := EncodeDate(Y, TmpM, D);
    end; { <- if Offset <> 0}
end;

procedure TPeriod.SetDates(ADate1: TDateTime; TypePeriod: TTypePeriod; Offset: Integer = 0);
begin
  DBeg := NextDate(ADate1, TypePeriod, Offset);
  with DMY[1] do DecodeDate(DBeg, Y, M, D);
  if TypePeriod = tpDay then
  begin
    if FAllowDateEnd or (DEnd <> 0) then{1'}
      DEnd := DBeg;
    exit;
  end;

  SetOrdPeriod(GetOrdPeriod(DBeg, TypePeriod), DMY[1].Y, TypePeriod);
end;

//-function TPeriod.GetTwoDates: T2DMY;
//begin
//  with Result[1] do DecodeDate(DBeg, Y, M, D);
//  with Result[2] do DecodeDate(DEnd, Y, M, D);
//end;

function TPeriod.DatesToText: string;
begin
  Result := GetTextPeriod;
end;

function iif(Switch: Boolean; Var1,Var2: Variant): Variant;
begin
  if Switch then Result := Var1 else Result := Var2;
end;

function ReplaceSubStr(Text,SubStr: string; PStart, PLength: Integer): string;
begin
  result := copy(Text, 1, PStart - 1) + SubStr +
    copy(Text, PStart + PLength, Length(Text) );
end;

function BlankBefore(_Blank: Char; Text: string; ALength: Integer): string;
begin
  Result := Text;
  While length(Result) < ALength do
    Result := _Blank + Result;
end;

function BlankAfter(_Blank: Char; Text: string; ALength: Integer): string;
begin
  Result := Text;
  While length(Result) < ALength do
    Result := Result + _Blank;
end;

//день(1), месяц(2) или год(2) текущей даты
function TextPartOfNow(Part: Integer; YearDigits: Integer): string;
var Fmt: string;
begin  //YearDigits нужно только для лет
  case Part of
   1: Fmt := 'dd';
   2: Fmt := 'mm';
   3: if YearDigits = 4 then Fmt := 'yyyy' else Fmt := 'yy';
  end;
  Result := FormatDateTime(Fmt, Now);
end;

function FocusedWNDIsChild(Owner: TComponent; FocusedWND: HWND): Boolean;
var I: Integer;
begin
  Result := false;
  with Owner do
  for I:=0 to ComponentCount - 1 do begin
    if (Components[I] is TWinControl)
      and (FocusedWND = TWinControl(Components[I]).Handle)
    then begin
        Result := True;
        break;
    end;
  end;
end;

procedure TgsPageControl.WMKillFocus(var Message: TWMKillFocus);
begin
  if not (csDesigning in ComponentState) then
    if (Message.FocusedWND <> Handle)
      and not FocusedWNDIsChild(Owner,Message.FocusedWND)
    then begin
      TgsDropWindow(Owner).BackDates;
      TgsDropWindow(Owner).Hide;
      TWinControl(Owner.Owner).SetFocus;
    end;

  inherited;
end;

procedure TgsPageControl.WndProc(var Msg: TMessage);
begin
  inherited WndProc(Msg);
  if (Msg.Msg = TCM_ADJUSTRECT) then begin

      with PRect(Msg.LParam)^ do begin
        Top := Top -6;
        Left := 0;
        Right := ClientWidth;
        Bottom := ClientHeight;
      end;
  end;
end;

procedure TgsMonthCalendar.WMKillFocus(var Message: TWMKillFocus);
begin
  if not (csDesigning in ComponentState) then
    if (Message.FocusedWND <> Handle)
      and (Owner is TgsDropWindow) and not TgsDropWindow(Owner).FSkipKillFocus{??}
      and not FocusedWNDIsChild(Owner, Message.FocusedWND)
    then begin
      TgsDropWindow(Owner).BackDates;
      TgsDropWindow(Owner).Hide;
      TWinControl(Owner.Owner).SetFocus;
    end;

  inherited;
  Refresh;
end;

procedure TgsMonthCalendar.CMCancelMode(var Message: TCMCancelMode);
begin
  inherited;
  if not (csDesigning in ComponentState) then
    if (Message.Sender <> Self) and (Message.Sender <> Owner)
      and ((Message.Sender).Owner <> nil)
      and not ((Message.Sender).Owner is TgsDropWindow) then
    begin
//      if FDropWindow.Visible then begin
//        FDropWindow.BackDates;
//        FDropWindow.Hide;
//      end;
    end;
end;

procedure TgsMonthCalendar.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTTAB;
end;

procedure TgsMonthCalendar.WMMouseWheel(var Message: TWMMouseWheel);
begin
  inherited;
  {$IFNDEF MCALENDAR}
  if Message.WheelDelta > 0 then begin
    DoDateChange(Date, IncMonth(Date, -1), false, true);
  end else
    DoDateChange(Date, IncMonth(Date, +1), false, true);
  {$ENDIF}  
end;

constructor TgsMonthCalendar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Font.Name := 'Arial';
  Font.Size := 8;
  ShowToday := false;
  ShowTodayCircle := false;
  with CalColors do begin
    MonthBackColor := $00FFF5E1;
    TextColor := $00454545;
    TitleBackColor := $00C08080;
    TitleTextColor := clWhite;
    TrailingTextColor := $00B0A080;//$00BFA0A0;//Dasy
  end;
  WeekNumbers := True;

  {$IFDEF MCALENDAR}  { TMonthCalendar }
  MultiSelect := false;
  AutoSize:=True;
  with CalColors do begin
    BackColor := $00FDD8CA;
  end;
  {$ELSE}             {   TgsCalendar  }
  Autosize := True;    Autosize := false;
  ShowTitle := false;  ShowTitle := True;
  CellWidth := 19;
  CellHeight := 16;
  SelectedShape := ssRectangle;
  with CalColors do begin
    HighLightColor := $00FDD8CA;
  end;
  //BorderStyle := bsSingle;
  {$ENDIF}
end;

procedure TgsCustomListBox.WMMouseWheel(var Message: TWMMouseWheel);
begin
  inherited;
//  SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @Result, 0);
//  Mouse.WheelPresent
  if Message.WheelDelta > 0 then begin
    if (ItemIndex <> -1) and (ItemIndex <> 0) then
      ItemIndex := ItemIndex - 1;
  end else
    if (ItemIndex <> -1) and (ItemIndex < Items.Count - 1) then
      ItemIndex := ItemIndex + 1;
end;

procedure TgsCustomListBox.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTTAB;
end;

procedure TgsCustomListBox.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
//  if ItemIndex <> -1 then
//    TgsDropWindow(Owner).DoOnChangePeriod(Self, false);
end;

procedure TgsCustomListBox.WMKillFocus(var Message: TWMKillFocus);
begin
  if (Message.FocusedWND <> Handle)
    and (Owner is TgsDropWindow)
    and not FocusedWNDIsChild(Owner, Message.FocusedWND)
    //and (Message.FocusedWND <> TgsPeriodEdit(Owner.Owner).FDropButton.Handle)
    //and (Message.FocusedWND <> TWinControl(Owner.Owner.Owner).Handle)
    //and (Message.FocusedWND <> FPeriodEdit.Handle)
  then begin
    TgsDropWindow(Owner).BackDates;
    TgsDropWindow(Owner).Hide;
    TWinControl(Owner.Owner).SetFocus;
  end;

  inherited;
end;

procedure TgsCustomListBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
end;

procedure TgsCustomListBox.DoonDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var TempStr: string;
begin
   with TListBox(Control) do begin
     TempStr := Items.Strings[Index];

     Canvas.Font.Color:=clBlack;
     if odFocused in State then
     begin
       Canvas.Brush.Color := $00FDD8CA;
     end else  begin
       Canvas.Brush.Color:=clWhite;
     end;

     Canvas.FillRect(Rect);

     if Control is TgsListBox then begin
       DrawText(Canvas.Handle, pChar(TempStr), Length(TempStr), Rect,
         DT_CENTER + DT_VCENTER + DT_END_ELLIPSIS)
     end else begin
       InflateRect(Rect, -2, 0);
       DrawText(Canvas.Handle, pChar(TempStr) , Length(TempStr), Rect,
         DT_VCENTER + DT_END_ELLIPSIS);
       InflateRect(Rect, 2, 0);
     end;

     if (FLayout=31) and (odSelected in State) then begin
       Canvas.Brush.Color := $00BD988A;
       Canvas.FrameRect(Rect);
     end
   end;
end;

constructor TgsCustomListBox.Create(AOwner: TComponent);
var
  ColWidth: Integer;
begin
  inherited Create(AOwner);
  BorderStyle := bsNone;
  Style := lbOwnerDrawFixed;
  ItemHeight := 14;
  OnDrawItem := DoOnDrawItem;

  if (Columns > 0) and (Width > 0) then
  begin
    ColWidth := (Width + Columns - 3-1) div Columns;
    if ColWidth < 1 then ColWidth := 1;
    SendMessage(Handle, LB_SETCOLUMNWIDTH, ColWidth, 0);
  end;
end;

procedure TgsListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  // Отключаем Скроллбары!!!
  Params.Style := Params.Style and ( (not WS_VSCROLL) and (not WS_HSCROLL) );
end;

{TODO: TgsButton}
constructor TgsButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  //IsActive := False;
  //IsPressed := False;
  //Is3D := True;
end;


procedure TgsButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;

  //IsActive := True;
  //Paint;
end;

procedure TgsButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  //IsActive := False;
  //Paint;
end;

procedure TgsButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);

  //IsPressed := True;
  //Paint;
end;

procedure TgsButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  Cursor := crArrow;
end;

procedure TgsButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);

  //IsPressed := False;
  //Paint;
end;

//procedure TgsButton.Paint;
//var
//  Y: Integer;
//begin
//  if not Is3D then
//  begin
//    if not IsPressed then
//      Canvas.Brush.Color := $0094A2A5
//    else
//      Canvas.Brush.Color := clBlack;
//
//    Canvas.FillRect(Rect(0, 0, Width, Height));
//
//    Canvas.Brush.Color := clBlack;
//    Canvas.FrameRect(Rect(0, 0, Width, Height));
//
//    Y := Height div 2 - 1;
//
//    if (IsActive and not TgsPeriodEdit(Parent).FDropWindow.Visible) or IsPressed then
//      Canvas.Pen.Color := clWhite
//    else
//      Canvas.Pen.Color := clBlack;
//
//    Canvas.MoveTo(6, Y + 1);
//    Canvas.LineTo(11, Y + 1);
//
//    Canvas.MoveTo(7, Y + 2);
//    Canvas.LineTo(10, Y + 2);
//
//    if (IsActive and not TgsPeriodEdit(Parent).FDropWindow.Visible) or IsPressed then
//      Canvas.Pixels[8, Y + 3] := clWhite
//    else
//      Canvas.Pixels[8, Y + 3] := clBlack;
//  end else
//    inherited Paint;
//end;

{TODO: TgsPeriodEdit}

var arBeg: array[1..6] of Integer;
    arLen: array[1..6] of Integer;

//Определение части даты(ы) в окошке редактирования
         //TgsPeriodEdit.
function PartInText(BegP: Integer; Offs: Integer = 0): Integer;
var I: Integer;
    LeftP, RightP: Integer;
begin
    Result := 0;

    if (Offs=-1) and (BegP>=arBeg[6] + arLen[6]) then begin
      Result := 7;{!!1^}
      exit;
    end;

    for I:=1 to 6 do
    begin
      // если Offs=-1 то точка слева входит в часть даты
      if Offs=-1 then LeftP := arBeg[I] - 1
      else LeftP := arBeg[I];
      // если Offs=1 то точка справа входит в часть даты
      if Offs=1 then RightP := arBeg[I] + arLen[I] + 1
      else RightP := arBeg[I] + arLen[I];

      if (BegP >= LeftP) and (BegP < RightP) then
      begin
        Result := I;
        break;
      end;
    end;
end;

//Вычисление части дат(ы) и её начало/длину для выделения в окошке редактирования
function TgsPeriodEdit.FurtherSelLen(CurBeg: Integer; Offs: Integer;
  var Beg,Len: Integer; Forw: Integer = 0): Integer;
var
  Part: Integer;
  LastPart: Integer;
begin
    Part := PartInText(CurBeg, Offs);
    if pos('-', Text) > 0 then LastPart := 6
                          else LastPart := 3;

    if Part > 0 then begin
      if (Forw = 1) then
        //if Part = LastPart then Part := 1 else Inc(Part);{круговорот}
        if Part < LastPart then Inc(Part);
      if (Forw = -1) then{!!1^}
        //if Part = 1 then Part := LastPart else Dec(Part);{круговорот}
        if Part > 1 then Dec(Part);

      Beg := arBeg[Part];
      Len := arLen[Part];
    end;

    Result := Part;
end;

//Выделение определённой части в окошке редактирования
procedure TgsPeriodEdit.SelRange(AStart, ALength: Integer);
begin
  SendMessage(Handle, EM_SETSEL, AStart, AStart+ALength);
//  SelStart := AStart;
//  SelLength := ALength;
end;


//установка региона редактирования
procedure TgsPeriodEdit.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - DropBtnWidth - 1;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECT, 0, LongInt(@Loc));
end;

function TgsPeriodEdit.GetEditHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);

  try
    GetTextMetrics(DC, SysMetrics);
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(0, DC);
  end;

  Result := SysMetrics.tmHeight;
  if Result > Metrics.tmHeight then
    Result := Metrics.tmHeight;
  Result := Result + 8; 
end;

procedure TgsPeriodEdit.WMSize(var Message: TWMSize);
var
  EditHeight: Integer;
begin
  inherited;

  EditHeight := GetEditHeight;
  if Height <> EditHeight then
    Height := EditHeight
  else if FDropButton <> nil then
  begin
    if NewStyleControls and Ctl3D then
      FDropButton.SetBounds(Width - FDropButton.Width - 4, 0, FDropButton.Width, Height - 4)
    else
      FDropButton.SetBounds (Width - FDropButton.Width, 0, FDropButton.Width, Height);
    SetEditRect;
  end;
end;

//procedure TgsPeriodEdit.WMMouseMove(var Message: TWMMouseMove);
//begin
//  inherited;
////  Cursor := crArrow;
//end;

procedure TgsPeriodEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  HideCaret(Handle);
end;

//procedure TgsPeriodEdit.WMKillFocus(var Message: TWMKillFocus);
//begin
//  inherited;
////  ArrangePeriodText;
////  PeriodTextToHistory;
//end;

//procedure TgsPeriodEdit.CMCancelMode(var Message: TCMCancelMode);
//begin
//  inherited;
//  {!!}
//  if not (csDesigning in ComponentState) then
//    if (Message.Sender <> Self) and (Message.Sender <> FDropWindow)
//      and (Message.Sender <> FDropButton)
//      and ((Message.Sender).Owner <> nil)
//      and ((Message.Sender).Owner <> FDropWindow) then
//    begin
//      if FDropWindow.Visible then begin
//        FDropWindow.BackDates;
//        FDropWindow.Hide;
//      end;
//    end;
//end;

procedure TgsPeriodEdit.CMEnter(var Message: TCMEnter);
begin
 //SendMessage(Handle, EM_SETSEL, FSelStart, FSelStart + FSelStart);
end;

procedure TgsPeriodEdit.CMExit(var Message: TCMExit);
begin
  ArrangePeriodText;
  PeriodTextToHistory;
end;

procedure TgsPeriodEdit.CNNotify(var Message: TWMNotify);
begin
//
end;

procedure TgsPeriodEdit.ArrangePeriodText(BegSel: Integer = -1);
var
  TxtTmp, Tmp: string;
  Beg, Len: Integer;

  procedure ArrangeNonYear(var TxtTmp: string; P: Integer);
  begin
    Tmp := StringReplace(copy(TxtTmp, P, 2), '_', '', [rfReplaceAll]);
    if length(Tmp) = 1 then           //BlankBefore('0', Tmp, 2)
      TxtTmp := ReplaceSubStr(TxtTmp, '0' + Tmp, P, 2);
  end;
  procedure ArrangeYear(var TxtTmp: string; P: Integer);
  begin
    Tmp := StringReplace(copy(TxtTmp, P, FLenY), '_', '', [rfReplaceAll]);
    if length(Tmp) in [1 .. FLenY - 1] then
    begin
      case length(Tmp) of
        1: if FLenY = 4 then Tmp := '200' + Tmp
           else Tmp := '0' + Tmp;
        2: Tmp := '20' + Tmp;
        3: Tmp := '2' + Tmp;
      end;
      TxtTmp := ReplaceSubStr(TxtTmp, Tmp, 7, FLenY);
    end;
  end;
var I, Part: Integer;
begin
{ проверка на недонабранность по всему тексту, }
{     а не только по текущему выделению        }
  // !! c
  if pos('_', Text) = 0 then begin
    exit;
  end;

  TxtTmp := Text;
  if BegSel <> -1 then
  begin
    Part := FurtherSelLen(BegSel, 0, Beg,Len, 0);
    if Part > 0 then
      Beg := Beg + 1
    else begin
      Beg := 1; Len := 0;
    end;
  end else begin
    Beg := 1; Len := 0;
  end;

  if pos('_', copy(Text, 1,  Beg - 1) + copy(Text, Beg + Len, MaxLength)) = 0 then
      exit;

  if Beg = -1 then Part := 0
  else Part := PartInText(BegSel);

  for I := 1 to 6 do begin
    if (I >= 4) and (pos('-', Text) = 0) then {вторая дата диапазона отсутствует}
      break;

    if Part <> I then
      if I in [3,6] then
        ArrangeYear(TxtTmp, ArBeg[I] + 1)
      else
        ArrangeNonYear(TxtTmp, ArBeg[I] + 1);

  end;

  if TxtTmp<>Text then
    Text := TxtTmp;
end;

procedure TgsPeriodEdit.WndProc(var Message: TMessage);
var
  TmpText: string;
  Txt1, Txt2: string;
  fmt: string;
  NewDate1, NewDate2: TDateTime;
  OldDate1, OldDate2: TDateTime;
  Date1Ok, Date2Ok: Boolean;

  function CheckDate(Txt: string; Part: Integer): TDateTime;
  var
    Y,M,D: Integer;
//    OldD,OldM: Integer;
  begin
    ListDateText(Txt, Y,M,D, Part);
//    OldD := D; OldM := M;
    if D > _DaysPerMonth(Y, M) then
      D := _DaysPerMonth(Y, M);
    if D = 0 then D := 1;

    if M > 12 then M := 12
    else if M = 0  then M := 1;

//    if (OldD = D) or (OldM = M) then
//      exit;
  //при годе из двух цифр EncodeDate выдавало начало эры
  //Result := EncodeDate(Y, M, D);
    if FLenY = 4 then Fmt := '%.2d.%.2d.%.4d' else Fmt := '%.2d.%.2d.%.2d';
    Result := StrToDate(format(Fmt,[D, M, Y]));

  end;{<- function CheckDate}
//var  B,E: Integer;
begin
  if (csDesigning in ComponentState) then begin
    inherited;
    exit;
  end;

  case Message.Msg of
    WM_SETTEXT:
    begin
      inherited;

      TmpText:=strpas(PChar(Message.LParam));

      FPeriod.FAllowDateEnd := FDiapason;// and (pos('-', TmpText) > 0);

      Txt1 := copy(TmpText, arBeg[1] + 1, FLenDate);
      Txt2 := copy(TmpText, arBeg[4] + 1, FLenDate);
      if FDiapason and (Txt2 = '') then begin {в TraceItems одна дата, а режим диапазона}
        Txt2 := BlankDate(FLenY);
        TmpText := Txt1 + '-' + Txt2;
      end;  
     //(pos('_', GetText1)=0)   (pos('_', GetText2)=0)
      Date1Ok := (pos('_', Txt1) = 0);
               //?? разобраться почему Txt2 первично пустое
      Date2Ok := (Txt2 <> '') and (pos('_', Txt2) = 0) and (pos('-', TmpText) > 0);

      OldDate1 := FPeriod.DBeg; OldDate2 := FPeriod.DEnd;
      NewDate1:=0; NewDate2:=0;{чтобы не было warning}

      if Date1Ok then
        NewDate1 := CheckDate(TmpText, 1);
      if Date2Ok then
        NewDate2 := CheckDate(TmpText, 2);

      if Date1Ok then FPeriod.DBeg := NewDate1;  //SetDate1(NewDate1);
      if Date2Ok then FPeriod.DEnd := NewDate2;  //SetDate2(NewDate2);

      if (Date1Ok)  // and (Date{PE} <> NewDate1
        or (Date2Ok)  then // and EndDate <> NewDate2
      begin                                      {TODO: Задание 2}
        if FDiapason and Date1Ok and Date2Ok and ReadyDate(1) and ReadyDate(1)
          and ((NewDate1 > EndDate) or (NewDate2 < Date{PE})) then
        begin
          ShowMessage('Начальная дата периода не может быть больше его конечной даты.');

          if NewDate1 > EndDate then FPeriod.DBeg := OldDate1;
          if NewDate2 < Date{PE} then FPeriod.DEnd := OldDate2;
          if FPeriod.DBeg > FPeriod.DEnd then FPeriod.DBeg := FPeriod.DEnd;
          TmpText := FPeriod.GetTextPeriod;
        end else
        begin
          if FDiapason then begin
            Txt1 := copy(TmpText, arBeg[1] + 1, FLenDate);
            Txt2 := copy(TmpText, arBeg[4] + 1, FLenDate);

            if Date1Ok and Date2Ok then
              TmpText := FPeriod.GetTextPeriod
            else begin
              if not Date1Ok then TmpText := Txt1 + '-' + FPeriod.GetTextPeriod(2)
              else if not Date2Ok then TmpText := FPeriod.GetTextPeriod(1) + '-' + Txt2;
            end;
          end else
            TmpText := FPeriod.GetTextPeriod;
        end;
        if Text <> TmpText then begin
          Text := TmpText;
          FKeepText := Text;
        end;

      end;
    end;

//    EM_SETSEL:  begin
//        B:= Message.WParam; E:= Message.LParam;
//        if E-B=3 then
//          B:=B;
//        case B of
//           0..1: ;
//          17..20: ;
//        end;
//        inherited;
//    end;
//
//    EM_GETSEL:    begin
//        inherited;
//    end;
//
//    WM_LBUTTONDOWN:
//    begin
//      if FDropWindow.Visible then
//        TmpText := '';{dbg}
//
//      inherited;
//    end;

  else
    inherited;
  end;
end;

//!! используется лишь один раз
procedure TgsPeriodEdit.ListDateText(DateText: string; var Y, M, D: Integer; Part: Integer);
var
  BegD: Integer; //начало даты
begin
  BegD := iif(Part = 1, arBeg[1] + 1, arBeg[4] + 1); {12''}

  D := StrToInt( Copy(DateText, BegD, 2) );
  M := StrToInt( Copy(DateText, BegD + 3, 2) );
  Y := StrToInt( Copy(DateText, BegD + 6, FLenY) );
end;

function TgsPeriodEdit.ReadyDate(Part: Integer): Boolean;
var
  Txt: string;
begin
  if Part < 4 then Txt := GetText1 else Txt := GetText2;
  Result := Pos('_', Txt) = 0;
end;

procedure TgsPeriodEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
//  Message.Result := Message.Result or DLGC_WANTTAB;
end;

procedure TgsPeriodEdit.KeyPress(var Key: Char);
var
  Tmp : string;
  I: Integer;
  Beg, Len, Part: Integer;
begin
//   if ReadOnly then
//     Key := #0

    case Key of
      '~': begin
             FurtherSelLen(SelStart, +1, Beg,Len, 0);
             if ( (SelStart = Beg) and ((SelLength > Len) or (SelLength = 0)) )
               or (SelStart <> Beg) then
                             SelRange(Beg, Len);
           end;
      #27: begin
             Text := FPeriod.DatesToText;
           end;
       #8: begin
        FurtherSelLen(SelStart, +1, Beg,Len, 0);
        Text := ReplaceSubStr(Text, StringOfChar('_',Len), Beg+1,Len);
        FurtherSelLen(Beg, 0, Beg,Len, -1);
        if (pos('-', Text) = 0) and (Beg >= arBeg[4]) then begin
          Beg := arBeg[3]; Len := arLen[3];
        end;
        SelRange(Beg,Len);
      end;
      #32: begin
        Part := FurtherSelLen(SelStart, 0, Beg,Len, 0);
        case Part of
          1,4: Tmp := ReplaceSubStr(Text, TextPartOfNow(1,FLenY), Beg + 1, Len);
          2,5: Tmp := ReplaceSubStr(Text, TextPartOfNow(2,FLenY), Beg + 1, Len);
          3,6: Tmp := ReplaceSubStr(Text, TextPartOfNow(3,FLenY), Beg + 1, Len);
        end;
        Text := Tmp;
        FurtherSelLen(Beg, 0, Beg,Len, 1);
        if (pos('-', Text) = 0) and (Beg >= arBeg[4]) then begin
          Beg := arBeg[1]; Len := arLen[1];
        end;
        SelRange(Beg, Len);

      end;

     '.': begin
             Part := FurtherSelLen(SelStart, 0, Beg,Len, 0);
             if Part > 0 then
             begin
               Tmp := StringReplace(copy(Text, Beg + 1, Len), '_', '', [rfReplaceAll]);
               if length(Tmp)>0 then begin
                 Text := ReplaceSubStr(Text, BlankBefore('0', Tmp, Len), Beg+1,Len);
                 FurtherSelLen(Beg, 0, Beg,Len, 1);
                 if (pos('-', Text) = 0) and (Beg >= arBeg[4]) then begin
                   Beg := arBeg[1]; Len := arLen[1];
                 end;
                 SelRange(Beg, Len);
               end
             end;
          end;
     '-': begin
            if FDiapason then begin
              //if (Length(Text) < FLenDate + 1) then Text := Text + '-' + BlankDate(FLenY);
              SelRange(arBeg[4],arLen[4]);
            end;
          end;
'0'..'9': begin
            Part := FurtherSelLen(SelStart, 0, Beg,Len, 0);
            case Part of
              1,2, 4,5, 3,6:  begin
                 Tmp := StringReplace(copy(Text, Beg+1, Len), '_', '', [rfReplaceAll]);
                 //если часть даты полностью набрана, то её убираем и набираем по новой
                 if Length(Tmp) = Len then Tmp := '';

                 //при добавление цифры получаем законченную часть даты
                 //проверяем её на правильность
                 if Length(Tmp) > Len-2 then begin
                   if (Part in [1,4]) and (StrToInt(Tmp+Key) in [1..31]) //день
                      or (Part in [2,5]) and (StrToInt(Tmp+Key) in [1..12])//месяц
                      or (Part in [3,6]) and (FLenY=4) and (StrToInt(Tmp+Key) > 1000) then
                   begin
                     Text := ReplaceSubStr(Text, Tmp+Key, Beg + 1, Len);
                     if (pos('-', Text) = 0) and (Beg = arBeg[3]) or (Beg = arBeg[6]) then
                      {Part := 1}{круговорот}
                     else
                      Inc(Part);

                     SelRange(arBeg[Part], arLen[Part]);//передвигаемся вправо
                   end
                   else //если часть даты неправильная, то её убираем и набираем по новой
                     Tmp := '';
                 end;

                 //ещё не всё набрано
                 if Length(Tmp) <= Len-2 then begin //BlankBefore
                   Text := ReplaceSubStr(Text, BlankAfter('_', Tmp + Key, Len),
                     Beg + 1, Len);
                   I := Len - Length(Tmp) - 1;
                   //устар.    было при выравнивания вправо
                   //SelRange(Beg + I, Len - I);//выделяем только цифровую часть даты
                   SelRange(Beg, Len - I);//выделяем только цифровую часть даты
                 end;

               end
               else begin // разделитель дат '.' или частей даты '-'
                   Part := FurtherSelLen(SelStart, 1, Beg,Len, 0);
                   if Part < 6 then begin
                     Beg := arBeg[Part+1]; Len := arLen[Part+1];
                   end;
                   SelRange(Beg, Len);
                 end;
               end; { <- case SelStart у цифр}

          end{цифры}
          else begin
            //FTimer.Enabled := True;
          end;
    end; { <- case Key }
    //FSelStart := SelStart;
    //FSelLen := SelLength;

    FMetaStr := FMetaStr + Key;
    Key := #0;
    inherited KeyPress(Key);
end;  { <- procedure TgsPeriodEdit.KeyPress  }

procedure TgsPeriodEdit.PeriodTextToHistory;
var
  Txt1, Txt2: string;
  IndexH: Integer;
begin
  Txt1 := copy(Text, arBeg[1] + 1, FLenDate);
  Txt2 := copy(Text, arBeg[4] + 1, FLenDate);

  if (pos('_', Txt1) = 0) and (Txt2 = '')
    or (pos('_', Txt1) = 0) and (Txt2 <> '') and (pos('_', Txt2) = 0) then
  begin

    FAllowHistoryLoad := false;
    IndexH := FDropWindow.lbHistory.Items.IndexOf(Text);
    if IndexH > 0 then begin
      FDropWindow.lbHistory.Items.Delete(IndexH);
      FTraceItems.Delete(IndexH);
    end;
    if IndexH <> 0 then begin  // если нет(-1) или есть и не верхний
      FDropWindow.lbHistory.Items.InsertObject(0, Text, TObjStr.Create(Text) );
      FTraceItems.InsertObject(0, Text, TObjStr.Create(Text) );
    end;
    FAllowHistoryLoad := True;

  end;
end; { <- TgsPeriodEdit.PeriodTextToHistory}


function TgsPeriodEdit.ValidTraceItem(Item: String; var PeriodAsStr: string): Boolean;
var
  p,J: Integer;
  Txt1, Txt2: string;
begin
  p := pos('-', Item);
  if p > 0 then begin
    txt2 := copy(Item, p + 1, Length(Item));
  end;  
  if p = 0 then
    txt1 := Item
  else
    txt1 := copy(Item, 1, p - 1);

  try
    StrToDate(Txt1); // raise ERangeError.Create('Некорректная дата');
    if p > 0 then StrToDate(Txt2);
    PeriodAsStr := Item;
    Result := True;
  except
    PeriodAsStr := '';
    for J:= 1 to 4 do begin
//примеры: '1979 год' 'IV-й квартал 1979 года' 'июнь 1979 года' '3-ая неделя 1979 года'
      PeriodAsStr := FmtPeriod(Item, J, FPeriod);
      if PeriodAsStr <> '' then
        break;
    end;
    Result := (PeriodAsStr <> '');
  end;
end;

//выполняется при загрузке компоненты и по таймеру
//проверяет не изменилась ли внешняя история, если да, то меняет внутреннюю
//историю на внешнюю
//Прим. На момент изменения внутренней истории FAllowHistoryLoad выставляется
//в ложь, чтобы исключить срабатывания по таймеру
//Прим. при изменении внутренней истории аналогично изменяется и внешняя
procedure TgsPeriodEdit.HistoryLoad;
var
  I: Integer;
  Txt: string;
begin
  with FDropWindow do
    if (lbHistory.Items.Text <> FTraceItems.Text) then
    begin
      lbHistory.Clear;
      for I := FTraceItems.Count - 1 downto 0 do begin
        if ValidTraceItem(FTraceItems[I], Txt) then
          lbHistory.Items.InsertObject(0, FTraceItems[I], TObjStr.Create(Txt))
        else
          FTraceItems.Delete(I);
      end;

      if (lbHistory.Items.Count > 0) then begin
        lbHistory.ItemIndex := 0;
        DoOnChangePeriod(lbHistory, false)
  //      Self.Perform(WM_SETTEXT, 0, Longint(TObjStr(lbHistory.Objects[0])).Text);
      end;
    end;{<- if}
end;

procedure TgsPeriodEdit.KeyDown(var Key: Word; Shift: TShiftState);
var
  Offs: Integer;
  Dat: TDate; tp: TTypePeriod;
  Beg,Len,Part: Integer;
begin
  if (Key = VK_DOWN) and not (ssCtrl in Shift) then begin
    DoOnDropDownClick(Self);
    Key := 0;
  end;

  if Key = VK_RETURN then begin
    ArrangePeriodText;
    PeriodTextToHistory;
    Key := 0;
  end;

  if Key = VK_DELETE then  begin
    FurtherSelLen(SelStart, +1, Beg,Len);
    Text := ReplaceSubStr(Text, StringOfChar('_',Len), Beg+1,Len);
    SelRange(Beg,Len);
  end;

  Part := PartInText(SelStart);
  if (ssCtrl in Shift)
    and ((Key = VK_UP) or (Key = VK_DOWN)) and ReadyDate(Part)
    {and (not ReadOnly)} then
  begin
    Dat := iif(SelStart < arBeg[4], GetDate1, GetDate2);
    Offs := iif(Key = VK_UP, 1, -1);
    tp := tpDay;{чтобы не было warning}
    case Part of 1,4: tp := tpDay; 2,5: tp := tpMonth; 3,6: tp := tpYear; end;
    FurtherSelLen(SelStart, +1, Beg,Len);//запоминаем тек. выделение
    dat := NextDate(dat, tp, offs);
    if SelStart < arBeg[4] then SetDate1(dat) else SetDate2(dat); 
    //при изменении даты выделяются 2 начальные цифры
    SelRange(Beg,Len);//поэтому восстанавливаем выделение

    Key := 0;
  end; {  <- Key = VK_UP) or (Key = VK_DOWN)  }

  if (Key = VK_RIGHT) {and (SelLength > 1)} then begin
    FurtherSelLen(SelStart, +1, Beg,Len, +1);
    SelRange(Beg,Len);
  end;

  if (Key = VK_LEFT) {and (SelLength > 1)} then begin
    FurtherSelLen(SelStart, -1, Beg,Len, -1);
    if (pos('-', Text) = 0) and (Beg >= arBeg[4]) then
      Beg := arBeg[3];
    SelRange(Beg,Len);
  end;

  if (Key = VK_HOME) then begin
    SelRange(0,2);
  end;
  if (Key = VK_END) then begin
    if pos('-', Text) = 0 then SelRange(arBeg[3],arLen[3])
    else SelRange(arBeg[6],arLen[6]);
  end;

  if (Key in [VK_DELETE, VK_LEFT, VK_RIGHT, VK_HOME, VK_END, VK_UP] ) then begin
    Beg := SelStart; Len := SelLength;
    ArrangePeriodText(SelStart);
    //!!! временное решение, в будущем отказаться от повторного SelRange, и вначеле его не делать
    // устанавливать переменные начала и длины выделения и после выравнивания
    // один применять SelRange
    if (Beg <> SelStart) or (Len <> SelLength) then
      SelRange(Beg, Len);
  end;

  Key := 0;
  inherited KeyDown(Key, Shift);
end;  {  <- procedure TzPeriodEdit.KeyDown }

procedure TgsPeriodEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  OldSelStart: Integer;
  Part,Beg,Len: Integer;
begin
  if (Button = mbLeft) then begin
// if not Focused and CanFocus then
//      SetFocus;
    inherited MouseDown(Button, Shift, X, Y);

    OldSelStart := SelStart;
    ArrangePeriodText;
    SelStart:= OldSelStart;

    Part := FurtherSelLen(SelStart, 1, Beg,Len);
    if Part > 0 then
      SelRange(Beg, Len)
    else
      SelRange(0, arBeg[6] + arLen[6]);
   end;
end;

procedure TgsPeriodEdit.CreateWnd;
begin
  inherited CreateWnd;
  if not (csDesigning in ComponentState) then
  begin
    SetEditRect;
    SelStart := Length(Text) + 1;
  end;
end;

procedure TgsPeriodEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CLIPCHILDREN or ES_MULTILINE;
  Params.Style := Params.Style and (not ES_WANTRETURN);
end;

procedure TgsPeriodEdit.DoOnDropDownClick(Sender: TObject);
var
  PEdit, PDrop: TPoint;
  J: Integer;
  L,T,H,W,DX: Integer;
  //DY: Integer;
begin
  if FDropWindow = nil then begin
    SetFocus;
    exit;
  end;

  if Now - FDropWindow.FTimeKillFocus < 0.0000033 then begin
    FDropWindow.FTimeKillFocus := Now;
    SetFocus;
    exit;
  end else
    FDropWindow.FTimeKillFocus := Now;

  if FDropWindow.Visible then begin
    FDropWindow.BackDates;
    FDropWindow.Hide;
    SetFocus;
    exit;
  end;

  FDropWindow.Width := 2 * FDropWindow.FCal1.Width + 12 + 4;
  FDropWindow.Height := 257;

  PEdit := ClientToScreen(Point(0, 0)) ;

  //если выпадающее окошко выходит за пределы экрана справа, то оно
  //выравнивается по правой части окошка редактирования, иначе по левой
  if PEdit.X + FDropWindow.Width > GetSystemMetrics(SM_CXSCREEN) then
    PDrop.X := PEdit.X + Width - FDropWindow.Width - 2
  else
    PDrop.X := PEdit.X - 2;

  //если выпадающее окошко выходит за пределы экрана снизу, то оно
  //отображается над окошком редактирования, иначе под ним
  if PEdit.Y + Height - 1 + FDropWindow.Height > GetSystemMetrics(SM_CYSCREEN) then
    PDrop.Y := PEdit.Y - FDropWindow.Height - 2
  else
    PDrop.Y := PEdit.Y + Height - 1;

  //перед переходом к выпадающему окошку сохраняем даты и текст окошка редактирования
  FOK := false;
  FKeepDate := Date{PE};
  FKeepEndDate := EndDate;
  FKeepText := Text;

  with FDropWindow do
  begin
    AssignCalDate(FCal1);
    AssignCalDate(FCal2);

    FDropText := '';
    //Размеры окошка и его контролов
    SetBounds(PDrop.X, PDrop.Y, Width, Height);

    W := 45; H:= 21;
    FBtnOk.SetBounds( (Width - 2 * W) div 3 , Height - H - 8, W, H);
    //W := 14; H:= 14;
    //FBtnCancel.SetBounds(Width - H - 3, Height - H - 3,    W, H);
    W := 45; H:= 21;
    FBtnCancel.SetBounds( w + 2 * ((Width - 2 * W) div 3), Height - H - 8, W, H);

    FPages.SetBounds(0, 0, Width - 2, FBtnOk.Top - 7);

    W := FCal1.Width; H := FCal1.Height;
    T := (FTabCal.Height - H) div 2;
    if FDiapason then begin
      FCal1.SetBounds(4, T, W, H);
      FCal2.SetBounds(W + 8, T, W, H);
    end else begin
      FCal1.SetBounds(Width div 4, T, W, H);
    end;

    //W := FPages.Width div 2; H := FTabCal.Height;
    //lbHistory.SetBounds(3, 2, W - 4, H - 4);
    //lbMeta.SetBounds(W + 2, 2, W - 4, H - 4);
    lbHistory.Align := alClient;
    lbMeta.Align := alClient;

    L:=5; W := 75 + 10;
    DX:= Trunc( (Width - 3*W - 50 - 5*2) / 2) - 1;

    H := FTabCal.Height;
    lbQuarter.SetBounds(L, H - 15, W, 15);
    FBtnDn.SetBounds(L, lbQuarter.Top - 10 - 2, W, 10);
    FBtnUp.SetBounds(L, 1, W, 10);
    lbYear.SetBounds(L, FBtnUp.BoundsRect.Bottom,
      W, FBtnDn.Top - FBtnUp.BoundsRect.Bottom - 1);
//    lbYear.IntegralHeight := True;
//    H := (lbYear.Height div lbYear.ItemHeight)*lbYear.ItemHeight;
//    DY := (lbYear.Height - H) Div 2;
//    FBtnUp.Top:= FBtnUp.Top+Dy;
//    lbYear.Top:= lbYear.Top+Dy;
//    FBtnDn.Top:= FBtnDn.Top-Dy;

    H := (lbMonth.ItemHeight) * 12 + 1;
    T := (FTabDpz.Height - H) div 2;
    if T < 2 then begin
      T := 2; H := FTabCal.Height - 4;
    end;
    lbMonth.SetBounds(   L+W+DX, T,    W, H);
    lbWeek.SetBounds(L+2*(W+DX), T, W+50, H);
//    FBtDbg.SetBounds(99,FTabCal.Height-T, 55, 25);

    Show;
    SetFocus;

    //На активной странице фокус передаём 1-му управляющему элементу
    with FPages.ActivePage do
    for J:=0 to ControlCount - 1 do
      if (Controls[J] is TgsCustomListBox)
        or (Controls[J] is TgsMonthCalendar) then
      begin
        TWinControl(Controls[J]).SetFocus;
        break;
      end;
  end;

  ArrangePeriodText;
  //selRange(0, Length(Text) + 1);
  //SetFocus;
end; {<- TgsPeriodEdit.DoOnDropDownClick}

procedure TgsPeriodEdit.DoOnTimer(Sender: TObject);
var
  II,I,IFound: Integer;
  Txt: string;
begin
  with FDropWindow,lbYear do begin
    FBtnUp.Enabled := ItemIndex > 0;{lbYear.TopIndex > 0;}
    FBtnDn.Enabled := ItemIndex < Items.Count - 1;
      {(Items.Count - TopIndex)*ItemHeight > lbYear.Height;}
  end;
  if FAllowHistoryLoad then
  begin
    FAllowHistoryLoad := false;
    HistoryLoad;
    FAllowHistoryLoad := True;
  end;

  if Focused then begin
    Perform(WM_Char, Ord('~'), 0);
//   GetCursorPos;
//   mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
//   mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  end;
  try
  IFound := 0;
  if FMetaStr <> '' then begin
    Txt := AnsiLowerCase(FMetaStr);
    for II:=1 to 2 do begin
      IFound := 0;
      for I:=1 to Length(ArMeta[II]) do
        if Txt = ArMeta[II][I] then begin
          IFound := I;
          break;
        end;
      if IFound > 0 then
        break;
    end;
  end;

  if FMetaStrLast = FMetaStr then begin
    FTimer.Tag := FTimer.Tag + 1;
    if FTimer.Tag > 3 then
    begin
      try
        if IFound > 0 then begin
          FTimer.Tag := IFound;
          FDropWindow.DoOnChangePeriod(Sender, True);
        end;
      finally
        FTimer.Tag := 0;
        FMetaStr := '';
      end;
    end;
  end else begin
    FTimer.Tag := 0;
    FMetaStrLast := FMetaStr;
  end;

  finally

  end;
end;

constructor TgsPeriodEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  ControlStyle := ControlStyle - [csSetCaption];
  MaxLength := 21;
  Width := 140;

  FPeriod := TPeriod.Create;
  SetDateFormat(dfDefault);//!!
  //FLenY := 4
  FDiapason := True;

  FYearPeriod := _getYear(now);

  Text := BlankDate(FLenY)+'-'+BlankDate(FLenY);
  FKeepText := Text;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := false;
  FTimer.Interval := 170;
  FTimer.OnTimer := DoOnTimer;

  FMetaStr := '';
  FMetaStrLast := '';

  FDropButton := TgsButton.Create(Self);
  FDropButton.Glyph.LoadFromResourceName(hInstance, 'DNBTN');
  FDropButton.ControlStyle := FDropButton.ControlStyle - [csAcceptsControls, csSetCaption] +
    [csFramed, csOpaque, csCaptureMouse];
  FDropButton.TabStop := false;

  FDropButton.Caption := '';
  FDropButton.Width := DropBtnWidth;
  FDropButton.Height := DropBtnHeight;
  FDropButton.Visible := True;
  FDropButton.Parent := Self;
  FDropButton.Cursor := crArrow;
  //FDropButton.OnMouseMove := DoOnButtonMouseMove;
  FDropButton.OnClick := DoOnDropDownClick;

  FTraceItems := TStringList.Create;
  FAllowHistoryLoad := false;

  if not (csDesigning in ComponentState) then
  begin
    FDropWindow := TgsDropWindow.Create(Self);
    FDropWindow.FPeriodEdit := Self;
    FDropWindow.Parent := Self;

    FCalBegDate := FDropWindow.FCal1.Date;
    FCalEndDate := FDropWindow.FCal2.Date;

    FDropButton.FDropWindow := FDropWindow;
  end;

  ArMetaFill;//дублирует метасимволы для английской раскладки клавиатуры
end;

destructor TgsPeriodEdit.Destroy;
begin
  FTraceItems.Free;
  FPeriod.Free;
  inherited;
end;

procedure TgsPeriodEdit.Loaded;
var
  I,J: Integer;
  D: TDateTime;
begin
  inherited Loaded;

//  if FDropButton <> nil then
//  begin
//    FDropButton.Is3D := Ctl3d;
//    FDropButton.Repaint;
//  end;

  if FDropWindow = nil then
    exit;

  SelStart := 0; SelLength := 2;

  with FDropWindow do
  begin
    FTabHistory.PageControl := FPages;
    FTabCal.PageControl := FPages;
    FTabDpz.PageControl := FPages;
    FTabHelp.PageControl := FPages;

    SetPageIndex(PageIndex);
    //dbg PageIndex := 2;
    {$IFNDEF MCALENDAR}
    FCal1.DoSize; FCal2.DoSize;
    {$ENDIF}
    FCal2.Visible := FDiapason;

    for I := 1970 to 2099 do begin
      lbYear.Items.Add(IntToStr(I));
      if I = FYearPeriod then
        lbYear.ItemIndex := lbYear.Items.Count - 1;
    end;

    for I :=1 to 4 do
      lbQuarter.Items.Add(ArQuarter[I]);//'IV'
    {чтобы не было гор. скроллинга вправо при нажатии на крайний правый элемент}
    {уменьшаем ширину элемента на единицу от дельфийского }
    {см. TCustomListBox.SetColumnWidth в StdCtrl.pas}
    with lbQuarter do
      if (Columns > 0) and (lbQuarter.Width > 0) then
      begin                      {уменьшаем ширину на единицу}
        I := (Width + Columns - 3 - 1) div Columns;
        if I < 1 then I := 1;
        SendMessage(Handle, LB_SETCOLUMNWIDTH, I, 0);
      end;

    for I := 1 to 12 do
       lbMonth.Items.Add(LongMonthNames[I]);//'Январь'

    //недели !!!
    D := EncodeDate(2008,12,31) - EncodeDate(2008,1,1) + 1;
    J := Trunc(D / 7);
    if Frac(J / 7) > 0 then
      J := J + 1;
    for I := 1 to J do
      lbWeek.Items.Add(IntToStr(I));

    //Метасимволы
    lbMeta.Items.Text:=
     // 'Метасимволы'#13''+
    ' c - сегодня'#13''+
    ' з - завтра'#13''+
    ' в - вчера'#13''+
    ' н - текущая неделя'#13''+
    ' пн - прошлая неделя'#13''+//5
    ' сн - следующая неделя'#13''+
    ' м - текущий месяц'#13''+
    ' пм - прошлый месяц'#13''+
    ' см - следующий месяц'#13''+
    ' к - текущий квартал'#13''+//10
    ' пк - прошлый квартал'#13''+
    ' ск - следующий квартал'#13''+
    ' г - текущий год'#13''+
    ' пг - прошлый год'#13''+
    ' сг - следующий год'#13;//15

  end; {<- with FDropWindow}

  HistoryLoad;

  FTimer.Enabled := True;
  FAllowHistoryLoad := True;
end;{ <- TgsPeriodEdit.Loaded}

{***************}

function TgsPeriodEdit.GetText1: string;
begin
  Result := copy(Text, arBeg[1] + 1, FLenDate);
end;

function TgsPeriodEdit.GetText2: string;
begin
  Result := copy(Text, arBeg[4] + 1, FLenDate);
end;

function TgsPeriodEdit.GetDate1: TDate;
begin
  Result := FPeriod.DBeg;
end;

function TgsPeriodEdit.GetDate2: TDate;
begin
  Result := FPeriod.DEnd;
end;

procedure TgsPeriodEdit.SetDate1(Value: TDate);
begin
  if FPeriod.DBeg <> Value then begin
    FPeriod.DBeg := Value;
    {TODO: Задание 3}
    if Diapason then
      Text := FPeriod.GetTextPeriod(1) + '-' + getText2
    else
      Text := FPeriod.GetTextPeriod(1);
  end;
end;

procedure TgsPeriodEdit.SetDate2(Value: TDate);
begin
  if FPeriod.DEnd <> Value then begin
    FPeriod.DEnd := Value;
    if Diapason then
      Text := getText1 + '-' + FPeriod.GetTextPeriod(2)
    else
      Text := FPeriod.GetTextPeriod(2);
  end;
end;

procedure TgsPeriodEdit.SetDates(ADate: TDateTime; TypePeriod: TTypePeriod;
  Offset: Integer = 0);
begin
  FPeriod.SetDates(ADate, TypePeriod, Offset);
  Text := FPeriod.DatesToText;
end;

procedure TgsPeriodEdit.AssignOrdPeriod(OrdPeriod,Year: Integer; TypePeriod: TTypePeriod);
begin
  FPeriod.SetOrdPeriod(OrdPeriod, Year, TypePeriod);
  Text := FPeriod.DatesToText;
end;

procedure TgsPeriodEdit.SetDateFormat(const Value: TDTDateFormat);
var DateFormat: string;
    I, Len: Integer;
begin
  if (FDateFormat <> Value) or (FLenY = 0) then
  begin
    FDateFormat := Value;

    if (Value = dfDefault) then begin
      DateFormat := lowercase(ShortDateFormat);
      Len := 0;
      for I:=1 to Length(DateFormat) do
        if DateFormat[I]='y' then Inc(Len);

      if Len<=2 then Len := 2
      else Len := 4;
    end else if Value = dfLong then
      Len := 4
    else
      Len := 2;

    if Len = 4 then begin
      FLenY := 4;
      FLenDate := 10;//FLenDate := arBeg[3]+FLenY
    end else begin
      FLenY := 2;
      FLenDate := 8;
    end;

    if FLenY = 4 then begin
      move(ar1Beg,arBeg, SizeOf(arBeg));
      move(ar1Len,arLen, SizeOf(arLen));
    end else begin
      move(ar2Beg,arBeg, SizeOf(arBeg));
      move(ar2Len,arLen, SizeOf(arLen));
    end;

    FPeriod.FLenYear := FLenY;
    Text := FPeriod.DatesToText;
  end;

end; {<- TgsPeriodEdit.SetDateFormat}


procedure TgsPeriodEdit.SetDiapason(const Value: Boolean);
begin
  if (FDiapason <> Value) then
  begin
    FDiapason := Value;
    FPeriod.FAllowDateEnd := FDiapason; //and (pos('-', Text) > 0);
    Text := FPeriod.DatesToText;

    if FDropWindow = nil then
      exit;

    FDropWindow.FCal2.Visible := FDiapason;
  end;
end;

procedure TgsPeriodEdit.SetPageIndex(const Value: Integer);
begin
  if Value > 3 then
    raise ERangeError.Create('Некорректный индекс страницы');

  if (FPageIndex <> Value) then
    FPageIndex := Value;

  if FDropWindow = nil then
    exit;

  if Value <> FDropWindow.FPages.ActivePageIndex then
    FDropWindow.DoOnPageChange(Self);

end;

procedure TgsPeriodEdit.SetTraceItems(Values: TStrings);
var
  I: Integer;   z: string;
  ErrMsg: string;
begin
  ErrMsg := '';

  FTraceItems.Clear;

  for I := Values.Count - 1 downto 0 do
  begin
    if not ValidTraceItem(Values[I], z) then
    begin
      ErrMsg := ErrMsg + IntToStr(I)+'-й элемент: '+Values[I]+#13#10;
      Values.Delete(I);
    end;
  end;

  if ErrMsg <> '' then
    ShowMessage('Некорректные значения элементов TraceItems пропущены'#13#10+ErrMsg);

  FTraceItems.Assign(Values);
  //ShowMessage(Values.Text);//dbg
end;

procedure TgsPeriodEdit.SetYearPeriod(const Value: Integer);
var
  I: Integer;
begin
  if (FYearPeriod <> Value) then
  begin
    FYearPeriod := Value;
    if FDropWindow <> nil then begin
      I := FDropWindow.lbYear.Items.IndexOf( IntToStr(Value) );
      FDropWindow.lbYear.ItemIndex := I;
    end;  
  end;
end;

{TODO: TgsDropWindow}

//procedure TgsDropWindow.WMMouseActivate(var Message: TWMMouseActivate);
//begin
//  Message.Result := MA_NOACTIVATE;
//end;

procedure TgsDropWindow.WMKillFocus(var Message: TWMKillFocus);
//var b: boolean;
begin
//  b:=(Message.FocusedWND <> Handle)
//      and (Message.FocusedWND <> FPeriodEdit.Handle)
//      and not FocusedWNDIsChild(Self, Message.FocusedWND);

  if not (csDesigning in ComponentState) and Visible then
  begin
    if (Message.FocusedWND <> Handle)
      and (Message.FocusedWND <> FPeriodEdit.Handle)
//      and (Message.FocusedWND = TWinControl(FPeriodEdit.Owner).Handle)
      and not FocusedWNDIsChild(Self, Message.FocusedWND) then
    begin
      BackDates;
      FPeriodEdit.SetFocus;
      Hide;
    end;
  end;

  inherited;
end;

procedure TgsDropWindow.DoOnBtnUpClick(Sender: TObject);
begin
  if (lbYear.ItemIndex <> -1) and (lbYear.ItemIndex <> 0) then
    lbYear.ItemIndex := lbYear.ItemIndex - 1;
  //lbYear.TopIndex := lbYear.TopIndex - 1;
end;

procedure TgsDropWindow.DoOnBtnDnClick(Sender: TObject);
begin
  if (lbYear.ItemIndex <> -1) and (lbYear.ItemIndex < lbYear.Items.Count - 1) then
    lbYear.ItemIndex := lbYear.ItemIndex + 1;
  //lbYear.TopIndex := lbYear.TopIndex + 1;
end;

procedure TgsDropWindow.BackDates;
begin
  FTimeKillFocus := Now; 
  with FPeriodEdit do
    if not FOK and ( (Date{PE} <> FKeepDate) or (Date{PE} <> FKeepDate)
      or (Text <> FKeepText) ) then
    begin
      Date{PE} := FKeepDate;
      EndDate   := FKeepEndDate;

      Text := FKeepText;
    end;
end;

procedure TgsDropWindow.DoOnBtnCancelClick(Sender: TObject);
begin
  BackDates;
  FPeriodEdit.SetFocus;
  FPeriodEdit.SelRange(0,2);
  Hide;
end;

procedure TgsDropWindow.DoOnBtnOkClick(Sender: TObject);
var
  IndexH: Integer;
begin
        //сейчас объект элемента листбокса для сравнения содержимого следов
        //не используется
        //IndexH := IndexOfObjStr(lbHistory.Items, FPeriodEdit.Text);

  FPeriodEdit.FAllowHistoryLoad := false;
  IndexH := lbHistory.Items.IndexOf(FDropText);
  if IndexH > 0 then begin// если есть и вверху, то не трогаем
    lbHistory.Items.Delete(IndexH);
    FPeriodEdit.FTraceItems.Delete(IndexH);
  end;
  if IndexH <> 0 then begin// если нет(-1) или есть и не верхний
    lbHistory.Items.InsertObject(0, FDropText, TObjStr.Create(FPeriodEdit.Text) );
    FPeriodEdit.FTraceItems.InsertObject(0, FDropText, TObjStr.Create(FPeriodEdit.Text) );
  end;
  FPeriodEdit.FAllowHistoryLoad := True;

  with FPeriodEdit do begin
    FOK := True;
    //FKeepDate := Date{PE};
    //FKeepEndDate := EndDate;
    //FKeepText := Text;

    SetFocus;
    SelRange(0,2);
  end;
  Hide;
end;

{$IFNDEF MCALENDAR}
procedure TgsDropWindow.DoOnDateChangeCalendar(Sender: TObject; FromDate, ToDate: TDateTime);
begin                               {TODO: Задание 1}
   if FPeriodEdit.FDiapason  {(FPeriodEdit.EndDate>0)}
     and ( (Sender= FCal1) and FPeriodEdit.ReadyDate(2) and (FCal1.Date > FPeriodEdit.EndDate) )
     or ( (Sender= FCal2) and FPeriodEdit.ReadyDate(1) and (FPeriodEdit.Date > FCal2.Date) )
   then                     {(FPeriodEdit.Date>0)}
   begin
      FSkipKillFocus := True;
      try
        MessageBox(0, 'Начальная дата периода не может быть больше его конечной даты.',
          'Неверный диапазон', MB_ICONWARNING  or MB_OK);

        AssignCalDate(TgsMonthCalendar(Sender));

        if not TWinControl(Sender).Focused then TWinControl(Sender).SetFocus;
//        raise EConvertError.Create('Начальная дата периода не может быть больше конечной даты.');//CreateFmt]
      finally
        FSkipKillFocus := false;
      end;
    end;
end;
{$ENDIF}

procedure TgsDropWindow.AssignCalDate(ACal: TgsMonthCalendar);
begin
   if ACal = FCal1 then
     FCal1.Date := FPeriodEdit.GetDate1 //FPeriodEdit.FCalBegDate
   else if ACal = FCal2 then
     FCal2.Date := FPeriodEdit.GetDate2;//FPeriodEdit.FCalEndDate;

   if ACal.Date = 0 then ACal.Date := Sysutils.Date;
end;

procedure TgsDropWindow.DoOnClickCalendar(Sender: TObject);
begin
  if FSkipKillFocus then exit;
  DoOnCalendarChange(Sender, false);
end;

procedure TgsDropWindow.DoOnDblClickCalendar(Sender: TObject);
begin
  if FSkipKillFocus then exit;
  DoOnCalendarChange(Sender, True);
end;

procedure TgsDropWindow.DoOnCalendarChange(Sender: TObject; CloseDropWindow: Boolean);
begin
  if Sender = FCal1 then begin
//    if ValidPeriod(FCal1) then begin
//      FPeriodEdit.FCalBegDate := FCal1.Date;
      FPeriodEdit.SetDate1(FCal1.Date);
//    end;
  end else
  if FPeriodEdit.FDiapason and (Sender = FCal2) then begin
//    if ValidPeriod(FCal2) then begin
//      FPeriodEdit.FCalEndDate := FCal2.Date;

      if pos('-', FPeriodEdit.Text) = 0 then
        FPeriodEdit.Text := FPeriodEdit.Text + '-' + BlankDate(FPeriodEdit.FLenY);
      FPeriodEdit.SetDate2(FCal2.Date);
//    end;
  end;

  FDropText := FPeriodEdit.Text;

  if CloseDropWindow then
    DoOnBtnOkClick(Sender);

end;{ <- TgsDropWindow.DoOnCalendarChange}

procedure TgsDropWindow.DoOnKeyDownDropWindow(Sender: TObject; var Key: Word;
  Shift: TShiftState);
//var Idbg: Integer;
begin
  if Key = VK_RETURN then begin
    if Sender = lbHistory then
      DoOnChangePeriod(Sender, True)
    else if Sender = lbMeta then
      DoOnChangePeriod(Sender, True)

    else if Sender = FCal1 then
      DoOnCalendarChange(Sender, True)
    else if Sender = FCal2 then
      DoOnCalendarChange(Sender, True)

    else if Sender = lbYear then
      DoOnChangePeriod(Sender, True)
    else if Sender = lbQuarter then
      DoOnChangePeriod(Sender, True)
    else if Sender = lbMonth then
      DoOnChangePeriod(Sender, True)
    else if Sender = lbWeek then
      DoOnChangePeriod(Sender, True);
  end;
//  if Sender = FPages then
//    Idbg:=1;

  if Key = VK_ESCAPE then begin
    BackDates;

    Hide;
    FPeriodEdit.SetFocus;
  end;
end; { <- TgsDropWindow.DoOnKeyDownDropWindow}


procedure TgsDropWindow.DoOnDblClickPeriod(Sender: TObject);
begin
  DoOnChangePeriod(Sender, True);
end;

procedure TgsDropWindow.DoOnClickPeriod(Sender: TObject);
begin
  DoOnChangePeriod(Sender, false);
end;

procedure TgsDropWindow.DoOnChangePeriod(Sender: TObject; CloseDropWindow: Boolean);
var
  Y: Integer;
  IndexM: Integer;
  TypePeriod: TTypePeriod;
  IPeriod: Integer;
  DateText: string;
begin

  if lbYear.ItemIndex <> -1 then
    Y := StrToInt(lbYear.Items[lbYear.ItemIndex])
  else
    Y := _getYear;

  IPeriod := Y;         //Инициализируем, чтобы не
  TypePeriod := tpYear; //"ругался" компилятор

  if Sender = lbYear then begin
    if lbYear.ItemIndex = -1 then
      exit;{это никогда не случится}
    FPeriodEdit.FYearPeriod := StrToInt( lbYear.Items[lbYear.ItemIndex] );

    Y := StrToInt(lbYear.Items[lbYear.ItemIndex]);
    IPeriod := Y;
    TypePeriod := tpYear;
    FDropText := Format(FmtYear,[Y]);
  end{<- год}
  else if Sender = lbQuarter then begin
    //FPeriodEdit.FQuarterIndex := lbQuarter.ItemIndex;
                //lbMonth.ItemIndex := 3 * ItemIndex + 2;
    IPeriod := lbQuarter.ItemIndex + 1;
    TypePeriod := tpQuarter;
    FDropText := Format(FmtQuarter, [lbQuarter.Items[lbQuarter.ItemIndex], Y]);
  end{<- квартал}
  else if Sender = lbMonth then begin
    //FPeriodEdit.FMonthIndex := lbMonth.ItemIndex;
                //lbQuarter.ItemIndex := ItemIndex div 3;
    IPeriod := lbMonth.ItemIndex + 1;
    TypePeriod := tpMonth;
    FDropText := Format(FmtMonth, [lbMonth.Items[lbMonth.ItemIndex], Y]);
  end{<- месяц}
  else if Sender = lbWeek then begin
    //FPeriodEdit.FWeekIndex := lbWeek.ItemIndex;
                //lbQuarter.ItemIndex := M div 3;
    IPeriod := lbWeek.ItemIndex + 1;
    TypePeriod := tpWeek;
    FDropText := Format(FmtWeek,[lbWeek.ItemIndex+1, Y]);
  end;{<- неделя}

  if (Sender = lbYear) or (Sender = lbQuarter)  or (Sender = lbMonth)
    or (Sender = lbWeek) then
  begin
    FPeriodEdit.FPeriod.FAllowDateEnd := FPeriodEdit.FDiapason;
    FPeriodEdit.AssignOrdPeriod(IPeriod, Y, TypePeriod);
  end
  else
  if (Sender = lbMeta)  or (Sender = lbHistory)
    or (Sender = FPeriodEdit.FTimer) then
  begin
    IndexM := -1;//если не -1, то даты(а) вычисляются на основе метасимвола

    if (Sender = FPeriodEdit.FTimer) then begin
      IndexM := FPeriodEdit.FTimer.Tag;
    end;

    if (Sender = lbMeta) then begin
      //раньше самый первый(0-ой) элемент был для информирования о содержимом
      //листбокса и не использовался для выбора метасимволов
      //if (lbMeta.ItemIndex < 1) then
      //  exit;
    //Отсчёт индекса метасимволов с единицы
      IndexM := lbMeta.ItemIndex + 1;
    end;

    if IndexM > 0 then begin
      FPeriodEdit.FPeriod.FAllowDateEnd := FPeriodEdit.FDiapason;

      case IndexM of
        1: FPeriodEdit.SetDates(now, tpDay);
        2: FPeriodEdit.SetDates(now, tpDay, 1);
        3: FPeriodEdit.SetDates(now, tpDay, -1);

        4: FPeriodEdit.SetDates(now, tpWeek);
        5: FPeriodEdit.SetDates(now, tpWeek, -1);
        6: FPeriodEdit.SetDates(now, tpWeek, 1);

        7: FPeriodEdit.SetDates(now, tpMonth);
        8: FPeriodEdit.SetDates(now, tpMonth, -1);
        9: FPeriodEdit.SetDates(now, tpMonth, 1);

        10: FPeriodEdit.SetDates(now, tpQuarter);
        11: FPeriodEdit.SetDates(now, tpQuarter, -1);
        12: FPeriodEdit.SetDates(now, tpQuarter, 1);

        13: FPeriodEdit.SetDates(now, tpYear);
        14: FPeriodEdit.SetDates(now, tpYear, -1);
        15: FPeriodEdit.SetDates(now, tpYear, 1);
      end;
    end;

    if Sender = lbHistory then begin
      if lbHistory.ItemIndex = -1 then
        exit;
      DateText := objstrText(lbHistory.Items, lbHistory.ItemIndex, FPeriodEdit.FLenY);
      FPeriodEdit.Text := DateText;
      FDropText := lbHistory.Items[lbHistory.ItemIndex];
    end else
      FDropText := FPeriodEdit.Text;

  end { <- if (Sender = lbMeta, FPeriodEdit.FTimer, lbHistory}
  else begin
    FPeriodEdit.SelRange(0,2);//dbg не должно такого быть
    exit;
  end;

  if CloseDropWindow then
    DoOnBtnOkClick(Sender);

end;{ <- TgsDropWindow.DoOnChangePeriod }

procedure TgsDropWindow.DoOnChildKeyPress(Sender: TObject; var Key: Char);
var I,EndI,J: Integer;
    isNextSelect: Boolean;
    isForward: Boolean;
    Delta: Integer;
begin
  { проверка куда двигаться назад или вперёд }
  isForward:= GetKeyState(VK_SHIFT) >= 0;

  with TWinControl(Sender) do begin
  try
    if Key = #9 then{табуляция}
    begin
      if isForward then begin
        I := 0;
        EndI := Parent.ControlCount - 1 + 1;
        Delta := 1;
      end else begin
        I := Parent.ControlCount - 1;
        EndI := 0 - 1;
        Delta := -1;
      end;

      while (I<>EndI) do
      begin
        if Parent.Controls[I] = Sender then
        begin
          isNextSelect := false;{}

          if Parent.Visible then
          begin
            J := I + Delta;
            while (J<>EndI) do  begin
              if (Parent.Controls[J] is TgsCustomListBox)
                or (Parent.Controls[J] is TgsMonthCalendar) then
              begin
                TwinControl(Parent.Controls[J]).SetFocus;
                isNextSelect := True;
                break;
              end;
              J := J + Delta;
            end;{ <- while}
          end;

          if not isNextSelect then
            with TPageControl(Parent.Parent) do
            begin
              SelectNextPage(isForward)
              {Обратный ход табуляции}
              //if GetKeyState(VK_SHIFT) >= 0 then
//              for J:=ActivePage.ControlCount - 1 downto 0 do
//                if (ActivePage.Controls[J] is TgsCustomListBox)
//                  or (ActivePage.Controls[J] is TgsMonthCalendar)
//                then begin
//                  TwinControl(ActivePage.Controls[J]).SetFocus;
//                  break;
//                end;

            end;{ <- with TPageControl(Parent.Parent)}

          break;
        end; { <- for if}
        I := I + Delta;
      end;
      Key:=#0;
    end;{ <- if Key = #9 }
    if not (Key in [#0,'0'..'9']) then begin
      //TgsPeriodEdit(Owner.Owner).FTimer.Enabled := True;
      TgsPeriodEdit(Owner.Owner).FMetaStr := TgsPeriodEdit(Owner.Owner).FMetaStr + Key;
    end;
    finally

    end;
  end;{ <- with}

end;{ <- TgsDropWindow.DoOnChildKeyPress}

procedure TgsDropWindow.DoOnPageChange(Sender: TObject);
var
  J: Integer;
begin
  with FPages do
  begin
    { первому элементу страницы с клавиатурным вводом даём фокус }
    if Sender = FPages then
      FPeriodEdit.PageIndex := FPages.ActivePageIndex
    else
      FPages.ActivePageIndex := FPeriodEdit.PageIndex;

    if FPages.ActivePageIndex = 1 then begin
      AssignCalDate(FCal1);
      AssignCalDate(FCal2);
    end;

    if Self.Visible then
      for J:=0 to ActivePage.ControlCount - 1 do
        if (ActivePage.Controls[J] is TgsCustomListBox)
          or (ActivePage.Controls[J] is TgsMonthCalendar)
        then begin
          TWinControl(ActivePage.Controls[J]).SetFocus;
          break;
        end;
  end;
end;

procedure TgsDropWindow.KeyPress(var Key: Char);
begin
   if not (Key in ['0'..'9']) then begin
     //FPeriodEdit.FTimer.Enabled := True;
     FPeriodEdit.FMetaStr := FPeriodEdit.FMetaStr + Key;
   end;

   Key := #0;
   inherited KeyPress(Key);
end;

procedure TgsDropWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP or WS_BORDER;
    ExStyle := WS_EX_TOOLWINDOW;
  end;
end;

constructor TgsDropWindow.Create(AOwner: TComponent);
var
  J: Integer;
begin
  inherited Create(AOwner);

  Color:=clBtnFace;
  TabStop := False;
  Visible := False;
//- IsFirst := True;
  FPeriodEdit := nil;

  FPages := TgsPageControl.Create(Self);
  FPages.Parent := Self;
  FPages.OnKeyDown := DoOnKeyDownDropWindow;
  FPages.OnChange := DoOnPageChange;

  FTabHistory := TTabSheet.Create(Self);
  FTabHistory.Parent := Self;
  FTabHistory.Caption := 'Что было';
  FTabHistory.Align := alClient;
  //^123^ FTabHistory.OnKeyDown := DoOnKeyDownDropWindow;

  FTabCal := TTabSheet.Create(Self);
  FTabCal.Parent := Self;
  FTabCal.Caption := 'Выбор дат';
  FTabCal.Align := alClient;

  FTabDpz := TTabSheet.Create(Self);
  FTabDpz.Parent := Self;
  FTabDpz.Caption := 'Диапазоны';
  FTabDpz.Align := alClient;

  FTabHelp := TTabSheet.Create(Self);
  FTabHelp.Parent := Self;
  FTabHelp.Caption := 'Подсказка';
  FTabHelp.Align := alClient;
  //^123^ FTabHistory.OnKeyDown := DoOnKeyDownDropWindow;


  lbHistory := TgsCustomListBox.Create(Self);
  lbHistory.Parent := FTabHistory;
  lbHistory.FLayout := 11;

  lbMeta := TgsCustomListBox.Create(Self);
  lbMeta.Parent := FTabHelp;
  lbMeta.FLayout := 12;

  FCal1 := TgsMonthCalendar.Create(Self);
  FCal1.Parent := FTabCal;

  FCal2 := TgsMonthCalendar.Create(Self);
  FCal2.Parent := FTabCal;

//  lbDbg:= TListBox.Create(Self); //dbg
//  lbDbg.Parent:= FTabCal;
//  lbDbg.Left:=111; lbDbg.Top:=0; lbDbg.Width:=211;
//  FBtDbg := TSpeedButton.Create(Self); //dbg
//  FBtDbg.Parent := FTabDpz;
//  FBtDbg.Caption := '12345';

  lbYear := TgsListBox.Create(Self);
  lbYear.Parent := FTabDpz;
  lbYear.FLayout := 31;

  FBtnUp := TSpeedButton.Create(Self);
  FBtnUp.Parent := FTabDpz;
  FBtnUp.OnClick := DoOnBtnUpClick;
  FBtnUp.Caption := '';  FBtnUp.Flat := True;
  FBtnUp.Glyph.LoadFromResourceName(hInstance, 'UPBTN');
  FBtnUp.Enabled := false;

  FBtnDn := TSpeedButton.Create(Self);
  FBtnDn.Parent := FTabDpz;
  FBtnDn.OnClick := DoOnBtnDnClick;
  FBtnDn.Caption := '';  FBtnDn.Flat := True;
  FBtnDn.Glyph.LoadFromResourceName(hInstance, 'DNBTN');

  lbQuarter := TgsListBox.Create(Self);
  lbQuarter.Parent := FTabDpz;
  lbQuarter.Columns := 4;
  lbQuarter.FLayout := 32;

  lbMonth := TgsListBox.Create(Self);
  lbMonth.Parent := FTabDpz;
  lbMonth.FLayout := 33;

  lbWeek := TgsListBox.Create(Self);
  lbWeek.Parent := FTabDpz;
  lbWeek.Columns := 5;
  lbWeek.FLayout := 34;

  FBtnOk := TSpeedButton.Create(Self);
  FBtnOk.Parent := Self;
  FBtnOk.Caption := 'Ok'; FBtnOk.Flat := True;
  FBtnOk.OnClick := DoOnBtnOkClick;

  FBtnCancel := TSpeedButton.Create(Self);
  FBtnCancel.Parent := Self;
  FBtnCancel.Caption := 'Cancel';  FBtnCancel.Flat := True;
  FBtnCancel.OnClick := DoOnBtnCancelClick;
  //FBtnCancel.Glyph.LoadFromResourceName(hInstance, 'CLOSEBTN');

  for J:=0 to ComponentCount - 1 do
  begin
    if (Components[J] is TgsCustomListBox) then begin
      TgsCustomListBox(Components[J]).FPeriodEdit := FPeriodEdit;

      TgsCustomListBox(Components[J]).OnClick := DoOnClickPeriod;
      TgsCustomListBox(Components[J]).OnDblClick := DoOnDblClickPeriod;
      TgsCustomListBox(Components[J]).OnKeyDown := DoOnKeyDownDropWindow;

      TgsCustomListBox(Components[J]).OnKeyPress := DoOnChildKeyPress;
    end;
    if (Components[J] is TgsMonthCalendar) then begin
      //!? FPeriodEdit
      {$IFNDEF MCALENDAR}
      TgsMonthCalendar(Components[J]).OnDateChange := DoOnDateChangeCalendar;
      {$ENDIF}
      TgsMonthCalendar(Components[J]).OnClick := DoOnClickCalendar;
      TgsMonthCalendar(Components[J]).OnDblClick := DoOnDblClickCalendar;
      TgsMonthCalendar(Components[J]).OnKeyDown := DoOnKeyDownDropWindow;

      TgsMonthCalendar(Components[J]).OnKeyPress := DoOnChildKeyPress;
    end;
  end;

  FSkipKillFocus := false;
  FTimeKillFocus := now;
end;  {<- TgsDropWindow.Create}

end.


