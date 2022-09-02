// ShlTanya, 10.03.2019

{++

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Module

    flt_ScriptInterface_body.pas

  Abstract

    Gedemin project. It is describing bodies of interfaces of Global variables:
    FilterScript, ParamGlobalDlg.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    15.10.01    JKL        Initial version.

--}

unit flt_ScriptInterface_body;

interface

uses
  Classes, flt_ScriptInterface, MSScriptControl_TLB, SysUtils, Windows,
  rp_ReportScriptControl, prm_ParamFunctions_unit, gdcBaseInterface;

type
  TfltGlobalScript = class(TComponent, IFilterScript)
  private
    FOnCreateObject: TOnCreateObject;
    {$IFNDEF GEDEMIN}
    FScriptControl: TReportScript;
    {$ENDIF}

    function GetScriptResult(const AnScriptText, AnLanguage: String;
     out AnSign: String): Variant;
  protected
    procedure SetOnCreateObject(const Value: TOnCreateObject);
    function Get_Object: TObject;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    property OnCreateObject: TOnCreateObject read FOnCreateObject write SetOnCreateObject;
  end;

type
  TCreateFilterDlg = procedure(const AnFirstKey, AnSecondKey: TID;
   const AnParamList: TgsParamList; var AnResult: Boolean; const AShowDlg: Boolean = True;
   const AFormName: string = ''; const AFilterName: string = '') of object;

type
  TprmGlobalDlg = class(TComponent, IFilterEnterData)
  private
    FOnDlgCreate: TCreateFilterDlg;

    procedure QueryParams(const AnFirstKey, AnSecondKey: TID;
     const AnParamList: TgsParamList; var AnResult: Boolean;
     const AShowDlg: Boolean = True;
     const AFormName: string = ''; const AFilterName: string = '');
    function IsEventAssigned: Boolean;
    function Get_Object: TObject;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnDlgCreate: TCreateFilterDlg read FOnDlgCreate write FOnDlgCreate;
  end;

type
  TCrackerReportScript = class(TReportScript);

procedure Register;

implementation

uses
  gd_i_ScriptFactory, IBSQL, rp_BaseReport_unit,
  scr_i_FunctionList, JclStrings, gd_security_operationconst
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ TFilterScript }

constructor TfltGlobalScript.Create(AnOwner: TComponent);
begin
  Assert(FilterScript = nil);

  inherited;

  {$IFNDEF GEDEMIN}
  FScriptControl := nil;

  if not (csDesigning in ComponentState) then
  try
    FScriptControl := TReportScript.Create(Self);
    FScriptControl.Language := '';
  except
    on E: Exception do
      MessageBox(0, PChar('Класс TScriptControl для фильтров не зарегистрирован.'#13#10 +
       E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TASKMODAL);
  end;
  {$ENDIF}
  FilterScript := Self;
end;

destructor TfltGlobalScript.Destroy;
begin
  {$IFNDEF GEDEMIN}
  if Assigned(FScriptControl) then
    FreeAndNil(FScriptControl);
  {$ENDIF}
  if Assigned(FilterScript) and (FilterScript.Get_Object = Self) then
    FilterScript := nil;

  inherited;
end;

function TfltGlobalScript.GetScriptResult(const AnScriptText,
  AnLanguage: String; out AnSign: String): Variant;

  function ExtractToken(const S: String; var B: Integer; out Token: String): Boolean;
  var
    E: Integer;
  begin
    while (B <= Length(S)) and (not (S[B] in ['a'..'z', 'A'..'Z'])) do
      Inc(B);
    E := B + 1;
    while (E <= Length(S)) and (S[E] in ['a'..'z', 'A'..'Z', '_', '0'..'9']) do
      Inc(E);
    Token := Copy(S, B, E - B);
    B := E + 1;
    Result := Token > '';
  end;

const
  Signs: array[1..8] of String =
    ('>=', '<=', '<>', '>', '<', '=', 'LIKE', 'SIMILAR TO');
var
  {$IFDEF GEDEMIN}
  P: Integer;
  q: TIBSQL;
  F: TrpCustomFunction;
  Cond, Tkn: String;
  {$ENDIF}
  I: Integer;
  TempStr: String;
begin
  {$IFNDEF GEDEMIN}
  if not Assigned(FScriptControl) then
    raise Exception.Create('Класс TScriptControl не зарегистрирован');
  TCrackerReportScript(FScriptControl).SetLanguage(AnLanguage);
  {$ENDIF}

  AnSign := '';
  TempStr := Trim(AnScriptText);

  for I := Low(Signs) to High(Signs) do
    if Pos(Signs[I], TempStr) = 1 then
    begin
      AnSign := Signs[I];
      break;
    end;

  if AnSign = '' then
    raise Exception.Create(
      'Выражение должно иметь следующий формат: <оператор сравнения> <выражение VBScript>,'#13#10 +
      'где <оператор сравнения> -- это один из следующих операторов: <, >, =, <>, <=, >=, LIKE, SIMILAR TO.'#13#10 +
      'Внутри <выражения VBScript> допускается обращение к глобальным объектам и вызов скрипт-функций.');

  TempStr := Copy(TempStr, Length(AnSign) + 1, 32000);

  {$IFDEF GEDEMIN}
  P := 1;
  Cond := '';
  while ExtractToken(TempStr, P, Tkn) do
    Cond := Cond + '''' + Tkn + ''',';
  if Cond > '' then
  begin
    SetLength(Cond, Length(Cond) - 1);

    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text :=
        'SELECT f.id, f.name ' +
        'FROM gd_function f ' +
        'WHERE f.modulecode = 1010001 AND f.module = ''UNKNOWN'' ' +
        '  AND UPPER(f.name) IN (' + AnsiUpperCase(Cond) + ')';
      q.ExecQuery;

      while not q.Eof do
      begin
        F := glbFunctionList.FindFunction(GetTID(q.FieldByName('id')));
        if Assigned(F) then
          ScriptFactory.AddScript(F, OBJ_APPLICATION, False);
        q.Next;
      end;
    finally
      q.Free;
    end;
  end;

  Result := ScriptFactory.Eval(TempStr);
  {$ELSE}
  Result := FScriptControl.Eval(TempStr);
  {$ENDIF}
  AnSign := ' ' + AnSign + ' ';
end;

function TfltGlobalScript.Get_Object: TObject;
begin
  Result := Self; 
end;

procedure TfltGlobalScript.SetOnCreateObject(const Value: TOnCreateObject);
begin
  FOnCreateObject := Value;
  {$IFNDEF GEDEMIN}
  if Assigned(FScriptControl) then
    FScriptControl.OnCreateObject := FOnCreateObject;
  {$ENDIF}
end;

{ TprmGlobalDlg }

constructor TprmGlobalDlg.Create(AnOwner: TComponent);
begin
  Assert(ParamGlobalDlg = nil);

  inherited;

  ParamGlobalDlg := Self;
end;

destructor TprmGlobalDlg.Destroy;
begin
  if Assigned(ParamGlobalDlg) and (ParamGlobalDlg.Get_Object = Self) then
    ParamGlobalDlg := nil;

  inherited;
end;

function TprmGlobalDlg.Get_Object: TObject;
begin
  Result := Self;
end;

function TprmGlobalDlg.IsEventAssigned: Boolean;
begin
  Result := Assigned(FOnDlgCreate);
end;

procedure TprmGlobalDlg.QueryParams(const AnFirstKey, AnSecondKey: TID;
   const AnParamList: TgsParamList; var AnResult: Boolean;
   const AShowDlg: Boolean = True;
   const AFormName: string = ''; const AFilterName: string = '');
begin
  if Assigned(FOnDlgCreate) then
    FOnDlgCreate(AnFirstKey, AnSecondKey, AnParamList, AnResult, AShowDlg, AFormName, AFilterName);
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TfltGlobalScript]);
  RegisterComponents('gsNew', [TprmGlobalDlg]);
end;

end.


