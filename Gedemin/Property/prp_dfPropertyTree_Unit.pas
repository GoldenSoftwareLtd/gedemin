unit prp_dfPropertyTree_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, prp_TreeItems, ImgList, evt_Base, Db, dmImages_unit,
  IBCustomDataSet, gdcBase, gdcTree, gdcDelphiObject, gd_ClassList,
  mtd_Base, gdc_createable_form, ActnList, gdcFunction, TB2Item, TB2Dock,
  TB2Toolbar, gdcMacros, gdcReport, SuperPageControl, gd_createable_form,
  Menus, StdCtrls, FR_Ctrls, FR_Combo, prp_DOCKFORM_unit, evt_i_Base,
  gdcCustomFunction, ExtCtrls;

const
  dfPasteError = 'Невозможно вставить данные из буфера обмена.';
  dfNoSaveError = 'Сохраните объект перед копированием в буфер обмена.';

type
  TSearchDir = (sdAbove, sdBelow);
  //Этот класс необходим для поддержания Drag&Drop
  TprpTreeView = class(TTreeView)
  private
    FMemoryStream: TMemoryStream;
    FClassesRootNode: TTreeNode;

    FMacrosRootNode: TTreeNode;
    FGORootNode: TTreeNode;
    FReportRootNode: TTreeNode;
    FObjectsRootNode: TTreeNode;
    FSFRootNode: TTreeNode;
    FConstRootNode: TTreeNode;
    FVBClassRootNode: TTreeNode;
    FPrologRootNode: TTreeNode;
    //Индекс нода при сохранении в поток
    FNodeIndex: Integer;
    //Индексы основных нодов
    FClassesRootNodeIndex: Integer;
    FMacrosRootNodeIndex: Integer;
    FGORootNodeIndex: Integer;
    FReportRootNodeIndex: Integer;
    FgdcReportRootNodeIndex: Integer;
    FObjectsRootNodeIndex: Integer;
    FSFRootNodeIndex: Integer;
    FConstRootNodeIndex: Integer;
    FVBClassRootNodeIndex: Integer;
    FSelectedIndex: Integer;
    FPrologRootNodeIndex: Integer;
    FgdcReportRootNode: TTreeNode;
    procedure SetgdcReportRootNode(const Value: TTreeNode);
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure ReadHasChildren(Stream: TStream);
    procedure ReadNodeHasChildren(N: TTreeNode; Stream: TStream);
    procedure SaveHasChildren(Stream: TStream);
    procedure SaveNodeHasChildren(N: TTreeNode; Stream: TStream);
    procedure ReadRootNodes;
    procedure InitRootIndexes;
    procedure UpdateRootIndexes(N: TTreeNode; Index: Integer);

  public
    destructor Destroy; override;

    property MacrosRootNode: TTreeNode read FMacrosRootNode write FMacrosRootNode;
    property SFRootNode: TTreeNode read FSFRootNode write FSFRootNode;
    property ObjectsRootNode: TTreeNode read FObjectsRootNode write FObjectsRootNode;
    property ReportRootNode: TTreeNode read FReportRootNode write FReportRootNode;
    property gdcReportRootNode: TTreeNode read FgdcReportRootNode write SetgdcReportRootNode;
    property ClassesRootNode: TTreeNode read FClassesRootNode write FClassesRootNode;
    property VBClassRootNode: TTreeNode read FVBClassRootNode write FVBClassRootNode;
    property ConstRootNode: TTreeNode read FConstRootNode write FConstRootNode;
    property GORootNode: TTreeNode read FGORootNode write FGORootNode;
    property PrologRootNode: TTreeNode read FPrologRootNode write FPrologRootNode;
  end;

  TTreeTabSheet = class(TSuperTabSheet)
  private
    FTree: TprpTreeView;

    procedure SetMacrosRootNode(const Value: TTreeNode);
    procedure SetConstRootNode(const Value: TTreeNode);
    procedure SetObjectsRootNode(const Value: TTreeNode);
    procedure SetGORootNode(const Value: TTreeNode);
    procedure SetClassesRootNode(const Value: TTreeNode);
    procedure SetReportRootNode(const Value: TTreeNode);
    procedure SetSFRootNode(const Value: TTreeNode);
    procedure SetVBClassRootNode(const Value: TTreeNode);
    procedure SetPrologRootNode(const Value: TTreeNode);
    function GetPrologRootNode: TTreeNode;
    function GetClassesRootNode: TTreeNode;
    function GetConstRootNode: TTreeNode;
    function GetGORootNode: TTreeNode;
    function GetMacrosRootNode: TTreeNode;
    function GetObjectsRootNode: TTreeNode;
    function GetReportRootNode: TTreeNode;
    function GetVBClassRootNode: TTreeNode;
    function GetSFRootNode: TTreeNode;
    procedure SetgdcReportRootNode(const Value: TTreeNode);
    function GetgdcReportRootNode: TTreeNode;
  private
    FMemoryStream: TMemoryStream;
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Tree: TprpTreeView read FTree;
    property MacrosRootNode: TTreeNode read GetMacrosRootNode write SetMacrosRootNode;
    property SFRootNode: TTreeNode read GetSFRootNode write SetSFRootNode;
    property ObjectsRootNode: TTreeNode read GetObjectsRootNode write SetObjectsRootNode;
    property ReportRootNode: TTreeNode read GetReportRootNode write SetReportRootNode;
    property gdcReportRootNode: TTreeNode read GetgdcReportRootNode write SetgdcReportRootNode;
    property ClassesRootNode: TTreeNode read GetClassesRootNode write SetClassesRootNode;
    property VBClassRootNode: TTreeNode read GetVBClassRootNode write SetVBClassRootNode;
    property ConstRootNode: TTreeNode read GetConstRootNode write SetConstRootNode;
    property GORootNode: TTreeNode read GetGORootNode write SetGORootNode;
    property PrologRootNode: TTreeNode read GetPrologRootNode write SetPrologRootNode;
  end;

  TdfClipboard = class(TObject)
  private
    FObjectStream: TMemoryStream;
    FObjectType: TTreeItemType;

  public
    constructor Create;
    destructor  Destroy; override;

    function  CanMakePasteObject(TreeItem: TCustomTreeItem): Boolean;
    procedure FillClipboard(const Stream: TStream; ObjectType: TTreeItemType);

    property ObjectType: TTreeItemType read FObjectType;
    property ObjectStream: TMemoryStream read FObjectStream;
  end;

type
  TdfPropertyTree = class(TDockableForm)
    gdcDelphiObject: TgdcDelphiObject;
    ActionList: TActionList;
    actAddItem: TAction;
    gdcFunction: TgdcFunction;
    actDeleteItem: TAction;
    TBDock1: TTBDock;
    tbtMain: TTBToolbar;
    TBItem2: TTBItem;
    gdcMacrosGroup: TgdcMacrosGroup;
    actAddFolder: TAction;
    TBItem3: TTBItem;
    gdcReportGroup: TgdcReportGroup;
    gdcReport: TgdcReport;
    imTreeView: TImageList;
    TBSeparatorItem2: TTBSeparatorItem;
    pmTreeView: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    tbtObjectList: TTBToolbar;
    TBControlItem1: TTBControlItem;
    cbObjectList: TComboBox;
    TBSeparatorItem4: TTBSeparatorItem;
    TBItem4: TTBItem;
    actRefresh: TAction;
    actRefreshTree: TAction;
    N4: TMenuItem;
    actDisable: TAction;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    actAddToSetting: TAction;
    N8: TMenuItem;
    N9: TMenuItem;
    actRenameItem: TAction;
    N10: TMenuItem;
    TBItem1: TTBItem;
    N11: TMenuItem;
    N12: TMenuItem;
    actCopy: TAction;
    actPaste: TAction;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem5: TTBItem;
    TBItem7: TTBItem;
    actEdit: TAction;
    TBItem8: TTBItem;
    actCopyObject: TMenuItem;
    actPasteObject: TMenuItem;
    FindDialog: TFindDialog;
    N13: TMenuItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBItem6: TTBItem;
    actFind: TAction;
    actClassInfo: TAction;
    N14: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure tvClassesDeletion(Sender: TObject; Node: TTreeNode);
    procedure tvClassesDblClick(Sender: TObject);
    procedure tvClassesEditing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure tvClassesGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure tvClassesCompare(Sender: TObject; Node1, Node2: TTreeNode;
      Data: Integer; var Compare: Integer);
    procedure tvClassesAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure actAddItemExecute(Sender: TObject);
    procedure actDeleteItemExecute(Sender: TObject);
    procedure actDeleteItemUpdate(Sender: TObject);
    procedure actAddFolderUpdate(Sender: TObject);
    procedure actAddFolderExecute(Sender: TObject);
    procedure tvClassesEdited(Sender: TObject; Node: TTreeNode;
      var S: String);
    procedure actAddItemUpdate(Sender: TObject);
    procedure tvClassesExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure actAddItemHint(var HintStr: String; var CanShow: Boolean);
    procedure tvClassesChange(Sender: TObject; Node: TTreeNode);
    procedure tvClassesGetSelectedIndex(Sender: TObject; Node: TTreeNode);
    procedure cbObjectListDropDown(Sender: TObject);
    procedure cbObjectListChange(Sender: TObject);
    procedure tbtObjectListResize(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actRefreshTreeExecute(Sender: TObject);
    procedure tvClassesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actDisableExecute(Sender: TObject);
    procedure pmTreeViewPopup(Sender: TObject);
    procedure actAddToSettingExecute(Sender: TObject);
    procedure actAddToSettingUpdate(Sender: TObject);
    procedure actRenameItemUpdate(Sender: TObject);
    procedure actRenameItemExecute(Sender: TObject);
    procedure actCopyUpdate(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actPasteUpdate(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actClassInfoUpdate(Sender: TObject);
    procedure actClassInfoExecute(Sender: TObject);
  private
    FdfClipboard: TdfClipboard;
    FOnChangeNode: TTVChangedEvent;

    function FindNode(ID: Integer; AParent: TTreeNode): TTreeNode;
    function FindNodeByClass(AClass: TClass; ASubType: string; APTN: TTreeNode): TTreeNode;
    function FindMethod(Id: Integer): TTreeNode;
    function FindMacros(Id: Integer): TTreeNode;
    function FindEvent(Id: Integer): TTreeNode;
    function FindReportFunction(Id: Integer): TTreeNode;
    function FindReport(Id: Integer): TTreeNode;
    function FindPrologSF(Id: Integer): TTreeNode;

    function FindVBClass(Id: Integer): TTreeNode;
    function FindConst(Id: Integer): TTreeNode;
    function FindGO(ID: Integer): TTreeNode;
    procedure InitOverloadAndDisable(C: TMethodClass);
    function GetSelectedNode: TTreeNode;
    function GetActiveTree: TTreeView;
    function GetActivePage: TTreeTabSheet;
    procedure FunctionNotFound(ID: Integer);
    procedure SetOnChangeNode(const Value: TTVChangedEvent);
    { Private declarations }
    procedure SetVisibleDisable;
    function  FindMacrosByKey(MacrosKey: Integer): TTreeNode;
  protected
    FPageControl: TSuperPageControl;

    FDBID: Integer;

    FCopyNode: TTreeNode;
    FCut: Boolean;

    FLastFindNode: TTreeNode;
    FSearchString: string;
    FSearchOptions: TFindOptions;
     // Получаем EventControl по его інтерфейсу
    function GetEventControl: TEventControl;

    procedure RefreshVBClassTreeRoot(AParent: TTreeNode; OwnerId: Integer;
      OwnerName: String);
    procedure RefreshConstTreeRoot(AParent: TTreeNode);
    procedure RefreshGOTreeRoot(AParent: TTreeNode);

    //проверяет присвено ли ид овнера для ветки содерж. нод
    procedure CheckOwnerId(Node: TTreeNode);
    //Обновляет ИД овнера. ТН - нод овнера
    procedure UpdateOwnerId(TN: TTreeNode; Id: Integer);
    //Возвращает имя новой папки
    function GetName(const AName: String; const AParentNode: TTreeNode): String;
    function GetDBId: Integer;
    //Функции работы с папками макросов
    procedure LoadMacrosFolder(AParent: TTreeNode; Id: Integer);
    function LoadMacrosFolderByObject(AParent: TTreeNode; Id: Integer;
      TV: TCustomTreeView; Create: Boolean = True): TTreeNode;
    function AddMacrosFolderNode(AParent: TTreeNode; Id: Integer; Name: string):TTreeNode;overload;
    function AddMacrosFolderNode(Parent: TTreeNode; Id: Integer; Name: string;
      TV: TCustomTreeView):TTreeNode;overload;
    function AddMacrosNode(Parent: TTreeNode; Id: Integer; Name: string):TTreeNode;
    //Добавляет папку локальных объектов
    procedure AddLocalMacrosFolder(Id: Integer);
    //Функции работы с классами
    procedure AddGDCClasses(AParent: TTreeNode; Index: Integer);overload;
    procedure AddGDCClasses(AParent: TTreeNode; Index: Integer; CClass: TClass);overload;
    //функция добавления одного нода гдс-класса без учета фильтра
    //используется при поиске функции
    //ClassName = ClassName + subtype
    function AddGDCClass(AParent: TTreeNode; ClassName, SubType: string): TTreeNode;
    function AddGDCClassNode(AParent: TTreeNode; I: Integer;
      SubType, SubTypeComent: String): TTreeNode; overload;
    function AddFRMClassNode(AParent: TTreeNode; I: Integer;
      SubType, SubTypeComent: String): TTreeNode;
    procedure AddMethods(AParent: TTreeNode; IsGDC: Boolean);
    //Добавляем нод метода
    function AddMethodItem(AnMethod: TMethodItem;
      const AnParentNode: TTreeNode): TTreeNode; overload;
    //Добавление одного нода метода без учета фильтра
    //используется при поиске функции
    function AddMethod(MethodName: string;
      const AParent: TTreeNode): TTreeNode; overload;
    //Функции работы с объектами
    //Добавление нода объекта
    procedure AddObjects(Parent: TTreeNode; C: TComponent);
    function AddObjectNode(Parent: TTreeNode; Name, ClassName: string): TTreeNode;
    function AddFormNode(F: TForm; id: Integer; TV: TCustomTreeView): TTreeNode;
    function CheckObjectNode(AParent: TTreeNode; ObjectName,
      ClassName: string; Add: Boolean = True): TTreeNode;
    function CheckComponentNode(Component: TComponent; Add: Boolean; const AOldName: string = ''): TTreeNode;
    // Заполняем список ивентов для класса в дереве
    procedure FillEvents(AnObject: TComponent; const AnTreeNode: TTreeNode;
      AddAll: Boolean = False);
    function AddEventNode(C: TComponent; AParent: TTreeNode; Name: string): TTreeNode;
    function CheckEventNode(C: TComponent; AParent: TTreeNode; Name: string): TTreeNode;
    procedure CheckFullEvents(Node: TTreeNode);
    //Возвращает указатель наформу
    function GetForm(Name: string): TCreateableForm;
    //Функции работы с отчетами
    procedure LoadAppReportRootNode(Parent: TTreeNode);
    function GetReportFolderChildrenCount(Id: Integer): Integer;
    procedure LoadReportFolder(Parent: TTreeNode; Id: Integer);
    function AddReportFolderNode(Parent: TTreeNode; Id: Integer;
      Name: string): TTreeNode;overload;
    function AddReportFolderNode(Parent: TTreeNode; Id: Integer; Name: string;
      TV: TCustomTreeView): TTreeNode;overload;
    function AddReportNode(Parent: TTreeNode; Id: Integer; Name: string):TTreeNode;
    function LoadReportFolderByObject(AParent: TTreeNode; Id: Integer): TTreeNode;
    function CheckCreateLocalReportFolder(Id: Integer; Name: string): Integer;
    procedure CheckCreateGDCReportFolder(Id: Integer; gdcObject: TgdcBase);
    procedure CheckLoadReportFolder(Node: TTreeNode);
    //Функции работы с Sf
    //Возвращает строку с условие для выборки СФ из базы
    function GetSFWhereClause(const AnID: Integer): String;
    function AddSfRootNode(Id: Integer; OwnerName: string; TV: TTReeView): TTreeNode;
    procedure LoadSf(Node: TTreeNode);
    procedure LoadPrologSF(Node: TTreeNode);
    function AddPrologSFRootNode(Id: Integer; OwnerName: string; TV: TTReeView): TTreeNode;
    function GetSFType(Module: string): sfTypes;
    function AddSFNode(Parent: TTreeNode; id: Integer; Name: string): TTreeNode;
    procedure CheckLoadSf(TN: TTreeNode);
    procedure CheckLoadPrologSF(TN: TTreeNode);
    function AddPSFNode(Parent: TTreeNode; id: Integer; Name: string): TTreeNode;

    //Возвращает индекс закладки объекта
    function IndexOfByObjId(Id: Integer): Integer;
    //
    //добавление закладки для Application
    procedure AddApplicationPage;
    //добавление закладки для объекта
    function AddFormPage(F: TCreateableForm): TTreeTabSheet;
    //Присваивает обработчики событий
    procedure AppropriateHandlers(TV: TTreeView);

    procedure OnChangePage(Sender: TObject);
    procedure SetObjectIndex;
    //Находит форму владельца компонента и возвращает закладку для формы
    function CheckComponentPage(C: TComponent): TTreeTabSheet;

    property LocEventControl: TEventControl read GetEventControl;
    property SelectedNode: TTreeNode read GetSelectedNode;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;

    procedure DestroyWnd; override;
    function DoFindNode(ANode: TTreeNode; Index: Integer; SearchDir: TSearchDir): TTreeNode;
    function DoFindNext(ANode: TTreeNode): TTreeNode;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    function GetPageByObjID(Id: Integer): TTreeTabSheet;
    procedure UpdatePages;
    procedure UpdateEventOverload(TN: TTreeNode; Increment: Integer);
    procedure UpdateEventDesabled(TN: TTreeNode; Increment: Integer);
    procedure UpdateMethodOverload(TN: TTreeNode; Increment: Integer);
    procedure UpdateMethodDisabled(TN: TTreeNode; Increment: Integer);
    function  AddVBClassItem: TCustomTreeItem;
    procedure AddConstItem;
    function  AddSFItem: TCustomTreeItem;
    function AddPSFItem: TCustomTreeItem;
    procedure AddGOItem;
    function  AddMacrosItem: TCustomTreeItem;
    procedure AddMacrosFolder;
    procedure AddReportFolder;
    function  AddReportItem: TCustomTreeItem;
    procedure Expand(Node: TTreeNode);
    function FindSF(ID: Integer): TTreeNode; overload;
    function FindSF(ID: Integer; Module: String): TTreeNode; overload;
    procedure OpenNode(TN: TTreeNode);
    procedure RefreshSf;
    procedure RefreshObjects;
    procedure RefreshClasses;
    procedure RefreshFullClassName(const FullName: Boolean);
    function CheckFormPage(F: TCreateableForm): TTreeTabSheet;
    procedure OpenEvent(Component: TComponent; EventName: string;
      const AFunctionID: integer = 0);
    procedure OpenMacrosRootFolder(Component: TComponent);
    procedure OpenReportRootFolder(Component: TComponent);
    procedure OpenObjectPage(Component: TComponent);
    //Ищет и открывает на редактирование отчёт
    //Возвращает Тру если отчет найден в дереве и открыт
    function OpenReport(ID: integer): Boolean;
    function OpenMacros(MacrosKey: integer): Boolean;
    function FindReportFolder(Id: Integer; OnlyApplication: Boolean = False): TTreeNode;
    procedure InvalidateTree;
    //Возвращает строковое представление пути к выделенному ноду
    function GetPath: string;
    //Обновляет дерево объекта удаляя или добавляя
    procedure InsertRemoveObject(C: TComponent; Operation: TPrpOperation);
    procedure RenameObject(C: TComponent; const AOldName: string = '');

    procedure CancelCopy;

    property  dfClipboard: TdfClipboard read FdfClipboard;

    property ActivePage: TTreeTabSheet read GetActivePage;
    property ActiveTree: TTreeView read GetActiveTree;
    property PageControl: TSuperPageControl read FPageControl;
    property OnChangeNode: TTVChangedEvent read FOnChangeNode write SetOnChangeNode;

    procedure GoToClassMethods(AClassName, ASubType: string); overload;
    procedure GoToClassMethods(AClass: TClass; ASubType: string); overload;
  end;

var
  dfPropertyTree: TdfPropertyTree;

implementation

uses
  prp_frmGedeminProperty_Unit, prp_Filter, prp_PropertySettings,
  TypInfo, IBSQL, gdcConstants, mtd_i_Base, rp_report_const, gd_security,
  gd_security_operationconst, prp_MessageConst, prp_BaseFrame_unit,
  gdcBaseInterface, dlgClassInfo_unit,
//  {$IFDEF GEDEMIN}
  prp_EventFrame_unit, prp_MethodFrame_unit,
//  {$ENDIF}
  gsComponentEmulator
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;
  
{$R *.DFM}

function GetOwnerForm(Component: TComponent): TCreateableForm;
var
  C: TComponent;
begin
  Result := nil;
  C := Component;
  if Assigned(C) then
  begin
    while C <> nil do
    begin
      if C is TCreateableForm then
      begin
        Result := TCreateableForm(C);
        Exit;
      end;
      C := C.Owner;
    end;
  end;
end;

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

procedure TdfPropertyTree.UpdateEventOverload(TN: TTreeNode;
  Increment: Integer);
var
  ATN: TTreeNode;
begin
  //все нормально можно работать
  ATN := TN;
  while TCustomTreeItem(ATN.Data).ItemType = tiObject do
  begin
    TObjectTreeItem(ATN.Data).OverloadEnevts :=
      TObjectTreeItem(ATN.Data).OverloadEnevts + Increment;
    if TObjectTreeItem(ATN.Data).OverloadEnevts < 0 then
      TObjectTreeItem(ATN.Data).OverloadEnevts := 0;
    ATN := ATN.Parent;
  end;
  TN.TreeView.Invalidate;
end;

procedure TdfPropertyTree.FillEvents(AnObject: TComponent;
  const AnTreeNode: TTreeNode; AddAll: Boolean = False);
var
  I, J: Integer;
  TempPropList: TPropList;
  CurrentObject: TEventObject;
  E: TEventItem;
begin
  if Assigned(EventControl) then
  begin
    J := GetPropList(AnObject.ClassInfo, [tkMethod], @TempPropList);
    CurrentObject := (TObject(AnTreeNode.Data) as TObjectTreeItem).EventObject;
    if Assigned(CurrentObject) then
    begin
      for I := 0 to J - 1 do
      begin
        E := CurrentObject.EventList.Find(TempPropList[I]^.Name);
        if (not PropertySettings.Filter.OnlySpecEvent or
          (PropertySettings.Filter.OnlySpecEvent and Assigned(CurrentObject) and
          Assigned(E) and (E.FunctionKey > 0))) and
          (not PropertySettings.Filter.OnlyDisabled or
          (PropertySettings.Filter.OnlyDisabled and Assigned(CurrentObject) and
          Assigned(E) and E.Disable)) and
          (Filter(TempPropList[I]^.Name, PropertySettings.Filter.EventName,
          TFilterOptions(PropertySettings.Filter.foEvent))) or
          AddAll then
        begin
          AddEventNode(AnObject, AnTreeNode, TempPropList[I]^.Name);
        end;
      end;
    end;
  end;
end;

function TdfPropertyTree.GetEventControl: TEventControl;
begin
  Result := nil;
  if Assigned(EventControl) then
    Result := EventControl.Get_Self as TEventControl;
end;

procedure TdfPropertyTree.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  inherited;

  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TgdcBase then
    begin
      TgdcBase(Components[I]).UseScriptMethod := False;
      if not TgdcBase(Components[I]).ReadTransaction.InTransaction then
        TgdcBase(Components[I]).ReadTransaction.StartTransaction;
    end;
  end;
  FPageControl := TSuperPageControl.Create(Self);
  FPageControl.Align := alClient;
  FPageControl.Parent := Self;
  FPageControl.OnChange := OnChangePage;
  FPageControl.TabsVisible := False;
  FPageControl.TabStop := False;
  UpdatePages;
end;

procedure TdfPropertyTree.tvClassesDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  if Assigned(Node.Data) and not (csDocking in ControlState) then
    TCustomTreeItem(Node.Data).Free;
  if FLastFindNode = Node then
    FLastFindNode := nil;  
end;

procedure TdfPropertyTree.tvClassesDblClick(Sender: TObject);
var
  TI: TCustomTreeItem;
  Node: TTreeNode;
begin
  CancelCopy;
  if Assigned(SelectedNode) then
  begin
    Node := SelectedNode;
    TI := TCustomTreeItem(Node.Data);
    case TI.ItemType of
      tiEvent: CheckOwnerId(Node);
      tiMethod: CheckOwnerId(Node);
    end;

    if  TI.ItemType in [tiEvent, tiMethod,
      tiVBClass, tiConst, tiGlobalObject, tiMacros, tiReport, tiSf, tiPrologSF] then
      TfrmGedeminProperty(DockForm).ShowFrame(TI);

{    if TCustomTreeItem(TTreeView(Sender).Selected.Data).EditorFrame <> nil then
      TTreeView(Sender).Selected.OverlayIndex := 15}
  end;
end;

procedure TdfPropertyTree.CheckOwnerId(Node: TTreeNode);
var
  NameList: TStrings;
  I: Integer;
  TN: TTreeNode;
  Id: Integer;
  SQL: TIBSQL;
  Add: Boolean;
  O: Boolean;

  procedure InsertObject(var Id: Integer; const Parent: Variant;
      AName: string);
  begin
    if not gdcDelphiObject.Active then gdcDelphiObject.Open;
    gdcDelphiObject.Insert;
    gdcDelphiObject.FieldByName(fnObjectName).AsString := AName;
    gdcDelphiObject.FieldByName(fnParent).Value := Parent;
    gdcDelphiObject.Post;
    Id := gdcDelphiObject.FieldByName(fnId).AsInteger;
  end;

  procedure InsertClass(var Id: Integer; const Parent: Variant;
      AName, SubType: string);
  begin
    if not gdcDelphiObject.Active then gdcDelphiObject.Open;
    gdcDelphiObject.Insert;
    gdcDelphiObject.FieldByName(fnClassName).AsString := AName;
    gdcDelphiObject.FieldByName(fnSubType).AsString := Subtype;
    gdcDelphiObject.FieldByName(fnParent).Value := Parent;
    gdcDelphiObject.Post;
    Id := gdcDelphiObject.FieldByName(fnId).AsInteger;
  end;

begin
  if Assigned(Node) and (TCustomTreeItem(Node.Data).OwnerId = 0) then
  begin
    if TCustomTreeItem(Node.Data).ItemType in [tiEvent, tiMethod] then
    begin
      if gdcDelphiObject.Active then gdcDelphiObject.Close;
      try
        O := TCustomTreeItem(Node.Data).ItemType = tiEvent;
        NameList := TStringList.Create;
        try
          TN := Node.Parent;
          while TCustomTreeItem(TN.Data).ItemType in [tiObject, tiGDCClass, tiForm] do
          begin
            I := NameList.Add(TCustomTreeItem(TN.Data).Name);
            NameList.Objects[I] := TN;
            TN := TN.Parent;
            if not Assigned(TN) then Break;
          end;

          if NameList.Count > 0 then
          begin
            Add := False;
            SQL := TIBSQL.Create(nil);
            try
              if gdcDelphiObject.Transaction.InTransaction then
                SQL.Transaction := gdcDelphiObject.Transaction
              else
                SQL.Transaction := gdcDelphiObject.ReadTransaction;
              if O then
              begin
                SQL.SQL.Text := 'SELECT * FROM evt_object WHERE UPPER(objectname) = :name AND parent IS NULL';
                SQL.Params[0].AsString := UpperCase(NameList[NameList.Count - 1]);
              end else
              begin
                SQL.SQL.Text := 'SELECT * FROM evt_object WHERE UPPER(classname) = :name AND ' +
                  ' UPPER(subtype) = :subtype';
                SQL.Params[0].AsString :=
                  UpperCase(TCustomTreeItem(TTreeNode(NameList.Objects[NameList.Count - 1]).Data).Name);
                SQL.Params[1].AsString :=
                  UpperCase(TGDCClassTreeItem(TTreeNode(NameList.Objects[NameList.Count - 1]).Data).SubType);
              end;
              SQL.ExecQuery;
              if SQL.Eof then
              begin
                if O then
                  InsertObject(Id, Null, NameList[NameList.Count - 1])
                else
                  InsertClass(Id, Null,
                    TCustomTreeItem(TTreeNode(NameList.Objects[NameList.Count - 1]).Data).Name,
                    TGDCClassTreeItem(TTreeNode(NameList.Objects[NameList.Count - 1]).Data).SubType);
                UpdateOwnerId(TTreeNode(NameList.Objects[NameList.Count - 1]), Id);
                Add := True;
              end else
                Id := SQL.FieldByName(fnId).AsInteger;

              SQL.Close;
              if O then
                SQL.SQL.Text := 'SELECT * FROM evt_object WHERE parent = :parent AND ' +
                  'UPPER(objectname) = :name'
              else
                SQL.SQL.Text := 'SELECT * FROM evt_object WHERE parent = :parent AND ' +
                  'UPPER(classname) = :name AND UPPER(subtype) = :subtype';

              for I := NameList.Count - 2 downto 0 do
              begin
                SQL.Params[0].AsInteger := id;
                if O then
                  SQL.Params[1].AsString := UpperCase(NameList[I])
                else
                begin
                  SQL.Params[1].AsString :=
                    UpperCase(TCustomTreeItem(TTreeNode(NameList.Objects[I]).Data).Name);
                  SQL.Params[2].AsString :=
                    UpperCase(TGDCClassTreeItem(TTreeNode(NameList.Objects[I]).Data).SubType);
                end;
                SQL.ExecQuery;
                if SQL.Eof then
                begin
                  if O then
                    InsertObject(Id, Id, NameList[I])
                  else
                    InsertClass(Id, Id,
                      TCustomTreeItem(TTreeNode(NameList.Objects[I]).Data).Name,
                      TGDCClassTreeItem(TTreeNode(NameList.Objects[I]).Data).SubType);

                  UpdateOwnerId(TTreeNode(NameList.Objects[I]), Id);
                  Add := True;
                end else
                  Id := SQL.FieldByName(fnId).AsInteger;
                SQL.Close;
              end;

              TCustomTreeItem(Node.Data).OwnerId := id;
              if Add then
              begin
                if O then
                  EventControl.LoadBranch(Id);
              end;
            finally
              SQL.Free;
            end;
          end;
        finally
          NameList.Free;
        end;
      finally
        gdcDelphiObject.Close;
      end;
    end;
  end;
end;

procedure TdfPropertyTree.UpdateOwnerId(TN: TTreeNode; Id: Integer);
var
  I: Integer;
begin
  if Assigned(TN) then
  begin
    TCustomTreeItem(TN.Data).ID := Id;
    for I := 0 to TN.Count -1 do
      TCustomTreeItem(TN.Item[I].Data).OwnerId := Id;
  end;
end;

procedure TdfPropertyTree.tvClassesEditing(Sender: TObject;
  Node: TTreeNode; var AllowEdit: Boolean);
begin
  AllowEdit := (tCustomTreeItem(Node.Data).ItemType in [tiMacrosFolder,
    tiReportFolder]) and (tCustomTreeItem(Node.Data).ID > 0);
end;

procedure TdfPropertyTree.tvClassesGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  case TCustomTreeItem(Node.Data).ItemType of
    tiMacrosFolder, tiReportFolder, tiSFFolder, tiConstFolder,
    tiGlobalObjectFolder, tiObjectFolder, tiGDCClassFolder,
    tiVBClassFolder, tiPrologSFFolder:
    begin
      Node.SelectedIndex := 9;
      Node.ImageIndex := 8;
    end;
    tiEvent:
    begin
      if TEventTreeItem(Node.Data).Id > 0 then
      begin
        if TEventTreeItem(Node.Data).EventItem.Disable then
          Node.ImageIndex := 24
        else
          Node.ImageIndex := 4;
      end else
        Node.ImageIndex := 40;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    tiMethod:
    begin
      if TMethodTreeItem(Node.Data).ID > 0 then
      begin
        if TMethodTreeItem(Node.Data).TheMethod.Disable then
          Node.ImageIndex := 30
        else
          Node.ImageIndex := 3;
      end else
        Node.ImageIndex := 34;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    tiMacros:
    begin
      Node.ImageIndex := 5;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    tiReport:
    begin
      Node.ImageIndex := 10;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    tiSF:
    begin
      case TSFTreeItem(Node.data).SFType of
        sfReport: Node.ImageIndex := 23;
        sfMacros: Node.ImageIndex := 20;
        sfEvent: Node.ImageIndex := 4;
        sfMethod: Node.ImageIndex := 3;
        sfUnknown: Node.ImageIndex := 24;
      end;
      Node.SelectedIndex := Node.ImageIndex;
    end;
    tiVBClass:
    begin
      Node.SelectedIndex := 42;
      Node.ImageIndex := 42;
    end;
    tiPrologSF:
    begin
      Node.SelectedIndex := 24;
      Node.ImageIndex := 24;
    end;
  end;
end;

procedure TdfPropertyTree.tvClassesCompare(Sender: TObject; Node1,
  Node2: TTreeNode; Data: Integer; var Compare: Integer);
var
  NT1, NT2: Integer;
begin
  NT1 := Integer(TCustomTreeItem(Node1.Data).ItemType);
  NT2 := Integer(TCustomTreeItem(Node2.Data).ItemType);
  Compare := NT1 - NT2;
  if Compare = 0 then
    Compare := CompareText(Node1.Text, Node2.Text);
end;

procedure TdfPropertyTree.tvClassesAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  NodeType: TTreeItemType;
begin
  NodeType := TCustomTreeItem(Node.Data).ItemType;
  if ((NodeType = tiEvent) and
    (TEventTreeItem(Node.Data).EventItem.FunctionKey > 0)) {or
    ((NodeType in [tiReportFunction, tiReportTemplate]) and
    (TscrCustomItem(Node.Data).Id > 0)) } or
    ((NodeType = tiMethod) and (TMethodTreeItem(Node.Data).TheMethod.FunctionKey > 0)) then
  begin
    Sender.Canvas.Font.Style := [fsBold];
    if (cdsSelected in State) and not (cdsFocused in State) then
    begin
      Sender.Canvas.Font.Color := clWindowText;
      Sender.Canvas.Brush.Color := clInactiveCaptionText;
    end;
  end else if NodeType = tiObject then
  begin
    //Проверяем определен ли какой нибудь Event
    if TObjectTreeItem(Node.Data).OverloadEnevts > 0 then
      Sender.Canvas.Font.Style := [fsBold];
    if TObjectTreeItem(Node.Data).DisabledEvents > 0 then
    begin
      Sender.Canvas.Font.Color := clRed
    end else
      Sender.Canvas.Font.Color := clWindowText;
    if (cdsSelected in State) then
      Sender.Canvas.Font.Color := clHighlightText;
  end else if NodeType = tiGDCClass then
  begin
    //Проверяем определен ли какой нибудь метод
    if TgdcClassTreeItem(Node.Data).OverloadMethods > 0 then
      Sender.Canvas.Font.Style := [fsBold];
    //Если есть отключенные, то цвет красный
    if TgdcClassTreeItem(Node.Data).DisabledMethods > 0 then
    begin
      Sender.Canvas.Font.Color := clRed
    end else
      Sender.Canvas.Font.Color := clWindowText;
    if (cdsSelected in State) then
      Sender.Canvas.Font.Color := clHighlightText;
  end;
end;

function TdfPropertyTree.AddMethodItem(AnMethod: TMethodItem;
  const AnParentNode: TTreeNode): TTreeNode;
var
  MI: TMethodTreeItem;
begin
  Result := TTreeView(AnParentNode.TreeView).Items.AddChild(AnParentNode,
    AnMethod.Name);
  MI := TMethodTreeItem.Create;
  MI.Id := AnMethod.MethodId;
  MI.Name := AnMethod.Name;
  MI.OwnerId := TgdcClassTreeItem(AnParentNode.Data).Id;
  MI.TheMethod := AnMethod;
  Result.Data := MI;
  MI.Node := Result;
  if TMethodTreeItem(Result.Data).TheMethod.Disable then
    TgdcClassTreeItem(AnParentNode.Data).TheClass.SpecDisableMethod :=
      TgdcClassTreeItem(AnParentNode.Data).TheClass.SpecDisableMethod + 1;
end;

procedure TdfPropertyTree.UpdateMethodOverload(TN: TTreeNode;
  Increment: Integer);
var
  ATN: TTreeNode;
begin
  //все нормально можно работать
  ATN := TN;
  while TCustomTreeItem(ATN.Data).ItemType = tigdcClass do
  begin
    TgdcClassTreeItem(ATN.Data).OverloadMethods :=
      TgdcClassTreeItem(ATN.Data).OverloadMethods + Increment;
    if TgdcClassTreeItem(ATN.Data).OverloadMethods < 0 then
      TgdcClassTreeItem(ATN.Data).OverloadMethods := 0;
    ATN := ATN.Parent;
  end;
  ActiveTree.Invalidate;
end;


procedure TdfPropertyTree.RefreshVBClassTreeRoot(AParent: TTreeNode;
  OwnerId: Integer; OwnerName: String);
var
  SQL: TIBSQL;
  TN: TTreeNode;
  VBI: TVBClassTreeItem;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcDelphiObject.ReadTransaction;
    SQL.SQL.Text := 'SELECT name, id, modulecode FROM gd_function WHERE UPPER(module) = :module ' +
      'and modulecode = :modulecode';
    SQL.Params[0].AsString := scrVBClasses;
    SQL.Params[1].AsInteger := OwnerId;
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      TN := TTreeView(AParent.TreeView).Items.AddChild(AParent,
        SQL.FieldByName(fnName).AsString);
      VBI := TVBClassTreeItem.Create;
      VBI.Id := SQL.FieldByName(fnId).AsInteger;
      VBI.Name := SQL.FieldByName(fnName).AsString;
      VBI.OwnerId := SQL.FieldByName(fnModuleCode).AsInteger;
      VBI.MainOwnerName := OwnerName;
      VBI.Node := TN;
      TN.Data := VBI;
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdfPropertyTree.RefreshConstTreeRoot(AParent: TTreeNode);
var
  SQL: TIBSQL;
  TN: TTreeNode;
  VBI: TConstTreeItem;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcDelphiObject.ReadTransaction;
    SQL.SQL.Text := 'SELECT name, id, modulecode FROM gd_function WHERE UPPER(module) = :module';
    SQL.Params[0].AsString := scrConst;
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      TN := TTreeView(AParent.TreeView).Items.AddChild(AParent,
        SQL.FieldByName(fnName).AsString);
      VBI := TConstTreeItem.Create;
      VBI.Id := SQL.FieldByName(fnId).AsInteger;
      VBI.Name := SQL.FieldByName(fnName).AsString;
      VBI.OwnerId := SQL.FieldByName(fnModuleCode).AsInteger;
      VBI.MainOwnerName := 'APPLICATION';
      VBI.Node := TN;
      TN.Data := VBI;
      TN.ImageIndex := 41;
      TN.SelectedIndex := 41;
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdfPropertyTree.actAddItemExecute(Sender: TObject);
begin
  CancelCopy;
  if Assigned(SelectedNode) then
  begin
    case TCustomTreeItem(SelectedNode.data).ItemType of
      tiVbClass, tiVBClassFolder: AddVBClassItem;
      tiConst, tiConstFolder: AddConstItem;
      tiGlobalObject, tiGlobalObjectFolder: AddGOItem;
      tiMacrosFolder, tiMacros: AddMacrosItem;
      tiReportFolder, tiReport: AddReportItem;
      tiSF, tiSFFolder: AddSFItem;
      tiPrologSF, tiPrologSFFolder: AddPSFItem;
      tiEvent, tiMethod: tvClassesDblClick(nil);
    end;
  end;
end;

function TdfPropertyTree.AddVBClassItem: TCustomTreeItem;
var
  TN: TTreeNode;
  VBI: TVBClassTreeItem;
begin
  Result := nil;
  if Assigned(ActivePage) and
    Assigned(ActivePage.VBClassRootNode) then
  begin
    if not ActivePage.VBClassRootNode.Expanded then
      ActivePage.VBClassRootNode.Expanded := True;
    TN := ActiveTree.Items.AddChild(ActivePage.VBClassRootNode,
      {gdcFunction.GetUniqueName(}NEW_VBCLASS{, '', 0)});
    VBI := TVBClassTreeItem.Create;
    VBI.Id := 0;
    VBI.Name := TN.Text;
    VBI.OwnerId := ActivePage.Tag;
    VBI.MainOwnerName := ActivePage.Caption;
    VBI.Node := TN;
    TN.Data := VBI;
    TN.Selected := True;
    tvClassesDblClick(ActiveTree);
    try
      TBaseFrame(VBI.EditorFrame).Post;
      Result := VBI;
    except
      TN.Delete;
    end;
  end;
end;

procedure TdfPropertyTree.AddConstItem;
var
  TN: TTreeNode;
  VBI: TConstTreeItem;
begin
  if Assigned(ActivePage) and
    Assigned(ActivePage.ConstRootNode) then       
  begin
    if not ActivePage.ConstRootNode.Expanded then
      ActivePage.ConstRootNode.Expanded := True;
    TN := ActiveTree.Items.AddChild(ActivePage.ConstRootNode,
      {gdcFunction.GetUniqueName(}NEW_CONST{, '', OBJ_APPLICATION)});
    VBI := TConstTreeItem.Create;
    VBI.Id := 0;
    VBI.Name := TN.Text;
    VBI.OwnerId := OBJ_APPLICATION;
    VBI.MainOwnerName := 'APPLICATION';
    VBI.Node := TN;
    TN.Data := VBI;
    TN.Selected := True;
    tvClassesDblClick(ActiveTree);
    try
      TBaseFrame(VBI.EditorFrame).Post;
    except
      TN.Delete;
    end;
  end;
end;

procedure TdfPropertyTree.actDeleteItemExecute(Sender: TObject);
var
  TN: TTreeNode;
  I, J: Integer;
begin
  CancelCopy;
  TN := SelectedNode;
  if Assigned(TN) then
  begin
    if TCustomTreeItem(TN.Data).ItemType in [tiMacrosFolder, tiReportFolder] then
    begin
      if TCustomTreeItem(TN.Data).ItemType = tiMacrosFolder then
      begin
        gdcMacrosGroup.Id := TCustomTreeItem(TN.Data).Id;
        gdcMacrosGroup.Open;
        try
          try
            gdcMacrosGroup.Delete;
            TN.Delete;
          except
          end;
        finally
          gdcMacrosGroup.Close;
        end;
      end else
      begin
        gdcReportGroup.Id := TCustomTreeItem(TN.Data).Id;
        gdcReportGroup.Open;
        try
          try
            gdcReportGroup.Delete;
            for i := 0 to FPageControl.PageCount - 1 do
            begin
              for J := TTreeTabSheet(FPageControl.Pages[I]).Tree.Items.Count - 1 downto 0 do
              begin
                if (TCustomTreeItem(TTreeTabSheet(FPageControl.Pages[I]).Tree.Items[J].Data).Id =
                  TCustomTreeItem(TN.Data).Id) and
                  (TTreeTabSheet(FPageControl.Pages[I]).Tree.Items[J] <> TN) then
                  TTreeTabSheet(FPageControl.Pages[I]).Tree.Items[J].Delete;
              end;
            end;
            TN.Delete;
            EventControl.UpdateReportGroup;
          except
          end;
        finally
          gdcReportGroup.Close;
        end;
      end;
    end else
    begin
      if Assigned(TCustomTreeItem(TN.Data).EditorFrame) then
      begin
        TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame).SpeedButton.Click;
        TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame).Delete;
      end else
      begin
        TfrmGedeminProperty(DockForm).ShowFrame(TCustomTreeItem(TN.Data), False);
        if TCustomTreeItem(TN.Data).EditorFrame <> nil then
          if not TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame).Delete then
            if TCustomTreeItem(TN.Data).EditorFrame <> nil then
            begin
              TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame).Free;
              TCustomTreeItem(TN.Data).EditorFrame := nil;
            end;
      end;
      EventControl.UpdateReportGroup;
    end;
  end;
end;

procedure TdfPropertyTree.actDeleteItemUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=
    Assigned(SelectedNode) and
    (TCustomTreeItem(SelectedNode.Data).ItemType in [tiMacros,
    tiReport, tiConst, tiVBClass, tiSF, tiGlobalObject, tiMacrosFolder,
    tiReportFolder, tiEvent, tiMethod, tiPrologSF]) and (TCustomTreeItem(SelectedNode.Data).ID > 0) and
    (tCustomTreeItem(Activetree.Selected.Data).ID <> OBJ_GLOBALMACROS);
end;

procedure TdfPropertyTree.RefreshGOTreeRoot(AParent: TTreeNode);
var
  SQL: TIBSQL;
  TN: TTreeNode;
  VBI: TGlobalObjectTreeItem;
begin
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcDelphiObject.ReadTransaction;
    SQL.SQL.Text := 'SELECT name, id, modulecode FROM gd_function WHERE UPPER(module) = :module';
    SQL.Params[0].AsString := scrGlobalObject;
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      TN := TTreeView(AParent.TreeView).Items.AddChild(AParent,
        SQL.FieldByName(fnName).AsString);
      VBI := TGlobalObjectTreeItem.Create;
      VBI.Id := SQL.FieldByName(fnId).AsInteger;
      VBI.Name := SQL.FieldByName(fnName).AsString;
      VBI.OwnerId := SQL.FieldByName(fnModuleCode).AsInteger;
      VBI.MainOwnerName := 'APPLICATION';
      VBI.Node := TN;
      TN.Data := VBI;
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdfPropertyTree.AddGOItem;
var
  TN: TTreeNode;
  VBI: TGlobalObjectTreeItem;
begin
  if Assigned(ActivePage) and
    Assigned(ActivePage.GORootNode) then
  begin
    if not ActivePage.GORootNode.Expanded then
      ActivePage.GORootNode.Expanded := True;
    TN := ActiveTree.Items.AddChild(ActivePage.GORootNode,
      {gdcFunction.GetUniqueName(}NEW_GLOBALOBJECT{, '', OBJ_APPLICATION)});
    VBI := TGlobalObjectTreeItem.Create;
    VBI.Id := 0;
    VBI.Name := TN.Text;
    VBI.OwnerId := OBJ_APPLICATION;
    VBI.MainOwnerName := 'APPLICATION';
    VBI.Node := TN;
    TN.Data := VBI;
    TN.Selected := True;
    tvClassesDblClick(ActiveTree);
    try
      TBaseFrame(VBI.EditorFrame).Post;
    except
      TN.Delete;
    end;
  end;
end;

function TdfPropertyTree.AddMacrosItem: TCustomTreeItem;
var
  TN: TTreeNode;
  VBI: TMacrosTreeItem;
begin
  Result := nil;
  if Assigned(SelectedNode) and (TCustomTreeItem(SelectedNode.data).ItemType in
    [tiMacros, tiMacrosFolder]) then
  begin
    if TCustomTreeItem(SelectedNode.data).ItemType = tiMacros then
      TN := SelectedNode.Parent
    else
      TN := SelectedNode;
    Expand(TN);
    VBI := TMacrosTreeItem.Create;
    VBI.MacrosFolderId := TMacrosTreeFolder(TN.Data).Id;
    VBI.OwnerId := TCustomTreeItem(TN.Data).OwnerId;
    VBI.MainOwnerName := TCustomTreeItem(TN.Data).MainOwnerName;
    TN := ActiveTree.Items.AddChild(TN,
      {gdcFunction.GetUniqueName(}'Macros'{, '',
        TCustomTreeItem(SelectedNode.data).OwnerId)});
    VBI.Id := 0;
    VBI.Name := TN.Text;
    VBI.Node := TN;
    TN.Data := VBI;
    TN.Selected := True;
    tvClassesDblClick(ActiveTree);
    if VBI.EditorFrame <> nil then
    begin
      try
        TBaseFrame(VBI.EditorFrame).Post;
        Result := VBI;
      except
        TN.Delete;
      end;
    end;
  end;
end;

procedure TdfPropertyTree.Expand(Node: TTreeNode);
var
  TN: TTreeNode;
begin
  TN := Node;
  while Assigned(TN) do
  begin
    TN.Expanded := True;
    TN := TN.Parent;
  end;
end;

procedure TdfPropertyTree.actAddFolderUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(SelectedNode) and
    (TCustomTreeItem(SelectedNode.Data).ItemType in [tiMacros, tiReport,
    tiMacrosFolder, tiReportFolder]) and
    (TCustomTreeItem(SelectedNode.Data).Id > 0) and
    (tCustomTreeItem(Activetree.Selected.Data).ID <> OBJ_GLOBALMACROS);
end;

procedure TdfPropertyTree.actAddFolderExecute(Sender: TObject);
begin
  if Assigned(SelectedNode) then
  begin
    case TCustomTreeItem(SelectedNode.Data).ItemType of
      tiMacros, tiMacrosFolder: AddMacrosFolder;
      tiReport, tiReportFolder: AddReportFolder;
    end;
  end;
  // Здесь только отчет, папка обновляется в tvClassesEdited
  if TCustomTreeItem(SelectedNode.Data).ItemType in [tiReportFolder, tiReport] then
    EventControl.UpdateReportGroup;
end;

procedure TdfPropertyTree.AddMacrosFolder;
var
  FI: TMacrosTreeFolder;
  TN: TTreeNode;
begin
  if Assigned(SelectedNode) then
  begin
    if TCustomTreeItem(SelectedNode.Data).ItemType = tiMAcros then
      TN := SelectedNode.Parent
    else
      TN := SelectedNode;
    Expand(TN);

    gdcMacrosGroup.Open;
    try
      gdcMacrosGroup.Insert;
      try
        gdcMacrosGroup.FieldByName(fnName).AsString := GetName(NEW_FOLDER_NAME, TN);
        gdcMacrosGroup.FieldByName(fnIsGlobal).AsInteger :=
          Integer(TCustomTreeItem(TN.Data).OwnerId = OBJ_APPLICATION);
        if TCustomTreeItem(TN.Data).ID > 0 then
          gdcMacrosGroup.FieldByName(fnParent).AsInteger := TCustomTreeItem(TN.Data).ID;

        gdcMacrosGroup.Post;
        FI := TMacrosTreeFolder.Create;
        FI.Parent := TCustomTreeFolder(TN.Data);
        FI.OwnerId := TCustomTreeFolder(TN.Data).OwnerId;
        FI.MainOwnerName := TCustomTreeFolder(TN.Data).MainOwnerName;
        TN := ActiveTree.Items.AddChild(TN, gdcMacrosGroup.FieldByName(fnName).AsString);
        FI.Node := TN;
        TN.Data := FI;
        FI.Name := TN.Text;
        FI.Id := gdcMacrosGroup.FieldByName(fnID).AsInteger;
        FI.ChildsCreated := True;
        TN.Selected := True;
        TN.EditText;
      except
        gdcMacrosGroup.Cancel;
      end;
    finally
      gdcMacrosGroup.Close;
    end;
  end;
end;

function TdfPropertyTree.GetName(const AName: String;
  const AParentNode: TTreeNode): String;
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

procedure TdfPropertyTree.tvClassesEdited(Sender: TObject; Node: TTreeNode;
  var S: String);
var
  SQL: TIBSQL;
  DidActivate: Boolean;
const
  NOT_FOUND = 'Переименуемая папка не найдена в базе';
begin
  case TCustomTreeItem(Node.Data).ItemType of
    tiMacrosFolder:
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcMacrosGroup.Transaction;
        SQL.SQL.Text := 'UPDATE evt_macrosgroup SET name = :name WHERE id = :id';
        DidActivate := not SQL.Transaction.InTransaction;
        if DidActivate then
          SQL.Transaction.StartTransaction;
        try
          SQL.Params[0].AsString := S;
          SQL.Params[1].AsInteger := TMacrosTreeFolder(Node.Data).ID;
          SQL.ExecQuery;
          if DidActivate then
            SQL.Transaction.Commit;
        except
          if DidActivate then
            SQL.Transaction.RollBack;
        end;
      finally
        SQL.Free;
      end;
    end;
    tiReportFolder:
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcReportGroup.Transaction;
        SQL.SQL.Text := 'UPDATE rp_reportgroup SET name = :name WHERE id = :id';
        DidActivate := not SQL.Transaction.InTransaction;
        if DidActivate then
          SQL.Transaction.StartTransaction;
        try
          SQL.Params[0].AsString := S;
          SQL.Params[1].AsInteger := TReportTreeFolder(Node.Data).ID;
          SQL.ExecQuery;
          if DidActivate then
            SQL.Transaction.Commit;
        except
          if DidActivate then
            SQL.Transaction.RollBack;
        end;
      finally
        SQL.Free;
      end;
    end;
  end;
  if TCustomTreeItem(Node.Data).ItemType in [tiReportFolder, tiReport] then
    EventControl.UpdateReportGroup;
end;


procedure TdfPropertyTree.actAddItemUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=
    Assigned(SelectedNode) and
    (((TCustomTreeItem(SelectedNode.Data).ItemType in [tiMacros,
    tiReport, tiConst, tiVBClass, tiSF, tiPrologSF, tiGlobalObject, tiMacrosFolder,
    tiReportFolder]) and (TCustomTreeItem(SelectedNode.Data).ID > 0)) or
    (TCustomTreeItem(SelectedNode.Data).ItemType in [tiSFFolder, tiVBClassFolder,
    tiConstFolder, tiGlobalObjectFolder, tiPrologSFFolder]) or
    ((TCustomTreeItem(SelectedNode.Data).ItemType in [tiEvent, tiMethod]) and
     (TCustomTreeItem(SelectedNode.Data).ID = 0)));
end;

procedure TdfPropertyTree.AddReportFolder;
var
  FI: TReportTreeFolder;
  TN: TTreeNode;
begin
  if Assigned(SelectedNode) then
  begin
    if TCustomTreeItem(SelectedNode.Data).ItemType = tiReport then
      TN := SelectedNode.Parent
    else
      TN := SelectedNode;
    CheckLoadReportFolder(TN);

    gdcReportGroup.Open;
    try
      gdcReportGroup.Insert;
      try
        gdcReportGroup.FieldByName(fnName).AsString := GetName(NEW_FOLDER_NAME, TN);
        if TCustomTreeItem(TN.Data).ID > 0 then
          gdcReportGroup.FieldByName(fnParent).AsInteger := TCustomTreeItem(TN.Data).ID;
        if gdcReportGroup.FieldByName(fnUserGroupName).IsNull then
          gdcReportGroup.FieldByName(fnUserGroupName).AsString := IntToStr(gdcReportGroup.ID) +
            '_' + IntToStr(GetDBID);
        gdcReportGroup.Post;
        FI := TReportTreeFolder.Create;
        FI.Parent := TCustomTreeFolder(TN.Data);
        FI.OwnerId := TCustomTreeFolder(TN.Data).OwnerId;
        FI.MainOwnerName := TCustomTreeFolder(TN.Data).MainOwnerName;
        TN := ActiveTree.Items.AddChild(TN, gdcReportGroup.FieldByName(fnName).AsString);
        FI.Node := TN;
        TN.Data := FI;
        FI.Name := TN.Text;
        Fi.Id := gdcReportGroup.FieldByName(fnID).AsInteger;
        FI.ChildsCreated := True;
        TN.Selected := True;
        TN.EditText;
      except
        gdcReportGroup.Cancel;
        TN.Delete;
      end;
    finally
      gdcReportGroup.Close;
    end;
  end;
end;

function TdfPropertyTree.GetDBId: Integer;
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

function TdfPropertyTree.AddReportItem: TCustomTreeItem;
var
  TN: TTreeNode;
  VBI: TReportTreeItem;
begin
  Result := nil;
  if Assigned(SelectedNode) and (TCustomTreeItem(SelectedNode.data).ItemType in
    [tiReport, tiReportFolder]) then
  begin
    if TCustomTreeItem(SelectedNode.data).ItemType = tiReport then
      TN := SelectedNode.Parent
    else
      TN := SelectedNode;
    Expand(TN);

    VBI := TReportTreeItem.Create;
    VBI.ReportFolderId := TReportTreeFolder(TN.Data).Id;
    VBI.OwnerId := TCustomTreeItem(TN.data).OwnerId;
    VBI.MainOwnerName := TCustomTreeItem(TN.data).MainOwnerName;
    TN := ActiveTree.Items.AddChild(TN, gdcReport.GetUniqueName(NEW_REPORT_NAME,
      '', TReportTreeFolder(TN.Data).Id));
    VBI.Id := 0;
    VBI.Name := TN.Text;
    VBI.Node := TN;
    TN.Data := VBI;
    TN.Selected := True;
    tvClassesDblClick(ActiveTree);
    if VBI.EditorFrame is TBaseFrame then
      try
        TBaseFrame(VBI.EditorFrame).Post;
        Result := VBI;
      except
        //
      end;
    if Result = nil then
      TN.Delete;
    EventControl.UpdateReportGroup;
  end;
end;

procedure TdfPropertyTree.LoadMacrosFolder(AParent: TTreeNode;
  Id: Integer);
var
  fSQL: TIBSQL;
  TN: TTreeNode;
  SQL: TIBSQL;
begin
  TCustomTreeFolder(AParent.Data).ChildsCreated := True;
  fSQL := TIBSQL.Create(nil);
  try
    fSQL.Transaction := gdcMacrosGroup.ReadTransaction;
    fSQL.SQL.Text := 'SELECT * FROM evt_macrosgroup WHERE parent = ' +
      IntToStr(Id);
    fSQL.ExecQuery;
    while not fSQL.Eof do
    begin
      TN := AddMacrosFolderNode(AParent, fSQL.FieldByName(fnId).AsInteger,
        fSQL.FieldByName(fnName).AsString);
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcMacrosGroup.ReadTransaction;
        SQL.SQl.Text := Format('SELECT 1 FROM rdb$database WHERE ' +
          ' EXISTS (SELECT 1 FROM evt_macrosgroup WHERE parent = :id) or ' +
          ' EXISTS (SELECT 1 FROM evt_macroslist WHERE macrosgroupkey = :id AND ' +
          ' g_sec_test(aview, %d) <> 0)', [IBLogin.InGroup]);
        SQL.Params[0].AsInteger := fSQL.FieldByName(fnId).AsInteger;
        SQL.ExecQuery;
        TN.HasChildren := not SQL.Eof;
        TCustomTreeFolder(TN.Data).ChildsCreated := not TN.HasChildren;
      finally
        SQL.Free;
      end;
      fSQL.Next;
    end;
    fSQL.Close;
    fSQl.SQL.Text := 'SELECT * FROM evt_macroslist WHERE macrosgroupkey = ' +
      IntToStr(Id) + ' AND g_sec_test(aview, ' + IntToStr(IBLogin.InGroup) + ') <> 0';
    fSQL.ExecQuery;
    while not fSQL.Eof do
    begin
      AddMacrosNode(AParent, fSQL.FieldByName(fnId).AsInteger,
        fSQL.FieldByName(fnName).AsString);
      fSQL.Next;
    end;
  finally
    fSQL.Free;
  end;
end;


function TdfPropertyTree.AddMacrosFolderNode(AParent: TTreeNode; Id: Integer;
  Name: string): TTreeNode;
begin
  Result := nil;
  if Assigned(AParent) then
    Result := AddMacrosFolderNode(AParent, Id, Name, AParent.TreeView);
end;

function TdfPropertyTree.AddMacrosNode(Parent: TTreeNode; Id: Integer;
  Name: string): TTreeNode;
var
  F: TMacrosTreeItem;
begin
  Result := TTreeView(Parent.TreeView).Items.AddChild(Parent, Name);
  F := TMacrosTreeItem.Create;
  F.Id := Id;
  F.Name := Name;
  if Assigned(Parent) then
  begin
    F.OwnerId := TMacrosTreeFolder(Parent.Data).OwnerID;
    F.MainOwnerName := TMacrosTreeFolder(Parent.Data).MainOwnerName;
    F.MacrosFolderId := TMacrosTreeFolder(Parent.Data).ID;
  end;
  F.Node := Result;
  Result.Data := F;
end;

procedure TdfPropertyTree.tvClassesExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
begin
  case TCustomTreeItem(Node.Data).ItemType of
    tiMacrosFolder:
      if not TCustomTreeFolder(Node.Data).ChildsCreated then
        LoadMacrosFolder(Node, TCustomTreeItem(Node.Data).Id);

    tiReportFolder:
      CheckLoadReportFolder(Node);

    tiGDCClassFolder:
      if not TCustomTreeFolder(Node.Data).ChildsCreated then
      begin
        AddGDCClasses(Node, -1, TgdcBase);
        AddGDCClasses(Node, -1, TgdcCreateableForm);
      end;

    tiGDCClass:
      if not TCustomTreeFolder(Node.Data).ChildsCreated then
        AddGDCClasses(Node, TgdcClassTreeItem(Node.Data).Index);

    tiForm:
      CheckFullEvents(Node);

    tiSfFolder:
      CheckLoadSf(Node);
    tiPrologSFFolder:
      CheckLoadPrologSF(Node);
  end;

  if Node.HasChildren and (Node.Count = 0) then
    Node.HasChildren := False;
end;

function TdfPropertyTree.LoadMacrosFolderByObject(AParent: TTreeNode;
  Id: Integer; TV: TCustomTreeView; Create: Boolean = True): TTreeNode;
var
  SQL: TIBSQL;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcDelphiObject.ReadTransaction;
    SQl.SQl.Text := 'SELECT m.*, o.objectname as MainOwnerName, o.id AS OwnerID FROM ' +
      ' evt_macrosgroup m, evt_object o WHERE ' +
      ' o.id = :id AND o.macrosgroupkey = m.id ';
    SQL.Params[0].AsInteger := Id;
    SQL.ExecQuery;
    if SQL.Eof and Create then
    begin
      //Создаём папку макросов и пепеоткрываем SQL
      AddLocalMacrosFolder(Id);
      SQL.Close;
      SQL.ExecQuery;
    end;
    if not SQL.Eof then
    begin
      Result := AddMacrosFolderNode(AParent, SQL.FieldByName(fnId).AsInteger,
        SQL.FieldByName(fnName).AsString, TV);
      TMacrosTreeFolder(Result.Data).OwnerId := SQL.FieldByName('ownerid').AsInteger;
      TMacrosTreeFolder(Result.Data).MainOwnerName := SQL.FieldByName('MainOwnerName').AsString;
    end;
    if Assigned(Result) then
    begin
      SQL.Close;
      SQL.SQl.Text := Format('SELECT 1 FROM rdb$database WHERE ' +
        ' EXISTS (SELECT 1 FROM evt_macrosgroup WHERE parent = :id) or ' +
        ' EXISTS (SELECT 1 FROM evt_macroslist WHERE macrosgroupkey = :id AND' +
        ' g_sec_test(aview, %d) <> 0)', [IBLogin.InGroup]);
      SQL.Params[0].AsInteger := TMacrosTreeFolder(Result.Data).ID;
      SQL.ExecQuery;
      Result.HasChildren := not SQL.Eof;
      TMacrosTreeFolder(Result.Data).ChildsCreated := not Result.HasChildren;
    end;
  finally
    SQL.Free;
  end;
end;

function TdfPropertyTree.FindPrologSF(Id: Integer): TTreeNode;
var 
  SQL: TIBSQL;
  TS: TTreeTabSheet;
  TN: TTreeNode;
  ModuleCode: Integer;
  PI: TPrologTreeItem;
  N: TTreeNode;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try  
    SQL.Transaction := gdcDelphiObject.ReadTransaction;
    SQL.SQL.Text := 'SELECT g.*, o.objectname As ObjectName FROM gd_function g, ' +
      ' evt_object o WHERE o.id = g.modulecode and g.id = ' + IntToStr(Id);
    SQL.ExecQuery;
    if not SQL.Eof then
    begin
      ModuleCode := SQl.FieldByName(fnModuleCode).AsInteger;
      TS := GetPageByObjID(ModuleCode);
      if Assigned(TS) then
      begin
        TN := TS.PrologRootNode;
        if Assigned(TN) then
        begin
          CheckLoadPrologSf(TN);
          N := TN.GetFirstChild;
          while (N <> nil) do
          begin
            if TPrologTreeItem(N.data).Id = id then
            begin
              Result := N;
              Break;
            end;
            N := N.GetNextSibling;
          end;
          if not Assigned(Result) then
            Result := AddPSFNode(TN, id, SQL.FieldByName(fnName).AsString);
        end;
      end;

      if not Assigned(Result) then
      begin
        TS := GetPageByObjID(OBJ_APPLICATION);
        if Assigned(TS) then
        begin
          TN := TS.PrologRootNode;
          if Assigned(TN) then
          begin
            CheckLoadPrologSf(TN);
            N := TN.GetFirstChild;
            while (N <> nil) do
            begin
              if TSFTreeItem(N.data).Id = id then
              begin
                Result := N;
                Break;
              end;
              N := N.GetNextSibling;
            end;
            if not Assigned(Result) then
            begin
              Result := AddPSFNode(TN, id, SQL.FieldByName(fnName).AsString);
              PI := TPrologTreeItem(Result.Data);
              PI.OwnerId := SQL.FieldByName(fnModuleCode).AsInteger;
              PI.MainOwnerName := SQL.FieldByName('ObjectName').AsString;
            end;
          end;
        end;
      end;
    end;
  finally
    SQL.Free;
  end;
end;

function TdfPropertyTree.FindSF(ID: Integer): TTreeNode;
var
  SQL: TIBSQL;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    //Получаем модуль с.ф. из базы
    SQL.Transaction := gdcDelphiObject.ReadTransaction;
    SQL.SQL.Text := 'SELECT module FROM gd_function WHERE id = ' + IntToStr(Id);
    SQL.ExecQuery;
    if not SQL.Eof then
    begin
      //Если с.ф. найдена в базе то ищем с.ф. в дереве
      Result := FindSf(Id, SQL.FieldByName('module').AsString);
    end else
      //т.к. с.ф. не найденав базе то генерим сообщение
      FunctionNotFound(ID);
  finally
    SQL.Free;
  end;
end;

function TdfPropertyTree.FindSF(ID: Integer; Module: String): TTreeNode;
var
  SQL: TIBSQL;
  TS: TTreeTabSheet;
  TN: TTreeNode;
  ModuleCode: Integer;
  SI: TSFTreeItem;
  N: TTreeNode;
begin
  //Инициализируем результат
  Result := nil;
  UpdatePages;
  CheckHandle(Self);
  //Далаем попытку найти с.ф. с учетом модуля.
  if Module = scrMacrosModuleName then
    Result := FindMacros(Id)
  else
  if (Module = MainModuleName) or (Module = ParamModuleName) or
    (Module = EventModuleName) then
    Result := FindReportFunction(Id)
  else
  if Module = scrMethodModuleName then
    Result := FindMethod(Id)
  else
  if Module = scrEventModuleName then
    Result := FindEvent(Id)
  else
  if Module = scrVBClasses then
    Result := FindVBClass(Id)
  else
  if Module = scrConst then
    Result := FindConst(ID)
  else if Module = scrGlobalObject then
    Result := FindGO(ID)
  else if Module = scrPrologModuleName then
    Result := FindPrologSF(ID);

  //Если функция не найдена то последняя надежда найти среди с.ф.
  if not Assigned(Result) then
  begin
    SQL := TIBSQL.Create(nil);
    try
      //Вытягиваем инф. о функции из базы
      SQL.Transaction := gdcDelphiObject.ReadTransaction;
      SQL.SQL.Text := 'SELECT g.*, o.objectname As ObjectName FROM gd_function g, ' +
        ' evt_object o WHERE o.id = g.modulecode and g.id = ' + IntToStr(Id);
      SQL.ExecQuery;
      if not SQL.Eof then
      begin
        ModuleCode := SQL.FieldByName(fnModuleCode).AsInteger;
        //Ищем падже объекта по ид объекта
        TS := GetPageByObjID(ModuleCode);
        if Assigned(TS) then
        begin
          //если нашли то получаем указатель на нод папки с.ф.
          TN := TS.SFRootNode;
          if Assigned(TN) then
          begin
            CheckLoadSf(TN);
            //если нашли то ищем нужный нод
            N := TN.GetFirstChild;
            while (N <> nil) do
            begin
              if TSFTreeItem(N.data).Id = id then
              begin
                //нашли. выходим.
                Result := N;
                Break;
              end;
              N := N.GetNextSibling;
            end;
            if not Assigned(Result) then
            begin
              //Если не нашли то добавляем нод в дерево
              Result := AddSFNode(TN, id, SQL.FieldByName(fnName).AsString);
              SI := TSFTreeItem(Result.Data);
              SI.SFType := GetSFType(SQL.FieldByName(fnModule).AsString);
            end;
          end;
        end;
        //Если не была найдена страница объекта то
        //делаем попытку найти с.ф. среди с.ф. объекта Application
        if not Assigned(Result) then
        begin
          //Ищем страницу Application
          TS := GetPageByObjID(OBJ_APPLICATION);
          if Assigned(TS) then
          begin
            //Если нашли то получаем нод папки с.ф.
            TN := TS.SFRootNode;
            if Assigned(TN) then
            begin
              CheckLoadSf(TN);
              //Если нашли папку то ищим нужный нод
              N := TN.GetFirstChild;
              while (N <> nil) do
              begin
                if TSFTreeItem(N.data).Id = id then
                begin
                  //нашли. выходим.
                  Result := N;
                  Break;
                end;
                N := N.GetNextSibling;
              end;
              //Если нод небыл найден то добавляем его
              if not Assigned(Result) then
              begin
                Result := AddSFNode(TN, id, SQL.FieldByName(fnName).AsString);
                SI := TSFTreeItem(Result.Data);
                //Подставляем параметры специф. для с.ф.
                SI.SFType := GetSFType(SQL.FieldByName(fnModule).AsString);
                SI.OwnerId := SQL.FieldByName(fnModuleCode).AsInteger;
                SI.MainOwnerName := SQL.FieldByName('ObjectName').AsString;
              end;
            end;
          end;
        end;
      end;

      //Если с.ф. не найдена то генерим сообщение
      if not Assigned(Result) then
        FunctionNotFound(ID);
    finally
      SQL.Free;
    end;
  end;
end;

procedure TdfPropertyTree.OpenNode(TN: TTreeNode);
begin
  if Assigned(TN) then
  begin
    TN.TreeView.Show;
    Expand(TN);
    TN.Selected := True;
    tvClassesDblClick(TN.TreeView);
  end;
end;

function TdfPropertyTree.AddReportFolderNode(Parent: TTreeNode;
  Id: Integer; Name: string): TTreeNode;
begin
  Result := nil;
  if Assigned(Parent) then
    Result := AddReportFolderNode(Parent, Id, Name, Parent.TreeView);
end;

function TdfPropertyTree.AddReportNode(Parent: TTreeNode; Id: Integer;
  Name: string): TTreeNode;
var
  F: TReportTreeItem;
begin
  Result := TTreeView(Parent.TreeView).Items.AddChild(Parent, Name);
  F := TReportTreeItem.Create;
  F.Id := Id;
  F.Name := Name;
  if Assigned(Parent) then
  begin
    F.OwnerId := TReportTreeFolder(Parent.Data).OwnerID;
    F.MainOwnerName := TReportTreeFolder(Parent.Data).MainOwnerName;
    F.ReportFolderId := TReportTreeFolder(Parent.Data).Id;
  end;
  F.Node := Result;
  Result.Data := F;
end;

procedure TdfPropertyTree.LoadReportFolder(Parent: TTreeNode; Id: Integer);
var
  fSQL: TIBSQL;
  TN: TTreeNode;
begin
  TCustomTreeFolder(Parent.Data).ChildsCreated := True;
  fSQL := TIBSQL.Create(nil);
  try
    fSQL.Transaction := gdcReportGroup.ReadTransaction;
    fSQL.SQL.Text := 'SELECT * FROM rp_reportgroup WHERE parent = :P';
    fSQL.ParamByName('P').AsInteger := Id;
    fSQL.ExecQuery;
    while not fSQL.Eof do
    begin
      TN := AddReportFolderNode(Parent, fSQL.FieldByName(fnId).AsInteger,
        fSQL.FieldByName(fnName).AsString);
      TN.HasChildren := GetReportFolderChildrenCount(fSQL.FieldByName(fnId).AsInteger) > 0;
      TCustomTreeFolder(TN.Data).ChildsCreated := not TN.HasChildren;
      fSQL.Next;
    end;
    fSQL.Close;
    fSQl.SQL.Text := 'SELECT * FROM rp_reportlist WHERE reportgroupkey = :K';
    if not IBLogin.IsUserAdmin then
    begin
      fSQl.SQL.Text := fSQl.SQL.Text + ' AND g_sec_test(aview, :U) <> 0';
      fSQL.ParamByName('U').AsInteger := IBLogin.InGroup;
    end;
    fSQL.ParamByName('K').AsInteger := Id;
    fSQL.ExecQuery;
    while not fSQL.Eof do
    begin
      AddReportNode(Parent, fSQL.FieldByName(fnId).AsInteger,
        fSQL.FieldByName(fnName).AsString);
      fSQL.Next;
    end;
  finally
    fSQL.Free;
  end;
end;

function TdfPropertyTree.LoadReportFolderByObject(AParent: TTreeNode;
  Id: Integer): TTreeNode;
var
  SQL, oSQL: TIBSQL;
  TN: TTreeNode;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcMacrosGroup.ReadTransaction;
    SQL.SQL.Text := 'SELECT r.* FROM rp_reportgroup r, evt_object o WHERE ' +
      'o.id = :id and (o.reportgroupkey = r.id or upper(o.objectname) = upper(r.usergroupname))';

    SQL.ExecQuery;
    oSQL := TIBSQL.Create(nil);
    try
      oSQL.Transaction := gdcMacrosGroup.ReadTransaction;
      oSQL.SQL.Text := 'SELECT o.objectname, o.id FROM evt_object o, rp_reportgroup r ' +
        'WHERE r.id = :id and (o.reportgroupkey = r.id or upper(o.objectname) = upper(r.usergroupname))';
      oSQL.Prepare;
      while not SQL.Eof do
      begin
        TN := AddReportFolderNode(AParent, SQL.FieldByName(fnId).AsInteger,
          SQL.FieldByName(fnName).AsString);
        oSQL.Params[0].AsInteger := SQL.FieldByName(fnId).AsInteger;
        oSQL.ExecQuery;
        try
          if not oSQL.Eof then
          begin
            TReportTreeFolder(TN.Data).OwnerId := oSQL.FieldByName(fnId).AsInteger;
            TReportTreeFolder(TN.Data).MainOwnerName := oSQL.FieldByName(fnName).AsString;
          end else
          begin
            TReportTreeFolder(TN.Data).OwnerId := OBJ_APPLICATION;
            TReportTreeFolder(TN.Data).MainOwnerName := 'APPLICATION';
          end;
        finally
          oSQL.Close;
        end;

        TN.HasChildren := GetReportFolderChildrenCount(SQL.FieldByName(fnId).AsInteger) > 0;
        TCustomTreeFolder(TN.Data).ChildsCreated := not TN.HasChildren;
        SQL.Next;
      end;
    finally
      oSQL.Free;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdfPropertyTree.AddGDCClasses(AParent: TTreeNode; Index: Integer; CClass: TClass);
var
  LocClassList: TgdcCustomClassList;
  TreeList, CountList: TList;
  I, J, K: Integer;
  TN: TTreeNode;
  MC: TMethodClass;
  ST: TStrings;
  IsGDC: Boolean;
  Init: Boolean;

  function ClassFilter(Index: Integer; AIsGDC: Boolean; SubType: string): Boolean;
  var
    I: Integer;
    C: TComponentClass;
    MC: TMethodClass;
    SQl: TIBSQL;
    FullClassName: TgdcFullClassName;
  begin
    if AIsGDC then
      C := TgdcClassList(LocClassList).Items[Index]
    else
      C := TfrmClassList(LocClassList).Items[Index];

    FullClassName.gdClassName := C.ClassName;
    FullClassName.SubType := SubType;
    MC := TMethodClass(MethodControl.FindMethodClass(FullClassName));

    Init := False;
    if PropertySettings.Filter.OnlySpecEvent then
    begin
      Result := True;
      if Assigned(MC) then
      begin
        InitOverloadAndDisable(MC);
        Init := True;
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

    if PropertySettings.Filter.OnlyDisabled then
    begin
      Result := True;
      if Assigned(MC) then
      begin
        if not Init then
          InitOverloadAndDisable(MC);
        if MC.SpecDisableMethod > 0 then
        begin
          SQL := TIBSQL.Create(nil);
          try
            SQL.Transaction:= gdcFunction.ReadTransaction;
            SQL.SQL.Text := 'SELECT e.eventname FROM evt_objectevent e, evt_object o1, ' +
              ' evt_object o2 WHERE e.objectkey = o2.id AND o1.lb <= o2.lb AND ' +
              ' o1.rb >= o2.rb AND o1.id = :id AND e.disable = 1';
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
  TCustomTreeFolder(AParent.Data).ChildsCreated := True;
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

      if (TCustomTreeItem(AParent.Data).ItemType = tiGDCClassFolder) or
        (TGDCClassTreeItem(AParent.Data).SubType = '') then
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
              InitOverloadAndDisable(TGDCClassTreeItem(TN.Data).TheClass);
            TGDCClassTreeItem(TN.Data).OverloadMethods :=
              TGDCClassTreeItem(TN.Data).TheClass.SpecMethodCount;
            TGDCClassTreeItem(TN.Data).DisabledMethods :=
              TGDCClassTreeItem(TN.Data).TheClass.SpecDisableMethod;
          end;

        if TCustomTreeItem(AParent.Data).ItemType = tiGDCClass then
        begin
          ST := TStringList.Create;
          try
            MC := TGDCClassTreeItem(AParent.Data).TheClass;
            if MC.Class_Reference.InheritsFrom(TgdcBase) then
              CgdcBase(MC.Class_Reference).GetSubTypeList(ST)
            else
              CgdcCreateableForm(MC.Class_Reference).GetSubTypeList(ST);
              //Добавляем SubTypы класса
              for I := 0 to ST.Count - 1 do
              begin
                if ClassFilter(Index, IsGDC, Replace(ST.Values[ST.Names[I]])) then
                begin
                  if MC.Class_Reference.InheritsFrom(TgdcBase) then
                    TN := AddGDCClassNode(AParent, Index,
                      Replace(ST.Values[ST.Names[I]]), ST.Names[I])
                  else
                    TN := AddFRMClassNode(AParent, Index,
                      Replace(ST.Values[ST.Names[I]]), ST.Names[I]);
                  TN.HasChildren := True;
                  //Если установлен флаг PropertySettings.Filter.OnlySpecEvent то
                  //InitOverloadAndDisable для данного класса вызывалась при фильтрации
                  //иначе вызываем здесь
                  if not PropertySettings.Filter.OnlySpecEvent then
                    InitOverloadAndDisable(TGDCClassTreeItem(TN.Data).TheClass);
                  TGDCClassTreeItem(TN.Data).OverloadMethods :=
                    TGDCClassTreeItem(TN.Data).TheClass.SpecMethodCount;
                  TGDCClassTreeItem(TN.Data).DisabledMethods :=
                    TGDCClassTreeItem(TN.Data).TheClass.SpecDisableMethod;
                end;
              end;
          finally
            ST.Free;
          end;
        end;
      end;

      AddMethods(AParent, IsGDC);
      AParent.HasChildren := AParent.Count > 0;
    finally
      CountList.Clear;
      CountList.Free;
    end;
  finally
    TreeList.Clear;
    TreeList.Free;
  end;
end;

function TdfPropertyTree.AddGDCClassNode(AParent: TTreeNode;
  I: Integer; SubType, SubTypeComent: String): TTreeNode;
var
  CClass: CgdcBase;
  CI: TgdcClassTreeItem;
  MClass: TMethodClass;
  FullName: TgdcFullClassName;
begin
  Result := nil;
  CClass := gdcClassList[I];

  if Assigned(CClass) then
  begin
    FullName.gdClassName := CClass.ClassName;
    FullName.SubType := SubType;
    MClass := TMethodClass(MethodControl.FindMethodClass(FullName));
    if MClass = nil then
      //Если не найден то регистрируем его в списке
      MClass := TMethodClass(MethodControl.AddClass(0, FullName, CClass));
    MClass.Class_Reference := CClass;
    MClass.SubTypeComment := SubTypeComent;

    CI := TgdcClassTreeItem.Create;
    CI.Id := MClass.Class_Key;
    CI.Index := I;
    CI.Name := CClass.ClassName;
    CI.Parent := TgdcClassTreeItem(AParent.Data);
    if CClass.ClassName <> TgdcBase.ClassName then
    begin
      CI.OwnerId := TgdcClassTreeItem(AParent.Data).OwnerId;
      CI.MainOwnerName := TgdcClassTreeItem(AParent.Data).MainOwnerName;
    end else
    begin
      CI.OwnerId := MClass.Class_Key;
      CI.MainOwnerName := CClass.ClassName;
    end;
    CI.OverloadMethods := MClass.SpecMethodCount;
    Ci.DisabledMethods := MClass.SpecDisableMethod;
    CI.TheClass := MClass;
    Result := GetPageByObjID(OBJ_APPLICATION).Tree.Items.AddChild(AParent,
      CClass.ClassName + SubType);
    Result.ImageIndex := 42;
    Result.SelectedIndex := 42;  
    if SubType <> '' then
    begin
      if not PropertySettings.GeneralSet.FullClassName then
        Result.Text := SubType;
    end else
      Result.Text := MClass.Class_Name;
    Result.Data := CI;
    CI.Node := Result;
  end;
end;

procedure TdfPropertyTree.AddGDCClasses(AParent: TTreeNode; Index: Integer);
begin
  if TCustomTreeItem(AParent.Data).ItemType = tiGDCClass then
    AddGDCClasses(AParent, Index, TgdcClassTreeItem(AParent.Data).TheClass.Class_Reference);
end;

function TdfPropertyTree.AddFRMClassNode(AParent: TTreeNode; I: Integer;
  SubType, SubTypeComent: String): TTreeNode;
var
  CClass: CgdcCreateableForm;
  CI: TgdcClassTreeItem;
  MClass: TMethodClass;
  FullName: TgdcFullClassName;
begin
  Result := nil;
  CClass := frmClassList[I];

  if Assigned(CClass) then
  begin
    FullName.gdClassName := CClass.ClassName;
    FullName.SubType := SubType;
    MClass := TMethodClass(MethodControl.FindMethodClass(FullName));
    if MClass = nil then
      //Если не найден то регистрируем его в списке
      MClass := TMethodClass(MethodControl.AddClass(0, FullName, CClass));
    MClass.Class_Reference := CClass;
    MClass.SubTypeComment := SubTypeComent;

    CI := TgdcClassTreeItem.Create;
    CI.Id := MClass.Class_Key;
    CI.Index := I;
    CI.Name := CClass.ClassName;
    CI.Parent := TgdcClassTreeItem(AParent.Data);
    if CClass.ClassName <> TgdcBase.ClassName then
    begin
      CI.OwnerId := TgdcClassTreeItem(AParent.Data).OwnerId;
      CI.MainOwnerName := TgdcClassTreeItem(AParent.Data).MainOwnerName;
    end else
    begin
      CI.OwnerId := MClass.Class_Key;
      CI.MainOwnerName := CClass.ClassName;
    end;
    CI.OverloadMethods := MClass.SpecMethodCount;
    Ci.DisabledMethods := MClass.SpecDisableMethod;
    CI.TheClass := MClass;
    Result := GetPageByObjID(OBJ_APPLICATION).Tree.Items.AddChild(AParent,
      CClass.ClassName + SubType);
    if SubType <> '' then
    begin
      if not PropertySettings.GeneralSet.FullClassName then
        Result.Text := SubType;
    end else
      Result.Text := MClass.Class_Name;
    Result.Data := CI;
    Result.ImageIndex := 42;
    Result.SelectedIndex := 42;
    CI.Node := Result;
  end;
end;

function TdfPropertyTree.FindMethod(Id: Integer): TTreeNode;
var
  SQL: TIBSQL;
  TN, PTN: TTreeNode;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcReportGroup.ReadTransaction;
    SQL.SQL.Text :=
      'SELECT ' +
      '  o2.* ' +
      'FROM ' +
      '  evt_object o1, ' +
      '  evt_object o2, ' +
      '  evt_objectevent e ' +
      'WHERE ' +
      '  e.functionkey = :id AND ' +
      '  e.objectkey = o1.id AND ' +
      '  o1.lb >= o2.lb AND ' +
      '  o1.rb <= o2.rb ' +
      'ORDER BY ' +
      '  o2.lb';
    SQl.Params[0].AsInteger := ID;
    SQL.ExecQuery;
    if not SQl.Eof then
    begin
      //Получаем коренную папку
      if not Assigned(GetPageByObjID(OBJ_APPLICATION)) then
        Exit;
      PTN := GetPageByObjID(OBJ_APPLICATION).ClassesRootNode;
      Expand(PTN);
      while not SQL.Eof do
      begin
        //Попытка поиска нода в дереве
        TN := FindNode(SQL.FieldByName(fnId).AsInteger, PTN);
        { TODO : Добавление отфильтрованного касса }
        if not Assigned(TN) then
          TN := AddGDCClass(PTN, SQL.FieldByName(fnClassName).AsString,
            SQL.FieldByName(fnSubType).AsString);
        PTN := TN;
        if  Assigned(PTN) then
          Expand(PTN)
        else
          Exit;
        SQL.Next;
      end;
      if Assigned(PTN) then
      begin
        SQL.Close;
        SQL.SQL.Text := 'SELECT id, eventname FROM evt_objectevent WHERE functionkey = ' +
          IntToStr(Id);
        SQL.ExecQuery;
        Result := FindNode(SQL.Fields[0].AsInteger, PTN);
        if not Assigned(Result) then
          Result := AddMethod(SQL.Fields[1].AsString, PTN);
      end;
    end;
  finally
    SQL.Free;
  end;
end;

function TdfPropertyTree.FindNode(ID: Integer;
  AParent: TTreeNode): TTreeNode;
var
  N: TTreeNode;
begin
  Result := nil;
  if Assigned(AParent) then
  begin
    N := AParent.GetFirstChild;
    while (N <> nil) do
    begin
      if TCustomTreeItem(N.data).Id = Id then
      begin
        Result := N;
        Break;
      end;
      N := N.GetNextSibling;
    end;
  end;
end;

function TdfPropertyTree.AddGDCClass(AParent: TTreeNode;
  ClassName, SubType: string): TTreeNode;
var
//  Index: Integer;
  C: TClass;
  S: TStrings;
//  SubType: String;
  FullName: TgdcFullClassName;

{  function GetSubType(ClassName, FullName: string): string;
  var
    L: Integer;
    I: Integer;
  begin
    L := Length(ClassName);
    Result := Copy(FullName, L + 1, Length(FullName) - L);
    for I := 1 to Length(Result) do
      if Result[I] = '_' then Result[I] := '$';
  end;}

begin
  Result := nil;
  S := TStringList.Create;
  try
    FullName.gdClassName := ClassName;
    FullName.SubType := SubType;
    C := gdcClassList.GetGDCClass(FullName);
    if C <> nil then
    begin
      if SubType <> '' then
      begin
        CgdcBase(C).GetSubTypeList(S);
        Result := AddGDCClassNode(AParent, gdcClassList.IndexOf(C), SubType,
          S.Values[SubType])
      end else
        Result := AddGDCClassNode(AParent, gdcClassList.IndexOf(C), '', '');
      TCustomTreeFolder(Result.Data).ChildsCreated := True;
      AddMethods(Result, True);
    end else
    begin
      C := frmClassList.GetFrmClass(FullName);
      if C <> nil then
      begin
        if SubType <> '' then
        begin
          CgdcCreateableForm(C).GetSubTypeList(S);
          Result := AddFRMClassNode(AParent, frmClassList.IndexOf(C), SubType,
            S.Values[SubType])
        end else
          Result := AddFRMClassNode(AParent, frmClassList.IndexOf(C), '', '');
        TCustomTreeFolder(Result.Data).ChildsCreated := True;
        AddMethods(Result, False);
      end;
    end;
  finally
    S.Free;
  end;
end;

procedure TdfPropertyTree.InitOverloadAndDisable(C: TMethodClass);
var
  SQL: TIBSQL;
begin
  if C.Class_Key > 0 then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcDelphiObject.ReadTransaction;
      SQL.SQL.Text := 'SELECT COUNT(*) FROM evt_objectevent e, evt_object o1, ' +
        ' evt_object o2 WHERE e.objectkey = o2.id AND o1.lb <= o2.lb AND ' +
        ' o1.rb >= o2.rb AND o1.id = :id AND e.FunctionKey > 0';
      SQL.Params[0].AsInteger := C.Class_Key;
      SQL.ExecQuery;
      C.SpecMethodCount := SQL.Fields[0].AsInteger;
      SQL.Close;
      SQL.SQL.Text := 'SELECT COUNT(*) FROM evt_objectevent e, evt_object o1, ' +
        ' evt_object o2 WHERE e.objectkey = o2.id AND o1.lb <= o2.lb AND ' +
        ' o1.rb >= o2.rb AND o1.id = :id AND e.disable = 1';
      SQL.Params[0].AsInteger := C.Class_Key;
      SQL.ExecQuery;
      C.SpecDisableMethod := SQL.Fields[0].AsInteger;
    finally
      SQL.Free;
    end;
  end;
end;

function TdfPropertyTree.AddMethod(MethodName: string;
  const AParent: TTreeNode): TTreeNode;
var
  MClass: TMethodClass;
  TheMethod: TMethodItem;
begin
  Result := nil;
  if Assigned(AParent) and (TCustomTreeItem(AParent.Data).ItemType = tiGDCClass) then
  begin
    // Добавляем методы класса
    MClass := TGDCClassTreeItem(AParent.Data).TheClass;
    TheMethod := MClass.MethodList.Find(MethodName);
    if Assigned(TheMethod) then
      Result := AddMethodItem(TheMethod, AParent);
  end;
end;

procedure TdfPropertyTree.AddMethods(AParent: TTreeNode; IsGDC: Boolean);
var
  FltFlag: Boolean;
  TheMethod: TMethodItem;
  MClass: TgdcClassMethods;
  I, J: Integer;

  function AddM(M: TMethodItem; Parent: TTreeNode): TTreeNode;
  var
    FltFlag: Boolean;
  begin
    Result := nil;
    FltFlag := Filter(M.Name ,PropertySettings.Filter.MethodName,
      TFilterOptions(PropertySettings.Filter.foMethod));
    //Применяем фильтр
    if FltFlag and
      ((PropertySettings.Filter.OnlySpecEvent and (M.FunctionKey > 0)) or
      not PropertySettings.Filter.OnlySpecEvent) and
      ((PropertySettings.Filter.OnlyDisabled and M.Disable) or
      not PropertySettings.Filter.OnlyDisabled) then
      Result := AddMethodItem(M, Parent);
  end;
var
  P: TTreeNode;
begin
  if TCustomTreeItem(AParent.Data).ItemType = tiGDCClass then
  begin
    FltFlag := Filter(TGDCClassTreeItem(AParent.Data).Name +
      TGDCClassTreeItem(AParent.Data).SubType, PropertySettings.Filter.ClassName,
      TFilterOptions(PropertySettings.Filter.foClass));

    P := AParent;


    while TObject(P.Data) is TgdcClassTreeItem do
    begin
      // Добавляем методы класса
      if IsGDC then
        MClass := gdcClassList.gdcItems[TGDCClassTreeItem(P.Data).Index]
      else
        MClass := frmClassList.gdcItems[TGDCClassTreeItem(P.Data).Index];

      for I := 0 to MClass.gdcMethods.Count - 1 do
      begin
        //Ищем метод среди уже зарегестрированных в БД
        TheMethod := TGDCClassTreeItem(AParent.Data).TheClass.MethodList.Find(
          MClass.gdcMethods.Methods[I].Name);
        if TheMethod = nil then // if not exist in DB but registered
        begin
          j := TGDCClassTreeItem(AParent.Data).TheClass.MethodList.Add(
            MClass.gdcMethods.Methods[I].Name, 0, False,
            TGDCClassTreeItem(AParent.Data).TheClass);
          TheMethod := TGDCClassTreeItem(AParent.Data).TheClass.MethodList.Items[j];
  //        TheMethod.MethodClass := TGDCClassTreeItem(AParent.Data).TheClass;
        end;

        TheMethod.MethodData := @MClass.gdcMethods.Methods[I].ParamsData;
        if FltFlag then
          AddM(TheMethod, AParent);
      end;
      P := P.Parent;
    end;
{     // Adding inherited methods
    if TObject(AParent.Parent.Data) is TgdcClassTreeItem then
    begin
      MC := TGDCClassTreeItem(AParent.Parent.Data).TheClass;
      for I := 0 to MC.MethodList.Count - 1 do
      begin
        //Ищем метод среди уже зарегестрированных в БД
        TheMethod := TGDCClassTreeItem(AParent.Data).TheClass.MethodList.Find(
          MC.MethodList.Name[I]);
        if TheMethod = nil then // if not exist in DB but registered
        begin
          j := TGDCClassTreeItem(AParent.Data).TheClass.MethodList.Add(
            MC.MethodList.Name[I], 0, False,
            TGDCClassTreeItem(AParent.Data).TheClass);
          TheMethod := TGDCClassTreeItem(AParent.Data).TheClass.MethodList.Items[j];
//          TheMethod.MethodClass := TGDCClassTreeItem(AParent.Data).TheClass;
        end;

        TheMethod.MethodData := MC.MethodList.Items[I].MethodData;
        if FltFlag then
          AddM(TheMethod, AParent);
      end;
    end;}
  end;
end;

procedure TdfPropertyTree.UpdatePages;
var
  I: Integer;
  Index: Integer;
begin
  Index := IndexOfByObjId(OBJ_APPLICATION);
  if Index = -1 then
    AddApplicationPage;

  for I := 0 to Screen.FormCount - 1 do
  begin
   if Screen.Forms[I].InheritsFrom(TCreateableForm) then
     CheckFormPage(TCreateableForm(Screen.Forms[I]));
  end;
end;

function TdfPropertyTree.IndexOfByObjId(Id: Integer): Integer;
var
  I: Integer;
begin
  Result := - 1;
  for I := 0 to FPageControl.PageCount - 1 do
  begin
    if FPageControl.Pages[I].Tag = Id then
    begin
      Result := I;
//      if not TTreeTabSheet(FPageControl.Pages[I]).HandleAllocated then
//        TTreeTabSheet(FPageControl.Pages[I]).HandleNeeded;
      Exit;
    end;
  end;
end;

procedure TdfPropertyTree.AddApplicationPage;
var
  TS: TTreeTabSheet;
  SQL: TIBSQL;
begin
  TS := TTreeTabSheet.Create(Self);
  try
    TS.PageControl := FPageControl;
    TS.Caption := 'APPLICATION';
    TS.Tag := OBJ_APPLICATION;
    AppropriateHandlers(TS.Tree);
    TS.MacrosRootNode := LoadMacrosFolderByObject(nil, OBJ_APPLICATION, TS.Tree);

    TS.ReportRootNode := TS.Tree.Items.AddChild(nil, 'Отчеты');
    TS.ReportRootNode.Data := TReportTreeFolder.Create;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcMacrosGroup.ReadTransaction;
      SQL.SQl.Text := 'SELECT r.* FROM rp_reportgroup r WHERE r.parent is NULL AND '+
        'NOT EXISTS (SELECT o.* FROM evt_object o WHERE o.reportgroupkey = r.id or ' +
        'UPPER(o.objectname) = upper(r.usergroupname)) AND usergroupname containing cast(id as varchar(20))';
      SQL.ExecQuery;
      TS.ReportRootNode.HasChildren := not SQL.Eof;
    finally
      SQL.Free;
    end;
    TReportTreeFolder(TS.ReportRootNode.Data).Id := idAppReportRootFolder;
    TReportTreeFolder(TS.ReportRootNode.Data).OwnerId := OBJ_APPLICATION;
    TReportTreeFolder(TS.ReportRootNode.Data).MainOwnerName := 'APPLICATION';

    TS.GORootNode := TS.Tree.Items.AddChild(nil, 'Глобальные VB-объекты');
    TS.GORootNode.Data := TGlobalObjectTreeFolder.Create;
    RefreshGOTreeRoot(TS.GORootNode);

    TS.ConstRootNode := TS.Tree.Items.AddChild(nil, 'Константы и переменные');
    TS.ConstRootNode.Data := TConstTreeFolder.Create;
    RefreshConstTreeRoot(TS.ConstRootNode);

    TS.VBClassRootNode := TS.Tree.Items.AddChild(nil, 'VB классы');
    TS.VBClassRootNode.Data := TVBClassTreeFolder.Create;
    RefreshVBClassTreeRoot(TS.VBClassRootNode, OBJ_APPLICATION, 'APPLICATION');

    TS.ClassesRootNode := TS.Tree.Items.AddChild(nil, 'Методы');
    TS.ClassesRootNode.Data := TgdcClassTreeFolder.Create;
    TS.ClassesRootNode.HasChildren := (gdcClassList.Count > 0) or (frmClassList.Count > 0);

   {TS.PrologRootNode := TS.Tree.Items.AddChild(nil, 'Пролог-скрипты');
    TS.PrologRootNode.Data := TPrologTreeFolder.Create;
    TPrologTreeFolder(TS.PrologRootNode.Data).Id := idAppReportRootFolder;
    TPrologTreeFolder(TS.PrologRootNode.Data).OwnerId := OBJ_APPLICATION;
    TPrologTreeFolder(TS.PrologRootNode.Data).MainOwnerName := 'APPLICATION';

    TS.PrologRootNode.HasChildren := True;  }
    TS.PrologRootNode := AddPrologSFRootNode(OBJ_APPLICATION, 'APPLICATION', TS.Tree);

    TS.SFRootNode := AddSfRootNode(OBJ_APPLICATION, 'APPLICATION', TS.Tree);
    cbObjectList.Items.AddObject(TS.Caption, TObject(TApplication));
    SetObjectIndex;
  except
    TS.Free;
  end;
end;

{ TTreeTabSheet }

constructor TTreeTabSheet.Create(AOwner: TComponent);
begin
  inherited;
  FTree := TprpTreeView.Create(Self);
  FTree.RightClickSelect := False;
  FTree.Align := alClient;
  FTree.Parent := Self;
  FTRee.SortType := stData;
  FTRee.HideSelection := False;
end;

destructor TTreeTabSheet.Destroy;
begin
  if Parent <> nil then CheckHandle(Self);
  FTree.Free;
  if FMemoryStream <> nil then FMemoryStream.Free;
  inherited;
end;

procedure TdfPropertyTree.AppropriateHandlers(TV: TTreeView);
begin
  if Assigned(TV) then
    with TV do
    begin
      OnAdvancedCustomDrawItem := tvClassesAdvancedCustomDrawItem;
      OnCompare := tvClassesCompare;
      OnDblClick := tvClassesDblClick;
      OnDeletion := tvClassesDeletion;
      OnEdited := tvClassesEdited;
      OnEditing := tvClassesEditing;
      OnExpanding := tvClassesExpanding;
      OnGetImageIndex := tvClassesGetImageIndex;
      OnGetSelectedIndex := tvClassesGetSelectedIndex;
      OnChange := tvClassesChange;
      OnKeyDown := tvClassesKeyDown;
      Images := imTreeView;
      PopupMenu := pmTreeView;
      TV.DragMode := dmAutomatic;
    end;
end;

function TdfPropertyTree.AddMacrosFolderNode(Parent: TTreeNode;
  Id: Integer; Name: string; TV: TCustomTreeView): TTreeNode;
var
  F: TMacrosTreeFolder;
begin
  Result := TTreeView(TV).Items.AddChild(Parent, Name);
  F := TMacrosTreeFolder.Create;
  F.Id := Id;
  F.Name := Name;
  if Assigned(Parent) then
  begin
    F.Parent := TMacrosTreeFolder(Parent.Data);
    F.OwnerId := TMacrosTreeFolder(Parent.Data).OwnerID;
    F.MainOwnerName := TMacrosTreeFolder(Parent.Data).MainOwnerName;
  end;
  F.Node := Result;
  Result.Data := F;
end;

function TdfPropertyTree.GetSelectedNode: TTreeNode;
begin
  Result := nil;
  if Assigned(ActiveTree) then  Result := ActiveTree.Selected;
end;

function TdfPropertyTree.GetActiveTree: TTreeView;
begin
  Result := nil;
  if (FPageControl <> nil) and Assigned(FPageControl.ActivePage) then
    Result := TTreeTabSheet(FPageControl.ActivePage).Tree;
end;

function TdfPropertyTree.AddReportFolderNode(Parent: TTreeNode;
  Id: Integer; Name: string; TV: TCustomTreeView): TTreeNode;
var
  F: TReportTreeFolder;
begin
  Result := TTreeView(TV).Items.AddChild(Parent, Name);
  F := TReportTreeFolder.Create;
  F.Id := Id;
  F.Name := Name;
  if Assigned(Parent) then
  begin
    F.Parent := TReportTreeFolder(Parent.Data);
    F.OwnerId := TReportTreeFolder(Parent.Data).OwnerID;
    F.MainOwnerName := TReportTreeFolder(Parent.Data).MainOwnerName;
  end;
  F.Node := Result;
  Result.Data := F;
end;

function TdfPropertyTree.GetPageByObjID(Id: Integer): TTreeTabSheet;
var
  Index: Integer;
begin
  Result := nil;
  Index := IndexOfByObjId(Id);
  if Index > - 1 then
    Result := TTreeTabSheet(FPageControl.Pages[Index]);
end;

procedure TTreeTabSheet.SetConstRootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.ConstRootNode := Value;
end;

procedure TTreeTabSheet.SetObjectsRootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.ObjectsRootNode := Value;
end;

procedure TTreeTabSheet.SetGORootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.GORootNode := Value;
end;

procedure TTreeTabSheet.SetMacrosRootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.MacrosRootNode := Value;
end;

function TdfPropertyTree.FindMacros(Id: Integer): TTreeNode;
var
  SQL, oSQL: TIBSQL;
  TN, PTN: TTreeNode;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcReportGroup.ReadTransaction;
    SQL.SQL.Text :=
      'SELECT mg2.* FROM evt_macrosgroup mg1, evt_macrosgroup mg2, ' +
      '  evt_macroslist m WHERE m.functionkey = :id AND m.macrosgroupkey = mg1.id AND ' +
      '  mg1.lb >= mg2.lb AND mg1.rb <= mg2.rb ORDER BY mg2.lb';
    SQl.Params[0].AsInteger := ID;
    SQL.ExecQuery;
    if not SQl.Eof then
    begin
      { TODO : Тут немного не красиво т.к oSQL создается 2 раза }
      //получаем ид объекта которому принадлежит папка макросов
      oSQL := TIBSQL.Create(nil);
      try
        oSQL.Transaction := gdcDelphiObject.ReadTransaction;
        oSQL.SQL.Text := 'SELECT * FROM evt_object WHERE macrosgroupkey = ' +
          IntToStr(SQL.FieldByName(fnId).AsInteger);
        oSQL.ExecQuery;
        if not Assigned(GetPageByObjID(oSQL.FieldByName(fnId).AsInteger)) then
          Exit;
        PTN := GetPageByObjID(oSQL.FieldByName(fnId).AsInteger).MacrosRootNode;
      finally
        oSQL.Free;
      end;
      //Делаем видимым дерево
      PTN.TreeView.Show;
      Expand(PTN);
      SQL.Next;
      //Ищем по цепочке
      while not SQL.Eof do
      begin
        TN := FindNode(SQL.FieldByName(fnId).AsInteger, PTN);
        if not Assigned(TN) then
        begin
          if TCustomTreeItem(PTN.Data).Id = idMacrosRootFolder then
          begin
            oSQl := TIBSQL.Create(nil);
            try
              oSQL.Transaction := gdcMacrosGroup.ReadtRansaction;
              oSQL.SQL.Text := 'SELECT * FROM evt_object WHERE macrosgroupkey = ' +
                SQL.FieldByName(fnId).AsString;
              oSQL.ExecQuery;
              TN := LoadMacrosFolderByObject(PTN, oSQL.FieldByName(fnId).AsInteger, PTN.TreeView);
              TMacrosTreeFolder(Result.Data).OwnerId := oSQL.FieldByName('ownerid').AsInteger;
              TMacrosTreeFolder(Result.Data).MainOwnerName := oSQL.FieldByName('MainOwnerName').AsString;
            finally
              oSQl.Free;
            end;
          end else
            Exit;
        end;
        PTN := TN;
        if Assigned(PTN) then
          PTN.Expanded := True
        else
          Exit;
        SQL.Next;
      end;
      if Assigned(PTN) then
      begin
        //Ищем нод макроса
        SQL.Close;
        SQL.SQL.Text := 'SELECT id FROM evt_macroslist WHERE functionkey = ' +
          IntToStr(Id);
        SQL.ExecQuery;
        Result := FindNode(SQL.Fields[0].AsInteger, PTN);
      end;
    end;
  finally
    SQL.Free;
  end;
end;

function TdfPropertyTree.AddFormPage(F: TCreateableForm): TTreeTabSheet;
var
  TS: TTreeTabSheet;
  B: Boolean;
begin
  Result := nil;
  TS := TTreeTabSheet.Create(Self);
  try
    TS.PageControl := FPageControl;
    TS.Caption := F.InitialName;
    TS.Tag := gdcDelphiObject.AddObject(F);
    AppropriateHandlers(TS.Tree);
    TS.MacrosRootNode := LoadMacrosFolderByObject(nil, TS.Tag, TS.Tree);
    TS.ReportRootNode := TS.Tree.Items.AddChild(nil, 'Отчеты формы');
    TS.ReportRootNode.Data := TReportTreeFolder.Create;
    TReportTreeFolder(TS.ReportRootNode.Data).OwnerId := TS.Tag;
    TReportTreeFolder(TS.ReportRootNode.Data).MainOwnerName := F.Name;
    TReportTreeFolder(TS.ReportRootNode.Data).Id := CheckCreateLocalReportFolder(TS.Tag, F.InitialName);
    if Assigned(TS.ReportRootNode) then
      TS.ReportRootNode.HasChildren := GetReportFolderChildrenCount(TReportTreeFolder(TS.ReportRootNode.Data).Id) > 0;

    if F is TgdcCreateableForm then
    begin
      //а gdcObject может оказывается бить равным нил
      if Assigned(TgdcCreateableForm(F).gdcObject) then
      begin
        TS.gdcReportRootNode := TS.Tree.Items.AddChild(nil, Format('Отчеты %s',
          [TgdcCreateableForm(F).gdcObject.ClassName + TgdcCreateableForm(F).gdcObject.SubType]));
        TS.gdcReportRootNode.Data := TReportTreeFolder.Create;
        TReportTreeFolder(TS.gdcReportRootNode.Data).OwnerId := OBJ_APPLICATION;
        TReportTreeFolder(TS.gdcReportRootNode.Data).MainOwnerName := 'APPLICATION';

        B := TgdcCreateableForm(F).gdcObject.UseScriptMethod;
        if B then TgdcCreateableForm(F).gdcObject.UseScriptMethod := False;
        try
          TReportTreeFolder(TS.gdcReportRootNode.Data).Id := TgdcCreateableForm(F).gdcObject.GroupID;
          CheckCreateGDCReportFolder(TReportTreeFolder(TS.gdcReportRootNode.Data).Id,
            TgdcCreateableForm(F).gdcObject);
          TS.gdcReportRootNode.HasChildren := GetReportFolderChildrenCount(TReportTreeFolder(TS.gdcReportRootNode.Data).Id) > 0;
        finally
          TgdcCreateableForm(F).gdcObject.UseScriptMethod := B;
        end;
      end;
    end; 

    TS.VBClassRootNode := TS.Tree.Items.AddChild(nil, 'VB классы');
    TS.VBClassRootNode.Data := TVBClassTreeFolder.Create;
    RefreshVBClassTreeRoot(TS.VBClassRootNode, TS.Tag, InitialName);

    TS.ObjectsRootNode := AddFormNode(F, TS.Tag, TS.Tree);

    TS.SFRootNode := AddSfRootNode(TS.Tag, F.InitialName,TS.Tree);
    Result := TS;
    cbObjectList.Items.AddObject(TS.Caption, TObject(F.ClassType));
    SetObjectIndex;
  except
    TS.Free;
  end;
end;

procedure TdfPropertyTree.AddLocalMacrosFolder(Id: Integer);
begin
  if Id > 0 then
  begin
    gdcDelphiObject.Close;
    gdcDelphiObject.ID := id;
    gdcDelphiObject.Open;
    try
      if not gdcDelphiObject.IsEmpty then
      begin
        gdcMacrosGroup.Open;
        try
          gdcMacrosGroup.Insert;
          if Id <> OBJ_APPLICATION then
            gdcMacrosGroup.FieldByName(fnName).AsString := 'Локальные макросы'
          else
            gdcMacrosGroup.FieldByName(fnName).AsString := 'Глобальные макросы';
          gdcMacrosGroup.FieldByName(fnIsGlobal).AsInteger :=
            Integer(Id = OBJ_APPLICATION);
          gdcMacrosGroup.Post;
          gdcDelphiObject.Edit;
          gdcDelphiObject.FieldByName(fnMacrosGroupKey).AsInteger :=
            gdcMacrosGroup.FieldByName(fnId).AsInteger;
          gdcDelphiObject.Post;  
        finally
          gdcMacrosGroup.Close;
        end;
      end else
        raise Exception.Create(Format('Не найден объект с id = %d', [id]));
    finally
      gdcDelphiObject.Close;
    end;
  end;
end;

procedure TTreeTabSheet.SetClassesRootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.ClassesRootNode := Value;
end;

procedure TTreeTabSheet.SetReportRootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.ReportRootNode := Value;
end;

procedure TTreeTabSheet.SetSFRootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.SFRootNode := Value;
end;

procedure TTreeTabSheet.SetVBClassRootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.VBClassRootNode := Value;
end;

function TdfPropertyTree.GetActivePage: TTreeTabSheet;
begin
  Result := TTreeTabSheet(FPageControl.ActivePage)
end;

procedure TdfPropertyTree.AddObjects(Parent: TTreeNode;
  C: TComponent);
var
  I: Integer;
  TN: TTreeNode;
  FltFlag: Boolean;

  function ObjectFilter(C: TComponent): Boolean;
  var
    I: Integer;
  begin
    if C is TCreateableForm then
      Result := Filter(TCreateableForm(C).InitialName, PropertySettings.Filter.ObjectName,
        TFilterOptions(PropertySettings.Filter.foObject))
    else
      Result := Filter(C.Name, PropertySettings.Filter.ObjectName,
        TFilterOptions(PropertySettings.Filter.foObject));

    if not Result then
    begin
      for I := 0 to C.ComponentCount - 1 do
      begin
        Result := ObjectFilter(C.Components[I]);
        if Result then Exit;
      end;
    end;
  end;

begin
  if not Assigned(C) or (C.Name = '') then
    Exit;

  TCustomTreeFolder(Parent.Data).ChildsCreated := True;
  for I := 0 to C.ComponentCount - 1 do
  begin
    if (C.Components[I] is TForm) or (C.Components[I].Name = '') or
      (C.Components[I] is TgsComponentEmulator) then Continue;
    FltFlag := ObjectFilter(C.Components[I]);
    if FltFlag then
    begin
      TN := AddObjectNode(Parent, C.Components[I].Name, C.Components[I].ClassName);

      AddObjects(TN, C.Components[I]);
    end;
  end;
  // Если у объекта нет зарегистрированых событий и
  // нет дочерних компонент с событиями то удаляем его
  for I := Parent.Count - 1 downto 0 do
  begin
    if Parent[I].Count = 0 then
      Parent[I].Delete;
  end;
  // Добавляем события в дерево
  FillEvents(C, Parent);
end;

function TdfPropertyTree.AddFormNode(F: TForm; id: Integer; TV: TCustomTreeView): TTreeNode;
var
  ObjectTreeItem: TFormTreeItem;
  EO: TEventObject;
  I: Integer;
begin
  Result := nil;
  if not Assigned(F) then Exit;

  // Добавляем объект в дерево
  Result := TTreeView(TV).Items.AddChild(nil, 'События');
  Result.ImageIndex := 8;
  Result.SelectedIndex := 9;

  ObjectTreeItem := TFormTreeItem.Create;
  if F is TCreateableForm then
  begin
    ObjectTreeItem.Name := TCreateableForm(F).InitialName;
    ObjectTreeItem.EventObject :=
      GetEventControl.EventObjectList.FindObject(TCreateableForm(F).InitialName);
  end else
  begin
    ObjectTreeItem.Name := F.Name;
    ObjectTreeItem.EventObject :=
      GetEventControl.EventObjectList.FindObject(F.Name);
  end;
  //Присваеваем значение имени формы владельца
  ObjectTreeItem.Parent := nil;
  ObjectTreeItem.ID := ID;
  ObjectTreeItem.OwnerId := ID;
  ObjectTreeItem.MainOwnerName := ObjectTreeItem.Name;

  // Создаем если не нашли
  if not Assigned(ObjectTreeItem.EventObject) then
  begin
    EO := TEventObject.Create;
    try
      if F is TCreateableForm then
        EO.ObjectName := TCreateableForm(F).InitialName
      else
        EO.ObjectName := F.Name;
      I := GetEventControl.EventObjectList.AddObject(EO);
      ObjectTreeItem.EventObject := GetEventControl.EventObjectList.EventObject[I];
    finally
      EO.Free;
    end;
  end;

  Result.Data := ObjectTreeItem;
  ObjectTreeItem.Node := Result;
  Result.HasChildren := True;
end;

procedure TdfPropertyTree.CheckFullEvents(Node: TTreeNode);
var
  F: TForm;
  C: TCursor;
begin
  if not TCustomTreeFolder(Node.Data).ChildsCreated then
  begin
    F := GetForm(TCustomTreeFolder(Node.Data).Name);
    if Assigned(F) then
    begin
      C := Screen.Cursor;
      Screen.Cursor := crHourGlass;
      try
        AddObjects(Node, F)
      finally
        Screen.Cursor := C;
      end;
    end else
      MessageBox(Application.Handle, PChar(Format(
        'В системе не найдена форма %s'#13#10 +
        'Пожалуйста откройте форму и повторите свои дейтвия',
        [TCustomTreeFolder(Node.Data).Name])), MSG_WARNING, MB_OK or MB_TASKMODAL);
  end;
end;

function TdfPropertyTree.GetForm(Name: string): TCreateableForm;
var
  I: Integer;
  TmpName: string;
begin
  Result := nil;
  TmpName := UpperCase(Name);
  for I := 0 to Screen.FormCount -1 do
  begin
    if Screen.Forms[I] is TCreateableForm then
    begin
      if UpperCase(TCreateableForm(Screen.Forms[I]).InitialName) = TmpName then
      begin
        Result := TCreateableForm(Screen.Forms[I]);
        Exit;
      end
    end{ else
    if UpperCase(Screen.Forms[I].Name) = TmpName then
    begin
      Result := Screen.Forms[I];
      Exit;
    end;}
  end;
end;

function TdfPropertyTree.FindEvent(Id: Integer): TTreeNode;
var
  SQL: TIBSQL;
  TN, PTN: TTreeNode;
  F: TCreateableForm;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcReportGroup.ReadTransaction;
    SQL.SQL.Text :=
      'SELECT ' +
      '  o2.* ' +
      'FROM ' +
      '  evt_object o1, ' +
      '  evt_object o2, ' +
      '  evt_objectevent e ' +
      'WHERE ' +
      '  e.functionkey = :id AND ' +
      '  e.objectkey = o1.id AND ' +
      '  o1.lb >= o2.lb AND ' +
      '  o1.rb <= o2.rb ' +
      'ORDER BY ' +
      '  o2.lb';
    SQl.Params[0].AsInteger := ID;
    SQL.ExecQuery;
    if not SQl.Eof then
    begin
      //Получаем коренную папку
      if not Assigned(GetPageByObjID(SQL.FieldByName(fnId).AsInteger)) then
      begin
        //Если страница не найдена то пытаемся создать
        F := GetForm(SQL.FieldByName(fnName).AsString);
        if Assigned(F) then AddFormPage(F) else Exit;
      end;
      if GetPageByObjID(SQL.FieldByName(fnId).AsInteger) <> nil then
        PTN := GetPageByObjID(SQL.FieldByName(fnId).AsInteger).ObjectsRootNode
      else
        Exit;
        
      //Создаем дерево
      CheckFullEvents(PTN);
      SQL.Next;
      while not SQL.Eof do
      begin
        //Попытка поиска нода в дереве
        TN := FindNode(SQL.FieldByName(fnId).AsInteger, PTN);
        { TODO : Добавление отфильтрованного касса }
        if not Assigned(TN) then Exit;
        PTN := TN;
        if  Assigned(PTN) then
          Expand(PTN)
        else
          Exit;
        SQL.Next;
      end;
      if Assigned(PTN) then
      begin
        SQL.Close;
        SQL.SQL.Text := 'SELECT id, eventname FROM evt_objectevent WHERE functionkey = ' +
          IntToStr(Id);
        SQL.ExecQuery;
        Result := FindNode(SQL.Fields[0].AsInteger, PTN);
      end;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdfPropertyTree.LoadAppReportRootNode(Parent: TTreeNode);
var
  SQL: TIBSQL;
  TN: TTreeNode;
begin
  TCustomTreeFolder(Parent.Data).ChildsCreated := True;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcMacrosGroup.ReadTransaction;
    SQL.SQl.Text := ' SELECT r.*, o.Id as OwnerId, o.ObjectName as MainOwnerName FROM ' +
      ' rp_reportgroup r LEFT JOIN evt_object o ON o.reportgroupkey = r.id WHERE ' +
      ' r.parent is NULL' ;
    SQL.ExecQuery;
    while not SQL.Eof do
    begin
      TN := AddReportFolderNode(Parent, SQL.FieldByName(fnId).AsInteger,
        SQL.FieldByName(fnName).AsString);

      if SQL.FieldByName('ownerid').IsNull then
      begin
        TReportTreeFolder(TN.Data).OwnerId := OBJ_APPLICATION;
        TReportTreeFolder(TN.Data).MainOwnerName := 'APPLICATION';
      end else
      begin
        TReportTreeFolder(TN.Data).OwnerId := SQL.FieldByName('ownerid').AsInteger;
        TReportTreeFolder(TN.Data).MainOwnerName := SQL.FieldByName('mainownername').AsString;
      end;
      TN.HasChildren := GetReportFolderChildrenCount(SQL.FieldByName(fnId).AsInteger) > 0;
      TCustomTreeFolder(TN.Data).ChildsCreated := not TN.HasChildren;
      SQL.Next;
    end;
  finally
    SQL.Free;
  end;
end;

function TdfPropertyTree.GetReportFolderChildrenCount(
  Id: Integer): Integer;
{
var
 oSQl: TIBSQL;
} 
begin
  Result := 1;

  {
  oSQL := TIBSQL.Create(nil);
  try
    oSQL.Transaction := gdcMacrosGroup.ReadTransaction;
    oSQL.SQl.Text := Format('SELECT Count(*) FROM rdb$database WHERE ' +
      ' EXISTS (SELECT 1 FROM rp_reportgroup WHERE parent = :id) or ' +
      ' EXISTS (SELECT 1 FROM rp_reportlist WHERE reportgroupkey = :id AND ' +
      ' g_sec_test(aview, %d) <> 0)', [IBLogin.InGroup]);
    oSQL.Params[0].AsInteger := ID;
    oSQL.ExecQuery;
    Result := oSQl.Fields[0].AsInteger;
  finally
    oSQL.Free
  end;
  }

end;

function TdfPropertyTree.CheckCreateLocalReportFolder(
  Id: Integer; Name: string): Integer;
var
  SQl: TIBSQL;
  N: string;
  I: Integer;
begin
  Result := 0;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcReportGroup.ReadTransaction;
    SQL.SQL.Text := 'SELECT r.* FROM evt_object o JOIN rp_reportgroup r ON o.reportgroupkey = r.id WHERE o.Id = :id';
    SQL.Params[0].AsInteger := Id;
    SQL.ExecQuery;
    if SQL.Eof then
    begin
      gdcReportGroup.Open;
      try
        gdcReportGroup.Insert;

        SQL.SQL.Text := 'SELECT id FROM rp_reportgroup WHERE name = :name AND parent IS NULL';
        N := 'Отчеты(' + Name + ')';
        I := 1;

        repeat
          SQL.Close;

          if Length(N) > gdcReportGroup.FieldByName(fnName).Size then
            N := System.Copy(N, 1, gdcReportGroup.FieldByName(fnName).Size);

          SQL.ParamByName('name').AsString := N;
          SQL.ExecQuery;
          if not SQL.EOF then
          begin
            N := 'Отчеты(' + Name + '_'+ IntToStr(I) + ')';
            Inc(i)
          end else
          begin
            gdcReportGroup.FieldByName(fnName).AsString := N;
          end;
        until SQL.RecordCount = 0;

        gdcReportGroup.FieldByName(fnUserGroupName).AsString := IntToStr(gdcReportGroup.ID) +
          '_' + IntToStr(GetDBID);
        gdcReportGroup.Post;
        gdcDelphiObject.ID := ID;
        gdcDelphiObject.Open;
        try
          if not gdcDelphiObject.IsEmpty then
          begin
            gdcDelphiObject.Edit;
            gdcDelphiObject.FieldByName(fnReportGroupKey).AsInteger :=
              gdcReportGroup.FieldByName(fnId).AsInteger;
            gdcDelphiObject.Post;
          end else
            raise Exception.Create(Format('Не найдем объект с id = %d',[ID]));
        finally
          gdcDelphiObject.Close;
        end;
        Result := gdcReportGroup.FieldByName(fnId).AsInteger;
      finally
        gdcReportGroup.Close;
      end;
    end else
      Result := SQL.FieldByName(fnId).AsInteger;
  finally
    SQL.Free;
  end;
end;

function TdfPropertyTree.FindReportFunction(Id: Integer): TTreeNode;
var
  SQL: TIBSQL;
begin
//  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcReportGroup.ReadTransaction;
    SQL.SQL.Text :=
      'SELECT r.* FROM rp_reportlist r WHERE (r.mainformulakey = :id OR ' +
      '  r.paramformulakey = :id OR r.eventformulakey = :id )';
    SQL.ParamByName('id').ASInteger := ID;
    SQL.ExecQuery;
    Result := FindReport(SQL.FieldByName(fnId).AsInteger);
  finally
    SQL.Free;
  end;
end;

function TdfPropertyTree.AddSfRootNode(Id: Integer; OwnerName: string; TV: TTReeView): TTreeNode;
var
  SFI: TSFTreeFolder;
  SQL: TIBSQl;
  WhereClause: String;
begin
  Result := TV.Items.AddChild(nil, 'Скрипт-функции');
  SFI := TSFTreeFolder.Create;
  SFI.ID := idSFFoulder;
  SFI.OwnerID := ID;
  SFI.MainOwnerName := OwnerName;
  Result.Data := SFI;
  SFI.Node := Result;
  WhereClause := GetSFWhereClause(ID);
  if WhereClause > '' then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcDelphiObject.ReadTransaction;
      SQL.SQL.Text :=
        'SELECT g.id FROM gd_function g ' +
        ' JOIN evt_object o2 ON g.modulecode = o2.id ' +
        ' JOIN evt_object o1 ON o1.lb >= o2.lb AND o1.rb <= o2.rb WHERE ' +
        WhereClause;
      SQL.Params[0].AsInteger := Id;
      SQL.ExecQuery;
      Result.HasChildren := not SQL.Eof;
    finally
      SQL.Free;
    end;
  end else
    Result.HasChildren := False;
end;

procedure TdfPropertyTree.LoadPrologSF(Node: TTreeNode);
var
  SQL: TIBSQL;
  S: TSortType;
begin
  S := TTreeView(Node.TreeView).SortType;
  TTreeView(Node.TreeView).SortType := stNone;
  try
    TCustomTreeFolder(Node.Data).ChildsCreated := True;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcDelphiObject.ReadTransaction;
      SQL.SQL.Text := 'SELECT g.* FROM ' +
        '  gd_function g '#13#10 +
        '  JOIN evt_object o2 on g.modulecode = o2.id '#13#10 +
        '  JOIN evt_object o1 on o1.lb <= o2.lb AND '#13#10 +
        '    o1.rb >= o2.rb AND o1.parent IS Null '#13#10 +
        '  WHERE o2.id = :id AND g.module = :m';

      SQL.ParamByName('id').AsInteger := TCustomTreeFolder(Node.Data).OwnerId;
      SQL.ParamByName('m').AsString := scrPrologModuleName;
      SQL.ExecQuery;
      while not SQL.Eof do
      begin
        AddPSFNode(Node, SQL.FieldByname(fnId).AsInteger, SQL.FieldByName(fnName).AsString);
        SQL.Next;
      end; 
    finally
      Node.HasChildren := Node.Count > 0;
      SQL.Free;
    end;
  finally
    TTreeView(Node.TreeView).SortType := S;
  end;
end;

function TdfPropertyTree.AddPrologSFRootNode(Id: Integer; OwnerName: string; TV: TTReeView): TTreeNode;
var
  PSFI: TPrologTreeFolder;
  SQL: TIBSQL;
begin
  Result := TV.Items.AddChild(nil, 'Пролог-скрипты');
  PSFI := TPrologTreeFolder.Create;
  PSFI.ID := idPrologSFFolder;
  PSFI.OwnerID := ID;
  PSFI.MainOwnerName := OwnerName;
  Result.Data := PSFI;
  PSFI.Node := Result;

  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcDelphiObject.ReadTransaction;
    SQL.SQL.Text :=
      'SELECT g.id FROM gd_function g ' +
      ' JOIN evt_object o2 ON g.modulecode = o2.id ' +
      ' JOIN evt_object o1 ON o1.lb >= o2.lb AND o1.rb <= o2.rb ' +
      'WHERE o2.id = :id AND module = :module';

    SQL.ParamByName('id').AsInteger := Id;
    SQL.ParamByName('module').AsString := scrPrologModuleName;
    SQL.ExecQuery;
    Result.HasChildren := not SQL.Eof;
  finally
    SQL.Free;
  end;  
end;

procedure TdfPropertyTree.LoadSf(Node: TTreeNode);
var
  SQL: TIBSQL;
  TN: TTreeNode;
  WhereClause: String;
  S: TSortType;
begin
  S := TTreeView(Node.TreeView).SortType;
  TTreeView(Node.TreeView).SortType := stNone;
  try
    TCustomTreeFolder(Node.Data).ChildsCreated := True;
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcDelphiObject.ReadTransaction;
      WhereClause := GetSFWhereClause(TCustomTreeFolder(Node.Data).OwnerId);
      if WhereClause <> '' then
      begin
        SQL.SQL.Text := 'SELECT g.* FROM ' +
          '  gd_function g '#13#10 +
          '  JOIN evt_object o2 on g.modulecode = o2.id '#13#10 +
          '  JOIN evt_object o1 on o1.lb <= o2.lb AND '#13#10 +
          '    o1.rb >= o2.rb AND o1.parent Is Null '#13#10 +
          '  WHERE ' +
          WhereClause + ' ORDER BY g.Module';
        SQL.Params[0].AsInteger := TCustomTreeFolder(Node.Data).OwnerId;
        SQL.ExecQuery;
        while not SQL.Eof do
        begin
          TN := AddSFNode(Node, SQL.FieldByname(fnId).AsInteger, SQL.FieldByName(fnName).AsString);
          TSFTreeItem(TN.Data).SFType := GetSFType(SQL.FieldByName(fnModule).AsString);
          SQL.Next;
        end;
      end;
    finally
      Node.HasChildren := Node.Count > 0;
      SQL.Free;
    end;
  finally
    TTreeView(Node.TreeView).SortType := S;
  end;
end;

function TdfPropertyTree.AddSFNode(Parent: TTreeNode; id: Integer;
  Name: string): TTreeNode;
var
  SI: TSFTreeItem;
begin
  Result := TTreeView(Parent.TreeView).Items.Addchild(Parent, Name);
  SI := TSFTreeItem.Create;
  SI.Id := Id;
  SI.Name := Name;
  SI.OwnerId := TCustomTreeFolder(Parent.Data).OwnerId;
  SI.Node := Result;
  SI.MainOwnerName := TCustomTreeFolder(Parent.Data).MainOwnerName;
  Result.Data := SI;
end;

function TdfPropertyTree.AddSFItem: TCustomTreeItem;
var
  TN: TTreeNode;
  VBI: TSFTreeItem;
begin
  Result := nil;
  if Assigned(ActivePage) and
    Assigned(ActivePage.SFRootNode) then
  begin
    CheckLoadSf(ActivePage.SFRootNode);
    TN := AddSFNode(ActivePage.SFRootNode, 0,
      {gdcFunction.GetUniqueName(}NEW_SCRIPTFUNCTION{, '', ActivePage.Tag)});
    VBI := TSFTreeItem(TN.Data);
    VBI.SFType := sfUnknown;
    TN.Selected := True;
    tvClassesDblClick(ActiveTree);
    try
      TBaseFrame(VBI.EditorFrame).Post;
      Result := VBI;
    except
      if VBI.EditorFrame <> nil then
        VBI.EditorFrame.Free;
      TN.Delete;
    end;
  end;
end;

procedure TdfPropertyTree.CheckLoadSf(TN: TTreeNode);
begin
  if not TCustomTreeFolder(TN.Data).ChildsCreated then
    LoadSf(TN);
end;

procedure TdfPropertyTree.CheckLoadPrologSF(TN: TTreeNode);
begin
  if not TCustomTreeFolder(TN.Data).ChildsCreated then
    LoadPrologSF(TN);
end;

function TdfPropertyTree.AddPSFNode(Parent: TTreeNode; id: Integer; Name: string): TTreeNode;
var
  PI: TPrologTreeItem;
begin
  Result := TTreeView(Parent.TreeView).Items.Addchild(Parent, Name);
  PI := TPrologTreeItem.Create;
  PI.Id := Id;
  PI.Name := Name;
  PI.OwnerId := TCustomTreeFolder(Parent.Data).OwnerId;
  PI.Node := Result;
  PI.MainOwnerName := TCustomTreeFolder(Parent.Data).MainOwnerName;
  Result.Data := PI;
end;

function TdfPropertyTree.AddPSFItem: TCustomTreeItem;
var
  TN: TTreeNode;
  VBI: TPrologTreeItem;
begin
  Result := nil;
  if Assigned(ActivePage) and
    Assigned(ActivePage.PrologRootNode) then
  begin
    TN := AddPSFNode(ActivePage.PrologRootNode, 0,
      {gdcFunction.GetUniqueName(}NEW_PROLOG{, '', ActivePage.Tag)});
    VBI := TPrologTreeItem(TN.Data);
    TN.Selected := True;
    tvClassesDblClick(ActiveTree);
    try
      TBaseFrame(VBI.EditorFrame).Post;
      Result := VBI;
    except
      if VBI.EditorFrame <> nil then
        VBI.EditorFrame.Free;
      TN.Delete;
    end;
  end;  
end;

procedure TdfPropertyTree.CheckLoadReportFolder(Node: TTreeNode);
begin
  if not TCustomTreeFolder(Node.Data).ChildsCreated then
  begin
    if TCustomTreeFolder(Node.Data).Id = idAppReportRootFolder then
      LoadAppReportRootNode(Node)
    else
      LoadReportFolder(Node, TCustomTreeItem(Node.Data).Id);
  end;
end;

function TdfPropertyTree.FindVBClass(Id: Integer): TTreeNode;
var
  J: Integer;
  TN: TTreeNode;
  TS: TTreeTabSheet;
begin
  Result := nil;
  for J := 0 to FPageControl.PageCount - 1 do
  begin
    TS := TTreeTabSheet(FPageControl.Pages[J]);
    if TS.VBClassRootNode <> nil then
    begin
      TN := TS.VBClassRootNode.GetFirstChild;
      while (TN <> nil) do
      begin
        if TVBClassTreeItem(TN.Data).Id = Id then
        begin
          Result := TN;
          Exit;
        end;
        TN := TN.GetNextSibling;
      end;
    end
  end;
end;

function TdfPropertyTree.FindConst(Id: Integer): TTreeNode;
var
  TN: TTreeNode;
  TS: TTreeTabSheet;
begin
  Result := nil;
  TS := GetPageByObjID(OBJ_APPLICATION);
  if Assigned(TS) and Assigned(TS.ConstRootNode) then
  begin
    TN := TS.ConstRootNode.GetFirstChild;
    while (TN <> nil) do
    begin
      if TConstTreeItem(TN.Data).Id = Id then
      begin
        Result := TN;
        Exit;
      end;
      TN := TN.GetNextSibling;
    end;
  end
end;

function TdfPropertyTree.FindGO(ID: Integer): TTreeNode;
var
  TN: TTreeNode;
  TS: TTreeTabSheet;
begin
  Result := nil;
  TS := GetPageByObjID(OBJ_APPLICATION);
  if Assigned(TS) and Assigned(TS.GORootNode) then
  begin
    TN := TS.GORootNode.GetFirstChild;
    while (TN <> nil) do
    begin
      if TGLobalObjectTreeItem(TN.Data).Id = Id then
      begin
        Result := TN;
        Exit;
      end;
      TN := TN.GetNextSibling;
    end;
  end
end;

procedure TdfPropertyTree.FunctionNotFound(ID: Integer);
begin
  raise Exception.Create(Format('Функция с id = %d в базе не найдена', [ID]));
end;

function TdfPropertyTree.GetSFType(Module: string): sfTypes;
begin
  Result := sfUnknown;
  if Module = scrMacrosModuleName then
    Result := sfMacros
  else
  if (Module = MainModuleName) or (Module = ParamModuleName) or
    (Module = EventModuleName) then
    Result := sfReport
  else
  if Module = scrEventModuleName then
    Result := sfEvent
  else
  if Module = scrMethodModuleName then
    Result := sfMethod;
end;

procedure TdfPropertyTree.RefreshSf;
var
  I: Integer;
begin
  CheckHandle(Self);
  for I := 0 to FPageControl.PageCount - 1 do
  begin
    if Assigned(TTreeTabsheet(FPageControl.Pages[I]).SFRootNode) then
    begin
      if TTreeTabsheet(FPageControl.Pages[i]).SFRootNode.Count > 0 then
        TTreeTabsheet(FPageControl.Pages[i]).SFRootNode.DeleteChildren;
      TTreeTabsheet(FPageControl.Pages[i]).SFRootNode.HasChildren := True;
      TCustomTreeFolder(TTreeTabsheet(FPageControl.Pages[i]).SFRootNode.Data).ChildsCreated := False;
    end
  end;
end;

procedure TdfPropertyTree.RefreshObjects;
var
  I: Integer;
  TS: TTreeTabSheet;
begin
  CheckHandle(Self);
  //Пояснения см. actRefreshTreeExecute
  SetFocusedControl(cbObjectList);
  for I := FPageControl.PageCount - 1 downto 0 do
  begin
    if TTreeTabSheet(FPageControl.Pages[I]).Tag <> OBJ_APPLICATION then
    begin
      TS := TTreeTabSheet(FPageControl.Pages[I]);
      TS.ObjectsRootNode.DeleteChildren;
      TS.ObjectsRootNode.HasChildren := True;
      TCustomTreeFolder(TS.ObjectsRootNode.Data).ChildsCreated := False;
//      cbObjectList.Items.Delete(I);
    end;
  end;
  UpdatePages;
end;

procedure TdfPropertyTree.RefreshClasses;
var
  TS: TTreeTabSheet;
begin
  CheckHandle(Self);
  TS := GetPageByObjID(OBJ_APPLICATION);
  if Assigned(TS) then
  begin
    if Assigned(TS.ClassesRootNode) then
    begin
      if TS.ClassesRootNode.Count > 0 then
        TS.ClassesRootNode.DeleteChildren;
      TS.ClassesRootNode.HasChildren := True;
      TCustomTreeFolder(TS.ClassesRootNode.Data).ChildsCreated := False;
    end;
  end;
end;

function TdfPropertyTree.GetSFWhereClause(const AnID: Integer): String;
var
  S: string;
//  b: boolean;
begin
  S := '';
  Result := '';
  with PropertySettings.ViewSet.SFSet do
  begin
    if ShowVBClassSF then
      S := S + '''' + scrVBClasses + ''',';
    if ShowMacrosSF then
      S := S + '''' + scrMacrosModuleName + ''',';
    if ShowReportSF then
      S := S + '''' + MainModuleName + ''',''' +
        ParamModuleName + ''',''' + EventModuleName + ''',';
    if ShowEventSF then
      S := S + '''' + scrEventModuleName + ''',';
    if S <> '' then
    begin
      SetLength(S, Length(S) - 1);
      Result := '(g.module IN (' + S + '))';
    end;

    if ShowUserSF then
    begin
      if Result > '' then Result := Result + ' OR ';
      Result := Result + ' (NOT (g.module IN ('''+ scrVBClasses +
        ''', ''' + scrMacrosModuleName +  ''', ''' + MainModuleName + ''',''' +
        ParamModuleName + ''',''' + EventModuleName + ''', ''' +scrEventModuleName +
        ''', ''' + scrMethodModuleName + ''', ''' + scrEntryModuleName + ''', ''' + scrPrologModuleName + ''')))'
    end;

    if Result > '' then
    begin
      Result := '((o2.id = :id) AND (' + Result + '))';
    end;

    if AnID = 1010001 then
    begin
      S := '';
      if ShowMethodSF then
        S := S + '''' + scrMethodModuleName + ''',';
      if ShowEntrySF then
        S := S + '''' + scrEntryModuleName + ''',';
      if S > '' then
      begin
        SetLength(S, Length(S) - 1);
        if Result > '' then
          Result := Result + ' OR ';
        Result := Result + '(g.module in ( ' + S + '))';
      end;
    end;

  end;
end;

function TdfPropertyTree.CheckFormPage(F: TCreateableForm): TTreeTabSheet;
var
  ObjId, Index: Integer;
begin
  Result := nil;
  if Assigned(F) then
  begin
    //!!! По моему это сдесь не нужно 21.05.2003
    if {(UpperCase(F.ClassName) <> 'TDLGVIEWPROPERTY') and
      (UpperCase(F.ClassName) <> 'TGSCOMPONENTEMULATOR') and}
      not (F is TfrmGedeminProperty) and not (F is TDockableForm) and
      F.UseDesigner then
      begin
       ObjId := gdcDelphiObject.AddObject(F);
       Index := IndexOfByObjId(ObjId);
       if Index = - 1 then
         Result := AddFormPage(F)
       else
         Result := TTreeTabSheet(FPageControl.Pages[Index]);
      end;
  end;
end;

procedure TdfPropertyTree.OpenEvent(Component: TComponent;
  EventName: string; const AFunctionID: integer = 0);
var
  TN: TTreeNode;
  F: TBaseFrame;
begin
  TN := CheckComponentNode(Component, True);
  if TN <> nil then
  begin
    TN := CheckEventNode(Component, TN, EventName);
    if TN <> nil then
    begin
      Expand(TN);
      TN.Selected := True;
      tvClassesDblClick(TN.TreeView);
      if TCustomTreeItem(TN.Data).EditorFrame <> nil then
      begin
        F := TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame);
        if F.PageControl.PageCount > 1 then
          F.PageControl.ActivePageIndex := 1;
        if (F is TEventFrame) and (AFunctionID <> 0) then begin
            TEventFrame(F).ChangeFunctionID(AFunctionID);
        end;
      end;
    end;
  end;
end;

function TdfPropertyTree.CheckObjectNode(AParent: TTreeNode;
  ObjectName, ClassName: string; Add: Boolean = True): TTreeNode;
var
  I: Integer;
  S: string;
begin
  Result := nil;
  if Assigned(AParent) then
  begin
    S := UpperCase(ObjectName);
    for I := 0 to AParent.Count -1 do
    begin
      if TCustomTreeItem(AParent[I].Data).ItemType = tiObject then
      begin
        if UpperCase(TObjectTreeItem(AParent[I].Data).Name) = S then
        begin
          Result := AParent[I];
          Break;
        end;
      end;
    end;
    if Result = nil then
    begin
      if Add then
        Result := AddObjectNode(AParent, ObjectName, ClassName);
    end;
  end;
end;

function TdfPropertyTree.AddObjectNode(Parent: TTreeNode;
  Name, ClassName: string): TTreeNode;
var
  ObjectTreeItem: TObjectTreeItem;
  EO: TEventObject;
  I: Integer;
begin
  Result := nil;
  if (Parent = nil) or (Name = '') then Exit;
  // Добавляем объект в дерево
  Result := TTreeView(Parent.TreeView).Items.AddChild(Parent,
    Name + '(' + ClassName + ')');
  Result.ImageIndex := 2;
  Result.SelectedIndex := 2;

  ObjectTreeItem := TObjectTreeItem.Create;
  ObjectTreeItem.Name := Name;

  //Присваеваем значение имени формы владельца
  ObjectTreeItem.Parent := TObjectTreeItem(Parent.Data);
  ObjectTreeItem.OwnerId := ObjectTreeItem.Parent.Id;
  ObjectTreeItem.MainOwnerName := TObjectTreeItem(Parent.Data).MainOwnerName;
  if Assigned(TObjectTreeItem(Parent.Data)) then
    ObjectTreeItem.EventObject := TObjectTreeItem(Parent.Data).EventObject.ChildObjects.FindObject(Name)
  else
    ObjectTreeItem.EventObject := nil;

  // Создаем если не нашли
  if not Assigned(ObjectTreeItem.EventObject) then
  begin
    EO := TEventObject.Create;
    try
      EO.ObjectName := Name;
      I := TObjectTreeItem(Parent.Data).EventObject.ChildObjects.AddObject(EO);
      ObjectTreeItem.EventObject :=
        TObjectTreeItem(Parent.Data).EventObject.ChildObjects.EventObject[I];
    finally
      EO.Free;
    end;
  end;

  ObjectTreeItem.Id := ObjectTreeItem.EventObject.ObjectKey;

  Result.Data := ObjectTreeItem;
  Result.HasChildren := True;
  ObjectTreeItem.Node := Result;
end;

function TdfPropertyTree.AddEventNode(C: TComponent; AParent: TTreeNode;
  Name: string): TTreeNode;
var
  J: Integer;
  TempPropList: TPropList;
  CurrentObject: TEventObject;
  EI: TEventTreeItem;

  function GetExistsEvent(const AnEventName: String): TEventItem;
  var
    I: Integer;
  begin
    Result := CurrentObject.EventList.Find(AnEventName);
    if not Assigned(Result) then
    begin
      I := CurrentObject.EventList.Add(AnEventName, 0);
      Result := CurrentObject.EventList[I];
    end;

    for I := 0 to J - 1 do
    begin
      if UpperCase(TempPropList[I]^.Name) = UpperCase(AnEventName) then
      begin
        Result.EventData := GetTypeData(TempPropList[I]^.PropType^);
        Break;
      end;
    end;
    Result.EventObject := CurrentObject;
  end;

begin
  Result := nil;
  if Assigned(AParent) then
  begin
    if Assigned(EventControl) then
    begin
      J := GetPropList(C.ClassInfo, [tkMethod], @TempPropList);
      CurrentObject := (TObject(AParent.Data) as TObjectTreeItem).EventObject;
      if Assigned(CurrentObject) then
      begin
        if EventControl.KnownEventList.IndexOf(Name) > -1 then
        begin
          Result := TTreeView(AParent.TreeView).Items.AddChild(AParent, Name);
          EI := TEventTreeItem.Create;
          EI.EventItem := GetExistsEvent(Name);
          EI.Name := Name;
          EI.ID := EI.EventItem.EventID;
          EI.MainOwnerName := TObjectTreeItem(AParent.Data).MainOwnerName;
          EI.OwnerId := TObjectTreeItem(AParent.Data).Id;
          EI.ObjectItem := TObjectTreeItem(AParent.Data);
          Result.Data := EI;
          EI.Node := Result;
          if EI.EventItem.FunctionKey <> 0 then
            UpdateEventOverload(AParent, 1);
          if EI.EventItem.Disable then
            UpdateEventDesabled(AParent, 1);
        end;
      end;
    end;
  end;
end;

function TdfPropertyTree.CheckEventNode(C: TComponent; AParent: TTreeNode;
  Name: string): TTreeNode;
var
  I: Integer;
  S: string;
begin
  Result := nil;
  if Assigned(AParent) then
  begin
    S := UpperCase(Name);
    for I := 0 to AParent.Count -1 do
    begin
      if TCustomTreeItem(AParent[I].Data).ItemType = tiEvent then
      begin
        if UpperCase(TObjectTreeItem(AParent[I].Data).Name) = S then
        begin
          Result := AParent[I];
          Break;
        end;
      end;
    end;
    if Result = nil then
      Result := AddEventNode(C, AParent, Name);
  end;
end;


procedure TdfPropertyTree.actAddItemHint(var HintStr: String;
  var CanShow: Boolean);
begin
  CanShow := False;
  HintStr := '';
  if Assigned(FPageControl.ActivePage) and
    Assigned(TTreeTabsheet(FPageControl.ActivePage).Tree.Selected) then
  begin
    case TCustomTreeItem(TTreeTabsheet(FPageControl.ActivePage).Tree.Selected.Data).ItemType of
      tiMacros, tiMacrosFolder: HintStr := 'Добавить макрос';
      tiReport, tiReportFolder: HintStr := 'Добавить отчёт';
      tiVBClass, tiVBClassFolder: HintStr := 'Добавить VB класс';
      tiConst, tiConstFolder: HintStr := 'Добавить константы и переменные';
      tiGlobalObject, tiGlobalObjectFolder: HintStr := 'Добавить глобальный объект';
      tiSF, tiSFFolder: HintStr := 'Добавить скрипт-функцию';
      tiPrologSF, tiPrologSFFolder: HintStr := 'Добавить пролог-скрипт';
    else
      HintStr := 'Добавить';  
    end;
    if HintStr <> '' then CanShow := True;
  end;
end;

procedure TdfPropertyTree.tvClassesChange(Sender: TObject;
  Node: TTreeNode);
var
  B: Boolean;
  S: String;
begin
  inherited;
  if not (csDocking in ControlState) then
  begin
    actAddItemHint(S, B);
    TBItem2.Hint := S;
    N2.Caption := S;
    if Assigned(OnChangeNode) then
      FOnChangeNode(Sender, Node);
  end;    
end;

function TdfPropertyTree.FindReport(Id: Integer): TTreeNode;
var
  SQL: TIBSQL;
  PTN: TTreeNode;
begin
  Result := nil;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcDelphiObject.ReadTransaction;
    //Вытягиваем дерево папок, содерж. отчёт
    SQL.SQL.Text := 'SELECT * FROM rp_reportlist WHERE id = :id ';

    SQl.Params[0].AsInteger := ID;
    SQL.ExecQuery;

    PTN := FindReportFolder(SQL.FieldByName(fnReportGroupKey).AsInteger);

    //Если папка найдена то ищем нод отчёта
    if Assigned(PTN) then Result := FindNode(ID, PTN);
  finally
    SQL.Free;
  end;
end;

function TdfPropertyTree.OpenReport(ID: integer): Boolean;
var
  TN: TTreeNode;
begin
  CheckHandle(Self);
  //ищем отчет в дереве
  TN := FindReport(ID);
  Result := TN <> nil;
  if Result then
  begin
    //если нод отчета найден то открываем отчет на редактиворание
    TN.TreeView.Show;
    TN.Selected := True;
    TTreeView(TN.TreeView).OnDblClick(TN.TreeView);
  end;
end;

function TdfPropertyTree.FindReportFolder(Id: Integer; OnlyApplication: Boolean = False): TTreeNode;
var
  SQL: TIBSQL;
  TN, PTN: TTreeNode;
  I: Integer;
begin
  Result := nil;
  UpdatePages;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcDelphiObject.ReadTransaction;
    //Вытягиваем дерево папок
    SQL.SQL.Text := 'SELECT rg2.* FROM rp_reportgroup rg1, rp_reportgroup rg2 ' +
      '  WHERE rg1.id = :id AND rg1.lb >= rg2.lb AND rg1.rb <= rg2.rb ' +
      '  ORDER BY rg2.lb';

    SQl.Params[0].AsInteger := ID;
    SQL.ExecQuery;

    PTN := nil;
    if not SQL.Eof then
    begin
      if not OnlyApplication then
      begin
        for I := 0 to FPageControl.PageCount - 1 do
        begin
          if FPageControl.Pages[I].Tag <> OBJ_APPLICATION then
          begin
          //Пытаемся найти у форм
            TN := TTreeTabSheet(FPageControl.Pages[I]).ReportRootNode;
            if TN <> nil then
            begin
              if SQL.FieldByName(fnId).AsInteger = TCustomTreeItem(TN.Data).Id then
              begin
                PTN := TN;
                SQL.Next;
                Break;
              end;
            end;

            TN := TTreeTabSheet(FPageControl.Pages[I]).gdcReportRootNode;
            if TN <> nil then
            begin
              if SQL.FieldByName(fnId).AsInteger = TCustomTreeItem(TN.Data).Id then
              begin
                PTN := TN;
                SQL.Next;
                Break;
              end;
            end;
          end;
        end;
      end;
      if PTN = nil then
        PTN := GetPageByObjID(OBJ_APPLICATION).ReportRootNode;
    end else
      Exit;

    if PTN = nil then
      exit
    else
      Result := PTN;
    //раскрываем нод
    Expand(PTN);
    if not SQl.Eof then
    begin
      //По названиям папок отчетов полученных из базы ищем
      //папку непосредственно содерж. отчёт
      //Если чтото не так - выходим
      while not SQL.Eof do
      begin
        TN := FindNode(SQL.FieldByName(fnId).AsInteger, PTN);
        if not Assigned(TN) then Exit;
        PTN := TN;
        if Assigned(PTN) then
          PTN.Expanded := True
        else
          Exit;
        SQL.Next;
      end;
      Result := PTN;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TTreeTabSheet.CreateWnd;
begin
  inherited;
{  if FMemoryStream <> nil then
  begin
    ReadRootNodes(FMemoryStream);
    FMemoryStream.Free;
    FMemoryStream := nil;
  end;}
end;

procedure TTreeTabSheet.DestroyWnd;
begin
{  FMemoryStream := TMemoryStream.Create;
  SaveRootNodes(FMemoryStream);
  FMemoryStream.Position := 0;}

  inherited;
end;



function TTreeTabSheet.GetClassesRootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.ClassesRootNode;
end;

function TTreeTabSheet.GetConstRootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.ConstRootNode;
end;

function TTreeTabSheet.GetGORootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.GORootNode;
end;

function TTreeTabSheet.GetMacrosRootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.MacrosRootNode;
end;

function TTreeTabSheet.GetObjectsRootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.ObjectsRootNode;
end;

function TTreeTabSheet.GetReportRootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.ReportRootNode;
end;

function TTreeTabSheet.GetVBClassRootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.VBClassRootNode;
end;

function TTreeTabSheet.GetSFRootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.SFRootNode;
end;

procedure TTreeTabSheet.SetgdcReportRootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.gdcReportRootNode := Value;
end;

function TTreeTabSheet.GetgdcReportRootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.gdcReportRootNode;
end;

procedure TTreeTabSheet.SetPrologRootNode(const Value: TTreeNode);
begin
  if FTree <> nil then
    FTree.FPrologRootNode := Value;
end;

function TTreeTabSheet.GetPrologRootNode: TTreeNode;
begin
  Result := nil;
  if FTree <> nil then
    Result := FTree.FPrologRootNode;
end;


{ TprpTreeView }


procedure TprpTreeView.CreateWnd;
var
  I: Integer;
begin
  inherited CreateWnd;
  if FMemoryStream <> nil then
  begin
    ReadHasChildren(FMemoryStream);
    FMemoryStream.Destroy;
    FMemoryStream := nil;
    //Обновляен указатели
    for I := 0 to Items.Count - 1 do
    begin
      TCustomTreeItem(Items[I].Data).Node := Items[I];
      if TCustomTreeItem(Items[I].Data).EditorFrame <> nil then
        TBaseFrame(TCustomTreeItem(Items[I].Data).EditorFrame).Node := Items[I];
    end;
    if FSelectedIndex <> - 1 then
      Items[FSelectedIndex].Selected := True;
  end;
end;

destructor TprpTreeView.Destroy;
var
  F: TCustomForm;
begin
  if FMemoryStream <> nil then FMemoryStream.Free;
  //В борландовском коде ошибка. Если дерево имеет
  //фокус ввода то при дестрое возникает исключение
  //поэтому при необходимоти снимаем фокус 
  if Parent <> nil then
  begin
    F := GetParentForm(Self);
    if F <> nil then
      F.DefocusControl(Self, True);
  end;
  inherited;
end;

procedure TprpTreeView.DestroyWnd;
begin
  InitRootIndexes;
  if Items.Count > 0 then
  begin
    FMemoryStream := TMemoryStream.Create;
    SaveHasChildren(FMemoryStream);
    FMemoryStream.Position := 0;
    Selected := nil
  end;
  inherited DestroyWnd;
end;

procedure TprpTreeView.InitRootIndexes;
begin
  FClassesRootNodeIndex := -1;
  FMacrosRootNodeIndex := -1;
  FGORootNodeIndex := -1;
  FReportRootNodeIndex := -1;
  FgdcReportRootNodeIndex := -1;
  FObjectsRootNodeIndex := -1;
  FSFRootNodeIndex := -1;
  FConstRootNodeIndex := -1;
  FVBClassRootNodeIndex := -1;
  FSelectedIndex := -1;
  FPrologRootNodeIndex := -1;
end;

procedure TprpTreeView.ReadHasChildren(Stream: TStream);
var
  Node: TTreeNode;
begin
  Node := Items.GetFirstNode;
  while Node <> nil do
  begin
    ReadNodeHasChildren(Node, Stream);
    Node := Node.GetNextSibling;
  end;
  ReadRootNodes;
end;

procedure TprpTreeView.ReadNodeHasChildren(N: TTreeNode; Stream: TStream);
var
  H: Boolean;
  lCount: Integer;
  K: TTreeNode;
begin
  Stream.ReadBuffer(H, SizeOf(H));
  N.HasChildren := H;
  Stream.ReadBuffer(lCount, SizeOf(lCount));
  if lCount <> N.Count then
    raise Exception.Create('node error');

  K := N.GetFirstChild;
  while (K <> nil) do
  begin
    ReadNodeHasChildren(K, Stream);
    K := K.GetNextSibling;
  end;
end;

procedure TprpTreeView.ReadRootNodes;
begin
  if FMacrosRootNodeIndex <> -1 then
    MacrosRootNode := Items[FMacrosRootNodeIndex];
  if FObjectsRootNodeIndex <> -1 then
    ObjectsRootNode := Items[FObjectsRootNodeIndex];
  if FSFRootNodeIndex <> -1 then
    SFRootNode := Items[FSFRootNodeIndex];
  if FConstRootNodeIndex <> -1 then
    ConstRootNode := Items[FConstRootNodeIndex];
  if FVBClassRootNodeIndex <> -1 then
    VBClassRootNode := Items[FVBClassRootNodeIndex];
  if FGORootNodeIndex <> -1 then
    GORootNode := Items[FGORootNodeIndex];
  if FReportRootNodeIndex <> -1 then
    ReportRootNode := Items[FReportRootNodeIndex];
  if FgdcReportRootNodeIndex <> -1 then
    gdcReportRootNode := Items[FgdcReportRootNodeIndex];
  if FClassesRootNodeIndex <> -1 then
    ClassesRootNode := Items[FClassesRootNodeIndex];
  if FPrologRootNodeIndex <> -1 then
    PrologRootNode := Items[FPrologRootNodeIndex]
end;

procedure TprpTreeView.SaveHasChildren(Stream: TStream);
var
  Node: TTreeNode;
begin
  FNodeIndex := 0;
  Node := Items.GetFirstNode;
  while Node <> nil do
  begin
    UpdateRootIndexes(Node, FNodeIndex);
    //Выбранный нод
    SaveNodeHasChildren(Node, Stream);
    Node := Node.GetNextSibling;
  end;
end;


procedure TprpTreeView.SaveNodeHasChildren(N: TTreeNode; Stream: TStream);
var
  lCount: Integer;
  H: Boolean;
  K: TTreeNode;
begin
  H := N.HasChildren;
  Stream.WriteBuffer(H, SizeOf(H));
  if N = Selected then
    FSelectedIndex := FNodeIndex;
  Inc(FNodeIndex);
  lCount := N.Count;
  Stream.WriteBuffer(lCount, SizeOf(lCount));

  K := N.GetFirstChild;
  while (K <> nil) do
  begin
    SaveNodeHasChildren(K, Stream);
    K := K.GetNextSibling;
  end;
end;

procedure TprpTreeView.SetgdcReportRootNode(const Value: TTreeNode);
begin
  FgdcReportRootNode := Value;
end;

procedure TprpTreeView.UpdateRootIndexes(N: TTreeNode; Index: Integer);
begin
  if FClassesRootNode = N then
    FClassesRootNodeIndex := Index
  else
  if FMacrosRootNode = N then
    FMacrosRootNodeIndex := Index
  else
  if FGORootNode = N then
    FGORootNodeIndex := Index
  else
  if FReportRootNode = N then
    FReportRootNodeIndex := Index
  else
  if FgdcReportRootNode = N then
    FgdcReportRootNodeIndex := Index
  else
  if FObjectsRootNode = N then
    FObjectsRootNodeIndex := Index
  else
  if FSFRootNode = N then
    FSFRootNodeIndex := Index
  else
  if FConstRootNode = N then
    FConstRootNodeIndex := Index
  else
  if FVBClassRootNode = N then
    FVBClassRootNodeIndex := Index
  else
  if FPrologRootNode = N then
    FPrologRootNodeIndex := Index;
end;

procedure TdfPropertyTree.InvalidateTree;
begin
  if FPageControl.ActivePage <> nil then
    TTreeTabSheet(FPageControl.ActivePage).Tree.Invalidate;
end;

procedure TdfPropertyTree.tvClassesGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  tvClassesGetImageIndex(Sender, Node);
end;

function TdfPropertyTree.GetPath: string;
var
  N: TTreeNode;
  TV: TTreeView;
begin
  Result := '';
  Tv := GetActiveTree;
  if (TV <> nil) and (TV.Selected <> nil) then
  begin
    N := TTreeTabSheet(FPageControl.ActivePage).Tree.Selected;
    while N <> nil do
    begin
      Result := '\' + N.Text + Result;
      N := N.Parent;
    end;
    N := TTreeTabSheet(FPageControl.ActivePage).Tree.Selected;
    if TCustomTreeItem(N.Data).ItemType = tiGDCClass then
    begin
      if TGDCClassTreeItem(N.Data).SubTypeComent <> '' then
        Result := Result + '(' + TGDCClassTreeItem(N.Data).SubTypeComent + ')';
    end else
    if TCustomTreeItem(N.Data).ItemType = tiMethod then
    begin
      N := TTreeTabSheet(FPageControl.ActivePage).Tree.Selected.Parent;
      if TGDCClassTreeItem(N.Data).SubTypeComent <> '' then
        Result := Result + '(' + TGDCClassTreeItem(N.Data).SubTypeComent + ')';
    end;
  end;
end;

procedure TdfPropertyTree.SetOnChangeNode(const Value: TTVChangedEvent);
begin
  FOnChangeNode := Value;
end;

procedure TdfPropertyTree.OnChangePage(Sender: TObject);
var
  TV: TTreeView;
begin
  //Изменяем индекс и хинт в комбобоксе объектов
  SetObjectIndex;
  //изменяем хинты кнопок и надпись в статусбаре
  TV := GetActiveTree;
  if TV <> nil then
    tvClassesChange(TV, TV.Selected);
end;

procedure TdfPropertyTree.cbObjectListDropDown(Sender: TObject);
var
  I: Integer;
  W: Integer;
  T: Integer;
  C: TControlCanvas;
begin
  UpdatePages;
//  if cbObjectList.Items
  W := cbObjectList.Width;
  C := TControlCanvas.Create;
  try
    C.Control := cbObjectList;
    C.Font := cbObjectList.Font;
    for I := 0 to cbObjectList.Items.Count -1 do
    begin
      T := C.TextWidth(cbObjectList.Items[I]);
      if T > W then W := T + 10;
    end;
  finally
    C.Free;
  end;
  SendMessage(cbObjectList.Handle, CB_SETDROPPEDWIDTH, W, 0);
end;

procedure TdfPropertyTree.cbObjectListChange(Sender: TObject);
begin
  FPageControl.ActivePageIndex := cbObjectList.ItemIndex;
end;

procedure TdfPropertyTree.SetObjectIndex;
begin
  cbObjectList.ItemIndex := FPageControl.ActivePageIndex;
  if cbObjectList.ItemIndex > -1 then
    cbObjectList.Hint := cbObjectList.Items[cbObjectList.ItemIndex]
  else
    cbObjectList.Hint := '';
end;

procedure TdfPropertyTree.tbtObjectListResize(Sender: TObject);
begin
  inherited;
  tbtObjectList.Realign;
  //Вычисляем ширину омбобокса
  cbObjectList.Width := tbtObjectList.ClientWidth - cbObjectList.Left;
  if (cbObjectList.Width < 30) then
    cbObjectList.Width := 30;
end;

procedure TdfPropertyTree.actRefreshExecute(Sender: TObject);
begin
  UpdatePages;
end;

procedure TdfPropertyTree.UpdateEventDesabled(TN: TTreeNode;
  Increment: Integer);
var
  ATN: TTreeNode;
begin
  //все нормально можно работать
  ATN := TN;
  while TCustomTreeItem(ATN.Data).ItemType = tiObject do
  begin
    TObjectTreeItem(ATN.Data).DisabledEvents :=
      TObjectTreeItem(ATN.Data).DisabledEvents + Increment;
    if TObjectTreeItem(ATN.Data).DisabledEvents < 0 then
      TObjectTreeItem(ATN.Data).DisabledEvents := 0;
    ATN := ATN.Parent;
  end;
  TN.TreeView.Invalidate;
end;

procedure TdfPropertyTree.UpdateMethodDisabled(TN: TTreeNode;
  Increment: Integer);
var
  ATN: TTreeNode;
begin
  //все нормально можно работать
  ATN := TN;
  while TCustomTreeItem(ATN.Data).ItemType = tigdcClass do
  begin
    TgdcClassTreeItem(ATN.Data).DisabledMethods :=
      TgdcClassTreeItem(ATN.Data).DisabledMethods + Increment;
    if TgdcClassTreeItem(ATN.Data).DisabledMethods < 0 then
      TgdcClassTreeItem(ATN.Data).DisabledMethods := 0;
    ATN := ATN.Parent;
  end;
  ActiveTree.Invalidate;
end;

procedure TdfPropertyTree.RefreshFullClassName(const FullName: Boolean);
var
  TS: TTreeTabSheet;
//  I: Integer;

  procedure ChangeNodeText(const Node: TTreeNode);
  var
    I: Integer;
    LMethod: TgdcClassTreeItem;
  begin
    if Assigned(Node) then
    begin
      for I := 0 to Node.Count - 1 do
      begin
        if Node.Item[I].HasChildren then
        begin
          LMethod := TgdcClassTreeItem(Node.Item[I].Data);
          if not FullName then
          begin
            Node.Item[I].Text := LMethod.TheClass.Class_Name +
              LMethod.TheClass.SubType;
          end else
            begin
              if Length(LMethod.TheClass.SubType) > 0 then
                Node.Item[I].Text := LMethod.TheClass.SubType;
            end;
          ChangeNodeText(Node.Item[I]);
        end;
      end;
    end;
  end;
begin
  CheckHandle(Self);
  TS := GetPageByObjID(OBJ_APPLICATION);
  if Assigned(TS) then
  begin
    ChangeNodeText(TS.ClassesRootNode);
  end;
end;

procedure TdfPropertyTree.actRefreshTreeExecute(Sender: TObject);
var
  I: Integer;
begin
  CancelCopy;
  CheckHandle(Self);
  //В Delphi есть небольшое рассогласование. Функции GetParentForm возвращает
  //форму у которой парент нил, поэтому при дестрое компонента, если данная
  //форма задокирована, свойство астивеконтрол может остатся неопределен.
  //Поэтому от греха подальше устанавливаем астивным комбобокс
  SetFocusedControl(cbObjectList);
  //
  if PropertySettings.GeneralSet.NoticeTreeRefresh then
  begin
    I := TfrmGedeminProperty(DockForm).EditingCont;
    if I > 0 then
      if MessageBox(Application.Handle,
        'Перед обновлением дерева необходимо'#13#10 +
        'закрыть все редактируемые скрипты', MSG_WARNING,
        MB_OKCANCEL or MB_TASKMODAL) = IDCANCEL then
        Exit;
  end;
  TfrmGedeminProperty(DockForm).actCloseAllExecute(nil);
  if TfrmGedeminProperty(DockForm).EditingCont > 0 then Exit;

  for I := FPageControl.PageCount - 1 downto 0 do
  begin
    FPageControl.Pages[I].Destroy;
    cbObjectList.Items.Delete(I);
  end;
  UpdatePages;
end;

procedure TdfPropertyTree.InsertRemoveObject(C: TComponent;
  Operation: TPrpOperation);
var
  TN, tnChild: TTreeNode;
  TI: TCustomTreeItem;
begin
  if Operation = poRemove then
  begin
    TN := CheckComponentNode(C, False);
    if TN <> nil then begin
      TI := TCustomTreeItem(TN.Data);
      if Assigned(TI) and Assigned(TI.EditorFrame) then begin
        TBaseFrame(TI.EditorFrame).Close;
      end;
      tnChild:= TN.GetFirstChild;
      while Assigned(tnChild) do begin
        try
          TI := TCustomTreeItem(tnChild.Data);
          if Assigned(TI) and Assigned(TI.EditorFrame) then
            TBaseFrame(TI.EditorFrame).Close;
        finally
          tnChild:= TN.GetNextChild(tnChild);
        end;
      end;

      TN.Delete;
    end;
  end else
  if Operation = poInsert then
  begin
    TN := CheckComponentNode(C, True);
    if TN <> nil then
      FillEvents(C, TN, True);
  end;
end;

procedure TdfPropertyTree.RenameObject(C: TComponent; const AOldName: string);
var
  TN: TTreeNode;
begin
  TN := CheckComponentNode(C, False, AOldName);
  if (TN <> nil) and (AOldName <> '') then begin
    TN.Text:= C.Name + '(' + C.ClassName + ')';
    TObjectTreeItem(TN.Data).Name:= C.Name;
  end;
end;

function TdfPropertyTree.CheckComponentNode(Component: TComponent;
  Add: Boolean; const AOldName: string): TTreeNode;
var
  F: TCreateableForm;
  TS: TTreeTabSheet;
  TN: TTreeNode;
  SL: TStringList;
  C: TComponent;
  I: Integer;
begin
  Result := nil;
  CheckHandle(Self);
  if Assigned(Component) then
  begin
    F := GetOwnerForm(Component);
    if Assigned(F) then
    begin
      TS := CheckFormPage(F);
      if TS <> nil then
      begin
        TS.Show;
        TN := TS.ObjectsRootNode;
        if Assigned(TN) then
        begin
          TN.Expanded := True;
          SL := TStringList.Create;
          try
            C := Component;
            while C <> nil do
            begin
              if C is TCreateableForm then Break;
              if (C = Component) and (AOldName <> '') then
                SL.AddObject(AOldName, C)
              else
                SL.AddObject(C.Name, C);
              C := C.Owner;
            end;
            if SL.Count > 0 then
            begin
              for I := SL.Count - 1 downto 0 do
              begin
                if (i = 0) and (AOldName <> '') then
                  TN := CheckObjectNode(TN, AOldName, SL.Objects[i].ClassName, Add)
                else
                  TN := CheckObjectNode(TN, SL[I], SL.Objects[i].ClassName, Add);
                if TN = nil then Exit;
              end;
            end;
            Result := TN;
          finally
            SL.Free;
          end;
        end;
      end;
    end;
  end;
end;

procedure TdfPropertyTree.OpenMacrosRootFolder(Component: TComponent);
var
  TS: TTreeTabSheet;
begin
  TS := CheckComponentPage(Component);
  if TS <> nil then
  begin
    TS.Show;
    if TS.MacrosRootNode <> nil then
    begin
      SetFocusedControl(TS.Tree);
      TS.MacrosRootNode.MakeVisible;
      TS.MacrosRootNode.Selected := True;
      TS.MacrosRootNode.Expanded := True;
    end;
  end;
end;

function TdfPropertyTree.CheckComponentPage(C: TComponent): TTreeTabSheet;
var
  F: TCustomForm;
begin
  Result := nil;
  if C <> Application then
  begin
    F := GetOwnerForm(C);
    if Assigned(F) then
      Result := CheckFormPage(TCreateableForm(F))
  end else
    Result := GetPageByObjID(OBJ_APPLICATION);
end;

procedure TdfPropertyTree.OpenReportRootFolder(Component: TComponent);
var
  TS: TTreeTabSheet;
begin
  TS := CheckComponentPage(Component);
  if TS <> nil then
  begin
    TS.Show;
    if TS.ReportRootNode <> nil then
    begin
      SetFocusedControl(TS.Tree);
      TS.ReportRootNode.MakeVisible;
      TS.ReportRootNode.Selected := True;
      TS.ReportRootNode.Expanded := True;
    end;
  end;
end;

procedure TdfPropertyTree.OpenObjectPage(Component: TComponent);
var
  TS: TTreeTabSheet;
begin
  TS := CheckComponentPage(Component);
  if TS <> nil then
  begin
    TS.Show;
    SetFocusedControl(TS.Tree);
  end;
end;

procedure TdfPropertyTree.tvClassesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Shift * [ssCtrl] <> [] then
  begin
    if (Key = Ord('F')) or (Key = Ord('f')) then
    begin
      if FindDialog.Execute then
      begin
        Key := 0;
      end;
    end;
  end;

  case Key of
    VK_F3:
    begin
      if FSearchString > '' then
      begin
        FindDialogFind(FindDialog);
      end else
        FindDialog.Execute;
      Key := 0;
    end;
    VK_RETURN:
    begin
      if GetSelectedNode <> nil then
        tvClassesDblClick(Sender);
      Key := 0;
    end;
    VK_DELETE:
    begin
      actDeleteItem.Execute;
      Key := 0;
    end;
  end;
end;

procedure TdfPropertyTree.actDisableExecute(Sender: TObject);

  procedure SetCurrentComponentsEvent;
  var
    LOwnerForm: TComponent;
    LI: Integer;
    LCurrObj: TComponent;
  begin
    LCurrObj := nil;
    with TEventTreeItem(SelectedNode.data) do
    begin
      for LI := 0 to Screen.FormCount - 1 do
      begin
        if Screen.Forms[LI].InheritsFrom(TCreateableForm) and
          (AnsiUpperCase(TCreateableForm(Screen.Forms[LI]).InitialName) =
          AnsiUppercase(MainOwnerName)) then
        begin
          LOwnerForm := Screen.Forms[LI];
          if EventItem.ObjectName = MainOwnerName then
            LCurrObj := LOwnerForm
          else
            begin
              if Assigned(LOwnerForm) then
                LCurrObj :=
                  LOwnerForm.FindComponent(EventItem.ObjectName);
            end;
        if Assigned(LCurrObj) then
           EventControl.RebootEvents(LCurrObj);
//           EventControl.OversetEvents(LCurrObj);
        end;
      end;
    end;
  end;
begin
  case TCustomTreeItem(SelectedNode.data).ItemType of
    tiEvent:
    begin
      with TEventTreeItem(SelectedNode.data) do
      begin
        {$IFDEF GEDEMIN}
        if Assigned(EditorFrame) then
          TEventFrame(EditorFrame).actDisable.Execute
        else
          begin
            EventItem.Disable := not EventItem.Disable;
            if Assigned(MethodControl) then
              MethodControl.SaveDisableFlag(Id, EventItem.Disable)
          end;
        {$ENDIF}
      end;
      SetCurrentComponentsEvent;
    end;
    tiMethod:
    begin
      with TMethodTreeItem(SelectedNode.data) do
      begin
        {$IFDEF GEDEMIN}
        if Assigned(EditorFrame) then
          TMethodFrame(EditorFrame).actDisable.Execute
        else
          begin
            TheMethod.Disable := not TheMethod.Disable;
            MethodControl.SaveDisableFlag(Id, TheMethod.Disable)
          end;
        {$ENDIF}  
      end;
    end;
  end;
//  tvClassesGetImageIndex(nil, SelectedNode);
  if Assigned(ActiveTree) then
    ActiveTree.Invalidate;
end;

procedure TdfPropertyTree.pmTreeViewPopup(Sender: TObject);
begin
  inherited;

  if Assigned(SelectedNode) and
    (TCustomTreeItem(SelectedNode.data).ItemType in [tiEvent, tiMethod]) and
    (TCustomTreeItem(SelectedNode.data).ID <> 0) then
  begin
    actDisable.Enabled := True;
    SetVisibleDisable;
  end else
    actDisable.Enabled := False;
end;

procedure TdfPropertyTree.SetVisibleDisable;
  procedure RedButton;
  begin
    actDisable.ImageIndex := 50;
    actDisable.Caption := 'Подключить';
  end;

  procedure GreenButton;
  begin
    actDisable.ImageIndex := 49;
    actDisable.Caption := 'Отключить';
  end;
begin
  if not Assigned(SelectedNode) then
    Exit;

  case TCustomTreeItem(SelectedNode.data).ItemType of
    tiEvent:
    begin
      if TEventTreeItem(SelectedNode.data).EventItem.Disable then
      begin
        RedButton;
      end else
        begin
          GreenButton;
        end;
    end;
    tiMethod:
    begin
      if TMethodTreeItem(SelectedNode.data).TheMethod.Disable then
      begin
        RedButton;
      end else
        begin
          GreenButton;
        end;
    end;
  end;
end;

function TdfPropertyTree.OpenMacros(MacrosKey: integer): Boolean;
var
  TN: TTreeNode;
begin
  CheckHandle(Self);
  TN := FindMacrosByKey(MacrosKey);
  Result := TN <> nil;
  if Result then
  begin
    TN.TreeView.Show;
    TN.Selected := True;
    TTreeView(TN.TreeView).OnDblClick(TN.TreeView);
  end;
end;

function TdfPropertyTree.FindMacrosByKey(MacrosKey: Integer): TTreeNode;
var
  PTN: TTreeNode;
  I: Integer;
begin
  Result := nil;
  for I := 0 to FPageControl.PageCount - 1 do
  begin
    PTN := TTreeTabSheet(FPageControl.Pages[I]).MacrosRootNode;
      //Делаем видимым дерево
//  PTN.TreeView.Show;
    Expand(PTN);
    Result := FindNode(MacrosKey, PTN);
    if Assigned(Result) then
      Break
  end;
end;

procedure TdfPropertyTree.CheckCreateGDCReportFolder(Id: Integer; gdcObject: TgdcBase);
var
  SQl: TIBSQL;
begin
  SQL := TIBSQL.Create(nil);
  try
    if gdcObject.Transaction.InTransaction then
      SQL.Transaction := gdcObject.Transaction
    else
      SQL.Transaction := gdcObject.ReadTransaction;
    SQL.SQL.Text := 'SELECT r.* FROM rp_reportgroup r WHERE r.Id = :id ';
    SQL.Params[0].AsInteger := Id;
    SQL.ExecQuery;
    if SQL.Eof then
    begin
      Assert(ID > 0);
      gdcReportGroup.Open;
      try
        gdcReportGroup.Insert;
        gdcReportGroup.FieldByName(fnid).AsInteger := Id;
        gdcReportGroup.FieldByName(fnName).AsString := gdcObject.GetDisplayName(gdcObject.SubSet);
        gdcReportGroup.FieldByName(fnUserGroupName).AsString := UpperCase(gdcObject.ClassName + gdcObject.SubType);
        gdcReportGroup.Post;
      finally
        gdcReportGroup.Close;
      end;
    end;
  finally
    SQL.Free;
  end;
end;

procedure TdfPropertyTree.actAddToSettingExecute(Sender: TObject);
var
  TN: TTreeNode;
begin
  TN := SelectedNode;
  if TN <> nil then
  begin
    if TCustomTreeItem(TN.Data).ItemType in [tiMacros, tiReport, tiVBClass, tiConst,
      tiMethod, tiEvent, tiSF, tiGlobalObject, tiPrologSF] then
    begin
      if Assigned(TCustomTreeItem(TN.Data).EditorFrame) then
        TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame).AddTosetting
      else
      begin
        TfrmGedeminProperty(DockForm).ShowFrame(TCustomTreeItem(TN.Data), False);
        if TCustomTreeItem(TN.Data).EditorFrame <> nil then
        begin
          TBaseFrame(TCustomTreeItem(TN.Data).EditorFrame).AddTosetting;
          TCustomTreeItem(TN.Data).EditorFrame.Free;
        end;
      end;
    end;
  end;
end;

procedure TdfPropertyTree.actAddToSettingUpdate(Sender: TObject);
var
  TN: TTreeNode;
begin
  TN := SelectedNode;
  TAction(Sender).Enabled := (TN <> nil) and (TCustomTreeItem(TN.Data).ItemType
    in [tiMacros, tiReport, tiVBClass, tiConst, tiMethod, tiEvent, tiSF,
    tiGlobalObject, tiPrologSF]) and (TCustomTreeItem(TN.Data).Id > 0);
end;

procedure TdfPropertyTree.actRenameItemUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (ActiveTree <> nil) and (Activetree.Selected <> nil) and
   (tCustomTreeItem(Activetree.Selected.Data).ItemType in [tiMacrosFolder,
    tiReportFolder]) and (tCustomTreeItem(Activetree.Selected.Data).ID > 0) and
    (tCustomTreeItem(Activetree.Selected.Data).ID <> OBJ_GLOBALMACROS);
end;

procedure TdfPropertyTree.actRenameItemExecute(Sender: TObject);
begin
  if (ActiveTree <> nil) and (Activetree.Selected <> nil) then
    Activetree.Selected.EditText;
end;

procedure TdfPropertyTree.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
{  if pCaption.Visible then
  begin
    pCaption.Top := 0;
    TBDock1.Top := pCaption.Height;
  end;}

  inherited;
end;

procedure TdfPropertyTree.actCopyUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (SelectedNode <> nil) and
    (TCustomTreeItem(SelectedNode.Data).ItemType in [tiMacros, tiReport,
    tiVBClass, tiSF]);
end;

procedure TdfPropertyTree.DestroyWnd;
begin
  CancelCopy;
  inherited;
end;

procedure TdfPropertyTree.CancelCopy;
begin
  if FCopyNode <> nil then
  begin
    if (TCustomTreeItem(FCopyNode.Data).EditorFrame <> nil) and
      not TCustomTreeItem(FCopyNode.Data).EditorFrame.Visible then
    begin
      TBaseFrame(TCustomTreeItem(FCopyNode.Data).EditorFrame).Free;
      TCustomTreeItem(FCopyNode.Data).EditorFrame := nil;
    end;

    FCopyNode := nil;
  end;
end;

procedure TdfPropertyTree.actCopyExecute(Sender: TObject);
var
  Node: TTreeNode;
  EditorFrame: TFrame;
  FrameFound: Boolean;
begin
//  CancelCopy;
//  FCopyNode := SelectedNode;
//  TfrmGedeminProperty(DockForm).ShowFrame(TCustomTreeItem(FCopyNode.Data), False);
//  FCut := False;

  Node := SelectedNode;
  if Node = nil then
    Exit;

  EditorFrame := TCustomTreeItem(Node.Data).EditorFrame;
  FrameFound := EditorFrame <> nil;

  if not FrameFound then
    TfrmGedeminProperty(DockForm).ShowFrame(TCustomTreeItem(Node.Data), False);
  try
    EditorFrame := TCustomTreeItem(Node.Data).EditorFrame;
    if EditorFrame = nil then
      Exit;

    if (EditorFrame as TBaseFrame).Modify then
      raise Exception.Create(dfNoSaveError);

    TBaseFrame(EditorFrame).CopyObject;
  finally
    if not FrameFound then
      FreeAndNil(EditorFrame);
  end;

  FCut := False;
end;

procedure TdfPropertyTree.actCutExecute(Sender: TObject);
begin
  CancelCopy;
  FCopyNode := SelectedNode;
  TfrmGedeminProperty(DockForm).ShowFrame(TCustomTreeItem(FCopyNode.Data), False);
  FCut := True;
end;

procedure TdfPropertyTree.actPasteUpdate(Sender: TObject);
var
  Dest: TCustomTreeItem;
begin
  if not actAddItem.Enabled then
  begin
    TAction(Sender).Enabled := False;
    Exit;
  end;

  Dest := nil;
  if SelectedNode <>  nil then
    Dest := TCustomTreeItem(SelectedNode.Data);

{  TAction(Sender).Enabled := (FCopyNode <> nil) and (Dest <> nil) and
    (TCustomTreeItem(FCopyNode.Data).EditorFrame <> nil) and
    ((not FCut and dfClipboard.CanMakePasteObject(Dest)));
    }
  TAction(Sender).Enabled := (Dest <> nil) and (not FCut) and
    dfClipboard.CanMakePasteObject(Dest);
end;

procedure TdfPropertyTree.actPasteExecute(Sender: TObject);
var
  TreeItem: TCustomTreeItem;
begin
  case dfClipboard.ObjectType of
    tiSF:
      TreeItem := AddSFItem;
    tiMacros:
      TreeItem := AddMacrosItem;
    tiReport:
      TreeItem := AddReportItem;
    tiVBClass:
      TreeItem := AddVBClassItem;
    else
      Exit;
  end;
  if TreeItem <> nil then
  begin
    try
      TBaseFrame(TreeItem.EditorFrame).PasteObject;
      TBaseFrame(TreeItem.EditorFrame).Modify := True;
    except
      TBaseFrame(TreeItem.EditorFrame).ShowDeleteQuestion := False;
      TBaseFrame(TreeItem.EditorFrame).Delete;
      raise;
    end;
  end;


 { Dest := TCustomTreeItem(SelectedNode.Data);
  if FCut then
  begin
    TreeItem := TBaseFrame(TCustomTreeItem(FCopyNode.Data).EditorFrame).Move(Dest);
    if SelectedNode.TreeView <> FCopyNode.TreeView then
    begin
      if (SelectedNode.HasChildren and (SelectedNode.Count <> 0)) or
        (not SelectedNode.HasChildren) then
      begin
        Node := TTreeView(SelectedNode.TreeView).Items.AddChild(SelectedNode, TreeItem.Name);
        Node.Data := TreeItem;
        TreeItem.Node := Node;
        TBaseFrame(TCustomTreeItem(Node.Data).EditorFrame).Node := Node;
      end;
      Node := FCopyNode;
      CancelCopy;
      Node.Data := nil;
      Node.Destroy;
    end else
    begin
      if (SelectedNode.HasChildren and (SelectedNode.Count <> 0)) or
        (not SelectedNode.HasChildren) then
        FCopyNode.MoveTo(SelectedNode, naAddChild);
      CancelCopy;
      FCopyNode := nil;
    end;
  end else
  begin
//    TreeItem := TBaseFrame(TCustomTreeItem(FCopyNode.Data).EditorFrame).CopyObject(Dest);
    if (SelectedNode.HasChildren and (SelectedNode.Count <> 0)) or
      (not SelectedNode.HasChildren) then
    begin
      Node := TTreeView(SelectedNode.TreeView).Items.AddChild(SelectedNode, TreeItem.Name);
      Node.Data := TreeItem;
      TreeItem.Node := Node;
    end;
    CancelCopy;
    FCopyNode := nil;
  end;
  }
end;

procedure TdfPropertyTree.actEditExecute(Sender: TObject);
begin
  tvClassesDblClick(nil);
end;

procedure TdfPropertyTree.actEditUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled :=
    Assigned(SelectedNode) and
    ((TCustomTreeItem(SelectedNode.Data).ItemType in [tiMacros,
    tiReport, tiConst, tiVBClass, tiSF, tiGlobalObject, tiEvent, tiMethod, tiPrologSF]) and
    (TCustomTreeItem(SelectedNode.Data).ID > 0));
end;

{ TdfClipboard }

function TdfClipboard.CanMakePasteObject(
  TreeItem: TCustomTreeItem): Boolean;
begin
  Result := False;
  case FObjectType of
    tiSF:
      if TreeItem.ItemType in [tiSF, tiSFFolder] then
        Result := True;
    tiMacros:
      if TreeItem.ItemType in [tiMacros, tiMacrosFolder] then
        Result := True;
    tiReport:
      if TreeItem.ItemType in [tiReport, tiReportFolder] then
        Result := True;
    tiVBClass:
      if TreeItem.ItemType in [tiVBClass, tiVBClassFolder] then
        Result := True;
    tiPrologSF:
      if TreeItem.ItemType in [tiPrologSF, tiPrologSFFolder] then
        Result := True;    
  end;
end;

constructor TdfClipboard.Create;
begin
  FObjectStream := TMemoryStream.Create;
  FObjectType := tiUnknown;
end;

destructor TdfClipboard.Destroy;
begin
  FObjectStream.Free;
  
  inherited;
end;

procedure TdfClipboard.FillClipboard(const Stream: TStream;
  ObjectType: TTreeItemType);
begin
  FObjectStream.Size := 0;
  FObjectStream.LoadFromStream(Stream);
  FObjectType := ObjectType;
end;

constructor TdfPropertyTree.Create(AOwner: TComponent);
const
  dfFoundError = 'Можно загрузить только один %s.';
begin
  if dfPropertyTree <> nil then
    raise Exception.Create(Format(dfFoundError, [dfPropertyTree.Caption]));
    
  inherited;

  dfPropertyTree := Self;

  FdfClipboard := TdfClipboard.Create;
end;

destructor TdfPropertyTree.Destroy;
begin
  if FdfClipboard <> nil then
    FdfClipboard.Free;
  inherited;
  dfPropertyTree := nil;
end;

function TdfPropertyTree.DoFindNext(ANode: TTreeNode): TTreeNode;
var
  N, Node: TTreeNode;
  Index: Integer;
  C: TCursor;
begin
  Result := nil;
  Node := ANode;
  Assert(Node <> nil, 'sdfsd');

  C := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    N := Node;
    Index := 0;

    while N <> nil do
    begin
      Result := DoFindNode(N, Index, sdBelow);

      if Result <> nil then Exit;

      Index := N.Index + 1;
      if N.Parent <> nil then
        N := N.Parent
      else
      begin
        N := N.GetNextSibling;
        while N <> nil do
        begin
          if ((frWholeWord in FSearchOptions) and (AnsiUpperCase(N.Text) = FSearchString)) or
            (not (frWholeWord in FSearchOptions) and (Pos(FSearchString, AnsiUpperCase(N.Text)) > 0)) then
          begin
            Result := N;
            Exit;
          end;

          Result := DoFindNode(N, 0, sdBelow);
          if Result <> nil then Exit;
          N := N.GetNextSibling;
        end;
      end;
    end;

  finally
    Screen.Cursor := C;
  end;
end;

procedure TdfPropertyTree.FindDialogFind(Sender: TObject);
var
  Node: TTreeNode;
  T: TDateTime;
begin
  T := Now;
  Node := nil;
  FSearchString := AnsiUpperCase(FindDialog.FindText);
  FSearchOptions := FindDialog.Options;
  if (ActiveTree <> nil) then
  begin
    if ActiveTree.Selected <> nil then
    begin
      Node := DoFindNext(ActiveTree.Selected);
      if (Node = nil) and (ActiveTree.Items.Count > 0) then
        Node := DoFindNext(ActiveTree.Items[0]);
    end else
      if ActiveTree.Items.Count > 0 then
        Node := DoFindNext(ActiveTree.Items[0]);

    if Node <> nil then
    begin
      Expand(Node.Parent);
      Node.Selected := True;
    end else
    begin
      MessageBox(Handle,
        PChar(Format(MSG_SEACHING_TEXT + FSearchString + MSG_NOT_FIND + ''#13#10'Время поиска: %d сек.',
          [Round((Now - T) * 24 * 60 * 60)])),
        'Внимание',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);

    end;
  end;
end;

procedure TdfPropertyTree.actFindUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := ActiveTree <> nil;
end;

procedure TdfPropertyTree.actFindExecute(Sender: TObject);
begin
  FindDialog.Execute
end;

function TdfPropertyTree.DoFindNode(ANode: TTreeNode; Index: Integer;
  SearchDir: TSearchDir): TTreeNode;
var
  I: Integer;
  B, E: Integer;
  Allow: Boolean;
  N: TTreeNode;
begin
  Result := nil;
  tvClassesExpanding(ANode.TreeView, ANode, Allow);

  B := 0;
  E := ANode.Count;

  if SearchDir = sdBelow then
    B := Index
  else
    E := Index;

  if (E > 0) and (B <> E) then
  begin
    N := ANode.Item[B];

    for I := B to E - 1 do
    begin
      if ((frWholeWord in FSearchOptions) and (AnsiUpperCase(N.Text) = FSearchString)) or
        (not (frWholeWord in FSearchOptions) and (Pos(FSearchString, AnsiUpperCase(N.Text)) > 0)) then
      begin
        Result := N;
      end else
      begin
        Result := DoFindNode(N, 0, sdBelow);
      end;
      if Result <> nil then Exit;
      N := N.GetNextSibling;
    end;
  end;
end;

procedure TdfPropertyTree.GoToClassMethods(AClassName, ASubType: string);
var
  C: TClass;
  i: integer;
begin
  C:= GetClass(AClassName);
  if not Assigned(C) then Exit;
  GoToClassMethods(C, ASubType);
  i:= cbObjectList.Items.IndexOf('APPLICATION');
  if i > -1 then begin
    cbObjectList.ItemIndex:= i;
    cbObjectListChange(cbObjectList);
  end;
end;

procedure TdfPropertyTree.GoToClassMethods(AClass: TClass;
  ASubType: string);
var
  PTN, TN: TTreeNode;
begin
  if not AClass.InheritsFrom(TgdcBase) and not AClass.InheritsFrom(TgdcCreateableForm) then Exit;
  if not Assigned(GetPageByObjID(OBJ_APPLICATION)) then Exit;

  PTN := GetPageByObjID(OBJ_APPLICATION).ClassesRootNode;

  TN:= FindNodeByClass(AClass, ASubType, PTN);
  if Assigned(TN) then begin
    TN.TreeView.Selected:= TN;
    Expand(TN);
  end;
end;

function TdfPropertyTree.FindNodeByClass(AClass: TClass; ASubType: string; APTN: TTreeNode): TTreeNode;
var
  TN: TTreeNode;
  TI: TGDCClassTreeItem;
  C: TClass;
begin
  Result:= nil;

  ASubType := StringReplace(ASubType, '$', '_', [rfReplaceAll]);

  if not Assigned(AClass) or not Assigned(APTN) then
    Exit;

  try
    Expand(APTN);
    TN:= APTN.GetFirstChild;

    while Assigned(TN) do
    begin
      TI:= TGDCClassTreeItem(TN.Data);
      if not Assigned(TI) then begin
        TN:= APTN.GetNextChild(TN);
        Continue;
      end;

      if not Assigned(TI.TheClass) then begin
        TN:= APTN.GetNextChild(TN);
        Continue;
      end;

      C:= TI.TheClass.Class_Reference;
      if not Assigned(C) then begin
        TN:= APTN.GetNextChild(TN);
        Continue;
      end;

      if (C = AClass) and (TI.SubType = ASubType) then begin
        Result:= TN;
        Exit;
      end else if (TI.ItemType = tiGDCClass) and AClass.InheritsFrom(C) and (TI.SubType = '') then
      begin
        Result:= FindNodeByClass(AClass, ASubType, TN);
        Exit;
      end
      else
        TN:= APTN.GetNextChild(TN);
    end;

  except
  end;
end;

procedure TdfPropertyTree.actClassInfoUpdate(Sender: TObject);
begin
  actClassInfo.Enabled := (SelectedNode <> nil)
    and (SelectedNode.Data <> nil)
    and (TCustomTreeItem(SelectedNode.Data).ItemType = tiGDCClass)
    and (TgdcClassTreeItem(SelectedNode.Data).TheClass <> nil)
    and (TgdcClassTreeItem(SelectedNode.Data).TheClass.Class_Reference <> nil);
end;

procedure TdfPropertyTree.actClassInfoExecute(Sender: TObject);
var
  C: CgdcBase;
  F: TCustomForm;
  SS: String;
begin
  C := nil;
  with TdlgClassInfo.Create(Application) do
  try
    lblClassName.Caption := TgdcClassTreeItem(SelectedNode.Data).TheClass.Class_Name;

    if Pos('USR_', TgdcClassTreeItem(SelectedNode.Data).TheClass.SubType) = 1 then
      SS := StringReplace(TgdcClassTreeItem(SelectedNode.Data).TheClass.SubType, 'USR_', 'USR$', [])
    else
      SS := TgdcClassTreeItem(SelectedNode.Data).TheClass.SubType;

    lblSubType.Caption := SS;
    lblParentClass.Caption := TgdcClassTreeItem(SelectedNode.Data).TheClass.Class_Reference.ClassParent.ClassName;

    if TgdcClassTreeItem(SelectedNode.Data).TheClass.Class_Reference.InheritsFrom(TgdcBase) then
    begin
      C := CgdcBase(TgdcClassTreeItem(SelectedNode.Data).TheClass.Class_Reference);
      lblMainTable.Caption := C.GetListTable(SS);
      lblName.Caption := C.GetDisplayName(SS);
    end;

    if ShowModal = mrYes then
    begin
      if C <> nil then
      begin
        F := C.CreateViewForm(Application, '', SS);
        if F <> nil then
          F.Show
        else
          MessageBox(0,
            'Для данного класса форма просмотра не определена.',
            'Внимание',
            MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      end;
    end;
  finally
    Free;
  end;
end;

end.
