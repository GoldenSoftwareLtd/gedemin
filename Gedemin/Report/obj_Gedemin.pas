
{++

  Copyright (c) 2001 by Golden Software of Belarus

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

{type
  TgsViewWindow = class(TAutoObject, IgsViewWindow)
  private
    FForm: TForm;
    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;

    function GetWindowInterface: IgsViewWindow;
  protected
    function  Get_WindowQuery: IgsQueryList; safecall;
    function  Get_SelectedKey: OleVariant; safecall;
  public
    constructor Create(AnForm: TForm; AnDatabase: TIBDatabase; AnTransaction: TIBTransaction);
  end;}

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
//    function  WindowByName(const WindowName: WideString): IgsViewWindow; safecall;
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
                                                                   
  public
    constructor Create(const AnDatabase: TIBDatabase; const AnTransaction: TIBTransaction);
    destructor Destroy; override;

    {property Database: TIBDatabase read FDatabase write FDatabase;
    property Transaction: TIBTransaction read FTransaction write FTransaction;}
  end;

implementation

uses
  ComServ, gd_security, gd_createable_form, obj_QueryList, IBQuery,
  IBCustomDataSet, SysUtils, IBTable, rp_ReportClient, rp_report_const,
  obj_dlgParamWindow, gdc_frmMemo_unit, at_sql_parser, at_sql_setup,
  obj_WrapperGSClasses, gdcOLEClassList, Storages, mtd_i_Base,
  rp_dlgViewResultEx_unit, scrMacrosGroup,
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
//  Result := TgsViewWindow.Create(LocComp as TForm, FDatabase, FTransaction);
//  Result :=  GetGdcOLEObject(LocComp) as IgsCreateableForm;
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
  Result := GetCode(ParamList);
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

{ TgsViewWindow }
(*
constructor TgsViewWindow.Create(AnForm: TForm; AnDatabase: TIBDatabase;
 AnTransaction: TIBTransaction);
begin
  Assert(AnForm <> nil, 'Can''t create empty window');

  FForm := AnForm;

  inherited Create;

  FDatabase := AnDatabase;
  FTransaction := AnTransaction;
end;

function TgsViewWindow.GetWindowInterface: IgsViewWindow;
begin
  Result := FForm as TCreateableForm;
end;

function TgsViewWindow.Get_SelectedKey: OleVariant;
begin
  Result := GetWindowInterface.SelectedKey;
end;

function TgsViewWindow.Get_WindowQuery: IgsQueryList;
var
  FLocalQuery: TgsQueryList;
  I: Integer;
begin
  Result := GetWindowInterface.WindowQuery;

  if Result <> nil then
    Exit;

  FLocalQuery := TgsQueryList.Create(FDatabase, FTransaction, True);
  try
    for I := 0 to FForm.ComponentCount - 1 do
    begin
      if (FForm.Components[I] is TIBCustomDataSet) and not (FForm.Components[I] is TIBTable) then
        FLocalQuery.AddRealQuery(TgsRealDataSet.Create((FForm.Components[I] as TIBCustomDataSet)));
    end;
    Result := FLocalQuery;
  except
    FLocalQuery.Free;
  end;
end;
  *)
{ TReportSystem }

type
  TClientReportCracker = class(TClientReport);

procedure TReportSystem.BuildReport(ReportKey: Integer);
begin
  CheckClientReport;
  ClientReport.ShowProgress:= True;
  ClientReport.FileName := '';
  ClientReport.ExportType := etNone;
  ClientReport.BuildReport(Unassigned, ReportKey);
end;

procedure TReportSystem.BuildReportWithOwnerForm(
  const OwnerForm: IgsGDCCreateableForm; ReportKey: Integer);
begin
  CheckClientReport;
  ClientReport.ShowProgress:= True;
  ClientReport.FileName := '';
  ClientReport.ExportType := etNone;
  ClientReport.BuildReport(OwnerForm, ReportKey);
end;

procedure TReportSystem.BuildReportWithParam(ReportKey: Integer;
  Params: OleVariant);
begin
  CheckClientReport;
  ClientReport.ShowProgress:= True;
  ClientReport.FileName := '';
  ClientReport.ExportType := etNone;
  TClientReportCracker(ClientReport).BuildReportWithParam(ReportKey, Params);
end;

procedure TReportSystem.BuildReportWithParamPrinter(ReportKey: Integer;
  Params: OleVariant; const PrinterName: WideString; ShowProgress: WordBool);
begin
  CheckClientReport;
  ClientReport.PrinterName := PrinterName;
  ClientReport.ShowProgress := ShowProgress;
  ClientReport.FileName := '';
  ClientReport.ExportType := etNone;
  TClientReportCracker(ClientReport).BuildReportWithParam(ReportKey, Params);
end;

procedure TReportSystem.CheckClientReport;
begin
  Assert(ClientReport <> nil, 'Global var ClientReport was not created.');
end;

procedure TReportSystem.ExportReportWithParam(ReportKey: Integer;
  Params: OleVariant; const FileName, ExportType: WideString);
var
  FExportType: TExportType;
  ET: String;
begin
  if FileName = '' then
    raise Exception.Create('Empty file name');
  CheckClientReport;
  ClientReport.ShowProgress := False;
  ClientReport.FileName := FileName;

  ET := AnsiUpperCase(ExportType);
  if Pos('WORD', ET) > 0 then
    FExportType := etWord
  else if Pos('EXCEL', ET) > 0 then
    FExportType := etExcel
  else if Pos('PDF', ET) > 0 then
    FExportType := etPdf
  else if Pos('XML', ET) > 0 then
    FExportType := etXML
  else
    FExportType := etNone;

  ClientReport.ExportType := FExportType;
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
  ClientReport.ExportType := etNone;
  ClientReport.BuildReport(Unassigned, ReportKey, True);
end;

procedure TReportSystem.RebuildReportWithParam(ReportKey: Integer;
  Params: OleVariant);
begin
  CheckClientReport;
  ClientReport.ShowProgress := True;
  ClientReport.FileName := '';
  ClientReport.ExportType := etNone;  
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
