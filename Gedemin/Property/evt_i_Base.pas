// ShlTanya, 24.02.2019

unit evt_i_Base;

interface

uses
  Classes, rp_report_const, forms, windows, gdcBaseInterface;

type
  TEditMode = (
    emNone,
    emEvent,
    emMethod,
    emMacros,
    emReport);

  TShowMode = (
    smEvent,
    smMethod,
    smMacros,
    smReport,
    smScriptFunction,
    smVBClasses);

  TShowModeSet = set of TShowMode;

  type
    TPrpOperation = (
      poInsert,
      poRemove,
      poPost,
      poCancel,
      poRename);

const
  smAll = [smEvent, smMethod, smMacros, smReport, smScriptFunction, smVBClasses];

type
  TEventSynchronize = procedure(const AnObjectName, AnEventName: String) of object;
  TVarParamEvent = function(AnVarParam: Variant): OleVariant of object;
  TFuncParamLang = (fplDelphi, fplJScript, fplVBScript);
  TChangeReportType = (ctReportGroupAdd, ctReportGroupDelete, ctReportGroupDrag,
    ctReportAdd, ctReportDelete, ctReportDrag);

  IEventControl = interface
  ['{AF83FB96-DD8F-11D5-B631-00C0DF0E09D1}']
    function Get_KnownEventList: TStrings;
    function Get_Self: TObject;
    function Get_PropertyIsLoaded: Boolean;

    procedure LoadBranch(const AnObjectKey: TID);
    // Инициализация
    procedure LoadLists;
    // Установка событий для компоненты
    // В случае если событие для компонента установлена
    // вызывается Exception
    // !!! Использовать при создании объекта
    //     во все остальных случаях RebootEvents
    procedure SetEvents(AnComponent: TComponent;
      const OnlyComponent: Boolean = False);
    // Перезагрузка событий компоненты
    procedure RebootEvents(AnComponent: TComponent);
    // Снятие событий для компоненты
    procedure ResetEvents(AnComponent: TComponent);
    // Установка событий для дочерних компоненты
    procedure SetChildEvents(AnComponent: TComponent);
    // Установка событий для компоненты
    // Использовать ТОЛЬКО если надо установить
    // события для дорерних компонент, при условии что
    // события на часть дочерних компонент уже установлена
    procedure SafeCallSetEvents(AnComponent: TComponent);
    // Снятие событий для дочерних компонент
    procedure ResetChildEvents(AnComponent: TComponent);
    // Возвращает список событий для компоненты
    // Формат строки <EventName=FunctionName>
    // Возвращает False если компонента не обнаружена
    function ObjectEventList(const AnComponent: TComponent;
     AnEventList: TStrings): Boolean;
    // Вызов окна редактирования для методов класса
    procedure GoToClassMethods(const AClassName,
      ASubType: string);
    // Вызов окна редактирования для всех свойств
    procedure EditObject(const AnComponent: TComponent;
     const EditMode: TEditMode; const AnName: String = '';
     const AnFunctionID: TID = 0);
    //Редактирование отдельной скрипт функции
    function EditScriptFunction(var AFunctionKey: TID): Boolean;
    //Уведомляет окно свойств об изменениях в системе  
    procedure PropertyNotification(AComponent: TComponent;
      Operation: TPrpOperation; const ANewName: string = '');
    procedure DisableProperty;
    procedure EnableProperty;
    function IsPropertyVisible: boolean;
    function GetPropertyHanlde: THandle;
    function GetProperty: TCustomForm;
    function GetPropertyCanChangeCaption: Boolean;
    procedure PrepareSOEditorForModal;
    procedure SetPropertyCanChangeCaption(const Value: Boolean);
    //Редактирование отчета
    procedure EditReport(IDReportGroup, IDReport: TID);
    //Пытается закрыть окно редактирования одиночной функции
    //Если окно закрылось возвр. ТРУ
    function PropertyClose: Boolean;
    procedure PropertyUpDateErrorsList;
    //Удаляет событие
    procedure DeleteEvent(FormName, ComponentName, EventName: string);
    // Возвращает список известных событий
    property KnownEventList: TStrings read Get_KnownEventList;
    //Имеет значение ТРУ если окно редактирования создано
    property PropertyIsLoaded: Boolean read Get_PropertyIsLoaded;
    property PropertyCanChangeCaption: Boolean read GetPropertyCanChangeCaption
      write SetPropertyCanChangeCaption;
    procedure GetParamInInterface(AVarInterface: IDispatch; AParam: OleVariant);

    procedure RegisterFrmReport(frmReport: TObject);
    procedure UnRegisterFrmReport(frmReport: TObject);
    procedure UpdateReportGroup;

    procedure EventLog;
    //Сброс EventControla
    procedure Drop;

    procedure CheckCreateForm;
    procedure DebugScriptFunction(const AFunctionKey: TID;
      const AModuleName: string = scrUnkonownModule;
      const CurrentLine: Integer = - 1);

    procedure AssignEvents(const Source, Acceptor: TComponent); overload;
    procedure AssignEvents(const SourceName: String; Acceptor: TComponent); overload;

    function GetVarParamEvent: TVarParamEvent;
    property OnVarParamEvent: TVarParamEvent read GetVarParamEvent;
    function GetReturnVarParamEvent: TVarParamEvent;
    property OnReturnVarParam: TVarParamEvent read GetReturnVarParamEvent;
    function AddDynamicCreatedEventObject(AnComponent: TComponent): integer;
  end;

var
  EventControl: IEventControl;
  UnEventMacro: Boolean;

implementation

uses
  gd_CmdLineParams_unit;

initialization
  EventControl := nil;
  UnEventMacro := gd_CmdLineParams.UnEvent;

finalization

end.
