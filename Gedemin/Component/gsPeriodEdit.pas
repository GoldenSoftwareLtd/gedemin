
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
    FCalendarState: TgsCalendarState;

    FMouseCellX, FMouseCellY: Integer;
    FYear, FMonth, FDay: Integer;
    FTodayYear, FTodayMonth, FTodayDay: Integer;
    FYearStart: Integer;
    FOnChange: TNotifyEvent;
    FAllowedState: TgsCalendarState;
    FMinDate: TDate;
    FMaxDate: TDate;

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
    function OffRange(const AYear, AMonth, ADay: Integer): Boolean;

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

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TgsPeriodEdit = class;

  TgsPeriodForm = class(TCustomControl)
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

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMMouseActivate(var Message: TWMMouseActivate);
      message WM_MouseActivate;
    function HasWindow(Wnd: TControl): Boolean;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AssignPeriod(const APeriod: TgsDatePeriod);

    property Period: TgsDatePeriod read FPeriod;
    property PeriodEdit: TgsPeriodEdit write FPeriodEdit;
  end;

  TgsPeriodEdit = class(TCustomEdit)
  private
    FDatePeriod, FSavedPeriod: TgsDatePeriod;
    FPeriodForm: TgsPeriodForm;
    FButton: TSpeedButton;
    FPeriodVisible: Boolean;
    FHasFocus: Boolean;

    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMSetFocus(var Message: TWMSetFocus);
      message WM_SetFocus;
    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KillFocus;

    function Validate(const Silent: Boolean = False): Boolean;

    function GetMinHeight: Integer;

    procedure DoOnButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DoOnButtonClick(Sender: TObject);
    function GetDatePeriod: TgsDatePeriod;

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;
    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure CloseUp(Accept: Boolean);
    procedure DropDown;

    procedure AssignPeriod(APeriod: TgsDatePeriod); overload;
    procedure AssignPeriod(const APeriod: String); overload;

    property DatePeriod: TgsDatePeriod read GetDatePeriod;

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

  DateDelimiter     = '.';
  PeriodDelimiter   = '-';

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
  _Y, _M, _D: Word;
  LStep, TStep, RStep, BStep, Tmp: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);

  CalcMouseCoord(X, Y);

  if not Enabled then
    exit;

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
          end;
        end;

        gscsMonth:
        begin
          Tmp := FMouseCellX + (FMouseCellY - 1) * MonthCellX;
          if OffRange(FYear, Tmp, FDay) then
            exit;
          FMonth := Tmp;
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
          end;
        end;

        gscsDay:
        begin
          DecodeDate(GetDayStart + FMouseCellX  - 1 + (FMouseCellY - 1) * DayCellX, _Y, _M, _D);
          if OffRange(_Y, _M, _D) then
            exit;
          if _M = FMonth then
          begin
            FYear := _Y;
            FMonth := _M;
            FDay := _D;
          end;
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
        OffRange(Yr, FMonth, FDay),
        False);
      Inc(X, YearCellWidth);
      Inc(Yr);
    end;
    Inc(Y, YearCellHeight);
  end;

  OutputText(Canvas, Rect(0, 0, Width, BottomHeight),
    IntToStr(FYearStart) + '-' + IntToStr(FYearStart + YearCellX * YearCellY),
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
        OffRange(FYear, M, FDay),
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
    Canvas.Font.Color := clGrayText;
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
    Canvas.Brush.Color := clGrayText;
    Canvas.Pen.Color := clGrayText;
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
  D: TDate;
begin
  if (ADay = 29) and (AMonth = 2) and IsLeapYear(AYear) then
    D := EncodeDate(AYear, AMonth, 28)
  else if (ADay = 31) and (AMonth in [4, 6, 9, 11]) then
    D := EncodeDate(AYear, AMonth, 30)
  else
    D := EncodeDate(AYear, AMonth, ADay);
  Result := ((FMinDate <> 0) and (D < FMinDate)) or
    ((FMaxDate <> 0) and (D > FMaxDate));  
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

  ControlStyle := ControlStyle + [csNoDesignVisible, csReplicatable];

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

  FRBFree.Down := True;
  OnRadioClick(FRBFree);

  Width := FLeft.Width + FRight.Width;
  Height := FLeft.Height + FBottom.Height + 2;
end;

procedure TgsPeriodForm.CreateParams(var Params: TCreateParams);
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
    if Sender = FLeft then
      FRight.MinDate := FLeft.Date
    else
      FLeft.MaxDate := FRight.Date;
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

procedure TgsPeriodForm.WMMouseActivate(var Message: TWMMouseActivate);
begin
  Message.Result := MA_NOACTIVATE;
end;

function TgsPeriodForm.HasWindow(Wnd: TControl): Boolean;
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

  if FRight.Enabled then
  begin
    FLeft.MaxDate := FRight.Date;
    FRight.MinDate := FLeft.Date;
  end;
end;

procedure TgsPeriodForm.UpdateInfo;
begin
  FInfo.Caption :=
    'Продолжительность: ' + FormatFloat('#,##0', FPeriod.DurationDays) + ' дн.';
end;

{ TgsPeriodEdit }

procedure TgsPeriodEdit.AssignPeriod(APeriod: TgsDatePeriod);
begin
  FDatePeriod.Assign(APeriod);
  Text := FDatePeriod.EncodeString;
  SelStart := 0;
  SelLength := Length(Text);
end;

procedure TgsPeriodEdit.CloseUp(Accept: Boolean);
begin
  if FPeriodVisible then
  begin
    if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
    SetFocus;
    SetWindowPos(FPeriodForm.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    FPeriodVisible := False;
    Invalidate;
    if Accept then
      AssignPeriod(FPeriodForm.Period)
    else if FSavedPeriod <> nil then
      AssignPeriod(FSavedPeriod);
    FreeAndNil(FSavedPeriod);
  end;
end;

procedure TgsPeriodEdit.CMCancelMode(var Message: TCMCancelMode);
begin
  if (Message.Sender <> Self) and (Message.Sender <> FButton)
    and (not FPeriodForm.HasWindow(Message.Sender)) then CloseUp(True);
end;

procedure TgsPeriodEdit.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls then
  begin
    RecreateWnd;
    Height := 0;
  end;
  inherited;
end;

procedure TgsPeriodEdit.CMDialogKey(var Message: TCMDialogKey);
begin
  if (Message.CharCode in [VK_RETURN, VK_ESCAPE]) and FPeriodVisible then
  begin
    CloseUp(Message.CharCode = VK_RETURN);
    Message.Result := 1;
  end else
    inherited;
end;

procedure TgsPeriodEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Height := 0;
end;

constructor TgsPeriodEdit.Create(AnOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 148;
  Text := '';

  FDatePeriod := TgsDatePeriod.Create;
  FSavedPeriod := nil;

  FButton := TSpeedButton.Create(Self);
  FButton.Glyph.LoadFromResourceName(hInstance, 'GSPERIODEDITBTN');
  FButton.ControlStyle := FButton.ControlStyle - [csAcceptsControls, csSetCaption] +
    [csFramed, csOpaque];
  FButton.Caption := '';
  FButton.Width := DropDownButtonWidth;
  FButton.Height := DropDownButtonHeight;
  FButton.Visible := True;
  FButton.Parent := Self;
  FButton.Cursor := crArrow;
  FButton.OnMouseMove := DoOnButtonMouseMove;
  FButton.OnClick := DoOnButtonClick;

  FPeriodForm := TgsPeriodForm.Create(Self);
  FPeriodForm.Visible := False;
  FPeriodForm.Parent := Self;
  FPeriodForm.PeriodEdit := Self;
end;

procedure TgsPeriodEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    if NewStyleControls and Ctl3D then
      ExStyle := ExStyle or WS_EX_CLIENTEDGE
    else
      Style := Style or WS_BORDER;
end;

procedure TgsPeriodEdit.CreateWnd;
begin
  inherited CreateWnd;
  if not (csDesigning in ComponentState) then
    SendMessage(Handle, EM_SETMARGINS, EC_RIGHTMARGIN,
      MakeLong(0, DropDownButtonWidth + 2));
end;

destructor TgsPeriodEdit.Destroy;
begin
  FDatePeriod.Free;
  inherited Destroy;
end;

procedure TgsPeriodEdit.DoExit;
begin
  if not Validate then
    SetFocus
  else
    inherited;
end;

procedure TgsPeriodEdit.DoOnButtonClick(Sender: TObject);
begin
  if Assigned(FPeriodForm) then
  begin
    if not FPeriodVisible then
      DropDown
    else
      CloseUp(True);
  end;
end;

procedure TgsPeriodEdit.DoOnButtonMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Cursor := crArrow;
end;

procedure TgsPeriodEdit.DropDown;
var
  P: TPoint;
  Y: Integer;
begin
  Assert(Parent <> nil);
  if not FPeriodVisible then
  begin
    if Validate(True) then
    begin
      FPeriodForm.AssignPeriod(FDatePeriod);

      if FSavedPeriod = nil then
        FSavedPeriod := TgsDatePeriod.Create;
      FSavedPeriod.Assign(FDatePeriod);
    end;
    P := Parent.ClientToScreen(Point(Left, Top));
    Y := P.Y + Height;
    if Y + FPeriodForm.Height > Screen.Height then Y := P.Y - FPeriodForm.Height;
    FPeriodVisible := True;
    SetWindowPos(FPeriodForm.Handle, HWND_TOP, P.X, Y, 0, 0,
      SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
    FPeriodForm.Visible := True;
    SetFocus;
  end;
end;

function TgsPeriodEdit.GetMinHeight: Integer;
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

procedure TgsPeriodEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    SetFocus;
    if not FHasFocus then Exit;
    if FPeriodVisible then CloseUp(True);
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TgsPeriodEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_UP) or (Key = VK_DOWN) then
  begin
    if FPeriodVisible then CloseUp(True) else DropDown;
    Key := 0;
  end;
  if (Key <> 0) and FPeriodVisible then FPeriodForm.KeyDown(Key, Shift);
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
      if Text[E] = PeriodDelimiter then
        break;
      if Text[E] = DateDelimiter then
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
      PostMessage(Handle, WM_CHAR, Ord(DateDelimiter), 0);
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
  if FPeriodVisible then
    CloseUp(Key = #13);
  if FDatePeriod.ProcessShortCut(Key) then
  begin
    if (FDatePeriod.Kind = dpkDay) and (SelLength = 0) and (SelStart = Length(Text))
      and (SelStart > 0) and (Text[SelStart] = '-') then
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

      PeriodDelimiter: if (Text = '') or (Pos(PeriodDelimiter, Text) > 0) then Key := #0;

      DateDelimiter: if (Text = '') or ((SelStart = Length(Text)) and (SelStart > 0) and (SelLength = 0)
             and (Text[SelStart] in [DateDelimiter, PeriodDelimiter])) or (DotCount >= 2) then Key := #0;

      #32:
      begin
        if (SelStart = Length(Text)) and (SelLength = 0)
          and ((SelStart = 0) or (Text[SelStart] in [DateDelimiter, PeriodDelimiter])) then
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

    inherited;
  end;
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

procedure TgsPeriodEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  FHasFocus := False;
  CloseUp(True);
end;

procedure TgsPeriodEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  FHasFocus := True;
  inherited;
end;

procedure TgsPeriodEdit.WMSize(var Message: TWMSize);
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
    SendMessage(Handle, EM_SETMARGINS, EC_RIGHTMARGIN,
      MakeLong(0, DropDownButtonWidth + 2));
  end;
end;

procedure TgsPeriodEdit.CNKeyDown(var Message: TWMKeyDown);
begin
  with Message do
  begin
    if (KeyDataToShiftState(KeyData) = []) and (CharCode = VK_F1) then
    begin
      ShellExecute(Handle,
        'open',
        'http://gsbelarus.com/gs/wiki/index.php/Период_дат',
        nil,
        nil,
        SW_SHOW);
      Result := 1;
      exit;
    end;
  end;

  inherited;
end;

procedure TgsPeriodEdit.AssignPeriod(const APeriod: String);
begin
  try
    FDatePeriod.DecodeString(APeriod);
    Text := FDatePeriod.EncodeString;
  except
    Text := '';
  end;
  SelStart := 0;
  SelLength := Length(Text);
end;

function TgsPeriodEdit.GetDatePeriod: TgsDatePeriod;
begin
  FDatePeriod.DecodeString(Text);
  Result := FDatePeriod;
end;

end.


