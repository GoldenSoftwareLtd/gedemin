unit gsRAChart;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ContNrs,
  StdCtrls, ExtCtrls;

const
  DefHeaderColor = clBtnFace;
  DefFrameColor  = clDkGray;

  scSeconds      = $0001;
  scMinutes      = $0002;
  scHours        = $0004;
  scDays         = $0008;
  scMonthes      = $0010;
  scQuarters     = $0020;
  scYears        = $0040;

  DefScaleKind   = scDays + scMonthes;

type
  TraValue = Variant;
  TraPoint = record
    X: TraValue;
    Y: Integer;
  end;

  TgsRAChart = class;
  TraInterval = class;
  TraIntervals = class;
  TraResources = class;

  TraResource = class(TObject)
  private
    FName: String;
    FID: Integer;
    FIntervals: TraIntervals;
    FSubResources: TraResources;
    FParent: TraResource;
    FSubItems: TStringList;
    FTotals: array of Double;
    FOwner: TraResources;

    procedure SetName(const Value: String);
    procedure SetID(const Value: Integer);
    function GetTotals(Index: Integer): Double;
    function GetTotalsCount: Integer;
    procedure SetOwner(const Value: TraResources);

  public
    constructor Create;
    destructor Destroy; override;

    procedure UpdateTotals(const OldData, NewData: Variant);
    procedure ClearTotals;

    property Name: String read FName write SetName;
    property ID: Integer read FID write SetID;
    property Intervals: TraIntervals read FIntervals;
    property SubResources: TraResources read FSubResources;
    property Parent: TraResource read FParent write FParent;
    property SubItems: TStringList read FSubItems;
    property Totals[Index: Integer]: Double read GetTotals;
    property TotalsCount: Integer read GetTotalsCount;
    property Owner: TraResources read FOwner write SetOwner;
  end;

  TraResources = class(TObjectList)
  private
    FChart: TgsRAChart;

  public
    destructor Destroy; override;

    function AddResource(const AnID: Integer; AParent: TraResource; const AName, ASubItems: String): Integer;
    function AddSubResources(R: TraResource): Integer;
    function RemoveSubResources(R: TraResource): Integer;
    function FindByID(const AnID: Integer): TraResource;

    property Chart: TgsRAChart read FChart write FChart;
  end;

  TraInterval = class(TObject)
  private
    FStartValue, FEndValue: TraValue;
    FID: Integer;
    FComment: String;
    FData: Variant;
    FBorderKind: Integer;
    FFontColor: TColor;
    FColor: TColor;

    procedure SetID(const Value: Integer);

  public
    property StartValue: TraValue read FStartValue write FStartValue;
    property EndValue: TraValue read FEndValue write FEndValue;
    property ID: Integer read FID write SetID;
    property Comment: String read FComment write FComment;
    property Data: Variant read FData write FData;
    property Color: TColor read FColor write FColor;
    property FontColor: TColor read FFontColor write FFontColor;
    property BorderKind: Integer read FBorderKind write FBorderKind;
  end;

  TraIntervals = class(TObjectList)
  private
    FResource: TraResource;

  public
    function AddInterval(const AnID: Integer; const AStartValue, AnEndValue: TraValue;
      const AData: Variant; const AComment: String;
      const AColor, AFontColor: TColor; const ABorderKind: Integer): Integer;
    function FindByValue(const AValue: TraValue): TraInterval;
    function FindByStartValue(const AStartValue: TraValue; out Index: Integer): Boolean;
    function FindByID(const AnID: Integer): TraInterval;
    function FindOverlap(const AStartValue, AnEndValue: TraValue;
      AnExclude: TraInterval): TraInterval;

    property Resource: TraResource read FResource write FResource;
  end;

  TgsRAChart = class(TCustomControl)
  private
    FResources: TraResources;
    FRowHeight, FCellWidth, FTopGap, FLeftGap, FRightGap, FTab: Integer;
    FHeaderRowHeight, FFooterHeight, FInitialFooterHeight: Integer;
    FHeaderHeight, FRowHeaderWidth, FRowTailWidth: Integer;
    FCursor, FDragCursor: TraPoint;
    FFirstVisibleValue, FLastVisibleValue: TraValue;
    FLastVisibleValueSet: Boolean;
    FFirstVisibleRow, FLastVisibleRow, FNonEmptyRowsCount: Integer;
    FMinValue, FMaxValue: TraValue;
    FRowHeadColumnsCapt: array of String;
    FRowHeadColumnsWidth: array of Integer;
    FRowHeadColumnsCount: Integer;
    FRowTailColumnsCapt: array of String;
    FRowTailColumnsWidth: array of Integer;
    FRowTailColumnsCount: Integer;
    FHeaderFont: TFont;
    FHeaderColor: TColor;
    FFrameColor: TColor;
    FSelected: array of TraPoint;
    FTipWnd: THandle;
    FTipBuffer: array[0..1024] of AnsiChar;
    FToolTips: array of String;
    FArDown, FArUp: TBitmap;
    FOnChange: TNotifyEvent;
    FMouseSelectionStart, FMouseSelectionPoint: TPoint;
    FInMouseSelection: Boolean;
    FOldSelectedFrameWidth, FOldSelectedFrameHeight: Cardinal;
    FInKeyboardSelection: Boolean;
    FKeyboardSelectionStartPoint: TraPoint;
    FDragIntervalID: Integer;
    FScaleKind: Integer;

    function GetRowHeadColumnsCapt(Index: Integer): String;
    function GetRowHeadColumnsWidth(Index: Integer): Integer;
    procedure SetRowHeadColumnsCapt(Index: Integer; const Value: String);
    procedure SetRowHeadColumnsCount(const Value: Integer);
    procedure SetRowHeadColumnsWidth(Index: Integer; const Value: Integer);
    function GetRowTailColumnsCapt(Index: Integer): String;
    function GetRowTailColumnsWidth(Index: Integer): Integer;
    procedure SetRowTailColumnsCapt(Index: Integer; const Value: String);
    procedure SetRowTailColumnsCount(const Value: Integer);
    procedure SetRowTailColumnsWidth(Index: Integer; const Value: Integer);

    function FindSelected(const P: TraPoint; out Index: Integer): Boolean; overload;
    function FindSelected(const C: TraValue; const R: Integer): Boolean; overload;
    procedure ToggleCell(const P: TraPoint);
    procedure SelectRegion(const PA, PB: TraPoint);

    procedure ClearToolTips;
    procedure AddToolTip(R: TRect; const ATip: String);
    function MoveInterval(const AnIntervalID: Integer;
      const OldC: TraValue; const OldR: Integer;
      const NewC: TraValue; const NewR: Integer): Boolean;
    function GetResourceID: Integer;
    function GetValue: TraValue;
    procedure SetResourceID(const Value: Integer);
    procedure SetValue(const Value: TraValue);
    function GetFirstVisibleValue: TraValue;
    procedure SetFirstVisibleValue(const Value: TraValue);
    function GetIntervalID: Integer;
    function GetDragResourceID: Integer;
    function GetDragValue: TraValue;
    procedure SetMaxValue(const Value: TraValue);
    procedure SetMinValue(const Value: TraValue);
    function GetSelectedCount: Integer;
    procedure SetCellWidth(const Value: Integer);
    procedure SetRowHeight(const Value: Integer);
    function GetCellColor(const C: TraValue; const R: Integer): TColor;
    function GetDragIntervalID: Integer;
    procedure SetScaleKind(const Value: Integer);

    function IncValue(const AValue: TraValue; const AnIncrement: Integer = 1): TraValue;
    function DiffValue(const A, B: TraValue): Integer;
    function FracValue(const A, B: TraValue): Double;
    function DecValue(const AValue: TraValue; const ADecrement: Integer = 1): TraValue;
    function AdjustValue(const AValue: TraValue): TraValue;

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Paint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    function GetCellDataFromMouse(const X, Y: Integer; out AResource: TraResource;
      out AnInterval: TraInterval): Boolean;
    function GetCellFromMouse(const X, Y: Integer; out C: TraValue; out R: Integer): Boolean;
    procedure ChangeCursorPos(const X: TraValue; const Y: Integer);
    procedure DoChange;

    function GetColumnCaption(const AValue: TraValue; const AGroup: Integer): String;
    function GetGroupsCount: Integer;
    function GetGroupNumber(const AValue: TraValue; const AGroup: Integer): Integer;
    function GetCellDecoration(const AValue: TraValue): TColor;

    procedure WMPaint(var Message: TWMPaint);
      message WM_PAINT;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMEraseBkGnd(var Message: TMessage);
      message WM_ERASEBKGND;
    procedure WMKeyDown(var Message: TWMKey);
      message WM_KEYDOWN;
    procedure WMGetDlgCode(var Message: TMessage);
      message WM_GETDLGCODE;
    procedure WMWindowPosChanged(var Message: TMessage);
      message WM_WINDOWPOSCHANGED;
    procedure WMVScroll(var Msg: TWMVScroll);
      message WM_VSCROLL;
    procedure WMHScroll(var Msg: TWMHScroll);
      message WM_HSCROLL;
    procedure WMSetFocus(var Msg: TWMSetFocus);
      message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure WM_NOTIFY(var Msg: TMessage);
      message WM_NOTIFY;
    procedure WM_MOUSEMOVE(var Msg: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WM_DESTROY(var Msg: TMessage);
      message WM_DESTROY;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure DragDrop(Source: TObject; X, Y: Integer); override;

    function AddRowHead(const ACaption: String; const AWidth: Integer): Integer;
    function AddRowTail(const ACaption: String; const AWidth: Integer): Integer;
    function AddResource(const AnID: Integer; const AName, ASubItems: String): Integer;
    function AddSubResource(const AnID, AParentID: Integer; const AName, ASubItems: String): Integer;
    function AddInterval(const AnID, AResourceID: Integer; const AStartValue, AnEndValue: TraValue;
      const AValue: Variant; const AComment: String;
      const AColor, AFontColor: TColor; const ABorderKind: Integer): Integer;
    procedure ClearResources;
    procedure DeleteResource(const AnID: Integer);
    procedure ClearIntervals(const AResourceID: Integer);
    procedure DeleteInterval(const AResourceID: Integer; const AnID: Integer);
    procedure GetSelected(const Idx: Integer; out AValue: TraValue; out AResourceID: Integer);
    function FindIntervalID(const AResourceID: Integer; const AValue: TraValue): Integer;
    procedure ClearSelected;
    procedure GetIntervalData(const AResourceID: Integer; const AnIntervalID: Integer;
      out AStartValue: TraValue; out AnEndValue: TraValue; out AData: Variant;
      out AComment: String);
    procedure ScrollTo(const AResourceID: Integer; const AValue: TraValue);  

    property Resources: TraResources read FResources;
    property RowHeadColumnsCapt[Index: Integer]: String read GetRowHeadColumnsCapt
      write SetRowHeadColumnsCapt;
    property RowHeadColumnsWidth[Index: Integer]: Integer read GetRowHeadColumnsWidth
      write SetRowHeadColumnsWidth;
    property RowHeadColumnsCount: Integer read FRowHeadColumnsCount write SetRowHeadColumnsCount;
    property RowTailColumnsCapt[Index: Integer]: String read GetRowTailColumnsCapt
      write SetRowTailColumnsCapt;
    property RowTailColumnsWidth[Index: Integer]: Integer read GetRowTailColumnsWidth
      write SetRowTailColumnsWidth;
    property RowTailColumnsCount: Integer read FRowTailColumnsCount write SetRowTailColumnsCount;
    property MinValue: TraValue read FMinValue write SetMinValue;
    property MaxValue: TraValue read FMaxValue write SetMaxValue;
    property Value: TraValue read GetValue write SetValue;
    property ResourceID: Integer read GetResourceID write SetResourceID;
    property IntervalID: Integer read GetIntervalID;
    property DragValue: TraValue read GetDragValue;
    property DragResourceID: Integer read GetDragResourceID;
    property DragIntervalID: Integer read GetDragIntervalID;
    property FirstVisibleValue: TraValue read GetFirstVisibleValue write SetFirstVisibleValue;
    property SelectedCount: Integer read GetSelectedCount;
    property RowHeight: Integer read FRowHeight write SetRowHeight;
    property CellWidth: Integer read FCellWidth write SetCellWidth;
    property ScaleKind: Integer read FScaleKind write SetScaleKind;

  published
    property Align;
    property TabStop;
    property Color;
    property PopupMenu;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;

implementation

uses
  Forms, Math, gsThemeManager, gsTooltip;

const
  SPI_GETFOCUSBORDERHEIGHT = $2010;
  SPI_SETFOCUSBORDERHEIGHT = $2011;
  SPI_GETFOCUSBORDERWIDTH  = $200E;
  SPI_SETFOCUSBORDERWIDTH  = $200F;

procedure Register;
begin
  RegisterComponents('xTool-2', [TgsRAChart]);
end;

function RAPoint(const X: TraValue; const Y: Integer): TraPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

function TgsRAChart.IncValue(const AValue: TraValue;
  const AnIncrement: Integer = 1): TraValue;
var
  DT: TDateTime;
begin
  if (scDays and FScaleKind) <> 0 then
    Result := AValue + AnIncrement
  else begin
    DT := AValue;
    Result := IncMonth(DT, AnIncrement);
  end;
end;

function TgsRAChart.DiffValue(const A, B: TraValue): Integer;
var
  DT1, DT2: TDateTime;
  Y1, Y2, M1, M2, D1, D2: Word;
begin
  if (scDays and FScaleKind) <> 0 then
    Result := Trunc(A) - Trunc(B)
  else begin
    DT1 := A;
    DT2 := B;
    DecodeDate(DT1, Y1, M1, D1);
    DecodeDate(DT2, Y2, M2, D2);
    Result := (Y1 - Y2) * 12 + M1 - M2;
  end;
end;

function TgsRAChart.FracValue(const A, B: TraValue): Double;
var
  DT1, DT2, CM, NM: TDateTime;
  Y1, Y2, M1, M2, D1, D2: Word;
begin
  if (scDays and FScaleKind) <> 0 then
    Result := Double(A) - Double(B)
  else begin
    DT1 := A;
    DT2 := B;
    DecodeDate(DT1, Y1, M1, D1);
    DecodeDate(DT2, Y2, M2, D2);

    CM := EncodeDate(Y2, M2, 1);
    NM := IncMonth(CM, 1);

    Result := (Y1 - Y2) * 12 + M1 - M2 +
      (B - CM) / (NM - CM);
  end;
end;

function Max(const A, B: TraValue): TraValue;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

function Min(const A, B: TraValue): TraValue;
begin
  if A < B then
    Result := A
  else
    Result := B;
end;

function TgsRAChart.DecValue(const AValue: TraValue;
  const ADecrement: Integer = 1): TraValue;
var
  DT: TDateTime;
begin
  if (scDays and FScaleKind) <> 0 then
    Result := AValue - ADecrement
  else begin
    DT := AValue;
    Result := IncMonth(DT, - ADecrement);
  end;
end;

function TgsRAChart.AddInterval(const AnID, AResourceID: Integer;
  const AStartValue, AnEndValue: TraValue; const AValue: Variant;
  const AComment: String; const AColor, AFontColor: TColor;
  const ABorderKind: Integer): Integer;
var
  R: TraResource;
begin
  R := FResources.FindByID(AResourceID);

  if R = nil then
    raise Exception.Create('Invalid resource ID');

  Result := R.Intervals.AddInterval(AnID, AStartValue, AnEndValue, AValue,
    AComment, AColor, AFontColor, ABorderKind);

  R.UpdateTotals(Null, AValue);  
end;

function TgsRAChart.AddResource(const AnID: Integer; const AName,
  ASubItems: String): Integer;
begin
  Result := FResources.AddResource(AnID, nil, AName, ASubItems);
end;

function TgsRAChart.AddRowHead(const ACaption: String;
  const AWidth: Integer): Integer;
begin
  Result := RowHeadColumnsCount;
  RowHeadColumnsCount := RowHeadColumnsCount + 1;
  RowHeadColumnsCapt[Result] := ACaption;
  RowHeadColumnsWidth[Result] := AWidth;
end;

function TgsRAChart.AddRowTail(const ACaption: String;
  const AWidth: Integer): Integer;
begin
  Result := RowTailColumnsCount;
  RowTailColumnsCount := RowTailColumnsCount + 1;
  RowTailColumnsCapt[Result] := ACaption;
  RowTailColumnsWidth[Result] := AWidth;
end;

function TgsRAChart.AddSubResource(const AnID, AParentID: Integer;
  const AName, ASubItems: String): Integer;
var
  P: TraResource;
begin
  if FResources.FindByID(AnID) <> nil then
    raise Exception.Create('Duplicate ID');

  P := FResources.FindByID(AParentID);

  if P = nil then
    raise Exception.Create('Invalid parent ID');

  Result := P.SubResources.AddResource(AnID, P, AName, ASubItems);
end;

procedure TgsRAChart.AddToolTip(R: TRect; const ATip: String);
var
  TI: TTOOLINFO;
begin
  if FTipWnd <> 0 then
  begin
    SetLength(FToolTips, Length(FToolTips) + 1);
    FToolTips[High(FToolTips)] := ATip;

    FillChar(TI, SizeOf(TI), 0);
    TI.cbSize := SizeOf(TI);
    TI.uFlags := {TTF_CENTERTIP or TTF_TRANSPARENT or} TTF_SUBCLASS;
    TI.hwnd := Handle;
    TI.uId := High(FToolTips);
    TI.lpszText := Pointer(Longint(-1));
    TI.rect := R;
    SendMessage(FTipWnd, TTM_ADDTOOL, 0, LongInt(@TI));
  end;
end;

procedure TgsRAChart.ClearToolTips;
var
  I: Integer;
  TI: TTOOLINFO;
begin
  if FTipWnd <> 0 then
  begin
    for I := Low(FToolTips) to High(FToolTips) do
    begin
      FillChar(TI, SizeOf(TI), 0);
      TI.cbSize := SizeOf(TI);
      TI.hwnd := Handle;
      TI.uId := I;
      SendMessage(FTipWnd, TTM_DELTOOL, 0, LongInt(@TI));
    end;
    SetLength(FToolTips, 0);
  end;
end;

constructor TgsRAChart.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FResources := TraResources.Create(True);
  FResources.Chart := Self;

  FRowHeight := 29;
  FCellWidth := 29;
  FHeaderRowHeight := 20;
  FInitialFooterHeight := 0;
  FTopGap := 4;
  FLeftGap := 4;
  FRightGap := 4;
  FTab := 24;

  FScaleKind := DefScaleKind;
  FMinValue := AdjustValue(Date - 365);
  FMaxValue := AdjustValue(Date + 365);
  FCursor.X := AdjustValue(Date);
  FCursor.Y := 10;
  FFirstVisibleValue := AdjustValue(Date - 10);
  FLastVisibleValue := -1;
  FLastVisibleValueSet := False;
  FDragIntervalID := -1;

  FHeaderFont := TFont.Create;
  FHeaderColor := DefHeaderColor;
  FFrameColor := DefFrameColor;

  TabStop := True;
  DoubleBuffered := True;

  FArDown := TBitmap.Create;
  FArDown.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_DNARROW));
  FArUp := TBitmap.Create;
  FArUp.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_UPARROW));

  Width := 240;
  Height := 160;
end;

procedure TgsRAChart.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_TABSTOP or WS_VSCROLL or WS_HSCROLL;
  Params.WindowClass.Style := CS_DBLCLKS;
end;

procedure TgsRAChart.CreateWnd;
begin
  inherited;

  FTipWnd := CreateWindow(TOOLTIPS_CLASS, nil,
    TTS_NOPREFIX or TTS_BALLOON or TTS_ALWAYSTIP,
    0, 0, 0, 0, Handle, 0, HInstance, nil);
  SetWindowPos(FTipWnd, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);

  SystemParametersInfo(SPI_GETFOCUSBORDERHEIGHT, 0, @FOldSelectedFrameHeight, 0);
  SystemParametersInfo(SPI_GETFOCUSBORDERWIDTH, 0, @FOldSelectedFrameWidth, 0);
end;

destructor TgsRAChart.Destroy;
begin
  FResources.Free;
  FHeaderFont.Free;
  FArDown.Free;
  FArUp.Free;
  inherited Destroy;
end;

{ TraResource }

procedure TraResource.ClearTotals;
begin
  SetLength(FTotals, 0);
end;

constructor TraResource.Create;
begin
  FIntervals := TraIntervals.Create(True);
  FIntervals.Resource := Self;
  FSubResources := TraResources.Create(True);
  FSubItems := TStringList.Create;
end;

destructor TraResource.Destroy;
begin
  FIntervals.Free;
  FSubResources.Free;
  FSubItems.Free;
  inherited;
end;

function TraResource.GetTotals(Index: Integer): Double;
begin
  if (Index < 0) or (Index > High(FTotals)) then
    raise Exception.Create('Index is out of bounds');

  Result := FTotals[Index];
end;

function TraResource.GetTotalsCount: Integer;
begin
  Result := High(FTotals) + 1;
end;

procedure TraResource.SetID(const Value: Integer);
begin
  if Value < 0 then
    raise Exception.Create('Invalid ID');
  FID := Value;
end;

procedure TraResource.SetName(const Value: String);
begin
  FName := Value;
end;

procedure TraResource.SetOwner(const Value: TraResources);
begin
  FOwner := Value;
  if FOwner is TraResources then
    FSubResources.Chart := (FOwner as TraResources).Chart;
end;

procedure TraResource.UpdateTotals(const OldData, NewData: Variant);
var
  I: Integer;
begin
  if (not VarIsNull(OldData)) and (not VarIsEmpty(OldData)) and VarIsArray(OldData) then
  begin
    if High(FTotals) <> (VarArrayHighBound(OldData, 1) - VarArrayLowBound(OldData, 1) - 1) then
      raise Exception.Create('Invalid data array size');

    for I := Low(FTotals) to High(FTotals) do
    begin
      if VarType(OldData[VarArrayLowBound(OldData, 1) + 1 + I]) in [varInteger, varDouble] then
        FTotals[I] := FTotals[I] - OldData[VarArrayLowBound(OldData, 1) + 1 + I];
    end;
  end;

  if (not VarIsNull(NewData)) and (not VarIsEmpty(NewData)) and VarIsArray(NewData) then
  begin
    if High(FTotals) < Low(FTotals) then
      SetLength(FTotals, VarArrayHighBound(NewData, 1) - VarArrayLowBound(NewData, 1));

    for I := Low(FTotals) to High(FTotals) do
    begin
      if VarType(NewData[VarArrayLowBound(NewData, 1) + 1 + I]) in [varInteger, varDouble] then
        FTotals[I] := FTotals[I] + NewData[VarArrayLowBound(NewData, 1) + 1 + I];
    end;
  end;
end;

{ TraInterval }

procedure TraInterval.SetID(const Value: Integer);
begin
  if Value < 0 then
    raise Exception.Create('Invalid ID');
  FID := Value;
end;

{ TraResources }

function TraResources.AddResource(const AnID: Integer; AParent: TraResource;
  const AName, ASubItems: String): Integer;
var
  R: TraResource;
begin
  if FindByID(AnID) <> nil then
    raise Exception.Create('Duplicate ID');

  R := TraResource.Create;
  try
    R.Owner := Self;
    R.ID := AnID;
    R.Name := AName;
    R.Parent := AParent;
    if ASubItems > '' then
      R.SubItems.CommaText := ASubItems
    else
      R.SubItems.Clear;  
    Result := Add(R);
  except
    R.Free;
    raise;
  end;
end;

function TraResources.AddSubResources(R: TraResource): Integer;
var
  I, J: Integer;
begin
  I := IndexOf(R);

  if I < 0 then
    raise Exception.Create('Invalid resource');

  if (I < Count - 1) and ((Items[I + 1] as TraResource).Parent = R) then
    raise Exception.Create('Subresources have been added');

  for J := 0 to R.SubResources.Count - 1 do
    Insert(I + J + 1, R.SubResources[J]);

  Result := R.SubResources.Count;
end;

destructor TraResources.Destroy;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
  begin
    if (Items[I] as TraResource).Parent <> nil then
      Extract(Items[I]);
  end;

  inherited;
end;

function TraResources.FindByID(const AnID: Integer): TraResource;
var
  I: Integer;
begin
  Result := nil;
  I := 0;
  while (Result = nil) and (I < Count) do
  begin
    if (Items[I] as TraResource).ID = AnID then
      Result := Items[I] as TraResource
    else
      Result := (Items[I] as TraResource).SubResources.FindByID(AnID);
    Inc(I);
  end;
end;

function TraResources.RemoveSubResources(R: TraResource): Integer;
var
  I, J: Integer;
begin
  I := IndexOf(R);

  if I < 0 then
    raise Exception.Create('Invalid resource');

  Result := 0;
  J := Count - 1;
  while J >= I + 1 do
  begin
    if (Items[J] as TraResource).Parent = R then
    begin
      Result := Result + RemoveSubResources(Items[J] as TraResource) + 1;
      Extract(Items[J]);
      J := Count - 1;
    end else
      Dec(J);
  end;
end;

function TgsRAChart.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  FFirstVisibleRow := FFirstVisibleRow + 1;
  if FFirstVisibleRow > FResources.Count - FNonEmptyRowsCount then
    FFirstVisibleRow := FResources.Count - FNonEmptyRowsCount;
  if FFirstVisibleRow < 0 then
    FFirstVisibleRow := 0;
  Invalidate;
  Result := True;
end;

function TgsRAChart.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  FFirstVisibleRow := FFirstVisibleRow - 1;
  if FFirstVisibleRow < 0 then
   FFirstVisibleRow := 0;
  Invalidate;
  Result := True;
end;

procedure TgsRAChart.DragDrop(Source: TObject; X, Y: Integer);
var
  C: TraValue;
  R: Integer;
begin
  Assert(FDragIntervalID > -1);

  if (Source = Self) and GetCellFromMouse(X, Y, C, R)
    and (R < FResources.Count) then
  begin
    if MoveInterval(FDragIntervalID, FCursor.X, FCursor.Y, C, R) then
    begin
      ChangeCursorPos(C, R);
      SetLength(FSelected, 0);
      DoChange;
      Invalidate;
    end;
  end;
  
  inherited;
end;

procedure TgsRAChart.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  C: TraValue;
  R: Integer;
begin
  inherited;
  Accept := GetCellFromMouse(X, Y, C, R) and (R < FResources.Count);
end;

function TgsRAChart.FindSelected(const P: TraPoint; out Index: Integer): Boolean;
var
  L, H, I: Integer;
begin
  Result := False;
  L := Low(FSelected);
  H := High(FSelected);
  while L <= H do
  begin
    I := (L + H) shr 1;
    if (FSelected[I].X < P.X) or ((FSelected[I].X = P.X) and (FSelected[I].Y < P.Y)) then
    begin
      L := I + 1
    end else
    begin
      H := I - 1;
      if (FSelected[I].X = P.X) and (FSelected[I].Y = P.Y) then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;
  Index := L;
end;

function TgsRAChart.GetCellDataFromMouse(const X, Y: Integer;
  out AResource: TraResource; out AnInterval: TraInterval): Boolean;
var
  C: TraValue;
  R, I: Integer;
  ExactValue: Double;
begin
  AResource := nil;
  AnInterval := nil;

  if GetCellFromMouse(X, Y, C, R) then
  begin
    if R < FResources.Count then
    begin
      AResource := FResources[R] as TraResource;

      ExactValue := FFirstVisibleValue + (X - FRowHeaderWidth) / FCellWidth;

      for I := 0 to AResource.Intervals.Count - 1 do
      begin
        if ((AResource.Intervals[I] as TraInterval).StartValue <= ExactValue)
          and ((AResource.Intervals[I] as TraInterval).EndValue > ExactValue) then
        begin
          AnInterval := AResource.Intervals[I] as TraInterval;
          break;
        end;
      end;
    end;
  end;

  Result := (AResource <> nil) and (AnInterval <> nil);
end;

function TgsRAChart.GetCellFromMouse(const X, Y: Integer;
  out C: TraValue; out R: Integer): Boolean;
begin
  if (X >= FRowHeaderWidth) and (X <= ClientWidth - FRowTailWidth - 1)
    and (Y >= FHeaderHeight) and (Y <= ClientHeight - FFooterHeight - 1) then
  begin
    C := IncValue(FFirstVisibleValue, (X - FRowHeaderWidth) div FCellWidth);
    R := FFirstVisibleRow + (Y - FHeaderHeight) div FRowHeight;
    Result := (C >= FMinValue) and (C <= FMaxValue) and (R >= 0) and (R < FResources.Count);
  end else
    Result := False;
end;

function TgsRAChart.GetColumnCaption(const AValue: TraValue; const AGroup: Integer): String;
begin
  case AGroup of
    0:
      if (scDays and FScaleKind) <> 0 then
        Result := FormatDateTime('dd', AValue)
      else
        Result := FormatDateTime('mmmm', AValue);
    1:
      if (scDays and FScaleKind) <> 0 then
        Result := FormatDateTime('mmmm yyyy', AValue)
      else
        Result := FormatDateTime('yyyy', AValue);
  end;
end;

function TgsRAChart.GetResourceID: Integer;
begin
  if (FCursor.Y >= 0) and (FCursor.Y < FResources.Count) then
    Result := (FResources[FCursor.Y] as TraResource).ID
  else
    Result := -1;
end;

function TgsRAChart.GetValue: TraValue;
begin
  Result := FCursor.X;
end;

function TgsRAChart.GetFirstVisibleValue: TraValue;
begin
  Result := FFirstVisibleValue;
end;

function TgsRAChart.GetGroupNumber(const AValue: TraValue; const AGroup: Integer): Integer;
var
  Y, M, D: Word;
begin
  if (scDays and FScaleKind) <> 0 then
    case AGroup of
      1:
      begin
        DecodeDate(AValue, Y, M, D);
        Result := Y * 12 + M;
      end;
    else
      Result := Trunc(AValue);
    end
  else
    case AGroup of
      1:
      begin
        DecodeDate(AValue, Y, M, D);
        Result := Y;
      end;
    else
      DecodeDate(AValue, Y, M, D);
      Result := Y * 12 + M;
    end
end;

function TgsRAChart.GetGroupsCount: Integer;
begin
  Result := 2;
end;

function TgsRAChart.GetRowHeadColumnsCapt(Index: Integer): String;
begin
  Result := FRowHeadColumnsCapt[Index];
end;

function TgsRAChart.GetRowHeadColumnsWidth(Index: Integer): Integer;
begin
  Result := FRowHeadColumnsWidth[Index];
end;

function TgsRAChart.GetRowTailColumnsCapt(Index: Integer): String;
begin
  Result := FRowTailColumnsCapt[Index];
end;

function TgsRAChart.GetRowTailColumnsWidth(Index: Integer): Integer;
begin
  Result := FRowTailColumnsWidth[Index];
end;

procedure TgsRAChart.KeyDown(var Key: Word; Shift: TShiftState);
var
  FOldCursor: TraPoint;
  I, J, R: Integer;
  Dt: TDateTime;
  Dbl: Double;
  V: TraValue;
begin
  inherited;

  FOldCursor := FCursor;

  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END, VK_PRIOR, VK_NEXT] then
  begin
    if ssShift in Shift then
    begin
      if not FInKeyboardSelection then
      begin
        FInKeyboardSelection := True;
        FKeyboardSelectionStartPoint := FCursor;
      end;
    end else
    begin
      FInKeyboardSelection := False;
      SetLength(FSelected, 0);
    end;
  end;

  case Key of
    VK_LEFT: ChangeCursorPos(DecValue(FCursor.X), FCursor.Y);
    VK_RIGHT: ChangeCursorPos(IncValue(FCursor.X), FCursor.Y);
    VK_DOWN: ChangeCursorPos(FCursor.X, FCursor.Y + 1);
    VK_UP: ChangeCursorPos(FCursor.X, FCursor.Y - 1);
    VK_HOME:
    begin
      if ssCtrl in Shift then
        ChangeCursorPos(FMinValue, FCursor.Y)
      else
        ChangeCursorPos(FFirstVisibleValue, FCursor.Y);
    end;
    VK_END:
    begin
      if ssCtrl in Shift then
        ChangeCursorPos(FMaxValue, FCursor.Y)
      else if FLastVisibleValueSet then
        ChangeCursorPos(FLastVisibleValue, FCursor.Y);
    end;
    VK_NEXT:
    begin
      if ssCtrl in Shift then
        ChangeCursorPos(FCursor.X, FResources.Count - 1)
      else begin
        FFirstVisibleRow := FFirstVisibleRow + FNonEmptyRowsCount;
        if FFirstVisibleRow > FResources.Count - FNonEmptyRowsCount then
          FFirstVisibleRow := FResources.Count - FNonEmptyRowsCount;
        if FFirstVisibleRow < 0 then
          FFirstVisibleRow := 0;
        FCursor.Y := FCursor.Y + FNonEmptyRowsCount;
        if FCursor.Y >= FResources.Count then
          FCursor.Y := FResources.Count - 1;
      end;
    end;
    VK_PRIOR:
    begin
      if ssCtrl in Shift then
        ChangeCursorPos(FCursor.X, 0)
      else begin
        FFirstVisibleRow := FFirstVisibleRow - FNonEmptyRowsCount;
        if FFirstVisibleRow < 0 then
          FFirstVisibleRow := 0;
        FCursor.Y := FCursor.Y - FNonEmptyRowsCount;
        if FCursor.Y < 0 then
          FCursor.Y := 0;
      end;
    end;
    VK_ESCAPE:
    begin
      if FInMouseSelection then
      begin
        FInMouseSelection := False;
        DoChange;
        Invalidate;
      end;
    end;
  end;

  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END, VK_PRIOR, VK_NEXT] then
  begin
    if FInKeyboardSelection and (ssShift in Shift) and
      ((FOldCursor.X <> FCursor.X) or (FOldCursor.Y <> FCursor.Y)) then
    begin
      SetLength(FSelected, 0);
      SelectRegion(FKeyboardSelectionStartPoint, FCursor);
    end;
    DoChange;
    Invalidate;
  end;

  if (Key = Word('T')) and (Shift = [ssCtrl]) then
  begin
    if (Date >= FMinValue) and (Date <= FMaxValue) then
    begin
      SetLength(FSelected, 0);
      FFirstVisibleValue := AdjustValue(Date);
      FCursor.X := AdjustValue(Date);
      DoChange;
      Invalidate;
    end;
  end;

  if ((Key = Word('L')) or (Key = Word('R'))) and (Shift = [ssCtrl])
    and FLastVisibleValueSet then
  begin
    R := -1;

    if Key = Word('L') then
      V := FMaxValue
    else
      V := FMinValue;

    for I := 0 to FResources.Count - 1 do
    begin
      for J := 0 to (FResources[I] as TraResource).Intervals.Count - 1 do
      begin
        if Key = Word('L') then
        begin
          if V > ((FResources[I] as TraResource).Intervals[J] as TraInterval).StartValue then
          begin
            V := ((FResources[I] as TraResource).Intervals[J] as TraInterval).StartValue;
            R := I;
          end;
        end else
        begin
          if V < ((FResources[I] as TraResource).Intervals[J] as TraInterval).EndValue then
          begin
            V := ((FResources[I] as TraResource).Intervals[J] as TraInterval).EndValue;
            R := I;
          end;
        end;
      end;
    end;

    if R > -1 then
    begin
      if Key <> Word('L') then
      begin
        V := DecValue(V, DiffValue(FLastVisibleValue, FFirstVisibleValue));
        if V < FMinValue then
          V := FMinValue;
      end;

      if V > FMaxValue then
        V := FMaxValue;

      SetLength(FSelected, 0);
      if VarType(FFirstVisibleValue) = varDate then
      begin
        Dt := Trunc(V);
        FFirstVisibleValue := Dt;
      end else
      begin
        Dbl := Trunc(V);
        FFirstVisibleValue := Dbl;
      end;
      FCursor.X := FFirstVisibleValue;
      FFirstVisibleRow := R;
      FCursor.Y := R;
      DoChange;
      Invalidate;
    end;
  end;
end;

procedure TgsRAChart.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  OldCursor: TraPoint;
  C: TraValue;
  R, K: Integer;
  Resource, ResourceNext: TraResource;
  Interval: TraInterval;
begin
  inherited;

  if ((ssLeft in Shift) or (ssRight in Shift)) and GetCellFromMouse(X, Y, C, R) then
  begin
    OldCursor := FCursor;

    FCursor.X := C;
    FCursor.Y := R;

    if Shift = [ssCtrl, ssLeft] then
    begin
      if SelectedCount = 0 then
        ToggleCell(OldCursor);
      ToggleCell(FCursor);
    end
    else if Shift = [ssShift, ssLeft] then
      SelectRegion(OldCursor, FCursor)
    else begin
      if (FCursor.X <> OldCursor.X) or (FCursor.Y <> OldCursor.Y) then
      begin
        if Shift = [ssLeft] then
          SetLength(FSelected, 0);
      end;

      if Shift = [ssLeft] then
      begin
        if GetCellDataFromMouse(X, Y, Resource, Interval) then
        begin
          FDragCursor := FCursor;
          FDragIntervalID := Interval.ID;
          BeginDrag(False, 4);
        end else
        begin
          FDragIntervalID := -1;
          FMouseSelectionStart := Point(X, Y);
          FMouseSelectionPoint := FMouseSelectionStart;
          FInMouseSelection := True;
        end;
      end;
    end;

    Invalidate;
    DoChange;
  end
  else if (ssLeft in Shift)
    and
    (
      (X > FRowHeaderWidth - FRightGap - FArDown.Width)
      and (X < FRowHeaderWidth)
      and (Y > FHeaderHeight)
      and (Y < ClientHeight - FFooterHeight - 1)
    ) then
  begin
    R := FFirstVisibleRow + (Y - FHeaderHeight) div FRowHeight;
    if R < FResources.Count then
    begin
      Resource := FResources[R] as TraResource;

      if R < FResources.Count - 1 then
        ResourceNext := FResources[R + 1] as TraResource
      else
        ResourceNext := nil;

      if Resource.SubResources.Count > 0 then
      begin
        if (ResourceNext <> nil) and (ResourceNext.Parent = Resource) then
        begin
          K := FResources.RemoveSubresources(Resource);
          if FCursor.Y > R + K then
            FCursor.Y := FCursor.Y - K
          else if (FCursor.Y > R) and (FCursor.Y <= R + K) then
            FCursor.Y := R;
          Invalidate;
          DoChange;
        end
        else if (ResourceNext = nil) or (ResourceNext.Parent <> Resource) then
        begin
          if FCursor.Y > R then
            FCursor.Y := FCursor.Y + FResources.AddSubresources(Resource)
          else
            FResources.AddSubresources(Resource);
          Invalidate;
          DoChange;
        end;
      end;
    end;
  end;

  if Visible and CanFocus and TabStop and not (csDesigning in ComponentState) then
    SetFocus;
end;

procedure TgsRAChart.MouseMove(Shift: TShiftState; X, Y: Integer);

  procedure DFR;
  begin
    if (FMouseSelectionStart.X <> FMouseSelectionPoint.X)
      or (FMouseSelectionStart.Y <> FMouseSelectionPoint.Y) then
    begin
      Canvas.DrawFocusRect(Rect(Min(FMouseSelectionStart.X, FMouseSelectionPoint.X),
        Min(FMouseSelectionStart.Y, FMouseSelectionPoint.Y),
        Max(FMouseSelectionStart.X, FMouseSelectionPoint.X),
        Max(FMouseSelectionStart.Y, FMouseSelectionPoint.Y)));
    end;
  end;

begin
  inherited;

  if FInMouseSelection then
  begin
    DFR;

    if (X > FRowHeaderWidth) and (X < ClientWidth - FRowTailWidth - 1) then
      FMouseSelectionPoint.X := Min(Max(X, FRowHeaderWidth + 1), ClientWidth - FRowTailWidth - 1);

    if (Y > FHeaderHeight) and (Y < ClientHeight - FFooterHeight - 1) then
      FMouseSelectionPoint.Y := Min(Max(Y, FHeaderHeight + 1), ClientHeight - FFooterHeight - 1);

    DFR;
  end;
end;

function TgsRAChart.MoveInterval(const AnIntervalID: Integer;
  const OldC: TraValue; const OldR: Integer;
  const NewC: TraValue; const NewR: Integer): Boolean;
var
  RsOld, RsNew: TraResource;
  IntOld: TraInterval;
begin
  Result := False;

  if (OldR >= 0) and (OldR < FResources.Count) then
    RsOld := FResources[OldR] as TraResource
  else
    RsOld := nil;

  if (NewR >= 0) and (NewR < FResources.Count) then
    RsNew := FResources[NewR] as TraResource
  else
    RsNew := nil;

  if (RsOld = nil) or (RsNew = nil)  then
    exit;

  IntOld := RsOld.Intervals.FindByID(AnIntervalID);

  if IntOld = nil then
    exit;

  if (RsOld = RsNew) and (OldC <> NewC) then
  begin
    if RsNew.Intervals.FindOverlap(IntOld.StartValue + NewC - OldC,
      IntOld.EndValue + NewC - OldC, IntOld) <> nil then
    begin
      exit;
    end;

    IntOld.StartValue := IntOld.StartValue + NewC - OldC;
    IntOld.EndValue := IntOld.EndValue + NewC - OldC;
    Result := True;
    exit;
  end;

  if RsOld <> RsNew then
  begin
    if RsNew.Intervals.FindOverlap(IntOld.StartValue + NewC - OldC,
      IntOld.EndValue + NewC - OldC, nil) <> nil then
    begin
      exit;
    end;

    RsOld.Intervals.Extract(IntOld);
    RsNew.Intervals.Add(IntOld);

    RsOld.UpdateTotals(IntOld.Data, Null);
    RsNew.UpdateTotals(Null, IntOld.Data);

    IntOld.StartValue := IntOld.StartValue + NewC - OldC;
    IntOld.EndValue := IntOld.EndValue + NewC - OldC;
    Result := True;
    exit;
  end;
end;

procedure TgsRAChart.Paint;
const
  MaxColTotals = 2;
var
  R, RSave, IntervalRect, VisibleRect, CellRect, TextRect, TotalRect: TRect;
  VisibleRgn, CellRgn: HRGN;
  I, J, Rw, Indent: Integer;
  D: TraValue;
  Sz: TSize;
  S, DataS, TotalS: String;
  Rs, RsNext, RsTemp: TraResource;
  LVRSet: Boolean;
  SI: TScrollInfo;
  Interval: TraInterval;
  Pts: array of TPoint;
  PtsCount, HalfHeight, AngleConst: Integer;
  ColTotals: array[0..MaxColTotals - 1] of Double;
  V: Variant;
begin
  FRowHeaderWidth := 0;
  for I := 0 to FRowHeadColumnsCount - 1 do
    Inc(FRowHeaderWidth, FRowHeadColumnsWidth[I]);

  FRowTailWidth := 0;
  for I := 0 to FRowTailColumnsCount - 1 do
    Inc(FRowTailWidth, FRowTailColumnsWidth[I]);

  FRowHeaderWidth := FRowHeaderWidth +
    (ClientWidth - FRowHeaderWidth - FRowTailWidth - 1) mod FCellWidth + 1;
  FHeaderHeight := FHeaderRowHeight * 2;
  FFooterHeight := FInitialFooterHeight +
    ((ClientHeight - FHeaderHeight - FInitialFooterHeight - 1) mod FRowHeight) - 1;

  Canvas.Brush.Color := FHeaderColor;
  Canvas.Brush.Style := bsSolid;
  Canvas.Pen.Color := FFrameColor;
  Canvas.Pen.Style := psSolid;
  Canvas.Font.Color := clBlack;

  R := Rect(0, 0, 0, 0 + FHeaderHeight);

  for I := 0 to FRowHeadColumnsCount - 1 do
  begin
    R.Left := R.Right;
    R.Right := R.Left + FRowHeadColumnsWidth[I];
    if I = FRowHeadColumnsCount - 1 then
      R.Right := FRowHeaderWidth;
    Sz := Canvas.TextExtent(FRowHeadColumnsCapt[I]);
    Canvas.TextRect(R, R.Left + (FRowHeadColumnsWidth[I] - Sz.CX) div 2,
      R.Top + (FHeaderHeight - Sz.CY) div 2, FRowHeadColumnsCapt[I]);
    Canvas.PolyLine([Point(R.Right - 1, R.Top), Point(R.Right - 1, R.Bottom)]);
  end;

  RSave := R;

  R.Left := R.Right;
  R.Bottom := 0 + FHeaderRowHeight;
  D := FFirstVisibleValue;
  while R.Right <= ClientWidth - FRowTailWidth do
  begin
    while GetGroupNumber(D, 1) = GetGroupNumber(DecValue(D), 1) do
    begin
      R.Right := R.Right + FCellWidth;
      D := IncValue(D);
    end;

    if R.Right > ClientWidth - FRowTailWidth then
      R.Right := ClientWidth - FRowTailWidth;

    S := GetColumnCaption(DecValue(D), 1);
    Sz := Canvas.TextExtent(S);
    if Sz.CX >= R.Right - R.Left then
      S := '';
    Canvas.TextRect(R, R.Left + (R.Right - R.Left - Sz.CX) div 2,
      R.Top + (FHeaderRowHeight - Sz.CY) div 2, S);
    Canvas.PolyLine([Point(R.Right - 1, R.Top), Point(R.Right - 1, R.Bottom)]);

    R.Left := R.Right;
    R.Right := R.Right + FCellWidth;
    D := IncValue(D);
  end;

  Canvas.PolyLine([Point(RSave.Right, R.Bottom - 1), Point(R.Right - 1, R.Bottom - 1)]);

  R := RSave;
  R.Top := 0 + FHeaderRowHeight;
  D := FFirstVisibleValue;
  while R.Right <= ClientWidth - FRowTailWidth - FCellWidth do
  begin
    R.Left := R.Right;
    R.Right := R.Left + FCellWidth;
    S := GetColumnCaption(D, 0);
    Sz := Canvas.TextExtent(S);
    Canvas.TextRect(R, R.Left + (FCellWidth - Sz.CX) div 2,
      R.Top + (FHeaderRowHeight - Sz.CY) div 2, S);
    Canvas.PolyLine([Point(R.Right - 1, R.Top), Point(R.Right - 1, R.Bottom)]);
    D := IncValue(D);
  end;

  FLastVisibleValue := DecValue(D);
  FLastVisibleValueSet := True;

  R.Top := 0;
  for I := 0 to FRowTailColumnsCount - 1 do
  begin
    R.Left := R.Right;
    R.Right := R.Left + FRowTailColumnsWidth[I];
    Sz := Canvas.TextExtent(FRowTailColumnsCapt[I]);
    Canvas.TextRect(R, R.Left + (FRowTailColumnsWidth[I] - Sz.CX) div 2,
      R.Top + (FHeaderHeight - Sz.CY) div 2, FRowTailColumnsCapt[I]);
    if I <> FRowTailColumnsCount - 1 then
      Canvas.PolyLine([Point(R.Right - 1, R.Top), Point(R.Right - 1, R.Bottom)]);
  end;

  Canvas.PolyLine([Point(0, 0 + FHeaderHeight),
    Point(ClientWidth, 0 + FHeaderHeight)]);

  Canvas.Brush.Color := RGB(148, 167, 209);
  Canvas.FillRect(Rect(ClientWidth - BorderWidth - BevelWidth - FRowTailWidth,
    0 + FHeaderHeight + 1,
    ClientWidth,
    ClientHeight - FFooterHeight - 1));

  R := Rect(0, 0 + FHeaderHeight + 1,
    0, 0 + FHeaderHeight + FRowHeight + 1);
  Rw := FFirstVisibleRow;
  FNonEmptyRowsCount := 0;

  LVRSet := False;
  ClearToolTips;

  while R.Bottom < ClientHeight - FFooterHeight do
  begin
    if Rw < FResources.Count then
    begin
      Rs := FResources[Rw] as TraResource;
      if (Rw + 1) < FResources.Count then
        RsNext := FResources[Rw + 1] as TraResource
      else
        RsNext := nil;
    end else
    begin
      Rs := nil;
      RsNext := nil;
      if not LVRSet then
      begin
        LVRSet := True;
        FLastVisibleRow := Rw - 1;
      end;
    end;

    Canvas.Brush.Color := clBtnFace;
    Canvas.Font.Color := clBlack;

    for I := 0 to FRowHeadColumnsCount - 1 do
    begin
      R.Left := R.Right;
      R.Right := R.Left + FRowHeadColumnsWidth[I];
      if I = FRowHeadColumnsCount - 1 then
        R.Right := FRowHeaderWidth;
      Indent := 0;
      if Rs <> nil then
      begin
        if I = 0 then
          S := Rs.Name
        else if (I - 1) < Rs.SubItems.Count then
          S := Rs.SubItems[I - 1]
        else
          S := '';

        if (I = 0) and (Rs.Parent <> nil) then
        begin
          RsTemp := Rs.Parent;
          while RsTemp <> nil do
          begin
            Inc(Indent, FTab);
            RsTemp := RsTemp.Parent;
          end;
        end;
      end else
      begin
        S := '';
      end;
      Sz := Canvas.TextExtent(S);
      Canvas.TextRect(R, R.Left + FLeftGap + Indent,
        R.Top + (FRowHeight - Sz.CY) div 2, S);

      if (I = FRowHeadColumnsCount - 1) and (Rs <> nil) and (Rs.SubResources.Count > 0) then
      begin
        if (RsNext <> nil) and (RsNext.Parent = Rs) then
          Canvas.Draw(R.Right - FArUp.Width - FRightGap, R.Top +
            (R.Bottom - R.Top - FArUp.Height) div 2, FArUp)
        else
          Canvas.Draw(R.Right - FArDown.Width - FRightGap, R.Top +
            (R.Bottom - R.Top - FArDown.Height) div 2, FArDown);
      end;

      Canvas.PolyLine([Point(R.Right - 1, R.Top), Point(R.Right - 1, R.Bottom)]);
    end;

    D := FFirstVisibleValue;
    while R.Right <= ClientWidth - FRowTailWidth - FCellWidth do
    begin
      R.Left := R.Right;
      R.Right := R.Left + FCellWidth;

      Canvas.Brush.Color := GetCellColor(D, Rw);
      Canvas.FillRect(R);
      Canvas.PolyLine([Point(R.Right - 1, R.Top), Point(R.Right - 1, R.Bottom)]);

      D := IncValue(D);
    end;

    if Rs <> nil then
    begin
      for I := 0 to Rs.Intervals.Count - 1 do
      begin
        Interval := Rs.Intervals[I] as TraInterval;

        if (Interval.EndValue <= FFirstVisibleValue)
          or (Interval.StartValue >= IncValue(FLastVisibleValue)) then
        begin
          continue;
        end;

        IntervalRect := Rect(
          FRowHeaderWidth +
            Floor(FracValue(Interval.StartValue, FFirstVisibleValue) * FCellWidth),
          R.Top,
          FRowHeaderWidth +
            Ceil(FracValue(Interval.EndValue, FFirstVisibleValue) * FCellWidth),
          R.Bottom);

        IntervalRect.Right := IntervalRect.Right - 1;
        IntervalRect.Bottom := IntervalRect.Bottom - 1;

        SetLength(Pts, 64);
        PtsCount := 0;
        AngleConst := Min((IntervalRect.Bottom - IntervalRect.Top) div 2,
          (IntervalRect.Right - IntervalRect.Left) div 2);
        HalfHeight := (IntervalRect.Bottom - IntervalRect.Top) div 2;

        case Interval.BorderKind and $F of
          0:
          begin
            Pts[PtsCount + 0] := Point(IntervalRect.Left, IntervalRect.Bottom);
            Pts[PtsCount + 1] := Point(IntervalRect.Left, IntervalRect.Top);
            Inc(PtsCount, 2);
          end;

          1:
          begin
            Pts[PtsCount + 0] := Point(IntervalRect.Left + AngleConst, IntervalRect.Bottom);
            Pts[PtsCount + 1] := Point(IntervalRect.Left, IntervalRect.Top + HalfHeight);
            Pts[PtsCount + 2] := Point(IntervalRect.Left + AngleConst, IntervalRect.Top);
            Inc(PtsCount, 3);
          end;

          2:
          begin
            Pts[PtsCount + 0] := Point(IntervalRect.Left, IntervalRect.Bottom);
            Pts[PtsCount + 1] := Point(IntervalRect.Left + AngleConst, IntervalRect.Top + HalfHeight);
            Pts[PtsCount + 2] := Point(IntervalRect.Left, IntervalRect.Top);
            Inc(PtsCount, 3);
          end;
        else
          raise Exception.Create('Invalid left border constant');
        end;

        case (Interval.BorderKind shr 4) and $F of
          0:
          begin
            Pts[PtsCount + 0] := Point(IntervalRect.Right, IntervalRect.Top);
            Pts[PtsCount + 1] := Point(IntervalRect.Right, IntervalRect.Bottom);
            Inc(PtsCount, 2);
          end;

          1:
          begin
            Pts[PtsCount + 0] := Point(IntervalRect.Right, IntervalRect.Top);
            Pts[PtsCount + 1] := Point(IntervalRect.Right - AngleConst, IntervalRect.Top + HalfHeight);
            Pts[PtsCount + 2] := Point(IntervalRect.Right, IntervalRect.Bottom);
            Inc(PtsCount, 3);
          end;

          2:
          begin
            Pts[PtsCount + 0] := Point(IntervalRect.Right - AngleConst, IntervalRect.Top);
            Pts[PtsCount + 1] := Point(IntervalRect.Right, IntervalRect.Top + HalfHeight);
            Pts[PtsCount + 2] := Point(IntervalRect.Right - AngleConst, IntervalRect.Bottom);
            Inc(PtsCount, 3);
          end;
        else
          raise Exception.Create('Invalid left border constant');
        end;

        SetLength(Pts, PtsCount);

        VisibleRect := IntervalRect;
        if VisibleRect.Left < FRowHeaderWidth then
          VisibleRect.Left := FRowHeaderWidth;
        if VisibleRect.Right >= ClientWidth - FRowTailWidth then
          VisibleRect.Right := ClientWidth - FRowTailWidth - 1;

        VisibleRgn := CreateRectRgn(VisibleRect.Left, VisibleRect.Top,
          VisibleRect.Right, VisibleRect.Bottom);
        try
          SelectClipRgn(Canvas.Handle, VisibleRgn);
          try
            Canvas.Brush.Color := Interval.Color;
            Canvas.Pen.Style := psClear;
            Canvas.Polygon(Pts);
            Canvas.Pen.Style := psSolid;
          finally
            SelectClipRgn(Canvas.Handle, 0);
          end;

          CellRect := VisibleRect;
          CellRect.Right := FRowHeaderWidth;
          D := FFirstVisibleValue;
          while (D < Interval.EndValue) and (CellRect.Right <= ClientWidth - FRowTailWidth - FCellWidth) do
          begin
            CellRect.Left := CellRect.Right;
            CellRect.Right := CellRect.Left + FCellWidth;

            if ((FCursor.X = D) and (FCursor.Y = Rw)) or FindSelected(D, Rw) then
            begin
              CellRgn := CreateRectRgn(CellRect.Left, CellRect.Top,
                CellRect.Right, CellRect.Bottom);
              try
                SelectClipRgn(Canvas.Handle, CellRgn);
                try
                  Canvas.Brush.Color := TgsThemeManager.MixColors(GetCellColor(D, Rw), Interval.Color);
                  Canvas.Pen.Style := psClear;
                  Canvas.Polygon(Pts);
                  Canvas.Pen.Style := psSolid;
                finally
                  SelectClipRgn(Canvas.Handle, 0);
                end;
              finally
                DeleteObject(CellRgn);
              end;
            end;

            D := IncValue(D);
          end;

          SelectClipRgn(Canvas.Handle, VisibleRgn);
          try
            TextRect := IntervalRect;

            case Interval.BorderKind and $F of
              0: TextRect.Left := TextRect.Left + FLeftGap;
              1, 2: TextRect.Left := TextRect.Left + HalfHeight;
            end;

            case (Interval.BorderKind shr 4) and $F of
              0: TextRect.Right := TextRect.Right - FRightGap;
              1, 2: TextRect.Right := TextRect.Right - HalfHeight;
            end;

            if TextRect.Left > TextRect.Right then
              TextRect.Left := TextRect.Right;

            Canvas.Brush.Style := bsClear;
            Canvas.Font.Color := Interval.FontColor;
            if VarIsArray(Interval.Data) then
              V := Interval.Data[0]
            else
              V := Interval.Data;
            if VarType(V) in [varCurrency, varDouble] then
              DataS := FormatFloat('#,###', V)
            else
              DataS := V;
            Sz := Canvas.TextExtent(DataS);
            if (Sz.CX < TextRect.Right - TextRect.Left)
              and (Sz.CY < TextRect.Bottom - TextRect.Top) then
            begin
              Canvas.TextRect(TextRect, TextRect.Left + (TextRect.Right - TextRect.Left - Sz.CX) div 2,
                TextRect.Top + (TextRect.Bottom - TextRect.Top - Sz.CY) div 2, DataS);
              AddToolTip(VisibleRect, Interval.Comment);
            end else
            begin
              Canvas.TextRect(TextRect, TextRect.Left,
                TextRect.Top + (TextRect.Bottom - TextRect.Top - Sz.CY) div 2, DataS);
              AddToolTip(VisibleRect, DataS + #13#10#13#10 + Interval.Comment);
            end;
            Canvas.Brush.Style := bsSolid;
          finally
            SelectClipRgn(Canvas.Handle, 0);
          end;
        finally
          DeleteObject(VisibleRgn);
        end;
      end;
    end;

    Canvas.Brush.Color := FHeaderColor;
    Canvas.Font.Color := clBlack;

    for I := 0 to FRowTailColumnsCount - 1 do
    begin
      R.Left := R.Right;
      R.Right := R.Left + FRowTailColumnsWidth[I];
      if (Rs <> nil) and (Rs.TotalsCount > I) then
        TotalS := FormatFloat('#,##0', Rs.Totals[I])
      else
        TotalS := '';
      Sz := Canvas.TextExtent(TotalS);
      Canvas.TextRect(R, R.Right - Sz.CX - FRightGap,
        R.Top + (FRowHeight - Sz.CY) div 2, TotalS);
      if I <> FRowTailColumnsCount - 1 then
        Canvas.PolyLine([Point(R.Right - 1, R.Top), Point(R.Right - 1, R.Bottom)]);
    end;

    Canvas.PolyLine([Point(0, R.Bottom - 1), Point(R.Right, R.Bottom - 1)]);

    R.Left := 0;
    R.Right := R.Left;
    R.Top := R.Bottom;
    R.Bottom := R.Bottom + FRowHeight;
    Inc(Rw);
    Inc(FNonEmptyRowsCount);
  end;

  if not LVRSet then
    FLastVisibleRow := Rw - 1;

  Canvas.Brush.Color := RGB(162, 209, 156);

  if FRowTailColumnsCount <= 0 then
  begin
    R.Left := 0;
    R.Right := ClientWidth;
    R.Bottom := R.Top + FFooterHeight + 1;
    Canvas.FillRect(R);
  end else
  begin
    R.Bottom := R.Top + FFooterHeight + 1;
    R.Left := 0;
    R.Right := FRowHeaderWidth - 1;

    Canvas.FillRect(R);
    Canvas.PolyLine([Point(R.Right, R.Top), Point(R.Right, R.Bottom)]);

    D := FFirstVisibleValue;
    R.Right := R.Right + 1;
    while R.Right < ClientWidth - FRowTailWidth do
    begin
      R.Left := R.Right;
      R.Right := R.Right + FCellWidth;

      for J := 0 to MaxColTotals - 1 do
        ColTotals[J] := 0;

      for I := 0 to FResources.Count - 1 do
      begin
        Interval :=(FResources[I] as TraResource).Intervals.FindByValue(D);
        if Interval <> nil then
        begin
          for J := 0 to MaxColTotals - 1 do
          begin
            if VarType(Interval.Data) in [varDouble, varInteger, varCurrency] then
            begin
              ColTotals[J] := ColToTals[J] + Interval.Data;
              break;
            end;

            if (VarType(Interval.Data) and varArray) = 0 then
              break;

            if J + 1 > VarArrayHighBound(Interval.Data, 1) then
              break;

            ColTotals[J] := ColTotals[J] + Interval.Data[J + 1];
          end;
        end;
      end;

      TotalRect := Rect(R.Left, R.Top, R.Right, R.Top);

      for J := 0 to MaxColTotals - 1 do
      begin
        TotalRect.Top := TotalRect.Bottom;
        TotalRect.Bottom := TotalRect.Bottom + FHeaderRowHeight;
        TotalS := FormatFloat('#,###', ColTotals[J]);
        Sz := Canvas.TextExtent(TotalS);
        Canvas.TextRect(TotalRect, TotalRect.Right - Sz.CX - FRightGap,
          TotalRect.Top + FTopGap, TotalS);
      end;

      TotalRect.Top := TotalRect.Bottom;
      TotalRect.Bottom := R.Bottom;
      Canvas.FillRect(TotalRect);
      Canvas.PolyLine([Point(R.Right - 1, R.Top), Point(R.Right - 1, R.Bottom)]);

      D := IncValue(D);
    end;

    R.Left := R.Right;
    R.Right := ClientWidth;
    Canvas.FillRect(R);
  end;

  SI.cbSize := SizeOf(SI);
  SI.fMask := SIF_ALL;
  SI.nMin := 0;
  SI.nMax := FResources.Count - 1;
  SI.nPage := FNonEmptyRowsCount;
  SI.nPos := FFirstVisibleRow;
  SI.nTrackPos := 1;
  SetScrollInfo(Self.Handle, SB_VERT, SI, True);

  SI.cbSize := SizeOf(SI);
  SI.fMask := SIF_ALL;
  SI.nMin := 0;
  SI.nMax := DiffValue(FMaxValue, FMinValue);
  if FLastVisibleValueSet then
    SI.nPage := DiffValue(FLastVisibleValue, FFirstVisibleValue)
  else
    SI.nPage := 0;  
  SI.nPos := DiffValue(FFirstVisibleValue, FMinValue);
  SI.nTrackPos := 1;
  SetScrollInfo(Self.Handle, SB_HORZ, SI, True);
end;

procedure TgsRAChart.SelectRegion(const PA, PB: TraPoint);
var
  X1, X2: TraValue;
  Y1, Y2, I, J, K, Idx, Diff: Integer;
begin
  X1 := Min(PA.X, PB.X);
  Y1 := Math.Min(PA.Y, PB.Y);
  X2 := Max(PA.X, PB.X);
  Y2 := Math.Max(PA.Y, PB.Y);
  Diff := DiffValue(X2, X1);
  for I := 0 to Diff do
    for J := Y1 to Y2 do
      if not FindSelected(RAPoint(IncValue(X1, I), J), Idx) then
      begin
        SetLength(FSelected, Length(FSelected) + 1);
        for K := High(FSelected) - 1 downto Idx do
          FSelected[K + 1] := FSelected[K];
        FSelected[Idx] := RAPoint(IncValue(X1, I), J);
      end;
end;

procedure TgsRAChart.SetResourceID(const Value: Integer);
var
  Idx: Integer;
begin
  Idx := FResources.IndexOf(FResources.FindByID(Value));

  if Idx < 0 then
    raise Exception.Create('Invalid ID');

  FCursor.Y := Idx;
  Invalidate;
end;

procedure TgsRAChart.SetValue(const Value: TraValue);
begin
  if (Value < FMinValue) or (Value > FMaxValue) then
    raise Exception.Create('Value is out of range');

  FCursor.X := AdjustValue(Value);
  Invalidate;
end;

procedure TgsRAChart.SetFirstVisibleValue(const Value: TraValue);
begin
  FFirstVisibleValue := AdjustValue(Value);
  if FFirstVisibleValue > FMaxValue then
    FFirstVisibleValue := FMaxValue;
  if FFirstVisibleValue < FMinValue then
    FFirstVisibleValue := FMinValue;
  FLastVisibleValueSet := False;  
  Invalidate;
end;

procedure TgsRAChart.SetRowHeadColumnsCapt(Index: Integer;
  const Value: String);
begin
  FRowHeadColumnsCapt[Index] := Value;
end;

procedure TgsRAChart.SetRowHeadColumnsCount(const Value: Integer);
begin
  FRowHeadColumnsCount := Value;
  SetLength(FRowHeadColumnsCapt, Value);
  SetLength(FRowHeadColumnsWidth, Value);
end;

procedure TgsRAChart.SetRowHeadColumnsWidth(Index: Integer;
  const Value: Integer);
begin
  FRowHeadColumnsWidth[Index] := Value;
end;

procedure TgsRAChart.SetRowTailColumnsCapt(Index: Integer;
  const Value: String);
begin
  FRowTailColumnsCapt[Index] := Value;
end;

procedure TgsRAChart.SetRowTailColumnsCount(const Value: Integer);
begin
  FRowTailColumnsCount := Value;
  SetLength(FRowTailColumnsCapt, Value);
  SetLength(FRowTailColumnsWidth, Value);
  FInitialFooterHeight := FHeaderRowHeight * Value;
end;

procedure TgsRAChart.SetRowTailColumnsWidth(Index: Integer;
  const Value: Integer);
begin
  FRowTailColumnsWidth[Index] := Value;
end;

procedure TgsRAChart.ToggleCell(const P: TRAPoint);
var
  Idx, I: Integer;
begin
  if not FindSelected(P, Idx) then
  begin
    SetLength(FSelected, Length(FSelected) + 1);
    for I := High(FSelected) - 1 downto Idx do
      FSelected[I + 1] := FSelected[I];
    FSelected[Idx] := P;
  end else
  begin
    for I := Idx + 1 to High(FSelected) do
      FSelected[I - 1] := FSelected[I];
    SetLength(FSelected, Length(FSelected) - 1);
  end;
end;

procedure TgsRAChart.WMEraseBkGnd(var Message: TMessage);
begin
  Message.Result := 1;
end;

procedure TgsRAChart.WMGetDlgCode(var Message: TMessage);
begin
  inherited;
  Message.Result := Message.Result or DLGC_WANTCHARS or DLGC_WANTARROWS or DLGC_WANTALLKEYS;
end;

procedure TgsRAChart.WMHScroll(var Msg: TWMHScroll);
begin
  inherited;

  case Msg.ScrollCode of
    SB_LINELEFT:
    begin
      FFirstVisibleValue := DecValue(FFirstVisibleValue);
      if FFirstVisibleValue < FMinValue then
        FFirstVisibleValue := FMinValue;
      Invalidate;
    end;

    SB_LINERIGHT:
    if FLastVisibleValueSet then
    begin
      FFirstVisibleValue := IncValue(FFirstVisibleValue);
      if FFirstVisibleValue >= FMaxValue - (FLastVisibleValue - FFirstVisibleValue) then
        FFirstVisibleValue := DecValue(FMaxValue - (FLastVisibleValue - FFirstVisibleValue));
      Invalidate;
    end;

    SB_PAGELEFT:
    if FLastVisibleValueSet then
    begin
      FFirstVisibleValue := FFirstVisibleValue - (FLastVisibleValue - FFirstVisibleValue);
      if FFirstVisibleValue < FMinValue then
        FFirstVisibleValue := FMinValue;
      Invalidate;
    end;

    SB_PAGERIGHT:
    if FLastVisibleValueSet then
    begin
      FFirstVisibleValue := FFirstVisibleValue + (FLastVisibleValue - FFirstVisibleValue);
      if FFirstVisibleValue >= FMaxValue - (FLastVisibleValue - FFirstVisibleValue) then
        FFirstVisibleValue := DecValue(FMaxValue - (FLastVisibleValue - FFirstVisibleValue));
      Invalidate;
    end;

    SB_LEFT:
    begin
      FFirstVisibleValue := FMinValue;
      Invalidate;
    end;

    SB_RIGHT:
    if FLastVisibleValueSet then
    begin
      FFirstVisibleValue := DecValue(FMaxValue - (FLastVisibleValue - FFirstVisibleValue));
      Invalidate;
    end;

    SB_THUMBTRACK:
    if FLastVisibleValueSet then
    begin
      FFirstVisibleValue := IncValue(FMinValue, Msg.Pos);
      if FFirstVisibleValue >= FMaxValue - (FLastVisibleValue - FFirstVisibleValue) then
        FFirstVisibleValue := DecValue(FMaxValue - (FLastVisibleValue - FFirstVisibleValue));
      Invalidate;
    end;
  end;

  if Visible and CanFocus and TabStop and not (csDesigning in ComponentState) then
    SetFocus;
end;

procedure TgsRAChart.WMKeyDown(var Message: TWMKey);
begin
  inherited;
end;

procedure TgsRAChart.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;
  FInMouseSelection := False;

  if FOldSelectedFrameHeight <> 0 then
    SystemParametersInfo(SPI_SETFOCUSBORDERHEIGHT, 0, Pointer(FOldSelectedFrameHeight), 0);
  if FOldSelectedFrameWidth <> 0 then
    SystemParametersInfo(SPI_SETFOCUSBORDERWIDTH, 0, Pointer(FOldSelectedFrameWidth), 0);

  Invalidate;
end;

procedure TgsRAChart.WMPaint(var Message: TWMPaint);
begin
  inherited;
end;

procedure TgsRAChart.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;

  SystemParametersInfo(SPI_SETFOCUSBORDERHEIGHT, 0, Pointer(2), 0);
  SystemParametersInfo(SPI_SETFOCUSBORDERWIDTH, 0, Pointer(2), 0);

  Invalidate;
end;

procedure TgsRAChart.WMSize(var Message: TWMSize);
begin
  inherited;
  Invalidate;
end;

procedure TgsRAChart.WMVScroll(var Msg: TWMVScroll);
begin
  inherited;

  case Msg.ScrollCode of
    SB_LINEDOWN:
    begin
      FFirstVisibleRow := FFirstVisibleRow + 1;
      if FFirstVisibleRow > FResources.Count - FNonEmptyRowsCount then
        FFirstVisibleRow := FResources.Count - FNonEmptyRowsCount;
      if FFirstVisibleRow < 0 then
        FFirstVisibleRow := 0;
      Invalidate;
    end;

    SB_LINEUP:
    begin
      FFirstVisibleRow := FFirstVisibleRow - 1;
      if FFirstVisibleRow < 0 then
        FFirstVisibleRow := 0;
      Invalidate;
    end;

    SB_BOTTOM:
    begin
      FFirstVisibleRow := FResources.Count - FNonEmptyRowsCount;
      if FFirstVisibleRow < 0 then
        FFirstVisibleRow := 0;
      Invalidate;
    end;

    SB_TOP:
    begin
      FFirstVisibleRow := 0;
      Invalidate;
    end;

    SB_PAGEDOWN:
    begin
      FFirstVisibleRow := FFirstVisibleRow + FNonEmptyRowsCount;
      if FFirstVisibleRow > FResources.Count - FNonEmptyRowsCount then
        FFirstVisibleRow := FResources.Count - FNonEmptyRowsCount;
      if FFirstVisibleRow < 0 then
        FFirstVisibleRow := 0;
      Invalidate;
    end;

    SB_PAGEUP:
    begin
      FFirstVisibleRow := FFirstVisibleRow - FNonEmptyRowsCount;
      if FFirstVisibleRow < 0 then
        FFirstVisibleRow := 0;
      Invalidate;
    end;

    SB_THUMBTRACK:
    begin
      FFirstVisibleRow := Msg.Pos;
      if FFirstVisibleRow > FResources.Count - 1 then
        FFirstVisibleRow := FResources.Count - 1;
      if FFirstVisibleRow < 0 then
        FFirstVisibleRow := 0;
      Invalidate;
    end;
  end;

  if Visible and CanFocus and TabStop and not (csDesigning in ComponentState) then
    SetFocus;
end;

procedure TgsRAChart.WMWindowPosChanged(var Message: TMessage);
begin
  inherited;
end;

{ TraIntervals }

function TraIntervals.AddInterval(const AnID: Integer;
  const AStartValue, AnEndValue: TraValue; const AData: Variant;
  const AComment: String;
  const AColor, AFontColor: TColor; const ABorderKind: Integer): Integer;
var
  Interval: TraInterval;
begin
  if FindByID(AnID) <> nil then
    raise Exception.Create('Duplicate ID');

  if AStartValue > AnEndValue then
    raise Exception.Create('Invalid interval boundaries');

  if FindOverlap(AStartValue, AnEndValue, nil) <> nil then
    raise Exception.Create('Interval overlaps');

  if FindByStartValue(AStartValue, Result) then
    raise Exception.Create('Interval with specified start value already exists');

  Interval := TraInterval.Create;
  Interval.ID := AnID;
  Interval.Data := AData;
  Interval.Comment := AComment;
  Interval.Color := AColor;
  Interval.FontColor := AFontColor;
  Interval.BorderKind := ABorderKind;
  Interval.StartValue := AStartValue;
  Interval.EndValue := AnEndValue;

  Insert(Result, Interval);
end;

function TraIntervals.FindByID(const AnID: Integer): TraInterval;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if (Items[I] as TraInterval).ID = AnID then
    begin
      Result := Items[I] as TraInterval;
      break;
    end;
end;

function TraIntervals.FindByStartValue(const AStartValue: TraValue;
  out Index: Integer): Boolean;
var
  L, H, I: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    if (Items[I] as TraInterval).StartValue < AStartValue then
    begin
      L := I + 1
    end else
    begin
      H := I - 1;
      if (Items[I] as TraInterval).StartValue = AStartValue then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;
  Index := L;
end;

function TraIntervals.FindByValue(const AValue: TraValue): TraInterval;
var
  I: Integer;
  Interval: TraInterval;
begin
  Assert(Resource is TraResource);
  Assert(Resource.Owner is TraResources);
  Assert(Resource.Owner.Chart is TgsRAChart);

  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Interval := Items[I] as TraInterval;
    if
      (
        (Interval.StartValue >= AValue)
        and
        (Interval.StartValue < Resource.Owner.Chart.IncValue(AValue))
      )
      {or
      (
        (Interval.EndValue > AValue)
        and
        (Interval.EndValue < IncValue(AValue))
      )
      or
      (
        (Interval.StartValue <= AValue)
        and
        (Interval.EndValue > AValue)
      )} then
    begin
      Result := Items[I] as TraInterval;
      break;
    end;
  end;

  if Result = nil then
    for I := 0 to Count - 1 do
    begin
      Interval := Items[I] as TraInterval;
      if
        (
          (Interval.StartValue <= AValue)
          and
          (Interval.EndValue > AValue)
        ) then
      begin
        Result := Items[I] as TraInterval;
        break;
      end;
    end;
end;

procedure TgsRAChart.WM_MOUSEMOVE(var Msg: TWMMouseMove);
begin
  inherited;
end;

procedure TgsRAChart.WM_NOTIFY(var Msg: TMessage);
begin
  inherited;

  if PNMHDR(Msg.LParam)^.Code = TTN_GETDISPINFO then
  begin
    if (PNMHDR(Msg.LParam)^.idFrom >= Low(FToolTips)) and (PNMHDR(Msg.LParam)^.idFrom <= High(FToolTips)) then
    begin
      SendMessage(PNMHDR(Msg.LParam)^.hwndFrom, TTM_SETMAXTIPWIDTH, 0, 150);
      PNMTTDISPINFO(Msg.LParam)^.lpszText := StrPLCopy(FTipBuffer,
        FToolTips[PNMHDR(Msg.LParam)^.idFrom],
        SizeOf(FTipBuffer) - 1);
    end;
  end;
end;

function TraIntervals.FindOverlap(const AStartValue, AnEndValue: TraValue;
  AnExclude: TraInterval): TraInterval;
var
  I: Integer;
  Intr: TraInterval;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Intr := Items[I] as TraInterval;
    if
      (
        (Intr.StartValue >= AStartValue)
        and
        (Intr.StartValue < AnEndValue)
      )
      or
      (
        (Intr.EndValue > AStartValue)
        and
        (Intr.EndValue <= AnEndValue)
      ) then
    begin
      if Items[I] <> AnExclude then
      begin
        Result := Items[I] as TraInterval;
        break;
      end;
    end;
  end;
end;

procedure TgsRAChart.ChangeCursorPos(const X: TraValue; const Y: Integer);
begin
  FCursor.X := X;
  FCursor.Y := Y;

  if FCursor.X < FMinValue then
    FCursor.X := FMinValue;
  if FCursor.X > FMaxValue then
    FCursor.X := FMaxValue;
  if FCursor.X < FFirstVisibleValue then
    FFirstVisibleValue := FCursor.X;
  if FLastVisibleValueSet and (FCursor.X > FLastVisibleValue) then
    FFirstVisibleValue := IncValue(FFirstVisibleValue,
      DiffValue(FCursor.X, FLastVisibleValue));

  if FCursor.Y < 0 then
    FCursor.Y := 0;
  if FCursor.Y >= FResources.Count then
    FCursor.Y := FResources.Count - 1;  
  if (FLastVisibleRow >= 0) and (FCursor.Y > FLastVisibleRow) then
    Inc(FFirstVisibleRow, FCursor.Y - FLastVisibleRow);
  if FCursor.Y < FFirstVisibleRow then
    Dec(FFirstVisibleRow, FFirstVisibleRow - FCursor.Y);
end;

procedure TgsRAChart.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

function TgsRAChart.GetIntervalID: Integer;
var
  Rs: TraResource;
  Interval: TraInterval;
begin
  Result := -1;
  Rs := FResources.FindByID(ResourceID);
  if Rs <> nil then
  begin
    Interval := Rs.Intervals.FindByValue(Value);
    if Interval <> nil then
      Result := Interval.ID;
  end;
end;

function TgsRAChart.GetDragResourceID: Integer;
begin
  if (FDragCursor.Y >= 0) and (FDragCursor.Y < FResources.Count) then
    Result := (FResources[FDragCursor.Y] as TraResource).ID
  else
    Result := -1;
end;

function TgsRAChart.GetDragValue: TraValue;
begin
  Result := FDragCursor.X;
end;

procedure TgsRAChart.SetMaxValue(const Value: TraValue);
begin
  if FMaxValue <> Value then
  begin
    FMaxValue := AdjustValue(Value);
    if FCursor.X > FMaxValue then
      FCursor.X := FMaxValue;
    Invalidate;
  end;
end;

procedure TgsRAChart.SetMinValue(const Value: TraValue);
begin
  if FMinValue <> Value then
  begin
    FMinValue := AdjustValue(Value);
    if FFirstVisibleValue < FMinValue then
      FFirstVisibleValue := FMinValue;
    if FCursor.X < FMinValue then
      FCursor.X := FMinValue;
    Invalidate;
  end;
end;

procedure TgsRAChart.ClearIntervals(const AResourceID: Integer);
var
  Res: TraResource;
begin
  Res := FResources.FindByID(AResourceID);
  if Res = nil then
    raise Exception.Create('Invalid resource ID')
  else begin
    Res.Intervals.Clear;
    Res.ClearTotals;
    Invalidate;
  end;
end;

procedure TgsRAChart.ClearResources;
begin
  FResources.Clear;
  FCursor.Y := 0;
  Invalidate;
end;

procedure TgsRAChart.DeleteInterval(const AResourceID, AnID: Integer);
var
  Res: TraResource;
  Interval: TraInterval;
begin
  Res := FResources.FindByID(AResourceID);
  if Res = nil then
    raise Exception.Create('Invalid resource ID')
  else begin
    Interval := Res.Intervals.FindByID(AnID);
    if Interval = nil then
      raise Exception.Create('Invalid interval ID')
    else begin
      Res.UpdateTotals(Interval.Data, Null);
      Res.Intervals.Remove(Interval);
      Invalidate;
    end;
  end;
end;

procedure TgsRAChart.DeleteResource(const AnID: Integer);
var
  Res: TraResource;
begin
  Res := FResources.FindByID(AnID);
  if Res = nil then
    raise Exception.Create('Invalid resource ID')
  else begin
    FResources.Remove(Res);
    if FCursor.Y >= FResources.Count then
      FCursor.Y := FResources.Count - 1;
    Invalidate;
  end;
end;

function TgsRAChart.GetCellDecoration(const AValue: TraValue): TColor;
begin
  if ((scDays and FScaleKind) <> 0)
    and ((DayOfWeek(AValue) = 1) or (DayOfWeek(AValue) = 7)) then
  begin
    Result := RGB(255, 200, 200);
  end else
    Result := clWindow;
end;

function TgsRAChart.GetSelectedCount: Integer;
begin
  Result := Length(FSelected);
end;

procedure TgsRAChart.GetSelected(const Idx: Integer; out AValue: TraValue;
  out AResourceID: Integer);
begin
  if (Idx >= Low(FSelected)) and (Idx <= High(FSelected)) then
  begin
    AValue := FSelected[Idx].X;
    if (FSelected[Idx].Y < 0) or (FSelected[Idx].Y >= FResources.Count) then
      raise Exception.Create('Invalid selected row index');
    AResourceID := (FResources[FSelected[Idx].Y] as TraResource).ID;
  end else
    raise Exception.Create('Index is out of bounds');
end;

procedure TgsRAChart.SetCellWidth(const Value: Integer);
begin
  if Value < 8 then
    raise Exception.Create('Minimal cell width is 8 pixels');
  if FCellWidth <> Value then
  begin
    FCellWidth := Value;
    Invalidate;
  end;  
end;

procedure TgsRAChart.SetRowHeight(const Value: Integer);
begin
  if Value < 8 then
    raise Exception.Create('Minimal row height is 8 pixels');
  if FRowHeight <> Value then
  begin
    FRowHeight := Value;
    Invalidate;
  end;
end;

procedure TgsRAChart.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  C1, C2: TraValue;
  R1, R2: Integer;
begin
  inherited;

  if FInMouseSelection then
  begin
    FInMouseSelection := False;
    if (FMouseSelectionStart.X <> FMouseSelectionPoint.X)
      or (FMouseSelectionStart.Y <> FMouseSelectionPoint.Y) then
    begin
      Canvas.DrawFocusRect(Rect(Min(FMouseSelectionStart.X, FMouseSelectionPoint.X),
        Min(FMouseSelectionStart.Y, FMouseSelectionPoint.Y),
        Max(FMouseSelectionStart.X, FMouseSelectionPoint.X),
        Max(FMouseSelectionStart.Y, FMouseSelectionPoint.Y)));
      if GetCellFromMouse(FMouseSelectionStart.X, FMouseSelectionStart.Y, C1, R1)
        and GetCellFromMouse(X, Y, C2, R2)
        and ((C1 <> C2) or (R1 <> R2)) then
      begin
        SelectRegion(
          RAPoint(Min(C1, C2), Min(R1, R2)),
          RAPoint(Max(C1, C2), Max(R1, R2)));
        DoChange;
        Invalidate;
      end;
    end;
  end;
end;

function TgsRAChart.FindIntervalID(const AResourceID: Integer;
  const AValue: TraValue): Integer;
var
  Interval: TraInterval;
  Res: TraResource;
begin
  Result := -1;
  Res := FResources.FindByID(AResourceID);
  if Res <> nil then
  begin
    Interval := Res.Intervals.FindByValue(AValue);
    if Interval <> nil then
      Result := Interval.ID;
  end;
end;

procedure TgsRAChart.WM_DESTROY(var Msg: TMessage);
begin
  inherited;

  if FOldSelectedFrameHeight <> 0 then
    SystemParametersInfo(SPI_SETFOCUSBORDERHEIGHT, 0, Pointer(FOldSelectedFrameHeight), 0);
  if FOldSelectedFrameWidth <> 0 then
    SystemParametersInfo(SPI_SETFOCUSBORDERWIDTH, 0, Pointer(FOldSelectedFrameWidth), 0);
end;

procedure TgsRAChart.ClearSelected;
begin
  SetLength(FSelected, 0);
  Invalidate;
end;

function TgsRAChart.GetCellColor(const C: TraValue;
  const R: Integer): TColor;
begin
  if (C > FMaxValue) or (C < FMinValue) or (R >= FResources.Count) or (R < 0) then
    Result := clBtnFace
  else
  begin
    if (FCursor.X = C) and (FCursor.Y = R) then
    begin
      if FindSelected(C, R) then
        Result := RGB(33, 255, 169)
      else
        Result := RGB(40, 255, 44);
    end else
    begin
      if FindSelected(C, R) then
        Result := TgsThemeManager.MixColors(RGB(164, 206, 215), GetCellDecoration(C))
      else
        Result := GetCellDecoration(C);
    end;

    if not Focused then
      Result := TgsThemeManager.MixColors(Result, clSilver);
  end;
end;

function TgsRAChart.FindSelected(const C: TraValue;
  const R: Integer): Boolean;
var
  Idx: Integer;
begin
  Result := FindSelected(RAPoint(C, R), Idx);
end;

procedure TgsRAChart.GetIntervalData(const AResourceID,
  AnIntervalID: Integer; out AStartValue, AnEndValue: TraValue;
  out AData: Variant; out AComment: String);
var
  Res: TraResource;
  Interval: TraInterval;
begin
  Res := FResources.FindByID(AResourceID);
  if Res <> nil then
  begin
    Interval := Res.FIntervals.FindByID(AnIntervalID);
    if Interval <> nil then
    begin
      AStartValue := Interval.StartValue;
      AnEndValue := Interval.EndValue;
      AData := Interval.Data;
      AComment := Interval.Comment;
      exit;
    end;
  end;
  raise Exception.Create('Invalid resource or interval ID');
end;

function TgsRAChart.GetDragIntervalID: Integer;
begin
  Result := FDragIntervalID;
end;

procedure TgsRAChart.SetScaleKind(const Value: Integer);
begin
  FScaleKind := Value;
  FMinValue := AdjustValue(FMinValue);
  FMaxValue := AdjustValue(FMaxValue);
  FCursor.X := AdjustValue(FCursor.X);
  FFirstVisibleValue := AdjustValue(FFirstVisibleValue);
  FLastVisibleValueSet := False;
  Invalidate;
end;

function TgsRAChart.AdjustValue(const AValue: TraValue): TraValue;
var
  Dbl: TDateTime;
  Y, M, D: Word;
begin
  if (scDays and FScaleKind) <> 0 then
  begin
    Dbl := Floor(AValue);
    Result := Dbl;
  end else
  begin
    DecodeDate(AValue, Y, M, D);
    Result := EncodeDate(Y, M, 1);
  end;
end;

procedure TgsRAChart.ScrollTo(const AResourceID: Integer;
  const AValue: TraValue);
var
  Idx: Integer;
begin
  if (AValue < FMinValue) or (AValue > FMaxValue) then
    raise Exception.Create('Value is out of range');

  Idx := FResources.IndexOf(FResources.FindByID(AResourceID));
  if Idx < 0 then
    raise Exception.Create('Invalid ID');

  FCursor.Y := Idx;
  FCursor.X := AdjustValue(AValue);

  if FCursor.X < FFirstVisibleValue then
  begin
    FFirstVisibleValue := FCursor.X;
    FLastVisibleValueSet := False;
  end;

  if FLastVisibleValueSet and (FCursor.X > FLastVisibleValue) then
  begin
    FFirstVisibleValue := IncValue(FFirstVisibleValue, DiffValue(FCursor.X, FLastVisibleValue));
    FLastVisibleValueSet := False;
  end;

  if (FLastVisibleRow >= 0) and (FCursor.Y > FLastVisibleRow) then
    Inc(FFirstVisibleRow, FCursor.Y - FLastVisibleRow);
  if FCursor.Y < FFirstVisibleRow then
    Dec(FFirstVisibleRow, FFirstVisibleRow - FCursor.Y);

  Invalidate;
end;

end.