
unit evt_Base;

interface

uses
  Classes, evt_i_Base, rp_BaseReport_unit, IBDatabase, Contnrs, Db, TypInfo,
  SysUtils, scr_i_FunctionList, Windows, Comctrls, Controls, menus, Actnlist,
  Gedemin_TLB, forms, Messages, stdctrls, rp_report_const,
  dbgrids, grids, gsDBGrid, IBCustomDataSet, gdcBase, gd_DebugLog, gd_KeyAssoc,
  gdc_dlgG_unit, TB2Item;

const
  GD_TEMPPATH = 'Temp\';

type
  TSFStreamState = (sfsCreated, sfsFailed, sfsBlocked, sfsUnassigned);

  TSFStreamDesc = record
    DBIB: Integer;
    DBPath: String[255];
    ServerName: String[24];
    SFModifyID: Integer;
    UseDebugInfo: Boolean;
    StreamVertion: Integer;
  end;

  TgsFunctionList = class(TComponent, IScriptFunctions)
  private
    FSortFuncList: TgdKeyObjectAssoc;
    {$IFDEF DEBUG}
    FSFLoadTime: TStrings;
    {$ENDIF}


    // Свойства для работы с файл-кэшем СФ
    // Список указателей позиций СФ в файл-кэше
    FSFDHandleList: TgdKeyIntAssoc;
    // Поток файл-кэша
    FSFStream: TFileStream;
    // Поток указателей файл-кэша
    FSFHandleStream: TFileStream;
    // Полное имя файла файл-кэша
    FSFDFileName: String;
    // Полное имя файла указателей файл-кэша
    FSFDHandleName: String;
    // Текущий статус файл-кэша
    FSFStreamState: TSFStreamState;
    // Системная информация подключения
    FSFStreamDesc: TSFStreamDesc;

    // Создает ф-цию, заполняет ее и возвращает
    function AddFromDataSet(AnDataSet: TDataSet): TrpCustomFunction;
    // Создает файловые потоки для работы с файл-кэшем СФ
    function CreateSFDHandleList: Boolean;
//    function  CreateSFStream: Boolean;
    // Возвращает СФ из файл-кэша
    function ReadSFFromStream(const AnFunctionKey: Integer): TrpCustomFunction;
    // Удаляет файлы файл-кэша
    function DeleteSFFiles: Boolean;

    // Добавляет СФ в гл. список
    procedure AddFunction(
      const AnFunction: TrpCustomFunction);
    // Обработчик события OnBreakPointsPrepared СФ
    // Добавляет инф-цию с файл-кэш
    procedure OnBreakPointsPrepared(Sender: TObject);

  protected
    function Get_Self: TObject;
    //Поиск в списке по ключу функции
//    function IndexOf(const AnFunctionKey: Integer): Integer;
    function FindFunctionWithoutDB(const AnFunctionKey: Integer): TrpCustomFunction;
    function FindFunctionInDB(const AnFunctionKey: Integer): TrpCustomFunction;
    function FindFunction(const AnFunctionKey: Integer): TrpCustomFunction;
    function ReleaseFunction(AnFunction: TrpCustomFunction): Integer;
    function  UpdateList: Boolean;
    // Удаляет ф-цию, чистит файл кэша
    procedure RemoveFunction(const AnFunctionKey: Integer);


    function Get_Function(Index: Integer): TrpCustomFunction;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;

    procedure Clear;
    procedure Drop;
//    function IndexOf(F: TrpCustomFunction): Integer;

    property Items[Index: Integer]: TrpCustomFunction read Get_Function;
  end;

  function CompareItems(Item1, Item2: Pointer): Integer;

const
  strStartObject = 'SOS';
  strEndObject = 'EOS';
  strStartObjList = 'SOLS';
  strEndObjList = 'EOLS';

type
//  TFuncParamLang = (fplDelphi, fplJScript, fplVBScript);

  // Класс для хранения данных функциию.
  // Предназначен для связи делфовских данных и данных из БД
  TCustomFunctionItem = class
  private
    FDisable: Boolean;
    FOldFunctionKey: Integer;
    procedure SetDisable(const Value: Boolean);
    procedure SetName(const Value: String);
    procedure SetFunctionKey(const Value: Integer);
  protected
    // Локализованное наименование
    // Для события - наименование события
    // Для метода - наименование перекрываемого метода
    FCustomName: String;
    // Ключ функции
    FFunctionKey: Integer;

    function GetComplexParams(const AnLang: TFuncParamLang;
      const FunctionName: String = ''): String; virtual; abstract;
//    function GetComplexParams(const AnLang: TFuncParamLang): String; virtual; abstract;
    function GetParams(const AnLang: TFuncParamLang): String; virtual; abstract;
    function GetParamCount: Integer; virtual; abstract;
    function GetObjectName: String; virtual; abstract;
  public
    // Возвращает шаблон пустой функции в зависимости от языка
//    property ComplexParams[const AnLang: TFuncParamLang]: String read GetComplexParams;
    function ComplexParams(
      const AnLang: TFuncParamLang; const FunctionName: String = ''): String;
    // Возвращает строку параметров с разделителем и типом в зависимости от языка
    property Params[const AnLang: TFuncParamLang]: String read GetParams;
    // Количество параметров
    property ParamCount: Integer read GetParamCount;
    property Name: String read FCustomName write SetName;
    // Наименование объекта которому принадлежит функция
    property ObjectName: String read GetObjectName;
//    property FunctionKey: Integer read FFunctionKey write FFunctionKey default 0;
    property FunctionKey: Integer read FFunctionKey write SetFunctionKey;
    property OldFunctionKey: Integer read FOldFunctionKey write FOldFunctionKey default 0;
    // поле указывает используется скрипт-метод для метода или нет
    property Disable: Boolean read FDisable write SetDisable default True;
  end;

  TEventObject = class;

  // Класс для хранения информации по ивентам
  TEventItem = class(TCustomFunctionItem)
  private
    //Хранит информ. о старом обработчике событий
    FOldEvent: TMethod;
    FIsOldEventSet: Boolean;
    FObject: TEventObject;
    FEventID: Integer;

    function GetDelphiParamString(const LocParamCount: Integer;
      const LocParams: array of Char; const AnLang: TFuncParamLang;
      out AnResultParam: String): String;
    procedure SetOldEvent(const Value: TMethod);
    procedure SetEventID(const Value: Integer);
    // Сохраняет для существующего в БД EventItem изменения
    procedure SaveChangeInDB(AnDatabase: TIBDatabase);

    procedure Reset;
  protected
    FEventData: PTypeData;
    function GetParams(const AnLang: TFuncParamLang): String; override;
    function GetParamCount: Integer; override;
    function GetComplexParams(const AnLang: TFuncParamLang;
      const FunctionName: String = ''): String; override;
    property IsOldEventSet: Boolean read FIsOldEventSet default False;
    function GetObjectName: String; override;
  public
    procedure Assign(ASource: TEventItem);
    function AutoFunctionName: String;

    // Старый обработчик события
    property OldEvent: TMethod read FOldEvent write SetOldEvent;
    // Указатель на стуктуру TTypeData для события
    property EventData: PTypeData read FEventData write FEventData;
    property EventObject: TEventObject read FObject write FObject;
    property EventID: Integer read FEventID write SetEventID;
  end;

  // Класс для хранения списка присвоенных ивентов
  TEventList = class(TObjectList)
  private
    function GetEventName(Index: Integer): String;
    function GetFunc(Index: Integer): Integer;
    function GetItem(Index: Integer): TEventItem;
    function GetMethod(Index: Integer): TMethod;
    procedure SetEventName(Index: Integer; const Value: String);
    procedure SetFunc(Index: Integer; const Value: Integer);
    procedure SetMethod(Index: Integer; const Value: TMethod);
    function GetNameItem(const AName: String): TEventItem;
  public
    function Add(const ASource: TEventItem): Integer; overload;
    function Add(const AName: String; const AFuncKey: Integer): Integer; overload;
    function Last: TEventItem;
    procedure Assign(ASource: TEventList);
    function Find(const AName: String): TEventItem;

    procedure DeleteForName(const AName: String);

    property Items[Index: Integer]: TEventItem read GetItem; default;
    property ItemByName[const AName: String]: TEventItem read GetNameItem;
    property Name[Index: Integer]: String read GetEventName write SetEventName;
    property OldMethod[Index: Integer]: TMethod read GetMethod write SetMethod;
    property EventFunctionKey[Index: Integer]: Integer read GetFunc write SetFunc;
  end;

  // Класс для хранения зарегистрированных в БД объектов.
  // Осуществляет связь между БД и делфовскими объектами.
  TEventObjectList = class;

  // Класс хранит данные по одному объекту
  TEventObject = class
  private
    FObjectKey: Integer;
    FObjectName: String;
    FChildObjects: TEventObjectList;
    FObjectClassType: TClass;
    FEventList: TEventList;
    FParentList: TEventObjectList;
    FSelfObject: TComponent;
//    FHasSpecEvent: Boolean;
    FSpecEventCount: Integer;

    FObjectRef: TComponent;

//    procedure SetHasSpecEvent(const Value: Boolean);
    procedure SetSpecEventCount(const Value: Integer);
    procedure SetObjectRef(const Value: TComponent);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(Source: TEventObject);

    procedure SaveToStream(AnStream: TStream);
    procedure LoadFromStream(AnStream: TStream);

    property ObjectClassType: TClass read FObjectClassType write FObjectClassType;
    property ObjectKey: Integer read FObjectKey write FObjectKey;
    property ObjectName: String read FObjectName write FObjectName;
    property ChildObjects: TEventObjectList read FChildObjects;
    property EventList: TEventList read FEventList write FEventList;
    property ParentList: TEventObjectList read FParentList write FParentList;
    property SelfObject: TComponent read FSelfObject write FSelfObject;
    //Показывает наличие опред. эвентов
//    property HasSpecEvent: Boolean read FHasSpecEvent write SetHasSpecEvent;
    property SpecEventCount: Integer read FSpecEventCount write SetSpecEventCount;
    property ObjectRef: TComponent read FObjectRef write SetObjectRef;
  end;

  TEventObjectList = class(TObjectList)
//  TEventObjectList = class(TStringList)
  private
    // массив хранящий динамические объекты и их обработчики
    FDinamicEventArray: TgdKeyObjectAssoc;

    function  AddDinamicObject(const SourceEventObject: TEventObject; Acceptor: TComponent): Boolean;
    function  GetEventObject(Index: Integer): TEventObject;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear; override;
    procedure Assign(Source: TEventObjectList);
    function AddObject(const AnObject: TEventObject): Integer;

    function  AddDinamicEventObject(const Source, Acceptor: TComponent): Boolean; overload;
    function  AddDinamicEventObject(const SourceName: String; Acceptor: TComponent): Boolean; overload;
    procedure RemoveDinamicObject(const AnObject: TObject);

//    procedure LoadFromDatabase(AnDatabase: TIBDatabase;
//     AnTransaction: TIBTransaction; const AnParent: Variant);
    procedure LoadFromDatabaseOpt(AnDatabase: TIBDatabase;
     AnTransaction: TIBTransaction; const AnParent: Variant);

    procedure LoadFromStream(AnStream: TStream);
    procedure SaveToStream(AnStream: TStream);
    function Last: TEventObject;
    function FindObject(const AnName: String): TEventObject; overload;
    function FindObject(const AnObject: TObject): TEventObject; overload;
    function FindObject(const AnObjectKey: Integer): TEventObject; overload;
    function FindAllObject(const AnName: String): TEventObject; overload;
    function FindAllObject(AObject: TComponent): TEventObject; overload;
    function FindAllObject(const AnObjectKey: Integer): TEventObject; overload;
    function FindObjectAndIndex(AObject: TComponent;
      out DynArrayIndex: Integer): TEventObject;

    property EventObject[Index: Integer]: TEventObject read GetEventObject;
  end;

const
  cClickEventName       = 'ONCLICK';
  // Event from PopupMenu
  cPopupEventName       = 'ONPOPUP';
  cCanResizeEventName   = 'ONCANRESIZE';
  cCreateEventName      = 'ONCREATE';

  //DAlex
  // Event for TControl
  cConstrainedResizeEventName    = 'ONCONSTRAINEDRESIZE';
  cContextPopupEventName= 'ONCONTEXTPOPUP';
  cDblClickEventName    = 'ONDBLCLICK';
  cDragDropEventName    = 'ONDRAGDROP';
  cDragOverEventName    = 'ONDRAGOVER';
  cEndDockEventName     = 'ONENDDOCK';
  cEndDragEventName     = 'ONENDDRAG';
  cMouseDownEventName   = 'ONMOUSEDOWN';
  cMouseMoveEventName   = 'ONMOUSEMOVE';
  cMouseUpEventName     = 'ONMOUSEUP';
  cResizeEventName      = 'ONRESIZE';
  cStartDockEventName   = 'ONSTARTDOCK';
  cStartDragEventName   = 'ONSTARTDRAG';
  // Events from TWinControl
  cDockDropEventName    = 'ONDOCKDROP';
  cDockOverEventName    = 'ONDOCKOVER';
  cEnterEventName       = 'ONENTER';
  cExitEventName        = 'ONEXIT';
  cGetSiteInfoEventName = 'ONGETSITEINFO';
  cKeyDownEventName     = 'ONKEYDOWN';
  cKeyPressEventName    = 'ONKEYPRESS';
  cKeyUpEventName       = 'ONKEYUP';
  cMouseWheelEventName  = 'ONMOUSEWHEEL';
  cMouseWheelDownEventName = 'ONMOUSEWHEELDOWN';
  cMouseWheelUpEventName= 'ONMOUSEWHEELUP';
  cUnDockEventName      = 'ONUNDOCK';
  // Events from TCustomForm
  cActivateEventName    = 'ONACTIVATE';
  cCloseEventName       = 'ONCLOSE';
  cCloseNotifyEventName = 'ONCLOSENOTIFY';
  cCloseQueryEventName  = 'ONCLOSEQUERY';
  cDeactivateEventName  = 'ONDEACTIVATE';
  cDestroyEventName     = 'ONDESTROY';
  cHideEventName        = 'ONHIDE';
  cPaintEventName       = 'ONPAINT';
  cShowEventName        = 'ONSHOW';
  // Events from TMenu
  cChangeEventName      = 'ONCHANGE';
  // Events from TTabControl
//  cChangeTabEventName      = 'ONCHANGETAB';
  cChangingEventName      = 'ONCHANGING';
  // Events from TCustomEdit
  cChangeEditEventName  = 'ONCHANGEEDIT';
  // Evants from TCustomTreeView
  cChangeTVEventName      = 'ONCHANGETV';
  cChangingTVEventName      = 'ONCHANGINGTV';

  // Events from TCustomListBox
  cDrawItemEventName    = 'ONDRAWITEM';
  cMeasureItemEventName = 'ONMEASUREITEM';
  // Events from TCheckListBox
  cClickCheckListBoxEventName = 'ONCLICKCHECKLISTBOX';
  // Events from TCustomComboBox
  cDropDownEventName    = 'ONDROPDOWN';
  // Events from TScrollBar
  cScrollEventName      = 'ONSCROLL';
  // Events from TCustomActionList
  cExecuteEventName     = 'ONEXECUTE';
  cUpdateEventName      = 'ONUPDATE';
  // Events from TBasicAction
  cExecuteActionEventName = 'ONEXECUTEACTION';
  cUpdateActionEventName      = 'ONUPDATEACTION';
  // Events from TTBToolbar
  cTBPopupEventName     = 'ONTBPOPUP';
  cMoveEventName        = 'ONMOVE';
  cRecreatedEventName   = 'ONRECREATED';
  cRecreatingEventName  = 'ONRECREATING';
  cDockChangedEventName = 'ONDOCKCHANGED';
  cDockChangingEventName= 'ONDOCKCHANGING';
  cDockChangingHiddenEventName   = 'ONDOCKCHANGINGHIDDEN';
  cVisibleChangedEventName       = 'ONVISIBLECHANGED';
  // Events from TCustomDBGrid
  cColEnterEventName             = 'ONCOLENTER';
  cColExitEventName              = 'ONCOLEXIT';
  cColumnMovedEventName          = 'ONCOLUMNMOVED';
  cDrawColumnCellEventName       = 'ONDRAWCOLUMNCELL';
  cDrawDataCellEventName         = 'ONDRAWDATACELL';
  cEditButtonClickEventName      = 'ONEDITBUTTONCLICK';
  cCellClickEventName      = 'ONCELLCLICK';
  // Events from TgsCustomDBGrid
  cAggregateChangedEventName     = 'ONAGGREGATECHANGED';
  cClickCheckEventName           = 'ONCLICKCHECK';
  cClickedCheckEventName         = 'ONCLICKEDCHECK';
  // Events from TDataSet
  cAfterCancelEventName  = 'AFTERCANCEL';
  cAfterCloseEventName   = 'AFTERCLOSE';
  cAfterDeleteEventName  = 'AFTERDELETE';
  cAfterEditEventName    = 'AFTEREDIT';
  cAfterInsertEventName  = 'AFTERINSERT';
  cAfterOpenEventName    = 'AFTEROPEN';
  cAfterPostEventName    = 'AFTERPOST';
  cAfterRefreshEventName = 'AFTERREFRESH';
  cAfterScrollEventName  = 'AFTERSCROLL';
  cBeforeCancelEventName = 'BEFORECANCEL';
  cBeforeCloseEventName  = 'BEFORECLOSE';
  cBeforeDeleteEventName = 'BEFOREDELETE';
  cBeforeEditEventName   = 'BEFOREEDIT';
  cBeforeInsertEventName = 'BEFOREINSERT';
  cBeforeOpenEventName   = 'BEFOREOPEN';
  cBeforePostEventName   = 'BEFOREPOST';
  cBeforeScrollEventName = 'BEFORESCROLL';
  cCalcFieldsEventName   = 'ONCALCFIELDS';
  cDeleteErrorEventName  = 'ONDELETEERROR';
  cEditErrorEventName    = 'ONEDITERROR';
  cFilterRecordEventName = 'ONFILTERRECORD';
  cNewRecordEventName    = 'ONNEWRECORD';
  cPostErrorEventName    = 'ONPOSTERROR';

  cAfterInternalPostRecordEventName = 'AFTERINTERNALPOSTRECORD';
  cBeforeInternalPostRecordEventName = 'BEFOREINTERNALPOSTRECORD';
  cAfterInternalDeleteRecordEventName = 'AFTERINTERNALDELETERECORD';
  cBeforeInternalDeleteRecordEventName = 'BEFOREINTERNALDELETERECORD';

  // Events from TIBCustomDataSet
  cAfterDatabaseDisconnectEventName = 'AFTERDATABASEDISCONNECT';
  cAfterTransactionEndEventName     = 'AFTERTRANSACTIONEND';
  cBeforeDatabaseDisconnectEventName= 'BEFOREDATABASEDISCONNECT';
  cBeforeTransactionEndEventName    = 'BEFORETRANSACTIONEND';
  cDatabaseFreeEventName            = 'DATABASEFREE';
  cUpdateErrorEventName             = 'ONUPDATEERROR';
  cUpdateRecordEventName            = 'ONUPDATERECORD';
  cTransactionFreeEventName         = 'TRANSACTIONFREE';
  cOnCalcAggregatesEventName        = 'ONCALCAGGREGATES';
  // Events from TIBDataSet
  cDatabaseDisconnectedEventName    = 'DATABASEDISCONNECTED';
  cDatabaseDisconnectingEventName   = 'DATABASEDISCONNECTING';

  // Events from gdcBase
  cAfterInitSQLEventName     = 'ONAFTERINITSQL';
  cFilterChangedEventName    = 'ONFILTERCHANGED';
  cBeforeShowDialogEventName = 'BEFORESHOWDIALOG';
  cAfterShowDialogEventName  = 'AFTERSHOWDIALOG';
  cOnGetSelectClauseEventName = 'ONGETSELECTCLAUSE';
  cOnGetFromClauseEventName   = 'ONGETFROMCLAUSE';
  cOnGetWhereClauseEventName  = 'ONGETWHERECLAUSE';
  cOnGetGroupClauseEventName  = 'ONGETGROUPCLAUSE';
  cOnGetOrderClauseEventName  = 'ONGETORDERCLAUSE';



  // Event from TDataSource
  cDataChangeEventName       = 'ONDATACHANGE';
  cStateChangeEventName      = 'ONSTATECHANGE';
  cUpdateDataEventName       = 'ONUPDATEDATA';
  // Events from gsIBLookupComboBox
  cCreateNewObjectEventName  = 'ONCREATENEWOBJECT';
  cAfterCreateDialogEventName= 'ONAFTERCREATEDIALOG';
  // Events from TgsSQLFilter
  cConditionChangedEventName = 'ONCONDITIONCHANGED';
  cFilterChangedSQLFilterEventName    = 'ONFILTERCHANGEDSQLFILTER';
  // Events from TTimer
  cTimerEventName            = 'ONTIMER';
  // Events from TOnGetFooter
  cGetFooterEventName      = 'ONGETFOOTER';
  // Events from TOnGetTotal
  cGetTotalEventName       = 'ONGETTOTAL';
  // Events from Tgdc_dlgG
  cSyncFieldEventName      = 'ONSYNCFIELD';
  cTestCorrectEventName    = 'ONTESTCORRECT';
  cSetupRecordEventName    = 'ONSETUPRECORD';
  cSetupDialogEventName    = 'ONSETUPDIALOG';

  // Events from TField
  cGetTextEventName        = 'ONGETTEXT';
  cSetTextEventName        = 'ONSETTEXT';
  cValidateEventName       = 'ONVALIDATE';

  // Events from TgsModem
  cModemSendEventName      = 'ONSEND';
  cModemReceiveEventName   = 'ONRECEIVE';
  cModemOpenPortEventName  = 'ONOPENPORT';
  cModemClosePortEventName = 'ONCLOSEPORT';
  cModemErrorEventName     = 'ONERROR';

  // Events from TCreateableForm
  cSaveSettingsEventName = 'ONSAVESETTINGS';
  cLoadSettingsAfterCreateEventName = 'ONLOADSETTINGSAFTERCREATE';

  // TWebBrowser
  cWebBrowserBeforeNavigate2Name = 'ONBEFORENAVIGATE2';
  cWebBrowserDocumentCompleteName = 'ONDOCUMENTCOMPLETE';

  //!DAlex

  cMsgCantFindObject    = 'TEventControl: Не найден объект вызвавший событие!!!';

// Класс для работы с событиями
// Компонента создаетчся одна на проект
// Связь осуществляется через интерфейс
type
  TObjectFlag = record
    Name: String;
    Flag: Boolean;
  end;

  TEventControl = class(TComponent, IEventControl)
  private
    FKnownEventList: TStrings;                  // Известные события
    FEventObjectList: TEventObjectList;         // Список объектов с событиями

    FDatabase: TIBDatabase;                     // Датабэйз. Задается из вне
    FTransaction: TIBTransaction;               // Транзакция. Создается внутри

    FVarParamEvent: TVarParamEvent;
    FReturnVarParamEvent: TVarParamEvent;

    FPaintFlag: TObjectFlag;
    FGetFooterFlag: TObjectFlag;

    FPropertyDisableCount: Integer;
    FEventList: TStrings;
    FgdcReportGroupList: TgdKeyArray;

    //Список классов поддержки TRect
    FRectList:  TgdKeyIntAssoc;
    //Список классов поддержки TPoint
    FPointList:  TgdKeyIntAssoc;
    //
    FRecursionDepth: Integer;

    //Список TEvetObject-ов созданных для обработки событий компонентов, созданных динамически
    FDynamicCreatedEventObjects: TObjectList;

    procedure SetDatabase(const AnDatabase: TIBDatabase);

    function  SetSingleEvent(const AnComponent: TComponent;
      const AnEventName: String; const AHandlerMethod: Pointer): Boolean;

    procedure FillEventList;
    // присваивает перекрытые обработчики событий
    procedure SetComponentEvent(const AnComponent: TComponent;
      const AnEventObject: TEventObject; const OnlyComponent: Boolean;
      const AnSafeMode: Boolean);
    procedure SetChildComponentEvent(const AnComponent: TComponent;
      const AnEventObject: TEventObject; const AnSafeMode: Boolean);
    procedure ResetComponentEvent(const AnComponent: TComponent;
      const AnEventObject: TEventObject);
    procedure ResetChildComponentEvent(const AnComponent: TComponent;
      const AnEventObject: TEventObject);
    function ExecuteEvent(const EventItem: TEventItem; var AnParams: Variant;
      Sender: TObject; const EventName: String): Variant;

    function GetVarInterface(const AnValue: Variant): OleVariant;
    function GetVarParam(const AnValue: Variant): OleVariant;
    function GetReturnVarParamEvent: TVarParamEvent;
    function GetVarParamEvent: TVarParamEvent;
    procedure CheckCreateForm;

    // используется для
    procedure AssignEvents(const Source, Acceptor: TComponent); overload;
    procedure AssignEvents(const SourceName: String; Acceptor: TComponent); overload;
    function GetPropertyCanChangeCaption: Boolean;
    procedure SetPropertyCanChangeCaption(const Value: Boolean);

    procedure ResetAllEvents(ObjectList: TEventObjectList);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    // Установка событий для дочерних компоненты
    procedure SetChildEvents(AnComponent: TComponent);
    // Установка событий для компоненты
    // Использовать ТОЛЬКО если надо установить
    // события для дорерних компонент, при условии что
    // события на часть дочерних компонент уже установлена
    procedure SafeCallSetEvents(AnComponent: TComponent);

    // Снятие событий для дочерних компонент
    procedure ResetChildEvents(AnComponent: TComponent);
    procedure RebootEvents(AnComponent: TComponent);

    function Get_KnownEventList: TStrings;
    function Get_Self: TObject;
    function ObjectEventList(const AnComponent: TComponent;
     AnEventList: TStrings): Boolean;
    // Вызов окна редактирования для всех свойств
    procedure GoToClassMethods(const AClassName, ASubType: string);
    procedure EditObject(const AnComponent: TComponent;
     const EditMode: TEditMode = emNone; const AnName: String = '';
     const AnFunctionID: integer = 0);
    //Уведомляет окно свойств об изменениях в системе
    procedure PropertyNotification(AComponent: TComponent;
      Operation: TPrpOperation; const AOldName: string = '');
    procedure PropertyUpDateErrorsList;
    procedure DisableProperty;
    procedure EnableProperty;
    function IsPropertyVisible: boolean;
    function GetProperty: TCustomForm;
    procedure PrepareSOEditorForModal;

    procedure DebugScriptFunction(const AFunctionKey: Integer;
      const AModuleName: string = scrUnkonownModule;
      const CurrentLine: Integer = - 1);

    //Редактирование отчета
    procedure EditReport(IDReportGroup, IDReport: Integer);

    procedure LoadBranch(const AnObjectKey: Integer);
    //
    function EditScriptFunction(var AFunctionKey: Integer): Boolean;
    // Инициализация
    procedure LoadLists;
    function Get_PropertyIsLoaded: Boolean;
    function PropertyClose: Boolean;
    function GetPropertyHanlde: THandle;
    procedure DeleteEvent(FormName, ComponentName, EventName: string);
    procedure EventLog;
//    procedure ReportRefresh;
    procedure RegisterFrmReport(frmReport: TObject);
    procedure UnRegisterFrmReport(frmReport: TObject);
    procedure UpdateReportGroup;
//    procedure ChangeReport(
//      const ReportObject: TObject; const ChangeType: TChangeReportType);
//    procedure DeleteReportGroup(
//      const ParendID, ID: Integer; const ChangeType: TChangeReportType);
//    procedure DeleteReport(
//      const ParentID, ID: Integer; const ChangeType: TChangeReportType);

    property PropertyCanChangeCaption: Boolean read GetPropertyCanChangeCaption
      write SetPropertyCanChangeCaption;
    function AddDynamicCreatedEventObject(AnComponent: TComponent): integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Методы интерфейса
    procedure ResetEvents(AnComponent: TComponent);
    procedure SetEvents(AnComponent: TComponent;
     const OnlyComponent: Boolean = False);
//    procedure OversetEvents(AnComponent: TComponent);

    procedure GetParamInInterface(AVarInterface: IDispatch; AParam: OleVariant);

    procedure Drop;

    {1)TEventControl имеет свойство:
    property EventObjectList: TEventObjectList read FEventObjectList
      write FEventObjectList;

При этом в деструкторе класса выполняется
    FreeAndNil(FEventObjectList);

Если свойство EventObjectList может быть присвоено извне, то какое мы имеем право уничтожать его при уничтожении класса?
}
{    property EventObjectList: TEventObjectList read FEventObjectList
      write FEventObjectList;                                        }
    property EventObjectList: TEventObjectList read FEventObjectList;
    function FindRealEventObject(AnComponent: TComponent; const AName: TComponentName = ''): TEventObject; overload;

  published
    property Database: TIBDatabase read FDatabase write SetDatabase;
    property OnVarParamEvent: TVarParamEvent read GetVarParamEvent write FVarParamEvent;
    property OnReturnVarParam: TVarParamEvent read GetReturnVarParamEvent
      write FReturnVarParamEvent;

    // Известные события
    // TNotifyEvent: OnClick
    procedure OnClick(Sender: TObject);
    // TNotifyEvent: OnPopup
    procedure OnPopup(Sender: TObject);
    // TCanResizeEvent: OnCanResize
    procedure OnCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    // TNotifyEvent: OnCreate
    procedure OnCreate(Sender: TObject);

    {!!! Events from TTBCustomItem !!!}
    // TTBPopupEvent
    procedure OnTBPopup(Sender: TTBCustomItem; FromLink: Boolean);

    //DAlex
    {!!! Events from TControl !!!}
    //  TConstrainedResizeEvent
    procedure OnConstrainedResize(Sender: TObject; var MinWidth, MinHeight,
      MaxWidth, MaxHeight: Integer);
    // TContextPopupEvent
    procedure OnContextPopup(Sender: TObject;
      MousePos: TPoint; var Handled: Boolean);
    // TNotifyEvent
    procedure OnDblClick(Sender: TObject);
    // TDragDropEvent
    procedure OnDragDrop(Sender, Source: TObject; X, Y: Integer);
    // TDragOverEvent
    procedure OnDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    // TEndDragEvent
    procedure OnEndDock(Sender, Target: TObject; X, Y: Integer);
    // TEndDragEvent
    procedure OnEndDrag(Sender, Target: TObject; X, Y: Integer);
    // TMouseEvent
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    // TMouseMoveEvent
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    // TMouseEvent
    procedure OnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    // TNotifyEvent
    procedure OnResize(Sender: TObject);
    // TStartDockEvent
    procedure OnStartDock(Sender: TObject; var DragObject: TDragDockObject);
    // TStartDragEvent
    procedure OnStartDrag(Sender: TObject; var DragObject: TDragObject);

    {!!! Events from TWinControl !!!}
    // TDockDropEvent
    procedure OnDockDrop(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer);
    // TDockOverEvent
    procedure OnDockOver(Sender: TObject; Source: TDragDockObject;
      X, Y: Integer; State: TDragState; var Accept: Boolean);
    // TNotifyEvent
    procedure OnEnter(Sender: TObject);
    // TNotifyEvent
    procedure OnExit(Sender: TObject);
    // TGetSiteInfoEvent
//    procedure OnGetSiteInfo(Sender: TObject; DockClient: TControl; var
//      InfluenceRect: TRect; MousePos: TPoint; var CanDock: Boolean);
    // TKeyEvent
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    // TKeyPressEvent
    procedure OnKeyPress(Sender: TObject; var Key: Char);
    // TKeyEvent
    procedure OnKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    // TMouseWheelEvent
    procedure OnMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    // TMouseWheelUpDownEvent
    procedure OnMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    // TMouseWheelUpDownEvent
    procedure OnMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    // TUnDockEvent
    procedure OnUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);

    {!!! Events from TCustomForm !!!}
    // TNotifyEvent
    procedure OnActivate(Sender: TObject);
    // TCloseEvent
    procedure OnClose(Sender: TObject; var Action: TCloseAction);

    // добавлен для TNotifyEvent (Тот же OnClose)
    procedure OnCloseNotify(Sender: TObject);

    // TCloseQueryEvent
    procedure OnCloseQuery(Sender: TObject; var CanClose: Boolean);
    // TNotifyEvent
    procedure OnDeactivate(Sender: TObject);
    // TNotifyEvent
    procedure OnDestroy(Sender: TObject);
    // TNotifyEvent
    procedure OnHide(Sender: TObject);
    // TNotifyEvent
    procedure OnPaint(Sender: TObject);
    // TNotifyEvent
    procedure OnShow(Sender: TObject);

    {!!! Events from TMenu !!!}
    // TMenuChangeEvent
    procedure OnChange(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);

    {!!! Events from TTabControl !!!}
    // TNotifyEvent
//    procedure OnChangeTab(Sender: TObject);
    // TTabChangingEvent
    procedure OnChanging(Sender: TObject; var AllowChange: Boolean);

    {!!! Events from TCustomEdit !!!}
    // TNotifyEvent
    procedure OnChangeEdit(Sender: TObject);

    {!!! Events from TCustomListBox !!!}
    // TDrawItemEvent
    procedure OnDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    // TMeasureItemEvent
    procedure OnMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);

    {!!! Events from TCustomTreeView !!!}
    // TTVChangedEvent
    procedure OnChangeTV(Sender: TObject; Node: TTreeNode);
    // TTVChangingEvent;
    procedure OnChangingTV(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);


    {!!! Events from TCheckListBox !!!}
    // TNotifyEvent
    procedure OnClickCheckListBox(Sender: TObject);


    {!!! Events from TCustomComboBox !!!}
    // TNotifyEvent
    procedure OnDropDown(Sender: TObject);

    {!!! Events from TScrollBar !!!}
    // TScrollEvent
    procedure OnScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);

    {!!! Events from TCustomActionList !!!}
    // TActionEvent
    procedure OnExecute(Action: TBasicAction; var Handled: Boolean);
    procedure OnUpdate(Action: TBasicAction; var Handled: Boolean);

    {!!! Events from TBasicAction!!!}
    // TNotifyEvent
    procedure OnExecuteAction(Sender: TObject);
    procedure OnUpdateAction(Sender: TObject);


    {!!! Events from TTBToolbar !!!}
    // TNotifyEvent
    procedure OnMove(Sender: TObject);
    // TNotifyEvent
    procedure OnRecreated(Sender: TObject);
    // TNotifyEvent
    procedure OnRecreating(Sender: TObject);
    // TNotifyEvent
    procedure OnDockChanged(Sender: TObject);
    // TNotifyEvent
    procedure OnDockChanging(Sender: TObject);
    // TNotifyEvent
    procedure OnDockChangingHidden(Sender: TObject);
    // TNotifyEvent
    procedure OnVisibleChanged(Sender: TObject);

    {!!! Events from TCustomDBGrid !!!}
    // TNotifyEvent
    procedure OnColEnter(Sender: TObject);
    // TNotifyEvent
    procedure OnColExit(Sender: TObject);
    // TMovedEvent
    procedure OnColumnMoved(Sender: TObject; FromIndex, ToIndex: Longint);
    // TDrawColumnCellEvent
    procedure OnDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    // TDrawDataCellEvent
    procedure OnDrawDataCell(Sender: TObject; const Rect: TRect;
      Field: TField; State: TGridDrawState);
    // TDBGridClickEvent
    procedure OnCellClick(Column: TColumn);
    // TNotifyEvent
    procedure OnEditButtonClick(Sender: TObject);
    // TOnGetFooter
    procedure OnGetFooter(Sender: TObject; const FieldName: String;
      const AggregatesObsolete: Boolean; var DisplayString: String);

    // TOnGetTotal
    procedure OnGetTotal(Sender: TObject; const FieldName: String;
      const AggregatesObsolete: Boolean; var DisplayString: String);

    {!!! Events from TgsCustomDBGrid !!!}
    // TNotifyEvent
    procedure OnAggregateChanged(Sender: TObject);
    // TCheckBoxEvent
    procedure OnClickCheck(Sender: TObject; CheckID: String;
      var Checked: Boolean);
    // TAfterCheckEvent
    procedure OnClickedCheck(Sender: TObject; CheckID: String;
      Checked: Boolean);

    {!!! Events from TDataSet !!!}
    // TDataSetNotifyEvent
    procedure AfterCancel(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure AfterClose(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure AfterDelete(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure AfterEdit(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure AfterInsert(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure AfterOpen(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure AfterPost(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure AfterRefresh(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure AfterScroll(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure BeforeCancel(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure BeforeClose(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure BeforeDelete(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure BeforeEdit(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure BeforeInsert(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure BeforeOpen(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure BeforePost(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure BeforeScroll(DataSet: TDataSet);
    // TDataSetNotifyEvent
    procedure OnCalcFields(DataSet: TDataSet);
    // TDataSetErrorEvent
    procedure OnDeleteError(DataSet: TDataSet; E: EDatabaseError; var
      Action: TDataAction);
    // TDataSetErrorEvent
    procedure OnEditError(DataSet: TDataSet; E: EDatabaseError; var
      Action: TDataAction);
    // TFilterRecordEvent
    procedure OnFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    // TDataSetNotifyEvent
    procedure OnNewRecord(DataSet: TDataSet);
    // TDataSetErrorEvent
    procedure OnPostError(DataSet: TDataSet; E: EDatabaseError; var
      Action: TDataAction);

    procedure AfterInternalPostRecord(DataSet: TDataSet);
    procedure BeforeInternalPostRecord(DataSet: TDataSet);
    procedure AfterInternalDeleteRecord(DataSet: TDataSet);
    procedure BeforeInternalDeleteRecord(DataSet: TDataSet);

    {!!! Events from TIBCustomDataSet !!!}
    // TNotifyEvent
    procedure AfterDatabaseDisconnect(Sender: TObject);
    // TNotifyEvent
    procedure AfterTransactionEnd(Sender: TObject);
    // TNotifyEvent
    procedure BeforeDatabaseDisconnect(Sender: TObject);
    // TNotifyEvent
    procedure BeforeTransactionEnd(Sender: TObject);
    // TNotifyEvent
    procedure DatabaseFree(Sender: TObject);
    // TIBUpdateErrorEvent
    procedure OnUpdateError(DataSet: TDataSet; E: EDatabaseError;
      UpdateKind: TUpdateKind; var UpdateAction: TIBUpdateAction);
    // TIBUpdateRecordEvent
    procedure OnUpdateRecord(DataSet: TDataSet; UpdateKind: TUpdateKind;
      var UpdateAction: TIBUpdateAction);
    // TNotifyEvent
    procedure TransactionFree(Sender: TObject);
    // TFilterRecordEvent
    procedure OnCalcAggregates(DataSet: TDataSet; var Accept: Boolean);


    {!!! Events from TIBDataSet !!!}
    // TNotifyEvent
    procedure DatabaseDisconnected(Sender: TObject);
    // TNotifyEvent
    procedure DatabaseDisconnecting(Sender: TObject);

    {!!! Events from TgdcBase !!!}
    // TgdcAfterInitSQL
    procedure OnAfterInitSQL(Sender: TObject;
      var SQLText: String; var isReplaceSQL: Boolean);
    // TNotifyEvent
    procedure OnFilterChanged(Sender: TObject);
    // TgdcDoBeforeShowDialog
    procedure BeforeShowDialog(Sender: TObject;
      DlgForm: TCustomForm);
    // TgdcDoAfterShowDialog
    procedure AfterShowDialog(Sender: TObject;
      DlgForm: TCustomForm; IsOk: Boolean);
    // TgdcOnGetSQLClause
    procedure OnGetSelectClause(Sender: TObject; var Clause: String);
    // TgdcOnGetSQLClause
    procedure OnGetFromClause(Sender: TObject; var Clause: String);
    // TgdcOnGetSQLClause
    procedure OnGetWhereClause(Sender: TObject; var Clause: String);
    // TgdcOnGetSQLClause
    procedure OnGetGroupClause(Sender: TObject; var Clause: String);
    // TgdcOnGetSQLClause
    procedure OnGetOrderClause(Sender: TObject; var Clause: String);

    {!!! Events from TDataSource !!!}
    // TDataChangeEvent
    procedure OnDataChange(Sender: TObject; Field: TField);
    // TNotifyEvent
    procedure OnStateChange(Sender: TObject);
    // TNotifyEvent
    procedure OnUpdateData(Sender: TObject);

    {!!! Events from TgsIBLookupComboBox !!!}
    // TOnCreateNewObject
    procedure OnCreateNewObject(Sender: TObject; ANewObject: TgdcBase);
    procedure OnAfterCreateDialog(Sender: TObject; ANewObject: TgdcBase);

    {!!! Events from  TgsSQLFilter !!!}
    // TConditionChanged
    procedure OnConditionChanged(Sender: TObject);
    // TFilterChanged
    procedure OnFilterChangedSQLFilter(Sender: TObject;
      const AnCurrentFilter: Integer);

    {!!! Events from TTimer !!!}
    // TNotifyEvent
    procedure OnTimer(Sender: TObject);

    {!!! Events from Tgdc_dlgG !!!}
    // TOnSyncFieldEvent
    procedure OnSyncField(Sender: TObject; Field: TField; SyncList: TList);
    // TOnTestCorrect
    function  OnTestCorrect(Sender: TObject): Boolean;
    // TOnSetupRecord
    procedure OnSetupRecord(Sender: TObject);
    // TOnSetupDialog
    procedure OnSetupDialog(Sender: TObject);


    {!!! Events from TField !!!}
    // TFieldGetTextEvent
    procedure OnGetText(Sender: TField; var Text: String; DisplayText: Boolean);
    // TFieldSetTextEvent
    procedure OnSetText(Sender: TField; const Text: String);
    // TFieldNotifyEvent
    procedure OnValidate(Sender: TField);

    {!!! Event from TCreateableForm !!!}
    // TNotifyEvent
    procedure OnSaveSettings(Sender: TObject);
    // TNotifyEvent
    procedure OnLoadSettingsAfterCreate(Sender: TObject);

    {!!! TWebBrowser !!!}
    procedure OnBeforeNavigate2(Sender: TObject;
      const pDisp: IDispatch;
      var URL: OleVariant;
      var Flags: OleVariant;
      var TargetFrameName: OleVariant;
      var PostData: OleVariant;
      var Headers: OleVariant;
      var Cancel: WordBool);

    procedure OnDocumentComplete(Sender: TObject;
      const pDisp: IDispatch;
      var URL: OleVariant);

//!Dalex
    // Modem
    procedure OnSend(Sender: TObject);
    procedure OnReceive(Sender: TObject; AFileName: String);
    procedure OnOpenPort(Sender: TObject);
    procedure OnClosePort(Sender: TObject);
    procedure OnError(Sender: TObject; ErrorCode: Integer; ErrorDescription: String);
  end;

// Эти функции нигде не используются
// Сохранение СтригЛиста вместе с поинтером
procedure SaveSLtoStreamEx(AnSL: TStrings; AnStream: TStream);
// Востановление СтригЛиста вместе с поинтером
procedure LoadSLfromStreamEx(AnSL: TStrings; AnStream: TStream);

function TShiftStateToStr(Value: TShiftState): String;

function StrToShiftState(Value: String): TShiftState;

function StrToTGridDrawState(Value: String): TGridDrawState;

function StrToTOwnerDrawState(Value: String): TOwnerDrawState;

procedure Register;

implementation

uses
  IB, IBSQL, IBQuery, gdcOLEClassList, rp_ReportScriptControl,
  gd_i_ScriptFactory, gd_SetDatabase,
  gsIBLookupComboBox, flt_sqlfilter_condition_type, prp_dlgScriptError_unit,
  gs_Exception, prp_Methods, gsResizerInterface{, obj_VarParam}, prp_frmEventLog_unit,
  gd_Security, obj_i_Debugger, dlg_gsResizer_ObjectInspector_unit,
  prp_frmGedeminProperty_Unit, gd_createable_form, mtd_i_Base,
  gdc_frmMDVTree_unit, gdcReport, FileCtrl, prp_PropertySettings, gsSupportClasses,
  shdocvw, gdcBaseInterface
  {$IFDEF MODEM}
    , gsModem
  {$ENDIF}
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  bSFHandleStream: Integer = $7FFFEAA5;
  eSFHandleStream: Integer = $7F5FCBCF;

  rp_SFFileName = '%sg%d.%s';
  rp_SFStreamVertion = 17;

  MaxRecursionDepth = 200;

type
  TrpCustomFunctionEx = class(TrpCustomFunction);

  TCrackerMethodData = record
    Flags: TParamFlags;
    ParamName: ShortString;
    TypeName: ShortString;
  end;

  TCrackerAction = class(TControl);

  PParamRecord = ^TParamRecord;
  TParamRecord = record
    Flags:     TParamFlags;
    ParamName: ShortString;
    TypeName:  ShortString;
  end;

procedure Register;
begin
  RegisterComponents('gsReport', [TgsFunctionList]);
  RegisterComponents('gsReport', [TEventControl]);
end;

function TShiftStateToStr(Value: TShiftState): String;
begin
  Result := '';
  if  ssShift in Value then
    Result := Result + 'ssShift';
  if  ssAlt in Value then
    Result := Result + 'ssAlt';
  if  ssCtrl in Value then
    Result := Result + 'ssCtrl';
  if  ssLeft in Value then
    Result := Result + 'ssLeft';
  if  ssRight in Value then
    Result := Result + 'ssRight';
  if  ssMiddle in Value then
    Result := Result + 'ssMiddle';
  if  ssDouble in Value then
    Result := Result + 'ssDouble';
end;

function StrToShiftState(Value: String): TShiftState;
begin
  Result := [];
  if Pos('SSSHIFT', AnsiUpperCase(Value)) > 0 then
    Include(Result, ssShift);
  if Pos('SSALT', AnsiUpperCase(Value)) > 0 then
    Include(Result, ssAlt);
  if Pos('SSCTRL', AnsiUpperCase(Value)) > 0 then
    Include(Result, ssCtrl);
  if Pos('SSLEFT', AnsiUpperCase(Value)) > 0 then
    Include(Result, ssLeft);
  if Pos('SSRIGHT', AnsiUpperCase(Value)) > 0 then
    Include(Result, ssRight);
  if Pos('SSMIDDLE', AnsiUpperCase(Value)) > 0 then
    Include(Result, ssMiddle);
  if Pos('SSDOUBLE', AnsiUpperCase(Value)) > 0 then
    Include(Result, ssDouble);
end;

function TOwnerDrawStateToStr(Value: TOwnerDrawState): String;
begin
  Result := '';
  if  odSelected in Value then
    Result := Result + 'odSelected';
  if  odGrayed in Value then
    Result := Result + 'odGrayed';
  if  odDisabled in Value then
    Result := Result + 'odDisabled';
  if  odChecked in Value then
    Result := Result + 'odChecked';
  if  odFocused in Value then
    Result := Result + 'odFocused';
  if  odDefault in Value then
    Result := Result + 'odDefault';
  if  odComboBoxEdit in Value then
    Result := Result + 'odComboBoxEdit';
end;

function TGridDrawStateToStr(Value: TGridDrawState): String;
begin
  Result := '';
  if gdSelected  in Value then
    Result := Result + 'gdSelected';
  if gdFocused  in Value then
    Result := Result + 'gdFocused';
  if gdFixed  in Value then
    Result := Result + 'gdFixed';
end;

function StrToTGridDrawState(Value: String): TGridDrawState;
begin
  Result := [];
  if Pos('GDSELECTED', AnsiUpperCase(Value)) > 0 then
    Include(Result, gdSelected);
  if Pos('GDFOCUSED', AnsiUpperCase(Value)) > 0 then
    Include(Result, gdFocused);
  if Pos('GDFIXED', AnsiUpperCase(Value)) > 0 then
    Include(Result, gdFixed);
end;

function StrToTOwnerDrawState(Value: String): TOwnerDrawState;
begin
  Result := [];
  if Pos('ODSELECTED', AnsiUpperCase(Value)) > 0 then
    Include(Result, odSelected);
  if Pos('ODGRAYED', AnsiUpperCase(Value)) > 0 then
    Include(Result, odGrayed);
  if Pos('ODDISABLED', AnsiUpperCase(Value)) > 0 then
    Include(Result, odDisabled);
  if Pos('ODCHECKED', AnsiUpperCase(Value)) > 0 then
    Include(Result, odChecked);
  if Pos('ODFOCUSED', AnsiUpperCase(Value)) > 0 then
    Include(Result, odFocused);
  if Pos('ODDEFAULT', AnsiUpperCase(Value)) > 0 then
    Include(Result, odDefault);
  if Pos('ODCOMBOBOXEDIT', AnsiUpperCase(Value)) > 0 then
    Include(Result, odComboBoxEdit);
end;

function CompareItems(Item1, Item2: Pointer): Integer;
begin
  Assert((TObject(Item1) is TrpCustomFunction) and (TObject(Item2) is TrpCustomFunction));
  Result := TrpCustomFunction(Item1).FunctionKey -
   TrpCustomFunction(Item2).FunctionKey;
end;

procedure SaveSLtoStreamEx(AnSL: TStrings; AnStream: TStream);
var
  I: Integer;
  Len: Integer;
begin
  Len := AnSL.Count;
  AnStream.WriteBuffer(Len, SizeOf(Len));
  for I := 0 to AnSL.Count - 1 do
  begin
    Len := Length(AnSL.Strings[I]);
    AnStream.WriteBuffer(Len, SizeOf(Len));
    AnStream.WriteBuffer(AnSL.Strings[I][1], Len);
    Len := Integer(AnSL.Objects[I]);
    AnStream.WriteBuffer(Len, SizeOf(Len));
  end;
end;

procedure LoadSLfromStreamEx(AnSL: TStrings; AnStream: TStream);
var
  I: Integer;
  Len, J: Integer;
  TempStr: String;
begin
  AnSL.Clear;
  AnStream.ReadBuffer(J, SizeOf(J));
  for I := 0 to J - 1 do
  begin
    AnStream.ReadBuffer(Len, SizeOf(Len));
    SetLength(TempStr, Len);
    AnStream.ReadBuffer(TempStr[1], Len);
    AnStream.ReadBuffer(Len, SizeOf(Len));
    AnSL.AddObject(TempStr, Pointer(Len));
  end;
end;

{ TEventControl }

procedure TEventControl.AfterCancel(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterCancelEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterCancelEventName);
    
    {if Assigned(LEventOfObject.OldEvent.Code) then
    begin
      LEvent := @LEventOfObject.OldEvent.Code;
      LEvent^(DataSet);
    end;
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterClose(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterCloseEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterCloseEventName);
    
    {if Assigned(LEventOfObject.OldEvent.Code) then
    begin
      LEvent := @LEventOfObject.OldEvent.Code;
      LEvent^(DataSet);
    end;
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterDatabaseDisconnect(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterDatabaseDisconnectEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cAfterDatabaseDisconnectEventName);
    
    {if Assigned(LEventOfObject.OldEvent.Code) then
    begin
      LEvent := @LEventOfObject.OldEvent.Code;
      LEvent^(Sender);
    end;
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterDelete(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterDeleteEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterDeleteEventName);
    
    {if Assigned(LEventOfObject.OldEvent.Code) then
    begin
      LEvent := @LEventOfObject.OldEvent.Code;
      LEvent^(DataSet);
    end;
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterEdit(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterEditEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterEditEventName);
    
    {if Assigned(LEventOfObject.OldEvent.Code) then
    begin
      LEvent := @LEventOfObject.OldEvent.Code;
      LEvent^(DataSet);
    end;
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterInsert(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterInsertEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterInsertEventName);
    
    {if Assigned(LEventOfObject.OldEvent.Code) then
    begin
      LEvent := @LEventOfObject.OldEvent.Code;
      LEvent^(DataSet);
    end;
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterOpen(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterOpenEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterOpenEventName);
    
    {if Assigned(LEventOfObject.OldEvent.Code) then
    begin
      LEvent := @LEventOfObject.OldEvent.Code;
      LEvent^(DataSet);
    end;
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterPost(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterPostEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterPostEventName);
    
    {if Assigned(LEventOfObject.OldEvent.Code) then
    begin
      LEvent := @LEventOfObject.OldEvent.Code;
      LEvent^(DataSet);
    end;
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterRefresh(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterRefreshEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterRefreshEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterScroll(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterScrollEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterScrollEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterShowDialog(Sender: TObject;
  DlgForm: TCustomForm; IsOk: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TgdcDoAfterShowDialog;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(DlgForm) as IDispatch, IsOk]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterShowDialogEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cAfterShowDialogEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterTransactionEnd(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterTransactionEndEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cAfterTransactionEndEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeCancel(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeCancelEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforeCancelEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeClose(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeCloseEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforeCloseEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeDatabaseDisconnect(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeDatabaseDisconnectEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cBeforeDatabaseDisconnectEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeDelete(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeDeleteEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforeDeleteEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeEdit(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeEditEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforeEditEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeInsert(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeInsertEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforeInsertEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeOpen(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeOpenEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforeOpenEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforePost(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforePostEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforePostEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeScroll(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeScrollEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforeScrollEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeShowDialog(Sender: TObject;
  DlgForm: TCustomForm);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TgdcDoBeforeShowDialog;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(DlgForm) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeShowDialogEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cBeforeShowDialogEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeTransactionEnd(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeTransactionEndEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cBeforeTransactionEndEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.CheckCreateForm;
begin
  if not Assigned(frmGedeminProperty) then
  begin
  { TODO : 
DAlex: Если дебаггер здесь отключается, то, 
если открыт инспектор классов и есть ошибка в глобальном объекте, 
то может появиться сообщение, что ID функции = 0.
Если не отключение не повлечет пагубных последствий, то так нужно и оставить. }
//    if Assigned(Debugger) then Debugger.Enabled := False;
    try
      FPropertyDisableCount := 0;
      if not TfrmGedeminProperty.FormAssigned(frmGedeminProperty) then
        TfrmGedeminProperty.CreateAndAssign(Application)
      else
        if not frmGedeminProperty.Visible then frmGedeminProperty.Show;
    finally
//      if Assigned(Debugger) then Debugger.Enabled := True;
    end;
  end;
end;

constructor TEventControl.Create(AOwner: TComponent);
var
  AddrNotifyEvent: TNotifyEvent;
  AddrDBGridClickEvent: TDBGridClickEvent;
  AddrCloseQueryEvent: TCloseQueryEvent;
  AddrCanResizeEvent: TCanResizeEvent;
begin
  Assert(EventControl = nil, 'This component can be only one.');

  inherited Create(AOwner);

  FRectList  :=  TgdKeyIntAssoc.Create;
  FPointList :=  TgdKeyIntAssoc.Create;

  // Инициализация и заполнения массива
  // известных событий
  FEventList := TStringList.Create;
  TStringList(FEventList).Sorted := True;
  FillEventList;
  FgdcReportGroupList := TgdKeyArray.Create;

  FKnownEventList := nil;
  FEventObjectList := nil;
  FTransaction := nil;

  if not (csDesigning in ComponentState) then
  begin
    FTransaction := TIBTransaction.Create(Self);
    FTransaction.Params.Add('read_committed');
    FTransaction.Params.Add('rec_version');
    FTransaction.Params.Add('nowait');

    FEventObjectList := TEventObjectList.Create;

    FKnownEventList := TStringList.Create;

    // Регистрация известных типов событий
    AddrNotifyEvent := OnClick;
    FKnownEventList.AddObject('OnClick', @AddrNotifyEvent);
    AddrNotifyEvent := OnPopup;
    FKnownEventList.AddObject('OnPopup', @AddrNotifyEvent);
    AddrCanResizeEvent := OnCanResize;
    FKnownEventList.AddObject('OnCanResize', @AddrCanResizeEvent);
    AddrNotifyEvent := OnCreate;
    FKnownEventList.AddObject('OnCreate', @AddrNotifyEvent);
    TConstrainedResizeEvent(AddrNotifyEvent) := OnConstrainedResize;
    FKnownEventList.AddObject('OnConstrainedResize', @AddrNotifyEvent);
    TContextPopupEvent(AddrNotifyEvent) := OnContextPopup;
    FKnownEventList.AddObject('OnContextPopup', @AddrNotifyEvent);
    AddrNotifyEvent := OnDblClick;
    FKnownEventList.AddObject('OnDblClick', @AddrNotifyEvent);
    TDragDropEvent(AddrNotifyEvent) := OnDragDrop;
    FKnownEventList.AddObject('OnDragDrop', @AddrNotifyEvent);
    TDragOverEvent(AddrNotifyEvent) := OnDragOver;
    FKnownEventList.AddObject('OnDragOver', @AddrNotifyEvent);
    TEndDragEvent(AddrNotifyEvent) := OnEndDock;
    FKnownEventList.AddObject('OnEndDock', @AddrNotifyEvent);
    TEndDragEvent(AddrNotifyEvent) := OnEndDrag;
    FKnownEventList.AddObject('OnEndDrag', @AddrNotifyEvent);
    TMouseEvent(AddrNotifyEvent) := OnMouseDown;
    FKnownEventList.AddObject('OnMouseDown', @AddrNotifyEvent);
    TMouseMoveEvent(AddrNotifyEvent) := OnMouseMove;
    FKnownEventList.AddObject('OnMouseMove', @AddrNotifyEvent);
    TMouseEvent(AddrNotifyEvent) := OnMouseUp;
    FKnownEventList.AddObject('OnMouseUp', @AddrNotifyEvent);
    AddrNotifyEvent := OnResize;
    FKnownEventList.AddObject('OnResize', @AddrNotifyEvent);
    TStartDockEvent(AddrNotifyEvent) := OnStartDock;
    FKnownEventList.AddObject('OnStartDock', @AddrNotifyEvent);
    TStartDragEvent(AddrNotifyEvent) := OnStartDrag;
    FKnownEventList.AddObject('OnStartDrag', @AddrNotifyEvent);

    TDockDropEvent(AddrNotifyEvent) := OnDockDrop;
    FKnownEventList.AddObject('OnDockDrop', @AddrNotifyEvent);
    TDockOverEvent(AddrNotifyEvent) := OnDockOver;
    FKnownEventList.AddObject('OnDockOver', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnEnter;
    FKnownEventList.AddObject('OnEnter', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnExit;
    FKnownEventList.AddObject('OnExit', @AddrNotifyEvent);
    TKeyEvent(AddrNotifyEvent) := OnKeyDown;
    FKnownEventList.AddObject('OnKeyDown', @AddrNotifyEvent);
    TKeyPressEvent(AddrNotifyEvent) := OnKeyPress;
    FKnownEventList.AddObject('OnKeyPress', @AddrNotifyEvent);
    TKeyEvent(AddrNotifyEvent) := OnKeyUp;
    FKnownEventList.AddObject('OnKeyUp', @AddrNotifyEvent);
    TMouseWheelEvent(AddrNotifyEvent) := OnMouseWheel;
    FKnownEventList.AddObject('OnMouseWheel', @AddrNotifyEvent);
    TMouseWheelUpDownEvent(AddrNotifyEvent) := OnMouseWheelDown;
    FKnownEventList.AddObject('OnMouseWheelDown', @AddrNotifyEvent);
    TMouseWheelUpDownEvent(AddrNotifyEvent) := OnMouseWheelUp;
    FKnownEventList.AddObject('OnMouseWheelUp', @AddrNotifyEvent);
    TUnDockEvent(AddrNotifyEvent) := OnUnDock;
    FKnownEventList.AddObject('OnUnDock', @AddrNotifyEvent);

    TNotifyEvent(AddrNotifyEvent) := OnActivate;
    FKnownEventList.AddObject('OnActivate', @AddrNotifyEvent);
    TCloseEvent(AddrNotifyEvent) := OnClose;
    FKnownEventList.AddObject('OnClose', @AddrNotifyEvent);

    TNotifyEvent(AddrNotifyEvent) := OnCloseNotify;
    FKnownEventList.AddObject('OnCloseNotify', @AddrNotifyEvent);

    AddrCloseQueryEvent := OnCloseQuery;
    FKnownEventList.AddObject('OnCloseQuery', @AddrCloseQueryEvent);
    TNotifyEvent(AddrNotifyEvent) := OnDeactivate;
    FKnownEventList.AddObject('OnDeactivate', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnDestroy;
    FKnownEventList.AddObject('OnDestroy', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnHide;
    FKnownEventList.AddObject('OnHide', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnPaint;
    FKnownEventList.AddObject('OnPaint', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnShow;
    FKnownEventList.AddObject('OnShow', @AddrNotifyEvent);
    TMenuChangeEvent(AddrNotifyEvent) := OnChange;
    FKnownEventList.AddObject('OnChange', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnChangeEdit;
    FKnownEventList.AddObject('OnChangeEdit', @AddrNotifyEvent);

    TNotifyEvent(AddrNotifyEvent) := OnClickCheckListBox;
    FKnownEventList.AddObject('OnClickCheckListBox', @AddrNotifyEvent);
    TTabChangingEvent(AddrNotifyEvent) := OnChanging;
    FKnownEventList.AddObject('OnChanging', @AddrNotifyEvent);

    TDrawItemEvent(AddrNotifyEvent) := OnDrawItem;
    FKnownEventList.AddObject('OnDrawItem', @AddrNotifyEvent);
    TMeasureItemEvent(AddrNotifyEvent) := OnMeasureItem;
    FKnownEventList.AddObject('OnMeasureItem', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnDropDown;
    FKnownEventList.AddObject('OnDropDown', @AddrNotifyEvent);
    TScrollEvent(AddrNotifyEvent) := OnScroll;
    FKnownEventList.AddObject('OnScroll', @AddrNotifyEvent);
    TActionEvent(AddrNotifyEvent) := OnExecute;
    FKnownEventList.AddObject('OnExecute', @AddrNotifyEvent);

    TNotifyEvent(AddrNotifyEvent) := OnExecuteAction;
    FKnownEventList.AddObject('OnExecuteAction', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnUpdateAction;
    FKnownEventList.AddObject('OnUpdateAction', @AddrNotifyEvent);

    TActionEvent(AddrNotifyEvent) := OnUpdate;
    FKnownEventList.AddObject('OnUpdate', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnMove;
    FKnownEventList.AddObject('OnMove', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnRecreated;
    FKnownEventList.AddObject('OnRecreated', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnRecreating;
    FKnownEventList.AddObject('OnRecreating', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnDockChanged;
    FKnownEventList.AddObject('OnDockChanged', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnDockChanging;
    FKnownEventList.AddObject('OnDockChanging', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnDockChangingHidden;
    FKnownEventList.AddObject('OnDockChangingHidden', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnVisibleChanged;
    FKnownEventList.AddObject('OnVisibleChanged', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnColEnter;
    FKnownEventList.AddObject('OnColEnter', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnColExit;
    FKnownEventList.AddObject('OnColExit', @AddrNotifyEvent);
    TMovedEvent(AddrNotifyEvent) := OnColumnMoved;
    FKnownEventList.AddObject('OnColumnMoved', @AddrNotifyEvent);
    TDrawColumnCellEvent(AddrNotifyEvent) := OnDrawColumnCell;
    FKnownEventList.AddObject('OnDrawColumnCell', @AddrNotifyEvent);
    TDrawDataCellEvent(AddrNotifyEvent) := OnDrawDataCell;
    FKnownEventList.AddObject('OnDrawDataCell', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnEditButtonClick;
    FKnownEventList.AddObject('OnEditButtonClick', @AddrNotifyEvent);
    AddrDBGridClickEvent:= OnCellClick;
    FKnownEventList.AddObject('OnCellClick', @AddrDBGridClickEvent);

    TOnGetFooter(AddrNotifyEvent) := OnGetFooter;
    FKnownEventList.AddObject('OnGetFooter', @AddrNotifyEvent);

    TOnGetFooter(AddrNotifyEvent) := OnGetTotal;
    FKnownEventList.AddObject('OnGetTotal', @AddrNotifyEvent);

    TNotifyEvent(AddrNotifyEvent) := OnAggregateChanged;
    FKnownEventList.AddObject('OnAggregateChanged', @AddrNotifyEvent);
    TCheckBoxEvent(AddrNotifyEvent) := OnClickCheck;
    FKnownEventList.AddObject('OnClickCheck', @AddrNotifyEvent);
    TAfterCheckEvent(AddrNotifyEvent) := OnClickedCheck;
    FKnownEventList.AddObject('OnClickedCheck', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterCancel;
    FKnownEventList.AddObject('AfterCancel', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterClose;
    FKnownEventList.AddObject('AfterClose', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterDelete;
    FKnownEventList.AddObject('AfterDelete', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterEdit;
    FKnownEventList.AddObject('AfterEdit', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterInsert;
    FKnownEventList.AddObject('AfterInsert', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterOpen;
    FKnownEventList.AddObject('AfterOpen', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterPost;
    FKnownEventList.AddObject('AfterPost', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterRefresh;
    FKnownEventList.AddObject('AfterRefresh', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterScroll;
    FKnownEventList.AddObject('AfterScroll', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforeCancel;
    FKnownEventList.AddObject('BeforeCansel', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforeClose;
    FKnownEventList.AddObject('BeforeClose', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforeDelete;
    FKnownEventList.AddObject('BeforeDelete', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforeEdit;
    FKnownEventList.AddObject('BeforeEdit', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforeInsert;
    FKnownEventList.AddObject('BeforeInsert', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforeOpen;
    FKnownEventList.AddObject('BeforeOpen', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforePost;
    FKnownEventList.AddObject('BeforePost', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforeScroll;
    FKnownEventList.AddObject('BeforeScroll', @AddrNotifyEvent);

    TDataSetNotifyEvent(AddrNotifyEvent) := AfterInternalPostRecord;
    FKnownEventList.AddObject('AfterInternalPostRecord', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforeInternalPostRecord;
    FKnownEventList.AddObject('BeforeInternalPostRecord', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := AfterInternalDeleteRecord;
    FKnownEventList.AddObject('AfterInternalDeleteRecord', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := BeforeInternalPostRecord;
    FKnownEventList.AddObject('BeforeInternalDeleteRecord', @AddrNotifyEvent);


    TDataSetNotifyEvent(AddrNotifyEvent) := OnCalcFields;
    FKnownEventList.AddObject('OnCalcFields', @AddrNotifyEvent);
    TDataSetErrorEvent(AddrNotifyEvent) := OnDeleteError;
    FKnownEventList.AddObject('OnDeleteError', @AddrNotifyEvent);
    TDataSetErrorEvent(AddrNotifyEvent) := OnEditError;
    FKnownEventList.AddObject('OnEditError', @AddrNotifyEvent);
    TFilterRecordEvent(AddrNotifyEvent) := OnFilterRecord;
    FKnownEventList.AddObject('OnFilterRecord', @AddrNotifyEvent);
    TDataSetNotifyEvent(AddrNotifyEvent) := OnNewRecord;
    FKnownEventList.AddObject('OnNewRecord', @AddrNotifyEvent);
    TDataSetErrorEvent(AddrNotifyEvent) := OnPostError;
    FKnownEventList.AddObject('OnPostError', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := AfterDatabaseDisconnect;
    FKnownEventList.AddObject('AfterDatabaseDisconnect', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := AfterTransactionEnd;
    FKnownEventList.AddObject('AfterTransactionEnd', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := BeforeDatabaseDisconnect;
    FKnownEventList.AddObject('BeforeDatabaseDisconnect', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := BeforeTransactionEnd;
    FKnownEventList.AddObject('BeforeTransactionEnd', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := DatabaseFree;
    FKnownEventList.AddObject('DatabaseFree', @AddrNotifyEvent);
    TIBUpdateErrorEvent(AddrNotifyEvent) := OnUpdateError;
    FKnownEventList.AddObject('OnUpdateError', @AddrNotifyEvent);
    TIBUpdateRecordEvent(AddrNotifyEvent) := OnUpdateRecord;
    FKnownEventList.AddObject('OnUpdateRecord', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := TransactionFree;
    FKnownEventList.AddObject('TransactionFree', @AddrNotifyEvent);
    TFilterRecordEvent(AddrNotifyEvent) := OnCalcAggregates;
    FKnownEventList.AddObject('OnCalcAggregates', @AddrNotifyEvent);

    TNotifyEvent(AddrNotifyEvent) := DatabaseDisconnected;
    FKnownEventList.AddObject('DatabaseDisconnected', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := DatabaseDisconnecting;
    FKnownEventList.AddObject('DatabaseDisconnecting', @AddrNotifyEvent);
    TgdcAfterInitSQL(AddrNotifyEvent) := OnAfterInitSQL;
    FKnownEventList.AddObject('OnAfterInitSQL', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnFilterChanged;
    FKnownEventList.AddObject('OnFilterChanged', @AddrNotifyEvent);
    TgdcDoBeforeShowDialog(AddrNotifyEvent) := BeforeShowDialog;
    FKnownEventList.AddObject('BeforeShowDialog', @AddrNotifyEvent);
    TgdcDoAfterShowDialog(AddrNotifyEvent) := AfterShowDialog;
    FKnownEventList.AddObject('AfterShowDialog', @AddrNotifyEvent);
    TDataChangeEvent(AddrNotifyEvent) := OnDataChange;
    FKnownEventList.AddObject('OnDataChange', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnStateChange;
    FKnownEventList.AddObject('OnStateChange', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnUpdateData;
    FKnownEventList.AddObject('OnUpdateData', @AddrNotifyEvent);
    TOnCreateNewObject(AddrNotifyEvent) := OnCreateNewObject;
    FKnownEventList.AddObject('OnCreateNewObject', @AddrNotifyEvent);
    TOnCreateNewObject(AddrNotifyEvent) := OnAfterCreateDialog;
    FKnownEventList.AddObject('OnAfterCreateDialog', @AddrNotifyEvent);
    TConditionChanged(AddrNotifyEvent) := OnConditionChanged;
    FKnownEventList.AddObject('OnConditionChanged', @AddrNotifyEvent);
    TFilterChanged(AddrNotifyEvent) := OnFilterChangedSQLFilter;
    FKnownEventList.AddObject('OnFilterChangedSQLFilter', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnTimer;
    FKnownEventList.AddObject('OnTimer', @AddrNotifyEvent);
    TOnSyncFieldEvent(AddrNotifyEvent) := OnSyncField;
    FKnownEventList.AddObject('OnSyncField', @AddrNotifyEvent);

    TOnTestCorrect(AddrNotifyEvent) := OnTestCorrect;
    FKnownEventList.AddObject('OnTestCorrect', @AddrNotifyEvent);
    TOnSetupRecord(AddrNotifyEvent) := OnSetupRecord;
    FKnownEventList.AddObject('OnSetupRecord', @AddrNotifyEvent);
    TOnSetupDialog(AddrNotifyEvent) := OnSetupDialog;
    FKnownEventList.AddObject('OnSetupDialog', @AddrNotifyEvent);



    TFieldGetTextEvent(AddrNotifyEvent) := OnGetText;
    FKnownEventList.AddObject('OnGetText', @AddrNotifyEvent);
    TFieldSetTextEvent(AddrNotifyEvent) := OnSetText;
    FKnownEventList.AddObject('OnSetText', @AddrNotifyEvent);
    TFieldNotifyEvent(AddrNotifyEvent) := OnValidate;
    FKnownEventList.AddObject('OnValidate', @AddrNotifyEvent);

    TgdcOnGetSQLClause(AddrNotifyEvent) := OnGetSelectClause;
    FKnownEventList.AddObject('OnGetSelectClause', @AddrNotifyEvent);
    TgdcOnGetSQLClause(AddrNotifyEvent) := OnGetFromClause;
    FKnownEventList.AddObject('OnGetFromClause', @AddrNotifyEvent);
    TgdcOnGetSQLClause(AddrNotifyEvent) := OnGetWhereClause;
    FKnownEventList.AddObject('OnGetWhereClause', @AddrNotifyEvent);
    TgdcOnGetSQLClause(AddrNotifyEvent) := OnGetGroupClause;
    FKnownEventList.AddObject('OnGetGroupClause', @AddrNotifyEvent);
    TgdcOnGetSQLClause(AddrNotifyEvent) := OnGetOrderClause;
    FKnownEventList.AddObject('OnGetOrderClause', @AddrNotifyEvent);

    TNotifyEvent(AddrNotifyEvent) := OnSaveSettings;
    FKnownEventList.AddObject('OnSaveSettings', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnLoadSettingsAfterCreate;
    FKnownEventList.AddObject('OnLoadSettingsAfterCreate', @AddrNotifyEvent);

    TWebBrowserBeforeNavigate2(AddrNotifyEvent) := OnBeforeNavigate2;
    FKnownEventList.AddObject('OnBeforeNavigate2', @AddrNotifyEvent);

    TWebBrowserDocumentComplete(AddrNotifyEvent) := OnDocumentComplete;
    FKnownEventList.AddObject('OnDocumentComplete', @AddrNotifyEvent);

 {!DAlex}

  {$IFDEF MODEM}

    TNotifyEvent(AddrNotifyEvent) := OnSend;
    FKnownEventList.AddObject('OnSend', @AddrNotifyEvent);
    TModemReceive(AddrNotifyEvent) := OnReceive;
    FKnownEventList.AddObject('OnReceive', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnOpenPort;
    FKnownEventList.AddObject('OnOpenPort', @AddrNotifyEvent);
    TNotifyEvent(AddrNotifyEvent) := OnClosePort;
    FKnownEventList.AddObject('OnClosePort', @AddrNotifyEvent);
    TgsModemError(AddrNotifyEvent) := OnError;
    FKnownEventList.AddObject('OnError', @AddrNotifyEvent);

  {$ENDIF}

    TStringList(FKnownEventList).Sorted := True;
  end;

  EventControl := Self;
end;

procedure TEventControl.DatabaseDisconnected(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDatabaseDisconnectedEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDatabaseDisconnectedEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.DatabaseDisconnecting(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDatabaseDisconnectingEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDatabaseDisconnectingEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.DatabaseFree(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDatabaseFreeEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDatabaseFreeEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.DebugScriptFunction(const AFunctionKey: Integer;
  const AModuleName: string; const CurrentLine: Integer);
begin
  if (not Application.Terminated) and IBLogin.Database.Connected then
  begin
    CheckCreateForm;
    frmGedeminProperty.DebugScriptFunction(AFunctionKey, CurrentLine);
  end;
end;

procedure TEventControl.DeleteEvent(FormName, ComponentName,
  EventName: string);
var
  Ob: TEventObject;
  E: TEventItem;
  SQL: TIBSQL;
  Flag: Boolean;
begin
  if Assigned(frmGedeminProperty) then
    frmGedeminProperty.DeleteEvent(FormName, ComponentName, EventName)
  else
  begin
    Ob := FEventObjectList.FindObject(FormName);
    if not Assigned(Ob) then
      raise Exception.Create('Не найдена форма');
    if UpperCase(FormName) <> UpperCase(ComponentName) then
      Ob := Ob.ChildObjects.FindAllObject(ComponentName);
    if not Assigned(Ob) then
      raise Exception.Create('Не найден компонент');
    E := Ob.EventList.Find(EventName);
    if not Assigned(E) then
      raise Exception.Create('Не найдено событие');
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := FTransaction;
      SQL.SQL.Text := 'DELETE FROM evt_objectevent ' +
        'WHERE UPPER(eventname) = ''' + UpperCase(E.Name) + ''' AND objectkey = ' +
        IntToStr(Ob.ObjectKey);
      Flag := not FTransaction.InTransaction;
      if Flag then
        FTransaction.StartTransaction;
      try
        SQL.ExecQuery;
        if Flag then
          FTransaction.Commit;
        E.FunctionKey := 0;
        E.EventID := 0;
        if dlg_gsResizer_ObjectInspector <> nil then
        begin
          if E.EventObject <> nil then
            dlg_gsResizer_ObjectInspector.EventSync(E.EventObject.ObjectName,
              E.Name);
        end;
      except
        if Flag and FTransaction.InTransaction then
          FTransaction.RollBack;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

destructor TEventControl.Destroy;
begin
  if Assigned(FTransaction) then
    FreeAndNil(FTransaction);
  FreeAndNil(FKnownEventList);

  // FEventObjectList может быть nil
  // яркий пример, dmClientReport_unit в режиме редактировании в Delphi
  if Assigned(FEventObjectList) then
  begin
    ResetAllEvents(FEventObjectList);
    FreeAndNil(FEventObjectList);
  end;
  FEventList.Free;
  FDynamicCreatedEventObjects.Free;
  FgdcReportGroupList.Free;

  if (EventControl.Get_Self = Self) then
    EventControl := nil;

  if Assigned(frmGedeminProperty) then
    FreeAndNil(frmGedeminProperty);

  FRectList.Free;
  FPointList.Free;

  
  inherited Destroy;
end;

procedure TEventControl.EditObject(const AnComponent: TComponent;
  const EditMode: TEditMode = emNone; const AnName: String = '';
  const AnFunctionID: integer = 0);
begin
  if not Application.Terminated and (IBLogin <> nil) and
    (IbLogin.IsUserAdmin) then
  begin
    CheckCreateForm;
    frmGedeminProperty.EditObject(AnComponent, EditMode, AnName, AnFunctionID);
  end;
end;

procedure TEventControl.GoToClassMethods(const AClassName,
  ASubType: string);
begin
  CheckCreateForm;

  frmGedeminProperty.GoToClassMethods(AClassName, ASubType);
end;

procedure TEventControl.EditReport(IDReportGroup, IDReport: Integer);
begin
  CheckCreateForm;

  frmGedeminProperty.EditReport(IDReportGroup, IDReport);
end;

function TEventControl.EditScriptFunction(var AFunctionKey: Integer): Boolean;
begin
  Result := False;
  if not Application.Terminated then
  begin
    if IBLogin.Database.Connected then
    begin
      CheckCreateForm;
      frmGedeminProperty.EditScriptFunction(AFunctionKey);
    end;  
  end;
end;

procedure TEventControl.EventLog;
begin
  if not Assigned(frmEventLog) then
    frmEventLog := TfrmEventLog.Create(Application)
  else
    frmEventLog.Show;
end;

function TEventControl.ExecuteEvent(const EventItem: TEventItem;
  var AnParams: Variant; Sender: TObject; const EventName: String): Variant;
var
  LFunction: TrpCustomFunction;
//  LResult: Variant;
//  FullObjectName: String;
const
  cMsgEventOffUser =
    'Во время выполнения обработчика события %s для объекта %s произошла ошибка.'#13#10 +
    'Ключ скрипт-функции - %d.'#13#10 +
    'Обратитесь к администратору.';

  cMsgEventOffAdmin =
    'Обработчик %s для объекта %s , вызвавший ошибку, не исправлен.'#13#10 +
    'Ключ скрипт-функции - %d.'#13#10 +
    'Отключить?';

  cFuncNotFount =
    'Скрипт-функция с ключем %d для обработки события %s объекта %s не обнаружена.';

  procedure DeleteEventItem(LComponent: TComponent; const LEventName: String);
  var
    LEventObject: TEventObject;
  begin
    // Поиск объекта вызывающего событие
    LEventObject := FEventObjectList.FindAllObject(LComponent);
    // Проверка результата поиска
    if Assigned(LEventObject) then
    begin
      // Поиск виртуального объекта для обработки события
      LEventObject.EventList.DeleteForName(LEventName);
    end;
  end;

begin
  if not FDatabase.Connected or (not Assigned(EventItem)) or
   (EventItem.FunctionKey = 0) then
  begin
    {$IFDEF DEBUG}
    if EventItem.Disable then
      raise Exception.Create('EventControl: Отключен обработчик. Что он здесь делает?');
    {$ENDIF}
    Exit;
  end;

  if Assigned(ScriptFactory) then
  begin
    if Assigned(glbFunctionList) then
    begin
      LFunction := glbFunctionList.FindFunction(EventItem.FunctionKey);
      if Assigned(LFunction) then
      try
        {$IFDEF DEBUG}
        if UseLog then
          Log.LogLn(DateTimeToStr(Now) + ': Запущено событие ' + LFunction.Name +
            '  ИД функции ' + IntToStr(LFunction.FunctionKey));
        try
        {$ENDIF}
        Inc(FRecursionDepth);
        if FRecursionDepth >= MaxRecursionDepth then
          MessageBox(0,
            PChar('Превышено максимальное количество рекурсивных вызовов функции ' +
            LFunction.Name + '.'),
            'Ошибка',
            MB_OK or MB_TASKMODAL or MB_ICONHAND)
        else
          ScriptFactory.ExecuteFunction(LFunction, AnParams, Result)
        {$IFDEF DEBUG}
        except
          if UseLog  then
            Log.LogLn(DateTimeToStr(Now) + ': Ошибка во время выполнения события ' + LFunction.Name +
              '  ИД функции ' + IntToStr(LFunction.FunctionKey));
          raise;
        end;
        {$ENDIF}
        {$IFDEF DEBUG}
        if UseLog then
          Log.LogLn(DateTimeToStr(Now) + ': Удачное выполнение события ' + LFunction.Name +
            '  ИД функции ' + IntToStr(LFunction.FunctionKey));
        {$ENDIF}
      finally
        Dec(FRecursionDepth);
        glbFunctionList.ReleaseFunction(LFunction);
      end
      else if IBLogin.Database.Connected then
      begin
        // если скрипт-функция, соответстующая ивенту не найдена, то возвращаем на текущий сеанс
        // делфовский обработчик.
        if Sender is TComponent then
        begin

          if IBLogin.IsIBUserAdmin then
          begin
            case MessageBox(Application.Handle, PChar(Format(cFuncNotFount ,[EventItem.FunctionKey, EventName, TComponent(Sender).Name]) + #13#10 +
              'Отключить отработчик?'), 'Ошибка подключения обработчика.', mb_YESNO or MB_IconError) of
              IDYES:
              begin
                // устанавливаем старый обработчик обработчик для компонента
                SetSingleEvent(TComponent(Sender), EventName,
                  FEventObjectList.FindAllObject(TComponent(
                    Sender)).EventList.Find(EventName).OldEvent.Code);
                EventItem.Disable := True;
                EventItem.SaveChangeInDB(FDatabase);
                Abort;
              end;
              IDNO:
              begin
                if MessageBox(Application.Handle, PChar(Format(cFuncNotFount ,
                  [EventItem.FunctionKey, EventName, TComponent(Sender).Name]) + #13#10 +
                  'Отработчик не отключен.'#13#10 + 'Открыть редактор обработчика?'),
                  'Ошибка подключения обработчика.', mb_YESNO or MB_IconWarning) = IDYES then
                  EditObject(TComponent(Sender), emEvent, EventName);
                Abort;
              end;
            end;
          end else
            begin
              // устанавливаем старый обработчик обработчик для компонента
              SetSingleEvent(TComponent(Sender), EventName,
                FEventObjectList.FindAllObject(TComponent(
                  Sender)).EventList.Find(EventName).OldEvent.Code);
              // удаляем старый обработчик обработчик в глобал. списке событий
              DeleteEventItem(TComponent(Sender), EventName);
              raise Exception.Create(Format(cFuncNotFount ,[EventItem.FunctionKey,
                EventName, TComponent(Sender).Name]) + #13#10 +
                'Обработчик отключен.'#13#10#13#10 + 'Обратитесь к администратору.');
            end;
        end else
          raise Exception.Create(GetGsException(Self, Format(cFuncNotFount ,
            [EventItem.FunctionKey, EventName, '???'])))
      end
    end else
      raise Exception.Create(GetGsException(Self, 'Класс glbFunctionList не создан'));
  end else
    raise Exception.Create(GetGsException(Self, 'Класс ScriptFactory не создан'));
end;

procedure TEventControl.GetParamInInterface(AVarInterface: IDispatch;
  AParam: OleVariant);
begin
  (AVarInterface as IgsVarParam).Value := AParam;
end;

function TEventControl.GetProperty: TCustomForm;
begin
  Result := frmGedeminProperty;
end;

function TEventControl.GetReturnVarParamEvent: TVarParamEvent;
begin
  Result := FReturnVarParamEvent;
end;

function TEventControl.GetVarInterface(const AnValue: Variant): OleVariant;
begin
  if Assigned(FVarParamEvent) then
    Result := FVarParamEvent(AnValue)
  else
    Result := AnValue;
end;

function TEventControl.GetVarParam(const AnValue: Variant): OleVariant;
begin
  if Assigned(FReturnVarParamEvent) then
    Result := FReturnVarParamEvent(AnValue)
  else
    Result := AnValue;
end;

function TEventControl.GetVarParamEvent: TVarParamEvent;
begin
  Result := FVarParamEvent;
end;

function TEventControl.Get_KnownEventList: TStrings;
begin
  Result := FKnownEventList;
end;

function TEventControl.Get_PropertyIsLoaded: Boolean;
begin
  Result := Assigned(frmGedeminProperty);
end;

function TEventControl.Get_Self: TObject;
begin
  Result := Self;
end;

function TEventControl.IsPropertyVisible: boolean;
begin
  Result := Assigned(frmGedeminProperty) and frmGedeminProperty.Visible;
end;

procedure TEventControl.LoadBranch(const AnObjectKey: Integer);
var
  LocSQL: TIBSQL;
  LEvtObjList: TEventObjectList;
  LEvtObj: TEventObject;
begin
  LocSQL := TIBSQL.Create(nil);
  try
    LocSQL.Database := FDatabase;
    LocSQL.Transaction := FTransaction;
    if not FTransaction.InTransaction then
      FTransaction.StartTransaction;
    LocSQL.SQL.Text := 'SELECT evtd.id, evtd.name FROM evt_object evtm, evt_object evtd ' +
     'WHERE evtm.id = :id AND evtd.lb <= evtm.lb AND evtd.rb >= evtm.rb ORDER BY evtd.lb';
    LocSQL.Params[0].AsInteger := AnObjectKey;
    LocSQL.ExecQuery;

    LEvtObjList := EventObjectList;

    while not LocSQL.Eof do
    begin
      LEvtObj := LEvtObjList.FindObject(LocSQL.FieldByName('id').AsInteger);
      if not Assigned(LEvtObj) then
      begin
        LEvtObjList.AddObject(nil);
        LEvtObjList.Last.ObjectName := LocSQL.FieldByName('name').AsString;
        LEvtObjList.Last.ObjectKey := LocSQL.FieldByName('id').AsInteger;
//        LEvtObjList.LoadFromDatabaseOpt(FDatabase, FTransaction, )
        LEvtObj := LEvtObjList.Last;
      end;
      LEvtObjList := LEvtObj.ChildObjects;
      LocSQL.Next;
    end;
  finally
    LocSQL.Free;
  end;
end;

procedure TEventControl.LoadLists;
begin
  FEventObjectList.LoadFromDatabaseOpt(FDatabase, FTransaction, NULL);
end;

function TEventControl.ObjectEventList(const AnComponent: TComponent;
  AnEventList: TStrings): Boolean;
var
  LPropList: TPropList;
  LObject: TEventObject;
  I, J: Integer;
  LEventItem: TEventItem;
  LFunctionName: String;
  LFunction: TrpCustomFunction;
  ObjectTree: TStrings;
  C: TComponent;
begin
  Result := False;
  AnEventList.Clear;
  //!!!Added by TipTop 28/02/2003
  ObjectTree := TStringList.Create;
  try
    C := AnComponent;
    while (C <> nil) and (C <> Application) do
    begin
      if C is TCreateableForm then
        ObjectTree.AddObject(TCreateableForm(C).InitialName, C)
      else
        ObjectTree.AddObject(C.Name, C);
      if C is TCustomForm then Break;  
      C := C.Owner;  
    end;

    LObject := FEventObjectList.FindObject(ObjectTree[ObjectTree.Count - 1]);
    if LObject <> nil then
    begin
      for I := ObjectTree.Count - 2 downto 0 do
      begin
        LObject := LObject.ChildObjects.FindObject(ObjectTree[I]);
        if LObject = nil then Break;
      end;
    end;
  finally
    ObjectTree.Free;
  end;
//  LObject := FEventObjectList.FindAllObject(AnComponent);
  //!!!
  J := GetPropList(AnComponent.ClassInfo, [tkMethod], @LPropList);
  for I := 0 to J - 1 do
    if FKnownEventList.IndexOf(LPropList[I]^.Name) <> -1 then
    begin
      if Assigned(LObject) then
      begin
        Result := True;
        LEventItem := LObject.EventList.Find(LPropList[I]^.Name);
        LFunctionName := '';
        if Assigned(LEventItem) then
        begin
          LFunction := glbFunctionList.FindFunction(LEventItem.FunctionKey);
          if Assigned(LFunction) then
          try
            LFunctionName := LFunction.Name;
          finally
            glbFunctionList.ReleaseFunction(LFunction);
          end;
        end;
      end;
      AnEventList.Add(LPropList[I]^.Name + '=' + LFunctionName);
    end;
end;

procedure TEventControl.OnActivate(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cActivateEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cActivateEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnAfterInitSQL(Sender: TObject;
  var SQLText: String; var isReplaceSQL: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TgdcAfterInitSQL;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(SQLText), GetVarInterface(isReplaceSQL)]);

    {!!!} {jkl} // Нет обратного присвоения параметров

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterInitSQLEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cAfterInitSQLEventName);
    // Обратное присвоение значений

    SQLText := String(GetVarParam(LParams[1]));
    isReplaceSQL := Boolean(GetVarParam(LParams[2]));
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnAggregateChanged(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAggregateChangedEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cAggregateChangedEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnCalcFields(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cCalcFieldsEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cCalcFieldsEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TCanResizeEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
     GetVarInterface(NewWidth), GetVarInterface(NewHeight), GetVarInterface(Resize)]);

    {!!!} {jkl} // Нет обратного присвоения параметров

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cCanResizeEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cCanResizeEventName);
    // Обратное присвоение значений
    NewWidth := Integer(GetVarParam(LParams[1]));
    NewHeight := Integer(GetVarParam(LParams[2]));
    Resize := Boolean(GetVarParam(LParams[3]));
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnChange(Sender: TObject; Source: TMenuItem;
  Rebuild: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TMenuChangeEvent;
  LParams: Variant;
begin
  if Assigned(Source) then
  begin
    // Поиск объекта вызывающего событие
    LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
    // Проверка результата поиска
    if Assigned(LEventObject) then
    begin
      // Формирование массива параметров. Различается в зависимости от параметров
      LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
        GetGdcOLEObject(Source) as IDispatch, Rebuild]);
      // Поиск виртуального объекта для обработки события
      LEventOfObject := LEventObject.EventList.Find(cChangeEventName);
      // Выполнение события
      ExecuteEvent(LEventOfObject, LParams, Sender, cChangeEventName);

    end else
      raise Exception.Create(cMsgCantFindObject);
  end;
end;

procedure TEventControl.OnChangeEdit(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cChangeEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cChangeEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnClick(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cClickEventName);
    // Выполнение события
//    try
      ExecuteEvent(LEventOfObject, LParams, Sender, cClickEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnClickCheck(Sender: TObject; CheckID: String;
  var Checked: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TCheckBoxEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
// ??? вместо Sender Action no
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      CheckID, GetVarInterface(Checked)]);

    {!!!} {jkl} // Нет обратного присвоения параметров

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cClickCheckEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cClickCheckEventName);
    // Обратное присвоение значений

    Checked := Boolean(GetVarParam(LParams[2]));
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnClickedCheck(Sender: TObject; CheckID: String;
  Checked: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TAfterCheckEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
// ??? вместо Sender Action no
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      CheckID, GetVarInterface(Checked)]);

    {!!!} {jkl} // Нет обратного присвоения параметров

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cClickedCheckEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cClickedCheckEventName);
    // Обратное присвоение значений

{    Checked := LParams[2];

    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnClose(Sender: TObject; var Action: TCloseAction);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(TgsCloseAction(Action))]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cCloseEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cCloseEventName);
    // Обратное присвоение значений

    Action := TCloseAction(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnCloseNotify(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cCloseEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cCloseEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TCloseQueryEvent;
  LParams: Variant;

begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(CanClose)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cCloseQueryEventName);

    // Выполнение события
    if Assigned(LEventOfObject) then
      ExecuteEvent(LEventOfObject, LParams, Sender, cCloseQueryEventName);

    // Обратное присвоение значений
    CanClose := Boolean(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnColEnter(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cColEnterEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cColEnterEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnColExit(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cColExitEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cColExitEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnColumnMoved(Sender: TObject; FromIndex,
  ToIndex: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TMovedEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      FromIndex, ToIndex]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cColumnMovedEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cColumnMovedEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnConditionChanged(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TConditionChanged;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cConditionChangedEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cConditionChangedEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnConstrainedResize(Sender: TObject; var MinWidth,
  MinHeight, MaxWidth, MaxHeight: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TConstrainedResizeEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
     GetVarInterface(MinWidth), GetVarInterface(MinHeight),
     GetVarInterface(MaxWidth), GetVarInterface(MaxHeight)]);

    {!!!} {jkl} // Нет обратного присвоения параметров

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cConstrainedResizeEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cConstrainedResizeEventName);
    // Обратное присвоение значений
    MinWidth := Integer(GetVarParam(LParams[1]));
    MinHeight := Integer(GetVarParam(LParams[2]));
    MaxWidth := Integer(GetVarParam(LParams[3]));
    MaxHeight := Integer(GetVarParam(LParams[4]));
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
  LgsPoint: TgsPoint;
  I: Integer;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    I := FPointList.IndexOf(Integer(Sender));
    if I = -1 then
    begin
      LgsPoint := TgsPoint.Create2(TComponent(Sender), FPointList);
      I := FPointList.Add(Integer(Sender));
      FPointList.ValuesByIndex[I] := Integer(LgsPoint);
    end else
      LgsPoint := TgsPoint(FPointList.ValuesByIndex[I]);
    LgsPoint.Point := MousePos;

    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
     GetGdcOLEObject(LgsPoint) as IDispatch, GetVarInterface(Handled)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cContextPopupEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cContextPopupEventName);
    // Обратное присвоение значений
    Handled := Boolean(GetVarParam(LParams[2]));

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnCreate(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cCreateEventName);
    
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cCreateEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnCreateNewObject(Sender: TObject;
  ANewObject: TgdcBase);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TOnCreateNewObject;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(ANewObject) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cCreateNewObjectEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cCreateNewObjectEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDataChange(Sender: TObject; Field: TField);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Field) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDataChangeEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDataChangeEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDblClick(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDblClickEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDblClickEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDeactivate(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDeactivateEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDeactivateEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDeleteError(DataSet: TDataSet; E: EDatabaseError;
  var Action: TDataAction);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetErrorEvent;
  LParams: Variant;
begin
  if Assigned(E) then
  begin
    // Поиск объекта вызывающего событие
    LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
    // Проверка результата поиска
    if Assigned(LEventObject) then
    begin
      // Формирование массива параметров. Различается в зависимости от параметров
      LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch,
        GetGdcOLEObject(E) as IDispatch, GetVarInterface(TgsDataAction(Action))]);

      {!!!} {jkl} // Нет обратного присвоения параметров

      // Поиск виртуального объекта для обработки события
      LEventOfObject := LEventObject.EventList.Find(cDeleteErrorEventName);
      // Выполнение события
      ExecuteEvent(LEventOfObject, LParams, DataSet, cDeleteErrorEventName);
      // Обратное присвоение значений

      try
        Action := TDataAction(GetVarParam(LParams[2]));
      except
      end;
      
    end else
      raise Exception.Create(cMsgCantFindObject);
  end;
end;

procedure TEventControl.OnDestroy(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDestroyEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDestroyEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDockChanged(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDockChangedEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDockChangedEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDockChanging(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDockChangingEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDockChangingEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDockChangingHidden(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDockChangingHiddenEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDockChangingHiddenEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDockDrop(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDockDropEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Source) as IDispatch, X, Y]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDockDropEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDockDropEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDockOver(Sender: TObject;
  Source: TDragDockObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDockOverEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Source) as IDispatch, X, Y, State, GetVarInterface(Accept)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDockOverEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDockOverEventName);
    // Обратное присвоение значений

    Accept := Boolean(GetVarParam(LParams[5]));

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDragDropEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Source) as IDispatch,X , Y]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDragDropEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDragDropEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDragOverEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Source) as IDispatch, X, Y, State, GetVarInterface(Accept)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDragOverEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDragOverEventName);
    // Обратное присвоение значений
    Accept := Boolean(GetVarParam(LParams[5]));
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
  LgsRect: TgsRect;
  I: Integer;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    I := FRectList.IndexOf(Integer(Sender));
    if I = -1 then
    begin
      LgsRect := TgsRect.Create2(TComponent(Sender), FRectList);
      I := FRectList.Add(Integer(Sender));
      FRectList.ValuesByIndex[I] := Integer(LgsRect);
    end else
      LgsRect := TgsRect(FRectList.ValuesByIndex[I]);
    LgsRect.Rect := Rect;
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(LgsRect) as IDispatch, DataCol,
      GetGdcOLEObject(Column) as IDispatch, TGridDrawStateToStr(State)]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDrawColumnCellEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDrawColumnCellEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDrawDataCell(Sender: TObject; const Rect: TRect;
  Field: TField; State: TGridDrawState);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
  LgsRect: TgsRect;
  I: Integer;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    I := FRectList.IndexOf(Integer(Sender));
    if I = -1 then
    begin
      LgsRect := TgsRect.Create2(TComponent(Sender), FRectList);
      I := FRectList.Add(Integer(Sender));
      FRectList.ValuesByIndex[I] := Integer(LgsRect);
    end else
      LgsRect := TgsRect(FRectList.ValuesByIndex[I]);
    LgsRect.Rect := Rect;
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(LgsRect) as IDispatch,
      GetGdcOLEObject(Field) as IDispatch, TGridDrawStateToStr(State)]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDrawDataCellEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDrawDataCellEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnCellClick(Column: TColumn);
var
  EvtObj: TEventObject;
  EvtItem: TEventItem;
  vParams: Variant;
begin
  EvtObj:= FEventObjectList.FindAllObject(Column.Grid as TComponent);
  if Assigned(EvtObj) then begin
    EvtItem:= EvtObj.EventList.Find(cCellClickEventName);
    vParams:= VarArrayOf([GetGdcOLEObject(Column) as IDispatch]);
    ExecuteEvent(EvtItem, vParams, Column.Grid, cCellClickEventName);
  end;
end;

procedure TEventControl.OnDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDrawItemEvent;
  LParams: Variant;
  LgsRect: TgsRect;
  I: Integer;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Control as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    I := FRectList.IndexOf(Integer(Control));
    if I = -1 then
    begin
      LgsRect := TgsRect.Create2(Control, FRectList);
      I := FRectList.Add(Integer(Control));
      FRectList.ValuesByIndex[I] := Integer(LgsRect);
    end else
      LgsRect := TgsRect(FRectList.ValuesByIndex[I]);
    LgsRect.Rect := Rect;
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Control) as IDispatch,
      Index, GetGdcOLEObject(LgsRect) as IDispatch,  TOwnerDrawStateToStr(State)]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDrawItemEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Control, cDrawItemEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDropDown(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cDropDownEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cDropDownEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnEditButtonClick(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cEditButtonClickEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cEditButtonClickEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnEditError(DataSet: TDataSet; E: EDatabaseError;
  var Action: TDataAction);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetErrorEvent;
  LParams: Variant;
begin
  if Assigned(E) then
  begin
    // Поиск объекта вызывающего событие
    LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
    // Проверка результата поиска
    if Assigned(LEventObject) then
    begin
      // Формирование массива параметров. Различается в зависимости от параметров
      LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch,
        GetGdcOLEObject(E) as IDispatch, GetVarInterface(TgsDataAction(Action))]);

      // Поиск виртуального объекта для обработки события
      LEventOfObject := LEventObject.EventList.Find(cEditErrorEventName);
      // Выполнение события
      ExecuteEvent(LEventOfObject, LParams, DataSet, cEditErrorEventName);
      // Обратное присвоение значений

      try
        Action := TDataAction(GetVarParam(LParams[2]));
      except
      end;
      
    end else
      raise Exception.Create(cMsgCantFindObject);
  end;
end;

procedure TEventControl.OnEndDock(Sender, Target: TObject; X, Y: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TEndDragEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Target) as IDispatch, X, Y]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cEndDockEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cEndDockEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnEndDrag(Sender, Target: TObject; X, Y: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TEndDragEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Target) as IDispatch, X, Y]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cEndDragEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cEndDragEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnEnter(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cEnterEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cEnterEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnExecute(Action: TBasicAction;
  var Handled: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TActionEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
// ??? вместо Sender Action no
  LEventObject := FEventObjectList.FindAllObject(TAction(Action).ActionList as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Action) as IDispatch,
      GetVarInterface(Handled)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cExecuteEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Action, cExecuteEventName);
    // Обратное присвоение значений

    Handled := Boolean(GetVarParam(LParams[1]));

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnExecuteAction(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
  LComponent: TComponent;
begin
  // если сендер не экшен, то событие вызвано из события ОнКлик объекта, у
  // которого определено свойство Экшен, => необходимо работать не с
  // Sender, а с Sender.Action
  // Тоже касается и пар-ра скрип-функции
  // А TTBCustomItem не наследован от TControl, могут и другие такие появиться
  if Sender.InheritsFrom(TBasicAction) then
    LComponent := Sender as TComponent
  else
    if Sender.InheritsFrom(TTBCustomItem) then
      LComponent := TTBCustomItem(Sender).Action as TComponent
    else
    try
      LComponent := TCrackerAction(Sender).Action as TComponent;
    except
      {$IFDEF DEBUG}
        raise Exception.Create('Передан объек класса ' + Sender.ClassName + ' не имеющий свойства Action');
      {$ENDIF}
      Exit;
    end;
  LEventObject := FEventObjectList.FindAllObject(LComponent);

  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(LComponent) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cExecuteEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cExecuteEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnExit(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cExitEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cExitEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnFilterChanged(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cFilterChangedEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cFilterChangedEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnFilterChangedSQLFilter(Sender: TObject;
  const AnCurrentFilter: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TFilterChanged;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch, AnCurrentFilter]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cFilterChangedEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cFilterChangedEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TFilterRecordEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch,
      GetVarInterface(Accept)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cFilterRecordEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cFilterRecordEventName);
    // Обратное присвоение значений

    Accept := Boolean(GetVarParam(LParams[1]));

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnGetFooter(Sender: TObject;
  const FieldName: String;  const AggregatesObsolete: Boolean;
  var DisplayString: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TMovedEvent;
  LParams{, LResult}: Variant;
begin
  // здесь обработка ошибок аналогична OnPaint

  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      FieldName, AggregatesObsolete, GetVarInterface(DisplayString)]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cGetFooterEventName);
    // Выполнение события

    ExecuteEvent(LEventOfObject, LParams, Sender, cGetFooterEventName);
    DisplayString := String(GetVarParam(LParams[3]));
  end else
    raise Exception.Create(cMsgCantFindObject);
  // если удачное выполнение, то сбрасываем флаг в ложь
  FGetFooterFlag.Flag := False;
end;

procedure TEventControl.OnHide(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cHideEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cHideEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TKeyEvent;
  LParams: Variant;
//  IVarPar: IgsVarParam;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(Key), TShiftStateToStr(Shift)]);

    {!!!} {jkl} // Нет обратного присвоения параметров

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cKeyDownEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cKeyDownEventName);
    // Обратное присвоение значений

    Key := Word(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnKeyPress(Sender: TObject; var Key: Char);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TKeyPressEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(Key)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cKeyPressEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cKeyPressEventName);
    // Обратное присвоение значений

    LParams[1] := GetVarParam(LParams[1]);
    try
      if VarType(LParams[1]) = varOleStr then
        Key :=  String(LParams[1])[1]
      else
        if VarType(LParams[1]) = varSmallint then
          Key := Chr(Byte(LParams[1]))
        else begin
          exit;
        end;
    except
    end;
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TKeyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(Key), TShiftStateToStr(Shift)]);

    {!!!} {jkl} // Нет обратного присвоения параметров

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cKeyUpEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cKeyUpEventName);
    // Обратное присвоение значений

    Key := Word(GetVarParam(LParams[1]));
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TMeasureItemEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
// ??? вместо Sender Control
  LEventObject := FEventObjectList.FindAllObject(Control as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Control) as IDispatch, Index,
      GetVarInterface(Height)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cMeasureItemEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Control, cMeasureItemEventName);
    // Обратное присвоение значений

    Height := Integer(GetVarParam(LParams[2]));
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TMouseEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      TgsMouseButton(Button), TShiftStateToStr(Shift), X, Y]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cMouseDownEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cMouseDownEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TMouseMoveEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
{???}
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      TShiftStateToStr(Shift), X, Y]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cMouseMoveEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cMouseMoveEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TMouseEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      TgsMouseButton(Button), TShiftStateToStr(Shift), X, Y]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cMouseUpEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cMouseUpEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
  LgsPoint: TgsPoint;
  I: Integer;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    I := FPointList.IndexOf(Integer(Sender));
    if I = -1 then
    begin
      LgsPoint := TgsPoint.Create2(TComponent(Sender), FPointList);
      I := FPointList.Add(Integer(Sender));
      FPointList.ValuesByIndex[I] := Integer(LgsPoint);
    end else
      LgsPoint := TgsPoint(FPointList.ValuesByIndex[I]);
    LgsPoint.Point := MousePos;

    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      TShiftStateToStr(Shift), WheelDelta,
      GetGdcOLEObject(LgsPoint) as IDispatch, GetVarInterface(Handled)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cMouseWheelEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cMouseWheelEventName);
    // Обратное присвоение значений

    Handled := Boolean(GetVarParam(LParams[4]));

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
  LgsPoint: TgsPoint;
  I: Integer;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    I := FPointList.IndexOf(Integer(Sender));
    if I = -1 then
    begin
      LgsPoint := TgsPoint.Create2(TComponent(Sender), FPointList);
      I := FPointList.Add(Integer(Sender));
      FPointList.ValuesByIndex[I] := Integer(LgsPoint);
    end else
      LgsPoint := TgsPoint(FPointList.ValuesByIndex[I]);
    LgsPoint.Point := MousePos;

    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      TShiftStateToStr(Shift), GetGdcOLEObject(LgsPoint) as IDispatch, GetVarInterface(Handled)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cMouseWheelDownEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cMouseWheelDownEventName);
    // Обратное присвоение значений

    Handled := Boolean(GetVarParam(LParams[3]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
  LgsPoint: TgsPoint;
  I: Integer;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    I := FPointList.IndexOf(Integer(Sender));
    if I = -1 then
    begin
      LgsPoint := TgsPoint.Create2(TComponent(Sender), FPointList);
      I := FPointList.Add(Integer(Sender));
      FPointList.ValuesByIndex[I] := Integer(LgsPoint);
    end else
      LgsPoint := TgsPoint(FPointList.ValuesByIndex[I]);
    LgsPoint.Point := MousePos;

    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      TShiftStateToStr(Shift),
      GetGdcOLEObject(LgsPoint) as IDispatch, GetVarInterface(Handled)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cMouseWheelUpEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cMouseWheelUpEventName);
    // Обратное присвоение значений

    Handled := Boolean(GetVarParam(LParams[3]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnMove(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cMoveEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cMoveEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnNewRecord(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cNewRecordEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cNewRecordEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnPaint(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
{ TODO :
Если во время OnPaint возникла ошибка, обработчик ошибки пытается
показать диалоговое окно, во время вызова, которого снова вызывается
кривой OnPaint.
Т.е. при втором попадании в этот OnPaint его надо сразу отключить. }

  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cPaintEventName);

    ExecuteEvent(LEventOfObject, LParams, Sender, cPaintEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
  // если удачное выполнение, то сбрасываем флаг в ложь
  FPaintFlag.Flag := False;
end;

procedure TEventControl.OnPopup(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  // OpPopup вызывается и при нажатии "быстрых клавиш", в этом случае, естественно,
  // LEventObject будет не найден, поэтому исключение здесь не генерируем
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cPopupEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cPopupEventName);

  end;
//   else
//    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnPostError(DataSet: TDataSet; E: EDatabaseError;
  var Action: TDataAction);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TDataSetErrorEvent;
  LParams: Variant;
begin
  if Assigned(E) then
  begin
    // Поиск объекта вызывающего событие
    LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
    // Проверка результата поиска
    if Assigned(LEventObject) then
    begin
      // Формирование массива параметров. Различается в зависимости от параметров
      LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch,
        GetGdcOLEObject(E) as IDispatch, GetVarInterface(TgsDataAction(Action))]);

      // Поиск виртуального объекта для обработки события
      LEventOfObject := LEventObject.EventList.Find(cPostErrorEventName);
      // Выполнение события
      ExecuteEvent(LEventOfObject, LParams, DataSet, cPostErrorEventName);
      // Обратное присвоение значений

      try
        Action := TDataAction(GetVarParam(LParams[2]));
      except
      end;
      
    end else
      raise Exception.Create(cMsgCantFindObject);
  end;
end;

procedure TEventControl.OnRecreated(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cRecreatedEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cRecreatedEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnRecreating(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cRecreatingEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cRecreatingEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnResize(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cResizeEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cResizeEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TScrollEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
// ??? вместо Sender Control
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      TgsScrollCode(ScrollCode), GetVarInterface(ScrollPos)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cScrollEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cScrollEventName);
    // Обратное присвоение значений

    ScrollPos := Integer(GetVarParam(LParams[2]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnShow(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cShowEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cShowEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnStartDock(Sender: TObject;
  var DragObject: TDragDockObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TStartDockEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(GetGdcOLEObject(DragObject) as IDispatch)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cStartDockEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cStartDockEventName);

    DragObject := InterfaceToObject(GetVarParam(LParams[1])) as TDragDockObject;

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnStartDrag(Sender: TObject;
  var DragObject: TDragObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TStartDragEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(GetGdcOLEObject(DragObject) as IDispatch)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cStartDragEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cStartDragEventName);
    // Обратное присвоение значений
    DragObject := InterfaceToObject(GetVarParam(LParams[1])) as TDragObject;

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnStateChange(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cStateChangeEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cStateChangeEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnTimer(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cTimerEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cTimerEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TUnDockEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Client) as IDispatch, GetGdcOLEObject(NewTarget) as IDispatch,
      GetVarInterface(Allow)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cUnDockEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cUnDockEventName);
    // Обратное присвоение значений

    Allow := Boolean(GetVarParam(LParams[3]));
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnUpdate(Action: TBasicAction;
  var Handled: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TActionEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
// ??? вместо Sender Action no
  LEventObject := FEventObjectList.FindAllObject(Action as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Action) as IDispatch,
      GetVarInterface(Handled)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cUpdateEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Action, cUpdateEventName);
    // Обратное присвоение значений

    Handled := Boolean(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnUpdateAction(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cUpdateEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cUpdateEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnUpdateData(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cUpdateDataEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cUpdateDataEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnUpdateError(DataSet: TDataSet; E: EDatabaseError;
  UpdateKind: TUpdateKind; var UpdateAction: TIBUpdateAction);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TIBUpdateErrorEvent;
  LParams: Variant;
begin
  if Assigned(E) then
  begin
    // Поиск объекта вызывающего событие
    LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
    // Проверка результата поиска
    if Assigned(LEventObject) then
    begin
      // Формирование массива параметров. Различается в зависимости от параметров
      LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch,
        GetGdcOLEObject(E) as IDispatch, TgsUpdatekind(UpdateKind),
        GetVarInterface(TgsIBUpdateAction(UpdateAction))]);

      // Поиск виртуального объекта для обработки события
      LEventOfObject := LEventObject.EventList.Find(cUpdateErrorEventName);
      // Выполнение события
      ExecuteEvent(LEventOfObject, LParams, DataSet, cUpdateErrorEventName);
      // Обратное присвоение значений

      try
        UpdateAction := TIBUpdateAction(GetVarParam(LParams[3]));
      except
      end;
    end else
      raise Exception.Create(cMsgCantFindObject);
  end;
end;

procedure TEventControl.OnUpdateRecord(DataSet: TDataSet;
  UpdateKind: TUpdateKind; var UpdateAction: TIBUpdateAction);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TIBUpdateRecordEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch,
      TgsUpdateKind(UpdateKind), GetVarInterface(TgsIBUpdateAction(UpdateAction))]);

    {!!!} {jkl} // Нет обратного присвоения параметров

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cUpdateRecordEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cUpdateRecordEventName);
    // Обратное присвоение значений

{    try
      UpdateAction := TIBUpdateAction(LParams[2]);
    except
    end;
    
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnVisibleChanged(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cVisibleChangedEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cVisibleChangedEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

function TEventControl.PropertyClose: Boolean;
begin
  Result := True;
  if Assigned(frmGedeminProperty) then
  begin
    Result := frmGedeminProperty.CloseQuery;
    if Result then frmGedeminProperty.Close;
  end;
end;


procedure TEventControl.DisableProperty;
begin
  if Assigned(frmGedeminProperty) then
  begin
    Inc(FPropertyDisableCount);
    if frmGedeminProperty.Enabled then
      frmGedeminProperty.Enabled := False;
  end;
end;

procedure TEventControl.PropertyNotification(AComponent: TComponent;
  Operation: TPrpOperation; const AOldName: string);
begin
  if not Application.Terminated and Assigned(frmGedeminProperty) then
    frmGedeminProperty.PropertyNotification(AComponent, Operation, AOldName);
end;

procedure TEventControl.EnableProperty;
begin
  if Assigned(frmGedeminProperty) then
  begin
    if FPropertyDisableCount > 0 then
      Dec(FPropertyDisableCount);

    if FPropertyDisableCount = 0 then
      frmGedeminProperty.Enabled := True;
  end;
end;

procedure TEventControl.ResetChildComponentEvent(
  const AnComponent: TComponent; const AnEventObject: TEventObject);
var
  I: Integer;
begin
  if Assigned(AnEventObject) then
    for I := 0 to AnComponent.ComponentCount - 1 do
      ResetComponentEvent(AnComponent.Components[I],
       AnEventObject.ChildObjects.FindObject(AnComponent.Components[I].Name));
end;

procedure TEventControl.ResetChildEvents(AnComponent: TComponent);
begin
  ResetChildComponentEvent(AnComponent, FEventObjectList.FindAllObject(AnComponent));
end;

procedure TEventControl.ResetComponentEvent(const AnComponent: TComponent;
  const AnEventObject: TEventObject);
var
  TempPropList: TPropList;
  TempPropInfo: PPropInfo;
  I, J: Integer;
  E: TEventItem;
begin
  if Assigned(AnEventObject) then
  begin
    J := GetPropList(AnComponent.ClassInfo, [tkMethod], @TempPropList);

    for I := 0 to J - 1 do
    begin
      E := AnEventObject.EventList.Find(TempPropList[I]^.Name);
      if (E <> nil) and (E.FunctionKey > 0) then
      begin
        if E.IsOldEventSet then
        begin
          TempPropInfo := GetPropInfo(AnComponent, TempPropList[I]^.Name);
          SetMethodProp(AnComponent, TempPropInfo,
           AnEventObject.EventList.ItemByName[TempPropList[I]^.Name].OldEvent);
        end;   
        AnEventObject.EventList.ItemByName[TempPropList[I]^.Name].Reset;
      end;
    end;  

    for I := 0 to AnComponent.ComponentCount - 1 do
      ResetComponentEvent(AnComponent.Components[I],
       AnEventObject.ChildObjects.FindObject(AnComponent.Components[I].Name));
  end;
end;

procedure TEventControl.ResetEvents(AnComponent: TComponent);
var
  I: Integer;
  EventObject: TEventObject;
begin
//  ResetComponentEvent(AnComponent, FEventObjectList.FindAllObject(AnComponent));
  EventObject := FEventObjectList.FindObjectAndIndex(AnComponent, I);
  if EventObject = nil then
    Exit;

  ResetComponentEvent(AnComponent, EventObject);
  if I > -1 then
    EventObject.ParentList.RemoveDinamicObject(AnComponent);

end;

procedure TEventControl.SafeCallSetEvents(AnComponent: TComponent);
begin
  SetComponentEvent(AnComponent, FEventObjectList.FindAllObject(AnComponent),
   False, True);
end;

procedure TEventControl.SetChildComponentEvent(
  const AnComponent: TComponent; const AnEventObject: TEventObject;
  const AnSafeMode: Boolean);
var
  I: Integer;
begin
  if Assigned(AnEventObject) then
  begin
    for I := 0 to AnComponent.ComponentCount - 1 do
    begin
      if AnComponent.Components[I].InheritsFrom(TBasicAction) then
        SetComponentEvent(AnComponent.Components[I],
          AnEventObject.ChildObjects.FindObject(AnComponent.Components[I].Name),
          True, AnSafeMode);
    end;
    for I := 0 to AnComponent.ComponentCount - 1 do
    begin
      if not AnComponent.Components[I].InheritsFrom(TBasicAction) then
        SetComponentEvent(AnComponent.Components[I],
          AnEventObject.ChildObjects.FindObject(AnComponent.Components[I].Name),
          True, AnSafeMode);
    end;
  end;
end;

procedure TEventControl.SetChildEvents(AnComponent: TComponent);
begin
  SetChildComponentEvent(AnComponent,
   FEventObjectList.FindAllObject(AnComponent), False);
end;

procedure TEventControl.SetComponentEvent(const AnComponent: TComponent;
  const AnEventObject: TEventObject; const OnlyComponent: Boolean;
  const AnSafeMode: Boolean);
var
  LName: string;
  TempPropList: TPropList;
  TempPropInfo: PPropInfo;
  MP: TMethod;
  I, J: Integer;
  LEventItem: TEventItem;
  EI: TEventItem;
begin
  if UnEventMacro then
    Exit;

  if Assigned(AnEventObject) then
  begin
    AnEventObject.ObjectRef := AnComponent;
    J := GetPropList(AnComponent.ClassInfo, [tkMethod], @TempPropList);
    for I := 0 to J - 1 do
    begin
      EI := AnEventObject.EventList.Find(TempPropList[I]^.Name);
      if (EI <> nil) and (EI.FunctionKey <> 0) and (not EI.Disable) then
      begin
        MP.Code := nil;
        MP.Data := nil;

        TempPropInfo := GetPropInfo(AnComponent, TempPropList[I]^.Name);
        LName := AnsiUpperCase(TempPropList[I]^.Name);

        // Ищем событие среди зарегистрированных
        if FEventList.IndexOf(LName) > -1 then
        begin
          // Для некоторых имен событий есть разный тип для разных классов.
          // Проверка для этих событий на тип.
          if LName = cPopupEventName then
          begin
            if TempPropList[I]^.PropType^^.Name = 'TNotifyEvent' then
              MP.Code := Self.MethodAddress(cPopupEventName)
            else
              if (TempPropList[I]^.PropType^^.Name = 'TTBPopupEvent') then
                MP.Code := Self.MethodAddress(cTBPopupEventName)
          end else
            if LName = cExecuteEventName then
            begin
              if TempPropList[I]^.PropType^^.Name = 'TActionEvent' then
                MP.Code := Self.MethodAddress(cExecuteEventName)
              else
                if (TempPropList[I]^.PropType^^.Name = 'TNotifyEvent') then
                  MP.Code := Self.MethodAddress(cExecuteActionEventName)
            end else
              if LName = cUpdateEventName then
              begin
                if TempPropList[I]^.PropType^^.Name = 'TActionEvent' then
                  MP.Code := Self.MethodAddress(cUpdateEventName)
                else
                  if (TempPropList[I]^.PropType^^.Name = 'TNotifyEvent') then
                    MP.Code := Self.MethodAddress(cUpdateActionEventName)
              end else
                if LName = cChangeEventName then
                begin
                  if TempPropList[I]^.PropType^^.Name = 'TMenuChangeEvent' then
                    MP.Code := Self.MethodAddress(cChangeEventName)
                  else
                    if (TempPropList[I]^.PropType^^.Name = 'TNotifyEvent') or
                       (TempPropList[I]^.PropType^^.Name = 'TFieldNotifyEvent')
                    then
                      MP.Code := Self.MethodAddress(cChangeEditEventName)
                    else
                      if (TempPropList[I]^.PropType^^.Name = 'TTVChangedEvent') then
                        MP.Code := Self.MethodAddress(cChangeTVEventName)
                end else
                  if LName = cFilterChangedEventName then
                  begin
                    if TempPropList[I]^.PropType^^.Name = 'TNotifyEvent' then
                      MP.Code := Self.MethodAddress(cFilterChangedEventName)
                    else
                      if TempPropList[I]^.PropType^^.Name = 'TFilterChanged' then
                        MP.Code := Self.MethodAddress(cFilterChangedSQLFilterEventName)
                  end else
                    if LName = cChangingEventName then
                    begin
                      if TempPropList[I]^.PropType^^.Name = 'cChangeTabEventNamet' then
                        MP.Code := Self.MethodAddress(cChangingEventName)
                      else
                        if TempPropList[I]^.PropType^^.Name = 'TTVChangingEvent' then
                          MP.Code := Self.MethodAddress(cChangingTVEventName)
                    end else
                      if LName = cCloseEventName then
                      begin
                        if TempPropList[I]^.PropType^^.Name = 'TNotifyEvent' then
                          MP.Code := Self.MethodAddress(cCloseNotifyEventName)
                        else
                          if TempPropList[I]^.PropType^^.Name = 'TCloseEvent' then
                            MP.Code := Self.MethodAddress(cCloseEventName)
                      end else
                        if LName = cClickCheckEventName then
                        begin
                          if TempPropList[I]^.PropType^^.Name = 'TCheckBoxEvent' then
                            MP.Code := Self.MethodAddress(cClickCheckEventName)
                          else
                            if (TempPropList[I]^.PropType^^.Name = 'TNotifyEvent') then
                              MP.Code := Self.MethodAddress(cClickCheckListBoxEventName)
                        end else
                          MP.Code := Self.MethodAddress(LName);
        end;
        MP.Data := Self;
        if not Assigned(MP.Code) then
          Exception.Create(GetGsException(Self, 'Can''t find event procedure.'));
        LEventItem := AnEventObject.EventList.ItemByName[TempPropList[I]^.Name];

        if not (AnSafeMode and LEventItem.IsOldEventSet) then
        begin
          if not LEventItem.IsOldEventSet then
            //Если значение дельфовского обработчика еще не сохранено то
            //сохраняем его
            LEventItem.OldEvent := GetMethodProp(AnComponent, TempPropInfo);
          //Установливаем новый обработчик события
          SetMethodProp(AnComponent, TempPropInfo, MP);
        end;

      end;
    end;
    if not OnlyComponent then
      SetChildComponentEvent(AnComponent, AnEventObject, AnSafeMode);
  end;
end;

procedure TEventControl.SetDatabase(const AnDatabase: TIBDatabase);
begin
  if AnDatabase <> FDatabase then
  begin
    FDatabase := AnDatabase;
    if Assigned(FTransaction) then
      FTransaction.DefaultDatabase := FDatabase;
  end;
end;

procedure TEventControl.SetEvents(AnComponent: TComponent; 
  const OnlyComponent: Boolean = False);
begin
  if AnComponent <> nil then
    SetComponentEvent(AnComponent, FEventObjectList.FindAllObject(AnComponent),
     OnlyComponent, False);
end;

function TEventControl.SetSingleEvent(const AnComponent: TComponent;
  const AnEventName: String; const AHandlerMethod: Pointer): Boolean;
var
  TempPropList: TPropList;
  TempPropInfo: PPropInfo;
  MP: TMethod;
  I, J: Integer;
begin
  Result := False;
  J := GetPropList(AnComponent.ClassInfo, [tkMethod], @TempPropList);
  for I := 0 to J - 1 do
  begin
    begin
      TempPropInfo := GetPropInfo(AnComponent, TempPropList[I]^.Name);
      AnsiUpperCase(TempPropList[I]^.Name);

      if AnsiUpperCase(TempPropList[I]^.Name) = AnEventName then
      begin
        MP.Code := AHandlerMethod;
        MP.Data := Self;
        SetMethodProp(AnComponent, TempPropInfo, MP);
        Break;
      end;
    end;
  end;
end;

procedure TEventControl.TransactionFree(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TNotifyEvent;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cTransactionFreeEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cTransactionFreeEventName);
{
    if Assigned(LEventOfObject.OldEvent.Code) then
    begin
      LEvent := @LEventOfObject.OldEvent.Code;
      LEvent^(Sender);
    end;
    }
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AssignEvents(const Source, Acceptor: TComponent);
begin
  if Source.InheritsFrom(TCreateableForm) then
    AssignEvents(TCreateableForm(Source).InitialName, Acceptor)
  else
    if FEventObjectList.AddDinamicEventObject(Source, Acceptor) then
      FreeNotification(Acceptor);
end;

procedure TEventControl.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  EvtObj: TEventObject;
begin
  inherited;

  if (Operation = Classes.opRemove) then
  begin
    if Assigned(FEventObjectList) then
      FEventObjectList.RemoveDinamicObject(AComponent);
    if Assigned(FDynamicCreatedEventObjects) and (FDynamicCreatedEventObjects.IndexOf(AComponent) > -1) then begin
      EvtObj:= EventObjectList.FindObject(AComponent);
      if Assigned(EvtObj) then
        EventObjectList.Remove(EvtObj);
      FDynamicCreatedEventObjects.Remove(AComponent);
    end;
  end;
end;

procedure TEventControl.FillEventList;
begin
  FEventList.Add(cClickEventName);
  FEventList.Add(cPopupEventName);
  FEventList.Add(cCanResizeEventName);
  FEventList.Add(cCreateEventName);
  FEventList.Add(cConstrainedResizeEventName);
  FEventList.Add(cContextPopupEventName);
  FEventList.Add(cDblClickEventName);
  FEventList.Add(cDragDropEventName);
  FEventList.Add(cDragOverEventName);
  FEventList.Add(cEndDockEventName);
  FEventList.Add(cEndDragEventName);
  FEventList.Add(cMouseDownEventName);
  FEventList.Add(cMouseMoveEventName);
  FEventList.Add(cMouseUpEventName);
  FEventList.Add(cResizeEventName);
  FEventList.Add(cStartDockEventName);
  FEventList.Add(cStartDragEventName);
  FEventList.Add(cDockDropEventName);
  FEventList.Add(cDockOverEventName);
  FEventList.Add(cEnterEventName);
  FEventList.Add(cExitEventName);
  FEventList.Add(cKeyDownEventName);
  FEventList.Add(cKeyPressEventName);
  FEventList.Add(cKeyUpEventName);
  FEventList.Add(cMouseWheelEventName);
  FEventList.Add(cMouseWheelDownEventName);
  FEventList.Add(cMouseWheelUpEventName);
  FEventList.Add(cUnDockEventName);
  FEventList.Add(cActivateEventName);
  FEventList.Add(cCloseQueryEventName);
  FEventList.Add(cDeactivateEventName);
  FEventList.Add(cDestroyEventName);
  FEventList.Add(cHideEventName);
  FEventList.Add(cPaintEventName);
  FEventList.Add(cShowEventName);
  FEventList.Add(cDrawItemEventName);
  FEventList.Add(cMeasureItemEventName);
  FEventList.Add(cDropDownEventName);
  FEventList.Add(cScrollEventName);
  FEventList.Add(cExecuteEventName);
  FEventList.Add(cUpdateEventName);
  FEventList.Add(cMoveEventName);
  FEventList.Add(cRecreatedEventName);
  FEventList.Add(cRecreatingEventName);
  FEventList.Add(cDockChangedEventName);
  FEventList.Add(cDockChangingEventName);
  FEventList.Add(cDockChangingHiddenEventName);
  FEventList.Add(cVisibleChangedEventName);
  FEventList.Add(cColEnterEventName);
  FEventList.Add(cColExitEventName);
  FEventList.Add(cColumnMovedEventName);
  FEventList.Add(cDrawColumnCellEventName);
  FEventList.Add(cDrawDataCellEventName);
  FEventList.Add(cCellClickEventName);
  FEventList.Add(cEditButtonClickEventName);
  FEventList.Add(cGetFooterEventName);
  FEventList.Add(cGetTotalEventName);
  FEventList.Add(cAggregateChangedEventName);
  FEventList.Add(cClickCheckEventName);
  FEventList.Add(cClickedCheckEventName);
  FEventList.Add(cAfterCancelEventName);
  FEventList.Add(cAfterCloseEventName);
  FEventList.Add(cAfterDeleteEventName);
  FEventList.Add(cAfterEditEventName);
  FEventList.Add(cAfterInsertEventName);
  FEventList.Add(cAfterOpenEventName);
  FEventList.Add(cAfterPostEventName);
  FEventList.Add(cAfterRefreshEventName);
  FEventList.Add(cAfterScrollEventName);
  FEventList.Add(cBeforeCancelEventName);
  FEventList.Add(cBeforeCloseEventName);
  FEventList.Add(cBeforeDeleteEventName);
  FEventList.Add(cBeforeEditEventName);
  FEventList.Add(cBeforeInsertEventName);
  FEventList.Add(cBeforeOpenEventName);
  FEventList.Add(cBeforePostEventName);
  FEventList.Add(cBeforeScrollEventName);
  FEventList.Add(cCalcFieldsEventName);
  FEventList.Add(cDeleteErrorEventName);
  FEventList.Add(cEditErrorEventName);
  FEventList.Add(cFilterRecordEventName);
  FEventList.Add(cNewRecordEventName);
  FEventList.Add(cPostErrorEventName);
  FEventList.Add(cAfterDatabaseDisconnectEventName);
  FEventList.Add(cAfterTransactionEndEventName);
  FEventList.Add(cBeforeDatabaseDisconnectEventName);
  FEventList.Add(cBeforeTransactionEndEventName);
  FEventList.Add(cDatabaseFreeEventName);
  FEventList.Add(cUpdateErrorEventName);
  FEventList.Add(cUpdateRecordEventName);
  FEventList.Add(cTransactionFreeEventName);
  FEventList.Add(cOnCalcAggregatesEventName);
  FEventList.Add(cDatabaseDisconnectedEventName);
  FEventList.Add(cDatabaseDisconnectingEventName);
  FEventList.Add(cAfterInitSQLEventName);
  FEventList.Add(cBeforeShowDialogEventName);
  FEventList.Add(cAfterShowDialogEventName);
  FEventList.Add(cDataChangeEventName);
  FEventList.Add(cStateChangeEventName);
  FEventList.Add(cUpdateDataEventName);
  FEventList.Add(cCreateNewObjectEventName);
  FEventList.Add(cAfterCreateDialogEventName);
  FEventList.Add(cTimerEventName);
  FEventList.Add(cConditionChangedEventName);
  FEventList.Add(cChangeEventName);
  FEventList.Add(cFilterChangedEventName);
  FEventList.Add(cCloseEventName);
  FEventList.Add(cSyncFieldEventName);
  FEventList.Add(cTestCorrectEventName);
  FEventList.Add(cSetupRecordEventName);
  FEventList.Add(cSetupDialogEventName);

  FEventList.Add(cAfterInternalPostRecordEventName);
  FEventList.Add(cBeforeInternalPostRecordEventName);
  FEventList.Add(cAfterInternalDeleteRecordEventName);
  FEventList.Add(cBeforeInternalDeleteRecordEventName);

  FEventList.Add(cGetTextEventName);
  FEventList.Add(cSetTextEventName);
  FEventList.Add(cValidateEventName);

  FEventList.Add(cModemSendEventName);
  FEventList.Add(cModemReceiveEventName);
  FEventList.Add(cModemOpenPortEventName);
  FEventList.Add(cModemClosePortEventName);
  FEventList.Add(cModemErrorEventName);

  FEventList.Add(cOnGetSelectClauseEventName);
  FEventList.Add(cOnGetFromClauseEventName);
  FEventList.Add(cOnGetWhereClauseEventName);
  FEventList.Add(cOnGetGroupClauseEventName);
  FEventList.Add(cOnGetOrderClauseEventName);
  FEventList.Add(cChangingEventName);

  FEventList.Add(cSaveSettingsEventName);
  FEventList.Add(cLoadSettingsAfterCreateEventName);
  FEventList.Add(cWebBrowserBeforeNavigate2Name);
  FEventList.Add(cWebBrowserDocumentCompleteName);
end;

function TEventControl.GetPropertyCanChangeCaption: Boolean;
begin
  Result := False;
  if frmGedeminProperty <> nil then
    Result := frmGedeminProperty.CanChangeCaption;
end;

procedure TEventControl.SetPropertyCanChangeCaption(const Value: Boolean);
begin
  if frmGedeminProperty <> nil then
    frmGedeminProperty.CanChangeCaption := Value;
end;

function TEventControl.GetPropertyHanlde: THandle;
begin
  Result := 0;
  if frmGedeminProperty <> nil then
    Result := frmGedeminProperty.Handle;
end;

{procedure TEventControl.ReportRefresh;
begin
  if Assigned(frmGedeminProperty) then
    ;
//    frmGedeminProperty.RefreshTree;
end;}

procedure TEventControl.RegisterFrmReport(frmReport: TObject);
begin
  if (frmReport is Tgdc_frmMDVTree) and
    (Tgdc_frmMDVTree(frmReport).gdcObject is TgdcReportGroup) then
    FgdcReportGroupList.Add(Integer(frmReport));
end;

procedure TEventControl.UnRegisterFrmReport(
  frmReport: TObject);
begin
  if frmReport is Tgdc_frmMDVTree  and
    (Tgdc_frmMDVTree(frmReport).gdcObject is TgdcReportGroup) then
    FgdcReportGroupList.Remove(Integer(frmReport));
end;

procedure TEventControl.UpdateReportGroup;
var
  i: Integer;
begin
  for i := 0 to FgdcReportGroupList.Count - 1 do
  begin
    Tgdc_frmMDVTree(FgdcReportGroupList.Keys[i]).tvGroup.Refresh;
  end;
end;

procedure TEventControl.OnSyncField(
  Sender: TObject; Field: TField; SyncList: TList);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Field) as IDispatch, GetGdcOLEObject(SyncList) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cSyncFieldEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cSyncFieldEventName);
    
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

{procedure TEventControl.ChangeReport(const ReportObject: TObject;
  const ChangeType: TChangeReportType);
var
  LReportGroup: TgdcReportGroup;
begin
  if not Assigned(frmGedeminProperty) then
    Exit;

  case ChangeType of
    ctReportGroupAdd:
    begin
      if ReportObject is TgdcReportGroup then
      begin
        LReportGroup := TgdcReportGroup(ReportObject);
        frmGedeminProperty.AddReportFolder(LReportGroup.Parent,
          LReportGroup.ID, LReportGroup.FieldByName('Name').AsString);
      end;
    end;
  end
end;

procedure TEventControl.DeleteReportGroup(const ParendID, ID: Integer;
  const ChangeType: TChangeReportType);
begin
  if not Assigned(frmGedeminProperty) then
    Exit;

  case ChangeType of
    ctReportGroupDelete:
    begin
      frmGedeminProperty.DeleteReportFolder(ParendID, ID);
    end;
  end;
end;

procedure TEventControl.DeleteReport(const ParentID, ID: Integer;
  const ChangeType: TChangeReportType);
begin
  if not Assigned(frmGedeminProperty) then
    Exit;

  case ChangeType of
    ctReportDelete:
    begin
      frmGedeminProperty.DeleteReport(ParentID, ID);
    end;
  end;
end;}

procedure TEventControl.PropertyUpDateErrorsList;
begin
  if frmGedeminProperty <> nil then
    frmGedeminProperty.UpdateErrors;
end;

procedure TEventControl.OnAfterCreateDialog(Sender: TObject;
  ANewObject: TgdcBase);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TOnCreateNewObject;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(ANewObject) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterCreateDialogEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cAfterCreateDialogEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(Text), DisplayText]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cGetTextEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cGetTextEventName);
    // Обратное присвоение значений
    Text := String(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnSetText(Sender: TField; const Text: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch, Text]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cSetTextEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cSetTextEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnValidate(Sender: TField);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cValidateEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cValidateEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

{procedure TEventControl.OverSetEvents(AnComponent: TComponent);
var
  LEventObject: TEventObject;
  TempPropList: TPropList;
  TempPropInfo: PPropInfo;
  I, J: Integer;
  E: TEventItem;
begin
  if AnComponent = nil then
    Exit;


  LEventObject := FEventObjectList.FindAllObject(AnComponent);
  if Assigned(LEventObject) then
  begin
    J := GetPropList(AnComponent.ClassInfo, [tkMethod], @TempPropList);

    for I := 0 to J - 1 do
    begin
      E := LEventObject.EventList.Find(TempPropList[I]^.Name);
      if E <> nil then
      begin
        TempPropInfo := GetPropInfo(AnComponent, TempPropList[I]^.Name);
        SetMethodProp(AnComponent, TempPropInfo,
          E.OldEvent);
        E.FIsOldEventSet := False;
      end;
    end;
  end;

  SetComponentEvent(AnComponent, FEventObjectList.FindAllObject(AnComponent),
    True, False);
end;}

function TEventControl.OnTestCorrect(Sender: TObject): Boolean;
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
  SrcResult: OleVariant;
begin
  Result := True;
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cTestCorrectEventName);
    // Выполнение события
    SrcResult := ExecuteEvent(LEventOfObject, LParams, Sender, cTestCorrectEventName);
    if VarType(SrcResult) = varBoolean then
      Result := Boolean(SrcResult)
    else
    begin
      if VarType(SrcResult) <> varEmpty then
        raise Exception.Create('Несоответствие типа. Тип возвращенный обработчиком OnTestCorrect не Boolean.');
    end;

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnSetupDialog(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cSetupDialogEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cSetupDialogEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnSetupRecord(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cSetupRecordEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cSetupRecordEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AssignEvents(const SourceName: String;
  Acceptor: TComponent);
begin
  if FEventObjectList.AddDinamicEventObject(SourceName, Acceptor) then
    FreeNotification(Acceptor);
end;

procedure TEventControl.OnGetFromClause(Sender: TObject;
  var Clause: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(Clause)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cOnGetFromClauseEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cOnGetFromClauseEventName);
    // Обратное присвоение значений

    Clause := String(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnGetGroupClause(Sender: TObject;
  var Clause: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(Clause)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cOnGetGroupClauseEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cOnGetGroupClauseEventName);
    // Обратное присвоение значений

    Clause := String(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnGetOrderClause(Sender: TObject;
  var Clause: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(Clause)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cOnGetOrderClauseEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cOnGetOrderClauseEventName);
    // Обратное присвоение значений

    Clause := String(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnGetSelectClause(Sender: TObject;
  var Clause: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(Clause)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cOnGetSelectClauseEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cOnGetSelectClauseEventName);
    // Обратное присвоение значений

    Clause := String(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnGetWhereClause(Sender: TObject;
  var Clause: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(Clause)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cOnGetWhereClauseEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cOnGetWhereClauseEventName);
    // Обратное присвоение значений

    Clause := String(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.RebootEvents(AnComponent: TComponent);
begin
  ResetEvents(AnComponent);
  SetEvents(AnComponent);
end;

{procedure TEventControl.OnChangeTab(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cChangeEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cChangeEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;}

procedure TEventControl.OnChanging(Sender: TObject;
  var AllowChange: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetVarInterface(AllowChange)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cChangingEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cChangingEventName);
    // Обратное присвоение значений
    AllowChange := Boolean(GetVarParam(LParams[1]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnCalcAggregates(DataSet: TDataSet;
  var Accept: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch,
      GetVarInterface(Accept)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cOnCalcAggregatesEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cOnCalcAggregatesEventName);
    // Обратное присвоение значений

    try
      Accept := GetVarParam(LParams[1]);
    except
    end;
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.Drop;
begin
  FEventObjectList.Clear;
end;

procedure TEventControl.OnGetTotal(Sender: TObject;
  const FieldName: String; const AggregatesObsolete: Boolean;
  var DisplayString: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // здесь обработка ошибок аналогична OnPaint

  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      FieldName, AggregatesObsolete, GetVarInterface(DisplayString)]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cGetTotalEventName);

    ExecuteEvent(LEventOfObject, LParams, Sender, cGetTotalEventName);
    DisplayString := String(GetVarParam(LParams[3]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnReceive(Sender: TObject; AFileName: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch, AFileName]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cModemReceiveEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cModemReceiveEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnSend(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cModemSendEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cModemSendEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnOpenPort(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cModemOpenPortEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cModemOpenPortEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnClosePort(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cModemClosePortEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cModemClosePortEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnError(Sender: TObject; ErrorCode: Integer;
  ErrorDescription: String);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch, ErrorCode, ErrorDescription]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cModemErrorEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cModemErrorEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnClickCheckListBox(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cClickCheckEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cClickCheckEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.PrepareSOEditorForModal;
begin
  frmGedeminProperty.PrepareForModal;
end;

procedure TEventControl.OnSaveSettings(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cSaveSettingsEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cSaveSettingsEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnLoadSettingsAfterCreate(Sender: TObject);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cLoadSettingsAfterCreateEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cLoadSettingsAfterCreateEventName);
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnChangeTV(Sender: TObject; Node: TTreeNode);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
//  LEvent: ^TMenuChangeEvent;
  LParams: Variant;
begin
  if Assigned(Sender) then
  begin
    // Поиск объекта вызывающего событие
    LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
    // Проверка результата поиска
    if Assigned(LEventObject) then
    begin
      // Формирование массива параметров. Различается в зависимости от параметров
      LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
        GetGdcOLEObject(Node) as IDispatch]);
      // Поиск виртуального объекта для обработки события
      LEventOfObject := LEventObject.EventList.Find(cChangeEventName);
      // Выполнение события
      ExecuteEvent(LEventOfObject, LParams, Sender, cChangeEventName);

    end else
      raise Exception.Create(cMsgCantFindObject);
  end;
end;

procedure TEventControl.OnChangingTV(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      GetGdcOLEObject(Node) as IDispatch,
      GetVarInterface(AllowChange)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cChangingEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cChangingEventName);
    // Обратное присвоение значений

    AllowChange := Boolean(GetVarParam(LParams[2]));

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnTBPopup(Sender: TTBCustomItem;
  FromLink: Boolean);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch, FromLink]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cPopupEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, Sender, cPopupEventName);
  end;
end;

procedure TEventControl.OnBeforeNavigate2(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      pDisp, GetVarInterface(URL), GetVarInterface(Flags),
      GetVarInterface(TargetFrameName), GetVarInterface(PostData),
      GetVarInterface(Headers), GetVarInterface(Cancel)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cWebBrowserBeforeNavigate2Name);

    ExecuteEvent(LEventOfObject, LParams, Sender, cWebBrowserBeforeNavigate2Name);

    URL := OleVariant(GetVarParam(LParams[2]));
    Flags := OleVariant(GetVarParam(LParams[3]));
    TargetFrameName := OleVariant(GetVarParam(LParams[4]));
    PostData := OleVariant(GetVarParam(LParams[5]));
    Headers := OleVariant(GetVarParam(LParams[6]));
    Cancel := WordBool(GetVarParam(LParams[7]));

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterInternalDeleteRecord(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterInternalDeleteRecordEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterInternalDeleteRecordEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.AfterInternalPostRecord(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cAfterInternalPostRecordEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cAfterInternalPostRecordEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeInternalDeleteRecord(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeInternalDeleteRecordEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforeInternalDeleteRecordEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.BeforeInternalPostRecord(DataSet: TDataSet);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(DataSet as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(DataSet) as IDispatch]);
    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cBeforeInternalPostRecordEventName);
    // Выполнение события
    ExecuteEvent(LEventOfObject, LParams, DataSet, cBeforeInternalPostRecordEventName);

  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.OnDocumentComplete(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
  LEventObject: TEventObject;
  LEventOfObject: TEventItem;
  LParams: Variant;
begin
  // Поиск объекта вызывающего событие
  LEventObject := FEventObjectList.FindAllObject(Sender as TComponent);
  // Проверка результата поиска
  if Assigned(LEventObject) then
  begin
    // Формирование массива параметров. Различается в зависимости от параметров
    LParams := VarArrayOf([GetGdcOLEObject(Sender) as IDispatch,
      pDisp, GetVarInterface(URL)]);

    // Поиск виртуального объекта для обработки события
    LEventOfObject := LEventObject.EventList.Find(cWebBrowserDocumentCompleteName);

    ExecuteEvent(LEventOfObject, LParams, Sender, cWebBrowserDocumentCompleteName);

    URL := OleVariant(GetVarParam(LParams[2]));
  end else
    raise Exception.Create(cMsgCantFindObject);
end;

procedure TEventControl.ResetAllEvents(ObjectList: TEventObjectList);
var
  I: Integer;
begin
  for I := 0 to ObjectList.Count - 1 do
  begin
    ResetAllEvents(ObjectList.EventObject[i].ChildObjects);
    ResetEvents(ObjectList.EventObject[i].SelfObject);
  end;

  for I :=  0 to ObjectList.FDinamicEventArray.Count - 1 do
  begin
    ResetAllEvents(TEventObject(ObjectList.FDinamicEventArray.ObjectByIndex[i]).ChildObjects);
    ResetEvents(TEventObject(ObjectList.FDinamicEventArray.ObjectByIndex[i]).SelfObject);
  end;
end;

function TEventControl.AddDynamicCreatedEventObject(
  AnComponent: TComponent): integer;
begin
  Result:= EventObjectList.AddObject(nil);
  EventObjectList.EventObject[Result].ObjectRef:= AnComponent;
  if not Assigned(FDynamicCreatedEventObjects) then
    FDynamicCreatedEventObjects:= TObjectList.Create(False);
  FDynamicCreatedEventObjects.Add(AnComponent);
  AnComponent.FreeNotification(self);
end;

function TEventControl.FindRealEventObject(AnComponent: TComponent;
  const AName: TComponentName): TEventObject;
begin
  Result:= nil;
  if not Assigned(AnComponent) then Exit;
  if AnComponent is TCustomForm then begin
    if AName <> '' then
      Result:= EventObjectList.FindObject(AName)
    else
      Result:= EventObjectList.FindObject(AnComponent.Name);
    Exit;
  end
  else
    Result:= FindRealEventObject(AnComponent.Owner);
  if not Assigned(Result) then Exit;
  if AName <> '' then
    Result:= Result.ChildObjects.FindObject(AName)
  else
    Result:= Result.ChildObjects.FindObject(AnComponent.Name);
end;

{ TgsFunctionList }

function TgsFunctionList.AddFromDataSet(AnDataSet: TDataSet): TrpCustomFunction;
begin
  Result := TrpCustomFunction.Create;
  Result.FunctionKey := AnDataSet.FieldByName('id').AsInteger;
  AddFunction(Result);
  Result.ReadFromDataSet(AnDataSet);
end;

procedure TgsFunctionList.AddFunction(
  const AnFunction: TrpCustomFunction);
begin
  if Assigned(AnFunction) then
  begin
    FSortFuncList.AddObject(AnFunction.FunctionKey, AnFunction);
    AnFunction.OnBreakPointsPrepared := Self.OnBreakPointsPrepared;
  end;
end;

procedure TgsFunctionList.Clear;
begin
  MethodControl.ClearMacroCache;
  FSortFuncList.Clear;
end;

constructor TgsFunctionList.Create(Owner: TComponent);
begin
  Assert(glbFunctionList = nil);

  inherited Create(Owner);

  FSortFuncList := TgdKeyObjectAssoc.Create(True);

  FSFDHandleList := TgdKeyIntAssoc.Create;

  glbFunctionList := Self;

  FSFStreamState := sfsUnassigned;

  {$IFDEF DEBUG}
  FSFLoadTime := TStringList.Create;
  {$ENDIF}
end;

function TgsFunctionList.CreateSFDHandleList: Boolean;
var
  Len, Value, I: Integer;
  DirStr: String;
  Ch: array[0..1024] of Char;
  SFStreamDesc: TSFStreamDesc;

  function CheckSysInfo(const SFStreamDesc: TSFStreamDesc): Boolean;
  begin
    Result := True;
    with SFStreamDesc do
    begin
      if DBIB <> FSFStreamDesc.DBIB then
        Result := False
      else
      if DBPath <> FSFStreamDesc.DBPath then
        Result := False
      else
      if ServerName <> FSFStreamDesc.ServerName then
        Result := False
      else
      if SFModifyID <> FSFStreamDesc.SFModifyID then
        Result := False
      else
      if UseDebugInfo <> FSFStreamDesc.UseDebugInfo then
        Result := False
      else
      if StreamVertion <> FSFStreamDesc.StreamVertion then
        Result := False;
    end;
  end;

  function CreateSFStream: Boolean;
  var
    CLen: Longint;
    CIBSQL: TIBSQL;
    CFileHandle: Integer;
  begin
    Result := False;
    try
      FreeAndNil(FSFStream);
      FreeAndNil(FSFHandleStream);

      if FindCmdLineSwitch('NC', ['/', '-'], True) then
      begin
        SysUtils.DeleteFile(FSFDHandleName);
        SysUtils.DeleteFile(FSFDFileName);

        FSFStreamState := sfsBlocked;
        Exit;
      end;

      CIBSQL := TIBSQL.Create(nil);
      try
        CIBSQL.Transaction := TIBTransaction.Create(CIBSQL);
        CIBSQL.Transaction.DefaultDatabase := IBLogin.Database;
        CIBSQL.Transaction.StartTransaction;
        CIBSQL.SQL.Text := 'SELECT GEN_ID(gd_g_functionch, 0) FROM rdb$database';

        { TODO :
в будущем, когда все базы сапгрейдим
убрать этот код }
        try
          CIBSQL.ExecQuery;
        except
          on E: EIBError do
          begin
            if E.IBErrorCode <> 335544343 then
              raise
            else begin
              CIBSQL.SQL.Text := 'CREATE GENERATOR gd_g_functionch ';
              CIBSQL.ExecQuery;
              CIBSQL.SQL.Text := 'SELECT GEN_ID(gd_g_functionch, 0) FROM rdb$database';
              CIBSQL.ExecQuery;
            end;
          end;
        end;

        // Создаем системную информацию
        with FSFStreamDesc do
        begin
          DBIB := IBLogin.DBID;
          DBPath := Trim(AnsiUpperCase(IBLogin.DatabaseName));
          ServerName := Trim(AnsiUpperCase(IBLogin.ServerName));
          if not CIBSQL.Eof then
            SFModifyID := CIBSQL.Fields[0].AsInteger
          else
            raise Exception.Create(
              'Неудалось получить информацию о версии изменения скрипт-функций.');
          // !!!
          UseDebugInfo := PropertySettings.DebugSet.UseDebugInfo;
          StreamVertion := rp_SFStreamVertion;
        end;

        CIBSQL.Close;
        CIBSQL.Transaction.Commit;
      finally
        CIBSQL.Free;
      end;

      // Если файлы не существуют(или один из них), то пересоздаем файлы
      if (not FileExists(FSFDFileName)) or (not FileExists(FSFDHandleName)) then
      begin
        CLen := SizeOf(FSFStreamDesc);
        CFileHandle := CreateFile(PChar(FSFDHandleName),
          GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_ALWAYS,
          FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_COMPRESSED, 0);
        if CFileHandle > 0 then
          FileClose(CFileHandle)
        else
          raise Exception.Create('Не удалось создать файлы-хранилища скрипт-функций.');

        FSFHandleStream := TFileStream.Create(FSFDHandleName, fmOpenReadWrite);
        try
          FSFHandleStream.Write(CLen, SizeOf(Integer));
          FSFHandleStream.Write(FSFStreamDesc, CLen);
        finally
          FreeAndNil(FSFHandleStream);
        end;

        CFileHandle := CreateFile(PChar(FSFDFileName),
          GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_ALWAYS,
          FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_COMPRESSED, 0);
        if CFileHandle  > 0 then
          FileClose(CFileHandle)
        else
          raise Exception.Create('Не удалось создать файлы-хранилища скрипт-функций.');

        FSFStream := TFileStream.Create(FSFDFileName, fmOpenReadWrite);
        try
          FSFStream.Write(CLen, SizeOf(Integer));
          FSFStream.Write(FSFStreamDesc, CLen);
        finally
          FreeAndNil(FSFStream);
        end;
      end;

      FSFStream := TFileStream.Create(FSFDFileName, fmOpenReadWrite or fmShareDenyWrite);
      FSFHandleStream := TFileStream.Create(FSFDHandleName, fmOpenReadWrite or fmShareDenyWrite);

      Result := True;
    except
      on E: Exception do
      begin
        FreeAndNil(FSFStream);
        FreeAndNil(FSFHandleStream);

        if E is EFOpenError then
          FSFStreamState := sfsBlocked
        else
          FSFStreamState := sfsFailed;
      end;
    end;
  end;

  procedure RecreateSFDFiles;
  var
    RLen: Integer;
  begin
    if (not DeleteSFFiles) or (not CreateSFStream) then
    begin
      raise Exception.Create('Неудалось пересоздать файлы файл-кэша скрипт-функций.');
    end;

    FSFHandleStream.ReadBuffer(RLen, SizeOf(Integer));
    FSFHandleStream.ReadBuffer(SFStreamDesc, RLen);
    FSFStream.ReadBuffer(RLen, SizeOf(Integer));
    FSFStream.ReadBuffer(SFStreamDesc, RLen);
  end;

begin
  Result := False;

  case FSFStreamState of
    sfsCreated:
    begin
      Result := True;
      Exit;
    end;
    sfsFailed, sfsBlocked:
      Exit;
  end;
  FSFDHandleList.Clear;

  if IBLogin = nil then
    exit;

  if GetTempPath(1024, Ch) = 0 then
     DirStr := ''
  else
     DirStr := StrPas(Ch);

  if not DirectoryExists(DirStr) then
    if not CreateDir(DirStr) then
    begin
      MessageBox(0,
        'Не удается найти папку временных файлов для размещения кэша макросов.'#13#10 +
        'Производительность программы может снизиться.'#13#10 +
        'Обратитесь к системному администратору.',
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);

      FSFStreamState := sfsBlocked;
      Exit;
    end;

  FSFDFileName := Format(rp_SFFileName, [DirStr, IBLogin.DBID, 'sfd']);
  FSFDHandleName := Format(rp_SFFileName, [DirStr, IBLogin.DBID, 'sfh']);

  if not CreateSFStream then
    exit;

  // Проверяем соответсвие системной инф. файлов и подключения
  FSFHandleStream.ReadBuffer(Len, SizeOf(Integer));
  FSFHandleStream.ReadBuffer(SFStreamDesc, Len);
  if CheckSysInfo(SFStreamDesc) then
  begin
    FSFStream.ReadBuffer(Len, SizeOf(Integer));
    FSFStream.ReadBuffer(SFStreamDesc, Len);
    if not CheckSysInfo(SFStreamDesc) then
      RecreateSFDFiles;
  end else
    RecreateSFDFiles;

  if FSFHandleStream.Size > 0 then
    try
      Len := SizeOf(Integer);
      while FSFHandleStream.Position < FSFHandleStream.Size do
      begin
        FSFHandleStream.ReadBuffer(Value, Len);
        if  Value <> bSFHandleStream then
          raise Exception.Create(GetGsException(Self, 'Wrong stream data'));

        FSFHandleStream.ReadBuffer(Value, Len);
        I := FSFDHandleList.Add(Value);

        FSFHandleStream.ReadBuffer(Value, Len);
        FSFDHandleList.ValuesByIndex[I] := Value;

        FSFHandleStream.ReadBuffer(Value, Len);
        if  Value <> eSFHandleStream then
          raise Exception.Create(GetGsException(Self, 'Wrong stream data'));
      end;

      FSFStreamState := sfsCreated;
      Result := True;
    except
      FSFStreamState := sfsFailed;
      FSFDHandleList.Clear;
    end
  else
    begin
      FSFStreamState := sfsCreated;
      Result := True;
    end;
end;

function TgsFunctionList.DeleteSFFiles: Boolean;
begin
  Result := False;
  if FSFStream <> nil then
    FreeAndNil(FSFStream);

  if FSFHandleStream <> nil then
    FreeAndNil(FSFHandleStream);

  try
    if Length(FSFDFileName) > 0 then
      DeleteFile(PChar(FSFDFileName));
    if Length(FSFDHandleName) > 0 then
      DeleteFile(PChar(FSFDHandleName));
    Result := True;
  except
    FSFStreamState := sfsFailed;
  end;
  FSFStreamState := sfsUnassigned;
  FSFDHandleList.Clear;
end;

destructor TgsFunctionList.Destroy;
begin
  if FSFStreamState = sfsFailed then
    DeleteSFFiles;

  {$IFDEF DEBUG}
  FSFLoadTime.SaveToFile('LoadTime.$$$');
  FSFLoadTime.Free;
  {$ENDIF}

  FreeAndNil(FSortFuncList);

  if glbFunctionList.Get_Self = Self then
    glbFunctionList := nil;

  FSFStream.Free;
  FSFHandleStream.Free;
  FSFDHandleList.Free;
  inherited Destroy;
end;

procedure TgsFunctionList.Drop;
begin
  Clear;
  FSFStreamState := sfsUnassigned;
  FSFDFileName := '';
  FSFDHandleName := '';
  FreeAndNil(FSFStream);
  FreeAndNil(FSFHandleStream);
end;

function TgsFunctionList.FindFunction(
  const AnFunctionKey: Integer): TrpCustomFunction;
begin
  if AnFunctionKey = 0 then
  begin
    Result := nil;
    Exit;
  end;

  Result := FindFunctionWithoutDB(AnFunctionKey);

  if not Assigned(Result) then
    Result := FindFunctionInDB(AnFunctionKey);

//  else
  if Assigned(Result) then
    Inc(TrpCustomFunctionEx(Result).FExternalUsedCounter);
end;

function TgsFunctionList.FindFunctionInDB(
  const AnFunctionKey: Integer): TrpCustomFunction;
var
  ibsqlFunc: TIBQuery;
begin
  Result := nil;

  // Если нет подключения к БД, то не ищем
  if not gdcBaseManager.Database.Connected then
    Exit;

  try
    ibsqlFunc := TIBQuery.Create(nil);
    try
      ibsqlFunc.Transaction := gdcBaseManager.ReadTransaction;
      ibsqlFunc.SQL.Text := 'SELECT ID, MODULECODE, NAME, COMMENT, SCRIPT, ' +
        ' MODULE, LANGUAGE, EDITIONDATE, ENTEREDPARAMS FROM gd_function WHERE id = :id';
      ibsqlFunc.Params[0].AsInteger := AnFunctionKey;
      ibsqlFunc.Open;
      if not ibsqlFunc.Eof then
      begin
        Result := AddFromDataSet(ibsqlFunc);
      end;
    finally
      ibsqlFunc.Free;
    end;
  except
    if gdcBaseManager.Database.TestConnected then
      raise;
  end;
end;

function TgsFunctionList.FindFunctionWithoutDB(
  const AnFunctionKey: Integer): TrpCustomFunction;
var
  Index: Integer;
begin
  Index := FSortFuncList.IndexOf(AnFunctionKey);
  if Index > - 1 then
    Result := TrpCustomFunction(Items[Index])
  else
    Result := ReadSFFromStream(AnFunctionKey);
end;

function TgsFunctionList.Get_Function(Index: Integer): TrpCustomFunction;
begin
  Result := TrpCustomFunction(FSortFuncList.ObjectByIndex[Index]);
end;

function TgsFunctionList.Get_Self: TObject;
begin
  Result := Self;
end;

{function TgsFunctionList.IndexOf(F: TrpCustomFunction): Integer;
var
  I: Integer;
begin
  Result := - 1;
  I := FSortFuncList.IndexOf(F.FunctionKey);
  if FSortFuncList.ObjectByIndex[I] = F then
    result := I;
end;}

procedure TgsFunctionList.OnBreakPointsPrepared(Sender: TObject);
var
  CustomFunction: TrpCustomFunction;
  I: Integer;

  procedure SaveSFHandle(
    const AnFunction: TrpCustomFunction; const Position: Integer);
  var
    tmpInt: Integer;
  begin
    FSFHandleStream.Position := FSFHandleStream.Size;
    tmpInt := bSFHandleStream;
    FSFHandleStream.Write(tmpInt, SizeOf(tmpInt));
    tmpInt := AnFunction.FunctionKey;
    FSFHandleStream.Write(tmpInt, SizeOf(tmpInt));
    tmpInt := Position;
    FSFHandleStream.Write(Position, SizeOf(tmpInt));
    tmpInt := eSFHandleStream;
    FSFHandleStream.Write(tmpInt, SizeOf(tmpInt));
  end;
begin
  if CreateSFDHandleList and (Sender is TrpCustomFunction) then
  begin
    CustomFunction := TrpCustomFunction(Sender);
//    if ((FSFStream <> nil) and (FSFHandleStream <> nil)) or
//      (CreateSFDHandleList{CreateSFStream}) then
    try
      if FSFDHandleList.IndexOf(CustomFunction.FunctionKey) > -1 then
      begin
        FSFStreamState := sfsFailed;
        Exit;
//        raise Exception.Create('Badly!!!');
      end;

      FSFStream.Position := FSFStream.Size;
      I := FSFDHandleList.Add(CustomFunction.FunctionKey);
      SaveSFHandle(CustomFunction, FSFStream.Position);
      FSFDHandleList.ValuesByIndex[I] := FSFStream.Position;
      CustomFunction.SaveToStream(FSFStream);
    except
      FSFStreamState := sfsFailed;
    end;
  end;
end;

(*procedure TgsFunctionList.ReadFromSFSFile;
var
  CustomFunction: TrpCustomFunction;
  strTest: String;
  Len, Value: Integer;
  Str: String;
  LDate: TDateTime;
  LBool: Boolean;
begin
{  FSortFuncList.Clear;

  if FSFStream.Size > 0 then
  try
    FSFStream.Position := 0;
    while FSFStream.Position < FSFStream.Size do
    begin
      CustomFunction := TrpCustomFunction.Create;
      CustomFunction.LoadFromStream(FSFStream);
      FSortFuncList.AddObject(CustomFunction.FunctionKey, CustomFunction);
    end;
  except
    FSortFuncList.Clear;
  end}
end;*)

function TgsFunctionList.ReadSFFromStream(
  const AnFunctionKey: Integer): TrpCustomFunction;
var
  I: Integer;
  {$IFDEF DEBUG}
  Tick: DWORD;
  {$ENDIF}
begin
  {$IFDEF DEBUG}
  Tick := GetTickCount;
  {$ENDIF}

  Result := nil;

  if (FSFStreamState in [sfsFailed, sfsBlocked]) or (not CreateSFDHandleList) then
    Exit;

  I := FSFDHandleList.IndexOf(AnFunctionKey);
  if (I = -1) or (FSFHandleStream = nil)  then
    Exit;

  Result := TrpCustomFunction.Create;
  try
    FSFStream.Position := FSFDHandleList.ValuesByIndex[I];
    Result.LoadFromStream(FSFStream);
  except
    FSFStreamState := sfsFailed;
    FreeAndNil(Result);
  end;
  AddFunction(Result);
  {$IFDEF DEBUG}
  FSFLoadTime.Add(IntToStr(GetTickCount - Tick));
  {$ENDIF}
end;

function TgsFunctionList.ReleaseFunction(
  AnFunction: TrpCustomFunction): Integer;
begin
  Result := -1;
  if Assigned(AnFunction) then
    Dec(TrpCustomFunctionEx(AnFunction).FExternalUsedCounter)
  else
    exit;
  Result := TrpCustomFunctionEx(AnFunction).FExternalUsedCounter;
end;

procedure TgsFunctionList.RemoveFunction(const AnFunctionKey: Integer);
var
  Index: Integer;
begin
  //вместо того, что бы использовать ф-цию UpdateList, которая удалит
  //файл кэша, а потом перечитает все ф-ции из gd_function, просто удаляем
  //файл и чистим список. кэш заполнится автоматически при обращении к используемым
  //ф-циям.

  DeleteSFFiles;
  Index := FSortFuncList.IndexOf(AnFunctionKey);
  if Index > - 1 then
    FSortFuncList.Delete(Index);
end;

function TgsFunctionList.UpdateList: Boolean;
var
  ibqueryFunc: TIBQuery;
  LFunction: TrpCustomFunction;
begin
  Result := False;

  if not gdcBaseManager.Database.Connected then
    Exit;

  DeleteSFFiles;
  try
    ibqueryFunc := TIBQuery.Create(nil);
    try
      ibqueryFunc.Transaction := gdcBaseManager.ReadTransaction;
      ibqueryFunc.SQL.Text := 'SELECT ID, MODULECODE, NAME, COMMENT, SCRIPT, ' +
        ' MODULE, LANGUAGE, EDITIONDATE, ENTEREDPARAMS FROM gd_function';
      ibqueryFunc.Open;
      while not ibqueryFunc.Eof do
      begin
        LFunction := FindFunctionWithoutDB(ibqueryFunc.FieldByName('ID').AsInteger);
        if Assigned(LFunction) then
          LFunction.ReadFromDataSet(ibqueryFunc);
        ibqueryFunc.Next;
      end;
    finally
      ibqueryFunc.Free;
    end;
  except
    raise;
  end;
  Result := True;
end;

{ TEventObject }

procedure TEventObject.Assign(Source: TEventObject);
begin
  FObjectKey := Source.ObjectKey;
  FObjectName := Source.ObjectName;
  FChildObjects.Assign(Source.ChildObjects);
  FObjectClassType := Source.ObjectClassType;
  FEventList.Assign(Source.EventList);
end;

constructor TEventObject.Create;
begin
  inherited;

  FChildObjects := TEventObjectList.Create;
  FEventList := TEventList.Create;
  FObjectKey := 0;
//  FHasSpecEvent := False;
end;

destructor TEventObject.Destroy;
begin
  FreeAndNil(FEventList);
  FreeAndNil(FChildObjects);

  inherited;
end;

procedure TEventObject.LoadFromStream(AnStream: TStream);
var
  strTest: array[0..SizeOf(strStartObject) - 1] of Char;
  Len: Integer;
begin
  AnStream.ReadBuffer(strTest, SizeOf(strStartObject));
  if strTest <> strStartObject then
    raise Exception.Create(GetGsException(Self, 'Wrong stream data'));

  AnStream.ReadBuffer(Len, SizeOf(Len));
  SetLength(FObjectName, Len);
  AnStream.ReadBuffer(FObjectName[1], Len);

  FChildObjects.LoadFromStream(AnStream);
//  LoadSLfromStreamEx(FEventList, AnStream);

  AnStream.ReadBuffer(strTest, SizeOf(strStartObject));
  if strTest <> strEndObject then
    raise Exception.Create(GetGsException(Self, 'Wrong stream data'));
end;

procedure TEventObject.SaveToStream(AnStream: TStream);
var
  Len: Integer;
begin
  AnStream.WriteBuffer(strStartObject, SizeOf(strStartObject));

  Len := Length(FObjectName);
  AnStream.WriteBuffer(Len, SizeOf(Len));
  AnStream.WriteBuffer(FObjectName[1], Len);

  FChildObjects.SaveToStream(AnStream);
//  SaveSLtoStreamEx(FEventList, AnStream);
  AnStream.WriteBuffer(strEndObject, SizeOf(strEndObject));
end;

{procedure TEventObject.SetHasSpecEvent(const Value: Boolean);
begin
  FHasSpecEvent := Value;
end;}

procedure TEventObject.SetObjectRef(const Value: TComponent);
begin
  FObjectRef := Value;
end;

procedure TEventObject.SetSpecEventCount(const Value: Integer);
begin
  FSpecEventCount := Value;
end;

{ TEventObjectList }

function TEventObjectList.AddObject(const AnObject: TEventObject): Integer;
begin
  Result := Add(TEventObject.Create);
  TEventObject(Last).ParentList := Self;
  if Assigned(AnObject) then
    TEventObject(Last).Assign(AnObject);
end;

procedure TEventObjectList.Assign(Source: TEventObjectList);
var
  I: Integer;
begin
  Clear;
  for I := 0 to Source.Count - 1 do
    AddObject(TEventObject(Source.Items[I]));
end;

function TEventObjectList.FindAllObject(
  const AnName: String): TEventObject;
var
  I: Integer;
begin
  Result := FindObject(AnName);
  if not Assigned(Result) then
    for I := 0 to Count - 1 do
    begin
      Result := EventObject[I].ChildObjects.FindAllObject(AnName);
      if Assigned(Result) then
        Break;
    end;
end;

function TEventObjectList.FindObjectAndIndex(AObject: TComponent;
  out DynArrayIndex: Integer): TEventObject;
var
  LCurObject: TComponent;
  LTreeParent: TStrings;
  I: Integer;
  LEventList: TEventObjectList;
  LEventObject: TEventObject;
  LCurObjectName: String;

  procedure SetCurObjectName;
  begin
    if Assigned(LCurObject) then
//      if LCurObject is TCreateableForm then
//        LCurObjectName := TCreateableForm(LCurObject).InitialName
//      else
      LCurObjectName := LCurObject.Name
    else
      LCurObjectName := '';
  end;
begin
  Result := nil;

  if Assigned(AObject) and (AObject is TCreateableForm) then
  begin
    i := FDinamicEventArray.IndexOf(Integer(AObject));
    if i > -1 then
      Result := TEventObject(FDinamicEventArray.ObjectByIndex[i])
    else
      if Assigned(EventControl) then
      begin
        EventControl.AssignEvents(
          TCreateableForm(AObject).InitialName, AObject);
        i := FDinamicEventArray.IndexOf(Integer(AObject));
        if i > -1 then
          Result := TEventObject(FDinamicEventArray.ObjectByIndex[i]);
      end;
  end;


  {
  if Assigned(AObject) and (AObject is TCreateableForm) and
    (AnsiCompareText(TCreateableForm(AObject).InitialName,
    TCreateableForm(AObject).Name) <> 0) then
  begin
    i := FDinamicEventArray.IndexOf(Integer(AObject));
    if i > -1 then
      Result := TEventObject(FDinamicEventArray.ObjectByIndex[i])
    else
      if Assigned(EventControl) then
      begin
        EventControl.AssignEvents(
          Application.FindComponent(TCreateableForm(AObject).InitialName), AObject);
        i := FDinamicEventArray.IndexOf(Integer(AObject));
        if i > -1 then
          Result := TEventObject(FDinamicEventArray.ObjectByIndex[i]);
      end;
  end;

  }
  if Assigned(Result) then
    Exit;

  LEventList := Self;
  LEventObject := nil;
  LTreeParent := TStringList.Create;
  try
    LCurObject := AObject;
    SetCurObjectName;
    while (LCurObject <> nil) and (LCurObject <> Application) do
    begin
      if LCurObject.InheritsFrom(TCustomForm) then
      begin
        i := FDinamicEventArray.IndexOf(Integer(LCurObject));
        if i > -1 then
          LEventObject := TEventObject(FDinamicEventArray.ObjectByIndex[i]);
        if not Assigned(LEventObject) then
          Exit
        else
          begin
            LEventList := LEventObject.ChildObjects;
            Break;
          end;
      end;
      LTreeParent.AddObject(LCurObjectName, LCurObject);

//      if LCurObject.InheritsFrom(TCustomForm) and
//        Assigned(LEventList.FindObject(LCurObjectName)) then
//        Break;
      LCurObject := LCurObject.Owner;
      SetCurObjectName;
    end;

    for I := LTreeParent.Count - 1 downto 0 do
    begin
      LEventObject := LEventList.FindObject(LTreeParent.Objects[I]);
//      LEventObject := LEventList.FindObject(LTreeParent.Strings[I]);
      if Assigned(LEventObject) then
        LEventList := LEventObject.ChildObjects
      else
        Break;
    end;
    Result := LEventObject;
    // если объект не найден, ищем его среди динамических объектов
    if Result = nil then
    begin
      i := FDinamicEventArray.IndexOf(Integer(AObject));
      if i > -1 then
        Result := TEventObject(FDinamicEventArray.ObjectByIndex[i]);
    end;
  finally
    LTreeParent.Free;
  end;
end;

function TEventObjectList.FindObject(const AnName: String): TEventObject;
var
  I: Integer;
  TempStr: String;
begin
  Result := nil;
  TempStr := UpperCase(AnName);
  for I := 0 to Count - 1 do
    if UpperCase(EventObject[I].ObjectName) = TempStr then
    begin
      Result := EventObject[I];
      Break;
    end;
  if Result = nil then
  for I := 0 to FDinamicEventArray.Count - 1 do
    if UpperCase(TEventObject(FDinamicEventArray.ObjectByIndex[I]).ObjectName) = TempStr then
    begin
      Result := TEventObject(FDinamicEventArray.ObjectByIndex[I]);
      Break;
    end;
end;

function TEventObjectList.GetEventObject(Index: Integer): TEventObject;
begin
  Assert((Index >= 0) and (Index < Count));
  Result := TEventObject(Items[Index]);
end;

function TEventObjectList.Last: TEventObject;
begin
  Result := TEventObject(inherited Last);
end;

procedure TEventObjectList.LoadFromDatabaseOpt(AnDatabase: TIBDatabase;
  AnTransaction: TIBTransaction; const AnParent: Variant);
type
  TTempRec = record
    ObjectKey: Integer;
    EventObject: TEventObject;
  end;

var
  ibsqlObj: TIBSQL;
  ibsqlEvent: TIBSQL;
  FlagTr: Boolean;
  // 1000 уровней вложенности
  TreeArray: array[0..1000] of TTempRec;
  CurrentIndex, I: Integer;
begin
  Clear;
  CurrentIndex := -1;
  FlagTr := AnTransaction.InTransaction;
  if not FlagTr then
    AnTransaction.StartTransaction;
  try
    ibsqlObj := TIBSQL.Create(nil);
    try
      ibsqlEvent := TIBSQL.Create(nil);
      try
        ibsqlObj.Database := AnDatabase;
        ibsqlObj.Transaction := AnTransaction;
        ibsqlObj.SQL.Text := 'SELECT PARENT, ID, OBJECTNAME FROM evt_object WHERE objectname > '''' ' +
         'ORDER BY lb';
        ibsqlObj.ExecQuery;

        ibsqlEvent.Database := AnDatabase;
        ibsqlEvent.Transaction := AnTransaction;
        ibsqlEvent.SQL.Text := 'SELECT oe.objectkey, oe.eventname, oe.id, oe.functionkey, oe.disable ' +
         ' FROM evt_objectevent oe JOIN ' +
         ' evt_object ob ON oe.objectkey = ob.id WHERE ob.objectname > '''' ORDER BY ob.lb, oe.eventname';
        ibsqlEvent.ExecQuery;

        while not ibsqlObj.Eof do
        begin
          if ibsqlObj.FieldByName('parent').IsNull then
            CurrentIndex := -1
          else
            for I := CurrentIndex downto 0 do
              if ibsqlObj.FieldByName('parent').AsInteger = TreeArray[I].ObjectKey then
              begin
                CurrentIndex := I;
                Break;
              end;

          if CurrentIndex = - 1 then
          begin
            AddObject(nil);
            TreeArray[CurrentIndex + 1].EventObject := Last;
          end else
          begin
            TreeArray[CurrentIndex].EventObject.ChildObjects.AddObject(nil);
            TreeArray[CurrentIndex + 1].EventObject := TreeArray[CurrentIndex].EventObject.ChildObjects.Last;
          end;
          Inc(CurrentIndex);
          TreeArray[CurrentIndex].EventObject.ObjectName := ibsqlObj.FieldByName('objectname').AsString;
          TreeArray[CurrentIndex].EventObject.ObjectKey := ibsqlObj.FieldByName('id').AsInteger;
          TreeArray[CurrentIndex].ObjectKey := TreeArray[CurrentIndex].EventObject.ObjectKey;


          while not ibsqlEvent.Eof and
           (ibsqlEvent.FieldByName('objectkey').AsInteger = TreeArray[CurrentIndex].ObjectKey) do
          begin
            with TreeArray[CurrentIndex].EventObject.EventList do
            begin
              Add(ibsqlEvent.FieldByName('eventname').AsString,
               ibsqlEvent.FieldByName('functionkey').AsInteger);
              Last.EventObject := TreeArray[CurrentIndex].EventObject;
              Last.EventId := ibsqlEvent.FieldByName('id').AsInteger;
              Last.Name := ibsqlEvent.FieldByName('eventname').AsString;

              if ibsqlEvent.FieldByName('Disable').IsNull then
                Last.Disable := False
              else
                Last.Disable := ibsqlEvent.FieldByName('Disable').AsInteger <> 0;
            end;
            ibsqlEvent.Next;
          end;
          ibsqlObj.Next;
        end;
      finally
        ibsqlEvent.Free;
      end;
    finally
      ibsqlObj.Free;
    end;
  finally
    if not FlagTr then
      AnTransaction.Commit;
  end;
end;

(*procedure TEventObjectList.LoadFromDatabase(AnDatabase: TIBDatabase;
  AnTransaction: TIBTransaction; const AnParent: Variant);
var
  ibsqlObj: TIBSQL;
  ibsqlEvent: TIBSQL;
  FlagTr: Boolean;
begin
  Clear;
  FlagTr := AnTransaction.InTransaction;
  if not FlagTr then
    AnTransaction.StartTransaction;
  try
    ibsqlObj := TIBSQL.Create(nil);
    try
      ibsqlEvent := TIBSQL.Create(nil);
      try
        ibsqlObj.Database := AnDatabase;
        ibsqlObj.Transaction := AnTransaction;
        {Сволочь такая не работает с NULL параметром} {gs}
        if AnParent = NULL then
          ibsqlObj.SQL.Text := 'SELECT * FROM evt_object WHERE objectname > '''' ' +
           'AND parent IS NULL ORDER BY objectname'
        else
        begin
          ibsqlObj.SQL.Text := 'SELECT * FROM evt_object WHERE objectname > '''' ' +
           'AND parent = :pr ORDER BY objectname';
          ibsqlObj.Params[0].AsVariant := AnParent;
        end;
        ibsqlObj.ExecQuery;

        ibsqlEvent.Database := AnDatabase;
        ibsqlEvent.Transaction := AnTransaction;
        ibsqlEvent.SQL.Text := 'SELECT * FROM evt_objectevent WHERE objectkey = :id ' +
         'ORDER BY eventname';
        ibsqlEvent.Prepare;

        while not ibsqlObj.Eof do
        begin
          AddObject(nil);
          Last.ObjectName := ibsqlObj.FieldByName('objectname').AsString;
          Last.ObjectKey := ibsqlObj.FieldByName('id').AsInteger;
          ibsqlEvent.Close;
          ibsqlEvent.Params[0].AsInteger := Last.ObjectKey;
          ibsqlEvent.ExecQuery;
          while not ibsqlEvent.Eof do
          begin
            Last.EventList.Add(ibsqlEvent.FieldByName('eventname').AsString,
             ibsqlEvent.FieldByName('functionkey').AsInteger);
            Last.EventList.Last.EventObject := Last;
            Last.EventList.Last.EventID := ibsqlEvent.FieldByName('id').AsInteger;

            ibsqlEvent.Next;
          end;
          Last.ChildObjects.LoadFromDatabase(AnDatabase, AnTransaction,
           Last.ObjectKey);

          ibsqlObj.Next;
        end;
      finally
        ibsqlEvent.Free;
      end;
    finally
      ibsqlObj.Free;
    end;
  finally
    if not FlagTr then
      AnTransaction.Commit;
  end;
end;*)

procedure TEventObjectList.LoadFromStream(AnStream: TStream);
var
  I, J: Integer;
  strTemp: array[0..SizeOf(strStartObjList)] of Char;
begin
  Clear;
  AnStream.ReadBuffer(strTemp, SizeOf(strStartObjList));
  if strTemp <> strStartObjList then
    raise Exception.Create(GetGsException(Self, 'Wrong stream data format'));

  AnStream.ReadBuffer(J, SizeOf(J));
  for I := 0 to J - 1 do
    EventObject[AddObject(TEventObject.Create)].LoadFromStream(AnStream);

  AnStream.ReadBuffer(strTemp, SizeOf(strStartObjList));
  if strTemp <> strEndObjList then
    raise Exception.Create(GetGsException(Self, 'Wrong stream data format'));
end;

procedure TEventObjectList.SaveToStream(AnStream: TStream);
var
  I: Integer;
begin
  AnStream.WriteBuffer(strStartObjList, SizeOf(strStartObjList));
  AnStream.WriteBuffer(Count, SizeOf(Count));
  for I := 0 to Count - 1 do
    EventObject[I].SaveToStream(AnStream);
  AnStream.WriteBuffer(strEndObjList, SizeOf(strEndObjList));
end;

function TEventObjectList.FindObject(
  const AnObjectKey: Integer): TEventObject;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if EventObject[I].ObjectKey = AnObjectKey then
    begin
      Result := EventObject[I];
      Break;
    end;
end;

function TEventObjectList.FindAllObject(
  const AnObjectKey: Integer): TEventObject;
var
  I: Integer;
begin
  Result := FindObject(AnObjectKey);
  if not Assigned(Result) then
    for I := 0 to Count - 1 do
    begin
      Result := EventObject[I].ChildObjects.FindAllObject(AnObjectKey);
      if Assigned(Result) then
        Break;
    end;
end;

function TEventObjectList.AddDinamicEventObject(const Source,
  Acceptor: TComponent): Boolean;
var
  LEventObject{, NewEventObject}: TEventObject;
//  i: Integer;
begin
  Result := False;
//  if (not (Assigned(Source) or Assigned(Acceptor))) or
//    (FDinamicEventArray.IndexOf(Integer(Acceptor)) > -1) then
//    Exit;
  if not Assigned(Source)  then
    Exit;

  LEventObject := FindAllObject(Source as TComponent);
  if LEventObject = nil then
    Exit;

  Result := AddDinamicObject(LEventObject, Acceptor);


{  NewEventObject := TEventObject.Create;
  NewEventObject.Assign(LEventObject);
  NewEventObject.ParentList := Self;
  NewEventObject.FSelfObject := Acceptor;
//  NewEventObject.FChildObjects.Clear;
  NewEventObject.FObjectKey := 0;
  NewEventObject.FObjectName := Acceptor.Name;
  i := FDinamicEventArray.Add(Integer(NewEventObject.FSelfObject));
  FDinamicEventArray.ObjectByIndex[i] := NewEventObject;

  Result := True;
}
end;

constructor TEventObjectList.Create;
begin
  inherited Create;

  FDinamicEventArray := TgdKeyObjectAssoc.Create;
//  FDinamicEventArray.OwnsObjects := True;
end;

destructor TEventObjectList.Destroy;
begin
  FDinamicEventArray.OwnsObjects := True;
  FreeAndNil(FDinamicEventArray);

  inherited;
end;

procedure TEventObjectList.RemoveDinamicObject(const AnObject: TObject);
var
  i: Integer;
  O: TObject;
begin
  if not Assigned(AnObject) then
    Exit;

  i := FDinamicEventArray.IndexOf(Integer(AnObject));
  if i > -1 then
  begin
    O := FDinamicEventArray.ObjectByIndex[i];
    FDinamicEventArray.Delete(i);
    O.Free;
  end;
end;

function TEventObjectList.AddDinamicEventObject(const SourceName: String;
  Acceptor: TComponent): Boolean;
var
  LEventObject: TEventObject;
begin
  Result := False;
  if Length(SourceName) = 0  then
    Exit;

  LEventObject := FindAllObject(SourceName);
  if LEventObject = nil then
    Exit;

  Result := AddDinamicObject(LEventObject, Acceptor);

{var
  LEventObject, NewEventObject: TEventObject;
  i: Integer;
begin
  Result := False;
  if (not Assigned(Acceptor)) or
    (FDinamicEventArray.IndexOf(Integer(Acceptor)) > -1) then
    Exit;

  LEventObject := FindAllObject(SourceName);
  if LEventObject = nil then
    Exit;

  NewEventObject := TEventObject.Create;
  NewEventObject.Assign(LEventObject);
  NewEventObject.ParentList := Self;
  NewEventObject.FSelfObject := Acceptor;
//  NewEventObject.FChildObjects.Clear;
  NewEventObject.FObjectKey := 0;
  NewEventObject.FObjectName := Acceptor.Name;
  i := FDinamicEventArray.Add(Integer(NewEventObject.FSelfObject));
  FDinamicEventArray.ObjectByIndex[i] := NewEventObject;

  Result := True;
//    FEventObjectList.AddDinamicEventObject(NewEventObject);
 }


end;

function TEventObjectList.AddDinamicObject(
  const SourceEventObject: TEventObject; Acceptor: TComponent): Boolean;
var
  NewEventObject: TEventObject;
  i: Integer;
begin
  Result := False;
  if (not (Assigned(SourceEventObject) or Assigned(Acceptor))) or
    (FDinamicEventArray.IndexOf(Integer(Acceptor)) > -1) then
    Exit;

  NewEventObject := TEventObject.Create;
  NewEventObject.Assign(SourceEventObject);
  NewEventObject.ParentList := Self;
  NewEventObject.FSelfObject := Acceptor;
//  NewEventObject.FChildObjects.Clear;
  NewEventObject.FObjectKey := 0;
  NewEventObject.FObjectName := Acceptor.Name;
  i := FDinamicEventArray.Add(Integer(NewEventObject.FSelfObject));
  FDinamicEventArray.ObjectByIndex[i] := NewEventObject;

  Result := True;
end;

function TEventObjectList.FindObject(
  const AnObject: TObject): TEventObject;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if EventObject[I].ObjectRef = AnObject then
    begin
      Result := EventObject[I];
      Break;
    end;
end;

function TEventObjectList.FindAllObject(AObject: TComponent): TEventObject;
var
  I: Integer;
begin
  Result := FindObjectAndIndex(AObject, I);
end;

procedure TEventObjectList.Clear;
begin
  if FDinamicEventArray <> nil then
    FDinamicEventArray.Clear;
  inherited;
end;

{ TEventItem }

procedure TEventItem.Assign(ASource: TEventItem);
begin
//  FCustomName := ASource.Name;
  Name := ASource.Name;
  FEventData := ASource.EventData;
  FFunctionKey := ASource.FunctionKey;
  FOldEvent := ASource.OldEvent;
  FEventId := ASource.EventID;
  FDisable := ASource.FDisable;
end;

function TEventItem.AutoFunctionName: String;
begin
  Result := ObjectName + Name;
end;

function TEventItem.GetComplexParams(
  const AnLang: TFuncParamLang; const FunctionName: String = ''): String;
var
  LFN, LFR, LFB, LFE, LFP: String;
  LResultParam: String;
  I: Integer;
  InheritedDim, InheritedSender: String;
  InheritedParam, InheritedArray: String;
  CallInherited, ReturnParam: String;
  Comment, EndComment: String;
  LFunctionName: String;
  OptExplicit: string;

  function VarParamPresent(EventData: TTypeData): Boolean;
  var
    ParamRec: PParamRecord;
    vi: Integer;
    TypeStr: ^ShortString;
  begin
    Result := False;
    ParamRec := @EventData.ParamList;
    vi := 1;
    while vi <= EventData.ParamCount do
    begin
      if pfVar in ParamRec.Flags then
      begin
        Result := True;
        Exit;
      end;
      Inc(vi);
      TypeStr := Pointer(Integer(@ParamRec^.ParamName) +
        Length(ParamRec^.ParamName)+ 1);
      ParamRec := PParamRecord(Integer(ParamRec) + SizeOf(TParamFlag) +
        (Length(ParamRec^.ParamName) + 1) + (Length(TypeStr^) + 1));
    end;
  end;

  function GetEventTypeName(const Index: Integer;
      const ParamList: array of Char): String;
  var
    L: Integer;
    I: Integer;
  begin
    Result := '';
    L := 1;
    for I := 0 to Index - 1 do
    begin
      L := L + Byte(ParamList[L]) + 1;
      L := L + Byte(ParamList[L]) + 1;
      Inc(L);
    end;
    L := L + Byte(ParamList[L]) + 1;
    Result := Copy(PChar(@ParamList[L + 1]), 1, Byte(ParamList[L]));
  end;

  function GetParamInArrayStr(EventData: TTypeData;
    out LReturnParam: String): String;
  var
    ParamRec: PParamRecord;
    vi: Integer;
    TypeStr: ^ShortString;
    TypeName: String;
  begin
    Result := '';
    LReturnParam := '';
    ParamRec := @EventData.ParamList;
    vi := 1;
    while vi <= EventData.ParamCount do
    begin
      if pfVar in ParamRec.Flags then
      begin
        LReturnParam := LReturnParam + '  ' +
          ParamRec^.ParamName + '.Value = ParamArr(' + IntToStr(vi - 1) + ')'#13#10;
      end;
      TypeName := GetEventTypeName(vi - 1, EventData.ParamList);
      if (pfAddress in ParamRec.Flags) or
        (AnsiCompareText(TypeName, TgsPoint.GetOriginTypeName) = 0) or
        (AnsiCompareText(TypeName, TgsRect.GetOriginTypeName) = 0) then
      begin
        Result := Result + '  Set ';
      end;
      Result := Result + '  ParamArr(' + IntToStr(vi - 1) +
        ') = ' + ParamRec^.ParamName + #13#10;
      Inc(vi);
      TypeStr := Pointer(Integer(@ParamRec^.ParamName) +
        Length(ParamRec^.ParamName)+ 1);
      ParamRec := PParamRecord(Integer(ParamRec) + SizeOf(TParamFlag) +
        (Length(ParamRec^.ParamName) + 1) + (Length(TypeStr^) + 1));
    end;
  end;



  function GetEventParamName(const Index: Integer;
      const ParamList: array of Char): String;
  var
    L: Integer;
    I: Integer;
  begin
    Result := '';
    L := 1;
    for I := 0 to Index - 1 do
    begin
      L := L + Byte(ParamList[L]) + 1;
      L := L + Byte(ParamList[L]) + 1;
      Inc(L);
    end;
    Result := Copy(PChar(@ParamList[L + 1]), 1, Byte(ParamList[L]));
  end;

  function ParamIsObject(const Index: Integer;
      const ParamList: array of Char): Boolean;
  var
    L: Integer;
    I: Integer;
  begin
    Result := False;
    L := 0;
    for I := 0 to Index - 1 do
    begin
      L := L + Byte(ParamList[L + 1]) + 2;
      L := L + Byte(ParamList[L]) + 1;
    end;
    if (ParamList[L] = #8) or (ParamList[L] = #9) then
      Result := True;
  end;

const
  InheritedComment = '%s*** Данный код необходим для вызова встроенного обработчика ***'#13#10 +
                     '%s*** В случае его удаления возможно нарушение работы системы ***'#13#10;
  InheritedEndComment =
                     '%s*** конец кода поддержки встроенного обработчика            ***'#13#10;
begin
  ReturnParam := '';
  LFR := '';
  LFP := GetDelphiParamString(FEventData^.ParamCount, FEventData^.ParamList,
    AnLang, LResultParam);

  if FunctionName = '' then
    LFunctionName := AutoFunctionName
  else
    LFunctionName := FunctionName;

  case FEventData^.MethodKind of
    mkSafeFunction, mkFunction:
    begin
      LFN := 'function';
      case AnLang of
        fplDelphi: LFR := ': ' + LResultParam + ';';
        fplJScript, fplVBScript:
          LFR := '';
      else
        raise Exception.Create('Unknown language type.');
      end;
    end;
    mkSafeProcedure, mkProcedure:
      case AnLang of
        fplDelphi:
        begin
          LFN := 'procedure';
          LFR := ';'#13#10;
        end;
        fplJScript:
        begin
          LFN := 'function';
//          LFR := ';';
        end;
        fplVBScript:
        begin
          LFN := 'sub';
//            LMacroBody := LMacroBody + '  call ';
        end;
      else
        raise Exception.Create('Unknown language type.');
      end;
  else
    raise Exception.Create(GetGsException(Self, 'This kind of method isn''t supported.'));
  end;
  InheritedDim := '';
  InheritedSender := '';
  InheritedParam := '';
  CallInherited := '';
  Comment := '';
  EndComment := '';
  OptExplicit := '';

  case AnLang of
    fplDelphi:
    begin
      LFB := 'begin'#13#10;
      LFE := 'end;';
    end;
    fplJScript:
    begin
      LFB := '{'#13#10;
      LFE := '}';
    end;
    fplVBScript:
    begin
      LFB := '';
      LFE := 'end ' + LFN;
      OptExplicit := 'option explicit'#13#10;
    end;
  end;

  if not ((Pos(USERCOMPONENT_PREFIX, LowerCase(ObjectName)) = 1) or
    (Pos(GLOBALUSERCOMPONENT_PREFIX, LowerCase(ObjectName)) = 1) or
    (Pos(ATCOMPONENT_PREFIX, LowerCase(ObjectName)) = 1) or
    (Pos(MACROSCOMPONENT_PREFIX, LowerCase(ObjectName)) = 1)) then
  begin
    case AnLang of
      fplJScript:
      begin
        InheritedDim := '  InheritedDim = new Array(' + IntToStr(FEventData^.ParamCount - 1) + ');'#13#10;

        InheritedArray := 'Array(' +
          GetEventParamName(0, FEventData^.ParamList);
        for I := 0 to FEventData^.ParamCount - 1 do
        begin
          InheritedArray := InheritedArray + ', ' +
            GetEventParamName(i, FEventData^.ParamList);
  //        InheritedParam := InheritedParam + '  InheritedDim[' + IntToStr(I) + '] = ' +
  //          GetEventParamName(i, FEventData^.ParamList) + ';'#13#10;
        end;
        InheritedArray := InheritedArray + ')';

        CallInherited := '  Inherited(' + GetEventParamName(0, FEventData^.ParamList) +
          ', ' + '''' + Name + ''', ' + InheritedArray + ');'#13#10;
  //      CallInherited := '  Inherited(' + GetEventParamName(0, FEventData^.ParamList) +
  //        ', ' + '''' + Name + ''', InheritedDim);';
        Comment := Format(InheritedComment, ['//', '//', '//']);
        EndComment := Format(InheritedEndComment, ['//']);
      end;
      fplVBScript:
      begin
        if VarParamPresent(FEventData^) then
        begin
          CallInherited := '  Dim ParamArr(' +
            IntToStr(FEventData^.ParamCount - 1) + ')'#13#10;
          CallInherited := CallInherited +
            GetParamInArrayStr(FEventData^, ReturnParam);

          case FEventData^.MethodKind of
            mkSafeFunction, mkFunction: CallInherited := CallInherited + '  ' + LFunctionName + ' = ';
            mkSafeProcedure, mkProcedure:  CallInherited := CallInherited + '  call ';
          end;
          CallInherited := CallInherited + '  Inherited(' + GetEventParamName(0, FEventData^.ParamList) +
            ', ' + '"' + Name + '", ParamArr)'#13#10;
          CallInherited := CallInherited + ReturnParam;
        end else
          begin
            InheritedDim := '  dim InheritedDim(' + IntToStr(FEventData^.ParamCount - 1) + ')'#13#10;
            InheritedArray := 'Array(' +
              GetEventParamName(0, FEventData^.ParamList);
            for I := 1 to FEventData^.ParamCount - 1 do
            begin
              InheritedArray := InheritedArray + ', ' +
                GetEventParamName(i, FEventData^.ParamList);
      //        if ParamIsObject(i, FEventData^.ParamList) then
      //          InheritedParam := InheritedParam + '  set';
      //        InheritedParam := InheritedParam + '  InheritedDim(' + IntToStr(i) + ') = ' +
      //          GetEventParamName(i, FEventData^.ParamList)+ #13#10;
            end;
            InheritedArray := InheritedArray + ')';

            case FEventData^.MethodKind of
              mkSafeFunction, mkFunction: CallInherited := '  ' + LFunctionName + ' = ';
              mkSafeProcedure, mkProcedure:  CallInherited := '  call ';
            end;
            CallInherited := CallInherited + '  Inherited(' + GetEventParamName(0, FEventData^.ParamList) +
              ', ' + '"' + Name + '", ' + InheritedArray + ')'#13#10 + ReturnParam;
          end;

  //      CallInherited := CallInherited + '  Inherited(' + GetEventParamName(0, FEventData^.ParamList) +
  //        ', ' + '"' + Name + '", InheritedDim)' ;
        Comment := Format(InheritedComment, ['''', '''', '''']);
        EndComment := Format(InheritedEndComment, ['''']);
      end;
    else
      raise Exception.Create('Unknown language type.');
    end;
    Result := OptExplicit + LFN + ' ' + LFunctionName + '(' + LFP +
      ')'#13#10 + LFR + LFB + Comment + CallInherited + EndComment + LFE;
  end else
    Result := OptExplicit + LFN + ' ' + LFunctionName + '(' + LFP +
      ')'#13#10 + LFR + LFB + LFE;
end;

function TEventItem.GetDelphiParamString(const LocParamCount: Integer;
 const LocParams: array of Char; const AnLang: TFuncParamLang;
 out AnResultParam: String): String;
var
  K, L: Integer;
begin
  Result := '';
  K := 0;
  L := 0;
  while K < LocParamCount do
  begin
    // Check param type
    //pfVar, pfConst, pfArray, pfAddress, pfReference, pfOut
    case Byte(LocParams[L]) and 39 of
      1:
      case AnLang of
        fplDelphi:
          Result := Result + 'var ';
        fplVBScript:
          Result := Result + 'ByRef ';
      end;
      2:
      case AnLang of
        fplDelphi:
          Result := Result + 'const ';
      end;
      4:
      case AnLang of
        fplDelphi:
          Result := Result + 'array of ';
      end;
      32:
      case AnLang of
        fplDelphi:
          Result := Result + 'out ';
        fplVBScript:
          Result := Result + 'ByRef ';
      end;
    else
      case AnLang of
        fplVBScript:
          Result := Result + 'ByVal ';
      end;
    end;

    // Copy Param Name
    Inc(L);
    Result := Result + Copy(PChar(@LocParams[L + 1]), 1, Byte(LocParams[L]));

    // Copy Param Type
    L := L + Byte(LocParams[L]) + 1;
    if AnLang = fplDelphi then
      Result := Result + ': ' + Copy(PChar(@LocParams[L + 1]), 1, Byte(LocParams[L]));

    // Add ';' if needed
    if K < LocParamCount - 1 then
      case AnLang of
        fplDelphi:
          Result := Result + '; ';
        fplVBScript, fplJScript:
          Result := Result + ', ';
      end;

    // Set position
    L := L + Byte(LocParams[L]) + 1;

    Inc(K);
  end;
  AnResultParam := Copy(PChar(@LocParams[L + 1]), 1, Byte(LocParams[L]));
end;

function TEventItem.GetObjectName: String;
begin
  Result := '';
  if Assigned(FObject) then
    Result := FObject.ObjectName;
end;

function TEventItem.GetParamCount: Integer;
begin
  Result := FEventData^.ParamCount;
end;

function TEventItem.GetParams(const AnLang: TFuncParamLang): String;
var
  LResultParam: String;
begin
  Result := GetDelphiParamString(FEventData^.ParamCount, FEventData^.ParamList,
   AnLang, LResultParam);
end;

procedure TEventItem.Reset;
begin
  FOldEvent.Code := nil;
  FOldEvent.Data := nil;
  FIsOldEventSet := False;
end;

procedure TEventItem.SetEventID(const Value: Integer);
begin
  FEventID := Value;
end;

procedure TEventItem.SetOldEvent(const Value: TMethod);
begin
  if not FIsOldEventSet then
  begin
    FOldEvent := Value;
    FIsOldEventSet := True;
  end else
    raise Exception.Create(GetGsException(Self, 'Значение старого обработчика событий уже присвоено!!!'));
end;

procedure TEventItem.SaveChangeInDB(AnDatabase: TIBDatabase);
var
  ibsqlUpdate: TIBSQL;
  ibtrUpdate: TIBTransaction;
begin
  Assert(Assigned(EventObject), 'Саша! У тебя ошибка!');

  if not Assigned(EventObject) then
    exit;

  ibtrUpdate := TIBTransaction.Create(nil);
  try
    ibtrUpdate.DefaultDatabase := AnDatabase;
    ibsqlUpdate := TIBSQL.Create(nil);
    try
      ibsqlUpdate.Database := AnDatabase;
      ibsqlUpdate.Transaction := ibtrUpdate;
      ibtrUpdate.StartTransaction;

      try
        ibsqlUpdate.SQL.Text :=
          'UPDATE evt_objectevent ' +
            'SET functionkey = :functionkey, disable = :disable WHERE ' +
            'objectkey = :objectkey AND UPPER(eventname) = :eventname';

        ibsqlUpdate.ParamByName('functionkey').AsInteger := FunctionKey;
        if Disable then
          ibsqlUpdate.ParamByName('disable').AsInteger := 1
        else
          ibsqlUpdate.ParamByName('disable').AsInteger := 0;
        ibsqlUpdate.ParamByName('objectkey').AsInteger := EventObject.ObjectKey;
        ibsqlUpdate.ParamByName('eventname').AsString := AnsiUppercase(Name);
        ibsqlUpdate.ExecQuery;

        ibtrUpdate.Commit;
      except
        if ibtrUpdate.InTransaction then
          ibtrUpdate.Rollback;
      end;
    finally
      ibsqlUpdate.Free;
    end;
  finally
    ibtrUpdate.Free;
  end;
end;

{ TEventList }

function TEventList.Add(const ASource: TEventItem): Integer;
begin
  Result := inherited Add(TEventItem.Create);
  if Assigned(ASource) then
    Last.Assign(ASource);
end;

function TEventList.Add(const AName: String;
  const AFuncKey: Integer): Integer;
begin
  Result := Add(nil);
  Last.Name := AName;
  Last.FunctionKey := AFuncKey;
end;

procedure TEventList.Assign(ASource: TEventList);
var
  I: Integer;
begin
  Clear;
  for I := 0 to ASource.Count - 1 do
    Add(ASource.Items[I]);
end;

procedure TEventList.DeleteForName(const AName: String);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if AnsiUpperCase(Name[I]) = AnsiUpperCase(AName) then
    begin
      Delete(i);
      Break;
    end;
end;

function TEventList.Find(const AName: String): TEventItem;
begin
  Result := ItemByName[AName];
end;

function TEventList.GetEventName(Index: Integer): String;
begin
  Result := Items[Index].Name;
end;

function TEventList.GetFunc(Index: Integer): Integer;
begin
  Result := Items[Index].FunctionKey;
end;

function TEventList.GetItem(Index: Integer): TEventItem;
begin
  Result := TEventItem(inherited Items[Index]);
end;

function TEventList.GetMethod(Index: Integer): TMethod;
begin
  Result := Items[Index].OldEvent;
end;

function TEventList.GetNameItem(const AName: String): TEventItem;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if AnsiCompareText(Name[I], AName) = 0 then
    begin
      Result := Items[I];
      exit;
    end;
  Result := nil;
end;

function TEventList.Last: TEventItem;
begin
  Result := TEventItem(inherited Last);
end;

procedure TEventList.SetEventName(Index: Integer; const Value: String);
begin
  Items[Index].Name := UpperCase(Value);
end;

procedure TEventList.SetFunc(Index: Integer; const Value: Integer);
begin
  Items[Index].FunctionKey := Value;
end;

procedure TEventList.SetMethod(Index: Integer; const Value: TMethod);
begin
  Items[Index].OldEvent := Value;
end;

{ TCustomFunctionItem }

{ TCustomFunctionItem }

function TCustomFunctionItem.ComplexParams(const AnLang: TFuncParamLang;
  const FunctionName: String): String;
begin
  Result := GetComplexParams(AnLang, FunctionName);
end;

procedure TCustomFunctionItem.SetDisable(const Value: Boolean);
begin
  FDisable := Value;
end;

procedure TCustomFunctionItem.SetFunctionKey(const Value: Integer);
begin
  FFunctionKey := Value;
end;

procedure TCustomFunctionItem.SetName(const Value: String);
begin
  FCustomName := Value;
end;

initialization
  Assert((SizeOf(strStartObject) = SizeOf(strEndObject)) and
   (SizeOf(strStartObjList) = SizeOf(strEndObjList)));

finalization

end.





