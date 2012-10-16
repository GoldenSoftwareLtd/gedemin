
unit prp_ReportFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  prp_BaseFrame_unit, StdCtrls, DBCtrls, Db, Mask, ComCtrls,
  IBCustomDataSet, gdcBase, gdcReport, ActnList, Menus, prp_TreeItems,
  prp_FunctionFrame_Unit, prp_ReportFunctionFrame_unit, rp_report_const,
  prp_TemplateFrame_unit, rp_BaseReport_unit, SuperPageControl, IBQuery,
  prpDBComboBox, ExtCtrls, StdActns, prp_dfPropertyTree_Unit, TB2Dock,
  TB2Item, TB2Toolbar, Storages, flt_ScriptInterface, gsIBLookupComboBox,
  IBDatabase, IBSQL, gdcBaseInterface, DBClient, gdcTemplate,
  SynEditExport, SynExportRTF, SynCompletionProposal, gdcTree,
  gdcDelphiObject, gdcCustomFunction, gdcFunction, clipbrd;

type
  TReportFrame = class(TBaseFrame)
    gdcReport: TgdcReport;
    tsMainFunction: TSuperTabSheet;
    tsParamFunction: TSuperTabSheet;
    tsEventFunction: TSuperTabSheet;
    tsTemplate: TSuperTabSheet;
    EventFunctionFrame: TReportFunctionFrame;
    MainFunctionFrame: TReportFunctionFrame;
    ParamFunctionFrame: TReportFunctionFrame;
    TemplateFrame: TTemplateFrame;
    dsServers: TDataSource;
    Panel1: TPanel;
    Panel2: TPanel;
    Transaction: TIBTransaction;
    pnlRUIDReport: TPanel;
    btnCopyRUIDReport: TButton;
    edtRUIDReport: TEdit;
    lblRUIDReport: TLabel;
    dbcbDisplayInMenu: TDBCheckBox;
    dbcbModalPreview: TDBCheckBox;
    iblFolder: TgsIBLookupComboBox;
    procedure MainFunctionFramegdcFunctionAfterPost(DataSet: TDataSet);
    procedure ParamFunctionFramegdcFunctionAfterPost(DataSet: TDataSet);
    procedure EventFunctionFramegdcFunctionAfterPost(DataSet: TDataSet);
    procedure PageControlChange(Sender: TObject);
    procedure TempalteFrameactEditTemplateExecute(Sender: TObject);
    procedure actProperty1Execute(Sender: TObject);
    procedure TemplateFrameactEditTemplateUpdate(Sender: TObject);
    procedure TemplateFramedbeNameNewRecord(Sender: TObject);
    procedure TemplateFramedbeNameSelChange(Sender: TObject);
    procedure TemplateFramedbeNameDropDown(Sender: TObject);
    procedure MainFunctionFramedbeNameNewRecord(Sender: TObject);
    procedure MainFunctionFramedbeNameSelChange(Sender: TObject);
    procedure ParamFunctionFramedbeNameNewRecord(Sender: TObject);
    procedure ParamFunctionFramedbeNameSelChange(Sender: TObject);
    procedure EventFunctionFramedbeNameNewRecord(Sender: TObject);
    procedure EventFunctionFramedbeNameSelChange(Sender: TObject);
    procedure dbcbServerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TemplateFrameactDeleteTemplateExecute(Sender: TObject);
    procedure ParamFunctionFrameactDeleteFunctionExecute(Sender: TObject);
    procedure EventFunctionFrameactDeleteFunctionExecute(Sender: TObject);
    procedure ParamFunctionFramedbeNameDeleteRecord(Sender: TObject);
    procedure EventFunctionFramedbeNameDeleteRecord(Sender: TObject);
    procedure TemplateFramedblcbTypeClick(Sender: TObject);
    procedure PageControlDrawTab(Control: TSuperPageControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure TemplateFrameactDeleteTemplateUpdate(Sender: TObject);
    procedure TemplateFrameactNewTemplateUpdate(Sender: TObject);
    procedure TemplateFrameactNewTemplateExecute(Sender: TObject);
    procedure MainFunctionFrameactNewFunctionExecute(Sender: TObject);
    procedure ParamFunctionFrameactDeleteFunctionUpdate(Sender: TObject);
    procedure ParamFunctionFrameactNewFunctionExecute(Sender: TObject);
    procedure EventFunctionFrameactDeleteFunctionUpdate(Sender: TObject);
    procedure EventFunctionFrameactNewFunctionExecute(Sender: TObject);
    procedure EventFunctionFrameactNewFunctionUpdate(Sender: TObject);
    procedure MainFunctionFrameactDeleteFunctionUpdate(Sender: TObject);
    procedure iblFolderChange(Sender: TObject);
    procedure gdcReportAfterEdit(DataSet: TDataSet);
    procedure btnCopyRUIDReportClick(Sender: TObject);
    procedure pMainResize(Sender: TObject);
    procedure MainFunctionFramedbeNameChange(Sender: TObject);
    procedure MainFunctionFramedbeNameDropDown(Sender: TObject);
    procedure gdcReportAfterInternalDeleteRecord(DataSet: TDataSet);
    procedure gdcReportAfterDelete(DataSet: TDataSet);
  private
    { Private declarations }
    procedure PrepareTestResult;

  protected
    FLastReportResult: TReportResult;
    procedure SetCustomTreeItem(const Value: TCustomTreeItem); override;
    function GetMasterObject: TgdcBase;override;
    function GetInfoHint: String; override;
    function GetSaveMsg: string; override;
    function GetDeleteMsg: string; override;
    procedure DoOnCreate; override;
    procedure DoOnDestroy; override;
    procedure OnFunctionChange(Sender: TObject);
    procedure DoOnNewMain;
    procedure DoOnNewParam;
    procedure DoOnNewEvent;
    procedure DoOnNewTemplate;
    function GetCanRun: Boolean; override;
    function GetCanPrepare: Boolean; override;
    function GetFunctionID: Integer; override;
    procedure ViewParam(const AnParam: Variant);
    procedure AfterPostCancel;
    procedure SetObjectId(const Value: Integer);override;
    procedure SetOnCaretPosChange(const Value: TCaretPosChange); override;
    procedure SetParent(AParent: TWinControl); override;
    function  NewNameUpdate: Boolean; override;
    procedure DoBeforeDelete; override;
    function GetRunning: Boolean; override;
    procedure SetPropertyTreeForm(const Value: TdfPropertyTree); override;
  public
    procedure DeleteFunction(ReportKey, FunctionKey: Integer);
    { Public declarations }
    constructor Create(AOwner: TComponent); override;

    procedure Setup(const FunctionName: String = ''); override;
    procedure Post; override;
    function Run(const SFType: sfTypes): Variant; override;
    procedure BuildReport(const OwnerForm: OleVariant); override;
    function CanBuildReport: Boolean; override;
    procedure Prepare; override;
    function IsExecuteScript: Boolean; override;
    procedure InvalidateFrame; override;
    procedure Evaluate; override;
    procedure Cancel; override;
    procedure EditFunction(ID: Integer); override;
    procedure GoToLine(Line, Column: Integer); override;
    procedure GotoErrorLine(Line: Integer); override;
    function GetSelectedText: string; override;
    function GetCurrentWord: string; override;
    procedure ToggleBreak; override;
    function CanToggleBreak: Boolean; override;
    procedure UpDateSyncs; override;
    //Загрузка из файла
    procedure LoadFromFile; override;
    function CanLoadFromFile: Boolean; override;
    //Сохраниение в файл
    procedure SaveToFile; override;
    function CanSaveToFile: Boolean; override;
    //Сохраниение в файл
    procedure Find; override;
    procedure Replace; override;
    procedure GoToLineNumber; override;
    function CanFindReplace: Boolean; override;
    function CanGoToLineNumber: Boolean; override;
    //Копирование в буфер
    procedure Copy; override;
    function CanCopy: Boolean; override;
    //Вырезать в буфер
    procedure Cut; override;
    function CanCut: Boolean; override;
    //Вставить из буфера
    procedure Paste; override;
    function CanPaste: Boolean; override;
    //Копировать СКЛ
    procedure CopySQl; override;
    function CanCopySQL: Boolean; override;
    //Вставить СКЛ
    procedure PasteSQL; override;
    function CanPasteSQL: Boolean; override;
    procedure Activate; override;
    procedure UpdateBreakPoints; override;
    function IsFunction(Id: Integer): Boolean; override;

    // Вставляет объект
    procedure PasteObject; override;
    // Помещает объект в буфер
    procedure CopyObject; override;
    class function GetNameById(Id: Integer): string; override;
    class function GetFunctionIdEx(Id: Integer): integer; override;
  end;

var
  ReportFrame: TReportFrame;

const
  cInfoHint = 'Отчёт %s'#13#10'Владелец %s';
  cSaveMsg = 'Отчёт %s был изменён. Сохранить изменения?';
  cDelMsg = 'Удалить отчёт %s?';
  cCategoryName = 'Входные параметры';

implementation

uses
  gdcConstants, prp_MessageConst, rp_StreamFR, Gedemin_TLB,
  xfr_TemplateBuilder, rp_dlgViewResultEx_unit, rp_ReportClient,
  rp_dlgEnterParam_unit, obj_i_Debugger, evt_i_Base,
  prp_frmGedeminProperty_Unit,
  {$IFDEF FR4}
  rp_StreamFR4,
  {$ENDIF}
  gdcOLEClassList, gd_Createable_Form, SynEdit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}
const
  cExtraSpace = 5;
  cHalfExtraSpace = 5 div 2;
  cDobleExtraSpace = 2 * cExtraSpace;
  cDivExtraSpace = cExtraSpace div 2;
  cMinTabWidth = 20;

type
  TrStreamType = (rsEvent, rsMain, rsParams, rsTemplate);

{ TReportFrame }

function TReportFrame.GetInfoHint: String;
begin
  if Assigned(CustomTreeItem) then
    Result := Format(cInfoHint, [CustomTreeItem.Name, CustomTreeItem.MainOwnerName])
  else
    Result := '';
end;

function TReportFrame.GetMasterObject: TgdcBase;
begin
  Result := gdcReport;
end;

procedure TReportFrame.Post;
var
  B: Boolean;
begin
  if not gdcReport.CanEdit then
  begin
    B := FShowCancelQu;
    try
      FShowCancelQu := False;
      Cancel;
      Exit;
    finally
      FShowCancelQu := B;
    end;
  end;

  if MainFunctionFrame.gdcFunction.State in [dsInsert, dsEdit] then
    MainFunctionFrame.Post;
  if ParamFunctionFrame.Modify then
    ParamFunctionFrame.Post
  else
  begin
    ParamFunctionFrame.Cancel;
    if ParamFunctionFrame.gdcFunction.IsEmpty then
      gdcReport.FieldByName(fnParamFormulaKey).Clear;
  end;
  if EventFunctionFrame.Modify then
    EventFunctionFrame.Post
  else
  begin
    EventFunctionFrame.Cancel;
    if EventFunctionFrame.gdcFunction.IsEmpty then
      gdcReport.FieldByName(fnEventFormulaKey).Clear;
  end;
  if TemplateFrame.Modify then
    TemplateFrame.Post
  else
  begin
    TemplateFrame.Cancel;
    if TemplateFrame.gdcTemplate.IsEmpty then
      gdcReport.FieldByName(fnTemplateKey).Clear;
  end;
  inherited;
  AfterPostCancel;
  PageControl.Repaint;
end;

procedure TReportFrame.Setup(const FunctionName: String = '');
begin
  inherited;
  DoOnNewMain;
end;

procedure TReportFrame.MainFunctionFramegdcFunctionAfterPost(
  DataSet: TDataSet);
begin
  inherited;
  MainFunctionFrame.gdcFunctionAfterPost(DataSet);
  gdcReport.FieldByName(fnMainFormulaKey).AsInteger :=
     MainFunctionFrame.gdcFunction.Id;
end;

procedure TReportFrame.ParamFunctionFramegdcFunctionAfterPost(
  DataSet: TDataSet);
begin
  inherited;
  ParamFunctionFrame.gdcFunctionAfterPost(DataSet);
  gdcReport.FieldByName(fnParamFormulaKey).AsInteger :=
     ParamFunctionFrame.gdcFunction.Id;
end;

procedure TReportFrame.EventFunctionFramegdcFunctionAfterPost(
  DataSet: TDataSet);
begin
  inherited;
  EventFunctionFrame.gdcFunctionAfterPost(DataSet);
  gdcReport.FieldByName(fnEventFormulaKey).AsInteger :=
     EventFunctionFrame.gdcFunction.Id;
end;

procedure TReportFrame.DoOnCreate;
begin
  inherited;
  PageControl.ActivePage := tsProperty;
  MainFunctionFrame.OnChange := OnFunctionChange;
  ParamFunctionFrame.OnChange := OnFunctionChange;
  EventFunctionFrame.OnChange := OnFunctionChange;
  TemplateFrame.OnChange := OnFunctionChange;
  FLastReportResult := TReportResult.Create;
  MainFunctionFrame.Modify := False;
  ParamFunctionFrame.Modify := False;
  EventFunctionFrame.Modify := False;
  TemplateFrame.Modify := False;
end;


procedure TReportFrame.OnFunctionChange(Sender: TObject);
begin
  Modify := True;
end;

procedure TReportFrame.PageControlChange(Sender: TObject);
begin
  if PageControl.ActivePage = tsParamFunction then
  begin
    if gdcReport.FieldByName(fnParamFormulaKey).IsNull then
    begin
      DoOnNewParam;
    end else
      ParamFunctionFrame.gdcFunction.Edit;
    if ParamFunctionFrame.gdcDelphiObject.State = dsInactive then
      ParamFunctionFrame.gdcDelphiObject.Open;
    if Assigned(OnCaretPosChange) then
       OnCaretPosChange(ParamFunctionFrame.gsFunctionSynEdit,
         ParamFunctionFrame.gsFunctionSynEdit.CaretX,
         ParamFunctionFrame.gsFunctionSynEdit.CaretY);
  end else
  if PageControl.ActivePage = tsEventFunction then
  begin
    if gdcReport.FieldByName(fnEventFormulaKey).IsNull then
    begin
      DoOnNewEvent;
    end else
      EventFunctionFrame.gdcFunction.Edit;
    if EventFunctionFrame.gdcDelphiObject.State = dsInactive then
      EventFunctionFrame.gdcDelphiObject.Open;
    if Assigned(OnCaretPosChange) then
       OnCaretPosChange(EventFunctionFrame.gsFunctionSynEdit,
         EventFunctionFrame.gsFunctionSynEdit.CaretX,
         EventFunctionFrame.gsFunctionSynEdit.CaretY);
  end else
  if PageControl.ActivePage = tsMainFunction then
  begin
    if not (MainFunctionFrame.gdcFunction.State in [dsInsert, dsEdit]) then
      MainFunctionFrame.gdcFunction.Edit;
    if MainFunctionFrame.gdcDelphiObject.State = dsInactive then
      MainFunctionFrame.gdcDelphiObject.Open;
    if Assigned(OnCaretPosChange) then
       OnCaretPosChange(MainFunctionFrame.gsFunctionSynEdit,
         MainFunctionFrame.gsFunctionSynEdit.CaretX,
         MainFunctionFrame.gsFunctionSynEdit.CaretY);
  end else
  if PageControl.ActivePage = tsTemplate then
  begin
    if gdcReport.FieldByName(fnTemplateKey).IsNull then
    begin
      DoOnNewTemplate;
    end else
      if Assigned(TemplateFrame) then
        TemplateFrame.gdcTemplate.Edit;
    if Assigned(OnCaretPosChange) then
       OnCaretPosChange(nil, -1, -1);
  end else
    if Assigned(OnCaretPosChange) then
       OnCaretPosChange(nil, -1, -1);
end;

procedure TReportFrame.Cancel;
begin
  if FShowCancelQu then
    if MessageBox(Application.Handle, 'Последние изменения будут потеряны.',
      MSG_WARNING, MB_OKCANCEL  or MB_ICONWARNING or MB_TASKMODAL) = ID_CANCEL then
      Exit;
  //Делаем отмену изменений и закрываем датасеты
  MainFunctionFrame.gdcFunction.Cancel;
  MainFunctionFrame.gdcFunction.Close;
  ParamFunctionFrame.gdcFunction.Cancel;
  ParamFunctionFrame.gdcFunction.Close;
  EventFunctionFrame.gdcFunction.Cancel;
  EventFunctionFrame.gdcFunction.Close;
  TemplateFrame.gdcTemplate.Cancel;
  TemplateFrame.gdcTemplate.Close;

  MasterObject.BaseState := MasterObject.BaseState - [sDialog];
  MasterObject.Cancel;
  if MasterObject.IsEmpty then
  begin
    MasterObject.Insert;
  end else
    MasterObject.Edit;
  MasterObject.BaseState := MasterObject.BaseState + [sDialog];

  //Переоткрываем датасеты
  MainFunctionFrame.gdcFunction.Open;
  ParamFunctionFrame.gdcFunction.Open;
  EventFunctionFrame.gdcFunction.Open;
  TemplateFrame.gdcTemplate.Open;
  AfterPostCancel;
  PageControl.Repaint;
  FModify := False;
  FNeedSave := False;
end;

{Заполняем справочник входных параметров}
type
  TAddParam = procedure (Sender: TObject; ParamName: string; Value: Variant);

procedure AddFRParam(Sender: TObject; ParamName: string; Value: Variant);
begin
  Tgs_frSingleReport(Sender).UpdateDictionary.Variables.Insert(0
    {Tgs_frSingleReport(Sender).UpdateDictionary.Variables.Count - 1}, ParamName);
  Tgs_frSingleReport(Sender).UpdateDictionary.Variables.Variable[ParamName] := Value;
end;

{$IFDEF FR4}
procedure AddFR4Param(Sender: TObject; ParamName: string; Value: Variant);
begin
  Tgs_fr4SingleReport(Sender).Variables.AddVariable(cCategoryName, ParamName, '''' + VarToStr(Value) + '''');
end;
{$ENDIF}

procedure TReportFrame.TempalteFrameactEditTemplateExecute(
  Sender: TObject);
var
  LfrReport: Tgs_frSingleReport;
  {$IFDEF FR4}
  Lfr4Report: Tgs_fr4SingleReport;
  {$ENDIF}
  RTFStr: TStream;
  Str: TStream;
  TF: TTemplateFrame;
  P: Variant;
  MS: TMemoryStream;
  VS: TVarStream;
const
  cTemplateWasChange = 'Шаблон был изменен. Сохранить?';
  cThereIsNotResults = 'Нет результата выполнения основной функции.';
  cErrTesrResult = 'Изменился формат данных. Запустите функцию отчета.';
  cParamName = 'PARAM';
  cSeparator = 's';

  procedure SetParam(Sender: TObject; const AnParamName: String; const Param: Variant; AddParam: TAddParam);
  var
    I: Integer;
    PP: OleVariant;
  begin
    if VarIsArray(Param) then
      for I := VarArrayLowBound(Param, 1) to VarArrayHighBound(Param, 1) do
      begin
        case VarType(Param[I]) of
          varDispatch:
            PP := 'Object';
          varEmpty:
            PP := ''
          else
          PP := Param[I];
        end;

        if Length(AnParamName) > Length(cParamName) then
          SetParam(Sender, AnParamName + cSeparator + IntToStr(I), PP, AddParam)
        else
          // Call abstract method.
          SetParam(Sender, AnParamName + IntToStr(I), PP, AddParam)
      end
    else
      AddParam(Sender, AnParamName, Param);
  end;
begin
  TF := TemplateFrame;
  if TF.dblcbType.KeyValue = ReportFR then
  begin
    LfrReport := Tgs_frSingleReport.Create(Application);
    try
      Str := MainFunctionFrame.gdcFunction.CreateBlobStream(
        MainFunctionFrame.gdcFunction.FieldByName('testresult'), DB.bmRead);
      try
        try
          LfrReport.UpdateDictionary.ReportResult.LoadFromStream(Str);
        except
          MainFunctionFrame.gdcFunction.FieldByName('testresult').Clear;
          raise Exception.Create(cErrTesrResult);
        end;
      finally
        Str.Free;
      end;

      RTFStr := TF.gdcTemplate.CreateBlobStream(
        TF.gdcTemplate.FieldByName('templatedata'), DB.bmReadWrite);
      try
        LfrReport.LoadFromStream(RTFStr);
        if MainFunctionFrame.FunctionParams <> nil then
        begin
          MS := TMemoryStream.Create;
          try
            if UserStorage.ValueExists(LocFilterFolderName + IntToStr(GD_PRM_REPORT), IntToStr(MainFunctionFrame.gdcFunction.Id)) then
            begin
              UserStorage.ReadStream(LocFilterFolderName + IntToStr(GD_PRM_REPORT), IntToStr(MainFunctionFrame.gdcFunction.Id), MS);
              MS.Position := 0;
              VS := TVarStream.Create(MS);
              try
                VS.Read(P);
              finally
                VS.Free;
              end;
            end;
         finally
           MS.Free;
         end;

          SetParam(LfrReport, cParamName, P, AddFRParam);
          LfrReport.UpdateDictionary.Variables.Insert(0, ' ' + cCategoryName);
        end;
        LfrReport.DesignReport;
        if (LfrReport.Modified or LfrReport.ComponentModified) then
        begin
          if MessageBox(0,
            cTemplateWasChange,
            MSG_WARNING,
            MB_YESNO or MB_ICONWARNING or MB_TASKMODAL) = IDYES then
          begin
            TF.Modify := True;
            RTFStr.Position := 0;
            RTFStr.Size := 0;
            LfrReport.SaveToStream(RTFStr);
            Post;
          end;
        end;
      finally
        RTFStr.Free;
      end;
    finally
      LfrReport.Free;
    end;
  end else
  if TF.dblcbType.KeyValue = ReportXFR then
  begin
    RTFStr := TF.gdcTemplate.CreateBlobStream(
      TF.gdcTemplate.FieldByName('templatedata'), DB.bmReadWrite);
    try
      Str := TMemoryStream.Create;
      try
        Str.CopyFrom(RTFStr, RTFStr.Size);
        RTFStr.Position := 0;

        with Txfr_dlgTemplateBuilder.Create(Self) do
        begin
          if Execute(RTFStr) then
          begin
            TF.Modify := True;
            if MessageBox(Application.Handle, cTemplateWasChange,
              MSG_WARNING, MB_YESNO or MB_ICONWARNING) = IDYES then
              Post
            else
              RTFStr.CopyFrom(Str, Str.Size);
          end;
        end;
      finally
        Str.Free;
      end;
    finally
      RTFStr.Free;
    end;
  end else
  if TF.dblcbType.KeyValue = ReportGRD then
  begin
    RTFStr := TF.gdcTemplate.CreateBlobStream(
      TF.gdcTemplate.FieldByName('templatedata'), DB.bmReadWrite);
    try
      Str := MainFunctionFrame.gdcFunction.CreateBlobStream(
        MainFunctionFrame.gdcFunction.FieldByName('testresult'), DB.bmRead);
      try
        try
          FLastReportResult.LoadFromStream(Str);
        except
          MainFunctionFrame.gdcFunction.FieldByName('testresult').Clear;
          raise Exception.Create(cErrTesrResult);
        end;
      finally
        Str.Free;
      end;

      if FLastReportResult.Count = 0 then
      begin
        MessageBox(Application.Handle, cThereIsNotResults,
          MSG_WARNING, MB_OK or MB_ICONWARNING);
        Exit;
      end;

      Str := TMemoryStream.Create;
      Str.CopyFrom(RTFStr, 0);
      RTFStr.Position := 0;
      try
        with TdlgViewResultEx.Create(nil) do
        try
          if ExecuteDialog(FLastReportResult, RTFStr) then
          begin
            TF.Modify := True;
            if MessageBox(Application.Handle, cTemplateWasChange,
              MSG_WARNING, MB_YESNO or MB_ICONWARNING) = IDYES then
              Post
            else
            begin
              RTFStr.Size := 0;
              RTFStr.CopyFrom(Str, 0);
            end;
          end;
        finally
          Free;
        end;
      finally
        Str.Free;
      end;
    finally
      RTFStr.Free;
    end;
  {$IFDEF FR4}
  end else
  if TF.dblcbType.KeyValue = ReportFR4 then
  begin
    Lfr4Report := Tgs_fr4SingleReport.Create(Application);
    try
      RTFStr := TF.gdcTemplate.CreateBlobStream(
        TF.gdcTemplate.FieldByName('templatedata'), DB.bmReadWrite);
      try
        //Загружаем отчет
        if RTFStr.Size > 0 then
          Lfr4Report.LoadFromStream(RTFStr);

        Lfr4Report.DataSets.Clear;
        //Загружаем наши наборы данных
        Str := MainFunctionFrame.gdcFunction.CreateBlobStream(
          MainFunctionFrame.gdcFunction.FieldByName('testresult'), DB.bmRead);
        try
          try
            Lfr4Report.ReportResult.LoadFromStream(Str);
          except
            MainFunctionFrame.gdcFunction.FieldByName('testresult').Clear;
            raise Exception.Create(cErrTesrResult);
          end;
        finally
          Str.Free;
        end;

        if MainFunctionFrame.FunctionParams <> nil then
        begin
          MS := TMemoryStream.Create;
          try
            if UserStorage.ValueExists(LocFilterFolderName + IntToStr(GD_PRM_REPORT), IntToStr(MainFunctionFrame.gdcFunction.Id)) then
            begin
              UserStorage.ReadStream(LocFilterFolderName + IntToStr(GD_PRM_REPORT), IntToStr(MainFunctionFrame.gdcFunction.Id), MS);
              MS.Position := 0;
              VS := TVarStream.Create(MS);
              try
                VS.Read(P);
              finally
                VS.Free;
              end;
            end;
          finally
            MS.Free;
          end;
          Lfr4Report.Variables.Clear;
          Lfr4Report.Variables[' ' + cCategoryName] := Null;
          SetParam(Lfr4Report, cParamName, P, AddFR4Param);
        end;
        Lfr4Report.DesignReport;
        if (Lfr4Report.Modified) then
        begin
          if MessageBox(0,
            cTemplateWasChange,
            MSG_WARNING,
            MB_YESNO or MB_ICONWARNING or MB_TASKMODAL) = IDYES then
          begin
            TF.Modify := True;
            RTFStr.Position := 0;
            RTFStr.Size := 0;
            Lfr4Report.Variables.Clear;
            Lfr4Report.SaveToStream(RTFStr);
            Post;
          end;
        end;
      finally
        RTFStr.Free;
      end;
    finally
      Lfr4Report.Free;
    end;
  {$ENDIF}
  end else
    raise Exception.Create(Format('Template type %s not supported',
      [TF.dblcbType.KeyValue]));
end;

procedure TReportFrame.DoOnNewMain;
begin
  if Assigned(CustomTreeItem) then
  begin
    gdcReport.FieldByName(fnMainFormulaKey).AsInteger := gdcReport.GetNextID(True);
    MainFunctionFrame.gdcFunction.Insert;
    MainFunctionFrame.gdcFunction.FieldByName(fnId).AsInteger := gdcReport.FieldByName(fnMainFormulaKey).AsInteger;
    gdcReport.FieldByName(fnName).AsString := CustomTreeItem.Name;
    gdcReport.FieldByName(fnReportGroupKey).AsInteger := TReportTreeItem(CustomTreeItem).ReportFolderId;
    MainFunctionFrame.gdcFunction.FieldByName(fnName).AsString :=
      {MainFunctionFrame.gdcFunction.GetUniqueName(}'rp_Main'{, '',
      CustomTreeItem.OwnerId)} + RUIDToStr(MainFunctionFrame.gdcFunction.GetRUID);
    MainFunctionFrame.gdcFunction.FieldByName(fnModule).AsString :=
      MainModuleName;
    MainFunctionFrame.gdcFunction.FieldByName(fnLanguage).AsString :=
      MainFunctionFrame.dbcbLang.Items[1];
    MainFunctionFrame.gdcFunction.FieldByName(fnModuleCode).AsInteger :=
      CustomTreeItem.OwnerId;
    MainFunctionFrame.gdcFunction.FieldByName(fnScript).AsString :=
      Format(VB_MAINFUNCTION_TEMPLATE,
      [MainFunctionFrame.gdcFunction.FieldByName(fnName).AsString,
      MainFunctionFrame.gdcFunction.FieldByName(fnName).AsString]);
    MainFunctionFrame.Modify := True;
    MainFunctionFrame.gsFunctionSynEdit.CaretX := 1;
    MainFunctionFrame.gdcDelphiObject.CloseOpen;
    PageControl.Repaint;
  end;
end;

procedure TReportFrame.DoOnNewParam;
begin
  if Assigned(CustomTreeItem) then
  begin
    gdcReport.FieldByName(fnParamFormulaKey).AsInteger := gdcReport.GetNextID;
    ParamFunctionFrame.gdcFunction.Insert;    
    ParamFunctionFrame.gdcFunction.FieldByName(fnId).AsInteger :=
      gdcReport.FieldByName(fnParamFormulaKey).AsInteger;
    ParamFunctionFrame.gdcFunction.FieldByName(fnName).AsString :=
      {ParamFunctionFrame.gdcFunction.GetUniqueName(}'rp_Param'{, '',
      CustomTreeItem.OwnerId)} + RUIDToStr(ParamFunctionFrame.gdcFunction.GetRUID);
    ParamFunctionFrame.gdcFunction.FieldByName(fnModule).AsString :=
      ParamModuleName;
    ParamFunctionFrame.gdcFunction.FieldByName(fnModuleCode).AsInteger :=
      CustomTreeItem.OwnerId;
    ParamFunctionFrame.gdcFunction.FieldByName(fnLanguage).AsString :=
      ParamFunctionFrame.dbcbLang.Items[1];
    ParamFunctionFrame.gdcFunction.FieldByName(fnScript).AsString :=
      Format(VB_PARAMFUNCTION_TEMPLATE,
      [ParamFunctionFrame.gdcFunction.FieldByName(fnName).AsString,
      ParamFunctionFrame.gdcFunction.FieldByName(fnName).AsString]);
      ParamFunctionFrame.gsFunctionSynEdit.CaretX := 1;
    ParamFunctionFrame.gdcDelphiObject.CloseOpen;
    PageControl.Repaint;
  end;
end;

procedure TReportFrame.DoOnNewEvent;
begin
  if Assigned(CustomTreeItem) then
  begin

    gdcReport.FieldByName(fnEventFormulaKey).AsInteger := gdcReport.GetNextID;
    EventFunctionFrame.gdcFunction.Insert;    
    EventFunctionFrame.gdcFunction.FieldByName(fnId).AsInteger :=
      gdcReport.FieldByName(fnEventFormulaKey).AsInteger;
    EventFunctionFrame.gdcFunction.FieldByName(fnName).AsString :=
      {EventFunctionFrame.gdcFunction.GetUniqueName(}'rp_Event'{, '',
      CustomTreeItem.OwnerId)} + RUIDToStr(EventFunctionFrame.gdcFunction.GetRUID);
    EventFunctionFrame.gdcFunction.FieldByName(fnModule).AsString :=
      EventModuleName;
    EventFunctionFrame.gdcFunction.FieldByName(fnModuleCode).AsInteger :=
      CustomTreeItem.OwnerId;
    EventFunctionFrame.gdcFunction.FieldByName(fnLanguage).AsString :=
      EventFunctionFrame.dbcbLang.Items[1];
    EventFunctionFrame.gdcFunction.FieldByName(fnScript).AsString :=
      Format(VB_EVENTFUNCTION_TEMPLATE,
      [EventFunctionFrame.gdcFunction.FieldByName(fnName).AsString,
      EventFunctionFrame.gdcFunction.FieldByName(fnName).AsString]);
    EventFunctionFrame.gsFunctionSynEdit.CaretX := 1;
    EventFunctionFrame.gdcDelphiObject.CloseOpen;
    PageControl.Repaint;  
  end;
end;

procedure TReportFrame.DoOnNewTemplate;
begin
  gdcReport.FieldByName(fnTemplateKey).AsInteger := gdcReport.GetNextID;
  TemplateFrame.gdcTemplate.Insert;  
  TemplateFrame.gdcTemplate.FieldByName(fnId).AsInteger :=
    gdcReport.FieldByName(fnTemplateKey).AsInteger;
  PageControl.Repaint;  
end;

function TReportFrame.GetCanPrepare: Boolean;
begin
  Result := (PageControl.ActivePage = tsMainFunction) or
    (PageControl.ActivePage = tsParamFunction) or
    (PageControl.ActivePage = tsEventFunction);
end;

function TReportFrame.GetCanRun: Boolean;
begin
  Result := ((PageControl.ActivePage = tsMainFunction) and Assigned(MainFunctionFrame) and MainFunctionFrame.CanRun) or
    ((PageControl.ActivePage = tsParamFunction) and Assigned(ParamFunctionFrame) and ParamFunctionFrame.CanRun) or
    ((PageControl.ActivePage = tsEventFunction) and Assigned(EventFunctionFrame) and EventFunctionFrame.CanRun);
end;

procedure TReportFrame.EditFunction(ID: Integer);
begin
  if MainFunctionFrame.ObjectId = id then
    MainFunctionFrame.gsFunctionSynEdit.Show
  else
  if ParamFunctionFrame.ObjectId = id then
    ParamFunctionFrame.gsFunctionSynEdit.Show
  else
  if EventFunctionFrame.ObjectId = id then
    EventFunctionFrame.gsFunctionSynEdit.Show
  else
    raise Exception.Create(Format('Функция с id = %d не обнаружена', [id]))
end;

function TReportFrame.GetFunctionID: Integer;
begin
  Result := 0;
  if PageControl.ActivePage = tsMainFunction then
    Result := MainFunctionFrame.gdcFunction.Id
  else
  if PageControl.ActivePage = tsParamFunction then
    Result := ParamFunctionFrame.gdcFunction.Id
  else
  if PageControl.activePage = tsEventFunction then
    Result := EventFunctionFrame.gdcFunction.Id
end;

procedure TReportFrame.Prepare;
begin
  if PageControl.ActivePage = tsMainFunction then
    MainFunctionFrame.Prepare
  else
  if PageControl.ActivePage = tsParamFunction then
    ParamFunctionFrame.Prepare
  else
  if PageControl.ActivePage = tsEventFunction then
    EventFunctionFrame.Prepare;
end;

function TReportFrame.Run(const SFType: sfTypes): Variant;
var
  LocDispatch: IDispatch;
  LocReportResult: IgsQueryList;
  VarResult: Variant;
  Str: TStream;
begin
  Result := Null;
  if (PageControl.ActivePage = tsMainFunction) then
  begin
    Result := MainFunctionFrame.Run(sfReport);
    if (VarType(Result) = varDispatch) then
    begin
      LocDispatch := Result;
      LocReportResult := LocDispatch as IgsQueryList;
      try
        VarResult := LocReportResult.ResultStream;

        FLastReportResult.TempStream.Size := VarArrayHighBound(VarResult, 1) -
          VarArrayLowBound(VarResult, 1) + 1;
        CopyMemory(FLastReportResult.TempStream.Memory, VarArrayLock(VarResult),
          FLastReportResult.TempStream.Size);
        VarArrayUnLock(VarResult);
        FLastReportResult.TempStream.Position := 0;
        if not FLastReportResult.IsStreamData then
        begin
          FLastReportResult.LoadFromStream(FLastReportResult.TempStream);
          FLastReportResult.TempStream.Clear;
          //Сохраняем результаты в базу
          Str := MainFunctionFrame.gdcFunction.CreateBlobStream(
            MainFunctionFrame.gdcFunction.FieldByName('testresult'), DB.bmWrite);
          try
            PrepareTestResult;
            FLastReportResult.SaveToStream(Str);
          finally
            Str.Free;
          end;

          MainFunctionFrame.NeedSave := True;
        end;
      finally
        LocReportResult.Clear;
      end;

      FLastReportResult.ViewResult;
    end;
  end else
  if (PageControl.ActivePage = tsParamFunction) then
  begin
    Result := ParamFunctionFrame.Run(sfUnknown);
    if (VarType(Result) = varDispatch) then
      ViewParam(Result);
  end else
  if (PageControl.ActivePage = tsEventFunction) then
    Result := EventFunctionFrame.Run(sfUnknown);
end;

procedure TReportFrame.DoOnDestroy;
begin
  FLastReportResult.Free;
  inherited;
end;

procedure TReportFrame.ViewParam(const AnParam: Variant);
begin
  if VarIsArray(AnParam) then
  begin
    with TdlgEnterParam.Create(Self) do
    try
      ViewParam(AnParam);
    finally
      Free;
    end;
  end else
    MessageBox(Application.Handle,
      'Результат функции должен быть массивом.', 'Ошибка',
      MB_OK or MB_ICONERROR or MB_TASKMODAL);
end;

procedure TReportFrame.InvalidateFrame;
begin
  if PageControl.ActivePage = tsMainFunction then
    MainFunctionFrame.InvalidateFrame
  else
  if PageControl.ActivePage = tsParamFunction then
    ParamFunctionFrame.InvalidateFrame
  else
  if PageControl.ActivePage = tsEventFunction then
    EventFunctionFrame.InvalidateFrame;
end;

procedure TReportFrame.GoToLine(Line, Column: Integer);
begin
  if PageControl.ActivePage = tsMainFunction then
    MainFunctionFrame.GoToLine(Line, Column)
  else
  if PageControl.ActivePage = tsParamFunction then
    ParamFunctionFrame.GoToLine(Line, Column)
  else
  if PageControl.ActivePage = tsEventFunction then
    EventFunctionFrame.GoToLine(Line, Column);
end;

procedure TReportFrame.Evaluate;
begin
  if PageControl.ActivePage = tsMainFunction then
    MainFunctionFrame.Evaluate
  else
  if PageControl.ActivePage = tsParamFunction then
    ParamFunctionFrame.Evaluate
  else
  if PageControl.ActivePage = tsEventFunction then
    EventFunctionFrame.Evaluate
  else
    inherited;
end;

procedure TReportFrame.actProperty1Execute(Sender: TObject);
var
  R: Boolean;
begin
  EventControl.DisableProperty;
  try
    R := gdcReport.EditDialog('Tgdc_dlgObjectProperties');
    if R then Modify := R;
  finally
    EventControl.EnableProperty;
  end;
end;

procedure TReportFrame.PrepareTestResult;
var
  I: Integer;
begin
  for I := 0 to FLastReportResult.Count - 1 do
    if FLastReportResult.DataSet[I].RecordCount > 100 then
    begin
      FLastReportResult.DataSet[I].Last;
      while FLastReportResult.DataSet[I].RecNo > 100 do
        FLastReportResult.DataSet[I].Delete;
    end;
end;

function TReportFrame.GetSelectedText: string;
begin
  if PageControl.ActivePage = tsMainFunction then
    Result := MainFunctionFrame.gsFunctionSynEdit.SelText
  else
  if PageControl.ActivePage = tsParamFunction then
    Result := ParamFunctionFrame.gsFunctionSynEdit.SelText
  else
  if PageControl.ActivePage = tsEventFunction then
    Result := EventFunctionFrame.gsFunctionSynEdit.SelText;
end;

function TReportFrame.GetSaveMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cSaveMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

procedure TReportFrame.TemplateFrameactEditTemplateUpdate(Sender: TObject);
begin
  inherited;
  TemplateFrame.actEditTemplateUpdate(Sender);
end;

procedure TReportFrame.TemplateFramedbeNameNewRecord(Sender: TObject);
begin
  TemplateFrame.gdcTemplate.Close;
  gdcReport.FieldByName(fnTemplateKey).Clear;
  TemplateFrame.gdcTemplate.Open;
  TemplateFrame.gdcTemplate.Insert;
  DoOnNewTemplate;
  TemplateFrame.Modify := False;
  Modify := True;
end;

procedure TReportFrame.TemplateFramedbeNameSelChange(Sender: TObject);
begin
  if TemplateFrame.dbeName.ItemIndex > - 1 then
  begin
    TemplateFrame.gdcTemplate.Close;
    gdcReport.FieldByName(fnTemplateKey).AsInteger :=
      Integer(TemplateFrame.dbeName.Items.Objects[TemplateFrame.dbeName.ItemIndex]);
    TemplateFrame.gdcTemplate.Open;
    TemplateFrame.gdcTemplate.Edit;
    TemplateFrame.Modify := False;
    Modify := True;
  end;
end;

procedure TReportFrame.TemplateFramedbeNameDropDown(Sender: TObject);
var
  SQL: TIBSQL;
begin
  TemplateFrame.dbeName.Items.Clear;
  SQL := TIBSQL.Create(nil);                               
  try
    SQL.Transaction := gdcReport.ReadTransaction;
    SQL.SQl.Text := 'SELECT * FROM rp_reporttemplate ORDER BY name';
    SQL.ExecQuery;
    while not SQl.Eof do
    begin
      TemplateFrame.dbeName.Items.AddObject(SQL.FieldByName(fnName).AsString,
        Pointer(SQL.FieldByName(fnId).AsInteger));
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
  inherited;
end;

procedure TReportFrame.MainFunctionFramedbeNameNewRecord(Sender: TObject);
begin
  MainFunctionFrame.gdcFunction.Close;
  gdcReport.FieldByName(fnMainFormulaKey).Clear;
  MainFunctionFrame.gdcFunction.Open;
  MainFunctionFrame.gdcFunction.Insert;
  DoOnNewMain;
  MainFunctionFrame.Modify := True;
end;

procedure TReportFrame.MainFunctionFramedbeNameSelChange(Sender: TObject);
begin
  if MainFunctionFrame.dbeName.ItemIndex > - 1 then
  begin
    MainFunctionFrame.gdcFunction.Close;
    gdcReport.FieldByName(fnMainFormulaKey).AsInteger :=
      Integer(MainFunctionFrame.dbeName.Items.Objects[
        MainFunctionFrame.dbeName.ItemIndex]);
    MainFunctionFrame.gdcFunction.Open;
    MainFunctionFrame.gdcFunction.Edit;
    MainFunctionFrame.Modify := False;
    Modify := True;
  end;
end;

procedure TReportFrame.MainFunctionFramedbeNameChange(Sender: TObject);
begin
  inherited;
  MainFunctionFrame.dbeNameChange(Sender);

end;

procedure TReportFrame.MainFunctionFramedbeNameDropDown(Sender: TObject);
begin
  inherited;
  MainFunctionFrame.dbeNameDropDown(Sender);

end;

procedure TReportFrame.ParamFunctionFramedbeNameNewRecord(Sender: TObject);
begin
  ParamFunctionFrame.gdcFunction.Close;
  gdcReport.FieldByName(fnParamFormulaKey).Clear;
  ParamFunctionFrame.gdcFunction.Open;
  ParamFunctionFrame.gdcFunction.Insert;
  DoOnNewParam;
  ParamFunctionFrame.Modify := False;
  Modify := True;
end;

procedure TReportFrame.ParamFunctionFramedbeNameSelChange(Sender: TObject);
begin
  if ParamFunctionFrame.dbeName.ItemIndex > - 1 then
  begin
    ParamFunctionFrame.gdcFunction.Close;
    gdcReport.FieldByName(fnParamFormulaKey).AsInteger :=
      Integer(ParamFunctionFrame.dbeName.Items.Objects[
        ParamFunctionFrame.dbeName.ItemIndex]);
    ParamFunctionFrame.gdcFunction.Open;
    ParamFunctionFrame.gdcFunction.Edit;
    ParamFunctionFrame.Modify := False;
    Modify := True;
  end;
end;

procedure TReportFrame.EventFunctionFramedbeNameNewRecord(Sender: TObject);
begin
  EventFunctionFrame.gdcFunction.Close;
  gdcReport.FieldByName(fnEventFormulaKey).Clear;
  EventFunctionFrame.gdcFunction.Open;
  EventFunctionFrame.gdcFunction.Insert;
  DoOnNewEvent;
  EventFunctionFrame.Modify := False;
  Modify := True;
end;

procedure TReportFrame.EventFunctionFramedbeNameSelChange(Sender: TObject);
begin
  if EventFunctionFrame.dbeName.ItemIndex > - 1 then
  begin
    EventFunctionFrame.gdcFunction.Close;
    gdcReport.FieldByName(fnEventFormulaKey).AsInteger :=
      Integer(EventFunctionFrame.dbeName.Items.Objects[
        EventFunctionFrame.dbeName.ItemIndex]);
    EventFunctionFrame.gdcFunction.Open;
    EventFunctionFrame.gdcFunction.Edit;
    EventFunctionFrame.Modify := False;
    Modify := True;
  end;
end;

procedure TReportFrame.AfterPostCancel;
begin
  //поверяем наличие данных и переводим датасеты в соотв. режим
  //производим первоначальныю инициализацию
  if MainFunctionFrame.gdcFunction.IsEmpty then
  begin
    MainFunctionFrame.gdcFunction.Insert;
    DoOnNewMain;
  end else
    MainFunctionFrame.gdcFunction.Edit;

  if ParamFunctionFrame.gdcFunction.IsEmpty then
  begin
    ParamFunctionFrame.gdcFunction.Insert;
    DoOnNewParam;
  end else
    ParamFunctionFrame.gdcFunction.Edit;

  if EventFunctionFrame.gdcFunction.IsEmpty then
  begin
    EventFunctionFrame.gdcFunction.Insert;
    DoOnNewEvent;
  end else
    EventFunctionFrame.gdcFunction.Edit;

  if TemplateFrame.gdcTemplate.IsEmpty then
  begin
    TemplateFrame.gdcTemplate.Insert;
    DoOnNewTemplate;
  end else
    TemplateFrame.gdcTemplate.Edit;
  MainFunctionFrame.Modify := False;
  ParamFunctionFrame.Modify := False;
  EventFunctionFrame.Modify := False;
  TemplateFrame.Modify := False;
  Modify := False;
end;


procedure TReportFrame.SetObjectId(const Value: Integer);
var
  F: TCustomForm;
  I: Integer;
begin
  F := GetParentForm(Self);
  if F <> nil then
  begin
    for i := 0 to F.ComponentCount -1 do
    begin
      if (F.Components[i] is TreportFrame) and
        (TReportFrame(F.Components[i]) <> Self) and
        (TReportFrame(F.Components[i]).ObjectId = Value) then
      begin
        case MessageBox(Application.Handle,
          'Данный отчёт уже открыт на редактирование'#13#10 +
          'Нажмите "Да" для открытия нового редактора,'#13#10 +
          '"Нет" перейти на открытый отчет', MSG_WARNING,
          MB_YESNOCANCEL or MB_TASKMODAL or MB_ICONWARNING) of
          ID_NO:
          begin
            TReportFrame(F.Components[i]).SpeedButton.Click;
            Abort;
          end;
          ID_CANCEL: Abort;
        end;
      end;
    end;
  end;

  inherited;
  MainFunctionFrame.Modify := False;
  ParamFunctionFrame.Modify := False;
  EventFunctionFrame.Modify := False;
  TemplateFrame.Modify := False;
  Modify := False;
  PageControl.Repaint;
end;

function TReportFrame.CanToggleBreak: Boolean;
begin
  Result := (PageControl.ActivePage = tsMainFunction) or
    (PageControl.ActivePage = tsParamFunction) or
    (PageControl.ActivePage = tsEventFunction);
end;

procedure TReportFrame.ToggleBreak;
begin
  if CanToggleBreak then
  begin
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.ToggleBreak
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.ToggleBreak
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.ToggleBreak;
  end;
end;

function TReportFrame.CanLoadFromFile: Boolean;
begin
  Result := True;
end;

procedure TReportFrame.LoadFromFile;
begin
  if CanLoadFromFile then
  begin
    if PageControl.ActivePage = tsTemplate then
      TemplateFrame.LoadFromFile
    else  
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.LoadFromFile
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.LoadFromFile
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.LoadFromFile
    else
      inherited;  
  end;
end;

function TReportFrame.CanSaveToFile: Boolean;
begin
  Result := True{((PageControl.ActivePage = tsMainFunction) and
    (MainFunctionFrame.CanSaveToFile)) or
    ((PageControl.ActivePage = tsParamFunction) and
    (ParamFunctionFrame.CanSaveToFile)) or
    ((PageControl.ActivePage = tsEventFunction) and
    (EventFunctionFrame.CanSaveToFile))};
end;

procedure TReportFrame.SaveToFile;
begin
  if CanSaveToFile then
  begin
    if PageControl.ActivePage = tsTemplate then
      TemplateFrame.SaveToFile
    else
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.SaveToFile
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.SaveToFile
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.SaveToFile
    else
      inherited;
  end;
end;

function TReportFrame.CanGoToLineNumber: Boolean;
begin
  Result := ((PageControl.ActivePage = tsMainFunction) and
    (Assigned(MainFunctionFrame) and MainFunctionFrame.CanGoToLineNumber)) or
    ((PageControl.ActivePage = tsParamFunction) and
    (Assigned(ParamFunctionFrame) and ParamFunctionFrame.CanGoToLineNumber)) or
    ((PageControl.ActivePage = tsEventFunction) and
    (Assigned(EventFunctionFrame) and EventFunctionFrame.CanGoToLineNumber));
end;

procedure TReportFrame.GoToLineNumber;
begin
  if CanGoToLineNumber then
  begin
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.GoToLineNumber
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.GoToLineNumber
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.GoToLineNumber;
  end;
end;

function TReportFrame.CanFindReplace: Boolean;
begin
  Result := ((PageControl.ActivePage = tsMainFunction) and
    (Assigned(MainFunctionFrame) and MainFunctionFrame.CanFindReplace)) or
    ((PageControl.ActivePage = tsParamFunction) and
    (Assigned(ParamFunctionFrame) and ParamFunctionFrame.CanFindReplace)) or
    ((PageControl.ActivePage = tsEventFunction) and
    (Assigned(EventFunctionFrame) and EventFunctionFrame.CanFindReplace));
end;

procedure TReportFrame.Find;
begin
  if CanFindReplace then
  begin
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.Find
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.Find
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.Find;
  end;
end;

procedure TReportFrame.Replace;
begin
  if CanFindReplace then
  begin
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.Replace
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.Replace
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.Replace;
  end;
end;

function TReportFrame.CanCopy: Boolean;
begin
  Result := ((PageControl.ActivePage = tsMainFunction) and
    (Assigned(MainFunctionFrame) and MainFunctionFrame.CanCopy)) or
    ((PageControl.ActivePage = tsParamFunction) and
    (Assigned(ParamFunctionFrame) and ParamFunctionFrame.CanCopy)) or
    ((PageControl.ActivePage = tsEventFunction) and
    (Assigned(EventFunctionFrame) and EventFunctionFrame.CanCopy));
end;

function TReportFrame.CanCopySQL: Boolean;
begin
  Result := CanCopy;
end;

function TReportFrame.CanCut: Boolean;
begin
  Result := ((PageControl.ActivePage = tsMainFunction) and
    (Assigned(MainFunctionFrame) and MainFunctionFrame.CanCut)) or
    ((PageControl.ActivePage = tsParamFunction) and
    (Assigned(ParamFunctionFrame) and ParamFunctionFrame.CanCut)) or
    ((PageControl.ActivePage = tsEventFunction) and
    (Assigned(EventFunctionFrame) and EventFunctionFrame.CanCut));
end;

function TReportFrame.CanPaste: Boolean;
begin
  Result := ((PageControl.ActivePage = tsMainFunction) and
    (Assigned(MainFunctionFrame) and MainFunctionFrame.CanPaste)) or
    ((PageControl.ActivePage = tsParamFunction) and
    (Assigned(ParamFunctionFrame) and ParamFunctionFrame.CanPaste)) or
    ((PageControl.ActivePage = tsEventFunction) and
    (Assigned(EventFunctionFrame) and EventFunctionFrame.CanPaste));
end;

function TReportFrame.CanPasteSQL: Boolean;
begin
  Result := CanPaste;
end;

procedure TReportFrame.Copy;
begin
  if CanCopy then
  begin
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.Copy
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.Copy
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.Copy;
  end;
end;

procedure TReportFrame.CopySQl;
begin
  if CanCopySQL then
  begin
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.CopySQL
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.CopySQL
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.CopySQL;
  end;
end;

procedure TReportFrame.Cut;
begin
  if CanCut then
  begin
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.Cut
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.Cut
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.Cut;
  end;
end;

procedure TReportFrame.Paste;
begin
  if CanPaste then
  begin
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.Paste
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.Paste
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.Paste;
  end;
end;

procedure TReportFrame.PasteSQL;
begin
  if CanPasteSQL then
  begin
    if PageControl.ActivePage = tsMainFunction then
      MainFunctionFrame.PasteSQL
    else
    if PageControl.ActivePage = tsParamFunction then
      ParamFunctionFrame.PasteSQL
    else
    if PageControl.ActivePage = tsEventFunction then
      EventFunctionFrame.PasteSQL;
  end;
end;

function TReportFrame.GetDeleteMsg: string;
begin
  if CustomTreeItem <> nil then
    Result := Format(cDelMsg, [CustomTreeItem.Name])
  else
    Result := inherited GetSaveMsg;
end;

procedure TReportFrame.SetOnCaretPosChange(const Value: TCaretPosChange);
begin
  MainFunctionFrame.OnCaretPosChange := Value;
  ParamFunctionFrame.OnCaretPosChange := Value;
  EventFunctionFrame.OnCaretPosChange := Value;
end;

procedure TReportFrame.BuildReport(const OwnerForm: OleVariant);
var
  Frm: TObject;
  I: Integer;
begin
  try
    Post;
    if Assigned(ClientReport) then
    begin
      Frm := Application.FindComponent(PropertyTreeForm.cbObjectList.Text);
      if Frm = nil then
      for I := 0 to Screen.FormCount - 1 do
        if (Screen.Forms[I].InheritsFrom(TCreateableForm)) and
          (CompareText(TCreateableForm(Screen.Forms[I]).InitialName,
           PropertyTreeForm.cbObjectList.Text) = 0) then
        begin
          Frm := Screen.Forms[I];
          Break;
        end;

      if (Frm = nil) and ClientReport.CheckWithOwnerForm(gdcReport.Id) and
        (MessageBox(0, PChar('Не найдена OwnerForm "' +
         PropertyTreeForm.cbObjectList.Text + '"'#13#10 + 'Возможно форма закрыта.'#13#10#13#10 +
         'Все равно запустить отчет?'), PChar('Ошибка подготовки отчета.'),
         MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL or MB_YESNO) <> id_Yes)
      then
        Exit;

      if Frm = nil then
        ClientReport.BuildReport(Unassigned, gdcReport.Id)
      else
        ClientReport.BuildReport(GetGdcOLEObject(Frm) as IDispatch, gdcReport.Id)
    end;
  finally
    if Assigned(Debugger) then
    //Данная остановка дебагера необходима на случай отмены при
    //запросе параметров
      Debugger.Stop;
  end;
end;

function TReportFrame.CanBuildReport: Boolean;
begin
  Result := True;
end;

procedure TReportFrame.GotoErrorLine(Line: Integer);
begin
  if PageControl.ActivePage = tsMainFunction then
    MainFunctionFrame.GoToErrorLine(Line)
  else
  if PageControl.ActivePage = tsParamFunction then
    ParamFunctionFrame.GoToErrorLine(Line)
  else
  if PageControl.ActivePage = tsEventFunction then
    EventFunctionFrame.GoToErrorLine(Line);
end;

procedure TReportFrame.SetParent(AParent: TWinControl);
var
  F: TCustomForm;
begin
  inherited;
  F := GetParentForm(Self);
  if F <> nil then
  begin
    MainFunctionFrame.gsFunctionSynEdit.Highlighter :=
      TfrmGedeminProperty(F).SynVBScriptSyn;
    MainFunctionFrame.UpdateSelectedColor;

    ParamFunctionFrame.gsFunctionSynEdit.Highlighter :=
      TfrmGedeminProperty(F).SynVBScriptSyn;
    ParamFunctionFrame.UpdateSelectedColor;

    EventFunctionFrame.gsFunctionSynEdit.Highlighter :=
      TfrmGedeminProperty(F).SynVBScriptSyn;
    EventFunctionFrame.UpdateSelectedColor;
  end;
end;

procedure TReportFrame.UpDateSyncs;
begin
  inherited;
  MainFunctionFrame.UpDateSyncs;

  ParamFunctionFrame.UpDateSyncs;

  EventFunctionFrame.UpDateSyncs;
end;

function TReportFrame.NewNameUpdate: Boolean;
begin
  Result := False;
end;

procedure TReportFrame.dbcbServerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if (Key = VK_DELETE) and (ssCtrl in Shift) then
  begin
    gdcReport.FieldByName('serverkey').Clear;
    Key := 0;
    Modify := True;
  end;
end;

procedure TReportFrame.TemplateFrameactDeleteTemplateExecute(
  Sender: TObject);
var
  SQL: TIBSQL;
  Transaction: TIBTransaction;
  Id: Integer;
begin
  inherited;
  Transaction := TIBTransaction.Create(nil);
  try
    Transaction.DefaultDataBase := gdcReport.Transaction.DefaultDataBase;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := Transaction;
      Transaction.StartTransaction;
      SQL.SQL.Text := 'SELECT * FROM rp_reportlist WHERE id <> :id AND ' +
        'templatekey = :templatekey';
      SQL.Params[0].AsInteger := gdcReport.FieldByName(fnId).AsInteger;
      SQL.Params[1].AsInteger := gdcReport.FieldByName(fnTemplateKey).AsInteger;
      SQL.ExecQuery;
      if SQl.Eof then
      begin
        if MessageBox(Application.Handle, 'Удалить шаблон?', MSG_QUESTION,
          MB_YESNO or MB_TASKMODAL or MB_ICONQUESTION) = IDYES then
        begin
          ID := gdcReport.FieldByName(fnTemplateKey).AsInteger;
          gdcReport.FieldByName(fnTemplateKey).Clear;
          Post;
          SQl.Close;
          SQL.SQL.text := 'DELETE FROM rp_reporttemplate WHERE id = ' +
            IntToStr(Id);
          SQL.ExecQuery;
          Transaction.Commit;
        end;
      end else
        MessageBox(Application.Handle, 'Нельзя удалить шаблон т.к. он используется другими отчетами',
          MSG_WARNING, MB_OK or MB_TASKMODAL or MB_ICONWARNING);
    finally
      SQL.Free;
    end;
  finally
    Transaction.Free;
  end;
end;

function TReportFrame.GetCurrentWord: string;
begin
  if PageControl.ActivePage = tsMainFunction then
    Result := MainFunctionFrame.gsFunctionSynEdit.WordAtCursor
  else
  if PageControl.ActivePage = tsParamFunction then
    Result := ParamFunctionFrame.gsFunctionSynEdit.WordAtCursor
  else
  if PageControl.ActivePage = tsEventFunction then
    Result := EventFunctionFrame.gsFunctionSynEdit.WordAtCursor;
end;

procedure TReportFrame.Activate;
begin
  inherited;
  if PageControl.ActivePage = tsMainFunction then
    MainFunctionFrame.Activate
  else
  if PageControl.ActivePage = tsParamFunction then
    ParamFunctionFrame.Activate
  else
  if PageControl.ActivePage = tsEventFunction then
    EventFunctionFrame.Activate;
end;

constructor TReportFrame.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;

  MainFunctionFrame.CustomTreeItem := CustomTreeItem;

  for I := 0 to MainFunctionFrame.ComponentCount - 1 do
  if MainFunctionFrame.Components[I] is TgdcBase then
  begin
    TgdcBase(MainFunctionFrame.Components[I]).UseScriptMethod := False;
    TgdcBase(MainFunctionFrame.Components[I]).QueryFiltered := False;
  end;
  for I := 0 to ParamFunctionFrame.ComponentCount - 1 do
  if MainFunctionFrame.Components[I] is TgdcBase then
  begin
    TgdcBase(ParamFunctionFrame.Components[I]).UseScriptMethod := False;
    TgdcBase(ParamFunctionFrame.Components[I]).QueryFiltered := False;
  end;
  for I := 0 to EventFunctionFrame.ComponentCount - 1 do
  if MainFunctionFrame.Components[I] is TgdcBase then
  begin
    TgdcBase(EventFunctionFrame.Components[I]).UseScriptMethod := False;
    TgdcBase(EventFunctionFrame.Components[I]).QueryFiltered := False;
  end;
end;

procedure TReportFrame.SetCustomTreeItem(const Value: TCustomTreeItem);
begin
  inherited SetCustomTreeItem(Value);
  if Assigned(MainFunctionFrame) then
    MainFunctionFrame.CustomTreeItem := CustomTreeItem;

end;

function TReportFrame.IsExecuteScript: Boolean;
begin
  Result := MainFunctionFrame.IsExecuteScript or
    ParamFunctionFrame.IsExecuteScript or EventFunctionFrame.IsExecuteScript;
end;

procedure TReportFrame.UpdateBreakPoints;
begin
  MainFunctionFrame.UpdateBreakpoints;
  ParamFunctionFrame.UpdateBreakpoints;
  EventFunctionFrame.UpdateBreakpoints;
end;

procedure TReportFrame.DeleteFunction(ReportKey, FunctionKey: Integer);
var
  F: TgdcFunction;
  Field: string;

  function CheckFunctionInUse: boolean;
  var
    ibsql: TIBSQL;
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction:= gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text:=
        'SELECT * FROM rp_reportlist ' +
        'WHERE id <> :rk AND ' + Field + ' = :fk ';
      ibsql.ParamByName('fk').AsInteger:= FunctionKey;
      ibsql.ParamByName('rk').AsInteger:= ReportKey;
      ibsql.ExecQuery;
      Result:= not ibsql.EOF;
    finally
      ibsql.Free;
    end;
  end;

begin
  F := TgdcFunction.Create(nil);
  try
    F.SubSet := 'ByID';
    F.Id := FunctionKey;
    try
      if MessageBox(Application.Handle,
        'Удалить функцию?',
        MSG_QUESTION,
        MB_YESNO or MB_TASKMODAL or MB_ICONQUESTION) = IDYES then
      begin
        if gdcReport.FieldByName(fnParamFormulaKey).AsInteger = FunctionKey then
        begin
          Field := fnParamFormulaKey;
          gdcReport.FieldByName(fnParamFormulaKey).Clear
        end else
        if gdcReport.FieldByName(fnEventFormulaKey).AsInteger = FunctionKey then
        begin
          Field := fnEventFormulaKey;
          gdcReport.FieldByName(fnEventFormulaKey).Clear;
        end;
        Post;
        if not CheckFunctionInUse then begin
          F.Open;
          F.Delete;
        end;
      end;
    except
      on E: Exception do
      begin
        if gdcReport.State <> dsEdit then
          gdcReport.Edit;
        gdcReport.FieldByName(Field).AsInteger := FunctionKey;
        Post;
      end;
    end;
  finally
    F.Free;
  end;
end;

procedure TReportFrame.ParamFunctionFrameactDeleteFunctionExecute(
  Sender: TObject);
begin
  DeleteFunction(gdcReport.FieldByName('id').AsInteger,
    gdcReport.FieldByName('paramformulakey').AsInteger);
end;

procedure TReportFrame.EventFunctionFrameactDeleteFunctionExecute(
  Sender: TObject);
begin
  DeleteFunction(gdcReport.FieldByName('id').AsInteger,
    gdcReport.FieldByName('eventformulakey').AsInteger);
end;

procedure TReportFrame.ParamFunctionFramedbeNameDeleteRecord(
  Sender: TObject);
begin
  ParamFunctionFrame.actDeleteFunction.Execute;
end;

procedure TReportFrame.EventFunctionFramedbeNameDeleteRecord(
  Sender: TObject);
begin
  EventFunctionFrame.actDeleteFunction.Execute;
end;

procedure TReportFrame.DoBeforeDelete;
var
  F: TCustomForm;
  I, J: Integer;
  T: TprpTreeView;
begin
  F := GetParentForm(Self);
  if F <> nil then
  begin
    for i := F.ComponentCount -1 downto 0 do
    begin
      if (F.Components[I] is TReportFrame) and
        (TReportFrame(F.Components[I]) <> Self) and
        (TReportFrame(F.Components[I]).ObjectId = ObjectId) then
      begin
        TReportFrame(F.Components[I]).FShowCancelQu := False;
        TReportFrame(F.Components[I]).Cancel;
        if TReportFrame(F.Components[I]).Node <> nil then
          TReportFrame(F.Components[I]).Node.Delete;
        TReportFrame(F.Components[I]).Free;
      end;
    end;

    if PropertyTreeForm <> nil then
    begin
      for i := 0 to PropertyTreeForm.PageControl.PageCount - 1 do
      begin
        T := TTreeTabSheet(PropertyTreeForm.PageControl.Pages[I]).Tree;
        for J := T.Items.Count - 1 downto 0 do
        begin
          if (TCustomTreeItem(T.Items[J].Data).Id = gdcReport.FieldByName('id').AsInteger) and
            (T.Items[J] <> Node) then
            T.Items[J].Delete;
        end;
      end;
    end;
  end;
end;

function TReportFrame.IsFunction(Id: Integer): Boolean;
begin
  Result := (Assigned(MainFunctionFrame) and (MainFunctionFrame.gdcFunction.FieldByName('id').AsInteger = id)) or
    (Assigned(ParamFunctionFrame) and (ParamFunctionFrame.gdcFunction.FieldByName('id').AsInteger = id)) or
    (Assigned(EventFunctionFrame) and (EventFunctionFrame.gdcFunction.FieldByName('id').AsInteger = id));
end;

function TReportFrame.GetRunning: Boolean;
begin
  Result := (Assigned(MainFunctionFrame) and MainFunctionFrame.Running) or
    (Assigned(ParamFunctionFrame) and ParamFunctionFrame.Running) or
    (Assigned(EventFunctionFrame) and EventFunctionFrame.Running);
end;

procedure TReportFrame.SetPropertyTreeForm(const Value: TdfPropertyTree);
begin
  inherited;
  MainFunctionFrame.PropertyTreeForm := Value;
  ParamFunctionFrame.PropertyTreeForm := Value;
  EventFunctionFrame.PropertyTreeForm := Value;
  TemplateFrame.PropertyTreeForm := Value;
end;

procedure TReportFrame.TemplateFramedblcbTypeClick(Sender: TObject);
begin
  inherited;
  TemplateFrame.dblcbTypeClick(Sender);
  dbeFunctionNameChange(Sender);
end;

procedure TReportFrame.PageControlDrawTab(Control: TSuperPageControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  FieldName: String;
  Frame: TBaseFrame;
begin
  inherited;

  if Control.Focused and (Active) then
    Control.Canvas.Font.Style := [fsBold]
  else
    Control.Canvas.Font.Style := [];

  FieldName := '';
  Frame := nil;
  case TabIndex of
    1: begin
         FieldName := 'MainFormulaKey';
         Frame := MainFunctionFrame;
       end;
    2: begin
         FieldName := 'ParamFormulaKey';
         Frame := ParamFunctionFrame;
       end;
    3: begin
         FieldName := 'EventFormulaKey';
         Frame := EventFunctionFrame;
       end;
    4: begin
         FieldName := 'TemplateKey';
         Frame := TemplateFrame;
       end;
  end;
  if (FieldName > '') and (gdcReport <> nil) and (gdcReport.State in [dsInsert, dsEdit]) then
    if gdcReport.FieldByName(FieldName).IsNull then
    begin
      Control.Canvas.Font.Color := clInactiveCaption;
    end;

  if Frame <> nil then
    if (not Frame.Modify) and (Frame.MasterObject.State = dsInsert) then
    begin
      Control.Canvas.Font.Color := clInactiveCaption;
    end;

  Control.Canvas.TextOut(Rect.Left + cExtraSpace, cExtraSpace + cDivExtraSpace,
    TSuperTabSheet(Control.Pages[TabIndex]).Caption);
  Control.Canvas.Font.Color := clWindowText;
end;

procedure TReportFrame.TemplateFrameactDeleteTemplateUpdate(
  Sender: TObject);
begin
  inherited;
  TemplateFrame.actDeleteTemplateUpdate(Sender);

end;

procedure TReportFrame.TemplateFrameactNewTemplateUpdate(Sender: TObject);
begin
  inherited;
  TemplateFrame.actNewTemplateUpdate(Sender);

end;

procedure TReportFrame.TemplateFrameactNewTemplateExecute(Sender: TObject);
var
  R: Integer;
begin
  if Modify then
  begin
     R := MessageBox(Application.Handle, 'Данные были изменены.'#13#10'Сохранить изменения?',
       MSG_WARNING, MB_YESNOCANCEL or MB_TASKMODAL or MB_ICONWARNING);
     case R of
       IDYES:
         try
           Post;
         except
           on E: Exception do
           begin
             if MessageBox(Application.Handle,
               PChar('При сохранении возникла ошибка: '#13#10 +
               E.Message + #13#10 + 'Продолжить создание нового шаблона с'#13#10+
               'потерей изменений?'),
               MSG_WARNING, MB_YESNO or MB_TASKMODAL or MB_ICONWARNING) = IDYES then
             begin
               Cancel;
             end else
               Exit;
           end;
         end;
       IDNO: Cancel;
       IDCANCEL: Exit;
     end;
  end;

  if MessageBox(0,
    'Создать новый шаблон?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
  begin
    TemplateFramedbeNameNewRecord(nil);
  end;
end;

procedure TReportFrame.MainFunctionFrameactNewFunctionExecute(
  Sender: TObject);
begin
  MainFunctionFramedbeNameNewRecord(nil);
end;

procedure TReportFrame.ParamFunctionFrameactDeleteFunctionUpdate(
  Sender: TObject);
begin
  inherited;
  ParamFunctionFrame.actDeleteFunctionUpdate(Sender);

end;

procedure TReportFrame.ParamFunctionFrameactNewFunctionExecute(
  Sender: TObject);
begin
  ParamFunctionFramedbeNameNewRecord(nil);
end;

procedure TReportFrame.EventFunctionFrameactDeleteFunctionUpdate(
  Sender: TObject);
begin
  inherited;
  EventFunctionFrame.actDeleteFunctionUpdate(Sender);

end;

procedure TReportFrame.EventFunctionFrameactNewFunctionExecute(
  Sender: TObject);
begin
  EventFunctionFramedbeNameNewRecord(nil);
end;

procedure TReportFrame.EventFunctionFrameactNewFunctionUpdate(
  Sender: TObject);
begin
  inherited;
  EventFunctionFrame.actNewFunctionUpdate(Sender);

end;

procedure TReportFrame.MainFunctionFrameactDeleteFunctionUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled := False;
end;

procedure TReportFrame.CopyObject;
var
  TmpStream: TMemoryStream;
  LStream: TStream;
  Str: String;
  I: Integer;
  ItemType: TTreeItemType;
  gdcTemplate: TgdcBase;
  StreamType: TrStreamType;
  Present: Boolean;

  procedure SaveRepFunction(const RepFuncType: TrStreamType;
    const RepFunction: TgdcFunction);
  var
    ParamStr: TStream;
  begin
    StreamType := RepFuncType;
    TmpStream.Write(StreamType, SizeOf(StreamType));
    if RepFunction.Eof then
      Present := False
    else
      Present := True;
    TmpStream.Write(Present, SizeOf(Present));

    if Present then
    begin
      Str := RepFunction.FieldByName(fnName).AsString;
      I := Length(Str);
      TmpStream.Write(I, SizeOf(I));
      TmpStream.Write(Str[1], I);
      Str := RepFunction.FieldByName(fnScript).AsString;
      I := Length(Str);
      TmpStream.Write(I, SizeOf(I));
      TmpStream.Write(Str[1], I);
      Str := RepFunction.FieldByName(fnComment).AsString;
      I := Length(Str);
      TmpStream.Write(I, SizeOf(I));
      TmpStream.Write(Str[1], I);

      ParamStr :=
        RepFunction.CreateBlobStream(RepFunction.FieldByName(fnEnteredParams), DB.bmRead);
      try
        I := ParamStr.Size;
        TmpStream.Write(I, SizeOf(I));
        TmpStream.CopyFrom(ParamStr, I);
      finally
        ParamStr.Free;
      end;
    end;
  end;
begin
  TmpStream := TMemoryStream.Create;
  try
    try
      ItemType := tiReport;
      TmpStream.Write(ItemType, SizeOf(ItemType));

      Str := gdcReport.FieldByName(fnName).AsString;
      I := Length(Str);
      TmpStream.Write(I, SizeOf(I));
      TmpStream.Write(Str[1], I);
      Str := gdcReport.FieldByName(fnDescription).AsString;
      I := Length(Str);
      TmpStream.Write(I, SizeOf(I));
      TmpStream.Write(Str[1], I);
      I := gdcReport.FieldByName(fnFRQREFRESH).AsInteger;
      TmpStream.Write(I, SizeOf(I));
      I := gdcReport.FieldByName(fnServerKey).AsInteger;
      TmpStream.Write(I, SizeOf(I));

      SaveRepFunction(rsEvent, EventFunctionFrame.gdcFunction);
      SaveRepFunction(rsMain, MainFunctionFrame.gdcFunction);
      SaveRepFunction(rsParams, ParamFunctionFrame.gdcFunction);


      gdcTemplate := TemplateFrame.gdcTemplate;
      StreamType := rsTemplate;
      TmpStream.Write(StreamType, SizeOf(StreamType));

      if gdcTemplate.Eof then
        Present := False
      else
        Present := True;
      TmpStream.Write(Present, SizeOf(Present));

      if Present then
      begin
        LStream := gdcTemplate.CreateBlobStream(
          gdcTemplate.FieldByName(fnTemplatedata), DB.bmRead);
        LStream.Position := 0;
        I := LStream.Size;
        TmpStream.Write(I, SizeOf(I));
//        TmpStream.LoadFromStream(LStream);
        TmpStream.CopyFrom(LStream, LStream.Size);
        Str := gdcTemplate.FieldByName(fnDescription).AsString;
        I := Length(Str);
        TmpStream.Write(I, SizeOf(I));
        TmpStream.Write(Str[1], I);

        Str := gdcTemplate.FieldByName(fnTemplateType).AsString;
        I := Length(Str);
        TmpStream.Write(I, SizeOf(I));
        TmpStream.Write(Str[1], I);

        Str := gdcTemplate.FieldByName(fnName).AsString;
        I := Length(Str);
        TmpStream.Write(I, SizeOf(I));
        TmpStream.Write(Str[1], I);
      end;

      dfPropertyTree.dfClipboard.FillClipboard(TmpStream, ItemType);
    except
      raise Exception.Create(dfCopyError);
    end;
  finally
    TmpStream.Free;
  end;
end;

procedure TReportFrame.PasteObject;
var
  LStream: TStream;
  Str, tmpStr: String;
  I: Integer;
  ItemType: TTreeItemType;
  gdcTemplate: TgdcBase;
  StreamType: TrStreamType;
  Present: Boolean;
  OldMainName, NewMainName, OldParamName,
  NewParamName, OldEventName, NewEventName: String;
  SearchOptions: TSynSearchOptions;

  procedure ReadRepFunction(const RepFuncType: TrStreamType;
    const RepFunction: TgdcFunction);
  var
    ParamStr: TStream;
    CurFrame: TFunctionFrame;
  begin
    case RepFuncType of
      rsEvent:
        CurFrame := EventFunctionFrame;
      rsParams:
        CurFrame := ParamFunctionFrame;
      rsMain:
        CurFrame := MainFunctionFrame;
    else
      CurFrame := nil;
    end;
    with dfPropertyTree.dfClipboard.ObjectStream do
    begin
      Read(StreamType, SizeOf(StreamType));
      if StreamType <> RepFuncType then
        raise Exception.Create(dfPasteError);

      Read(Present, SizeOf(Present));
      if not Present then
        Exit;

      Read(I, SizeOf(I));
      SetLength(Str, I);
      Read(Str[1], I);
      TmpStr := GetUniCopyname(Str, RepFunction.ID);//GetUniFuncname(Str, RepFunction.FieldByName(fnModulecode).AsInteger);
      if Length(TmpStr) = 0 then
        TmpStr := Str;
      RepFunction.FieldByName(fnName).AsString := TmpStr;
      case RepFuncType of
        rsMain:
        begin
          OldMainName := Str;
          NewMainName := TmpStr;
        end;
        rsEvent:
        begin
          OldEventName := Str;
          NewEventName := TmpStr;
        end;
        rsParams:
        begin
          OldParamName := Str;
          NewParamName := TmpStr;
        end;
      end;

      Read(I, SizeOf(I));
      SetLength(Str, I);
      Read(Str[1], I);
      RepFunction.FieldByName(fnScript).AsString := Str;

      Read(I, SizeOf(I));
      SetLength(Str, I);
      Read(Str[1], I);
      RepFunction.FieldByName(fnComment).AsString := Str;

      ParamStr := RepFunction.CreateBlobStream(RepFunction.FieldByName(fnEnteredParams), DB.bmWrite);
      try
        Read(I, SizeOf(I));
        if I > 0 then
        begin
          ParamStr.CopyFrom(dfPropertyTree.dfClipboard.ObjectStream, I);
          ParamStr.Position := 0;
          if Assigned(CurFrame) then
            CurFrame.FunctionParams.LoadFromStream(ParamStr);
        end;
      finally
        ParamStr.Free;
      end;
      if Assigned(CurFrame) then
        CurFrame.Modify := True;
    end;
  end;

begin
  if dfPropertyTree.dfClipboard.ObjectType <> tiReport then
    raise Exception.Create(dfPasteError);

  NewMainName  := '';
  NewParamName := '';
  NewEventName := '';
  with dfPropertyTree.dfClipboard do
  try
    ObjectStream.Position := 0;
    ObjectStream.ReadBuffer(ItemType, SizeOf(ItemType));
    if ItemType <> tiReport then
      raise Exception.Create(dfPasteError);

    ObjectStream.ReadBuffer(I, SizeOf(I));
    SetLength(Str, I);
    if I > 0 then
      ObjectStream.ReadBuffer(Str[1], I);

//        tmpStr := 'SELECT rl.name FROM rp_reportlist rl WHERE reportgroupkey = ' +
//          gdcReport.FieldByName('reportgroupkey').AsString;
    tmpStr := GetUniCopyname(Str, gdcReport.ID);// GetUniname(TmpStr, Str, NameList, IBSQL);
    if Length(tmpStr) > 0 then
      gdcReport.FieldByName(fnName).AsString := TmpStr
    else
      gdcReport.FieldByName(fnName).AsString := Str;
          
    Node.Text := gdcReport.FieldByName(fnName).AsString;
    SpeedButton.Caption := Node.Text;

    ObjectStream.ReadBuffer(I, SizeOf(I));
    SetLength(Str, I);
    if I > 0 then
      ObjectStream.ReadBuffer(Str[1], I);
    gdcReport.FieldByName(fnDescription).AsString := Str;
    ObjectStream.ReadBuffer(I, SizeOf(I));
    gdcReport.FieldByName(fnFRQREFRESH).AsInteger := I;
    ObjectStream.ReadBuffer(I, SizeOf(I));
    if I > 0 then
      gdcReport.FieldByName(fnServerKey).AsInteger := I;

    ReadRepFunction(rsEvent, EventFunctionFrame.gdcFunction);
    ReadRepFunction(rsMain, MainFunctionFrame.gdcFunction);
    ReadRepFunction(rsParams, ParamFunctionFrame.gdcFunction);


    ObjectStream.ReadBuffer(StreamType, SizeOf(StreamType));
    if StreamType <> rsTemplate then
      raise Exception.Create(dfPasteError);

    ObjectStream.ReadBuffer(Present, SizeOf(Present));
    if Present then
    begin
      gdcTemplate := TemplateFrame.gdcTemplate;

      ObjectStream.ReadBuffer(I, SizeOf(I));
      LStream := gdcTemplate.CreateBlobStream(
        gdcTemplate.FieldByName(fnTemplatedata), DB.bmWrite);
      try
        if LStream = nil then
          raise Exception.Create(dfPasteError);
        LStream.CopyFrom(ObjectStream, I);
      finally
        LStream.Free;
      end;

      ObjectStream.ReadBuffer(I, SizeOf(I));
      SetLength(Str, I);
      if I > 0 then
        ObjectStream.ReadBuffer(Str[1], I);
      gdcTemplate.FieldByName(fnDescription).AsString := Str;

      ObjectStream.ReadBuffer(I, SizeOf(I));
      SetLength(Str, I);
      if I > 0 then
        ObjectStream.ReadBuffer(Str[1], I);
      gdcTemplate.FieldByName(fnTemplateType).AsString := Str;

      ObjectStream.ReadBuffer(I, SizeOf(I));
      SetLength(Str, I);
      if I > 0 then
        ObjectStream.ReadBuffer(Str[1], I);

      tmpStr := GetUniCopyname(Str, gdcTemplate.ID);

      if Length(tmpStr) > 0 then
        gdcTemplate.FieldByName(fnName).AsString := TmpStr
      else
        gdcTemplate.FieldByName(fnName).AsString := Str;

      gdcTemplate.Post;
      gdcTemplate.Edit;
    end;
  except
    raise Exception.Create(dfPasteError);
  end;
  Repaint;

  if MessageBox(Handle, 'Вставлен отчет из буфера. Скорректировать имена скрипт-функций?',
    'Вставка отчета',
    MB_YESNO or MB_ICONINFORMATION or MB_TASKMODAL or MB_TOPMOST) = IDYES then
  begin
    SearchOptions := [ssoWholeWord, ssoReplaceAll];
    if Length(NewMainName) > 0 then
    begin
      MainFunctionFrame.gsFunctionSynEdit.SearchReplace(OldMainName, NewMainName, SearchOptions);
    end;
    if Length(NewParamName) > 0 then
    begin
      ParamFunctionFrame.gsFunctionSynEdit.SearchReplace(OldParamName, NewParamName, SearchOptions);
    end;
    if Length(NewEventName) > 0 then
    begin
      EventFunctionFrame.gsFunctionSynEdit.SearchReplace(OldEventName, NewEventName, SearchOptions);
    end;
  end;
end;

procedure TReportFrame.iblFolderChange(Sender: TObject);
begin
  Modify := True;
end;

class function TReportFrame.GetNameById(Id: Integer): string;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text := 'SELECT name FROM rp_reportlist WHERE id = :id';
    SQL.ParamByname('id').AsInteger := Id;
    SQL.ExecQuery;

    if SQl.RecordCount > 0 then
    begin
      Result := 'Отчет ' + SQL.FieldByName('name').AsString;
    end else
      Result := '';
  finally
    SQL.Free;
  end;
end;

class function TReportFrame.GetFunctionIdEx(Id: Integer): integer;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQl.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQl.Text := 'SELECT mainformulakey FROM rp_reportlist WHERE id = :id';
    SQL.ParamByName('id').AsInteger := Id;
    SQL.ExecQuery;
    Result := SQL.FieldByName('mainformulakey').AsInteger;
  finally
    SQL.Free;
  end;
end;

procedure TReportFrame.gdcReportAfterEdit(DataSet: TDataSet);
begin
  edtRUIDReport.Text:= gdcBaseManager.GetRUIDStringByID(gdcReport.ID);
end;

procedure TReportFrame.btnCopyRUIDReportClick(Sender: TObject);
begin
  Clipboard.AsText:= edtRUIDReport.Text;
end;

procedure TReportFrame.pMainResize(Sender: TObject);
begin
  edtRUIDReport.Width:= pMain.ClientWidth - edtRUIDReport.Left - 87;
  pnlRUIDReport.Left:= edtRUIDReport.Left + edtRUIDReport.Width + 2;
  pnlRUIDReport.Width:= 75;
end;

procedure TReportFrame.gdcReportAfterInternalDeleteRecord(
  DataSet: TDataSet);
var
  SQL: TIBSQL;
  S: String;
begin
  if MainFunctionFrame.gdcFunction.RecordUsed <= 1 then
    S := IntToStr(MainFunctionFrame.ObjectId);

  if ParamFunctionFrame.gdcFunction.RecordUsed <= 1 then
  begin
    if S > '' then S := S + ',';
    S := S + IntToStr(ParamFunctionFrame.ObjectId);
  end;

  if EventFunctionFrame.gdcFunction.RecordUsed <= 1 then
  begin
    if S > '' then S := S + ',';
    S := S + IntToStr(EventFunctionFrame.ObjectId);
  end;

  if S > '' then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcReport.Transaction;
      SQL.SQL.Text := 'DELETE FROM gd_function WHERE id IN (' + S + ')';
      try
        SQL.ExecQuery;
      except
        on E: Exception do
          Application.ShowException(E);
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TReportFrame.gdcReportAfterDelete(DataSet: TDataSet);
var
  N: TTreeNode;
begin
  N := Node;
  inherited;
  if Assigned(N) then
    N.Delete;
end;

initialization
  RegisterClass(TReportFrame);
finalization
  UnRegisterClass(TReportFrame);
end.
