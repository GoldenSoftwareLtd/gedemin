
unit gsPeriodEdit;

interface

uses
  Classes, Windows, Controls, Graphics, ExtCtrls, Messages, StdCtrls,
  Dialogs, Buttons, forms,ComObj, registry, SysUtils, gsDatePeriod;

type
  TgsCalendarState = (gscsYear, gscsMonth, gscsDay);

const
  DefCalendarState = gscsYear;

type
  TgsCalendarPanel = class(TCustomControl)
  private
    b, vid: Boolean;
    FCalendarState: TgsCalendarState;
    Year,XX,YY,FCalendarMonth,FlX,FlY,NX,NY,FNumberDay, DataToday, YearToday, MonthToday, FTodayDayWeek, VibPeriod: Integer;

    FMouseCellX, FMouseCellY: Integer;
    FYear, FMonth, FDay: Integer;
    FYearStart: Integer;

    procedure SetCalendarState(const Value: TgsCalendarState);

    procedure SetNormalAttr(Canvas: TCanvas);
    procedure SetCurrentAttr(Canvas: TCanvas);
    procedure SetMouseAttr(Canvas: TCanvas);

    procedure OutputText(Canvas: TCanvas; const R: TRect; const S: String);

    procedure DrawYear(Canvas: TCanvas);
    procedure DrawMonth(Canvas: TCanvas);
    procedure DrawDay(Canvas: TCanvas);

    procedure CalcMouseCoord(const X, Y: Integer);
    function GetDayStart: TDate;

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

    property CalendarState: TgsCalendarState read FCalendarState write SetCalendarState
      default DefCalendarState;
  end;

  TgsPeriodForm = class(TCustomControl)
  private

    FObjPanel1, FObjPanel2: TgsCalendarPanel;
    NumberPeriod: Integer;

  protected
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TgsPeriodShortCutEdit = class(TCustomEdit)
  private
    FDatePeriod: TgsDatePeriod;

  protected
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property DatePeriod: TgsDatePeriod read FDatePeriod;
  end;

  TgsEditPeriod = class(TWinControl)
  private
     FPeriodWind: TgsPeriodForm;
     FEdit: TgsPeriodShortCutEdit;
     FSpeedButton: TSpeedButton;
     RunShortCut: Boolean;
     Text: String;
     ShortCut: String[2];
     Timer: TTimer;
     FDatePeriod: TgsDatePeriod;

  protected
    procedure CMExit(var Message: TCMExit);
      message CM_EXIT;
    procedure OnMyTimer(Sender: TObject);
    procedure KeyPress2(Sender: TObject; var Key: Char);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Change(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure DoOnButtonClick(Sender: TObject);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Resize; override;
    procedure DropDown;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property DatePeriod: TgsDatePeriod read FDatePeriod;
  end;

procedure Register;

implementation

// {$R XCALCULATOREDIT.RES}

uses
  jclDateTime;

const
  YearCellWidth     = 37;
  YearCellHeight    = 21;
  YearCellX         = 4;
  YearCellY         = 5;

  MonthCellWidth    = 37;
  MonthCellHeight   = 35;
  MonthCellX        = 4;
  MonthCellY        = 3;

  DayCellWidth      = 21;
  DayCellX          = 7;
  DayCellHeight     = 15;
  DayCellY          = 7;

  BottomHeight      = 30;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsEditPeriod]);
end;

function ClickYear(const nx, ny: Integer): Integer;
const
  YearFirst = 2009;
begin
  Result := YearFirst + ((nx - 1) * 4 + (ny - 1));
end;

function ClickMonth(const nx, ny: Integer): Integer;
begin
  Result := 1 + ((nx - 1) * 4 + (ny - 1));
end;

function ClickDay(const X, Y, Year, Month: Integer): Integer;
var
  YearX, MonthX, DayX, pF: Integer;
  Date: TDate;
begin
  pF := ISODayOfWeek(EncodeDate(Year, Month, 01));
  Date := EncodeDate(Year, Month, 01) - pF + 1;
  DecodeDate(Date + (Y-1) * 7 + (X - 1), YearX, MonthX, DayX);
  Result := DayX;
end;

{ TgsCalendarPanel }

constructor TgsCalendarPanel.Create(AnOwner: TComponent);
begin
  inherited ;

  AutoSize := True;
  DoubleBuffered := True;

  DecodeDate(SysUtils.Date, FYear, FMonth, FDay);
  FYearStart := FYear - YearCellX * YearCellY div 2;

  FMouseCellX := -1;
  FMouseCellY := -1;

  DecodeDate(SysUtils.Now, Year, FCalendarMonth, DataToday);
  MonthToday := FCalendarMonth;
  FTodayDayWeek := ISODayOfWeek(SysUtils.Now);
   {DefCalendarState;   }
  FCalendarState :=  gscsDay;
  YearToday := Year;
  FlX := 3;
  FlY := 3;
  b := false;
  vid := false;
end;

procedure TgsCalendarPanel.Paint;
begin
  Canvas.Font.Name := 'Tahoma';
  Canvas.Font.Size := 8;

  case FCalendarState of
    gscsYear: DrawYear(Canvas);
    gscsMonth: DrawMonth(Canvas);
    gscsDay: DrawDay(Canvas);
  end;

  Canvas.Brush.Color := clWindowText;
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Color := clWindowText;
  Canvas.Pen.Style := psSolid;
  Canvas.Polygon([Point(10, 8), Point(10, 16), Point(6, 12)]);
  Canvas.Polygon([Point(Width - 10, 8), Point(Width - 10, 16), Point(Width - 6, 12)]);
end;


procedure TgsCalendarPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Bitmap: TBitmap;
  ax, ay, I, bit_x, bit_y: Integer;
  R: TRect;
  px, py: Integer;
  _Y, _M, _D: Word;
begin
  inherited MouseDown(Button, Shift, X, Y);

  CalcMouseCoord(X, Y);

  if (FMouseCellX > 0) and (FMouseCellY > 0) then
  begin
    case FCalendarState of
      gscsYear:
      begin
      end;

      gscsMonth:
      begin
        FMonth := FMouseCellX + (FMouseCellY - 1) * MonthCellX;
      end;

      gscsDay:
      begin
        DecodeDate(GetDayStart + FMouseCellX  - 1 + (FMouseCellY - 1) * DayCellX, _Y, _M, _D);
        FYear := _Y;
        FMonth := _M;
        FDay := _D;
        Invalidate;
      end;
    end;
  end else
  begin

  end;


  b := false;
  FlX := 2;
  FlY := 2;
  Vid := false;
  Bitmap := TBitmap.Create;
  bit_x := 37;
  bit_y := 35;
  if (FCalendarState = gscsMonth) and (Y > 30) and (VibPeriod <> 2) and (VibPeriod <>3) then
  begin
    FCalendarState := gscsDay;
    FCalendarMonth := ClickMonth(((Y-30) div 37) + 1, (X div 35) + 1);
    Bitmap.Width := 148;
    Bitmap.Height := 135;
    ax:= ((X div bit_x) * bit_x) div 13;
    ay := (((Y - 30) div bit_y) * bit_y + 30) div 12;
    px := ((X div bit_x)) * bit_x ;
    py := ((Y - 30) div bit_y) * bit_y + 30;
    DrawDay(Bitmap.Canvas);
      for I := 1 to 13 do
       begin
         R := bounds(px, py, bit_x, bit_y);
         Canvas.CopyRect(R, BitMap.Canvas, bitmap.Canvas.ClipRect);
         bit_x := bit_x + 8;
         bit_y := bit_y + 7;
         px := px - ax;
         py := py - ay;
         sleep(14);
       end;
  end
  else
    if (VibPeriod = 2) or (VibPeriod = 3)  then
      FCalendarMonth := ClickMonth(((Y-30) div 37) + 1, (X div 35) + 1);
  if  (FCalendarState = gscsYear) and (Y > 30) and (VibPeriod <> 1)  then
  begin
    FCalendarState := gscsMonth;
    Year := ClickYear(((Y-30) div 37) + 1, (X div 35) + 1);
    Bitmap.Width := 148;
    Bitmap.Height := 135;
    ax:= ((X div bit_x) * bit_x) div 13;
    ay := (((Y - 30) div bit_y) * bit_y + 30) div 12;
    px := ((X div bit_x)) * bit_x ;
    py := ((Y - 30) div bit_y) * bit_y + 30;
    DrawMonth(Bitmap.Canvas);
      for I := 1 to 13 do
       begin
         R := bounds(px, py, bit_x, bit_y);
         Canvas.CopyRect(R, BitMap.Canvas, bitmap.Canvas.ClipRect);
         bit_x := bit_x + 8;
         bit_y := bit_y + 7;
         px := px - ax; 
         py := py - ay;
         sleep(14);
       end;
  end
  else
    if VibPeriod = 1 then
      Year := ClickYear(((Y-30) div 37) + 1, (X div 35) + 1);
  if (FCalendarState = gscsMonth) and ((X < 30) and (Y < 30)) then
    Year := Year - 1
  else
  if (FCalendarState = gscsMonth) and ((X > 120) and (Y < 30)) then
    Year := Year + 1;
  if  (FCalendarState = gscsDay) and ((X < 30) and (Y <27)) then
  begin
    FCalendarMonth := FCalendarMonth - 1;
    if FCalendarMonth <= 0 then
    begin
      FCalendarMonth := 12;
      Year := Year - 1;
    end;
  end
  else
    if  (FCalendarState = gscsDay) and ((X > 120) and (Y <27)) then
    begin
      FCalendarMonth := FCalendarMonth + 1;
      if FCalendarMonth > 12 then
      begin
        Year := Year + 1;
        FCalendarMonth := 1;
      end;
    end;
  if (FCalendarState = gscsDay) and (X >30) and (X < 120) and (Y < 27) then
    FCalendarState := gscsMonth

  else
    if  (FCalendarState = gscsMonth) and (X >30) and (X < 120) and (Y < 27) then
      FCalendarState := gscsYear;

  paint;
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

procedure TgsCalendarPanel.DrawYear(Canvas: TCanvas);
var
  I, J, X, Y, Yr: Integer;
begin
  Yr := FYearStart;
  X := 0;
  for I := 1 to YearCellX do
  begin
    Y := BottomHeight;
    for J := 1 to YearCellY do
    begin
      if (I = FMouseCellX) and (J = FMouseCellY) then
        SetMouseAttr(Canvas)
      else if Yr = FYear then
        SetCurrentAttr(Canvas)
      else
        SetNormalAttr(Canvas);
      OutputText(Canvas, Rect(X, Y, X + YearCellWidth, Y + YearCellHeight), IntToStr(Yr));
      Inc(Y, YearCellHeight);
      Inc(Yr);
    end;
    Inc(X, YearCellWidth);
  end;

  SetNormalAttr(Canvas);
  OutputText(Canvas, Rect(0, 0, Width, BottomHeight),
    IntToStr(FYearStart) + '-' + IntToStr(FYearStart + YearCellX * YearCellY));
end;

procedure TgsCalendarPanel.SetCurrentAttr(Canvas: TCanvas);
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clWindow;
  Canvas.Font.Color := clRed;
  Canvas.Font.Style := [];
end;

procedure TgsCalendarPanel.SetMouseAttr(Canvas: TCanvas);
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clActiveCaption;
  Canvas.Font.Color := clCaptionText;
  Canvas.Font.Style := [];
end;

procedure TgsCalendarPanel.SetNormalAttr(Canvas: TCanvas);
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clWindow;
  Canvas.Font.Color := clWindowText;
  Canvas.Font.Style := [];
end;

procedure TgsCalendarPanel.DrawMonth(Canvas: TCanvas);
var
  I, J, X, Y, M: Integer;
begin
  M := 1;
  X := 0;
  for I := 1 to MonthCellX do
  begin
    Y := BottomHeight;
    for J := 1 to MonthCellY do
    begin
      if (I = FMouseCellX) and (J = FMouseCellY) then
        SetMouseAttr(Canvas)
      else if M = FMonth then
        SetCurrentAttr(Canvas)
      else
        SetNormalAttr(Canvas);
      OutputText(Canvas, Rect(X, Y, X + MonthCellWidth, Y + MonthCellHeight),
        ShortMonthNames[M]);
      Inc(Y, MonthCellHeight);
      Inc(M);
    end;
    Inc(X, MonthCellWidth);
  end;

  SetNormalAttr(Canvas);
  OutputText(Canvas, Rect(0, 0, Width, BottomHeight), IntToStr(FYear));
end;

procedure TgsCalendarPanel.OutputText(Canvas: TCanvas; const R: TRect;
  const S: String);
var
  Size: TSize;
begin
  Canvas.FillRect(R);
  Size := Canvas.TextExtent(S);
  Canvas.TextRect(R,
    R.Left + (R.Right - R.Left - Size.cx) div 2,
    R.Top + (R.Bottom - R.Top - Size.cy) div 2,
    S);
end;

procedure TgsCalendarPanel.DrawDay(Canvas: TCanvas);
const
  DayNames: array [1..7] of String = ('Пн', 'Вт', 'Ср', 'Чт','Пт', 'Сб', 'Вс');
var
  I, J, X, Y: Integer;
  _Y, _M, _D: Word;
  D: TDate;
begin
  SetNormalAttr(Canvas);
  for I := 1 to DayCellX do
    OutputText(Canvas,
      Rect(DayCellWidth * (I - 1), BottomHeight, DayCellWidth * I, BottomHeight + DayCellHeight),
      DayNames[I]);

  D := GetDayStart;
  Y := BottomHeight + DayCellHeight;
  for J := 1 to DayCellY do
  begin
    X := 0;
    for I := 1 to DayCellX do
    begin
      if (I = FMouseCellX) and (J = FMouseCellY) then
        SetMouseAttr(Canvas)
      else if D = EncodeDate(FYear, FMonth, FDay) then
        SetCurrentAttr(Canvas)
      else
        SetNormalAttr(Canvas);
      DecodeDate(D, _Y, _M, _D);
      if _M <> FMonth then
        Canvas.Font.Color := clLtGray;
      OutputText(Canvas, Rect(X, Y, X + DayCellWidth, Y + DayCellHeight), IntToStr(_D));
      D := D + 1;
      Inc(X, DayCellWidth);
    end;
    Inc(Y, DayCellHeight);
  end;

  SetNormalAttr(Canvas);
  OutputText(Canvas, Rect(0, 0, Width, BottomHeight),
    LongMonthNames[FMonth] + ' ' + IntToStr(FYear));
end;

procedure TgsCalendarPanel.CalcMouseCoord(const X, Y: Integer);
begin
  if (X < 0) or (X >= Width) or (Y < BottomHeight) or (Y >= Height) then
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

{ TgsPeriodForm }

constructor TgsPeriodForm.Create(AnOwner: TComponent);
begin
  inherited;
  NumberPeriod := 0;
  Width := 245;
  Height := 169;
  FObjPanel1 := TgsCalendarPanel.Create(Self);
  FObjPanel1.Parent := Self;
  FObjPanel2 := TgsCalendarPanel.Create(Self);
  FObjPanel2.Parent := Self;
end;

procedure  TgsPeriodform.Paint;
const
  GodX = 5;
  GodY = 5;
  MonthX = 5;
  MonthY = 34;
  KvartX = 5;
  KvartY = 59;
  DayX =  5;
  DayY =  84;
  PeriodX = 5;
  PeriodY = 109;
  HistoryX =5;
  HistoryY = 134;
  clx = 87;
  cly = 148;
  clxx = 239;
  clyy = 164;
  clh = 154;
  mly = 4;
  perX = 410;
  PenWidth = 4;
var
  Size : TSize;
begin
  Canvas.Brush.Color := clWhite;
  Canvas.Brush.Style := bsSolid;
  Canvas.Font.Name := 'Tahoma';//'Sylfaen';
  Canvas.Font.Size := 9;
  if NumberPeriod = 1 then
  begin
    Canvas.Pen.Color := clWhite;
    Canvas.Brush.Color := clWhite;
    Canvas.Rectangle(clx, cly, clxx, clyy);
    Size := Canvas.TextExtent('Текущий год :' + IntToStr(FObjPanel1.YearToday));
    Canvas.TextOut(clx + ((clh - Size.cx) div 2), cly, 'Текущий год:' + IntToStr(FObjPanel1.YearToday));
    Canvas.Brush.Color := $003F20FF;
    Canvas.Pen.Color := $003F20FF;
  end else
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
  end;
  Canvas.Rectangle(GodX, GodY, GodX + 80, GodY + 29);
  Size := Canvas.TextExtent('Год');
  Canvas.TextOut(GodX + (75- Size.cx) div 2, GodY + (29 - Size.cy) div 2, 'Год');
  Canvas.Brush.Color := clWhite;
  if NumberPeriod = 2 then
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.Rectangle(clx, cly, clxx, clyy);
    Size := Canvas.TextExtent('Месяц:' + LongMonthNames[FObjPanel1.MonthToday] + '  ' + IntToStr(FObjPanel1.YearToday));
    Canvas.TextOut(clx + ((clh - Size.cx) div 2),cly,'Месяц:' + LongMonthNames[FObjPanel1.MonthToday] + '  ' + IntToStr(FObjPanel1.YearToday));
    Canvas.Brush.Color := $003F20FF;
    Canvas.Pen.Color := $003F20FF;

  end  else
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
  end;
  Canvas.Rectangle(MonthX, MonthY, MonthX + 80, MonthY + 25);
  Size := Canvas.TextExtent('Месяц');
  Canvas.TextOut(MonthX + (75 - Size.cx) div 2, MonthY + (25 - Size.cy) div 2, 'Месяц');
  if NumberPeriod = 3 then
  begin
    Canvas.Pen.Color := clWhite;
    Canvas.Brush.Color := clWhite;
    Canvas.Rectangle(clx, cly, clxx, clyy);
    case FObjPanel1.MonthToday of
    1..3:
    begin
      Size := Canvas.TextExtent('Квартал:' + '1кв.' + '  ' + IntToStr(FObjPanel1.YearToday));
      Canvas.TextOut(clx + ((clh - Size.cx) div 2), cly,'Квартал:' + '1кв.' + '  ' + IntToStr(FObjPanel1.YearToday));
    end;
    4..6:
    begin
      Size := Canvas.TextExtent('Квартал:' + '2кв.' + '  ' + IntToStr(FObjPanel1.YearToday));
      Canvas.TextOut(clx + ((clh - Size.cx) div 2), cly,'Квартал:' + '2кв.' + '  ' + IntToStr(FObjPanel1.YearToday));
    end;
    7..9:
    begin
      Size := Canvas.TextExtent('Квартал:' + '3кв.' + '  ' + IntToStr(FObjPanel1.YearToday));
      Canvas.TextOut(clx + ((clh - Size.cx) div 2), cly,'Квартал:' + '3кв.' + '  ' + IntToStr(FObjPanel1.YearToday));
    end;
    10..12:
    begin
      Size := Canvas.TextExtent('Квартал:' + '4кв.' + '  ' + IntToStr(FObjPanel1.YearToday));
      Canvas.TextOut(clx + ((clh - Size.cx) div 2), cly,'Квартал:' + '4кв.' + '  ' + IntToStr(FObjPanel1.YearToday));
    end;
    end;
    Canvas.Brush.Color := $003F20FF;
    Canvas.Pen.Color := $003F20FF;
  end  else
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
  end;

  Canvas.Rectangle(KvartX, KvartY, KvartX + 80, KvartY + 25);
  Size := Canvas.TextExtent('Квартал');
  Canvas.TextOut(KvartX + (75 - Size.cx) div 2, KvartY + (25 - Size.cy) div 2, 'Квартал');
  Canvas.Brush.Color := clWhite;
  if NumberPeriod = 4 then
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
    Canvas.Rectangle(clx, cly, clxx, clyy);
    Size := Canvas.TextExtent('Сегодня: ' + DateToStr(SysUtils.Now));
    Canvas.TextOut(clx + ((clh - Size.cx) div 2), cly, 'Сегодня: ' + DateToStr(SysUtils.Now));
    Canvas.Brush.Color := $003F20FF;
    Canvas.Pen.Color := $003F20FF;
  end  else
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
  end;
  Canvas.Rectangle(DayX, DayY, DayX + 80, DayY + 25);
  Size := Canvas.TextExtent('День');
  Canvas.TextOut(DayX + (75 - Size.cx) div 2, DayY + (25 - Size.cy) div 2 , 'День');
  Canvas.Brush.Color := clWhite;
  if NumberPeriod = 5 then
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
    Canvas.Rectangle(clx, cly,410,clyy);
    Size := Canvas.TextExtent('Сегодня: ' + DateToStr(SysUtils.Now));
    Canvas.TextOut(clx + ((clh - Size.cx) div 2), cly, 'Сегодня: ' + DateToStr(SysUtils.Now));
    Size := Canvas.TextExtent('Сегодня: ' + DateToStr(SysUtils.Now));
    Canvas.TextOut(260 + ((150 - Size.cx) div 2), cly, 'Сегодня: ' + DateToStr(SysUtils.Now));
    Canvas.Rectangle(239, 9,260,142);
    Canvas.Brush.Color := $003F20FF;
    Canvas.Pen.Color := $003F20FF;
  end  else
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
  end;
  Canvas.Rectangle(PeriodX, PeriodY, PeriodX + 80, PeriodY + 26);
  Size := Canvas.TextExtent('Период');
  Canvas.TextOut(PeriodX + (75 - Size.cx) div 2, PeriodY + ((26 - Size.cy) div 2), 'Период');
  if (NumberPeriod <> 0) and (NumberPeriod <> 5) and (NumberPeriod <> 6) then
  begin
    Canvas.MoveTo(clx, mly);
    Canvas.Brush.Color := $003F20FF;
    Canvas.Pen.Color := $003F20FF;
    Canvas.Pen.Width := PenWidth;
    Canvas.LineTo(clxx + 1, mly - 1);
    Canvas.LineTo(clxx + 1, cly - 3);
    Canvas.LineTo(clx, cly - 3);
    Canvas.LineTo(clx, mly);
    Canvas.MoveTo(clxx + 5, mly);
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
    Canvas.Pen.Width := PenWidth;
    Canvas.LineTo(perX, mly - 1);
    Canvas.LineTo(perX, cly - 3);
    Canvas.LineTo(clxx + 5, cly - 3);
  end else
  begin
    Canvas.MoveTo(clx, mly);
    Canvas.Brush.Color := clWindow;
    Canvas.Pen.Color :=clWindow;
    Canvas.Pen.Width := PenWidth;
    Canvas.LineTo(clxx - 5, mly - 1);
    Canvas.LineTo(clxx - 5, cly - 3);
    Canvas.LineTo(clx, cly - 3);
    Canvas.LineTo(clx, mly);
    if (NumberPeriod = 5) or (NumberPeriod = 6) then
    begin
      Canvas.MoveTo(clx, mly);
      Canvas.Brush.Color := $003F20FF;
      Canvas.Pen.Color := $003F20FF;
      Canvas.Pen.Width := PenWidth;
      Canvas.LineTo(perX, mly - 1);
      Canvas.LineTo(perX, cly - 3);
      Canvas.LineTo(clx, cly - 3);
      Canvas.LineTo(clx, mly);
    end
  end;
  if NumberPeriod = 6 then
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
    Canvas.Rectangle(91, 10,407,141);
    Canvas.Rectangle(clx - 1, cly + 2,perX,clyy);
    Canvas.Brush.Color := $003F20FF;
    Canvas.Pen.Color := $003F20FF;
  end  else
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
  end;
  Canvas.Rectangle(HistoryX, HistoryY + 4, HistoryX + 79, HistoryY + 30);
  Size := Canvas.TextExtent('История');
  Canvas.TextOut(HistoryX + (73 - Size.cx) div 2, HistoryY + (30 - Size.cy) div 2, 'История');
  Canvas.Brush.Color := clWhite;
end;

procedure TgsPeriodForm.WMActivate(var Message: TWMActivate);
begin
  if Message.Active = WA_INACTIVE then
  begin
    Hide;
  end;
end;

procedure TgsPeriodForm.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
end;

procedure TgsPeriodForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style :=WS_POPUP;
    ExStyle := WS_EX_STATICEDGE;
    AddBiDiModeExStyle(ExStyle);
  end;
end;

destructor TgsPeriodForm.Destroy;
begin
  FObjPanel1.Free;
  FObjPanel2.Free;
  inherited Destroy;
end;

{ TgsPeriodEdit }

constructor TgsEditPeriod.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  BevelOuter := bvLowered;
  BevelInner := bvLowered;
  BevelKind := bkTile;

  FDatePeriod := TgsDatePeriod.Create;

  FEdit := TgsPeriodShortCutEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.BorderStyle := bsNone;
  FEdit.OnChange := Change;
  FEdit.OnKeyPress := KeyPress2;

  FSpeedButton := TSpeedButton.Create(Self);
  FSpeedButton.Parent := Self;
  FSpeedButton.Glyph.Handle := LoadBitmap(hInstance, 'CALCBTN');
  FSpeedButton.OnClick := DoOnButtonClick;

  Width := 200;
  Height := 21;

  ShortCut := '';
  RunShortCut := False;
end;

procedure TgsEditPeriod.OnMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
begin
  case  FPeriodWind.NumberPeriod of
   1:
   if Y > 30 then
   begin
     FEdit.Text := IntToStr(ClickYear(FPeriodWind.FObjPanel1.NY - 1,FPeriodWind.FObjPanel1.NX));
     FPeriodWind.FObjPanel2.Year := ClickYear(FPeriodWind.FObjPanel1.NY - 1,FPeriodWind.FObjPanel1.NX);
     FPeriodWind.Hide;
   end;
   2:
   if  (FPeriodWind.FObjPanel1.FCalendarState = gscsMonth) and (Y > 30)  then
   begin
     FEdit.Text :=IntToStr(ClickMonth(FPeriodWind.FObjPanel1.NY - 1, FPeriodWind.FObjPanel1.NX)) + '.'  + IntToStr(FPeriodWind.FObjPanel1.Year);
     FPeriodWind.Hide;
   end;
   3: if  (Y > 30) and (FPeriodWind.FObjPanel1.FCalendarState = gscsMonth) then
       begin
         case FPeriodWind.FObjPanel1.FCalendarMonth of
         1..3:
           FEdit.Text := '01.01.' + IntToStr(FPeriodWind.FObjPanel1.Year) + '-' + '31.03.' + IntToStr(FPeriodWind.FObjPanel1.Year);
         4..6:
           FEdit.Text := '01.04.' + IntToStr(FPeriodWind.FObjPanel1.Year) + '-' + '30.06.' + IntToStr(FPeriodWind.FObjPanel1.Year);
         7..9:
           FEdit.Text := '01.07.' + IntToStr(FPeriodWind.FObjPanel1.Year) + '-' + '30.09.' + IntToStr(FPeriodWind.FObjPanel1.Year);
         10..12:
           FEdit.Text := '01.10.' + IntToStr(FPeriodWind.FObjPanel1.Year) + '-' + '31.12.' + IntToStr(FPeriodWind.FObjPanel1.Year);
         end;
         FPeriodWind.Hide;
       end;
   4:
   if (FPeriodWind.FObjPanel1.FCalendarState = gscsDay) and (Y > 30) then
   begin
     FEdit.Text := DateToStr(EncodeDate(FPeriodWind.FObjPanel1.Year, FPeriodWind.FObjPanel1.FCalendarMonth, ClickDay((X div 21) + 1, (Y-30) div 15, FPeriodWind.FObjPanel1.Year, FPeriodWind.FObjPanel1.FCalendarMonth)));
     FPeriodWind.Hide;
   end;
   5:
   begin
   if (Y > 30) and (FPeriodWind.FObjPanel1.FCalendarState = gscsDay) then
   FEdit.Text := DateToStr(EncodeDate(FPeriodWind.FObjPanel1.Year, FPeriodWind.FObjPanel1.FCalendarMonth, ClickDay((X div 21) + 1, (Y-30) div 15, FPeriodWind.FObjPanel1.Year, FPeriodWind.FObjPanel1.FCalendarMonth)));
   end;
  end;
end;

procedure TgsEditPeriod.OnMouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
begin
  if (FPeriodWind.NumberPeriod = 5) and (FPeriodWind.FObjPanel2.FCalendarState = gscsDay) and ( Y > 30) then
  begin
    FEdit.Text :=FEdit.Text + '-' + DateToStr(EncodeDate(FPeriodWind.FObjPanel2.Year, FPeriodWind.FObjPanel2.FCalendarMonth, ClickDay((X div 21) + 1, (Y-30) div 15, FPeriodWind.FObjPanel2.Year, FPeriodWind.FObjPanel2.FCalendarMonth)));
    FPeriodWind.Hide;
  end;
 FPeriodWind.Paint;
end;

procedure TgsEditPeriod.OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_Escape: FPeriodWind.Hide;
  end;
end;

procedure TgsEditPeriod.DoOnButtonClick(Sender: TObject);
begin
  DropDown;
end;

procedure TgsEditPeriod.FormMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
const
  PeriodWidth = 245;
var
  Year, Month, Day: Word;
begin
  DecodeDate(SysUtils.Now, Year, Month, Day);
  if (X > 245) and (Y > 147) then
  begin
    FPeriodWind.FObjPanel2.Year := Year;
    FPeriodWind.FObjPanel2.FCalendarMonth := Month;
    FPeriodWind.FObjPanel2.Paint;
  end
  else
  if (X > 70) and (X < 236) and (Y > 147) and (Y < 167) then
  begin
    case FPeriodWind.NumberPeriod of
    1:
    begin
      FEdit.Text := IntToStr(Year);
      FPeriodWind.Hide;
    end;
    2:
    begin
      FEdit.Text := IntTostr(Month) + '.'+ IntTostr(Year);
      FPeriodWind.Hide;
    end;
    3:
    begin
      case Month of
      1..3:
      begin
        FEdit.Text :='01.01.' + IntTostr(Year) + '-' + '31.03.' + IntTostr(Year);
        FPeriodWind.Hide;
      end;
      4..6:
      begin
        FEdit.Text := '01.04.' + IntTostr(Year) + '-' + '30.06.' + IntTostr(Year);
        FPeriodWind.Hide;
      end;
      7..9:
      begin
        FEdit.Text := '01.07.' + IntTostr(Year) + '-' + '30.09.' + IntTostr(Year);
        FPeriodWind.Hide;
      end;
      10..12:
      begin
        FEdit.Text := '01.10.' + IntTostr(Year) + '-' + '31.12.' + IntTostr(Year);
        FPeriodWind.Hide;
      end;
      end;
    end;
    4:
    begin
      FEdit.Text := DateToStr(SysUtils.Now);
      FPeriodWind.Hide;
      end;
    5:
    begin
      if  (X > 70) and (X < 236) and (Y > 147) and (Y < 167) then
      begin
        FPeriodWind.FObjPanel1.Year := Year;
        FPeriodWind.FObjPanel1.FCalendarMonth := Month;
        FPeriodWind.FObjPanel1.Paint;
      end;
     end;
    end;
  end;
  if (X >10) and (X < 85) and (Y < 157) and (Y > 5) then
  begin
    FPeriodWind.NumberPeriod := (Y - 5) div 26 + 1;
    Case FPeriodWind.NumberPeriod of
     1:
     begin
       FPeriodWind.Width := PeriodWidth;
       DatePeriod.Kind := dpkYear;
       FPeriodWind.FObjPanel1.FCalendarState := gscsYear;
       FPeriodWind.FObjPanel1.Show;
       FPeriodWind.FObjPanel1.VibPeriod := 1;
       FPeriodWind.FObjPanel2.Hide;
       FPeriodWind.FObjPanel1.Paint;
       FPeriodWind.paint;
     end;
     2:
     begin
       FPeriodWind.Width := PeriodWidth;
       DatePeriod.Kind := dpkMonth;
       FPeriodWind.FObjPanel1.FCalendarState := gscsMonth;
       FPeriodWind.FObjPanel1.Show;
       FPeriodWind.FObjPanel1.VibPeriod := 2;
       FPeriodWind.FObjPanel2.Hide;
       FPeriodWind.FObjPanel1.Paint;
       FPeriodWind.paint;
     end;
     3:
     begin
       FPeriodWind.Width := PeriodWidth;
       DatePeriod.Kind := dpkQuarter;
       FPeriodWind.FObjPanel1.FCalendarState := gscsMonth;
       FPeriodWind.FObjPanel1.Show;
       FPeriodWind.FObjPanel1.VibPeriod := 3;
       FPeriodWind.FObjPanel2.Hide;
       FPeriodWind.FObjPanel1.Paint;
       FPeriodWind.paint;
     end;
     4:
     begin
       FPeriodWind.Width := PeriodWidth;
       DatePeriod.Kind := dpkDay;
       FPeriodWind.FObjPanel1.FCalendarState := gscsDay;
       FPeriodWind.FObjPanel1.Show;
       FPeriodWind.FObjPanel1.VibPeriod := 4;
       FPeriodWind.FObjPanel2.Hide;
       FPeriodWind.FObjPanel1.Paint;
       FPeriodWind.paint;
      end;
      5:
     begin
       FPeriodWind.Width := PeriodWidth + 172;
       DatePeriod.Kind := dpkFree;
       FPeriodWind.FObjPanel1.FCalendarState := gscsDay;
       FPeriodWind.FObjPanel1.Show;
       FPeriodWind.FObjPanel1.VibPeriod := 5;
       FPeriodWind.FObjPanel2.Left := 260;
       FPeriodWind.FObjPanel2.Top := 7;
       FPeriodWind.FObjPanel2.Visible := true;
       FPeriodWind.FObjPanel1.Paint;
       FPeriodWind.Paint;
     end;
     6:
     begin
       FPeriodWind.Width := PeriodWidth + 172;
       FPeriodWind.FObjPanel1.FCalendarState := gscsDay;
       FPeriodWind.FObjPanel1.Hide;
       FPeriodWind.FObjPanel2.Hide;
       FPeriodWind.paint;
     end;
     end;
     end;

     if (Y > 30) and (Y < 165) then
     begin
       FPeriodWind.FObjPanel1.Left := 90;
       FPeriodWind.FObjPanel1.Top := 7;
     end;
end;

procedure TgsEditPeriod.KeyPress2(Sender: TObject; var Key: Char);
const
  ArrRus = 'ё"№;:?йцукенгшщзхъфывапролджэячсмитьбю.ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ.';
  ArrEng = '`@#$^&qwertyuiop[]asdfghjkl;''zxcvbnm,./~QWERTYUIOP[]ASDFGHJKL;''ZXCVBNM,./';
var
  Ch: array[0..KL_NAMELENGTH] of Char;
  Kl, I: Integer;
begin
  case Key of
  '0'..'9', '-', '.':
  begin
    FEdit.Text := FEdit.Text;
  end;
  #8:
  begin
    FEdit.Text := Copy(FEdit.Text,1,Length(FEdit.Text) - 1);
    FEdit.SetSelStart(Length(FEdit.Text));
  end;
  ' ':
  begin
    Key := #0;
    FEdit.Text := FEdit.Text + DateToStr(SysUtils.Now);
  end  else
  begin
    GetKeyboardLayoutName(Ch);
    KL := StrToInt('$' + StrPas(Ch));
    I := 1;
    if (KL and $3ff) = LANG_ENGLISH then
    begin
      While ArrEng[I] <> Key do
        I := I + 1;
        Key := ArrRus[I];
    end;
    ShortCut := ShortCut + Key;
    if Length(ShortCut) = 1 then
    begin
      Timer := TTimer.Create(nil);
      Timer.OnTimer := OnMyTimer;
      Timer.Interval := 1000;
      Timer.Enabled := true;
    end
    else
    if Length(ShortCut) = 2 then
    begin
      Timer.Enabled := false;
      if DatePeriod.ProcessShortCut(ShortCut[1]) = true then
      begin
        FEdit.Text := DatePeriod.EncodeString;
        RunShortCut := true;
        ShortCut := '';
      end
      else
        ShortCut:= Copy(ShortCut,2,1);
    end;
      Key := #0;
  end;
 end;

end;

procedure TgsEditPeriod.Change(Sender: TObject);   //ставит точки
begin
  Text := FEdit.Text;
end;



destructor TgsEditPeriod.Destroy;
begin
  DatePeriod.Free;
  FPeriodWind.Free;
  Timer.Free;
  inherited Destroy;
end;

procedure TgsEditPeriod.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);

end;


{ TgsPeriodShortCutEdit }


constructor TgsPeriodShortCutEdit.Create(AnOwner: TComponent);
begin
  inherited;
  FDatePeriod := TgsDatePeriod.Create;
end;

destructor TgsPeriodShortCutEdit.Destroy;
begin
  FDatePeriod.Free;
  inherited Destroy;
end;

procedure TgsEditPeriod.OnMyTimer(Sender: TObject);
begin
   if FEdit.Focused = true then
     if Length(ShortCut) = 1 then
       if DatePeriod.ProcessShortCut(ShortCut[1]) = true then
       begin
         FEdit.Text := DatePeriod.EncodeString;
         ShortCut := '';
         RunShortCut := true;
       end;
   Timer.Enabled := false;
   Timer.Free;
end;

procedure TgsEditPeriod.CMExit(var Message: TCMExit);
begin
  if (Length(Text) > 0) and (RunShortCut = false) then
    DatePeriod.DecodeString(Text);
  if FPeriodWind <> nil then
    FPeriodWind.Hide;
end;

procedure TgsEditPeriod.Resize;
begin
  inherited;

  FEdit.SetBounds(0, 0, ClientWidth - 17, ClientHeight);
  FSpeedButton.SetBounds(FEdit.Width + 1, 1, 16, ClientHeight - 1);
end;

procedure TgsEditPeriod.DropDown;
const
  PeriodWidth = 245;
begin
  if FPeriodWind = nil then
  begin
    FPeriodWind := TgsPeriodForm.Create(Self);
    FPeriodWind.Parent := Self;
    FPeriodWind.Left := ClientOrigin.x;
    FPeriodWind.Top := ClientOrigin.y + Height;
    FPeriodWind.OnMouseDown := FormMouseDown;
    FPeriodWind.OnKeyDown := OnKeyDown;
    FPeriodWind.FObjPanel1.OnMouseDown := OnMouseDown;
    FPeriodWind.FObjPanel2.OnMouseUp := OnMouseUp;
  end;

  FPeriodWind.Left := ClientOrigin.x;
  FPeriodWind.Top := ClientOrigin.y  + Height;
  FPeriodWind.FObjPanel1.Left := 90;
  FPeriodWind.FObjPanel1.Top := 7;

  case DatePeriod.Kind of
    dpkMonth:
    begin
      FPeriodWind.Width := PeriodWidth;
      FPeriodWind.FObjPanel1.FCalendarState := gscsMonth;
      FPeriodWind.NumberPeriod := 2;
    end;

    dpkDay:
    begin
      FPeriodWind.Width := PeriodWidth;
      FPeriodWind.FObjPanel1.FCalendarState := gscsDay;
      FPeriodWind.NumberPeriod := 4;
    end;

    dpkYear:
    begin
      FPeriodWind.Width := PeriodWidth;
      FPeriodWind.FObjPanel1.FCalendarState := gscsYear;
      FPeriodWind.NumberPeriod := 1;
      FPeriodWind.FObjPanel1.paint;
      FPeriodWind.paint;
    end;

    dpkQuarter:
    begin
      FPeriodWind.Width := PeriodWidth;
      FPeriodWind.FObjPanel1.FCalendarState := gscsYear;
      FPeriodWind.NumberPeriod := 3;
    end;

    dpkFree, dpkWeek:
    begin
      FPeriodWind.Width := PeriodWidth + 172;
      FPeriodWind.NumberPeriod := 5;
      FPeriodWind.FObjPanel1.FCalendarState := gscsDay;
      FPeriodWind.FObjPanel1.VibPeriod := 5;
      FPeriodWind.FObjPanel2.Left := 260;
      FPeriodWind.FObjPanel2.Top :=7;
      FPeriodWind.FObjPanel2.Visible := true;
    end;
  end;

  if FPeriodWind.Visible then
    FPeriodWind.Hide
  else begin
    FPeriodWind.Show;
    FPeriodWind.SetFocus;
  end;
end;

procedure TgsPeriodShortCutEdit.DoExit;
begin
  try
    FDatePeriod.DecodeString(Text);
    Text := FDatePeriod.EncodeString;
    inherited;
  except
    on E: Exception do
    begin
      Application.ShowException(E);
      SetFocus;
    end;
  end;
end;

procedure TgsPeriodShortCutEdit.KeyPress(var Key: Char);
begin
  if FDatePeriod.ProcessShortCut(Key) then
  begin
    Text := FDatePeriod.EncodeString;
    SelStart := 0;
    SelLength := Length(Text);
    Key := #0;
  end else
    inherited;
end;

end.
