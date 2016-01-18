
{++

  Copyright (c) 2001 - 2016 by Golden Software of Belarus, Ltd

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
    1.03    01.04.03    DAlex      Script-module support and function vertion tracking.

--}

unit rp_ReportServer;

interface

{$DEFINE LogReport}

uses
  Classes, SysUtils, IBDatabase, rp_BaseReport_unit, IBSQL,
  IBQuery, DB, IBCustomDataSet, DBClient, Forms, ExtCtrls,
  rp_ReportScriptControl, Gedemin_TLB, Windows,
  ScktComp, gd_SetDatabase,
  rp_report_const, gd_KeyAssoc;

const
  ScriptControlNotRegister = 'Класс Microsoft Script Control не зарегистрирован.';

{type
  TServerConnectionState = (rsIdle, rsRefresh, rsRebuild, rsOption, rsGetResult,
    rsDeleteResult);   }

type
  TBaseReport = class(TComponent)
  private
    FOnCreateObject: TOnCreateObject;
    FOnCreateGlobalObj: TOnCreateObject;
    FOnCreateConst: TOnCreateObject;
    FOnCreateVBClasses: TOnCreateObject;
    FOnIsCreated: TNotifyEvent;

    FLocStateDB, FLocStateTR: Boolean;
    FLocState: Integer;
    {$IFNDEF GEDEMIN}
    FVBClasses: String;
    {$ENDIF}
    {$IFNDEF GEDEMIN}
    FConstants: String;
    {$ENDIF}
//    FVBObjects: String;
    FLogFileName: String;
    FCreateEventLoad: Boolean;
    FNonLoadSFList: TgdKeyDuplArray;
    Fgd_functionVers: Integer;

    function  GetDatabase: TIBDatabase;
    {$IFNDEF GEDEMIN}
    function  GetNonLoadSFList: TgdKeyArray;
    {$ENDIF}

    {$IFNDEF GEDEMIN}
    function  Get_gd_functionVersion: Integer;
    {$ENDIF}

    {$IFNDEF GEDEMIN}
    procedure CreateModuleVBClass(Sender: TObject;
      const ModuleCode: Integer; VBClassArray: TgdKeyArray);
    {$ENDIF}

    procedure SetDatabase(const AnDatabase: TIBDatabase);
    procedure SetOnCreateObject(const Value: TOnCreateObject);
    procedure SetOnCreateConst(const Value: TOnCreateObject);
    procedure SetOnCreateGlobalObj(const Value: TOnCreateObject);
    procedure SetOnCreateVBClasses(const Value: TOnCreateObject);
    procedure SetOnIsCreated(const Value: TNotifyEvent);

    {$IFNDEF GEDEMIN}
    procedure SetNonLoadSFList(const Value: TgdKeyArray);
    {$ENDIF}

    {$IFNDEF GEDEMIN}
    procedure SetOnCreateEvets;
    {$ENDIF}

    {$IFNDEF GEDEMIN}
    procedure CreateVBClassesLists;
    {$ENDIF}
    {$IFNDEF GEDEMIN}
    procedure CreateVBConstLists;
    {$ENDIF}
    {$IFNDEF GEDEMIN}
    procedure CreateVBClasses(Sender: TObject);
    {$ENDIF}
    {$IFNDEF GEDEMIN}
    procedure CreateConstans(Sender: TObject);
    {$ENDIF}

    procedure SaveLog(const S: String); virtual;
  protected
    FReportList: TReportList;

   {$IFNDEF GEDEMIN}
    FReportScriptControl: TReportScript;
   {$ENDIF}

    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure PrepareSourceDatabase; virtual;
    procedure UnPrepareSourceDatabase; virtual;

    procedure CheckScriptControl;

    function ExecuteFunctionWithoutParam(const AnFunction: TrpCustomFunction; const AnReportResult: TReportResult;
      var AnParamAndResult: Variant): Boolean;
    function InputParams(const AnFunction: TrpCustomFunction; out AnParamResult: Variant): Boolean;
    procedure SetTransactionParams; virtual;
    function FindReportNow(const AnReportKey: Integer;
      const AnCustomReport: TCustomReport; const AnReadTemplate: Boolean = True): Boolean;
    function FindFunctionNow(const AnFunctionKey: Integer;
      const AnCustomReport: TCustomReport; const AnReadTemplate: Boolean = True): Boolean;

  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    function ExecuteFunctionWithParam(const AnFunction: TrpCustomFunction; const AnReportResult: TReportResult;
      var AnParamAndResult: Variant): Boolean;

    procedure Refresh; virtual;

    property Database: TIBDatabase read GetDatabase write SetDatabase;
    {$IFNDEF GEDEMIN}
    property NonLoadSFList: TgdKeyArray read GetNonLoadSFList write SetNonLoadSFList;
    {$ENDIF}
    property OnCreateConst: TOnCreateObject read FOnCreateConst write SetOnCreateConst;
    property OnCreateGlobalObj: TOnCreateObject read FOnCreateGlobalObj write SetOnCreateGlobalObj;
    property OnCreateObject: TOnCreateObject read FOnCreateObject write SetOnCreateObject;
    property OnCreateVBClasses: TOnCreateObject read FOnCreateVBClasses write SetOnCreateVBClasses;
    property OnIsCreated: TNotifyEvent read FOnIsCreated write SetOnIsCreated;
  end;

implementation

uses
  jclMath, rp_dlgReportOptions_unit, gd_security_operationconst,
  WinSock, FileCtrl, {rp_ExecuteThread_unit,} gd_directories_const,
  prm_ParamFunctions_unit, flt_ScriptInterface,
 {$IFDEF GEDEMIN}
  gd_i_ScriptFactory,
 {$ENDIF}
  flt_IBUtils
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$IFNDEF GEDEMIN}
{$R Gedemin.TLB}
{$ENDIF}

{procedure WriteError(AnError: String);
var
  FStr: TFileStream;
  S: String;
begin
  try
    AnError := AnError + ' ' + DateTimeToStr(Now) + #13#10;
    S := ChangeFileExt(Application.EXEName, '.log');
    if FileExists(S) then
      FStr := TFileStream.Create(S, fmOpenWrite)
    else
      FStr := TFileStream.Create(S, fmCreate);
    try
      FStr.Position := FStr.Size;
      FStr.Write(AnError[1], Length(AnError));
    finally
      FStr.Free;
    end;
  except
    on E: Exception do
      MessageBox(0, PChar(E.Message), 'SaveLog', MB_OK or MB_TASKMODAL);
  end;
end;

function rpSetServerState(const AnState: TServerConnectionState): String;
begin
  case AnState of
    rsIdle: Result := 'Свободен';
    rsRefresh: Result := 'Обновление';
    rsRebuild: Result := 'Перестройка';
    rsOption: Result := 'Параметры';
    rsGetResult: Result := 'Вызов клиентом';
  else
    Result := 'Unknown'
  end;
end;      }

// TBaseReport

constructor TBaseReport.Create(Owner: TComponent);
begin
  {$IFDEF DEBUG}
  SaveLog('    Create');
  {$ENDIF}
  inherited Create(Owner);

  FLogFileName := '';
  FCreateEventLoad := False;
  FReportList := nil;
  FTransaction := nil;
  {$IFNDEF GEDEMIN}
  FReportScriptControl := nil;
  {$ENDIF}
  Fgd_functionVers := 0;

  if not (csDesigning in ComponentState) then
  begin
    FNonLoadSFList := TgdKeyDuplArray.Create;
    FNonLoadSFList.Duplicates := dupIgnore;
    FTransaction := TIBTransaction.Create(Self);
    SetTransactionParams;
    FReportList := TReportList.Create;
    FReportList.Transaction := FTransaction;
   {$IFNDEF GEDEMIN}
    try
      FReportScriptControl := TReportScript.CreateWithParam(Self, True, True);
      FReportScriptControl.Transaction := FTransaction;
      FReportScriptControl.OnCreateModuleVBClasses := CreateModuleVBClass;

    except
      (*on E: Exception do
      begin
        {MessageBox(0, PChar(ScriptControlNotRegister + #13#10 + E.Message),
         'Ошибка', MB_OK or MB_ICONERROR);}
        Abort;
      end;*)
    end;
   {$ENDIF}
  end;
end;

destructor TBaseReport.Destroy;
begin
  {$IFDEF DEBUG}
  SaveLog('    Destroy');
  {$ENDIF}
  if Assigned(FReportList) then
    FReportList.Free;
  {$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.Free;
  {$ENDIF}
  if Assigned(FTransaction) then
    FTransaction.Free;
  if Assigned(FNonLoadSFList) then
    FNonLoadSFList.Free;

  inherited Destroy;
end;

procedure TBaseReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  {$IFDEF DEBUG}
  SaveLog('    Notification ' + AComponent.ClassName);
  {$ENDIF}
  inherited Notification(AComponent, Operation);

  if (Operation = Classes.opRemove) and (FDatabase <> nil)
    and (AComponent = FDatabase) then FDatabase := nil;
end;

function TBaseReport.GetDatabase: TIBDatabase;
begin
  {$IFDEF DEBUG}
  SaveLog('    GetDatabase');
  {$ENDIF}
  Result := FDatabase;
end;

procedure TBaseReport.SetDatabase(const AnDatabase: TIBDatabase);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetDatabase');
  {$ENDIF}
  FDatabase := AnDatabase;
  if Assigned(FTransaction) then
  begin
    if FTransaction.InTransaction then
      FTransaction.Commit;
    FTransaction.DefaultDatabase := FDatabase;

    FReportList.Database := FDatabase;
  end;
end;

procedure TBaseReport.SetOnCreateObject(const Value: TOnCreateObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateObject');
  {$ENDIF}
  FOnCreateObject := Value;
  {$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnCreateObject := FOnCreateObject;
  {$ENDIF}
end;

function TBaseReport.ExecuteFunctionWithParam(const AnFunction: TrpCustomFunction; const AnReportResult: TReportResult;
 var AnParamAndResult: Variant): Boolean;
begin
  {$IFDEF DEBUG}
  SaveLog('    ExecuteFunctionWithParam');
  {$ENDIF}
  Result := False;
  if InputParams(AnFunction, AnParamAndResult) then
    Result := ExecuteFunctionWithoutParam(AnFunction, AnReportResult, AnParamAndResult);
end;

function TBaseReport.ExecuteFunctionWithoutParam(const AnFunction: TrpCustomFunction; const AnReportResult: TReportResult;
 var AnParamAndResult: Variant): Boolean;
var
  LocDispatch: IDispatch;
  LocReportResult: IgsQueryList;
{  VarResult: Variant;  }
 {$IFNDEF GEDEMIN}
  LocRpScrCtrl: TReportScript;
 {$ENDIF}

  TempInt: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog('    ExecuteFunctionWithoutParam');
  {$ENDIF}
  try
   {$IFDEF GEDEMIN}
    try
      Result := True;
      ScriptFactory.ExecuteFunction(AnFunction, AnParamAndResult);
    except
      Result := False;
    end;
   {$ELSE}
    if FReportScriptControl.IsBusy then
    begin
      LocRpScrCtrl := TReportScript.CreateWithParam(nil, True, True);
      try
        LocRpScrCtrl.OnCreateConst := FReportScriptControl.OnCreateConst;
        LocRpScrCtrl.OnCreateVBClasses := FReportScriptControl.OnCreateVBClasses;
        LocRpScrCtrl.OnCreateObject := FReportScriptControl.OnCreateObject;
        LocRpScrCtrl.OnIsCreated := FReportScriptControl.OnIsCreated;
        LocRpScrCtrl.OnCreateModuleVBClasses := FReportScriptControl.OnCreateModuleVBClasses;
        LocRpScrCtrl.Transaction := FTransaction;

        Result := LocRpScrCtrl.ExecuteFunction(AnFunction, AnParamAndResult);
      finally
        LocRpScrCtrl.Free;
      end;
    end else
    begin
      FReportScriptControl.Reset;
      Result := FReportScriptControl.ExecuteFunction(AnFunction, AnParamAndResult);
    end;
   {$ENDIF}

    if Result then
    begin
      if AnFunction.Module = MainModuleName then
        if (VarType(AnParamAndResult) = varDispatch) and ((LocDispatch as IgsQueryList) <> nil) then
        begin
          LocDispatch := AnParamAndResult;
          LocReportResult := LocDispatch as IgsQueryList;
          LocReportResult.ResultMasterDetail;
{          try
            VarResult := LocReportResult.ResultStream;

            AnReportResult.TempStream.Size := VarArrayHighBound(VarResult, 1) - VarArrayLowBound(VarResult, 1) + 1;
            CopyMemory(AnReportResult.TempStream.Memory, VarArrayLock(VarResult), AnReportResult.TempStream.Size);
            VarArrayUnLock(VarResult);
            AnReportResult.TempStream.Position := 0;
            if not AnReportResult.IsStreamData then
            begin
              AnReportResult.LoadFromStream(AnReportResult.TempStream);
              AnReportResult.TempStream.Clear;
            end;
          finally
            LocReportResult.Clear;
          end    }
        end else
        begin
          Result := False;
          AnParamAndResult :=
            'Функция отчета должна вернуть объект BaseQueryList.'#13#10 +
            'Проверьте наличие инструкции: Set <function_name> = BaseQueryList';
        end
      else
      if AnFunction.Module = ParamModuleName then
      begin
        if not VarIsArray(AnParamAndResult) then
        begin
          Result := False;
          if (VarType(AnParamAndResult) <> varEmpty) then
            AnParamAndResult := 'Функция параметров должна возвращать массив.';
        end
      end else
        if AnFunction.Module = EventModuleName then
        begin
          Result := (VarType(AnParamAndResult) in [varBoolean, varSmallInt, varByte]);
          if Result then
          begin
            TempInt := AnParamAndResult;
            Result := ((TempInt = 0) or (TempInt = 1));
          end;
          if not Result then
            AnParamAndResult := 'При написании скрипта должна использоваться функция.'#13#10 +
             'Ее результатом должено быть булевское значение 0 либо 1.';
        end;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      AnParamAndResult := E.Message;
    end;
  end;
end;

procedure TBaseReport.SetTransactionParams;
begin
  {$IFDEF DEBUG}
  SaveLog('    SetTransactionParams');
  {$ENDIF}
  FTransaction.Params.Clear;
  FTransaction.Params.Add('read_committed');
  FTransaction.Params.Add('rec_version');
  FTransaction.Params.Add('nowait');
end;

function TBaseReport.InputParams(const AnFunction: TrpCustomFunction; out AnParamResult: Variant): Boolean;
var
  {$IFNDEF GEDEMIN}
  LocRpScrCtrl: TReportScript;
  {$ENDIF}
  LocParamList: TgsParamList;
  I: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog('    InputParams');
  {$ENDIF}
  {$IFNDEF GEDEMIN}
  SetOnCreateEvets;
  {$ENDIF}
  Result := False;
  LocParamList := TgsParamList.Create;
  try
    GetParamsFromText(LocParamList, AnFunction.Name, AnFunction.Script.Text);
    if AnFunction.EnteredParams.Count = LocParamList.Count then
    begin
      Result := True;
      for I := 0 to LocParamList.Count - 1 do
        Result := Result and (UpperCase(LocParamList.Params[I].RealName) =
         UpperCase(AnFunction.EnteredParams.Params[I].RealName));
    end;
  finally
    LocParamList.Free;
  end;

  if Result and Assigned(ParamGlobalDlg) and ParamGlobalDlg.IsEventAssigned then
  begin
    ParamGlobalDlg.QueryParams(GD_PRM_REPORT, AnFunction.FunctionKey, AnFunction.EnteredParams, Result);
    AnParamResult := AnFunction.EnteredParams.GetVariantArray;
  end else
    begin
      {$IFDEF GEDEMIN}
      Result := ScriptFactory.InputParams(AnFunction, AnParamResult);
      {$ELSE}
      if FReportScriptControl.IsBusy then
      begin
        LocRpScrCtrl := TReportScript.CreateWithParam(nil, True, True);
        try
          LocRpScrCtrl.OnCreateConst := FReportScriptControl.OnCreateConst;
          LocRpScrCtrl.OnCreateVBClasses := FReportScriptControl.OnCreateVBClasses;
          LocRpScrCtrl.OnCreateObject := FReportScriptControl.OnCreateObject;
          LocRpScrCtrl.OnIsCreated := FReportScriptControl.OnIsCreated;
          LocRpScrCtrl.OnCreateModuleVBClasses := FReportScriptControl.OnCreateModuleVBClasses;
          LocRpScrCtrl.Transaction := FTransaction;

  //        LocRpScrCtrl.CreateConst;
  //        LocRpScrCtrl.CreateObject;
  //        LocRpScrCtrl.CreateVBClasses;
  //        LocRpScrCtrl.CreateGlobalObj;
          Result := LocRpScrCtrl.InputParams(AnFunction, AnParamResult);
        finally
          LocRpScrCtrl.Free;
        end;
      end else
        Result := FReportScriptControl.InputParams(AnFunction, AnParamResult);
      {$ENDIF}
    end;
end;

procedure TBaseReport.Refresh;
begin
  {$IFDEF DEBUG}
  SaveLog('    Refresh');
  {$ENDIF}
  try
    PrepareSourceDatabase;
    try
      FReportList.Refresh;
    finally
      UnPrepareSourceDatabase;
    end;
  except
    on E: Exception do
    begin
      SaveLog(E.Message);
      Application.Terminate;
    end;
  end;
end;

procedure TBaseReport.PrepareSourceDatabase;
begin
  {$IFDEF DEBUG}
  SaveLog('    PrepareSourceDatabase');
  {$ENDIF}
  if FLocState = 0 then
  begin
    FLocStateDB := FDatabase.Connected;
    FLocStateTR := FTransaction.InTransaction;
    if not FLocStateDB then
      FDatabase.Connected := True;
    if not FLocStateTR then
      FTransaction.StartTransaction;
  end;
  Inc(FLocState);
end;

procedure TBaseReport.CheckScriptControl;
begin
  {$IFDEF DEBUG}
  SaveLog('    CheckScriptControl');
  {$ENDIF}
  {$IFNDEF GEDEMIN}
  if not Assigned(FReportScriptControl) then
    raise Exception.Create(ScriptControlNotRegister);
  {$ENDIF}
end;

procedure TBaseReport.UnPrepareSourceDatabase;
begin
  {$IFDEF DEBUG}
  SaveLog('    UnPrepareSourceDatabase');
  {$ENDIF}
  Dec(FLocState);
  if FLocState = 0 then
  begin
    if not FLocStateTR then
      FTransaction.Commit;
    if not FLocStateDB then
      FDatabase.Connected := False;
  end;
end;

function TBaseReport.FindReportNow(const AnReportKey: Integer;
  const AnCustomReport: TCustomReport; const AnReadTemplate: Boolean): Boolean;
var
  TempQuery: TIBQuery;
  ParamKey, MainKey, EventKey: Integer;
  FunctionKeyList: TgdKeyArray;

  procedure AddIncludingFunctions(const AddQuery: TIBQuery; const AnFunction: TrpCustomFunction;
    const KeyList: TgdKeyArray);
  var
    i: Integer;
    LFunction: TrpCustomFunction;
  begin
    AddQuery.Close;
    AddQuery.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
    LFunction := TrpCustomFunction.Create;
    try
      for i := 0 to KeyList.Count - 1 do
      begin
        if FunctionKeyList.IndexOf(KeyList.Keys[i]) > -1 then
          Continue;

        AddQuery.Close;
        AddQuery.Params[0].AsInteger := KeyList.Keys[i];
        AddQuery.Open;
        LFunction.ReadFromDataSet(AddQuery);
        AnFunction.Script.Text := AnFunction.Script.Text +
          #13#10 + LFunction.Script.Text;
        FunctionKeyList.Add(KeyList.Keys[i]);
        if LFunction.IncludingList.Count > 0 then
          AddIncludingFunctions(AddQuery, AnFunction, LFunction.IncludingList);
      end;
    finally
      LFunction.Free;
    end;

    for i := 0 to AnFunction.IncludingList.Count - 1 do
    begin
      if FunctionKeyList.IndexOf(AnFunction.IncludingList[i]) = -1 then
      begin
      end;
    end;

    AddQuery.Close;

  end;

begin
  {$IFDEF DEBUG}
  SaveLog('    FindReportNow');
  {$ENDIF}
  Result := False;
  try
    PrepareSourceDatabase;
    try
      TempQuery := TIBQuery.Create(nil);
      try
        TempQuery.Database := FDatabase;
        TempQuery.Transaction := FTransaction;
        TempQuery.SQL.Text := 'SELECT * FROM rp_reportlist WHERE id = ' + IntToStr(AnReportKey);
        TempQuery.Open;
        if TempQuery.Eof then
          raise Exception.Create(Format('Запись отчета %d не найдена.', [AnReportKey]));
        AnCustomReport.ReadFromDataSet(TempQuery, AnReadTemplate);

        ParamKey := TempQuery.FieldByName('paramformulakey').AsInteger;
        MainKey := TempQuery.FieldByName('mainformulakey').AsInteger;
        EventKey := TempQuery.FieldByName('eventformulakey').AsInteger;

        TempQuery.Close;
        TempQuery.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';

        FunctionKeyList := TgdKeyArray.Create;
        try
          TempQuery.Close;
          if ParamKey > 0 then
          begin
            TempQuery.Params[0].AsInteger := ParamKey;
            TempQuery.Open;
          end;
          AnCustomReport.ParamFunction.ReadFromDataSet(TempQuery);
//          AddIncludingFunctions(TempQuery, AnCustomReport.ParamFunction,
//            AnCustomReport.ParamFunction.IncludingList);
//          AnCustomReport.ParamFunction.IncludingList.Clear;

          TempQuery.Close;
          if MainKey > 0 then
          begin
            TempQuery.Params[0].AsInteger := MainKey;
            TempQuery.Open;
          end;
          AnCustomReport.MainFunction.ReadFromDataSet(TempQuery);
//          AddIncludingFunctions(TempQuery, AnCustomReport.MainFunction,
//            AnCustomReport.MainFunction.IncludingList);
//          AnCustomReport.MainFunction.IncludingList.Clear;

          TempQuery.Close;
          if EventKey > 0 then
          begin
            TempQuery.Params[0].AsInteger := EventKey;
            TempQuery.Open;
          end;
          AnCustomReport.EventFunction.ReadFromDataSet(TempQuery);
//          AnCustomReport.EventFunction.ReadFromDataSet(TempQuery);
//          AddIncludingFunctions(TempQuery, AnCustomReport.EventFunction,
//            AnCustomReport.EventFunction.IncludingList);
//          AnCustomReport.EventFunction.IncludingList.Clear;
        finally
          FunctionKeyList.Free;
        end;

        Result := True;
      finally
        TempQuery.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  except
    on E: Exception do
      SaveLog(E.Message);
{    on E: Exception do
      if (Self is TClientReport) then
        MessageBox(0, PChar('Произошла ошибка при поиске отчета.'#13#10 + E.Message),
         'Ошибка', MB_OK or MB_ICONERROR);}
  end;
end;

function TBaseReport.FindFunctionNow(const AnFunctionKey: Integer;
  const AnCustomReport: TCustomReport;
  const AnReadTemplate: Boolean): Boolean;
var
  TempQuery: TIBQuery;
//  ParamKey, MainKey, EventKey: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog('    FindFunctionNow');
  {$ENDIF}
  Result := False;
  try
    AnCustomReport.FrqRefresh := 100;
    PrepareSourceDatabase;
    try
      TempQuery := TIBQuery.Create(nil);
      try
        TempQuery.Database := FDatabase;
        TempQuery.Transaction := FTransaction;
        TempQuery.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
        TempQuery.Params[0].AsInteger := AnFunctionKey;
        TempQuery.Open;
        if TempQuery.Eof then
          raise Exception.Create(Format('Запись функции %d не найдена.', [AnFunctionKey]));
        AnCustomReport.MainFunction.ReadFromDataSet(TempQuery);
        Result := True;
      finally
        TempQuery.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  except
    on E: Exception do
      SaveLog(E.Message);
{    on E: Exception do
      if (Self is TClientReport) then
        MessageBox(0, PChar('Произошла ошибка при поиске отчета.'#13#10 + E.Message),
         'Ошибка', MB_OK or MB_ICONERROR);}
  end;
end;

procedure TBaseReport.SetOnCreateConst(const Value: TOnCreateObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateConst');
  {$ENDIF}
  FOnCreateConst := Value;
{$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnCreateConst := FOnCreateConst;
{$ENDIF}
end;

procedure TBaseReport.SetOnCreateGlobalObj(const Value: TOnCreateObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateGlobalObj');
  {$ENDIF}
  FOnCreateGlobalObj := Value;
{$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnCreateGlobalObj := FOnCreateGlobalObj;
{$ENDIF}
end;

procedure TBaseReport.SetOnCreateVBClasses(const Value: TOnCreateObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateVBClasses');
  {$ENDIF}
  FOnCreateVBClasses := Value;
{$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnCreateVBClasses := FOnCreateVBClasses;
{$ENDIF}
end;

{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateVBClassesLists;
var
  ibsqlVB: TIBSQL;
  ibtrVB: TIBTransaction;
  TestRS: TReportScript;
  StateDB: Boolean;
  ErrScript: String;
begin
  {$IFDEF DEBUG}
  SaveLog('    CreateVBClassesLists');
  {$ENDIF}
  FVBClasses := '';
  StateDB := FDatabase.Connected;
  ibtrVB := TIBTransaction.Create(nil);
  try
    ibtrVB.DefaultDatabase := FDatabase;
    if not StateDB then
      FDatabase.Open;

    ibsqlVB := TIBSQL.Create(nil);
    try
      ibsqlVB.Database := FDatabase;
      ibsqlVB.Transaction := ibtrVB;
      ibtrVB.StartTransaction;
      try

        ibsqlVB.SQL.Text := 'SELECT * ' +
          'FROM gd_function WHERE module = ''VBCLASSES'' AND modulecode = ' +
          IntToStr(OBJ_APPLICATION);
        ibsqlVB.ExecQuery;

        // сохраняем вб-классы
        TestRS := TReportScript.Create(nil);
        TestRS.OnCreateConst := FReportScriptControl.OnCreateConst;
        TestRS.IsCreate;
        try
          while not ibsqlVB.Eof do
          begin
            try
              FNonLoadSFList.Add(ibsqlVB.FieldByName('id').AsInteger);
              TestRS.AddCode(ibsqlVB.FieldByName('script').AsString);
              FVBClasses := FVBClasses +
                ibsqlVB.FieldByName('script').AsString + #13#10;
            except
              begin
                ErrScript := #13#10 + 'ОШИБКА!!!  Класс ' +  ibsqlVB.FieldByName('Name').AsString +
                  ' не загружен.'#13#10 + '  ' + TestRS.Error.Description + ': ' + TestRS.Error.Text + #13#10 +
                  '  Строка: ' + IntToStr(TestRS.Error.Line) + #13#10 + '  Дата: ';
                SaveLog(ErrScript);
              end;
            end;
            ibsqlVB.Next;
          end;
        finally
          TestRS.Free;
        end;
      finally
        ibtrVB.Commit;
      end;
    finally
      ibsqlVB.Free;
    end;
  finally
    if not StateDB then
      FDatabase.Close;
    ibtrVB.Free;
  end;
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateVBClasses(Sender: TObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    CreateVBClasses');
  {$ENDIF}
  (Sender as TReportScript).AddCode(FVBClasses);
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateConstans(Sender: TObject);
begin
  {$IFDEF DEBUG}
  SaveLog('    CreateConstans');
  {$ENDIF}
  (Sender as TReportScript).AddCode(FConstants);
end;
{$ENDIF}


{$IFNDEF GEDEMIN}
procedure TBaseReport.SetOnCreateEvets;
var
  LVers: Integer;
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnCreateEvets');
  {$ENDIF}
//  if FReportScriptControl.IsBusy
  LVers := Get_gd_functionVersion;
  if Fgd_functionVers <> LVers then
  begin
    Fgd_functionVers := LVers;
    FCreateEventLoad := False;
    FReportScriptControl.ClearFlag := True;
  end;

  if not FCreateEventLoad then
  begin
    FNonLoadSFList.Clear;

    if Assigned(FOnCreateConst) then
      FReportScriptControl.OnCreateConst := FOnCreateConst
    else
      begin
        CreateVBConstLists;
        FReportScriptControl.OnCreateConst := CreateConstans;
      end;
    if Assigned(FOnCreateVBClasses) then
      FReportScriptControl.OnCreateVBClasses := FOnCreateVBClasses
    else
      begin
        CreateVBClassesLists;
        FReportScriptControl.OnCreateVBClasses := CreateVBClasses;
      end;
    if Assigned(FOnCreateGlobalObj) then
      FReportScriptControl.OnCreateGlobalObj := FOnCreateGlobalObj
    else
      begin
        FReportScriptControl.OnCreateGlobalObj := nil;
      end;
    if (not Assigned(FOnIsCreated)) and (FReportScriptControl.NonLoadSFList = nil) then
      FReportScriptControl.NonLoadSFList := FNonLoadSFList;

    FCreateEventLoad := True;
  end;
end;
{$ENDIF}


{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateVBConstLists;
var
  ibsqlVB: TIBSQL;
  ibtrVB: TIBTransaction;
  TestRS: TReportScript;
  StateDB: Boolean;
  ErrScript: String;
begin
  {$IFDEF DEBUG}
  SaveLog('    CreateVBConstLists');
  {$ENDIF}
  FConstants := '';
  StateDB := FDatabase.Connected;
  ibtrVB := TIBTransaction.Create(nil);
  try
    ibtrVB.DefaultDatabase := FDatabase;
    if not StateDB then
      FDatabase.Open;

    ibsqlVB := TIBSQL.Create(nil);
    try
      ibsqlVB.Database := FDatabase;
      ibsqlVB.Transaction := ibtrVB;
      ibtrVB.StartTransaction;
      try
        TestRS := TReportScript.Create(nil);
        try
          ibsqlVB.SQL.Text := 'SELECT * ' +
            'FROM gd_function WHERE module = ''CONST''';
          ibsqlVB.ExecQuery;

          // сохраняем в константы
          while not ibsqlVB.Eof do
          begin
            try
              FNonLoadSFList.Add(ibsqlVB.FieldByName('id').AsInteger);
              TestRS.AddCode(ibsqlVB.FieldByName('script').AsString);
              FConstants := FConstants +
                ibsqlVB.FieldByName('script').AsString + #13#10;
            except
              begin
//                MessageBeep(1000);
                ErrScript := #13#10 + 'ОШИБКА!!!  Блок констант ' +  ibsqlVB.FieldByName('Name').AsString +
                  ' не загружен.'#13#10 + '  ' + TestRS.Error.Description + ': ' + TestRS.Error.Text + #13#10 +
                  '  Строка: ' + IntToStr(TestRS.Error.Line) + #13#10 + '  Дата: ';
                SaveLog(ErrScript);

              end;
            end;
            ibsqlVB.Next;
          end;
        finally
          TestRS.Free;
        end;
      finally
        ibtrVB.Commit;
      end;
    finally
      ibsqlVB.Free;
    end;
  finally
    if not StateDB then
      FDatabase.Close;
    ibtrVB.Free;
  end;
end;
{$ENDIF}

procedure TBaseReport.SaveLog(const S: String);
{$IFDEF LogReport}
var
  F: TextFile;
{$ENDIF}
begin
  {$IFDEF LogReport}
  if FLogFileName = '' then
    FLogFileName := ChangeFileExt(Application.EXEName, '.log');

  try
    AssignFile(F, FLogFileName);
    if FileExists(FLogFileName) then
      Append(F)
    else
      Rewrite(F);
    try
      Writeln(F, S + ': ' + DateTimeToStr(Now));
      Flush(F);
    finally
      CloseFile(F);
    end;
  except
    //
  end;
  {$ENDIF}
end;

procedure TBaseReport.SetOnIsCreated(const Value: TNotifyEvent);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetOnIsCreated');
  {$ENDIF}
  FOnIsCreated := Value;
{$IFNDEF GEDEMIN}
  if Assigned(FReportScriptControl) then
    FReportScriptControl.OnIsCreated := Value;
{$ENDIF}
end;

{$IFNDEF GEDEMIN}
procedure TBaseReport.SetNonLoadSFList(const Value: TgdKeyArray);
begin
  {$IFDEF DEBUG}
  SaveLog('    SetNonLoadSFList');
  {$ENDIF}
  FReportScriptControl.NonLoadSFList := Value;
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
function TBaseReport.GetNonLoadSFList: TgdKeyArray;
begin
  {$IFDEF DEBUG}
  SaveLog('    GetNonLoadSFList');
  {$ENDIF}
  Result := FReportScriptControl.NonLoadSFList;
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
procedure TBaseReport.CreateModuleVBClass(Sender: TObject;
  const ModuleCode: Integer; VBClassArray: TgdKeyArray);
var
  ibDatasetWork: TIBDataset;
  SF: TrpCustomFunction;
  I: Integer;
  LModuleName: String;
  TrFlag: Boolean;

begin
  {$IFDEF DEBUG}
  SaveLog('    CreateModuleVBClass');
  {$ENDIF}
  VBClassArray.Clear;
  begin
    LModuleName := IntToStr(ModuleCode);
    ibDatasetWork := TIBDataset.Create(nil);
    try
      ibDatasetWork.Transaction := FTransaction;
      TrFlag := FTransaction.Active;
      if not TrFlag then
        FTransaction.StartTransaction;
      try
        ibDatasetWork.SelectSQL.Text := 'SELECT * ' +
         'FROM gd_function WHERE module = ''' + scrVBClasses +
         ''' AND modulecode = ' + LModuleName;
        ibDatasetWork.Open;
        ibDatasetWork.First;

        VBClassArray.Clear;

        if not ibDatasetWork.IsEmpty then
        begin
          SF := TrpCustomFunction.Create;
          try
            while not (ibDatasetWork.Eof) do
            begin
                SF.ReadFromDataSet(ibDatasetWork);
                I := VBClassArray.Add(SF.FunctionKey, True);
                try
                  (Sender as TReportScript).AddScript(SF, LModuleName, ModuleCode);
                except
                  { TODO : Ошибка добавления класса, надо добавить в лог. }
                  VBClassArray.Delete(I);
                end;
              ibDatasetWork.Next;
            end;
          finally
            SF.Free;
          end;
        end;
      finally
        if not TrFlag then
          FTransaction.Commit;
      end;
    finally
      ibDatasetWork.Free;
    end;
  end;
end;
{$ENDIF}

{$IFNDEF GEDEMIN}
function TBaseReport.Get_gd_functionVersion: Integer;
var
  IBSQL: TIBSQL;
  TrState: Boolean;
begin
  {$IFDEF DEBUG}
  SaveLog('    Get_gd_functionVersion');
  {$ENDIF}
  Result := -1;
  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Transaction := FTransaction;
    TrState := FTransaction.Active;
    if not TrState then
      FTransaction.StartTransaction;
    IBSQL.SQL.Text :=
      'SELECT GEN_ID(gd_g_functionch, 0) FROM rdb$database';
    IBSQL.ExecQuery;
    if not IBSQL.Eof then
      Result := IBSQL.Fields[0].AsInteger;
  finally
    IBSQL.Free;
  end;
end;
{$ENDIF}

end.



