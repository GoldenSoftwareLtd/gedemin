unit Xaccount;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DBTables;

type
  TFormulaType = (ftUnknown, ftIllPay, ftHolidPay, ftStag, ftGeneral, ftYearPay,
    ftIllInd);

type

  TxDate = class
    FDate: TDateTime;
  end;

  TxPeriod = class
    FBeginDate: TDateTime;
    FEndDate: TDateTime;
  end;

  (* Начисление *)
  TxPayRecord = class
  private
    FAccDate, FEnlistDate: TDateTime;
    FAccName: String;
    FDays: Double;
    FHours: Double;
    FSum: Double;

    function GetAccYear: word;
    function GetAccMonth: word;
    function GetEnlistYear: word;
    function GetEnlistMonth: word;
  public
    constructor Create;

    function IsLess(Value: TxPayRecord): Boolean;
    function EnlistDateEqual(Value: TxPayRecord): Boolean;

    procedure UpDate(Value: TxPayRecord);

    property AccDate: TDateTime read FAccDate write FAccDate;
    property AccYear: Word read GetAccYear;
    property AccMonth: Word read GetAccMonth;

    property EnlistDate: TDateTime read FEnlistDate write FEnlistDate;
    property EnlistYear: Word read GetEnlistYear;
    property EnlistMonth: Word read GetEnlistMonth;

    property AccName: String read FAccName write FAccName;
    property Days: Double read FDays write FDays;
    property Hours: Double read FHours write FHours;
    property Sum: Double read FSum write FSum;
  end;

  TxAccountList = class
  private
    function GetCount: Integer;
    function GetDays: Double;
    function GetHours: Double;
    function GetSum: Double;
  public
    FList: TList;
    constructor Create;
    destructor Destroy;

    function RowByIndex(I: Integer): TxPayRecord;

    procedure Add(Value: TxPayRecord);
    procedure AddByEnlistDate(Value: TxPayRecord);
    procedure Clear;

    property Count: Integer read GetCount;
    property Days: Double read GetDays;
    property Hours: Double read GetHours;
    property Sum: Double read GetSum;
  end;

  (* Должностные оклады *)
type
  TxMSalarySum = class(TComponent)
  private
    FWorkDate: TDateTime;
    FMSalAcc: TTable;

    FEmplKey: LongInt;
    FExist: Boolean;
    FWorkDays: Integer;
    FWorkHours, FWorkSum: Double;
    FHoliDays: Integer;
    FHoliHours, FHoliSum: Double;

    function GetActive: Boolean;

    procedure ReadProperties;
    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetWorkDate(Value: TDateTime);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property WorkDate: TDateTime read FWorkDate write SetWorkDate;

    property WorkDays: Integer read FWorkDays;
    property WorkHours: Double read FWorkHours;
    property WorkSum: Double read FWorkSum;
    property HoliDays: Integer read FHoliDays;
    property HoliHours: Double read FHoliHours;
    property HoliSum: Double read FHoliSum;
  end;

  (* Почасовая оплата *)
type
  TxTimePaySum = class(TComponent)
  private
    FWorkDate: TDateTime;
    FTimePay: TTable;

    FEmplKey: LongInt;
    FExist: Boolean;

    FWorkDays: Integer;
    FWorkHours, FWorkSum: Double;
    FHoliDays: Integer;
    FHoliHours, FHoliSum, FNightHours, FNightSum: Double;
    FOverTime1Hours, FOverTime1Sum: Double;
    FOverTime2Hours, FOverTime2Sum: Double;

    function GetActive: Boolean;

    procedure ReadProperties;
    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetWorkDate(Value: TDateTime);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property WorkDate: TDateTime read FWorkDate write SetWorkDate;

    property WorkDays: Integer read FWorkDays;
    property WorkHours: Double read FWorkHours;
    property WorkSum: Double read FWorkSum;
    property HoliDays: Integer read FHoliDays;
    property HoliHours: Double read FHoliHours;
    property HoliSum: Double read FHoliSum;
    property NightHours: Double read FNightHours;
    property NightSum: Double read FNightSum;
    property OverTime1Hours: Double read FOverTime1Hours;
    property OverTime1Sum: Double read FOverTime1Sum;
    property OverTime2Hours: Double read FOverTime2Hours;
    property OverTime2Sum: Double read FOverTime2Sum;

  end;

  (* Сдельная оплата *)
type
  TxSimpleOrderSum = class(TComponent)
  private
    FFromDate, FToDate, FWorkDate: TDateTime;

    FSOrders, FPiecWork: TTable;

    FVarList: TStringList;

    FEmplKey: LongInt;
    FExist: Boolean;
    FWorkDays: Double;
    FWorkHours, FWorkSum: Double;
    FHoliDays: Double;
    FHoliHours, FHoliSum: Double;
    FAddPaySum, FAtherSum: Double;

    FxAccountList: TxAccountList;

    function GetActive: Boolean;

    procedure SetActive(Value: Boolean);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetWorkDays: Double;
    function GetWorkHours: Double;
    function GetWorkSum: Double;

    function GetHoliDays: Double;
    function GetHoliHours: Double;
    function GetHoliSum: Double;

    function GetAtherSum: Double;
    function GetAddPaySum: Double;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function GetSumByVariable(Value: String): Double;
    procedure FillVarList;

    procedure CreateWorkSumList;
    procedure CreateHolidSumList;
    procedure CreateAddPaySumList;
    procedure CreateAtherSumList;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write FEmplKey;

    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;
    property WorkDate: TDateTime read FWorkDate write FWorkDate;

    property WorkDays: Double read GetWorkDays;
    property WorkHours: Double read GetWorkHours;
    property WorkSum: Double read GetWorkSum;
    property HoliDays: Double read GetHoliDays;
    property HoliHours: Double read GetHoliHours;
    property HoliSum: Double read GetHoliSum;
    property AddPaySum: Double read GetAddPaySum;
    property AtherSum: Double read GetAtherSum;

    property xAccountList: TxAccountList read FxAccountList write FxAccountList;

    property VarList: TStringList read FVarList;
  end;

  (* Оплата с учетом коэффицента трудового участия *)
type
  TxKTUOrderSum = class(TComponent)
  private
    FFromDate, FToDate: TDateTime;

    FKTUVed, FKTUStaff: TTable;

    FEmplKey: LongInt;
    FExist: Boolean;

    FAddPayOrder: Integer;

    FWorkDays: Integer;
    FWorkHours, FWorkSum: Double;

    function GetActive: Boolean;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetWorkDays: Integer;
    function GetWorkHours: Double;
    function GetWorkSum: Double;

    function GetKTUValue(What: Integer): Double;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;

    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;

    property WorkDays: Integer read GetWorkDays;
    property WorkHours: Double read GetWorkHours;
    property WorkSum: Double read GetWorkSum;

    property AddPayOrder: Integer read FAddPayOrder write FAddPayOrder;
  end;

(* Отпуска *)
type
  TxHolidPaySum = class(TComponent)
  private
    FWorkDate, FFromDate, FToDate: TDateTime;
    FHolidPay, FHolidStr: TTable;
    FEmplKey: LongInt;
    FExist: Boolean;

    FPeriodList: TList;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;
    function GetAllHoliDays: Double;
    function GetAllHolidSum: Double;
    function GetAllCompDays: Double;
    function GetAllCompSum: Double;

    function GetPrevHoliDays: Double;
    function GetPrevHolidSum: Double;
    function GetPrevCompDays: Double;
    function GetPrevCompSum: Double;

    function GetCurrentHoliDays: Double;
    function GetCurrentHolidSum: Double;
    function GetCurrentCompDays: Double;
    function GetCurrentCompSum: Double;

    function GetOnlyCurrentHoliDays: Double;
    function GetOnlyCurrentHolidSum: Double;
    function GetOnlyCurrentCompDays: Double;
    function GetOnlyCurrentCompSum: Double;

    function GetNextHoliDays: Double;
    function GetNextHolidSum: Double;
    function GetNextCompDays: Double;
    function GetNextCompSum: Double;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AllHolidSumList;
    procedure AllCompSumList;

    procedure PrevHolidSumList;
    procedure PrevCompSumList;

    procedure CurrentHolidSumList;
    procedure CurrentCompSumList;

    procedure OnlyCurrentHolidSumList;
    procedure OnlyCurrentCompSumList;

    procedure NextHolidSumList;
    procedure NextCompSumList;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;
    property WorkDate: TDateTime read FWorkDate write FWorkDate;

    property xAccountList: TxAccountList read FxAccountList;

    property AllHoliDays: Double read GetAllHoliDays;
    property AllHolidSum: Double read GetAllHolidSum;
    property AllCompDays: Double read GetAllCompDays;
    property AllCompSum: Double read GetAllCompSum;

    property PrevHoliDays: Double read GetPrevHoliDays;
    property PrevHolidSum: Double read GetPrevHolidSum;
    property PrevCompDays: Double read GetPrevCompDays;
    property PrevCompSum: Double read GetPrevCompSum;

    property CurrentHoliDays: Double read GetCurrentHoliDays;
    property CurrentHolidSum: Double read GetCurrentHolidSum;
    property CurrentCompDays: Double read GetCurrentCompDays;
    property CurrentCompSum: Double read GetCurrentCompSum;

    property OnlyCurrentHoliDays: Double read GetOnlyCurrentHoliDays;
    property OnlyCurrentHolidSum: Double read GetOnlyCurrentHolidSum;
    property OnlyCurrentCompDays: Double read GetOnlyCurrentCompDays;
    property OnlyCurrentCompSum: Double read GetOnlyCurrentCompSum;

    property NextHoliDays: Double read GetNextHoliDays;
    property NextHolidSum: Double read GetNextHolidSum;
    property NextCompDays: Double read GetNextCompDays;
    property NextCompSum: Double read GetNextCompSum;
  end;

(* Больничные *)
type
  TxIllPaySum = class(TComponent)
  private
    FWorkDate, FFromDate, FToDate: TDateTime;
    FIllPay, FIllStr: TTable;
    FEmplKey: LongInt;
    FExist: Boolean;

    FIllCode: String;
    FEndDaysList: TList;
    FxAccountList: TxAccountList;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);
    procedure SetIllCode(Value: String);

    function GetActive: Boolean;


    function GetAllIllDays: Double;
    function GetAllIllHours: Double;
    function GetAllIllSum: Double;

    function GetAllDekrDays: Double;
    function GetAllDekrHours: Double;
    function GetAllDekrSum: Double;

    function GetAllIllDaysByCode: Double;
    function GetAllIllHoursByCode: Double;
    function GetAllIllSumByCode: Double;

    function GetCurrentIllDays: Double;
    function GetCurrentIllHours: Double;
    function GetCurrentIllSum: Double;
    function GetCurrentIllSum100: Double;

    function GetCurrentDekrDays: Double;
    function GetCurrentDekrHours: Double;
    function GetCurrentDekrSum: Double;

    function GetPrevIllDays: Double;
    function GetPrevIllHours: Double;
    function GetPrevIllSum: Double;

    function GetPrevDekrDays: Double;
    function GetPrevDekrHours: Double;
    function GetPrevDekrSum: Double;

    function GetCurrentPrevIllDays: Double;
    function GetCurrentPrevIllHours: Double;
    function GetCurrentPrevIllSum: Double;
    function GetCurrentPrevDekrDays: Double;
    function GetCurrentPrevDekrHours: Double;
    function GetCurrentPrevDekrSum: Double;

    function GetNextIllDays: Double;
    function GetNextIllHours: Double;
    function GetNextIllSum: Double;
    function GetNextDekrDays: Double;
    function GetNextDekrHours: Double;
    function GetNextDekrSum: Double;

    function GetPeriodCurrentIllDays: Double;
    function GetPeriodCurrentIllHours: Double;
    function GetPeriodCurrentIllSum: Double;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;


    procedure GetIllEndDaysList;

    property  EndDaysList:TList read FEndDaysList write FEndDaysList;

    procedure AllIllSumList;
    procedure AllDekrSumList;
    procedure AllIllSumListByCode;

    procedure CurrentIllSumList;
    procedure CurrentIllSumList100;
    procedure CurrentDekrSumList;

    procedure PrevIllSumList;
    procedure PrevDekrSumList;

    procedure CurrentPrevIllSumList;
    procedure CurrentPrevDekrSumList;

    procedure NextIllSumList;
    procedure NextDekrSumList;

    procedure PeriodCurrentIllSumList;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;
    property WorkDate: TDateTime read FWorkDate write FWorkDate;

    property IllCode: String read FIllCode write SetIllCode;

    property xAccountList: TxAccountList read FxAccountList;

    property AllIllDays: Double read GetAllIllDays;
    property AllIllHours: Double read GetAllIllHours;
    property AllIllSum: Double read GetAllIllSum;

    property AllDekrDays: Double read GetAllDekrDays;
    property AllDekrHours: Double read GetAllDekrHours;
    property AllDekrSum: Double read GetAllDekrSum;

    property AllIllDaysByCode: Double read GetAllIllDaysByCode;
    property AllIllHoursByCode: Double read GetAllIllHoursByCode;
    property AllIllSumByCode: Double read GetAllIllSumByCode;

    property CurrentIllDays: Double read GetCurrentIllDays;
    property CurrentIllHours: Double read GetCurrentIllHours;
    property CurrentIllSum: Double read GetCurrentIllSum;

    property CurrentIllSum100: Double read GetCurrentIllSum100;

    property CurrentDekrDays: Double read GetCurrentDekrDays;
    property CurrentDekrHours: Double read GetCurrentDekrHours;
    property CurrentDekrSum: Double read GetCurrentDekrSum;

    property PrevIllDays: Double read GetPrevIllDays;
    property PrevIllHours: Double read GetPrevIllHours;
    property PrevIllSum: Double read GetPrevIllSum;
    property PrevDekrDays: Double read GetPrevDekrDays;
    property PrevDekrHours: Double read GetPrevDekrHours;
    property PrevDekrSum: Double read GetPrevDekrSum;

    property CurrentPrevIllDays: Double read GetPrevIllDays;
    property CurrentPrevIllHours: Double read GetPrevIllHours;
    property CurrentPrevIllSum: Double read GetPrevIllSum;
    property CurrentPrevDekrDays: Double read GetPrevDekrDays;
    property CurrentPrevDekrHours: Double read GetPrevDekrHours;
    property CurrentPrevDekrSum: Double read GetPrevDekrSum;

    property NextIllDays: Double read GetNextIllDays;
    property NextIllHours: Double read GetNextIllHours;
    property NextIllSum: Double read GetNextIllSum;
    property NextDekrDays: Double read GetNextDekrDays;
    property NextDekrHours: Double read GetNextDekrHours;
    property NextDekrSum: Double read GetNextDekrSum;

    property PeriodCurrentIllDays: Double read GetPeriodCurrentIllDays;
    property PeriodCurrentIllHours: Double read GetPeriodCurrentIllHours;
    property PeriodCurrentIllSum: Double read GetPeriodCurrentIllSum;
  end;

type
  TxAccFormula = class(TComponent)
  private
    FYearForm: TTable;

    FFormulaType: TFormulaType;
    FFormula: String;
    FAccName: String;

    (* Структура начислений *)
    FxAccountList: TxAccountList;

    function GetFormulaTypeKey: Integer;

    procedure SetFormulaType(Value: TFormulaType);
    procedure SetFormulaTypeKey(Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property FormulaType: TFormulaType read FFormulaType write SetFormulaType;
    property FormulaTypeKey: Integer read GetFormulaTypeKey write SetFormulaTypeKey;
    property AccName: String read FAccName;
    property Formula: String read FFormula;
  end;

  (* Индексация больничных *)
type
  TxIllIndSum = class(TComponent)
  private
    (* Период, за который выбираются индексации *)
    FWorkDate, FEnlistDate, FFromDate, FToDate: TDateTime;
    (* Структура начислений *)
    FxAccountList: TxAccountList;

    FIndIllD, FIndIllS: TTable;
    FEmplKey: LongInt;

    procedure SetActive(Value: Boolean);
    procedure SetEmplKey(Value: LongInt);
    procedure SetFromDate(Value: TDateTime);
    procedure SetToDate(Value: TDateTime);

    function GetActive: Boolean;

    function GetAllIndIllSum: Double;
    function GetAllIndDekrSum: Double;
    function GetCurrentIndIllSum: Double;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    (* Заполняет xAccountLis по дате зачисления за период (fromDate toDate)*)
    procedure GroupByEnlistDate;
    (* Заполняет xAccountLis по всем индексациям больничных за период (fromDate toDate)*)
    procedure CreateAllIndIll;
    (* Заполняет xAccountLis по всем индексациям декретных за период (fromDate toDate)*)
    procedure CreateAllIndDekr;

    procedure CreatePrevIndIll;

    property Active: Boolean read GetActive write SetActive;
    property EmplKey: LongInt read FEmplKey write SetEmplKey;
    property FromDate: TDateTime read FFromDate write SetFromDate;
    property ToDate: TDateTime read FToDate write SetToDate;
    property WorkDate: TDateTime read FWorkDate write FWorkDate;

    property AllIllIndSum: Double read GetAllIndIllSum;
    property AllDekrIndSum: Double read GetAllIndDekrSum;
    property CurrentIndIllSum: Double read GetCurrentIndIllSum;

    property xAccountList: TxAccountList read FxAccountList;
  end;

procedure Register;

implementation
uses
  Inform;

(* TxPayRecord *)
constructor TxPayRecord.Create;
begin
  FAccDate := Now;
  FEnlistDate := Now;
  FAccName := '';
  FDays := 0;
  FHours := 0;
  FSum := 0;
end;

function TxPayRecord.GetAccYear: word;
var
  Day, Month: word;
begin
  DecodeDate(FAccDate, Result, Month, Day);
end;

function TxPayRecord.GetAccMonth: word;
var
  Day, Year: word;
begin
  DecodeDate(FAccDate, Year, Result, Day);
end;

function TxPayRecord.GetEnlistYear: word;
var
  Day, Month: word;
begin
  DecodeDate(FEnlistDate, Result, Month, Day);
end;

function TxPayRecord.GetEnlistMonth: word;
var
  Day, Year: word;
begin
  DecodeDate(FEnlistDate, Year, Result, Day);
end;

function TxPayRecord.IsLess(Value: TxPayRecord): Boolean;
begin
  Result := False;
  if AccDate < Value.AccDate then Result := True
  else
    if AccDate = Value.AccDate then
      if EnlistDate <= Value.EnlistDate then
        Result := True;
end;

function TxPayRecord.EnlistDateEqual(Value: TxPayRecord): Boolean;
begin
  Result := (EnlistDate = Value.EnlistDate)
end;

procedure TxPayRecord.UpDate(Value: TxPayRecord);
begin
  Days := Days + Value.Days;
  Hours := Hours + Value.Hours;
  Sum := Sum + Value.Sum;
end;

{----  TxAccountList --------------}
constructor TxAccountList.Create;
begin
  FList := TList.Create;
end;

destructor TxAccountList.Destroy;
begin
  Clear;
  FList.Free;
end;

procedure TxAccountList.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    TxPayRecord(FList[I]).Free;
  FList.Clear;
end;

function TxAccountList.GetCount: Integer;
begin
  Result := FList.Count; 
end;

function TxAccountList.GetDays: Double;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FList.Count - 1 do
    Result := Result + TxPayRecord(FList[I]).Days;
end;

function TxAccountList.GetHours: Double;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FList.Count - 1 do
    Result := Result + TxPayRecord(FList[I]).Hours;
end;

function TxAccountList.GetSum: Double;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FList.Count - 1 do
    Result := Result + TxPayRecord(FList[I]).Sum;
end;

function TxAccountList.RowByIndex(I: Integer): TxPayRecord;
begin
  if I >= Count then
    raise Exception.Create('Ошибка диапазона!');
  Result := TxPayRecord(FList[I]); 
end;

procedure TxAccountList.Add(Value: TxPayRecord);
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    if Value.IsLess(TxPayRecord(FList[I])) then
    begin
      FLIst.Insert(I, Value);
      Exit;
    end;

  FList.Add(Value);
end;

procedure TxAccountList.AddByEnlistDate(Value: TxPayRecord);
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    if TxPayRecord(FList[I]).EnlistDateEqual(Value) then
    begin
      TxPayRecord(FList[I]).UpDate(Value);
      Exit;
    end;

  FList.Add(Value);
end;

{----  xMSalarySum --------------}
constructor TxMSalarySum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FMSalAcc := TTAble.Create(Self);
  FMSalAcc.DatabaseName := 'WAGE';
  FMSalAcc.Name := 'MSalAcc';
  FMSalAcc.TableName := 'MSalAcc';
  FMSalAcc.IndexFieldNames := 'EmplKey;MSalDate';

  FWorkDate := Now;
  FEmplKey := -1;

  FExist := False;
  ReadProperties;
end;

destructor TxMSalarySum.Destroy;
begin
  if Assigned(FMSalAcc) then FMSalAcc.Free;
  inherited Destroy;
end;

function TxMSalarySum.GetActive: Boolean;
begin
  Result := FMSalAcc.Active;
end;

procedure TxMSalarySum.ReadProperties;
begin
  if FExist then
  begin
    FWorkDays := FMSalAcc.FieldByName('MSalDay').AsInteger;
    FWorkHours := FMSalAcc.FieldByName('MSalHour').AsFloat;
    FWorkSum := FMSalAcc.FieldByName('MSalSum').AsFloat -
      FMSalAcc.FieldByName('MSalHolidSum').AsFloat;

    FHoliDays := FMSalAcc.FieldByName('MSalHoliDay').AsInteger;
    FHoliHours := FMSalAcc.FieldByName('MSalHoliHour').AsFloat;
    FHoliSum := FMSalAcc.FieldByName('MSalHolidSum').AsFloat;
  end
  else
  begin
    FWorkDays := 0;
    FWorkHours := 0;
    FWorkSum := 0;
    FHoliDays := 0;
    FHoliHours := 0;
    FHoliSum := 0;
  end;
end;

procedure TxMSalarySum.SetActive(Value: Boolean);
begin
  FMSalAcc.Active := Value;
  if not Value then
  begin
    FEmplKey := -1;
    FExist := False;
    ReadProperties;
  end;
end;

procedure TxMSalarySum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := -1;
  FExist := False;
  if Active then
  begin
    FEmplKey := Value;
    FExist := FMSalAcc.FindKey([FEmplKey, FWorkDate]);
  end;

  ReadProperties;
end;

procedure TxMSalarySum.SetWorkDate(Value: TDateTime);
begin
  FWorkDate := Value;
  FExist := False;
  if Active then
    FExist := FMSalAcc.FindKey([FEmplKey, FWorkDate]);

  ReadProperties;
end;


{----  TxTimePaySum --------------}
constructor TxTimePaySum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FTimePay := TTAble.Create(Self);
  FTimePay.DatabaseName := 'WAGE';
  FTimePay.Name := 'TimePay';
  FTimePay.TableName := 'TimePay';
  FTimePay.IndexFieldNames := 'EmplKey;TimePayDate';

  FWorkDate := Now;
  FEmplKey := -1;

  FExist := False;

  ReadProperties;
end;

destructor TxTimePaySum.Destroy;
begin
  if Assigned(FTimePay) then FTimePay.Free;
  inherited Destroy;
end;

function TxTimePaySum.GetActive: Boolean;
begin
  Result := FTimePay.Active;
end;

procedure TxTimePaySum.ReadProperties;
begin
  if FExist then
  begin
    FWorkDays := FTimePay.FieldByName('TimePayDay').AsInteger;
    FWorkHours := FTimePay.FieldByName('TimePayHour').AsFloat;
    FWorkSum := FTimePay.FieldByName('TimePaySum').AsFloat -
      FTimePay.FieldByName('HolidSum').AsFloat -
      FTimePay.FieldByName('NightSum').AsFloat -
      FTimePay.FieldByName('OverTime1Sum').AsFloat -
      FTimePay.FieldByName('OverTime2Sum').AsFloat;

    FHoliDays := FTimePay.FieldByName('TimePayHoliDay').AsInteger;
    FHoliHours := FTimePay.FieldByName('TimePayHoliHour').AsFloat;
    FHoliSum := FTimePay.FieldByName('HolidSum').AsFloat;

    FNightHours := FTimePay.FieldByName('TimePayHoliDay').AsFloat;
    FNightSum := FTimePay.FieldByName('TimePayHoliHour').AsFloat;

    FNightHours := FTimePay.FieldByName('NightHour').AsFloat;
    FNightSum := FTimePay.FieldByName('NightSum').AsFloat;

    FOverTime1Hours := FTimePay.FieldByName('OverTime1').AsFloat;
    FOverTime1Sum := FTimePay.FieldByName('OverTime1Sum').AsFloat;

    FOverTime2Hours := FTimePay.FieldByName('OverTime2').AsFloat;
    FOverTime2Sum := FTimePay.FieldByName('OverTime2Sum').AsFloat;
  end                                
  else
  begin
    FWorkDays := 0;
    FWorkHours := 0;
    FWorkSum := 0;
    FHoliDays := 0;
    FHoliHours := 0;
    FHoliSum := 0;
    FNightHours := 0;
    FNightSum  := 0;
    FOverTime1Hours := 0;
    FOverTime1Sum := 0;
    FOverTime2Hours := 0;
    FOverTime2Sum := 0;
  end;
end;

procedure TxTimePaySum.SetActive(Value: Boolean);
begin
  FTimePay.Active := Value;
  if not Value then
  begin
    FEmplKey := -1;
    FExist := False;
    ReadProperties;
  end;
end;

procedure TxTimePaySum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := -1;
  FExist := False;
  if Active then
  begin
    FEmplKey := Value;
    FExist := FTimePay.FindKey([FEmplKey, FWorkDate]);
  end;

  ReadProperties;
end;

procedure TxTimePaySum.SetWorkDate(Value: TDateTime);
begin
  FWorkDate := Value;
  FExist := False;
  if Active then
    FExist := FTimePay.FindKey([FEmplKey, FWorkDate]);

  ReadProperties;
end;

{----  xSimpleOrderSum --------------}
constructor TxSimpleOrderSum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FSOrders := TTable.Create(Self);
  FSOrders.DatabaseName := 'WAGE';
  FSOrders.Name := 'SOrders';
  FSOrders.TableName := 'SOrders';
  FSOrders.IndexFieldNames := 'SOrderDate';

  FPiecWork := TTable.Create(Self);
  FPiecWork.DatabaseName := 'WAGE';
  FPiecWork.Name := 'PiecWork';
  FPiecWork.TableName := 'PiecWork';
  FPiecWork.IndexFieldNames := 'SOrderKey;EmplKey';

  FFromDate := Now;
  FToDate := Now;
  WorkDate := Now;

  FEmplKey := -1;

  FVarList := TStringList.Create;

  FxAccountList := TxAccountList.Create;
end;

destructor TxSimpleOrderSum.Destroy;
begin
  FxAccountList.Free;
  FVarList.Free;

  if Assigned(FSOrders) then FSOrders.Free;
  if Assigned(FPiecWork) then FPiecWork.Free;

  inherited Destroy;
end;

function TxSimpleOrderSum.GetActive: Boolean;
begin
  Result := (FSOrders.Active and FPiecWork.Active);
  FSOrders.SetRange([FFromDate], [FToDate]);
end;

procedure TxSimpleOrderSum.SetActive(Value: Boolean);
begin
  FSOrders.Active := Value;
  FPiecWork.Active := Value;
end;

procedure TxSimpleOrderSum.SetFromDate(Value: TDateTime);
begin
  FSorders.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxSimpleOrderSum.SetToDate(Value: TDateTime);
begin
  FSorders.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

(* Заполнить список начислений за отработанное *)
procedure TxSimpleOrderSum.CreateWorkSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FSOrders.First;
  while not FSOrders.EOF do
  begin
    if FPiecWork.FindKey([FSOrders.FieldByName('SOrderKey').AsInteger, FEmplKey]) then
    begin
      xPayRecord := TxPayRecord.Create;

      xPayRecord.AccDate := WorkDate;
      xPayRecord.EnlistDate := WorkDate;
      xPayRecord.AccName := FSOrders.FieldByName('WorkName').AsString;
      xPayRecord.Days := FPiecWork.FieldByName('PWDay').AsInteger;
      xPayRecord.Hours := FPiecWork.FieldByName('PWHour').AsFloat;
      xPayRecord.Sum := FPiecWork.FieldByName('WorkSum').AsFloat;

      FxAccountList.Add(xPayRecord);
    end;

    FSOrders.Next;
  end;
end;

(* кол-во дней *)
function TxSimpleOrderSum.GetWorkDays: Double;
begin
  Result := 0;
  CreateWorkSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxSimpleOrderSum.GetWorkHours: Double;
begin
  Result := 0;
  CreateWorkSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxSimpleOrderSum.GetWorkSum: Double;
begin
  Result := 0;
  CreateWorkSumList;
  Result := FxAccountList.Sum;
end;

(* Заполнить список начислений за отработанное *)
procedure TxSimpleOrderSum.CreateHolidSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FSOrders.First;
  while not FSOrders.EOF do
  begin
    if FPiecWork.FindKey([FSOrders.FieldByName('SOrderKey').AsInteger, FEmplKey]) then
    begin
      xPayRecord := TxPayRecord.Create;

      xPayRecord.AccDate := WorkDate;
      xPayRecord.EnlistDate := WorkDate;
      xPayRecord.AccName := 'Праздничные по наряду';
      xPayRecord.Days := FPiecWork.FieldByName('PWHoliDay').AsInteger;
      xPayRecord.Hours := FPiecWork.FieldByName('PWHoliHour').AsFloat;
      xPayRecord.Sum := FPiecWork.FieldByName('HolidSum').AsFloat;

      FxAccountList.Add(xPayRecord);
    end;

    FSOrders.Next;
  end;
end;

(* кол-во дней *)
function TxSimpleOrderSum.GetHoliDays: Double;
begin
  Result := 0;
  CreateHolidSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxSimpleOrderSum.GetHoliHours: Double;
begin
  Result := 0;
  CreateHolidSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxSimpleOrderSum.GetHoliSum: Double;
begin
  Result := 0;
  CreateHolidSumList;
  Result := FxAccountList.Sum;
end;

(* Заполнить список дополнительных начислений *)
procedure TxSimpleOrderSum.CreateAddPaySumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FSOrders.First;
  while not FSOrders.EOF do
  begin
    if FPiecWork.FindKey([FSOrders.FieldByName('SOrderKey').AsInteger, FEmplKey]) then
    begin
      xPayRecord := TxPayRecord.Create;

      xPayRecord.AccDate := WorkDate;
      xPayRecord.EnlistDate := WorkDate;
      xPayRecord.AccName := 'Доплата по наряду';
      xPayRecord.Sum := FPiecWork.FieldByName('AddPaySum').AsFloat;

      FxAccountList.Add(xPayRecord);
    end;

    FSOrders.Next;
  end;
end;

(* сумма *)
function TxSimpleOrderSum.GetAddPaySum: Double;
begin
  Result := 0;
  CreateAtherSumList;
  Result := FxAccountList.Sum;
end;

(* Заполнить список прочих начислений *)
procedure TxSimpleOrderSum.CreateAtherSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FSOrders.First;
  while not FSOrders.EOF do
  begin
    if FPiecWork.FindKey([FSOrders.FieldByName('SOrderKey').AsInteger, FEmplKey]) then
    begin
      xPayRecord := TxPayRecord.Create;

      xPayRecord.AccDate := WorkDate;
      xPayRecord.EnlistDate := WorkDate;
      xPayRecord.AccName := 'Прочие суммы';
      xPayRecord.Sum := FPiecWork.FieldByName('AtherSum').AsFloat;

      FxAccountList.Add(xPayRecord);
    end;

    FSOrders.Next;
  end;
end;

(* сумма *)
function TxSimpleOrderSum.GetAtherSum: Double;
begin
  Result := 0;
  CreateAtherSumList;
  Result := FxAccountList.Sum;
end;

(* Заполнить список переменных, которые используются *)
procedure TxSimpleOrderSum.FillVarList;
var
  xFromDate, xToDate: TDateTime;
  S: String;
  P: Integer;
begin
  FVarList.Clear;

  xFromDate := FromDate;
  xToDate := ToDate;

  try
    FromDate := 0;

    FSOrders.First;
    while not FSOrders.EOF do
    begin
      S := AnsiUpperCase(FSOrders.FieldByName('Variable').AsString);
      if Length(S) <> 0 then
        if not FVarList.Find(S, P) then
          FVarList.Add(S);
      FSOrders.Next;
    end;
  finally
    FromDate := xFromDate;
  end;
end;

(* Получить сумму, начисленную работникам по нарядам, соответствующим данной переменной *)
function TxSimpleOrderSum.GetSumByVariable(Value: String): Double;
begin
  Result := 0;
  if Length(Value) = 0 then Exit;

  FSOrders.First;
  while not FSOrders.EOF do
  begin
    if AnsiCompareText(Value, FSOrders.FieldByName('Variable').AsString) = 0 then
      if FPiecWork.FindKey([FSOrders.FieldByName('SOrderKey').AsInteger, FEmplKey]) then
        Result := Result + FPiecWork.FieldByName('WorkSum').AsFloat;
    FSOrders.Next;
  end;
end;

{----  xKTUOrderSum --------------}
constructor TxKTUOrderSum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FKTUVed := TTable.Create(Self);
  FKTUVed.DatabaseName := 'WAGE';
  FKTUVed.Name := 'KTUVed';
  FKTUVed.TableName := 'KTUVed';
  FKTUVed.IndexFieldNames := 'VedDate';

  FKTUStaff := TTable.Create(Self);
  FKTUStaff.DatabaseName := 'WAGE';
  FKTUStaff.Name := 'KTUStaff';
  FKTUStaff.TableName := 'KTUStaff';
  FKTUStaff.IndexFieldNames := 'VedKey;EmplKey';

  FFromDate := Now;
  FToDate := Now;

  FAddPayOrder := 0;

  FEmplKey := -1;

end;

destructor TxKTUOrderSum.Destroy;
begin
  if Assigned(FKTUVed) then FKTUVed.Free;
  if Assigned(FKTUStaff) then FKTUStaff.Free;

  inherited Destroy;
end;

function TxKTUOrderSum.GetActive: Boolean;
begin
  Result := (FKTUVed.Active and FKTUStaff.Active);
  FKTUVed.SetRange([FFromDate], [FToDate]);
end;

function TxKTUOrderSum.GetKTUValue(What: Integer): Double;
begin
  Result := 0;
  FKTUVed.First;
  while not FKTUVed.EOF do
  begin
    if FKTUVed.FieldByName('ClacKey').AsInteger <> 4 then
    begin
      FKTUStaff.SetRange
        ([FKTUVed.FieldByName('VedKey').AsInteger, FEmplKey],
         [FKTUVed.FieldByName('VedKey').AsInteger, FEmplKey]);

      FKTUStaff.First;
      while not FKTUStaff.EOF do
      begin
        case What of
          0: (* Дни *)
            Result := Result + FKTUStaff.FieldByName('Days').AsInteger;
          1: (* Часы *)
            Result := Result + FKTUStaff.FieldByName('Hours').AsFloat;
          2: (* Сумма *)
            Result := Result + FKTUStaff.FieldByName('TariffSalary').AsFloat;
        end;
        FKTUStaff.Next;
      end;

      FKTUStaff.CancelRange;
    end;
    FKTUVed.Next;
  end;
end;

procedure TxKTUOrderSum.SetActive(Value: Boolean);
begin
  FKTUVed.Active := Value;
  FKTUStaff.Active := Value;

  if not Value then
    FEmplKey := -1;
end;

procedure TxKTUOrderSum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := -1;
  if Active then FEmplKey := Value;
end;

procedure TxKTUOrderSum.SetFromDate(Value: TDateTime);
begin
  if Active then
  begin
    FKTUVed.SetRange([Value], [FToDate]);
    FFromDate := Value;
  end;
end;

procedure TxKTUOrderSum.SetToDate(Value: TDateTime);
begin
  if Active then
  begin
    FExist := True;
    FKTUVed.SetRange([FFromDate], [Value]);
    FToDate := Value;
  end;
end;

(* Отработано дней *)
function TxKTUOrderSum.GetWorkDays: Integer;
begin
  Result := Round(GetKTUValue(0));
end;

(* Отработано часов *)
function TxKTUOrderSum.GetWorkHours: Double;
begin
  Result := GetKTUValue(1);
end;

(* Сумма за отработанное время *)
function TxKTUOrderSum.GetWorkSum: Double;
begin
  Result := GetKTUValue(2);
end;

{----  xHolidPaySum -------------}
constructor TxHolidPaySum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FHolidPay := TTable.Create(Self);
  FHolidPay.DatabaseName := 'WAGE';
  FHolidPay.Name := 'HolidPay';
  FHolidPay.TableName := 'HolidPay';
  FHolidPay.IndexFieldNames := 'HolidKey';

  FHolidStr := TTable.Create(Self);
  FHolidStr.DatabaseName := 'WAGE';
  FHolidStr.Name := 'HolidStr';
  FHolidStr.TableName := 'HolidStr';
  FHolidStr.IndexFieldNames := 'EmplKey;AccDate';

  FWorkDate := Now;
  FFromDate := Now;
  FToDate := Now;
  FEmplKey := -1;
  FExist := False;

  FxAccountList := TxAccountList.Create;
end;

destructor TxHolidPaySum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FHolidPay) then FHolidPay.Free;
  if Assigned(FHolidStr) then FHolidStr.Free;

  inherited Destroy;
end;

function TxHolidPaySum.GetActive: Boolean;
begin
  Result := (FHolidPay.Active and FHolidStr.Active);
end;

procedure TxHolidPaySum.SetActive(Value: Boolean);
begin
  FHolidPay.Active := Value;
  FHolidStr.Active := Value;
end;

procedure TxHolidPaySum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxHolidPaySum.SetFromDate(Value: TDateTime);
begin
  FFromDate := Value;
end;

procedure TxHolidPaySum.SetToDate(Value: TDateTime);
begin
  FToDate := Value;
end;

{-------------------- Отпуска, начисленные за период от FromDate до ToDate }
procedure TxHolidPaySum.AllHolidSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;AccDate';
  FHolidStr.Open;
  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
      if not FHolidPay.FieldByName('Comp').AsBoolean then
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
        xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
        xPayRecord.AccName := 'Отпускные';
        xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
        xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

        FxAccountList.Add(xPayRecord);
      end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* кол-во дней *)
function TxHolidPaySum.GetAllHoliDays: Double;
begin
  Result := 0;
  AllHolidSumList;
  Result := FxAccountList.Days;
end;

(* Сумма *)
function TxHolidPaySum.GetAllHolidSum: Double;
begin
  Result := 0;
  AllHolidSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Компенсации, начисленные за период от FromDate до ToDate }
procedure TxHolidPaySum.AllCompSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;AccDate';
  FHolidStr.Open;
  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
      if FHolidPay.FieldByName('Comp').AsBoolean then
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
        xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
        xPayRecord.AccName := 'Компенсация';
        xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
        xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

        FxAccountList.Add(xPayRecord);
      end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* кол-во дней *)
function TxHolidPaySum.GetAllCompDays: Double;
begin
  Result := 0;
  AllCompSumList;
  Result := FxAccountList.Days;
end;

(* сумма *)
function TxHolidPaySum.GetAllCompSum: Double;
begin
  Result := 0;
  AllCompSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Отпуска, приходящиеся за период от FromDate до ToDate,
                      но начисленные в прошлых месяцах }
procedure TxHolidPaySum.PrevHolidSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;EnlistDate';
  FHolidStr.Open;

  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    if FHolidStr.FieldByName('AccDate').AsDateTime <
      FHolidStr.FieldByName('EnlistDate').AsDateTime then
      if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
        if not FHolidPay.FieldByName('Comp').AsBoolean then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
          xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Отпускные';
          xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
          xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

          FxAccountList.Add(xPayRecord);
        end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* Кол-во дней *)
function TxHolidPaySum.GetPrevHoliDays: Double;
begin
  Result := 0;
  PrevHolidSumList;
  Result := FxAccountList.Days;
end;

(* Сумма *)
function TxHolidPaySum.GetPrevHolidSum: Double;
begin
  Result := 0;
  PrevHolidSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Компенсации, приходящиеся за период от FromDate до ToDate,
                      но начисленные в прошлых месяцах }
procedure TxHolidPaySum.PrevCompSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;EnlistDate';
  FHolidStr.Open;

  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    if FHolidStr.FieldByName('AccDate').AsDateTime <
      FHolidStr.FieldByName('EnlistDate').AsDateTime then
      if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
        if FHolidPay.FieldByName('Comp').AsBoolean then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
          xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Компенсация';
          xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
          xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

          FxAccountList.Add(xPayRecord);
        end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* Кол-во дней *)
function TxHolidPaySum.GetPrevCompDays: Double;
begin
  Result := 0;
  PrevCompSumList;
  Result := FxAccountList.Days;
end;

(* Сумма *)
function TxHolidPaySum.GetPrevCompSum: Double;
begin
  Result := 0;
  PrevCompSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Отпуска, приходящиеся за период от FromDate до ToDate и
                      ограниченные планкой WorkDate}
procedure TxHolidPaySum.CurrentHolidSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;EnlistDate';
  FHolidStr.Open;

  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    if FHolidStr.FieldByName('AccDate').AsDateTime <= FWorkDate then
      if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
        if not FHolidPay.FieldByName('Comp').AsBoolean then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
          xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Отпускные';
          xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
          xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

          FxAccountList.Add(xPayRecord);
        end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* кол-во дней *)
function TxHolidPaySum.GetCurrentHoliDays: Double;
begin
  Result := 0;
  CurrentHolidSumList;
  Result := FxAccountList.Days;
end;

(* сумма  *)
function TxHolidPaySum.GetCurrentHolidSum: Double;
begin
  Result := 0;
  CurrentHolidSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Компенсация, приходящиеся за период от FromDate до ToDate и
                      ограниченные планкой WorkDate}
procedure TxHolidPaySum.CurrentCompSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;EnlistDate';
  FHolidStr.Open;

  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    if FHolidStr.FieldByName('AccDate').AsDateTime <= WorkDate then
      if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
        if FHolidPay.FieldByName('Comp').AsBoolean then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
          xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Компенсация';
          xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
          xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

          FxAccountList.Add(xPayRecord);
        end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* Кол-во дней *)
function TxHolidPaySum.GetCurrentCompDays: Double;
begin
  Result := 0;
  CurrentCompSumList;
  Result := FxAccountList.Days;
end;

(* сумма *)
function TxHolidPaySum.GetCurrentCompSum: Double;
begin
  Result := 0;
  CurrentCompSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Отпуска, начисленные c FromDate по ToDate
          и приходящиеся на текущий месяц }
procedure TxHolidPaySum.OnlyCurrentHolidSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;AccDate';
  FHolidStr.Open;

  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    if FHolidStr.FieldByName('AccDate').AsDateTime <= WorkDate then
      if FHolidStr.FieldByName('EnlistDate').AsDateTime =
        FHolidStr.FieldByName('AccDate').AsDateTime then
          if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
            if not FHolidPay.FieldByName('Comp').AsBoolean then
            begin
              xPayRecord := TxPayRecord.Create;
              xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
              xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
              xPayRecord.AccName := 'Отпускные';
              xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
              xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

              FxAccountList.Add(xPayRecord);
            end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* кол-во дней *)
function TxHolidPaySum.GetOnlyCurrentHoliDays: Double;
begin
  Result := 0;
  OnlyCurrentHolidSumList;
  Result := FxAccountList.Days;
end;

(* сумма  *)
function TxHolidPaySum.GetOnlyCurrentHolidSum: Double;
begin
  Result := 0;
  OnlyCurrentHolidSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Компенсация, приходящиеся за период от FromDate до ToDate и
                      приходящиеся на месяц начисления}
procedure TxHolidPaySum.OnlyCurrentCompSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;AccDate';
  FHolidStr.Open;

  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    if FHolidStr.FieldByName('AccDate').AsDateTime <= WorkDate then
      if FHolidStr.FieldByName('EnlistDate').AsDateTime =
        FHolidStr.FieldByName('AccDate').AsDateTime then
          if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
            if FHolidPay.FieldByName('Comp').AsBoolean then
            begin
              xPayRecord := TxPayRecord.Create;
              xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
              xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
              xPayRecord.AccName := 'Компенсация';
              xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
              xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

              FxAccountList.Add(xPayRecord);
            end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* Кол-во дней *)
function TxHolidPaySum.GetOnlyCurrentCompDays: Double;
begin
  Result := 0;
  OnlyCurrentCompSumList;
  Result := FxAccountList.Days;
end;

(* сумма *)
function TxHolidPaySum.GetOnlyCurrentCompSum: Double;
begin
  Result := 0;
  OnlyCurrentCompSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Отпуска, приходящиеся за период от FromDate до ToDate, но
                      приходящиеся за следуюшие месяцы}
procedure TxHolidPaySum.NextHolidSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;AccDate';
  FHolidStr.Open;

  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    (* приходится на следующие месяццы *)
    if FHolidStr.FieldByName('EnlistDate').AsDateTime >
      FHolidStr.FieldByName('AccDate').AsDateTime then
        if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
          (* Только отпуска *)
          if not FHolidPay.FieldByName('Comp').AsBoolean then
          begin
            xPayRecord := TxPayRecord.Create;
            xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
            xPayRecord.AccName := 'Отпускные';
            xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
            xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
            xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

            FxAccountList.Add(xPayRecord);
          end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* кол-во дней *)
function TxHolidPaySum.GetNextHoliDays: Double;
begin
  Result := 0;
  NextHolidSumList;
  Result := FxAccountList.Days;
end;

(* суииа *)
function TxHolidPaySum.GetNextHolidSum: Double;
begin
  Result := 0;
  NextHolidSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Компенсации, приходящиеся за период от FromDate до ToDate, но
                      приходящиеся за следуюшие месяцы}
procedure TxHolidPaySum.NextCompSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FHolidStr.Close;
  FHolidStr.IndexFieldNames := 'EmplKey;AccDate';
  FHolidStr.Open;

  FHolidStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FHolidStr.First;
  while not FHolidStr.EOF do
  begin
    (* приходится на следующие месяццы *)
    if FHolidStr.FieldByName('EnlistDate').AsDateTime >
      FHolidStr.FieldByName('AccDate').AsDateTime then
        if FHolidPay.FindKey([FHolidStr.FieldByName('HolidKey').AsInteger]) then
          (* Только компенсация *)
          if FHolidPay.FieldByName('Comp').AsBoolean then
          begin
            xPayRecord := TxPayRecord.Create;
            xPayRecord.AccDate := FHolidStr.FieldByName('AccDate').AsDateTime;
            xPayRecord.EnlistDate := FHolidStr.FieldByName('EnlistDate').AsDateTime;
            xPayRecord.AccName := 'Компенсация';
            xPayRecord.Days := FHolidStr.FieldByName('HoliDay').AsInteger;
            xPayRecord.Sum := FHolidStr.FieldByName('HolidSum').AsFloat;

            FxAccountList.Add(xPayRecord);
          end;
    FHolidStr.Next;
  end;
  FHolidStr.CancelRange;
end;

(* Кол-во дней *)
function TxHolidPaySum.GetNextCompDays: Double;
begin
  Result := 0;
  NextCompSumList;
  Result := FxAccountList.Days;
end;



(* Сумма *)
function TxHolidPaySum.GetNextCompSum: Double;
begin
  Result := 0;
  NextCompSumList;
  Result := FxAccountList.Sum;
end;

{----  xIllPaySum -------------}
constructor TxIllPaySum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FIllPay := TTable.Create(Self);
  FIllPay.DatabaseName := 'WAGE';
  FIllPay.Name := 'IllPay';
  FIllPay.TableName := 'IllPay';
  FIllPay.IndexFieldNames := 'IllKey;EmplKey;IllDate';

  FIllStr := TTable.Create(Self);
  FIllStr.DatabaseName := 'WAGE';
  FIllStr.Name := 'IllStr';
  FIllStr.TableName := 'IllStr';
  FIllStr.IndexFieldNames := 'EmplKey;AccDate';

  FWorkDate := Now;
  FFromDate := Now;
  FToDate := Now;
  FEmplKey := -1;
  FExist := False;

  FIllCode := '';

  FxAccountList := TxAccountList.Create;
  FEndDaysList := TList.Create;
end;

destructor TxIllPaySum.Destroy;
begin
  FxAccountList.Free;
  FEndDaysList.Free;
  if Assigned(FIllPay) then FIllPay.Free;
  if Assigned(FIllStr) then FIllStr.Free;

  inherited Destroy;
end;

function TxIllPaySum.GetActive: Boolean;
begin
  Result := (FIllPay.Active and FIllStr.Active);
end;

procedure TxIllPaySum.SetActive(Value: Boolean);
begin
  FIllPay.Active := Value;
  FIllStr.Active := Value;
end;

procedure TxIllPaySum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxIllPaySum.SetFromDate(Value: TDateTime);
begin
  FFromDate := Value;
end;

procedure TxIllPaySum.SetToDate(Value: TDateTime);
begin
  FToDate := Value;
end;

procedure TxIllPaySum.SetIllCode(Value: String);
begin
  FIllCode := Value;
end;

{-------------------- Больничные, начисленные за период от FromDate до ToDate }
procedure TxIllPaySum.AllIllSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;AccDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
      if FIllPay.FieldByName('Dekret').AsString <> '+' then
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
        xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
        xPayRecord.AccName := 'Больничный';
        xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
        xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
        xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

        FxAccountList.Add(xPayRecord);
      end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetAllIllDays: Double;
begin
  Result := 0;
  AllIllSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxIllPaySum.GetAllIllHours: Double;
begin
  Result := 0;
  AllIllSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxIllPaySum.GetAllIllSum: Double;
begin
  Result := 0;
  AllIllSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Декретные, начисленные за период от FromDate до ToDate }
procedure TxIllPaySum.AllDekrSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;AccDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
      if FIllPay.FieldByName('Dekret').AsString = '+' then
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
        xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
        xPayRecord.AccName := 'Декретный';
        xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
        xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
        xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

        FxAccountList.Add(xPayRecord);
      end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetAllDekrDays: Double;
begin
  Result := 0;
  AllDekrSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxIllPaySum.GetAllDekrHours: Double;
begin
  Result := 0;
  AllDekrSumList;
  Result := FxAccountList.Hours;
end;

(* Сумма *)
function TxIllPaySum.GetAllDekrSum: Double;
begin
  Result := 0;
  AllDekrSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Больничные, начисленные за период от FromDate до ToDate,
  соответсвуюие заданной категории }
procedure TxIllPaySum.AllIllSumListByCode;
var
  xPayRecord: TxPayRecord;
  Ok: Boolean;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;AccDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin

    if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
    begin
      if FIllPay.FieldByName('Dekret').AsString = IllCode then
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
        xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
        xPayRecord.AccName := 'Больничный';
        xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
        xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
        xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

        FxAccountList.Add(xPayRecord);
      end;
    end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetAllIllDaysByCode: Double;
begin
  Result := 0;
  AllIllSumListByCode;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxIllPaySum.GetAllIllHoursByCode: Double;
begin
  Result := 0;
  AllIllSumListByCode;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxIllPaySum.GetAllIllSumByCode: Double;
begin
  Result := 0;
  AllIllSumListByCode;
  Result := FxAccountList.Sum;
end;

{-------------------- Больничные, приходящиеся за период от FromDate до ToDate
                      и начисленные до WorkDate }
procedure TxIllPaySum.CurrentIllSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;EnlistDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);


  FIllStr.First;
  while not FIllStr.EOF do
  begin

    if FIllStr.FieldByName('AccDate').AsDateTime <= WorkDate then
    begin

      if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
      begin

        if FIllPay.FieldByName('Dekret').AsString <> '+' then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
          xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Больничный';
          xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
          xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
          xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

          FxAccountList.Add(xPayRecord);
        end;
      end;
    end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetCurrentIllDays: Double;
begin
  Result := 0;
  CurrentIllSumList;
  Result := FxAccountList.Days;
end;

(* список последних дней *)
procedure TxIllPaySum.GetIllEndDaysList;
var
  i: integer;
  tmp: TxDate;
begin
  FEndDaysList.Clear;
  CurrentIllSumList;
  for I := 0 to xAccountList.FList.Count - 1 do
  begin
    tmp := TxDate.Create;
    tmp.FDate := TxPayRecord(xAccountList.FList.Items[I]).EnlistDate;
    FEndDaysList.Add(Tmp);
  end;
end;


(* кол-во часов *)
function TxIllPaySum.GetCurrentIllHours: Double;
begin
  Result := 0;
  CurrentIllSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxIllPaySum.GetCurrentIllSum: Double;
begin
  Result := 0;
  CurrentIllSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Больничные, приходящиеся за период от FromDate до ToDate
                      и начисленные до WorkDate оплачиваемые в размере 100 %}
procedure TxIllPaySum.CurrentIllSumList100;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;EnlistDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if (FIllStr.FieldByName('AccDate').AsDateTime <= WorkDate) and
      (FIllStr.FieldByName('Percent').AsFloat = 100) then
      if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
        if FIllPay.FieldByName('Dekret').AsString <> '+' then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
          xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Больничный';
          xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
          xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
          xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

          FxAccountList.Add(xPayRecord);
        end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* сумма *)
function TxIllPaySum.GetCurrentIllSum100: Double;
begin
  Result := 0;
  CurrentIllSumList100;
  Result := FxAccountList.Sum;
end;

{-------------------- Декретные, приходящиеся за период от FromDate до ToDate
                      и начисленные до WorkDate }
procedure TxIllPaySum.CurrentDekrSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;EnlistDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if FIllStr.FieldByName('EnlistDate').AsDateTime <= WorkDate then
      if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
        if FIllPay.FieldByName('Dekret').AsString = '+' then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
          xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Декретный';
          xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
          xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
          xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

          FxAccountList.Add(xPayRecord);
        end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetCurrentDekrDays: Double;
begin
  Result := 0;
  CurrentDekrSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxIllPaySum.GetCurrentDekrHours: Double;
begin
  Result := 0;
  CurrentDekrSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxIllPaySum.GetCurrentDekrSum: Double;
begin
  Result := 0;
  CurrentDekrSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Больничные, начисленные за период от FromDate до ToDate
                      и приходящиеся на предыдущие месяцы }
procedure TxIllPaySum.PrevIllSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;AccDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if FIllStr.FieldByName('EnlistDate').AsDateTime <
      FIllStr.FieldByName('AccDate').AsDateTime then
      if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
        if FIllPay.FieldByName('Dekret').AsString <> '+' then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
          xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Больничный';
          xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
          xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
          xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

          FxAccountList.Add(xPayRecord);
       end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* дней больничного, приходящихся на период до FromDate *)
function TxIllPaySum.GetPrevIllDays: Double;
begin
  Result := 0;
  PrevIllSumList;
  Result := FxAccountList.Days;
end;

(* часов больничного, приходящихся на период до FromDate *)
function TxIllPaySum.GetPrevIllHours: Double;
begin
  Result := 0;
  PrevIllSumList;
  Result := FxAccountList.Hours;
end;

function TxIllPaySum.GetPrevIllSum: Double;
begin
  Result := 0;
  PrevIllSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Декретные, начисленные за период от FromDate до ToDate
                      и приходящиеся на предыдущие месяцы }
procedure TxIllPaySum.PrevDekrSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;AccDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FFromDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if FIllStr.FieldByName('EnlistDate').AsDateTime <
      FIllStr.FieldByName('AccDate').AsDateTime then
        if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
          if FIllPay.FieldByName('Dekret').AsString = '+' then
          begin
            xPayRecord := TxPayRecord.Create;
            xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
            xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
            xPayRecord.AccName := 'Декретный';
            xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
            xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
            xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

            FxAccountList.Add(xPayRecord);
          end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetPrevDekrDays: Double;
begin
  Result := 0;
  PrevDekrSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxIllPaySum.GetPrevDekrHours: Double;
begin
  Result := 0;
  PrevDekrSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxIllPaySum.GetPrevDekrSum: Double;
begin
  Result := 0;
  PrevDekrSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Больничные, приходящиеся за период от FromDate до ToDate
                      и начисленные в предыдущие месяцы с верхней границей WorkDate}
procedure TxIllPaySum.CurrentPrevIllSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;EnlistDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if (FIllStr.FieldByName('EnlistDate').AsDateTime <
      FIllStr.FieldByName('AccDate').AsDateTime) and
      (FIllStr.FieldByName('AccDate').AsDateTime <= WorkDate) then

      if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
        if FIllPay.FieldByName('Dekret').AsString <> '+' then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
          xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Больничный';
          xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
          xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
          xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

          FxAccountList.Add(xPayRecord);
        end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetCurrentPrevIllDays: Double;
begin
  Result := 0;
  CurrentPrevIllSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxIllPaySum.GetCurrentPrevIllHours: Double;
begin
  Result := 0;
  CurrentPrevIllSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxIllPaySum.GetCurrentPrevIllSum: Double;
begin
  Result := 0;
  CurrentPrevIllSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Декретные, приходящиеся за период от FromDate до ToDate
                      и начисленные в предыдущие месяцы }
procedure TxIllPaySum.CurrentPrevDekrSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;EnlistDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FFromDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if FIllStr.FieldByName('EnlistDate').AsDateTime >
      FIllStr.FieldByName('AccDate').AsDateTime then
        if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
          if FIllPay.FieldByName('Dekret').AsString = '+' then
          begin
            xPayRecord := TxPayRecord.Create;
            xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
            xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
            xPayRecord.AccName := 'Декретный';
            xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
            xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
            xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

            FxAccountList.Add(xPayRecord);
          end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetCurrentPrevDekrDays: Double;
begin
  Result := 0;
  PrevDekrSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxIllPaySum.GetCurrentPrevDekrHours: Double;
begin
  Result := 0;
  PrevDekrSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxIllPaySum.GetCurrentPrevDekrSum: Double;
begin
  Result := 0;
  PrevDekrSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Больничные, начисленные за период от FromDate до ToDate
                      и приходящиеся на следующие месяцы }
procedure TxIllPaySum.NextIllSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;AccDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FFromDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if FIllStr.FieldByName('EnlistDate').AsDateTime >
      FIllStr.FieldByName('AccDate').AsDateTime then
        if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
          if FIllPay.FieldByName('Dekret').AsString <> '+' then
          begin
            xPayRecord := TxPayRecord.Create;
            xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
            xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
            xPayRecord.AccName := 'Больничный';
            xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
            xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
            xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

            FxAccountList.Add(xPayRecord);
          end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetNextIllDays: Double;
begin
  Result := 0;
  NextIllSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxIllPaySum.GetNextIllHours: Double;
begin
  Result := 0;
  NextIllSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxIllPaySum.GetNextIllSum: Double;
begin
  Result := 0;
  NextIllSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Декретные, начисленные за период от FromDate до ToDate
                      и приходящиеся на следующие месяцы }
procedure TxIllPaySum.NextDekrSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;AccDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FFromDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if FIllStr.FieldByName('EnlistDate').AsDateTime >
      FIllStr.FieldByName('AccDate').AsDateTime then
        if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
          if FIllPay.FieldByName('Dekret').AsString = '+' then
          begin
            xPayRecord := TxPayRecord.Create;
            xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
            xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
            xPayRecord.AccName := 'Декретный';
            xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
            xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
            xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

            FxAccountList.Add(xPayRecord);
          end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetNextDekrDays: Double;
begin
  Result := 0;
  NextDekrSumList;
  Result := FxAccountList.Days;
end;

(* часов декретного, приходящихся на период после FromDate *)
function TxIllPaySum.GetNextDekrHours: Double;
begin
  Result := 0;
  NextDekrSumList;
  Result := FxAccountList.Hours;
end;

(* сумма декретного, приходящихся на период после FromDate *)
function TxIllPaySum.GetNextDekrSum: Double;
begin
  Result := 0;
  NextDekrSumList;
  Result := FxAccountList.Sum;
end;

{-------------------- Больничные, начисленные за период от FromDate до ToDate
                      и приходящиеся на WorkDate }
procedure TxIllPaySum.PeriodCurrentIllSumList;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIllStr.Close;
  FIllStr.IndexFieldNames := 'EmplKey;AccDate';
  FIllStr.Open;
  FIllStr.SetRange([FEmplKey, FFromDate], [FEmplKey, FToDate]);

  FIllStr.First;
  while not FIllStr.EOF do
  begin
    if GetAccountDate(FIllStr.FieldByName('EnlistDate').AsDateTime) = WorkDate then
        if FIllPay.FindKey([FIllStr.FieldByName('IllKey').AsInteger]) then
          if FIllPay.FieldByName('Dekret').AsString <> '+' then
          begin
            xPayRecord := TxPayRecord.Create;
            xPayRecord.AccDate := FIllStr.FieldByName('AccDate').AsDateTime;
            xPayRecord.EnlistDate := FIllStr.FieldByName('EnlistDate').AsDateTime;
            xPayRecord.AccName := 'Больничный';
            xPayRecord.Days := FIllStr.FieldByName('IllDay').AsInteger;
            xPayRecord.Hours := FIllStr.FieldByName('IllHour').AsFloat;
            xPayRecord.Sum := FIllStr.FieldByName('IllSum').AsFloat;

            FxAccountList.Add(xPayRecord);
          end;
    FIllStr.Next;
  end;
  FIllStr.CancelRange;
end;

(* кол-во дней *)
function TxIllPaySum.GetPeriodCurrentIllDays: Double;
begin
  Result := 0;
  PeriodCurrentIllSumList;
  Result := FxAccountList.Days;
end;

(* кол-во часов *)
function TxIllPaySum.GetPeriodCurrentIllHours: Double;
begin
  Result := 0;
  PeriodCurrentIllSumList;
  Result := FxAccountList.Hours;
end;

(* сумма *)
function TxIllPaySum.GetPeriodCurrentIllSum: Double;
begin
  Result := 0;
  PeriodCurrentIllSumList;
  Result := FxAccountList.Sum;
end;

{ ------------------------ TAccFormula }
constructor TxAccFormula.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FYearForm := TTAble.Create(Self);
  FYearForm.DatabaseName := 'WAGE';
  FYearForm.Name := 'YearForm';
  FYearForm.TableName := 'YearForm';
  FYearForm.IndexFieldNames := 'FormKey';

  FFormulaType := ftUnknown;
  FFormula := '0';
  FAccName := 'Неизвестная формула!';
end;

destructor TxAccFormula.Destroy;
begin
  if Assigned(FYearForm) then FYearForm.Free;

  inherited Destroy;
end;

procedure TxAccFormula.SetFormulaType(Value: TFormulaType);
begin
  FYearForm.Open;
  if FYearForm.FindKey([Ord(Value)]) then
  begin
    case FYearForm.FieldByName('FormKey').AsInteger of
      1: FAccName := 'Больничные';
      2: FAccName := 'Отпуск';
      3: FAccName := 'Стаж';
      4: FAccName := 'В общем случае';
      5: FAccName := 'Годовые выплаты';
      6: FAccName := 'Индексация больничных';
    else
      raise Exception.Create('Неверный диапазон!')
    end;

    FFormula := FYearForm.FieldByName('Formula').AsString;
  end else
  begin
    FFormulaType := ftUnknown;
    FFormula := '0';
    FAccName := 'Неизвестная формула!';
  end;
end;

function TxAccFormula.GetFormulaTypeKey: Integer;
begin
  Result := Ord(FormulaType);
end;

procedure TxAccFormula.SetFormulaTypeKey(Value: Integer);
var
  X: TFormulaType;
begin
  X := ftUnknown;
  Inc(X, Value);

  FormulaType := X;
end;

{------ Индексация пособия по нетрудоспособности ------}
constructor TxIllIndSum.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FIndIllD := TTable.Create(Self);
  FIndIllD.DatabaseName := 'WAGE';
  FIndIllD.Name := 'IndIllD';
  FIndIllD.TableName := 'IndIllD';
  FIndIllD.IndexFieldNames := 'WorkDate';

  FIndIllS := TTable.Create(Self);
  FIndIllS.DatabaseName := 'WAGE';
  FIndIllS.Name := 'IndIllS';
  FIndIllS.TableName := 'IndIllS';
  FIndIllS.IndexFieldNames := 'IndIllKey;Emplkey;EnlistDate';

  FEnlistDate := Now; 
  FFromDate := Now;
  FToDate := Now;

  FEmplKey := -1;

  FxAccountList := TxAccountList.Create;
end;

destructor TxIllIndSum.Destroy;
begin
  FxAccountList.Free;

  if Assigned(FIndIllD) then FIndIllD.Free;
  if Assigned(FIndIllS) then FIndIllS.Free;

  inherited Destroy;
end;

function TxIllIndSum.GetActive: Boolean;
begin
  Result := (FIndIllD.Active and FIndIllS.Active);
  FIndIllD.SetRange([FFromDate], [FToDate]);
end;

procedure TxIllIndSum.SetActive(Value: Boolean);
begin
  FIndIllD.Active := Value;
  FIndIllS.Active := Value;
end;

procedure TxIllIndSum.SetEmplKey(Value: LongInt);
begin
  FEmplKey := Value;
end;

procedure TxIllIndSum.SetFromDate(Value: TDateTime);
begin
  FIndIllD.SetRange([Value], [FToDate]);
  FFromDate := Value;
end;

procedure TxIllIndSum.SetToDate(Value: TDateTime);
begin
  FIndIllD.SetRange([FFromDate], [Value]);
  FToDate := Value;
end;

(* Формирует структуру индексации больничных, начисленной за период с FromDate по ToDate *)
procedure TxIllIndSum.CreateAllIndIll;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIndIllD.First;
  while not FIndIllD.EOF do
  begin
    try
      FIndIllS.SetRange(
        [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey],
        [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey]);

      FIndIllS.First;
      while not FIndIllS.EOF do
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FIndIllD.FieldByName('WorkDate').AsDateTime;
        xPayRecord.AccName := 'Индексация больничного';
        xPayRecord.EnlistDate := FIndIllS.FieldByName('EnlistDate').AsDateTime;
        xPayRecord.Sum := FIndIllS.FieldByName('IndSum').AsFloat;

        FxAccountList.Add(xPayRecord);

        FIndIllS.Next;
      end;
    finally
      FIndIllS.CancelRange;
    end;
    FIndIllD.Next;
  end;
end;

function TxIllIndSum.GetAllIndIllSum: Double;
begin
  Result := 0;
  CreateAllIndIll;
  Result := FxAccountList.Sum;
end;

(* Индексации предшествующие FromDate *)
procedure TxIllIndSum.CreatePrevIndIll;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIndIllD.First;
  while not FIndIllD.EOF do
  begin
    try
      FIndIllS.SetRange(
        [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey],
        [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey]);

      FIndIllS.First;
      while not FIndIllS.EOF do
      begin
        (* Индексация *)
        if FIndIllS.FieldByName('EnlistDate').AsDateTime < FromDate then
        begin
          xPayRecord := TxPayRecord.Create;
          xPayRecord.AccDate := FIndIllD.FieldByName('WorkDate').AsDateTime;
          xPayRecord.EnlistDate := FIndIllS.FieldByName('EnlistDate').AsDateTime;
          xPayRecord.AccName := 'Индексация больничного';
          xPayRecord.Sum := FIndIllS.FieldByName('IndSum').AsFloat;
        end;

        FxAccountList.Add(xPayRecord);

        FIndIllS.Next;
      end;
    finally
      FIndIllS.CancelRange;
    end;
    FIndIllD.Next;
  end;
end;

(* Всего начислено индексации декретных за период с FromDate по ToDate *)
procedure TxIllIndSum.CreateAllIndDekr;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIndIllD.First;
  while not FIndIllD.EOF do
  begin
    try
      FIndIllS.SetRange(
       [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey],
        [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey]);

      FIndIllS.First;
      while not FIndIllS.EOF do
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FIndIllD.FieldByName('WorkDate').AsDateTime;
        xPayRecord.EnlistDate := FIndIllS.FieldByName('EnlistDate').AsDateTime;
        xPayRecord.AccName := 'Индексация декретного';
        xPayRecord.Sum := FIndIllS.FieldByName('IndDekr').AsFloat;
        FxAccountList.Add(xPayRecord);

        FIndIllS.Next;
      end;
    finally
      FIndIllS.CancelRange;
    end;
    FIndIllD.Next;
  end;
end;

function TxIllIndSum.GetAllIndDekrSum: Double;
begin
  Result := 0;
  CreateAllIndDekr;
  Result := FxAccountList.Sum;
end;

procedure TxIllIndSum.GroupByEnlistDate;
var
  xPayRecord: TxPayRecord;
begin
  FxAccountList.Clear;

  FIndIllD.First;
  while not FIndIllD.EOF do
  begin
    try
      FIndIllS.SetRange(
        [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey],
        [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey]);

      FIndIllS.First;
      while not FIndIllS.EOF do
      begin
        xPayRecord := TxPayRecord.Create;
        xPayRecord.AccDate := FIndIllD.FieldByName('WorkDate').AsDateTime;
        xPayRecord.EnlistDate := FIndIllS.FieldByName('EnlistDate').AsDateTime;
        xPayRecord.Sum := FIndIllS.FieldByName('IndSum').AsFloat;
        xPayRecord.AccName := 'Индексация декретного';
        FxAccountList.AddByEnlistDate(xPayRecord);

        FIndIllS.Next;
      end;
    finally
      FIndIllS.CancelRange;
    end;
    FIndIllD.Next;
  end;
end;

(* Индексации начисленные в за период FromDate-ToDate и приходящиеся на EnlistDate *)
function TxIllIndSum.GetCurrentIndIllSum: Double;
begin
  Result := 0;

  FIndIllD.First;
  while not FIndIllD.EOF do
  begin
    try
      FIndIllS.SetRange(
        [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey],
        [FIndIllD.FieldByName('IndIllKey').AsInteger, FEmplKey]);

      FIndIllS.First;
      while not FIndIllS.EOF do
      begin
        if FIndIllS.FieldByName('EnlistDate').AsDateTime = WorkDate then
          Result := Result + FIndIllS.FieldByName('IndSum').AsFloat;
        FIndIllS.Next;
      end;
    finally
      FIndIllS.CancelRange;
    end;
    FIndIllD.Next;
  end;
end;

procedure Register;
begin
  RegisterComponents('xWage', [TxMSalarySum]);
  RegisterComponents('xWage', [TxTimePaySum]);
  RegisterComponents('xWage', [TxSimpleOrderSum]);
  RegisterComponents('xWage', [TxKTUOrderSum]);
  RegisterComponents('xWage', [TxHolidPaySum]);
  RegisterComponents('xWage', [TxIllPaySum]);
  RegisterComponents('xWage', [TxAccFormula]);
  RegisterComponents('xWage', [TxIllIndSum]);
end;

end.
