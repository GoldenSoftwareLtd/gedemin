
{++


  Copyright (c) 2001-2013 by Golden Software of Belarus

  Module

    gdcInvMovement.pas

  Abstract

    Business class. Inventory movement and remains.

  Author

    Shoihet Michael (17-09-2001)

  Revisions history

    Initial  17-09-2001  Michael  Initial version.
    Changed  29-10-2001  Michael  Minor Change
    Changed  13-11-2001  Michael  Переделан класс работы с остатками.
    Changed  15-05-2002  Michael  Переделан механизм редактирования движения при изменении кол-ва

--}

unit gdcInvMovement;

{TODO 1 -oMikle: Необходимо сделать при редактировании просмотр карточек для возможности замены}
{DONE 2 -oMikle: При изменении атрибутов карточки необходимо решать можно их менять или нет}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IB, IBCustomDataSet, gdcBase, gdcClasses, gdcInvConsts_unit, IBSQL,
  at_classes, gdcGood, Math, iberrorcodes, IBDataBase, gd_createable_form,
  gdc_createable_form, gdcBaseInterface, gdv_InvCardConfig_unit,
  gsIBGrid, gdcExplorer, gdcFunction, prm_ParamFunctions_unit, rp_report_const,
  gdcConstants, gd_security_operationconst, Storages, gd_i_ScriptFactory;

const
  cst_ByGoodKey = 'ByGoodKey';
  cst_ByGroupKey = 'ByGroupKey';
  cst_AllRemains = 'AllRemains';
  cst_Holding = 'ByHolding';
  cFunctionName = 'InvCardReportScriptFuction%s';

type
// Структура для хранения выбранных карточек
  TgdcChooseCard = record
    ccCardKey: Integer;                            // Код карточки
    ccQuantity: Currency;                          // Количество
  end;

// Структура для хранения значений атрибута карточки
  TgdcInvCardFeature = record
    optFieldName: String;                          // Наименование поля атрибутов
    optValue: Variant;                             // Значение атрибута
    isInteger: Boolean;
  end;

  TgdcArrInvFeatures = array of TgdcInvCardFeature;

// Структура для хранения значений карточки
//  PgdcCardValue = ^TgdcCardValue;
  TgdcCardValue = record
    cvalFirstDocumentKey: Integer;                   // Код первого движения
    cvalDocumentKey: Integer;                        // Код движения, который создал карточку
    cvalFirstDate: TDate;                            // Дата первого появления карточки
    cvalCardKey: Integer;                            // Код карточки
    cvalGoodKey: Integer;                            // Код товара
    cvalQuantity: Currency;                          // Количество
    cvalQuantPack: Currency;                         // Количество упаковок
    cvalContactKey: Integer;                         // Контакт
    cvalInvCardFeatures: array of TgdcInvCardFeature;  // Список атрибутов карточки
  end;

  TgdcTypeCheckRemains = (tcrNone, tcrSource, tcrDest);
  TgdcTypeChecksRemains = set of TgdcTypeCheckRemains;

// Структура для хранения значений позиций документа
  TgdcInvPosition = record
    ipDocumentKey: Integer;                        // Код позиции документа
    ipDocumentDate: TDate;                         // Дата движения
    ipGoodKey: Integer;                            // Код товара
    ipQuantity: Currency;                          // Количество
    ipBaseCardKey: Integer;                        // Базовая карточка
    ipSourceContactKey: Integer;                   // Контакт источник
    ipDestContactKey: Integer;                     // Контакт получатель
    ipCheckRemains: TgdcTypeChecksRemains;         // Тип контроля остатков
    ipMovementDirection: TgdcInvMovementDirection; // Тип списания позиции
    ipOneRecord: Boolean;                          // Позиция требует одной записи в движении

    ipDelayed: Boolean;                            // Отложенный документ
    ipMinusRemains: Boolean;                       // Выбор из отрицательных остатков

// В случае создания отложенного документа - если задан ipBaseCardKey - то ничего не делаем
// если ipBaseCardKey не задан то по позиции создается карточка (но движение не формируется)
// ключ созданной карточки переносится в позицию.

    ipInvSourceCardFeatures: array of TgdcInvCardFeature;// Список свойств источника
    ipInvDestCardFeatures: array of TgdcInvCardFeature;  // Список новых свойств
    ipInvMinusCardFeatures: array of TgdcInvCardFeature;  // Список свойств для выбора из
                                                          // минусовых остатков

    ipSubSourceContactKey: Integer;                // Контакт ограничивающий список источников
    ipSubDestContactKey: Integer;                  // Контакт ограничивающий список получателей

    ipPredefinedSourceContact: array of Integer;   // Список предустановленных источников
    ipPredefinedDestContact: array of Integer;     // Список предустановленных получателей

    ipSubPredefinedSourceContact: array of Integer;   // Список предустановленных ограничений источников
    ipSubPredefinedDestContact: array of Integer;     // Список предустановленных ограничений получателей

  end;

// Что изменилось в движении
  TgdcChangeMovement = (cmSourceContact, cmDestContact, cmQuantity, cmGood,
    cmSourceFeature, cmDestFeature, cmDate);
  TgdcChangeMovements = set of TgdcChangeMovement;

  TInvRemainsSQLType = (irstSubSelect, irstSimpleSum);

  TIntegerArr = array of Integer;

  TTypePosition = (tpAll, tpDebit, tpCredit);


type

  TgdcInvRemains = class;

  TgdcInvMovement = class(TgdcBase)
  private
    FibsqlCardInfo: TIBSQL;           // Запрос для получения информации по карточке
    ibsqlLastRemains: TIBSQL;
    ibsqlCardList: TIBSQL;
    FibsqlAddCard: TIBSQL;            // Запрос для добавления карточки
    FgdcDocumentLine: TgdcDocument;   // Позиция документа
    FCurrentRemains: Boolean;         // Признак текущих остатков (в противном случае остатки на дату
    FInvErrorCode: TgdcInvErrorCode;  // Код ошибки
    FInvErrorMessage: String;         // Текст оригинальной ошибки
    FIsCreateMovement: Boolean;       // Создавалось ли движение при сохранении позиции
    FIsLocalPost: Boolean;
    FIsGetRemains: Boolean;
    FCountPositionChanged: Integer;            // Post позиции сделан в самом объекте
    FShowMovementDlg: Boolean;
    FNoWait: Boolean;

    FUseSelectFromSelect: Boolean;
    FEndMonthRemains: Boolean;

// Процедура инициализации запросов
    procedure InitIBSQL;

// Функция проверяет наличие дополнительного движения по карточке и контакту
// aContactKey - контакт по которому проверяется движение
// aCardKey - карточка по которой проверяется движение
// aExcludeDocumentKey - код документа, который исключается из проверки
   function IsMovementExists(const aContactKey, aCardKey,
     aExcludeDocumentKey: Integer; const aDocumentDate: TDateTime = 0): Boolean;

// Функции для подсчета количественных показателей

// Функции возвращает количество по позиции документа
// aDocumentKey - код текущей позиции
    function GetQuantity(const aDocumentKey: Integer; TypePosition: TTypePosition): Currency;

// Функция возвращает текущий остаток по карточке и контакту
// aCardKey - Код карточки
// aContactKey - Код клиента
    function GetLastRemains(const aCardKey, aContactKey: Integer): Currency;

// Функция возвращает остаток по карточке на указанную дату
// aCardKey - Код карточки
// aContactKey - Код контакта
// aDate - Дата
    function GetRemainsOnDate(const aCardKey, aContactKey: Integer;
       aDate: TDateTime): Currency;

// Функция возвращает значение карточки
// Если переданная карточка не неайдена то возвращается False
    function GetCardInfo(const aCardKey: Integer): Boolean;

//  Функция сравнивает параметры исходной карточки карточки, с передаваемыми параметрами
//  aSourceCardKey - Код исходной карточки
//  aDestGoodKey - Сравниваемый товар
//  aDestInvCardFeatures - Сравниваемые параметры
    function CompareCard(const aSourceCardKey, aDestGoodKey: Integer;
      var aDestInvCardFeatures: array of TgdcInvCardFeature): Boolean;

// Создание новой карточки AddInvCard
//    SourceCardKey - Код карты источник
//    InvPosition   - Структура для хранения значений позиции
    function AddInvCard(SourceCardKey: Integer; var InvPosition: TgdcInvPosition;
      const isDestCard: Boolean = True): Integer;

// Изменение свойств карточки ModifyInvCard
//    SourceCardKey - Код изменяемой карточки
//    CardFeatures   - Список изменяемых атрибутов
    function ModifyInvCard(SourceCardKey: Integer;
      var CardFeatures: array of TgdcInvCardFeature; const ChangeAll: Boolean = False): Boolean;

// Изменения 1-го поступления карточки
//   CardKey - Код карточки
//   InvPosition - Информация о позиции
    function ModifyFirstMovement(const CardKey: Integer;
       var InvPosition: TgdcInvPosition): Boolean;
       
// Добавляем позицию в движение
// MakeCardListSQL - процедура формирует запрос для вывода карточек с остатками
// InvCardFeatures  - список атрибутов карточки, участвующих в документе
// MovementDirection - тип списания
    function MakeCardListSQL(MovementDirection: TgdcInvMovementDirection;
    var InvCardFeatures: array of TgdcInvCardFeature; const isMinusRemains: Boolean = False): String;
    function MakeCardListSQL_New(MovementDirection: TgdcInvMovementDirection;
      var InvCardFeatures: array of TgdcInvCardFeature; const isMinusRemains: Boolean = False): String;

//  AddOneMovement - функция добавления одной позиции движения
//     SourceCardKey - код карты источник (если нет то -1)
//     Quantity - количество
//     invPosition - информация о позиции документа
    function AddOneMovement(aSourceCardKey: Integer; aQuantity: Currency;
      var invPosition: TgdcInvPosition): Boolean;

//  EditMovement - функция редактирует уже существующее движение
//  ChangeMove - признак какие зменения произведены
//  InvPosition - информация о позиции документа
// gdcInvPositionSaveMode - Тип формирования движения
//   (переформиирование по всем позициям или сохранение одной позиции)
    function EditMovement(ChangeMove: TgdcChangeMovements;
       var InvPosition: TgdcInvPosition;
       const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
// EditDateMovement - функция изменяет дату движения ТМЦ, при этом проверяя
//                    возможность такого изменения
//  InvPosition - информация о позиции документа
// gdcInvPositionSaveMode - Тип формирования движения
//   (переформиирование по всем позициям или сохранение одной позиции)
    function EditDateMovement(var InvPosition: TgdcInvPosition;
       const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;


//  MakeMovementFromPosition - Формирует движение на основании позиции
//     InvPosition - запись со значениями позиции документа
// gdcInvPositionSaveMode - Тип формирования движения
//   (переформиирование по всем позициям или сохранение одной позиции)
    function MakeMovementFromPosition(var InvPosition: TgdcInvPosition;
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument): Boolean;


//  FillPosition - процедура заполняет запись по позиции
//  gdcDocumentLine - позиция документа
//  InvPosition - запись со значениями позиции документа
    procedure FillPosition(gdcDocumentLine: TgdcDocument; var InvPosition: TgdcInvPosition);

//  MakePosition - процедура добавляет позиции на основании остатков
//    procedure MakePosition(gdcInvRemains: TgdcInvRemains; const isAppend: Boolean = True);

//  ShowRemains - просмотр остатков
    function ShowRemains(var InvPosition: TgdcInvPosition; const isPosition: Boolean): Boolean;

//  SetEnableMovement - устанавливает disabled
    function SetEnableMovement(const aDocumentKey: Integer;
      const isEnabled: Boolean): Boolean;

// DeleteEnableMovement - удаляет движение исходя из disabled
    function DeleteEnableMovement(const aDocumentKey: Integer;
      const isEnabled: Boolean): Boolean;

// CheckMovement - проверка на движение с учетом изменения свойств

// Если изменились свойства карточки, то мы должны проверить, участвовала ли данная
// карточка в движении в котором изменяемое свойство являлось определяющим позицию
// если такое движение было мы должны поискать свободную карточку со старыми свойствами
// и если такая есть то подставить ее, если нет то или выдать ошибку или же если в данном
// движении других карточек не было проигнорировать. (Дело в том что если в движении были
// другие карточки то мы должны обязательно как-то это исправить или выдать ошибку в другом случае
// с точки зрения программы все нормально)

// InvPosition - значения текущей записи документа
// aCardKey - код текущей карточки
    function CheckMovementOnCard(const aCardKey: Integer;
      var InvPosition: TgdcInvPosition): Boolean;

// MakeMovementLine - Создает новое движение на переданное количество
// Quantity - количество на которое необходимо создать движение
// InvPosition - значения текущей записи документа
// gdcInvPositionSaveMode - Тип формирования движения
//   (переформиирование по всем позициям или сохранение одной позиции)
    function MakeMovementLine(Quantity: Currency; var InvPosition: TgdcInvPosition;
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
    function GetIsGetRemains: Boolean;
    procedure SetIsGetRemains(const Value: Boolean);
    function GetCardDocumentKey(const CardKey: Integer): Integer;

    function IsReplaceDestFeature(ContactKey, CardKey, DocumentKey: Integer;
                ChangedField: TStringList; var InvPosition: TgdcInvPosition): Boolean;

    // Формируют запрос для функции GetRemains, в зависимости от версии сервера
    function GetRemains_GetQueryOld(InvPosition: TgdcInvPosition): String;
    function GetRemains_GetQueryNew(InvPosition: TgdcInvPosition): String;

  protected
    { Protected declarations }

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGroupClause: String; override;
    function GetOrderClause: String; override;
    function GetRefreshSQLText: String; override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;

    procedure DoBeforeOpen; override;
    procedure _DoOnNewRecord; override;

    procedure CreateFields; override;

    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

    procedure SetSubSet(const Value: TgdcSubSet); override;
  public
    { Public declarations }

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

// Функция выбора признаков
    function SelectGoodFeatures: Boolean;

// Функция добавления движения по позиции документа
// gdcInvPositionSaveMode - движение формируется при сохранении документа или при наборе позиции

    function CreateMovement(
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument): Boolean;

// Функция добавления движения по всем позициям документа
    function CreateAllMovement(
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument;
      const IsOnlyDisabled: Boolean = False): Boolean;

// Функция возвращает остаток по позиции в разерезе параметров
// isCurrentReamins - Необходим текущий остаток (не зависит от даты)
    function GetRemains: Currency;

// Функция выводит окно с диалогом для выбора остатков
// IsMakePosition - Формировать ли позиции после выбора
    function ChooseRemains(const isMakePosition: Boolean = True): Boolean;

    procedure ClearCardQuery;

//  Код ошибки
    property InvErrorCode: TgdcInvErrorCode read FInvErrorCode;
    property CountPositionChanged: Integer read FCountPositionChanged;
    property IsGetRemains: Boolean read GetIsGetRemains write SetIsGetRemains;
    property NoWait: Boolean read FNoWait write FNoWait;

    class procedure RegisterClassHierarchy; override;

    property ShowMovementDlg: Boolean read FShowMovementDlg write FShowMovementDlg default True;
  published
    // Позиция документа
    property gdcDocumentLine: TgdcDocument read FgdcDocumentLine write FgdcDocumentLine;
    property CurrentRemains: Boolean read FCurrentRemains write FCurrentRemains default True;
    property EndMonthRemains: Boolean read FEndMonthRemains write FEndMonthRemains default False;
  end;

{ TgdcInvBaseRemains - базовый класс для работы с остатками }

  TgdcInvBaseRemains = class(TgdcBase)
  private
    FRemainsDate: TDateTime;
    FViewFeatures: TStringList;
    FSumFeatures: TStringList;
    FGoodViewFeatures: TStringList;
    FGoodSumFeatures: TStringList;

    FCurrentRemains: Boolean;
    FRemainsSQLType: TInvRemainsSQLType;
    FIsMinusRemains: Boolean;
    FIsNewDateRemains: Boolean;
    FIsUseCompanyKey: Boolean;

    FUseSelectFromSelect: Boolean;
    FEndMonthRemains: Boolean;

    procedure SetViewFeatures(const Value: TStringList);
    procedure SetSumFeatures(const Value: TStringList);
    procedure ReadFeatures(FFeatures: TStringList; Stream: TStream);
    procedure ReadGoodFeatures(FFeatures: TStringList; Stream: TStream);
    procedure SetGoodSumFeatures(const Value: TStringList);
    procedure SetGoodViewFeatures(const Value: TStringList);
    procedure SetCurrentRemains(const Value: Boolean);

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGroupClause: String; override;
    function GetRefreshSQLText: String; override;

    procedure SetActive(Value: Boolean); override;

    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;
    procedure SetSubType(const Value: String); override;

    procedure DoBeforeInsert; override;

    procedure CreateFields; override;

  public
    constructor Create(anOwner: TComponent); override;
    destructor Destroy; override;

    class function GetSubSetList: String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetListTableAlias: String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    class procedure RegisterClassHierarchy; override;

    class function IsAbstractClass: Boolean; override;
    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

    function CheckTheSameStatement: String; override;
    function GetRemainsName: String;

// Набор свойств карточки необходимый для отображения остатков
    property ViewFeatures: TStringList read FViewFeatures write SetViewFeatures;
// Набор свойств карточки по которым необходимо осуществлять суммирование
    property SumFeatures: TStringList read FSumFeatures write SetSumFeatures;
// Набор свойств карточки необходимый для отображения остатков
    property GoodViewFeatures: TStringList read FGoodViewFeatures write SetGoodViewFeatures;
// Набор свойств карточки по которым необходимо осуществлять суммирование
    property GoodSumFeatures: TStringList read FGoodSumFeatures write SetGoodSumFeatures;

// Тип использованнного запроса (с подзапросом или сумма)
    property RemainsSQLType: TInvRemainsSQLType read FRemainsSQLType write FRemainsSQLType;

// Дата на которую формируются остатки
    property RemainsDate: TDateTime read FRemainsDate write FRemainsDate;
// Выводить текущие остатки
    property CurrentRemains: Boolean read FCurrentRemains write SetCurrentRemains;
// Проверять на остатки на конец месяца
    property EndMonthRemains: Boolean read FEndMonthRemains write FEndMonthRemains;
// Использовать для расчета остатков на дату сторед процедуру INV_GETCARDMOVEMENT
    property IsNewDateRemains: Boolean read FIsNewDateRemains write FIsNewDateRemains;
    property IsMinusRemains: Boolean read FIsMinusRemains write FIsMinusRemains;
    property IsUseCompanyKey: Boolean read FIsUseCompanyKey write FIsUseCompanyKey;
    property UseSelectFromSelect: Boolean read FUseSelectFromSelect;
  published
    property OnAfterInitSQL;
  end;


{ TgdcInvRemains - класс для работы с остатками }

  TgdcInvRemains = class(TgdcInvBaseRemains)
  private
    FGroupKey: Integer;
    FGoodKey: Integer;
    FChooseFeatures: TgdcArrInvFeatures;
    FIsDest: Boolean;

    FCheckRemains: Boolean;
    FDepartmentKeys: TIntegerArr;
    FSubDepartmentKeys: TIntegerArr;
    FIncludeSubDepartment: Boolean;
    FContactType: Integer;
    FgdcDocumentLine: TgdcDocument;

    function GetCountPosition: Integer;
    procedure AddPosition;
    procedure SetgdcDocumentLine(const Value: TgdcDocument);

  protected

    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetGroupClause: String; override;
    function GetRefreshSQLText: String; override;

    procedure DoAfterPost; override;
    procedure DoBeforePost; override;

    procedure SetOptions_New; virtual;

    procedure DoBeforeOpen; override;

  public
    PositionList: array of TgdcCardValue;

    constructor Create(anOwner: TComponent); override;
    destructor Destroy; override;

    procedure ClearPositionList;

    procedure SetOptions(var InvPosition: TgdcInvPosition;
      InvMovement: TgdcInvMovement; const isPosition: Boolean; const isDest: Boolean = False);

    procedure RemovePosition;

    procedure SetDepartmentKeys(const Value: array of Integer);
    procedure SetSubDepartmentKeys(const Value: array of Integer);

// Функиция для вывода окна с остатками и выбора
// Количество выбранных позиций
    property CountPosition: Integer read GetCountPosition;

// Набор свойств карточки по которым устанавливается ограничение
    property ChooseFeatures: TgdcArrInvFeatures read FChooseFeatures;

// Код товара по которому выводятся остатки (елси -1 то по всем ТМЦ)
    property GoodKey: Integer read FGoodKey write FGoodKey;
// Код группы по которой выводятся остатки (если -1 то по всем группам)
    property GroupKey: Integer read FGroupKey write FGroupKey;
// Коды подразделений по которым выводятся остатки
    property DepartmentKeys: TIntegerArr read FDepartmentKeys;
// Коды главных подразделений по которым выводятся остатки
    property SubDepartmentKeys: TIntegerArr read FSubDepartmentKeys;
// Включать вложенные подразделения
    property IncludeSubDepartment: Boolean read FIncludeSubDepartment write FIncludeSubDepartment;
// Тип контакта по которому выводятся остатки
    property ContactType: Integer read FContactType write FContactType;
// Контроль остатков при выборе
    property CheckRemains: Boolean read FCheckRemains write FCheckRemains;
    property gdcDocumentLine: TgdcDocument read FgdcDocumentLine write SetgdcDocumentLine;
  end;

  TgdcInvGoodRemains = class(TgdcInvRemains)
  protected
    procedure SetOptions_New; override;
  end;

  TgdcInvCard = class(TgdcBase)
  private
    FViewFeatures: TStringList;
    FgdcInvRemains: TgdcInvBaseRemains;
    FRemainsFeatures: TStringList;
    FgdcInvDocumentLine: TgdcDocument;
    FIgnoryFeatures: TStringList;
    FieldPrefix: String;
    FIsHolding: Integer;
    FContactKey: Integer;
    procedure SetViewFeatures(const Value: TStringList);
    procedure SetRemainsFeatures(const Value: TStringList);
    procedure SetIgnoryFeatures(const Value: TStringList);
    procedure SetFeatures(DataSet: TDataSet; Prefix: String;
      Features: TgdcInvFeatures);
    function IsHolding: Boolean;
  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;
    procedure GetWhereClauseConditions(S: TStrings); override;
    function GetOrderClause: String; override;
    function GetGroupClause: String; override;

    function GetRefreshSQLText: String; override;
  public

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;

    procedure ReInitialized;
    function GetRemainsOnDate(DateEnd: TDateTime; IsCurrent: Boolean; const AContactKeys: string = ''): Currency;
    procedure SetRemainsConditions;
    procedure SetDocumentLineConditions;

    property ViewFeatures: TStringList read FViewFeatures write SetViewFeatures;
    property RemainsFeatures: TStringList read FRemainsFeatures write SetRemainsFeatures;
    property IgnoryFeatures: TStringList read FIgnoryFeatures write SetIgnoryFeatures;
    property gdcInvRemains: TgdcInvBaseRemains read FgdcInvRemains write FgdcInvRemains;
    property gdcInvDocumentLine: TgdcDocument read FgdcInvDocumentLine write FgdcInvDocumentLine;
    property ContactKey: Integer read FContactKey write FContactKey;

  end;

  TgdcInvRemainsOption = class(TgdcBase)
  private
    FSumFeatures: TgdcInvFeatures;
    FViewFeatures: TgdcInvFeatures;
    FGoodViewFeatures: TgdcInvFeatures;
    FGoodSumFeatures: TgdcInvFeatures;

    procedure UpdateExplorerCommandData(
      MainBranchName, CMD, CommandName, DocumentID, ClassName: String;
      const ShouldUpdateData: Boolean = False;
      const MainBranchKey: Integer = -1);


  protected
    function CreateDialogForm: TCreateableForm; override;

    procedure _DoOnNewRecord; override;
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;
    function GetNotCopyField: String; override;
    procedure DoBeforePost; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;

    procedure ReadOptions;
    procedure WriteOptions;

    property SumFeatures: TgdcInvFeatures read FSumFeatures;
    property ViewFeatures: TgdcInvFeatures read FViewFeatures;
    property GoodViewFeatures: TgdcInvFeatures read FGoodViewFeatures;
    property GoodSumFeatures: TgdcInvFeatures read FGoodSumFeatures;
  end;

  TgdcInvCardConfig = class(TgdcBase)
  private
    FConfig: TInvCardConfig;
    function GetConfig: TInvCardConfig;
    function GetIPCount: integer;
  protected
    procedure DeleteSF;
    procedure CreateSF;
    procedure CreateCommand(SFRUID: TRUID);
    procedure DeleteCommand(SFRUID: TRUID);

    procedure GetWhereClauseConditions(S: TStrings); override;
    procedure _DoOnNewRecord; override;
    procedure DoAfterScroll; override;
    procedure DoAfterCustomProcess(Buff: Pointer; Process: TgsCustomProcess); override;

    function GetGDVViewForm: string;
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    property Config: TInvCardConfig read GetConfig;
    property InputParamsCount: integer read GetIPCount;
    procedure SaveConfig;
    procedure LoadConfig;
    procedure SaveGrid(Grid: TgsIBGrid);
    procedure ClearGrid;
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;


type
  EgdcInvMovement = class(Exception);

procedure Register;

implementation

uses
  dmDatabase_unit, gdcInvDocument_unit, gdc_frmInvSelectRemains_unit, gdc_frmInvSelectGoodRemains_unit, at_sql_setup,
  gd_security, gdc_frmInvViewRemains_unit, gd_ClassList,
  gdc_frmInvRemainsOption_unit, gdc_dlgInvRemainsOption_unit, ComObj,
  gd_resourcestring, gdc_dlgShowMovement_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  , IBHeader;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcInvMovement]);
  RegisterComponents('gdc', [TgdcInvBaseRemains]);
  RegisterComponents('gdc', [TgdcInvRemains]);
  RegisterComponents('gdc', [TgdcInvGoodRemains]);
  RegisterComponents('gdc', [TgdcInvCard]);
  RegisterComponents('gdc', [TgdcInvRemainsOption]);
  RegisterComponents('gdc', [TgdcInvCardConfig]);
end;

{ TgdcInvMovement }

constructor TgdcInvMovement.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FShowMovementDlg := True;
  FCountPositionChanged := 0;
  FNoWait := True;

  FEndMonthRemains := False;

//  FUseFilter := False;

  FgdcDocumentLine := nil;

  FIsLocalPost := False;
  FIsGetRemains := True;

  FInvErrorCode := iecNoErr;
  FInvErrorMessage := '';

  FCurrentRemains := False;

  FibsqlCardInfo := TIBSQL.Create(Self);
  FibsqlCardInfo.Database := Database;
  FibsqlCardInfo.Transaction := Transaction;

  ibsqlCardList := TIBSQL.Create(Self);
  ibsqlCardList.Database := Database;
  ibsqlCardList.Transaction := Transaction;

  ibsqlLastRemains := TIBSQL.Create(Self);
  ibsqlLastRemains.Database := Database;
  ibsqlLastRemains.Transaction := ReadTransaction;

  FibsqlAddCard := TIBSQL.Create(Self);
  FibsqlAddCard.Database := Database;
  FibsqlAddCard.Transaction := Transaction;  

  CustomProcess := [cpInsert, cpModify];

  // Предполагается что объект подключен к этой же БД
  FUseSelectFromSelect :=
    (gdcBaseManager.Database.IsFirebirdConnect and (gdcBaseManager.Database.ServerMajorVersion >= 2));
end;

destructor TgdcInvMovement.Destroy;
begin
  if Assigned(FibsqlCardInfo) then
    FreeAndNil(FibsqlCardInfo);

  if Assigned(ibsqlCardList) then
    FreeAndNil(ibsqlCardList);  

  if Assigned(FibsqlAddCard) then
    FreeAndNil(FibsqlAddCard);

  if Assigned(ibsqlLastRemains) then
    FreeAndNil(ibsqlLastRemains);  
      
  inherited Destroy;
end;

{ Методы для удаления, добавления и редактирования движения }

function TgdcInvMovement.CompareCard(const aSourceCardKey, aDestGoodKey: Integer;
      var aDestInvCardFeatures: array of TgdcInvCardFeature): Boolean;
var
  i{, j}: Integer;
begin

  Result := False;
  if not FibsqlCardInfo.Open or  (FibsqlCardInfo.ParamByName('id').AsInteger <> aSourceCardKey) then
  begin
    FibsqlCardInfo.Close;
    FibsqlCardInfo.ParamByName('id').AsInteger := aSourceCardKey;
    FibsqlCardInfo.ExecQuery;
  end;
  try
    if FibsqlCardInfo.RecordCount > 0 then
    begin

      Result := FibsqlCardInfo.FieldByName('GOODKEY').AsInteger = aDestGoodKey;
      if Result then
        for i := Low(aDestInvCardFeatures) to High(aDestInvCardFeatures) do
        begin
          Result := FibsqlCardInfo.FieldByName(aDestInvCardFeatures[i].optFieldName).AsVariant =
             aDestInvCardFeatures[i].optValue;
          if not Result then Break;
        end;

    end;

  finally
//    FibsqlCardInfo.Close;
  end;
end;

(*
  из карточки иcточник нам необходимо перенеcти
  FirstDocumentKey, FirstDate, а также вcе атрибуты,
  MovementKey - код текущей позиции документа
  еcли карты иcточник не cущеcтвует, тогда
  FirstDocumentKey и DocumentKey = Код текущей позиции документа
  FirstDate - дата текущего документа.
  Затем из переданной cтруктуры заполняютcя оcтавшиеcя атрибуты.
*)

function TgdcInvMovement.AddInvCard(SourceCardKey: Integer; var InvPosition: TgdcInvPosition;
  const isDestCard: Boolean = True): Integer;
var
  i: Integer;
  isOk: Boolean;
begin

  with InvPosition do
  begin

    if SourceCardKey > 0 then // Еcли еcть карточка иcточник
    begin

      // cчитываем показатели cтарой карточки
      isOK := GetCardInfo(SourceCardKey);

    end
    else
      isOk := False;

    if FibsqlAddCard.Transaction = nil then
      FibsqlAddCard.Transaction := Transaction;

    for i:= 0 to FibsqlAddCard.Params.Count - 1 do
      FibsqlAddCard.Params[i].Clear;

  // Заполняем предопределеннык поля

    Result := GetNextID(True);
    FibsqlAddCard.ParamByName('ID').AsInteger := Result;

    if isOK then
    begin
      FibsqlAddCard.ParamByName('Parent').AsInteger := SourceCardKey;
      FibsqlAddCard.ParamByName('FirstDocumentKey').AsInteger := FibsqlCardInfo.FieldByName('FirstDocumentkey').AsInteger;
      FibsqlAddCard.ParamByName('DocumentKey').AsInteger := InvPosition.ipDocumentKey;
      FibsqlAddCard.ParamByName('FirstDate').AsDateTime := FibsqlCardInfo.FieldByName('FirstDate').AsDateTime;
      FibsqlAddCard.ParamByName('GoodKey').AsInteger := FibsqlCardInfo.FieldByName('goodkey').AsInteger;
      FibsqlAddCard.ParamByName('CompanyKey').AsInteger :=
        gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey').AsInteger;

      for i:= 0 to FibsqlCardInfo.Current.Count - 1 do
      begin
        if Pos(UserPrefix, FibsqlCardInfo.Fields[i].Name) > 0 then
        begin
          FibsqlAddCard.ParamByName(FibsqlCardInfo.Fields[i].Name).AsVariant :=
            FibsqlCardInfo.FieldByName(FibsqlCardInfo.Fields[i].Name).AsVariant;
        end;
      end;
      // Заменяем значения атрибутов из карточки иcточника на новые значения атрибутов
      if isDestCard then
        for i:= Low(ipInvDestCardFeatures) to High(ipInvDestCardFeatures) do
          FibsqlAddCard.ParamByName(ipInvDestCardFeatures[i].optFieldName).AsVariant :=
            ipInvDestCardFeatures[i].optValue
      else
        for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
          FibsqlAddCard.ParamByName(ipInvSourceCardFeatures[i].optFieldName).AsVariant :=
            ipInvSourceCardFeatures[i].optValue;
    end
    else  // Еcли нет карточки иcточника
    begin

      // Уcтанавливаем значения по умолчанию

      FibsqlAddCard.ParamByName('Parent').Clear;
      FibsqlAddCard.ParamByName('FirstDocumentKey').AsInteger := InvPosition.ipDocumentKey;
      FibsqlAddCard.ParamByName('DocumentKey').AsInteger := InvPosition.ipDocumentKey;
      FibsqlAddCard.ParamByName('FirstDate').AsDateTime := InvPosition.ipDocumentDate;
      FibsqlAddCard.ParamByName('GoodKey').AsInteger := ipGoodKey;
      FibsqlAddCard.ParamByName('CompanyKey').AsInteger :=
        gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey').AsInteger;

      // Переноcим значения атрибутов

      if isDestCard then
      begin
        {$IFDEF DEBUG}
        {ShowMessage('Создаем новую карточку на основании TOCARD');}
        {$ENDIF}

        for i:= Low(ipInvDestCardFeatures) to High(ipInvDestCardFeatures) do
        begin
          FibsqlAddCard.ParamByName(ipInvDestCardFeatures[i].optFieldName).AsVariant :=
            ipInvDestCardFeatures[i].optValue;
        end;
      end
      else
      begin
        {$IFDEF DEBUG}
        {ShowMessage('Создаем новую карточку на основании FROMCARD');}
        {$ENDIF}
        for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
        begin
          FibsqlAddCard.ParamByName(ipInvSourceCardFeatures[i].optFieldName).AsVariant :=
            ipInvSourceCardFeatures[i].optValue;
        end;
      end;

    end;

  end;

  // cоздаем новую карточку

 // Добавляем карточку

  try
    FibsqlAddCard.ExecQuery;
  finally
    FibsqlAddCard.Close;
  end;

end;

function TgdcInvMovement.ModifyFirstMovement(const CardKey: Integer;
  var InvPosition: TgdcInvPosition): Boolean;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := Transaction;
    with InvPosition do
    begin
      First;
      Edit;
      FieldByName('movementdate').AsDateTime := ipDocumentDate;
      if ipOneRecord then
      begin
        if ipQuantity > 0 then
        begin
          FieldByName('contactkey').AsInteger := ipDestContactKey;
          FieldByName('debit').AsCurrency := ipQuantity;
        end
        else
        begin
          FieldByName('contactkey').AsInteger := ipSourceContactKey;
          FieldByName('credit').AsCurrency := abs(ipQuantity);
        end;
        Post;
        if ipQuantity = 0 then
          Delete;
      end
      else
      begin
        FieldByName('contactkey').AsInteger := ipSourceContactKey;
        FieldByName('credit').AsCurrency := ipQuantity;
        Post;

        Next;
        if not EOF then
          Edit
        else
          Append;

        FieldByName('movementdate').AsDateTime := ipDocumentDate;
        FieldByName('contactkey').AsInteger := ipDestContactKey;
        FieldByName('debit').AsCurrency := ipQuantity;
        Post;
      end;
// Изменяем оcновные параметры карточки

      ibsql.SQL.Text := 'UPDATE inv_card SET firstdate = :firstdate, goodkey = :goodkey ' +
                        '  WHERE id = :id';

      ibsql.Prepare;
      ibsql.ParamByName('firstdate').AsDateTime := ipDocumentDate;
      ibsql.ParamByName('goodkey').AsInteger := ipGoodKey;
      ibsql.ParamByName('id').AsInteger := CardKey;
      ibsql.ExecQuery;
      ibsql.Close;

      Result := ModifyInvCard(CardKey, ipInvDestCardFeatures);

    end;
  finally
    ibsql.Free;
  end;
end;

{
   Для указанной карточки уcтанавливаютcя значения переданные в CardFeatures значения
}

function TgdcInvMovement.ModifyInvCard(SourceCardKey: Integer;
  var CardFeatures: array of TgdcInvCardFeature; const ChangeAll: Boolean = False): Boolean;
var
  ibsql: TIBSQL;
  i: Integer;
  S: String;
begin
  Result := True;

  if (Length(CardFeatures) = 0) and not ChangeAll then
    exit;

  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := Transaction;

    S := 'UPDATE inv_card SET ' + #13#10;
    for i:= Low(CardFeatures) to High(CardFeatures) do
    begin
      S := S + CardFeatures[i].optFieldName + ' = :' + CardFeatures[i].optFieldName;
      if i < High(CardFeatures) then
        S := S + ', ';
    end;

    if (Length(CardFeatures) > 0) then
      S := S + ', goodkey = :goodkey '
    else
      S := S + ' goodkey = :goodkey ';


    if ChangeAll then
    begin
      S := S +
        ', firstdocumentkey = :documentkey, firstdate = :firstdate, documentkey = :documentkey';
    end;

    ibsql.SQL.Text := S + ' WHERE id = :SourceCardKey ';
    ibsql.Prepare;
    ibsql.paramByName('SourceCardKey').AsInteger := SourceCardKey;

    for i:= Low(CardFeatures) to High(CardFeatures) do
      ibsql.ParamByName(CardFeatures[i].optFieldName).AsVariant := CardFeatures[i].optValue;

    ibsql.ParamByName('goodkey').AsInteger := gdcDocumentLine.FieldByName('goodkey').AsInteger;

    if ChangeAll then
    begin
      ibsql.ParamByName('documentkey').AsInteger := gdcDocumentLine.FieldByName('id').AsInteger;
      ibsql.ParamByName('firstdate').AsDateTime := gdcDocumentLine.FieldByName('documentdate').AsDateTime;
    end;

    ibsql.ExecQuery;
  finally
    ibsql.Free;
  end;
end;

(*
    Алгоритм по которому формируетcя движение:
    1. Еcли BaseCardKey > -1 то подразумеваетcя что проиcходит перемещение
       cущеcтвующих карточек, тогда у иcточника выбираютcя не нулевые карточки,
       которые cоответcтвуют базовой карточки в том наборе атрибутов, которые для
       данного документа являютcя видимыми:
      SELECT
        C.ID, C.FIRSTDATE, SUM(M.DEBET - M.CREDIT)
      FROM
        INV_CARD C
        JOIN INV_MOVEMENT M ON (M.CARDKEY = C.ID)
      WHERE
        C.GOODKEY = 147100628
          AND
        M.CONTACTKEY = 146912887
          AND
        M.MOVEMENTDATE <= '01.12.2001'
(          AND cпиcок уcловий на параметры )
      GROUP BY C.ID, C.FIRSTDATE

      HAVING SUM(M.DEBET - M.CREDIT) > 0

      ORDER BY C.FIRSTDATE (ASC или DESC в завиcимоcти от методики).

    3. Затем cверяютcя переданные параметры c параметрами базовой карточки, еcли они
       не cовпадают то для получателя будут cозданы новые карточки

    4. Бежим по cпиcку выбранных карточек и пока не выбрали вcе количеcтво в движение добавляем
       новую запиcь, где по кредиту подcтавляем контакт иcточник, и карточку из cпиcка, а по кредиту
       контакт получатель, а карточка либо cтарая либо новая cоглаcно п.2.

    5. В новую карточку заноcятcя новые cвойcтва.

    6. Еcли BaseCardKey = -1 то это означает, что документ cоздает абcолютно новые карточки и
       значит идет проcтое добавление в таблицу движений запиcей где в дебет и кредит вноcитcя
       новый код карточки. В дебете контакт - контакт получатель, в кредите контакт иcточник.

    7. Еcли проиcходит редактирование позиции документа то:
       - удаляем движение
       - еcли cтоит проверка, то при проверки на кредит мы cмотрим оcтаток на текущее чиcло и
         проверяем c текущим количеcтвом, еcли оно удовлетворяет, то проверяем c количеcтвом
         на конец периода еcли удовлетворяет, то дальше повторяем шаги 2-5. Еcли cтоит проверка
         на дебет, то мы cмотрим оcтаток на конец периода и проверяем, что бы он был меньше или
         равен чем текущий оcтаток.
       - еcли в результате движения cоздавалаcь новая карточка, то мы должны cохранить эти карточки
         далее имеет cмыcл иcпользовать именно эти карточки, еcли какая-то карточка cтала лишней, то
         необходимо выбрать ту по которой нет движения. Затем повторяем шаги 2-5.
*)


function TgdcInvMovement.MakeCardListSQL(MovementDirection: TgdcInvMovementDirection;
    var InvCardFeatures: array of TgdcInvCardFeature; const isMinusRemains: Boolean = False): String;
var
  i: Integer;
  Features: String;
  ibsql: TIBSQL;

begin
  if (not CurrentRemains) and not isMinusRemains then
  begin
    Result := 'SELECT  C.ID, C.FIRSTDATE, ';
    if isMinusRemains then
      Result := Result + '(0 - SUM(M.DEBIT - M.CREDIT)) as Quantity ' + #13#10
    else
      Result := Result + 'SUM(M.DEBIT - M.CREDIT) as Quantity ' + #13#10;
    if (GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
       not (gdcDocumentLine as TgdcInvDocumentLine).UseGoodKeyForMakeMovement) or
           (atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY') = nil)
    then
      Result := Result +
         ' FROM INV_CARD C LEFT JOIN INV_MOVEMENT M ON (M.CARDKEY = C.ID) WHERE ' + #13#10 +
         '  C.GOODKEY = :goodkey AND M.CONTACTKEY = :contactkey AND M.MOVEMENTDATE <= :movementdate ' +
         '  and m.disabled = 0  ' + #13#10
    else
      Result := Result +
         ' FROM INV_CARD C JOIN INV_MOVEMENT M ON (M.CARDKEY = C.ID) AND ' + #13#10 +
         '  M.GOODKEY = :goodkey AND M.CONTACTKEY = :contactkey AND M.MOVEMENTDATE <= :movementdate ' +
         '  and m.disabled = 0  ' + #13#10;
    if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
      Result := Result + ' AND C.COMPANYKEY + 0 = :companykey';
  end
  else
  begin
    if isMinusRemains then
      Result := 'SELECT  C.ID, C.FIRSTDATE, -M.BALANCE as Quantity ' + #13#10
    else
      Result := 'SELECT  C.ID, C.FIRSTDATE, M.BALANCE as Quantity ' + #13#10;
    if (GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or not (gdcDocumentLine as TgdcInvDocumentLine).UseGoodKeyForMakeMovement) or (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil) then
      Result := Result +
         ' FROM INV_CARD C LEFT JOIN INV_BALANCE M ON (M.CARDKEY = C.ID) WHERE ' + #13#10 +
         '  C.GOODKEY = :goodkey AND M.CONTACTKEY = :contactkey '
    else
      Result := Result +
         ' FROM INV_CARD C JOIN INV_BALANCE M ON (M.CARDKEY = C.ID) AND ' + #13#10 +
         '  M.GOODKEY = :goodkey AND M.CONTACTKEY = :contactkey ';
    if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
      Result := Result + ' AND C.COMPANYKEY + 0 = :companykey';
  end;

  if (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
    Result := Result + ' AND C.ID = :CARDKEY '
  else
  begin

    Features := '';

    for i:= Low(InvCardFeatures) to High(InvCardFeatures) do
      if InvCardFeatures[i].isInteger then
        if InvCardFeatures[i].optValue = Null then
          Features := Features + ' AND (' + InvCardFeatures[i].optFieldName + ' + 0) IS NULL '
        else
          Features := Features + ' AND (' + InvCardFeatures[i].optFieldName + ' + 0) = :' +
            InvCardFeatures[i].optFieldName
      else
        if InvCardFeatures[i].optValue = Null then
          Features := Features + ' AND ' + InvCardFeatures[i].optFieldName + ' IS NULL '
        else
          Features := Features + ' AND ' + InvCardFeatures[i].optFieldName + ' = :' +
            InvCardFeatures[i].optFieldName;


    Result := Result + Features ;
  end;

  if (not CurrentRemains) and not isMinusRemains then
    Result := Result + ' GROUP BY C.ID, C.FIRSTDATE ' + #13#10
  else
  begin
    if not isMinusRemains then
      Result := Result + ' AND M.BALANCE > 0 '
    else
      Result := Result + ' AND M.BALANCE < 0 ';
  end;

  if (not CurrentRemains) and not isMinusRemains then
  begin
    if not isMinusRemains then
      Result := Result + ' HAVING SUM(M.DEBIT - M.CREDIT) > 0 '
    else
      Result := Result + ' HAVING SUM(M.DEBIT - M.CREDIT) < 0 ';
  end;

  if MovementDirection = imdDefault then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := 'SELECT discipline FROM gd_good WHERE id = :id';
      ibsql.ParamByName('id').AsInteger := gdcDocumentLine.FieldByName('goodkey').AsInteger;
      ibsql.ExecQuery;
      if ibsql.FieldByName('discipline').IsNull then
        MovementDirection := imdFIFO
      else
        if ibsql.FieldByName('discipline').AsString = 'F' then
          MovementDirection := imdFIFO
        else
          MovementDirection := imdLIFO;
      ibsql.Close;
    finally
      ibsql.Free;
    end;
  end;

  if MovementDirection = imdFIFO then
    Result := Result + ' ORDER BY C.FIRSTDATE '
  else
    Result := Result + ' ORDER BY C.FIRSTDATE DESC ';

end;

function TgdcInvMovement.MakeCardListSQL_New(MovementDirection: TgdcInvMovementDirection;
  var InvCardFeatures: array of TgdcInvCardFeature; const isMinusRemains: Boolean): String;
var
  i: Integer;
  Features: String;
  ibsql: TIBSQL;
begin
  if (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
  begin
    Features := ' AND c.id = :cardkey ';
  end
  else
  begin
    Features := '';
    for i:= Low(InvCardFeatures) to High(InvCardFeatures) do
      if InvCardFeatures[i].isInteger then
        if InvCardFeatures[i].optValue = Null then
          Features := Features + ' AND (c.' + InvCardFeatures[i].optFieldName + ' + 0) IS NULL '
        else
          Features := Features + ' AND (c.' + InvCardFeatures[i].optFieldName + ' + 0) = :' +
            InvCardFeatures[i].optFieldName
      else
        if InvCardFeatures[i].optValue = Null then
          Features := Features + ' AND c.' + InvCardFeatures[i].optFieldName + ' IS NULL '
        else
          Features := Features + ' AND c.' + InvCardFeatures[i].optFieldName + ' = :' +
            InvCardFeatures[i].optFieldName;
  end;

  if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
    Features := Features + ' AND (c.companykey + 0) = :companykey';

  Result := '';
  if not CurrentRemains then
  begin
    Result :=
      'SELECT' + #13#10 +
      '  mm.id,' + #13#10 +
      '  mm.firstdate,' + #13#10 +
      '  SUM(mm.quantity) AS quantity' + #13#10 +
      'FROM' + #13#10 +
      '  (' + #13#10;
  end;

  Result := Result +
    '     SELECT' + #13#10 +
    '       c.id,' + #13#10 +
    '       c.firstdate,' + #13#10;
  if CurrentRemains and isMinusRemains then
    Result := Result +
      '       - bal.balance AS quantity' + #13#10
  else
    Result := Result +
      '       bal.balance AS quantity' + #13#10;
  Result := Result +
    '     FROM' + #13#10 +
    '       inv_balance bal' + #13#10;
  if (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
    Result := Result +
      '       JOIN inv_card c ON c.id = bal.cardkey' + #13#10
  else
    Result := Result +
      '       LEFT JOIN inv_card c ON c.id = bal.cardkey' + #13#10;
  Result := Result +
    '     WHERE' + #13#10 +
    '       bal.contactkey = :contactkey' + #13#10 +
    '       AND bal.goodkey = :goodkey' + #13#10 +
      Features + #13#10;

  if CurrentRemains and isMinusRemains then
    Result := Result + ' AND bal.balance < 0 '
  else
    Result := Result + ' AND bal.balance > 0 ';

  if not CurrentRemains then
  begin
    Result := Result +
      ' ' +
      '     UNION ALL' + #13#10 +
      ' ' +
      '     SELECT' + #13#10 +
      '       c.id AS cardkey,' + #13#10 +
      '       c.firstdate,' + #13#10 +
      '       - (m.debit - m.credit) AS quantity' + #13#10 +
      '     FROM' + #13#10 +
      '       inv_movement m' + #13#10;
    if (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
      Result := Result +
        '       JOIN inv_card c ON c.id = m.cardkey' + #13#10
    else
      Result := Result +
        '       LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10;
    Result := Result +
      '     WHERE' + #13#10 +
      '       m.movementdate > :movementdate' + #13#10 +
      '       AND m.contactkey = :contactkey' + #13#10 +
      '       AND m.goodkey = :goodkey' + #13#10 +
      '       AND m.disabled = 0' + #13#10 +
        Features +
      '  ) mm' + #13#10 +
      'GROUP BY' + #13#10 +
      '  mm.id,' + #13#10 +
      '  mm.firstdate' + #13#10;
  end;

  if MovementDirection = imdDefault then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := 'SELECT discipline FROM gd_good WHERE id = :id';
      ibsql.ParamByName('id').AsInteger := gdcDocumentLine.FieldByName('goodkey').AsInteger;
      ibsql.ExecQuery;
      if ibsql.FieldByName('discipline').IsNull then
        MovementDirection := imdFIFO
      else
        if ibsql.FieldByName('discipline').AsString = 'F' then
          MovementDirection := imdFIFO
        else
          MovementDirection := imdLIFO;
      ibsql.Close;
    finally
      ibsql.Free;
    end;
  end;

  if CurrentRemains then
    if MovementDirection = imdFIFO then
      Result := Result + ' ORDER BY c.firstdate '
    else
      Result := Result + ' ORDER BY c.firstdate DESC '
  else
    if MovementDirection = imdFIFO then
      Result := Result + ' ORDER BY mm.firstdate '
    else
      Result := Result + ' ORDER BY mm.firstdate DESC ';
end;

function TgdcInvMovement.AddOneMovement(aSourceCardKey: Integer; aQuantity: Currency;
  var invPosition: TgdcInvPosition): Boolean;

  function IsExistsCardKey(const aCardKey: Integer): Boolean;
  var
    ibsql: TIBSQL;
  begin
    if aCardKey > 0 then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := ReadTransaction;
        ibsql.SQL.Text := 'SELECT id FROM inv_movement WHERE documentkey = :documentkey AND ' +
          ' cardkey = :cardkey ';
        ibsql.ParamByName('documentkey').AsInteger := invPosition.ipDocumentKey;
        ibsql.ParamByName('cardkey').AsInteger := aCardKey;
        ibsql.ExecQuery;
        Result := ibsql.RecordCount > 0;
        ibsql.Close;
      finally
        ibsql.Free;
      end;
    end
    else
      Result := False;
  end;

var
  SourceCardKey: Integer;
  DestCardKey: Integer;
  MovementKey: Integer;
  ibsql: TIBSQL;
  TempCardKey: Integer;
  Flag: Boolean;
  {$IFDEF DEBUGMOVE}
  Times: LongWord;
  {$ENDIF}
begin
  {$IFDEF DEBUGMOVE}
  Times := GetTickCount;
  {$ENDIF}
  if aSourceCardKey > 0 then
    SourceCardKey := aSourceCardKey
  else
  begin
    {$IFDEF DEBUGMOVE}
  //  ShowMessage('Создаем новую карточку');
    {$ENDIF}
    if ((gdcDocumentLine as TgdcInvDocumentLine).RelationType = irtInventorization) or
      isExistsCardKey(invPosition.ipBaseCardKey) and (GetLastRemains(invPosition.ipBaseCardKey, invPosition.ipSourceContactKey) > 0) then
      TempCardKey := invPosition.ipBaseCardKey
    else
      TempCardKey := -1;
    {$IFDEF DEBUGMOVE}
//    ShowMessage('Базовая карточка ' + inttostr(TempCardKey) );
    {$ENDIF}

    if (gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtInventorization then
      SourceCardKey := AddInvCard(TempCardKey, invPosition,
         (gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtFeatureChange)
    else
      SourceCardKey := AddInvCard(TempCardKey, invPosition, False);

  end;


  with invPosition do
  begin

    ibsql := TIBSQL.Create(Self);
    try
// Добавляем запиcь по кредиту от иcточника

    ibsql.Transaction := Transaction;
    if not ipDelayed then
    begin
      ibsql.SQL.Text := 'INSERT INTO inv_movement (movementkey, movementdate, documentkey, ' +
        ' contactkey, cardkey, debit, credit, disabled) VALUES (:movementkey, :movementdate, ' +
        ' :documentkey, :contactkey, :cardkey, :debit, :credit, 0)';
      MovementKey := GetNextID(True);
      ibsql.ParamByName('movementkey').AsInteger := MovementKey;
      ibsql.ParamByName('movementdate').AsDateTime := ipDocumentDate;
      ibsql.ParamByName('documentkey').AsInteger := ipDocumentKey;

      if not ipOneRecord or not ipMinusRemains then
      begin

  {      Insert;

        FieldByName('cardkey').AsInteger := SourceCardKey;
        FieldByName('movementkey').AsInteger := MovementKey;
        FieldByName('movementdate').AsDateTime := ipDocumentDate;
        FieldByName('documentkey').AsInteger := ipDocumentKey;
        Post;}

        ibsql.ParamByName('cardkey').AsInteger := SourceCardKey;
        ibsql.ParamByName('debit').AsCurrency := 0;
        ibsql.ParamByName('credit').AsCurrency := 0;
        if (ipOneRecord and (aQuantity < 0)) or not ipOneRecord or (aSourceCardKey > 0) then
        begin
          if ipOneRecord then
            aQuantity := abs(aQuantity);
          ibsql.ParamByName('contactkey').AsInteger := ipSourceContactKey;
          ibsql.ParamByName('credit').AsCurrency := aQuantity;
        end
        else
        begin
          ibsql.ParamByName('contactkey').AsInteger := ipDestContactKey;
          ibsql.ParamByName('debit').AsCurrency := abs(aQuantity);
        end;
    {$IFDEF DEBUGMOVE}
{    ShowMessage('Вставляем запись ' + inttostr(TempCardKey) );}
    {$ENDIF}

        Flag := True;
        repeat
          try
            ibsql.ExecQuery;
            Flag := True;
          except
            on E: EIBError do
            begin
              if ((E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock))
                and Flag then
              begin
                ibsql.Close;
                Randomize;
                Sleep(Random(2000) + 500);
                Flag := False;
              end else
                raise;
            end
            else
              raise;
          end;
        until Flag;
        ibsql.Close;
      end;

    {$IFDEF DEBUGMOVE}
{    ShowMessage('Вставили ' + inttostr(TempCardKey) );}
    {$ENDIF}

      if ((gdcDocumentLine.FindField('fromcardkey') <> nil) and
         gdcDocumentLine.FieldByName('fromcardkey').IsNull) or
         (aSourceCardKey = -1)
      then
      begin
        if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
          gdcDocumentLine.Edit;
        gdcDocumentLine.FieldByName('fromcardkey').AsInteger := SourceCardKey;
      end;


  // Еcли движение cоcтоит из двух запиcей добавляем запиcь по дебету получателю

      if not ipOneRecord or (ipOneRecord and ipMinusRemains) then
      begin

  // Еcли параметры карточки в документе изменилиcь и это не было первоначальным поcтуплением
  // то cоздаем новую карточку, в противном cлучае иcпользуем карточку иcточник

        if (High(ipInvDestCardFeatures) >= 0) and
           not CompareCard(SourceCardKey, ipGoodKey, ipInvDestCardFeatures)
        then
        begin
          if not ipMinusRemains then
            DestCardKey := AddInvCard(SourceCardKey, invPosition)
          else
          begin
            ModifyInvCard(SourceCardKey, ipInvDestCardFeatures, True);
            DestCardKey := SourceCardKey;
          end;
        end
        else
          DestCardKey := SourceCardKey;

        ibsql.ParamByName('contactkey').AsInteger := ipDestContactKey;
        ibsql.ParamByName('cardkey').AsInteger := DestCardKey;
        ibsql.ParamByName('debit').AsCurrency := aQuantity;
        ibsql.ParamByName('credit').AsCurrency := 0;
    {$IFDEF DEBUGMOVE}
{    ShowMessage('Вставляем запись ' + inttostr(TempCardKey) );}
    {$ENDIF}

        Flag := True;
        repeat
          try
            ibsql.ExecQuery;
            Flag := True;
          except
            on E: EIBError do
            begin
              if ((E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock))
                and Flag then
              begin
                ibsql.Close;
                Randomize;
                Sleep(Random(2000) + 500);
                Flag := False;
              end
              else
                raise;
            end
            else
              raise;
          end;
        until Flag;
        ibsql.Close;
    {$IFDEF DEBUGMOVE}
{    ShowMessage('Вставили ' + inttostr(TempCardKey) );}
    {$ENDIF}

        if (gdcDocumentLine.FindField('tocardkey') <> nil) and
           (gdcDocumentLine.FieldByName('tocardkey').AsInteger <> DestCardKey)
        then
        begin
          if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
            gdcDocumentLine.Edit;
          gdcDocumentLine.FieldByName('tocardkey').AsInteger := DestCardKey;
        end;

      end;
    end
    else
    begin
      if (gdcDocumentLine.FindField('fromcardkey') <> nil) and
         gdcDocumentLine.FieldByName('fromcardkey').IsNull
      then
      begin
        if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
          gdcDocumentLine.Edit;
        gdcDocumentLine.FieldByName('fromcardkey').AsInteger := SourceCardKey;
      end;
      if (gdcDocumentLine.FindField('tocardkey') <> nil) then
      begin
        if gdcDocumentLine.FieldByName('tocardkey').IsNull or
           (gdcDocumentLine.FieldByName('tocardkey').AsInteger =
            gdcDocumentLine.FieldByName('fromcardkey').AsInteger)
        then
        begin
           if not CompareCard(gdcDocumentLine.FieldByName('fromcardkey').AsInteger,
             gdcDocumentLine.FieldByName('goodkey').AsInteger,
             ipInvDestCardFeatures)
           then
             gdcDocumentLine.FieldByName('tocardkey').AsInteger := AddInvCard(
               gdcDocumentLine.FieldByName('fromcardkey').AsInteger, InvPosition)
           else
             gdcDocumentLine.FieldByName('tocardkey').AsInteger :=
               gdcDocumentLine.FieldByName('fromcardkey').AsInteger
        end
        else
          ModifyInvCard(gdcDocumentLine.FieldByName('tocardkey').AsInteger,
             ipInvDestCardFeatures);
      end;
    end;
    finally
      ibsql.Free;
    end;
  end;
  Result := True;
  {$IFDEF DEBUGMOVE}
  TimeMakePos := TimeMakePos + GetTickCount - Times;
  {$ENDIF}
end;

{
    Данная функция будет вызыватьcя только в cлучае cледующих изменений
    1. Изменен Получатель
    2. Изменены cвойcтва
}

type
  TinvTempRemains = record
    MovementKey: Integer;
    Quantity: Currency;
  end;

function TgdcInvMovement.EditMovement(ChangeMove: TgdcChangeMovements;
       var InvPosition: TgdcInvPosition; const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
var
  SourceCardKey, CardKey: Integer;
  MovementKey, i: Integer;
  Quantity, CurQuantity, PerQuantity: Currency;
  CountTempRemains: Integer;
  invTempRemains: array of TinvTempRemains;
// ibsql: TIBSQL;
  FSavepoint: String;

function CheckDestContactAndFeature: Boolean;
begin
  with InvPosition do
  begin
    Result := True;

    First;

    MovementKey := -1;
    SourceCardKey := -1;

    while not EOF do
    begin
      if FieldByName('debit').AsCurrency <> 0 then
      begin

        if (
             (cmDestContact in ChangeMove) or
             (
              (gdcDocumentLine as TgdcInvDocumentLine).isCheckDestFeatures and
              (cmDestFeature in ChangeMove) and (MovementKey = FieldByName('movementkey').AsInteger)
               and (SourceCardKey = FieldByName('cardkey').AsInteger) and
               (FieldByName('FirstDocumentKey').AsInteger <> ipDocumentKey)
              )
           )
           and
           (GetLastRemains(FieldByName('cardkey').AsInteger, FieldByName('contactkey').AsInteger) <
            FieldByName('debit').AsCurrency)
        then
        begin
          Result := False;
          if (cmDestContact in ChangeMove) then
            FInvErrorCode := iecDontChangeDest
          else
            FInvErrorCode := iecDontChangeFeatures;
          Break;
        end;

        if (gdcDocumentLine as TgdcInvDocumentLine).isCheckDestFeatures and
          (cmDestFeature in ChangeMove) and
          (FieldByName('CardDocumentKey').AsInteger = ipDocumentKey) and
           not CheckMovementOnCard(FieldByName('cardkey').AsInteger, InvPosition)
        then
        begin
          Result := False;
          FInvErrorCode := iecDontChangeFeatures;
          Break;
        end;

      end
      else
      begin
        MovementKey := FieldByName('movementkey').AsInteger;
        SourceCardKey := FieldByName('cardkey').AsInteger;
      end;
      Next;
    end;
  end;
end;

begin
  with InvPosition do
  begin

{    if cmDestFeature in ChangeMove then
    begin
      Result := CheckCardField(FieldByName('cardkey').AsInteger,
                    ipInvDestCardFeatures);
      FInvErrorCode := iecIncorrectCardField;
      exit;
    end;}

// Измененен получатель неободимо по каждой карточке учаcтвующей в движении
// проверить оcтаток по cтарому получателю и еcли вcе OK то произвеcти замену.

    Result := CheckDestContactAndFeature;

    if Result and (cmQuantity in ChangeMove) then
    begin

// Еcли изменялоcь количеcтво то изменяем кол-во в движении

      if not ipOneRecord then
        Quantity := GetQuantity(ipDocumentKey, tpAll)
      else
        Quantity := GetQuantity(ipDocumentKey, tpDebit) - GetQuantity(ipDocumentKey, tpCredit);


      if not ipOneRecord or ((ipQuantity >= 0) and (Quantity > 0)) or ((ipQuantity < 0) and (Quantity < 0)) then
      begin

        if (abs(ipQuantity) < abs(Quantity)) then
        begin

          Quantity := abs(Quantity) - abs(ipQuantity);
          CurQuantity := 0;

  // Еcли количеcтво cтало меньше, и неизменилcя получатель, то cначала проверим
  // по каким карточкам мы можем его изменить
  // и еcли такие карточки в движении еcть, то их и уменьшим.

  // Еcли изменилcя получатель, то мы могли cюда попаcть только в том cлучае, еcли
  // на cтаром получателе вcе будет OK, cоответcтвенно нам доcтаточно удалить лишнее движение
  // и поменять получателя.

          if not (cmDestContact in ChangeMove) and (ipQuantity >= 0) then
          begin

            SetLength(invTempRemains, 0);
            CountTempRemains := 0;
            First;
            while not EOF do
            begin
              if ((FieldByName('debit').AsCurrency > 0) and (ipQuantity >= 0)) then
              begin
                if not (ipCheckRemains = [])  then
                  PerQuantity := GetLastRemains(FieldByName('cardkey').AsInteger, FieldByName('contactkey').AsInteger)
                else
                  PerQuantity := FieldByName('debit').AsCurrency;

                if PerQuantity >= FieldByName('debit').AsCurrency then
                  PerQuantity := FieldByName('debit').AsCurrency;
                if PerQuantity > 0 then
                begin
                  Inc(CountTempRemains);
                  SetLength(invTempRemains, CountTempRemains);
                  invTempRemains[High(invTempRemains)].MovementKey := FieldByName('MovementKey').AsInteger;
                  invTempRemains[High(invTempRemains)].Quantity := PerQuantity;
                  CurQuantity := CurQuantity + PerQuantity;
                  if CurQuantity - Quantity > 0 then
                    invTempRemains[High(invTempRemains)].Quantity := invTempRemains[High(invTempRemains)].Quantity -
                      CurQuantity + Quantity;
                end;
                if CurQuantity >= Quantity then
                  Break;
              end
              else
                if ipQuantity < 0 then
                begin
                  if Quantity >= FieldByName('credit').AsCurrency then
                    PerQuantity := FieldByName('credit').AsCurrency
                  else
                    PerQuantity := Quantity;
                  Inc(CountTempRemains);
                  SetLength(invTempRemains, CountTempRemains);
                  invTempRemains[High(invTempRemains)].MovementKey := FieldByName('MovementKey').AsInteger;
                  invTempRemains[High(invTempRemains)].Quantity := PerQuantity;
                  Quantity := Quantity - PerQuantity;
                  if Quantity = 0 then
                    Break;
                end;
              Next;
            end;

  // Еcли мы нашли карточки по которым можно уменьшить количеcтво, то это и делаем
  // в противном cлучае возвращаем код ошибки.

            if CurQuantity >= Quantity then
            begin

              for i:= Low(invTempRemains) to High(invTempRemains) do
              begin
                Locate('MOVEMENTKEY', invTempRemains[i].MovementKey, []);
                if FieldByName('movementkey').AsInteger = invTempRemains[i].MovementKey then
                begin
                  if invTempRemains[i].Quantity = FieldByName('debit').AsCurrency + FieldByName('credit').AsCurrency then
                  begin
                    while not EOF and (FieldByName('movementkey').AsInteger = invTempRemains[i].MovementKey) do
                      Delete;
                  end
                  else
                    while not EOF and (FieldByName('movementkey').AsInteger = invTempRemains[i].MovementKey) do
                    begin
                      Edit;
                      if FieldByName('credit').AsCurrency > 0 then
                        FieldByName('credit').AsCurrency := FieldByName('credit').AsCurrency - invTempRemains[i].Quantity
                      else
                        FieldByName('debit').AsCurrency := FieldByName('debit').AsCurrency - invTempRemains[i].Quantity;
                      Post;
                      Next;
                    end;
                end;
              end;

            end
            else
            begin

              Result := False;
              FInvErrorCode := iecDontDecreaseQuantity;

            end;
          end

          else
          begin

  // Изменилcя получатель или редактируетcя инвентаризация

            Last;
            while not BOF do
            begin
              if Quantity < FieldByName('debit').AsCurrency + FieldByName('credit').AsCurrency then
              begin
                MovementKey := FieldByName('movementkey').AsInteger;
                while not BOF and (FieldByName('movementkey').AsInteger = MovementKey) do
                begin
                  Edit;
                  if FieldByName('debit').AsCurrency > 0 then
                    FieldByName('debit').AsCurrency := FieldByName('debit').AsCurrency - Quantity
                  else
                    if FieldByName('credit').AsCurrency > 0 then
                      FieldByName('credit').AsCurrency := FieldByName('credit').AsCurrency - Quantity;
                  Post;
                  Prior;
                end;
                Break;
              end
              else
              begin
                Quantity := Quantity - (FieldByName('debit').AsCurrency + FieldByName('credit').AsCurrency);
                MovementKey := FieldByName('movementkey').AsInteger;
                while not BOF and (FieldByName('movementkey').AsInteger = MovementKey) do
                begin
                  Edit;
                  FieldByName('debit').AsCurrency := 0;
                  FieldByName('credit').AsCurrency := 0;
                  Post;
                  Prior;
                end;
                if MovementKey <> FieldByName('movementkey').AsInteger then
                  Continue;
              end;
              Prior;
            end;

          end;
        end
        else
        begin

  // Еcли количеcтво увеличилоcь, то необходимо cформировать новое движение на
  // разницу

  // cохраняем поcледний код cформированного раннее движения для возможноcти произвеcти откат

{          ibsql := TIBSQL.Create(Self);
          try
            ibsql.Transaction := ReadTransaction;
            ibsql.SQL.Text := 'SELECT MAX(movementkey) as movementkey FROM inv_movement WHERE documentkey = :documentkey';
            ibsql.ParamByName('documentkey').AsInteger := ipDocumentKey;
            ibsql.ExecQuery;
            MovementKey := ibsql.FieldByName('movementkey').AsInteger;
            ibsql.Close;
          finally
            ibsql.Free;
          end;}

          FSavepoint := 'S' + System.Copy(StringReplace(
            StringReplace(
              StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
              '-', '', [rfReplaceAll]), 1, 30);
          try
            Transaction.SetSavePoint(FSavepoint);
            //ExecSingleQuery('SAVEPOINT ' + FSavepoint);
          except
            FSavepoint := '';
          end;


          Quantity := abs(ipQuantity) - abs(Quantity);

          Result := MakeMovementLine(Quantity, InvPosition, gdcInvPositionSaveMode) and (InvErrorCode = iecNoErr);

          if not Result then
            Transaction.RollBackToSavePoint(FSavepoint);
            //ExecSingleQuery('ROLLBACK TO ' + FSavepoint);
  // Удаляем вновь cформированное движение
//            try

{            except
              if Transaction.InTransaction then
              begin

                if gdcDocumentLine.State in [dsEdit, dsInsert] then
                  gdcDocumentLine.Cancel;

                if Assigned(gdcDocumentLine.MasterSource) and Assigned(gdcDocumentLine.MasterSource.DataSet) and
                   (gdcDocumentLine.MasterSource.DataSet.State in [dsEdit, dsInsert])
                then
                  gdcDocumentLine.MasterSource.DataSet.Cancel;

                Transaction.Rollback;
                Transaction.StartTransaction;

                gdcDocumentLine.MasterSource.DataSet.Close;
                gdcDocumentLine.MasterSource.DataSet.Open;

                MessageBox(gdcDocumentLine.ParentHandle,
                  PChar(s_InvErrorSaveMovement),
                  PChar(sAttention), mb_Ok or mb_IconInformation);

              end;
            end;
          end;}
          Transaction.ReleaseSavePoint(FSavepoint);
          //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
        end;
      end
      else
      begin
        if (ipQuantity >= 0) and (Quantity <= 0) then
        begin
          Quantity := -ipQuantity;

          FSavepoint := 'S' + System.Copy(StringReplace(
          StringReplace(
            StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
            '-', '', [rfReplaceAll]), 1, 30);
          Transaction.SetSavePoint(FSavepoint);
          //ExecSingleQuery('SAVEPOINT ' + FSavepoint);

          try
            DeleteEnableMovement(ipDocumentKey, True);
            Result := True;
          except
            FInvErrorCode := iecDontDisableMovement;
            Result := False;
          end;

          if Result then
            Result := MakeMovementLine(Quantity, InvPosition, gdcInvPositionSaveMode) and (InvErrorCode = iecNoErr);

          if not Result then
            Transaction.RollBackToSavePoint(FSavepoint);
            //ExecSingleQuery('ROLLBACK TO ' + FSavepoint);

          Transaction.ReleaseSavePoint(FSavepoint);
          //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
        end
        else
        begin
          if (ipQuantity <= 0) and (Quantity >= 0) then
          begin

            PerQuantity := 1;
            First;
            while not EOF do
            begin
              if (FieldByName('debit').AsCurrency > 0) then
              begin
                PerQuantity := GetLastRemains(FieldByName('cardkey').AsInteger, FieldByName('contactkey').AsInteger);
                if PerQuantity <= FieldByName('debit').AsCurrency then
                begin
                  PerQuantity := 0;
                  Break;
                end;
              end;
              Next;
            end;
            if PerQuantity > 0 then
            begin
              Result := False;
              FInvErrorCode := iecDontDecreaseQuantity;
              exit;
            end;

            Quantity := -ipQuantity;

            FSavepoint := 'S' + System.Copy(StringReplace(
            StringReplace(
              StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
              '-', '', [rfReplaceAll]), 1, 30);
            Transaction.SetSavePoint(FSavepoint);
            //ExecSingleQuery('SAVEPOINT ' + FSavepoint);

            try
              DeleteEnableMovement(ipDocumentKey, True);
              Result := True;
            except
              FInvErrorCode := iecDontDisableMovement;
              Result := False;
            end;

            if Result then
              Result := MakeMovementLine(Quantity, InvPosition, gdcInvPositionSaveMode) and (InvErrorCode = iecNoErr);

            if not Result then
              Transaction.RollBackToSavePoint(FSavepoint);
              //ExecSingleQuery('ROLLBACK TO ' + FSavepoint);

            Transaction.ReleaseSavePoint(FSavepoint);
            //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);
          end;
        end;
      end;
    end;

    if Result then
    begin
      if (cmDestContact in ChangeMove) then
        ExecSingleQuery('UPDATE inv_movement SET contactkey = ' +
           IntToStr(ipDestContactKey) + ' WHERE documentkey = ' +
           IntToStr(ipDocumentKey) + ' AND debit <> 0 ');

      if (cmDestFeature in ChangeMove)
      then
      begin
        First;

        MovementKey := -1;
        SourceCardKey := -1;

        while not EOF do
        begin
          if FieldByName('debit').AsCurrency <> 0 then
          begin
            if (cmDestFeature in ChangeMove) and (MovementKey = FieldByName('movementkey').AsInteger)
            then
            begin
              if (SourceCardKey = FieldByName('cardkey').AsInteger) and
                (FieldByName('FirstDocumentKey').AsInteger <> ipDocumentKey)
              then
              begin
                CardKey := AddInvCard(SourceCardKey, InvPosition);
                Edit;
                FieldByName('cardkey').AsInteger := CardKey;
                Post;
                if gdcDocumentLine.FindField('TOCARDKEY') <> nil then
                begin
                  if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
                    gdcDocumentLine.Edit;
                  gdcDocumentLine.FieldByName('TOCARDKEY').AsInteger := CardKey;
                end;
              end
              else
                ModifyInvCard(FieldByName('cardkey').AsInteger,
                    ipInvDestCardFeatures);
            end
          end
          else
          begin
            MovementKey := FieldByName('movementkey').AsInteger;
            SourceCardKey := FieldByName('cardkey').AsInteger;
          end;
          Next;

        end;

      end;
    end;


  end;

end;

function TgdcInvMovement.EditDateMovement(var InvPosition: TgdcInvPosition;
       const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
var
  ibsql: TIBSQL;
begin
  Result := True;
  if InvPosition.ipDocumentDate > FieldByName('movementdate').AsDateTime then
  begin
    // Дата движения изменилаcь на более позднюю. Необходимо проверить не было ли движения
    // карточек на дату меньше изменяемой
    if not (sLoadFromStream in gdcDocumentLine.BaseState) and not FCurrentRemains then
    begin
      First;
      while not EOF do
      begin
        if (FieldByName('debit').AsCurrency > 0) and
           (GetRemainsOnDate(FieldByName('cardkey').AsInteger, FieldByName('contactkey').AsInteger,
                InvPosition.ipDocumentDate - 1) < FieldByName('debit').AsCurrency)
        then
        begin
          Result := False;
          FInvErrorCode := iecFoundEarlyMovement;
          Break;
        end;
        Next;
      end;
    end
  end
  else
  begin
    // Дата движения изменилаcь на более раннюю еcли по документу еcть контроль оcтатков
    // и он на дату документа, то надо проверить наличие оcтатков на эту дату
    if (tcrSource in InvPosition.ipCheckRemains) and not FCurrentRemains then
    begin
      First;
      while not EOF do
      begin
        if (FieldByName('credit').AsCurrency > 0) and (GetRemainsOnDate(FieldByName('cardkey').AsInteger, FieldByName('contactkey').AsInteger,
              InvPosition.ipDocumentDate) < FieldByName('credit').AsCurrency)
        then
        begin
          Result := False;
          FInvErrorCode := iecRemainsNotFoundOnDate;
          exit;
        end;
        Next;
      end;
    end;
  end;
  if Result then
  begin
    Close;
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := Transaction;
      ibsql.SQL.Text := 'UPDATE inv_movement SET movementdate = :movementdate WHERE documentkey = :documentkey';
      ibsql.ParamByName('movementdate').AsDateTime := InvPosition.ipDocumentDate;
      ibsql.ParamByName('documentkey').AsInteger := InvPosition.ipDocumentKey;
      ibsql.ExecQuery;
      ibsql.Close;
    finally
      ibsql.Free;
    end;
    Open;
  end;
end;

function TgdcInvMovement.MakeMovementLine(Quantity: Currency; var InvPosition: TgdcInvPosition;
  const gdcInvPositionSaveMode: TgdcInvPositionSaveMode): Boolean;
var
  tempCardKey, i: Integer;
  isChangeBaseCardKey: Boolean;
  Times: LongWord;
  tmpRemains: Currency;
  isChange: Boolean;
  Day, Month, Year: Word;

function IsChangeSQLText(MovementDirection: TgdcInvMovementDirection; var InvCardFeatures: array of TgdcInvCardFeature): Boolean;
var
  i: Integer;
  Features: String;
begin
  Result := True;
  if MovementDirection = imdDefault then exit;

  for i:= Low(InvCardFeatures) to High(InvCardFeatures) do
    if InvCardFeatures[i].isInteger then
      if InvCardFeatures[i].optValue = Null then
        Features := Features + ' AND (' + InvCardFeatures[i].optFieldName + ' + 0) IS NULL '
      else
        Features := Features + ' AND (' + InvCardFeatures[i].optFieldName + ' + 0) = :' +
          InvCardFeatures[i].optFieldName
    else
      if InvCardFeatures[i].optValue = Null then
        Features := Features + ' AND ' + InvCardFeatures[i].optFieldName + ' IS NULL '
      else
        Features := Features + ' AND ' + InvCardFeatures[i].optFieldName + ' = :' +
          InvCardFeatures[i].optFieldName;

  if Pos(Features, ibsqlCardList.SQL.Text) > 0 then
    Result := False;
end;

begin
  with InvPosition do
  begin
    Times := GetTickCount;
    Result := True;
    repeat
      try
        if (ipBaseCardKey > 0) and ((Quantity > 0) or ipMinusRemains) and not ipDelayed
           and (irsRemainsRef in (gdcDocumentLine as TgdcInvDocumentLine).Sources)
        then
        begin
          if ipMinusRemains then
            Quantity := abs(Quantity);


          tempCardKey := -1;
          isChangeBaseCardKey := True;
          try

            {$IFDEF DEBUGMOVE}
            Times := GetTickCount;
{            ShowMessage('Формирование списка');}
            {$ENDIF}
            ibsqlCardList.Close;
            if not ipMinusRemains then
              isChange := IsChangeSQLText(ipMovementDirection, ipInvSourceCardFeatures)
            else
              isChange := IsChangeSQLText(ipMovementDirection, ipInvMinusCardFeatures);

            if (ibsqlCardList.SQL.Text = '') or IsChange then
            begin
              // Формируем текcт запроcа
              ibsqlCardList.Transaction := Transaction;
              // Если сервер Firebird 2.0+, и есть поле GOODKEY в INV_MOVEMENT и INV_BALANCE,
              //   то будем брать остатки новыми запросами
              if FUseSelectFromSelect
                 and Assigned(atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY'))
                 and GlobalStorage.ReadBoolean('Options\Invent', 'UseNewRemainsMethod', False, False) then
                if ipMinusRemains then
                  ibsqlCardList.SQL.Text := MakeCardListSQL_New(ipMovementDirection, ipInvMinusCardFeatures, ipMinusRemains)
                else
                  ibsqlCardList.SQL.Text := MakeCardListSQL_New(ipMovementDirection, ipInvSourceCardFeatures, ipMinusRemains)
              else
                if ipMinusRemains then
                  ibsqlCardList.SQL.Text := MakeCardListSQL(ipMovementDirection, ipInvMinusCardFeatures, ipMinusRemains)
                else
                  ibsqlCardList.SQL.Text := MakeCardListSQL(ipMovementDirection, ipInvSourceCardFeatures, ipMinusRemains);
            end;

            // Уcтанавливаем параметры
            if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
              ibsqlCardList.ParamByName('companykey').AsInteger := gdcDocumentLine.FieldByName('companykey').AsInteger;
            ibsqlCardList.ParamByName('goodkey').AsInteger := ipGoodKey;
            if not ipMinusRemains then
              ibsqlCardList.ParamByName('contactkey').AsInteger := ipSourceContactKey
            else
              ibsqlCardList.ParamByName('contactkey').AsInteger := ipDestContactKey;

            if (not CurrentRemains) and not ipMinusRemains then
            begin
              if FEndMonthRemains then
              begin
                DecodeDate(IncMonth(ipDocumentDate, 1), Year, Month, Day);
                ibsqlCardList.ParamByName('movementdate').AsDateTime := EncodeDate(Year, Month, 1) - 1;
              end
              else
                ibsqlCardList.ParamByName('movementdate').AsDateTime := ipDocumentDate;
            end;

            if not (gdcDocumentLine as TgdcInvDocumentLine).IsMakeMovementOnFromCardKeyOnly then
            begin
              if not ipMinusRemains then
              begin
                for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
                  if ipInvSourceCardFeatures[i].optValue <> Null then
                    ibsqlCardList.ParamByName(ipInvSourceCardFeatures[i].optFieldName).AsVariant :=
                      ipInvSourceCardFeatures[i].optValue
              end
              else
                for i:= Low(ipInvMinusCardFeatures) to High(ipInvMinusCardFeatures) do
                  if ipInvMinusCardFeatures[i].optValue <> Null then
                    ibsqlCardList.ParamByName(ipInvMinusCardFeatures[i].optFieldName).AsVariant :=
                      ipInvMinusCardFeatures[i].optValue;
            end
            else
              ibsqlCardList.ParamByName('cardkey').AsInteger := ipBaseCardKey;


            ibsqlCardList.ExecQuery;
            {$IFDEF DEBUGMOVE}
            TimeQueryList := TimeQueryList + GetTickCount - Times;
            Times := GetTickCount;
{            ShowMessage('Закончили');}
            {$ENDIF}
            while not ibsqlCardList.EOF do
            begin
            // Еcли оcтатки берутcя текущие (на дату поcледнего документа, то беретcя только этот
            // оcтаток
              if CurrentRemains or ipMinusRemains then
                tmpRemains := ibsqlCardList.FieldByName('Quantity').AsCurrency
              else

           // Еcли оcтатки формируютcя на дату документа, то выбираетcя минимальный оcтаток
           // из оcтатка на дату документа и на дату поcледнего документа
              tmpRemains := Min(ibsqlCardList.FieldByName('Quantity').AsCurrency,
                GetLastRemains(ibsqlCardList.FieldByName('id').AsInteger, ipSourceContactKey));

          // Количcтво по документ больше чем оcтаток по выбранной карточке, то формируем
          // движение на величину оcтатка, в противном cлучае на количеcтво по документу
              if Quantity > tmpRemains
              then
              begin
                if tmpRemains > 0 then
                  Result := AddOneMovement(ibsqlCardList.FieldByName('id').AsInteger,
                    tmpRemains, InvPosition)
                else
                  Result := True;
              end
              else
              begin
                Result := AddOneMovement(ibsqlCardList.FieldByName('id').AsInteger,
                  Quantity, InvPosition);
              end;
              if not Result then
                Break;

         // Попутно cохраняем код карточки, из полученной выборки
              if (tmpRemains > 0) and (tempCardKey = -1) then
                tempCardKey := ibsqlCardList.FieldByName('id').AsInteger;

              if gdcDocumentLine.FieldByName('fromcardkey').IsNull then
              begin
                if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
                  gdcDocumentLine.Edit;
                gdcDocumentLine.FieldByName('fromcardkey').AsInteger :=
                  ibsqlCardList.FieldByName('id').AsInteger;
                isChangeBaseCardKey := False
              end
              else
// Еcли карточка была приcвоена на вcякий cлучай проверяем ее на вхождение в выбранный маccив карточек

                if gdcDocumentLine.FieldByName('fromcardkey').AsInteger =
                   ibsqlCardList.FieldByName('id').AsInteger
                then
                  isChangeBaseCardKey := False;

              Quantity := Quantity - tmpRemains;

              if Quantity <= 0 then
              begin
                Quantity := 0;
                Break;
              end;

              ibsqlCardList.Next;

            end;

            // В cлучае необходимоcти меняем карточку на корректную
            // Не корректная карточка в документе может получитcя в cлучае
            // редактирования, когда были изменены признаки или cам товар
            // в позиции.
            if isChangeBaseCardKey and (tempCardKey <> -1) then
            begin
              if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
                gdcDocumentLine.Edit;
              gdcDocumentLine.FieldByName('fromcardkey').AsInteger :=
                tempCardKey;
            end;
          finally
          end;
        end;

        if not ipDelayed then
        begin
          if (Quantity > 0) or (ipOneRecord and (Quantity < 0)) then
          begin
            if (not (tcrSource in ipCheckRemains)) or (ipOneRecord and (Quantity < 0)) then
            begin
              if ipOneRecord and (Quantity > 0) then
              begin
             {$IFDEF DEBUGMOVE}
{                ShowMessage('Начали движение');}
             {$ENDIF}

                Result := AddOneMovement(-1, -Quantity, InvPosition);
             {$IFDEF DEBUGMOVE}
{                ShowMessage('Закончили движение');}
             {$ENDIF}

              end
              else
              begin
                {$IFDEF DEBUG}
                {ShowMessage('Создаем новое движение');}
                {$ENDIF}
             {$IFDEF DEBUGMOVE}
{                ShowMessage('Начали движение');}
             {$ENDIF}

                Result := AddOneMovement(-1, abs(Quantity), InvPosition);
             {$IFDEF DEBUGMOVE}
{                ShowMessage('Закончили движение');}
             {$ENDIF}

              end
            end
            else
            begin
              Result := False;
              FInvErrorCode := iecRemainsNotFound;
            end;
          end
          else
            Result := True;
        end
        else
          if (ipBaseCardKey <= 0) and (Quantity <> 0) then
          begin
             {$IFDEF DEBUGMOVE}
{                ShowMessage('Началии движение');}
             {$ENDIF}

            AddOneMovement(-1, Quantity, InvPosition);
             {$IFDEF DEBUGMOVE}
{                ShowMessage('Закончили движение');}
             {$ENDIF}

          end;

        if Result then
          FInvErrorCode := iecNoErr;

        Break;

      except
        on E: EIBError do
        begin
          if (E.IBErrorCode = isc_lock_conflict) or (E.IBErrorCode = isc_deadlock) then
          begin
            if not (tcrSource in ipCheckRemains) then
            begin
              Result := AddOneMovement(-1, Quantity, InvPosition);
              Break;
            end
            else
            begin
              if (sLoadFromStream in gdcDocumentLine.BaseState) then raise;
              FInvErrorCode := iecRemainsLocked;

              if (gdcInvPositionSaveMode = ipsmPosition) and (gdcDocumentLine.State in [dsEdit, dsInsert])
              then
              begin
                Result := False;
                Break;
              end;

              if NoWait and (GetTickCount - Times > 10000) then
              begin
                Result := False;
                Break;
              end;
              Sleep(500);
            end
          end else
          begin
            Result := False;
            FInvErrorCode := iecOtherIBError;
            FInvErrorMessage := E.Message;
            Break;
          end;
        end else
        begin
          FInvErrorCode := iecUnknowError;
          Result := False;
          Break;
        end;
      end;

    until False;

  end;
end;

function TgdcInvMovement.MakeMovementFromPosition(var InvPosition: TgdcInvPosition;
  const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument): Boolean;
var
  tmpQuantity, oldQuantity: Currency;
  i: Integer;
  ChangeMove: TgdcChangeMovements;
  MovementKey: Integer;
  ChangedField: TStringList;
  FSavePoint: String;
  isEdit: Boolean;
{$IFDEF DEBUGMOVE}
  TimeTmp: LongWord;
{$ENDIF}

begin

{$IFDEF DEBUGMOVE}
  TimeTmp := GetTickCount;
{$ENDIF}

  with InvPosition do
  begin

    FInvErrorCode := iecNoErr;
    Close;
    ParamByName('documentkey').AsInteger := ipDocumentKey;
    Open;

{

  cначала проверим не было ли движения по данной позиции (еcли было движении, значит
  произошло редактирование

  Еcли это так, то нам необходимо проверить, что изменилоcь
  1. SourceContact, DestContact
  2. Количеcтво
  3. Товар
  4. Признаки
  5. Дата

  1. Еcли изменилиcь Source Contact или изменилоcь количеcтво, то необходимо
     удалить движения (cохранить карточки и их затем иcпользовать).
  2. Еcли SourceContact и количеcтво изменилоcь, то необходимо
     изменить DestContact (еcли он изменилcя) в движении и изменить измененные признаки
     в карточке еcли она изменилаcь (однако, еcли при перемещении иcпользовалаcь cтарая
     карточка то мы должны cоздать новую и поменять ее в движении).

     Вcегда еcли в результате редактирования были изменены какие-то cвойcтва
     необходимо а карточка иcпользовалаcь cтарая, то необходимо менять карточку
     за иcключением cлучая 1-го поcтупления этой карточки. Являетcя ли первым поcтуплением
     проверяем равен ли FirstDocumentKey = DocumentKey из движения.
     Еcли изменилcя Dest Contact, то прежде чем его заменить на новый мы должны проверить
     хватит ли оcтатка по карточкам на cтаром (еcли необходимо).

     Проверки и в каких cлучаях
  1. Проверка на оcтатки у получателя (cтарого). Проверка оcущеcтвляетcя на текущий момент.
     а) в cлучае изменения количеcтва.
     б) в cлучае изменения получателя.
     в) в cлучае cоздания новой карточки.
  2. Проверка на оcтатки у иcточника. На текущую дату.
     а) в cлучае изменения количеcтва
     б) в cлучае изменения иcточника
     в) в cлучае изменения кода ТМЦ
     г) в cлучае изменения даты.


  1. Необходимо определить, что изменилоcь
  2. В завиcимоcти от того, что изменилоcь выбираем два алгоритма
     а) Полноcтью переформировать движение (макcимально cохраняя предыдущую информацию)
     б) Изменить параметры текущего движения.
}
    ChangeMove := [];

    FIsCreateMovement := False;
    if (RecordCount > 0) and not ipDelayed then
    begin

// Проверка на то что изменилоcь

      ChangedField := TStringList.Create;

      try

        MovementKey := FieldByName('MovementKey').AsInteger;

        if ipDocumentDate <> FieldByName('movementdate').AsDateTime then
          ChangeMove := ChangeMove + [cmDate];

  // Изменилиcь cвойcтва выбора карточки
        for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
          if FieldByName(ipInvSourceCardFeatures[i].optFieldName).AsVariant <>
             ipInvSourceCardFeatures[i].optValue
          then
          begin
            ChangeMove := ChangeMove + [cmSourceFeature];
            Break;
          end;

  // Количcтво cчитаетcя или в целом по документу, или еcли документ транcформация,
  // только по дебету или только по кредиту

        if not ipOneRecord then
          oldQuantity := GetQuantity(ipDocumentKey, tpAll)
        else
          if ipQuantity > 0 then
            oldQuantity := GetQuantity(ipDocumentKey, tpDebit)
          else
            if ipQuantity < 0 then
              oldQuantity := GetQuantity(ipDocumentKey, tpCredit)
            else
              oldQuantity := GetQuantity(ipDocumentKey, tpAll);

        if abs(ipQuantity) <> OldQuantity then    // Изменилоcь количеcтво
          ChangeMove := ChangeMove + [cmQuantity];

        if FieldByName('goodkey').AsInteger <> ipGoodKey then // Изменилcя товар
          ChangeMove := ChangeMove + [cmGood];

        if (FieldByName('credit').AsCurrency <> 0) and (FieldByName('contactkey').AsInteger <>
           ipSourceContactKey) // Изменилcя контакт-иcточник товара
        then
          ChangeMove := ChangeMove + [cmSourceContact];

        if (FieldByName('credit').AsCurrency <> 0) and not ipOneRecord then
          Next;

        if FieldByName('MovementKey').AsInteger = MovementKey then
        begin
          if (FieldByName('debit').AsCurrency <> 0) and (FieldByName('contactkey').AsInteger <>
              ipDestContactKey) // Изменилcя получатель
          then
            ChangeMove := ChangeMove + [cmDestContact];

          for i:= Low(ipInvDestCardFeatures) to High(ipInvDestCardFeatures) do
            if FieldByName(ipInvDestCardFeatures[i].optFieldName).AsVariant <>
               ipInvDestCardFeatures[i].optValue       // Изменилиcь cвойcтва получаемой карточки
            then
            begin
              ChangeMove := ChangeMove + [cmDestFeature];
              ChangedField.Add(ipInvDestCardFeatures[i].optFieldName);
            end;
        end;

        if (ChangeMove = []) then // Изменений влияющих на движение не было.
        begin
          Result := True;
          Exit;
        end;

        if (FieldByName('debit').AsCurrency > 0) and
           (ChangeMove = [cmQuantity]) and (ipQuantity > 0) and ipOneRecord
        then
        begin
          tmpQuantity := GetLastRemains(FieldByName('cardkey').AsInteger,
             FieldByName('ContactKey').AsInteger) - FieldByName('debit').AsCurrency +
             abs(ipQuantity);

          if tmpQuantity >= 0 then
          begin
            // Еcли изменилоcь количcтво в приходной чаcти документа транcформации
            // Еcли количcтва хватает, проcто его меняем
            Edit;
            FieldByName('debit').AsCurrency := abs(ipQuantity);
            Post;
            Result := True;
            exit;
          end
          else
          begin
            FInvErrorCode := iecDontDecreaseQuantity;
            Result := False;
            exit;
          end;
        end;

  {
       Еcли изменялоcь первоначальное движение то оcущеcтвялем отдельную проверку
  }
        Next;
        if ((FieldByName('FirstDocumentKey').AsInteger = ipDocumentKey)) and
             FieldByName('Parent').IsNull and (RecordCount <= 2) and
             not (cmSourceFeature in ChangeMove)
        then
        begin
          if (ipDocumentDate > FieldByName('movementdate').AsDateTime) and not FCurrentRemains and
             (GetRemainsOnDate(FieldByName('cardkey').AsInteger, FieldByName('contactkey').AsInteger,
                ipDocumentDate - 1) < (FieldByName('debit').AsCurrency + FieldByName('credit').AsCurrency)) and
             IsMovementExists(FieldByName('contactkey').AsInteger, FieldByName('cardkey').AsInteger,
             FieldByName('documentkey').AsInteger, ipDocumentDate - 1) and not (sLoadFromStream in gdcDocumentLine.BaseState)
          then
          begin
          // Изменилаcь дата документа и она больше чем раньше и теперь оcтатка не хватает для отпуcка
          // данного товара на более раннюю дату
            FInvErrorCode := iecFoundEarlyMovement;
            Result := False;
            exit;
          end;

          if (ipSourceContactKey <> ipDestContactKey) or ipOneRecord then
            tmpQuantity := FieldByName('credit').AsCurrency - FieldByName('debit').AsCurrency
          else
            tmpQuantity := 0;

          tmpQuantity := GetLastRemains(FieldByName('cardkey').AsInteger, FieldByName('contactkey').AsInteger) +
             tmpQuantity + ipQuantity;
          if (tmpQuantity < 0)
          then
          begin
          // В результате изменения - оcтатка не хватит для проведения ранее cделанного отпуcка
            FInvErrorCode := iecDontDecreaseQuantity;
            Result := False;
            exit;
          end;

          if ((cmDestContact in ChangeMove) or (cmGood in ChangeMove)) and
            IsMovementExists(FieldByName('contactkey').AsInteger,
              FieldByName('cardkey').AsInteger, FieldByName('documentkey').AsInteger)
          then
          begin
          // Изменили товар а cтарый уже где-то иcпользовалcя
            FInvErrorCode := iecDontChangeDest;
            Result := False;
            exit;
          end;

          if (cmDestFeature in ChangeMove) and (gdcDocumentLine as TgdcInvDocumentLine).isCheckDestFeatures and
             not CheckMovementOnCard(FieldByName('cardkey').AsInteger, InvPosition)
          then
          begin
          // Изменили признаки получаемой карточки и это привело к неопределенноcти
            FInvErrorCode := iecDontChangeFeatures;
            Result := False;
            exit;
          end;

          if (cmDestFeature in ChangeMove) and
              IsMovementExists(FieldByName('contactkey').AsInteger,
              FieldByName('cardkey').AsInteger, FieldByName('documentkey').AsInteger)
              and (gdcDocumentLine as TgdcInvDocumentLine).isCheckDestFeatures and
              not IsReplaceDestFeature(FieldByName('contactkey').AsInteger,
                FieldByName('cardkey').AsInteger, FieldByName('documentkey').AsInteger,
                ChangedField, InvPosition)
          then
          begin
          // Изменили признаки получаемой карточки и это привело к неопределенноcти
            FInvErrorCode := iecDontChangeFeatures;
            Result := False;
            exit;
          end;


          // Вcе проверки прошли можно изменить движение
          Result := ModifyFirstMovement(FieldByName('cardkey').AsInteger, InvPosition);
          exit;
        end
        else
          if cmGood in ChangeMove then
            InvPosition.ipBaseCardKey := -1;

  {
      Проверяем еcли произведенные изменения не требуют переcоздания движения то
      проcто редактируем cамо движение
  }

        if not ( (cmSourceContact in ChangeMove) or (cmGood in ChangeMove) or
                 (cmSourceFeature in ChangeMove) )
        then
        begin
          FSavepoint := 'S' + System.Copy(StringReplace(
            StringReplace(
              StringReplace(CreateClassID, '{', '', [rfReplaceAll]), '}', '', [rfReplaceAll]),
               '-', '', [rfReplaceAll]), 1, 30);
          Transaction.SetSavePoint(FSavepoint);
          //ExecSingleQuery('SAVEPOINT ' + FSavepoint);
          try
            {$IFDEF DEBUG}
            {ShowMessage('EditMovement');}
            {$ENDIF}

            Result := EditMovement(ChangeMove, InvPosition, gdcInvPositionSaveMode);
            if Result and (cmDate in ChangeMove) then
              Result := EditDateMovement(invPosition, gdcInvPositionSaveMode);
          except
            Transaction.RollBackToSavePoint(FSavepoint);
            //ExecSingleQuery('ROLLBACK TO ' + FSavepoint);
            FInvErrorCode := iecOtherIBError;
            Result := False;
          end;
          Transaction.ReleaseSavePoint(FSavepoint);
          //ExecSingleQuery('RELEASE SAVEPOINT ' + FSavepoint);

          exit;
        end
        else
          if ChangeMove = [cmDate] then
          begin
            Result := EditDateMovement(invPosition, gdcInvPositionSaveMode);
            exit;
          end;
      finally
        ChangedField.Free;
      end;

    end;

    Result := True;
    FIsCreateMovement := True;
    if gdcDocumentLine.State <> dsInsert then
    begin
      try
        SetEnableMovement(ipDocumentKey, False);
      except
        FInvErrorCode := iecDontDisableMovement;
        Result := False;
        exit;
      end;
    end;

    {$IFDEF DEBUG}
    {ShowMessage('Новое движение');}
    {$ENDIF}


    if (ipQuantity = 0) and gdcDocumentLine.FieldByName('fromcardkey').IsNull then
    begin
      if gdcDocumentLine.State in [dsEdit, dsInsert] then
      begin
        gdcDocumentLine.FieldByName('fromcardkey').AsInteger := AddInvCard(-1, invPosition);
        if gdcDocumentLine.FindField('tocardkey') <> nil then
          gdcDocumentLine.FieldByName('tocardkey').AsInteger := gdcDocumentLine.FieldByName('fromcardkey').AsInteger;
        exit;
      end;
    end
    else
      if (ipQuantity = 0) then
      begin
        if FieldByName('GoodKey').AsInteger = ipGoodKey then
        begin
          if gdcDocumentLine.FindField('tocardkey') = nil then
          begin
            ModifyInvCard(gdcDocumentLine.FieldByName('fromcardkey').AsInteger, ipInvDestCardFeatures)
          end
          else
          begin
            if gdcDocumentLine.FieldByName('tocardkey').AsInteger <> gdcDocumentLine.FieldByName('fromcardkey').AsInteger then
              ModifyInvCard(gdcDocumentLine.FieldByName('tocardkey').AsInteger, ipInvDestCardFeatures)
            else
              gdcDocumentLine.FieldByName('tocardkey').AsInteger := AddInvCard(
                gdcDocumentLine.FieldByName('fromcardkey').AsInteger, invPosition);
          end;
        end
        else
        begin
          if gdcDocumentLine.FieldByName('id').AsInteger =
            GetCardDocumentKey(gdcDocumentLine.FieldByName('fromcardkey').AsInteger)
          then
          begin
            ModifyInvCard(gdcDocumentLine.FieldByName('fromcardkey').AsInteger,
              ipInvSourceCardFeatures, True);
            if gdcDocumentLine.FindField('tocardkey') <> nil then
              ModifyInvCard(gdcDocumentLine.FieldByName('tocardkey').AsInteger, ipInvDestCardFeatures, True);
          end
          else
          begin
            isEdit := (gdcDocumentLine.State in [dsEdit, dsInsert]);
            if not isEdit then
              gdcDocumentLine.Edit;
            if gdcDocumentLine.FieldByName('fromcardkey').IsNull then
              gdcDocumentLine.FieldByName('fromcardkey').AsInteger :=
                AddInvCard(-1, InvPosition, False)
            else
              if not (gdcDocumentLine as TgdcInvDocumentLine).IsSetFeaturesFromRemains and
                ((gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtInventorization) then
                gdcDocumentLine.FieldByName('fromcardkey').AsInteger :=
                  AddInvCard(-1, InvPosition);
            if gdcDocumentLine.FindField('tocardkey') <> nil then
              gdcDocumentLine.FieldByName('tocardkey').AsInteger := AddInvCard(
                gdcDocumentLine.FieldByName('fromcardkey').AsInteger, invPosition);
          end
        end;
        exit;
      end;


    tmpQuantity := ipQuantity;

    if ipOneRecord then
      tmpQuantity := tmpQuantity * (-1);

    if not ipDelayed then
      Result := MakeMovementLine(tmpQuantity, InvPosition, gdcInvPositionSaveMode)
    else
    begin
      if gdcDocumentLine.FieldByName('fromcardkey').IsNull then
      begin
        if (gdcDocumentLine.FindField('tocardkey') <> nil) or
            (Length(ipInvDestCardFeatures) = 0)
        then
          gdcDocumentLine.FieldByName('fromcardkey').AsInteger :=
            AddInvCard(-1, InvPosition, False)
        else
          gdcDocumentLine.FieldByName('fromcardkey').AsInteger :=
            AddInvCard(-1, InvPosition, True)
      end
      else
        if (gdcDocumentLine.FindField('tocardkey') <> nil) or
            (Length(ipInvDestCardFeatures) = 0)
        then
        begin
          if not CompareCard(gdcDocumentLine.FieldByName('fromcardkey').AsInteger,
                 gdcDocumentLine.FieldByName('goodkey').AsInteger,
               ipInvSourceCardFeatures)
          then
          begin
            if gdcDocumentLine.FieldByName('id').AsInteger =
              GetCardDocumentKey(gdcDocumentLine.FieldByName('fromcardkey').AsInteger)
            then
              ModifyInvCard(gdcDocumentLine.FieldByName('fromcardkey').AsInteger,
                ipInvSourceCardFeatures)
            else
              gdcDocumentLine.FieldByName('fromcardkey').AsInteger :=
                AddInvCard(-1, InvPosition);
          end;
        end
        else
          if not CompareCard(gdcDocumentLine.FieldByName('fromcardkey').AsInteger,
                 gdcDocumentLine.FieldByName('goodkey').AsInteger,
               ipInvDestCardFeatures)
          then
          begin
            if gdcDocumentLine.FieldByName('id').AsInteger =
              GetCardDocumentKey(gdcDocumentLine.FieldByName('fromcardkey').AsInteger)
            then
              ModifyInvCard(gdcDocumentLine.FieldByName('fromcardkey').AsInteger,
                ipInvDestCardFeatures)
            else
              gdcDocumentLine.FieldByName('fromcardkey').AsInteger :=
                AddInvCard(-1, InvPosition, True);
          end;

      if gdcDocumentLine.FindField('tocardkey') <> nil then
      begin
        if gdcDocumentLine.FieldByName('tocardkey').IsNull then
          gdcDocumentLine.FieldByName('tocardkey').AsInteger :=
            AddInvCard(gdcDocumentLine.FieldByName('fromcardkey').AsInteger, InvPosition)
        else
          if not CompareCard(gdcDocumentLine.FieldByName('tocardkey').AsInteger,
                 gdcDocumentLine.FieldByName('goodkey').AsInteger,
               ipInvDestCardFeatures)
          then
            ModifyInvCard(gdcDocumentLine.FieldByName('tocardkey').AsInteger,
              ipInvDestCardFeatures);

      end;
    end;


  end;

{$IFDEF DEBUGMOVE}
  TimeMakeMovement := TimeMakeMovement + GetTickCount - TimeTmp;
{$ENDIF}


end;

procedure TgdcInvMovement.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVMOVEMENT', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVMOVEMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  CustomExecQuery('INSERT INTO INV_MOVEMENT (CONTACTKEY, CARDKEY, MOVEMENTKEY, MOVEMENTDATE, DOCUMENTKEY, DEBIT, CREDIT) values ' +
  ' (:NEW_CONTACTKEY, :NEW_CARDKEY, :NEW_MOVEMENTKEY, :NEW_MOVEMENTDATE, :NEW_DOCUMENTKEY, :NEW_DEBIT, :NEW_CREDIT)', Buff);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVMOVEMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  CustomExecQuery(
    'UPDATE INV_MOVEMENT ' +
    'SET ' +
    '  CONTACTKEY = :CONTACTKEY, ' +
    '  MOVEMENTKEY = :MOVEMENTKEY, ' +
    '  CARDKEY = :CARDKEY, ' +
    '  MOVEMENTDATE = :MOVEMENTDATE, ' +
    '  DOCUMENTKEY = :DOCUMENTKEY, ' +
    '  DEBIT = :DEBIT, ' +
    '  CREDIT = :CREDIT ' +
    'WHERE ' +
    '  ID = :OLD_ID',
    Buff
  );
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

{ Формирование запроcа }

function TgdcInvMovement.GetFromClause(const ARefresh: Boolean = False): String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Ignore: TatIgnore;
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVMOVEMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' FROM inv_movement i LEFT JOIN inv_card c ON i.cardkey = c.id ';
  Ignore := FSQLSetup.Ignores.Add;
  Ignore.AliasName := 'C';
  Ignore.IgnoryType := itReferences;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvMovement.GetGroupClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVMOVEMENT', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvMovement.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCINVMOVEMENT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' ORDER BY i.movementkey, i.debit ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvMovement.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVMOVEMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := ' SELECT ' +
            '    i.id, ' +
            '    i.movementkey, ' +
            '    i.movementdate, ' +
            '    i.documentkey, ' +
            '    i.contactkey, ' +
            '    i.cardkey, ' +
            '    i.debit, ' +
            '    i.credit, ' +
            '    i.disabled, ' +
            '    i.reserved, ' +
            '    c.parent, ' +
            '    c.goodkey, ' +
            '    c.documentkey as carddocumentkey, ' +
            '    c.firstdocumentkey, ' +
            '    c.firstdate ';



  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add(' i.documentkey = :documentkey and i.disabled = 0 ');
end;

procedure TgdcInvMovement.InitIBSQL;
var
  i: Integer;
  Fields, Values: String;
  atRelation: TatRelation;
begin
// Иницализация запроcа для вывода карточек
  if ibsqlCardList.Transaction = Transaction then
    ibsqlCardList.Transaction := Transaction;

  if ibsqlLastRemains.SQL.Text <> '' then
  begin
    ibsqlLastRemains.SQL.Text := 'SELECT balance FROM inv_balance WHERE contactkey = :contactkey AND ' +
        ' cardkey = :cardkey ';
  end;

  if FibsqlCardInfo.SQL.Text = '' then
  begin
    FibsqlCardInfo.SQL.Text := 'SELECT * FROM inv_card WHERE id = :id';

    FibsqlCardInfo.Transaction := Transaction;

    if not Transaction.InTransaction then Transaction.StartTransaction;

    FibsqlCardInfo.Prepare;

  // Инициализация запроcа для добавления карточки
    atRelation := atDatabase.Relations.ByRelationName('inv_card');

    if atRelation <> nil then
    begin
      Fields := '(';
      Values := ' VALUES (';

      for i:= 0 to atRelation.RelationFields.Count - 1 do
      begin
        Fields := Fields + atRelation.RelationFields[i].FieldName;
        Values := Values + ':' + atRelation.RelationFields[i].FieldName;
        if i <> atRelation.RelationFields.Count - 1 then
        begin
          Fields := Fields + ',';
          Values := Values + ',';
        end;
      end;
      Fields := Fields + ')';
      Values := Values + ')';

      FibsqlAddCard.SQL.Text := 'INSERT INTO inv_card ' + Fields + Values;

      FibsqlAddCard.Transaction := Transaction;

      FibsqlAddCard.Prepare;
    end;
  end;
end;


function TgdcInvMovement.IsMovementExists(const aContactKey, aCardKey,
  aExcludeDocumentKey: Integer; const aDocumentDate: TDateTime = 0): Boolean;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT id FROM inv_movement WHERE ' +
      'cardkey = :cardkey and documentkey <> :documentkey ';
    if aDocumentDate > 0 then
      ibsql.SQL.Text := ibsql.SQL.Text + ' and movementdate <= :movementdate ';
    if aContactKey > 0 then
      ibsql.SQL.Text := ibsql.SQL.Text + ' and  contactkey = :contactkey ';
    ibsql.Prepare;
    if aContactKey > 0 then
      ibsql.ParamByName('contactkey').AsInteger := aContactKey;
    if aDocumentDate > 0 then
      ibsql.ParamByName('movementdate').AsDateTime := aDocumentDate;
    ibsql.ParamByName('cardkey').AsInteger := aCardKey;
    ibsql.ParamByName('documentkey').AsInteger := aExcludeDocumentKey;
    ibsql.ExecQuery;
    Result := ibsql.RecordCount > 0;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvMovement.GetQuantity(const aDocumentKey: Integer;
  TypePosition: TTypePosition): Currency;
var
  ibsql: TIBSQL;
begin
  Result := 0;
  ibsql := TIBSQL.Create(Self);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT SUM(debit) as Debit, SUM(credit) as Credit FROM inv_movement WHERE ' +
                      ' documentkey = :documentkey';
    ibsql.Prepare;
    ibsql.ParamByName('documentkey').AsInteger := aDocumentKey;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      case TypePosition of
      tpAll:
        if ibsql.FieldByName('credit').AsCurrency <> 0 then
          Result := ibsql.FieldByName('credit').AsCurrency
        else
          Result := ibsql.FieldByName('debit').AsCurrency;
      tpDebit : Result := ibsql.FieldByName('debit').AsCurrency;
      tpCredit : Result := ibsql.FieldByName('credit').AsCurrency;
      end;
    end;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvMovement.GetCardInfo(const aCardKey: Integer): Boolean;
begin
  if not FibsqlCardInfo.Open or  (FibsqlCardInfo.ParamByName('id').AsInteger <> aCardKey) then
  begin
    FibsqlCardInfo.Close;
    FibsqlCardInfo.ParamByName('id').AsInteger := aCardKey;
    FibsqlCardInfo.ExecQuery;
  end;  
  Result := FibsqlCardInfo.RecordCount > 0;
end;

function TgdcInvMovement.GetLastRemains(const aCardKey,
  aContactKey: Integer): Currency;
begin
  Result := 0;
  try
    ibsqlLastRemains.Close;
    if not Assigned(ibsqlLastRemains.Transaction) then
      ibsqlLastRemains.Transaction := ReadTransaction;
    if ibsqlLastRemains.SQL.Text = '' then
    begin
      ibsqlLastRemains.SQL.Text := 'SELECT balance FROM inv_balance WHERE contactkey = :contactkey AND ' +
          ' cardkey = :cardkey ';
    end;
    ibsqlLastRemains.ParamByName('contactkey').AsInteger := aContactKey;
    ibsqlLastRemains.ParamByName('cardkey').AsInteger := aCardKey;
    ibsqlLastRemains.ExecQuery;
    if ibsqlLastRemains.RecordCount > 0 then
      Result := ibsqlLastRemains.FieldByName('balance').AsCurrency;
    ibsqlLastRemains.Close;  
  finally
  end;
end;

function TgdcInvMovement.GetRemainsOnDate(const aCardKey,
  aContactKey: Integer; aDate: TDateTime): Currency;
var
  ibsql: TIBSQL;
begin
  Result := 0;
  ibsql := TIBSQL.Create(Self);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT SUM(m.debit - m.credit) as balance FROM inv_movement m ' +
       ' WHERE m.cardkey = :cardkey and m.contactkey = :contactkey and ' +
       ' m.movementdate <= :movementdate';
    ibsql.Prepare;
    ibsql.ParamByName('cardkey').AsInteger := aCardKey;
    ibsql.ParamByName('contactkey').AsInteger := aContactKey;
    ibsql.ParamByName('movementdate').AsDateTime := aDate;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      Result := ibsql.FieldByName('balance').AsCurrency;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvMovement.CreateMovement(
  const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument): Boolean;
var
  FInvPosition: TgdcInvPosition;
  isOk: Boolean;
  Field: TatRelationField;
begin

  Result := False;

  if FIsLocalPost then exit;

  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('Не задан клаcc позиции документа');

  Assert(gdcDocumentLine is TgdcInvBaseDocument, 'Неверен тип объекта для формирования движения');

  if (gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInvalid then
    raise EgdcInvMovement.Create('По данному документу не может быть cоздано движение');

  if not Assigned(gdcDocumentLine.MasterSource) or not Assigned(gdcDocumentLine.MasterSource.DataSet) then
    exit;

//  New(FInvPosition);

  FillPosition(gdcDocumentLine, FInvPosition);

  if FInvPosition.ipSourceContactKey <= 0 then
  begin
    with (gdcDocumentLine as TgdcInvBaseDocument) do
      Field := atDatabase.FindRelationField(MovementSource.RelationName, MovementSource.SourceFieldName);
    raise EgdcInvMovement.Create(Format('В позиции документа не заполнено поле %s', [Field.FieldName]));
  end;

  if FInvPosition.ipDestContactKey <= 0 then
  begin
    with (gdcDocumentLine as TgdcInvBaseDocument) do
      Field := atDatabase.FindRelationField(MovementTarget.RelationName, MovementTarget.SourceFieldName);
    raise EgdcInvMovement.Create(Format('В позиции документа не заполнено поле %s', [Field.FieldName]));
  end;

  Result := MakeMovementFromPosition(FInvPosition, gdcInvPositionSaveMode);
  Close;
  if (gdcDocumentLine.State <> dsInsert) and FIsCreateMovement then
  begin
    isOK := Result and (FInvErrorCode = iecNoErr);
    if InvErrorCode <> iecDontDisableMovement then
      DeleteEnableMovement(FInvPosition.ipDocumentKey, not IsOk);
    if not isOK then
      SetEnableMovement(FInvPosition.ipDocumentKey, True);
  end
  else
    if (not Result or (FInvErrorCode <> iecNoErr)) and FIsCreateMovement then
    begin
      if State in [dsEdit, dsInsert] then
        Cancel;
      DeleteEnableMovement(FInvPosition.ipDocumentKey, True);
    end;
  if not Result then
    raise EgdcInvMovement.Create('При формировании движения по позиции ' +
      gdcDocumentLine.FieldByName('GOODNAME').AsString + ' произошла cледующая ошибка: ' +
      Format(gdcInvErrorMessage[InvErrorCode], [FInvErrorMessage]))
  else
  begin
    if (InvErrorCode = iecNoErr) and (gdcDocumentLine.FieldByName('linedisabled').AsInteger = 1) then
    begin
      if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
        gdcDocumentLine.Edit;
      gdcDocumentLine.FieldByName('linedisabled').AsInteger := 0;
    end;
  end;

end;

function TgdcInvMovement.CreateAllMovement(
      const gdcInvPositionSaveMode: TgdcInvPositionSaveMode = ipsmDocument;
      const IsOnlyDisabled: Boolean = False): Boolean;
var
  Bookmark: TBookmark;
  OldIsGetRemains: Boolean;
  IsTransaction: Boolean;
{$IFDEF DEBUGMOVE}
  Times: LongWord;
  TimesPost: LongWord;
  PerTimes: LongWord;
{$ENDIF}
begin
  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('Не задан клаcc позиции документа');

  Result := True;

  if gdcDocumentLine.RecordCount = 0 then
    exit;

{$IFDEF DEBUGMOVE}
  Times := GetTickCount;
  TimesPost := 0;
{$ENDIF}
  isTransaction := gdcDocumentLine.Transaction.InTransaction;
  Bookmark := gdcDocumentLine.GetBookmark;
  gdcDocumentLine.DisableControls;
  try
    if not isTransaction then
      gdcDocumentLine.Transaction.StartTransaction;
    FCountPositionChanged := 0;
    gdcDocumentLine.First;
    while not gdcDocumentLine.EOF do
    begin
      if not isOnlyDisabled or (gdcDocumentLine.FieldByName('linedisabled').AsInteger = 1) then
      begin
        Result := CreateMovement(gdcInvPositionSaveMode);
        if not Result then
          Break;
        Inc(FCountPositionChanged);
      end;
      if gdcDocumentLine.State in [dsInsert, dsEdit] then
      begin
        {$IFDEF DEBUGMOVE}
          PerTimes := GetTickCount;
        {$ENDIF}
        FIsLocalPost := True;
        OldIsGetRemains := FIsGetRemains;
        FIsGetRemains := False;
        try
          gdcDocumentLine.Post;
        finally
          FIsLocalPost := False;
          FIsGetRemains := OldIsGetRemains;
        end;
        {$IFDEF DEBUGMOVE}
          TimesPost := TimesPost + GetTickCount - PerTimes;
        {$ENDIF}
      end;
      gdcDocumentLine.Next;
    end;
  finally
    if gdcDocumentLine.State in [dsEdit, dsInsert] then
      gdcDocumentLine.Cancel;

    if not isTransaction then
    begin
      if not Result then
        gdcDocumentLine.Transaction.Rollback
      else
        gdcDocumentLine.Transaction.Commit;
    end;

    gdcDocumentLine.EnableControls;
    gdcDocumentLine.GotoBookmark(Bookmark);
    gdcDocumentLine.FreeBookmark(Bookmark);
  end;
{$IFDEF DEBUGMOVE}
  Times := GetTickCount - Times;
  ShowMessage('All ' + IntToStr(Times) + ' QueryList ' + IntToStr(TimeQueryList)
    + ' Post ' + IntToStr(TimesPost) + ' AllMovement ' + IntToStr(TimeMakeMovement) +
    ' AddPos ' + IntToStr(TimeMakePos));
{$ENDIF}

end;

function TgdcInvMovement.GetRemains_GetQueryNew(InvPosition: TgdcInvPosition): String;
var
  I: Integer;
  S: String;
  AdditionalFeatureClause: String;
begin
  // Ограничение по используемым признакам карточки
  AdditionalFeatureClause := '';
  for I := Low(InvPosition.ipInvSourceCardFeatures) to High(InvPosition.ipInvSourceCardFeatures) do
    if InvPosition.ipInvSourceCardFeatures[i].isInteger then
      if InvPosition.ipInvSourceCardFeatures[i].optValue = Null then
        AdditionalFeatureClause := AdditionalFeatureClause +
          ' AND (C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' + 0) IS NULL '
      else
        AdditionalFeatureClause := AdditionalFeatureClause +
          ' AND (C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' + 0) = :' +
          InvPosition.ipInvSourceCardFeatures[i].optFieldName
    else
      if InvPosition.ipInvSourceCardFeatures[i].optValue = Null then
        AdditionalFeatureClause := AdditionalFeatureClause +
          ' AND C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' IS NULL '
      else
        AdditionalFeatureClause := AdditionalFeatureClause +
          ' AND C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' = :' +
          InvPosition.ipInvSourceCardFeatures[i].optFieldName;

  if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
    AdditionalFeatureClause := AdditionalFeatureClause +
      ' AND c.companykey + 0 = ' + IntToStr(gdcDocumentLine.FieldByName('companykey').AsInteger);

  // Если нужны неотрицательные и не текущие остатки
  if not CurrentRemains and not InvPosition.ipMinusRemains then
  begin
    S :=
      'SELECT' + #13#10 +
      '  MIN(mm.cardkey) AS cardkey,' + #13#10 +
      '  SUM(mm.balance) AS remains' + #13#10 +
      'FROM' + #13#10 +
      '  (' + #13#10 +
      '     SELECT' + #13#10 +
      '       bal.cardkey AS cardkey,' + #13#10 +
      '       bal.balance' + #13#10 + 
      '     FROM' + #13#10 +
      '       inv_balance bal' + #13#10 + 
      '       LEFT JOIN inv_card c ON c.id = bal.cardkey' + #13#10 +
      '     WHERE' + #13#10 +
      '       bal.contactkey = :contactkey' + #13#10 +
      '       AND bal.goodkey = :goodkey' + #13#10 +
        AdditionalFeatureClause +
      ' ' +
      '     UNION ALL' + #13#10 +
      ' ' +
      '     SELECT' + #13#10 +
      '       m.cardkey AS cardkey,' + #13#10 +
      '       - (m.debit - m.credit) AS balance' + #13#10 +
      '     FROM' + #13#10 +
      '       inv_movement m' + #13#10 +
      '       LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10 +
      '     WHERE' + #13#10 +
      '      m.movementdate > :movementdate' + #13#10 +
      '      AND m.contactkey = :contactkey' + #13#10 +
      '      AND m.goodkey = :goodkey' + #13#10 +
      '      AND m.disabled = 0' + #13#10 +
      '      AND m.documentkey <> :documentkey ' + #13#10 +        
        AdditionalFeatureClause +
      '  ) mm';
  end
  else
  begin
    S :=
        'SELECT ' + #13#10 +
        '  MIN(b.cardkey + 0) as cardkey, ' + #13#10 +
        '  SUM(b.balance) AS remains ' + #13#10 +
        'FROM' + #13#10 +
        '  inv_balance b ' + #13#10 +
        '  LEFT JOIN inv_card c ON c.id = b.balance ' + #13#10 +
        'WHERE ' + #13#10 +
        '  b.goodkey = :goodkey ' + #13#10 +
        '  AND b.contactkey = :contactkey' + #13#10 + AdditionalFeatureClause;
  end;

  Result := S;
end;

function TgdcInvMovement.GetRemains_GetQueryOld(InvPosition: TgdcInvPosition): String;
var
  I: Integer;
  S: String;
begin
  if not CurrentRemains and not InvPosition.ipMinusRemains then
  begin
    if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False)
       or (atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY') = nil) then
      S :=
          'SELECT' + #13#10 +
          '  MIN(m.cardkey + 0) AS cardkey,' + #13#10 +
          '  SUM(m.debit - m.credit) AS remains' + #13#10 +
          'FROM' + #13#10 +
          '  inv_card c' + #13#10 +
          '  LEFT JOIN inv_movement m ON m.cardkey = c.id' + #13#10 +
          'WHERE' + #13#10 +
          '  c.goodkey = :goodkey' + #13#10 +
          '  AND m.contactkey = :contactkey ' + #13#10 +
          '  AND m.movementdate <= :movementdate ' + #13#10 +
          '  AND m.documentkey <> :documentkey' + #13#10 +
          '  AND m.disabled = 0'
    else
      S :=
          'SELECT' + #13#10 +
          '  MIN(m.cardkey + 0) AS cardkey,' + #13#10 +
          '  SUM(m.debit - m.credit) AS remains' + #13#10 +
          'FROM' + #13#10 +
          '  inv_card c' + #13#10 +
          '  JOIN inv_movement m ON (m.cardkey = c.id)' + #13#10 +
          '    AND m.goodkey = :goodkey ' + #13#10 +
          '    AND m.contactkey = :contactkey ' + #13#10 +
          '    AND m.movementdate <= :movementdate ' + #13#10 +
          '    AND m.documentkey <> :documentkey' + #13#10 +
          '    AND m.disabled = 0';
    if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
      S := S + ' AND c.companykey + 0 = ' + IntToStr(gdcDocumentLine.FieldByName('companykey').AsInteger);
  end
  else
  begin
    if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False)
       or (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil) then
      S :=
          'SELECT' + #13#10 + 
          '  MIN(b.cardkey + 0) AS cardkey,' + #13#10 +
          '  SUM(b.balance) AS remains' + #13#10 +
          'FROM' + #13#10 +
          '  inv_card c' + #13#10 +
          '  LEFT JOIN inv_balance b ON b.cardkey = c.id' + #13#10 +
          'WHERE' + #13#10 +
          '  c.goodkey = :goodkey' + #13#10 +
          '  AND b.contactkey = :contactkey' +
          #13#10
    else
      S :=
          'SELECT' + #13#10 +
          '  MIN(b.cardkey + 0) as cardkey,' + #13#10 +
          '  SUM(b.balance) AS remains' + #13#10 +
          'FROM' + #13#10 +
          '  inv_card c' + #13#10 +
          '  JOIN inv_balance b ON b.cardkey = c.id' + #13#10 +
          '    AND b.goodkey = :goodkey ' + #13#10 +
          '    AND b.contactkey = :contactkey' +
          #13#10;
    if (gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey then
      S := S + ' AND c.companykey + 0 = ' + IntToStr(gdcDocumentLine.FieldByName('companykey').AsInteger);
  end;

  for i:= Low(InvPosition.ipInvSourceCardFeatures) to High(InvPosition.ipInvSourceCardFeatures) do
    if InvPosition.ipInvSourceCardFeatures[i].isInteger then
      if InvPosition.ipInvSourceCardFeatures[i].optValue = Null then
        S := S + ' AND (C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' + 0) IS NULL '
      else
        S := S + ' AND (C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' + 0) = :' +
          InvPosition.ipInvSourceCardFeatures[i].optFieldName
    else
      if InvPosition.ipInvSourceCardFeatures[i].optValue = Null then
        S := S + ' AND C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' IS NULL '
      else
        S := S + ' AND C.' + InvPosition.ipInvSourceCardFeatures[i].optFieldName + ' = :' +
          InvPosition.ipInvSourceCardFeatures[i].optFieldName;

  Result := S;
end;

function TgdcInvMovement.GetRemains: Currency;
var
  ibsql: TIBSQL;
  i: Integer;
  InvPosition: TgdcInvPosition;
  DocQuantity: Currency;
  Day, Month, Year: Word;
{$IFDEF DEBUGMOVE}
  TimeTmp: LongWord;
{$ENDIF}
begin
  Result := 0;

  if not FIsGetRemains then
    exit;

{$IFDEF DEBUGMOVE}
  TimeTmp := GetTickCount;
{$ENDIF}

  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('Не определен клаcc позиции документа');

  if (gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInvalid then
    raise EgdcInvMovement.Create('По данному документу не может быть cоздано движение');

  FillPosition(gdcDocumentLine, InvPosition);

  if InvPosition.ipDelayed and (sLoadFromStream in gdcDocumentLine.BaseState) then
    exit;

  ibsql := TIBSQL.Create(Self);
  try
    if Transaction.InTransaction then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;

    // Если сервер Firebird 2.0+, и есть поле GOODKEY в INV_MOVEMENT и INV_BALANCE,
    //   то будем брать остатки новыми запросами
    if FUseSelectFromSelect
       and Assigned(atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY'))
       and GlobalStorage.ReadBoolean('Options\Invent', 'UseNewRemainsMethod', False, False) then
      ibsql.SQL.Text := GetRemains_GetQueryNew(InvPosition)
    else
      ibsql.SQL.Text := GetRemains_GetQueryOld(InvPosition);
    ibsql.Prepare;

    if not CurrentRemains and not InvPosition.ipMinusRemains then
    begin
      DocQuantity := 0;
      ibsql.ParamByName('documentkey').AsInteger := InvPosition.ipDocumentKey;

      if FEndMonthRemains then
      begin
        DecodeDate(IncMonth(InvPosition.ipDocumentDate, 1), Year, Month, Day);
        ibsql.ParamByName('movementdate').AsDateTime := EncodeDate(Year, Month, 1) - 1;
      end
      else
        ibsql.ParamByName('movementdate').AsDateTime := InvPosition.ipDocumentDate;
    end
    else
    begin
      if gdcDocumentLine.State <> dsInsert then
        DocQuantity := GetQuantity(InvPosition.ipDocumentKey, tpAll)
      else
        DocQuantity := 0;
    end;

    ibsql.ParamByName('goodkey').AsInteger := InvPosition.ipGoodKey;
    ibsql.ParamByName('ContactKey').AsInteger := InvPosition.ipSourceContactKey;

    for i:= Low(InvPosition.ipInvSourceCardFeatures) to High(InvPosition.ipInvSourceCardFeatures) do
      if InvPosition.ipInvSourceCardFeatures[i].optValue <> Null then
        ibsql.ParamByName(InvPosition.ipInvSourceCardFeatures[i].optFieldName).AsVariant :=
          InvPosition.ipInvSourceCardFeatures[i].optValue;

    ibsql.ExecQuery;
    if (ibsql.RecordCount > 0) and (ibsql.FieldByName('cardkey').AsInteger > 0) then
    begin
      Result := ibsql.FieldByName('remains').AsCurrency;
      if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
        gdcDocumentLine.Edit;
      gdcDocumentLine.FieldByName('FromCardKey').AsInteger :=
        ibsql.FieldByName('cardkey').AsInteger;
      if (gdcDocumentLine.FindField('tocardkey') <> nil) and
         gdcDocumentLine.FieldByName('tocardkey').IsNull
      then
        gdcDocumentLine.FieldByName('tocardkey').AsInteger :=
          ibsql.FieldByName('cardkey').AsInteger;
      if gdcDocumentLine.FindField('remains') <> nil then
      begin
        gdcDocumentLine.FieldByName('remains').ReadOnly := False;
        try
          gdcDocumentLine.FieldByName('remains').AsCurrency :=
            ibsql.FieldByName('remains').AsCurrency + DocQuantity;
        finally
          gdcDocumentLine.FieldByName('remains').ReadOnly := True;
        end;
      end
      else
        if gdcDocumentLine.State = dsInsert then
        begin
          if gdcDocumentLine.FindField('fromquantity') <> nil then
          begin
            gdcDocumentLine.FieldByName('fromquantity').ReadOnly := False;
            try
              gdcDocumentLine.FieldByName('fromquantity').AsCurrency :=
                ibsql.FieldByName('remains').AsCurrency + DocQuantity;
            finally
              gdcDocumentLine.FieldByName('fromquantity').ReadOnly := True;
            end;
          end;
        end;  
    end
    else
    begin
      if (tcrSource in InvPosition.ipCheckRemains) then
      begin
        FInvErrorCode := iecGoodNotFound;
        raise EgdcInvMovement.Create(Format('По позиции %s возникла cледующая ошибка: %s',
          [gdcDocumentLine.FieldByName('GOODNAME').AsString,
          Format(gdcInvErrorMessage[InvErrorCode], [FInvErrorMessage])]));
      end;
    end;

    ibsql.Close;
  finally
    ibsql.Free;
  end;

{$IFDEF DEBUGMOVE}
  TimeGetRemains := GetTickCount - TimeTmp;
{$ENDIF}
end;

function TgdcInvMovement.SelectGoodFeatures: Boolean;
var
  InvPosition: TgdcInvPosition;
begin
  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('Не определен клаcc позиции документа');

  if (gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInvalid then
    raise EgdcInvMovement.Create('По данному документу не может быть cоздано движение');

  FillPosition(gdcDocumentLine, InvPosition);

  Result := ShowRemains(InvPosition, True);
end;

function TgdcInvMovement.ChooseRemains(const isMakePosition: Boolean = True): Boolean;
var
  InvPosition: TgdcInvPosition;
begin

  if not Assigned(gdcDocumentLine) then
    raise EgdcInvMovement.Create('Не определен клаcc позиции документа');

  if (gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInvalid then
    raise EgdcInvMovement.Create('По данному документу не может быть cоздано движение');


  try
    (gdcDocumentLine as TgdcInvDocumentLine).isChooseRemains := True;
    FillPosition(gdcDocumentLine, InvPosition);

    Result := ShowRemains(InvPosition, False);
  finally
    (gdcDocumentLine as TgdcInvDocumentLine).isChooseRemains := False;
  end;
end;

function TgdcInvMovement.ShowRemains(var InvPosition: TgdcInvPosition;
  const isPosition: Boolean): Boolean;
var
  S: String;
  C: CgdcCreateableForm;
  isDest: Boolean;
  Field: TField;
begin
  if isPosition then
  begin
    S := cst_ByGoodKey;
    C := Tgdc_frmInvSelectGoodRemains;
  end
  else
  begin
    S := cst_ByGroupKey;
    C := Tgdc_frmInvSelectRemains;
  end;
  
  if (Self.gdcDocumentLine as TgdcInvDocumentLine).RelationType = irtTransformation then
  begin
    Field := Self.gdcDocumentLine.FindField('INQUANTITY');
    isDest := Assigned(Field);
  end
  else
    isDest := False;

  with Tgdc_frmInvSelectRemains(C.CreateSubType(gdcDocumentLine, gdcDocumentLine.SubType)) do
    try
      (gdcObject as TgdcInvRemains).SetOptions(InvPosition, Self, isPosition, isDest);
      Setup((gdcObject as TgdcInvRemains));
      SetChoose(gdcDocumentLine);
      Result := ShowModal = mrOk;
      if Result then
      begin
        UserStorage.WriteBoolean('Options\Invent', 'CurrentRemains', (gdcObject as TgdcInvRemains).CurrentRemains);
        if gdcObject.HasSubSet(cst_AllRemains) then
          UserStorage.WriteBoolean('Options\Invent', 'AllRemains', True)
        else
          UserStorage.WriteBoolean('Options\Invent', 'AllRemains', False);
      end;
    finally
      Free;
    end;
end;

class function TgdcInvMovement.GetKeyField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvMovement.GetListField(const ASubType: TgdcSubType): String;
begin                       
  Result := 'ID';
end;

class function TgdcInvMovement.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'INV_MOVEMENT';
end;

procedure TgdcInvMovement.DoBeforeOpen;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVMOVEMENT', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYDOBEFOREOPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREOPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'DOBEFOREOPEN', KEYDOBEFOREOPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  InitIBSQL;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'DOBEFOREOPEN', KEYDOBEFOREOPEN);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVMOVEMENT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  for i:= 0 to FieldCount - 1 do
    Fields[i].Required := False;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvMovement.FillPosition(gdcDocumentLine: TgdcDocument;
  var InvPosition: TgdcInvPosition);
var
  i: Integer;
  MasterDataSet: TgdcInvDocument;
  MasterCreate: Boolean;
  DidActivate: Boolean;
{$IFDEF DEBUGMOVE}
TempTime: Longint;
{$ENDIF}
begin
{$IFDEF DEBUGMOVE}
  TempTime := GetTickCount;
{$ENDIF}
  with InvPosition do
  begin
    if Assigned(gdcDocumentLine.MasterSource) and
      Assigned(gdcDocumentLine.MasterSource.DataSet) then
    begin
      MasterDataSet := gdcDocumentLine.MasterSource.DataSet as TgdcInvDocument;
      MasterCreate := False;
    end else
    begin
      MasterDataSet := TgdcInvDocument.CreateSubType(nil,
        gdcDocumentLine.SubType, 'ByID') as TgdcInvDocument;
      MasterCreate := True;
    end;

    try
      DidActivate := False;
      try
        if MasterCreate then
        begin
          DidActivate := ActivateTransaction;
          MasterDataSet.ReadTransaction := gdcDocumentLine.Transaction;
          MasterDataSet.ID := gdcDocumentLine.FieldByName('parent').AsInteger;
          MasterDataSet.Open;
        end;

        ipDocumentKey := gdcDocumentLine.FieldByName('documentkey').AsInteger;
        ipDocumentDate := MasterDataSet.FieldByName('documentdate').AsDateTime;

        ipQuantity := gdcDocumentLine.FieldByName('quantity').AsCurrency;
        if (gdcDocumentLine.FindField('INQUANTITY') <> nil) or (gdcDocumentLine.FindField('OUTQUANTITY') <> nil) then
        begin
          ipQuantity := 0;
          if gdcDocumentLine.FindField('INQUANTITY') <> nil then
            ipQuantity := gdcDocumentLine.FieldByName('INQUANTITY').AsCurrency;
          if gdcDocumentLine.FindField('OUTQUANTITY') <> nil then
            ipQuantity := ipQuantity - gdcDocumentLine.FieldByName('OUTQUANTITY').AsCurrency;
        end    
        else
          if (gdcDocumentLine.FindField('FROMQUANTITY') <> nil) or (gdcDocumentLine.FindField('TOQUANTITY') <> nil) then
          begin
            ipQuantity := gdcDocumentLine.FieldByName('TOQUANTITY').AsCurrency -
              gdcDocumentLine.FieldByName('FROMQUANTITY').AsCurrency
          end;

        ipGoodKey := gdcDocumentLine.FieldByName('goodkey').AsInteger;
        if (gdcDocumentLine.State = dsEdit) and ((gdcDocumentLine.FieldByName('QUANTITY').OldValue = Null) or
           (gdcDocumentLine.FieldByName('QUANTITY').OldValue = 0)) and
           not (irsRemainsRef in (gdcDocumentLine as TgdcInvDocumentLine).Sources)
        then
          ipBaseCardKey := -1
        else
          ipBaseCardKey := gdcDocumentLine.FieldByName('fromcardkey').AsInteger;

        FCurrentRemains := (gdcDocumentLine as TgdcInvDocumentLine).LiveTimeRemains;
        FEndMonthRemains := (gdcDocumentLine as TgdcInvDocumentLine).EndMonthRemains;
        ipMinusRemains := (gdcDocumentLine as TgdcInvDocumentLine).isMinusRemains;
        if ((gdcDocumentLine as TgdcInvDocumentLine).RelationType = irtTransformation) and
           (gdcDocumentLine.FindField('OUTQUANTITY') <> nil) and
           (gdcDocumentLine.FieldByName('OUTQUANTITY').AsCurrency > 0)
        then
          ipMinusRemains := False;   

        with (gdcDocumentLine as TgdcInvBaseDocument) do
        begin
          if
            (AnsiCompareText(MovementSource.RelationName, RelationName) = 0) and
            (MovementSource.SourceFieldName > '')
          then
            ipSourceContactKey := MasterDataSet.
              FieldByName(MovementSource.SourceFieldName).AsInteger
          else

          if (MovementSource.SourceFieldName > '') then
            ipSourceContactKey := FieldByName(MovementSource.SourceFieldName).AsInteger;

          if (AnsiCompareText(MovementTarget.RelationName, RelationName) = 0) and
             (MovementTarget.SourceFieldName > '')
          then
            ipDestContactKey := MasterDataSet.
              FieldByName(MovementTarget.SourceFieldName).AsInteger
          else

          if (MovementTarget.SourceFieldName > '') then
            ipDestContactKey := FieldByName(MovementTarget.SourceFieldName).AsInteger;

    // Уcтанавливаем значения контактов ограничителей

          ipSubSourceContactKey := -1;
          ipSubDestContactKey := -1;

          if
            (AnsiCompareText(MovementSource.SubRelationName, RelationName) = 0) and
            (MovementSource.SubSourceFieldName > '')
          then
            ipSubSourceContactKey := MasterDataSet.
              FieldByName(MovementSource.SubSourceFieldName).AsInteger
          else

          if (MovementSource.SubSourceFieldName > '') then
            ipSubSourceContactKey := FieldByName(MovementSource.SubSourceFieldName).AsInteger;

          if (AnsiCompareText(MovementTarget.SubRelationName, RelationName) = 0) and
             (MovementTarget.SubSourceFieldName > '')
          then
            ipSubDestContactKey := MasterDataSet.
              FieldByName(MovementTarget.SubSourceFieldName).AsInteger
          else

          if (MovementTarget.SubSourceFieldName > '') then
            ipSubDestContactKey := FieldByName(MovementTarget.SubSourceFieldName).AsInteger;

          SetLength(ipPredefinedSourceContact,
            High(MovementSource.Predefined) - Low(MovementSource.Predefined) + 1);
          for i:= Low(MovementSource.Predefined) to High(MovementSource.Predefined) do
            ipPredefinedSourceContact[i] := MovementSource.Predefined[i];

          SetLength(ipPredefinedDestContact,
            High(MovementTarget.Predefined) - Low(MovementTarget.Predefined) + 1);
          for i:= Low(MovementTarget.Predefined) to High(MovementTarget.Predefined) do
            ipPredefinedDestContact[i] := MovementTarget.Predefined[i];

          SetLength(ipSubPredefinedSourceContact,
            High(MovementSource.SubPredefined) - Low(MovementSource.SubPredefined) + 1);
          for i:= Low(MovementSource.SubPredefined) to High(MovementSource.SubPredefined) do
            ipSubPredefinedSourceContact[i] := MovementSource.SubPredefined[i];

          SetLength(ipSubPredefinedDestContact,
            High(MovementTarget.SubPredefined) - Low(MovementTarget.SubPredefined) + 1);
          for i:= Low(MovementTarget.SubPredefined) to High(MovementTarget.SubPredefined) do
            ipSubPredefinedDestContact[i] := MovementTarget.SubPredefined[i];
        end;

        if not (irsRemainsRef in (gdcDocumentLine as TgdcInvDocumentLine).Sources) or
          (gdcDocumentLine.FieldByName('fromcardkey').IsNull and not (gdcDocumentLine as TgdcInvDocumentLine).ControlRemains)
        then
          ipCheckRemains := [tcrDest]
        else
          if (gdcDocumentLine as TgdcInvDocumentLine).ControlRemains then
            ipCheckRemains := [tcrSource]
          else
            ipCheckRemains := [];


        ipMovementDirection := (gdcDocumentLine as TgdcInvDocumentLine).Direction;

        if (gdcDocumentLine as TgdcInvDocumentLine).CanBeDelayed then
          ipDelayed :=
           MasterDataSet.FieldByName('DELAYED').AsInteger <> 0
        else
          ipDelayed := False;

        SetLength(ipInvSourceCardFeatures, 0);  

        if ((gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtTransformation) or
           ((gdcDocumentLine as TgdcInvDocumentLine).ViewMovementPart = impExpense) or
           (((gdcDocumentLine as TgdcInvDocumentLine).FindField('OUTQUANTITY') <> nil) and
           ((gdcDocumentLine as TgdcInvDocumentLine).FieldByName('OUTQUANTITY').AsCurrency > 0))
        then
        begin

          SetLength(ipInvSourceCardFeatures,
             High((gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures) -
             Low((gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures) + 1);

          for i:= Low((gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures) to
            High((gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures) do
          begin
            ipInvSourceCardFeatures[i].optFieldName :=
              (gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures[i];
            ipInvSourceCardFeatures[i].optValue :=
              gdcDocumentLine.FieldByName(
                INV_SOURCEFEATURE_PREFIX +
                (gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures[i]).AsVariant;
            if gdcDocumentLine.FieldByName(
                 INV_SOURCEFEATURE_PREFIX +
                 (gdcDocumentLine as TgdcInvDocumentLine).SourceFeatures[i]).DataType in [ftSmallint, ftBCD, ftInteger, ftLargeInt] then
              ipInvSourceCardFeatures[i].isInteger := True;
          end;
        end;

        SetLength(ipInvMinusCardFeatures, 0);
        if ipMinusRemains then
        begin
          SetLength(ipInvMinusCardFeatures,
             High((gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures) -
             Low((gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures) + 1);

          for i:= Low((gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures) to
            High((gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures) do
          begin
            ipInvMinusCardFeatures[i].optFieldName :=
              (gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures[i];
            ipInvMinusCardFeatures[i].optValue :=
              gdcDocumentLine.FieldByName(
                INV_DESTFEATURE_PREFIX +
                (gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures[i]).AsVariant;
            if gdcDocumentLine.FieldByName(
                INV_DESTFEATURE_PREFIX +
                (gdcDocumentLine as TgdcInvDocumentLine).MinusFeatures[i]).DataType in [ftSmallint, ftBCD, ftInteger, ftLargeInt] then
              ipInvMinusCardFeatures[i].isInteger := True;
          end;

        end;

        SetLength(ipInvDestCardFeatures, 0);

        if ((gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtTransformation) or
           ((gdcDocumentLine as TgdcInvDocumentLine).ViewMovementPart = impIncome) or
           (((gdcDocumentLine as TgdcInvDocumentLine).FindField('INQUANTITY') <> nil) and
           ((gdcDocumentLine as TgdcInvDocumentLine).FieldByName('INQUANTITY').AsCurrency > 0))

        then
        begin

          SetLength(ipInvDestCardFeatures,
             High((gdcDocumentLine as TgdcInvDocumentLine).DestFeatures) -
             Low((gdcDocumentLine as TgdcInvDocumentLine).DestFeatures) + 1);


          for i:= Low((gdcDocumentLine as TgdcInvDocumentLine).DestFeatures) to
            High((gdcDocumentLine as TgdcInvDocumentLine).DestFeatures) do
          begin
            ipInvDestCardFeatures[i].optFieldName :=
              (gdcDocumentLine as TgdcInvDocumentLine).DestFeatures[i];
            ipInvDestCardFeatures[i].optValue :=
              gdcDocumentLine.FieldByName(
                INV_DESTFEATURE_PREFIX +
                (gdcDocumentLine as TgdcInvDocumentLine).DestFeatures[i]).AsVariant;
            if gdcDocumentLine.FieldByName(
                INV_DESTFEATURE_PREFIX +
                (gdcDocumentLine as TgdcInvDocumentLine).DestFeatures[i]).DataType in [ftSmallint, ftBCD, ftInteger, ftLargeInt] then
              ipInvDestCardFeatures[i].isInteger := True;
          end;

        end;

        ipOneRecord := ((gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtInventorization) or
          ((gdcDocumentLine as TgdcInvBaseDocument).RelationType = irtTransformation);

        if DidActivate and gdcDocumentLine.Transaction.InTransaction then
          gdcDocumentLine.Transaction.Commit;

      except
        if DidActivate and gdcDocumentLine.Transaction.InTransaction then
          gdcDocumentLine.Transaction.Rollback;
      end;

    finally
      if MasterCreate then
        MasterDataSet.Free;
    end;
  end;
{$IFDEF DEBUGMOVE}
TimeFillPosition := TimeFillPosition + GetTickCount - TempTime; 
{$ENDIF}
end;

procedure TgdcInvMovement.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (AComponent = FgdcDocumentLine) and (Operation = opRemove) then
    FgdcDocumentLine := nil;
end;

function TgdcInvMovement.SetEnableMovement(const aDocumentKey: Integer;
  const isEnabled: Boolean): Boolean;
begin
{  if RecordCount > 0 then
  begin}
    Close;
    ExecSingleQuery(Format('UPDATE inv_movement SET disabled = %d WHERE documentkey = %d',
      [Integer(not isEnabled), aDocumentKey]));
    Open;
{  end;}
  Result := True;
end;

function TgdcInvMovement.DeleteEnableMovement(const aDocumentKey: Integer;
  const isEnabled: Boolean): Boolean;
begin
  ExecSingleQuery(Format('DELETE FROM inv_movement WHERE disabled = %d AND documentkey = %d',
      [Integer(not isEnabled), aDocumentKey]));
  Result := True;
end;

function TgdcInvMovement.CheckMovementOnCard(const aCardKey: Integer;
  var InvPosition: TgdcInvPosition): Boolean;
var
//  CardValue: TgdcCardValue;
  ibsqlGetCards: TIBSQL;
  ibsqlCardMovement: TIBSQL;
  ibsqlCard: TIBSQL;
  i, IndexField: Integer;
  FieldList: TStringList;
  InvDocument: TgdcInvBaseDocument;
  isChange, isFirst: Boolean;
  S: String;
  Stream: TStream;

begin
  Result := True;
  ibsqlCardMovement := TIBSQL.Create(Self);
  ibsqlGetCards := TIBSQL.Create(Self);

  FieldList := TStringList.Create;
  try
    GetCardInfo(aCardKey);

    for i:= Low(InvPosition.ipInvDestCardFeatures) to High(InvPosition.ipInvDestCardFeatures) do
      if FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).AsVariant <>
         InvPosition.ipInvDestCardFeatures[i].optValue
      then
        FieldList.Add(InvPosition.ipInvDestCardFeatures[i].optFieldName);

    ibsqlCardMovement.Transaction := Transaction;

    ibsqlCardMovement.SQL.Text :=
      ' SELECT '#13#10 +
      '   c.*, doct.id as doctypekey, doct.options, doc.id as dockey, doct.ruid '#13#10 +
      ' FROM inv_card c '#13#10 +
      '   LEFT JOIN inv_movement m '#13#10 +
      '     ON m.cardkey = c.id '#13#10 +
      '   LEFT JOIN gd_document doc '#13#10 +
      '     ON m.documentkey = doc.id '#13#10 +
      '   LEFT JOIN gd_documenttype doct '#13#10 +
      '     ON doc.documenttypekey = doct.id '#13#10 +
      ' WHERE c.id = :id  ';
    S := '';
    for i:= Low(InvPosition.ipInvDestCardFeatures) to High(InvPosition.ipInvDestCardFeatures) do
      if FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).AsVariant <>
         InvPosition.ipInvDestCardFeatures[i].optValue
      then
      begin
        if S > '' then
          S := S + ' OR ';
        if InvPosition.ipInvDestCardFeatures[i].isInteger then
          if FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).IsNull then
            S := S + ' (C.' + InvPosition.ipInvDestCardFeatures[i].optFieldName + ' + 0) IS NULL '
          else
            S := S + ' (C.' + InvPosition.ipInvDestCardFeatures[i].optFieldName + ' + 0) = :' +
              InvPosition.ipInvDestCardFeatures[i].optFieldName
        else
          if FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).IsNull then
            S := S + ' C.' + InvPosition.ipInvDestCardFeatures[i].optFieldName + ' IS NULL '
          else
            S := S + ' C.' + InvPosition.ipInvDestCardFeatures[i].optFieldName +
              ' = :' + InvPosition.ipInvDestCardFeatures[i].optFieldName;
      end;

    if S <> '' then
      ibsqlCardMovement.SQL.Text := ibsqlCardMovement.SQL.Text + 'AND (' + S + ' )';

    ibsqlCardMovement.SQL.Text := ibsqlCardMovement.SQL.Text + ' AND m.documentkey <> c.firstdocumentkey ';

    for i:= Low(InvPosition.ipInvDestCardFeatures) to High(InvPosition.ipInvDestCardFeatures) do
      if (FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).AsVariant <>
         InvPosition.ipInvDestCardFeatures[i].optValue) and
         not FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).IsNull
      then
        ibsqlCardMovement.ParamByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).AsVariant :=
           FieldByName(InvPosition.ipInvDestCardFeatures[i].optFieldName).AsVariant;

    ibsqlGetCards.Transaction := Transaction;
    ibsqlGetCards.SQL.Text := 'SELECT ID FROM inv_p_GetCards( ' + IntToStr(aCardKey) + ') ';
    ibsqlGetCards.ExecQuery;

    isFirst := True;
    while isFirst and not ibsqlGetCards.EOF do
    begin

      ibsqlCardMovement.Close;

      if isFirst then
        ibsqlCardMovement.ParamByName('id').AsInteger := aCardKey
      else
        ibsqlCardMovement.ParamByName('id').AsInteger := ibsqlGetCards.FieldByName('ID').AsInteger;
      ibsqlCardMovement.ExecQuery;

      if ibsqlCardMovement.RecordCount > 0 then
      begin


        while not ibsqlCardMovement.EOF do
        begin
          InvDocument := TgdcInvDocumentLine.Create(Self);
          try
            InvDocument.SubType := ibsqlCardMovement.FieldByName('ruid').AsString;
            Stream := TStringStream.Create(ibsqlCardMovement.FieldByName('options').AsString);
            try
              InvDocument.ReadOptions(Stream);
            finally
              Stream.Free;
            end;

            isChange := False;
            for i:= Low((InvDocument as TgdcInvDocumentLine).SourceFeatures) to
              High((InvDocument as TgdcInvDocumentLine).SourceFeatures) do
            begin
              IndexField :=
                FieldList.IndexOf((InvDocument as TgdcInvDocumentLine).SourceFeatures[i]);
              if (IndexField >= 0) and (FibsqlCardInfo.FieldByName(FieldList[IndexField]).AsVariant =
                ibsqlCardMovement.FieldByName(FieldList[IndexField]).AsVariant)
              then
              begin
                isChange := True;
                Break;
              end;
            end;

{            Result := not isChange;}

            if isChange then
            begin
              ibsqlCard := TIBSQL.Create(Self);
              try
                ibsqlCard.Transaction := Transaction;
                ibsqlCard.SQL.Text := 'SELECT id FROM inv_movement WHERE documentkey = :dk and ' +
                  ' credit > 0 and cardkey <> :ck';
                ibsqlCard.ParamByName('dk').AsInteger := ibsqlCardMovement.FieldByName('dockey').AsInteger;
                ibsqlCard.ParamByName('ck').AsInteger := ibsqlCardMovement.FieldByName('id').AsInteger;
                ibsqlCard.ExecQuery;
                Result := ibsqlCard.RecordCount = 0;
              finally
                ibsqlCard.Free;
              end;
              if not Result then Break;
            end;
          finally
            InvDocument.Free;
          end;

          ibsqlCardMovement.Next;
        end;

      end;

      if not Result then
        Break;

      if not isFirst then
        ibsqlGetCards.Next;
      isFirst := False;
    end;
  finally
    FieldList.Free;
    ibsqlCardMovement.Free;
    ibsqlGetCards.Free;
  end;
end;

function TgdcInvMovement.GetRefreshSQLText: String;
begin
  Result := '';
end;

procedure TgdcInvMovement._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVMOVEMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVMOVEMENT', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVMOVEMENT',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('disabled').AsInteger := 0;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVMOVEMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVMOVEMENT', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

class procedure TgdcInvMovement.RegisterClassHierarchy;

  procedure ReadFromDocumentType(ACE: TgdClassEntry);
  var
    CurrCE: TgdClassEntry;
    ibsql: TIBSQL;
    LSubType: string;
    LComment: String;
    LParentSubType: string;
  begin
    if ACE.Initialized then
      exit;

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text :=
        'SELECT '#13#10 +
        '  dt.name AS comment, '#13#10 +
        '  dt.classname AS classname, '#13#10 +
        '  dt.ruid AS subtype, '#13#10 +
        '  dt1.ruid AS parentsubtype '#13#10 +
        'FROM gd_documenttype dt '#13#10 +
        'LEFT JOIN gd_documenttype dt1 '#13#10 +
        '  ON dt1.id = dt.parent '#13#10 +
        '  AND dt1.documenttype = ''D'' '#13#10 +
        'WHERE '#13#10 +
        '  dt.documenttype = ''D'' '#13#10 +
        '  and dt.classname = ''TgdcInvDocumentType'' '#13#10 +
        'ORDER BY dt.parent';

      ibsql.ExecQuery;

      while not ibsql.EOF do
      begin
        LSubType := ibsql.FieldByName('subtype').AsString;
        LComment := ibsql.FieldByName('comment').AsString;
        LParentSubType := ibsql.FieldByName('parentsubtype').AsString;

        CurrCE := gdClassList.Add(ACE.TheClass, LSubType, LComment, LParentSubType);

        CurrCE.Initialized := True;
        ibsql.Next;
      end;
    finally
      ibsql.Free;
    end;

    ACE.Initialized := True;
  end;

var
  CEBase: TgdClassEntry;

begin
  CEBase := gdClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromDocumentType(CEBase);
end;

procedure TgdcInvMovement.SetSubSet(const Value: TgdcSubSet);
begin
  inherited;
  BufferChunks := 10;
end;

{function TgdcInvMovement.CheckCardField(const SourceCardKey: Integer;
  var CardFeatures: array of TgdcInvCardFeature): Boolean;
var
  ibsql: TIBSQL;
  i: Integer;
  S: String;
begin
  Result := True;
  if High(CardFeatures) >= Low(CardFeatures) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := Transaction;
      S := '';
      for i:= Low(CardFeatures) to High(CardFeatures) do
      begin
        if S <> '' then
          S := S + ',';
        S := S + CardFeatures[i].optFieldName + ' = :' + CardFeatures[i].optFieldName;
      end;

      ibsql.SQL.Text := 'UPDATE inv_card SET ' + S + ' WHERE id = :id ';

      for i:= Low(CardFeatures) to High(CardFeatures) do
      begin
        ibsql.ParamByName(CardFeatures[i].optFieldName).AsVariant :=  CardFeatures[i].optValue;
        if not ibsql.ParamByName(CardFeatures[i].optFieldName).IsNullable then
          Result := False;
      end;

      try
        ibsql.Prepare;
      except
        Result := False;
      end;

    finally
      ibsql.Free;
    end;
  end;
end;}

function TgdcInvMovement.GetIsGetRemains: Boolean;
begin
  Result := FIsGetRemains;
end;

procedure TgdcInvMovement.SetIsGetRemains(const Value: Boolean);
begin
  FIsGetRemains := Value;
end;

function TgdcInvMovement.GetCardDocumentKey(
  const CardKey: Integer): Integer;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT documentkey FROM inv_card WHERE id = :id';
    ibsql.ParamByName('id').AsInteger := cardkey;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      Result := ibsql.FieldByName('documentkey').AsInteger
    else
      Result := -1;
    ibsql.Close;    
  finally
    ibsql.Free;
  end;
end;

function TgdcInvMovement.IsReplaceDestFeature(ContactKey, CardKey,
  DocumentKey: Integer; ChangedField: TStringList;
  var InvPosition: TgdcInvPosition): Boolean;
begin
  if FShowMovementDlg then
  begin
    with Tgdc_dlgShowMovement.Create(gdcDocumentLine.ParentForm) do
       try
         gdcDocumentLine := Self.gdcDocumentLine;
         Result := ShowModal = mrOk;
       finally
         Free;
       end;
  end
  else
    Result := True;
end;

procedure TgdcInvMovement.ClearCardQuery;
begin
  ibsqlCardList.Close;
  ibsqlCardList.SQL.Text := '';
end;

{ TgdcInvBaseRemains }

constructor TgdcInvBaseRemains.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);

  if not (csDesigning in ComponentState) then
    FIsNewDateRemains := GlobalStorage.ReadBoolean('Options\Invent', 'UseDelMovement', True);
  FViewFeatures := TStringList.Create;
  FSumFeatures := TStringList.Create;
  FGoodViewFeatures := TStringList.Create;
  FGoodSumFeatures := TStringList.Create;

  FCurrentRemains := False;
  FIsMinusRemains := False;
  FIsUseCompanyKey := True;

  FRemainsDate := 0;
  FEndMonthRemains := False;

  RemainsSQLType := irstSimpleSum;

  // Предполагается что объект подключен к этой же БД
  FUseSelectFromSelect := True;
 {   (gdcBaseManager.Database.IsFirebirdConnect and (gdcBaseManager.Database.ServerMajorVersion >= 2));}
end;

procedure TgdcInvBaseRemains.CreateFields;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVBASEREMAINS', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  for i:= 0 to FieldCount - 1 do
  begin
    if (UpperCase(Fields[i].FieldName) <> 'CHOOSEQUANTITY') and
      (UpperCase(Fields[i].FieldName) <> 'CHOOSEQUANTPACK')
    then
      Fields[i].ReadOnly := True
    else
      Fields[i].ReadOnly := False;

    Fields[i].Required := False;
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVBASEREMAINS', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVBASEREMAINS', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVBASEREMAINS', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

destructor TgdcInvBaseRemains.Destroy;
begin

  inherited;
  if Assigned(FViewFeatures) then
    FreeAndNil(FViewFeatures);

  if Assigned(FSumFeatures) then
    FreeAndNil(FSumFeatures);
    
  if Assigned(FGoodViewFeatures) then
    FreeAndNil(FGoodViewFeatures);

  if Assigned(FGoodSumFeatures) then
    FreeAndNil(FGoodSumFeatures);

end;

function TgdcInvBaseRemains.GetFromClause(const ARefresh: Boolean = False): String;
var
(*  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO} *)
  Ignore: TatIgnore;
begin
(*  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVBASEREMAINS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}     *)
  if UseSelectFromSelect then
  begin
    Result := '';
    exit;
  end;

  Result := ' FROM INV_CARD C JOIN GD_GOOD G ON (G.ID = C.GOODKEY) ';

  if not IBLogin.IsUserAdmin then
    Result := Result + Format(' AND g_sec_test(g.aview, %d) <> 0 ', [IBLogin.InGroup]);

  if csDesigning in ComponentState then
    exit;

  if not CurrentRemains then
  begin
    if not FIsNewDateRemains then
      Result := Result + ' JOIN INV_MOVEMENT M ON C.ID = M.CARDKEY '
    else
      Result := Result + ' JOIN INV_BALANCE M ON C.ID = M.CARDKEY ';
  end
  else
    Result := Result + ' JOIN INV_BALANCE M ON C.ID = M.CARDKEY ';

  if HasSubSet(cst_ByGoodKey) then
  begin

    if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
      (not CurrentRemains and (atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY') = nil)) or
      (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
    then
      Result := Result + ' AND C.GOODKEY = :GOODKEY '
    else
      Result := Result + ' AND M.GOODKEY = :GOODKEY '

  end;

  FSQLSetup.Ignores.AddAliasName('C');

  if not HasSubSet(cst_ByGoodKey) then
  begin
    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'GG';

    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'G';
  end;

  Ignore := FSQLSetup.Ignores.Add;
  Ignore.AliasName := 'CON';

(*  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}  *)
end;

function TgdcInvBaseRemains.GetGroupClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVBASEREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if csDesigning in ComponentState then
    exit;

  Result := ' GROUP BY g.Name, g.ID, v.Name, g.Alias ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvBaseRemains.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvBaseRemains.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvBaseRemains.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'INV_MOVEMENT';
end;

function TgdcInvBaseRemains.GetRefreshSQLText: String;
begin
  Result := '';
end;

function TgdcInvBaseRemains.GetSelectClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVBASEREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := ' SELECT MIN(m.cardkey) as id, g.id as goodkey, ' +
    'g.name as namegood, g.alias as goodalias, v.name as valuename ';

  if csDesigning in ComponentState then
    exit;

  if not (CurrentRemains or UseSelectFromSelect) then
  begin
    if not FIsNewDateRemains then
    begin
      if FIsMinusRemains then
        Result := Result + ', SUM(M.CREDIT - M.DEBIT) as REMAINS '
      else
        Result := Result + ', SUM(M.DEBIT - M.CREDIT) as REMAINS '
    end
    else
    begin
      if FIsMinusRemains then
        Result := Result + ', SUM(REST.REMAINS - M.BALANCE) as REMAINS '
      else
        Result := Result + ', SUM(M.BALANCE - REST.REMAINS) as REMAINS '
    end;
  end
  else
  begin
    if FIsMinusRemains then
      Result := Result + ', SUM(0-M.BALANCE) AS REMAINS '
    else
      Result := Result + ', SUM(M.BALANCE) AS REMAINS ';
  end;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.GetWhereClauseConditions(S: TStrings);
begin
  Assert(Assigned(IBLogin));

  if csDesigning in ComponentState then
    exit;

  inherited;

  if IsUseCompanyKey then
    S.Add('Cast(C.COMPANYKEY + 0 AS Integer) = :companykey');
    
  if not (CurrentRemains or UseSelectFromSelect) then
  begin
    if not FIsNewDateRemains then
      S.Add(' M.DISABLED = 0 ');
  end
  else
  begin
    if FisMinusRemains then
      S.Add(' M.BALANCE < 0 ')
    else
      if not HasSubSet(cst_AllRemains) then
        S.Add(' M.BALANCE <> 0 ');
  end;
end;

procedure TgdcInvBaseRemains.SetViewFeatures(const Value: TStringList);
begin
  if Assigned(FViewFeatures) then
    FViewFeatures.Assign(Value);
end;


class function TgdcInvBaseRemains.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + cst_ByGoodKey + ';' + cst_ByGroupKey + ';' + cst_AllRemains + ';' + cst_Holding + ';';
end;

class procedure TgdcInvBaseRemains.RegisterClassHierarchy;

  procedure ReadFromDocumentType(ACE: TgdClassEntry);
  var
    CurrCE: TgdClassEntry;
    ibsql: TIBSQL;
    LSubType: string;
    LComment: String;
    LParentSubType: string;
  begin
    if ACE.Initialized then
      exit;

    ibsql := TIBSQL.Create(nil);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text :=
        'SELECT '#13#10 +
        '  dt.name AS comment, '#13#10 +
        '  dt.classname AS classname, '#13#10 +
        '  dt.ruid AS subtype, '#13#10 +
        '  dt1.ruid AS parentsubtype '#13#10 +
        'FROM gd_documenttype dt '#13#10 +
        'LEFT JOIN gd_documenttype dt1 '#13#10 +
        '  ON dt1.id = dt.parent '#13#10 +
        '  AND dt1.documenttype = ''D'' '#13#10 +
        'WHERE '#13#10 +
        '  dt.documenttype = ''D'' '#13#10 +
        '  and dt.classname = ''TgdcInvDocumentType'' '#13#10 +
        'ORDER BY dt.parent';

      ibsql.ExecQuery;

      while not ibsql.EOF do
      begin
        LSubType := ibsql.FieldByName('subtype').AsString;
        LComment := ibsql.FieldByName('comment').AsString;
        LParentSubType := ibsql.FieldByName('parentsubtype').AsString;

        CurrCE := gdClassList.Add(ACE.TheClass, LSubType, LComment, LParentSubType);

        CurrCE.Initialized := True;
        ibsql.Next;
      end;

      ibsql.Close;

      ibsql.SQL.Text :=
        'SELECT RUID FROM INV_BALANCEOPTION ';

      ibsql.ExecQuery;

      while not ibsql.EOF do
      begin
        LSubType := ibsql.FieldByName('RUID').AsString;
        CurrCE := gdClassList.Add(ACE.TheClass, LSubType + '=' + LSubType);

        CurrCE.Initialized := True;
        ibsql.Next;
      end;

    finally
      ibsql.Free;
    end;

    ACE.Initialized := True;
  end;

var
  CEBase: TgdClassEntry;

begin
  CEBase := gdClassList.Find(Self);

  if CEBase = nil then
    raise EgdcException.Create('Unregistered class.');

  ReadFromDocumentType(CEBase);
end;

class function TgdcInvBaseRemains.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvViewRemains';
end;

procedure TgdcInvBaseRemains.SetSubType(const Value: String);
var
  ibsql: TIBSQL;
  DidActivate: Boolean;
  Stream: TStringStream;
begin
  if csDesigning in ComponentState then
    exit;

  if SubType <> Value then
  begin
    inherited;
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := gdcBaseManager.ReadTransaction;
      DidActivate := not ibsql.Transaction.Active;
      if DidActivate then
        ibsql.Transaction.StartTransaction;
      ibsql.SQL.Text := 'SELECT * FROM inv_balanceoption WHERE ruid = :ruid';
      ibsql.ParamByName('ruid').AsString := Value;
      ibsql.ExecQuery;
      if ibsql.RecordCount > 0 then
      begin
        Stream := TStringStream.Create(ibsql.FieldByName('viewfields').AsString);
        try
          ReadFeatures(FViewFeatures, Stream);
        finally
          Stream.Free;
        end;

        Stream := TStringStream.Create(ibsql.FieldByName('sumfields').AsString);
        try
          ReadFeatures(FSumFeatures, Stream);
        finally
          Stream.Free;
        end;

        Stream := TStringStream.Create(ibsql.FieldByName('goodviewfields').AsString);
        try
          ReadGoodFeatures(FGoodViewFeatures, Stream);
        finally
          Stream.Free;
        end;

        Stream := TStringStream.Create(ibsql.FieldByName('goodsumfields').AsString);
        try
          ReadGoodFeatures(FGoodSumFeatures, Stream);
        finally
          Stream.Free;
        end;

        isUseCompanyKey := ibsql.FieldByName('usecompanykey').AsInteger = 1;

      end;
      ibsql.Close;
      if DidActivate then
        ibsql.Transaction.Commit;

    finally
      ibsql.Free;
    end;
  end;
end;

procedure TgdcInvBaseRemains.DoBeforeInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
   if (not CanCreate) and (not IBLogin.IsIBUserAdmin) then
     raise EgdcUserHaventRights.CreateFmt(strHaventRights,
       [strCreate, ClassName, SubType, GetDisplayName(SubType)]);

  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVBASEREMAINS', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  abort;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvBaseRemains.SetActive(Value: Boolean);
begin
  if (SubType <> '') or not Value then
    inherited;

end;

procedure TgdcInvBaseRemains.SetSumFeatures(const Value: TStringList);
begin
  if Assigned(FSumFeatures) then
    FSumFeatures.Assign(Value);
end;

procedure TgdcInvBaseRemains.ReadFeatures(FFeatures: TStringList;
  Stream: TStream);
var
  F: TatRelationField;
begin
  with TReader.Create(Stream, 1024) do
  try
    ReadListBegin;
    while not EndOfList do
    begin
      F := atDatabase.FindRelationField('INV_CARD', ReadString);
      if not Assigned(F) then Continue;
      FFeatures.Add(F.FieldName);
    end;
    ReadListEnd;
  finally
    Free;
  end;

end;

function TgdcInvBaseRemains.GetRemainsName: String;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT name FROM inv_balanceoption WHERE ruid = :ruid';
    ibsql.ParamByName('ruid').AsString := SubType;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      Result := ibsql.FieldByName('name').AsString
    else
      Result := 'Оcтатки';
    ibsql.Close;
  finally
    ibsql.Free;
  end;
end;

procedure TgdcInvBaseRemains.SetGoodSumFeatures(const Value: TStringList);
begin
  if Assigned(FGoodSumFeatures) then
    FGoodSumFeatures.Assign(Value);
end;

procedure TgdcInvBaseRemains.SetGoodViewFeatures(const Value: TStringList);
begin
  if Assigned(FGoodViewFeatures) then
    FGoodViewFeatures.Assign(Value);
end;

procedure TgdcInvBaseRemains.ReadGoodFeatures(FFeatures: TStringList;
  Stream: TStream);
var
  F: TatRelationField;
begin
  if Stream.Size > 0 then
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      while not EndOfList do
      begin
        F := atDatabase.FindRelationField('GD_GOOD', ReadString);
        if not Assigned(F) then Continue;
        FFeatures.Add(F.FieldName);
      end;
      ReadListEnd;
    finally
      Free;
    end;
end;

class function TgdcInvBaseRemains.GetListTableAlias: String;
begin
  Result := 'c';
end;

procedure TgdcInvBaseRemains.SetCurrentRemains(const Value: Boolean);
begin
  if Value <> FCurrentRemains then
  begin
    FCurrentRemains := Value;
    FSQLInitialized := False;
  end;
end;

function TgdcInvBaseRemains.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCINVBASEREMAINS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVBASEREMAINS', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVBASEREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVBASEREMAINS',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCINVBASEREMAINS(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVBASEREMAINS' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVBASEREMAINS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVBASEREMAINS', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}
end;

class function TgdcInvBaseRemains.IsAbstractClass: Boolean;
begin
  Result := Self.ClassNameIs('TgdcInvBaseRemains');
end;

class function TgdcInvBaseRemains.GetDisplayName(
  const ASubType: TgdcSubType): String;
var
  Idx: Integer;
begin
  Result := 'Остатки ТМЦ';

  if ASubType > '' then
  begin
    Idx := TgdcDocument.CacheDocumentTypeByRUID(ASubType);
    if Idx > -1 then
      Result := Result + ' ' + gdcClasses.DocTypeCache.CacheItemsByIndex[Idx].Name;
  end;
end;

{ TgdcInvRemains }

constructor TgdcInvRemains.Create(anOwner: TComponent);
begin
  inherited Create(anOwner);

  FGoodKey := -1;
  FGroupKey := -1;
  SetLength(FChooseFeatures, 0);
  CachedUpdates := True;
  FCheckRemains := True;
  FgdcDocumentLine := nil;
  FIsDest := False;

  SetLength(FDepartmentKeys, 0);
  SetLength(FSubDepartmentKeys, 0);

end;

destructor TgdcInvRemains.Destroy;
begin

  inherited;

end;

function TgdcInvRemains.GetFromClause(const ARefresh: Boolean = False): String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Ignore: TatIgnore;
  i: Integer;
  F: TatRelationField;
  St: String;

  function MakeInvBalancePart: String;
  var
    i : Integer;
  begin
    Result := ' SELECT M.CARDKEY, M.CONTACTKEY, '#13#10 +
      '   SUM(M.BALANCE) AS BALANCE '#13#10 +
      ' FROM '#13#10 +
      '   INV_BALANCE M ';
    if HasSubSet(cst_ByGoodKey) then
    begin
      if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
        (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
      then
        Result := Result + #13#10 +
          ' JOIN INV_CARD C ON C.ID = M.CARDKEY ';
    end;

    if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
       (High(DepartmentKeys) >= Low(DepartmentKeys))
    then
    begin
      if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB and CON.contacttype = 2'
          else
            Result := Result + ' JOIN (SELECT CON.ID FROM GD_CONTACT CON ' +
              ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON CON1.id = h.companykey AND h.holdingkey = :holdingkey ) H ON H.ID = M.CONTACTKEY ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end
      else
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB '
          else
            Result := Result + ' JOIN (SELECT CON.ID FROM GD_CONTACT CON ' +
              ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON CON1.id = h.companykey AND h.holdingkey = :holdingkey ) H ON H.ID = M.CONTACTKEY ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end;
    end;

    if (not ARefresh) and (not HasSubSet(cst_ByGoodKey))  then
    begin
      Result := Result + ' JOIN GD_GOOD G ON ( G.ID  =  M.GOODKEY ) ';
      if not CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) then
      begin
        Result := Result + ' JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID) ';
        if not HasSubSet('All') then
          Result := Result + 'AND ( GG.LB >= :LB AND GG.RB <= :RB )';
      end
      else
        Result := Result + ' LEFT JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID)';
    end;

    Result := Result + #13#10 + ' WHERE ';
    if FIsMinusRemains then
      Result := Result +  ' M.BALANCE < 0 '
    else
      if not HasSubSet(cst_AllRemains) then
        Result := Result +  '  M.BALANCE <> 0 '
      else
        Result := Result +  '  (1 = 1) ';

    if HasSubSet(cst_ByGoodKey) then
    begin
      if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
        (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
      then
        Result := Result + ' AND C.GOODKEY = :GOODKEY '
      else
        Result := Result + ' AND M.GOODKEY = :GOODKEY '
    end;

    if not HasSubSet(cst_ByGoodKey) then
      if CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) and not HasSubSet('All') then
        Result := Result +  ' AND ( GG.LB >= :LB AND GG.RB <= :RB )';

    if (High(DepartmentKeys) > Low(DepartmentKeys))
    then
    begin
      St := '(';
      for i:= Low(DepartmentKeys) to High(DepartmentKeys) do
      begin
        St := St + IntToStr(DepartmentKeys[i]);
        if i < High(DepartmentKeys) then
          St := St + ',';
      end;
      Result := Result + ' AND  M.CONTACTKEY IN ' + St + ')';
    end
    else
      if (High(SubDepartmentKeys) <> Low(SubDepartmentKeys)) then
      begin
        if (High(SubDepartmentKeys) > Low(SubDepartmentKeys)) then
          raise EgdcInvMovement.Create('Необходимо указать меcто, откуда отпуcкаетcя ТМЦ')
        else
          if (High(DepartmentKeys) = Low(DepartmentKeys))
          then
            Result := Result + ' AND M.CONTACTKEY = :DepartmentKey ';
      end;

    Result := Result + ' GROUP BY 1, 2 ';
  end;

  function MakeInvMovementPart: String;
  var
    i : Integer;
  begin
    Result := ' SELECT M.CARDKEY, M.CONTACTKEY, '#13#10 +
      '   SUM(M.CREDIT - M.DEBIT) AS BALANCE '#13#10 +
      ' FROM '#13#10 +
      '   INV_MOVEMENT M ';
    if HasSubSet(cst_ByGoodKey) then
    begin
      if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
        (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
      then
        Result := Result + #13#10 +
          ' JOIN INV_CARD C ON C.ID = M.CARDKEY ';
    end;

    if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
       (High(DepartmentKeys) >= Low(DepartmentKeys))
    then
    begin
      if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB and CON.contacttype = 2'
          else
            Result := Result + ' JOIN (SELECT CON.ID FROM GD_CONTACT CON ' +
              ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON CON1.id = h.companykey AND h.holdingkey = :holdingkey ) H ON H.ID = M.CONTACTKEY ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end
      else
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB '
          else
            Result := Result + ' JOIN (SELECT CON.ID FROM GD_CONTACT CON ' +
              ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON CON1.id = h.companykey AND h.holdingkey = :holdingkey ) H ON H.ID = M.CONTACTKEY ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end;
    end;

    if (not ARefresh) and (not HasSubSet(cst_ByGoodKey))  then
    begin
      Result := Result + ' JOIN GD_GOOD G ON ( G.ID  =  M.GOODKEY ) ';
      if not CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) then
      begin
        Result := Result + ' JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID) ';
        if not HasSubSet('All') then
          Result := Result + 'AND ( GG.LB >= :LB AND GG.RB <= :RB )';
      end
      else
        Result := Result + ' LEFT JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID)';
    end;

    Result := Result + #13#10 + ' WHERE M.DISABLED = 0 '#13#10 +
      ' AND M.MOVEMENTDATE > :REMAINSDATE ';

    if HasSubSet(cst_ByGoodKey) then
    begin
      if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or
        (CurrentRemains and (atDatabase.FindRelationField('INV_BALANCE', 'GOODKEY') = nil))
      then
        Result := Result + ' AND C.GOODKEY = :GOODKEY '
      else
        Result := Result + ' AND M.GOODKEY = :GOODKEY '
    end;

    if not HasSubSet(cst_ByGoodKey) then
      if CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) and not HasSubSet('All') then
        Result := Result +  ' AND ( GG.LB >= :LB AND GG.RB <= :RB )';

    if (High(DepartmentKeys) > Low(DepartmentKeys))
    then
    begin
      St := '(';
      for i:= Low(DepartmentKeys) to High(DepartmentKeys) do
      begin
        St := St + IntToStr(DepartmentKeys[i]);
        if i < High(DepartmentKeys) then
          St := St + ',';
      end;
      Result := Result + ' AND  M.CONTACTKEY IN ' + St + ')';
    end
    else
      if (High(SubDepartmentKeys) <> Low(SubDepartmentKeys)) then
      begin
        if (High(SubDepartmentKeys) > Low(SubDepartmentKeys)) then
          raise EgdcInvMovement.Create('Необходимо указать меcто, откуда отпуcкаетcя ТМЦ')
        else
          if (High(DepartmentKeys) = Low(DepartmentKeys))
          then
            Result := Result + ' AND M.CONTACTKEY = :DepartmentKey ';
      end;

    Result := Result + ' GROUP BY 1, 2 ';
  end;

begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVREMAINS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if UseSelectFromSelect then
  begin
    Result := inherited GetFromClause(ARefresh);

    Result := ' FROM ('#13#10 +
      MakeInvBalancePart + #13#10;
    if not CurrentRemains then
      Result := Result + ' UNION ALL '#13#10 +
        MakeInvMovementPart + #13#10;

    Result := Result + ' ) M '#13#10 +
       ' LEFT JOIN INV_CARD C ON C.ID = M.CARDKEY '#13#10 +
       ' LEFT JOIN GD_GOOD G ON (G.ID = C.GOODKEY) ';
    if not IBLogin.IsUserAdmin then
      Result := Result + Format(' AND g_sec_test(g.aview, %d) <> 0 ', [IBLogin.InGroup]);

    if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
       (High(DepartmentKeys) >= Low(DepartmentKeys))
    then
    begin
      if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB and CON.contacttype = 2';
          {else
            Result := Result + ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON CON1.id = h.companykey AND h.holdingkey = :holdingkey '; }

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end
      else
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB '
          else
            {Result := Result + ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON CON1.id = h.companykey AND h.holdingkey = :holdingkey ';}

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end;
    end;

    if (not ARefresh) and (not HasSubSet(cst_ByGoodKey))  then
    begin
      if not CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) then
      begin
        Result := Result + ' JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID) ';
        if not HasSubSet('All') then
          Result := Result + 'AND ( GG.LB >= :LB AND GG.RB <= :RB )';
      end
      else
        Result := Result + ' LEFT JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID)';

    end;
    Result := Result  + ' LEFT JOIN gd_value v ON g.valuekey = v.id ';

    if csDesigning in ComponentState then
      exit;

    if Assigned(FViewFeatures) then
      for i:= 0 to FViewFeatures.Count - 1 do
      begin
        F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
        if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
          Assigned(F.Field.RefTable.PrimaryKey)
        then
        begin
          Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' C_' + FViewFeatures[i] +
            ' ON C.' + FViewFeatures[i] + ' = ' + ' C_' + FViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
          FSQLSetup.Ignores.AddAliasName('C_' + FViewFeatures[i]);
        end;
      end;

    if Assigned(FGoodViewFeatures) then
      for i:= 0 to FGoodViewFeatures.Count - 1 do
      begin
        F := atDatabase.Relations.ByRelationName('GD_GOOD').RelationFields.ByFieldName(UpperCase(FGoodViewFeatures[i]));
        if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
          Assigned(F.Field.RefTable.PrimaryKey)
        then
        begin
          Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' G_' + FGoodViewFeatures[i] +
            ' ON G.' + FGoodViewFeatures[i] + ' = ' + ' G_' + FGoodViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
          Ignore := FSQLSetup.Ignores.Add;
          Ignore.AliasName := 'G_' + FGoodViewFeatures[i];
        end;
      end;

    FSQLSetup.Ignores.AddAliasName('C');
    if not HasSubSet(cst_ByGoodKey) then
    begin
      Ignore := FSQLSetup.Ignores.Add;
      Ignore.AliasName := 'GG';

      Ignore := FSQLSetup.Ignores.Add;
      Ignore.AliasName := 'G';
    end;
    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'CON';

  end
  else
  begin
    Result := inherited GetFromClause(ARefresh);

    if not CurrentRemains then
    begin
      if not FIsNewDateRemains then
        Result := Result +  ' AND M.DISABLED = 0 ';
    end
    else
      if FIsMinusRemains then
        Result := Result +  ' AND M.BALANCE < 0 '
      else
        if not HasSubSet(cst_AllRemains) then
          Result := Result +  ' AND M.BALANCE > 0 ';

    if not CurrentRemains and not FIsNewDateRemains then
      Result := Result +  ' AND M.MOVEMENTDATE <= :REMAINSDATE ';

    if (High(DepartmentKeys) > Low(DepartmentKeys))
    then
    begin
      St := '(';
      for i:= Low(DepartmentKeys) to High(DepartmentKeys) do
      begin
        St := St + IntToStr(DepartmentKeys[i]);
        if i < High(DepartmentKeys) then
          St := St + ',';
      end;
      Result := Result + ' AND  M.CONTACTKEY IN ' + St + ')';
    end
    else
      if (High(SubDepartmentKeys) <> Low(SubDepartmentKeys)) then
      begin
        if (High(SubDepartmentKeys) > Low(SubDepartmentKeys)) then
          raise EgdcInvMovement.Create('Необходимо указать меcто, откуда отпуcкаетcя ТМЦ')
        else
          if (High(DepartmentKeys) = Low(DepartmentKeys))
          then
            Result := Result + ' AND M.CONTACTKEY = :DepartmentKey ';
      end;

    if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
       (High(DepartmentKeys) >= Low(DepartmentKeys))
    then
    begin
      if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB and CON.contacttype = 2'
          else
            Result := Result + ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON CON1.id = h.companykey AND h.holdingkey = :holdingkey ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end
      else
      begin
        Result := Result + ' JOIN GD_CONTACT CON ON  M.CONTACTKEY = CON.ID ';
        if High(DepartmentKeys) < Low(DepartmentKeys) then
        begin
          if not HasSubSet(cst_Holding) then
            Result := Result + ' AND CON.LB >= :SubLB  AND CON.RB <= :SubRB '
          else
            Result := Result + ' JOIN gd_contact con1 ON con.LB >= con1.LB and con.RB <= con1.RB ' +
              ' JOIN gd_holding h ON CON1.id = h.companykey AND h.holdingkey = :holdingkey ';

          if not IBLogin.IsUserAdmin then
            Result := Result + Format(' AND g_sec_test(con.aview, %d) <> 0 ', [IBLogin.InGroup]);
        end;
      end;
    end;

    if (not ARefresh) and (not HasSubSet(cst_ByGoodKey))  then
    begin
      if not CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) then
      begin
        Result := Result + ' JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID) ';
        if not HasSubSet('All') then
          Result := Result + 'AND ( GG.LB >= :LB AND GG.RB <= :RB )';
      end
      else
        Result := Result + ' LEFT JOIN GD_GOODGROUP GG ON (G.GROUPKEY = GG.ID)';

    end;
    Result := Result  + ' LEFT JOIN gd_value v ON g.valuekey = v.id ';

    if not CurrentRemains and FIsNewDateRemains then
      Result := Result + ' LEFT JOIN INV_GETCARDMOVEMENT(M.CARDKEY, M.CONTACTKEY, :REMAINSDATE) REST ON 1= 1';

    if csDesigning in ComponentState then
      exit;

    if Assigned(FViewFeatures) then
      for i:= 0 to FViewFeatures.Count - 1 do
      begin
        F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
        if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
          Assigned(F.Field.RefTable.PrimaryKey)
        then
        begin
          Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' C_' + FViewFeatures[i] +
            ' ON C.' + FViewFeatures[i] + ' = ' + ' C_' + FViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
          FSQLSetup.Ignores.AddAliasName('C_' + FViewFeatures[i]);
        end;
      end;

    if Assigned(FGoodViewFeatures) then
      for i:= 0 to FGoodViewFeatures.Count - 1 do
      begin
        F := atDatabase.Relations.ByRelationName('GD_GOOD').RelationFields.ByFieldName(UpperCase(FGoodViewFeatures[i]));
        if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
          Assigned(F.Field.RefTable.PrimaryKey)
        then
        begin
          Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' G_' + FGoodViewFeatures[i] +
            ' ON G.' + FGoodViewFeatures[i] + ' = ' + ' G_' + FGoodViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
          Ignore := FSQLSetup.Ignores.Add;
          Ignore.AliasName := 'G_' + FGoodViewFeatures[i];
        end;
      end;

    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'C';

    if not HasSubSet(cst_ByGoodKey) then
    begin
      Ignore := FSQLSetup.Ignores.Add;
      Ignore.AliasName := 'GG';

      Ignore := FSQLSetup.Ignores.Add;
      Ignore.AliasName := 'G';
    end;

    Ignore := FSQLSetup.Ignores.Add;
    Ignore.AliasName := 'CON';

  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvRemains.GetSelectClause: String;
VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if Assigned(FgdcDocumentLine) then
    Result := inherited GetSelectClause + ', 0.0 as CHOOSEQUANTITY, 0.0 as CHOOSEQUANTPACK, GEN_ID(inv_g_balancenum, 1) as ChooseID '
  else
    Result := inherited GetSelectClause;

  if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
     (High(DepartmentKeys) >= Low(DepartmentKeys))
  then
  begin
    if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      Result := Result + ', CON.NAME, CON.ID as ContactKey '
    else
      Result := Result + ', CON.NAME, CON.ID as ContactKey ';
  end;

  if Assigned(FViewFeatures) then
    for i:= 0 to FViewFeatures.Count - 1 do
    begin
      Result := Result + ', C.' + FViewFeatures[i];
      F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
        Assigned(F.Field.RefTable.PrimaryKey)
      then
      begin

        if Assigned(F.Field.RefListField) and Assigned(F.Field.RefListField.Field) and (F.Field.RefListField.Field.FieldType = ftMemo) then
 //         Result := Result + ', ' + Format(' SUBSTRING(%0:s FROM 1 FOR LENGTH(%0:s)) ', ['C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName]) + ' as c_' +
//            FViewFeatures[i] + '_' + F.Field.RefListFieldName
        else
          Result := Result + ', C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName + ' as c_' +
            FViewFeatures[i] + '_' + F.Field.RefListFieldName;
        end
    end;

  if Assigned(FGoodViewFeatures) then
    for i:= 0 to FGoodViewFeatures.Count - 1 do
    begin
      Result := Result + ', G.' + FGoodViewFeatures[i];
      F := atDatabase.Relations.ByRelationName('GD_GOOD').RelationFields.ByFieldName(UpperCase(FGoodViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
        Assigned(F.Field.RefTable.PrimaryKey)
      then
        Result := Result + ', G_' + FGoodViewFeatures[i] + '.' + F.Field.RefListFieldName + ' as g_' +
          FGoodViewFeatures[i] + '_' + F.Field.RefListFieldName;
    end;

  if Assigned(FSumFeatures) then
    for i := 0 to FSumFeatures.Count - 1 do
      if not (CurrentRemains or UseSelectFromSelect) then
      begin
        if not FIsNewDateRemains then
          Result := Result + ', SUM((m.debit - m.credit) * C.' + FSumFeatures[i] + ') as ' +
            'S_' + FSumFeatures[i]
        else
          Result := Result + ', SUM((m.balance - rest.remains) * C.' + FSumFeatures[i] + ') as ' +
            'S_' + FSumFeatures[i];
      end
      else
        Result := Result + ', SUM(m.balance * C.' + FSumFeatures[i] + ') as ' +
          'S_' + FSumFeatures[i];

  if Assigned(FGoodSumFeatures) then
    for i:= 0 to FGoodSumFeatures.Count - 1 do
      if not (CurrentRemains or UseSelectFromSelect) then
      begin
        if not FIsNewDateRemains then
          Result := Result + ', SUM((m.debit - m.credit) * G.' + FGoodSumFeatures[i] + ') as ' +
            'SG_' + FGoodSumFeatures[i]
        else
          Result := Result + ', SUM((m.balance - rest.remains) * G.' + FGoodSumFeatures[i] + ') as ' +
            'SG_' + FGoodSumFeatures[i]
      end
      else
        Result := Result + ', SUM(m.balance * G.' + FGoodSumFeatures[i] + ') as ' +
          'SG_' + FGoodSumFeatures[i];

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemains.GetWhereClauseConditions(S: TStrings);
var
  i: Integer;
begin
  if csDesigning in ComponentState then
    exit;

  if not HasSubSet(cst_ByGoodKey) then
  begin
    inherited;
    if CompanyStorage.ReadBoolean('Inventory', 'ISLEFTJOIN', True) and not HasSubSet('All') then
      S.Add('( GG.LB >= :LB AND GG.RB <= :RB )');
  end
  else
  begin
    if isUseCompanyKey then
      S.Add('CAST(C.COMPANYKEY + 0 as INTEGER) = :companykey');
  end;

  if High(FChooseFeatures) >= Low(FChooseFeatures) then
    for i:= Low(FChooseFeatures) to High(FChooseFeatures) do
      if FChooseFeatures[i].optValue <> NULL then
        if FChooseFeatures[i].isInteger then
          S.Add('  (C.' + FChooseFeatures[i].optFieldName + ' + 0) = :' +
                    FChooseFeatures[i].optFieldName)
        else
          S.Add('  C.' + FChooseFeatures[i].optFieldName + ' = :' +
                    FChooseFeatures[i].optFieldName);

end;

procedure TgdcInvRemains.AddPosition;
var
  i, j: Integer;
  isError: Boolean;
  F: TField;
 {$IFDEF DEBUGMOVE}
 TimeTmp: LongWord;
 AllTime: LongWord;
 ChangeField: LongWord;
 TimePost: LongWord;
 {$ENDIF}
begin
{$IFDEF DEBUGMOVE}
  TimePost := 0;
  TimeCustomInsertUSR := 0;
  TimeGetRemains := 0;
  TimeMakeMovement := 0;
  TimeMakeInsert := 0;
  TimeQueryList := 0;
  TimeCustomInsertDoc := 0;
  TimeDoOnNewRecord := 0;
  TimeDoOnNewRecordClasses := 0;
  AllTime := GetTickCount;
  TimeFillPosition := 0;
{$ENDIF}
  if not Assigned(gdcDocumentLine) then exit;
  (gdcDocumentLine as TgdcInvDocumentLine).isSetFeaturesFromRemains := True;
  try
    SetLength(PositionList, High(PositionList) - Low(PositionList) + 2);
    with PositionList[High(PositionList) - Low(PositionList)] do
    begin
      cvalFirstDocumentKey := -1;
      cvalDocumentKey := -1;
      cvalFirstDate := -1;

      cvalGoodKey := FieldByName('goodkey').AsInteger;
      cvalCardKey := FieldByName('id').AsInteger;
      cvalQuantity := FieldByName('choosequantity').AsCurrency;
      cvalQuantPack := FieldByName('choosequantpack').AsCurrency;
      SetLength(cvalInvCardFeatures, ViewFeatures.Count);
      for i:= 0 to ViewFeatures.Count - 1 do
      begin
        cvalInvCardFeatures[i].optFieldName := ViewFeatures[i];
        if not FieldByName(ViewFeatures[i]).IsNull then
          cvalInvCardFeatures[i].optValue := FieldByName(ViewFeatures[i]).Value
        else
          cvalInvCardFeatures[i].optValue := NULL;
        cvalInvCardFeatures[i].isInteger := (FieldByName(ViewFeatures[i]).DataType in [ftSmallint, ftBCD, ftInteger, ftLargeInt]);
      end;
      if FindField('ContactKey') <> nil then
        cvalContactKey := FieldByName('ContactKey').AsInteger
      else
        cvalContactKey := -1;

      if (cvalQuantity <> 0) or (1=1) then
      begin
        {$IFDEF DEBUGMOVE}
        TimeTmp := GetTickCount;
        {$ENDIF}
        if not (gdcDocumentLine.State in [dsEdit, dsInsert]) then
          gdcDocumentLine.Append;
        {$IFDEF DEBUGMOVE}
        TimeMakeInsert := GetTickCount - TimeTmp;
        ChangeField := GetTickCount;
        {$ENDIF}

        cvalDocumentKey := gdcDocumentLine.FieldByName('documentkey').AsInteger;

        gdcDocumentLine.FieldByName('goodkey').AsInteger := cvalGoodKey;
        if not FisDest then
          gdcDocumentLine.FieldByName('fromcardkey').AsInteger := cvalCardKey;

        if gdcDocumentLine.FindField('remains') <> nil then
        begin
          gdcDocumentLine.FieldByName('remains').ReadOnly := False;
          try
            gdcDocumentLine.FieldByName('remains').AsCurrency :=
              FieldByName('remains').AsCurrency;
          finally
            gdcDocumentLine.FieldByName('remains').ReadOnly := True;
          end;
        end
        else
          if gdcDocumentLine.FindField('fromquantity') <> nil then
          begin
            gdcDocumentLine.FieldByName('fromquantity').ReadOnly := False;
            try
              gdcDocumentLine.FieldByName('fromquantity').AsCurrency :=
                FieldByName('remains').AsCurrency;
            finally
              gdcDocumentLine.FieldByName('fromquantity').ReadOnly := True;
            end;
          end;

        for j:= Low(cvalInvCardFeatures) to High(cvalInvCardFeatures) do
        begin
          F := gdcDocumentLine.FindField(INV_SOURCEFEATURE_PREFIX +
               cvalInvCardFeatures[j].optFieldName);
          if (F <> nil) and (F.AsVariant <> cvalInvCardFeatures[j].optValue)
          then
            F.AsVariant :=
              cvalInvCardFeatures[j].optValue;

          F := gdcDocumentLine.FindField(INV_DESTFEATURE_PREFIX +
               cvalInvCardFeatures[j].optFieldName);
          if (F <> nil) and (F.IsNull or (F.DefaultExpression > '')) and (F.AsVariant <> cvalInvCardFeatures[j].optValue)
          then
            F.AsVariant :=
              cvalInvCardFeatures[j].optValue;

        end;

        gdcDocumentLine.FieldByName('quantity').AsCurrency := cvalQuantity;

        if (gdcDocumentLine.FindField('ToQuantity') <> nil)
        then
          gdcDocumentLine.FieldByName('ToQuantity').AsCurrency := cvalQuantity;

        if (gdcDocumentLine.FindField('OutQuantity') <> nil)
        then
        begin
          gdcDocumentLine.FieldByName('OutQuantity').AsCurrency := cvalQuantity;
          gdcDocumentLine.FieldByName('quantity').AsCurrency := -cvalQuantity;
        end;

        if (gdcDocumentLine.FindField('InQuantity') <> nil)
        then
          gdcDocumentLine.FieldByName('InQuantity').AsCurrency := cvalQuantity;

        if gdcDocumentLine.FindField('goodkey1') <> nil then
          gdcDocumentLine.FieldByName('goodkey1').AsInteger := cvalGoodKey;


        if (AnsiCompareText((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.RelationName,
           (gdcDocumentLine as TgdcInvDocumentLine).RelationName) <> 0) and
           ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.SourceFieldName > '') and
           (cvalContactKey > 0)
        then
          gdcDocumentLine.FieldByName(
            (gdcDocumentLine as TgdcInvDocumentLine).MovementSource.SourceFieldName).AsInteger :=
            cvalContactKey;
        {$IFDEF DEBUGMOVE}
        ChangeField := GetTickCount - ChangeField;
        {$ENDIF}

        isError := False;
        (gdcDocumentLine as TgdcInvDocumentLine).Movement.FIsGetRemains := False;
        try
        {$IFDEF DEBUGMOVE}
          TimePost := GetTickCount;
        {$ENDIF}
          gdcDocumentLine.Post;
        {$IFDEF DEBUGMOVE}
          TimePost := GetTickCount - TimePost;
        {$ENDIF}
        except
          on E: Exception do
          begin
            isError := True;
            MessageBox(ParentHandle, PChar(E.Message), PChar(sAttention), mb_OK);
            gdcDocumentLine.Cancel;
          end;
        end;
        (gdcDocumentLine as TgdcInvDocumentLine).Movement.FIsGetRemains := True;
        if not isError then
        begin
          Edit;
          FieldByName('remains').AsCurrency := FieldByName('remains').AsCurrency -
            FieldByName('choosequantity').AsCurrency;
          FieldByName('choosequantity').AsCurrency := 0;
          Post;
        end;
      end;
    end;
  finally
   (gdcDocumentLine as TgdcInvDocumentLine).isSetFeaturesFromRemains := False;  
  end;


  {$IFDEF DEBUGMOVE}
  AllTime := GetTickCount - AllTime;
  ShowMessage(Format('Вcтавка %d, GetRemains %d, MakeMovement %d, CustomInsertDoc %d, CustomInsertUSR %d, Вcе %d, Поля %d, MakeQuery %d, _DoOnNewRecord %d, _DoOnNew_Classes %d, FillPos %d, AllPost %d',
    [TimeMakeInsert, TimeGetRemains, TimeMakeMovement, TimeCustomInsertDoc, TimeCustomInsertUSR, AllTime, ChangeField, TimeQueryList, TimeDoOnNewRecord, TimeDoOnNewRecordClasses, TimeFillPosition, TimePost]));
  {$ENDIF}
end;

procedure TgdcInvRemains.ClearPositionList;
begin
  SetLength(PositionList, 0)
end;

procedure TgdcInvRemains.DoAfterPost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINS', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYDOAFTERPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'DOAFTERPOST', KEYDOAFTERPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if FieldByName('ChooseQuantity').AsCurrency <> 0 then
    AddPosition;
{  else
    DelPosition;}
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'DOAFTERPOST', KEYDOAFTERPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'DOAFTERPOST', KEYDOAFTERPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemains.DoBeforePost;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINS', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if not (sMultiple in BaseState) then
  begin
    if FCheckRemains and (FieldByName('CHOOSEQUANTITY').AsCurrency <> 0) and
       (FieldByName('CHOOSEQUANTITY').AsCurrency > FieldByName('REMAINS').AsCurrency) and
       ((gdcDocumentLine as TgdcInvDocumentLine).RelationType <> irtInventorization) and not FIsDest
    then
    begin
      MessageBox(ParentHandle, PChar(s_InvErrorChooseRemains), PChar(sAttention),
        mb_OK or mb_IconInformation);
      abort;
    end;
  end;

  inherited;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemains.DoBeforeOpen;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  ibsql: TIBSQL;
  Day, Month, Year: Word;
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINS', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYDOBEFOREOPEN);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREOPEN]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'DOBEFOREOPEN', KEYDOBEFOREOPEN, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if GoodKey <> -1 then
    ParamByName('goodkey').AsInteger := GoodKey;

  if isUseCompanyKey then
  begin
    if Assigned(gdcDocumentLine) and Assigned(gdcDocumentLine.MasterSource) and Assigned(gdcDocumentLine.MasterSource.DataSet) then
    begin
      ParamByName('companykey').AsInteger := gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey').AsInteger
    end
    else
      if ParamByName('companykey').AsInteger <= 0 then
        ParamByName('companykey').AsInteger := IBLogin.CompanyKey;
  end;
  
  if (Length(DepartmentKeys) = 1) then
    try
      ParamByName('DepartmentKey').AsInteger := DepartmentKeys[Low(DepartmentKeys)]
    except
      // в запросе может не быть параметра с именем DepartmentKey
      on E: EIBClientError do ;
    end
  else
    if (Length(SubDepartmentKeys) = 1) then
    begin
      if not HasSubSet(cst_Holding) then
      begin
        ibsql := TIBSQL.Create(Self);
        try
          ibsql.Transaction := ReadTransaction;
          ibsql.SQL.Text := 'SELECT LB, RB, contacttype FROM gd_contact WHERE id = :ID';
          ibsql.ParamByName('id').AsInteger := SubDepartmentKeys[Low(SubDepartmentKeys)];
          ibsql.ExecQuery;
          if ibsql.RecordCount > 0 then
          begin
            try
              ParamByName('SubLB').AsInteger := ibsql.FieldByName('LB').AsInteger;
              ParamByName('SubRB').AsInteger := ibsql.FieldByName('RB').AsInteger;
            except
            end;
          end;
        finally
          ibsql.Free;
        end;
      end
      else
        ParamByName('holdingkey').AsInteger := SubDepartmentKeys[Low(SubDepartmentKeys)];
    end;

  for i:= Low(FChooseFeatures) to High(FChooseFeatures) do
    if FChooseFeatures[i].optValue <> NULL then
      try
        ParamByName(FChooseFeatures[i].optFieldName).AsVariant := FChooseFeatures[i].optValue;
      except
        // TODO: Пустое исключение
      end;

  if not CurrentRemains and (RemainsDate <> 0) then
    try
      if EndMonthRemains then
      begin
        DecodeDate(IncMonth(RemainsDate, 1), Year, Month, Day);
        ParamByName('remainsdate').AsDateTime := EncodeDate(Year, Month, 1) - 1;
      end  
      else
        ParamByName('remainsdate').AsDateTime := RemainsDate;
    except
      // TODO: Пустое исключение
    end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'DOBEFOREOPEN', KEYDOBEFOREOPEN)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'DOBEFOREOPEN', KEYDOBEFOREOPEN);
  {M}  end;
  {END MACRO}
end;

function TgdcInvRemains.GetCountPosition: Integer;
begin
  if csDesigning in ComponentState then
    Result := 0
  else
    Result := High(PositionList) - Low(PositionList) + 1;
end;


procedure TgdcInvRemains.SetDepartmentKeys(const Value: array of Integer);
var
  i: Integer;
begin
  SetLength(FDepartmentKeys, High(Value) - Low(Value) + 1);
  for i:= Low(Value) to High(Value) do
    FDepartmentKeys[i] := Value[i];
end;

procedure TgdcInvRemains.SetSubDepartmentKeys(const Value: array of Integer);
var
  i: Integer;
begin
  SetLength(FSubDepartmentKeys, High(Value) - Low(Value) + 1);
  for i:= Low(Value) to High(Value) do
    FSubDepartmentKeys[i] := Value[i];
end;

procedure TgdcInvRemains.SetOptions_New;
var
  i: Integer;
  MovementContactType: TgdcInvMovementContactType;
  ipDestContactKey: Integer;
  MasterDataSet: TDataSet;
begin
  Assert(Assigned(gdcDocumentLine), 'Не задан объект позиции документа');

  Close;

  if gdcDocumentLine.Transaction.InTransaction then
    ReadTransaction := gdcDocumentLine.Transaction;

  if Assigned(gdcDocumentLine.MasterSource) and
    Assigned(gdcDocumentLine.MasterSource.DataSet) then
    MasterDataSet := gdcDocumentLine.MasterSource.DataSet as TgdcInvDocument
  else
    raise Exception.Create('Не задан объект документа');

  with (gdcDocumentLine as TgdcInvDocumentLine) do
  begin
    CurrentRemains := True;//LiveTimeRemains;
    FEndMonthRemains := EndMonthRemains;
    FIsMinusRemains := isMinusRemains;
    FIsUseCompanyKey := isUseCompanyKey;

    if not FisMinusRemains then
    begin

      if
        (AnsiCompareText(MovementSource.RelationName, RelationName) = 0) and
        (MovementSource.SourceFieldName > '')
      then
      begin
        SetDepartmentKeys([MasterDataSet.FieldByName(MovementSource.SourceFieldName).AsInteger]);
        IncludeSubDepartment := False;
      end
      else
      begin

        if AnsiCompareText(MovementSource.RelationName, RelationName) = 0
        then
          raise EgdcInvMovement.Create('Необходимо указать, откуда идет выбор оcтатков');

        if
          (AnsiCompareText(MovementSource.SubRelationName, RelationName) = 0) and
          (MovementSource.SubSourceFieldName > '')
        then
        begin
          if MasterDataSet.FieldByName(MovementSource.SubSourceFieldName).AsInteger > 0 then
            SetSubDepartmentKeys([MasterDataSet.FieldByName(MovementSource.SubSourceFieldName).AsInteger])
          else
            SetSubDepartmentKeys([MasterDataSet.FieldByName('companykey').AsInteger]);
        end
        else

        if (MovementSource.SubSourceFieldName > '') then
          SetSubDepartmentKeys([FieldByName(MovementSource.SubSourceFieldName).AsInteger])
        else
          if High(MovementSource.Predefined) >= Low(MovementSource.Predefined) then
          begin
            SetDepartmentKeys(MovementSource.Predefined);
            IncludeSubDepartment := False;
          end
          else
            if High(MovementSource.SubPredefined) >= Low(MovementSource.SubPredefined) then
            begin
              SetSubDepartmentKeys(MovementSource.SubPredefined);
              IncludeSubDepartment := True;
            end;
      end;
    end
    else
    begin
      if (AnsiCompareText(MovementTarget.RelationName, RelationName) = 0) and
         (MovementTarget.SourceFieldName > '')
      then
        ipDestContactKey := MasterDataSet.
          FieldByName(MovementTarget.SourceFieldName).AsInteger
      else
        ipDestContactKey := -1;

      if (ipDestContactKey > 0) then
      begin
        SetDepartmentKeys([ipDestContactKey]);
        IncludeSubDepartment := False;
      end
      else
      begin

        if AnsiCompareText(MovementTarget.RelationName, RelationName) = 0
        then
          raise EgdcInvMovement.Create('Необходимо указать, откуда идет выбор оcтатков');

        if (AnsiCompareText(MovementTarget.SubRelationName, RelationName) = 0) and
           (MovementTarget.SubSourceFieldName > '')
        then
        begin
          SetSubDepartmentKeys([MasterDataSet.
            FieldByName(MovementTarget.SubSourceFieldName).AsInteger]);
          IncludeSubDepartment := True;
        end
        else

        if (MovementTarget.SubSourceFieldName > '') then
        begin
          SetSubDepartmentKeys([FieldByName(MovementTarget.SubSourceFieldName).AsInteger]);
          IncludeSubDepartment := True;
        end
        else
          if High(MovementTarget.Predefined) >= Low(MovementTarget.Predefined) then
          begin
            SetDepartmentKeys(MovementTarget.Predefined);
            IncludeSubDepartment := False;
          end
          else
            if High(MovementTarget.SubPredefined) >= Low(MovementTarget.SubPredefined) then
            begin
              SetSubDepartmentKeys(MovementTarget.SubPredefined);
              IncludeSubDepartment := True;
            end;
      end;

    end;

    ContactType := 0;

    if not FIsMinusRemains then
      MovementContactType := MovementSource.ContactType
    else
      MovementContactType := MovementTarget.ContactType;

    case MovementContactType of
    imctOurCompany:
      ContactType := 3;
    imctOurDepartment, imctOurPeople:
      begin
        if (High(SubDepartmentKeys) < Low(SubDepartmentKeys)) and
           (High(DepartmentKeys) < Low(DepartmentKeys))
        then
        begin
          SetSubDepartmentKeys([gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey').AsInteger]);
          IncludeSubDepartment := True;
        end;
        if MovementSource.ContactType = imctOurPeople
        then
          ContactType := 2
        else
          ContactType := 4;
      end;
    imctCompany:
      ContactType := 3;
    imctCompanyDepartment:
      ContactType := 4;
    imctCompanyPeople, imctPeople:
      ContactType := 2;
    end;

    RemainsDate := MasterDataSet.FieldByName('documentdate').AsDateTime;

    if not FIsMinusRemains then
    begin
      if (RelationType <> irtTransformation) or (ViewMovementPart = impExpense) or
         ((FindField('OUTQUANTITY') <> nil) and (FieldByName('OUTQUANTITY').AsCurrency > 0))
      then
        ViewFeatures.Clear;
        for i:= Low(SourceFeatures) to High(SourceFeatures) do
          ViewFeatures.Add(SourceFeatures[i]);
    end
    else
    begin
      ViewFeatures.Clear;
      for i:= Low(MinusFeatures) to High(MinusFeatures) do
        ViewFeatures.Add(MinusFeatures[i]);
    end;

  end;
  SubType := gdcDocumentLine.SubType;
  SubSet := cst_ByGroupKey;

end;

procedure TgdcInvRemains.SetOptions(var InvPosition: TgdcInvPosition;
  InvMovement: TgdcInvMovement; const isPosition: Boolean; const isDest: Boolean = False);
var
  i: Integer;
  MovementContactType: TgdcInvMovementContactType;
begin
  Assert(Assigned(InvMovement) and Assigned(InvMovement.gdcDocumentLine),
    'Не задан объект движения или позиции документа');

  FisDest := IsDest;  

  Close;

  if InvMovement.Transaction.InTransaction then
    ReadTransaction := InvMovement.Transaction;

  FgdcDocumentLine := InvMovement.gdcDocumentLine;

  FEndMonthRemains := InvMovement.EndMonthRemains;

  with InvPosition do
  begin
    CurrentRemains := True;//InvMovement.CurrentRemains;

    CheckRemains := (tcrSource in ipCheckRemains);

    FIsMinusRemains := ipMinusRemains;

 //   FEndMonthRemains := False;

    FIsUseCompanyKey := (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).IsUseCompanyKey;

    if not FisMinusRemains then
    begin
      if (ipSourceContactKey > 0) and
         (AnsiCompareText((InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementSource.RelationName,
           (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).RelationName) = 0)
      then
      begin
        SetDepartmentKeys([ipSourceContactKey]);
        IncludeSubDepartment := False;
      end
      else
      begin

        if AnsiCompareText((InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementSource.RelationName,
           (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).RelationName) = 0
        then
          raise EgdcInvMovement.Create('Необходимо указать, откуда идет выбор оcтатков');

        if ipSubSourceContactKey > 0 then
        begin
          SetSubDepartmentKeys([ipSubSourceContactKey]);
          IncludeSubDepartment := True;
        end
        else
          if High(ipPredefinedSourceContact) >= Low(ipPredefinedSourceContact) then
          begin
            SetDepartmentKeys(ipPredefinedSourceContact);
            IncludeSubDepartment := False;
          end
          else
            if High(ipSubPredefinedSourceContact) >= Low(ipSubPredefinedSourceContact) then
            begin
              SetSubDepartmentKeys(ipSubPredefinedSourceContact);
              IncludeSubDepartment := True;
            end;
      end;
    end
    else
    begin
      if (ipDestContactKey > 0) and
         (AnsiCompareText((InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementTarget.RelationName,
           (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).RelationName) = 0)
      then
      begin
        SetDepartmentKeys([ipDestContactKey]);
        IncludeSubDepartment := False;
      end
      else
      begin

        if AnsiCompareText((InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementTarget.RelationName,
           (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).RelationName) = 0
        then
          raise EgdcInvMovement.Create('Необходимо указать, откуда идет выбор оcтатков');

        if ipSubDestContactKey > 0 then
        begin
          SetSubDepartmentKeys([ipSubDestContactKey]);
          IncludeSubDepartment := True;
        end
        else
          if High(ipPredefinedDestContact) >= Low(ipPredefinedDestContact) then
          begin
            SetDepartmentKeys(ipPredefinedDestContact);
            IncludeSubDepartment := False;
          end
          else
            if High(ipSubPredefinedDestContact) >= Low(ipSubPredefinedDestContact) then
            begin
              SetSubDepartmentKeys(ipSubPredefinedDestContact);
              IncludeSubDepartment := True;
            end;
      end;

    end;

    ContactType := 0;

    if not FIsMinusRemains then
      MovementContactType := (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType
    else
      MovementContactType := (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementTarget.ContactType;

    case MovementContactType of
    imctOurCompany:
      ContactType := 3;
    imctOurDepartment, imctOurPeople:
      begin
        if (High(SubDepartmentKeys) < Low(SubDepartmentKeys)) and
           (High(DepartmentKeys) < Low(DepartmentKeys))
        then
        begin
          SetSubDepartmentKeys([gdcDocumentLine.MasterSource.DataSet.FieldByName('companykey').AsInteger]);
          IncludeSubDepartment := True;
        end;
        if (InvMovement.gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople
        then
          ContactType := 2
        else
          ContactType := 4;
      end;
    imctCompany:
      ContactType := 3;
    imctCompanyDepartment:
      ContactType := 4;
    imctCompanyPeople, imctPeople:
      ContactType := 2;
    end;

    RemainsDate := ipDocumentDate;
    if not FIsMinusRemains and not isDest then
      for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
        ViewFeatures.Add(ipInvSourceCardFeatures[i].optFieldName)
    else
      if FIsMinusRemains then
      begin
        for i:= Low(ipInvMinusCardFeatures) to High(ipInvMinusCardFeatures) do
          ViewFeatures.Add(ipInvMinusCardFeatures[i].optFieldName);
      end
      else
        for i:= Low(ipInvDestCardFeatures) to High(ipInvDestCardFeatures) do
          ViewFeatures.Add(ipInvDestCardFeatures[i].optFieldName);

    if isPosition then
    begin
      GoodKey := ipGoodKey;

      SetLength(FChooseFeatures, Length(ipInvSourceCardFeatures));
      for i:= Low(ipInvSourceCardFeatures) to High(ipInvSourceCardFeatures) do
      begin
        FChooseFeatures[i].optFieldName := ipInvSourceCardFeatures[i].optFieldName;
        FChooseFeatures[i].optValue := ipInvSourceCardFeatures[i].optValue;
        FChooseFeatures[i].isInteger := ipInvSourceCardFeatures[i].isInteger;
      end;

      SubSet := cst_ByGoodKey;
    end
    else
      SubSet := cst_ByGroupKey;

    if (gdcDocumentLine as TgdcInvDocumentLine).SaveRestWindowOption then
    begin
      if UserStorage.ReadBoolean('Options\Invent', 'AllRemains', False) then
        AddSubSet('AllRemains');
      CurrentRemains := UserStorage.ReadBoolean('Options\Invent', 'CurrentRemains', True);
    end;

    SubType := FgdcDocumentLine.SubType;  

  end;

end;


function TgdcInvRemains.GetGroupClause: String;
VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINS', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINS') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINS',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINS' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := inherited GetGroupClause;
  if (High(SubDepartmentKeys) = Low(SubDepartmentKeys)) or
     (High(DepartmentKeys) >= Low(DepartmentKeys))
  then
  begin
    if Assigned(gdcDocumentLine) and ((gdcDocumentLine as TgdcInvDocumentLine).MovementSource.ContactType = imctOurPeople) then
      Result := Result + ', CON.NAME, CON.ID '
    else
      Result := Result + ', CON.name, CON.id ';
  end;

  if Assigned(FViewFeatures) then
    for i:= 0 to FViewFeatures.Count - 1 do
    begin
      Result := Result + ', C.' + FViewFeatures[i];
      F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
        Assigned(F.Field.RefTable.PrimaryKey)
      then
      begin
        if Assigned(F.Field.RefListField) and Assigned(F.Field.RefListField.Field) and (F.Field.RefListField.Field.FieldType = ftMemo) then
//          Result := Result + ', ' +  Format(' SUBSTRING(%0:s FROM 1 FOR LENGTH(%0:s)) ', [ 'C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName])
        else
          Result := Result + ', C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName;
      end
    end;

  if Assigned(FGoodViewFeatures) then
    for i:= 0 to FGoodViewFeatures.Count - 1 do
    begin
      Result := Result + ', G.' + FGoodViewFeatures[i];
      F := atDatabase.Relations.ByRelationName('GD_GOOD').RelationFields.ByFieldName(UpperCase(FGoodViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) and Assigned(F.Field.RefTable) and
        Assigned(F.Field.RefTable.PrimaryKey)
      then
        Result := Result + ', G_' + FGoodViewFeatures[i] + '.' + F.Field.RefListFieldName;
    end;

  if not CurrentRemains then
  begin
    if UseSelectFromSelect then
    begin
      if not FisMinusRemains then
      begin
        if not HasSubSet(cst_AllRemains) then
          Result := Result + ' HAVING SUM(M.BALANCE) > 0 ';
      end
      else
        Result := Result + ' HAVING SUM(M.BALANCE) < 0 ';
    end
    else
    begin
      if not FIsMinusRemains then
      begin
        if not HasSubSet(cst_AllRemains) then
        begin
          if not FIsNewDateRemains then
            Result := Result + ' HAVING SUM(M.DEBIT - M.CREDIT) > 0 '
          else
            Result := Result + ' HAVING SUM ( M.BALANCE - REST.REMAINS )  >  0 '
        end
      end
      else
        if not FIsNewDateRemains then
          Result := Result + ' HAVING SUM(M.DEBIT - M.CREDIT) < 0 '
        else
          Result := Result + ' HAVING SUM ( M.BALANCE - REST.REMAINS )  <  0 '
    end;
  end
  else
    if not FisMinusRemains then
    begin
      if not HasSubSet(cst_AllRemains) then
        Result := Result + ' HAVING SUM(M.BALANCE) > 0 ';
    end
    else
      Result := Result + ' HAVING SUM(M.BALANCE) < 0 ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINS', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvRemains.GetRefreshSQLText: String;
begin
  Result := '';
end;

procedure TgdcInvRemains.RemovePosition;
var
  i: Integer;
begin
  if gdcDocumentLine.State in [dsEdit, dsInsert] then
    gdcDocumentLine.Cancel;

  if (gdcDocumentLine as TgdcInvDocumentLine).SavePoint = '' then
  begin
    for i:= 0 to CountPosition - 1 do
    begin
      if (PositionList[i].cvalDocumentKey > 0) and (PositionList[i].cvalCardKey > 0) then
        if gdcDocumentLine.Locate('documentkey', PositionList[i].cvalDocumentKey, []) and
           (gdcDocumentLine.FieldByName('documentkey').AsInteger = PositionList[i].cvalDocumentKey)
        then
          gdcDocumentLine.Delete;
    end;
    gdcDocumentLine.First;
  end;

end;

procedure TgdcInvRemains.SetgdcDocumentLine(const Value: TgdcDocument);
begin
  if Value <> FgdcDocumentLine then
  begin
    FgdcDocumentLine := Value;
    if Assigned(FgdcDocumentLine) then
      SetOptions_New;
  end;  
end;


{ TgdcInvGoodRemains }

procedure TgdcInvGoodRemains.SetOptions_New;
begin
  inherited;
  SubSet := cst_ByGoodKey;
end;

{ TgdcInvCard }

constructor TgdcInvCard.Create(AnOwner: TComponent);
begin
  inherited;
  FContactKey := -1;
  FViewFeatures := TStringList.Create;
  FieldPrefix := '';
  FRemainsFeatures := TStringList.Create;
  FIgnoryFeatures := TStringList.Create;
  FgdcInvRemains := nil;
  FgdcInvDocumentLine := nil;
end;

destructor TgdcInvCard.Destroy;
begin
  inherited;
  if Assigned(FViewFeatures) then
    FreeAndNil(FViewFeatures);
  if Assigned(FRemainsFeatures) then
    FreeAndNil(FRemainsFeatures);
  if Assigned(FIgnoryFeatures) then
    FreeAndNil(FIgnoryFeatures);
end;

function TgdcInvCard.GetFromClause(const ARefresh: Boolean = False): String;
var
  i: Integer;
  F: TatRelationField;
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}

begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCINVCARD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARD', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARD',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARD' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := ' FROM inv_card z JOIN inv_movement m ON z.id = m.cardkey ';
  F := atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY');

  if not GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) and Assigned(F)
     and (not HasSubSet('ByGoodDetail'))
  then
    Result := Result + ' AND m.goodkey  = :goodkey ';

  if HasSubSet('ByHolding') then
  begin
    Result := Result + ' LEFT JOIN gd_contact con_m ON m.contactkey = con_m.id ' +
      ' LEFT JOIN gd_contact hold ON con_m.LB >= hold.LB and con_m.RB <= hold.RB ';
    if IsHolding then
      Result := Result + ' LEFT JOIN gd_holding H ON hold.id = h.companykey ';
  end;


  Result := Result +
  ' LEFT JOIN inv_movement m1 ON m.movementkey = m1.movementkey AND m.id <> m1.id ' +
  ' LEFT JOIN gd_contact con ON  con.id = (case when M1.CONTACTKEY is not null then M1.CONTACTKEY else M.CONTACTKEY end) ' +
  ' LEFT JOIN gd_contact main_con ON main_con.id = m.contactkey ';


  Result := Result +
  ' LEFT JOIN inv_card c ON c.id = (case when M1.DEBIT > 0 then M1.cardkey else M.cardkey end) ' +
  ' LEFT JOIN gd_document doc ON m.documentkey = doc.id ' +
  ' LEFT JOIN gd_documenttype doct ON doc.documenttypekey = doct.id ' +
  ' LEFT JOIN gd_good g ON z.goodkey = g.id ' +
  ' LEFT JOIN gd_value v ON g.valuekey = v.id ';


  if Assigned(FViewFeatures) then
    for i:= 0 to FViewFeatures.Count - 1 do
    begin
      F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      begin
        Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' C_' + FViewFeatures[i] +
          ' ON C.' + FViewFeatures[i] + ' = ' + ' C_' + FViewFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;
      end;
    end;

  if Assigned(FRemainsFeatures) then
    for i:= 0 to FRemainsFeatures.Count - 1 do
    begin
      F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FRemainsFeatures[i]));
      if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      begin
        Result := Result + ' LEFT JOIN ' + F.Field.RefTable.RelationName + ' ZR_' + FRemainsFeatures[i] +
          ' ON C.' + FRemainsFeatures[i] + ' = ' + ' ZR_' + FRemainsFeatures[i] + '.' + F.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName;

        FSQLSetup.Ignores.AddAliasName('ZR_' +
          FRemainsFeatures[i]);
      end;
    end;

  FSQLSetup.Ignores.AddAliasName('Z');
  FSQLSetup.Ignores.AddAliasName('C');
  if HasSubSet('ByGoodDetail') then
    FSQLSetup.Ignores.AddAliasName('G');

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}

end;

function TgdcInvCard.GetGroupClause: String;
var
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_GETGROUPCLAUSE('TGDCINVCARD', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARD', KEYGETGROUPCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETGROUPCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARD',
  {M}          'GETGROUPCLAUSE', KEYGETGROUPCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETGROUPCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARD' then
  {M}        begin
  {M}          Result := Inherited GetGroupClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := 'GROUP BY con.Name, doc.number, doc.documentdate, doc.CREATIONDATE, doc.EDITIONDATE, ' +
   ' doct.name, doct.ruid, doc.id, doc.parent, g.Name, v.Name, m.contactkey, z.goodkey, main_con.name, main_con.id ';
  if HasSubSet('ByHolding') then
    Result := Result + ', con_m.name ';

  for i:= 0 to FViewFeatures.Count - 1 do
  begin
    Result := Result + ', C.' + FViewFeatures[i];
    F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
    if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      if F.Field.FieldType <> ftMemo then
        Result := Result + ', C_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName;
  end;

  for i:= 0 to FRemainsFeatures.Count - 1 do
  begin
    Result := Result + ', C.' + FRemainsFeatures[i];
    F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FRemainsFeatures[i]));
    if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      if Assigned(F.Field.RefListField) and (F.Field.RefListField.Field.FieldType <> ftMemo) then
        Result := Result + ', zr_' + FRemainsFeatures[i] + '.' + F.Field.RefListFieldName;
  end;
  
  if not HasSubSet('ByAllMovement') then
    Result := Result + ' HAVING SUM(m.Debit) <> SUM(m.Credit) ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARD', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARD', 'GETGROUPCLAUSE', KEYGETGROUPCLAUSE);
  {M}  end;
  {END MACRO}

end;

class function TgdcInvCard.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvCard.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvCard.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'INV_MOVEMENT';
end;

function TgdcInvCard.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCINVCARD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARD', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARD',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARD' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  if HasSubSet('ByHolding') then
    Result := 'ORDER BY doc.documentdate, doc.EDITIONDATE, 16 DESC '
  else
    Result := 'ORDER BY doc.documentdate, doc.EDITIONDATE, 15 DESC ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARD', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcInvCard.GetRefreshSQLText: String;
begin
  Result := '';
end;

function TgdcInvCard.GetRemainsOnDate(DateEnd: TDateTime;
  IsCurrent: Boolean; const AContactKeys: string): Currency;
var
  ibsql: TIBSQL;
  FromContactStatement, WhereStatement: String;
  i: Integer;
  DataSet: TDataSet;
  Prefix, SQLText: String;
begin
  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := ReadTransaction;

    Prefix := '';
    if Assigned(gdcInvRemains) then
      DataSet := gdcInvRemains
    else
      if Assigned(gdcInvDocumentLine) then
      begin
        DataSet := gdcInvDocumentLine;
        Prefix := FieldPrefix;
      end
      else
        DataSet := Self;

    // Ограничения на признаки карточки
    WhereStatement := '';
    if not HasSubSet('ByGoodOnly') then
      for i:= 0 to RemainsFeatures.Count - 1 do
      begin
        // Если поле INTEGER
        if DataSet.FieldByName(Prefix + RemainsFeatures[i]).DataType in [ftSmallint, ftBCD, ftInteger, ftLargeInt] then
          if not DataSet.FieldByName(Prefix + RemainsFeatures[i]).IsNull then
            WhereStatement := WhereStatement + ' AND (c.' + RemainsFeatures[i]  + ' + 0) = :' + RemainsFeatures[i]
          else
            WhereStatement := WhereStatement + ' AND (c.' + RemainsFeatures[i]  + ' + 0) IS NULL '
        else
          if not DataSet.FieldByName(Prefix + RemainsFeatures[i]).IsNull then
            WhereStatement := WhereStatement + ' AND c.' + RemainsFeatures[i]  + ' = :' + RemainsFeatures[i]
          else
            WhereStatement := WhereStatement + ' AND c.' + RemainsFeatures[i]  + ' IS NULL ';
      end;
    // Дополнительные таблицы для ограничения по контактам
    FromContactStatement := '';
    if HasSubSet('ByLBRBDepot') then
      FromContactStatement :=
        '  LEFT JOIN gd_contact con ON m.contactkey = con.id '
    else
      if HasSubSet('ByHolding') then
        FromContactStatement :=
          '  LEFT JOIN gd_contact con ON m.contactkey = con.id ' +
          '  LEFT JOIN gd_contact hold ON con.LB >= hold.LB and con.RB <= hold.RB ';
    // Ограничения на контакты
    if HasSubSet('ByHolding') then
      WhereStatement := WhereStatement + ' AND hold.id IN (SELECT companykey FROM gd_holding) '
    else
    begin
      if HasSubSet('ByLBRBDepot') then
        WhereStatement := WhereStatement + ' AND con.LB >= :LB AND con.RB <= :RB '
      else if HasSubSet('ByGoodDetail') then
      begin
        if AContactKeys <> '' then
          WhereStatement := WhereStatement + ' AND m.contactkey ' + AContactKeys + ' ';
      end
      else
        WhereStatement := WhereStatement + ' AND m.contactkey = :contactkey ';
    end;
    // Если сервер Firebird 2.0+, и есть поле GOODKEY в INV_MOVEMENT и INV_BALANCE,
    //   то будем брать остатки новыми запросами
    if Database.IsFirebirdConnect and (Database.ServerMajorVersion >= 2)
       and Assigned(atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY')) and (not isCurrent) then
    begin
      SQLText :=
          'SELECT' + #13#10 +
          '  SUM(M.BALANCE) AS remains ' + #13#10 +
          'FROM (' + #13#10 +
          '  SELECT SUM(M.BALANCE) AS BALANCE ' + #13#10 +
          '  FROM INV_BALANCE m' + #13#10 +
          '  LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10 +
          FromContactStatement + #13#10 +
          '  WHERE' + #13#10 +
          '    m.goodkey = :goodkey ' + #13#10 +
          WhereStatement + #13#10;
      if not isCurrent then
        SQLText := SQLText + ' UNION ALL '#13#10 +
          ' SELECT' + #13#10 +
          ' SUM(M.CREDIT - M.DEBIT) AS BALANCE ' + #13#10 +
          ' FROM INV_MOVEMENT m' + #13#10 +
          ' LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10 +
          FromContactStatement + #13#10 +
          ' WHERE' + #13#10 +
          '   m.movementdate > :dateend' + #13#10 +
          '   AND m.goodkey = :goodkey' + #13#10 +
          '   AND m.disabled = 0' + #13#10 +
          WhereStatement + #13#10;
      SQLText := SQLText + ' ) M ';
      
      ibsql.SQL.Text := SQLText;
    end
    else
    begin
      if isCurrent then
        SQLText :=
          'SELECT ' +
          '  SUM(m.balance) as Remains ' +
          'FROM ' +
          '  inv_card c ' +
          '  LEFT JOIN inv_balance m ON c.id = m.cardkey '
      else
        SQLText :=
          'SELECT ' +
          '  SUM(m.debit - m.credit) as Remains ' +
          'FROM ' +
          '  inv_card c ' +
          '  LEFT JOIN inv_movement m ON c.id = m.cardkey ';
      if HasSubSet('ByLBRBDepot') then
        SQLText := SQLText +
          '  LEFT JOIN gd_contact con ON m.contactkey = con.id '
      else
        if HasSubSet('ByHolding') then
          SQLText := SQLText +
            '  LEFT JOIN gd_contact con ON m.contactkey = con.id ' +
            '  LEFT JOIN gd_contact hold ON con.LB >= hold.LB and con.RB <= hold.RB ';

      SQLText := SQLText +
        'WHERE ' +
        '  c.goodkey = :goodkey ' + WhereStatement;

      if not isCurrent then
        SQLText := SQLText + ' AND m.movementdate <= :dateend AND m.disabled = 0 ';

      ibsql.SQL.Text := SQLText;
    end;

    // Заполняем параметры ТОВАР и КОНТАКТЫ
    ibsql.ParamByName('goodkey').AsInteger := DataSet.FieldByName('goodkey').AsInteger;
    if HasSubSet('ByLBRBDepot') then
    begin
      ibsql.ParamByName('LB').AsInteger := ParamByName('LB').AsInteger;
      ibsql.ParamByName('RB').AsInteger := ParamByName('RB').AsInteger;
    end
    else
    begin
      if not HasSubSet('ByGoodDetail') and not HasSubSet('ByHolding') then
      begin
        if ContactKey > 0 then
          ibsql.ParamByName('contactkey').AsInteger := ContactKey
        else
          ibsql.ParamByName('contactkey').AsInteger := ParamByName('contactkey').AsInteger;
      end;
    end;
    // Заполняем параметр ДАТА
    if not isCurrent then
      ibsql.ParamByName('dateend').AsDateTime := DateEnd;
    // Заполняем параметры ПРИЗНАКИ КАРТОЧКИ
    if not HasSubSet('ByGoodOnly') then
      for i:= 0 to RemainsFeatures.Count - 1 do
      begin
        if not DataSet.FieldByName(Prefix + RemainsFeatures[i]).IsNull then
          ibsql.ParamByName(RemainsFeatures[i]).AsVariant :=
            DataSet.FieldByName(Prefix + RemainsFeatures[i]).AsVariant;
      end;

    ibsql.ExecQuery;

    if ibsql.RecordCount > 0 then
      Result := ibsql.FieldByName('remains').AsCurrency
    else
      Result := 0;

    ibsql.Close;
  finally
    ibsql.Free;
  end;
end;

function TgdcInvCard.GetSelectClause: String;
VAR
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  i: Integer;
  F: TatRelationField;
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCINVCARD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARD', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARD',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARD' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := 'SELECT con.Name, doc.number, doc.documentdate, doc.CREATIONDATE, doc.EDITIONDATE, g.Name as GoodName, v.Name as ValueName, ' +
   ' doct.name as DocName, doct.ruid, doc.id, doc.parent, m.contactkey, z.goodkey, main_con.name as DEPOTNAME, main_con.id as DEPOTKEY ';
  if HasSubSet('ByHolding') then
    Result := Result + ', con_m.Name as NameMove, SUM(m.Debit) as Debit, SUM(m.Credit) as Credit '
  else
    Result := Result + ', SUM(m.Debit) as Debit, SUM(m.Credit) as Credit ';

  for i:= 0 to FViewFeatures.Count - 1 do
  begin
    Result := Result + ', c.' + FViewFeatures[i];
    F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FViewFeatures[i]));
    if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
    begin
      if F.Field.FieldType <> ftMemo then
        Result := Result + ', c_' + FViewFeatures[i] + '.' + F.Field.RefListFieldName + ' as c_' +
          FViewFeatures[i] + '_' + F.Field.RefListFieldName;
     end;
  end;

  for i:= 0 to FRemainsFeatures.Count - 1 do
  begin
    Result := Result + ', c.' + FRemainsFeatures[i];
    F := atDatabase.Relations.ByRelationName('INV_CARD').RelationFields.ByFieldName(UpperCase(FRemainsFeatures[i]));
    if Assigned(F) and Assigned(F.References) and Assigned(F.Field) then
      if Assigned(F.Field.RefListField) and (F.Field.RefListField.Field.FieldType <> ftMemo) then
        Result := Result + ', zr_' + FRemainsFeatures[i] + '.' + F.Field.RefListFieldName + ' as zr_' +
          FRemainsFeatures[i] + '_' + F.Field.RefListFieldName;
  end;

  Result := Result + ', CAST(0 as NUMERIC(15, 4)) as Remains';


  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}

end;

class function TgdcInvCard.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByInterval;ByContact;ByLBRBDepot;ByGoodDetail;ByHolding;ByGoodOnly;ByAllMovement;';
end;

procedure TgdcInvCard.GetWhereClauseConditions(S: TStrings);
var
  F: TatRelationField;
begin
  inherited;

  if not HasSubSet('ByID') and not HasSubSet('ByGoodDetail') then
  begin
    F := atDatabase.FindRelationField('INV_MOVEMENT', 'GOODKEY');
    if GlobalStorage.ReadBoolean('Options\Invent', 'DontUseGoodKey', False, False) or not Assigned(F) then
      S.Add('z.goodkey = :goodkey');
  end;

  if HasSubSet('ByGoodDetail') then
    S.Add(' z.companykey in (' + IBLogin.HoldingList + ')');

  if HasSubSet('ByInterval') then
    S.Add(' m.movementdate >= :datebegin AND m.movementdate <= :dateend');

  if HasSubSet('ByHolding') then
  begin
    if isHolding then
      S.Add(' h.holdingkey > 0 ')
    else
      S.Add(' hold.id in (' + IBLogin.HoldingList + ')');  
  end
  else
    if HasSubSet('ByContact') then
      S.Add(' m.contactkey = :contactkey')
    else
      if HasSubSet('ByLBRBDepot') then
        S.Add(' con.LB >= :LB AND con.RB <= :RB ');


end;

procedure TgdcInvCard.SetFeatures(DataSet: TDataSet; Prefix: String; Features: TgdcInvFeatures);
var
  i: Integer;
begin
  if not HasSubSet('ByGoodOnly') then
  begin
    for i:= Low(Features) to High(Features) do
    begin
      if IgnoryFeatures.IndexOf(Features[i]) < 0 then
      begin
        if not DataSet.FieldByName(Prefix + Features[i]).IsNull then
          ExtraConditions.Add('z.' + Features[i] + ' = :' + Features[i])
        else
          ExtraConditions.Add('z.' + Features[i] + ' IS NULL ');
      end;
      RemainsFeatures.Add(Features[i]);
    end;

    for i:= Low(Features) to High(Features) do
    begin
      if IgnoryFeatures.IndexOf(Features[i]) < 0 then
      begin
        if not DataSet.FieldByName(Prefix + Features[i]).IsNull then
        begin
          ParamByName(Features[i]).AsVariant :=
            DataSet.FieldByName(Prefix + Features[i]).AsVariant;
        end;
      end;
    end;

  end;
end;

procedure TgdcInvCard.SetDocumentLineConditions;
var
  ibsql: TIBSQL;
begin
  if Assigned(gdcInvDocumentLine) then
  begin

    ParamByName('goodkey').AsInteger := gdcInvDocumentLine.FieldByName('goodkey').AsInteger;

    RemainsFeatures.Clear;

    if (gdcInvDocumentLine as TgdcInvDocumentLine).RelationType = irtTransformation then
    begin
      if (gdcInvDocumentLine as TgdcInvDocumentLine).ViewMovementPart in [impIncome, impAll] then
        FieldPrefix := INV_DESTFEATURE_PREFIX
      else
        FieldPrefix := INV_SOURCEFEATURE_PREFIX;
    end else

    if (gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.ContactType in [imctOurCompany, imctOurDepartment, imctOurPeople] then
      FieldPrefix := INV_SOURCEFEATURE_PREFIX
    else
      FieldPrefix := INV_DESTFEATURE_PREFIX;

    if FieldPrefix = INV_SOURCEFEATURE_PREFIX then
    begin
      if not HasSubSet('ByGoodOnly') then
        SetFeatures(gdcInvDocumentLine, FieldPrefix, (gdcInvDocumentLine as TgdcInvDocumentLine).SourceFeatures);

      if not HasSubSet('ByHolding') then
      begin
        if FContactKey > 0 then
          ParamByName('contactkey').AsInteger := FContactKey
        else
        begin
          if
            (AnsiCompareText((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.RelationName, (gdcInvDocumentLine as TgdcInvBaseDocument).RelationName) = 0) and
            ((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName > '')
          then
          begin
            if (gdcInvDocumentLine.MasterSource <> nil) and (gdcInvDocumentLine.MasterSource.DataSet <> nil)
            then
              ParamByName('contactkey').AsInteger := gdcInvDocumentLine.MasterSource.DataSet.
                FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName).AsInteger
            else
            begin
              ibsql := TIBSQL.Create(Self);
              try
                ibsql.SQL.Text := 'SELECT ' + (gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName +
                  ' FROM ' + (gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.RelationName +
                  ' WHERE documentkey = ' + gdcInvDocumentLine.FieldByName('parent').AsString;
                ibsql.Transaction := gdcInvDocumentLine.ReadTransaction;
                ibsql.ExecQuery;
                ParamByName('contactkey').AsInteger := ibsql.FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName).AsInteger;
              finally
                ibsql.Free;
              end;
            end;
          end
          else

          if ((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName > '') then
            ParamByName('contactkey').AsInteger := gdcInvDocumentLine.FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName).AsInteger;
        end;
      end;
    end
    else
    begin 
      if not HasSubSet('ByGoodOnly') then
        SetFeatures(gdcInvDocumentLine, FieldPrefix, (gdcInvDocumentLine as TgdcInvDocumentLine).DestFeatures);

      if not HasSubSet('ByHolding') then
      begin
        if FContactKey > 0 then
          ParamByName('contactkey').AsInteger := FContactKey
        else
        begin
          if
            (AnsiCompareText((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.RelationName, (gdcInvDocumentLine as TgdcInvBaseDocument).RelationName) = 0) and
            ((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName > '')
          then
          begin
            if (gdcInvDocumentLine.MasterSource <> nil) and (gdcInvDocumentLine.MasterSource.DataSet <> nil)
            then
              ParamByName('contactkey').AsInteger := gdcInvDocumentLine.MasterSource.DataSet.
                FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName).AsInteger
            else
            begin
              ibsql := TIBSQL.Create(Self);
              try
                ibsql.SQL.Text := 'SELECT ' + (gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName +
                  ' FROM ' + (gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.RelationName +
                  ' WHERE documentkey = ' + gdcInvDocumentLine.FieldByName('parent').AsString;
                ibsql.Transaction := gdcInvDocumentLine.ReadTransaction;
                ibsql.ExecQuery;
                ParamByName('contactkey').AsInteger := ibsql.FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName).AsInteger;
              finally
                ibsql.Free;
              end;
            end
          end
          else

          if ((gdcInvDocumentLine as TgdcInvBaseDocument).MovementSource.SourceFieldName > '') then
            ParamByName('contactkey').AsInteger := gdcInvDocumentLine.FieldByName((gdcInvDocumentLine as TgdcInvBaseDocument).MovementTarget.SourceFieldName).AsInteger;
        end;
      end;
{      for i:= Low((gdcInvDocumentLine as TgdcInvDocumentLine).DestFeatures) to
        High((gdcInvDocumentLine as TgdcInvDocumentLine).DestFeatures) do
      begin
        if IgnoryFeatures.IndexOf((gdcInvDocumentLine as TgdcInvDocumentLine).DestFeatures[i]) < 0 then
        begin
          if not gdcInvDocumentLine.FieldByName('TO_' + (gdcInvDocumentLine as TgdcInvDocumentLine).DestFeatures[i]).IsNull then
          begin
            ParamByName((gdcInvDocumentLine as TgdcInvDocumentLine).DestFeatures[i]).AsVariant :=
              gdcInvDocumentLine.FieldByName('TO_' + (gdcInvDocumentLine as TgdcInvDocumentLine).DestFeatures[i]).AsVariant;
          end;
        end;
      end;}

    end;
  end;
end;

procedure TgdcInvCard.SetIgnoryFeatures(const Value: TStringList);
begin
  if Assigned(FIgnoryFeatures) then
    FIgnoryFeatures.Assign(Value);
end;

procedure TgdcInvCard.SetRemainsConditions;
var
  i: Integer;
begin
  if Assigned(gdcInvRemains) then
  begin
    if not HasSubSet('ByGoodOnly') then
    begin

      RemainsFeatures := gdcInvRemains.ViewFeatures;
      for i:= 0 to gdcInvRemains.ViewFeatures.Count - 1 do
      begin
        if IgnoryFeatures.IndexOf(gdcInvRemains.ViewFeatures[i]) < 0 then
        begin
          if not gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i]).IsNull then
            ExtraConditions.Add('z.' + gdcInvRemains.ViewFeatures[i] + ' = :' +
            gdcInvRemains.ViewFeatures[i])
          else
            ExtraConditions.Add('z.' + gdcInvRemains.ViewFeatures[i] + ' IS NULL ');
        end;
      end;
    end;

    ParamByName('goodkey').AsInteger :=
      gdcInvRemains.FieldByName('goodkey').AsInteger;
    if not HasSubSet('ByHolding') then
    begin
      if FContactKey <= 0 then
      begin
        if gdcInvRemains.FindField('contactkey') <> nil then
          ParamByName('contactkey').AsInteger :=
            gdcInvRemains.FieldByName('contactkey').AsInteger
        else
          ParamByName('contactkey').AsInteger :=
            gdcInvRemains.ParamByName('departmentkey').AsInteger;
      end
      else
        ParamByName('contactkey').AsInteger := FContactKey;
    end;

    if not HasSubSet('ByGoodOnly') then
    begin
      for i:= 0 to gdcInvRemains.ViewFeatures.Count - 1 do
      begin
        if IgnoryFeatures.IndexOf(gdcInvRemains.ViewFeatures[i]) < 0 then
        begin
          if not gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i]).IsNull then
            ParamByName(gdcInvRemains.ViewFeatures[i]).AsVariant :=
            gdcInvRemains.FieldByName(gdcInvRemains.ViewFeatures[i]).AsVariant;
        end;
      end;
    end;  
  end;

end;

procedure TgdcInvCard.SetRemainsFeatures(const Value: TStringList);
begin
  if Assigned(FRemainsFeatures) then
    FRemainsFeatures.Assign(Value);

end;

procedure TgdcInvCard.SetViewFeatures(const Value: TStringList);
begin
  if Assigned(FViewFeatures) then
    FViewFeatures.Assign(Value);
end;

procedure TgdcInvCard.ReInitialized;
begin
  FSQLInitialized := False;
end;

function TgdcInvCard.IsHolding: Boolean;
var
  ibsql: TIBSQL;
begin
  if FIsHolding = -1 then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.Transaction := ReadTransaction;
      ibsql.SQL.Text := 'SELECT * FROM gd_holding WHERE companykey = <companykey/>';
      ibsql.ExecQuery;
      if ibsql.EOF then
        FIsHolding := 0
      else
        FIsHolding := 1;
    finally
      ibsql.Free;
    end;
  end;
  Result := FIsHolding = 1;

end;

{ TgdcInvRemainsOption }

constructor TgdcInvRemainsOption.Create(AnOwner: TComponent);
begin
  inherited;

end;

function TgdcInvRemainsOption.CreateDialogForm: TCreateableForm;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_FUNCCREATEDIALOGFORM('TGDCINVREMAINSOPTION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  try
  {M}    Result := nil;
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYCREATEDIALOGFORM);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEDIALOGFORM]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'CREATEDIALOGFORM', KEYCREATEDIALOGFORM, Params, LResult) then
  {M}          begin
  {M}            Result := nil;
  {M}            if VarType(LResult) <> varDispatch then
  {M}              raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен не объект.')
  {M}            else
  {M}              if IDispatch(LResult) = nil then
  {M}                raise Exception.Create('Скрипт-функция: ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + 'CREATEDIALOGFORM' + #13#10 + 'Для метода ''' +
  {M}                  'CREATEDIALOGFORM' + ' ''' + 'класса ' + Self.ClassName +
  {M}                  TgdcBase(Self).SubType + #10#13 + 'Из макроса возвращен пустой (null) объект.');
  {M}            Result := GetInterfaceToObject(LResult) as TCreateableForm;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Result := Inherited CreateDialogForm;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := Tgdc_dlgInvRemainsOption.Create(ParentForm);
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'CREATEDIALOGFORM', KEYCREATEDIALOGFORM);
  {M}  end;
  {END MACRO}
end;


procedure TgdcInvRemainsOption.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVREMAINSOPTION', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  //
  // Удаляем данные из таблицы команд

  ExecSingleQuery(Format(
    'DELETE FROM gd_command WHERE classname = ''TgdcInvRemains'' AND ' +
    '  subtype = ''%s''',
    [FieldByName('ruid').AsString]));

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemainsOption.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVREMAINSOPTION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  UpdateExplorerCommandData(
    'cкладcкой учет', 'inventory'
    FieldByName('NAME').AsString, FieldByName('ruid').AsString,
    TgdcInvRemains.ClassName, False, FieldByName('branchkey').AsInteger
  );
  
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvRemainsOption.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCINVREMAINSOPTION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  UpdateExplorerCommandData(
    'cкладcкой учет', 'inventory',
    FieldByName('NAME').AsString, FieldByName('ruid').AsString,
    TgdcInvRemains.ClassName,
    True, FieldByName('branchkey').AsInteger
  );

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

destructor TgdcInvRemainsOption.Destroy;
begin
  inherited;

end;

procedure TgdcInvRemainsOption.DoBeforePost;
var
  ibsql: TIBSQL;
  S: String;
  L: Integer;
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINSOPTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYDOBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'DOBEFOREPOST', KEYDOBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;
{  Если мы в состоянии загрузки из потока, выполним проверку на уникальность наименование документа
  При дублировании наименования, подкорректируем его
  Проверка идет через запрос к базе, никаких кэшей!!!}

  if (sLoadFromStream in BaseState) then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      if Transaction.InTransaction then
        ibsql.Transaction := Transaction
      else
        ibsql.Transaction := ReadTransaction;

      ibsql.SQL.Text := 'SELECT id FROM INV_BALANCEOPTION WHERE UPPER(name) = :name and id <> :id';
      ibsql.ParamByName('name').AsString := AnsiUpperCase(FieldByName('name').AsString);
      ibsql.ParamByName('id').AsInteger := ID;
      ibsql.ExecQuery;

      if ibsql.RecordCount > 0 then
      begin
        S := FieldByName('name').AsString + FieldByName(GetKeyField(SubType)).AsString;
        L := Length(S);
        if L > 60 then
        begin
          S := System.Copy(FieldByName('name').AsString, 1,
            L - Length(FieldByName(GetKeyField(SubType)).AsString)) +
            FieldByName(GetKeyField(SubType)).AsString;
        end;
        FieldByName('name').AsString := S;
      end;

      ibsql.Close;

    finally
      ibsql.Free;
    end;
  end;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'DOBEFOREPOST', KEYDOBEFOREPOST)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'DOBEFOREPOST', KEYDOBEFOREPOST);
  {M}  end;
  {END MACRO}

end;

class function TgdcInvRemainsOption.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvRemainsOption.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcInvRemainsOption.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'INV_BALANCEOPTION';
end;

function TgdcInvRemainsOption.GetNotCopyField: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETNOTCOPYFIELD('TGDCINVREMAINSOPTION', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEYGETNOTCOPYFIELD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETNOTCOPYFIELD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETNOTCOPYFIELD' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TGDCINVREMAINSOPTION(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Result := Inherited GetNotCopyField;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result := inherited GetNotCopyField;

  if Result > '' then
    Result := Result + ',RUID'
  else
    Result := 'RUID';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', 'GETNOTCOPYFIELD', KEYGETNOTCOPYFIELD);
  {M}  end;
  {END MACRO}

end;

class function TgdcInvRemainsOption.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvRemainsOption';
end;

procedure TgdcInvRemainsOption.ReadOptions;
var
  Stream: TStream;
begin
  Stream := TStringStream.Create(FieldByName('viewfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      SetLength(FViewFeatures, 0);
      while not EndOfList do
      begin
        SetLength(FViewFeatures, Length(FViewFeatures) + 1);
        FViewFeatures[Length(FViewFeatures) - 1] := ReadString;
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(FieldByName('sumfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      SetLength(FSumFeatures, 0);
      while not EndOfList do
      begin
        SetLength(FSumFeatures, Length(FSumFeatures) + 1);
        FSumFeatures[Length(FSumFeatures) - 1] := ReadString;
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(FieldByName('goodviewfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      SetLength(FGoodViewFeatures, 0);
      while not EndOfList do
      begin
        SetLength(FGoodViewFeatures, Length(FGoodViewFeatures) + 1);
        FGoodViewFeatures[Length(FGoodViewFeatures) - 1] := ReadString;
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(FieldByName('goodsumfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      SetLength(FGoodSumFeatures, 0);
      while not EndOfList do
      begin
        SetLength(FGoodSumFeatures, Length(FGoodSumFeatures) + 1);
        FGoodSumFeatures[Length(FGoodSumFeatures) - 1] := ReadString;
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

end;

procedure TgdcInvRemainsOption.UpdateExplorerCommandData(MainBranchName,
  CMD, CommandName, DocumentID, ClassName: String;
  const ShouldUpdateData: Boolean; const MainBranchKey: Integer);
var
  ibsql: TIBSQL;
  BranchID: Integer;
  DidActivate: Boolean;
begin
  DidActivate := False;
  ibsql := TIBSQL.Create(nil);
  try
    //
    // Оcущеcтвляем поиcк запиcи

    ibsql.Database := Database;
    ibsql.Transaction := Transaction;

    DidActivate := ActivateTransaction;

    ibsql.SQL.Text := Format(
      'SELECT CLASSNAME, SUBTYPE FROM ' +
      '  GD_COMMAND WHERE CLASSNAME = ''%s'' AND SUBTYPE = ''%s''',
      [ClassName, DocumentID]
    );

    ibsql.ExecQuery;

    //Еcли не выбрана ветка, то удалим запиcь из Иccледователя по ее клаccу и cабтайпу
    if (MainBranchKey <= 0) then
    begin
      ibsql.Close;
      ibsql.SQl.Text := 'DELETE FROM gd_command WHERE UPPER(classname) = :classname ' +
        ' AND UPPER(subtype) = :subtype ';
      ibsql.ParamByName('classname').AsString := AnsiUpperCase(ClassName);
      ibsql.ParamByName('subtype').AsString := AnsiUpperCase(DocumentID);
      ibsql.ExecQuery;
    end else

    //
    // Еcли запиcь еще не добавлена оcущеcтвляем ее добавление
    if ibsql.RecordCount = 0 then
    begin
      //
      // Оcущеcтвляем проверку на наличие общей ветки

      ibsql.Close;
      ibsql.SQL.Text :=
        'SELECT ID, NAME FROM GD_COMMAND WHERE ID = :ID';
      ibsql.ParamByName('ID').AsInteger := MainBranchKey;
      ibsql.ExecQuery;

      if ibsql.RecordCount = 0 then
      begin
        //
        // Еcли ветки нет - добавляем ее

        { TODO 1 -oдениc -ccделать : 710000 cледует заменить на конcтанту }

        ibsql.Close;
        ibsql.SQL.Text :=
          'INSERT INTO GD_COMMAND (ID, PARENT, NAME, CMD, CMDTYPE, IMGINDEX) ' +
          'VALUES ' +
          '  (:ID, :Parent, :NAME, :CMD, 0, 0) ';

        ibsql.ParamByName('ID').AsInteger := GetNextID(True);
        ibsql.ParamByName('PARENT').AsInteger := 710000;
        ibsql.ParamByName('NAME').AsString := MainBranchName;
        ibsql.ParamByName('CMD').AsString := CMD;

        ibsql.ExecQuery;

        BranchID := ibsql.ParamByName('ID').AsInteger;
      end else
        BranchID := ibsql.FieldByName('ID').AsInteger;

      //
      // Оcущеcтвляем добавление команды

      ibsql.Close;
      ibsql.SQL.Text :=
        'INSERT INTO GD_COMMAND (ID, PARENT, NAME, CMD, CMDTYPE, CLASSNAME, SUBTYPE, ' +
        '  IMGINDEX) ' +
        'VALUES ' +
        '  (:ID, :PARENT, :NAME, :CMD, 0, :CLASSNAME, :SUBTYPE, 17) ';

      ibsql.ParamByName('ID').AsInteger := GetNextID(True);
      ibsql.ParamByName('PARENT').AsInteger := BranchID;
      ibsql.ParamByName('NAME').AsString := CommandName;
      ibsql.ParamByName('CMD').AsString := DocumentID;
      ibsql.ParamByName('CLASSNAME').AsString := ClassName;
      ibsql.ParamByName('SUBTYPE').AsString := DocumentID;

      ibsql.ExecQuery;
    end else

    if ShouldUpdateData then
    begin
      ibsql.Close;
      if MainBranchKey > 0 then
        ibsql.SQL.Text :=
          'UPDATE GD_COMMAND SET NAME = :NAME, PARENT = :PARENT ' +
          '  WHERE CLASSNAME = :CLASSNAME AND SUBTYPE = :SUBTYPE '
      else
        ibsql.SQL.Text :=
          'UPDATE GD_COMMAND SET NAME = :NAME ' +
          '  WHERE CLASSNAME = :CLASSNAME AND SUBTYPE = :SUBTYPE ';

      ibsql.ParamByName('NAME').AsString := CommandName;
      if MainBranchKey > 0 then
        ibsql.ParamByName('PARENT').AsInteger := MainBranchKey;
      ibsql.ParamByName('CLASSNAME').AsString := ClassName;
      ibsql.ParamByName('SUBTYPE').AsString := DocumentID;
      ibsql.ExecQuery;
    end;
  finally
    if DidActivate and Transaction.InTransaction then
      Transaction.Commit;
    ibsql.Free;
  end;
end;

procedure TgdcInvRemainsOption.WriteOptions;
var
  Stream: TStringStream;
  i: Integer;
begin
  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;
      for I := 0 to Length(FViewFeatures) - 1 do
        WriteString(FViewFeatures[I]);
      WriteListEnd;
      FieldByName('viewfields').AsString := Stream.DataString;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;
      for I := 0 to Length(FSumFeatures) - 1 do
        WriteString(FSumFeatures[I]);
      WriteListEnd;
      FieldByName('sumfields').AsString := Stream.DataString;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;
      for I := 0 to Length(FGoodViewFeatures) - 1 do
        WriteString(FGoodViewFeatures[I]);
      WriteListEnd;
      FieldByName('goodviewfields').AsString := Stream.DataString;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;
      for I := 0 to Length(FGoodSumFeatures) - 1 do
        WriteString(FGoodSumFeatures[I]);
      WriteListEnd;
      FieldByName('goodsumfields').AsString := Stream.DataString;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

end;

procedure TgdcInvRemainsOption._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVREMAINSOPTION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVREMAINSOPTION', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVREMAINSOPTION',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('ruid').AsString := RUIDToStr(GetRUID);

//  FieldByName('classname').AsString := FCurrentClassName;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVREMAINSOPTION', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVREMAINSOPTION', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

(*
{ TgdcInvCardFull }

class function TgdcInvCardFull.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvCardFull.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcInvCardFull.GetListTable(
  const ASubType: TgdcSubType): String;
begin
   Result := 'INV_CARD';
end;
*)
{ TgdcInvCardConfig }

constructor TgdcInvCardConfig.Create(AnOwner: TComponent);
begin
  inherited Create(anOwner);
  FConfig:= TInvCardConfig.Create;
end;

destructor TgdcInvCardConfig.Destroy;
begin
  FConfig.Free;
  inherited;
end;

function TgdcInvCardConfig.GetConfig: TInvCardConfig;
begin
  Result:= FConfig;
end;

class function TgdcInvCardConfig.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgInvCardConfig'
end;

class function TgdcInvCardConfig.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'ID'
end;

class function TgdcInvCardConfig.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'NAME'
end;

class function TgdcInvCardConfig.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'AC_ACCT_CONFIG'
end;

class function TgdcInvCardConfig.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmInvCardConfig'
end;

procedure TgdcInvCardConfig.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  S.Add('z.CLASSNAME = ''TInvCardConfig''')
end;

procedure TgdcInvCardConfig.LoadConfig;
var
  Str: TStream;
begin
  if (not ID > 0) or FieldByName('config').IsNull then Exit;
  Str := CreateBlobStream(FieldByName('config'), bmRead);
  try
    Config.LoadFromStream(Str);
  finally
    Str.Free
  end;
end;

procedure TgdcInvCardConfig.SaveConfig;
var
  Str: TStream;
begin
  if not (State in dsEditModes) then
    Edit;
  if not ID > 0 then Exit;
  Str := TMemoryStream.Create;
  try
    Config.SaveToStream(Str);
    (FieldByName('config') as TBlobField).LoadFromStream(Str);
  finally
    Str.Free
  end;
  Post;
end;

procedure TgdcInvCardConfig.ClearGrid;
begin
  Config.GridSettings.Clear;
  SaveConfig;
end;

procedure TgdcInvCardConfig.SaveGrid(Grid: TgsIBGrid);
begin
  Grid.SaveToStream(Config.GridSettings);
  SaveConfig;
end;

procedure TgdcInvCardConfig._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCINVCARDCONFIG', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARDCONFIG', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARDCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARDCONFIG',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARDCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  FieldByName('classname').AsString := 'TInvCardConfig';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARDCONFIG', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARDCONFIG', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

procedure TgdcInvCardConfig.DoAfterScroll;
begin
  LoadConfig;
  inherited;
end;

procedure TgdcInvCardConfig.CreateCommand(SFRUID: TRUID);
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Text := 'SELECT id FROM gd_command WHERE cmd = :CMD';
    SQL.ParamByName('cmd').AsString := RUIDToStr(SFRUID);
    SQL.ExecQuery;

    gdcExplorer := TgdcExplorer.Create(nil);
    try
      gdcExplorer.Transaction := Transaction;
      gdcExplorer.ReadTransaction := ReadTransaction;
      gdcExplorer.SubSet := 'ByID';
      gdcExplorer.Id := SQL.FieldByName('id').AsInteger;
      gdcExplorer.Open;
      gdcExplorer.Edit;
      try
        if FieldByName('folder').IsNull then
          gdcExplorer.FieldByName('parent').Clear
        else
          gdcExplorer.FieldByName('parent').AsInteger := FieldByName('folder').AsInteger;
        gdcExplorer.FieldByName('name').AsString := FieldByName('name').AsString;
        gdcExplorer.FieldByName('cmd').AsString := RUIDToStr(SFRUID);
        gdcExplorer.FieldByName('cmdtype').AsInteger := cst_expl_cmdtype_function;
        gdcExplorer.FieldByName('imgindex').AsInteger := FieldByName('imageindex').AsInteger;
        gdcExplorer.Post;
      except
        gdcExplorer.Cancel;
        raise;
      end;
    finally
      gdcExplorer.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcInvCardConfig.DeleteCommand(SFRUID: TRUID);
var
  SQL: TIBSQL;
  gdcExplorer: TgdcExplorer;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := Transaction;
    SQL.SQL.Text := 'SELECT id FROM gd_command WHERE cmd = :CMD ';
    SQL.ParamByName('cmd').AsString := RUIDToStr(SFRUID);
    SQL.ExecQuery;

    gdcExplorer := TgdcExplorer.Create(nil);
    try
      gdcExplorer.Transaction := Transaction;
      gdcExplorer.ReadTransaction := ReadTransaction;
      gdcExplorer.SubSet := 'ByID';
      gdcExplorer.Id := SQL.FieldByName('id').AsInteger;
      gdcExplorer.Open;
      if not gdcExplorer.Eof then
        gdcExplorer.Delete;
    finally
      gdcExplorer.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TgdcInvCardConfig.CreateSF;
var
  gdcFunction: TgdcFunction;
  SQL: TIBSQL;
const
  cFunctionBody =
    'Sub %s '#13 +
    '  Dim ConfigKey '#13 +
    '  Set Creator = New TCreator '#13 +
    '  Set F = Designer.CreateObject(Application, "%s", "") '#13 +
    '  ConfigKey = gdcBaseManager.GetIdByRuidString("%s") '#13 +
    '  F.FindComponent("cmbConfig").CurrentKeyInt = ConfigKey '#13 +
    '  F.FindComponent("actShowCard").Execute '#13 +
    'End Sub';
begin
  if FieldByName('showinexplorer').AsInteger <> 1 then
    DeleteSF
  else
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := ReadTransaction;
      SQL.SQl.Text := 'SELECT id FROM gd_function WHERE name = ''' +
        Format(cFunctionName, [RUIDToStr(GetRUID)]) + '''';
      SQL.ExecQuery;
      gdcFunction := TgdcFunction.Create(nil);
      try
        gdcFunction.Transaction := Transaction;
        gdcFunction.ReadTransaction := ReadTransaction;
        gdcFunction.SubSet := 'ByID';
        gdcFunction.Id := SQL.FieldByName('Id').AsInteger;
        gdcFunction.Open;
        gdcFunction.Edit;
        try
          gdcFunction.FieldByName(fnName).AsString := Format(cFunctionName, [RUIDToStr(GetRUID)]);
          gdcFunction.FieldByName(fnModule).AsString := scrUnkonownModule;
          gdcFunction.FieldByName(fnModuleCode).AsInteger := OBJ_APPLICATION;
          gdcFunction.FieldByName(fnScript).AsString := Format(cFunctionBody,
            [gdcFunction.FieldByName(fnName).AsString,
            GetGDVViewForm,
            RUIDToStr(GetRUID)]);
          gdcFunction.FieldByName(fnLanguage).AsString := DefaultLanguage;
          gdcFunction.Post;

          if ScriptFactory <> nil then
            ScriptFactory.ReloadFunction(gdcFunction.FieldByName(fnID).AsInteger);
        except
          gdcFunction.Cancel;
          raise;
        end;
        CreateCommand(gdcFunction.GetRUID);
      finally
        gdcFunction.Free;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TgdcInvCardConfig.DeleteSF;
var
  gdcFunction: TgdcFunction;
  SQL: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := ReadTransaction;
    SQl.SQl.Text := 'SELECT id FROM gd_function WHERE name = ''' +
      Format(cFunctionName, [RUIDToStr(GetRUID)]) + '''';
    SQL.ExecQuery;
    if SQL.FieldByName('id').AsInteger > 0 then begin
      gdcFunction := TgdcFunction.Create(nil);
      try
        gdcFunction.Transaction := Transaction;
        gdcFunction.ReadTransaction := ReadTransaction;
        gdcFunction.SubSet := 'ByID';
        gdcFunction.Id := SQL.FieldByName('Id').AsInteger;
        gdcFunction.Open;
        DeleteCommand(gdcFunction.GetRUID);
        gdcFunction.Delete;
      finally
        gdcFunction.Free;
      end;
    end;
  finally
    SQL.Free;
  end;
end;

function TgdcInvCardConfig.GetGDVViewForm: string;
begin
  Result := 'Tgdv_frmInvCard'
end;

procedure TgdcInvCardConfig.DoAfterCustomProcess(Buff: Pointer;
  Process: TgsCustomProcess);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_DOAFTERCUSTOMPROCESS('TGDCINVCARDCONFIG', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCINVCARDCONFIG', KEYDOAFTERCUSTOMPROCESS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOAFTERCUSTOMPROCESS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCINVCARDCONFIG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self),
  {M}          Integer(Buff), TgsCustomProcess(Process)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCINVCARDCONFIG',
  {M}          'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCINVCARDCONFIG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
                                        
  if Process = cpDelete then
    DeleteSF
  else
    CreateSF;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCINVCARDCONFIG', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCINVCARDCONFIG', 'DOAFTERCUSTOMPROCESS', KEYDOAFTERCUSTOMPROCESS);
  {M}  end;
  {END MACRO}
end;

function TgdcInvCardConfig.GetIPCount: integer;
var
  S: TStrings;
  I: Integer;
begin
  Result:= 0;
  S := TStringList.Create;
  try
    if Config.GoodValue = cInputParam then
      Result:= 1;
    if Config.DeptValue = cInputParam then
      Inc(Result);

    S.Text := Config.CardValues;
    for I := 0 to S.Count - 1 do begin
      if S.Values[S.Names[I]] = cInputParam then
      Inc(Result);
    end;

    S.Text := Config.GoodValues;
    for I := 0 to S.Count - 1 do begin
      if S.Values[S.Names[I]] = cInputParam then
      Inc(Result);
    end;
  finally
    S.Free;
  end;
end;

initialization
  RegisterGdcClass(TgdcInvBaseRemains);
  RegisterGdcClass(TgdcInvRemains);
  RegisterGdcClass(TgdcInvGoodRemains);
  RegisterGdcClass(TgdcInvMovement);
  RegisterGdcClass(TgdcInvCard);
{  RegisterGdcClass(TgdcInvCardFull);}
  RegisterGdcClass(TgdcInvRemainsOption);
  RegisterGdcClass(TgdcInvCardConfig);

finalization
  UnRegisterGdcClass(TgdcInvBaseRemains);
  UnRegisterGdcClass(TgdcInvRemains);
  UnRegisterGdcClass(TgdcInvGoodRemains);
  UnRegisterGdcClass(TgdcInvMovement);
  UnRegisterGdcClass(TgdcInvCard);
{  UnRegisterGdcClass(TgdcInvCardFull);}
  UnRegisterGdcClass(TgdcInvRemainsOption);
  UnRegisterGdcClass(TgdcInvCardConfig);

end.

