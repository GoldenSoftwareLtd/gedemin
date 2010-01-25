
{++

  Copyright (c) 2001 by Golden Software of Belarus

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
  {rp_vwReport_unit, }rp_ErrorMsgFactory, rp_prgReportCount_unit, rp_ReportServer,
  IBSQL, ScktComp, Forms, rp_report_const;

const
  ScriptControlNotRegister = 'Класс Microsoft Script Control не зарегистрирован.';
  VersionReportStorage = $00000010;
  {!!!}
  // константа для отличия функции и отчета при передаче функции от клиента серверу отчетов
  FunctionIdentifier = 'THIS_IS_FUNCTION._USE_FOR_DISTINCTION_FUNCTION!!!';

type
  TClientReport = class(TBaseReport)
  private
    FibsqlServerName: TIBSQL;

    FReportFactory: TReportFactory;

    FUniqueValue: Cardinal;
    FProgressForm: TprgReportCount;
    FClientEventFactory: TClientEventFactory;

    FFirstRead: Boolean;
    FReportList: TReportList;

    FPrinterName: string;
    FShowProgress: boolean;

    function ClientQuery(const ReportData: TCustomReport; const ReportResult: TReportResult;
     var ParamAndResult: Variant; const AnIsRebuild: Boolean): Boolean;
    procedure ViewResult(const AnReport: TCustomReport; const AnReportResult: TReportResult;
     const AnParam: Variant; const AnBuildDate: TDateTime; const AnBaseQueryList: Variant);
    function ExecuteReport(const OwnerForm: OleVariant;
      const AnReport: TCustomReport; const AnResult: TReportResult;
      out AnErrorMessage: String; const AnIsRebuild: Boolean): Boolean;
//    function GetDefaultServer: TSocketServerParam;  не используется

    procedure ClientEvent(AnReportData: TCustomReport; AnTempParam: Variant; AnReportResult: TReportResult; AnBaseQueryList: Variant);
    procedure CheckLoaded;
  protected
//    function GetReportServerName(const AnServerKey: Integer): String;  не используется
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure BuildReportWithParam(const AnReportKey: Integer; const AnParam: Variant; const AnIsRebuild: Boolean = False);
//    function GetUniqueClientKey: Cardinal;  не используется
//    procedure CreateNewTemplate(AnIBSQL: TIBSQL; AnTemplate: TTemplateStructure);
//    procedure CreateNewFunction(AnIBSQL: TIBSQL; AnFunction: TrpCustomFunction);
//    procedure CreateNewReport(AnReport: TCustomReport);
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    //Проверяет, есть ли у осн.функции OwnerForm
    function  CheckWithOwnerForm(const AnReportKey: Integer): Boolean;

    procedure BuildReport(const OwnerForm: OleVariant;
      const AnReportKey: Integer; const AnIsRebuild: Boolean = False);
    procedure Execute(const AnGroupKey: Integer = 0);
    procedure Refresh; override;
//    property DefaultServer: TSocketServerParam read GetDefaultServer;  не используется
    function DoAction(const AnKey: Integer; const AnAction: TActionType): Boolean;
//    procedure SaveReportToFile(const AnReportKey: Integer;
//     const AnFileName: String = '');
//    function LoadReportFromFile(const AnGroupKey: Integer; const AnFileName: String = ''): Boolean;
    procedure Clear;

    // Only For Testing
    property ReportList: TReportList read FReportList;
  published
    property OnCreateConst;
    property OnCreateObject;
    property OnCreateVBClasses;
    property OnCreateGlobalObj;
    property OnIsCreated;
    property Database;
    property ReportFactory: TReportFactory read FReportFactory write FReportFactory;
    property PrinterName: string read FPrinterName write FPrinterName;
    property ShowProgress: boolean read FShowProgress write FShowProgress;
  end;

// Глобальная переменная слиентской части отчетов
// ВНИМАНИЕ! Должен быть только один такой компонент
var
  ClientReport: TClientReport;

procedure Register;

implementation

uses
  Windows, gd_SetDatabase, gd_DebugLog, prp_MessageConst, prm_ParamFunctions_unit,
  gd_security
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
//  RegisterComponents('gsReport', [TServerReport]);
end;

// TClientReport

constructor TClientReport.Create(Owner: TComponent);
begin
  Assert(ClientReport = nil, 'ClientReport must be one for project.');

  inherited Create(Owner);

  FibsqlServerName := nil;
  FUniqueValue := 0;
  FReportFactory := nil;
  FProgressForm := nil;
  FClientEventFactory := nil;
  FFirstRead := False;
  FShowProgress:= True;

  if not (csDesigning in ComponentState) then
  begin
    FProgressForm := TprgReportCount.Create(nil);
    FClientEventFactory := TClientEventFactory.Create;
    FibsqlServerName := TIBSQL.Create(Self);
    FibsqlServerName.SQL.Text := 'SELECT computername FROM rp_reportserver ' +
     'WHERE id = :id';

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
  if Assigned(FibsqlServerName) then
    FreeAndNil(FibsqlServerName);
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
     FPrinterName, FShowProgress, AnBaseQueryList)
  else
    raise Exception.Create('Object ReportFactory not assigned.');
end;

procedure TClientReport.ClientEvent(AnReportData: TCustomReport; AnTempParam: Variant; AnReportResult: TReportResult; AnBaseQueryList: Variant);
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

{function TClientReport.GetDefaultServer: TSocketServerParam;
var
  ibsqlDefaultServer: TIBSQL;
begin
  Result.ServerName := '';
  Result.ServerPort := 0;
  PrepareSourceDatabase;
  try
    ibsqlDefaultServer := TIBSQL.Create(nil);
    try
      ibsqlDefaultServer.Database := FDatabase;
      ibsqlDefaultServer.Transaction := FTransaction;
      ibsqlDefaultServer.SQL.Text := 'SELECT rs.computername, rs.serverport, ' +
       'rs.id FROM ' +
       'rp_reportserver rs, rp_reportdefaultserver rds WHERE rds.serverkey = rs.id AND ' +
       'rds.clientname = ''' + rpGetComputerName + '''';
      ibsqlDefaultServer.ExecQuery;
      if not ibsqlDefaultServer.Eof then
      begin
        Result.ServerName := ibsqlDefaultServer.Fields[0].AsString;
        Result.ServerPort := ibsqlDefaultServer.Fields[1].AsInteger;
        Result.ServerKey := ibsqlDefaultServer.Fields[2].AsInteger;
      end;
    finally
      ibsqlDefaultServer.Free;
    end;
  finally
    UnPrepareSourceDatabase;
  end;
end;}

{function TClientReport.GetUniqueClientKey: Cardinal;
begin
  Inc(FUniqueValue);
  Result := FUniqueValue;
end;}

procedure TClientReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent = FReportFactory) then
    FReportFactory := nil;
end;

{function TClientReport.GetReportServerName(const AnServerKey: Integer): String;
begin
  PrepareSourceDatabase;
  try
    FibsqlServerName.Close;
    FibsqlServerName.Database := FDatabase;
    FibsqlServerName.Transaction := FTransaction;
    FibsqlServerName.Params[0].AsInteger := AnServerKey;
    FibsqlServerName.ExecQuery;
    Result := FibsqlServerName.Fields[0].AsString;
  finally
    FibsqlServerName.Close;
    UnPrepareSourceDatabase;
  end;
end;}

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
var
  CurrentReport: TCustomReport;
  LocReportResult: TReportResult;
  LocErrorMessage: String;
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

{function TClientReport.LoadReportFromFile(const AnGroupKey: Integer; const AnFileName: String): Boolean;
var
  TempReport: TCustomReport;
  FStr: TFileStream;
  TempLength: Integer;
  TestVersion: DWord;
  TempStr: String;
begin
  Result := False;
  try
    TempReport := TCustomReport.Create;
    try
      FStr := TFileStream.Create(AnFileName, fmOpenRead);
      try
        FStr.ReadBuffer(TestVersion, SizeOf(TestVersion));
        if VersionReportStorage <> TestVersion then
          raise Exception.Create('Неверный формат файла');

        FStr.ReadBuffer(TempLength, SizeOf(TempLength));
        SetLength(TempStr, TempLength);
        if TempLength > 0 then
          FStr.ReadBuffer(TempStr[1], TempLength);
        TCrackCustomReport(TempReport).FReportName := TempStr;

        FStr.ReadBuffer(TempLength, SizeOf(TempLength));
        SetLength(TempStr, TempLength);
        if TempLength > 0 then
          FStr.ReadBuffer(TempStr[1], TempLength);
        TCrackCustomReport(TempReport).FReportDescription := TempStr;

        FStr.ReadBuffer(TempLength, SizeOf(TempLength));
        TCrackCustomReport(TempReport).FFrqRefresh := TempLength;

        FStr.ReadBuffer(TempLength, SizeOf(TempLength));
        if TempLength = 0 then
          TCrackCustomReport(TempReport).FServerKey := null
        else
          TCrackCustomReport(TempReport).FServerKey := TempLength;

        FStr.ReadBuffer(TempLength, SizeOf(TempLength));
        if TempLength = 0 then
          TCrackCustomReport(TempReport).FPreview := False
        else
          TCrackCustomReport(TempReport).FPreview := True;

        FStr.ReadBuffer(TempLength, SizeOf(TempLength));
        if TempLength = 0 then
          TCrackCustomReport(TempReport).FIsRebuild := False
        else
          TCrackCustomReport(TempReport).FIsRebuild := True;

        FStr.ReadBuffer(TempLength, SizeOf(TempLength));
        if TempLength = 0 then
          TCrackCustomReport(TempReport).FIsLocalExecute := False
        else
          TCrackCustomReport(TempReport).FIsLocalExecute := True;

        TempReport.ParamFunction.LoadFromStream(FStr);
        TempReport.MainFunction.LoadFromStream(FStr);
        TempReport.EventFunction.LoadFromStream(FStr);
        TempReport.TemplateStructure.LoadFromStream(FStr);
        TCrackCustomReport(TempReport).FReportGroupKey := AnGroupKey;
      finally
        FStr.Free;
      end;
      CreateNewReport(TempReport);
      Result := True;
    finally
      TempReport.Free;
    end;
  except
    on E: Exception do
      MessageBox(0, PChar('Произошла ошибка при создании нового отчета из файла'#13#10
       + E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
  end;
end;

procedure TClientReport.SaveReportToFile(const AnReportKey: Integer;
  const AnFileName: String);
var
  TempReport: TCustomReport;
  FStr: TFileStream;
  TempLength: Integer;
  TestVersion: DWord;
begin
  try
    TempReport := TCustomReport.Create;
    try
      FindReportNow(AnReportKey, TempReport);

      FStr := TFileStream.Create(AnFileName, fmCreate);
      try
        TestVersion := VersionReportStorage;
        FStr.Write(TestVersion, SizeOf(TestVersion));

        TempLength := Length(TempReport.ReportName);
        FStr.Write(TempLength, SizeOf(TempLength));
        FStr.Write(TempReport.ReportName[1], TempLength);

        TempLength := Length(TempReport.Description);
        FStr.Write(TempLength, SizeOf(TempLength));
        FStr.Write(TempReport.Description[1], TempLength);

        TempLength := TempReport.FrqRefresh;
        FStr.Write(TempLength, SizeOf(TempLength));

        if TempReport.ServerKey = null then
          TempLength := 0
        else
          TempLength := TempReport.ServerKey;
        FStr.Write(TempLength, SizeOf(TempLength));

        if TempReport.Preview then
          TempLength := 1
        else
          TempLength := 0;
        FStr.Write(TempLength, SizeOf(TempLength));

        if TempReport.IsRebuild then
          TempLength := 1
        else
          TempLength := 0;
        FStr.Write(TempLength, SizeOf(TempLength));

        if TempReport.IsLocalExecute then
          TempLength := 1
        else
          TempLength := 0;
        FStr.Write(TempLength, SizeOf(TempLength));

        TempReport.ParamFunction.SaveToStream(FStr);
        TempReport.MainFunction.SaveToStream(FStr);
        TempReport.EventFunction.SaveToStream(FStr);
        TempReport.TemplateStructure.SaveToStream(FStr);
      finally
        FStr.Free;
      end;
    finally
      TempReport.Free;
    end;
  except
    on E: Exception do
      MessageBox(0, PChar('Произошла ошибка при сохранении отчета в файл'#13#10
       + E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
  end;
end;         }

(*procedure TClientReport.CreateNewTemplate(AnIBSQL: TIBSQL;
  AnTemplate: TTemplateStructure);
begin
  Assert((AnIBSQL <> nil) and (AnTemplate <> nil), 'Can''t send nil');
  Assert(AnIBSQL.Database.Connected, 'Database must been connected');
  Assert(AnIBSQL.Transaction.InTransaction, 'Transaction must been started');

  if AnTemplate.TemplateKey = 0 then
    Exit;
  AnIBSQL.Close;
  AnIBSQL.SQL.Text := 'insert into rp_reporttemplate ' +
   '(ID, NAME, DESCRIPTION, TEMPLATEDATA, TEMPLATETYPE, AFULL, ACHAG, ' +
   'AVIEW, RESERVED) values (:ID, :NAME, :DESCRIPTION, :TEMPLATEDATA, ' +
   ':TEMPLATETYPE, :AFULL, :ACHAG, :AVIEW, :RESERVED)';
  AnIBSQL.Params[0].AsInteger := GetUniqueKey(AnIBSQL.Database, AnIBSQL.Transaction);
  AnTemplate.TemplateKey := AnIBSQL.Params[0].AsInteger;
  AnIBSQL.Params[1].AsString := AnTemplate.Name;
  AnIBSQL.Params[2].AsString := AnTemplate.Description;
  AnIBSQL.Params[3].LoadFromStream(AnTemplate.ReportTemplate);
  AnIBSQL.Params[4].AsString := AnTemplate.TemplateType;
  AnIBSQL.Params[5].AsInteger := AnTemplate.AFull;
  AnIBSQL.Params[6].AsInteger := AnTemplate.AChag;
  AnIBSQL.Params[7].AsInteger := AnTemplate.AView;
  AnIBSQL.ExecQuery;
end;

procedure TClientReport.CreateNewFunction(AnIBSQL: TIBSQL;
  AnFunction: TrpCustomFunction);
begin
  Assert((AnIBSQL <> nil) and (AnFunction <> nil), 'Can''t send nil');
  Assert(AnIBSQL.Database.Connected, 'Database must been connected');
  Assert(AnIBSQL.Transaction.InTransaction, 'Transaction must been started');

  if AnFunction.FunctionKey = 0 then
    Exit;
  AnIBSQL.Close;
  AnIBSQL.SQL.Text := 'insert into gd_function (ID, MODULE, LANGUAGE, NAME, ' +
   'COMMENT, SCRIPT)'{, AFULL, ACHAG, AVIEW, MODIFYDATE) ' }+
   'values(:ID, :MODULE, :LANGUAGE, :NAME, :COMMENT, :SCRIPT)'{, :AFULL, :ACHAG, ' +
   ':AVIEW, :MODIFYDATE)'};
  AnIBSQL.Params[0].AsInteger := GetUniqueKey(AnIBSQL.Database, AnIBSQL.Transaction);
  AnFunction.FunctionKey := AnIBSQL.Params[0].AsInteger;
  AnIBSQL.Params[1].AsString := AnFunction.Module;
  AnIBSQL.Params[2].AsString := AnFunction.Language;
  AnIBSQL.Params[3].AsString := AnFunction.Name;
  AnIBSQL.Params[4].AsString := AnFunction.Comment;
  AnIBSQL.Params[5].AsString := AnFunction.Script.Text;
//  AnIBSQL.Params[6].AsInteger := AnFunction.AFull;
//  AnIBSQL.Params[7].AsInteger := AnFunction.AChag;
//  AnIBSQL.Params[8].AsInteger := AnFunction.AView;
//  AnIBSQL.Params[9].AsDateTime := AnFunction.ModifyDate;
  AnIBSQL.ExecQuery;
end;

procedure TClientReport.CreateNewReport(AnReport: TCustomReport);
var
  LocIBTR: TIBTransaction;
  LocIBSQL: TIBSQL;
  I: Integer;
begin
  LocIBTR := TIBTransaction.Create(nil);
  try
    try
      LocIBTR.DefaultDatabase := FDatabase;
      LocIBTR.StartTransaction;
      LocIBSQL := TIBSQL.Create(nil);
      try
        LocIBSQL.Database := FDatabase;
        LocIBSQL.Transaction := LocIBTR;
        CreateNewTemplate(LocIBSQL, AnReport.TemplateStructure);
        CreateNewFunction(LocIBSQL, AnReport.ParamFunction);
        CreateNewFunction(LocIBSQL, AnReport.MainFunction);
        CreateNewFunction(LocIBSQL, AnReport.EventFunction);

        LocIBSQL.Close;
        LocIBSQL.SQL.Text := 'insert into rp_reportlist (ID, NAME, DESCRIPTION, ' +
         'FRQREFRESH, REPORTGROUPKEY, PARAMFORMULAKEY, MAINFORMULAKEY, ' +
         'EVENTFORMULAKEY, TEMPLATEKEY, ISREBUILD, AFULL, ACHAG, AVIEW, ' +
         'SERVERKEY, ISLOCALEXECUTE, PREVIEW) values(:ID, :NAME, ' +
         ':DESCRIPTION, :FRQREFRESH, :REPORTGROUPKEY, :PARAMFORMULAKEY, ' +
         ':MAINFORMULAKEY, :EVENTFORMULAKEY, :TEMPLATEKEY, :ISREBUILD, :AFULL, ' +
         ':ACHAG, :AVIEW, :SERVERKEY, :ISLOCALEXECUTE, :PREVIEW)';

        for I := 0 to LocIBSQL.Params.Count - 1 do
          LocIBSQL.Params[I].Clear;

        LocIBSQL.Params[0].AsInteger := GetUniqueKey(LocIBSQL.Database, LocIBSQL.Transaction);
        LocIBSQL.Params[1].AsString := AnReport.ReportName;
        LocIBSQL.Params[2].AsString := AnReport.Description;
        LocIBSQL.Params[3].AsInteger := AnReport.FrqRefresh;
        LocIBSQL.Params[4].AsInteger := AnReport.ReportGroupKey;
        if AnReport.ParamFunction.FunctionKey <> 0 then
          LocIBSQL.Params[5].AsInteger := AnReport.ParamFunction.FunctionKey;
        if AnReport.MainFunction.FunctionKey <> 0 then
          LocIBSQL.Params[6].AsInteger := AnReport.MainFunction.FunctionKey;
        if AnReport.EventFunction.FunctionKey <> 0 then
          LocIBSQL.Params[7].AsInteger := AnReport.EventFunction.FunctionKey;
        if AnReport.TemplateStructure.TemplateKey <> 0 then
          LocIBSQL.Params[8].AsInteger := AnReport.TemplateStructure.TemplateKey;
        LocIBSQL.Params[9].AsInteger := Integer(AnReport.IsRebuild);
        LocIBSQL.Params[10].AsInteger := AnReport.AFull;
        LocIBSQL.Params[11].AsInteger := AnReport.AChag;
        LocIBSQL.Params[12].AsInteger := AnReport.AView;
        LocIBSQL.Params[13].Value := AnReport.ServerKey;
        LocIBSQL.Params[14].AsInteger := Integer(AnReport.IsLocalExecute);
        LocIBSQL.Params[15].AsInteger := Integer(AnReport.Preview);
        LocIBSQL.ExecQuery;
      finally
        LocIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        if LocIBTR.InTransaction then
          LocIBTR.Rollback;
        MessageBox(0, PChar('Произошла ошибка при создании отчета из файла'#13#10 +
         E.Message), 'Ошибка', MB_OK or MB_ICONERROR or MB_TOPMOST);
      end;
    end
  finally
    if LocIBTR.InTransaction then
      LocIBTR.Commit;
    LocIBTR.Free;
  end;
end; *)

procedure TClientReport.Clear;
begin
  if Assigned(FReportFactory) then
    FReportFactory.Clear;
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


