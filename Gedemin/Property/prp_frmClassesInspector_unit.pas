{++

  Copyright (c) 2001-2015 by Golden Software of Belarus

  Module

    prp_frmClassesInspector_unit.pas

  Abstract

    Gedemin project. Inspector for Delphi, user form and VB classes.

  Author

    Dubrovnik Alexander

  Revisions history

    1.00    03.01.03    DAlex        Initial version.
    1.10    20.01.03    DAlex        .
--}

unit prp_frmClassesInspector_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, gdcOLEClassList, TB2Dock, TB2Toolbar, StdCtrls, gd_KeyAssoc,
  TB2Item, ActnList, Menus, ToolWin, ExtCtrls, ImgList, prp_DOCKFORM_unit,
  Buttons, contnrs, gd_Createable_Form, clipbrd, gd_ClassList;

const
  NoShowProp =
    'QueryInterface'#13#10 +
    'AddRef'#13#10 +
    'Release'#13#10 +
    'GetTypeInfoCount'#13#10 +
    'GetTypeInfo'#13#10 +
    'GetIDsOfNames'#13#10 +
    'Invoke'#13#10 +
    '_NewEnum'#13#10 +
    'Self';

  cnComponent = 'Компоненты';
  cnHierarchy = 'Иерархия';
  cnMethods   = 'Методы';
  cnProperty  = 'Свойства';

  pdClassRef = 'class';
  pdTreeNode = 'node';

type
  TciInsertCurrentText =  procedure (const Text: String) of object;

type
  TciItemType = (ciUnknown, ciParentTypeFolder, ciStClass, ciFrmClass, ciGdcClass,
    ciVBClass, ciUserForm, ciVBModule, ciGlObject, ciGlObjMetFolder,
    ciHierFolder, ciMethodFolder, ciPropertyFolder, ciCompFolder, ciHierClass,
    ciMethod, ciMethodGet, ciPropertyR, ciPropertyW, ciPropertyRW, ciVBProp,
    ciComponent, ciInterface);

  TRefDateType = (rdNode, rdClass);

  TfrmClassesInspector = class;
  TResList = class;

  TCurrentModule = record
    Name: String;
    ClassRef: TClass;
  end;

  TInspectorItem = class
  private
    FData: Pointer;
    FItemType: TciItemType;
    FDescription: String;
    procedure SetData(const Value: Pointer);
    procedure SetItemType(const Value: TciItemType);
    procedure SetDescription(const Value: String);

  public
    constructor Create(const RegList: TObjectList); virtual;

    property ItemType: TciItemType read FItemType write SetItemType;
    property ItemData: Pointer read FData write SetData;
    property Description: String read FDescription write SetDescription;
  end;

  TClassItem = class(TInspectorItem)
  public
    ComponentNode: TTreeNode;
    HierarchyNode: TTreeNode;
    MethodsNode: TTreeNode;
    PropertyNode: TTreeNode;

  end;

  TWithResultItem = class(TClassItem)
  public
    ResultNodeRef: TTreeNode;
    ResultClassRef: TClass;
    ResultTypeName: String;
    NodeText: String;

  end;

  TParamObject = class;

  TMethodItem = class(TWithResultItem)
  public
    ParamList: TObjectList;

    constructor Create(const RegList: TObjectList); override;
    destructor  Destroy; override;

    function  GetCount: Integer;
    function  GetParam(const Index: Integer): TParamObject;
    function  IndexOfType(const TypeName: String): Integer;

    procedure  AddParam(const TypeName: String; const ClassRef: TClass;
      NodeRef: TTreeNode);
  end;

  TParamObject = class(TObject)
    TypeName: String;
    ClassRef: TClass;
    NodeRef: TTreeNode;
  end;

  IprpClassesFrm = interface
    function GetItemList: TObjectList;
    function GetClassesTree: TTreeView;
    function GetLibArray: TResList;
    function GetInterfacesNode: TTreeNode;
    function GetClassesInspector: TfrmClassesInspector;
    function IsShowInherited: boolean;
  end;

  IprpClassesInspector = interface
    procedure AddDelphiClassInList(const ClassRef: Pointer; const DataType: TRefDateType;
      const ClassGUID: TGUID; const prpClassesFrm: IprpClassesFrm);

    procedure AddItemsForDelphiClass(Node: TTreeNode; const ClassInterface: IUnknown;
      const ClassGUID: TGUID; const prpClassesFrm: IprpClassesFrm);
    procedure AddItemsByDispath(Node: TTreeNode; const ClassInterface: IDispatch; const prpClassesFrm: IprpClassesFrm);

    procedure CreateHierarchyNode(Node: TTreeNode; const ClassName: String;
      const BeginWithParent: Boolean; const prpClassesFrm: IprpClassesFrm);
    procedure Clear;
    procedure ClearGl_VBClasses;
    procedure CreateVBClasses(const prpClassesFrm: IprpClassesFrm);
    procedure CreateLoc_VBClasses(const prpClassesFrm: IprpClassesFrm);
    procedure FillStGlobalObjects(const ObjectNode, MethodNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);
    procedure FillVBGlobalObjects(const ObjectNode, MethodNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);
    procedure FillUsGlobalObjects(const ObjectNode, MethodNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);
    procedure FillVBClass(const VBClassNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);

    procedure ShowHelpByGUIDString(const GUIDString: String);

    procedure SetClassDescription(Node: TTreeNode; const ClassInterface: IUnknown;
      const ClassGUID: TGUID);

    procedure SetFrmClassesInspector(const Frm: TfrmClassesInspector);
  end;

  TResRecord = record
    ClassRef: Pointer;
    DataType: TRefDateType;
  end;

  // Хранит инф-цию о типах с одним GUID.D1
  TResItem = class
  private
    FResRecord: TResRecord;
    FRefGUID: TGUID;
    FInsideResItem: TResItem;

    function CompareGUID(GUID1, GUID2: TGUID): Boolean;
    function GetResRecord(RefGUID: TGUID): TResRecord;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure AddResRef(const ClassRef: Pointer; const DataType: TRefDateType;
      const ClassGUID: TGUID);
    property ResRecord[RefGUID: TGUID]: TResRecord read GetResRecord; default;
  end;

  // Список хранит ссылку на класс или нод по GUID
  // Для каждого GUID.D1 создается свой итем.
  // Если для нескольких GUID поле D1 одинакое, то за обрадотку
  // этой ситуации отвечает итем класса TResItem
  TResList = class(TObject)
  private
    FResLibArray: TgdKeyObjectAssoc;
  public
    constructor Create;
    destructor  Destroy; override;

    function  GetRef(const RefGUID: TGUID): TResRecord;
    procedure AddRef(const ClassRef: Pointer; const DataType: TRefDateType;
      const ClassGUID: TGUID);
    procedure Clear;
  end;

  TfrmClassesInspector = class(TDockableForm, IprpClassesFrm)
    sbCurrentNode: TStatusBar;
    actInsertCurrentItem: TAction;
    actCollapse: TAction;
    actExpand: TAction;
    pcMain: TPageControl;
    tsClasses: TTabSheet;
    tsSearch: TTabSheet;
    tvClassesInsp: TTreeView;
    mmDescription: TMemo;
    pnlSearch: TPanel;
    actSearch: TAction;
    Panel1: TPanel;
    actGotoSearch: TAction;
    Splitter1: TSplitter;
    pnlSearchClasses: TPanel;
    lbClasses: TListBox;
    lblClasses: TLabel;
    Splitter2: TSplitter;
    pnlSearchWords: TPanel;
    lbWords: TListBox;
    lblWords: TLabel;
    Panel2: TPanel;
    edtSearch: TEdit;
    Label1: TLabel;
    cbWholeWord: TCheckBox;
    btnSearch: TButton;
    btnGo: TButton;
    btnRefresh: TSpeedButton;
    cbClasses: TComboBox;
    btnGoBack: TSpeedButton;
    alMain2: TActionList;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    actAddCOMServ: TAction;
    actCopyCurrentItem: TAction;
    N6: TMenuItem;
    chkShowInherited: TCheckBox;
    procedure actInsertCurrentItemExecute(Sender: TObject);
    procedure TBItem1Click(Sender: TObject);
    procedure tvClassesInspChange(Sender: TObject; Node: TTreeNode);
    procedure tvClassesInspExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure tvClassesInspDblClick(Sender: TObject);
    procedure tvClassesInspCompare(Sender: TObject; Node1,
      Node2: TTreeNode; Data: Integer; var Compare: Integer);
    procedure actCollapseExecute(Sender: TObject);
    procedure tvClassesInspChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure tvClassesInspAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure actExpandExecute(Sender: TObject);
    procedure tsSearchShow(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure lbWordsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbWordsDblClick(Sender: TObject);
    procedure btnGoBackClick(Sender: TObject);
    procedure lbClassesDblClick(Sender: TObject);
    procedure actGotoSearchExecute(Sender: TObject);
    procedure lbWordsClick(Sender: TObject);
    procedure tvClassesInspCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure pmMain2Popup(Sender: TObject);
    procedure tvClassesInspKeyPress(Sender: TObject; var Key: Char);
    procedure btnRefreshClick(Sender: TObject);
    procedure cbClassesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbClassesDblClick(Sender: TObject);
    procedure actStayOnTopExecute(Sender: TObject);
    procedure FormEndDock(Sender, Target: TObject; X, Y: Integer);
    procedure actCopyCurrentItemExecute(Sender: TObject);
    procedure chkShowInheritedClick(Sender: TObject);
  private
    FIsTreeCreated: Boolean;
//    FNoShowList: TStringList;
    FDelphiClassesNode: TTreeNode;
    FgdcClassesNode: TTreeNode;
    FfrmClassesNode: TTreeNode;
    FVBClassesNode: TTreeNode;
    FUserFromNode: TTreeNode;
    FGlObjectNode: TTreeNode;
    FStGlObjectNode: TTreeNode;
    FUserGlObjectNode: TTreeNode;
    FGlMethodNode: TTreeNode;
    FStGlMethodNode: TTreeNode;
    FVBGlMethodNode: TTreeNode;
    FInterfacesNode: TTreeNode;
    FSearchActivate: Boolean;
    FJumpList: TStrings;
    FGUIDArray: TgdKeyStringAssoc;
    FLibArray: TResList;

    FOnInsertCurrentText: TciInsertCurrentText;
    FHLNodeList: TList;
    FCurrentModule: TCurrentModule;
    FItemList: TObjectList;

    procedure WMShowWindow(var Message: TWMShowWindow); message WM_SHOWWINDOW;

    function GetItemList: TObjectList;
    function GetClassesTree: TTreeView;
    function GetLibArray: TResList;
    function GetInterfacesNode: TTreeNode;
    function GetClassesInspector: TfrmClassesInspector;
    function IsShowInherited: boolean;

    procedure pmMainItemClick(Sender: TObject);
    procedure CopyChildNode(const TreeNodes: TTreeNodes;
      const DestNode, SourceNode: TTreeNode);
    procedure GotoCbClass;

    procedure ClearSearchResurs;
    procedure MarkChild(const Node: TTreeNode);
    procedure Reset;
    procedure Refresh;



    procedure AddPropMethod(const Node: TTreeNode);
    procedure AddStandartComponent(var CompNode: TTreeNode; const Node: TTreeNode;
      const FrmClassName: String);
    procedure AddComponentName(var CompNode: TTreeNode; const Node: TTreeNode;
      CompList: TStrings);

    procedure FillClassesNode(const Node: TTreeNode);
    procedure FillFormNode(const Node: TTreeNode);
    procedure GotoOnClass(const AClass: TClass);
    function  GetClassNode(const AClass: TClass): TTreeNode;

    procedure InsertCurrentText(const Text: String);

    procedure CreateVBClasses;

    procedure CreateFullTree;

    procedure FillClassesTree;
    procedure FillVBClassesTree;
    procedure FillGlObjectsTree;
    procedure FillUserFormClassesTree;

    procedure AddItemsForDelphiClass(Node: TTreeNode; const ClassInterface: IUnknown;
      const ClassGUID: TGUID);
    procedure SetOnInsertCurrentText(const Value: TciInsertCurrentText);
    procedure SetCurrentModule(const Value: TCurrentModule);

    function BuildFrmClassTree(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;
    function BuildGdcClassTree(ACE: TgdClassEntry; AData1: Pointer;
      AData2: Pointer): Boolean;

    property CurrentModule: TCurrentModule read FCurrentModule write SetCurrentModule;

  protected
    procedure CreateWindowHandle(const Params: TCreateParams); override;

  public
    FDispArray: TgdKeyIntAssoc;

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    class function IsDocked: Boolean;

    procedure SetModuleClass(const ModuleName: string;
      const ModuleClass: TClass);
    
    property DelphiClassesNode: TTreeNode read FDelphiClassesNode;
    property frmClassesNode: TTreeNode read FfrmClassesNode;
    property gdcClassesNode: TTreeNode read FgdcClassesNode;
    property VBClassesNode: TTreeNode read FVBClassesNode;
    property UserFromNode: TTreeNode read FUserFromNode;
    property GlObjectNode: TTreeNode read FGlObjectNode;

//    property NoShowList: TStringList read FNoShowList;

    property OnInsertCurrentText: TciInsertCurrentText read FOnInsertCurrentText
      write SetOnInsertCurrentText;
  end;

  function AddItemData(Node: TTreeNode; const NodeType: TciItemType;
    const Description: String; const prpClassesFrm: IprpClassesFrm): TInspectorItem; overload;
  function AddItemData(Node: TTreeNode; const NodeType: TciItemType;
    const Description: String; const Data: Pointer;
    const prpClassesFrm: IprpClassesFrm): TInspectorItem; overload;
  procedure SetCorrectType(Node: TTreeNode; const NodeType: TciItemType);

  function GetItemType(Node: TTreeNode): TciItemType;

var
  frmClassesInspector: TfrmClassesInspector;
  prpClassesInspector: IprpClassesInspector;

implementation

uses
  IBSQL, IBDatabase, gdcBaseInterface, gd_directories_const,
  Storages, gsStorage, dmImages_unit, gsStorage_CompPath, registry,
  prp_frmGedeminProperty_Unit, {HashUnit,} gd_i_ScriptFactory, gdcBase, gdc_createable_form
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  cInsFrmName = 'frmClassesInspector';

type
  TCrackCustomTreeView = class(TCustomTreeView);
  TCrackCustomListView = class(TCustomListView);
  TCrackPopupMenu = class(TPopupMenu);

{$R *.DFM}

{ Tprp_frmClassesInspector }

procedure TfrmClassesInspector.AddItemsForDelphiClass(Node: TTreeNode;
  const ClassInterface: IUnknown; const ClassGUID: TGUID);
begin
  if Assigned(prpClassesInspector) then
    prpClassesInspector.AddItemsForDelphiClass(Node, ClassInterface, ClassGUID, Self);
end;

constructor TfrmClassesInspector.Create(AOwner: TComponent);
var
  tmpCursor: TCursor;
begin
  Assert(frmClassesInspector = nil, 'Форма может быть только одна.');

  FIsTreeCreated := False;

  inherited;

  //Имя должно быть таким
  Name := cInsFrmName;

  frmClassesInspector := Self;

  FItemList := TObjectList.Create(True);

  btnGoBack.Enabled := False;

  tmpCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    FDispArray := TgdKeyIntAssoc.Create;
    FLibArray := TResList.Create;
    FHLNodeList := TList.Create;
//    FNoShowList := TStringList.Create;
//    FNoShowList.Sorted := True;
//    FNoShowList.Text := NoShowProp;

    if Assigned(prpClassesInspector) then
      prpClassesInspector.SetFrmClassesInspector(Self);

    FJumpList := TStringList.Create;

    FSearchActivate := False;
  finally
    Screen.Cursor := tmpCursor;
  end;
  tvClassesInsp.Enabled := True;

  FGUIDArray := TgdKeyStringAssoc.Create;
end;

procedure TfrmClassesInspector.CreateVBClasses;
begin
  prpClassesInspector.CreateVBClasses(Self);
end;

destructor TfrmClassesInspector.Destroy;
begin
  ClearSearchResurs;
  FGUIDArray.Free;
  FJumpList.Free;
  FHLNodeList.Free;
  FDispArray.Free;
  FLibArray.Free;
  FItemList.Free;

  inherited;
  frmClassesInspector := nil;
end;

function TfrmClassesInspector.BuildFrmClassTree(ACE: TgdClassEntry; AData1: Pointer;
  AData2: Pointer): Boolean;
var
  TreeNode, TmpNode: TTreeNode;
  COMClassItem: TgdcCOMClassItem;
  ClassRef: TClass;
begin
  if not (ACE is TgdFormEntry) then
  begin
    Result := False;
    exit;
  end;

  TreeNode := TTreeNode(AData1^);

  if (ACE <> nil) and (TTreeNode <> nil) and (ACE.SubType = '') then
  begin
    COMClassItem := OLEClassList.FindOLEClassItem(ACE.TheClass);
    if Assigned(COMClassItem) then
    begin
      ClassRef := COMClassItem.DelphiClass;
      TmpNode := tvClassesInsp.Items.AddChild(TreeNode,
        ACE.TheClass.ClassName);
      AddItemData(TmpNode, ciFrmClass, 'Класс стандартной формы', ClassRef, Self);

      if Assigned(prpClassesInspector) then
      begin
        prpClassesInspector.AddDelphiClassInList(ClassRef,
          rdClass, COMClassItem.DispIntf, Self);
        prpClassesInspector.SetClassDescription(TmpNode,
          COMClassItem.TypeLib, COMClassItem.DispIntf);
      end;

      TmpNode.HasChildren := True;
    end;
  end;
  Result := True;
end;

function TfrmClassesInspector.BuildGdcClassTree(ACE: TgdClassEntry; AData1: Pointer;
  AData2: Pointer): Boolean;
var
  TreeNode, TmpNode: TTreeNode;
  COMClassItem: TgdcCOMClassItem;
  ClassRef: TClass;
begin
  TreeNode := TTreeNode(AData1^);

  if (ACE is TgdBaseEntry) and (TTreeNode <> nil) and (ACE.SubType = '') then
  begin
    COMClassItem := OLEClassList.FindOLEClassItem(TgdBaseEntry(ACE).gdcClass);
    if Assigned(COMClassItem) then
    begin
      ClassRef := COMClassItem.DelphiClass;
      TmpNode := tvClassesInsp.Items.AddChild(TreeNode,
        ACE.TheClass.ClassName);
      AddItemData(TmpNode, ciGdcClass, 'Бизнес-класс', ClassRef, Self);

      if Assigned(prpClassesInspector) then
      begin
        prpClassesInspector.AddDelphiClassInList(ClassRef,
          rdClass, COMClassItem.DispIntf, Self);
        prpClassesInspector.SetClassDescription(TmpNode,
          COMClassItem.TypeLib, COMClassItem.DispIntf);
      end;

      TmpNode.HasChildren := True;
    end;
  end;
  Result := True;
end;

procedure TfrmClassesInspector.FillClassesTree;
var
  i: Integer;
  TreeNode, TmpNode: TTreeNode;
  COMClassItem: TgdcCOMClassItem;
  ClassRef: TClass;
begin
  TreeNode := FfrmClassesNode;
  gdClassList.Traverse(TgdcCreateableForm, '', BuildFrmClassTree, @TreeNode, nil);
  TreeNode.AlphaSort;

  TreeNode := FgdcClassesNode;
  gdClassList.Traverse(TgdcBase, '', BuildGdcClassTree, @TreeNode, nil);
  TreeNode.AlphaSort;

  TreeNode := FDelphiClassesNode;
  for i := 0 to OLEClassList.Count - 1 do
  begin
    COMClassItem := TgdcCOMClassItem(OLEClassList.ValuesByIndex[i]);
    if cbClasses.Items.IndexOf(
      COMClassItem.DelphiClass.ClassName) > -1 then
      Continue;

    ClassRef := TClass(OLEClassList.Keys[i]);
    TmpNode := tvClassesInsp.Items.AddChild(TreeNode,
      TClass(OLEClassList.Keys[i]).ClassName);
    AddItemData(tmpNode, ciStClass,
      'Стандартный класс ' + tmpNode.Text + '.',ClassRef, Self);

    if Assigned(prpClassesInspector) then
    begin
      prpClassesInspector.AddDelphiClassInList(ClassRef,
        rdClass, COMClassItem.DispIntf, Self);
      prpClassesInspector.SetClassDescription(TmpNode,
        COMClassItem.TypeLib, COMClassItem.DispIntf);
    end;

    TmpNode.HasChildren := True;
  end;
  TreeNode.AlphaSort;
end;

procedure TfrmClassesInspector.actInsertCurrentItemExecute(
  Sender: TObject);
begin
  if tvClassesInsp.Selected <> nil then
    InsertCurrentText(tvClassesInsp.Selected.Text);
end;

procedure TfrmClassesInspector.actCopyCurrentItemExecute(Sender: TObject);
begin
  if tvClassesInsp.Selected <> nil then
    Clipboard.AsText:= tvClassesInsp.Selected.Text;
end;

procedure TfrmClassesInspector.InsertCurrentText(const Text: String);
begin
  if Assigned(FOnInsertCurrentText) then
    FOnInsertCurrentText(Text);
end;

procedure TfrmClassesInspector.SetOnInsertCurrentText(
  const Value: TciInsertCurrentText);
begin
  FOnInsertCurrentText := Value;
end;

procedure TfrmClassesInspector.TBItem1Click(Sender: TObject);
begin
  tvClassesInsp.Items.Clear;
  CreateFullTree;
end;

procedure TfrmClassesInspector.CreateFullTree;
var
  tmpCursor: TCursor;
begin
  tmpCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    cbClasses.Items.Clear;
    mmDescription.Clear;
    lbWords.Items.Clear;
    lbClasses.Items.Clear;
    if prpClassesInspector <> nil then
      prpClassesInspector.Clear;

    FDelphiClassesNode := tvClassesInsp.Items.Add(nil, 'Классы стандартные');
    FDelphiClassesNode.Data := Pointer(1);
    AddItemData(FDelphiClassesNode, ciParentTypeFolder, 'Классы стандартные.', Self);
    FfrmClassesNode := tvClassesInsp.Items.Add(nil, 'Классы стандартных форм');
    AddItemData(FfrmClassesNode, ciParentTypeFolder, 'Классы стандартных форм.', Self);
    FgdcClassesNode := tvClassesInsp.Items.Add(nil, 'Классы бизнес объектов');
    AddItemData(FgdcClassesNode, ciParentTypeFolder, 'Классы бизнес объектов.', Self);
    FVBClassesNode := tvClassesInsp.Items.Add(nil, 'Классы VB');
    AddItemData(FVBClassesNode, ciParentTypeFolder, 'Классы VB.', Self);
    FVBClassesNode.HasChildren := True;
    FUserFromNode := tvClassesInsp.Items.Add(nil, 'Классы пользовательских форм');
    AddItemData(FUserFromNode, ciParentTypeFolder, 'Классы пользовательских форм.', Self);
    FGlObjectNode := tvClassesInsp.Items.Add(nil, 'Глобальные объекты');
    AddItemData(FGlObjectNode, ciParentTypeFolder, 'Глобальные объекты.', Self);
    FStGlObjectNode := tvClassesInsp.Items.AddChild(FGlObjectNode, 'Стандартные');
    AddItemData(FStGlObjectNode, ciGlObjMetFolder, 'Стандартные глобальные объекты.', Self);
    FUserGlObjectNode := tvClassesInsp.Items.AddChild(FGlObjectNode, 'Пользовательские');
    AddItemData(FUserGlObjectNode, ciGlObjMetFolder, 'Пользовательские глобальные объекты.',Self);
    FGlMethodNode := tvClassesInsp.Items.Add(nil, 'Глобальные методы');
    AddItemData(FGlMethodNode, ciParentTypeFolder, 'Глобальные методы.', Self);
    FStGlMethodNode := tvClassesInsp.Items.AddChild(FGlMethodNode, 'Стандартные');
    AddItemData(FStGlMethodNode, ciGlObjMetFolder, 'Стандартные глобальные методы.',Self);
    FVBGlMethodNode := tvClassesInsp.Items.AddChild(FGlMethodNode, 'VBScript');
    AddItemData(FVBGlMethodNode, ciGlObjMetFolder, 'Глобальные методы VBScript.', Self);
    FInterfacesNode:= tvClassesInsp.Items.AddChild(nil, 'Интерфейсы');
    AddItemData(FInterfacesNode, ciParentTypeFolder, 'Интерфейсы.', Self);

    tvClassesInsp.AlphaSort;

    FillClassesTree;
    CreateVBClasses;
    FillUserFormClassesTree;
    FillVBClassesTree;
    FillGlObjectsTree;

    tvClassesInsp.AlphaSort;
  finally
    Screen.Cursor := tmpCursor;
  end;
end;

procedure TfrmClassesInspector.FillUserFormClassesTree;
var
  gsStorageFolder: TgsStorageFolder;
  i: Integer;
  F: TMemoryStream;
  F1: TStringStream;
  S, gdcFrmClassName: String;
  CompList: TStrings;
  CompNode, CurrentUserFrmNode: TTreeNode;
  Sign: String;

begin
  if not Assigned(GlobalStorage) then
    Exit;

  gsStorageFolder := GlobalStorage.OpenFolder(st_ds_NewFormPath);
  if gsStorageFolder <> nil then
  try
    CompList := TStringList.Create;
    F := TMemoryStream.Create;
    try
        for i := 0 to gsStorageFolder.FoldersCount - 1 do
        begin
          F1 := TStringStream.Create('');
          try
            CurrentUserFrmNode :=
              tvClassesInsp.Items.AddChild(FUserFromNode, gsStorageFolder.Folders[i].Name);
            AddItemData(CurrentUserFrmNode, ciUserForm, 'Класс пользовательской формы.', Self);

            gdcFrmClassName := gsStorageFolder.Folders[i].ReadString(st_ds_FormClass);
            prpClassesInspector.CreateHierarchyNode(CurrentUserFrmNode,
              gdcFrmClassName, False, Self);

            gsStorageFolder.Folders[i].ReadStream(st_ds_UserFormDFM, F);
            F.Seek(0, soFromBeginning);
            try
              SetLength(Sign, 3);
              F.Read(Sign[1], 3);
              if Sign = 'TPF' then
              begin
                F.Position := 0;
                ObjectBinaryToText(F, F1);
              end else
              begin
                F1.CopyFrom(F, 0);
              end;

              CompList.Clear;
              S := F1.DataString;
              CompList.Text := S;
              CompNode := nil;
              AddComponentName(CompNode, CurrentUserFrmNode, CompList);
              AddStandartComponent(CompNode, CurrentUserFrmNode, gdcFrmClassName);
            except
              ShowMessage(
                Format('Ошибка считывания пользовательской формы: "%s"',
                [gsStorageFolder.Folders[i].Name]))
            end;
            F.Clear;
          finally
            F1.Free;
          end;
        end;
    finally
      CompList.Free;
      F.Free;
    end;
  finally
    GlobalStorage.CloseFolder(gsStorageFolder);
  end;
  FUserFromNode.AlphaSort;
end;

procedure TfrmClassesInspector.tvClassesInspChange(Sender: TObject;
  Node: TTreeNode);
begin
  sbCurrentNode.SimpleText := Node.Text;
  if (Node.Data <> nil) and (mmDescription <> nil) then
  begin
    try
      mmDescription.Lines.Text := TInspectorItem(Node.Data).Description;
    except
      MessageBox(0,
        'Node.Data содержит ссылку на несуществующий объект.',
        'Внимание',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
      raise;
    end;
  end;
end;

procedure TfrmClassesInspector.tvClassesInspExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
var
  tmpCursor: TCursor;
begin
  tmpCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    if Node.getFirstChild = nil then
    begin
      case GetItemType(Node) of
        ciStClass, ciGdcClass:
          FillClassesNode(Node);
        ciFrmClass:
          FillFormNode(Node);
      end;
      if FHLNodeList.IndexOf(Node) > -1 then
      begin
        MarkChild(Node);
        tvClassesInsp.Refresh;
      end;
      Node.AlphaSort;
    end;

  finally
    Screen.Cursor := tmpCursor;
  end;
end;

procedure TfrmClassesInspector.AddPropMethod(const Node: TTreeNode);
var
  COMClassItem: TgdcCOMClassItem;
  I: Integer;
begin
  if GetItemType(Node) in [ciStClass, ciGdcClass, ciFrmClass] then
    I := Integer(TInspectorItem(Node.Data).ItemData)
  else
    raise Exception.Create('Несоответствие типа узла.');


  COMClassItem := TgdcCOMClassItem(OLEClassList.ValuesByKey[I]);
  if COMClassItem <> nil then
    AddItemsForDelphiClass(Node, COMClassItem.TypeLib, COMClassItem.DispIntf);

  Node.AlphaSort;
end;

procedure TfrmClassesInspector.FillClassesNode(const Node: TTreeNode);
begin
  AddPropMethod(Node);
end;

procedure TfrmClassesInspector.FillFormNode(const Node: TTreeNode);
var
  CompNode: TTreeNode;
begin
  AddPropMethod(Node);
  CompNode := nil;
  AddStandartComponent(CompNode, Node, Node.Text);
end;

procedure TfrmClassesInspector.tvClassesInspDblClick(Sender: TObject);
var
  TmpClass: TClass;
begin
  if tvClassesInsp.Selected <> nil then
    case GetItemType(tvClassesInsp.Selected) of
      ciHierClass:
      begin
        // находим индекс класса компонента в списке
        TmpClass := OLEClassList.GetClass(tvClassesInsp.Selected.Text);
        if TmpClass = nil then
          TmpClass := GetClass(tvClassesInsp.Selected.Text);
        GotoOnClass(TmpClass);
      end;
      ciMethod, ciMethodGet, ciPropertyR, ciPropertyW, ciPropertyRW:
      begin
        with tvClassesInsp.Selected do
          if TWithResultItem(Data).ResultNodeRef <> nil then
          begin
            TWithResultItem(Data).ResultNodeRef.Selected := True;
          end else
            GotoOnClass(TWithResultItem(Data).ResultClassRef);
      end;
      ciComponent:
      begin
        with tvClassesInsp.Selected do
          TmpClass := GetClass(Trim(Copy(Text, Pos(':', Text) + 1, Length(Text))));
        GotoOnClass(TmpClass);
      end;
    end;
end;

procedure TfrmClassesInspector.GotoOnClass(const AClass: TClass);
var
  TmpNode: TTreeNode;
begin
  TmpNode := GetClassNode(AClass);
  if TmpNode <> nil then
    TmpNode.Selected := True;
end;

procedure TfrmClassesInspector.tvClassesInspCompare(Sender: TObject; Node1,
  Node2: TTreeNode; Data: Integer; var Compare: Integer);
begin
  if (Node1.Parent <> nil) and (Node1.Parent.Text <> cnHierarchy) and (Node2 <> nil) then
    Compare := AnsiStrIComp(PChar(Node1.Text), PChar(Node2.Text));
end;

procedure TfrmClassesInspector.AddStandartComponent(
  var CompNode: TTreeNode; const Node: TTreeNode; const FrmClassName: String);
var
  HRsrc, HInst: THandle;
  gdcFullClassName: TgdcFullClassName;
  TmpClass: TClass;
  ResStream: TResourceStream;
  CompList: TStrings;
  StrStream: TStringStream;
  I: Integer;
  tmpNode: TTreeNode;
begin
  gdcFullClassName.SubType := '';
  gdcFullClassName.gdClassName := FrmClassName;
  TmpClass := gdClassList.GetFrmClass(gdcFullClassName.gdClassName);
  if not Assigned(TmpClass) then
    TmpClass := GetClass(FrmClassName);
  if not Assigned(TmpClass) then
    Exit;

  HInst := FindResourceHInstance(FindClassHInstance(TmpClass));
  if HInst = 0 then HInst := HInstance;
  HRsrc := FindResource(HInst, PChar(FrmClassName), RT_RCDATA);
  if HRsrc = 0 then Exit;

  ResStream := TResourceStream.Create(HInst, PChar(FrmClassName), RT_RCDATA);
  try
    CompList := TStringList.Create;
    StrStream := TStringStream.Create('');
    try
      ResStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(ResStream, StrStream);
      CompList.Text := StrStream.DataString;
      AddComponentName(CompNode, Node, CompList);
    finally
      StrStream.Free;
      CompList.Free;
    end;
  finally
    ResStream.Free;
  end;
  TmpClass := TmpClass.ClassParent;
  if TmpClass.InheritsFrom(TCreateableForm) then
  begin
    I := cbClasses.Items.IndexOf(TmpClass.ClassName);
    if I > -1 then
    with TTreeNode(cbClasses.Items.Objects[I]) do
    begin
      tmpNode := getFirstChild;
      if tmpNode <> nil then
      begin
        Expand(True);
        Collapse(True);
      end;
      while (getItemType(tmpNode) <> ciComponent) and (tmpNode <> nil) do
        tmpNode := GetNextChild(tmpNode);
      if tmpNode <> nil then
      begin
        CopyChildNode(tvClassesInsp.Items, CompNode, tmpNode);
      end;
    end;
  end;
end;

procedure TfrmClassesInspector.AddComponentName(var CompNode: TTreeNode;
  const Node: TTreeNode; CompList: TStrings);
var
  AI{, AP}: Integer;
  S: String;
  tmpNode: TTreeNode;
begin
  for AI := 1 to CompList.Count - 1 do
  begin
    S := Trim(CompList[AI]);
    if Pos('object', S) = 1 then
    begin
      if CompNode = nil then
      begin
        CompNode :=
          tvClassesInsp.Items.AddChild(Node, cnComponent);
        AddItemData(CompNode, ciCompFolder,
          'Компоненты формы ' + CompNode.Parent.Text + '.', Self);
      end;
      tmpNode := tvClassesInsp.Items.AddChild(CompNode, Trim(Copy(S, 7, Length(S))));
      AddItemData(tmpNode, ciComponent,
        'Компонент формы ' + tmpNode.Parent.Parent.Text + '.', Self);
    end;
  end;
  if CompNode <> nil then
    CompNode.AlphaSort;
end;

procedure TfrmClassesInspector.actCollapseExecute(Sender: TObject);
var
  tmpCursor: TCursor;
begin
  tmpCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    tvClassesInsp.Enabled := False;
    tvClassesInsp.FullCollapse;
  finally
    Screen.Cursor := tmpCursor;
    tvClassesInsp.Enabled := True;
  end;
end;

procedure TfrmClassesInspector.tvClassesInspChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  if (FJumpList.Count = 0) or ((FJumpList.Count > 0) and
    (TTreeNode(FJumpList.Objects[FJumpList.Count - 1]) <> Node)) then
  begin
    FJumpList.AddObject(Node.Text, Node);
    while FJumpList.Count > 19 do
      FJumpList.Delete(0);
  end;

  if FJumpList.Count > 1 then
    btnGoBack.Enabled := True
  else
    btnGoBack.Enabled := False;
end;

procedure TfrmClassesInspector.tvClassesInspAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
begin
  if FHLNodeList.IndexOf(Node) > -1 then
  begin
    Sender.Canvas.Font.Style := [fsBold];
    Sender.Canvas.Font.Color := clGreen;
  end;
end;

procedure TfrmClassesInspector.SetCurrentModule(
  const Value: TCurrentModule);

  function  GetDelphiClassNode(const DelphiClass: TClass): TTreeNode;
  var
    GI: Integer;
    GClass: TClass;
  begin
    Result := nil;
    GI := -1;
    GClass := DelphiClass;
    while (GI = -1) and (GClass <> nil) do
    begin
      GI := cbClasses.Items.IndexOf(GClass.ClassName);
      if GI > -1 then
      begin
        Result := TTreeNode(cbClasses.Items.Objects[GI]);
        Break;
      end;
      GClass := GClass.ClassParent;
      if GClass = nil then
        Break;
    end;
  end;

  procedure AddAllNode(const AddNode: TTreeNode);
  var
    FANode: TTreeNode;
  begin
    FANode := AddNode;
    FHLNodeList.Add(Pointer(FANode));
    MarkChild(FANode);
    FANode := FANode.Parent;
    while Assigned(FANode) do
    begin
      FHLNodeList.Add(Pointer(FANode));
      FANode := FANode.Parent;
    end;
  end;

  procedure AddAllDelphiClass(const BeginFindNode: TTreeNode;
    const DelphiClass: TClass);
  var
    FANode: TTreeNode;
  begin
    FANode := GetDelphiClassNode(DelphiClass);
    if FANode <> nil then
      AddAllNode(FANode);
  end;

  procedure FindNodeAndAddAll(const BeginFindNode: TTreeNode;
    const FindName: string);
  var
    FANode: TTreeNode;
  begin
    FANode := BeginFindNode.getFirstChild;
    while Assigned(FANode) do
    begin
      if FANode.Text = FindName then
      begin
        AddAllNode(FANode);
        Break;
      end else
        FANode := FfrmClassesNode.GetNextChild(FANode);
    end;
  end;

begin
  if frmClassesInspector = nil then
    Exit;
  if not ((FCurrentModule.Name = Value.Name) and
    (FCurrentModule.ClassRef = Value.ClassRef)) then
  begin
    FCurrentModule := Value;
    FHLNodeList.Clear;
    if FCurrentModule.ClassRef.InheritsFrom(TCreateableForm) then
      AddAllDelphiClass(FfrmClassesNode, FCurrentModule.ClassRef)
    else
      AddAllDelphiClass(FDelphiClassesNode, FCurrentModule.ClassRef);
    //!!!->
    //Шура глянь этот код. Почем то для Application FVBClassesNode был
    //равен nil
    if FVBClassesNode <> nil then
    //!!!<-
      FindNodeAndAddAll(FVBClassesNode, Value.Name);
  end;
end;

procedure TfrmClassesInspector.SetModuleClass(const ModuleName: string;
  const ModuleClass: TClass);
var
  tmpCurrentModule: TCurrentModule;
begin
  tmpCurrentModule.Name := ModuleName;
  tmpCurrentModule.ClassRef := ModuleClass;
  CurrentModule := tmpCurrentModule;
  tvClassesInsp.Refresh;
end;

procedure TfrmClassesInspector.FillVBClassesTree;
begin
  prpClassesInspector.CreateLoc_VBClasses(Self);
end;

procedure TfrmClassesInspector.MarkChild(const Node: TTreeNode);
var
  ChildNode: TTreeNode;
begin
  ChildNode := Node.getFirstChild;
  while Assigned(ChildNode) do
  begin
    FHLNodeList.Add(ChildNode);
    MarkChild(ChildNode);
    ChildNode := Node.GetNextChild(ChildNode);
  end;
end;

procedure TfrmClassesInspector.actExpandExecute(Sender: TObject);
var
  tmpCursor: TCursor;
begin
  tmpCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    tvClassesInsp.Enabled := False;
    tvClassesInsp.FullExpand;
  finally
    Screen.Cursor := tmpCursor;
    tvClassesInsp.Enabled := True;
  end;
  FSearchActivate := True;
end;

procedure TfrmClassesInspector.tsSearchShow(Sender: TObject);
const
  ActStr = 'Активация поиска: ';

  function ExpandAndBack(const ExNode: TTreeNode): boolean;
  var
    ETmpNode: TTreeNode;
    ExpFlag: Boolean;
  begin
    ETmpNode := ExNode.getFirstChild;
    Result:= True;
    while ETmpNode <> nil do begin
      if GetAsyncKeyState(VK_ESCAPE) shr 1 > 0 then begin
        Result:= False;
        Break;
      end;
      if ((TInspectorItem(ETmpNode.Data).ItemType in
        [ciHierFolder, ciMethodFolder, ciPropertyFolder, ciCompFolder])) and
        (ETmpNode.getFirstChild <> nil ) then
        Exit;
{      if ((TInspectorItem(ETmpNode.Data).ItemType in
        [ciStClass, ciFrmClass, ciGdcClass, ciVBClass, ciUserForm])) and
        (ETmpNode.getFirstChild <> nil ) then
        Exit;}




      ExpFlag := ETmpNode.Expanded;
      sbCurrentNode.SimpleText := ActStr + ETmpNode.Text;
      ETmpNode.Expand(False);
//      ETmpNode.Expand(True);
      if not ExpFlag then
        ETmpNode.Collapse(False);
      if not (TInspectorItem(ETmpNode.Data).ItemType in
        [ciStClass, ciFrmClass, ciGdcClass, ciVBClass, ciUserForm]) then
        ExpandAndBack(ETmpNode);

      ETmpNode := ExNode.GetNextChild(ETmpNode);
    end;
  end;

begin
  Application.ProcessMessages;

  if Application.Terminated then
    exit;

  if not FSearchActivate then
  begin
    if not ExpandAndBack(FDelphiClassesNode) then begin
      sbCurrentNode.SimpleText := '';
      pcMain.ActivePage:= tsClasses;
      Exit;
    end;
    if not ExpandAndBack(FgdcClassesNode) then begin
      sbCurrentNode.SimpleText := '';
      pcMain.ActivePage:= tsClasses;
      Exit;
    end;
    if not ExpandAndBack(FfrmClassesNode) then begin
      sbCurrentNode.SimpleText := '';
      pcMain.ActivePage:= tsClasses;
      Exit;
    end;
    if not ExpandAndBack(FVBClassesNode) then begin
      sbCurrentNode.SimpleText := '';
      pcMain.ActivePage:= tsClasses;
      Exit;
    end;
    if not ExpandAndBack(FUserFromNode) then begin
      sbCurrentNode.SimpleText := '';
      pcMain.ActivePage:= tsClasses;
      Exit;
    end;
  end;

  FSearchActivate := True;
  sbCurrentNode.SimpleText := 'Выберите раздел и нажмите "Перейти"';
end;

procedure TfrmClassesInspector.actSearchExecute(Sender: TObject);
var
  I, K, WordIndex: Integer;
  ClList: TStrings;
  tmpNode: TTreeNode;
  FSearchStr: String;
var
  tmpCursor: TCursor;

  procedure CorrectPartition(PartNode: TTreeNode; PartIndex: Integer);
  begin
    if TInspectorItem(PartNode.Data).ItemType = ciVBClass then
    begin
      while (PartNode <> nil) and (PartNode.Data <> nil) and
        (TInspectorItem(PartNode.Data).ItemType <> ciParentTypeFolder) do
      begin
        if TInspectorItem(PartNode.Data).ItemType = ciVBModule then
        begin
          ClList[PartIndex] := ClList[PartIndex] + ' (' + PartNode.Text + ')';
          Break;
        end;
        PartNode := PartNode.Parent;
      end;
    end;
  end;
begin
  tmpCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    ClearSearchResurs;

    FSearchStr := AnsiUpperCase(edtSearch.Text);
    if Length(Trim(FSearchStr)) = 0 then
      Exit;
    for I := 0 to tvClassesInsp.Items.Count - 1 do
    begin
      if (TInspectorItem(tvClassesInsp.Items[I].Data).ItemType <> ciParentTypeFolder) then
      begin
        if (cbWholeWord.Checked and (AnsiUpperCase(tvClassesInsp.Items[I].Text) = FSearchStr)) or
          ((not cbWholeWord.Checked) and (Pos(FSearchStr, AnsiUpperCase(tvClassesInsp.Items[I].Text)) > 0)) then
        begin
          WordIndex := lbWords.Items.IndexOf(tvClassesInsp.Items[I].Text);
          if WordIndex = -1 then
          begin
            ClList := TStringList.Create;
            lbWords.Items.AddObject(tvClassesInsp.Items[I].Text, ClList);
          end else
            begin
              if lbWords.Items.Objects[WordIndex] <> nil then
                ClList := TStrings(lbWords.Items.Objects[WordIndex])
              else
                begin
                  ClList := TStringList.Create;
                  lbWords.Items.Objects[WordIndex] := ClList;
                end;
            end;
          tmpNode := tvClassesInsp.Items[I];

          if TInspectorItem(tmpNode.Data).InheritsFrom(TWithResultItem) and
            (tmpNode.Parent <> nil) and (tmpNode.Parent.Parent <> nil) then
          begin
            K :=  ClList.AddObject(tmpNode.Parent.Parent.Text, tvClassesInsp.Items[I]);
            CorrectPartition(tmpNode.Parent.Parent, K);
          end else
            begin
              while (tmpNode <> nil) and (tmpNode.Data <> nil) and
                (TInspectorItem(tmpNode.Data).ItemType <> ciParentTypeFolder) do
              begin
                if TInspectorItem(tmpNode.Data).ItemType in [ciStClass, ciFrmClass, ciGdcClass,
                  ciVBClass, ciUserForm] then
                begin
                  K :=  ClList.AddObject(tmpNode.Text, tvClassesInsp.Items[I]);

                  CorrectPartition(tmpNode, K);
                  Break;
                end;
                tmpNode := tmpNode.Parent;
              end;
              if ClList.Count = 0 then
              begin
                if tmpNode <> nil then
                  ClList.AddObject(tmpNode.Text, tvClassesInsp.Items[I])
                else
                  lbWords.Items.Delete(WordIndex);
              end;
            end;
        end;
      end;
    end;
    sbCurrentNode.SimpleText := '';
  finally
    Screen.Cursor := tmpCursor;;
  end;
end;

procedure TfrmClassesInspector.ClearSearchResurs;
var
  I: Integer;
begin
  for I := 0 to lbWords.Items.Count - 1 do
  begin
    if lbWords.Items.Objects[I] <> nil then
      lbWords.Items.Objects[I].Free;
  end;
  lbWords.Items.Clear;
  lbClasses.Items.Clear;
end;

procedure TfrmClassesInspector.lbWordsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Str, SearchStr, VisStr: String;
  I, X, Y: Integer;
begin
  if not Control.InheritsFrom(TListBox) then
    Exit;

  SearchStr := AnsiUpperCase(edtSearch.text);
  with TListBox(Control) do
  begin
    Str := Items[Index];
    VisStr := AnsiUpperCase(Str);
    Canvas.FillRect(Rect);
    I := Pos(SearchStr, VisStr);
    X := Rect.Left;
    Y := Rect.Top;
    if I > 1 then
    begin
      VisStr := copy(Str, 1, I - 1);
      Canvas.TextOut(X, Y, VisStr);
      X := X + Canvas.TextWidth(VisStr);
    end;
    Canvas.Font.Style := [fsBold];
    VisStr := copy(Str, I, Length(SearchStr));
    Canvas.TextOut(X, Y, VisStr);
    X := X + Canvas.TextWidth(VisStr);
    Canvas.Font.Style := [];
    VisStr := copy(Str, I + Length(SearchStr), Length(Str) - Length(SearchStr) - I + 1);
    Canvas.TextOut(X, Y, VisStr);
    Rect.Right := X + Canvas.TextWidth(VisStr);
  end;

end;


procedure TfrmClassesInspector.lbWordsDblClick(Sender: TObject);
begin
end;

{ TInspectorItem }

constructor TInspectorItem.Create(const RegList: TObjectList);
begin
  inherited Create;
  RegList.Add(Self);
end;

procedure TInspectorItem.SetData(const Value: Pointer);
begin
  FData := Value;
end;

procedure TInspectorItem.SetDescription(const Value: String);
begin
  FDescription := Value;
end;

procedure TInspectorItem.SetItemType(const Value: TciItemType);
begin
  FItemType := Value;
end;

function GetItemType(Node: TTreeNode): TciItemType;
begin
  if (Node <> nil) and (Node.Data <> nil) then
    Result := TInspectorItem(Node.Data).ItemType
  else
    Result := ciUnknown;
end;

procedure SetCorrectType(Node: TTreeNode; const NodeType: TciItemType);

  procedure SetImage(const ImageIndex: Integer);
  begin
    Node.ImageIndex := ImageIndex;
    Node.SelectedIndex := ImageIndex;
    Node.StateIndex := ImageIndex;
  end;
begin
  if Node.Data = nil then
    Exit;

  TInspectorItem(Node.Data).ItemType := NodeType;

  case NodeType of
    ciParentTypeFolder:
      SetImage(8);
    ciGlObjMetFolder:
      SetImage(8);
    ciStClass:
      SetImage(2);
    ciFrmClass:
      SetImage(2);
    ciGdcClass:
      SetImage(2);
    ciVBClass:
      SetImage(2);
    ciUserForm:
      SetImage(2);
    ciVBModule:
      SetImage(43);
    ciGlObject:
      SetImage(0);
    ciHierFolder:
      SetImage(40);
    ciMethodFolder:
      SetImage(6);
    ciPropertyFolder:
      SetImage(6);
    ciCompFolder:
      SetImage(6);
    ciHierClass:
      SetImage(42);
    ciMethod:
      SetImage(4);
    ciMethodGet:
      SetImage(20);
    ciPropertyR:
      SetImage(39);
    ciPropertyW:
      SetImage(38);
    ciPropertyRW:
      SetImage(37);
    ciVBProp:
      SetImage(39);
    ciComponent:
      SetImage(41);
    ciInterface:
      SetImage(30);
  end;
end;

function AddItemData(Node: TTreeNode;
  const NodeType: TciItemType; const Description: String;
  const prpClassesFrm: IprpClassesFrm): TInspectorItem;
var
  I: Integer;

begin
//  Assert(prpClassesFrm <> nil, 'Не передана форма');
  if prpClassesFrm = nil then raise Exception.Create('Не передана форма IprpClassesFrm');

  // Создаем инфо-класс нода
  case NodeType of
    ciStClass, ciFrmClass, ciGdcClass, ciUserForm, ciVBClass, ciInterface:
      Result := TClassItem.Create(prpClassesFrm.GetItemList);
    ciMethod, ciMethodGet:
      Result := TMethodItem.Create(prpClassesFrm.GetItemList);
    ciPropertyR, ciPropertyW, ciPropertyRW, ciGlObject:
      Result := TWithResultItem.Create(prpClassesFrm.GetItemList);
    else
      Result := TInspectorItem.Create(prpClassesFrm.GetItemList);
  end;

  Result.Description := Description;

  // Сохраняем указатель в инфо-классе нода-класса
  if (Node.Parent <> nil) and (Node.Parent.Data <> nil) then
    case NodeType of
      ciHierFolder:
        TClassItem(Node.Parent.Data).HierarchyNode := Node;
      ciMethodFolder:
        TClassItem(Node.Parent.Data).MethodsNode := Node;
      ciPropertyFolder:
        TClassItem(Node.Parent.Data).PropertyNode := Node;
      ciCompFolder:
        TClassItem(Node.Parent.Data).ComponentNode := Node;
    end;

  Node.Data := Result;

  // Если нод класса, добавляем имя класса в список комбо-бокса.
  if (NodeType in [ciStClass, ciFrmClass, ciGdcClass,
    ciVBClass, ciUserForm, ciInterface]) and (frmClassesInspector <> nil) then
  begin
    I := frmClassesInspector.cbClasses.Items.IndexOf(Node.Text);
    if (I > -1) and (Node.Parent <> nil) then
    begin
      frmClassesInspector.cbClasses.Items.AddObject(
        Node.Text + '(' + Node.Parent.Text + ')', Node);
      if (frmClassesInspector.cbClasses.Items.Objects[I] is TTreeNode) and
        (TTreeNode(frmClassesInspector.cbClasses.Items.Objects[I]).Parent <> nil) then
      begin
        frmClassesInspector.cbClasses.Items[I] :=
          frmClassesInspector.cbClasses.Items[I] + '(' +
          TTreeNode(frmClassesInspector.cbClasses.Items.Objects[I]).Parent.Text + ')';
      end;
    end else
      frmClassesInspector.cbClasses.Items.AddObject(Node.Text, Node);
  end;

  SetCorrectType(Node, NodeType);
end;

function AddItemData(Node: TTreeNode; const NodeType: TciItemType;
  const Description: String; const Data: Pointer;
   const prpClassesFrm: IprpClassesFrm): TInspectorItem;
begin
  Result := AddItemData(Node, NodeType, Description, prpClassesFrm);
  Result.ItemData := Data;
end;

procedure TfrmClassesInspector.btnGoBackClick(Sender: TObject);
begin
  if FJumpList.Count > 1 then
  begin
    FJumpList.Delete(FJumpList.Count - 1);
    TTreeNode(FJumpList.Objects[FJumpList.Count - 1]).Selected := True;
  end;
end;

procedure TfrmClassesInspector.CopyChildNode(const TreeNodes: TTreeNodes;
  const DestNode, SourceNode: TTreeNode);
var
  tmpNode: TTreeNode;
begin
  tmpNode := SourceNode.getFirstChild;
  while tmpNode <> nil do
  begin
    TreeNodes.AddChildObject(DestNode, tmpNode.Text, tmpNode.Data);
    tmpNode := SourceNode.GetNextChild(tmpNode);
  end;
end;

procedure TfrmClassesInspector.lbClassesDblClick(Sender: TObject);
begin
  actGotoSearch.Execute;
end;

procedure TfrmClassesInspector.actGotoSearchExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lbClasses.Items.Count - 1 do
    if lbClasses.Selected[I] then
    begin
      TTreeNode(lbClasses.Items.Objects[I]).Selected := True;
      pcMain.ActivePage := tsClasses;
      tvClassesInsp.SetFocus;
    end;
end;

procedure TfrmClassesInspector.lbWordsClick(Sender: TObject);
begin
  if not Sender.InheritsFrom(TListBox) then
    Exit;

  with TListBox(Sender) do
  begin
    if Items.Objects[ItemIndex] <> nil then
    begin
      lbClasses.Items.Clear;
      lbClasses.Items.AddStrings(TStrings(Items.Objects[ItemIndex]));
    end;
  end;
end;

procedure TfrmClassesInspector.tvClassesInspCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
end;

{ TMethodItem }

procedure TMethodItem.AddParam(const TypeName: String; const ClassRef: TClass;
  NodeRef: TTreeNode);
var
  ParamObject: TParamObject;

begin
  if IndexOfType(TypeName) > -1 then
    Exit;

  if ParamList = nil then
    ParamList := TObjectList.Create(True);

  ParamObject := TParamObject.Create;
  ParamObject.TypeName := TypeName;
  ParamObject.ClassRef := ClassRef;
  ParamObject.NodeRef  := NodeRef;
  ParamList.Add(ParamObject);
end;

constructor TMethodItem.Create(const RegList: TObjectList);
begin
  inherited;
  ParamList := nil;
end;

destructor TMethodItem.Destroy;
begin
  if ParamList <> nil then
    ParamList.Free;
  inherited;
end;

function TMethodItem.GetCount: Integer;
begin
  if ParamList <> nil then
    Result := ParamList.Count
  else
    Result := 0;
end;

function TMethodItem.GetParam(const Index: Integer): TParamObject;
begin
  if ParamList <> nil then
    Result := TParamObject(ParamList[Index])
  else
    Result := nil;
end;

procedure TfrmClassesInspector.pmMain2Popup(Sender: TObject);
var
  Pos: TPoint;
  Node: TTreeNode;
  I: Integer;
  Item: TMenuItem;
begin
  for I := pmMain.Items.Count - 1 downto 0 do
    pmMain.Items[I].Free;
  pmMain.Items.Clear;

  begin
    Item := TMenuItem.Create(Self);
    Item.Action := actInsertCurrentItem;
    pmMain.Items.Add(Item);

    Item := TMenuItem.Create(Self);
    Item.Action := actCopyCurrentItem;
    pmMain.Items.Add(Item);

    Item := TMenuItem.Create(Self);
    Item.Caption := '-';
    pmMain.Items.Add(Item);

    Item := TMenuItem.Create(Self);
    Item.Action := actExpand;
    pmMain.Items.Add(Item);

    Item := TMenuItem.Create(Self);
    Item.Action := actCollapse;
    pmMain.Items.Add(Item);
  end;

  Pos := TCrackPopupMenu(pmMain).PopupPoint;
  Pos := tvClassesInsp.ScreenToClient(Pos);
  Node := tvClassesInsp.GetNodeAt(Pos.x, Pos.y);
  if Node = nil then
    Exit;

  Node.Selected := True;
  if TInspectorItem(Node.Data).ItemType in [ciMethod, ciMethodGet] then
  begin
    Item := TMenuItem.Create(pmMain);
    pmMain.Items.Add(Item);
    Item.Caption := '-';
    for I := 0 to TMethodItem(Node.Data).GetCount - 1 do
    with TMethodItem(Node.Data).GetParam(I) do
      if (ClassRef <> nil) or (NodeRef <> nil) then
      begin
        Item := TMenuItem.Create(pmMain);
        pmMain.Items.Add(Item);
        if NodeRef <> nil then
        begin
          Item.Caption := NodeRef.Text;
          Item.Tag := Integer(NodeRef);
        end else
          begin
            Item.Caption := TypeName;
            Item.Tag := Integer(GetClassNode(ClassRef));
          end;
        Item.OnClick := pmMainItemClick;
      end;
  end;

  if (TInspectorItem(Node.Data).ItemType in
    [ciMethod, ciMethodGet, ciPropertyR, ciPropertyW, ciPropertyRW]) and
    (((TInspectorItem(Node.Data) as TWithResultItem).ResultClassRef <> nil) or
    ((TInspectorItem(Node.Data) as TWithResultItem).ResultNodeRef <> nil)) then
  begin
    Item := TMenuItem.Create(pmMain);
    pmMain.Items.Add(Item);
    Item.Caption := '-';

    Item := TMenuItem.Create(pmMain);
    pmMain.Items.Add(Item);
    if TWithResultItem(Node.Data).ResultNodeRef <> nil then
    begin
      Item.Caption := TWithResultItem(Node.Data).ResultNodeRef.Text;
      Item.Tag := Integer(TWithResultItem(Node.Data).ResultNodeRef);
    end else
      begin
        Item.Caption := TWithResultItem(Node.Data).ResultTypeName;
        Item.Tag := Integer(GetClassNode(TWithResultItem(Node.Data).ResultClassRef));
      end;
    Item.OnClick := pmMainItemClick;
  end;
end;

function TMethodItem.IndexOfType(const TypeName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to GetCount - 1 do
    if AnsiUpperCase(GetParam(I).TypeName) = AnsiUpperCase(TypeName) then
    begin
      Result := I;
      Break;
    end;
end;

procedure TfrmClassesInspector.pmMainItemClick(Sender: TObject);
begin
  if not Sender.InheritsFrom(TMenuItem) then
    Exit;

  if (TMenuItem(Sender).Tag > 0) and
    TObject(TMenuItem(Sender).Tag).InheritsFrom(TTreeNode) then
  begin
    TTreeNode(TMenuItem(Sender).Tag).Selected := True;
  end;
end;

procedure TfrmClassesInspector.FillGlObjectsTree;
begin
  prpClassesInspector.FillStGlobalObjects(FStGlObjectNode, FStGlMethodNode, Self);
  prpClassesInspector.FillVBGlobalObjects(FStGlObjectNode, FVBGlMethodNode, Self);
  prpClassesInspector.FillUsGlobalObjects(FUserGlObjectNode, nil, Self);
end;

procedure TfrmClassesInspector.tvClassesInspKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Ord(Key) of
    13: tvClassesInspDblClick(Sender);
    26: btnGoBackClick(Sender);
  end;
end;

function TfrmClassesInspector.GetClassNode(
  const AClass: TClass): TTreeNode;
var
  I: Integer;
  TmpClass: TClass;
begin
  Result := nil;
  if Assigned(AClass) then
  begin
    I := -1;
    TmpClass := AClass;
    while (I > -1) or Assigned(TmpClass) do
    begin
      I := cbClasses.Items.IndexOf(TmpClass.ClassName);
      if I > -1 then
      begin
        Result := TTreeNode(cbClasses.Items.Objects[I]);
        Break;
      end;
      TmpClass := TmpClass.ClassParent;
    end;
  end;
end;

{ TResList }

procedure TResList.AddRef(const ClassRef: Pointer;
  const DataType: TRefDateType; const ClassGUID: TGUID);
var
  I: Integer;
  ResItem: TResItem;
begin
  I := FResLibArray.IndexOf(Integer(ClassGUID.D1));
  if I = -1 then
  begin
    ResItem := TResItem.Create;
    ResItem.AddResRef(ClassRef, DataType, ClassGUID);
    FResLibArray.AddObject(Integer(ClassGUID.D1), ResItem);
  end else
    begin
      ResItem := TResItem(FResLibArray.ObjectByIndex[I]);
      if ResItem.ResRecord[ClassGUID].ClassRef = nil then
        ResItem.AddResRef(ClassRef, DataType, ClassGUID);
    end;
end;

procedure TResList.Clear;
begin
  FResLibArray.Clear;
end;

constructor TResList.Create;
begin
  FResLibArray := TgdKeyObjectAssoc.Create(True);
end;

destructor TResList.Destroy;
begin
  FResLibArray.Free;
  inherited;
end;

function TResList.GetRef(const RefGUID: TGUID): TResRecord;
var
  I: Integer;
begin
  I := FResLibArray.IndexOf(Integer(RefGUID.D1));
  if I > -1 then
    Result := TResItem(FResLibArray.ObjectByIndex[I]).ResRecord[RefGUID]
  else
    Result.ClassRef := nil;
end;

{ TResItem }

procedure TResItem.AddResRef(const ClassRef: Pointer;
  const DataType: TRefDateType; const ClassGUID: TGUID);
begin
  if FResRecord.ClassRef = nil then
  begin
    FRefGUID := ClassGUID;
    FResRecord.ClassRef := ClassRef;
    FResRecord.DataType := DataType;
  end else
    begin
      if FInsideResItem = nil then
        FInsideResItem := TResItem.Create;
      FInsideResItem.AddResRef(ClassRef, DataType, ClassGUID);
    end;
end;

function TResItem.CompareGUID(GUID1, GUID2: TGUID): Boolean;
begin
  Result := True;
  if (GUID1.D1 <> GUID2.D1) or
    (GUID1.D2 <> GUID2.D2) or
    (GUID1.D3 <> GUID2.D3) or
    (GUID1.D4[0] <> GUID2.D4[0]) or
    (GUID1.D4[1] <> GUID2.D4[1]) or
    (GUID1.D4[2] <> GUID2.D4[2]) or
    (GUID1.D4[3] <> GUID2.D4[3]) or
    (GUID1.D4[4] <> GUID2.D4[4]) or
    (GUID1.D4[5] <> GUID2.D4[5]) or
    (GUID1.D4[6] <> GUID2.D4[6]) or
    (GUID1.D4[7] <> GUID2.D4[7])
  then
    Result := False;
end;

constructor TResItem.Create;
begin
  FInsideResItem := nil;
end;

destructor TResItem.Destroy;
begin
  if FInsideResItem <> nil then
    FInsideResItem.Free;
  inherited;
end;

function TResItem.GetResRecord(RefGUID: TGUID): TResRecord;
begin
  if CompareGUID(FRefGUID, RefGUID) then
    Result := FResRecord
  else
    begin
      if FInsideResItem <> nil then
        Result := FInsideResItem.ResRecord[RefGUID]
      else
        Result.ClassRef := nil;
    end;
end;

procedure TfrmClassesInspector.btnRefreshClick(Sender: TObject);
begin
  Refresh;
end;

procedure TfrmClassesInspector.Refresh;
begin
  ScriptFactory.Eval('');
  Reset;

//  FNoShowList.Text := NoShowProp;
  CreateFullTree;

  if frmGedeminProperty <> nil then
    frmGedeminProperty.SetInsCurrentClass;
end;

procedure TfrmClassesInspector.Reset;
begin
  tvClassesInsp.Items.Clear;
  FSearchActivate := False;
  FJumpList.Clear;
  FHLNodeList.Clear;
  FItemList.Clear;
  FLibArray.Clear;
  FCurrentModule.Name:= '';
  FCurrentModule.ClassRef:= nil;

end;

procedure TfrmClassesInspector.cbClassesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
    GotoCbClass;
end;

procedure TfrmClassesInspector.cbClassesDblClick(Sender: TObject);
begin
  GotoCbClass;
end;

procedure TfrmClassesInspector.GotoCbClass;
var
  i: Integer;
begin
  i := cbClasses.Items.IndexOf(cbClasses.Text);
  if i > -1 then
  begin
    TTreeNode(cbClasses.Items.Objects[i]).Selected := True;
    TTreeNode(cbClasses.Items.Objects[i]).Focused := True;
    tvClassesInsp.SetFocus;
  end;
end;

procedure TfrmClassesInspector.actStayOnTopExecute(Sender: TObject);
begin
  if MessageBox(Handle, PChar('Для изменение статуса инспектора потребуется перестроить дерево.'#13#10 + 'Продолжить?'), 'Внимание',
    MB_YESNO or MB_TOPMOST or MB_TASKMODAL or MB_ICONWARNING) = id_No then Exit;

  inherited;
  Refresh;
end;

procedure TfrmClassesInspector.FormEndDock(Sender, Target: TObject; X,
  Y: Integer);
begin
  inherited;
  if not FIsTreeCreated then
  begin
    Refresh;
    FIsTreeCreated := True;
  end;
end;

class function TfrmClassesInspector.IsDocked: Boolean;
var
  Path, DockSiteName: String;
  F: TgsStorageFolder;
begin
  Result := False;;
  if Assigned(UserStorage) then
  begin
    Path := 'frmGedeminProperty\' + cInsFrmName;
    F := UserStorage.OpenFolder(Path, True);
    if F <> nil then
    try
      DockSiteName := F.ReadString(cDockSite, cNil);
    finally
      UserStorage.CloseFolder(F);
    end;
    if DockSiteName <> cNil then
      Result := True;
  end;
end;

procedure TfrmClassesInspector.WMShowWindow(var Message: TWMShowWindow);
begin
  inherited;
  if not FIsTreeCreated then
  begin
    Refresh;
    FIsTreeCreated := True;
  end;
end;

procedure TfrmClassesInspector.CreateWindowHandle(
  const Params: TCreateParams);
begin
  inherited;
  if FIsTreeCreated then
    FIsTreeCreated := False;
end;

function TfrmClassesInspector.GetItemList: TObjectList;
begin
  Result := FItemList;
end;

function TfrmClassesInspector.GetClassesTree: TTreeView;
begin
  Result := tvClassesInsp;
end;

function TfrmClassesInspector.GetClassesInspector: TfrmClassesInspector;
begin
  Result := Self;
end;

function TfrmClassesInspector.GetLibArray: TResList;
begin
  Result := FLibArray;
end;

function TfrmClassesInspector.GetInterfacesNode: TTreeNode;
begin
  Result := FInterfacesNode;
end;

function TfrmClassesInspector.IsShowInherited: boolean;
begin
  Result:= chkShowInherited.Checked;
end;

procedure TfrmClassesInspector.chkShowInheritedClick(Sender: TObject);
begin
  Refresh;
end;

end.
