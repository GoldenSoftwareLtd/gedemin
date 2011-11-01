unit gdScriptFactory;

interface

uses
  Windows, Classes, gd_i_ScriptFactory, rp_ReportScriptControl,
  rp_BaseReport_unit, prm_ParamFunctions_unit, Sysutils;

type
  TVarLocCash = class(TObject)
  private
    FFunctionKey: Integer;
    FModifyDate: String;
    FParam, FResult: Variant;

  public
    property FunctionKey: Integer read FFunctionKey write FFunctionKey;
    property ModifyDate: String read FModifyDate write FModifyDate;
    property Param: Variant read FParam write FParam;
    property Result: Variant read FResult write FResult;
  end;

type
  TgbScriptFactory = class(TComponent, IgdScriptFactory)
  private
    FLocCashScript: TList;
    FReportScript: TReportScript;

    function GetCreateObject: TOnCreateObject;
    function GetShowRaise: Boolean;

    procedure SetCreateObject(const Value: TOnCreateObject);
    procedure SetShowRaise(const Value: Boolean);

  protected
    function Get_Self: TObject;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function InputParams(const AFunction: TrpCustomFunction; out AParamAndResult: Variant): Boolean;
    function ExecuteFunction(AFunction: TrpCustomFunction; var AParamAndResult: Variant;
     const CanUseServer: Boolean = False): Boolean;

    property ShowRaise: Boolean read GetShowRaise write SetShowRaise;

  published
    property OnCreateObject: TOnCreateObject read GetCreateObject write SetCreateObject;
  end;

procedure Register;

implementation


{ TgbScriptFactory }

constructor TgbScriptFactory.Create(AOwner: TComponent);
begin
  Assert(ScriptFactory = nil, 'This component can be only one.');

  inherited Create(AOwner);

  FLocCashScript := TList.Create;
  FReportScript := TReportScript.Create(Self);
  ScriptFactory := Self;
end;

destructor TgbScriptFactory.Destroy;
begin
  if Assigned(FReportScript) then
  begin
    while Boolean(FLocCashScript.Count) do
      TObject(FLocCashScript.Items[FLocCashScript.Count -1]).Free;
    FReportScript.Free;
  end;

  inherited;

  if ScriptFactory.Get_Self = Self then
    ScriptFactory := nil;
end;

function TgbScriptFactory.InputParams(const AFunction: TrpCustomFunction;
  out AParamAndResult: Variant): Boolean;
var
  LocReportScript: TReportScript;
begin
  if FReportScript.IsBusy then
  begin
    LocReportScript := TReportScript.Create(nil);
    try
      LocReportScript.OnCreateObject := FReportScript.OnCreateObject;
      LocReportScript.CreateObject;
      Result := LocReportScript.InputParams(AFunction, AParamAndResult);
    finally
      LocReportScript.Free;
    end;
  end else
    Result := FReportScript.InputParams(AFunction, AParamAndResult);
end;

function TgbScriptFactory.ExecuteFunction(AFunction: TrpCustomFunction;
  var AParamAndResult: Variant; const CanUseServer: Boolean): Boolean;
var
  LocReportScript: TReportScript;
  VarLocCash: TVarLocCash;
  CashSelect: Boolean;
  CashIndex, i: Integer;

  function ModifyDateToStr(const MDate: TDateTime): String;
  begin
    Result := DateToStr(MDate) + TimeToStr(MDate);
  end;

  function CompArrVariant(const ArrVariant1, ArrVariant2: Variant): Boolean;
  var
    Compare: Boolean;
    i: integer;
  begin
    Compare := False;
//    if (ArrVariant1.VType <> Null.VType) and (ArrVariant2.VType <> Null.VType) then
      if VarIsArray(ArrVariant1) and VarIsArray(ArrVariant2) then
        if VarArrayDimCount(ArrVariant1) = VarArrayDimCount(ArrVariant2) then
          begin
            Compare := True;
            for i := VarArrayLowBound(ArrVariant1, 1) to VarArrayHighBound(ArrVariant1, 1) do
            if VarType(ArrVariant1[i]) = VarType(ArrVariant2[i]) then
              if VarType(ArrVariant1[i]) = varVariant then
                Compare := CompArrVariant(ArrVariant1[i], ArrVariant2[i])
              else
                if ArrVariant1[i] = ArrVariant2[i] then
                  Compare := True
                else
                  begin
                    Compare := False;
                    break;
                  end
            else
              begin
                CashSelect := False;
                break;
              end;

          end;
    Result := Compare;
  end;

begin
{
  проверка на наличие в кэше AFunction & AParamAndResult
  по полям
    FFunctionKey: Integer;
    FModifyDate: TDateTime;
  и входным параметрам
    FParam: Variant;
}
  VarLocCash := TVarLocCash.Create;
  CashSelect := False;
  for i := 0 to FLocCashScript.Count - 1 do
  begin
    if (TObject(FLocCashScript.Items[i]) as TVarLocCash).FunctionKey = AFunction.FunctionKey then
      if CompArrVariant((TObject(FLocCashScript.Items[i]) as TVarLocCash).Param, AParamAndResult) then
        if ((TObject(FLocCashScript.Items[i]) as TVarLocCash).ModifyDate =
          ModifyDateToStr(AFunction.ModifyDate)) then
            begin
              CashSelect := True;
              CashIndex := i
            end;
  end;
//конец проверки кэша

  if not CashSelect then
  begin
    VarLocCash.Param := AParamAndResult;
    if FReportScript.IsBusy then           // проверка на затость ExecuteFunction
    begin
      LocReportScript := TReportScript.Create(nil);
      try
        LocReportScript.OnCreateObject := FReportScript.OnCreateObject;
        LocReportScript.CreateObject;
//!!!!!!!!! Заремлено для тестировая кэша
//        Result := LocReportScript.ExecuteFunction(AFunction, AParamAndResult);
      finally
        LocReportScript.Free;
      end;
    end else

//!!!!!!!!! Заремлено для тестировая кэша
//      Result := FReportScript.ExecuteFunction(AFunction, AParamAndResult);
//  добавление в кэш новой макроса
    VarLocCash.FunctionKey := AFunction.FunctionKey;
    VarLocCash.ModifyDate := ModifyDateToStr(AFunction.ModifyDate);
    VarLocCash.Result := AParamAndResult;
    FLocCashScript.Add(VarLocCash);
  end
  else
  AParamAndResult := TVarLocCash(FLocCashScript.Items[CashIndex]).Result;

end;

function TgbScriptFactory.Get_Self: TObject;
begin
  Result := Self;
end;

function TgbScriptFactory.GetCreateObject: TOnCreateObject;
begin
  Result := FReportScript.OnCreateObject;
end;

function TgbScriptFactory.GetShowRaise: Boolean;
begin
  Result := FReportScript.ShowRaise;
end;

procedure TgbScriptFactory.SetCreateObject(const Value: TOnCreateObject);
begin
  FReportScript.OnCreateObject := Value;
end;

procedure TgbScriptFactory.SetShowRaise(const Value: Boolean);
begin
  FReportScript.ShowRaise := Value;
end;

procedure Register;
begin
  RegisterComponents('gsReport', [TgbScriptFactory]);
end;


{ TVarLocCash }

end.


