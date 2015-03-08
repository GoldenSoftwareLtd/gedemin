
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

  Module

    prp_FunctionFrame_Unit.pas

  Abstract

    Gedemin project. TFunctionFrame_Unit.
    Фрайм для редактирования функции.

  Author

    Karpuk Alexander

  Revisions history

    1.00    17.10.02    tiptop        Initial version.

--}

unit prp_FunctionFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  prp_BaseFrame_unit, ComCtrls, StdCtrls, DBCtrls, Mask, Db, ExtCtrls,
  SynEdit, SynDBEdit, gsFunctionSyncEdit, IBCustomDataSet, gdcBase,
  gdcFunction, Menus, prp_TreeItems, prm_ParamFunctions_unit, contnrs,
  gdcTree, gdcDelphiObject, ActnList, SynHighlighterVBScript,
  SynEditHighlighter, SynHighlighterJScript, SynCompletionProposal,
  TB2ToolWindow, FR_Dock, TB2Item, TB2Dock, TB2Toolbar, obj_i_Debugger,
  VBParser, ImgList, SynEditKeyCmds, prp_dlgEvaluate_unit, SuperPageControl,
  prpDBEdit, prpDBComboBox, dmImages_unit, prp_dlgPropertyFind,
  prp_dlgPropertyReplace, prp_dlgPropertyReplacePromt, SynEditExport,
  SynExportRTF, gdcCustomFunction, StdActns, AppEvnts, SynEditPlugins,
  prp_frmTypeInfo, gdcBaseInterface, gd_strings;

{ TGutterMarkDrawPlugin }

type
  TDebugSupportPlugin = class(TSynEditPlugin)
  private
    FDebugLines: TDebugLines;
    FFunctionKey: Integer;
    procedure SetDebugLines(const Value: TDebugLines);
    procedure SetFunctionKey(const Value: Integer);
  protected
    procedure AfterPaint(ACanvas: TCanvas; AClip: TRect;
      FirstLine, LastLine: integer); override;
    procedure LinesInserted(FirstLine, Count: integer); override;
    procedure LinesDeleted(FirstLine, Count: integer); override;
    function IsExecuteScript: Boolean;
  public
    property DebugLines: TDebugLines read FDebugLines write SetDebugLines;
    property FunctionKey: Integer read FFunctionKey write SetFunctionKey;
  end;

  TErrorListSuppurtPlugin = class(TSynEditPlugin)
  private
    FErrorListView: TListView;
    FFunctionKey: Integer;
    procedure SetErrorListView(const Value: TListView);
    procedure SetFunctionKey(const Value: Integer);
  protected
    procedure AfterPaint(ACanvas: TCanvas; AClip: TRect;
      FirstLine, LastLine: integer); override;
    procedure LinesInserted(FirstLine, Count: integer); override;
    procedure LinesDeleted(FirstLine, Count: integer); override;
  public
    property ErrorListView: TListView read FErrorListView write SetErrorListView;
    property FunctionKey: Integer read FFunctionKey write SetFunctionKey;
  end;

const
  prp_VBComment = '''';

type
  TCreckPopupMenu = class(TPopupMenu)
  end;

type
  TprpComment = (prpComment, prpUnComment);

type
//Обновить: зависимые, зависит от, все.
  TprpDepend = (sdDependent, sdDependedFrom, sdAll);

type
  TFunctionFrame = class(TBaseFrame)
    tsScript: TSuperTabSheet;
    tsParams: TSuperTabSheet;
    gsFunctionSynEdit: TgsFunctionSynEdit;
    gdcFunction: TgdcFunction;
    ScrollBox: TScrollBox;
    Label19: TLabel;
    pnlCaption: TPanel;
    gdcDelphiObject: TgdcDelphiObject;
    dsDelpthiObject: TDataSource;
    SynCompletionProposal: TSynCompletionProposal;
    ReplaceDialog: TReplaceDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    actReplace: TAction;
    miFind: TMenuItem;
    miReplace: TMenuItem;
    miS3: TMenuItem;
    actRun: TAction;
    miRun: TMenuItem;
    actPrepare: TAction;
    actCopy: TAction;
    actCut: TAction;
    miPrepare: TMenuItem;
    miS4: TMenuItem;
    miCopy: TMenuItem;
    miCut: TMenuItem;
    actPaste: TAction;
    miPaste: TMenuItem;
    miS6: TMenuItem;
    actCopySQL: TAction;
    actPasteSQL: TAction;
    miCopySQL: TMenuItem;
    miPasteSQL: TMenuItem;
    actComment: TAction;
    miS7: TMenuItem;
    miComment: TMenuItem;
    actUnComment: TAction;
    miUnComment: TMenuItem;
    SynExporterRTF1: TSynExporterRTF;
    miS5: TMenuItem;
    actCopyToRTF: TAction;
    miCopyToRTF: TMenuItem;
    actFind: TAction;
    miS2: TMenuItem;
    miSeparator: TMenuItem;
    actEnableBreakPoint: TAction;
    miEnableBreakPoint: TMenuItem;
    actPropertyBreakPoint: TAction;
    miPropertyBreakPoint: TMenuItem;
    lbOwner: TLabel;
    lbLanguage: TLabel;
    dbcbLang: TDBComboBox;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    dbtOwner: TDBEdit;
    N1: TMenuItem;
    N2: TMenuItem;
    TypeInfo1: TMenuItem;
    tsDependencies: TSuperTabSheet;
    pnlDependent: TPanel;
    pnlDependedFrom: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Panel4: TPanel;
    lbDependent: TListBox;
    lbDependedFrom: TListBox;
    pmDependent: TPopupMenu;
    pmDependedFrom: TPopupMenu;
    actRefreshDependent: TAction;
    actRefreshDependedFrom: TAction;
    pmiRefreshDependent: TMenuItem;
    pmiRefreshDependedFrom: TMenuItem;
    actTypeInfo: TAction;
    actWizard: TAction;
    tbiWizard: TTBItem;
    dbeLocalName: TDBEdit;
    lLocalName: TLabel;
    lblRUIDFunction: TLabel;
    pnlRUIDFunction: TPanel;
    btnCopyRUIDFunction: TButton;
    edtRUIDFunction: TEdit;
    tsHistory: TSuperTabSheet;
    actExternalEditor: TAction;
    nExternalEditor: TMenuItem;
    nExternalEditorBreak: TMenuItem;
    procedure PageControlChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure PageControlChange(Sender: TObject);
    procedure gsFunctionSynEditChange(Sender: TObject);
    procedure gdcFunctionAfterPost(DataSet: TDataSet);
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var AString: String; x, y: Integer;
      var CanExecute: Boolean);
    procedure gsFunctionSynEditSpecialLineColors(Sender: TObject;
      Line: Integer; var Special: Boolean; var FG, BG: TColor);
    procedure gsFunctionSynEditGutterClick(Sender: TObject; X, Y,
      Line: Integer; mark: TSynEditMark);
    procedure gsFunctionSynEditCommandProcessed(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
    procedure gsFunctionSynEditPlaceBookmark(Sender: TObject;
      var Mark: TSynEditMark);
    procedure gsFunctionSynEditProcessCommand(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
    procedure gdcFunctionAfterEdit(DataSet: TDataSet);
    procedure gsFunctionSynEditPaintGutter(AClip: TRect; FirstLine,
      LastLine: Integer);
    procedure dbeNameChange(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure ReplaceDialogReplace(Sender: TObject);
    procedure gsFunctionSynEditProcessUserCommand(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
    procedure actRunExecute(Sender: TObject);
    procedure actRunUpdate(Sender: TObject);
    procedure actPrepareUpdate(Sender: TObject);
    procedure actPrepareExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCutUpdate(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actPasteUpdate(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actCopySQLUpdate(Sender: TObject);
    procedure actCopySQLExecute(Sender: TObject);
    procedure actPasteSQLUpdate(Sender: TObject);
    procedure actPasteSQLExecute(Sender: TObject);
    procedure gdcFunctionAfterInsert(DataSet: TDataSet);
    procedure gsFunctionSynEditReplaceText(Sender: TObject; const ASearch,
      AReplace: String; Line, Column: Integer;
      var Action: TSynReplaceAction);
    procedure actCommentExecute(Sender: TObject);
    procedure actUnCommentExecute(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure dbeNameExit(Sender: TObject);
    procedure dbeNameKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dbeNameDblClick(Sender: TObject);
    procedure actCopyToRTFExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure gdcFunctionAfterDelete(DataSet: TDataSet);
    procedure actEnableBreakPointExecute(Sender: TObject);
    procedure dbeNameUpdateRecord(Sender: TObject);
    procedure actEnableBreakPointUpdate(Sender: TObject);
    procedure actPropertyBreakPointExecute(Sender: TObject);
    procedure actPropertyBreakPointUpdate(Sender: TObject);
    procedure lbDependentDblClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure lbDependedFromDblClick(Sender: TObject);
    procedure gdcFunctionAfterOpen(DataSet: TDataSet);
    procedure actRefreshDependentExecute(Sender: TObject);
    procedure actRefreshDependedFromExecute(Sender: TObject);
    procedure actTypeInfoExecute(Sender: TObject);
    procedure actWizardUpdate(Sender: TObject);
    procedure actWizardExecute(Sender: TObject);
    procedure btnCopyRUIDFunctionClick(Sender: TObject);
    procedure pMainResize(Sender: TObject);
    procedure gdcDelphiObjectAfterScroll(DataSet: TDataSet);
    procedure actExternalEditorExecute(Sender: TObject);
  private
    FFunctionParams: TgsParamList;
    FParamLines: TObjectList;
    FCurrentFunctionName: String;
    FBreakPoint: TBreakPoint;
    FOldName: string;
    HistoryFrame: TFrame;
    FOldFunctionKey: Integer;
    //FHint: THintWindow;

    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;

    // Комментирует и откомметирует выделенный блок
    procedure ChangeCommentBlock(const AComment: TprpComment);
    procedure OnBeforePaint(Sender: TObject);
    procedure OnErrorLineChanged(Sender: TObject);
    procedure SetCurrentFunctionName(const Value: String);
    procedure CopyToRTFClipboart;
    procedure UpdateBreakPointsWindow;

  protected
    FDebugPlugin: TDebugSupportPlugin;
    FErrorListSuppurtPlugin: TErrorListSuppurtPlugin;
    FVBParser: TVBParser;
    FCurrentLine: Integer;
    FDebugLines: TDebugLines;
    FFinding: Boolean;
    FFindNext: Boolean;

    function GetCaretXY: TPoint; override;
    procedure SetCaretXY(const Value: TPoint); override;
    function GetMasterObject: TgdcBase;override;
    // Обработчик события SynhEdit.OnParamChange
    procedure edValueChange(Sender: TObject);
    procedure ParamChange(Sender: TObject);
    procedure DoOnCreate; override;
    procedure DoOnDestroy; override;
    procedure DoBeforeDelete; override;
    function GetModule: string; virtual; abstract;

    function GetStatament(var Str: String; Pos: Integer): String;
    function GetCompliteStatament(var Str: String; Pos: Integer;
      out BeginPos, EndPos: Integer): String;
    function GetFunctionID: Integer; override;
    function CheckDestroing: Boolean;
    procedure ParserInit; virtual;
    procedure SetObjectId(const Value: Integer); override;
    // Проверка имени функции
    function CheckFunctionName(AnFunctionName: string;
      AnScriptText: TStrings): Boolean;
    //Возвращает Тру если имя функции не сответствует имени в скрипте
    procedure WarningFunctionName(const AnFunctionName: string;
      AnScriptText: TStrings); virtual;
    //Производить обновление списка параметров
    procedure UpDataFunctionParams(FunctionParams: TgsParamList);
    procedure SaveFunctionParams;
    procedure ToggleBreakpoint(Line: Integer);

    procedure LoadBreakPoints;
    procedure UpdateNameColor; virtual;
    function ScriptIsActive: Boolean;
    procedure SetMessageListView(const Value: TListView); override;
    procedure GotoToInclude;
    procedure DoFind;
    procedure DoReplace;
    procedure SetParent(AParent: TWinControl); override;
    procedure SetBaseScriptText(const NewFunctionName: String); virtual;
    function  NewNameUpdate: Boolean; override;
    procedure SetHighlighter; virtual;
//    procedure UpdateEdidor;

//Заполянет списки зависимостей
    procedure SetDependencies(Flag: TprpDepend);

    class function GetNameFromDb(Id: Integer): string; virtual;
    class function GetTypeName: string; virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Post; override;
    procedure Setup(const FunctionName: String = ''); override;
    procedure Cancel; override;
    function Run(const SFType: sfTypes): Variant; override;
    procedure Prepare; override;
    procedure EditFunction(ID: Integer); override;
    procedure InvalidateFrame; override;
    procedure Evaluate; override;
    procedure ShowTypeInfo; override;

    function IsExecuteScript: Boolean; override;
    //Переводит курсор на строку и установливает фокус на SynEdit
    procedure GotoLineNumber; override;
    procedure GoToLine(Line, Column: Integer); override;
    procedure GoToXY(X, Y: Integer);
    procedure GotoErrorLine(ErrorLine: Integer); override;
    function GetSelectedText: string; override;
    function GetCurrentWord: string; override;
    procedure UpDateSyncs; override;
    procedure UpdateSelectedColor;
    procedure ToggleBreak; override;
    function CanToggleBreak: Boolean; override;
    //Загрузка из файла
    procedure LoadFromFile; override;
    function CanLoadFromFile: Boolean; override;
    //Сохраниение в файл
    procedure SaveToFile; override;
    function CanSaveToFile: Boolean; override;
    //Сохраниение в файл
    procedure Find; override;
    procedure Replace; override;
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
    procedure InsertText(const AText: String);
    procedure OnShowHint(var HintStr: String;
      var CanShow: Boolean; var HintInfo: THintInfo); override;
    procedure UpdateBreakPoints; override;
    procedure InsertCodeTemplate;

    class function GetNameById(Id: Integer): string; override;
    class function GetFunctionIdEx(Id: Integer): integer; override;

    property FunctionParams: TgsParamList read FFunctionParams;
    property CurrentFunctionName: String read FCurrentFunctionName write SetCurrentFunctionName;
  end;

var
  FunctionFrame: TFunctionFrame;

implementation

uses
  gdcConstants, rp_frmParamLineSE_unit, scr_i_FunctionList,
  rp_BaseReport_unit, gd_i_ScriptFactory, syn_ManagerInterface_unit,
  prp_Messages, prp_i_VBProposal, prp_MessageConst, gd_ScriptFactory,
  prp_frmGedeminProperty_Unit, IBSQL, IBDatabase, mtd_i_Base, Clipbrd,
  gd_createable_form, jclStrings, CodeExplorerParser, rp_report_const,
  prp_dfPropertyTree_Unit, gd_security_operationconst, prp_PropertySettings,
  prp_dlgInputLineNumber_unit, prp_dlgBreakPointProperty_unit, wiz_Main_Unit,
  gdcClasses_interface, prp_FunctionHistoryFrame_unit, gd_ExternalEditor
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}
type
  TCrackDBSynEdit = class(TDBSynEdit);

function _IsExecutedScript(FunctionKey: Integer): Boolean;
begin
  Result := (Debugger <> nil) and
    ((Debugger.ExecuteScriptFunction = FunctionKey) or
    (Debugger.LastScriptFunction = FunctionKey)) and not Debugger.IsStoped;
end;
{ TFunctionFrame }

function TFunctionFrame.GetMasterObject: TgdcBase;
begin
  Result := gdcFunction;
end;

procedure TFunctionFrame.Setup(const FunctionName: String = '');
begin
  inherited;

  if (gdcFunction.State = dsInsert) and Assigned(CustomTreeItem) then
  begin
    with gdcFunction do
    begin
      CustomTreeItem.Name := CustomTreeItem.Name + RUIDToStr(GetRUID);
      FieldByName(fnName).AsString := CustomTreeItem.Name;
      FieldByName(fnModuleCode).AsInteger := CustomTreeItem.OwnerId;
      FieldByName(fnModule).AsString := GetModule;
      FieldByName(fnLanguage).AsString := dbcbLang.Items[1];
    end;
  end;
end;

procedure TFunctionFrame.PageControlChanging(Sender: TObject;
  var AllowChange: Boolean);
var
  I: Integer;
begin
  AllowChange := True;
  if PageControl.ActivePage = tsParams then
  begin
    FFunctionParams.Clear;
    for I := 0 to FParamLines.Count - 1 do
    begin
      FFunctionParams.AddParam('', '', prmInteger, '');
      AllowChange := AllowChange and
        TfrmParamLineSE(FParamLines.Items[I]).GetParam(FFunctionParams.Params[I]);
    end;
  end;
  if AllowChange then
    ScrollBox.Visible := False;
end;

procedure TFunctionFrame.PageControlChange(Sender: TObject);
var
  ParamDlg: TgsParamList;
  I, J: Integer;
  LocParamLine: TfrmParamLineSE;
begin
  if PageControl.ActivePage = tsParams then
  begin
    ScrollBox.Visible := False;
    try
      ParamDlg := TgsParamList.Create;
      try
        GetParamsFromText(ParamDlg, dbeName.Text, gsFunctionSynEdit.Text);
        pnlCaption.Visible := ParamDlg.Count <> 0;

        FParamLines.Clear;
        for I := 0 to ParamDlg.Count - 1 do
        begin
          for J := 0 to FFunctionParams.Count - 1 do
            if UpperCase(FFunctionParams.Params[J].RealName) =
              UpperCase(ParamDlg.Params[I].RealName) then
            begin
              ParamDlg.Params[I].Assign(FFunctionParams.Params[J]);
              Break;
            end;
          LocParamLine := TfrmParamLineSE.Create(nil);
          LocParamLine.Top := FParamLines.Count * LocParamLine.Height;
          LocParamLine.Parent := ScrollBox;
          LocParamLine.SetParam(ParamDlg.Params[I]);
          LocParamLine.OnParamChange := ParamChange;
          LocParamLine.edValuesList.OnChange := edValueChange;

          FParamLines.Add(LocParamLine);
          ScrollBox.VertScrollBar.Increment := LocParamLine.Height;
        end;
        Label19.Visible := ParamDlg.Count = 0;
      finally
        ParamDlg.Free;
      end;
    finally
      ScrollBox.Visible := True;
    end;
  end
  else if (PageControl.ActivePage = tsHistory) then
    if HistoryFrame <> nil then
    begin
      Tprp_FunctionHistoryFrame(HistoryFrame).S := gdcFunction.FieldByName('script').AsString;
      Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.Close;
      Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.Open;
    end else
    begin
      HistoryFrame := Tprp_FunctionHistoryFrame.Create(Self);
      HistoryFrame.Parent := tsHistory;
      Tprp_FunctionHistoryFrame(HistoryFrame).S := gdcFunction.FieldByName('script').AsString;

      Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.ParamByName('ID').AsInteger := gdcFunction.ID;
      Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.Open;
    end;
end;

procedure TFunctionFrame.ParamChange(Sender: TObject);
begin
  Modify := True;
end;

procedure TFunctionFrame.edValueChange(Sender: TObject);
begin
  Modify := True;
end;

procedure TFunctionFrame.DoOnCreate;
begin
  dbeName.OnUpdateRecord := dbeNameUpdateRecord;
  FFunctionParams := TgsParamList.Create;
  FParamLines := TObjectList.Create;
  FDebugLines := TDebugLines.Create;
  FDebugLines.OnErrorLineChanged := OnErrorLineChanged;
  if Assigned(Debugger) then
  begin
    FDebugPlugin := TDebugSupportPlugin.Create(gsFunctionSynEdit);
    FDebugPlugin.DebugLines := FDebugLines;
  end;

  SynCompletionProposal.EndOfTokenChr := '()[].,=<>-+&"';
  FErrorListSuppurtPlugin := TErrorListSuppurtPlugin.Create(gsFunctionSynEdit);

  FVBParser := TVBParser.Create(Self);

  gsFunctionSynEdit.Parser := FVBParser;
  gsFunctionSynEdit.UseParser := True;
  gsFunctionSynEdit.OnChange := gsFunctionSynEditChange;
  gsFunctionSynEdit.OnBeforePaint := OnBeforePaint;
  inherited;
  UpDateSyncs;
  PageControl.ActivePageIndex := 1;
end;

procedure TFunctionFrame.DoOnDestroy;
begin
  FParamLines.Free;
  FFunctionParams.Free;
  FDebugPlugin.DebugLines := nil;
  FDebugLines.Free;
  FDebugPlugin.Free;
  FErrorListSuppurtPlugin.Free;
  FreeAndNil(dsDelpthiObject);
  inherited;
end;

procedure TFunctionFrame.gsFunctionSynEditChange(Sender: TObject);
begin
  Modify := True;
end;

procedure TFunctionFrame.Post;
var
  T: Integer;
begin
  T := gsFunctionSynEdit.TopLine;

  {для начала будем выдавать просто сообщение, в дальнейшем не давать сохранить}
  if (gdcFunction.FieldByName(fnModule).AsString <> scrConst) and
    (gdcFunction.FieldByName(fnModule).AsString <> scrPrologModuleName) then
  begin
    if System.Pos('OPTION EXPLICIT', AnsiUpperCase(gsFunctionSynEdit.Lines.Text)) > 0 then
    begin
      if System.Pos('''OPTION EXPLICIT', AnsiUpperCase(gsFunctionSynEdit.Lines.Text)) > 0 then
        MessageBox(Application.Handle, 'Option Explicit закомментирован.'#13#10 +
          'Его отключение может приводить к ошибкам в коде.', 'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    end else
      MessageBox(Application.Handle, 'Отсутствует Option Explicit.'#13#10 +
        'Его отключение может приводить к ошибкам в коде.', 'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end;

  WarningFunctionName(dbeName.Text,
    gsFunctionSynEdit.Lines);

  gsFunctionSynEdit.UpdateRecord;
  UpDataFunctionParams(FFunctionParams);
  SaveFunctionParams;
  inherited;
  gsFunctionSynEdit.TopLine := T;
end;

procedure TFunctionFrame.gdcFunctionAfterPost(DataSet: TDataSet);
var
  Fnc: TrpCustomFunction;
begin
  inherited;

  //Регестрирум функцию в глобальном списке функций
  Fnc := glbFunctionList.FindFunction(gdcFunction.Id);
  if not Assigned(Fnc) then
  begin
    Fnc := TrpCustomFunction.Create;
    try
      Fnc.ReadFromDataSet(gdcFunction);
      glbFunctionList.AddFunction(Fnc);
    finally
      Fnc.Free;
    end;
  end else
  begin
    Fnc.ReadFromDataSet(gdcFunction);
    glbFunctionList.ReleaseFunction(Fnc);
  end;
  // Если модуль VBClass, Const, GlobalObject, то не заносим в релоадлист
  if not ((Fnc.Module = scrVBClasses) or (Fnc.Module = scrConst) or
    (Fnc.Module = scrGlobalObject))
  then
    ScriptFactory.ReloadFunction(gdcFunction.Id);
    
  MethodControl.ClearMacroCache;

  if HistoryFrame is Tprp_FunctionHistoryFrame then
  begin
    Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.Close;
    Tprp_FunctionHistoryFrame(HistoryFrame).ibdsLog.Open;
  end;
end;

procedure TFunctionFrame.UpDateSyncs;
begin
  if Assigned(SynManager) then
  begin
    gsFunctionSynEdit.BeginUpdate;
    try
      gsFunctionSynEdit.Font.Assign(SynManager.GetHighlighterFont);
      SynManager.GetSynEditOptions(TSynEdit(gsFunctionSynEdit));

      UpdateSelectedColor;
    finally
      gsFunctionSynEdit.EndUpdate;
    end;
    gsFunctionSynEdit.Repaint;
  end;
end;

function TFunctionFrame.GetCompliteStatament(var Str: String; Pos: Integer;
  out BeginPos, EndPos: Integer): String;
var
  CB: Integer;
  L: Integer;
begin
  Result := '';

  if Str > '' then
  begin
    L := Length(Str);
    BeginPos := Pos;
    if BeginPos > L then BeginPos := L;
    EndPos := BeginPos;
    CB := 0;
    while (BeginPos > 1) and ((Str[BeginPos - 1] in ['0'..'9','a'..'z', 'A'..'Z', '_', '.', ')']) or
      ((Str[BeginPos - 1] in ['0'..'9','a'..'z', 'A'..'Z', '_', '.']) and (CB > 0))) do
    begin
      if Str[BeginPos - 1] = ')' then
        Inc(CB);
      if Str[BeginPos] = '(' then
        Dec(CB);
      Dec(BeginPos);
    end;

    while (EndPos <= L) and (Str[EndPos] in ['0'..'9','a'..'z', 'A'..'Z', '_']) do
      Inc(EndPos);

    if BeginPos < EndPos then
      Result := System.Copy(Str, BeginPos, EndPos - BeginPos)
    else
      Result := '';
  end;    
end;

function TFunctionFrame.GetStatament(var Str: String;
  Pos: Integer): String;
var
  BeginPos, EndPos: Integer;
  CB: Integer;
begin
  Result := '';

  BeginPos := Pos;
  if BeginPos > Length(Str) then
    BeginPos := Length(Str);
  EndPos := BeginPos;
  CB := 0;
  while (BeginPos > 1) and ((system.Pos(Str[BeginPos - 1], Letters + '.)') > 0) or
    ((System.Pos(Str[BeginPos - 1], Letters + '.') = 0) and (CB > 0))) do
  begin
    if Str[BeginPos - 1] = ')' then
      Inc(CB);
    if Str[BeginPos] = '(' then
      Dec(CB);
    Dec(BeginPos);
  end;

  while (EndPos > 1) and (System.Pos(Str[EndPos], Letters) > 0) do
    Dec(EndPos);
  if BeginPos < EndPos then
    Result := System.Copy(Str, BeginPos, EndPos - BeginPos)
  else
    Result := '';
end;

procedure TFunctionFrame.GotoLineNumber;
var
  frm: TdlgInputLineNumber;
begin
  frm:= TdlgInputLineNumber.Create(nil);
  try
    frm.LineNumber:= gsFunctionSynEdit.CaretY;
    if frm.ShowModal = mrOk then begin
      GotoLine(frm.LineNumber, 0);
      gsFunctionSynEdit.Show;
    end;
  finally
    frm.Free;
  end;
end;

procedure TFunctionFrame.GotoErrorLine(ErrorLine: Integer);
begin
  if Assigned(Debugger) then  FDebugLines.ErrorLine := ErrorLine - 1;
  GotoLine(ErrorLine, 0);
  gsFunctionSynEdit.Show;
end;

procedure TFunctionFrame.GoToLine(Line, Column: Integer);
begin
  GoToXY(Column, Line);
end;

procedure TFunctionFrame.GoToXY(X, Y: Integer);
begin
  if (Y > 0) and (Y <= gsFunctionSynEdit.Lines.Count) then
  begin
    gsFunctionSynEdit.CaretX := X;
    gsFunctionSynEdit.CaretY := Y;
    gsFunctionSynEdit.EnsureCursorPosVisibleEx(True);
    gsFunctionSynEdit.InvalidateLine(Y);
  end;
  if gsFunctionSynEdit.CanFocus then
    gsFunctionSynEdit.SetFocus;
end;

function TFunctionFrame.CheckDestroing: Boolean;
begin
  Result := Application.Terminated or (csDestroying in ComponentState);
end;

procedure TFunctionFrame.ParserInit;
var
  C: TComponent;

  procedure AddComponents(C: TComponent);
  var
    I: Integer;
  begin
    if C is TCreateableForm then
      FVBParser.Objects.Add(TCreateableForm(C).InitialName)
    else
      FVBParser.Objects.Add(C.Name);

    if Assigned(VBProposal) then
      if C is TCreateableForm then
      begin
        if VBProposal <> nil then
          VBProposal.AddFKObject(TCreateableForm(C).InitialName, C)
      end else
        if VBProposal <> nil then
          VBProposal.AddFKObject(C.Name, C);

    for I := 0 to C.ComponentCount - 1 do
      if C.Components[I].Name <> '' then
        AddComponents(C.Components[I]);
  end;

begin
  FVBParser.IsEvent := False;
  if Assigned(CustomTreeItem) then
  begin
    FVBParser.Component := nil;
    FVBParser.Objects.Clear;
    if VBProposal <> nil then
      VBProposal.ClearFKObjects;
    C := GetForm(CustomTreeItem.MainOwnerName);
    if Assigned(C) then
    begin
      FVBParser.ComponentName := TCreateableForm(C).InitialName;
      FVBParser.Component := C;
      AddComponents(C);
    end;
  end;
end;

procedure TFunctionFrame.SetObjectId(const Value: Integer);
begin
  inherited;

  //Инициализируем парсер
  ParserInit;
  gsFunctionSynEdit.CaretX := 1;
end;

procedure TFunctionFrame.Prepare;
var
  SF: TgdScriptFactory;
  CustomFunction: TrpCustomFunction;
begin
  TfrmGedeminProperty(GetParentForm(Self)).ClearErrorResult;

  WarningFunctionName(dbeName.Text, gsFunctionSynEdit.Lines);

  if gsFunctionSynEdit.Modified then
  begin
    ScriptFactory.Reset;
    gsFunctionSynEdit.UpdateRecord;
  end;

  if Assigned(ScriptFactory) then
  begin
    { TODO : Добавление кода в скрипт функтион }
    SF := TgdScriptFactory(ScriptFactory.Get_Self);
    try
      CustomFunction := TrpCustomFunction.Create;
      try
        CustomFunction.ReadFromDataSet(gdcFunction);

        SF.ScriptTest(CustomFunction);
        MessageBox(Application.Handle, 'Удачное завершение.'#13#10 +
          'Синтаксические ошибки не обнаружены.',
          PChar('Проверка синтаксиса ' + dbeName.Text),
          MB_OK or MB_ICONINFORMATION or MB_TOPMOST or MB_TASKMODAL);
      finally
        CustomFunction.Free;
      end;
    finally
      TfrmGedeminProperty(GetParentForm(Self)).UpdateErrors;
    end;
  end;
end;

function TFunctionFrame.Run(const SFType: sfTypes): Variant;
var
  CustomFunction: TrpCustomFunction;
  PMess: array[0..1024] of Char;
  S: String;
  B: Boolean;
const
  WMess = 'Для запущенной скрипт-функции %s не найдена'#13#10'форма владелец %s (параметр OwnerForm).'#13#10'Все равно запустить?';

begin
  Result := Null;
  B := (Debugger <> nil) and not Debugger.FunctionRun;
  if CanRun then
  try
    TfrmGedeminProperty(GetParentForm(Self)).ClearErrorResult;
    try
      WarningFunctionName(dbeName.Text, gsFunctionSynEdit.Lines)
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, PChar(E.Message), MSG_ERROR,
          MB_OK or MB_TASKMODAL or MB_ICONERROR);
        Exit;
      end;
    end;

    if gsFunctionSynEdit.Modified then
    begin
      ScriptFactory.Reset;
      gsFunctionSynEdit.UpdateRecord;
    end;

    // Создание тестовой функции

    CustomFunction := TrpCustomFunction.Create;
    try
      CustomFunction.ReadFromDataSet(gdcFunction);
      UpDataFunctionParams(FFunctionParams);
      CustomFunction.EnteredParams.Assign(FFunctionParams);

      if Assigned(ScriptFactory) then
      begin
        Result := VarArrayOf([]);
        Result := CustomFunction.EnteredParams.GetVariantArray;
        try
          //Устанавливаем признак запуска скрипта
          FRunning := True;
          try
            if ScriptFactory.InputParams(CustomFunction, Result) then
            begin
              FFunctionParams.Assign(CustomFunction.EnteredParams);
              if SFType in [sfMacros, sfReport] then
              begin
                if not ScriptFactory.GiveOwnerForm(CustomFunction, Result,
                  PropertyTreeForm.cbObjectList.Text
                  {TdfPropertyTree(CustomTreeItem.Node.Owner.Owner.Owner.Owner).cbObjectList.Text}) then
                begin
                  S :=  Format(WMess, [CustomFunction.Name, CustomTreeItem.MainOwnerName]);
                  StrPCopy(PMess, S);
                  if MessageBox(0, PMess, MSG_ERROR,
                    MB_YESNO or MB_ICONERROR or MB_TASKMODAL or MB_TOPMOST or MB_DEFBUTTON2) = ID_NO then
                    raise EAbort.Create('');
                end;
              end;
              ScriptFactory.ExecuteFunction(CustomFunction, Result);
            end;
          except
             ScriptFactory.ReloadFunction(CustomFunction.FunctionKey);
             Result := Null;
//             if not PropertySettings.Exceptions.Stop then
             raise;
          end;
        finally
          //Снимаем признак запуска скрипта
          FRunning := False;
          TfrmGedeminProperty(GetParentForm(Self)).UpdateErrors;
          TfrmGedeminProperty(GetParentForm(Self)).UpdateCallStack;
          TfrmGedeminProperty(GetParentForm(Self)).UpdateWatchList;
          TfrmGedeminProperty(GetParentForm(Self)).UpdateBreakPoints;
        end;
      end else
        raise Exception.Create('Компонент ScriptFactory не создан.');
    finally
      CustomFunction.Free;
    end;
  finally
    //Данная остановка дебагера необходима на случай отмены при
    //запросе параметров
    if (Debugger <> nil) and B then Debugger.Stop;
    //Запрещаем изменение вывода инф. о запуске фун.
    TfrmGedeminProperty(GetParentForm(Self)).CanChangeCaption := False;
  end;
end;

procedure TFunctionFrame.WarningFunctionName(const AnFunctionName: string;
  AnScriptText: TStrings);
var
  i: integer;
  SearchOptions: TSynSearchOptions;
  OldPos: TPoint;

  procedure EdtSetFocus;
  begin
    dbeName.Show;
    dbeName.SetFocus;
  end;

begin
  dbeName.Text:= Trim(dbeName.Text);

  if (Length(AnFunctionName) = 0) then begin
    EdtSetFocus;
    raise Exception.Create(MSG_EMPTY_NAME_FUNCTION);
  end;

  if Pos(AnFunctionName[1], Numbers) > 0 then begin
    EdtSetFocus;
    raise Exception.Create(MSG_NAME_FUNCTION_NUMBER);
  end;

  for i:= 1 to Length(AnFunctionName) do begin
    if Pos(AnFunctionName[i], Letters) < 1 then begin
      EdtSetFocus;
      raise Exception.Create(MSG_UNKNOWN_NAME_FUNCTION);
    end;
  end;

  if not CheckFunctionName(AnFunctionName, AnScriptText) then
  begin
    if (FOldName <> AnFunctionName) and CheckFunctionName(FOldName, AnScriptText) then begin
      if MessageBox(Application.handle, MSG_CORRECT_NAME_FUNCTION,
          'Внимание', MB_YESNO or MB_TASKMODAL or MB_ICONQUESTION) = IDYES then begin
        SearchOptions := [ssoWholeWord, ssoReplaceAll];
        OldPos:= gsFunctionSynEdit.CaretXY;
        gsFunctionSynEdit.CaretX:= 0;
        gsFunctionSynEdit.CaretY:= 0;
        gsFunctionSynEdit.SearchReplace(FOldName, AnFunctionName, SearchOptions);
        FOldName:= AnFunctionName;
        gsFunctionSynEdit.CaretXY:= OldPos;
      end
      else
        raise Exception.Create(MSG_UNKNOWN_NAME_FUNCTION);
    end
    else
      raise Exception.Create(MSG_UNKNOWN_NAME_FUNCTION);
  end
  else if FOldName <> AnFunctionName then
    FOldName:= AnFunctionName;
end;

procedure TFunctionFrame.UpDataFunctionParams(
  FunctionParams: TgsParamList);
var
  I, J: Integer;
  ParamDlg: TgsParamList;
begin
  //Прозиводим обнавление параметров
  if PageControl.ActivePage = tsParams then
  begin
    FunctionParams.Clear;
    for I := 0 to FParamLines.Count - 1 do
    begin
      FunctionParams.AddParam('', '', prmInteger, '');
      TfrmParamLineSE(FParamLines.Items[I]).GetParam(FunctionParams.Params[I]);
    end;
  end else
  begin
    ParamDlg := TgsParamList.Create;
    try
      ParamDlg.Assign(FunctionParams);
      FunctionParams.Clear;
      GetParamsFromText(FunctionParams, dbeName.Text, gsFunctionSynEdit.Text);
      for I := 0 to FunctionParams.Count - 1 do
      begin
        for J := 0 to ParamDlg.Count - 1 do
          if UpperCase(FunctionParams.Params[I].RealName) =
            UpperCase(ParamDlg.Params[J].RealName) then
          begin
            FunctionParams.Params[I].Assign(ParamDlg.Params[J]);
            Break;
          end;
      end;
    finally
      ParamDlg.Free;
    end;
  end;
end;

function TFunctionFrame.CheckFunctionName(AnFunctionName: string;
  AnScriptText: TStrings): Boolean;
var
  E: TCodeExplorerParser;
begin
  Result := True;
  E := TCodeExplorerParser.Create(nil);
  try
   if (gdcFunction.FieldByName(fnModule).AsString <> scrVBClasses) and
     (gdcFunction.FieldByName(fnModule).AsString <> scrConst) and
     (gdcFunction.FieldByName(fnModule).AsString <> scrPrologModuleName) then
   begin
     if gdcFunction.FieldByName(fnModule).AsString = scrGlobalObject then
       AnFunctionName := AnFunctionName + '_Initialize';
     Result := E.CheckFunctionName(AnFunctionName, AnScriptText.Text);
   end;
  finally
    E.Free;
  end;
end;

procedure TFunctionFrame.EditFunction(ID: Integer);
begin
  if gdcFunction.Id = id then
    gsFunctionSynEdit.Show
  else
    raise Exception.Create(Format('Функция с id = %d не обнаружена', [id]));
end;

procedure TFunctionFrame.ToggleBreakpoint(Line: Integer);
var
  BreakPoint: TBreakPoint;
begin
  BreakPoint := BreakPointList.BreakPoint(gdcFunction.fieldByname(fnId).AsInteger,
    Line);
  if BreakPoint = nil then
  begin
    BreakPoint := TBreakPoint.Create;
    BreakPoint.FunctionKey := gdcFunction.fieldByname(fnId).AsInteger;
    BreakPoint.Line := Line;
    BreakPointlist.Add(BreakPoint);
  end else
    BreakPointList.Remove(BreakPoint);
  BreakPointList.SaveToStorage;

  gsFunctionSynEdit.InvalidateGutter;
  gsFunctionSynEdit.InvalidateLine(Line);
  UpdateBreakPointsWindow;
end;

function TFunctionFrame.IsExecuteScript: Boolean;
begin
  Result := _IsExecutedScript(gdcFunction.Id);
end;

procedure TFunctionFrame.LoadBreakPoints;
var
  S: TStream;
begin
  S := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('breakpoints'),
    DB.bmRead);
  try
    if S.Size > 0 then
      FDebugLines.ReadBPFromStream(S);
  finally
    S.Free;
  end;
end;

function TFunctionFrame.GetFunctionID: Integer;
begin
  Result := gdcFunction.Id;
end;

procedure TFunctionFrame.InvalidateFrame;
begin
  inherited;
  gsFunctionSynEdit.Invalidate;
  gsFunctionSynEdit.InvalidateGutter;
end;

procedure TFunctionFrame.OnBeforePaint(Sender: TObject);
begin
end;

function TFunctionFrame.GetCaretXY: TPoint;
begin
  Result := gsFunctionSynEdit.CaretXY;
end;

procedure TFunctionFrame.SetCaretXY(const Value: TPoint);
begin
  gsFunctionSynEdit.CaretXY := Value;
end;

procedure TFunctionFrame.Evaluate;
var
  Text: String;
  I: Integer;
begin
  if PageControl.ActivePage = tsScript then
  begin
    if not Assigned(FEvaluate) then
      FEvaluate := TdlgEvaluate.Create(Self);

    if gsFunctionSynEdit.SelAvail then
      Text := gsFunctionSynEdit.SelText
    else
      Text := gsFunctionSynEdit.WordAtCursor;

    for I := Length(Text) downto 1 do
    begin
      if Text[I] in [#10, #13] then
        Text[I] := ' ';
    end;
    //Дебагер в режиме пайзы блокирует все окна кроме редактора
    //поэтому при необходимости разблокируем окно
    if not FEvaluate.Enabled then FEvaluate.Enabled := True;
    FEvaluate.cbExpression.Text := Trim(Text);
    FEvaluate.ShowModal;
  end else
    inherited;
end;

function TFunctionFrame.GetSelectedText: string;
begin
  Result := gsFunctionSynEdit.SelText;
end;

procedure TFunctionFrame.UpdateNameColor;
var
  SQL: TIBSQl;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcFunction.ReadTransaction;
    SQL.SQL.Text := 'SELECT COUNT(*) FROM gd_function WHERE id <> :id AND ' +
      'UPPER(name) = UPPER(:name) AND modulecode = :modulecode';
    SQL.Params[0].AsInteger := gdcFunction.FieldByName(fnId).AsInteger;
    SQL.Params[1].AsString := dbeName.Text;
    SQL.Params[2].AsInteger := gdcFunction.FieldByName(fnModuleCode).AsInteger;
    SQL.ExecQuery;
    if SQL.Fields[0].AsInteger > 0 then
      dbeName.Color := clRed
    else
      dbeName.Color := clWhite;
  finally
    SQL.Free;
  end;
end;

procedure TFunctionFrame.ToggleBreak;
begin
  if PageControl.ActivePage = tsScript then
    ToggleBreakpoint(gsFunctionSynEdit.CaretY);
end;

function TFunctionFrame.CanToggleBreak: Boolean;
begin
  Result := ScriptIsActive;
end;

function TFunctionFrame.CanLoadFromFile: Boolean;
begin
  Result := ScriptIsActive;
end;

procedure TFunctionFrame.LoadFromFile;
begin
  if CanLoadFromFile then
  begin
    OpenDialog.Filter := gsFunctionSynEdit.Highlighter.DefaultFilter;
    if OpenDialog.Execute then
    begin
      gsFunctionSynEdit.Lines.LoadFromFile(OpenDialog.FileName);
      TCrackDBSynEdit(gsFunctionSynEdit).NewOnChange(gsFunctionSynEdit);
      Modify := True;
    end;
  end;
end;

function TFunctionFrame.CanSaveToFile: Boolean;
begin
  Result := ScriptIsActive;
end;

procedure TFunctionFrame.SaveToFile;
var
  I: Integer;
begin
  SaveDialog.Filter := gsFunctionSynEdit.Highlighter.DefaultFilter;
  SaveDialog.DefaultExt := '';
  I := Length(SaveDialog.Filter);
  while (I > 0) and (SaveDialog.Filter[I] <> '.') do
  begin
    SaveDialog.DefaultExt := SaveDialog.Filter[I] + SaveDialog.DefaultExt;
    Dec(I);
  end;

  SaveDialog.FileName := dbeName.Text;
  if SaveDialog.Execute then
    gsFunctionSynEdit.SaveToFile(SaveDialog.FileName);
end;

function TFunctionFrame.ScriptIsActive: Boolean;
begin
  Result := PageControl.ActivePage = tsScript;
end;

function TFunctionFrame.CanGoToLineNumber: Boolean;
begin
  Result := ScriptIsActive;
end;

function TFunctionFrame.CanFindReplace: Boolean;
begin
  Result := ScriptIsActive;
end;

procedure TFunctionFrame.Find;
var
  F: TCustomForm;
begin
  if dlgPropertyFind = nil then
    TdlgPropertyFind.Create(Self);

  if dlgPropertyFind <> nil then
  begin
    dlgPropertyFind.SearchInDB := False;
    if gsFunctionSynEdit.SelAvail then
      SearchOptions.SearchText := gsFunctionSynEdit.SelText
    else
      SearchOptions.SearchText := gsFunctionSynEdit.WordAtCursor;

    if dlgPropertyFind.ShowModal = mrOk then
    begin
      if dlgPropertyFind.PC.ActivePage = dlgPropertyFind.tsFind then
      begin
        FFinding := True;
        FFindNext := False;
        DoFind;
      end else
      begin
        F := GetParentForm(Self);
        if F <> nil then
          TfrmGedeminProperty(F).DoFind;
      end;
    end;
    FreeAndNil(dlgPropertyFind);
  end;
end;

procedure TFunctionFrame.Replace;
begin
  if dlgPropertyReplace = nil then
    TdlgPropertyReplace.Create(Self);

  if dlgPropertyReplace <> nil then
  begin
    if gsFunctionSynEdit.SelAvail then
      ReplaceOptions.SearchText := gsFunctionSynEdit.SelText
    else
      ReplaceOptions.SearchText := Trim(gsFunctionSynEdit.WordAtCursor);

    if dlgPropertyReplace.ShowModal = mrOk then
    begin
      FFinding := False;
      FFindNext := False;
      DoReplace;
    end;
    FreeAndNil(dlgPropertyReplace);
  end;
end;

function TFunctionFrame.CanCopy: Boolean;
begin
  Result := ScriptIsActive and gsFunctionSynEdit.SelAvail;
end;

function TFunctionFrame.CanCopySQL: Boolean;
begin
  Result := CanCopy;
end;

function TFunctionFrame.CanCut: Boolean;
begin
  Result := ScriptIsActive and gsFunctionSynEdit.SelAvail;
end;

function TFunctionFrame.CanPaste: Boolean;
begin
  Result := ScriptIsActive;
end;

function TFunctionFrame.CanPasteSQL: Boolean;
begin
  Result := CanPaste;
end;

procedure TFunctionFrame.Copy;
begin
  if CanCopy then
    gsFunctionSynEdit.CopyToClipboard;
end;

procedure TFunctionFrame.CopySQl;
begin
  gd_strings.CopySQL(gsFunctionSynEdit);
end;

procedure TFunctionFrame.Cut;
begin
  if CanCut then
    gsFunctionSynEdit.CutToClipboard;
end;

procedure TFunctionFrame.Paste;
begin
  if CanPaste then
    gsFunctionSynEdit.PasteFromClipboard;
end;

procedure TFunctionFrame.PasteSQL;
begin
  gd_strings.PasteSQL(gsFunctionSynEdit);
end;

procedure TFunctionFrame.SetMessageListView(const Value: TListView);
begin
  inherited;
  FErrorListSuppurtPlugin.ErrorListView := Value;
end;

procedure TFunctionFrame.GotoToInclude;
var
  CurrentWord: String;
  SQL: TIBSQL;
  E: TCodeExplorerParser;
  S: TStrings;
  Index: Integer;
begin
  if Modify then
    Post;

  CurrentWord := UpperCase(Trim(System.Copy(gsFunctionSynEdit.Lines[gsFunctionSynEdit.CaretY - 1],
    gsFunctionSynEdit.WordStart.X, gsFunctionSynEdit.WordEnd.X -
    gsFunctionSynEdit.WordStart.X)));
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcFunction.ReadTransaction;
    SQL.SQl.Text := 'SELECT g.id FROM gd_function g, rp_additionalfunction a ' +
      'WHERE a.mainfunctionkey = :id and g.id = a.addfunctionkey and Upper(g.name) = :name';
    SQL.Prepare;
    SQL.Params[0].AsInteger := gdcFunction.FieldByName(fnId).AsInteger;
    SQl.Params[1].AsString := CurrentWord;
    SQL.ExecQuery;
    if not SQL.Eof then
    begin
      TfrmGedeminProperty(GetParentForm(Self)).FindAndEdit(SQL.Fields[0].AsInteger);
    end else
    begin
      E := TCodeExplorerParser.Create(nil);
      try
        S := TStringList.Create;
        try
          E.ProceduresList(gsFunctionSynEdit.Lines, S);
          Index := S.IndexOf(CurrentWord);
          if Index > - 1 then
          begin
            gsFunctionSynEdit.CaretY := Integer(S.Objects[Index]) + 1;
            gsFunctionSynEdit.CaretX := 1;
            Exit;
          end;
        finally
          S.Free;
        end;
      finally
        E.Free;
      end;

      SQL.CLose;
      SQL.SQL.Text:=
        'SELECT id FROM gd_function WHERE Upper(name) = ' + QuotedStr(CurrentWord);
      SQL.ExecQuery;
      if not SQL.Eof then begin
        if MessageBox(Application.Handle,
            PChar(Format('Функция %s не перечислена в секции INCLUDE. Добавить?', [CurrentWord])),
            'Внимание', MB_YESNO or MB_ICONEXCLAMATION or MB_TASKMODAL) = ID_YES then begin
          gsFunctionSynEdit.Lines.Insert(0, '''#include ' + CurrentWord);
          Modify := True;
          gsFunctionSynEdit.Modified := True;
        end;
        TfrmGedeminProperty(GetParentForm(Self)).FindAndEdit(SQL.Fields[0].AsInteger);
      end else
        MessageBox(Application.Handle,
          PChar(Format('Функция %s не найдена.', [CurrentWord])),
          'Внимание',
          MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
    end;
  finally
    SQl.Free;
  end;
end;

procedure TFunctionFrame.Cancel;
begin
  FDebugLines.Clear;
  inherited;
  UpdateNameColor;
end;

procedure TFunctionFrame.SaveFunctionParams;
var
  Str: TStream;
begin
  if FFunctionParams.Count > 0 then
  begin
    Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmWrite);
    try
      FFunctionParams.SaveToStream(Str);
    finally
      Str.Free;
    end;
  end else
    gdcFunction.FieldByName(fnEnteredParams).Clear;
end;

procedure TFunctionFrame.OnErrorLineChanged(Sender: TObject);
begin
  gsFunctionSynEdit.Invalidate;
end;

procedure TFunctionFrame.DoFind;
var
  rOptions: TSynSearchOptions;
begin
  if Length(SearchOptions.SearchText) = 0 then
  begin
    Exit;
  end else
  begin
    rOptions := [];
    with SearchOptions do
    begin
      if SearchInText.Options.CaseSensitive then
        Include(rOptions, ssoMatchCase);
      if SearchInText.Options.WholeWord then
        Include(rOptions, ssoWholeWord);
      if SearchInText.Direction = sdBackward then
        Include(rOptions, ssoBackwards);
      if SearchInText.Scope = ssSelectedText then
        Include(rOptions, ssoSelectedOnly);
      if not FFindNext and (SearchInText.Origin = soEntireScope) then
        Include(rOptions, ssoEntireScope);
      if gsFunctionSynEdit.SearchReplace(SearchText, '', rOptions) = 0 then
      begin
        Beep;
        MessageBox(Application.Handle, PChar(MSG_SEACHING_TEXT + SearchText +
         MSG_NOT_FIND), MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
      end;
    end;
  end;
end;

procedure TFunctionFrame.SetParent(AParent: TWinControl);  
begin
  inherited;

  SetHighlighter;
end;

procedure TFunctionFrame.SetHighlighter;
var
  F: TCustomForm;
begin
  F := GetParentForm(Self);
  if F <> nil then
  begin
    gsFunctionSynEdit.Highlighter := TfrmGedeminProperty(F).SynVBScriptSyn;
    UpdateSelectedColor;
  end;
end;

procedure TFunctionFrame.DoReplace;
var
  rOptions: TSynSearchOptions;
begin
  if Length(ReplaceOptions.SearchText) = 0 then
  begin
    Exit;
  end else
  begin
    rOptions := [ssoReplace];
    with ReplaceOptions do
    begin
      if ReplaceInText.Promt then
        Include(rOptions, ssoPrompt);
      if ReplaceAll then
        Include(rOptions, ssoReplaceAll);
      if ReplaceInText.Options.CaseSensitive then
        Include(rOptions, ssoMatchCase);
      if ReplaceInText.Options.WholeWord then
        Include(rOptions, ssoWholeWord);
      if ReplaceInText.Direction = sdBackward then
        Include(rOptions, ssoBackwards);
      if ReplaceInText.Scope = ssSelectedText then
        Include(rOptions, ssoSelectedOnly);
      if not FFindNext and (ReplaceInText.Origin = soEntireScope) then
        Include(rOptions, ssoEntireScope);
      if gsFunctionSynEdit.SearchReplace(SearchText, ReplaceText, rOptions) = 0 then
      begin
        Beep;
        MessageBox(Application.Handle, PChar(MSG_SEACHING_TEXT + SearchText +
          MSG_NOT_FIND), MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
      end;
    end;
  end;
end;

procedure TFunctionFrame.UpdateSelectedColor;
var
  SynHighlighter: TSynCustomHighlighter;
begin
  SynHighlighter := gsFunctionSynEdit.Highlighter;
  if (SynHighlighter <> nil) and (SynHighlighter is TSynVBScriptSyn) then
  begin
    gsFunctionSynEdit.SelectedColor.Foreground :=
      TSynVBScriptSyn(SynHighlighter).MarkBlockAttri.Foreground;
    gsFunctionSynEdit.SelectedColor.Background :=
      TSynVBScriptSyn(SynHighlighter).MarkBlockAttri.Background;
  end else
  begin
    gsFunctionSynEdit.SelectedColor.Foreground := clHighlightText;
    gsFunctionSynEdit.SelectedColor.Background := clHighlight;
  end;
end;

procedure TFunctionFrame.DoBeforeDelete;
var
  TS: TTreeTabSheet;

  procedure DeleteSFNode(N: TTreeNode);
  var
    Nd: TTreeNode;
  begin
    if N <> nil then
    begin
      Nd := N.GetFirstChild;
      while (Nd <> nil) do
      begin
        if (TCustomTreeItem(Nd.Data).Id = gdcFunction.Id) and
          (Node <> Nd) then
        begin
          if TCustomTreeItem(Nd.Data).EditorFrame <> nil then
          begin
            TBaseFrame(TSFTreeItem(Nd.Data).EditorFrame).Cancel;
            TBaseFrame(TSFTreeItem(Nd.Data).EditorFrame).Close;
          end;
          Nd.Delete;
          Break;
        end;
        Nd := Nd.GetNextSibling;
      end;
    end;
  end;

begin
  inherited;
  if Node <> nil then
  begin
    if TCustomTreeItem(Node.Data).ItemType <> tiSF then
      DeleteSFNode(TprpTreeView(Node.TreeView).SFRootNode);
    FOldFunctionKey := TCustomTreeItem(Node.Data).ID;
  end;
  if PropertyTreeForm <> nil then
  begin
    TS := PropertyTreeForm.GetPageByObjID(OBJ_APPLICATION);
    if TS <> nil then
      DeleteSFNode(TS.SFRootNode);
    if TCustomTreeItem(Node.Data).ItemType = tiSF then
    begin
      //Если сф имеет модуль VBClass, Const, GObject то необходимо удалить
      //соответсвоющие ноды в дереве
      if TS <> nil then
      begin
        DeleteSFNode(TS.VBClassRootNode);
        DeleteSFNode(TS.ConstRootNode);
        DeleteSFNode(TS.GORootNode);
      end;
    end;
  end;
end;

procedure TFunctionFrame.ChangeCommentBlock(const AComment: TprpComment);
var
  Str: String;
  I, K: Integer;
  LStrings: TStrings;
  F: Boolean;
  BlockBegin, BlockEnd: TPoint;
begin
  Str := '';
  // есть ли выделение
  if gsFunctionSynEdit.SelAvail then
  begin
    // запоминаем начало и окончание выделения
    BlockBegin := gsFunctionSynEdit.BlockBegin;
    BlockEnd := gsFunctionSynEdit.BlockEnd;
    Str := gsFunctionSynEdit.SelText;
    // выделена строка до конца или нет
    if System.Copy(Str, Length(Str)  - 1, 2) =  #13#10 then
      F := True
    else
      F := False;
    case AComment of
      prpComment:
      // добавляем символ комментария в каждую строку
      begin
        Str := prp_VBComment + Str;
        StrReplace(Str, #13#10, #13#10 + prp_VBComment, [rfIgnoreCase, rfReplaceAll]);
        if System.Copy(Str, Length(Str) - 2, 3) = #13#10 + prp_VBComment then
          Str := System.Copy(Str, 1, Length(Str) - 3) + #13#10;
        // корректировка окончания блока
        if BlockEnd.x > 1 then
          BlockEnd.x := BlockEnd.x + Length(prp_VBComment);
      end;
      prpUnComment:
      // удаляем символ комментария
      begin
        LStrings := TStringList.Create;
        try
          LStrings.Text := Str;
          for I := 0 to LStrings.Count - 1 do
          begin
            for K := 1 to Length(LStrings[I]) do
            begin
              if LStrings[I][K] = ' ' then
                Continue
              else
                begin
                  if LStrings[I][K] = prp_VBComment then
                    LStrings[I] := StringOfChar(' ', K - 1) +
                      System.Copy(LStrings[I], K + 1, Length(LStrings[I]));
                  Break;
                end;
            end;
          end;
          // получаем измененный текст, которым заменим выделение
          if F then
          begin
            Str := LStrings.Text;
            // корректировка окончания блока
            if BlockEnd.x > 1 then
              BlockEnd.x := Length(LStrings[LStrings.Count - Length(prp_VBComment)])
          end else
            begin
              Str := System.Copy(LStrings.Text, 1, Length(LStrings.Text) - 2);
              // корректировка окончания блока
              if BlockEnd.x > 1 then
                BlockEnd.x := BlockEnd.x - Length(prp_VBComment);
            end;
        finally
          LStrings.Free;
        end;
      end;
    end;

  end;
  // заменяем текст в редакторе
  gsFunctionSynEdit.SelText := Str;
  // устанавливаем границы выделения
  gsFunctionSynEdit.BlockBegin := BlockBegin;
  gsFunctionSynEdit.BlockEnd := BlockEnd;
end;

procedure TFunctionFrame.CMShowingChanged(var Message: TMessage);
begin
  Inherited;
  if Message.Msg = SW_HIDE then
  begin
    dbeNameExit(Self);
  end;
end;

constructor TFunctionFrame.Create(AOwner: TComponent);
begin
  inherited;
  FCurrentFunctionName := '';
  FOldFunctionKey := 0;
  gdcFunction.CompileScript := True;
end;

procedure TFunctionFrame.SetBaseScriptText(const NewFunctionName: String);
begin

end;

procedure TFunctionFrame.SetCurrentFunctionName(const Value: String);
begin
  FCurrentFunctionName := Value;
end;

function TFunctionFrame.NewNameUpdate: Boolean;
begin
  Result := True;
end;

procedure TFunctionFrame.CopyToRTFClipboart;
var
  LStrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    LStrings.Text := gsFunctionSynEdit.SelText;
    with SynExporterRTF1 do begin
      Title := 'Source file exported to clipboard (RTF format)';
      ExportAsText := False;
      Highlighter := gsFunctionSynEdit.Highlighter;
      ExportAll(LStrings);
      CopyToClipboard;
    end;
  finally
    LStrings.Free;
  end;
end;

procedure TFunctionFrame.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
end;

function TFunctionFrame.GetCurrentWord: string;
begin
  Result := gsFunctionSynEdit.WordAtCursor;
end;

procedure TFunctionFrame.Activate;
var
  F: TCustomForm;
begin
  inherited;
  if PageControl.ActivePage = tsScript then
  begin
    F := GetParentForm(Self);
    if F <> nil then
      F.ActiveControl := gsFunctionSynEdit;
  end;
end;

procedure TFunctionFrame.InsertText(const AText: String);
begin
end;

procedure TFunctionFrame.UpdateBreakPoints;
begin
  if IsExecuteScript then
    FDebugLines.Assign(Debugger.ExecuteDebugLines);
end;

procedure TFunctionFrame.UpdateBreakPointsWindow;
var
  F: TCustomForm;
begin
  F := GetParentForm(self);
  if F <> nil then
    TfrmGedeminProperty(F).UpdateBreakPoints;
end;

procedure TFunctionFrame.ShowTypeInfo;
var
  Text, TypeName: String;
  I: Integer;
  Variable: OleVariant;
begin
  if PageControl.ActivePage = tsScript then
  begin
    if frmTypeInfo = nil then
    begin
      frmTypeInfo := TfrmTypeInfo.Create(nil);
      frmTypeInfo.DockForm := TfrmGedeminProperty(GetParentForm(Self));
    end;

    Text := gsFunctionSynEdit.WordAtCursor;

    for I := Length(Text) downto 1 do
    begin
      if Text[I] in [#10, #13] then
        Text[I] := ' ';
    end;

    if not (Trim(Text) = '') then
    begin
      Variable := Debugger.GetVariable(Text);
      try
        if VarType(Variable) = varEmpty then
        begin
          if ScriptFactory.Eval('VarType(' + Text + ')') = varDispatch then
            Variable := ScriptFactory.Eval(Text);
        end;
        TypeName := Debugger.eval('TypeName(' + Text + ')');
        if TypeName[1] = '"' then TypeName := System.Copy(TypeName, 2, Length(TypeName));
        if TypeName[Length(TypeName)] = '"' then TypeName := System.Copy(TypeName, 1, Length(TypeName) - 1);

      except
        raise Exception.Create('Не удалось получить информацию о переменной ''' + Text + '''');
      end;

      frmTypeInfo.ShowTypeInfo(Debugger.GetVariable(Text), Text, TypeName);
    end;
    //Дебагер в режиме пайзы блокирует все окна кроме редактора
    //поэтому при необходимости разблокируем окно
//    if not FfrmTypeInfo.Enabled then FfrmTypeInfo.Enabled := True;
  end;
end;

procedure TFunctionFrame.SetDependencies(Flag: TprpDepend);
var
  ibsql: TIBSQL;
begin
  if Flag in [sdDependent, sdAll] then
    lbDependent.Items.Clear;

  if Flag in [sdDependedFrom, sdAll] then
    lbDependedFrom.Items.Clear;

  if gdcFunction.ID <= 0 then Exit;

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    if Flag in [sdDependent, sdAll] then
    begin
      ibsql.SQL.Text := 'SELECT f.id, f.name ' +
        ' FROM ' +
        '   rp_additionalfunction a ' +
        ' LEFT JOIN gd_function f ON f.id = a.mainfunctionkey ' +
        ' WHERE a.addfunctionkey = :fk ' ;

      ibsql.ParamByName('fk').AsInteger := gdcFunction.ID;
      ibsql.ExecQuery;

      lbDependent.Sorted := False;
      while not ibsql.EOF do
      begin
        lbDependent.Items.AddObject(ibsql.FieldByName('name').AsString,
          Pointer(ibsql.FieldByName('id').AsInteger));
        ibsql.Next;
      end;
      lbDependent.Sorted := True;
    end;

    if Flag in [sdDependedFrom, sdAll] then
    begin
      ibsql.Close;
      ibsql.SQL.Text := 'SELECT f.id, f.name ' +
        ' FROM ' +
        '   rp_additionalfunction a ' +
        ' LEFT JOIN gd_function f ON f.id = a.addfunctionkey ' +
        ' WHERE a.mainfunctionkey = :fk ' ;

      ibsql.ParamByName('fk').AsInteger := gdcFunction.ID;
      ibsql.ExecQuery;

      lbDependedFrom.Sorted := False;
      while not ibsql.EOF do
      begin
        lbDependedFrom.Items.AddObject(ibsql.FieldByName('name').AsString,
          Pointer(ibsql.FieldByName('id').AsInteger));
        ibsql.Next;
      end;
      lbDependedFrom.Sorted := True;
    end;
  finally
    ibsql.Free;
  end;
end;

class function TFunctionFrame.GetNameById(Id: Integer): string;
var
  S: string;
begin
  S := GetNameFromDb(Id);
  if S > '' then
    Result := GetTypeName + S
  else
    Result := '';
end;

class function TFunctionFrame.GetNameFromDb(Id: Integer): string;
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQl.SQL.Text := 'SELECT name FROM gd_function WHERE id = :id';
    SQL.ParamByName('id').AsInteger := id;
    SQL.ExecQuery;
    Result := SQL.FieldByName('name').AsString;
  finally
    SQL.Free;
  end;
end;

class function TFunctionFrame.GetTypeName: string;
begin
  Result := 'Функция ';
end;

class function TFunctionFrame.GetFunctionIdEx(Id: Integer): integer;
begin
  Result := id;
end;

procedure TFunctionFrame.InsertCodeTemplate;
var
  s, st, se: string;
  iPos: integer;
begin
  s:= gsFunctionSynEdit.WordAtCursor;
  st:= TfrmGedeminProperty(GetParentForm(Self)).GetCodeTemplate(s);
  if s <> st then begin
    if Pos(#13#10, st) > 0 then begin
      s:= '';
      se:= StringOfChar(' ', gsFunctionSynEdit.WordStart.x - 1);
      while Pos(#13#10, st) > 0 do begin
        s:= s + System.Copy(st, 1, Pos(#13#10, st) + 1);
        System.Delete(st, 1, Pos(#13#10, st) + 1);
        if st <> '' then
          st:= se + st;
      end;
      st:= s + st;
    end;
    iPos:= Pos('|', st);
    if iPos > 0 then
      System.Delete(st, iPos, 1);
    if gsFunctionSynEdit.CaretX = gsFunctionSynEdit.WordStart.x then
      gsFunctionSynEdit.CaretX:= gsFunctionSynEdit.CaretX + 1
    else if gsFunctionSynEdit.CaretX = gsFunctionSynEdit.WordEnd.x then
      gsFunctionSynEdit.CaretX:= gsFunctionSynEdit.CaretX - 1;
    gsFunctionSynEdit.SetSelWord;
    iPos:= gsFunctionSynEdit.SelStart + iPos;
    gsFunctionSynEdit.SelText:= st;
    gsFunctionSynEdit.SelStart:= iPos - 1;
    gsFunctionSynEdit.SelEnd:= gsFunctionSynEdit.SelStart;
  end;
end;

destructor TFunctionFrame.Destroy;
begin
  FreeAndNil(HistoryFrame);
  inherited;
end;

{ TDebugSupportPlugin }

procedure TDebugSupportPlugin.AfterPaint(ACanvas: TCanvas; AClip: TRect;
  FirstLine, LastLine: integer);
begin
end;

function TDebugSupportPlugin.IsExecuteScript: Boolean;
begin
  Result := _IsExecutedScript(FunctionKey);
end;

procedure TDebugSupportPlugin.LinesDeleted(FirstLine, Count: integer);
var
  I: Integer;
begin
  if not Assigned(Debugger) then Exit;

  FDebugLines.Checksize(FirstLine + Count);

  for I := FirstLine + Count - 1 downto FirstLine do
    FDebugLines.Delete(I);

  if IsExecuteScript then
  begin
    Debugger.ExecuteDebugLines.CheckSize(FirstLine + Count);
    for I := FirstLine + Count - 1 downto FirstLine do
      Debugger.ExecuteDebugLines.Delete(I);
  
    if Debugger.CurrentLine >= FirstLine - 1 then
      Debugger.CurrentLine := Debugger.CurrentLine - Count;
  end;

  for I := BreakPointList.Count - 1 downto 0 do
  begin
    if (BreakPointList[I].FunctionKey = FFunctionKey) and
      (BreakPointList[I].Line >= FirstLine + 1) then
    begin
      if BreakPointList[I].Line <= FirstLine + Count + 1 then
        BreakPointList.Remove(BreakPointList[I])
      else
        BreakPointList[I].Line := BreakPointList[I].Line - Count;
    end;
  end;

  if Editor <> nil then
    Editor.InvalidateGutter;
end;

procedure TDebugSupportPlugin.LinesInserted(FirstLine, Count: integer);
var
  I: Integer;
begin
  if not Assigned(Debugger) then
    Exit;

  FDebugLines.Checksize(FirstLine);

  for I := FirstLine - 1 to FirstLine + Count - 2 do
    FDebugLines.Insert(I, []);

  if IsExecuteScript then
  begin
    Debugger.ExecuteDebugLines.CheckSize(FirstLine);
    for I := FirstLine - 1 to FirstLine + Count - 2 do
      Debugger.ExecuteDebugLines.Insert(I, []);

    if Debugger.CurrentLine >= FirstLine - 1 then
      Debugger.CurrentLine := Debugger.CurrentLine + Count;
  end;

  for I := 0 to BreakPointList.Count - 1 do
  begin
    if (BreakPointList[I].FunctionKey = FFunctionKey) and
      (BreakPointList[I].Line >= FirstLine) then
      BreakPointList[I].Line := BreakPointList[I].Line + Count;
  end;

  if Editor <> nil then
    Editor.InvalidateGutter;
end;

procedure TDebugSupportPlugin.SetDebugLines(const Value: TDebugLines);
begin
  FDebugLines := Value;
end;

procedure TDebugSupportPlugin.SetFunctionKey(const Value: Integer);
begin
  FFunctionKey := Value;
end;

{ TErrorListSuppurtPlugin }

procedure TErrorListSuppurtPlugin.AfterPaint(ACanvas: TCanvas;
  AClip: TRect; FirstLine, LastLine: integer);
begin
end;

procedure TErrorListSuppurtPlugin.LinesDeleted(FirstLine, Count: integer);
var
  I: Integer;
begin
  if FErrorListView <> nil then
  begin
    for I := 0 to FErrorListView.Items.Count - 1 do
    begin
      if TObject(FErrorListView.Items[I].Data) is TCustomMessageItem then
      begin
        if (FFunctionKey = TCustomMessageItem(FErrorListView.Items[I].Data).FunctionKey) then
        begin
          if TCustomMessageItem(FErrorListView.Items[I].Data).Line >=
            FirstLine then
          begin
            if TCustomMessageItem(FErrorListView.Items[I].Data).Line >
              FirstLine + Count then
              TCustomMessageItem(FErrorListView.Items[I].Data).Line :=
                TCustomMessageItem(FErrorListView.Items[I].Data).Line - Count
            else
              TCustomMessageItem(FErrorListView.Items[I].Data).Line := - 1;
          end;
        end;
      end;
    end;
  end;
end;

procedure TErrorListSuppurtPlugin.LinesInserted(FirstLine, Count: integer);
var
  I: Integer;
begin
  if FErrorListView <> nil then
  begin
    for I := 0 to FErrorListView.Items.Count - 1 do
    begin
      if TObject(FErrorListView.Items[I].Data) is TCustomMessageItem then
      begin
        if (FFunctionKey = TCustomMessageItem(FErrorListView.Items[I].Data).FunctionKey) then
        begin
          if TCustomMessageItem(FErrorListView.Items[I].Data).Line >=
            FirstLine then
            TCustomMessageItem(FErrorListView.Items[I].Data).Line :=
              TCustomMessageItem(FErrorListView.Items[I].Data).Line + Count;
        end;
      end;
    end;
  end;
end;

procedure TErrorListSuppurtPlugin.SetErrorListView(const Value: TListView);
begin
  FErrorListView := Value;
end;

procedure TFunctionFrame.SynCompletionProposalExecute(
  Kind: SynCompletionType; Sender: TObject; var AString: String; x,
  y: Integer; var CanExecute: Boolean);
var
  Str: String;
  Script: TStrings;
//  I, P: Integer;
begin
  CanExecute := False;
  if Assigned(VBProposal) then
  begin
    ParserInit;
    Str := gsFunctionSynEdit.LineText;
    Str := GetStatament(Str, gsFunctionSynEdit.CaretX);

    Script := TStringList.Create;
    try
      Script.Assign(gsFunctionSynEdit.Lines);
      VBProposal.PrepareScript(Str, Script, gsFunctionSynEdit.CaretY);
    finally
      Script.Free;
    end;
    SynCompletionProposal.ItemList.Assign(VBProposal.ItemList);
    SynCompletionProposal.InsertList.Assign(VBProposal.InsertList);
    CanExecute := SynCompletionProposal.ItemList.Count > 0;
  end;
end;

procedure TFunctionFrame.gsFunctionSynEditSpecialLineColors(
  Sender: TObject; Line: Integer; var Special: Boolean; var FG,
  BG: TColor);
var
  LI: TDebuggerLineInfos;
  BreakPoint: TBreakPoint;
begin
  if not (Assigned(Debugger) and (gsFunctionSynEdit.Highlighter is
    TSynVBScriptSyn)) then Exit;

  FDebugLines.CheckSize(gsFunctionSynEdit.Lines.Count);
  LI := FDebugLines[Line - 1];
  BreakPoint := BreakPointList.BreakPoint(gdcFunction.FieldByName(fnId).asInteger,
    Line);
  if (Debugger.CurrentLine = Line - 1) and IsExecuteScript then
  begin
    Special := TRUE;
    FG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).ExecutionPointAttri.Foreground;
    BG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).ExecutionPointAttri.Background;
  end else
  if BreakPoint <> nil then
  begin
    Special := TRUE;
    if (PropertySettings.DebugSet.UseDebugInfo) and (BreakPoint.Enabled) then
    begin
      if (dlExecutableLine in LI) or not IsExecuteScript then
      begin
        FG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).EnableBreakPointAttri.Foreground;
        BG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).EnableBreakPointAttri.Background;
      end else
      begin
        FG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).InvalidBreakPointAttri.Foreground;
        BG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).InvalidBreakPointAttri.Background;
      end
    end else
    begin
      BG := clLime;
      FG := clRed;
    end;
  end;
  if FDebugLines.ErrorLine = Line - 1{dlErrorLine in LI} then
  begin
    Special := True;
    FG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).ErrorLineAttri.Foreground;
    BG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).ErrorLineAttri.Background;
  end;
end;

procedure TFunctionFrame.gsFunctionSynEditGutterClick(Sender: TObject; X,
  Y, Line: Integer; mark: TSynEditMark);
begin
  if GetAsyncKeyState(VK_LBUTTON) > 0 then
    ToggleBreakpoint(Line)
end;

procedure TFunctionFrame.gsFunctionSynEditCommandProcessed(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
begin
  case Command of
    ecLeft .. ecGotoXY, ecSelLeft..ecSelGotoXY, ecGotoMarker0..ecGotoMarker9,
    ecDeleteLastChar..ecString:
    begin
//      FNeedSave := True;
      //Изменяем инфр. о положении курсора
      if Assigned(OnCaretPosChange) then
      begin
        FOnCaretPosChange(gsFunctionSynEdit, gsFunctionSynEdit.CaretX,
          gsFunctionSynEdit.CaretY);
      end;
    end;
    ecFind: Find;
    ecReplace: Replace;
    ecFindNext:
    begin
      FFindNext := True;
      if FFinding then DoFind else DoReplace;
    end;
    ecComentBlock: ChangeCommentBlock(prpComment);
    ecUnComentBlock: ChangeCommentBlock(prpUnComment);
    ecCodeTemplate: InsertCodeTemplate;
  end;
end;

procedure TFunctionFrame.gsFunctionSynEditPlaceBookmark(Sender: TObject;
  var Mark: TSynEditMark);
begin
  FNeedSave := True;
end;

procedure TFunctionFrame.gsFunctionSynEditProcessCommand(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
begin
  Case Command of
    ecLeft .. ecGotoXY, ecSelLeft..ecSelGotoXY, ecGotoMarker0..ecGotoMarker9,
    ecDeleteLastChar..ecString:
    begin
      if (FDebugLines.ErrorLine > - 1) then
        FDebugLines.ErrorLine := -1;
    end;
    ecCodeComplite: ParserInit;
  end;
end;

procedure TFunctionFrame.gdcFunctionAfterEdit(DataSet: TDataSet);
var
  Str: TStream;
begin
  inherited;
  FDebugPlugin.FunctionKey := gdcFunction.FieldByName(fnId).AsInteger;
  FErrorListSuppurtPlugin.FunctionKey := gdcFunction.FieldByName(fnId).AsInteger;
  edtRUIDFunction.Text:= gdcBaseManager.GetRUIDStringByID(gdcFunction.ID);
//  LoadBreakPoints;
//  UpdateEdidor;
  //Считываем параметры
  try
    if not gdcFunction.FieldByName(fnEnteredParams).IsNull then
    begin
      Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmRead);
      try
        FFunctionParams.Clear;
        FFunctionParams.LoadFromStream(Str);
      finally
        Str.Free;
      end;
    end else
      FFunctionParams.Clear;
  except
    MessageBox(Application.Handle, 'Данные параметров были повреждены. Их следует переопределить.',
      MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
  end;
end;

procedure TFunctionFrame.gsFunctionSynEditPaintGutter(AClip: TRect;
  FirstLine, LastLine: Integer);
var
  LI: TDebuggerLineInfos;
  LH, X, Y: integer;
  ImgIndex: integer;
  BreakPoint: TBreakPoint;
begin
  if not (Assigned(Debugger) and (gsFunctionSynEdit.Highlighter is
    TSynVBScriptSyn)) then Exit;
  //Проверяем размер. На всякий случай
  FDebugLines.CheckSize(gsFunctionSynEdit.Lines.Count);
  if FDebugLines.Count >= gsFunctionSynEdit.Lines.Count then
  begin
    X := 14;
    LH := gsFunctionSynEdit.LineHeight;
    Y := (LH - dmImages.imglGutterGlyphs.Height) div 2
      + LH * (FirstLine - gsFunctionSynEdit.TopLine);
    while FirstLine <= LastLine do
    begin
      LI := FDebugLines[FirstLine - 1];
      if (Debugger.CurrentLine = FirstLine - 1) and
        IsExecuteScript then
      begin
        BreakPoint := BreakpointList.BreakPoint(gdcFunction.FieldByName(fnid).AsInteger,
          FirstLine);
        if BreakPoint <> nil then
          ImgIndex := 2
        else
          ImgIndex := 1;
      end else
      if dlExecutableLine in LI then
      begin
        BreakPoint := BreakpointList.BreakPoint(gdcFunction.FieldByName(fnid).AsInteger,
          FirstLine);
        if BreakPoint <> nil then
          if (PropertySettings.DebugSet.UseDebugInfo) and
            BreakPoint.Enabled then
            ImgIndex := 3
          else
            ImgIndex := 5
        else
          ImgIndex := 0;
        if FDebugLines.ErrorLine = FirstLine - 1 then
          ImgIndex := 0;
      end else
      begin
        BreakPoint := BreakpointList.BreakPoint(gdcFunction.FieldByName(fnid).AsInteger,
          FirstLine);
        if BreakPoint <> nil then
        begin
          if (PropertySettings.DebugSet.UseDebugInfo) and BreakPoint.Enabled then
          begin
            if not IsExecuteScript then
              ImgIndex := 3
            else
              ImgIndex := 4
          end else
            ImgIndex := 5
        end else
          ImgIndex := -1;
      end;
      if ImgIndex >= 0 then
        dmImages.imglGutterGlyphs.Draw(gsFunctionSynEdit.Canvas, X, Y, ImgIndex);
      Inc(FirstLine);
      Inc(Y, LH);
    end;
  end;
end;


procedure TFunctionFrame.dbeNameChange(Sender: TObject);
begin
  inherited;
  UpdateNameColor;
end;

procedure TFunctionFrame.actReplaceExecute(Sender: TObject);
begin
{  if gsFunctionSynEdit.SelAvail then
    ReplaceDialog.FindText := gsFunctionSynEdit.SelText
  else
    ReplaceDialog.FindText := gsFunctionSynEdit.WordAtCursor;
  ReplaceDialog.Execute;}
  Replace;
end;

procedure TFunctionFrame.ReplaceDialogReplace(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
begin
  sSearch := ReplaceDialog.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Application.Handle, MSG_REPLACE_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  end else
  begin
    rOptions := [ssoReplace];
    if frMatchCase in ReplaceDialog.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in ReplaceDialog.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in ReplaceDialog.Options then
      Include(rOptions, ssoReplaceAll);
    if gsFunctionSynEdit.SelAvail then
      Include(rOptions, ssoSelectedOnly);
    if gsFunctionSynEdit.SearchReplace(sSearch, ReplaceDialog.ReplaceText, rOptions) = 0 then
    begin
      Beep;
      MessageBox(Application.Handle, PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_REPLACE),
       MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    end;
  end;
end;

procedure TErrorListSuppurtPlugin.SetFunctionKey(const Value: Integer);
begin
  FFunctionKey := Value;
end;

procedure TFunctionFrame.gsFunctionSynEditProcessUserCommand(
  Sender: TObject; var Command: TSynEditorCommand; var AChar: Char;
  Data: Pointer);
begin
  case Command of
    ecGotoToInclude: GotoToInclude;
  end;
end;

procedure TFunctionFrame.actRunExecute(Sender: TObject);
begin
  Run(sfUnknown);
end;

procedure TFunctionFrame.actRunUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanRun;
end;

procedure TFunctionFrame.actPrepareUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanPrepare;
end;

procedure TFunctionFrame.actPrepareExecute(Sender: TObject);
begin
  Prepare;
end;

procedure TFunctionFrame.actCopyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanCopy;
end;

procedure TFunctionFrame.actCopyExecute(Sender: TObject);
begin
  Copy;
end;

procedure TFunctionFrame.actCutUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanCut;
end;

procedure TFunctionFrame.actCutExecute(Sender: TObject);
begin
  Cut;
end;

procedure TFunctionFrame.actPasteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanPaste and
    (Clipboard.HasFormat(SynEditClipboardFormat) or Clipboard.HasFormat(CF_TEXT));
end;

procedure TFunctionFrame.actPasteExecute(Sender: TObject);
begin
  Paste;
end;

procedure TFunctionFrame.actCopySQLUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanCopySQL;
end;

procedure TFunctionFrame.actCopySQLExecute(Sender: TObject);
begin
  CopySQL;
end;

procedure TFunctionFrame.actPasteSQLUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanPasteSQL;
end;

procedure TFunctionFrame.actPasteSQLExecute(Sender: TObject);
begin
  PasteSQL;
end;

procedure TFunctionFrame.gdcFunctionAfterInsert(DataSet: TDataSet);
begin
  inherited;
  FDebugPlugin.FunctionKey := gdcFunction.FieldByName(fnId).AsInteger;
  FErrorListSuppurtPlugin.FunctionKey := gdcFunction.FieldByName(fnId).AsInteger;
  FFunctionParams.Clear;
//  UpdateEdidor;
end;

procedure TFunctionFrame.gsFunctionSynEditReplaceText(Sender: TObject;
  const ASearch, AReplace: String; Line, Column: Integer;
  var Action: TSynReplaceAction);
var
  F: TdlgPropertyReplacePromt;
  P: TPoint;
  W: Integer;
begin
  inherited;
  P := gsFunctionSynEdit.RowColumnToPixels(Point(Column, Line));
  P := gsFunctionSynEdit.ClientToScreen(P);
  F := TdlgPropertyReplacePromt.Create(Application);
  try
    F.Label1.Caption := Format('Заменить ''%s'' на ''%s''?', [ASearch, AReplace]);
    W := Screen.Width;
    F.Top := P.Y - 10 - F.Height;
    if F.Top < 0 then
      F.Top := P.Y + 10 + gsFunctionSynEdit.LineHeight;
    F.Left := P.X - F.Left div 2;
    if W < F.Left + F.Width + 10 then
      F.Left := W - 10 - F.Width;
    case F.ShowModal of
      mrYes: Action := raReplace;
      mrNo: Action := raSkip;
      mrCancel: Action := raCancel;
      mrAll: Action := raReplaceAll;
    end;
  finally
    F.Free;
  end;
end;

procedure TFunctionFrame.actCommentExecute(Sender: TObject);
begin
  ChangeCommentBlock(prpComment);
end;

procedure TFunctionFrame.PopupMenuPopup(Sender: TObject);
var
  P: TPoint;
  B: Boolean;
  Line: Integer;
begin
  inherited;
  if gsFunctionSynEdit.SelAvail then
  begin
    actComment.Enabled := True;
    actUnComment.Enabled := True;
  end else
    begin
      actComment.Enabled := False;
      actUnComment.Enabled := False;
    end;

  P := gsFunctionSynEdit.ScreenToClient(TCreckPopupMenu(Sender).PopupPoint);
  Line := gsFunctionSynEdit.PixelsToRowColumn(P).Y;
  FBreakPoint := BreakPointList.BreakPoint(gdcFunction.FieldByName(fnId).AsInteger,
     Line);
  B := (P.x < gsFunctionSynEdit.Gutter.Width) and (FBreakPoint <> nil);
  miSeparator.Visible := B;
  miPropertyBreakPoint.Visible := B;
  miEnableBreakPoint.Visible := B;
end;

procedure TFunctionFrame.actUnCommentExecute(Sender: TObject);
begin
  ChangeCommentBlock(prpUnComment);
end;

procedure TFunctionFrame.dbeNameExit(Sender: TObject);
begin
  if NewNameUpdate then
    inherited;
end;

procedure TFunctionFrame.dbeNameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if Key = 13 then
    if NewNameUpdate then
      dbeName.SetFocus;
end;

procedure TFunctionFrame.dbeNameDblClick(Sender: TObject);
begin
  inherited;
  if NewNameUpdate then
    dbeName.SetFocus;
end;

procedure TFunctionFrame.actCopyToRTFExecute(Sender: TObject);
begin
  inherited;
  CopyToRTFClipboart;
end;

procedure TFunctionFrame.actFindExecute(Sender: TObject);
begin
  Find;
end;

procedure TFunctionFrame.gdcFunctionAfterDelete(DataSet: TDataSet);
begin
  inherited;

  //Т.к. проседуры удаления функции в glbFunctionList нет
  //то очищаем список
  if FOldFunctionKey <> 0 then
    glbFunctionList.RemoveFunction(FOldFunctionKey)
  else
    glbFunctionList.UpdateList;
  ScriptFactory.Reset;
end;

procedure TFunctionFrame.OnShowHint(var HintStr: String;
  var CanShow: Boolean; var HintInfo: THintInfo);
var
  p: TPoint;
  RowColumn: TPoint;
  Str, Eval: String;
  BeginPos, EndPos: Integer;
  B: TBreakPoint;
  Line: Integer;
begin
  inherited;
  if HintInfo.HintControl = gsFunctionSynEdit then
  begin
    p := HintInfo.CursorPos;
    if Assigned(Debugger) and (Debugger.IsPaused) then
    begin
      if (P.x > gsFunctionSynEdit.Gutter.Width) and (P.y > 0) and
        (P.X < gsFunctionSynEdit.Width) and (P.Y < gsFunctionSynEdit.Height) then
      begin
        if gsFunctionSynEdit.SelAvail then
        begin
          Str := gsFunctionSynEdit.SelText;
        end else
        begin
          RowColumn := gsFunctionSynEdit.PixelsToRowColumn(P);
          Str := gsFunctionSynEdit.Lines[RowColumn.y - 1];
          Str := Trim(GetCompliteStatament(Str, RowColumn.X, BeginPos, EndPos));

          HintInfo.CursorRect.TopLeft := gsFunctionSynEdit.RowColumnToPixels(Point(BeginPos,
             RowColumn.Y));
          HintInfo.CursorRect.BottomRight := gsFunctionSynEdit.RowColumnToPixels(Point(EndPos,
             RowColumn.Y + 1));

          P := gsFunctionSynEdit.RowColumnToPixels(Point(BeginPos,
            RowColumn.Y + 1));
          P := gsFunctionSynEdit.ClientToScreen(P);

          Str := GetCompliteStatament(Str, 1, BeginPos, EndPos);
        end;

        if Str <> '' then
        begin
          try
            Eval := Debugger.Eval(Str, False);
          except
            Eval := 'Ошибка вычисления';
          end;
          if Eval <> '' then
            HintStr := Format('%s = %s ', [Str, Eval]);
        end;
      end
    end;

    if (P.x < gsFunctionSynEdit.Gutter.Width) and (P.y > 0) and
      (P.X > 0) and (P.Y < gsFunctionSynEdit.Height) then
    begin
      Line := gsFunctionSynEdit.PixelsToRowColumn(P).Y;
      B := BreakPointList.BreakPoint(gdcFunction.FieldByName(fnId).AsInteger,
         Line);
      CanShow := B <> nil;
      if CanShow then
      begin
        HintInfo.CursorRect.TopLeft := gsFunctionSynEdit.RowColumnToPixels(Point(1,
           Line));
        HintInfo.CursorRect.BottomRight := gsFunctionSynEdit.RowColumnToPixels(Point(1,
           Line + 1));
        HintInfo.CursorRect.Left := 1;
        HintInfo.CursorRect.Right := gsFunctionSynEdit.Gutter.Width - 1; 
        HintStr := Format('Condition: %s'#13#10'PassCount: %d of %d',
          [B.Condition, B.ValidPassCount, B.PassCount]);
      end;
    end;
  end;
end;

procedure TFunctionFrame.actEnableBreakPointExecute(Sender: TObject);
begin
  if FBreakPoint <> nil then
  begin
    FBreakPoint.Enabled := not FBreakPoint.Enabled;
    gsFunctionSynEdit.InvalidateLine(FBreakPoint.Line);
    gsFunctionSynEdit.InvalidateGutter;
    FBreakPoint := nil;
    UpdateBreakPointsWindow;
  end;
end;

procedure TFunctionFrame.dbeNameUpdateRecord(Sender: TObject);
begin
  if FCurrentFunctionName = '' then
    FCurrentFunctionName := AnsiUpperCase(Trim(dbeName.Text));
end;

procedure TFunctionFrame.actEnableBreakPointUpdate(Sender: TObject);
begin
  TAction(sender).Enabled := FBreakPoint <> nil;
  if TAction(sender).Enabled then
  begin
    if TAction(sender).Checked <> FBreakPoint.Enabled then
      TAction(sender).Checked := FBreakPoint.Enabled;
  end;
end;

procedure TFunctionFrame.actPropertyBreakPointExecute(Sender: TObject);
var
  F: TdlgBreakPointProperty;
begin
  if FBreakPoint <> nil then
  begin
    F := TdlgBreakPointProperty.Create(Application);
    try
      F.BreakPoint := FBreakPoint;
      F.ShowModal;
    finally
      F.Free;
    end;
    FBreakPoint := nil;
    UpdateBreakPointsWindow;
  end;
end;

procedure TFunctionFrame.actPropertyBreakPointUpdate(Sender: TObject);
begin
  TAction(sender).Enabled := FBreakPoint <> nil;
end;

procedure TFunctionFrame.lbDependentDblClick(Sender: TObject);
begin
  if lbDependent.Items.Count > 0 then
  begin
    TfrmGedeminProperty(GetParentForm(Self)).FindAndEdit(
      Integer(lbDependent.Items.Objects[lbDependent.ItemIndex]));
  end;
end;

procedure TFunctionFrame.FrameResize(Sender: TObject);
begin
  inherited;
  pnlDependent.Width := Round(Self.Width / 2) - 10; 
end;

procedure TFunctionFrame.lbDependedFromDblClick(Sender: TObject);
begin
  if lbDependedFrom.Items.Count > 0 then
  begin
    TfrmGedeminProperty(GetParentForm(Self)).FindAndEdit(
      Integer(lbDependedFrom.Items.Objects[lbDependedFrom.ItemIndex]));
  end;
end;

procedure TFunctionFrame.gdcFunctionAfterOpen(DataSet: TDataSet);
begin
  inherited;
  SetDependencies(sdAll);

end;

procedure TFunctionFrame.actRefreshDependentExecute(Sender: TObject);
begin
  SetDependencies(sdDependent);
end;

procedure TFunctionFrame.actRefreshDependedFromExecute(Sender: TObject);
begin
  SetDependencies(sdDependedFrom);
end;

procedure TFunctionFrame.actTypeInfoExecute(Sender: TObject);
begin
  ShowTypeInfo;
end;

procedure TFunctionFrame.actWizardUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdcFunction.FieldByName('module').AsString = scrEntryModuleName
end;

procedure TFunctionFrame.actWizardExecute(Sender: TObject);
type
  TModule = (mNone, mTrrecord, mHeader, mLine);
var
  SQL, aSQl: TIBSQL;
  FunctionCreator: TCustomNewFunctionCreater;
  Str, PStr: TStream;
  F: TdlgFunctionWisard;
  ScriptChanged: Boolean;
  Module: TModule;
  Id: Integer;
  DidActivate: Boolean;
  Params: TgsParamList;
const
  cwHeader = 'шапка';
  cwLine   = 'позиция';
begin
  Module := mNone;
  Id := 0;
  FunctionCreator := nil;
  SQL := TIBSQL.Create(nil);
  aSQL := TIBSQL.Create(nil);
  Str := TMemoryStream.Create;
  try
    SQL.Transaction := gdcFunction.ReadTransaction;
    aSQL.Transaction := gdcFunction.ReadTransaction;
    SQL.SQl.text := 'SELECT * FROM ac_trrecord WHERE functionkey = :functionkey';
    SQL.ParamByName('functionkey').AsInteger := gdcFunction.Id;
    SQL.ExecQuery;
    if SQL.RecordCount > 0 then
    begin
      //Похоже это тип операция
      aSQL.SQL.text := 'SELECT id FROM ac_autotrrecord WHERE id = :id';
      aSQL.ParamByname(fnid).AsInteger := SQL.FieldByName(fnId).AsInteger;
      aSQL.ExecQuery;
      if aSQL.RecordCount > 0 then
      begin
        aSQL.Close;
        aSQL.SQl.text := 'SELECT * FROM gd_taxactual WHERE trrecordkey = :id';
        aSQL.ParamByName(fnid).AsInteger := SQL.FieldByName(fnId).AsInteger;
        aSQL.ExecQuery;
        if aSQL.RecordCount > 0 then
        begin
          //Похоже это налоги
          FunctionCreator := TNewTaxFunctionCreater.Create;

          TNewTaxFunctionCreater(FunctionCreator).TaxActualRuid := gdcBaseManager.GetRUIDStringByID(aSQL.FieldByName(fnid).AsInteger);
          TNewTaxFunctionCreater(FunctionCreator).TaxNameRuid := gdcBaseManager.GetRUIDStringByID(aSQL.FieldByName(fnTaxNameKey).AsInteger);
          TNewTaxFunctionCreater(FunctionCreator).TransactionRUID := gdcBaseManager.GetRUIDStringByID(SQL.FieldByName(fnTransactionKey).AsInteger);
          TNewTaxFunctionCreater(FunctionCreator).TrRecordRUID := gdcBaseManager.GetRUIDStringByID(SQL.FieldByName(fnID).AsInteger);
          TNewTaxFunctionCreater(FunctionCreator).CardOfAccountRUID := gdcBaseManager.GetRuidStringById(SQL.FieldByName(fnAccountKey).AsInteger);
        end else
        begin
          FunctionCreator := TNewEntryFunctionCreater.Create;

          TNewEntryFunctionCreater(FunctionCreator).TransactionRUID := gdcBaseManager.GetRUIDStringByID(SQL.FieldByName(fnTransactionKey).AsInteger);
          TNewEntryFunctionCreater(FunctionCreator).TrRecordRUID := gdcBaseManager.GetRUIDStringByID(SQL.FieldByName(fnID).AsInteger);
          TNewEntryFunctionCreater(FunctionCreator).CardOfAccountRUID := gdcBaseManager.GetRuidStringById(SQL.FieldByName(fnAccountKey).AsInteger);
        end;
      end else
      begin
        FunctionCreator := TNewTrEntryFunctionCreater.Create;

        TNewTrEntryFunctionCreater(FunctionCreator).TransactionRUID := gdcBaseManager.GetRUIDStringByID(SQL.FieldByName(fnTransactionkey).AsInteger);
        TNewTrEntryFunctionCreater(FunctionCreator).TrRecordRUID := gdcBaseManager.GetRUIDStringByID(SQL.FieldByName(fnId).AsInteger);
        TNewTrEntryFunctionCreater(FunctionCreator).CardOfAccountRUID := gdcBaseManager.GetRuidStringById(SQL.FieldByName(fnAccountKey).AsInteger);
        TNewTrEntryFunctionCreater(FunctionCreator).DocumentRUID := gdcBaseManager.GetRUIDStringByID(SQL.FieldByName(fnDocumentTypeKey).AsInteger);
        TNewTrEntryFunctionCreater(FunctionCreator).SaveEmpty := SQL.FieldByName(fnIsSaveNull).AsInteger = 1;
        if SQL.FieldByName(fnDocumentPart).AsString = cwHeader then
          TNewTrEntryFunctionCreater(FunctionCreator).DocumentPart := dcpHeader
        else
          TNewTrEntryFunctionCreater(FunctionCreator).DocumentPart := dcpLine;
      end;

      SQL.FieldByName(fnFunctionTemplate).SaveToStream(Str);
      Module := mTrrecord;
      Id := SQL.FieldByName(fnId).AsInteger;
    end else
    begin
      aSQl.SQL.text := 'SELECT id, headerfunctiontemplate as Templ, CAST(''header'' as VarChar(10)) as doctype FROM gd_documenttype WHERE headerfunctionkey = :functionkey ' +
        'UNION ALL SELECT id, linefunctiontemplate as Templ, CAST(''line''as VarChar(10)) as doctype FROM gd_documenttype WHERE linefunctionkey = :functionkey ';
      aSQL.ParamByName('functionkey').AsInteger := gdcFunction.id;
      aSQL.ExecQuery;
      if aSQl.RecordCount > 0 then
      begin
        FunctionCreator := TNewDocumentTransactioCreater.Create;
        TNewDocumentTransactioCreater(FunctionCreator).DocumentTypeRUID :=
          gdcBaseManager.GetRUIDStringById(aSQL.FieldByName(fnId).AsInteger);
        if aSQL.FieldByName('doctype').AsString = 'header' then
        begin
          TNewDocumentTransactioCreater(FunctionCreator).DocumentPart := dcpHeader;
          Module := mHeader;
        end else
        begin
          TNewDocumentTransactioCreater(FunctionCreator).DocumentPart := dcpLine;
          Module := mLine;
        end;

        aSQL.FieldByName('templ').SaveToStream(Str);
        Id := aSQL.FieldByName(fnID).AsInteger;
      end;
    end;

    if FunctionCreator <> nil then
    begin
      Str.Position := 0;

      FunctionCreator.Stream := Str;
      FunctionCreator.FunctionName := gdcFunction.FieldByName(fnName).AsString;
      FunctionCreator.FunctionRUID := RUIDToStr(gdcFunction.GetRUID);

      F := TdlgFunctionWisard.Create(Application);
      try
        F.CreateNewFunction(FunctionCreator);

        ScriptChanged := F.ShowModal = mrOk;
        if ScriptChanged then
        begin
          SQL.Close;
          SQl.Transaction := gdcFunction.Transaction;
          DidActivate := not gdcFunction.Transaction.InTransaction;
          if DidActivate then
            gdcFunction.Transaction.StartTransaction;
          try
            case Module of
              mTrrecord:
              begin
                SQL.SQL.Text := 'UPDATE ac_trrecord SET functiontemplate = :functiontemplate WHERE id = :id';
              end;
              mHeader:
              begin
                SQL.SQL.Text := 'UPDATE gd_documenttype SET headerfunctiontemplate = :functiontemplate WHERE id = :id';
              end;
              mLine:
              begin
                SQL.SQL.Text := 'UPDATE gd_documenttype SETlinefunctiontemplate = :functiontemplate WHERE id = :id';
              end;
            end;

            Str.Size := 0;
            F.SaveToStream(Str);
            Str.Position := 0;

            SQL.ParamByName(fnFunctionTemplate).LoadFromStream(Str);
            SQL.ParamByName(fnId).AsInteger := Id;

            SQl.ExecQuery;

            if DidActivate then
              gdcFunction.Transaction.Commit;

            gdcFunction.FieldByName(fnScript).AsString := F.Script;
            gdcFunction.FieldByName(fnName).AsString := F.MainFunctionName;
            Params := TgsParamList.Create;
            try
              Params.Assign(F.Params);
              PStr := gdcFunction.CreateBlobStream(gdcFunction.FieldByName(fnEnteredParams), DB.bmWrite);
              try
                Pstr.Size := 0;
                PStr.Position := 0;
                Params.SaveToStream(PStr);
              finally
                PStr.Free;
              end;
            finally
              Params.Free;
            end;
            Modify := True;
          except
            if DidActivate then
              gdcFunction.Transaction.RollBack;
          end;
        end;
      finally
        F.Free;
      end;
    end;
  finally
    SQL.Free;
    aSQL.Free;
    Str.Free
  end;
end;

procedure TFunctionFrame.btnCopyRUIDFunctionClick(Sender: TObject);
begin
  Clipboard.AsText:= edtRUIDFunction.Text;
end;

procedure TFunctionFrame.pMainResize(Sender: TObject);
begin
  edtRUIDFunction.Width:= pMain.ClientWidth - edtRUIDFunction.Left - 87;
  pnlRUIDFunction.Left:= edtRUIDFunction.Left + edtRUIDFunction.Width + 2;
  pnlRUIDFunction.Width:= 75;
end;

procedure TFunctionFrame.gdcDelphiObjectAfterScroll(DataSet: TDataSet);
begin
  FOldName:= gdcFunction.FieldByName('name').AsString;
end;

procedure TFunctionFrame.actExternalEditorExecute(Sender: TObject);
begin
  InvokeExternalEditor('vb', gsFunctionSynEdit.Lines);
end;

initialization
  RegisterClass(TFunctionFrame);
finalization
  UnRegisterClass(TFunctionFrame);
end.
