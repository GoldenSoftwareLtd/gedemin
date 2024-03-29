// ShlTanya, 27.02.2019

{++

  Copyright (c) 2000-2016 by Golden Software of Belarus, Ltd

  Module

    rp_ReportScriptControl.pas

  Abstract

    Gedemin project. It is ControlScript for processing of report functions.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    ~01.03.01    JKL        Initial version.
    2.00     20.03.03    DAlex      Final version.

--}

unit rp_ReportScriptControl;

interface

uses
  Classes, rp_BaseReport_unit, MSScriptControl_TLB, IBDatabase,
  ActiveX, SysUtils, Windows, Provider, gd_KeyAssoc, gd_ScrException,
  gd_DebugLog, contnrs, gdcBaseInterface
  {$IFDEF GEDEMIN}
  , obj_i_Debugger
  {$ENDIF};

const
  rsGlobalModule = 'GLOBAL';

type
  TReportScript = class;

  TOnCreateObject = procedure(Sender: TObject) of object;
  TOnGenerateException = function: EScrException of object;
  TOnGetInherited = function(Sender: TObject): IDispatch of object;
  TOnCreate = function(Sender: TObject): IDispatch of object;
  TOnGetRuntimeTicks = procedure(const AnFunction: TrpCustomFunction;
    const RuntimeTicks: DWORD) of object;
  TOnCreateModuleVBClass = procedure(Sender: TObject;
    const ModuleCode: TID; VBClassArray: TgdKeyArray) of object;

  TscHistoryItem = class(TObject)
  private
    FLoadList: TgdKeyDuplArray;
    FRunList: TgdKeyDuplArray;

    function GetRunCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    function AddLoadKey(const AFunctionKey: TID): Integer;
    function AddRunKey(const AFunctionKey: TID): Integer;
    function GetFromLoadList(const AFunctionKey: TID): Integer;
    function GetFromRunList(const AFunctionKey: TID): Integer;

    procedure RemoveLoadKey(const AFunctionKey: TID);
    procedure RemoveRunKey(const AFunctionKey: TID);

    property  RunCount: Integer read GetRunCount;
  end;

  TscHistory = class(TObject)
  private
    FHistoryList: TgdKeyIntAssoc;

    function  GetByIndex(const Index: Integer): TscHistoryItem;
  public
    constructor Create;
    destructor  Destroy; override;

    function  AddLoadKey(const AFunctionKey, AModuleKey: TID): Integer;
    function  AddRunKey(const AFunctionKey, AModuleKey: TID): Integer;
    function  GetHistoryItem(const AModuleKey: TID): TscHistoryItem;
    function  FunctionIsLoad(const AFunctionKey, AModuleKey: TID): Integer;
    function  FunctionIsRun(const AFunctionKey, AModuleKey: TID): Integer;
    function  RunCount: Integer;

    procedure GetLoadModuleList(const ModuleList: TgdKeyArray; const AFunctionKey: TID);
    procedure GetRunModuleList(const ModuleList: TgdKeyArray; const AFunctionKey: TID);
    procedure GetReloadModuleList(const ModuleList: TgdKeyArray; const AFunctionKey: TID);
    // ������� ������ ������� �� ������ ����������� ��� ������
    procedure RemoveLoadKey(const AFunctionKey, AModuleKey: TID); overload;
    // ������� ������ ������� �� ������ ����������� ��� ���� ������
    procedure RemoveLoadKey(const AFunctionKey: TID); overload;
    procedure RemoveRunKey(const AFunctionKey, AModuleKey: TID);
    procedure Reset;
  end;

  TReportScript = class(TScriptControl)
  private
   {$IFDEF DEBUG}
    FRunCountList: TStringList;
   {$ENDIF}
    FOnCreateConst: TOnCreateObject;
    FOnCreateGlobalObj: TOnCreateObject;
    FOnCreateObject: TOnCreateObject;
    FOnCreateVBClasses: TOnCreateObject;
    FOnGenerateException: TOnGenerateException;

    FShowRaise: Boolean;
    FLastParams: Variant;
    FIsBusy: Boolean;
    // ��������� ������� �������, ������, ��������� ��� ���.
    FIsCreate: Boolean;
    FClearFlag: Boolean;
    FFunctionKeyList: TStringList;
    FFunctionKey: TID;
    // ����������� ��
    FHistoryList: TscHistory;
    // ������ ������ ���������� �������
    FReloadList: TgdKeyIntAssoc;
    // �������� ��������������� �� ����� �������� � �� ��������
    // ����������� �������
    FUseModules: Boolean;
    // ����������� ���� (�������� ������� �� �������������)
    FUseCache: Boolean;
    // ������ ������������ �������;
    FAddModule: TgdKeyArray;
    FModuleVBClassArray: TgdKeyObjectAssoc;
    FCalculateRuntimeTicks: Boolean;
    FSelfFunctionList: TObjectList;

    FOnMethodInherited: TOnGetInherited;
    FOnEventInherited: TOnGetInherited;
    FOnGetRuntimeTicks: TOnGetRuntimeTicks;
    FOnCreateModuleVBClasses: TOnCreateModuleVBClass;
    FNonLoadSFList: TgdKeyArray;
    FOnIsCreated: TNotifyEvent;
    FTransaction: TIBTransaction;
    //���� ����������, ��� ����� ���������� ���������� �������
    //������������ ��� ���������� ������ ������� ���������� � ����������
    FAddCodeMode: Boolean;

    function SetParams(var AnParam: Variant): Boolean;
    // ���������� ������-�������
    function  ClearMethod: Boolean;
    procedure SetOnGenerateException(const Value: TOnGenerateException);

    function  GenerateException: EScrException;
    function  GetFunctionByID(const FunctionKey: TID): TrpCustomFunction;

    procedure SetFunctionKey(const Value: TID);
    // ����� ������� ��� �������� �������
    procedure CreateObject; dynamic;
    procedure CreateVBClasses;
    procedure CreateConst;
    procedure CreateGlobalObj;

    function  GetEventInherited: IDispatch;
    function  GetMethodInherited: IDispatch;

    procedure SetOnEventInherited(const Value: TOnGetInherited);
    procedure SetOnMethodInherited(const Value: TOnGetInherited);

    // ��������� �� � ������ ����������� ��, ���������� ����� �������� ��
    procedure AddFunctionRunList(const AnFunction: TrpCustomFunction);
    // ������� �� �� ������� ����������� ��, ���������� ����� ���������� ��
    procedure RemoveFunctionRunList(const AnFunction: TrpCustomFunction);
    // ������������� � ��
    // ���� �� ���� � ������ �����������, �� ��� �� ���������������
    procedure ReloadFunction;
    // ��������� ������-�������
    // AModuleKey - ���� ������, IncludingList - ������ ������-�������
    procedure AddIncludingScript(const AModuleKey: TID;
      IncludingList: TgdKeyIntAssoc; const TestInLoaded: Boolean);
    // ������� ������� �� ������ ������������
    procedure RemoveReloadFunction(const AFunctionKey: TID);
    // ��������� ��� ������������� ����� �� � ��������� ��
    // IsGlobal = True, ���� �� ������ ���� ��������� ��� ����������
    function  AddAndRun(const AnFunction: TrpCustomFunction;
      const IsGlobal: Boolean; const ModuleName: String;
      const FuncIndex: Integer; var ParamsArray: PSafeArray): Variant;
    procedure SetOnGetRuntimeTicks(const Value: TOnGetRuntimeTicks);
    procedure SetCalculateRuntimeTicks(const Value: Boolean);
    procedure SetOnCreateModuleVBClasses(
      const Value: TOnCreateModuleVBClass);
    procedure SetClearFlag(const Value: Boolean);
    procedure SetNonLoadSFList(const Value: TgdKeyArray);
    procedure SetOnIsCreated(const Value: TNotifyEvent);
    procedure SetTransaction(const Value: TIBTransaction);
    function GetUseModules: Boolean;

  protected
    procedure SetLanguage(const AnLanguage: String);

    property  CalculateRuntimeTicks: Boolean
      read FCalculateRuntimeTicks write SetCalculateRuntimeTicks default False;
    property  ModuleVBClassArray: TgdKeyObjectAssoc read FModuleVBClassArray;
    property  OnGetRuntimeTicks: TOnGetRuntimeTicks read FOnGetRuntimeTicks
      write SetOnGetRuntimeTicks;
  public
    // �� ��������� ������ � ��� ������-������� �� ������������;
    constructor Create(AOwner: TComponent); override;
    // ��� ������������� ������������ ��� ���(�) ������ ������������ ���� ������
    constructor CreateWithParam(AOwner: TComponent; const UseCache: Boolean = False;
      const UseModules: Boolean = False);
    destructor Destroy; override;

    function MakeMakeSafeArray_1(TheParams: Variant): PSafeArray;

    procedure AddCode(const Code: WideString);


    // ����� ������� ��� �������� ��������, ��������, �������
    // ������ CreateObject, CreateVBClasses, CreateConst, CreateGlobalObj
    // ��� ������������� ������ �������� ���, �.�. ����� ������������������� ��������.
    procedure IsCreate;

    // ���������� ��� ��� ������, ���� ������ ����������, �� ������ GLOBAL
    function  GetModuleName(ModuleCode: TID): String;
    // ��� ����������, ������� ������ � ������-��������
    // � ���������� ��� ���
    function  GetModuleNameWithIndex(const ModuleCode: TID; const FuncModule: String): String;
    // ��������� ����� ������-������� ������ � ������-���������
    // ModuleName - ��� ������(��� ���� ModuleKey ��� ������), ModuleKey - ���� ������
    // TestInLoaded - ����� �����������, ��������� ���������� �� �������
    procedure AddScript(const AnFunction: TrpCustomFunction;
                        const ModuleName: String = ''; const ModuleKey: TID = 0; const TestInLoaded: Boolean = True);
    // ���������� ������-�������
    // ��������� �������� !!!
    procedure Reset;
    // ���������� ���-�� ���-��� ��� ��
    function GetParamsCount(const AnFunction: TrpCustomFunction): Integer;
    // ������ ����������
    function InputParams(const AnFunction: TrpCustomFunction; out AnParamResult: Variant): Boolean;
    // ���������� �������
    function ExecuteFunction(const AnFunction: TrpCustomFunction;
      var AnParamAndResult: Variant): Boolean; overload;
    // ���������� ������� � ������������ ����������
    function ExecuteFunction(const AnFunction: TrpCustomFunction;
      var AnParam, AnResult: Variant): Boolean; overload;

    // ���������� ���������
    function Eval(const Expression: WideString): OleVariant;

    function SFIsLoaded(const AnFunction: TrpCustomFunction): Boolean;

    // ��������� � ������ ��� ������������
    procedure AddReloadFunction(const AFunctionKey: TID);

    // ������������ ��� ����������� ���������� � safecall �-����
    function SafeCallException(ExceptObject: TObject; ExceptAddr: Pointer):
      HResult; override;

    property ShowRaise: Boolean read FShowRaise write FShowRaise default False;
    property IsBusy: Boolean read FIsBusy;
    // ���� True, �� �� ExecuteFunction ���������� ������� Reset, ��������
    // FFunctionKeyList, FMethodKeyList, ����� ��������� ������� � VB-������
    property ClearFlag: Boolean read FClearFlag write SetClearFlag;
    // ������ ��������� ������ �� �������
    property scrException: EScrException read GenerateException;
    //���� ����������� �������
    property FunctionKey: TID read FFunctionKey write SetFunctionKey;
    property UseModules: Boolean read GetUseModules;

    property NonLoadSFList: TgdKeyArray read FNonLoadSFList write SetNonLoadSFList;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;

    property AddCodeMode: Boolean read FAddCodeMode;

    property OnGenerateException: TOnGenerateException read FOnGenerateException write SetOnGenerateException;
    property OnMethodInherited: TOnGetInherited read FOnMethodInherited write SetOnMethodInherited;
    property OnEventInherited: TOnGetInherited read FOnEventInherited write SetOnEventInherited;

    property OnCreateModuleVBClasses: TOnCreateModuleVBClass read
      FOnCreateModuleVBClasses write SetOnCreateModuleVBClasses;
    // ������� ���������� ����� �������� ���� ��.�������� � ���������� ��.��������
    property OnIsCreated: TNotifyEvent read FOnIsCreated write SetOnIsCreated;

  published
    property OnCreateConst: TOnCreateObject read FOnCreateConst write FOnCreateConst;
    property OnCreateGlobalObj: TOnCreateObject
      read FOnCreateGlobalObj write FOnCreateGlobalObj;
    property OnCreateObject: TOnCreateObject read FOnCreateObject write FOnCreateObject;
    property OnCreateVBClasses: TOnCreateObject
      read FOnCreateVBClasses write FOnCreateVBClasses;
  end;

procedure Register;

function GetErrorMessage(AnSource, AnDescription, AnText, AnErrorMessage: String;
  AnLine: Integer): String;

var
  ScriptControlList: TgdKeyArray;

implementation

uses
  rp_report_const,
  rp_dlgEnterParam_unit,
  Controls,
  gd_security,
  gdcOLEClassList,
  gd_security_operationconst,
  scr_i_FunctionList,
  comobj,
  Forms,
  evt_i_Base,
  IBQuery
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  {$IFDEF WITH_INDY}
    , gdccClient_unit
  {$ENDIF}
  ;

constructor TReportScript.Create(AOwner: TComponent);
begin
  inherited;
  {$IFDEF DEBUG}
  FRunCountList := TStringList.Create;
  {$ENDIF}

  FAddCodeMode := False;

  FNonLoadSFList := TgdKeyArray.Create;
  FHistoryList := TscHistory.Create;
  FAddModule := TgdKeyArray.Create;
  FModuleVBClassArray := TgdKeyObjectAssoc.Create;
  FModuleVBClassArray.OwnsObjects := True;
  Language := 'VBSCRIPT';
  GetModuleNameWithIndex(OBJ_APPLICATION, '');

  FReloadList := TgdKeyIntAssoc.Create;
  {$IFDEF DEBUG}
  if UseLog then
    Log.LogLn(DateTimeToStr(Now) + ': ����� �������� ReportScriptControl ');
  {$ENDIF}
  Language := DefaultLanguage;
  FOnCreateObject := nil;
  FOnCreateConst := nil;
  FOnCreateGlobalObj := nil;
  FOnCreateVBClasses := nil;
  FShowRaise := False;
  FLastParams := VarArrayOf(['']);
  FIsBusy := False;

  FFunctionKeyList := TStringList.Create;
  FFunctionKeyList.Sorted := true;

  FSelfFunctionList := TObjectList.Create(True);

  FUseCache := False;
  FIsCreate := False;
  FClearFlag := False;

  TimeOut := -1;

  ScriptControlList.Add(Integer(Self));
end;

destructor TReportScript.Destroy;
var
  i: Integer;
begin
  {$IFDEF DEBUG}
  FRunCountList.Free;
  {$ENDIF}

  if Assigned(FReloadList) then
  begin
    for i := 0 to FReloadList.Count - 1 do
      TObject(FReloadList.ValuesByIndex[i]).Free;
    FReloadList.Free;
  end;  

  FSelfFunctionList.Free;
  FNonLoadSFList.Free;
  FAddModule.Free;
  FModuleVBClassArray.Free;
  FHistoryList.Free;
  if Assigned(ScriptControlList) then
    ScriptControlList.Remove(Integer(Self));
  FFunctionKeyList.Free;
  {$IFDEF DEBUG}
  if UseLog then
    Log.LogLn(DateTimeToStr(Now) + ': ����� ������������� ReportScriptControl ');
  {$ENDIF}
  inherited;
end;

function TReportScript.InputParams(const AnFunction: TrpCustomFunction; out AnParamResult: Variant): Boolean;
var
  MsgError: String;
  LReportScript: TReportScript;
begin
  FIsBusy := True;
  Result := True;
  LReportScript := TReportScript.Create(nil);
  try
    try
      AnParamResult := NULL;

      LReportScript.Language := AnFunction.Language;
      LReportScript.AddCode(AnFunction.Script.Text);
      AnParamResult := VarArrayCreate([0, LReportScript.Procedures.Item[AnFunction.Name].NumArgs - 1], varVariant);
      if LReportScript.Procedures.Item[AnFunction.Name].NumArgs > 0 then
        Result := SetParams(AnParamResult);
    except
      on E: Exception do
      begin
        MsgError := GetErrorMessage(LReportScript.Error.Source,
          LReportScript.Error.Description, LReportScript.Error.Text,
          E.Message, LReportScript.Error.Line);
        if FShowRaise then
          MessageBox(0, PChar('��������� ������ ��� ��������� ����������:'#13#10
           + MsgError), '������', MB_OK or MB_ICONERROR or MB_TASKMODAL);
        AnParamResult := MsgError;
        Result := False;
      end;
    end;
  finally
    LReportScript.Free;
  end;
  FIsBusy := False;
end;

function TReportScript.ExecuteFunction(const AnFunction: TrpCustomFunction;
  var AnParam, AnResult: Variant): Boolean;
type
  TPArr = array[0..2] of Pointer;
var
  ParamsArray: PSafeArray;
  hRes: HRESULT;
  Data: Variant;
  LFuncIndex: Integer;
  LModuleName: String;
  {$IFDEF GEDEMIN}
  StopFlag: Boolean;
  {$ENDIF}
  {$IFDEF WITH_INDY}
  TstID: Integer;
  {$ENDIF}

  function GetVarArray(TheSafeArray: PSafeArray): Variant;
  var
    Number: Integer;
    LowBound, HighBound, Dim: Integer;
  begin
    Dim := SafeArrayGetDim(TheSafeArray);
    hRes := SafeArrayGetUBound(TheSafeArray, Dim, HighBound);
    if not Succeeded(hRes) then
      raise Exception.Create('Can''t get upper bound!');
    hRes := SafeArrayGetLBound(TheSafeArray, Dim, LowBound);
    if not Succeeded(hRes) then
      raise Exception.Create('Can''t get lower bound!');

    Result := VarArrayCreate([LowBound, HighBound], varVariant);
    if VarIsArray(Result) then
    begin
      for Number := LowBound to HighBound do
      begin
        hRes := SafeArrayGetElement(TheSafeArray, Number, Data);
        Result[Number] := Data;

        if not Succeeded(hRes) then
          raise Exception.Create('Can''t get safe param!');
      end;
    end else
      raise Exception.Create('Can''t create variant param!');
  end;

  function MakeMakeSafeArray(TheParams: Variant): PSafeArray;
  var
    Bound: TSafeArrayBound;
    Number: Integer;
    LowBound, HighBound: Integer;
  begin
    LowBound := 0;
    HighBound := -1;
    if VarIsArray(TheParams) then
    begin
      HighBound := VarArrayHighBound(TheParams, 1);
      LowBound := VarArrayLowBound(TheParams, 1);
    end;

    Bound.cElements := HighBound - LowBound + 1;
    Bound.lLbound := 0;
    Result := SafeArrayCreate(VT_VARIANT, 1, Bound);

    if Assigned(Result) then
    begin
      for Number := LowBound to HighBound do
      begin
        Data := TheParams[Number];
        hRes := SafeArrayPutElement(Result, Number, Data);

        if not Succeeded(hRes) then
          raise Exception.Create('Can''t put safe param!');
      end;
    end else
      raise Exception.Create('Can''t create safe param!');
  end;

begin
  if (AnFunction.Module = scrVBClasses) or (AnFunction.Module = scrConst) then
  begin
    raise Exception.Create('�������� ������������� �������.');
  end;
  FIsBusy := True;
  {$IFDEF GEDEMIN}
  StopFlag := False;
  {$ENDIF}
  {$IFDEF DEBUG}
  try
  {$ENDIF}
    Result := False;
    try
      if not Assigned(AnFunction) then
        exit;

      try
        SetLanguage(AnFunction.Language);
        ClearMethod;
        IsCreate;

        {$IFDEF WITH_INDY}
        TstID := gdccClient.StartPerfCounter('vbs', AnFunction.Name);
        {$ENDIF}

        // ��������� ���������
        ParamsArray := MakeMakeSafeArray(AnParam);
        try
          try
            Error.Clear;
          except
          end;

          //!!! TipTop ���������� 1.11.2002
          // ���� ��� �������
          {$IFDEF GEDEMIN}
          if Assigned(Debugger) then
          begin
            if Debugger.IsPaused then
            begin
              Result := True;
              exit;
            end;

            Debugger.PrepareScript(AnFunction);
            if not Debugger.FunctionRun then
            begin
              StopFlag := True;
              Debugger.FunctionRun := True;
              if Debugger.IsStoped or Debugger.IsReseted then
                Debugger.Run;
            end;
            if Debugger.IsReseted then
              Debugger.Run;
          end;
          //!!!
          {$ENDIF}

          if FUseModules then
          begin
            // �������� ������ ��� ��
            LModuleName := GetModuleNameWithIndex(AnFunction.ModuleCode, AnFunction.Module);
            try
              // �������� �� �� ���������
              ReloadFunction;
              // ������ �� � ������ �����������
              LFuncIndex := FHistoryList.FunctionIsLoad(AnFunction.FunctionKey, AnFunction.ModuleCode);
              // ��������� �� � ������ �����������
              AddFunctionRunList(AnFunction);

              //!!! ��� ������ �������� ������ ��� ����� 1.11.2002

              {$IFDEF DEBUG}
              FRunCountList.Add(AnFunction.Name);
              {$ENDIF}

              // ���������� � ���������� ��
              if  AnFunction.ModuleCode = OBJ_APPLICATION then
              begin
                // ��� ���������� ��
                AnResult := AddAndRun(AnFunction, True, '', LFuncIndex, ParamsArray);
              end else
                // ��� ��������� ��
                begin
                  AnResult := AddAndRun(AnFunction, False, LModuleName, LFuncIndex, ParamsArray);
                end;
            finally
              // �������� �� �� ������ �����������
              RemoveFunctionRunList(AnFunction);
              {$IFDEF DEBUG}
              if FRunCountList.IndexOf(AnFunction.Name) > -1 then
                FRunCountList.Delete(FRunCountList.IndexOf(AnFunction.Name));
              {$ENDIF}
            end;
          end else
            begin
              // ���� ������ �� ������������, �� �����������, ��� ��� ����������
              LFuncIndex := FHistoryList.FunctionIsLoad(AnFunction.FunctionKey, OBJ_APPLICATION);
              AnResult := AddAndRun(AnFunction, True, rsGlobalModule, LFuncIndex, ParamsArray);
            end;

          Result := True;
        finally
          {$IFDEF WITH_INDY}
          gdccClient.StopPerfCounter(TstID);
          {$ENDIF}

          FFunctionKey := 0;
          {$IFDEF GEDEMIN}
          if Assigned(Debugger) then
            //b ���� ������������ ������ ����� ������� ��
            //��� �� ���������� ����������. ������� ���������� �����
            Result := Result and not Debugger.IsReseted;
            //e
            if StopFlag and Debugger.FunctionRun then
            begin
              Debugger.Stop;
              Debugger.FunctionRun := False;
              {$IFDEF DEBUG}
              StopFlag := False;
              {$ENDIF}
              if EventControl <> nil then
                EventControl.PropertyCanChangeCaption := False;
            end;
            {$ENDIF}

          AnParam := GetVarArray(ParamsArray);
          hres := SafeArrayDestroy(ParamsArray);

          if not Succeeded(hRes) then
            raise Exception.Create('Can''t destroy safe array!');
        end;
      except
        on E: EOleException do
        begin
          Result := False;
          if FShowRaise then
            MessageBox(0, PChar('��������� ������ ��� ���������� �������:'#13#10
             + E.Message), '������', MB_OK or MB_ICONERROR or MB_TASKMODAL);
          if Error.Description <> '' then
          begin
            AnResult := String(Error.Description);
          end else
            begin
              AnResult := String(E.Message);
            end;
        end;
        on E: Exception do
        begin
          Result := False;
          AnResult := String(E.Message);
        end;
      end;
    finally
      FIsBusy := False;
    end;
  {$IFDEF DEBUG}
  finally
    if StopFlag then
      raise Exception.Create('���� StopFlag = ��� ������ Debuger ����� ����������')
  end;
  {$ENDIF}
end;

procedure TReportScript.CreateObject;
begin
  if Assigned(FOnCreateObject) then
    FOnCreateObject(Self);
end;

procedure TReportScript.SetLanguage(const AnLanguage: String);
begin
  if AnsiUpperCase(AnLanguage) = 'JSCRIPT' then
  begin
    MessageBox(0, PChar('������ ������ �� ������������ JScript.'),
      PChar('������'), MB_OK or MB_ICONERROR or MB_TASKMODAL);
    raise EAbort.Create('������ ������ �� ������������ JScript.');
  end;
  if AnsiUpperCase(Language) <> AnsiUpperCase(AnLanguage) then
  begin
    ClearMethod;
    Language := AnLanguage;
  end;
end;

function TReportScript.SetParams(var AnParam: Variant): Boolean;
begin
  with TdlgEnterParam.Create(Self) do
  try
    if VarArrayHighBound(AnParam, 1) - VarArrayLowBound(AnParam, 1) =
     VarArrayHighBound(FLastParams, 1) - VarArrayLowBound(FLastParams, 1) then
      AnParam := FLastParams;

    Result := InputParams(AnParam);

    if Result then
      FLastParams := AnParam;
  finally
    Free;
  end;
end;

function GetErrorMessage(AnSource, AnDescription, AnText, AnErrorMessage: String;
  AnLine: Integer): String;
begin
  Result := '';
  if Trim(AnSource) <> '' then
    Result := Result + AnSource  + ': ';
  if Trim(AnDescription) <> '' then
    Result := Result + AnDescription;
  if Trim(AnText) <> '' then
    Result := Result + ' "' + AnText + '"';
  if Trim(Result) = '' then
    Result := AnErrorMessage;
  if AnLine <> 0 then
    Result := Result + ', ������: ' + IntToStr(AnLine);
end;

function TReportScript.ExecuteFunction(const AnFunction: TrpCustomFunction;
  var AnParamAndResult: Variant): Boolean;
var
  LFuncResult: Variant;
begin
  Result := ExecuteFunction(AnFunction, AnParamAndResult, LFuncResult);
  AnParamAndResult := LFuncResult;
end;

procedure Register;
begin
  RegisterComponents('gsReport', [TReportScript]);
end;

procedure TReportScript.CreateVBClasses;
begin
  if Assigned(FOnCreateVBClasses) then
  begin
    FOnCreateVBClasses(Self);
  end;
end;

function TReportScript.ClearMethod: Boolean;
var
  I: Integer;
begin
  {$IFDEF DEBUG}
  if UseLog then
    Log.LogLn('ClearMethod');
  {$ENDIF}
  Result := False;
  if FClearFlag and (FHistoryList.RunCount = 0) then
  begin
    try
      inherited Reset;
    except
    end;
    FIsCreate := False;
    FFunctionKeyList.Clear;

    for i := 0 to FReloadList.Count - 1 do
      TObject(FReloadList.ValuesByIndex[i]).Free;

    FReloadList.Clear;
    FClearFlag := False;
    if FUseModules then
    begin
      FAddModule.Clear;
      if Assigned(IbLogin) {and (IBLogin.IsUserAdmin and
        PropertySettings.Exceptions.Stop) }then
        FModuleVBClassArray.Clear;

      FHistoryList.Reset;
      FHistoryList.GetHistoryItem(OBJ_APPLICATION);
    end;
    Result := True;
  end;
end;

procedure TReportScript.SetOnGenerateException(
  const Value: TOnGenerateException);
begin
  {$IFDEF DEBUG}
  if UseLog then
    Log.LogLn('SetOnGenerateException');
  {$ENDIF}
  FOnGenerateException := Value;
end;

function TReportScript.GenerateException: EScrException;
begin
  if Assigned(FOnGenerateException) then
    Result := FOnGenerateException
  else
    Result := nil;
end;

function TReportScript.GetParamsCount(
  const AnFunction: TrpCustomFunction): Integer;
begin
  SetLanguage(AnFunction.Language);

  if (FReloadList.IndexOf(AnFunction.FunctionKey) > -1) or
    (FHistoryList.FunctionIsRun(AnFunction.FunctionKey, AnFunction.ModuleCode) = -1) then
  begin
    if AnFunction.ModuleCode <> OBJ_APPLICATION then
      AddScript(AnFunction, GetModuleName(AnFunction.ModuleCode), AnFunction.ModuleCode, False)
    else
      AddScript(AnFunction, '', OBJ_APPLICATION, False);
  end;

  if AnFunction.ModuleCode <> OBJ_APPLICATION then
    Result := Modules[GetModuleName(AnFunction.ModuleCode)].Procedures.Item[AnFunction.Name].NumArgs
  else
    Result := Procedures.Item[AnFunction.Name].NumArgs;
end;

procedure TReportScript.CreateConst;
begin
  if Assigned(FOnCreateConst) then
    FOnCreateConst(Self);
end;

procedure TReportScript.CreateGlobalObj;
begin
  if Assigned(FOnCreateGlobalObj) then
    FOnCreateGlobalObj(Self);
end;

procedure TReportScript.IsCreate;
begin
  if not FIsCreate then
  try
    if AnsiUpperCase(Language) = 'VBSCRIPT' then
    begin
      // ����� ������������������ ������ ������������
      FIsCreate := True;
      CreateObject;
      CreateConst;
      CreateVBClasses;
      CreateGlobalObj;
      FClearFlag := False;
      if Assigned(FOnIsCreated) then
        FOnIsCreated(Self);
    end else
      raise Exception.Create('����� ������������ ���� ����������������.');
  except
  end;
end;

function TReportScript.Eval(const Expression: WideString): OleVariant;
begin
  IsCreate;
  Result := inherited Eval(Expression);
end;

procedure TReportScript.SetFunctionKey(const Value: TID);
begin
  FFunctionKey := Value;
end;

procedure TReportScript.Reset;
begin
  ClearFlag := True;
  ClearMethod;
end;

procedure TReportScript.SetOnEventInherited(const Value: TOnGetInherited);
begin
  FOnEventInherited := Value;
end;

procedure TReportScript.SetOnMethodInherited(const Value: TOnGetInherited);
begin
  FOnMethodInherited := Value;
end;

function TReportScript.GetEventInherited: IDispatch;
begin
  if Assigned(FOnEventInherited) then
    Result := FOnEventInherited(Self);
end;

function TReportScript.GetMethodInherited: IDispatch;
begin
  if Assigned(FOnMethodInherited) then
    Result := FOnMethodInherited(Self);
end;

function TReportScript.GetModuleNameWithIndex(const ModuleCode: TID;
  const FuncModule: String): String;
var
  LObj: OleVariant;
  LModuleVBClass: TgdKeyArray;
begin
  Result := GetModuleName(ModuleCode);

  // � ����������� �� ���� �� (FuncModule)
  // ������ ��������� � ������� ��������� Inherited
  if (ModuleCode > 0) and (FAddModule.IndexOf(ModuleCode) = -1) then
  begin
    if {(ModuleCode <> 0) and }(ModuleCode <> OBJ_APPLICATION) then
    begin
      if (FuncModule = scrMethodModuleName) then
      begin
        LObj := GetMethodInherited;
      end else
        begin
          LObj := GetEventInherited;
        end;
      FAddModule.Add(ModuleCode);
      Self.Modules.Add(Result, LObj);

      // �������� VB ������� ��� ������
      if FModuleVBClassArray.IndexOf(ModuleCode) = -1 then
      begin
        FModuleVBClassArray.Add(ModuleCode);
        LModuleVBClass := TgdKeyArray.Create;
        FModuleVBClassArray[ModuleCode] := LModuleVBClass;
      end else
        LModuleVBClass := FModuleVBClassArray[ModuleCode] as TgdKeyArray;
      if Assigned(FOnCreateModuleVBClasses) then
        FOnCreateModuleVBClasses(Self, ModuleCode, LModuleVBClass);
    end
    else
    begin
      FAddModule.Add(OBJ_APPLICATION);
    end;
  end;
end;

function TReportScript.GetModuleName(ModuleCode: TID): String;
begin
  if (ModuleCode = 0) or (ModuleCode = OBJ_APPLICATION) then
    Result := rsGlobalModule
  else
    Result := TID2S(ModuleCode);
end;

constructor TReportScript.CreateWithParam(AOwner: TComponent;
  const UseCache, UseModules: Boolean);
begin
  Create(AOwner);
  FUseCache := UseCache;
  FUseModules := UseModules;
end;

procedure TReportScript.AddIncludingScript(
  const AModuleKey: TID; IncludingList: TgdKeyIntAssoc; const TestInLoaded: Boolean);
var
  i, IncFuncIndex: Integer;
  LocInclFunc: TrpCustomFunction;
begin
  for i := 0 to IncludingList.Count - 1 do
  begin
    if (FNonLoadSFList <> nil) and (FNonLoadSFList.IndexOf(IncludingList[i]) > -1) then
      Continue;

    LocInclFunc := nil;
    IncFuncIndex := -1;
    if FUseCache then
    begin
      // ��������� ���������� ��� �� ��� ���
      // �������� ������ ��� �� � ������ �������� �������
      IncFuncIndex := FHistoryList.FunctionIsLoad(IncludingList[i], AModuleKey);
      // ���� �� � ��� ���, �� ��� ������������
      if IncFuncIndex = -1 then
      begin
        IncFuncIndex := FHistoryList.FunctionIsLoad(IncludingList[i], OBJ_APPLICATION);
      end;
    end;

    if IncFuncIndex = -1 then
    begin
      // ���������� ��
      if not Assigned(LocInclFunc) then
        LocInclFunc := GetFunctionByID(IncludingList[i]);

      if not Assigned(LocInclFunc) then
        raise Exception.Create('�� ������� ������-������� ' + {IncludingList.ValuesByIndex[i] +}
          ', ����������� � #Include ���������.');

      try
        if not (LocInclFunc.Module = scrVBClasses) then
        begin
          if (LocInclFunc.ModuleCode <> OBJ_APPLICATION) and FUseModules then
          begin
            AddScript(LocInclFunc, GetModuleName(AModuleKey), AModuleKey, TestInLoaded);
            if FUseCache then
            begin
              AddIncludingScript(AModuleKey, LocInclFunc.IncludingList, TestInLoaded);
            end;
          end else
            begin
              AddScript(LocInclFunc, '', OBJ_APPLICATION, TestInLoaded);
              if FUseCache then
              begin
                AddIncludingScript(OBJ_APPLICATION, LocInclFunc.IncludingList, TestInLoaded);
              end;
            end;
        end;
      finally
        if glbFunctionList <> nil then
          glbFunctionList.ReleaseFunction(LocInclFunc);
      end;
    end;
  end;
end;

{ TscHistoryItem }

function TscHistoryItem.AddLoadKey(const AFunctionKey: TID): Integer;
begin
  Result := FLoadList.Add(AFunctionKey);
end;

function TscHistoryItem.AddRunKey(const AFunctionKey: TID): Integer;
begin
  Result := FRunList.Add(AFunctionKey);
end;

constructor TscHistoryItem.Create;
begin
  inherited Create;
  FLoadList := TgdKeyDuplArray.Create;
  FLoadList.Duplicates := dupAccept;
  FRunList := TgdKeyDuplArray.Create;
  FRunList.Duplicates := dupAccept;
end;

destructor TscHistoryItem.Destroy;
begin
  FLoadList.Free;
  FRunList.Free;
  inherited;
end;

function TscHistoryItem.GetRunCount: Integer;
begin
  Result := FRunList.Count;
end;

function TscHistoryItem.GetFromLoadList(
  const AFunctionKey: TID): Integer;
begin
  Result := FLoadList.IndexOf(AFunctionKey);
end;

function TscHistoryItem.GetFromRunList(
  const AFunctionKey: TID): Integer;
begin
  Result := FRunList.IndexOf(AFunctionKey);
end;

procedure TscHistoryItem.RemoveLoadKey(const AFunctionKey: TID);
begin
  FLoadList.Remove(AFunctionKey);
end;

procedure TscHistoryItem.RemoveRunKey(const AFunctionKey: TID);
begin
  FRunList.Remove(AFunctionKey);
end;

{ TscHistory }

function TscHistory.GetHistoryItem(const AModuleKey: TID): TscHistoryItem;
var
  i: Integer;
begin
  i := FHistoryList.IndexOf(AModuleKey);
  if i = -1 then
  begin
    i := FHistoryList.Add(AModuleKey);
    Result := TscHistoryItem.Create;
    FHistoryList.ValuesByIndex[i] := Integer(Result);
  end else
    Result := TscHistoryItem(FHistoryList.ValuesByIndex[i]);
end;

function TscHistory.AddLoadKey(const AFunctionKey, AModuleKey: TID): Integer;
var
  LHistoryItem: TscHistoryItem;
begin
  LHistoryItem := GetHistoryItem(AModuleKey);
  Result := LHistoryItem.AddLoadKey(AFunctionKey);
end;

function TscHistory.AddRunKey(const AFunctionKey,
  AModuleKey: TID): Integer;
var
  LHistoryItem: TscHistoryItem;
begin
  LHistoryItem := GetHistoryItem(AModuleKey);
  Result := LHistoryItem.AddRunKey(AFunctionKey);
end;

constructor TscHistory.Create;
begin
  inherited Create;

  FHistoryList := TgdKeyIntAssoc.Create;
end;

destructor TscHistory.Destroy;
begin
  Reset;
  FHistoryList.Free;

  inherited;
end;

function TscHistory.FunctionIsLoad(const AFunctionKey,
  AModuleKey: TID): Integer;
begin
  Result := GetHistoryItem(AModuleKey).GetFromLoadList(AFunctionKey);
end;

function TscHistory.FunctionIsRun(const AFunctionKey,
  AModuleKey: TID): Integer;
begin
  Result := GetHistoryItem(AModuleKey).GetFromRunList(AFunctionKey);
end;

procedure TscHistory.RemoveLoadKey(const AFunctionKey,
  AModuleKey: TID);
begin
  GetHistoryItem(AModuleKey).RemoveLoadKey(AFunctionKey);
end;

procedure TscHistory.RemoveRunKey(const AFunctionKey, AModuleKey: TID);
begin
  GetHistoryItem(AModuleKey).RemoveRunKey(AFunctionKey);
end;

function TscHistory.GetByIndex(const Index: Integer): TscHistoryItem;
begin
  Result := TscHistoryItem(FHistoryList.ValuesByIndex[Index]);
end;

function TscHistory.RunCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FHistoryList.Count - 1 do
    Result := Result + GetByIndex(i).RunCount;
end;

procedure TscHistory.Reset;
var
  i: Integer;
begin
  for i := 0 to FHistoryList.Count - 1 do
    TObject(FHistoryList.ValuesByIndex[i]).Free;
  FHistoryList.Clear;
end;

procedure TReportScript.ReloadFunction;
var
  i, k: Integer;
  j, CurSF: TID;
  LoadModuleList, RunModuleList: TgdKeyArray;
  LocFunc: TrpCustomFunction;
begin
  if FReloadList.Count = 0 then
    exit;

  RunModuleList :=  TgdKeyArray.Create;
  try
    i := 0;
    while i < FReloadList.Count do
    begin
      LoadModuleList := TgdKeyArray(FReloadList.ValuesByIndex[i]);
      CurSF := FReloadList[i];
      if LoadModuleList.Count = 0 then
        FHistoryList.GetLoadModuleList(LoadModuleList, CurSF);
      FHistoryList.GetRunModuleList(RunModuleList, CurSF);
      k := 0;
      while (LoadModuleList <> nil) and (k < LoadModuleList.Count) do
      begin
        LocFunc := GetFunctionByID(CurSF);

        if Assigned(LocFunc) then
        try
          j := LoadModuleList.Keys[k];

          if RunModuleList.IndexOf(j) = -1 then
          begin
            if j = OBJ_APPLICATION then
              AddScript(LocFunc, '', OBJ_APPLICATION, False)
            else
              AddScript(LocFunc, GetModuleName(j), j, False);
            LoadModuleList.Remove(j);
          end else
            Inc(k);
        finally
          if glbFunctionList <> nil then
            glbFunctionList.ReleaseFunction(LocFunc);
        end;
      end;
      if (LoadModuleList <> nil) and (LoadModuleList.Count = 0) then
        RemoveReloadFunction(CurSF)
      else Inc(i);
    end;
  finally
    RunModuleList.Free;
  end;
end;

procedure TscHistory.GetLoadModuleList(const ModuleList: TgdKeyArray;
  const AFunctionKey: TID);
var
  i: Integer;
begin
  ModuleList.Clear;
  for i := 0 to FHistoryList.Count - 1 do
  begin
    if (GetByIndex(i).GetFromLoadList(AFunctionKey) > -1) then
    begin
      ModuleList.Add(FHistoryList.Keys[i]);
    end;
  end;
end;

procedure TscHistory.GetRunModuleList(const ModuleList: TgdKeyArray;
  const AFunctionKey: TID);
var
  i: Integer;
begin
  ModuleList.Clear;
  for i := 0 to FHistoryList.Count - 1 do
  begin
    if (GetByIndex(i).GetFromRunList(AFunctionKey) > -1) then
    begin
      ModuleList.Add(FHistoryList.Keys[i]);
    end;
  end;
end;

procedure TscHistory.GetReloadModuleList(const ModuleList: TgdKeyArray;
  const AFunctionKey: TID);
var
  i: Integer;
  rlItem: TscHistoryItem;
begin
  ModuleList.Clear;
  for i := 0 to FHistoryList.Count - 1 do
  begin
    rlItem := GetByIndex(i);
    if (rlItem.GetFromLoadList(AFunctionKey) > -1) and
       (rlItem.GetFromRunList(AFunctionKey) = -1) then
    begin
      ModuleList.Add(FHistoryList.Keys[i]);
    end;
  end;
end;

procedure TReportScript.AddReloadFunction(const AFunctionKey: TID);
var
  Index: Integer;
begin
  Index := FReloadList.IndexOf(AFunctionKey);
  if Index = -1 then
  begin
    FReloadList.Add(AFunctionKey);
    FReloadList.ValuesByKey[AFunctionKey] := Integer(TgdKeyArray.Create);
  end else
    TgdKeyArray(FReloadList.ValuesByIndex[Index]).Clear;
end;

procedure TReportScript.RemoveReloadFunction(const AFunctionKey: TID);
var
  i: Integer;
begin
  i := FReloadList.IndexOf(AFunctionKey);
  if i > -1 then
  begin
    TObject(FReloadList.ValuesByKey[AFunctionKey]).Free;
    FReloadList.Delete(i);
  end;
end;

procedure TReportScript.AddFunctionRunList(
  const AnFunction: TrpCustomFunction);
var
  i: Integer;
begin
  FHistoryList.AddRunKey(AnFunction.FunctionKey, AnFunction.ModuleCode);
  if AnFunction.IncludingList.Count > 0 then
  begin
    for i := 0 to AnFunction.IncludingList.Count - 1 do
    begin
      if (AnFunction.IncludingList.ValuesByIndex[i] = 0) or
        (AnFunction.IncludingList.ValuesByIndex[i] = OBJ_APPLICATION) then
        FHistoryList.AddRunKey(AnFunction.IncludingList.Keys[i], OBJ_APPLICATION)
      else
        FHistoryList.AddRunKey(AnFunction.IncludingList.Keys[i], AnFunction.ModuleCode);
    end;
  end;
end;

procedure TReportScript.RemoveFunctionRunList(
  const AnFunction: TrpCustomFunction);
var
  i: Integer;
begin
  FHistoryList.RemoveRunKey(AnFunction.FunctionKey, AnFunction.ModuleCode);
  FHistoryList.RunCount;
  if AnFunction.IncludingList.Count > 0 then
  begin
    for i := 0 to AnFunction.IncludingList.Count - 1 do
    begin
      if (AnFunction.IncludingList.ValuesByIndex[i] = 0) or
        (AnFunction.IncludingList.ValuesByIndex[i] = OBJ_APPLICATION) then
        FHistoryList.RemoveRunKey(AnFunction.IncludingList.Keys[i], OBJ_APPLICATION)
      else
        FHistoryList.RemoveRunKey(AnFunction.IncludingList.Keys[i], AnFunction.ModuleCode);
    end;
  end;
end;

procedure TReportScript.AddScript(const AnFunction: TrpCustomFunction;
  const ModuleName: String; const ModuleKey: TID; const TestInLoaded: Boolean);
var
  S: WideString;
begin
  if Assigned(AnFunction) then
  begin
    // ���� ��������� � ������� ����������, �� �������
    if TestInLoaded then
    begin
      if FHistoryList.FunctionIsLoad(AnFunction.FunctionKey, ModuleKey) > -1 then
        Exit;
    end;
    S := AnFunction.Name;
    {$IFDEF GEDEMIN}
    if Assigned(Debugger) then
    begin
      Debugger.ProcBegin(AnFunction.FunctionKey, S);
      try
        Debugger.PrepareExecuteScript(AnFunction);
      except
      end;
    end;
    {$ENDIF}
    try
        if Length(ModuleName) > 0 then
        begin
          FAddCodeMode := True;
          try
            Self.Modules[ModuleName].AddCode(AnFunction.Script.Text);
          finally
            FAddCodeMode := False;
          end;
        end else
          begin
            Self.AddCode(AnFunction.Script.Text)
          end;
        AddIncludingScript(ModuleKey, AnFunction.IncludingList, TestInLoaded);
        FHistoryList.AddLoadKey(AnFunction.FunctionKey, ModuleKey);
    finally
      {$IFDEF GEDEMIN}
      if Assigned(Debugger) then
        Debugger.ProcEnd;
      {$ENDIF}
      //���� �� ����� ���������� �������� ������, ��
      //� ����������� SctiptFactory � ��� ����������.
      //������� ������ ������ ������
      Error.Clear;
    end;
  end;
end;

procedure TscHistory.RemoveLoadKey(const AFunctionKey: TID);
var
  i: Integer;
begin
  for i := 0 to FHistoryList.Count - 1 do
    GetByIndex(i).RemoveLoadKey(AFunctionKey);
end;

function TReportScript.AddAndRun(const AnFunction: TrpCustomFunction;
  const IsGlobal: Boolean; const ModuleName: String; const FuncIndex: Integer;
  var ParamsArray: PSafeArray): Variant;
var
  LModuleName: String;
  LModuleCode: TID;
  LRuntimeTicks: DWORD;
begin
  if IsGlobal then
  begin
    LModuleName := rsGlobalModule;
    LModuleCode := OBJ_APPLICATION;
  end else
    begin
      LModuleName := ModuleName;
      LModuleCode := AnFunction.ModuleCode;
    end;

  if FUseCache then
  begin
    // ���� ������������ ���, �� ��������� �� �� �������������
    if FuncIndex = -1 then
    begin
      AddScript(AnFunction, LModuleName, LModuleCode, False);
    end else
      if FClearFlag and
        (FHistoryList.FunctionIsRun(AnFunction.FunctionKey, LModuleCode) = -1) then
      begin
        AddScript(AnFunction, LModuleName, LModuleCode, False);
      end;
  end else
    // ����� ����� ���������
    begin
      AddScript(AnFunction, LModuleName, LModuleCode, False);
    end;

  if AnFunction.Module = scrVBClasses then
  begin
    Result := Unassigned;
    Exit;
  end;
  // ��������� ��
  LRuntimeTicks := GetTickCount;

  try
    Result := Self.Modules[LModuleName].Run(AnFunction.Name, ParamsArray);
  except
    if IBLogin.Database.Connected then
      raise
    else begin
      Result := Unassigned;
      Exit;
    end;
  end;

  if CalculateRuntimeTicks then
  begin
    LRuntimeTicks := GetTickCount - LRuntimeTicks;
    if Assigned(FOnGetRuntimeTicks) then
      FOnGetRuntimeTicks(AnFunction, LRuntimeTicks);
  end;
end;

procedure TReportScript.SetOnGetRuntimeTicks(
  const Value: TOnGetRuntimeTicks);
begin
  FOnGetRuntimeTicks := Value;
end;

procedure TReportScript.SetCalculateRuntimeTicks(const Value: Boolean);
begin
  FCalculateRuntimeTicks := Value;
end;

procedure TReportScript.SetOnCreateModuleVBClasses(
  const Value: TOnCreateModuleVBClass);
begin
  FOnCreateModuleVBClasses := Value;
end;

procedure TReportScript.SetClearFlag(const Value: Boolean);
begin
  FClearFlag := Value;
end;

procedure TReportScript.SetNonLoadSFList(const Value: TgdKeyArray);
begin
  if Value <> nil then
    FNonLoadSFList.Assign(Value)
  else
    FNonLoadSFList.Clear;
end;

procedure TReportScript.SetOnIsCreated(const Value: TNotifyEvent);
begin
  FOnIsCreated := Value;
end;

function TReportScript.GetFunctionByID(
  const FunctionKey: TID): TrpCustomFunction;
var
  IBQuery: TIBQuery;
  TrState: Boolean;
begin
  Result := nil;
  if glbFunctionList <> nil then
  begin
    Result := glbFunctionList.FindFunction(FunctionKey);
    Exit;
  end;

  if FTransaction = nil then
    Exit;

  IBQuery := TIBQuery.Create(nil);
  try
    IBQuery.Transaction := FTransaction;
    IBQuery.SQL.Text :=
      'SELECT * FROM gd_function WHERE id = ' +  TID2S(FunctionKey);
    if not FTransaction.Active then
    begin
      TrState := False;
      FTransaction.StartTransaction;
    end else
      TrState := True;
    try
      IBQuery.Open;
      if IBQuery.Eof then
        Exit;

      Result := TrpCustomFunction.Create;
      FSelfFunctionList.Add(Result);
      Result.ReadFromDataSet(IBQuery);
    finally
      if not TrState then
        FTransaction.Commit;
    end;
  finally
    IBQuery.Free;
  end;
end;

procedure TReportScript.SetTransaction(const Value: TIBTransaction);
begin
  FTransaction := Value;
end;

function TReportScript.SFIsLoaded(const AnFunction: TrpCustomFunction): Boolean;
var
  LFuncIndex: Integer;
begin
  if FUseModules then
    LFuncIndex := FHistoryList.FunctionIsLoad(AnFunction.FunctionKey, AnFunction.ModuleCode)
  else
    LFuncIndex := FHistoryList.FunctionIsLoad(AnFunction.FunctionKey, OBJ_APPLICATION);

  Result := not LFuncIndex = -1;
end;

function TReportScript.MakeMakeSafeArray_1(TheParams: Variant): PSafeArray;
var
  Bound: TSafeArrayBound;
  Number: Integer;
  LowBound, HighBound: Integer;
  hRes: HRESULT;
  Data: Variant;
begin
  LowBound := 0;
  HighBound := -1;
  if VarIsArray(TheParams) then
  begin
    HighBound := VarArrayHighBound(TheParams, 1);
    LowBound := VarArrayLowBound(TheParams, 1);
  end;

  Bound.cElements := HighBound - LowBound + 1;
  Bound.lLbound := 0;
  Result := SafeArrayCreate(VT_VARIANT, 1, Bound);

  if Assigned(Result) then
  begin
    for Number := LowBound to HighBound do
    begin
      Data := TheParams[Number];
      hRes := SafeArrayPutElement(Result, Number, Data);

      if not Succeeded(hRes) then
        raise Exception.Create('Can''t put safe param!');
    end;
  end else
    raise Exception.Create('Can''t create safe param!');
end;

function TReportScript.GetUseModules: Boolean;
begin
  Result := FUseModules;
end;

procedure TReportScript.AddCode(const Code: WideString);
begin
  FAddCodeMode := True;
  try
    TScriptControl(Self).AddCode(Code);
  finally
    FAddCodeMode := False;
  end;
end;

function TReportScript.SafeCallException(ExceptObject: TObject;
  ExceptAddr: Pointer): HResult;
const
  TReportScriptGUID: TGUID = '{BD866588-A0F6-4D7A-BB4D-5B85E4D684B8}';
begin
  Result := HandleSafeCallException(ExceptObject, ExceptAddr, TReportScriptGUID,
    String(ExceptObject.ClassName), '');
end;

Initialization
  ScriptControlList := TgdKeyArray.Create;

Finalization
  {$IFDEF DEBUG}
  if ScriptControlList.Count > 0 then
    Beep(4000, 1500);
  {$ENDIF}
  FreeAndNil(ScriptControlList);
end.
