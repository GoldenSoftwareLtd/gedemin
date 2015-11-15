
{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
    
--}

unit wiz_FunctionBlock_unit;

interface

uses
  {$IFDEF GEDEMIN}
   gdcClasses_interface, gdcClasses, gdc_frmAnalyticsSel_unit,
   wiz_DocumentInfo_unit, at_classes, gd_createable_form, dmImages_unit,
  {$ENDIF}
  controls, Graphics, Windows, Classes, Messages, Math, Forms, menus, Sysutils,
  wiz_FunctionsParams_unit, IBSQL, gd_common_functions, Dialogs, clipbrd,
  wiz_Strings_unit, BtnEdit, AcctUtils, gdcConstants, ActnList, contnrs;

type
  TBlockSetMember = (bsSimple, bsCycle, bsEntry, bsTax);
  TBlockSet = set of TBlockSetMember;

  TVisualBlockClass = class of TVisualBlock;
  TVisualBlock = class;

  TdlgBaseEditFormClass = class of TdlgBaseEditForm;
  TFrameClass = class of TFrame;

  TdlgBaseEditForm = class(TForm)
  private
    FEditFrame: TFrame;
    procedure SetEditFrame(const Value: TFrame);
  protected
    FBlock: TVisualBlock;
    FActiveEdit: TBtnEdit;
    procedure SetBlock(const Value: TVisualBlock); virtual;
    procedure beClick(Sender: TObject; PopupMenu: TPopupMenu);

    function SetAccount(Account: string; out AccountID: Integer): string;
    function GetAccount(Account: string; AccountId: Integer): string;
  public
    function CheckOk: Boolean; virtual;
    procedure SaveChanges; virtual;
    property Block: TVisualBlock read FBlock write SetBlock;
    property EditFrame: TFrame read FEditFrame write SetEditFrame;
  end;

  TVisualBlock = class(TCustomControl)
  private
    FBlockName: string;
    FUnWrap: Boolean;
    FMouseDelta: TPoint;
    FMousePoint: TPoint;
    FDescription: string;
    FPopupMenu: TPopupMenu;
    FCannotDelete: boolean;
    FStreamVersion: Integer;
    FBeginScriptLine: Integer;
    FEndScriptLine: Integer;
    FEditing: Boolean;
    FReserved: string;
    FLocalName: string;
    FActionList: TActionList;
    FactCopy: TAction;
    FactCut: TAction;
    FactPast: TAction;
    FactSelAll: TAction;
    FDragging: boolean;

    procedure SetBlockName(const Value: string);
    procedure SetUnWrap(const Value: Boolean);

    procedure CMWantSpecialKey(var Msg: TCMWantSpecialKey); message CM_WANTSPECIALKEY;

    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure WMClose(var Message: TWMClose); message WM_CLOSE;

    procedure SetDescription(const Value: string);
    procedure SetCannotDelete(const Value: boolean);
    function GetColor: TColor;
    function GetEditing: Boolean;
    procedure SetReserved(const Value: string);
    procedure SetLocalName(const Value: string);
  protected
    //Указывает можетли блок быь владельцем других блоков
    function CanHasOwnBlock: boolean; virtual;
    //Заголовок блока
    function HeaderPrefix: string; virtual;
    //Подножие блока
    function FotterPrefix: string; virtual;
    function HasFootter: boolean; virtual;
    function HasBody: boolean; virtual;

    //Подножие блока
    function Fotter: string; virtual;

    function SelectColor: TColor; 
    function HeaderColor: TColor; virtual;
    function BodyColor: TColor; virtual;
    function FotterColor: TColor; virtual;

    //Высота заголовка и подножия
    function GetHeaderHeight: integer; virtual;
    function GetHeaderWidth: Integer; virtual;
    function GetFotterHieght: Integer; virtual;
    function GetFotterWidth: Integer; virtual;
    function GetHeaderRect: TRect; virtual;
    function GetFotterRect: TRect; virtual;
    function GetBodyRect: TRect; virtual;
    function GetButtonRect: TRect;

    function ClickInHeader(X, Y: Integer): Boolean;
    function ClickInBody(X, Y: Integer): Boolean;
    function ClickInButton(X, Y: Integer): Boolean;
    procedure Paint; override;

    //Обработка мыши
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    //Пороцедуры драг&дропа
    function CanDrop(Source: TObject; X, Y: Integer): boolean; virtual;
    procedure DragOver(Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure AdjustSize; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;

    function GetEditDialogClass: TdlgBaseEditFormClass; virtual;
    function GetEditDialogForm: TdlgBaseEditForm; virtual;


    procedure ShowErrorMessage; virtual;

    procedure OnPropertyClick(Sender: TObject);
    procedure OnDeleteClick(Sender: TObject);

    class function CheckParent(AParent: TVisualBlock): Boolean; virtual;

    procedure DoSaveToStream(Stream: TStream); virtual;
    procedure DoLoadFromStream(Stream: TStream); virtual;

    function GetNextIndex(ATop: Integer): Integer;
    procedure DoGenerate(S: TStrings; Paragraph: Integer); virtual;
    procedure DoGenerateBeginComment(S: TStrings; Paragraph: Integer); virtual;
    procedure DoGenerateEndComment(S: TStrings; Paragraph: Integer); virtual;
    function DoPaste(Stream: TStream; AOwner: TComponent;
      AParent: TWinControl; ATopPaste: Integer = -1): Integer; virtual;
    procedure ShowException(Msg: string); virtual;

    function GetFrameColor: TColor; virtual;
    procedure SetParent(AParent: TWinControl); override;

    function ObjectStreamVersion: Integer;

    procedure ReserveVars; virtual;
    procedure ReleaseVars; virtual;
    procedure DoReserveVars; virtual;
    procedure DoReleaseVars; virtual;

    function GetBlockSetMember: TBlockSetMember; virtual;
    procedure GetBlockSet(var BS: TBlockSet); virtual;
    function GetCannotDelete: boolean; virtual;

    procedure InsertLine(Count: Integer);
    class function NeedRename: Boolean; virtual;
    class function CanPast_(Stream: TStream; AParent: TVisualBlock): Boolean; virtual;

    procedure OnCopyExecute(Sender: TObject);
    procedure OnCopyUpdate(Sender: TObject);
    procedure OnCutExecute(Sender: TObject);
    procedure OnCutUpdate(Sender: TObject);
    procedure OnPastExecute(Sender: TObject);
    procedure OnPastUpdate(Sender: TObject);

    procedure OnSelectAllExecute(Sender: TObject);
    procedure OnSelectAllUpdate(Sender: TObject);

    procedure CheckActionList; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CanEdit: boolean;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure PopupMenu(X, Y: Integer); virtual;
    procedure DoCreateNew; virtual;
    procedure CreateNew(X, Y: Integer); virtual;
    procedure GetNamesList(const S: TStrings); virtual;
    procedure Generate(S: TStrings; Paragraph: Integer); virtual;
    function CheckName: boolean; virtual;
    procedure Delete;
    //Запись и чтение из потока
    procedure SaveToStream(Stream: TStream); virtual;
    class procedure LoadFromStream(Stream: TStream; AOwner: TComponent;
      AParent: TWinControl; const AFunctionName: String = '';
      const AParentFunctionName: String = ''); virtual;

    function EditDialog: boolean; virtual;

    class function GetUniqueName: string; virtual;
    class function CheckUniqueName(AName: string): boolean;
    class function NamePrefix: string; virtual;
    function GetEditFrame: TFrameClass; virtual;
    //Возвращает тру если функция может быть сохранена
    function CanSave: Boolean; virtual;

    procedure GetVars(const Strings: TStrings); virtual;
    function GetVarScript(const VarName: string): string; virtual;
    function EditExpression(Expression: string; Sender: TVisualBlock): string; virtual;
    //Заголовок блока
    function Header: string;
    function CanCopy: Boolean; virtual;
    function CanCut: Boolean; virtual;
    function CanPast: Boolean; virtual;
    procedure Copy; virtual;
    procedure Cut; virtual;
    procedure Paste; virtual;
    procedure SelectAll; virtual;

    property UnWrap: Boolean read FUnWrap write SetUnWrap;
    property BlockName: string read FBlockName write SetBlockName;
    property Description: string read FDescription write SetDescription;
    property CannotDelete: boolean read GetCannotDelete write SetCannotDelete;
    property BeginScriptLine: Integer read FBeginScriptLine;
    property EndScriptLine: Integer read FEndScriptLine;
    property Color: TColor read GetColor;
    property Editing: Boolean read GetEditing;
    property Reserved: string read FReserved write SetReserved;
    property LocalName: string read FLocalName write SetLocalName;
  end;

  TUserDefinedBlock = class(TVisualBlock)
  private
    FFormName: string;
    FTemplate: string;
    procedure SetFormName(const Value: string);
    procedure SetTemplate(const Value: string);
  public
    property Template: string read FTemplate write SetTemplate;
    property FormName: string read FFormName write SetFormName;
  end;

  TScriptBlock = class;

  TVisualBlockScrollBar = class(TPersistent)
  private
    FControl: TScriptBlock;
    FIncrement: TScrollBarInc;
    FPageIncrement: TScrollbarInc;
    FPosition: Integer;
    FRange: Integer;
    FCalcRange: Integer;
    FKind: TScrollBarKind;
    FMargin: Word;
    FVisible: Boolean;
    FTracking: Boolean;
    FScaled: Boolean;
    FSmooth: Boolean;
    FDelay: Integer;
    FButtonSize: Integer;
    FColor: TColor;
    FParentColor: Boolean;
    FSize: Integer;
    FStyle: TScrollBarStyle;
    FThumbSize: Integer;
    FPageDiv: Integer;
    FLineDiv: Integer;
    FUpdateNeeded: Boolean;

    constructor Create(AControl: TScriptBlock; AKind: TScrollBarKind);
    procedure CalcAutoRange;
    function ControlSize(ControlSB, AssumeSB: Boolean): Integer;
    procedure DoSetRange(Value: Integer);
    function GetScrollPos: Integer;
    function NeedsScrollBarVisible: Boolean;
    function IsIncrementStored: Boolean;
    procedure ScrollMessage(var Msg: TWMScroll);
    procedure SetButtonSize(Value: Integer);
    procedure SetColor(Value: TColor);
    procedure SetParentColor(Value: Boolean);
    procedure SetPosition(Value: Integer);
    procedure SetRange(Value: Integer);
    procedure SetSize(Value: Integer);
    procedure SetStyle(Value: TScrollBarStyle);
    procedure SetThumbSize(Value: Integer);
    procedure SetVisible(Value: Boolean);
    function IsRangeStored: Boolean;
    procedure Update(ControlSB, AssumeSB: Boolean);
  public
    procedure Assign(Source: TPersistent); override;
    procedure ChangeBiDiPosition;
    property Kind: TScrollBarKind read FKind;
    function IsScrollBarVisible: Boolean;
    property ScrollPos: Integer read GetScrollPos;

  published
    property ButtonSize: Integer read FButtonSize write SetButtonSize default 0;
    property Color: TColor read FColor write SetColor default clBtnHighlight;
    property Increment: TScrollBarInc read FIncrement write FIncrement stored IsIncrementStored default 8;
    property Margin: Word read FMargin write FMargin default 0;
    property ParentColor: Boolean read FParentColor write SetParentColor default True;
    property Position: Integer read FPosition write SetPosition default 0;
    property Range: Integer read FRange write SetRange stored IsRangeStored default 0;
    property Smooth: Boolean read FSmooth write FSmooth default False;
    property Size: Integer read FSize write SetSize default 0;
    property Style: TScrollBarStyle read FStyle write SetStyle default ssRegular;
    property ThumbSize: Integer read FThumbSize write SetThumbSize default 0;
    property Tracking: Boolean read FTracking write FTracking default False;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TScriptBlock = class(TVisualBlock)
  private
    FHorzScrollBar: TVisualBlockScrollBar;
    FVertScrollBar: TVisualBlockScrollBar;
    FAutoScroll: Boolean;
    FAutoRangeCount: Integer;
    FUpdatingScrollBars: Boolean;
    procedure CalcAutoRange;
    procedure ScaleScrollBars(M, D: Integer);
    procedure SetAutoScroll(Value: Boolean);
    procedure SetHorzScrollBar(Value: TVisualBlockScrollBar);
    procedure SetVertScrollBar(Value: TVisualBlockScrollBar);
    procedure UpdateScrollBars;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
  protected
    procedure Paint; override;
    procedure DblClick; override;
    function GetClientRect: TRect; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function CanDrop(Source: TObject; X, Y: Integer): boolean; override;
    procedure AdjustSize; override;

    function GetBodyRect: TRect; override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    procedure DoGenerateBeginComment(S: TStrings; Paragraph: Integer); override;
    procedure DoGenerateEndComment(S: TStrings; Paragraph: Integer); override;

    procedure SetParent(AParent: TWinControl); override;

    procedure AdjustClientRect(var Rect: TRect); override;
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    function AutoScrollEnabled: Boolean; virtual;
    procedure AutoScrollInView(AControl: TControl); virtual;
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DoFlipChildren; override;
    property AutoScroll: Boolean read FAutoScroll write SetAutoScroll default True;
    function GetCannotDelete: boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DisableAutoRange;
    procedure EnableAutoRange;
    procedure ScrollInView(AControl: TControl);

    procedure PopupMenu(X, Y: Integer); override;
    procedure CreateNew(X, Y: Integer); override;

    function CanCopy: Boolean; override;

    property HorzScrollBar: TVisualBlockScrollBar read FHorzScrollBar write SetHorzScrollBar;
    property VertScrollBar: TVisualBlockScrollBar read FVertScrollBar write SetVertScrollBar;
  end;

  TFunctionBlockClass = class of TFunctionBlock;
  TFunctionBlock = class(TVisualBlock)
  private
    FReturnResult: Boolean;
    FFunctionParams: TwizParamList;
    FInitScript: string;
    FFinalScript: string;
    FCardOfAccountsRUID: string;
    procedure SetInitScript(const Value: string);
    procedure SetFinalScript(const Value: string);
    procedure SetCardOfAccountsRUID(const Value: string);
  protected
    procedure SetReturnResult(const Value: Boolean); virtual;

    //Заголовок блока
    function HeaderPrefix: string;override;
    //Подножие блока
    function FotterPrefix: string; override;

    function HasFootter: boolean; override;

    procedure ShowErrorMessage; override;

    class function CheckParent(AParent: TVisualBlock): Boolean; override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;
    function GetParamsString: string;
    procedure _DoBeforeGenerate(S: TStrings; Paragraph: Integer); virtual;
    procedure _DoAfterGenerate(S: TStrings; Paragraph: Integer); virtual;
    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    procedure DoGenerateExceptFunction(S: TStrings; Paragraph: Integer); virtual;
    procedure DoGenearteCallExceptFunction(S: TStrings; Paragraph: Integer); virtual;
    procedure DoGenerateEndComment(S: TStrings; Paragraph: Integer); override;
    procedure DoReserveVars; override;
    procedure DoReleaseVars; override;
    function BodyColor: TColor; override;
    function GetEditDialogForm: TdlgBaseEditForm; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetEditFrame: TFrameClass; override;
    function CanCopy: Boolean; override;

    class function NamePrefix: string; override;
    class function GetUniqueName: string; override;
    procedure GetVars(const Strings: TStrings); override;
    procedure InitInitScript; virtual;
    procedure InitFinalScript; virtual;
    function EditExpression(Expression: string; Sender: TVisualBlock): string; override;
    function CanRun: Boolean; virtual;
    function CheckAccount(Account: string; var AccountId: Integer): boolean; virtual;
    //Обравотчик события по выбору фикс. значения счета
    function OnClickAccount(var Account: string; var AccountRUID: string): boolean;

    property ReturnResult: Boolean read FReturnResult write SetReturnResult;
    property FunctionParams: TwizParamList read FFunctionParams;
    property InitScript: string read FInitScript write SetInitScript;
    property FinalScript: string read FFinalScript write SetFinalScript;
    //РУИд плана счетов
    property CardOfAccountsRUID: string read FCardOfAccountsRUID write SetCardOfAccountsRUID;
  end;


  TEntryFunctionBlock = class(TFunctionBlock)
  private
    FTransactionRUID: string;
    FTrRecordRUID: string;
    FNoDeleteLastResults: Boolean;
    procedure SetTransactionRUID(const Value: string);
    procedure SetTrRecordRUID(const Value: string);
    procedure SetNoDeleteLastResults(const Value: Boolean);
  protected
    procedure GenerateGdcClass(S: TStrings; Paragraph: Integer);
    procedure DeleteOldEntry(S: TStrings; Paragraph: Integer);
    procedure _DoBeforeGenerate(S: TStrings; Paragraph: Integer); override;
    procedure _DoAfterGenerate(S: TStrings; Paragraph: Integer); override;

    procedure DoReserveVars; override;
    procedure DoReleaseVars; override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;

    function GetBlockSetMember: TBlockSetMember; override;
  public
    procedure InitInitScript; override;
    procedure InitFinalScript; override;
    function GetEditFrame: TFrameClass; override;

    property TransactionRUID: string read FTransactionRUID write SetTransactionRUID;
    property TrRecordRUID: string read FTrRecordRUID write SetTrRecordRUID;
    property NoDeleteLastResults: Boolean read FNoDeleteLastResults write SetNoDeleteLastResults;
  end;


  TTaxFunctionBlock = class(TEntryFunctionBlock)
  private
    FTaxNameRuid: string;
    FTaxActualRuid: string;
    procedure SetTaxActualRuid(const Value: string);
    procedure SetTaxNameRuid(const Value: string);
  protected
    procedure _DoBeforeGenerate(S: TStrings; Paragraph: Integer); override;
    procedure _DoAfterGenerate(S: TStrings; Paragraph: Integer); override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;

    procedure DoReserveVars; override;
    procedure DoReleaseVars; override;
    function GetBlockSetMember: TBlockSetMember; override;
  public
    procedure InitFinalScript; override;

    property TaxActualRuid: string read FTaxActualRuid write SetTaxActualRuid;
    property TaxNameRuid: string read FTaxNameRuid write SetTaxNameRuid;
  end;

  TDocumentTransactionFunction = class(TFunctionBlock)
  private
    FDocumentTypeRUID: string;
    {$IFDEF GEDEMIN}
    FDocumentHead: TDocumentInfo;
    FDocumentLine: TDocumentLineInfo;
    FDocumentPart: TgdcDocumentClassPart;
    {$ENDIF}

    {$IFDEF GEDEMIN}
    function GetDocumentInfo: TDocumentInfo;
    function GetDocumentLineInfo: TDocumentLineInfo;
    procedure SetDocumentPart(const Value: TgdcDocumentClassPart);
    {$ENDIF}

    procedure SetDocumentTypeRUID(const Value: string);
  protected
    procedure _DoBeforeGenerate(S: TStrings; Paragraph: Integer); override;
    procedure CheckDocumentInfo;
  public
    procedure InitInitScript; override;

    {$IFDEF GEDEMIN}
    function EditExpression(Expression: string; Sender: TVisualBlock): string; override;
    {$ENDIF}

    property DocumentTypeRUID: string read FDocumentTypeRUID write SetDocumentTypeRUID;
    {$IFDEF GEDEMIN}
    property DocumentHead: TDocumentInfo read GetDocumentInfo;
    property DocumentLine: TDocumentLineInfo read GetDocumentLineInfo;
    property DocumentPart: TgdcDocumentClassPart read FDocumentPart write SetDocumentPart;
    {$ENDIF}
  end;

  TTrEntryFunctionBlock = class(TEntryFunctionBlock)
  private
    FDocumentRUID: string;
    {$IFDEF GEDEMIN}
    FDocumentHead: TDocumentInfo;
    FDocumentLine: TDocumentLineInfo;
    FDocumentPart: TgdcDocumentClassPart;
    {$ENDIF}
    FSaveEmpty: Boolean;
    FCheckMasterInsertLine: Integer;

    procedure SetDocumentRUID(const Value: string);
    {$IFDEF GEDEMIN}
    function GetDocumentInfo: TDocumentInfo;
    function GetDocumentLineInfo: TDocumentLineInfo;
    procedure SetDocumentPart(const Value: TgdcDocumentClassPart);
    {$ENDIF}
    procedure SetSaveEmpty(const Value: Boolean);
  protected
    procedure SetReturnResult(const Value: Boolean); override;
    procedure _DoBeforeGenerate(S: TStrings; Paragraph: Integer); override;
    procedure _DoAfterGenerate(S: TStrings; Paragraph: Integer); override;
    procedure DoGenerateExceptFunction(S: TStrings; Paragraph: Integer); override;
    procedure DoGenearteCallExceptFunction(S: TStrings; Paragraph: Integer); override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;
    function GetBlockSetMember: TBlockSetMember; override;

    procedure DoReserveVars; override;
    procedure DoReleaseVars; override;
    procedure CheckDocumentInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure InitFinalScript; override;
    function EditExpression(Expression: string; Sender: TVisualBlock): string; override;
    function CanSave: Boolean; override;
    function CanRun: Boolean; override;
    function CheckAccount(Account: string; var AccountId: Integer): boolean; override;
    procedure GetVars(const Strings: TStrings); override;

    property DocumentRUID: string read FDocumentRUID write SetDocumentRUID;
    {$IFDEF GEDEMIN}
    property DocumentHead: TDocumentInfo read GetDocumentInfo;
    property DocumentLine: TDocumentLineInfo read GetDocumentLineInfo;
    property DocumentPart: TgdcDocumentClassPart read FDocumentPart write SetDocumentPart;
    {$ENDIF}
    property SaveEmpty: Boolean read FSaveEmpty write SetSaveEmpty;
  end;

  TCycleBlock = class(TVisualBlock)
  protected
    //Заголовок блока
    function HeaderPrefix: string;override;
    //Подножие блока
    function FotterPrefix: string; override;

    function HeaderColor: TColor; override;
    function FotterColor: TColor; override;
    procedure DoReserveVars; override;
    procedure DoReleaseVars; override;
    function BodyColor: TColor; override;
    function GetBlockSetMember: TBlockSetMember; override;
    class function NeedRename: Boolean; override;
  public
    class function NamePrefix: string; override;
  end;

  TWhileCycleBlock = class(TCycleBlock)
  private
    FCondition: string;
    procedure SetCondition(const Value: string);
  protected
    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;
  public
    class function NamePrefix: string; override;
    function GetEditFrame: TFrameClass; override;
    property Condition: string read FCondition write SetCondition;
  end;

  TSQLCycleBlock = class(TCycleBlock)
  private
    FFields: string;
    FSQL: string;
    FParams: string;
    procedure SetFields(const Value: string);
    procedure SetParams(const Value: string);
    procedure SetSQL(const Value: string);
  protected
    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;
    function GetEditDialogForm: TdlgBaseEditForm; override;
  public
    class function NamePrefix: string; override;
    function GetEditFrame: TFrameClass; override;
    procedure GetVars(const Strings: TStrings); override;
    function GetVarScript(const VarName: string): string; override;

    property SQL: string read FSQL write SetSQL;
    property Params: string read FParams write SetParams;
    property Fields: string read FFields write SetFields;
  end;

  TSQLBlock = class(TSQLCycleBlock)
  protected
    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    function HasBody: boolean; override;
    function HeaderPrefix: string;override;
    function HeaderColor: TColor; override;
  public
    class function NamePrefix: string; override;
    procedure GetVars(const Strings: TStrings); override;
  end;

  TForCycleBlock = class(TCycleBlock)
  private
    FCondition: string;
    FConditionTo: string;
    FStep: string;
    procedure SetConditionTo(const Value: string);
    procedure SetStep(const Value: string);
    procedure SetCondition(const Value: string);
  protected
    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;
  public
    procedure GetVars(const Strings: TStrings); override;
    function GetEditFrame: TFrameClass; override;
    class function NamePrefix: string; override;
    property Condition: string read FCondition write SetCondition;
    property ConditionTo: string read FConditionTo write SetConditionTo;
    property Step: string read FStep write SetStep;
  end;

  TAccountCycleBlock = class(TCycleBlock)
  private
    FAccount: string;
    FAnalise: string;
    FFilter: string;
    FBeginDate: string;
    FEndDate: string;
    FGroupBy: String;
    FWhere: string;
    FOrder: string;
    FFrom: string;
    FSelect: string;
    procedure SetAccount(const Value: string);

    procedure SetFilter(const Value: string);
    procedure SetBeginDate(const Value: string);
    procedure SetEndDate(const Value: string);
    procedure SetGroupBy(const Value: String);
    procedure SetFrom(const Value: string);
    procedure SetOrder(const Value: string);
    procedure SetSelect(const Value: string);
    procedure SetWhere(const Value: string);

  protected
    procedure SetAnalise(const Value: string); virtual;
    //Заголовок блока
    function HeaderPrefix: string;override;
    //Подножие блока
    function FotterPrefix: string; override;


    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;

    procedure GenerateSQL(S: TStrings; Paragraph: Integer; SQLName: string); virtual;
    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;

    function GetAnalise: string; virtual;
    function GetAccountList(Paragraph: Integer): string;
  public
    class function NamePrefix: string; override;
    function GetEditFrame: TFrameClass; override;

    procedure GetVars(const Strings: TStrings); override;
    function GetVarScript(const VarName: string): string; override;
    property Account: string read FAccount write SetAccount;
    property Analise: string read GetAnalise write SetAnalise;
    property Filter: string read FFilter write SetFilter;
    property BeginDate: string read FBeginDate write SetBeginDate;
    property EndDate: string read FEndDate write SetEndDate;
    property GroupBy: String read FGroupBy write SetGroupBy;

    property Select: string read FSelect write SetSelect;
    property From: string read FFrom write SetFrom;
    property Where: string read FWhere write SetWhere;
    property Order: string read FOrder write SetOrder;
  end;

  TEntryCycleBlock = class(TAccountCycleBlock)
  protected
    //Заголовок блока
    function HeaderPrefix: string;override;

    procedure GenerateSQL(S: TStrings; Paragraph: Integer; SQLName: string); override;
    function GetAnalise: string; override;
    procedure SetAnalise(const Value: string); override;
  public
    function GetEditFrame: TFrameClass; override;

    class function NamePrefix: string; override;
    procedure GetVars(const Strings: TStrings); override;
    function GetVarScript(const VarName: string): string; override;
  end;

  TIfBlock = class(TVisualBlock)
  private
    FCondition: string;
    procedure SetCondition(const Value: string);
  protected
    //Заголовок блока
    function HeaderPrefix: string; override;
    //Подножие блока
    function FotterPrefix: string; override;

    function HeaderColor: TColor; override;
    function FotterColor: TColor; override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;


    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;
    function BodyColor: TColor; override;
  public
    class function NamePrefix: string; override;
    function GetEditFrame: TFrameClass; override;

    property Condition: string read FCondition write SetCondition;
  end;

  TSelectBlock = class(TVisualBlock)
  private
    FCondition: string;
    procedure SetCondition(const Value: string);
  protected
    //Заголовок блока
    function HeaderPrefix: string; override;
    //Подножие блока
    function FotterPrefix: string; override;

    function HeaderColor: TColor; override;
    function FotterColor: TColor; override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;
    function BodyColor: TColor; override;
    function CanDrop(Source: TObject; X, Y: Integer): boolean; override;
  public
    class function NamePrefix: string; override;
    function GetEditFrame: TFrameClass; override;

    property Condition: string read FCondition write SetCondition;
  end;

  TCaseBlock = class(TVisualBlock)
  private
    FCondition: string;
    procedure SetCondition(const Value: string);
  protected
    //Заголовок блока
    function HeaderPrefix: string; override;
    //Подножие блока
    function FotterPrefix: string; override;

    function HeaderColor: TColor; override;
    function FotterColor: TColor; override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;
    function BodyColor: TColor; override;
  public
    class function NamePrefix: string; override;
    class function CheckParent(AParent: TVisualBlock): Boolean; override;
    function GetEditFrame: TFrameClass; override;

    property Condition: string read FCondition write SetCondition;
  end;

  TElseBlock = Class(TVisualBlock)
  protected
    //Заголовок блока
    function HeaderPrefix: string;override;
    function HasFootter: boolean; override;

    function HeaderColor: TColor; override;

    procedure DragOver(Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
    class function CheckParent(AParent: TVisualBlock): Boolean; override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    function BodyColor: TColor; override;
  public

    class function NamePrefix: string; override;
  end;

  TCaseElseBlock = Class(TVisualBlock)
  protected
    //Заголовок блока
    function HeaderPrefix: string;override;
    function HasFootter: boolean; override;
    function HeaderColor: TColor; override;

    procedure DragOver(Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
    class function CheckParent(AParent: TVisualBlock): Boolean; override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    function BodyColor: TColor; override;
  public

    class function NamePrefix: string; override;
  end;

  TVarBlock = class(TVisualBlock)
  private
    FIsobject: Boolean;
    FExpression: string;
    procedure SetExpression(const Value: string);
    procedure SetIsobject(const Value: Boolean);
  protected
    //Указывает можетли блок быь владельцем других блоков
    function CanHasOwnBlock: boolean; override;

    //Заголовок блока
    function HeaderPrefix: string; override;
    function HasFootter: boolean; override;
    function HasBody: boolean; override;

    function HeaderColor: TColor; override;


    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    procedure DoGenerateEndComment(S: TStrings; Paragraph: Integer); override;
    class function NeedRename: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;

    function GetEditFrame: TFrameClass; override;
    class function NamePrefix: string; override;
    procedure GetVars(const Strings: TStrings); override;
    procedure GetNamesList(const S: TStrings); override;

    property Expression: string read FExpression write SetExpression;
    property Isobject: Boolean read FIsobject write SetIsObject;
  end;

  TTaxVarBlock = class(TVarBlock)
  protected
    function HeaderPrefix: string; override;
    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    function HeaderColor: TColor; override;
    function GetBlockSetMember: TBlockSetMember; override;

  public
    function GetEditFrame: TFrameClass; override;
  
    class function NamePrefix: string; override;
  end;

  TEntryBlock = class(TVisualBlock)
  private
    FSumCurr: String;
    FSum: String;
    FCurr: Integer;
    FCredit: string;
    FDebit: string;
    FAnalDebit: string;
    FAnalCredit: string;
    FEntryDate: string;
    FBeginDate: string;
    FEndDate: string;
    FCurrRUID: string;
    FSaveEmpty: boolean;
    FEntryDescription: string;
    FQuantityDebit: string;
    FQuantityCredit: string;
    FSumEq: String;
    procedure SetAnalCredit(const Value: string);
    procedure SetAnalDebit(const Value: string);
    procedure SetCredit(const Value: string);
    procedure SetCurr(const Value: Integer);
    procedure SetDebit(const Value: string);
    procedure SetSum(const Value: string);
    procedure SetSumCurr(const Value: string);
    procedure SetBeginDate(const Value: string);
    procedure SetEndDate(const Value: string);
    procedure SetEntryDate(const Value: string);
    procedure SetCurrRUID(const Value: string);
    procedure SetSaveEmpty(const Value: boolean);
    procedure SetEntryDescription(const Value: string);
    procedure SetQuantityCredit(const Value: string);
    procedure SetQuantityDebit(const Value: string);
    procedure SetSumEq(const Value: String);
  protected
    //Указывает можетли блок быь владельцем других блоков
    function CanHasOwnBlock: boolean; override;

    //Заголовок блока
    function HeaderPrefix: string;override;
    function HasFootter: boolean; override;
    function HasBody: boolean; override;

    function HeaderColor: TColor; override;


    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;

    function GetBlockSetMember: TBlockSetMember; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function NamePrefix: string; override;
    function GetEditFrame: TFrameClass; override;

    property Debit: string read FDebit write SetDebit;
    property Credit: string read FCredit write SetCredit;
    property AnalDebit: string read FAnalDebit write SetAnalDebit;
    property AnalCredit: string read FAnalCredit write SetAnalCredit;
    property Sum: String read FSum write SetSum;
    property Curr: Integer read FCurr write SetCurr;
    property SumCurr: String read FSumCurr write SetSumCurr;
    property SumEQ: String read FSumEq write SetSumEq;
    property BeginDate: string read FBeginDate write SetBeginDate;
    property EndDate: string read FEndDate write SetEndDate;
    property EntryDate: string read FEntryDate write SetEntryDate;
    property CurrRUID: string read FCurrRUID write SetCurrRUID;
    property SaveEmpty: boolean read FSaveEmpty write SetSaveEmpty;
    property EntryDescription: string read FEntryDescription write SetEntryDescription;
    property QuantityDebit: string read FQuantityDebit write SetQuantityDebit;
    property QuantityCredit: string read FQuantityCredit write SetQuantityCredit;
  end;

  TUserBlock = class(TVisualBlock)
  private
    FScript: TStrings;
    procedure SetScript(const Value: TStrings);
  protected
    //Указывает можетли блок быь владельцем других блоков
    function CanHasOwnBlock: boolean; override;

    //Заголовок блока
    function HeaderPrefix: string;override;
    function FotterPrefix: string; override;

    function HasBody: boolean; override;

    function HeaderColor: TColor; override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;
    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;

    procedure DoReserveVars; override;
    procedure DoReleaseVars; override;

    function GetEditDialogForm: TdlgBaseEditForm; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetVars(const Strings: TStrings); override;

    class function NamePrefix: string; override;
    function GetEditFrame: TFrameClass; override;

    property Script: TStrings read FScript write SetScript;
  end;

  TTrEntryBlock = class;

  TTrEntryPositionBlock = class(TVisualBlock)
  private
    FDocumentType: string;
    FAccountPart: string;
    FAnalytics: string;
    FSumCurr: string;
    FQuantity: string;
    FAccount: string;
    FSumNCU: string;
    FCurrRUID: string;
    FSumEQ: string;
    procedure SetAccount(const Value: string);
    procedure SetAccountPart(const Value: string);
    procedure SetAnalytics(const Value: string);
    procedure SetCurrRUID(const Value: string);
    procedure SetDocumentType(const Value: string);
    procedure SetQuantity(const Value: string);
    procedure SetSumCurr(const Value: string);
    procedure SetSumNCU(const Value: string);
    function GetDocumentRUID: string;
    procedure SetSumEQ(const Value: string);

  protected
    function CanHasOwnBlock: boolean; override;

    //Заголовок блока
    function HeaderPrefix: string;override;
    function FotterPrefix: string; override;

    function HasBody: boolean; override;

    function HeaderColor: TColor; override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    function Get: TTrEntryBlock; virtual;
  public
    class function NamePrefix: string; override;
    function GetEditFrame: TFrameClass; override;
    class function CheckParent(AParent: TVisualBlock): Boolean; override;
    function CheckOffBalance(Account: string): boolean;

    property DocumentType: string read FDocumentType write SetDocumentType;
    property Account: string read FAccount write SetAccount;
    property AccountPart: string read FAccountPart write SetAccountPart;
    property SumNCU: string read FSumNCU write SetSumNCU;
    property CurrRUID: string read FCurrRUID write SetCurrRUID;
    property SumCurr: string read FSumCurr write SetSumCurr;
    property SumEQ: string read FSumEQ write SetSumEQ;
    property Analytics: string read FAnalytics write SetAnalytics;
    property Quantity: string read FQuantity write SetQuantity;
    property DocumentRUID: string read GetDocumentRUID ;
    property TrEntry: TTrEntryBlock read Get;
  end;

  TBalanceOffTrEntryPositionBlock = class(TTrEntryPositionBlock)
  private
    FTrEntryBlock: TTrEntryBlock;
    FCompanyRUID: string;
    FEntryDate: string;
    FEntryDescription: String;
    procedure SetCompanyRUID(const Value: string);
    procedure SetEntryDate(const Value: string);
    procedure SetEntryDescription(const Value: String);
  protected
    function Get: TTrEntryBlock; override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
    function HeaderPrefix: string;override;
  public
    destructor Destroy; override;

    function GetEditFrame: TFrameClass; override;
    class function NamePrefix: string; override;
    class function CheckParent(AParent: TVisualBlock): Boolean; override;

    property CompanyRUID: string read FCompanyRUID write SetCompanyRUID;
    property EntryDate: string read FEntryDate write SetEntryDate;
    property EntryDescription: String read FEntryDescription write SetEntryDescription;
  end;

  TTrEntryBlock = class(TVisualBlock)
  private
    FEntryDate: string;
    FCompanyRUID: string;
    FEntryDescription: String;
    FAttributes: string;
    procedure SetCompanyRUID(const Value: string);
    procedure SetEntryDate(const Value: string);
    procedure SetEntryDescription(const Value: String);
    procedure SetAttributes(const Value: string);
  protected
    function CanHasOwnBlock: boolean; override;

    //Заголовок блока
    function HeaderPrefix: string;override;
    function FotterPrefix: string; override;

    function HasBody: boolean; override;

    function HeaderColor: TColor; override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;

    procedure DoReserveVars; override;
    procedure DoReleaseVars; override;
  public
    class function CheckParent(AParent: TVisualBlock): Boolean; override;
    procedure DoCreateNew; override;
    function CanSave: Boolean; override;

    class function NamePrefix: string; override;
    function GetEditFrame: TFrameClass; override;

    property CompanyRUID: string read FCompanyRUID write SetCompanyRUID;
    property EntryDate: string read FEntryDate write SetEntryDate;
    property EntryDescription: String read FEntryDescription write SetEntryDescription;
    property Attributes: string read FAttributes write SetAttributes;
  end;

  TTransactionBlock = class(TVisualBlock)
  private
    FTrasactionRUID: string;
    procedure SetTrasactionRUID(const Value: string);
  protected
    //Указывает можетли блок быь владельцем других блоков
    function CanHasOwnBlock: boolean; override;

    //Заголовок блока
    function HeaderPrefix: string;override;
    function HasFootter: boolean; override;
    function HasBody: boolean; override;

    function HeaderColor: TColor; override;

    procedure DoSaveToStream(Stream: TStream); override;
    procedure DoLoadFromStream(Stream: TStream); override;

    procedure DoGenerate(S: TStrings; Paragraph: Integer); override;
  public

    function GetEditFrame: TFrameClass; override;
    class function NamePrefix: string; override;

    property TransactionRUID: string read FTrasactionRUID write SetTrasactionRUID;
  end;

  TAccountPopupMenu = class(TPopupMenu)
  private
    FOnClickAccount: TNotifyEvent;
    FOnClickAccountCycle: TNotifyEvent;
    FOnClickExpr: TNotifyEvent;
    procedure SetOnClickAccount(const Value: TNotifyEvent);
    procedure SetOnClickAccountCycle(const Value: TNotifyEvent);
    procedure SetOnClickExpr(const Value: TNotifyEvent);
  protected
    procedure DoPopup(Sender: TObject); override;
  public

    property OnClickAccount: TNotifyEvent read FOnClickAccount write SetOnClickAccount;
    property OnClickAccountCycle: TNotifyEvent read FOnClickAccountCycle write SetOnClickAccountCycle;
    property OnClickExpr: TNotifyEvent read FOnClickExpr write SetOnClickExpr;
  end;

  TTrAccountPopupMenu = class(TAccountPopupMenu)
  private
    FOnClickTrDocumentAccount: TNotifyEvent;
    procedure SetOnClickTrDocumentAccount(const Value: TNotifyEvent);
  protected
    procedure DoPopup(Sender: TObject); override;
  public
    property OnClickTrDocumentAccount: TNotifyEvent read FOnClickTrDocumentAccount write SetOnClickTrDocumentAccount;
  end;

  TAnalPopupMenu = class(TPopupMenu)
  private
    FOnClickAnal: TNotifyEvent;
    FOnClickAnalCycle: TNotifyEvent;
    FOnClickCustomAnal: TNotifyEvent;
    FOnExpr: TNotifyEvent;
    procedure SetOnClickAnal(const Value: TNotifyEvent);
    procedure SetOnClickAnalCycle(const Value: TNotifyEvent);
    procedure SetOnClickCustomAnal(const Value: TNotifyEvent);
    procedure SetOnExpr(const Value: TNotifyEvent);
  protected
    procedure DoPopup(Sender: TObject); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Popup(X, Y: Integer); override;

    property OnClickAnal: TNotifyEvent read FOnClickAnal write SetOnClickAnal;
    property OnClickCustomAnal: TNotifyEvent read FOnClickCustomAnal write SetOnClickCustomAnal;
    property OnClickAnalCycle: TNotifyEvent read FOnClickAnalCycle write SetOnClickAnalCycle;
    property OnExpr: TNotifyEvent read FOnExpr write SetOnExpr;
  end;

type
  TLabelStream = array[0..3] of char;

const
  LblSize = SizeOf(TLabelStream);

var
  NeedCreate: TVisualBlockClass;
  MainFunction: TFunctionBlock;
  ReGenerate: Boolean;
  AccountText: string;
  FunctionRUID: string;
  OnBlockSelect, OnBlockUnselect: TNotifyEvent;
  Running: Boolean;
  Modified: Boolean;
const
  cWizLb = 'FWiz';

var
  ClipboardFormat: Word;
  SelBlockList, CopiedBlockList: TObjectList;

const
  ClipboardFormatName: array[0..17] of Char = 'GS_VISUAL_BLOCKS'#00;
  cSaveStreamError = 'Ошибка записи в поток';
  cLoadStreamError = 'Ошибка чтения из потока';
  ClipboardSignature = $5683;

function GenerateExpression(S: String): string;
//сохраняет метку в поток
procedure SaveLabelToStream(lb: TLabelStream; Stream: TStream);
//проверяет метку в потоке
procedure CheckLabel(const Lb: TLabelStream; const Stream: TStream; ErrorMsg: string);

function CheckValidName(Name: string): boolean;

function GetVarName(Prefix: string; Description: string = ' '): string;
procedure ReleaseVarName(Name: string);

function AddVarName(Name: string; Description: string = ' '): string;
//Заполняет список циклов по аналитике
procedure AccountCicleList(const List: TList);
//Заполняет список переменных
procedure VarsList(const Strings: TStrings; VisualBlock: TVisualBlock = nil);
//Заполняет список функций
procedure FunctionList(const List: TList);
function ParentFunction(VB: TVisualBlock): TVisualBlock;

procedure FillAnaliticMenuItem(Menu: TMenu; MenuItem: TMenuItem;
  OnClickAnal, OnClickCustomAnal, OnClickAnalCycle, OnExpr: TNotifyEvent);
procedure FillAccountMenuItem(Menu: TMenu; MenuItem: TMenuItem;
  OnClickAccount: TNotifyEvent = nil; OnClickAccountCycle: TNotifyEvent = nil;
  OnExprClick: TNotifyEvent = nil);


procedure AddAnal(Edit: TBtnEdit; AddedText: string);

implementation

uses
  {$IFDEF GEDEMIN}
  wiz_dlgEditFrom_unit, wiz_dlgVarEditForm_unit, wiz_dlgEntryEditForm_unit,
  wiz_dlgFunctionEditorForm_unit, wiz_dlgUserEditorForm_unit, wiz_dlgAccountCycleForm_unit,
  wiz_dlgIfEditForm_unit,  gdc_frmAccountSel_unit, wiz_dlgTrEntryEditForm_unit,
  wiz_dlgEntryCycleForm_unit, wiz_dlgTaxVarEditForm_unit, wiz_ExpressionEditorForm_unit,
  wiz_dlgTrExpressionEditorForm_unit, wiz_frWhileEditFrame_unit, wiz_frForCycleEditFrame_Unit,
  wiz_FunctionEditFrame_Unit, wiz_TrPosEntryEditFrame_Unit, wiz_frIfEditFrame_Unit,
  wiz_frTaxVarEditFrame_Unit, wiz_frUserEditorFrame_Unit, wiz_frVarEditFrame_unit,
  wiz_frAccountCycleFrame_Unit, wiz_frEntryEditFrame_unit, wiz_frTrEntryEditFrame_Unit,
  wiz_frSelectEditFrame_unit, wiz_frCaseEditFrame_unit, wiz_frDocumentTransactionEditFrame_unit,
  wiz_frSQLCycleEditFrame_unit, wiz_EntryFunctionEditFrame_Unit, wiz_frBalanceOffTrEntry_unit,
  {$ENDIF}
  wiz_Utils_unit, FlatSB, gdcBaseInterface, Commctrl, wiz_dlgEditForm_unit,
  wiz_frEditFrame_unit, gd_directories_const;

const
  cRightSpace = 5;
  cLeftSpace = 10;
  cTextSpace = 5;
  cSpace = 5;

  cGridDelta = 8;

var
  NameList: TStrings;
  IncludeList: TStrings;
  _CheckMaster: Boolean;
  BlockList: TList;

const
  txNameChars =
    'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890_';
  tfVBF = 'VB';
  tfSFF = 'SF';
  tfCFF = 'CF';
  tfGSF = 'GS';
  tfHead = 'H';
  tfLine = 'L';

  txReportFolder = '%s (%s)';


type
  TtxFuncType = (txVB, txSF, txCF, txGS, txUnknown, txHead, txLine);

  TtxFuncDecl = record
    Name: String;
    FuncType: TtxFuncType;
    BPos, EPos: Integer;
  end;

function SaveCopiedToStream(AStr: TStream): boolean;
var
  i: integer;
  sTmp: string;
begin
  Result:= False;
  if not Assigned(CopiedBlockList) then Exit;
  try
    TMemoryStream(AStr).Clear;
    SaveLabelToStream(cWizLb, AStr);
    SaveIntegerToStream(CopiedBlockList.Count, AStr);
    for i:= 0 to CopiedBlockList.Count - 1 do begin
      if not (CopiedBlockList[i] is TMemoryStream) then Exit;
      SaveIntegerToStream(TMemoryStream(CopiedBlockList[i]).Size, AStr);
      AStr.CopyFrom(TMemoryStream(CopiedBlockList[i]), 0);
    end;
    Result:= True;
  finally
    if not Result then begin
      if CopiedBlockList.Count > 1 then
        sTmp:= 'ов'
      else
        sTmp:= 'а';
      raise Exception.Create(Format('Ошибка при копировании блок%s.', [sTmp]));
    end;
  end;
end;

function LoadCopiedFromStream(AStr: TStream): boolean;
var
  i, iSize, iCount: integer;
  msBlock: TMemoryStream;
begin
  Result:= False;
  if not Assigned(CopiedBlockList) then Exit;
  CopiedBlockList.Clear;
  AStr.Position:= 0;
  CheckLabel(cWizLb, AStr, cLoadStreamError);
  iCount:= ReadIntegerFromStream(AStr);
  for i:= 1 to iCount do begin
    msBlock:= TMemoryStream.Create;
    iSize:= ReadIntegerFromStream(AStr);
    msBlock.CopyFrom(AStr, iSize);
    CopiedBlockList.Add(msBlock);
  end;
  Result:= True;
end;

function LoadCopiedFromClipboard: boolean;
var
  H: THandle;
  P: Pointer;
  Stream: TMemoryStream;
  iSize: integer;
begin
  Result:= False;
  ClipboardFormat:= RegisterClipboardFormat(ClipboardFormatName);
  if not OpenClipboard(Application.Handle) then Exit;
  try
    Stream:= TMemoryStream.Create;
    try
      H:= GetClipboardData(ClipboardFormat);
      if H > 0 then begin
        iSize:= GlobalSize(H);
        P:= GlobalLock(H);
        try
          Stream.Size:= iSize;
          CopyMemory(Stream.Memory, P, iSize);
          Result:= LoadCopiedFromStream(Stream);
        finally
          GlobalUnlock(H);
        end;
      end;
    finally
      FreeAndNil(Stream);
    end;
  finally
    CloseClipboard;
  end;
end;

procedure RepaintSelBlockList;
var
  i: integer;
begin
  if not Assigned(SelBlockList) then Exit;
  for i:= 0 to SelBlockList.Count - 1 do begin
    TVisualBlock(SelBlockList[i]).Repaint;
  end;
end;

procedure ClearSelBlockList;
var
  VB: TVisualBlock;
begin
  if not Assigned(SelBlockList) then Exit;
  while SelBlockList.Count > 0 do begin
    VB:= TVisualBlock(SelBlockList[SelBlockList.Count - 1]);
    SelBlockList.Extract(VB);
    VB.FDragging:= False;
    VB.Repaint;
  end;
end;

function SortSelBlockList(Item1, Item2: pointer): integer;
begin
  Result:= TVisualBlock(Item1).Top - TVisualBlock(Item2).Top
end;

procedure AddAnal(Edit: TBtnEdit; AddedText: string);
begin
  Edit.Text := Trim(Edit.Text);
  if Edit.Text > '' then
  begin
    if Edit.Text[Length(Edit.Text)] = ';' then
      Edit.Text := Edit.Text + AddedText
    else
      Edit.Text := Edit.Text + ';' + AddedText;
  end else
    Edit.Text := AddedText;
end;

procedure SaveLabelToStream(lb: TLabelStream; Stream: TStream);
begin
  Stream.WriteBuffer(Lb, LblSize);
end;

procedure CheckLabel(const Lb: TLabelStream; const Stream: TStream; ErrorMsg: string);
var
  LocLb: TLabelStream;
begin
  Stream.ReadBuffer(LocLb, LblSize);
  if LocLb <> Lb then
    raise Exception.Create(ErrorMsg);
end;

function CheckValidName(Name: string): boolean;
var
  I, L: Integer;
begin
  L := Length(Name);
  Result := L > 0;
  if Result then
  begin
    for I := 1 to L - 1 do
    begin
      if not (Name[I] in ['a'..'z', 'A'..'Z', '_', '0'..'9']) then
      begin
        Result := False;
        Break;
      end
    end;
    if Result then
      Result := (Name[1] in ['a'..'z', 'A'..'Z']);
  end;
end;

function GetVarName(Prefix: string; Description: string = ' '): string;
var
  I: Integer;
begin
  I := 0;
  Result := Prefix;
  while NameList.IndexOfName(Result) > -1 do
  begin
    Inc(I);
    Result := Prefix + IntToStr(I);
  end;
  NameList.Add(Result + '=' + Description);
end;

procedure ReleaseVarName(Name: string);
var
  Index: Integer;
begin
  Index := NameList.IndexOfName(Name);
  if Index > - 1 then
    NameList.Delete(Index);
end;

function AddVarName(Name: string; Description: string = ' '): string;
begin
  if NameList.IndexOfName(Name) = -1 then
  begin
    NameList.Add(Name + '=' + Description);
  end;
end;

procedure AccountCicleList(const List: TList);
var
  I: Integer;
begin
  if (List <> nil) and (BlockList <> nil) then
  begin
    for I := 0 to BlockList.Count - 1 do
    begin
      if (TVisualBlock(BlockList[I]) is TAccountCycleBlock) and
         not TVisualBlock(BlockList[I]).Editing then
        List.Add(BlockList[I]);
    end;
  end;
end;

function ParentFunction(VB: TVisualBlock): TVisualBlock;
var
  C: TControl;
begin
  Result := nil;
  C := VB;
  while (C <> nil) and (C is TVisualBlock) and not (C is TFunctionBlock) do
    C := C.Parent;
  if (C <> nil) and (C is TFunctionBlock) then
    Result := TVisualBlock(C);
end;

function CheckParent(VB, ParentVB: TVisualBlock): Boolean;
var
  C: TControl;
begin
  C := VB;
  while (C <> nil) and (C is TVisualBlock) and (C.Parent <> ParentVB) and
    (C <> ParentVB) do
    C := C.Parent;
  Result := (C <> nil) and ((C.Parent = ParentVB) or (C = ParentVB));
end;

procedure VarsList(const Strings: TStrings; VisualBlock: TVisualBlock = nil);
var
  I: Integer;
  PF: TVisualBlock;
begin
  if Strings <> nil then
  begin
    Strings.Clear;
    if VisualBlock = nil then
    begin
      for I := 0 to BlockList.Count - 1 do
        TVisualBlock(BlockList[I]).GetVars(Strings);
    end else
    begin
      PF := ParentFunction(VisualBlock);
      if PF <> nil then
      begin
        for I := 0 to BlockList.Count - 1 do
        begin
          if CheckParent(TVisualBlock(BlockList[i]), PF) then
            TVisualBlock(BlockList[I]).GetVars(Strings);
        end;
      end;
    end;
  end;
end;

procedure FunctionList(const List: TList);
var
  I: Integer;
begin
  if List <> nil then
  begin
    for I := 0 to BlockList.Count - 1 do
    begin
      if TVisualBlock(BlockList[I]) is TFunctionBlock then
        List.Add(BlockList[I]);
    end;
  end;
end;

procedure FillAnaliticMenuItem(Menu: TMenu; MenuItem: TMenuItem;
  OnClickAnal, OnClickCustomAnal, OnClickAnalCycle, OnExpr: TNotifyEvent);
var
  List: TList;
  MI, SI: TMenuItem;
  I, J: Integer;
  AC: TAccountCycleBlock;
  Str: TStrings;
begin
  MenuItem.Clear;

  if Assigned(OnClickAnal) then
  begin
    MI := TMenuItem.Create(Menu);
    MI.Caption := 'Аналитика...';
    MI.OnClick := OnClickAnal;
    MenuItem.Add(MI);
  end;

  if Assigned(OnClickCustomAnal) then
  begin
    MI := TMenuItem.Create(Menu);
    MI.Caption := 'Прочие справочники...';
    MI.OnClick := OnClickCustomAnal;
    MenuItem.Add(MI);
  end;

  if Assigned(OnExpr) then
  begin
    MI := TMenuItem.Create(Menu);
    MI.Caption := 'Выражение...';
    MI.OnClick := OnExpr;
    MenuItem.Add(MI);
  end;

  if Assigned(OnClickAnalCycle) then
  begin
    List := TList.Create;
    try
      AccountCicleList(List);
      if List.Count > 0 then
      begin
        MI := TMenuItem.Create(Menu);
        MI.Caption := '-';
        MenuItem.Add(MI);

        Str := TStringList.Create;
        try
          for i := 0 to List.Count - 1 do
          begin
            AC := TAccountCycleBlock(List[I]);
            MI := TMenuItem.Create(Menu);
            MI.Caption := 'Аналитика цикла ' + Ac.BlockName;
            MenuItem.Add(MI);

            Str.Clear;
            ParseString(Ac.Analise, Str);
            if Str.Count > 0 then
            begin
              for J := 0 to Str.Count - 1 do
              begin
                SI := TMenuItem.Create(Menu);
                SI.Caption := Str[J];
                SI.ONClick := OnClickAnalCycle;
                SI.Tag := Integer(List[I]);
                MI.Add(SI);
              end;
            end else
            begin
              SI := TMenuItem.Create(Menu);
              SI.Caption := 'Пусто';
              SI.Enabled := False;
              MI.Add(SI);
            end;
          end;
        finally
          Str.Free;
        end;
      end;
    finally
      List.Free;
    end;
  end;
end;

procedure FillAccountMenuItem(Menu: TMenu; MenuItem: TMenuItem;
  OnClickAccount: TNotifyEvent = nil; OnClickAccountCycle: TNotifyEvent = nil;
  OnExprClick: TNotifyEvent = nil);
var
  List: TList;
  MI: TMenuItem;
  I: Integer;
  AC: TAccountCycleBlock;
begin
  MenuItem.Clear;

  if Assigned(OnClickAccount) then
  begin
    MI := TMenuItem.Create(Menu);
    MI.Caption := RUS_ACCOUNT;
    MI.OnClick := OnClickAccount;
    MenuItem.Add(MI);
  end;

  if Assigned(OnExprClick) then
  begin
    MI := TMenuItem.Create(Menu);
    MI.Caption := RUS_EXPRESSION;
    MI.OnClick := OnExprClick;
    MenuItem.Add(MI);
  end;

  if Assigned(OnClickAccountCycle) then
  begin
    List := TList.Create;
    try
      AccountCicleList(List);
      if List.Count > 0 then
      begin
        MI := TMenuItem.Create(Menu);
        MI.Caption := '-';
        MenuItem.Add(MI);

        for i := 0 to List.Count - 1 do
        begin
          AC := TAccountCycleBlock(List[I]);
          MI := TMenuItem.Create(Menu);
          MI.Caption := 'Счёт цикла ' + Ac.BlockName;
          MI.Hint := Ac.Description;
          MI.ONClick := OnClickAccountCycle;
          MI.Tag := Integer(List[I]);
          MenuItem.Add(MI);
        end;
      end;
    finally
      List.Free;
    end;
  end;
end;

procedure GetNameAndValue(const S: string; out Name, Value: string);
var
  P: Integer;
  V: string;
  Id: Integer;
const
  cError = 'Неверный формат аналитики';
begin
  Name := ''; Value := '';
  P := Pos('=', S);
  if P > 0 then
  begin
    Name := Trim(Copy(S, 1, P - 1));
    V := Trim(Copy(S, P + 1, Length(S) - P));
    if CheckRUID(V) then
      Value := 'CStr(gdcBaseManager.GetIdByRUIDString("' + V + '"))'
    else
    begin
      try
        id := StrToInt(V);
      except
        id := 0;
      end;
      if id > 0 then
        Value := V
      else
        Value := GenerateExpression(V);
    end
  end else
  begin
    P := Pos('.Account', S);
    if P > 0 then
    begin
      Name := Trim(Copy(S, P + 1, Length(S) - P));
      Value := Format('GS.GetAnalyticValue(%s, "%s")', [Trim(Copy(S, 1, P - 1)), Name]);
    end else
    begin
      P := Pos('.USR$', UpperCase(S));
      if P = 0 then P := Pos('.CREDIT', UpperCase(S));
      if P = 0 then P := Pos('.DEBIT', UpperCase(S));
      if P > 0 then
      begin
        Name := Trim(Copy(S, P + 1, Length(S) - P));
        Value := Format('GS.GetAnalyticValue(%s, "%s")', [Trim(Copy(S, 1, P - 1)), Name]);
      end else
        raise Exception.Create(cError)
    end;
  end;
end;

{ TVisualBlock }

procedure TVisualBlock.AdjustSize;
var
  W, H, nH: Integer;
  I: Integer;
begin
  W := GetHeaderWidth;
  H := GetHeaderHeight;
  if FUnWrap then
  begin
    if HasBody then
    begin
      W := Max(W, GetFotterWidth);
      H := 2 * H;
      for I := 0 to ControlCount - 1 do
      begin
        W := Max(W, Controls[I].Width + Controls[I].Left + cRightSpace);
        nH := Controls[I].Top + Controls[I]. Height + cSpace ;
        if H < nH then
          H := nH;
      end;
    end;
    if HasFootter then
      H := H + GetFotterHieght;
  end;
  SetBounds(Left, Top, W, H);
end;

procedure TVisualBlock.AlignControls(AControl: TControl; var Rect: TRect);
var
  I: Integer;
  L: TList;
  H: Integer;
  R: TRect;

  procedure add(C: TControl);
  var
    I: Integer;
  begin
    if L.Count > 0 then
    begin
      for I := 0 to L.Count - 1 do
      begin
        if C.Top < TControl(L[I]).Top then
        begin
          L.Insert(I, C);
          Exit;
        end;
      end;
      L.Add(C);
    end else
      L.Add(C);
  end;
begin
  L := TList.Create;
  try
    R := GetBodyRect;

    for I := 0 to ControlCount - 1 do
    begin
      Controls[I].Left := R.Left + cLeftSpace;
      Add(Controls[I]);
    end;

    H := cSpace + R.Top;

    for I := 0 to L.Count - 1 do
    begin
      TVisualBlock(L[I]).AdjustSize;
      TControl(L[I]).Top := H;
      H := H + TControl(L[I]).Height + cSpace;
    end;
  finally
    L.Free;
  end;
//  inherited;
  if Showing then AdjustSize;
end;

function TVisualBlock.BodyColor: TColor;
begin
  Result := clWhite;
end;

function TVisualBlock.CanDrop(Source: TObject; X, Y: Integer): boolean;
var
  R: TRect;
  V: TControl;
begin
  Result := CanHasOwnBlock and (Source is TVisualBlock) and (Source <> Self) and
    TVisualBlock(Source).CheckParent(Self) and CanEdit;
  if Result then
  begin
    R := ClientRect;
    Result := PtInRect(R, Point(X, Y));
    if Result then
    begin
      V := Self;
      while V <> nil do
      begin
        if V = Source then
        begin
          Result := False;
          Exit;
        end;
        V := V.Parent;
        Modified := True;
      end;
    end;
  end;
end;


function TVisualBlock.CanHasOwnBlock: boolean;
begin
  Result := HasBody;
end;

function TVisualBlock.CheckName: boolean;
begin
  Result := CheckValidName(FBlockName);
end;

class function TVisualBlock.CheckParent(AParent: TVisualBlock): Boolean;
begin
  Result := not (AParent is TScriptBlock);
end;

function TVisualBlock.ClickInBody(X, Y: Integer): Boolean;
var
  R: TRect;
  P: TPoint;
begin
  R := GetBodyRect;
  P := Point(X, Y);
  Result := PtInRect(R, P);
end;

function TVisualBlock.ClickInHeader(X, Y: Integer): Boolean;
var
  R: TRect;
  P: TPoint;
begin
  R := GetHeaderRect;
  P := Point(X, Y);
  Result := PtInRect(R, P);
end;

constructor TVisualBlock.Create(AOwner: TComponent);
begin
  inherited;
  BlockList.Add(Self);
  ShowHint := True;
end;

procedure TVisualBlock.CreateNew(X, Y: Integer);
var
  V: TVisualBlock;
begin
  if CanHasOwnBlock and (NeedCreate <> nil) and NeedCreate.CheckParent(Self) then
  begin
    V := NeedCreate.Create(Owner);
    V.UnWrap := True;
    V.Left := X;
    V.Top := Y;
    V.Parent := Self;
    V.BlockName := V.GetUniqueName;
    V.DoCreateNew;
    if (V is TVarBlock) and (BlockList.IndexOf(V) > -1) then
      BlockList.Extract(V);
    if not V.EditDialog then
      V.Free
    else
      if (V is TVarBlock) and (BlockList.IndexOf(V) = -1) then
        BlockList.Add(V);
    NeedCreate := nil;
    ReGenerate := True;
  end;
end;

procedure TVisualBlock.DblClick;
var
  P: TPoint;
begin
  inherited;

  P := ScreenToClient(Mouse.CursorPos);
  if ClickInHeader(P.x, P.y) and not ClickInButton(P.X, P.Y) then
  begin
    EditDialog;
  end;
end;

procedure TVisualBlock.DragDrop(Source: TObject; X, Y: Integer);
var
  V: TVisualBlock;
  b: boolean;
  i: integer;
begin
  if not Assigned(SelBlockList) then Exit;
  b:= False;
  for i:= 0 to SelBlockList.Count - 1 do begin
    b:= CanDrop(TVisualBlock(SelBlockList[i]), X, Y);
    if not b then Break;
  end;
  for i:= 0 to SelBlockList.Count - 1 do begin
    if TVisualBlock(SelBlockList[0]).Parent <> Self then
      V := TVisualBlock(SelBlockList[SelBlockList.Count - 1 - i])
    else
      if TVisualBlock(SelBlockList[0]).Top < Y then
        V := TVisualBlock(SelBlockList[i])
      else
        V := TVisualBlock(SelBlockList[SelBlockList.Count - 1 - i]);
    if b then begin
      V.Parent := Self;
      V.SetBounds(X, Y, V.Width, V.Height);
    end;
    V.FDragging:= False;
  end;
  Realign;
end;

procedure TVisualBlock.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  i: integer;
begin
  if not Assigned(SelBlockList) then begin
    Accept:= False;
    Exit;
  end;
  if SelBlockList.Count = 1 then
    Accept := CanDrop(Source, X, Y)
  else
    for i:= 0 to SelBlockList.Count - 1 do begin
      Accept:= CanDrop(TVisualBlock(SelBlockList[i]), X, Y);
      if not Accept then Break;
    end;
end;

function TVisualBlock.EditDialog: boolean;
var
  F: TdlgBaseEditForm;
begin
  Result := False;
  if CanEdit then
  begin
    FEditing := True;
    F := GetEditDialogForm;
    try
      Result := F.ShowModal = mrOk;
      ReGenerate := Result;
      Hint := FDescription;
      Modified := Modified or Result;
    finally
      FEditing := False;
      F.Free;
    end;
  end
end;

function TVisualBlock.FotterPrefix: string;
begin
  Result := '';
end;

function TVisualBlock.FotterColor: TColor;
begin
  Result := HeaderColor;
end;


function TVisualBlock.GetEditDialogClass: TdlgBaseEditFormClass;
begin
  {$IFDEF GEDEMIN}
  Result := TBlockEditForm;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TVisualBlock.GetFotterHieght: Integer;
begin
  Result := Canvas.TextHeight(Fotter) + 2 * cTextSpace;
end;

function TVisualBlock.GetFotterRect: TRect;
begin
  Result := GetClientRect;
  if HasFootter and FUnWrap then
    Result.Top := Result.Bottom - GetFotterHieght
  else
    Result.Bottom := Result.Top;
end;

function TVisualBlock.GetFotterWidth: Integer;
begin
  Result := 0;
  if HasFootter then
  begin
    Result := Canvas.TextWidth('[-] ' + Fotter);
    Result := Result  + cTextSpace * 2;
  end;  
end;

function TVisualBlock.GetHeaderHeight: integer;
begin
  Result := Canvas.TextHeight(Header) + 2 * cTextSpace;
end;

function TVisualBlock.GetHeaderRect: TRect;
begin
  Result := GetClientRect;
  Result.Bottom := Result.Top + GetHeaderHeight;
end;

function TVisualBlock.GetHeaderWidth: Integer;
begin
  if HasBody or HasFootter then
  begin
    Result := GetButtonRect.Right + Canvas.TextWidth(Header);
  end else
    Result := Canvas.TextWidth(Header);
  Result := Result  + cTextSpace * 2;  
end;

function TVisualBlock.HasFootter: boolean;
begin
  Result := False;
end;

function TVisualBlock.HeaderPrefix: string;
begin
  Result := '';
end;

function TVisualBlock.HeaderColor: TColor;
begin
  Result := clLtGray;
end;

procedure TVisualBlock.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  R: TRect;
  P: TPoint;
begin
  inherited;

  if ssLeft in Shift then
  begin
    if Assigned(SelBlockList) and ([ssLeft, ssCtrl] = Shift) then begin
      if SelBlockList.IndexOf(self) > -1 then
      begin
        if SelBlockList.Count > 1 then
          SelBlockList.Extract(self);
      end else
      begin
        if SelBlockList.Count > 0 then
          if TVisualBlock(SelBlockList[0]).Parent <> self.Parent then
            ClearSelBlockList;
        SelBlockList.Add(self);
      end;
    end;
    if [ssLeft] = Shift then begin
      if Assigned(SelBlockList) and (SelBlockList.IndexOf(self) = -1) then
      begin
        ClearSelBlockList;
        CancelDrag;
        SelBlockList.Add(self);
        Repaint;
      end;
      if ClickInButton(X, Y) then
      begin
        FUnWrap := not FUnWrap;
        AdjustSize;
        Repaint;
      end else
      if ClickInHeader(X, Y) then
      begin
        R := GetHeaderRect;
        FMouseDelta.x := R.Left - X;
        FMouseDelta.y := R.Top - Y;
      end;
    end;
  end else
  if [ssRight] = Shift then
  begin
    P := ClientToScreen(Point(X, Y)); 
    PopupMenu(P.X, P.Y);
  end;
  FMousePoint := Point(X, Y);
  if Focused then begin
    Invalidate;
    if Assigned(OnBlockSelect) then
      OnBlockSelect(Self);
  end
  else
    SetFocus;
end;

procedure TVisualBlock.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  i: integer;
begin
  if not Assigned(SelBlockList) then Exit;
  inherited;
  if [ssLeft] = Shift then
  begin
    if (X - FMousePoint.x <> 0) or (Y - FMousePoint.y <> 0) then
    begin
      SelBlockList.Sort(SortSelBlockList);
      for i:= 0 to SelBlockList.Count - 1 do
        TVisualBlock(SelBlockList[i]).FDragging:= True;
      if SelBlockList.Count > 0 then
        TVisualBlock(SelBlockList[0]).BeginDrag(False, 3)
      else
        BeginDrag(False, 3);
    end;
  end;
end;

procedure TVisualBlock.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  if ([] = Shift) and (mbLeft = Button) then
  begin
    if ClickInBody(X, Y) then
    begin
      CreateNew(X, Y);
      CancelDrag;
    end;
  end;
end;

procedure TVisualBlock.OnPropertyClick(Sender: TObject);
begin
  EditDialog;
end;

procedure TVisualBlock.Paint;
var
  R: TRect;
  L: Integer;
  TempColor: TColor;
begin
  if SelBlockList.IndexOf(self) > -1 then
  begin
    TempColor := SelectColor;
    Canvas.Font.Color := clWhite;
  end
  else
  begin
    TempColor := HeaderColor;
    Canvas.Font.Color := clBlack;
  end;

  R := GetClientRect;
  Canvas.Brush.Color := GetFrameColor;
  Canvas.FrameRect(R);

  //Прорисовка заголовка
  R := GetHeaderRect;
  Canvas.Brush.Color := GetFrameColor;
  Canvas.FrameRect(R);
  InflateRect(R, -1, -1);
  Canvas.Brush.Color := TempColor;
  Canvas.FillRect(R);

  //Canvas.Font.Color := clBlack;
  L := 0;
  if HasBody or HasFootter then
  begin
    R := GetButtonRect;
    L := R.Right;
    Canvas.Brush.Color := GetFrameColor;
    Canvas.FrameRect(R);
    Canvas.Brush.Color := TempColor;

    InflateRect(R, -2, -2);
    Canvas.MoveTo(R.Left, R.Top + ((R.Bottom - R.Top) div 2));
    Canvas.LineTo(R.Right, R.Top + ((R.Bottom - R.Top) div 2));
    if not FUnWrap then
    begin
      Canvas.MoveTo(R.Left + ((R.Right - R.Left) div 2), R.Top);
      Canvas.LineTo(R.Left + ((R.Right - R.Left) div 2), R.Bottom);
    end;
  end;

  Canvas.Brush.Color := TempColor;
  Canvas.TextOut(L + cTextSpace, cTextSpace, Header);

  if FUnWrap then
  begin
    if HasBody then
    begin
      //Прописовка тела
      R := GetBodyRect;

      InflateRect(R, -1, 0);
      if not HasFootter then R.Bottom := R.Bottom - 1;
      Canvas.Brush.Color := BodyColor;
      Canvas.FillRect(R);
    end;

    if HasFootter then
    begin
      //Прорисовка подножия
      R := GetFotterRect;
      Canvas.Brush.Color := GetFrameColor;
      Canvas.FrameRect(R);
      InflateRect(R, -1, -1);
      Canvas.Brush.Color := FotterColor;
      Canvas.FillRect(R);
      Canvas.TextOut(cTextSpace, R.Top + cTextSpace, Fotter)
    end;
  end;
end;

procedure TVisualBlock.PopupMenu(X, Y: Integer);
var
  MI: TMenuItem;

  procedure AddMenuItem(Action: TAction);
  begin
    MI := TMenuItem.Create(FPopupMenu);
    MI.Action := Action;
    FPopupMenu.Items.Add(MI);
  end;

  procedure AddDevider;
  begin
    MI := TMenuItem.Create(FPopupMenu);
    MI.Caption := '-';
    FPopupMenu.Items.Add(MI);
  end;
begin
  if FPopupMenu = nil then
  begin
    CheckActionList;
    FPopupMenu := TPopupMenu.Create(Self);
    {$IFDEF GEDEMIN}
    FPopupMenu.Images := dmImages.il16x16;
    {$ENDIF}

    MI := TMenuItem.Create(FPopupMenu);
    MI.Caption := 'Свойства ...';
    MI.OnClick := OnPropertyClick;
    {$IFDEF GEDEMIN}
    MI.ImageIndex := iiProperties;
    {$ENDIF}
    FPopupMenu.Items.Add(MI);

    if not CannotDelete then
    begin
      AddDevider;
      MI := TMenuItem.Create(FPopupMenu);
      MI.Caption := 'Удалить';
      MI.OnClick := OnDeleteClick;
      MI.ShortCut := ShortCut(Ord('D'), [ssCtrl]);
      {$IFDEF GEDEMIN}
      MI.ImageIndex := iiDelete;
      {$ENDIF}
      FPopupMenu.Items.Add(MI);
    end;

    AddDevider;

    AddMenuItem(FactCopy);
    AddMenuItem(FactCut);
    AddMenuItem(FactPast);
    AddMenuItem(FactSelAll);
  end;
  FPopupMenu.Popup(X, Y);
end;

procedure TVisualBlock.SetBlockName(const Value: string);
begin
  FBlockName := Value;
  {$IFDEF GEDEMIN}
  AdjustSize;
  {$ENDIF}
end;

procedure TVisualBlock.SetDescription(const Value: string);
begin
  FDescription := Value;
end;

procedure TVisualBlock.SetUnWrap(const Value: Boolean);
begin
  FUnWrap := Value;
end;

procedure TVisualBlock.ShowErrorMessage;
begin

end;

procedure TVisualBlock.CMWantSpecialKey(var Msg: TCMWantSpecialKey);
begin
  inherited;
  
  if (Msg.CharCode = VK_UP) or (Msg.CharCode = VK_DOWN) then
    Msg.Result := 1;
end;

procedure TVisualBlock.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

destructor TVisualBlock.Destroy;
begin
  BlockList.Extract(Self);
  if Assigned(SelBlockList) and (SelBlockList.IndexOf(Self) > -1) then
    SelBlockList.Extract(Self);

  if MainFunction = Self then
    MainFunction := nil;

  inherited;

  ReGenerate := True;
end;

class function TVisualBlock.CheckUniqueName(AName: string): boolean;
var
  I: Integer;
  N: string;
begin
  Result := True;
  N := UpperCase(AName);
  for I := 0 to BlockList.Count - 1 do
  begin
    if UpperCase(TVisualBlock(BlockList[I]).BlockName) = N then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

class function TVisualBlock.GetUniqueName: string;
var
  I: Integer;
begin
  I := 1;
  Result := NamePrefix + '_' + IntToStr(I);
  while not CheckUniqueName(Result) do
  begin
    Inc(I);
    Result := NamePrefix + '_' + IntToStr(I);
  end;
end;

class function TVisualBlock.NamePrefix: string;
begin
  Result := 'Name';
end;

procedure TVisualBlock.GetNamesList(const S: TStrings);
var
  I, Index: Integer;
begin
  S.Clear;
  for I := 0 to BlockList.Count - 1 do
  begin
    if TVisualBlock(BlockList[I]).ClassType = Self.ClassType then
    begin
      Index := s.IndexOf(TVisualBlock(BlockList[I]).FBlockName);
      if Index = - 1 then
        S.AddObject(TVisualBlock(BlockList[I]).FBlockName, BlockList[I]);
    end;
  end;
end;

procedure TVisualBlock.OndeleteClick(Sender: TObject);
begin
  Delete;
end;

function TVisualBlock.Fotter: string;
begin
  Result := FotterPrefix;
end;

function TVisualBlock.Header: string;
begin
  if FLocalName <> '' then
    Result := FLocalName
  else
    Result := HeaderPrefix + ' ''' + FBlockName + '''';
end;

procedure TVisualBlock.Generate(S: TStrings; Paragraph: Integer);
begin
  FBeginScriptLine := S.Count + 1;
  DoGenerateBeginComment(S, Paragraph);
  try
    DoGenerate(S, Paragraph);
  except
    on E: Exception do
      ShowException(E.Message);
  end;
  DoGenerateEndComment(S, Paragraph);
  FEndScriptLine := S.Count;
end;

class procedure TVisualBlock.LoadFromStream(Stream: TStream; AOwner: TComponent;
  AParent: TWinControl; const AFunctionName: String = '';
  const AParentFunctionName: String = '');
var
  CName: String;
  C: TVisualBlockClass;
  V: TVisualBlock;
  I, LCount: Integer;
begin
  CName := ReadStringFromStream(Stream);
  C := TVisualBlockClass(GetClass(CName));
  Assert(C <> nil, Format('Незарегистрированный класс %s', [CName]));
  if AParent is TVisualBlock then
  begin
    if not (TVisualBlock(AParent).CanHasOwnBlock  and
      C.CheckParent(TVisualBlock(AParent)) and TVisualBlock(AParent).CanEdit) then
      exit;
  end;
  V := C.Create(AOwner);
  V.DoLoadFromStream(Stream);
  V.Parent := AParent;

  if (AFunctionName > '') and (AParentFunctionName > '')
    and (AnsiUpperCase(V.FBlockName) = AnsiUpperCase(AParentFunctionName)) then
  begin
    V.FBlockName := AFunctionName;
  end;

  Stream.ReadBuffer(LCount, SizeOf(LCount));
  for I := 0 to LCount - 1 do
    TVisualBlock.LoadFromStream(Stream, AOwner, V, AFunctionName, AParentFunctionName);
end;

procedure TVisualBlock.SaveToStream(Stream: TStream);
var
  LCount: Integer;
  T, Index: Integer;
begin
  SaveStringToStream(ClassName, Stream);
  DoSaveToStream(Stream);
  LCount := ControlCount;
  Stream.Write(LCount, SizeOf(LCount));

  T := Low(Integer);
  while GetNextIndex(T) > -1 do
  begin
    Index := GetNextIndex(T);
    T := Controls[Index].Top;
    TVisualBlock(Controls[Index]).SaveToStream(Stream);
  end;
end;

procedure TVisualBlock.DoLoadFromStream(Stream: TStream);
var
  L, T, W, H: Integer;

  function CheckUniqueName_(AName: string): boolean;
  var
    I: Integer;
    N: string;
  begin
    Result := True;
    N := UpperCase(AName);
    for I := 0 to BlockList.Count - 1 do
    begin
      if (UpperCase(TVisualBlock(BlockList[I]).BlockName) = N) and
        (Self <> BlockList[I]) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
begin
  Stream.ReadBuffer(FStreamVersion, Sizeof(FStreamVersion));
  FBlockName := ReadStringFromStream(Stream);

  if NeedRename and not CheckUniqueName_(FBlockName) then
  begin
    FBlockName := GetUniqueName;
  end;

  FDescription := ReadStringFromStream(Stream);
  Hint := FDescription;
  Stream.ReadBuffer(FUnWrap, SizeOf(FUnWrap));

  Stream.ReadBuffer(L, Sizeof(L));
  Stream.ReadBuffer(T, SizeOf(T));
  Stream.ReadBuffer(W, sizeOf(W));
  Stream.ReadBuffer(H, SizeOf(H));
  
  SetBounds(L, T, W, H);

  Stream.ReadBuffer(FCannotDelete, SizeOf(FCannotDelete));
  if FStreamVersion > 1 then
  begin
    FReserved := ReadStringFromStream(Stream);
    if FStreamVersion > 3 then
    begin
      FLocalName := ReadStringFromStream(Stream);
    end;
  end;
end;

function TVisualBlock.DoPaste(Stream: TStream; AOwner: TComponent;
      AParent: TWinControl; ATopPaste: Integer = -1): Integer;
var
  CName: String;
  C: TVisualBlockClass;
  V: TVisualBlock;
  I, LCount: Integer;
begin
  Assert(Stream <> nil);

  Result := - 1;
  CName := ReadStringFromStream(Stream);
  C := TVisualBlockClass(GetClass(CName));
  if C = nil then
    raise Exception.CreateFmt('Незарегистрированный класс %s', [CName]);

  if AParent is TVisualBlock then
  begin
    if not (TVisualBlock(AParent).CanHasOwnBlock and
      C.CheckParent(TVisualBlock(AParent)) and TVisualBlock(AParent).CanEdit) then
    begin
      exit;
    end;
  end;

  V := C.Create(AOwner);
  V.DoLoadFromStream(Stream);
  if ATopPaste > - 1 then
    V.SetBounds(V.Left, ATopPaste, V.Width, V.Height);
  V.Parent := AParent;

  Result := V.Top + V.Height;

  Stream.ReadBuffer(LCount, SizeOf(LCount));
  for I := 0 to LCount - 1 do
    DoPaste(Stream, AOwner, V);
end;

procedure TVisualBlock.DoSaveToStream(Stream: TStream);
var
  L, T, W, H: Integer;
  V: Integer;
begin
  V := ObjectStreamVersion;
  Stream.WriteBuffer(V, SizeOf(V));
  SaveStringToStream(FBlockName, Stream);
  SaveStringToStream(FDescription, Stream);
  Stream.WriteBuffer(FUnWrap, SizeOf(FUnWrap));

  L := Left; T := Top; W := Width; H := Height;
  Stream.Write(L, Sizeof(L));
  Stream.Write(T, SizeOf(T));
  Stream.Write(W, sizeOf(W));
  Stream.Write(H, SizeOf(H));

  Stream.Write(FCannotDelete, SizeOf(FCannotDelete));
  SaveStringToStream(FReserved, Stream);
  SaveStringToStream(FLocalName, Stream);
end;

procedure TVisualBlock.SetCannotDelete(const Value: boolean);
begin
  FCannotDelete := Value;
end;

procedure TVisualBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  T, Index: Integer;
begin
  T := Low(Integer);
  while GetNextIndex(T) > -1 do
  begin
    Index := GetNextIndex(T);
    T := Controls[Index].Top;
    TVisualBlock(Controls[Index]).Generate(S, Paragraph);
  end;
end;

procedure TVisualBlock.DoGenerateBeginComment(S: TStrings; Paragraph: Integer);
var
  sl: string;
  I: Integer;
  Str: TStringList;
begin
  Sl := StringOfChar(' ',Paragraph);
  Str := TStringList.Create;
  try
    Str.Text := FDescription;
    for I := 0 to str.Count - 1 do
    begin
      S.Add(Sl + '''' + Str[I]);
    end;
  finally
    Str.Free;
  end;
end;

procedure TVisualBlock.DoGenerateEndComment(S: TStrings;
  Paragraph: Integer);
begin
end;

procedure TVisualBlock.ShowException(Msg: string);
begin
  Application.MessageBox(PChar(Format('Во время генерации блока "%s" возникла ошибка:',
    [FBlockName]) + #13#10 + Msg), 'Ошибка генерации', MB_OK or MB_ICONERROR);
end;

function TVisualBlock.GetFrameColor: TColor;
var
  b: boolean;
begin
  if Assigned(SelBlockList) then
    b:= (SelBlockList.IndexOf(self) > -1)
  else
    b:= Focused;
  if b then
    Result := clActiveCaption
  else
    Result := clInactiveCaption;
end;

procedure TVisualBlock.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited
  Invalidate;
end;

procedure TVisualBlock.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Invalidate;
  if Assigned(OnBlockSelect) then
    OnBlockSelect(Self);
end;

function TVisualBlock.HasBody: boolean;
begin
  Result := True;
end;

function TVisualBlock.GetBodyRect: TRect;
begin
  Result := inherited GetClientRect;
  Result.Top := Result.Top + GetHeaderHeight;
  if HasBody and FUnWrap then
  begin
    if HasFootter then
      Result.Bottom := Result.Bottom - GetFotterHieght;
  end else
    Result.Bottom := Result.Top;
end;

function TVisualBlock.GetButtonRect: TRect;
var
  BSize: Integer;
begin
  Result := GetClientRect;
  if HasBody or HasFootter then
  begin
    BSize := 9;
    Result.Left := cLeftSpace;
    Result.Right := Result.Left + BSize;
    Result.Top := (GetHeaderHeight - BSize) div 2;
    Result.Bottom := Result.Top + BSize;
  end else
  begin
    Result.Bottom := Result.Top;
    Result.Right := Result.Left;
  end;
end;

function TVisualBlock.ClickInButton(X, Y: Integer): Boolean;
var
  R: TRect;
  P: TPoint;
begin
  R := GetButtonRect;
  P := Point(X, Y);
  Result := PtInRect(R, P);
end;

procedure TVisualBlock.SetParent(AParent: TWinControl);
begin
  inherited;
  ReGenerate := True;
  Modified := True;
end;

procedure TVisualBlock.GetVars(const Strings: TStrings);
begin

end;

function TVisualBlock.ObjectStreamVersion: Integer;
begin
  Result := 18;
end;

procedure TVisualBlock.KeyDown(var Key: Word; Shift: TShiftState);
var
  I: Integer;
  K: Integer;
begin
  if ((Key = VK_UP) or (Key = VK_DOWN)) and (Shift = [ssShift]) then
  begin
    for I := 0 to Parent.ControlCount - 1 do
    begin
      if Self = Parent.Controls[I] then
      begin
        if ((Key = VK_UP) and (I > 0))
          or ((Key = VK_DOWN) and (I < (Parent.ControlCount - 1))) then
        begin
          if Assigned(SelBlockList) then
          begin
            if Key = VK_UP then
              K := I - 1
            else
              K := I + 1;
            if SelBlockList.IndexOf(Parent.Controls[K]) > -1 then
            begin
              SelBlockList.Extract(Self);
              TVisualBlock(Self).Repaint;
            end
            else
            begin
              SelBlockList.Add(Parent.Controls[K]);
              TVisualBlock(Parent.Controls[K]).Repaint;
            end;
            TVisualBlock(Parent.Controls[K]).SetFocus;
          end;
        end;
        break;
      end;
    end;
  end
  else
    inherited;
end;

procedure TVisualBlock.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) then
  begin
    Delete;
  end else
    inherited;
end;

procedure TVisualBlock.WMClose(var Message: TWMClose);
begin
  if Assigned(OnBlockUnselect) then
    OnBlockUnSelect(Self);

  Free;
  Message.Result := 0;
end;

function TVisualBlock.GetColor: TColor;
begin
  Result := HeaderColor;
end;

function TVisualBlock.GetEditing: Boolean;
begin
  Result := FEditing;
end;

procedure TVisualBlock.ReleaseVars;
var
  I: Integer;
begin
  DoReleaseVars;
  for I := 0 to ControlCount - 1 do
  begin
    TVisualBlock(Controls[I]).ReleaseVars;
  end
end;

procedure TVisualBlock.ReserveVars;
var
  I: Integer;
begin
  DoReserveVars;
  for I := 0 to ControlCount - 1 do
  begin
    TVisualBlock(Controls[I]).ReserveVars;
  end
end;

procedure TVisualBlock.DoReleaseVars;
begin
end;

procedure TVisualBlock.DoReserveVars;
begin

end;

procedure TVisualBlock.SetReserved(const Value: string);
begin
  FReserved := Value;
end;

procedure TVisualBlock.SetLocalName(const Value: string);
begin
  FLocalName := Value;
  {$IFDEF GEDEMIN}
  AdjustSize;
  {$ENDIF}
end;

function TVisualBlock.CanEdit: boolean;
begin
  if Running then
    ShowMessage('Редактирование невозможно т.к. в данный'#13#10 +
      'момент выполняется скрипт.');
  Result := not Running;
end;

procedure TVisualBlock.GetBlockSet(var BS: TBlockSet);
var
  I: Integer;
begin
  BS := BS + [GetBlockSetMember];
  for I := 0 to ControlCount - 1 do
  begin
    TVisualBlock(Controls[i]).GetBlockSet(BS);
  end;
end;

function TVisualBlock.GetBlockSetMember: TBlockSetMember;
begin
  Result := bsSimple;
end;

function TVisualBlock.EditExpression(Expression: string; Sender: TVisualBlock): string;
begin
  if MainFunction <> nil then
    Result := MainFunction.EditExpression(Expression, Sender)
  else
    Result := Expression;  
end;

function TVisualBlock.GetEditFrame: TFrameClass;
begin
  Result := TfrEditFrame;
end;

procedure TVisualBlock.DoCreateNew;
begin

end;

function TVisualBlock.GetEditDialogForm: TdlgBaseEditForm;
var
  Fr: TfrEditFrame;
begin
  Result := TdlgEditForm.Create(Application);
  Fr := TfrEditFrame(GetEditFrame.Create(Result));
  Result.EditFrame := Fr;

  Fr.Parent := Result;

  Result.Block := Self;
  Result.AutoSize := True;
  Result.Height := 20;
end;

function TVisualBlock.CanSave: Boolean;
var
  I: Integer;
begin
  Result := CheckName;
  if not Result then
  begin
    ShowMessage(Format(RUS_INVALID_VISUALBLOCK_NAME, [Header]))
  end else
  begin
    for I := 0 to ControlCount - 1 do
    begin
      Result := TVisualBlock(Controls[I]).CanSave;
      if not Result  then Exit;
    end;
  end;
end;

function TVisualBlock.GetCannotDelete: boolean;
begin
  Result := FCannotDelete;
end;

function TVisualBlock.GetVarScript(const VarName: string): string;
begin
  Result := VarName;
end;

procedure TVisualBlock.InsertLine(Count: Integer);
var
  I: Integer;
begin
  Inc(FBeginScriptLine, Count);
  Inc(FEndScriptLine, Count);
  for I := 0 to ControlCount - 1 do
  begin
    TVisualBlock(Controls[I]).InsertLine(Count);
  end;
end;

procedure TVisualBlock.Delete;
var
  I: integer;
begin
  if not Assigned(SelBlockList) then Exit;
  if CanEdit then
  begin
    for I:= SelBlockList.Count - 1 downto 0 do
    begin
      if (SelBlockList[I] is TVisualBlock) and (not (SelBlockList[I] as TVisualBlock).CannotDelete) then
      begin
        if Assigned(OnBlockUnselect) then
          OnBlockUnSelect(SelBlockList[I]);
        SelBlockList[I].Free;
      end;
    end;
    SelBlockList.Clear;

    if Parent <> nil then
      Parent.SetFocus;
    ReGenerate := True;
    Modified := True;
  end;
end;

function TVisualBlock.CanCopy: Boolean;
begin
  Result := True;
end;

function TVisualBlock.CanCut: Boolean;
begin
  Result := CanCopy and not CannotDelete;
end;

class function TVisualBlock.CanPast_(Stream: TStream;
  AParent: TVisualBlock): Boolean;
var
  CName: String;
  C: TVisualBlockClass;
begin
  Result := False;
  CName := ReadStringFromStream(Stream);
  C := TVisualBlockClass(GetClass(CName));
  if C <> nil then
  begin
    if not (TVisualBlock(AParent).CanHasOwnBlock  and
      C.CheckParent(TVisualBlock(AParent)) and TVisualBlock(AParent).CanEdit) then
      Exit;
    Result := True;
  end;
end;

class function TVisualBlock.NeedRename: Boolean;
begin
  Result := True;
end;

procedure TVisualBlock.Copy;
var
  i: integer;
  Stream: TMemoryStream;
  H: THandle;
  P: Pointer;
begin
  if not Assigned(SelBlockList) or not Assigned(CopiedBlockList) then Exit;

  ClipboardFormat:= RegisterClipboardFormat(ClipboardFormatName);
  if not OpenClipboard(Application.Handle) then Exit;
  try
    EmptyClipboard;
    for i:= CopiedBlockList.Count - 1 downto 0 do
        CopiedBlockList.Delete(i);
    SelBlockList.Sort(SortSelBlockList);
    for i:= 0 to SelBlockList.Count - 1 do begin
      Stream:= TMemoryStream.Create;
      try
        SaveLabelToStream(cWizLb, Stream);
        TVisualBlock(SelBlockList[i]).SaveToStream(Stream);
      finally
        CopiedBlockList.Add(Stream);
      end;
    end;
    Stream:= TMemoryStream.Create;
    try
      if SaveCopiedToStream(Stream) then begin
        H := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE,
          Stream.Size + SizeOf(Integer));
        if H <> 0 then
        begin
          P := GlobalLock(H);
          try
            CopyMemory(P, Stream.Memory, Stream.Size)
          finally
            GlobalUnlock(H);
            if not (SetClipboardData(ClipboardFormat, H) > 0) then
              EmptyClipboard;
          end;
        end;
      end;
    finally
      FreeAndNil(Stream);
    end;
  finally
    CloseClipboard;
  end;
end;

procedure TVisualBlock.Cut;
begin
  if not Assigned(SelBlockList) then Exit;
  Copy;
  Delete;
end;

procedure TVisualBlock.Paste;
var
  Stream: TMemoryStream;
  i: integer;
  Temp: Integer;
begin
  if not Assigned(SelBlockList) or not Assigned(CopiedBlockList) then Exit;
  if not LoadCopiedFromClipboard then Exit;
  Temp := FMousePoint.Y;
  for i:= 0 to CopiedBlockList.Count - 1 do begin
    if TObject(CopiedBlockList[i]) is TMemoryStream then begin
      Stream:= TMemoryStream(CopiedBlockList[i]);
      Stream.Position:= 0;
      CheckLabel(cWizLb, Stream, cLoadStreamError);
      Temp := DoPaste(Stream, Owner, Self, Temp);
    end;
  end;
end;

procedure TVisualBlock.SelectAll;
var
  I: Integer;
begin
  if not Assigned(SelBlockList) then
    Exit;

  ClearSelBlockList;

  for I := 0 to ControlCount - 1 do
  begin
    SelBlockList.Add(TVisualBlock(Controls[I]));
    if Assigned(OnBlockSelect) then
      OnBlockSelect(TVisualBlock(Controls[I]));
  end;
  
  Repaint;
end;

function TVisualBlock.CanPast: Boolean;
var
  i: integer;
  Stream: TMemoryStream;
begin
  ClipboardFormat:= RegisterClipboardFormat(ClipboardFormatName);
  Result:= IsClipboardFormatAvailable(ClipboardFormat);
  if not Result then Exit;
  Result:= Assigned(SelBlockList) and LoadCopiedFromClipboard and (CopiedBlockList.Count > 0);
  if Result then begin
    try
      for i:= 0 to CopiedBlockList.Count - 1 do begin
        Stream:= TMemoryStream(CopiedBlockList[i]);
        Stream.Position:= 0;
        CheckLabel(cWizLb, Stream, cLoadStreamError);
        Result:= TVisualBlock.CanPast_(Stream, Self);
        if not Result then Exit;
      end;
    except
      Result:= False;
    end;
  end;
end;

function TVisualBlock.GetNextIndex(ATop: Integer): Integer;
var
  I: Integer;
  Delta: Integer;
begin
  Delta := MaxInt;
  Result := -1;
  for I := 0 to ControlCount - 1 do
  begin
    if (ATop < Controls[I].Top) and (Controls[I].Top - ATop < Delta) then
    begin
      Result := I;
      Delta := Controls[I].Top - ATop;
    end;
  end;
end;

procedure TVisualBlock.CheckActionList;
begin
  if FActionList = nil then
  begin
    FActionList := TActionList.Create(Self);

    FactSelAll := TAction.Create(Self);
    FactSelAll.ActionList := FActionList;
    FactSelAll.OnExecute := OnSelectAllExecute;
    FactSelAll.OnUpdate := OnSelectAllUpdate;
    FactSelAll.Caption := 'Выделить все';
    FactSelAll.ShortCut := ShortCut(Ord('A'), [ssCtrl]);

    FactCopy := TAction.Create(Self);
    FactCopy.ActionList := FActionList;
    FactCopy.OnExecute := OnCopyExecute;
    FactCopy.OnUpdate := OnCopyUpdate;
    FactCopy.Caption := 'Копировать';
    FactCopy.ShortCut := ShortCut(Ord('C'), [ssCtrl]);

    FactCut := TAction.Create(Self);
    FactCut.ActionList := FActionList;
    FactCut.OnExecute := OnCutExecute;
    FactCut.OnUpdate := OnCutUpdate;
    FactCut.Caption := 'Вырезать';
    FactCut.ShortCut := ShortCut(Ord('X'), [ssCtrl]);

    FactPast := TAction.Create(Self);
    FactPast.ActionList := FActionList;
    FactPast.OnExecute := OnPastExecute;
    FactPast.OnUpdate := OnPastUpdate;
    FactPast.Caption := 'Вставить';
    FactPast.ShortCut := ShortCut(Ord('V'), [ssCtrl]);
    {$IFDEF GEDEMIN}
    FActionList.Images := dmImages.il16x16;
    FactCopy.ImageIndex := iiCopy;
    FactCut.ImageIndex := iiCut;
    FactPast.ImageIndex := iiPast;
    {$ENDIF}
  end;
end;

procedure TVisualBlock.OnCopyExecute(Sender: TObject);
begin
  Copy
end;

procedure TVisualBlock.OnCopyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanCopy
end;

procedure TVisualBlock.OnSelectAllExecute(Sender: TObject);
begin
  SelectAll;
end;

procedure TVisualBlock.OnSelectAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := True;
end;

procedure TVisualBlock.OnCutExecute(Sender: TObject);
begin
  Cut
end;

procedure TVisualBlock.OnCutUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanCut
end;

procedure TVisualBlock.OnPastExecute(Sender: TObject);
begin
  Paste
end;

procedure TVisualBlock.OnPastUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanPast
end;

function TVisualBlock.SelectColor: TColor;
begin
  Result := RGB(100, 100, 100);
end;

{ TFunctionBlock }

class function TFunctionBlock.CheckParent(AParent: TVisualBlock): Boolean;
begin
  Result := AParent is TScriptBlock;
end;

constructor TFunctionBlock.Create(AOwner: TComponent);
begin
  inherited;

  FFunctionParams := TwizParamList.Create;
  InitInitScript;
  InitFinalScript;
end;

destructor TFunctionBlock.Destroy;
begin
  FFunctionParams.Free;
  
  inherited;
end;

procedure TFunctionBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited DoLoadFromStream(Stream);

  Stream.ReadBuffer(FReturnResult, SiZeOf(FReturnResult));
  FFunctionParams.LoadFromStream(Stream);
  FInitScript := ReadStringFromStream(Stream);
  FFinalScript := ReadStringFromStream(Stream);

  if CannotDelete then
    MainFunction := self;
end;

procedure TFunctionBlock.DoSaveToStream(Stream: TStream);
begin
  inherited DoSaveToStream(Stream);

  Stream.Write(FReturnResult, SiZeOf(FReturnResult));
  FFunctionParams.SaveToStream(Stream);
  SaveStringToStream(FInitScript, Stream);
  SaveStringToStream(FFinalScript, Stream);
end;

function TFunctionBlock.FotterPrefix: string;
begin
  FotterPrefix := 'Конец процедуры';
end;

procedure TFunctionBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: String;
  Str: TStringList;
  I: Integer;
begin
  lS := StringOfChar(' ', Paragraph);
  ReserveVars;
  try
    if FReturnResult then
      S.Add(Format(lS + 'Function %s%s', [FBlockName,  GetParamsString]))
    else
      S.Add(Format(lS + 'Sub %s%s', [FBlockName,  GetParamsString]));


    Inc(Paragraph, 2);
    try
      _DoBeforeGenerate(S, Paragraph);

      Str := TStringList.Create;
      try
        Str.Text := FInitScript;
        ls := StringOfChar(' ',Paragraph);
        if Str.Count > 0 then
        begin
          S.Add(lS + '''Скрипт инициализации процедуры');
          for I := 0 to Str.Count -1 do
          begin
            S.Add(lS + Str[I]);
          end;
        end;
      finally
        Str.Free;
      end;
      inherited DoGenerate(S, Paragraph);

      Str := TStringList.Create;
      try
        Str.Text := FFinalScript;
        ls := StringOfChar(' ',Paragraph);
        if Str.Count > 0 then
        begin
          S.Add(lS + '''Скрипт финализации процедуры');
          for I := 0 to Str.Count -1 do
          begin
            S.Add(lS + Str[I]);
          end;
        end;
      finally
        Str.Free;
      end;
      _DoAfterGenerate(S, Paragraph);
    finally
      Dec(Paragraph, 2);
    end;

    lS := StringOfChar(' ', Paragraph);

    if FReturnResult then
      S.Add(lS + 'End Function')
    else
      S.Add(lS + 'End Sub');

    DoGenerateExceptFunction(S, Paragraph);
  finally
    ReleaseVars;
  end;
end;

function TFunctionBlock.GetParamsString: string;
var
  I: Integer;
  P: TwizParamData;
begin
  Result := '';
  for I := 0 to FFunctionParams.Count - 1 do
  begin
    P := FFunctionParams.Params[i];
    if Result > '' then Result := Result + ', ';

    if P.ReferenceType > '' then
      Result := Result + P.ReferenceType + ' ' + P.RealName
    else
       Result := Result + P.RealName;
  end;
  if Result > '' then Result := '(' + Result + ')';
end;


function TFunctionBlock.HeaderPrefix: string;
begin
  Result := 'Процедура'; 
end;

class function TFunctionBlock.NamePrefix: string;
begin
  Result := 'Sub';
end;

procedure TFunctionBlock.SetReturnResult(const Value: Boolean);
begin
  FReturnResult := Value;
end;

procedure TFunctionBlock.ShowErrorMessage;
begin
end;

procedure TFunctionBlock.DoGenerateEndComment(S: TStrings;
  Paragraph: Integer);
begin
  inherited;
  S.Add('');
end;

function TFunctionBlock.HasFootter: boolean;
begin
  Result := True;
end;

procedure TFunctionBlock._DoBeforeGenerate(S: TStrings; Paragraph: Integer);
begin
end;

procedure TFunctionBlock.SetInitScript(const Value: string);
begin
  FInitScript := Value;
end;

procedure TFunctionBlock.InitInitScript;
begin
  FInitScript := ''
end;

procedure TFunctionBlock.GetVars(const Strings: TStrings);
var
  I: Integer;
begin
  if FFunctionParams <> nil then
    for I := 0 to FFunctionParams.Count - 1 do
      if Strings.IndexOfName(TwizParamData(FFunctionParams[I]).RealName) = - 1 then
        Strings.AddObject(TwizParamData(FFunctionParams[I]).RealName + '=' +
          TwizParamData(FFunctionParams[I]).Comment, Self);
  if FReturnResult then
    Strings.AddObject(FBlockName + '=' + FDescription, Self);        
end;

procedure TFunctionBlock.SetFinalScript(const Value: string);
begin
  FFinalScript := Value;
end;

procedure TFunctionBlock.InitFinalScript;
begin
  FFinalScript := '';
end;

procedure TFunctionBlock._DoAfterGenerate(S: TStrings; Paragraph: Integer);
begin
end;

class function TFunctionBlock.GetUniqueName: string;
var
  I: Integer;
begin
  I := 1;
  Result := NamePrefix + '_' + IntToStr(I) + '_' + FunctionRUID;
  while not CheckUniqueName(Result) do
  begin
    Inc(I);
    Result := NamePrefix + '_' + IntToStr(I) + '_' + FunctionRUID;
  end;
end;

procedure TFunctionBlock.DoReleaseVars;
begin
  ReleaseVarName('Transaction');
  ReleaseVarName('Creator');
  ReleaseVarName('Result');
end;

procedure TFunctionBlock.DoReserveVars;
begin
  AddVarName('Transaction');
  AddVarName('Creator');
  AddVarName('Result');
end;

function TFunctionBlock.BodyColor: TColor;
begin
  Result := Windows.RGB(244, 244, 244)
end;

function TFunctionBlock.EditExpression(Expression: string; Sender: TVisualBlock): string;
{$IFDEF GEDEMIN}
var
  F: TExpressionEditorForm;
{$ENDIF}
begin
  Result := Expression;
  {$IFDEF GEDEMIN}
  F := TExpressionEditorForm.Create(Application);
  try
    F.mExpression.Lines.Text := Expression;
    F.Block := Sender;
    if F.ShowModal = mrOk then
    begin
      Result := Trim(F.mExpression.Lines.Text);
    end;
  finally
    F.Free;
  end;
  {$ENDIF}
end;

procedure TFunctionBlock.SetCardOfAccountsRUID(const Value: string);
begin
  FCardOfAccountsRUID := Value;
end;

procedure TFunctionBlock.DoGenerateExceptFunction(S: TStrings;
  Paragraph: Integer);
var
  ls: string;
  BS: TBlockSet;
begin
  BS := [];
  GetBlockSet(BS);
  if BS * [bsCycle, bsEntry, bsTax] <> [] then
  begin
    lS := StringOfChar(' ', Paragraph);
    S.Add('''Функция обработки исключения');
    S.Add(lS + Format('Sub Except%s (Transaction)', [FBlockName]));
    S.Add(lS + '  Transaction.Rollback');
    S.Add(lS + '  GS.Transaction = Nothing');
    S.Add(lS + 'End Sub');
    S.Add('');
  end;
end;

procedure TFunctionBlock.DoGenearteCallExceptFunction(S: TStrings;
  Paragraph: Integer);
var
  BS: TBlockSet;
  lS: string;
begin
  BS := [];
  GetBlockSet(BS);
  if BS * [bsCycle, bsEntry, bsTax] <> [] then
  begin
    lS := StringOfChar(' ', Paragraph);
    S.Add(lS + Format('Except Except%s(Transaction)', [FBlockName]));
  end;
end;

function TFunctionBlock.CanRun: Boolean;
begin
  Result := True;
end;

function TFunctionBlock.CheckAccount(Account: string;
  var AccountId: Integer): boolean;
var
  SQL: TIBSQL;
  I: Integer;
begin
  if AccountId = 0 then
  begin
    //Может передан алиас?
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQL.Text := Format('SELECT a.id FROM ac_account a JOIN ac_account c ' +
        ' ON c.lb <= a.lb AND c.rb >= c.rb AND c.accounttype = ''C'' WHERE UPPER(a.alias) = ''%s'' '+
        ' AND c.id = %d', [UpperCase(Account),
        gdcBaseManager.GetIdByRUIDString(MainFunction.CardOfAccountsRUID)]);
      SQL.ExecQuery;
      Result := SQL.RecordCount > 0;
      if Result then
      begin
        AccountId := SQL.Fields[0].AsInteger;
        Exit;
      end;
    finally
      SQL.Free;
    end;

    //Может передан РУИД?
    if CheckRUID(Account) then
    begin
      AccountId := gdcBaseManager.GetIdByRUIDString(Account);
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        SQL.SQL.Text := Format('SELECT a.id FROM ac_account a JOIN ac_account c ' +
          ' ON c.lb <= a.lb AND c.rb >= c.rb AND c.accounttype = ''C'' WHERE a.id = %d '+
          ' AND c.id = %d', [AccountId,
          gdcBaseManager.GetIdByRUIDString(MainFunction.CardOfAccountsRUID)]);
        SQL.ExecQuery;
        Result := SQL.RecordCount > 0;
        if Result then Exit;
      finally
        SQL.Free;
      end;
    end;

    for I := 0 to BlockList.Count - 1 do
    begin
      if TObject(BlockList[I]) is TVarBlock then
      begin
        if UpperCase(TVisualBlock(BlockList[I]).BlockName) = UpperCase(Account) then
        begin
          Result := True;
          Exit;
        end;
      end;

      if TObject(BlockList[I]) is TCycleBlock then
      begin
        if (Pos(UpperCase(TVisualBlock(BlockList[I]).BlockName),UpperCase(Account)) = 1) and
          (Pos('.ACCOUNT', UpperCase(Account)) = Length(TVisualBlock(BlockList[I]).BlockName) + 1) then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
    { TODO :
    Есть необходимость вводить произвольные значения счета, но
    как проверть их коректность? }
    Result := True;
  end else
    Result := True;
end;

function TFunctionBlock.OnClickAccount(var Account: string;
  var AccountRuid: string): boolean;
{$IFDEF GEDEMIN}
var
  F: TatRelationField;
  Id: Integer;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  F := atDataBase.FindRelationField(AC_ENTRY, fnAccountKey);
  Result := false;
  if F <> nil then
  begin
    with TfrmAnalyticSel.Create(nil) do
    try
   
      DataField := F;
      if gdcBaseManager.GetIdByRUIDString(MainFunction.CardOfAccountsRUID) = -1 then
      begin
        ibcbAnalytics.ListTable := 'ac_account z';
        Condition := 'z.accounttype IN (''A'', ''S'')';
      end else
      begin
        ibcbAnalytics.ListTable := 'ac_account z JOIN ac_account c ON c.lb <= z.lb AND c.rb >= z.rb ';
        Condition := Format('c.id = %d AND z.accounttype IN (''A'', ''S'')',
          [gdcBaseManager.GetIdByRUIDString(MainFunction.CardOfAccountsRUID)]);
      end;
      ibcbAnalytics.ListField := fnAlias;

      if (AccountRuid > '') then
      begin
        if CheckRuid(AccountRuid) then
          Id := gdcBaseManager.GetIdByRuidString(AccountRuid)
        else
        begin
          try
            Id := StrToInt(AccountRuid);
          except
            Id := 0;
          end;
        end;
        AnalyticsKey := Id;
      end;

      if ShowModal = mrOk then
      begin
        Account := AnalyticAlias;
        AccountRUID := AnalyticsRUID;
        Result := True;
      end;
    finally
      Free;
    end
  end;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function TFunctionBlock.GetEditFrame: TFrameClass;
begin
{$IFDEF GEDEMIN}
  Result := TfrFunctionEditFrame;
  {$ELSE}
  Result := nil;
{$ENDIF}
end;

function TFunctionBlock.GetEditDialogForm: TdlgBaseEditForm;
begin
  Result := inherited GetEditDialogForm;
  if Result is TdlgEditForm then
  begin
    Result.EditFrame.Constraints.MaxHeight := 0;
    Result.EditFrame.Constraints.MaxWidth := 0;
    Result.AutoSize := False;
    TdlgEditForm(Result).bOk.Default := False;
  end;
end;

function TFunctionBlock.CanCopy: Boolean;
begin
  Result := MainFunction <> Self;
end;

{ TdlgBaseEditForm }

procedure TdlgBaseEditForm.beClick(Sender: TObject; PopupMenu: TPopupMenu);
var
  Point: TPoint;
begin
  if Sender is TEditSButton then
  begin
    Point.x := 0;
    Point.y := TEditSButton(Sender).Height - 1;
    Point := TEditSButton(Sender).ClientToScreen(Point);
    FActiveEdit := TEditSButton(Sender).Edit;
    PopupMenu.Popup(Point.X, Point.Y);
  end;
end;


function TdlgBaseEditForm.CheckOk: Boolean;
begin
  Result := True;
  if FEditFrame <> nil then
    Result := TfrEditFrame(FEditFrame).CheckOk
end;

function TdlgBaseEditForm.GetAccount(Account: string;
  AccountId: Integer): string;
begin
  if AccountId > 0 then
    Result := gdcBaseManager.GetRUIDStringById(AccountId)
  else
    Result := Account;
end;

procedure TdlgBaseEditForm.SaveChanges;
begin
  if FEditFrame <> nil then
    TfrEditFrame(FEditFrame).SaveChanges;
end;

function TdlgBaseEditForm.SetAccount(Account: string;
  out AccountID: Integer): string;
begin
  if CheckRUID(Account) then
    AccountId := gdcBaseManager.GetIDByRUIDString(Account)
  else
    AccountId := 0;

  if AccountId > 0 then
    Result := GetAlias(AccountId)
  else
    Result := Account;
end;

procedure TdlgBaseEditForm.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
  if FEditFrame <> nil then
    TfrEditFrame(FEditFrame).Block := FBlock
end;

procedure TdlgBaseEditForm.SetEditFrame(const Value: TFrame);
begin
  FEditFrame := Value;
  if (Value <> nil) and (FBlock <> nil) then
    TfrEditFrame(Value).Block := FBlock; 
end;

{ TCycleBlock }

function TCycleBlock.FotterPrefix: string;
begin
  Result := 'Конец цикла';
end;

function TCycleBlock.FotterColor: TColor;
begin
  Result := clYellow;
end;

function TCycleBlock.HeaderPrefix: string;
begin
  Result := 'Цикл';
end;

function TCycleBlock.HeaderColor: TColor;
begin
  Result := RGB(252, 248, 197);
end;

class function TCycleBlock.NamePrefix: string;
begin
  Result := 'Cycle';
end;

procedure TCycleBlock.DoReleaseVars;
begin
  ReleaseVarName(FBlockName)
end;

procedure TCycleBlock.DoReserveVars;
begin
  AddVarName(FBlockName);
end;

function TCycleBlock.BodyColor: TColor;
begin
  Result := RGB(255, 255, 236)
end;

function TCycleBlock.GetBlockSetMember: TBlockSetMember;
begin
  Result := bsCycle;
end;

class function TCycleBlock.NeedRename: Boolean;
begin
  Result := False;
end;

{ TIfBlock }

function TIfBlock.FotterPrefix: string;
begin
  Result := 'Конец условия'
end;

function TIfBlock.FotterColor: TColor;
begin
  Result  := clLime;
end;

function TIfBlock.HeaderPrefix: string;
begin
  Result := 'Условие'
end;

function TIfBlock.HeaderColor: TColor;
begin
  Result  := RGB(193, 251, 172);
end;

class function TIfBlock.NamePrefix: string;
begin
  Result := 'If';
end;

procedure TIfBlock.DoGenerate(S: TStrings; Paragraph: Integer);
begin
  S.Add(Format(StringOfChar(' ',Paragraph) + 'If %s Then', [GenerateExpression(FCondition)]));
  Inc(Paragraph, 2);
  try
    inherited DoGenerate(S, Paragraph);
  finally
    Dec(Paragraph, 2);
  end;
  S.Add(StringOfChar(' ',Paragraph) + 'End If');
end;

procedure TIfBlock.SetCondition(const Value: string);
begin
  FCondition := Value;
end;

function TIfBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrIfEditFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

procedure TIfBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  FCondition := ReadStringFromStream(Stream);
end;

procedure TIfBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  
  SaveStringToStream(FCondition, Stream);
end;

function TIfBlock.BodyColor: TColor;
begin
  Result := RGB(230, 255, 230);
end;

{ TVarBlock }

function TVarBlock.CanHasOwnBlock: boolean;
begin
  Result := False;
end;

constructor TVarBlock.Create(AOwner: TComponent);
begin
  inherited;
end;


function TVarBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrVarEditFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TVarBlock.HasFootter: boolean;
begin
  Result := False;
end;

function TVarBlock.HeaderPrefix: string;
begin
  Result := 'Переменная';
end;

function TVarBlock.HeaderColor: TColor;
begin
  Result := RGB(251, 206, 248);
end;

procedure TVarBlock.SetExpression(const Value: string);
begin
  FExpression := Value;
end;

procedure TVarBlock.SetIsobject(const Value: Boolean);
begin
  FIsobject := Value;
end;

class function TVarBlock.NamePrefix: string;
begin
  Result := 'Var';
end;

procedure TVarBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
begin
  lS := '';
  if IsObject then lS := 'Set ';
  lS := lS + FBlockName + ' = ' + GenerateExpression(Expression);
  S.Add(StringOfChar(' ', Paragraph) + lS);
  AddVarName(Name);
end;

function GenerateExpression(S: String): string;
const
  tfBFD     = '[';
  tfEFD     = ']';
  tfSpace   = ' ';
  tfColon   = ':';
  tfStrDecl = '"';
  tfPoint   = '.';
  tfComma   = ',';
  tfOpenCom = '{';
  tfCloseCom = '}';

  procedure ConvertProcess(var Script: String);
  var
    CI, CI1: Integer;
    CBCount, CSDCount, ComCount: Integer;
    CtxFunc: TtxFuncDecl;
    CTypeStr: String;
    CBNamePos: Integer;
    CTmpStr: String;
    CPrevLength: Integer;
    CtxFuncParam: String;
    CCommaFound: Boolean;
    Index: Integer;

    FieldName: string;
    {$IFDEF GEDEMIN}
    //F: TatRelationField;
    DI: TDocumentField;
    DocumentPart: TgdcDocumentClassPart;
    {$ENDIF}
    V: string;
  begin
    CCommaFound := False;
    CI := 1;
    CI1 := 1;
    CBCount := 0;
    CSDCount := 0;
    CBNamePos := 0;
    ComCount := 0;
    while CI <= Length(Script) do
    begin
      if ComCount > 0 then
      begin
        if Script[CI] = tfCloseCom then
        begin
          ComCount := 0;
          Delete(Script, CI1, CI - CI1 + 1);
          CI := CI1;
        end;
      end else
      begin
        case Script[CI] of
          tfOpenCom:
            begin
              Inc(ComCount);
              CI1 := CI;
            end;
          tfColon:
            if CSDCount mod 2 = 0 then
              raise Exception.Create('Ошибка синтаксиса.'#13#10 +
                'Использование символа ":" запрещено.');
          tfComma:
          begin
            if CCommaFound and (CSDCount mod 2 = 0) then
              raise Exception.Create('Ошибка синтаксиса (две запятые подряд).'#13#10 +
                'Возможно, пропущен параметр.');
            CCommaFound := True;
          end;
          tfBFD:
          begin
            if CBCount = 0 then
            begin
              CtxFunc.Name := '';
              CtxFunc.FuncType := txUnknown;
              CtxFunc.BPos := CI;
              CtxFunc.EPos := -1;
              CBNamePos := -1;
            end;
            Inc(CBCount);
          end;
          tfStrDecl: Inc(CSDCount);
          tfEFD:
          begin
            Dec(CBCount);
            if (CBCount = 0) and ((CSDCount mod 2) = 0) then
            begin
              CSDCount := 0;
              CtxFunc.EPos := CI;
              CI := CtxFunc.BPos + 1;
              while CI <= CtxFunc.EPos do
              begin
                case Script[CI] of
                  tfSpace: ;
                  tfPoint:
                  begin
                    if not (CtxFunc.FuncType = txUnknown) then
                      raise Exception.Create('Ошибка синтаксиса (две точки подряд).');

                    CTypeStr := AnsiUpperCase(Trim(copy(Script, CtxFunc.BPos + 1,
                      CI - CtxFunc.BPos - 1)));
                    if CTypeStr = tfVBF then
                    begin
                      CtxFunc.FuncType := txVB;
                    end else
                    if CTypeStr = tfSFF then
                    begin
                      CtxFunc.FuncType := txSF
                    end else
                    if CTypeStr = tfCFF then
                    begin
                      CtxFunc.FuncType := txCF
                    end else
                    if CTypeStr = tfGSF then
                    begin
                      CtxFunc.FuncType := txGS
                    end else
                    if CTypeStr = tfHead then
                    begin
                      CtxFunc.FuncType := txHead
                    end else
                    if CTypeStr = tfLine then
                    begin
                      CtxFunc.FuncType := txLine
                    end else
                      raise Exception.Create('Тип функции не определен.');
                  end
                  else
                    begin
                      if (not (CtxFunc.FuncType = txUnknown)) then
                      begin
                        if CBNamePos = -1 then
                        begin
                          if Pos(Script[CI], txNameChars) > 0  then
                            CBNamePos := CI
                          else
                            raise Exception.Create('Ошибка синтаксиса.');
                        end else
                          if Pos(Script[CI], txNameChars) = 0  then
                          begin
                            CPrevLength := Length(Script);

                            CtxFunc.Name := Copy(Script, CBNamePos, CI - CBNamePos);
                            if Length(CtxFunc.Name) > 0 then
                            begin
                              CtxFuncParam := Copy(Script, CI, CtxFunc.EPos - CI);
                              ConvertProcess(CtxFuncParam);
                              CTmpStr := CtxFunc.Name + CtxFuncParam +
                                Copy(Script, CtxFunc.EPos + 1, Length(Script));

                              case CtxFunc.FuncType of
                                txVB:
                                  Script := Copy(Script, 1, CtxFunc.BPos - 1) + CTmpStr;
                                txSF:
                                begin
                                  Index := IncludeList.IndexOf('''#include ' + CtxFunc.Name);
                                  if Index = - 1 then
                                    IncludeList.Add('''#include ' + CtxFunc.Name);
                                  Script := Copy(Script, 1, CtxFunc.BPos - 1) + CTmpStr;
                                end;
                                txCF:
                                  Script := Copy(Script, 1, CtxFunc.BPos - 1) +
                                    CtxFunc.Name +
                                    Copy(CTmpStr, 1 + Length(CtxFunc.Name), Length(CTmpStr));
                                txGS:
                                  Script := Copy(Script, 1, CtxFunc.BPos - 1) +
                                    'GS.' + CTmpStr;
                                txHead:
                                  begin
                                   if not ((MainFunction is TTrEntryFunctionBlock) or
                                     (MainFunction is TDocumentTransactionFunction))then
                                     raise Exception.Create(RUS_INVALIDTYPE);
                                   FieldName := CtxFunc.Name + CtxFuncParam;
                                   {$IFDEF GEDEMIN}
                                   if MainFunction is TTrEntryFunctionBlock then
                                   begin
                                     Di := TTrEntryFunctionBlock(MainFunction).DocumentHead.Find(FieldName);
                                     DocumentPart := TTrEntryFunctionBlock(MainFunction).DocumentPart;
                                   end else
                                   begin
                                     Di := TDocumentTransactionFunction(MainFunction).DocumentHead.Find(FieldName);
                                     DocumentPart := TDocumentTransactionFunction(MainFunction).DocumentPart;
                                   end;

                                   if (DI <> nil) and (DI.RelationField.ReferencesField = nil) then
                                   begin
                                     V := DI.FieldRepresentation
                                   end else
                                     V := 'Value';


                                   if DocumentPart = dcpLine then
                                   begin
                                     Script := Copy(Script, 1, CtxFunc.BPos - 1) +
                                       Format('gdcDocumentHeader.FieldByName("%s").%s',
                                       [CtxFunc.Name + CtxFuncParam, V]) +
                                       Copy(Script, CtxFunc.EPos + 1, Length(Script));
                                     _CheckMaster := True;
                                   end else
                                     Script := Copy(Script, 1, CtxFunc.BPos - 1) +
                                       Format('gdcDocument.FieldByName("%s").%s',
                                       [CtxFunc.Name + CtxFuncParam, V]) +
                                       Copy(Script, CtxFunc.EPos + 1, Length(Script));
                                  {$ENDIF}
                                  end;
                                txLine:
                                  begin
                                   if not ((MainFunction is TTrEntryFunctionBlock) or
                                     (MainFunction is TDocumentTransactionFunction))then
                                     raise Exception.Create(RUS_INVALIDTYPE);


                                   FieldName := CtxFunc.Name + CtxFuncParam;
                                   {$IFDEF GEDEMIN}
                                   if MainFunction is TTrEntryFunctionBlock then
                                   begin
                                     if TTrEntryFunctionBlock(MainFunction).DocumentLine = nil then
                                       raise Exception.Create('Ссылка на документ позиции невозможна!');

                                     Di := TTrEntryFunctionBlock(MainFunction).DocumentLine.Find(FieldName);
                                   end else
                                   begin
                                     if TDocumentTransactionFunction(MainFunction).DocumentLine = nil then
                                       raise Exception.Create('Ссылка на документ позиции невозможна!');

                                     Di := TDocumentTransactionFunction(MainFunction).DocumentLine.Find(FieldName);
                                   end;

                                   if (DI <> nil) and (DI.RelationField.ReferencesField = nil) then
                                   begin
                                     V := DI.FieldRepresentation;
                                   end else
                                     V := 'Value';
                                   {$ENDIF}
                                   Script := Copy(Script, 1, CtxFunc.BPos - 1) +
                                     Format('gdcDocument.FieldByName("%s").%s',
                                     [CtxFunc.Name + CtxFuncParam, V]) +
                                     Copy(Script, CtxFunc.EPos + 1, Length(Script));
                                  end;
                                else
                                  raise Exception.Create(RUS_INVALIDTYPE);
                              end;
                              CI := CtxFunc.EPos - (CPrevLength - Length(Script));
                              Break;
                            end else
                              raise Exception.Create('Ошибка в имени функции.');
                          end;
                      end;
                    end;
                end;

                Inc(CI);
              end;
            end;
          end;
        end;
      end;
      if (Script[CI] <> tfSpace) and (Script[CI] <> tfComma)  then
        CCommaFound := False;
      Inc(CI);
    end;
    if (CSDCount mod 2) <> 0 then
      raise Exception.Create('Ошибка синтаксиса.'#13#10 +
        'Обнаружена незаконченная строка.');
    if ComCount <> 0 then
      raise Exception.Create('Ошибка синтаксиса.'#13#10 +
        'Обнаружена незаконченный коментарий.');
  end;

begin
  Result := S;
  ConvertProcess(Result);
end;

procedure TVarBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;

  FExpression := ReadStringFromStream(Stream);
  Stream.ReadBuffer(FIsObject, SizeOf(FIsObject));
end;

procedure TVarBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;

  SaveStringToStream(FExpression, Stream);
  Stream.Write(FIsObject, SizeOf(FIsObject));
end;

procedure TVarBlock.DoGenerateEndComment(S: TStrings; Paragraph: Integer);
begin

end;

function TVarBlock.HasBody: boolean;
begin
  Result := False;
end;

procedure TVarBlock.GetVars(const Strings: TStrings);
begin
  if Strings.IndexOfName(FBlockName) = - 1 then
    if FDescription > '' then
      Strings.AddObject(FBlockName + '=' + FDescription, Self)
    else
      Strings.AddObject(FBlockName + '=' + FLocalName, Self)
end;

class function TVarBlock.NeedRename: Boolean;
begin
  Result := False;
end;

procedure TVarBlock.GetNamesList(const S: TStrings);
begin
  inherited;
end;

{ TElseBlock }

class function TElseBlock.CheckParent(AParent: TVisualBlock): Boolean;
var
  I: Integer;
begin
  Result := AParent is TIfBlock;
  if Result then
  begin
    for I := 0 to AParent.ControlCount - 1 do
    begin
      if AParent.Controls[I] is TElseBlock then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

procedure TElseBlock.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  inherited;
end;

function TElseBlock.HasFootter: boolean;
begin
  Result := False;
end;

function TElseBlock.HeaderPrefix: string;
begin
  Result := 'Иначе'
end;

function TElseBlock.HeaderColor: TColor;
begin
  Result  := RGB(193, 251, 175)
end;

class function TElseBlock.NamePrefix: string;
begin
  Result := 'Else'
end;

procedure TElseBlock.DoGenerate(S: TStrings; Paragraph: Integer);
begin
  Dec(Paragraph, 2);
  try
    S.Add(StringOfChar(' ',Paragraph) + 'Else')
  finally
    Inc(Paragraph, 2);
  end;
  inherited DoGenerate(S, Paragraph);
end;

function TElseBlock.BodyColor: TColor;
begin
  Result := RGB(230, 255, 230)
end;

{ TAccountCycleBlock }

procedure TAccountCycleBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  VarName: string;
  lS: String;
begin
  lS := StringOfChar(' ', Paragraph);
  VarName := 'sql_' + FBlockName;
  try
    S.Add(lS + Format('Set %s = Creator.GetObject(null, "TIBSQL", "")', [VarName]));
    S.Add(lS + Format('%s.Transaction = gdcBaseManager.ReadTransaction', [VarName]));

    GenerateSQL(S, Paragraph, VarName);

    if (BeginDate > '')  then
      S.Add(lS + Format('%s.ParamByName("begindate").AsDateTime = %s',
        [VarName, BeginDate]));
    if EndDate > '' then
      S.Add(lS + Format('%s.ParamByName("enddate").AsDateTime = %s',
        [VarName, EndDate]));

    S.Add(lS + Format('%s.ExecQuery', [VarName]));
    S.Add(lS + Format('Do While Not %s.Eof', [VarName]));
    inc(Paragraph, 2);
    try
      lS := StringOfChar(' ', Paragraph);
      S.Add(lS + Format('%s = GS.GetAnalyticStr(%s)', [FBlockName, VarName]));
      inherited;
      S.Add(lS + Format('%s.Next', [VarName]));
    finally
      dec(Paragraph, 2);
      lS := StringOfChar(' ', Paragraph);
    end;
    S.Add(lS + 'Loop');
    S.Add(lS + Format('Creator.DestroyObject(%s)', [VarName]));
  finally
    ReleaseVarName(VarName);
  end;
end;

procedure TAccountCycleBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;

  FAccount := ReadStringFromStream(Stream);
  FAnalise := ReadStringFromStream(Stream);
  FFilter := ReadStringFromStream(Stream);
  FBeginDate := ReadStringFromStream(Stream);
  FEndDate := ReadStringFromStream(Stream);
  if FStreamVersion > 0 then
    FGroupBy := ReadStringFromStream(Stream);
  if FStreamVersion > 2 then
  begin
    FSelect := ReadStringFromStream(Stream);
    FFrom := ReadStringFromStream(Stream);
    FWhere := ReadStringFromStream(Stream);
    FOrder := ReadStringFromStream(Stream);
  end;
end;

procedure TAccountCycleBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;

  SaveStringToStream(FAccount, Stream);
  SaveStringToStream(FAnalise, Stream);
  SaveStringToStream(FFilter, Stream);
  SaveStringToStream(FBeginDate, Stream);
  SaveStringToStream(FEndDate, Stream);
  SaveStringToStream(FGroupBy, Stream);

  SaveStringToStream(FSelect, Stream);
  SaveStringToStream(FFrom, Stream);
  SaveStringToStream(FWhere, Stream);
  SaveStringToStream(FOrder, Stream);
end;

function TAccountCycleBlock.FotterPrefix: string;
begin
  Result := 'Конец цикла';
end;

procedure TAccountCycleBlock.GenerateSQL(S: TStrings; Paragraph: Integer;
  SQLName: string);
var
  lS: string;
  pS: TStrings;
  I: Integer;
  FieldName, Value: string;
begin
  pS := TStringList.Create;
  try
    lS := StringOfChar(' ', Paragraph);
    ParseString(FAnalise, pS);
    S.Add(lS + Format('%s.SQL.Text = "SELECT DISTINCT " & _', [SQLName]));
    if pS.Count = 0 then
      S.Add(lS + '   "a.alias, e.accountkey as account " & _')
    else
    begin
      S.Add(lS + '   "a.alias, e.accountkey as account, " & _');
      for I := 0 to pS.Count - 1 do
      begin
        if (pS.Count - I > 1) or (FSelect > '') then
          S.Add(lS + '   "e.' + pS[I] + ', " & _')
        else
          S.Add(lS + '   "e.' + pS[I] + ' " & _');
      end;
    end;
    if FSelect <> '' then
    begin
      S.Add(lS + Format('   "%s " & _', [FSelect]));
    end;
    S.Add(lS + ' "FROM " & _');
    S.Add(lS + '   "ac_entry e join ac_account a on e.accountkey = a.id " & _');
    S.Add(lS + '   "join ac_record r on r.id = e.recordkey " & _ ');
    if FFrom <> '' then
    begin
      S.Add(lS + Format('   "%s " & _', [FFrom]));
    end;
    S.Add(lS + ' "WHERE " & _');

    S.Add(lS + Format('   "e.accountkey in (" & %s & ") " ', [GetAccountList(Paragraph)]));

    if FFilter > '' then
    begin
      pS.Clear;
      ParseString(FFilter, pS);
      for I := 0 to pS.Count - 1 do
      begin
        GetNameAndValue(pS[I], FieldName, Value);
        S.Add(lS + Format('%s.SQL.Add("and ")', [SQLName]));
        if Pos('GS.', value) = 0 then
        begin
          {$IFDEF GEDEMIN}
          S.Add(lS + Format('%s.SQL.Add("e.%s = " & %s)', [SQLName, FieldName, Value]));
          {$ENDIF}
        end else
        begin
          S.Add(lS + Format('If %s = "" Then ', [Value]));
          S.Add(lS + Format('  %s.SQL.Add("e.%s IS NULL ")', [SQLName, FieldName]));
          S.Add(lS + 'Else');
          S.Add(lS + Format('  %s.SQL.Add("e.%s = " & %s)', [SQLName, FieldName, Value]));
          S.Add(lS + 'End If');
        end;
      end;
    end;

    S.Add(lS + 'If IBLogin.IsHolding Then ');
    S.Add(lS + Format('  %s.SQL.Text = %s.SQL.Text & " AND r.companykey IN (" & IBLogin.HoldingList & ") " ',
      [SQLName, SQLName]));
    S.Add(lS + 'Else');
    S.Add(lS + Format('  %s.SQL.Text = %s.SQL.Text & " AND r.companykey IN (" & Cstr(IBLogin.Companykey) & ") " ',
      [SQLName, SQLName]));
    S.Add(lS + 'End If');

    S.Add(lS + Format('%s.SQL.Text = %s.SQL.Text & " AND BIN_AND(BIN_OR(r.aview, 1), " & Cstr(IBLogin.InGroup) & ") <> 0 " ',
      [SQLName, SQLName]));

    if (BeginDate > '')  then
    begin
      S[S.Count - 1] := S[S.Count - 1] + ' + _';
      S.Add(lS + '   "AND e.entrydate >= :begindate "');
    end;

    if EndDate > '' then
    begin
      S[S.Count - 1] := S[S.Count - 1] + ' + _';
      S.Add(lS + '   "AND e.entrydate <= :enddate"');
    end;

    if FWhere <> '' then
    begin
      S.Add(lS + Format('%s.SQL.Add("AND %s ")', [SQLName, FWhere]));
    end;

    if (FGroupBy > '') then
    begin
      pS.Clear;
      ParseString(FGroupBy, pS);
      if pS.Count > 0 then
      begin
        S.Add(lS + Format('%s.SQL.Add(" ORDER BY ")', [SQLName]));
        for I := 0 to pS.Count - 1 do
        begin
          if (I = pS.Count - 1) and (FOrder = '') then
            S.Add(lS + Format('%s.SQL.Add("   e.%s ") ', [SQLName, pS[I]]))
          else
            S.Add(lS + Format('%s.SQL.Add("   e.%s, ") ', [SQLName, pS[I]]));
        end;
        if FOrder > '' then
        begin
          S.Add(lS + Format('%s.SQL.Add("   %s ")', [SQLName, FOrder]));
        end;
      end;
    end else
    begin
      if FOrder > '' then
      begin
        S.Add(lS + Format('%s.SQL.Add(" ORDER BY ")', [SQLName]));
        S.Add(lS + Format('%s.SQL.Add("   %s ")', [SQLName, FOrder]));
      end;
    end;
  finally
    pS.Free;
  end;
end;

function TAccountCycleBlock.GetAccountList(Paragraph: Integer): string;
var
  S: TStrings;
  I: Integer;
  lS: String;
begin
  Result := '';
  S := TStringList.Create;
  try
    ParseString(FAccount, S);
    lS := StringOfChar(' ', Paragraph + 2);
    for I := 0 to S.Count - 1 do
    begin
      if Result > '' then Result := Result + '& ", " & ';
  {$IFDEF GEDEMIN}
      if StrToInt(S[I]) < cstUserIDStart then
        Result := Result + '"' + S[I] + '" '
      else
        Result := Result + '_'#13#10 + lS + 'CStr(gdcBaseManager.GetIdByRUIDString("' +
          gdcBaseManager.GetRUIDStringByID(StrToInt(S[I])) + '")) ';
    {$ENDIF}
    end;
  finally
    S.Free;
  end;
end;

function TAccountCycleBlock.GetAnalise: string;
begin
  Result := FAnalise;
end;

function TAccountCycleBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrAccountCycleFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

procedure TAccountCycleBlock.GetVars(const Strings: TStrings);
var
  S: TStrings;
  I: Integer;
begin
  if Strings.IndexOfName(FBlockName) = - 1 then
    if FLocalName = '' then
      Strings.AddObject(FBlockName + Format('=Текущие значения счёта и аналитик цикла по счёту %s', [FBlockName]), Self)
    else
      Strings.AddObject(FBlockName + Format('=Текущие значения счёта и аналитик цикла по счёту %s', [FLocalName]), Self);

  S := TStringList.Create;
  try
    S.Text := StringReplace(FAnalise, ';', #13#10, [rfReplaceAll]);
    for I := 0 to S.Count - 1 do
    begin
      Strings.AddObject(FBlockName + Format('_%s=Текущие значение поля %s цикла по счёту %s', [S[I], S[I], Header]), Self);
    end;
  finally
    S.Free;
  end;
end;

function TAccountCycleBlock.GetVarScript(const VarName: string): string;
var
  S: TStrings;
  I: Integer;
  FieldName: String;
begin
  if VarName = FBlockName then
  begin
    Result := FBlockName;
    Exit;
  end;

  S := TStringList.Create;
  try
    S.Text := StringReplace(FAnalise, ';', #13#10, [rfReplaceAll]);
    for I := 0 to S.Count - 1 do
    begin
      if Format('%s_%s', [FBlockName, S[I]]) = VarName then
      begin
        FieldName := S[I];
        Result := 'sql_' + FBlockName + Format('.FieldByName("%s").Value', [FieldName]);
        Exit;
      end;
    end;
  finally
    S.Free;
  end;
end;

function TAccountCycleBlock.HeaderPrefix: string;
begin
  Result := 'Цикл по счёту';
end;

class function TAccountCycleBlock.NamePrefix: string;
begin
  Result := 'AccountCycle';
end;

procedure TAccountCycleBlock.SetAccount(const Value: string);
begin
  FAccount := Value;
end;

procedure TAccountCycleBlock.SetAnalise(const Value: string);
begin
  FAnalise := Value;
end;

procedure TAccountCycleBlock.SetBeginDate(const Value: string);
begin
  FBeginDate := Value;
end;

procedure TAccountCycleBlock.SetEndDate(const Value: string);
begin
  FEndDate := Value;
end;

procedure TAccountCycleBlock.SetFilter(const Value: string);
begin
  FFilter := Value;
end;

procedure TAccountCycleBlock.SetFrom(const Value: string);
begin
  FFrom := Value;
end;

procedure TAccountCycleBlock.SetGroupBy(const Value: String);
begin
  FGroupBy := Value;
end;

procedure TAccountCycleBlock.SetOrder(const Value: string);
begin
  FOrder := Value;
end;

procedure TAccountCycleBlock.SetSelect(const Value: string);
begin
  FSelect := Value;
end;

procedure TAccountCycleBlock.SetWhere(const Value: string);
begin
  FWhere := Value;
end;

{ TEntryBlock }

function TEntryBlock.CanHasOwnBlock: boolean;
begin
  Result := False;
end;

function TEntryBlock.HasFootter: boolean;
begin
  Result := False;
end;

function TEntryBlock.HeaderPrefix: string;
begin
  Result := 'Проводка'
end;

function TEntryBlock.HeaderColor: TColor;
begin
  Result := RGB(206, 244, 251);
end;

class function TEntryBlock.NamePrefix: string;
begin
  Result := 'Entry';
end;

function TEntryBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrEntryEditFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

procedure TEntryBlock.SetAnalCredit(const Value: string);
begin
  FAnalCredit := Value;
end;

procedure TEntryBlock.SetAnalDebit(const Value: string);
begin
  FAnalDebit := Value;
end;

procedure TEntryBlock.SetCredit(const Value: string);
begin
  FCredit := Value;
end;

procedure TEntryBlock.SetCurr(const Value: Integer);
begin
  FCurr := Value;
end;

procedure TEntryBlock.SetDebit(const Value: string);
begin
  FDebit := Value;
end;

procedure TEntryBlock.SetSum(const Value: string);
begin
  FSum := Value;
end;

procedure TEntryBlock.SetSumCurr(const Value: string);
begin
  FSumCurr := Value;
end;

procedure TEntryBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  FDebit := ReadStringFromStream(Stream);
  FCredit := ReadStringFromStream(Stream);
  FAnalDebit := ReadStringFromStream(Stream);
  FAnalCredit := ReadStringFromStream(Stream);
  FSum := ReadStringFromStream(Stream);
  if FStreamVersion < 8 then
  begin
    Stream.ReadBuffer(FCurr, SizeOf(FCurr));
    FCurrRUID := gdcBaseManager.GetRUIDStringById(FCurr);
  end;
  FSumCurr := ReadStringFromStream(Stream);
  FBeginDate := ReadStringFromStream(Stream);
  FEndDate := ReadStringFromStream(Stream);
  FEntryDate := ReadStringFromStream(Stream);
  if FStreamVersion >= 8 then
  begin
    FCurrRUID := ReadStringFromStream(Stream);
  end;
  if FStreamVersion >= 11 then
  begin
    FSaveEmpty := ReadBooleanFromStream(Stream);
  end;

  if FStreamVersion > 14 then
  begin
    FDescription := ReadStringFromStream(Stream);
  end;

  if FStreamVersion > 17 then
  begin
    FEntryDescription := ReadStringFromStream(Stream);
  end;

  if FStreamVersion > 15 then
  begin
    FQuantityDebit := ReadStringFromStream(Stream);
    FQuantityCredit := ReadStringFromStream(Stream);
  end;

  if FStreamVersion > 16 then
  begin
    FSumEQ := ReadStringFromStream(Stream);
  end;

end;

procedure TEntryBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;

  SaveStringToStream(FDebit, Stream);
  SaveStringToStream(FCredit, Stream);
  SaveStringToStream(FAnalDebit, Stream);
  SaveStringToStream(FAnalCredit, Stream);
  SaveStringToStream(FSum, Stream);
  SaveStringToStream(FSumCurr, Stream);
  SaveStringToStream(FBeginDate, Stream);
  SaveStringToStream(FEndDate, Stream);
  SaveStringToStream(FEntryDate, Stream);
  SaveStringToStream(FCurrRuid, Stream);
  SaveBooleanToStream(FSaveEmpty, Stream);
  SaveStringToStream(FDescription, Stream);
  SaveStringToStream(FEntryDescription, Stream);
  SaveStringToStream(FQuantityDebit, Stream);
  SaveStringToStream(FQuantityCredit, Stream);
  SaveStringToStream(FSumEQ, Stream);
end;

procedure TEntryBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
  SQLName, gdcSRName, SumName, CurrSumName, EqSumName: string;
  pS: TStringList;
  I: Integer;
  A: TStrings;
  AName, AValue: string;
const
  cCreateSQl = 'Set %s = Designer.CreateObject(null, "TIBSQL", "")';
  cCreateSR = 'Set %s = Designer.CreateObject(null, "TgdcAcctSimpleRecord", "")';
  cDidActivateTr = '%s = Not %s.Transaction.InTransaction';
  cActivateTr = 'If %s Then %s.Transaction.StartTransaction';
  cSetSQLTransaction = '%s.Transaction = %s.Transaction';
  cSQLExecQuery = '%s.ExecQuery';
  cSQLClose = '%s.Close';
  cSetInsertSQLText1 = '%s.SQL.Text = "INSERT INTO AC_AUTOENTRY (id, entrykey, trrecordkey, begindate, " & _';
  cSetInsertSQLText2 = '  "enddate, debitaccount, creditaccount) VALUES((SELECT gen_id(gd_g_unique, 1) FROM rdb$database), :entrykey, " & _';
  cSetInsertSQLText3 = '  ":trrecordkey, :begindate, :enddate, :debit, :credit)"';
  cSetDebitField = '%s.DebitEntryLine.FieldByName("%s").AsString = %s';
  cSetCreditField = '%s.CreditEntryLine.FieldByName("%s").AsString = %s';

  function GetAccount(Alias: string): string;
  var
    P: Integer;
    Name: string;
    Id: Integer;
  begin
    Result := '';
    P := Pos('.ACCOUNT', UpperCase(Alias));
    if P > 0 then
    begin
      Name := Trim(System.Copy(Alias, P + 1, Length(Alias) - P));
      Result := Format('GS.GetAnalyticValue(%s, "%s")', [Trim(System.Copy(Alias, 1, P - 1)), Name]);
    end else
    begin
      if CheckRUID(alias) then
      begin
        Id := gdcBaseManager.GetIdByRUIDString(Alias);
        if id < cstUserIDStart then
          Result := IntTostr(Id)
        else
          Result := Format('gdcBaseManager.GetIdByRUIDString("%s")',
            [Alias]);
      end else
        //Передана переменная
        Result := Alias;
    end;
  end;
begin
  lS := StringOfChar(' ', Paragraph);
  SQLName := 'SimpleRecordSQL';
  gdcSRName := 'gdcSimpleRecord';
  SumName := GetVarName('Sum');
  CurrSumName := GetVarName('CurrSum');
  EQSumName := GetVarName('EQSum');
  try
    S.Add(lS + '''Вычисляем сумму проводки');
    if Sum <> '' then
      //Сумма в НДЕ
      S.Add(lS + Format('%s = %s', [SumName, GenerateExpression(FSum)]));

    if FSumCurr <> '' then
      //Сумма в валюте
      S.Add(lS + Format('%s = %s', [CurrSumName, GenerateExpression(FSumCurr)]));
    if FSumEQ <> '' then
      //Сумма в эквиваленте
      S.Add(lS + Format('%s = %s', [EQSumName, GenerateExpression(FSumEQ)]));

    if not FSaveEmpty then
    begin
      S.Add(lS + Format('If (%s <> 0) Or (%s <> 0) Or (%s <> 0) Then', [SumName, CurrSumName, EQSumName]));
      Inc(Paragraph, 2);
      lS := StringOfChar(' ', Paragraph);
    end;

    S.Add(lS + Format('%s.Insert', [gdcSRName]));
    S.Add('');
    S.Add(lS + Format('%s.FieldByName("recorddate").AsDateTime = %s',
      [gdcSRName, GenerateExpression(EntryDate)]));
    S.Add(lS + Format('%s.FieldByName("DELAYED").AsInteger = 1', [gdcSRName]));
    S.Add(lS + Format('%s.FieldByName("transactionkey").AsInteger = TransactionKey',
      [gdcSRName]));

    S.Add(lS + 'If Assigned(gdcTaxDesignDate) Then');
    S.Add(lS + Format('  %s.FieldByName("documentkey").AsInteger = %s',
      [gdcSRName, 'gdcTaxDesignDate.FieldByName("id").AsInteger']));
    S.Add(lS + Format('  %s.FieldByName("masterdockey").AsInteger = %s',
      [gdcSRName, 'gdcTaxDesignDate.FieldByName("id").AsInteger']));
    S.Add(lS + 'End If');
//-------------------------------------

    if FEntryDescription <> '' then
      S.Add(lS + Format('%s.FieldByName("description").Value = %s',
         [gdcSRName, GenerateExpression(FEntryDescription)]));

    pS := TStringList.Create;
    try
      S.Add(lS + Format('%s.DebitEntryLine.Edit', [gdcSRName]));
      S.Add(lS + Format('%s.DebitEntryLine.FieldByName("accountkey").AsInteger = %s',
        [gdcSRName, GetAccount(FDebit)]));

      //Аналитика пл дебету
      if FAnalDebit > '' then
      begin
        S.Add(lS + '''Присвоение значения аналитик');
        A := TStringList.Create;
        try
          A.Text := FAnalDebit;
          for I := 0 to A.Count - 1 do
          begin
            AName := A.Names[I];
            AValue := A.Values[AName];

            if CheckRUID(AValue) then
              S.Add(lS + Format('%s.DebitEntryLine.FieldByName("%s").AsInteger = gdcBaseManager.GetIdByRuidString("%s")',
                [gdcSRName, AName, AValue]))
            else
              S.Add(lS + Format('%s.DebitEntryLine.FieldByName("%s").AsVariant = %s',
                [gdcSRName, AName, GenerateExpression(AValue)]))
          end;
        finally
          A.Free;
        end;
      end;

      if FQuantityDebit > '' then
      begin
        S.Add(lS + '''Присвоение количественных показателей по дебету');
        A := TStringList.Create;
        try
          A.Text := FQuantityDebit;
          for I := 0 to A.Count - 1 do
          begin
            AName := A.Names[I];
            AValue := A.Values[AName];
            S.Add(lS + Format('%s.DebitEntryLine.gdcQuantity.Insert', [gdcSRName]));

            if CheckRUID(AName) then
              S.Add(lS + Format('%s.DebitEntryLine.gdcQuantity.FieldByName("valuekey").AsInteger = gdcBaseManager.GetIdByRuidString("%s")',
                [gdcSRName, AName]))
            else
              S.Add(lS + Format('%s.DebitEntryLine.gdcQuantity.FieldByName("valuekey").AsVariant = %s',
                [gdcSRName, GenerateExpression(AName)]));

            S.Add(lS + Format('%s.DebitEntryLine.gdcQuantity.FieldByName("quantity").AsVariant = %s',
              [gdcSRName ,GenerateExpression(AValue)]));

            S.Add(lS + Format('%s.DebitEntryLine.gdcQuantity.Post', [gdcSRName]));
          end;
        finally
          A.Free;
        end;
      end;

      S.Add(lS + Format('%s.CreditEntryLine.Edit', [gdcSRName]));
      S.Add(lS + Format('%s.CreditEntryLine.FieldByName("accountkey").AsInteger = %s',
        [gdcSRName, GetAccount(FCredit)]));

      //Аналитика по кредиту
      if FAnalCredit > '' then
      begin
        S.Add(lS + '''Присвоение значения аналитик');
        A := TStringList.Create;
        try
          A.Text := FAnalCredit;
          for I := 0 to A.Count - 1 do
          begin
            AName := A.Names[I];
            AValue := A.Values[AName];

            if CheckRUID(AValue) then
              S.Add(lS + Format('%s.CreditEntryLine.FieldByName("%s").AsInteger = gdcBaseManager.GetIdByRuidString("%s")',
                [gdcSRName, AName, AValue]))
            else
              S.Add(lS + Format('%s.CreditEntryLine.FieldByName("%s").AsVariant = %s',
                [gdcSRName, AName, GenerateExpression(AValue)]))
          end;
        finally
          A.Free;
        end;
      end;

      if FQuantityCredit > '' then
      begin
        S.Add(lS + '''Присвоение количественных показателей по кредиту');
        A := TStringList.Create;
        try
          A.Text := FQuantityCredit;
          for I := 0 to A.Count - 1 do
          begin
            AName := A.Names[I];
            AValue := A.Values[AName];
            S.Add(lS + Format('%s.CreditEntryLine.gdcQuantity.Insert', [gdcSRName]));

            if CheckRUID(AName) then
              S.Add(lS + Format('%s.CreditEntryLine.gdcQuantity.FieldByName("valuekey").AsInteger = gdcBaseManager.GetIdByRuidString("%s")',
                [gdcSRName, AName]))
            else
              S.Add(lS + Format('%s.CreditEntryLine.gdcQuantity.FieldByName("valuekey").AsVariant = %s',
                [gdcSRName, GenerateExpression(AName)]));

            S.Add(lS + Format('%s.CreditEntryLine.gdcQuantity.FieldByName("quantity").AsVariant = %s',
              [gdcSRName ,GenerateExpression(AValue)]));

            S.Add(lS + Format('%s.CreditEntryLine.gdcQuantity.Post', [gdcSRName]));
          end;
        finally
          A.Free;
        end;
      end;

      if Sum <> '' then
      begin
        //Сумма в НДЕ
        S.Add(lS + Format('%s.FieldByName("debitncu").AsCurrency = %s',
          [gdcSRName, SumName]));
      end;

      if FSumCurr <> '' then
      begin
        //Сумма в валюте
        {$IFDEF GEDEMIN}
        S.Add(lS + Format('%s.DebitEntryLine.FieldByName("debitcurr").AsCurrency = %s',
          [gdcSRName, CurrSumName]));

        if FCurrRUID > '' then
        begin
          if CheckRUID(FCurrRUID) then
            S.Add(lS + Format('%s.DebitEntryLine.FieldByName("currkey").AsInteger = gdcBaseManager.GetIdByRUIDString("%s")', [gdcSRName, FCurrRUID]))
          else
            S.Add(lS + Format('%s.DebitEntryLine.FieldByName("currkey").AsVariant = %s', [gdcSRName, GenerateExpression(FCurrRUID)]));
        end;

        S.Add(lS + Format('%s.CreditEntryLine.FieldByName("creditcurr").AsCurrency = %s',
          [gdcSRName, CurrSumName]));
        if FCurrRUID > '' then
        begin
          if CheckRUID(FCurrRUID) then
            S.Add(lS + Format('%s.CreditEntryLine.FieldByName("currkey").AsInteger = gdcBaseManager.GetIdByRUIDString("%s")', [gdcSRName, FCurrRUID]))
          else
            S.Add(lS + Format('%s.CreditEntryLine.FieldByName("currkey").AsVariant = %s', [gdcSRName, GenerateExpression(FCurrRUID)]));
        end;
        {$ENDIF}
      end;

      if FSumEQ <> '' then
      begin
        //Сумма в Эквиваленте
        S.Add(lS + Format('%s.FieldByName("debiteq").AsCurrency = %s',
          [gdcSRName, EQSumName]));
      end;

      S.Add(lS + Format('%s.Post', [gdcSRName]));

      S.Add(lS + '');
      S.Add(lS + '''Заносим информацию во вспомогательную таблицу');
      S.Add('');
      S.Add(lS + Format('%s.ParamByName("trrecordkey").AsInteger = TrRecordKey',
        [SQLName]));
      S.Add(lS + Format('%s.ParamByName("begindate").AsDateTime = %s',
        [SQLName, GenerateExpression(BeginDate)]));
      S.Add(lS + Format('%s.ParamByName("enddate").AsDateTime = %s',
        [SQLName, GenerateExpression(EndDate)]));
      S.Add('');
      S.Add(lS + Format('%s.ParamByName("entrykey").AsInteger = %s.DebitEntryLine.FieldByName("id").AsInteger',
        [SQLName, gdcSRName]));
      S.Add(lS + Format('%s.ParamByName("debit").AsInteger = %s',
        [SQLName, GetAccount(FDebit)]));
      S.Add(lS + Format('%s.ParamByName("credit").AsInteger = %s',
        [SQLName, GetAccount(FCredit)]));

      S.Add(lS + 'SimpleRecordSQL.ExecQuery');
      S.Add(lS + 'SimpleRecordSQL.Close');

      S.Add(lS + Format('%s.ParamByName("entrykey").AsInteger = %s.CreditEntryLine.FieldByName("id").AsInteger',
        [SQLName, gdcSRName]));
      S.Add(lS + 'SimpleRecordSQL.ExecQuery');
      S.Add(lS + 'SimpleRecordSQL.Close');

      if not FSaveEmpty then
      begin
        Dec(Paragraph, 2);
        lS := StringOfChar(' ', Paragraph);
        S.Add(lS + 'End If');
      end;
    finally
      pS.Free;
    end;
  finally
    ReleaseVarName(SumName);
    ReleaseVarName(CurrSumName);
  end;
end;

procedure TEntryBlock.SetBeginDate(const Value: string);
begin
  FBeginDate := Value;
end;

procedure TEntryBlock.SetEndDate(const Value: string);
begin
  FEndDate := Value;
end;

procedure TEntryBlock.SetEntryDate(const Value: string);
begin
  FEntryDate := Value;
end;

constructor TEntryBlock.Create(AOwner: TComponent);
begin
  inherited;

  FBeginDate := 'BeginDate';
  FEndDate := 'EndDate';
  FEntryDate := 'EntryDate';
end;

function TEntryBlock.HasBody: boolean;
begin
  Result := False;
end;


function TEntryBlock.GetBlockSetMember: TBlockSetMember;
begin
  Result := bsEntry
end;

procedure TEntryBlock.SetCurrRUID(const Value: string);
begin
  FCurrRUID := Value;
end;

procedure TEntryBlock.SetSaveEmpty(const Value: boolean);
begin
  FSaveEmpty := Value;
end;

procedure TEntryBlock.SetEntryDescription(const Value: string);
begin
  FEntryDescription := Value;
end;

procedure TEntryBlock.SetQuantityCredit(const Value: string);
begin
  FQuantityCredit := Value;
end;

procedure TEntryBlock.SetQuantityDebit(const Value: string);
begin
  FQuantityDebit := Value;
end;

procedure TEntryBlock.SetSumEq(const Value: String);
begin
  FSumEq := Value;
end;

{ TUserBlock }

function TUserBlock.CanHasOwnBlock: boolean;
begin
  Result := False;
end;

constructor TUserBlock.Create(AOwner: TComponent);
begin
  inherited;

  if FScript = nil then FScript := TStringList.Create;
end;

destructor TUserBlock.Destroy;
begin
  FScript.Free;

  inherited;
end;

procedure TUserBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;

  FScript.Text := ReadStringFromStream(Stream);
end;

procedure TUserBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;

  SaveStringToStream(FScript.Text, Stream);
end;

function TUserBlock.FotterPrefix: string;
begin
  Result := 'конец';
end;

procedure TUserBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
  I: Integer;
begin
  lS := StringOfChar(' ', Paragraph);
  for I := 0 to FScript.Count - 1 do
    S.Add(lS + GenerateExpression(FScript[I]));
end;

function TUserBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrUserEditFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TUserBlock.HeaderColor: TColor;
begin
  Result := $B6B8E4;
end;

function TUserBlock.HeaderPrefix: string;
begin
  Result := 'Пользовательский блок'
end;

class function TUserBlock.NamePrefix: string;
begin
  Result := 'Usr';
end;

procedure TUserBlock.SetScript(const Value: TStrings);
begin
  FScript.Assign(Value);
end;

function TUserBlock.HasBody: boolean;
begin
  Result := False;
end;

procedure TUserBlock.DoReleaseVars;
var
  S: TStrings;
  I: Integer;
begin
  S := TStringList.Create;
  try
    S.Text := Reserved;
    for I := 0 to S.Count - 1 do
    begin
      ReleaseVarName(S[I]);
    end;
  finally
    S.Free;
  end;
end;

procedure TUserBlock.DoReserveVars;
var
  S: TStrings;
  I: Integer;
begin
  S := TStringList.Create;
  try
    S.Text := Reserved;
    for I := 0 to S.Count - 1 do
    begin
      AddVarName(S[I]);
    end;
  finally
    S.Free;
  end;
end;

function TUserBlock.GetEditDialogForm: TdlgBaseEditForm;
begin
  Result := inherited GetEditDialogForm;
  if Result is TdlgEditForm then
  begin
    Result.EditFrame.Constraints.MaxHeight := 0;
    Result.EditFrame.Constraints.MaxWidth := 0;
    Result.AutoSize := False;
    Result.Width:= 580;
    Result.Height:= 440;
    TdlgEditForm(Result).bOk.Default := False;
  end;
end;

procedure TUserBlock.GetVars(const Strings: TStrings);
var
  S: TStrings;
  I: Integer;
begin
  S := TStringList.Create;
  try
    S.Text := Reserved;
    for I := 0 to S.Count - 1 do
    begin
      Strings.AddObject(S[I] + Format('=Переменная пользовательского блока ''%s''', [Header]), Self);
    end;
  finally
    S.Free;
  end;
  inherited;
end;

{ TScriptBlock }

procedure TScriptBlock.AdjustClientRect(var Rect: TRect);
begin
  Rect := Bounds(-HorzScrollBar.Position, -VertScrollBar.Position,
    Max(HorzScrollBar.Range, ClientWidth), Max(ClientHeight,
    VertScrollBar.Range));
  inherited AdjustClientRect(Rect);
end;

procedure TScriptBlock.AdjustSize;
begin
  if not (csLoading in ComponentState) and HandleAllocated then
  begin
    SetWindowPos(Handle, 0, 0, 0, Width, Height, SWP_NOACTIVATE or SWP_NOMOVE or
      SWP_NOZORDER);
    RequestAlign;
  end;
end;

procedure TScriptBlock.AlignControls(AControl: TControl; var ARect: TRect);
begin
  CalcAutoRange;
  inherited AlignControls(AControl, ARect);
end;

function TScriptBlock.AutoScrollEnabled: Boolean;
begin
  Result := not AutoSize and not (DockSite and UseDockManager);
end;

procedure TScriptBlock.AutoScrollInView(AControl: TControl);
begin
  if (AControl <> nil) and not (csLoading in AControl.ComponentState) and
    not (csLoading in ComponentState) then
    ScrollInView(AControl);
end;

procedure TScriptBlock.CalcAutoRange;
begin
  if FAutoRangeCount <= 0 then
  begin
    HorzScrollBar.CalcAutoRange;
    VertScrollBar.CalcAutoRange;
  end;
end;

function TScriptBlock.CanCopy: Boolean;
begin
  Result := False;
end;

function TScriptBlock.CanDrop(Source: TObject; X, Y: Integer): boolean;
begin
  Result := Source is TFunctionBlock and CanEdit
end;

procedure TScriptBlock.ChangeScale(M, D: Integer);
begin
  ScaleScrollBars(M, D);
  inherited ChangeScale(M, D);
end;

procedure TScriptBlock.CMBiDiModeChanged(var Message: TMessage);
var
  Save: Integer;
begin
  Save := Message.WParam;
  try
    { prevent inherited from calling Invalidate & RecreateWnd }
    inherited;
  finally
    Message.wParam := Save;
  end;
  if HandleAllocated then
  begin
    HorzScrollBar.ChangeBiDiPosition;
    UpdateScrollBars;
  end;
end;

constructor TScriptBlock.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHorzScrollBar := TVisualBlockScrollBar.Create(Self, sbHorizontal);
  FVertScrollBar := TVisualBlockScrollBar.Create(Self, sbVertical);
  FAutoScroll := True;
  Align := alClient;
  FCannotDelete := True;
end;

procedure TScriptBlock.CreateNew(X, Y: Integer);
begin
  if (NeedCreate <> nil) and (NeedCreate = TFunctionBlock) then
    inherited;
end;

procedure TScriptBlock.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do
  begin
    style := style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

procedure TScriptBlock.CreateWnd;
begin
  inherited CreateWnd;
  //! Scroll bars don't move to the Left side of a TScrollingWinControl when the
  //! WS_EX_LEFTSCROLLBAR flag is set and InitializeFlatSB is called.
  //! A call to UnInitializeFlatSB does nothing.
  if not SysLocale.MiddleEast then InitializeFlatSB(Handle);
  UpdateScrollBars;
end;

procedure TScriptBlock.DblClick;
begin

end;

destructor TScriptBlock.Destroy;
begin
  FHorzScrollBar.Free;
  FVertScrollBar.Free;
  inherited Destroy;
end;

procedure TScriptBlock.DisableAutoRange;
begin
  Inc(FAutoRangeCount);
end;

procedure TScriptBlock.DoFlipChildren;
var
  Loop: Integer;
  TheWidth: Integer;
  ScrollBarActive: Boolean;
  FlippedList: TList;
begin
  FlippedList := TList.Create;
  try
    TheWidth := ClientWidth;
    with HorzScrollBar do begin
      ScrollBarActive := (IsScrollBarVisible) and (TheWidth < Range);
      if ScrollBarActive then
      begin
        TheWidth := Range;
        Position := 0;
      end;
    end;

    for Loop := 0 to ControlCount - 1 do with Controls[Loop] do
    begin
      FlippedList.Add(Controls[Loop]);
      Left := TheWidth - Width - Left;
    end;
    
    { Allow controls that have associations to realign themselves }  
    for Loop := 0 to FlippedList.Count - 1 do
      TControl(FlippedList[Loop]).Perform(CM_ALLCHILDRENFLIPPED, 0, 0);

    if ScrollBarActive then
      HorzScrollBar.ChangeBiDiPosition;
  finally
     FlippedList.Free;
  end;
end;

procedure TScriptBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  I: Integer;
begin
  IncludeList.Clear;
  NameList.Clear;
  inherited DoGenerate(S, Paragraph);
  for i := 0 to IncludeList.Count - 1 do
    S.Add(IncludeList[I]);
end;

procedure TScriptBlock.DoGenerateBeginComment(S: TStrings;
  Paragraph: Integer);
var
  lS: String;
begin
  lS := StringOfChar(' ', Paragraph);
  S.Add(lS + '''Данная скрипт-функция создана конструктором функций.');
  S.Add(lS + '''Все изменения, произведённые вручную, будут потеряны');
  S.Add(lS + '''при следующей генерации скрипт-функции.');
end;

procedure TScriptBlock.DoGenerateEndComment(S: TStrings;
  Paragraph: Integer);
begin

end;

procedure TScriptBlock.EnableAutoRange;
begin
  if FAutoRangeCount > 0 then
  begin
    Dec(FAutoRangeCount);
    if (FAutoRangeCount = 0) and (FHorzScrollBar.Visible or
      FVertScrollBar.Visible) then CalcAutoRange;
  end;
end;

function TScriptBlock.GetBodyRect: TRect;
begin
  Result := inherited GetClientRect;
  AdjustClientRect(Result);
end;

function TScriptBlock.GetCannotDelete: boolean;
begin
  Result := True;
end;

function TScriptBlock.GetClientRect: TRect;
begin
  Windows.GetClientRect(Handle, Result);
end;

procedure TScriptBlock.MouseMove(Shift: TShiftState; X, Y: Integer);
begin

end;

procedure TScriptBlock.Paint;
var
  P: TPoint;
  R: TRect;
begin
  R := GetClientRect;
  AdjustClientRect(R);
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(R);
  P := Point(cGridDelta, cGridDelta);
  while P.x < R.Right do
  begin
    while P.y < R.Bottom do
    begin
      Canvas.Pixels[P.x, P.y] := clBlack;
      P.y := P.y + cGridDelta;
    end;
    P.y := cGridDelta;
    P.x := P.x + cGridDelta;
  end;
end;

procedure TScriptBlock.PopupMenu(X, Y: Integer);
begin

end;

procedure TScriptBlock.ScaleScrollBars(M, D: Integer);
begin
  if M <> D then
  begin
    if not (csLoading in ComponentState) then
    begin
      HorzScrollBar.FScaled := True;
      VertScrollBar.FScaled := True;
    end;
    HorzScrollBar.Position := 0;
    VertScrollBar.Position := 0;
    if not FAutoScroll then
    begin
      with HorzScrollBar do if FScaled then Range := MulDiv(Range, M, D);
      with VertScrollBar do if FScaled then Range := MulDiv(Range, M, D);
    end;
  end;
  HorzScrollBar.FScaled := False;
  VertScrollBar.FScaled := False;
end;

procedure TScriptBlock.ScrollInView(AControl: TControl);
var
  Rect: TRect;
begin
  if AControl = nil then Exit;
  Rect := AControl.ClientRect;
  Dec(Rect.Left, HorzScrollBar.Margin);
  Inc(Rect.Right, HorzScrollBar.Margin);
  Dec(Rect.Top, VertScrollBar.Margin);
  Inc(Rect.Bottom, VertScrollBar.Margin);
  Rect.TopLeft := ScreenToClient(AControl.ClientToScreen(Rect.TopLeft));
  Rect.BottomRight := ScreenToClient(AControl.ClientToScreen(Rect.BottomRight));
  if Rect.Left < 0 then
    with HorzScrollBar do Position := Position + Rect.Left
  else if Rect.Right > ClientWidth then
  begin
    if Rect.Right - Rect.Left > ClientWidth then
      Rect.Right := Rect.Left + ClientWidth;
    with HorzScrollBar do Position := Position + Rect.Right - ClientWidth;
  end;
  if Rect.Top < 0 then
    with VertScrollBar do Position := Position + Rect.Top
  else if Rect.Bottom > ClientHeight then
  begin
    if Rect.Bottom - Rect.Top > ClientHeight then
      Rect.Bottom := Rect.Top + ClientHeight;
    with VertScrollBar do Position := Position + Rect.Bottom - ClientHeight;
  end;
end;

procedure TScriptBlock.SetAutoScroll(Value: Boolean);
begin
  if FAutoScroll <> Value then
  begin
    FAutoScroll := Value;
    if Value then CalcAutoRange else
    begin
      HorzScrollBar.Range := 0;
      VertScrollBar.Range := 0;
    end;
  end;
end;

procedure TScriptBlock.SetHorzScrollBar(Value: TVisualBlockScrollBar);
begin
  FHorzScrollBar.Assign(Value);
end;

procedure TScriptBlock.SetParent(AParent: TWinControl);
begin
  if AParent <> nil then
    BoundsRect := AParent.ClientRect;
  inherited;
  AdjustSize;
end;

procedure TScriptBlock.SetVertScrollBar(Value: TVisualBlockScrollBar);
begin
  FVertScrollBar.Assign(Value);
end;

procedure TScriptBlock.UpdateScrollBars;
begin
  if not FUpdatingScrollBars and HandleAllocated then
    try
      FUpdatingScrollBars := True;
      if FVertScrollBar.NeedsScrollBarVisible then
      begin
        FHorzScrollBar.Update(False, True);
        FVertScrollBar.Update(True, False);
      end
      else if FHorzScrollBar.NeedsScrollBarVisible then
      begin
        FVertScrollBar.Update(False, True);
        FHorzScrollBar.Update(True, False);
      end
      else
      begin
        FVertScrollBar.Update(False, False);
        FHorzScrollBar.Update(True, False);
      end;
    finally
      FUpdatingScrollBars := False;
    end;
end;

procedure TScriptBlock.WMHScroll(var Message: TWMHScroll);
begin
  if (Message.ScrollBar = 0) and FHorzScrollBar.Visible then
    FHorzScrollBar.ScrollMessage(Message) else
    inherited;
end;

procedure TScriptBlock.WMSize(var Message: TWMSize);
begin
  Inc(FAutoRangeCount);
  try
    inherited;
  finally
    Dec(FAutoRangeCount);
  end;
  FUpdatingScrollBars := True;
  try
    CalcAutoRange;
  finally
    FUpdatingScrollBars := False;
  end;
  if FHorzScrollBar.Visible or FVertScrollBar.Visible then
    UpdateScrollBars;
end;

procedure TScriptBlock.WMVScroll(var Message: TWMVScroll);
begin
  if (Message.ScrollBar = 0) and FVertScrollBar.Visible then
    FVertScrollBar.ScrollMessage(Message) else
    inherited;
end;

{ TVisualBlockScrollBar }

procedure TVisualBlockScrollBar.Assign(Source: TPersistent);
begin
  if Source is TControlScrollBar then
  begin
    Visible := TControlScrollBar(Source).Visible;
    Range := TControlScrollBar(Source).Range;
    Position := TControlScrollBar(Source).Position;
    Increment := TControlScrollBar(Source).Increment;
    Exit;
  end;
  inherited Assign(Source);
end;

procedure TVisualBlockScrollBar.CalcAutoRange;
var
  I: Integer;
  NewRange, AlignMargin: Integer;

  procedure ProcessHorz(Control: TControl);
  begin
    if Control.Visible then
      case Control.Align of
        alLeft, alNone:
          if (Control.Align = alLeft) or (Control.Anchors * [akLeft, akRight] = [akLeft]) then
            NewRange := Max(NewRange, Position + Control.Left + Control.Width);
        alRight: Inc(AlignMargin, Control.Width);
      end;
  end;

  procedure ProcessVert(Control: TControl);
  begin
    if Control.Visible then
      case Control.Align of
        alTop, alNone:
          if (Control.Align = alTop) or (Control.Anchors * [akTop, akBottom] = [akTop]) then
            NewRange := Max(NewRange, Position + Control.Top + Control.Height);
        alBottom: Inc(AlignMargin, Control.Height);
      end;
  end;

begin
  if FControl.FAutoScroll then
  begin
    if FControl.AutoScrollEnabled then
    begin
      NewRange := 0;
      AlignMargin := 0;
      for I := 0 to FControl.ControlCount - 1 do
        if Kind = sbHorizontal then
          ProcessHorz(FControl.Controls[I]) else
          ProcessVert(FControl.Controls[I]);
      DoSetRange(NewRange + AlignMargin + Margin);
    end
    else DoSetRange(0);
  end;
end;


procedure TVisualBlockScrollBar.ChangeBiDiPosition;
begin
  if Kind = sbHorizontal then
    if IsScrollBarVisible then
      if not FControl.UseRightToLeftScrollBar then
        Position := 0
      else
        Position := Range;
end;

function TVisualBlockScrollBar.ControlSize(ControlSB,
  AssumeSB: Boolean): Integer;
var
  BorderAdjust: Integer;

  function ScrollBarVisible(Code: Word): Boolean;
  var
    Style: Longint;
  begin
    Style := WS_HSCROLL;
    if Code = SB_VERT then Style := WS_VSCROLL;
    Result := GetWindowLong(FControl.Handle, GWL_STYLE) and Style <> 0;
  end;

  function Adjustment(Code, Metric: Word): Integer;
  begin
    Result := 0;
    if not ControlSB then
      if AssumeSB and not ScrollBarVisible(Code) then
        Result := -(GetSystemMetrics(Metric) - BorderAdjust)
      else if not AssumeSB and ScrollBarVisible(Code) then
        Result := GetSystemMetrics(Metric) - BorderAdjust;
  end;

begin
  BorderAdjust := Integer(GetWindowLong(FControl.Handle, GWL_STYLE) and
    (WS_BORDER or WS_THICKFRAME) <> 0);
  if Kind = sbVertical then
    Result := FControl.ClientHeight + Adjustment(SB_HORZ, SM_CXHSCROLL) else
    Result := FControl.ClientWidth + Adjustment(SB_VERT, SM_CYVSCROLL);
end;

constructor TVisualBlockScrollBar.Create(AControl: TScriptBlock;
  AKind: TScrollBarKind);
begin
  inherited Create;
  FControl := AControl;
  FKind := AKind;
  FPageIncrement := 80;
  FIncrement := FPageIncrement div 10;
  FVisible := True;
  FDelay := 10;
  FLineDiv := 4;
  FPageDiv := 12;
  FColor := clBtnHighlight;
  FParentColor := True;
  FUpdateNeeded := True;
end;

procedure TVisualBlockScrollBar.DoSetRange(Value: Integer);
begin
  FRange := Value;
  if FRange < 0 then FRange := 0;
  FControl.UpdateScrollBars;
end;

function TVisualBlockScrollBar.GetScrollPos: Integer;
begin
  Result := 0;
  if Visible then Result := Position;
end;

function TVisualBlockScrollBar.IsIncrementStored: Boolean;
begin
  Result := not Smooth;
end;

function TVisualBlockScrollBar.IsRangeStored: Boolean;
begin
  Result := not FControl.AutoScroll;
end;

function TVisualBlockScrollBar.IsScrollBarVisible: Boolean;
var
  Style: Longint;
begin
  Style := WS_HSCROLL;
  if Kind = sbVertical then Style := WS_VSCROLL;
  Result := (Visible) and
            (GetWindowLong(FControl.Handle, GWL_STYLE) and Style <> 0);
end;


function TVisualBlockScrollBar.NeedsScrollBarVisible: Boolean;
begin
  Result := FRange > ControlSize(False, False);
end;

procedure TVisualBlockScrollBar.ScrollMessage(var Msg: TWMScroll);
var
  Incr, FinalIncr, Count: Integer;
  CurrentTime, StartTime, ElapsedTime: Longint;

  function GetRealScrollPosition: Integer;
  var
    SI: TScrollInfo;
    Code: Integer;
  begin
    SI.cbSize := SizeOf(TScrollInfo);
    SI.fMask := SIF_TRACKPOS;
    Code := SB_HORZ;
    if FKind = sbVertical then Code := SB_VERT;
    Result := Msg.Pos;
    if FlatSB_GetScrollInfo(FControl.Handle, Code, SI) then
      Result := SI.nTrackPos;
  end;

begin
  with Msg do
  begin
    if FSmooth and (ScrollCode in [SB_LINEUP, SB_LINEDOWN, SB_PAGEUP, SB_PAGEDOWN]) then
    begin
      case ScrollCode of
        SB_LINEUP, SB_LINEDOWN:
          begin
            Incr := FIncrement div FLineDiv;
            FinalIncr := FIncrement mod FLineDiv;
            Count := FLineDiv;
          end;
        SB_PAGEUP, SB_PAGEDOWN:
          begin
            Incr := FPageIncrement;
            FinalIncr := Incr mod FPageDiv;
            Incr := Incr div FPageDiv;
            Count := FPageDiv;
          end;
      else
        Count := 0;
        Incr := 0;
        FinalIncr := 0;
      end;
      CurrentTime := 0;
      while Count > 0 do
      begin
        StartTime := GetCurrentTime;
        ElapsedTime := StartTime - CurrentTime;
        if ElapsedTime < FDelay then Sleep(FDelay - ElapsedTime);
        CurrentTime := StartTime;
        case ScrollCode of
          SB_LINEUP: SetPosition(FPosition - Incr);
          SB_LINEDOWN: SetPosition(FPosition + Incr);
          SB_PAGEUP: SetPosition(FPosition - Incr);
          SB_PAGEDOWN: SetPosition(FPosition + Incr);
        end;
        FControl.Update;
        Dec(Count);
      end;
      if FinalIncr > 0 then
      begin
        case ScrollCode of
          SB_LINEUP: SetPosition(FPosition - FinalIncr);
          SB_LINEDOWN: SetPosition(FPosition + FinalIncr);
          SB_PAGEUP: SetPosition(FPosition - FinalIncr);
          SB_PAGEDOWN: SetPosition(FPosition + FinalIncr);
        end;
      end;
    end
    else
      case ScrollCode of
        SB_LINEUP: SetPosition(FPosition - FIncrement);
        SB_LINEDOWN: SetPosition(FPosition + FIncrement);
        SB_PAGEUP: SetPosition(FPosition - ControlSize(True, False));
        SB_PAGEDOWN: SetPosition(FPosition + ControlSize(True, False));
        SB_THUMBPOSITION:
            if FCalcRange > 32767 then
              SetPosition(GetRealScrollPosition) else
              SetPosition(Pos);
        SB_THUMBTRACK:
          if Tracking then
            if FCalcRange > 32767 then
              SetPosition(GetRealScrollPosition) else
              SetPosition(Pos);
        SB_TOP: SetPosition(0);
        SB_BOTTOM: SetPosition(FCalcRange);
        SB_ENDSCROLL: begin end;
      end;
  end;
end;

procedure TVisualBlockScrollBar.SetButtonSize(Value: Integer);
const
  SysConsts: array[TScrollBarKind] of Integer = (SM_CXHSCROLL, SM_CXVSCROLL);
var
  NewValue: Integer;
begin
  if Value <> ButtonSize then
  begin
    NewValue := Value;
    if NewValue = 0 then
      Value := GetSystemMetrics(SysConsts[Kind]);
    FButtonSize := Value;
    FUpdateNeeded := True;
    FControl.UpdateScrollBars;
    if NewValue = 0 then
      FButtonSize := 0;
  end;
end;

procedure TVisualBlockScrollBar.SetColor(Value: TColor);
begin
  if Value <> Color then
  begin
    FColor := Value;
    FParentColor := False;
    FUpdateNeeded := True;
    FControl.UpdateScrollBars;
  end;
end;

procedure TVisualBlockScrollBar.SetParentColor(Value: Boolean);
begin
  if ParentColor <> Value then
  begin
    FParentColor := Value;
    if Value then Color := clBtnHighlight;
  end;
end;

procedure TVisualBlockScrollBar.SetPosition(Value: Integer);
var
  Code: Word;
  Form: TCustomForm;
  OldPos: Integer;
begin
  if csReading in FControl.ComponentState then
    FPosition := Value
  else
  begin
    if Value > FCalcRange then Value := FCalcRange
    else if Value < 0 then Value := 0;
    if Kind = sbHorizontal then
      Code := SB_HORZ else
      Code := SB_VERT;
    if Value <> FPosition then
    begin
      OldPos := FPosition;
      FPosition := Value;
      if Kind = sbHorizontal then
        FControl.ScrollBy(OldPos - Value, 0) else
        FControl.ScrollBy(0, OldPos - Value);
      if csDesigning in FControl.ComponentState then
      begin
        Form := GetParentForm(FControl);
        if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
      end;
    end;
    if FlatSB_GetScrollPos(FControl.Handle, Code) <> FPosition then
      FlatSB_SetScrollPos(FControl.Handle, Code, FPosition, True);
  end;
end;

procedure TVisualBlockScrollBar.SetRange(Value: Integer);
begin
  FControl.FAutoScroll := False;
  FScaled := True;
  DoSetRange(Value);
end;

procedure TVisualBlockScrollBar.SetSize(Value: Integer);
const
  SysConsts: array[TScrollBarKind] of Integer = (SM_CYHSCROLL, SM_CYVSCROLL);
var
  NewValue: Integer;
begin
  if Value <> Size then
  begin
    NewValue := Value;
    if NewValue = 0 then
      Value := GetSystemMetrics(SysConsts[Kind]);
    FSize := Value;
    FUpdateNeeded := True;
    FControl.UpdateScrollBars;
    if NewValue = 0 then
      FSize := 0;
  end;
end;

procedure TVisualBlockScrollBar.SetStyle(Value: TScrollBarStyle);
begin
  if Style <> Value then
  begin
    FStyle := Value;
    FUpdateNeeded := True;
    FControl.UpdateScrollBars;
  end;
end;

procedure TVisualBlockScrollBar.SetThumbSize(Value: Integer);
begin
  if Value <> ThumbSize then
  begin
    FThumbSize := Value;
    FUpdateNeeded := True;
    FControl.UpdateScrollBars;
  end;
end;

procedure TVisualBlockScrollBar.SetVisible(Value: Boolean);
begin
  FVisible := Value;
  FControl.UpdateScrollBars;
end;

procedure TVisualBlockScrollBar.Update(ControlSB, AssumeSB: Boolean);
type
  TPropKind = (pkStyle, pkButtonSize, pkThumbSize, pkSize, pkBkColor);
const
  Props: array[TScrollBarKind, TPropKind] of Integer = (
    { Horizontal }
    (WSB_PROP_HSTYLE, WSB_PROP_CXHSCROLL, WSB_PROP_CXHTHUMB, WSB_PROP_CYHSCROLL,
     WSB_PROP_HBKGCOLOR),
    { Vertical }
    (WSB_PROP_VSTYLE, WSB_PROP_CYVSCROLL, WSB_PROP_CYVTHUMB, WSB_PROP_CXVSCROLL,
     WSB_PROP_VBKGCOLOR));
  Kinds: array[TScrollBarKind] of Integer = (WSB_PROP_HSTYLE, WSB_PROP_VSTYLE);
  Styles: array[TScrollBarStyle] of Integer = (FSB_REGULAR_MODE,
    FSB_ENCARTA_MODE, FSB_FLAT_MODE);
var
  Code: Word;
  ScrollInfo: TScrollInfo;

  procedure UpdateScrollProperties(Redraw: Boolean);
  begin
    FlatSB_SetScrollProp(FControl.Handle, Props[Kind, pkStyle], Styles[Style], Redraw);
    if ButtonSize > 0 then
      FlatSB_SetScrollProp(FControl.Handle, Props[Kind, pkButtonSize], ButtonSize, False);
    if ThumbSize > 0 then
      FlatSB_SetScrollProp(FControl.Handle, Props[Kind, pkThumbSize], ThumbSize, False);
    if Size > 0 then
      FlatSB_SetScrollProp(FControl.Handle, Props[Kind, pkSize], Size, False);
    FlatSB_SetScrollProp(FControl.Handle, Props[Kind, pkBkColor],
      ColorToRGB(Color), False);
  end;

begin
  FCalcRange := 0;
  Code := SB_HORZ;
  if Kind = sbVertical then Code := SB_VERT;
  if Visible then
  begin
    FCalcRange := Range - ControlSize(ControlSB, AssumeSB);
    if FCalcRange < 0 then FCalcRange := 0;
  end;
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_ALL;
  ScrollInfo.nMin := 0;
  if FCalcRange > 0 then
    ScrollInfo.nMax := Range else
    ScrollInfo.nMax := 0;
  ScrollInfo.nPage := ControlSize(ControlSB, AssumeSB) + 1;
  ScrollInfo.nPos := FPosition;
  ScrollInfo.nTrackPos := FPosition;
  UpdateScrollProperties(FUpdateNeeded);
  FUpdateNeeded := False;
  FlatSB_SetScrollInfo(FControl.Handle, Code, ScrollInfo, True);
  SetPosition(FPosition);
  FPageIncrement := (ControlSize(True, False) * 9) div 10;
  if Smooth then FIncrement := FPageIncrement div 10;
end;

{ TAccountFunctionBlock }

procedure TEntryFunctionBlock.DeleteOldEntry(S: TStrings;
  Paragraph: Integer);
var
  SQLName: string;
  lS: string;
begin
  lS := StringOfChar(' ', Paragraph );
  
  SQLName := GetVarName('SQL');
  try
    S.Add(lS + '''Удаляем предыдущие проводки');
    S.Add(lS + Format('Set %s = Creator.GetObject(null, "TIBSQL", "")', [SQLName]));
    S.Add(lS + Format('%s.Transaction = %s', [SQLName, 'Transaction']));

    S.Add(lS + Format('%s.SQL.Text = "execute block (begindate DATE = :begindate, enddate DATE = :enddate, trrecordkey INTEGER = :trrecordkey)" & vbCrLf & _', [SQLName]));
    S.Add(lS + '  "as " & vbCrLf & _');
    S.Add(lS + '  "  declare id integer;" & vbCrLf & _');
    S.Add(lS + '  "begin" & vbCrLf & _');
    S.Add(lS + '  "  for" & vbCrLf & _');
    S.Add(lS + '  "    SELECT e.documentkey FROM ac_autoentry ae JOIN ac_entry e ON e.id = ae.entrykey" & vbCrLf & _');
    S.Add(lS + '  "    WHERE ae.trrecordkey = :trrecordkey AND" & vbCrLf & _');
    S.Add(lS + '  "     ae.begindate >= :begindate AND ae.enddate <= :enddate AND" & vbCrLf & _');
    S.Add(lS + '  "      e.companykey IN (" & IbLogin.HoldingList & ")" & vbCrLf & _');
    S.Add(lS + '  "    into :id" & vbCrLf & _');
    S.Add(lS + '  "  do" & vbCrLf & _');
    S.Add(lS + '  "   DELETE FROM gd_document  WHERE id = :id;" & vbCrLf & _');
    S.Add(lS + '  "end" ');
    S.Add(lS + Format('%s.ParamByName("trrecordkey").AsInteger = TrRecordKey', [SQLName]));
    S.Add(lS + Format('%s.ParamByName("begindate").AsDateTime = %s', [SQLName, 'BeginDate']));
    S.Add(lS + Format('%s.ParamByName("enddate").AsDateTime = %s', [SQLName, 'EndDate']));
    S.Add(lS + Format('%s.ExecQuery', [SQLName]));
    S.Add(lS + Format('Creator.DestroyObject(%s)', [SQLName]));
  finally
    ReleaseVarName(SQLName);
  end;
end;

procedure TEntryFunctionBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  if FStreamVersion > 4 then
  begin
    FTransactionRUID := ReadStringFromStream(Stream);
    FTrRecordRUID := ReadStringFromStream(Stream);
  end;

  if FStreamVersion > 13 then
  begin
    FNoDeleteLastResults := ReadBooleanFromStream(Stream)
  end;
end;

procedure TEntryFunctionBlock.DoReleaseVars;
begin
  ReleaseVarName('TrRecordKey');
  ReleaseVarName('TransactionKey');
  ReleaseVarName('SimpleRecordSQL');
  ReleaseVarName('gdcSimpleRecord');
  ReleaseVarName('ViewEntryForm');
  ReleaseVarName('usrg_gdcAcctEntryRegister1');
  ReleaseVarName('ViewEntryFormSQL');
end;

procedure TEntryFunctionBlock.DoReserveVars;
begin
  AddVarName('TrRecordKey');
  AddVarName('TransactionKey');
  AddVarName('SimpleRecordSQL');
  AddVarName('gdcSimpleRecord');
  AddVarName('ViewEntryForm');
  AddVarName('usrg_gdcAcctEntryRegister1');
  AddVarName('ViewEntryFormSQL');
end;

procedure TEntryFunctionBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FTransactionRUID, Stream);
  SaveStringToStream(FTrRecordRUID, Stream);
  SaveBooleanToStream(FNoDeleteLastResults, Stream);
end;

procedure TEntryFunctionBlock.GenerateGdcClass(S: TStrings;
  Paragraph: Integer);
var
  lS: string;
begin
  lS := StringOfChar(' ', Paragraph );

  S.Add(lS + 'Set SimpleRecordSQL = Creator.GetObject(null, "TIBSQL", "")');
  S.Add(lS + 'SimpleRecordSQL.Transaction = Transaction');
  S.Add(lS + 'SimpleRecordSQL.SQL.Text = "INSERT INTO AC_AUTOENTRY (id, entrykey, trrecordkey, begindate, " & _');
  S.Add(lS + '  "enddate, debitaccount, creditaccount) VALUES((SELECT gen_id(gd_g_unique, 1) FROM rdb$database), :entrykey, " & _');
  S.Add(lS + '  ":trrecordkey, :begindate, :enddate, :debit, :credit)"');
  S.Add('');
  S.Add(lS + 'Set gdcSimpleRecord = Creator.GetObject(null, "TgdcAcctSimpleRecord", "")');
  S.Add(lS + 'gdcSimpleRecord.Transaction = Transaction');
  S.Add(lS + 'gdcSimpleRecord.ReadTransaction = Transaction');
  S.Add(lS + 'gdcSimpleRecord.Open');
  S.Add('');
end;

function TEntryFunctionBlock.GetBlockSetMember: TBlockSetMember;
begin
  Result := bsEntry
end;

function TEntryFunctionBlock.GetEditFrame: TFrameClass;
begin
{$IFDEF GEDEMIN}
  Result := TfrEntryFunctionEditFrame;
  {$ELSE}
  Result := nil;
{$ENDIF}
end;

procedure TEntryFunctionBlock.InitFinalScript;
var
  S: TStringList;
  SQLName: string;
  lS: String;
begin
  S := TStringList.Create;
  try
    lS := '';
    SQLName := 'ViewEntryFormSQL';
    S.Add(lS + Format('Set %s = Creator.GetObject(null, "TIBSQL", "")', [SQLName]));
    S.Add(lS + Format('%s.Transaction = %s', [SQLName, 'Transaction']));
    S.Add('');
    S.Add(lS + 'Set ViewEntryForm = Creator.GetObject(null, "usrf_acc_viewdelayedentry", "")');
    S.Add(lS + Format('%s.SQL.Text = "SELECT description FROM ac_trrecord WHERE id = :id"', [SQLName]));
    S.Add(lS + Format('%s.ParamByName("id").AsInteger = TrRecordKey', [SQLName]));
    S.Add(lS + Format('%s.ExecQuery', [SQLName]));
    S.Add(lS + Format('ViewEntryForm.Caption = "Результаты расчёта автоматической операции ''" & %s.FieldByName("description").AsString & "''"', [SQLName]));
    S.Add(lS + Format('%s.Close',  [SQLName]));
    S.Add(lS + 'Set usrg_gdcAcctEntryRegister1 = ViewEntryForm.FindComponent("usrg_gdcAcctViewEntryRegister1")');
    S.Add(lS + Format('usrg_gdcAcctEntryRegister1.Transaction = %s', ['Transaction']));
    S.Add(lS + Format('usrg_gdcAcctEntryRegister1.ReadTransaction = %s', ['Transaction']));
    S.Add(lS + 'usrg_gdcAcctEntryRegister1.ExtraConditions.Clear');
    S.Add(lS + 'usrg_gdcAcctEntryRegister1.ExtraConditions.Add("z.delayed = 1 AND r.id IN (SELECT entrykey FROM ac_autoentry WHERE trrecordkey = :trrecordkey)")');
    S.Add(lS + 'usrg_gdcAcctEntryRegister1.QueryFiltered = False');
    S.Add(lS + 'usrg_gdcAcctEntryRegister1.ParamByName("trrecordkey").AsInteger = trrecordkey');
    S.Add(lS + 'usrg_gdcAcctEntryRegister1.Open');
    S.Add(lS + 'Result = ViewEntryForm.ShowModal = vbOk');
    S.Add(lS + 'Creator.DestroyObject(ViewEntryForm)');
    S.Add(lS + Format('Creator.DestroyObject(%s)', [SQLName]));

    FFinalScript := S.Text;
  finally
    S.Free;
  end;
end;

procedure TEntryFunctionBlock.InitInitScript;
begin
  inherited
end;

{ TAccountPopupMenu }

procedure TAccountPopupMenu.DoPopup(Sender: TObject);
begin
  FillAccountMenuItem(Self, Items, FOnClickAccount, FOnClickAccountCycle, FOnClickExpr);
  inherited;
end;

procedure TAccountPopupMenu.SetOnClickAccount(const Value: TNotifyEvent);
begin
  FOnClickAccount := Value;
end;

procedure TAccountPopupMenu.SetOnClickAccountCycle(
  const Value: TNotifyEvent);
begin
  FOnClickAccountCycle := Value;
end;

procedure TAccountPopupMenu.SetOnClickExpr(const Value: TNotifyEvent);
begin
  FOnClickExpr := Value;
end;

{ TAnalPopupMenu }

constructor TAnalPopupMenu.Create(AOwner: TComponent);
begin
  inherited;

  AutoHotkeys := maManual;
end;

procedure TAnalPopupMenu.DoPopup(Sender: TObject);
begin
  FillAnaliticMenuItem(Self, Items, FOnClickAnal, FOnClickCustomAnal, FOnClickAnalCycle, FOnExpr);

  inherited;
end;

procedure TAnalPopupMenu.Popup(X, Y: Integer);
begin
  inherited;
end;

procedure TAnalPopupMenu.SetOnClickAnal(const Value: TNotifyEvent);
begin
  FOnClickAnal := Value;
end;

procedure TAnalPopupMenu.SetOnClickAnalCycle(const Value: TNotifyEvent);
begin
  FOnClickAnalCycle := Value;
end;

procedure TAnalPopupMenu.SetOnClickCustomAnal(const Value: TNotifyEvent);
begin
  FOnClickCustomAnal := Value;
end;

procedure TAnalPopupMenu.SetOnExpr(const Value: TNotifyEvent);
begin
  FOnExpr := Value;
end;

{ TEntryCycleBlock }

procedure TEntryCycleBlock.GenerateSQL(S: TStrings; Paragraph: Integer;
  SQLName: string);
var
  lS: string;
  pS: TStrings;
  I: Integer;
  FieldName, Value: string;
begin
  pS := TStringList.Create;
  try
    lS := StringOfChar(' ', Paragraph);
    ParseString(FAnalise, pS);
    S.Add(lS + Format('%s.SQL.Text = "SELECT DISTINCT " & _', [SQLName]));
    S.Add(lS + '   "a.alias, e.accountkey as account, e.debitncu, e.creditncu, " & _');
    if pS.Count = 0 then
        S.Add(lS + '   "e.debitcurr, e.creditcurr, e.entrydate, e.debiteq, e.crediteq " & _')
    else
    begin
        S.Add(lS + '   " e.debitcurr, e.creditcurr, e.entrydate, e.debiteq, e.crediteq, " & _');
      for I := 0 to pS.Count - 1 do
      begin
        if (pS.Count - I > 1) or (FSelect > '') then
          S.Add(lS + '   "e.' + pS[I] + ', " & _')
        else
          S.Add(lS + '   "e.' + pS[I] + ' " & _');
      end;
    end;
    if FSelect <> '' then
    begin
      S.Add(lS + Format('   "%s " & _', [FSelect]));
    end;
    S.Add(lS + ' "FROM " & _');
    S.Add(lS + '   "ac_entry e join ac_account a on e.accountkey = a.id " & _');
    S.Add(lS + '   "join ac_record r on r.id = e.recordkey " & _ ');
    if FFrom <> '' then
    begin
      S.Add(lS + Format('   "%s " & _', [FFrom]));
    end;
    S.Add(lS + ' "WHERE " & _');
    S.Add(lS + Format('   "e.accountkey in (" & %s & ") " ', [GetAccountList(Paragraph)]));

    if FFilter > '' then
    begin
      pS.Clear;
      ParseString(FFilter, pS);
      for I := 0 to pS.Count - 1 do
      begin
        GetNameAndValue(pS[I], FieldName, Value);
        S.Add(lS + Format('%s.SQL.Add("and ")', [SQLName]));
        if Pos('GS.', value) = 0 then
        begin
          {$IFDEF GEDEMIN}
          S.Add(lS + Format('%s.SQL.Add("e.%s = " & %s)', [SQLName, FieldName, Value]));
          {$ENDIF}
        end else
        begin
          S.Add(lS + Format('If %s = "" Then ', [Value]));
          S.Add(lS + Format('  %s.SQL.Add("e.%s IS NULL ")', [SQLName, FieldName]));
          S.Add(lS + 'Else');
          S.Add(lS + Format('  %s.SQL.Add("e.%s = " & %s)', [SQLName, FieldName, Value]));
          S.Add(lS + 'End If');
        end;
      end;
    end;

    S.Add(lS + 'If IBLogin.IsHolding then ');
    S.Add(lS + Format('  %s.SQL.Add(" and r.companykey in (" & IBLogin.HoldingList & ") " )',
      [SQLName, SQLName]));
    S.Add(lS + 'Else');
    S.Add(lS + Format('  %s.SQL.Add(" and r.companykey in (" & Cstr(IBLogin.Companykey) & ") ") ',
      [SQLName, SQLName]));
    S.Add(lS + 'End If');

    S.Add(lS + Format('%s.SQL.Add(" and G_SEC_TEST(r.aview, " & Cstr(IBLogin.InGroup) & ") <> 0 " )',
      [SQLName, SQLName]));

    if (BeginDate > '')  then
      S.Add(lS + Format('%s.SQL.Add("and e.entrydate >= :begindate ")', [SQLName]));

    if EndDate > '' then
      S.Add(lS + Format('%s.SQL.Add("and e.entrydate <= :enddate")', [SQLName]));

    if FWhere <> '' then
    begin
      S.Add(lS + Format('%s.SQL.Add("and %s ")', [SQLName, FWhere]));
    end;

    if (FGroupBy > '') then
    begin
      pS.Clear;
      ParseString(FGroupBy, pS);
      if pS.Count > 0 then
      begin
        S.Add(lS + Format('%s.SQL.Add(" order by ")', [SQLName]));
        for I := 0 to pS.Count - 1 do
        begin
          if (I = pS.Count - 1) and (FOrder = '') then
            S.Add(lS + Format('%s.SQL.Add("   e.%s ") ', [SQLName, pS[I]]))
          else
            S.Add(lS + Format('%s.SQL.Add("   e.%s, ") ', [SQLName, pS[I]]));
        end;
        if FOrder > '' then
        begin
          S.Add(lS + Format('%s.SQL.Add("   %s ")', [SQLName, FOrder]));
        end;
      end;
    end else
    begin
      if FOrder > '' then
      begin
        S.Add(lS + Format('%s.SQL.Add(" order by ")', [SQLName]));
        S.Add(lS + Format('%s.SQL.Add("   %s ")', [SQLName, FOrder]));
      end;
    end;
  finally
    pS.Free;
  end;
end;

function TEntryCycleBlock.GetAnalise: string;
begin
  Result := inherited GetAnalise + ';ENTRYDATE;DEBITNCU;CREDITNCU;DEBITCURR;CREDITCURR;DEBITEQ;CREDITEQ';
end;

function TEntryCycleBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrAccountCycleFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

procedure TEntryCycleBlock.GetVars(const Strings: TStrings);
var
  S: TStrings;
  I: Integer;
begin
  if Strings.IndexOfName(FBlockName) = - 1 then
    if FLocalName = '' then
      Strings.AddObject(FBlockName + Format('=Текущие значения счета и аналитик цикла по проводкам %s', [FBlockName]), Self)
    else
      Strings.AddObject(FBlockName + Format('=Текущие значения счета и аналитик цикла по проводкам %s', [FLocalName]), Self);

  S := TStringList.Create;
  try
    S.Text := StringReplace(FAnalise + ';ENTRYDATE;DEBITNCU;CREDITNCU;DEBITCURR;CREDITCURR;CREDITEQ;DEBITEQ', ';', #13#10, [rfReplaceAll]);
    for I := 0 to S.Count - 1 do
    begin
      Strings.AddObject(FBlockName + Format('_%s=Текущие значение поля %s цикла по проводкам %s', [S[I], S[I], Header]), Self);
    end;
  finally
    S.Free;
  end;
end;

function TEntryCycleBlock.GetVarScript(const VarName: string): string;
var
  S: TStrings;
  I: Integer;
  FieldName: String;
begin
  if VarName = FBlockName then
  begin
    Result := FBlockName;
    Exit;
  end;

  S := TStringList.Create;
  try
    S.Text := StringReplace(FAnalise + ';ENTRYDATE;DEBITNCU;CREDITNCU;DEBITCURR;CREDITCURR;DEBITEQ;CREDITEQ', ';', #13#10, [rfReplaceAll]);
    for I := 0 to S.Count - 1 do
    begin
      if Format('%s_%s', [FBlockName, S[I]]) = VarName then
      begin
        FieldName := S[I];
        Result := 'sql_' + FBlockName + Format('.FieldByName("%s").Value', [FieldName]);
        Exit;
      end;
    end;
  finally
    S.Free;
  end;
end;

function TEntryCycleBlock.HeaderPrefix: string;
begin
  Result := 'Цикл по проводкам';
end;

class function TEntryCycleBlock.NamePrefix: string;
begin
  Result := 'EntryCycle';
end;

procedure TEntryCycleBlock.SetAnalise(const Value: string);
var
  pS: TStrings;
  I: Integer;
begin
  FAnalise := '';
  pS := TStringList.Create;
  try
    ParseString(Value, pS);
    for I := pS.Count - 1 downto 0 do
    begin
      if Pos(Trim(UpperCase(pS[I])), ';ENTRYDATE;DEBITNCU;CREDITNCU;DEBITCURR;CREDITCURR;DEBITEQ;CREDITEQ') = 0 then
      begin
        if FAnalise > '' then
          FAnalise := FAnalise + '; ';
        FAnalise := FAnalise + pS[i];
      end;
    end;
  finally
    pS.Free;
  end;
end;

{ TTaxVarBlock }

function TTaxVarBlock.HeaderPrefix: string;
begin
  Result := 'Позиция отчета';
end;

procedure TTaxVarBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
begin
  lS := FBlockName + ' = ' + GenerateExpression(Expression);
  S.Add(StringOfChar(' ', Paragraph) + lS);
  AddVarName(Name);
end;

function TTaxVarBlock.GetBlockSetMember: TBlockSetMember;
begin
  Result := bsTax
end;

function TTaxVarBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrTaxVarEditFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TTaxVarBlock.HeaderColor: TColor;
begin
  Result := RGB(221, 160, 221);
end;

class function TTaxVarBlock.NamePrefix: string;
begin
  Result := 'TaxVar'
end;

{ TTaxFunctionBlock }

procedure TTaxFunctionBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  FTaxActualRuid := ReadStringFromStream(Stream);
  FTaxNameRuid := ReadStringFromStream(Stream);
end;

procedure TTaxFunctionBlock.DoReleaseVars;
begin
  inherited;
  ReleaseVarName(ENG_GDCTAXDESIGNDATE);
  ReleaseVarName(ENG_GDCTAXRESULT);
  ReleaseVarName(ENG_ENTRYDATE);
end;

procedure TTaxFunctionBlock.DoReserveVars;
begin
  inherited;
  AddVarName(ENG_GDCTAXDESIGNDATE);
  AddVarName(ENG_GDCTAXRESULT);
  AddVarName(ENG_ENTRYDATE, RUS_ENTRYDATE);
end;

procedure TTaxFunctionBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FTaxActualRuid, Stream);
  SaveStringToStream(FTaxNameRuid, Stream);
end;

function TTaxFunctionBlock.GetBlockSetMember: TBlockSetMember;
begin
  Result := bsSimple
end;

procedure TTaxFunctionBlock.InitFinalScript;
begin
  FFinalScript := 'Result = True';
end;

procedure TTaxFunctionBlock.SetTaxActualRuid(const Value: string);
begin
  FTaxActualRuid := Value;
end;

procedure TTaxFunctionBlock.SetTaxNameRuid(const Value: string);
begin
  FTaxNameRuid := Value;
end;

procedure TTaxFunctionBlock._DoAfterGenerate(S: TStrings;
  Paragraph: Integer);
var
  I: Integer;
  V, V1: TStrings;
  B: TTaxVarBlock;
  lS: string;
  Flag: Boolean;
begin
  lS := StringOfChar(' ', Paragraph);
  V := TStringList.Create;
  try
    VarsList(V, Self);
    if V.Count > 0 then
    begin
      Flag := False;
      for I := 0 to BlockList.Count - 1 do
      begin
        if TObject(BlockList[i]) is TTaxVarBlock then
        begin
          B := TTaxVarBlock(BlockList[i]);
          if V.IndexOfName(B.BlockName) > - 1 then
          begin
            Flag := True;
            Break;
          end;
        end;
      end;

      if Flag then
      begin
        S.Add('''#include tax_AddTaxResult');
        S.Add('''Сохраняем налоги');
        S.Add(ls + 'If Result Then');

        S.Add(lS + '  Set gdcTaxResult = Creator.GetObject(null, "TgdcTaxResult", "")');
        S.Add(lS + '  gdcTaxResult.Transaction = Transaction');
        S.Add(lS + '  gdcTaxResult.ReadTransaction = Transaction');
        S.Add(lS + '  gdcTaxResult.SubSet = "ByDesignDate"');
        S.Add(lS + '  gdcTaxResult.ParamByName("taxdesigndatekey").AsInteger = gdcTaxDesignDate.Id');
        S.Add(lS + '  gdcTaxResult.Open');
        S.Add(lS + '  While Not gdcTaxResult.Eof ');
        S.Add(lS + '    gdcTaxResult.Delete');
        S.Add(lS + '  WEnd');

        V1 := TStringList.Create;
        try
          S.Add('');
          for I := 0 to BlockList.Count - 1 do
          begin
            if TObject(BlockList[i]) is TTaxVarBlock then
            begin
              B := TTaxVarBlock(BlockList[i]);
              if (V.IndexOfName(B.BlockName) > - 1) and (V1.IndexOf(B.BlockName) < 0) then
              begin
                S.Add(lS + Format('  Call tax_AddTaxResult(gdcTaxResult, gdcTaxDesignDate.id, _'#13#10 +
                  lS + '    "%s", EndDate, %s, "%s")',
                  [B.BlockName, B.BlockName, StringReplace(B.Description, #13#10, ' ', [rfReplaceAll])]));
                V1.Add(B.BlockName);
              end;
            end;
          end;
        finally
          V1.Free;
        end;
        S.Add(lS + 'End If')
      end;
    end;
  finally
    V.Free;
  end;

  inherited;
end;

procedure TEntryFunctionBlock.SetNoDeleteLastResults(const Value: Boolean);
begin
  FNoDeleteLastResults := Value;
end;

procedure TEntryFunctionBlock.SetTransactionRUID(const Value: string);
begin
  FTransactionRUID := Value;
end;

procedure TEntryFunctionBlock.SetTrRecordRUID(const Value: string);
begin
  FTrRecordRUID := Value;
end;

procedure TEntryFunctionBlock._DoAfterGenerate(S: TStrings;
  Paragraph: Integer);
var
  lS: string;
  SQLName: string;
  BS: TBlockSet;
begin
  lS := StringOfChar(' ', Paragraph);

  BS := [];
  GetBlockSet(BS);
  if BS * [bsCycle, bsEntry] <> [] then
  begin
    SQLName := GetVarName('SQL');
    try
      S.Add(lS + 'If Result Then');
      S.Add(lS + Format('  Set %s = Creator.GetObject(null, "TIBSQL", "")', [SQLName]));
      S.Add(lS + Format('  %s.Transaction = %s', [SQLName, 'Transaction']));
      S.Add(lS + Format('  %s.SQL.Text = "execute block (trrecordkey INTEGER = :trrecordkey, begindate DATE = :begindate, enddate DATE = :enddate)" & _', [SQLName]));
      S.Add(lS + '    "as " & _');
      S.Add(lS + '    "  declare id integer; " & _');
      S.Add(lS + '    "begin " & _');
      S.Add(lS + '    "  for " & _');
      S.Add(lS + '    "    SELECT e.recordkey FROM ac_autoentry ae JOIN ac_entry e ON e.id = ae.entrykey " & _');
      S.Add(lS + '    "    JOIN ac_record r ON r.id = e.recordkey WHERE ae.trrecordkey = :trrecordkey AND " & _');
      S.Add(lS + '    "    ae.begindate = :begindate AND ae.enddate = :enddate AND r.delayed = 1 AND " & _');
      S.Add(lS + '    "    r.companykey IN (" & IbLogin.HoldingList & ")" & _');
      S.Add(lS + '    "    into :id " & _');
      S.Add(lS + '    "  do " & _');
      S.Add(lS + '    "    UPDATE ac_record SET delayed = 0 WHERE id = :id; " & _');
      S.Add(lS + '    "end " ');
      S.Add(lS + Format('  %s.ParamByName("trrecordkey").AsInteger = TrRecordKey', [SQLName]));
      S.Add(lS + Format('  %s.ParamByName("begindate").AsDateTime = %s', [SQLName, 'BeginDate']));
      S.Add(lS + Format('  %s.ParamByName("enddate").AsDateTime = %s', [SQLName, 'EndDate']));
      S.Add(lS + Format('  %s.ExecQuery', [SQLName]));
      S.Add(lS + Format('  Creator.DestroyObject(%s)', [SQLName]));
      S.Add(lS + 'End If');
    finally
      ReleaseVarName(SQLName);
    end;
  end;

  S.Add(lS + 'GS.Transaction = nothing');

  S.Add(lS + 'If Result Then');
  S.Add(lS + '  Transaction.Commit');
  S.Add(lS + 'Else');
  S.Add(lS + '  Transaction.Rollback');
  S.Add(lS + 'End If');

  inherited;
end;

procedure TEntryFunctionBlock._DoBeforeGenerate(S: TStrings;
  Paragraph: Integer);
var
  lS: string;
  BS: TBlockSet;
begin
  lS := StringOfChar(' ', Paragraph );

  S.Add(lS + 'Result = False');
  S.Add(lS + 'Set Creator = new TCreator');
  S.Add(lS + 'Set Transaction = Creator.GetObject(null, "TIBTransaction", "")');
  S.Add(lS + 'Transaction.DefaultDataBase = gdcBaseManager.DataBase');
  S.Add(lS + 'Transaction.StartTransaction');
  S.Add(lS + 'GS.Transaction = Transaction');
  S.Add('');
  S.Add(lS + Format('TrRecordKey = gdcBaseManager.GetIDByRUIDString("%s")', [FTrRecordRUID]));
  S.Add(lS + Format('TransactionKey = gdcBaseManager.GetIDByRUIDString("%s")', [FTransactionRUID]));


  DoGenearteCallExceptFunction(S, Paragraph);

  if not NoDeleteLastResults then
    DeleteOldEntry(S, Paragraph);

  BS := [];
  GetBlockSet(BS);
  if BS * [bsEntry] <> [] then
  begin
    GenerateGdcClass(S, Paragraph);
  end;

  inherited;
end;

procedure TTaxFunctionBlock._DoBeforeGenerate(S: TStrings;
  Paragraph: Integer);
begin
  S.Add(StringOfChar(' ', Paragraph ) + 'EntryDate = EndDate');
  inherited;
  S.Add(StringOfChar(' ', Paragraph ) + 'Set gdcTaxDesignDate = Creator.GetObject(null, "TgdcTaxDesignDate", "")');
  S.Add(StringOfChar(' ', Paragraph ) + 'gdcTaxDesignDate.Transaction = Transaction');
  S.Add(StringOfChar(' ', Paragraph ) + 'gdcTaxDesignDate.ReadTransaction = Transaction');  
  S.Add(StringOfChar(' ', Paragraph ) + 'gdcTaxDesignDate.SubSet = "ByTaxActual,ByDocumentDate"');
  S.Add(StringOfChar(' ', Paragraph ) + Format('gdcTaxDesignDate.ParamByName("taxactualkey").AsInteger = gdcBaseManager.GetIdByRUIDString("%s")', [FTaxActualRuid]));
  S.Add(StringOfChar(' ', Paragraph ) + 'gdcTaxDesignDate.ParamByName("documentdate").AsDateTime = EndDate');
  S.Add(StringOfChar(' ', Paragraph ) + 'gdcTaxDesignDate.Open');
  S.Add(StringOfChar(' ', Paragraph ) + 'If gdcTaxDesignDate.Eof Then');
  S.Add(StringOfChar(' ', Paragraph ) + '  gdcTaxDesignDate.Insert');
  S.Add(StringOfChar(' ', Paragraph ) + Format('  gdcTaxDesignDate.FieldByName("taxactualkey").AsInteger = gdcBaseManager.GetIdByRUIDString("%s")', [FTaxActualRuid]));
  S.Add(StringOfChar(' ', Paragraph ) + Format('  gdcTaxDesignDate.FieldByName("taxnamekey").AsInteger = gdcBaseManager.GetIdByRUIDString("%s")', [FTaxNameRuid]));
  S.Add(StringOfChar(' ', Paragraph ) + '  gdcTaxDesignDate.FieldByName("documentdate").AsDateTime = EndDate');
  S.Add(StringOfChar(' ', Paragraph ) + '  gdcTaxDesignDate.Post');
  S.Add(StringOfChar(' ', Paragraph ) + 'End If');

end;

{ TTrEntryFunctionBlock }

procedure TTrEntryFunctionBlock.InitFinalScript;
begin
  FFinalScript := 'Result = True';
end;

procedure TTrEntryFunctionBlock._DoAfterGenerate(S: TStrings;
  Paragraph: Integer);
var
  lS: String;
  I: Integer;
begin
  ls := StringOfChar(' ', Paragraph);

  Inc(FEndScriptLine, 1);
  for I := 0 to ControlCount - 1 do
  begin
    TVisualBlock(Controls[I]).InsertLine(1);
  end;

  {$IFDEF GEDEMIN}
  if _CheckMaster then
  begin
    if DocumentPart = dcpLine then
    begin
      S.Insert(FCheckMasterInsertLine + 1, lS + 'If Assigned(gdcDocument.MasterSource) Then');
      S.Insert(FCheckMasterInsertLine + 2, lS + '  Set gdcDocumentHeader = gdcDocument.MasterSource.Dataset');
      S.Insert(FCheckMasterInsertLine + 3, lS + 'Else');
      S.Insert(FCheckMasterInsertLine + 4, lS + '  Set gdcDocumentHeader = Creator.GetObject(nil, "' + DocumentHead.Document.ClassName + '", "")');
      S.Insert(FCheckMasterInsertLine + 5, lS + '  gdcDocumentHeader.Transaction = Transaction');
      S.Insert(FCheckMasterInsertLine + 6, lS + '  gdcDocumentHeader.SubType = gdcDocument.SubType');
      S.Insert(FCheckMasterInsertLine + 7, lS + '  gdcDocumentHeader.Subset = "ByID"');
      S.Insert(FCheckMasterInsertLine + 8, lS + '  gdcDocumentHeader.ID = gdcDocument.FieldByName("parent").AsInteger');
      S.Insert(FCheckMasterInsertLine + 9, lS + '  gdcDocumentHeader.Open');
      S.Insert(FCheckMasterInsertLine + 10, lS + 'End If');
      Inc(FEndScriptLine, 11);
      for I := 0 to ControlCount - 1 do
      begin
        TVisualBlock(Controls[I]).InsertLine(11);
      end;
    end;
  end;
  {$ENDIF}
end;

procedure TTrEntryFunctionBlock._DoBeforeGenerate(S: TStrings;
  Paragraph: Integer);
var
  lS: string;
begin
  _CheckMaster := False;

  lS := StringOfChar(' ', Paragraph );
  S.Add(lS + 'Dim IsZero, Result, BeginDate, EndDate, EntryDate, Transaction, Creator');
  S.Add(lS + '');
  S.Add(lS + 'IsZero = True');

  S.Add(lS + 'Result = False');
  S.Add(lS + 'BeginDate = gdcDocument.FieldByName("documentdate").AsDateTime');
  S.Add(lS + 'EndDate = BeginDate');
  S.Add(lS + 'EntryDate = EndDate');
  S.Add(lS + Format('TrRecordKey = gdcBaseManager.GetIDByRUIDString("%s")', [FTrRecordRUID]));
  S.Add(lS + 'Set Transaction = gdcDocument.Transaction');
  S.Add(lS + 'GS.Transaction = Transaction');
  S.Add(lS + 'Set Creator = New TCreator');
  FCheckMasterInsertLine := S.Count;

  DoGenearteCallExceptFunction(S, Paragraph);
end;

procedure TTrEntryFunctionBlock.SetDocumentRUID(const Value: string);
begin
  FDocumentRUID := Value;
end;

procedure TTrEntryFunctionBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  if FStreamVersion > 5 then
  begin
    FDocumentRUID := ReadStringFromStream(Stream);
    if FStreamVersion > 8 then
    begin
      FSaveEmpty := ReadBooleanFromStream(Stream);
    end;
  end;
end;

procedure TTrEntryFunctionBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FDocumentRUID, Stream);
  SaveBooleanToStream(FSaveEmpty, Stream); 
end;

function TTrEntryFunctionBlock.GetBlockSetMember: TBlockSetMember;
begin
  Result := bsSimple
end;

procedure TTrEntryFunctionBlock.DoReleaseVars;
begin
  inherited;
  ReleaseVarName(ENG_BEGINDATE);
  ReleaseVarName(ENG_ENDDATE);
  ReleaseVarName(ENG_ENTRYDATE);
  ReleaseVarName(ISZERO);
end;

procedure TTrEntryFunctionBlock.DoReserveVars;
begin
  inherited;
  AddVarName(ENG_BEGINDATE, RUS_BEGINDATE);
  AddVarName(ENG_ENDDATE, RUS_ENDDATE);
  AddVarName(ENG_ENTRYDATE, RUS_ENTRYDATE);
  AddVarName(ISZERO, '');
end;

function TTrEntryFunctionBlock.EditExpression(Expression: string;
  Sender: TVisualBlock): string;
{$IFDEF GEDEMIN}
var
  F: TdlgTrExpressionEditorForm;
  I: Integer;
{$ENDIF}
begin
  Result := Expression;
  {$IFDEF GEDEMIN}
  F := TdlgTrExpressionEditorForm.Create(Application);
  try
    F.mExpression.Lines.Text := Expression;
    F.Block := Sender;
    CheckDocumentInfo;
    for I := 0 to FDocumentHead.FieldCount - 1 do
    begin
      if (FDocumentHead.Fields[I].RelationField.ReferencesField <> nil) or
          ((FDocumentHead.Fields[I].RelationField.Relation.PrimaryKey <> nil) and
          (FDocumentHead.Fields[I].RelationField.Relation.PrimaryKey.
          ConstraintFields.IndexOf(FDocumentHead.Fields[I].RelationField) > - 1))  then
      begin
        F.RefFields.Add(FDocumentHead.Fields[I].DisplayName + '=' +
          FDocumentHead.Fields[I].Script);
      end else
      begin
        case FDocumentHead.Fields[I].RelationField.Field.SQLType of
          12, 13, 35: F.DateFields.Add(FDocumentHead.Fields[I].DisplayName + '=' +
             FDocumentHead.Fields[I].Script);
          11, 27, 10, 16, 8, 9: F.CurrFields.Add(FDocumentHead.Fields[I].DisplayName + '=' +
             FDocumentHead.Fields[I].Script);
        else
          F.OtherFields.Add(FDocumentHead.Fields[I].DisplayName + '=' +
             FDocumentHead.Fields[I].Script);
        end;
      end;
    end;

    if FDocumentLine <> nil then
    begin
      for I := 0 to FDocumentLine.FieldCount - 1 do
      begin
        if (FDocumentLine.Fields[I].RelationField.ReferencesField <> nil) or
          ((FDocumentLine.Fields[I].RelationField.Relation.PrimaryKey <> nil) and
          (FDocumentLine.Fields[I].RelationField.Relation.PrimaryKey.
          ConstraintFields.IndexOf(FDocumentLine.Fields[I].RelationField) > - 1)) then
        begin
          F.RefFields.Add(FDocumentLine.Fields[I].DisplayName + '=' +
            FDocumentLine.Fields[I].Script);
        end else
        begin
          case FDocumentLine.Fields[I].RelationField.Field.SQLType of
            12, 13, 35: F.DateFields.Add(FDocumentLine.Fields[I].DisplayName + '=' +
               FDocumentLine.Fields[I].Script);
            11, 27, 10, 16, 8, 9: F.CurrFields.Add(FDocumentLine.Fields[I].DisplayName + '=' +
               FDocumentLine.Fields[I].Script);
          else
            F.OtherFields.Add(FDocumentLine.Fields[I].DisplayName + '=' +
               FDocumentLine.Fields[I].Script);
          end;
        end;
      end;
    end;

    if F.ShowModal = mrOk then
      Result := F.mExpression.Lines.Text;
  finally
    F.Free;
  end;
  {$ENDIF}
end;

procedure TTrEntryFunctionBlock.CheckDocumentInfo;
begin
{$IFDEF GEDEMIN}
  if FDocumentHead = nil then
  begin
    FDocumentHead := TDocumentInfo.Create;
    FDocumentHead.DocumentRUID := FDocumentRuid;
  end;

  if FDocumentPart = dcpLine then
  begin
    if FDocumentLine = nil then
    begin
      FDocumentLine := TDocumentLineInfo.Create;
      FDocumentLine.DocumentRUID := FDocumentRuid;
    end;
  end;
  {$ENDIF}
end;
{$IFDEF GEDEMIN}
function TTrEntryFunctionBlock.GetDocumentInfo: TDocumentInfo;
begin
  CheckDocumentInfo;
  Result := FDocumentHead;
end;

function TTrEntryFunctionBlock.GetDocumentLineInfo: TDocumentLineInfo;
begin
  CheckDocumentInfo;
  Result := FDocumentLine;
end;

procedure TTrEntryFunctionBlock.SetDocumentPart(
  const Value: TgdcDocumentClassPart);
begin
  FDocumentPart := Value;
end;
{$ENDIF}

function TTrEntryFunctionBlock.CanSave: Boolean;
begin
  Result := inherited CanSave;
end;

procedure TTrEntryFunctionBlock.DoGenerateExceptFunction(S: TStrings;
  Paragraph: Integer);
var
  ls: string;
begin
  lS := StringOfChar(' ', Paragraph);
  S.Add('''Функция обработки исключения');
  S.Add(lS + Format('Sub Except%s (gdcEntry)', [FBlockName]));

  S.Add(lS + '  If (gdcEntry.State = 2) Or (gdcEntry.State = 3) Then gdcEntry.Cancel');
  S.Add(lS + 'End Sub');
  S.Add('');
end;

procedure TTrEntryFunctionBlock.DoGenearteCallExceptFunction(S: TStrings;
  Paragraph: Integer);
var
  lS: string;
begin
  lS := StringOfChar(' ', Paragraph);
  S.Add(lS + Format('Except Except%s(gdcEntry)', [FBlockName]));
end;

constructor TTrEntryFunctionBlock.Create(AOwner: TComponent);
begin
  inherited;
  FReturnResult := False;
end;

procedure TTrEntryFunctionBlock.SetReturnResult(const Value: Boolean);
begin
  inherited SetReturnResult(False);
end;

function TTrEntryFunctionBlock.CanRun: Boolean;
begin
  Result := False;
end;

function TTrEntryFunctionBlock.CheckAccount(Account: string;
  var AccountId: Integer): boolean;
{$IFDEF GEDEMIN}
var
  I: Integer;
{$ENDIF}
begin
{$IFDEF GEDEMIN}
  if AccountID = 0 then
  begin
    //Может передана ссылка на поле?
    CheckDocumentInfo;

    if FDocumentHead <> nil then
    begin
      for I := 0 to FDocumentHead.FieldCount - 1 do
      begin
        if UpperCase(Account) = UpperCase(FDocumentHead.Fields[I].Script) then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;

    if FDocumentLine <> nil then
    begin
      for I := 0 to FDocumentLine.FieldCount - 1 do
      begin
        if UpperCase(Account) = UpperCase(FDocumentLine.Fields[I].Script) then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;

    Result := inherited  CheckAccount(Account, AccountId);
  end else
    Result := True;
{$ELSE}
  Result := False;
{$ENDIF}
end;

procedure TTrEntryFunctionBlock.SetSaveEmpty(const Value: Boolean);
begin
  FSaveEmpty := Value;
end;

procedure TTrEntryFunctionBlock.GetVars(const Strings: TStrings);
begin
  inherited;
  Strings.AddObject(ENG_BEGINDATE + '=' + RUS_BEGINDATE, Self);
  Strings.AddObject(ENG_ENDDATE + '=' + RUS_ENDDATE, Self);
  Strings.AddObject(ENG_ENTRYDATE + '=' + RUS_ENTRYDATE, Self);
  Strings.AddObject(ISZERO + '=' + '', Self);
end;

destructor TTrEntryFunctionBlock.Destroy;
begin
  {$IFDEF GEDEMIN}
  FDocumentHead.Free;
  FDocumentLine.Free;
  {$ENDIF}
  inherited;
end;

{ TTrEntryPositionBlock }

function TTrEntryPositionBlock.CanHasOwnBlock: boolean;
begin
  Result := False;
end;

function TTrEntryPositionBlock.CheckOffBalance(Account: string): boolean;
var
  SQL: TIBSQL;
begin
  Result := False;
  if CheckRuid(Account) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQl.SQl.Text := 'SELECT offbalance FROM ac_account WHERE id = :id';
      SQL.ParamByName(fnId).AsInteger := gdcBaseManager.GetIdByRuidString(Account);
      SQl.ExecQuery;
      Result := SQL.Fields[0].AsInteger > 0;
    finally
      SQL.Free
    end;
  end;
end;

class function TTrEntryPositionBlock.CheckParent(
  AParent: TVisualBlock): Boolean;
var
  P: TControl;
begin
  Result := False;
  P := AParent;
  while P <> nil do
  begin
    Result := P is TTrEntryBlock;
    if Result then
      Break
    else
      P := P.Parent;
  end;
end;

procedure TTrEntryPositionBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
  A: TStrings;
  I: Integer;
  AName, AValue: string;
  Tr: TTrEntryBlock;
begin
  lS := StringOfChar(' ', Paragraph);
  S.Add(lS + Format('''Позиция типовой проводки %s', [Header]));
  S.Add(lS + 'gdcEntry.Insert');
  S.Add(lS + 'gdcEntry.FieldByName("recordkey").AsInteger = RecordKey');
  Tr := TrEntry;
  if Tr <> nil then
  begin
    if Tr.CompanyRUID > '' then
    begin
      if CheckRUID(Tr.CompanyRUID) then
      begin
        S.Add(lS + Format('gdcEntry.FieldByName("companykey").AsInteger = gdcBaseManager.GetIdByRUIDString("%s")', [Tr.CompanyRUID]))
      end else
      begin
        S.Add(lS + Format('gdcEntry.FieldByName("companykey").AsInteger = %s', [GenerateExpression(Tr.CompanyRUID)]))
      end;
    end;

    if Tr.EntryDate > '' then
    begin
      S.Add(lS + Format('gdcEntry.FieldByName("recorddate").AsDateTime = %s', [GenerateExpression(Tr.EntryDate)]))
    end;

    if Tr.EntryDescription > '' then
    begin
      S.Add(lS + Format('gdcEntry.FieldByName("description").Value = %s', [GenerateExpression(Tr.EntryDescription)]));
    end;

    if Tr.Attributes > '' then
    begin
      S.Add(lS + '''Присвоение значения атрибутов');
      A := TStringList.Create;
      try
        A.Text := Tr.Attributes;
        for I := 0 to A.Count - 1 do
        begin
          AName := A.Names[I];
          AValue := A.Values[AName];

          if CheckRUID(AValue) then
            S.Add(lS + Format('gdcEntry.FieldByName("%s").AsInteger = gdcBaseManager.GetIdByRuidString("%s")',
              [AName, AValue]))
          else
            S.Add(lS + Format('gdcEntry.FieldByName("%s").AsVariant = %s',
              [AName, GenerateExpression(AValue)]))
        end;
      finally
        A.Free;
      end;
    end;
  end;

  S.Add(lS + '''Присвоение счета и типа счета проводки');
  if CheckRUID(FAccount) then
    S.Add(lS + Format('gdcEntry.FieldByName("accountkey").AsInteger = gdcBaseManager.GetIdByRUIDString("%s")',
      [FAccount]))
  else
    S.Add(lS + Format('gdcEntry.FieldByName("accountkey").AsInteger = %s',
      [GenerateExpression(FAccount)]));

  S.Add(lS + '''Тип счета');
  S.Add(lS + Format('gdcEntry.FieldByName("accountpart").AsString = "%s"', [FAccountPart]));

  if FSumNCU > '' then
  begin
    if FAccountPart = 'D' then
    begin
      S.Add(lS + Format('gdcEntry.FieldByName("debitncu").AsCurrency = %s', [GenerateExpression(FSumNcu)]));
      S.Add(lS + 'DebitNcu = DebitNcu + gdcEntry.FieldByName("debitncu").AsCurrency');
    end else
    begin
      S.Add(lS + Format('gdcEntry.FieldByName("creditncu").AsCurrency = %s', [GenerateExpression(FSumNcu)]));
      S.Add(lS + 'CreditNcu = CreditNcu + gdcEntry.FieldByName("creditncu").AsCurrency');
    end;
  end;

  if FCurrRUID > '' then
  begin
    if CheckRUID(FCurrRUID) then
      S.Add(lS + Format('gdcEntry.FieldByName("currkey").AsInteger = gdcBaseManager.GetIdByRUIDString("%s")', [FCurrRUID]))
    else
      S.Add(lS + Format('gdcEntry.FieldByName("currkey").AsVariant = %s', [GenerateExpression(FCurrRUID)]));
  end;

  if FSumCurr > '' then
  begin
    if FAccountPart = 'D' then
    begin
      S.Add(lS + Format('gdcEntry.FieldByName("debitcurr").AsCurrency = %s', [GenerateExpression(FSumCurr)]));
      S.Add(lS + 'DebitCurr = DebitCurr + gdcEntry.FieldByName("debitcurr").AsCurrency');
    end else
    begin
      S.Add(lS + Format('gdcEntry.FieldByName("creditcurr").AsCurrency = %s', [GenerateExpression(FSumCurr)]));
      S.Add(lS + 'CreditCurr = CreditCurr + gdcEntry.FieldByName("creditcurr").AsCurrency');
    end;
  end;

  if FSumEQ > '' then
  begin
    if FAccountPart = 'D' then
    begin
      S.Add(lS + Format('gdcEntry.FieldByName("debiteq").AsCurrency = %s', [GenerateExpression(FSumEQ)]));
      S.Add(lS + 'DebitEQ = DebitEQ + gdcEntry.FieldByName("debiteq").AsCurrency');
    end else
    begin
      S.Add(lS + Format('gdcEntry.FieldByName("crediteq").AsCurrency = %s', [GenerateExpression(FSumEQ)]));
      S.Add(lS + 'CreditEQ = CreditEQ + gdcEntry.FieldByName("crediteq").AsCurrency');
    end;
  end;

  if FAnalytics > '' then
  begin
    S.Add(lS + '''Присвоение значения аналитик');
    A := TStringList.Create;
    try
      A.Text := FAnalytics;
      for I := 0 to A.Count - 1 do
      begin
        AName := A.Names[I];
        AValue := A.Values[AName];

        if CheckRUID(AValue) then
          S.Add(lS + Format('gdcEntry.FieldByName("%s").AsInteger = gdcBaseManager.GetIdByRuidString("%s")',
            [AName, AValue]))
        else
          S.Add(lS + Format('gdcEntry.FieldByName("%s").AsVariant = %s',
            [AName, GenerateExpression(AValue)]))
      end;
    finally
      A.Free;
    end;
  end;

  if FQuantity > '' then
  begin
    S.Add(lS + '''Присвоение количественных показателей');
    A := TStringList.Create;
    try
      A.Text := FQuantity;
      for I := 0 to A.Count - 1 do
      begin
        AName := A.Names[I];
        AValue := A.Values[AName];
        S.Add(lS + 'gdcEntry.gdcQuantity.Insert');

        if CheckRUID(AName) then
          S.Add(lS + Format('gdcEntry.gdcQuantity.FieldByName("valuekey").AsInteger = gdcBaseManager.GetIdByRuidString("%s")', [AName]))
        else
          S.Add(lS + Format('gdcEntry.gdcQuantity.FieldByName("valuekey").AsVariant = %s', [GenerateExpression(AName)]));

        S.Add(lS + Format('gdcEntry.gdcQuantity.FieldByName("quantity").AsVariant = %s', [GenerateExpression(AValue)]));

        S.Add(lS + 'gdcEntry.gdcQuantity.Post');
      end;
    finally
      A.Free;
    end;
  end;
  //если предыдущая проводка была нулевой то
  //gdcEntry был переоткрыт . Поэтому необходимо присвоить
  //значение тррекордкей заново
  S.Add(lS + 'gdcEntry.FieldByName("trrecordkey").AsInteger = TrRecordKey');
  S.Add(lS + 'gdcEntry.Post');
end;

procedure TTrEntryPositionBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  if FStreamVersion > 6 then
  begin
    FDocumentType := ReadStringFromStream(Stream);
    FAccountPart := ReadStringFromStream(Stream);
    FAnalytics := ReadStringFromStream(Stream);
    FSumCurr := ReadStringFromStream(Stream);
    FQuantity := ReadStringFromStream(Stream);
    FAccount := ReadStringFromStream(Stream);
    FSumNCU := ReadStringFromStream(Stream);
    FCurrRUID := ReadStringFromStream(Stream);
  end;
  if FStreamVersion > 16 then
    FSumEQ := ReadStringFromStream(Stream);
end;

procedure TTrEntryPositionBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;

  SaveStringToStream(FDocumentType, Stream);
  SaveStringToStream(FAccountPart, Stream);
  SaveStringToStream(FAnalytics, Stream);
  SaveStringToStream(FSumCurr, Stream);
  SaveStringToStream(FQuantity, Stream);
  SaveStringToStream(FAccount, Stream);
  SaveStringToStream(FSumNCU, Stream);
  SaveStringToStream(FCurrRUID, Stream);
  SaveStringToStream(FSumEQ, Stream);

end;

function TTrEntryPositionBlock.FotterPrefix: string;
begin
  Result := ''
end;

function TTrEntryPositionBlock.Get: TTrEntryBlock;
var
  P: TControl;
begin
  Result := nil;
  P := Parent;
  while P <> nil do
  begin
    if P is TTrEntryBlock then
    begin
      Result := TTrEntryBlock(P);
      Break;
    end else
      P := P.Parent;
  end;
end;

function TTrEntryPositionBlock.GetDocumentRUID: string;
begin
  if (MainFunction <> nil) and (MainFunction is TTrEntryFunctionBlock) then
    Result := TTrEntryFunctionBlock(MainFunction).DocumentRUID
  else
    Result := '';  
end;

function TTrEntryPositionBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrTrPosEntryEditFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TTrEntryPositionBlock.HasBody: boolean;
begin
  Result := False;
end;

function TTrEntryPositionBlock.HeaderColor: TColor;
begin
  Result := $F3D8D8
end;

function TTrEntryPositionBlock.HeaderPrefix: string;
begin
  Result := 'Позиция типовой проводки'
end;

class function TTrEntryPositionBlock.NamePrefix: string;
begin
  Result := 'TrPosEntry'
end;

procedure TTrEntryPositionBlock.SetAccount(const Value: string);
begin
  FAccount := Value;
end;

procedure TTrEntryPositionBlock.SetAccountPart(const Value: string);
begin
  FAccountPart := Value;
end;

procedure TTrEntryPositionBlock.SetAnalytics(const Value: string);
begin
  FAnalytics := Value;
end;

procedure TTrEntryPositionBlock.SetCurrRUID(const Value: string);
begin
  FCurrRUID := Value;
end;

procedure TTrEntryPositionBlock.SetDocumentType(const Value: string);
begin
  FDocumentType := Value;
end;

procedure TTrEntryPositionBlock.SetQuantity(const Value: string);
begin
  FQuantity := Value;
end;

procedure TTrEntryPositionBlock.SetSumCurr(const Value: string);
begin
  FSumCurr := Value;
end;

procedure TTrEntryPositionBlock.SetSumEQ(const Value: string);
begin
  FSumEQ := Value;
end;

procedure TTrEntryPositionBlock.SetSumNCU(const Value: string);
begin
  FSumNCU := Value;
end;

{ TTrAccountPopupMenu }

procedure TTrAccountPopupMenu.DoPopup(Sender: TObject);
begin
  inherited;

end;

procedure TTrAccountPopupMenu.SetOnClickTrDocumentAccount(
  const Value: TNotifyEvent);
begin
  FOnClickTrDocumentAccount := Value;
end;

{ TfrBaseEditFrame }

{ TTrEntryBlock }

function TTrEntryBlock.CanHasOwnBlock: boolean;
begin
  Result := True;
end;

function TTrEntryBlock.CanSave: Boolean;
var
  I: Integer;
  DebitCount, CreditCount: Integer;
  SD, SC: TStrings;
  Index: Integer;
  Account, AccountPart: string;
  BlockNames: string;
begin
  Result := inherited CanSave;
  if Result then
  begin
    DebitCount := 0;
    CreditCount := 0;
    SD := TStringList.Create;
    SC := TStringList.Create;
    try
      for I := 0 to BlockList.Count - 1 do
      begin
        if (TObject(BlockList[i]) is TTrEntryPositionBlock) and
          (TTrEntryPositionBlock(BlockList[i]).TrEntry = Self) then
        begin
          if TTrEntryPositionBlock(BlockList[i]).AccountPart = 'D' then
          begin
            Inc(DebitCount);
            Index := SD.Indexof(TTrEntryPositionBlock(BlockList[i]).Account);
            if Index = - 1 then
              SD.AddObject(TTrEntryPositionBlock(BlockList[i]).Account, Pointer(1))
            else
              SD.Objects[Index] := Pointer(Integer(SD.Objects[Index]) + 1);
          end else
          begin
            Inc(CreditCount);
            Index := SC.Indexof(TTrEntryPositionBlock(BlockList[i]).Account);
            if Index = - 1 then
              SC.AddObject(TTrEntryPositionBlock(BlockList[i]).Account, Pointer(1))
            else
              SC.Objects[Index] := Pointer(Integer(SC.Objects[Index]) + 1);
          end;
        end;
      end;

      if (DebitCount = 0) and (CreditCount = 0) then
      begin
        ShowMessage(Header + ':'#13#10 + RUS_TRENTRY_ERROR1);
        Result := False;
        Exit;
      end else
      if (DebitCount > 1) and (CreditCount > 1)then
      begin
        ShowMessage(Header + ':'#13#10 + RUS_TRENTRY_ERROR2);
        Result := False;
        Exit;
      end else
      if (DebitCount > 0) and (CreditCount = 0) then
      begin
        ShowMessage(Header + ':'#13#10 + RUS_TRENTRY_ERROR3);
        Result := False;
        Exit;
      end else
      if (CreditCount > 0) and (DebitCount = 0) then
      begin
        ShowMessage(Header + ':'#13#10 + RUS_TRENTRY_ERROR4);
        Result := False;
        Exit;
      end else
      begin
        Account := '';
        for I := 0 to SD.Count - 1 do
        begin
          if Integer(SD.Objects[I]) > 1 then
          begin
            Account := SD[I];
            AccountPart := 'D';
            Break;
          end;
        end;
        if Account = '' then
        begin
          for I := 0 to SC.Count - 1 do
          begin
            if Integer(SC.Objects[I]) > 1 then
            begin
              Account := SC[I];
              AccountPart := 'C';
              Break;
            end;
          end;
        end;

        if Account > '' then
        begin
          BlockNames := '';
          for I := 0 to BlockList.Count - 1 do
          begin
            if (TObject(BlockList[i]) is TTrEntryPositionBlock) and
              (TTrEntryPositionBlock(BlockList[i]).Account = Account) and
              (TTrEntryPositionBlock(BlockList[i]).AccountPart = AccountPart) then
            begin
              BlockNames := BlockNames + '  ' + TTrEntryPositionBlock(BlockList[i]).Header + #13#10
            end;
          end;
          ShowMessage(Header + ':'#13#10 + Format(RUS_TRENTRY_ERROR5, [BlockNames]));
          Result := False;
          Exit;

        end;
      end;
    finally
      SD.Free;
      SC.Free;
    end;
  end;
end;

class function TTrEntryBlock.CheckParent(AParent: TVisualBlock): Boolean;
var
  P: TControl;
begin
  Result := False;
  P := AParent;
  while P <> nil do
  begin
    Result := not (P is TTrEntryBlock);
    if not Result then
      Break
    else
      P := P.Parent;
  end;
end;

procedure TTrEntryBlock.DoCreateNew;
var
  TrEntryPos: TTrEntryPositionBlock;
begin
  inherited;

  TrEntryPos := TTrEntryPositionBlock.Create(Owner);
  TrEntryPos.Parent := Self;
  TrEntryPos.Left := 0;
  TrEntryPos.Top := 0;
  TrEntryPos.BlockName := TrEntryPos.GetUniqueName;
  TrEntryPos.AccountPart := 'D';
  TrEntryPos.LocalName := 'Дебет';

  TrEntryPos := TTrEntryPositionBlock.Create(Owner);
  TrEntryPos.Parent := Self;
  TrEntryPos.Left := 0;
  TrEntryPos.Top := 30;
  TrEntryPos.BlockName := TrEntryPos.GetUniqueName;
  TrEntryPos.AccountPart := 'С';
  TrEntryPos.LocalName := 'Кредит';
end;

procedure TTrEntryBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: String;
begin
  lS := StringOfChar(' ', Paragraph);
  S.Add(lS + 'RecordKey = gdcEntry.GetNextId(True)');
  S.Add(lS + 'DebitNcu = 0');
  S.Add(lS + 'CreditNcu = 0');
  S.Add(lS + 'DebitCurr = 0');
  S.Add(lS + 'CreditCurr = 0');
  S.Add(lS + 'DebitEq = 0');
  S.Add(lS + 'CreditEq = 0');

  inherited;

  S.Add(lS + 'If (DebitNcu <> CreditNcu) Then');
  S.Add(lS + '  Call Exception.Raise("Exception", "Сумма по дебету не равна сумме по кредиту!" & Chr(13) & Chr(10) & _');
  S.Add(lS + '    "Проверьте настройку типовой операции." & Chr(13) & Chr(10))');
  S.Add(lS + 'End If');

  if MainFunction is TTrEntryFunctionBlock then
  begin
     if not TTrEntryFunctionBlock(MainFunction).SaveEmpty then
     begin
       S.Add(lS + 'IsZero = (DebitNcu = 0) and (CreditNcu = 0) and _ ');
       S.Add(lS + '  (DebitCurr = 0) and (CreditCurr = 0) and _ ');
       S.Add(lS + '  (DebitEq = 0) and (CreditEq = 0)');
       S.Add(lS + 'If IsZero Then ');
       S.Add(lS + '  call gdcBaseManager.ExecSingleQuery("DELETE FROM ac_record WHERE id = (" & _ ');
       S.Add(lS + '    CStr(RecordKey) & ")", Transaction )');
       S.Add(lS + 'End If');
     end;
  end;
end;

procedure TTrEntryBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  if FStreamVersion > 9 then
  begin
    FCompanyRUID := ReadStringFromStream(Stream);
    FEntryDate := ReadStringFromStream(Stream);
  end;

  if FStreamVersion > 11 then
  begin
    FEntryDescription := ReadStringFromStream(Stream);
  end;

  if FStreamVersion > 12 then
  begin
    FAttributes := ReadStringFromStream(Stream);
  end;
end;

procedure TTrEntryBlock.DoReleaseVars;
begin
  inherited;
  ReleaseVarName(ENG_RECORDKEY);
  ReleaseVarName(ENG_DEBITNCU);
  ReleaseVarName(ENG_CREDITNCU);
  ReleaseVarName(ENG_DEBITCURR);
  ReleaseVarName(ENG_CREDITCURR);
  ReleaseVarName(ENG_DEBITEQ);
  ReleaseVarName(ENG_CREDITEQ);
end;

procedure TTrEntryBlock.DoReserveVars;
begin
  inherited;
  AddVarName(ENG_RECORDKEY);
  AddVarName(ENG_DEBITNCU);
  AddVarName(ENG_CREDITNCU);
  AddVarName(ENG_DEBITCURR);
  AddVarName(ENG_CREDITCURR);
  AddVarName(ENG_DEBITEQ);
  AddVarName(ENG_CREDITEQ);
end;

procedure TTrEntryBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FCompanyRUID, Stream);
  SaveStringToStream(FEntryDate, Stream);
  SaveStringToStream(FEntryDescription, Stream);
  SaveStringToStream(FAttributes, Stream);
end;

function TTrEntryBlock.FotterPrefix: string;
begin
  Result := HeaderPrefix
end;

function TTrEntryBlock.GetEditFrame: TFrameClass;
begin
{$IFDEF GEDEMIN}
  Result := TfrTrEntryEditFrame
  {$ELSE}
  Result := nil;
{$ENDIF}
end;

function TTrEntryBlock.HasBody: boolean;
begin
  Result := True
end;

function TTrEntryBlock.HeaderColor: TColor;
begin
  Result := $F3D8D8
end;

function TTrEntryBlock.HeaderPrefix: string;
begin
  Result := 'Типовая проводка'
end;

class function TTrEntryBlock.NamePrefix: string;
begin
  Result := 'TrEntry'
end;

procedure TTrEntryBlock.SetAttributes(const Value: string);
begin
  FAttributes := Value;
end;

procedure TTrEntryBlock.SetCompanyRUID(const Value: string);
begin
  FCompanyRUID := Value;
end;

procedure TTrEntryBlock.SetEntryDate(const Value: string);
begin
  FEntryDate := Value;
end;

procedure TTrEntryBlock.SetEntryDescription(const Value: String);
begin
  FEntryDescription := Value;
end;

{ TWhileCycleBlock }

procedure TWhileCycleBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
begin
  lS := StringOfChar(' ', Paragraph);

  S.Add(lS + Format('do while %s ', [FCondition]));
  inc(Paragraph, 2);
  inherited;
  S.Add(lS + 'loop');
end;

procedure TWhileCycleBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  FCondition := ReadStringFromStream(Stream);
end;

procedure TWhileCycleBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FCondition, Stream);
end;

function TWhileCycleBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrWhileEditFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

class function TWhileCycleBlock.NamePrefix: string;
begin
  Result := 'WhileCycle'
end;

procedure TWhileCycleBlock.SetCondition(const Value: string);
begin
  FCondition := Value;
end;

{ TForCycle }

procedure TForCycleBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
begin
  lS := StringOfChar(' ', Paragraph);

  if Trim(FStep) = '' then
    S.Add(lS + Format('For %s = %s To %s ', [FBlockName, FCondition, FConditionTo]))
  else
    S.Add(lS + Format('For %s = %s To %s Step %s', [FBlockName, FCondition, FConditionTo, FStep]));
  inc(Paragraph, 2);
  inherited;
  S.Add(lS + 'Next');
end;

procedure TForCycleBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  FCondition :=ReadStringFromStream(Stream);
  FConditionTo := ReadStringFromStream(Stream);
  FStep := ReadStringFromStream(Stream);
end;

procedure TForCycleBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FCondition, Stream);
  SaveStringToStream(FConditionTo, Stream);
  SaveStringToStream(FStep, Stream);
end;

function TForCycleBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrForCycleEditFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

procedure TForCycleBlock.GetVars(const Strings: TStrings);
begin
  inherited;
  Strings.Add(FBlockName + '=Счетчик цикла FOR');
end;

class function TForCycleBlock.NamePrefix: string;
begin
  Result := 'ForCycle';
end;

procedure TForCycleBlock.SetCondition(const Value: string);
begin
  FCondition := Value;
end;

procedure TForCycleBlock.SetConditionTo(const Value: string);
begin
  FConditionTo := Value;
end;

procedure TForCycleBlock.SetStep(const Value: string);
begin
  FStep := Value;
end;

{ TSelectBlock }

function TSelectBlock.BodyColor: TColor;
begin
  Result := RGB(240, 248, 255)
end;

function TSelectBlock.CanDrop(Source: TObject; X, Y: Integer): boolean;
begin
  Result := Source is TCaseBlock;

  if Result then
  begin
    Result := inherited CanDrop(Source, X, Y);
  end;
end;

procedure TSelectBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: String;
begin
  lS := StringOfChar(' ', Paragraph);
  S.Add(lS + Format('Select Case %s', [GenerateExpression(FCondition)]));
  inc(Paragraph, 2);
  inherited;
  S.Add(lS + 'End Select');
end;

procedure TSelectBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  FCondition := ReadStringFromStream(Stream);
end;

procedure TSelectBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FCondition, Stream);
end;

function TSelectBlock.FotterColor: TColor;
begin
  Result := $EFB4E7
end;

function TSelectBlock.FotterPrefix: string;
begin
  Result := 'Конец выбора'
end;

function TSelectBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrSelectEditFrame;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TSelectBlock.HeaderColor: TColor;
begin
  Result := RGB(203, 231, 250)
end;

function TSelectBlock.HeaderPrefix: string;
begin
  Result := 'Выбор из';
end;

class function TSelectBlock.NamePrefix: string;
begin
  Result := 'Select'
end;

procedure TSelectBlock.SetCondition(const Value: string);
begin
  FCondition := Value;
end;

{ TCaseBlock }

function TCaseBlock.BodyColor: TColor;
begin
  Result := $FAE7F7
end;

class function TCaseBlock.CheckParent(AParent: TVisualBlock): Boolean;
begin
  Result := AParent is TSelectBlock
end;

procedure TCaseBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
begin
  lS := StringOfChar(' ', Paragraph);
  S.Add(lS + Format('Case %s', [GenerateExpression(FCondition)]));
  Inc(Paragraph, 2);
  inherited;
end;

procedure TCaseBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  FCondition := ReadStringFromStream(Stream)
end;

procedure TCaseBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FCondition, Stream);
end;

function TCaseBlock.FotterColor: TColor;
begin
  Result := $EFB4E7
end;

function TCaseBlock.FotterPrefix: string;
begin
  Result := 'Конец выбора'
end;

function TCaseBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrCaseEditFrame
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TCaseBlock.HeaderColor: TColor;
begin
  Result := RGB(203, 231, 250)
end;

function TCaseBlock.HeaderPrefix: string;
begin
  Result := 'Выбор'
end;

class function TCaseBlock.NamePrefix: string;
begin
  Result := 'Case'
end;

procedure TCaseBlock.SetCondition(const Value: string);
begin
  FCondition := Value;
end;

{ TDocumentTransactionFunction }

procedure TDocumentTransactionFunction.CheckDocumentInfo;
begin
{$IFDEF GEDEMIN}
  if FDocumentHead = nil then
  begin
    FDocumentHead := TDocumentInfo.Create;
    FDocumentHead.DocumentRUID := FDocumentTypeRuid;
  end;

  if FDocumentPart = dcpLine then
  begin
    if FDocumentLine = nil then
    begin
      FDocumentLine := TDocumentLineInfo.Create;
      FDocumentLine.DocumentRUID := FDocumentTypeRuid;
    end;
  end;
  {$ENDIF}
end;
{$IFDEF GEDEMIN}
function TDocumentTransactionFunction.EditExpression(Expression: string;
  Sender: TVisualBlock): string;
{$IFDEF GEDEMIN}
var
  F: TdlgTrExpressionEditorForm;
  I: Integer;
{$ENDIF}
begin
  Result := Expression;
  {$IFDEF GEDEMIN}
  F := TdlgTrExpressionEditorForm.Create(Application);
  try
    F.mExpression.Lines.Text := Expression;
    F.Block := Sender;
    CheckDocumentInfo;
    for I := 0 to FDocumentHead.FieldCount - 1 do
    begin
      if (FDocumentHead.Fields[I].RelationField.ReferencesField <> nil) or
          (FDocumentHead.Fields[I].RelationField.Relation.PrimaryKey.
          ConstraintFields.IndexOf(FDocumentHead.Fields[I].RelationField) > - 1)  then
      begin
        F.RefFields.Add(FDocumentHead.Fields[I].DisplayName + '=' +
          FDocumentHead.Fields[I].Script);
      end else
      begin
        case FDocumentHead.Fields[I].RelationField.Field.SQLType of
          12, 13, 35: F.DateFields.Add(FDocumentHead.Fields[I].DisplayName + '=' +
             FDocumentHead.Fields[I].Script);
          11, 27, 10, 16, 8, 9: F.CurrFields.Add(FDocumentHead.Fields[I].DisplayName + '=' +
             FDocumentHead.Fields[I].Script);
        else
          F.OtherFields.Add(FDocumentHead.Fields[I].DisplayName + '=' +
             FDocumentHead.Fields[I].Script);
        end;
      end;
    end;

    if FDocumentLine <> nil then
    begin
      for I := 0 to FDocumentLine.FieldCount - 1 do
      begin
        if (FDocumentLine.Fields[I].RelationField.ReferencesField <> nil) or
          (FDocumentLine.Fields[I].RelationField.Relation.PrimaryKey.
          ConstraintFields.IndexOf(FDocumentLine.Fields[I].RelationField) > - 1) then
        begin
          F.RefFields.Add(FDocumentLine.Fields[I].DisplayName + '=' +
            FDocumentLine.Fields[I].Script);
        end else
        begin
          case FDocumentLine.Fields[I].RelationField.Field.SQLType of
            12, 13, 35: F.DateFields.Add(FDocumentLine.Fields[I].DisplayName + '=' +
               FDocumentLine.Fields[I].Script);
            11, 27, 10, 16, 8, 9: F.CurrFields.Add(FDocumentLine.Fields[I].DisplayName + '=' +
               FDocumentLine.Fields[I].Script);
          else
            F.OtherFields.Add(FDocumentLine.Fields[I].DisplayName + '=' +
               FDocumentLine.Fields[I].Script);
          end;
        end;
      end;
    end;


    if F.ShowModal = mrOk then
    begin
      Result := F.mExpression.Lines.Text;
    end;
  finally
    F.Free;
  end;
  {$ENDIF}
end;

function TDocumentTransactionFunction.GetDocumentInfo: TDocumentInfo;
begin
  CheckDocumentInfo;
  Result := FDocumentHead;
end;

function TDocumentTransactionFunction.GetDocumentLineInfo: TDocumentLineInfo;
begin
  CheckDocumentInfo;
  Result := FDocumentLine;
end;


procedure TDocumentTransactionFunction.SetDocumentPart(
  const Value: TgdcDocumentClassPart);
begin
  FDocumentPart := Value;
end;
{$ENDIF}

procedure TDocumentTransactionFunction.InitInitScript;
begin
  FInitScript :=
    'If Not gdcDocument.FieldByName("transactionkey").IsNull Then _'#13#10 +
    '  gdcDocument.FieldByName("transactionkey").Clear'#13#10
end;

procedure TDocumentTransactionFunction.SetDocumentTypeRUID(
  const Value: string);
begin
  FDocumentTypeRUID := Value;
end;

procedure TDocumentTransactionFunction._DoBeforeGenerate(S: TStrings;
  Paragraph: Integer);
var
  lS: string;
begin
  inherited;
  lS := StringOfChar(' ', Paragraph );
  S.Add(lS + 'Set Creator = New TCreator');
  S.Add(lS + 'If gdcDocument.Transaction.InTransaction Then');
  S.Add(lS + '  Set Transaction = gdcDocument.Transaction');
  S.Add(lS + 'Else');
  S.Add(lS + '  Set Transaction = gdcDocument.ReadTransaction');
  S.Add(lS + 'End If');
  {$IFDEF GEDEMIN}
  if FDocumentPart = dcpLine then
  begin
    S.Add(lS + 'If Assigned(gdcDocument.MasterSource) Then');
    S.Add(lS + '  Set gdcDocumentHeader = gdcDocument.MasterSource.Dataset');
    S.Add(lS + 'Else');
    S.Add(lS + '  Set gdcDocumentHeader = Creator.GetObject(nil, "' + DocumentHead.Document.ClassName + '", "")');
    S.Add(lS + '  gdcDocumentHeader.Transaction = Transaction');
    S.Add(lS + '  gdcDocumentHeader.SubType = gdcDocument.SubType');
    S.Add(lS + '  gdcDocumentHeader.Subset = "ByID"');
    S.Add(lS + '  gdcDocumentHeader.ID = gdcDocument.FieldByName("parent").AsInteger');
    S.Add(lS + '  gdcDocumentHeader.Open');
    S.Add(lS + 'End If');
    AddVarName('gdcDocumentHeader');
  end;
  {$ENDIF}
end;

{ TTransactionBlock }

function TTransactionBlock.CanHasOwnBlock: boolean;
begin
  Result := False;
end;

procedure TTransactionBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
begin
  lS := StringOfChar(' ', Paragraph);
  S.Add(lS + Format('gdcDocument.FieldByName("transactionkey").AsInteger = gdcBaseManager.GetIdByRuidString("%s")', [FTrasactionRUID]));
end;

procedure TTransactionBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  FTrasactionRUID := ReadStringFromStream(Stream)
end;

procedure TTransactionBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FTrasactionRUID, Stream)
end;

function TTransactionBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrDocumentTransactionEditFrame
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TTransactionBlock.HasBody: boolean;
begin
  Result := False;
end;

function TTransactionBlock.HasFootter: boolean;
begin
  Result := False;
end;

function TTransactionBlock.HeaderColor: TColor;
begin
  Result := $F8F8D6
end;

function TTransactionBlock.HeaderPrefix: string;
begin
  Result := 'Типовая операция'
end;

class function TTransactionBlock.NamePrefix: string;
begin
  Result := 'Transaction'
end;

procedure TTransactionBlock.SetTrasactionRUID(const Value: string);
begin
  FTrasactionRUID := Value;
end;

{ TSQLCycleBlock }

procedure TSQLCycleBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
  SQLName: string;
  Strings: TStrings;
  I: Integer;
begin
  Strings := TStringList.Create;
  try
    lS := StringOfChar(' ', Paragraph);
    SQLName := FBlockName;

    S.Add(lS + Format('Set %s = Creator.GetObject(nul, "TIBSQL", "")', [SQLName]));
    S.Add(lS + Format('%s.Transaction = Transaction', [SQLName]));
    S.Add(lS + Format('%s.SQL.Text = _', [SQLName]));
    Strings.Text := FSQL;
    for I := 0 to Strings.Count - 1 do
    begin
      if I > 0 then S[S.Count - 1] := S[S.Count - 1] + ' + _';
      S.Add(lS + Format('  " %s "', [Strings[I]]));
    end;
    S.Add(lS + Format('%s.Prepare', [SQLName]));
    Strings.Text := Params;

    if Strings.Count > 0 then
    begin
      for I := 0 to Strings.Count - 1 do
      begin
        S.Add(lS + Format('%s.ParamByName("%s").AsVariant = %s', [SQLName,
          Strings.Names[I], GenerateExpression(Strings.Values[Strings.Names[I]])]));
      end;
    end;

    S.Add(lS + Format('%s.ExecQuery', [SQLName]));
    S.Add(lS + Format('Do While Not %s.Eof ', [SQLName]));
    inherited DoGenerate(S, Paragraph + 2);
    S.Add(lS + Format('  %s.Next', [SQLName]));
    S.Add(lS + 'Loop');

    S.Add(lS + Format('Creator.DestroyObject(%s)', [SQLName]));
  finally
    Strings.Free;
  end;
end;

procedure TSQLCycleBlock.DoLoadFromStream(Stream: TStream);
begin
  inherited;
  FSQL := ReadStringFromStream(Stream);
  FParams := ReadStringFromStream(Stream);
  FFields := ReadStringFromStream(Stream);
end;

procedure TSQLCycleBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;
  SaveStringToStream(FSQL, Stream);
  SaveStringToStream(FParams, Stream);
  SaveStringToStream(FFields, Stream);
end;

function TSQLCycleBlock.GetEditDialogForm: TdlgBaseEditForm;
begin
  Result := inherited GetEditDialogForm;
  if Result is TdlgEditForm then
  begin
    Result.EditFrame.Constraints.MaxHeight := 0;
    Result.EditFrame.Constraints.MaxWidth := 0;
    Result.AutoSize := False;
    TdlgEditForm(Result).bOk.Default := False;
  end;
end;

function TSQLCycleBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrSQLCycleEditFrame
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

procedure TSQLCycleBlock.GetVars(const Strings: TStrings);
var
  SQL: TIBSQL;
  I: Integer;
  Names: TStrings;
begin
  inherited;

  if FSQL = '' then
    exit;

  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQL.Text := FSQL;
    try
      SQL.Prepare;
    except
      exit;
    end;

    Names := TStringList.Create;
    try
      Names.Text := SQL.Current.Names;
      for I := 0 to Names.Count - 1 do
      begin
        Strings.AddObject(Format('%s_%s', [FBlockName, Names[I]]) +
          '=' + Format('Значение поля %s цикла ''%s''', [Names[I],
          Header]), Self);
      end;
    finally
      Names.Free;
    end;
  finally
    SQL.Free;
  end;
end;

function TSQLCycleBlock.GetVarScript(const VarName: string): string;
var
  P: Integer;
begin
  P := Pos(FBlockName, VarName);
  if P > 0 then
  begin
    Result :=  Format('%s.FieldByName("%s").Value', [FBlockName,
      System.Copy(VarName, Length(FBlockName) + 2, Length(VarName) -
      Length(FBlockName) - 1)]);
  end else
    Result := inherited GetVarScript(VarName);
end;

class function TSQLCycleBlock.NamePrefix: string;
begin
  Result := 'SQLCycle';
end;

procedure TSQLCycleBlock.SetFields(const Value: string);
begin
  FFields := Value;
end;

procedure TSQLCycleBlock.SetParams(const Value: string);
begin
  FParams := Value;
end;

procedure TSQLCycleBlock.SetSQL(const Value: string);
begin
  FSQL := Value;
end;

{ TUserDefinedBlock }

procedure TUserDefinedBlock.SetFormName(const Value: string);
begin
  FFormName := Value;
end;

procedure TUserDefinedBlock.SetTemplate(const Value: string);
begin
  FTemplate := Value;
end;

{ TBalanceOffTrEntryPositionBlock }

class function TBalanceOffTrEntryPositionBlock.CheckParent(
  AParent: TVisualBlock): Boolean;
var
  P: TControl;
begin
  Result := False;
  P := AParent;
  while P <> nil do
  begin
    Result := P is TTrEntryBlock;
    if Result then
      Break
    else
      P := P.Parent;
  end;

  Result := not Result;
end;

destructor TBalanceOffTrEntryPositionBlock.Destroy;
begin
  FTrEntryBlock.Free;

  inherited;
end;

procedure TBalanceOffTrEntryPositionBlock.DoGenerate(S: TStrings;
  Paragraph: Integer);
var
  lS: String;
begin
  lS := StringOfChar(' ', Paragraph);
  S.Add(lS + 'RecordKey = gdcEntry.GetNextId(True)');
  S.Add(lS + 'DebitNcu = 0');
  S.Add(lS + 'CreditNcu = 0');
  S.Add(lS + 'DebitCurr = 0');
  S.Add(lS + 'CreditCurr = 0');
  S.Add(lS + 'DebitEq = 0');
  S.Add(lS + 'CreditEq = 0');

  TrEntry.CompanyRUID := FCompanyRUID;
  TrEntry.EntryDate := FEntryDate;
  TrEntry.EntryDescription := FEntryDescription;

  inherited;

  if MainFunction is TTrEntryFunctionBlock then
  begin
     if not TTrEntryFunctionBlock(MainFunction).SaveEmpty then
     begin
       S.Add(lS + 'IsZero = (DebitNcu = 0) and (CreditNcu = 0) and _ ');
       S.Add(lS + '  (DebitCurr = 0) and (CreditCurr = 0) and _ ');
       S.Add(lS + '  (DebitEq = 0) and (CreditEq = 0) ');
       S.Add(lS + 'If IsZero Then ');
       S.Add(lS + '  gdcEntry.Close');
       S.Add(lS + '  Call gdcBaseManager.ExecSingleQuery("DELETE FROM ac_record WHERE id = (" & _ ');
       S.Add(lS + '    CStr(RecordKey) & ")", Transaction )');
       S.Add(lS + '  gdcEntry.Open');
       S.Add(lS + 'End If');
     end;
  end;
end;

procedure TBalanceOffTrEntryPositionBlock.DoLoadFromStream(
  Stream: TStream);
begin
  inherited;

  FCompanyRUID := ReadStringFromStream(Stream);
  FEntryDate := ReadStringFromStream(Stream);
  FEntryDescription := ReadStringFromStream(Stream);
end;

procedure TBalanceOffTrEntryPositionBlock.DoSaveToStream(Stream: TStream);
begin
  inherited;

  SaveStringToStream(FCompanyRUID, Stream);
  SaveStringToStream(FEntryDate, Stream);
  SaveStringToStream(FEntryDescription, Stream);
end;

function TBalanceOffTrEntryPositionBlock.Get: TTrEntryBlock;
begin
  if FTrEntryBlock = nil then
  begin
    FTrEntryBlock := TTrEntryBlock.Create(Self);
    BlockList.Extract(FTrEntryBlock);
  end;

  Result := FTrEntryBlock;  
end;

function TBalanceOffTrEntryPositionBlock.GetEditFrame: TFrameClass;
begin
  {$IFDEF GEDEMIN}
  Result := TfrBalanceOffTrEntry;
  {$ELSE}
  Result := nil;
  {$ENDIF}
end;

function TBalanceOffTrEntryPositionBlock.HeaderPrefix: string;
begin
  Result := 'Забалансовая проводка';
end;

class function TBalanceOffTrEntryPositionBlock.NamePrefix: string;
begin
  Result := 'BalanceOffTrPosEntry'
end;

procedure TBalanceOffTrEntryPositionBlock.SetCompanyRUID(
  const Value: string);
begin
  FCompanyRUID := Value;
end;

procedure TBalanceOffTrEntryPositionBlock.SetEntryDate(
  const Value: string);
begin
  FEntryDate := Value;
end;

procedure TBalanceOffTrEntryPositionBlock.SetEntryDescription(
  const Value: String);
begin
  FEntryDescription := Value;
end;

{ TSQLBlock }


procedure TSQLBlock.DoGenerate(S: TStrings; Paragraph: Integer);
var
  lS: string;
  SQLName: string;
  Strings: TStrings;
  I: Integer;
begin
  Strings := TStringList.Create;
  try
    lS := StringOfChar(' ', Paragraph);
    SQLName := FBlockName;

    S.Add(lS + Format('If Not Assigned(%s) Then', [SQLName]));
    S.Add(lS + Format('  Set %s = Creator.GetObject(null, "TIBSQL", "")', [SQLName]));
    S.Add(lS + Format('  %s.Transaction = Transaction', [SQLName]));
    S.Add(lS + Format('  %s.SQL.Text = _', [SQLName]));
    Strings.Text := FSQL;
    for I := 0 to Strings.Count - 1 do
    begin
      if I > 0 then S[S.Count - 1] := S[S.Count - 1] + ' + _';
      S.Add(lS + Format('  " %s "', [Strings[I]]));
    end;
    S.Add(lS + Format('  %s.Prepare', [SQLName]));

    S.Add(lS + 'End If');

    S.Add(lS + Format('%s.Close', [SQLName]));

    Strings.Text := Params;

    if Strings.Count > 0 then
    begin
      for I := 0 to Strings.Count - 1 do
      begin
        S.Add(lS + Format('%s.ParamByName("%s").AsVariant = %s', [SQLName,
          Strings.Names[I], GenerateExpression(Strings.Values[Strings.Names[I]])]));
      end;
    end;

    S.Add(lS + Format('%s.ExecQuery', [SQLName]));
  finally
    Strings.Free;
  end;
end;

procedure TSQLBlock.GetVars(const Strings: TStrings);
var
  SQL: TIBSQL;
  I: Integer;
  Names: TStrings;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQl.Text := FSQL;
    try
      SQL.Prepare;
      Names := TStringList.Create;
      try
        Names.Text := SQL.Current.Names;
        for I := 0 to Names.Count - 1 do
        begin
          Strings.AddObject(Format('%s_%s', [FBlockName, Names[I]]) +
            '=' + Format('Значение поля %s запроса ''%s''', [Names[I],
            Header]), Self);
        end;
      finally
        Names.Free;
      end;
    except
    end;
  finally
    SQL.Free;
  end;
end;

function TSQLBlock.HasBody: boolean;
begin
  Result := False;
end;

function TSQLBlock.HeaderColor: TColor;
begin
  Result := RGB(252, 224, 233)
end;

function TSQLBlock.HeaderPrefix: string;
begin
  Result := 'Запрос'
end;

class function TSQLBlock.NamePrefix: string;
begin
  Result := 'SQL';
end;

{ TCaseElseBlock }

function TCaseElseBlock.BodyColor: TColor;
begin
  Result := $FAE7F7
end;

class function TCaseElseBlock.CheckParent(AParent: TVisualBlock): Boolean;
var
  I: Integer;
begin
  Result := AParent is TSelectBlock;
  if Result then
  begin
    for I := 0 to AParent.ControlCount - 1 do
    begin
      if AParent.Controls[I] is TCaseElseBlock then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;
end;

procedure TCaseElseBlock.DoGenerate(S: TStrings; Paragraph: Integer);
begin
  S.Add(StringOfChar(' ',Paragraph) + 'Case Else');
  Inc(Paragraph, 2);
  inherited DoGenerate(S, Paragraph);
end;

procedure TCaseElseBlock.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  inherited;
end;

function TCaseElseBlock.HasFootter: boolean;
begin
  Result := False;
end;

function TCaseElseBlock.HeaderColor: TColor;
begin
  Result := RGB(203, 231, 250)
end;

function TCaseElseBlock.HeaderPrefix: string;
begin
  Result := 'Выбор иначе'
end;

class function TCaseElseBlock.NamePrefix: string;
begin
  Result := 'Case_Else'
end;

initialization
  RegisterClass(TVisualBlock);
  RegisterClass(TFunctionBlock);
  RegisterClass(TCycleBlock);
  RegisterClass(TAccountCycleBlock);
  RegisterClass(TIfBlock);
  RegisterClass(TElseBlock);
  RegisterClass(TVarBlock);
  RegisterClass(TEntryBlock);
  RegisterClass(TUserBlock);
  RegisterClass(TScriptBlock);
  RegisterClass(TEntryFunctionBlock);
  RegisterClass(TEntryCycleBlock);
  RegisterClass(TTaxVarBlock);
  RegisterClass(TTaxFunctionBlock);
  RegisterClass(TTrEntryFunctionBlock);
  RegisterClass(TTrEntryPositionBlock);
  RegisterClass(TTrEntryBlock);
  RegisterClass(TWhileCycleBlock);
  RegisterClass(TForCycleBlock);
  RegisterClass(TSelectBlock);
  RegisterClass(TCaseBlock);
  RegisterClass(TCaseElseBlock);
  RegisterClass(TTransactionBlock);
  RegisterClass(TDocumentTransactionFunction);
  RegisterClass(TSQLCycleBlock);
  RegisterClass(TBalanceOffTrEntryPositionBlock);
  RegisterClass(TSQLBlock);

  BlockList := TList.Create;
  NameList := TStringList.Create;
  IncludeList := TStringList.Create;
  
finalization
  BlockList.Free;
  NameList.Free;
  IncludeList.Free;

  UnRegisterClass(TVisualBlock);
  UnRegisterClass(TFunctionBlock);
  UnRegisterClass(TCycleBlock);
  UnRegisterClass(TAccountCycleBlock);
  UnRegisterClass(TIfBlock);
  UnRegisterClass(TElseBlock);
  UnRegisterClass(TCaseElseBlock);
  UnRegisterClass(TVarBlock);
  UnRegisterClass(TEntryBlock);
  UnRegisterClass(TUserBlock);
  UnregisterClass(TScriptBlock);
  UnregisterClass(TEntryFunctionBlock);
  UnregisterClass(TEntryCycleBlock);
  UnregisterClass(TTaxVarBlock);
  UnregisterClass(TTaxFunctionBlock);
  UnRegisterClass(TTrEntryFunctionBlock);
  UnRegisterClass(TTrEntryPositionBlock);
  UnRegisterClass(TTrEntryBlock);
  UnRegisterClass(TWhileCycleBlock);
  UnRegisterClass(TForCycleBlock);
  UnRegisterClass(TSelectBlock);
  UnRegisterClass(TCaseBlock);
  unregisterClass(TTransactionBlock);
  UnRegisterClass(TDocumentTransactionFunction);
  UnRegisterClass(TSQLCycleBlock);
  UnRegisterClass(TBalanceOffTrEntryPositionBlock);
  UnRegisterClass(TSQLBlock);
end.


