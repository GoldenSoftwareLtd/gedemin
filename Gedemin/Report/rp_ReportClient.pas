
{++

  Copyright (c) 2001 - 2015 by Golden Software of Belarus

  Module

    rp_ReportServer.pas

  Abstract

    Gedemin project. REPORT SYSTEM.
    Components: TServerReport, TClientReport;
    It's cool system.

  Author

    Andrey Shadevsky

  Revisions history

    1.00   ~01.05.01    JKL        Initial version.
    1.01    03.11.01    JKL        Additional checking for looking for a Computer with
                                   ReportServer has been added.
    1.02    08.11.01    JKL        The system is more reliable.
    1.03    26.02.02    JKL        Some comments was added. It was so difficult to remember.
    1.04    01.10.02    JKL        ReportViewForm was deleted. gdcViewForm is used.

--}

unit rp_ReportClient;

interface

{$DEFINE LogReport}

uses
  Classes, SysUtils, IBDatabase, rp_BaseReport_unit, rp_ClassReportFactory,
  rp_ErrorMsgFactory, rp_prgReportCount_unit, rp_ReportServer,
  Forms, rp_report_const, rp_i_ReportBuilder_unit;

const
  ScriptControlNotRegister = 'Класс Microsoft Script Control не зарегистрирован.';
  // константа для отличия функции и отчета при передаче функции от клиента серверу отчетов
  FunctionIdentifier = 'THIS_IS_FUNCTION._USE_FOR_DISTINCTION_FUNCTION!!!';

type
  TClientReport = class(TBaseReport)
  private
    FReportFactory: TReportFactory;

    FUniqueValue: Cardinal;
    FProgressForm: TprgReportCount;
    FClientEventFactory: TClientEventFactory;

    FFirstRead: Boolean;

    FPrinterName: String;
    FShowProgress: Boolean;
    FFileName: String;
    FExportType: String;

    function ClientQuery(const ReportData: TCustomReport; const ReportResult: TReportResult;
      var ParamAndResult: Variant; const AnIsRebuild: Boolean): Boolean;

    procedure ViewResult(const AnReport: TCustomReport; const AnReportResult: TReportResult;
     const AnParam: Variant; const AnBuildDate: TDateTime; const AnBaseQueryList: Variant);

    function ExecuteReport(const OwnerForm: OleVariant;
      const AnReport: TCustomReport; const AnResult: TReportResult;
      out AnErrorMessage: String; const AnIsRebuild: Boolean): Boolean;

    procedure ClientEvent(const AnReportData: TCustomReport; const AnTempParam: Variant;
      const AnReportResult: TReportResult; const AnBaseQueryList: Variant);
    procedure CheckLoaded;

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    //Проверяет, есть ли у осн.функции OwnerForm
    function  CheckWithOwnerForm(const AnReportKey: Integer): Boolean;

    procedure BuildReport(const OwnerForm: OleVariant;
      const AnReportKey: Integer; const AnIsRebuild: Boolean = False);
    procedure Execute(const AnGroupKey: Integer = 0);
    procedure Refresh; override;
    function DoAction(const AnKey: Integer; const AnAction: TActionType): Boolean;
    procedure Clear;
    procedure BuildReportWithParam(const AnReportKey: Integer; const AnParam: Variant;
      const AnIsRebuild: Boolean = False);

  published
    property OnCreateConst;
    property OnCreateObject;
    property OnCreateVBClasses;
    property OnCreateGlobalObj;
    property OnIsCreated;
    property Database;
    property ReportFactory: TReportFactory read FReportFactory write FReportFactory;
    property PrinterName: String read FPrinterName write FPrinterName;
    property ShowProgress: Boolean read FShowProgress write FShowProgress;
    property FileName: String read FFileName write FFileName;
    property ExportType: String read FExportType write FExportType;
  end;

// Глобальная переменная слиентской части отчетов
// ВНИМАНИЕ! Должен быть только один такой компонент
var
  ClientReport: TClientReport;

procedure Register;

implementation

uses
  Windows, gd_SetDatabase, gd_DebugLog, prp_MessageConst, prm_ParamFunctions_unit,
  gd_security, obj_i_Debugger
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{.$IFNDEF GEDEMIN}
{.$R Gedemin.TLB}
{.$ENDIF}

type
  TCrackCustomReport = class(TCustomReport);

const
  TimeOut = 10000;

procedure Register;
begin
  RegisterComponents('gsReport', [TClientReport]);
end;

// TClientReport

constructor TClientReport.Create(Owner: TComponent);
begin
  Assert(ClientReport = nil, 'ClientReport must be one for project.');

  inherited Create(Owner);

  FUniqueValue := 0;
  FReportFactory := nil;
  FProgressForm := nil;
  FClientEventFactory := nil;
  FFirstRead := False;
  FShowProgress := True;
  FFileName := '';
  FExportType := '';

  if not (csDesigning in ComponentState) then
  begin
    FProgressForm := TprgReportCount.Create(nil);
    FClientEventFactory := TClientEventFactory.Create;

    {$IFNDEF GEDEMIN}
    if not Assigned(FReportScriptControl) then
    begin
      {$IFNDEF DEPARTMENT}
      MessageBox(0, ScriptControlNotRegister, 'Ошибка', MB_OK or MB_ICONERROR or MB_TASKMODAL);
      {$ENDIF}
      Abort;
    end;
    {$ENDIF}
  end;

  ClientReport := Self;
end;

destructor TClientReport.Destroy;
begin
//  if Assigned(FibsqlServerName) then
//    FreeAndNil(FibsqlServerName);
  if Assigned(FProgressForm) then
    FreeAndNil(FProgressForm);
  if Assigned(FClientEventFactory) then
    FreeAndNil(FClientEventFactory);

  inherited Destroy;
  
  ClientReport := nil;
end;

procedure TClientReport.ViewResult(const AnReport: TCustomReport; const AnReportResult: TReportResult;
 const AnParam: Variant; const AnBuildDate: TDateTime; const AnBaseQueryList: Variant);
begin
  if Assigned(FReportFactory) then
    FReportFactory.CreateReport(AnReport.TemplateStructure, AnReportResult,
     AnParam, AnBuildDate, AnReport.Preview, AnReport.EventFunction, AnReport.ReportName,
     FPrinterName, FShowProgress, AnBaseQueryList, FFileName, FExportType, AnReport.ModalPreview)
  else
    raise Exception.Create('Object ReportFactory not assigned.');
end;

procedure TClientReport.ClientEvent(const AnReportData: TCustomReport; const AnTempParam: Variant;
  const AnReportResult: TReportResult; const AnBaseQueryList: Variant);
var
  TempReport: TCustomReport;
  TempFlag: Boolean;
  TempMsg: String;
begin
  TempFlag := True;

  TempReport := TCustomReport.Create;
  try
    if FindReportNow(AnReportData.ReportKey, TempReport) then
      ViewResult(TempReport, AnReportResult, AnTempParam, Date, AnBaseQueryList)
    else
    begin
      TempFlag := False;
      TempMsg := 'ОШИБКА!!! Отчет построен, но его запись не найдена.';
    end;
  finally
    TempReport.Free;
  end;
  FClientEventFactory.AddThread(TClientEventThread.Create(FProgressForm, False, TempFlag, TempMsg));
end;

procedure TClientReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent = FReportFactory) then
    FReportFactory := nil;
end;

function TClientReport.ClientQuery(const ReportData: TCustomReport; const ReportResult: TReportResult;
 var ParamAndResult: Variant; const AnIsRebuild: Boolean): Boolean;
var
  TempParam: Variant;
begin
  TempParam := ParamAndResult;
  try
    FProgressForm.AddRef(FShowProgress);
    try
      Result := ExecuteFunctionWithoutParam(ReportData.MainFunction, ReportResult,
       ParamAndResult);
      if Result then
        ClientEvent(ReportData, TempParam, ReportResult, ParamAndResult)
      else
        FProgressForm.Release;
    except
      FProgressForm.Release;
      raise;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      ParamAndResult := E.Message;
    end;
  end;
end;

function TClientReport.ExecuteReport(const OwnerForm: OleVariant; const AnReport: TCustomReport;
 const AnResult: TReportResult; out AnErrorMessage: String; const AnIsRebuild: Boolean): Boolean;
var
  Param: Variant;
  T: TDateTime;
begin
  AnErrorMessage := '';

  {$IFDEF DEBUG}
  if UseLog then
    Log.LogLn(DateTimeToStr(Now) + ': Запущен на выполнение отчет ' + AnReport.ReportName +
      '  ИД  ' + IntToStr(AnReport.ReportKey));
  {$ENDIF}

  T := Now;

  if Assigned(IBLogin) then
  begin
    IBLogin.AddEvent('Запущен на выполнение отчет.',
      AnReport.ReportName,
      AnReport.ReportKey);
  end;

  if AnReport.ParamFunction.FunctionKey <> 0 then
  begin
    with AnReport do
    begin
      Result := InputParams(ParamFunction, Param);
      if Result then
      begin
        if (ParamFunction.EnteredParams.Count > 0) and
          (AnsiUpperCase(Trim(ParamFunction.EnteredParams.Params[0].RealName)) =
          VB_OWNERFORM) and (ParamFunction.EnteredParams.Params[0].ParamType = prmNoQuery) then
          Param[0] := OwnerForm;
        Result := ExecuteFunctionWithoutParam(ParamFunction, AnResult, Param);
        if (Result) and
          (MainFunction.EnteredParams.Count <>
          (VarArrayHighBound(Param, 1) - VarArrayLowBound(Param, 1) + 1)) then
        begin
          Result := False;
          Param := 'Количество параметров основной функции не равно длине массива, возвращенного функцией параметров.';
        end;
      end;
    end;
  end else 
    with AnReport do
    begin
      Result := InputParams(MainFunction, Param);
      if (MainFunction.EnteredParams.Count > 0) and
        (AnsiUpperCase(Trim(MainFunction.EnteredParams.Params[0].RealName)) =
        VB_OWNERFORM) and (MainFunction.EnteredParams.Params[0].ParamType = prmNoQuery) then
        Param[0] := OwnerForm;
    end;

  if VarType(Param) = varString then
    AnErrorMessage := Param;

  if Result then
  begin
    Result := ClientQuery(AnReport, AnResult, Param, AnIsRebuild);

    if not Result then
    begin
      {$IFDEF DEBUG}
      if UseLog then
        Log.LogLn(DateTimeToStr(Now) + ': Ошибка во время выполнения отчета ' + AnReport.ReportName +
          '  ИД ' + IntToStr(AnReport.ReportKey));
      {$ENDIF}

      if Assigned(IBLogin) then
      begin
        IBLogin.AddEvent('Ошибка при построении отчета.',
          AnReport.ReportName,
          AnReport.ReportKey);
      end;

      AnErrorMessage := Param;
    end else
      begin
      {$IFDEF DEBUG}
        if UseLog then
          Log.LogLn(DateTimeToStr(Now) + ': Удачное выполнение отчета ' + AnReport.ReportName +
            '  ИД ' + IntToStr(AnReport.ReportKey));
      {$ENDIF}

        if Assigned(IBLogin) then
        begin
          IBLogin.AddEvent('Успешно построен отчет за ' +
            FormatDateTime('hh:nn:ss', Now - T) + '.',
            AnReport.ReportName,
            AnReport.ReportKey);
        end;
      end;
  end;
end;

procedure TClientReport.Refresh;
begin
  FFirstRead := True;
end;

procedure TClientReport.Execute(const AnGroupKey: Integer = 0);
begin
  CheckLoaded;
end;

procedure TClientReport.BuildReportWithParam(const AnReportKey: Integer;
 const AnParam: Variant; const AnIsRebuild: Boolean = False);
var
  CurrentReport: TCustomReport;
  LocReportResult: TReportResult;
  LocErrorMessage: String;
  TempParam: Variant;
  OldTime: DWORD;
begin
  if ReportIsBuilding then
  begin
    OldTime := GetTickCount;
    while (not Application.Terminated)
      and ReportIsBuilding
      and (GetTickCount - OldTime < TimeOut) do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;

    if Application.Terminated then
      exit;

    if ReportIsBuilding then
    begin
      MessageBox(0,
        'Идет построение отчета. Дождитесь окончания процесса.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      exit;
    end;  
  end;

  CheckLoaded;
  CurrentReport := TCustomReport.Create;
  try
    if not FindReportNow(AnReportKey, CurrentReport, False) then
    begin
      MessageBox(0,
        'Отчет не найден',
        'Внимание',
        MB_OK or MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL);
      Exit;
    end;
    if not ((VarType(AnParam) and (not (VarType(AnParam) xor VarArray))) = VarArray) then begin
      MessageBox(0,
        'Параметром должен быть массив',
        'Внимание',
        MB_OK or MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL);
      Exit;
    end;
    LocReportResult := TReportResult.Create;
    try
      LocReportResult.IsStreamData := True;
      LocErrorMessage := '';

      TempParam := AnParam;
      if not ClientQuery(CurrentReport, LocReportResult, TempParam, AnIsRebuild) then
      begin
        if (VarType(TempParam) = varString) and (TempParam > '') then
        begin
          LocErrorMessage := TempParam;
          MessageBox(0,
            PChar('Произошла ошибка при построении отчета: '#13#10 + LocErrorMessage),
            'Внимание!',
            MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
        end;
      end;
    finally
      LocReportResult.Free;
    end;
  finally
    CurrentReport.Free;
  end;
end;

procedure TClientReport.BuildReport(const OwnerForm: OleVariant;
  const AnReportKey: Integer; const AnIsRebuild: Boolean = False);
const
  cn_MsgReportIsRunning: String = 'Идет построение отчета. Дождитесь окончания процесса.';
var
  CurrentReport: TCustomReport;
  LocReportResult: TReportResult;
  LocErrorMessage: String;
  OldTime: DWORD;
begin
  FFileName := '';
  FExportType := '';

  if Assigned(Debugger) and (Debugger.IsPaused) then
  begin
    MessageBox(0, PChar(cn_MsgReportIsRunning), 'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    exit;
  end;

  if ReportIsBuilding then
  begin
    OldTime := GetTickCount;
    while (not Application.Terminated)
      and ReportIsBuilding
      and (GetTickCount - OldTime < TimeOut) do
    begin
      Sleep(100);
      Application.ProcessMessages;
    end;

    if Application.Terminated then
      exit;

    if ReportIsBuilding then
    begin
      MessageBox(0, PChar(cn_MsgReportIsRunning), 'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      exit;
    end;
  end;

  CurrentReport := TCustomReport.Create;
  try
    if not FindReportNow(AnReportKey, CurrentReport, False) then
    begin
      MessageBox(0,
        'Отчет не найден',
        'Внимание',
        MB_OK or MB_ICONWARNING or MB_TOPMOST or MB_TASKMODAL);
      Exit;
    end;
    if not CurrentReport.IsLocalExecute then
      CheckLoaded;
    LocReportResult := TReportResult.Create;
    try
      LocReportResult.IsStreamData := True;
      LocErrorMessage := '';
      if not ExecuteReport(OwnerForm, CurrentReport, LocReportResult, LocErrorMessage, AnIsRebuild) then
        if (LocErrorMessage > '') then
          MessageBox(0,
            PChar('Произошла ошибка при построении отчета: '#13#10 + LocErrorMessage),
            'Внимание!',
            MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
    finally
      LocReportResult.Free;
    end;
  finally
    CurrentReport.Free;
  end;
end;

procedure TClientReport.CheckLoaded;
begin
  if not FFirstRead then
    Refresh;
end;

function TClientReport.DoAction(const AnKey: Integer;
  const AnAction: TActionType): Boolean;
begin
  Result := False;
end;

procedure TClientReport.Clear;
begin
{  if Assigned(FReportFactory) then
    FReportFactory.Clear;  }
  FClientEventFactory.Clear;
end;

function TClientReport.CheckWithOwnerForm(
  const AnReportKey: Integer): Boolean;
var
  CurrentReport: TCustomReport;
begin
  Result := False;
  CurrentReport := TCustomReport.Create;
  try
    if not FindReportNow(AnReportKey, CurrentReport, False) then
    begin
      Exit;
    end;
    with CurrentReport do
    begin
      if (MainFunction.EnteredParams.Count > 0) and
        (AnsiUpperCase(Trim(MainFunction.EnteredParams.Params[0].RealName)) =
        VB_OWNERFORM) and (MainFunction.EnteredParams.Params[0].ParamType = prmNoQuery) then
        Result := True;
    end;
  finally
    CurrentReport.Free;
  end;
end;

initialization
  ClientReport := nil;

finalization
  ClientReport := nil;
  
end.


