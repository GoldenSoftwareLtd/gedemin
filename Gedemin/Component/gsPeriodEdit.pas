// ShlTanya, 20.02.2019

unit gsPeriodEdit;

interface

uses
  Classes, Windows, Controls, Graphics, ExtCtrls, Messages, StdCtrls,
  Dialogs, Buttons, forms,ComObj, registry, SysUtils, gsDatePeriod;

type
  TgsCalendarState = (gscsYear, gscsMonth, gscsDay);

const
  DefAllowedState  = gscsDay;
  DefCalendarState = DefAllowedState;

type
  TgsCalendarPanel = class(TCustomControl)
  private
    FCalendarState, FAllowedState: TgsCalendarState;

    FMouseCellX, FMouseCellY: Integer;
    FYear, FMonth, FDay: Integer;
    FTodayYear, FTodayMonth, FTodayDay: Integer;
    FYearStart: Integer;
    FOnChange: TNotifyEvent;
    FMinDate: TDate;
    FMaxDate: TDate;
    FRightPanel: Boolean;

    procedure SetCalendarState(const Value: TgsCalendarState);
    procedure SetAllowedState(const Value: TgsCalendarState);

    procedure OutputText(Canvas: TCanvas; const R: TRect; const S: String;
      const AMouse, ACurrent, AToday, AnOffRange, ATitle: Boolean);

    procedure DrawYear(Canvas: TCanvas; const DrawMouse: Boolean = True);
    procedure DrawMonth(Canvas: TCanvas; const DrawMouse: Boolean = True);
    procedure DrawDay(Canvas: TCanvas; const DrawMouse: Boolean = True);
    procedure DrawButtons(Canvas: TCanvas);

    procedure CalcMouseCoord(const X, Y: Integer);
    function GetDayStart: TDate;
    procedure DoChange;
    function GetDate: TDate;
    procedure SetDate(const Value: TDate);
    procedure SetMaxDate(const Value: TDate);
    procedure SetMinDate(const Value: TDate);
    function OffRange(const AYear, AMonth, ADay: Integer): Boolean; overload;
    function OffRange(const AYear: Integer): Boolean; overload;
    function OffRange(const AYear, AMonth: Integer): Boolean; overload;
    function AdjustDate(const AYear, AMonth, ADay: Integer): Integer;

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

    property CalendarState: TgsCalendarState read FCalendarState write SetCalendarState;
    property AllowedState: TgsCalendarState read FAllowedState write SetAllowedState;
    property Year: Integer read FYear;
    property Month: Integer read FMonth;
    property Day: Integer read FDay;
    property Date: TDate read GetDate write SetDate;
    property MinDate: TDate read FMinDate write SetMinDate;
    property MaxDate: TDate read FMaxDate write SetMaxDate;
    property RightPanel: Boolean read FRightPanel write FRightPanel;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TgsDropDownEdit = class;
  TgsPeriodEdit = class;

  TgsDropDownBtn = class(TCustomControl)
  private
    Glyph: TBitmap;
    FDown: Boolean;

    function GetEdit: TgsDropDownEdit;

  protected
    procedure WMMouseActivate(var Message: TWMMouseActivate);
      message WM_MouseActivate;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LButtonUp;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;

    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TgsDropDownForm = class(TCustomControl)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMMouseActivate(var Message: TWMMouseActivate);
      message WM_MouseActivate;
    function HasWindow(Wnd: TControl): Boolean;

  public
    constructor Create(AnOwner: TComponent); override;
  end;

  TgsPeriodForm = class(TgsDropDownForm)
  private
    FLeft, FRight: TgsCalendarPanel;
    FBottom: TPanel;
    FInfo: TLabel;
    FPeriod: TgsDatePeriod;
    FRBYear, FRBMonth, FRBDay, FRBFree: TSpeedButton;
    FPeriodEdit: TgsPeriodEdit;

    procedure OnRadioClick(Sender: TObject);
    procedure OnCalendarChange(Sender: TObject);
    procedure UpdatePeriod;
    procedure SyncUI;
    procedure UpdateInfo;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AssignPeriod(const APeriod: TgsDatePeriod);

    property Period: TgsDatePeriod read FPeriod;
    property PeriodEdit: TgsPeriodEdit write FPeriodEdit;
    property LeftPanel: TgsCalendarPanel read FLeft;
    property RightPanel: TgsCalendarPanel read FRight;
  end;

  TgsDropDownEdit = class(TCustomEdit)
  private
    FButton: TgsDropDownBtn;
    FDropDownVisible: Boolean;
    FHasFocus: Boolean;
    FDropDownForm: TgsDropDownForm;

    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMSetFocus(var Message: TWMSetFocus);
      message WM_SetFocus;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KillFocus;

    function GetMinHeight: Integer;
    procedure SetEditRect;

  protected
    function Validate(const Silent: Boolean = False): Boolean; virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoExit; override;
    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure InitDropDown; virtual; abstract;
    procedure AcceptValue(Accept: Boolean); virtual; abstract;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure DropDown;
    procedure CloseUp(Accept: Boolean);

    property DropDownVisible: Boolean read FDropDownVisible;
  end;

  TgsPeriodEdit = class(TgsDropDownEdit)
  private
    FDatePeriod, FSavedPeriod: TgsDatePeriod;

    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;

    procedure SyncText;

    function GetDate: TDate;
    function GetEndDate: TDate;
    procedure SetDate(const Value: TDate);
    procedure SetEndDate(const Value: TDate);

  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function Validate(const Silent: Boolean = False): Boolean; override;
    procedure InitDropDown; override;
    procedure AcceptValue(Accept: Boolean); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AssignPeriod(APeriod: TgsDatePeriod); overload;
    procedure AssignPeriod(const APeriod: String); overload;
    procedure AssignPeriod(const ADate, ADateEnd: TDate); overload;

    procedure AssignToDatePeriod(APeriod: TgsDatePeriod);

    property Date: TDate read GetDate write SetDate;
    property EndDate: TDate read GetEndDate write SetEndDate;

  published
    property Anchors;
    property AutoSelect;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property Visible;
    property OnChange;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

{$R GSPERIODEDIT.RES}

uses
  jclDateTime, ShellAPI;

const
  YearCellWidth     = 37;
  YearCellHeight    = 15;
  YearCellX         = 4;
  YearCellY         = 7;

  MonthCellWidth    = 37;
  MonthCellHeight   = 35;
  MonthCellX        = 4;
  MonthCellY        = 3;

  DayCellWidth      = 21;
  DayCellX          = 7;
  DayCellHeight     = 15;
  DayCellY          = 7;

  BottomHeight      = 30;

  ButtonHeight      = 20;
  ButtonWidth       = 15;

  RadioButtonsCount = 4;
  RadioButtonsCaptions: array[1..RadioButtonsCount] of String =
    ('Год', 'Месяц', 'День', 'Период');
  RadioButtonsLeft: array[1..RadioButtonsCount + 1] of Integer =
    (4, 62, 132, 196, 272);

  DropDownButtonWidth  = 17;
  DropDownButtonHeight = 17;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsPeriodEdit]);
end;

{ TgsCalendarPanel }

constructor TgsCalendarPanel.Create(AnOwner: TComponent);
var
  W, H: Integer;
begin
  inherited Create(AnOwner);

  AutoSize := True;
  DoubleBuffered := True;
  ParentColor := False;
  Color := clWindow;

  CanAutoSize(W, H);
  Width := W;
  Height := H;

  Date := SysUtils.Date;
  DecodeDate(SysUtils.Date, FTodayYear, FTodayMonth, FTodayDay);

  FMouseCellX := -1;
  FMouseCellY := -1;

  FCalendarState := DefCalendarState;
  FAllowedState := DefAllowedState;
end;

procedure TgsCalendarPanel.Paint;
begin
  case FCalendarState of
    gscsYear: DrawYear(Canvas);
    gscsMonth: DrawMonth(Canvas);
    gscsDay: DrawDay(Canvas);
  end;
end;


procedure TgsCalendarPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  AnimationSteps = 6;
var
  Bitmap: TBitmap;
  I: Integer;
  Src, Dest: TRect;
  _M, _D: Word;
  LStep, TStep, RStep, BStep, Tmp: Integer;
  NeedClose: Boolean;
begin
  inherited MouseDown(Button, Shift, X, Y);

  if not Enabled then
    exit;

  NeedClose := False;
  CalcMouseCoord(X, Y);
  Bitmap := TBitmap.Create;
  try
    Bitmap.Width := Width;
    Bitmap.Height := Height;

    if (FMouseCellX > 0) and (FMouseCellY > 0) then
    begin
      case FCalendarState of
        gscsYear:
        begin
          Tmp := FYearStart + (FMouseCellX - 1) + (FMouseCellY - 1) * YearCellX;
          if OffRange(Tmp, FMonth, FDay) then
            exit;
          FYear := Tmp;
          FDay := AdjustDate(FYear, FMonth, FDay);
          if FAllowedState > gscsYear then
          begin
            FCalendarState := gscsMonth;
            DrawMonth(Bitmap.Canvas, False);
            Src := Rect(0, 0, Width, Height);
            Dest := Rect((FMouseCellX - 1) * YearCellWidth, (FMouseCellY - 1) * YearCellHeight + BottomHeight,
              FMouseCellX * YearCellWidth, FMouseCellY * YearCellHeight + BottomHeight);
            LStep := Trunc(Dest.Left / AnimationSteps);
            TStep := Trunc(Dest.Top / AnimationSteps);
            RStep := Trunc((Width - Dest.Right) / AnimationSteps);
            BStep := Trunc((Height - Dest.Bottom) / AnimationSteps);
            for I := 1 to AnimationSteps do
            begin
              Canvas.CopyRect(Dest, Bitmap.Canvas, Src);
              Dest.Left := Dest.Left - LStep;
              Dest.Top := Dest.Top - TStep;
              Dest.Right := Dest.Right + RStep;
              Dest.Bottom := Dest.Bottom + BStep;
              Sleep(40);
            end;
          end else
            NeedClose := True;
        end;

        gscsMonth:
        begin
          Tmp := FMouseCellX + (FMouseCellY - 1) * MonthCellX;
          if OffRange(FYear, Tmp, FDay) then
            exit;
          FMonth := Tmp;
          FDay := AdjustDate(FYear, FMonth, FDay);
          if FAllowedState > gscsMonth then
          begin
            FCalendarState := gscsDay;
            DrawDay(Bitmap.Canvas, False);
            Src := Rect(0, 0, Width, Height);
            Dest := Rect((FMouseCellX - 1) * MonthCellWidth, (FMouseCellY - 1) * MonthCellHeight + BottomHeight,
              FMouseCellX * MonthCellWidth, FMouseCellY * MonthCellHeight + BottomHeight);
            LStep := Trunc(Dest.Left / AnimationSteps);
            TStep := Trunc(Dest.Top / AnimationSteps);
            RStep := Trunc((Width - Dest.Right) / AnimationSteps);
            BStep := Trunc((Height - Dest.Bottom) / AnimationSteps);
            for I := 1 to AnimationSteps do
            begin
              Canvas.CopyRect(Dest, Bitmap.Canvas, Src);
              Dest.Left := Dest.Left - LStep;
              Dest.Top := Dest.Top - TStep;
              Dest.Right := Dest.Right + RStep;
              Dest.Bottom := Dest.Bottom + BStep;
              Sleep(40);
            end;
          end else
            NeedClose := True;
        end;

        gscsDay:
        begin
          DecodeDate(GetDayStart + FMouseCellX  - 1 + (FMouseCellY - 1) * DayCellX, FYear, FMonth, FDay);
          NeedClose := FRightPanel or ((Owner is TgsPeriodForm) and (TgsPeriodForm(Owner).RightPanel <> nil)
            and (not TgsPeriodForm(Owner).RightPanel.Enabled));
        end;
      end;

      DoChange;
    end else
    begin
      if (Y < ButtonHeight) and (X < ButtonWidth) then
      begin
        _M := FMonth;
        _D := FDay;

        case FCalendarState of
          gscsYear: Tmp := FYear - YearCellX * YearCellY;
          gscsMonth: Tmp := FYear - 1;
          gscsDay: DecodeDate(IncMonth(Date, -1), Tmp, _M, _D);
        end;

        if OffRange(Tmp, _M, _D) then
          exit;

        FYear := Tmp;
        FMonth := _M;
        FDay := _D;

        if FYearStart > FYear then
          FYearStart := FYear;

        DoChange;
      end
      else if (Y < ButtonHeight) and (X > Width - ButtonWidth) then
      begin
        _M := FMonth;
        _D := FDay;

        case FCalendarState of
          gscsYear: Tmp := FYear + YearCellX * YearCellY;
          gscsMonth: Tmp := FYear + 1;
          gscsDay: DecodeDate(IncMonth(Date, 1), Tmp, _M, _D);
        end;

        if OffRange(Tmp, _M, _D) then
          exit;

        FYear := Tmp;
        FMonth := _M;
        FDay := _D;

        if FYearStart + YearCellX * YearCellY <= FYear then
          FYearStart := FYear;

        DoChange;
      end else
        case FCalendarState of
          gscsMonth: FCalendarState := gscsYear;
          gscsDay: FCalendarState := gscsMonth;
        end;
    end;

    Invalidate;
  finally
    Bitmap.Free;
  end;

  if NeedClose and not (ssShift in Shift) then
    (Owner as TgsPeriodForm).FPeriodEdit.CloseUp(True);
end;


procedure TgsCalendarPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  CalcMouseCoord(X, Y);
  Invalidate;
end;

procedure TgsCalendarPanel.CMMouseLeave(var Message: TMessage);
begin
  FMouseCellX := -1;
  FMouseCellY := -1;
  Invalidate;
end;

procedure TgsCalendarPanel.SetCalendarState(const Value: TgsCalendarState);
begin
  if Value > FAllowedState then
    raise Exception.Create('This calendar state is not allowed');

  FCalendarState := Value;
  Invalidate;
end;

function TgsCalendarPanel.CanAutoSize(var NewWidth,
  NewHeight: Integer): Boolean;
begin
  case FCalendarState of
    gscsYear:
    begin
      NewWidth := YearCellWidth * YearCellX;
      NewHeight := YearCellHeight * YearCellY + BottomHeight;
    end;

    gscsMonth:
    begin
      NewWidth := MonthCellWidth * MonthCellX;
      NewHeight := MonthCellHeight * MonthCellY + BottomHeight;
    end;

    gscsDay:
    begin
      NewWidth := DayCellWidth * DayCellX;
      NewHeight := DayCellHeight * DayCellY + BottomHeight;
    end;
  end;

  Result := (NewWidth <> Width) or (NewHeight <> Height);
end;

procedure TgsCalendarPanel.DrawYear(Canvas: TCanvas; const DrawMouse: Boolean = True);
var
  I, J, X, Y, Yr: Integer;
begin
  Yr := FYearStart;
  Y := BottomHeight;
  for J := 1 to YearCellY do
  begin
    X := 0;
    for I := 1 to YearCellX do
    begin
      OutputText(Canvas, Rect(X, Y, X + YearCellWidth, Y + YearCellHeight), IntToStr(Yr),
        (I = FMouseCellX) and (J = FMouseCellY) and DrawMouse,
        Yr = FYear,
        Yr = FTodayYear,
        OffRange(Yr),
        False);
      Inc(X, YearCellWidth);
      Inc(Yr);
    end;
    Inc(Y, YearCellHeight);
  end;

  OutputText(Canvas, Rect(0, 0, Width, BottomHeight),
    IntToStr(FYearStart) + gsdpPeriodDelimiter + IntToStr(FYearStart + YearCellX * YearCellY),
    False, False, False, False, True);
  DrawButtons(Canvas);
end;

procedure TgsCalendarPanel.DrawMonth(Canvas: TCanvas; const DrawMouse: Boolean = True);
var
  I, J, X, Y, M: Integer;
begin
  M := 1;
  Y := BottomHeight;
  for J := 1 to MonthCellY do
  begin
    X := 0;
    for I := 1 to MonthCellX do
    begin
      OutputText(Canvas, Rect(X, Y, X + MonthCellWidth, Y + MonthCellHeight),
        ShortMonthNames[M],
        (I = FMouseCellX) and (J = FMouseCellY) and DrawMouse,
        M = FMonth,
        M = FTodayMonth,
        OffRange(FYear, M),
        False);
      Inc(X, MonthCellWidth);
      Inc(M);
    end;
    Inc(Y, MonthCellHeight);
  end;

  OutputText(Canvas, Rect(0, 0, Width, BottomHeight), IntToStr(FYear),
    False, False, False, False, True);
  DrawButtons(Canvas);
end;

procedure TgsCalendarPanel.OutputText(Canvas: TCanvas; const R: TRect; const S: String;
  const AMouse, ACurrent, AToday, AnOffRange, ATitle: Boolean);
var
  Size: TSize;
begin
  Canvas.Font.Name := 'Tahoma';
  Canvas.Font.Size := 8;
  Canvas.Font.Style := [];
  Canvas.Font.Color := clWindowText;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := Color;
  if Enabled then
  begin
    if AMouse then
    begin
      Canvas.Font.Color := clCaptionText;
      Canvas.Brush.Color := clActiveCaption;
    end
    else if ATitle then
    begin
      Canvas.Font.Style := [fsBold];
    end
    else if AnOffRange then
    begin
      Canvas.Font.Color := clLtGray;
    end
    else if ACurrent then
    begin
      Canvas.Brush.Color := clRed;
      Canvas.Font.Style := [fsBold];
    end
    else if AToday then
    begin
      Canvas.Font.Color := clNavy;
      Canvas.Font.Style := [fsBold];
    end;
  end else
  begin
    Canvas.Font.Color := clLtGray;
    Canvas.Brush.Color := clBtnFace;
  end;

  Canvas.FillRect(Rect(R.Left, R.Top, R.Right + 1, R.Bottom + 1));
  Size := Canvas.TextExtent(S);
  Canvas.TextRect(R,
    R.Left + (R.Right - R.Left - Size.cx) div 2,
    R.Top + (R.Bottom - R.Top - Size.cy) div 2,
    S);
end;

procedure TgsCalendarPanel.DrawDay(Canvas: TCanvas; const DrawMouse: Boolean = True);
const
  DayNames: array [1..7] of String = ('Пн', 'Вт', 'Ср', 'Чт','Пт', 'Сб', 'Вс');
var
  I, J, X, Y: Integer;
  _Y, _M, _D: Word;
  D: TDate;
begin
  for I := 1 to DayCellX do
    OutputText(Canvas,
      Rect(DayCellWidth * (I - 1), BottomHeight, DayCellWidth * I, BottomHeight + DayCellHeight),
      DayNames[I], False, False, False, False, True);

  D := GetDayStart;
  Y := BottomHeight + DayCellHeight;
  for J := 1 to DayCellY - 1 do
  begin
    X := 0;
    for I := 1 to DayCellX do
    begin
      DecodeDate(D, _Y, _M, _D);
      OutputText(Canvas, Rect(X, Y, X + DayCellWidth, Y + DayCellHeight), IntToStr(_D),
        (I = FMouseCellX) and (J = FMouseCellY) and DrawMouse,
        D = Date,
        D = SysUtils.Date,
        OffRange(_Y, _M, _D) or (_M <> FMonth),
        False);
      D := D + 1;
      Inc(X, DayCellWidth);
    end;
    Inc(Y, DayCellHeight);
  end;

  OutputText(Canvas, Rect(0, 0, Width, BottomHeight),
    LongMonthNames[FMonth] + ' ' + IntToStr(FYear),
    False, False, False, False, True);
  DrawButtons(Canvas);
end;

procedure TgsCalendarPanel.CalcMouseCoord(const X, Y: Integer);
begin
  if (not Enabled) or
    ((X < 0) or (X >= Width) or (Y < BottomHeight) or (Y >= Height)) then
  begin
    FMouseCellX := -1;
    FMouseCellY := -1;
  end else
  begin
    case FCalendarState of
      gscsYear:
      begin
        FMouseCellX := (X div YearCellWidth) + 1;
        FMouseCellY := ((Y - BottomHeight) div YearCellHeight) + 1;
      end;

      gscsMonth:
      begin
        FMouseCellX := (X div MonthCellWidth) + 1;
        FMouseCellY := ((Y - BottomHeight) div MonthCellHeight) + 1;
      end;

      gscsDay:
      begin
        if Y < (BottomHeight + DayCellHeight) then
        begin
          FMouseCellX := -1;
          FMouseCellY := -1;
        end else
        begin
          FMouseCellX := (X div DayCellWidth) + 1;
          FMouseCellY := ((Y - BottomHeight) div DayCellHeight);
        end;  
      end;
    end;
  end;
end;

function TgsCalendarPanel.GetDayStart: TDate;
begin
  Result := EncodeDate(FYear, FMonth, 1) - ISODayOfWeek(EncodeDate(FYear, FMonth, 1)) + 1;
end;

procedure TgsCalendarPanel.DrawButtons(Canvas: TCanvas);
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Style := psSolid;
  if Enabled then
  begin
    Canvas.Brush.Color := clWindowText;
    Canvas.Pen.Color := clWindowText;
  end else
  begin
    Canvas.Brush.Color := clLtGray;
    Canvas.Pen.Color := clLtGray;
  end;
  Canvas.Polygon([Point(10, 8), Point(10, 16), Point(6, 12)]);
  Canvas.Polygon([Point(Width - 10, 8), Point(Width - 10, 16), Point(Width - 6, 12)]);
end;

procedure TgsCalendarPanel.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TgsCalendarPanel.SetAllowedState(const Value: TgsCalendarState);
begin
  FAllowedState := Value;
  FCalendarState := FAllowedState;
  Invalidate;
end;

procedure TgsCalendarPanel.CMEnabledChanged(var Message: TMessage);
begin
  Invalidate;
  inherited;  
end;

function TgsCalendarPanel.GetDate: TDate;
begin
  Result := EncodeDate(FYear, FMonth, FDay);
end;

procedure TgsCalendarPanel.SetDate(const Value: TDate);
begin
  if Value <> Date then
  begin
    if ((FMinDate <> 0) and (Value < FMinDate)) or ((FMaxDate <> 0) and (Value > FMaxDate)) then
      raise Exception.Create('Date is out of range');
    DecodeDate(Value, FYear, FMonth, FDay);
    FYearStart := FYear - YearCellX * YearCellY div 2;
    Invalidate;
  end;
end;

procedure TgsCalendarPanel.SetMaxDate(const Value: TDate);
begin
  FMaxDate := Value;
  if (FMaxDate <> 0) and (Date > FMaxDate) then
    Date := FMaxDate;
  Invalidate;
end;

procedure TgsCalendarPanel.SetMinDate(const Value: TDate);
begin
  FMinDate := Value;
  if (FMinDate <> 0) and (Date < FMinDate) then
    Date := MinDate;
  Invalidate;
end;

function TgsCalendarPanel.OffRange(const AYear, AMonth,
  ADay: Integer): Boolean;
var
  NewDay: Integer;
  D: TDate;
begin
  NewDay := AdjustDate(AYear, AMonth, ADay);
  D := EncodeDate(AYear, AMonth, NewDay);
  Result := ((FMinDate <> 0) and (D < FMinDate)) or
    ((FMaxDate <> 0) and (D > FMaxDate));
end;

function TgsCalendarPanel.OffRange(const AYear: Integer): Boolean;
var
  MaxYear, MinYear, M, D: Integer;
begin
  DecodeDate(FMinDate, MinYear, M, D);
  DecodeDate(FMaxDate, MaxYear, M, D);
  Result := ((FMinDate <> 0) and (AYear < MinYear))
    or ((FMaxDate <> 0) and (AYear > MaxYear));
end;

function TgsCalendarPanel.OffRange(const AYear, AMonth: Integer): Boolean;
var
  MaxYear, MinYear, MaxMonth, MinMonth, D: Integer;
begin
  DecodeDate(FMinDate, MinYear, MinMonth, D);
  DecodeDate(FMaxDate, MaxYear, MaxMonth, D);
  Result := ((FMinDate <> 0) and ((AYear * 12 + AMonth) < (MinYear * 12 + MinMonth)))
    or ((FMaxDate <> 0) and ((AYear * 12 + AMonth) > (MaxYear * 12 + MaxMonth)));
end;

function TgsCalendarPanel.AdjustDate(const AYear, AMonth, ADay: Integer): Integer;
begin
  if (AMonth = 2) and (ADay > 29) and IsLeapYear(AYear) then
    Result := 29
  else if (AMonth = 2) and (ADay > 28) and not IsLeapYear(AYear) then
    Result := 28
  else if (ADay = 31) and (AMonth in [4, 6, 9, 11]) then
    Result := 30
  else
    Result := ADay;
end;

{ TgsPeriodForm }

constructor TgsPeriodForm.Create(AnOwner: TComponent);

  function CreateRB(const I: Integer): TSpeedButton;
  begin
    Result := TSpeedButton.Create(Self);
    with Result do
    begin
      Parent := FBottom;
      Caption := RadioButtonsCaptions[I];
      Top := 2;
      Left := RadioButtonsLeft[I];
      Width := RadioButtonsLeft[I + 1] - RadioButtonsLeft[I];
      Height := 18;
      GroupIndex := 1;
      Tag := I;
      Flat := True;
      OnClick := OnRadioClick;
    end;
  end;

begin
  inherited;

  FPeriod := TgsDatePeriod.Create;

  FBottom := TPanel.Create(Self);
  FBottom.Parent := Self;
  FBottom.Align := alBottom;
  FBottom.Height := 38;
  FBottom.BevelOuter := bvNone;
  FBottom.TabStop := False;

  FLeft := TgsCalendarPanel.Create(Self);
  FLeft.Parent := Self;
  FLeft.Align := alLeft;
  FLeft.OnChange := OnCalendarChange;

  FRight := TgsCalendarPanel.Create(Self);
  FRight.Parent := Self;
  FRight.Align := alRight;
  FRight.Color := $B0FFFF;
  FRight.OnChange := OnCalendarChange;
  FRight.RightPanel := True;

  FInfo := TLabel.Create(Self);
  FInfo.Parent := FBottom;
  FInfo.Align := alBottom;
  FInfo.Transparent := False;
  FInfo.Alignment := taCenter;
  FInfo.AutoSize := False;
  FInfo.Height := 16;
  FInfo.Color := clInfoBk;

  FRBYear := CreateRB(1);
  FRBMonth := CreateRB(2);
  FRBDay := CreateRB(3);
  FRBFree := CreateRB(4);

  SyncUI;

  Width := FLeft.Width + FRight.Width;
  Height := FLeft.Height + FBottom.Height + 2;
end;

constructor TgsDropDownForm.Create(AnOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csNoDesignVisible, csReplicatable];
end;

procedure TgsDropDownForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP or WS_BORDER;
    ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

destructor TgsPeriodForm.Destroy;
begin
  FPeriod.Free;
  inherited Destroy;
end;

procedure TgsPeriodForm.OnRadioClick(Sender: TObject);
begin
  if FRBYear.Down then
    FPeriod.Kind := dpkYear
  else if FRBMonth.Down then
    FPeriod.Kind := dpkMonth
  else if FRBDay.Down then
    FPeriod.Kind := dpkDay
  else
    FPeriod.Kind := dpkFree;
  SyncUI;
  UpdateInfo;
  UpdatePeriod;        
end;

procedure TgsPeriodForm.OnCalendarChange(Sender: TObject);
begin
  if FRight.Enabled then
  begin
    if (Sender = FLeft) and (FLeft.Date > FRight.Date) then
      FRight.Date := FLeft.Date
    else if (Sender = FRight) and (FRight.Date < FLeft.Date) then
      FLeft.Date := FRight.Date;
  end;

  case FPeriod.Kind of
    dpkYear: FPeriod.SetPeriod(FLeft.Year);
    dpkMonth: FPeriod.SetPeriod(FLeft.Year, FLeft.Month);
    dpkDay: FPeriod.SetPeriod(FLeft.Year, FLeft.Month, FLeft.Day);
  else
    FPeriod.SetPeriod(FLeft.Date, FRight.Date);
  end;

  UpdatePeriod;
  UpdateInfo;
end;

procedure TgsPeriodForm.AssignPeriod(const APeriod: TgsDatePeriod);
begin
  FPeriod.Assign(APeriod);
  SyncUI;
  UpdateInfo;
end;

procedure TgsDropDownForm.WMMouseActivate(var Message: TWMMouseActivate);
begin
  Message.Result := MA_NOACTIVATE;
end;

function TgsDropDownForm.HasWindow(Wnd: TControl): Boolean;
begin
  Result := (Wnd <> nil) and ((Wnd = Self) or (Wnd.Owner = Self));
end;

procedure TgsPeriodForm.UpdatePeriod;
begin
  if FPeriodEdit <> nil then
    FPeriodEdit.AssignPeriod(FPeriod);
end;

procedure TgsPeriodForm.SyncUI;
begin
  FLeft.MinDate  := 0;
  FLeft.MaxDate  := 0;
  FRight.MinDate := 0;
  FRight.MaxDate := 0;

  FRight.Enabled := not (FPeriod.Kind in [dpkYear, dpkMonth, dpkDay]);

  case FPeriod.Kind of
    dpkYear:
    begin
      FRBYear.Down := True;
      FLeft.AllowedState := gscsYear;
    end;

    dpkMonth:
    begin
      FRBMonth.Down := True;
      FLeft.AllowedState := gscsMonth;
    end;

    dpkDay:
    begin
      FRBDay.Down := True;
      FLeft.AllowedState := gscsDay;
    end;
  else
    FLeft.AllowedState := gscsDay;
    FRBFree.Down := True;
  end;

  FLeft.Date := FPeriod.Date;
  FRight.Date := FPeriod.EndDate;
end;

procedure TgsPeriodForm.UpdateInfo;
begin
  FInfo.Caption := 'F1=Справка                   Продолжительность: ' +
    FormatFloat('#,##0', FPeriod.DurationDays) + ' дн.';
end;

{ TgsPeriodEdit }

procedure TgsPeriodEdit.AssignPeriod(APeriod: TgsDatePeriod);
begin
  FDatePeriod.Assign(APeriod);
  SyncText;
end;

procedure TgsDropDownEdit.CloseUp(Accept: Boolean);
begin
  if FDropDownVisible then
  begin
    if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
    SetFocus;
    SetWindowPos(FDropDownForm.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    FDropDownVisible := False;
    AcceptValue(Accept);
    Invalidate;
  end;
end;

procedure TgsDropDownEdit.CMCancelMode(var Message: TCMCancelMode);
begin
  if (Message.Sender <> Self) and (Message.Sender <> FButton)
    and (not FDropDownForm.HasWindow(Message.Sender)) then CloseUp(True);
end;

procedure TgsDropDownEdit.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls then
  begin
    RecreateWnd;
    Height := 0;
  end;
  inherited;
end;

procedure TgsDropDownEdit.CMDialogKey(var Message: TCMDialogKey);
begin
  if (Message.CharCode in [VK_RETURN, VK_ESCAPE]) and FDropDownVisible then
  begin
    CloseUp(Message.CharCode = VK_RETURN);
    Message.Result := 1;
  end else
    inherited;
end;

procedure TgsDropDownEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Height := 0;
end;

constructor TgsPeriodEdit.Create(AnOwner: TComponent);
begin
  inherited;
  Width := 148;
  Text := '';

  FDatePeriod := TgsDatePeriod.Create;
  FSavedPeriod := nil;

  FDropDownForm := TgsPeriodForm.Create(Self);
  FDropDownForm.Visible := False;
  FDropDownForm.Parent := Self;
  (FDropDownForm as TgsPeriodForm).PeriodEdit := Self;
end;

procedure TgsDropDownEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    if NewStyleControls and Ctl3D then
      ExStyle := ExStyle or WS_EX_CLIENTEDGE
    else
      Style := Style or WS_BORDER;

    Style := Params.Style {or ES_MULTILINE} or WS_CLIPCHILDREN;
  end;
end;

procedure TgsDropDownEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

destructor TgsPeriodEdit.Destroy;
begin
  FDatePeriod.Free;
  FSavedPeriod.Free;
  inherited Destroy;
end;

procedure TgsDropDownEdit.DoExit;
begin
  if not Validate then
    SetFocus
  else
    inherited;
end;

procedure TgsDropDownEdit.DropDown;
var
  P: TPoint;
  Y: Integer;
begin
  Assert(Parent <> nil);
  if not FDropDownVisible then
  begin
    if Validate(True) then
      InitDropDown;
    P := Parent.ClientToScreen(Point(Left, Top));
    Y := P.Y + Height;
    if Y + FDropDownForm.Height > Screen.Height then Y := P.Y - FDropDownForm.Height;
    FDropDownVisible := True;
    SetWindowPos(FDropDownForm.Handle, HWND_TOP, P.X, Y, 0, 0,
      SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
    FDropDownForm.Visible := True;
    SetFocus;
  end;
end;

constructor TgsDropDownEdit.Create(AnOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csSetCaption];
  FButton := TgsDropDownBtn.Create(Self);
end;

destructor TgsDropDownEdit.Destroy;
begin
  inherited;

end;

function TgsDropDownEdit.GetMinHeight: Integer;
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
end;

procedure TgsDropDownEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    SetFocus;
    if not FHasFocus then Exit;
    if FDropDownVisible then CloseUp(True);
    if (SelLength = 0) and (Length(Text) > 0) then
    begin
      SelStart := 0;
      SelLength := Length(Text);
    end;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TgsPeriodEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  case Key of
    VK_F1:
    if Shift = [] then
    begin
      ShellExecute(Handle,
        'open',
        'http://gsbelarus.com/gs/wiki/index.php/Период_дат',
        nil,
        nil,
        SW_SHOW);
      Key := 0;
    end;

    VK_F2..VK_F12, VK_DELETE, VK_INSERT:
      if FDropDownVisible then CloseUp(True);

    VK_UP, VK_DOWN:
    begin
      if FDropDownVisible then
        CloseUp(True)
      else
        DropDown;
      Key := 0;
    end;
  end;

  if (Key <> 0) and FDropDownVisible then
    FDropDownForm.KeyDown(Key, Shift);
end;

procedure TgsPeriodEdit.KeyPress(var Key: Char);

  function DotCount: Integer;
  var
    E: Integer;
  begin
    Result := 0;
    E := Length(Text);
    while E > 0 do
    begin
      if Text[E] = gsdpPeriodDelimiter then
        break;
      if Text[E] = gsdpDateDelimiter then
        Inc(Result);
      Dec(E);
    end;
  end;

  procedure PostNumber(N: Word);
  var
    S: String;
    I: Integer;
  begin
    S := IntToStr(N);
    if N < 10 then S := '0' + S;
    for I := 1 to Length(S) do
      PostMessage(Handle, WM_CHAR, Ord(S[I]), 0);
    if N <= 31 then
      PostMessage(Handle, WM_CHAR, Ord(gsdpDateDelimiter), 0);
  end;

  function SingleDigit: Boolean;
  begin
    Result := ((SelStart = Length(Text)) and (SelLength = 0))
      and (Text[SelStart] in ['0'..'9'])
      and ((SelStart = 1) or (not (Text[SelStart - 1] in ['0'..'9'])));
  end;

var
  Y, M, D: Word;
begin
  if FDropDownVisible then
    CloseUp(Key <> #27);

  if FDatePeriod.ProcessShortCut(Key) then
  begin
    if (FDatePeriod.Kind = dpkDay) and (SelLength = 0) and (SelStart = Length(Text))
      and (SelStart > 0) and (Text[SelStart] = gsdpPeriodDelimiter) then
    begin
      Text := Text + FDatePeriod.EncodeString;
    end else
      Text := FDatePeriod.EncodeString;
    SelStart := 0;
    SelLength := Length(Text);
    Key := #0;
  end else
  begin
    case Key of
      #0..#31: ;

      gsdpPeriodDelimiter:
        if (Text = '') or (Pos(gsdpPeriodDelimiter, Text) > 0)
          or (Text[SelStart] = gsdpDateDelimiter) then
        begin
          Key := #0;
        end;

      gsdpDateDelimiter:
        if (Text = '') or ((SelStart = Length(Text)) and (SelStart > 0) and (SelLength = 0)
          and (Text[SelStart] in [gsdpDateDelimiter, gsdpPeriodDelimiter])) or (DotCount >= 2) then
            Key := #0;

      #32:
      begin
        if (SelLength > 0) and (SelLength = Length(Text)) then
          Text := '';

        if (SelStart = Length(Text)) and (SelLength = 0)
          and ((SelStart = 0)
            or (Text[SelStart] in [gsdpDateDelimiter, gsdpPeriodDelimiter])) then
        begin
          DecodeDate(SysUtils.Date, Y, M, D);

          case DotCount of
            0: PostNumber(D);
            1: PostNumber(M);
            2: PostNumber(Y);
          end;
        end;
        Key := #0;
      end;

      '0'..'9': ;
    else
      Key := #0;
    end;
  end;

  inherited;
end;

function TgsPeriodEdit.Validate(const Silent: Boolean = False): Boolean;
begin
  try
    FDatePeriod.DecodeString(Text);
    Text := FDatePeriod.EncodeString;
    Result := True;
  except
    on E: Exception do
    begin
      if not Silent then
        Application.ShowException(E);
      Result := False;
    end;
  end;
end;

procedure TgsDropDownEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  FHasFocus := False;
  CloseUp(True);
end;

procedure TgsDropDownEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  FHasFocus := True;
  inherited;
end;

procedure TgsDropDownEdit.WMSize(var Message: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
  if Height < MinHeight then
    Height := MinHeight
  else if FButton <> nil then
  begin
    if NewStyleControls and Ctl3D then
      FButton.SetBounds(Width - FButton.Width - 4, 0, FButton.Width, Height - 4)
    else
      FButton.SetBounds (Width - FButton.Width, 0, FButton.Width, Height);
    SetEditRect;
  end;
end;

procedure TgsPeriodEdit.CNKeyDown(var Message: TWMKeyDown);
begin
  case Message.CharCode of
    VK_F1:
    begin
      ShellExecute(Handle,
        'open',
        'http://gsbelarus.com/gs/wiki/index.php/Период_дат',
        nil,
        nil,
        SW_SHOW);
      Message.Result := 1;
      exit;
    end;

    VK_F2..VK_F12:
      if FDropDownVisible then CloseUp(True);
  end;

  inherited;
end;

procedure TgsPeriodEdit.AssignPeriod(const APeriod: String);
begin
  try
    FDatePeriod.DecodeString(APeriod);
    SyncText;
  except
    Text := '';
  end;
end;

procedure TgsPeriodEdit.AssignPeriod(const ADate, ADateEnd: TDate);
begin
  FDatePeriod.SetPeriod(ADate, ADateEnd);
  SyncText;
end;

function TgsPeriodEdit.GetDate: TDate;
begin
  FDatePeriod.DecodeString(Text);
  Result := FDatePeriod.Date;
end;

function TgsPeriodEdit.GetEndDate: TDate;
begin
  FDatePeriod.DecodeString(Text);
  Result := FDatePeriod.EndDate;
end;

procedure TgsPeriodEdit.SetDate(const Value: TDate);
begin
  FDatePeriod.Date := Value;
  SyncText;
end;

procedure TgsPeriodEdit.SetEndDate(const Value: TDate);
begin
  FDatePeriod.EndDate := Value;
  SyncText;
end;

procedure TgsPeriodEdit.SyncText;
begin
  Text := FDatePeriod.EncodeString;
  if WindowHandle <> 0 then
  begin
    SelStart := 0;
    SelLength := Length(Text);
  end;
end;

procedure TgsPeriodEdit.AssignToDatePeriod(APeriod: TgsDatePeriod);
begin
  APeriod.Assign(FDatePeriod);
end;

function TgsDropDownEdit.Validate(const Silent: Boolean): Boolean;
begin
  Result := True;
end;

procedure TgsPeriodEdit.InitDropDown;
begin
  (FDropDownForm as TgsPeriodForm).AssignPeriod(FDatePeriod);

  if FSavedPeriod = nil then
    FSavedPeriod := TgsDatePeriod.Create;
  FSavedPeriod.Assign(FDatePeriod);
end;

procedure TgsPeriodEdit.AcceptValue(Accept: Boolean);
begin
  if Accept then
    AssignPeriod((FDropDownForm as TgsPeriodForm).Period)
  else if FSavedPeriod <> nil then
    AssignPeriod(FSavedPeriod);
  FreeAndNil(FSavedPeriod);
end;

procedure TgsDropDownEdit.SetEditRect;
begin
  SendMessage(Handle, EM_SETMARGINS, EC_RIGHTMARGIN or EC_LEFTMARGIN,
    (DropDownButtonWidth + 2) shl 16);
end;

{ TgsDropDownBtn }

procedure TgsDropDownBtn.CMMouseLeave(var Message: TMessage);
begin
  inherited;

  if FDown then
  begin
    FDown := False;
    Invalidate;
  end;
end;

constructor TgsDropDownBtn.Create(AnOwner: TComponent);
begin
  inherited;

  Glyph := TBitmap.Create;
  Glyph.Transparent := True;
  Glyph.LoadFromResourceName(hInstance, 'GSPERIODEDITBTN');

  Parent := AnOwner as TWinControl;
  TabStop := False;
  Width := DropDownButtonWidth;
  Height := DropDownButtonHeight;
end;

destructor TgsDropDownBtn.Destroy;
begin
  Glyph.Free;
  inherited;
end;

function TgsDropDownBtn.GetEdit: TgsDropDownEdit;
begin
  Result := Owner as TgsDropDownEdit;
end;

procedure TgsDropDownBtn.Paint;
var
  State, Shift: Integer;
begin
  if FDown then
  begin
    State := DFCS_PUSHED or DFCS_BUTTONPUSH;
    Shift := 1;
  end else
  begin
    State := DFCS_BUTTONPUSH;
    Shift := 0;
  end;

  DrawFrameControl(Canvas.Handle, Rect(0, 0, Width, Height), DFC_BUTTON, State);
  Canvas.Draw(3 + Shift, 3+ Shift, Glyph);
end;

procedure TgsDropDownBtn.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;

  if not GetEdit.Focused then
    GetEdit.SetFocus;

  FDown := True;
  Invalidate;
end;

procedure TgsDropDownBtn.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;

  if FDown then
  begin
    FDown := False;
    Invalidate;

    with GetEdit do
    begin
      if DropDownVisible then
        CloseUp(True)
      else
        DropDown;  
    end;
  end;
end;

procedure TgsDropDownBtn.WMMouseActivate(var Message: TWMMouseActivate);
begin
  Message.Result := MA_NOACTIVATE;
end;

end.


