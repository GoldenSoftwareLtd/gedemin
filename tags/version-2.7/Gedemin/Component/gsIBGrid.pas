
{++

  Copyright (c) 2000-2015 by Golden Software of Belarus

  Module

    gsIBGrid.pas

  Abstract

    Original Delphi's DBGrid with additional options of Interbase.

  Author

    Romanovski Denis (31-08-2000)

  Revisions history

    Initial  31-08-2000  Dennis  Initial version.
             25-10-2001  Nick Изменена работа Inplace Editor
                         Добавлены объекты для работы со множествами(простыми и древовидными),
                         Лукапом, Списком, CheckBox - ом, Датой, Калькулятором
                         для полей типа Date, Time, DateTime автоматически подставляется маска
                         редактирования с автозаполнением.
             29-10-2001  Dennis Добавлено свойство в TLookup - subtype. Необходимо
                         для работы с базовым классом. Также добавлено поле типа
                         TIBBase для хранения транзакции и подключения. Соответствующие
                         published совйства добавлены TLookup.
             30-10-2001  Nick Для текстовых полей добавлен InplaceEditor в виде выподающего Memo
                         тип редактора определяется автоматически
             02-11-2001  Nick Во встренном редакторе добавлен тип cesGraphic и добавлен диалог
                         для просмотра загрузки и сохранения картинок в формате bmp
             05-11-2001  Nick Добавлена расширяемая панель
             06-11-2001  Nick Lookup, SetGrid и SetTree переложены на раздвижную панель,
                         В Lookup изменена обработка редактирования и удаления.
             08-11-2001  Nick ListBox переложен на раздвижную панель,
             25-04-2002  Nick Обновлен Lookup
--}

unit gsIBGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, StdCtrls, ComCtrls, Menus, ActnList, DB, IBDatabase,
  IBCustomDataSet, IBQuery, IBSQL, gsDBGrid, Contnrs, at_classes, dbctrls,
  gdcBase, JclStrHashMap;

type
  TgsSortOrder = (soNone, soAsc, soDesc);
  TgsViewType = (vtByClass, vtTree, vtGrid);

const
  DefSortOrder       = soNone;
  DefCheckUserRights = True;
  DefDropDownCount   = 8;
  MESSAGE_SHIFT      = WM_USER + $500;
  CM_DOREDUCE        = MESSAGE_SHIFT + 1;
  
type
  EDuplicateEditor = Exception;
  TgsCustomIBGrid = class;
  TgsIBColumn = class;

  TgsIBColumnTitle = class(TgsColumnTitle)
  private
    function GetGrid: TgsCustomIBGrid;
    function GetColumn: TgsIBColumn;

  protected
    function IsAlignmentStored: Boolean; override;
    function IsCaptionStored: Boolean; override;

    property Grid: TgsCustomIBGrid read GetGrid;
    property Column: TgsIBColumn read GetColumn;

  public

  end;

  TgsIBColumn = class(TgsColumn)
  private
    function GetRelationField: TatRelationField;
    function GetGrid: TgsCustomIBGrid;

    function CountWidth: Integer;

  protected
    function CreateTitle: TColumnTitle; override;

    function IsAlignmentStored: Boolean; override;
    function IsColorStored: Boolean; override;
    function IsFontStored: Boolean; override;
    function IsWidthStored: Boolean; override;
    function IsVisibleStored: Boolean; override;
    function IsDisplayFormatStored: Boolean; override;

    function IsRelationFieldValid: Boolean;

    property RelationField: TatRelationField read GetRelationField;
    property Grid: TgsCustomIBGrid read GetGrid;

  public
    procedure RestoreDefaults; override;
  end;

  TgsIBColumnEditorStyle = (cesNone, cesEllipsis, cesLookup, cesDate,
                            cesMemo, cesCalculator, cesValueList, cesSetGrid,
                            cesSetTree, cesGraphic);
  TgsIBColumnEditor = class;

  TLookup = class(TPersistent)
  private
    FEditor: TgsIBColumnEditor;
    FLookupListField: String;
    FLookupKeyField: String;
    FParentField: String;
    FLookupTable: String;
    FCondition: String;
    FgdClassName: String;
    FCheckUserRights: Boolean;
    FSortOrder: TgsSortOrder;
    FViewType: TgsViewType;
    FSubType: String;
    FIBBase: TIBBase;
    FGroupBY: String;
    FIsTree: Boolean;
    FFields: String;                // список полей расширенного отображения
    FCountAddField: Integer;        // количество дополнительных полей
    FParams: TStrings;              // Параметры
    FDistinct: Boolean;
    FFullSearchOnExit: Boolean;     // По выходу из лукапа если True то поиск по полному совпадению
                                    // Если False по вхождению. По умолчанию True
    procedure SetLookupListField(const Value: String);
    procedure SetLookupKeyField(const Value: String);
    procedure SetLookupTable(const Value: String);
    procedure SetgdClassName(Value: String);
    procedure SetCondition(const Value: String);
    function GetDatabase: TIBDatabase;
    function GetTransaction: TIBTransaction;
    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetGroupBy(const Value: String);
    procedure SetFields(const Value: String);
    function FieldWithAlias(AFieldName: String): String;
    function GetParams: TStrings;
    function GetMainTableAlias: String;
    function GetMainTableName: String;
    procedure SetDistinct(const Value: Boolean);
    function GetDistinct: Boolean;
    procedure SetFullSearchOnExit(const Value: Boolean);
    function GetFullSearchOnExit: Boolean;
    procedure SetViewType(const Value: TgsViewType);
    procedure SetSubType(const Value: String);

  public
    constructor Create(Owner: TgsIBColumnEditor);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property IsTree: Boolean read FIsTree;
    property ParentField: string read FParentField;
    property MainTableName: String read GetMainTableName;
    property MainTableAlias: String read GetMainTableAlias;

  published
    property LookupListField: String read FLookupListField write SetLookupListField;
    property LookupKeyField: String read FLookupKeyField write SetLookupKeyField;
    property LookupTable: String read FLookupTable write SetLookupTable;
    property Condition: String read FCondition write SetCondition;
    property GroupBY: String read FGroupBY write SetGroupBy;
    property CheckUserRights: Boolean read FCheckUserRights write FCheckUserRights
     default DefCheckUserRights;
    property SortOrder: TgsSortOrder read FSortOrder write FSortOrder
     default DefSortOrder;
    property ViewType: TgsViewType read FViewType write SetViewType default vtByClass;
    property gdClassName: String read FgdClassName write SetgdClassName;
    property SubType: String read FSubType write SetSubType;
    property Database: TIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;
    property Fields: String read FFields write SetFields;
    property Params: TStrings read GetParams;
    property Distinct: Boolean read GetDistinct write SetDistinct;
    property FullSearchOnExit: Boolean read GetFullSearchOnExit write SetFullSearchOnExit Default True;
  end;

  TSet = class(TPersistent)
  private
    FEditor: TgsIBColumnEditor;

    FKeyField: String;   //Ключевое поле  текущей таблицы
    FSourceKeyField: String; //Ключевое поле таблицы множества
    FSourceListField: String; //Поле просмотра таблицы множества
    FSourceParentField: String; //Поле ссылки на родителя в таблице множества
    FCrossDestField: String; //Ссылка на ключевое поле текущей таблицы
    FCrossSourceField: String; //Ссылка на ключевое поле таблицы множества
    FSourceTable: String; //Таблица множества
    FCrossTable: String;  //Таблица пересечений
    procedure SetSourceKeyField(const Value: String);
    procedure SetSourceListField(const Value: String);
    procedure SetSourceParentField(const Value: String);
    procedure SetCrossDestField(const Value: String);
    procedure SetCrossSourceField(const Value: String);
    procedure SetSourceTable(const Value: String);
    procedure SetCrossTable(const Value: String);

  public
    constructor Create(Owner: TgsIBColumnEditor);
    procedure Assign(Source: TPersistent); override;

  published
    property KeyField: String read FKeyField write FKeyField;
    property SourceKeyField: String read FSourceKeyField write SetSourceKeyField;
    property SourceListField: String read FSourceListField write SetSourceListField;
    property SourceParentField: String read FSourceParentField write SetSourceParentField;
    property CrossDestField: String read FCrossDestField write SetCrossDestField;
    property CrossSourceField: String read FCrossSourceField write SetCrossSourceField;
    property SourceTable: String read FSourceTable write SetSourceTable;
    property CrossTable: String read FCrossTable write SetCrossTable;
  end;

  TgsIBColumnEditor = class(TCollectionItem)
  private
    FEditorStyle: TgsIBColumnEditorStyle;
    FFieldName: String;
    FDisplayField: String;
    FValueList: TStringList;

    FRevertValueList: TStringLIst;

    FPickList: TStringList;

    FLookupDataSet: TIBDataSet;
    FLookupDataSource: TDatasource;
    FDropDownCount: Integer;
    FLookupPrepared: Boolean;
    FLookuped: boolean;
    FgdClass: CgdcBase;

//  Поля для Set's
    FCrossDataset: TibDataset;
    FSourceDataset: TibQuery;
    FSetPrepared: Boolean;
    FSourceDataSource: TDatasource;
    FLookup: TLookup;
    FSet: TSet;

    FListFieldIsBlob: Boolean;

    FText: String;

    procedure SetFieldName(const Value: String);
    procedure SetDisplayField(const Value: String);
    procedure ValueListOnChange(Sender: TObject);
    function GetGrid: TgsCustomIBGrid;
    procedure SetValueList(Value: TStringList);
    function GetPickList: TStringList;
    function GetLookupSource: TDataSource;
    function PrepareLookup: boolean;

    function PrepareSet: boolean;
    function GetSetDatasource: TDataSource;


    function CreateGDClassInstance(const AnID: Integer): TgdcBase;
    function GetFullCondtion: String;
    procedure SetEditorStyle(const Value: TgsIBColumnEditorStyle);
    procedure DropDown(const Match: String = ''; const UseExisting: Boolean = False);
    procedure SetLookup(Value: TLookup);
    procedure SetPopupSet(Value: TSet);
  protected

    property PickList: TStringList read GetPickList;
    property LookupDataSource: TDataSource read GetLookupSource;
    property SetDatasource: TDataSource read GetSetDatasource;
    procedure RefreshDataset;
    function DoLookup(const Exact: Boolean = False; const ShowMsg: Boolean = True): boolean;
    function CreateNew: Integer;
    procedure ObjectProperties(const Value: Integer);
    function ViewForm: Integer;
    function Edit(const Value: Integer): Boolean;
    function Delete(const Value: Integer): Boolean;

    function Reduce(var Value: Integer): Boolean;

    property FullCondition: String read GetFullCondtion;
  public

    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Grid: TgsCustomIBGrid read GetGrid;
    property Text: String read FText;

  published
    property Lookup: TLookup read FLookup write SetLookup;
    property LookupSet: TSet read FSet write SetPopupSet;
    property EditorStyle: TgsIBColumnEditorStyle read FEditorStyle write SetEditorStyle;
    property FieldName: String read FFieldName write SetFieldName;
    property DisplayField: String read FDisplayField write SetDisplayField;
    property ValueList: TStringList read FValueList write SetValueList;


    property DropDownCount: Integer read FDropDownCount write FDropDownCount;
  end;

  TgsIBColumnEditors = class(TCollection)
  private
    FGrid: TgsCustomIBGrid; // Таблица, которой принадлежит данный список

    function GetEditor(Index: Integer): TgsIBColumnEditor;
    procedure SetEditor(Index: Integer; const Value: TgsIBColumnEditor);

  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create(Grid: TgsCustomIBGrid);
    destructor Destroy; override;
    function IndexByField(Const Name:String): Integer;
    function Add: TgsIBColumnEditor;

    // Таблица, которой принадлежит коллекция
    property Grid: TgsCustomIBGrid read FGrid;
    // Элемент коллекции по индексу
    property Items[Index: Integer]: TgsIBColumnEditor read GetEditor write SetEditor; default;
  end;

  TFieldAliases = class;

  TFieldAlias = class(TCollectionItem)
  private
    FAlias: String;
    FLName: String;

    procedure SetAlias(const Value: String);
    procedure SetLName(const Value: String);
    function GetGrid: TgsCustomIBGrid;

  protected
    function GetDisplayName: string; override;

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    // Визуальная таблица
    property Grid: TgsCustomIBGrid read GetGrid;

  published
    // Наименование поля на английском в дата сете
    property Alias: String read FAlias write SetAlias;
    // Локализация поля
    property LName: String read FLName write SetLName;

  end;


  TFieldAliases = class(TCollection)
  private
    FGrid: TgsCustomIBGrid; // Таблица, которой принадлежит данный список

    function GetAlias(Index: Integer): TFieldAlias;
    procedure SetAlias(Index: Integer; const Value: TFieldAlias);

  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create(Grid: TgsCustomIBGrid);
    destructor Destroy; override;

    function  Add: TFieldAlias;

    function FindAlias(const AliasName: String; out Alias: TFieldAlias): Boolean;

    // Визуальная таблица
    property Grid: TgsCustomIBGrid read FGrid;
    // Элемент коллекции по индексу
    property Items[Index: Integer]: TFieldAlias read GetAlias write SetAlias; default;

  end;

  TOnCreateNewObject = procedure(Sender: TObject; ANewObject: TgdcBase)
    of object;

  TgsCustomIBGrid = class(TgsCustomDBGrid)
  private
    FOrigins: TStringHashMap;
    FAliases: TFieldAliases;

    FColumnEditors: TgsIBColumnEditors; // Коллекция редакторов
    FOnCreateNewObject: TOnCreateNewObject;

    procedure QueryChanged(Sender: TObject; WithPlan: Boolean);
    procedure DefaultsClick(Sender: TObject);

    procedure ReadFieldOrigins;
    function FindFieldOrigin(const FieldName: String): TatRelationField;

    procedure SetAliases(const Value: TFieldAliases);
    procedure SetColumnEditors(const Value: TgsIBColumnEditors);

    procedure HideInplaceEdit;


  protected
    function CreateColumns: TDBGridColumns; override;
    function CreateEditor: TInplaceEdit; override;

    procedure LayoutChanged; override;
    procedure LinkActive(Active: Boolean); override;


    function GetEditMask(ACol, ARow: Longint): string; override;
    function GetEditText(ACol, ARow: Longint): string; override;

    procedure SetEditText(ACol, ARow: Longint; const Value: string); override;

    procedure GetValueFromValueList(AColumn: TColumn; var AValue: String); override;

    class function GridClassType: TgsDBGridClass; override;
    class function GetColumnClass: TgsColumnClass; override;

    property Aliases: TFieldAliases read FAliases write SetAliases;

    property Canvas;

    property ColumnEditors: TgsIBColumnEditors read FColumnEditors write SetColumnEditors;
    property OnCreateNewObject: TOnCreateNewObject read FOnCreateNewObject write FOnCreateNewObject;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure ValidateColumns; override;
    procedure PrepareMaster(AMaster: TForm); override;
    procedure SetupGrid(AMaster: TForm; const UpdateGrid: Boolean = True); override;

    procedure Read(Reader: TReader); override;
    procedure Write(Writer: TWriter); override;


  end;


  TgsIBGrid = class(TgsCustomIBGrid)
  private

  protected

  public
    property Canvas;
    property SelectedRows;

  published

    // Свойства, перешедшие из стандартного TCustomDBGrid

    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Columns stored False;
    property Constraints;
    property Ctl3D;
    property DataSource;
    property DefaultDrawing;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ImeMode;
    property ImeName;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDrawDataCell;
    property OnDrawColumnCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditButtonClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;

    // Свойства добавленные и измененные TgsCustomDBGrid


    property TableFont;
    property TableColor;

    property SelectedFont;
    property SelectedColor;

    property TitleFont;
    property TitleColor;

    property RefreshType;

    property Striped;
    property StripeOdd;
    property StripeEven;

    property InternalMenuKind;

    property Expands;
    property ExpandsActive;
    property ExpandsSeparate;
    property TitlesExpanding;

    property Conditions;
    property ConditionsActive;

    property CheckBox;

    property ScaleColumns;
    property MinColWidth;
    property ToolBar;

    property FinishDrawing;

    property RememberPosition;

    property SaveSettings default True;

    //  Свойства из TgsCustomIBGrid

    property ColumnEditors;
    property Aliases;

    //
    property ShowFooter;
    property ShowTotals;

    //
    //property OnAggregateChanged;
    property OnClickCheck;
    property OnClickedCheck;
    property OnCreateNewObject;

    //
    property OnGetFooter;
    property OnGetTotal;
  end;



procedure Register;

implementation

uses
  gsDBGrid_dlgMaster, DsgnIntf, mask, extctrls, jclSysUtils, gd_security,
  gsDBReduction, gsDBTreeView, dlgPictureDialog_unit, buttons, gdc_frmG_unit,
  gdcTree, gdcClasses, gdcBaseInterface, gdc_frmMDH_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , gdvAcctBase;

{$R gsIBGrid.RES}

const
  VertSkip = 19;
  HorizSkip = 10;
  Between = 2;

  ButtonWidth = 20;
  ButtonHeight = 20;

  EqualWidth = 42;

  VertNumber = 5;
  HorizNumber = 4;

  ToolBarHeight = 16;
type
  TIBStringProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

{ TPopupListbox }
  TgsIBGridInplaceEdit = class;

  TPopupPanel = class(TPanel)
  private
    FbtnGrow: TSpeedButton;
    FbtnShrink: TSpeedButton;
    FToolbar: TPanel;
    FShrinkAction: TAction;
    FGrowAction: TAction;
    FMinWidth: Integer;
    FRowCount: Integer;
    FMainControl: TWinControl;

    procedure ShrinkExecute(Sender: TObject);
    procedure GrowExecute(Sender: TObject);
    procedure SetRowCount(const Value: Integer);
    procedure SetMainControl(Control: TWinControl);

  protected
    FEditor: TgsIBGridInplaceEdit;

    procedure SetMinWidth(const Value: Integer); virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WndProc(var Message: TMessage); override;
    procedure AddButton(Button: TSpeedButton; ALeftAlign: boolean = True);
    property MinWidth: Integer read FMinWidth write SetMinWidth;
    property RowCount: Integer read FRowCount write SetRowCount;
    property MainControl: TWinControl read FMainControl write SetMainControl;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TPopupListbox = class(TPopupPanel)
  private
    FListBox: TListBox;
    FSearchText: String;
    FSearchTickCount: Longint;
    procedure ListKeyPress(Sender: TObject; var Key: Char);
    procedure ListMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TPopupMemo = class(TMemo)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;

  end;

  TPopupCalculator = class(TCustomControl)
  private
    FCalcImage: TImage; // Рисунок калькулятора
    FPressedButton: TPoint; // Коодинаты нажатой клавиши
    FBtnRect: TRect; // Экранные координаты нажатой клавиши
    FIsInverted: Boolean; // Произведена ли инвертация
    FCalculatorEdit: TgsIBGridInplaceEdit; // Класс калькулятора
    FIsFirst: Boolean; // Первый раз
    procedure WMMouseActivate(var Message: TWMMouseActivate);
      message WM_MouseActivate;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging);
      message WM_WINDOWPOSCHANGING;
    procedure DoOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    function GetPressedButton(Pos: TPoint; var BtnRect: TRect): TPoint;
    procedure InvertPressedButton;
    procedure InvertByPos(APos: TPoint);

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWND; override;
    procedure Click; override;
  public
    constructor Create(AnOwner: TComponent); override;

  published
  end;


  TPopupCalendar = class(TMonthCalendar)
  private
    FMonthChanged: Boolean;

    procedure SetMonth(Sender: TObject; Month: LongWord; var MonthBoldInfo: LongWord);
  protected
    procedure CreateWnd; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(Owner: TComponent); override;
  end;

  TPopupLookup = class(TPopupPanel)
  private
    FGrid: TgsIBGrid;
    FTV: TgsDBTreeView;

    FListSource: TDataSource;
    FListField: String;
    FKeyField: String;
    FParentField: String;

    FbtnNew: TSpeedButton;
    FbtnEdit: TSpeedButton;
    FbtnDelete: TSpeedButton;
    FbtnMerge: TSpeedButton;
    FTree: Boolean;

    function GetKeyValue: Variant;
    function GetListValue: Variant;
    procedure SetKeyValue(Value: Variant);
    procedure SetListSource(Value: TDataSource);
    procedure NewExecute(Sender: TObject);
    procedure DeleteExecute(Sender: TObject);
    procedure MergeExecute(Sender: TObject);
    procedure EditExecute(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure GridCellClick(Column: TColumn);
    procedure SetTree(const Value: Boolean);
    procedure SetParentField(const Value: String);
    procedure SetKeyField(const Value: String);
    procedure SetListField(const Value: String);
  protected
    procedure SetMinWidth(const Value: Integer); override;
    procedure AssignExpands;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    property KeyValue: Variant read GetKeyValue write SetKeyValue;
    property ListValue: Variant read GetListValue;
    property KeyField: String read FKeyField write SetKeyField;
    property ListField: String read FListField write SetListField;
    property ListSource: TDataSource read FListSource write SetListSource;
    property Tree: Boolean read FTree write SetTree;
    property ParentField: String read FParentField write SetParentField;
  end;

  TPopupSetGrid = class(TPopupPanel)
  private
    FSetGrid: TgsDBGrid;
    FMenu: TPopupMenu;
    FCurrentKey: Variant;
    FSetState: Boolean;

    procedure GridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CheckBoxSet(Sender: TObject; CheckID: String; var Checked: Boolean);

    procedure SelectAll(Sender: TObject);
    procedure RemoveAll(Sender: TObject);

  protected

    procedure SetupCheckBoxes;
    procedure ClearCheckBoxes;

    function ApplyChanges: String;
    procedure CancelChanges;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TPopupSetTree = Class;

  TPopupTree = class(TgsDBTreeView)
  private
    FParent: TPopupSetTree;
  protected
    procedure SetCheck(Node: TTreeNode; Check: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TPopupSetTree = class(TPopupPanel)
  private
    FSetTree: TPopupTree;

    FLoading: Boolean;
    FList, FNames: TStringList;
    FMenu: TPopupMenu;
    FCurrentKey: Integer;

    procedure SelectAll(Sender: TObject);
    procedure RemoveAll(Sender: TObject);

  protected

    procedure SetupCheckBoxes;
    procedure ClearCheckBoxes;

    function ApplyChanges: String;
    procedure CancelChanges;


  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;


  TExpressionAction = (eaPlus, eaMinus, eaDevide, eaMultiple, eaEqual, eaNone);

  TgsIBGridInplaceEdit = class(TInplaceEdit)
  private
    FOldValue: Double; // Предыдущее значение (до ввода знаков +-*/ и т.п.)
    FOldValueEntered: Boolean; // Введено ли предыдущее чмсло
    FNeedToChangeValue: Boolean; // Нужно ли разрешать ввод нового числа
    FExpressionAction: TExpressionAction; // Вид действия
    FDecDigits: Word; // Кол-во цифр после разделителя целой и дробной частей

    FButtonWidth: Integer;
    FDataList: TPopupLookup;
    FPickList: TPopupListbox;
    FPopupCalendar: TPopupCalendar;
    FPopupCalculator: TPopupCalculator;
    FPopupSetGrid: TPopupSetGrid;
    FPopupSetTree: TPopupSetTree;
    FPopupMemo: TPopupMemo;
    FPictureDialog: TdlgPictureDialog;
    FActiveList: TWinControl;

    FEditStyle: TgsIBColumnEditorStyle;
    FListVisible: Boolean;
    FTracking: Boolean;
    FPressed: Boolean;
    FLookup: TLookup;
    FCurrentEditor: TgsIBColumnEditor;
    FCanEdit: Boolean;
    FFieldType: TFieldType;
    FInKeyProcessing: Boolean;
    //
    procedure ChangeInvertion;
    function GetValue: Double;
    procedure SetValue(AValue: Double);
    //
    procedure SetEditStyle(Value: TgsIBColumnEditorStyle);
    procedure StopTracking;
    procedure TrackButton(X,Y: Integer);
    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CancelMode;

    procedure WMCancelMode(var Message: TMessage); message WM_CancelMode;
    procedure WMKillFocus(var Message: TMessage); message WM_KillFocus;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message wm_LButtonDblClk;
    procedure WMPaint(var Message: TWMPaint); message wm_Paint;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SetCursor;

    procedure CMDoReduce(var Message: TMessage); message CM_DOREDUCE;

    function OverButton(const P: TPoint): Boolean;
    function ButtonRect: TRect;
  protected
    function IsValidChar(Key: Char): Boolean; virtual;
    procedure KeyPress(var Key: Char); override;
    procedure BoundsChanged; override;
    procedure CloseUp(Accept: Boolean; const AHideEditor: boolean = True);
    procedure DoDropDownKeys(var Key: Word; Shift: TShiftState);
    procedure DropDown;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure PaintWindow(DC: HDC); override;
    procedure UpdateContents; override;
    procedure WndProc(var Message: TMessage); override;

    property  EditStyle: TgsIBColumnEditorStyle read FEditStyle write SetEditStyle;
    property  ActiveList: TWinControl read FActiveList write FActiveList;
    property DataList: TPopupLookup read FDataList;
    property PickList: TPopupListbox read FPickList;
    property PopupSetGrid: TPopupSetGrid read FPopupSetGrid;
    property PopupSetTree: TPopupSetGrid read FPopupSetGrid;
    property PopupCalendar: TPopupCalendar read FPopupCalendar;
    property PopupCalculator: TPopupCalculator read FpopupCalculator;

    property Value: Double read GetValue write SetValue;
  public

    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
  end;

function GetFieldNameWithoutAlias(const FullFieldName: String): String;
var
  I: Integer;
begin
  I := Pos('.', FullFieldName);
  if I > 0 then
  begin
    Result := Copy(FullFieldName, I + 1, Length(FullFieldName));
  end else
    Result := FullFieldName;
end;

procedure TimeDelay(Pause: LongWord; DoProcessMessages: Boolean);
var
  OldTime: LongWord;
begin
  OldTime := GetTickCount;
  while GetTickCount - OldTime <= Pause do
    if DoProcessMessages then Application.ProcessMessages;
end;

function GetDateMask: String;
begin
  Result := '!90/90/0000;1;_'
end;

function GetTimeMask: String;
begin
  Result := '!90:00:00;1;_'
end;

function GetDateTimeMask: String;
begin
  Result := '!90/90/0000 !90:00:00;1;_'
end;

constructor TPopupListbox.Create(AnOwner: TComponent);
begin
  inherited;
  FListBox := TListBox.Create(Self);
  FListBox.OnKeyPress := ListKeyPress;
  FListBox.OnMouseUp := ListMouseUp;
  FListBox.OnMouseDown := ListMouseDown;
  FListBox.OnMouseMove := ListMouseMove;

  FListBox.IntegralHeight := False;
  FListBox.ItemHeight := 11;
  MainControl := FListBox;
end;

destructor TPopupListbox.Destroy;
begin
  FListBox.Free;
  inherited;
end;

procedure TPopupListbox.ListKeyPress(Sender: TObject; var Key: Char);
var
  TickCount: Integer;
begin
  case Key of
    #8, #27: FSearchText := '';
    #32..#255:
      begin
        TickCount := GetTickCount;
        if TickCount - FSearchTickCount > 2000 then FSearchText := '';
        FSearchTickCount := TickCount;
        if Length(FSearchText) < 32 then FSearchText := FSearchText + Key;
        SendMessage(FListBox.Handle, LB_SelectString, WORD(-1), Longint(PChar(FSearchText)));
        Key := #0;
      end;
  end;
end;

procedure TPopupListbox.ListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (X >= 0) and (Y >= 0) and (X < FListBox.Width) and (Y < FListBox.Height) then
    FListBox.ItemIndex := FListBox.ItemAtPos(Point(X, Y), True);
end;

procedure TPopupListbox.ListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) and (X >= 0) and (Y >= 0) and (X < FListBox.Width) and (Y < FListBox.Height) then
    FListBox.ItemIndex := FListBox.ItemAtPos(Point(X, Y), True);
end;

procedure TPopupListbox.ListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    if (X >= 0) and (Y >= 0) and (X < FListBox.Width) and (Y < FListBox.Height) then
    begin
      FListBox.ItemIndex := FListBox.ItemAtPos(Point(X, Y), True);
      FEditor.CloseUp(True);
    end
    else
      FEditor.CloseUp(False);
  end;
end;

{TgsIBGridInplaceEditor}
constructor TgsIBGridInplaceEdit.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  FButtonWidth := GetSystemMetrics(SM_CXVSCROLL);

  FPopupCalendar := nil;
  FPopupCalculator := nil;
  FPickList := nil;
  FDataList := nil;
  FPopupSetGrid := nil;
  //FPopupPanel := nil;
  FPopupSetTree := nil;
  FPopupMemo := nil;
  FLookup := nil;
  FPictureDialog := nil;

  FEditStyle := cesNone;
end;

procedure TgsIBGridInplaceEdit.BoundsChanged;
var
  R: TRect;
begin
  SetRect(R, 2, 2, Width - 2, Height);
  if FEditStyle <> cesNone then
    if not TgsCustomIBGrid(Owner).UseRightToLeftAlignment then
      Dec(R.Right, FButtonWidth)
    else
      Inc(R.Left, FButtonWidth - 2);
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@R));
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
  if SysLocale.FarEast then
    SetImeCompositionWindow(Font, R.Left, R.Top);

  CloseUp(False);  
end;

procedure TgsIBGridInplaceEdit.CloseUp(Accept: Boolean; const AHideEditor: boolean);
var
  MasterField: TField;
  ListValue, KeyValue: Variant;
begin

  if FListVisible then
  begin
    if GetCapture <> 0 then SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
    if not Assigned(FActiveList) then
       Exit;
    if FActiveList = FDataList then
    begin
      ListValue := FDataList.ListValue;
      KeyValue := FDataList.KeyValue;
    end
    else if FActiveList = FPopupCalendar then
      ListValue := DateToStr(FPopupCalendar.Date)
    else if FActiveList = FPopupCalculator then
    begin
      ListValue := Text;
      FExpressionAction := eaNone;
    end
    else  if FActiveList = FPopupSetGrid then
    begin
      if Accept then
        ListValue := FPopupSetGrid.ApplyChanges
      else
        FPopupSetGrid.CancelChanges;
    end
    else  if FActiveList = FPopupSetTree then
    begin
      if Accept then
        ListValue := FPopupSetTree.ApplyChanges
      else
        FPopupSetTree.CancelChanges;
    end
    else  if FActiveList = FPopupMemo then
    begin
      ListValue := FPopupMemo.Text;
    end
    {else  if FActiveList = FPopupPanel then
    begin
      Accept := False;
    end}

    else
      if FPickList.FListBox.ItemIndex <> -1 then
      begin
        if FCurrentEditor.ValueList.Names[0] > '' then
          ListValue := FCurrentEditor.ValueList.Values[FPickList.FListBox.Items[FPicklist.FListBox.ItemIndex]]
        else
          ListValue := FPickList.FListBox.Items[FPicklist.FListBox.ItemIndex];
      end;

    SetWindowPos(FActiveList.Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);
    FListVisible := False;

    if Accept and FCanEdit then
    begin
      FInKeyProcessing := True;
      try
        if FActiveList = FDataList then
          with TgsCustomIBGrid(Grid), Columns[SelectedIndex].Field do
          begin
            MasterField := DataSet.FieldByName(FCurrentEditor.FieldName);
            try
              if MasterField.CanModify and DataLink.Edit then
                MasterField.Value := KeyValue;
              if DataSet.State in [dsEdit, dsInsert] then
                if not VarIsNULL(ListValue) then
                  Text := ListValue
                else
                  Text := '';
            except
              if DataSet.State in [dsEdit, dsInsert] then
                Text := '';
            end;
          end
        else
          if (not VarIsNull(ListValue)) and EditCanModify then
            with TgsCustomIBGrid(Grid) do
            begin
              if Columns[SelectedIndex].Field.DataType = ftMemo then
                Columns[SelectedIndex].Field.AsString := ListValue
              else
                Columns[SelectedIndex].Field.Text := ListValue;
            end;
        if Assigned(FDataList) then
          FDataList.ListSource := nil;
        Invalidate;
      finally
        FInKeyProcessing := True;
        if AHideEditor then
          TgsCustomIBGrid(Grid).HideInplaceEdit;
      end
    end;
  end;
end;

procedure TgsIBGridInplaceEdit.DoDropDownKeys(var Key: Word; Shift: TShiftState);
begin
  try
    FInKeyProcessing := True;
    case Key of
      VK_UP, VK_DOWN:
        if ssAlt in Shift then
        begin
          if FListVisible then CloseUp(True) else DropDown;
          Key := 0;
        end;
      VK_RETURN, VK_ESCAPE:
        if FListVisible and not (ssAlt in Shift) then
        begin
          CloseUp(Key = VK_RETURN, False);
          Key := 0;
        end;
    end;
  finally
    FInKeyProcessing := False;
  end;
end;

/////////!!!!!!!!
procedure TgsIBGridInplaceEdit.DropDown;
  procedure SetActiveList;
  begin
    case FEditStyle of
      cesCalculator:
      begin
        if not Assigned(FPopupCalculator) then
        begin
          FPopupCalculator := TPopupCalculator.Create(Self);
          FPopupCalculator.FCalculatorEdit := Self;
          FPopupCalculator.Visible := False;
          FPopupCalculator.AutoSize := True;
          FPopupCalculator.Parent := Self;
        end;
        FActiveList := FPopupCalculator;
      end;
      cesDate:
      begin
        if not Assigned(FPopupCalendar) then
          begin
            FPopupCalendar := TPopupCalendar.Create(Self);
            FpopupCalendar.AutoSize := True;
            FPopupCalendar.Visible := False;
            FPopupCalendar.Parent := Self;
          end;
          FActiveList := FPopupCalendar;
      end;
      cesValueList:
        begin
          if not Assigned(FPickList) then
          begin
            FPickList := TPopupListbox.Create(Self);
            FPickList.Visible := False;
          end;
          FActiveList := FPickList;
        end;
      cesLookUp:
        begin
          if not Assigned(FDataList) then
          begin
            FDataList := TPopUpLookup.Create(Self);
            FDataList.Visible := False;
          end;

          FActiveList := FDataList;
        end;
      cesSetGrid:
        begin
          if not Assigned(FPopupSetGrid) then
          begin
            FPopupSetGrid := TPopupSetGrid.Create(Self);
            FPopupSetGrid.Visible := False;
          end;

          FActiveList := FPopupSetGrid;
        end;
      cesSetTree:
        begin
          if not Assigned(FPopupSetTree) then
          begin
            FPopupSetTree := TPopupSetTree.Create(Self);
            FPopupSetTree.Visible := False;
          end;
          FActiveList := FPopupSetTree;
        end;
      cesMemo:
        begin
          FPopupMemo.Free;
          FPopupMemo := TPopupMemo.Create(Self);
          FPopupMemo.Visible := False;
          FPopupMemo.Parent := Self;
          FActiveList := FPopupMemo;
        end;
      cesGraphic:
        begin
          if not Assigned(FPictureDialog) then
          begin
            FPictureDialog := TdlgPictureDialog.Create(Nil);
            FActiveList := FPictureDialog;
          end;
        end;
      else { cbsNone, cbsEllipsis, or read only field }
        FActiveList := nil;
    end;
  end;
var
  P: TPoint;
  Y, I: Integer;
  Column: TColumn;
begin
  SetActiveList;
  if not FListVisible and Assigned(FActiveList) then
  begin
    if FActiveList <> FPictureDialog then
    begin
      if FActiveList.InheritsFrom(TPopupPanel) then
      begin
        (FActiveList As TPopupPanel).MinWidth := Width;
        (FActiveList As TPopupPanel).RowCount := 8;
      end
      else
        FActiveList.Width := Width;
    end;
    with TgsCustomIBGrid(Grid) do
      Column := Columns[SelectedIndex];

    if Column.ReadOnly then 
      exit;

    if FActiveList = FDataList then
    with Column.Field do
    begin
      if not FCurrentEditor.PrepareLookup then
      begin
        raise Exception.Create('Incorrect Lookup settings')
      end;

      FDataList.Tree := FCurrentEditor.FLookup.IsTree;
      FDataList.RowCount := FCurrentEditor.DropDownCount;
      FDataList.KeyField := GetFieldNameWithoutAlias(FCurrentEditor.FLookup.LookupKeyField);
      FDataList.ListField := GetFieldNameWithoutAlias(FCurrentEditor.Flookup.LookupListField);
      FDataList.ParentField := FCurrentEditor.FLookup.ParentField;
      FDataList.ListSource := FCurrentEditor.LookupDataSource;

      if FCurrentEditor.FLookup.gdClassName = '' then
      begin
        FDataList.FbtnNew.Visible := False;
        FDataList.FbtnEdit.Visible := False;
        FDataList.FbtnDelete.Visible := False;
        FDataList.FbtnMerge.Visible := False;
      end
      else
      begin
        FDataList.FbtnNew.Visible := True;
        FDataList.FbtnEdit.Visible := True;
        FDataList.FbtnDelete.Visible := True;
        FDataList.FbtnMerge.Visible := True;
      end;

      if not FCurrentEditor.FLookuped then
      begin
        if Self.Modified then
          FCurrentEditor.DropDown(Self.Text)
        else
          FCurrentEditor.DropDown;

        FDataList.KeyValue :=
          TgsCustomIbGrid(Grid).Datasource.DataSet.FieldByName(
          FCurrentEditor.FieldName).Value;
      end else
        FCurrentEditor.FLookuped := False;
        
      FDataList.AssignExpands;
    end
    else
    if FActiveList = FPopupSetGrid then
    with Column.Field do
    begin
      if VarIsNull(TgsCustomIbGrid(Grid).Datasource.DataSet.FieldByName(FCurrentEditor.FSet.KeyField).Value) then
      begin
        if TgsCustomIbGrid(Grid).Datasource.DataSet.Eof then
          TgsCustomIbGrid(Grid).Datasource.DataSet.Edit;
        if TgsCustomIbGrid(Grid).Datasource.DataSet.State in [dsEdit, dsInsert] then
          TgsCustomIbGrid(Grid).Datasource.DataSet.Post;
        if not(Assigned(FActiveList)) then
          SetActiveList;
      end;
      FPopupSetGrid.FSetGrid.DataSource := FCurrentEditor.SetDatasource;
      FPopupSetGrid.FCurrentKey := TgsCustomIbGrid(Grid).Datasource.DataSet.FieldByName(FCurrentEditor.FSet.KeyField).Value;
      FPopupSetGrid.SetupCheckBoxes;
    end
    else
    if FActiveList = FPopupSetTree then
    with Column.Field do
    begin
      if VarIsNull(TgsCustomIbGrid(Grid).Datasource.DataSet.FieldByName(FCurrentEditor.FSet.KeyField).Value) then
      begin
        if TgsCustomIbGrid(Grid).Datasource.DataSet.Eof then
          TgsCustomIbGrid(Grid).Datasource.DataSet.Edit;
        if TgsCustomIbGrid(Grid).Datasource.DataSet.State in [dsEdit, dsInsert] then
          TgsCustomIbGrid(Grid).Datasource.DataSet.Post;
        if not(Assigned(FActiveList)) then
          SetActiveList;
      end;
      FPopupSetTree.FCurrentKey := TgsCustomIbGrid(Grid).Datasource.DataSet.FieldByName(FCurrentEditor.FSet.KeyField).Value;
      FPopupSetTree.FSetTree.DisplayField := FCurrentEditor.FSet.FSourceListField;
      FPopupSetTree.FSetTree.KeyField := FCurrentEditor.FSet.FSourceKeyField;
      FPopupSetTree.FSetTree.ParentField := FCurrentEditor.FSet.FSourceParentField;
      FPopupSetTree.FSetTree.Datasource := FCurrentEditor.SetDatasource;
      FPopupSetTree.SetupCheckBoxes;
    end
    else
    if FActiveList = FPickList then
    begin
      FPickList.FListBox.Color := Color;
      FPickList.FListBox.Font := Font;
      FPickList.FListBox.Items := FCurrentEditor.PickList;
      FPickList.RowCount := FCurrentEditor.DropDownCount;
      if Column.Field.IsNull then
        FPickList.FListBox.ItemIndex := -1
      else
      begin
        for I := 0 to FCurrentEditor.ValueList.Count - 1 do
        begin
          if Column.Field.Text = FCurrentEditor.ValueList.Values[FCurrentEditor.ValueList.Names[I]] then
          begin
            FPickList.FListBox.ItemIndex := FPickList.FListBox.Items.IndexOf(FCurrentEditor.ValueList.Names[I]);
          end;
        end;
      end
    end
    else if FActiveList = FPopupCalendar then
    begin
      if not (Column.Field.Text = '') then
        FPopupCalendar.Date := Column.Field.AsDateTime
      else
        FPopupCalendar.Date := Date;
    end
    else if FActiveList = FPopupCalculator then
    begin
      FPopupCalculator.Width := FPopupCalculator.FCalcImage.Width;

      FOldValue := 0;
      FOldValueEntered := False;
      FExpressionAction := eaEqual;
      FNeedToChangeValue := False;
      FDecDigits := 0;

      Value := Value;

      SelStart := Length(Text) + 1;

    end else if FActiveList = FPopupMemo then
    begin
      FPopupMemo.Height := Integer(Column.DropDownRows) * (Abs(Font.Height) + 4);
      FPopupMemo.Text := Text;
      FPopupMemo.SelStart := SelStart;
      FPopupMemo.SelLength := SelLength;
      FPopupMemo.MaxLength := MaxLength;

      FPopupMemo.ReadOnly := not FCanEdit;
    end else if FActiveList = FPictureDialog then
      FPictureDialog.PictureField := (Column.Field As TBlobField)
    else
      CloseUp(False);

    if FActiveList <> FPictureDialog then
    begin
      P := Parent.ClientToScreen(Point(Left, Top));
      Y := P.Y + Height;

      if Y + FActiveList.Height > Screen.Height then Y := P.Y - FActiveList.Height;
      SetWindowPos(FActiveList.Handle, HWND_TOP, P.X, Y, 0, 0,
        SWP_NOSIZE or SWP_NOACTIVATE or SWP_SHOWWINDOW);
      FListVisible := True;
      Invalidate;
      Windows.SetFocus(Handle);
    end
    else
    begin
      if Assigned(FActiveList) then
        FPictureDialog.ShowPictureDialog;
    end
  end;
end;

type
  TWinControlCracker = class(TWinControl);

procedure KillMessage(Wnd: HWnd; Msg: Integer);
// Delete the requested message from the queue, but throw back
// any WM_QUIT msgs that PeekMessage may also return
var
  M: TMsg;
begin
  M.Message := 0;
  if PeekMessage(M, Wnd, Msg, Msg, pm_Remove) and (M.Message = WM_QUIT) then
    PostQuitMessage(M.wparam);
end;

procedure TgsIBGridInplaceEdit.KeyDown(var Key: Word; Shift: TShiftState);
var
  V: Integer;
  MasterField: TField;
begin
  if (EditStyle = cesEllipsis) and (Key = VK_RETURN) and (Shift = [ssCtrl]) then
  begin
    (Grid as TgsCustomIbGrid).EditButtonClick;
    KillMessage(Handle, WM_CHAR);
  end
  else
  if (EditStyle = cesCalculator) then
  begin
    if not (csDesigning in ComponentState) then
    case Key of
      VK_ESCAPE, VK_MENU: if FListVisible then
      begin
        CloseUp(False);
      end;
      VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_NEXT, VK_PRIOR, VK_END, VK_HOME, VK_TAB:
        if FListVisible then Key := 0;
    end;
    if (Key <> 0) then inherited KeyDown(Key, Shift)
  end
  else
  if (EditStyle = cesSetGrid) then
  begin
    if not (csDesigning in ComponentState) then
    if FListVisible then
    begin
      case Key of
        VK_ESCAPE, VK_MENU: CloseUp(False);
        else
          SendMessage(FPopupSetGrid.handle, WM_CHAR, Key, 0);
      end;
      Key := 0;
    end;
    if (Key <> 0) then inherited KeyDown(Key, Shift)
  end
  else
  if (EditStyle = cesSetTree) then
  begin
    if not (csDesigning in ComponentState) then
    if FListVisible then
    begin
      SendMessage(FPopupSetTree.handle, WM_CHAR, Key, 0);
      Key := 0;
    end;
    if (Key <> 0) then inherited KeyDown(Key, Shift)
  end
  else
  if (EditStyle = cesLookup) then
  begin
    FInKeyProcessing := True;
    try
      if key = VK_DOWN then
      begin
        KillMessage(Handle, WM_CHAR);
        Key := 0;
        DropDown;
      end
      else if key in [VK_UP, {VK_DOWN,} VK_NEXT, VK_PRIOR, VK_TAB, VK_RETURN] then
      begin
        if (Text > '') and Modified then
        begin
          if not FCurrentEditor.DoLookup(
            FCurrentEditor.FLookup.FFullSearchOnExit, False) then
          begin
            KillMessage(Handle, WM_CHAR);
            if not FCurrentEditor.DoLookup then
              Key := 0;
          end;
          if FListVisible then
            Key := 0;
        end
        else if Modified then
        begin
          with TgsCustomIBGrid(Grid), Columns[SelectedIndex].Field do
          begin
            MasterField := DataSet.FieldByName(FCurrentEditor.FieldName);
            if MasterField.CanModify and DataLink.Edit then
              MasterField.Clear;
            if DataSet.State in [dsEdit, dsInsert] then
              Text := '';
          end;
        end;
      end;

      inherited;

      if (Shift = [ssCtrl]) and (Key = Ord('R'))  then
      begin

        V := (Grid as TgsCustomIbGrid).DataSource.DataSet.FieldByName(FCurrentEditor.FieldName).AsVariant;
        if FCurrentEditor.Reduce(V) then
        begin
          if not ((Grid as TgsCustomIbGrid).Datasource.Dataset.State in [dsEdit, dsInsert]) then
          (Grid as TgsCustomIbGrid).Datasource.Dataset.Edit;

          (Grid as TgsCustomIbGrid).Datasource.Dataset.FieldByName(FCurrentEditor.FieldName).AsVariant := V;
          FCurrentEditor.RefreshDataSet;

          if FCurrentEditor.LookupDataSource.DataSet.Locate(FCurrentEditor.FLookup.LookupKeyField, V, []) then
            Text := FCurrentEditor.LookupDataSource.DataSet.FieldByName(FCurrentEditor.FLookup.LookupListField).AsString;
        end;
      end
      else
        if Shift <> [] then exit;

      case Key of
        VK_F2, VK_F3, VK_F4, VK_F5, {VK_F6,} VK_F7, VK_F8, VK_F9, VK_F11:
          begin
            case Key of
              VK_F2:
              begin
                V := FCurrentEditor.CreateNew;
                if (V <> -1) then
                begin
                  if not ((Grid as TgsCustomIbGrid).Datasource.Dataset.State in [dsEdit, dsInsert]) then
                    (Grid as TgsCustomIbGrid).Datasource.Dataset.Edit;
                  (Grid as TgsCustomIbGrid).Datasource.Dataset.FieldByName(FCurrentEditor.FieldName).AsInteger := V;
                  (Grid as TgsCustomIbGrid).Datasource.Dataset.FieldByName(FCurrentEditor.DisplayField).AsString := FCurrentEditor.Text;
                  if FCurrentEditor.FLookupPrepared then
                    FCurrentEditor.FLookupDataSet.Close;
                  TgsCustomIBGrid(Grid).HideInplaceEdit;
                end
              end; {!!!!!!}
              VK_F3:
              begin
                if FCurrentEditor.DoLookup then
                  Modified := False;
              end;
              VK_F4:
              begin
                if FCurrentEditor.Edit((Grid as TgsCustomIbGrid).DataSource.DataSet.FieldByName(FCurrentEditor.FieldName).AsInteger) then
                begin
                  Text := FCurrentEditor.Text;
                  if FCurrentEditor.FLookupPrepared then
                    FCurrentEditor.FLookupDataSet.Close;

                  TgsCustomIBGrid(Grid).HideInplaceEdit;
                end
              end;
              VK_F5:
              begin
                MessageBox(Grid.Handle, PChar((Grid as TgsCustomIbGrid).Datasource.Dataset.FieldByName(FCurrentEditor.FieldName).AsString),
                 'Текущий ключ', MB_OK or MB_ICONINFORMATION);
              end;
              VK_F7:
              begin
                FCurrentEditor.DoLookup(True);
                Modified := False;
              end;
              VK_F8:
              begin
                if FCurrentEditor.Delete((Grid as TgsCustomIbGrid).DataSource.DataSet.FieldByName(FCurrentEditor.FieldName).AsInteger) then
                begin
                  if not ((Grid as TgsCustomIbGrid).Datasource.Dataset.State in [dsEdit, dsInsert]) then
                    (Grid as TgsCustomIbGrid).Datasource.Dataset.Edit;
                  (Grid as TgsCustomIbGrid).Datasource.Dataset.FieldByName(FCurrentEditor.FieldName).Clear;
                  Text := '';
                end;
              end;
              VK_F9:
              begin
                V := FCurrentEditor.ViewForm;
                if (V <> -1) then
                begin
                  if not ((Grid as TgsCustomIbGrid).Datasource.Dataset.State in [dsEdit, dsInsert]) then
                    (Grid as TgsCustomIbGrid).Datasource.Dataset.Edit;
                  (Grid as TgsCustomIbGrid).Datasource.Dataset.FieldByName(FCurrentEditor.FieldName).AsInteger := V;
                  Text := FCurrentEditor.Text;
                  Modified := True;
                  if FCurrentEditor.FLookupPrepared then
                    FCurrentEditor.FLookupDataSet.Close;
                end;
                ////**/
                //////
              end;
              VK_F11:
              begin
                FCurrentEditor.ObjectProperties((Grid as TgsCustomIbGrid).DataSource.DataSet.FieldByName(FCurrentEditor.FieldName).AsInteger);
              end;
            end;
            Key := 0;
         end;
        else
          if FListVisible then
           SendMessage(FDataList.handle, WM_CHAR, Key, 0);
      end;
    finally
      FInKeyProcessing := False;
    end;
  end
  else if FEditStyle = cesMemo then
  begin
    if not FListVisible then
    begin
        inherited KeyDown(Key, Shift);
    end;
  end
  else
    inherited KeyDown(Key, Shift);

end;

procedure TgsIBGridInplaceEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Button = mbLeft) and (FEditStyle <> cesNone) and
    OverButton(Point(X,Y)) then
  begin
    if FListVisible then
      CloseUp(False)
    else
    begin
      MouseCapture := True;
      FTracking := True;
      TrackButton(X, Y);
      DropDown;
    end;
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TgsIBGridInplaceEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ListPos: TPoint;
  MousePos: TSmallPoint;
begin
  if FTracking then
  begin
    TrackButton(X, Y);
    if FListVisible then
    begin
      ListPos := FActiveList.ScreenToClient(ClientToScreen(Point(X, Y)));
      if PtInRect(FActiveList.ClientRect, ListPos) then
      begin
        StopTracking;
        MousePos := PointToSmallPoint(ListPos);
        SendMessage(FActiveList.Handle, WM_LBUTTONDOWN, 0, Integer(MousePos));
        Exit;
      end;
    end;
  end;
  inherited MouseMove(Shift, X, Y);
end;

procedure TgsIBGridInplaceEdit.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  WasPressed: Boolean;
begin
  WasPressed := FPressed;
  StopTracking;
  if (Button = mbLeft) and (FEditStyle = cesEllipsis) and WasPressed then
    TgsCustomIBGrid(Grid).EditButtonClick;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TgsIBGridInplaceEdit.PaintWindow(DC: HDC);
var
  R: TRect;
  Flags: Integer;
  W, X, Y: Integer;
begin
  if FEditStyle <> cesNone then
  begin
    R := ButtonRect;
    Flags := 0;
    if FEditStyle in [cesLookUp, cesValueList] then
    begin
{      if FActiveList = nil then
        Flags := DFCS_INACTIVE
      else} if FPressed then
        Flags := DFCS_FLAT or DFCS_PUSHED;
      DrawFrameControl(DC, R, DFC_SCROLL, Flags or DFCS_SCROLLCOMBOBOX);
      ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
    end
    else   { esEllipsis }
    begin
      if FPressed then Flags := BF_FLAT;
      DrawEdge(DC, R, EDGE_RAISED, BF_RECT or BF_MIDDLE or Flags);
      X := R.Left + ((R.Right - R.Left) shr 1) - 1 + Ord(FPressed);
      Y := R.Top + ((R.Bottom - R.Top) shr 1) - 1 + Ord(FPressed);
      W := FButtonWidth shr 3;
      if W = 0 then W := 1;
      PatBlt(DC, X, Y, W, W, BLACKNESS);
      PatBlt(DC, X - (W * 2), Y, W, W, BLACKNESS);
      PatBlt(DC, X + (W * 2), Y, W, W, BLACKNESS);
      ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
    end;

  end;
  inherited PaintWindow(DC);
end;

procedure TgsIBGridInplaceEdit.SetEditStyle(Value: TgsIBColumnEditorStyle);
begin
  FEditStyle := Value;
  FActiveList := nil;
  with TgsCustomIBGrid(Grid) do
  begin
    Self.ReadOnly := Columns[SelectedIndex].ReadOnly;
  end;
  Repaint;
end;

procedure TgsIBGridInplaceEdit.StopTracking;
begin
  if FTracking then
  begin
    TrackButton(-1, -1);
    FTracking := False;
    MouseCapture := False;
  end;
end;

procedure TgsIBGridInplaceEdit.TrackButton(X,Y: Integer);
var
  NewState: Boolean;
  R: TRect;
begin
  R := ButtonRect;
  NewState := PtInRect(R, Point(X, Y));
  if FPressed <> NewState then
  begin
    FPressed := NewState;
    InvalidateRect(Handle, @R, False);
  end;
end;

///////!!!!!!!!
procedure TgsIBGridInplaceEdit.UpdateContents;
var
  Column: TColumn;
  NewStyle: TgsIBColumnEditorStyle;
  Index: Integer;
begin
  with TgsCustomIBGrid(Grid) do
  begin
    Column := Columns[SelectedIndex];
    if Assigned(Column.Field) then
    begin
      FCanEdit := Column.Field.CanModify
        and (not Column.ReadOnly)
        and (not TgsCustomIbGrid(Grid).ReadOnly)
    end else
    begin
      FCanEdit := False;
      Exit;
    end
  end;

  NewStyle := cesNone;
  Index := TgsCustomIBGrid(Grid).ColumnEditors.IndexByField(Column.FieldName);
  Hint := '';

  FFieldType := Column.Field.DataType;

  if Index > -1 then
  begin
    FCurrentEditor := TgsCustomIBGrid(Grid).ColumnEditors[Index];

    NewStyle := FCurrentEditor.EditorStyle;
    case NewStyle of
      cesLookUp:
      begin
        {
        if (Hint = '') and (not (csLoading in ComponentState)) then
        begin
          if (FCurrentEditor.FLookup.gdClassName > '') then
            Hint := 'Используйте клавиши:'#13#10 +
              '  F2 -- создание нового объекта'#13#10 +
              '  F3 -- поиск'#13#10 +
              '  F4 -- изменение выбранного объекта'#13#10 +
              '  F5 -- показать текущий ключ'#13#10 +
              '  Ctrl-R -- объединение двух записей'#13#10 +
              '  F7 -- точный поиск'#13#10 +
              '  F8 -- удаление выбранного объекта'#13#10 +
              '  F9 -- форма объекта'#13#10 +
              '  F11--  свойства объекта'
          else
            Hint := 'Используйте клавишу F3 -- для поиска';
          ShowHint := True;
        end;
        }
        FCurrentEditor.FLookuped := False;
      end;
      cesDate{, cesTime}:
      begin

      end;
      cesCalculator: ;
      cesValueList:
      begin
        if Assigned(TgsCustomIBGrid(Grid).ColumnEditors[Index].ValueList) and (TgsCustomIBGrid(Grid).ColumnEditors[Index].ValueList.Count > 0) and
          not Column.Readonly then
          NewStyle := cesValueList
        else
          NewStyle := cesNone;
      end;
      cesSetGrid: ;
      cesSetTree: ;
      cesMemo:;
      cesGraphic:;
    end;
  end
  else
  begin
    if FFieldType in [ftString, ftMemo, ftFmtMemo, ftFixedChar, ftWideString] then
      NewStyle := cesMemo
    else if FFieldType in [ftGraphic] then
      NewStyle := cesGraphic
    else if FFieldType in [ftCurrency, ftBCD] then
      NewStyle := cesCalculator
    else if FFieldType in [ftDate] then
      NewStyle := cesDate;
    FCurrentEditor := nil;
  end;

  if EditStyle <> NewStyle then
    EditStyle := NewStyle;

  inherited UpdateContents;

  if EditStyle = cesGraphic then
  begin
    if Column.Field.IsNull then
      Text := '(' + GraphicFieldString + ')'
    else
      Text := '(' + AnsiUpperCase(GraphicFieldString) + ')';
  end;

  if EditStyle = cesMemo then
  begin
    if not Column.Field.IsNull then
      Text := Column.Field.AsString;
  end;
  if (EditStyle = cesLookup) and (not FCanEdit) then
    FCanEdit := True;

  Font.Assign(Column.Font);
  ImeMode := Column.ImeMode;
  ImeName := Column.ImeName;
end;

procedure TgsIBGridInplaceEdit.CMCancelMode(var Message: TCMCancelMode);
begin
  if (Message.Sender <> Self) and (Message.Sender <> FActiveList)
    and (FActiveList <> FPopupCalculator) and (FActiveList <> FPopupSetGrid)
    and (FActiveList <> FPopupSetTree)
    and (FActiveList <> FPopupMemo)
    and not (FActiveList.InheritsFrom(TPopupPanel))then
    CloseUp(False);
end;

procedure TgsIBGridInplaceEdit.WMCancelMode(var Message: TMessage);
begin
  StopTracking;
  inherited;
end;

procedure TgsIBGridInplaceEdit.WMKillFocus(var Message: TMessage);
begin
  if not SysLocale.FarEast then inherited
  else
  begin
    ImeName := Screen.DefaultIme;
    ImeMode := imDontCare;
    inherited;
    if HWND(Message.WParam) <> TgsCustomIBGrid(Grid).Handle then
      ActivateKeyboardLayout(Screen.DefaultKbLayout, KLF_ACTIVATE);
  end;
  CloseUp(False);
end;

function TgsIBGridInplaceEdit.ButtonRect: TRect;
begin
  if not TgsCustomIBGrid(Owner).UseRightToLeftAlignment then
    Result := Rect(Width - FButtonWidth, 0, Width, Height)
  else
    Result := Rect(0, 0, FButtonWidth, Height);
end;

function TgsIBGridInplaceEdit.OverButton(const P: TPoint): Boolean;
begin
  Result := PtInRect(ButtonRect, P);
end;

procedure TgsIBGridInplaceEdit.WMLButtonDblClk(var Message: TWMLButtonDblClk);
begin
  with Message do
  if (FEditStyle <> cesNone) and OverButton(Point(XPos, YPos)) then
    Exit;
  inherited;
end;

procedure TgsIBGridInplaceEdit.WMPaint(var Message: TWMPaint);
begin
  PaintHandler(Message);
end;

procedure TgsIBGridInplaceEdit.WMSetCursor(var Message: TWMSetCursor);
var
  P: TPoint;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
  if (FEditStyle <> cesNone) and OverButton(P) then
    Windows.SetCursor(LoadCursor(0, idc_Arrow))
  else
  inherited;
end;

procedure TgsIBGridInplaceEdit.WndProc(var Message: TMessage);
var
  MasterField: TField;
  S: String;
begin
  case Message.Msg of
    wm_KeyDown, wm_SysKeyDown, wm_Char: begin
    //Nick захотите раскоментировать проверьте как работает на английском
      {ry
        with TWMKey(Message) do
          if not FListVisible and (CharCode = VK_DELETE) and (KeyDataToShiftState(KeyData) = []) then begin
            if not TgsCustomIBGrid(Grid).Columns[TgsCustomIBGrid(Grid).SelectedIndex].Field.Required then begin
              if not (TgsCustomIBGrid(Grid).DataSource.Dataset.State in [dsInsert, dsEdit]) then
                TgsCustomIBGrid(Grid).DataSource.Dataset.Edit;
              TgsCustomIBGrid(Grid).Columns[TgsCustomIBGrid(Grid).SelectedIndex].Field.Clear;
              Exit;
            end;
          end;
      except
      end;}

      if EditStyle in [cesValueList, cesLookUp,
                       cesDate, cesCalculator, cesSetGrid, cesSetTree, cesMemo] then
      with TWMKey(Message) do
      begin
        if (EditStyle in [cesCalculator]) and FListVisible then
        begin
          inherited;
          exit;
        end;

        DoDropDownKeys(CharCode, KeyDataToShiftState(KeyData));
        if (CharCode <> 0) and FListVisible then
        begin
          with TMessage(Message) do
            SendMessage(FActiveList.Handle, Msg, WParam, LParam);
          Exit;
        end;
      end;
    end;
    wm_killfocus:
    begin
      if (not FInKeyProcessing) and (EditStyle = cesLookup) and Modified then
      begin
        S := Text;
        KillMessage(Handle, WM_KillFocus);
        TgsCustomIBGrid(Grid).ShowEditor;
        SetFocus;
        Modified := False;
////////////
        Text := S;
        if (Text > '') then
        begin
          if not FCurrentEditor.DoLookup(FCurrentEditor.FLookup.FFullSearchOnExit, False) then
          begin
            FCurrentEditor.DoLookup;
            if FListVisible then
              CloseUp(True);
          end;
        end
        else
        begin
          with TgsCustomIBGrid(Grid), Columns[SelectedIndex].Field do
          begin
            MasterField := DataSet.FieldByName(FCurrentEditor.FieldName);
            if MasterField.CanModify and DataLink.Edit then
              MasterField.Clear;
            if DataSet.State in [dsEdit, dsInsert] then
              Text := '';
          end;
        end;
//////////////
      end;
    end;

  end;
  inherited;
end;


{ TIBStringProperty }

function TIBStringProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

procedure TIBStringProperty.GetValueList(List: TStrings);
var
  DataSource: TDataSource;
  Comp: TPersistent;
begin
  Comp := GetComponent(0);

  if not Assigned(Comp) then Exit;


  if Comp is TgsibColumnEditor then
    DataSource := (Comp as TgsIBColumnEditor).Grid.DataSource
  else
  if Comp is TFieldAlias then
    DataSource := (Comp as TFieldAlias).Grid.DataSource
  else
    DataSource := nil;

  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
    DataSource.DataSet.GetFieldNames(List);
end;

procedure TIBStringProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

{ Registration }

procedure Register;
begin
  RegisterComponents('gsNew', [TgsIBGrid]);
  RegisterPropertyEditor(TypeInfo(string), TFieldAlias, 'Alias', TIBStringProperty);

  RegisterPropertyEditor(TypeInfo(string), TgsibColumnEditor, 'FieldName', TIBStringProperty);
  RegisterPropertyEditor(TypeInfo(string), TgsibColumnEditor, 'DisplayField', TIBStringProperty);

end;

var
  TempBitmap: TBitmap;

type
  TIBCustomDataSetCracker = class(TIBCustomDataSet);

type
  TFieldData = class
  private
    FFieldName: String;
    FAlias: String;
    FRelationName: String;

  protected
  public
    constructor Create(AFieldName, AnAlias, ARelstionName: String);

  end;

{ TFieldData }

constructor TFieldData.Create(AFieldName, AnAlias, ARelstionName: String);
begin
  FFieldName := AFieldName;
  FAlias := AnAlias;
  FRelationName := ARelstionName;
end;

{ TgsCustomIBGrid }


constructor TgsCustomIBGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FOrigins := TStringHashMap.Create(CaseInSensitiveTraits, 256);

  FAliases := TFieldAliases.Create(Self);
  FColumnEditors := TgsIBColumnEditors.Create(Self);
end;

destructor TgsCustomIBGrid.Destroy;
begin
  FOrigins.Free;
  FAliases.Free;
  FColumnEditors.Free;
  inherited Destroy;
end;

{
  Осуществляем подготовку мастера.
}

procedure TgsCustomIBGrid.PrepareMaster(AMaster: TForm);
var
  SQL: TIBSQL;
begin
  inherited PrepareMaster(AMaster);

  if Assigned(Self.DataLink.DataSet) and (DataLink.DataSet is TIBCustomDataSet) then
  with AMaster as TdlgMaster do
  begin
    if (Self.DataLink.DataSet is TIBDataSet) then
      seQuery.Text := (Self.DataLink.DataSet as TIBDataSet).SelectSQL.Text
    else
      if (Self.DataLink.DataSet is TIBQuery) then
        seQuery.Text := (Self.DataLink.DataSet as TIBQuery).SQL.Text
      else
        if (Self.DataLink.DataSet is TgdcBase) then
          seQuery.Text := (Self.DataLink.DataSet as TgdcBase).SelectSQL.Text
        else
          if (Self.DataLink.DataSet is TgdvAcctBase) then
            seQuery.Text := (Self.DataLink.DataSet as TgdvAcctBase).SelectSQL.Text
          else
            Exit;

    EnableCategory('Query', True);
    QueryChanged := Self.QueryChanged;

    btnDefaults.Visible := True;
    btnDefaults.OnClick := DefaultsClick;

    lblDefaults.Visible := True;

    if seQuery.Text > '' then
    begin
      {$IFNDEF DEBUG}
      if (IBLogin <> nil) and IBLogin.IsUserAdmin then
      begin
      {$ENDIF}
        tsQuery.TabVisible := True;

        if AnsiPos('PLAN (', AnsiUpperCase(seQuery.Text)) <= 0 then
        begin
          SQL := TIBSQL.Create(nil);
          try
            try
              SQL.Transaction := (Self.DataLink.DataSet as TIBCustomDataSet).ReadTransaction;
              SQL.SQL.Text := seQuery.Text;
              SQL.Prepare;

              try
                seQuery.Text := seQuery.Text + #13#10 + SQL.Plan;
              except
              end;
            finally
              SQL.Free;
            end;
          except
            seQuery.Text := seQuery.Text + #13#10 + #13#10 + 'ERROR IN QUERY!';
          end;
        end;
      {$IFNDEF DEBUG}
      end else
        tsQuery.TabVisible := False;
      {$ENDIF}  
    end;
  end;
end;

procedure TgsCustomIBGrid.SetupGrid(AMaster: TForm; const UpdateGrid: Boolean = True);
var
  I: Integer;
  Column: TgsIBColumn;
  T: TgdcBase;
begin
  inherited SetupGrid(AMaster, UpdateGrid);

  if Assigned(DataSource) and Assigned(DataSource.DataSet) and
    (DataSource.DataSet is TgdcBase) then
  begin
    T := DataSource.DataSet as TgdcBase;

    for I := 0 to Columns.Count - 1 do
    begin
      Column := Columns[I] as TgsIBColumn;
      Column.Visible := Column.Visible
        and Column.Field.Visible
        and T.ShowFieldInGrid(Column.Field);
    end;
  end;
end;

class function TgsCustomIBGrid.GridClassType: TgsDBGridClass;
begin
  Result := TgsIBGrid;
end;

procedure TgsCustomIBGrid.QueryChanged(Sender: TObject; WithPlan: Boolean);
var
  SQL: String;
  I: Integer;
begin
  SQL := (Sender as TdlgMaster).seQuery.Text;

  if not WithPlan then
  begin
    repeat
      I := AnsiPos('PLAN (', AnsiUpperCase(SQL));

      if I > 0 then
        SQL := Copy(SQL, 1, I - 1);
    until I = 0;
  end;

  SQL := TrimRight(SQL);

  if (DataLink.DataSet is TIBDataSet) then
    (DataLink.DataSet as TIBDataSet).SelectSQL.Text := SQL
  else
  if (DataLink.DataSet is TIBQuery) then
    (DataLink.DataSet as TIBQuery).SQL.Text := SQL;
end;

{ TgsIBGrid Class }

procedure TgsCustomIBGrid.ReadFieldOrigins;
var
  I: Integer;
  ibsql: TIBSQL;
  StartedTransaction: Boolean;
  D: TIBCustomDataSetCracker;
  R: TatRelation;
  RF: TatRelationField;
begin
  Assert(atDatabase <> nil);

  if Assigned(DataLink.DataSet) then
  begin
    if not (DataLink.DataSet is TIBCustomDataSet) then
      raise Exception.Create('gsIBGrid must be linked to IBDataSet only');

    D := TIBCustomDataSetCracker(DataLink.DataSet);
    FOrigins.Clear;

    ibsql := nil;
    StartedTransaction := False;
    try
      if DataLink.DataSet.Active then
        ibsql := D.QSelect
      else begin
        ibsql := TIBSQL.Create(nil);
        ibsql.Transaction := D.ReadTransaction;
        ibsql.SQL.Text := D.QSelect.SQL.Text;
        if ibsql.SQL.Text = '' then
        begin
          D.InternalPrepare;
          ibsql.SQL.Text := D.QSelect.SQL.Text
        end;
      end;

      if not ibsql.Transaction.InTransaction then
      begin
        ibsql.Transaction.StartTransaction;
        StartedTransaction := True;
      end;

      if not ibsql.Prepared then
        ibsql.Prepare;

      for I := 0 to ibsql.Current.Count - 1 do
      begin
        R := atDatabase.Relations.ByRelationName(StrPas(ibsql.Current[I].AsXSQLVAR.relname));

        if Assigned(R) then
        begin
          RF := R.RelationFields.ByFieldName(StrPas(ibsql.Current[I].AsXSQLVAR.sqlname));
          FOrigins.Add(StrPas(ibsql.Current[I].AsXSQLVAR.aliasname), RF);
        end;
      end;

    finally
      if StartedTransaction and Assigned(ibsql) then
        ibsql.Transaction.Commit;
      if not DataLink.DataSet.Active then
        ibsql.Free;
    end;
  end;
end;

function TgsCustomIBGrid.FindFieldOrigin(const FieldName: String): TatRelationField;
begin
  if not FOrigins.Find(FieldName, Result) then
    Result := nil;
end;

function TgsCustomIBGrid.CreateColumns: TDBGridColumns;
begin
  Result := TgsColumns.Create(Self, TgsIBColumn, False);
end;

procedure TgsCustomIBGrid.LayoutChanged;
begin
  if csDestroying in ComponentState then
  begin
    Exit;
  end;

  if csDesigning in ComponentState then
  begin
    inherited;
    Exit;
  end;

  if Assigned(FOrigins) then
  begin
    if Assigned(DataSource)
      and Assigned(DataSource.DataSet)
      and DataSource.DataSet.Active then
    begin
      if FOrigins.Count = 0 then
        ReadFieldOrigins;
    end else
      FOrigins.Clear;
  end;

  inherited;
end;

function TgsCustomIBGrid.GetEditMask(ACol, ARow: Longint): string;
begin
  if Datasource.DataSet.Active then
  with Columns[RawToDataColumn(ACol)] do
  begin
    if Assigned(Field) then
      Result := Field.EditMask;
    if Result = '' then
      case Field.DataType of
        ftDate: Result := GetDateMask;
        ftTime: Result := GetTimeMask;
        ftDateTime: Result := GetDateTimeMask;
      end;
  end;
end;

procedure TgsCustomIBGrid.LinkActive(Active: Boolean);
begin
  if csDesigning in ComponentState then
  begin
    inherited;
    Exit;
  end;

  if (FOrigins.Count > 0) and (not Active) then
    FOrigins.Clear
  else if Active then
    ReadFieldOrigins;
  inherited;
end;

procedure TgsCustomIBGrid.DefaultsClick(Sender: TObject);
var
  I: Integer;
begin
  with ((Sender as TControl).Owner as TdlgMaster) do
  begin
    for I := 0 to NewColumns.Count - 1 do
      NewColumns[I].RestoreDefaults;
    UpdateColumnsView;
  end;
end;

class function TgsCustomIBGrid.GetColumnClass: TgsColumnClass;
begin
  Result := TgsIBColumn;
end;

procedure TgsCustomIBGrid.Read(Reader: TReader);
var
  I: Integer;
  Column: TgsIBColumn;
  Alias: TFIeldAlias;
begin
  inherited;

  if FOrigins.Count = 0 then
    ReadFieldOrigins;

  for I := 0 to Columns.Count - 1 do
  begin
    Column := Columns[I] as TgsIBColumn;

    if Column.IsRelationFieldValid then
    begin
      if not (cvTitleCaption in Column.AssignedValues) then
      begin
        if FAliases.FindAlias(Column.FieldName, Alias) then
          Column.Title.Caption := Alias.LName
        else
          Column.Title.Caption := Column.RelationField.LShortName;
      end;

      if not (cvAlignment in Column.AssignedValues) then
        Column.Alignment := FieldAlignmentToAlignment(
          Column.RelationField.Alignment);

      if not (cvReadOnly in Column.AssignedValues) then
        Column.ReadOnly := Column.RelationField.ReadOnly;
    end else
      if FAliases.FindAlias(Column.FieldName, Alias) then
        Column.Title.Caption := Alias.LName;

    if Column.Title.Caption = '' then
      Column.Title.Caption := '"' + Column.FieldName + '"';

    if Assigned(DataSource)
      and Assigned(DataSource.DataSet)
      and (DataSource.DataSet is TgdcBase)
      and Assigned(Column.Field)
      and (Column.Field.DataSet = DataSource.DataSet) then
    begin
      Column.Visible := Column.Visible
        and Column.Field.Visible
        and (DataSource.DataSet as TgdcBase).ShowFieldInGrid(Column.Field);
    end;
  end;
end;

procedure TgsCustomIBGrid.Write(Writer: TWriter);
begin
  inherited;
end;

procedure TgsCustomIBGrid.SetAliases(const Value: TFieldAliases);
begin
  FAliases.Assign(Value);
end;

procedure TgsCustomIBGrid.SetColumnEditors(
  const Value: TgsIBColumnEditors);
begin
  FColumnEditors.Assign(Value);
  Invalidate;
end;


function TgsCustomIBGrid.CreateEditor: TInplaceEdit;
begin
  Result := TgsIBGridInplaceEdit.Create(Self);
end;

function TgsCustomIBGrid.GetEditText(ACol, ARow: Integer): string;
begin
  Result := inherited GetEditText(ACol, ARow);
  if Result > '' then
  with Columns[RawToDataColumn(ACol)] do
  begin
    case Field.DataType of
      ftDate, ftDateTime:
      begin
        if Assigned(Field) and (not Field.IsNull) then
        begin
          if Field.DataType = ftDate then
            Result := FormatDateTime('dd.mm.yyyy' , Field.AsDateTime);
          if Field.DataType = ftDateTime then
            Result := FormatDateTime('dd.mm.yyyy hh:nn:ss' , Field.AsDateTime);
        end;
      end;
      ftMemo:
        Result := Field.AsString;
    end;    
  end
end;

procedure TgsCustomIBGrid.SetEditText(ACol, ARow: Integer;
  const Value: string);
var
  stDay, stMonth, stYear, S: String;
  I: Integer;
begin
  if InplaceEditor.Visible
     and InplaceEditor.IsMasked
     and (TgsIBGridInplaceEdit(InplaceEditor).FFieldType in [ftDate, ftDateTime, ftTime])
     and (
       (InplaceEditor.EditText = '')
       or (InplaceEditor.EditText <> InplaceEditor.Text)) then
  begin
    if TgsIBGridInplaceEdit(InplaceEditor).FFieldType = ftDate then
    begin
      { как известно у нас редактирование дат привязано к маске
        __.__.____
        т.е. требуется ввести четыре знака для года обязательно.
        это людям не нравится. они хотят вводить только два.
        вот мы и написали тут код, который корректирует
        дату в момент ее ввода.

        работает он следующим образом: введенную или даже частично
        введенную дату пытается разбить на три части: день месяц и год.

        если какая-то часть не извлекается, то она заменяется значением
        из текущей даты.

        потом все это собирается обратно в строку.
      }

      S := InplaceEditor.Text;
      I := Pos('.', S);
      stDay := Trim(Copy(S, 1, I - 1));
      Delete(S, 1, I);
      I := Pos('.', S);
      stMonth := Trim(Copy(S, 1, I - 1));
      stYear := Trim(Copy(S, I + 1, 4));
      if (StrToIntDef(stDay, -1) = -1) and (StrToIntDef(stMonth, -1) = -1) and (StrToIntDef(stYear, -1) = -1) then
        S := ''
      else
      begin
        if StrToIntDef(stDay, -1) = -1 then
          DateTimeToString(stDay, 'dd', Now);
        if StrToIntDef(stMonth, -1) = -1 then
          DateTimeToString(stMonth, 'mm', Now);
        case StrToIntDef(stYear, -1) of
          -1: DateTimeToString(stYear, 'yyyy', Now);
          0..99: stYear := '20' + stYear;
          100..999: stYear := '2' + stYear;
        end;
        S := stDay + '.' + stMonth + '.' + stYear;
      end
    end else
      S := '';

    inherited SetEditText(ACol, ARow, S);
  end else
    inherited SetEditText(ACol, ARow, Value);
end;

procedure TgsCustomIBGrid.ValidateColumns;
var
  I, K: Integer;
  L: TList;
  R: TatRelationField;
  C: TgsIBColumn;
begin
  inherited;

  Columns.BeginUpdate;
  try
    if (IBLogin <> nil) and (not IBLogin.IsIBUserAdmin) then
    begin
      for I := Columns.Count - 1 downto 0 do
      begin
        R := TgsIbColumn(Columns[I]).RelationField;
        if (R <> nil) and ((R.aView and IBLogin.Ingroup) = 0) then
          Columns[I].Free;
      end;
    end;

    if (not DataLink.Active) or
      (DataLink.DataSet.State = dsInactive) then
    begin
      exit;
    end;

    if (not FDontLoadSettings)
      and Assigned(FOrigins)
      and DataLink.Active then
    begin
      L := TList.Create;
      try
        for I := Columns.Count - 1 downto 0 do
        begin
          C := TgsIbColumn(Columns[I]);
          R := C.RelationField;

          if R <> nil then
          begin
            C.Visible := R.Visible;

            if R.ColWidth > 0 then
            begin
              C.Width := Round(R.ColWidth * 6.5);
            end;

            C.Alignment := FieldAlignmentToAlignment(R.Alignment);

            if (C.Field.DisplayLabel = '') and (R.LShortName > '') then
              C.Title.Caption := R.LShortName;
          end else
          begin
            if (C.Field <> nil) and (Pos('RDB$', C.Field.Origin) > 0) then
              C.Visible := False;
          end;
        end;

        K := 0;
        for I := 0 to Columns.Count - 1 do
        begin
          if Columns[I].Visible then
            Inc(K)
          else
          begin
            if (Columns[I].Field <> nil)
              and (Pos('NAME', UpperCase(Columns[I].Field.FieldName)) > 0) then
            begin
              L.Add(Columns[I]);
            end;
          end;
        end;

        if K = 0 then
        begin
          for I := 0 to L.Count - 1 do
          begin
            TColumn(L[I]).Visible := True;
          end;
          K := L.Count;
        end;

        if K = 0 then
        begin
          for I := 0 to Columns.Count - 1 do
          begin
            if (Columns[I].Field <> nil)
              and (Columns[I].Field.DataType = ftString) then
            begin
              Columns[I].Visible := True;
              Inc(K);
            end;
          end;
        end;

        if (K = 0) and (Columns.Count > 0) then
        begin
          Columns[0].Visible := True;
          Inc(K);
        end;

        if K <= 4 then
          ScaleColumns := True;
      finally
        L.Free;
      end;

      FDontLoadSettings := True;
    end;
  finally
    Columns.EndUpdate;
  end;
end;


procedure TgsCustomIBGrid.GetValueFromValueList(AColumn: TColumn;
  var AValue: String);
var
  I: Integer;
begin
  I := ColumnEditors.IndexByField(AColumn.FieldName);
  if (I > -1) and (ColumnEditors[I].FEditorStyle = cesValueList) then
  begin
    AValue := ColumnEditors[I].FRevertValueList.Values[AValue];
  end
end;

procedure TgsCustomIBGrid.HideInplaceEdit;
begin
  HideEditor;
end;

{ TgsIBColumnTitle }

function TgsIBColumnTitle.GetColumn: TgsIBColumn;
begin
  Result := inherited Column as TgsIBColumn;
end;

function TgsIBColumnTitle.GetGrid: TgsCustomIBGrid;
begin
  Result := Column.Grid as TgsCustomIBGrid;
end;

function TgsIBColumnTitle.IsAlignmentStored: Boolean;
begin
  Result := inherited IsAlignmentStored;
end;

function TgsIBColumnTitle.IsCaptionStored: Boolean;
var
  Alias: TFieldAlias;
begin
  Result :=
    not Column.IsRelationFieldValid
      or
    (Caption <> Column.RelationField.LShortName)
      or
    (Caption <> Column.FieldName) //
      or
    (
      Grid.Aliases.FindAlias(Column.FieldName, Alias)
        and
      (Caption <> Alias.LName)
    );
end;

{ TgsIBColumn }

function TgsIBColumn.CountWidth: Integer;
begin
  if not TempBitmap.Canvas.TryLock then
  begin
    Result := 0;
    Exit;
  end;

  try
    TempBitmap.Canvas.Font := Font;
    if IsRelationFieldValid then
      Result := SymbolsToPixels(RelationField.ColWidth, TempBitmap.Canvas)
    else
      Result := 0;
  finally
    TempBitmap.Canvas.Unlock;
  end;
end;

function TgsIBColumn.CreateTitle: TColumnTitle;
begin
  Result := TgsIBColumnTitle.Create(Self);
end;

function TgsIBColumn.GetGrid: TgsCustomIBGrid;
begin
  Result := inherited Grid as TgsCustomIBGrid;
end;

function TgsIBColumn.GetRelationField: TatRelationField;
begin
  Result := Grid.FindFieldOrigin(FieldName);
end;

function TgsIBColumn.IsAlignmentStored: Boolean;
begin
  Result := not IsRelationFieldValid or
    (Alignment <> FieldAlignmentToAlignment(RelationField.Alignment));
end;

function TgsIBColumn.IsColorStored: Boolean;
begin
  Result := inherited IsColorStored;
end;

function TgsIBColumn.IsDisplayFormatStored: Boolean;
begin
  Result := not IsRelationFieldValid or
    (DisplayFormat <> RelationField.FormatString);
end;

function TgsIBColumn.IsFontStored: Boolean;
begin
  Result := inherited IsFontStored;
end;

function TgsIBColumn.IsRelationFieldValid: Boolean;
begin
  Assert(atDatabase <> nil);
  Result := (RelationField <> nil) and
    (atDatabase.Relations.Count > 0);
end;

function TgsIBColumn.IsVisibleStored: Boolean;
begin
  Result := inherited IsVisibleStored;
end;

function TgsIBColumn.IsWidthStored: Boolean;
begin
  Result := not IsRelationFieldValid or
    (Width <> CountWidth);
end;

procedure TgsIBColumn.RestoreDefaults;
var
  W: Integer;
  Alias: TFieldAlias;
begin
  inherited;

  if (not (Collection as TgsColumns).IsSetupMode)
    and Grid.SaveSettings
    and ([csDesigning] * Grid.ComponentState = [])
  then
  begin
    IsStored := True;
  end;  

  if IsRelationFieldValid then
  begin
    if Grid.SaveSettings then
    with RelationField do
    begin
      Self.Alignment := FieldAlignmentToAlignment(Alignment);

      Self.ReadOnly := ReadOnly;

      W := CountWidth;

      if Grid.Aliases.FindAlias(Self.FieldName, Alias) then
        Title.Caption := Alias.LName
      else
        Title.Caption := LShortName;

      if W > 0 then
        Self.Width := W;

      if Assigned(Grid.DataSource) then
      begin
        if Grid.DataSource.DataSet is TgdcBase then
        begin
          Self.Visible := Self.Visible
            and (Grid.DataSource.DataSet as TgdcBase).ShowFieldInGrid(Self.Field);
        end;
      end;

      Self.DisplayFormat := FormatString;
    end else
      Title.Caption := RelationField.LShortName;
  end else
    if Grid.SaveSettings and Grid.Aliases.FindAlias(Self.FieldName, Alias) then
      Title.Caption := Alias.LName;

  if (Field <> nil) and (Field.DisplayLabel > '') then
    Title.Caption := Field.DisplayLabel;

  if Title.Caption = '' then
    Title.Caption := '"' + Self.FieldName + '"';
end;

{ TFieldAlias }

procedure TFieldAlias.Assign(Source: TPersistent);
begin
  if Source is TFieldAlias then
  begin
    FAlias := (Source as TFieldAlias).FAlias;
    FLName := (Source as TFieldAlias).FLName;
  end else
    inherited;
end;

constructor TFieldAlias.Create(Collection: TCollection);
begin
  inherited;

  FAlias := '';
  FLName := '';
end;

destructor TFieldAlias.Destroy;
begin
  inherited;
end;

function TFieldAlias.GetDisplayName: string;
begin
  Result := inherited GetDisplayName;

  if (FAlias > '') or (FLName > '') then
    Result := FAlias + '[' + FLNAme + ']';
end;

function TFieldAlias.GetGrid: TgsCustomIBGrid;
begin
  Result := (Collection as TFieldAliases).FGrid;
end;

procedure TFieldAlias.SetAlias(const Value: String);
begin
  FAlias := Value;
end;

procedure TFieldAlias.SetLName(const Value: String);
begin
  FLName := Value;
end;

{ TFieldAliases }

function TFieldAliases.Add: TFieldAlias;
begin
  Result := TFieldAlias(inherited Add);
end;

constructor TFieldAliases.Create(Grid: TgsCustomIBGrid);
begin
  inherited Create(TFieldAlias);

  FGrid := Grid;
end;

destructor TFieldAliases.Destroy;
begin
  inherited;
end;

function TFieldAliases.FindAlias(const AliasName: String;
  out Alias: TFieldAlias): Boolean;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if AnsiCompareText(Items[I].Alias, AliasName) = 0 then
    begin
      Alias := Items[I];
      Result := True;
      Exit;
    end;

  Result := False;
end;

function TFieldAliases.GetAlias(Index: Integer): TFieldAlias;
begin
  Result := TFieldAlias(inherited Items[Index]);
end;

function TFieldAliases.GetOwner: TPersistent;
begin
  Result := FGrid;
end;

procedure TFieldAliases.SetAlias(Index: Integer; const Value: TFieldAlias);
begin
  Items[Index].Assign(Value);
end;

procedure TFieldAliases.Update(Item: TCollectionItem);
begin
  inherited;
end;

{ TgsIBColumnEditor }

procedure TgsIBColumnEditor.Assign(Source: TPersistent);
begin
  if Source is TgsIBColumnEditor then
  begin
    FFieldName := (Source as TgsIBColumnEditor).FieldName;
    FEditorStyle := (Source as TgsIBColumnEditor).EditorStyle;

  end else
    inherited Assign(Source);
end;

constructor TgsIBColumnEditor.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FFieldName := '';
  FEditorStyle := cesNone;
  FPickList := TStringList.Create;
  FPickList.Duplicates := dupIgnore;
  FValueList := TStringList.Create;
  FValueList.OnChange := ValueListOnChange;
  FRevertValueList := TStringList.Create;
  FLookupPrepared := False;
  FLookupDataSet := nil;
  FLookupDatasource := nil;
  FDropDownCount := DefDropDownCount;
  FLookup := TLookup.Create(Self);
  FSet := TSet.Create(Self);
  FLookuped := False;
  FListFieldIsBlob := False;
end;

function TgsIBColumnEditor.CreateGDClassInstance(const AnID: Integer): TgdcBase;
var
  C: TPersistentClass;
begin
  C := GetClass(FLookup.gdClassName);
  if Assigned(C) and (C.InheritsFrom(TgdcBase)) then
  begin
    Result := CgdcBase(C).CreateSubType(Grid, FLookup.SubType, 'ByID');
    Result.ID := AnID;
    if Result.ID > 0 then
    begin
      Result.Open;

      if Result.IsEmpty then
      begin
        MessageBox(0,
          PChar('Невозможно создать экземпляр бизнес объекта с текущим ключем.'#13#10 +
          'Проверьте правильность задания имени класса, а также транзакцию, '#13#10 +
          'на которой работает выпадающий список.'),
          'Внимание',
          MB_OK or MB_ICONHAND or MB_TASKMODAL);
        Abort;
      end;
    end;
  end else
    Result := nil;
end;

function TgsIBColumnEditor.CreateNew: Integer;
var
  T, obj: TgdcBase;
  C: TgdcFullClass;
  S: String;
begin
  Assert(FEditorStyle = cesLookup);
  Result := -1;

  T := CreateGDClassInstance(-1);
  if Assigned(T) then
  try
    C := T.QueryDescendant;
    if C.gdClass <> nil then
    begin
      Obj := C.gdClass.CreateSubType(Grid, FLookup.FSubType, 'ByID');

      Obj.Open;
      Obj.Insert;

      S := Grid.InplaceEditor.Text;
      if (S > '') then
        Obj.ObjectName := S;
      if Assigned(Grid.OnCreateNewObject) then
        Grid.OnCreateNewObject(Grid, Obj);
      try
        if Obj.CreateDialog then
        begin
          Result := Obj.ID;
          FText := Obj.FieldByName(GetFieldNameWithoutAlias(FLookup.LookupListField)).AsString;
        end
        else
          FText := '';
      finally
        Obj.Free;
      end;
    end;
  finally
    T.Free;
  end;
end;

function TgsIBColumnEditor.Delete(const Value: Integer): boolean;
var
  T: TgdcBase;
begin
  Assert(FEditorStyle = cesLookup);
  Result := False;
  if (Value <> -1) then
  begin
    T := CreateGDClassInstance(Value);
    if Assigned(T) then
    try
      try
        T.Delete;
        Result := True;
      except
        ShowMessage('Ошибка удаления');
      end;
    finally
      T.Free;
    end;
  end;
end;

destructor TgsIBColumnEditor.Destroy;
begin
  FValueList.Free;
  FRevertValueList.Free;
  FPickList.Free;
  FLookup.Free;
  FSet.Free;
  if Assigned(FLookupDataSet) then
    FreeAndNil(FLookupDataSet);
  if Assigned(FLookupDataSource) then
    FreeAndNil(FLookupDataSource);

  if Assigned(FCrossDataset) then
    FreeAndNil(FCrossDataset);
  if Assigned(FSourceDataset) then
    FreeAndNil(FSourceDataset);
  if Assigned(FSourceDatasource) then
    FreeAndNil(FSourceDatasource);

  inherited Destroy;
end;

function TgsIBColumnEditor.DoLookup(const Exact: Boolean = False; const ShowMsg: boolean = True): boolean;
var
  S, SText: String;
  StrFields: String;
  V, MessageBoxResult: Integer;
  I, J: Integer;
  SelectCondition: String;
  SL: TStringList;
  DistinctStr: String;
begin
  Assert(atDatabase <> nil);
  Assert(IBLogin <> nil);

  Result := False;
  if (not FlookupPrepared) and (not PrepareLookup) then
    Exit;

  if FLookup.FFields > '' then
    StrFields :=  StrFields + ', ' + FLookup.FieldWithAlias(FLookup.FFields)
  else
    StrFields := '';

  if (FgdClass <> nil) and FgdClass.InheritsFrom(TgdcTree) and (not CgdcTree(FgdClass).HasLeafs) then
    StrFields := StrFields + ', ' + FLookup.FieldWithAlias(CgdcTree(FgdClass).GetParentField(FLookup.SubType));

  SText := Grid.InplaceEditor.Text;

  while Pos('''', SText) > 0 do
    System.Delete(SText, Pos('''', SText), 1);

  Grid.InplaceEditor.Text := SText;

  if FLookup.IsTree then
    StrFields := StrFields + ', ' + FLookup.FieldWithAlias(FLookup.FParentField);

  if FLookup.FDistinct then
    DistinctStr := 'DISTINCT'
  else
    DistinctStr := '';

  if Grid.InplaceEditor.Text > '' then
  begin
    S := Format('SELECT %4:s %0:s, %1:s %2:s FROM %3:s WHERE',
      [FLookup.FieldWithAlias(FLookup.LookupListField), FLookup.FieldWithAlias(FLookup.FLookupKeyField),
      StrFields, FLookup.LookupTable, DistinctStr]);

    if Exact then
      SelectCondition := Format(' (%0:s = ''%1:s'') ', [FLookup.FieldWithAlias(FLookup.LookupListField), Grid.InplaceEditor.Text])
    else
      if FListFieldIsBlob then
        SelectCondition := Format('(upper(SUBSTRING(%0:s FROM 1 FOR CHAR_LENGTH(%0:s))) LIKE ''%%''|| ''%1:s'' || ''%%'') ',
          [FLookup.FieldWithAlias(FLookup.LookupListField), AnsiUpperCase(Grid.InplaceEditor.Text)])
      else
        SelectCondition := Format('(upper(%0:s) LIKE ''%%%1:s%%'') ',
          [FLookup.FieldWithAlias(FLookup.LookupListField),
          AnsiUpperCase(Grid.InplaceEditor.Text)]);

    if FLookup.FFields > '' then
    begin
      SL := TStringList.Create;
      try
        SL.CommaText := FLookup.FFields;
        for J := 0 to SL.Count - 1 do
          if Exact then
            SelectCondition := Format('%s OR (%s = ''%s'') ',
              [SelectCondition, FLookup.FieldWithAlias(Trim(SL[J])), Grid.InplaceEditor.Text])
          else
            SelectCondition := Format('%0:s OR (upper(SUBSTRING('''' || %1:s FROM 1 FOR CHAR_LENGTH('''' || %1:s))) LIKE ''%%''|| ''%2:s'' || ''%%'') ',
              [SelectCondition, FLookup.FieldWithAlias(Trim(SL[J])), AnsiUpperCase(Grid.InplaceEditor.Text)])
      finally
        SL.Free;
      end;
    end;
    S := Format('%s (%s)', [S, SelectCondition])
  end else
    S := Format('SELECT %4:s %0:s, %1:s %2:s FROM %3:s ',
      [FLookup.FieldWithAlias(FLookup.LookupListField), FLookup.FieldWithAlias(FLookup.LookupKeyField),
       StrFields, FLookup.LookupTable, DistinctStr]);

  if FullCondition > '' then
    if Grid.InplaceEditor.Text > '' then
      S := S + ' AND (' + FullCondition + ') '
    else
      S := S + ' WHERE ' + FullCondition + ' ';


  if FLookup.CheckUserRights and (not IBLogin.IsUserAdmin)
    and (atDatabase.FindRelationField(FLookup.MainTableName, 'AVIEW') <> nil) then
  begin
    if Pos('WHERE ', S) = 0 then
      S := S + ' WHERE '
    else
      S := S + ' AND ';

    S := S + Format('(BIN_AND(BIN_OR(%s.aview, 1), %d) <> 0) ',
      [FLookup.MainTableAlias, IBLogin.InGroup])
  end;

  if atDatabase.FindRelationField(FLookup.MainTableName, 'DISABLED') <> nil then
  begin
    if Pos('WHERE ', S) = 0 then
      S := S + ' WHERE '
    else
      S := S + ' AND ';

    S := Format('%s ((%s.disabled IS NULL) OR (%s.disabled = 0))',
      [S, FLookup.MainTableAlias, FLookup.MainTableAlias]);
  end;

  if FLookup.GroupBy > '' then
    S := S + ' GROUP BY ' + FLookup.GroupBy;
  if FLookup.SortOrder = soAsc then
    S := S + ' ORDER BY ' + FLookup.LookupListField + ' ASC '
  else if FLookup.SortOrder = soDesc then
    S := S + ' ORDER BY ' + FLookup.LookupListField + ' DESC ';

  FLookupDataSet.Close;
  FLookupDataSet.SelectSQL.Text := S;
  FLookupDataSet.Prepare;
  for I := 0 to FLookup.FParams.Count - 1 do
  try
    FLookupDataSet.ParamByName(FLookup.FParams.Names[I]).AsString := FLookup.FParams.Values[FLookup.FParams.Names[I]];
  except
    on E: Exception do MessageDlg(E.Message, mtError, [mbOk], 0);
  end;

  try
    FLookupDataSet.Open;
  except
    Grid.InplaceEditor.Text := '';  
    Grid.InplaceEditor.Modified := False;
    TgsIBGridInplaceEdit(Grid.InplaceEditor).DropDown;
    raise;
  end;

  Result := FLookupDataSet.RecordCount > 0;

  if FLookupDataSet.RecordCount = 0 then
  begin
    FLookuped := False;
    if ShowMsg then
    begin
      if (FLookup.gdClassName > '') then
      begin
        MessageBoxResult := Application.MessageBox(
          'Не найдено ни одного объекта, удовлетворяющего'#13#10 +
          'указанному критерию поиска. Вывести весь список?'#13#10 +
          #13#10 +
          'Выберите:'#13#10 +
          'Да -- вывести список всех объектов.'#13#10 +
          'Нет -- создать новый объект.'#13#10 +
          'Отмена -- закрыть это окно.',
          'Внимание!',
          MB_YESNOCANCEL or MB_ICONQUESTION);

          if MessageBoxResult = IDYES then
          begin
            Grid.InplaceEditor.Modified := False;
            TgsIBGridInplaceEdit(Grid.InplaceEditor).DropDown
          end
          else if MessageBoxResult = IDNO then
          begin
            V := CreateNew;
            if (V <> -1) then
            begin
              if not ((Grid as TgsCustomIbGrid).Datasource.Dataset.State in [dsEdit, dsInsert]) then
                (Grid as TgsCustomIbGrid).Datasource.Dataset.Edit;
              (Grid as TgsCustomIbGrid).Datasource.Dataset.FieldByName(FieldName).AsInteger := V;
              Grid.InplaceEditor.Text := Text;
              Grid.InplaceEditor.Modified := True;
              if FLookupPrepared then
                FLookupDataSet.Close;
            end;
          end
          else begin
            Grid.InplaceEditor.Text := '';
            Grid.InplaceEditor.SetFocus;
          end;
      end
      else
      begin
        MessageBoxResult := Application.MessageBox(
          'Не найдено ни одного объекта, удовлетворяющего'#13#10 +
          'указанному критерию поиска. Вывести весь список?'#13#10 +
          #13#10 +
          'Выберите:'#13#10 +
          'Да -- вывести список всех объектов.'#13#10 +
          'Нет -- закрыть это окно.',
          'Внимание!',
          MB_YESNO or MB_ICONQUESTION);
        if MessageBoxResult = IDYES then
        begin
          Grid.InplaceEditor.Modified := False;
          TgsIBGridInplaceEdit(Grid.InplaceEditor).DropDown
        end
        else begin
          Grid.InplaceEditor.Text := '';
          Grid.InplaceEditor.SetFocus;
        end;
      end
    end
    else
      Grid.InplaceEditor.SetFocus;
  end
  else if FLookupDataSet.RecordCount > 0 then
  begin
    FLookuped := True;
    while (not FLookupDataSet.EOF) and (FLookupDataSet.RecordCount < FDropDownCount) do
      FLookupDataSet.Next;

    FLookupDataSet.First;

    TgsIBGridInplaceEdit(Grid.InplaceEditor).DropDown;

    if FLookupDataSet.RecordCount = 1 then
      TgsIBGridInplaceEdit(Grid.InplaceEditor).CloseUp(True);
  end;
end;

procedure TgsIBColumnEditor.DropDown(const Match: String;
  const UseExisting: Boolean);
var
  S, StrFields: String;
  I: Integer;
  DistinctStr: String;
begin
  Assert(atDatabase <> nil);
  Assert(IBLogin <> nil);

  FLookuped := False;
  if (not FlookupPrepared) and (not PrepareLookup) then
    Exit;

  if not UseExisting then
  begin
    if FLookup.LookupKeyField <> FLookup.LookupListField then
      StrFields := ', ' + FLookup.FieldWithAlias(FLookup.LookupKeyField)
    else
      StrFields := '';

    if FLookup.FFields > '' then
      StrFields :=  StrFields + ', ' + FLookup.FieldWithAlias(FLookup.FFields);

    if FLookup.IsTree then
      StrFields := StrFields + ', ' + FLookup.FieldWithAlias(FLookup.ParentField);

    if FLookup.FDistinct then
      DistinctStr := 'DISTINCT'
    else
      DistinctStr := '';

    S := Format('SELECT %3:s %0:s %1:s FROM %2:s ', [FLookup.FieldWithAlias(FLookup.LookupListField), StrFields, FLookup.LookupTable, DistinctStr]);

    if Match > '' then
      if FListFieldIsBlob then
        S := S + Format(' WHERE (upper(SUBSTRING(%0:s FROM 1 FOR CHAR_LENGTH(%0:s))) LIKE ''%%''|| ''%1:s'' || ''%%'') ', [FLookup.FieldWithAlias(FLookup.LookupListField), AnsiUpperCase(Match)])
      else
        S := S + Format(' WHERE (UPPER(%0:s) LIKE ''%%%1:s%%'') ', [FLookup.FieldWithAlias(FLookup.LookupListField), AnsiUpperCase(Match)]);

    if Trim(FullCondition) > '' then
      if Pos('WHERE ', S) = 0 then
        S := S + ' WHERE (' + FullCondition + ') '
      else
        S := S + ' AND (' + FullCondition + ') ';


    if FLookup.CheckUserRights and (not IBLogin.IsUserAdmin)
      and (atDatabase.FindRelationField(FLookup.MainTableName, 'AVIEW') <> nil) then
    begin
      if Pos('WHERE ', S) = 0 then
        S := S + ' WHERE '
      else
        S := S + ' AND ';

      S := S + Format('(BIN_AND(BIN_OR(%s.aview, 1), %d) <> 0) ',
        [FLookup.MainTableAlias, IBLogin.InGroup])
    end;

    //if (FgdClass <> nil) and (AnsiCompareText(FLookup.FLookupTable, FgdClass.GetListTable(FLookup.SubType)) = 0)
    //  and (tiDisabled in FgdClass.GetTableInfos(FLookup.SubType)) then
    if atDatabase.FindRelationField(FLookup.MainTableName, 'DISABLED') <> nil then
    begin
      if Pos('WHERE ', S) = 0 then
        S := S + ' WHERE '
      else
        S := S + ' AND ';

      S := Format('%s ((%s.disabled IS NULL) OR (%s.disabled = 0))',
        [S, FLookup.MainTableAlias, FLookup.MainTableAlias]);
    end;

    if FLookup.GroupBY > '' then
      S := S + ' GROUP BY ' + FLookup.GroupBY;

    if FLookup.SortOrder = soAsc then
      S := S + ' ORDER BY ' + FLookup.FieldWithAlias(FLookup.LookupListField) + ' ASC '
    else if FLookup.SortOrder = soDesc then
      S := S + ' ORDER BY ' + FLookup.FieldWithAlias(FLookup.LookupListField) + ' DESC ';

    FLookupDataSet.Close;
    FLookupDataSet.SelectSQL.Text := S;
    FLookupDataSet.Prepare;

    for I := 0 to FLookup.FParams.Count - 1 do
    try
      FLookupDataSet.ParamByName(FLookup.FParams.Names[I]).AsString := FLookup.FParams.Values[FLookup.FParams.Names[I]];
    except
      on E: Exception do MessageDlg(E.Message, mtError, [mbOk], 0);
    end;

    FLookupDataSet.Open;
  end;

  if FLookupDataSet.IsEmpty then
  begin

    MessageBox(Grid.Handle,
      'Список для выбора пуст.',
      'Внимание!',
      MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

    Grid.InplaceEditor.SetFocus;
    Abort;

  end else
  begin
    while (not FLookupDataSet.EOF) and (FLookupDataSet.RecordCount < FDropDownCount) do
      FlookupDataSet.Next;
  end;

end;

function TgsIBColumnEditor.Edit(const Value: Integer): Boolean;
var
  T: TgdcBase;
begin
  Assert(FEditorStyle = cesLookup);

  Result := False;

  if (Value > 0) then
  begin
    T := CreateGDClassInstance(Value);
    if Assigned(T) then
    try
      Result := T.EditDialog;
      FText := T.FieldByName(GetFieldNameWithoutAlias(FLookup.LookupListField)).AsString;
    finally
      T.Free;
    end;
  end;

end;


function TgsIBColumnEditor.GetFullCondtion: String;
var
  RestrCondition: String;
  LMainTableAlias: String;
begin
  if Assigned(FgdClass) and (FLookup.Condition = '') then
  begin
    LMainTableAlias := Trim(FLookup.GetMainTableAlias);
    if LMainTableAlias <> '' then LMainTableAlias := LMainTableAlias + '.';
    RestrCondition := StringReplace(FgdClass.GetRestrictCondition(FLookup.LookupTable, FLookup.FSubType),
      FgdClass.GetListTableAlias + '.', LMainTableAlias, [rfReplaceAll, rfIgnoreCase])
  end else
    RestrCondition := '';

  if RestrCondition > '' then
    Result := iff(FLookup.Condition > '', FLookup.Condition + ' AND ', '') + RestrCondition
  else
    Result := FLookup.Condition;
end;

function TgsIBColumnEditor.GetGrid: TgsCustomIBGrid;
begin
  Result := (Collection as TgsIBColumnEditors).Grid;
end;

function TgsIBColumnEditor.GetLookupSource: TDataSource;
begin
  if not FLookupPrepared then
    PrepareLookup;
  Result := FLookupDataSource;
end;

function TgsIBColumnEditor.GetPickList: TStringList;
var
  I: Integer;
begin
  FPickList.Clear;
  if FValueList.Count > 0 then
  begin
    if FValueList.Names[0] > '' then
    begin
      for I := 0 to FValueList.Count - 1 do
      begin
        FPickList.Add(FValueList.Names[I]);
      end;
    end
    else
      FPickList.Assign(FValueList);
  end;

  Result := FPickList;
end;

function TgsIBColumnEditor.GetSetDatasource: TDataSource;
begin
  if not FSetPrepared then
    PrepareSet;
  Result := FSourceDataSource;
end;

procedure TgsIBColumnEditor.ObjectProperties(const Value: Integer);
var
  T2: TgdcBase;
begin
  Assert(FEditorStyle = cesLookup);

  if Value = -1 then
    exit;
  T2 := CreateGDClassInstance(Value);
  if Assigned(T2) then
  try
    T2.EditDialog('Tgdc_dlgObjectProperties');
  finally
    T2.Free;
  end;
end;

function TgsIBColumnEditor.PrepareLookup: boolean;
var
  strField: String;
  DistinctStr: String;
  atRelation: TAtRelation;
  atRelationField: TAtRelationField;
begin
  Result := FLookupPrepared;
  try
    if (not FLookupPrepared) and (not (csDesigning in Grid.ComponentState)) then
    begin
      FLookupPrepared := False;

      if (not Assigned(Grid.DataSource)) or (not Assigned(Grid.DataSource.DataSet)) or (not Grid.DataSource.DataSet.Active) or (FLookup.LookupKeyField = '') or
         (FLookup.LookupListField = '') or (FLookup.LookupTable = '') then
        Exit;

      FListFieldIsBlob := False;
      if Assigned(atDatabase) then
      begin
        atRelation := atDatabase.Relations.ByRelationName(FLookup.LookupTable);
        if Assigned(atRelation) then
        begin
          atRelationField := atRelation.RelationFields.ByFieldName(FLookup.LookupListField);
          if Assigned(atRelationField) and Assigned(atRelationField.Field) and (atRelationField.Field.FieldType in [ftMemo, ftBlob]) then
            FListFieldIsBlob := True;
        end;
      end;


      if not Assigned(FLookupDataset) then
        FLookupDataset := TIbDataSet.Create(Grid);
      if not Assigned(FLookupDatasource) then
        FLookupDataSource := TDatasource.Create(Grid);

      FLookupDataSet.Close;
      FLookupDataSource.DataSet := FLookupDataset;

      FLookupDataSet.Database := FLookup.Database;
      FLookupDataSet.Transaction := FLookup.Transaction;
      if FLookup.IsTree then
        StrField := ', ' + FLookup.FieldWithAlias(FLookup.ParentField)
      else
        StrField := '';

      if FLookup.FDistinct then
        DistinctStr := 'DISTINCT'
      else
        DistinctStr := '';

      if Trim(FullCondition) > '' then
        FLookupDataSet.SelectSQL.Text := Format('SELECT %5:s %0:s, %1:s %2:s FROM %3:s WHERE %4:s',
          [FLookup.FieldWithAlias(FLookup.LookupKeyField),
          FLookup.FieldWithAlias(FLookup.LookupListField), StrField,
          FLookup.LookupTable, FullCondition, DistinctStr])
      else
        FLookupDataSet.SelectSQL.Text := Format('SELECT %4:s %0:s, %1:s %2:s FROM %3:s',
          [FLookup.FieldWithAlias(FLookup.LookupKeyField),
          FLookup.FieldWithAlias(FLookup.LookupListField), StrField, FLookup.LookupTable,
          DistinctStr]);
      FLookupDataSet.Open;
//      FLookupDataSet.FieldByName(FLookup.LookupKeyField).Visible := False;

      FLookupPrepared := True;
    end;
    Result := FLookupPrepared;
  except
    on E: Exception do MessageDlg(E.Message, mtError, [mbOk], 0);
  end;
end;

function TgsIBColumnEditor.PrepareSet: boolean;
begin
  Result := False;
  try
    if not FSetPrepared then
    begin
      FSetPrepared := False;
      if (not (csDesigning in Grid.ComponentState))then
      begin
        if (not Assigned(Grid.DataSource)) or (not Assigned(Grid.DataSource.DataSet))
           or (not Grid.DataSource.DataSet.Active) or (FSet.KeyField = '')
           or (FSet.SourceKeyField = '') or (FSet.SourceListField = '') or (FSet.CrossDestField = '')
           or (FSet.CrossSourceField = '') or (FSet.SourceTable = '') or (FSet.CrossTable = '') then
          Exit;
        if not Assigned(FSourceDataSource) then
          FSourceDatasource := TDatasource.Create(Grid);
        if not Assigned(FSourceDataSet) then
          FSourceDataset := TibQuery.Create(Grid);
        if not Assigned(FCrossDataset) then
          FCrossDataSet := TibDataSet.Create(Grid);

        FSourceDatasource.DataSet := FSourceDataset;
        FSourceDataset.Close;
        FSourceDataset.Database := TibDataSet(Grid.Datasource.Dataset).Database;
        FSourceDataset.Transaction := TibDataSet(Grid.Datasource.Dataset).Transaction;
        if EditorStyle = cesSetGrid then
          FSourceDataset.SQL.Text := Format('SELECT %s, %s FROM %s', [FSet.SourceKeyField, FSet.SourceListField, FSet.SourceTable])
        else
          FSourceDataset.SQL.Text := Format('SELECT %s, %s, %s FROM %s', [FSet.SourceKeyField, FSet.SourceListField, 'Parent', FSet.SourceTable]);

        FSourceDataset.Prepare;
        FSourceDataset.Open;
        FSourceDataset.FieldByName(FSet.SourceKeyField).Visible := False;



        FCrossDataSet.Close;
        FCrossDataSet.Database := TibDataSet(Grid.Datasource.Dataset).Database;
        FCrossDataSet.Transaction := TibDataSet(Grid.Datasource.Dataset).Transaction;
        FCrossDataset.SelectSQL.Text := Format('SELECT %s, %s FROM %s WHERE %s = :Key', [FSet.CrossDestField, FSet.CrossSourceField, FSet.CrossTable, FSet.CrossDestField]);
        FCrossDataset.InsertSQL.Text := Format('INSERT INTO %s (%s , %s) VALUES (:%s, :%s)', [FSet.CrossTable, FSet.CrossDestField,
                                        FSet.CrossSourceField, FSet.CrossDestField, FSet.CrossSourceField ]);
        FCrossDataset.DeleteSQL.Text := Format('DELETE FROM %s WHERE (%s = :%s) AND (%s = :%s)', [FSet.CrossTable, FSet.CrossDestField,
                                        FSet.CrossDestField, FSet.CrossSourceField, FSet.CrossSourceField ]);

        FCrossDataSet.Prepare;

        FSetPrepared := True;
      end;
    end;
    Result := FSetPrepared;
  except
    on E: Exception do MessageDlg(E.Message, mtError, [mbOk], 0);
  end;
end;

function TgsIBColumnEditor.Reduce(var Value: Integer): boolean;
begin
  Result := False;
  if (Value <> -1) then
  begin
    with TgsDBReductionWizard.Create(Grid) do
    try
      if Assigned(Grid.DataSource) and Assigned(Grid.DataSource.DataSet) and
          (Grid.DataSource.DataSet is TgdcBase) then
        HideFields := (Grid.DataSource.DataSet as TgdcBase).HideFieldsList + 'LB;RB;'
      else
        HideFields := 'LB;RB;AFULL;ACHAG;AVIEW';
      Condition := Self.FLookup.Condition;
      Database := TibDataSet(Grid.Datasource.DataSet).Database;
      ListField := Self.FLookup.LookupListField;
      MasterKey := IntToStr(Value);
      Table := Self.FLookup.LookupTable;
      Transaction := TibDataSet(Grid.Datasource.DataSet).Transaction;
      TransferData := True;
      Result := Wizard;
      if Result then
        Value := StrToInt(MasterKey);
    finally
      Free;
    end;
  end;
end;

procedure TgsIBColumnEditor.RefreshDataset;
var
  SL: TStringList;
  I: Integer;
begin
  if (not FLookupPrepared) and (not PrepareLookup) then
    Exit;

  SL := TStringList.Create;
  try

    for I := 0 to FLookupDataSet.FieldCount - 1 do
      if not FLookupDataSet.Fields[I].Visible then
        SL.Add(FLookupDataSet.Fields[I].FieldName);

    FLookupDataSet.Close;

    FLookupDataSet.Open;

    for I := 0 to SL.Count - 1 do
      FLookupDataSet.FieldByName(SL[I]).Visible := False;

  finally
    SL.Free;
  end
end;

procedure TgsIBColumnEditor.SetDisplayField(const Value: String);
var
  I: Integer;
begin
  if not AnsiSameText(FDisplayField, Value) then
  begin
    if not (csLoading in Grid.ComponentState) then
    begin
      for I := 0 to Collection.Count - 1 do
      begin
        if AnsiSameText(TgsIBColumnEditor(Collection.Items[I]).DisplayField, Value) then
          raise EDuplicateEditor.CreateFmt('Редактор для поля %s уже существует', [Value]);
      end;
    end;  
    FDisplayField := Value;
    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

procedure TgsIBColumnEditor.SetEditorStyle(const Value: TgsIBColumnEditorStyle);
begin
  if Value <> FEditorStyle then
  begin
    FEditorStyle := Value;
  end;
end;

procedure TgsIBColumnEditor.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    FFieldName := Value;

    if Assigned(Grid) then
      Grid.Invalidate;

  end;
end;

procedure TLookup.SetgdClassName(Value: String);
var
  C: TPersistentClass;

begin
  if FgdClassName <> Value then
  begin
    FgdClassName := Value;
    C := GetClass(FgdClassName);
    if Assigned(C) and C.InheritsFrom(TgdcBase) then
    begin
      FEditor.FgdClass := CgdcBase(C);

      if (FEditor.FgdClass.GetListTable(FSubType) > '') and (FLookupTable = '') then
        LookupTable := FEditor.FgdClass.GetListTable(FSubType);

      if (FEditor.FgdClass.GetListField(FSubType) > '') and (FLookupListField = '') then
        FLookupListField := FEditor.FgdClass.GetListField(FSubType);

      if (FEditor.FgdClass.GetKeyField(FSubType) > '') and (FLookupKeyField = '') then
        FLookupKeyField := FEditor.FgdClass.GetKeyField(FSubType);

      FIsTree := False;
      FParentField := '';

      if (C.InheritsFrom(TgdcTree) and (FViewType in [vtByClass, vtTree])) and ((not CgdcTree(C).HasLeafs) or (FViewType = vtTree))  then
      begin
        FIsTree := True;
        FParentField := CgdcTree(C).GetParentField(FSubType);
      end
      else
      begin
        if FViewType = vtTree then
        begin
          FIsTree := False;
          FParentField := '';
          raise Exception.Create('Класс не наследован от дерева! Вы не можете отображать его в виде дерева!');
        end;
      end;
    end else
    begin
      {$IFDEF DEBUG}
//      if not (csDesigning in ComponentState) then
//        raise Exception.Create('Invalid GD class name');
      {$ENDIF}
    end;
  end;
end;

procedure TgsIBColumnEditor.SetLookup(Value: TLookup);
begin
  FLookup.Assign(Value);
end;



procedure TgsIBColumnEditor.SetPopupSet(Value: TSet);
begin
  FSet.Assign(Value);
end;

procedure TgsIBColumnEditor.SetValueList(Value: TStringList);
begin
  FValueList.Assign(Value);
end;


procedure TgsIBColumnEditor.ValueListOnChange(Sender: TObject);
var
  I: Integer;
begin
  FRevertValueList.Clear;
  for I := 0 to FValueList.Count - 1 do
    FRevertValueList.Add(Copy(FValueList[I], Pos('=', FValueList[I]) + 1, Length(FValueList[I])) + '=' + FValueList.Names[I]);
end;

function TgsIBColumnEditor.ViewForm: Integer;
var
  C: TPersistentClass;
  F: TForm;
begin
  Result := -1;
  Assert(FEditorStyle = cesLookup);
  C := GetClass(FLookup.FgdClassName);
  if Assigned(C) and (C.InheritsFrom(TgdcBase)) then
  begin
    F := CgdcBase(C).CreateViewForm(Application, '', FLookup.FSubType, True);
    if Assigned(F) then
    begin
      MessageBox(0,
        'Для выбора объекта установите на него курсор и закройте окно.'#13#10#13#10 +
        'Изменения данных объекта, сделанные Вами в форме просмотра и'#13#10 +
        'выбора, могут быть недоступны в выпадающем списке.'#13#10 +
        '',
        'Выбор объекта',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

      F.ShowModal;
      if MessageBox(0,
        'Вы подтверждаете свой выбор?',
        'Внимание',
        MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
      begin
        if (F is Tgdc_frmMDH) and ((F as Tgdc_frmMDH).gdcDetailObject <> nil) then
        begin
          if C.InheritsFrom((F as Tgdc_frmMDH).gdcDetailObject.ClassType)
            and ((F as Tgdc_frmMDH).gdcDetailObject.ID > 0) then
          begin
            Result := (F as Tgdc_frmMDH).gdcDetailObject.ID;
            FText := (F as Tgdc_frmMDH).gdcDetailObject.FieldByName(GetFieldNameWithoutAlias(FLookup.LookupListField)).AsString;
          end else if ((F as Tgdc_frmMDH).gdcObject <> nil) and
            C.InheritsFrom((F as Tgdc_frmMDH).gdcObject.ClassType)
          then
          begin
            Result := (F as Tgdc_frmMDH).gdcObject.ID;
            FText := (F as Tgdc_frmMDH).gdcObject.FieldByName(GetFieldNameWithoutAlias(FLookup.LookupListField)).AsString;
          end
        end
        else if (F is Tgdc_frmG) and ((F as Tgdc_frmG).gdcObject <> nil) then
        begin
          Result := (F as Tgdc_frmG).gdcObject.ID;
          FText := (F as Tgdc_frmG).gdcObject.FieldByName(GetFieldNameWithoutAlias(FLookup.LookupListField)).AsString;
        end
      end
    end;
  end;
end;

{ TgsIBColumnEditors }

function TgsIBColumnEditors.Add: TgsIBColumnEditor;
begin
  Result := TgsIBColumnEditor(inherited Add);
end;

constructor TgsIBColumnEditors.Create(Grid: TgsCustomIBGrid);
begin
  inherited Create(TgsIBColumnEditor);
  FGrid := Grid;
end;

destructor TgsIBColumnEditors.Destroy;
begin
  inherited Destroy;
end;

function TgsIBColumnEditors.GetEditor(Index: Integer): TgsIBColumnEditor;
begin
  Result := TgsIBColumnEditor(inherited Items[Index]);
end;

function TgsIBColumnEditors.GetOwner: TPersistent;
begin
  Result := FGrid;
end;

function TgsIBColumnEditors.IndexByField(const Name: String): Integer;
begin
  Result := 0;
  while
    (Result < Count) and
    (AnsiCompareText(Items[Result].DisplayField, Name) <> 0)
  do
    Inc(Result);
  if Result = Count then
    Result := -1;
end;

procedure TgsIBColumnEditors.SetEditor(Index: Integer;
  const Value: TgsIBColumnEditor);
begin
  Items[Index].Assign(Value)
end;

procedure TgsIBColumnEditors.Update(Item: TCollectionItem);
begin
 if (FGrid = nil) or (csLoading in FGrid.ComponentState) then Exit;
  FGrid.Invalidate;
end;


{ TPopUpCalendar }

constructor TPopupCalendar.Create(Owner: TComponent);
begin
  inherited;
  Visible := False;
  OnGetMonthInfo := SetMonth;
end;

procedure TPopupCalendar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := WS_EX_TOOLWINDOW;
    WindowClass.style := WindowClass.style and not CS_DBLCLKS;
  end;

end;

procedure TPopUpCalendar.CreateWnd;
begin

  inherited CreateWnd;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

procedure TPopUpCalendar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if not FMonthChanged then
    TgsIBGridInPlaceEdit(Owner).CloseUp((X >= 0) and (Y >= 0) and
        (X < Width) and (Y < Height))
  else
    FMonthChanged := False;
end;



destructor TgsIBGridInplaceEdit.Destroy;
begin
  FPickList.Free;
  FDataList.Free;
  FPopupSetGrid.Free;
  FPopupSetTree.Free;
  FPopupMemo.Free;
  FPopupCalculator.Free;
  FPopupCalendar.Free;
  FLookup.Free;
  FPictureDialog.Free;;
  inherited;
end;

procedure TPopupCalendar.SetMonth(Sender: TObject; Month: LongWord;
  var MonthBoldInfo: LongWord);
begin
  FMonthChanged := True;
end;


{ TPopupCalculator }


procedure TPopupCalculator.Click;
begin
  inherited;
//
end;

constructor TPopupCalculator.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  // Загружаем bitmap калькулятора
  FCalcImage := TImage.Create(AnOwner);
  FCalcImage.Parent := Self;
  FCalcImage.Picture.Bitmap.LoadFromResourceName(hInstance, 'GRIDCALCULATOR');

  Width := FCalcImage.Picture.Bitmap.Width;
  Height := FCalcImage.Picture.Bitmap.Height;

  FCalcImage.Align := alClient;


  TabStop := False;
  Visible := False;

  FCalcImage.OnMouseDown := DoOnMouseDown;
  FPressedButton := Point(0, 0);
  FIsInverted := False;

  FCalculatorEdit := TgsIbGridInplaceEdit(AnOwner);
  FIsFirst := True;
end;

procedure TPopupCalculator.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP;
    ExStyle := WS_EX_TOOLWINDOW;
    AddBiDiModeExStyle(ExStyle);
  end;
end;


procedure TPopupCalculator.CreateWND;
begin
  inherited CreateWnd;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

procedure TPopupCalculator.DoOnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  Arr: array[1..5, 1..4] of Char = (
    ('7', '8', '9', '/'),
    ('4', '5', '6', '*'),
    ('1', '2', '3', '-'),
    ('0', '.', 'I', '+'),
    ('C', 'B', '=', '=')
  );

begin
  Arr[4, 2] := DecimalSeparator;

  FPressedButton := GetPressedButton(Point(X, Y), FBtnRect);
  // Если нажата одна из кнопок
  try
    with FPressedButton do
    case Arr[Y, X] of
      'B': SendMessage(Parent.Handle, WM_CHAR, VK_BACK, 0);
      'I': (FCalculatorEdit as TgsIBGridInplaceEdit).ChangeInvertion;
    else
    //  FCalculatorEdit.KeyPress(Arr[FPressedButton.Y, FPressedButton.X]);
      SendMessage(Parent.Handle, WM_CHAR, Ord(Arr[FPressedButton.Y, FPressedButton.X]), 0);
    end;
  except
  end;
end;

function TPopupCalculator.GetPressedButton(Pos: TPoint;
  var BtnRect: TRect): TPoint;
var
  I, K: Integer;
  NewRect: TRect;
begin
  Result := Point(0, 0); // Устанавливаем 0-ые значения результата

  for I := 0 to HorizNumber - 1 do
  begin
    NewRect.Left := HorizSkip + ButtonWidth * I + Between * I;
    NewRect.Right := NewRect.Left + ButtonWidth - 1;

    for K := 0 to VertNumber - 1 do
    begin
      // Если кнопка "="
      if (I > 1) and (K >= 4) then
      begin
        NewRect.Left := HorizSkip + ButtonWidth * 2 + Between * 2;
        NewRect.Right := NewRect.Left + EqualWidth - 1;
      end;

      NewRect.Top := VertSkip + ButtonHeight * K + Between * K;
      NewRect.Bottom := NewRect.Top + ButtonHeight - 1;

      if (Pos.X >= NewRect.Left) and (Pos.X <= NewRect.Right) and
        (Pos.Y >= NewRect.Top) and (Pos.Y <= NewRect.Bottom) then
      begin
        Result.X := I + 1;
        Result.Y := K + 1;
        BtnRect := NewRect;
        Exit;
      end;
    end;

  end;

end;

procedure TPopupCalculator.InvertByPos(APos: TPoint);
begin
  APos.X := HorizSkip + (ButtonWidth + Between) * APos.X;
  APos.Y := VertSkip + (ButtonHeight + Between) * APos.Y;
  FPressedButton := GetPressedButton(APos, FBtnRect);

  if not FIsInverted then
  begin
    FIsInverted := True;
    InvertPressedButton;
    TimeDelay(100, False);
    InvertPressedButton;
    FIsInverted := False;
  end;
end;

procedure TPopupCalculator.InvertPressedButton;
begin
  InvertRect(FCalcImage.Canvas.Handle, FBtnRect);
  FCalcImage.Repaint;
end;


procedure TPopupCalculator.WMMouseActivate(var Message: TWMMouseActivate);
begin
  Message.Result := MA_NOACTIVATE;
end;

procedure TPopupCalculator.WMWindowPosChanging(
  var Message: TWMWindowPosChanging);
begin

  with Message do
  begin
    if (WindowPos.flags = SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE) and (WindowPos.x = 0) and
      (WindowPos.y = 0) and (WindowPos.cx = 0) and (WindowPos.cy = 0) and
      (FCalculatorEdit as TgsIBGridInplaceEdit).FListVisible  then
    begin
      if FIsFirst then
      begin
        FIsFirst := False;
        Exit;
      end;

      (FCalculatorEdit as TgsIBGridInplaceEdit).FExpressionAction := eaNone;
      (FCalculatorEdit as TgsIBGridInplaceEdit).CloseUp(False);
    end;
  end;

  inherited;
end;


procedure TgsIBGridInplaceEdit.ChangeInvertion;
begin
  FExpressionAction := eaEqual;
  Value := -Value;
  SelStart := Length(Text) + 1;
end;

function TgsIBGridInplaceEdit.GetValue: Double;
begin
  try
    if Text = '' then
      Result := 0
    else
      Result := StrToFloat(Text);
  except
    Result := 0;
  end;
end;

procedure TgsIBGridInplaceEdit.SetValue(AValue: Double);
var
  S: String;
  P, I: Integer;
begin
  // Если нет необходимости в показании 0, то опускаем их.
  if Frac(AValue) <> 0 then
    S := FloatToStrF(AValue, ffGeneral, 15, FDecDigits)
  else
    S := FloatToStrF(AValue, ffGeneral, 15, 0);

  I := Length(S);
  P := Pos('.', S);

  // Заменяем знак "." на стандартный разделитель и проверяем лишние "0".
  if P > 0 then
  begin
    S[P] := DecimalSeparator;

    while I > P + 1 do
      if S[I] = '0' then
        Dec(I)
      else
        Break;
  end;

  Text := Copy(S, 1, I);
end;


function TgsIBGridInplaceEdit.IsValidChar(Key: Char): Boolean;
begin
  Result := (Key in [DecimalSeparator, '0'..'9']) or
    ((Key < #32) and not (Key in [Chr(VK_RETURN), Chr(VK_TAB)]));
end;

procedure TgsIBGridInplaceEdit.KeyPress(var Key: Char);

  function CountValue: Double; // Подсчитывает результат
  begin
    case FExpressionAction of
      eaPlus: Result := FOldValue + Value;
      eaMinus: Result := FOldValue - Value;
      eaMultiple: Result := FOldValue * Value;
      eaDevide: // Проверка деления на 0
        try
          Result := FOldValue / Value;
        except
          on Exception do
          begin
            MessageDlg('Нельзя делить на 0!', mtWarning, [MBOK], 0);
            Result := FOldValue;
          end;
        end;
      else Result := Value;
    end;
    FExpressionAction := eaEqual;
  end;

  procedure GetDateInStr(aDate: TDateTime; var sYear, sMonth, sDay: String);
  begin
    DateTimeToString(sDay, 'dd', aDate);
    DateTimeToString(sMonth, 'mm', aDate);
    DateTimeToString(sYear, 'yyyy', aDate);
  end;

  procedure GetTimeInStr(aTime: TDateTime; var sHour, sMin, sSec: String);
  begin
    DateTimeToString(sHour, 'hh', aTime);
    DateTimeToString(sMin, 'nn', aTime);
    DateTimeToString(sSec, 'ss', aTime);
  end;

  function GetLength: Word;
  begin
    Result := MaxLength;
    while (not (Text[Result] in ['0'..'9'])) and (Result <> 0) do
      Dec(Result);

    if (Result = 2) or (Result = 5) or (Result = 13) or (Result = 16) then
      Inc(Result);
  end;

var
  len: Integer;
  stYear, stDay, stMonth, stHour, stSec, stMin: String;
begin

  if (Key = #32)
    and (FFieldType in [ftDate, ftTime, ftDateTime])
    and (not FListVisible)
    and FCanEdit then
  begin
    Len := SelStart;
    Key := #0;
    case FFieldType of
      ftDate, ftDateTime:
      begin
        GetDateInStr(Now, stYear, stMonth, stDay);
        GetTimeInStr(Now, stHour, stMin, stSec);
        if Len < 3 then
        begin
          Text := '';
          SelStart := 0;
          SelLength :=2;
          inherited KeyPress(stDay[1]);
          inherited KeyPress(stDay[2]);
        end;
        if Len in [3..5] then
        begin
          SelStart := 3;
          SelLength :=2;
          inherited KeyPress(stMonth[1]);
          inherited KeyPress(stMonth[2]);
        end;
        if Len in [6..9] then
        begin
          SelStart := 5;
          SelLength :=4;
          inherited KeyPress(stYear[1]);
          inherited KeyPress(stYear[2]);
          inherited KeyPress(stYear[3]);
          inherited KeyPress(stYear[4]);
          SelStart := 11
        end;
        if Len in [11..13] then
        begin
          SelStart := 10;
          SelLength :=2;
          inherited KeyPress(stHour[1]);
          inherited KeyPress(stHour[2]);
        end;
        if Len in [14..16] then
        begin
          SelStart := 13;
          SelLength :=2;
          inherited KeyPress(stMin[1]);
          inherited KeyPress(stMin[2]);
        end;
        if Len in [17..19] then
        begin
          SelStart := 16;
          SelLength :=2;
          inherited KeyPress(stSec[1]);
          inherited KeyPress(stSec[2]);
        end;
        SelLength := 1;
      end;
      ftTime:
        begin
          GetTimeInStr(Now, stHour, stMin, stSec);
          if Len < 3 then
          begin
            Text := stHour;
            SelStart := 0;
            SelLength :=2;
            inherited KeyPress(stHour[1]);
            inherited KeyPress(stHour[2]);
          end;
          if Len in [3..5] then
          begin
            SelStart := 3;
            SelLength :=2;
            inherited KeyPress(stMin[1]);
            inherited KeyPress(stMin[2]);
          end;
          if Len > 5 then
          begin
            SelStart := 6;
            SelLength :=2;
            inherited KeyPress(stSec[1]);
            inherited KeyPress(stSec[2]);
          end;
          SelLength := 1;
        end;
      end;
    inherited ;
  end;

  if (EditStyle = cesCalculator) and FCanEdit then
  begin
    // Проверка на нажатие кнопи ввод: позволяем данное нажатие, елси скрыт калькулятор
    if not FListVisible and (Ord(Key) = VK_RETURN) then
    begin
      inherited KeyPress(Key);
      Exit;
    end;

    if not (csDesigning in ComponentState) then
    begin
      case Key of
        '.', ',', ' ': Key := DecimalSeparator;
      end;

      if not IsValidChar(Key) then
      begin
        if not FListVisible and (Key in ['-', '+', '*', '/']) then
          DropDown;

        // Производится перерисовка кнопок калькулятора
        if FListVisible then
          case Key of
            '/': FPopupCalculator.InvertByPos(Point(3, 0));
            '*': FPopupCalculator.InvertByPos(Point(3, 1));
            '-': FPopupCalculator.InvertByPos(Point(3, 2));
            '+': FPopupCalculator.InvertByPos(Point(3, 3));
            '=': FPopupCalculator.InvertByPos(Point(3, 4));
            else if AnsiCompareText(Key, 'c') = 0 then
              FPopupCalculator.InvertByPos(Point(0, 4));
          end;

        // Если нажата кнопка сброса
        if (AnsiCompareText(Key, 'C') = 0) and FListVisible then
        begin
          Value := 0;
          FExpressionAction := eaEqual;
          FOldValue := 0;
          FOldValueEntered := False;
          FNeedToChangeValue := False;
        end else if ((Ord(Key) = VK_RETURN) or (Key = '=') or (Ord(Key) = VK_TAB) ) and FListVisible then
        begin // Если нажата кнопка Enter или знак "="
          if not FNeedToChangeValue then
            Value := CountValue;

          CloseUp(True);
          FOldValue := 0;
          FOldValueEntered := False;
          if Ord(Key) = VK_TAB then
            PostMessage(Grid.Handle, WM_KEYDOWN, VK_TAB, 0);

        end else if (Key in ['+', '-', '*', '/']) and FListVisible then
        begin // Если выбран один из вышеперечисленных знаков
          if FOldValueEntered and not FNeedToChangeValue then Value := CountValue;

          case Key of // Устанавливаем вид действия
            '+': FExpressionAction := eaPlus;
            '-': FExpressionAction := eaMinus;
            '*': FExpressionAction := eaMultiple;
            '/': FExpressionAction := eaDevide;
          end;

          // Происходит сохранение первого числа или его обнуление
          if not FOldValueEntered or (Key <> '=') then
          begin
            FOldValue := Value;
            FOldValueEntered := True;
            FNeedToChangeValue := True;
          end else if not FNeedToChangeValue then
          begin
            FOldValue := 0;
            FOldValueEntered := False;
          end;
        end;

        Key := #0;
      end else begin
        // Производится перерисовка кнопок калькулятора
        if FListVisible then
        begin
          case Key of
            '7'..'9': FPopupCalculator.InvertByPos(Point(StrToInt(Key) - 7, 0));
            '4'..'6': FPopupCalculator.InvertByPos(Point(StrToInt(Key) - 4, 1));
            '1'..'3': FPopupCalculator.InvertByPos(Point(StrToInt(Key) - 1, 2));
            '0': FPopupCalculator.InvertByPos(Point(0, 3));
            else if Key = DecimalSeparator then
              FPopupCalculator.InvertByPos(Point(1, 3))
            else if Ord(Key) = VK_BACK then
              FPopupCalculator.InvertByPos(Point(1, 4));
          end;
        end;
        if (Ord(Key) = VK_BACK) and FListVisible then
        begin // Если нажата кнопка BACKSPACE
          if FExpressionAction = eaNone then Key := #0;
        end else if FNeedToChangeValue and FListVisible then
        begin // Если нужно подставить новое число
          FNeedToChangeValue := False;
          if FExpressionAction = eaNone then FExpressionAction := eaEqual;

          if Key <> DecimalSeparator then
            Text := ''
          else
            Text := '0';
        // В строке не может быть несколько разделителей
        end else if (Key = DecimalSeparator) and (Pos(Key, Text) > 0) then
          Key := #0;
      end;

      // Если в строке стоит только 0, то мы удаляем его
      if (Key <> #0) and (Text = '0') and (Key <> DecimalSeparator) then
        Text := '';

      if Key <> #0 then
      begin
        inherited KeyPress(Key);
        // Подстановка 0 при BACKSPACE
        if (Length(Text) <= 1) and (Ord(Key) = VK_BACK) and FListVisible then
          Text := '0 ';
      end;
    end else
      inherited KeyPress(Key);
    // Устанавливаем позицию курсора в конце
    if FListVisible then SelStart := Length(Text) + 1;
  end
  else
  if (EditStyle = cesSetGrid) then
  begin
    Key := #0;
    inherited;
  end else
    inherited;
end;



{ TPopUpLookup }

procedure TPopupLookup.AssignExpands;
var
  I: Integer;
  ColumnExpand: TColumnExpand;
begin
  if not FTree then
  begin
    FGrid.Expands.Clear;
    for I := 0 to FListSource.DataSet.Fields.Count - 1 do
    begin
      if (FKeyField <> FListField) and (AnsiCompareText(FKeyField, FListSource.DataSet.Fields[I].FieldName) = 0) then
      begin
        FGrid.ColumnByField(FListSource.DataSet.Fields[I]).Visible := False;
        continue;
      end;

      if (AnsiCompareText(FListField, FListSource.DataSet.Fields[I].FieldName) = 0) then
      begin
        FGrid.ColumnByField(FListSource.DataSet.Fields[I]).Visible := True;
        continue;
      end;

      ColumnExpand := FGrid.Expands.Add;
      ColumnExpand.DisplayField := FListSource.DataSet.Fields[0].FieldName;
      ColumnExpand.FieldName := FListSource.DataSet.Fields[I].FieldName;
      ColumnExpand.Options := [ceoAddField];
      FGrid.ColumnByField(FListSource.DataSet.Fields[I]).Visible := False;
    end;
    FGrid.ExpandsActive := True;
  end;
end;

constructor TPopUpLookup.Create(Owner: TComponent);
begin
  inherited;
  FGrid := TgsIBGrid.Create(Self);
  FGrid.DisableActions;
  FGrid.ShowTotals := False;
  FGrid.BorderStyle := bsNone;
  FGrid.Striped := True;
  FGrid.StripeEven := $00D6E7E7;
  FGrid.StripeOdd := $00E7F3F7;
  FGrid.RememberPosition := true;
  FGrid.SaveSettings := False;
  FGrid.ReadOnly := True;
  FGrid.Options := [dgColumnResize, {dgRowLines,} dgRowSelect,
                    dgAlwaysShowSelection, dgConfirmDelete,
                    dgCancelOnExit];
  FGrid.OnKeyDown := GridKeyDown;
  FGrid.OnCellClick := GridCellClick;
  FGrid.Align := alClient;
  FGrid.Parent := Self;
  FGrid.Options := FGrid.Options + [dgTabs];
  FGrid.ScaleColumns := True;

  FTV := TgsDbTreeView.Create(Self);
  FTV.DisableActions;
  FTV.ReadOnly := True;
  FTV.Align := alNone;
  FTV.Enabled := False;
  FTV.Width := 0;
  FTV.Parent:= Self;

  FTV.HideSelection := False;
  FTV.OnKeyDown := GridKeyDown;
  FTV.OnMouseDown := tvMouseDown;
//  FTV.OnCellClick := GridCellClick;

  FMainControl := FGrid;

  FbtnMerge := TSpeedButton.Create(Self);
  FbtnMerge.Glyph.LoadFromResourceName(hInstance, 'IBGRIDMERGE');
  FbtnMerge.OnClick := MergeExecute;
  AddButton(FbtnMerge);
  FbtnDelete := TSpeedButton.Create(Self);
  FbtnDelete.Glyph.LoadFromResourceName(hInstance, 'IBGRIDDELETE');
  FbtnDelete.OnClick := DeleteExecute;
  AddButton(FbtnDelete);
  FbtnEdit := TSpeedButton.Create(Self);
  FbtnEdit.Glyph.LoadFromResourceName(hInstance, 'IBGRIDEDIT');
  FbtnEdit.OnClick := EditExecute;
  AddButton(FbtnEdit);
  FbtnNew := TSpeedButton.Create(Self);
  FbtnNew.Glyph.LoadFromResourceName(hInstance, 'IBGRIDNEW');
  FbtnNew.OnClick := NewExecute;
  AddButton(FbtnNew);
  FMinWidth := 4 * ToolBarHeight;

  BevelInner := bvNone;
  BevelOuter := bvNone;
end;

procedure TPopupLookup.DeleteExecute(Sender: TObject);
begin
  SendMessage(Handle, WM_KEYDOWN, VK_F8, 0);
end;

destructor TPopupLookup.Destroy;
begin
  FGrid.Free;
  FTV.Free;
  FbtnNew.Free;
  FbtnEdit.Free;
  FbtnDelete.Free;
  FbtnMerge.Free;

  inherited;
end;

procedure TPopupLookup.EditExecute(Sender: TObject);
begin
  SEndMessage(Handle, WM_KEYDOWN, VK_F4, 0);
end;

function TPopUpLookup.GetKeyValue: Variant;
var
  I: Integer;
begin
  I := Pos('.', KeyField);
  if I > 0 then
    Result := FListSource.DataSet.FieldByName(Copy(KeyField, I + 1, Length(KeyField))).AsVariant
  else
    Result := FListSource.DataSet.FieldByName(KeyField).AsVariant;
end;

function TPopUpLookup.GetListValue: Variant;
var
  I: Integer;
begin
  I := Pos('.', ListField);
  if I > 0 then
    Result := FListSource.DataSet.FieldByName(Copy(ListField, I + 1, Length(ListField))).AsVariant
  else
    Result := FListSource.DataSet.FieldByName(ListField).AsVariant;
end;

procedure TPopupLookup.GridCellClick(Column: TColumn);
begin
  FEditor.CloseUp(True);
end;

procedure TPopupLookup.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and (Key = Ord('R')) then
  begin
    FEditor.CloseUp(True);
    SendMessage(FEditor.Handle, CM_DOREDUCE, 0, 0);
  end;
  if Key in [VK_F2, VK_F3, VK_F7, VK_F4, VK_F5, {VK_F6,} VK_F8, VK_TAB] then
  begin
    if Key in [VK_F2, VK_F3, VK_F7] then
      FEditor.CloseUp(False);
    if Key in [VK_F4, VK_F5{, VK_F6}, VK_F8, VK_TAB] then
      FEditor.CloseUp(True);
    SendMessage(FEditor.Handle, WM_KEYDOWN, Key, 0);
  end
  else
    Inherited;
end;

procedure TPopupLookup.MergeExecute(Sender: TObject);
var
  Key: Word;
begin
  Key := Ord('R');
  GridKeyDown(Self, Key, KeysToShiftState(MK_CONTROL))
end;

procedure TPopupLookup.NewExecute(Sender: TObject);
begin
  SendMessage(Handle, WM_KEYDOWN, VK_F2, 0);
end;

procedure TPopupLookup.SetKeyField(const Value: String);
begin
  if FKeyField <> Value then
  begin
    FKeyField := Value;
    FTV.KeyField := FKeyField;
  end;
end;

procedure TPopUpLookup.SetKeyValue(Value: Variant);
begin
  if (not VarIsNull(Value)) and (not VarIsEmpty(Value)) then FListSource.DataSet.Locate(FKeyField, Value, [])
    else FListSource.DataSet.First;
end;

procedure TPopupLookup.SetListField(const Value: String);
begin
  if FListField <> Value then
  begin
    FListField := Value;
    FTV.DisplayField := FListField;
  end;
end;

procedure TPopUpLookup.SetListSource(Value: TDataSource);
begin
  if FListSource <> Value then
  begin
    FListSource := Value;
    if FTree then
    begin
      FTV.DataSource := FListSource;
      FGrid.DataSource := nil;
    end
    else
    begin
      FGrid.DataSource := FListSource;
      FTV.DataSource := nil;
    end
  end;
end;

procedure TPopupLookup.SetMinWidth(const Value: Integer);
begin
  if Value < (6 * ToolBarHeight) then
    inherited SetMinWidth(6 * ToolBarHeight)
  else
    inherited SetMinWidth(Value);
end;

procedure TPopupLookup.SetParentField(const Value: String);
begin
  if FParentField <> Value then
  begin
    FParentField := Value;
    FTV.ParentField := Value;
  end;
end;

procedure TPopupLookup.SetTree(const Value: Boolean);
begin
  if Value <> FTree then
  begin
    FTree := Value;
    if FTree then
    begin
      FGrid.Align := alNone;
      FGrid.Width := 0;
      FGrid.Enabled := False;
      FGrid.Visible := False;


      FTV.Visible := True;
      FTV.Align := alClient;
      FTV.Enabled := True;

      FMainControl := FTV;

    end
    else
    begin
      FTV.Align := AlNone;
      FTV.Width := 0;
      FTV.Enabled := False;
      FTV.Visible := False;

      FGrid.Visible := True;
      FGrid.Align := alClient;
      FGrid.Enabled := True;

      FMainControl := FGrid;
    end;
  end;

end;

procedure TPopupLookup.tvMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if htOnItem in Ftv.GetHitTestInfoAt(X, Y)  then
    FEditor.CloseUp(True);
end;

{ TPopupSetGrid }

function TPopupSetGrid.ApplyChanges: String;
var
  I: Integer;
begin
  Result := '';
  with FEditor.FCurrentEditor do
  begin
    for I := 0 to FSetGrid.CheckBox.CheckCount - 1 do
    begin
      if FSourceDataset.Locate(FSet.SourceKeyField, FSetGrid.CheckBox.CheckList[I],[]) then
        Result := Result + FSourceDataset.FieldByName(FSet.SourceListField).AsString;
      if I <> (FSetGrid.CheckBox.CheckCount - 1) then
        Result := Result + ', ';
    end;
    FCrossDataset.ApplyUpdates;
  end;
end;

procedure TPopupSetGrid.CancelChanges;
begin
  FEditor.FCurrentEditor.FCrossDataset.CancelUpdates;
end;

procedure TPopupSetGrid.CheckBoxSet(Sender: TObject; CheckID: String;
  var Checked: Boolean);
begin
//
  if not FSetState then
  with FEditor.FCurrentEditor do
  if Checked then
  begin
    try
      FCrossDataset.Insert;
      FCrossDataset.FieldByName(FSet.CrossDestField).AsVariant := FCurrentKey;
      FCrossDataset.FieldByName(FSet.CrossSourceField).AsVariant := FSourceDataset.FieldByName(FSet.SourceKeyField).AsVariant;
      FCrossDataset.Post;
    except
      FCrossDataset.Cancel;
      raise;
    end;
  end else begin
    if
      FCrossDataset.Locate
      (
        FSet.CrossDestField + ';' + FSet.CrossSourceField,
        VarArrayOf([FCurrentKey, CheckID]),
        []
      )
    then
      FCrossDataset.Delete;
  end;
end;

procedure TPopupSetGrid.ClearCheckBoxes;
begin
  FSetGrid.CheckBox.Clear;
end;

constructor TPopupSetGrid.Create(AOwner: TComponent);
var
  Item: TMenuItem;
begin
  inherited;

  FSetGrid := TgsDBGrid.Create(Self);
  FSetGrid.ShowTotals := False;
  FSetGrid.Align := alClient;
  FSetGrid.RememberPosition := True;
  FSetGrid.SaveSettings := False;
  FSetGrid.ReadOnly := True;

  FSetGrid.Options := [dgColumnResize, dgColLines, dgRowLines, dgRowSelect,
                dgAlwaysShowSelection];
  FSetGrid.OnKeyDown := GridKeyDown;
  FSetGrid.CheckBox.CheckBoxEvent := CheckBoxSet;

  FSetGrid.Striped := True;
  FSetGrid.StripeEven := $00D6E7E7;
  FSetGrid.StripeOdd := $00E7F3F7;
  FSetGrid.SaveSettings := False;
  FSetGrid.ScaleColumns := True;
  InsertControl(FSetGrid);
  FMainControl := FSetGrid;

  FMenu := TPopupMenu.Create(Self);

  Item := TMenuItem.Create(FMenu);
  Item.Caption := 'Выбрать все';
  Item.OnClick := SelectAll;
  FMenu.Items.Add(Item);

  Item := TMenuItem.Create(FMenu);
  Item.Caption := 'Очистить все';
  Item.OnClick := RemoveAll;
  FMenu.Items.Add(Item);

  FSetGrid.PopupMenu := FMenu;

end;

destructor TPopupSetGrid.Destroy;
begin
  FMenu.Free;
  FSetGrid.Free;
  inherited;
end;

procedure TPopupSetGrid.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: FEditor.CloseUp(True, False);
    VK_ESCAPE: FEditor.CloseUp(False, False);
  end;

end;


procedure TPopupSetGrid.RemoveAll(Sender: TObject);
var
  I: Integer;
begin
  FSetGrid.CheckBox.BeginUpdate;
  try
    for I := 0 to FSetGrid.CheckBox.CheckCount - 1 do
      FSetGrid.CheckBox.DeleteCheck(FSetGrid.CheckBox.StrCheck[0]);
  finally
    FSetGrid.CheckBox.EndUpdate;
  end;
end;

procedure TPopupSetGrid.SelectAll(Sender: TObject);
var
  Mark: TBookmark;
  I: Integer;
begin

  with FEditor.FCurrentEditor do
  begin
    Mark := FSourceDataset.GetBookmark;

    FSourceDataset.DisableControls;
    FSetGrid.CheckBox.BeginUpdate;

    try
      FSourceDataset.First;
      I := 0;
      while not FSourceDataset.EOF do
      begin
        if not FSetGrid.CheckBox.RecordChecked then
          FSetGrid.CheckBox.AddCheck(FSourceDataset.FieldByName(FSet.SourceKeyField).AsString);
        Inc(I);

        if (I mod 300 = 0) and (MessageBox(Handle, 'Обработано 300 записей. Продолжить?',
          'Внимание!', MB_ICONINFORMATION or MB_YESNO) = mrNo)
        then
          Break;

        FSourceDataset.Next;
      end;

    finally
      FSourceDataset.EnableControls;
      if FSourceDataset.BookmarkValid(Mark) then
        FSourceDataset.GotoBookmark(Mark);
      FSetGrid.CheckBox.EndUpdate;
    end;
  end;
end;

procedure TPopupSetGrid.SetupCheckBoxes;
begin
  with FEditor.FCurrentEditor, FSetGrid do
  begin
    CheckBox.BeginUpdate;
    CheckBox.Clear;
    CheckBox.DisplayField := FSet.SourceListField;
    CheckBox.FieldName := FSet.SourceKeyField;
    CheckBox.Visible := True;
    FCrossDataset.Close;
    FCrossDataset.CachedUpdates := True;
    FCrossDataSet.ParamByName('Key').AsInteger := Integer(FCurrentKey);
    FCrossDataSet.Open;
    FSetState := True;
    try
      while not FCrossDataset.EOF do
      begin
        CheckBox.AddCheck(FCrossDataSet.FieldByName(FSet.CrossSourceField).AsString);
        FCrossDataset.Next;
      end;
    finally
      CheckBox.EndUpdate;
      FSetState := False;
    end;
  end;
end;

{ TLookup }

procedure TLookup.Assign(Source: TPersistent);
begin
  FLookupListField := TLookup(Source).LookupListField;
  FLookupKeyField := TLookup(Source).LookupKeyField;
  FLookupTable := TLookup(Source).LookupTable;
  FCondition := TLookup(Source).Condition;
  FCheckUserRights := TLookup(Source).CheckUserRights;
  FSortOrder := TLookup(Source).SortOrder;
  inherited;
end;

constructor TLookup.Create(Owner: TgsIBColumnEditor);
begin
  inherited Create;

  FParams := TStringList.Create;

  FFullSearchOnExit := True;

  FCountAddField := 0;
  FEditor := Owner;
  FCheckUserRights := DefCheckUserRights;
  FSortOrder := DefSortOrder;
  FViewType := vtByClass;
  FSubType := '';

  FIBBase := TIBBase.Create(Self);
end;

procedure TLookup.SetLookupKeyField(const Value: String);
begin
  if Trim(Value) <> FLookupKeyField then
  begin
    FLookupKeyField := Trim(Value);
    FEditor.FLookupPrepared := False;
  end
end;

procedure TLookup.SetLookupListField(const Value: String);
begin
  if Trim(Value) <> FLookupListField then
  begin
    FLookupListField := Trim(Value);
    FEditor.FLookupPrepared := False;
  end
end;

procedure TLookup.SetLookupTable(const Value: String);
begin
  Assert(atDatabase <> nil);

  if Trim(Value) <> FLookupTable then
  begin
    FLookupTable := Trim(Value);
    FEditor.FLookupPrepared := False;
  end
end;

procedure TLookup.SetCondition(const Value: String);
begin
  if FCondition <> Value then
  begin
    FCondition := Value;
    FEditor.FLookupPrepared := False;
  end
end;

function TLookup.GetDatabase: TIBDatabase;
begin
  Result := FIBBase.Database;
end;

function TLookup.GetTransaction: TIBTransaction;
begin
  Result := FIBBase.Transaction;
end;

procedure TLookup.SetDatabase(const Value: TIBDatabase);
begin
  FIBBase.Database := Value;
end;

procedure TLookup.SetTransaction(const Value: TIBTransaction);
begin
  FIBBase.Transaction := Value;
end;

destructor TLookup.Destroy;
begin
  FIBBase.Free;
  FParams.Free;
  inherited;
end;

procedure TLookup.SetGroupBy(const Value: String);
begin
  if FGroupBY <> Value then
  begin
    FGroupBY := Value;
    FEditor.FLookupPrepared := False;
  end
end;

procedure TLookup.SetFields(const Value: String);
var
  I: Integer;
begin
  if FFields <> Value then
  begin
    FFields := StringReplace(Trim(Value), ';', ',', [rfReplaceAll]);
    FCountAddField := 0;
    if FFields > '' then
    begin
      Inc(FCountAddField);
      for I := 1 to Length(FFields) - 1 do { -1 to allow strings like aaa;bbb; }
        if FFields[i] = ',' then Inc(FCountAddField);
    end;
  end;
end;

function TLookup.GetMainTableAlias: String;
const
  SacredWords = ';JOIN;LEFT;RIGHT;FULL;OUTER;INNER;,;ON;';
var
  i: Integer;
  St: String;
  TmpLookupTable: String;
begin
//Попробуем вытянуть алиас главной таблицы
//главная таблица должна идти первой!!!
//Если есть несколько таблиц, то они не должны разделяться запятой!!!!
  TmpLookupTable := TrimLeft(FLookupTable);
  i := Pos(' ', TmpLookupTable);
  if i = 0 then
    Result := TmpLookupTable
  else
  begin
    St := Trim(Copy(TmpLookupTable, I, Length(TmpLookupTable) - I + 1));
    if (Pos(' ', St) > 0) and (AnsiPos(';' + AnsiUpperCase(Copy(St, 1, Pos(' ', St) - 1)) + ';', SacredWords) = 0) then
      Result := Copy(St, 1, Pos(' ', St) - 1)
    else if (Pos(' ', St) = 0) and (AnsiPos(';' + AnsiUpperCase(St) + ';', SacredWords) = 0) then
      Result := St
    else
      Result := Copy(TmpLookupTable, 1, i - 1);
  end;
end;

function TLookup.GetMainTableName: String;
var
  i: Integer;
begin
  i := Pos(' ', Trim(FLookupTable));
  if i = 0 then
    Result := FLookupTable
  else
    Result := Copy(Trim(FLookupTable), 1, i - 1);
{$IFDEF DEBUG}
  if Pos(' ', FLookupTable) = 1 then
    ShowMessage(FLookupTable);
{$ENDIF}
end;

function TLookup.FieldWithAlias(AFieldName: String): String;
var
  SL: TStringList;
  I: Integer;
begin
  AFieldName := Trim(AFieldName);

  if Pos(',', AFieldName) = 0 then
  begin
    if Pos('.', AFieldName) > 0 then
      Result := AFieldName
    else
      Result := GetMainTableAlias + '.' + AFieldName;
  end else
  begin
    SL := TStringList.Create;
    try
      SL.CommaText := AFieldName;
      for I := 0 to SL.Count - 1 do
      begin
        if Pos('.', SL[I]) = 0 then
          SL[I] := GetMainTableAlias + '.' + SL[I];
      end;
      Result := SL.CommaText;
    finally
      SL.Free;
    end;
  end;
end;

function TLookup.GetParams: TStrings;
begin
  Result := FParams;
end;

procedure TLookup.SetDistinct(const Value: Boolean);
begin
  FDistinct := Value;
end;

function TLookup.GetDistinct: Boolean;
begin
  Result := FDistinct;
end;

procedure TLookup.SetFullSearchOnExit(const Value: Boolean);
begin
  FFullSearchOnExit := Value;
end;

function TLookup.GetFullSearchOnExit: Boolean;
begin
  Result := FFullSearchOnExit;
end;

procedure TLookup.SetViewType(const Value: TgsViewType);
var
  C: TPersistentClass;
begin
  FViewType := Value;
  FIsTree := False;
  FParentField := '';

  if FgdClassName > '' then
  begin
    C := GetClass(FgdClassName);
    if Assigned(C) and C.InheritsFrom(TgdcBase) then
    begin
      if (C.InheritsFrom(TgdcTree) and (FViewType in [vtByClass, vtTree])) and ((not CgdcTree(C).HasLeafs) or (FViewType = vtTree))  then
      begin
        FIsTree := True;
        FParentField := CgdcTree(C).GetParentField(FSubType);
      end
      else
      begin
        if FViewType = vtTree then
        begin
          FIsTree := False;
          FParentField := '';

          raise Exception.Create('Класс не наследован от дерева! Вы не можете отображать его в виде дерева!');
        end;  
      end;
    end;
  end;

end;

procedure TLookup.SetSubType(const Value: String);
begin
  FSubType := Value;
end;

{ TSet }

procedure TSet.Assign(Source: TPersistent);
begin
  FKeyField := TSet(Source).KeyField;
  FSourceKeyField := TSet(Source).SourceKeyField;
  FSourceListField := TSet(Source).SourceListField;
  FSourceParentField := TSet(Source).SourceParentField;
  FCrossDestField := TSet(Source).CrossDestField;
  FCrossSourceField := TSet(Source).CrossSourceField;
  FSourceTable := TSet(Source).SourceTable;
  FCrossTable := TSet(Source).CrossTable;

  inherited;
end;

constructor TSet.Create(Owner: TgsIBColumnEditor);
begin
  inherited Create;
  FEditor := Owner;
end;

procedure TSet.SetCrossDestField(const Value: String);
begin
  if Value <> FCrossDestField then
  begin
    FCrossDestField := Value;
    FEditor.FSetPrepared := False;
  end
end;

procedure TSet.SetCrossSourceField(const Value: String);
begin
  if Value <> FCrossSourceField then
  begin
    FCrossSourceField := Value;
    FEditor.FSetPrepared := False;
  end
end;

procedure TSet.SetCrossTable(const Value: String);
begin
  if Value <> FCrossTable then
  begin
    FCrossTable := Value;
    FEditor.FSetPrepared := False;
  end
end;

procedure TSet.SetSourceKeyField(const Value: String);
begin
  if Value <> FSourceKeyField then
  begin
    FSourceKeyField := Value;
    FEditor.FSetPrepared := False;
  end
end;

procedure TSet.SetSourceListField(const Value: String);
begin
  if Value <> FSourceListField then
  begin
    FSourceListField := Value;
    FEditor.FSetPrepared := False;
  end
end;

procedure TSet.SetSourceParentField(const Value: String);
begin
  if Value <> FSourceParentField then
  begin
    FSourceParentField := Value;
    FEditor.FSetPrepared := False;
  end
end;

procedure TSet.SetSourceTable(const Value: String);
begin
  if Value <> FSourceTable then
  begin
    FSourceTable := Value;
    FEditor.FSetPrepared := False;
  end
end;

{ TPopupSetTree }

function TPopupSetTree.ApplyChanges: String;
begin
  Result := '';
  FEditor.FCurrentEditor.FCrossDataset.ApplyUpdates;
end;

procedure TPopupSetTree.CancelChanges;
begin
  FEditor.FCurrentEditor.FCrossDataset.CancelUpdates;
end;


procedure TPopupSetTree.ClearCheckBoxes;
var
  I: Integer;
begin
  for I := 0 to FSetTree.Items.Count - 1 do
    FSetTree.SetCheck(FSetTree.Items[I], False);
end;

constructor TPopupSetTree.Create(AnOwner: TComponent);
var
  Item: TMenuItem;
begin
  inherited;

  FSetTree := TPopupTree.Create(Self);
  FSetTree.WithCheckBox := True;
  FSetTree.HideSelection := False;
  MainControl := FSetTree;

  FLoading := False;
  FList := TStringList.Create;
  FNames := TStringList.Create;

  FMenu := TPopupMenu.Create(Self);

  Item := TMenuItem.Create(FMenu);
  Item.Caption := 'Выбрать все считанные записи.';
  Item.OnClick := SelectAll;
  FMenu.Items.Add(Item);

  Item := TMenuItem.Create(FMenu);
  Item.Caption := 'Очистить все считанные записи.';
  Item.OnClick := RemoveAll;
  FMenu.Items.Add(Item);

  PopupMenu := FMenu;
end;

destructor TPopupSetTree.Destroy;
begin
  FreeAndNil(FList);
  FreeAndNil(FNames);
  inherited;
end;

procedure TPopupSetTree.RemoveAll(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FSetTree.Items.Count - 1 do
  begin
    FSetTree.SetCheck(FSetTree.Items[I], False);
  end;
end;

procedure TPopupSetTree.SelectAll(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FSetTree.Items.Count - 1 do
  begin
    FSetTree.SetCheck(FSetTree.Items[I], True);
  end;
end;

constructor TPopupTree.Create(AOwner: TComponent);
begin
  inherited;
  FParent := AOwner As TPopupSetTree;
end;

procedure TPopupTree.SetCheck(Node: TTreeNode; Check: Boolean);
begin
  inherited;
  if not FParent.FLoading then
  begin
    with FParent.FEditor.FCurrentEditor, FParent do
    if Check then
    begin
      try
        FCrossDataset.Insert;
        FCrossDataset.FieldByName(FSet.CrossDestField).AsVariant := FCurrentKey;
        FCrossDataset.FieldByName(FSet.CrossSourceField).AsVariant := Integer(Node.Data);
        FCrossDataset.Post;
      except
        FCrossDataset.Cancel;
        raise;
      end;
    end else begin
      if
        FCrossDataset.Locate
        (
          FSet.CrossDestField + ';' + FSet.CrossSourceField,
          VarArrayOf([FCurrentKey, Integer(Node.Data)]),
          []
        )
      then
        FCrossDataset.Delete;
    end;
  end;
end;

procedure TPopupSetTree.SetupCheckBoxes;
var
  N: TTreeNode;
begin
  FLoading := True;
  try
    with FEditor.FCurrentEditor do
    begin

      FSetTree.Items.BeginUpdate;
      try

        ClearCheckBoxes;

        FCrossDataset.Close;
        FCrossDataset.CachedUpdates := True;
        FCrossDataSet.ParamByName('Key').AsInteger := FCurrentKey;
        FCrossDataSet.Open;

        while not FCrossDataset.EOF do
        begin
          N := FSetTree.NodeByKeyField(FCrossDataSet.FieldByName(FSet.CrossSourceField).AsInteger);
          if Assigned(N) then
            FSetTree.SetCheck(N, True);
          FCrossDataset.Next;
        end;

      finally
        FSetTree.Items.EndUpdate;
      end;
    end;
  finally
    FLoading := False;
  end
end;

{ TPopupEditor }
constructor TPopupMemo.Create(AOwner: TComponent);
begin
  inherited;
  WordWrap := True;
  ScrollBars := ssVertical;
end;

procedure TPopupMemo.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_BORDER;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
    AddBiDiModeExStyle(ExStyle);
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

procedure TPopupMemo.CreateWnd;
begin
  inherited CreateWnd;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

{ TPopupPanel }

procedure TPopupPanel.AddButton(Button: TSpeedButton; ALeftAlign: boolean = True);
begin
  if ALeftAlign then
    Button.Align := alLeft
  else
    Button.Align := alRight;

  Button.Height := ToolBarHeight;
  Button.Width := ToolBarHeight;
  Button.AllowAllUp := True;
  Button.Flat := True;
  FToolBar.InsertControl(Button);
end;

constructor TPopupPanel.Create(AnOwner: TComponent);
begin
  inherited;

  Parent := (AnOwner As TWinControl);

  BorderStyle := bsNone;
  BevelOuter := bvRaised;
  BevelInner := bvNone;

  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or
   SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_HIDEWINDOW);

  FEditor := TgsIBGridInplaceEdit(Owner);

  FShrinkAction := TAction.Create(Self);
  FShrinkAction.OnExecute := ShrinkExecute;

  FGrowAction := TAction.Create(Self);
  FGrowAction.OnExecute := GrowExecute;

  Caption := '';
  FToolbar := TPanel.Create(Self);
  FToolbar.Height := ToolBarHeight;
  FToolbar.Caption := '';
  FToolbar.Align := alTop;
  FToolbar.BevelOuter := bvNone;
  FToolbar.BevelInner := bvNone;

  InsertControl(FToolBar);

  FbtnGrow := TSpeedButton.Create(FToolbar);
  FbtnGrow.Glyph.LoadFromResourceName(hInstance, 'IBGRIDGROW');
  FbtnGrow.Action := FGrowAction;
  AddButton(FbtnGrow, False);

  FbtnShrink := TSpeedButton.Create(FToolbar);
  FbtnShrink.Glyph.LoadFromResourceName(hInstance, 'IBGRIDSHRINK');
  FbtnShrink.Action := FShrinkAction;
  AddButton(FbtnShrink, False);

  FShrinkAction.Enabled := (Width > FMinWidth) ;
end;

procedure TPopupPanel.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_BORDER;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
    AddBiDiModeExStyle(ExStyle);
    WindowClass.Style := CS_SAVEBITS;
  end;
end;

procedure TPopupPanel.CreateWnd;
begin
  inherited CreateWnd;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, wm_SetFocus, 0, 0);
end;

destructor TPopupPanel.Destroy;
begin
  FbtnGrow.Free;
  FbtnShrink.Free;
  FToolbar.Free;
  FShrinkAction.Free;
  FGrowAction.Free;

  inherited;
end;

procedure TPopupPanel.GrowExecute(Sender: TObject);
var
  Pt: TPoint;
begin
  Width := Width + 20;
  if GetCursorPos(Pt) then SetCursorPos(Pt.X + 20, Pt.Y);
  FGrowAction.Enabled := Left + Width < Screen.Width - 20;
  FShrinkAction.Enabled := (Width > FMinWidth);
end;


procedure TPopupPanel.SetMainControl(Control: TWinControl);
begin
  if Control <> FMainControl then
  begin
    if FMainControl <> nil then
      FMainControl.Parent := nil;

    Control.Align := alClient;
    FMainControl := Control;
    FMainControl.Parent := Self;
   // InsertControl(FMainControl);
  end;
end;

procedure TPopupPanel.SetMinWidth(const Value: Integer);
begin
  if FMinWidth < Value then
  begin
    FMinWidth := Value;
    Width := FMinWidth;
    FShrinkAction.Enabled := (Width > FMinWidth) ;
  end
end;

procedure TPopupPanel.SetRowCount(const Value: Integer);
begin
  if Value <> FRowCount then
  begin
    FRowCount := Value;
    Height := Abs(Font.Height) * 2 * FRowCount;
  end;
end;

procedure TPopupPanel.ShrinkExecute(Sender: TObject);
var
  Pt: TPoint;
  I: Integer;
begin
  if (Width - 20) < FMinWidth then
  begin
    I := Width - FMinWidth;
    Width := FMinWidth;
    if GetCursorPos(Pt) then SetCursorPos(Pt.X - I, Pt.Y);
  end
  else
  begin
    Width := Width - 20;
    if GetCursorPos(Pt) then SetCursorPos(Pt.X - 20, Pt.Y);
  end;

  FShrinkAction.Enabled := (Width > FMinWidth);
  FGrowAction.Enabled := Left + Width < Screen.Width - 20;
end;

procedure TPopupPanel.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    wm_KeyDown, wm_SysKeyDown, wm_Char, wm_SetFocus:
    begin
      with Message do
        SendMessage(FMainControl.Handle, Msg, WParam, LParam);
      Exit;
    end;
  end;
  inherited;
end;

procedure TgsIBGridInplaceEdit.CMDoReduce(var Message: TMessage);
var
  Key: Word;
begin
  Key := Ord('R');
  KeyDown(Key, KeysToShiftState(MK_CONTROL));
end;

initialization

  TempBitmap := TBitmap.Create;
  TempBitmap.Width := 40;
  TempBitmap.Height := 40;

finalization
  FreeAndNil(TempBitmap);
end.

