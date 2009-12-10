
{++

  Copyright (c) 2000-2001 by Golden Software of Belarus

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
  rp_ReportScriptControl, prm_ParamFunctions_unit;

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
  TCreateFilterDlg = procedure(const AnFirstKey, AnSecondKey: Integer;
   const AnParamList: TgsParamList; var AnResult: Boolean; const AShowDlg: Boolean = True;
   const AFormName: string = ''; const AFilterName: string = '') of object;

type
  TprmGlobalDlg = class(TComponent, IFilterEnterData)
  private
    FOnDlgCreate: TCreateFilterDlg;

    procedure QueryParams(const AnFirstKey, AnSecondKey: Integer;
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
  gd_i_ScriptFactory
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
const
  MORE_OR_EQUAL = '>=';
  LESS_OR_EQUAL = '<=';
  NOT_EQUAL = '<>';
  MORE = '>';
  LESS = '<';
  EQUAL = '=';
  LIKE = 'LIKE';
var
  TempStr: String;
begin
  {$IFNDEF GEDEMIN}
  if not Assigned(FScriptControl) then
    raise Exception.Create('Класс TScriptControl не зарегистрирован');
  TCrackerReportScript(FScriptControl).SetLanguage(AnLanguage);
  {$ENDIF}
  TempStr := Trim(AnScriptText);
  if Pos(MORE_OR_EQUAL, TempStr) = 1 then
    AnSign := MORE_OR_EQUAL
  else
    if Pos(LESS_OR_EQUAL, TempStr) = 1 then
      AnSign := LESS_OR_EQUAL
    else
      if Pos(NOT_EQUAL, TempStr) = 1 then
        AnSign := NOT_EQUAL
      else
        if Pos(MORE, TempStr) = 1 then
          AnSign := MORE
        else
          if Pos(LESS, TempStr) = 1 then
            AnSign := LESS
          else
            if Pos(EQUAL, TempStr) = 1 then
              AnSign := EQUAL
            else
              if Pos(LIKE, TempStr) = 1 then
                AnSign := LIKE
              else
                raise Exception.Create(
                  'Выражение должно иметь следующий формат: <оператор сравнения><выражение>,'#13#10 +
                  'где <оператор сравнения> -- это один из следующих операторов: <, >, =, <>, <=, >=, LIKE,'#13#10 +
                  'а выражение, это вычисляемое выражение на языке VBScript.'#13#10 +
                  'Из выражения возможен доступ к глобальным объектам Гедымина, функциям.');

  {$IFDEF GEDEMIN}
  Result := ScriptFactory.Eval(Copy(TempStr, Length(AnSign) + 1, Length(TempStr)));
  {$ELSE}
  Result := FScriptControl.Eval(Copy(TempStr, Length(AnSign) + 1, Length(TempStr)));
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

procedure TprmGlobalDlg.QueryParams(const AnFirstKey, AnSecondKey: Integer;
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


