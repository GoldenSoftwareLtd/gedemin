// ShlTanya, 26.02.2019

{++

  Copyright (c) 2002 - 2016 by Golden Software of Belarus, Ltd

  Module

    gd_ScriptFactory.pas

  Abstract

    Gedemin project.
    TgdScriptFactory

  Author

    Andrey Shadevsky
    Dubrovnik Alexander

  Revisions history

    1.00    21.02.02    JKL        Header was created.
    1.01    22.02.02    Dalex      Initial version
    1.10    26.02.02    Dalex      Optimization
    1.11    18.06.03    Dalex      Exceptions in VBScript are handled within 'Except' statements

--}

unit gd_ScriptFactory;

interface

uses
  Windows, Classes, gd_i_ScriptFactory, rp_ReportScriptControl,
  rp_BaseReport_unit, prm_ParamFunctions_unit, Sysutils, DB,
  rp_report_const, scr_i_FunctionList, IBDataBase, IBQuery, scrMacrosGroup,
  ibsql, scktcomp, rp_ReportServer, rp_msgConnectServer_unit, Forms,
  messages, gd_SetDatabase, rp_prgReportCount_unit, rp_msgErrorReport_unit,
  gd_DebugLog, gd_KeyAssoc, gd_ScrException, obj_i_Debugger, prp_PropertySettings,
  contnrs, gdcBaseInterface;

type
  TgsScriptExceptionError = class;

  // ������ ������� ������ ��������� ���� �� ����������.
  // �� �������� �� ���������� ������-�������,
  TgdScriptFactory = class(TComponent, IgdScriptFactory)
  private
    FLocStateDB, FLocStateTR: Boolean;
    FLocState: Integer;
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FscrException: EScrException;
    // ���� FErrorEvent <> nil, �� ��������� � ���� ������������ ������
    FErrorEvent: TNotifyEvent;
    FVBReportScript: TReportScript;
    FErrorList: TgdErrorlList;
    FExceptionFlags: TExceptionFlags;
    FInExcepted: Boolean;
    FScriptExceptionError: TgsScriptExceptionError;

    function GetCreateConst: TOnCreateObject;
    function GetCreateGlobalObj: TOnCreateObject;
    function GetCreateVBClasses: TOnCreateObject;
    function GetCreateObject: TOnCreateObject;
    function GetShowRaise: Boolean;
    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;

    // ����� ���������� ������ �� ����� �������
    function FindMacros
       (const AFunctionKey: TPrimaryKey;
        const AMacros: TscrMacrosItem): Boolean; overload;
    // ���� �� ����� � ���������� � �� ������
    function FindMacros
       (const AName: String;
        const AMacros: TscrMacrosItem): Boolean; overload;
    // ���� ������ �� ����� � ����� �������, � ���. �� �����������
    function FindMacros
       (const AName, AObjectName: String;
        const AMacros: TscrMacrosItem): Boolean; overload;

    procedure SetCreateConst(const Value: TOnCreateObject);
    procedure SetCreateGlobalObj(const Value: TOnCreateObject);
    procedure SetCreateObject(const Value: TOnCreateObject);
    procedure SetCreateVBClasses(const Value: TOnCreateObject);
    procedure SetShowRaise(const Value: Boolean);
    procedure SetDatabase(Source: TIBDatabase);
    procedure SetTransaction(Source: TIBTransaction);

    procedure PrepareSourceDatabase; virtual;
    procedure UnPrepareSourceDatabase; virtual;

    function  FindObjectFunction(const AFuncName,
      AnObjectName: String; AFunction: TrpCustomFunction): Boolean;
    // ��������� ��������� �� ������ AErrMrg � ���� ErrScript.Log
    procedure AddErrorMsgInLog(const Name, ErrMsg: String;
      const FunctionKey: TID; const Line: Integer);
    // ��� ����������.
    // ���� ������, �� ���������� ���������� �� �����, ����� �� VB
    function DelphiException(const RS: TReportScript): Boolean;
    function GetOnVBError: TNotifyEvent;

    procedure CreateModuleVBClass(Sender: TObject;
      const ModuleCode: TID; VBClassArray: TgdKeyArray);
    function GetOnIsCreated: TNotifyEvent;
    procedure SetOnIsCreated(const Value: TNotifyEvent);
    function GetNonLoadSFList: TgdKeyArray;
    procedure SetNonLoadSFList(const Value: TgdKeyArray);
    // ���������� ������
    procedure rsErrorHandler(Sender: TObject);
  protected

    function GetErrorList: TgdErrorlList;
    // ������� ���������� ����������.
    function Get_Self: TObject;

    // !!! ����� �������������� ���� ���� ���������, ��� ��������� ������
    //     � ������ ������ �� �����������
    // ��������� ����� ������-������� ������ � ������-���������
    // ModuleName - ��� ������ (��� ���� ModuleKey ��� ������), ModuleKey - ���� ������
    procedure AddScript(const AnFunction: TrpCustomFunction;
                          const ModuleKey: TID = 0; const TestInLoaded: Boolean = True);

    function InputParams(// ���������� ������ �������
                         const AFunction: TrpCustomFunction;
                         // ������������� � ������������ � ������������ ��������� �������
                         out AParamAndResult: Variant): Boolean; overload;

    function InputParams(// ���������� ���� ������-�������
                         const AnFunctionKey : TPrimaryKey;
                         // ������������ ���������
                         out AnParamResult : Variant) : Boolean; overload;

    // ���������� ����� InputParams ������ ���, ��� �������� �������� OwnerForm
    function GiveOwnerForm(const AnFunction: TrpCustomFunction;
       var AnParamResult: Variant; const OwnerFormName: String): Boolean;

    procedure ExecuteFunction(const AFunction: TrpCustomFunction;
      var AParamAndResult: Variant; const AErrorEvent: TNotifyEvent); overload;
    procedure ExecuteFunction(const AFunctionKey: TID;
     AParams: Variant; out AnResult: Variant); overload;

    procedure ExecuteFunction(const AFunction: TrpCustomFunction;
      var AParamAndResult: Variant); overload;
    procedure ExecuteFunction(const AFunction: TrpCustomFunction;
      AParams: Variant; out AResult: Variant); overload;

    // ����� ������ ��� ���������� ������-�������. ��� ���� ������� ��������� � ��������� ���������� ���������� ������� �����������.
    procedure ExecuteFunctionEx
       (// ���������� ������ �������� ������ ������� ���������� ����������.
        const AnFunction : TrpCustomFunction;
        // ������� ��������� ������-�������.
        AnParams : Variant;
        // ��������� ���������� �������
        out AnResult : Variant;
        // ���������� ������
        const AnErrorEvent: TNotifyEvent;
        // ���� ��������� �� ����������� ����������� ���������� ���������� ������-�������.
        AnUseCache : Boolean = False); overload;

    // ����� ����� ����������� ��������������, ������ ������� ���������� �������� ���� ������-�������.
    procedure ExecuteFunctionEx
       (const AnFunctionKey : TPrimaryKey;
        AnParams : Variant;
        out AnResult : Variant;
        const AnErrorEvent: TNotifyEvent;
        AnUseCache : Boolean = False); overload;

    // ����� ��������� ������ ������� ������.
    // �������� ����������� ������ ��������
    // ���� ������, ������������ �������, ����������� ������������� �������,
    // ����� ��������� ��������� ����������
    // � ������ ������������� ������� ���������� ��� �������
    // ��� ������������� �������������
    procedure ExecuteReport
       (AnReportKey : TPrimaryKey;
        AnServerName : String;
        AnUseServer : Boolean;
        AnProcProcess : TProcProcess);

    // ������� ��������� ������. ������������ ���������:
    // ���� �������, ������������ �������, ����������� ��� �������������.
    // � ������ ������������� ������� ���������� ��� �������
    // ��� ������������� �������������
    procedure ExecuteMacros(OwnerForm: OleVariant; AnMacros : TObject);

    // ���������� ������� �������� �� ����� � ��������� ����������
    // � ��������� ����������
    function  ExecuteMacro(const AName, AObjectName: String;
      const AParams: OleVariant): Variant;
    // ���������� �� �� �����
    function  ExecuteScript(const AFunctionKey: TID;
      const AParams: OleVariant): Variant;
    // ���������� �� �� �� ����� � ����� �������, � ���. ��� �����������,
    // � ��������� ���������� � ��������� ����������
    function  ExecuteObjectScript(const AFunctionName,
      AObjectName: String;  const AParams: OleVariant): Variant;

    // ��������� Statement � ������ ���������� ������� � FunctionKey
    procedure ExecuteStatement(const FunctionKey: TID; const Statement: WideString);

    //���������� ���������
    function GetScriptEval(const AnScriptText, AnLanguage: String): Variant;
    function Eval(const Expression: String): Variant;

    function GetScrException: EScrException;
    // ������ ���� ������� ��� ������������� ������
    // ErrorMsg - ��������� �� �����
    // goException = True, ���� �������� �������� ������
{    procedure ErrorDialog(AReportScript: TObject;
      const AnFunction: TrpCustomFunction; const ErrorMsg: String;
      const goException: Boolean);
      }

    // ���������� ����� ��������� ������-�������
    // ���������, ��� �� �������� � ��������� �� ������������ � ��
    procedure ReloadFunction(FunctionKey: TID);

    function  GetExceptionFlags: TExceptionFlags;
    procedure SetExceptionFlags(Value: TExceptionFlags);

    property OnVBError: TNotifyEvent read GetOnVBError;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function  VBScriptControl: TReportScript;
    // ������ ����� ������ ����� ��������� � ������-��������
    procedure Reset;
    procedure ResetVBClasses(const ModuleCode: TID);

    // ������ ����������� ����� ���� ������-��������� ������
    procedure ResetNow;

    // ������������ ���� �������
    // ���� � ���� ������, �� ������������ ������� OnError
    procedure ScriptTest(const AnFunction: TrpCustomFunction);

    property NonLoadSFList: TgdKeyArray read GetNonLoadSFList write SetNonLoadSFList;
  published
    property ShowRaise: Boolean read GetShowRaise write SetShowRaise;
    property DataBase: TIBDatabase read GetDataBase write SetDataBase;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;
    property OnCreateConst: TOnCreateObject read GetCreateConst write SetCreateConst;
    property OnCreateGlobalObj: TOnCreateObject read GetCreateGlobalObj write SetCreateGlobalObj;
    property OnCreateObject: TOnCreateObject read GetCreateObject write SetCreateObject;
    property OnCreateVBClasses: TOnCreateObject read GetCreateVBClasses write SetCreateVBClasses;
    property OnIsCreated: TNotifyEvent read GetOnIsCreated write SetOnIsCreated;
  end;

  TgsScriptExceptionError = class(TObject)
  public
    Line: Integer;
    Description: String;
    SFKey: TID;
  end;

// ����������� ����������
procedure Register;

implementation

uses
  flt_ScriptInterface, mtd_i_Base,
  Controls, evt_i_Base, IBCustomDataSet, gs_Exception, IB, gd_Security,
  gd_security_operationconst, MSScriptControl_TLB, gd_frmErrorInScript,
  prp_MessageConst, prp_methods, gdcOLEClassList, gd_Createable_Form,
  ActiveX, gdcJournal
  {$IFDEF WITH_INDY}
    , gd_WebClientControl_unit
  {$ENDIF}
  {$IFDEF EXCMAGIC_GEDEMIN}
    , ExcMagic_Gedemin
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

type
  TCrackerReportScript = class(TReportScript);

procedure Register;
begin
  RegisterComponents('gsReport', [TgdScriptFactory]);
end;

{ TgdScriptFactory }

constructor TgdScriptFactory.Create(AOwner: TComponent);
begin
  Assert(ScriptFactory = nil, 'This component can be only one.');

  inherited Create(AOwner);

  FInExcepted := False;

  if not (csDesigning in ComponentState) then
  begin
    FscrException := EScrException.Create;
    FErrorList := TgdErrorlList.Create;
  end;

  FVBReportScript := TReportScript.CreateWithParam(Self, True, True);
  FVBReportScript.Name := Format('ReportControl%d', [1]);
  FVBReportScript.OnGenerateException := GetScrException;
  FVBReportScript.OnError := rsErrorHandler;
  FVBReportScript.OnCreateModuleVBClasses := CreateModuleVBClass;
  FErrorEvent := rsErrorHandler;
  ScriptFactory := Self;
end;

destructor TgdScriptFactory.Destroy;
begin
  FVBReportScript.Free;

  if Assigned(ScriptFactory) then
  begin
    if ScriptFactory.Get_Self = Self then
      ScriptFactory := nil;
  end;

  FreeAndNil(FscrException);

  FErrorList.Free;
  inherited;
end;

function TgdScriptFactory.InputParams(const AFunction: TrpCustomFunction;
  out AParamAndResult: Variant): Boolean;
var
  LocParamList: TgsParamList;
  I: Integer;
begin
  Result := False;

  if not Assigned(AFunction) then
    exit;

  if not Assigned(glbFunctionList) then
    Exit;

  LocParamList := TgsParamList.Create;
  try
    GetParamsFromText(LocParamList, AFunction.Name, AFunction.Script.Text);
    if AFunction.EnteredParams.Count = LocParamList.Count then
    begin
      Result := True;
      for I := 0 to LocParamList.Count - 1 do
        Result := Result and (AnsiUpperCase(LocParamList.Params[I].RealName) =
         AnsiUpperCase(AFunction.EnteredParams.Params[I].RealName));
    end;
  finally
    LocParamList.Free;
  end;

  try
    if Result and Assigned(ParamGlobalDlg) and ParamGlobalDlg.IsEventAssigned then
    begin
      ParamGlobalDlg.QueryParams(GD_PRM_REPORT, AFunction.FunctionKey,
        AFunction.EnteredParams, Result);
      AParamAndResult := AFunction.EnteredParams.GetVariantArray;
    end else
      begin
        Result := FVBReportScript.InputParams(AFunction, AParamAndResult);
      end;

  except
    MessageBox(0, PChar(String('������ ��� ����� ����������.'#13#14 +
      '�������: ' + AFunction.Name)), '������',
      MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
    raise;
  end;
end;

procedure TgdScriptFactory.ExecuteFunction(const AFunction: TrpCustomFunction;
  var AParamAndResult: Variant);
var
  TempParams: Variant;
  LEvent: TNotifyEvent;
begin
  TempParams := AParamAndResult;
  LEvent := nil;
  ExecuteFunctionEx(AFunction, TempParams, AParamAndResult, LEvent);
end;

function TgdScriptFactory.Get_Self: TObject;
begin
  Result := Self;
end;

function TgdScriptFactory.GetCreateObject: TOnCreateObject;
begin
  Result := FVBReportScript.OnCreateObject;
end;

function TgdScriptFactory.GetShowRaise: Boolean;
begin
  Result := FVBReportScript.ShowRaise;
end;

function TgdScriptFactory.GetDatabase: TIBDatabase;
begin
  Result := FDatabase;
end;

function TgdScriptFactory.GetTransaction: TIBTransaction;
begin
  Result := FTransaction;
end;

procedure TgdScriptFactory.SetCreateObject(const Value: TOnCreateObject);
begin
  FVBReportScript.OnCreateObject := Value;
end;

procedure TgdScriptFactory.SetShowRaise(const Value: Boolean);
begin
  FVBReportScript.ShowRaise := Value;
end;

procedure TgdScriptFactory.SetDatabase(Source: TIBDatabase);
begin
  FDatabase := Source;
end;

procedure TgdScriptFactory.SetTransaction(Source: TIBTransaction);
begin
  FTransaction := Source;
end;

procedure TgdScriptFactory.PrepareSourceDatabase;
begin
  if FLocState = 0 then
  begin
    FLocStateDB := Database.Connected;
    FLocStateTR := Transaction.InTransaction;
    if not FLocStateDB then
      FDatabase.Connected := True;
    if not FLocStateTR then
      FTransaction.StartTransaction;
  end;
  Inc(FLocState);
end;

procedure TgdScriptFactory.UnPrepareSourceDatabase;
begin
  Dec(FLocState);
  if FLocState = 0 then
  begin
    if not FLocStateTR then
      Transaction.Commit;
    if not FLocStateDB then
      Database.Connected := False;
  end;
end;

function TgdScriptFactory.InputParams
   (const AnFunctionKey : TPrimaryKey;
    out AnParamResult : Variant) : Boolean;
var
  Fnc: TrpCustomFunction;
begin
  Result := False;
  Fnc := glbFunctionList.FindFunction(AnFunctionKey);
  if Fnc <> nil then
  try
    Result := InputParams(Fnc, AnParamResult)
  finally
    glbFunctionList.ReleaseFunction(Fnc);
  end;
end;

procedure TgdScriptFactory.ExecuteFunctionEx
   (const AnFunction : TrpCustomFunction;
    AnParams : Variant;
    out AnResult : Variant;
    const AnErrorEvent: TNotifyEvent;
    AnUseCache : Boolean);
var
  LE: Exception;
begin
  if not Assigned(AnFunction) then
  begin
    exit;
  end;
  // ���� FVBReportScript.Error.Number <> 0, ������ ��� �� ��������� ����������
  // �� � ������� => ����� ������� �� ���������
  if FVBReportScript.Error.Number <> 0 then
    exit;

  // ������� ������ ������
  // ������� ��� ���� ����� �������� � �����
  if FErrorList.Count > 0 then
    FErrorList.Clear;

  if PropertySettings.DebugSet.RuntimeSave then
    TCrackerReportScript(FVBReportScript).CalculateRuntimeTicks := True;
  try
    if gdScrException <> nil then
      FreeAndNil(gdScrException);

    // ��������� ��, ���� �-��� ������� ����, �� ��� ��������
    if not FVBReportScript.ExecuteFunction(AnFunction, AnParams, AnResult) then
    begin
      // ���� gdScrException ����������, �� �������� ��������� �� �����, ������� ���
      // ����� ������ � VB
      try
        if Assigned(FVBReportScript.scrException) then
          if Trim(FVBReportScript.scrException.ExcClass) <> '' then
          try
            FVBReportScript.scrException.GetException;
          finally
            FVBReportScript.scrException.DelRaise;
          end;

        if gdScrException <> nil then
        begin
          LE := ExceptionCopier(gdScrException);
          if LE <> nil then
            raise LE;
        end else
          begin
            if VarType(AnResult) = varString then
            begin
              if AnResult = 'OLE error 800A01C2' then
                raise Exception.Create('��� �������: ' + AnFunction.Name + #13#10 +
                  '������: ��������� ������� ����������� ��� �� ������������� ������������ ���������')
              else if AnResult = 'OLE error 800A001C' then
                raise Exception.Create('��� �������: ' + AnFunction.Name + #13#10 +
                  'Out of stack space. ��������� ��� �� ������� ����������� ��������')
              else
                raise Exception.Create(AnResult);
            end else
              raise Exception.Create('������ �� ����� ���������� ������-�������');
          end;
      finally
        // ������� ������ � ������-��������
        FVBReportScript.Error.Clear;
      end;
    end;
  finally
    if FVBReportScript.Error.Number <> 0 then
      FVBReportScript.Error.Clear;
    // ������� ������ ������
    if FErrorList.Count > 0 then
      FErrorList.Clear;
  end;
end;

procedure TgdScriptFactory.ExecuteFunctionEx
   (const AnFunctionKey : TPrimaryKey;
    AnParams : Variant;
    out AnResult : Variant;
    const AnErrorEvent: TNotifyEvent;
    AnUseCache : Boolean);
var
  Fnc: TrpCustomFunction;
begin
  Assert(glbFunctionList <> nil);

  Fnc := glbFunctionList.FindFunction(AnFunctionKey);
  try
    ExecuteFunctionEx(Fnc, AnParams, AnResult, AnErrorEvent, AnUseCache)
  finally
    glbFunctionList.ReleaseFunction(Fnc);
  end;
end;

function TgdScriptFactory.FindMacros(const AFunctionKey: TPrimaryKey;
  const AMacros: TscrMacrosItem): Boolean;
var
  TempSQL: TIBSQL;
begin
  Result := False;
  if Assigned(AMacros) then
  begin
    PrepareSourceDatabase;
    try
      TempSQL := TIBSQL.Create(nil);
      try
        TempSQL.Database := Database;
        TempSQL.Transaction := Transaction;
        TempSQL.SQL.Text := 'SELECT * FROM Evt_MacrosList WHERE FunctionKey = :FunctionKey';
        SetTID(TempSQL.Params[0], AFunctionKey);
        TempSQL.ExecQuery;
        if TempSQL.Eof then
          raise Exception.Create(Format('������ ������� � �������� %d �� �������.', [TID264(AFunctionKey)]));

        AMacros.FunctionKey := AFunctionKey;
        AMacros.Name := TempSQL.FieldByName('Name').AsString;
        AMacros.ServerKey := GetTID(TempSQL.FieldByName('ServerKey'));

        Result := True;
      finally
        TempSQL.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  end;
end;

procedure TgdScriptFactory.ExecuteReport
   (AnReportKey : TPrimaryKey;
    AnServerName : String;
    AnUseServer : Boolean;
    AnProcProcess : TProcProcess);
begin
  Assert(False, 'Don''t work yet');
end;

procedure TgdScriptFactory.ExecuteMacros(OwnerForm: OleVariant; AnMacros : TObject);
var
  LocFunction: TrpCustomFunction;
  LocParams: Variant;
  AnResult: Variant;
  LMacros: TscrMacrosItem;
const
  MSG_ERROR ='������';
begin
  if Assigned(AnMacros) then
  begin
    if not AnMacros.InheritsFrom(TscrMacrosItem) then
      raise Exception.Create('������������ ������ ������ ���� TscrMacrosItem ������');

    LMacros := TscrMacrosItem(AnMacros);
    // ����� ������� �� �����
    LocFunction := glbFunctionList.FindFunction(LMacros.FunctionKey);
    if Assigned(LocFunction) then
    begin
      try
      // ���� ����������
        if InputParams(LocFunction, LocParams) then
        begin
          // ��������� ����������
          if (LocFunction.EnteredParams.Count > 0) and
            (AnsiUpperCase(Trim(LocFunction.EnteredParams.Params[0].RealName)) =
            VB_OWNERFORM) and (LocFunction.EnteredParams.Params[0].ParamType = prmNoQuery) then
            LocParams[0] := OwnerForm;
          ExecuteFunction(LocFunction, LocParams, AnResult);
        end;
      finally
        glbFunctionList.ReleaseFunction(LocFunction);
      end;
    end else
      MessageBox(0, PChar(Format('�������, ��������������� ������� %s (ID = %d), �� �������!', [LMacros.Name, TID264(LMacros.ID)])), '������',
        MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL)
  end else
    MessageBox(0, '������ �����������!', '������',
      MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
end;

procedure TgdScriptFactory.ExecuteFunction(const AFunction: TrpCustomFunction;
  AParams: Variant; out AResult: Variant);
var
  LEvent: TNotifyEvent;
begin
//  Result := ExecuteFunctionEx(AFunction, AParams, AResult, False);
  LEvent := nil;
  ExecuteFunctionEx(AFunction, AParams, AResult, LEvent, False);
end;

procedure TgdScriptFactory.Reset;
var
  i: Integer;
begin
  // ��������������� ����� ���������� � ����� ������-�������
  for i := 0 to ScriptControlList.Count - 1 do
    TReportScript(ScriptControlList[i]).ClearFlag := True;
end;

function TgdScriptFactory.GetScriptEval(const AnScriptText,
  AnLanguage: String): Variant;
var
  OldErrorHandler: TNotifyEvent;
begin
//  TCrackerReportScript(FVBReportScript).SetLanguage(AnLanguage);
  OldErrorHandler := FVBReportScript.OnError;
  FVBReportScript.OnError := nil;
  try
    Result := FVBReportScript.Eval(AnScriptText);
  finally
    //���� ���  ���������� �������� ������ �� ������� �
    if FVBReportScript.Error.Number <> 0 then
      FVBReportScript.Error.Clear;
    FVBReportScript.OnError := OldErrorHandler;
  end;
end;

function TgdScriptFactory.GetScrException: EScrException;
begin
  Result := FscrException;
end;

function TgdScriptFactory.GetCreateVBClasses: TOnCreateObject;
begin
  Result := FVBReportScript.OnCreateVBClasses;
end;

procedure TgdScriptFactory.ScriptTest(const AnFunction: TrpCustomFunction);
var
  LVBRS: TReportScript;
  ModuleName: String;
begin
  LVBRS := TReportScript.CreateWithParam(nil);
  try
    FErrorList.Clear;
    LVBRS.OnError := FVBReportScript.OnError;
    LVBRS.OnCreateObject := FVBReportScript.OnCreateObject;
    LVBRS.OnCreateConst := FVBReportScript.OnCreateConst;
    LVBRS.OnCreateVBClasses := FVBReportScript.OnCreateVBClasses;
    LVBRS.OnIsCreated := FVBReportScript.OnIsCreated;
    LVBRS.IsCreate;
    LVBRS.NonLoadSFList := FVBReportScript.NonLoadSFList;
    ModuleName :=
      LVBRS.GetModuleNameWithIndex(AnFunction.ModuleCode,
      LVBRS.GetModuleName(AnFunction.ModuleCode));
    LVBRS.AddScript(AnFunction, ModuleName, AnFunction.ModuleCode);
  finally
    LVBRS.Free;
  end;
end;

function TgdScriptFactory.ExecuteMacro(const AName, AObjectName: String;
  const AParams: OleVariant): Variant;
var
  LocMacro : TscrMacrosItem;
  LocFunction: TrpCustomFunction;
  LocParams: Variant;
begin
  Result := '';
  LocMacro := TscrMacrosItem.Create;
  LocParams := AParams;
  try
    if not FindMacros(AName, AObjectName, LocMacro) then
    begin
      Raise Exception.Create('������ ' + AName + ' ��� ������� ' +
        AObjectName + ' �� ������');
      Exit;
    end;

    // ����� ������� �� �����
    LocFunction := glbFunctionList.FindFunction(LocMacro.FunctionKey);
    if Assigned(LocFunction) then
    begin
      try
        // ���� ����������
        if not ((VarType(LocParams) = $200C) or
          (VarType(LocParams) = VarArray)) then
        begin
          if not InputParams(LocFunction, LocParams) then
          begin
            Raise Exception.Create('�� ������� ������ ��������� ��� ������� ' + AName);
          end;
        end else
        begin
          if (FVBReportScript.GetParamsCount(LocFunction) - 1) <>
            (VarArrayHighBound(LocParams, 1) - VarArrayLowBound(LocParams, 1)) then
            Raise Exception.Create('� ������ ' + AName +
              ' ���������� �������� ������ �� ' +
              IntToStr(FVBReportScript.GetParamsCount(LocFunction)) + ' ����������.');
          if VarArrayDimCount(LocParams) > 1 then
            Raise Exception.Create('������ ���������� ������ ���� ����������.');
        end;

        // ��������� ����������
        {$IFDEF DEBUG}
        if UseLog then
          Log.LogLn(DateTimeToStr(Now) + ': ������� ������ ' + LocFunction.Name +
            '  �� ������� ' + TID2S(LocFunction.FunctionKey));
        try
        {$ENDIF}
          ExecuteFunction(LocFunction, LocParams, Result);
        {$IFDEF DEBUG}
          if UseLog then
            Log.LogLn(DateTimeToStr(Now) + ': ������ �� ����� ���������� ������� ' + LocFunction.Name +
              '  �� ������� ' + TID2S(LocFunction.FunctionKey));
        except
          if UseLog then
            Log.LogLn(DateTimeToStr(Now) + ': ������� ���������� ������� ' + LocFunction.Name +
              '  �� ������� ' + TID2S(LocFunction.FunctionKey));
          raise;
        end;
        {$ENDIF}
      finally
        glbFunctionList.ReleaseFunction(LocFunction);
      end;
    end else
      Raise Exception.Create('�������, ��������������� ������� ' + AName + ', �� �������!');
  finally
    LocMacro.Free;
  end;
end;

function TgdScriptFactory.FindMacros(const AName: String;
  const AMacros: TscrMacrosItem): Boolean;
var
  TempSQL: TIBSQL;
begin
  Result := False;
  if Assigned(AMacros) then
  begin
    PrepareSourceDatabase;
    try
      TempSQL := TIBSQL.Create(nil);
      try
        TempSQL.Database := Database;
        TempSQL.Transaction := Transaction;
        TempSQL.SQL.Text := 'SELECT * FROM Evt_MacrosList WHERE Upper(Name) = :Name';
        TempSQL.Params[0].AsString := AnsiUpperCase(AName);
        TempSQL.ExecQuery;
        if TempSQL.Eof then
          raise Exception.Create(Format('������ %s �� ������ � ���� ������.', [AName]));

        AMacros.FunctionKey := GetTID(TempSQL.FieldByName('FunctionKey'));
        AMacros.Name := AName;
        AMacros.ServerKey := GetTID(TempSQL.FieldByName('ServerKey'));

        Result := True;
        TempSQL.Close;
      finally
        TempSQL.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  end;
end;

function TgdScriptFactory.ExecuteScript(const AFunctionKey: TID;
  const AParams: OleVariant): Variant;
var
  LocFunction: TrpCustomFunction;
  LocParams: Variant;
begin
  Result := '';
  LocFunction := glbFunctionList.FindFunction(AFunctionKey);
  if not Assigned(LocFunction) then
    raise Exception.Create('������-������� � ������ ' + TID2S(AFunctionKey) +
      ' �� �������.');

  try
    // �������� �� �������� ����������
    LocParams := AParams;
    if not ((VarType(LocParams) = $200C) or
      (VarType(LocParams) = VarArray)) then
    begin
      if not InputParams(LocFunction, LocParams) then
      begin
        Raise Exception.Create('�� ������� ������ ��������� ��� ������-������� � ������ ' +
          TID2S(AFunctionKey));
      end;
    end else
    begin
      if (FVBReportScript.GetParamsCount(LocFunction) - 1) <>
        (VarArrayHighBound(LocParams, 1) - VarArrayLowBound(LocParams, 1)) then
        Raise Exception.Create('� ������-������� � ������ ' + TID2S(AFunctionKey) +
          ' ���������� �������� ������ �� ' +
          IntToStr(FVBReportScript.GetParamsCount(LocFunction)) + ' ����������.');
      if VarArrayDimCount(LocParams) > 1 then
        Raise Exception.Create('������ ���������� ������ ���� ����������.');
    end;


    ExecuteFunction(LocFunction, LocParams, Result);
  finally
    glbFunctionList.ReleaseFunction(LocFunction);
  end;
end;

function TgdScriptFactory.FindObjectFunction(const AFuncName,
  AnObjectName: String; AFunction: TrpCustomFunction): Boolean;
var
  TempSQL: TIBDataSet;
begin
  Result := False;
  if Assigned(AFunction) then
  begin
    PrepareSourceDatabase;
    try
      TempSQL := TIBDataSet.Create(nil);
      try
        TempSQL.Database := Database;
        TempSQL.Transaction := Transaction;


        if Length(Trim(AnObjectName)) = 0 then
        begin
          TempSQL.SelectSQL.Text := 'SELECT f.* '#13#10+
            'FROM gd_function f '#13#10 +
            'WHERE f.ModuleCode = :ObjectCode and '#13#10 +
            ' upper(f.Name) = :FuncName';
          SetTID(TempSQL.Params[0], OBJ_APPLICATION);
          TempSQL.Params[1].AsString := AnsiUpperCase(AFuncName);
        end else
        begin
          TempSQL.SelectSQL.Text := 'SELECT f.* '#13#10+
            'FROM gd_function f, evt_object o '#13#10 +
            'WHERE upper(o.Name) = :ObjectName and '#13#10 +
            'f.modulecode = o.id and upper(f.Name) = :FuncName';
          TempSQL.Params[0].AsString := AnsiUpperCase(AnObjectName);
          TempSQL.Params[1].AsString := AnsiUpperCase(AFuncName);
        end;
        TempSQL.Open;
        if TempSQL.Eof then
        begin
          if Length(Trim(AnObjectName)) = 0 then
            raise Exception.Create(Format('���������� ������-������� %s �� �������.',
              [AFuncName]))
          else
            raise Exception.Create(Format('������-������� %s ��� ������� %s �� �������.',
              [AFuncName, AnObjectName]));
        end;

        AFunction.ReadFromDataSet(TempSQL);
        Result := True;
      finally
        TempSQL.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  end;
end;

function TgdScriptFactory.ExecuteObjectScript(const AFunctionName,
  AObjectName: String; const AParams: OleVariant): Variant;
var
  LocFunction: TrpCustomFunction;
  LocParams: Variant;
begin
  Result := '';
  LocFunction := TrpCustomFunction.Create;
  try
    if not FindObjectFunction(AFunctionName, AObjectName, LocFunction) then
      raise Exception.Create('������-������� ' + AFunctionName + ' ��� ������� ' +
        AObjectName + ' �� �������.');

    // �������� �� �������� ����������
    LocParams := AParams;
    if not ((VarType(LocParams) = $200C) or
      (VarType(LocParams) = VarArray)) then
    begin
      if not InputParams(LocFunction, LocParams) then
      begin
        Raise Exception.Create('�� ������� ������ ��������� ��� ������-������� ' +
          AFunctionName + ' ������� ' + AObjectName);
      end;
    end else
    begin
      if (FVBReportScript.GetParamsCount(LocFunction) - 1) <>
        (VarArrayHighBound(LocParams, 1) - VarArrayLowBound(LocParams, 1)) then
        raise Exception.Create('� ������-������� ' + AFunctionName +
          ' ������� ' + AObjectName + ' ���������� �������� ������ �� ' +
          IntToStr(FVBReportScript.GetParamsCount(LocFunction)) + ' ����������.');
      if VarArrayDimCount(LocParams) > 1 then
        Raise Exception.Create('������ ���������� ������ ���� ����������.');
    end;

    ExecuteFunction(LocFunction, LocParams, Result);
  finally
    LocFunction.Free;
  end;
end;

function TgdScriptFactory.GetCreateConst: TOnCreateObject;
begin
  Result := FVBReportScript.OnCreateConst;
end;

procedure TgdScriptFactory.SetCreateConst(const Value: TOnCreateObject);
begin
  FVBReportScript.OnCreateConst := Value;
end;

function TgdScriptFactory.GetCreateGlobalObj: TOnCreateObject;
begin
  Result := FVBReportScript.OnCreateGlobalObj;
end;

procedure TgdScriptFactory.SetCreateGlobalObj(
  const Value: TOnCreateObject);
begin
  FVBReportScript.OnCreateGlobalObj := Value;
end;

procedure TgdScriptFactory.SetCreateVBClasses(
  const Value: TOnCreateObject);
begin
  FVBReportScript.OnCreateVBClasses := Value;
end;

procedure TgdScriptFactory.ResetNow;
begin
  TCrackerReportScript(FVBReportScript).Reset;
end;

procedure TgdScriptFactory.AddErrorMsgInLog(
  const Name, ErrMsg: String; const FunctionKey: TID; const Line: Integer);
var
  LStrings: TStrings;
  i: Integer;
  LMsg: String;
  FullFileName: String;

const
  ErrLogFileName = 'ErrScript.log';

begin
  if not FExceptionFlags.SaveErrorLog then
    Exit;

  LMsg := Format('��: %s, ��: %d. ������: %d.'#13#10 + '������: %s',
    [Name, TID264(FunctionKey), Line, ErrMsg]);

  // ���� �������� ������, ���������� ��
  try
    LStrings := TStringList.Create;
    try
      FullFileName := ExtractFileDir(Application.ExeName)+ '\' + FExceptionFlags.FileName;
      if FileExists(FullFileName) then
        LStrings.LoadFromFile(FullFileName);
      LStrings.Add('----------------'#13#10 + DateTimeToStr(Now) + #13#10 +
        '������������: ' + IBLogin.UserName + #13#10 + LMsg);
      if FExceptionFlags.LimitLines and (LStrings.Count > FExceptionFlags.LinesCount) then
      begin
        for I := LStrings.Count - 1 downto FExceptionFlags.LinesCount do
          LStrings.Delete(0);
      end;
      try
        LStrings.SaveToFile(FullFileName);
      except
  {      MessageBox(0, PChar('���������� ��������� ���������� �� ������.' + #13#10 +
          '�������� ����������� ������������ ��� �����.'), PChar('������'),
          MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);}
      end;
    finally
      LStrings.Free;
    end;
  except
  end;
end;

procedure TgdScriptFactory.ExecuteFunction(
  const AFunction: TrpCustomFunction; var AParamAndResult: Variant;
  const AErrorEvent: TNotifyEvent);
var
  LResult: Variant;
begin
  ExecuteFunctionEx(AFunction, AParamAndResult, LResult, AErrorEvent);
  AParamAndResult := LResult;
end;

procedure TgdScriptFactory.ExecuteFunction(const AFunctionKey: TID;
  AParams: Variant; out AnResult: Variant);
var
  LEvent: TNotifyEvent;
begin
  LEvent := nil;
  ExecuteFunctionEx(AFunctionKey, AParams, AnResult, LEvent);
end;

procedure TgdScriptFactory.ReloadFunction(FunctionKey: TID);
var
  i: Integer;
begin
  // ���������� �� ��� ��
  for i := 0 to ScriptControlList.Count - 1 do
    TReportScript(ScriptControlList[i]).AddReloadFunction(FunctionKey);
end;

function TgdScriptFactory.VBScriptControl: TReportScript;
begin
  Result := FVBReportScript;
end;

function TgdScriptFactory.FindMacros(const AName, AObjectName: String;
  const AMacros: TscrMacrosItem): Boolean;
var
  TempSQL: TIBSQL;
begin
  Result := False;
  if Assigned(AMacros) then
  begin
    PrepareSourceDatabase;
    try
      TempSQL := TIBSQL.Create(nil);
      try
        TempSQL.Database := Database;
        TempSQL.Transaction := Transaction;
        if Length(Trim(AObjectName)) = 0 then
        begin
          TempSQL.SQL.Text :=
            'SELECT m.* FROM evt_macroslist m'#13#10 +
            ' WHERE Upper(m.Name) = :MacroName and m.functionkey IN'#13#10 +
            '   (SELECT f.id FROM gd_function f WHERE f.modulecode = :ApplicationCode)';
          TempSQL.Params[0].AsString := AnsiUpperCase(AName);
          SetTID(TempSQL.Params[1], OBJ_APPLICATION);
        end else
          begin
            TempSQL.SQL.Text :=
              'SELECT m.* FROM evt_macroslist m'#13#10 +
              ' WHERE Upper(m.Name) = :MacroName and m.functionkey IN'#13#10 +
              '   (SELECT f.id FROM gd_function f WHERE f.modulecode ='#13#10 +
              '     (SELECT o.id FROM evt_object o WHERE Upper(o.Name) = :ObjectName))';
            TempSQL.Params[0].AsString := AnsiUpperCase(AName);
            TempSQL.Params[1].AsString := AnsiUpperCase(AObjectName);
          end;
        TempSQL.ExecQuery;
        if TempSQL.Eof then
          raise Exception.Create(Format('������ %s �� ������ � ���� ������.', [AName]));

        AMacros.FunctionKey := GetTID(TempSQL.FieldByName('FunctionKey'));
        AMacros.Name := AName;
        AMacros.ServerKey := GetTID(TempSQL.FieldByName('ServerKey'));

        Result := True;
      finally
        TempSQL.Free;
      end;
    finally
      UnPrepareSourceDatabase;
    end;
  end;
end;

procedure TgdScriptFactory.rsErrorHandler(Sender: TObject);
var
  LErrorItem: TgdErrorItem;
  I: Integer;
  S: string;
  SF: TrpCustomFunction;
  ActiveForm: TCustomForm;
  PSArray: PSafeArray;
  ModuleName: String;
  tmpVar: Variant;
  FinallyRec: TFinallyRec;
  ErrorHanlderScriptKey: TID;
  ScriptModule: IScriptModule;
  ExcFuncPresent: Boolean;
  LastFunctionKey: TID;
  Msg: TMsg;
const
  cError = '������';

  procedure ErrorMessage;
  var
    FuncName: String;
  begin
    if not Assigned(SF) then
      SF := glbFunctionList.FindFunction(LastFunctionKey);
    try
      if Assigned(SF) then
      begin
        FuncName := SF.Name;
        {$IFNDEF EXCMAGIC_GEDEMIN}
          {$IFDEF WITH_INDY}
          if gdWebClientControl <> nil then
          begin
            gdWebClientControl.SendError(FuncName + ', line: ' +
              IntToStr(FErrorList[0].Line) + '. ' +
              TScriptControl(Sender).Error.Description, True);
          end;
          {$ENDIF}
        {$ELSE}
          ExcMagicAdditionalInfo := FuncName + ', line: ' +
            IntToStr(FErrorList[0].Line);
        {$ENDIF}
      end else
        FuncName := '**����������**';
      S :=  GetErrorMessage(TScriptControl(Sender).Error.Source + #13#10 +
        '������-������� ' + FuncName, #13#10 +
        TScriptControl(Sender).Error.Description, TScriptControl(Sender).Error.Text,
        '', FErrorList[0].Line) + #13#10#13#10'���������� � ��������������';
      TgdcJournal.AddEvent(S, 'Macros Exception', -1, nil, True);
      with TfrmErrorInScript.Create(Application) do
      try
        SetErrMessage(S);
        if ShowModal = mrEditFunction then
        begin
          if (Debugger <> nil) and (EventControl <> nil)
            and (IBLogin.Database.Connected) then
          begin
            //�������� �������� �������
            EventControl.EditScriptFunction(LastFunctionKey);
            Debugger.Pause;
          end;
        end;
      finally
        Free;
      end;
    finally
      if Assigned(SF) then
        glbFunctionList.ReleaseFunction(SF);
    end;
  end;

begin
  Assert(Sender.InheritsFrom(TReportScript),
    '���������� ������������ ������ ��� �������� ������ TReportScript.');

  if (Debugger <> nil) and Debugger.IsReseted then
    exit;

  if FScriptExceptionError = nil then
  begin
    if Debugger <> nil then
    begin
      LastFunctionKey := Debugger.LastScriptFunction;
    end;
  end else
    LastFunctionKey := FScriptExceptionError.SFKey;

  try
    if FInExcepted then
    begin
      FErrorList.Clear;
      FInExcepted := False;
    end;
    // ������� � ��������� ������ ��� �������� ������
    LErrorItem := TgdErrorItem.Create;
    with LErrorItem do
    begin
      if FScriptExceptionError <> nil then
      begin
        Line := FScriptExceptionError.Line;
        Pos := 0;
        Text := FScriptExceptionError.Description;
        Msg := Format(MSG_ERROR_IN_SCRIPT,
          [FScriptExceptionError.Description, '']);
      end else
        begin
          if Assigned(gdScrException) and
            (AnsiUpperCase(TReportScript(Sender).Error.Description) <>
            AnsiUpperCase(gdScrException.Message)) then
            Msg := Format(MSG_ERROR_IN_SCRIPT, [TReportScript(Sender).Error.Description,
              ' (' + gdScrException.Message + ') '])
          else
            Msg := Format(MSG_ERROR_IN_SCRIPT,
              [TReportScript(Sender).Error.Description, '']);

          Line := TReportScript(Sender).Error.Line;
          Pos := TReportScript(Sender).Error.Column;
          Text := TReportScript(Sender).Error.Text;
          if Text = '' then
            Text := '������������ ������';
        end;
      if Assigned(Debugger) then
      begin
        if FErrorList.Count = 0 then
          SFID := LastFunctionKey;
      end;
    end;
    // ��������� ������ � ������� � ������ ������
    FErrorList.Add(LErrorItem);

    if (FErrorList.Count = 1) and ((not Assigned(gdScrException)) or
      (Assigned(gdScrException) and (not gdScrException.InheritsFrom(EAbort)))) then
    begin
      SF := glbFunctionList.FindFunction(LastFunctionKey);
      if Assigned(SF) then
      try
        AddErrorMsgInLog(SF.Name, LErrorItem.Msg{TScriptControl(Sender).Error.Description}, SF.FunctionKey,
          LErrorItem.Line)
      finally
        glbFunctionList.ReleaseFunction(SF);
      end else
        AddErrorMsgInLog('**����������**', LErrorItem.Msg, -1, 0);

      if PeekMessage(Msg, 0, WM_QUIT, WM_QUIT, PM_NOREMOVE) then
        exit;

      Application.Restore;

      // ��������� ����� ������������ � ��� ���������
      // ������ ��������� �� ������, ���� ������������ �� �������������, ���,
      // ���� �� ����� ������������� �� �������, ���, ����
      // �� ����� ������������� �� ���������� �������, � ������ ����������.
      if ((not Assigned(IbLogin)) or
        (Assigned(IbLogin) and (not IBLogin.IsUserAdmin)) or
        (not FExceptionFlags.Stop) or (DelphiException(TReportScript(Sender)) and
         (not FExceptionFlags.StopOnInside))) and ((FErrorList.Count = 1){ or FInExcepted}) then
      begin
        // ������ ��������� �� ������, ���� ��� �� ������������� ���������� � �������
        if (not (Assigned(FVBReportScript.scrException) and
          (Trim(FVBReportScript.scrException.ExcClass) <> '')) and
          (not Assigned(gdScrException))) and
          (IBLogin.Database.Connected) then
        begin
          ErrorMessage;
        end;
        Exit;
      end;
      // ���� �� ���������� ���������� ������, ��
      // ������ ������������� � ������� �
      // ������ �� ����� �� ��������������  �� ��������������
      if (not FExceptionFlags.StopOnInside) and ((Assigned(FVBReportScript.scrException) and
        (Trim(FVBReportScript.scrException.ExcClass) <> '')) or
        DelphiException(TReportScript(Sender))) then
      begin
        Exit;
      end;

      if EventControl <> nil then
      begin
        if Debugger <> nil then
        begin
          //���� ������������ ������������� �� ���� ��� ����������� ���������������
          //������
          if Assigned(IbLogin) and IBLogin.IsUserAdmin then
          begin
            Assert(FErrorList.Count > 0);

            S :=  GetErrorMessage(TScriptControl(Sender).Error.Source, #13#10 +
              TScriptControl(Sender).Error.Description, TScriptControl(Sender).Error.Text,
              '', FErrorList[0].Line) + #13#10 +
              '���������� �����������.' + #13#10 +
              '����������� ������� "���������" ��� �����������';
            //������� ��������������
            ActiveForm := Screen.ActiveCustomForm;

            MessageBox(Application.Handle, PChar(S), cError, MB_OK +
              MB_APPLMODAL or MB_ICONERROR or MB_TOPMOST);
            //�������� �������� �������
            EventControl.EditScriptFunction(LastFunctionKey);
            Debugger.Pause;

            if Assigned(ActiveForm) and (FormsList.IndexOf(ActiveForm) > -1) then
            begin
              ActiveForm.BringToFront;
            end;
          end;
        end;
      end;
    end;
    Application.Restore;
  finally
    //���� ������ Except ����������
    if Sender.InheritsFrom(TReportScript) and (not TReportScript(Sender).AddCodeMode) then
    begin
      if (Debugger <> nil) and (Debugger.GetCurrentKeyIndex > -1) then
      begin
        // ������� Debug-���������� ������, ���������� ������
        Debugger.ClearDebugVars(Debugger.GetCurrentKeyIndex);
        // �������� ������ �������-����������� ��� �������� �������
        FinallyRec := Debugger.GetCurrentFinallyParams;
        // ��������� ���� ������-�����������
        ErrorHanlderScriptKey := Debugger.GetCurrentKey;
        // !!! ����� ���� ������ ������ �������� � ����������
        // ��������� ������ �������� �������, �.�. � ���� �������� ���������
        Debugger.DecKeyIndex;
        if Length(Trim(FinallyRec.FinallyScript)) > 0 then
        begin
          SF := glbFunctionList.FindFunction(ErrorHanlderScriptKey);
          if SF <> nil then
          try
            if FVBReportScript.UseModules then
              ModuleName := FVBReportScript.GetModuleNameWithIndex(SF.ModuleCode, SF.Module)
            else
              ModuleName := rsGlobalModule;

            with FinallyRec do
            begin
              I := VarArrayHighBound(ParamArray, 1) - VarArrayLowBound(ParamArray, 1);
              tmpVar := VarArrayCreate([0, I], varVariant);
              for I := VarArrayLowBound(ParamArray, 1) to VarArrayHighBound(ParamArray, 1) do
                tmpVar[I - VarArrayLowBound(ParamArray, 1)] := ParamArray[I];
            end;
            try
              PSArray := FVBReportScript.MakeMakeSafeArray_1(tmpVar);
              try
                FInExcepted := True;
                ExcFuncPresent := False;
                ScriptModule := TScriptControl(Sender).Modules[ModuleName];
                for I := 1 to ScriptModule.Procedures.Count do
                begin
                  if AnsiCompareText(ScriptModule.Procedures[i].Name, FinallyRec.FinallyScript) = 0 then
                  begin
                    ExcFuncPresent := True;
                    Break;
                  end;
                end;
                if ExcFuncPresent then
                begin
                  TScriptControl(Sender).Modules[ModuleName].Run(FinallyRec.FinallyScript, PSArray);
                end else
                  begin
                    for I := 1 to TScriptControl(Sender).Procedures.Count do
                    begin
                      if AnsiCompareText(TScriptControl(Sender).Procedures[i].Name, FinallyRec.FinallyScript) = 0 then
                      begin
                        ExcFuncPresent := True;
                        Break;
                      end;
                    end;
                    if ExcFuncPresent then
                      TScriptControl(Sender).Run(FinallyRec.FinallyScript, PSArray)
                    else
                      begin
                        FScriptExceptionError := TgsScriptExceptionError.Create;
                        try
                          FScriptExceptionError.Line := FinallyRec.Line + 1;
                          FScriptExceptionError.Description :=
                            '����������� ������� ' +  FinallyRec.FinallyScript +
                            ' ���������� Except.';
                          FScriptExceptionError.SFKey := SF.FunctionKey;

                          TScriptControl(Sender).OnError(Sender);
                        finally;
                          FreeAndNil(FScriptExceptionError);
                        end;
                      end;
                  end;


              finally
                FInExcepted := False;
                SafeArrayDestroy(PSArray);
              end;
            finally
              tmpVar[0] := Unassigned;
              tmpVar := Unassigned;
            end;
          finally
            glbFunctionList.ReleaseFunction(SF);
          end;
        end;
      end;
    end;
  end;
end;

function TgdScriptFactory.GetErrorList: TgdErrorlList;
begin
  Result := FErrorList;
end;

function TgdScriptFactory.GetExceptionFlags: TExceptionFlags;
begin
  Result := FExceptionFlags;
end;

procedure TgdScriptFactory.SetExceptionFlags(Value: TExceptionFlags);
begin
  FExceptionFlags := Value;
end;

function TgdScriptFactory.DelphiException(
  const RS: TReportScript): Boolean;
begin
  Result := (0 > RS.Error.Number) or
    (RS.Error.Number > 65535);
end;

function TgdScriptFactory.GetOnVBError: TNotifyEvent;
begin
  Result := FVBReportScript.OnError;
end;

procedure TgdScriptFactory.CreateModuleVBClass(Sender: TObject;
  const ModuleCode: TID; VBClassArray: TgdKeyArray);
var
  ibDatasetWork: TIBSQL;
  SF: TrpCustomFunction;
  I: Integer;
begin
  Assert(Assigned(gdcBaseManager));

  if VBClassArray.Count = 0 then
  begin
    ibDatasetWork := TIBSQL.Create(nil);
    try
      ibDatasetWork.Transaction := gdcBaseManager.ReadTransaction;
      ibDatasetWork.SQL.Text :=
        'SELECT id FROM gd_function WHERE module = ''' +
        scrVBClasses + ''' AND modulecode = :MC';
      SetTID(ibDatasetWork.ParamByName('MC'), ModuleCode);
      ibDatasetWork.ExecQuery;

      VBClassArray.Clear;

      if not ibDatasetWork.EOF then
      begin
        if not Assigned(glbFunctionList) then
          exit;

        while not ibDatasetWork.Eof do
        begin
          SF := glbFunctionList.FindFunction(GetTID(ibDatasetWork.FieldByName('id')));
          if Assigned(SF) then
          begin
            VBClassArray.Add(SF.FunctionKey);
            glbFunctionList.ReleaseFunction(SF);
          end;
          ibDatasetWork.Next;
        end;
      end;
    finally
      ibDatasetWork.Free;
    end;
  end;

  i := 0;
  while i < VBClassArray.Count do
  begin
    SF := glbFunctionList.FindFunction(VBClassArray.Keys[i]);
    try
      try
        (Sender as TReportScript).AddScript(SF, TID2S(ModuleCode), ModuleCode);
        Inc(i);
      except
        VBClassArray.Delete(I);
        FErrorList.Clear;
      end;
    finally
      glbFunctionList.ReleaseFunction(SF);
    end;
  end;
end;

procedure TgdScriptFactory.ResetVBClasses(const ModuleCode: TID);
var
  i: Integer;
begin
  Reset;
  i := TCrackerReportScript(FVBReportScript).ModuleVBClassArray.IndexOf(ModuleCode);
  if i > -1 then
    TgdKeyArray(TCrackerReportScript(FVBReportScript).ModuleVBClassArray.ObjectByIndex[i]).Clear;
end;

function TgdScriptFactory.GiveOwnerForm(
  const AnFunction: TrpCustomFunction; var AnParamResult: Variant;
  const OwnerFormName: String): Boolean;
var
  OwnerForm: TObject;
  I: Integer;
begin
  Result := True;
  if (AnFunction.EnteredParams.Count > 0) and
    (AnsiUpperCase(Trim(AnFunction.EnteredParams.Params[0].RealName)) =
    VB_OWNERFORM) and (AnFunction.EnteredParams.Params[0].ParamType = prmNoQuery) then
  begin
    OwnerForm := Application.FindComponent(OwnerFormName);
    if OwnerForm = nil then
      for I := 0 to Screen.FormCount - 1 do
        if (Screen.Forms[I].InheritsFrom(TCreateableForm)) and
          (CompareText(TCreateableForm(Screen.Forms[I]).InitialName, OwnerFormName) = 0) then
        begin
          OwnerForm := Screen.Forms[I];
          Break;
        end;
        
    if Assigned(OwnerForm) and OwnerForm.InheritsFrom(TCreateableForm) then
      AnParamResult[0] := GetGdcOLEObject(OwnerForm) as IDispatch
    else
      Result := False;
  end;
end;

procedure TgdScriptFactory.AddScript(const AnFunction: TrpCustomFunction;
  const ModuleKey: TID; const TestInLoaded: Boolean);
begin
  try
    FVBReportScript.AddScript(AnFunction,
      FVBReportScript.GetModuleNameWithIndex(ModuleKey,
      FVBReportScript.GetModuleName(ModuleKey)), ModuleKey, TestInLoaded);
  finally
    FVBReportScript.Error.Clear;
  end;
end;

function TgdScriptFactory.GetOnIsCreated: TNotifyEvent;
begin
  Result := FVBReportScript.OnIsCreated;
end;

procedure TgdScriptFactory.SetOnIsCreated(const Value: TNotifyEvent);
begin
  FVBReportScript.OnIsCreated := Value;
end;

function TgdScriptFactory.GetNonLoadSFList: TgdKeyArray;
begin
  Result := FVBReportScript.NonLoadSFList;
end;

procedure TgdScriptFactory.SetNonLoadSFList(const Value: TgdKeyArray);
begin
  FVBReportScript.NonLoadSFList := Value;
end;

procedure TgdScriptFactory.ExecuteStatement(const FunctionKey: TID;
  const Statement: WideString);
var
  tmpFunction: TrpCustomFunction;
  tmpModuleName: String;
begin
  tmpFunction := glbFunctionList.FindFunction(FunctionKey);
  if tmpFunction = nil then
    raise Exception.Create('������� � ID = ' + TID2S(FunctionKey) + ' �� �������.');

  tmpModuleName :=
    FVBReportScript.GetModuleNameWithIndex(tmpFunction.ModuleCode, tmpFunction.Module);
  FVBReportScript.Modules[tmpModuleName].ExecuteStatement(Statement);
end;

function TgdScriptFactory.Eval(const Expression: String): Variant;
var
  OldErrorHandler: TNotifyEvent;
begin
  OldErrorHandler := FVBReportScript.OnError;
  FVBReportScript.OnError := nil;
  try
    Result := FVBReportScript.Eval(Expression);
  finally
    //���� ���  ���������� �������� ������ �� ������� �
    if FVBReportScript.Error.Number <> 0 then
      FVBReportScript.Error.Clear;
    FVBReportScript.OnError := OldErrorHandler;
  end;
end;

end.


