{++

  Copyright (c) 2001 by Golden Software of Belarus
  
  Module

    prp_frmGedeminProperty_Unit.pas

  Abstract

    Gedemin project. TfrmGedeminProperty.

  Author

    Karpuk Alexander

  Revisions history

    1.00    17.10.02    tiptop        Initial version.
--}

unit prp_frmGedeminProperty_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  prp_frm_Unit, ExtCtrls, TB2Dock, TB2Toolbar, ComCtrls, ActnList, ImgList,
  prp_DockForm_unit, TB2Item, prp_TreeItems, AppEvnts, obj_i_Debugger, gd_createable_form,
  prp_PropertySettings, contnrs, dmImages_unit, evt_i_Base, flt_frmSQLEditorSyn_unit,
  SynEditHighlighter, SynHighlighterVBScript, Menus, prp_frmRuntimeScript,
  prp_dfMessages_unit, prp_frmClassesInspector_unit,  prp_dfPropertyTree_Unit,
  prp_dfBreakPoints_unit, Db, IBCustomDataSet, gdcBase, gdcTaxFunction,
  rp_BaseReport_unit, gd_security, prp_dlgCodeTemplates_unit;

type
  TfrmGedeminProperty = class(Tprp_frm)
    tbtMenu: TTBToolbar;
    tbtTree: TTBToolbar;
    ActionList: TActionList;
    imFunction: TImageList;
    imglActions: TImageList;
    actShowTree: TAction;
    actShowMessages: TAction;
    TBSubmenuItem1: TTBSubmenuItem;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    tbtSpeedButtons: TTBToolbar;
    actPost: TAction;
    actCancel: TAction;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    actFindSfById: TAction;
    TBSubmenuItem2: TTBSubmenuItem;
    actlDebug: TActionList;
    actDebugRun: TAction;
    actDebugStepIn: TAction;
    actDebugStepOver: TAction;
    actDebugGotoCursor: TAction;
    actDebugPause: TAction;
    actProgramReset: TAction;
    actToggleBreakpoint: TAction;
    actEvaluate: TAction;
    TBToolbar5: TTBToolbar;
    TBItem23: TTBItem;
    TBItem24: TTBItem;
    TBSeparatorItem11: TTBSeparatorItem;
    TBItem17: TTBItem;
    TBItem29: TTBItem;
    TBSubmenuItem3: TTBSubmenuItem;
    TBItem41: TTBItem;
    TBItem34: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem40: TTBItem;
    TBItem39: TTBItem;
    TBItem38: TTBItem;
    TBItem6: TTBItem;
    TBItem35: TTBItem;
    TBSeparatorItem19: TTBSeparatorItem;
    TBItem31: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem7: TTBItem;
    actPrepare: TAction;
    TBSubmenuItem4: TTBSubmenuItem;
    actSettings: TAction;
    TBItem9: TTBItem;
    TBItem3: TTBItem;
    actFindInDB: TAction;
    actSQLEditor: TAction;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem10: TTBItem;
    TBItem11: TTBItem;
    actEditorSet: TAction;
    TBToolbar1: TTBToolbar;
    TBItem12: TTBItem;
    TBItem13: TTBItem;
    TBItem14: TTBItem;
    TBItem15: TTBItem;
    TBItem16: TTBItem;
    TBItem18: TTBItem;
    TBItem19: TTBItem;
    actLoadFromFile: TAction;
    actSaveToFile: TAction;
    actFind: TAction;
    actReplace: TAction;
    TBSeparatorItem4: TTBSeparatorItem;
    TBSeparatorItem5: TTBSeparatorItem;
    actCopy: TAction;
    actCut: TAction;
    actPaste: TAction;
    actCopySQL: TAction;
    actPasteSQL: TAction;
    TBSeparatorItem6: TTBSeparatorItem;
    TBItem20: TTBItem;
    TBItem21: TTBItem;
    TBItem22: TTBItem;
    TBSeparatorItem7: TTBSeparatorItem;
    TBItem25: TTBItem;
    actGotoOnExecute: TAction;
    TBItem26: TTBItem;
    TBSubmenuItem5: TTBSubmenuItem;
    TBItem27: TTBItem;
    TBItem28: TTBItem;
    TBItem30: TTBItem;
    TBItem32: TTBItem;
    TBSeparatorItem8: TTBSeparatorItem;
    actSaveAll: TAction;
    actClose: TAction;
    actCloseAll: TAction;
    TBItem33: TTBItem;
    TBSeparatorItem9: TTBSeparatorItem;
    TBItem36: TTBItem;
    actBuildReport: TAction;
    TBSeparatorItem10: TTBSeparatorItem;
    TBItem37: TTBItem;
    actShowCallStack: TAction;
    TBItem42: TTBItem;
    SynVBScriptSyn: TSynVBScriptSyn;
    TBToolbar2: TTBToolbar;
    TBItem43: TTBItem;
    actShowRuntime: TAction;
    TBItem44: TTBItem;
    actShowWatchList: TAction;
    TBItem45: TTBItem;
    actAddWatch: TAction;
    TBItem8: TTBItem;
    TBItem47: TTBItem;
    actShowClassesInsp: TAction;
    actGotoNext: TAction;
    actGotoPrev: TAction;
    actShowBreakPoints: TAction;
    TBItem46: TTBItem;
    actCompaleProject: TAction;
    TBItem48: TTBItem;
    TBSeparatorItem12: TTBSeparatorItem;
    TBItem49: TTBItem;
    TBSeparatorItem13: TTBSeparatorItem;
    TBItem50: TTBItem;
    TBSeparatorItem14: TTBSeparatorItem;
    TBItem51: TTBItem;
    TBSeparatorItem15: TTBSeparatorItem;
    TBItem52: TTBItem;
    TBItem53: TTBItem;
    TBItem54: TTBItem;
    TBItem55: TTBItem;
    TBSeparatorItem16: TTBSeparatorItem;
    TBItem56: TTBItem;
    TBSubmenuItem6: TTBSubmenuItem;
    actHelp: TAction;
    TBItem57: TTBItem;
    actTypeInfo: TAction;
    TBItem58: TTBItem;
    actTypeInformation: TAction;
    TBSeparatorItem17: TTBSeparatorItem;
    TBItem59: TTBItem;
    actVBScripthelp: TAction;
    actFastReportHelp: TAction;
    actPGHelp: TAction;
    TBItem60: TTBItem;
    TBItem61: TTBItem;
    TBItem62: TTBItem;
    TBSeparatorItem18: TTBSeparatorItem;
    TBSubmenuItem7: TTBSubmenuItem;
    TBItem63: TTBItem;
    actCodeTemplates: TAction;
    actFindDelEventsSF: TAction;
    actGoToLineNumber: TAction;
    TBSeparatorItem20: TTBSeparatorItem;
    TBItem65: TTBItem;
    TBSeparatorItem21: TTBSeparatorItem;
    TBItem64: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actShowTreeUpdate(Sender: TObject);
    procedure actShowTreeExecute(Sender: TObject);
    procedure actShowMessagesUpdate(Sender: TObject);
    procedure actShowMessagesExecute(Sender: TObject);
    procedure actPostUpdate(Sender: TObject);
    procedure actPostExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actFindSfByIdExecute(Sender: TObject);
    procedure actDebugRunUpdate(Sender: TObject);
    procedure actDebugRunExecute(Sender: TObject);
    procedure actDebugStepInUpdate(Sender: TObject);
    procedure actDebugStepInExecute(Sender: TObject);
    procedure actDebugStepOverExecute(Sender: TObject);
    procedure actDebugGotoCursorExecute(Sender: TObject);
    procedure actDebugPauseExecute(Sender: TObject);
    procedure actDebugPauseUpdate(Sender: TObject);
    procedure actProgramResetUpdate(Sender: TObject);
    procedure actProgramResetExecute(Sender: TObject);
    procedure actEvaluateExecute(Sender: TObject);
    procedure actEvaluateUpdate(Sender: TObject);
    procedure actSettingsExecute(Sender: TObject);
    procedure actPrepareExecute(Sender: TObject);
    procedure actPrepareUpdate(Sender: TObject);
    procedure actFindInDBExecute(Sender: TObject);
    procedure actSQLEditorExecute(Sender: TObject);
    procedure actEditorSetExecute(Sender: TObject);
    procedure actToggleBreakpointExecute(Sender: TObject);
    procedure actToggleBreakpointUpdate(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actLoadFromFileUpdate(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actSaveToFileUpdate(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actCutUpdate(Sender: TObject);
    procedure actPasteUpdate(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actCopySQLExecute(Sender: TObject);
    procedure actCopySQLUpdate(Sender: TObject);
    procedure actPasteSQLUpdate(Sender: TObject);
    procedure actPasteSQLExecute(Sender: TObject);
    procedure actGotoOnExecuteUpdate(Sender: TObject);
    procedure actGotoOnExecuteExecute(Sender: TObject);
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure actSaveAllUpdate(Sender: TObject);
    procedure actSaveAllExecute(Sender: TObject);
    procedure actCloseUpdate(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actCloseAllExecute(Sender: TObject);
    procedure actBuildReportUpdate(Sender: TObject);
    procedure actBuildReportExecute(Sender: TObject);
    procedure actShowCallStackUpdate(Sender: TObject);
    procedure actShowCallStackExecute(Sender: TObject);
    procedure TBItem43Click(Sender: TObject);
    procedure actShowRuntimeExecute(Sender: TObject);
    procedure actShowWatchListUpdate(Sender: TObject);
    procedure actShowWatchListExecute(Sender: TObject);
    procedure actAddWatchExecute(Sender: TObject);
    procedure actShowClassesInspExecute(Sender: TObject);
    procedure actGotoNextExecute(Sender: TObject);
    procedure actGotoPrevExecute(Sender: TObject);
    procedure actShowBreakPointsExecute(Sender: TObject);
    procedure actCloseAllUpdate(Sender: TObject);
    procedure actCompaleProjectExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure actTypeInformationExecute(Sender: TObject);
    procedure actCompaleProjectUpdate(Sender: TObject);
    procedure actVBScripthelpExecute(Sender: TObject);
    procedure actFastReportHelpExecute(Sender: TObject);
    procedure actPGHelpExecute(Sender: TObject);
    procedure TBSubmenuItem7Popup(Sender: TTBCustomItem;
      FromLink: Boolean);
    procedure actCodeTemplatesExecute(Sender: TObject);
    procedure actFindDelEventsSFExecute(Sender: TObject);
    procedure actGoToLineNumberUpdate(Sender: TObject);
    procedure actGoToLineNumberExecute(Sender: TObject);
  private
    { Private declarations }
    FRun: Boolean;
    FRestored: Boolean;
    FPropertyTreeForm: TdfPropertyTree;
    FMessagesForm: TdfMessages;
    FCallStackForm: TDockableForm;
    FWatchListForm: TDockableForm;
    FRunTimeForm: TDockableForm;
    FBreakPoints: TdfBreakPoints;
    FActiveFrame: TFrame;
    //Список объектов которые не привязаны к другим
    FGhostObjects: TObjectList;
    FCanChangeCaption: Boolean;
    FUpdateNode: Boolean;
    {$IFDEF DEBUG}
    FPreparedScript: String;
    {$ENDIF}

    FSQLEditor: TfrmSQLEditorSyn;
    FOldOnShowHint: TShowHintEvent;

    FNeedCloseAfterEdit: Boolean;
    FActivate: Boolean;

    FOpenedSF: TStrings;
    FDeskTopSF: TStrings;
    FDestroying: Boolean;

    FCodeTemplates: TStrings;
    procedure WMShowWindow(var Message: TWMShowWindow); message WM_SHOWWINDOW;

    function AddSpeedButton(Name: String; Frame: TFrame;
      ImageIndex: Integer = -1): TTBCustomItem;
    procedure OnSpeedButtonClick(Sender: TObject);
    procedure OnChange(Sender: TObject);
    procedure OnFrameDestroy(Sender: TObject; ShowNext: Boolean);
    function CheckModefy: Boolean;
    procedure OnDebuggerStateChange(Sender: TObject;
      OldState, NewState: TDebuggerState);
    procedure OnDebuggerStateChanged(Sender: TObject);
    procedure OnCurrentLineChange(Sender: TObject);
    procedure OpenFunction(Id: Integer);
    //Сравнивает новые установки фильтров и старые и если
    //они не равны то возвращает тру
    function NeedSFRefresh(OldPS: TSettings): Boolean;
    function NeedObjectsRefresh(OldPS: TSettings): Boolean;
    function NeedClassesRefresh(OldPS: TSettings): Boolean;
    function NeedFullClassName(OldPS: TSettings): Boolean;
    //Процедуры обновления дерева
    function RefreshSf: Boolean;
    function RefreshObjects: Boolean;
    function RefreshClasses: Boolean;
    function RefreshFullClassName(const FullClassName: Boolean): Boolean;
    //
    function EventsEditing: Integer;
    function MethodsEditing: Integer;
    //Процедура настроики цветов и кнопок редактора
    procedure UpdateSyncs;
    procedure SetCanChangeCaption(const Value: Boolean);
    //Изменяет заголовок формы
    procedure SetCaption(State: TDebuggerState);
    //Возвращает строковое значение состояния дебагера
    function GetDebugStateName(State: TDebuggerState): String;
    function GetModifiedCount: Integer;
    procedure ClearCallStack;
    function GetEditingCont: Integer;

    procedure InsertCurrentText(const InsertText: String);

//    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure Restore;
    procedure SetNeedCloseAfterEdit(const Value: Boolean);
    procedure OnFrameButtonClick(Sender: TObject);
    procedure UpdateFrameButtonState(V: Boolean);
    procedure OnReopenClick(Sender: TObject);
    procedure ReopenSF(S: String);
    function SFEditing: Integer;
  protected
    procedure OnChangeNode(Sender: TObject; Node: TTreeNode);
    procedure OnCaretPosChange(Sender: TObject; const X,Y: Integer);
    procedure CancelAll;
    procedure OnShowHint(var HintStr: String;
      var CanShow: Boolean; var HintInfo: THintInfo);
    procedure SelectNextFrame(SelectNext: Boolean);
    procedure SetEnabled(Value: Boolean); override;
    procedure UpdateCodeTemlates;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure BeforeDestruction; override;
    procedure PrepareForModal;
    procedure DoFind;
    { Public declarations }
    // Устанавливает в инсп.классов текущий класс
    procedure SetInsCurrentClass;
    procedure SaveSettings; override;
    procedure LoadSettingsAfterCreate; override;
    procedure OnDockWindowDestroy(Sender: TDockableForm); override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    procedure ShowFrame(TI: TCustomTreeItem; AShow: Boolean = True);
    function IndexOfFrame(Frame: TFrame): Integer;
    procedure SetActive(Frame: TFrame);
    function CheckDestroying: Boolean;

    procedure GoToClassMethods(AClassName, ASubType: string);
    procedure EditObject(const Component: TComponent;
      const EditMode: TEditMode = emNone; EventName: String = '';
      const AFunctionID: integer = 0);
    function EditScriptFunction(const FunctionKey: Integer): Boolean;
    procedure DebugScriptFunction(const FunctionKey: Integer;
      const CurrentLine: Integer = - 1);
    //вывод окна редактирования отчета
    procedure EditReport(const IDReportGroup, IDReport: Integer); overload;
    //В отличие от первого метода делает попытку открыть только существующий отчет
    procedure EditReport(const IDReport: Integer); overload;
    procedure EditMacro(const IDMacro: Integer);
    procedure DeleteEvent(FormName, ComponentName,
      EventName: string);
    procedure PropertyNotification(AComponent: TComponent;
      Operation: TPrpOperation; const AOldName: string = '');
    //Ищет и открывает на редактирование функцию
    procedure FindAndEdit(Id: Integer; Line: Integer = - 1; Column: Integer = 0; Error: Boolean = False);
    procedure UpdateErrors;
    procedure UpdateCallStack;
    procedure UpdateWatchList;
    procedure UpdateBreakPoints;
    procedure ClearErrorResult;
    procedure ClearSearchResult;
    procedure RefreshTree;
    procedure FindInDB;

    procedure ClearErrorList;
    procedure ShowErrorList(const ErrorList: TObjectList);
    //Указывает на возможность вывода инф. о запуске фун.
    property CanChangeCaption: Boolean read FCanChangeCaption write SetCanChangeCaption;
    //Количество изменненых скриптов
    property ModifiedCount: Integer read GetModifiedCount;
    property EditingCont: Integer read GetEditingCont;
    property ActiveFrame: TFrame read FActiveFrame;
    property NeedCloseAfterEdit: Boolean read FNeedCloseAfterEdit write SetNeedCloseAfterEdit;
    property Restored: Boolean read FRestored write FRestored;
    function GetCodeTemplate(AName: string): string;
  end;


var
  frmGedeminProperty: TfrmGedeminProperty;

implementation

uses
  prp_BaseFrame_unit,
  {$IFDEF GEDEMIN}
  prp_FunctionFrame_Unit, prp_EventFrame_unit, prp_MethodFrame_Unit,
  prp_VBClass_unit, prp_ConstFrame_Unit, prp_GOFrame_unit,
  prp_MacrosFrame, prp_ReportFrame_Unit,
  prp_SFFrame_unit,
  {$ENDIF}
  prp_dlgFindFunction,
  prp_MessageConst, gd_directories_const, prp_dlg_PropertySettings_unit,
  scr_i_FunctionList, dm_i_ClientReport_unit, gd_i_ScriptFactory,
  gdcBaseInterface, prp_Messages, IBSQL, gdcConstants,
  gd_security_operationconst, syn_ManagerInterface_unit, SynEditKeyCmds,
  gsResizer, evt_Base,  prp_dfCallStack_unit, gdHelp_Interface,
  {$IFDEF DEBUG}
  prp_PreparedScriptViewer_Unit,
  {$ENDIF}
  gsStorage, Storages, prp_dlgPropertyFind, prp_dfWatchList_unit,
  gdcCustomFunction, prp_frmLooseFunction_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}
CONST
  cCaption = 'Редактор скрипт-объектов %s';
  cFirstLoad = 'FirstLoad';
  cReopen = 'Reopen';
  cDeskTop = 'DeskTop';
  cReopenCount = 10;

  _Count: Integer = 0;
type
  TTBCustomToolbarAccess = class(TTBCustomToolbar);

procedure TfrmGedeminProperty.FormCreate(Sender: TObject);
begin
  inherited;
  UseDesigner := False;
  {$IFDEF DEBUG}
  TBToolbar2.Show;
  {$ELSE}
  TBToolbar2.Hide;
  {$ENDIF}
  FPropertyTreeForm := TdfPropertyTree.Create(Self);
  FPropertyTreeForm.DockForm := Self;
  TdfPropertyTree(FPropertyTreeForm).OnChangeNode := OnChangeNode;

  FMessagesForm := TdfMessages.Create(Self);
  FMessagesForm.DockForm := Self;

  FCallStackForm := TdfCallStack.Create(Self);
  FCallStackForm.DockForm := Self;

  FWatchListForm := TdfWatchList.Create(Self);
  FWatchListForm.DockForm := Self;

  FRunTimeForm := TfrmRuntimeScript.Create(Self);
  FRunTimeForm.DockForm := Self;

  FBreakPoints := TdfBreakPoints.Create(Self);
  FBreakPoints.DockForm := Self;

  if TfrmClassesInspector.IsDocked then
  begin
    actShowClassesInsp.Execute;
  end;


  FUpdateNode := True;
  if Assigned(Debugger) then
  begin
    Debugger.OnStateChange := OnDebuggerStateChange;
    Debugger.OnCurrentLineChange := OnCurrentLineChange;
    Debugger.OnStateChanged := OnDebuggerStateChanged;
  end;
  FGhostObjects := TObjectList.Create(True);
  //Обновляем настройки ShortCut-ов для Actin-ов
  UpdateSyncs;
  SetCaption(dsStopped);
  FOldOnShowHint := Application.OnShowHint;
  Application.OnShowHint := OnShowHint;
  FActivate := True;
  UpdateCodeTemlates;
  Restored := True;
end;

procedure TfrmGedeminProperty.actShowTreeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(FPropertyTreeForm);
end;

procedure TfrmGedeminProperty.actShowTreeExecute(Sender: TObject);
begin
  if Assigned(FPropertyTreeForm) then
  begin
    ReCalcDockBounds := False;
    try
      FPropertyTreeForm.Show;
    finally
      ReCalcDockBounds := True;
    end;
  end;
end;

procedure TfrmGedeminProperty.actShowMessagesUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(FMessagesForm) //and not FMessagesForm.Visible;
end;

procedure TfrmGedeminProperty.actShowMessagesExecute(Sender: TObject);
begin
  if Assigned(FMessagesForm) then
  begin
    ReCalcDockBounds := False;
    try
      FMessagesForm.Show;
    finally
      ReCalcDockBounds := True;
    end;
  end;
end;

class function TfrmGedeminProperty.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmGedeminProperty) then
    frmGedeminProperty := TfrmGedeminProperty.Create(AnOwner);

  Result := frmGedeminProperty;
end;

procedure TfrmGedeminProperty.ShowFrame(TI: TCustomTreeItem; AShow: Boolean = True);
var
  Index: Integer;
  Frame: TFrame;

  function FindFrame(const FrameClass: CBaseFrame): Boolean;
  var
    FI: Integer;
  begin
    Result := False;
    for FI := 0 to frmGedeminProperty.ComponentCount - 1 do
    begin
      if frmGedeminProperty.Components[FI].InheritsFrom(FrameClass) and
        (TI.Id = TBaseFrame(frmGedeminProperty.Components[FI]).ObjectId) then
      begin
        TI.EditorFrame := TBaseFrame(frmGedeminProperty.Components[FI]);
        if Ti.Node <> TBaseFrame(frmGedeminProperty.Components[FI]).Node then Exit;
        Result := True;
        if AShow then
          TBaseFrame(TI.EditorFrame).SpeedButton.Click;
        Break;
      end;
    end;
  end;

begin
  {$IFDEF GEDEMIN}
  try
    if Assigned(TI) and (FPropertyTreeForm <> nil) then
    begin
      if Assigned(TI.EditorFrame) then
      begin
        Index := IndexOfFrame(TI.EditorFrame);
        if Index > - 1 then
          SetActive(TI.EditorFrame)
        else
        begin
          Frame := TI.EditorFrame;
          FreeAndNil(Frame);
        end;
        Exit;
      end;
      case TI.ItemType of
        tiEvent:
        begin
          if FindFrame(TEventFrame) then
            Exit;
          TI.EditorFrame := TEventFrame.Create(Self);
        end;
        tiMethod:
        begin
          if FindFrame(TMethodFrame) then
            Exit;
          TI.EditorFrame := TMethodFrame.Create(Self);
        end;
        tiVBClass:
        begin
          if FindFrame(TVBClassFrame)  then
            Exit;
          TI.EditorFrame := TVBClassFrame.Create(Self);
        end;
        tiConst:
        begin
          if FindFrame(TConstFrame) then
            Exit;
          TI.EditorFrame := TConstFrame.Create(Self);
        end;
        tiGlobalObject:
        begin
          if FindFrame(TGOFrame) then
            Exit;
          TI.EditorFrame := TGOFrame.Create(Self);
        end;
        tiMacros:
        begin
          if FindFrame(TMacrosFrame) then
            Exit;
          TI.EditorFrame := TMacrosFrame.Create(Self);
        end;
        tiReport:
        begin
          if FindFrame(TReportFrame) then
            Exit;
          TI.EditorFrame := TReportFrame.Create(Self);
        end;
        tiSF:
        begin
          if FindFrame(TSFFrame) then
            Exit;
          TI.EditorFrame := TSFFrame.Create(Self);
        end;
      end;
      TBaseFrame(TI.EditorFrame).Visible := AShow;
      TBaseFrame(TI.EditorFrame).Parent := self;
      TBaseFrame(TI.EditorFrame).CustomTreeItem := TI;
      TI.EditorFrame.Name := '';
      try
        TBaseFrame(TI.EditorFrame).ObjectId := TI.Id;
      except
        { TODO :
тут не правильно. во-первых, даже если у пользователя
нет прав, то на экране будет следующая картина: редактор
с ивентом раскроется и тут же закроется. а во-вторых,
если произойдет другое исключение, не связанное с правами
оно погасится и будет непонятно что делать.
было бы правильней отлавливать только исключения
нарушения прав доступа. показывать пользователю
предупреждение, а все остальные исключения выкидывать дальше}

        // andreik добавил
        on E: Exception do
        begin
          //Если у пользователя нет прав то сгенерится исключение
          //Удаляем фраме
          TBaseFrame(TI.EditorFrame).Free;
          TI.EditorFrame := nil;

          //andreik
          Application.HandleException(E);

          Exit;
        end;
      end;
      TBaseFrame(TI.EditorFrame).PropertyTreeForm :=
        TdfPropertyTree(FPropertyTreeForm);
      TBaseFrame(TI.EditorFrame).Node := TI.Node;
      if AShow then
      begin
        AddSpeedButton(TI.Name, TI.EditorFrame).Checked := True;
        TBaseFrame(TI.EditorFrame).Parent := Self;
        FActiveFrame := TI.EditorFrame;
        TBaseFrame(TI.EditorFrame).OnChange := OnChange;
        TBaseFrame(TI.EditorFrame).OnDestroy := OnFrameDestroy;
        TBaseFrame(TI.EditorFrame).OnCaretPosChange := OnCaretPosChange;
        if FMessagesForm <> nil then
          TBaseFrame(TI.EditorFrame).MessageListView :=
            TdfMessages(FMessagesForm).lvMessages;
        Show;
      end;
    end;
  except
  end;
  UpdateFrameButtonState(FActiveFrame <> nil);
  {$ENDIF}
end;

function TfrmGedeminProperty.AddSpeedButton(Name: String;
  Frame: TFrame; ImageIndex: Integer): TTBCustomItem;
begin
  Result := TTBCustomItem.Create(tbtSpeedButtons);
  Result.Caption := Name;
  Result.ImageIndex := ImageIndex;
  Result.GroupIndex := 1;
  Result.Tag := Integer(Frame);
  Result.AutoCheck := True;
  Result.OnClick := OnSpeedButtonClick;
  Result.Hint := TBaseFrame(Frame).InfoHint;
  tbtSpeedButtons.PopupMenu := Frame.PopupMenu;
  TBaseFrame(Frame).SpeedButton := Result;
  tbtSpeedButtons.Items.Add(Result);
  tbtSpeedButtons.Items.Add(TTBSeparatorItem.Create(tbtSpeedButtons));
end;

procedure TfrmGedeminProperty.OnSpeedButtonClick(Sender: TObject);
var
  TV: TTreeView;
  N: TTreeNode;
begin
  //Показываем фрэйм
  if  TFrame(TTBCustomItem(Sender).Tag) <> FActiveFrame then
  begin
    if not TFrame(TTBCustomItem(Sender).Tag).Visible then
      TFrame(TTBCustomItem(Sender).Tag).Show;
    TFrame(TTBCustomItem(Sender).Tag).BringToFront;
    if FActiveFrame <> nil then
      FActiveFrame.Visible := False;
    if FActivate then
      TBaseFrame(TTBCustomItem(Sender).Tag).Activate;
    //Заполняем переменную текущего активного фрэйма
    FActiveFrame := TFrame(TTBCustomItem(Sender).Tag);
  end;
    tbtSpeedButtons.PopupMenu := FActiveFrame.PopupMenu;
  //  TBaseFrame(FActiveFrame).ApplicationEvents := ApplicationEvents;
  TTBCustomItem(Sender).Checked := True;
  N := TBaseFrame(TTBCustomItem(Sender).Tag).Node;
  if (FPropertyTreeForm <> nil) and
    FPropertyTreeForm.Visible then
  begin
    if (N <> nil) and FUpDateNode and (N.Owner <> nil) and (N.ItemId <> nil) then
    begin
      //Показываем нод, связанный с фрэймом
      TV := TTreeView(N.TreeView);
      TV.Show;
      N.MakeVisible;
      N.Selected := True;
    end;
  end;
  UpdateFrameButtonState(FActiveFrame <> nil);
end;

function TfrmGedeminProperty.IndexOfFrame(Frame: TFrame): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to tbtSpeedButtons.Items.Count - 1 do
  begin
    if TFrame(tbtSpeedButtons.Items[I].Tag) = Frame then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TfrmGedeminProperty.SetActive(Frame: TFrame);
var
  Index: Integer;
begin
  if Assigned(Frame) and (Frame <> FActiveFrame) then
  begin
    Index := IndexOfFrame(Frame);
    if (Index > - 1) then tbtSpeedButtons.Items[Index].Click;
  end;
  
end;

procedure TfrmGedeminProperty.OnChange(Sender: TObject);
begin

end;

procedure TfrmGedeminProperty.actPostUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(FActiveFrame) and
    TBaseFrame(FActiveFrame).Modify;
end;

procedure TfrmGedeminProperty.actPostExecute(Sender: TObject);
var
  Index: Integer;
begin
  TBaseFrame(FActiveFrame).Post;
  Index := IndexOfFrame(FActiveFrame);
  if Index > - 1 then
    tbtSpeedButtons.Items[Index].Hint := TBaseFrame(FActiveFrame).InfoHint;
end;

procedure TfrmGedeminProperty.actCancelExecute(Sender: TObject);
begin
  TBaseFrame(FActiveFrame).Cancel;
end;

procedure TfrmGedeminProperty.OnFrameDestroy(Sender: TObject; ShowNext: Boolean);
var
  Index: Integer;
  S: string;
begin
  Index := IndexOfFrame(TFrame(Sender));
  if Index > - 1 then
  begin
  //Удаляем сепаратор
    tbtSpeedButtons.Items.Delete(Index + 1);
  //Удаляем кнопку
    tbtSpeedButtons.Items.Delete(Index);
    if FActiveFrame = TFrame(Sender) then
      FActiveFrame := nil;
    if ShowNext and Visible then
    begin
      if Index < tbtSpeedButtons.Items.Count - 1 then
      try
        FUpdateNode := False;
        SetActive(TFrame(tbtSpeedButtons.Items[Index].Tag))
      finally
        FUpdateNode := True;
      end else
      if tbtSpeedButtons.Items.Count > 0 then
      try
        FUpdateNode := False;
        SetActive(TFrame(tbtSpeedButtons.Items[tbtSpeedButtons.Items.Count - 2].Tag))
      finally
        FUpdateNode := True;
      end;
    end;

    S := IntToStr(TBaseFrame(Sender).ObjectId) + '=' + TBaseFrame(Sender).ClassName;
    Index := FOpenedSF.IndexOf(S);
    if Index > - 1 then
      FOpenedSF.Delete(Index);

    FOpenedSF.Insert(0, S);
    while FOpenedSF.Count >  cReopenCount do
    begin
      FOpenedSF.Delete(FOpenedSF.Count - 1);
    end;
    if FDestroying then
    begin
      FDeskTopSF.Add(S);
    end;
  end;
  UpdateFrameButtonState(FActiveFrame <> nil);
end;

procedure TfrmGedeminProperty.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  I: Integer;
begin
  CanClose := True;

  try
    for I := ComponentCount - 1 downto 0 do
    begin
      if Components[I] is TBaseFrame then
      begin
        if FShiftDown then
        begin
          FDestroying := True;
          try
            CanClose := TBaseFrame(Components[I]).CloseQuery;
            if CanClose then
              Components[I].Free;
          finally
            FDestroying := False;
          end;
        end else
          CanClose := TBaseFrame(Components[I]).CloseQuery;
      end;

      if not CanClose then
        Exit;
    end;
  except
  end;
end;

procedure TfrmGedeminProperty.actFindSfByIdExecute(Sender: TObject);
var
  TN: TTreeNode;
  ID: Integer;
begin
  if FPropertyTreeForm <> nil then
  begin
    if Pos('_', dlgPropertyFind.cbTextDB.Text) <> 0 then
      ID := gdcBaseManager.GetIDByRUIDString(dlgPropertyFind.cbTextDB.Text)
    else
      ID := StrToInt(dlgPropertyFind.cbTextDB.Text);

    TN := TdfPropertyTree(FPropertyTreeForm).FindSF(ID);
    if Assigned(Tn) then
      TdfPropertyTree(FPropertyTreeForm).OpenNode(TN);
  end;
end;

procedure TfrmGedeminProperty.actDebugRunUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(Debugger) and (Debugger.IsPaused or
    ((FActiveFrame <> nil) and TBaseFrame(FActiveFrame).CanRun and not FRun));
end;

procedure TfrmGedeminProperty.actDebugRunExecute(Sender: TObject);
begin
  ClearCallStack;
  if not (Assigned(Debugger) and (Debugger.IsPaused or
    ((FActiveFrame <> nil) and TBaseFrame(FActiveFrame).CanRun and not FRun))) then
    Exit;

  if not CheckModefy then
  begin
    CanChangeCaption := True;
    if not Debugger.IsPaused then
    begin
      if not FRun then
      begin
        FRun := True;
        try
          Debugger.Run;
          TBaseFrame(FActiveFrame).Run(sfUnknown);
        finally
          FRun := False;
        end;
      end;
    end else
      Debugger.Run;
  end;
end;

function TfrmGedeminProperty.CheckModefy: Boolean;
var
  MR: Integer;
  I: Integer;
begin
  Result := ModifiedCount > 0;
  if Result then
  begin
    if PropertySettings.GeneralSet.AutoSaveOnExecute then
      MR := ID_YES
    else
      MR := MessageBox(Application.Handle, 'Данные были изменены. Перед отладкой'#13 +
        'их необходимо сохранить. Сохранять?', MSG_WARNING, MB_YESNOCANCEL or MB_TASKMODAL);
    case MR of
      ID_YES:
      begin
        try
          Result := not actSaveAll.Execute;
        except
        end;
      end;
      ID_NO:
      begin
        try
          for I := 0 to ComponentCount - 1 do
          begin
            if (Components[I] is TBaseFrame) and
              TBaseFrame(Components[I]).Modify then
              TBaseFrame(Components[I]).Cancel;
          end;
          Result := False;
        except
        end;
      end;
    end;
  end;
end;

procedure TfrmGedeminProperty.OnDebuggerStateChange(Sender: TObject;
  OldState, NewState: TDebuggerState);
var
  I: Integer;
begin
  if not CheckDestroying then
  begin
    //!!! TipTop добавлено 30.10.2002
    //Идея в следующем: Если FCanChangeCaption = фолсе то
    //окно открыто не через DebugSritpFnction а значит и нечего обновлять
    if FCanChangeCaption then
    begin
    //!!!
      if Assigned(Debugger) then
      begin
        if Assigned(FActiveFrame) then
        begin
          if Active then
          begin
            TBaseFrame(FActiveFrame).GotoLine(Debugger.CurrentLine + 1, 0);
            TBaseFrame(FActiveFrame).InvalidateFrame;
          end;
          SetCaption(NewState);
        end;
      end;
    end;
    if _DebugLinkList <> nil then
    begin
      for I := 0 to _DebugLinkList.Count - 1 do
      begin
        with (_DebugLinkList[i] as TCustomDebugLink) do
          OnDebuggerStateChange(Sender, OldState, NewState);
      end;
    end;
  end;
end;

procedure TfrmGedeminProperty.OnCurrentLineChange(Sender: TObject);
begin
end;

function TfrmGedeminProperty.CheckDestroying: Boolean;
begin
  Result := Application.Terminated or (csDestroying in ComponentState) or
    (not IBLogin.LoggedIn);
end;

procedure TfrmGedeminProperty.actDebugStepInUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=  PropertySettings.DebugSet.UseDebugInfo and
    Assigned(Debugger) and Assigned(FActiveFrame) and
    not ((Debugger.IsRunning or  Debugger.IsStep or Debugger.IsStepOver) and not FRun) and
    (TBaseFrame(FActiveFrame).CanRun or Debugger.IsPaused);
end;

procedure TfrmGedeminProperty.actDebugStepInExecute(Sender: TObject);
begin
  ClearCallStack;
  if not Assigned(Debugger) or not Assigned(FActiveFrame) then
    Exit;

  if not CheckModefy then
  begin
    CanChangeCaption := True;
    if not Debugger.IsPaused then
    begin
      FRun := True;
      try
        Debugger.Step;
        TBaseFrame(FActiveFrame).Run(sfUnknown);
      finally
        FRun := False;
      end;
    end else
      Debugger.Step;
  end;
end;

procedure TfrmGedeminProperty.actDebugStepOverExecute(Sender: TObject);
begin
  ClearCallStack;
  if not Assigned(Debugger) or not Assigned(FActiveFrame) then
    Exit;

  if not CheckModefy then
  begin
    CanChangeCaption := True;
    if not Debugger.IsPaused then
    begin
      FRun := True;
      try
        Debugger.Step;
        TBaseFrame(FActiveFrame).Run(sfUnknown);
      finally
        FRun := False;
      end;
    end else
      Debugger.StepOver;
  end;
end;

procedure TfrmGedeminProperty.actDebugGotoCursorExecute(Sender: TObject);
begin
  ClearCallStack;
  if not Assigned(Debugger) or not Assigned(FActiveFrame) then
    Exit;

  if not CheckModefy then
  begin
    if not Debugger.IsPaused then
    begin
      FRun := True;
      try
        Debugger.GotoToLine(TBaseFrame(FActiveFrame).FunctionId,
          TBaseFrame(FActiveFrame).CaretXY.Y - 1);
        TBaseFrame(FActiveFrame).Run(sfUnknown);
      finally
        FRun := False;
      end;
    end else
      Debugger.GotoToLine(TBaseFrame(FActiveFrame).FunctionId,
        TBaseFrame(FActiveFrame).CaretXY.Y - 1);
  end;
end;


procedure TfrmGedeminProperty.LoadSettingsAfterCreate;
var
  F: TgsStorageFolder;
  Path: String;
  FirstLoad: Boolean;
  I: Integer;
begin
  inherited;
  if Assigned(UserStorage) then
  begin
    //Открываем папку в сторадже
    Path := Self.Name;
    F := UserStorage.OpenFolder(Path, True);
    if F <> nil then
    begin
      FirstLoad := F.ReadBoolean(cFirstLoad, True);
      if FirstLoad then
      begin
        FPropertyTreeForm.ManualDock(LeftDockPanel, nil, alClient);
        FMessagesForm.ManualDock(BottomDockPanel, nil, alClient);
        FCallStackForm.ManualDock(FMessagesForm, nil, alClient);
        FWatchListForm.ManualDock(FMessagesForm, nil, alClient);
        FRunTimeForm.Hide;
      end;

      FOpenedSF.Text := F.ReadString(cReopen, '');
      FDeskTopSF.Text := F.ReadString(cDeskTop, '');

      if (PropertySettings.GeneralSet.RestoreDeskTop) and (not Assigned(Debugger) or (Debugger.CurrentState = dsStopped)) then
      begin
        Restored := False;
        try
          for I := 0 to FDeskTopSF.Count - 1 do
          begin
            ReopenSf(FDeskTopSF[I]);
          end;
        finally
          Restored := True;
        end;
      end;
      FDeskTopSF.Clear;
    end;
    UserStorage.CloseFolder(F);
  end;
end;

procedure TfrmGedeminProperty.SaveSettings;
var
  F: TgsStorageFolder;
  Path: String;
begin
  inherited;
  if Assigned(UserStorage) then
  begin
    //Открываем папку в сторадже
    Path := Self.Name;
    F := UserStorage.OpenFolder(Path, True);
    try
      if F <> nil then
      begin
        F.WriteBoolean(cFirstLoad, False);
        F.WriteString(cReopen, FOpenedSF.Text);
        F.WriteString(cDeskTop, FDeskTopSF.Text);
      end;
    finally
      UserStorage.CloseFolder(F);
    end;
  end;
end;

procedure TfrmGedeminProperty.GoToClassMethods(AClassName,
  ASubType: string);
begin
  if FPropertyTreeForm = nil then Exit;
  Restore;
  Show;
  FPropertyTreeForm.GoToClassMethods(AClassName, ASubType);
end;

procedure TfrmGedeminProperty.EditObject(const Component: TComponent;
  const EditMode: TEditMode = emNone; EventName: String = '';
  const AFunctionID: integer = 0);
var
  P: TdfPropertyTree;
begin
  if FPropertyTreeForm = nil then Exit;
  Restore;
  Show;
  if Component <> nil then
  begin
    P := TdfPropertyTree(FPropertyTreeForm);
    case EditMode of
      emNone: P.OpenObjectPage(Component);
      emMacros: P.OpenMacrosRootFolder(Component);
      emReport: P.OpenReportRootFolder(Component);
      emEvent:  P.OpenEvent(Component, EventName, AFunctionID);
    end;
  end;
end;

procedure TfrmGedeminProperty.DebugScriptFunction(const FunctionKey,
  CurrentLine: Integer);
{$IFDEF DEBUG}
var
  F: TrpCustomFunction;
{$ENDIF}
var
  DL: TCustomDebugLink;
  I: Integer;
begin
  //Проверяем находится ли окно в режиме удаления
  if not CheckDestroying then
  begin
    DL := nil;
    if (_DebugLinkList <> nil) and (_DebugLinkList.Count > 0) then
    begin
      for I := 0 to _DebugLinkList.Count - 1 do
      begin
        if (_DebugLinkList[I] as TCustomDebugLink).FunctionKey = FunctionKey then
        begin
          DL :=(_DebugLinkList[I] as TCustomDebugLink);
          Break;
        end;
      end;
    end;

    Restore;

    if csDestroying in ComponentState then
      exit;

    if (DL = nil) or (DL.Form = nil) then
    begin
      //Показываем окно
      Show;
      if Assigned(Debugger) then
      begin
        try
          //ищем функцию
          FindAndEdit(FunctionKey);
          //перерисовываем окно редактора для обновления
          //текущей строки
          if Active then
            TBaseFrame(FActiveFrame).InvalidateFrame;
          //Устанавлваем флаг возможности вывода информации
          //о режиме работы дебагера
          CanChangeCaption := True;
          {$IFDEF DEBUG}
          if glbFunctionList <> nil then
          begin
            F := glbFunctionList.FindFunction(FunctionKey);
            try
              FPreparedScript := F.Script.Text;
            finally
              glbFunctionList.ReleaseFunction(F);
            end;
          end;
          {$ENDIF}
        except
        end;
      end;
    end else
    begin
      DL.ShowForm;
    end;
  end;
end;

procedure TfrmGedeminProperty.EditReport(const IDReportGroup, IDReport: Integer);
var
  RI: TReportTreeItem;
  SQL, oSQL: TIBSQL;
  I: Integer;
  TN: TTreeNode;
begin
  Restore;
  //Делаем потытку найти отчёт в дереве
  Show;
  if not TdfPropertyTree(FPropertyTreeForm).OpenReport(IDReport) then
  begin
    //Если отчёт в дереве не найден то ищем его в базе и
    //создаём фраме тля редактирования отчёта
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQl.SQL.Text := 'SELECT * FROM rp_reportlist WHERE id = ' + IntToStr(IDReport);
      SQL.ExecQuery;
      if not SQl.Eof then
      begin
        RI := TReportTreeItem.Create;
        RI.Id := IDReport;
        RI.Name := SQL.FieldByName(fnName).AsString;
        RI.MainOwnerName := 'Неизвестный';
        RI.Node := nil;
        RI.ReportFolderId := IDReportGroup;
        //т.к. Ri не привязана к ноду дерева то для последующего её удаления
        //добавляем в список объектов
        FGhostObjects.Add(Ri);
        //выводим Frame
        ShowFrame(RI);
      end else
      begin
        TN := TdfPropertyTree(FPropertyTreeForm).FindReportFolder(IDReportGroup, True);
        if TN <> nil then
        begin
          //Если найдена папка отчета то открываем ее и создаём в ней отчет
          TdfPropertyTree(FPropertyTreeForm).PageControl.ActivePage := TTreeTabSheet(TN.TreeView.Parent);
          TN.MakeVisible;
          TN.Selected := True;
          TdfPropertyTree(FPropertyTreeForm).AddReportItem;
          Exit;
        end;
        //Если отчета нет в базе то необходимо создать новый
        SQL.Close;
        //Вытягиваем дерево папок
        SQL.SQL.Text := 'SELECT rg2.* FROM rp_reportgroup rg1, rp_reportgroup rg2 ' +
          '  WHERE rg1.id = :id AND rg1.lb >= rg2.lb AND rg1.rb <= rg2.rb ' +
          '  ORDER BY rg2.lb';

        SQl.Params[0].AsInteger := IDReportGroup;
        SQL.ExecQuery;

        RI := TReportTreeItem.Create;
        RI.Id := 0;

        oSQL := TIBSQL.Create(nil);
        try
          //Получаем Ид объекта которому принадлежит отчёт
          oSQL.Transaction := gdcBaseManager.ReadTransaction;
          //Получаем уникальное имя
          RI.ReportFolderId := IDReportGroup;
          I := 0;
          oSQL.SQL.Text := 'SELECT * FROM rp_reportlist WHERE name = ' +
            ' :name AND reportgroupkey = :reportgroupkey';
          oSQL.Params[0].AsString := NEW_REPORT_NAME;
          oSQL.Params[1].AsInteger := IDReportGroup;
          oSQL.ExecQuery;

          while not oSQL.Eof do
          begin
            oSQL.Close;
            Inc(I);
            oSQL.Params[0].AsString := NEW_REPORT_NAME + IntToStr(I);
            oSQL.Params[1].AsInteger := IDReportGroup;
            oSQl.ExecQuery;
          end;

          RI.Name := oSQL.Params[0].AsString;

          oSQl.Close;
          { TODO :
          Здесь не правильно ищется ид объекта
          которому принадлежит отчет }
          oSQL.SQL.Text := 'SELECT o2.* FROM evt_object o1, evt_object o2, ' +
            ' rp_reportgroup r WHERE r.id = :reportgroupkey and ' +
            ' (o1.reportgroupkey = r.id or upper(o1.name) = Upper(r.usergroupname)) ' +
            ' AND o1.lb >= o2.lb AND o1.rb <= o2.rb AND o2.parent is null';
          oSQL.Params[0].AsInteger := SQL.FieldByName(fnId).AsInteger;
          oSQL.ExecQuery;
          if not oSQL.Eof then
          begin
            RI.OwnerId := oSQL.FieldByName(fnId).AsInteger;
            RI.MainOwnerName := oSQL.FieldByName(fnName).AsString
          end else
          begin
            //Если не найден объект то делаем предположение что отчёт
            //принадлежит Application
            RI.OwnerId := OBJ_APPLICATION;
            RI.MainOwnerName := 'APPLICATION';
          end;
          //т.к. Ri не привязана к ноду дерева то для последующего её удаления
          //добавляем в список объектов
          FGhostObjects.Add(Ri);
          //выводим Frame
          ShowFrame(RI);
          //Делаем пост
          TBaseFrame(FActiveFrame).Post;
        finally
          oSQl.Free;
        end;
      end;
    finally
      SQL.Free;
    end;
  end;
  //Выводим на передний план
  Show;
end;

function TfrmGedeminProperty.EditScriptFunction(
  const FunctionKey: Integer): Boolean;
{$IFDEF DEBUG}
var
  F: TrpCustomFunction;
{$ENDIF}
var
  DL: TCustomDebugLink;
  I: Integer;
begin
  Result := False;
  if not CheckDestroying then
  begin
    DL := nil;
    if (_DebugLinkList <> nil) and (_DebugLinkList.Count > 0) then
    begin
      for I := 0 to _DebugLinkList.Count - 1 do
      begin
        if (_DebugLinkList[I] as TCustomDebugLink).FunctionKey = FunctionKey then
        begin
          DL :=(_DebugLinkList[I] as TCustomDebugLink);
          Break;
        end;
      end;
    end;

    if (DL = nil) or (DL.Form = nil) then
    begin
      //Устанавлваем флаг возможности вывода информации
      //о режиме работы дебагера
      CanChangeCaption := True;

      Restore;

      if csDestroying in ComponentState then
        exit;

      Show;
      FindAndEdit(FunctionKey);
      UpdateErrors;
      if Assigned(FMessagesForm) then
        TdfMessages(FMessagesForm).GotoLastError;
    end else
      DL.ShowForm;

    Result := True;
    {$IFDEF DEBUG}
    if glbFunctionList <> nil then
    begin
      F := glbFunctionList.FindFunction(FunctionKey);
      try
        FPreparedScript := F.Script.Text;
      finally
        glbFunctionList.ReleaseFunction(F);
      end;
    end;
    {$ENDIF}
  end;
end;

procedure TfrmGedeminProperty.OpenFunction(Id: Integer);
var
  TN: TTReeNode;
begin
  if FPropertyTreeForm = nil then Exit;
  TN := TdfPropertyTree(FPropertyTreeForm).FindSF(ID);
  if Assigned(TN) then
  begin
    TdfPropertyTree(FPropertyTreeForm).OpenNode(TN);
    if Assigned(TCustomTreeItem(TN.Data).EditorFrame) then
      TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame).EditFunction(Id);
  end;
end;

procedure TfrmGedeminProperty.DeleteEvent(FormName, ComponentName,
  EventName: string);
var
  Ob: TEventObject;
  E: TEventItem;
  TN: TTreeNode;
  BF: TBaseFrame;
  EC: TEventControl;
begin
  if (FPropertyTreeForm = nil) or (EventControl = nil) then Exit;

  EC := TEventControl(EventControl.Get_Self);
  Ob := EC.EventObjectList.FindObject(FormName);
  if not Assigned(Ob) then
    raise Exception.Create('Не найдена форма');
  if UpperCase(FormName) <> UpperCase(ComponentName) then
    Ob := Ob.ChildObjects.FindAllObject(ComponentName);
  E := Ob.EventList.Find(EventName);
  if not Assigned(E) then
    raise Exception.Create('Не найдено событие');

  try
    TN := TdfPropertyTree(FPropertyTreeForm).FindSF(E.FunctionKey);
  except
    TN := nil;
  end;
  
  if TN <> nil then
  begin
    BF := TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame);
    if BF = nil then
    begin
      ShowFrame(TCustomTreeItem(TN.Data), False);
      BF := TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame);
    end;
    BF.ShowDeleteQuestion := False;
    BF.Delete
  end;
end;

procedure TfrmGedeminProperty.PropertyNotification(AComponent: TComponent;
  Operation: TPrpOperation; const AOldName: string);
begin
  if Operation = poPost then
    actSaveAllExecute(nil)
  else
  if (Operation = poInsert) or  (Operation = poRemove) then
    TdfPropertyTree(FPropertyTreeForm).InsertRemoveObject(AComponent, Operation)
  else
  if Operation = poRename then
    TdfPropertyTree(FPropertyTreeForm).RenameObject(AComponent, AOldName);

  if (ModifiedCount = 0) and FNeedCloseAfterEdit and
    (Operation in [poPost, poCancel]) then
    Close;
end;

procedure TfrmGedeminProperty.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TBaseFrame then
    begin
      TBaseFrame(Components[I]).OnChange := nil;
      TBaseFrame(Components[I]).OnDestroy := nil;
      TBaseFrame(Components[I]).OnCaretPosChange := nil;
    end else
    if Components[i] is TTBCustomItem then
      TTBCustomItem(Components[i]).OnClick := nil;
  end;

  if Assigned(Debugger) then
  begin
    Debugger.OnStateChange := nil;
    Debugger.OnCurrentLineChange := nil;
    Debugger.OnStateChanged := nil;
  end;
  FGhostObjects.Free;
  Application.OnShowHint := FOldOnShowHint;

  inherited;
  frmGedeminProperty := nil;
end;

procedure TfrmGedeminProperty.actDebugPauseExecute(Sender: TObject);
begin
  if Assigned(Debugger) then
    Debugger.WantPause;
end;

procedure TfrmGedeminProperty.actDebugPauseUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := PropertySettings.DebugSet.UseDebugInfo and
    Assigned(Debugger) and Debugger.FunctionRun and not Debugger.IsPaused;
end;

procedure TfrmGedeminProperty.actProgramResetUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=  PropertySettings.DebugSet.UseDebugInfo and
    Assigned(Debugger) and {Debugger.IsPaused;} Debugger.FunctionRun;
end;

procedure TfrmGedeminProperty.actProgramResetExecute(Sender: TObject);
begin
  if Assigned(Debugger) then
    Debugger.Reset;
end;

procedure TfrmGedeminProperty.actEvaluateExecute(Sender: TObject);
begin
  if Assigned(FActiveFrame) then
    TBaseFrame(FActiveFrame).Evaluate;
end;

procedure TfrmGedeminProperty.actEvaluateUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(FActiveFrame);
end;

procedure TfrmGedeminProperty.actSettingsExecute(Sender: TObject);
var
  S: TdlgPropertySettings;
  PS: TSettings;
  R: Boolean;
begin
  PS := PropertySettings;
  S := TdlgPropertySettings.Create(Application);
  try
    if S.ShowModal = mrOk then
    begin
      R := True;
      if R and NeedSFRefresh(PS) then
        R := RefreshSf;
      if R and NeedObjectsRefresh(PS) then
        R := RefreshObjects;
      if R and NeedClassesRefresh(PS) then
        RefreshClasses;
      if R and NeedFullClassName(PS) then
        RefreshFullClassName(PS.GeneralSet.FullClassName);

      if ((PS.DebugSet.UseDebugInfo <> PropertySettings.DebugSet.UseDebugInfo) or
        (PS.DebugSet.RuntimeSave <> PropertySettings.DebugSet.RuntimeSave)) and
        Assigned(glbFunctionList) then
      begin
        glbFunctionList.UpdateList;

        if Assigned(dm_i_ClientReport) then
        begin
          dm_i_ClientReport.CreateGlobalSF;
//          dm_i_ClientReport.CreateVBConst;
//          dm_i_ClientReport.CreateVBClasses;
//          dm_i_ClientReport.CreateGlObjArray;
        end;
        if Assigned(ScriptFactory) then
          ScriptFactory.Reset;
      end;
    end;
  finally
    S.Free;
    if Debugger <> nil then
      SetCaption(Debugger.CurrentState);
  end;
end;

function TfrmGedeminProperty.NeedSFRefresh(OldPS: TSettings): Boolean;
begin
  Result := not CompareMem(@OldPS.ViewSet.SFSet, @PropertySettings.ViewSet.SFSet,
    SizeOf(OldPS.ViewSet.SFSet));
end;

function TfrmGedeminProperty.NeedObjectsRefresh(OldPS: TSettings): Boolean;
begin
  Result := OldPS.Filter.foObject <> PropertySettings.Filter.foObject;
  if not Result then
    Result := OldPs.Filter.foEvent <> PropertySettings.Filter.foEvent;
  if not Result then
    Result := CompareText(OldPs.Filter.ObjectName,
      PropertySettings.Filter.ObjectName) <> 0;
  if not Result then
    Result := CompareText(OldPs.Filter.EventName,
      PropertySettings.Filter.EventName) <> 0;
  if not Result then
    Result := OldPS.Filter.OnlySpecEvent <> PropertySettings.Filter.OnlySpecEvent;
  if not Result then
    Result := OldPS.Filter.OnlyDisabled <> PropertySettings.Filter.OnlyDisabled;
end;

function TfrmGedeminProperty.NeedClassesRefresh(OldPS: TSettings): Boolean;
begin
  Result := OldPS.Filter.foClass <> PropertySettings.Filter.foClass;
  if not Result then
    Result := OldPs.Filter.foMethod <> PropertySettings.Filter.foMethod;
  if not Result then
    Result := CompareText(OldPs.Filter.ClassName,
      PropertySettings.Filter.ClassName) <> 0;
  if not Result then
    Result := CompareText(OldPs.Filter.MethodName,
      PropertySettings.Filter.MethodName) <> 0;
  if not Result then
    Result := OldPS.Filter.OnlySpecEvent <> PropertySettings.Filter.OnlySpecEvent;
  if not Result then
    Result := OldPS.Filter.OnlyDisabled <> PropertySettings.Filter.OnlyDisabled;
end;

function TfrmGedeminProperty.RefreshClasses: Boolean;
var
  I: Integer;
begin
  Result := False;
  if FPropertyTreeForm = nil then Exit;
  if Assigned(Debugger) then Debugger.Enabled := False;
  try
    if MethodsEditing > 0 then
    begin
      if PropertySettings.GeneralSet.NoticeTreeRefresh then
        MessageBox(Application.Handle,
          'Для применения новых параметров вывода'#13#10 +
          'методов будут закрыты все редакти-'#13#10 +
          'руемые методы', MSG_WARNING, MB_OK or MB_ICONINFORMATION or 
          MB_TASKMODAL);

      for I := tbtSpeedButtons.Items.Count - 1 downto 0 do
      begin
        if Assigned(Pointer(tbtSpeedButtons.Items[I].Tag)) then
        begin
          if TBaseFrame(tbtSpeedButtons.Items[I].Tag).CustomTreeItem.ItemType = tiMethod then
          begin
            if not TBaseFrame(tbtSpeedButtons.Items[I].Tag).Close then
            begin
              MessageBox(Application.Handle,
                'Обновление дерева было прервано т.к.'#13#10 +
                'не удалось закрыть все редактируемые'#13#10 +
                'методы', MSG_WARNING, MB_OK or MB_ICONINFORMATION or
                MB_TASKMODAL);
              Exit;
            end;
          end;
        end;
      end;
    end;
    TdfPropertyTree(FPropertyTreeForm).RefreshClasses;
    Result := True;
  finally
    if Assigned(Debugger) then Debugger.Enabled := True;
  end;
end;

function TfrmGedeminProperty.RefreshObjects: Boolean;
var
  I: Integer;
begin
  Result := False;
  if FPropertyTreeForm = nil then Exit;
  if Assigned(Debugger) then Debugger.Enabled := False;
  try
    if EventsEditing > 0 then
    begin
      if PropertySettings.GeneralSet.NoticeTreeRefresh then
        MessageBox(Application.Handle,
          'Для применения новых параметров вывода'#13#10 +
          'событий будут закрыты все редакти-'#13#10 +
          'руемые события', MSG_WARNING, MB_OK or MB_ICONINFORMATION  +
          MB_TASKMODAL);

      for I := tbtSpeedButtons.Items.Count - 1 downto 0 do
      begin
        if Assigned(Pointer(tbtSpeedButtons.Items[I].Tag)) then
        begin
          if TBaseFrame(tbtSpeedButtons.Items[I].Tag).CustomTreeItem.ItemType = tiEvent then
          begin
            if not TBaseFrame(tbtSpeedButtons.Items[I].Tag).Close then
            begin
              MessageBox(Application.Handle,
                'Обновление дерева было прервано т.к.'#13#10 +
                'не удалось закрыть все редактируемые'#13#10 +
                'события', MSG_WARNING, MB_OK or MB_ICONINFORMATION  +
                MB_TASKMODAL);
              Exit;
            end;
          end;
        end;
      end;
    end;
    TdfPropertyTree(FPropertyTreeForm).RefreshObjects;
    Result := True;
  finally
      if Assigned(Debugger) then Debugger.Enabled := True;
  end;
end;

function TfrmGedeminProperty.RefreshSf: Boolean;
var
  I: Integer;
begin
  Result := False;
  if FPropertyTreeForm = nil then Exit;
  if Assigned(Debugger) then Debugger.Enabled := False;
  try
    if SFEditing > 0 then
    begin
      if PropertySettings.GeneralSet.NoticeTreeRefresh then
        MessageBox(Application.Handle,
          'Для применения новых параметров вывода'#13#10 +
          'скрипт-функций будут закрыты все '#13#10 +
          'редактируемые скрипт-функции', MSG_WARNING, MB_OK or MB_ICONINFORMATION  +
          MB_TASKMODAL);

      for I := tbtSpeedButtons.Items.Count - 1 downto 0 do
      begin
        if Assigned(Pointer(tbtSpeedButtons.Items[I].Tag)) then
        begin
          if TBaseFrame(tbtSpeedButtons.Items[I].Tag).CustomTreeItem.ItemType = tiSF then
          begin
            if not TBaseFrame(tbtSpeedButtons.Items[I].Tag).Close then
            begin
              MessageBox(Application.Handle,
                'Обновление дерева было прервано т.к.'#13#10 +
                'не удалось закрыть все редактируемые'#13#10 +
                'скрипт-функции', MSG_WARNING, MB_OK or MB_ICONINFORMATION +
                MB_TASKMODAL);
              Exit;
            end;
          end;
        end;
      end;
    end;
    TdfPropertyTree(FPropertyTreeForm).RefreshSf;
    Result := True;
  finally
    if Assigned(Debugger) then Debugger.Enabled := True;
  end;
end;

function TfrmGedeminProperty.EventsEditing: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := tbtSpeedButtons.Items.Count - 1 downto 0 do
  begin
    if Assigned(Pointer(tbtSpeedButtons.Items[I].Tag)) and
     (TBaseFrame(tbtSpeedButtons.Items[I].Tag).CustomTreeItem.ItemType = tiEvent) then
     Inc(Result);
  end;
end;

function TfrmGedeminProperty.MethodsEditing: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := tbtSpeedButtons.Items.Count - 1 downto 0 do
  begin
    if Assigned(Pointer(tbtSpeedButtons.Items[I].Tag)) and
     (TBaseFrame(tbtSpeedButtons.Items[I].Tag).CustomTreeItem.ItemType = tiMethod) then
     Inc(Result);
  end;
end;

function TfrmGedeminProperty.SFEditing: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := tbtSpeedButtons.Items.Count - 1 downto 0 do
  begin
    if Assigned(Pointer(tbtSpeedButtons.Items[I].Tag)) and
     (TBaseFrame(tbtSpeedButtons.Items[I].Tag).CustomTreeItem.ItemType = tiSF) then
     Inc(Result);
  end;
end;

procedure TfrmGedeminProperty.OnDockWindowDestroy(Sender: TDockableForm);
var
  I: Integer;
begin
  if Sender = FPropertyTreeForm then
  begin
    TdfPropertyTree(FPropertyTreeForm).OnChangeNode := nil;
    FPropertyTreeForm := nil;
  end;

  if Sender = FMessagesForm then
  begin
    for I := 0 to ComponentCount - 1 do
    begin
      if Components[I] is TBaseFrame then
        TBaseFrame(Components[I]).MessageListView := nil;
    end;
    FMessagesForm := nil;
  end;

  if Sender = FCallStackForm then
    FCallStackForm := nil;

  if Sender = FwatchListForm then
    FWatchListForm := nil;

  if Sender = FRunTimeForm then
    FRunTimeForm := nil;

  if Sender = FBreakPoints then
    FBreakPoints := nil;  
end;

procedure TfrmGedeminProperty.FindAndEdit(Id: Integer; Line: Integer = - 1;
  Column:Integer = 0; Error: Boolean = False);
var
  I: Integer;
begin
  if Id = 0 then
    raise Exception.Create('Значение ключа функции должно быть больше 0');

  for i := 0 to ComponentCount - 1 do
  begin
    if (Components[I] is TBaseFrame) and
      TBaseFrame(Components[I]).IsFunction(Id) then
      TBaseFrame(Components[I]).SpeedButton.Click;
  end;

  if Assigned(FActiveFrame) and
    TBaseFrame(FActiveFrame).IsFunction(Id) then
    TBaseFrame(FActiveFrame).EditFunction(Id)
  else
    OpenFunction(Id);

  if FActiveFrame <> nil then
  begin
    TBaseFrame(FActiveFrame).UpdateBreakPoints;
    if Line > - 1 then
      if Error then
        TBaseFrame(FActiveFrame).GotoErrorLine(Line)
      else
        TBaseFrame(FActiveFrame).GotoLine(Line, Column);
  end;
end;

procedure TfrmGedeminProperty.actPrepareExecute(Sender: TObject);
begin
  if not Assigned(FActiveFrame) then
    Exit;

  TBaseFrame(FActiveFrame).Prepare;
end;

procedure TfrmGedeminProperty.actPrepareUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(FActiveFrame) and
    TBaseFrame(FActiveFrame).CanPrepare;
end;

procedure TfrmGedeminProperty.UpdateErrors;
begin
  if Assigned(FMessagesForm) then
    //Обновляем список ошибок
    TdfMessages(FMessagesForm).UpdateErrors;
end;

procedure TfrmGedeminProperty.ClearErrorResult;
begin
  if Assigned(FMessagesForm) then TdfMessages(FMessagesForm).ClearErrorResults;
end;

procedure TfrmGedeminProperty.ClearSearchResult;
begin
  TdfMessages(FMessagesForm).ClearSearch;
end;

procedure TfrmGedeminProperty.actFindInDBExecute(Sender: TObject);
begin
  FindInDB;
//  FindInDB.Execute;
end;

procedure TfrmGedeminProperty.actSQLEditorExecute(Sender: TObject);
begin
  if not TCreateableForm.FormAssigned(FSQLEditor) then
  begin
    FSQLEditor := TfrmSQLEditorSyn.Create(Application);
    FSQLEditor.FDatabase := gdcBaseManager.Database;
  end else
  begin
    if (Debugger <> nil) and (Debugger.IsPaused) then
      EnableWindow(FSQLEditor.Handle, True);
  end;
    FSQLEditor.ShowSQL('', nil, False);
end;

procedure TfrmGedeminProperty.actEditorSetExecute(Sender: TObject);
begin
  if Assigned(SynManager) then
    if SynManager.ExecuteDialog then
      UpdateSyncs;
end;

procedure TfrmGedeminProperty.UpdateSyncs;
var
  I: Integer;
  Index: Integer;
begin
  if SynManager <> nil then
  begin
    SynManager.GetHighlighterOptions(SynVBScriptSyn);
    for I := ComponentCount - 1 downto 0 do
      if Components[I] is TBaseFrame then
        TBaseFrame(Components[I]).UpDateSyncs;

    //Назначаем ShortCutы для экшинов
    with SynManager.GetKeyStroke do
    begin
      Index := FindCommand(ecFindInTree);
      if Index > - 1 then
        actFindInDB.ShortCut := Items[Index].ShortCut
      else
        actFindInDB.ShortCut := 0;

      Index := FindCommand(ecAddItem);
      if Index > - 1 then
        TdfPropertyTree(FPropertyTreeForm).actAddItem.ShortCut :=
          Items[Index].ShortCut
      else
        TdfPropertyTree(FPropertyTreeForm).actAddItem.ShortCut := 0;

      Index := FindCommand(ecDeleteItem);
      if Index > - 1 then
        TdfPropertyTree(FPropertyTreeForm).actAddItem.ShortCut :=
          Items[Index].ShortCut
      else
        TdfPropertyTree(FPropertyTreeForm).actAddItem.ShortCut := 0;

      Index := FindCommand(ecAddFolder);
      if Index > - 1 then
        TdfPropertyTree(FPropertyTreeForm).actAddItem.ShortCut :=
          Items[Index].ShortCut
      else
        TdfPropertyTree(FPropertyTreeForm).actAddItem.ShortCut := 0;

{      Index := FindCommand(ecCutTreeItem);
      if Index > - 1 then
        actCutTreeItem.ShortCut := Items[Index].ShortCut
      else
        actCutTreeItem.ShortCut := 0;

      Index := FindCommand(ecPasteTreeItem);
      if Index > - 1 then
        actPasteTreeItem.ShortCut := Items[Index].ShortCut
      else
        actPasteTreeItem.ShortCut := 0;

      Index := FindCommand(ecCopyTreeItem);
      if Index > - 1 then
        actCopyTreeItem.ShortCut := Items[Index].ShortCut
      else
        actCopyTreeItem.ShortCut := 0;

      Index := FindCommand(ecRefreshTree);
      if Index > - 1 then
        actRefresh.ShortCut := Items[Index].ShortCut
      else
        actRefresh.ShortCut := 0;

      Index := FindCommand(ecExecReport);
      if Index > - 1 then
        actExecReport.ShortCut := Items[Index].ShortCut
      else
        actExecReport.ShortCut := 0;

      Index := FindCommand(ecDisableMethod);
      if Index > - 1 then
        actDisableMethod.ShortCut := Items[Index].ShortCut
      else
        actDisableMethod.ShortCut := 0;}

      Index := FindCommand(ecCommit);
      if Index > - 1 then
        actPost.ShortCut := Items[Index].ShortCut
      else
        actPost.ShortCut := 0;

      Index := FindCommand(ecRollBack);
      if Index > - 1 then
        actCancel.ShortCut := Items[Index].ShortCut
      else
        actCancel.ShortCut := 0;

      Index := FindCommand(ecLoadFromFile);
      if Index > - 1 then
        actLoadFromFile.ShortCut := Items[Index].ShortCut
      else
        actLoadFromFile.ShortCut := 0;

      Index := FindCommand(ecSaveToFile);
      if Index > - 1 then
        actSaveToFile.ShortCut := Items[Index].ShortCut
      else
        actSaveToFile.ShortCut := 0;

      Index := FindCommand(ecSQLEditor);
      if Index > - 1 then
        actSQLEditor.ShortCut := Items[Index].ShortCut
      else
        actSQLEditor.ShortCut := 0;

      Index := FindCommand(ecEvaluate);
      if Index > - 1 then
        actEvaluate.ShortCut := Items[Index].ShortCut
      else
        actEvaluate.ShortCut := 0;

      Index := FindCommand(ecDebugRun);
      if Index > - 1 then
        actDebugRun.ShortCut := Items[Index].ShortCut
      else
        actDebugRun.ShortCut := 0;

      Index := FindCommand(ecDebugStepIn);
      if Index > - 1 then
        actDebugStepIn.ShortCut := Items[Index].ShortCut
      else
        actDebugStepIn.ShortCut := 0;

      Index := FindCommand(ecDebugStepOut);
      if Index > - 1 then
        actDebugStepOver.ShortCut := Items[Index].ShortCut
      else
        actDebugStepOver.ShortCut := 0;

      Index := FindCommand(ecDebugGotoCursor);
      if Index > - 1 then
        actDebugGotoCursor.ShortCut := Items[Index].ShortCut
      else
        actDebugGotoCursor.ShortCut := 0;

      Index := FindCommand(ecDebugPause);
      if Index > - 1 then
        actDebugPause.ShortCut := Items[Index].ShortCut
      else
        actDebugPause.ShortCut := 0;

      Index := FindCommand(ecProgramReset);
      if Index > - 1 then
        actProgramReset.ShortCut := Items[Index].ShortCut
      else
        actProgramReset.ShortCut := 0;

      Index := FindCommand(ecToggleBreakPoint);
      if Index > - 1 then
        actToggleBreakpoint.ShortCut := Items[Index].ShortCut
      else
        actToggleBreakpoint.ShortCut := 0;

      Index := FindCommand(ecPrepare);
      if Index > - 1 then
        actPrepare.ShortCut := Items[Index].ShortCut
      else
        actPrepare.ShortCut := 0;

      Index := FindCommand(ecAddWatch);
      if Index > - 1 then
        actAddWatch.ShortCut := Items[Index].ShortCut
      else
        actAddWatch.ShortCut := 0;
    end;
  end;
end;

procedure TfrmGedeminProperty.actToggleBreakpointExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).ToggleBreak;
end;

procedure TfrmGedeminProperty.actToggleBreakpointUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    TBaseFrame(FActiveFrame).CanToggleBreak; 
end;

procedure TfrmGedeminProperty.actLoadFromFileExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).LoadFromFile;
end;

procedure TfrmGedeminProperty.actLoadFromFileUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    (TBaseFrame(FActiveFrame).CanLoadFromFile);
end;

procedure TfrmGedeminProperty.actSaveToFileExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).SaveToFile;
end;

procedure TfrmGedeminProperty.actSaveToFileUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    (TBaseFrame(FActiveFrame).CanSaveToFile);
end;

procedure TfrmGedeminProperty.actFindUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    (TBaseFrame(FActiveFrame).CanFindReplace);
end;

procedure TfrmGedeminProperty.actFindExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).Find;
end;

procedure TfrmGedeminProperty.actGoToLineNumberUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    (TBaseFrame(FActiveFrame).CanGoToLineNumber);
end;

procedure TfrmGedeminProperty.actGoToLineNumberExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).GoToLineNumber;
end;

procedure TfrmGedeminProperty.actReplaceExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).Replace;
end;

procedure TfrmGedeminProperty.actCopyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    (TBaseFrame(FActiveFrame).CanCopy);
end;

procedure TfrmGedeminProperty.actCopyExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).Copy;
end;

procedure TfrmGedeminProperty.actCutExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).Cut;
end;

procedure TfrmGedeminProperty.actCutUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    (TBaseFrame(FActiveFrame).CanCut);
end;

procedure TfrmGedeminProperty.actPasteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    (TBaseFrame(FActiveFrame).CanPaste);
end;

procedure TfrmGedeminProperty.actPasteExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).Paste;
end;

procedure TfrmGedeminProperty.actCopySQLExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).CopySQL;
end;

procedure TfrmGedeminProperty.actCopySQLUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    (TBaseFrame(FActiveFrame).CanCopySQL);
end;

procedure TfrmGedeminProperty.actPasteSQLUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    (TBaseFrame(FActiveFrame).CanPasteSQL);
end;

procedure TfrmGedeminProperty.actPasteSQLExecute(Sender: TObject);
begin
  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).PasteSQL;
end;

procedure TfrmGedeminProperty.SetCanChangeCaption(const Value: Boolean);
begin
  FCanChangeCaption := Value;
end;

procedure TfrmGedeminProperty.SetCaption(State: TDebuggerState);
var
  EditorState, DebStateStr: String;

begin
  if CanChangeCaption then
    DebStateStr := GetDebugStateName(State)
  else
    DebStateStr := '';

  EditorState := '';
  if PropertySettings.DebugSet.UseDebugInfo then
  begin
    if Trim(DebStateStr) <> '' then
      EditorState := '[Режим отладки / ' + DebStateStr +  ']'
    else
      EditorState := '[Режим отладки]';
  end else
    if Trim(DebStateStr) <> '' then
      EditorState := '[' + DebStateStr +  ']';
  Caption := Format(cCaption, [EditorState]);
end;

function TfrmGedeminProperty.GetDebugStateName(
  State: TDebuggerState): String;
begin
  Result := '';
  if Assigned(Debugger) then
  begin
    with Debugger do
    begin
      if State in [dsRunning, dsStep, dsStepOver, dsReset] then
        Result := 'Running'
      else
      if State = dsPaused then
        Result := 'Paused';
    end;
  end;
end;

function TfrmGedeminProperty.GetModifiedCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to ComponentCount - 1 do
  begin
    if (Components[I] is TBaseFrame) and
      TBaseFrame(Components[I]).Modify then
    begin
      Inc(Result);
    end;
  end;
end;

procedure TfrmGedeminProperty.actGotoOnExecuteUpdate(Sender: TObject);
begin
  actGotoOnExecute.Enabled :=  PropertySettings.DebugSet.UseDebugInfo and
    (Debugger <> nil) and (Debugger.IsPaused);
end;

procedure TfrmGedeminProperty.actGotoOnExecuteExecute(Sender: TObject);
begin
  if (Debugger <> nil) and (Debugger.IsPaused) then
  begin
    FindAndEdit(Debugger.ExecuteScriptFunction{.FunctionKey},
      Debugger.CurrentLine);
  end;
end;

procedure TfrmGedeminProperty.OnChangeNode(Sender: TObject;
  Node: TTreeNode);
var
  I: Integer;
begin
  StatusBar.Panels[1].Text := TdfPropertyTree(FPropertyTreeForm).GetPath;
  if Assigned(Node) then
  begin
    if TCustomTreeItem(Node.Data).EditorFrame <> nil then
    begin
      FActivate := false;
      try
        SetActive(TCustomTreeItem(Node.Data).EditorFrame);
      finally
        FActivate := True;
      end;
    end else
    begin
      for I := 0 to ComponentCount - 1 do
        if Components[I] is TBaseFrame then
          TBaseFrame(Components[I]).Hide;
      if FActiveFrame <> nil then
        FActiveFrame := nil;
    end;
  end;
  if frmClassesInspector <> nil then
  begin
    I := FPropertyTreeForm.cbObjectList.Items.IndexOf(
      FPropertyTreeForm.cbObjectList.Text);
    if I > - 1 then
      frmClassesInspector.SetModuleClass(FPropertyTreeForm.cbObjectList.Text,
        TClass(FPropertyTreeForm.cbObjectList.Items.Objects[I]));
  end;
  UpdateFrameButtonState(FActiveFrame <> nil);
end;

procedure TfrmGedeminProperty.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  W: Integer;
  L: Integer;
  C: Integer;
  Str: string;
  Index: Integer;
begin
  if Panel <> StatusBar.Panels[1] then Exit;
  if Panel.Text <> '' then
    with StatusBar.Canvas do
    begin
      W := TextWidth(Panel.Text);
      if W > Rect.Right - Rect.Left then
      begin
        L := Length(Panel.Text);
        C := Round(W / L);
        Index := Round((W - (Rect.Right - Rect.Left))/C + 12);
        Str := System.Copy(Panel.Text, Index, L - Index + 1);
        Str := '...' + Str;
        TextOut(Rect.Left, Rect.Top, Str);
      end else
        TextOut(Rect.Left, Rect.Top, Panel.Text);
    end;
end;

procedure TfrmGedeminProperty.OnCaretPosChange(Sender: TObject; const X,
  Y: Integer);
begin
  if (X = - 1) or (Y = - 1) then
    StatusBar.Panels[0].Text := ''
  else
    StatusBar.Panels[0].Text := IntToStr(Y) +': ' + IntToStr(X);
end;

procedure TfrmGedeminProperty.actSaveAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ModifiedCount > 0;
end;

procedure TfrmGedeminProperty.actSaveAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
  begin
    if (Components[I] is TBaseFrame) and (TBaseFrame(Components[i]).Modify) then
    try
      TBaseFrame(Components[i]).Post;
    except
      SetActive(TBaseFrame(Components[i]));
    end;
  end;
end;

procedure TfrmGedeminProperty.actCloseUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := FActiveFrame <> nil;
  
end;

procedure TfrmGedeminProperty.actCloseExecute(Sender: TObject);
begin
  TBaseFrame(FActiveFrame).Close;
end;

procedure TfrmGedeminProperty.actCloseAllExecute(Sender: TObject);
var
  I: Integer;
  B: Boolean;
begin
  for I := ComponentCount - 1 downto 0 do
  begin
    if Components[I] is TBaseFrame then
    begin
      B := TBaseFrame(Components[I]).CloseQuery;
      if not B then
        Exit
      else
        Components[I].Free;
    end;
  end;
end;

procedure TfrmGedeminProperty.actBuildReportUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FActiveFrame <> nil) and
    TBaseFrame(FActiveFrame).CanBuildReport;
end;

procedure TfrmGedeminProperty.actBuildReportExecute(Sender: TObject);
begin
  TBaseFrame(FActiveFrame).BuildReport(Unassigned);
end;

procedure TfrmGedeminProperty.actShowCallStackUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(FCallStackForm);
end;

procedure TfrmGedeminProperty.actShowCallStackExecute(Sender: TObject);
begin
  if Assigned(FCallStackForm) then
  begin
    ReCalcDockBounds := False;
    try
      FCallStackForm.Show;
    finally
      ReCalcDockBounds := True;
    end;
  end;
end;

procedure TfrmGedeminProperty.ClearCallStack;
begin
  if FCallStackForm <> nil then
    TdfCallStack(FCallStackForm).ClearCallStackList;
end;

function TfrmGedeminProperty.NeedFullClassName(OldPS: TSettings): Boolean;
begin
  Result :=
    OldPS.GeneralSet.FullClassName <> PropertySettings.GeneralSet.FullClassName;
end;

function TfrmGedeminProperty.RefreshFullClassName(
  const FullClassName: Boolean): Boolean;
begin
  Result := False;
  TdfPropertyTree(FPropertyTreeForm).RefreshFullClassName(FullClassName);
end;

function TfrmGedeminProperty.GetEditingCont: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TBaseFrame then
      Inc(Result);
  end;
end;

procedure TfrmGedeminProperty.RefreshTree;
begin
  TdfPropertyTree(FPropertyTreeForm).actRefreshTree.Execute;
end;

procedure TfrmGedeminProperty.CancelAll;
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
  begin
    if (Components[I] is TBaseFrame) and (TBaseFrame(Components[i]).Modify) then
    try
      TBaseFrame(Components[i]).Cancel;
    except
      SetActive(TBaseFrame(Components[i]));
    end;
  end;
end;

procedure TfrmGedeminProperty.UpdateCallStack;
begin
  if Assigned(FCallStackForm) then
    //Обновляем список ошибок
    TdfCallStack(FCallStackForm).UpdateCallStackList;
end;

procedure TfrmGedeminProperty.FindInDB;
begin
  if dlgPropertyFind = nil then
    TdlgPropertyFind.Create(Self);

  if dlgPropertyFind <> nil then
  begin
    dlgPropertyFind.SearchInDB := True;
    if dlgPropertyFind.ShowModal = mrOk then
      DoFind;
  end;
end;

procedure TfrmGedeminProperty.DoFind;
var
  SearchText: String;
  P: Integer;
  SM: TSearchMessageItem;
  Add: Integer;
  SQL: TIBSQL;
  LI: TListItem;
  Strings: TStringList;
  Str: String;
  L: Integer;
  C: TCursor;
  DateCondition, ModuleCondition: string;
const
  ALPHA = ['A'..'Z', 'a'..'z', '_', '0'..'9'];

  function InvertedComma(Str: String): String;
  var
    I: Integer;
  begin
    Result := Str;
    I := 1;
    while I < Length(Result) do
    begin
      if Result[I] = '''' then
      begin
        Insert('''', Result, I);
        Inc(I);
      end;
      Inc(I);
    end;
  end;

  function AddLI(Caption: string; Node: TTreeNode; Line,
    Column: Integer): TListItem;
  begin
    Result := TdfMessages(FMessagesForm).lvMessages.Items.Add;
    Result.Caption := Caption;
    SM := TSearchMessageItem.Create;
    Result.Data := SM;
    SM.Message := Caption;
    SM.Node := Node;
    SM.Line := Line;
    SM.Column := Column;
  end;

  procedure FillFindList(FindList: TStrings; const ItemType: TItemType);
  var
    FI: Integer;

    procedure AddItem(Caption: string; FunctionKey: Integer; Module: string;
      Line, Pos: Integer);
    begin
      LI := AddLI(Caption, nil, Line, Pos);
      TSearchMessageItem(LI.Data).FunctionKey := FunctionKey;
      TSearchMessageItem(LI.Data).Module := Module;
      TSearchMessageItem(LI.Data).ItemType := ItemType;
    end;

  begin
    if SearchOptions.SearchText <> '' then
    begin
      FindList.Text := SQL.FieldByName(fnScript).AsString;
      for FI := 0 to FindList.Count - 1 do
      begin
        if SearchOptions.SearchInDb.Options.CaseSensitive then
          Str := FindList[FI]
        else
          Str := AnsiUpperCase(FindList[FI]);

        P := System.Pos(SearchText, Str);
        if P > 0 then
        begin
          if SearchOptions.SearchInDb.Options.WholeWord then
          begin
            if ((P <> 1) and (FindList[FI][P - 1] in Alpha)) or
              ((P + L - 1 <> Length(FindList[FI])) and (FindList[FI][P + L] in Alpha)) then
              Continue;
          end;
          Str := FindList[FI];
          System.Insert(#9, Str, P + Length(SearchText));
          System.Insert(#9, Str, P);
          AddItem(SQL.FieldByName(fnName).AsString + ': ' + Str,
            SQL.FieldByName(fnId).AsInteger, SQL.FieldByName(fnModule).AsString,
            FI + 1, P);
          Inc(Add);
        end;
      end;
    end else
    begin
      AddItem(SQL.FieldByName(fnName).AsString + ': изменен ' +
        SQL.FieldByName('editiondate').AsString,
        SQL.FieldByName(fnId).AsInteger, SQL.FieldByName(fnModule).AsString,
        1, 1);
      Inc(Add);
    end;
  end;

  procedure AddModuleDateCondition;
  begin
    if ModuleCondition > '' then
      SQL.SQL.Text := SQL.SQL.Text + ' where ' + ModuleCondition;
    if DateCondition > '' then begin
      if ModuleCondition > '' then
        SQL.SQL.Text := SQL.SQL.Text + ' and '
      else
        SQL.SQL.Text := SQL.SQL.Text + ' where ';
      SQL.SQL.Text := SQL.SQL.Text + DAteCondition;
    end;
  end;

  procedure OpenCloseSQL(IT: TItemType);
  begin
    SQL.ExecQuery;
    if not SQL.Eof then
      while not SQL.Eof do begin
        FillFindList(Strings, IT);
        SQL.Next;
      end;
    SQL.Close;
  end;

begin
  C := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    if SearchOptions.SearchInDb.ByID then
    begin
      actFindSfByIdExecute(nil);
      Exit;
    end;

    if FMessagesForm = nil then Exit;

    TdfMessages(FMessagesForm).lvMessages.Items.BeginUpdate;
    try
      ClearSearchResult;

      if SearchOptions.SearchInDb.Options.CaseSensitive then
        SearchText := SearchOptions.SearchText
      else
        SearchText := AnsiUpperCase(SearchOptions.SearchText);

      DateCondition := '';
      if SearchOptions.SearchInDb.Date then
      begin
        if SearchOptions.SearchInDb.BeginDate > 0 then
          DateCondition := ' f.editiondate >= ''' + DateTimeToStr(SearchOptions.SearchInDb.BeginDate) + '''';

       if SearchOptions.SearchInDb.EndDate > 0 then
       begin
         if DateCondition > '' then
           DateCondition := DateCondition + ' and ';
         DateCondition := DateCondition + ' f.editiondate <= ''' +
           DateTimeToStr(SearchOptions.SearchInDb.EndDate + 1) + '''';
       end;
      end;

      ModuleCondition := '';
      if SearchOptions.SearchInDb.CurrentObject then
      begin
        if not (Assigned(FPropertyTreeForm.ActivePage) and
            Assigned(FPropertyTreeForm.ActivePage.SFRootNode) and
            Assigned(FPropertyTreeForm.ActivePage.SFRootNode.Data)) then
          raise Exception.Create('Дерево объектов не найдено.');
        ModuleCondition := ' f.modulecode = ' +
          IntToStr(TSFTreeFolder(FPropertyTreeForm.ActivePage.SFRootNode.Data).OwnerId);
      end;

      Add := 0;
      L := Length(SearchText);
      SQL := TIBSQL.Create(nil);
      Strings := TStringList.Create;
      try
        try
          SQL.Transaction := gdcBaseManager.ReadTransaction;
          if wInText in SearchOptions.SearchInDb.Where then
          begin
            SQL.SQL.Text := 'SELECT f.id, f.name, f.script, f.module, f.editiondate FROM gd_function f ';
            AddModuleDateCondition;
            SQL.SQL.Text := SQL.SQL.Text + ' ORDER BY f.name';
            OpenCloseSQL(itOther);
          end;

          if wInCaption in SearchOptions.SearchInDb.Where then
          begin
            if nwMacro in SearchOptions.SearchInDb.InNameWhere then
            begin
              SQL.SQL.Text :=
                'SELECT ml.name as name, ml.name as script, ml.id as id, obj.id as module, ' +
                ' f.editiondate FROM evt_macroslist ml LEFT JOIN evt_object obj ON obj.macrosgroupkey =  ' +
                'ml.macrosgroupkey JOIN gd_function f ON f.id = ml.functionkey ';

              AddModuleDateCondition;

              SQL.SQL.Text := SQL.SQL.Text + ' ORDER BY ml.name';

              OpenCloseSQL(itMacro);
            end;

            if nwReport in SearchOptions.SearchInDb.InNameWhere then
            begin
              SQL.SQL.Text :=
                'SELECT rl.name as name, rl.name as script, rl.id, obj.id as module, ' +
                ' f.editiondate FROM gd_function f JOIN rp_reportlist rl ON f.id = rl.mainformulakey or ' +
                ' f.id = rl.paramformulakey or f.id = rl.eventformulakey LEFT JOIN ' +
                ' evt_object obj ON obj.reportgroupkey = rl.reportgroupkey';

              AddModuleDateCondition;

              SQL.SQL.Text := SQL.SQL.Text + ' ORDER BY rl.name';

              OpenCloseSQL(itReport);
            end;

            if nwEvent in SearchOptions.SearchInDb.InNameWhere then
            begin
              SQL.SQL.Text :=
                'SELECT oe.eventname as name, obj.name || oe.eventname as script, f.id as id, obj.id as module, ' +
                ' f.editiondate FROM evt_objectevent oe LEFT JOIN evt_object obj ON obj.id =  ' +
                'oe.objectkey JOIN gd_function f ON f.id = oe.functionkey ';

              AddModuleDateCondition;

              SQL.SQL.Text := SQL.SQL.Text + ' ORDER BY obj.name';

              OpenCloseSQL(itOther);
            end;

            if nwOther in SearchOptions.SearchInDb.InNameWhere then
            begin
              SQL.SQL.Text :=
                'SELECT f.id, f.name, f.name as script, f.module, f.editiondate FROM gd_function f ';

              AddModuleDateCondition;
              if (ModuleCondition <> '') or (DateCondition <> '') then
                SQL.SQL.Text:= SQL.SQL.Text + ' AND '
              else
                SQL.SQL.Text:= SQL.SQL.Text + ' WHERE ';

              SQL.SQL.Text:= SQL.SQL.Text + 
                ' UPPER(f.module) <> ' + QuotedStr('MACROS') + ' AND UPPER(f.module) <> ' + QuotedStr('EVENTS') +
                ' AND UPPER(f.module) NOT LIKE ' + QuotedStr('REPORT%');

              SQL.SQL.Text := SQL.SQL.Text + ' ORDER BY f.name';

              OpenCloseSQL(itOther);
            end;

          end;

        finally
          SQL.Free;
        end;
        if Add = 0 then AddLI(#9'Поиск не дал результатов'#9, nil, -1, -1);

        FMessagesForm.Show;
      finally
        Strings.Free;
      end;
    finally
      TdfMessages(FMessagesForm).lvMessages.Items.EndUpdate;
    end;
  finally
    Screen.Cursor := C;
  end;
end;

procedure TfrmGedeminProperty.EditMacro(const IDMacro: Integer);
var
  MI: TMacrosTreeItem;
  SQL: TIBSQL;
begin
  Restore;
  Show;
  //Делаем потытку найти макрос в дереве
  if not TdfPropertyTree(FPropertyTreeForm).OpenMacros(IDMacro) then
  begin
    //Если макрос в дереве не найден то ищем его в базе и
    //создаём фраме для редактирования макроса
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQl.SQL.Text :=
        'SELECT ml.*, obj.objectname as ownername, obj.id as ownerid FROM ' +
        'evt_macroslist ml LEFT JOIN evt_object obj ON ' +
        'obj.macrosgroupkey = ml.macrosgroupkey WHERE ml.id = ' + IntToStr(IDMacro);
      SQL.ExecQuery;
      if not SQl.Eof then
      begin
        MI := TMacrosTreeItem.Create;
        MI.Id := IDMacro;
        MI.Name := SQL.FieldByName(fnName).AsString;
        MI.MainOwnerName := SQL.FieldByName('ownername').AsString;
        MI.OwnerId := SQL.FieldByName('id').AsInteger;
        MI.Node := nil;
        MI.MacrosFolderId := 0;
        //т.к. MI не привязана к ноду дерева то для последующего её удаления
        //добавляем в список объектов
        FGhostObjects.Add(MI);
        //выводим Frame
        ShowFrame(MI);
      end else
        MessageBox(Application.Handle, PChar('Макрос с ИД = ' + IntToStr(IDMacro) +
          ' не найден.'), PChar('Ошибка открытия макроса.'), MB_OK or MB_ICONERROR);
    finally
      SQL.Free;
    end;
  end;
  //Выводим на передний план
  Show;
end;

procedure TfrmGedeminProperty.TBItem43Click(Sender: TObject);
{$IFDEF DEBUG}
var
  F: TPreparedScriptViewer;
{$ENDIF}
begin
  inherited;
  {$IFDEF DEBUG}
  F := TPreparedScriptViewer.Create(nil);
  try
    F.SynEdit1.Lines.Text := FPreparedScript;
    F.ShowModal;
  finally
    F.Free;
  end;
  {$ENDIF}
end;

procedure TfrmGedeminProperty.actShowRuntimeExecute(Sender: TObject);
begin
  if Assigned(FRunTimeForm) then
  begin
    ReCalcDockBounds := False;
    try
      FRunTimeForm.Show;
    finally
      ReCalcDockBounds := True;
    end;
  end;
end;

procedure TfrmGedeminProperty.actShowWatchListUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(FWatchListForm);
end;

procedure TfrmGedeminProperty.actShowWatchListExecute(Sender: TObject);
begin
  if Assigned(FWatchListForm) then
  begin
    ReCalcDockBounds := False;
    try
      FWatchListForm.Show;
    finally
      ReCalcDockBounds := True;
    end;
  end;
end;

procedure TfrmGedeminProperty.UpdateWatchList;
begin
  if FWatchListForm <> nil then
    TdfWatchList(FWatchListForm).UpdateWatchList;
end;

procedure TfrmGedeminProperty.ShowErrorList(const ErrorList: TObjectList);
begin
  FMessagesForm.SetErrorMessages(ErrorList);
  actShowMessagesExecute(Self);
end;

procedure TfrmGedeminProperty.ClearErrorList;
begin
  FMessagesForm.ClearErrorResults;
end;

procedure TfrmGedeminProperty.actAddWatchExecute(Sender: TObject);
begin
  if FWatchListForm <> nil then
    TdfWatchList(FWatchListForm).actAddWatch.Execute;
end;

procedure TfrmGedeminProperty.actShowClassesInspExecute(Sender: TObject);
begin
  if frmClassesInspector = nil then
  begin
    TfrmClassesInspector.Create(Self);
    frmClassesInspector.DockForm := Self;
    frmClassesInspector.OnInsertCurrentText := InsertCurrentText;
  end;
  if frmClassesInspector.Visible then
    frmClassesInspector.BringToFront
  else
    frmClassesInspector.Show;
//  SetInsCurrentClass;
end;

procedure TfrmGedeminProperty.InsertCurrentText(const InsertText: String);
{var
  Str: String;}
begin
  {$IFDEF GEDEMIN}
  if not (Assigned(ActiveFrame) and ActiveFrame.InheritsFrom(TFunctionFrame)) then
    Exit;

  TFunctionFrame(ActiveFrame).gsFunctionSynEdit.InsertText(InsertText);
  {$ENDIF}
end;

procedure TfrmGedeminProperty.OnDebuggerStateChanged(Sender: TObject);
begin
  if FCanChangeCaption then
  begin
    if FWatchListForm <> nil then
      TdfWatchList(FWatchListForm).UpdateWatchList;
    if FCallStackForm <> nil then
      TdfCallStack(FCallStackForm).UpdateCallStackList;
    UpdateBreakPoints;  
  end;    
end;

procedure TfrmGedeminProperty.OnShowHint(
  var HintStr: String; var CanShow: Boolean; var HintInfo: THintInfo);
begin
  if Assigned(FOldOnShowHint) then
    FOldOnShowHint(HintStr, CanShow, HintInfo);

  if FActiveFrame <> nil then
    TBaseFrame(FActiveFrame).OnShowHint(HintStr, CanShow, HintInfo);
end;

procedure TfrmGedeminProperty.SelectNextFrame(SelectNext: Boolean);
var
  SB: TTBCustomItem;
  I: Integer;
begin
  if FActiveFrame <> nil then
  begin
    SB := TBaseFrame(FActiveFrame).SpeedButton;
    I := tbtSpeedButtons.Items.IndexOf(SB);
    if I > -1 then
    begin
      if SelectNext then
      begin
        Inc(I, 2);
        if I >= tbtSpeedButtons.Items.Count then
        begin
          if tbtSpeedButtons.Items.Count > 0 then
            I := 0
          else
            I := -1;
        end;
      end else
      begin
        Dec(I, 2);
        if I < 0 then
        begin
          if tbtSpeedButtons.Items.Count > 0 then
            I := tbtSpeedButtons.Items.Count - 2
          else
            I := -1;
        end;
      end;
    end;
  end else
  begin
    if SelectNext then
      if tbtSpeedButtons.Items.Count > 0 then
        I := 0
      else
        I := -1
    else
      if tbtSpeedButtons.Items.Count > 0 then
        I := tbtSpeedButtons.Items.Count - 2
      else
        I := -1;
  end;
  if (I > - 1) and (I < tbtSpeedButtons.Items.Count) then
    tbtSpeedButtons.Items[I].Click;
end;

procedure TfrmGedeminProperty.actGotoNextExecute(Sender: TObject);
begin
  SelectNextFrame(True);
end;

procedure TfrmGedeminProperty.actGotoPrevExecute(Sender: TObject);
begin
  SelectNextFrame(False);
end;

procedure TfrmGedeminProperty.actShowBreakPointsExecute(Sender: TObject);
begin
  if Assigned(FBreakPoints) then
  begin
    ReCalcDockBounds := False;
    try
      FBreakPoints.Show;
    finally
      ReCalcDockBounds := True;
    end;
  end;
end;

procedure TfrmGedeminProperty.UpdateBreakPoints;
begin
  if FBreakPoints <> nil then
  begin
    FBreakPoints.LoadBreakPoints;
  end;
end;

procedure TfrmGedeminProperty.actCloseAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := EditingCont > 0;
end;


{procedure TfrmGedeminProperty.WMSysCommand(var Message: TWMSysCommand);
begin
  with Message do
    if ((CmdType and $FFF0 = SC_MINIMIZE) or (CmdType and $FFF0 = SC_RESTORE)) and
      not (csDesigning in ComponentState) then
      DefaultHandler(Message)
    else
      inherited;
end;}

procedure TfrmGedeminProperty.actCompaleProjectExecute(Sender: TObject);
begin
  ClearErrorList;
  VBCompiler.CompileVBProject;
  ShowErrorList(VBCompiler.HintList);
  ShowErrorList(VBCompiler.ErrorList);
end;

procedure TfrmGedeminProperty.SetEnabled(Value: Boolean);
begin
  inherited;
  if frmClassesInspector <> nil then
    frmClassesInspector.Enabled := Value;
end;

procedure TfrmGedeminProperty.FormActivate(Sender: TObject);
begin
  Application.Restore;
  inherited;
  if Debugger <> nil then SetCaption(Debugger.CurrentState);
end;

procedure TfrmGedeminProperty.Restore;
begin
  Application.ProcessMessages;
  if not Application.Terminated then
    Application.Restore;
end;

procedure TfrmGedeminProperty.SetNeedCloseAfterEdit(const Value: Boolean);
begin
  FNeedCloseAfterEdit := Value;
end;

procedure TfrmGedeminProperty.WMShowWindow(var Message: TWMShowWindow);
var
  I: Integer;
begin
  inherited;
  if frmClassesInspector <> nil then
    with FPropertyTreeForm.cbObjectList do
    begin
      I := Items.IndexOf(Text);
      if I = -1 then
        I := Items.IndexOf('APPLICATION');
      if I > -1 then
        frmClassesInspector.SetModuleClass(Text,
          TClass(Items.Objects[I]));
    end;
end;

procedure TfrmGedeminProperty.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TfrmGedeminProperty.SetInsCurrentClass;
var
  I: Integer;
begin
  if (FPropertyTreeForm <> nil) and Visible then
    with FPropertyTreeForm.cbObjectList do
    begin
      I := Items.IndexOf(Text);
      if I = -1 then
        I := Items.IndexOf('APPLICATION');
      if I > -1 then
        frmClassesInspector.SetModuleClass(Text,
          TClass(Items.Objects[I]));
    end;
end;

procedure TfrmGedeminProperty.PrepareForModal;
begin
  ReleaseCapture;
end;

procedure TfrmGedeminProperty.actTypeInformationExecute(Sender: TObject);
begin
  if Assigned(FActiveFrame) then
    TBaseFrame(FActiveFrame).ShowTypeInfo;
end;

procedure TfrmGedeminProperty.EditReport(const IDReport: Integer);
var
  RI: TReportTreeItem;
  SQL: TIBSQL;
begin
  Restore;
  //Делаем потытку найти отчёт в дереве
  Show;
  if not TdfPropertyTree(FPropertyTreeForm).OpenReport(IDReport) then
  begin
    //Если отчёт в дереве не найден то ищем его в базе и
    //создаём фраме тля редактирования отчёта
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQl.SQL.Text := 'SELECT * FROM rp_reportlist WHERE id = ' + IntToStr(IDReport);
      SQL.ExecQuery;
      if not SQl.Eof then
      begin
        RI := TReportTreeItem.Create;
        RI.Id := IDReport;
        RI.Name := SQL.FieldByName(fnName).AsString;
        RI.MainOwnerName := 'Неизвестный';
        RI.Node := nil;
        RI.ReportFolderId := sql.FieldByName('reportgroupkey').AsInteger;
        //т.к. Ri не привязана к ноду дерева то для последующего её удаления
        //добавляем в список объектов
        FGhostObjects.Add(Ri);
        //выводим Frame
        ShowFrame(RI);
      end;
    finally
      SQL.Free;
    end;
  end;
  //Выводим на передний план
  Show;
end;

constructor TfrmGedeminProperty.Create(AnOwner: TComponent);
var
  I: TTBFrameButtonItem;
begin
  Inc(_Count);
  if frmGedeminProperty <> nil then
    raise Exception.Create('Можно создать только один экземпляр редактора скрипт-объектов');

  inherited;

  I := TTBFrameButtonItem.Create(Self);
  TTBCustomToolbarAccess(tbtMenu).FMDIButtonsItem := I;
  I.OnItemClick := OnFrameButtonClick;
  UpdateFrameButtonState(False);
  tbtMenu.View.RecreateAllViewers;
  FOpenedSF := TStringList.Create;
  FDeskTopSF := TStringList.Create;
  FCodeTemplates:= TStringList.Create;

  frmGedeminProperty := Self;
end;

destructor TfrmGedeminProperty.Destroy;
begin
  FOpenedSF.Free;
  FDeskTopSF.Free;
  FCodeTemplates.Free;
  if tbtMenu <> nil then
    TTBCustomToolbarAccess(tbtMenu).FMDIButtonsItem := nil;

  Dec(_Count);
  if _Count <=0 then
    frmGedeminProperty := nil;
  inherited;
end;

procedure TfrmGedeminProperty.actCompaleProjectUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(Debugger) and (Debugger.IsStoped or
    Debugger.IsReseted);
end;

procedure TfrmGedeminProperty.OnFrameButtonClick(Sender: TObject);
begin
  if FActiveFrame <> nil then
  begin
    TBaseFrame(FActiveFrame).Close;
  end;
  UpdateFrameButtonState(FActiveFrame <> nil);
end;

procedure TfrmGedeminProperty.UpdateFrameButtonState(V: Boolean);
var
  I: TTBFrameButtonItem;
begin
  I := TTBFrameButtonItem(TTBCustomToolbarAccess(tbtMenu).FMDIButtonsItem);

  if I.CloseItem.Visible <> V then
  begin
    I.CloseItem.Visible := V;
    TTBCustomToolbarAccess(tbtMenu).View.InvalidatePositions;
//    TTBCustomToolbarAccess(tbtMenu).TryValidatePositions;
  end;
end;

procedure TfrmGedeminProperty.actVBScripthelpExecute(Sender: TObject);
begin
  ShowHelp('VBS55.CHM');
end;

procedure TfrmGedeminProperty.actFastReportHelpExecute(Sender: TObject);
begin
  ShowHelp('FR24RUS.CHM');
end;

procedure TfrmGedeminProperty.actPGHelpExecute(Sender: TObject);
begin
  ShowHelp('GEDYMINPG.CHM');
end;

procedure TfrmGedeminProperty.TBSubmenuItem7Popup(Sender: TTBCustomItem;
  FromLink: Boolean);
var
  I: Integer;
  function AddItem(Caption: String; Id: Integer): TTBItem;
  begin
    Result := TTbItem.Create(Sender);
    Result.Caption := Caption;
    Sender.Add(Result);
    Result.Tag := Id;
    if Id = -1 then
      Result.Enabled := False
    else
    begin
      Result.OnClick := OnReopenClick;
      Result.Enabled := True;
    end;
  end;
var
  CN: string;
  id: Integer;
  C: CBaseFrame;
  Name: string;
  Count: Integer;
begin
  Sender.Clear;
  Count := 0;
  Id := -1;
  if FOpenedSF.Count > 0 then
  begin
    for I := 0 to FOpenedSF.Count - 1 do
    begin
      try
        Id := StrToInt(FOpenedSF.Names[I]);
      except
        Continue;
      end;
      CN := FOpenedSF.Values[FOpenedSF.Names[I]];

      C := CBaseFrame(GetClass(CN));
      if (C <> nil) and C.InheritsFrom(TBaseFrame) then
      begin
        Name := C.GetNameById(Id);
        if Name > '' then
        begin
          AddItem(Name, I);
          Inc(Count);
        end;
      end;
    end;
  end;
  if Count = 0 then
  begin
    AddItem('Пусто', -1);
  end;
end;

procedure TfrmGedeminProperty.OnReopenClick(Sender: TObject);
begin
  ReopenSf(FOpenedSF[TTBItem(Sender).Tag]);
end;

procedure TfrmGedeminProperty.ReopenSF(S: string);
var
  CN: string;
  id: Integer;
  C: CBaseFrame;
  Strings: TStringList;
  SQL: TIBSQL;
begin
  Strings := TStringList.Create;
  try
    Strings.Text := S;
    if Strings.Count = 1 then
    begin
      try
        Id := StrToInt(Strings.Names[0]);
        if Id = 0 then exit;
      except
        Exit;
      end;
      CN := FOpenedSF.Values[Strings.Names[0]];

      C := CBaseFrame(GetClass(CN));
      if (C <> nil) and C.InheritsFrom(TBaseFrame) then
      begin
        id := C.GetFunctionIdEx(Id);
        if id > 0 then
        begin
          SQL := TIBSQL.Create(nil);
          try
            SQL.Transaction := gdcBaseManager.ReadTransaction;
            SQL.SQL.text := 'select id from gd_function where id = :id';
            SQL.ParamByName('id').AsInteger := Id;
            SQL.ExecQuery;
            if SQL.recordCount > 0 then
              EditScriptFunction(id);
          finally
            SQl.Free;
          end;
        end;
      end;
    end;
  finally
    Strings.Free;
  end
end;

procedure TfrmGedeminProperty.BeforeDestruction;
var
 I: Integer;
begin
  Fdestroying := True;
  for I := ComponentCount - 1 downto 0 do
  begin
    if Components[I] is TBaseFrame then
      TBaseFrame(Components[I]).Free;
  end;

  inherited;
end;

procedure TfrmGedeminProperty.actCodeTemplatesExecute(Sender: TObject);
begin
  with Tprp_dlgCodeTemplates.Create(self) do
  try
    if ShowModal = mrOk then
      UpdateCodeTemlates;
  finally
    Free;
  end;
end;

procedure TfrmGedeminProperty.UpdateCodeTemlates;
var
  SF: TgsStorageFolder;
  i: integer;
begin
  FCodeTemplates.Clear;
  if Assigned(UserStorage) then
  begin
    SF:= UserStorage.OpenFolder('Options\CodeTemplates', True, False);
    try
      for i:= 0 to SF.FoldersCount - 1 do begin
        FCodeTemplates.Add(AnsiLowerCase(SF.Folders[i].Name) + '=' + SF.Folders[i].ValueByName('Value').AsString);
      end;
    finally
      UserStorage.CloseFolder(SF);
    end;
  end;
end;

function TfrmGedeminProperty.GetCodeTemplate(AName: string): string;
begin
  Result:= AName;
  if FCodeTemplates.IndexOfName(AnsiLowerCase(AName)) > -1 then
    Result:= FCodeTemplates.Values[AnsiLowerCase(AName)];
end;

procedure TfrmGedeminProperty.actFindDelEventsSFExecute(Sender: TObject);
var
  frm: TfrmLooseFunctions;
begin
  frm:= TfrmLooseFunctions.Create(self);
  try
    frm.ShowModal;
  finally
    frm.Free;
  end;
end;

initialization
  frmGedeminProperty := nil;
  RegisterClass(TfrmGedeminProperty);

finalization
  UnRegisterClass(TfrmGedeminProperty);

end.
