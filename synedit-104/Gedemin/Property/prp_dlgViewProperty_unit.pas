unit prp_dlgViewProperty_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, TypInfo, ImgList, StdCtrls, evt_Base,
  mtd_Base, rp_BaseReport_unit, TB2Dock, TB2Toolbar, SynCompletionProposal,
  SynHighlighterJScript, SynEditHighlighter, SynHighlighterVBScript,
  SynEdit, SynDBEdit, DBCtrls, Db, IBCustomDataSet, DBClient,
  IBDatabase, Contnrs, prm_ParamFunctions_unit, ActnList, IBSQL, IBQuery,
  Menus, TB2Item, scrReportGroup, scrMacrosGroup, prp_i_VBProposal,
  Buttons,  gdcDelphiObject, evt_i_Base, mtd_i_Base, gdcEvent, gdcFunction,
  gdcTemplate, gdcReport, gdcMacros, rp_report_const, gd_ClassList,
  VBParser, obj_i_Debugger, gd_createable_form, prp_dlgEvaluate_unit, SynEditKeyCmds,
  prp_MessageConst, gdcTree, Mask, gdcBase, gsFunctionSyncEdit, gdc_createable_form,
  prp_dlg_PropertySettings_unit, ActiveX, AppEvnts, prp_PropertySettings,
  prp_Messages, StdActns, TB2ToolWindow, FR_Dock, gdcBaseInterface,
  gdcCustomFunction;

type
  sfTypes = (sfMacros, sfReport, sfEvent, sfMethod, sfUnknown);
type
  TFunctionPages = (fpMacrosFolder, fpReportFolder, fpVBClassGroup,
    fpScriptFunctionGroup, fpConstGroup, fpGlobalObjectGroup,
    fpMethodClass, fpEventObject, fpReport, fpMacros, fpReportFunction,
    fpReportTemplate, fpEvent, fpMethod, fpScriptFunction, fpVBClass,
    fpConst, fpGlobalObject, fpNone);
type
  PHistoryNote = ^THistoryNote;
  THistoryNote = record
    Node: TTreeNode;
    CarretPos: TPoint;
  end;

  THistory = class(TList)
  private
    FPosition: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    function Add(Note: THistoryNote): Integer;
    function IsBegin: Boolean;
    function IsEnd: Boolean;
    function Previous(var Note: THistoryNote): Boolean;
    function Next(out Note: THistoryNote): Boolean;
    function GotoPosition(Index: Integer): THistoryNote;
    procedure Clear; override;
    procedure Delete(Index: Integer);

    property Position: Integer read FPosition;
  end;

{ TGutterMarkDrawPlugin }

type
  TDebugSupportPlugin = class(TSynEditPlugin)
  private
    FImages: TImageList;
    procedure SetImages(const Value: TImageList);
  protected
    procedure AfterPaint(ACanvas: TCanvas; AClip: TRect;
      FirstLine, LastLine: integer); override;
    procedure LinesInserted(FirstLine, Count: integer); override;
    procedure LinesDeleted(FirstLine, Count: integer); override;
    function IsExecuteScript: Boolean;
  public
    property Images: TImageList read FImages write SetImages;
  end;

  TErrorListSuppurtPlugin = class(TSynEditPlugin)
  private
    FErrorListView: TListView;
    procedure SetErrorListView(const Value: TListView);
  protected
    procedure AfterPaint(ACanvas: TCanvas; AClip: TRect;
      FirstLine, LastLine: integer); override;
    procedure LinesInserted(FirstLine, Count: integer); override;
    procedure LinesDeleted(FirstLine, Count: integer); override;
  public
    property ErrorListView: TListView read FErrorListView write SetErrorListView;
  end;

type
  TPropertyViewState = (psRefreshTree);
  TPropertyViewStates = set of TPropertyViewState;
type
  TdlgViewProperty = class(TCreateableForm)
    imTreeView: TImageList;
    SynVBScriptSyn1: TSynVBScriptSyn;
    SynJScriptSyn1: TSynJScriptSyn;
    imSynEdit: TImageList;
    imFunction: TImageList;
    ibtrFunction: TIBTransaction;
    ActionList1: TActionList;
    actFuncCommit: TAction;
    actFuncRollback: TAction;
    ibsqlInsertEvent: TIBSQL;
    ibqrySetFunction: TIBQuery;
    dsSetFunction: TDataSource;
    OpenDialog1: TOpenDialog;
    actLoadFromFile: TAction;
    SaveDialog1: TSaveDialog;
    actSaveToFile: TAction;
    actCompile: TAction;
    actSQLEditor: TAction;
    actFind: TAction;
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;
    actReplace: TAction;
    actCopyText: TAction;
    actPaste: TAction;
    actOptions: TAction;
    pmdbseScript: TPopupMenu;
    actCompile1: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    actFuncCommit1: TMenuItem;
    actFuncRollback1: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    dsFunction: TDataSource;
    gdcDelphiObject: TgdcDelphiObject;
    imMainTool: TImageList;
    gdcFunction: TgdcFunction;
    gdcEvent: TgdcEvent;
    dsTemplate: TDataSource;
    cdsTemplateType: TClientDataSet;
    cdsTemplateTypeTemplateType: TStringField;
    cdsTemplateTypeDescriptionType: TStringField;
    dsTemplateType: TDataSource;
    gdcMacros: TgdcMacros;
    ActionList2: TActionList;
    actAddMacros: TAction;
    actAddFolder: TAction;
    actDeleteFolder: TAction;
    actDeleteMacros: TAction;
    actRename: TAction;
    actAddReport: TAction;
    actDeleteReport: TAction;
    actCutTreeItem: TAction;
    actPasteTreeItem: TAction;
    actCopyTreeItem: TAction;
    pmtvClasses: TPopupMenu;
    actAddFolder1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    N6: TMenuItem;
    gdcMacrosGroup: TgdcMacrosGroup;
    gdcReport: TgdcReport;
    gdcReportGroup: TgdcReportGroup;
    gdcTemplate: TgdcTemplate;
    dsReport: TDataSource;
    dsMacros: TDataSource;
    dsTemplate1: TDataSource;
    dsReportServer: TDataSource;
    ibqryReportServer: TIBQuery;
    ibqryTemplate: TIBQuery;
    dsDescription: TDataSource;
    actEditTemplate: TAction;
    actAddScriptFunction: TAction;
    actDeleteScriptFunction: TAction;
    actRefresh: TAction;
    SynCompletionProposal: TSynCompletionProposal;
    actExecReport: TAction;
    actFindInTree: TAction;
    actExpand: TAction;
    actUnExpand: TAction;
    N23: TMenuItem;
    N24: TMenuItem;
    N25: TMenuItem;
    ibtrObject: TIBTransaction;
    actPrev: TAction;
    actNext: TAction;
    pmHistory: TPopupMenu;
    actPrepare: TAction;
    imglGutterGlyphs: TImageList;
    actOnlySpecEvent: TAction;
    actAutoSave: TAction;
    actAddVBClass: TAction;
    actDeleteVBClass: TAction;
    actDeleteEvent: TAction;
    N28: TMenuItem;
    actDeleteUnusedMethods: TAction;
    actDeleteUnUsedEvents: TAction;
    actSaveHist: TAction;
    actSettings: TAction;
    actAddItem: TAction;
    actDeleteItem: TAction;
    actAddConst: TAction;
    actAddGlobalObject: TAction;
    imglActions: TImageList;
    actlDebug: TActionList;
    actDebugRun: TAction;
    actDebugStepIn: TAction;
    actDebugGotoCursor: TAction;
    actDebugPause: TAction;
    actToggleBreakpoint: TAction;
    actDebugStepOver: TAction;
    actProgramReset: TAction;
    actEvaluate: TAction;
    N5: TMenuItem;
    N14: TMenuItem;
    actDisableMethod: TAction;
    pmSpeedReturn: TPopupMenu;
    actSpeedReturn: TAction;
    Timer: TTimer;
    PopupEval: TSynCompletionProposal;
    FindInTreeDialog: TFindDialog;
    pmMessages: TPopupMenu;
    ActionList3: TActionList;
    actClearSearchResult: TAction;
    actClearErrorResult: TAction;
    N15: TMenuItem;
    N16: TMenuItem;
    actFindFunction: TAction;
    actDeleteReportFunction: TAction;
    dsOwner: TDataSource;
    ibqOwner: TIBQuery;
    pnlButtons: TPanel;
    Button1: TButton;
    Button2: TButton;
    pnlParam: TPanel;
    Splitter1: TSplitter;
    pcFuncParam: TPageControl;
    tsReport: TTabSheet;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label4: TLabel;
    DBText1: TDBText;
    dbeFrqRefresh: TDBEdit;
    dbcbSaveResult: TDBCheckBox;
    dbmDescription: TDBMemo;
    dbcbIsLocalExecute: TDBCheckBox;
    dbcbPreview: TDBCheckBox;
    dbcbReportServer: TDBLookupComboBox;
    tsDescription: TTabSheet;
    dbmGroupDescription: TDBMemo;
    tsFunction: TTabSheet;
    pcFunction: TPageControl;
    tsFuncMain: TTabSheet;
    pMacrosAddParams: TPanel;
    Label1: TLabel;
    Label7: TLabel;
    dblcbMacrosServer: TDBLookupComboBox;
    DBCheckBox1: TDBCheckBox;
    DBCheckBox2: TDBCheckBox;
    hkMacros: THotKey;
    Panel2: TPanel;
    Label12: TLabel;
    Label11: TLabel;
    Label6: TLabel;
    lFunctionID: TLabel;
    dbtFunctionID: TDBText;
    dbtOwner: TDBText;
    Label8: TLabel;
    dbeFunctionName: TDBEdit;
    DBMemo1: TDBMemo;
    dbcbLang: TDBComboBox;
    tsFuncScript: TTabSheet;
    gsFunctionSynEdit: TgsFunctionSynEdit;
    sbFuncEdit: TStatusBar;
    tsParams: TTabSheet;
    ScrollBox1: TScrollBox;
    Label19: TLabel;
    pnlCaption: TPanel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    tsReportTemplate: TTabSheet;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label10: TLabel;
    DBEdit1: TDBEdit;
    dbeDescription: TDBEdit;
    dblcbType: TDBLookupComboBox;
    btnEditTemplate: TButton;
    dblcbTemplate: TDBLookupComboBox;
    TBDock1: TTBDock;
    TBToolbar2: TTBToolbar;
    TBItem20: TTBItem;
    TBItem1: TTBItem;
    TBSeparatorItem10: TTBSeparatorItem;
    TBControlItem1: TTBControlItem;
    dblcbSetFunction: TDBLookupComboBox;
    TBToolbar3: TTBToolbar;
    TBItem25: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem5: TTBItem;
    TBItem4: TTBItem;
    TBSeparatorItem13: TTBSeparatorItem;
    TBItem43: TTBItem;
    TBItem44: TTBItem;
    TBSeparatorItem14: TTBSeparatorItem;
    TBItem26: TTBItem;
    TBSeparatorItem15: TTBSeparatorItem;
    TBItem27: TTBItem;
    TBSeparatorItem8: TTBSeparatorItem;
    TBItem13: TTBItem;
    TBSeparatorItem17: TTBSeparatorItem;
    TBItem22: TTBItem;
    TBItem21: TTBItem;
    TBItem19: TTBItem;
    TBSeparatorItem16: TTBSeparatorItem;
    biSpeedReturn: TTBItem;
    TBToolbar4: TTBToolbar;
    N26_OLD_OLD: TTBSubmenuItem;
    N27_OLD_OLD: TTBItem;
    N28_OLD_OLD: TTBItem;
    N31_OLD_OLD: TTBSubmenuItem;
    N32_OLD_OLD: TTBItem;
    N33_OLD_OLD: TTBItem;
    TBSeparatorItem12: TTBSeparatorItem;
    TBItem36: TTBItem;
    TBItem37: TTBItem;
    TBSubmenuItem3: TTBSubmenuItem;
    TBItem30: TTBItem;
    TBItem28: TTBItem;
    TBItem45: TTBItem;
    TBSeparatorItem18: TTBSeparatorItem;
    TBItem7: TTBItem;
    TBSubmenuItem2: TTBSubmenuItem;
    TBItem41: TTBItem;
    TBItem34: TTBItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem40: TTBItem;
    TBItem39: TTBItem;
    TBItem38: TTBItem;
    TBItem3: TTBItem;
    TBItem35: TTBItem;
    TBSeparatorItem19: TTBSeparatorItem;
    TBItem31: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem6: TTBItem;
    TBSubmenuItem1: TTBSubmenuItem;
    TBItem33: TTBItem;
    N26: TTBSubmenuItem;
    TBItem42: TTBItem;
    TBItem32: TTBItem;
    TBToolbar1: TTBToolbar;
    TBItem16: TTBItem;
    TBItem15: TTBItem;
    TBSeparatorItem9: TTBSeparatorItem;
    TBItem14: TTBItem;
    TBItem18: TTBItem;
    TBSeparatorItem7: TTBSeparatorItem;
    TBItem12: TTBItem;
    TBItem11: TTBItem;
    TBSeparatorItem6: TTBSeparatorItem;
    TBItem10: TTBItem;
    TBItem9: TTBItem;
    TBSeparatorItem5: TTBSeparatorItem;
    TBItem8: TTBItem;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem2: TTBItem;
    TBToolbar5: TTBToolbar;
    TBItem23: TTBItem;
    TBItem24: TTBItem;
    TBSeparatorItem11: TTBSeparatorItem;
    TBItem17: TTBItem;
    TBItem29: TTBItem;
    tbHistory: TTBToolbar;
    tbiPrev: TTBItem;
    tbiNext: TTBItem;
    tbtbMethods: TTBToolbar;
    biDisableMethod: TTBItem;
    tbSpeedBottons: TTBToolbar;
    spMessages: TSplitter;
    sbComment: TStatusBar;
    actProperty: TAction;
    TBSeparatorItem20: TTBSeparatorItem;
    TBItem46: TTBItem;
    N27: TMenuItem;
    N29: TMenuItem;
    actEditCopy: TEditCopy;
    actEditCut: TEditCut;
    actEditPaste: TEditPaste;
    TBSeparatorItem21: TTBSeparatorItem;
    TBItem47: TTBItem;
    TBItem48: TTBItem;
    TBItem49: TTBItem;
    N30: TMenuItem;
    N31: TMenuItem;
    N32: TMenuItem;
    N33: TMenuItem;
    frToolBar1: TfrToolBar;
    TBDock2: TTBDock;
    tbTree: TTBToolWindow;
    tvClasses: TTreeView;
    TBDock3: TTBDock;
    TBDock4: TTBDock;
    TBDock5: TTBDock;
    twMessages: TTBToolWindow;
    lvMessages: TListView;
    TBDock6: TTBDock;
    TBDock7: TTBDock;
    Splitter2: TSplitter;
    TBItem50: TTBItem;
    TBItem51: TTBItem;
    actShowTreeWindow: TAction;
    TBSeparatorItem22: TTBSeparatorItem;
    actShowMessagesWindow: TAction;
    TBItem52: TTBItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tvClassesChange(Sender: TObject; Node: TTreeNode); virtual;
    procedure tvClassesChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean); virtual;
    procedure dbcbLangChange(Sender: TObject);

    procedure actFuncCommitExecute(Sender: TObject);
    procedure actFuncCommitUpdate(Sender: TObject);
    procedure actFuncRollbackExecute(Sender: TObject);
    procedure actAddMacrosExecute(Sender: TObject);
    procedure actAddFolderExecute(Sender: TObject);
    procedure actAddFolderUpdate(Sender: TObject);
    procedure actAddMacrosUpdate(Sender: TObject);
    procedure actDeleteFolderExecute(Sender: TObject);
    procedure actDeleteFolderUpdate(Sender: TObject);
    procedure actDeleteMacrosExecute(Sender: TObject);
    procedure actDeleteMacrosUpdate(Sender: TObject);
    procedure actRenameExecute(Sender: TObject);
    procedure actRenameUpdate(Sender: TObject);
    procedure actCutTreeItemExecute(Sender: TObject);
    procedure actCutTreeItemUpdate(Sender: TObject);
    procedure actPasteFromClipBoardExecute(Sender: TObject);
    procedure actPasteFromClipBoardUpdate(Sender: TObject);
    procedure actCopyTreeItemExecute(Sender: TObject);
    procedure actCopyTreeItemUpdate(Sender: TObject);
    procedure actDeleteReportUpdate(Sender: TObject);
    procedure actDeleteReportExecute(Sender: TObject);
    procedure actEditTemplateExecute(Sender: TObject);
    procedure actEditTemplateUpdate(Sender: TObject);
    procedure actLoadFromFileExecute(Sender: TObject);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actCompileExecute(Sender: TObject);
    procedure actSQLEditorExecute(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure actReplaceExecute(Sender: TObject);
    procedure actCopyTextExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure actCopyTextUpdate(Sender: TObject);
    procedure actPasteUpdate(Sender: TObject);
    procedure actAddReportExecute(Sender: TObject);
    procedure actAddReportUpdate(Sender: TObject);

    procedure dbeFunctionNameChange(Sender: TObject);
    procedure dbeFunctionNameEnter(Sender: TObject);
    procedure dblcbSetFunctionClick(Sender: TObject);
    procedure dblcbSetFunctionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure pcFunctionChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure pcFunctionChange(Sender: TObject);
    procedure hkMacrosKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actFunctionButtonUpdate(Sender: TObject);
    procedure dbmGroupDescriptionChange(Sender: TObject);
    procedure btnSelTemplateClick(Sender: TObject);
    procedure dbmDescriptionChange(Sender: TObject);
    procedure ControlChange(Sender: TObject);
    procedure dbcbReportServerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure dblcbTemplateClick(Sender: TObject);
    procedure dblcbTemplateKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FuncControlChanged(Sender: TObject);
    procedure dblcbMacrosServerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvClassesExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure tvClassesEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure tvClassesEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure tvClassesGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure tvClassesDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure tvClassesEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure tvClassesStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure tvClassesDeletion(Sender: TObject; Node: TTreeNode);
    procedure pcFuncParamChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure dblcbMacrosServerClick(Sender: TObject);
    procedure actAddScriptFunctionExecute(Sender: TObject);
    procedure actAddScriptFunctionUpdate(Sender: TObject);
    procedure actDeleteScriptFunctionExecute(Sender: TObject);
    procedure actDeleteScriptFunctionUpdate(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actRefreshUpdate(Sender: TObject);
    procedure actExecReportUpdate(Sender: TObject);
    procedure actExecReportExecute(Sender: TObject);
    procedure actFindInTreeExecute(Sender: TObject);
    procedure actExpandExecute(Sender: TObject);
    procedure actUnExpandExecute(Sender: TObject);
    procedure tvClassesAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure actPrevExecute(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure tbHistoryMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actPrepareExecute(Sender: TObject);
    procedure actOnlySpecEventExecute(Sender: TObject);
    procedure actAutoSaveExecute(Sender: TObject);
    procedure actEvaluateExecute(Sender: TObject);
    procedure hkMacrosKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gsFunctionSynEditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure gsFunctionSynEditSpecialLineColors(Sender: TObject;
      Line: Integer; var Special: Boolean; var FG, BG: TColor);
    procedure gsFunctionSynEditChange(Sender: TObject);
    procedure actAddVBClassExecute(Sender: TObject);
    procedure actDeleteVBClassExecute(Sender: TObject);
    procedure actAddVBClassUpdate(Sender: TObject);
    procedure actDeleteVBClassUpdate(Sender: TObject);
    procedure actDeleteEventUpdate(Sender: TObject);
    procedure actDeleteEventExecute(Sender: TObject);
    procedure actDeleteUnusedMethodsExecute(Sender: TObject);
    procedure actDeleteUnUsedEventsExecute(Sender: TObject);
    procedure tvClassesCompare(Sender: TObject; Node1, Node2: TTreeNode;
      Data: Integer; var Compare: Integer);
    procedure actSaveHistExecute(Sender: TObject);
    procedure gsFunctionSynEditProcessCommand(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
    procedure actCompileUpdate(Sender: TObject);
    procedure actSettingsExecute(Sender: TObject);
    procedure actAddItemUpdate(Sender: TObject);
    procedure actAddItemExecute(Sender: TObject);
    procedure actDeleteItemUpdate(Sender: TObject);
    procedure actDeleteItemExecute(Sender: TObject);
    procedure actAddConstExecute(Sender: TObject);
    procedure actAddGlobalObjectExecute(Sender: TObject);
    procedure actPrepareUpdate(Sender: TObject);
    procedure SynCompletionProposalExecute(Kind: SynCompletionType;
      Sender: TObject; var AString: String; x, y: Integer;
      var CanExecute: Boolean);
    procedure gsFunctionSynEditGutterClick(Sender: TObject; X, Y,
      Line: Integer; mark: TSynEditMark);
    procedure actDebugRunUpdate(Sender: TObject);
    procedure actDebugPauseUpdate(Sender: TObject);
    procedure actDebugRunExecute(Sender: TObject);
    procedure actDebugStepInExecute(Sender: TObject);
    procedure actDebugGotoCursorExecute(Sender: TObject);
    procedure actDebugStepOverExecute(Sender: TObject);
    procedure actProgramResetExecute(Sender: TObject);
    procedure actDebugPauseExecute(Sender: TObject);
    procedure actProgramResetUpdate(Sender: TObject);
    procedure actDisableMethodExecute(Sender: TObject);
    procedure gsFunctionSynEditMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure TimerTimer(Sender: TObject);
    procedure actSpeedReturnExecute(Sender: TObject);
    procedure lvErrorMessageDeletion(Sender: TObject; Item: TListItem);
    procedure FindInTreeDialogFind(Sender: TObject);
    procedure lvMessagesDeletion(Sender: TObject; Item: TListItem);
    procedure lvMessagesCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure sbCommentDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure actToggleBreakpointExecute(Sender: TObject);
    procedure gsFunctionSynEditPlaceBookmark(Sender: TObject;
      var Mark: TSynEditMark);
    procedure gsFunctionSynEditCommandProcessed(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
    procedure tvClassesDblClick(Sender: TObject);
    procedure lvMessagesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure actClearSearchResultExecute(Sender: TObject);
    procedure actClearErrorResultExecute(Sender: TObject);
    procedure actFindFunctionExecute(Sender: TObject);
    procedure actDeleteReportFunctionUpdate(Sender: TObject);
    procedure actDeleteReportFunctionExecute(Sender: TObject);
    procedure actDebugStepInUpdate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure actPropertyExecute(Sender: TObject);
    procedure actPropertyUpdate(Sender: TObject);
    procedure actEditCopyExecute(Sender: TObject);
    procedure actEditCutExecute(Sender: TObject);
    procedure actEditPasteExecute(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure Splitter1Moved(Sender: TObject);
    procedure TBDock2RequestDock(Sender: TObject;
      Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure TBDock1RequestDock(Sender: TObject;
      Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure spMessagesCanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure spMessagesMoved(Sender: TObject);
    procedure TBDock2Resize(Sender: TObject);
    procedure TBDock4Resize(Sender: TObject);
    procedure TBDock6Resize(Sender: TObject);
    procedure TBDock2InsertRemoveBar(Sender: TObject; Inserting: Boolean;
      Bar: TTBCustomDockableWindow);
    procedure TBDock6InsertRemoveBar(Sender: TObject; Inserting: Boolean;
      Bar: TTBCustomDockableWindow);
    procedure TBDock4InsertRemoveBar(Sender: TObject; Inserting: Boolean;
      Bar: TTBCustomDockableWindow);
    procedure actShowTreeWindowUpdate(Sender: TObject);
    procedure actShowTreeWindowExecute(Sender: TObject);
    procedure actShowMessagesWindowUpdate(Sender: TObject);
    procedure lvMessagesClick(Sender: TObject);
    procedure actShowMessagesWindowExecute(Sender: TObject);
    procedure lvMessagesExit(Sender: TObject);
    procedure Splitter2Moved(Sender: TObject);
    procedure TBItem52Click(Sender: TObject);
  private
    // хранит ссылку на последний объект, для редактирования
    // которого открывалось окно
    FLastComponent: TComponent;

    procedure ClearSpeedReturnPopup;
    procedure ViewParam(const AnParam: Variant);
    procedure OnHistoryMenuClick(Sender: TObject);
    procedure OnSpeedReturnMenuClick(Sender: TObject);

    procedure ChangeVBClassText(Node: TTreeNode;
      const OldName, NewName: String);
    procedure ChangeGlobalObjectText(Node: TTreeNode;
      const OldName, NewName: String);

    procedure MethodVisible(MethodItem: TTreeNode; const AVirtualMethod: Boolean);
  protected
    function GetPath(ANode: TTreeNode): String;
    procedure SetChanged; virtual;
    procedure NoChanges;
    procedure PrepareTestResult;
    procedure SaveReportResult;
    procedure LoadReportResult;

    // Вызываем функцию на редактирование или создаем ее
    procedure LoadFunction(const AnModule: String; const AnFunctionKey: Integer;
     const AnFunctionName: String = ''; const AnParams: String = ''); virtual;
    procedure EditFunction; virtual;
    // Подтвреждение изменений
    function PostFunction(out AnFunctionKey: Integer): Boolean; virtual;
    // Отмена изменений
    procedure CancelFunction; virtual;

    // Запускаем транзакцию
    procedure StartTrans;
    // Завешаем транзакцию
    function CommitTrans: Boolean; virtual;

    // Заполняем список ивентов для класса в дереве
    procedure FillEvents(AnObject: TComponent; const AnTreeNode: TTreeNode);
    // Заполняем список классов для перекрытия методов
    function AddClassItem(const AnClassMethods: TgdcClassMethods;
      const AnParentNode: TTreeNode; gdcCLIndex: Integer;
      const SubTypeName: string = '';const SubTypeComment: string = ''): TTreeNode;
    // Заполняем список объектов для задания ивентов
    function AddEventItem(const AnObject: TComponent; const AnParent: TTreeNode;
     const AnParentObject: TEventObjectList): TTreeNode;
    //Добавляем метод
    function AddMethodItem(AnMethod: TMethodItem;  const AnParentNode: TTreeNode): TTreeNode;

    // Сохраняем связь м/у ивентом объекта и функции
    function SaveEvent(const AnObjectNode: TTreeNode; const AnEventNode: TTreeNode): Boolean; virtual;
    // Сохраняем связь в evt_objectevent
    function SaveMethod(const AnClassNode: TTreeNode; const AnMethodNode: TTreeNode): Boolean;

    // Поиск объекта
    function FindObject(const AnTreeNode: TTreeNode; const AnIsCreate: Boolean = True): Boolean;
    // Создание нового объекта
    function AddObject(var AnEventObject: TEventObject;
     const AnParentObject: TEventObject; const AnObjectType: Integer = 0): Boolean;

    // Поиск класса
    function FindClass(const AnTreeNode: TTreeNode; const AnIsCreate: Boolean = True): Boolean;
    // добавл-е класса в ТБД evt_object
    function AddClass(const AnMethodClass: TCustomMethodClass; const AnParent: Variant;
     const AnObjectType: Integer = 1): Boolean;

    // Получаем EventControl по его інтерфейсу
    function GetEventControl: TEventControl;

    procedure ChangePageVisible;

    // Функция выводит д.о. для подтвержления созранения
    // и вызывает комит или ролбэк
    function SaveChanges: Boolean;

    //Так надо
    procedure UpDateSyncs;
    // Возращает уникальное имя в парент группе
    function GetName(const AName: String; const AParentNode: TTreeNode): String;
    // Проверяет содержится ли Child в одной из дочерних
    //ветвей Parentа
    function IsChild(Child, Parent: TTreeNode): Boolean;
    // Обработчик события SynhEdit.OnParamChange
    procedure ParamChange(Sender: TObject);
    // Проверка на возможность ДрагАндДропа
    function CanDragandDrop(Source, Target: TTReeNode): Boolean;

    // Проверка имени функции
    function CheckFunctionName(const AnFunctionName, AnScriptText: String): Boolean;
    //Возвращает Тру если имя функции не сответствует имени в скрипте
    function WarningFunctionName(const AnFunctionName, AnScriptText: String): Boolean;
    procedure EnableControls;
    procedure DisableControls;
    procedure EnableChanges;
    procedure DisableChanges;
    procedure Loaded; override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure Activate; override;
  protected
    FObjectKey: Integer;
    // Откат транзакции
    procedure RollbackTrans;
    function GetObjectId(ANode: TTreeNode): Integer; virtual;
    // Полный коммит
    function OverallCommit: Boolean; virtual;
    // Полный откат
    procedure OverallRollback; virtual;

    // Возвращает тип нода
    function GetNodeType(Node: TTreeNode): TFunctionPages; virtual;
    function GetSelectedNodeType: TFunctionPages;

    //Процедура вывода VB классов
    procedure ShowVBClassesTreeRoot(AComponent: TComponent);
    //Процедура вывода корней дерева макросов
    procedure ShowMacrosTreeRoot(AComponent: TComponent);
    // Добавить node
    function AddItemNode(const Item: TscrCustomItem;
      const Parent: TTreeNode; Save: Boolean = True): TTreeNode;
    //Сохраняем макрос
    function PostMacros(const AMacrosNode: TTreeNode): Boolean;
    // Сохраняем группу
    function PostMacrosGroup(const ANode: TTreeNode): Boolean;
    // Удаляем группу
    function DeleteMacrosGroupItem(const ANode: TTreeNode): Boolean;
    // Удаляем макрос
    function DeleteMacros(const ANode: TTreeNode): Boolean;
    //
    function DeleteScriptFunction(const ANode: TTreeNode): Boolean;
    //
    function DeleteReportGroupItem(const ANode: TTreeNode): Boolean;
    //
    function DeleteReportItem(const ANode: TTreeNode): Boolean;
    //Добавить новую рапорт
    function AddReportItem(const AItem: TscrReportItem;
       const AParent: TTreeNode; Save: Boolean = True): TTreeNode;
    //Процедура вывода корней дерева рапортов
    procedure ShowReportTreeRoot(AComponent: TComponent);
    procedure ShowMethodTreeRoot(AnComponent: TComponent);
    procedure ShowEventTreeRoot(AnComponent: TComponent);
    procedure ShowAllRoot;
    //
    procedure ShowScriptFunctionTreeRoot(AComponent: TComponent);
    //
    procedure ShowConstTreeRoot;
    //
    procedure ShowGlobalObjectTreeRoot;
    //
    function PostReportFunction(const AReportFunctionNode: TTreeNode): Boolean;
    //Сохраняем отчёт
    function PostReport(const AReportNode: TTreeNode): Boolean;
     //Сохраняем отчёт
    function PostReportTemplate(const ANode: TTreeNode): Boolean;
    // Сохраняем группу отчётов
    function PostReportGroup(const ANode: TTreeNode): Boolean;

    // Делаем Канселы
    procedure CancelReportFunction;
    procedure CancelTemplate;
    procedure CancelReport;
    procedure CancelMacros;
    procedure CancelScriptFunction;
    procedure CancelMacrosGroup;
    procedure CancelReportGroup;
    // Возвращает парент группу
    function GetParentFolder(ANode: TTreeNode): TTreeNode;
    // Переносит нод из соурса в таргет
    procedure NodeCopy(SourceNode, TargetNode: TTreeNode);
    //Возвращает тру если это редактируемая папка
    function IsEditFolder(ANode: TTreeNode): Boolean;
    //Возвращает тру если это редактируемый макрос
    function IsEditMacros(ANode: TTreeNode): Boolean;
    //Возвращает тру если это папка с макросами
    function IsMacrosFolder(ANode: TTreeNode): Boolean;
    //Возвращает тру если это папка с отчётами
    function IsReportFolder(ANode: TTreeNode): Boolean;
    //Возвращает тру если это макрос
    function IsMacros(ANode: TTreeNode): Boolean;
    //Возвращает тру если это отчёт
    function IsReport(ANode: TTreeNode): Boolean;
    //Возвращает тру если это
    function IsReportTemplate(ANode: TTreeNode): Boolean;
    //
    function IsScriptFunction(ANode: TTreeNode): Boolean;
    function IsVBClass(ANode: TTreeNode): Boolean;
    // Копирует запись гдс-класса в буффер
    procedure Copy(Node: TTreeNode; ACut: Boolean);
    //вырезает в буффер обмена
    procedure Cut(Node: TTreeNode);
    //Встасляет из буффера обмена
    procedure Paste(TargetNode: TTreeNode);
    //Возвращает тру если восможна вставка из буфера
    function CanPaste(Source, Target: TTReeNode): Boolean;

    procedure LoadReport(const Node: TTreeNode);
    procedure LoadReportFunction(const Node: TTreeNode);
    procedure LoadReportTemplate(const Node: TTreeNode);
    procedure LoadReportGroup(const Node: TTreeNode);
    procedure LoadMacrosGroup(const Node: TTreeNode);
    procedure LoadMacros(const Node: TTreeNode);

    procedure ParserInit;
    //Добавляет новый ивент в список ивентов обьекта
    procedure AddEventToList(const Node: TTreeNode);
    procedure RefreshTree(const AnComponent: TComponent;
      const AnShowMode: TShowModeSet = smAll; const AnName: String = '';
      const Refresh: Boolean = False);

    //Возвращает True если определено хотя бы одно событие
    //у объекта определенного TN.Data или у дочернего объекта
    function EventSpec(TN: TTreeNode): Boolean;
    //обновляет флаги наличия событий с определ. макросами
    //для объекта в TN.Data и его радителей
    procedure UpdateEventSpec(TN: TTreeNode; Increment: Integer);
    procedure UpdateMethodSpec(TN: TTreeNode; Increment: Integer);

    procedure OnScriptError(Sender: TObject);
    //Переводит курсор на строку и установливает фокус на SynEdit
    procedure GoToLine(Line: Integer);
    procedure GoToXY(X, Y: Integer);
    procedure GotoErrorLine(ErrorLine: Integer);
    procedure AddAnyClass(ACountList, ATreeList: TList;
      AClassList: TgdcCustomClassList; const AParent: TTreeNode;
      const AnIndex: Integer; const LevelIndex: Integer = - 1);
    function SFGetType(TN: TTreeNode): sfTypes;
    //Производить обновление списка параметров
    procedure UpDataFunctionParams(FunctionParams: TgsParamList);
    procedure SaveFunctionParams;
    //Обработчик изменения состояния Debuggera
    procedure OnDebuggerStateChange(Sender: TObject;
      OldState, NewState: TDebuggerState);
    procedure OnCurrentLineChange(Sender: TObject);
    function FindTreeNode(SF: TrpCustomFunction): TTreeNode;
    procedure Expand(TN: TTreeNode);
    function CheckModefy: Boolean;

    function IsExecuteScript: Boolean;

    function GetStatament(var Str: String; Pos: Integer): String;
    function GetCompliteStatament(var Str: String; Pos: Integer;
      out BeginPos, EndPos: Integer): String;
    function FindSFInTree(ID: Integer; Module: String;
      const FindInDB: Boolean = True; ARefreshTree: Boolean = True): TTreeNode; overload;
    function FindSFInTree(ID: Integer; ARefreshTree: Boolean = True): TTreeNode; overload;
    procedure ClearSearchResult;
    procedure ClearErrorResult;
    function ErrorCount: Integer;
    procedure GotoLastError;
    procedure ClearEventRootNode;
    procedure ToggleBreakpoint(Line: Integer);
    procedure ChangeHighLight;
    procedure selectColorChange;
    procedure SelectNode(Node: TTreeNode);
    //Поиск нода события для обёекта
    function FindEventNode(AComponent: TComponent; Name: String): TTreeNode;
    //Возвращает окно владелец
    function GetOwnerForm(AComponent: TComponent): TCustomForm;
    function IsComponentMsg(C: TComponent; const Msg:TMsg): Boolean;
    function AddErrorListItem(Node: TTreeNode; Line: Integer; Caption: String): TListItem;
    function GetDebugStateName: String; overload;
    function GetDebugStateName(State: TDebuggerState): String; overload;
    procedure SetCaption; overload;
    procedure SetCaption(State: TDebuggerState); overload;
    procedure DoShow; override;
    function GetDBId: Integer;
    //Функции работы с классами
    procedure AddGDCClass(AParent: TTreeNode; Index: Integer);overload;
    procedure AddGDCClass(AParent: TTreeNode; Index: Integer; CClass: TClass);overload;
    function AddGDCClassNode(AParent: TTreeNode; I: Integer;
      SubType, SubTypeComent: String): TTreeNode;
    function AddFRMClassNode(AParent: TTreeNode; I: Integer;
      SubType, SubTypeComent: String): TTreeNode;

  protected
    FDBID: Integer;
    FCurrentFunction: TrpCustomFunction;
    FLastReportResult: TReportResult;
    FObjectList: TObjectList;
    FFunctionParams: TgsParamList;
    FCompiled: Boolean;
    // Указывает на изменение функции произведенные пользователем
    FChanged: Boolean;
    // Указывает на смену функции для события
    FFunctionChanged: Boolean;
    //Указывает на необходимость записи изменений функции в связи
    //с изменениями точек остановки, положение курсора и т.д.
    FFunctionNeadSave: Boolean;
    FModuleName: String;
    FParamLines: TObjectList;
    FRootShowName: String;
    FRootObject: TComponent;

    FDeleteNodeDate: TObject;
    FEnableControls: Integer;
    //
    FEnableChanges: Boolean;
    // Нод скопированный в буффер обмена
    FCopyNode: TTreeNode;
    //Указывает о переносе записи
    FCut: Boolean;
    //Указывает на создание нового отчёта
    FReportCreated: Boolean;
    //Указывает на изменения произвед. в
    //одной из ф. отчета или шаблоне
    FReportChanged: Boolean;
    //Указывает на возможность сохранения изменений
    //при создании нового отчета
    FCanSaveLoad: Boolean;
    //Хранит указатель на компонент для которого вызвано окно
    FComponent: TComponent;
    //Фиксирует кол-во дочерних компонент для FComponent в момент вывода окна
    //исполизуется при повторном вызове окна. Если хранимое значение
    //не совпадает с новым кол-м дочерних компонент то происходит перестройка дерева
    FComponentCount: Integer;
    //Режим вывода окна
    FShowMode: TShowModeSet;
    //Указатель на нод папки скрипт-функций
    //используется при добавлении или удалении макросов, отчетов и ивентов
    FScrFuncNode: TTreeNode;
    FEventRootNode: TTreeNode;
    FReportRootNode: TTreeNode;
    FMethodRootNode: TTreeNode;
    FVBClassRootNode: TTreeNode;
    FGMacrosRootNode: TTReeNode;
    FLMacrosRootNode: TTreeNode;
    FConstRootNode: TTreeNode;
    FGlobalObjectRootNode: TTreeNode;
    //Указывает что окно вызвано для редактирования одной функции
    FSingleFunction: Boolean;
    //Указатель на стек истории переходов по include
    FHistory: THistory;
    //Указатель на процедуру синхронизации с ObjectInspector-ом
//    FSynchronize: TEventSynchronize;
    //Указатель на обьект связывающий SynEdit с дебагером
    FDebugPlugin: TDebugSupportPlugin;
    //Указывает на обьект связывающий SynEdit с ErrorList
    FErrorListSuppurtPlugin: TErrorListSuppurtPlugin;
    //Указатель на обьект парсера
    FVBParser: TVBParser;
    //Строка в которой произошла ошибка
    FErrorLine: Integer;
    //Указатель на окно вычисления выражений
    FEvaluate: TdlgEvaluate;
    //
    FShortCut: TShortCut;
    FFindTextInTree: String;

    FRootEventCreated: Boolean;
    FRootScriptCreated: Boolean;
    FRootReportCreated: Boolean;
    FRootMethodCreated: Boolean;
    FRootVBClassCreated: Boolean;
    FRootGMacrosCreated: Boolean;
    FRootConstCreated: Boolean;
    FRootGlobalObjectCreated: Boolean;

    FMousePos: TPoint;
    FMouseRect: TRect;
    //Состояние окна
    FPropertyViewStates: TPropertyViewStates;
    FCurrentLine: Integer;
    FEnabledCount: Integer;
    FActive: Boolean;
    //Новый размер TBTollWindow при изменении размера сплитером
    FNewSize: Integer;
    property LocEventControl: TEventControl read GetEventControl;

  public
    procedure SaveSettings; override;
    procedure LoadSettings; override;
    procedure LoadSettingsAfterCreate; override;

    // устанавливает визуальное отоброжение метода в соответсвии его статусу
    procedure SetMethodView(AMethod: TMethodItem);

    procedure DeleteEvent(FormName, ComponentName,
      EventName: string);
    procedure Execute(const AnComponent: TComponent;
      const AnShowMode: TShowModeSet = smAll; const AnName: String = '';
      const AnSynchronize: TEventSynchronize = nil); virtual;
    //вывод модального окна для редактирования единственной скрипт-функции
    function EditScriptFunction(var AFunctionKey: Integer): Boolean;
    procedure DebugScriptFunction(const AFunctionKey: Integer;
      const AModuleName: string = scrUnkonownModule;
      const CurrentLine: Integer = - 1);
    //вывод окна редактирования отчета
    procedure EditReport(IDReportGroup, IDReport: Integer);
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

    procedure PropertyNotification(AComponent: TComponent;
      Operation: TOperation);
    function CheckDestroing: Boolean;
    function IsPropertyMsg(const Msg: TMsg): Boolean;
  end;


var
  dlgViewProperty: TdlgViewProperty;
  CrossingCount: Integer;

const
  fnHasChildren = 'haschildren';
  cCaption = 'Макросы [%s]%s';

implementation

uses
  gd_SetDatabase, rp_frmParamLineSE_unit, prp_dlgFindFunction,
  {$IFDEF SYNEDIT}
  flt_frmSQLEditorSyn_unit,
  {$ELSE}
  flt_frmSQLEditor_unit,
  {$ENDIF}
  syn_ManagerInterface_unit, ClipBrd, gd_security_operationconst,
  gd_i_ScriptFactory, gdcConstants, Gedemin_TLB, rp_StreamFR,
  rtf_TemplateBuilder, xfr_TemplateBuilder, Math, rp_ReportClient,
  st_dlgFind_unit, prp_dlgCopyFunctionRec_unit, scr_i_FunctionList,
  rp_dlgEnterParam_unit, gd_ScriptFactory, MSScriptControl_TLB,
  JclStrings, registry, gd_directories_const, rp_ReportScriptControl,
  gdc_frmExplorer_unit, dm_i_ClientReport_unit, prp_Filter,
  dlg_gsResizer_ObjectInspector_unit, gd_security,
  rp_dlgViewResultEx_unit
  , prp_frmGedeminProperty_Unit;


type
//  TCrackStringGrid = class(TStringGrid);
  TCrackComboBox = class(TComboBox);
  TCrackDBSynEdit = class(TDBSynEdit);
  TCrackHotKey = class(THotKey);

type
  TCrossingSaver = class(TObject)
  public
    FunctionKey: Integer;
    ModuleName: String;
    Node: TObject;
    {$IFDEF DEBUG}
    constructor Create; overload;
    destructor Destroy; override;
    {$ENDIF}
  end;

  TErrorScriptSaver = class(TObject)
  public
    Node: TTreeNode;
    ErrorLine: Integer;
  end;


{$R *.DFM}
function InheritsFromCount(AnMainClass,
  AnParentClass: TClass): Integer;
asm
      { ->    EAX     Pointer to our class    }
      {       EDX     Pointer to AClass               }
      { <-    EAX      Boolean result          }
      PUSH    EBX
      MOV     EBX, 0
      JMP     @@haveVMT
@@loop:
      MOV     EAX,[EAX]
@@haveVMT:
      CMP     EAX,EDX
      JE      @@success
      INC     EBX
      MOV     EAX,[EAX].vmtParent
      TEST    EAX,EAX
      JNE     @@loop
      MOV     EAX, -1
      JMP     @@exit
@@success:
      MOV     EAX, EBX
@@exit:
      POP     EBX
end;

{ TdlgViewProperty }

function TdlgViewProperty.AddClassItem(const AnClassMethods: TgdcClassMethods;
  const AnParentNode: TTreeNode; gdcCLIndex: Integer;
  const SubTypeName: string = '';const SubTypeComment: string = ''): TTreeNode;
var
  TheClass, TheParentClass: TCustomMethodClass;
  TheMethod: TMethodItem;
  PrntMethName: String;
  I, j: Integer;
  ST: TStrings;
  LFullClassName: TgdcFullClassName;

  function AddM(M: TMethodItem; Parent: TTreeNode): TTreeNode;
  begin
    Result := nil;
    //Применяем фильтр
    if Filter(M.Name ,PropertySettings.Filter.MethodName,
      TFilterOptions(PropertySettings.Filter.foMethod)) then
    begin
      if (PropertySettings.Filter.OnlySpecEvent and (M.FunctionKey <> 0)) or
        not PropertySettings.Filter.OnlySpecEvent then
      begin
        Result := AddMethodItem(M, Parent);
        if (M.FunctionKey <> 0) then
          UpdateMethodSpec(Parent, 1);
      end;
    end;
  end;

begin
  Result := nil;
  if not (Assigned(AnClassMethods) and Assigned(AnClassMethods.gdcClass)) then
    Exit;

  //Поиск класса среди ранее сохранненых в БД
  LFullClassName.gdClassName := AnClassMethods.gdcClass.ClassName;
  LFullClassName.SubType := SubTypeName;
  TheClass := TCustomMethodClass(MethodControl.FindMethodClass(LFullClassName));
  if TheClass = nil then
  begin
    //Если не найден то регистрируем его в списке
    TheClass := TCustomMethodClass(MethodControl.AddClass(0, LFullClassName, AnClassMethods.gdcClass));
//    TheClass := TCustomMethodClass(MethodControl.MethodClass[i]);
//    TheClass.Class_Reference := AnClassMethods.gdcClass;
//    TheClass.Class_Name := AnClassMethods.gdcClass.ClassName + SubTypeName;
//    TheClass.SubType := SubTypeName;
  end;
  TheClass.SubTypeComment := SubTypeComment;

  Result := tvClasses.Items.AddChild(AnParentNode, '');
  Result.ImageIndex := 0;
  Result.SelectedIndex := Result.ImageIndex;
  Result.Data := TheClass;

  if SubTypeName <> '' then
  begin
    if PropertySettings.GeneralSet.FullClassName then
      Result.Text := AnClassMethods.gdcClass.ClassName + SubTypeName
    else
      Result.Text := SubTypeName;
  end else
    Result.Text := AnClassMethods.gdcClass.ClassName;

  // Добавляем методы класса
  for I := 0 to AnClassMethods.gdcMethods.Count - 1 do
  begin
    //Ищем метод среди уже зарегестрированных в БД
    TheMethod := TheClass.MethodList.Find(AnClassMethods.gdcMethods.Methods[I].Name);
    if TheMethod = nil then // if not exist in DB but registered
    begin
      j := TheClass.MethodList.Add(AnClassMethods.gdcMethods.Methods[I].Name,
        0, False, TheClass);
      TheMethod := TheClass.MethodList.Items[j];
//      TheMethod.MethodClass := TheClass;
    end;

    TheMethod.MethodData := @AnClassMethods.gdcMethods.Methods[I].ParamsData;
    AddM(TheMethod, Result);
  end;

   // Adding inherited methods
  if Assigned(AnParentNode) and Assigned(AnParentNode.Data)then
  begin
    TheParentClass := TCustomMethodClass(AnParentNode.Data);

    for I := 0 to TheParentClass.MethodList.Count - 1 do
    begin
      PrntMethName := TheParentClass.MethodList.Name[I];
      if AnClassMethods.gdcMethods.MethodByName(PrntMethName) = nil then //if not reg-d in curr. class
      begin
        TheMethod := TheClass.MethodList.Find(PrntMethName);
        if TheMethod = nil then // if not exists in MethodList
        begin
          j := TheClass.MethodList.Add(PrntMethName, 0, False, TheClass);
          TheMethod := TheClass.MethodList.Items[j];
//          TheMethod.MethodClass := TheClass;
        end;
        TheMethod.MethodData := TheParentClass.MethodList.Items[I].MethodData;
        AddM(TheMethod, Result);
      end;
    end;
  end;

  if Assigned(TheClass.Class_Reference) and
    ((TheClass.Class_Reference.InheritsFrom(TgdcBase)) or
    (TheClass.Class_Reference.InheritsFrom(TgdcCreateableForm))) then
  begin  
    ST := TStringList.Create;
    try
      if TheClass.Class_Reference.InheritsFrom(TgdcBase) then
        CgdcBase(TheClass.Class_Reference).GetSubTypeList(ST)
      else
        CgdcCreateableForm(TheClass.Class_Reference).GetSubTypeList(ST);
      //добавляем SubTypы для гдс классов
      //Если SubTypeName = '' то для данного класа
      //регистрация SubTypов не производилась
      if SubTypeName = '' then
      begin
        //Добавляем SubTypы класса
        for I := 0 to ST.Count - 1 do
          AddClassItem(AnClassMethods, Result, gdcCLIndex,
            ChangeIncorrectSymbol(ST.Values[ST.Names[I]]), ST.Names[I]);
      end;
    finally
      ST.Free;
    end;
  end;
end;

function TdlgViewProperty.AddEventItem(const AnObject: TComponent;
  const AnParent: TTreeNode; const AnParentObject: TEventObjectList): TTreeNode;
var
  TN: TTreeNode;
  I: Integer;
  Flag: Boolean;
  fltFlag: Boolean;
begin
  Result := nil;
  if not Assigned(AnObject) then
    Exit;

  fltFlag := Filter(AnObject.Name, PropertySettings.Filter.ObjectName,
    TFilterOptions(PropertySettings.Filter.foObject)) or (AnObject = FComponent);
  // Добавляем объект в дерево
  if AnObject is TForm then
  begin
    TN := tvClasses.Items.AddChild(FEventRootNode, AnObject.Name + '(' + AnObject.ClassName + ')');
    TN.ImageIndex := 1
  end else
  begin
    TN := tvClasses.Items.AddChild(AnParent, AnObject.Name + '(' + AnObject.ClassName + ')');
    TN.ImageIndex := 2;
  end;
  // Присваиваем иконку
  TN.SelectedIndex := TN.ImageIndex;
  // Ищем объект
  if AnObject is TForm then
    TN.Data := LocEventControl.EventObjectList.FindObject(AnObject.Name)
  else
  if Assigned(AnParentObject) then
    TN.Data := AnParentObject.FindObject(AnObject.Name)
  else
    TN.Data := nil;

  // Создаем если не нашли
  if not Assigned(TN.Data) then
  begin
    TN.Data := TEventObject.Create;
    TEventObject(TN.Data).ObjectName := AnObject.Name;
    TEventObject(TN.Data).SelfObject := AnObject;
    FObjectList.Add(TN.Data);
  end else
  begin
    TEventObject(TN.Data).SelfObject := AnObject;
    TEventObject(TN.Data).SpecEventCount := 0;
  end;
  // Добавляем события в дерево
  if fltFlag then
    FillEvents(AnObject, TN);

  // Добавляем дочерние объекты
  for I := 0 to AnObject.ComponentCount - 1 do
    if AnObject.Components[I].Name <> '' then
      AddEventItem(AnObject.Components[I], TN, TEventObject(TN.Data).ChildObjects);

  if not fltFlag then
  begin
    //Если наименование объекта неудовлетворяет условию фильтра
    //то проверяем наличие дочерних обектов удовлет. фильтру
    Flag := False;
    for I := 0 to Tn.Count - 1 do
    begin
      if TObject(Tn.Item[I].Data) is TEventObject then
      begin
        Flag := True;
        Break;
      end
    end;
    if not Flag then
    begin
      Tn.Delete;
      Result := nil;
      Exit;
    end
  end;

  // Если у объекта нет зарегистрированых событий и
  // нет дочерних компонент с событиями то удаляем его
  if TN.Count <= 0 then
  begin
    TN.Delete;
    TN := nil;
  end;

  Result := TN;
end;

function TdlgViewProperty.AddMethodItem(AnMethod: TMethodItem;  const AnParentNode: TTreeNode): TTreeNode;
begin
  Result := tvClasses.Items.AddChild(AnParentNode, AnMethod.Name);
  Result.Data := AnMethod;
  MethodVisible(Result, False);
  Result.SelectedIndex := Result.ImageIndex;
  if TMethodItem(Result.Data).Disable then
    TCustomMethodClass(AnParentNode.Data).SpecDisableMethod :=
      TCustomMethodClass(AnParentNode.Data).SpecDisableMethod + 1;
end;

procedure TdlgViewProperty.Execute(const AnComponent: TComponent;
 const AnShowMode: TShowModeSet = smAll; const AnName: String = '';
 const AnSynchronize: TEventSynchronize = nil);
begin
  if not CheckDestroing then
  begin
    if FLastComponent <> AnComponent then
    begin
      ClearSpeedReturnPopup;
      FLastComponent := AnComponent;
    end;
    if pmSpeedReturn.Items.Count > 0 then
      actSpeedReturn.Enabled := True
    else
      actSpeedReturn.Enabled := False;

    //Обновляем дерево
    RefreshTree(AnComponent, AnShowMode, AnName, False);
    //показывем окно
    Show;
  end;
end;

procedure TdlgViewProperty.FillEvents(AnObject: TComponent;
 const AnTreeNode: TTreeNode);
var
  I, J: Integer;
  TempPropList: TPropList;
  CurrentObject: TEventObject;
  TN: TTreeNode;
  PN: TTreeNode;
  function GetExistsEvent(const AnEventName: String): TEventItem;
  var
    K: TEventItem;
  begin
    Result := TEventItem.Create;
    Result.Name := AnEventName;
    Result.EventData := GetTypeData(TempPropList[I]^.PropType^);
    Result.EventObject := CurrentObject;
    if Assigned(CurrentObject) then
    begin
      K := CurrentObject.EventList.Find(AnEventName);
      if Assigned(K) then
        Result.FunctionKey := K.FunctionKey;
    end;
  end;
begin
  J := GetPropList(AnObject.ClassInfo, [tkMethod], @TempPropList);
  CurrentObject := (TObject(AnTreeNode.Data) as TEventObject);
  for I := 0 to J - 1 do
  begin
    if Assigned(EventControl) then
      if EventControl.KnownEventList.IndexOf(TempPropList[I]^.Name) > -1 then
      begin
        if ((not PropertySettings.Filter.OnlySpecEvent) or (PropertySettings.Filter.OnlySpecEvent and Assigned(CurrentObject) and
          Assigned(CurrentObject.EventList.Find(TempPropList[I]^.Name))))
          and (Filter(TempPropList[I]^.Name, PropertySettings.Filter.EventName,
          TFilterOptions(PropertySettings.Filter.foEvent)) or (AnObject =
          FComponent))then
        begin
          TN := tvClasses.Items.AddChild(AnTreeNode, '');
          TN.ImageIndex := 4;
          TN.SelectedIndex := 4;
          TN.Data := GetExistsEvent(TempPropList[I]^.Name);
          TN.Text := TempPropList[I]^.Name;
          if (FRootObject = AnObject) and
            (UpperCase(TempPropList[I]^.Name) = FRootShowName) then
          begin
            TN.Selected := True;
            Assert(GetSelectedNodeType <> fpNone);
            pcFunction.ActivePage := tsFuncScript;
            gsFunctionSynEdit.Show;
          end;
          FObjectList.Add(TN.Data);
          if Assigned(TN.Data) then
          begin
            if TEventItem(TN.Data).FunctionKey > 0 then
            begin
              PN := TN.Parent;
              repeat
                (TObject(PN.Data) as TEventObject).SpecEventCount :=
                  (TObject(PN.Data) as TEventObject).SpecEventCount + 1;
                PN := PN.Parent;
              until PN.Parent = nil;
            end
          end;
        end;
      end;
  end;
end;

function TdlgViewProperty.GetEventControl: TEventControl;
begin
  Result := nil;
  if Assigned(EventControl) then
    Result := EventControl.Get_Self as TEventControl;
end;

procedure TdlgViewProperty.FormCreate(Sender: TObject);
begin
  tbSpeedBottons.Visible := False;
  tbSpeedBottons.Visible := true;
  FPropertyViewStates := [];
  FLastComponent := nil;
  UseDesigner := False;
  FObjectList := TObjectList.Create;
  FCurrentFunction := TrpCustomFunction.Create;
  FLastReportResult := TReportResult.Create;
  FFunctionParams := TgsParamList.Create;
  FChanged := False;
  FParamLines := TObjectList.Create;
  FObjectKey := 0;
  pcFunction.ActivePage := tsFuncScript;

  gdcDelphiObject.UseScriptMethod := False;
  gdcFunction.UseScriptMethod := False;
  gdcEvent.UseScriptMethod := False;
  gdcMacros.UseScriptMethod := False;
  gdcMacrosGroup.UseScriptMethod := False;
  gdcReport.UseScriptMethod := False;
  gdcReportGroup.UseScriptMethod := False;
  gdcTemplate.UseScriptMethod := False;

  FReportChanged := False;
  FCopyNode := nil;
  FCut := True;
  FScrFuncNode := nil;
  FHistory := THistory.Create;

  cdsTemplateType.Close;
  cdsTemplateType.CreateDataSet;
{RTF deleted}
  cdsTemplateType.AppendRecord([ReportFR, 'Шаблон FastReport']);
  cdsTemplateType.AppendRecord([ReportXFR, 'Шаблон xFastReport']);
  cdsTemplateType.AppendRecord([ReportGRD, 'Шаблон Grid']);
//  FTestReportResult := TReportResult.Create;

  if Assigned(Debugger) then
  begin
    Debugger.OnStateChange := OnDebuggerStateChange;
    Debugger.OnCurrentLineChange := OnCurrentLineChange;
  end;
  FDebugPlugin := TDebugSupportPlugin.Create(gsFunctionSynEdit);
  FDebugPlugin.Images := imglGutterGlyphs;
  FErrorLine := - 1;

  FErrorListSuppurtPlugin := TErrorListSuppurtPlugin.Create(gsFunctionSynEdit);
  FErrorListSuppurtPlugin.ErrorListView := lvMessages;

  FVBParser := TVBParser.Create(Self);

  TCrackHotKey(hkMacros).OnKeyUp := hkMacrosKeyUp;

  gsFunctionSynEdit.Parser := FVBParser;
  gsFunctionSynEdit.UseParser := True;
  gsFunctionSynEdit.OnChange := gsFunctionSynEditChange;
  UpDateSyncs;

  EnableChanges;
end;


procedure TdlgViewProperty.FormDestroy(Sender: TObject);
begin
  SaveChanges;
  
  FLastComponent := nil;
  ClearSpeedReturnPopup;

  FreeAndNil(FCurrentFunction);
  FreeAndNil(FLastReportResult);
  FreeAndNil(FFunctionParams);
  FreeAndNil(FObjectList);
  FParamLines.Free;
  FHistory.Free;
  FDebugPlugin.Free;
  FErrorListSuppurtPlugin.Free;
  FEvaluate.Free;
//  FTestReportResult.Free;

  if Assigned(Debugger) then
  begin
    Debugger.OnStateChange := nil;
    Debugger.OnCurrentLineChange := nil;
  end;
  if Self = dlgViewProperty then
    dlgViewProperty := nil;
end;

procedure TdlgViewProperty.tvClassesChange(Sender: TObject;
  Node: TTreeNode);
var
  LBranchType: TFunctionPages;
  LocUnMethodMacro: Boolean;
  i: Integer;
begin
  //проверяем список переходов, если данный нод в нем есть, то удаляем его
  for i := 0 to pmSpeedReturn.Items.Count - 1 do
  begin
    if TCrossingSaver(pmSpeedReturn.Items[i].Tag).Node = Node then
    begin
      TCrossingSaver(pmSpeedReturn.Items[i].Tag).Free;
      pmSpeedReturn.Items.Delete(i);
      Break;
    end;
  end;
  LocUnMethodMacro := UnMethodMacro;
  UnMethodMacro := True;

  //Отслючаем контролы
  DisableControls;
  gdcFunction.DisableControls;
  StartTrans;
  try
    if GetSelectedNodeType = fpNone then
      Exit;

    if ibqrySetFunction.Active then
      ibqrySetFunction.Close;

    sbFuncEdit.Panels[0].Text := '';

    LBranchType := GetSelectedNodeType;

    if LBranchType <> fpMethod then
    begin
      tbtbMethods.Visible := False;
      actDisableMethod.Enabled := False;
    end else
      actDisableMethod.Enabled := True;

    sbComment.Panels[0].Text := GetPath(tvClasses.Selected) + '\' +
      tvClasses.Selected.Text;

    case GetSelectedNodeType of
      fpMacros:
      begin
        Label6.Caption := 'Наименование функции';
        tsFuncScript.Caption := 'Текст функции';
        LoadMacros(tvClasses.Selected);
      end;
      fpMacrosFolder: LoadMacrosGroup(tvClasses.Selected);
      fpReportFolder: LoadReportGroup(tvClasses.Selected);
      fpReportFunction:
      begin
        Label6.Caption := 'Наименование функции';
        tsFuncScript.Caption := 'Текст функции';
        LoadReportFunction(tvClasses.Selected);
      end;
      fpReport: LoadReport(tvClasses.Selected);
      fpReportTemplate: LoadReportTemplate(tvClasses.Selected);
      fpEvent:
      begin
        Label6.Caption := 'Наименование обработчика';
        tsFuncScript.Caption := 'Текст обработчика';
        ibqrySetFunction.Params[0].AsString := scrEventModuleName;
        ibqrySetFunction.Params[1].AsInteger :=
          GetObjectId(tvClasses.Selected);
        ibqrySetFunction.Params[2].AsInteger :=
           TEventItem(tvClasses.Selected.Data).FunctionKey;
        ibqrySetFunction.Open;
        dblcbSetFunction.KeyValue := TEventItem(tvClasses.Selected.Data).FunctionKey;

        LoadFunction(scrEventModuleName, TEventItem(tvClasses.Selected.Data).FunctionKey,
          TEventItem(tvClasses.Selected.Data).AutoFunctionName, TEventItem(tvClasses.Selected.Data).ComplexParams[fplVBScript]);
      end;
      fpMethodClass:
      begin
        Label6.Caption := 'Наименование метода';
        tsFuncScript.Caption := 'Текст метода';
        if TCustomMethodClass(tvClasses.Selected.Data).SubTypeComment <> '' then
          sbComment.Panels[0].Text := sbComment.Panels[0].Text + ' (' +
            TCustomMethodClass(tvClasses.Selected.Data).SubTypeComment + ')';
      end;
      fpMethod:
      begin
        tbtbMethods.Visible := True;
        MethodVisible(tvClasses.Selected, False);

        Label6.Caption := 'Наименование метода';
        tsFuncScript.Caption := 'Текст метода';
        ibqrySetFunction.Params[0].AsString := scrMethodModuleName;
        ibqrySetFunction.Params[1].AsInteger := GetObjectId(tvClasses.Selected);
        ibqrySetFunction.Params[2].AsInteger :=
          TMethodItem(tvClasses.Selected.Data).FunctionKey;
        ibqrySetFunction.Open;
        dblcbSetFunction.KeyValue := TMethodItem(tvClasses.Selected.Data).FunctionKey;

        LoadFunction(scrMethodModuleName, TMethodItem(tvClasses.Selected.Data).FunctionKey,
         TMethodItem(tvClasses.Selected.Data).AutoFunctionName, TMethodItem(tvClasses.Selected.Data).ComplexParams[fplVBScript]);

        sbComment.Panels[0].Text := GetPath(tvClasses.Selected);
//        if TMethodItem(tvClasses.Selected.Data).MethodClass.SubTypeComment <> '' then
        if TCustomMethodClass(tvClasses.Selected.Parent.Data).SubTypeComment <> '' then
          sbComment.Panels[0].Text := sbComment.Panels[0].Text + ' (' +
//            TMethodItem(tvClasses.Selected.Data).MethodClass.SubTypeComment + ')';
            TCustomMethodClass(tvClasses.Selected.Parent.Data).SubTypeComment + ')';
        sbComment.Panels[0].Text := sbComment.Panels[0].Text + '\' +
          tvClasses.Selected.Text;
      end;
      fpScriptFunction:
      begin
        Label6.Caption := 'Наименование функции';
        tsFuncScript.Caption := 'Текст функции';
        LoadFunction(TscrScriptFunction(tvClasses.Selected.Data).Module,
          TscrScriptFunction(tvClasses.Selected.Data).Id, Node.Text,
          Format(VB_SCRIPTFUNCTION_TEMPLATE, [Node.Text]));
        Node.Text := gdcFunction.FieldByName(fnName).AsString;
      end;
      fpConst:
      begin
        Label6.Caption := 'Имя блока констант';
        tsFuncScript.Caption := 'Описание констант';
        LoadFunction(TscrConst(tvClasses.Selected.Data).Module,
          TscrConst(tvClasses.Selected.Data).Id, Node.Text,
          VB_CONST);
        Node.Text := gdcFunction.FieldByName(fnName).AsString;
      end;
      fpGlobalObject:
      begin
        Label6.Caption := 'Имя глобального объекта';
        tsFuncScript.Caption := 'Описание объекта';
        LoadFunction(TscrGlobalObject(tvClasses.Selected.Data).Module,
          TscrGlobalObject(tvClasses.Selected.Data).Id, Node.Text,
          Format(VB_GLOBAL_OBJECT, [Node.Text, Node.Text, Node.Text, Node.Text]));
        Node.Text := gdcFunction.FieldByName(fnName).AsString;
      end;
      fpVBClass:
      begin
        Label6.Caption := 'Имя класса';
        tsFuncScript.Caption := 'Описание класса';
        LoadFunction(scrVBClasses, TscrVBClass(tvClasses.Selected.Data).Id,
          Node.Text, Format(VBClASS_TEMPLATE, [Node.Text]));
        Node.Text := gdcFunction.FieldByName(fnName).AsString;
      end;
    end;

  finally
    gdcFunction.EnableControls;
    UnMethodMacro := LocUnMethodMacro;
    //Включаем контролы
    EnableControls;
    //изменяем отображение закладок
    ChangePageVisible;
  end;
end;

procedure TdlgViewProperty.ChangePageVisible;
var
  NT: TFunctionPages;
begin
  NT := GetSelectedNodeType;
  case NT of
    fpEvent, fpMethod, fpMacros,
    fpReportFunction, fpScriptFunction,
    fpVBClass, fpConst, fpGlobalObject:
    begin
      pcFuncParam.ActivePage := tsFunction;
      gsFunctionSynEdit.EnsureCursorPosVisibleEx(True);
    end;
    fpReport:
      pcFuncParam.ActivePage := tsReport;
    fpReportTemplate:
      pcFuncParam.ActivePage := tsReportTemplate;
    fpReportFolder, fpMacrosFolder:
      pcFuncParam.ActivePage := tsDescription;
  else
    pcFuncParam.ActivePage := nil;
  end;
//  pnlParam.Visible := pcFuncParam.ActivePage <> nil;

  pMacrosAddParams.Visible := NT = fpMacros;

  tsParams.TabVisible := not (NT in [fpEvent, fpMethod, fpConst, fpGlobalObject]);

  if pcFunction.ActivePage = tsParams then
    pcFunctionChange(nil);

  dblcbSetFunction.Visible := NT in [fpEvent, fpReportFunction];
end;

procedure TdlgViewProperty.tvClassesChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
  function IsRepNode(Node: TTreeNode):Boolean;
  begin
    Result := GetNodeType(Node) in [fpReport, fpReportFunction, fpReportTemplate];
  end;

  procedure SaveCrossing(const ANameScript, ModuleName: String;
    const FucntionKey: Integer);
  var
    MI: TMenuItem;
    SI: Integer;
    SingleSaver: TCrossingSaver;
  begin
    if (not Assigned(Node)) or (FucntionKey = 0) then
      Exit;

    if pmSpeedReturn.Items.Count > 14 then
    for SI := pmSpeedReturn.Items.Count - 1 downto 14 do
    begin
      TObject(pmSpeedReturn.Items[SI].Tag).Free;
      pmSpeedReturn.Items.Delete(SI);
    end;
    SI := 0;
    while SI < pmSpeedReturn.Items.Count do
      if pmSpeedReturn.Items[SI].Caption = ANameScript then
      begin
        TObject(pmSpeedReturn.Items[SI].Tag).Free;
        pmSpeedReturn.Items.Delete(SI);
      end else
        Inc(SI);
    MI := TMenuItem.Create(Self);
    MI.Caption := ANameScript;
    MI.OnClick := OnSpeedReturnMenuClick;

    SingleSaver := TCrossingSaver.Create;
    SingleSaver.Node := tvClasses.Selected;

    SingleSaver.FunctionKey := FucntionKey;
    SingleSaver.ModuleName := ModuleName;

    MI.Tag := Integer(SingleSaver);
    pmSpeedReturn.Items.Insert(0, MI);
    actSpeedReturn.Enabled := True;
  end;

begin
  if (FSingleFunction) and (ModalResult <> mrCancel) and
    (ModalResult <> mrOk) then
  begin
    MessageBox(Application.Handle,
      'Вы находитесь в режиме редактирования одной функции.'#10#13 +
      'Отредактируйте выделенную функцию и нажмите кнопку "Ок"'#10#13 +
      'для подтверждения изменений или "Отмена" для отказа от'#10#13 +
      'сделанных изменений', MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    AllowChange := False;
    Exit;
  end;

  DisableControls;
  gdcFunction.DisableControls;
  try
    if FEnableChanges then //Флаг указывает на необходимость сохранения изменений
    //Равен Фалсе если идет активная работа с деревом на которую нет необходимости
    //реагировать (например удаление нодов при ролбэке)
    begin
      //эта офигенная проверка нужна для правильной работы отчётов
      //при создании нового отчёта
      if (tvClasses.Selected = Node) and (GetNodeType(Node) = fpReportFunction) then
      begin //Переход с самого на себя
        AllowChange := True;
      end else if (GetNodeType(tvClasses.Selected) = fpReport) and
        IsChild(Node, tvClasses.Selected) and FReportCreated then
      begin //переход с вновь созданного отчета на функцию или шаблон
        AllowChange := True;
        FCanSaveLoad := False; //Если отчет вновь созданный то запрещаем загрузку и запись
      end else if (GetNodeType(tvClasses.Selected) in [fpReportFunction, fpReportTemplate]) and
        (GetNodeType(Node) in [fpReport, fpReportFunction, fpReportTemplate]) and
        ((tvClasses.Selected.Parent = Node) or (Node.Parent = tvClasses.Selected.Parent)) then
      begin //Переход с функции или шаблона
        if FReportCreated then
          FCanSaveLoad := False;  //Если отчет вновь созданный то запрещаем загрузку и запись
        if FReportChanged or (not FReportCreated and FChanged) then
          //Изменена функция или шаблон. Вызываем запрос на сохранение
          AllowChange := SaveChanges
        else  
        if FFunctionChanged or FFunctionNeadSave then
          AllowChange := OverallCommit;
      end else
        begin
        FCanSaveLoad := True;  //Разрешаем загрузку и запись отчета
        //Вызываем запрос на сохранение
        AllowChange := SaveChanges;
      end;
    end;

    case GetSelectedNodeType of
      fpMacros:
        SaveCrossing(tvClasses.Selected.Text +  '(' +
          tvClasses.Selected.Parent.Text + ')', scrMacrosModuleName,
          TscrMacrosItem(tvClasses.Selected.Data).FunctionKey);
      fpReportFunction:
        SaveCrossing(tvClasses.Selected.Text +  '(' +
          tvClasses.Selected.Parent.Text + ')',
          TscrReportFunction(tvClasses.Selected.Data).ModuleName,
          TscrReportFunction(tvClasses.Selected.Data).Id);
      fpEvent:
        SaveCrossing(tvClasses.Selected.Text + '(' +
          tvClasses.Selected.Parent.Text + ')', scrEventModuleName,
          TEventItem(tvClasses.Selected.Data).FunctionKey);
      fpMethod:
        SaveCrossing(tvClasses.Selected.Text +  '(' +
          tvClasses.Selected.Parent.Text + ')', scrMethodModuleName,
          TMethodItem(tvClasses.Selected.Data).FunctionKey);
      fpScriptFunction:
        SaveCrossing(tvClasses.Selected.Text, scrUnkonownModule,
          TscrScriptFunction(tvClasses.Selected.Data).Id);
      fpGlobalObject:
        SaveCrossing(tvClasses.Selected.Text, scrGlobalObject,
          TscrGlobalObject(tvClasses.Selected.Data).Id);
      fpVBClass:
        SaveCrossing(tvClasses.Selected.Text, scrVBClasses,
          TscrVBClass(tvClasses.Selected.Data).Id);
      fpConst:
        SaveCrossing(tvClasses.Selected.Text, scrConst,
          TscrConst(tvClasses.Selected.Data).Id);
    end;
  finally
    gdcFunction.EnableControls;
    EnableControls;
  end;
end;

procedure TdlgViewProperty.CancelFunction;
begin
  DisableControls;
  try
    gdcFunction.Cancel;
    FFunctionChanged := False;
  finally
    EnableControls;
  end;
end;

function TdlgViewProperty.PostFunction(out AnFunctionKey: Integer): Boolean;
var
  Str: TStream;
  Fnc: TrpCustomFunction;
  dlgCopyFunctionRec: TdlgCopyFunctionRec;
begin
  Result := False;

  gsFunctionSynEdit.UpdateRecord;
  gdcFunction.FieldByName(fnName).AsString := dbeFunctionName.Text;
  gdcFunction.FieldByName('COMMENT').AsString := DBMemo1.Lines.Text;
  gdcFunction.FieldByName('language').AsString := dbcbLang.Text;

  if FChanged and not (GetSelectedNodeType in [fpConst, fpGlobalObject]) then
    if WarningFunctionName(gdcFunction.FieldByName(fnName).AsString,
      gdcFunction.FieldByName(fnScript).AsString) then
    begin
      Exit;
    end;

  if not FChanged and not (FFunctionNeadSave and (gdcFunction.State = dsEdit)) then
  begin
    Result := True;
    FFunctionNeadSave := False;
    FFunctionChanged := False;
    Exit;
  end;

  if FChanged and not FFunctionChanged and
    (GetSelectedNodeType in [fpReportFunction, fpEvent]) then
  begin
    if (gdcFunction.RecordUsed > 1) then
    begin
      dlgCopyFunctionRec := TdlgCopyFunctionRec.Create(Self);
      try
        dlgCopyFunctionRec.Transaction := ibtrFunction;
        dlgCopyFunctionRec.Id := gdcFunction.ID;
        dlgCopyFunctionRec.stMessage.Caption := Format(MSG_QUESTION_FOR_COPY,
          [tvClasses.Selected.Text, gdcFunction.FieldByName(fnName).AsString]);
        dlgCopyFunctionRec.ShowModal;

        if dlgCopyFunctionRec.ModalResult = mrOk then
        begin
          Fnc := TrpCustomFunction.Create;
          try
            Fnc.ReadFromDataSet(gdcFunction);
            CancelFunction;
            gdcFunction.Copy('name', gdcFunction.GetUniqueName('copy', Fnc.Name,
              gdcFunction.FieldByName('modulecode').AsInteger), False, False);

            gdcFunction.FieldByName('comment').AsString := Fnc.Comment;

            Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('script'), DB.bmWrite);
            try
              Fnc.Script.SaveToStream(Str);
            finally
              Str.Free;
            end;

            gdcFunction.FieldByName('module').AsString := Fnc.Module;
            gdcFunction.FieldByName('language').AsString := Fnc.Language;

            Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('enteredparams'), DB.bmWrite);
            try
              Fnc.EnteredParams.SaveToStream(Str);
            finally
              Str.Free;
            end;

          finally
            Fnc.Free;
          end;
        end else
        if dlgCopyFunctionRec.ModalResult = mrCancel then
          Exit;
      finally
        dlgCopyFunctionRec.Free;
      end;
    end;
  end;

  try

    if gdcFunction.FieldByName('id').IsNull then
      gdcFunction.FieldByName('id').AsInteger := gdcFunction.GetNextID;

    if FModuleName = MainModuleName then
      SaveReportResult;

    UpDataFunctionParams(FFunctionParams);

    SaveFunctionParams;

    if Assigned(Debugger) then
    begin
      Debugger.DisplayScriptFunction.BreakPointsPrepared := False;
      Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('breakpoints'), DB.bmWrite);
      try
        Debugger.DisplayDebugLines.SaveBPToStream(Str);
      finally
        Str.Free;
      end;
    end;
    gdcFunction.Post;

    AnFunctionKey := gdcFunction.FieldByName('id').AsInteger;

    //Регестрирум функцию в глобальном списке функций
    Fnc := glbFunctionList.FindFunction(AnFunctionKey);
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
    end;

    FFunctionChanged := False;
    FFunctionNeadSave := False;

    Result := True;
    if (FReportChanged) and (GetSelectedNodeType = fpReportFunction) then
      FReportChanged:= not Result;
  except
    on E: Exception do
    begin
      MessageBox(Application.Handle, PChar('Произошла ошибка ' + E.Message), MSG_WARNING,
       MB_OK or MB_ICONERROR or MB_TASKMODAL);
    end;
  end;
end;

procedure TdlgViewProperty.LoadFunction(const AnModule: String;
 const AnFunctionKey: Integer; const AnFunctionName: String = '';
 const AnParams: String = '');
var
  Str: TStream;
  ChangeFlag: Boolean;
begin
  ibqOwner.Close;
  FErrorLine := - 1;
  StartTrans;
  ChangeFlag := FChanged;
  FModuleName := AnModule;
  gdcFunction.Close;
  gdcFunction.SubSet := 'ByID';
  gdcFunction.ID := AnFunctionKey;
  gdcFunction.Open;
  if gdcFunction.Eof then
  begin
    gdcFunction.Insert;
    gdcFunction.FieldByName('language').AsString := DefaultLanguage;
    gdcFunction.FieldByName('module').AsString := FModuleName;
    gdcFunction.FieldByName('name').AsString := AnFunctionName;
    gdcFunction.FieldByName(fnScript).AsString := AnParams;
    TCrackDBSynEdit(gsFunctionSynEdit).NewOnChange(gsFunctionSynEdit);

    gdcFunction.FieldByName('modulecode').AsInteger := GetObjectId(tvClasses.Selected);
    gdcFunction.FieldByName('publicfunction').Required := False;

    FCompiled := False;
  end else
  begin
    gdcFunction.Edit;

    FModuleName := gdcFunction.FieldByName('module').AsString;
    try
      if not gdcFunction.FieldByName('enteredparams').IsNull then
      begin
        Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('enteredparams'), DB.bmRead);
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

    FCompiled := True;
    gsFunctionSynEdit.Modified := False;
  end;

  if Assigned(Debugger) then
  begin
    if not IsExecuteScript then
    begin
      Debugger.DisplayScriptFunction.ReadFromDataSet(gdcFunction);
      Debugger.DisplayDebugLines.Clear;
      Debugger.DisplayDebugLines.CheckSize(Debugger.DisplayScriptFunction.Script.Count);
      Str :=  gdcFunction.CreateBlobStream(gdcFunction.FieldByName('BreakPoints'), DB.bmRead);
      try
        if Str.Size > 0 then
          Debugger.DisplayDebugLines.ReadBPFromStream(Str);
      finally
        Str.Free;
      end;
    end else
    begin
      Debugger.DisplayDebugLines.Assign(Debugger.ExecuteDebugLines);
      Debugger.DisplayScriptFunction.Assign(Debugger.ExecuteScriptFunction);
    end;
  end;

  FChanged := ChangeFlag;
  FFunctionChanged := False;
  FFunctionNeadSave := False;
  FReportChanged := False;
  ChangeHighLight;
  ParserInit;
  dbeFunctionName.Enabled := (FModuleName <> scrEventModuleName) and
    (FModuleName <> scrMethodModuleName);
  ibqOwner.Params[0].AsInteger := gdcFunction.Id;
  ibqOwner.Open;
end;

function TdlgViewProperty.GetObjectId(ANode: TTreeNode): Integer;
var
  DataSet: TIBDataSet;
begin
  Assert(Assigned(ANode) and Assigned(ANode.Data) and
    Assigned(ANode.Parent.Data), MSG_ERROR);

  if (TObject(ANode.Data) is TMethodItem) then
  begin
    Result := TCustomMethodClass(ANode.Parent.Data).Class_Key;
    if Result = 0 then
    begin
      FindClass(ANode.Parent);
      Result := TCustomMethodClass(ANode.Parent.Data).Class_Key;
    end;
  end
  else if TObject(ANode.Data) is TscrMacrosItem then
  begin
    if TscrMacrosGroupItem(ANode.Parent.Data).IsGlobal then
      Result := OBJ_APPLICATION
    else
      Result := FObjectKey;
  end
  else if TObject(ANode.Data) is TscrReportFunction then
  begin
    if FComponent = Application then
    begin
      while Assigned(ANode.Parent.Parent) do
        ANode := ANode.Parent;
      DataSet := TIBDataSet.Create(nil);
      try
        DataSet.Transaction := ibtrFunction;
        DataSet.SelectSQL.Text := 'SELECT * FROM evt_object WHERE ' +
          fnReportGroupKey + ' = ' + IntToStr(TscrCustomItem(ANode.Data).Id);
        DataSet.Open;
        Result := DataSet.FieldByName(fnId).AsInteger;
        if Result = 0 then
          Result := OBJ_APPLICATION;
      finally
        DataSet.Free;
      end;
    end
    else
      Result := FObjectKey;
  end
  else if TObject(ANode.Data) is TscrScriptFunction then
  begin
    Result := FObjectKey;
  end
  else if TObject(ANode.Data) is TscrVBClass then
  begin
    Result := OBJ_APPLICATION;
  end
  else if TObject(ANode.Data) is TEventItem then
  begin
    Result := TEventObject(ANode.Parent.Data).ObjectKey;
    if (Result = 0) and FindObject(ANode.Parent) then
      Result := TEventObject(ANode.Parent.Data).ObjectKey;
  end
  else if (TObject(ANode.Data) is TscrConst) or
    (TObject(ANode.Data) is TscrGlobalObject) then
  begin
    Result := OBJ_APPLICATION;
  end else
    raise Exception.Create('Can`t find valid object key');
end;

procedure TdlgViewProperty.PrepareTestResult;
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

procedure TdlgViewProperty.dbcbLangChange(Sender: TObject);
var
  NT: TFunctionPages;
begin
  SetChanged;
  NT := GetNodeType(tvClasses.Selected);
  if gdcFunction.FieldByName('language').AsString = DefaultLanguage then
  begin
    if gdcFunction.State = dsInsert then
    begin
      case NT of
        fpEvent:
          gdcFunction.FieldByName(fnScript).AsString :=
            TEventItem(tvClasses.Selected.Data).ComplexParams[fplVBScript];
        fpMethod:
          gdcFunction.FieldByName(fnScript).AsString :=
            TMethodItem(tvClasses.Selected.Data).ComplexParams[fplVBScript];
        fpMacros:
          gdcFunction.FieldByName(fnScript).AsString :=
            Format(VB_MACROS_TEMPLATE, [gdcFunction.FieldByName(fnName).AsString]);
        fpScriptFunction:
          gdcFunction.FieldByName(fnScript).AsString :=
            Format(VB_SCRIPTFUNCTION_TEMPLATE, [gdcFunction.FieldByName(fnName).AsString]);
        fpReportFunction:
        begin
          case TscrReportFunction(tvClasses.Selected.Data).FncType of
            rfMainFnc:
              gdcFunction.FieldByName(fnScript).AsString :=
                Format(VB_MAINFUNCTION_TEMPLATE,[
                  gdcFunction.FieldByName(fnName).AsString,
                  gdcFunction.FieldByName(fnName).AsString]);
            rfParamFnc:
              gdcFunction.FieldByName(fnScript).AsString :=
                Format(VB_PARAMFUNCTION_TEMPLATE,[
                  gdcFunction.FieldByName(fnName).AsString,
                  gdcFunction.FieldByName(fnName).AsString]);
            rfEventFnc:
              gdcFunction.FieldByName(fnScript).AsString :=
                Format(VB_EVENTFUNCTION_TEMPLATE,[
                  gdcFunction.FieldByName(fnName).AsString,
                  gdcFunction.FieldByName(fnName).AsString]);
          end;
        end;
      end;
    end;
  end else
  begin
    if gdcFunction.State = dsInsert then
    begin
      case NT of
        fpEvent:
          gdcFunction.FieldByName(fnScript).AsString :=
            TEventItem(tvClasses.Selected.Data).ComplexParams[fplJScript];
        fpMethod:
          gdcFunction.FieldByName(fnScript).AsString :=
            TMethodItem(tvClasses.Selected.Data).ComplexParams[fplJScript];
        fpMacros:
          gdcFunction.FieldByName(fnScript).AsString :=
            Format(JS_MACROS_TEMPLATE, [gdcFunction.FieldByName(fnName).AsString]);
        fpScriptFunction:
          gdcFunction.FieldByName(fnScript).AsString :=
            Format(JS_SCRIPTFUNCTION_TEMPLATE, [gdcFunction.FieldByName(fnName).AsString]);
        fpReportFunction:
        begin
          case TscrReportFunction(tvClasses.Selected.Data).FncType of
            rfMainFnc:
              gdcFunction.FieldByName(fnScript).AsString :=
                Format(JS_MAINFUNCTION_TEMPLATE,[Name]);
            rfParamFnc:
              gdcFunction.FieldByName(fnScript).AsString :=
                Format(JS_PARAMFUNCTION_TEMPLATE,[Name]);
            rfEventFnc:
              gdcFunction.FieldByName(fnScript).AsString :=
                Format(JS_EVENTFUNCTION_TEMPLATE,[Name]);
          end;
        end;
      end;
    end;
  end;
  ChangeHighLight;
end;

procedure TdlgViewProperty.actFuncCommitExecute(Sender: TObject);
var
  CaretXY: TPoint;
begin
  DisableControls;
  gdcFunction.DisableControls;
  try
    CaretXY := gsFunctionSynEdit.CaretXY;
    if IsReport(tvClasses.Selected) then
      FCanSaveLoad := True;
    if OverallCommit then
      tvClassesChange(tvClasses, tvClasses.Selected);
    gsFunctionSynEdit.CaretXY := CaretXY;
  finally
    gdcFunction.EnableControls;
    EnableControls;
  end;
end;

procedure TdlgViewProperty.actFuncRollbackExecute(Sender: TObject);
begin
  DisableControls;
  gdcFunction.DisableControls;
  try
    OverallRollback;
    tvClassesChange(tvClasses, tvClasses.Selected);
  finally
    gdcFunction.EnableControls;
    EnableControls;
  end;
end;

procedure TdlgViewProperty.actFuncCommitUpdate(Sender: TObject);
begin
  actFuncCommit.Enabled := FChanged;
  actFuncRollback.Enabled := FChanged;
end;


procedure TdlgViewProperty.EditFunction;
begin
  if not (gdcFunction.State in [dsEdit, dsInsert]) then
  begin
    FCompiled := True;
    if gdcFunction.Eof then
      LoadFunction(FModuleName, 0)
    else
      LoadFunction(FModuleName, gdcFunction.FieldByName('id').AsInteger);
  end;
end;

procedure TdlgViewProperty.SetChanged;
begin
  if FEnableControls = 0 then
  begin
    FChanged := True;
    FCompiled := False;
    if (GetSelectedNodeType = fpReportFunction) then
      FReportChanged := True;
    MethodVisible(tvClasses.Selected, True);
  end;
end;

procedure TdlgViewProperty.dbeFunctionNameChange(Sender: TObject);
begin
  SetChanged;
end;

procedure TdlgViewProperty.dbeFunctionNameEnter(Sender: TObject);
begin
  EditFunction;
end;

function TdlgViewProperty.CommitTrans: Boolean;
begin
  Result := False;
  DisableControls;
  try
    try
      if ibtrFunction.InTransaction then
        ibtrFunction.Commit;
      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, PChar(MSG_ERROR_SAVE + E.Message),
         MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
        ibtrFunction.Rollback;
      end;
    end;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty.StartTrans;
begin
  if not ibtrFunction.InTransaction then
    ibtrFunction.StartTransaction;
end;

function TdlgViewProperty.OverallCommit: Boolean;
var
  LFunctionKey: Integer;
  ReReadConst, ReCreateGlobalObject, ReReadVBClass: Boolean;
begin
  Result := False;
  if not IBLogin.LoggedIn then
  begin
    if FChanged or FFunctionChanged then
      MessageBox(Application.Handle, 'Потеряно соединение с базой',
        MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
    Exit;
  end;

  ReReadVBClass := False;
  ReReadConst := False;
  ReCreateGlobalObject := False;

  if FChanged or FFunctionChanged or FFunctionNeadSave then
  begin
    case GetSelectedNodeType of
      fpMacros:
      begin
        //сохраняем изменения макроса
        ScriptFactory.ReloadFunction(TscrMacrosItem(tvClasses.Selected.Data).FunctionKey);
        Result := PostMacros(tvClasses.Selected);
      end;
      fpMacrosFolder:
        //сохраняем изменения группы макросов
        Result := PostMacrosGroup(tvClasses.Selected);
      fpReportFolder:
        //сохраняем изменения группы отчётов
        Result := PostReportGroup(tvClasses.Selected);
      fpReportFunction:
      begin
        ScriptFactory.ReloadFunction((TObject(tvClasses.Selected.Data) as TscrCustomItem).Id);
        Result := PostReportFunction(tvClasses.Selected);
      end;
      fpReport:
      begin
        //сохраняем отчёт
//        if FCanSaveLoad then
          Result := PostReport(tvClasses.Selected);
          if Result and not FCanSaveLoad then
            FCanSaveLoad := True;
      end;
      fpReportTemplate:
        Result := PostReportTemplate(tvClasses.Selected);
      fpEvent:
      begin
        LFunctionKey := (TObject(tvClasses.Selected.Data) as TEventItem).FunctionKey;
        ScriptFactory.ReloadFunction(LFunctionKey);
        Result := PostFunction(LFunctionKey);
        if Result then
          (TObject(tvClasses.Selected.Data) as TEventItem).FunctionKey := LFunctionKey;
        if Result then
          Result := Result and (tvClasses.Selected.Parent <> nil);
        if Result then
          Result := Result and FindObject(tvClasses.Selected.Parent);
        if Result then
          Result := Result and SaveEvent(tvClasses.Selected.Parent, tvClasses.Selected);
        if LFunctionKey > 0 then
          UpdateEventSpec(tvClasses.Selected.Parent, 1)
        else
          UpdateEventSpec(tvClasses.Selected.Parent, - 1);
        AddEventToList(tvClasses.Selected);
        if Result and Assigned(dlg_gsResizer_ObjectInspector) then
          dlg_gsResizer_ObjectInspector.EventSync(TEventItem(tvClasses.Selected.Data).EventObject.ObjectName,
          TEventItem(tvClasses.Selected.Data).Name);
      end;
      fpMethod:
      begin
        MethodControl.ClearMacroCache;
        FindClass(tvClasses.Selected.Parent);
                                
        LFunctionKey := (TObject(tvClasses.Selected.Data) as TMethodItem).FunctionKey;
        ScriptFactory.ReloadFunction(LFunctionKey);
        Result := PostFunction(LFunctionKey);
        if Result then
          (TObject(tvClasses.Selected.Data) as TMethodItem).FunctionKey := LFunctionKey;
        if Result then
          Result := Result and (tvClasses.Selected.Parent <> nil);

        if Result then
          Result := Result and SaveMethod(tvClasses.Selected.Parent, tvClasses.Selected);

        if LFunctionKey > 0 then
          UpdateMethodSpec(tvClasses.Selected.Parent, 1)
        else
          UpdateMethodSpec(tvClasses.Selected.Parent, -1);
      end;
      fpScriptFunction:
      begin
        LFunctionKey := (TObject(tvClasses.Selected.Data) as TscrCustomItem).Id;
        ScriptFactory.ReloadFunction(LFunctionKey);
        Result := PostFunction(LFunctionKey);
        if Result then
          (TObject(tvClasses.Selected.Data) as TscrCustomItem).Id := LFunctionKey;
      end;
      fpGlobalObject:
      begin
        ScriptFactory.Reset;
        ReCreateGlobalObject := FChanged;
        LFunctionKey := (TObject(tvClasses.Selected.Data) as TscrCustomItem).Id;
        Result := PostFunction(LFunctionKey);
        if Result then
          (TObject(tvClasses.Selected.Data) as TscrCustomItem).Id := LFunctionKey;
      end;
      fpConst:
      begin
        ScriptFactory.Reset;
        ReReadConst := FChanged;
        ReReadVBClass := FChanged;
        ReCreateGlobalObject := FChanged;
        LFunctionKey := (TObject(tvClasses.Selected.Data) as TscrCustomItem).Id;
        Result := PostFunction(LFunctionKey);
        if Result then
          (TObject(tvClasses.Selected.Data) as TscrCustomItem).Id := LFunctionKey;
      end;
      fpVBClass:
      begin
        ScriptFactory.Reset;
        ReReadVBClass := FChanged;
        ReCreateGlobalObject := FChanged;
        LFunctionKey := (TObject(tvClasses.Selected.Data) as TscrVBClass).Id;
        Result := PostFunction(LFunctionKey);
        if Result then
          (TObject(tvClasses.Selected.Data) as TscrVBClass).Id := LFunctionKey;
      end;
    end;

    if not FReportCreated then
    begin
      if Result then //если все ОК делаем полный коммит
      begin
        Result := CommitTrans;
        if Assigned(dm_i_ClientReport) then
        begin
          if ReReadConst  then
            dm_i_ClientReport.CreateVBConst;
          if ReReadVBClass then
            dm_i_ClientReport.CreateVBClasses;
          if ReCreateGlobalObject then
            dm_i_ClientReport.CreateGlObjArray;
        end;
      end{ else
        RollbackTrans};
    end;

   FChanged := (not Result) or (FReportCreated)
  end else
    Result := True;
end;

procedure TdlgViewProperty.OverallRollback;
var
  Flag: Boolean;
  TN: TTreeNode;
begin
  //Сохраняем флаг изменения шаблона или функции отчёта
  Flag := FReportChanged;
  //Делаем канселы соответ. датасеты
  case GetSelectedNodeType of
    fpReportTemplate: CancelTemplate;
    fpReportFunction: CancelReportFunction;
    fpReport: CancelReport;
    fpMacros: CancelMacros;
    fpMacrosFolder: CancelMacrosGroup;
    fpReportFolder: CancelReportGroup;
    fpScriptFunction, fpVBClass:
      CancelScriptFunction;
    fpEvent, fpMethod:
      CancelFunction;
  end;

  DisableChanges;
  DisableControls;
  try
    if (GetSelectedNodeType in [fpReport, fpReportFunction, fpReportTemplate])
      and FReportCreated and not Flag then
      begin
        //отчет новый и небыло изменений в шаблоне или функциях
        //удаляем нод
        TN:= tvClasses.Selected;
        if GetSelectedNodeType in [fpReportFunction, fpReportTemplate] then
        begin
          tvClasses.Selected.Parent.Parent.Selected := True;
          Assert(GetSelectedNodeType <> fpNone);
          TN.Parent.Delete;
        end else
        begin
          tvClasses.Selected.Parent.Selected := True;
          Assert(GetSelectedNodeType <> fpNone);
          TN.Delete;
        end;
        FReportCreated := False;
      end;

    //Делаем откат если не создан отчёт или создан но не изменен
    if (not FReportCreated) or (FReportCreated and not Flag) then
    begin
      RollbackTrans;
      FChanged := False;
      FFunctionNeadSave := False;
    end;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

function TdlgViewProperty.AddObject(
  var AnEventObject: TEventObject; const AnParentObject: TEventObject;
  const AnObjectType: Integer = 0): Boolean;
var
  LocEvtObj: TEventObject;
  LocId: Integer;
begin
  Result := False;
  ibtrObject.StartTransaction;
  try
    if gdcDelphiObject.Active then
      gdcDelphiObject.Close;
    gdcDelphiObject.SubSet := ssByID;
    gdcDelphiObject.ID := -1;
    gdcDelphiObject.Open;
    gdcDelphiObject.Insert;
    gdcDelphiObject.FieldByName('objectname').AsString := AnEventObject.ObjectName;
    {$IFDEF LEFACY_EVT_OBJECT}
//    gdcDelphiObject.FieldByName('name').AsString := AnEventObject.ObjectName;
//    gdcDelphiObject.FieldByName('objecttype').AsInteger := 0;
    {$ENDIF}

    //!!! для not (AnEventObject.SelfObject is TCustomForm) требуется проверка
    if (AnParentObject <> nil) and not (AnEventObject.SelfObject is TCustomForm) then
      gdcDelphiObject.FieldByName('parent').AsVariant := AnParentObject.ObjectKey
    else
      gdcDelphiObject.FieldByName('parent').Clear;
    gdcDelphiObject.Post;

    LocId :=  gdcDelphiObject.FieldByName('id').AsInteger;
    ibtrObject.Commit;
    AnEventObject.ObjectKey := LocId;
    Result := True;

    // Предполагается что родительский объект из списка
    // SelfObject используется в данном окне для хранения ссылки на объект
    // если он создан в форме а не считан из списка
    //!!! для not (AnEventObject.SelfObject is TCustomForm) требуется проверка
    if Assigned(AnParentObject) and not (AnEventObject.SelfObject is TCustomForm) then
    begin
      // Если родительский объект создан в форме присваиваем, то ищем по реальному делфовскому объекту
      if Assigned(AnParentObject.SelfObject) then
      begin
        LocEvtObj := GetEventControl.EventObjectList.FindAllObject(AnParentObject.SelfObject);
        // Если родительский объект найден, то добавляем его в список и меняем ссылку
        if Assigned(LocEvtObj) then
        begin
          LocEvtObj.ChildObjects.AddObject(AnEventObject);
          AnEventObject := LocEvtObj.ChildObjects.FindObject(AnEventObject.ObjectName);
        end else
          raise Exception.Create('Нельзя обновить список объектов');
      end else
      begin
        // Если объект вытянут из списка то добавляем прямо в него
        AnParentObject.ChildObjects.AddObject(AnEventObject);
        AnEventObject := AnParentObject.ChildObjects.FindObject(AnEventObject.ObjectName);
      end;
    end else
    begin
      // Если парент не задан, то добавляем в корень
      GetEventControl.EventObjectList.AddObject(AnEventObject);
      AnEventObject := GetEventControl.EventObjectList.FindObject(AnEventObject.ObjectName);
    end;
  except
    on E: Exception do
    begin
      MessageBox(Application.Handle, PChar(MSG_ERROR_CREATE_OBJECT +
        E.Message), MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
      ibtrObject.RollBack;
    end;
  end;
end;

function TdlgViewProperty.FindObject(const AnTreeNode: TTreeNode;
  const AnIsCreate: Boolean = True): Boolean;
var
  TopParentKey: Variant;
  LocEvtObj: TEventObject;
begin
  TopParentKey := NULL;
  try
    LocEvtObj := (TObject(AnTreeNode.Data) as TEventObject);
    if Assigned(LocEvtObj) and (LocEvtObj.ObjectKey <> 0) then
    begin
      Result := True;
      Exit;
    end;

    if (AnTreeNode.Parent.Parent <> nil) and
      not {!!!} LocEvtObj.SelfObject.InheritsFrom(TCustomForm) then
    begin
      Result := FindObject(AnTreeNode.Parent, AnIsCreate);
      TopParentKey := TEventObject(AnTreeNode.Parent.Data).ObjectKey;
    end else
    begin
      // Здесь сохранение идет по реальному объекту
      // Поэтому не будет обновления списка
      LocEvtObj.ObjectKey := gdcDelphiObject.AddObject(LocEvtObj.SelfObject);
      Result := LocEvtObj.ObjectKey <> 0;
      Exit;
    end;

    if Result and AnIsCreate then
      Result := AddObject(LocEvtObj, TEventObject(AnTreeNode.Parent.Data));

      AnTreeNode.Data := LocEvtObj;
  except
    on E: Exception do
    begin
      MessageBox(Application.Handle, PChar(MSG_ERROR_FIND_OBJECT + E.Message),
       MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
      Result := False;
    end;
  end;
end;

function TdlgViewProperty.FindClass(const AnTreeNode: TTreeNode;
 const AnIsCreate: Boolean = True): Boolean;
var
  TopParentKey: Variant;
  MC: TCustomMethodClass;
begin
  TopParentKey := NULL;
  MC := (TObject(AnTreeNode.Data) as TCustomMethodClass);
  try
    if not Assigned(MC) or (MC.Class_Key <> 0) then
    begin
      Result := True;
      Exit;
    end;

    if AnTreeNode.Parent.Parent <> nil then
    begin
      Result := FindClass(AnTreeNode.Parent, AnIsCreate);
      TopParentKey := TCustomMethodClass(AnTreeNode.Parent.Data).Class_Key;
    end else
    begin
      AddClass(TCustomMethodClass(AnTreeNode.Data), NULL);{needs tst}
      Result := MC.Class_Key <> 0;
      Exit;
    end;

    if Result and AnIsCreate then
      Result := AddClass(MC, TopParentKey);
  except
    on E: Exception do
    begin
      MessageBox(Application.Handle, PChar(MSG_ERROR_FIND_OBJECT + E.Message),
       MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
      Result := False;
    end;
  end;
end;

function TdlgViewProperty.AddClass(const AnMethodClass: TCustomMethodClass; const AnParent: Variant;
 const AnObjectType: Integer = 1): Boolean;
var
  DataSet: TIBDataSet;
  LocId: Integer;
begin
  Result := False;
  ibtrObject.StartTransaction;
  try
    DataSet := TIBDataSet.Create(nil);
    try
      DataSet.Transaction := ibtrObject;
      DataSet.SelectSQL.Text := 'SELECT * FROM evt_object WHERE (UPPER(classname)' +
        ' = UPPER(''' + AnMethodClass.Class_Name + ''')) AND '#13#10 +
        '(UPPER(subtype) = UPPER(''' + AnMethodClass.SubType + '''))';

      DataSet.Open;
      if DataSet.IsEmpty then
      begin
        gdcDelphiObject.SubSet := 'ByID';
        gdcDelphiObject.ID := -1;
        gdcDelphiObject.Open;
        gdcDelphiObject.Insert;
        if AnObjectType = 0 then
          raise Exception.Create('Нельзя сохранять объекты, как классы')
//          gdcDelphiObject.FieldByName('objectname').AsString := AnMethodClass.Class_Name
        else
        begin
          gdcDelphiObject.FieldByName('classname').AsString := AnMethodClass.Class_Name;
          gdcDelphiObject.FieldByName('subtype').AsString := AnMethodClass.SubType;
          {$IFDEF LEFACY_EVT_OBJECT}
//          gdcDelphiObject.FieldByName('name').AsString :=
//            AnMethodClass.Class_Name + AnMethodClass.SubType;
//          gdcDelphiObject.FieldByName('objecttype').AsInteger := 1;
          {$ENDIF}
        end;
        gdcDelphiObject.FieldByName('parent').AsVariant := AnParent;
        gdcDelphiObject.Post;

        LocId := gdcDelphiObject.FieldByName('id').AsInteger;
      end else
        LocId := DataSet.FieldByName('id').AsInteger;

      ibtrObject.Commit;
      AnMethodClass.Class_Key := LocID;
      Result := True;
    finally
      DataSet.Free;
    end;
  except
    on E: Exception do
    begin
      MessageBox(Application.Handle, PChar(MSG_ERROR_CREATE_OBJECT +
        E.Message), MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
      ibtrObject.RollBack;
    end;
  end;
end;

function TdlgViewProperty.SaveEvent(const AnObjectNode: TTreeNode;
  const AnEventNode: TTreeNode): Boolean;
begin
  Result := gdcEvent.SaveEvent(AnObjectNode, AnEventNode);
end;

function TdlgViewProperty.SaveMethod(const AnClassNode: TTreeNode;
  const AnMethodNode: TTreeNode): Boolean;
var
  LibsqlCheck: TIBSQL;
//  SQLSaver: String;
begin
  Result := False;
  if (TObject(AnMethodNode.Data) as TMethodItem).FunctionKey = 0 then
    TMethodItem(AnMethodNode.Data).Disable := False;
  try
    LibsqlCheck := TIBSQL.Create(nil);
    try
      LibsqlCheck.Database := ibsqlInsertEvent.Database;
      LibsqlCheck.Transaction := ibsqlInsertEvent.Transaction;
      LibsqlCheck.SQL.Text := 'SELECT * FROM evt_objectevent WHERE objectkey = ' +
       ' :objectkey AND eventname = :eventname';
      LibsqlCheck.Params[0].AsInteger :=
       (TObject(AnClassNode.Data) as TCustomMethodClass).Class_Key;
      LibsqlCheck.Params[1].AsString :=
       AnsiUpperCase((TObject(AnMethodNode.Data) as TMethodItem).Name);
      LibsqlCheck.ExecQuery;
      if not LibsqlCheck.Eof then
      begin
        Result := (LibsqlCheck.FieldByName('functionkey').AsInteger =
         (TObject(AnMethodNode.Data) as TMethodItem).FunctionKey);
        if not Result then
        begin
          LibsqlCheck.Close;
          LibsqlCheck.SQL.Text := 'DELETE FROM evt_objectevent WHERE objectkey = ' +
           ' :objectkey AND eventname = :eventname';
          LibsqlCheck.Params[0].AsInteger :=
           (TObject(AnClassNode.Data) as TCustomMethodClass).Class_Key;
          LibsqlCheck.Params[1].AsString :=
           AnsiUpperCase((TObject(AnMethodNode.Data) as TMethodItem).Name);
          LibsqlCheck.ExecQuery;
        end else
          begin
            Result := ((LibsqlCheck.FieldByName('disable').AsInteger <> 0) =
             (TObject(AnMethodNode.Data) as TMethodItem).Disable);
            if not Result then
            begin
              LibsqlCheck.Close;
              LibsqlCheck.SQL.Text := 'UPDATE evt_objectevent ' +
                'SET disable = :disable WHERE ' +
                'objectkey = :objectkey AND eventname = :eventname';
              if (TObject(AnMethodNode.Data) as TMethodItem).Disable then
                LibsqlCheck.Params[0].AsInteger := 1
              else
                LibsqlCheck.Params[0].AsInteger := 0;
              LibsqlCheck.Params[1].AsInteger :=
               (TObject(AnClassNode.Data) as TCustomMethodClass).Class_Key;
              LibsqlCheck.Params[2].AsString :=
                AnsiUpperCase((TObject(AnMethodNode.Data) as TMethodItem).Name);
              LibsqlCheck.ExecQuery;
              Result := True;
            end;
            Exit;
          end
      end;
    finally
      LibsqlCheck.Free;
    end;

    if (TObject(AnMethodNode.Data) as TMethodItem).FunctionKey <> 0 then
    begin
      ibsqlInsertEvent.Close;
      ibsqlInsertEvent.ParamByName('id').AsInteger :=
        GetUniqueKey(gdcFunction.Database, gdcFunction.Transaction);
      ibsqlInsertEvent.ParamByName('objectkey').AsInteger :=
       (TObject(AnClassNode.Data) as TCustomMethodClass).Class_Key;
      ibsqlInsertEvent.ParamByName('functionkey').AsInteger :=
       (TObject(AnMethodNode.Data) as TMethodItem).FunctionKey;
      ibsqlInsertEvent.ParamByName('eventname').AsString :=
       AnsiUpperCase((TObject(AnMethodNode.Data) as TMethodItem).Name);
      ibsqlInsertEvent.ParamByName('afull').AsInteger := -1;
      if (TObject(AnMethodNode.Data) as TMethodItem).Disable then
        ibsqlInsertEvent.ParamByName('Disable').AsInteger := 1
      else
        ibsqlInsertEvent.ParamByName('Disable').AsInteger := 0;
      ibsqlInsertEvent.ExecQuery;
      ibsqlInsertEvent.Close;
    end;
    ibsqlInsertEvent.Transaction.Commit;
    ibsqlInsertEvent.Transaction.StartTransaction;
    Result := True;
  except
    on E: Exception do
      MessageBox(Application.Handle, PChar(MSG_ERROR_SAVE_EVENT + E.Message),
       MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
  end;
end;

procedure TdlgViewProperty.RollbackTrans;
begin
  try
    if ibtrFunction.InTransaction then
      ibtrFunction.Rollback;
  except
    on E: Exception do
    begin
      MessageBox(Application.Handle, PChar(MSG_ERROR_ROLLBACK + E.Message),
       MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
      ibtrFunction.Rollback;
    end;
  end;
end;

procedure TdlgViewProperty.dblcbSetFunctionClick(Sender: TObject);
var
  LAllowChange: Boolean;
  Key: Integer;
begin
  Key := dblcbSetFunction.KeyValue;
  if TObject(tvClasses.Selected.Data) is TscrReportFunction and
    (TscrReportFunction(tvClasses.Selected.Data).FncType = rfMainFnc) and
    (dblcbSetFunction.KeyValue = 0) then
    LAllowChange := False
  else
    tvClassesChanging(tvClasses, tvClasses.Selected, LAllowChange);
  dblcbSetFunction.KeyValue := Key;
  if LAllowChange then
  begin
    if TObject(tvClasses.Selected.Data) is TCustomFunctionItem then
      TCustomFunctionItem(tvClasses.Selected.Data).FunctionKey :=
        dblcbSetFunction.KeyValue
    else if TObject(tvClasses.Selected.Data) is TscrReportFunction then
       TscrReportFunction(tvClasses.Selected.Data).Id :=
          dblcbSetFunction.KeyValue;
    tvClassesChange(tvClasses, tvClasses.Selected);
    FFunctionChanged := dblcbSetFunction.KeyValue <> 0;
    if Assigned(dlg_gsResizer_ObjectInspector) and (TObject(tvClasses.Selected.Data) is TEventItem)then
    begin
      AddEventToList(tvClasses.Selected);
      dlg_gsResizer_ObjectInspector.EventSync(TEventItem(tvClasses.Selected.Data).EventObject.ObjectName,
      TEventItem(tvClasses.Selected.Data).Name);
    end;
    tvClasses.Invalidate;
  end else
    if TObject(tvClasses.Selected.Data) is TCustomFunctionItem then
      dblcbSetFunction.KeyValue :=
        (TObject(tvClasses.Selected.Data) as TCustomFunctionItem).FunctionKey
    else if TObject(tvClasses.Selected.Data) is TscrReportFunction then
       dblcbSetFunction.KeyValue :=
         (TObject(tvClasses.Selected.Data) as TscrReportFunction).Id;
end;

procedure TdlgViewProperty.dblcbSetFunctionKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    dblcbSetFunction.KeyValue := 0;
    dblcbSetFunctionClick(dblcbSetFunction);
  end;
end;

procedure TdlgViewProperty.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := False;
  if Assigned(Debugger) and (Debugger.IsPaused) then
  begin
    if MessageBox(Application.Handle,
      'Вы находитесь в режиме отладки.'#13 +
      'Для выхода из этого режима и за'#13 +
      'крытия окна нажмите "OK".', MSG_WARNING, MB_OKCANCEL or MB_TASKMODAL) = ID_Ok then
    begin
      actProgramResetExecute(nil);
      CanClose := True;
    end;
  end else
    CanClose := True;

  if CanClose then
    tvClassesChanging(tvClasses, nil, CanClose);

  if CanClose then
  begin
    FindDialog1.CloseDialog;
    FindInTreeDialog.CloseDialog;
    ReplaceDialog1.CloseDialog;
  end;
end;

function TdlgViewProperty.GetName(const AName: String; const AParentNode: TTreeNode): String;
var
  I, K: Integer;
  NodeCount: Integer;
begin
  K := 0;
  I := 0;
  Result := AName;
  NodeCount := AParentNode.Count;
  while I < NodeCount do
  begin
    while (I < NodeCount) and (Result <> AParentNode.Item[I].Text) do
    begin
      Inc(I);
    end;
    if I < NodeCount then
    begin
      Inc(K);
      Result := AName + ' (' + IntToStr(K) + ')';
      I := 0;
    end;
  end;
end;

procedure TdlgViewProperty.actAddFolderExecute(Sender: TObject);
var
  Node, ParentFolder: TTreeNode;
  MacrosGroupItem: TscrMacrosGroupItem;
  ReportGroupItem: TscrReportGroupItem;
begin
  if not (GetNodeType(tvClasses.Selected) in
    [fpMacros, fpMacrosFolder, fpReport, fpReportFolder]) then
    Exit;

  if SaveChanges then
  begin
    ParentFolder := GetParentFolder(tvClasses.Selected);
    if TObject(ParentFolder.Data) is TscrMacrosGroupItem then
    begin
      MacrosGroupItem := TscrMacrosGroupItem.Create(False);
      MacrosGroupItem.Name := GetName(NEW_FOLDER_NAME, ParentFolder);
      MacrosGroupItem.IsGlobal := TscrMacrosGroupItem(ParentFolder.Data).IsGlobal;
      MacrosGroupItem.Parent := TscrMacrosGroupItem(ParentFolder.Data).Id;
      Node := AddItemNode(MacrosGroupItem, ParentFolder);
      Node.Selected := True;
      Assert(GetSelectedNodeType <> fpNone);
      Node.EditText;
    end
    else
      if TObject(ParentFolder.Data) is TscrReportGroupItem then
      begin
        ReportGroupItem := TscrReportGroupItem.Create(False);
        ReportGroupItem.Name := GetName(MSG_REPORT_GROUP, ParentFolder);
        ReportGroupItem.Parent := TscrreportGroupItem(ParentFolder.Data).id;
        Node := AddItemNode(ReportGroupItem, ParentFolder);
        Node.Selected := True;
        Assert(GetSelectedNodeType <> fpNone);
        Node.EditText;
      end;
    FChanged := True;
  end;
end;

// Функция самодостаточна и изменению не подлежит
function TdlgViewProperty.SaveChanges: Boolean;
var
  mbRes: Integer;
begin
  Result := True;

  if not (FChanged or FFunctionChanged or FFunctionNeadSave) then
  begin
    OverallRollback;
    Exit;
  end;

  if FChanged and not PropertySettings.GeneralSet.AutoSaveChanges then
  begin
    if CheckDestroing or (psRefreshTree in FPropertyViewStates) then
      mbRes := MessageBox(Application.Handle, MSG_SAVE_CHANGES, MSG_WARNING,
        MB_YESNO or MB_ICONQUESTION or MB_TOPMOST{ or MB_TASKMODAL})
    else
      mbRes := MessageBox(Application.Handle, MSG_SAVE_CHANGES, MSG_WARNING,
        MB_YESNOCANCEL or MB_ICONQUESTION{ or MB_TOPMOST or MB_TASKMODAL})
  end else
    mbRes := ID_YES;

  case mbRes of
    ID_CANCEL: Result := False;
    ID_YES: Result := OverallCommit;
    ID_NO: OverallRollback;
  end;

  if (psRefreshTree in FPropertyViewStates) and not Result then
  begin
    OverallRollback;
    Result := True;
  end;
end;

procedure TdlgViewProperty.actLoadFromFileExecute(Sender: TObject);
begin
  OpenDialog1.Filter := gsFunctionSynEdit.Highlighter.DefaultFilter;
  if OpenDialog1.Execute then
  begin
    gsFunctionSynEdit.Lines.LoadFromFile(OpenDialog1.FileName);
    TCrackDBSynEdit(gsFunctionSynEdit).NewOnChange(gsFunctionSynEdit);
    FChanged := True;
  end;
end;

procedure TdlgViewProperty.actSaveToFileExecute(Sender: TObject);
var
  I: Integer;
begin
  SaveDialog1.Filter := gsFunctionSynEdit.Highlighter.DefaultFilter;
  SaveDialog1.DefaultExt := '';
  I := Length(SaveDialog1.Filter);
  while (I > 0) and (SaveDialog1.Filter[I] <> '.') do
  begin
    SaveDialog1.DefaultExt := SaveDialog1.Filter[I] + SaveDialog1.DefaultExt;
    Dec(I);
  end;

  SaveDialog1.FileName := dbeFunctionName.Text;
  if SaveDialog1.Execute then
    gsFunctionSynEdit.SaveToFile(SaveDialog1.FileName);
end;

procedure TdlgViewProperty.ViewParam(const AnParam: Variant);
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
    MessageBox(Application.Handle, 'Результат функции должен быть массивом.', 'Ошибка', MB_OK or MB_ICONERROR or MB_TASKMODAL);
end;

procedure TdlgViewProperty.actCompileExecute(Sender: TObject);
var
  CustomFunction: TrpCustomFunction;
  ParamResult: Variant;
  LocDispatch: IDispatch;
  LocReportResult: IgsQueryList;
  VarResult: Variant;
//  Str: TStream;
begin
  // В SynDBEdit добавлен метод
  // procedure TCustomDBSynEdit.UpdateRecord;
  // begin
  //   FDataLink.UpdateRecord;
  // end;
  if gsFunctionSynEdit.Modified then
    ScriptFactory.Reset;

  gsFunctionSynEdit.UpdateRecord;

  if WarningFunctionName(dbeFunctionName.Text, gsFunctionSynEdit.Lines.Text) then
  begin
    if Assigned(Debugger) then
      Debugger.Stop;
    Exit;
  end;

  if PropertySettings.GeneralSet.AutoSaveOnExecute then
  begin
    OverallCommit;
    tvClassesChange(tvClasses, tvClasses.Selected);
  end;

  ClearErrorResult;

  // Создание тестовой функции
  CustomFunction := TrpCustomFunction.Create;
  try
    CustomFunction.ReadFromDataSet(gdcFunction);
    UpDataFunctionParams(FFunctionParams);
    CustomFunction.EnteredParams.Assign(FFunctionParams);

    if Assigned(ScriptFactory) then
    begin
      ParamResult := VarArrayOf([]);
      ParamResult := CustomFunction.EnteredParams.GetVariantArray;
      ScriptFactory.ShowErrorDialog := False;
      try
        if ScriptFactory.InputParams(CustomFunction, ParamResult) then
        begin
          try
            // выполнение скрипт-функции со своим обработчиком
            ScriptFactory.ExecuteFunction(CustomFunction, ParamResult, OnScriptError);
            if FModuleName = MainModuleName then
            begin
              if VarType(ParamResult) = varDispatch then
              begin
                LocDispatch := ParamResult;
                LocReportResult := LocDispatch as IgsQueryList;
                try
                  VarResult := LocReportResult.ResultStream;

                  FLastReportResult.TempStream.Size := VarArrayHighBound(VarResult, 1) - VarArrayLowBound(VarResult, 1) + 1;
                  CopyMemory(FLastReportResult.TempStream.Memory, VarArrayLock(VarResult), FLastReportResult.TempStream.Size);
                  VarArrayUnLock(VarResult);
                  FLastReportResult.TempStream.Position := 0;
                  if not FLastReportResult.IsStreamData then
                  begin
                    FLastReportResult.LoadFromStream(FLastReportResult.TempStream);
                    FLastReportResult.TempStream.Clear;
                    FFunctionNeadSave := True;
                  end;
                finally
                  LocReportResult.Clear;
                end;

              FLastReportResult.ViewResult;
              end;
            end else
              if FModuleName = ParamModuleName then
                ViewParam(ParamResult);
            FCompiled := True;
          except
//            on E: Exception do
//            begin
//              MessageBox(Handle, PChar(E.Message), MSG_ERROR, MB_OK);
              ScriptFactory.ReloadFunction(CustomFunction.FunctionKey);
//            end
          end;
        end;
      finally
        GotoLastError;
        if Assigned(Debugger) then
        //Данная остановка дебагера необходима на случай отмены при
        //запросе параметров
          Debugger.Stop;
        ScriptFactory.ShowErrorDialog := True;
      end;
    end else
      raise Exception.Create('Компонент ScriptFactory не создан.');
  finally
    CustomFunction.Free;
  end;
end;

procedure TdlgViewProperty.actSQLEditorExecute(Sender: TObject);
begin
  {$IFDEF SYNEDIT}
  with TfrmSQLEditorSyn.Create(Application) do
  {$ELSE}
  with TfrmSQLEditor.Create(Application) do
  {$ENDIF}
  begin
    FDatabase := gdcFunction.Database;
    ShowSQL(gsFunctionSynEdit.SelText, nil);
  end;  
end;

procedure TdlgViewProperty.actFindExecute(Sender: TObject);
begin
  if gsFunctionSynEdit.SelAvail then
    FindDialog1.FindText := gsFunctionSynEdit.SelText
  else
    FindDialog1.FindText := gsFunctionSynEdit.WordAtCursor;
  FindDialog1.Execute;
end;

procedure TdlgViewProperty.FindDialog1Find(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  dlg: TFindDialog;
  sSearch: string;
begin
  if Sender = ReplaceDialog1 then
    dlg := ReplaceDialog1
  else
    dlg := FindDialog1;

  sSearch := dlg.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Application.Handle, MSG_FIND_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  end else
  begin
    rOptions := [];
    if not (frDown in dlg.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in dlg.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in dlg.Options then
      Include(rOptions, ssoWholeWord);
    if gsFunctionSynEdit.SearchReplace(sSearch, '', rOptions) = 0 then
    begin
      Beep;
      MessageBox(Application.Handle, PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_FIND), MSG_WARNING,
       MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    end;
  end;
end;

procedure TdlgViewProperty.ReplaceDialog1Replace(Sender: TObject);
var
  rOptions: TSynSearchOptions;
  sSearch: string;
begin
  sSearch := ReplaceDialog1.FindText;
  if Length(sSearch) = 0 then
  begin
    Beep;
    MessageBox(Application.Handle, MSG_REPLACE_EMPTY_STRING, MSG_WARNING,
     MB_OK or MB_ICONWARNING or MB_TASKMODAL);
  end else
  begin
    rOptions := [ssoReplace];
    if frMatchCase in ReplaceDialog1.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in ReplaceDialog1.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in ReplaceDialog1.Options then
      Include(rOptions, ssoReplaceAll);
    if gsFunctionSynEdit.SelAvail then
      Include(rOptions, ssoSelectedOnly);
    if gsFunctionSynEdit.SearchReplace(sSearch, ReplaceDialog1.ReplaceText, rOptions) = 0 then
    begin
      Beep;
      MessageBox(Application.Handle, PChar(MSG_SEACHING_TEXT + sSearch + MSG_NOT_REPLACE),
       MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    end;
  end;
end;

procedure TdlgViewProperty.actReplaceExecute(Sender: TObject);
begin
  if gsFunctionSynEdit.SelAvail then
    ReplaceDialog1.FindText := gsFunctionSynEdit.SelText
  else
    ReplaceDialog1.FindText := gsFunctionSynEdit.WordAtCursor;
  ReplaceDialog1.Execute;
end;

procedure TdlgViewProperty.actCopyTextExecute(Sender: TObject);
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    SL.BeginUpdate;
    SL.Text := gsFunctionSynEdit.SelText;
    for I := 0 to SL.Count - 1 do
    begin            
      while (SL[I] > '') and (SL[I][1] <> '"') do
        SL[I] := System.Copy(SL[I], 2, Length(SL[I]));
      if SL[I] > '' then SL[I] := System.Copy(SL[I], 2, Length(SL[I]));
      while (SL[I] > '') and (SL[I][Length(SL[I])] <> '"') do
        SL[I] := System.Copy(SL[I], 1, Length(SL[I]) - 1);
      if SL[I] > '' then SL[I] := System.Copy(SL[I], 1, Length(SL[I]) - 1);
    end;

    SL.Text := SL.Text + #0;
    SL.EndUpdate;

    Clipboard.SetTextBuf(PChar(@SL.Text[1]));
  finally
    SL.Free;
  end;
end;

procedure TdlgViewProperty.actPasteExecute(Sender: TObject);
var
  SL: TStringList;
  I: Integer;
  TempStr: String;
begin
  if Clipboard.HasFormat(CF_TEXT) then
  begin
    SL := TStringList.Create;
    try
      SL.Text := Clipboard.AsText;
      TempStr := Clipboard.AsText;
      for I := 0 to SL.Count - 1 do
      begin
        if I <> SL.Count -1 then
          SL[I] := '  " ' + Trim(SL[I]) + ' " + _'
        else
          SL[I] := '  " ' + Trim(SL[I]) + ' "'
      end;

      Clipboard.AsText := SL.Text;
    finally
      SL.Free;
    end;

    gsFunctionSynEdit.PasteFromClipboard;
    Clipboard.AsText := TempStr;
  end;
end;

procedure TdlgViewProperty.actOptionsExecute(Sender: TObject);
begin
  if Assigned(SynManager) then
    if SynManager.ExecuteDialog then
    begin
      UpdateSyncs;
      SelectColorChange;
    end;
end;

procedure TdlgViewProperty.UpDateSyncs;
var
  Index: Integer;
begin
  if Assigned(SynManager) then
  begin
    SynManager.GetHighlighterOptions(SynJScriptSyn1);
    SynManager.GetHighlighterOptions(SynVBScriptSyn1);
    gsFunctionSynEdit.Font.Assign(SynManager.GetHighlighterFont);
    SynManager.GetSynEditOptions(TSynEdit(gsFunctionSynEdit));
    //Назначаем ShortCutы для экшинов
    with gsFunctionSynEdit.Keystrokes do
    begin
      Index := FindCommand(ecFindInTree);
      if Index > - 1 then
        actFindInTree.ShortCut := Items[Index].ShortCut
      else
        actFindInTree.ShortCut := 0;

      Index := FindCommand(ecAddItem);
      if Index > - 1 then
        actAddItem.ShortCut := Items[Index].ShortCut
      else
        actAddItem.ShortCut := 0;

      Index := FindCommand(ecDeleteItem);
      if Index > - 1 then
        actDeleteItem.ShortCut := Items[Index].ShortCut
      else
        actDeleteItem.ShortCut := 0;

      Index := FindCommand(ecAddFolder);
      if Index > - 1 then
        actAddFolder.ShortCut := Items[Index].ShortCut
      else
        actAddFolder.ShortCut := 0;

      Index := FindCommand(ecDeleteFolder);
      if Index > - 1 then
        actDeleteFolder.ShortCut := Items[Index].ShortCut
      else
        actDeleteFolder.ShortCut := 0;

      Index := FindCommand(ecCutTreeItem);
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
        actDisableMethod.ShortCut := 0;

      Index := FindCommand(ecCommit);
      if Index > - 1 then
        actFuncCommit.ShortCut := Items[Index].ShortCut
      else
        actFuncCommit.ShortCut := 0;

      Index := FindCommand(ecRollBack);
      if Index > - 1 then
        actFuncRollback.ShortCut := Items[Index].ShortCut
      else
        actFuncRollback.ShortCut := 0;

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
    end;
  end;
end;

procedure TdlgViewProperty.actCopyTextUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gsFunctionSynEdit.SelAvail and
    (GetSelectedNodeType in [fpMacros, fpEvent, fpMethod, fpReportFunction,
      fpVBClass, fpScriptFunction]) and (pcFunction.ActivePage = tsFuncScript);
end;

procedure TdlgViewProperty.actPasteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Clipboard.HasFormat(CF_TEXT) and
    (Length(ClipBoard.AsText) > 0) and
    (GetSelectedNodeType in [fpMacros, fpEvent, fpMethod, fpReportFunction,
      fpVBClass, fpScriptFunction]) and (pcFunction.ActivePage = tsFuncScript);
end;

procedure TdlgViewProperty.pcFunctionChanging(Sender: TObject;
  var AllowChange: Boolean);
var
  I: Integer;
begin
  AllowChange := True;
  if pcFunction.ActivePage = tsParams then
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
    ScrollBox1.Visible := False;
end;

procedure TdlgViewProperty.pcFunctionChange(Sender: TObject);
var
  ParamDlg: TgsParamList;
  I, J: Integer;
  LocParamLine: TfrmParamLineSE;
begin
  if pcFunction.ActivePage = tsParams then
  begin
    ScrollBox1.Visible := False;
    try
      ParamDlg := TgsParamList.Create;
      try
        GetParamsFromText(ParamDlg, dbeFunctionName.Text, gsFunctionSynEdit.Text);
        pnlCaption.Visible := ParamDlg.Count <> 0;

        FParamLines.Clear;
        for I := 0 to ParamDlg.Count - 1 do
        begin
          for J := 0 to FFunctionParams.Count - 1 do
            if FFunctionParams.Params[J].RealName = ParamDlg.Params[I].RealName then
            begin
              ParamDlg.Params[I].Assign(FFunctionParams.Params[J]);
              Break;
            end;
          LocParamLine := TfrmParamLineSE.Create(nil);
          LocParamLine.Top := FParamLines.Count * LocParamLine.Height;
          LocParamLine.Parent := ScrollBox1;
          LocParamLine.SetParam(ParamDlg.Params[I]);
          LocParamLine.OnParamChange := ParamChange;
          FParamLines.Add(LocParamLine);
          ScrollBox1.VertScrollBar.Increment := LocParamLine.Height;
        end;
        Label19.Visible := ParamDlg.Count = 0;
      finally
        ParamDlg.Free;
      end;
    finally
      ScrollBox1.Visible := True;
    end;
  end;
end;


procedure TdlgViewProperty.ParamChange(Sender: TObject);
begin
  SetChanged;
end;

function TdlgViewProperty.IsChild(Child, Parent: TTreeNode): Boolean;
var
  I: Integer;
begin
  Result := False;
  I := 0;
  while (I < Parent.Count) and not Result do
  begin
    Result := Parent.Item[I] = Child;
    if not Result then Result := IsChild(Child, Parent.Item[I]);
    Inc(I);
  end;
end;

function TdlgViewProperty.CanDragandDrop(Source,
  Target: TTReeNode): Boolean;
begin
  Result := (Assigned(Target) and Assigned(TObject(Target.Data)) and
    (Target <> Source) and
    (Target <> Source.Parent) and
    (not IsChild(Target, Source)));
end;

procedure TdlgViewProperty.actFunctionButtonUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (GetSelectedNodeType in
    [fpMacros, fpEvent, fpMethod, fpReportFunction, fpScriptFunction,
     fpVBClass, fpConst, fpGlobalObject]) 
     and (pcFunction.ActivePage = tsFuncScript);
end;

function TdlgViewProperty.CheckFunctionName(const AnFunctionName,
  AnScriptText: String): Boolean;
const
  LimitChar = [' ', '(', #13, #10, ';', '{', '}'];
var
  I: Integer;
  L: Integer;
begin
  I := Pos(AnFunctionName, AnScriptText);
  L := Length(AnFunctionName);
  Result := (I > 1) and (L + I < Length(AnScriptText)) and
    (AnScriptText[I - 1] = ' ') and (AnScriptText[I + L] in LimitChar);
end;

procedure TdlgViewProperty.dbmGroupDescriptionChange(Sender: TObject);
begin
  FChanged := True;
end;

function TdlgViewProperty.WarningFunctionName(const AnFunctionName,
  AnScriptText: String): Boolean;
begin
  Result := (Trim(dbeFunctionName.Text) = '') or
    (Trim(AnScriptText) = '') or
    not CheckFunctionName(UpperCase(AnFunctionName), UpperCase(AnScriptText));
  if Result then
  begin
    MessageBox(Application.Handle, MSG_UNKNOWN_NAME_FUNCTION,
     MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    pcFunction.ActivePage := tsFuncMain;
//    dbeFunctionName.Enabled := {not ((GetSelectedNodeType = fpScriptFunction) and
//     (gdcFunction.State = dsEdit))} True;
    SetFocusedControl(dbeFunctionName);
  end;
end;

function TdlgViewProperty.GetNodeType(Node: TTreeNode): TFunctionPages;
begin
  Result := fpNone;
  if Assigned(Node) and Assigned(Node.Data) then
  begin
    if (TObject(Node.Data) is TscrMacrosItem) then
      Result := fpMacros
    else if (TObject(Node.Data) is TscrMacrosGroupItem) then
      Result := fpMacrosFolder
    else if (TObject(Node.Data) is TscrReportFunction) then
      Result := fpReportFunction
    else if (TObject(Node.Data) is TscrReportItem) then
      Result := fpReport
    else if (TObject(Node.Data) is TscrReportGroupItem) then
      Result := fpReportFolder
    else if (TObject(Node.Data) is TscrReportTemplate) then
      Result := fpReportTemplate
    else if (TObject(Node.Data) is TEventItem) then
      Result := fpEvent
    else if (TObject(Node.Data) is TMethodItem) then
      Result := fpMethod
    else if (TObject(Node.Data) is TscrScriptFunction) then
      Result := fpScriptFunction
    else if (TObject(Node.Data) is TscrScriptFunctionGroup) then
      Result := fpScriptFunctionGroup
    else if (TObject(Node.Data) is TEventObject) then
      Result := fpEventObject
    else if (TObject(Node.Data) is TCustomMethodClass) then
      Result := fpMethodClass
    else if (TObject(Node.Data) is TscrVBClassGroup) then
      Result := fpVBClassGroup
    else if (TObject(Node.Data) is TscrVBClass) then
      Result := fpVBClass
    else if (TObject(Node.Data) is TscrConst) then
      Result := fpConst
    else if (TObject(Node.Data) is TscrConstGroup) then
      Result := fpConstGroup
    else if (TObject(Node.Data) is TscrGlobalObject) then
      Result := fpGlobalObject
    else if (TObject(Node.Data) is TscrGlobalObjectGroup) then
      Result := fpGlobalObjectGroup;
  end;
end;

procedure TdlgViewProperty.DisableControls;
begin
  Inc(FEnableControls);
end;

procedure TdlgViewProperty.EnableControls;
begin
  if FEnableControls > 0 then
    Dec(FEnableControls);
end;

procedure TdlgViewProperty.btnSelTemplateClick(Sender: TObject);
begin
  pcFuncParam.ActivePage := tsReportTemplate;
end;

procedure TdlgViewProperty.DisableChanges;
begin
  FEnableChanges := False;
end;

procedure TdlgViewProperty.EnableChanges;
begin
  FEnableChanges := True;
end;

function TdlgViewProperty.GetSelectedNodeType: TFunctionPages;
begin
  if Assigned(tvClasses.Selected) then
    Result := GetNodeType(tvClasses.Selected)
  else
    Result := fpNone;
end;

procedure TdlgViewProperty.dbmDescriptionChange(Sender: TObject);
begin
  if FEnableControls = 0 then
    FChanged := True;
end;

procedure TdlgViewProperty.ControlChange(Sender: TObject);
begin
  if FEnableControls = 0 then
  begin
    FChanged := True;
    FReportChanged := True;
  end;
end;

procedure TdlgViewProperty.dbcbReportServerKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    dbmDescriptionChange(Sender);
    DisableControls;
    try
      gdcReport.FieldByName('serverkey').Clear;
    finally
      EnableControls;
    end;  
  end;
end;

procedure TdlgViewProperty.dblcbTemplateClick(Sender: TObject);
begin
  ControlChange(Sender);
  FReportChanged := False;
  DisableControls;
  try
    gdcReport.FieldByName(fnTemplateKey).AsInteger :=
      dblcbTemplate.KeyValue;

    TscrReportTemplate(tvClasses.Selected.Data).Id := dblcbTemplate.KeyValue;

    LoadReportTemplate(tvClasses.Selected);
  finally
   EnableControls;
  end;
end;

procedure TdlgViewProperty.dblcbTemplateKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  ControlChange(Sender);
  FReportChanged := False;
  DisableControls;
  try
    if Key = VK_DELETE then
    begin
      dblcbTemplate.KeyValue := 0;
      gdcReport.FieldByName(fnTemplateKey).Clear;
      TscrReportTemplate(tvClasses.Selected.Data).Id := 0;

      LoadReportTemplate(tvClasses.Selected);
    end;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty.actEditTemplateExecute(Sender: TObject);
var
  LfrReport: Tgs_frSingleReport;
  RTFStr: TStream;
//  FStr: TFileStream;
  Str: TStream;
begin
  DisableControls;
  try
    if dblcbType.KeyValue = ReportFR then
    begin
      LfrReport := Tgs_frSingleReport.Create(Application);
      try
        if not gdcReport.FieldByName(fnMainFormulaKey).IsNull then
        begin
          gdcFunction.Close;
          gdcFunction.SubSet := ssById;
          gdcFunction.Id := gdcReport.FieldByName(fnMainFormulaKey).AsInteger;
          gdcFunction.Open;
          Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('testresult'), DB.bmRead);
          try
            LfrReport.UpdateDictionary.ReportResult.LoadFromStream(Str);
          finally
            Str.Free;
          end;
        end;

        RTFStr := gdcTemplate.CreateBlobStream(gdcTemplate.FieldByName('templatedata'), DB.bmReadWrite);
        try
          LfrReport.LoadFromStream(RTFStr);
          LfrReport.DesignReport;
          if (LfrReport.Modified or LfrReport.ComponentModified) {and (MessageBox(Handle,
            'Шаблон был изменен. Сохранить изменения?', 'Вопрос', MB_YESNO or MB_ICONQUESTION) = IDYES)} then
          begin
            RTFStr.Position := 0;
            RTFStr.Size := 0;
            LfrReport.SaveToStream(RTFStr);
            FChanged := True;
            FReportChanged :=True;
          end else
        finally
          RTFStr.Free;
        end;
      finally
        LfrReport.Free;
      end;
    end else
    if dblcbType.KeyValue = ReportXFR then
    begin
      RTFStr := gdcTemplate.CreateBlobStream(gdcTemplate.FieldByName('templatedata'),
        DB.bmReadWrite);
      try
        with Txfr_dlgTemplateBuilder.Create(Self) do
        try
          Execute(RTFStr);
          FChanged := True;
          FReportChanged := True;
        finally
          Free;
        end;
      finally
        RTFStr.Free;
      end;
    end else
    if dblcbType.KeyValue = ReportGRD then
    begin
      RTFStr := gdcTemplate.CreateBlobStream(gdcTemplate.FieldByName('templatedata'), DB.bmReadWrite);
      try
        if not gdcReport.FieldByName(fnMainFormulaKey).IsNull then
        begin
          gdcFunction.Close;
          gdcFunction.SubSet := ssById;
          gdcFunction.Id := gdcReport.FieldByName(fnMainFormulaKey).AsInteger;
          gdcFunction.Open;
          Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('testresult'), DB.bmRead);
          try
            FLastReportResult.LoadFromStream(Str);
          finally
            Str.Free;
          end;
        end;

        with TdlgViewResultEx.Create(nil) do
        try
          ExecuteDialog(FLastReportResult, RTFStr);
          FChanged := True;
          FReportChanged := True;
        finally
          Free;
        end;
      finally
        RTFStr.Free;
      end;
    end else
      raise Exception.Create(Format('Template type %s not supported', [dblcbType.KeyValue]));
  finally
    EnableControls;
  end;
end;


procedure TdlgViewProperty.actEditTemplateUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := dblcbType.KeyValue <> NULL;
end;

procedure TdlgViewProperty.FuncControlChanged(Sender: TObject);
begin
  SetChanged;
end;

procedure TdlgViewProperty.dblcbMacrosServerKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    SetChanged;

    DisableControls;
    try
      gdcMacros.FieldByName('serverkey').Clear;
    finally
      EnableControls;
    end;  
  end
end;

function TdlgViewProperty.AddItemNode(const Item: TscrCustomItem;
  const Parent: TTreeNode; Save: Boolean): TTreeNode;
begin
  Result := tvClasses.Items.AddChild(Parent, Item.Name);
  Result.Data := Item;
  if Save then
    FObjectList.Add(Item);
end;

function TdlgViewProperty.AddReportItem(const AItem: TscrReportItem;
  const AParent: TTreeNode; Save: Boolean): TTreeNode;
var
  TmpFnc: TscrReportFunction;
  Tmptempl: TscrReportTemplate;
  I: Integer;
  TN: TTreeNode;
const
  //Массив с именами функций
  Names: array[0..2] of String = (MAIN_FUNCTION, PARAM_FUNCTION,EVENT_FUNCTION) ;
  //Массив с типами функций
  Types: array[0..2] of TscrReportFncType = (rfMainFnc, rfParamFnc, rfEventFnc);
begin
  Result := tvClasses.Items.AddChild(AParent, AItem.Name);
  Result.Data := AItem;
  Result.ImageIndex := 10;
  Result.SelectedIndex := Result.ImageIndex;
  if Save then
   FObjectList.Add(AItem);

  //добавляем ноды функций отчёта
  for I := 0 to 2 do
  begin
    TmpFnc := TscrReportFunction.Create;
    TmpFnc.Name := Names[I];
    TmpFnc.FncType := Types[I];
    case TmpFnc.FncType of
      rfMainFnc: TmpFnc.Id := AItem.MainFormulaKey;
      rfParamFnc: TmpFnc.Id := AItem.ParamFormulaKey;
      rfEventFnc: TmpFnc.Id := AItem.EventFormulaKey;
    end;
    TN := tvClasses.Items.AddChild(Result, TmpFnc.Name);
    TN.Data := TmpFnc;
    if Save then
      FObjectList.Add(TmpFnc);
  end;

  //Добавляем нод шаблона
  TmpTempl := TscrReportTemplate.Create;
  TmpTempl.Id := AItem.TemplateKey;
  TN := tvClasses.Items.AddChild(Result, TEMPLATE);
  TN.Data := TmpTempl;
  if Save then
    FObjectList.Add(TmpTempl);
end;

procedure TdlgViewProperty.CancelMacros;
begin
  DisableControls; //Возможно удаление нода поэтому отключаем проверку изменений
  DisableChanges;
  try
    if gdcMacros.State = dsInsert then
      tvClasses.Selected.Delete;
    gdcMacros.Cancel;
    CancelFunction;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

procedure TdlgViewProperty.CancelMacrosGroup;
begin
  DisableControls; //Возможно удаление нода поэтому отключаем проверку изменений
  DisableChanges;
  try
    if gdcMacrosGroup.State = dsInsert then
      tvClasses.Selected.Delete;
    gdcMacrosGroup.Cancel;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

procedure TdlgViewProperty.CancelReport;
begin
  DisableControls;
  try
    gdcReport.Cancel;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty.CancelReportFunction;
begin
  DisableControls;
  try
    CancelFunction;
    CancelReport;
    FReportChanged := False;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty.CancelReportGroup;
begin
  DisableControls; //Возможно удаление нода поэтому отключаем проверку изменений
  DisableChanges;
  try
    if (gdcReportGroup.State = dsInsert) and
      (TscrReportGroupItem(tvClasses.Selected.Data).ID <> - 1) then
      tvClasses.Selected.Delete;
    gdcReportGroup.Cancel;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

procedure TdlgViewProperty.CancelTemplate;
begin
  DisableControls;
  try
    gdcTemplate.Cancel;
    gdcReport.Cancel;
    FReportChanged := False;
  finally
    EnableControls;
  end;
end;

function TdlgViewProperty.CanPaste(Source, Target: TTReeNode): Boolean;
begin
  Result := Assigned(Target) and Assigned(Target.Data) and
    Assigned(Source) and (Target <> Source) and
    (not IsChild(Target, Source));

  if FCut then
    Result := Result and (Target <> Source.Parent);

  if IsMacrosFolder(Target) then
    Result := Result and (GetNodeType(Source) in [fpMacrosFolder, fpMacros]) and
     (TscrMacrosGroupItem(Target.Data).IsGlobal =
     TscrMacrosGroupItem(GetParentFolder(Source).Data).IsGlobal)
  else if IsReportFolder(Target) then
    Result := Result and (IsReportFolder(Source) or (IsReport(Source) and
      Assigned(Target.Parent)))
  else Result := False;
end;

procedure TdlgViewProperty.Copy(Node: TTreeNode; ACut: Boolean);
begin
  if not Assigned(tvClasses.Selected) then
    Exit;

  if not FChanged then
  begin
    DisableControls;
    FCopyNode := tvClasses.Selected;
    FCut := ACut;
    try
      case GetNodeType(FCopyNode) of
        fpMacros:
        begin
          gdcMacros.Close;
          gdcMacros.SubSet := ssById;
          gdcMacros.Id := TscrMacrosItem(FCopyNode.Data).ID;
          gdcMacros.Open;
          gdcMacros.CopyToClipboard(nil, ACut);
        end;
        fpMacrosFolder:
        begin
          gdcMacrosGroup.Close;
          gdcMacrosGroup.SubSet := ssById;
          gdcMacrosGroup.Id := TscrMacrosGroupItem(FCopyNode.Data).Id;
          gdcMacrosGroup.Open;
          gdcMacrosGroup.CopyToClipboard(nil, ACut);
        end;
        fpReport:
        begin
          gdcReport.Close;
          gdcReport.SubSet := ssById;
          gdcReport.Id := TscrReportItem(FCopyNode.Data).ID;
          gdcReport.Open;
          gdcReport.CopyToClipboard(nil, ACut);
        end;
        fpReportFolder:
        begin
          gdcReportGroup.Close;
          gdcReportGroup.SubSet := ssById;
          gdcReportGroup.Id := TscrReportGroupItem(FCopyNode.Data).Id;
          gdcReportGroup.Open;
          gdcReportGroup.CopyToClipboard(nil, ACut);
        end;
      else
        FCopyNode := nil;
      end;
    finally
      EnableControls;
      tvClassesChange(tvClasses, tvClasses.Selected);
    end;
  end;
end;

procedure TdlgViewProperty.Cut(Node: TTreeNode);
begin
  Copy(Node, True)
end;

function TdlgViewProperty.DeleteMacros(const ANode: TTreeNode): Boolean;
begin
  DisableControls;
  DisableChanges;
  try
    try
      Assert(IsEditMacros(ANode), MSG_INVALID_DATA);
      if gdcMacros.State = dsInsert then
        CancelMacros
      else
      begin
        gdcMacros.Delete;
        try
          gdcFunction.Delete;
        except
        end;

        tvClasses.Selected.Delete;
      end;
      CommitTrans;

      Result := True;
      NoChanges;
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, MSG_CAN_NOT_DELETE_MACROS,
          MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);

        RollBackTrans;
        Result := False;
      end;
    end;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

function TdlgViewProperty.DeleteMacrosGroupItem(
  const ANode: TTreeNode): Boolean;
var
  DS: TIBDataSet;
begin
  Result := False;
  DisableControls;
  DisableChanges;

  DS := TIBDataSet.Create(nil);
  DS.Transaction := ibtrFunction;
  try
    try
      DS.SelectSQL.Text:= 'SELECT t1.*, (SELECT 1 FROM RDB$DATABASE WHERE ' +
        'EXISTS (SELECT t3.id FROM EVT_MACROSGROUP t3 WHERE t3.parent = t1.id) ' +
        'OR EXISTS (SELECT t4.id FROM evt_macroslist t4 WHERE ' +
        't4.MacrosGroupKey = t1.id)) AS HASCHILDREN ' +
        ' FROM evt_macrosgroup t1  ' + ' WHERE t1.id = :ID ';
      DS.ParamByName('id').AsInteger :=
        gdcMacrosGroup.FieldByName(fnId).AsInteger;
      DS.Open;
      if DS.FieldByName('haschildren').AsInteger = 0 then
      begin
        if gdcMacrosGroup.State = dsInsert then
          CancelMacrosGroup
        else
        begin
          gdcMacrosGroup.Delete;
          tvClasses.Selected.Delete;
        end;

        CommitTrans;
        Result := True;
        NoChanges;
      end else
        MessageBox(Application.Handle, MSG_CAN_NOT_DELETE_FOULDER,
          MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, PChar(E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
        RollbackTrans;
      end;
    end;
  finally
    DS.Free;
    EnableControls;
    EnableChanges;
  end;
end;

function TdlgViewProperty.DeleteReportGroupItem(
  const ANode: TTreeNode): Boolean;
var
  DS: TIBDataSet;
  SQL: TIBSQL;
begin
  Result := False;
  DisableControls;
  DisableChanges;

  DS := TIBDataSet.Create(nil);
  DS.Transaction := ibtrFunction;
  try
    try
      SQL := TIBSQL.Create(nil);
      try
        SQL.SQL.Text := 'UPDATE evt_object SET reportgroupkey = NULL ' +
          ' where reportgroupkey = ' + gdcReportGroup.FieldByName(fnId).AsString;
        SQL.Transaction := ibtrFunction;
        DS.SelectSQL.Text:= 'SELECT t1.*, (SELECT 1 FROM RDB$DATABASE WHERE ' +
          'EXISTS (SELECT t3.id FROM rp_reportgroup t3 WHERE t3.parent = t1.id) ' +
          'OR EXISTS (SELECT t4.id FROM rp_reportlist t4 WHERE ' +
          't4.ReportGroupKey = t1.id)) AS HASCHILDREN ' +
          ' FROM rp_reportgroup t1  ' + ' WHERE t1.id = :ID ';
        DS.ParamByName('id').AsInteger :=
          gdcReportGroup.FieldByName(fnId).AsInteger;
        DS.Open;
        if DS.FieldByName('haschildren').AsInteger = 0 then
        begin
          SQL.ExecQuery;
          if gdcReportGroup.State = dsInsert then
            CancelReportGroup
          else
          begin
            gdcReportGroup.Delete;
            tvClasses.Selected.Delete;
          end;

          CommitTrans;
          Result := True;
          NoChanges;
        end else
          MessageBox(Application.Handle, MSG_CAN_NOT_DELETE_FOULDER,
            MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
       finally
         SQL.Free;
       end;
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, PChar(E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
        RollbackTrans;
      end;
    end;
  finally
    DS.Free;
    EnableControls;
    EnableChanges;
  end;
end;

function TdlgViewProperty.DeleteReportItem(
  const ANode: TTreeNode): Boolean;
var
  Keys: array [0..3] of Integer;
  I: Integer;
  SQL: TIBSQL;
begin
  DisableControls;
  DisableChanges;
  try
    try
      Assert(IsReport(ANode), MSG_INVALID_DATA);

      Keys[0] := gdcReport.FieldByName(fnMainFormulaKey).AsInteger;
      Keys[1] := gdcReport.FieldByName(fnParamFormulaKey).AsInteger;
      Keys[2] := gdcReport.FieldByName(fnEventFormulaKey).AsInteger;
      Keys[3] := gdcReport.FieldByName(fnTemplateKey).AsInteger;

      if gdcReport.State = dsInsert then
        CancelReport
      else
        gdcReport.Delete; //Удаляем отчет

      tvClasses.Selected.Delete;

      for I := 0 to 2 do
      begin
        gdcFunction.Close;
        gdcFunction.SubSet := ssById;
        gdcFunction.ID := Keys[I];
        gdcFunction.Open;
        if not gdcFunction.IsEmpty and (gdcFunction.RecordUsed = 0) then
        begin
          try
            gdcFunction.Delete;  //Удаляем функцию
          except
 //           MessageBox(Application.Handle, PChar(Format(MSG_CANNOT_DELETE_REPORTFUNCTION,
 //             [gdcFunction.FieldByName(fnName).AsString])), MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
          end;
        end;
      end;

      gdcTemplate.Close;
      gdcTemplate.SubSet := ssById;
      gdcTemplate.ID := Keys[3];
      gdcTemplate.Open;
      if not gdcTemplate.IsEmpty then
      begin
        try
          SQL := TIBSQL.Create(nil);
          try
            SQL.SQL.Text := 'SELECT templatekey FROM rp_reportlist WHERE templatekey = ' +
               IntToStr(Keys[3]);
            SQL.Transaction := ibtrFunction;
            SQL.ExecQuery;
            if SQL.EOF then
              gdcTemplate.Delete;  //Удаляем шаблон
          finally
            SQL.Free;
          end;
        except
//          MessageBox(Application.Handle, PChar(Format(MSG_CANNOT_DELETE_REPORTTEMPLATE,
//            [gdcTemplate.FieldByName(fnName).AsString])), MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
        end;
      end;

      CommitTrans;
      Result := True;
      NoChanges;
    except
      MessageBox(Application.Handle, MSG_CAN_NOT_DELETE_REPORT,
        MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);
      RollBackTrans;
      Result := False;
    end;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

function TdlgViewProperty.GetParentFolder(ANode: TTreeNode): TTreeNode;
begin
  Result := ANode;
  While not (GetNodeType(Result) in [fpMacrosFolder, fpReportFolder,
    fpScriptFunctionGroup, fpVBClassGroup]) and
    Assigned(Result) do
    Result := Result.Parent;
end;

function TdlgViewProperty.IsEditFolder(ANode: TTreeNode): Boolean;
begin
  Result := (IsMacrosFolder(ANode) and (ANode.Parent <> nil)) or
    (IsReportFolder(ANode) and (TscrCustomItem(ANode.Data).Id > -1));
end;

function TdlgViewProperty.IsEditMacros(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpMacros;
end;

function TdlgViewProperty.IsMacros(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpMacros;
end;

function TdlgViewProperty.IsMacrosFolder(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpMacrosFolder;
end;

function TdlgViewProperty.IsReport(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpReport;
end;

function TdlgViewProperty.IsReportFolder(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpReportFolder;
end;

function TdlgViewProperty.IsReportTemplate(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpReportTemplate;
end;

procedure TdlgViewProperty.NodeCopy(SourceNode, TargetNode: TTreeNode);
var
  Item: pointer;
  TN: TTreeNode;
begin
  //вставить можно только в папку
  if GetNodeType(TargetNode) in [fpMacrosFolder, fpReportFolder] then
  begin
    if FCut then
    begin
      //происходит перемещение
      SourceNode.MoveTo(TargetNode, comctrls.naAddChild);
      SourceNode.Selected := True;
      Assert(GetSelectedNodeType <> fpNone);
      Item := SourceNode.Data;
      //изменяем значения парента
      if TObject(Item) is TscrMacrosGroupItem then
        TscrMacrosGroupItem(Item).Parent :=
          TscrMacrosGroupItem(TargetNode.Data).Id
      else if TObject(Item) is TscrMacrosItem then
        TscrMacrosItem(Item).GroupKey :=
          TscrMacrosGroupItem(TargetNode.Data).Id
      else if TObject(Item) is TscrReportItem then
        TscrReportItem(Item).ReportGroupKey :=
          TscrReportGroupItem(TargetNode.Data).Id
      else if TObject(Item) is TscrReportGroupItem then
        TscrReportGroupItem(Item).Parent :=
          TscrReportGroupItem(TargetNode.Data).Id
      else
        Exit;
      tvClassesChange(tvClasses, tvClasses.Selected);
    end else
    begin
      DisableControls;
      try
        StartTrans;
        case TscrCustomItem(SourceNode.Data).ItemType of
          //происходит копирование
          itMacros:
          begin
            //читаем из базы скопированный макрос
            Item := TscrMacrosItem.Create;
            gdcMacros.Close;
            gdcMacros.SubSet := ssById;
            gdcMacros.Id := gdcMacros.LastInsertId;
            gdcMacros.Open;
            Assert(not gdcMacros.IsEmpty);
            TscrMacrosItem(Item).ReadFromDataSet(gdcMacros);
            TN := AddItemNode(Item, TargetNode);
          end;
          itReport:
          begin
            //читаем из базы скопированный отчёт
            Item := TscrReportItem.Create;
            gdcReport.Close;
            gdcReport.SubSet := ssById;
            gdcReport.Id := gdcReport.LastInsertId;
            gdcReport.Open;
            Assert(not gdcReport.IsEmpty);
            TscrReportItem(Item).ReadFromDataSet(gdcReport);
            TN := AddReportItem(Item, TargetNode);
          end;
        else
          Exit;
        end;
        TN.Selected := True;
        Assert(GetSelectedNodeType <> fpNone);

        TN.EditText;
      finally
        CommitTrans;
        tvClassesChange(tvClasses, tvClasses.Selected);
        EnableControls;
      end;
    end;
  end;
end;

procedure TdlgViewProperty.Paste(TargetNode: TTreeNode);
var
  gdc: TgdcBase;
  S1, S2, S3: String;
begin
  if Assigned(FCopyNode) and OverallCommit then
  begin
    DisableControls;
    try
      StartTrans;
      //Формируем значения gdc и S1
      if IsMacrosFolder(TargetNode) then
      begin
        S1 := TscrMacrosGroupItem(TargetNode.Data).Name;
        gdc := gdcMacrosGroup;
        gdc.Close;
        gdc.SubSet := ssById;
        gdc.Id := TscrMacrosGroupItem(TargetNode.Data).Id;
        gdc.Open;
      end else if IsReportFolder(TargetNode) then
      begin
        S1 := TscrReportGroupItem(TargetNode.Data).Name;
        gdc := gdcReportGroup;
        gdc.Close;
        gdc.SubSet := ssById;
        if TscrReportGroupItem(TargetNode.Data).Id > 0 then
          gdc.Id := TscrReportGroupItem(TargetNode.Data).Id
        else
          gdc.Id := 0;
        gdc.Open;
      end else
        Exit;

      //формируем S2
      if IsMacrosFolder(FCopyNode) then
        S2 := Format(MSG_COPY_FOLDER,
          [TscrMacrosGroupItem(FCopyNode.Data).Name])
      else if IsMacros(FCopyNode) then
        S2 := Format(MSG_COPY_MACROS,
          [TscrMacrosItem(FCopyNode.Data).Name])
      else if IsReportFolder(FCopyNode) then
        S2 := Format(MSG_COPY_FOLDER,
          [TscrReportGroupItem(FCopyNode.Data).Name])
      else if IsReport(FCopyNode) then
        S2 := Format(MSG_COPY_REPORT,
          [TscrReportItem(FCopyNode.Data).Name]);

      //формируем S3
      if FCut then
        S3 := MSG_CUT
      else
        S3 := MSG_COPY;

      if gdc.CanPasteFromClipboard and (MessageBox(Application.Handle, PChar(Format(MSG_SURE_TO_COPY,[S3,S2, S1])),
         MSG_WARNING, MB_YESNO or MB_ICONWARNING or MB_TASKMODAL) = IDYES) then
      begin
        //вставляем из клипборда
        if gdc.PasteFromClipboard then
        begin
          CommitTrans;
          //переносим нод
          NodeCopy(FCopyNode, TargetNode);
          if FCut then
            FCopyNode := nil;
        end else
          MessageBox(Application.Handle, MSG_PASTE_ERROR, MSG_ERROR, MB_OK and
            MB_ICONERROR or MB_TASKMODAL);
      end;
    finally
      EnableControls;
    end;  
  end;
end;

function TdlgViewProperty.PostMacros(
  const AMacrosNode: TTreeNode): Boolean;
var
  TmpMcr: TscrMacrosItem;
  LFunctionKey: Integer;
begin
  Result := False;
  if not IsMacros(AMacrosNode) then
    Exit;

  try
    DisableControls;
    try
      Result := PostFunction(LFunctionKey);

      if Result then
      begin
        TmpMcr := TscrMacrosItem(AMacrosNode.Data);
        TmpMcr.FunctionKey := LFunctionKey;
        if gdcMacros.FieldByName(fnID).IsNull then
        begin
          //макрос новый поэтому получаем айди
          gdcMacros.FieldByName(fnId).AsInteger :=
            GetUniqueKey(gdcMacros.Database, gdcMacros.Transaction);
        end;

        gdcMacros.FieldByname(fnMacrosGroupKey).AsInteger := TmpMcr.GroupKey;
        gdcMacros.FieldByName(fnFunctionKey).AsInteger := TmpMcr.FunctionKey;
        gdcMacros.FieldByName(fnName).AsString := AMacrosNode.Text;
        gdcMacros.FieldByName(fnShortCut).AsInteger := hkMacros.HotKey;
      
        gdcMacros.Post;

        TmpMcr.Id := gdcMacros.FieldByName(fnId).AsInteger;

        gdcMacros.Close;
        Result := True;
      end;
    finally
      EnableControls;
    end;
  except
    on E: Exception do
    begin
      EnableControls;
      MessageBox(Application.Handle, PChar(MSG_ERROR_SAVE_EVENT + E.Message),
        MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
    end;
  end;
end;

function TdlgViewProperty.PostMacrosGroup(const ANode: TTreeNode): Boolean;
var
  TmpGrp:  TscrMacrosGroupItem;
begin
  Result := False;

  if not IsMacrosFolder(ANode) then
    Exit;

  TmpGrp := TscrMacrosGroupItem(ANode.Data);
  try
    DisableControls;
    try
      if gdcMacrosGroup.FieldByName(fnId).IsNull then
      begin
        gdcMacrosGroup.FieldByName(fnId).AsInteger :=
          GetUniqueKey(gdcMacrosGroup.Database, gdcMacrosGroup.Transaction);
      end;

      if TmpGrp.Parent = 0 then
        gdcMacrosGroup.FieldByName(fnParent).Clear
      else
        gdcMacrosGroup.FieldByName(fnParent).AsInteger := TmpGrp.Parent;

      gdcMacrosGroup.FieldByName(fnName).AsString := ANode.Text;
      gdcMacrosGroup.FieldByName(fnIsGlobal).AsInteger := Integer(TmpGrp.IsGlobal);

      gdcMacrosGroup.Post;

      TmpGrp.Id := gdcMacrosGroup.FieldByName(fnId).AsInteger;

      Result := True;
    finally
      EnableControls;
    end;
  except
    on E: Exception do
    begin
      EnableControls;
      MessageBox(Application.Handle, PChar(MSG_ERROR_SAVE + E.Message),
        MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
    end;
  end;
end;

function TdlgViewProperty.PostReport(
  const AReportNode: TTreeNode): Boolean;
var
  ReportItem: TscrReportItem;
begin
  Result := False;
  if not IsReport(AReportNode) then
    Exit;

  if TscrReportItem(AReportNode.Data).MainFormulaKey = 0 then
  begin
    //Основная функция неопределена. Выходим
    MessageBox(Application.Handle, MSG_NEED_MAIN_FORMULA_KEY, MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
    Exit;
  end;

  try
    DisableControls;
    try
      ReportItem := TscrReportItem(AReportNode.Data);
      if gdcReport.FieldByName(fnId).IsNull then
      begin
        //Отчет новый. Генерируем ИД
        gdcReport.FieldByName(fnId).AsInteger :=
          GetUniqueKey(gdcReport.Database, gdcReport.Transaction);
      end;

      if ReportItem.EventFormulaKey > 0 then
        gdcReport.FieldByName(fnEventFormulaKey).AsInteger :=
          ReportItem.EventFormulaKey
      else
        gdcReport.FieldByName(fnEventFormulaKey).Clear;

      gdcReport.FieldByName(fnMainFormulaKey).AsInteger :=
        ReportItem.MainFormulaKey;

      if ReportItem.ParamFormulaKey > 0 then
        gdcReport.FieldByName(fnParamFormulaKey).AsInteger :=
          ReportItem.ParamFormulaKey
      else
        gdcReport.FieldByName(fnParamFormulaKey).Clear;

      gdcReport.FieldByName(fnName).AsString := AReportNode.Text;

      gdcReport.FieldByName(fnReportGroupKey).AsInteger :=
        TscrReportGroupItem(AReportNode.Parent.Data).Id;

      gdcReport.Post;

      ReportItem.Id := gdcReport.FieldByName(fnId).AsInteger;

      FReportChanged := False;

      FReportCreated := False;
      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, PChar(MSG_ERROR_SAVE_REPORT + E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
      end;
  end;
  finally
    EnableControls;
  end;
end;

function TdlgViewProperty.PostReportFunction(
  const AReportFunctionNode: TTreeNode): Boolean;
var
  LFunctionKey: Integer;
  VFunctionKey: Variant;
begin
  LFunctionKey := (TObject(AReportFunctionNode.Data) as TscrCustomItem).Id;
  DisableControls;
  try
    //сохраняем изменения функции отчётов
    Result := PostFunction(LFunctionKey);
    if Result then
    begin
      (TObject(AReportFunctionNode.Data) as TscrReportFunction).Id := LFunctionKey;
      case (TObject(AReportFunctionNode.Data) as TscrReportFunction).FncType of
        //функция должна быть одной из:
        rfMainFnc:
          TscrReportItem(AReportFunctionNode.Parent.Data).MainFormulaKey := LFunctionKey;
        rfParamFnc:
          TscrReportItem(AReportFunctionNode.Parent.Data).ParamFormulaKey := LFunctionKey;
        rfEventFnc:
          TscrReportItem(AReportFunctionNode.Parent.Data).EventFormulaKey := LFunctionKey;
      end;

      if LFunctionKey > 0 then
        VFunctionKey := LFunctionKey
      else
        VFunctionKey := Null;

      if FCanSaveLoad then
        Result := PostReport(AReportFunctionNode.Parent);

      FReportChanged := False;
    end;
  finally
    tvClasses.Invalidate;
    EnableControls;
  end;
end;

function TdlgViewProperty.PostReportGroup(const ANode: TTreeNode): Boolean;
var
  ReportGroup: TscrReportGroupItem;
begin
  Result := False;
  //Проверяем правильность переданных данных
  if not IsReportFolder(ANode) then
    Exit;
  try
    //отключаем конролы
    DisableControls;
    try
      ReportGroup := TscrReportGroupItem(ANode.Data);
      //Если FieldByName(fnId).IsNull то генерируем ИД
      { DONE : Вообщето ИД генерируется автом. по команде Insert
      поэтому этот код лишний}
      if gdcReportGroup.FieldByName(fnId).IsNull then
      begin
        gdcReportGroup.FieldByName(fnId).AsInteger :=
          GetUniqueKey(gdcReportGroup.Database, gdcReportGroup.Transaction);
      end;

      //если ReportGroup.Parent = 0 то мы находимся на самом верхнем
      //ноде и в таблицу заносим Null
      if ReportGroup.Parent > 0 then
        gdcReportGroup.FieldByName(fnParent).AsInteger := ReportGroup.Parent
      else
        gdcReportGroup.FieldByName(fnParent).Clear;

      //Сохраняем имя отчета
      gdcReportGroup.FieldByName(fnName).AsString := ANode.Text;
      //ЮзерГруппНаме - это имя гдскласса + сабтайп.
      if gdcReportGroup.FieldByName(fnUserGroupName).IsNull then
        gdcReportGroup.FieldByName(fnUserGroupName).AsString :=
          IntToStr(gdcReportGroup.FieldByName(fnId).AsInteger) + '_' +
          IntToStr(GetDBID);
      //Делаем Пост
      gdcReportGroup.Post;
      //Если все ОК то присваем ИД итему хранящемуся в ноде
      //Это делается после Поста что обеспечивает целостность данных
      ReportGroup.Id := gdcReportGroup.FieldByName(fnId).AsInteger;
      Result := True;
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, PChar(MSG_ERROR_SAVE_EVENT + E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
      end;
    end;
  finally
    //Включаем контролы
    EnableControls;
  end
end;

function TdlgViewProperty.PostReportTemplate(
  const ANode: TTreeNode): Boolean;
begin
  Result := False;
  //Проверяем правильность переданных данных
  Assert(IsReportTemplate(ANode), MSG_INVALID_DATA);

  if Trim(DBEdit1.Text) = '' then
  begin
    MessageBox(Application.Handle, 'Не определено наименование шаблона', MSG_ERROR, MB_OK
      + MB_ICONERROR or MB_TASKMODAL);
    Exit;
  end;

  try
    //отключаем конролы
    DisableControls;
    try
      if ibqryTemplate.Active then
        ibqryTemplate.Close;

      //если были изменения в шабдоне то сохраняем их
      if FReportChanged then
      begin
        //Если FieldByName(fnId).IsNull то генерируем ИД
        { DONE : Вообщето ИД генерируется автом. по команде Insert
        поэтому этот код лишний}
//        if gdcTemplate.FieldByName(fnId).IsNull then
//          gdcTemplate.FieldByName(fnId).AsInteger :=
//            GetUniqueKey(gdcTemplate.Database, gdcTemplate.Transaction);

        //Делаем Пост
        gdcTemplate.Post;
        //Если все ОК то присваем ИД итему хранящемуся в ноде
        //Это делается после Поста что обеспечивает целостность данных
        gdcReport.FieldByName(fnTemplateKey).AsInteger :=
          gdcTemplate.FieldByName(fnId).AsInteger;
        FReportChanged := False;
        Result := True;
      end;

      TscrReportTemplate(ANode.Data).Id :=
         gdcTemplate.FieldByName(fnId).AsInteger;

      if FCanSaveLoad then
        Result := PostReport(ANode.Parent);

    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, PChar(MSG_ERROR_SAVE_REPORT + E.Message),
          MSG_ERROR, MB_OK or MB_ICONERROR or MB_TASKMODAL);
      end;
    end;
  finally
    tvClasses.Invalidate;
    ibqryTemplate.Open;
    EnableControls;
  end;
end;

procedure TdlgViewProperty.ShowMacrosTreeRoot(AComponent: TComponent);
var
  TmpGrp: TscrMacrosGroupItem;
  MacrosGroup: TscrMacrosGroup;

  procedure FillMacrosTree(AParent: TTreeNode; Index: Integer);
  var
    TN: TTreeNode;
    I: Integer;
    MG: TscrMacrosGroupItem;
    M: TscrMacrosItem;

  begin
    if (Index < MacrosGroup.Count) and Assigned(AParent) then
    begin
      for I := Index + 1 to MacrosGroup.Count - 1 do
      begin
        if MacrosGroup.GroupItems[Index].Id = MacrosGroup.GroupItems[I].Parent then
        begin
          MG := TscrMacrosGroupItem.Create(False);
          MG.Assign(MacrosGroup[I]);
          MG.ChildIsRead := True;
          TN := AddItemNode(MG, AParent);
          FillMacrosTree(TN, I);
        end;
      end;

      for I := 0 to MacrosGroup.GroupItems[Index].MacrosList.Count - 1 do
      begin
        M := TscrMacrosItem.Create;
        M.Assign(MacrosGroup.GroupItems[Index].MacrosList[I]);
        AddItemNode(M, AParent);
      end;
    end;
  end;

begin
  DisableControls;
  try
    MacrosGroup := TscrMacrosGroup.Create(False);
    try
      MacrosGroup.Transaction := ibtrFunction;
      StartTrans;
      //чтение Глобальной группы макросов
      gdcMacrosGroup.Close;
      gdcMacrosGroup.SubSet := ssById;
      gdcMacrosGroup.Id := OBJ_GLOBALMACROS;
      gdcMacrosGroup.Open;
      Assert (not gdcMacrosGroup.IsEmpty);

      MacrosGroup.Load(OBJ_GLOBALMACROS);
      TmpGrp := TscrMacrosGroupItem.Create(False);
      TmpGrp.ReadFromDataSet(gdcMacrosGroup);
      FGMacrosRootNode := AddItemNode(TmpGrp, nil);
      TmpGrp.ChildIsRead := True;

      FillMacrosTree(FGMacrosRootNode, 0);
      //чтение локольной группы макросов
      if AComponent <> Application then
      begin
        //ищем запись с Id = FObjectKey для полущения
        //значения MacrosGroupKey
        ibtrObject.StartTransaction;
        try
          gdcDelphiObject.Close;
          gdcDelphiObject.SubSet := ssById;
          gdcDelphiObject.ID := FObjectKey;
          gdcDelphiObject.Open;

          //ищем группу локальных макросов
          gdcMacrosGroup.Close;
          gdcMacrosGroup.SubSet := ssById;
          gdcMacrosGroup.Id := gdcDelphiObject.FieldByName(fnMacrosGroupKey).AsInteger;
          gdcMacrosGroup.Open;

          TmpGrp := TscrMacrosGroupItem.Create(False);
          TmpGrp.Name := ROOT_LOCAL_MACROS;
          TmpGrp.IsGlobal := False;
          FLMacrosRootNode := AddItemNode(TmpGrp, nil);

          if gdcMacrosGroup.IsEmpty then
          begin
            //для данного объекта нет группы макросов.
            //создаём её
            LoadMacrosGroup(FLMacrosRootNode);
            PostMacrosGroup(FLMacrosRootNode);
            ibtrFunction.Commit;
            ibtrFunction.StartTransaction;

            gdcDelphiObject.Edit;
            gdcDelphiObject.FieldByName(fnMacrosGroupKey).AsInteger := TmpGrp.Id;
            gdcDelphiObject.Post;
          end else
            TmpGrp.Id := gdcMacrosGroup.FieldByName(fnId).AsInteger;

          ibtrObject.Commit;
        except
          ibtrObject.RollBack;
        end;

        TmpGrp.ChildIsRead := True;
        MacrosGroup.Load(gdcMacrosGroup.Id);
        FillMacrosTree(FLMacrosRootNode, 0);
      end;
    finally
      MacrosGroup.Free;
    end;
  finally
    CommitTrans;
    EnableControls;
  end;
end;

procedure TdlgViewProperty.ShowReportTreeRoot(AComponent: TComponent);
var
  TmpGrp: TscrReportGroupItem;
  TN: TTreeNode;
  ReportGroup: TscrReportGroup;

  procedure FillReportTree(AParent: TTreeNode; Index: Integer);
  var
    TN: TTreeNode;
    I: Integer;
    RG: TscrReportGroupItem;
    R: TscrReportItem;
    Id: Integer;

  begin
    if (Index < ReportGroup.Count) and Assigned(AParent) then
    begin
      Id := TscrReportGroupItem(AParent.Data).Id;
      if Id = -1 then id := 0;
      for I := Index + 1 to ReportGroup.Count - 1 do
      begin
        if Id = ReportGroup.GroupItems[I].Parent then
        begin
          RG := TscrReportGroupItem.Create(False);
          RG.Assign(ReportGroup[I]);
          RG.ChildIsRead := True;
          TN := AddItemNode(RG, AParent);
          FillReportTree(TN, I);
        end;
      end;

      if TscrReportGroupItem(AParent.Data).Id <> -1 then
        for I := 0 to ReportGroup.GroupItems[Index].ReportList.Count - 1 do
        begin
          R := TscrReportItem.Create;
          R.Assign(ReportGroup.GroupItems[Index].ReportList[I]);
          AddReportItem(R, AParent);
        end;
    end;
  end;

begin
  if (AComponent is TForm) or (AComponent = Application) or
  (AComponent is TgdcBase) then
  begin
    DisableControls;
    try
      ReportGroup := TscrReportGroup.Create(False);
      try
        ReportGroup.Transaction := ibtrFunction;
        StartTrans;
        TN := FReportRootNode;
        TmpGrp := TObject(TN.Data) as TscrReportGroupItem;
        gdcReportGroup.Close;
        gdcReportGroup.SubSet := ssById;
        if (AComponent = Application) then
        begin
          //При загрузке групп будем отличать главную группу
          TmpGrp.Id := - 1;
        end else if (AComponent is TForm) or (AComponent is TgdcBase) then
        begin
          ibtrObject.StartTransaction;
          try
            if AComponent is TForm then
            begin
              gdcDelphiObject.Close;
              gdcDelphiObject.SubSet := ssById;
              gdcDelphiObject.Id := FObjectKey;
              gdcDelphiObject.Open;

              gdcReportGroup.SubSet := ssByID;
              gdcReportGroup.ID :=
                  gdcDelphiObject.FieldByName(fnReportGroupKey).AsInteger;
            end else
              gdcReportGroup.ID := TgdcBase(AComponent).GroupID;

            gdcReportGroup.Open;

            if gdcReportGroup.IsEmpty then
            begin
              LoadReportGroup(TN);
              TN.Text := REPORTS + ' (' + AComponent.Name + ')';
              PostReportGroup(TN);
              ibtrFunction.Commit;
              ibtrFunction.StartTransaction;

              TN.Text := REPORTS;
              gdcDelphiObject.Edit;
              gdcDelphiObject.FieldByName(fnReportGroupKey).AsInteger := TmpGrp.Id;
              gdcDelphiObject.Post;
              if not gdcReportGroup.Active then
                gdcReportGroup.Open;
            end else
            begin
              TmpGrp.Id := gdcReportGroup.FieldByName(fnId).AsInteger;
              if AComponent is TgdcBase then
              begin
                gdcDelphiObject.Close;
                gdcDelphiObject.SubSet := ssById;
                gdcDelphiObject.Id := FObjectKey;
                gdcDelphiObject.Open;
                gdcDelphiObject.Edit;
                gdcDelphiObject.FieldByName(fnReportGroupKey).AsInteger := TmpGrp.Id;
                gdcDelphiObject.Post;
              end;
            end;
            ibtrObject.Commit;
          except
            ibtrObject.Rollback;
          end;
        end;

        TmpGrp.ChildIsRead := True;
        ReportGroup.Load(TmpGrp.Id);
        FillReportTree(TN, 0);
      finally
        ReportGroup.Free;
      end;
    finally
      CommitTrans;
      EnableControls;
    end;
  end;
end;

procedure TdlgViewProperty.LoadMacros(const Node: TTreeNode);
var
  Name: String;
begin
  Assert(IsMacros(Node));

  Label6.Caption := 'Наименование макроса';
  tsFuncScript.Caption := 'Текст макроса';
  DisableControls;
  StartTrans;
  try
    if ibqryReportServer.Active then
      ibqryReportServer.Close;

    Name := '';
    gdcMacros.Close;
    gdcMacros.SubSet := ssById;
    gdcMacros.ID := TscrMacrosItem(Node.Data).Id;
    gdcMacros.Open;
    if gdcMacros.IsEmpty then
    begin
      gdcMacros.Insert;
      gdcMacros.FieldByName(fnName).AsString := Node.Text;
      Name := gdcFunction.GetUniqueName('Macros', '', GetObjectId(tvClasses.Selected));
      gdcMacros.FieldByName(fnName).AsString := Name;
    end else
      gdcMacros.Edit;

    Node.Text := gdcMacros.FieldByName(fnName).AsString;
    hkMacros.HotKey := gdcMacros.FieldByName(fnShortCut).AsInteger;
    LoadFunction(scrMacrosModuleName,
      gdcMacros.FieldByName(fnFunctionKey).AsInteger, Name,
      Format(VB_MACROS_TEMPLATE,[Name]));

  finally
    ibqryReportServer.Open;
    EnableControls;
  end;
end;

procedure TdlgViewProperty.LoadMacrosGroup(const Node: TTreeNode);
var
  MacrosGroup: TscrMacrosGroupItem;
begin
  Assert(IsMacrosFolder(Node));

  DisableControls;
  StartTrans;
  try
    MacrosGroup := TscrMacrosGroupItem(Node.Data);
    gdcMacrosGroup.Close;
    gdcMacrosGroup.SubSet := ssById;
    gdcMacrosGroup.ID := MacrosGroup.Id;
    gdcMacrosGroup.Open;
    if gdcMacrosGroup.IsEmpty then
    begin
      gdcMacrosGroup.Insert;
      gdcMacrosGroup.FieldByName(fnName).AsString := Node.Text;
    end else
      gdcMacrosGroup.Edit;

    Node.Text := gdcMacrosGroup.FieldByName(fnName).AsString;
  finally
    //Устанавливаем датасет для описания
    dsDescription.DataSet := gdcMacrosGroup;
    EnableControls;
  end;
end;

procedure TdlgViewProperty.LoadReport(const Node: TTreeNode);
var
  Report: TscrReportItem;
begin
  Assert(IsReport(Node));

  Label6.Caption := 'Наименование функции';
  tsFuncScript.Caption := 'Текст функции';
  DisableControls;
  StartTrans;
  try
    //закрываем зависимые датасеты
    if ibqryReportServer.Active then
      ibqryReportServer.Close;

    //загружаем если не создан новый отчёт
    if not (gdcReport.State = dsInsert) then
    begin
      Report := TscrReportItem(Node.Data);
      gdcReport.Close;
      gdcReport.SubSet := ssById;
      gdcReport.Id := - 1;
      gdcReport.ID := Report.Id;
      gdcReport.Open;
      if gdcReport.IsEmpty then
      begin
        gdcReport.Insert;
        gdcReport.FieldByName(fnName).AsString := Node.Text;
      end else
        gdcReport.Edit;
    end;

    Node.Text := gdcReport.FieldByName(fnName).AsString;

    ibqryReportServer.Open;

  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty.LoadReportFunction(const Node: TTreeNode);
var
  RF: TscrReportFunction;
  Name: String;
begin
  DisableControls;
  try
    Label6.Caption := 'Наименование функции';
    tsFuncScript.Caption := 'Текст функции';
    StartTrans;

    RF := TscrReportFunction(Node.Data);
    ibqrySetFunction.Close;
    ibqrySetFunction.Params[0].AsString := RF.ModuleName;
    ibqrySetFunction.Params[1].AsInteger := GetObjectId(Node);
    ibqrySetFunction.Params[2].AsInteger := RF.Id;
    ibqrySetFunction.Open;

    Name := '';
    if RF.ID = 0 then
      case RF.FncType of
        rfMainFnc:
          Name := gdcFunction.GetUniqueName('mn_Report','',
            GetObjectId(tvClasses.Selected));
        rfParamFnc:
          Name := gdcFunction.GetUniqueName('pr_Report','',
            GetObjectId(tvClasses.Selected));
        rfEventFnc:
          Name := gdcFunction.GetUniqueName('ev_Report','',
            GetObjectId(tvClasses.Selected));
      end;

    case RF.FncType of
      rfMainFnc:
        LoadFunction(RF.ModuleName, RF.Id,Name
          Format(VB_MAINFUNCTION_TEMPLATE,[Name, Name]));
      rfParamFnc:
        LoadFunction(RF.ModuleName, RF.Id,Name
          Format(VB_PARAMFUNCTION_TEMPLATE,[Name, Name]));
      rfEventFnc:
        LoadFunction(RF.ModuleName, RF.Id,Name
          Format(VB_EVENTFUNCTION_TEMPLATE,[Name, Name]));
    end;

    dblcbSetFunction.KeyValue := RF.Id;

    //если отчет не находится на редактирование то открываем его
    if not (gdcReport.State in dsEditModes) then
      LoadReport(Node.Parent);

  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty.LoadReportGroup(const Node: TTreeNode);
var
  ReportGroup: TscrReportGroupItem;
begin
  Assert(IsReportFolder(Node));

  DisableControls;
  StartTrans;
  try
    ReportGroup := TscrReportGroupItem(Node.Data);
    gdcReportGroup.Close;
    if ReportGroup.Id > -1 then
    begin
      gdcReportGroup.SubSet := ssById;
      gdcReportGroup.ID := ReportGroup.Id;
      gdcReportGroup.Open;
      if gdcReportGroup.IsEmpty then
      begin
        gdcReportGroup.Insert;
        gdcReportGroup.FieldByName(fnName).AsString := Node.Text;
      end else
        gdcReportGroup.Edit;

      if Assigned(Node.Parent) then
        Node.Text := gdcReportGroup.FieldByName(fnName).AsString;
    end else
    begin
      gdcReportGroup.SubSet := ssAll;
      gdcReportGroup.Open;
      gdcReportGroup.Insert;
    end
  finally
    //Устанавливаем датасет для описания
    dsDescription.DataSet := gdcReportGroup;
    EnableControls;
  end;
end;

procedure TdlgViewProperty.LoadReportTemplate(const Node: TTreeNode);
begin
  Assert(IsReportTemplate(Node));

  DisableControls;
  try
    //если отчет не находится на редактирование то открываем его

    Label6.Caption := 'Наименование функции';
    tsFuncScript.Caption := 'Текст функции';
    if not (gdcReport.State in dsEditModes) then
      LoadReport(Node.Parent);

    StartTrans;
    if ibqryTemplate.Active then
      ibqryTemplate.Close;

    gdcTemplate.Close;
    gdcTemplate.SubSet := ssById;
    gdcTemplate.ID :=
      gdcReport.FieldByName(fnTemplateKey).AsInteger;

    gdcTemplate.Open;
    if gdcTemplate.IsEmpty then
    begin
      gdcTemplate.Insert;
      gdcTemplate.FieldByName(fnName).AsString := '';
    end else
      gdcTemplate.Edit;

    ibqryTemplate.Open;
  finally
    EnableControls;
  end;
end;

procedure TdlgViewProperty.NoChanges;
begin
  FChanged := False;
  FReportChanged := False;
end;

procedure TdlgViewProperty.actAddFolderUpdate(Sender: TObject);
begin
  actAddFolder.Enabled := GetSelectedNodeType in [fpMacros, fpMacrosFolder,
      fpReportFolder, fpReport];
end;

procedure TdlgViewProperty.actAddMacrosExecute(Sender: TObject);
var
  Node: TTreeNode;
  ParentFolder: TTreeNode;
  MacrosItem: TscrMacrosItem;

begin
  if not (GetNodeType(tvClasses.Selected) in
    [fpMacros, fpMacrosFolder]) then
    Exit;

  if SaveChanges then
  begin
    ParentFolder := GetParentFolder(tvClasses.Selected);
    MacrosItem := TscrMacrosItem.Create;

//    MacrosItem.Name := gdcMacros.GetUniqueName(NEW_MACROS_NAME, '');
//    MacrosItem.Name := gdcFunction.GetUniqueName()
    MacrosItem.IsGlobal := TscrMacrosGroupItem(ParentFolder.Data).IsGlobal;
    MacrosItem.GroupKey := TscrMacrosGroupItem(ParentFolder.Data).Id;
    Node := AddItemNode(MacrosItem, ParentFolder);
    Node.Selected := True;
    Assert(GetSelectedNodeType <> fpNone);
    Node.EditText;
    FChanged := True;
  end;
end;

procedure TdlgViewProperty.actAddMacrosUpdate(Sender: TObject);
begin
  actAddMacros.Enabled := GetSelectedNodeType in [fpMacros, fpMacrosFolder];
end;

procedure TdlgViewProperty.actDeleteFolderExecute(Sender: TObject);
begin
  if not IsEditFolder(tvClasses.Selected) then
    Exit
  else
    if MessageBox(Application.Handle, MSG_YOU_ARE_SURE, MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING or MB_TASKMODAL) = IDOK then
    case GetSelectedNodeType of
      fpMacrosFolder:
        DeleteMacrosGroupItem(tvClasses.Selected);
      fpReportFolder:
        DeleteReportGroupItem(tvClasses.Selected);
    end;
    
  tvClassesChange(tvClasses, tvClasses.Selected);
end;

procedure TdlgViewProperty.actDeleteFolderUpdate(Sender: TObject);
begin
  actDeleteFolder.Enabled := IsEditFolder(tvClasses.Selected);
end;

procedure TdlgViewProperty.actDeleteMacrosExecute(Sender: TObject);
begin
  if not IsEditMacros(tvClasses.Selected) then
    Exit
  else
    if MessageBox(Application.Handle, MSG_YOU_ARE_SURE, MSG_WARNING,
      MB_OKCANCEL or MB_ICONWARNING or MB_TASKMODAL) = IDOK then
      DeleteMacros(tvClasses.Selected);

  tvClassesChange(tvClasses, tvClasses.Selected);        
end;

procedure TdlgViewProperty.actDeleteMacrosUpdate(Sender: TObject);
begin
  actDeleteMacros.Enabled :=  IsEditMacros(tvClasses.Selected);
end;

procedure TdlgViewProperty.actRenameExecute(Sender: TObject);
begin
  if not (GetNodeType(tvClasses.Selected) in [fpMacros, fpMacrosFolder,
    fpReport, fpReportFolder]) then
    Exit
  else
    tvClasses.Selected.EditText;
end;

procedure TdlgViewProperty.actRenameUpdate(Sender: TObject);
begin
  actRename.Enabled := IsEditMacros(tvClasses.Selected) or
    IsEditFolder(tvClasses.Selected) or IsReport(tvClasses.Selected);
end;

procedure TdlgViewProperty.tvClassesExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var
  Text: String;
  Cursor: TCursor;

  procedure BeginLoad;
  begin
    tvClasses.SortType := stNone;
    Text := Node.Text;
    Node.Text := 'Загрузка...';
    Cursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;
//    Application.ProcessMessages;
  end;

  procedure EndLoad;
  begin
    Node.Text := Text;
    Screen.Cursor := Cursor;
    tvClasses.SortType := stText;
  end;

begin
  if (Node = FEventRootNode) and not FRootEventCreated then
  begin
    BeginLoad;
    try
      FEventRootNode.HasChildren := False;
      FRootEventCreated := True;
      ShowEventTreeRoot(FComponent);
    finally
      EndLoad;
    end;
  end else
  if (Node = FScrFuncNode) and not FRootScriptCreated then
  begin
    BeginLoad;
    try
      FScrFuncNode.HasChildren := FScrFuncNode.Count > 0;
      FRootScriptCreated := True;
      ShowScriptFunctionTreeRoot(FComponent);
    finally
      EndLoad;
    end;
  end else
  if (Node = FReportRootNode) and not FRootReportCreated then
  begin
    BeginLoad;
    try
      FReportRootNode.HasChildren := False;
      FRootReportCreated := True;
      ShowReportTreeRoot(FComponent);
    finally
      EndLoad;
    end;
  end else
  if (Node = FMethodRootNode) and not FRootMethodCreated then
  begin
    BeginLoad;
    try
      FMethodRootNode.HasChildren := False;
      FRootMethodCreated := True;
      AddGDCClass(Node, -1, TgdcBase);
      AddGDCClass(Node, -1, TgdcCreateableForm);
    finally
      EndLoad;
    end;
  end else
  if (Node = FVBClassRootNode) and not FRootVBClassCreated then
  begin
    BeginLoad;
    try
      FVBClassRootNode.HasChildren := False;
      FRootVBClassCreated := True;
      ShowVBClassesTreeRoot(FComponent);
    finally
      EndLoad;
    end;
  end else
  if (Node = FConstRootNode) and not FRootConstCreated then
  begin
    BeginLoad;
    try
      FConstRootNode.HasChildren := False;
      ShowConstTreeRoot;
      FRootConstCreated := True;
    finally
      EndLoad;
    end;
  end else
  if (Node = FGlobalObjectRootNode) and not FRootGlobalObjectCreated then
  begin
    BeginLoad;
    try
      FGlobalObjectRootNode.HasChildren := False;
      ShowGlobalObjectTreeRoot;
      FRootGlobalObjectCreated := True;
    finally
      EndLoad;
    end;
  end else
  if (GetNodeType(Node) = fpMethodClass) and Node.HasChildren and
    (Node.Count = 0) then
  begin
    if TCustomMethodClass(Node.Data).Class_Reference.InheritsFrom(TgdcBase) then
      AddGDCClass(Node, gdcClassList.IndexOf(TCustomMethodClass(Node.Data).Class_Reference))
    else
      AddGDCClass(Node, frmClassList.IndexOf(TCustomMethodClass(Node.Data).Class_Reference))
  end;
end;

procedure TdlgViewProperty.actAddReportExecute(Sender: TObject);
var
  Node: TTreeNode;
  ParentFolder: TTreeNode;
  ReportItem: TscrReportItem;

begin
  if not (GetNodeType(tvClasses.Selected) in [fpReport, fpReportFolder])then
    Exit;

  if SaveChanges then
  begin
    ParentFolder := GetParentFolder(tvClasses.Selected);
    ReportItem := TscrReportItem.Create;

    ReportItem.Name := gdcReport.GetUniqueName(NEW_REPORT_NAME, '');
    ReportItem.ReportGroupKey := TscrReportGroupItem(ParentFolder.Data).Id;
    Node := AddReportItem(ReportItem, ParentFolder);
    Node.Selected := True;
    Assert(GetSelectedNodeType <> fpNone);
    Node.EditText;
    FChanged := True;
    FReportCreated := True;
  end;
end;

procedure TdlgViewProperty.actAddReportUpdate(Sender: TObject);
begin
  actAddReport.Enabled := (GetNodeType(tvClasses.Selected) in [fpReport, fpReportFolder]) and
    (TscrReportGroupItem(GetParentFolder(tvClasses.Selected).Data).Id > 0){ and
    (gdcReport.State <> dsInsert)};
end;

procedure TdlgViewProperty.tvClassesEditing(Sender: TObject;
  Node: TTreeNode; var AllowEdit: Boolean);
begin
  AllowEdit := IsEditFolder(Node) or IsEditMacros(Node) or
    (GetSelectedNodeType in [fpReport]);
end;

procedure TdlgViewProperty.tvClassesEdited(Sender: TObject;
  Node: TTreeNode; var S: String);
  //Возвращает тру если АНаме уже существует
  function AllReady(const AName: String; ANode: TTreeNode): Boolean;
  var
    I: Integer;
    NodeType: TFunctionPages;
  begin
    DisableControls;
    try
      NodeType := GetNodeType(ANode);
      if NodeType = fpMacros then
        Result := gdcMacros.CheckMacros(AName)
      else if  NodeType = fpReport then
        Result := gdcReport.CheckReport(AName)
      else if NodeType in [fpScriptFunction, fpConst,
        fpGlobalObject] then
        Result := gdcFunction.CheckFunction(AName, GetObjectId(tvClasses.Selected))
      else
      begin
        I := 0;
        while (I < ANode.Parent.Count) and
          (AName <> ANode.Parent.Item[I].Text) do
          Inc(I);
        Result := I < ANode.Parent.Count;
      end;
    finally
      EnableControls;
    end;
  end;
var
  NodeType: TFunctionPages;
begin
  if not Assigned(Node.Data) then
    Exit;

  // Выходим если в базе уже есть такое имя или новое имя пустое
  if (S = '') or (AllReady(S,Node)) then
  begin
    S := Node.Text;
    Exit;
  end;

  case GetNodeType(Node) of
    fpVBClass:
      ChangeVBClassText(Node, Node.Text, S);
    fpGlobalObject:
      ChangeGlobalObjectText(Node, Node.Text, S);
  end;

  NodeType := GetNodeType(Node);
  if NodeType = fpReport then
    gdcReport.FieldByName(fnName).AsString := S
  else if NodeType in [fpScriptFunction, fpConst, fpGlobalObject] then
    gdcFunction.FieldByName(fnName).AsString := S;

  FChanged := True;
end;

procedure TdlgViewProperty.tvClassesGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  case GetNodeType(Node) of
    fpMacrosFolder, fpReportFolder, fpScriptFunctionGroup, fpConstGroup,
    fpGlobalObjectGroup:
    begin
      Node.SelectedIndex := 9;
      Node.ImageIndex := 8;
    end;
    fpMacros:
    begin
      Node.ImageIndex := 5;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    fpReport:
    begin
      Node.ImageIndex := 10;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    fpReportFunction:
    begin
      Node.ImageIndex := 23;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    fpScriptFunction:
    begin
      case SFGetType(Node) of
        sfReport: Node.ImageIndex := 23;
        sfMacros: Node.ImageIndex := 20;
        sfEvent: Node.ImageIndex := 4;
        sfMethod: Node.ImageIndex := 3;
        sfUnknown: Node.ImageIndex := 24;
      end;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    fpVBClass:
    begin
      Node.SelectedIndex := 2;
      Node.ImageIndex := 2;
    end;
  end;
end;

procedure TdlgViewProperty.tvClassesDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  TargetNode :TTreeNode;
begin
  TargetNode := tvClasses.GetNodeAt(X, Y);
  Accept := CanPaste(FCopyNode, TargetNode);
end;

procedure TdlgViewProperty.tvClassesEndDrag(Sender, Target: TObject; X,
  Y: Integer);
var
  TargetNode: TTreeNode;
begin
  if X + Y = 0 then
    Exit;
  TargetNode := tvClasses.GetNodeAt(X,Y);
  if not CanPaste(tvClasses.Selected, TargetNode) then
    Exit;
  Paste(TargetNode);
end;

procedure TdlgViewProperty.tvClassesStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  if not FChanged then
    Cut(tvClasses.Selected)
  else
    Abort;  
end;

procedure TdlgViewProperty.actCopyTreeItemExecute(Sender: TObject);
begin
  if GetNodeType(tvClasses.Selected) in [fpMacros, fpReport] then
    if SaveChanges then
      Copy(tvClasses.Selected, False)
end;

procedure TdlgViewProperty.actCopyTreeItemUpdate(Sender: TObject);
begin
  actCopyTreeItem.Enabled := GetNodeType(tvClasses.Selected) in
    [fpMacros, fpReport];
end;

procedure TdlgViewProperty.actCutTreeItemExecute(Sender: TObject);
begin
  if SaveChanges then
    Cut(tvClasses.Selected);
end;

procedure TdlgViewProperty.actCutTreeItemUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := IsEditFolder(tvClasses.Selected) or
    IsEditMacros(tvClasses.Selected) or IsReport(tvClasses.Selected);
end;

procedure TdlgViewProperty.actPasteFromClipBoardExecute(Sender: TObject);
begin
  Paste(tvClasses.Selected);
end;

procedure TdlgViewProperty.actPasteFromClipBoardUpdate(Sender: TObject);
var
  gdc: TgdcBase;
begin
  (Sender as TAction).Enabled := False;
  if IsMacrosFolder(tvClasses.Selected) then
    gdc := gdcMacrosGroup
  else if IsReportFolder(tvClasses.Selected) then
    gdc := gdcReportGroup
  else
    Exit;

  (Sender as TAction).Enabled := (gdc.CanPasteFromClipboard and
    CanPaste(FCopyNode, tvClasses.Selected));
end;

procedure TdlgViewProperty.actDeleteReportExecute(Sender: TObject);
begin
  if not IsReport(tvClasses.Selected) then
    Exit
  else
    if MessageBox(Application.Handle, MSG_YOU_ARE_SURE, MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING or MB_TASKMODAL) = IDOK then
      DeleteReportItem(tvClasses.Selected);

  tvClassesChange(tvClasses, tvClasses.Selected);
end;

procedure TdlgViewProperty.actDeleteReportUpdate(Sender: TObject);
begin
  actDeleteReport.Enabled := GetSelectedNodeType = fpReport;
end;

procedure TdlgViewProperty.tvClassesDeletion(Sender: TObject;
  Node: TTreeNode);
var
  i: Integer;
begin
  if not (csDestroying in ComponentState) then
  begin
    if Node = FCopyNode then
      FCopyNode := nil
    else
    if Node = FEventRootNode then
      FEventRootNode := nil;

    for I := 0 to pmSpeedReturn.Items.Count - 1 do
      if TCrossingSaver(pmSpeedReturn.Items[i].Tag).Node = Node then
        begin
          TCrossingSaver(pmSpeedReturn.Items[i].Tag).Node := nil;
          Break;
        end;
  end;
end;

procedure TdlgViewProperty.pcFuncParamChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  if (pcFuncParam.ActivePage = tsReport) or
    (pcFuncParam.ActivePage = tsReportTemplate) then
    AllowChange := SaveChanges;
end;

procedure TdlgViewProperty.dblcbMacrosServerClick(Sender: TObject);
begin
  SetChanged;
end;

procedure TdlgViewProperty.ShowScriptFunctionTreeRoot(AComponent: TComponent);
var
  I: Integer;
  SortType: TSortType;
  SQL: TIBSQL;
  TmpScr: TscrScriptFunction;
  InClause: string;
begin
  SortType := tvClasses.SortType;
  try
    tvClasses.SortType := stNone;
    if (AComponent is TForm) or (AComponent = Application) then
    begin
      InClause := '';
      with PropertySettings.ViewSet.SFSet do
      begin
        if ShowUserSF then
          InClause := InClause + '''' + scrUnkonownModule + ''',';
        if ShowVBClassSF then
          InClause := InClause + '''' +scrVBClasses + ''',';
        if ShowMacrosSF then
          InClause := InClause + '''' +scrMacrosModuleName + ''',';
        if ShowReportSF then
          InClause := InClause + '''' +MainModuleName + ''',''' +
            ParamModuleName + ''',''' + EventModuleName + ''',';
        if ShowEventSF then
          InClause := InClause + '''' +scrEventModuleName + ''',';
        if ShowMethodSF then
          InClause := InClause + '''' +scrMethodModuleName + ''',';
      end;
      if InClause <> '' then
        SetLength(InClause, Length(InClause) - 1)
      else
        Exit;
      DisableControls;
      try
        SQL := TIBSQL.Create(nil);
        try
          SQL.Transaction := ibtrObject;
          if (AComponent = Application) then
            SQL.SQL.Text := 'SELECT * FROM gd_function WHERE module in (' +
              InClause + ')'
          else
            SQL.SQL.Text := 'SELECT g.* FROM EVT_OBJECT Z, evt_object e, ' +
              'gd_function g WHERE e.id = ' +
              IntToStr(gdcDelphiObject.AddObject(AComponent)) +
              ' and Z.LB >= e.lb AND  Z.RB <= e.rb AND ' +
              'g.modulecode = z.id and g.module in (' + InClause + ')';
          I := 0;
          ibtrObject.StartTransaction;
          try
            SQL.ExecQuery;
            while (I < FScrFuncNode.Count) and not SQL.Eof do
            begin
              TscrScriptFunction(FScrFuncNode.Item[I].Data).ReadFromSQL(SQL);
              FScrFuncNode.Item[I].Text :=
                TscrScriptFunction(FScrFuncNode.Item[I].Data).Name;
              Inc(I);
              SQL.Next;
            end;
//            Application.ProcessMessages;
            if not SQL.Eof then
              //Записей в таблице больше чем Итемов в FScrFuncNode
              //добовляем недостающие
              while not SQL.Eof do
              begin
                TmpScr := TscrScriptFunction.Create;
                TmpScr.ReadFromSQL(SQL);
                AddItemNode(TmpScr, FScrFuncNode);
                Inc(I);
                SQL.Next;
              end;
//              Application.ProcessMessages;
               //Записей в таблице меньше чем Итемов в FScrFuncNode
               //удаляем лишние
              while I < FScrFuncNode.Count do
              begin
                FObjectList.Delete(FObjectList.IndexOf(TscrScriptFunction(FScrFuncNode.Item[I].Data)));
                FScrFuncNode.Item[I].Delete;
              end;
            ibtrObject.Commit;
          except
            ibtrObject.Rollback;
          end;
        finally
          SQL.Free;
        end;
      finally
        EnableControls;
      end;
    end;
  finally
    tvClasses.SortType := SortType;
  end;
end;

function TdlgViewProperty.IsScriptFunction(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpScriptFunction;
end;

procedure TdlgViewProperty.actAddScriptFunctionExecute(Sender: TObject);
var
  Node: TTreeNode;
  ParentFolder: TTreeNode;
  Scr: TscrScriptFunction;

begin
  if not (GetNodeType(tvClasses.Selected) in
    [fpScriptFunction, fpScriptFunctionGroup]) then
    Exit;

  if SaveChanges then
  begin
    ParentFolder := GetParentFolder(tvClasses.Selected);
    Scr := TscrScriptFunction.Create;

    Scr.Name := gdcFunction.GetUniqueName(NEW_SCRIPTFUNCTION, '', FObjectKey);
    Node := AddItemNode(Scr, ParentFolder);
    Node.Selected := True;
    Assert(GetSelectedNodeType <> fpNone);
    Node.EditText;
    FChanged := True;
  end;
end;

procedure TdlgViewProperty.actAddScriptFunctionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=
    (GetSelectedNodeType in [fpScriptFunction, fpScriptFunctionGroup]) and
    not FSingleFunction;
end;

procedure TdlgViewProperty.actDeleteScriptFunctionExecute(Sender: TObject);
begin
  if not (GetSelectedNodeType in [fpScriptFunction, fpVBClass, fpConst,
    fpGlobalObject]) then
    Exit
  else
    if MessageBox(Application.Handle, MSG_YOU_ARE_SURE, MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING or MB_TASKMODAL) = IDOK then
      DeleteScriptFunction(tvClasses.Selected);

  tvClassesChange(tvClasses, tvClasses.Selected);
end;

procedure TdlgViewProperty.actDeleteScriptFunctionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (GetSelectedNodeType = fpScriptFunction) and
    not FSingleFunction;
end;

function TdlgViewProperty.DeleteScriptFunction(const ANode: TTreeNode): Boolean;
var
  Name: string;
begin
  try
    DisableControls;
    DisableChanges;
    try
      Assert((TObject(ANode.Data) is TscrCustomItem), MSG_INVALID_DATA);
      Name := gdcFunction.FieldByName(fnName).AsString;
      if gdcFunction.State = dsInsert then
        CancelScriptFunction
      else
      begin
        gdcFunction.Delete;
        tvClasses.Selected.Delete;
      end;
      CommitTrans;

      Result := True;
      NoChanges;
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, PChar(Format(MSG_CAN_NOT_DELETE_FUNCTION,
          [Name])), MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);

      RollbackTrans;
      Result := False;
      end;
    end;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

procedure TdlgViewProperty.CancelScriptFunction;
begin
  DisableControls; //Возможно удаление нода поэтому отключаем проверку изменений
  DisableChanges;
  try
    if gdcFunction.State = dsInsert then
      tvClasses.Selected.Delete;
    gdcFunction.Cancel;
  finally
    EnableControls;
    EnableChanges;
  end;
end;

procedure TdlgViewProperty.actRefreshExecute(Sender: TObject);
var
  Expanded: Boolean;
  Id, I: Integer;
begin
  Id := 0;
  if FScrFuncNode <> nil then
  begin
    tvClasses.Items.BeginUpDate;
    Expanded := FScrFuncNode.Expanded;
    if GetSelectedNodeType in [fpScriptFunction, fpScriptFunctionGroup] then
      Id := TscrCustomItem(tvClasses.Selected.Data).Id;
    ShowScriptFunctionTreeRoot(FComponent);
    FScrFuncNode.Expanded := Expanded;
    if Id <> 0 then
      if Id = - 1 then
      begin
        FScrFuncNode.Selected := True;
        Assert(GetSelectedNodeType <> fpNone);
      end
      else
        for I := 0 to FScrFuncNode.Count - 1 do
        begin
          if TscrCustomItem(FScrFuncNode.Item[I].Data).Id = Id then
          begin
            FScrFuncNode.Item[I].Selected := True;
            Assert(GetSelectedNodeType <> fpNone);
            Break;
          end;
        end;
    tvClasses.Items.EndUpDate;
  end;
end;

procedure TdlgViewProperty.actRefreshUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := not actFuncCommit.Enabled and
    not FSingleFunction;
end;

procedure TdlgViewProperty.ParserInit;
var
  Component: TComponent;
  NameStr: string;
  Id: Integer;
  I: Integer;

  function GetComponent(AComponent: TComponent; Name: String): TComponent;
  var
    I: Integer;
  begin
    I := 0;
    Result := nil;
    while (I < AComponent.ComponentCount) and (Result = nil) do
    begin
      if UpperCase(AComponent.Components[I].Name) = Name then
        Result := AComponent.Components[I]
      else if AComponent.Components[I].ComponentCount > 0 then
        Result := GetComponent(AComponent.Components[I], Name);
      Inc(I);
    end;
  end;

begin
  if not Assigned(tvClasses.Selected) then
    Exit;
  //Выходим если нет парсера
  if not Assigned(FVBParser) then
    Exit;

  //Получаем ИД объкта которому пренадлежит скрипт
  Id := GetObjectId(tvClasses.Selected);
  //Находим объект в базе
  { DONE :
  Имеет смысл обрабатывать только события, макросы,
  функции отчета  принадлежащие конкретному окну.
  Методы принадлежат классу и поэтому имело бы смысл
  ввести обработку имен свойств и методов}
  if (Id <> OBJ_APPLICATION) and
    (GetNodeType(tvClasses.Selected) in [fpEvent, fpMacros, fpReportFunction]) then
  begin
    ibtrObject.StartTransaction;
    try
      gdcDelphiObject.Close;
      gdcDelphiObject.SubSet := ssById;
      gdcDelphiObject.Id := Id;
      gdcDelphiObject.Open;

      Assert(not gdcDelphiObject.IsEmpty);

      NameStr := UpperCase(gdcDelphiObject.FieldByName(fnName).AsString);
      ibtrObject.Commit;
    except
      ibtrObject.RollBack;
    end;

    //Получаем указатель на компонент
    if (GetNodeType(tvClasses.Selected) in [fpMacros, fpReportFunction]) then
      Component := GetComponent(Application, NameStr)
    else
      Component := (TObject(tvClasses.Selected.Parent.Data) as TEventObject).SelfObject;
    //Если компонент не форма то находим форму которой принадлежит объект
    if Assigned(Component) then
    begin
      while not ((Component is TCustomForm) or (Component is TDataModule))do
        if Assigned(Component) then
          Component := Component.Owner;
    end;
  end else
    Component := nil;

  FVBParser.ComponentName := '';
  FVBParser.Component := nil;
  FVBParser.Objects.Clear;
  if Assigned(VBProposal) then
  begin
    VBProposal.ComponentName := '';
    VBProposal.Component := nil;
    VBProposal.FKObjects.Clear;
  end;
  if Assigned(Component) then
  begin
    //регестрируем имена компонент в парсере
    FVBParser.ComponentName := Component.Name;
    FVBParser.Component := Component;
    FVBParser.Objects.Clear;
    FVBParser.Objects.Add(Component.Name);
    if Assigned(VBProposal) then
      VBProposal.FKObjects.Objects[VBProposal.FKObjects.Add(Component.Name)] :=
        Component;
    for I := 0 to Component.ComponentCount - 1 do
    begin
      FVBParser.Objects.Add(Component.Components[I].Name);
      if Assigned(VBProposal) then
       VBProposal.FKObjects.Objects[VBProposal.FKObjects.Add(
          Component.Components[I].Name)] := Component.Components[I];
    end;
  end;
end;

function TdlgViewProperty.EditScriptFunction(var AFunctionKey: Integer): Boolean;
var
  Node: TTreeNode;
  I: Integer;
  V: Boolean;
begin
  Result := False;
  if not CheckDestroing then
  begin
    if not SaveChanges then
      Exit;
    tvClasses.Selected := nil;

    V := Visible;
    actSpeedReturn.Enabled := False;

    Node := FindSFInTree(AFunctionKey);
    if not Assigned(Node) then
      raise Exception.Create('Ненайдена с-ф');
    Expand(Node);
    Node.Selected := True;
    Assert(GetSelectedNodeType <> fpNone);
//    tvClassesChange(tvClasses, Node);

    if Assigned(ScriptFactory) then
    begin
      ClearErrorResult;
      if Assigned(Debugger) then
      begin
        AddErrorListItem(nil, ScriptFactory.GetErrorList[0].Line, ScriptFactory.GeterrorList[0].Msg + '(строка: ' +
          IntToStr(ScriptFactory.GeterrorList[0].Line) + ')');
      end else
      for I := 0 to ScriptFactory.GetErrorList.count - 1 do
      begin
        AddErrorListItem(nil, ScriptFactory.GetErrorList[I].Line, ScriptFactory.GeterrorList[I].Msg + '(строка: ' +
          IntToStr(ScriptFactory.GeterrorList[I].Line) + ')');
      end;
      GotoLastError;
    end;

    FSingleFunction := True;
    try
      pnlButtons.Visible := True;
      TBItem20.Visible := False;
      TBItem1.Visible := False;
      if V then Hide;
      try
        Result := ShowModal = mrOk;
      finally
        pnlButtons.Visible := False;
        TBItem20.Visible := True;
        TBItem1.Visible := True;
        if Assigned(tvClasses.Selected) then
          tvClassesChange(tvClasses, tvClasses.Selected);
        if V then Show;
      end;
    finally
      FSingleFunction := False;
    end;
  end;
end;

procedure TdlgViewProperty.actExecReportUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (GetSelectedNodeType in [fpReport,
    fpReportFunction, fpReportTemplate]) and (gdcReport.State = dsEdit);
end;

procedure TdlgViewProperty.actExecReportExecute(Sender: TObject);
begin
  if Assigned(ClientReport) then
  begin
    if (GetSelectedNodeType = fpReport) then
      ClientReport.BuildReport(TscrReportItem(tvClasses.Selected.Data).Id)
    else
      if GetSelectedNodeType in [fpReportFunction, fpReportTemplate] then
        ClientReport.BuildReport(TscrReportItem(tvClasses.Selected.Parent.Data).Id)
  end
end;

procedure TdlgViewProperty.actFindInTreeExecute(Sender: TObject);
begin
  FindInTreeDialog.Execute;
end;

procedure TdlgViewProperty.actExpandExecute(Sender: TObject);
var
  I: Integer;
begin
  tvClasses.Items.BeginUpDate;
  for I := 0 to tvClasses.Items.Count - 1 do
  begin
    tvClasses.Items[I].Expanded := True;
  end;
  tvClasses.Items.EndUpDate;
end;

procedure TdlgViewProperty.actUnExpandExecute(Sender: TObject);
var
  I: Integer;
begin
  if SaveChanges then
  begin
    tvClasses.Items.BeginUpDate;
    for I := 0 to tvClasses.Items.Count - 1 do
    begin
      tvClasses.Items[I].Expanded := False;
    end;
    tvClasses.Items.EndUpDate;
  end;
end;

procedure TdlgViewProperty.tvClassesAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  NodeType: TFunctionPages;
begin
  NodeType := GetNodeType(Node);
  if ((NodeType = fpEvent) and
    (TEventItem(Node.Data).FunctionKey > 0)) or
    ((NodeType in [fpReportFunction, fpReportTemplate{, fpMacros,
      fpScriptFunction}]) and
    (TscrCustomItem(Node.Data).Id > 0)) or
    ((NodeType = fpMethod) and (TMethodItem(Node.Data).FunctionKey > 0)) then
  begin
    Sender.Canvas.Font.Style := [fsBold];
    if (cdsSelected in State) and not (cdsFocused in State) then
    begin
      Sender.Canvas.Font.Color := clWindowText;
      Sender.Canvas.Brush.Color := clInactiveCaptionText;
    end;
  end else if NodeType = fpEventObject then
  begin
    //Проверяем определен ли какой нибудь Event
    if TEventObject(Node.Data).SpecEventCount > 0 then
      Sender.Canvas.Font.Style := [fsBold]
  end else if NodeType = fpMethodClass then
  begin
    //Проверяем определен ли какой нибудь метод
    if TCustomMethodClass(Node.Data).SpecMethodCount > 0 then
      Sender.Canvas.Font.Style := [fsBold];
    //Если есть отключенные, то цвет красный
    if (TCustomMethodClass(Node.Data).SpecDisableMethod > 0) then
    begin
      Sender.Canvas.Font.Color := clRed
    end else
      Sender.Canvas.Font.Color := clWindowText;
    if (cdsSelected in State) then
      Sender.Canvas.Font.Color := clHighlightText;
  end;
end;

//Возвращает True если определено хотя бы одно событие
//у объекта определенного TN.Data или у дочернего объекта
function TdlgViewProperty.EventSpec(TN: TTreeNode): Boolean;
var
  I: Integer;
  NT: TFunctionPages;
begin
  Result := False;
  //Проверяем каждый дочерний нод
  for I := 0 to TN.Count - 1 do
  begin
    //Берем тип нода
    NT := GetNodeType(TN.Item[I]);
    if NT = fpEvent then
    //если это событие
    begin
      if TEventItem(TN.Item[I].Data).FunctionKey > 0 then
      begin
        //если событие определено то поиск завершен успешно
        Result := True;
        Exit;
      end;
    end
    else if NT = fpEventObject then
    //если это объект хранящий события
    begin
      //пытаемся найти событие для которого определен макрос
      //среди событий данного объёкта
      Result := EventSpec(TN.Item[I]);
      //если венули тру то поиск завершен успешно
      //поэтому выходим
      if Result then
        Exit;
    end;
  end;
end;

procedure TdlgViewProperty.OnHistoryMenuClick(Sender: TObject);
var
  MI: TMenuItem;
  Note: THistoryNote;
begin
  if Sender is TMenuItem then
  begin
    MI := TMenuItem(Sender);
    Note := FHistory.GotoPosition(MI.Tag);
    Note.Node.Selected := True;
    Assert(GetSelectedNodeType <> fpNone);
  end;
end;

procedure TdlgViewProperty.AddEventToList(const Node: TTreeNode);
var
  EI: TEventItem;
  LocEventObject: TEventObject;
  //LFunction: TrpCustomFunction;
begin
  // Проверку убирать нельзя, т.к. есть возможность не добавления в список объекта
  // тогда обновления происходить не будет

  // При таком написании кода где гарантия что сюда будет передаваться TEventObject

  // Объект из списка, все объекты не из списка должны создаваться с привязкой
  // Если объект не создан в форме, а вытянут из списка, то добавляем событие непосредственно в объект
  if not Assigned((TObject(Node.Parent.Data) as TEventObject).SelfObject) then
  begin
    EI := (TObject(Node.Parent.Data) as TEventObject).EventList.Find((TObject(Node.Data) as TEventItem).Name);
    // Если событие находим, то присваиваем ему свойства
    // Хотя можно проверять из списка он или нет
    if Assigned(EI) then
      EI.Assign(TObject(Node.Data) as TEventItem)
    // в противном случае добавляем событие в общий список
    else
      (TObject(Node.Parent.Data) as TEventObject).EventList.Add(TEventItem(Node.Data));

    if not Assigned((TObject(Node.Parent.Data) as TEventObject).EventList.Find((TObject(Node.Data) as TEventItem).Name)) then
      raise Exception.Create(Format('%s: Не удалось обновить список событий', [Self.ClassName]));
  end else
  // Если объект создан в форме то ищем на него ссылку в списке по делфовскому объекту
  begin
    LocEventObject := GetEventControl.EventObjectList.FindAllObject((TObject(Node.Parent.Data) as TEventObject).SelfObject);

    // По аналогии
    if Assigned(LocEventObject) then
    begin
      EI := LocEventObject.EventList.Find((TObject(Node.Data) as TEventItem).Name);
      if Assigned(EI) then
        EI.Assign(TObject(Node.Data) as TEventItem)
      else
        LocEventObject.EventList.Add(TEventItem(Node.Data));

      if not Assigned(LocEventObject.EventList.Find((TObject(Node.Data) as TEventItem).Name)) then
        raise Exception.Create(Format('%s: Не удалось обновить список событий', [Self.ClassName]));
    end else
      raise Exception.Create(Format('%s: Не удалось обновить список объектов', [Self.ClassName]));
  end;
  //Регестрирум функцию в глобальном списке функций

  { DONE : Необходімо прідумать способ обновленія событій для об'ектов }
  GetEventControl.SetEvents((TObject(Node.Parent.Data) as TEventObject).SelfObject);
end;

procedure TdlgViewProperty.RefreshTree(  const AnComponent: TComponent;
  const AnShowMode: TShowModeSet = smAll; const AnName: String = '';
  const Refresh: Boolean = False);
var
  I: Integer;
  TmpName: String;
  TmpScrGrp: TscrScriptFunctionGroup;
  TmpGrp: TscrReportGroupItem;
  TmpVBGrp: TscrVBClassGroup;
  TmpConstGroup: TscrConstGroup;
  TmpGlobalObjectGroup: TscrGlobalObjectGroup;
  TN: TTreeNode;
begin
  Include(FPropertyViewStates, psRefreshTree);
  try
    if (FComponent <> AnComponent) or (FShowMode <> AnShowMode) or
      (Assigned(FComponent) and
      (FComponent.ComponentCount <> FComponentCount))or Refresh or
      ((Trim(AnName) <> '') and PropertySettings.Filter.OnlySpecEvent) then
    begin
      tvClasses.Items.BeginUpdate;//oleg_m
      try
        tvClasses.SortType := stNone;
        twMessages.Hide;
        FScrFuncNode := nil;
        FEventRootNode := nil;
        FReportRootNode := nil;
        FMethodRootNode := nil;
        FVBClassRootNode := nil;
        FGMacrosRootNode := nil;
        FLMacrosRootNode := nil;
        tvClasses.Selected := nil;
        // Очистка дерева
        tvClasses.Items.Clear;
        // Очистка списка объекта
        FObjectList.Clear;
        FComponent := AnComponent;
        FComponentCount := AnComponent.ComponentCount;
        FShowMode := AnShowMode;
        FRootShowName := UpperCase(AnName);

        //Эта функция должна вызываться только после присвоения
        //поля FComponent
        SetCaption;
        FObjectKey := gdcDelphiObject.AddObject(AnComponent);

        if Trim(AnName) <> '' then
          PropertySettings.Filter.OnlySpecEvent := False;
        //Выводим дерево макросов
        if smMacros in AnShowMode then
        begin
          ShowMacrosTreeRoot(AnComponent);
        end;

        //Выводим дерево отчетов
        if smReport in AnShowMode then
        begin
          TmpGrp := TscrReportGroupItem.Create(False);
          TmpGrp.Name := REPORTS;
          TmpGrp.Id := - 1;
          FReportRootNode := AddItemNode(TmpGrp, nil);
          FReportRootNode.HasChildren := True;
          FRootReportCreated := False;
        end;

        FRootObject := AnComponent;

        if smEvent in AnShowMode then
        begin
          if not Assigned(gdcClassList) then
            Exit;
          //Добавляем папку классов
          FMethodRootNode := tvClasses.Items.AddChild(nil, ROOT_CLASSES);
          FMethodRootNode.ImageIndex := 8;
          FMethodRootNode.SelectedIndex := 9;
          FMethodRootNode.HasChildren := True;
          FRootMethodCreated := False;
        end;

        if smEvent in AnShowMode then
        begin
          //Добавляем папку объектов
          FEventRootNode := tvClasses.Items.AddChild(nil, ROOT_OBJECT);
          FEventRootNode.ImageIndex := 8;
          FEventRootNode.SelectedIndex := 9;
          if AnName = '' then
          begin
            FEventRootNode.HasChildren := True;
            FRootEventCreated := False;
          end else
          begin
            FRootEventCreated := True;
            ShowEventTreeRoot(FComponent);
          end;
        end;

        //Добавляем папку скрипт функций
        TmpScrGrp := TscrScriptFunctionGroup.Create;
        TmpScrGrp.Name := SCRIPT_FUNCTIONS;
        TmpScrGrp.Id := -1;
        FScrFuncNode := AddItemNode(TmpScrGrp, nil);
        FScrFuncNode.HasChildren := True;
        FRootScriptCreated := False;

        //Добавляем папку констант
        TmpConstGroup := TscrConstGroup.Create;
        TmpConstGroup.Name := ROOT_CONST;
        TmpConstGroup.Id := -1;
        FConstRootNode := AddItemNode(TmpConstGroup, nil);
        FConstRootNode.HasChildren := True;
        FRootConstCreated := False;

        //Добавляем папку глобальных обёектов
        TmpGlobalObjectGroup := TscrGlobalObjectGroup.Create;
        TmpGlobalObjectGroup.Name := ROOT_GLOBAL_OBJECT;
        TmpGlobalObjectGroup.Id := - 1;
        FGlobalObjectRootNode := AddItemNode(TmpGlobalObjectGroup, nil);
        FGlobalObjectRootNode.HasChildren := True;
        FRootGlobalObjectCreated := False;

        //Выводим дерево VB классов
//        if smVBClasses in AnShowMode then
//        begin
        TmpVBGrp := TscrVBClassGroup.Create;
        TmpVBGrp.Name := VBCLASSES;
        TmpVBGrp.Id := -1;
        FVBClassRootNode := AddItemNode(TmpVBGrp, nil);
        FVBClassRootNode.ImageIndex := 8;
        FVBClassRootNode.SelectedIndex := 9;
        FVBClassRootNode.HasChildren := True;
        FRootVBClassCreated := False;
//        end;
      finally//oleg_m
        tvClasses.Items.EndUpdate;
        tvClasses.SortType := stText;
      end;
    end else
    begin
      if (AnName <> '') and Assigned(FEventRootNode) then
      begin
        TN := nil;
        TmpName := Trim(UpperCase(FComponent.Name));
        for I := 0 to FEventRootNode.Count - 1 do
        begin
          if (TmpName = Trim(UpperCase((TObject(FEventRootNode.Item[I].Data) as
            TEventObject).SelfObject.Name))) then
            TN := FEventRootNode.Item[I];
        end;
        TmpName := Trim(UpperCase(AnName));
        if Assigned(TN) then
          for I := 0 to TN.Count - 1 do
            if (TmpName = Trim(UpperCase(TN.Item[I].Text))) then
            begin
              TN.Item[I].Selected := True;
              Assert(GetSelectedNodeType <> fpNone);
              Break;
            end;
      end;
    end;
    if Assigned(tvClasses.Selected) then
      tvClasses.OnChange(tvClasses, tvClasses.Selected)
    else
      tvClasses.OnChange(tvClasses, nil);
  finally
    Exclude(FPropertyViewStates, psRefreshTree);
  end;
end;

procedure TdlgViewProperty.UpdateEventSpec(TN: TTreeNode; Increment: Integer);
begin
  //проверяем правильности типа переданного нода
  if GetNodeType(TN) = fpEventObject then
  begin
    //все нормально можно работать
    repeat
      TEventObject(TN.Data).SpecEventCount := TEventObject(TN.Data).SpecEventCount +
        Increment;
      if TEventObject(TN.Data).SpecEventCount < 0 then
        TEventObject(TN.Data).SpecEventCount := 0;
      TN := TN.Parent;
    until TN.Parent = nil;
  end;
  tvClasses.Invalidate;
end;

procedure TdlgViewProperty.UpdateMethodSpec(TN: TTreeNode; Increment: Integer);
begin
  if GetNodeType(TN) = fpMethodClass then
  begin
    repeat
      TCustomMethodClass(TN.Data).SpecMethodCount := TCustomMethodClass(TN.Data).SpecMethodCount +
        Increment;
      TN := TN.Parent;
    until TN.Parent = nil;
  end;
  tvClasses.Invalidate;
end;

procedure TdlgViewProperty.hkMacrosKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if FShortCut <> hkMacros.HotKey then
    SetChanged;
end;

procedure TdlgViewProperty.hkMacrosKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FShortCut := hkMacros.HotKey;
end;

procedure TdlgViewProperty.OnScriptError(Sender: TObject);
begin
  if not CheckDestroing then
  begin
    AddErrorListItem(nil, TScriptControl(Sender).Error.Line, TScriptControl(Sender).Error.Description + '(строка: ' +
      IntToStr(TScriptControl(Sender).Error.Line) + ')');
    if Assigned(Debugger) then
      Debugger.ClearVars;  
  end;
end;

procedure TdlgViewProperty.GoToLine(Line: Integer);
begin
  GoToXY(0, Line);
end;

procedure TdlgViewProperty.ShowVBClassesTreeRoot(AComponent: TComponent);
var
  TmpVB: TscrVBClass;
  gdcF: TgdcFunction;
  TN, TC: TTreeNode;
begin
  if (AComponent is TForm) or (AComponent = Application) then
  begin
    DisableControls;
    try
      gdcF := TgdcFunction.Create(nil);
      try
        StartTrans;
        gdcF.UseScriptMethod := False;
//        gdcF.Transaction := ibtrFunction;
        TN := FVBClassRootNode;
        gdcF.SubSet := cByModule;
        gdcF.ParamByName('module').AsString := scrVBClasses;
        gdcF.Open;
//        Application.ProcessMessages;
        while not gdcF.Eof do
        begin
          TmpVB := TscrVBClass.Create;
          TmpVB.Name := gdcF.FieldByName(fnName).AsString;
          TmpVB.Id := gdcF.FieldByName(fnId).AsInteger;

          TC := AddItemNode(TmpVB, TN);
          TC.ImageIndex := 2;
          TC.SelectedIndex := 2;
          gdcF.Next;
        end;
      finally
        gdcF.Free;
      end;
    finally
      EnableControls;
    end;
  end;
end;

function TdlgViewProperty.IsVBClass(ANode: TTreeNode): Boolean;
begin
  Result := GetNodeType(ANode) = fpVBClass;
end;

procedure TdlgViewProperty.ChangeVBClassText(Node: TTreeNode;
  const OldName, NewName: String);
begin
//  gsFunctionSynEdit.Lines[0] := 'Class ' + NewName;
  TscrVBClass(Node.Data).Name := NewName;
  dbeFunctionName.Text := NewName;
  gdcFunction.FieldByName('Name').AsString := NewName;
end;


procedure TdlgViewProperty.LoadSettings;
begin
  inherited;
  
  { TODO : может сделать сохранение не в реестре а в сторадже десктопа? }
  TBRegLoadPositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);
end;

procedure TdlgViewProperty.SaveSettings;
begin
  TBRegSavePositions(Self, HKEY_CURRENT_USER, ClientRootRegistrySubKey + 'TB\' + Name);

  inherited;
end;

procedure TdlgViewProperty.DeleteEvent(FormName, ComponentName,
  EventName: string);
var
  I: Integer;
  Str: string;
  TN: TTreeNode;

  function FindComponent(Name: string; Node: TTreeNode): TTreeNode;
  var
    I: Integer;
  begin
    Result := nil;
    for I := 0 to Node.Count - 1 do
    begin
      if TObject(Node.Item[I].Data) is TEventObject then
      begin
        if UpperCase(TEventObject(Node.Item[I].Data).ObjectName) =
          Name then
            Result := Node.Item[I]
          else
            FindComponent(Name, Node.Item[I]);
        if Assigned(Result) then
          Break;
      end;
    end;
  end;

begin
  if not CheckDestroing and SaveChanges then
  begin
    if Assigned(FEventRootNode) then
    begin
      TN := nil;
      //Если окно открыто для апликэйшн или формы то ищем по имени
      //форм, если для компоненты то ищем для компоненты
      if (FComponent = Application) or (FComponent is TCreateableForm) then
        Str := UpperCase(FormName)
      else
        Str := UpperCase(ComponentName);
      for I := 0 to FEventRootNode.Count - 1 do
      begin
        if (TObject(FEventRootNode.Item[I].Data) is TEventObject) and
          (UpperCase(TEventObject(FEventRootNode.Item[I].Data).ObjectName) =
          Str) then
        begin
          if (UpperCase(FormName) <> UpperCase(ComponentName)) and
           ((FComponent = Application) or (FComponent is TCreateableForm)) then
          begin
            TN := FindComponent(UpperCase(ComponentName),
              FEventRootNode.Item[I]);
          end else
            TN := FEventRootNode.Item[I];
          if Assigned(TN) then
            Break;
        end;
      end;
      if Assigned(TN) then
      begin
        Str := UpperCase(EventName);
        for I := 0 to TN.Count - 1 do
        begin
          if (TObject(TN.Item[I].Data) is TEventItem) and
            (UpperCase(TEventItem(TN.Item[I].Data).Name) = Str) then
          begin
            TEventItem(TN.Item[I].Data).FunctionKey := 0;
            if Assigned(tvClasses.Selected) and
              (tvClasses.Selected = TN.Item[I]) then
              tvClassesChange(tvClasses, tvClasses.Selected);
            if Assigned(dlg_gsResizer_ObjectInspector) then
              dlg_gsResizer_ObjectInspector.EventSync(TEventItem(TN.Item[I].Data).EventObject.ObjectName,
                TEventItem(TN.Item[I].Data).Name);
            Break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TdlgViewProperty.AddAnyClass(ACountList, ATreeList: TList;
  AClassList: TgdcCustomClassList; const AParent: TTreeNode;
  const AnIndex: Integer; const LevelIndex: Integer = - 1);
var
  LTreeNode: TTreeNode;
  TempRC: TgdcClassMethods;

begin
//  Application.ProcessMessages;
  if (Integer(ACountList.Items[AnIndex]) < -1) {or
    ((LevelIndex <> Integer(ACountList.Items[AnIndex])) and
    ((Integer(ACountList.Items[AnIndex]) > -1) and
    (LevelIndex <> Integer(ACountList.Items[Integer(ACountList.Items[AnIndex])]))))} then
    Exit;

  TempRC := AClassList.gdcItems[AnIndex];
  LTreeNode := AParent;
  if Integer(ACountList.Items[AnIndex]) >= 0 then
  begin
    AddAnyClass(ACountList, ATreeList, AClassList,
      LTreeNode, Integer(ACountList.Items[AnIndex]), LevelIndex);
    LTreeNode := ATreeList.Items[Integer(ACountList.Items[AnIndex])];
  end;
  ATreeList.Items[AnIndex] := AddClassItem(TempRC, LTreeNode, AnIndex);
  ACountList.Items[AnIndex] := Pointer(-2);
end;

procedure TdlgViewProperty.ShowMethodTreeRoot(AnComponent: TComponent);
var
  LocClassList: TgdcClassList;
  LocFrmClassList: TfrmClassList;
  TreeList, CountList: TList;
  FrmTreeList, FrmCountList: TList;
  TempClass: TClass;
  I, J, K: Integer;
  TN: TTreeNode;

  function InheritsFromCount(AnMainClass, AnParentClass: TClass): Integer;
  asm
        { ->    EAX     Pointer to our class    }
        {       EDX     Pointer to AClass               }
        { <-    EAX      Boolean result          }
        PUSH    EBX
        MOV     EBX, 0
        JMP     @@haveVMT
@@loop:
        MOV     EAX,[EAX]
@@haveVMT:
        CMP     EAX,EDX
        JE      @@success
        INC     EBX
        MOV     EAX,[EAX].vmtParent
        TEST    EAX,EAX
        JNE     @@loop
        MOV     EAX, -1
        JMP     @@exit
@@success:
        MOV     EAX, EBX
@@exit:
        POP     EBX
  end;

  procedure DeleteNotSpecClass(TreeNode: TTreeNode);
  var
    I: Integer;
    A: array of TTreeNode;
    Count: Integer;
  begin
    Count :=  TreeNode.Count;
    SetLength(A, TreeNode.Count);
    //Инициализируем массив
    for I := 0 to Count -1 do
      A[I] := nil;
    for I := 0 to TreeNode.Count -1 do
    begin
      if Assigned(TreeNode.Item[I].Data) and
        (TObject(TreeNode.Item[I].Data) is TCustomMethodClass) then
      begin
        if (TObject(TreeNode.Item[I].Data) as TCustomMethodClass).SpecMethodCount > 0 then
          DeleteNotSpecClass(TreeNode.Item[I])
        else
           A[I] := TreeNode.Item[I];
      end;
    end;
    for I := 0 to Count -1 do
      if Assigned(A[I]) then
        A[I].Delete;
  end;

  procedure DeleteFiltered(Tn: TTreeNode);
  var
    I: Integer;
  begin
    for I := Tn.Count - 1 downto 0 do
    begin
      if TObject(Tn.Item[I].Data) is TCustomMethodClass then
        DeleteFiltered(Tn.Item[I])
    end;

    if not Filter(Tn.Text, PropertySettings.Filter.ClassName,
      TFilterOptions(PropertySettings.Filter.foClass)) then
      for I := Tn.Count - 1 downto 0 do
        if TObject(Tn.Item[I].Data) is TMethodItem then
        begin
          if TMethodItem(Tn.Item[I].Data).FunctionKey <> 0 then
            //Dec(C);
            UpdateMethodSpec(Tn, -1);
          Tn.Item[I].Delete;
        end;
//    UpdateMethodSpec(Tn, C);
    if Tn.Count = 0 then
      Tn.Delete;
  end;

begin
  TN := FMethodRootNode;
  if AnComponent = Application then
  begin
    LocClassList := gdcClassList;
    LocFrmClassList := frmClassList;
  end else
  begin
    LocClassList := TgdcClassList.Create;
    LocFrmClassList := TfrmClassList.Create;
    TempClass := AnComponent.ClassType;
    while TempClass <> nil do
    begin
      //!!!!! Помоему здесь можно обойтись и без поиска в списке
      //if TempClass.InheritsFrom(gdcBase) then
      //  LocClassList.Add(TempClass)
      //else
      //if TempClass.InheritsFrom(gdcCreatedleForm) then
      //  LocClassList(TempClass);
      //TempClass := TempClass.ClassParent;
      //!!!!!
      I := gdcClassList.IndexOf(TempClass);
      if I > -1 then
        LocClassList.Add(gdcClassList.Items[I])
      else
      begin
        I := frmClassList.IndexOf(TempClass);
        if I > -1 then
          LocFrmClassList.Add(frmClassList.Items[I])
      end;
      TempClass := TempClass.ClassParent;
    end;
  end;

  try
    TreeList := TList.Create;
    FrmTreeList := TList.Create;
    try
      CountList := TList.Create;
      FrmCountList := TList.Create;
      try
        for I := 0 to LocClassList.Count - 1 do
        begin
          CountList.Add(Pointer(-1));
          TreeList.Add(Pointer($FFFF));
        end;

        for I := 0 to LocFrmClassList.Count - 1 do
        begin
          FrmCountList.Add(Pointer(-1));
          FrmTreeList.Add(Pointer($FFFF));
        end;

        for I := 0 to LocClassList.Count - 1 do
          for J := 0 to LocClassList.Count - 1 do
          begin
            K := InheritsFromCount(LocClassList.Items[I], LocClassList.Items[J]);
            if (K > 0) then
              if (Integer(TreeList.Items[I]) > K) and (Integer(CountList.Items[I]) <> J) then
              begin
                CountList.Items[I] := Pointer(J);
                TreeList.Items[I] := Pointer(K);
              end;
          end;
        for I := 0 to LocFrmClassList.Count - 1 do
          for J := 0 to LocFrmClassList.Count - 1 do
          begin
            K := InheritsFromCount(LocFrmClassList.Items[I], LocFrmClassList.Items[J]);
            if (K > 0) then
              if (Integer(FrmTreeList.Items[I]) > K) and (Integer(FrmCountList.Items[I]) <> J) then
              begin
                FrmCountList.Items[I] := Pointer(J);
                FrmTreeList.Items[I] := Pointer(K);
              end;
          end;


        Assert(((LocClassList.Count) =
          TreeList.Count) and (TreeList.Count = CountList.Count));
        Assert(((LocFrmClassList.Count) =
          FrmTreeList.Count) and (FrmTreeList.Count = FrmCountList.Count));

        for I := 0 to LocClassList.Count - 1 do
        begin
          AddAnyClass(CountList, TreeList, LocClassList, TN, I)
        end;

        for I := 0 to LocFrmClassList.Count - 1 do
        begin
          AddAnyClass(FrmCountList, FrmTreeList,
            LocFrmClassList, TN, I)
        end;

        //Если необходимо то удаляем классы в которых не определены
        //перекрытие методы
        if PropertySettings.Filter.OnlySpecEvent then
          DeleteNotSpecClass(TN);
        for I := Tn.Count - 1 downto 0 do
          DeleteFiltered(Tn.Item[I]);
      finally
        CountList.Free;
        FrmCountList.Free;
      end;
    finally
      FrmTreeList.Free;
      TreeList.Free;
    end;
  finally
    if LocClassList <> gdcClassList then
      LocClassList.Free;
    if LocFrmClassList <> frmClassList then
      LocFrmClassList.Free;
  end;
end;

procedure TdlgViewProperty.ShowEventTreeRoot(AnComponent: TComponent);
var
  LEventObject: TEventObject;
  LEventList: TEventObjectList;
  I: Integer;
begin
  if AnComponent = Application then
    for I := 0 to AnComponent.ComponentCount - 1 do
    begin
      if AnComponent.Components[I].InheritsFrom(TCreateableForm) and
       (UpperCase(AnComponent.Components[I].ClassName) <> 'TDLGVIEWPROPERTY') and
       (UpperCase(AnComponent.Components[I].ClassName) <> 'TGSCOMPONENTEMULATOR') then
        AddEventItem(AnComponent.Components[I], FEventRootNode, GetEventControl.EventObjectList)
    end
  else
  begin
    LEventObject := GetEventControl.EventObjectList.FindAllObject(AnComponent);
    if Assigned(LEventObject) then
      LEventList := LEventObject.ParentList
    else
      LEventList := nil;
    AddEventItem(AnComponent, FEventRootNode, LEventList);
  end;
end;

function TdlgViewProperty.SFGetType(TN: TTreeNode): sfTypes;
begin
  if (TscrScriptFunction(TN.Data).Module = MainModuleName) or
    (TscrScriptFunction(TN.Data).Module = ParamModuleName) or
    (TscrScriptFunction(TN.Data).Module = EventModuleName) then
    Result := sfReport
  else if (TscrScriptFunction(TN.Data).Module = scrEventModuleName) then
    Result := sfEvent
  else if (TscrScriptFunction(TN.Data).Module = scrMacrosModuleName) then
    result := sfMacros
  else if (TscrScriptFunction(TN.Data).Module = scrMethodModuleName) then
    Result := sfMethod
  else
    Result := sfUnknown;
end;

procedure TdlgViewProperty.UpDataFunctionParams(
  FunctionParams: TgsParamList);
var
  I, J: Integer;
  ParamDlg: TgsParamList;
begin
  //Прозиводим обнавление параметров
  if pcFunction.ActivePage = tsParams then
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
      GetParamsFromText(FunctionParams, dbeFunctionName.Text, gsFunctionSynEdit.Text);
      for I := 0 to FunctionParams.Count - 1 do
      begin
        for J := 0 to ParamDlg.Count - 1 do
          if FunctionParams.Params[I].RealName = ParamDlg.Params[J].RealName then
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

procedure TdlgViewProperty.EditReport(IDReportGroup, IDReport: Integer);
var
  I: Integer;
  TN: TTreeNode;
begin
  if not CheckDestroing then
  begin
    //Обновляем дерево
    RefreshTree(Application, FShowMode + [smReport], '');
    if Assigned(FReportRootNode) then
    begin
      if not FRootReportCreated then
      begin
        FRootReportCreated := True;
        FReportRootNode.HasChildren := True;
        ShowReportTreeRoot(FComponent);
      end;
      if IDReport <> 0 then
      begin
        for I := 0 to tvClasses.Items.Count - 1 do
          if (TObject(tvClasses.Items[I].Data) is TscrReportItem) and
            (TscrReportItem(tvClasses.Items[I].Data).Id = IDReport) then
          begin
            tvClasses.Items[I].Selected := True;
            Assert(GetSelectedNodeType <> fpNone);
            Break;
          end;
      end else
      begin
        TN := nil;
        if IDReportGroup <> 0 then
          for I := 0 to tvClasses.Items.Count - 1 do
            if (TObject(tvClasses.Items[I].Data) is TscrReportGroupItem) and
              (TscrReportGroupItem(tvClasses.Items[I].Data).Id = IDreportGroup) then
              TN := tvClasses.Items[I];
        if Assigned(TN) then
        begin
          TN.Selected := True;
//          tvClassesChange(tvClasses, TN);
          Assert(GetSelectedNodeType <> fpNone);
        end
        else
        begin
          FReportRootNode.Selected := True;
          Assert(GetSelectedNodeType <> fpNone);
        end;
        actAddReportExecute(nil);
      end;
    end;
    //показывем окно
    Show;
  end;
end;

class function TdlgViewProperty.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(dlgViewProperty) then
    dlgViewProperty := TdlgViewProperty.Create(AnOwner);

  Result := dlgViewProperty;
end;

procedure TdlgViewProperty.ShowConstTreeRoot;
var
  SQL: TIBSQL;
  TmpConst: TscrConst;
begin
  if not Assigned(FConstRootNode) then
    Exit;

  SQL := TIBSQL.Create(nil);
  try
    ibtrObject.StartTransaction;
    try
      SQL.Transaction := ibtrObject;
      SQL.SQL.Text := 'SELECT * FROM gd_function WHERE module = ''' +
        scrConst + '''';
      SQL.ExecQuery;
      while not SQL.Eof do
      begin
        TmpConst := TscrConst.Create;
        TmpConst.ReadFromSQL(SQL);
        AddItemNode(TmpConst, FConstRootNode);
        SQL.Next;
      end;
    finally
      ibtrObject.Commit;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdlgViewProperty.ShowGlobalObjectTreeRoot;
var
  SQL: TIBSQL;
  TmpGlobalObject: TscrGlobalObject;
begin
  if not Assigned(FGlobalObjectRootNode) then
    Exit;

  SQL := TIBSQL.Create(nil);
  try
    ibtrObject.StartTransaction;
    try
      SQL.Transaction := ibtrObject;
      SQL.SQL.Text := 'SELECT * FROM gd_function WHERE module = ''' +
        scrGlobalObject + '''';
      SQL.ExecQuery;
      while not SQL.Eof do
      begin
        TmpGlobalObject := TscrGlobalObject.Create;
        TmpGlobalObject.ReadFromSQL(SQL);
        AddItemNode(TmpGlobalObject, FGlobalObjectRootNode);
        SQL.Next;
      end;
    finally
      ibtrObject.Commit;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdlgViewProperty.Loaded;
{$IFDEF GEDEMIN}
var
  L: Integer;
{$ENDIF}
begin
  inherited;
  {$IFDEF GEDEMIN}
  if Assigned(Application.MainForm) {and (Position = poDesigned)} then
  begin
    if FormAssigned(gdc_frmExplorer) then
      L := gdc_frmExplorer.Left + gdc_frmExplorer.Width
    else
      L := 200;
    Left := L;
    Top := Application.MainForm.Top + Application.MainForm.Height;
    Height := Screen.DesktopHeight - Top - 26;
    Width := Screen.DesktopWidth - L;
  end;
  {$ENDIF}
end;

procedure TdlgViewProperty.LoadSettingsAfterCreate;
begin
  inherited;
end;

procedure TdlgViewProperty.OnDebuggerStateChange(Sender: TObject; OldState,
  NewState: TDebuggerState);
begin
  if not CheckDestroing then
  begin
    if Assigned(gsFunctionSynEdit) and Assigned(Debugger) then
    begin
      GotoLine(Debugger.CurrentLine + 1);
//      gsFunctionSynEdit.Invalidate;
      if FActive then
        SetCaption(NewState);
      actDebugRun.Enabled := not (NewState in [dsRunning, dsStep, dsStepOver]) and
        ((GetSelectedNodeType in [fpMacros, fpReportFunction, fpScriptFunction])
        or (NewState = dsPaused));
      actDebugPause.Enabled :=  not (NewState in [dsPaused, dsStopped, dsReset]) and
        (GetSelectedNodeType in [fpMacros, fpEvent, fpMethod, fpReportFunction,
        fpScriptFunction, fpVBClass]);
    end;
  end;  
end;

procedure TdlgViewProperty.ChangeGlobalObjectText(Node: TTreeNode;
  const OldName, NewName: String);
var
  bp: Integer;
  LOldName, NewGlobalObject: String;
begin
  LOldName := AnsiUpperCase(OldName);
  NewGlobalObject := '';
  bp := Pos(LOldName, AnsiUpperCase(gsFunctionSynEdit.Lines.Text));
  while bp > 0 do
  begin
    // проверка для того чтобы отделить объявление гл.объекта от других имен,
    // которые могут вкл. в себя название гл.объекта
    {перед названием гл.объекта символа либо нет, либо он не из NameSymbol,
     за последним символом либо нет символа, либо он не из NameSymbol,
     либо после названия GL_OBJ_INIT(инициализация) или GL_OBJ_TERM(уничтожение),
     после которого тоже либо нет символа, либо он не из NameSymbol}
    if ((bp = 1) or
      (Pos(System.Copy(gsFunctionSynEdit.Lines.Text, bp - 1, 1), NameSymbol) = 0)) and
      ((bp + Length(LOldName) = Length(gsFunctionSynEdit.Lines.Text)) or
      (Pos(System.Copy(gsFunctionSynEdit.Lines.Text, bp + Length(LOldName), 1),
      NameSymbol) = 0) or
      ((Pos(AnsiUpperCase(System.Copy(gsFunctionSynEdit.Lines.Text, bp + Length(LOldName), Length(GL_OBJ_INIT))),
      GL_OBJ_INIT) = 1) and (Pos(System.Copy(gsFunctionSynEdit.Lines.Text, bp + Length(LOldName) +
      Length(GL_OBJ_INIT), 1), NameSymbol) = 0)) or
      ((Pos(AnsiUpperCase(System.Copy(gsFunctionSynEdit.Lines.Text, bp + Length(LOldName), Length(GL_OBJ_TERM))),
      GL_OBJ_TERM) = 1) and (Pos(System.Copy(gsFunctionSynEdit.Lines.Text, bp + Length(LOldName) +
      Length(GL_OBJ_INIT), 1), NameSymbol) = 0)))

       then
    begin
      NewGlobalObject := NewGlobalObject +
        System.Copy(gsFunctionSynEdit.Lines.Text, 1, bp - 1) + NewName;
      gsFunctionSynEdit.Lines.Text := System.Copy(gsFunctionSynEdit.Lines.Text, bp + Length(LOldName),
        Length(gsFunctionSynEdit.Lines.Text));
    end else
      begin
        NewGlobalObject := NewGlobalObject +
          System.Copy(gsFunctionSynEdit.Lines.Text, 1, bp + Length(OldName) - 1) ;
        gsFunctionSynEdit.Lines.Text := System.Copy(gsFunctionSynEdit.Lines.Text, bp + Length(LOldName),
          Length(gsFunctionSynEdit.Lines.Text));
      end;
    bp := Pos(LOldName, AnsiUpperCase(gsFunctionSynEdit.Lines.Text));
  end;
  gsFunctionSynEdit.Lines.Text := NewGlobalObject +
    gsFunctionSynEdit.Lines.Text;

  TscrGlobalObject(Node.Data).Name := NewName;
  dbeFunctionName.Text := NewName;
  gdcFunction.FieldByName('Name').AsString := NewName;
  gdcFunction.FieldByName('Script').AsString := gsFunctionSynEdit.Lines.Text;
end;

procedure TdlgViewProperty.GotoErrorLine(ErrorLine: Integer);
begin
  if Assigned(Debugger) then
    Debugger.SetErrorLine(ErrorLine - 1);
  GotoLine(ErrorLine);
  if Visible and gsFunctionSynEdit.CanFocus then
    gsFunctionSynEdit.SetFocus;
end;

function TdlgViewProperty.FindTreeNode(SF: TrpCustomFunction): TTreeNode;
var
  I: Integer;
  TmpScr: TscrScriptFunction;
  SQL: TIBSQL;
begin
  Result := nil;
  Assert(Assigned(Sf), 'Не присвоено значение');

  if Assigned(FScrFuncNode) then
  begin
    for I := 0 to FScrFuncNode.Count - 1 do
    begin
      if (TObject(FScrFuncNode.Item[I].Data) as TscrScriptFunction).Id =
        SF.FunctionKey then
      begin
        Result := FScrFuncNode.Item[I];
        Break;
      end
    end;
  end;

  if not Assigned(Result) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ibtrObject;
      SQL.SQL.Text := 'SELECT * FROM gd_function WHERE id = ' +
        IntToStr(Sf.FunctionKey);
      ibtrObject.StartTransaction;
      try
        SQL.ExecQuery;
        if not SQL.Eof then
        begin
          TmpScr := TscrScriptFunction.Create;
          TmpScr.ReadFromSQL(SQL);
          AddItemNode(TmpScr, FScrFuncNode);
        end else
          raise Exception.Create('Не найдена функция');
      finally
        ibtrObject.Rollback;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TdlgViewProperty.Expand(TN: TTreeNode);
var
  TmpTn: TTreeNode;
begin
  if Assigned(Tn) then
  begin
    TmpTn := Tn;
    tvClasses.Items.BeginUpdate;
    try
      while TmpTN.Parent <> nil do
      begin
        TmpTn := TmpTN.Parent;
        TmpTn.Expanded := True;
      end;
    finally
      tvClasses.Items.EndUpdate;
    end;
  end;
end;

procedure TdlgViewProperty.DebugScriptFunction(const AFunctionKey: Integer;
  const AModuleName: string; const CurrentLine: Integer);
var
  Node: TTreeNode;
begin
  if not CheckDestroing then
  begin
    if Assigned(Debugger) then
    begin
      if AFunctionKey = 0 then
        raise Exception.Create('Значение ключа функции должен быть больше 0');

      if not (gdcFunction.State in [dsInsert, dsEdit]) or
        (gdcFunction.FieldByName(fnID).AsInteger <> AFunctionKey) then
      begin
        { DONE : Необходимо реализовать поиск в зависимости от Модуля функции }
        if not SaveChanges then
          Exit;

        tvClasses.Selected := nil;
        Node := FindSFInTree(AFunctionKey, AModuleName);
        if not Assigned(Node) then
          Exit;
        Node.Selected := True;
        Assert(GetSelectedNodeType <> fpNone);
      end;

      if not Debugger.DisplayScriptFunction.BreakPointsPrepared or
        (Debugger.DisplayScriptFunction.FunctionKey <>
        Debugger.ExecuteScriptFunction.FunctionKey)then
      begin
        Debugger.DisplayDebugLines.Assign(Debugger.ExecuteDebugLines);
        Debugger.DisplayScriptFunction.Assign(Debugger.ExecuteScriptFunction);
      end;
    end;
    Show;
  end;  
end;

function TdlgViewProperty.CheckModefy: Boolean;
var
  MR: Integer;
begin
  Result := FChanged;
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
        Result := not OverallCommit;
        if not Result then
          tvClassesChange(tvClasses, tvClasses.Selected);
      end;
      ID_NO:
      begin
        OverallRollback;
        tvClassesChange(tvClasses, tvClasses.Selected);
        Result := False;
      end;
      IDCANCEL: Result := True;
    end;
  end;
end;

function TdlgViewProperty.IsExecuteScript: Boolean;
begin
  Result := Assigned(Debugger) and (Debugger.ExecuteScriptFunction.FunctionKey =
    gdcFunction.FieldByName(fnId).AsInteger) and not Debugger.IsStoped;
end;

procedure TdlgViewProperty.MethodVisible(MethodItem: TTreeNode;
  const AVirtualMethod: Boolean);
begin
  if (not Assigned(MethodItem.Data)) or
    (not (TObject(MethodItem.Data) is TMethodItem)) then
  exit;

  if ((TObject(MethodItem.Data) as TMethodItem).FunctionKey = 0) and
    (not AVirtualMethod) then
  begin
    actDisableMethod.Enabled := False;
    MethodItem.ImageIndex := 34;
    MethodItem.SelectedIndex := 34;
  end else
    begin
      if not TMethodItem(MethodItem.Data).Disable then
      begin
        biDisableMethod.ImageIndex := 32;
        actDisableMethod.ImageIndex := 32;
        actDisableMethod.Hint := 'Отключить скрипт-метод';
        actDisableMethod.Caption := 'Отключить метод';
        MethodItem.ImageIndex := 3;
        MethodItem.SelectedIndex := 3;
//        if TCustomMethodClass(MethodItem.Parent.Data).SpecDisableMethod > 0 then
//          TCustomMethodClass(MethodItem.Parent.Data).SpecDisableMethod :=
//            TCustomMethodClass(MethodItem.Parent.Data).SpecDisableMethod - 1;
      end else
        begin
          biDisableMethod.ImageIndex := 31;
          actDisableMethod.ImageIndex := 31;
          actDisableMethod.Hint := 'Подключить скрипт-метод';
          actDisableMethod.Caption := 'Подключить метод';
          MethodItem.ImageIndex := 30;
          MethodItem.SelectedIndex := 30;
        end;
      actDisableMethod.Enabled := True;
    end;
//  SetChanged;
end;

procedure TdlgViewProperty.SetMethodView(AMethod: TMethodItem);
var
  i: Integer;
begin
  for i := 0 to tvClasses.Items.Count - 1 do
    if tvClasses.Items[i].Data = AMethod then
      MethodVisible(tvClasses.Items[i], True);
end;

procedure TdlgViewProperty.OnSpeedReturnMenuClick(Sender: TObject);
var
  MI: TMenuItem;
  i: Integer;
  LNode: TTreeNode;
  LCursor: TCursor;
begin
  if not (Sender is TMenuItem) then
    Exit;

  MI := TMenuItem(Sender);

  if Assigned(TCrossingSaver(MI.Tag).Node) then
    for i := 0 to tvClasses.Items.Count - 1 do
    begin
      if tvClasses.Items[i] = TCrossingSaver(MI.Tag).Node then
      begin
        tvClasses.Items[i].Selected := True;
        Assert(GetSelectedNodeType <> fpNone);
        Exit;
      end
    end;

  LCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  LNode := FindSFInTree(TCrossingSaver(MI.Tag).FunctionKey, TCrossingSaver(MI.Tag).ModuleName, False);
  Screen.Cursor := LCursor;
  if Assigned(LNode) then
    begin
      LNode.Selected := True;
      Assert(GetSelectedNodeType <> fpNone);
    end else
    begin
      MessageBox(Application.Handle, PChar('Скрипт-функция ' + MI.Caption + ' не обнаружена.'#13#10 +
        'Возможно она была удалена или нет объекта для нее.'), PChar('Ошибка перехода'),
        MB_OK or MB_ICONINFORMATION or MB_TOPMOST or MB_TASKMODAL);
      pmSpeedReturn.Items.Delete(pmSpeedReturn.Items.IndexOf(MI));
     end;
end;

procedure TdlgViewProperty.ClearSpeedReturnPopup;
var
  i: Integer;
begin
  for i := 0 to pmSpeedReturn.Items.Count - 1 do
    TCrossingSaver(pmSpeedReturn.Items[i].Tag).Free;
  pmSpeedReturn.Items.Clear;
end;

function TdlgViewProperty.GetStatament(var Str: String; Pos: Integer): String;
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

function TdlgViewProperty.GetCompliteStatament(var Str: String;
  Pos: Integer; out BeginPos, EndPos: Integer): String;
var
//  BeginPos, EndPos: Integer;
  CB: Integer;
begin
  Result := '';

  BeginPos := Pos;
  if BeginPos > Length(Str) then
    BeginPos := Length(Str);
  EndPos := BeginPos;
  CB := 0;
  while (BeginPos > 1) and ((System.Pos(Str[BeginPos - 1], Letters + '.)') > 0) or
    ((System.Pos(Str[BeginPos - 1], Letters + '.') = 0) and (CB > 0))) do
  begin
    if Str[BeginPos - 1] = ')' then
      Inc(CB);
    if Str[BeginPos] = '(' then
      Dec(CB);
    Dec(BeginPos);
  end;

  while (EndPos >= 1) and (System.Pos(Str[EndPos], Letters) > 0) do
    Inc(EndPos);
  if BeginPos < EndPos then
    Result := System.Copy(Str, BeginPos, EndPos - BeginPos)
  else
    Result := '';
end;

procedure TdlgViewProperty.PropertyNotification(AComponent: TComponent;
  Operation: TOperation);
var
  C: TComponent;

  function FindComponentNode(AComponent: TComponent): TTreeNode;
  var
    I: Integer;
  begin
    Result := nil;
    for I := 0 to FEventRootNode.Count - 1 do
    begin
      if Assigned(FEventRootNode.Item[I].Data) and
        ((TObject(FEventRootNode.Item[I].Data) as TEventObject).SelfObject =
        AComponent) then
      begin
        Result := FEventRootNode.Item[I];
        Break;
      end;
    end;
  end;

begin
  if not CheckDestroing and Assigned(AComponent) and
    Assigned(FEventRootNode) then
  begin
    case Operation of
    Classes.opInsert:
      if (AComponent <> Self) and (AComponent is TCreateableForm) and
        FRootEventCreated then
      begin
        ClearEventRootNode;
      end;
    Classes.opRemove:
      begin
        //Если удаляемый компонент явл-ся компнентом для которого
        //вызывалось окно редактирования св-в то обновляем
        //дерево но для сомтонента апликэшн
        if AComponent = FComponent then
          RefreshTree(Application, smAll, '', True);

        if FRootEventCreated then
        begin
          //если было создано дерево объектов то
          //удаляем его
          C := GetOwnerForm(AComponent);
          if Assigned(C) and Assigned(FindComponentNode(C)) then
            ClearEventRootNode;
        end;
      end;
    end;
  end;
end;

function TdlgViewProperty.FindSFInTree(ID: Integer;
  Module: String; const FindInDB: Boolean = True;
  ARefreshTree: Boolean = True): TTreeNode;
var
  SQL: TIBSQL;
  I: Integer;
  TmpScr: TscrScriptFunction;
  AllowExpansion: Boolean;
//  trFlag: Boolean;

  function FindEvent(ID: Integer; Parent: TTreeNode): TTreeNode;
  var
    I: Integer;
  begin
    Result := nil;
    if not Assigned(Parent) then
      Exit;

    for I := 0 to Parent.Count - 1 do
    begin
      if Assigned(Parent.Item[I].Data) then
      begin
        if (TObject(Parent.Item[I].Data) is TEventObject) then
          Result := FindEvent(Id, Parent.Item[I])
        else
        if (TObject(Parent.Item[I].Data) is TEventItem)  and
          (TEventItem(Parent.Item[I].Data).FunctionKey = Id) then
          Result := Parent.Item[I];
      end;
      if Assigned(Result) then
        Break;
    end;
  end;

  function FindMethod(ID: Integer; Parent: TTreeNode): TTreeNode;
  var
    I: Integer;
  begin
    Result := nil;
    if not Assigned(Parent) then
      Exit;

    for I := 0 to Parent.Count - 1 do
    begin
      if Assigned(Parent.Item[I].Data) then
      begin
        if (TObject(Parent.Item[I].Data) is TCustomMethodClass) then
          Result := FindMethod(Id, Parent.Item[I])
        else
        if (TObject(Parent.Item[I].Data) is TMethodItem)  and
          (TMethodItem(Parent.Item[I].Data).FunctionKey = Id) then
          Result := Parent.Item[I];
      end;
      if Assigned(Result) then
        Break;
    end;
  end;

  function FindMacros(ID: Integer; Parent: TTreeNode): TTreeNode;
  var
    I: Integer;
  begin
    Result := nil;
    if not Assigned(Parent) then
      Exit;

    for I := 0 to Parent.Count - 1 do
    begin
      if Assigned(Parent.Item[I].Data) then
      begin
        if (TObject(Parent.Item[I].Data) is TscrMacrosGroupItem) then
          Result := FindMacros(Id, Parent.Item[I])
        else
        if (TObject(Parent.Item[I].Data) is TscrMacrosItem)  and
          (TscrMacrosItem(Parent.Item[I].Data).FunctionKey = Id) then
          Result := Parent.Item[I];
      end;
      if Assigned(Result) then
        Break;
    end;
  end;

  function FindReportFunction(ID: Integer; Parent: TTreeNode): TTreeNode;
  var
    I: Integer;
  begin
    Result := nil;
    if not Assigned(Parent) then
      Exit;

    for I := 0 to Parent.Count - 1 do
    begin
      if Assigned(Parent.Item[I].Data) and
        (TObject(Parent.Item[I].Data) is TscrReportFunction) and
        (TscrReportFunction(Parent.Item[I].Data).Id = Id) then
      begin
        Result := Parent.Item[I];
        Break;
      end
    end;
  end;

  function FindReport(ID: Integer; Parent: TTreeNode): TTreeNode;
  var
    I: Integer;
  begin
    Result := nil;
    if not Assigned(Parent) then
      Exit;

    for I := 0 to Parent.Count - 1 do
    begin
      if Assigned(Parent.Item[I].Data) then
      begin
        if (TObject(Parent.Item[I].Data) is TscrReportGroupItem) then
          Result := FindReport(Id, Parent.Item[I])
        else
        if (TObject(Parent.Item[I].Data) is TscrReportItem) then
          Result := FindReportFunction(Id, Parent.Item[I]);
      end;
      if Assigned(Result) then
        Break;
    end;
  end;

begin
  Result := nil;
  if ID <= 0 then
    Exit;

  tvClasses.Items.BeginUpdate;
  try
    AllowExpansion := False;
    if (Module = scrEventModuleName) then
    begin
      if not Assigned(FEventRootNode) and ARefreshTree then
        RefreshTree(Application, FShowMode + [smEvent, smMethod], '', True);
      if Assigned(FEventRootNode) then
      begin
        tvClassesExpanding(nil, FEventRootNode, AllowExpansion);
        Result := FindEvent(Id, FEventRootNode);
      end;
    end else
    if (Module = scrMethodModuleName) then
    begin
      if not Assigned(FMethodRootNode) and ARefreshTree then
        RefreshTree(Application, FShowMode + [smEvent, smMethod], '', True);
      if Assigned(FMethodRootNode) then
      begin
        tvClassesExpanding(nil, FMethodRootNode, AllowExpansion);
        Result := FindMethod(Id, FMethodRootNode);
      end;
    end else
    if Module = scrMacrosModuleName then
    begin
      if not Assigned(FGMacrosRootNode) and ARefreshTree then
         RefreshTree(Application, FShowMode + [smMacros], '', True);
      if Assigned(FGMacrosRootNode) then
        Result := FindMacros(Id, FGMacrosRootNode);
      if not Assigned(Result) and Assigned(FLMacrosRootNode) then
        Result := FindMacros(Id, FLMacrosRootNode);
    end else
    if (Module = scrVBClasses) then
    begin
      if not Assigned(FVBClassRootNode) and ARefreshTree then
         RefreshTree(Application, FShowMode + [smVBClasses], '', True);
      if Assigned(FVBClassRootNode) then
      begin
        tvClassesExpanding(nil, FVBClassRootNode, AllowExpansion);
        for I := 0 to FVBClassRootNode.Count - 1 do
        begin
          if Assigned(FVBClassRootNode.Item[I].Data) and
            (TObject(FVBClassRootNode.Item[I].Data) is TscrVBClass) and
            (TscrVBClass(FVBClassRootNode.Item[I].Data).Id = Id) then
          begin
            Result := FVBClassRootNode.Item[I];
            Break;
          end
        end;
      end;
    end else
    if (Module = scrConst) and Assigned(FConstRootNode) then
    begin
      if not Assigned(FConstRootNode) and ARefreshTree then
        RefreshTree(Application, FShowMode + [smVBClasses], '', True);
      if Assigned(FConstRootNode) then
      begin
        tvClassesExpanding(nil, FConstRootNode, AllowExpansion);
        for I := 0 to FConstRootNode.Count - 1 do
        begin
          if Assigned(FConstRootNode.Item[I].Data) and
            (TObject(FConstRootNode.Item[I].Data) is TscrConst) and
            (TscrConst(FConstRootNode.Item[I].Data).Id = Id) then
          begin
            Result := FConstRootNode.Item[I];
            Break;
          end
        end;
      end;
    end else
    if (Module = scrGlobalObject) and Assigned(FGlobalObjectRootNode) then
    begin
      if not Assigned(FGlobalObjectRootNode) and ARefreshTree then
        RefreshTree(Application, FShowMode + [smVBClasses], '', True);
      if Assigned(FGlobalObjectRootNode) then
      begin
        tvClassesExpanding(nil, FGlobalObjectRootNode, AllowExpansion);
        for I := 0 to FGlobalObjectRootNode.Count - 1 do
        begin
          if Assigned(FGlobalObjectRootNode.Item[I].Data) and
            (TObject(FGlobalObjectRootNode.Item[I].Data) is TscrGlobalObject) and
            (TscrGlobalObject(FGlobalObjectRootNode.Item[I].Data).Id = Id) then
          begin
            Result := FGlobalObjectRootNode.Item[I];
            Break;
          end
        end;
      end;
    end else
    if (Module = MainModuleName) or (Module = ParamModuleName) or
      (Module = EventModuleName) then
    begin
      if not Assigned(FReportRootNode) and ARefreshTree then
         RefreshTree(Application, FShowMode + [smReport], '', True);
      if Assigned(FReportRootNode) then
      begin
        tvClassesExpanding(nil, FReportRootNode, AllowExpansion);
        Result := FindReport(Id, FReportRootNode);
      end;
    end;

    //Если нужная функция не найдена в дереве то производим поиск
    //в базе
    if not Assigned(Result) then
    begin
      if not Assigned(FScrFuncNode)  and ARefreshTree then
        RefreshTree(Application, FShowMode + [smScriptFunction], '', True);
      if Assigned(FScrFuncNode) then
      begin
        tvClassesExpanding(nil, FScrFuncNode, AllowExpansion);

        if ID <> 0 then
        begin
          for I := 0 to FScrFuncNode.Count - 1 do
            if (TObject(FScrFuncNode.Item[I].Data) is TscrScriptFunction) and
              (TscrScriptFunction(FScrFuncNode.Item[I].Data).Id = ID) then
            begin
              Result := FScrFuncNode.Item[I];
              Break;
            end;
          if not Assigned(Result) and FindInDB then
          begin
            SQL := TIBSQL.Create(nil);
            try
              SQL.SQL.Text := 'SELECT * FROM gd_function WHERE id = :id';
              SQL.Transaction := gdcFunction.ReadTransaction;
              SQL.Params[0].AsInteger := Id;
              SQL.ExecQuery;
              if not SQL.Eof then
              begin
                TmpScr := TscrScriptFunction.Create;
                TmpScr.ReadFromSQL(SQL);
                Result := AddItemNode(TmpScr, FScrFuncNode);
              end;
            finally
              SQL.Free;
            end;
          end
        end;
      end;
    end;
  finally
    if not Assigned(Result) then
      Application.MessageBox('Функция не найдена ', MSG_WARNING,
        IDOK or MB_TASKMODAL);
    tvClasses.Items.EndUpdate;
  end;
end;

procedure TdlgViewProperty.ShowAllRoot;
var
  B: Boolean;
begin
  tvClasses.Items.BeginUpdate;
  try
    B := False;
    if Assigned(FScrFuncNode) then
      tvClassesExpanding(nil, FScrFuncNode, B);
    if Assigned(FEventRootNode) then
      tvClassesExpanding(nil, FEventRootNode, B);
    if Assigned(FReportRootNode) then
      tvClassesExpanding(nil, FReportRootNode, B);
    if Assigned(FMethodRootNode) then
      tvClassesExpanding(nil, FMethodRootNode, B);
    if Assigned(FVBClassRootNode) then
      tvClassesExpanding(nil, FVBClassRootNode, B);
    if Assigned(FConstRootNode) then
      tvClassesExpanding(nil, FConstRootNode, B);
    if Assigned(FGlobalObjectRootNode) then
      tvClassesExpanding(nil, FGlobalObjectRootNode, B);
  finally
     if Assigned(tvClasses.Selected) then
       tvClassesChange(tvClasses, tvClasses.Selected);
     tvClasses.Items.EndUpdate;
  end;
end;

procedure TdlgViewProperty.GoToXY(X, Y: Integer);
begin
  if (Y > 0) and (Y <= gsFunctionSynEdit.Lines.Count) then
  begin
    gsFunctionSynEdit.CaretX := X;
    gsFunctionSynEdit.CaretY := Y;
    gsFunctionSynEdit.EnsureCursorPosVisibleEx(True);
    gsFunctionSynEdit.InvalidateLine(Y);
  end;
end;

procedure TdlgViewProperty.ClearSearchResult;
var
  I: Integer;
begin
  for I := lvMessages.Items.Count - 1 downto 0 do
  begin
    if Assigned(lvMessages.Items[I].Data) and
      (TObject(lvMessages.Items[I].Data) is TSearchMessageItem) then
    lvMessages.Items[I].Delete;
  end;
end;

procedure TdlgViewProperty.ClearEventRootNode;
begin
  if Assigned(FEventRootNode) then
  begin
    Include(FPropertyViewStates, psRefreshTree);
    tvClasses.Items.BeginUpdate;
    try
      if GetSelectedNodeType in [fpEventObject, fpEvent] then
        SaveChanges;
      FEventRootNode.DeleteChildren;
      FRootEventCreated := False;
      FEventRootNode.HasChildren := True;
      if Assigned(tvClasses.Selected) then
        tvClassesChange(tvClasses, tvClasses.Selected);
    finally
      tvClasses.Items.EndUpdate;
      Exclude(FPropertyViewStates, psRefreshTree);
    end;
  end;
end;

function TdlgViewProperty.GetPath(ANode: TTreeNode): String;
begin
  Result := '';
  while Assigned(ANode.Parent) do
  begin
    ANode := ANode.Parent;
    Result := '\' + ANode.Text + Result;
  end;
  if Result <> '' then
    Result := '\' + Result;
end;

procedure TdlgViewProperty.SaveReportResult;
var
  Str: TStream;
begin
  Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('testresult'),
    DB.bmWrite);
  try
    PrepareTestResult;
    FLastReportResult.SaveToStream(Str);
  finally
    Str.Free;
  end;
end;

procedure TdlgViewProperty.SaveFunctionParams;
var
  Str: TStream;
begin
  if FFunctionParams.Count > 0 then
  begin
    Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('enteredparams'), DB.bmWrite);
    try
      FFunctionParams.SaveToStream(Str);
    finally
      Str.Free;
    end;
  end else
    gdcFunction.FieldByName('enteredparams').Clear;
end;

procedure TdlgViewProperty.LoadReportResult;
var
  Str: TStream;
begin
  Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('testresult'), DB.bmRead);
  try
    FLastReportResult.LoadFromStream(Str);
  finally
    Str.Free;
  end;
end;

procedure TdlgViewProperty.ToggleBreakpoint(Line: Integer);
var
  Fnc: TrpCustomFunction;
  Str: TStream;
begin
  if Assigned(Debugger) then
  begin
    Debugger.ToggleBreakpoint(Line - 1);
    if IsExecuteScript then
      Debugger.ToggleExecuteBreakpoint(Line - 1);
  end;

  Fnc := glbFunctionList.FindFunction(gdcFunction.FieldByName(fnId).AsInteger);
  if Assigned(Fnc) then
  begin
    Fnc.BreakPoints.Size := 0;
    Debugger.DisplayDebugLines.SaveBPToStream(Fnc.BreakPoints);
  end;


  if Assigned(Debugger) then
  begin
    //Сохраняем в базу т.к. при запуске функции она считавыется из базы
    Str := gdcFunction.CreateBlobStream(gdcFunction.FieldByName('breakpoints'), DB.bmWrite);
    try
      Debugger.DisplayDebugLines.SaveBPToStream(Str);
    finally
      Str.Free;
    end;
  end;

  FFunctionNeadSave := True;
  gsFunctionSynEdit.InvalidateGutter;
  gsFunctionSynEdit.InvalidateLine(Line);
end;

procedure TdlgViewProperty.ChangeHighLight;
begin
  if gdcFunction.FieldByName('language').AsString = DefaultLanguage then
  begin
    gsFunctionSynEdit.Highlighter := SynVBScriptSyn1;
    gsFunctionSynEdit.Parser := FVBParser;
  end else
  begin
    gsFunctionSynEdit.Highlighter := SynJScriptSyn1;
    gsFunctionSynEdit.Parser := nil;
  end;
  SelectColorChange;
end;

procedure TdlgViewProperty.SelectNode(Node: TTreeNode);
begin
  if Assigned(Node) then
  begin
    Node.Selected := True;
    Assert(GetSelectedNodeType <> fpNone);
    while Assigned(Node.Parent) do
    begin
      Node := Node.Parent;
      Node.Expanded := True;
    end;
  end;
end;

function TdlgViewProperty.CheckDestroing: Boolean;
begin
  Result := Application.Terminated or (csDestroying in ComponentState);
end;

function TdlgViewProperty.FindEventNode(AComponent: TComponent;
  Name: String): TTreeNode;
{var
  AllowExpansion: Boolean;
  Tmp: TComponent;
  NameList: TStrings;
  I, J: Integer;
  Node: TTreeNode;}
begin
  Result := nil;
{  if not Assigned(AComponent) or (Name = '') or (AComponent = Application) then
    Exit;

  Include(FShowMode, smEvent);
  if not Assigned(FEventRootNode) then
    RefreshTree(Application, FShowMode, '', True);

  if Assigned(FEventRootNode) then
  begin
    tvClassesExpanding(nil, FEventRootNode, AllowExpansion);
    Tmp := AComponent;
    NameList := TStringList.Create;
    try
      NameList.Add(UpperCase(Tmp.Name));
      while (not Tmp.InheritsFrom(TCustomForm)) and ((Tmp.Owner <> nil) or
        (Tmp.Owner <> Application)) do
      begin
        Tmp := Tmp.Owner;
        NameList.Add(UpperCase(Tmp.Name));
      end;
      Node := FEventRootNode;
      for I := 0 to NameList.Count - 1 do
      begin
        for J := 0 to Node.Count - 1 do
        begin
          if Assigned(Node.Item[J].Data) and
            (TObject(Node.Item[J].Data) is TEventObject) and
            (UpperCase(TEventObject(Node.Item[J].Data).ObjectName) = NameList[I]) then
          begin
            Break;
          end;
        end;
        if J = Node.Count then
          Exit
        else
          Node := Node.Item[J];
      end;
      if I < NameList.Count then
      begin
        for I := 0 to Node.Count - 1 do
        begin
          if Assigned(Node.Item[I].Data) and
            (TObject(Node.Item[I].Data) is TEventItem) and
            (UpperCase(TEventItem(Node.Item[I].Data).Name) = UpperCase(Name)) then
          begin
            Result := Node.Item[I];
            Break;
          end;
        end;
      end;
    finally
      NameList.Free;
    end;
  end;}
end;

procedure TdlgViewProperty.SelectColorChange;
begin
  if gsFunctionSynEdit.Highlighter = SynVBScriptSyn1 then
  begin
    gsFunctionSynEdit.SelectedColor.Foreground :=
      SynVBScriptSyn1.MarkBlockAttri.Foreground;
    gsFunctionSynEdit.SelectedColor.Background :=
      SynVBScriptSyn1.MarkBlockAttri.Background;
  end else
  begin
    gsFunctionSynEdit.SelectedColor.Foreground := clHighlightText;
    gsFunctionSynEdit.SelectedColor.Background := clHighlight;
  end;
end;

procedure TdlgViewProperty.DoCreate;
begin
  inherited;

  if Assigned(_OnCreateForm) then
    _OnCreateForm(Self);
end;

procedure TdlgViewProperty.DoDestroy;
begin
  if Assigned(_OnDestroyForm) then
    _OnDestroyForm(Self);

  inherited;
end;

procedure TdlgViewProperty.Activate;
begin
  inherited;

  if Assigned(_OnActivateForm) then
    _OnActivateForm(Self);
end;

function TdlgViewProperty.GetOwnerForm(
  AComponent: TComponent): TCustomForm;
var
  TmpComp: TComponent;
begin
  Result := nil;
  if Assigned(AComponent) and not AComponent.InheritsFrom(TCustomForm) then
  begin
    TmpComp := AComponent;
    while (TmpComp <> nil) and (TmpComp <> Application) and
      not (TmpComp.InheritsFrom(TCustomForm)) do
      TmpComp := TmpComp.Owner;
    if TmpComp.InheritsFrom(TCustomForm) then
      Result := TCustomForm(TmpComp);
  end;
end;

procedure TdlgViewProperty.ClearErrorResult;
var
  I: Integer;
begin
  for I := lvMessages.Items.Count - 1 downto 0 do
  begin
    if Assigned(lvMessages.Items[I].Data) and
      (TObject(lvMessages.Items[I].Data) is TErrorMessageItem) then
    lvMessages.Items[I].Delete;
  end;
end;

function TdlgViewProperty.ErrorCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for i := 0 to lvMessages.Items.Count -1 do
  begin
    if Assigned(lvMessages.Items[I].Data) and
      (TObject(lvMessages.Items[I].Data) is TErrorMessageItem) then
      Inc(Result);
  end;
end;

procedure TdlgViewProperty.GotoLastError;
var
  I: Integer;
begin
  for I := lvMessages.Items.Count - 1 downto 0 do
  begin
    if Assigned(lvMessages.Items[I].Data) and
      (TObject(lvMessages.Items[I].Data) is TErrorMessageItem) then
    begin
      lvMessages.Items[I].Selected := True;
      lvMessages.Items[I].MakeVisible(False);
      Break;
    end;
  end;
end;

function TdlgViewProperty.IsPropertyMsg(const Msg: TMsg): Boolean;
begin
  Result := IsComponentMsg(Self, Msg);
end;

function TdlgViewProperty.IsComponentMsg(C: TComponent;
  const Msg: TMsg): Boolean;
var
  I: Integer;
begin
  Result := (C is TWinControl) and (Msg.hwnd = TWinControl(C).Handle);
  if not Result then
  begin
    for I := 0 to C.ComponentCount - 1 do
    begin
      Result := IsComponentMsg(C.Components[I], Msg);
      if Result then Exit;
    end;
  end;
end;

function TdlgViewProperty.AddErrorListItem(Node: TTreeNode; Line: Integer;
  Caption: String): TListItem;
var
  LI: TListItem;
  EM: TErrorMessageItem;
begin
  Result := nil;
  if not CheckDestroing then
  begin
    if not Assigned(Debugger) or (ErrorCount = 0) then
    begin
      LI := lvMessages.Items.Add;
      EM := TErrorMessageItem.Create;
      LI.Data := EM;
      EM.Node := Node;
      EM.Line := Line;
      if Assigned(Debugger) then
        EM.FunctionKey := Debugger.LastScriptFunction;

      LI.Caption := Caption;
      if not twMessages.Visible then
        twMessages.Visible := True;
      LI.MakeVisible(False);
      Result := LI;
    end;
  end;
end;

function TdlgViewProperty.GetDebugStateName: String;
begin
  Result := '';
  if Assigned(Debugger) then
  begin
    with Debugger do
    begin
      if IsRunning or IsStep or IsStepOver or IsReseted then
        Result := GetDebugStateName(dsRunning)
      else
      if IsPaused then
        Result := GetDebugStateName(dsPaused);
    end;
  end;
end;

function TdlgViewProperty.GetDebugStateName(State: TDebuggerState): String;
begin
  Result := '';
  if Assigned(Debugger) then
  begin
    with Debugger do
    begin
      if State in [dsRunning, dsStep, dsStepOver, dsReset] then
        Result := '[Running]'
      else
      if State = dsPaused then
        Result := '[Paused]';
    end;
  end;
end;

procedure TdlgViewProperty.SetCaption;
begin
  if FComponent = Application then
    Caption := Format(cCaption, ['Application', GetDebugStateName])
  else
  begin
    if FComponent.Name <> '' then
      Caption := Format(cCaption, [FComponent.Name, GetDebugStateName])
    else
      Caption := Format(cCaption, [FComponent.ClassName, GetDebugStateName]) ;
  end;
end;

procedure TdlgViewProperty.SetCaption(State: TDebuggerState);
begin
  if FComponent = Application then
    Caption := Format(cCaption, ['Application', GetDebugStateName(State)])
  else
  begin
    if FComponent.Name <> '' then
      Caption := Format(cCaption, [FComponent.Name, GetDebugStateName(State)])
    else
      Caption := Format(cCaption, [FComponent.ClassName, GetDebugStateName(State)]) ;
  end;
end;

procedure TdlgViewProperty.OnCurrentLineChange(Sender: TObject);
var
  T, B: Integer;
begin
  if not CheckDestroing and Assigned(Debugger) then
  begin
    T := gsFunctionSynEdit.TopLine - 1;
    B := gsFunctionSynEdit.TopLine + gsFunctionSynEdit.LinesInWindow;
    if ((T <= FCurrentLine) and ( B > FCurrentLine)) or ((T <=
    Debugger.CurrentLine) and (B > Debugger.CurrentLine))then
      gsFunctionSynEdit.Invalidate;
    FCurrentLine := Debugger.CurrentLine;
  end;
end;

function TdlgViewProperty.FindSFInTree(ID: Integer;
  ARefreshTree: Boolean = True): TTreeNode;
var
  SQL: TIBSQL;
  Module: String;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcFunction.ReadTransaction;
    SQL.SQL.Text := 'SELECT module FROM gd_function WHERE id = ' + IntToStr(Id);
    SQL.ExecQuery;
    if not SQL.Eof then
      Module := SQL.Fields[0].AsString
    else Exit;
    Result := FindSFInTree(ID, Module, True, ARefreshTree);
  finally
    SQL.Free;
  end;
end;
procedure TdlgViewProperty.DoShow;
begin
  inherited;

  if not (gdcFunction.State in [dsInsert, dsEdit]) then
  begin
    if Assigned(tvClasses.Selected) then
      tvClassesChange(tvClasses, tvClasses.Selected)
    else
      tvClassesChange(tvClasses, nil);
  end;
end;

function TdlgViewProperty.GetDBId: Integer;
var
  SQL: TIBSQL;
begin
  if FDBID = 0 then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcMacrosGroup.ReadTransaction;
      SQL.SQL.Text := 'SELECT gen_id(GD_G_DBID, 0) AS dbid ' +
        'FROM RDB$DATABASE';
      SQL.ExecQuery;
      FDBID := SQL.Fields[0].AsInteger;
    finally
      SQL.Free;
    end;
  end;
  Result := FDBID;
end;

function TdlgViewProperty.AddFRMClassNode(AParent: TTreeNode; I: Integer;
  SubType, SubTypeComent: String): TTreeNode;
var
  CClass: CgdcCreateableForm;
  MClass: TCustomMethodClass;
  FullName: String;
  LFullClassName: TgdcFullClassName;
begin
  Result := nil;
  CClass := frmClassList[I];

  if Assigned(CClass) then
  begin
    LFullClassName.gdClassName := CClass.ClassName;
    LFullClassName.SubType := SubType;
    FullName := CClass.ClassName + SubType;
    MClass := TCustomMethodClass(MethodControl.FindMethodClass(LFullClassName));
    if MClass = nil then
    begin
      //Если не найден то регистрируем его в списке
      MClass := TCustomMethodClass(MethodControl.AddClass(0, LFullClassName, CClass));
//      MClass := TCustomMethodClass(MethodControl.MethodClass[Index]);
//      Index := MethodControl.AddClass(0, LFullClassName, CClass);
//      MClass := TCustomMethodClass(MethodControl.MethodClass[Index]);
    end;
    MClass.Class_Reference := CClass;
    MClass.SubType := SubType;
    MClass.SubTypeComment := SubTypeComent;

    Result := tvClasses.Items.AddChild(AParent, FullName);
    if SubType <> '' then
    begin
      if PropertySettings.GeneralSet.FullClassName then
        Result.Text := FullName
      else
        Result.Text := SubType;
    end else
      Result.Text := MClass.Class_Name;
    Result.Data := MClass;
  end;
end;

procedure TdlgViewProperty.AddGDCClass(AParent: TTreeNode; Index: Integer;
  CClass: TClass);
var
  LocClassList: TgdcCustomClassList;
  TreeList, CountList: TList;
  I, J, K: Integer;
  TN: TTreeNode;
  MClass: TgdcClassMethods;
  MC, LMethodClass: TCustomMethodClass;
  TheMethod: TMethodItem;
  ST: TStrings;
  IsGDC: Boolean;
  FltFlag: Boolean;

  function AddM(M: TMethodItem; Parent: TTreeNode): TTreeNode;
  var
    FltFlag: Boolean;
  begin
    Result := nil;
    FltFlag := Filter(M.Name ,PropertySettings.Filter.MethodName,
      TFilterOptions(PropertySettings.Filter.foMethod));
    //Применяем фильтр
    if FltFlag and
      (PropertySettings.Filter.OnlySpecEvent and (M.FunctionKey > 0) or
      not PropertySettings.Filter.OnlySpecEvent) then
      Result := AddMethodItem(M, Parent);
  end;

  procedure InitOverloadAndDisable(C: TCustomMethodClass);
  var
    SQL: TIBSQL;
  begin
    if C.Class_Key > 0 then
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.SQL.Text := 'SELECT COUNT(*) FROM evt_objectevent e, evt_object o1, ' +
          ' evt_object o2 WHERE e.objectkey = o2.id AND o1.lb <= o2.lb AND ' +
          ' o1.rb >= o2.rb AND o1.id = :id AND e.FunctionKey > 0';
        SQL.Transaction := gdcDelphiObject.ReadTransaction;
        SQL.Params[0].AsInteger := C.Class_Key;
        SQL.ExecQuery;
        C.SpecMethodCount := SQL.Fields[0].AsInteger;
      finally
        SQL.Free;
      end;
    end;
  end;

  function ClassFilter(Index: Integer; AIsGDC: Boolean; SubType: string): Boolean;
  var
    I: Integer;
    C: TComponentClass;
    MC: TCustomMethodClass;
    SQl: TIBSQL;
    LFullClassName: TgdcFullClassName;
  begin
    if AIsGDC then
      C := TgdcClassList(LocClassList).Items[Index]
    else
      C := TfrmClassList(LocClassList).Items[Index];

    LFullClassName.gdClassName := C.ClassName;
    LFullClassName.SubType := SubType;
    MC := TCustomMethodClass(MethodControl.FindMethodClass(LFullClassName));

    if PropertySettings.Filter.OnlySpecEvent then
    begin
      Result := True;
      if Assigned(MC) then
      begin
        InitOverloadAndDisable(MC);
        if MC.SpecMethodCount > 0 then
        begin
          SQL := TIBSQL.Create(nil);
          try
            SQL.Transaction:= gdcFunction.ReadTransaction;
            SQL.SQL.Text := 'SELECT e.eventname FROM evt_objectevent e, evt_object o1, ' +
              ' evt_object o2 WHERE e.objectkey = o2.id AND o1.lb <= o2.lb AND ' +
              ' o1.rb >= o2.rb AND o1.id = :id AND e.FunctionKey > 0';
            SQL.Params[0].AsInteger := MC.Class_Key;
            SQL.ExecQuery;
            while not SQL.Eof do
            begin
              Result := Filter(SQL.Fields[0].AsString ,PropertySettings.Filter.MethodName,
                TFilterOptions(PropertySettings.Filter.foMethod));
              if Result then Break;
              SQL.Next;
            end;
          finally
            SQL.Free;
          end;
        end else
          Result := False;
      end else
        Result := False;
      if not Result then Exit;
    end;

    Result := Filter(C.ClassName + SubType, PropertySettings.Filter.ClassName,
      TFilterOptions(PropertySettings.Filter.foClass));
    if not Result and (SubType = '') then
    begin
      for I := 0 to CountList.Count - 1 do
      begin
        if CountList[I] = Pointer(Index) then
          Result := ClassFilter(I, AIsGDC, SubType);
        if Result then
          Exit;
      end;
    end;
  end;

begin
//  TCustomTreeFolder(AParent.Data).ChildsCreated := True;
  IsGDC := CClass.InheritsFrom(TgdcBase);
  if IsGDC then
    LocClassList := gdcClassList
  else
    LocClassList := frmClassList;

  TreeList := TList.Create;
  try
    CountList := TList.Create;
    try
      for I := 0 to LocClassList.Count - 1 do
      begin
        CountList.Add(Pointer(-1));
        TreeList.Add(Pointer($FFFF));
      end;

      if IsGDC then
      begin
        for I := 0 to LocClassList.Count - 1 do
          for J := 0 to LocClassList.Count - 1 do
          begin
            K := InheritsFromCount(TgdcClassList(LocClassList).Items[I],
               TgdcClassList(LocClassList).Items[J]);
            if (K > 0) then
              if (Integer(TreeList.Items[I]) > K) and (Integer(CountList.Items[I]) <> J) then
              begin
                CountList.Items[I] := Pointer(J); //Класс с индексам I и класс с индексом J
                TreeList.Items[I] := Pointer(K);  //отделяется K наследованиями
              end;
          end;
      end else
      begin
        for I := 0 to LocClassList.Count - 1 do
          for J := 0 to LocClassList.Count - 1 do
          begin
            K := InheritsFromCount(TfrmClassList(LocClassList).Items[I],
              TfrmClassList(LocClassList).Items[J]);
            if (K > 0) then
              if (Integer(TreeList.Items[I]) > K) and (Integer(CountList.Items[I]) <> J) then
              begin
                CountList.Items[I] := Pointer(J); //Класс с индексам I и класс с индексом J
                TreeList.Items[I] := Pointer(K);  //отделяется K наследованиями
              end;
          end;
      end;

      Assert(((LocClassList.Count) =
        TreeList.Count) and (TreeList.Count = CountList.Count));

      if (AParent = FMethodRootNode) or
        (TCustomMethodClass(AParent.Data).SubType = '') then
      begin
        for I := 0 to CountList.Count - 1 do
          if (CountList[I] = Pointer(Index)) and ClassFilter(I, IsGDC, '') then
          begin
            if IsGDC then
              TN := AddGDCClassNode(AParent, I, '', '')
            else
              TN := AddFRMClassNode(AParent, I, '', '');

            TN.HasChildren := True;
            //Если установлен флаг PropertySettings.Filter.OnlySpecEvent то
           //InitOverloadAndDisable для данного класса вызывалась при фильтрации
           //иначе вызываем здесь
            if not PropertySettings.Filter.OnlySpecEvent then
              InitOverloadAndDisable(TN.Data);
          end;

        if GetNodeType(AParent) = fpMethodClass then
        begin
          ST := TStringList.Create;
          try
            MC := TCustomMethodClass(AParent.Data);
            if MC.Class_Reference.InheritsFrom(TgdcBase) then
              CgdcBase(MC.Class_Reference).GetSubTypeList(ST)
            else
              CgdcCreateableForm(MC.Class_Reference).GetSubTypeList(ST);
              //Добавляем SubTypы класса
              for I := 0 to ST.Count - 1 do
              begin
                if ClassFilter(Index, IsGDC, ChangeIncorrectSymbol(ST.Values[ST.Names[I]])) then
                begin
                  if MC.Class_Reference.InheritsFrom(TgdcBase) then
                    TN := AddGDCClassNode(AParent, Index,
                      ChangeIncorrectSymbol(ST.Values[ST.Names[I]]), ST.Names[I])
                  else
                    TN := AddFRMClassNode(AParent, Index,
                      ChangeIncorrectSymbol(ST.Values[ST.Names[I]]), ST.Names[I]);
                  TN.HasChildren := True;
                  //Если установлен флаг PropertySettings.Filter.OnlySpecEvent то
                  //InitOverloadAndDisable для данного класса вызывалась при фильтрации
                  //иначе вызываем здесь
                  if not PropertySettings.Filter.OnlySpecEvent then
                    InitOverloadAndDisable(TN.Data);
                end;
              end;
          finally
            ST.Free;
          end;
        end;
      end;

      if (GetNodeType(AParent) = fpMethodClass) then
      begin
         FltFlag := Filter(TCustomMethodClass(AParent.Data).Class_Name +
          TCustomMethodClass(AParent.Data).SubType, PropertySettings.Filter.ClassName,
          TFilterOptions(PropertySettings.Filter.foClass));
        // Добавляем методы класса
        if IsGDC then
          MClass := gdcClassList.gdcItems[Index]
        else
          MClass := frmClassList.gdcItems[Index];

        for I := 0 to MClass.gdcMethods.Count - 1 do
        begin
          //Ищем метод среди уже зарегестрированных в БД
          LMethodClass := TCustomMethodClass(AParent.Data);
          TheMethod := LMethodClass.MethodList.Find(
            MClass.gdcMethods.Methods[I].Name);
          if TheMethod = nil then // if not exist in DB but registered
          begin
            j := LMethodClass.MethodList.Add(
              MClass.gdcMethods.Methods[I].Name, 0, False, LMethodClass);
            TheMethod := LMethodClass.MethodList.Items[j];
//            TheMethod.MethodClass := TCustomMethodClass(AParent.Data);
          end;

          TheMethod.MethodData := @MClass.gdcMethods.Methods[I].ParamsData;
          if FltFlag then
            AddM(TheMethod, AParent);
        end;

         // Adding inherited methods
        if GetNodeType(AParent.Parent) = fpMethodClass then
        begin
          MC := TCustomMethodClass(AParent.Parent.Data);
          for I := 0 to MC.MethodList.Count - 1 do
          begin
            //Ищем метод среди уже зарегестрированных в БД
            LMethodClass := TCustomMethodClass(AParent.Data);
            TheMethod := LMethodClass.MethodList.Find(
              MC.MethodList.Name[I]);
            if TheMethod = nil then // if not exist in DB but registered
            begin
              j := LMethodClass.MethodList.Add(
                MC.MethodList.Name[I], 0, False, LMethodClass);
              TheMethod := LMethodClass.MethodList.Items[j];
//              TheMethod.MethodClass := TCustomMethodClass(AParent.Data);
            end;

            TheMethod.MethodData := MC.MethodList.Items[I].MethodData;
            if FltFlag then
              AddM(TheMethod, AParent);
          end;
        end;
      end;
    finally
      CountList.Free;
    end;
  finally
    TreeList.Free;
  end;
end;

procedure TdlgViewProperty.AddGDCClass(AParent: TTreeNode; Index: Integer);
begin
  if GetNodeType(AParent) = fpMethodClass then
    AddGDCClass(AParent, Index, TCustomMethodClass(AParent.Data).Class_Reference);
end;

function TdlgViewProperty.AddGDCClassNode(AParent: TTreeNode; I: Integer;
  SubType, SubTypeComent: String): TTreeNode;
var
  CClass: CgdcBase;
  MClass: TCustomMethodClass;
  LFullClassName: TgdcFullClassName;
  { TODO : Не будет никакого фулнэйма, подтип и класс будет разделен }
//  FullName: String;
begin
  Result := nil;
  CClass := gdcClassList[I];

  if Assigned(CClass) then
  begin
    LFullClassName.gdClassName := CClass.ClassName;
    LFullClassName.SubType := SubType;
    MClass := TCustomMethodClass(MethodControl.FindMethodClass(LFullClassName));
    if MClass = nil then
    begin
      //Если не найден то регистрируем его в списке
      MClass := TCustomMethodClass(MethodControl.AddClass(0, LFullClassName, CClass));
//      MClass := TCustomMethodClass(MethodControl.MethodClass[Index]);
//      Index := MethodControl.AddClass(0, LFullClassName, CClass);
//      MClass := TCustomMethodClass(MethodControl.MethodClass[Index]);
    end;
    MClass.Class_Reference := CClass;
    MClass.SubType := SubType;
    MClass.SubTypeComment := SubTypeComent; 

    Result := tvClasses.Items.AddChild(AParent, CClass.ClassName + SubType);
    if SubType <> '' then
    begin
      if PropertySettings.GeneralSet.FullClassName then
        Result.Text := CClass.ClassName + SubType
      else
        Result.Text := SubType;
    end else
      Result.Text := MClass.Class_Name;
    Result.Data := MClass;
  end;
end;

{ THistory }

function THistory.Add(Note: THistoryNote): Integer;
var
  PNote: PHistoryNote;
  TmpNote: PHistoryNote;
begin
  //Указатель находится в середине списка поэтому удаляем
  //все записи правее указалеля
  while FPosition < Count - 1 do
    Delete(Count - 1);

  if Count > 0 then
  begin
    TmpNote := PHistoryNote(Last);
    if TmpNote^.Node = Note.Node then
    begin
      TmpNote^.CarretPos := Note.CarretPos;
      Result := Count - 1;
    end else
    begin
      GetMem(PNote, SizeOf(THistoryNote));
      PNote^ := Note;
      Result := inherited Add(PNote);
    end;
  end else
  begin
    GetMem(PNote, SizeOf(THistoryNote));
    PNote^ := Note;
    Result := inherited Add(PNote);
  end;
  FPosition := Count - 1;
end;

procedure THistory.Clear;
begin
  while Count > 0 do
    Delete(Count - 1);
end;

constructor THistory.Create;
begin
  FPosition := - 1;
end;

procedure THistory.Delete(Index: Integer);
begin
  FreeMem(Items[Index], SizeOf(THistoryNote));
  
  inherited Delete(Index);
end;

destructor THistory.Destroy;
begin
  Clear;

  inherited;
end;

function THistory.GotoPosition(Index: Integer): THistoryNote;
begin
  Result := THistoryNote(Items[Index]^);
  FPosition := Index;
end;

function THistory.IsBegin: Boolean;
begin
  Result := FPosition <= 0;
end;

function THistory.IsEnd: Boolean;
begin
  Result := FPosition >= Count - 1;
end;

function THistory.Next(out Note: THistoryNote): Boolean;
begin
  if not IsEnd then
  begin
    Inc(FPosition);
    Note := THistoryNote(Items[FPosition]^);
    Result := True;
  end else
    Result := False;
end;

function THistory.Previous(var Note: THistoryNote): Boolean;
begin
  if not IsBegin then
  begin
    Dec(FPosition);
    Note := THistoryNote(Items[FPosition]^);
    Result := True;
  end else
    Result := False;
end;

procedure TdlgViewProperty.actPrevExecute(Sender: TObject);
var
  Note: THistoryNote;
  CanGo: Boolean;
begin
  if not FHistory.IsBegin then
  begin
    FHistory.Previous(Note);
    tvClasses.OnChanging(tvClasses, tvClasses.Selected, CanGo);
    if CanGo then
    begin
      Note.Node.Selected := True;
      Assert(GetSelectedNodeType <> fpNone);
      tvClasses.OnChange(tvClasses, Note.Node);
      gsFunctionSynEdit.CaretXY := Note.CarretPos;
    end;
  end;
end;

procedure TdlgViewProperty.actPrevUpdate(Sender: TObject);
begin
  actPrev.Enabled := not FHistory.IsBegin;
end;

procedure TdlgViewProperty.actNextExecute(Sender: TObject);
var
  Note: THistoryNote;
  CanGo: Boolean;
begin
  if FHistory.Next(Note) then
  begin
    tvClasses.OnChanging(tvClasses, tvClasses.Selected, CanGo);
    if CanGo then
    begin
      Note.Node.Selected :=True;
      tvClasses.OnChange(tvClasses, Note.Node);
      gsFunctionSynEdit.CaretXY := Note.CarretPos;
    end;
  end;
end;

procedure TdlgViewProperty.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := not FHistory.IsEnd;
end;

procedure TdlgViewProperty.tbHistoryMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  R: TRect;
  MI: TMenuItem;
begin
  if Button = TMouseButton(1) then
  begin
    pmHistory.Items.Clear;
    with tbHistory do
    begin
      R := View.Find(tbiPrev).BoundsRect;
      if (R.Left < X) and (R.Right > X) and (R.Top < Y) and (R.Bottom > Y) then
        for I := 0 to FHistory.Position - 1 do
        begin
          MI := TMenuItem.Create(Self);
          MI.Caption := THistoryNote(FHistory[I]^).Node.Text;
          MI.OnClick := OnHistoryMenuClick;
          MI.Tag := I;
          pmHistory.Items.Insert(0, MI);
        end else
      begin
        R := View.Find(tbiNext).BoundsRect;
        if (R.Left < X) and (R.Right > X) and (R.Top < Y) and (R.Bottom > Y) then
          for I := FHistory.Position + 1 to FHistory.Count - 1 do
          begin
            MI := TMenuItem.Create(Self);
            MI.Caption := THistoryNote(FHistory[I]^).Node.Text;
            MI.OnClick := OnHistoryMenuClick;
            MI.Tag := I;
            pmHistory.Items.Add(MI);
          end else
            Exit;
      end;
      R.TopLeft := ClientToScreen(R.TopLeft);
      R.BottomRight := ClientToScreen(R.BottomRight);
    end;
    pmHistory.PopUp(R.Left, R.Bottom);
  end;
end;

procedure TdlgViewProperty.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  glbFunctionList.Clear;
end;

procedure TdlgViewProperty.actPrepareExecute(Sender: TObject);
var
  SF: TgdScriptFactory;
  OldOnError: TNotifyEvent;
begin
  ClearErrorResult;

  gsFunctionSynEdit.UpdateRecord;

  if Assigned(ScriptFactory) then
  begin
    { TODO : Добавление кода в скрипт функтион }
    SF := TgdScriptFactory(ScriptFactory.Get_Self);
    OldOnError := SF.OnRSError;
    SF.OnRSError := OnScriptError;
    SF.ShowErrorDialog := False;
    try
      SF.ScriptTest(glbFunctionList.FindFunction(gdcFunction.FieldByName('ID').AsInteger));
      MessageBox(Application.Handle, 'Удачное завершение.'#13#10 + 'Синтаксические ошибки не обнаружены.',
        PChar('Тест текста ' + dbeFunctionName.Text),
        MB_OK or MB_ICONINFORMATION or MB_TOPMOST or MB_TASKMODAL);
    finally
      SF.ShowErrorDialog := True;
      SF.OnRSError := OldOnError;
      twMessages.Visible := lvMessages.Items.Count <> 0;
    end;
  end;
end;

{ TDebugSupportPlugin }

procedure TDebugSupportPlugin.AfterPaint(ACanvas: TCanvas; AClip: TRect;
  FirstLine, LastLine: integer);
var
  LH, X, Y: integer;
  LI: TDebuggerLineInfos;
  ImgIndex: integer;
begin
  if not Assigned(Debugger) then
    Exit;

  if (Images <> nil) and (Debugger.DisplayDebugLines.Count >= FirstLine) then
  begin
    X := 14;
    LH := Editor.LineHeight;
    Y := (LH - Images.Height) div 2
      + LH * (FirstLine - Editor.TopLine);
    while FirstLine <= LastLine do
    begin
      LI := Debugger.GetLineInfos(FirstLine - 1);
      if (Debugger.CurrentLine = FirstLine - 1) and
        IsExecuteScript then
      begin
        if dlBreakpointLine in LI then
          ImgIndex := 2
        else
          ImgIndex := 1;
      end else
      if dlExecutableLine in LI then
      begin
        if dlBreakpointLine in LI then
          ImgIndex := 3
        else
          ImgIndex := 0;
        if dlErrorLine in LI then
          ImgIndex := 0;
      end else
      begin
        if dlBreakpointLine in LI then
          if not Debugger.DisplayScriptFunction.BreakPointsPrepared then
            ImgIndex := 3
          else
            ImgIndex := 4
        else
          ImgIndex := -1;
      end;
      if ImgIndex >= 0 then
        Images.Draw(ACanvas, X, Y, ImgIndex);
      if dlErrorLine in LI then
      begin

      end;
      Inc(FirstLine);
      Inc(Y, LH);
    end;
  end;
end;

procedure TDebugSupportPlugin.LinesDeleted(FirstLine, Count: integer);
var
  I: Integer;
begin
  if not Assigned(Debugger) then
    Exit;

  if (Debugger.DisplayDebugLines.Count >= FirstLine + Count - 1) and
    (Debugger.DisplayDebugLines.Count > 0) then
  begin
    for I := FirstLine + Count - 1 downto FirstLine do
      Debugger.DisplayDebugLines.Delete(I);
  end;

  if Debugger.CurrentLine >= FirstLine - 1 then
    Debugger.CurrentLine := Debugger.CurrentLine - Count;
end;

procedure TDebugSupportPlugin.LinesInserted(FirstLine, Count: integer);
var
  I: Integer;
begin
  if not Assigned(Debugger) then
    Exit;

  if Debugger.DisplayDebugLines.Count >= FirstLine then
  begin
    for I := FirstLine - 1 to FirstLine + Count - 2 do
      Debugger.DisplayDebugLines.Insert(I, []);
  end;

  if Debugger.CurrentLine >= FirstLine - 1 then
    Debugger.CurrentLine := Debugger.CurrentLine + Count;
end;

procedure TDebugSupportPlugin.SetImages(const Value: TImageList);
begin
  FImages := Value;
end;

procedure TdlgViewProperty.actOnlySpecEventExecute(Sender: TObject);
begin
  actOnlySpecEvent.Checked := not actOnlySpecEvent.Checked;
  RefreshTree(FComponent, FShowMode, '', True);
end;

procedure TdlgViewProperty.actAutoSaveExecute(Sender: TObject);
begin
  actAutoSave.Checked := not actAutoSave.Checked;
end;

procedure TdlgViewProperty.actEvaluateExecute(Sender: TObject);
var
  Text: String;
  I: Integer;
begin
  if not Assigned(FEvaluate) then
    FEvaluate := TdlgEvaluate.Create(Self);

  if gsFunctionSynEdit.Focused then
  begin
    if gsFunctionSynEdit.SelAvail then
      Text := gsFunctionSynEdit.SelText
    else
      Text := gsFunctionSynEdit.WordAtCursor;

    for I := Length(Text) downto 1 do
    begin
      if Text[I] in [#10, #13] then
        Text[I] := ' ';
    end;
  end else
    Text := '';
  FEvaluate.cbExpression.Text := Trim(Text);
  FEvaluate.ShowModal;
end;

procedure TdlgViewProperty.gsFunctionSynEditKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  CurrentWord: String;
  PrevWord: String;
  CP: TPoint;
  SQL: TIBSQL;
  TN: TTreeNode;
  Id: Integer;
  Module: string;
begin
{ DONE : Переделать переход по инклуде }
  if (Key = VK_RETURN) and (ssCtrl in Shift) then
  begin
    CP := gsFunctionSynEdit.CaretXY;
    gsFunctionSynEdit.CaretX := gsFunctionSynEdit.PrevWordPos.x;
    gsFunctionSynEdit.CaretX := gsFunctionSynEdit.PrevWordPos.x;
    PrevWord := UpperCase(Trim(System.Copy(gsFunctionSynEdit.Lines[gsFunctionSynEdit.CaretY - 1],
      gsFunctionSynEdit.WordStart.x, gsFunctionSynEdit.WordEnd.x  - gsFunctionSynEdit.WordStart.x)));
    gsFunctionSynEdit.CaretX := gsFunctionSynEdit.NextWordPos.x;
    CurrentWord := UpperCase(Trim(System.Copy(gsFunctionSynEdit.Lines[gsFunctionSynEdit.CaretY - 1],
      gsFunctionSynEdit.WordStart.x - 1, gsFunctionSynEdit.WordEnd.x - gsFunctionSynEdit.WordStart.x + 1)));
    gsFunctionSynEdit.CaretXY := CP;
    if PrevWord = 'INCLUDE' then
    begin
      SQL := TIBSQL.Create(nil);
      try
        Id := 0; Module := '';
        SQL.Transaction := gdcFunction.ReadTransaction;
        SQL.SQl.Text := 'SELECT g.id, g.module FROM gd_function g, rp_additionalfunction a ' +
          'WHERE a.mainfunctionkey = :id and g.id = a.addfunctionkey and Upper(g.name) = :name';
        SQL.Prepare;
        SQL.Params[0].AsInteger := gdcFunction.FieldByName(fnId).AsInteger;
        SQl.Params[1].AsString := CurrentWord;
        SQL.ExecQuery;
        if not SQL.Eof then
        begin
          Id := SQL.Fields[0].AsInteger;
          Module := SQL.Fields[1].AsString;
        end;
        if Id > 0 then
        begin
          TN := FindSFInTree(Id, Module, True);
          SelectNode(TN);
        end;
      finally
        SQl.Free;
      end;
    end;
  end;
end;

procedure TdlgViewProperty.gsFunctionSynEditSpecialLineColors(
  Sender: TObject; Line: Integer; var Special: Boolean; var FG,
  BG: TColor);
var
  LI: TDebuggerLineInfos;
  DebugLines: TDebugLines;
begin
  if not (Assigned(Debugger) and (gsFunctionSynEdit.Highlighter =
    SynVBScriptSyn1))then
    Exit;

  DebugLines := Debugger.DisplayDebugLines;

  if DebugLines.Count >= gsFunctionSynEdit.Lines.Count  then
  begin
    LI := Debugger.GetLineInfos(Line - 1);
    if (Debugger.CurrentLine = Line - 1) and
      IsExecuteScript then
    begin
      Special := TRUE;
      FG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).ExecutionPointAttri.Foreground;
      BG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).ExecutionPointAttri.Background;
    end else
    if dlBreakpointLine in LI then
    begin
      Special := TRUE;
      if (dlExecutableLine in LI) or
        not Debugger.DisplayScriptFunction.BreakPointsPrepared then
      begin
        FG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).EnableBreakPointAttri.Foreground;
        BG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).EnableBreakPointAttri.Background;
      end else
      begin
        FG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).InvalidBreakPointAttri.Foreground;
        BG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).InvalidBreakPointAttri.Background;
      end;
    end;
    if dlErrorLine in LI then
    begin
      Special := TRUE;
      FG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).ErrorLineAttri.Foreground;
      BG := TSynVBScriptSyn(gsFunctionSynEdit.Highlighter).ErrorLineAttri.Background;
    end;
  end;
end;

procedure TdlgViewProperty.gsFunctionSynEditChange(Sender: TObject);
begin
  SetChanged;
end;

procedure TdlgViewProperty.actAddVBClassExecute(Sender: TObject);
var
  Node: TTreeNode;
  ParentFolder: TTreeNode;
  ScrVB: TscrVBClass;

begin
  if not (GetNodeType(tvClasses.Selected) in
    [fpVBClass, fpVBClassGroup]) then
    Exit;

  if SaveChanges then
  begin
    ParentFolder := GetParentFolder(tvClasses.Selected);
    ScrVB := TscrVBClass.Create;

    ScrVB.Name := gdcFunction.GetUniqueName(NEW_VBCLASS, '', OBJ_APPLICATION);
    Node := AddItemNode(ScrVB, ParentFolder);
    Node.Selected := True;
    Assert(GetSelectedNodeType <> fpNone);
    Node.EditText;
    FChanged := True;
  end;

end;

procedure TdlgViewProperty.actDeleteVBClassExecute(Sender: TObject);
begin
  if not IsScriptFunction(tvClasses.Selected) then
    Exit
  else
    if MessageBox(Application.Handle, MSG_YOU_ARE_SURE, MSG_WARNING, MB_OKCANCEL or MB_ICONWARNING or MB_TASKMODAL) = IDOK then
      DeleteScriptFunction(tvClasses.Selected);

  tvClassesChange(tvClasses, tvClasses.Selected);
end;

procedure TdlgViewProperty.actAddVBClassUpdate(Sender: TObject);
begin
  actAddVBClass.Enabled := GetSelectedNodeType in [fpVBClass, fpVBClassGroup];
end;

procedure TdlgViewProperty.actDeleteVBClassUpdate(Sender: TObject);
begin
  actDeleteVBClass.Enabled := GetSelectedNodeType in [fpVBClass];
end;

procedure TdlgViewProperty.actDeleteEventUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (GetselectedNodeType in [fpEvent, fpMethod])
    and (TCustomFunctionItem(tvClasses.Selected.Data).FunctionKey > 0);
end;

procedure TdlgViewProperty.actDeleteEventExecute(Sender: TObject);
begin
  DisableControls;
  DisableChanges;
  try
    try
      if GetSelectedNodeType in [fpEvent, fpMethod] then
      begin
        TCustomFunctionItem(tvClasses.Selected.Data).FunctionKey := 0;
        if GetSelectedNodeType = fpEvent then
          gdcEvent.SaveEvent(tvClasses.Selected.Parent, tvClasses.Selected)
        else
          begin
            SaveMethod(tvClasses.Selected.Parent, tvClasses.Selected);
            MethodControl.ClearMacroCache;
          end;

        if gdcFunction.State = dsInsert then
        begin
          CancelFunction
        end else
        begin
          try
            gdcFunction.Delete;
          except
          end;
        end;

        if TObject(tvClasses.Selected.Data) is TEventItem then
        begin
          AddEventToList(tvClasses.Selected);
          UpdateEventSpec(tvClasses.Selected.Parent, - 1);
          if Assigned(dlg_gsResizer_ObjectInspector) then
            dlg_gsResizer_ObjectInspector.EventSync(TEventItem(tvClasses.Selected.Data).EventObject.ObjectName,
              TEventItem(tvClasses.Selected.Data).Name);
        end else
          UpdateMethodSpec(tvClasses.Selected.Parent, - 1);
      end;
      CommitTrans;

      NoChanges;
    except
      on E: Exception do
      begin
        MessageBox(Application.Handle, MSG_CAN_NOT_DELETE_EVENT,
          MSG_WARNING, MB_OK or MB_ICONWARNING or MB_TASKMODAL);

        RollBackTrans;
      end;
    end;
  finally
    EnableControls;
    EnableChanges;
  end;
  tvClassesChange(tvClasses, tvClasses.Selected);
end;

procedure TdlgViewProperty.actDeleteUnusedMethodsExecute(Sender: TObject);
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ibtrObject;
    ibtrObject.StartTransaction;
    try
      SQL.SQL.Text := 'DELETE FROM gd_function f WHERE f.module = ' +
      '''METHOD'' AND NOT EXISTS (SELECT oe.functionkey FROM ' +
      'evt_objectevent oe WHERE f.id = oe.functionkey)';
      SQL.ExecQuery;
      ibtrObject.Commit;
    except
      ibtrObject.Rollback;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdlgViewProperty.actDeleteUnUsedEventsExecute(Sender: TObject);
var
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ibtrObject;
    ibtrObject.StartTransaction;
    try
      SQL.SQL.Text := 'DELETE FROM gd_function f WHERE f.module = ' +
      '''EVENTS'' AND NOT EXISTS (SELECT oe.functionkey FROM ' +
      'evt_objectevent oe WHERE f.id = oe.functionkey)';
      SQL.ExecQuery;
      ibtrObject.Commit;
    except
      ibtrObject.Rollback;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdlgViewProperty.tvClassesCompare(Sender: TObject; Node1,
  Node2: TTreeNode; Data: Integer; var Compare: Integer);
var
  NT1, NT2: Integer;
begin
  NT1 := Integer(GetNodeType(Node1));
  NT2 := Integer(GetNodeType(Node2));
  Compare := NT1 - NT2;
  if Compare = 0 then
  begin
    if NT1 = Integer(fpScriptFunction) then
    begin
      NT1 := Integer(SFGetType(Node1));
      NT2 := Integer(SFGetType(Node2));
      Compare := NT1 - NT2;
    end;
    if Compare = 0 then
      Compare := CompareText(Node1.Text, Node2.Text);
  end;
end;

procedure TdlgViewProperty.actSaveHistExecute(Sender: TObject);
var
  Note: THistoryNote;
begin
  Note.CarretPos.x := gsFunctionSynEdit.CaretX;
  Note.CarretPos.y := gsFunctionSynEdit.CaretY;
  Note.Node := tvClasses.Selected;
  FHistory.Add(Note);
end;

procedure TdlgViewProperty.gsFunctionSynEditProcessCommand(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
begin
{  if (FErrorLine > - 1) and (Command <> 700) and (Command <> 701) then
  begin
    gsFunctionSynEdit.InvalidateLine(FErrorLine);
    FErrorLine := - 1;
  end;}
end;

function TDebugSupportPlugin.IsExecuteScript: Boolean;
begin
  Result := Assigned(Debugger) and (Debugger.ExecuteScriptFunction.FunctionKey =
    Debugger.DisplayScriptFunction.FunctionKey) and not Debugger.IsStoped;
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
  if Assigned(FErrorListView) and Assigned(Debugger) then
  begin
    for I := 0 to FErrorListView.Items.Count - 1 do
    begin
      if TObject(FErrorListView.Items[I].Data) is TErrorMessageItem then
      begin
        if (Debugger.DisplayScriptFunction.FunctionKey =
          TErrorMessageItem(FErrorListView.Items[I].Data).FunctionKey) then
        begin
          if TErrorMessageItem(FErrorListView.Items[I].Data).Line >=
            FirstLine + 1 then
          begin
            if TErrorMessageItem(FErrorListView.Items[I].Data).Line >
              FirstLine + Count + 1 then
              TErrorMessageItem(FErrorListView.Items[I].Data).Line :=
                Integer(FErrorListView.Items[I].Data) - Count
            else
              TErrorMessageItem(FErrorListView.Items[I].Data).Line := - 1;
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
  if Assigned(FErrorListView) and Assigned(Debugger) then
  begin
    for I := 0 to FErrorListView.Items.Count - 1 do
    begin
      if TObject(FErrorListView.Items[I].Data) is TErrorMessageItem then
      begin
        if (Debugger.DisplayScriptFunction.FunctionKey =
          TErrorMessageItem(FErrorListView.Items[I].Data).FunctionKey) then
        begin
          if TErrorMessageItem(FErrorListView.Items[I].Data).Line =
            FirstLine - 1 then
            TErrorMessageItem(FErrorListView.Items[I].Data).Line := - 1
          else
            if TErrorMessageItem(FErrorListView.Items[I].Data).Line >
              FirstLine - 1 then
              TErrorMessageItem(FErrorListView.Items[I].Data).Line :=
                Integer(FErrorListView.Items[I].Data) + Count;
        end;
      end;
    end;
  end;
end;

procedure TErrorListSuppurtPlugin.SetErrorListView(const Value: TListView);
begin
  FErrorListView := Value;
end;

procedure TdlgViewProperty.actCompileUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := GetSelectedNodeType in
    [fpMacros, fpEvent, fpMethod, fpReportFunction,
    fpScriptFunction, fpVBClass];
end;

procedure TdlgViewProperty.actSettingsExecute(Sender: TObject);
var
  S: TdlgPropertySettings;
  UseDebugInfo: Boolean;
begin
  UseDebugInfo := PropertySettings.DebugSet.UseDebugInfo;
  S := TdlgPropertySettings.Create(Application);
  try
    if S.ShowModal = mrOk then
    begin
      if not FSingleFunction then
        RefreshTree(FComponent, FShowMode, '', True);

      if UseDebugInfo <> PropertySettings.DebugSet.UseDebugInfo and
        Assigned(glbFunctionList) then
      begin
        glbFunctionList.Clear;

        if Assigned(dm_i_ClientReport) then
        begin
          dm_i_ClientReport.CreateVBConst;
          dm_i_ClientReport.CreateVBClasses;
          dm_i_ClientReport.CreateGlObjArray;
        end;
        if Assigned(ScriptFactory) then
          ScriptFactory.Reset;
      end;
//      if PropertySettings.DebugSet.UseDebugInfo then
//        SetCaption
//      else
//        SetCaption(dsStopped);
    end;
  finally
    S.Free;
  end;
end;

procedure TdlgViewProperty.actAddItemUpdate(Sender: TObject);
var
  NT: TFunctionPages;
begin
  NT := GetSelectedNodeType;
  with Sender as TAction do
  begin
    case NT of
      fpMacros, fpMacrosFolder:
      begin
        if ImageIndex <> 13 then ImageIndex := 13;
        Caption := 'Создать макрос';
      end;
      fpReport, fpReportFolder:
      begin
        if ImageIndex <> 15 then ImageIndex := 15;
        Caption := 'Создать отчет';
      end;
      fpVBClass, fpVBClassGroup:
      begin
        if ImageIndex <> 26 then ImageIndex := 26;
        Caption := 'Создать класс';
      end;
      fpScriptFunction, fpScriptFunctionGroup:
      begin
        if ImageIndex <> 21 then ImageIndex := 21;
        Caption := 'Создать скрипт-функцию';
      end;
      fpConst, fpConstGroup:
      begin
        if ImageIndex <> 21 then ImageIndex := 21;
        Caption := actAddConst.Caption;
      end;
      fpGlobalObject, fpGlobalObjectGroup:
      begin
        if ImageIndex <> 21 then ImageIndex := 21;
        Caption := actAddGlobalObject.Caption;
      end;
    end;
    Enabled := NT in [fpMacros, fpReport, fpVBClass, fpScriptFunction,
      fpMacrosFolder, fpReportFolder, fpVBClassGroup, fpScriptFunctionGroup,
      fpConst, fpConstGroup, fpGlobalObject, fpGlobalObjectGroup];
  end;
end;

procedure TdlgViewProperty.actAddItemExecute(Sender: TObject);
var
  NT: TFunctionPages;
begin
  NT := GetSelectedNodeType;
  case NT of
    fpMacros, fpMacrosFolder: actAddMacrosExecute(Sender);
    fpReport, fpReportFolder: actAddReportExecute(Sender);
    fpVBClass, fpVBClassGroup: actAddVBClassExecute(Sender);
    fpScriptFunction, fpScriptFunctionGroup: actAddScriptFunctionExecute(Sender);
    fpConst, fpConstGroup: actAddConstExecute(Sender);
    fpGlobalObject, fpGlobalObjectGroup: actAddGlobalObjectExecute(Sender);
  end;
end;

procedure TdlgViewProperty.actDeleteItemUpdate(Sender: TObject);
var
  NT: TFunctionPages;
begin
  NT := GetSelectedNodeType;
  with Sender as TAction do
  begin
    case NT of
      fpMacros:
      begin
        if ImageIndex <> 14 then
        begin
          ImageIndex := 14;
          Caption := 'Удалить макрос';
        end;
      end;
      fpReport:
      begin
        if ImageIndex <> 16 then
        begin
          ImageIndex := 16;
          Caption := 'Удалить отчет';
        end;
      end;
      fpVBClass:
      begin
        if ImageIndex <> 27 then
        begin
          ImageIndex := 27;
          Caption := 'Удалить класс';
        end;
      end;
      fpScriptFunction:
      begin
        if ImageIndex <> 22 then
        begin
          ImageIndex := 22;
          Caption := 'Удалить скрипт-функцию';
        end;
      end;
      fpEvent:
      begin
        if ImageIndex <> 28 then
        begin
          ImageIndex := 28;
          Caption := 'Удалить событие';
        end;
      end;
      fpMethod:
      begin
        if ImageIndex <> 29 then
        begin
          ImageIndex := 29;
          Caption := 'Удалить метод';
        end;
      end;
      fpConst:
      begin
        if ImageIndex <> 22 then
        begin
          ImageIndex := 22;
          Caption := 'Удалить описание констант';
        end;
      end;
      fpGlobalObject:
      begin
        if ImageIndex <> 22 then
        begin
          ImageIndex := 22;
          Caption := 'Удалить глобальный объект';
        end;
      end;
      fpReportFunction:
      begin
        if ImageIndex <> 36 then
        begin
          ImageIndex := 36;
          Caption := 'Удалить функцию отчета';
        end;
      end;
    end;
    Enabled := NT in [fpMacros, fpReport, fpVBClass, fpScriptFunction,
      fpEvent, fpMethod, fpConst, fpGlobalObject, fpReportFunction];
  end;
end;

procedure TdlgViewProperty.actDeleteItemExecute(Sender: TObject);
var
  NT: TFunctionPages;
begin
  NT := GetSelectedNodeType;
  case NT of
    fpMacros: actDeleteMacrosExecute(Sender);
    fpReport: actDeleteReportExecute(Sender);
    fpScriptFunction, fpVBClass, fpConst, fpGlobalObject:
      actDeleteScriptFunctionExecute(Sender);
    fpEvent, fpMethod: actDeleteEventExecute(Sender);
    fpReportFunction: actDeleteReportFunctionExecute(Sender);
  end;
end;

procedure TdlgViewProperty.actAddConstExecute(Sender: TObject);
var
  Node: TTreeNode;
  Scr: TscrConst;
begin
  if not (GetNodeType(tvClasses.Selected) in
    [fpConst, fpConstGroup]) then
    Exit;

  if SaveChanges then
  begin
    Scr := TscrConst.Create;
    Scr.Name := gdcFunction.GetUniqueName(NEW_CONST, '', OBJ_APPLICATION);

    Node := AddItemNode(Scr, FConstRootNode);
    Node.Selected := True;
    Assert(GetSelectedNodeType <> fpNone);
    Node.EditText;
    FChanged := True;
  end;
end;

procedure TdlgViewProperty.actAddGlobalObjectExecute(Sender: TObject);
var
  Node: TTreeNode;
  Scr: TscrGlobalObject;
begin
  if not (GetNodeType(tvClasses.Selected) in
    [fpGlobalObject, fpGlobalObjectGroup]) then
    Exit;

  if SaveChanges then
  begin
    Scr := TscrGlobalObject.Create;
    Scr.Name := gdcFunction.GetUniqueName(NEW_GlobalObject, '', OBJ_APPLICATION);

    Node := AddItemNode(Scr, FGlobalObjectRootNode);
    Node.Selected := True;
    Assert(GetSelectedNodeType <> fpNone);
    Node.EditText;
    FChanged := True;
  end;
end;

procedure TdlgViewProperty.actPrepareUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (GetSelectedNodeType in
    [fpMacros, fpEvent, fpMethod, fpReportFunction,
    fpScriptFunction, fpVBClass, fpConst, fpGlobalObject]) and
    ((Assigned(Debugger) and (Debugger.IsStoped or Debugger.IsReseted)) or
    not Assigned(Debugger));
end;

procedure TdlgViewProperty.SynCompletionProposalExecute(
  Kind: SynCompletionType; Sender: TObject; var AString: String; x,
  y: Integer; var CanExecute: Boolean);
var
  Str: String;
  Script: TStrings;
  I, P: Integer;
begin
  CanExecute := False;
  if Assigned(VBProposal) then
  begin
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
    TStringList(SynCompletionProposal.ItemList).Sort;
    SynCompletionProposal.InsertList.Clear;
    for I := 0 to SynCompletionProposal.ItemList.Count - 1 do
    begin
      P := Pos('(', SynCompletionProposal.ItemList[I]);
      if P = 0 then
        SynCompletionProposal.InsertList.Add(SynCompletionProposal.ItemList[I])
      else
        SynCompletionProposal.InsertList.Add(
          System.Copy(SynCompletionProposal.ItemList[I], 1, P - 1))
    end;

    CanExecute := SynCompletionProposal.ItemList.Count > 0;
  end;
end;


procedure TdlgViewProperty.gsFunctionSynEditGutterClick(Sender: TObject; X,
  Y, Line: Integer; mark: TSynEditMark);
begin
  ToggleBreakpoint(Line);
end;

procedure TdlgViewProperty.actDebugRunUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(Debugger) and not (Debugger.IsRunning or
    Debugger.IsStep or Debugger.IsStepOver) and
    ((GetSelectedNodeType in [fpMacros, fpReportFunction, fpScriptFunction])
    or Debugger.IsPaused);
end;

procedure TdlgViewProperty.actDebugPauseUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(Debugger) and ((not (Debugger.IsStoped or
    Debugger.IsPaused or Debugger.IsReseted) and (GetSelectedNodeType in
    [fpMacros, fpEvent, fpMethod, fpReportFunction, fpScriptFunction, fpVBClass])) or
    (Debugger.IsRunning or Debugger.IsStep or Debugger.IsStepOver)) and
    (PropertySettings.DebugSet.UseDebugInfo);
end;

procedure TdlgViewProperty.actDebugRunExecute(Sender: TObject);
begin
  if not Assigned(Debugger) then
    Exit;

  if not CheckModefy then
  begin
    if not Debugger.IsPaused then
    begin
        Debugger.Run;
        actCompileExecute(nil);
    end else
      Debugger.Run
  end;
end;

procedure TdlgViewProperty.actDebugStepInExecute(Sender: TObject);
begin
  if not Assigned(Debugger) then
    Exit;

  if not CheckModefy then
  begin
    if not Debugger.IsPaused then
    begin
      Debugger.Step;
      actCompileExecute(nil);
    end else
      Debugger.Step;
  end;    
end;

procedure TdlgViewProperty.actDebugGotoCursorExecute(Sender: TObject);
begin
  if not Assigned(Debugger) then
    Exit;

  if not CheckModefy then
  begin
    if not Debugger.IsPaused then
    begin
      Debugger.GotoToLine(gsFunctionSynEdit.CaretY - 1);
      actCompileExecute(nil);
    end else
      Debugger.GotoToLine(gsFunctionSynEdit.CaretY - 1);
  end;
end;

procedure TdlgViewProperty.actDebugStepOverExecute(Sender: TObject);
begin
  if not Assigned(Debugger) then
    Exit;

  if not CheckModefy then
  begin
    if not Debugger.IsPaused then
    begin
      Debugger.Step;
      actCompileExecute(nil);
    end else
      Debugger.StepOver;
  end;
end;

procedure TdlgViewProperty.actProgramResetExecute(Sender: TObject);
begin
  if Assigned(Debugger) then
    Debugger.Reset;
end;

procedure TdlgViewProperty.actDebugPauseExecute(Sender: TObject);
begin
  if Assigned(Debugger) then
    Debugger.WantPause;
end;

procedure TdlgViewProperty.actProgramResetUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(Debugger) and (not (Debugger.IsStoped or Debugger.IsReseted)) and
    (GetSelectedNodeType in [fpMacros, fpEvent, fpMethod, fpReportFunction,
    fpScriptFunction, fpVBClass]) and
    (PropertySettings.DebugSet.UseDebugInfo);
end;

procedure TdlgViewProperty.actDisableMethodExecute(Sender: TObject);
begin
  if TMethodItem(tvClasses.Selected.Data).Disable then
  begin
    TMethodItem(tvClasses.Selected.Data).Disable := False;
    TCustomMethodClass(tvClasses.Selected.Parent.Data).SpecDisableMethod :=
      TCustomMethodClass(tvClasses.Selected.Parent.Data).SpecDisableMethod - 1;
  end else
  begin
    TMethodItem(tvClasses.Selected.Data).Disable := True;
    TCustomMethodClass(tvClasses.Selected.Parent.Data).SpecDisableMethod :=
      TCustomMethodClass(tvClasses.Selected.Parent.Data).SpecDisableMethod + 1;
  end;
  SetChanged;
end;

procedure TdlgViewProperty.gsFunctionSynEditMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
  if not PtInRect(FMouseRect, Point(X, Y)) then
  begin
    PopupEval.Deactivate;
    FMouseRect.TopLeft := gsFunctionSynEdit.ClientRect.TopLeft;
    FMouseRect.BottomRight := gsFunctionSynEdit.ClientRect.BottomRight;
  end;
end;

procedure TdlgViewProperty.TimerTimer(Sender: TObject);
var
  p: TPoint;
  RowColumn: TPoint;
  Str, Eval: String;
  BeginPos, EndPos: Integer;
begin
  if Assigned(Debugger) and (Debugger.IsPaused) then
  begin
    P := gsFunctionSynEdit.ScreenToClient(Mouse.CursorPos);
    if (P.x > gsFunctionSynEdit.Gutter.Width) and (P.y > 0) and
      (P.X < gsFunctionSynEdit.Width) and (P.Y < gsFunctionSynEdit.Height) then
    begin
      if gsFunctionSynEdit.SelAvail then
      begin

      end else
      begin
        RowColumn := gsFunctionSynEdit.PixelsToRowColumn(P);
        Str := gsFunctionSynEdit.Lines[RowColumn.y - 1];
        Str := Trim(GetCompliteStatament(Str, RowColumn.X - 1, BeginPos, EndPos));

        FMouseRect.TopLeft := gsFunctionSynEdit.RowColumnToPixels(Point(BeginPos,
           RowColumn.Y));
        FMouseRect.BottomRight := gsFunctionSynEdit.RowColumnToPixels(Point(EndPos,
           RowColumn.Y + 1));

        P := gsFunctionSynEdit.RowColumnToPixels(Point(BeginPos,
          RowColumn.Y + 1));
        P := gsFunctionSynEdit.ClientToScreen(P);

        Str := GetCompliteStatament(Str, 1, BeginPos, EndPos);

        if Str <> '' then
        begin
          Eval := Debugger.Eval(Str, False);
          if Eval <> '' then
            PopupEval.ExecuteEx(Format('%s = %s ', [Str, Eval]),
               P.X, P.Y, PopupEval.DefaultType);
        end
      end;
    end;
  end;
  Timer.Enabled := False;
end;

procedure TdlgViewProperty.actSpeedReturnExecute(Sender: TObject);
var
  R: TRect;
begin
  with TBToolbar3 do
  begin
    R := View.Find(biSpeedReturn).BoundsRect;
    R.TopLeft := ClientToScreen(R.TopLeft);
    R.BottomRight := ClientToScreen(R.BottomRight);
  end;
  pmSpeedReturn.Popup(R.Left, R.Bottom);
end;

procedure TdlgViewProperty.lvErrorMessageDeletion(Sender: TObject;
  Item: TListItem);
begin
  if Assigned(Item.Data) then
    TObject(Item.Data).Free;
end;

{ TCrossingSaver }

{$IFDEF DEBUG}
constructor TCrossingSaver.Create;
begin
  inherited;
  Inc(CrossingCount);
end;

destructor TCrossingSaver.Destroy;
begin
  inherited;
  Dec(CrossingCount);
end;
{$ENDIF}

procedure TdlgViewProperty.FindInTreeDialogFind(Sender: TObject);
var
  I: Integer;
  FindText, SearchText: String;
  P: Integer;
  SM: TSearchMessageItem;
  Add: Integer;
  SQL: TIBSQL;
  LI: TListItem;
  Strings: TStrings;
  Str: String;


  function AddLI(Caption: string; Node: TTreeNode; Line,
    Column: Integer): TListItem;
  begin
    Result := lvMessages.Items.Add;
    Result.Caption := Caption;
    SM := TSearchMessageItem.Create;
    Result.Data := SM;
    SM.Node := Node;
    SM.Line := Line;
    SM.Column := Column;
  end;

begin
  ShowAllRoot;

  lvMessages.Items.BeginUpdate;
  ClearSearchResult;

  SearchText := AnsiUpperCase(FindInTreeDialog.FindText);

  Add := 0;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ibtrObject;
    SQL.SQL.Text := 'SELECT ' + fnScript + ', ' + fnName + ', ' + fnId + ', ' + fnModule + ' FROM gd_function WHERE script' +
      ' CONTAINING ''' + SearchText + '''';
    ibtrObject.StartTransaction;
    try
      SQL.ExecQuery;
      if not SQL.Eof then
      begin
        Strings := TStringList.Create;
        try
          while not SQL.Eof do
          begin
            Strings.Text := SQL.FieldByName(fnScript).AsString;
            for I := 0 to Strings.Count - 1 do
            begin
              Str := AnsiUpperCase(Strings[I]);
              P := System.Pos(SearchText, Str);
              if P > 0 then
              begin
                Str := Strings[I];
                System.Insert(#9, Str, P + Length(SearchText));
                System.Insert(#9, Str, P);
                LI := AddLI(SQL.FieldByName(fnName).AsString + ': ' + Str,
                  nil, I + 1, P);
                TSearchMessageItem(LI.Data).FunctionKey := SQL.FieldByName(fnId).AsInteger;
                TSearchMessageItem(LI.Data).Module := SQL.FieldByName(fnModule).AsString;
                Inc(Add);
              end;
            end;
            SQL.Next;
          end;
        finally
          Strings.Free;
        end;
      end;
    finally
//      ibtrObject.Rollback;
      ibtrObject.Commit; // Для сервера лучше так.
    end;
  finally
    SQL.Free;
  end;

  for I := 0 to tvClasses.Items.Count -1 do
  begin
    P := System.Pos(SearchText, AnsiUpperCase(tvClasses.Items[I].Text));
    if P > 0 then
    begin
      FindText := tvClasses.Items[I].Text;
      System.Insert(#9, FindText, P + Length(SearchText));
      System.Insert(#9, FindText, P);
      FindText := GetPath(tvClasses.Items[I]) + '\' + FindText;

      LI := AddLI(FindText, tvClasses.Items[I], -1, -1);
      case GetNodeType(tvClasses.Items[I]) of
        fpScriptFunction:
        begin
          TSearchMessageItem(LI.Data).FunctionKey := TscrScriptFunction(tvClasses.Items[I].data).Id;
          TSearchMessageItem(LI.Data).Module := TscrScriptFunction(tvClasses.Items[I].data).Module;
        end;
        fpReportFunction:
        begin
          TSearchMessageItem(LI.Data).FunctionKey := TscrReportFunction(tvClasses.Items[I].data).Id;
          TSearchMessageItem(LI.Data).Module := TscrReportFunction(tvClasses.Items[I].data).ModuleName;
        end;
        fpEvent:
        begin
          TSearchMessageItem(LI.Data).FunctionKey := TEventItem(tvClasses.Items[I].data).FunctionKey;
          TSearchMessageItem(LI.Data).Module := scrEventModuleName;
        end;
        fpMethod:
        begin
          TSearchMessageItem(LI.Data).FunctionKey := TMethodItem(tvClasses.Items[I].data).FunctionKey;
          TSearchMessageItem(LI.Data).Module := scrMethodModuleName;
        end;
      end;
      Inc(Add);
    end
  end;

  if Add = 0 then AddLI(#9'Поиск не дал результатов'#9, nil, -1, -1);

  twMessages.Visible := True;

  lvMessages.Items.EndUpdate;
end;

procedure TdlgViewProperty.lvMessagesDeletion(Sender: TObject;
  Item: TListItem);
begin
  if Assigned(Item) and Assigned(Item.Data) then
    TObject(Item.Data).Free;
end;

procedure TdlgViewProperty.lvMessagesCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  Str1, Str2: String;
  P: Integer;
  Rect: TRect;
begin
  if Assigned(Item.Data) and (TObject(Item.Data) is TCustomMessageItem) then
  begin
    Str1 := Item.Caption;
    P := System.Pos(#9, Str1);
    Sender.Canvas.Lock;
    try
      if (cdsFocused in State) or (cdsMarked in State) then
      begin
        Sender.Canvas.Font.Color := clHighlightText;
        Sender.Canvas.Brush.Color := clHighlight;
      end else
      begin
        Sender.Canvas.Font.Color :=  clWindowText;
        Sender.Canvas.Brush.Color := clWindow;
      end;

      Rect := Sender.ClientRect;
      Rect.Top := Item.Top;
      Rect.Bottom := Rect.Top + Sender.Canvas.TextHeight(Str1);
      { TODO :
      Непонятно почему но изменения свойств шрифта не действуют
      после функций TextOut, TextHeight }
      Sender.Canvas.FillRect(Rect);

      Sender.Canvas.MoveTo(Item.Left, Item.Top);
      if P > 0 then
      begin
        Sender.Canvas.Font.Style := [fsBold];
        Str2 :=  System.Copy(Str1, 1, P - 1);
        Sender.Canvas.TextOut(Sender.Canvas.PenPos.X, Sender.Canvas.PenPos.Y, Str2);
        System.Delete(Str1, 1, P);
        P := System.Pos(#9, Str1);
        Str2 := System.Copy(Str1, 1, P - 1);
        Sender.Canvas.Font.Style := [fsBold];
        //Это необходимо чтобы изменения шрифра вступили в силу
        SelectObject(Sender.Canvas.Handle,  Sender.Canvas.Font.Handle);
        Sender.Canvas.TextOut(Sender.Canvas.PenPos.X, Sender.Canvas.PenPos.Y, Str2);
        Sender.Canvas.Font.Style := [];
        //Это необходимо чтобы изменения шрифра вступили в силу
        SelectObject(Sender.Canvas.Handle,  Sender.Canvas.Font.Handle);
        System.Delete(Str1, 1, P);
        Sender.Canvas.TextOut(Sender.Canvas.PenPos.X, Sender.Canvas.PenPos.Y, Str1);
      end else
        Sender.Canvas.TextOut(Sender.Canvas.PenPos.X, Sender.Canvas.PenPos.Y, Str1);
      DefaultDraw := False;
    finally
      Sender.Canvas.Unlock;
    end;
  end else
    DefaultDraw := True;
end;

procedure TdlgViewProperty.sbCommentDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  W: Integer;
  L: Integer;
  C: Integer;
  Str: string;
  Index: Integer;
begin
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

procedure TdlgViewProperty.actToggleBreakpointExecute(Sender: TObject);
begin
  ToggleBreakpoint(gsFunctionSynEdit.CaretY);
end;

procedure TdlgViewProperty.gsFunctionSynEditPlaceBookmark(Sender: TObject;
  var Mark: TSynEditMark);
begin
  FFunctionNeadSave := True;
end;

procedure TdlgViewProperty.gsFunctionSynEditCommandProcessed(
  Sender: TObject; var Command: TSynEditorCommand; var AChar: Char;
  Data: Pointer);
begin
  case Command of
    ecLeft .. ecGotoXY, ecSelLeft..ecSelGotoXY, ecGotoMarker0..ecGotoMarker9,
    ecDeleteLastChar..ecString:
    begin
      { DONE :
      При наборе текста информ. о положении курсора не
      изменяется }
      FFunctionNeadSave := True;
      sbFuncEdit.Panels[1].Text := 'X: ' + IntToStr(gsFunctionSynEdit.CaretX) +
       ';   Y: ' + IntToStr(gsFunctionSynEdit.CaretY) + ';';
    end;
    ecFind: actFindExecute(nil);
    ecReplace: actReplaceExecute(nil);
  end;
end;

procedure TdlgViewProperty.tvClassesDblClick(Sender: TObject);
var
  Item: TTBItem;
  NT: TFunctionPages;
  CS: TCrossingSaver;
begin
  NT := GetSelectedNodeType;
  if NT in [fpMacros, fpEvent, fpMethod, fpScriptFunction, fpReportFunction] then
  begin
    Item := TTBItem.Create(tbSpeedBottons);
    Item.Caption := tvClasses.Selected.Text;
    CS := TCrossingSaver.Create;
    Item.Tag := Integer(CS);
    tbSpeedBottons.Items.Add(Item);
  end;
end;

procedure TdlgViewProperty.lvMessagesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  TN: TTreeNode;
  NT: TFunctionPages;

  function FindInTree(TreeNode: TTreeNode): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to tvClasses.Items.Count - 1 do
    begin
      Result := tvClasses.Items[I] = TreeNode;
      if Result then Exit;
    end;
  end;

  function FindSF(FunctionKey: Integer; Module: String): TTreeNode;
  var
    I: Integer;
  begin
    Result := nil;
    if TObject(Item.Data) is TCustomMessageItem then
    begin
      TN := FindSFInTree(TCustomMessageItem(Item.Data).FunctionKey, False);
      if Assigned(TN) then
      begin
        if Assigned(TN.Data) then
        begin
          for I := 0 to TListView(Sender).Items.Count - 1 do
          begin
            if TCustomMessageItem(TListView(Sender).Items[I].Data).FunctionKey =
              FunctionKey then
              TCustomMessageItem(TListView(Sender).Items[I].Data).Node := TN;
          end;
        end;
        TN.Selected := True;
        Assert(GetSelectedNodeType <> fpNone);
        Expand(Tn);
        if TCustomMessageItem(Item.Data).Line > 1 then
        begin
          if TCustomMessageItem(Item.Data) is TSearchMessageItem then
            GoToXY(TSearchMessageItem(Item.Data).Column,
              TSearchMessageItem(Item.Data).Line)
          else
          begin
            pcFunction.ActivePage := tsFuncScript;
            GotoErrorLine(TCustomMessageItem(Item.Data).Line);
          end;
        end;
      end;
    end;
  end;

begin
  if not Selected then  Exit;
  Screen.Cursor := crHourGlass;
  try
    if Assigned(Item) and Assigned(Item.Data) then
    begin
      TN := TCustomMessageItem(Item.Data).Node;
      //Нод мог был удален поэтому проверяем существует ли он
      if (TN <> nil) and FindInTree(TN) then
      begin
        NT := GetNodeType(TN);
        //Для событийб методовб с.ф. возможно изменение id хранимой фуекции
        //проверяем на соответствие Ид
        case NT of
          fpEvent:
          begin
            if TEventItem(TN.Data).FunctionKey <>
              TCustomMessageItem(Item.Data).FunctionKey then
            begin
              FindSF(TCustomMessageItem(Item.Data).FunctionKey,
                TCustomMessageItem(Item.Data).Module);
              Exit;
            end;
          end;
          fpMethod:
          begin
            if TMethodItem(TN.Data).FunctionKey <>
              TCustomMessageItem(Item.Data).FunctionKey then
            begin
              FindSF(TCustomMessageItem(Item.Data).FunctionKey,
                TCustomMessageItem(Item.Data).Module);
              Exit;
            end;
          end;
          fpScriptFunction:
          begin
            if TscrScriptFunction(TN.Data).id <>
              TCustomMessageItem(Item.Data).FunctionKey then
            begin
              FindSF(TCustomMessageItem(Item.Data).FunctionKey,
                TCustomMessageItem(Item.Data).Module);
              Exit;
            end;
          end;
        end;
        //Все нормалино. Переходим
        TN.Selected := True;
        Assert(GetSelectedNodeType <> fpNone);
        if TCustomMessageItem(Item.Data).Line > 1 then
        begin
          if TCustomMessageItem(Item.Data) is TSearchMessageItem then
            GoToXY(TSearchMessageItem(Item.Data).Column,
              TSearchMessageItem(Item.Data).Line)
          else
          begin
            pcFunction.ActivePage := tsFuncScript;
            GoToErrorLine(TCustomMessageItem(Item.Data).Line);
          end;
        end;
        //Раскрываем ветку дерева которой принадлежит нод
        Expand(Tn);
        if Visible and gsFunctionSynEdit.CanFocus then
          gsFunctionSynEdit.SetFocus;
      end else
        FindSF(TCustomMessageItem(Item.Data).FunctionKey,
              TCustomMessageItem(Item.Data).Module);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TdlgViewProperty.actClearSearchResultExecute(Sender: TObject);
begin
  ClearSearchResult;
end;

procedure TdlgViewProperty.actClearErrorResultExecute(Sender: TObject);
begin
  ClearErrorResult;
end;

procedure TdlgViewProperty.actFindFunctionExecute(Sender: TObject);
var
  Tn: TTreeNode;
begin
  with TdlgFindFunction.Create(nil) do
  try
    if ShowModal = mrOk then
    begin
      Tn := FindSFInTree(StrToInt(eId.Text));
      if Assigned(Tn) then
      begin
        Expand(Tn);
        Tn.Selected := True;
        Assert(GetSelectedNodeType <> fpNone);
      end;
    end;
  finally
    Free;  
  end;
end;

procedure TdlgViewProperty.actDeleteReportFunctionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (GetSelectedNodeType in [fpReportFunction])
    and (TscrReportFunction(tvClasses.Selected.Data).Id > 0);
end;

procedure TdlgViewProperty.actDeleteReportFunctionExecute(Sender: TObject);
var
  Id: Integer;
  F: Boolean;
begin
  if (GetSelectedNodeType = fpReportFunction) and
    (TscrReportFunction(tvClasses.Selected.Data).FncType <> rfMainFnc) then
  begin
    DisableControls;
    DisableChanges;
    try
      Id := TscrReportFunction(tvClasses.Selected.Data).Id;
      F := False;
      try
        TscrReportFunction(tvClasses.Selected.Data).Id := 0;
        case TscrReportFunction(tvClasses.Selected.Data).FncType of
          rfParamFnc:
            TscrReportItem(tvClasses.Selected.Parent.Data).ParamFormulaKey := 0;
          rfEventFnc:
            TscrReportItem(tvClasses.Selected.Parent.Data).EventFormulaKey := 0;
        end;

        if FCanSaveLoad then
        begin
          PostReport(tvClasses.Selected.Parent);
          F := True;
        end;

        if gdcFunction.State = dsInsert then
        begin
          CancelFunction
        end else
          gdcFunction.Delete;
//        CommitTrans;

        NoChanges;
      except
        if F then  gdcReport.Edit;
        TscrReportFunction(tvClasses.Selected.Data).Id := id;
        case TscrReportFunction(tvClasses.Selected.Data).FncType of
          rfParamFnc:
          begin
            TscrReportItem(tvClasses.Selected.Parent.Data).ParamFormulaKey := Id;
            if F then gdcReport.FieldByName(fnParamFormulaKey).AsInteger := Id;
          end;
          rfEventFnc:
          begin
            TscrReportItem(tvClasses.Selected.Parent.Data).EventFormulaKey := Id;
            if F then gdcReport.FieldByName(fnEventFormulaKey).AsInteger := Id;
          end;
        end;
        if F then gdcReport.Post;
      end;
    finally
      EnableControls;
      EnableChanges;
    end;
    tvClassesChange(tvClasses, tvClasses.Selected);
  end;
end;

procedure TdlgViewProperty.actDebugStepInUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(Debugger) and not (Debugger.IsRunning or
    Debugger.IsStep or Debugger.IsStepOver) and
    ((GetSelectedNodeType in [fpMacros, fpReportFunction, fpScriptFunction])
    or Debugger.IsPaused) and (PropertySettings.DebugSet.UseDebugInfo);
end;

procedure TdlgViewProperty.Button1Click(Sender: TObject);
begin
  actFuncCommitExecute(nil);
end;

procedure TdlgViewProperty.actPropertyExecute(Sender: TObject);
begin
  case GetSelectedNodeType of
    fpMacros:
    begin
      EventControl.DisableProperty;
      try
        gdcMacros.EditDialog('Tgdc_dlgObjectProperties');
      finally
        EventControl.EnableProperty;
      end;
    end;
    fpReport:
    begin
      EventControl.DisableProperty;
      try
        gdcReport.EditDialog('Tgdc_dlgObjectProperties');
      finally
        EventControl.EnableProperty;
      end;
    end;
  end;
end;

procedure TdlgViewProperty.actPropertyUpdate(Sender: TObject);
var
  NT: TFunctionPages;
begin
  NT := GetSelectedNodeType;
  TAction(Sender).Enabled := ((NT = fpMacros) and (gdcMacros.State = dsEdit)) or
    ((NT = fpReport) and (gdcReport.State = dsEdit));
end;

procedure TdlgViewProperty.actEditCopyExecute(Sender: TObject);
begin
  gsFunctionSynEdit.CopyToClipboard;
end;

procedure TdlgViewProperty.actEditCutExecute(Sender: TObject);
begin
  gsFunctionSynEdit.CutToClipboard;
end;

procedure TdlgViewProperty.actEditPasteExecute(Sender: TObject);
begin
  gsFunctionSynEdit.PasteFromClipboard;
end;

procedure TdlgViewProperty.FormActivate(Sender: TObject);
begin
  FActive := True;
  SetCaption;
end;

procedure TdlgViewProperty.FormDeactivate(Sender: TObject);
begin
  FActive := False;
  SetCaption(dsStopped);
end;

procedure TdlgViewProperty.Splitter1CanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
  FNewSize := NewSize;
end;

procedure TdlgViewProperty.Splitter1Moved(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to TBDock2.ToolbarCount - 1 do
  begin
    TBDock2.Toolbars[I].Width := FNewSize;
  end;
end;

procedure TdlgViewProperty.TBDock2RequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
var
  D: TTBDock;
begin
  Accept := Bar is TTBToolWindow;
  if Accept then
  begin
    D := TTBDock(Sender);
    if D.Position in [TB2Dock.dpRight, TB2Dock.dpLeft] then
    begin
      if D.ToolbarCount = 0 then
        Bar.Width := ClientWidth div 4
      else
        Bar.Width := D.ClientWidth;
    end else
    begin
      if D.ToolbarCount = 0 then
        Bar.Height := ClientHeight div 4
      else
        Bar.Height := D.ClientHeight;
    end;
  end;
end;

procedure TdlgViewProperty.TBDock1RequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := not (Bar is TTBToolWindow);
end;

procedure TdlgViewProperty.spMessagesCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
begin
  FNewSize := NewSize;
end;

procedure TdlgViewProperty.spMessagesMoved(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to TBDock4.ToolbarCount - 1 do
    TBDock4.Toolbars[I].Height := FNewSize;
end;

procedure TdlgViewProperty.TBDock2Resize(Sender: TObject);
begin
  Splitter1.Left := TBDock2.Width;
  TBDock3.Left := Splitter1.Left + Splitter1.Width;
end;

procedure TdlgViewProperty.TBDock4Resize(Sender: TObject);
begin
  spMessages.Top := TBDock4.Top + spMessages.Height;
  TBDock5.Top := spMessages.Top + TBDock5.Height;
end;

procedure TdlgViewProperty.TBDock6Resize(Sender: TObject);
begin
  Splitter2.Left := TBDock6.Left - Splitter2.Width;
  TBDock7.Left := Splitter2.Left - TBDock7.Width; 
end;

procedure TdlgViewProperty.TBDock2InsertRemoveBar(Sender: TObject;
  Inserting: Boolean; Bar: TTBCustomDockableWindow);
begin
  if Inserting then
  begin
    if not Splitter1.Visible then
      Splitter1.Visible := True;
  end else
  begin
    if TBDock2.ToolbarCount = 0 then
      Splitter1.Visible := False;
  end;
end;

procedure TdlgViewProperty.TBDock6InsertRemoveBar(Sender: TObject;
  Inserting: Boolean; Bar: TTBCustomDockableWindow);
begin
  if Inserting then
  begin
    if not Splitter2.Visible then
      Splitter2.Visible := True;
  end else
  begin
    if TBDock6.ToolbarCount = 0 then
      Splitter2.Visible := False;
  end;
end;

procedure TdlgViewProperty.TBDock4InsertRemoveBar(Sender: TObject;
  Inserting: Boolean; Bar: TTBCustomDockableWindow);
begin
  if Inserting then
  begin
    if not spMessages.Visible then
      spMessages.Visible := True;
  end else
  begin
    if TBDock4.ToolbarCount = 0 then
      spMessages.Visible := False;
  end;
end;

procedure TdlgViewProperty.actShowTreeWindowUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := not tbTree.Visible;
end;

procedure TdlgViewProperty.actShowTreeWindowExecute(Sender: TObject);
begin
  tbTree.Visible := True;
end;

procedure TdlgViewProperty.actShowMessagesWindowUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := not twMessages.Visible;
end;

procedure TdlgViewProperty.lvMessagesClick(Sender: TObject);
begin
//
end;

procedure TdlgViewProperty.actShowMessagesWindowExecute(Sender: TObject);
begin
  twMessages.Visible := True;
end;

procedure TdlgViewProperty.lvMessagesExit(Sender: TObject);
begin
  lvMessages.Selected := nil;
end;

procedure TdlgViewProperty.Splitter2Moved(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to TBDock6.ToolbarCount - 1 do
  begin
    TBDock6.Toolbars[I].Width := FNewSize;
  end;
end;

procedure TdlgViewProperty.TBItem52Click(Sender: TObject);
begin
  with TfrmGedeminProperty.Create(Application) do
    Show;
end;

initialization
  dlgViewProperty := nil;
  RegisterClass(TdlgViewProperty);

finalization
  {$IFDEF DEBUG}
  if CrossingCount > 0 then
    MessageBox(Application.Handle, 'Уничтожены не все CrossingSavers', 'Внимание', mb_Ok or MB_TASKMODAL);
  {$ENDIF}
  UnRegisterClass(TdlgViewProperty);
end.

