unit evt_i_Base;

interface

uses
  Classes, rp_report_const, forms, windows;

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

    procedure LoadBranch(const AnObjectKey: Integer);
    // �������������
    procedure LoadLists;
    // ��������� ������� ��� ����������
    // � ������ ���� ������� ��� ���������� �����������
    // ���������� Exception
    // !!! ������������ ��� �������� �������
    //     �� ��� ��������� ������� RebootEvents
    procedure SetEvents(AnComponent: TComponent;
      const OnlyComponent: Boolean = False);
    // ������������ ������� ����������
    procedure RebootEvents(AnComponent: TComponent);
    // ������ ������� ��� ����������
    procedure ResetEvents(AnComponent: TComponent);
    // ��������� ������� ��� �������� ����������
    procedure SetChildEvents(AnComponent: TComponent);
    // ��������� ������� ��� ����������
    // ������������ ������ ���� ���� ����������
    // ������� ��� �������� ���������, ��� ������� ���
    // ������� �� ����� �������� ��������� ��� �����������
    procedure SafeCallSetEvents(AnComponent: TComponent);
    // ������ ������� ��� �������� ���������
    procedure ResetChildEvents(AnComponent: TComponent);
    // ���������� ������ ������� ��� ����������
    // ������ ������ <EventName=FunctionName>
    // ���������� False ���� ���������� �� ����������
    function ObjectEventList(const AnComponent: TComponent;
     AnEventList: TStrings): Boolean;
    // ����� ���� �������������� ��� ������� ������
    procedure GoToClassMethods(const AClassName,
      ASubType: string);
    // ����� ���� �������������� ��� ���� �������
    procedure EditObject(const AnComponent: TComponent;
     const EditMode: TEditMode; const AnName: String = '';
     const AnFunctionID: integer = 0);
    //�������������� ��������� ������ �������
    function EditScriptFunction(var AFunctionKey: Integer): Boolean;
    //���������� ���� ������� �� ���������� � �������  
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
    //�������������� ������
    procedure EditReport(IDReportGroup, IDReport: Integer);
    //�������� ������� ���� �������������� ��������� �������
    //���� ���� ��������� �����. ���
    function PropertyClose: Boolean;
    procedure PropertyUpDateErrorsList;
    //������� �������
    procedure DeleteEvent(FormName, ComponentName, EventName: string);
    // ���������� ������ ��������� �������
    property KnownEventList: TStrings read Get_KnownEventList;
    //����� �������� ��� ���� ���� �������������� �������
    property PropertyIsLoaded: Boolean read Get_PropertyIsLoaded;
    property PropertyCanChangeCaption: Boolean read GetPropertyCanChangeCaption
      write SetPropertyCanChangeCaption;
    procedure GetParamInInterface(AVarInterface: IDispatch; AParam: OleVariant);

    procedure RegisterFrmReport(frmReport: TObject);
    procedure UnRegisterFrmReport(frmReport: TObject);
    procedure UpdateReportGroup;

    procedure EventLog;
    //����� EventControla
    procedure Drop;

    procedure CheckCreateForm;
    procedure DebugScriptFunction(const AFunctionKey: Integer;
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
