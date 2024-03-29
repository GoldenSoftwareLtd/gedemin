// ShlTanya, 26.02.2019

{++

  Copyright (c) 2001-22 by Golden Software of Belarus, Ltd

  Module

    dmClientReport_unit.pas

  Abstract

    Gedemin project. Join Gedemin and ReportSystem.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    ~01.04.01    JKL        Initial version.
    1.01    14.03.03    JKL         Check dalex bugs.

--}

unit dmClientReport_unit;

interface

uses
  Windows,      Messages,       SysUtils,       Classes,
  Graphics,     Controls,       Forms,          Dialogs,
  rp_ReportClient, rp_ClassReportFactory,       IBDatabase,
  ActiveX,      rp_ReportScriptControl,         FR_Desgn,
  FR_DCtrl,     FR_Shape,       FR_ChBox,       FR_RRect,
  FR_Rich,      FR_Chart,       FR_BarC,        FR_OLE,
  NumConv,      FR_Class, {FR_E_HTM,}
  {FR_E_CSV,} {FR_E_RTF,} {FR_E_XLS,} {FR_E_TXT,}
  IBSQL,        rp_BaseReport_unit,             Db,
  IBCustomDataSet, flt_ScriptInterface_body,    evt_Inherited,
  gdcBase,      gdcConst,       flt_ScriptInterface, FR_Cross,
  FR_E_CSV_RS,  evt_Base,       gd_ScriptFactory,    gsMorph,
  mtd_Base,     mtd_Inherited,  rp_ReportServer,dm_i_ClientReport_unit,
  obj_i_Debugger, obj_Debugger, prp_i_VBProposal, flt_SQLProposal, flt_i_SQLProposal,
  prp_VBProposal, prp_PropertySettings,         gd_KeyAssoc,
  gdcConstants, frOLEExl,       frXMLExl,       gdcBaseInterface,
  FR_E_TXT,     FR_E_RTF,       frRtfExp
  {$IFDEF FR4}
  ,rp_FR4Functions //, syQRCode
  {$ENDIF}
  ;

type
  TSingleGlObj = record
    Name: String;
    IDisp: IDispatch;
    Description: String;
  end;

  TGlObjArray = array of TSingleGlObj;

  TgsFunctionLibrary = class;

  TdmClientReport = class(TDataModule, IdmClientReport)
    IBTransaction1: TIBTransaction;
    ReportFactory1: TReportFactory;
    frOLEObject1: TfrOLEObject;
    frBarCodeObject1: TfrBarCodeObject;
    frChartObject1: TfrChartObject;
    frRichObject1: TfrRichObject;
    frRoundRectObject1: TfrRoundRectObject;
    frCheckBoxObject1: TfrCheckBoxObject;
    frShapeObject1: TfrShapeObject;
    frDialogControls1: TfrDialogControls;
    frDesigner1: TfrDesigner;
    frTextExport: TfrTextExport;
    ClientReport1: TClientReport;
    fltGlobalScript1: TfltGlobalScript;
    frCrossObject1: TfrCrossObject;
    gsFunctionList1: TgsFunctionList;
    EventControl1: TEventControl;
    gdScriptFactory1: TgdScriptFactory;
    MethodControl1: TMethodControl;
    frOLEExcelExport: TfrOLEExcelExport;
    frXMLExcelExport: TfrXMLExcelExport;
    frRtfAdvExport: TfrRtfAdvExport;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure ClientReport1CreateObject(Sender: TObject);
    procedure ReportFactory1ReportEvent(const AnVarArray: Variant;
      const AnEventFunction: TrpCustomFunction; var AnResult: Boolean);
    function EventControl1VarParamEvent(AnVarParam: Variant): OleVariant;
    function EventControl1ReturnVarParam(AnVarParam: Variant): OleVariant;
    procedure gdScriptFactory1CreateConst(Sender: TObject);
    procedure gdScriptFactory1CreateGlobalObj(Sender: TObject);
    procedure gdScriptFactory1CreateVBClasses(Sender: TObject);
    procedure gdScriptFactory1IsCreated(Sender: TObject);
  private
    FMethodInherited: TMethodInherited;
    FEventInherited: TEventInherited;
    FGlObjectRS: TReportScript;

    FGedeminApplication: IDispatch;

    // ������ ���� �������
    FBaseQuery: IDispatch;
    FGedemin: IDispatch;
    FConst: IDispatch;
    FStorage: IDispatch;

    // ������ ������ ���������� � ����� ���������� ��������
    // ��� VBScript
    FGlObjArray: TGlObjArray{array of TSingleGlObj};
    // ������ VB-��������
    FVBConst: TgdKeyArray;
    // VB ������
    FVBClassKey: TgdKeyArray;
    FIsCreateGlObj: Boolean;
    // ������ ���������� ����������� �������� (�����., ������, ��.�������)
    FStaticSFList: TgdKeyDuplArray;

    procedure CreateGlobalSF;

    // ����������� ��.��������
    procedure  ClearGlObjArray;
    // ��������� ������ VB-��������
    procedure  CreateVBConst;
    // ������� ���������� VB-������� � ��������� ������
    procedure  CreateGlObjArray;
    procedure  CreateGlObjArrayProcess;
    // ������� ����� �������
    procedure CreateVBClasses;

    function  GetStaticSFList: TgdKeyArray;

    function  GetEventInherited(Sender: TObject): IDispatch;
    function  GetMethodInherited(Sender: TObject): IDispatch;
    procedure DoConnect;
    procedure DoDisconnect;
  protected
    property GlObjArray: TGlObjArray{array of TSingleGlObj} read FGlObjArray;
  public
    frRTF_Export: TfrExportFilter;
    frCSV_Export: TfrExportFilter;
    frExcel_Export: TfrExportFilter;

    // ������������ ��� ������� � VB �������, ���������� � ��.��������
    property  GlobalRS: TReportScript read FGlObjectRS;
  end;

  TgsFunctionLibrary = class(TfrFunctionLibrary)
  private
    NumberConvert: TNumberConvert;

    function GetSumCurr(D1, D2, D3: Variant; D4: Boolean = False): Variant;
    function GetSumStr(D1: Variant; D2: Byte = 0): Variant;
    function GetRubSumStr(D: Variant): Variant;
    function GetFullRubSumStr(D: Variant): Variant;
    function DateStr(D: Variant): Variant;

    // ������� ��� ����� � ����������
    function GetConstByName(const AName: String): Variant;
    function GetConstByID(const AnID: TID): Variant;
    function GetConstByNameForDate(const AName: String; const ADate: TDateTime): Variant;
    function GetConstByIDForDate(const AnID: TID; const ADate: TDateTime): Variant;

    function AdvString: Variant;

    function GetCaseWord(TheWord: String; TheCase, Sex, Name: Word): Variant;

  public
    constructor Create; override;
    destructor Destroy; override;

    procedure DoFunction(FNo: Integer; p1, p2, p3: Variant;
      var val: Variant); override;
  end;

var
  dmClientReport: TdmClientReport;

implementation

uses
  {$IFDEF GEDEMIN}
  dmDatabase_unit,
  obj_GedeminApplication,
  gd_convert,
  {$ELSE}
  dmTestReport_unit,
  {$ENDIF}
  IBIntf,
  rp_report_const, obj_QueryList, obj_Gedemin, {bn_PaymentCommon,}
  gd_security, evt_i_Base, gd_i_ScriptFactory, mtd_i_Base,
  scrOpenSaveDialog_unit, gd_ClassList, {obj_WrapperDelphiClasses, }gsTextTemplate_unit,
  obj_VarParam, Gedemin_TLB, GDCOleClassList, prp_methods, rp_VBConsts,
  comobj, scr_i_FunctionList, gd_security_operationconst, gdcCustomFunction,
  gd_main_form, MSScriptControl_TLB, prp_frmGedeminProperty_Unit
  {$IFDEF WITH_INDY}
    , gdccClient_unit, gdccConst
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  MonthNames: array[1..12] of String = (
    '������',
    '�������',
    '�����',
    '������',
    '���',
    '����',
    '����',
    '�������',
    '��������',
    '�������',
    '������',
    '�������'
  );

type
  TCrackGdScriptFactory = class(TgdScriptFactory);

{$R *.DFM}

{TdmClientReport}

procedure TdmClientReport.DataModuleCreate(Sender: TObject);
var
  UnEventMacroStor: Boolean;
begin
  dm_i_ClientReport := Self;

  FStaticSFList := TgdKeyDuplArray.Create;
  FStaticSFList.Duplicates := dupIgnore;

  UnEventMacroStor := UnEventMacro;
  UnEventMacro := True;
  try
    // �������������� OLE
    OleInitialize(nil);

    Debugger := TDebugger.Create;

    frCharset := RUSSIAN_CHARSET;

    //frRTF_Export := TfrRTF_rsExport.Create(Self);
    frCSV_Export := TfrCSV_rsExport.Create(Self);
    //frExcel_Export := TfrOLEExcelExport.Create(Self);//TfrExcelExport.Create(Self);

    // ����������� ����� ������� ��� ���� �������
    frRegisterFunctionLibrary(TgsFunctionLibrary);

    // ������� ������ ��� ���������
    GetEventInherited(nil);
    GetMethodInherited(nil);
  except
    on E: Exception do
      Application.ShowException(E);
  end;

  UnEventMacro := UnEventMacroStor;

  gdScriptFactory1.VBScriptControl.OnMethodInherited := GetMethodInherited;
  gdScriptFactory1.VBScriptControl.OnEventInherited := GetEventInherited;
end;

procedure TdmClientReport.DataModuleDestroy(Sender: TObject);
begin
  FStaticSFList.Free;
// ������������ � FR_Class
  frUnRegisterFunctionLibrary(TgsFunctionLibrary);

  frRTF_Export.Free;
  frCSV_Export.Free;
  frExcel_Export.Free;

  FGedemin := nil;
  FBaseQuery := nil;
  dm_i_ClientReport := nil;

  FGedeminApplication := nil;
  Debugger := nil;

  FreeAndNil(FMethodInherited);
  FreeAndNil(FEventInherited);
end;

procedure TdmClientReport.ClientReport1CreateObject(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  if not Assigned(FGedeminApplication) then
  begin
    if GedeminApplication = nil then
      GedeminApplication := TgsGedeminApplication.Create;
    FGedeminApplication := GedeminApplication;
  end;
  {$ELSE}
  if not Assigned(FBaseQuery        ) then
    FBaseQuery := TgsQueryList.Create(ClientReport1.Database, IBTransaction1);
  if not Assigned(FGedemin) then
    FGedemin := TgsGedemin.Create(ClientReport1.Database, IBTransaction1);
  {$ENDIF}

  {$IFDEF GEDEMIN}
  // ������ �������� ������ ���� ������
  (Sender as TReportScript).AddObject('GedeminApplication', (GedeminApplication as IDispatch), True);
  if Assigned(Debugger) then
    (Sender as TReportScript).AddObject('Debugger', (Debugger as IDispatch), False);
  if Assigned(FEventInherited) then
    (Sender as TReportScript).AddObject('Inherited', FEventInherited.InheritedObject, False);
  // ��� �������������
  (Sender as TReportScript).AddObject(ReportObjectName, (GedeminApplication as IGedeminApplication).BaseQueryList, False);
  // ������ ��������
  {$ELSE}
  (Sender as TReportScript).AddObject(ReportObjectName, FBaseQuery, False);
  (Sender as TReportScript).AddObject('System', FGedemin, False);
  {$ENDIF}
end;


procedure TdmClientReport.ReportFactory1ReportEvent(
  const AnVarArray: Variant; const AnEventFunction: TrpCustomFunction;
  var AnResult: Boolean);
var
  TempVar: Variant;
begin
  AnResult := False;
  // �������� ��������. ������� �� �����������.
  // �� ��� �������� ������� � �������� ����.
  if Trim(AnEventFunction.Name) = '' then
    Exit;

  try
    ScriptFactory.ExecuteFunction(AnEventFunction, AnVarArray, TempVar);
    if VarType(TempVar) in [varBoolean, varSmallint] then
      AnResult := TempVar;
  except
    AnResult := False;
    if VarType(TempVar) = varString then
    begin
      MessageBox(Application.Handle, PChar(String(TempVar)), '������', MB_OK or MB_ICONERROR);
    end;
  end;
end;

procedure TdmClientReport.CreateVBConst;
var
  ibtrConst: TIBTransaction;
  ibsqlConst: TIBSQL;
  LocRS: TScriptControl;
  ErrScript: String;
begin
// �������� � ������-������� StandartConsts
  FVBConst.Clear;
  ibtrConst := TIBTransaction.Create(nil);
  try
    ibtrConst.DefaultDatabase := gdScriptFactory1.Database;
    ibtrConst.StartTransaction;
    try
      ibsqlConst := TIBSQL.Create(nil);
      try
        ibsqlConst.Database := gdScriptFactory1.Database;
        ibsqlConst.Transaction := ibtrConst;
        ibsqlConst.SQL.Text := 'SELECT name, ' + fnID + ',' + fnscript +
          ' FROM gd_function WHERE module = ''CONST''';
        ibsqlConst.ExecQuery;

        LocRS := TScriptControl.Create(nil);
        LocRS.Language := 'VBSCRIPT';
        LocRS.TimeOut := -1;
        try
          while not ibsqlConst.Eof do
          begin
            try
              try
                FStaticSFList.Add(GetTID(ibsqlConst.FieldByName(fnid)));
                LocRS.AddCode(ibsqlConst.FieldByName(fnscript).AsString);
                FVBConst.Add(GetTID(ibsqlConst.FieldByName(fnid)));
              except
                ErrScript := LocRS.Error.Description + ': ' + LocRS.Error.Text + #13#10 +
                  '������: ' + IntToStr(LocRS.Error.Line) + #13#10;

                {$IFDEF WITH_INDY}
                if gdccClient <> nil then
                begin
                  gdccClient.AddLogRecord('script', '������ �������� ����� ���������� �������� ' +
                    ibsqlConst.FieldByName('Name').AsString + '.'#13#10 + ErrScript + #13#10 +
                    '���������, ����������� � ����� ����� �� ��������.', gdcc_lt_Warning, True);
                end;
                {$ENDIF}
              end;
            finally
              ibsqlConst.Next;
            end;
          end;
        finally
          LocRS.Free;
        end;
      finally
        ibsqlConst.Free;
      end;
    finally
      ibtrConst.Commit;
    end;
  finally
    ibtrConst.Free;
  end;
  gdScriptFactory1.Reset;
end;

procedure TdmClientReport.ClearGlObjArray;
var
  i: Integer;
  LocFucn: TrpCustomFunction;
  Params: PSafeArray;
  Name, Error: String;
begin
  if FGlObjectRS <> nil then
  begin
    LocFucn := TrpCustomFunction.Create;
    try
      LocFucn.Language := 'VBSCRIPT';
      LocFucn.FunctionKey := -1;
      for i := 0 to Length(FGlObjArray) - 1 do
        if FGlObjArray[i].IDisp <> nil then
        begin
          Name := FGlObjArray[i].Name;
          try
            Params := SafeArrayCreateVector(vtVariant, 0, 0);
            // ����� ������-������� ����������� ��. �������
            try
              {$IFDEF WITH_INDY}
              //if gdccClient <> nil then
              //  gdccClient.AddLogRecord('Global Objects', 'Calling ' + FGlObjArray[i].Name + '_Terminate');
              {$ENDIF}

              FGlObjectRS.Run(FGlObjArray[i].Name + '_Terminate', Params);
            finally
              SafeArrayDestroy(Params);
            end;
          except
            if FGlObjectRS.Error <> nil then
            begin
              Error := FGlObjectRS.Error.Get_Description + #13#10 +
                '������: ' + IntToStr(FGlObjectRS.Error.Get_Number);
            end else
            begin
              Error := 'unknown error';
            end;

            MessageBox(0, PChar(String(
              '������ ����������� ������� ' + Name + ' � ����������:'#13#10 +
              Error)),
              PChar(String('������-������� ' + Name + '_Terminate')),
              MB_Ok or MB_ICONERROR or MB_TOPMOST);
          end;
          {$IFDEF WITH_INDY}
          //if gdccClient <> nil then
          //  gdccClient.AddLogRecord('Global Objects', 'Freeing disp interface of ' + FGlObjArray[i].Name + '...');
          {$ENDIF}

          try
            FGlObjArray[i].IDisp := nil;
          except
            on E: Exception do
            begin
              {$IFDEF WITH_INDY}
              //if gdccClient <> nil then
              //  gdccClient.AddLogRecord('Global Objects', 'Error: ' + E.Message, gdcc_lt_Error);
              {$ENDIF}

              //MessageBox(0, PChar(String(
              //  '������ ��������� disp ���������� ������� ' + Name + ' � ����������:'#13#10 +
              //  E.Message)),
              //  '������',
              //  MB_OK or MB_ICONERROR or MB_TOPMOST);
            end;
          end;
        end;
    finally
      LocFucn.Free;
    end;
  end;

  if FGlObjectRS <> nil then
    FGlObjectRS.Reset;

  // ��������� �������, ��������� ��������� �� ���������� ��.�������
  SetLength(FGlObjArray, 0);
end;

function TdmClientReport.GetEventInherited(Sender: TObject): IDispatch;
begin
  Result := nil;
  if Not Assigned(FEventInherited) then
    FEventInherited := TEventInherited.Create;
  Result := FEventInherited.InheritedObject;
end;

function TdmClientReport.GetMethodInherited(Sender: TObject): IDispatch;
begin
  Result := nil;
  if not Assigned(FMethodInherited) then
    FMethodInherited := TMethodInherited.Create(nil);
  Result := FMethodInherited.InheritedObject;
end;

procedure TdmClientReport.CreateVBClasses;
var
  ibDatasetWork: TIBSQL;
  rsTest: TReportScript;
  ibtrVBClass: TIBTransaction;
begin
  ibtrVBClass := TIBTransaction.Create(nil);
  try
    ibtrVBClass.DefaultDatabase := gdScriptFactory1.Database;
    ibtrVBClass.StartTransaction;
    ibDatasetWork := TIBSQL.Create(nil);
    try
      ibDatasetWork.Transaction := ibtrVBClass;
      ibDatasetWork.SQL.Text := 'SELECT id ' +
       'FROM gd_function WHERE module = ''' + scrVBClasses +
       ''' AND modulecode = :MC';
      SetTID(ibDatasetWork.ParamByName('MC'), OBJ_APPLICATION);
      ibDatasetWork.ExecQuery;
      FVBClassKey.Clear;

      rsTest := TReportScript.Create(nil);
      rsTest.OnCreateConst := gdScriptFactory1.OnCreateConst;
      try
        rsTest.IsCreate;
        if not ibDatasetWork.EOF then
        begin
          if not Assigned(glbFunctionList) then
            Exit;

          while not (ibDatasetWork.Eof) do
          try
            try
              FStaticSFList.Add(GetTID(ibDatasetWork.FieldByName(fnid)));
              FVBClassKey.Add(GetTID(ibDatasetWork.FieldByName(fnid)));
            except
            end;
          finally
            ibDatasetWork.Next;
          end;
        end;
      finally
        rsTest.Free;
      end;
    finally
      ibDatasetWork.Free;
    end;
    ibtrVBClass.Commit;
  finally
    ibtrVBClass.Free;
  end;
end;

procedure TdmClientReport.CreateGlObjArrayProcess;
var
  ibtrConst: TIBTransaction;
  ibsqlConst: TIBDataSet;
  objNum: Integer;
  fParam: Variant;
  LocFucn: TrpCustomFunction;
  LGlObjArray: array of TSingleGlObj;
  i: Integer;

  procedure ErrorObjectInitialization(const ErrMessage: String);
  begin
    MessageBox(0, PChar(String('������ ������������� ������� � ����������:'#13#10 +
      ErrMessage + #13#10 + '������ ' + ibsqlConst.FieldByName('Name').AsString +
      ' �� ����� ��������.'#13#10 + '���������� � ��������������.')),
      PChar(String(ibsqlConst.FieldByName('Name').AsString + '_Initialize')),
      MB_Ok or MB_ICONERROR or MB_TOPMOST);
  end;

begin
  if FIsCreateGlObj or (not IBLogin.LoggedIn) or (FGlObjectRS = nil) then
    Exit;

  ClearGlObjArray;

  ibtrConst := TIBTransaction.Create(nil);
  try
    ibtrConst.DefaultDatabase := gdScriptFactory1.Database;
    ibtrConst.StartTransaction;
    try
      ibsqlConst := TIBDataSet.Create(nil);
      try
        ibsqlConst.Database := gdScriptFactory1.Database;
        ibsqlConst.Transaction := ibtrConst;
        ibsqlConst.SelectSQL.Text := 'SELECT ' + fnID + ',' + fnName +
          ' FROM gd_function WHERE module = ''GLOBALOBJECT''';
        ibsqlConst.Open;

        if ibsqlConst.Eof then
          Exit;

        while not ibsqlConst.Eof do
        begin
          FStaticSFList.Add(GetTID(ibsqlConst.FieldByName(fnId)));
          ibsqlConst.Next
        end;
        ibsqlConst.First;

        // ������� ������ ��� �������� ���������� ����������� ��. ��������
        SetLength(LGlObjArray, ibsqlConst.RecordCount);

        objNum := 0;
        while not ibsqlConst.Eof do
        begin
          LocFucn := glbFunctionList.FindFunction(GetTID(ibsqlConst.FieldByName(fnID)));
          try
            LocFucn.Name := ibsqlConst.FieldByName(fnName).AsString + '_Initialize';
            // ����������� ������ ������� ����������� ��.��������
            // ���� ��� ���������� � �������, �� ��� ����� ��������������
            FGlObjectRS.AddCode('Sub ' + ibsqlConst.FieldByName(fnName).AsString +
              '_Terminate'#13#10 + 'End Sub');

            // ���������� ������-������� �� �������� ��. �������
            if FGlObjectRS.ExecuteFunction(LocFucn, fParam) then
            begin
              // �������� �������� ��. ������ �� ������-��������
              fParam := FGlObjectRS.Eval(ibsqlConst.FieldByName(fnName).AsString);
              if VarType(fParam) = VarDispatch then
              begin
                // ��������� ��. ������ � ������
                LGlObjArray[objNum].IDisp := IDispatch(fParam);
                LGlObjArray[objNum].Name := ibsqlConst.FieldByName(fnName).AsString;
                // ����������� ������� ��.�������� �� �������
                Inc(objNum);
              end else
                ErrorObjectInitialization('������ �� ������ � ������-������� ' +
                  LocFucn.Name + #13#10);
            end else
              begin
                ErrorObjectInitialization(String(fParam));
              end;

          finally
            glbFunctionList.ReleaseFunction(LocFucn);
          end;
          ibsqlConst.Next;
        end;
        // ������������� ����� �������, �������� ���-�� ������ ��������� ��������
        SetLength(LGlObjArray, objNum);
      finally
        ibsqlConst.Free;
      end;
    finally
      ibtrConst.Commit;
    end;
  finally
    ibtrConst.Free;
  end;

  SetLength(FGlObjArray, objNum);
  for i := 0 to objNum - 1 do
    FGlObjArray[i] := LGlObjArray[i];
  SetLength(LGlObjArray, 0);
  gdScriptFactory1.Reset;
  FIsCreateGlObj := True;
end;

procedure TdmClientReport.CreateGlObjArray;
begin
  FIsCreateGlObj := False;
end;

procedure TdmClientReport.DoConnect;
var
  UnEventMacroStor: Boolean;
  UnMethodMacroStor: Boolean;
begin
  gdScriptFactory1.Reset;

  FStaticSFList.Clear;
  if Debugger <> nil then
  begin
    Debugger.ResultRuntimeList.Clear;
    Debugger.Enabled := True;
  end;
  glbFunctionList.Drop;
  EventControl1.Drop;
  MethodControl1.Drop;

  UnEventMacroStor := UnEventMacro;
  UnEventMacro := True;
  UnMethodMacroStor := UnMethodMacro;
  UnMethodMacro := True;
  try
    FIsCreateGlObj := False;
    FVBConst := TgdKeyArray.Create;
    FVBClassKey := TgdKeyArray.Create;
    try
      // �������������� OLE
      {$IFDEF GEDEMIN}
      if not IBLogin.LoggedIn then
        exit;

      ClientReport1.Database := dmDatabase.ibdbGAdmin;
      IBTransaction1.DefaultDatabase := dmDatabase.ibdbGAdmin;
      gdScriptFactory1.Database := dmDatabase.ibdbGAdmin;
      gdScriptFactory1.Transaction := IBTransaction1;
      EventControl1.Database := dmDatabase.ibdbGAdmin;
      MethodControl1.Database := dmDatabase.ibdbGAdmin;
      SetLength(FGlObjArray, 0);
      CreateVBConst;
      CreateVBClasses;
      FGlObjectRS := TReportScript.CreateWithParam(nil, True, True);
      FGlObjectRS.Language := 'VBSCRIPT';
      FGlObjectRS.OnCreateConst := gdScriptFactory1CreateConst;
      FGlObjectRS.OnCreateObject := ClientReport1CreateObject;
      FGlObjectRS.OnCreateVBClasses := gdScriptFactory1.OnCreateVBClasses;
      FGlObjectRS.OnError := TCrackGdScriptFactory(gdScriptFactory1).OnVBError;
      gdScriptFactory1.Reset;
      if VBProposal = nil then
        VBProposalObject := TVBProposal.Create(nil);

      {$ELSE}
      if dmTestReport <> nil then
      begin
        dmTestReport.IBDatabase1.Connected := True;
        ClientReport1.Database := dmTestReport.IBDatabase1;
        IBTransaction1.DefaultDatabase := dmTestReport.IBDatabase1;
        //gsFunctionList1.Database := dmTestReport.IBDatabase1;
        EventControl1.Database := dmTestReport.IBDatabase1;
        gdScriptFactory1.Database := dmTestReport.IBDatabase1;
      end;
      {$ENDIF}
    except
      on E: Exception do
        Application.ShowException(E);
    end;

    EventControl.LoadLists;
    MethodControl.LoadLists;
  finally
    UnEventMacro := UnEventMacroStor;
    UnMethodMacro := UnMethodMacroStor;
  end;
  EventControl1.SetEvents(frmGedeminMain);

  if BreakPointList <> nil then
    BreakPointList.LoadFromStorage;
end;

procedure TdmClientReport.DoDisconnect;
begin
  if Debugger <> nil then
    Debugger.Enabled := True;

  gdScriptFactory1.ResetNow;
  // ������������ � FR_Class
  if Assigned(FGlObjectRS) then
  begin
    ClearGlObjArray;
    FreeAndNil(FGlObjectRS);
  end;

  FConst := nil;
  FStorage := nil;
  if Assigned(VBProposal) then
    FreeAndNil(VBProposalObject);

  if Assigned(SQLProposal) then
    FreeAndNil(SQLProposalObject);

  FreeAndNil(FVBConst);
  FreeAndNil(FVBClassKey);

  // ������ Uninitialize OLE
  OleUninitialize;

  VBCompiler.ClearList;

  EventControl1.ResetEvents(frmGedeminMain);

  gdScriptFactory1.Reset;
end;

procedure TdmClientReport.CreateGlobalSF;
begin
  FStaticSFList.Clear;
  CreateVBConst;
  CreateVBClasses;
  CreateGlObjArray;
end;

function TdmClientReport.GetStaticSFList: TgdKeyArray;
begin
  Result := FStaticSFList;
end;

{TgsFunctionLibrary}

constructor TgsFunctionLibrary.Create;
begin
  inherited Create;

  with List do
  begin
    Add('DATESTR');

    Add('GETVALUEBYID');
    Add('GETVALUEBYIDFORDATE');
    Add('GETVALUEBYNAME');
    Add('GETVALUEBYNAMEFORDATE');

    Add('SUMCURRSTR');
    Add('SUMCURRSTR2');
    Add('SUMFULLRUBSTR');
    Add('SUMRUBSTR');
    Add('SUMSTR');

    Add('ADVSTRING');

    Add('GETCASENARWORD');
    Add('GETCASEOWNWORD');
    Add('GETCOMPLEXCASE');
  end;

  AddFunctionDesc('DATESTR', 'Golden Software',
    'DATESTR(<����>)/���������� ���� (����� �� ������� �����)');
  AddFunctionDesc('GETVALUEBYID', 'Golden Software',
    'GETVALUEBYID(<�������������>)/���������� �������� ��������� �� ��������������');
  AddFunctionDesc('GETVALUEBYIDFORDATE', 'Golden Software',
    'GETVALUEBYIDFORDATE(<�������������>, <����>)/���������� �������� ������������� ��������� �� �������������� �� ��������� ����');
  AddFunctionDesc('GETVALUEBYNAME', 'Golden Software',
    'GETVALUEBYNAME(<������������>)/���������� �������� ��������� �� ������������');
  AddFunctionDesc('GETVALUEBYNAMEFORDATE', 'Golden Software',
    'GETVALUEBYNAMEFORDATE(<������������>, <����>)/���������� �������� ������������� ��������� �� ������������ �� ��������� ����');
  AddFunctionDesc('SUMCURRSTR', 'Golden Software',
    'SUMCURRSTR(<���� ������>, <�����>, <���� ������>)/���������� ����� ������ ��������. (���� ���������, ���������� �� ���� ������)');
  AddFunctionDesc('SUMCURRSTR2', 'Golden Software',
    'SUMCURRSTR2(<���� ������>, <�����>, <0 ������>)/���������� ����� ������ ��������, � ������� �������.  (���� ���������, ���������� �� ���� ������)');
  AddFunctionDesc('SUMFULLRUBSTR', 'Golden Software',
    'SUMFULLRUBSTR(<�����>)/���������� ����� �������� �� ������ ������ � ��������� � ������ ������');
  AddFunctionDesc('SUMRUBSTR', 'Golden Software',
    'SUMRUBSTR(<�����>)/���������� ����� �������� �� ������ ������ � ������ ������');
  AddFunctionDesc('SUMSTR', 'Golden Software',
    'SUMSTR(<�����>, <���������� ������ ����� �������>)/���������� ����� ��������, ���������� ������ ����� ������� �� ������ ����.');

  AddFunctionDesc('ADVSTRING', 'Golden Software',
    'ADVSTRING()/');

  AddFunctionDesc('GETCASENARWORD', 'Golden Software',
    'GETCASENARWORD(<�����>, <���(0 - �������, 1 - ������� )>, <�����(1-6)>)/���������� ��� ������������� � ������ ������.');
  AddFunctionDesc('GETCASEOWNWORD', 'Golden Software',
    'GETCASEOWNWORD(<�����>, <���(0 - �������, 1 - ������� )>, <�����(1-6)>)/���������� ��� �����������(�������) � ������ ������.');
  AddFunctionDesc('GETCOMPLEXCASE', 'Golden Software',
    'GETCOMPLEXCASE(<������>, <�����(1-6)>)/���������� ������ ���� [[�����������] [�����������]...] ������������ [�������] � ������ ������.');
end;

destructor TgsFunctionLibrary.Destroy;
begin
  NumberConvert.Free;
  inherited;
end;

procedure TgsFunctionLibrary.DoFunction(FNo: Integer; p1, p2, p3: Variant;
  var val: Variant);
begin
  val := 0;
  case FNo of
     0: val := DateStr(frParser.Calc(p1));
     1: val := GetConstByID(GetTID(frParser.Calc(p1)));
     2: val := GetConstByIDForDate(GetTID(frParser.Calc(p1)), frParser.Calc(p2));
     3: val := GetConstByName(frParser.Calc(p1));
     4: val := GetConstByNameForDate(frParser.Calc(p1), frParser.Calc(p2));
     5: val := GetSumCurr(frParser.Calc(p1), frParser.Calc(p2), 1, frParser.Calc(p3));
     6: val := GetSumCurr(frParser.Calc(p1), frParser.Calc(p2), 0, frParser.Calc(p3));
     7: val := GetFullRubSumStr(frParser.Calc(p1));
     8: val := GetRubSumStr(frParser.Calc(p1));
     9: val := GetSumStr(frParser.Calc(p1), frParser.Calc(p2));
    10: val := AdvString;
    11: val := GetCaseWord(frParser.Calc(p1), frParser.Calc(p2), frParser.Calc(p3), nmNar);
    12: val := GetCaseWord(frParser.Calc(p1), frParser.Calc(p2), frParser.Calc(p3), nmOwn);
    13: val := ComplexCase(frParser.Calc(p1), frParser.Calc(p2));
  end;
end;

function TgsFunctionLibrary.GetSumCurr(D1, D2, D3: Variant; D4: Boolean = False): Variant;
begin
  if VarType(D3) = varBoolean then
    Result := gd_convert.GetSumCurr(GetTID(D1), D2, D3, D4)
  else
    Result := gd_convert.GetSumCurr(GetTID(D1), D2, D3 <> 0, D4);
end;

function TgsFunctionLibrary.GetSumStr(D1: Variant; D2: Byte = 0): Variant;
begin
  if VarIsNull(D1) then
    raise Exception.Create('� ������� GetSumStr �������� �������� NULL.');

  Result := gd_convert.GetSumStr(D1, D2);
end;

function TgsFunctionLibrary.GetRubSumStr(D: Variant): Variant;
begin
  try
    Result := gd_convert.GetRubSumStr(D);
  except
    Result := '';
  end;
end;

function DateToRusStr(ADate: TDateTime): String;
var
  MM, DD, YY: Word;
  DS: String;
begin
  DecodeDate(ADate, YY, MM, DD);
  DS := IntToStr(DD);
  if DD < 10 then
    DS := '0' + DS;
  Result := Format('%s %s %d', [DS, MonthNames[MM], YY]);
end;

function TgsFunctionLibrary.DateStr(D: Variant): Variant;
begin
  try
    if VarType(D) = varDate then
      Result := DateToRusStr(D)
    else
      Result := '';
  except
    Result := '';
  end;
end;


function TgsFunctionLibrary.AdvString: Variant;
begin
  Result := '������������ � ������� �������. ���.: (017) 256-17-59, 256-27-83. http://gsbelarus.com � 1994-2020 Golden Software of Belarus, Ltd. ';
end;


function GetKopWord(Value: Double): String;
var
  Num: Integer;
begin
  Num := Trunc(Abs(Value));

  if (Trunc(Num) mod 100 >= 20) or (Trunc(Num) mod 100 <= 10) then
    case Trunc(Num) mod 10 of
      1: Result := '�������';
      2, 3, 4: Result := '�������';
    else
      Result := '������';
    end
  else
    Result := '������';
end;

function TgsFunctionLibrary.GetFullRubSumStr(D: Variant): Variant;
begin
  try
    Result := gd_convert.GetFullRubSumStr(D);
  except
    Result := '';
  end;
end;

function TdmClientReport.EventControl1VarParamEvent(
  AnVarParam: Variant): OleVariant;
begin
  Result := TgsVarParam.Create(AnVarParam) as IDispatch;
end;

function TdmClientReport.EventControl1ReturnVarParam(
  AnVarParam: Variant): OleVariant;
var
  IVarPar: IgsVarParam;
begin
  if VarType(AnVarParam) = varDispatch then
  begin
    IVarPar := IDispatch(AnVarParam) as IgsVarParam;
    Result := IVarPar.Value;
    IVarPar := nil;
  end;
end;

function TgsFunctionLibrary.GetConstByID(const AnID: TID): Variant;
begin
  Result := TgdcConst.QGetValueByID(AnID);
end;

function TgsFunctionLibrary.GetConstByIDForDate(const AnID: TID;
  const ADate: TDateTime): Variant;
begin
  Result := TgdcConst.QGetValueByIDAndDate(AnID, ADate);
end;

function TgsFunctionLibrary.GetConstByName(const AName: String): Variant;
begin
  Result := TgdcConst.QGetValueByName(AName);
end;

function TgsFunctionLibrary.GetConstByNameForDate(const AName: String;
  const ADate: TDateTime): Variant;
begin
  Result := TgdcConst.QGetValueByNameAndDate(AName, ADate);
end;

procedure TdmClientReport.gdScriptFactory1CreateConst(Sender: TObject);
var
  i: Integer;
  SF: TrpCustomFunction;
begin
  Assert(Assigned(FVBConst));
  for i := 0 to FVBConst.Count - 1 do
  begin
    SF := glbFunctionList.FindFunction(FVBConst.Keys[i]);
    try
      (Sender as TReportScript).AddScript(SF,
        (Sender as TReportScript).GetModuleName(SF.ModuleCode), SF.ModuleCode);
    finally
      glbFunctionList.ReleaseFunction(SF);
    end;
  end;
end;

procedure TdmClientReport.gdScriptFactory1CreateGlobalObj(Sender: TObject);
var
  i: Integer;
begin
  CreateGlObjArrayProcess;
  for i := 0 to Length(FGlObjArray) - 1 do
  try
    if FGlObjArray[i].IDisp <> nil then
      (Sender as TReportScript).AddObject(FGlObjArray[i].Name, FGlObjArray[i].IDisp, False);
  except
  end;
end;

procedure TdmClientReport.gdScriptFactory1CreateVBClasses(Sender: TObject);
var
  i: Integer;
  SF: TrpCustomFunction;
begin
  i := 0;
  while i < FVBClassKey.Count do
  begin
    SF := glbFunctionList.FindFunction(FVBClassKey.Keys[i]);
    try
      try
        (Sender as TReportScript).AddScript(SF,
          (Sender as TReportScript).GetModuleName(SF.ModuleCode), SF.ModuleCode);
        Inc(i);
      except
        FVBClassKey.Delete(I);
      end;
    finally
      glbFunctionList.ReleaseFunction(SF);
    end;
  end;
end;

procedure TdmClientReport.gdScriptFactory1IsCreated(Sender: TObject);
begin
  gdScriptFactory1.NonLoadSFList := FStaticSFList;
end;

var
  RegKey: HKEY;

function TgsFunctionLibrary.GetCaseWord(TheWord: String; TheCase,
  Sex, Name: Word): Variant;
begin
  Result := GetCase(TheWord, TheCase, Sex, Name);
end;

initialization
  if not TryIBLoad then
  begin
    MessageBox(0,
      '���������� ����� Interbase �� �����������. ��������� ���������.',
      '��������',
      MB_OK or MB_ICONHAND or MB_TASKMODAL or MB_TOPMOST);
    exit;
  end;

  if RegOpenKey(HKEY_CLASSES_ROOT,
    PChar('CLSID\' + GUIDToString(CLASS_ScriptControl)), RegKey) <> ERROR_SUCCESS then
  begin
    MessageBox(0,
      PChar(
        '����������� ����������� ���������� MSSCRIPT.OCX.'#13#10 +
        '��������� ��������� ������������ �������� ���'#13#10 +
        '���������� Microsoft Script Control �������.'),
      '������ �������������',
      MB_OK or MB_ICONERROR or MB_TASKMODAL or MB_TOPMOST);
    exit;
  end else
    RegCloseKey(RegKey);
end.
