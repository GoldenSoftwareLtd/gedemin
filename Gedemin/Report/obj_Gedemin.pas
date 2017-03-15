
{++

  Copyright (c) 2001-2016 by Golden Software of Belarus, Ltd

  Module

    obj_Gedemin.pas

  Abstract

    Gedemin project. COM-object "System". It is used for obtaining params
    of Gedemin.

  Author

    Andrey Shadevsky

  Revisions history

    1.00   ~01.05.01    JKL        Initial version.
    1.01    29.10.01    sai        Добавлены два метода в TgdGedemin
                                   ShowString(S)
                                   ShowSQL(S)

--}

unit obj_Gedemin;

interface

uses
  ComObj, ActiveX, AxCtrls, Gedemin_TLB, StdVcl, Forms, Classes, IBDatabase,
  Windows, gdcConst, obj_WrapperDelphiClasses, gd_i_ScriptFactory, Printers;
  
type
  TgsRecord = class(TAutoObject, IRecord)
  private
    FID: Integer;
    FName: String;
  protected
    function  Get_ID: Integer; safecall;
    function  Get_Name: WideString; safecall;
  public
    constructor Create(const AnID: Integer; const AnName: String);
  end;

type
  TgsReportWindow = class(TAutoObject, IgsDlgWindow)
  private
    FAction: Integer;
  protected
    function  Add(ParentKey: Integer): WordBool; safecall;
    function  Edit(ObjectKey: Integer): WordBool; safecall;
    function  Delete(ObjectKey: Integer): WordBool; safecall;
    function  Execute: WordBool; safecall;
  public
    constructor Create(const ActionType: Integer);
  end;

type
  TReportSystem = class(TAutoObject, IReportSystem)
  private
    procedure CheckClientReport;
  protected
    procedure Refresh; safecall;
    procedure BuildReport(ReportKey: Integer); safecall;
    procedure RebuildReport(ReportKey: Integer); safecall;
    function  Get_ReportGroup: IgsDlgWindow; safecall;
    function  Get_ReportList: IgsDlgWindow; safecall;
    function  Get_DefaultServer: IgsDlgWindow; safecall;
    procedure BuildReportWithParam(ReportKey: Integer; Params: OleVariant); safecall;
    procedure BuildReportWithOwnerForm(const OwnerForm: IgsGDCCreateableForm; ReportKey: Integer); safecall;
    procedure RebuildReportWithParam(ReportKey: Integer; Params: OleVariant); safecall;
    property  ReportGroup: IgsDlgWindow read Get_ReportGroup;
    property  ReportList: IgsDlgWindow read Get_ReportList;
    property  DefaultServer: IgsDlgWindow read Get_DefaultServer;
    procedure BuildReportWithParamPrinter(ReportKey: Integer; Params: OleVariant;
             const PrinterName: WideString; ShowProgress: WordBool); safecall;
    procedure ExportReportWithParam(ReportKey: Integer; Params: OleVariant; 
             const FileName: WideString; const ExportType: WideString); safecall;
  end;

type
  TgsGedemin = class(TAutoObject, IGedemin)
  private
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FwrpIBDatabase: IgsIBDatabase;
    FUnMethod: Boolean;

    function FindWindowByName(const WindowName: WideString): TForm;
    procedure CreateAssertion;

  protected
    function  Get_User: IRecord; safecall;
    function  Get_Contact: IRecord; safecall;
    function  Get_Company: IRecord; safecall;
    function  Get_InGroup: IRecord; safecall;
    function  Get_SubSystem: IRecord; safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    function  ActiveWindow: IgsCreateableForm; safecall;
    function  ExecuteMacro(const Name: WideString; const ObjectName: WideString; Params: OleVariant): OleVariant; safecall;
    function  ExecuteScript(const FunctionName: WideString; const ObjectName: WideString;
                            Params: OleVariant): OleVariant; safecall;
    function  ExecuteScriptFunction(FunctionID: Integer; Params: OleVariant): OleVariant; safecall;
    procedure ExecuteMacros(OwnerFrom: OleVariant; Id: Integer); safecall;
    function  WindowByName(const WindowName: WideString): IgsCreateableForm; safecall;
    function  IsWindowExit(const WindowName: WideString): WordBool; safecall;
    function  WindowExists(const WindowName: WideString): WordBool; safecall;
    function  ReportSystem: IReportSystem; safecall;
    function  Get_GedeminPath: WideString; safecall;
    function  GetNewParamWindow(WindowKey: Integer): IgsParamWindow; safecall;
    procedure EnableMethods; safecall;
    procedure DisableMethods; safecall;

    function  GetGlobal(const Folder: WideString; const Name: WideString): OleVariant; safecall;
    function  GetUser(const Folder: WideString; const Name: WideString): OleVariant; safecall;
    function  GetCompany(const Folder: WideString; const Name: WideString): OleVariant; safecall;
    function  GetValue(const AName: WideString): WideString; safecall;
    function  GetValueByID(AnID: Integer): WideString; safecall;
    procedure ShowString(const S: WideString); safecall;
    procedure ShowSQL(const S: WideString); safecall;
    function  GetSQL(const SQL: WideString): WideString; safecall;
    function  GetPrepareSQL(const SQL: WideString; const AClassname: WideString): WideString; safecall;
    procedure ShowPrepareSQL(const S: WideString; const ClassName: WideString); safecall;
    function  ViewQueryList(const QueryList: IgsQueryList): WordBool; safecall;
    function  ViewDataSet(const DataSet: IgsIBCustomDataSet): WordBool; safecall;

    function  AnsiToOem(const S: WideString): WideString; safecall;
    function  OemToAnsi(const S: WideString): WideString; safecall;
                                    
    function  GetCodeByParams(const ParamList: WideString): LongWord; safecall;
    function  StartPerfCounter(const ASrc: WideString; const AName: WideString): Integer; safecall;
    procedure StopPerfCounter(AnID: Integer); safecall;
    procedure AddLogRecord(const ASrc: WideString; const AText: WideString; AType: Integer;
                           AnObjID: Integer; const AnObjType: WideString; AShowWindow: WordBool); safecall;
    procedure WIN1251ToUTF8(const AWIN1251Stream: IgsStream; const AUTF8Stream: IgsStream); safecall;
    procedure UTF8ToWIN1251(const AUTF8Stream: IgsStream; const AWIN1251Stream: IgsStream); safecall;
    function  ReplaceXMLTags(const S: WideString): WideString; safecall;
    function  ExpandXMLTags(const S: WideString): WideString; safecall;
    function GetCurrRate(ForDate: TDateTime; ValidDays: Integer; RegulatorKey: OleVariant; FromCurrKey: OleVariant;
                             ToCurrKey: OleVariant; CrossCurrKey: OleVariant; Amount: Currency;
                             ForceCross: WordBool; UseInverted: WordBool; RaiseException: WordBool): Double; safecall;
  public
    constructor Create(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction);
    destructor Destroy; override;
  end;

implementation

uses
  ComServ, gd_security, gd_createable_form, obj_QueryList, IBQuery,
  IBCustomDataSet, SysUtils, IBTable, rp_ReportClient, rp_report_const,
  obj_dlgParamWindow, gdc_frmMemo_unit, at_sql_parser, at_sql_setup,
  obj_WrapperGSClasses, gdcOLEClassList, Storages, mtd_i_Base,
  rp_dlgViewResultEx_unit, scrMacrosGroup, jclUnicode, gd_directories_const,
  gd_common_functions, AcctUtils,
  {$IFDEF WITH_INDY}
  gdccClient_unit,
  {$ENDIF}
  {$IFDEF GEDEMIN_LOCK}
  gd_registration,
  {$ENDIF}
  rp_BaseReport_unit, rp_i_ReportBuilder_unit;

{ TgsGedemin }

function TgsGedemin.ActiveWindow: IgsCreateableForm;
var
  LocForm: TForm;
begin
  Result := nil;
  LocForm := Screen.ActiveForm;
  if LocForm.InheritsFrom(TCreateableForm) then
    Result := GetGdcOLEObject(LocForm) as IgsCreateableForm;
end;

constructor TgsGedemin.Create(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction);
begin
  inherited Create;

  FDatabase := AnDatabase;
  FTransaction := AnTransaction;
  FUnMethod := UnMethodMacro;
end;

procedure TgsGedemin.CreateAssertion;
begin
  Assert(IBLogin <> nil, 'IBLogin can''t be nil.');
end;

function TgsGedemin.FindWindowByName(const WindowName: WideString): TForm;
begin
  Result := Application.FindComponent(WindowName) as TForm;
end;

function TgsGedemin.Get_Company: IRecord;
begin
  CreateAssertion;
  Result := TgsRecord.Create(IBLogin.CompanyKey, IBLogin.CompanyName);
end;

function TgsGedemin.Get_Contact: IRecord;
begin
  CreateAssertion;
  Result := TgsRecord.Create(IBLogin.ContactKey, 'Unknown');
end;

function TgsGedemin.Get_GedeminPath: WideString;
begin
  Result := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));
end;

function TgsGedemin.Get_InGroup: IRecord;
begin
  CreateAssertion;
  Result := TgsRecord.Create(IBLogin.Ingroup, IBLogin.GroupName);
end;

function TgsGedemin.Get_SubSystem: IRecord;
begin
  CreateAssertion;
  Result := TgsRecord.Create(IBLogin.SubSystemKey, IBLogin.SubSystemName);
end;

function TgsGedemin.Get_User: IRecord;
begin
  CreateAssertion;
  Result := TgsRecord.Create(IBLogin.UserKey, IBLogin.UserName);
end;

function TgsGedemin.GetValue(const AName: WideString): WideString;
begin
  {if FgdcConst = nil then
  begin
    FgdcConst := TgdcConst.Create(nil);
    FgdcConst.SubSet := 'All';
  end;}

  //Result := {dmDataBase.}FgdcConst.GetValue(AName);
  Result := TgdcConst.QGetValueByName(AName);
end;

procedure TgsGedemin.ShowSQL(const S: WideString);
begin
  ShowString(GetSQL(S));
end;

procedure TgsGedemin.ShowString(const S: WideString);
begin
  with Tgdc_frmMemo.Create(nil) do
  try
    Memo.Lines.Text := S;
    ShowModal;
  finally
    Free;
  end;
end;

function TgsGedemin.GetValueByID(AnID: Integer): WideString;
begin
  {if FgdcConst = nil then
  begin
    FgdcConst := TgdcConst.Create(nil);
    FgdcConst.SubSet := 'All';
  end;}

  //Result := {dmDataBase.}FgdcConst.GetValue(AnID);
  Result := TgdcConst.QGetValueByID(AnID);
end;

{ TAutoStorage }

function  TgsGedemin.GetGlobal(const Folder: WideString; const Name: WideString): OleVariant; safecall;
begin
  Result := GlobalStorage.ReadString(Folder, Name);
end;

function  TgsGedemin.GetUser(const Folder: WideString; const Name: WideString): OleVariant; safecall;
begin
  Result := UserStorage.ReadString(Folder, Name);
end;

function  TgsGedemin.GetCompany(const Folder: WideString; const Name: WideString): OleVariant; safecall;
begin
  Result := CompanyStorage.ReadString(Folder, Name);
end;

function TgsGedemin.IsWindowExit(const WindowName: WideString): WordBool;
begin
  Result := WindowExists(WindowName);
end;

function TgsGedemin.ReportSystem: IReportSystem;
begin
  Assert(ClientReport <> nil);
  Result := TReportSystem.Create;
end;

function TgsGedemin.WindowByName(const WindowName: WideString): IgsCreateableForm;
var
  LocComp: TComponent;
begin
  LocComp := FindWindowByName(WindowName);
  if LocComp = nil then
    raise Exception.Create('Window ' + WindowName + ' not found');
  if not (LocComp is TCreateableForm) then
    raise Exception.Create('Calling form must be TCreateableForm');

  Result := GetGdcOLEObject(LocComp) as IgsCreateableForm;
end;

function TgsGedemin.WindowExists(const WindowName: WideString): WordBool;
var
  LocComp: TComponent;
begin
  Result := False;
  LocComp := FindWindowByName(WindowName);
  if Assigned(LocComp) then
    if not (LocComp is TCreateableForm) then
      raise Exception.Create('Calling form must be TCreateableForm')
    else
      Result := True;
end;

function TgsGedemin.GetNewParamWindow(WindowKey: Integer): IgsParamWindow;
begin
  Result := TgsParamWindow.Create(WindowKey);
end;

function TgsGedemin.AnsiToOem(const S: WideString): WideString;
var
  St: String;
begin
  St := S;
//  CharToOem(Pchar(St), PChar(St));
  CharToOem(@St[1], @St[1]);
  Result := St;
end;

function TgsGedemin.OemToAnsi(const S: WideString): WideString;
var
  St: String;
begin
  St := S;
  OemToChar(@St[1], @St[1]);
  Result := St;                
end;

function TgsGedemin.GetCodeByParams(const ParamList: WideString): LongWord;
begin
{$IFDEF GEDEMIN_LOCK}
  Result := TRegParams.GetCode(ParamList);
{$ELSE}
  Result := 0;
{$ENDIF}
end;

destructor TgsGedemin.Destroy;
begin
  FwrpIBDatabase := nil;
  inherited;
end;

function TgsGedemin.Get_Database: IgsIBDatabase;
begin
  if FwrpIBDatabase = nil then
    FwrpIBDatabase := TwrpIBDatabase.Create(FDatabase, ComServer.TypeLib, IID_IgsIBDatabase);
  Result := FwrpIBDatabase as IgsIBDatabase;
end;

function TgsGedemin.ExecuteMacro(const Name: WideString;
  const ObjectName: WideString; Params: OleVariant): OleVariant;
begin
  if Assigned(ScriptFactory) then
    Result := ScriptFactory.ExecuteMacro(Name, ObjectName, Params);
end;

function TgsGedemin.ExecuteScript(const FunctionName: WideString;
  const ObjectName: WideString; Params: OleVariant): OleVariant;
begin
  if Assigned(ScriptFactory) then
    Result := ScriptFactory.ExecuteObjectScript(FunctionName,
      ObjectName, Params);
end;

procedure TgsGedemin.DisableMethods;
begin
  FUnMethod := UnMethodMacro;
  UnMethodMacro := True;
end;

procedure TgsGedemin.EnableMethods;
begin
  UnMethodMacro := FUnMethod;
end;
                                   
function TgsGedemin.ViewDataSet(
  const DataSet: IgsIBCustomDataSet): WordBool;
var
  LocalQuery: TgsQueryList;
begin
  LocalQuery := TgsQueryList.Create(nil, nil, True);
  try
    LocalQuery.AddRealQuery(TgsRealDataSet.Create(TObject(DataSet.Get_Self) as TIBCustomDataSet));
    Result := ViewQueryList(LocalQuery);
  except
    LocalQuery.Free;
  end;
end;

function TgsGedemin.ViewQueryList(const QueryList: IgsQueryList): WordBool;
var
  VarResult: Variant;
  ReportResult: TReportResult;
begin
  ReportResult := TReportResult.Create;
  try
    VarResult := QueryList.ResultStream;

    ReportResult.TempStream.Size := VarArrayHighBound(VarResult, 1) - VarArrayLowBound(VarResult, 1) + 1;
    CopyMemory(ReportResult.TempStream.Memory, VarArrayLock(VarResult), ReportResult.TempStream.Size);
    VarArrayUnLock(VarResult);
    ReportResult.TempStream.Position := 0;
    ReportResult.LoadFromStream(ReportResult.TempStream);

    with TdlgViewResultEx.Create(nil) do
    try
      Result := ExecuteDialog(ReportResult, nil);
    finally
      Free;
    end;
  finally
    ReportResult.Free;
  end;
end;

procedure TgsGedemin.ShowPrepareSQL(const S: WideString; const ClassName: WideString);
begin
  ShowString(GetPrepareSQL(S, ClassName));
end;

function TgsGedemin.GetPrepareSQL(const SQL: WideString; const AClassname: WideString): WideString;
var
  SQLSetup: TatSQLSetup;
begin
  SQLSetup := TatSQLSetup.Create(nil);
  try
    Result := SQLSetup.PrepareSQL(SQL, AClassName);
  finally
    SQLSetup.Free;
  end;
end;

function TgsGedemin.GetSQL(const SQL: WideString): WideString;
var
  Parser: TsqlParser;
  S: String;
begin
  Parser := TsqlParser.Create(SQL);
  try
    Parser.Parse;
    Parser.Build(S);
    Result := S;
  finally
    Parser.Free;
  end;
end;

function TgsGedemin.ExecuteScriptFunction(FunctionID: Integer;
  Params: OleVariant): OleVariant;
begin
  if Assigned(ScriptFactory) then
    Result := ScriptFactory.ExecuteScript(FunctionId, Params);
end;

procedure TgsGedemin.ExecuteMacros(OwnerFrom: OleVariant;
  Id: Integer);
var
  M: TscrMacrosItem;
begin
  if ID > -1 then
  begin
    if Assigned(ScriptFactory) then
    begin
      M := TscrMacrosItem.Create;
      try
        M.FunctionKey := Id;
        ScriptFactory.ExecuteMacros(OwnerFrom, M);
      finally
        M.Free;
      end;
    end;
  end
  else
    raise Exception.Create('Попытка вызова макроса с ID = -1');
end;

procedure TgsGedemin.AddLogRecord(const ASrc, AText: WideString; AType,
  AnObjID: Integer; const AnObjType: WideString; AShowWindow: WordBool);
begin
  {$IFDEF WITH_INDY}
  if gdccClient <> nil then
    gdccClient.AddLogRecord(ASrc, AText, AType, AShowWindow);
  {$ENDIF}
end;

function TgsGedemin.StartPerfCounter(const ASrc,
  AName: WideString): Integer;
begin
  {$IFDEF WITH_INDY}
  if gdccClient <> nil then
    Result := gdccClient.StartPerfCounter(ASrc, AName)
  else
    Result := 0;
  {$ELSE}
  Result := 0;
  {$ENDIF}
end;

procedure TgsGedemin.StopPerfCounter(AnID: Integer);
begin
  {$IFDEF WITH_INDY}
  if gdccClient <> nil then
    gdccClient.StopPerfCounter(AnID);
  {$ENDIF}
end;

procedure TgsGedemin.UTF8ToWIN1251(const AUTF8Stream, AWIN1251Stream: IgsStream);
var
  S: AnsiString;
  ACharReplace: LongBool;
  SSUTF8: TStringStream;
begin
  Assert((AWIN1251Stream <> nil) and (AWIN1251Stream.Get_Self <> 0));
  Assert((AUTF8Stream <> nil) and (AUTF8Stream.Get_Self <> 0));

  SSUTF8 := TStringStream.Create('');
  try
    SSUTF8.CopyFrom(TStream(AUTF8Stream.Get_Self), 0);
    S := WideStringToStringEx(DecodeUTF8(SSUTF8.DataString), ACharReplace);
  finally
    SSUTF8.Free;
  end;

  TStream(AWIN1251Stream.Get_Self).Position := 0;
  TStream(AWIN1251Stream.Get_Self).Size := Length(S);
  if S > '' then
    TStream(AWIN1251Stream.Get_Self).WriteBuffer(S[1], Length(S));
end;

procedure TgsGedemin.WIN1251ToUTF8(const AWIN1251Stream, AUTF8Stream: IgsStream);
var
  S: AnsiString;
  SSUTF8: TStringStream;
begin
  Assert((AWIN1251Stream <> nil) and (AWIN1251Stream.Get_Self <> 0));
  Assert((AUTF8Stream <> nil) and (AUTF8Stream.Get_Self <> 0));

  if AWin1251Stream.Size > 0 then
  begin
    AWin1251Stream.Position := 0;
    SetLength(S, AWIN1251Stream.Size);
    TStream(AWin1251Stream.Get_Self).ReadBuffer(S[1], AWIN1251Stream.Size);
  end else
    S := '';

  SSUTF8 := TStringStream.Create(WideStringToUTF8(
    StringToWideStringEx(S, WIN1251_CODEPAGE)));
  try
    TStream(AUTF8Stream.Get_Self).CopyFrom(SSUTF8, 0);
  finally
    SSUTF8.Free;
  end;
end;

function TgsGedemin.ExpandXMLTags(const S: WideString): WideString;
var
  T: AnsiString;
begin
  T := StringReplace(S, '&amp;', '&', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace(T, '&apos;', '''', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace(T, '&quot;', '"', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace(T, '&lt;', '<', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace(T, '&gt;', '>', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace(T, '&laquo;', '«', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace(T, '&raquo;', '»', [rfReplaceAll, rfIgnoreCase]);
  Result := T;
end;

function TgsGedemin.ReplaceXMLTags(const S: WideString): WideString;
var
  T: AnsiString;
begin
  T := StringReplace(S, '&', '&amp;', [rfReplaceAll]);
  T := StringReplace(T, '''', '&apos;', [rfReplaceAll]);
  T := StringReplace(T, '"', '&quot;', [rfReplaceAll]);
  T := StringReplace(T, '<', '&lt;', [rfReplaceAll]);
  T := StringReplace(T, '>', '&gt;', [rfReplaceAll]);
  T := StringReplace(T, '«', '&laquo;', [rfReplaceAll]);
  T := StringReplace(T, '»', '&raquo;', [rfReplaceAll]);
  Result := T;
end;

function TgsGedemin.GetCurrRate(ForDate: TDateTime; ValidDays: Integer; RegulatorKey,
  FromCurrKey, ToCurrKey, CrossCurrKey: OleVariant; Amount: Currency;
  ForceCross, UseInverted, RaiseException: WordBool): Double;
begin
  Result := AcctUtils.GetCurrRate(ForDate, ValidDays, RegulatorKey, FromCurrKey,
    ToCurrKey, CrossCurrKey, Amount, ForceCross, UseInverted, RaiseException);
end;

{ TgsRecord }

constructor TgsRecord.Create(const AnID: Integer; const AnName: String);
begin
  inherited Create;

  FID := AnID;
  FName := AnName;
end;

function TgsRecord.Get_ID: Integer;
begin
  Result := FID;
end;

function TgsRecord.Get_Name: WideString;
begin
  Result := FName;
end;

{ TReportSystem }

type
  TClientReportCracker = class(TClientReport);

procedure TReportSystem.BuildReport(ReportKey: Integer);
begin
  CheckClientReport;
  ClientReport.ShowProgress:= True;
  ClientReport.FileName := '';
  ClientReport.ExportType := '';
  ClientReport.BuildReport(Unassigned, ReportKey);
end;

procedure TReportSystem.BuildReportWithOwnerForm(
  const OwnerForm: IgsGDCCreateableForm; ReportKey: Integer);
begin
  CheckClientReport;
  ClientReport.ShowProgress:= True;
  ClientReport.FileName := '';
  ClientReport.ExportType := '';
  ClientReport.BuildReport(OwnerForm, ReportKey);
end;

procedure TReportSystem.BuildReportWithParam(ReportKey: Integer;
  Params: OleVariant);
begin
  CheckClientReport;
  ClientReport.ShowProgress:= True;
  ClientReport.FileName := '';
  ClientReport.ExportType := '';
  TClientReportCracker(ClientReport).BuildReportWithParam(ReportKey, Params);
end;

procedure TReportSystem.BuildReportWithParamPrinter(ReportKey: Integer;
  Params: OleVariant; const PrinterName: WideString; ShowProgress: WordBool);
begin
  CheckClientReport;
  ClientReport.PrinterName := PrinterName;
  ClientReport.ShowProgress := ShowProgress;
  ClientReport.FileName := '';
  ClientReport.ExportType := '';
  TClientReportCracker(ClientReport).BuildReportWithParam(ReportKey, Params);
end;

procedure TReportSystem.CheckClientReport;
begin
  Assert(ClientReport <> nil, 'Global var ClientReport was not created.');
end;

procedure TReportSystem.ExportReportWithParam(ReportKey: Integer;
  Params: OleVariant; const FileName, ExportType: WideString);
begin
  if FileName = '' then
    raise Exception.Create('Empty file name');
  CheckClientReport;
  ClientReport.ShowProgress := False;
  ClientReport.FileName := FileName;
  ClientReport.ExportType := ExportType;
  TClientReportCracker(ClientReport).BuildReportWithParam(ReportKey, Params);
end;

function TReportSystem.Get_DefaultServer: IgsDlgWindow;
begin
  Result := TgsReportWindow.Create(2);
end;

function TReportSystem.Get_ReportGroup: IgsDlgWindow;
begin
  Result := TgsReportWindow.Create(0);
end;

function TReportSystem.Get_ReportList: IgsDlgWindow;
begin
  Result := TgsReportWindow.Create(1);
end;

procedure TReportSystem.RebuildReport(ReportKey: Integer);
begin
  CheckClientReport;
  ClientReport.ShowProgress := True;
  ClientReport.FileName := '';
  ClientReport.ExportType := '';
  ClientReport.BuildReport(Unassigned, ReportKey, True);
end;

procedure TReportSystem.RebuildReportWithParam(ReportKey: Integer;
  Params: OleVariant);
begin
  CheckClientReport;
  ClientReport.ShowProgress := True;
  ClientReport.FileName := '';
  ClientReport.ExportType := '';
  TClientReportCracker(ClientReport).BuildReportWithParam(ReportKey, Params);
end;

procedure TReportSystem.Refresh;
begin
  CheckClientReport;
  ClientReport.Refresh;
end;

{ TgsReportWindow }

function TgsReportWindow.Add(ParentKey: Integer): WordBool;
begin
  Result := False;
  case FAction of
    0: Result := ClientReport.DoAction(0, atAddGroup);
    1: Result := ClientReport.DoAction(0, atAddReport);
  end;
end;

constructor TgsReportWindow.Create(const ActionType: Integer);
begin
  inherited Create;

  FAction := ActionType;
end;

function TgsReportWindow.Delete(ObjectKey: Integer): WordBool;
begin
  Result := False;
  case FAction of
    0: Result := ClientReport.DoAction(0, atDelGroup);
    1: Result := ClientReport.DoAction(0, atDelReport);
  end;
end;

function TgsReportWindow.Edit(ObjectKey: Integer): WordBool;
begin
  Result := False;
  case FAction of
    0: Result := ClientReport.DoAction(0, atEditGroup);
    1: Result := ClientReport.DoAction(0, atEditReport);
  end;
end;

function TgsReportWindow.Execute: WordBool;
begin
  Result := False;
  if FAction = 2 then
    Result := ClientReport.DoAction(0, atDefServer);
end;

initialization
//  TAutoObjectFactory.Create(ComServer, TgsViewWindow, CLASS_gs_ViewWindow,
//    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsRecord, CLASS_gs_Record,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TReportSystem, CLASS_gs_ReportSystem,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsGedemin, CLASS_gs_Gedemin,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TgsReportWindow, CLASS_gsDlgWindow,
    ciMultiInstance, tmApartment);
end.
