
unit gsPeriodEdit;

interface

uses
  Classes, Windows, Controls, Graphics, ExtCtrls, Messages, StdCtrls,
  Dialogs, Buttons, forms,ComObj, registry, SysUtils;

type
  TgsCalendarState = (gscsYear, gscsMonth, gscsDay);
  TgsMonth = (gscsJan,gscsFev,gscsMar,gscsApr,gscsMay,gscsIun,gscsIul,gscsAvg,gscsSen,gscsOct,gscsNojb,gscsDec);
  TgsDatePeriodKind = (dpkYear, dpkQuarter, dpkMonth, dpkWeek, dpkDay, dpkFree);

const
  DefCalendarState = gscsYear;
  PanelMonth: array [1..12] of String= ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь');

type
  EgsDatePeriod = class(Exception);

  TgsCalendarPanel = class(TCustomControl)
  private
    b, vid: Boolean;
    FCalendarState: TgsCalendarState;
    Year,XX,YY,FCalendarMonth,FlX,FlY,NX,NY,FNumberDay, DataToday, YearToday, MonthToday, FTodayDayWeek, VibPeriod: Integer;

    procedure SetCalendarState(const Value: TgsCalendarState);

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;
    function ControlVid(const X, Y: Integer): Boolean;
    function CanvasYear(h: TCanvas): Boolean;
    function CanvasMonth(h: TCanvas): Boolean;
    function CanvasDay(h: TCanvas): Boolean;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;

    property CalendarState: TgsCalendarState read FCalendarState write SetCalendarState
      default DefCalendarState;
  end;

  TgsDataPeriod = class(TObject)
  private
    tir: Integer;
    FDate, FEndDate, FMaxDate, FMinDate: TDate;
    FKind: TgsDatePeriodKind;
  public
    constructor Create;
    procedure Assign(const ASource: TgsDataPeriod);
    function ProcessShortCut(const S: String): Boolean;
    function EncodeString: String;
    procedure DecodeString(const AString: String);
    property Kind: TgsDatePeriodKind read FKind write FKind;
    property MaxDate: TDate read FMaxDate write FMaxDate;
    property MinDate: TDate read FMinDate write FMinDate;
    property Date: TDate read FDate write FDate;
    property EndDate: TDate read FEndDate write FEndDate;
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
    g: Integer;
    Data: Boolean;
    FData: TgsDataPeriod;

  protected
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TgsEditPeriod = class(TWinControl)
  private
     FPeriodWind: TgsPeriodForm;
     FEdit: TgsPeriodShortCutEdit;
     FSpeedButton: TSpeedButton;
     RunShortCut: Boolean;
     FGuid: TGUID;
     Text: String;
     ShortCut: String[2];
     Timer: TTimer;

  protected
    procedure CMExit(var Message: TCMExit);
      message CM_EXIT;
    procedure OnMyTimer(Sender: TObject);
    procedure KeyPress2(Sender: TObject; var Key: Char);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Change(Sender: TObject);
    procedure Loaded; override;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure DoOnButtonClick(Sender: TObject);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  public
    DatePeriod: TgsDataPeriod;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property GUID : TGUID read FGUID write FGUID;
  end;

function DateAdd(DatePart: Char; AddNumber: Integer; CurrentDate: TDate): TDate;

procedure Register;

implementation

uses
  jclDateTime;

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

function DateAdd(DatePart: Char; AddNumber: Integer; CurrentDate: TDate): TDate;
var
  iYear, iMonth, iDay: Word;
  iToAddDays, iMonthDays: Integer;
begin
  iMonthDays := 0;
  Result := CurrentDate;
  if AddNumber = 0 then Exit;
  case DatePart of
    'Y':
      begin
        DecodeDate(CurrentDate, iYear, iMonth, iDay);
        iYear := iYear + AddNumber;
        Result := EncodeDate(iYear, iMonth, iDay);
      end;
    'M': Result := IncMonth(CurrentDate, AddNumber);
    'W': Result := DateAdd('D', AddNumber * 7, CurrentDate);
    'D':
      begin
        iToAddDays := AddNumber;
        DecodeDate(CurrentDate, iYear, iMonth, iDay);
        if iToAddDays > 0 then
          while iToAddDays > 0 do
          begin
            case iMonth of
              1, 3, 5, 7, 9, 11: iMonthDays := 31;
              4, 6, 8, 10, 12: iMonthDays := 30;
              2:
                begin
                  if IsLeapYear(iYear) then
                    iMonthDays := 29
                  else
                    iMonthDays := 28;
                end;
            end;  // end case iMonth of
            if iMonthDays >= (iToAddDays + iDay) then
            begin
              iDay := iDay + iToAddDays;
              iToAddDays := 0;
            end
            else  // goto next month
            begin
              if iMonth = 12 then
              begin
                iMonth := 1;
                Inc(iYear);
              end
              else
                Inc(iMonth);
              iToAddDays := iToAddDays - (iMonthDays - iDay);
              iDay := 0;
            end;
          end  // end while iToAddDays > 0
        else
          while iToAddDays < 0 do
          begin
            if iDay > -iToAddDays then
            begin
              iDay := iDay + iToAddDays;
              iToAddDays := 0;
            end
            else  // goto previous month
            begin
              if iMonth = 1 then
              begin
                iMonth := 12;
                Dec(iYear);
              end
              else
              begin
                Dec(iMonth);
                case iMonth of
                  1, 3, 5, 7, 9, 11: iMonthDays := 31;
                  4, 6, 8, 10, 12: iMonthDays := 30;
                  2:
                    begin
                      if IsLeapYear(iYear) then
                        iMonthDays := 29
                      else
                        iMonthDays := 28;
                    end;
                end;  // end case iMonth of
                iToAddDays := iToAddDays + iDay;
                iDay := iMonthDays;
              end;
            end;
          end; //  end while iToAddDays < 0
        Result := EncodeDate(iYear, iMonth, iDay);
      end;
  end;
end;

{ TgsCalendarPanel }


function TgsCalendarPanel.CanResize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := false;
  case FCalendarState of
    gscsYear:
       begin
        NewWidth := 37 * 4;
        NewHeight := 35 * 3 + 30;
        Result := True;
       end;
    gscsMonth:
       begin
        NewWidth := 37 * 4;
        NewHeight := 35 * 3 + 30 ;
        Result := True;
       end;
    gscsDay:
       begin
        NewWidth := 21*7;
        NewHeight := 15*7 + 30 ;
        Result := True;
       end;
      end;

end;

constructor TgsCalendarPanel.Create(AnOwner: TComponent);
begin
  inherited ;
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
const
  YearCellWidth = 37;
  YearCellHeight = 35;
  YearCellXCount = 4;
  YearCellYCount = 3;
  MonthCellWidth = 37;
  MonthCellHeight = 35;
  MonthCellXCount = 4;
  MonthCellYCount = 3;
  DayCellWidth = 21;
  DayCellHeight = 15;
  DayCellXCount = 7;
  DayCellYCount = 7;
  Month: array [1..3, 1..4] of String = (
    ('янв', 'фев', 'мар' , 'апр'),
    ('май', 'июн', 'июл', 'авг'),
    ('сен', 'окт', 'ноя', 'дек')
    ) ;
  Day: array [1..7] of String = ('Пн', 'Вт', 'Ср', 'Чт','Пт', 'Сб', 'Вс');
var
  I, J, X, Y: Integer;
  R: TRect;
  Size: TSize;

begin
  inherited;
  Canvas.Font.Name := 'Tahoma';//'Sylfaen';
  Canvas.Font.Size := 9;
  case FCalendarState of
    gscsYear:
       begin
         CanvasYear(Canvas);
         {Canvas.Brush.Style := bsSolid;
         Canvas.Pen.Color := clWindow;
         if b = false then
         begin
           X := 0;
           for I := 1 to YearCellXCount do
           begin
             Y := 30;
             for J := 1 to YearCellYCount do
             begin
               Canvas.Brush.Color := clWindow;
               R := Rect(X, Y, X + YearCellWidth, Y + YearCellHeight);
               Canvas.FillRect(R);                             ;
               Size := Canvas.TextExtent(IntToStr(ClickYear(J, I)));
               Canvas.TextRect(R, X + ((YearCellWidth - Size.cx) div 2), Y + ((YearCellHeight - Size.cy) div 2),IntToStr(ClickYear(J, I)));
               Inc(Y, YearCellHeight);
             end;
           Inc(X, YearCellWidth);
         end;
     end    else
     begin
       Canvas.Brush.Color := clWindow;
       R := Rect((FlX - 1) * YearCellWidth, (FlY -2) * YearCellHeight +30 , (FlX - 1) * YearCellWidth + YearCellWidth, (FlY - 2) * YearCellHeight +30 + YearCellHeight);
       Canvas.FillRect(R);
       Size := Canvas.TextExtent(IntToStr(ClickYear(FlY - 1, FlX)));
       Canvas.TextRect(R, (FlX - 1) * YearCellWidth + ((YearCellWidth - Size.cx) div 2), (FlY - 2) * YearCellHeight +30 + ((YearCellHeight - Size.cy) div 2),IntToStr(ClickYear(FlY - 1, FlX)));

       Canvas.Brush.Color := $00FFFF99;
       R := Rect((NX - 1) * YearCellWidth, (NY -2) * YearCellHeight +30 , (NX - 1) * YearCellWidth + YearCellWidth, (NY - 2) * YearCellHeight +30 + YearCellHeight);
       Canvas.FillRect(R);
       Size := Canvas.TextExtent(IntToStr(ClickYear(NY - 1, NX)));
       Canvas.TextRect(R, (NX - 1) * YearCellWidth + ((YearCellWidth - Size.cx) div 2), (NY - 2) * YearCellHeight +30 + ((YearCellHeight - Size.cy) div 2),IntToStr(ClickYear(NY - 1, NX)));
     end; }
    end;
    gscsMonth:
       begin
          CanvasMonth(Canvas);
       { Canvas.Brush.Style := bsSolid;
         Canvas.Pen.Color := clWindow;
         if b = false  then
         begin
           X := 0;
           for I := 1 to MonthCellXCount do
           begin
             Y := 30;
             for J := 1 to MonthCellYCount do
             begin
               Canvas.Brush.Color := clWindow;
               R := Rect(X, Y, X + MonthCellWidth, Y + MonthCellHeight);
               Canvas.FillRect(R);
               Size := Canvas.TextExtent(Month[J,I]);
               Canvas.TextRect(R, X + ((MonthCellWidth - Size.cx) div 2), Y + ((MonthCellHeight - Size.cy) div 2), Month[J,I]);
               Inc(Y, MonthCellHeight);
             end;
            Inc(X, MonthCellWidth);
          end;
    end  else
    if b = true then
    begin
      Canvas.Brush.Color := clWindow;
      R := Rect((FlX - 1) * MonthCellWidth, (FlY - 2) * MonthCellHeight + 30, (FlX ) * MonthCellWidth , (FlY - 2) * MonthCellHeight + 30 + MonthCellHeight);
      Canvas.FillRect(R);
      Size := Canvas.TextExtent(Month[FlY-1,FlX]);
      Canvas.TextRect(R, (FlX - 1) * MonthCellWidth + ((MonthCellWidth - Size.cx) div 2), (FlY - 2) * MonthCellHeight + 30 + ((MonthCellHeight - Size.cy) div 2),Month[FlY-1,FlX]);

      Canvas.Brush.Color := $00FFFF99;
      R := Rect((NX - 1) * MonthCellWidth, (NY - 2) * MonthCellHeight + 30, (NX ) * MonthCellWidth , (NY - 2) * MonthCellHeight + 30 + MonthCellHeight);
      Canvas.FillRect(R);
      Size := Canvas.TextExtent(Month[NY-1,NX]);
      Canvas.TextRect(R, (NX - 1) * MonthCellWidth + ((MonthCellWidth - Size.cx) div 2), (NY - 2) * MonthCellHeight + 30 + ((MonthCellHeight - Size.cy) div 2),Month[NY-1,NX]);
    end;  }
  end;
    gscsDay:
       begin
         CanvasDay(Canvas);
         {Canvas.Brush.Style := bsSolid;
         Canvas.Pen.Color := clWindow;
         if b = false then
         begin
           X := 0;
           Y := 30;
           for I := 1 to DayCellXCount do
           begin
             Canvas.Brush.Color := clWindow;
             R := Rect(X, Y, X + DayCellWidth, Y + DayCellHeight);
             Canvas.FillRect(R);
             Canvas.TextRect(R, X , Y , Day[I]);
             Inc(X, DayCellWidth);
           end;
           Y :=  DayCellHeight +30;
           for I := 2 to DayCellYCount do
           begin
             X := 0;
             for J := 1 to DayCellXCount do
             begin
               if (ClickDay(J ,I-1, Year, FCalendarMonth) = DataToday) and (Year = YearToday) and (MonthToday = FCalendarMonth) and (FTodayDayWeek = J) then
                 Canvas.Brush.Color := clAqua
               else
                 Canvas.Brush.Color := clWindow;
               R := Rect(X, Y, X + DayCellWidth, Y + DayCellHeight + 1);
               Canvas.FillRect(R);
               Size := Canvas.TextExtent(IntToStr(ClickDay(J, I-1, Year, FCalendarMonth)));
               Canvas.TextRect(R, X + ((DayCellWidth - Size.cx) div 2), Y + ((DayCellHeight - Size.cy) div 2),IntToStr(ClickDay(J, I-1, Year, FCalendarMonth)));
               Inc(X, DayCellWidth);
               Inc(FNumberDay, 1);
              end;
              Inc(Y, DayCellHeight);
            end;
        end    else
        begin
          if (FlY > 2) and (NY > 2) then
          begin
            Canvas.Brush.Color := clWindow;
            R := Rect((FlX - 1) * DayCellWidth, (FlY - 2) * DayCellHeight  + 30 , (FlX ) * DayCellWidth, (FlY - 1) * DayCellHeight + 30);
            Canvas.FillRect(R);
            Size := Canvas.TextExtent(IntToStr(ClickDay(FlX, FlY - 2, Year, FCalendarMonth)));
            Canvas.TextRect(R, (FlX - 1) * DayCellWidth + ((DayCellWidth - Size.cx) div 2)  , (FlY - 2) * DayCellHeight + 30 + ((DayCellHeight -Size.cy) div 2),IntToStr(ClickDay(FlX, FlY - 2, Year, FCalendarMonth)));

            Canvas.Brush.Color := $00FFFF99;
            R := Rect((NX - 1) * DayCellWidth, (NY - 2) * DayCellHeight  + 30 , (NX ) * DayCellWidth, (NY - 1) * DayCellHeight + 30);
            Canvas.FillRect(R);
            Size := Canvas.TextExtent(IntToStr(ClickDay(NX, NY - 2, Year, FCalendarMonth)));
            Canvas.TextRect(R, (NX - 1) * DayCellWidth + ((DayCellWidth - Size.cx) div 2)  , (NY - 2) * DayCellHeight + 30 + ((DayCellHeight -Size.cy) div 2),IntToStr(ClickDay(NX, NY - 2, Year, FCalendarMonth)));
          end;
       end;}
     end;
 end;
  if  (b = false) and (FCalendarState = gscsYear)  then
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.Brush.Style := bsSolid;
    R := Rect(0, 0, 147 , 30 );
    Canvas.FillRect(R);
    Size:=Canvas.TextExtent('2009-2020');
    Canvas.TextOut((147 - Size.cx) div 2,(30 - Size.cy) div 2,'2009-2020');
  end;
  if (b = false) and (FCalendarState = gscsMonth)  then
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.Brush.Style := bsSolid;
    R := Rect(0, 0, 147 , 30 );
    Canvas.FillRect(R);
    Canvas.Pen.Color := clBlack;
    Canvas.MoveTo(10, 11);
    Canvas.LineTo(10, 18);
    Canvas.LineTo(5, 15);
    Canvas.LineTo(10, 11);
    Canvas.MoveTo(137, 11);
    Canvas.LineTo(137, 18);
    Canvas.LineTo(142, 15);
    Canvas.LineTo(137, 11);
    Canvas.Brush.Color := clBlack;
    Canvas.FloodFill(8,15,clWhite,fsSurface);
    Canvas.FloodFill(139,15,clWhite,fsSurface);
    Canvas.Brush.Color := clWhite;
    Size := Canvas.TextExtent(IntToStr(Year));
    Canvas.TextOut((147 - Size.cx) div 2,(30 - Size.cy) div 2,IntToStr(Year));
  end;
  if (b = false) and (FCalendarState = gscsDay) then
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.Brush.Style := bsSolid;
    R := Rect(0, 0, 147 , 30 );
    Canvas.FillRect(R);
    Canvas.Pen.Color := clBlack;
    Canvas.MoveTo(10, 11);
    Canvas.LineTo(10, 18);
    Canvas.LineTo(5, 15);
    Canvas.LineTo(10, 11);
    Canvas.MoveTo(137, 11);
    Canvas.LineTo(137, 18);
    Canvas.LineTo(142, 15);
    Canvas.LineTo(137, 11);
    Canvas.Brush.Color := clBlack;
    Canvas.FloodFill(8,15,clWhite,fsSurface);
    Canvas.FloodFill(139,15,clWhite,fsSurface);
    Canvas.Brush.Color := clWhite;
    Size := Canvas.TextExtent(PanelMonth[FCalendarMonth] + IntToStr(Year));
    Canvas.TextOut((147 - Size.cx) div 2,(30 - Size.cy) div 2,PanelMonth[FCalendarMonth] + ' ' + IntToStr(Year));
  end;
end;


procedure TgsCalendarPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Bitmap: TBitmap;
  ax, ay, I, bit_x, bit_y: Integer;
  R: TRect;
  px, py: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
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
    CanvasDay(Bitmap.Canvas);
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
    CanvasMonth(Bitmap.Canvas);
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
end;

procedure TgsCalendarPanel.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited ;
  XX := Message.XPos;
  YY := Message.YPos;
  if YY > 30 then
  b := ControlVid(XX, YY);
  if b = true  then
    if (NX <> FlX) or (NY <> FlY) then
    begin
      paint;
      FlX := NX;
      FlY := NY;
    end;
  if ((YY < 30) and (b = true))  or((FCalendarState = gscsday) and (FlY <= 2) and (NY <= 2) and (b = true))  then
  begin
    b := false;
    paint;
    FlX := 3;
    FlY := 4;
  end
end;

function TgsCalendarPanel.ControlVid( const X,Y:Integer):boolean;
begin
  Result := true;
  if Y > 30 then
  case FCalendarState of
    gscsYear:
    begin
      NX := (X div 37) + 1;
      NY := ((Y - 30) div 35) + 2;
      Result := true;
    end;
    gscsMonth:
    begin
      Result := true;
      NX := (X div 37) + 1;
      NY := ((Y - 30) div 35) + 2;
    end;
    gscsDay:
    begin
      NX := (X div 21) + 1;
      NY := ((Y-30) div 15) + 2;
      Result := true;
    end;
    end   else
    begin
      Result := false;
      FlX := 3;
      FlY := 4;
    end;

end;

procedure TgsCalendarPanel.CMMouseLeave(var Message: TMessage);
begin
  if b = true then
  begin
    b := false;
    paint;
    FlX := 3;
    FlY := 4;
  end;
end;


procedure TgsCalendarPanel.SetCalendarState(const Value: TgsCalendarState);
begin
  FCalendarState := Value;
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
  Str, ss, sss:String;
  Reg: TRegistry;
  I, K, DateX, DateY: Word;
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
    Size := Canvas.TextExtent('Месяц:' + PanelMonth[FObjPanel1.MonthToday] + '  ' + IntToStr(FObjPanel1.YearToday));
    Canvas.TextOut(clx + ((clh - Size.cx) div 2),cly,'Месяц:' + PanelMonth[FObjPanel1.MonthToday] + '  ' + IntToStr(FObjPanel1.YearToday));
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
   { Reg:= TRegistry.Create;
    try
      Reg.RootKey:= HKEY_CURRENT_USER;
      Reg.OpenKey('\Software\Golden Software\Gedemin\Client\CurrentVersion\TgsCalendarEdit', false); }
     // Str := Reg.ReadString('{741D1779-CE77-4843-808F-796DE1BCBB3E}');
   { finally
      Reg.Free;
    end;
    I := 2;
    if Str <> '' then
    begin
      DateX := 93;
      DateY := 12;
      for K:=1 to 4 do
      begin
        if Str = '' then
          break;
        While Str[I] <> '"' do
          I := I + 1;
        ss := copy(Str,2,I - 2) + '  ';
        if  K = 1 then
          sss := ss
        else
        begin
          Canvas.TextOut(DateX,DateY,sss + '  ' + ss);
          DateY := DateY + 23;
        end;
        Str := copy(Str,I + 2,Length(Str));
        I:= 2;
       end;

     end; }
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

  FEdit := TgsPeriodShortCutEdit.Create(Self);
  FEdit.Parent := Self;
  DatePeriod := TgsDataPeriod.Create;

  FEdit.Height := 21;
  FEdit.Width := 145;
  FEdit.OnChange := Change;
  FEdit.OnKeyPress := KeyPress2;

  FSpeedButton := TSpeedButton.Create(Self);
  FSpeedButton.Width := 19;
  FSpeedButton.Height := FEdit.Height - 2;
  FSpeedButton.Visible := True;
  FSpeedButton.Left := FEdit.Width;
  FSpeedButton.Parent := Self;
  FSpeedButton.OnClick := DoOnButtonClick;
  FSpeedButton.Glyph.Handle := LoadBitmap(0, Pointer(OBM_DNARROW));	
  FSpeedButton.ControlStyle := FSpeedButton.ControlStyle - [csAcceptsControls, csSetCaption] +
    [csFramed, csOpaque];
  FSpeedButton.Caption := '';
  FSpeedButton.Cursor := crArrow;
  Width := FEdit.Width + FSpeedButton.Width;
  Height := FEdit.Height;


  if (csDesigning in ComponentState) and (not (csLoading in ComponentState)) then
     GUID := StringToGUID(CreateClassID());

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
const
  PeriodWidth = 245;
begin

  if FPeriodWind = nil then
  begin
    FPeriodWind := TgsPeriodForm.Create(Self);
    FPeriodWind.Parent := Self;
    FPeriodWind.Left := ClientOrigin.x;
    FPeriodWind.Top := ClientOrigin.y  + Height;
    FPeriodWind.OnMouseDown := FormMouseDown;
    FPeriodWind.OnKeyDown := OnKeyDown;
    FPeriodWind.FObjPanel1.OnMouseDown := OnMouseDown;
    FPeriodWind.FObjPanel2.OnMouseUp := OnMouseUp;
  end
  else
  if FPeriodWind.Visible = false then
  begin
    FPeriodWind.Show;
    FPeriodWind.SetFocus;
  end
  else
    FPeriodWind.Hide;

  FPeriodWind.Left := ClientOrigin.x;
  FPeriodWind.Top := ClientOrigin.y  + Height;
  FPeriodWind.FObjPanel1.Left := 90;
  FPeriodWind.FObjPanel1.Top := 7;

  case DatePeriod.FKind of
  dpkMonth:
  begin
    FPeriodWind.Width := PeriodWidth;
    FPeriodWind.FObjPanel1.FCalendarState := gscsMonth;
    FPeriodWind.NumberPeriod := 2;
    FPeriodWind.FObjPanel1.paint;
    FPeriodWind.paint;
  end;
  dpkDay:
  begin
    FPeriodWind.Width := PeriodWidth;
    FPeriodWind.FObjPanel1.FCalendarState := gscsDay;
    FPeriodWind.NumberPeriod := 4;
    FPeriodWind.FObjPanel1.paint;
    FPeriodWind.paint;
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
    FPeriodWind.FObjPanel1.paint;
    FPeriodWind.paint;
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
    FPeriodWind.FObjPanel1.Paint;
    FPeriodWind.FObjPanel1.Show;
    FPeriodWind.Paint;
  end;
 end;
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
       DatePeriod.FKind := dpkYear;
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
       DatePeriod.FKind := dpkMonth;
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
       DatePeriod.FKind := dpkQuarter;
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
       DatePeriod.FKind := dpkDay;
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
       DatePeriod.FKind := dpkFree;
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

procedure TgsEditPeriod.Loaded;
begin
  inherited ;
 // if GUIDToString(FGUID) = '{00000000-0000-0000-0000-000000000000}' then
  //   FGUID := StringToGUID(CreateClassID());
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
      if DatePeriod.ProcessShortCut(ShortCut) = true then
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
var
  Reg: TRegistry;
  Str: String;
  I: Word;
begin
 //DatePeriod.DecodeString(Text);
  //FGUID :=StringToGuid('{741D1779-CE77-4843-808F-796DE1BCBB3E}');
 // StringToGUID(CreateClassID());
 { Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    Reg.OpenKey('\Software\Golden Software\Gedemin\Client\CurrentVersion\TgsCalendarEdit', false);
    Str := Reg.ReadString(GUIDToString(FGUID));
    I := 2;
    if Str <> '' then
    begin
      While Str[I] <> '"' do
        I := I + 1;
    if (copy(Str,2,I - 2)) = DateToStr(SysUtils.Now) then
      Reg.WriteString(GUIDToString(FGUID), '"' + DateToStr(SysUtils.Now) + '"' + ',' + '"' + DateToStr(DatePeriod.FDate) + '-' + DateToStr(DatePeriod.FEndDate) + '"' + copy(Str,I + 1, Length(Str)))
    else
      Reg.WriteString(GUIDToString(FGUID), '"' + DateToStr(SysUtils.Now) + '"' + ',' + '"' + DateToStr(DatePeriod.FDate) + '-' + DateToStr(DatePeriod.FEndDate) + '"' );
    end
    else
      Reg.WriteString(GUIDToString(FGUID), '"' + DateToStr(SysUtils.Now) + '"' + ',' + '"' + DateToStr(DatePeriod.FDate) + '-' + DateToStr(DatePeriod.FEndDate) + '"' );
  finally
    Reg.Free;
  end;}
  DatePeriod.Free;
  FPeriodWind.Free;
  FEdit.Free;
  FSpeedButton.Free;
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
  FData := TgsDataPeriod.Create;
  Data := false;
  g := 0;
end;


procedure TgsPeriodShortCutEdit.KeyUp(var Key: Word; Shift: TShiftState);
var
  s, SS: string;
  num: Integer;
begin
  case Key of
  48..57,189, 191:
  begin
    S:=trim(Text);
    if key = 189 then
      begin
        FData.tir := 0;
        g := Length(s);
      end;
    if g <> 0 then
     begin
     Num := Length(Copy(S,g + 1,Length(S)));
     SS := Copy(S,g + 1, Length(s))
     end   else
     begin
       Num := Length(Copy(S,g ,Length(S)));
       SS := Copy(S,g + 1, Length(s))
     end;
    if FData.tir = 0 then
    case Num of
     1: if StrToInt(SS[1]) > 3 then
        begin
          Delete(S,Length(s),1);
          Text := S;
          SetSelStart(g + 1);
        end ;
     2: if  (StrToInt(SS[1]) = 3) and (StrToInt(SS[2]) > 1) then
        begin
          Delete(S,Length(s),1);
          Text := S;
          SetSelStart(g +1);
        end  else
        begin
          Text := Text + '.';
          SetSelStart(Length(Text));
        end;
       4: if StrToInt(SS[4]) > 1 then
          begin
            Delete(S,Length(s),1);
            Text := S;
            SetSelStart(Length(s));
          end;
        5: if (StrToInt(SS[4])= 1) and (StrToInt(SS[5]) > 2) then
           begin
             Delete(S,Length(s),1);
             Text := S;
             SetSelStart(Length(s));
           end  else
           begin
             Text := Text + '.';
             SetSelStart(Length(Text));
           end;
       end   else
       case Num of
       3: if StrToInt(SS[4]) > 1 then
          begin
            Delete(S,Length(s),1);
            Text := S;
            SetSelStart(Length(s));
         end;
        4: if (StrToInt(SS[4])= 1) and (StrToInt(SS[5]) > 2) then
           begin
             Delete(S,Length(s),1);
             Text := S;
             SetSelStart(Length(s));
           end  else
           begin
             Text := Text + '.';
             SetSelStart(Length(Text));
           end;
         end;
       end;
    end;
end;

destructor TgsPeriodShortCutEdit.Destroy;
begin
  FData.Free;
  inherited Destroy;
end;


 {TgsDatePeriod}

constructor TgsDataPeriod.Create;
begin
  inherited;
  tir := 0;
  FMaxDate := 0;
  FMinDate := 0;
  FKind := dpkFree;
end;

function TgsDataPeriod.ProcessShortCut(const S: String): boolean;
var
  Year, Month, Day: Word;
  NumberWeek: Integer;
  Key : String;
  TempDate: TDateTime;
begin
  Result := True;
  DecodeDate(SysUtils.Date, Year, Month, Day);

  Key := AnsiUpperCase(S);

  if Key = 'СМ' then
  begin
    FKind := dpkMonth;
    TempDate := EncodeDate(Year, Month, 1);
    FDate := DateAdd('M', 1, TempDate);
    FEndDate := DateAdd('M', 2, TempDate) - 1;
  end
  else if Key = 'СГ' then
  begin
    FKind := dpkYear;
    FDate := EncodeDate(Year + 1, 01, 01);
    FEndDate := EncodeDate(Year + 1, 12, 31);
  end
  else if Key = 'СК' then
  begin
    FKind := dpkQuarter;
    case Month + 3 of
      4..6:
      begin
        FDate := EncodeDate(Year, 04, 01);
        FEndDate := EncodeDate(Year, 06, 30);
      end;
      7..9:
      begin
        FDate := EncodeDate(Year, 07, 01);
        FEndDate := EncodeDate(Year, 09, 30);
      end;
      10..12:
      begin
        FDate := EncodeDate(Year, 10, 01);
        FEndDate := EncodeDate(Year, 12, 31);
      end;
      13..15:
      begin
        FDate := EncodeDate(Year, 01, 01);
        FEndDate := EncodeDate(Year, 03, 31);
      end;
    end;
  end
  else if Key = 'СН' then
  begin
    FKind := dpkWeek;
    NumberWeek := ISOWeekNumber(SysUtils.Now);
    FDate := ISOWeekToDateTime(Year, NumberWeek + 1,1);
    FEndDate := ISOWeekToDateTime(Year, NumberWeek + 1,7);
  end
  else if Key = 'ПГ' then
  begin
    FKind := dpkYear;
    FDate := EncodeDate(Year - 1, 01, 01);
    FEndDate := EncodeDate(Year - 1, 12, 31);
  end
  else if Key = 'ПН' then
  begin
    FKind := dpkWeek;
    NumberWeek := ISOWeekNumber(SysUtils.Now);
    FDate := ISOWeekToDateTime(Year, NumberWeek - 1,1);
    FEndDate := ISOWeekToDateTime(Year, NumberWeek - 1,7);
  end
  else if Key = 'ПК' then
  begin
    FKind := dpkQuarter;
    case Month - 3 of
     1..3:
     begin
       FDate := EncodeDate(Year, 01, 01);
       FEndDate := EncodeDate(Year , 03, 31);
     end;
     4..6:
     begin
       FDate := EncodeDate(Year, 04, 01);
       FEndDate := EncodeDate(Year, 06, 30);
     end;
     7..9:
     begin
       FDate := EncodeDate(Year, 07, 01);
       FEndDate := EncodeDate(Year, 09, 30);
     end;
     -2..0:
     begin
       FDate := EncodeDate(Year - 1, 10, 01);
       FEndDate := EncodeDate(Year - 1, 12, 31);
     end;
    end
  end
  else if Key = 'ПМ' then
  begin
     FKind := dpkMonth;
     if Month -1  = 0  then
     begin
       FDate := EncodeDate(Year - 1, 12, 1);
       FEndDate := EncodeDate(Year, 12, 31);
     end else
     begin
       FDate := EncodeDate(Year, Month - 1, 1);
       FEndDate := EncodeDate(Year, Month - 1, DaysInMonth(EncodeDate(Year, Month - 1, 7)));
     end;
  end
  else if Key = 'М' then
  begin
    Fkind := dpkMonth;
    FDate := EncodeDate(Year, Month, 01);
    FEndDate := EncodeDate(Year, Month, DaysInMonth(EncodeDate(Year, Month, 7)));
  end
  else if Key = 'Г' then
  begin
    FKind := dpkYear;
    FDate := EncodeDate(Year, 01, 01);
    FEndDate := EncodeDate(Year, 12, 31);
  end
  else if Key = 'К' then
  begin
    FKind := dpkQuarter;
    case Month of
      1..3:
      begin
        FDate := EncodeDate(Year, 01, 01);
        FEndDate := EncodeDate(Year, 01, 31);
      end;
      4..6:
      begin
        FDate := EncodeDate(Year, 04, 01);
        FEndDate := EncodeDate(Year, 06, 30);
      end;
      7..9:
      begin
        FDate := EncodeDate(Year, 07, 01);
        FEndDate := EncodeDate(Year, 09, 30);
      end;
      10..12:
      begin
        FDate := EncodeDate(Year, 10, 01);
        FEndDate := EncodeDate(Year, 12, 31);
      end;
    end;
  end
  else if Key = 'Н' then
  begin
    FKind := dpkWeek;
    NumberWeek := ISOWeekNumber(SysUtils.Now);
    FDate := ISOWeekToDateTime(Year, NumberWeek ,1);
    FEndDate := ISOWeekToDateTime(Year, NumberWeek ,7); 
  end
  else if Key = 'З' then
  begin
    FDate := EncodeDate(Year, Month,Day) + 1;
    FEndDate := FDate;
    FKind := dpkDay;
  end
  else if Key = 'В' then
  begin
  FDate := EncodeDate(Year, Month,Day) - 1;
    FEndDate := FDate;
    FKind := dpkDay;
  end
  else if Key = 'С' then
  begin
    FKind := dpkDay;
    FDate := SysUtils.Date;
    FEndDate := FDate;
  end else
    Result := False;
end;

procedure TgsDataPeriod.Assign(const ASource: TgsDataPeriod);
begin
  FDate := ASource.Date;
  FEndDate := ASource.Date;
  FMaxDate := ASource.FMaxDate;
  FMinDate := ASource.FMinDate;
  FKind := ASource.Kind;
end;

function TgsDataPeriod.EncodeString: String;
var
  Year, Month, Day: Word;
begin
 Case FKind of
  dpkYear:
  begin
    DecodeDate(Date,Year, Month, Day);
    Result := IntToStr(Year);
   end;
  dpkWeek:
  begin
   Result :=DateToStr(FDate) + '-' + DateToStr(FEndDate);
  end;
  dpkQuarter:
  begin
   Result :=DateToStr(FDate) + '-' + DateToStr(FEndDate);
  end;
  dpkMonth:
  begin
   DecodeDate(Date,Year, Month, Day);
   Result := IntToStr(Month) + '.' + IntToStr(Year); 
  end;
  dpkDay:
  begin
   Result := DateToStr(FDate);
  end;
  dpkFree:
  begin
    Result := DateToStr(FDate) + '-' + DateToStr(FEndDate);
  end;  
  end;
end;

procedure TgsDataPeriod.DecodeString(const AString: String);
 var
  ss: string;
  Year, Month, Day, I: Word;
begin
  if AString = '' then
     exit;
   if StrPos(PChar(AString), '-') <> nil  then
        begin
        FKind := dpkFree;
        for I := 1 to Length(AString) do
           if AString[I] = '-' then
           begin
             if StrPos(PChar(ss), '.') = nil then
               FDate := EncodeDate(StrToInt(ss), 01, 01)
             else
               FDate := StrToDate(ss);
               ss := '';
            end else
              ss := ss+ AString[I];
              if StrPos(PChar(ss), '.') = nil then
                FEndDate := EncodeDate(StrToInt(ss), 12, 31)
              else
                FEndDate := StrToDate(ss);
              DecodeDate(FDate, Year, Month, Day);
              if EncodeDate(Year,Month + 1, Day) - 1 = FEndDate then
                FKind := dpkMonth
              else
                if DateAdd('M', +3, FDate) - 1 = FEndDate then 
                  FKind := dpkQuarter;
         end
        else
        if StrPos (PChar(AString), '.') = nil then
        begin
          FDate := StrToDate('01.01.' + AString);
          FEndDate := StrToDate('31.12.' + AString);
          FKind := dpkYear;
        end  else
        if length(AString) <= 7   then
        begin
          FDate := StrToDate('01.' + AString);
          DecodeDate(Date,Year, Month, Day);
          FEndDate := StrToDate(IntToStr(DaysInMonth(EncodeDate(Year, Month, 7))) + '.' + AString);
          FKind := dpkMonth;
        end  else
        begin
          FDate := StrToDate(AString);
          FEndDate := StrToDate(AString);
          FKind := dpkDay;
        end;
      if (FMinDate <>FMaxDate) and ((FMinDate <> 0) or (FMaxDate <> 0)) then  
         if (FDate < FMinDate) or (FEndDate > FMaxDate) then
           Raise EgsDatePeriod.Create('превышен диапозон дат');
end;

procedure TgsEditPeriod.OnMyTimer(Sender: TObject);
begin
   if FEdit.Focused = true then
     if Length(ShortCut) = 1 then
       if DatePeriod.ProcessShortCut(ShortCut) = true then
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
  FPeriodWind.Hide;
end;

function TgsCalendarPanel.CanvasYear(h: TCanvas): Boolean;
const
  YearCellWidth = 37;
  YearCellHeight = 35;
  YearCellXCount = 4;
  YearCellYCount = 3;
var
  I, J, X, Y: Integer;
  R: TRect;
  Size: TSize;
begin
  result := true;
  h.Font.Name := 'Tahoma';//'Sylfaen';
  h.Font.Size := 9;
  h.Brush.Style := bsSolid;
  h.Pen.Color := clWindow;
  if b = false then
  begin
    X := 0;
    for I := 1 to YearCellXCount do
    begin
      Y := 30;
      for J := 1 to YearCellYCount do
      begin
        h.Brush.Color := clWindow;
        R := Rect(X, Y, X + YearCellWidth, Y + YearCellHeight);
        h.FillRect(R);                             ;
        Size := h.TextExtent(IntToStr(ClickYear(J, I)));
        h.TextRect(R, X + ((YearCellWidth - Size.cx) div 2), Y + ((YearCellHeight - Size.cy) div 2),IntToStr(ClickYear(J, I)));
        Inc(Y, YearCellHeight);
      end;
      Inc(X, YearCellWidth);
      end;
     end    else
     begin
       h.Brush.Color := clWindow;
       R := Rect((FlX - 1) * YearCellWidth, (FlY -2) * YearCellHeight +30 , (FlX - 1) * YearCellWidth + YearCellWidth, (FlY - 2) * YearCellHeight +30 + YearCellHeight);
       h.FillRect(R);
       Size := Canvas.TextExtent(IntToStr(ClickYear(FlY - 1, FlX)));
       h.TextRect(R, (FlX - 1) * YearCellWidth + ((YearCellWidth - Size.cx) div 2), (FlY - 2) * YearCellHeight +30 + ((YearCellHeight - Size.cy) div 2),IntToStr(ClickYear(FlY - 1, FlX)));

       h.Brush.Color := $00FFFF99;
       R := Rect((NX - 1) * YearCellWidth, (NY -2) * YearCellHeight +30 , (NX - 1) * YearCellWidth + YearCellWidth, (NY - 2) * YearCellHeight +30 + YearCellHeight);
       h.FillRect(R);
       Size := Canvas.TextExtent(IntToStr(ClickYear(NY - 1, NX)));
       h.TextRect(R, (NX - 1) * YearCellWidth + ((YearCellWidth - Size.cx) div 2), (NY - 2) * YearCellHeight +30 + ((YearCellHeight - Size.cy) div 2),IntToStr(ClickYear(NY - 1, NX)));
     end;
end;

function TgsCalendarPanel.CanvasMonth(h: TCanvas): Boolean;
const
  MonthCellWidth = 37;
  MonthCellHeight = 35;
  MonthCellXCount = 4;
  MonthCellYCount = 3;
  Month: array [1..3, 1..4] of String = (
    ('янв', 'фев', 'мар' , 'апр'),
    ('май', 'июн', 'июл', 'авг'),
    ('сен', 'окт', 'ноя', 'дек')
    ) ;
var
  I, J, X, Y: Integer;
  R: TRect;
  Size: TSize;
begin
  Result := true;
  h.Font.Name := 'Tahoma';//'Sylfaen';
  h.Font.Size := 9;
  h.Brush.Style := bsSolid;
  h.Pen.Color := clWindow;
  if b = false  then
  begin
    X := 0;
    for I := 1 to MonthCellXCount do
    begin
      Y := 30;
      for J := 1 to MonthCellYCount do
      begin
        h.Brush.Color := clWindow;
        R := Rect(X, Y, X + MonthCellWidth, Y + MonthCellHeight);
        h.FillRect(R);
        Size := h.TextExtent(Month[J,I]);
        h.TextRect(R, X + ((MonthCellWidth - Size.cx) div 2), Y + ((MonthCellHeight - Size.cy) div 2), Month[J,I]);
        Inc(Y, MonthCellHeight);
      end;
      Inc(X, MonthCellWidth);
    end;
  end  else
  if b = true then
  begin
    h.Brush.Color := clWindow;
    R := Rect((FlX - 1) * MonthCellWidth, (FlY - 2) * MonthCellHeight + 30, (FlX ) * MonthCellWidth , (FlY - 2) * MonthCellHeight + 30 + MonthCellHeight);
    h.FillRect(R);
    Size := h.TextExtent(Month[FlY-1,FlX]);
    h.TextRect(R, (FlX - 1) * MonthCellWidth + ((MonthCellWidth - Size.cx) div 2), (FlY - 2) * MonthCellHeight + 30 + ((MonthCellHeight - Size.cy) div 2),Month[FlY-1,FlX]);

    h.Brush.Color := $00FFFF99;
    R := Rect((NX - 1) * MonthCellWidth, (NY - 2) * MonthCellHeight + 30, (NX ) * MonthCellWidth , (NY - 2) * MonthCellHeight + 30 + MonthCellHeight);
    h.FillRect(R);
    Size := h.TextExtent(Month[NY-1,NX]);
    h.TextRect(R, (NX - 1) * MonthCellWidth + ((MonthCellWidth - Size.cx) div 2), (NY - 2) * MonthCellHeight + 30 + ((MonthCellHeight - Size.cy) div 2),Month[NY-1,NX]);
  end;
end;

{function TgsCalendarPanel.PaintCanvas(h: TCanvas): Boolean;

const
  YearCellWidth = 37;
  YearCellHeight = 35;
  YearCellXCount = 4;
  YearCellYCount = 3;
  MonthCellWidth = 37;
  MonthCellHeight = 35;
  MonthCellXCount = 4;
  MonthCellYCount = 3;
  DayCellWidth = 21;
  DayCellHeight = 15;
  DayCellXCount = 7;
  DayCellYCount = 7;
  Month: array [1..3, 1..4] of String = (
    ('янв', 'фев', 'мар' , 'апр'),
    ('май', 'июн', 'июл', 'авг'),
    ('сен', 'окт', 'ноя', 'дек')
    ) ;
  Day: array [1..7] of String = ('Пн', 'Вт', 'Ср', 'Чт','Пт', 'Сб', 'Вс');
var
  I, J, X, Y: Integer;
  R: TRect;
  Size: TSize;
begin
  inherited;
  Canvas.Font.Name := 'Arial';//'Sylfaen';
  Canvas.Font.Size := 13;
  Canvas.Font.Height := 15;

  case FCalendarState of
    gscsYear:
       begin
         Canvas.Brush.Style := bsSolid;
         Canvas.Pen.Color := clWindow;
         if b = false then
         begin
           X := 0;
           for I := 1 to YearCellXCount do
           begin
             Y := 30;
             for J := 1 to YearCellYCount do
             begin
               Canvas.Brush.Color := clWindow;
               R := Rect(X, Y, X + YearCellWidth, Y + YearCellHeight);
               Canvas.FillRect(R);                             ;
               Size := Canvas.TextExtent(IntToStr(ClickYear(J, I)));
               Canvas.TextRect(R, X + ((YearCellWidth - Size.cx) div 2), Y + ((YearCellHeight - Size.cy) div 2),IntToStr(ClickYear(J, I)));
               Inc(Y, YearCellHeight);
             end;
           Inc(X, YearCellWidth);
         end;
     end    else
     begin
       Canvas.Brush.Color := clWindow;
       R := Rect((FlX - 1) * YearCellWidth, (FlY -2) * YearCellHeight +30 , (FlX - 1) * YearCellWidth + YearCellWidth, (FlY - 2) * YearCellHeight +30 + YearCellHeight);
       Canvas.FillRect(R);
       Size := Canvas.TextExtent(IntToStr(ClickYear(FlY - 1, FlX)));
       Canvas.TextRect(R, (FlX - 1) * YearCellWidth + ((YearCellWidth - Size.cx) div 2), (FlY - 2) * YearCellHeight +30 + ((YearCellHeight - Size.cy) div 2),IntToStr(ClickYear(FlY - 1, FlX)));

       Canvas.Brush.Color := $00FFFF99;
       R := Rect((NX - 1) * YearCellWidth, (NY -2) * YearCellHeight +30 , (NX - 1) * YearCellWidth + YearCellWidth, (NY - 2) * YearCellHeight +30 + YearCellHeight);
       Canvas.FillRect(R);
       Size := Canvas.TextExtent(IntToStr(ClickYear(NY - 1, NX)));
       Canvas.TextRect(R, (NX - 1) * YearCellWidth + ((YearCellWidth - Size.cx) div 2), (NY - 2) * YearCellHeight +30 + ((YearCellHeight - Size.cy) div 2),IntToStr(ClickYear(NY - 1, NX)));
     end;
    end;
    gscsMonth:
       begin
         Canvas.Brush.Style := bsSolid;
         Canvas.Pen.Color := clWindow;
         if b = false  then
         begin
           X := 0;
           for I := 1 to MonthCellXCount do
           begin
             Y := 30;
             for J := 1 to MonthCellYCount do
             begin
               Canvas.Brush.Color := clWindow;
               R := Rect(X, Y, X + MonthCellWidth, Y + MonthCellHeight);
               Canvas.FillRect(R);
               Size := Canvas.TextExtent(Month[J,I]);
               Canvas.TextRect(R, X + ((MonthCellWidth - Size.cx) div 2), Y + ((MonthCellHeight - Size.cy) div 2), Month[J,I]);
               Inc(Y, MonthCellHeight);
             end;
            Inc(X, MonthCellWidth);
          end;
    end  else
    if b = true then
    begin
      Canvas.Brush.Color := clWindow;
      R := Rect((FlX - 1) * MonthCellWidth, (FlY - 2) * MonthCellHeight + 30, (FlX ) * MonthCellWidth , (FlY - 2) * MonthCellHeight + 30 + MonthCellHeight);
      Canvas.FillRect(R);
      Size := Canvas.TextExtent(Month[FlY-1,FlX]);
      Canvas.TextRect(R, (FlX - 1) * MonthCellWidth + ((MonthCellWidth - Size.cx) div 2), (FlY - 2) * MonthCellHeight + 30 + ((MonthCellHeight - Size.cy) div 2),Month[FlY-1,FlX]);

      Canvas.Brush.Color := $00FFFF99;
      R := Rect((NX - 1) * MonthCellWidth, (NY - 2) * MonthCellHeight + 30, (NX ) * MonthCellWidth , (NY - 2) * MonthCellHeight + 30 + MonthCellHeight);
      Canvas.FillRect(R);
      Size := Canvas.TextExtent(Month[NY-1,NX]);
      Canvas.TextRect(R, (NX - 1) * MonthCellWidth + ((MonthCellWidth - Size.cx) div 2), (NY - 2) * MonthCellHeight + 30 + ((MonthCellHeight - Size.cy) div 2),Month[NY-1,NX]);
    end;
  end;
    gscsDay:
       begin

         Canvas.Brush.Style := bsSolid;
         Canvas.Pen.Color := clWindow;
         if b = false then
         begin
           X := 0;
           Y := 30;
           for I := 1 to DayCellXCount do
           begin
             Canvas.Brush.Color := clWindow;
             R := Rect(X, Y, X + DayCellWidth, Y + DayCellHeight);
             Canvas.FillRect(R);
             Canvas.TextRect(R, X , Y , Day[I]);
             Inc(X, DayCellWidth);
           end;
           Y :=  DayCellHeight +30;
           for I := 2 to DayCellYCount do
           begin
             X := 0;
             for J := 1 to DayCellXCount do
             begin
               if (ClickDay(J ,I-1, Year, FCalendarMonth) = DataToday) and (Year = YearToday) and (MonthToday = FCalendarMonth) and (FTodayDayWeek = J) then
                 Canvas.Brush.Color := clAqua
               else
                 Canvas.Brush.Color := clWindow;
               R := Rect(X, Y, X + DayCellWidth, Y + DayCellHeight + 1);
               Canvas.FillRect(R);
               Size := Canvas.TextExtent(IntToStr(ClickDay(J, I-1, Year, FCalendarMonth)));
               Canvas.TextRect(R, X + ((DayCellWidth - Size.cx) div 2), Y + ((DayCellHeight - Size.cy) div 2),IntToStr(ClickDay(J, I-1, Year, FCalendarMonth)));
               Inc(X, DayCellWidth);
               Inc(FNumberDay, 1);
              end;
              Inc(Y, DayCellHeight);
            end;
        end    else
        begin
          if (FlY > 2) and (NY > 2) then
          begin
            Canvas.Brush.Color := clWindow;
            R := Rect((FlX - 1) * DayCellWidth, (FlY - 2) * DayCellHeight  + 30 , (FlX ) * DayCellWidth, (FlY - 1) * DayCellHeight + 30);
            Canvas.FillRect(R);
            Size := Canvas.TextExtent(IntToStr(ClickDay(FlX, FlY - 2, Year, FCalendarMonth)));
            Canvas.TextRect(R, (FlX - 1) * DayCellWidth + ((DayCellWidth - Size.cx) div 2)  , (FlY - 2) * DayCellHeight + 30 + ((DayCellHeight -Size.cy) div 2),IntToStr(ClickDay(FlX, FlY - 2, Year, FCalendarMonth)));

            Canvas.Brush.Color := $00FFFF99;
            R := Rect((NX - 1) * DayCellWidth, (NY - 2) * DayCellHeight  + 30 , (NX ) * DayCellWidth, (NY - 1) * DayCellHeight + 30);
            Canvas.FillRect(R);
            Size := Canvas.TextExtent(IntToStr(ClickDay(NX, NY - 2, Year, FCalendarMonth)));
            Canvas.TextRect(R, (NX - 1) * DayCellWidth + ((DayCellWidth - Size.cx) div 2)  , (NY - 2) * DayCellHeight + 30 + ((DayCellHeight -Size.cy) div 2),IntToStr(ClickDay(NX, NY - 2, Year, FCalendarMonth)));
          end;
       end;
     end;
 end;
  if  (b = false) and (FCalendarState = gscsYear)  then
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.Brush.Style := bsSolid;
    R := Rect(0, 0, 147 , 30 );
    Canvas.FillRect(R);
    Size:=Canvas.TextExtent('2009-2020');
    Canvas.TextOut((147 - Size.cx) div 2,(30 - Size.cy) div 2,'2009-2020');
  end;
  if (b = false) and (FCalendarState = gscsMonth)  then
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.Brush.Style := bsSolid;
    R := Rect(0, 0, 147 , 30 );
    Canvas.FillRect(R);
    Canvas.Pen.Color := clBlack;
    Canvas.MoveTo(10, 11);
    Canvas.LineTo(10, 18);
    Canvas.LineTo(5, 15);
    Canvas.LineTo(10, 11);
    Canvas.MoveTo(137, 11);
    Canvas.LineTo(137, 18);
    Canvas.LineTo(142, 15);
    Canvas.LineTo(137, 11);
    Canvas.Brush.Color := clBlack;
    Canvas.FloodFill(8,15,clWhite,fsSurface);
    Canvas.FloodFill(139,15,clWhite,fsSurface);
    Canvas.Brush.Color := clWhite;
    Size := Canvas.TextExtent(IntToStr(Year));
    Canvas.TextOut((147 - Size.cx) div 2,(30 - Size.cy) div 2,IntToStr(Year));
  end;
  if (b = false) and (FCalendarState = gscsDay) then
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.Brush.Style := bsSolid;
    R := Rect(0, 0, 147 , 30 );
    Canvas.FillRect(R);
    Canvas.Pen.Color := clBlack;
    Canvas.MoveTo(10, 11);
    Canvas.LineTo(10, 18);
    Canvas.LineTo(5, 15);
    Canvas.LineTo(10, 11);
    Canvas.MoveTo(137, 11);
    Canvas.LineTo(137, 18);
    Canvas.LineTo(142, 15);
    Canvas.LineTo(137, 11);
    Canvas.Brush.Color := clBlack;
    Canvas.FloodFill(8,15,clWhite,fsSurface);
    Canvas.FloodFill(139,15,clWhite,fsSurface);
    Canvas.Brush.Color := clWhite;
    Size := Canvas.TextExtent(PanelMonth[FCalendarMonth] + IntToStr(Year));
    Canvas.TextOut((147 - Size.cx) div 2,(30 - Size.cy) div 2,PanelMonth[FCalendarMonth]+ '  ' + IntToStr(Year));
  end;
end; }



function TgsCalendarPanel.CanvasDay(h: TCanvas): Boolean;
const
  DayCellWidth = 21;
  DayCellHeight = 15;
  DayCellXCount = 7;
  DayCellYCount = 7;
  Day: array [1..7] of String = ('Пн', 'Вт', 'Ср', 'Чт','Пт', 'Сб', 'Вс');
var
  I, J, X, Y: Integer;
  R: TRect;
  Size: TSize;
begin
  Result := true;
  h.Font.Name := 'Tahoma';//'Sylfaen';
  h.Font.Size := 9;
  h.Brush.Style := bsSolid;
  h.Pen.Color := clWindow;
  if b = false then
  begin
    X := 0;
    Y := 30;
    for I := 1 to DayCellXCount do
    begin
      h.Brush.Color := clWindow;
      R := Rect(X, Y, X + DayCellWidth, Y + DayCellHeight);
      h.FillRect(R);
      h.TextRect(R, X , Y , Day[I]);
      Inc(X, DayCellWidth);
    end;
    Y :=  DayCellHeight +30;
    for I := 2 to DayCellYCount do
    begin
      X := 0;
      for J := 1 to DayCellXCount do
      begin
        if (ClickDay(J ,I-1, Year, FCalendarMonth) = DataToday) and (Year = YearToday) and (MonthToday = FCalendarMonth) and (FTodayDayWeek = J) then
          h.Brush.Color := clAqua
        else
        h.Brush.Color := clWindow;
        R := Rect(X, Y, X + DayCellWidth, Y + DayCellHeight + 1);
        h.FillRect(R);
        Size := h.TextExtent(IntToStr(ClickDay(J, I-1, Year, FCalendarMonth)));
        if ClickDay(J, I-1, Year, FCalendarMonth) in [1..9] then
          Size.cx :=1; 
        h.TextRect(R, X + ((DayCellWidth - Size.cx) div 2), Y + ((DayCellHeight - Size.cy) div 2),IntToStr(ClickDay(J, I-1, Year, FCalendarMonth)));
        Inc(X, DayCellWidth);
        Inc(FNumberDay, 1);
      end;
      Inc(Y, DayCellHeight);
    end;
  end   else
  begin
    if (FlY > 2) and (NY > 2) then
    begin
      if (ClickDay(FlX, FlY - 2,Year, FCalendarMonth) = DataToday) and (Year = YearToday) and (MonthToday = FCalendarMonth) and (FTodayDayWeek = FlX)  then
          h.Brush.Color := clAqua
      else
        h.Brush.Color := clWindow;
      R := Rect((FlX - 1) * DayCellWidth, (FlY - 2) * DayCellHeight  + 30 , (FlX ) * DayCellWidth, (FlY - 1) * DayCellHeight + 30);
      h.FillRect(R);
      Size := h.TextExtent(IntToStr(ClickDay(FlX, FlY - 2, Year, FCalendarMonth)));
      if ClickDay(FlX, FlY - 2, Year, FCalendarMonth) in [1..9] then
          Size.cx :=1;
      h.TextRect(R, (FlX - 1) * DayCellWidth + ((DayCellWidth - Size.cx) div 2)  , (FlY - 2) * DayCellHeight + 30 + ((DayCellHeight -Size.cy) div 2),IntToStr(ClickDay(FlX, FlY - 2, Year, FCalendarMonth)));
      h.Brush.Color := $00FFFF99;
      R := Rect((NX - 1) * DayCellWidth, (NY - 2) * DayCellHeight  + 30 , (NX ) * DayCellWidth, (NY - 1) * DayCellHeight + 30);
      h.FillRect(R);
      Size := h.TextExtent(IntToStr(ClickDay(NX, NY - 2, Year, FCalendarMonth)));
      if ClickDay(NX, NY - 2, Year, FCalendarMonth) in [1..9] then
          Size.cx :=1;
      h.TextRect(R, (NX - 1) * DayCellWidth + ((DayCellWidth - Size.cx) div 2)  , (NY - 2) * DayCellHeight + 30 + ((DayCellHeight -Size.cy) div 2),IntToStr(ClickDay(NX, NY - 2, Year, FCalendarMonth)));
    end;
  end;
end;
end.
