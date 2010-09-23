
unit gsPeriodEdit;

interface

uses
  Classes, Windows, Controls, Graphics, ExtCtrls, Messages, StdCtrls, Dialogs, Buttons, forms,ComObj, registry, SysUtils;

type
  TgsCalendarState = (gscsYear, gscsMonth, gscsDay);
  TgsMonth = (gscsJan,gscsFev,gscsMar,gscsApr,gscsMay,gscsIun,gscsIul,gscsAvg,gscsSen,gscsOct,gscsNojb,gscsDec);
  TgsDatePeriodKind = (dpkYear, dpkQuarter, dpkMonth, dpkWeek, dpkDay, dpkFree);
  const
  DefCalendarState = gscsYear;
  DefKind = dpkFree;
  DefMaxDate = 0;
    YearNumber : array [1..3, 1..4] of Integer = (
     (2009, 2010, 2011, 2012),
     (2013, 2014, 2015, 2016),
     (2017, 2018, 2019, 2020)
     );
    YearColor : array [1..3, 1..4] of TColor = (
      (clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow)
      );
    MonthColor : array [1..3, 1..4] of TColor = (
      (clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow)
      );
    DayColor : array [1..7, 1..7] of TColor = (
      (clWindow, clWindow, clWindow, clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow, clWindow, clWindow, clWindow),
      (clWindow, clWindow, clWindow, clWindow, clWindow, clWindow, clWindow)
      );
   PanelMonth: array [1..12] of String= ('Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь', 'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь');
   LastData:array [1..12] of  Integer = (31,28,31,30,31,30,31,31,30,31,30,31);

type

 EgsDatePeriod = class(Exception)

 end;

 TgsCalendarPanel = class(TCustomControl)
  private
    NumberDay: array [1..7, 1..7] of Integer;
    b, vid : Boolean;
    FCalendarState : TgsCalendarState;
    Year,XX,YY,FCalendarMonth,FlX,FlY,NX,NY,FNumberDay, DataToday, YearToday, MonthToday, FTodayDayWeek, VibPeriod, TitleYear, TitleMonth, TitleDay : integer;
    procedure SetCalendarState(const Value: TgsCalendarState);

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;
    function ControlVid( Var X, Y: Integer):Boolean;

  protected
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
  property CalendarState: TgsCalendarState read FCalendarState write SetCalendarState
      default DefCalendarState;
  end;

TgsDataPeriod = class(TObject)
   private
     Kj, tir, Month, Day, FDayWeek: Integer;
     Sp: Char;
     Date, EndDate,FMaxDate, FMinDate :TDate;
     Kind: TgsDatePeriodKind;
     Raz: Boolean;
     procedure SetKindState(const Value: TgsDatePeriodKind);
     procedure SetKind(const pr: Integer);
   protected
     procedure Assign(const ASource: TgsDataPeriod);
     procedure ProcessShortCut(var Key: char; Text: String);
     function EncodeString: String;
     procedure DecodeString(const AString: String);
   public
     property PeriodKind: TgsDatePeriodKind read Kind write SetKindState
      default DefKind;
     property MaxDate: TDate read FMaxDate write FMaxDate;
     property MinDate: TDate read FMinDate write FMinDate;
     constructor Create;
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

  TgsPeriodEdit = class(TWinControl)

  private
     DatePeriod: TgsDataPeriod;
     FPeriodWind: TgsPeriodForm;
     FEdit: TgsPeriodShortCutEdit;
     FSpeedButton: TSpeedButton;
     Kj: Integer;
     FGuid : TGUID;
     Text :String;
     
  protected
    procedure KeyPress(Sender: TObject; var Key: Char);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage);
      message CM_MOUSELEAVE;
    procedure Change(Sender: TObject);
    procedure FOnExit(Sender: TObject);
    procedure Loaded; override;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure DoOnButtonClick(Sender: TObject);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
     property GUID : TGUID read FGUID write FGUID;
  end;





implementation

//uses
//  SysUtils;

{ TgsCalendarPanel }


function TgsCalendarPanel.CanResize(var NewWidth,
  NewHeight: Integer): Boolean;
begin
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
  var
   s, ss: String;
   I: Integer;
begin
  inherited ;
  s := DateToStr(SysUtils.Now);
  for I:=1 to Length(s) do
  begin
    if s[I]='.' then
    begin
      if I = 3 then
         DataToday := StrToInt(ss);
      if I = 6 then
      begin
       FCalendarMonth := StrToInt(ss);
       MonthToday := FCalendarMonth;
      end;
    ss:='';
  end  else
  ss:=ss+s[i];
end;

 FTodayDayWeek := DayOfWeek(StrToDate(s));
 if FTodayDayWeek = 1 then
     FTodayDayWeek := 7
 else
     FTodayDayWeek := FTodayDayWeek - 1;
   {DefCalendarState;   }
 FCalendarState :=  gscsDay;
 Year := StrToInt(ss);;
 YearToday := Year;
 FlX := 1;
 FlY := 2;
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
  I, J, X, Y, pF, prom  : Integer;
  R: TRect;
  Size: TSize;

begin
  inherited;
  Canvas.Font.Name := 'Tahoma';
  Canvas.Font.Size := 16 ;
  Canvas.Font.Height := 16;

  if (Year mod 4) = 0 then
     LastData[2] := 29;
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
               Size := Canvas.TextExtent(IntToStr(YearNumber[J, I]));
               Canvas.TextRect(R, X + ((YearCellWidth - Size.cx) div 2), Y + ((YearCellHeight - Size.cy) div 2),IntToStr(YearNumber[J, I]));
               Inc(Y, YearCellHeight);
             end;
           Inc(X, YearCellWidth);
         end;
     end    else
     begin
         Canvas.Brush.Color := YearColor[FlY, FlX];
         R := Rect((FlX - 1) * YearCellWidth, (FlY -2) * YearCellHeight +30 , (FlX - 1) * YearCellWidth + YearCellWidth, (FlY - 2) * YearCellHeight +30 + YearCellHeight);
         Canvas.FillRect(R);
         Size := Canvas.TextExtent(IntToStr(YearNumber[FlY - 1, FlX]));
         Canvas.TextRect(R, (FlX - 1) * YearCellWidth + ((YearCellWidth - Size.cx) div 2), (FlY - 2) * YearCellHeight +30 + ((YearCellHeight - Size.cy) div 2),IntToStr(YearNumber[FlY - 1, FlX]));
     end;
    end;
    gscsMonth:
       Begin
          Canvas.Brush.Style := bsSolid;
          Canvas.Pen.Color := clWindow;
          if b = false  then
          Begin
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
    end   else
    if b = true then
    Begin
       Canvas.Brush.Color := MonthColor[FlY, FlX];
       R := Rect((FlX - 1) * MonthCellWidth, (FlY - 2) * MonthCellHeight + 30, (FlX ) * MonthCellWidth , (FlY - 2) * MonthCellHeight + 30 + MonthCellHeight);
       Canvas.FillRect(R);
       Size := Canvas.TextExtent(Month[FlY-1,FlX]);
       Canvas.TextRect(R, (FlX - 1) * MonthCellWidth + ((MonthCellWidth - Size.cx) div 2), (FlY - 2) * MonthCellHeight + 30 + ((MonthCellHeight - Size.cy) div 2),Month[FlY-1,FlX]);
    end;
  end;
    gscsDay:
       begin
          pF := DayOfWeek(StrToDate('01.'+IntToStr(FCalendarMonth)+'.'+IntToStr(Year)));
          if pF = 1 then
             pF := 7
          else
            pF := pF-1;
          FNumberDay := 1;
          prom := pF;
          For I:=1 to 7 do
          Begin
             For J:=prom to 7 do
             begin
                 if FNumberDay > LastData[FCalendarMonth] then
                   FNumberDay := 1;
                 NumberDay[J,I] :=FNumberDay;
                 FNumberDay := FNumberDay + 1;
             end;
             prom:=1;
             end;
             if (FCalendarMonth - 1) <= 0 then
                FNumberDay := LastData[12]
             else
                FNumberDay := LastData[FCalendarMonth-1];
              For J:=1 to pF - 1 do
              Begin
                 NumberDay[pF - J,1] := FNumberDay;
                 FNumberDay := FNumberDay - 1;
              end;
       Canvas.Brush.Style := bsSolid;
       Canvas.Pen.Color := clWindow;
    if b = false then
    Begin
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
          if (NumberDay[J ,I-1] = DataToday) and (Year = YearToday) and (MonthToday = FCalendarMonth) and (FTodayDayWeek = J) then
             Canvas.Brush.Color := clAqua
          else
             Canvas.Brush.Color := clWindow;
             R := Rect(X, Y, X + DayCellWidth, Y + DayCellHeight + 1);
             Canvas.FillRect(R);
             Size := Canvas.TextExtent(IntToStr(NumberDay[J ,I-1]));
             Canvas.TextRect(R, X + ((DayCellWidth - Size.cx) div 2), Y + ((DayCellHeight - Size.cy) div 2),IntToStr(NumberDay[J ,I-1]));
             Inc(X, DayCellWidth);
             Inc(FNumberDay, 1);
         end;
       Inc(Y, DayCellHeight);
      end;
     end    else
     Begin
       if FlY > 2 then
       begin
         Canvas.Brush.Color := DayColor[FlX, FlY];
         R := Rect((FlX - 1) * DayCellWidth, (FlY - 2) * DayCellHeight  + 30 , (FlX ) * DayCellWidth, (FlY - 1) * DayCellHeight + 30);
         Canvas.FillRect(R);
         Size := Canvas.TextExtent(IntToStr(NumberDay[FlX  , FlY - 2]));
         Canvas.TextRect(R, (FlX - 1) * DayCellWidth + ((DayCellWidth - Size.cx) div 2)  , (FlY - 2) * DayCellHeight + 30 + ((DayCellHeight -Size.cy) div 2),IntToStr(NumberDay[FlX  , FlY - 2]));
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
     Size := Canvas.TextExtent(PanelMonth[FCalendarMonth]+ '  ' + IntToStr(Year));
     Canvas.TextOut((147 - Size.cx) div 2,(30 - Size.cy) div 2,PanelMonth[FCalendarMonth]+ '  ' + IntToStr(Year));
  end;
end;


procedure TgsCalendarPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  FocusMonth : array [1..3, 1..4] of Integer = (
    (1, 2, 3, 4),
    (5, 6, 7, 8),
    (9, 10, 11, 12)
    );

begin
inherited MouseDown(Button, Shift, X, Y);
    b := false;
    FlX := 2;
    FlY := 2;
    Vid := false;

  if (FCalendarState = gscsMonth) and (Y > 30) and (VibPeriod <> 2) and (VibPeriod <>3) then
  begin
    FCalendarState := gscsDay;
    FCalendarMonth := FocusMonth[((Y-30) div 37) + 1, (X div 35) + 1];
  end else
   if (VibPeriod = 2) or (VibPeriod = 3)  then
       FCalendarMonth := FocusMonth[((Y-30) div 37) + 1, (X div 35) + 1];
  if  (FCalendarState = gscsYear) and (Y > 30) and (VibPeriod <> 1)  then
  begin
     FCalendarState := gscsMonth;
     Year := YearNumber[((Y-30) div 37) + 1, (X div 35) + 1];
  end else
   if VibPeriod = 1 then
        Year := YearNumber[((Y-30) div 37) + 1, (X div 35) + 1];

  if (FCalendarState = gscsMonth) and ((X < 30) and (Y < 30)) then
     Year := Year - 1;

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
  end else
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
  TitleYear := Year;
  TitleMonth := FCalendarMonth;
  if  (FCalendarState = gscsDay) and (Y > 30) then
     TitleDay := NumberDay [((X div 21) + 1), (((Y-30) div 15))];
  paint;
end;


procedure TgsCalendarPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
inherited MouseMove(Shift, X, Y);
end;

procedure TgsCalendarpanel.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited ;
  XX := Message.XPos;
  YY := Message.YPos;
  b := ControlVid(XX, YY);
end;

function TgsCalendarPanel.ControlVid( Var X,Y:Integer):boolean;
begin
  if Y > 30 then
    case FCalendarState of
    gscsYear:
       begin
          NX := (X div 37) + 1;
          NY := ((Y - 30) div 35) + 2;
          YearColor[FlY, FlX] := clWhite;
          YearColor[NY, NX] := $00FFFF99;
          paint;
          FlX := NX;
          FlY := NY;
          Result := true;
        end;
    gscsMonth:
        begin
          NX := (X div 37) + 1;
          NY := ((Y - 30) div 35) + 2;
          MonthColor[FlY, FlX] := clWhite;
          MonthColor[NY, NX] := $00FFFF99;
          paint;
          FlX := NX;
          FlY := NY;
          Result := true;
        end;
    gscsDay:
        begin
          NX := (X div 21) + 1;
          NY := ((Y-30) div 15) + 2;
          DayColor[FlX, FlY] := clWhite;
          DayColor[NX, NY] := $00FFFF99;
          paint;
          FlX := NX;
          FlY := NY;
          Result := true;
        end;
      end   else
      begin
        Result :=false;
        FlX := 2;
        FlY := 2;
      end;
end;

procedure TgsCalendarPanel.CMMouseLeave(var Message: TMessage);
var
 I,J : Integer;
begin
  for I := 1 to 4 do
     for J := 1 to 3 do
        YearColor[J,I] := clWhite;
  for I := 1 to 4 do
     for J := 1 to 3 do
        MonthColor[J,I] := clWhite;
  for I := 1 to 7 do
      for J := 1 to 7 do
         DayColor[J,I] := clWhite;
  b:=false;
  paint;
end;


procedure TgsCalendarPanel.SetCalendarState(const Value: TgsCalendarState);
begin
  FCalendarState := Value;
end;

{ TgsPeriodForm }

constructor TgsPeriodForm.Create(AnOwner: TComponent);
begin
  inherited;
  FObjPanel2 := TgsCalendarPanel.Create(Self);
  FObjPanel2.Parent := Self;
  NumberPeriod := 0;
  Width := 245;
  Height := 195;

  FObjPanel1 := TgsCalendarPanel.Create(Self);
  FObjPanel1.Parent := Self;
end;

procedure  TgsPeriodform.Paint;
const
   GodX = 10;
   GodY = 28;
   MonthX = 10;
   MonthY = 57;
   KvartX = 10;
   KvartY = 82;
   DayX =  10;
   DayY =  107;
   PeriodX = 10;
   PeriodY = 132;
   HistoryX =10;
   HistoryY = 157;
var
   Size : TSize;
   Str, ss, sss:String;
   Reg: TRegistry;
   I, K, DateX, DateY: Word;
begin
     Canvas.Brush.Color := clWhite;
     Canvas.Brush.Style := bsSolid;

     Canvas.Font.Size := 12;
     Size := Canvas.TextExtent('Год');
     if NumberPeriod = 1 then
     begin

       Canvas.Pen.Color := clWhite;
       Canvas.Brush.Color := clWhite;
       Canvas.Font.Size := 8;
       Canvas.Rectangle(88, 171,240,188);
       Canvas.TextOut(90,171,'Текущий год :' + IntToStr(FObjPanel1.YearToday) + 'г.');
       Canvas.Brush.Color := clRed;
       Canvas.Pen.Color := clRed;
        Canvas.Font.Size := 12;
     end else
     begin
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
     end;
       Canvas.Rectangle(GodX, GodY, GodX + 75, GodY + Size.cy + 10);
       Canvas.TextOut(GodX, GodY, 'Год');
       Canvas.Brush.Color :=clWhite;
       if NumberPeriod = 2 then
     begin
       Canvas.Brush.Color := clWindow;
       Canvas.Rectangle(88, 171,240,188);
       Canvas.Pen.Color := clRed;
       Canvas.Font.Size := 8;
       Canvas.TextOut(90,171,'Месяц:' + PanelMonth[FObjPanel1.MonthToday] + '  ' + IntToStr(FObjPanel1.YearToday)+'г.');
        Canvas.Brush.Color := clRed;
        Canvas.Font.Size := 12
     end  else
     begin
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
     end;
       Canvas.Rectangle(MonthX, MonthY, MonthX + 75, MonthY + Size.cy + 11);
       Canvas.TextOut(MonthX, MonthY, 'Месяц');

     if NumberPeriod = 3 then
     begin
        Canvas.Pen.Color := clWhite;
       Canvas.Brush.Color := clWhite;

       Canvas.Font.Size := 8;
       Canvas.Rectangle(88, 171,240,188);
       case FObjPanel1.MonthToday of
         1..3:
         begin
          Canvas.TextOut(90,171,'Квартал:' + '1кв.' + '  ' + IntToStr(FObjPanel1.YearToday)+'г.');
         end;
         4..6:
         begin
           Canvas.TextOut(90,171,'Квартал:' + '2кв.' + '  ' + IntToStr(FObjPanel1.YearToday)+'г.');
         end;
         7..9:
         begin
           Canvas.TextOut(90,171,'Квартал:' + '3кв.' + '  ' + IntToStr(FObjPanel1.YearToday)+'г.');
         end;
         10..12:
         begin
           Canvas.TextOut(90,171,'Квартал:' + '4кв.' + '  ' + IntToStr(FObjPanel1.YearToday)+'г.');
         end;
       end;
       Canvas.Pen.Color := clRed;
        Canvas.Brush.Color := clRed;
        Canvas.Font.Size := 12
     end  else
     begin
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
     end;

       Canvas.Rectangle(KvartX, KvartY, KvartX + 75, KvartY + Size.cy + 10);
       Canvas.TextOut(KvartX, KvartY, 'Квартал');
       Canvas.Brush.Color := clWhite;

     if NumberPeriod = 4 then
     begin
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
       Canvas.Font.Size := 8;
       Canvas.Rectangle(88, 171,240,188);
       Canvas.TextOut(90,171,'Сегодня: ' + DateToStr(SysUtils.Now) + 'г.');
       Canvas.Brush.Color := clRed;
       Canvas.Pen.Color := clRed;
        Canvas.Font.Size := 12;
     end  else
     begin
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
     end;

       Canvas.Rectangle(DayX, DayY, DayX + 75, DayY + Size.cy + 10);
       Canvas.TextOut(DayX, DayY, 'День');
       Canvas.Brush.Color := clWhite;

     if NumberPeriod = 5 then
     begin

       Canvas.Font.Size := 8;
       Canvas.Rectangle(88, 171,410,188);
       Canvas.TextOut(88,171,'Сегодня: ' + DateToStr(SysUtils.Now) + 'г.');
       Canvas.TextOut(300,171,'Сегодня: ' + DateToStr(SysUtils.Now) + 'г.');
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
       Canvas.Rectangle(241, 33,258,163);
       Canvas.Brush.Color := clRed;
       Canvas.Pen.Color := clRed;
        Canvas.Font.Size := 12;
     end  else
     begin
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
     end;
       Canvas.Rectangle(PeriodX, PeriodY, PeriodX + 75, PeriodY + Size.cy+6);
       Canvas.TextOut(PeriodX, PeriodY, 'Период');

     if (NumberPeriod <> 0) and (NumberPeriod <> 5) and (NumberPeriod <> 6) then
     begin

       Canvas.MoveTo(88, 27);
       Canvas.Brush.Color := clRed;
       Canvas.Pen.Color := clRed;
       Canvas.Pen.Width := 6;
       Canvas.LineTo(241, 26);
       Canvas.LineTo(241, 168);
       Canvas.LineTo(88, 168);
       Canvas.LineTo(88, 27);
       Canvas.MoveTo(245, 27);
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
       Canvas.Pen.Width := 6;
       Canvas.LineTo(410, 26);
       Canvas.LineTo(410, 168);
       Canvas.LineTo(245, 168);

     end else
      begin
       Canvas.MoveTo(88, 27);
       Canvas.Brush.Color := clWindow;
       Canvas.Pen.Color :=clWindow;
       Canvas.Pen.Width := 6;
       Canvas.LineTo(235, 26);
       Canvas.LineTo(235, 168);
       Canvas.LineTo(88, 168);
       Canvas.LineTo(88, 27);

     if (NumberPeriod = 5) or (NumberPeriod = 6) then
      begin
        Canvas.MoveTo(88, 27);
        Canvas.Brush.Color := clRed;
        Canvas.Pen.Color := clRed;
        Canvas.Pen.Width := 6;
        Canvas.LineTo(410, 26);
        Canvas.LineTo(410, 168);
        Canvas.LineTo(88, 168);
        Canvas.LineTo(88, 27);
      end

    end;
   if NumberPeriod = 6 then
     begin
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
       Canvas.Rectangle(93, 33,404,164);
       Canvas.Rectangle(88, 173,410,188);

        Reg:= TRegistry.Create;
        Reg.RootKey:= HKEY_CURRENT_USER;
        Reg.OpenKey('\Software\Golden Software\Gedemin\Client\CurrentVersion\TgsCalendarEdit', false);
        Str := Reg.ReadString('{741D1779-CE77-4843-808F-796DE1BCBB3E}');
        I := 2;

       if Str <> '' then
       begin
         DateX := 93;
         DateY := 35;
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
     end;
        Canvas.Brush.Color := clRed;
        Canvas.Pen.Color := clRed;
     end  else
     begin
       Canvas.Brush.Color := clWhite;
       Canvas.Pen.Color := clWhite;
     end ;

       Canvas.Rectangle(HistoryX, HistoryY, HistoryX + 73, HistoryY + Size.cy + 10);
       Canvas.TextOut(HistoryX, HistoryY, 'История');
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
  FObjPanel1.free;
  FObjPanel2.free;
  inherited Destroy;
end;

{ TgsPeriodEdit }

constructor TgsPeriodEdit.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FEdit := TgsPeriodShortCutEdit.Create(Self);
  FEdit.Parent := Self;
  DatePeriod := TgsDataPeriod.Create;

  FEdit.Height := 21;
  FEdit.Width := 200;
  FEdit.OnChange := Change;
  FEdit.OnKeyPress := KeyPress;
  FSpeedButton := TSpeedButton.Create(Self);
  FSpeedButton.Caption := '';
  FSpeedButton.Width := 19;
  FSpeedButton.Height := 19;
  FSpeedButton.Visible := True;
  FSpeedButton.Left := FEdit.Width;
  FSpeedButton.Parent := Self;
  FSpeedButton.OnClick := DoOnButtonClick;

  Width := FEdit.Width + FSpeedButton.Width;
  Height := FEdit.Height;
  Kj := 0;
  FPeriodWind := TgsPeriodForm.Create(Self);
  FPeriodWind.Parent := Self ;
  FPeriodWind.OnMouseDown := FormMouseDown;
  FPeriodWind.Visible := false;
  FPeriodWind.OnKeyDown := OnKeyDown;
  FPeriodWind.FObjPanel1.OnMouseUp := OnMouseDown;
  FPeriodWind.FObjPanel2.OnMouseUp := OnMouseUp;
  FPeriodWind.OnExit := FOnExit;
  if (csDesigning in ComponentState) and (not (csLoading in ComponentState)) then
     GUID := StringToGUID(CreateClassID());




end;
procedure TgsPeriodEdit.OnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
 var
  pr : Integer;
begin

  case  FPeriodWind.NumberPeriod of
   1:
   if Y > 30 then
   begin
      FEdit.Text := IntToStr(FPeriodWind.FObjPanel1.Year);
      FPeriodWind.FObjPanel2.Year := FPeriodWind.FObjPanel1.Year;
      FPeriodWind.Hide;
   end;
   2:
   if  (FPeriodWind.FObjPanel1.FCalendarState = gscsMonth) and (Y > 30)  then
   begin
       if  FPeriodWind.FObjPanel1.FCalendarMonth - 10 < 0 then
          FEdit.Text := '0' + IntToStr(FPeriodWind.FObjPanel1.FCalendarMonth) + '.'  + IntToStr(FPeriodWind.FObjPanel1.Year)
       else
          FEdit.Text :=IntToStr(FPeriodWind.FObjPanel1.FCalendarMonth) + '.'  + IntToStr(FPeriodWind.FObjPanel1.Year);
          DatePeriod.Month := FPeriodWind.FObjPanel1.FCalendarMonth;
          FPeriodWind.Hide;

   end;
   3: if  (Y > 30) then
       begin
         FPeriodWind.FObjPanel1.FCalendarState := gscsMonth;
         pr := 2;
         DatePeriod.SetKind(pr);
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
      if  FPeriodWind.FObjPanel1.FCalendarMonth - 10 < 0 then
       FEdit.Text := IntToStr(FPeriodWind.FObjPanel1.TitleDay)+ '.' + '0' + IntToStr(FPeriodWind.FObjPanel1.FCalendarMonth) + '.' + IntToStr(FPeriodWind.FObjPanel1.Year)
      else
       FEdit.Text := IntToStr(FPeriodWind.FObjPanel1.TitleDay)+ '.' + IntToStr(FPeriodWind.FObjPanel1.FCalendarMonth) + '.' + IntToStr(FPeriodWind.FObjPanel1.Year);
       DatePeriod.Day := FPeriodWind.FObjPanel1.TitleDay;
       FPeriodWind.Hide;
      end;
   end;

end;

procedure TgsPeriodEdit.OnMouseUp(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
begin

 if (FPeriodWind.NumberPeriod = 5) and (FPeriodWind.FObjPanel2.FCalendarState = gscsDay) and ( Y > 30) then
 begin
  if  FPeriodWind.FObjPanel1.FCalendarMonth - 10 < 0 then
   FEdit.Text := IntToStr(FPeriodWind.FObjPanel1.TitleDay)+ '.' + '0' + IntToStr(FPeriodWind.FObjPanel1.FCalendarMonth) + '.' + IntToStr(FPeriodWind.FObjPanel1.Year) + '-'
  else
    FEdit.Text := IntToStr(FPeriodWind.FObjPanel1.TitleDay)+ '.' + IntToStr(FPeriodWind.FObjPanel1.FCalendarMonth) + '.' + IntToStr(FPeriodWind.FObjPanel1.Year) + '-';

  if   FPeriodWind.FObjPanel2.FCalendarMonth - 10 < 0 then
    FEdit.Text := FEdit.Text + IntToStr(FPeriodWind.FObjPanel2.TitleDay)+ '.' + '0' + IntToStr(FPeriodWind.FObjPanel2.FCalendarMonth) + '.' + IntToStr(FPeriodWind.FObjPanel2.Year )
  else
     FEdit.Text := FEdit.Text + IntToStr(FPeriodWind.FObjPanel2.TitleDay)+ '.' + IntToStr(FPeriodWind.FObjPanel2.FCalendarMonth) + '.' + IntToStr(FPeriodWind.FObjPanel2.Year );
   FPeriodWind.Hide;
 end;
 FPeriodWind.Paint;
end;

procedure TgsPeriodEdit.OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_Escape: FPeriodWind.Hide;
   end;
end;

procedure TgsPeriodEdit.DoOnButtonClick(Sender: TObject);
begin
  if FPeriodWind.Visible = true then
    FPeriodWind.Hide
  else
  begin
  if FperiodWind.NumberPeriod = 5 then
     FPeriodWind.Width := 420
  else
  FPeriodWind.Width := 245;

  FPeriodWind.Left := ClientOrigin.x;
  FPeriodWind.Top := ClientOrigin.y  + Height;
  FPeriodWind.Paint;
  FPeriodWind.Visible := true;
   end;
  end;

procedure TgsPeriodEdit.FormMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
 var
  Year, Month, Day: Word;

begin
     DecodeDate(SysUtils.Now, Year, Month, Day);
     if (X > 245) and (Y > 170) then
     begin
        FPeriodWind.FObjPanel2.Year := Year;
        FPeriodWind.FObjPanel2.FCalendarMonth := Month;
        FPeriodWind.FObjPanel2.Paint;
          end;
    if (X > 70) and (X < 236) and (Y > 170) and (Y < 190) then
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
          if  (X > 70) and (X < 236) and (Y > 170) and (Y < 190) then
           begin
           FPeriodWind.FObjPanel1.Year := Year;
           FPeriodWind.FObjPanel1.FCalendarMonth := Month;
           FPeriodWind.FObjPanel1.Paint;
          end

          end;
         end;
       end;

  if (X >10) and (X < 85) and (Y < 180) and (Y > 26) then
  begin
     FPeriodWind.NumberPeriod := (Y - 28) div (57 - 28 - 3) + 1;
   Case FPeriodWind.NumberPeriod of
     1:
     begin
       FPeriodWind.Width := 245;
       FPeriodWind.FObjPanel1.FCalendarState := gscsYear;
       FPeriodWind.FObjPanel1.Show;
       FPeriodWind.FObjPanel1.VibPeriod := 1;
       FPeriodWind.FObjPanel2.Hide;
       FPeriodWind.FObjPanel1.Paint;
       FPeriodWind.paint;
     end;
     2:
     begin
        FPeriodWind.Width := 245;
        FPeriodWind.FObjPanel1.FCalendarState := gscsMonth;
        FPeriodWind.FObjPanel1.Show;
        FPeriodWind.FObjPanel1.VibPeriod := 2;
        FPeriodWind.FObjPanel2.Hide;
        FPeriodWind.FObjPanel1.Paint;
        FPeriodWind.paint;
     end;
     3:
     begin
        FPeriodWind.Width := 245;
        FPeriodWind.FObjPanel1.FCalendarState := gscsMonth;
        FPeriodWind.FObjPanel1.Show;
        FPeriodWind.FObjPanel1.VibPeriod := 3;
        FPeriodWind.FObjPanel2.Hide;
        FPeriodWind.FObjPanel1.Paint;
        FPeriodWind.paint;
     end;
     4:
     begin
        FPeriodWind.Width := 245;
        FPeriodWind.FObjPanel1.FCalendarState := gscsDay;
        FPeriodWind.FObjPanel1.Show;
        FPeriodWind.FObjPanel1.VibPeriod := 4;
        FPeriodWind.FObjPanel2.Hide;
        FPeriodWind.FObjPanel1.Paint;
        FPeriodWind.paint;
      end;
      5:
     begin
       FPeriodWind.Width := 420;
       FPeriodWind.FObjPanel1.FCalendarState := gscsDay;
       FPeriodWind.FObjPanel1.Show;
       FPeriodWind.FObjPanel1.VibPeriod := 5;
       FPeriodWind.FObjPanel2.Left := 260;
       FPeriodWind.FObjPanel2.Top :=30 ;
       FPeriodWind.FObjPanel2.Visible := true;
       FPeriodWind.FObjPanel1.Paint;
       FPeriodWind.Paint;

     end;
     6:
     begin
        FPeriodWind.Width := 420;
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
      FPeriodWind.FObjPanel1.Top := 30;
     end;

end;

procedure TgsPeriodEdit.Loaded;
begin
  inherited ;
 if GUIDToString(FGUID) = '{00000000-0000-0000-0000-000000000000}' then
     FGUID := StringToGUID(CreateClassID());

end;

procedure TgsPeriodEdit.KeyPress(Sender: TObject; var Key: Char);

begin
     case Key of
      'с': Key := 'С';
      'з': Key := 'З';
      'в': Key := 'В';
      'г': Key := 'Г';
      'т': Key := 'Т';
      'м': Key := 'М';
      'н': Key := 'Н';
      'п': Key := 'П';
      'к': Key := 'К';
      end;

   case Key of
   '0'..'9','-':begin
    Text := Text;
    end;
   'С','З','В','Г','Т','М','Н','П','К','.':
    begin
    DatePeriod.ProcessShortCut(Key, Text);
    FEdit.Text := DatePeriod.EncodeString;
    end;
    #32:
     begin
       FEdit.Text := Text + DateToStr(SysUtils.Now);
     end
    else
    Key := #0;
   end;
   FEdit.SetSelStart(Length(Text));


end;

procedure TgsPeriodEdit.Change(Sender: TObject);   //ставит точки
begin
  Text := FEdit.Text;
end;

procedure TgsPeriodEdit.FOnExit(Sender: TObject);
begin
  if FEdit.Text <> '' then
    DatePeriod.DecodeString(FEdit.Text);
end;

destructor TgsPeriodEdit.Destroy;
var
 Reg: TRegistry;
 Str: String;
 I: Word;

begin
 //DatePeriod.DecodeString(Text);
 FGUID :=StringToGuid('{741D1779-CE77-4843-808F-796DE1BCBB3E}');
 // StringToGUID(CreateClassID());
  Reg:= TRegistry.Create;
  Reg.RootKey:= HKEY_CURRENT_USER;
  Reg.OpenKey('\Software\Golden Software\Gedemin\Client\CurrentVersion\TgsCalendarEdit', false);
  Str := Reg.ReadString(GUIDToString(FGUID));
  I := 2;
  if Str <> '' then
    begin
  While Str[I] <> '"' do
   I := I + 1;
  if (copy(Str,2,I - 2)) = DateToStr(SysUtils.Now) then
      Reg.WriteString(GUIDToString(FGUID), '"' + DateToStr(SysUtils.Now) + '"' + ',' + '"' + DateToStr(DatePeriod.Date) + '-' + DateToStr(DatePeriod.EndDate) + '"' + copy(Str,I + 1, Length(Str)))
  else
       Reg.WriteString(GUIDToString(FGUID), '"' + DateToStr(SysUtils.Now) + '"' + ',' + '"' + DateToStr(DatePeriod.Date) + '-' + DateToStr(DatePeriod.EndDate) + '"' );
     end
  else
    Reg.WriteString(GUIDToString(FGUID), '"' + DateToStr(SysUtils.Now) + '"' + ',' + '"' + DateToStr(DatePeriod.Date) + '-' + DateToStr(DatePeriod.EndDate) + '"' );
  Reg.Free;
  DatePeriod.Free;
  FPeriodWind.Free;
  FEdit.Free;
  FSpeedButton.Free;
  inherited Destroy;
end;

procedure TgsPeriodEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
inherited MouseMove(Shift, X, Y);
end;

procedure TgsPeriodEdit.CMMouseLeave(var Message: TMessage);
begin
 if (Text <> '') then
 begin
  DatePeriod.DecodeString(Text);
  DatePeriod.SetKind(3);
 end;
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
  Raz := false;
end;

procedure TgsDataPeriod.SetKind(const pr: Integer);
begin
 case pr of
  1:  Kind:= dpkWeek;
  2:  Kind:= dpkQuarter;
  3:  Kind:= dpkFree;
  end;
end;
procedure TgsDataPeriod.ProcessShortCut(Var Key: char; Text: String);
var
 Year, Month, Day: Word;
 YearN,YearL: Word;
 Next, Last, Today,Result,s: String;
begin
   s := DateToStr(SysUtils.Now);
   FDayWeek := DayOfWeek(StrToDate(s));
 if FDayWeek = 1 then
     FDayWeek := 7
 else
     FDayWeek := FDayWeek - 1;
    DecodeDate(SysUtils.Now, Year, Month, Day);
    YearN := Year;
    YearL := Year;
    Today := IntToStr(Month);
    if StrToInt(Today) + 1 >12 then
    begin
     Next := '1';
     YearN := Year + 1;
    end  else
    Next := IntToStr(StrToInt(Today)+ 1);
    if  StrToInt(Today) - 1 = 0 then
    begin
     Last := '12';
     YearL := Year - 1;
    end
    else
     Last :=  IntToStr(StrToInt(Today) - 1);
     if StrToInt(Next) < 10 then
        Next :='0' + Next;
     if StrToInt(Last) < 10 then
        Last := '0' + Last;
     if StrToInt(Today) < 10 then
        Today := '0' + Today;
   Kj := Kj + 1;

 case Key of
        '.':
        begin
         if (Length(Text) <= 1) or (Length(Text) >= 5) then
          tir := 1
         else
           key := #0;
          Result := Text;
        end;
     #32:
        begin
           Result := Text + DateToStr(SysUtils.Now);
        end;
     'З':                               
        begin
          key := #0;
         if  Day + 1 <= LastData[Month] then
           if Month < 10 then
           Result := IntToStr(Day + 1) + '.' + '0' + IntToStr(Month) + '.' + IntTostr(Year)
           else
            Result :=IntToStr(Day + 1) + '.' + IntTostr(Month) + '.' + IntTostr(Year)
         else
            Result :='1' + '.' + Next + '.' + IntTostr(YearN);
         Kj := 0;
        end;
         'В':
        begin
          key := #0;
        if  Day - 1 > 0 then
           Result := IntToStr(Day -1) + '.' + Today + '.' + IntTostr(Year)
        else
           Result := IntToStr(LastData[StrToInt(Last)]) + '.' + Last + '.' + IntTostr(YearL);
         Kj := 0;
        end;
         'С':
         begin

         Key := #0;
         if (Sp = 'К') and (Kj = 2) then
         begin
          Kind := dpkQuarter;
          case Month + 3 of
           4..6:
            Result := '01.04.' + IntToStr(Year) + '-' + '30.06.' + IntToStr(Year);
           7..9:
           Result := '01.07.' + IntToStr(Year) + '-' + '30.09.' + IntToStr(Year);
           10..12:
          Result := '01.10.' + IntToStr(Year) + '-' + '31.12.' + IntToStr(Year);
           13..15:
            Result := '01.01.' + IntToStr(Year + 1) + '-' + '31.03.' + IntToStr(Year + 1);
          end;
          Kj := 0;
         end;
         if (Sp = 'Г') and (Kj = 2) then
          begin
          Result := IntToStr(Year + 1);
           Kj := 0;
           end else
            if  Kj = 1 then
            begin
            Result := IntToStr(Day) + '.' + Today + '.' + IntToStr(Year);
              Kj := 0;
            end;
         if (Sp = 'М') and (Kj = 2) then
          begin
         Result := Next + '.'  + IntToStr(YearN);
          Kj := 0;
         end;
       if (Sp = 'Н') and (Kj = 2) then
       begin
       Kind := dpkWeek;
         if ((Day +  FDayWeek + 6 )  <  LastData[Month]) and ((Day + 14 - FDayWeek)<=LastData[Month]) then
         Result := IntToStr(Day + 8 - FDayWeek ) + '.'  + Today + '.' + IntToStr(Year)+ '-' + IntToStr(Day + 8 - FDayWeek + 6)  + '.'  + Today  + '.' + IntToStr(Year)
         else
           if  Day + FDayWeek + 6 > LastData[Month] then
              if Day + 8 -  FDayWeek > LastData[Month] then
               Result := IntToStr(Day + 8 -  FDayWeek - LastData[Month]) + '.'  + Next + '.' + IntToStr(YearN)+ '-' + IntToStr(Day + 8 -  FDayWeek - LastData[Month] + 6)  + '.' + Next + '.' + IntToStr(YearN)
              else
              Result := IntToStr(Day + 8 -  FDayWeek ) + '.'  + Next + '.' + IntToStr(YearN)+ '-' + IntToStr(Day + 8 -  FDayWeek - LastData[Month] + 6)  + '.' + Next + '.' + IntToStr(YearN)
           else
           Result := IntToStr(Day  -  FDayWeeK + 8) + '.'  + IntToStr(Month ) + '.' + IntToStr(Year)+ '-' + IntToStr(Day + 8 -  FDayWeek - LastData[Month] + 6)  + '.' + Next + '.' + IntToStr(YearN);
              Kj := 0;
        end;
        end;
        'П':
          begin
            key := #0;
           if (Sp = 'К') and (Kj = 2) then
           begin
            Kind := dpkQuarter;
            Case Month - 3 of
              1..3:
               Result := '01.01.' + IntToStr(Year) + '-' + '31.03.' + IntToStr(Year);
              4..6:
               Result := '01.04.' + IntToStr(Year) + '-' + '30.06.' + IntToStr(Year);
              7..9:
               Result := '01.07.' + IntToStr(Year) + '-' + '30.09.' + IntToStr(Year);
              -2..0:
              Result := '01.10.' + IntToStr(Year - 1) + '-' + '31.12.' + IntToStr(Year - 1);
              end;
              Kj := 0;
            end;
           if (Sp = 'М') and (Kj = 2) then
           begin
             if  Month - 10 <= 0 then
          Result := '0' + IntToStr(Month - 1) + '.'  + IntToStr(Year)
       else
         Result :=IntToStr(Month - 1) + '.'  + IntToStr(Year);
             Kj := 0;
           end else
           if (Sp = 'Г') and (Kj = 2) then
           begin
          Result := IntToStr(Year - 1);
              Kj := 0;
           end;
           if (Sp = 'Н') and (Kj = 2) then
           begin
           Kind := dpkWeek;
             if (Day - FDayWeek - 6 ) > 0 then
           Result := IntToStr(Day - FDayWeek -6 ) + '.'  + Today + '.' + IntToStr(Year)+ '-' + IntToStr(Day - FDayWeek )  + '.'  + Today + '.' + IntToStr(Year)
         else
           if  Day - FDayWeek <= 0 then
             Result := IntToStr(Day  -  FDayWeek + LastData[StrToInt(Last)] - 6) + '.'  + Last + '.' + IntToStr(YearL)+ '-' + IntToStr(Day  -  FDayWeek + LastData[Month - 1] )  + '.' + Last + '.' + IntToStr(YearL)
           else
              Result := IntToStr(Day  -  FDayWeek + LastData[StrToInt(Last)] - 6) + '.' + Last + '.' + IntToStr(Year - 1)+ '-' + IntToStr(Day -  FDayWeeK)  + '.' + Last + '.' + IntToStr(Year);
              Kj := 0;
            end;
               end;
            'Т':
           begin
             key := #0;
            if (Sp = 'К') and (Kj = 2) then
             begin
              Kind := dpkQuarter;
              case Month of
              1..3:
                Result := '01.01.' + IntToStr(Year) + '-' + '31.03.' + IntToStr(Year);
              4..6:
                Result := '01.04.' + IntToStr(Year) + '-' + '30.06.' + IntToStr(Year);
              7..9:
               Result := '01.07.' + IntToStr(Year) + '-' + '30.09.' + IntToStr(Year);
              10..12:
                Result := '01.10.' + IntToStr(Year) + '-' + '31.12.' + IntToStr(Year);
             end;
             Kj := 0;
            end;
            if (Sp = 'М') and (Kj = 2) then
            begin
              Result :=  Today + '.'  + IntToStr(Year);
                Kj := 0;
             end else
             if (Sp = 'Г') and (Kj = 2) then
             begin
             Result := IntToStr(Year );
                 Kj := 0;
             end;
            if (Sp = 'Н') and (Kj = 2) then
            begin
            Kind := dpkWeek;
             if ((Day - FDayWeek + 1) > 0) and ((Day - FDayWeek + 7) < LastData[Month]) then
               Result := IntToStr(Day  - FDayWeek + 1) + '.' + Today + '.' + IntToStr(Year)+ '-' + IntToStr(Day  -  FDayWeek +7 )  + '.'  + Today + '.' + IntToStr(Year)
             else
               if  (Day - FDayWeek + 1) <= 0 then
               Result := IntToStr(Day  - FDayWeek + 1 + LastData[StrToInt(Last)]) + '.' + Last + '.' + IntToStr(Year - 1)+ '-' + IntToStr(Day -  FDayWeek +7 )  + '.'  + Today + '.' + IntToStr(Year)
               else
                if  (Day - FDayWeek + 7) > LastData[Month] then
                Result := IntToStr(Day  - FDayWeek + 1) + '.'  + Today + '.' + IntToStr(Year)+ '-' + IntToStr(Day  -  FDayWeek +1 + 6 - LastData[Month] )  + '.' + Next + '.' + IntToStr(YearN)
                else
               Result := IntToStr(Day  - FDayWeek + 1) + '.'  + Today + '.' + IntToStr(Year)+ '-' + IntToStr(Day  -  FDayWeek +1 + 6  )  + '.' + Next + '.' + IntToStr(YearN);
                 Kj := 0;
            end
            end  else
            begin
            if (Key <> 'М') and (Key <> 'Н') and (Key <> 'Г') and (Key <> 'К') then
            begin
             Kj := 0;
             Sp :='\';
            end 
            else
            if  Kj = 1 then
             Sp := key
            else
             Kj := 0; 
             key := #0;
           end;
        end;
      if Kj > 2 then
      begin
        Kj := 0;
        Sp := '\';
      end;
   if result <> '' then
   begin
   DecodeString(Result);
   Raz := true;
   end;     
end;

procedure TgsDataPeriod.Assign(const ASource: TgsDataPeriod);
begin
  Date := ASource.Date;
  EndDate := ASource.Date;
  FMaxDate := ASource.FMaxDate;
  FMinDate := ASource.FMinDate;
  Kind := ASource.Kind;
end;

function TgsDataPeriod.EncodeString: String;
 var
  Year, Month, Day: Word;
begin
 if Raz = true then
 begin
 Case Kind of
  dpkYear:
  begin
   DecodeDate(Date,Year, Month, Day);
    Result := IntToStr(Year);
   end;
  dpkWeek:
  begin
   Result :=DateToStr(Date) + '-' + DateToStr(EndDate);
  end;
  dpkQuarter:
  begin
   Result :=DateToStr(Date) + '-' + DateToStr(EndDate);
  end;
  dpkMonth:
  begin
   DecodeDate(Date,Year, Month, Day);
   Result := IntToStr(Month) + '.' + IntToStr(Year); 
  end;
  dpkDay:
  begin
   Result := DateToStr(Date);
  end;
  end;
   Raz := false;
   end else
  Result := '';
end;

procedure TgsDataPeriod.DecodeString(const AString: String);
 var
  ss: string;
  Year, Month, Day, I: Word;
begin
  if AString = '' then
     exit;
   if StrPos (PChar(AString), '-') <> nil  then
        begin
        for I := 1 to Length(AString) do
           if AString[I] = '-' then
            begin
            Date := StrToDate(ss);
            ss := '';
            end else
              ss := ss+ AString[I];
            EndDate := StrToDate(ss);
         end
        else
        if StrPos (PChar(AString), '.') = nil then

        begin
          Date := StrToDate('01.01.' + AString);
          EndDate := StrToDate('31.12.' + AString);
          Kind := dpkYear;
        end  else
        if length(AString) <= 7   then
        begin
          Date := StrToDate('01.' + AString);
          DecodeDate(Date,Year, Month, Day);
          EndDate := StrToDate(IntToStr(LastData[Month]) + '.' + AString);
          Kind := dpkMonth;
        end  else
        Begin
          Date := StrToDate(AString);
          EndDate := StrTodate(AString);
          Kind := dpkDay;
        end;
      if (FMinDate <>FMaxDate) and ((FMinDate <> 0) or (FMaxDate <> 0)) then  
         if (Date < FMinDate) or (EndDate > FMaxDate) then
           Raise EgsDatePeriod.Create('превышен диапозон дат');
end;

procedure TgsDataPeriod.SetKindState(const Value: TgsDatePeriodKind);
begin
  Kind := Value;
end;
end.
