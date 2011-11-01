
{++


  Copyright (c) 2000 by Golden Software of Belarus

  Module

    gsDBGrid.pas

  Abstract

    Original Delphi's DBGrid with additional options.

  Author

    Romanovski Denis (31-08-2000)

  Revisions history

    Initial  31-08-2000  Dennis  Initial version.
             25-10-2001  Nick добавлена обработка выделения по
                         PgDn PgUp Home End
                         Откоректирована работа агрегатов
             02-11-2001  Nick если поле типа TBlobField и подтип ftGraphic
                         то теперь в поле пишет слово Рисунок из GraphicFieldString
             08-11-2001  Nick агрегаты теперь выделяются не только жирным шрифтом но и
                         полутоном текущего цвета выделеня с белым
             23-11-2001  Nick Добавлен поиск по колонкам работает если у грида
                         не установлено dgEditing
--}

unit gsDBGrid;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, StdCtrls, ComCtrls, Menus, ActnList, DB, xCalc, Imglist,
  ExtCtrls, ContNrs,
  {$IFDEF GEDEMIN}
  gdcBase,
  {$ENDIF}
  IBCustomDataSet, gd_KeyAssoc;

resourcestring
  GraphicFieldString = 'Рисунок';

const
  DefStriped = True;
  DefStripeEven = $00D6E7E7;
  DefStripeOdd = $00E7F3F7;
  DefScaleColumns = False;
  DefShowTotals = True;
  DefShowFooter = False;
  DefTitlesExpanding = False;

  WM_CHANGEDISPLAYFORMTS = WM_USER + 21782;

///////////////////////////////////////////////////////
// Вид меню для класса TgsCustomDBGrid
// imkSubMenu - добавление меню группой
// imkWithSeparator - добавление меню через разделитель
// imkNone - меню для настройки грида выводиться не будет
//           кнопки на тулбаре так же не будут отображаться

type
  TInternalMenuKind = (imkSubMenu, imkWithSeparator, imkNone);

//////////////////////////////////////////////
// Вид условия для TCondition
// ckEqual - равно
// ckNotEqual - не равно
// ckIn - внутри
// ckOut - вне
// ckBigger - больше
// ckSmaller меньше
// ckBiggerEqual - больше или равно
// ckSmallerEqual - меньше или равно
// ckStarts - начинается с (только для текста)
// ckContains - содержит (только для текста)

type
  TConditionKind =
    (
    ckEqual, ckNotEqual, ckIn, ckOut, ckBigger, ckSmaller,
    ckBiggerEqual, ckSmallerEqual, ckStarts, ckContains, ckExist, ckNotExist, ckNone
    );

//////////////////////////////////////////
// Опции отображения для класса TCondition
// doColor - отображать цвет
// doFont - отображать шрифт

type
  TDisplayOption = (doColor, doFont);
  TDisplayOptions = set of TDisplayOption;

/////////////////////////////////////////////////////////////////////////////
// Состояние условия для класса TCondition
// csPrepared - условие подготовлено и меожет быть использовано
// csUnPrepared - условие необходимо подготовить
// csError - условие содержит ошибку и не может быть использовано
// csFormula - условие вычисляет формулу. Условие подготавливается каждый раз

type
  TConditionState = (csPrepared, csUnPrepared, csFormula, csError);

///////////////////////////////////////////////////////////
// Вид сравнения условия со значением поля класс TCondition
// cckNumeric - сравнение чисел
// cckDateTime - сравнение времени
// cckString - сравнение строк
// cckNone - сравнение не установлено

type
  TConditionCompareKind = (cckNumeric, cckDateTime, cckString, cckNone);

//////////////////////////////////////////////////////////////////
// Опции для расширенного отображения класс TColumnExpand
// ceoAddField - дополнительная колонка
// ceoAddFieldMultiline - дополнительная колонка в несколько строк
// ceoMultiline - основная колонка в несколько строк

type
  TColumnExpandOption = (ceoAddField, ceoAddFieldMultiline, ceoMultiline);
  TColumnExpandOptions = set of TColumnExpandOption;

type
  TCheckBoxEvent = procedure (Sender: TObject; CheckID: String;
    var Checked: Boolean) of object;
  TAfterCheckEvent =  procedure (Sender: TObject; CheckID: String;
    Checked: Boolean) of object;

type
  // обработчик события вызывается для получения текста итого по колонке
  // или текста, выводимого в подножии таблицы
  // если FieldName -- пустая строка, то -- подножие
  TOnGetFooter = procedure (Sender: TObject;
    const FieldName: String;
    const AggregatesObsolete: Boolean;
    var DisplayString: String) of Object;

  TgsCustomDBGrid = class;

  TGridHintWindow = class(THintWindow)
  private
    FTimer: TTimer;

    FRect: TRect;
    FHint: String;
    FData: Pointer;

    OldCP: TPoint;

    procedure DoOnTimer(Timer: TObject);

  protected
    procedure Paint; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure ActivateHint(Rect: TRect; const AHint: string); override;
    procedure ActivateHintData(Rect: TRect; const AHint: string;
      AData: Pointer); override;

    function CalcNeededRect(MaxWidth: Integer; const AHint: string;
      AData: Pointer): TRect; virtual;

    procedure ShowGridHint(Rect: TRect; const AHint: string; AData: Pointer);
    procedure HideGridHint;

  end;

  TGridConditions = class;

  TGridCheckBox = class(TPersistent)
  private
    FDisplayField: String; // Колонка, в которой отображать CheckBox
    FFieldName: String; // Поле данных с уникальным идентификатором
    FVisible: Boolean; // Видим ли CheckBox
    FCheckList: TStringList; // Список идентификаторов
    FOwner: TgsCustomDBGrid; // Владелец
    FGlyphChecked: TBitmap; // Рисунок с "галочкой"
    FGlyphUnChecked: TBitmap; // Рисунок без "галочки"
    FStoreGlyphChecked, FStoreGlyphUnChecked: Boolean; // Сохранять ли рисунки

    FCheckBoxEvent: TCheckBoxEvent; // Событие до добавлению элемента в список CheckBox-ов
    FAfterCheckEvent: TAfterCheckEvent;
    FFirstColumn: Boolean; // Событие после добавлению элемента в список CheckBox-ов

    function GetCheckCount: Integer;
    function GetStrCheck(AnIndex: Integer): String;
    function GetIntCheck(AnIndex: Integer): Integer;

    procedure SetDisplayField(const Value: String);
    procedure SetFieldName(const Value: String);
    procedure SetVisible(const Value: Boolean);
    procedure SetCheckList(const Value: TStringList);

    procedure SetGlyphChecked(const Value: TBitmap);
    procedure SetGlyphUnChecked(const Value: TBitmap);

    function GetRecordChecked: Boolean;
    procedure SetFirstColumn(const Value: Boolean);

  protected
    FInOnClickCheck: Boolean;

    function GetOwner: TPersistent; override;

    procedure DoOnChange(Sender: TObject);

  public
    constructor Create(AnOwner: TgsCustomDBGrid);
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function GetNamePath: string; override;

    procedure AddCheck(const Value: String); overload;
    procedure AddCheck(const Value: Integer); overload;

    procedure DeleteCheck(const Value: String); overload;
    procedure DeleteCheck(const Value: Integer); overload;

    procedure Clear;

    procedure BeginUpdate;
    procedure EndUpdate;

    // Таблица, которой принадлежит данный класс
    property Grid: TgsCustomDBGrid read FOwner;

    // Количество идентификаторов
    property CheckCount: Integer read GetCheckCount;
    // Идентификатор в виде строки по индексу
    property StrCheck[Index: Integer]: String read GetStrCheck;
    // Идентификатор в виде числа по индексу
    property IntCheck[Index: Integer]: Integer read GetIntCheck; default;
    // Отмечена ли запись (сохранен ли ее идентификатор)
    property RecordChecked: Boolean read GetRecordChecked;

  published
    // Поле, где выводится CheckBox
    property DisplayField: String read FDisplayField write SetDisplayField;
    // Поле, откуда береться уникальный идентификатор
    property FieldName: String read FFieldName write SetFieldName;
    // Видим ли CheckBox
    property Visible: Boolean read FVisible write SetVisible;
    // Список идентификаторов
    property CheckList: TStringList read FCheckList write SetCheckList;
    // Рисунок с "галочкой"
    property GlyphChecked: TBitmap read FGlyphChecked write SetGlyphChecked
      stored FStoreGlyphChecked;
    // Рисунок без "галочки"
    property GlyphUnChecked: TBitmap read FGlyphUnChecked write SetGlyphUnChecked
      stored FStoreGlyphUnChecked;
    // Событие по добавлению элемента в список CheckBox-ов
    property CheckBoxEvent: TCheckBoxEvent read FCheckBoxEvent write FCheckBoxEvent;
    property AfterCheckEvent: TAfterCheckEvent read FAfterCheckEvent write FAfterCheckEvent;

    property FirstColumn: Boolean read FFirstColumn write SetFirstColumn;
  end;

  ///////////////////////////////////////////////
  // Событие - проверка пользовательского условия
  // для класса TCondition

  TOnUserCondition = function
  (
    Sender: TObject;
    Field: TField
  ):
    Boolean
  of object;

  TCondition = class(TCollectionItem)
  private
    FConditionState: TConditionState; // Состояние условия

    FConditionName: String; // Наименование условия

    FDisplayFields: String; // Поля, в которых будут отображаться условия
    FFieldName: String; // Поле, на основе которого будет строиться условие

    FFont: TFont; // Шрифт условия
    FColor: TColor; // Цвет условия

    FExpression1: String; // Первое выражение
    FExpression2: String; // Второе выражение

    FConditionKind: TConditionKind; // Вид условия
    FDisplayOptions: TDisplayOptions; // Опции отображения

    FEvaluateFormula: Boolean; // Рассчитывать формулы

    FUserCondition: Boolean; // Использовать пользовательское условие
    FOnUserCondition: TOnUserCondition; // Событие на проверку пользовательского условия

    // Методы реализации свойств

    function GetGrid: TgsCustomDBGrid;
    function GetDataLink: TGridDataLink;
    function GetField: TField;

    procedure SetConditionName(const Value: String);

    procedure SetDisplayFields(const Value: String);
    procedure SetFieldName(const Value: String);

    procedure SetFont(const Value: TFont);
    procedure SetColor(const Value: TColor);

    procedure SetExpression1(const Value: String);
    procedure SetExpression2(const Value: String);

    procedure SetConditionKind(const Value: TConditionKind);
    procedure SetDisplayOptions(const Value: TDisplayOptions);

    procedure SetEvaluateFormula(const Value: Boolean);

    procedure SetUserCondition(const Value: Boolean);
    procedure SetOnUserCondition(const Value: TOnUserCondition);

    function GetIsValid: Boolean;
    function DoOnVariable(const VariableName: String; var V: Double): Boolean;

  protected
    FCompareValue1, FCompareValue2: Extended; // Значения для сравнения (числовые)
    FCompareDate1, FCompareDate2: TDateTime; // Значения дл сравнения (дата/время)
    FConditionCompareKind1, FConditionCompareKind2: TConditionCompareKind; // Вид сравнения данных

    FFoCal: TxFoCal; // Класс расчета математичсеких выражений

    function GetDisplayName: string; override;

    procedure Prepare;
    procedure CheckAndApply;

    // Соединение с источником данных
    property DataLink: TGridDataLink read GetDataLink;
    // Возвращает поле данных для услоавия
    property Field: TField read GetField;
    // Вид сравнения данных
    property ConditionCompareKind1: TConditionCompareKind read FConditionCompareKind1;
    // Вид сравнения данных
    property ConditionCompareKind2: TConditionCompareKind read FConditionCompareKind2;

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function Suits(const DisplayField: TField): Boolean;

    // Таблица, которой принадлежит данная коллекция
    property Grid: TgsCustomDBGrid read GetGrid;
    // Состояние условия
    property ConditionState: TConditionState read FConditionState;
    // Чисто ли условие, или есть название
    property IsValid: Boolean read GetIsValid;

  published
    // Название условия
    property ConditionName: String read FConditionName write SetConditionName;

    // Поля, в которых будут отображаться условия
    property DisplayFields: String read FDisplayFields write SetDisplayFields;
    // Поле, на основе которого будет строиться условие
    property FieldName: String read FFieldName write SetFieldName;

    // Шрифт условия
    property Font: TFont read FFont write SetFont;
    // Цвет условия
    property Color: TColor read FColor write SetColor;

    // Первое выражение
    property Expression1: String read FExpression1 write SetExpression1;
    // Второе выражение
    property Expression2: String read FExpression2 write SetExpression2;

    // Вид условия
    property ConditionKind: TConditionKind read FConditionKind write SetConditionKind;
    // Опции отображения
    property DisplayOptions: TDisplayOptions read FDisplayOptions write SetDisplayOptions;
    // расчитывать формулы
    property EvaluateFormula: Boolean read FEvaluateFormula write SetEvaluateFormula;

    // Использовать пользовательское условие
    property UserCondition: Boolean read FUserCondition write SetUserCondition;
    // Событие на проверку пользовательского условия
    property OnUserCondition: TOnUserCondition read FOnUserCondition write SetOnUserCondition;

  end;

  TGridConditions = class(TCollection)
  private
    FGrid: TgsCustomDBGrid; // Таблица, которой принадлежит данный список

    function GetCondition(Index: Integer): TCondition;
    procedure SetCondition(Index: Integer; const Value: TCondition);

  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create(Grid: TgsCustomDBGrid);
    destructor Destroy; override;

    function  Add: TCondition;

    // Таблица, которой принадлежит коллекция
    property Grid: TgsCustomDBGrid read FGrid;
    // Элемент коллекции по индексу
    property Items[Index: Integer]: TCondition read GetCondition write SetCondition; default;
  end;


  TColumnExpands = class;

  TColumnExpand = class(TCollectionItem)
  private
    FDisplayField: String; // Отображать в поле
    FFieldName: String; // Брать данные из поля
    FLineCount: Integer; // Кол-во строчек для расширенного отображения
    FOptions: TColumnExpandOptions; // Опции расширенного отображения

    procedure SetDisplayField(const Value: String);
    procedure SetFieldName(const Value: String);
    procedure SetLineCount(const Value: Integer);

    function GetGrid: TgsCustomDBGrid;

    procedure SetOptions(const Value: TColumnExpandOptions);

  protected
    function GetDisplayName: string; override;

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function IsExpandValid(ADataLink: TGridDataLink): Boolean;

    // Таблица, которой принадлежит данная коллекция
    property Grid: TgsCustomDBGrid read GetGrid;

  published
    // Отображать в поле
    property DisplayField: String read FDisplayField write SetDisplayField;
    // Брать данные из поля
    property FieldName: String read FFieldName write SetFieldName;
    // Кол-во строчек для расширенного отображения
    property LineCount: Integer read FLineCount write SetLineCount;
    // Опции расширенного отображения
    property Options: TColumnExpandOptions read FOptions write SetOptions;

  end;

  TColumnExpands = class(TCollection)
  private
    FGrid: TgsCustomDBGrid; // Таблица, которой принадлежит данный список

    function GetExpand(Index: Integer): TColumnExpand;
    procedure SetExpand(Index: Integer; const Value: TColumnExpand);

  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create(Grid: TgsCustomDBGrid);
    destructor Destroy; override;

    function  Add: TColumnExpand;

    // Таблица, которой принадлежит коллекция
    property Grid: TgsCustomDBGrid read FGrid;
    // Элемент коллекции по индексу
    property Items[Index: Integer]: TColumnExpand read GetExpand write SetExpand; default;

  end;


  TgsColumn = class;
  TgsColumns = class;


  TgsColumnTitle = class(TColumnTitle)
  private
    function GetColumn: TgsColumn;

  protected
    function IsAlignmentStored: Boolean; virtual;
    function IsCaptionStored: Boolean; virtual;
    function IsColorStored: Boolean; virtual;
    function IsFontStored: Boolean; virtual;

//    procedure SetCaption(const Value: string); override;

  public
    constructor Create(Column: TgsColumn);
    destructor Destroy; override;

    procedure RestoreDefaults; override;

    property Column: TgsColumn read GetColumn;

  published
    property Alignment stored IsAlignmentStored;
    property Caption stored IsCaptionStored;
    property Color stored IsColorStored;
    property Font stored IsFontStored;

  end;

  TgsTotalType = (ttNone, ttSum);

  TgsColumnClass = class of TgsColumn;
  TgsColumn = class(TColumn)
  private
    FDisplayFormat: String;

    // адносіцца да фільтру
    FMax: Integer;
    FFilteredValue: String;
    FFilteredCache: TStringList;
    FFiltered: Boolean;

    FTotalType: TgsTotalType;
    FFrozen: Boolean;

    function GetGrid: TgsCustomDBGrid;

    procedure SetDisplayFormat(const Value: String);
    function IsTotalTypeStored: Boolean;
    procedure SetTotalType(const Value: TgsTotalType);
    function GetDisplayFormat: String;
    procedure SetFrozen(const Value: Boolean);

  protected
    function  CreateTitle: TColumnTitle; override;

    function IsAlignmentStored: Boolean; virtual;
    function IsColorStored: Boolean; virtual;
    function IsFontStored: Boolean; virtual;
    function IsWidthStored: Boolean; virtual;
    function IsVisibleStored: Boolean; virtual;
    function IsDisplayFormatStored: Boolean; virtual;

  public
    WasFrozen: Boolean;

    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure RestoreDefaults; override;

    function Filterable: Boolean;
    class function IsFilterableField(F: TField): Boolean;

    procedure SetFieldFormat;

    property Grid: TgsCustomDBGrid read GetGrid;

    // адносіцца да фільтру
    // максимальная длина значения по колонке в символах
    property Max: Integer read FMax write FMax;
    property FilteredValue: String read FFilteredValue write FFilteredValue;
    property FilteredCache: TStringList read FFilteredCache write FFilteredCache;
    property Filtered: Boolean read FFiltered write FFiltered;

  published
    property Alignment stored IsAlignmentStored;
    property Color stored IsColorStored;
    property Font stored IsFontStored;
    property Width stored IsWidthStored;
    property Visible stored IsVisibleStored;
    property DisplayFormat: String read GetDisplayFormat write SetDisplayFormat
      stored IsDisplayFormatStored;
    property TotalType: TgsTotalType read FTotalType write SetTotalType
      stored IsTotalTypeStored;
    property Frozen: Boolean read FFrozen write SetFrozen
      default False;
  end;


  TgsColumns = class(TDBGridColumns)
  private
    FIsSetupMode: Boolean;

    function GetColumn(Index: Integer): TgsColumn;
    procedure SetColumn(Index: Integer; Value: TgsColumn);

    function GetGrid: TgsCustomDBGrid;

  protected
    procedure Update(Item: TCollectionItem); override;

  public
    constructor Create(Grid: TCustomDBGrid; ColumnClass: TgsColumnClass; IsSetupMode: Boolean);
    function Add: TgsColumn;

    property IsSetupMode: Boolean read FIsSetupMode;
    property State;
    property Grid: TgsCustomDBGrid read GetGrid;
    property Items[Index: Integer]: TgsColumn read GetColumn write SetColumn; default;

  end;

  TCustomDBGridCracker = class(TCustomDBGrid);
  TWinControlCracker = class(TWinControl);

  // типы агрегатных значений: сумма, среднее, минимальное, максимальное,
  // количество выделенных значений, количество числовых значений в
  // выделенных значениях
  {TgsAggregateType = (atSum, atAvg, atMin, atMax, atCount, atNumCount, atNone);

  TgsAggregate = class(TObject)
  private
    FGrid: TgsCustomDBGrid;
    FRows: TStringList;
    FSum, FAvg, FMin, FMax: Double;
    FCount, FNumCount: Integer;
    FCol: Integer;
    FOnChanged: TNotifyEvent;
    FCache: TBookmarkStr;
    FCacheIndex: Integer;
    FCacheFind: Boolean;
    FAggregateType: TgsAggregateType;
    pm: TPopupMenu;
    FInitialRow: TBookmarkStr;
    FMessageShowed: Boolean;
    procedure StringsChanged(Sender: TObject);
    function GetRowsCount: Integer;
    procedure MenuClicked2(Sender: TObject);
    procedure SetAggregateType(const Value: TgsAggregateType);
    function GetAggregateText: String;

  protected
    procedure Clear(const AUserInteraction: Boolean = True);
    procedure Add(AField: TField; const AUserInteraction: Boolean = True);
    procedure Delete(AField: TField; const AUserInteraction: Boolean = True);
    procedure Switch(AField: TField);
    procedure Switch2(AField: TField);
    procedure SelectCol(AField: TField);
    function Compare(const Item1, Item2: TBookmarkStr): Integer;
    procedure AddToAggregates(AField: TField);
    procedure DeleteFromAggregates(AField: TField);
    procedure DoOnChanged;

    property InitialRow: TBookmarkStr read FInitialRow;

  public
    constructor Create(AGrid: TgsCustomDBGrid);
    destructor Destroy; override;

    function Find(const Item: TBookmarkStr; var Index: Integer): Boolean;
    function IndexOf(const Item: TBookmarkStr): Integer;

    // выводит на экран всплывающее меню для выбора агрегатного значения
    // меню выводится в текущих координатах мыши
    procedure PopupMenu(const X: Integer = -1; const Y: Integer = -1);

    property Sum: Double read FSum;
    property Avg: Double read FAvg;
    property Min: Double read FMin;
    property Max: Double read FMax;
    property Count: Integer read FCount;
    property NumCount: Integer read FNumCount;

    property Col: Integer read FCol write FCol;
    property RowsCount: Integer read GetRowsCount;

    // свойство используется для установки
    property AggregateType: TgsAggregateType read FAggregateType write SetAggregateType;
    property AggregateText: String read GetAggregateText;

    // вызывается при включении/исключении записей в агрегатную выборку
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;}
  ///^^^
  TgsDataLink = class(TDataLink)
  protected
    procedure DataSetChanged; override;
    procedure DataEvent(Event: TDataEvent; Info: Longint); override;

  public
    constructor Create;
    destructor Destroy; override;
  end;


  TStripeKind = (skOdd, skEven, skNone);
  TRefreshType = (rtRefresh, rtCloseOpen, rtNone);

  TgsDBGridClass = class of TgsCustomDBGrid;

  TgsCustomDBGrid = class(TCustomDBGrid)
  private
    FInternalMenuKind: TInternalMenuKind; // Вид внутреннего меню
    FActionList: TActionList;             // Список команд меню для таблицы
    FImages: TImageList;                  // Список рисунков для списка действий
    // Указатели на действия
    FMasterAct, FRefreshAct, FFindAct, FFindNextAct, FPanelAct,
    FHideColAct, FGroupAct, FInputCaptionAct, FFrozeColumnAct, FCancelAutoFilterAct,
    FFirst, FLast, FNext, FPrior, FPageUp, FPageDown,
    {$IFDEF NEW_GRID}
    FUnGroupAct,
    FGroupWrapAct, FGroupUnWrapAct,
    FGroupOneWrapAct, FGroupOneUnWrapAct,
    FGroupNextAct, FGroupPriorAct,
    FCopyToClipboardAct : TAction;
    {$ELSE}
    FCopyToClipboardAct: TAction;
    {$ENDIF}


    FSelectedFont: TFont;                 // Шрифт выделенного текста
    FSelectedColor: TColor;               // Цвет выдлеленного текста

    FStriped: Boolean;                    // Режим полосатой таблицы
    FStripeOdd: TColor;                   // Первая полоса
    FStripeEven: TColor;                  // Вторая полоса

    FMyOdd, FMyEven: TStripeKind;         // Текущие значения полос

    FExpands: TColumnExpands;             // Настройки расширенного отображения.
    FExpandsActive: Boolean;              // Используется ли расширенное отображение
    FExpandsSeparate: Boolean;            // Использовать резделитель элементов расширенного отображения
    FTitlesExpanding: Boolean;            // Использовать ли расширенное отображение залоговков

    FConditions: TGridConditions;         // Коллекция условий
    FConditionsActive: Boolean;           // Используются ли уловия

    FCheckBox: TGridCheckBox;             // Класс работы со списком CheckBox-ов

    FScaleColumns: Boolean;               // Режим растягивания колонок
    FCanScale: Boolean;                   // Можно ли расятгивать колонки
    FBlockSettings: Boolean;              // Блокировка внутренних установок

    FSizedIndex: Integer;                 // Индекс колонки, размер которой изменялся
    FSizedOldWidth: Integer;              // Старный размер колонки, которую меняли
    FLastRemain: Integer;                 // Индекс колонки, которой в последний раз добавляли больше

    FRestriction: Boolean;                // Запрет на редактирование
    FBlockFieldSetting: Boolean;          // Блокировка внутренних установок полей

    FMinColWidth: Integer;                // Минимальный размер колонки

    FFormName: String;                    // Храним название формы

    FToolBar: TToolBar;                   // Панель инструментов для данной таблицы

    FFinishDrawing: Boolean;              // Заканчивать ли рисование до края таблицы вертикально
    FRefreshType: TRefreshType;           // Тип обновления данных

    FRememberPosition: Boolean;           // Запоминать ли позицию

    FSaveSettings: Boolean;               // Запоминать ли настройки
    FSearchFlag: Boolean;                 // Флаг осуществления поиска
    FCloseDialog: Boolean;

    //FAggregate: TgsAggregate;

    FOldX, FOldY: Integer;
    FHalfSelectedTone: TColor;          // Свет выделения агрегатов равный
                                        // полутону белого и текущего цвета выделения
    FSearchKey: String;                 // Ключ поиска по полю
    FPressProcessing: Boolean;          // Происходит ввод символов поиска
    FReStartProcessing: Boolean;        // Флаг перехода к начальной задержке
    FSearchLength: Integer;             // Размер последней строки поиска
                                        // чтобы не искать каждый раз с начала
    FRecNum: Integer;
    FSettingsModified: Boolean;

    //
    FFilterableColumns: TList;
    FFilteredColumns: TList;
    FFilteringColumn: TgsColumn;
    lv: TListBox;
    FShowTotals: Boolean;
    FShowFooter: Boolean;
    FOnGetFooter: TOnGetFooter;
    FFilteredDataSet: TDataSet;
    Column: TColumn;
    FNeedScaleColumns: Boolean;

    //
    FOddKeys, FEvenKeys: TgdKeyArray;
    FGroupFieldName: String;

    FSettingsLoaded: Boolean;
    FOnGetTotal: TOnGetFooter;

    //
    FInInputQuery: Boolean;

    //
    FOldOnFilterRecord: TFilterRecordEvent;
    FOldFiltered: Boolean;

    //
    Items: TList;
    P: TPopupMenu;

    FAllowDrawTotals: Boolean;
    FInDrawTotals: Boolean;

    FTempKey: Word;
    //^^^
    //_FDataLink: TgsDataLink;

    //
    //FInternalCanShowEditor: Boolean;
    //FInternalSetFocus: Boolean;

    // Методы обработки свойств компонента

    function GetTableFont: TFont;
    procedure SetTableFont(const Value: TFont);

    function GetTableColor: TColor;
    procedure SetTableColor(const Value: TColor);

    function GetSelectedFont: TFont;
    procedure SetSelectedFont(const Value: TFont);

    function GetSelectedColor: TColor;
    procedure SetSelectedColor(const Value: TColor);

    function GetTitleFont: TFont;
    procedure SetTitleFont(const Value: TFont);

    function GetTitleColor: TColor;
    procedure SetTitleColor(const Value: TColor);

    procedure SetDataSource(Value: TDataSource);

    procedure SetStriped(const Value: Boolean);
    procedure SetStripeOdd(const Value: TColor);
    procedure SetStripeEven(const Value: TColor);

    function GetLineCount: Integer;
    function GetCaptionLineCount: Integer;
    function GetVisibleColumnCount: Integer;

    procedure SetColumnExpands(const Value: TColumnExpands);
    procedure SetExpandsActive(const Value: Boolean);
    procedure SetExpandsSeparate(const Value: Boolean);
    procedure SetTitlesExpanding(const Value: Boolean);

    procedure SetConditions(const Value: TGridConditions);
    procedure SetConditionsActive(const Value: Boolean);

    procedure SetCheckBox(const Value: TGridCheckBox);
    procedure SetScaleColumns(const Value: Boolean);
    procedure SetMinColWidth(const Value: Integer);

    procedure SetToolBar(const Value: TToolBar);
    procedure SetFinishDrawing(const Value: Boolean);

    // Внутренние методы компонента

    procedure CreateActionList;
    procedure FullFillMenu(PopupColumn: TColumn; APopupMenu: TPopupMenu; Items: TList;
      const ColumnTitle: Boolean);

    //procedure SetupActions(AToolBar: TToolBar);
    //procedure RemoveActions(AToolBar: TToolBar);

    procedure DoShowMaster(Sender: TObject);
    {$IFDEF GEDEMIN}
    procedure DoApplyMaster(Sender: TObject);
    {$ENDIF}

    procedure DoOnFindExecute(Sender: TObject);
    procedure DoOnFindNextExecute(Sender: TObject);
    procedure DoOnCopyToClipboardExecute(Sender: TObject);

    procedure DoOnRefresh(Sender: TObject);
    procedure DoOnPanel(Sender: TObject);

    procedure DoOnPrior(Sender: TObject);
    procedure DoOnNext(Sender: TObject);

    procedure DoOnFirst(Sender: TObject);
    procedure DoOnLast(Sender: TObject);

    procedure DoOnPageUp(Sender: TObject);
    procedure DoOnPageDown(Sender: TObject);

    procedure DoOnHideColumn(Sender: TObject);
    {$IFDEF NEW_GRID}
    procedure DoOnGroup(Sender: TObject);
    procedure DoOnUnGroup(Sender: TObject);
    procedure DoOnGroupWrap(Sender: TObject);
    procedure DoOnGroupUnWrap(Sender: TObject);
    procedure DoOnGroupOneWrap(Sender: TObject);
    procedure DoOnGroupOneUnWrap(Sender: TObject);
    procedure DoOnGroupNext(Sender: TObject);
    procedure DoOnGroupPrior(Sender: TObject);

    procedure _OnPseudoRecordsOn(DataSet: TDataSet; var Accept: Boolean);
    {$ENDIF}
    procedure DoOnInputCaption(Sender: TObject);
    procedure DoOnFrozeColumn(Sender: TObject);
    procedure DoOnFrozeColumnUpdate(Sender: TObject);
    procedure DoOnCancelAutoFilter(Sender: TObject);

    procedure CountStripes(Distance: Integer);

    procedure GetExpandsList(Field: TField; List: TList);
    function FindMainExpand(List: TList): TColumnExpand;
    function GetDefaultRowHeight: Integer;
    function GetDefaultTitleRowHeight: Integer;

    procedure CMParentFontChanged(var Message: TMessage);
      message CM_PARENTFONTCHANGED;
    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd);
      message WM_ERASEBKGND;
    procedure WMChangeDisplayFormats(var Message: TWmEraseBkgnd);
      message WM_CHANGEDISPLAYFORMTS;
    procedure WMContextMenu(var Message: TWMContextMenu);
      message WM_CONTEXTMENU;
{    procedure WMSetFocus(var Message: TMessage);
      message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TMessage);
      message WM_KillFOCUS;}

    {$IFDEF GEDEMIN}
    procedure WMHScroll(var Msg: TWMHScroll); message WM_HSCROLL;
    {$ENDIF}

    procedure DoOnFontChanged(Sender: TObject);
    procedure _CountScaleColumns;
    procedure CountScaleColumns;

    function NotParentFont: Boolean;
    {function GetOnAggregateChanged: TNotifyEvent;
    procedure SetOnAggregateChanged(const Value: TNotifyEvent);}

    // создаваемые внутри грида действия должны быть недоступны
    // если не подключен датасет или он не открыт
    procedure OnActionUpdate(Sender: TObject);

    procedure SetCheckBoxEvent(Value: TCheckBoxEvent);
    function GetCheckBoxEvent: TCheckBoxEvent;
    function GetAfterCheckEvent: TAfterCheckEvent;
    procedure SetAfterCheckEvent(Value: TAfterCheckEvent);

    // процедуры для осуществления поиска по датасету
    procedure Find;
    procedure ProcessDelay;
    {$IFDEF GEDEMIN}
    function GetGDObject: TgdcBase;
    {$ENDIF}

    procedure _OnExit(Sender: TObject);
    procedure _OnClick(Sender: TObject);
    procedure _OnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure _OnFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure SetShowTotals(const Value: Boolean);
    procedure SetShowFooter(const Value: Boolean);
    procedure SetGroupFieldName(const Value: String);

  protected
    FFindValue: String;
    FFindColumn: TColumn;

    FDeferedLoading: Boolean;                   // Отложенная загрузка
    FDeferedStream: TMemoryStream;              // Поток с отолженными настройками
    FDontLoadSettings: Boolean;
    FDataSetOpenCounter, FFilterDataSetOpenCounter: Integer;

    {$IFDEF GEDEMIN}
    procedure ClampInView(const Coord: TGridCoord); override;
    procedure UpdateScrollPos; override;
    procedure UpdateScrollRange; override;
    {$ENDIF}

    procedure Loaded; override;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure DrawTotals(const ForceDraw: Boolean = True);
    procedure TopLeftChanged; override;

    function GetFirstVisible(AddIndicator: Boolean = True): Integer;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;

    procedure LinkActive(Active: Boolean); override;
    procedure Scroll(Distance: Integer); override;
    procedure LayoutChanged; override;

    procedure ColumnMoved(FromIndex, ToIndex: Longint); override;

    procedure RowHeightsChanged; override;
    procedure ColWidthsChanged; override;
//    function CanEditShow: Boolean; override;

    procedure CalcSizingState(X, Y: Integer; var State: TGridState;
      var Index: Longint; var SizingPos, SizingOfs: Integer;
      var FixedInfo: TGridDrawInfo); override;

    function GetClientRect: TRect; override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure gsKeyDown(var Key: Word; Shift: TShiftState);
    procedure KeyPress(var Key: Char); override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;

    procedure UpdateRowCount;

    function GetFieldCaption(AField: TField): String;
    function GetFullCaption(AColumn: TColumn): String;
    function CountFullCaptionWidth(AColumn: TColumn): Integer;
    function ExpandExists(AColumn: TColumn): Boolean;

    procedure GetCaptionFields(AColumn: TColumn; Fields: TList);
    procedure GetColumnFields(AColumn: TColumn; Fields: TList);

    procedure SetParent(AParent: TWinControl); override;
    procedure SetColumnAttributes; override;

    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;

    function CreateColumns: TDBGridColumns; override;

    procedure DoExit; override;

    procedure WMPAINT(var Message: TMessage);
      message WM_PAINT;

    function  HighlightCell(DataCol, DataRow: Integer; const Value: string;
      AState: TGridDrawState): Boolean; override;
    //function AggregateCell(DataCol, DataRow: Integer): boolean;
    class function GridClassType: TgsDBGridClass; virtual;
    class function GetColumnClass: TgsColumnClass; virtual;

    procedure TitleClick(Column: TColumn); override;

    procedure GetValueFromValueList(AColumn: TColumn; var AValue: String); virtual;
    //
    // Вычисляет кол-во линий
    property LineCount: Integer read GetLineCount;
    // Вычисляет кол-во линий зглавий
    property CaptionLineCount: Integer read GetCaptionLineCount;
    // Возвращает кол-во видимых колонок
    property VisibleColumnCount: Integer read GetVisibleColumnCount;

    // Шрифт таблицы
    property TableFont: TFont read GetTableFont write SetTableFont
      stored NotParentFont;
    // Цвет таблицы
    property TableColor: TColor read GetTableColor write SetTableColor
      default clWindow;

    // Шрифт выделенного текста
    property SelectedFont: TFont read GetSelectedFont write SetSelectedFont
      stored NotParentFont;
    // Цвет выделенного текста
    property SelectedColor: TColor read GetSelectedColor write SetSelectedColor
      default clHighlight;

    // Шрифт заглавий
    property TitleFont read GetTitleFont write SetTitleFont
      stored NotParentFont;
    // Цвет заглавий
    property TitleColor: TColor read GetTitleColor write SetTitleColor
      default clBtnFace;

    // Режим полосатой таблицы
    property Striped: Boolean read FStriped write SetStriped default DefStriped;
    // Первая полоса
    property StripeOdd: TColor read FStripeOdd write SetStripeOdd default DefStripeOdd;
    // Вторая полоса
    property StripeEven: TColor read FStripeEven write SetStripeEven default DefStripeEven;

    // Вид внутреннего меню
    property InternalMenuKind: TInternalMenuKind read FInternalMenuKind write FInternalMenuKind;

    // Настройки для расширенного отображения
    property Expands: TColumnExpands read FExpands write SetColumnExpands;
    // Использовать расширенное отображение или нет
    property ExpandsActive: Boolean read FExpandsActive write SetExpandsActive;
    // Использовать резделитель элементов расширенного отображения
    property ExpandsSeparate: Boolean read FExpandsSeparate write SetExpandsSeparate;
    // Сложное рисование заглавий
    property TitlesExpanding: Boolean read FTitlesExpanding write SetTitlesExpanding;

    // Класс работы со списком CheckBox-ов
    property CheckBox: TGridCheckBox read FCheckBox write SetCheckBox;

    // Режим растягивания колонок
    property ScaleColumns: Boolean read FScaleColumns write SetScaleColumns
      default DefScaleColumns;
    // Минимальный размер колонки
    property MinColWidth: Integer read FMinColWidth write SetMinColWidth;
    // Панель инструментов для данной таблицы
    property ToolBar: TToolBar read FToolBar write SetToolBar;

    // Родитель таблицы
    property Parent write SetParent;

    // Заканчивать ли рисование до края таблицы вертикально
    property FinishDrawing: Boolean read FFinishDrawing write SetFinishDrawing
      default True;
    // Тип обновления данных
    property RefreshType: TRefreshType read FRefreshType write FRefreshType
      default rtCloseOpen;
    // Необходимо ли позиционировать после фильтра
    property RememberPosition: Boolean read FRememberPosition write FRememberPosition
      default True;
    // Источник данных
    property DataSource write SetDataSource;
    // Сохранять ли настройки во время работы
    property SaveSettings: Boolean read FSaveSettings write FSaveSettings;
    property OnClickCheck: TCheckBoxEvent read GetCheckBoxEvent write SetCheckBoxEvent;
    property OnClickedCheck: TAfterCheckEvent read GetAfterCheckEvent write SetAfterCheckEvent;

    property Options default [dgEditing, dgTitles, dgIndicator, dgColumnResize,
      dgColLines, {dgRowLines,} dgTabs, dgConfirmDelete, dgCancelOnExit];

    //
    property ShowTotals: Boolean read FShowTotals write SetShowTotals
      default DefShowTotals;
    property ShowFooter: Boolean read FShowFooter write SetShowFooter
      default DefShowFooter;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure AfterConstruction; override;

    procedure PrepareMaster(AMaster: TForm); virtual;
    procedure SetupGrid(AMaster: TForm; const UpdateGrid: Boolean = True); virtual;

    procedure DefaultHandler(var Msg); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    procedure DisableActions;

    procedure Read(Reader: TReader); virtual;
    procedure Write(Writer: TWriter); virtual;
    procedure AddCheck;

//    procedure LoadFromStream(Stream: TStream);
//    procedure SaveToStream(Stream: TStream);

    function GridCoordFromMouse: TGridCoord;
    function ColumnByField(Field: TField): TColumn;

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

    procedure ValidateColumns; virtual;

    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure ResizeColumns;

    procedure FindInGrid;

    // Наименование формы
    property FormName: String read FFormName;

    //
    {property Aggregate: TgsAggregate read FAggregate;
    property OnAggregateChanged: TNotifyEvent read GetOnAggregateChanged write SetOnAggregateChanged;}

    //
    {$IFDEF GEDEMIN}
    property GDObject: TgdcBase read GetGDObject;
    {$ENDIF}

    //
    property GroupFieldName: String read FGroupFieldName write SetGroupFieldName;

    //
    property SettingsModified: Boolean read FSettingsModified write FSettingsModified;
    property DontLoadSettings: Boolean read FDontLoadSettings write FDontLoadSettings;

    property Columns;

    //
    property OnGetFooter: TOnGetFooter read FOnGetFooter write FOnGetFooter;
    property OnGetTotal: TOnGetFooter read FOnGetTotal write FOnGetTotal;

    // Коллекция условий
    property Conditions: TGridConditions read FConditions write SetConditions;
    // Используются ли уловия
    property ConditionsActive: Boolean read FConditionsActive write SetConditionsActive;

    //
    { TODO :
для поддержки этого свойства придется много чего
переписать в гриде. может его убрать? }
    property FixedCols;
  end;

type
  TgsDBGrid = class(TgsCustomDBGrid)
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
    property RefreshType;
    property ScrollBars stored False;
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

    property Striped;
    property StripeOdd;
    property StripeEven;

    property InternalMenuKind;

    property Expands;
    property ExpandsActive;
    property ExpandsSeparate;
    property TitlesExpanding default DefTitlesExpanding;

    property Conditions;
    property ConditionsActive;

    property CheckBox;

    property ScaleColumns;
    property MinColWidth;
    property ToolBar;

    property FinishDrawing;

    property RememberPosition;

    property SaveSettings default True;

    property ShowTotals;
    property ShowFooter;
    //property OnAggregateChanged;
    property OnClickCheck;
    property OnClickedCheck;
    property OnGetFooter;
    property OnGetTotal;
  end;

type
  EgsDBGridException = class(Exception);

procedure Register;

function FontsEqual(Font1, Font2: TFont): Boolean;

const
  GridStripeProh: Boolean = False;

implementation

{$R GSDBGRID.RES}

uses
  Math, ClipBrd, DsgnIntf, TypInfo, gsdbGrid_dlgFilter, jclStrings
  {$IFDEF GEDEMIN}
  , Storages, gd_security, gsDBGrid_dlgMaster, gsdbGrid_dlgFind_unit, ComObj
    {$IFDEF NEW_GRID}
    , IBCustomDataSet_dlgSortGroupProp_unit
    {$ENDIF}
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub, gd_localization
  {$ENDIF}
  //, udemo1 //&&&
  ;

{$IFDEF GEDEMIN}
var
  RegExp: Variant;
{$ENDIF}

type
  TGridDataLinkCrack = class(TGridDataLink);

  TgsListBox = class(TListBox)
  protected
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
  end;

const
  MENU_MASTER = 'Мастер установок...';
  MENU_REFRESH = 'Обновить данные';
  MENU_FIND = 'Найти...';
  MENU_FINDNEXT = 'Найти следующее';
  MENU_PANEL = 'Панель инструментов';
  MENU_HIDECOL = 'Скрыть колонку';

  MENU_GROUP = 'Группировать';
  MENU_UNGROUP = 'Снять группировки';
  MENU_GROUPWRAP =      'Свернуть все группы';
  MENU_GROUPUNWRAP =    'Развернуть все группы                  Ctrl+*';
  MENU_GROUPONEWRAP =   'Свернуть группу';
  MENU_GROUPONEUNWRAP = 'Развернуть группу                         Ctrl++';

  MENU_GROUPNEXT = 'Следующая группа';
  MENU_GROUPPRIOR = 'Предыдущая группа';

  MENU_INPUTCAPTION = 'Заголовок колонки...';
  MENU_FROZECAPTION = 'Закрепить колонку';
  MENU_CANCELAUTOFILTERCAPTION = 'Отмена автофильтрации';
  MENU_COPYTOCLIPBOARD = 'Скопировать ячейки в буфер';

  MENU_FIRST = 'Первый';
  MENU_LAST = 'Последний';
  MENU_PRIOR = 'Предыдущий';
  MENU_NEXT = 'Следующий';
  MENU_PAGEUP = 'Страница вверх';
  MENU_PAGEDOWN = 'Страница вниз';

  GRID_STREAM_VERSION_2 = 'GRID_STREAM_2';
  GRID_STREAM_VERSION_3 = 'GRID_STREAM_3';
  GRID_STREAM_VERSION_4 = 'GRID_STREAM_4';

  MAXDOUBLE =  1e300;
  MINDOUBLE = -1e300;

{ Private. LongMulDiv multiplys the first two arguments and then
  divides by the third.  This is used so that real number
  (floating point) arithmetic is not necessary.  This routine saves
  the possible 64-bit value in a temp before doing the divide.  Does
  not do error checking like divide by zero.  Also assumes that the
  result is in the 32-bit range (Actually 31-bit, since this algorithm
  is for unsigned). }

function LongMulDiv(Mult1, Mult2, Div1: Longint): Longint; stdcall;
  external 'kernel32.dll' name 'MulDiv';

function HalfTone(Const A, B:TColor): TColor;
var
  C, D: Integer;
begin

  C := (A and $FF0000) shr 16;
  D := (B and $FF0000) shr 16;

  Result := ((C + D) shr 1) shl 16;

  C := (A and $FF00) shr 8;
  D := (B and $FF00) shr 8;

  Result := Result or (((C + D) shr 1) shl 8);

  C := (A and $FF);
  D := (B and $FF);

  Result := Result or ((C + D) shr 1);
end;

function FontsEqual(Font1, Font2: TFont): Boolean;
begin
  Result :=
    (Font1.Charset = Font2.Charset) and
    (Font1.Color = Font2.Color) and
    (Font1.Height = Font2.Height) and
    (Font1.Name = Font2.Name) and
    (Font1.Pitch = Font2.Pitch) and
    (Font1.Size = Font2.Size) and
    (Font1.Style = Font2.Style);
end;

function AnsiUpperPos(S1, S2: String): Integer;
begin
  Result := AnsiPos(AnsiUpperCase(S1), AnsiUpperCase(S2));
end;

function AdjustColor(const Cl: TColor; Delta: Integer): TColor;

  function _f(const I: Integer): Integer;
  begin
    if I < 0 then Result := 0
    else if I > 255 then Result := 255
    else Result := I;
  end;

var
  vRGB: Longint;
  R, G, B: Integer;
begin
  vRGB := ColorToRGB(Cl);
  R := GetRValue(vRGB);
  G := GetGValue(vRGB);
  B := GetBValue(vRGB);
  if (R + G + B) div 3 < 150 then
    Delta := - Delta;
  R := _f(R + Delta);
  G := _f(G + Delta);
  B := _f(B + Delta);
  Result := RGB(R, G, B);
end;

function MixColors(const Cl1, Cl2: TColor): TColor;
var
  vRGB1, vRGB2: Longint;
begin
  vRGB1 := ColorToRGB(Cl1);
  vRGB2 := ColorToRGB(Cl2);
  Result := RGB(
    (GetRValue(vRGB1) + GetRValue(vRGB2)) div 2,
    (GetGValue(vRGB1) + GetGValue(vRGB2)) div 2,
    (GetBValue(vRGB1) + GetBValue(vRGB2)) div 2
  );
end;

{ TGridCheckBox }

{
  Производит загрузку стандартных рисунокв CheckBox
}

const
 CHECK_WIDTH = 13;
 CHECK_HEIGHT = 13;

procedure LoadCheckBox(ABitmap: TBitmap; Checked: Boolean);
var
  B: TBitmap;
  R: TRect;
begin
  B := TBitmap.Create;

  try
    B.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_CHECKBOXES));

    ABitmap.Width := CHECK_WIDTH;
    ABitmap.Height := CHECK_HEIGHT;

    if Checked then
      R := Rect(CHECK_WIDTH, 0, CHECK_WIDTH * 2, CHECK_HEIGHT)
    else
      R := Rect(0, 0, 13, 13);

    ABitmap.Canvas.CopyRect(Rect(0, 0, CHECK_WIDTH, CHECK_HEIGHT), B.Canvas, R);
  finally
    B.Free;
  end;
end;

function SortItemsDesc(List: TStringList; Index1,
  Index2: Integer): Integer;
begin
  Assert(List <> nil);
  Result := AnsiCompareText(List[Index2], List[Index1]);
end;

{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TGridCheckBox.Create(AnOwner: TgsCustomDBGrid);
begin
  FDisplayField := '';
  FFieldName := '';
  FVisible := False;
  FCheckList := TStringList.Create;
  FCheckList.OnChange := DoOnChange;
  FOwner := AnOwner;
  FFirstColumn := False;

  FGlyphChecked := TBitmap.Create;
  FGlyphUnChecked := TBitmap.Create;

  LoadCheckBox(FGlyphChecked, True);
  LoadCheckBox(FGlyphUnChecked, False);

  FStoreGlyphChecked := False;
  FStoreGlyphUnChecked := False;

  FCheckBoxEvent := nil;
end;

destructor TGridCheckBox.Destroy;
begin
  FCheckList.Free;

  FGlyphChecked.Free;
  FGlyphUnChecked.Free;

  inherited Destroy;
end;

{
  Производим присваивание свойств от другого такого же класса.
}

procedure TGridCheckBox.Assign(Source: TPersistent);
begin
  if Source is TGridCheckBox then
  begin
    FFirstColumn := (Source as TGridCheckBox).FirstColumn;
    FDisplayField := (Source as TGridCheckBox).DisplayField;
    FFieldName := (Source as TGridCheckBox).FieldName;
    FVisible := (Source as TGridCheckBox).Visible;
    FCheckList.Assign((Source as TGridCheckBox).CheckList);
    FGlyphChecked.Assign((Source as TGridCheckBox).GlyphChecked);
    FGlyphUnChecked.Assign((Source as TGridCheckBox).GlyphUnChecked);
  end else
    inherited Assign(Source);
end;

function TGridCheckBox.GetNamePath: string;
begin
  Result := 'CheckBox';
end;

{
  Добавление идентификатора в виде строки.
}

procedure TGridCheckBox.AddCheck(const Value: String);
var
  Checked: Boolean;
begin
  if (Value > '') and (FCheckList.IndexOf(Value) = -1) then
  begin
    Checked := True;

    // передается не Self, а Grid, чтобы можно было обработать из макроса
    if Assigned(FCheckBoxEvent) then
    begin
      FInOnClickCheck := True;
      try
        FCheckBoxEvent(TGridCheckBox(Self).Grid, Value, Checked);
      finally
        FInOnClickCheck := False;
      end;
    end;
{Может какому-нибудь умному человеку пришло в голову в ивенте занести значение в список}
    if Checked and (FCheckList.IndexOf(Value) = -1) then
      FCheckList.Add(Value);

    // передается не Self, а Grid, чтобы можно было обработать из макроса
    if Assigned(FAfterCheckEvent) then
      FAfterCheckEvent(TGridCheckBox(Self).Grid, Value, Checked);

  end;
end;

{
  Добавление идентификатора в виде числа.
}

procedure TGridCheckBox.AddCheck(const Value: Integer);
var
  Checked: Boolean;
begin
  if FCheckList.IndexOf(IntToStr(Value)) = -1 then
  begin
    Checked := True;

    if Assigned(FCheckBoxEvent) then
      FCheckBoxEvent(TGridCheckBox(Self).Grid, IntToStr(Value), Checked);
    if Checked and (FCheckList.IndexOf(IntToStr(Value)) = -1) then
      FCheckList.Add(IntToStr(Value));
    if Assigned(FAfterCheckEvent) then
      FAfterCheckEvent(TGridCheckBox(Self).Grid, IntToStr(Value), Checked);

  end;
end;

{
  Удаление идентификатора в виде строки.
}

procedure TGridCheckBox.DeleteCheck(const Value: String);
var
  I: Integer;
  Checked: Boolean;
begin
  I := FCheckList.IndexOf(Value);
  if I <> -1 then
  begin
    Checked := False;

    if Assigned(FCheckBoxEvent) then
      FCheckBoxEvent(TGridCheckBox(Self).Grid, Value, Checked);

    I := FCheckList.IndexOf(Value);
    if not Checked and (I > -1)then
      FCheckList.Delete(I);

    if Assigned(FAfterCheckEvent) then
      FAfterCheckEvent(TGridCheckBox(Self).Grid, Value, Checked);

  end;
end;

{
  Удаление идентификатора в виде числа.
}

procedure TGridCheckBox.DeleteCheck(const Value: Integer);
var
  I: Integer;
  Checked: Boolean;
begin
  I := FCheckList.IndexOf(IntToStr(Value));
  if I <> -1 then
  begin
    Checked := False;

    if Assigned(FCheckBoxEvent) then
      FCheckBoxEvent(TGridCheckBox(Self).Grid, IntToStr(Value), Checked);

    I := FCheckList.IndexOf(IntToStr(Value));
    if not Checked and (I > -1)then
      FCheckList.Delete(I);

    if Assigned(FAfterCheckEvent) then
      FAfterCheckEvent(TGridCheckBox(Self).Grid, IntToStr(Value), Checked);

  end;
end;

procedure TGridCheckBox.Clear;
begin
  FCheckList.Clear;
end;

procedure TGridCheckBox.BeginUpdate;
begin
  FCheckList.BeginUpdate;
end;

procedure TGridCheckBox.EndUpdate;
begin
  FCheckList.EndUpdate;

  if FOwner.UpdateLock = 0 then
    FOwner.Invalidate;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

function TGridCheckBox.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

{
  Если были изменения в списке идентификаторов производим перерисовку.
}

procedure TGridCheckBox.DoOnChange(Sender: TObject);
begin
  if Assigned(FOwner) and ((FOwner.UpdateLock = 0) or (FInOnClickCheck)) then
    FOwner.Invalidate;
end;

{
  **********************
  ***  Private Part  ***
  **********************
}

{
  Кол-во идентификаторов.
}

function TGridCheckBox.GetCheckCount: Integer;
begin
  Result := FCheckList.Count;
end;

{
  Возвращает идентификатор в виде строки.
}

function TGridCheckBox.GetStrCheck(AnIndex: Integer): String;
begin
  Result := FCheckList[AnIndex];
end;

{
  Возвращает идентификатор в виде числа.
}

function TGridCheckBox.GetIntCheck(AnIndex: Integer): Integer;
var
  err: Integer;
begin
  Val(FCheckList[AnIndex], Result, err);
end;

{
  Устанавливает поле отображения.
}

procedure TGridCheckBox.SetDisplayField(const Value: String);
begin
  if FDisplayField <> Value then
  begin
    FDisplayField := Value;

    if Assigned(FOwner) and (FOwner.UpdateLock = 0) then
      FOwner.Invalidate;
  end;
end;

{
  Устанавливает поле, где брать данные идентификаторов.
}

procedure TGridCheckBox.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    FFieldName := Value;

    if Assigned(FOwner) and (FOwner.UpdateLock = 0) then
      FOwner.Invalidate;
  end;
end;

{
  Устанавливает режим отображения CheckBox.
}

procedure TGridCheckBox.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    
    if Assigned(FOwner) and (FOwner.UpdateLock = 0) then
      FOwner.Invalidate;
  end;
end;

{
  Устанавливает список идентификаторов.
}

procedure TGridCheckBox.SetCheckList(const Value: TStringList);
begin
  FCheckList.Assign(Value);
end;

{
  Рисунок с "галочкой"
}

procedure TGridCheckBox.SetGlyphChecked(const Value: TBitmap);
begin
  FGlyphChecked.Assign(Value);

  if FGlyphChecked.Empty then
  begin
    LoadCheckBox(FGlyphChecked, True);
    FStoreGlyphChecked := False;
  end else
    FStoreGlyphChecked := True;

  if Assigned(FOwner) and (FOwner.UpdateLock = 0) then
    FOwner.Invalidate;
end;

{
  Рисунок без "галочки"
}

procedure TGridCheckBox.SetGlyphUnChecked(const Value: TBitmap);
begin
  FGlyphUnChecked.Assign(Value);

  if FGlyphUnChecked.Empty then
  begin
    LoadCheckBox(FGlyphUnChecked, False);
    FStoreGlyphUnChecked := False;
  end else
    FStoreGlyphUnChecked := True;

  if Assigned(FOwner) and (FOwner.UpdateLock = 0) then
    FOwner.Invalidate;
end;

{
  Отмечена ли запись (сохранен ди ее идентификатор)
}

function TGridCheckBox.GetRecordChecked: Boolean;
var
  TheField: TField;
begin
  TheField := FOwner.DataLink.DataSet.FindField(FFieldName);
  if Assigned(TheField) then
    Result := FCheckList.IndexOf(TheField.DisplayText) <> -1
  else
    Result := False;
end;

{ TGridHintWindow }

var
  GridHintWindow: TGridHintWindow; // Окно hint-ов для grid-а

{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TGridHintWindow.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  GridHintWindow := Self;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := 700;
  FTimer.Enabled := False;
  FTimer.OnTimer := DoOnTimer;

  Brush.Color := clInfoBk;
end;

destructor TGridHintWindow.Destroy;
begin
  FTimer.Enabled := False;
  GridHintWindow := nil;
  inherited Destroy;
end;

procedure TGridHintWindow.ActivateHint(Rect: TRect; const AHint: string);
begin
  Dec(Rect.Bottom, 4);
  inherited ActivateHint(Rect, AHint);
end;

procedure TGridHintWindow.ActivateHintData(Rect: TRect;
  const AHint: string; AData: Pointer);
begin
  if Assigned(AData) then
  begin
    if TObject(AData) is TColumn then
    begin
      with TColumn(AData) do
        Self.Canvas.Font := Font;
    end else

    if TObject(AData) is TColumnTitle then
    begin
      with TColumnTitle(AData) do
        Self.Canvas.Font := Font;
    end;
  end;  

  inherited ActivateHintData(Rect, AHint, AData);
end;

function TGridHintWindow.CalcNeededRect(MaxWidth: Integer; const AHint: string;
  AData: Pointer): TRect;
begin
  if TObject(AData) is TColumn then
  begin
    with TColumn(AData) do
      Self.Canvas.Font := Font;
  end else

  if TObject(AData) is TColumnTitle then
  begin
    with TColumnTitle(AData) do
      Self.Canvas.Font := Font;
  end;

  Result := Rect(0, 0, MaxWidth, 0);
  DrawText(Canvas.Handle, PChar(AHint), -1, Result, DT_CALCRECT or DT_LEFT or
    DT_WORDBREAK or DT_NOPREFIX or DrawTextBiDiModeFlagsReadingOnly);

  //Inc(Result.Right, 2);
end;

procedure TGridHintWindow.ShowGridHint(Rect: TRect; const AHint: string; AData: Pointer);
begin
  FRect := Rect;
  FHint := AHint;
  FData := AData;

  FTimer.Enabled := True;
end;

procedure TGridHintWindow.HideGridHint;
begin
  FData := nil;
  FHint := '';

  if HandleAllocated and IsWindowVisible(Handle) then
    ShowWindow(Handle, SW_HIDE);

  FTimer.Enabled := False;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}


procedure TGridHintWindow.Paint;
var
  R: TRect;
begin
  R := ClientRect;
  Inc(R.Left, 1);
  Inc(R.Top, 1);
  Canvas.Font.Color := clInfoText;
  DrawText(Canvas.Handle, PChar(Caption), -1, R, DT_LEFT or DT_NOPREFIX or
    DT_WORDBREAK or DrawTextBiDiModeFlagsReadingOnly);
end;

{
  **********************
  ***  Private Part  ***
  **********************
}


procedure TGridHintWindow.DoOnTimer(Timer: TObject);
var
  CP: TPoint;
begin
  if not (csDestroying in ComponentState) then
  begin
    FTimer.Enabled := False;

    GetCursorPos(CP);
    if (CP.X <> OldCP.X) or (CP.Y <> OldCP.Y) then
    begin
      OldCP := CP;
      ActivateHintData(FRect, FHint, FData);
    end;

    FHint := '';
    FData := nil;
  end;  
end;

{ TCondition }

{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TCondition.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  FConditionState := csUnPrepared;
  FConditionCompareKind1 := cckNone;
  FConditionCompareKind2 := cckNone;

  FConditionName := '';

  FDisplayFields := '';
  FFieldName := '';

  FFont := TFont.Create;
  FColor := clWhite;

  FExpression1 := '';
  FExpression2 := '';

  FConditionKind := ckNone;
  FDisplayOptions := [];

  FUserCondition := False;
  FOnUserCondition := nil;

  FCompareValue1 := 0;
  FCompareValue2 := 0;

  FCompareDate1 := 0;
  FCompareDate2 := 0;

  FFoCal := nil;
end;

destructor TCondition.Destroy;
begin
  Font.Free;
  FFoCal.Free;

  inherited Destroy;
end;

{
  Присваивание объектов.
}

procedure TCondition.Assign(Source: TPersistent);
begin
  if Source is TCondition then
  begin
    FConditionName := (Source as TCondition).ConditionName;

    FDisplayFields := (Source as TCondition).DisplayFields;
    FFieldName := (Source as TCondition).FieldName;

    FFont.Assign((Source as TCondition).Font);
    FColor := (Source as TCondition).Color;

    FExpression1 := (Source as TCondition).Expression1;
    FExpression2 := (Source as TCondition).Expression2;

    FConditionKind := (Source as TCondition).ConditionKind;
    FDisplayOptions := (Source as TCondition).DisplayOptions;

    EvaluateFormula := (Source as TCondition).EvaluateFormula;

    FUserCondition := (Source as TCondition).UserCondition;
    FOnUserCondition := (Source as TCondition).OnUserCondition;
  end else
    inherited Assign(Source);
end;

{
  Проверка, следует ли применять условие на данное поле.
}

function TCondition.Suits(const DisplayField: TField): Boolean;
begin
  Result := StrIPos(';' + DisplayField.FieldName + ';', ';' + FDisplayFields + ';') > 0;
end;


{
  ************************
  ***  Protected Part  ***
  ************************
}

function TCondition.GetDisplayName: string;
begin
  Result := FConditionName;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

{
  Подготавливает условие к работе.
}

procedure TCondition.Prepare;
var
  TheField: TField;
  OkStatus: Boolean;

  // Проверка строки на совместимость с числовым типом поля
  function IsNumericCompatible(Text: String; var Value: Extended): Boolean;
  begin
    if TheField.DataType = ftCurrency then
      Result := TextToFloat(PChar(Text), Value, fvCurrency)
    else
      Result := TextToFloat(PChar(Text), Value, fvExtended);
  end;

  // Проверка строки на совместимость с датой
  function IsDateCompatible(Text: String; var Value: TDateTime): Boolean;
  begin
    try
      Value := StrToDate(Text);
      Result := True;
    except
      Result := False;
    end;
  end;

  // Проверка строки на совместимость со временем
  function IsTimeCompatible(Text: String; var Value: TDateTime): Boolean;
  begin
    try
      Value := StrToTime(Text);
      Result := True;
    except
      Result := False;
    end;
  end;

  // Проверка строки на совместимость с датой, временем
  function IsDateTimeCompatible(Text: String; var Value: TDateTime): Boolean;
  begin
    try
      Value := StrToDateTime(Text);
      Result := True;
    except
      Result := False;
    end;
  end;

  // Производит проверку выражения
  function CheckExpression(
    AnExpression: String;
    var NumValue: Extended;
    var DateValue: TDateTime;
    var CompareKind: TConditionCompareKind): Boolean;
  begin
    case TheField.DataType of
      ftSmallint, ftInteger, ftWord, ftAutoInc,
      ftLargeint, ftFloat, ftCurrency, ftBoolean, ftBCD:
      begin
        Result := IsNumericCompatible(AnExpression, NumValue);
        CompareKind := cckNumeric;
      end;
      ftString, ftMemo, ftFixedChar, ftWideString:
      begin
        Result := True;
        CompareKind := cckString;
      end;
      ftDate:
      begin
        Result := IsDateCompatible(AnExpression, DateValue);
        CompareKind := cckDateTime;
      end;
      ftTime:
      begin
        Result := IsTimeCompatible(AnExpression, DateValue);
        CompareKind := cckDateTime;
      end;
      ftDateTime:
      begin
        Result := IsDateTimeCompatible(AnExpression, DateValue);
        CompareKind := cckDateTime;
      end;
      else begin
        Result := False;
      end;
    end;
  end;

begin
  TheField := Field;

  if Assigned(TheField) then
  begin

    ////////////////////////////////////
    // Вариант пользовательского условия

    if UserCondition then
    begin
      if Assigned(FOnUserCondition) then
        FConditionState := csPrepared
      else
        FConditionState := csError;
    end else

    ///////////////////////////
    // Вариант обычного условия

    if not FEvaluateFormula then
    begin
      case ConditionKind of
        ckEqual, ckNotEqual, ckBigger, ckSmaller, ckBiggerEqual,
        ckSmallerEqual, ckStarts, ckContains:
          OkStatus :=
            CheckExpression(FExpression1, FCompareValue1, FCompareDate1,
              FConditionCompareKind1);
        ckIn, ckOut:
          OkStatus :=
            CheckExpression(FExpression1, FCompareValue1, FCompareDate1,
              FConditionCompareKind1)
              and
            CheckExpression(FExpression2, FCompareValue2, FCompareDate2,
              FConditionCompareKind2);
        ckExist, ckNotExist:
          OkStatus := True;
        else
          OkStatus := False;
      end;

      if OkStatus then
        FConditionState := csPrepared
      else
        FConditionState := csError;
    end;
  end else
    FConditionState := csError;
end;

{
  Применить условие к данному полю.
}

function TCondition.DoOnVariable(const VariableName: String;
  var V: Double): Boolean;
var
  I: Integer;
  F: TField;
begin
  Assert(Grid.DataLink.DataSet <> nil);
  Assert(Grid.DataLink.DataSet.Active);

  Result := False;

  if CompareText('DATE', VariableName) = 0 then
  begin
    V := Date;
    Result := True;
  end else
    for I := 0 to Grid.DataLink.DataSet.FieldCount - 1  do
    begin
      F := Grid.DataLink.DataSet.Fields[I];
      if (F.DataType in [ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint,
          ftFloat, ftCurrency, ftBoolean, ftDate, ftTime, ftDateTime, ftBCD])
        and (CompareText(VariableName, F.FieldName) = 0) then
      begin
        V := F.AsFloat;
        Result := True;
        break;
      end;
    end;
end;

procedure TCondition.CheckAndApply;
var
  OkStatus: Boolean;
  TheField: TField;
  CompareResult: Boolean;

  // Устанавливает фришт и цвет условия
  procedure Apply;
  begin
    if doFont in FDisplayOptions then
      Grid.Canvas.Font := Font;
    if doColor in FDisplayOptions then
      Grid.Canvas.Brush.Color := Color;
  end;

  // Рассчитывает формулу
  function Calculate(
    AnExpression: String;
    var NumValue: Extended;
    var DateValue: TDateTime;
    var CompareKind: TConditionCompareKind): Boolean;
  begin
    try
{!!!!!b Julia}
      FFoCal.Expression := AnExpression;
{!!!!!e Julia}
      if FFoCal.Value = 0 then
        Result := AnsiCompareText(FFoCal.Expression, 'Error') <> 0
      else
        Result := True;

      case TheField.DataType of
        ftSmallint, ftInteger, ftWord, ftAutoInc,
        ftLargeint, ftFloat, ftCurrency, ftBoolean, ftBCD:
          NumValue := FFoCal.Value;
        ftDate, ftTime, ftDateTime:
          DateValue := FFoCal.Value;
        else begin
          Result := False;
        end;
      end;
    except
      Result := False;
    end;
  end;

begin
  // Игонорирует условия с ошибками
  if FConditionState = csError then Exit;

  // Для ускорения запоминаем указатель на поле
  TheField := Field;

  ////////////////////////////////////////////
  // Исли не используется условие пользователя

  if not FUserCondition and Assigned(TheField) then
  begin

    ///////////////////////////////////////
    // Если необходимо рассчитывать формулы

    if FEvaluateFormula then
    begin
      (*
      // Очищаем старый список переменных
      FFoCal.ClearVariablesList;
      FFoCal.AssignVariable('DATE', Date);
      // Добавляем новый список переменных
      for I := 0 to DataLink.DataSet.FieldCount - 1  do
        if
          DataLink.DataSet.Fields[I].DataType
            in
          [
            ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint,
            ftFloat, ftCurrency, ftBoolean, ftDate, ftTime, ftDateTime, ftBCD
          ]
        then
          FFoCal.AssignVariable(DataLink.DataSet.Fields[I].FieldName,
            DataLink.DataSet.Fields[I].AsFloat);
      *)

      case FConditionKind of
        ckEqual, ckNotEqual, ckBigger, ckSmaller, ckBiggerEqual,
        ckSmallerEqual, ckStarts, ckContains:
          OkStatus :=
            Calculate(FExpression1, FCompareValue1, FCompareDate1,
              FConditionCompareKind1);
        ckIn, ckOut:
          OkStatus :=
            Calculate(FExpression1, FCompareValue1, FCompareDate1,
              FConditionCompareKind1)
              and
            Calculate(FExpression2, FCompareValue2, FCompareDate2,
              FConditionCompareKind2);
        ckExist, ckNotExist:
          OkStatus := True;
        else
          OkStatus := False;
      end;

      if not OkStatus then
        FConditionState := csError;
    end;

    //////////////////////////////////////////
    // Сравнение данных условия с данными поля

    case FConditionKind of
      ckEqual:
        case FConditionCompareKind1 of
          cckNumeric:
            CompareResult := FCompareValue1 = TheField.AsFloat;
          cckDateTime:
            CompareResult := FCompareDate1 = TheField.AsDateTime;
          cckString:
          begin
            if TheField.Datatype = ftMemo then
              CompareResult := AnsiCompareText(FExpression1, TheField.AsString) = 0
            else
              CompareResult := AnsiCompareText(FExpression1, TheField.DisplayText) = 0;
          end else
            CompareResult := False;
        end;
      ckNotEqual:
        case FConditionCompareKind1 of
          cckNumeric:
            CompareResult := FCompareValue1 <> TheField.AsFloat;
          cckDateTime:
            CompareResult := FCompareDate1 <> TheField.AsDateTime;
          cckString:
          begin
            if TheField.Datatype = ftMemo then
              CompareResult := AnsiCompareText(FExpression1, TheField.AsString) <> 0
            else
              CompareResult := AnsiCompareText(FExpression1, TheField.DisplayText) <> 0;
          end else
            CompareResult := False;
        end;
      ckIn:
      begin
        case FConditionCompareKind1 of
          cckNumeric:
            CompareResult :=
              (FCompareValue1 <= TheField.AsFloat)
                and
              (FCompareValue2 >= TheField.AsFloat);
          cckDateTime:
            CompareResult :=
              (FCompareDate1 <= TheField.AsDateTime)
                and
              (FCompareDate2 >= TheField.AsDateTime);
          cckString:
          begin
            if TheField.Datatype = ftMemo then
              CompareResult :=
                (FExpression1 <= TheField.AsString)
                  and
                (FExpression2 >= TheField.AsString)
            else
              CompareResult :=
                (FExpression1 <= TheField.DisplayText)
                  and
                (FExpression2 >= TheField.DisplayText);
          end else
            CompareResult := False;
        end;
      end;
      ckOut:
      begin
        case FConditionCompareKind1 of
          cckNumeric:
            CompareResult :=
              (FCompareValue1 > TheField.AsFloat)
                or
              (FCompareValue2 < TheField.AsFloat);
          cckDateTime:
            CompareResult :=
              (FCompareDate1 > TheField.AsDateTime)
                or
              (FCompareDate2 < TheField.AsDateTime);
          cckString:
            if TheField.Datatype = ftMemo then
              CompareResult :=
                (FExpression1 > TheField.AsString)
                  and
                (FExpression2 < TheField.AsString)
            else
              CompareResult :=
                (FExpression1 > TheField.DisplayText)
                  and
                (FExpression2 < TheField.DisplayText);
          else
            CompareResult := False;
        end;
      end;
      ckBigger:
        case FConditionCompareKind1 of
          cckNumeric:
            CompareResult := FCompareValue1 < TheField.AsFloat;
          cckDateTime:
            CompareResult := FCompareDate1 < TheField.AsDateTime;
          cckString:
          begin
            if TheField.Datatype = ftMemo then
              CompareResult := FExpression1 < TheField.AsString
            else
              CompareResult := FExpression1 < TheField.DisplayText;
          end else
            CompareResult := False;
        end;
      ckSmaller:
        case FConditionCompareKind1 of
          cckNumeric:
            CompareResult := FCompareValue1 > TheField.AsFloat;
          cckDateTime:
            CompareResult := FCompareDate1 > TheField.AsDateTime;
          cckString:
          begin
            if TheField.Datatype = ftMemo then
              CompareResult := FExpression1 > TheField.AsString
            else
              CompareResult := FExpression1 > TheField.DisplayText;
          end else
            CompareResult := False;
        end;
      ckBiggerEqual:
        case FConditionCompareKind1 of
          cckNumeric:
            CompareResult := FCompareValue1 <= TheField.AsFloat;
          cckDateTime:
            CompareResult := FCompareDate1 <= TheField.AsDateTime;
          cckString:
          begin
            if TheField.Datatype = ftMemo then
              CompareResult := FExpression1 <= TheField.AsString
            else
              CompareResult := FExpression1 <= TheField.DisplayText;
          end else
            CompareResult := False;
        end;
      ckSmallerEqual:
        case FConditionCompareKind1 of
          cckNumeric:
            CompareResult := FCompareValue1 >= TheField.AsFloat;
          cckDateTime:
            CompareResult := FCompareDate1 >= TheField.AsDateTime;
          cckString:
          begin
            if TheField.Datatype = ftMemo then
              CompareResult := FExpression1 >= TheField.AsString
            else
              CompareResult := FExpression1 >= TheField.DisplayText;
          end else
            CompareResult := False;
        end;
      ckContains:
        case FConditionCompareKind1 of
          cckString:
          begin
            if TheField.Datatype = ftMemo then
              CompareResult := AnsiUpperPos(FExpression1, TheField.AsString) > 0
            else
              CompareResult := AnsiUpperPos(FExpression1, TheField.DisplayText) > 0;
          end else
            CompareResult := False;
        end;
      ckStarts:
        case FConditionCompareKind1 of
          cckString:
          begin
            if TheField.Datatype = ftMemo then
              CompareResult := AnsiUpperPos(FExpression1, TheField.AsString) = 1
            else
              CompareResult := AnsiUpperPos(FExpression1, TheField.DisplayText) = 1;
          end else
            CompareResult := False;
        end;
      ckExist:
        CompareResult := not TheField.IsNull;
      ckNotExist:
        CompareResult := TheField.IsNull;
      else
        CompareResult := False;
    end;
  end else begin

    /////////////////////////////////////////////////
    // Если присвоено событие пользоватьского условия
    // выполняем его

    if Assigned(OnUserCondition) then
      CompareResult := OnUserCondition(Self, TheField)
    else
      CompareResult := False;
  end;

  //////////////////////////////////////
  // Если условие выполнено, то изменять
  // установки цвета и шрифта

  if CompareResult then
    Apply;
end;

{
  **********************
  ***  Private Part  ***
  **********************
}

{
  Возвращает таблицу.
}

function TCondition.GetGrid: TgsCustomDBGrid;
begin
  Result := (Collection as TGridConditions).Grid;
end;

{
  Возвращает соединение с источником данных.
}

function TCondition.GetDataLink: TGridDataLink;
begin
  if Assigned(Grid) then
    Result := Grid.DataLink
  else
    Result := nil;   
end;

{
  Возвращает поле для условия.
}

function TCondition.GetField: TField;
begin
  if Assigned(DataLink) and Assigned(DataLink.DataSet) then
    Result := DataLink.DataSet.FindField(FFieldName)
  else
    Result := nil;
end;

{
  Если новое имя условия, о устатавливаем его.
}

procedure TCondition.SetConditionName(const Value: String);
begin
  if FConditionName <> Value then
  begin
    FConditionName := Value;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Поля, в которых будут отображаться условия
}

procedure TCondition.SetDisplayFields(const Value: String);
begin
  if FDisplayFields <> Value then
  begin
    FDisplayFields := Value;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Поле, на основе которого будет строиться условие
}

procedure TCondition.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    FFieldName := Value;

    if not FEvaluateFormula then
      FConditionState := csUnPrepared;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Шрифт условия
}

procedure TCondition.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);

  if Assigned(Grid) then
    Grid.Invalidate;
end;

{
  Цвет условия
}

procedure TCondition.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Первое выражение
}

procedure TCondition.SetExpression1(const Value: String);
begin
  if FExpression1 <> Value then
  begin
    FExpression1 := Value;

    if not FEvaluateFormula then
      FConditionState := csUnPrepared;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Второе выражение
}

procedure TCondition.SetExpression2(const Value: String);
begin
  if FExpression2 <> Value then
  begin
    FExpression2 := Value;

    if not FEvaluateFormula then
      FConditionState := csUnPrepared;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Вид условия
}

procedure TCondition.SetConditionKind(const Value: TConditionKind);
begin
  if FConditionKind <> Value then
  begin
    FConditionKind := Value;

    if not FEvaluateFormula then
      FConditionState := csUnPrepared;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Опции отображения
}

procedure TCondition.SetDisplayOptions(const Value: TDisplayOptions);
begin
  if FDisplayOptions <> Value then
  begin
    FDisplayOptions := Value;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Устаналивает режим расчета формул.
}

procedure TCondition.SetEvaluateFormula(const Value: Boolean);
begin
  if FEvaluateFormula <> Value then
  begin
    FEvaluateFormula := Value;

    if FEvaluateFormula and not Assigned(FFoCal) then
    begin
      FFoCal := TxFoCal.Create(nil);
      FFoCal.OnVariable := DoOnVariable;
      FConditionState := csFormula;
      if Assigned(Field) and (Field.DataType in [ftDate, ftTime, ftDateTime]) then
      begin
        FConditionCompareKind1 := cckDateTime;
        FConditionCompareKind2 := cckDateTime;
      end
      else
      begin
        FConditionCompareKind1 := cckNumeric;
        FConditionCompareKind2 := cckNumeric;
      end
    end else begin
      if not FEvaluateFormula and Assigned(FFoCal) then
        FreeAndNil(FFoCal);

      FConditionState := csUnprepared;
    end;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Использовать пользовательское условие
}

procedure TCondition.SetUserCondition(const Value: Boolean);
begin
  if FUserCondition <> Value then
  begin
    FUserCondition := Value;
    FConditionState := csUnPrepared;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Событие на проверку пользовательского условия
}

procedure TCondition.SetOnUserCondition(const Value: TOnUserCondition);
begin
  FOnUserCondition := Value;
  FConditionState := csUnPrepared;

  if Assigned(Grid) then
    Grid.Invalidate;
end;

{

}

function TCondition.GetIsValid: Boolean;
begin
  Result := not
  (
    (FDisplayFields = '') or (FFieldName = '') or
    (FConditionKind = ckNone) or (FExpression1 = '')
  );
end;


{ TGridConditions }

{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TGridConditions.Create(Grid: TgsCustomDBGrid);
begin
  inherited Create(TCondition);

  FGrid := Grid; 
end;

destructor TGridConditions.Destroy;
begin
  inherited Destroy;
end;

{
  Добавление нового элемента.
}

function  TGridConditions.Add: TCondition;
begin
  Result := TCondition(inherited Add);
end;

{
  Возвращает владельца коллекции.
}

function TGridConditions.GetOwner: TPersistent;
begin
  Result := FGrid;
end;

{
  Производит обновление владельца коллекции.
}

procedure TGridConditions.Update(Item: TCollectionItem);
begin
  if (FGrid = nil) or (csLoading in FGrid.ComponentState) then Exit;
  FGrid.Invalidate;
end;

{
  **********************
  ***  Private Part  ***
  **********************
}

{
  Условие по индексу.
}

function TGridConditions.GetCondition(Index: Integer): TCondition;
begin
  Result := TCondition(inherited Items[Index]);
end;

{
  Устанавливает условие по индексу.
}

procedure TGridConditions.SetCondition(Index: Integer; const Value: TCondition);
begin
  Items[Index].Assign(Value);
end;


{ TColumnExpand }


{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TColumnExpand.Create(Collection: TCollection);
begin
  FDisplayField := '';
  FFieldName := '';
  FLineCount := 1;
  FOptions := [];

  inherited Create(Collection);
end;

destructor TColumnExpand.Destroy;
begin
  inherited Destroy;
end;

{
  Присваивание объектов.
}

procedure TColumnExpand.Assign(Source: TPersistent);
begin
  if Source is TColumnExpand then
  begin
    FOptions := (Source as TColumnExpand).Options;
    FDisplayField := (Source as TColumnExpand).DisplayField;
    FFieldName := (Source as TColumnExpand).FieldName;
    FLineCount := (Source as TColumnExpand).LineCount;
  end else
    inherited Assign(Source);
end;

{
  Есть ли поля, необходимые для работы данного
  элемента расширенного отображения.
}

function TColumnExpand.IsExpandValid(ADataLink: TGridDataLink): Boolean;
begin
  Result := ADataLink.DataSet.FindField(FDisplayField) <> nil;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

{
  Заголовок в дизайнере.
}

function TColumnExpand.GetDisplayName: string;
begin
  Result := FDisplayField;
  if Result = '' then
    Result := inherited GetDisplayName;
end;


{
  **********************
  ***  Private Part  ***
  **********************
}

{
  Устанавливает колонку, в которой выводить расширенное отображение.
}

procedure TColumnExpand.SetDisplayField(const Value: String);
begin
  if FDisplayField <> Value then
  begin
    FDisplayField := Value;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Устанавливает поле данных, откуда брать текст для расширенного отображения.
}

procedure TColumnExpand.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    FFieldName := Value;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Устанавливает кол-во линий.
}

procedure TColumnExpand.SetLineCount(const Value: Integer);
begin
  if FLineCount <> Value then
  begin
    if Value < 1 then Exit;
    FLineCount := Value;

    if Assigned(Grid) then
      Grid.Invalidate;
  end;
end;

{
  Возвращает таблицу.
}

function TColumnExpand.GetGrid: TgsCustomDBGrid;
begin
  Result := (Collection as TColumnExpands).Grid;
end;

{
  Опции расширенного отображения
}

procedure TColumnExpand.SetOptions(const Value: TColumnExpandOptions);
var
  NewOptions: TColumnExpandOptions;
begin
  if FOptions <> Value then
  begin
    NewOptions := Value;

    if ceoAddField in NewOptions then
      NewOptions := NewOptions - [ceoMultiline];

    if ceoMultiline in NewOptions then
    begin
      NewOptions := NewOptions - [ceoAddFieldMultiline, ceoAddField];
      FieldName := '';
    end;

    if
      (ceoAddFieldMultiline in Options)
        and
      not (ceoAddField in Options)
    then
      NewOptions := NewOptions - [ceoAddFieldMultiline];

    if NewOptions <> FOptions then
    begin
      FOptions := NewOptions;
      
      if Assigned(Grid) then
        Grid.Invalidate;
    end;
  end;
end;

{ TColumnExpands }


{
  *********************
  ***  Public Part  ***
  *********************
}


constructor TColumnExpands.Create(Grid: TgsCustomDBGrid);
begin
  inherited Create(TColumnExpand);

  FGrid := Grid;
end;

destructor TColumnExpands.Destroy;
begin
  inherited Destroy;
end;

{
  Добавляет новый элемент коллекции.
}

function  TColumnExpands.Add: TColumnExpand;
begin
  Result := TColumnExpand(inherited Add);
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

{
  Возвращает владельца коллекции.
}

function TColumnExpands.GetOwner: TPersistent;
begin
  Result := FGrid;
end;

{
  Вызываем перерисовку таблицы после произведенных изменений.
}

procedure TColumnExpands.Update(Item: TCollectionItem);
begin
  if (FGrid = nil) or (csLoading in FGrid.ComponentState) then Exit;
  FGrid.Invalidate;
end;


{
  **********************
  ***  Private Part  ***
  **********************
}

{
  Возвращаем элемент коллекции по индексу.
}

function TColumnExpands.GetExpand(Index: Integer): TColumnExpand;
begin
  Result := TColumnExpand(inherited Items[Index]);
end;

{
  Устанавливаем значения элемента по индексу.
}

procedure TColumnExpands.SetExpand(Index: Integer; const Value: TColumnExpand);
begin
  Items[Index].Assign(Value);
end;

{ TgsColumnTitle }

constructor TgsColumnTitle.Create(Column: TgsColumn);
begin
  inherited Create(Column);
end;

destructor TgsColumnTitle.Destroy;
begin
  inherited;
end;

function TgsColumnTitle.GetColumn: TgsColumn;
begin
  Result := inherited Column as TgsColumn;
end;

function TgsColumnTitle.IsAlignmentStored: Boolean;
begin
  Result := Alignment <> DefaultAlignment;
end;

function TgsColumnTitle.IsCaptionStored: Boolean;
begin
  Result := Caption <> Column.FieldName;
end;

function TgsColumnTitle.IsColorStored: Boolean;
begin
  Result := Color <> Column.Grid.TitleColor;
end;

function TgsColumnTitle.IsFontStored: Boolean;
begin
  Result := not FontsEqual(Column.Grid.TableFont, Font);
end;

procedure TgsColumnTitle.RestoreDefaults;
begin
  inherited;
end;

{ TgsColumn }

procedure TgsColumn.Assign(Source: TPersistent);
begin
  inherited Assign(Source);

  if Assigned(Source) and (Source is TgsColumn) then
  begin
    FDisplayFormat := (Source as TgsColumn).FDisplayFormat;
    FMax := (Source as TgsColumn).FMax;
    FTotalType := (Source as TgsColumn).TotalType;
    FFrozen := (Source as TgsColumn).Frozen;
    WasFrozen := (Source as TgsColumn).WasFrozen;
  end;
end;

constructor TgsColumn.Create(Collection: TCollection);
begin
  inherited;

  FDisplayFormat := '';

  FMax := 0;
  FFiltered := False;
  FFilteredValue := '';
  FFilteredCache := nil;

  FTotalType := ttNone;

  FFrozen := False;
end;

function TgsColumn.CreateTitle: TColumnTitle;
begin
  Result := TgsColumnTitle.Create(Self);
end;

destructor TgsColumn.Destroy;
begin
  FreeAndNil(FFilteredCache);
  if Grid is TgsDBGrid then
    with (Grid as TgsDBGrid) do
    begin
      FFilterableColumns.Extract(Self);
      FFilteredColumns.Extract(Self);
    end;
  inherited;
end;

function TgsColumn.Filterable: Boolean;
begin
  Result := IsFilterableField(Field)
    and ((Collection as TDBGridColumns).Grid.DataSource.DataSet
      is TIBCustomDataSet);
end;

function TgsColumn.GetDisplayFormat: String;
begin
  Result := FDisplayFormat;
end;

function TgsColumn.GetGrid: TgsCustomDBGrid;
begin
  Result := inherited Grid as TgsCustomDBGrid;
end;

function TgsColumn.IsAlignmentStored: Boolean;
begin
  Result := Alignment <> DefaultALignment;
end;

function TgsColumn.IsColorStored: Boolean;
begin
  Result := Color <> Grid.TableColor;
end;

function TgsColumn.IsDisplayFormatStored: Boolean;
begin
  Result := True;
end;

class function TgsColumn.IsFilterableField(F: TField): Boolean;
begin
  Result := (F <> nil) and (F.DataType in [
    ftString, ftSmallint, ftInteger, ftWord,
    ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate, ftTime, ftDateTime,
    {ftBytes, ftVarBytes, ftAutoInc,} ftBlob, ftMemo, ftGraphic, ftFmtMemo,
    {ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftFixedChar, ftWideString,}
    ftLargeint{, ftADT, ftArray, ftReference, ftDataSet, ftOraBlob, ftOraClob,
    ftVariant, ftInterface, ftIDispatch, ftGuid}
    ]);
end;

function TgsColumn.IsFontStored: Boolean;
begin
  Result := not FontsEqual(Font, Grid.TitleFont);
end;

function TgsColumn.IsTotalTypeStored: Boolean;
begin
  Result := FTotalType <> ttNone;
end;

function TgsColumn.IsVisibleStored: Boolean;
begin
  Result := not WasFrozen;
end;

function TgsColumn.IsWidthStored: Boolean;
begin
  Result := True;
end;

procedure TgsColumn.RestoreDefaults;
begin
  inherited;

  if Assigned(Field) and (Visible <> Field.Visible) then
    Visible := Field.Visible;
end;

{
procedure TgsColumnTitle.SetCaption(const Value: string);
begin
  if (Value = '') and Assigned(Column) then
    inherited SetCaption(Column.FieldName)
  else
    inherited SetCaption(Value);
end;
}

procedure TgsColumn.SetDisplayFormat(const Value: String);
var
  OldStored: Boolean;
begin
  if FDisplayFormat <> Value then
  begin
    FDisplayFormat := Value;

    if (Collection as TgsColumns).FIsSetupMode then
      Exit;

    OldStored := IsStored;
    try
      IsStored := False;
      SetFieldFormat;
    finally
      IsStored := OldStored;
    end;
  end;
end;

procedure TgsColumn.SetFieldFormat;
begin
  if Field is TNumericField then
  begin
    (Field as TNumericField).DisplayFormat := FDisplayFormat;
    if (Field as TNumericField).DisplayFormat > '' then
    begin
      (Field as TNumericField).EditFormat :=
        StringReplace((Field as TNumericField).DisplayFormat, ',', '', [rfReplaceAll]);
    end;
  end else
  if Field is TDateTimeField then
  begin
    (Field as TDateTimeField).DisplayFormat := FDisplayFormat;
  end;
end;

procedure TgsColumn.SetFrozen(const Value: Boolean);
var
  I: Integer;
begin
  if FFrozen <> Value then
  begin
    if Value then
    begin
      if Collection <> nil then
      begin
        for I := 0 to Collection.Count - 1 do
        begin
          if Collection.Items[I] = Self then
          begin
            break;
          end;

          if (Collection.Items[I] is TgsColumn)
            and ((Collection.Items[I] as TgsColumn).WasFrozen) then
          begin
            exit;
          end;
        end;
      end;
    end;

    FFrozen := Value;

    if Collection <> nil then
    begin
      if FFrozen then
      begin
        for I := 0 to Collection.Count - 1 do
        begin
          if (Collection.Items[I] <> Self) and (Collection.Items[I] is TgsColumn)
            and ((Collection.Items[I] as TgsColumn).Frozen) then
          begin
            (Collection.Items[I] as TgsColumn).FFrozen := False;
          end;
        end;
      end else
      begin
        for I := 0 to Collection.Count - 1 do
        begin
          if (Collection.Items[I] <> Self) and (Collection.Items[I] is TgsColumn)
            and ((Collection.Items[I] as TgsColumn).WasFrozen) then
          begin
            (Collection.Items[I] as TgsColumn).WasFrozen := False;
            (Collection.Items[I] as TgsColumn).Visible := True;
          end;
        end;
      end;
    end;
  end;
end;

procedure TgsColumn.SetTotalType(const Value: TgsTotalType);
begin
  FTotalType := Value;
end;

{ TgsColumns }

function TgsColumns.Add: TgsColumn;
begin
  Result := inherited Add as TgsColumn;
end;

constructor TgsColumns.Create(Grid: TCustomDBGrid; ColumnClass: TgsColumnClass;
  IsSetupMode: Boolean);
begin
  inherited Create(Grid, ColumnClass);
  FIsSetupMode := IsSetupMode;
end;

function TgsColumns.GetColumn(Index: Integer): TgsColumn;
begin
  Result := inherited Items[Index] as TgsColumn;
end;

function TgsColumns.GetGrid: TgsCustomDBGrid;
begin
  Result := inherited Grid as TgsCustomDBGrid;
end;

procedure TgsColumns.SetColumn(Index: Integer; Value: TgsColumn);
begin
  inherited Items[Index] := Value;
end;

procedure TgsColumns.Update(Item: TCollectionItem);
var
  I: Integer;
begin
  if not FIsSetupMode then
    inherited Update(Item);

  if Item is TgsColumn then
  begin
    (Item as TgsColumn).SetFieldFormat;
  end else
  begin
    if Item = nil then
    begin
      for I := 0 to Count - 1 do
      begin
        if Items[I] is TgsColumn then
        begin
          Items[I].SetFieldFormat;
        end;
      end;
    end;  
  end;
end;

{
  *********************************************
  ***  Additional Procedures and functions  ***
  *********************************************
}

var
  DrawBitmap: TBitmap; // Общий BITMAP для рисования текста
  UserCount: Integer; // Кол-во пользователей BITMAP

{
  Увеличивает счетчик кол-во пользователей BITMAP.
}

procedure UsesBitmap;
begin
  if UserCount = 0 then
    DrawBitmap := TBitmap.Create;
  Inc(UserCount);
end;

{
  Уменьшает счетчик пользователей BITMAP.
}

procedure ReleaseBitmap;
begin
  Dec(UserCount);
  if UserCount = 0 then DrawBitmap.Free;
end;

{
  Процедура рисования текста. Взята из модуля DBGrids с
  изменениями.
}

procedure WriteText(ACanvas: TCanvas; const ARect, ADrawRect: TRect; DX, DY: Integer;
  const Text: string; Alignment: TAlignment; ARightToLeft, Multiline: Boolean);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
  RTL: array [Boolean] of Integer = (0, DT_RTLREADING);
  MultilineFlag: array[Boolean] of Integer =
    (0, DT_EDITCONTROL);
var
  B, R: TRect;
  Left: Integer;
  I: TColorRef;
begin
  I := ColorToRGB(ACanvas.Brush.Color);

  if (GetNearestColor(ACanvas.Handle, I) = I) and not Multiline then
  begin                       { Use ExtTextOut for solid colors }
    { In BiDi, because we changed the window origin, the text that does not
      change alignment, actually gets its alignment changed. }

    if (ACanvas.CanvasOrientation = coRightToLeft) and (not ARightToLeft) then
      ChangeBiDiModeAlignment(Alignment);

    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - ACanvas.TextWidth(Text) - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1
        - (ACanvas.TextWidth(Text) shr 1);
    end;

    ACanvas.TextRect(ARect, Left, ARect.Top + DY, Text);
  end else begin
    DrawBitmap.Canvas.Lock;

    try
      if Multiline then
        with ADrawRect do
          B := Rect(0, 0, Right - Left, Bottom - Top)
      else
        with ARect do
          B := Rect(0, 0, Right - Left, Bottom - Top);

      with DrawBitmap do
      begin
        Width := Max(Width, B.Right);
        Height := Max(Height, B.Bottom);

        with ARect do
          R := Rect(DX, DY, Right - Left - 2, Bottom - Top - 2);
      end;

      with DrawBitmap.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);

        if (ACanvas.CanvasOrientation = coRightToLeft) then
          ChangeBiDiModeAlignment(Alignment);

        DrawText(Handle, PChar(Text), Length(Text), R,
          AlignFlags[Alignment] or RTL[ARightToLeft] or MultilineFlag[Multiline]);
      end;

      ACanvas.CopyRect(ADrawRect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
end;

{
  ==========  HINT PROCS ROUTINE  ==========
}


var
  GridHintThreadID: DWORD;
  GridHintDoneEvent: THandle;
  GridHintHook: HHOOK;
  GridHintThread: THandle;

{
  Создает объект для отображения hint-ов.
}

procedure CreateGridHint;
begin
  if
    Assigned(Application) and
    not (csDesigning in Application.ComponentState) and
    not Assigned(GridHintWindow)
  then
    GridHintWindow := TGridHintWindow.Create({Application}nil);
end;

{
  В течении одной секунды не удаляем окно хинтов на случай, если
  курсор перемещен в ячейку, где может быть хинт.
}

procedure GridHintMouseThread(Param: Integer); stdcall;
var
  P: TPoint;
  W: TWinControl;
begin
  GridHintThreadID := GetCurrentThreadID;
  while WaitForSingleObject(GridHintDoneEvent, 100) = WAIT_TIMEOUT do
  begin
    if Assigned(GridHintWindow) then
    begin
      GetCursorPos(P);
      W := FindVCLWindow(P);

      if not Assigned(W) then
        try
          GridHintWindow.HideGridHint;
        except
          Assert(False, 'Падобна GridHintWindow ужо няма...');
        end
      else if
        not (W is TgsCustomDBGrid) and
        not (W is TGridHintWindow)
          or
        (Assigned(Application) and not Application.Active)
      then
        GridHintWindow.HideGridHint;
    end;                  
  end;
end;

{
  Все сообщения, которые могут влиять на отображение хинта
  отлавливаем здесь и проверяем.
}

function GridHintGetMsgHook(nCode: Integer; wParam: Longint;
  var Msg: TMsg): Longint; stdcall;
begin
  Result := CallNextHookEx(GridHintHook, nCode, wParam, Longint(@Msg));

  if (nCode >= 0) and Assigned(GridHintWindow) then
  begin
    if
      GridHintWindow.IsHintMsg(Msg) and
      GridHintWindow.HandleAllocated and
      IsWindowVisible(GridHintWindow.Handle)
    then
      GridHintWindow.HideGridHint;
  end;
end;

{
  Процедура, осуществляющая установку hook-а для хинта в общую
  цепочку.
}

procedure GridHookHintHooks;
var
  ThreadID: DWORD;
begin
  if GridHintHook = 0 then
    GridHintHook := SetWindowsHookEx(WH_GETMESSAGE, @GridHintGetMsgHook, 0, GetCurrentThreadID);
  if GridHintDoneEvent = 0 then
    GridHintDoneEvent := CreateEvent(nil, False, False, nil);
  if GridHintThread = 0 then
    GridHintThread := CreateThread(nil, 1000, @GridHintMouseThread, nil, 0, ThreadID);
end;

{
  Процедура, удаляющая hook для хинта из общей цепочки.
}

procedure GridUnhookHintHooks;
begin
  if GridHintHook <> 0 then UnhookWindowsHookEx(GridHintHook);
  GridHintHook := 0;
  if GridHintThread <> 0 then
  begin
    SetEvent(GridHintDoneEvent);
    if GetCurrentThreadId <> GridHintThreadID then
      WaitForSingleObject(GridHintThread, INFINITE);
    CloseHandle(GridHintThread);
    GridHintThread := 0;
  end;
end;

(*
var
  AutoFilterHook: HHOOK = 0;

function AutoFilterHookProc(nCode: Integer; wParam: Integer; lParam: Integer): LResult; stdcall;
var
  P: TPoint;
begin
  Result := CallNextHookEx(AutoFilterHook, nCode, wParam, lParam);
  with PMouseHookStruct(lParam)^ do
  begin
    case wParam of
      WM_LBUTTONDOWN, WM_NCLBUTTONDOWN, WM_LBUTTONUP:
      begin
        if (Screen.ActiveForm is TdlgDropDown) and (GetForegroundWindow = Screen.ActiveForm.Handle) then
        with (Screen.ActiveForm as TdlgDropDown) do
        begin
          P := ScreenToClient(pt);
          if (P.X < 0) or (P.X > Width) or
            (P.Y < 0) or (P.Y > Height) then
          begin
            ModalResult := mrCancel;
            Result := 1;
          end else
            SendMessage(Handle, wParam, 0, MakeLParam(pt.X, pt.Y)); // was PostMessage
        end
      end;
    end;
  end;
end;
*)

{ TgsCustomDBGrid }


{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TgsCustomDBGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  UsesBitmap;

  if (UserCount = 1) and not (csDesigning in ComponentState) then
  begin
    CreateGridHint;
    GridHookHintHooks;
  end;

  FInternalMenuKind := imkWithSeparator;

  FRememberPosition := True;
  FSettingsLoaded := False;
  FMasterAct := nil;
  FRefreshAct := nil;
  FFindAct := nil;
  FFindNextAct := nil;
  FPanelAct := nil;
  FHideColAct := nil;
  FGroupAct := nil;
  {$IFDEF NEW_GRID}
  FUnGroupAct := nil;
  FGroupWrapAct := nil;
  FGroupUnWrapAct := nil;
  FGroupOneWrapAct := nil;
  FGroupOneUnWrapAct := nil;
  FGroupNextAct := nil;
  FGroupPriorAct := nil;
  {$ENDIF}
  FInputCaptionAct := nil;
  FFrozeColumnAct := nil;
  FCancelAutoFilterAct := nil;
  FCopyToClipboardAct := nil;

  FSelectedFont := TFont.Create;
  FSelectedFont.Color := clHighlightText;
  FSelectedFont.OnChange := DoOnFontChanged;

  FSelectedColor := clHighlight;
  FHalfSelectedTone := HalfTone(FSelectedColor, clWhite);

  FStriped := DefStriped;
  FStripeOdd := DefStripeOdd;
  FStripeEven := DefStripeEven;

  FMyOdd := skOdd;
  FMyEven := skEven;

  FExpands := TColumnExpands.Create(Self);
  FExpandsActive := False;
  FTitlesExpanding := DefTitlesExpanding;

  FConditions := TGridConditions.Create(Self);
  FConditionsActive := False;

  FSearchKey := '';
  FSearchLength := 0;
  // В режиме запуска программы создаем список действий
  if not (csDesigning in ComponentState) then
  begin
    FActionList := TActionList.Create(Self);
    FImages := TImageList.Create(Self);

    CreateActionList;
  end else begin
    FActionList := nil;
    FImages := nil;
  end;

  FCheckBox := TGridCheckBox.Create(Self);
  FScaleColumns := DefScaleColumns;
  FCanScale := False;

  FSizedIndex := -1;
  FSizedOldWidth := -1;
  FLastRemain := -1;
  FRestriction := False;
  FBlockFieldSetting := False;

  FMinColWidth := 40;
  FFormName := '';

  FFinishDrawing := True;
  FRefreshType := rtCloseOpen;

  FBlockSettings := False;
  FSaveSettings := True;
  FSearchFlag := False;
  FCloseDialog := False;

  FDeferedLoading := False;
  FDeferedStream := nil;

  //FAggregate := TgsAggregate.Create(Self);

  Options := [dgEditing, dgTitles, dgIndicator, dgColumnResize,
    dgColLines, {dgRowLines,} dgTabs, dgConfirmDelete, dgCancelOnExit];

  FSettingsModified := False;

  FFilterableColumns := TList.Create;
  FFilteredColumns := TList.Create;
  lv := nil;
  FFilteringColumn := nil;

  FShowTotals := DefShowTotals;
  FShowFooter := DefShowFooter;

  FDataSetOpenCounter := -1;
  FFilterDataSetOpenCounter := -1;
  //HelpContext := 3;

  Items := nil;
  P := nil;

  FAllowDrawTotals := True;
  FInDrawTotals := False;

  //^^^
  //_FDataLink:=TgsDataLink.Create;
  //_FDataLink.DataSource:=DataSource;
end;

destructor TgsCustomDBGrid.Destroy;
begin
  if FFilteredDataSet <> nil then
  begin
    FFilteredDataSet.OnFilterRecord := FOldOnFilterRecord;
    FFilteredDataSet.Filtered := FOldFiltered;
  end;

  FFilteredColumns.Free;
  FFilterableColumns.Free;

  FSelectedFont.Free;
  FExpands.Free;
  FCheckBox.Free;
  FConditions.Free;

  if Assigned(GridHintWindow) then
    GridHintWindow.HideGridHint;

  FreeAndNil(FDeferedStream);

  ReleaseBitmap;

  FOddKeys.Free;
  FEvenKeys.Free;

  //P := nil;
  FreeAndNil(Items);

  if (UserCount = 0) and not (csDesigning in ComponentState) then
    GridUnHookHintHooks;

  inherited Destroy;
end;

{
  Подготовка мастера перед выводом на экран.
}

procedure TgsCustomDBGrid.PrepareMaster(AMaster: TForm);
begin
  SelectedRows.Clear;

  {$IFDEF GEDEMIN}
  with AMaster as TdlgMaster do
  begin
    DataLink := Self.DataLink;

    TableFont := Self.Font;
    TableColor := Self.Color;

    TitleFont := Self.TitleFont;
    TitleColor := Self.TitleColor;

    SelectedFont := Self.SelectedFont;
    SelectedColor := Self.SelectedColor;

    Striped := Self.FStriped;
    StripeEven := Self.FStripeOdd;
    StripeOdd := Self.FStripeEven;

    ExpandsActive := Self.FExpandsActive;
    ExpandsSeparate := Self.FExpandsSeparate;

    ConditionsActive := Self.FConditionsActive;
    ScaleColumns := Self.ScaleColumns;
    ShowTotals := Self.ShowTotals;
    ShowFooter := Self.ShowFooter;

    TitlesExpanding := Self.TitlesExpanding;

    SetOldColumns(Columns as TgsColumns);
    SetOldExpands(FExpands);
    SetOldConditions(FConditions);

    Options := Self.Options;

    actApply.OnExecute := DoApplyMaster;
  end;
  {$ENDIF}
end;

{
  Установка паремтров мастера в визуальную таблицу.
}

procedure TgsCustomDBGrid.SetupGrid(AMaster: TForm; const UpdateGrid: Boolean = True);
{$IFDEF GEDEMIN}
var
  I: Integer;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  with AMaster as TdlgMaster do
  begin
    BeginLayout;

    //!!!
    DoOnCancelAutoFilter(nil);

    FCanScale := False;

    try
      Self.Font := TableFont;
      Self.Color := TableColor;

      Self.TitleFont := TitleFont;
      Self.TitleColor := TitleColor;

      Self.SelectedFont := SelectedFont;
      Self.SelectedColor := SelectedColor;

      Self.Striped := Striped;
      Self.StripeOdd := StripeEven;
      Self.StripeEven := StripeOdd;

      Self.ExpandsActive := ExpandsActive;
      Self.ExpandsSeparate := ExpandsSeparate;

      Self.ConditionsActive := ConditionsActive;
      Self.ScaleColumns := ScaleColumns;
      Self.ShowTotals := ShowTotals;
      Self.ShowFooter := ShowFooter;

      Self.TitlesExpanding := TitlesExpanding;

      if Self.DataLink.Active then
      begin
        Columns.Assign(NewColumns);

        for I := 0 to Columns.Count - 1 do
        begin
          if (Columns[I] as TgsColumn).WasFrozen then
          begin
            if Columns[I].Visible then
              Columns[I].Visible := False
            else
              (Columns[I] as TgsColumn).WasFrozen := False;
          end;
        end;

        for I := 0 to Columns.Count - 1 do
        begin
          if (Columns[I] as TgsColumn).Frozen then
          begin
            if not Columns[I].Visible then
              (Columns[I] as TgsColumn).Frozen := False;
          end;
        end;

        Expands := NewExpands;
        Conditions := NewConditions;
      end;

      if dgRowLines in Options then
        Self.Options := Self.Options + [dgRowLines]
      else
        Self.Options := Self.Options - [dgRowLines];

      if Assigned(DataSource)
        and (DataSource.DataSet is TIBCustomDataSet) then
      begin
        TIBCustomDataSet(DataSource.DataSet).Aggregates.Clear;
      end;
    finally
      FCanScale := True;

      if UpdateGrid then UpdateRowCount;
      EndLayout;
      ValidateColumns;

      if UpdateGrid then
        CountScaleColumns;
      if UpdateGrid and Self.HandleAllocated then
        PostMessage(Self.Handle, WM_CHANGEDISPLAYFORMTS, 0, 0)
    end;
  end;
  {$ENDIF}
end;

{
  Обрабатывает операции, связанные с выводом меню
  на экран.
}

procedure TgsCustomDBGrid.DefaultHandler(var Msg);
type
  TMenuCreateKind = (mckUser, mckInternal);

var
  Cell: TGridCoord;
  MenuCreateKind: TMenuCreateKind;
  I: Integer;
begin
  // Реагируем только на сообщения о правой кнопке мыши
  if (TMessage(Msg).Msg = wm_RButtonUp) {or (TMessage(Msg).Msg = WM_CONTEXTMENU)}
    and (Screen.Width >= 640) then {вторая проверка, чтобы предотвратить появление меню на палмах}
  begin
    with TWMRButtonUp(Msg) do
    begin
      // Определяем колонку
      Cell := MouseCoord(XPos, YPos);

      if (dgTitles in Options) and (Cell.Y = 0) then begin
        if EditorMode then
          EditorMode := False;
      end;

      if not EditorMode then
      begin
        if Items = nil then
          Items := TList.Create;

        if P <> nil then
          FreeAndNil(P);

        // Определяем меню
        if (Cell.X < Integer(dgIndicator in Options))
          or (Cell.Y < 0)
        then begin
          P := nil;
          Column := nil;
        end else begin
          Column := Columns[RawToDataColumn(Cell.X)];
          P := Column.PopupMenu;
        end;

        if not Assigned(P) then
        begin
          if (Assigned(PopupMenu) and not ((Cell.Y = 0) and (dgTitles in Options)))
            {$IFDEF NEW_GRID} { меню для заголовка группы }
            and not ((DataSource <> nil) and (DataSource.DataSet is TIBCustomDataSet)
            and (TIBCustomDataSet(DataSource.DataSet).RecordKind in [rkHeader, rkGroup])
            and (Column <> nil) )
            {$ENDIF}
          then begin
            P := PopupMenu;
            MenuCreateKind := mckUser;
          end else begin
            P := TPopupMenu.Create(Self);
            MenuCreateKind := mckInternal;
          end;
        end else
          MenuCreateKind := mckUser;

        for I := Items.Count - 1 downto 0 do
        begin
          {if (P <> nil) then
            P.Items.Remove(Items[I]);}
          TObject(Items[I]).Free;
        end;

        try
          // Заполняем меню
          FullFillMenu(Column, P, Items, (Cell.Y = 0) and (dgTitles in Options));

          // Активируем меню колонки
          if (P <> nil) and P.AutoPopup then
          begin
            SendCancelMode(nil);
            P.PopupComponent := Self;

            with ClientToScreen(SmallPointToPoint(Pos)) do
            begin
              P.Popup(X, Y);
            end;
            //Application.ProcessMessages;
          end;
        finally
          Result := 0;

          if MenuCreateKind <> mckInternal then
            P := nil;

          {if (not (csDestroying in ComponentState)) and Assigned(P) then
          begin
            if MenuCreateKind = mckInternal then
              FreeAndNil(P)
            else
            begin
              for I := Items.Count - 1 downto 0 do
              begin
                P.Items.Remove(Items[I]);
                TObject(Items[I]).Free;
              end;
            end;
          end;}
        end;
      end;    {  --  if not EditorMode  --  }
    end;      {  --  with TWMRButtonUp(Msg)  --  }
  end else
    inherited DefaultHandler(Msg);
end;

{
  При изменении размеров окна осуществляем
  расчет размера колонок.
}

procedure TgsCustomDBGrid.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  OldH, OldW: Integer;
begin
  OldH := Height;
  OldW := Width;

  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if Width <> OldW then
    CountScaleColumns
  else if (FShowTotals or FShowFooter)
    and (Height <> OldH)
    and Assigned(DataSource)
    and Assigned(DataSource.DataSet)
    and (DataSource.DataSet.IsEmpty) then
  begin
    Invalidate;
  end;
end;

{
  Восстановление настроек из потока.
}

procedure TgsCustomDBGrid.DisableActions;
begin
  FreeAndNil(FRefreshAct);
  FreeAndNil(FFindAct);
  FreeAndNil(FFindNextAct);
  FreeAndNil(FCopyToClipboardAct);
end;

procedure TgsCustomDBGrid.Read(Reader: TReader);
var
  I: Integer;
  Version: String;
  O: TDBGridOptions;
//  SelectedFieldName: String;

  function ReadColor(DefColor: TColor): TColor;
  begin
    try
      Result := StringToColor(Reader.ReadString);
    except
      Result := DefColor;
    end;
  end;

  procedure ReadFont(AFont: TFont);
  var
    Pitch: TFontPitch;
    Style: TFontStyles;
  begin
    Reader.ReadListBegin;

    try
      AFont.Name := Reader.ReadString;
      AFont.Color := ReadColor(AFont.Color);
      AFont.Height := Reader.ReadInteger;
      Reader.Read(Pitch, SizeOf(TFontPitch));
      AFont.Pitch := Pitch;
      AFont.Size := Reader.ReadInteger;
      Reader.Read(Style, SizeOf(TFontStyles));
      AFont.Style := Style;
      AFont.CharSet := Reader.ReadInteger;
      Reader.ReadListEnd;
    except
      Reader.ReadListEnd;
    end;
  end;

begin
  SelectedIndex := 0;

  BeginLayout;

  try
    Reader.ReadSignature;

    //////////////////////////////
    // Считывание данных для
    // версии грида

    I := Reader.Position;
    try
      if (Reader.NextValue = vaString) then
      begin
        Version := Reader.ReadString;

        if
          (Version <> GRID_STREAM_VERSION_2) and
          (Version <> GRID_STREAM_VERSION_3) and
          (Version <> GRID_STREAM_VERSION_4)
        then begin
          Reader.Position := I;
          Version := '';
        end;
      end else
        Version := '';
    except
      Reader.Position := I;
      Version := '';
    end;

    ReadFont(TableFont);
    TableColor := ReadColor(TableColor);

    ReadFont(SelectedFont);
    SelectedColor := ReadColor(SelectedColor);

    ReadFont(TitleFont);
    TitleColor := ReadColor(TitleColor);

    Striped := Reader.ReadBoolean;
    StripeOdd := ReadColor(StripeOdd);
    StripeEven := ReadColor(StripeEven);

    if Reader.ReadValue = vaCollection then Reader.ReadCollection(FExpands);
    ExpandsActive := Reader.ReadBoolean;
    ExpandsSeparate := Reader.ReadBoolean;

    if Reader.ReadValue = vaCollection then Reader.ReadCollection(FConditions);
    ConditionsActive := Reader.ReadBoolean;

    if Reader.ReadValue = vaCollection then Reader.ReadCollection(Columns);

    ScaleColumns := Reader.ReadBoolean;

    if (Version = GRID_STREAM_VERSION_2) then
      TitlesExpanding := Reader.ReadBoolean
    else if (Version = GRID_STREAM_VERSION_3) or (Version = GRID_STREAM_VERSION_4) then
    begin
      TitlesExpanding := Reader.ReadBoolean;

      Reader.Read(O, SizeOf(TDBGridOptions));
      if dgRowLines in O then
        Options := Options + [dgRowLines]
      else
        Options := Options - [dgRowLines];
    end;

    if (Version = GRID_STREAM_VERSION_4) then
    begin
      FShowTotals := Reader.ReadBoolean;
      FShowFooter := Reader.ReadBoolean;
    end;
    FSettingsLoaded := True;
  finally
    EndLayout;
    ValidateColumns;

    if Assigned(Parent) and (LayoutLock = 0) then
    begin
      UpdateRowCount;
      CountScaleColumns;
    end;
  end;
end;

{
  Сохранение даных в поток.
}

procedure TgsCustomDBGrid.Write(Writer: TWriter);

  procedure WriteFont(AFont: TFont);
  var
    Pitch: TFontPitch;
    Style: TFontStyles;
  begin
    Writer.WriteListBegin;

    Writer.WriteString(AFont.Name);
    Writer.WriteString(ColorToString(AFont.Color));
    Writer.WriteInteger(AFont.Height);
    Pitch := AFont.Pitch;
    Writer.Write(Pitch, SizeOf(TFontPitch));
    Writer.WriteInteger(AFont.Size);
    Style := AFont.Style;
    Writer.Write(Style, SizeOf(TFontStyles));
    Writer.WriteInteger(AFont.CharSet);

    Writer.WriteListEnd;
  end;

begin
  //////////////////////////////////////////////////////
  // Если до сохранения не был отключен источник данных,
  // следовательно нужно сохранить инфо о колонках

  Writer.WriteSignature;

  // Запись версии грида
  Writer.WriteString(GRID_STREAM_VERSION_4);

  WriteFont(TableFont);
  Writer.WriteString(ColorToString(TableColor));

  WriteFont(SelectedFont);
  Writer.WriteString(ColorToString(SelectedColor));

  WriteFont(TitleFont);
  Writer.WriteString(ColorToString(TitleColor));

  Writer.WriteBoolean(Striped);
  Writer.WriteString(ColorToString(StripeOdd));
  Writer.WriteString(ColorToString(StripeEven));

  Writer.WriteCollection(FExpands);
  Writer.WriteBoolean(ExpandsActive);
  Writer.WriteBoolean(ExpandsSeparate);

  Writer.WriteCollection(FConditions);
  Writer.WriteBoolean(ConditionsActive);

  //по умолчанию для колонки сохраняются только
  //Expanded, FieldName, Readonly, Title, Width, Visible
  Writer.WriteCollection(Columns);
  Writer.WriteBoolean(ScaleColumns);
  Writer.WriteBoolean(TitlesExpanding);
  Writer.Write(Options, SizeOf(TDBGridOptions));

  // 4
  Writer.WriteBoolean(FShowTotals);
  Writer.WriteBoolean(FShowFooter);
end;

{
  Считывание из потока.
}

procedure TgsCustomDBGrid.LoadFromStream(Stream: TStream);
var
  R: TReader;
begin
  // Если источник данных не открыт, откладываем присваивание настроек
  if not DataLink.Active then
  begin
    if not Assigned(FDeferedStream) then
      FDeferedStream := TMemoryStream.Create;

    FDeferedStream.CopyFrom(Stream, Stream.Size);
    FDeferedStream.Position := 0;
    FDeferedLoading := True;
  end else begin
    if Stream.Size > 0 then
    begin
      R := TReader.Create(Stream, 1024);
      try
        FDontLoadSettings := True;
        Read(R);
      finally
        R.Free;
      end;
    end;
  end;
end;

{
  Запись в поток.
}

procedure TgsCustomDBGrid.SaveToStream(Stream: TStream);
var
  W: TWriter;
begin
  if FDeferedLoading and Assigned(FDeferedStream) then
  begin
    Stream.CopyFrom(FDeferedStream, 0);
  end else
  begin
    W := TWriter.Create(Stream, 1024);
    try
      Write(W);
    finally
      W.Free;
    end;
  end;
end;

{
  Определяет над какой ячейкой находится курсор.
}

function TgsCustomDBGrid.GridCoordFromMouse: TGridCoord;
begin
  Result := MouseCoord(HitTest.X, HitTest.Y);
  Dec(Result.X, Integer(dgIndicator in Options));
  Dec(Result.Y, Integer(dgTitles in Options));
end;

function TgsCustomDBGrid.ColumnByField(Field: TField): TColumn;
var
  I: Integer;
begin
  for I := 0 to Columns.Count - 1 do
    if Columns[I].Field = Field then
    begin
      Result := Columns[I];
      Exit;
    end;

  Result := nil;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

{$IFDEF NEW_GRID}
var
  FIDS: TIBCustomDataSet; //для присваивания в процедурах для уменьшения длины строки кода

function DataSetIsIBCustom(DataSource: TDataSource): Boolean;
begin
   Result := Assigned(DataSource)
     and (DataSource.DataSet is TIBCustomDataSet);
end;

function GridGroupSortResult(gsGrid: TgsCustomDBGrid): string;
var I, J: Integer;
    F: TGroupSortField; FieldCaption: string;
    DS: TIBCustomDataSet;
begin
   Result := '';
   if DataSetIsIBCustom(gsGrid.DataSource) then
   with gsGrid do begin
     DS := TIBCustomDataSet(DataSource.DataSet);
     for I := 0 to DS.GroupSortFields.Count - 1 do begin
       F := DS.GroupSortFields[I];// as TGroupSortField;
       if not (F.GroupSortOrder in [gsoGroupAsc, gsoGroupDesc]) then
         continue;
       FieldCaption := F.Field.FieldName;
       for J := 0 to Columns.Count - 1 do begin
         if UpperCase(F.Field.FieldName) = UpperCase(Columns[J].FieldName) then
         begin
           FieldCaption := Columns[J].Title.Caption;
           break;
         end;
       end;
       //Result := Result + ', ' + FieldCaption + '={' + F.Field.asString+'}';
       Result := Result + ', ' + F.Field.asString+'';
     end;
   end;
   System.Delete(Result, 1, 1);
end;
{$ENDIF}

procedure VertLine(Canvas: TCanvas; X, Y, Height: Integer);
begin
  Canvas.Polyline([Point(X, Y), Point(X, Y + Height)]);
end;
procedure HorzLine(Canvas: TCanvas; X, Y, Width: Integer);
begin
  Canvas.Polyline([Point(X, Y), Point(X + Width, Y)]);
end;

{
  Осуществляет перерисовку таблицы.
}

procedure TgsCustomDBGrid.DrawCell(ACol, ARow: Longint; ARect: TRect;
  AState: TGridDrawState);
const
  GRow: Integer = -1;
  GKey: Integer = -1;
  GColor: TColor = -1;
  GDDKey: Integer = -1;

var
  OldActive: LongInt; // Сохраненный № пп в таблице
  HighLight: Boolean; // Флаг выделения записей таблицы
  Value: string;   // Значение, которое будет нарисовано
  //InAggregates: Boolean; //флаг вхождения ячейки в агрегаты
  DrawColumn: TColumn; // Текущая таблица, в которой производится рисование
  ExpandsList: TList; // Список элементов расширенного отображения
  CurrExpand: TColumnExpand; // Текущий элемент расширенного отображения
  I: Integer; // Счетчик
  CurrLine: Integer; // Текущая линия
  DefRowHeight: Integer; // Высота ячейки
  IsCheckBoxField: Boolean; // Поле отмечено
  TheField: TField; // Поле
  CurrAlignment: TAlignment;
  OldMode: TPenMode;
  OldPenColor, OldBrushColor, OldTitleColor: TColor;
  OldPenStyle: TPenStyle;
  OldBrushStyle: TBrushStyle;
  FGroup: TField;
  Da: Boolean; // для присваивания значений длинных выражений для дальнейшего исп.
  {$IFDEF NEW_GRID}
  ValF: string;  // значение Value для формулы
  MarginVal: Integer;   // начало вывода текста, может быть отр. для группировочной записи
  W1, W2: Integer;
  MarginF: Integer;
  RecKind: TRecordKind;
  DX, DY : Integer;

  OldPseudoRecordsOn: Boolean;

  function WidthBefore: Integer;
  var I: integer;
  begin
    Result := 0;
    for I:=GetFirstVisible to ACol - 1 do
      Result := Result + ColWidths[I]
        + GridLineWidth * Integer(dgColLines in Options);
    if Result > 0 then
      Result := Result + GridLineWidth * Integer(dgColLines in Options);
  end;
  {$ENDIF}

  // Производит рисование CheckBox-ов
  procedure DrawCheckBox(const BMP: TBitmap; const R: TRect);
  var
    Pos: Integer;
  begin
    Pos := ((R.Bottom - R.Top) - BMP.Height) div 2;

    Canvas.BrushCopy
    (
      Rect(R.Left, R.Top + Pos, R.Left + CHECK_WIDTH, R.Top + Pos + CHECK_HEIGHT),
      BMP,
      Rect(0, 0, CHECK_WIDTH, CHECK_HEIGHT),
      clNone{BMP.TransparentColor}
    );
  end;

begin                        
  if (lv <> nil) and (not lv.Focused) and (not FInInputQuery) then
    FreeAndNil(lv);

  // Получаем колонку
  if (ACol - Integer(dgIndicator in Options) >= 0) and
    (ACol - Integer(dgIndicator in Options) < Columns.Count)
  then
    DrawColumn := Columns[ACol - Integer(dgIndicator in Options)]
  else
    DrawColumn := nil;

  if gdFixed in AState then
  begin//////////////////////////////////////////
       // Производится рисование заглавий колонок
    if FExpandsActive
      and Assigned(DrawColumn)
      and Assigned(DrawColumn.Field) then
    begin
      //////////////////////////////////////////////
      // Используется режим расширенного отображения

      // Возвращает высоту строчки
      DefRowHeight := GetDefaultTitleRowHeight;

      Canvas.Brush.Color := DrawColumn.Title.Color;
      Canvas.Font := DrawColumn.Title.Font;

      if FFilteredDataSet <> nil then
        Canvas.Font.Color := clBlue;

      if FTitlesExpanding and ExpandExists(DrawColumn) then
      begin
        ExpandsList := TList.Create;
        try
          GetCaptionFields(DrawColumn, ExpandsList);

          for I := 0 to ExpandsList.Count - 1 do
          begin
            TheField := ExpandsList[I];

            WriteText
            (
              Canvas,
              Rect
              (
                ARect.Left,
                ARect.Top + DefRowHeight * I + I * 2,
                ARect.Right,
                ARect.Top + DefRowHeight * (I + 1) + (I + 1) * 2
              ),
              Rect
              (
                ARect.Left,
                ARect.Top + DefRowHeight * I,
                ARect.Right,
                ARect.Bottom
              ),
              2, 2, GetFieldCaption(TheField), TheField.Alignment,
              UseRightToLeftAlignmentForField(TheField, TheField.Alignment),
              True
            );

            if FExpandsSeparate and (I > 0) then
            begin
              OldMode := Canvas.Pen.Mode;
              try
                Canvas.Pen.Mode := pmNot;

                Canvas.MoveTo(ARect.Left, ARect.Top + DefRowHeight * I);
                Canvas.LineTo(ARect.Right, ARect.Top + DefRowHeight * I);

              finally
                Canvas.Pen.Mode := OldMode;
              end;
            end;
          end;
        finally
          ExpandsList.Free;
        end;

      end else begin
        Value := GetFullCaption(DrawColumn);

        WriteText
        ( Canvas,
          ARect, ARect, 2, 2,
          Value, DrawColumn.Title.Alignment,
          UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Title.Alignment),
          False
        );
      end;{if FTitlesExpanding}

      if [dgRowLines, dgColLines] * Options = [dgRowLines, dgColLines] then
      begin
        DrawEdge(Canvas.Handle, ARect, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
        DrawEdge(Canvas.Handle, ARect, BDR_RAISEDINNER, BF_TOPLEFT);
      end;
    end else {  -- if FExpandsActive  --  }
    begin
      if (ACol >= 0) and (ACol < Columns.Count) then
      begin
        if FFilteredDataSet <> nil then
        begin
          BeginUpdate;
          OldTitleColor := TitleFont.Color;
          try
            TitleFont.Color := clBlue;
            inherited DrawCell(ACol, ARow, ARect, AState);
          finally
            TitleFont.Color := OldTitleColor;
            EndUpdate;
          end;
        end else
          inherited DrawCell(ACol, ARow, ARect, AState);
      end;
    end;

    // трэба намаляваць трохкутнічак для фільтрацыі
    if (ARow = 0) and (DrawColumn is TgsColumn) and TgsColumn(DrawColumn).Filterable then
      with ARect, Canvas do
    begin
      OldBrushStyle := Brush.Style;
      OldPenStyle := Pen.Style;
      OldBrushColor := Brush.Color;
      OldPenColor := Pen.Color;
      try
        Brush.Style := bsSolid;
        Brush.Color := DrawColumn.Title.Color;
        FillRect(Rect(Right - 13, Bottom - 14, Right - 1, Bottom - 1));

        if FFilteredColumns.IndexOf(DrawColumn) = -1 then
        begin
          Brush.Color := clBlack;
          Pen.Color := clBlack;
        end else
        begin
          Brush.Color := clBlue;
          Pen.Color := clBlue;
        end;
        Polygon([Point(Right - 11, Bottom - 10),
          Point(Right - 3, Bottom - 10),
          Point(Right - 7, Bottom - 6)]);
      finally
        Pen.Color := OldPenColor;
        Pen.Style := OldPenStyle;
        Brush.Color := OldBrushColor;
        Brush.Style := OldBrushStyle;
      end;
    end;
    // канец маляваньня трохкутнічка

    //
    if (DrawColumn <> nil)
      and (DataSource <> nil)
      and (DataSource.DataSet is TIBCustomDataSet)
      and (DrawColumn.FieldName > '') then
    begin
      {$IFDEF NEW_GRID}
      FIDS := TIBCustomDataSet(DataSource.DataSet);
      if FIDS.IsGroupSortField(DrawColumn.Field) then
      {$ELSE}
      if DrawColumn.FieldName = TIBCustomDataSet(DataSource.DataSet).SortField then
      {$ENDIF}
      with ARect, Canvas do
      begin
        OldBrushStyle := Brush.Style;
        OldPenStyle := Pen.Style;
        OldBrushColor := Brush.Color;
        OldPenColor := Pen.Color;
        try
          Brush.Style := bsSolid;
          Pen.Style := psSolid;
          Brush.Color := clRed;
          Pen.Color := clMaroon;

          Da := false;
          {$IFDEF NEW_GRID}
          //if FIDS.IsGroupSortField(DrawColumn.Field, True) then
          //  Brush.Color := clYellow;
          if FIDS.IsGroupSortFieldAsc(DrawColumn.Field) then
            Da := True;
          {$ELSE}
          if TIBCustomDataSet(DataSource.DataSet).SortAscending then
            Da := True;
          {$ENDIF}

          if Da then
            Polygon([Point(Right - 6, Top),
              Point(Right, Top),
              Point(Right, Top + 6)])
          else
            Polygon([Point(Left, Top),
              Point(Left + 6, Top),
              Point(Left, Top + 6)]);
        finally
          Pen.Color := OldPenColor;
          Pen.Style := OldPenStyle;
          Brush.Color := OldBrushColor;
          Brush.Style := OldBrushStyle;
        end;
      end;
    end;

  end else { not gdFixed in ColumnState  }
  if Assigned(DrawColumn) then
  with Canvas do begin

    ////////////////////////////////////////
    // Производится рисование текста колонок

    // Возвращает высоту строчки
    DefRowHeight := GetDefaultRowHeight;

    // Устанавливаем шрифт и цвет
    Self.Canvas.Font := DrawColumn.Font;
    Brush.Color := DrawColumn.Color;

    // Если данных нет, то рисуем простой прямоугольник
    if not Assigned(DataLink) or not DataLink.Active then
    begin
      FillRect(ARect);
    end else
    begin//////////////////////////////////////////////////////////////////
        // Устанавливаем указатель в базе данных на необходимую запись для
        // получения данных
      //_FDataLink.DataSource := DataSource;
      OldActive := DataLink.ActiveRecord;
      {$IFDEF NEW_GRID} { TODO : ^^^^ DataLink.ActiveRecord в прорисовке грида }
      if DataSetIsIBCustom(DataSource) then begin
        if TIBCustomDataSet(DataSource.DataSet).GroupSortExist then
          //OldPseudoRecordsOn := TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn;
        TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn := True;
        OldPseudoRecordsOn := false;
      end;
      {$ENDIF}
      try
        // Получаем необходиму запись
        DataLink.ActiveRecord := ARow - Integer(dgTitles in Options);

        // Получаем текст для рисования
        if Assigned(DrawColumn.Field) then
        begin
          if ((DrawColumn.Field is TBlobField) and ((DrawColumn.Field as TBlobField).BlobType = ftGraphic))
             or (DrawColumn.Field is TGraphicField)  then
          begin
            if DrawColumn.Field.IsNull then
              Value := '(' + GraphicFieldString + ')'
            else
              Value := '(' + AnsiUpperCase(GraphicFieldString) + ')';
          end
          else
          begin
            if (DrawColumn.Field is TNumericField) and (DrawColumn.Field.AsFloat = 0)
              {$IFDEF GEDEMIN}
              and (UserStorage <> nil) and
                (not UserStorage.ReadBoolean('Options', 'ShowZero', False, False))
              {$ELSE}
              and False
              {$ENDIF}
              then
            begin
              Value := '';
            end else
            begin
              if (DrawColumn.Field is TMemoField) then
                Value := StringReplace(DrawColumn.Field.AsString, #13#10, ' ',
                  [rfReplaceAll])
              else
              begin
                Value := StringReplace(DrawColumn.Field.DisplayText, #13#10, ' ',
                  [rfReplaceAll]);
                GetValueFromValueList(DrawColumn, Value);
              end;
            end;
          end;
            //Value := DrawColumn.Field.DisplayText

          if (DrawColumn.Field is TNumericField) and
            (Self.Canvas.TextWidth(Value) >= DrawColumn.Width) then
          begin
            Value := '########';
          end;
        end
        else
          Value := '';

        // Устанавливаем необходимость рисования данной ячейки выделенной
        Highlight := HighlightCell(ACol, ARow, Value, AState);
        //InAggregates := AggregateCell(ACol, ARow);
        //////////////////////////////////////////////////////////
        // Проверяем дополнительные опции по выбору шрифта и цвета

        if Highlight then
          Self.Canvas.Font := FSelectedFont;

        (*if Highlight then
        begin

          //////////////////////////////////////////////////////////////
          // Устанавливаем цвет и шрифт для рисования выделенного текста

          Brush.Color := FSelectedColor;
          Self.Canvas.Font := FSelectedFont;
          {if InAggregates then
          begin
            Self.Canvas.Font.Style := Self.Canvas.Font.Style + [fsBold];
            Brush.Color := FHalfSelectedTone;
          end}
        end else *)begin

          {$IFDEF NEW_GRID}
          RecKind := rkRecord;{чтобы была поменьше длина кода при проверке типа записи}
          
          if DataSetIsIBCustom(DataSource) then begin
             RecKind := TIBCustomDataSet(DataSource.DataSet).RecordKind;
          end;

          if (RecKind <> rkRecord) then
          begin
            case RecKind of
              rkGroup: Brush.Color := clBtnFace;        //--clOlive;
              rkHeader: Brush.Color := clBtnFace;       //-- clTeal;
              rkHeaderRecord: Brush.Color := clBtnFace; //--clTeal;
              rkFooter: AdjustColor(clBtnFace, -20);//--clLime;
             // rkHiddenRecord: Brush.Color := clRed;
             // rkGhost: Brush.Color := clGreen;
            else
              Brush.Color := clYellow;{на всякий случай если понадобятся новые разновидности}
            end;
          end else
          begin { Настоящие записи (не-псевдо) }
          {$ENDIF}
            ///////////////////////////////////////
            // Используется режим полосатой таблицы

            // Выбираем цвет текущей полосы в таблице
            if FStriped and (not GridStripeProh) then
            begin
              if (FGroupFieldName > '')
                and Assigned(DataSource)
                and (DataSource.DataSet is TIBCustomDataSet) then
              begin
                if (FDataSetOpenCounter <> TIBCustomdataSet(DataLink.DataSet).OpenCounter) then
                begin
                  FDataSetOpenCounter := TIBCustomdataSet(DataLink.DataSet).OpenCounter;

                  FreeAndNil(FOddKeys);
                  FreeAndNil(FEvenKeys);
                end;

                FGroup := DataSource.DataSet.FindField(FGroupFieldName);
              end else
                FGroup := nil;

              if FGroup = nil then
              begin
                if (ARow mod 2) = 0 then
                begin
                  if FMyOdd = skOdd then
                    Brush.Color := FStripeOdd
                  else if FMyOdd = skEven then
                    Brush.Color := FStripeEven;
                end else begin
                  if FMyEven = skOdd then
                    Brush.Color := FStripeOdd
                  else if FMyEven = skEven then
                    Brush.Color := FStripeEven;
                end;
              end else
              begin
                if FOddKeys = nil then
                begin
                  FOddKeys := TgdKeyArray.Create;
                  FEvenKeys := TgdKeyArray.Create;
                  GKey := FGroup.AsInteger;
                  if Odd(GKey) then
                  begin
                    GColor := FStripeOdd;
                    FOddKeys.Add(GKey);
                  end else
                  begin
                    GColor := FStripeEven;
                    FEvenKeys.Add(GKey);
                  end;
                end else
                begin
                  if GKey <> FGroup.AsInteger then
                  begin
                    GKey := FGroup.AsInteger;
                    if FOddKeys.IndexOf(GKey) <> -1 then
                      GColor := FStripeOdd
                    else if FEvenKeys.IndexOf(GKey) <> -1 then
                      GColor := FStripeEven
                    else begin
                      if GColor = FStripeEven then
                      begin
                        GColor := FStripeOdd;
                        FOddKeys.Add(GKey);
                      end else
                      begin
                        GColor := FStripeEven;
                        FEvenKeys.Add(GKey);
                      end;
                    end;
                  end;
                end;

                if FGroup <> nil then
                  Brush.Color := GColor
                else
                begin
                  if (ARow mod 2) = 0 then
                  begin
                    if FMyOdd = skOdd then
                      Brush.Color := AdjustColor(GColor, 12)
                    else if FMyOdd = skEven then
                      Brush.Color := AdjustColor(GColor, -12);
                  end else begin
                    if FMyEven = skOdd then
                      Brush.Color := AdjustColor(GColor, 12)
                    else if FMyEven = skEven then
                      Brush.Color := AdjustColor(GColor, -12);
                  end;
                end;
              end;
            end;{ if FStriped and (not GridStripeProh) }

            ////////////////////////////////////////////
            // Если используется условное форматирование
            if FConditionsActive and Assigned(DrawColumn.Field) and not HighLight then
            begin
              for I := 0 to FConditions.Count - 1 do
              begin
                // Пропускаем условия с ошибками
                if FConditions[I].ConditionState = csError then Continue;

                // Работаем с условием только, если его следует отображать
                // в данной колонке
                if FConditions[I].Suits(DrawColumn.Field) then
                begin
                 // Подготавливаем условия, если они еще не подготовлены
                 if FConditions[I].ConditionState = csUnPrepared then
                    FConditions[I].Prepare;

                  // Пропускаем условия с ошибками
                  if FConditions[I].ConditionState = csError then
                    Continue;

                  // Производим проверку и нанесение цвета и шрифта
                  try
                    FConditions[I].CheckAndApply;
                  except
                  end;
                end;
              end;
            end;
          end;
        {$IFDEF NEW_GRID}
        end;
        {$ENDIF}

        if Highlight then
        begin
          if (SelectedRows.Count > 1) and (not (gdSelected in AState)) then
            Brush.Color := MixColors(Brush.Color, FSelectedColor)
          else
          {$IFDEF NEW_GRID}
            if not (RecKind in [rkGroup, rkHeader, rkFooter]) then
              Brush.Color := FSelectedColor;
          {$ELSE}
            Brush.Color := FSelectedColor;
          {$ENDIF}
        end
        else if OldActive = DataLink.ActiveRecord then
            Canvas.Brush.Color := AdjustColor(Canvas.Brush.Color, -40);

        if (DrawColumn is TgsColumn) then
        begin
          if (DataSource <> nil)
            and (DataSource.DataSet is TIBCustomDataSet)
            {$IFDEF NEW_GRID}
            and TIBCustomDataSet(DataSource.DataSet).IsGroupSortField(DrawColumn.Field)
            and not (RecKind in [rkGroup, rkHeader, rkFooter, rkHeaderRecord]) then
            {$ELSE}
            and (DrawColumn.FieldName = TIBCustomDataSet(DataSource.DataSet).SortField) then
            {$ENDIF}
          begin
        { уменьшаем светимость группироваочной(сортировочной) колонки  }
            Canvas.Brush.Color := AdjustColor(Canvas.Brush.Color, -30);
          end;
        end;

        /////////////////////////////////////////////////////
        // Если необходимо рисовать текст самостоятельно, т.е.
        // не перекрыты события рисования OnDrawColumnCell,
        // OnDrawDataCell

        if DefaultDrawing then
        begin
          if FCheckBox.Visible and FCheckBox.FirstColumn then
            IsCheckBoxField := ACol = GetFirstVisible
          else
            IsCheckBoxField :=
              FCheckBox.Visible
                and
              (
                (AnsiCompareText(FCheckBox.FDisplayField, DrawColumn.FieldName) = 0)
               );

          if FExpandsActive and Assigned(DrawColumn.Field) then
          begin//////////////////////////////////////////////
               // Используется режим расширенного отображения
            ExpandsList := TList.Create;
            try
              GetExpandsList(DrawColumn.Field, ExpandsList);
              CurrLine := 0;
              CurrExpand := FindMainExpand(ExpandsList);
              //////////////////////////////////////////////////////
              // Рисуем главное поле, если есть настройки для него -
              // используем эти настройки
              if Assigned(CurrExpand) then
              begin/////////////////////////////////////////////////////
                   // Если поле memo и вывод более чем в одну строку, то
                   // преобразуем в текст
                if
                  Assigned(DrawColumn.Field)
                    and
                  (DrawColumn.Field is TMemoField)
                    and
                  (CurrExpand.LineCount > 1)
                then
                  Value := StringReplace(DrawColumn.Field.AsString, #13#10, ' ', [rfReplaceAll]);
                  //Value := DrawColumn.Field.AsString;

                WriteText
                ( Canvas,
                  Rect
                  ( ARect.Left,
                    ARect.Top,
                    ARect.Right,
                    ARect.Top + DefRowHeight * (CurrLine + CurrExpand.LineCount)
                  ),
                  ARect,
                  2 + (CHECK_WIDTH + 2) * Integer(IsCheckBoxField), 2,
                  Value, DrawColumn.Alignment,
                  UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment),
                  (CurrLine + CurrExpand.LineCount - 1) > 0
                );

                CurrLine := CurrExpand.LineCount;
              end else begin
                WriteText
                ( Canvas,
                  ARect, ARect,
                  2 + (CHECK_WIDTH + 2) * Integer(IsCheckBoxField), 2,
                  Value, DrawColumn.Alignment,
                  UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment),
                  False
                );

                CurrLine := 1;
              end;

              for I := 0 to ExpandsList.Count - 1 do
              begin
                CurrExpand := ExpandsList[I];

                if ceoAddField in CurrExpand.Options then
                begin
                  TheField := DataLink.DataSet.FindField(CurrExpand.FieldName);
                  if TheField <> nil then
                  begin
                    if TheField is TMemoField then
                      Value := TheField.AsString
                    else if (TheField is TNumericField) and (TheField.AsFloat = 0)
                      {$IFDEF GEDEMIN}
                      and (UserStorage <> nil) and
                        (not UserStorage.ReadBoolean('Options', 'ShowZero', False, False))
                      {$ENDIF}
                      then begin
                        Value := '';
                      end else
                        Value := TheField.DisplayText;

                    CurrAlignment := TheField.Alignment;
                  end else begin
                    Value := '';
                    CurrAlignment := DrawColumn.Alignment;
                  end;

                  WriteText
                  ( Canvas,
                    Rect
                    ( ARect.Left,
                      ARect.Top + DefRowHeight * CurrLine,
                      ARect.Right,
                      ARect.Top + DefRowHeight * (CurrLine + CurrExpand.LineCount)
                    ),
                    Rect
                    ( ARect.Left,
                      ARect.Top + DefRowHeight * CurrLine,
                      ARect.Right,
                      ARect.Bottom
                    ),
                    2, 2, Value, CurrAlignment,
                    UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment),
                    ceoAddFieldMultiline in CurrExpand.Options
                  );

                  /////////////////////////////////////////////////
                  // Если используется режим визуального разделения
                  // элементов расширенного отображения

                  if FExpandsSeparate then
                  begin
                    MoveTo(ARect.Left, ARect.Top + DefRowHeight * CurrLine);
                    LineTo(ARect.Right, ARect.Top + DefRowHeight * CurrLine);
                  end;

                  Inc(CurrLine, CurrExpand.LineCount);
                end;
              end;

            finally
              ExpandsList.Free;
            end;

          end else begin
            //////////////////////////
            // Обычный режим рисования

          {$IFDEF NEW_GRID}
            MarginVal := 0;
            ValF := '';
            if DataSetIsIBCustom(DataSource) then
            begin
             if (RecKind in [rkGroup, rkHeader, rkHeaderRecord])
               or (RecKind in [rkFooter]) and (ACol = GetFirstVisible) then
                 MarginVal := MarginVal + 12;
                          {  Текст для заголовка группы  }
             if (RecKind in [rkGroup, rkHeader])
             then begin
               ValF := TIBCustomDataSet(DataSource.DataSet).GetFormulaByField(DrawColumn.Field);
               if {(ACol <> GetFirstVisible) and} (ValF <> '') then begin
                        {  Текст значения формулы поля  }
                 ValF := FormatFloat('#,##0.####',DrawColumn.Field.asFloat);
                 MarginF := ARect.Right - ARect.Left - Canvas.TextWidth(ValF) - 4;
               end;{ else
                 ValF := '';}

               Value := GridGroupSortResult(Self);
               W1 := WidthBefore;  W2 := Canvas.TextWidth(Value);
               if (W2 + MarginVal) < W1 then begin
                 Value := '';{ValF;}
               end else if (ACol <> GetFirstVisible) then begin
                 MarginVal := MarginVal - W1 + 1;
                if dgIndicator in Options then
                  MarginVal := MarginVal;
               end;

               if (ValF <> '') and ((W2 - W1) > (MarginF - 7)) then
                 ValF := '';
             end;
                          {  Текст для подножия группы  }
          { Раньше выводилось подножие. Не прошло }
//             if (RecKind in [rkFooter]) then begin
          { Раньше перед значением формулч выводилось её названиие. Не прошло }
//               ValTmp := TIBCustomDataSet(DataSource.DataSet).GetFormulaByField(DrawColumn.Field);
//               if ValTmp <> '' then
//                 Value := ValTmp + '= ' + }Value;
//             end;

                      {   псевдозаписи выводятся без разделения колонок }
             if (RecKind in [rkGroup, rkHeader, rkFooter]) then begin
               Canvas.Brush.Color := clBtnFace;
               Canvas.Font.Color := clWindowText;
               if RecKind = rkFooter then
                 Canvas.Brush.Color := AdjustColor(clBtnFace, -5);
               //else with TGroupSortField(DrawColumn.Field) do
               // if (IntScale <> 1) or (DateScale <> dsType) then
               //   Canvas.Font.Color := clNavy;

               ARect.Right := ARect.Right + GridLineWidth * Integer(dgColLines in Options);
               if ([gdFocused] * AState) <> [] then
                 Canvas.Brush.Color := AdjustColor(Canvas.Brush.Color, 15);
             end else
               if TIBCustomDataSet(DataSource.DataSet).UpdateStatus = usDeleted then
                 Canvas.Brush.Color := $00DBB7FF;
  
           end;     {  --  if DataSetIsIBCustom(DataSource)  -- }

           if (RecKind in [rkGroup, rkHeader, rkFooter]) then begin
             WriteText( Canvas, ARect, ARect,
               MarginVal , 2,  Value, taLeftJustify, False, False );
             if ValF <> '' then begin
               Canvas.Font.Color := clNavy;
               ARect.Left := ARect.Left + MarginF;
               WriteText( Canvas, ARect, ARect,
                 0 , 2, ValF, taLeftJustify, False, False);
               ARect.Left := ARect.Left - MarginF;
             end;
           end else
             WriteText( Canvas, ARect, ARect,
               2 + (CHECK_WIDTH + 2) * Integer(IsCheckBoxField), 2,
               Value, DrawColumn.Alignment,
               UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment),
               False );

           if DataSetIsIBCustom(DataSource) then
             if (ARow = Row) and (RecKind in [rkGroup, rkHeader, rkFooter]) then
             begin
               Canvas.Pen.Color := clBlack;
               Canvas.Pen.Style := psSolid;   {ARect.Right - ARect.Left}
               HorzLine(Canvas, 0, ARect.Top, ClientRect.Right);
               HorzLine(Canvas, 0, ARect.Bottom - 1, ClientRect.Right);
             end else if (ARow <> Row) and (RecKind in [rkGroup, rkHeader, rkFooter]) then begin
               Canvas.Pen.Color := AdjustColor(clBtnFace, -33);
               HorzLine(Canvas, 0, ARect.Bottom - 1, ClientRect.Right);
             end;

          {$ELSE}
            WriteText
            ( Canvas, ARect, ARect,
              2 + (CHECK_WIDTH + 2) * Integer(IsCheckBoxField), 2,
              Value, DrawColumn.Alignment,
              UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment),
              False
            );
          {$ENDIF}

          end;     {  --  else  if FExpandsActive  --  }

          if IsCheckBoxField then
            if FCheckBox.RecordChecked then
              DrawCheckBox
              (
                FCheckBox.GlyphChecked,
                Rect(
                  ARect.Left + 2,  ARect.Top,
                  ARect.Right,     ARect.Top + DefRowHeight + 1
                )
              )
            else
              DrawCheckBox
              (
                FCheckBox.GlyphUnChecked,
                Rect(
                  ARect.Left + 2, ARect.Top,
                  ARect.Right,    ARect.Top + DefRowHeight + 1
                )
              );
        {$IFDEF NEW_GRID}
          if (ACol = GetFirstVisible)
            and Assigned(DataSource)
            and (DataSource.DataSet is TIBCustomDataSet) then
          begin
            case TIBCustomDataSet(DataSource.DataSet).RecordKind of
              rkHeader, rkGroup, rkFooter:
                with ARect, Canvas do
                begin
                  OldBrushStyle := Brush.Style;
                  OldPenStyle := Pen.Style;
                  OldBrushColor := Brush.Color;
                  OldPenColor := Pen.Color;
                  try
                    Brush.Style := bsSolid;
                    Brush.Color := AdjustColor(clBtnFace, 20);
                    Pen.Color := clBlack;
                    Pen.Style := psSolid;

                    if RecKind <> rkFooter then begin
                      Polygon([Point(Left + 2, Top + 2),
                        Point(Left + 2 + 10, Top + 2),
                        Point(Left + 2 + 10, Top + 2 + 10),
                        Point(Left + 2, Top + 2 + 10)]);

                      HorzLine(Canvas, Left + 4, Top + 2 + 5, 7);
                      if TIBCustomDataSet(DataSource.DataSet).RecordKind = rkGroup then
                        VertLine(Canvas, Left + 7, Top + 2 + 2, 7)

                    end else begin
                      //Pen.Color := clWhite;
                      DX := 2; DY := 3;
                      HorzLine(Canvas, Left + DX, Bottom - DY    , 12);
                      HorzLine(Canvas, Left + DX, Bottom - DY - 2, 10);
                      HorzLine(Canvas, Left + DX, Bottom - DY - 4, 8);
                      HorzLine(Canvas, Left + DX, Bottom - DY - 6, 6);
                      HorzLine(Canvas, Left + DX, Bottom - DY - 8, 4);
                      HorzLine(Canvas, Left + DX, Bottom - DY - 10,2);
                    end;

                  finally
                    Pen.Color := OldPenColor;
                    Pen.Style := OldPenStyle;
                    Brush.Color := OldBrushColor;
                    Brush.Style := OldBrushStyle;
                  end;
                end;
            end;
          end;

        {$ENDIF}
        end;{ if DefaultDrawing }

        if Columns.State = csDefault then
          DrawDataCell(ARect, DrawColumn.Field, AState);

        DrawColumnCell(ARect, ACol - Integer(dgIndicator in Options),
          DrawColumn, AState);
      finally
        DataLink.ActiveRecord := OldActive;
        {$IFDEF NEW_GRID}
        // TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn := OldPseudoRecordsOn;
        {$ENDIF}
      end;

      // Ресуем Focus
      if
        DefaultDrawing and (gdSelected in AState)
          and
        ((dgAlwaysShowSelection in Options) or Focused)
          and
        not (csDesigning in ComponentState)
          and
        not (dgRowSelect in Options)
          and
        (UpdateLock = 0)
          and
        (ValidParentForm(Self).ActiveControl = Self)
      then
        Windows.DrawFocusRect(Handle, ARect);

      if TgsColumn(DrawColumn).Frozen then
      begin
        Canvas.Brush.Color := $000000;
        Canvas.FillRect(Rect(ARect.Right - 2, ARect.Top,
          ARect.Right, ARect.Bottom + 1));
      end;
    end;
  end;
end;


{
  Изменение состояния источника данных. Необходимо
  произвести действия с колонками.
}

procedure TgsCustomDBGrid.LinkActive(Active: Boolean);
var
  I: Integer;
begin
  FDataSetOpenCounter := -1;
  FFilterDataSetOpenCounter := -1;

  inherited LinkActive(Active);

  FMyOdd := skOdd;
  FMyEven := skEven;

  if Active then
    FCanScale := True;

  if Active then
  begin
    for I := 0 to FConditions.Count - 1 do
    begin
      FConditions[I].Prepare;
    end;
  end;

  if FSaveSettings then ValidateColumns;
  CountScaleColumns;
end;

{
  При скроллинге необходимо решить проблему с
  полосатой перерисовкой.
}

procedure TgsCustomDBGrid.Scroll(Distance: Integer);
begin
  if Distance <> 0 then CountStripes(Distance);
  inherited Scroll(Distance);
end;

procedure TgsCustomDBGrid.LayoutChanged;
var
  Reader: TReader;
begin
  if ScaleColumns then
    CountScaleColumns;
  if FDeferedLoading and Assigned(FDeferedStream) then
  begin
    FDeferedLoading := False;
    if FDeferedStream.Size > 0 then
    begin
      Reader := TReader.Create(FDeferedStream, 1024);
      try
        FDontLoadSettings := True;
        Read(Reader);
      finally
        Reader.Free;
      end;
    end;
    FreeAndNil(FDeferedStream);
  end else
  begin
    inherited LayoutChanged;

    {if DataLink.Active then
      CountScaleColumns;}

    //
    //  Необходимо осуществить обновление форматов полей.
    //  Посылаем для этого сообщение самому себе.
{    if HandleAllocated then
      PostMessage(Handle, WM_CHANGEDISPLAYFORMTS, 0, 0);}
  end;
end;

procedure TgsCustomDBGrid.ColumnMoved(FromIndex, ToIndex: Longint);
{$IFDEF GEDEMIN}
var
  I: Integer;
  F: Boolean;
{$ENDIF}
begin
  inherited;

{$IFDEF GEDEMIN}
  F := False;
  for I := 0 to Columns.Count - 1 do
  begin
    if (Columns[I] as TgsColumn).WasFrozen then
    begin
      (Columns[I] as TgsColumn).WasFrozen := False;
      Columns[I].Visible := True;
      F := True;
    end;
  end;
  for I := 0 to Columns.Count - 1 do
  begin
    if (Columns[I] as TgsColumn).Frozen then
    begin
      if (RawToDataColumn(ToIndex) = I)
        or (RawToDataColumn(FromIndex) >= I) then
      begin
        (Columns[I] as TgsColumn).Frozen := False;
        break;
      end;
    end;
  end;
  if F then
  begin
    ClampInView(FCurrent);
  end;
{$ENDIF}
end;

procedure TgsCustomDBGrid.RowHeightsChanged;
begin
  inherited RowHeightsChanged;

  if not FBlockSettings then
  begin
    FBlockSettings := True;
    try
      UpdateRowCount;
    finally
      FBlockSettings := False;
    end;
  end;
end;

procedure TgsCustomDBGrid.ColWidthsChanged;
var
  Difference: Integer;
  I: Integer;
  Next: Integer;

  function GetNext(Index: Integer): Integer;
  var
    Z: Integer;
  begin
    for Z := Index + 1 to ColCount - 1 do
      if Columns[Z - Integer(dgIndicator in Options)].Visible then
      begin
        Result := Z;
        Exit;
      end;

    Result := -1;
  end;

begin
  if
    FScaleColumns and FCanScale and
    (FSizedIndex <> -1) then
  begin
    if AcquireLayoutLock then
    try
      Next := GetNext(FSizedIndex);

      if Next = -1 then
        ColWidths[FSizedIndex] := FSizedOldWidth;

      if ColWidths[FSizedIndex] < FMinColWidth then
        ColWidths[FSizedIndex] := FMinColWidth;

      if ColWidths[FSizedIndex] > FSizedOldWidth then
      begin
        Difference := ColWidths[FSizedIndex] - FSizedOldWidth;

        if Next <> -1 then
        begin
          if ColWidths[Next] - Difference < FMinColWidth then
          begin
            ColWidths[FSizedIndex] := ColWidths[FSizedIndex] +
              (ColWidths[Next] - Difference - FMinColWidth);

            Difference := ColWidths[FSizedIndex] - FSizedOldWidth;
          end;

          ColWidths[Next] := ColWidths[Next] - Difference;
        end;

      end else if ColWidths[FSizedIndex] < FSizedOldWidth then
      begin
        Difference := FSizedOldWidth - ColWidths[FSizedIndex];
        Next := GetNext(FSizedIndex);

        if Next <> -1 then
          ColWidths[Next] := ColWidths[Next] + Difference;
      end;

      for I := 0 to Columns.Count - 1 do
        Columns[I].Width := ColWidths[I + Integer(dgIndicator in Options)];
    finally
      EndLayout;
    end;
  end;

  inherited ColWidthsChanged;
end;

procedure TgsCustomDBGrid.CalcSizingState(X, Y: Integer;
  var State: TGridState; var Index, SizingPos, SizingOfs: Integer;
  var FixedInfo: TGridDrawInfo);
begin
  inherited CalcSizingState(X, Y, State, Index, SizingPos, SizingOfs, FixedInfo);

  if State = gsColSizing then
  begin
    FSizedIndex := Index;
    FSizedOldWidth := ColWidths[Index];
  end else begin
    FSizedIndex := -1;
    FSizedOldWidth := -1;
  end;
end;

procedure TgsCustomDBGrid.KeyDown(var Key: Word; Shift: TShiftState);
const
  RowMovementKeys = [VK_UP, VK_PRIOR, VK_DOWN, VK_NEXT, VK_HOME, VK_END];
var
  OldSelectedRows: Integer;
  OldBm, NewBm: String;
  WasEOF: Boolean;
begin
  {$IFDEF NEW_GRID}
  {DBG}{не забыть удалить}
//  if (Key = Word('G')) and ([ssCtrl] = Shift) then begin
//     FIDS:= TIBCustomDataSet(DataSource.DataSet); //dbg/
//     FIDS.ClearGroupSort;       //dbg/       CITY
//     //FIDS.AddGroupSortField(FIDS.FieldByName('EDITIONDATE'), //dbg/
//     //   gsoGroupAsc, 1, dsType, '');  //dbg/
//     //FIDS.AddGroupSortField(FIDS.FieldByName('ID'), //dbg/
//     //     gsoGroupAsc, 10000, dsType, '');  //dbg/
//     //FIDS.AddFormulaField(FIDS.FieldByName('ZIP'), 'SUM');  //dbg/
//
//     FIDS.AddGroupSortField(FIDS.FieldByName('UserID'), gsoGroupAsc, 1, dsType, '');
//     FIDS.AddGroupSortField(FIDS.FieldByName('WorkID'), gsoSortDesc, 1, dsType, '');
//
//     FIDS.Group;                //dbg/
//     FIDS.WrapAllGroups;        //dbg/
//  end else if (Key = VK_F11) and (Shift = []) then begin
//     DataSource.DataSet.Last
//  end else if (Key = VK_F2) and (Shift = []) then begin
//    if not (DataSource.DataSet.State in dsEditModes) then
//      DataSource.DataSet.Edit
//  end else if (Key = VK_F8) and (Shift = []) then begin
//    if not (DataSource.DataSet.State in dsEditModes) then
//      DataSource.DataSet.Delete;
//  end else {DBG}
  if (Key = Word('G')) and ([ssCtrl] = Shift) then begin
    DoOnGroup(Self); exit;
  end;

  if (DataSource.DataSet is TIBCustomDataSet) then

   if TIBCustomDataSet(DataSource.DataSet).GroupSortExist then begin
     FIDS := TIBCustomDataSet(DataSource.DataSet);

     if (Key = VK_F2) and (FIDS.RecordKind in [rkGroup, rkHeader, rkFooter]) then begin
       Key := 0;
       exit;
     end;

     if TIBCustomDataSet(DataSource.DataSet).GroupSortExist then begin
       if (Key = VK_DIVIDE) and ([ssCtrl] = Shift) then begin
         DoOnGroupWrap(Self);
         exit;
       end else if (Key = VK_MULTIPLY) and ([ssCtrl] = Shift) then begin
         DoOnGroupUnWrap(Self);
         exit;
       end else if (Key = VK_SUBTRACT) and ([ssCtrl] = Shift) then begin
         DoOnGroupOneWrap(Self);
         exit;
       end else if (Key = VK_ADD) and ([ssCtrl] = Shift) then begin
         DoOnGroupOneUnWrap(Self);
         exit;
       end else if (Key = VK_UP) and ([ssCtrl] = Shift) then begin
         DoOnGroupPrior(Self);
         exit;
       end else if (Key = VK_DOWN) and ([ssCtrl] = Shift) then begin
         DoOnGroupNext(Self);
         exit;
       end

     end;

   end;
  {$ENDIF}

  if (Key = VK_F3) and (Shift = []) then {!!!}
  begin
    if Assigned(FFindNextAct) then FFindNextAct.Execute;
  end
  else if (Key = Word('F')) and ([ssCtrl] = Shift) then
  begin
    if Assigned(FFindAct) then FFindAct.Execute;
  end
  else if (Key = VK_F5) and (Shift = []) then
  begin
    if Assigned(FRefreshAct) then FRefreshAct.Execute;
  end
  else if (Key = VK_INSERT) and (Shift = [ssCtrl])
    and ((InplaceEditor = nil) or (not InplaceEditor.Visible)) then
  begin
    if Assigned(FCopyToClipboardAct) then FCopyToClipboardAct.Execute;
  end
  {$IFDEF GEDEMIN}
  else if (Key = VK_F5) and (Shift = [ssCtrl])
    and Assigned(DataSource) and (DataSource.DataSet is TgdcBase)
    and Assigned(TgdcBase(DataSource.DataSet).Filter) then
  begin
    TgdcBase(DataSource.DataSet).Filter.FilterQuery(NULL);
  end
  {$ENDIF}
  else if (Key = VK_F10) and (Shift = []) then
  begin
    if (FInternalMenuKind <> imkNone) and Assigned(FMasterAct) then
      FMasterAct.Execute;
  end
  else if (Key = VK_TAB) and ([ssCtrl] = Shift) and (Owner is TWinControl) then
  begin
    TWinControlCracker(Owner).SelectNext(Self, not (ssShift in Shift), True);
  end
  else begin
    OldSelectedRows := SelectedRows.Count;
    if DataLink.Active then
      OldBm := DataLink.DataSet.Bookmark
    else
      OldBm := '';
    WasEOF := DataLink.Active and DataLink.EOF;
    gsKeyDown(Key, Shift);
    if DataLink.Active then
      NewBm := DataLink.DataSet.Bookmark
    else
      NewBm := '';
    if DataLink.Active then
      if (OldSelectedRows <> SelectedRows.Count)
        or (OldBm <> NewBm)
        or (DataLink.EOF <> WasEOF) then
      begin
        DrawTotals(DataLink.EOF);
      end;
  end;
end;

{
  Если мышкой нажали на CheckBox, необходимо обработать
  его состояние.
}

procedure TgsCustomDBGrid.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  GridCoord: TGridCoord;
  OldActive{, OldCol, OldRow}: Integer;
  SelField, DataField: TField;
  SL, SLSave: TStringList;
  Bm: String;

  // правярае, знаходзіцца мышыны курсор над чэк-боксам, ці не
  function IsInCheckRect: Boolean;
  var
    R: TRect;
    Center: Integer;
  begin
    R := CellRect(GridCoord.X, GridCoord.Y);
    R.Bottom := R.Top + GetDefaultRowHeight + 1;
    Center := ((R.Bottom - R.Top) - CHECK_HEIGHT) div 2;

    with R do
    Result := PtInRect
    (
      Rect(Left + 2, Top + Center, Left + 2 + CHECK_WIDTH, Top + Center + CHECK_HEIGHT),
      Point(X, Y)
    );
  end;
{$IFDEF NEW_GRID}
var OldPseudoRecordsOn: Boolean;
{$ENDIF}
begin
{  OldCol := Col;
  OldRow := Row;}

{  FInternalCanShowEditor := FInternalSetFocus;
  try}
  if Sizing(X, Y) then
  begin
    inherited MouseDown(Button, Shift, X, Y);
    exit;
  end;

  if FShowTotals
    and (Y > ClientHeight)
    and DataLink.Active
    and (DataLink.DataSet is TIBCustomDataSet)
    and (not TIBCustomDataSet(DataLink.DataSet).QSelect.EOF) then
  begin
    DataLink.DataSet.Last;
    inherited MouseDown(Button, Shift, X, Y);
    exit;
  end;

  GridCoord := MouseCoord(X, Y);
//^^^

  if DataLink.Active and (GridCoord.X >= Integer(dgIndicator in Options)) then
    SelField := GetColField(GridCoord.X - Integer(dgIndicator in Options))
  else
    SelField := nil;

  if (Button = mbLeft)
    and (ssDouble in Shift)
    and (GridCoord.Y = Integer(dgTitles in Options) - 1)
    and (DataLink.Active)
    and (DataLink.DataSet.State = dsBrowse)
    and (SelField is TNumericField) then
  begin
    {TODO: unedit 2 MouseDown}

    inherited MouseDown(Button, Shift, X, Y);

    FOldX := MaxInt;
    FOldY := MaxInt;
    exit;
  end;

  FOldX := X;
  FOldY := Y;

  if (Button = mbLeft) and {DataLink.Active and} Assigned(SelField) and FCheckBox.Visible
      and
    IsInCheckRect and (GridCoord.X >= Integer(dgIndicator in Options))
      and
    (GridCoord.Y >= Integer(dgTitles in Options))
      and
    ((SelField = DataLink.DataSet.FindField(FCheckBox.DisplayField))
      or
     (FCheckBox.FirstColumn and ((SelectedIndex = GetFirstVisible(False)) or (dgRowSelect in Options)))
     )
      and
    (

      (InplaceEditor = nil)
        or
      ((InplaceEditor <> nil) and (not InplaceEditor.Visible))
    )
  then begin
    BeginUpdate;
    OldActive := DataLink.ActiveRecord;

    FRestriction := True;

    try

      // Получаем необходиму запись
      DataLink.ActiveRecord := GridCoord.Y - Integer(dgTitles in Options);

      DataField := DataLink.DataSet.FindField(FCheckBox.FieldName);

      if not Assigned(DataField) then
        raise EgsDBGridException.Create('CheckBox data field not found!');

      if FCheckBox.RecordChecked then
      begin
        FCheckBox.DeleteCheck(DataField.DisplayText);
        {$IFDEF GEDEMIN}
        if DataSource.DataSet.InheritsFrom(TgdcBase) and
          not (DataSource.DataSet as TgdcBase).HasSubSet('OnlySelected') then
        begin
          (DataSource.DataSet as TgdcBase).RemoveFromSelectedID(DataField.AsInteger);
        end;
        {$ENDIF}
      end else
      begin
        FCheckBox.AddCheck(DataField.DisplayText);
        {$IFDEF GEDEMIN}
        if DataSource.DataSet.InheritsFrom(TgdcBase) and
          not (DataSource.DataSet as TgdcBase).HasSubSet('OnlySelected') then
        begin
          (DataSource.DataSet as TgdcBase).AddToSelectedID(DataField.AsInteger);
        end;
        {$ENDIF}
      end;

    finally
      // Возвращаем курсор на ранее установленную запись
      DataLink.ActiveRecord := OldActive;

      EndUpdate;

      inherited MouseDown(Button, Shift, X, Y);

      HideEditor;
      FRestriction := False;
    end;

    with GridCoord do
      DrawCell(X, Y, CellRect(X, Y), [gdSelected, gdFocused]);
  end else
  begin
    { TODO :
цель этого кода -- приблизить поведение работы с выделением
нескольких записей к тому, как это происходит во виндоуз }
    if (Button = mbRight) then
    begin
      Move(PChar(SelectedRows)[1 * SizeOf(Integer)], SL, SizeOf(SL));
      SLSave := TStringList.Create;
      try
        SLSave.Assign(SL);
        if not (Assigned(Datasource) and Assigned(Datasource.Dataset)) then
        begin
          inherited MouseDown(Button, Shift, X, Y);
          Exit;
        end;
        Bm := Datasource.Dataset.Bookmark;
        inherited MouseDown(Button, Shift, X, Y);
        if (ssCtrl in Shift) or (SLSave.IndexOf(Datasource.Dataset.Bookmark) > -1) then
        begin
          SL.Assign(SLSave);
          if ssCtrl in Shift then
            Datasource.Dataset.Bookmark := Bm;
        end;
      finally
        SLSave.Free;
      end;
    end else
    begin
      {$IFDEF NEW_GRID} {TODO: unedit 3 MouseDown DataLink}
      if (DataSetIsIBCustom(DataSource)) { and DataLink.Active }
        and (TIBCustomDataSet(DataSource.DataSet).RecordKind
                  in [rkGroup, rkHeader, rkFooter]) then
      begin
        if (ssDouble in Shift) then begin
          Shift := Shift - [ssDouble];
          exit;
        end;
        if (dgEditing in Options) //^^^
          and (GridCoord.Y >= (Integer(dgTitles in Options)))
          and (GridCoord.Y < RowCount) then begin
            X := - 1;
          end;
      end;
      //^^^
      if (DataSetIsIBCustom(DataSource)) then
      with TIBCustomDataSet(DataSource.DataSet) do
      begin
        OldPseudoRecordsOn := PseudoRecordsOn;
        PseudoRecordsOn := True;
        try
          inherited MouseDown(Button, Shift, X, Y);
        finally
         PseudoRecordsOn := OldPseudoRecordsOn;
        end;
      end else
      {$ENDIF}
      inherited MouseDown(Button, Shift, X, Y);

      { TODO : проверять на Frozen? }
      {$IFDEF GEDEMIN}
      if (not (dgTitles in Options)) or (Y > RowHeights[0]) then
        ClampInView(FCurrent);
      {$ENDIF}
    end;
  end;

  {if (Button = mbRight) and
    DataLink.Active and
    (GridCoord.Y < RowCount) then
  begin
    SelectedRows.CurrentRowSelected := True;
  end;}

  //!!??
  if (DataLink.DataSet is TIBCustomDataSet) then
  begin
    FDataSetOpenCounter := TIBCustomdataSet(DataLink.DataSet).OpenCounter;
  end;

  { TODO : может не всегда перерисовывать а только когда надо? }
  DrawTotals(False);

{  finally
    if (not FInternalCanShowEditor) and (Col = OldCol) and (Row = OldRow) then
      //
    else
      FInternalCanShowEditor := FInternalSetFocus;
  end;    }
end;        {  procedure TgsCustomDBGrid.MouseDown  }

procedure TgsCustomDBGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  CellR, HintR, OldR: TRect;
  GridCoord: TGridCoord;
  OldActive: Integer;
  Column: TColumn;
  Value: String;
  ExpandsList: TList;
  MainExpand: TColumnExpand;
  Data: Pointer;

  function RectsSame(R1, R2: TRect): Boolean;
  begin
    Result :=
      (R1.Top = R2.Top) and (R1.Left = R2.Left) and
      (R1.Bottom = R2.Bottom) and (R1.Right = R2.Right)
  end;

begin
  inherited MouseMove(Shift, X, Y);

  if FGridState in [gsRowSizing, gsColSizing, gsRowMoving, gsColMoving] then
    FSettingsModified := True;

  if not Assigned(GridHintWindow) then
    exit;

  {$IFDEF GEDEMIN}
  if Assigned(UserStorage) and
    (not UserStorage.ReadBoolean('Options', 'HintInGrid', True, False)) then
  begin
    exit;
  end;
  {$ENDIF}

  GridCoord := MouseCoord(X, Y);

  with CellRect(GridCoord.X, GridCoord.Y) do
  begin
    CellR.TopLeft := ClientToScreen(TopLeft);
    CellR.BottomRight := ClientToScreen(BottomRight);
  end;

  if DataLink.Active and (GridCoord.X >= Integer(dgIndicator in Options)) then
    Column := Columns[GridCoord.X - Integer(dgIndicator in Options)]
  else
    Column := nil;

  if not Datalink.Editing and Assigned(Column) and Assigned(Column.Field) then
  begin
    if GridCoord.Y - Integer(dgTitles in Options) >= 0 then
    begin
      OldActive := DataLink.ActiveRecord;
      try
        // Получаем необходиму запись
        DataLink.ActiveRecord := GridCoord.Y - Integer(dgTitles in Options);

        if Column.Field is TMemoField then
          Value := Column.Field.AsString
        else
          Value := Column.Field.DisplayText;

        Data := Column;
      finally
        // Возвращаем курсор на ранее установленную запись
        DataLink.ActiveRecord := OldActive;
      end;
    end else begin
      Value := GetFieldCaption(Column.Field);
      Data := Column.Title;
    end;

    ExpandsList := TList.Create;

    try
      GetExpandsList(Column.Field, ExpandsList);
      MainExpand := FindMainExpand(ExpandsList);
    finally
      ExpandsList.Free;
    end;

    if Assigned(MainExpand) then
      HintR := GridHintWindow.CalcNeededRect(CellR.Right - CellR.Left, Value, Data)
    else
      HintR := GridHintWindow.CalcNeededRect(Screen.DesktopWidth, Value, Data);

    if (
        (HintR.Right - HintR.Left > CellR.Right - CellR.Left)
          or
        (HintR.Bottom - HintR.Top > CellR.Bottom - CellR.Top)
      )
        and (Shift = [])
    then begin
      if Assigned(MainExpand) then
        HintR := GridHintWindow.CalcHintRect(CellR.Right - CellR.Left - 6, Value, Data)
      else
        HintR := GridHintWindow.CalcHintRect(Screen.DesktopWidth - 6, Value, Data);

      Inc(HintR.Left, CellR.Left);
      Inc(HintR.Right, CellR.Left);

      if HintR.Right < CellR.Right then
        HintR.Right := CellR.Right;

      HintR.Top := CellR.Top;
      Inc(HintR.Bottom, HintR.Top);

      if HintR.Bottom < CellR.Bottom then
        HintR.Bottom := CellR.Bottom;

      with GridHintWindow do
        OldR := Rect(Left, Top, Left + Width, Top + Height);

      if not RectsSame(HintR, OldR) or not IsWindowVisible(GridHintWindow.Handle) then
      begin
        if not (csDesigning in ComponentState) then
          GridHintWindow.ShowGridHint(HintR, Value, Data);
      end;
    end else
      GridHintWindow.HideGridHint;
  end else
    GridHintWindow.HideGridHint;

  {$IFDEF NEW_GRID}
//   if (GridCoord.X = Integer(dgIndicator in Options))
//     and (GridCoord.Y >=Integer(dgTitles in Options))
//     and (DataSource <> nil)
//     and (not (DataSource.DataSet.State in dsEditModes))
//     and (DataSource.DataSet is TIBCustomDataSet)
//     and (TIBCustomDataSet(DataSource.DataSet).RecordKind in [rkGroup])
//   then
//   begin
//     CellR := CellRect(Col, Row);
//     if (X >= CellR.Left + 2) and (X <= CellR.Left + 12)
//       and (Y >= CellR.Top + 2) and (Y <= CellR.Top + 12) then
//         TIBCustomDataSet(DataSource.DataSet).WrapGroup;
//   end;
  {$ENDIF}

end;

{
  Двойной щелчек - осуществляем расчет размера колонки.
}

procedure TgsCustomDBGrid.ResizeColumns;
var
  SizedColumn: TColumn;
  ExpandsList: TList;
  Main, CurrExpand: TColumnExpand;
  TheField: TField;
  CurrWidth, MaxWidth, CaptionWidth: Integer;
  OldActive: Integer;
  I, J, K: Integer;

begin
  if DataLink.Active then
  begin
    for J := 0 to Columns.Count - 1 do
    begin
      SizedColumn := Columns[J];
      if (not SizedColumn.Visible) then
        Continue;

      if Assigned(SizedColumn) then
      begin
        ExpandsList := TList.Create;

        try
          GetExpandsList(SizedColumn.Field, ExpandsList);
          Main := FindMainExpand(ExpandsList);

          if Assigned(Main) then
            ExpandsList.Remove(Main);

          if
            Assigned(Main) and (Main.LineCount = 1) or not Assigned(Main)
              or
            not FExpandsActive
          then begin
            Canvas.Font := SizedColumn.Font;
            MaxWidth := 0;

            OldActive := DataLink.ActiveRecord;
            try
              for I := 0 to VisibleRowCount - 1 do
              begin
                // Получаем необходиму запись
                DataLink.ActiveRecord := I;

                if SizedColumn.Field <> nil then
                  CurrWidth := Canvas.TextWidth(SizedColumn.Field.DisplayText) + 4
                else
                  CurrWidth := 0;

                if
                  FCheckBox.Visible
                    and
                  (AnsiCompareText(SizedColumn.FieldName, FCheckBox.DisplayField) = 0)
                then
                  CurrWidth := CurrWidth + CHECK_WIDTH + 4;

                if MaxWidth < CurrWidth then
                  MaxWidth := CurrWidth;

                if FExpandsActive then
                  for K := 0 to ExpandsList.Count - 1 do
                  begin
                    CurrExpand := ExpandsList[K];
                    if (ceoAddFieldMultiline in CurrExpand.Options) then Continue;
                    TheField := DataLink.DataSet.FindField(CurrExpand.FieldName);

                    if Assigned(TheField) then
                    begin
                      CurrWidth := Canvas.TextWidth(TheField.DisplayText) + 4;
                      if MaxWidth < CurrWidth then MaxWidth := CurrWidth;
                    end;
                  end;
              end;
            finally
              DataLink.ActiveRecord := OldActive;

              Canvas.Font := SizedColumn.Title.Font;
              CaptionWidth := CountFullCaptionWidth(SizedColumn) + 4;

              if (SizedColumn as TgsColumn).Filterable
                and (SizedColumn.Title.Alignment <> taRightJustify) then
              begin
                CaptionWidth := CaptionWidth + 12; {место для кнопочки автофильтрации}
                if SizedColumn.Title.Alignment = taCenter then
                  CaptionWidth := CaptionWidth + 12; {место для кнопочки автофильтрации}
              end;

              if MaxWidth > CaptionWidth then
                SizedColumn.Width := MaxWidth
              else
                SizedColumn.Width := CaptionWidth;
            end;
          end;
        finally
          ExpandsList.Free;
        end;
      end;
    end;
  end;
end;

procedure TgsCustomDBGrid.DblClick;
var
  SizedColumn: TColumn;
  ExpandsList: TList;
  Main, CurrExpand: TColumnExpand;
  TheField{, SelField}: TField;
  CurrWidth, MaxWidth{, CaptionWidth}: Integer;
  OldActive: Integer;
  I, K: Integer;
  {GridCoord: TGridCoord;}
begin
{  FInternalCanShowEditor := FInternalSetFocus;
  try}

  SizedColumn := nil;
  
  if
    DataLink.Active and Sizing(HitTest.X, HitTest.Y)
      and
    (FSizedIndex >= Integer(dgIndicator in Options))
      and
    (FSizedIndex <= ColCount - 1)
  then begin
    SizedColumn := Columns[FSizedIndex - Integer(dgIndicator in Options)];

    if Assigned(SizedColumn) then
    begin
      ExpandsList := TList.Create;

      try
        GetExpandsList(SizedColumn.Field, ExpandsList);
        Main := FindMainExpand(ExpandsList);

        if Assigned(Main) then
          ExpandsList.Remove(Main);

        if Assigned(Main) and (Main.LineCount = 1) or not Assigned(Main)
            or
          not FExpandsActive
        then begin
          Canvas.Font := SizedColumn.Font;
          MaxWidth := 0;

          OldActive := DataLink.ActiveRecord;
          try
            for I := 0 to VisibleRowCount - 1 do
            begin
              // Получаем необходиму запись
              DataLink.ActiveRecord := I;

              CurrWidth := Canvas.TextWidth(SizedColumn.Field.DisplayText) + 4;

              if FCheckBox.Visible
                and (
                  (FCheckBox.FirstColumn and (SizedColumn.Index = 0))
                  or
                  (AnsiCompareText(SizedColumn.FieldName, FCheckBox.DisplayField) = 0)
                )
              then
                CurrWidth := CurrWidth + CHECK_WIDTH + 4;

              if MaxWidth < CurrWidth then
                MaxWidth := CurrWidth;

              if FExpandsActive then
                for K := 0 to ExpandsList.Count - 1 do
                begin
                  CurrExpand := ExpandsList[K];
                  if (ceoAddFieldMultiline in CurrExpand.Options) then Continue;
                  TheField := DataLink.DataSet.FindField(CurrExpand.FieldName);

                  if Assigned(TheField) then
                  begin
                    CurrWidth := Canvas.TextWidth(TheField.DisplayText) + 4;
                    if MaxWidth < CurrWidth then MaxWidth := CurrWidth;
                  end;
                end;
            end;
          finally
            DataLink.ActiveRecord := OldActive;

            //Canvas.Font := SizedColumn.Title.Font;
            //CaptionWidth := CountFullCaptionWidth(SizedColumn) + 4;

            //if (SizedColumn as TgsColumn).Filterable
            //  and (SizedColumn.Title.Alignment <> taRightJustify) then
            //begin
            //  CaptionWidth := CaptionWidth + 12; {место для кнопочки автофильтрации}
            //  if SizedColumn.Title.Alignment = taCenter then
            //    CaptionWidth := CaptionWidth + 12; {место для кнопочки автофильтрации}
            //end;

            //if MaxWidth > CaptionWidth then
              SizedColumn.Width := MaxWidth
            //else
            //  SizedColumn.Width := CaptionWidth;
          end;
        end;
      finally
        ExpandsList.Free;
      end;
    end;
  end {else
  begin
    GridCoord := MouseCoord(X, Y);

    if (GridCoord.X = -1) or (GridCoord.Y = -1) then
      exit;

    if DataLink.Active and (GridCoord.X >= Integer(dgIndicator in Options)) then
      SelField := GetColField(GridCoord.X - Integer(dgIndicator in Options))
    else
      SelField := nil;

    if SelField <> nil then
    begin
    end;
  end};
   {$IFDEF NEW_GRID}
      if DataLink.Active
        and DataSetIsIBCustom(DataSource)
        and (TIBCustomDataSet(DataSource.DataSet).RecordKind in [rkGroup, rkHeader, rkFooter])
        then
          exit;
   {$ENDIF}
  if SizedColumn = nil then
    inherited DblClick;
{  finally
    FInternalCanShowEditor := FInternalSetFocus;
  end;}
end;  {  --  TgsCustomDBGrid.DblClick  --  }

{
  Запрет на редактирование.
}
{ TODO : DBG9 CanEditShow}
{
function TgsCustomDBGrid.CanEditShow: Boolean;
begin
//  Result := FInternalCanShowEditor and (inherited CanEditShow) and (not FRestriction);
end;}

{
  Рассчитываем кол-во строчек
}

procedure TgsCustomDBGrid.UpdateRowCount;
var
  OldRowCount: Integer;
  NewRowHeight, NewTitleHeight: Integer;
begin
  OldRowCount := RowCount;

  ////////////////////////////
  // Сохраняем размер заглавий

  //////////////////////////////////////////////////////////
  // Устанавливаем свой размер, но учитываем размер заглавий

  NewRowHeight := GetDefaultRowHeight * LineCount;
  NewTitleHeight := GetDefaultTitleRowHeight * CaptionLineCount;

  if DefaultRowHeight <> NewRowHeight then
    inherited DefaultRowHeight := NewRowHeight;

  if
    FTitlesExpanding and FExpandsActive and
    (RowHeights[0] <> NewTitleHeight)
  then
    RowHeights[0] := NewTitleHeight;

  if (RowCount <= Integer(dgTitles in Options)) then
    inherited RowCount := Integer(dgTitles in Options) + 1;

  FixedRows := Integer(dgTitles in Options);
  with DataLink do
    if not Active or (RecordCount = 0) or not HandleAllocated then
      inherited RowCount := 1 + Integer(dgTitles in Options)
    else
    begin
      inherited RowCount := 1000;
      DataLink.BufferCount := VisibleRowCount;
      inherited RowCount := RecordCount + Integer(dgTitles in Options);

      if dgRowSelect in Options then
        TopRow := FixedRows;
    end;

  if OldRowCount <> RowCount then
    Invalidate;
end;

function TgsCustomDBGrid.GetFieldCaption(AField: TField): String;
var
  Column: TColumn;
begin
  Column := ColumnByField(AField);

  if Assigned(Column) then
    Result := Column.Title.Caption
  else if Assigned(AField) then
    Result := AField.DisplayName
  else
    Result := '';

  {$IFDEF LOCALIZATION}
    Result := Translate(Result, Self, False);
  {$ENDIF}
end;

{
  Возвращает полное наименование заглавия колонки.
}

function TgsCustomDBGrid.GetFullCaption(AColumn: TColumn): String;
var
  ExpandsList: Tlist;
  TheField: TField;
  TheColumn: TColumn;
  I: Integer;
  CurrExpand: TColumnExpand;
begin
  if not Assigned(AColumn) or not Assigned(AColumn.Field) then
  begin
    Result := '';
    Exit;
  end;

  Result := AColumn.Title.Caption;
  ExpandsList := TList.Create;

  try
    GetExpandsList(AColumn.Field, ExpandsList);

    for I := 0 to ExpandsList.Count - 1 do
    begin
      CurrExpand := ExpandsList[I];
      TheField := DataLink.DataSet.FindField(CurrExpand.FieldName);

      if Assigned(TheField) then
        TheColumn := ColumnByField(TheField)
      else
        TheColumn := nil;

      if (ceoAddField in CurrExpand.Options) then
      begin
        if Assigned(TheColumn) then
          Result := Result + '\' + TheColumn.Title.Caption
        else if Assigned(TheField) then
          Result := Result + '\' + TheField.DisplayName;
      end;
    end;
  finally
    ExpandsList.Free;
  end;
end;

function TgsCustomDBGrid.CountFullCaptionWidth(AColumn: TColumn): Integer;
var
  I, W: Integer;
  Fields: TList;
  TheField: TField;
begin
  if FTitlesExpanding then
  begin
    Result := 0;

    Fields := TList.Create;
    try
      GetCaptionFields(AColumn, Fields);

      for I := 0 to Fields.Count - 1 do
      begin
        TheField := Fields[I];

        W := Canvas.TextWidth(GetFieldCaption(TheField));
        if W > Result then
          Result := W;
      end;

    finally
      Fields.Free;
    end;

  end else
    Result := Canvas.TextWidth(GetFullCaption(AColumn));
end;

function TgsCustomDBGrid.ExpandExists(AColumn: TColumn): Boolean;
var
  I: Integer;
begin
  for I := 0 to FExpands.Count - 1 do
    if AnsiCompareText(FExpands[I].DisplayField, AColumn.FieldName) = 0 then
    begin
      Result := True;
      Exit;
    end;

  Result := False;
end;

procedure TgsCustomDBGrid.GetCaptionFields(AColumn: TColumn; Fields: TList);
var
  ExpandsList: Tlist;
  TheField: TField;
  I: Integer;
  CurrExpand: TColumnExpand;
begin
  if not Assigned(AColumn) or not Assigned(AColumn.Field) then
    Exit;

  Fields.Add(AColumn.Field);
  ExpandsList := TList.Create;

  try
    GetExpandsList(AColumn.Field, ExpandsList);

    for I := 0 to ExpandsList.Count - 1 do
    begin
      CurrExpand := ExpandsList[I];

      if ceoAddField in CurrExpand.Options then
        TheField := DataLink.DataSet.FindField(CurrExpand.FieldName)
      else
        TheField := nil;

      if Assigned(TheField) then
        Fields.Add(TheField);
    end;
  finally
    ExpandsList.Free;
  end;
end;

procedure TgsCustomDBGrid.GetColumnFields(AColumn: TColumn; Fields: TList);
var
  I: Integer;
  ExpandsList: TList;
  F: TField;
begin
  if not Assigned(AColumn) or not Assigned(AColumn.Field) then
    Exit;

  Fields.Add(AColumn.Field);
  ExpandsList := TList.Create;

  try
    GetExpandsList(AColumn.Field, ExpandsList);

    for I := 0 to ExpandsList.Count - 1 do
    begin
      F := DataLink.DataSet.FindField(TColumnExpand(ExpandsList[I]).FieldName);
      if Assigned(F) and (F <> AColumn.Field) then
        Fields.Add(F);
    end;
  finally
    ExpandsList.Free;
  end;
end;

procedure TgsCustomDBGrid.SetParent(AParent: TWinControl);
var
  LocControl: TControl;
begin
  inherited SetParent(AParent);

  if
    not (csDesigning in ComponentState)
      and
    Assigned(AParent)
  then
  begin
    LocControl := Self;
    while LocControl.Parent <> nil do LocControl := LocControl.Parent;
    FFormName := LocControl.Name;
  end;
end;

function TgsCustomDBGrid.CreateColumns: TDBGridColumns;
begin
  Result := TgsColumns.Create(Self, TgsColumn, False);
end;

{
  Если удаляется объект, убираем ссылку на него.
}

procedure TgsCustomDBGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    {if AComponent = FToolBar then
      FToolBar := nil
    else} if AComponent = FFilteredDataset then
    begin
      FFilteredDataset := nil;
      FOldFiltered := False;
      FOldOnFilterRecord := nil;
    end else
    begin
      if Items <> nil then
        Items.Remove(AComponent);
    end;
  end;
end;

type
  PRectArray = ^TRectArray;
  TRectArray = array[0..MaxListSize div 4] of TRect;

  PIntegerArray = ^TIntegerArray;
  TIntegerArray = array[0..MaxListSize] of Integer;

procedure TgsCustomDBGrid.Paint;
var
  I: Integer;
  X, Y: Integer;
  DrawInfo: TGridDrawInfo;

  Rects, FixedRects: PRectArray;
  PointCount, FixedPointCount: PIntegerArray;

  TotalColCount, TotalRowCount: Integer;
  R: TRect;
  Rgn: hRgn;

  OldBrushColor, OldPenColor: TColor;
  {$IFDEF NEW_GRID}
  OldPseudoRecordsOn: Boolean;
  {$ENDIF}
begin
  if FScaleColumns and FCanScale and DataLink.Active and Assigned(Parent)
    and (not DataLink.Editing) then
  begin
    if FNeedScaleColumns then
    begin
      try
        _CountScaleColumns;
      finally
        FNeedScaleColumns := False;
      end;
      exit;
    end;
  end;

  if (DataLink.Active)
    and (DataLink.DataSet is TIBCustomDataSet)
    and (FDataSetOpenCounter <> TIBCustomdataSet(DataLink.DataSet).OpenCounter) then
  begin
    if (SelectedRows.Count > 0) then
      SelectedRows.Clear;
    FDataSetOpenCounter := TIBCustomdataSet(DataSource.DataSet).OpenCounter;
  end;

  //////////////////////////////////////////////////////////////////
  // Если рисуем окончание таблицы, то необходимо ограничить область
  // переисовки для родительского класса

  if FFinishDrawing and DataLink.Active then
  begin
    // Вычисляем информацию о рисовании
    CalcDrawInfo(DrawInfo);

    Rgn := CreateRectRgn(0, 0, ClientWidth, DrawInfo.Vert.GridBoundary);
    try
      SelectClipRgn(Canvas.Handle, Rgn);
    finally
      DeleteObject(Rgn);
    end;
  end;
  //^^^
      {$IFDEF NEW_GRID} { TODO : ^^^^ DataLink.ActiveRecord в Paint грида }
      if DataSetIsIBCustom(DataSource) then begin
        if TIBCustomDataSet(DataSource.DataSet).GroupSortExist then
          //OldPseudoRecordsOn := TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn;
        TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn := True;
//fm1.Memo1.Lines.Add('Paint start: '+fm1.Q1ORDERKEY.asString+', '//&&&
//        +TIBCustomDataSet(DataSource.DataSet).Dbg1);//&&&
      end;
      {$ENDIF}

  try
    inherited Paint;

    ////////////////////////////////////////////////////////////////////
    // Если используется режим рисования до пределов таблицы вертикально

    if FFinishDrawing and DataLink.Active then
    begin
      OldBrushColor := Canvas.Brush.Color;
      OldPenColor := Canvas.Pen.Color;

      Rgn := CreateRectRgn(0, DrawInfo.Vert.GridBoundary, ClientWidth, DrawInfo.Vert.GridExtent);
      try
        SelectClipRgn(Canvas.Handle, Rgn);
      finally
        DeleteObject(Rgn);
      end;

      // Вычисляем кол-во обрабатываемых колонок и строчек
      TotalRowCount :=
        (ClientHeight - DrawInfo.Vert.GridBoundary) div DefaultRowHeight + 1;
      TotalColCount :=
        ColCount - LeftCol + Integer(dgIndicator in Options);

      // Выделяем память
      GetMem(Rects, Sizeof(TRect) * (TotalColCount + TotalRowCount));
      GetMem(PointCount, SizeOf(Integer) * (TotalColCount + TotalRowCount));

      FillChar(Rects^, Sizeof(TRect) * (TotalColCount + TotalRowCount), 0);
      FillChar(PointCount^, SizeOf(Integer) * (TotalColCount + TotalRowCount), 0);

      if dgIndicator in Options then
      begin
        GetMem(FixedRects, Sizeof(TRect) * (TotalRowCount + 1));
        GetMem(FixedPointCount, SizeOf(Integer) * (TotalRowCount + 1));

        FillChar(FixedRects^, Sizeof(TRect) * (TotalRowCount + 1), 0);
        FillChar(FixedPointCount^, SizeOf(Integer) * (TotalRowCount + 1), 0);
      end else begin
        FixedRects := nil;
        FixedPointCount := nil;
      end;

      try

        ///////////////////////////////////////////////////////
        // Осуществляется определение координат рисования линий
        // таблицы

        X := - Integer(dgColLines in Options) * GridLineWidth;
        Y := DrawInfo.Vert.GridBoundary - 1;

        ///////////////////////////////////////////////////////////////
        // Осуществляем расчет и заполнение массива точек для рисования
        // горизонтальных линий

        for I := 0 to TotalColCount - 1 do
        begin
          if (I = 0) and (dgIndicator in Options) then
            Inc(X, ColWidths[0] + GridLineWidth * Integer(dgColLines in Options))
          else
            Inc(X, ColWidths[LeftCol + I - Integer(dgIndicator in Options)] +
              GridLineWidth * Integer(dgColLines in Options));

          if dgColLines in Options then
          begin
            Rects^[I] := Rect(X, Y, X, ClientHeight);
            PointCount^[I] := 2;
          end;
        end;

        ///////////////////////////////////////////////////////////////
        // Осуществляем расчет и заполнение массива точек для рисования
        // вертикальных линий

        for I := TotalColCount to TotalColCount + TotalRowCount - 1 do
        begin
          Inc(Y, DefaultRowHeight + GridLineWidth * Integer(dgRowLines in Options));

          if dgRowLines in Options then
          begin
            Rects^[I] := Rect(
              ColWidths[0] * Integer(dgIndicator in Options),
              Y,
              X, Y
            );

            PointCount^[I] := 2;
          end;

          /////////////////////////////////////////
          // Если режим полосатости - рисуем полосы

          if FStriped and (not GridStripeProh) then
          begin///////////////////
               // Вычисляем полосу
            if (((I - TotalColCount) + RowCount) mod 2) = 0 then
            begin
              if FMyOdd = skOdd then
                Canvas.Brush.Color := FStripeOdd
              else if FMyOdd = skEven then
                Canvas.Brush.Color := FStripeEven;
            end else begin
              if FMyEven = skOdd then
                Canvas.Brush.Color := FStripeOdd
              else if FMyEven = skEven then
                Canvas.Brush.Color := FStripeEven;
            end;
          end else
            Canvas.Brush.Color := Color;

          ///////////////////////////////
          // Осуществляем рисование полос
          Canvas.FillRect(Rect
          (
            ColWidths[0] * Integer(dgindicator in Options),
            Y - DefaultRowHeight - GridLineWidth * Integer(dgRowLines in Options) +
              Integer(I = TotalColCount),
            X, Y
          ));

          ////////////////////////////////////
          // Осуществляем рисование индикатора
          if dgIndicator in Options then
          begin
            R := Rect(
              0, Y - DefaultRowHeight,
              ColWidths[0], Y
            );

            Canvas.Brush.Color := FixedColor;
            Canvas.FillRect(R);

            if [dgRowLines, dgColLines] * Options = [dgRowLines, dgColLines] then
            begin
              DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
              DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_TOPLEFT);
            end;
          end;
        end;

        //ShowMessage('2');

        if (dgColLines in Options) or (dgRowLines in Options) then
        begin
          Canvas.Pen.Color := clSilver;
          if ColorToRGB(Color) = clSilver then Canvas.Pen.Color := clGray;
        end;

        if dgColLines in Options then
          PolyPolyLine(Canvas.Handle, Rects^, PointCount^, TotalColCount);

        //ShowMessage('3');

        if dgRowLines in Options then
          PolyPolyLine(
            Canvas.Handle,
            PRectArray(Rects)^[TotalColCount],
            PIntegerArray(PointCount)^[TotalColCount],
            TotalRowCount
          );


        //ShowMessage('4');

        ////////////////////////////////////////////////////////////////////////
        // Если используется индикатор, то осуществляем рисование линий для него

        if dgIndicator in Options then
        begin
          Y := DrawInfo.Vert.GridBoundary - 1;

          if dgColLines in Options then
          begin
            FixedRects^[TotalRowCount] := Rect(ColWidths[0], Y, ColWidths[0], ClientHeight);
            FixedPointCount^[TotalRowCount] := 2;
          end;

          if dgRowLines in Options then
            for I := 0 to TotalRowCount - 1 do
            begin
              Inc(Y, DefaultRowHeight + GridLineWidth * Integer(dgRowLines in Options));
              FixedRects^[I] := Rect(0, Y, ColWidths[0], Y);
              FixedPointCount^[I] := 2;
            end;

          Canvas.Pen.Color := clBlack;

          if dgRowLines in Options then
            PolyPolyLine(
              Canvas.Handle,
              FixedRects^,
              FixedPointCount^,
              TotalRowCount + Integer(dgColLines in Options)
            )
          else if dgColLines in Options then
            PolyPolyLine(
              Canvas.Handle,
              PRectArray(FixedRects)^[TotalRowCount],
              PIntegerArray(FixedPointCount)^[TotalRowCount],
              1
            );
        end;{if dgIndicator}

        //ShowMessage('5');

        Canvas.Brush.Color := Color;
        Canvas.FillRect(Rect(
          X + Integer(dgColLines in Options) * GridLineWidth,
          DrawInfo.Vert.GridBoundary,
          ClientWidth,
          ClientHeight)
        );

      finally
        FreeMem(Rects, Sizeof(TRect) * (TotalColCount + TotalRowCount));
        FreeMem(PointCount, SizeOf(Integer) * (TotalColCount + TotalRowCount));

        if dgIndicator in Options then
        begin
          FreeMem(FixedRects, Sizeof(TRect) * (TotalRowCount + 1));
          FreeMem(FixedPointCount, SizeOf(Integer) * (TotalRowCount + 1));
        end;

        Canvas.Brush.Color := OldBrushColor;
        Canvas.Pen.Color := OldPenColor;
      end;
    end;

  finally
    {$IFDEF NEW_GRID}
            OldPseudoRecordsOn := false;
        TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn := OldPseudoRecordsOn;
//     fm1.Memo1.Lines.Add('Paint end: '+fm1.Q1ORDERKEY.asString+', '//&&&
//        +TIBCustomDataSet(DataSource.DataSet).Dbg1);//&&&
    {$ENDIF}
    SelectClipRgn(Canvas.Handle, 0);
  end;
end;

class function TgsCustomDBGrid.GridClassType: TgsDBGridClass;
begin
  Result := TgsDBGrid;
end;

class function TgsCustomDBGrid.GetColumnClass: TgsColumnClass;
begin
  Result := TgsColumn;
end;

{
  **********************
  ***  Private Part  ***
  **********************
}

function TgsCustomDBGrid.GetTableFont: TFont;
begin
  Result := inherited Font;
end;

procedure TgsCustomDBGrid.SetTableFont(const Value: TFont);
begin
  inherited Font := Value;
end;

function TgsCustomDBGrid.GetTableColor: TColor;
begin
  Result := Color;
end;

procedure TgsCustomDBGrid.SetTableColor(const Value: TColor);
begin
  Color := Value;
end;

function TgsCustomDBGrid.GetSelectedFont: TFont;
begin
  Result := FSelectedFont;
end;

procedure TgsCustomDBGrid.SetSelectedFont(const Value: TFont);
begin
  FSelectedFont.Assign(Value);
  if UpdateLock = 0 then Invalidate;
end;

function TgsCustomDBGrid.GetSelectedColor: TColor;
begin
  Result := FSelectedColor;
end;

procedure TgsCustomDBGrid.SetSelectedColor(const Value: TColor);
begin
  if FSelectedColor <> Value then
  begin

    FSelectedColor := Value;
    FHalfSelectedTone := HalfTone(FSelectedColor, clWhite);
    if UpdateLock = 0 then Invalidate;
  end;
end;

function TgsCustomDBGrid.GetTitleFont: TFont;
begin
  Result := inherited TitleFont;
end;

procedure TgsCustomDBGrid.SetTitleFont(const Value: TFont);
begin
  inherited TitleFont := Value;
end;

function TgsCustomDBGrid.GetTitleColor: TColor;
begin
  Result := FixedColor;
end;

procedure TgsCustomDBGrid.SetTitleColor(const Value: TColor);
begin
  FixedColor := Value;
end;

{
  Устанавливается новый источник данных. Необходимо получить
  сведения о настройках.
}

procedure TgsCustomDBGrid.SetDataSource(Value: TDataSource);
begin
  inherited DataSource := Value;
end;

{
  Устанавливается режим полосатой таблицы.
}

procedure TgsCustomDBGrid.SetStriped(const Value: Boolean);
begin
  if Value <> FStriped then
  begin
    FStriped := Value;
    if UpdateLock = 0 then Invalidate;
  end;
end;

{
  Устанавливается цвет первой полосы.
}

procedure TgsCustomDBGrid.SetStripeOdd(const Value: TColor);
begin
  if Value <> FStripeOdd then
  begin
    FStripeOdd := Value;
    if UpdateLock = 0 then Invalidate;
  end;
end;

{
  Устанавливается цвет второй полосы.
}

procedure TgsCustomDBGrid.SetStripeEven(const Value: TColor);
begin
  if Value <> FStripeEven then
  begin
    FStripeEven := Value;
    if UpdateLock = 0 then Invalidate;
  end;
end;

{
  Определяет кол-во линий.
}

function TgsCustomDBGrid.GetLineCount: Integer;
var
  CurrExpand: TColumnExpand;
  CurrField: TField;
  Lines: array of Integer;
  I: Integer;
begin
  Result := 1;
  if (not FExpandsActive) or (not DataLink.Active) or (Assigned(Datalink.DataSet) and (not Datalink.DataSet.Active))  then Exit;

  SetLength(Lines, DataLink.DataSet.FieldCount);

  for I := 0 to Length(Lines) - 1 do Lines[I] := 1;

  for I := FExpands.Count - 1 downto 0 do
  begin
    CurrExpand := FExpands[I];
    CurrField := DataLink.DataSet.FindField(CurrExpand.DisplayName);

    if not Assigned(CurrField) then
    begin
      // Если нет поля на расширенное
      // отображение - удаляем элемент
      FreeAndNil(CurrExpand);
      Continue;
    end else begin
      if ceoMultiline in CurrExpand.Options then
        Lines[CurrField.Index] := CurrExpand.LineCount
      else
        Lines[CurrField.Index] := Lines[CurrField.Index] + CurrExpand.LineCount;
    end;

    if Lines[CurrField.Index] > Result then
      Result := Lines[CurrField.Index];
  end;
end;

function TgsCustomDBGrid.GetCaptionLineCount: Integer;
var
  CurrExpand: TColumnExpand;
  CurrField: TField;
  Lines: array of Integer;
  I: Integer;
begin
  Result := 1;
  if (not FExpandsActive) or (not DataLink.Active) or (Assigned(Datalink.DataSet) and (not Datalink.DataSet.Active))  then Exit;

  SetLength(Lines, DataLink.DataSet.FieldCount);

  for I := 0 to Length(Lines) - 1 do Lines[I] := 1;

  for I := FExpands.Count - 1 downto 0 do
  begin
    CurrExpand := FExpands[I];
    CurrField := DataLink.DataSet.FindField(CurrExpand.DisplayName);

    if not Assigned(CurrField) then
    begin
      // Если нет поля на расширенное
      // отображение - удаляем элемент
      FreeAndNil(CurrExpand);
      Continue;
    end else begin
      if [ceoAddFieldMultiline, ceoAddField] * CurrExpand.Options <> [] then
        Lines[CurrField.Index] := Lines[CurrField.Index] + 1;
    end;

    if Lines[CurrField.Index] > Result then
      Result := Lines[CurrField.Index];
  end;
end;


{
  Возвращает кол-во видимых колонок.
}

function TgsCustomDBGrid.GetVisibleColumnCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  if Assigned(Columns) then
    for I := 0 to Columns.Count - 1 do
      if Columns[I].Visible then Inc(Result);
end;

{
  Устанавливаем настройки расширенного отображения.
}

procedure TgsCustomDBGrid.SetColumnExpands(const Value: TColumnExpands);
begin
  FExpands.Assign(Value);

  if LayoutLock = 0 then
  begin
    BeginLayout;
    try
      UpdateRowCount;
    finally
      EndLayout;
    end;
  end;  
end;

{
  Использовать расширенное отображение или нет
}

procedure TgsCustomDBGrid.SetExpandsActive(const Value: Boolean);
begin
  if FExpandsActive <> Value then
  begin
    FExpandsActive := Value;

    if LayoutLock = 0 then
    begin
      BeginLayout;
      try
        UpdateRowCount;
      finally
        EndLayout;
      end;
    end;
  end;
end;

{
  Использовать резделитель элементов расширенного отображения.
}

procedure TgsCustomDBGrid.SetExpandsSeparate(const Value: Boolean);
begin
  if FExpandsSeparate <> Value then
  begin
    FExpandsSeparate := Value;

    if (UpdateLock = 0) and FExpandsActive then
      Invalidate;
  end;
end;

procedure TgsCustomDBGrid.SetTitlesExpanding(const Value: Boolean);
begin
  if FTitlesExpanding <> Value then
  begin
    FTitlesExpanding := Value;

    if (UpdateLock = 0) and FExpandsActive then
      Invalidate;
  end;
end;

{
  Коллекция условий
}

procedure TgsCustomDBGrid.SetConditions(const Value: TGridConditions);
begin
  FConditions.Assign(Value);
  if FConditionsActive and (UpdateLock = 0) then Invalidate;
end;

{
  Используются ли уловия
}

procedure TgsCustomDBGrid.SetConditionsActive(const Value: Boolean);
begin
  if FConditionsActive <> Value then
  begin
    FConditionsActive := Value;
    if UpdateLock = 0 then Invalidate;
  end;
end;

{
  Устанавливаем значения класса TGridCheckBox.
}

procedure TgsCustomDBGrid.SetCheckBox(const Value: TGridCheckBox);
begin
  FCheckBox.Assign(Value);
end;

{
  Устанавливаем или снимаем режим растягивания колонок.
}

procedure TgsCustomDBGrid.SetScaleColumns(const Value: Boolean);
begin
  if FScaleColumns <> Value then
  begin
    FScaleColumns := Value;

    if (LayoutLock = 0) and FScaleColumns then
      CountScaleColumns;
  end;
end;

{
  Устанавливает минимальный размер колонок.
}

procedure TgsCustomDBGrid.SetMinColWidth(const Value: Integer);
begin
  if FMinColWidth <> Value then
  begin
    FMinColWidth := Value;
    CountScaleColumns;
    LayoutChanged;
  end;
end;

{
  Панель инструментов для данной таблицы
}

procedure TgsCustomDBGrid.SetToolBar(const Value: TToolBar);
begin
end;
(*
begin
  if FToolBar <> Value then
  begin
    if
      Assigned(FToolBar)
        and
      not (csDesigning in ComponentState)
    then
      RemoveActions(FToolBar);

    FToolBar := Value;

    if
      Assigned(FToolBar)
        and
      not (csDesigning in ComponentState)
    then
      SetupActions(FToolBar);
  end;
end;

*)

{
  Заканчивать ли рисование до края таблицы вертикально
}
procedure TgsCustomDBGrid.SetFinishDrawing(const Value: Boolean);
begin
  if Value <> FFinishDrawing then
  begin
    FFinishDrawing := Value;
    if UpdateLock = 0 then Invalidate;
  end;
end;

{
  Создает список действий для таблицы.
}

procedure TgsCustomDBGrid.CreateActionList;

  // Добавляет новое действие
  function NewAction: TAction;
  begin
    Result := TAction.Create(FActionList);
    Result.ActionList := FActionList;
    Result.OnUpdate := OnActionUpdate;
  end;

begin
  FImages.Width := 16;
  FImages.Height := 16;

  FImages.GetResource(rtBitmap, 'ALL', 16, [lrDefaultColor], clOlive);
  FActionList.Images := FImages;

  // Пункт Мастер установок
  if FInternalMenuKind <> imkNone then
  begin
    {$IFDEF GEDEMIN}
    if Assigned(GlobalStorage) and Assigned(IBLogin)
      and ((GlobalStorage.ReadInteger('Options\Policy',
      GD_POL_EDIT_UI_ID, GD_POL_EDIT_UI_MASK, False) and IBLogin.InGroup) <> 0) then
    begin
    {$ENDIF}
      FMasterAct := NewAction;
      FMasterAct.OnExecute := DoShowMaster;
      FMasterAct.ShortCut := VK_F10;
      FMasterAct.Caption := MENU_MASTER;
      FMasterAct.ImageIndex := 76;
      FMasterAct.Hint := MENU_MASTER;
    {$IFDEF GEDEMIN}
    end;
    {$ENDIF}
  end;

  // Пункт Обновить данные
  FRefreshAct := NewAction;
  FRefreshAct.OnExecute := DoOnRefresh;
  FRefreshAct.ShortCut := VK_F5;
  FRefreshAct.Caption := MENU_REFRESH;
  FRefreshAct.ImageIndex := 17;
  FRefreshAct.Hint := MENU_REFRESH;

  // Пункт Найти
  FFindAct := NewAction;
  FFindAct.OnExecute := DoOnFindExecute;
  FFindAct.ShortCut := TextToShortCut('Ctrl+F');
  FFindAct.Caption := MENU_FIND;
  FFindAct.ImageIndex := 23;
  FFindAct.Hint := MENU_FIND;

  // Пункт Найти След
  FFindNextAct := NewAction;
  FFindNextAct.OnExecute := DoOnFindNextExecute;
  FFindNextAct.ShortCut := VK_F3;
  FFindNextAct.Caption := MENU_FINDNEXT;
  FFindNextAct.ImageIndex := 24;
  FFindNextAct.Hint := MENU_FINDNEXT;

  //
  FCopyToClipboardAct := NewAction;
  FCopyToClipboardAct.OnExecute := DoOnCopyToClipboardExecute;
  //FCopyToClipboardAct.ShortCut := ;
  FCopyToClipboardAct.Caption := MENU_COPYTOCLIPBOARD;
  FCopyToClipboardAct.ImageIndex := 10;
  FCopyToClipboardAct.Hint := MENU_COPYTOCLIPBOARD;

  //^^^^^
  {$IFDEF GEDEMIN}
  if (GlobalStorage.ReadInteger('Options\Policy',
    GD_POL_EDIT_UI_ID, GD_POL_EDIT_UI_MASK, False) and IBLogin.InGroup) <> 0 then
  begin
  {$ENDIF}
  FHideColAct := NewAction;
  FHideColAct.OnExecute := DoOnHideColumn;
  FHideColAct.Caption := MENU_HIDECOL;
  FHideColAct.Hint := MENU_HIDECOL;

  {$IFDEF NEW_GRID}
  // пункт Группировать
  FGroupAct := NewACtion;
  FGroupAct.OnExecute := DoOnGroup;
  FGroupAct.Caption := MENU_GROUP;
  FGroupAct.Hint := MENU_GROUP;

  // пункт Группировать
  FUnGroupAct := NewACtion;
  FUnGroupAct.OnExecute := DoOnUnGroup;
  FUnGroupAct.Caption := MENU_UNGROUP;
  FUnGroupAct.Hint := MENU_UNGROUP;

  // пункт Свернуть все группы
  FGroupWrapAct := NewAction;
  FGroupWrapAct.OnExecute := DoOnGroupWrap;          //Ctrl- /
  FGroupWrapAct.ShortCut := TextToShortCut('Ctrl+/');
  FGroupWrapAct.Caption := MENU_GROUPWRAP;
  FGroupWrapAct.Hint := MENU_GROUPWRAP;

  // пункт Развернуть все группы
  FGroupUnWrapAct := NewAction;
  FGroupUnWrapAct.OnExecute := DoOnGroupUnWrap; //Ctrl- *
  //FGroupUnWrapAct.ShortCut := TextToShortCut('Ctrl+*');
  FGroupUnWrapAct.Caption := MENU_GROUPUNWRAP;
  FGroupUnWrapAct.Hint := MENU_GROUPUNWRAP;

  // пункт Свернуть группу   //^^^
  FGroupOneWrapAct := NewAction;
  FGroupOneWrapAct.OnExecute := DoOnGroupOneWrap;       //Ctrl- -
  FGroupOneWrapAct.ShortCut := TextToShortCut('Ctrl+-');
  FGroupOneWrapAct.Caption := MENU_GROUPONEWRAP;
  FGroupOneWrapAct.Hint := MENU_GROUPONEWRAP;

  // пункт Развернуть группу
  FGroupOneUnWrapAct := NewAction;
  FGroupOneUnWrapAct.OnExecute := DoOnGroupOneUnWrap; //Ctrl- +
  //FGroupOneUnWrapAct.ShortCut := TextToShortCut('Ctrl++');
  FGroupOneUnWrapAct.Caption := MENU_GROUPONEUNWRAP;
  FGroupOneUnWrapAct.Hint := MENU_GROUPONEUNWRAP;

  // пункт Следующая группа
  FGroupNextAct := NewAction;
  FGroupNextAct.OnExecute := DoOnGroupNext;             //Ctrl- стрелка вниз
  FGroupNextAct.ShortCut := TextToShortCut('Ctrl+Down');
  FGroupNextAct.Caption := MENU_GROUPNEXT;
  FGroupNextAct.Hint := MENU_GROUPNEXT;

  // пункт Предыдущая группа
  FGroupPriorAct := NewAction;
  FGroupPriorAct.OnExecute := DoOnGroupPrior;           //Ctrl- стрелка вверх
  FGroupPriorAct.ShortCut := TextToShortCut('Ctrl+Up');
  FGroupPriorAct.Caption := MENU_GROUPPRIOR;
  FGroupPriorAct.Hint := MENU_GROUPPRIOR;
  {$ENDIF}

  //
  FInputCaptionAct := NewAction;
  FInputCaptionAct.OnExecute := DoOnInputCaption;
  FInputCaptionAct.Caption := MENU_INPUTCAPTION;
  FInputCaptionAct.Hint := MENU_INPUTCAPTION;

  FFrozeColumnAct := NewAction;
  FFrozeColumnAct.OnExecute := DoOnFrozeColumn;
  FFrozeColumnAct.OnUpdate := DoOnFrozeColumnUpdate;
  FFrozeColumnAct.Caption := MENU_FROZECAPTION;
  FFrozeColumnAct.Hint := MENU_FROZECAPTION;
  {$IFDEF GEDEMIN}
  end;
  {$ENDIF}

  //
  FCancelAutoFilterAct := NewAction;
  FCancelAutoFilterAct.OnExecute := DoOnCancelAutoFilter;
  FCancelAutoFilterAct.Caption := MENU_CANCELAUTOFILTERCAPTION;
  FCancelAutoFilterAct.Hint := MENU_CANCELAUTOFILTERCAPTION;

  // Пункт Панель инструментов
  FPanelAct := NewAction;
  FPanelAct.OnExecute := DoOnPanel;
  FPanelAct.Caption := MENU_PANEL;
  FPanelAct.ImageIndex := -1;
  FPanelAct.Hint := MENU_PANEL;

  // Пункт Предыдущий
  FPrior := NewAction;
  FPrior.OnExecute := DoOnPrior;
  FPrior.Caption := MENU_PRIOR;
  FPrior.ImageIndex := 4;
  FPrior.Hint := MENU_PRIOR;

  // Пункт Последующий
  FNext := NewAction;
  FNext.OnExecute := DoOnNext;
  FNext.Caption := MENU_NEXT;
  FNext.ImageIndex := 5;
  FNext.Hint := MENU_NEXT;

  // Пункт Первый
  FFirst := NewAction;
  FFirst.OnExecute := DoOnFirst;
  FFirst.Caption := MENU_FIRST;
  FFirst.ImageIndex := 3;
  FFirst.Hint := MENU_FIRST;

  // Пункт Последний
  FLast := NewAction;
  FLast.OnExecute := DoOnLast;
  FLast.Caption := MENU_LAST;
  FLast.ImageIndex := 6;
  FLast.Hint := MENU_LAST;

  // Пункт Страница назад
  FPageUp := NewAction;
  FPageUp.OnExecute := DoOnPageUp;
  FPageUp.Caption := MENU_PAGEUP;
  FPageUp.ImageIndex := 7;
  FPageUp.Hint := MENU_PAGEUP;

  // Пункт Страница вперед
  FPageDown := NewAction;
  FPageDown.OnExecute := DoOnPageDown;
  FPageDown.Caption := MENU_PAGEDOWN;
  FPageDown.ImageIndex := 8;
  FPageDown.Hint := MENU_PAGEDOWN;
end;

{
  Создаем внутреннее меню.
}

procedure TgsCustomDBGrid.FullFillMenu(PopupColumn: TColumn;
  APopupMenu: TPopupMenu; Items: TList; const ColumnTitle: Boolean);

var
  MenuItem: TMenuItem;
  {$IFDEF NEW_GRID}
  function GroupSortPresent(): Boolean;
  begin
    Result := (DataSource.DataSet is TIBCustomDataSet)
      and TIBCustomDataSet(DataSource.DataSet).GroupSortExist;
  end;
  function GroupSortRecordKind(): TRecordKind;
  begin
    Result := TIBCustomDataSet(DataSource.DataSet).RecordKind;
  end;
  {$ENDIF}


  // Добавляем элемент в меню
  function AddItem(Group: TMenuItem; S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := S;
    Group.Add(Result);
  end;

begin
  {$IFNDEF GED_LOC_RUS}
  exit;
  {$ENDIF}

  if Assigned(APopupMenu) then
  begin
    // Если нужен разделитель, добавляем его
    if (FInternalMenuKind = imkWithSeparator) and (APopupMenu.Items.Count > 0) then
      Items.Add(AddItem(APopupMenu.Items, '-'));

    if ColumnTitle then
    begin

      if Assigned(FHideColAct) then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FHideColAct;
        Items.Add(MenuItem);
      end;

      if Assigned(FInputCaptionAct) then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FInputCaptionAct;
        Items.Add(MenuItem);
      end;

      if Assigned(FFrozeColumnAct) then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FFrozeColumnAct;
        Items.Add(MenuItem);
      end;

      // Разделитель
      Items.Add(AddItem(APopupMenu.Items, '-'));

      {$IFDEF NEW_GRID} { Заголовок грида }
      if Assigned(FGroupAct) then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupAct;
        Items.Add(MenuItem);
      end;

      if Assigned(FUnGroupAct) and GroupSortPresent then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FUnGroupAct;
        Items.Add(MenuItem);
      end;

      if Assigned(FGroupWrapAct) and GroupSortPresent then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupWrapAct;
        Items.Add(MenuItem);
      end;

      if Assigned(FGroupUnWrapAct) and GroupSortPresent then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupUnWrapAct;
        Items.Add(MenuItem);
      end;
      {$ENDIF}

      if FFilteredDataSet <> nil then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FCancelAutoFilterAct;
        Items.Add(MenuItem);
      end;

      exit;
    end;

    {$IFDEF NEW_GRID}
    // меню для заголовка группы
    if (DataSource <> nil) and (DataSource.DataSet is TIBCustomDataSet)
      and (TIBCustomDataSet(DataSource.DataSet).RecordKind in [rkHeader, rkGroup]) then
    begin
      // пункт Группировать
      if Assigned(FGroupAct) then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupAct;
        Items.Add(MenuItem);
      end;

      // Пункт Обновить данные
      if FRefreshType <> rtNone then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FRefreshAct;
        Items.Add(MenuItem);
      end;

      // Разделитель
      Items.Add(AddItem(APopupMenu.Items, '-'));

      // пункт Свернуть все группы
      if Assigned(FGroupWrapAct) and GroupSortPresent then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupWrapAct;
        Items.Add(MenuItem);
      end;

      // пункт Развернуть все группы
      if Assigned(FGroupUnWrapAct) and GroupSortPresent then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupUnWrapAct;
        Items.Add(MenuItem);
      end;

            // Разделитель
      Items.Add(AddItem(APopupMenu.Items, '-'));

      //^^^
      if Assigned(FGroupOneWrapAct) and GroupSortPresent then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupOneWrapAct;
        MenuItem.Enabled := (GroupSortRecordKind = rkHeader);
        Items.Add(MenuItem);
      end;

      if Assigned(FGroupOneUnWrapAct) and GroupSortPresent  then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupOneUnWrapAct;
        MenuItem.Enabled := (GroupSortRecordKind = rkGroup);        
        Items.Add(MenuItem);
      end;

      // Разделитель
      Items.Add(AddItem(APopupMenu.Items, '-'));

      if Assigned(FGroupNextAct) and GroupSortPresent  then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupNextAct;
        Items.Add(MenuItem);
      end;

      if Assigned(FGroupPriorAct) and GroupSortPresent then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FGroupPriorAct;
        Items.Add(MenuItem);
      end;

      exit;
    end;
    {$ENDIF}


    // Пункт Мастер установок
    if (FInternalMenuKind <> imkNone) and Assigned(FMasterAct) then
    begin
      MenuItem := AddItem(APopupMenu.Items, '');
      MenuItem.Action := FMasterAct;
      Items.Add(MenuItem);
    end;

    if DataLink.Active
      and (FCopyToClipboardAct <> nil) then
    begin
      // Разделитель
      Items.Add(AddItem(APopupMenu.Items, '-'));

      // Скопировать ячейки в буфер
      MenuItem := AddItem(APopupMenu.Items, '');
      MenuItem.Action := FCopyToClipboardAct;
      Items.Add(MenuItem);

      // Разделитель
      Items.Add(AddItem(APopupMenu.Items, '-'));

      // Пункт Обновить данные
      if FRefreshType <> rtNone then
      begin
        MenuItem := AddItem(APopupMenu.Items, '');
        MenuItem.Action := FRefreshAct;
        Items.Add(MenuItem);
      end;

      // Пункт Найти
      MenuItem := AddItem(APopupMenu.Items, '');
      MenuItem.Action := FFindAct;
      Items.Add(MenuItem);

      // Пункт Найти Next
      MenuItem := AddItem(APopupMenu.Items, '');
      MenuItem.Action := FFindNextAct;
      Items.Add(MenuItem);
    end;

    {if Assigned(FToolBar) then
    begin
      // Разделитель
      Items.Add(AddItem(APopupMenu.Items, '-'));

      // Пункт панель инструментов
      MenuItem := AddItem(APopupMenu.Items, '');
      MenuItem.Action := FPanelAct;
      Items.Add(MenuItem);
      FPanelAct.Checked := FToolBar.Visible;
    end;}
  end;
end;

{
  Добавляет кнопки в панель управления.
}

(*
procedure TgsCustomDBGrid.SetupActions(AToolBar: TToolBar);
var
  T: TToolButton;

  // Позиция, куда будет добавлена новая кнопка
  function GetStartPosition: Integer;
  var
    Z: Integer;
  begin
    with AToolBar do
    begin
      Result := 0;
      for Z := 0 to ButtonCount - 1 do
        Inc(Result, Buttons[Z].Width);
    end;
  end;

begin
  AToolBar.Images := FImages;

  if (FInternalMenuKind <> imkNone) and Assigned(FMasterAct) then
  begin
    T := TToolButton.Create(AToolBar);
    AToolBar.InsertControl(T);
    T.Style := tbsButton;
    T.Left := GetStartPosition;
    T.Action := FMasterAct;
    T.Tag := Integer(Self);
  end;

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsButton;
  T.Left := GetStartPosition;
  T.Action := FRefreshAct;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsSeparator;
  T.Left := GetStartPosition;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsButton;
  T.Left := GetStartPosition;
  T.Action := FFindAct;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsButton;
  T.Left := GetStartPosition;
  T.Action := FFindNextAct;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsSeparator;
  T.Left := GetStartPosition;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsButton;
  T.Left := GetStartPosition;
  T.Action := FPrior;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsButton;
  T.Left := GetStartPosition;
  T.Action := FNext;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsButton;
  T.Left := GetStartPosition;
  T.Action := FPageUp;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsButton;
  T.Left := GetStartPosition;
  T.Action := FPageDown;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsButton;
  T.Left := GetStartPosition;
  T.Action := FFirst;
  T.Tag := Integer(Self);

  T := TToolButton.Create(AToolBar);
  AToolBar.InsertControl(T);
  T.Style := tbsButton;
  T.Left := GetStartPosition;
  T.Action := FLast;
  T.Tag := Integer(Self);

  AToolBar.Width := GetStartPosition + T.Width;
end;

{
  Удаляет кнопки из панели управления.
}

procedure TgsCustomDBGrid.RemoveActions(AToolBar: TToolBar);
var
  I: Integer;
begin
  with AToolBar do
  for I := ButtonCount - 1 downto 0 do
    if (Pointer(Buttons[I].Tag) = Self) then
      Buttons[I].Free;
end;

*)

{
  Показывает мастер установок таблицы.
}

procedure TgsCustomDBGrid.DoShowMaster(Sender: TObject);
{$IFDEF GEDEMIN}
var
  Master: TdlgMaster;
begin
  if not (csDesigning in ComponentState) then
  begin
    Master := TdlgMaster.Create(Self, GridClassType, GetColumnClass);
    try
      PrepareMaster(Master);

      if Master.ShowModal = mrOk then
      begin
        if Master.FReset then
        begin
          FDeferedLoading := False;
          FDontLoadSettings := False;
          ValidateColumns;
        end else
          SetupGrid(Master);
        FSettingsModified := True;
      end;

      if Assigned(GlobalStorage) then GlobalStorage.SaveToDatabase;
      if Assigned(UserStorage) then UserStorage.SaveToDatabase;
      if Assigned(CompanyStorage) then CompanyStorage.SaveToDatabase;
      if Assigned(AdminStorage) then AdminStorage.SaveToDatabase;
    finally
      Master.Free;
    end;
  end;
end;
{$ELSE}
begin
end;
{$ENDIF}

{
  Все настройки диалога переносятся в таблицу.
}

{$IFDEF GEDEMIN}
procedure TgsCustomDBGrid.DoApplyMaster(Sender: TObject);
var
  MasterForm: TdlgMaster;
begin
  MasterForm := (Sender as TAction).Owner as TdlgMaster;
  MasterForm.CheckSettings;
  SetupGrid(MasterForm);
end;
{$ENDIF}

{
  Активация диалогового окна поиска.
}

procedure ReEnableControls (DataSet: TDataSet);
begin
while DataSet.ControlsDisabled do
  DataSet.EnableControls;
end;

procedure TgsCustomDBGrid.DoOnFindNextExecute(Sender: TObject);
{$IFDEF GEDEMIN}
const
  OldTime: TDateTime = 0;
var
  FFindDlg: TgsdbGrid_dlgFind;
  bmOrg: TBookmarkStr;
  bmFound: TBookmarkStr;
  Found: Boolean;
  Text, CompareText, CompareText2: String;
  IsMovedToStart: Boolean;
  Fields: TList;
  I: Integer;
  OldCursor: TCursor;
  F: Boolean;
  WasDialog: Boolean;
  S: String;
  {$IFDEF NEW_GRID}
  bmGroup: TBookmarkStr;
  RecHidden: Boolean;
  IBDS: TIBCustomDataSet;
  {$ENDIF}
  procedure ToBookmark(bm: TBookmarkStr);
  begin
   {$IFDEF NEW_GRID}
     if Assigned(IBDS) then IBDS.SetFinding(false);
   {$ENDIF}
    ReEnableControls(DataSource.DataSet);
    if DataSource.DataSet.BookmarkValid(Pointer(bm)) then
      DataSource.DataSet.Bookmark := bm;
    DataSource.DataSet.DisableControls;
    {$IFDEF NEW_GRID}
     if Assigned(IBDS) then IBDS.SetFinding(True);
    {$ENDIF}
  end;
  function FindAtField(CurrField: TField): Boolean;
  begin
    Result := false;

    if not Assigned(CurrField) then exit;

//    VarTypeToDataType(TVarData(V).VType)

    if not (FFindDlg.chbxMatchCase.Checked) then
    begin
      if CurrField.DataType in [ftMemo, ftBlob] then
        CompareText := AnsiUpperCase(CurrField.AsString)
      else
        CompareText := AnsiUpperCase(CurrField.DisplayText);

      if CurrField.DataType in [ftInteger, ftCurrency, ftSmallint, ftWord,
         ftFloat, ftDate, ftTime, ftDateTime, ftLargeint, ftBCD] then
        CompareText2 := AnsiUpperCase(CurrField.AsString)
      else
        CompareText2 := '';
    end else begin
      if CurrField.DataType in [ftMemo, ftBlob] then
        CompareText := CurrField.AsString
      else
        CompareText := CurrField.DisplayText;
      if CurrField.DataType in [ftInteger, ftCurrency, ftSmallint, ftWord,
         ftFloat, ftDate, ftTime, ftDateTime, ftLargeint, ftBCD] then
        CompareText2 := CurrField.AsString
      else
        CompareText2 := '';
    end;

    if not FFindDlg.chbxMatchCase.Checked then
    begin
      CompareText := AnsiUpperCase(CompareText);
      CompareText2 := AnsiUpperCase(CompareText2);
    end;

    if ((FFindDlg.chbxWholeWord.Checked)
      and ((Text = CompareText) or ((CompareText2 > '') and (Text = CompareText2))))
      or  ((not FFindDlg.chbxWholeWord.Checked) and ((AnsiPos(Text, CompareText) > 0)
      or ((CompareText2 > '') and (AnsiPos(Text, CompareText2) > 0))))
    then begin
      Result := True;
      SelectedRows.Clear;
    end;
  end;          {   --  function FindAtField  --  }

begin
  if not DataLink.Active then
    Exit;

  {$IFDEF NEW_GRID}
  RecHidden := false;
  {$ENDIF}

  SelectedRows.Clear;

  FFindDlg := TgsdbGrid_dlgFind.Create(Self);
  Fields := TList.Create;
  try
    FFindDlg.cbFindText.Text := FFindValue;

    if (FFindColumn = nil)
      or (FFindColumn <> ColumnByField(SelectedField))
      or (Now - OldTime > 1 / 24 / 60) then
    begin
      GetColumnFields(ColumnByField(SelectedField), Fields);

      S := '';
      for I := 0 to Fields.Count - 1 do
      begin
        if Assigned(Fields[I]) then begin
          S := S + TField(Fields[I]).DisplayLabel + ', ';
        end;
      end;

      if Length(S) > 2 then
        SetLength(S, Length(S) - 2);
      FFindDlg.Caption := 'Поиск по: ' + S;

      F := FFindDlg.ShowModal = mrOk;
      WasDialog := True;
    end else
    begin
      F := True;
      WasDialog := False;
      GetColumnFields(ColumnByField(SelectedField), Fields);
    end;

    OldTime := Now;

    if F then
    begin
      FFindValue := FFindDlg.cbFindText.Text;
      FFindColumn := ColumnByField(SelectedField);

      Found := False;

      if FFindDlg.chbxMatchCase.Checked then
        Text := FFindDlg.cbFindText.Text
      else
        Text := AnsiUpperCase(FFindDlg.cbFindText.Text);

      bmOrg := DataSource.DataSet.Bookmark;
      DataSource.DataSet.DisableControls;

      IsMovedToStart := False;

      OldCursor := Screen.Cursor;
      Screen.Cursor := crAppStart;
      {$IFDEF NEW_GRID}
      IBDS := nil;
      {$ENDIF}
      try
        {$IFDEF NEW_GRID}
        if DataSetIsIBCustom(DataSource) then begin
          IBDS := TIBCustomDataSet(DataSource.DataSet);
          IBDS.SetFinding(True);
        end;
        {$ENDIF}

        if FFindDlg.rbBegin.Checked and WasDialog then
        begin
          if FFindDlg.rbDown.Checked then
            DataSource.DataSet.First
          else
            DataSource.DataSet.Last;
        end;

        while (GetAsyncKeyState(VK_ESCAPE) shr 1) = 0 do
        begin
          if FFindDlg.rbDown.Checked then
          begin
            DataSource.DataSet.Next;

            if DataSource.DataSet.EOF then
            begin
              ToBookmark(bmOrg);
              if not IsMovedToStart and  (MessageBox(0,
                  'Заданное значение не найдено. Продолжить поиск с начала списка?',
                  'Внимание!',
                  MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = ID_YES)
              then begin
                IsMovedToStart := True;
                DataSource.DataSet.First;
              end else begin
                Break;
              end;
            end; {  --  if DataSource.DataSet.EOF  --  }
          end else begin
            DataSource.DataSet.Prior;

            if DataSource.DataSet.BOF then
            begin
              ToBookmark(bmOrg);
              if not IsMovedToStart and (MessageBox(0,
                  'Заданное значение не найдено. Продолжить поиск с конца списка?',
                  'Внимание!',
                  MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = ID_YES)
              then begin
                IsMovedToStart := True;
                DataSource.DataSet.Last;
              end else begin
                Break;
              end;
            end;  {  --  if DataSource.DataSet.BOF  --  }
          end; { -- if FFindDlg.rbDown.Checked else  -- }

          {$IFDEF NEW_GRID}
          { по псевдозаписям поиск не производится }
          if Assigned(IBDS) then
            RecHidden := (IBDS.RecordKind = rkHiddenRecord);
          if Assigned(IBDS) and (IBDS.RecordKind in [rkRecord, rkHiddenRecord,
            rkHeaderRecord{, rkGroup}]) then
          {$ENDIF}
            for I := 0 to Fields.Count - 1 do begin
              Found := FindAtField(Fields[I]);
              if Found then
                Break;
            end;

          if Found then begin
            bmFound := DataSource.DataSet.Bookmark;
            {$IFDEF NEW_GRID}
            if RecHidden then begin
              while not IBDS.BOF
                  and (IBDS.RecordKind <> rkGroup) do
              begin
                DataSource.DataSet.Prior;
                if IBDS.RecordKind = rkGroup then
                  bmGroup := DataSource.DataSet.Bookmark;
              end;
            end;
            {$ENDIF}
            break;
          end;

        end;       {  --  while (GetAsyncKeyState(VK_ESCAPE) shr 1) = 0  --  }

        if not Found then begin
          ToBookmark(bmOrg);
          MessageBox(Handle,
            'Значение не найдено!',
            'Внимание!',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
          FFindColumn := nil;
        end else begin
         {$IFDEF NEW_GRID}
          IBDS.SetFinding(false);
          if RecHidden then
            if IBDS.BookmarkValid(Pointer(bmGroup)) then begin
              IBDS.Bookmark := bmGroup;
              IBDS.WrapGroup;
            end;
          {$ENDIF}
          ToBookmark(bmFound);
          if bmOrg = DataSource.DataSet.Bookmark then
            MessageBox(Handle,
              'Найдено заданное значение.',
              'Внимание!',
              MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
        end;

      finally
        {$IFDEF NEW_GRID}
        IBDS.SetFinding(false);
        {$ENDIF}
        ReEnableControls(DataSource.DataSet);
        Screen.Cursor := OldCursor;
      end;
    end;
  finally
    FFindDlg.Free;
    Fields.Free;
    {$IFDEF NEW_GRID}
    //Refresh;//??//
    {$ENDIF}
  end;
end;
{$ELSE}
begin
end;
{$ENDIF}

{
  Осуществляет поиск данных в таблице.
}

{
  Обновление данных.

  После полного обновления данных важно вернуть курсор на место.
  Мы запоминаем ИД записи, на которой стоял курсор до удаления
  и ИД следующей за ней записи. После обновления пытаемся найти
  такую запись. Если есть, то все нормально, если ее нет, то ищем
  ИД следующей записи.

  Проблемы, которые остались:

  1. Если и следующая запись будет удалена, то курсор
     станет на первую строку. Как решить непонятно. Запоимнать
     еще один ИД (следующий после следующего), а если и та запись будет
     удалена?

  2. Если выделено несколько записей, то надо запоминать ИД, той на которой стоит курсор
     и ИД следующей, за последней записью в выделенном блоке, в которм стоит кусор.

  3. На время, когда мы запоминаем ИД и бегаем по таблице -- деактивировать
     контролы.

  4. Проверки сделаны не оптимально. В большинстве случаев ИД будет  одно поле,
     а унас оптимизировано под ключи из нескольких полей.
}

{ TODO -oандрэй -cзрабіць : см. выше. }

procedure TgsCustomDBGrid.DoOnRefresh(Sender: TObject);
var
  SelectedFieldName: String;
  SL: TStringList;
  I: Integer;
  {$IFDEF GEDEMIN}
  ID: Integer;
  {$ENDIF}
  BM: TBookmarkStr;
  RC: Integer;
  DS: TDataSet;
begin
  {$IFDEF GEDEMIN}
  ID := -1;
  {$ENDIF}
  RC := 0;

  if DataLink.Active then
    case FRefreshType of
      rtRefresh:
        DataSource.DataSet.Refresh;

      rtCloseOpen:
      begin
        { TODO : этот код надо бы перенести gsIBGrid? }
        if (DataLink.DataSet is TIBDataset) and
          TIBDataSet(DataLink.DataSet).CachedUpdates then
        begin
          // переоткрывать датасет в состоянии cachedUpdates
          // нельзя!
          exit;
        end;

        {$IFDEF GEDEMIN}
        if (DataLink.DataSet is TgdcBase) and
          TgdcBase(DataLink.DataSet).CachedUpdates then
        begin
          // переоткрывать датасет в состоянии cachedUpdates
          // нельзя!
          exit;
        end;
        {$ENDIF}

        if DataLink.DataSet.State in dsEditModes then
        begin
          DataLink.DataSet.Post;
        end;

        DataLink.DataSet.DisableControls;
        try
          SelectedRows.Clear;

          if FRememberPosition then
          begin
            {$IFDEF GEDEMIN}
            if (GDObject <> nil) and (GDObject.Active)
              and (not GDObject.IsEmpty) then
            begin
              ID := GDObject.ID
            end else begin
              ID := -1;
            {$ENDIF}
              { TODO :
даже сохранение количества вытянутых записей не
является гарантией, что курсор станет на туже запись. }
              BM := DataLink.DataSet.Bookmark;
              RC := DataLink.DataSet.RecordCount;
            {$IFDEF GEDEMIN}
            end;
            {$ENDIF}
          end;

          ////////////////////////////////////
          // Сохраняем выделенное в визуальной
          // таблице поле

          if Assigned(SelectedField) then
            SelectedFieldName := SelectedField.FieldName
          else
            SelectedFieldName := '';

          ////////////////////////
          // Обновляем сам запрос
          SL := TStringList.Create;
          try
            DS := DataLink.DataSet;

            for I := 0 to DS.Fields.Count - 1 do
              if not DS.Fields[I].Visible then
                SL.Add(DS.Fields[I].FieldName);

            DS.Close;
            DS.Open;

            FDataSetOpenCounter := TIBCustomdataSet(DataSource.DataSet).OpenCounter;

            for I := 0 to SL.Count -1 do
              DS.FieldByName(SL[I]).Visible := False;

          finally
            SL.Free;
          end;
          //////////////////////////////
          // Восстанавливаем положение в
          // визуальной таблице

          if FRememberPosition then
          begin
            {$IFDEF GEDEMIN}
            if ID <> -1 then
            begin
              if not GDObject.Locate(GDObject.GetKeyField(GDObject.SubType), ID, []) then
              begin
                if Assigned(UserStorage)
                  and (UserStorage.ReadBoolean('Options\Confirmations', 'Other', True, False)) then
                begin
                  MessageBox(Handle,
                    'После перечитывания данных невозможно установить курсор на прежнюю запись.'#13#10 +
                    'Возможно, запись не удовлетворяет текущим условиям фильтрации'#13#10 +
                    'или была удалена другим пользователем, подключенным к этой базе данных.'#13#10#13#10 +
                    'Если Вы не хотите в дальнейшем получать такие предупреждения, отключите'#13#10 +
                    'флаг "Прочие предупреждения" в окне "Опции", вызываемого из пункта "Сервис"'#13#10 +
                    'главного меню.',
                    'Информация',
                    MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
                end;
              end;
            end
            else begin
            {$ENDIF}
              DataLink.DataSet.MoveBy(RC);
              if DataLink.DataSet.BookmarkValid(Pointer(Bm)) then
                DataLink.DataSet.Bookmark := Bm;
            {$IFDEF GEDEMIN}
            end;
            {$ENDIF}
          end;
        finally
          DataLink.DataSet.EnableControls;

          if SelectedFieldName > '' then
            SelectedField := DataLink.DataSet.FindField(SelectedFieldName);
        end;
      end;
    end;
end;

{
  Устанавливам видимость панели управления
}

procedure TgsCustomDBGrid.DoOnPanel(Sender: TObject);
begin
  //FToolBar.Visible := not FPanelAct.Checked;
end;

procedure TgsCustomDBGrid.DoOnPrior(Sender: TObject);
begin
  if DataLink.Active then
    DataSource.DataSet.Prior;
end;

procedure TgsCustomDBGrid.DoOnNext(Sender: TObject);
begin
  if DataLink.Active then
    DataSource.DataSet.Next;
end;

procedure TgsCustomDBGrid.DoOnFirst(Sender: TObject);
begin
  if DataLink.Active then
    DataSource.DataSet.First;
end;

procedure TgsCustomDBGrid.DoOnLast(Sender: TObject);
begin
  if DataLink.Active then
    DataSource.DataSet.Last;
end;

procedure TgsCustomDBGrid.DoOnPageUp(Sender: TObject);
begin
  if DataLink.Active then
    DataLink.DataSet.MoveBy(- VisibleRowCount);
end;

procedure TgsCustomDBGrid.DoOnPageDown(Sender: TObject);
begin
  if DataLink.Active then
    DataLink.DataSet.MoveBy(VisibleRowCount);
end;


{
  Расчет первой полосы.
}

procedure TgsCustomDBGrid.CountStripes(Distance: Integer);
begin
  if (Distance mod 2 <> 0) then
    if FMyOdd = skOdd then
    begin
      FMyOdd := skEven;
      FMyEven := skOdd;
    end else begin
      FMyOdd := skOdd;
      FMyEven := skEven;
    end;
end;

{
  Возвращает список элементов расширенного отображения по
  указанному полю.
}

procedure TgsCustomDBGrid.GetExpandsList(Field: TField; List: TList);
var
  I: Integer;
begin
  List.Clear;
  if not Assigned(Field) then Exit;

  for I := 0 to FExpands.Count - 1 do
    if AnsiCompareText(FExpands[I].DisplayField, Field.FieldName) = 0 then
      List.Add(FExpands[I]);
end;

{
  Осуществляет поиск главного элемента расширенного отображения.
  Главный элемент - элемент для поля отображения, где может быть
  указано, кол-во строк для поля колонки.
}

function TgsCustomDBGrid.FindMainExpand(List: TList): TColumnExpand;
var
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
    if ceoMultiline in TColumnExpand(List[I]).Options then
    begin
      Result := List[I];
      List.Delete(I);
      Exit;
    end;

  Result := nil;
end;

{
  Определяет размер заглавий
}

function TgsCustomDBGrid.GetDefaultRowHeight: Integer;
begin
  if not HandleAllocated then
  begin
    DrawBitmap.Canvas.Font := Font;
    Result := DrawBitmap.Canvas.TextHeight('Wg') + 3;
    if dgRowLines in Options then
      Inc(Result, GridLineWidth);
  end else begin
    Canvas.Font := Font;
    Result := Canvas.TextHeight('Wg') + 3;
    if dgRowLines in Options then
      Inc(Result, GridLineWidth);
  end;
end;

function TgsCustomDBGrid.GetDefaultTitleRowHeight: Integer;
begin
  if not HandleAllocated then
  begin
    DrawBitmap.Canvas.Font := Font;
    Result := DrawBitmap.Canvas.TextHeight('Wg') + 3;
    if dgRowLines in Options then
      Inc(Result, GridLineWidth);
  end else begin
    Canvas.Font := TitleFont;
    Result := Canvas.TextHeight('Wg') + 3;
    if dgRowLines in Options then
      Inc(Result, GridLineWidth);
  end;
end;

{
  Если используется родительских шрифт,
  присваиваем его своим шрифтам.
}

procedure TgsCustomDBGrid.CMParentFontChanged(var Message: TMessage);
begin
  inherited;

  if ParentFont then
  begin
    TableFont := Font;
    TitleFont := Font;

    FSelectedFont.OnChange := nil;
    FSelectedFont.Assign(Font);

    if FSelectedFont.Color = clWindowText then
      FSelectedFont.Color := clHighlightText;

    FSelectedFont.OnChange := DoOnFontChanged;

    if UpdateLock = 0 then Invalidate;
  end;
end;

procedure TgsCustomDBGrid.WMChar(var Message: TWMChar);
var
  DataField: TField;
begin
  if
    (Message.CharCode = VK_SPACE) and DataLink.Active and FCheckBox.Visible
      and
    ((SelectedField = DataLink.DataSet.FindField(FCheckBox.DisplayField))
      or
     (FCheckBox.FirstColumn and ((SelectedIndex = GetFirstVisible(False)) or (dgRowSelect in Options)))
     )
      and
    (

      (InplaceEditor = nil)
        or
      ((InplaceEditor <> nil) and not InplaceEditor.Visible)
    )
  then begin
    BeginUpdate;

    try

      DataField := DataLink.DataSet.FindField(FCheckBox.FieldName);

      if FCheckBox.RecordChecked then
      begin
        FCheckBox.DeleteCheck(DataField.DisplayText);
        {$IFDEF GEDEMIN}
        if DataSource.DataSet.InheritsFrom(TgdcBase) and
          not (DataSource.DataSet as TgdcBase).HasSubSet('OnlySelected') then
        begin
          (DataSource.DataSet as TgdcBase).RemoveFromSelectedID(DataField.AsInteger);
        end;
        {$ENDIF}
      end else
      begin
        FCheckBox.AddCheck(DataField.DisplayText);
        {$IFDEF GEDEMIN}
        if DataSource.DataSet.InheritsFrom(TgdcBase) and
          not (DataSource.DataSet as TgdcBase).HasSubSet('OnlySelected') then
          (DataSource.DataSet as TgdcBase).AddToSelectedID(DataField.AsInteger);
        {$ENDIF}
      end;

    finally
      EndUpdate;
    end;

    DrawCell(Col, Row, CellRect(Col, Row), [gdSelected, gdFocused]);

    DrawTotals(False);
  end else
    inherited;
end;

procedure TgsCustomDBGrid.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TgsCustomDBGrid.WMChangeDisplayFormats(var Message: TWmEraseBkgnd);
var
  I: Integer;
begin
  inherited;

  //
  //  Осуществим установку форматов полей

  if not FBlockFieldSetting then
  begin
    FBlockFieldSetting := True;
    BeginUpdate;
    try
      for I := 0 to Columns.Count - 1 do
      with Columns[I] as TgsColumn do
      begin
        if not Assigned(Field) or (Field.FieldName = '') then
          Continue;
        SetFieldFormat;
      end;
    finally
      FBlockFieldSetting := False;
      EndUpdate;
    end;
  end;
end;

{
  Если изменен какой-либо из шрифтов, то убираем родтельский шрифт.
}

{$IFDEF GEDEMIN}
procedure TgsCustomDBGrid.WMHScroll(var Msg: TWMHScroll);

var
  FI: Integer;

  function FrozenIndex: Integer;
  var
    I: Integer;
  begin
    for I := 0 to Columns.Count - 1 do
    begin
      if Columns[I].Visible and (Columns[I] as TgsColumn).Frozen then
      begin
        Result := I;
        exit;
      end;
    end;
    Result := -1;
  end;

  procedure StepRight;
  var
    I, K, J: Integer;
  begin
    J := 0;
    while (J = 0) and (GetScrollPos(Handle, SB_HORZ) < MaxShortInt) do
    begin
      J := 1;

      for K := Columns.Count - 1 downto 0 do
      begin
        if Columns[K].Visible then
        begin
          break;
        end;
      end;

      for I := FI + 1 to K - 1 do
      begin
        if Columns[I].Visible then
        begin
          Columns[I].Visible := False;
          (Columns[I] as TgsColumn).WasFrozen := True;
          TopLeftMoved(FTopLeft);
          if (Msg.ScrollCode <> SB_RIGHT)
            and (not ((Msg.ScrollCode = SB_THUMBPOSITION) and (Msg.Pos = MaxShortInt))) then
          begin
            exit;
          end;
          J := 0;
        end;
      end;
    end;
  end;

  procedure StepLeft;
  var
    I: Integer;
  begin
    for I := Columns.Count - 1 downto 1 do
    begin
      if (Columns[I] as TgsColumn).WasFrozen then
      begin
        (Columns[I] as TgsColumn).WasFrozen := False;
        Columns[I].Visible := True;
        TopLeftMoved(FTopLeft);
        if (Msg.ScrollCode <> SB_LEFT)
          and (not ((Msg.ScrollCode = SB_THUMBPOSITION) and (Msg.Pos = 0))) then
        begin
          break;
        end;
      end;
    end;
  end;

begin
  FI := FrozenIndex;

  if FI = -1 then
    inherited
  else
  begin
    if Visible and CanFocus and TabStop and not (csDesigning in ComponentState) then
      SetFocus;

    case Msg.ScrollCode of
      SB_LINELEFT, SB_PAGELEFT, SB_LEFT:
        StepLeft;

      SB_LINERIGHT, SB_PAGERIGHT, SB_RIGHT:
        StepRight;

      SB_THUMBPOSITION{,
      SB_THUMBTRACK}:
      begin
        if Msg.Pos < GetScrollPos(Handle, SB_HORZ) then
          StepLeft
        else if Msg.Pos > GetScrollPos(Handle, SB_HORZ) then
          StepRight;
      end;
    end;
  end;
end;
{$ENDIF}

procedure TgsCustomDBGrid.DoOnFontChanged(Sender: TObject);
begin
  ParentFont := False;
end;

{
  Производит расчет растягиваемых колонок.
}

procedure TgsCustomDBGrid.CountScaleColumns;
begin
  FNeedScaleColumns := True;
end;

{
  Возвращает флаг - используется родительский шрифт или нет.
}

function TgsCustomDBGrid.NotParentFont: Boolean;
begin
  Result := not inherited ParentFont;
end;

{ TgsDBGrid }


{
  *********************
  ***  Public Part  ***
  *********************
}


{
  ************************
  ***  Protected Part  ***
  ************************
}


{
  **********************
  ***  Private Part  ***
  **********************
}


{
  ********************************
  ***  Registering Components  ***
  ********************************
}

type
  TDBStringProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TgsDataFieldProperty = class(TDBStringProperty)
  public
    procedure GetValueList(List: TStrings); override;
  end;

{ TDBStringProperty }

function TDBStringProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

procedure TDBStringProperty.GetValueList(List: TStrings);
begin
end;

procedure TDBStringProperty.GetValues(Proc: TGetStrProc);
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

{ TgsDataFieldProperty }

procedure TgsDataFieldProperty.GetValueList(List: TStrings);
var
  DataSource: TDataSource;
  Comp: TPersistent;
begin
  Comp := GetComponent(0);

  if not Assigned(Comp) then Exit;

  if Comp is TGridCheckBox then
    DataSource := (Comp as TGridCheckBox).Grid.DataSource
  else

  if Comp is TCondition then
    DataSource := (Comp as TCondition).Grid.DataSource
  else

  if Comp is TColumnExpand then
    DataSource := (Comp as TColumnExpand).Grid.DataSource
  else

  if Comp is TgsCustomDBGrid then
    DataSource := (Comp as TgsCustomDBGrid).DataSource
  else
    DataSource := nil;

  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
    DataSource.DataSet.GetFieldNames(List);
end;

procedure TgsCustomDBGrid.ValidateColumns;
var
  I, K: Integer;
  C: TColumn;
  M1: TFilterRecordEvent;
  P1: Pointer absolute M1;
  M2: TFilterRecordEvent;
  P2: Pointer absolute M2;
begin
  if (not DataLink.Active) or
    (DataLink.DataSet.State = dsInactive) or
    FRestriction
  then
    Exit;

  FRestriction := True;
  try
    // пересоздание колонок не совместимо с нашим фильтрованием
    if FFilteredDataSet <> nil then
    begin
      M1 := FFilteredDataSet.OnFilterRecord;
      M2 := _OnFilterRecord;

      if P1 = P2 then
      begin
        FFilteredDataSet.OnFilterRecord := FOldOnFilterRecord;
        FFilteredDataSet.Filtered := FOldFiltered;
      end;

      FFilteredDataSet := nil;
      FOldOnFilterRecord := nil;
      FOldFiltered := False;
    end;

    FFilterableColumns.Clear;
    FFilteredColumns.Clear;
    FFilteringColumn := nil;
    if (not FInInputQuery) then
      FreeAndNil(lv);

    with DataLink do
    begin

      //
      //  Проверка колонок без полей

      for I := Columns.Count - 1 downto 0 do
      begin
        if not Assigned(Columns[I].Field) then
          Columns[I].Free;
      end;

      //
      //  Проверка нескольких колонок с одинаковыми полями

      for I := Columns.Count - 1 downto 0 do
      begin
        C := Columns[I];

        for K := I - 1 downto 0 do
          if Columns[K].Field = C.Field then
          begin
            C.Free;
            Break;
          end;
      end;

      //
      //  Добавление недостающих полей

      for I := 0 to DataSet.FieldCount - 1 do
      begin
        C := ColumnByField(DataSet.Fields[I]);
        if not Assigned(C) then
        begin
          C := Columns.Add;
          C.Field := DataSet.Fields[I];
          { TODO : тут бы еще на ShowFieldInGrid проверять }
          if FSettingsLoaded then
            C.Visible := False
          else
            C.Visible := C.Field.Visible and C.Visible;
        end;
      end;
    end;
  finally
    FRestriction := False;
  end;
end;


procedure Register;
begin
  RegisterComponents('gsNew', [TgsDBGrid]);

  RegisterPropertyEditor(TypeInfo(string), TGridCheckBox, 'FieldName', TgsDataFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TGridCheckBox, 'DisplayField', TgsDataFieldProperty);

  RegisterPropertyEditor(TypeInfo(string), TCondition, 'FieldName', TgsDataFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TCondition, 'DisplayFields', TgsDataFieldProperty);

  RegisterPropertyEditor(TypeInfo(string), TColumnExpand, 'FieldName', TgsDataFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TColumnExpand, 'DisplayField', TgsDataFieldProperty);
end;

procedure TgsCustomDBGrid.SetColumnAttributes;
begin
  inherited;
end;

procedure TgsCustomDBGrid.AfterConstruction;
begin
  inherited;

  {$IFDEF GEDEMIN}
  if Assigned(GlobalStorage) and Assigned(IBLogin) then
  begin
    if (IBLogin.InGroup and GlobalStorage.ReadInteger(
      'Options\Policy', GD_POL_EDIT_UI_ID, GD_POL_EDIT_UI_MASK, False)) = 0 then
    begin
      Options := Options - [dgColumnResize];
    end;
  end;
  {$ENDIF}
end;

{ TgsAggregate }

{procedure TgsAggregate.Add(AField: TField; const AUserInteraction: Boolean = True);
var
  Index: Integer;
  Current: TBookmarkStr;
begin
  Current := AField.DataSet.Bookmark;
  if (Length(Current) = 0) or Find(Current, Index) then Exit;
  AddToAggregates(AField);
  FRows.Insert(Index, Current);
  if FInitialRow = '' then FInitialRow := Current;
  TCustomDBGridCracker(FGrid).InvalidateRow(TCustomDBGridCracker(FGrid).Row);
  if AUserInteraction then DoOnChanged;
end;

procedure TgsAggregate.AddToAggregates(AField: TField);
var
  V: Double;
begin
  V := AField.AsFloat;
  FSum := FSum + V;
  FAvg := (FAvg * FCount + V) / (FCount + 1);
  if FMin > V then FMin := V;
  if FMax < V then FMax := V;
  Inc(FCount);
  Inc(FNumCount);
end;

procedure TgsAggregate.Clear(const AUserInteraction: Boolean = True);
begin
  FRows.Clear;
  FSum := 0;
  FAvg := 0;
  FMin := MAXDOUBLE;
  FMax := MINDOUBLE;
  FCount := 0;
  FNumCount := 0;
  if AUserInteraction then
    TCustomDBGridCracker(FGrid).InvalidateCol(FCol);
  FCol := -1;
  FInitialRow := '';
  if AUserInteraction then
    DoOnChanged;
end;

function TgsAggregate.Compare(const Item1, Item2: TBookmarkStr): Integer;
begin
  with TCustomDBGridCracker(FGrid).Datalink.Datasource.Dataset do
    Result := CompareBookmarks(TBookmark(Item1), TBookmark(Item2));
end;

constructor TgsAggregate.Create(AGrid: TgsCustomDBGrid);
begin
  FGrid := AGrid;
  FRows := TStringList.Create;
  FRows.OnChange := StringsChanged;
  FCol := -1;
  FAggregateType := atSum;
  FMin := MAXDOUBLE;
  FMax := MINDOUBLE;
  FSum := 0;
  FAvg := 0;
  FCount := 0;
  FNumCount := 0;
  FMessageShowed := False;
end;

procedure TgsAggregate.Delete(AField: TField; const AUserInteraction: Boolean = True);
var
  Index: Integer;
  Current: TBookmarkStr;
begin
  Current := AField.DataSet.Bookmark;
  if (Length(Current) = 0) or (not Find(Current, Index)) then Exit;
  DeleteFromAggregates(AField);
  FRows.Delete(Index);
  if FRows.Count = 0 then FInitialRow := '';
  TCustomDBGridCracker(FGrid).InvalidateRow(TCustomDBGridCracker(FGrid).Row);
  if AUserInteraction then DoOnChanged;
end;

procedure TgsAggregate.DeleteFromAggregates(AField: TField);
var
  V: Double;
begin
  V := AField.AsFloat;
  FSum := FSum - V;
  if FCount = 1 then FAvg := 0 else
    FAvg := (FAvg * FCount - V) / (FCount - 1);
  if V = FMin then FMin := MAXDOUBLE;
  if V = FMax then FMax := MINDOUBLE;
  Dec(FCount);
  Dec(FNumCount);
end;

destructor TgsAggregate.Destroy;
begin
  FRows.Free;
  if Assigned(pm) then pm.Free;

  inherited;
end;}

(*
procedure TgsAggregate.DoOnChanged;
begin
  { TODO : только чтобы перерисовать итого?? }
  if FGrid.ShowFooter then
    FGrid.DrawTotals;
    //FGrid.Invalidate;

  if Assigned(FOnChanged) and
    (FGrid <> nil) and
    (TCustomDBGridCracker(FGrid).UpdateLock = 0) then FOnChanged(FGrid);
end;

function TgsAggregate.Find(const Item: TBookmarkStr; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  if (Item = FCache) and (FCacheIndex >= 0) then
  begin
    Index := FCacheIndex;
    Result := FCacheFind;
    Exit;
  end;
  Result := False;
  L := 0;
  H := FRows.Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := Compare(FRows[I], Item);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        L := I;
      end;
    end;
  end;
  Index := L;
  FCache := Item;
  FCacheIndex := Index;
  FCacheFind := Result;
end;

function TgsAggregate.GetAggregateText: String;

  function fmt(D: Double): String;
  begin
    if Frac(D) = 0 then
      Result := FloatToStrF(D, ffNumber, 15, 0)
    else
      Result := FloatToStrF(D, ffNumber, 15, 2)
  end;

begin
  if RowsCount = 0 then
  begin
    {if (FGrid = nil) or (FGrid.DataSource = nil) or (FGrid.DataSource.DataSet = nil) then
      Result := ''
    else
      Result := 'Скачано записей: ' + fmt(FGrid.DataSource.DataSet.RecordCount);}
  end else
    case FAggregateType of
      atNone: Result := '';
      atSum: Result := 'Сумма = ' + fmt(FSum);
      atAvg: Result := 'Среднее = ' + fmt(FAvg);
      atMin: if FMin < MAXDOUBLE - 0.01 then Result := 'Минимум = ' + fmt(FMin)
               else Result := 'Нет данных. Повторите выделение группы записей.';
      atMax: if FMax > MINDOUBLE + 0.01 then Result := 'Максимум = ' + fmt(FMax)
               else Result := 'Нет данных. Повторите выделение группы записей.';
      atCount: Result := 'Количество = ' + fmt(FCount);
      atNumCount: Result := 'Чисел = ' + fmt(FNumCount);
    end;
end;

function TgsAggregate.GetRowsCount: Integer;
begin
  Result := FRows.Count;
end;

function TgsAggregate.IndexOf(const Item: TBookmarkStr): Integer;
begin
  if not Find(Item, Result) then
    Result := -1;
end;

procedure TgsAggregate.MenuClicked2(Sender: TObject);
begin
  if Sender is TMenuItem then
  begin
    (Sender as TMenuItem).Checked := True;
    AggregateType := TgsAggregateType((Sender as TMenuItem).Tag);
  end;
end;

procedure TgsAggregate.PopupMenu(const X: Integer = -1; const Y: Integer = -1);

  procedure InitMenuItem(const ACaption: String; const AnAggType: TgsAggregateType);
  var
    mi: TMenuItem;
  begin
    mi := TMenuItem.Create(pm);
    mi.Caption := ACAption;
    if ACaption <> '-' then
    begin
      mi.GroupIndex := 1;
      mi.RadioItem := True;
      mi.OnClick := MenuClicked2;
      mi.Tag := Integer(AnAggType);
      if FAggregateType = AnAggType then mi.Checked := True;
    end;
    pm.Items.Add(mi);
  end;

var
  pt: TPoint;

begin
  if pm = nil then
  begin
    pm := TPopupMenu.Create(nil);
    InitMenuItem('Нет', atNone);
    InitMenuItem('-', atNone);
    InitMenuItem('Сумма', atSum);
    InitMenuItem('Среднее', atAvg);
    InitMenuItem('Минимум', atMin);
    InitMenuItem('Максимум', atMax);
    InitMenuItem('Количество', atCount);
    InitMenuItem('Количество чисел', atNumCount);
  end;

  if (X = -1) and (Y = -1) then
    GetCursorPos(pt)
  else
    pt := Point(X, Y);
  pm.Popup(pt.X, pt.Y);
end;

procedure TgsAggregate.SelectCol(AField: TField);
var
  Bm: TBookmarkStr;
  I: Integer;
begin
  with TCustomDBGridCracker(FGrid) do
  begin
    //BeginUpdate;
    DataLink.DataSet.DisableControls;
    Bm := DataLink.DataSet.Bookmark;
    try
      I := 0;
      DataLink.DataSet.First;
      while not DataLink.DataSet.EOF do
      begin
        Add(AField, False);
        DataLink.DataSet.Next;
        Inc(I);
        if ((I = 1000) or (I = 10000)) and (not FMessageShowed)
          and (I >= DataLink.DataSet.RecordCount) then
        begin
          FMessageShowed := True;
          if MessageDlg('Возможно таблица содержит большой набор данных. Прервать подсчет?',
            mtConfirmation,
            [mbYes, mbNo], 0) = IDYES then
          begin
            FMessageShowed := False;
            Clear;
            break;
          end;
          FMessageShowed := False;
          Application.ProcessMessages;
        end;
      end;
      DoOnChanged;
    finally
      if DataLink.DataSet.BookmarkValid(Pointer(Bm)) then
        DataLink.DataSet.Bookmark := Bm;
      DataLink.DataSet.EnableControls;
      //EndUpdate;
    end;
  end;
end;

procedure TgsAggregate.SetAggregateType(const Value: TgsAggregateType);
begin
  if FAggregateType <> Value then
  begin
    FAggregateType := Value;
    DoOnChanged;
  end;
end;

procedure TgsAggregate.StringsChanged(Sender: TObject);
begin
  FCache := '';
  FCacheIndex := -1;
end;

procedure TgsAggregate.Switch(AField: TField);
begin
  if IndexOf(AField.DataSet.Bookmark) = -1 then Add(AField)
    else Delete(AField);
end;
*)

(*
function TgsCustomDBGrid.GetOnAggregateChanged: TNotifyEvent;
begin
  Result := FAggregate.OnChanged;
end;

procedure TgsCustomDBGrid.SetOnAggregateChanged(const Value: TNotifyEvent);
begin
  FAggregate.OnChanged := Value;
end;
*)

(*
procedure TgsAggregate.Switch2(AField: TField);
var
  OldActive: Integer;
begin
  with TCustomDBGridCracker(FGrid) do
  begin
    OldActive := DataLink.ActiveRecord;
    try
      // Получаем необходимую запись
      DataLink.ActiveRecord := Row - Integer(dgTitles in Options);
      Switch(AField);
    finally
      DataLink.ActiveRecord := OldActive;
    end;
  end;
end;
*)                         

procedure TgsCustomDBGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  GridCoord: TGridCoord;
  SelField: TField;
  CR: TRect;
  C: TgsColumn;
  R: TRect;
  Bm, TempS, DT: String;
  OldFiltered: Boolean;
  Max: Integer;
  I, L: Integer;
  TM: TTextMetric;
  OldCursor: TCursor;
  FlagShowZero: Boolean;
  {$IFDEF NEW_GRID}
  ARect: TRect;
  {$ENDIF}
begin
//  try
  inherited MouseUp(Button, Shift, X, Y);

  if Sizing(X, Y) then
    exit;

  if (DataSource <> nil)
    and (DataSource.DataSet <> nil)
    and (not (DataSource.DataSet.State in dsEditModes))
    and (FOldX = X)
    and (FOldY = Y)
    and (not (ssDouble in Shift)) then
  begin
    GridCoord := MouseCoord(X, Y);

    if (GridCoord.X - Integer(dgIndicator in Options) < 0) or (GridCoord.Y < 0) then
      exit;

    {$IFDEF NEW_GRID}  //^^^

    {$ENDIF}

    if (Button = mbRight)
      and DataLink.Active and (GridCoord.Y < RowCount)
      and (GridCoord.Y >= (Integer(dgTitles in Options)))
      {$IFDEF NEW_GRID}
      and (DataSetIsIBCustom(DataSource))
      and not (TIBCustomDataSet(DataSource.DataSet).RecordKind in [rkGroup, rkHeader])
      {$ENDIF}
    then begin {TODO: unedit 1 MouseUp}
      SelectedRows.CurrentRowSelected := True;
    end;

    if DataLink.Active
      and (GridCoord.X >= Integer(dgIndicator in Options)) then
      SelField := GetColField(GridCoord.X - Integer(dgIndicator in Options))
    else
      SelField := nil;

{$IFDEF NEW_GRID}
    if (Button = mbLeft)
      and (GridCoord.X = Integer(dgIndicator in Options))
      and (GridCoord.Y >=Integer(dgTitles in Options))
      and (DataSource <> nil)
      and (DataSource.DataSet is TIBCustomDataSet)
      and (TIBCustomDataSet(DataSource.DataSet).RecordKind in [rkHeader, rkGroup])
      and (not (DataSource.DataSet.State in dsEditModes))
    then
    begin
      ARect := CellRect(GridCoord.X, GridCoord.Y);
      if (X >= ARect.Left + 2) and (X <= ARect.Left + 12)
        and (Y >= ARect.Top + 2) and (Y <= ARect.Top + 12) then
          TIBCustomDataSet(DataSource.DataSet).WrapGroup;   {TODO: unedit 4 MouseUp DataLink}
      { если последний ряд в гриде то двигаем вверх записи группы }
      if TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn then
      if DataLink.ActiveRecord = DataLink.BufferCount - 1 then
      begin
        I := 0;
        DataLink.DataSet.DisableControls;
        while not DataLink.DataSet.Eof do begin
        DataLink.DataSet.Next;
        Inc(I);
        if (TIBCustomDataSet(DataLink.DataSet).RecordKind <> rkRecord)
          or (I = DataLink.BufferCount - 1) then
            break;
        end;
        DataLink.DataSet.EnableControls;
      end;
      exit;
    end;
{$ENDIF}

    CR := CellRect(GridCoord.X, GridCoord.Y);
    CR.Left := CR.Right - 14;
    CR.Top := CR.Bottom - 14;
    C := Columns[GridCoord.X - Integer(dgIndicator in Options)] as TgsColumn;

    if C.Filterable
      and PtInRect(CR, Point(X, Y))
      and (Button = mbLeft)
      and (dgTitles in Options)
      //and (DataSource <> nil)
      and (DataSource.DataSet is TIBCustomDataSet)
      and (GridCoord.Y = 0) then
    begin

      if EditorMode then
        EditorMode := False;

      with DataSource.DataSet as TIBCustomDataSet do
      begin
        if FFilterDataSetOpenCounter <> OpenCounter then
        begin
          if (not Filtered) and (FFilterableColumns.Count > 0) then
          begin
            for I := 0 to FFilterableColumns.Count - 1 do
              with TgsColumn(FFilterableColumns[I]) do
                if FilteredCache <> nil then
                  FilteredCache.Clear;
            FFilterableColumns.Clear;
          end;
          FFilterDataSetOpenCounter := OpenCounter;
        end;
      end;

      if FFilterableColumns.Count = 0 then
      begin
        for I := 0 to Columns.Count - 1 do
          with Columns[I] as TgsColumn do
          if Filterable then
          begin
            if FilteredCache = nil then
            begin
              FilteredCache := TStringList.Create;
              FilteredCache.Sorted := True;
              FilteredCache.Duplicates := dupIgnore;
            end
            else begin
              FilteredCache.Clear;
              FilteredCache.Sorted := True;
            end;

            FFilterableColumns.Add(Columns[I]);
          end;

        with DataSource.DataSet as TIBCustomDataSet do
        begin
          DisableControls;
          Bm := Bookmark;
          OldFiltered := Filtered;
          OldCursor := Screen.Cursor;
          Screen.Cursor := crHourGlass;
          {$IFDEF GEDEMIN}
          if (UserStorage <> nil) and (not UserStorage.ReadBoolean('Options', 'ShowZero', False, False)) then
            FlagShowZero := True
          else
          {$ENDIF}
            FlagShowZero := False;
          try
            if Filtered then
              Filtered := False;
            Last;
            while not BOF do
            begin
              for I := 0 to FFilterableColumns.Count - 1 do
              begin
                with TgsColumn(FFilterableColumns[I]) do
                if (FilteredCache <> nil) and (FilteredCache.Count < 4000)
                  and (not (Field.DataType in [ftBlob, ftMemo, ftGraphic, ftFmtMemo])) then
                begin
                  DT := Field.DisplayText;
                  if DT > '' then
                  begin
                    if Field is TDateTimeField then
                    begin
                      if Field.AsDateTime < 1 then
                        TempS := FormatDateTime('hh:nn:ss', Field.AsDateTime)
                      else
                        TempS := FormatDateTime('yyyy.mm.dd', Field.AsDateTime)
                    end else
                      TempS := Copy(DT, 1, 40);

                    FilteredCache.Add(TempS);

                    L := Length(TempS);
                    if L > Max then
                      Max := L;
                  end else
                  begin
                    if (not FlagShowZero) and (Field is TNumericField)
                      and (not Field.IsNull) then
                    begin
                      FilteredCache.Add('0');
                    end;
                  end;
                end;
              end;

              Prior;
            end;

            for I := 0 to FFilterableColumns.Count - 1 do
              with TgsColumn(FFilterableColumns[I]) do
                if (FilteredCache <> nil) and (Field is TDateTimeField) then
                begin
                  FilteredCache.Sorted := False;
                  FilteredCache.CustomSort(SortItemsDesc);
                end;
          finally
            Screen.Cursor := OldCursor;
            if Filtered <> OldFiltered then
              Filtered := OldFiltered;
            Bookmark := Bm;
            EnableControls;
          end;
        end;
      end;

      FFilteringColumn := C;

      R := CellRect(GridCoord.X, GridCoord.Y);

      if lv = nil then
      begin
        lv := TgsListBox.Create(Self);
        lv.ParentFont := False;
        lv.ParentColor := False;
        lv.ParentCtl3D := False;
        lv.OnExit := _OnExit;
        lv.OnClick := _OnClick;
        lv.OnMouseDown := _OnMouseDown;
        lv.Parent := Self;
      end;

      GetTextMetrics(lv.Canvas.Handle, TM);

      if C.Max < 18 then Max := 18 else Max := C.Max;
      lv.Width := R.Right - R.Left;
      if lv.Width < (Max * TM.tmAveCharWidth + GetSystemMetrics(SM_CXVSCROLL)) then
        lv.Width := Max * TM.tmAveCharWidth + GetSystemMetrics(SM_CXVSCROLL);
      if lv.Width + R.Left >= Width - GetSystemMetrics(SM_CXVSCROLL) * 2 then
        lv.Width := Width - R.Left - GetSystemMetrics(SM_CXVSCROLL) * 2;
      if (C.FilteredCache <> nil) and (C.FilteredCache.Count < 13) then
        lv.Height := (C.FilteredCache.Count + 5) * 14
      else
        lv.Height := 200;
      if lv.Height + R.Bottom >= Height - 22 then
        lv.Height := Height - R.Bottom - 22;
      lv.Left := R.Left;
      lv.Top := R.Bottom;
      lv.Items.Assign(C.FilteredCache);
      lv.Items.Insert(0, '<Все>');
      lv.Items.Insert(1, '<Пустые>');
      lv.Items.Insert(2, '<Не пустые>');
      if C.Field.DataType in [ftInteger, ftSmallInt, ftWord, ftCurrency, ftBCD, ftLargeInt, ftFloat] then
        lv.Items.Insert(3, '<Не 0 и не пустые>');
      if not (C.Field.DataType in [ftBlob, {ftMemo,} ftGraphic{, ftFmtMemo}]) then
        lv.Items.Insert(1, '<Содержит...>');
      lv.Show;
      lv.SetFocus;
    end
    else if (Button = mbLeft) and
      (dgTitles in Options) and
      (GridCoord.Y = 0) and
      (SelField <> nil) then
    begin
      if (DataSource <> nil)
        and (DataSource.DataSet is TIBCustomDataSet)
        and (not DataSource.DataSet.IsEmpty) then
      begin

        if EditorMode then
          EditorMode := False;

        {$IFDEF NEW_GRID}
        if DataSetIsIBCustom(DataSource) then
          TIBCustomDataSet(DataSource.DataSet).SortGroupSortAtField(C.Field);{~qa~}
        {$ELSE}
        if (C.FieldName = TIBCustomDataSet(DataSource.DataSet).SortField)
          and (TIBCustomDataSet(DataSource.DataSet).SortAscending) then
        begin
          TIBCustomDataSet(DataSource.DataSet).Sort(SelField, False);
        end else
        begin
          if TIBCustomDataSet(DataSource.DataSet).SortField = '' then
            TIBCustomDataSet(DataSource.DataSet).Sort(SelField,
              not (C.Field is TDateTimeField))
          else
            TIBCustomDataSet(DataSource.DataSet).Sort(SelField);
        end;
        {$ENDIF}

        SelectedRows.Clear;
      end;
    end;
  end;
end;

function TgsCustomDBGrid.HighlightCell(DataCol, DataRow: Integer;
  const Value: string; AState: TGridDrawState): Boolean;
begin
  Result := inherited HighlightCell(DataCol, DataRow, Value, AState);
end;

procedure TgsCustomDBGrid.OnActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (DataSource <> nil)
    and (DataSource.DataSet <> nil)
    and (DataSource.DataSet.Active);
end;

function TgsCustomDBGrid.GetCheckBoxEvent: TCheckBoxEvent;
begin
  Result := FCheckBox.FCheckBoxEvent;
end;

procedure TgsCustomDBGrid.SetCheckBoxEvent(Value: TCheckBoxEvent);
begin
  FCheckBox.FCheckBoxEvent := Value;
end;

function TgsCustomDBGrid.GetAfterCheckEvent: TAfterCheckEvent;
begin
  Result := FCheckBox.FAfterCheckEvent;
end;

procedure TgsCustomDBGrid.SetAfterCheckEvent(Value: TAfterCheckEvent);
begin
  FCheckBox.FAfterCheckEvent := Value;
end;

{$IFDEF GEDEMIN}
procedure TgsCustomDBGrid.ClampInView(const Coord: TGridCoord);
var
  DrawInfo: TGridDrawInfo;
  MaxTopLeft: TGridCoord;
  OldTopLeft: TGridCoord;
  I, J, K, _X: Integer;
begin
  if UpdateLock <> 0 then
  begin
    for I := 0 to Columns.Count - 1 do
    begin
      if (Columns[I] as TgsColumn).Frozen then
        exit;
    end;    
    inherited;
  end else
  begin
    if not HandleAllocated then Exit;
    CalcDrawInfo(DrawInfo);
    with DrawInfo, Coord do
    begin
      _X := RawToDataColumn(X);
      if (X > Horz.LastFullVisibleCell) or
        (Y > Vert.LastFullVisibleCell) or (X < LeftCol) or (Y < TopRow) then
      begin
        OldTopLeft := FTopLeft;
        MaxTopLeft := CalcMaxTopLeft(Coord, DrawInfo);
        Update;
        if X < LeftCol then
        begin
          if FTempKey = VK_LEFT then
          begin
            if Columns[_X].Visible
              and (Columns[_X] as TgsColumn).Frozen then
            begin
              for I := Columns.Count - 1 downto _X + 1  do
              begin
                if (Columns[I] as TgsColumn).WasFrozen then
                begin
                  FCurrent.X := DataToRawColumn(I);
                  (Columns[I] as TgsColumn).WasFrozen := False;
                  Columns[I].Visible := True;
                  break;
                end;
              end;
            end;

            FTempKey := 0;

            FTopLeft.X := FCurrent.X;
          end else
            FTopLeft.X := X;
        end
        else if X > Horz.LastFullVisibleCell then
        begin
          J := 0;

          for I := _X - 1 downto 0 do
          begin
            if Columns[I].Visible
              and (Columns[I] as TgsColumn).Frozen then
            begin
              J := 2;
              for K := I + 1 to _X - 1 do
              begin
                if Columns[K].Visible then
                begin
                  Columns[K].Visible := False;
                  (Columns[K] as TgsColumn).WasFrozen := True;
                  J := 1;
                  break;
                end;
              end;
            end;

            if J <> 0 then
              break;
          end;

          if J = 0 then
            FTopLeft.X := MaxTopLeft.X
          else
          begin
            if J = 1 then
            begin
              FTempKey := 0;
              ClampInView(Coord);
            end;  
            exit;
          end;
        end;
        if Y < TopRow then FTopLeft.Y := Y
        else if Y > Vert.LastFullVisibleCell then FTopLeft.Y := MaxTopLeft.Y;
        TopLeftMoved(OldTopLeft);
      end else
      begin
        if X >= FixedCols then
        begin
          if FTempKey = VK_LEFT then
          begin
            if Columns[_X].Visible
              and (Columns[_X] as TgsColumn).Frozen then
            begin
              for I := Columns.Count - 1 downto _X + 1  do
              begin
                if (Columns[I] as TgsColumn).WasFrozen then
                begin
                  FCurrent.X := DataToRawColumn(I);
                  (Columns[I] as TgsColumn).WasFrozen := False;
                  Columns[I].Visible := True;
                  break;
                end;
              end;
            end;

            FTempKey := 0;
          end else
          if FTempKey = VK_RIGHT then
          begin
            for I := _X - 1 downto 0 do
            begin
              if Columns[I].Visible then
              begin
                if (Columns[I] as TgsColumn).Frozen then
                begin
                  for J := _X - 1 downto I + 1 do
                  begin
                    if (Columns[J] as TgsColumn).WasFrozen then
                    begin
                      FCurrent.X := DataToRawColumn(J);
                      (Columns[J] as TgsColumn).WasFrozen := False;
                      Columns[J].Visible := True;
                    end;
                  end;
                end;

                break;
              end;
            end;

            FTempKey := 0;
          end;
        end;
      end;

      if FTempKey = VK_HOME then
      begin
        for I := Columns.Count - 1 downto 0 do
        begin
          if (Columns[I] as TgsColumn).WasFrozen then
          begin
            FCurrent.X := DataToRawColumn(I);
            (Columns[I] as TgsColumn).WasFrozen := False;
            Columns[I].Visible := True;
          end;
        end;

        FTempKey := 0;
      end;
    end;
  end;  
end;

procedure TgsCustomDBGrid.UpdateScrollPos;
var
  DrawInfo: TGridDrawInfo;
  MaxTopLeft: TGridCoord;
  GridSpace, ColWidth: Integer;
  I, J: Integer;

  procedure SetScroll(Code: Word; Value: Integer);
  begin
    if UseRightToLeftAlignment and (Code = SB_HORZ) then
      if ColCount <> 1 then Value := MaxShortInt - Value
      else                  Value := (ColWidth - GridSpace) - Value;
    if GetScrollPos(Handle, Code) <> Value then
      SetScrollPos(Handle, Code, Value, True);
  end;

begin
  if (not HandleAllocated) or (ScrollBars = ssNone) then Exit;
  CalcDrawInfo(DrawInfo);
  MaxTopLeft.X := ColCount - 1;
  MaxTopLeft.Y := RowCount - 1;
  MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
  if ScrollBars in [ssHorizontal, ssBoth] then
    if ColCount = 1 then
    begin
      ColWidth := ColWidths[DrawInfo.Horz.FirstGridCell];
      GridSpace := ClientWidth - DrawInfo.Horz.FixedBoundary;
      if (FColOffset > 0) and (GridSpace > (ColWidth - FColOffset)) then
        ModifyScrollbar(SB_HORZ, SB_THUMBPOSITION, ColWidth - GridSpace, True)
      else
        SetScroll(SB_HORZ, FColOffset)
    end
    else
    begin
      J := 0;
      for I := 0 to Columns.Count - 1 do
      begin
        if (Columns[I] as TgsColumn).WasFrozen then
        begin
          Inc(J);
        end;
      end;

      SetScroll(SB_HORZ, LongMulDiv(FTopLeft.X - FixedCols + J, MaxShortInt,
        MaxTopLeft.X - FixedCols + J));
    end;
  if ScrollBars in [ssVertical, ssBoth] then
    SetScroll(SB_VERT, LongMulDiv(FTopLeft.Y - FixedRows, MaxShortInt,
      MaxTopLeft.Y - FixedRows));
end;

procedure TgsCustomDBGrid.UpdateScrollRange;
var
  MaxTopLeft, OldTopLeft: TGridCoord;
  DrawInfo: TGridDrawInfo;
  OldScrollBars: TScrollStyle;
  Updated: Boolean;

  procedure DoUpdate;
  begin
    if not Updated then
    begin
      Update;
      Updated := True;
    end;
  end;

  function ScrollBarVisible(Code: Word): Boolean;
  var
    Min, Max: Integer;
  begin
    Result := False;
    if (ScrollBars = ssBoth) or
      ((Code = SB_HORZ) and (ScrollBars = ssHorizontal)) or
      ((Code = SB_VERT) and (ScrollBars = ssVertical)) then
    begin
      GetScrollRange(Handle, Code, Min, Max);
      Result := Min <> Max;
    end;
  end;

  procedure CalcSizeInfo;
  begin
    CalcDrawInfoXY(DrawInfo, DrawInfo.Horz.GridExtent, DrawInfo.Vert.GridExtent);
    MaxTopLeft.X := ColCount - 1;
    MaxTopLeft.Y := RowCount - 1;
    MaxTopLeft := CalcMaxTopLeft(MaxTopLeft, DrawInfo);
  end;

  procedure SetAxisRange(var Max, Old, Current: Longint; Code: Word;
    Fixeds: Integer);
  var
    I: Integer;
    F: Boolean;
  begin
    CalcSizeInfo;
    if Fixeds < Max then
      SetScrollRange(Handle, Code, 0, MaxShortInt, True)
    else
    begin
      F := False;
      for I := 0 to Columns.Count - 1 do
      begin
        if (Columns[I] as TgsColumn).WasFrozen then
        begin
          F := True;
          break;
        end;
      end;
      if F then
        SetScrollRange(Handle, Code, 0, MaxShortInt, True)
      else
        SetScrollRange(Handle, Code, 0, 0, True);
    end;
    if Old > Max then
    begin
      DoUpdate;
      Current := Max;
    end;
  end;

  procedure SetHorzRange;
  var
    Range: Integer;
  begin
    if OldScrollBars in [ssHorizontal, ssBoth] then
      if ColCount = 1 then
      begin
        Range := ColWidths[0] - ClientWidth;
        if Range < 0 then Range := 0;
        SetScrollRange(Handle, SB_HORZ, 0, Range, True);
      end
      else
        SetAxisRange(MaxTopLeft.X, OldTopLeft.X, FTopLeft.X, SB_HORZ, FixedCols);
  end;

  procedure SetVertRange;
  begin
    if OldScrollBars in [ssVertical, ssBoth] then
      SetAxisRange(MaxTopLeft.Y, OldTopLeft.Y, FTopLeft.Y, SB_VERT, FixedRows);
  end;

begin
  if (ScrollBars = ssNone) or not HandleAllocated or not Showing then Exit;
  with DrawInfo do
  begin
    Horz.GridExtent := ClientWidth;
    Vert.GridExtent := ClientHeight;
    { Ignore scroll bars for initial calculation }
    if ScrollBarVisible(SB_HORZ) then
      Inc(Vert.GridExtent, GetSystemMetrics(SM_CYHSCROLL));
    if ScrollBarVisible(SB_VERT) then
      Inc(Horz.GridExtent, GetSystemMetrics(SM_CXVSCROLL));
  end;
  OldTopLeft := FTopLeft;
  { Temporarily mark us as not having scroll bars to avoid recursion }
  OldScrollBars := FScrollBars;
  FScrollBars := ssNone;
  Updated := False;
  try
    { Update scrollbars }
    SetHorzRange;
    DrawInfo.Vert.GridExtent := ClientHeight;
    SetVertRange;
    if DrawInfo.Horz.GridExtent <> ClientWidth then
    begin
      DrawInfo.Horz.GridExtent := ClientWidth;
      SetHorzRange;
    end;
  finally
    FScrollBars := OldScrollBars;
  end;
  UpdateScrollPos;
  if (FTopLeft.X <> OldTopLeft.X) or (FTopLeft.Y <> OldTopLeft.Y) then
    TopLeftMoved(OldTopLeft);
end;

{$ENDIF}

procedure TgsCustomDBGrid.Loaded;
begin
  inherited;

  {$IFDEF GEDEMIN}
  if Assigned(GlobalStorage) and Assigned(IBLogin) then
  begin
    if (IBLogin.InGroup and GlobalStorage.ReadInteger(
      'Options\Policy', GD_POL_EDIT_UI_ID, GD_POL_EDIT_UI_MASK, False)) = 0 then
    begin
      Options := Options - [dgColumnResize];
    end;
  end;
  {$ENDIF}
end;

procedure TgsCustomDBGrid.gsKeyDown(var Key: Word; Shift: TShiftState);
var
  I: Integer;
  V: Word;
begin
  if (ssShift in Shift)
    and (Key in [VK_NEXT, VK_PRIOR, VK_HOME, VK_END])
    and DataLink.Active then
  begin
    DataLink.DataSet.DisableControls;
    try
      case Key of
        VK_NEXT:
          begin
            I := 0;
            V := VK_Down;
            while (not DataLink.DataSet.EOF) and (I < VisibleRowCount - 1) do
            begin
              inherited KeyDown(V, Shift);
              Inc(I);
            end;
            Key := 0;
          end;
        VK_PRIOR:
          begin
            I := 0;
            V := VK_UP;
            while (not DataLink.DataSet.BOF) and (I < VisibleRowCount - 1) do
            begin
              inherited KeyDown(V, Shift);
              Inc(I);
            end;
            Key := 0;
          end;
        VK_HOME, VK_END:
          begin
            if (ssCtrl in Shift) or (dgRowSelect in Options) then
            begin
              case Key of
                VK_HOME:
                  begin
                    V := VK_UP;
                    while (not DataLink.DataSet.BOF) do
                      inherited KeyDown(V, [ssShift]);
                  end;
                VK_END:
                  begin
                    V := VK_DOWN;
                    while (not DataLink.DataSet.EOF) do
                      inherited KeyDown(V, [ssShift]);
                  end;
              end;
              Key := 0;
            end;
          end;
      end;
    finally
      DataLink.DataSet.EnableControls;
    end;
  end;

  FTempKey := Key;
  inherited KeyDown(Key, Shift);
end;

procedure TgsCustomDBGrid.KeyPress(var Key: Char);
begin
  if not (dgEditing in Options) and (Key in [#32..#255]) then
  begin
    if not Application.Terminated then
    begin
      FSearchKey := FSearchKey + Key;
      Find;

      if not FPressProcessing then
        ProcessDelay
      else
        FReStartProcessing := True;
    end;    
  end
  else
    inherited;
end;

procedure TgsCustomDBGrid.Find;
var
  BM: String;
begin
  DataLink.DataSet.DisableControls;

  try
    BM := DataLink.DataSet.BookMark;

    if (FSearchLength = 0) or (FSearchLength >= Length(FSearchKey)) then
    begin
      DataLink.DataSet.First;
      FRecNum := 0;
    end;

    while (AnsiPos(AnsiUppercase(FSearchKey), AnsiUppercase(Columns[SelectedIndex].Field.AsString)) <> 1) and
          (FRecNum < DataLink.DataSet.RecordCount) do
    begin
      Inc(FRecNum);
      DataLink.DataSet.Next;
    end;

    if FRecNum = DataLink.DataSet.RecordCount then
    begin
      FSearchKey := '';
      Datalink.Dataset.BookMark := BM;
      //MessageBeep(0);
    end
    else
    begin
      FSearchLength := Length(FSearchKey);
    end;
  finally
    Datalink.Dataset.EnableControls;
  end;
end;

procedure TgsCustomDBGrid.ProcessDelay;
const
  Pause = 2000;
var
  OldTime: LongWord;
begin
  OldTime := GetTickCount;
  FPressProcessing := True;

  while GetTickCount - OldTime <= Pause do
  begin
    Sleep(Pause div 20);
    Application.ProcessMessages;
    if Application.Terminated then
      break;

    // Если введен символ, то все начинаем сначала
    if FReStartProcessing then
    begin
      OldTime := GetTickCount;
      FReStartProcessing := False;
    end;
  end;

  FSearchKey := '';
  FReStartProcessing := False;
  FPressProcessing := False;
end;

{$IFDEF GEDEMIN}
function TgsCustomDBGrid.GetGDObject: TgdcBase;
begin
  if (DataLink.DataSet <> nil) and (DataLink.DataSet is TgdcBase) then
    Result := DataLink.DataSet as TgdcBase
  else
    Result := nil;
end;
{$ENDIF}

function TgsCustomDBGrid.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
var
  Key: Word;
begin
  if (not (csDesigning in ComponentState))
    and Assigned(DataSource)
    and Assigned(DataSource.DataSet)
    and Focused
    {and (DataSource.DataSet.State = dsBrowse)} then
  begin
    Key := VK_DOWN;
    KeyDown(Key, Shift);
  end;
  Result := True;
end;

function TgsCustomDBGrid.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
var
  Key: Word;
begin
  if (not (csDesigning in ComponentState))
    and Assigned(DataSource)
    and Assigned(DataSource.DataSet)
    and Focused
    {and (DataSource.DataSet.State = dsBrowse)} then
  begin
    Key := VK_UP;
    KeyDown(Key, Shift);
  end;
  Result := True;
end;

procedure TgsCustomDBGrid.DragDrop(Source: TObject; X, Y: Integer);
{$IFDEF GEDEMIN}
var
  R: TGridCoord;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  R := Self.MouseCoord(X, Y);
  try
    if (not (Source is TgdcDragObject)) or (TgdcDragObject(Source).SourceControl <> Self) then
      SelectedRows.Clear;
    if (R.Y < RowCount)  and (R.X < ColCount) and
       (R.Y > -1) and (R.X > -1) and (R.Y <> Row) then
      Datasource.Dataset.MoveBy(R.Y - Row);
  except
  end;
  {$ENDIF}

  inherited;
end;

procedure TGridCheckBox.SetFirstColumn(const Value: Boolean);
begin
  if FFirstColumn <> Value then
  begin
    FFirstColumn := Value;

    if Assigned(FOwner) and (FOwner.UpdateLock = 0) then
      FOwner.Invalidate;
  end;
end;

function TgsCustomDBGrid.GetFirstVisible(AddIndicator: Boolean = True): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to Columns.Count - 1 do
    if Columns.Items[I].Visible then
    begin
      Result := I;
      Break;
    end;
  if AddIndicator and (dgIndicator in Options) then
    Result := Result + 1;
end;

procedure TgsCustomDBGrid.TitleClick(Column: TColumn);
begin
  inherited;
end;

procedure TgsCustomDBGrid._OnExit(Sender: TObject);
begin
  (Sender as TWinControl).Hide;
  (Sender as TWinControl).Parent.SetFocus;
  if not FInInputQuery then
    FFilteringColumn := nil;
end;

procedure TgsCustomDBGrid._OnClick(Sender: TObject);
begin
  (Sender as TWinControl).Hide;
  (Sender as TWinControl).Parent.SetFocus;
  FFilteringColumn := nil;
end;

procedure TgsCustomDBGrid._OnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if lv <> nil then
  begin
    with (Sender as TListBox) do
      if ItemIndex >= 0 then
      begin
        if Assigned(FFilteringColumn) then
        begin
          with DataSource.DataSet do
          if Items[ItemIndex] <> '<Все>' then
          begin
            FFilteringColumn.Filtered := True;
            if FFilteredColumns.IndexOf(FFilteringColumn) = -1 then
              FFilteredColumns.Add(FFilteringColumn);
            if Items[ItemIndex] = '<Пустые>' then
              FFilteringColumn.FilteredValue := #8
            else if Items[ItemIndex] = '<Не пустые>' then
              FFilteringColumn.FilteredValue := #9
            else if Items[ItemIndex] = '<Не 0 и не пустые>' then
              FFilteringColumn.FilteredValue := #10
            else if Items[ItemIndex] = '<Содержит...>' then
            begin
              with TdlgFilter_Grid.Create(Self) do
              try
                FInInputQuery := True;
                if ShowModal = mrOk then
                begin
                  if FFilteringColumn.Field is TNumericField then
                    FFilteringColumn.FilteredValue := #11 + StringReplace(cbText.Text, ' ', '', [rfReplaceAll])
                  else
                    FFilteringColumn.FilteredValue := #11 + cbText.Text;
                  {$IFDEF GEDEMIN}
                  if chbxRegExp.Checked then
                  begin
                    if VarIsEmpty(RegExp) then
                    try
                      RegExp := CreateOleObject('VBScript.RegExp');
                      RegExp.IgnoreCase := True;
                      RegExp.Global := True;
                      if FFilteringColumn.Field is TNumericField then
                        RegExp.Pattern := StringReplace(cbText.Text, ' ', '', [rfReplaceAll])
                      else
                        RegExp.Pattern := cbText.Text;
                      RegExp.Test('A');  // проверяем, не введено ли выражение с ошибкой
                    except
                      RegExp := Unassigned;
                    end;
                  end else
                    RegExp := Unassigned;
                  {$ENDIF}
                end else
                begin
                  if not Filtered then
                  begin
                    FFilteredColumns.Extract(FFilteringColumn);
                    FFilteringColumn := nil;
                  end;  
                end;
              finally
                FInInputQuery := False;
                Free;
              end;
            end else
              FFilteringColumn.FilteredValue := Items[ItemIndex];
            if FFilteringColumn <> nil then
            begin
              if FFilteredDataSet <> Self.DataSource.DataSet then
              begin
                FFilteredDataSet := Self.DataSource.DataSet;
                FOldOnFilterRecord := OnFilterRecord;
                FOldFiltered := Filtered;
                OnFilterRecord := _OnFilterRecord;
              end;
              (Sender as TControl).Hide;
              Filtered := True;
              SelectedRows.Clear;
            end;
          end else
          begin
            FFilteringColumn.Filtered := False;
            FFilteredColumns.Extract(FFilteringColumn);
            (Sender as TControl).Hide;
            if FFilteredColumns.Count = 0 then
            begin
              if FFilteredDataSet <> nil then
              begin
                FFilteredDataSet := nil;
                OnFilterRecord := FOldOnFilterRecord;
                Filtered := FOldFiltered;
                FOldOnFilterRecord := nil;
                FOldFiltered := False;
                SelectedRows.Clear;
              end;
            end else
            begin
              Resync([]);
              if FFilteredDataSet is TIBCustomDataSet then
                TIBCustomDataSet(FFilteredDataSet).ResetAllAggs(True, SelectedRows);
            end;
            FFilterDataSetOpenCounter := -1;
          end;
        end;
      end else
      begin
        FFilteredColumns.Extract(FFilteringColumn);
      end;

    FFilteringColumn := nil;
  end;
end;   {  --  procedure TgsCustomDBGrid._OnMouseDown  --  }

procedure TgsCustomDBGrid._OnFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);

  function GetComparableText(F: TField): String;
  begin
    if (F is TNumericField) or (F is TBlobField) then
      Result := F.AsString
    else
      Result := F.DisplayText;
  end;

var
  I: Integer;
 {$IFDEF NEW_GRID}
  DS: TIBCustomDataSet;
  {$ENDIF}
begin
  {$IFDEF NEW_GRID}
  if DataSetIsIBCustom(DataSource) then begin
    DS := TIBCustomDataSet(DataSource.DataSet);
    if (DS.GroupSortFields <> nil) then
      if (DS.GroupSortFields.Count > 0) then
        if   DS.RecordGroupFilterAccept   then // эти записи уже были отобраны
          exit;        // при вызове функции группировки в наборе данных грида
  end;
  {$ENDIF}

  if Assigned(FOldOnFilterRecord) then
  begin
    FOldOnFilterRecord(DataSet, Accept);
    if not Accept then
      exit;
  end;

  for I := 0 to FFilteredColumns.Count - 1 do
    if (FFilteredColumns[I] <> nil) and (TgsColumn(FFilteredColumns[I]).Field <> nil) then
      with TgsColumn(FFilteredColumns[I]) do
      begin
        if FilteredValue = #8 then
        begin
          if not Field.IsNull then
          begin
            Accept := False;
            break;
          end;
        end
        else if FilteredValue = #9 then
        begin
          if Field.IsNull or (Field.AsString = '') then
          begin
            Accept := False;
            break;
          end;
        end else if FilteredValue = #10 then
        begin
          if Field.IsNull or (Field.AsFloat = 0) then
          begin
            Accept := False;
            break;
          end;
        end else if Copy(FilteredValue, 1, 1) = #11 then
        begin
          {$IFDEF GEDEMIN}
          if VarIsEmpty(RegExp) then
          begin
            if AnsiPos(AnsiUpperCase(Copy(FilteredValue, 2, 1024)),
              AnsiUpperCase(GetComparableText(Field))) = 0 then
            begin
              Accept := False;
              break;
            end;
          end else
          begin
            RegExp.Pattern := Copy(FilteredValue, 2, 1024);
            try
              if not RegExp.Test(GetComparableText(Field)) then
              begin
                Accept := False;
                break;
              end;
            except
              RegExp := Unassigned;
            end;
          end;
          {$ELSE}
          if AnsiPos(AnsiUpperCase(Copy(FilteredValue, 2, 1024)),
            AnsiUpperCase(Field.DisplayText)) = 0 then
          begin
            Accept := False;
            break;
          end;
          {$ENDIF}
        end else if Field is TDateTimeField then
        begin
          if ((Field.AsDateTime > 1) and (FormatDateTime('yyyy.mm.dd', Field.AsDateTime) <> FilteredValue))
            or ((Field.AsDateTime < 1) and (FormatDateTime('hh:nn:ss', Field.AsDateTime) <> FilteredValue)) then
          begin
            Accept := False;
            break;
          end;
        end else if (Field is TBlobField) and (FilteredValue = '') then
        begin
          if not Field.IsNull then
          begin
            Accept := False;
            break;
          end;
        end else if (Copy(Field.DisplayText{AsString}, 1, 40) <> FilteredValue) then
        begin
          Accept := False;
          break;
        end;
      end;
end;       {  --  procedure TgsCustomDBGrid._OnFilterRecord  --  }

procedure TgsCustomDBGrid.DoExit;
begin
  inherited;
  if (lv <> nil) and (not FInInputQuery) then
    FreeAndNil(lv);
end;

function TgsCustomDBGrid.GetClientRect: TRect;
begin
  Result := inherited GetClientRect;
  if FShowTotals {and (DataSource <> nil) and (DataSource.DataSet <> nil)
    and (not DataSource.DataSet.IsEmpty)} then
    Result.Bottom := Result.Bottom - DefaultRowHeight;
  {$IFDEF NEW_GRID}
    if ( DataSetIsIBCustom(DataSource)
      and TIBCustomDataSet(DataSource.DataSet).GroupSortExist ) then
        exit;
  {$ENDIF}
  if FShowFooter then
    Result.Bottom := Result.Bottom - DefaultRowHeight;
end;

procedure TgsCustomDBGrid.SetShowTotals(const Value: Boolean);
begin
  if FShowTotals <> Value then
  begin
    FShowTotals := Value;
    Invalidate;
  end;
end;

procedure TgsCustomDBGrid.DrawTotals(const ForceDraw: Boolean = True);
const
  OldSelectedRows: Integer = -1;
  OldAggregates: String = '<<!>>';
var
  TheField: TField;
  R: TRect;
  I, J, SR: Integer;
  DrawInfo: TGridDrawInfo;
  A: TgdcAggregate;
  S, V: String;
  bInAggregates: boolean;
begin
  if FInDrawTotals then
    exit;

  FInDrawTotals := True;
  try
    // малюем страку "агулам"
    if (DataSource = nil) or (DataSource.DataSet = nil) then
      exit;

    { TODO : вставить проверку, а не выполнять эти действия каждый раз! }
    CalcDrawInfo(DrawInfo);

    R := ClientRect;
    R.Left := DrawInfo.Horz.FixedBoundary;
    R.Right := R.Left;
    R.Top := R.Bottom;
    R.Bottom := R.Bottom + DefaultRowHeight;

    if FShowTotals then
    begin
      if (DataSource.DataSet is TIBCustomDataSet) and (DataSource.DataSet.Active) then
      begin
        with DataSource.DataSet as TIBCustomDataSet do
        begin
          if Aggregates.Count = 0 then
          begin
            AggregatesActive := True;
            for I := 0 to Columns.Count - 1 do
              if Columns[I].Visible
                and ((Columns[I] as TgsColumn).TotalType = ttSum)
                and (Columns[I].Field <> nil) and (Columns[I].Field.DataType in
                  [ftSmallInt, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftLargeInt]) then
              begin
                A := Aggregates.Add;
                A.DataType := Columns[I].Field.DataType;
                A.Expression := Columns[I].Field.FieldName;
              end;
            ResetAllAggs(True, SelectedRows);
          end else if AggregatesObsolete or (SelectedRows.Count > 1) or (OldSelectedRows <> SelectedRows.Count) then
          begin
            ResetAllAggs(True, SelectedRows);
            OldSelectedRows := SelectedRows.Count;
          end;
        end;

        S := '';
        with DataSource.DataSet as TIBCustomDataSet do
          for I := 0 to Aggregates.Count - 1 do
          begin
            if not VarIsNull(Aggregates[I].Value) then
              S := S + VarAsType(Aggregates[I].Value, varString);
          end;
      end;

      if ForceDraw or (S <> OldAggregates) or Assigned(FOnGetTotal) then
      begin
        OldAggregates := S;

        Canvas.Brush.Color := clActiveCaption;
        Canvas.Brush.Style := bsSolid;
        Canvas.FillRect(Rect(ClientRect.Left, R.Top, R.Left, R.Bottom));

        for I := (LeftCol - Integer(dgIndicator in Options)) to Columns.Count - 1 do
        begin
          if not Assigned(Columns[I]) then
            continue;

          if R.Left >= DrawInfo.Horz.GridBoundary then
            break;

          if not Columns[I].Visible then
            continue;

          bInAggregates:= False;

          R.Right := R.Left + Columns[I].Width;
          Canvas.FillRect(R);

          TheField := Columns[I].Field;

          if TheField <> nil then
          begin
            if Assigned(FOnGetTotal) then
            begin
              S := '';

              if (DataSource.DataSet is TIBCustomDataSet) then
                if TIBCustomDataSet(DataSource.DataSet).QSelect.EOF or (SelectedRows.Count > 1) then
                  with DataSource.DataSet as TIBCustomDataSet do begin
                    for J := 0 to Aggregates.Count - 1 do
                      if AnsiCompareText(Aggregates[J].Expression, TheField.FieldName) = 0 then begin
                        S := FormatFloat('#,###.##', Aggregates[J].Value);
                        bInAggregates:= True;
                        Break;
                      end;
                  end;

              FOnGetTotal(Self, TheField.FullName, bInAggregates, S);
              if S > '' then
              begin
                Canvas.Font := Self.TableFont;
                Canvas.Font.Color := clCaptionText;
                if Canvas.TextWidth(S) > (R.Right - R.Left - 4) then
                  S := '########';
                WriteText
                (
                  Canvas,
                  R,
                  R,
                  2, 2,
                  S,
                  TheField.Alignment,
                  UseRightToLeftAlignmentForField(TheField, TheField.Alignment),
                  True
                );
              end;
            end else
            begin
              if (DataSource.DataSet is TIBCustomDataSet) then
              begin
                if TIBCustomDataSet(DataSource.DataSet).QSelect.EOF or (SelectedRows.Count > 1) then
                  with DataSource.DataSet as TIBCustomDataSet do
                begin
                  for J := 0 to Aggregates.Count - 1 do
                    if AnsiCompareText(Aggregates[J].Expression, TheField.FieldName) = 0 then
                    begin
                      Canvas.Font := Self.TableFont;
                      Canvas.Font.Color := clCaptionText;

                      V := FormatFloat('#,###.##', Aggregates[J].Value);

                      if Canvas.TextWidth(V) > (R.Right - R.Left - 4) then
                        V := '########';

                      WriteText
                      (
                        Canvas,
                        R,
                        R,
                        2, 2,
                        V,
                        TheField.Alignment,
                        UseRightToLeftAlignmentForField(TheField, TheField.Alignment),
                        True
                      );
                    end;
                end
                else if (Columns[I] as TgsColumn).TotalType = ttSum then
                begin
                  Canvas.Font := Self.TableFont;
                  Canvas.Font.Color := clCaptionText;

                  WriteText
                  (
                    Canvas,
                    R,
                    R,
                    2, 2,
                    'Расcчитать...',
                    TheField.Alignment,
                    UseRightToLeftAlignmentForField(TheField, TheField.Alignment),
                    True
                  );
                end;
              end;
            end;
          end;

          Canvas.Pen.Color := clCaptionText;
          Canvas.Pen.Style := psSolid;
          Canvas.MoveTo(R.Right, R.Top);
          Canvas.LineTo(R.Right, R.Bottom);

          R.Left := R.Right + 1;
        end;
      end;

      Canvas.Brush.Color := Color;
      Canvas.FillRect(
        Rect(DrawInfo.Horz.GridBoundary, R.Top, ClientRect.Right, R.Bottom));

      {$IFDEF NEW_GRID}
      if not ( (DataSource.DataSet is TIBCustomDataSet)
        and TIBCustomDataSet(DataSource.DataSet).GroupSortExist ) then
      {$ENDIF}
      if FShowFooter then
      begin
        Inc(R.Bottom, DefaultRowHeight);
        Inc(R.Top, DefaultRowHeight);
      end;
    end;

    {$IFDEF NEW_GRID}
    if not ( (DataSource.DataSet is TIBCustomDataSet)
      and TIBCustomDataSet(DataSource.DataSet).GroupSortExist ) then
    {$ENDIF}
    if FShowFooter and DataSource.DataSet.Active then
    begin
      R := Rect(ClientRect.Left, R.Top, DrawInfo.Horz.GridBoundary - 1, R.Bottom);

      Canvas.Brush.Color := Color;
      Canvas.FillRect(
        Rect(DrawInfo.Horz.GridBoundary, R.Top, ClientRect.Right, R.Bottom));

      Canvas.Brush.Color := clActiveCaption;
      Canvas.Pen.Color := clCaptionText;
      Canvas.Font := Self.TableFont;
      Canvas.Font.Color := clCaptionText;
      Canvas.FillRect(R);

      if SelectedRows.Count > 0 then
        SR := SelectedRows.Count
      else if DataSource.DataSet.RecordCount = 0 then
        SR := 0
      else
        SR := 1;

      if DataSource.DataSet.Filtered and (DataSource.DataSet.RecordCount > 100) then
        S := Format('Извлечено записей: %d, Выделено записей: %d',
          [DataSource.DataSet.RecordCount, SR])
      else
        S := Format('Извлечено записей: %d, Выделено записей: %d, Текущая запись: %d',
          [DataSource.DataSet.RecordCount, SR, DataSource.DataSet.RecNo]);

      if DataSource.DataSet is TIBCustomDataSet then
      begin
        if not TIBCustomDataSet(DataSource.DataSet).QSelect.EOF then
        begin
          S := S + '. Не все записи извлечены!';
        end;
      end;

      if Assigned(FOnGetFooter) then
        if DataSource.DataSet is TIBCustomDataSet then
          FOnGetFooter(Self, '', (DataSource.DataSet as TIBCustomDataSet).AggregatesObsolete, S)
        else
          FOnGetFooter(Self, '', False, S);

      WriteText(
        Canvas,
        R,
        R,
        2, 2,
        S,
        taLeftJustify,
        False,
        True
      );

      Canvas.MoveTo(R.Left, R.Top);
      Canvas.LineTo(R.Right, R.Top);
      Canvas.LineTo(R.Right, R.Bottom);
    end;
  finally
    FInDrawTotals := False;
  end;
end;

procedure TgsCustomDBGrid.TopLeftChanged;
begin
  inherited;
  DrawTotals;
end;

procedure TgsCustomDBGrid.SetShowFooter(const Value: Boolean);
begin
  if FShowFooter <> Value then
  begin
    FShowFooter := Value;
    Invalidate;
  end;
end;

procedure TgsCustomDBGrid.AddCheck;
begin
  FCheckBox.AddCheck(DataLink.DataSet.FindField(FCheckBox.FieldName).DisplayText);
end;

procedure TgsCustomDBGrid.DoOnHideColumn(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(Column) then
  begin
    for I := 0 to Columns.Count - 1 do
      if (Columns[I] = Column) then
      begin
        if (not (Column as TgsColumn).Frozen) then
        begin
          Columns[I].Visible := False;
          FSettingsModified := True;
          CountScaleColumns;
        end else
          MessageBox(Handle,
            'Сначала снимите закрепление колонки.',
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
        exit;
      end;
  end;
end;

{$IFDEF NEW_GRID}
procedure TgsCustomDBGrid.DoOnGroup(Sender: TObject);
begin
  if DataSource.DataSet is TIBCustomDataSet then
  begin
    with TIBCustomDataSet_dlgSortGroupProp.Create(Self) do
    try
      TIBCustomDataSet(DataSource.DataSet).OnPseudoRecordsOn  := _OnPseudoRecordsOn;
      Setup(DataSource.DataSet as TIBCustomDataSet, Self);
      ShowModal;
    finally
      Free;
    end;
  end;
end;

procedure TgsCustomDBGrid.DoOnUnGroup(Sender: TObject);
begin
  if DataSource.DataSet is TIBCustomDataSet then
    with (DataSource.DataSet as TIBCustomDataSet) do
      if GroupSortExist then begin
        ClearGroupSort;
        UnGroup(false);
      end;
end;

procedure TgsCustomDBGrid.DoOnGroupWrap(Sender: TObject);
begin
  if DataSource.DataSet is TIBCustomDataSet then
    with (DataSource.DataSet as TIBCustomDataSet) do
      if GroupSortExist then
        WrapAllGroups;
end;

procedure TgsCustomDBGrid.DoOnGroupUnWrap(Sender: TObject);
begin
  if DataSource.DataSet is TIBCustomDataSet then
    with (DataSource.DataSet as TIBCustomDataSet) do
      if GroupSortExist then
         UnWrapAllGroups;
end;

procedure TgsCustomDBGrid.DoOnGroupOneWrap(Sender: TObject);
var
  DS: TIBCustomDataSet;
begin
  if DataSource.DataSet is TIBCustomDataSet then begin
    DS := TIBCustomDataSet(DataSource.DataSet);
    if DS.GroupSortExist and not (DS.RecordKind in [rkGroup]) then
    begin
        DS.DisableControls;
        try
          while not DS.Bof do begin
            if (DS.RecordKind in [rkHeader]) then
              break;
            DS.Prior;
          end;
        finally
          DS.EnableControls;
          DS.WrapGroup;
        end;
      end;
    end;
end;

procedure TgsCustomDBGrid.DoOnGroupOneUnWrap(Sender: TObject);
begin
  if DataSource.DataSet is TIBCustomDataSet then
    with (DataSource.DataSet as TIBCustomDataSet) do
      if GroupSortExist and (RecordKind in [rkGroup]) then
        WrapGroup;
end;

procedure TgsCustomDBGrid.DoOnGroupNext(Sender: TObject);
var
  OldBm: string;
  DS: TIBCustomDataSet;
begin
  DS := DataSource.DataSet as TIBCustomDataSet;
  OldBm := DataLink.DataSet.Bookmark;
  DS.DisableControls;
  try
    if (DS.RecordKind in [rkHeader, rkGroup]) then
      DS.Next;
    while not DS.Eof do begin
      if (DS.RecordKind in [rkHeader, rkGroup]) then
        break;
      DS.Next;
    end;

    if DS.Eof then
      DataLink.DataSet.Bookmark := OldBm
    else begin
      if (DS.RecordKind in [rkGroup]) then
        DS.WrapGroup;
      DS.Next;
    end;
  finally
    DS.EnableControls;
  end;
end;

procedure TgsCustomDBGrid.DoOnGroupPrior(Sender: TObject);
var
  DS: TIBCustomDataSet;
begin
  DS := DataSource.DataSet as TIBCustomDataSet;
  DS.DisableControls;
  try
    while not DS.Bof do begin
        if (DS.RecordKind in [rkHeader, rkGroup]) then
          break;
        DS.Prior;
    end;
    while not DS.Bof do begin
      DS.Prior;
      if (DS.RecordKind in [rkHeader, rkGroup]) then begin
        break;
      end;
    end;

    if (DS.RecordKind in [rkGroup]) then
      DS.WrapGroup;
    DS.Next;
  finally
    DS.EnableControls;
  end;
end;

procedure TgsCustomDBGrid._OnPseudoRecordsOn(DataSet: TDataSet; var Accept: Boolean);
begin
  Accept := True;
end;
{$ENDIF}

procedure TgsCustomDBGrid.DoOnInputCaption(Sender: TObject);
var
  I: Integer;
  S: String;
begin
  if Assigned(Column) then
  begin
    for I := 0 to Columns.Count - 1 do
      if (Columns[I] = Column) then
      begin
        S := Column.Title.Caption;
        if InputQuery('Колонка', 'Введите заголовок колонки:', S) then
        begin
          Column.Title.Caption := S;
          FSettingsModified := True;
        end;
        exit;
      end;
  end;
end;

procedure TgsCustomDBGrid.DoOnFrozeColumn(Sender: TObject);
var
  I, J: Integer;
begin
  if Assigned(Column) then
  begin
    for I := 0 to Columns.Count - 1 do
      if (Columns[I] = Column) then
      begin
        for J := I downto 0 do
        begin
          if (Columns[J] as TgsColumn).WasFrozen then
          begin
            MessageBox(Handle,
              'Нельзя закрепить колонку, если слева от нее были скрыты колонки.',
              'Внимание',
              MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
            exit;
          end;
        end;

        (Column as TgsColumn).Frozen := not (Column as TgsColumn).Frozen;
        Invalidate;
        FSettingsModified := True;
        exit;
      end;
  end;
end;

procedure TgsCustomDBGrid.DoOnFrozeColumnUpdate(Sender: TObject);
var
  I: Integer;
begin
  if Assigned(Column) and ((LeftCol - IndicatorOffset = 0)
    or (Column as TgsColumn).Frozen) then
  begin
    OnActionUpdate(Sender);

    for I := 0 to Columns.Count - 1 do
      if (Columns[I] = Column) then
      begin
        (Sender as TAction).Checked := (Column as TgsColumn).Frozen;
        exit;
      end;

    (Sender as TAction).Checked := False;
  end else
  begin
    (Sender as TAction).Enabled := False;

    for I := 0 to Columns.Count - 1 do
      if (Columns[I] = Column) then
      begin
        (Sender as TAction).Checked := (Column as TgsColumn).Frozen;
        exit;
      end;
  end;
end;

procedure TgsCustomDBGrid.DoOnCancelAutoFilter(Sender: TObject);
var
  C: TgsColumn;
  M1: TFilterRecordEvent;
  P1: Pointer absolute M1;
  M2: TFilterRecordEvent;
  P2: Pointer absolute M2;
begin
  if (not Assigned(DataSource)) or (not Assigned(DataSource.DataSet)) then
    exit;

  while FFilteredColumns.Count > 0 do
  begin
    C := TgsColumn(FFilteredColumns[FFilteredColumns.Count - 1]);
    C.Filtered := False;
    FFilteredColumns.Delete(FFilteredColumns.Count - 1);
  end;

  with DataSource.DataSet do
  begin
    if Filtered then
    begin
      M1 := OnFilterRecord;
      M2 := _OnFilterRecord;

      if P1 = P2 then
      begin
        OnFilterRecord := FOldOnFilterRecord;
        Filtered := FOldFiltered;
      end;
    end;
  end;

  FFilteredDataSet := nil;
  FOldOnFilterRecord := nil;
  FOldFiltered := False;
end;

procedure TgsCustomDBGrid._CountScaleColumns;
var
  OldWidth, VertLineWidth, Delta, NewColWidth: Integer;
  Percent: Double;
  I: Integer;

  function TestColumn(C: TColumn): Boolean;
  begin
    Result := C.Visible and (((C.Field is TStringField) and (C.Field.Size > 20))
      or (C.Field is TMemoField));
  end;

begin
  if FCanScale and DataLink.Active and Assigned(Parent) then
  begin
    if AcquireLayoutLock then
    try
      VertLineWidth := GridLineWidth * Integer(dgColLines in Options);

      if dgIndicator in Options then
        OldWidth := ColWidths[0] + VertLineWidth
      else
        OldWidth := 0;

      for I := 0 to Columns.Count - 1 do
        if Columns[I].Visible then
          Inc(OldWidth, Columns[I].Width + VertLineWidth);

      Delta := OldWidth - ClientWidth;

      if (Delta > 0) and FScaleColumns then
      begin
        for I := ColCount - 1 downto Integer(dgIndicator in Options) do
        begin
          if TestColumn(Columns[I - Integer(dgIndicator in Options)]) then
          begin
            NewColWidth := ColWidths[I] - Delta;
            if NewColWidth < FMinColWidth then
              NewColWidth := FMinColWidth;
            Delta := Delta - ColWidths[I] + NewColWidth;
            ColWidths[I] := NewColWidth;
            if Delta <= 0 then
              break;
          end;
        end;

        if Delta > 0 then
        begin
          if OldWidth > 0 then
            Percent := ClientWidth / OldWidth
          else
            Percent := 0;

          for I := Integer(dgIndicator in Options) to ColCount - 1 do
          begin
            if Columns[I - Integer(dgIndicator in Options)].Visible then
            begin
              NewColWidth := Round(ColWidths[I] * Percent);
              if NewColWidth < FMinColWidth then
                NewColWidth := FMinColWidth;
              Delta := Delta - ColWidths[I] + NewColWidth;
              ColWidths[I] := NewColWidth;
              if Delta <= 0 then
                break;
            end;
          end;
        end;
      end;

      if Delta < 0 then
      begin
        for I := ColCount - 1 downto Integer(dgIndicator in Options) do
        begin
          if TestColumn(Columns[I - Integer(dgIndicator in Options)]) then
          begin
            ColWidths[I] := ColWidths[I] - Delta;
            Delta := 0;
            break;
          end;
        end;
      end;

      if Delta < 0 then
      begin
        for I := ColCount - 1 downto Integer(dgIndicator in Options) do
        begin
          if Columns[I - Integer(dgIndicator in Options)].Visible then
          begin
            ColWidths[I] := ColWidths[I] - Delta;
            break;
          end;
        end;
      end;

      for I := 0 to Columns.Count - 1 do
        if Columns[I].Visible then
          Columns[I].Width := ColWidths[I + Integer(dgIndicator in Options)];
    finally
      EndLayout;
    end;
  end;
end;

{ TgsListBox }

procedure TgsListBox.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;
  Hide;
  if not (Owner as TgsCustomDBGrid).FInInputQuery then
    (Owner as TgsCustomDBGrid).FFilteringColumn := nil;
end;

procedure TgsCustomDBGrid.SetGroupFieldName(const Value: String);
begin
  if FGroupFieldName <> Value then
  begin
    FGroupFieldName := Value;
    FreeAndNil(FOddKeys);
    FreeAndNil(FEvenKeys);
    Invalidate;
  end;
end;

procedure TgsCustomDBGrid.DoOnFindExecute(Sender: TObject);
begin
  FFindColumn := nil;
  DoOnFindNextExecute(Sender);
end;

procedure TgsCustomDBGrid.WMPAINT(var Message: TMessage);
begin
  inherited;

  // программист может неудачно перекрыть ОнГетФутер
  // и там будет аксесвиолэйшн
  // на паинте это очень болезненно
  // первый раз выкинем исключение, а все последующие
  // просто не будем рисовать тотал
  if FAllowDrawTotals then
  begin
    try
      DrawTotals;
    except
      FAllowDrawTotals := False;
      raise;
    end;
  end;
end;

procedure TgsCustomDBGrid.GetValueFromValueList(AColumn: TColumn;
  var AValue: String);
begin
  //
end;

procedure TgsCustomDBGrid.WMContextMenu(var Message: TWMContextMenu);
var
  R: TRect;
  P: TSmallPoint;
begin
  if (Col >= 0) and (Row >= 0) then
  begin
    R := CellRect(Col, Row);
    P.x := R.Left;
    P.y := R.Bottom;
    Message.Result := Perform(WM_RBUTTONUP, 0, Integer(P));
  end else
    inherited;
end;

procedure TgsCustomDBGrid.FindInGrid;
begin
  if Assigned(FFindAct) then
    FFindAct.Execute;
end;

procedure TgsCustomDBGrid.DoOnCopyToClipboardExecute(Sender: TObject);
var
  I, J, K: Integer;
  Bm, S, Title: String;
  Data, Data2: THandle;
  DataPtr, DataPtr2: Pointer;
  D: DWORD;
  F: Boolean;
begin
  S := '';
  Title := '';

  if (SelectedRows.Count > 0) and (DataSource <> nil)
    and (DataSource.DataSet <> nil) then
  begin
    Bm := DataSource.DataSet.Bookmark;
    BeginUpdate;
    try
      for I := 0 to SelectedRows.Count - 1 do
      begin
        DataSource.DataSet.Bookmark := SelectedRows[I];
        F := False;
        for J := 0 to Columns.Count - 1 do
        begin
          if Columns[J].Visible and (Columns[J].Field <> nil)
            and (not (Columns[J].Field.DataType in [ftBlob, ftGraphic])) then
          begin
            if F then
            begin
              S := S + #9;
              if I = 0 then
                Title := Title + #9;
            end else
              F := True;
            S := S + Columns[J].Field.AsString;

            if I = 0 then
            begin
              Title := Title + Columns[J].Title.Caption;
            end;

            for K := 0 to FExpands.Count - 1 do
            begin
              if FExpands[K].DisplayField = Columns[J].Field.FieldName then
              begin
                if (DataSource.DataSet.FindField(FExpands[K].FieldName) <> nil)
                  and (not (DataSource.DataSet.FieldByName(FExpands[K].FieldName).DataType in [ftBlob, ftGraphic])) then
                begin
                  S := S + #9 + DataSource.DataSet.FieldByName(FExpands[K].FieldName).AsString;
                  if I = 0 then
                  begin
                    Title := Title + #9 + DataSource.DataSet.FieldByName(FExpands[K].FieldName).DisplayLabel;
                  end;
                end;  
              end;
            end;
          end;
        end;
        if I <> (SelectedRows.Count - 1) then
          S := S + #13#10;
      end;
      S := Title + #13#10 + S;
    finally
      DataSource.DataSet.Bookmark := Bm;
      EndUpdate;
    end;
  end else
  begin
    if Assigned(SelectedField) then
    begin
      S := SelectedField.AsString;

      for K := 0 to FExpands.Count - 1 do
      begin
        if FExpands[K].DisplayField = SelectedField.FieldName then
        begin
          if DataSource.DataSet.FindField(FExpands[K].FieldName) <> nil then
          begin
            S := S + #13#10 + DataSource.DataSet.FieldByName(FExpands[K].FieldName).AsString;
          end;
        end;
      end;

    end;
  end;

  if S > '' then
  begin
    with TClipboard.Create do
    try
      Open;
      try
        Data := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, Length(S) + 1);
        Data2 := GlobalAlloc(GMEM_MOVEABLE+GMEM_DDESHARE, SizeOf(DWORD));
        try
          DataPtr := GlobalLock(Data);
          DataPtr2 := GlobalLock(Data2);
          try
            { TODO : а как будут обрабатываться другие языки? }
            D := MAKELONG(MAKEWORD(LANG_RUSSIAN, SUBLANG_NEUTRAL), SORT_DEFAULT);
            Move(D, DataPtr2^, SizeOf(D));
            Move(PChar(S)^, DataPtr^, Length(S) + 1);
            EmptyClipboard;
            SetClipboardData(CF_LOCALE, Data2);
            SetClipboardData(CF_TEXT, Data);
          finally
            GlobalUnlock(Data);
            GlobalUnlock(Data2);
          end;
        except
          GlobalFree(Data);
          GlobalFree(Data2);
          raise;
        end;
      finally
        Close;
      end;
    finally
      Free;
    end;
  end;
end;

//^^^

procedure TgsDataLink.DataSetChanged;
//var
//  OldPseudoRecordsOn: Boolean;
//  DS: TIBCustomDataSet;
begin
//      {$IFDEF NEW_GRID} { TODO : ^^^^ DataLink.ActiveRecord в DataSetChanged грида }
//      if DataSetIsIBCustom(DataSource) then begin
//        if TIBCustomDataSet(DataSource.DataSet).GroupSortExist then
//          OldPseudoRecordsOn := TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn;
//        DS := TIBCustomDataSet(DataSource.DataSet);
//        TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn := True;
//     fm1.Memo1.Lines.Add('DataSetChanged: '+fm1.Q1ORDERKEY.asString+', '
//        +DS.Dbg1);//&&&
//     fm1.Memo1.Lines.Add( IntToStr(DS.CurRecord) + ', '  + IntToStr(DS.RecordCount) );
//     if EOF then fm1.Memo1.Lines.Add('EOF');//&&&
//      end;
//      {$ENDIF}
   inherited DataSetChanged;
end;

procedure TgsDataLink.DataEvent(Event: TDataEvent; Info: Longint);
//var
//  OldPseudoRecordsOn: Boolean;
//  DS: TIBCustomDataSet;
begin
  if (Event <> deUpdateState) and Active then
    if Event = deDataSetChange then
    begin
      {$IFDEF NEW_GRID} { TODO : ^^^^ DataLink.ActiveRecord в DataSetChanged грида }
      if DataSetIsIBCustom(DataSource) then
        if TIBCustomDataSet(DataSource.DataSet).GroupSortExist then
        begin
//        DS := TIBCustomDataSet(DataSource.DataSet);
//fm1.Memo1.Lines.Add('_ DataEvent: '+fm1.Q1ORDERKEY.asString+', '
//        +DS.Dbg1);//&&&
//fm1.Memo1.Lines.Add( IntToStr(DS.CurRecord) + ', '  + IntToStr(DS.RecordCount) );
//if EOF then fm1.Memo1.Lines.Add('EOF');//&&&
        if TIBCustomDataSet(DataSource.DataSet).PseudoSkip > 0 then begin
//          OldPseudoRecordsOn := TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn;
          TIBCustomDataSet(DataSource.DataSet).PseudoRecordsOn := True;
          //TIBCustomDataSet(DataSource.DataSet).Resync([]);
        end;  
      end;
      {$ENDIF}
    end;
  inherited DataEvent(Event, Info);
end;


constructor TgsDataLink.Create;
begin
  inherited Create;
end;

destructor TgsDataLink.Destroy;
begin
  inherited;
end;

initialization

  GridHintWindow := nil;

  {$IFDEF GEDEMIN}
  RegExp := Unassigned;
  {$ENDIF}

finalization

  {$IFDEF GEDEMIN}
  RegExp := Unassigned;
  {$ENDIF}

  if GridHintDoneEvent <> 0 then
  begin
    CloseHandle(GridHintDoneEvent);
    GridHintDoneEvent := 0;
  end;

  if GridHintWindow <> nil then
    FreeAndNil(GridHintWindow);

end.


