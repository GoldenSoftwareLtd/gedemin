
unit obj_WrapperDelphiClasses;

interface

uses
  Windows, ComObj, ActiveX, AxCtrls, Classes, Gedemin_TLB, StdVcl,
  Controls, StdCtrls, DB, Forms, IBCustomDataSet, menus, Graphics, extctrls,
  ActnList, sysutils, Dialogs, IBDataBase, IBSQL, checklst, comctrls,
  buttons, grids, dbctrls, mask, dbclient, IBDatabaseInfo, IBEvents, IBExtract,
  IBQuery, IBStoredProc, IBTable, IBUpdateSQL, imglist, Outline, filectrl,
  ColorGrd, toolwin, Gauges, Spin, obj_WrapperIBXClasses, dbgrids, contnrs,
  printers, gdv_frAcctAnalytics_unit, shdocvw, JvDBImage, gsMorph, gsPeriodEdit, gsPanel;

type
  TPointArray = array of TPoint;

  TwrpMouse = class(TwrpObject, IgsMouse)
  protected
    function  Get_DragImmediate: WordBool; safecall;
    function  Get_CursorPosX: Integer; safecall;
    procedure Set_CursorPosX(Value: Integer); safecall;
    function  Get_CursorPosY: Integer; safecall;
    procedure Set_CursorPosY(Value: Integer); safecall;
    function  Get_DragThreshold: Integer; safecall;
    function  Get_MousePresent: WordBool; safecall;
    function  Get_WheelPresent: WordBool; safecall;
    function  Get_WheelScrollLines: Integer; safecall;
  end;

  TwrpOutlineNode = class(TwrpPersistent, IgsOutlineNode)
  private
    function  GetOutlineNode: TOutlineNode;
  protected
    procedure ChangeLevelBy(Value: Integer); safecall;
    procedure Collapse; safecall;
    procedure Expand; safecall;
    procedure FullExpand; safecall;
    function  GetDisplayWidth: Integer; safecall;
    function  GetFirstChild: Integer; safecall;
    function  GetLastChild: Integer; safecall;
    function  GetNextChild(Value: Integer): Integer; safecall;
    function  GetPrevChild(Value: Integer): Integer; safecall;
    procedure MoveTo(Destination: Integer; AttachMode: TgsAttachMode); safecall;
    function  Get_Parent: IgsOutlineNode; safecall;
    function  Get_Expanded: WordBool; safecall;
    procedure Set_Expanded(Value: WordBool); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_Index: Integer; safecall;
    function  Get_Level: LongWord; safecall;
    procedure Set_Level(Value: LongWord); safecall;
    function  Get_HasItems: WordBool; safecall;
    function  Get_IsVisible: WordBool; safecall;
    function  Get_TopItem: Integer; safecall;
    function  Get_FullPath: WideString; safecall;
  end;

  TwrpHeaderSection = class(TwrpCollectionItem, IgsHeaderSection)
  private
    function  GetHeaderSection: THeaderSection;
  protected
    procedure ParentBiDiModeChanged; safecall;
    function  UseRightToLeftAlignment: WordBool; safecall;
    function  UseRightToLeftReading: WordBool; safecall;
    function  Get_Left: Integer; safecall;
    function  Get_Right: Integer; safecall;
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_AllowClick: WordBool; safecall;
    procedure Set_AllowClick(Value: WordBool); safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    function  Get_BiDiMode: TgsBiDiMode; safecall;
    procedure Set_BiDiMode(Value: TgsBiDiMode); safecall;
    function  Get_ImageIndex: Integer; safecall;
    procedure Set_ImageIndex(Value: Integer); safecall;
    function  Get_MaxWidth: Integer; safecall;
    procedure Set_MaxWidth(Value: Integer); safecall;
    function  Get_MinWidth: Integer; safecall;
    procedure Set_MinWidth(Value: Integer); safecall;
    function  Get_ParentBiDiMode: WordBool; safecall;
    procedure Set_ParentBiDiMode(Value: WordBool); safecall;
    function  Get_Style: TgsHeaderSectionStyle; safecall;
    procedure Set_Style(Value: TgsHeaderSectionStyle); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
  end;

  TwrpHeaderSections = class(TwrpCollection, IgsHeaderSections)
  private
    function  GetHeaderSections: THeaderSections;
  protected
    function  Add: IgsHeaderSection; safecall;
    function  Get_Items(Index: Integer): IgsHeaderSection; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsHeaderSection); safecall;
  end;

  TwrpChangeLink = class(TwrpObject, IgsChangeLink)
  private
    function  GetChangeLink: TChangeLink;
  protected
    procedure Change; safecall;
    function  Get_Sender: IgsCustomImageList; safecall;
    procedure Set_Sender(const Value: IgsCustomImageList); safecall;
  end;

  TwrpParams = class(TwrpCollection, IgsParams)
  private
    function  GetParams: TParams;
  protected
    procedure AssignValues(const Value: IgsParams); safecall;
    procedure AddParam(const Value: IgsParam); safecall;
    procedure RemoveParam(const Value: IgsParam); safecall;
    function  CreateParam(FldType: TgsFieldType; const ParamName: WideString;
                          ParamType: TgsParamType): IgsParam; safecall;
    procedure GetParamList(const List: IgsList; const ParamNames: WideString); safecall;
    function  IsEqual(const Value: IgsParams): WordBool; safecall;
    function  ParseSQL(const SQL: WideString; DoCreate: WordBool): WideString; safecall;
    function  ParamByName(const Value: WideString): IgsParam; safecall;
    function  FindParam(const Value: WideString): IgsParam; safecall;
    function  Get_Items(Index: Integer): IgsParam; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsParam); safecall;
    function  Get_ParamValues(const ParamName: WideString): OleVariant; safecall;
    procedure Set_ParamValues(const ParamName: WideString; Value: OleVariant); safecall;
    property Items[Index: Integer]: IgsParam read Get_Items write Set_Items; default;
    property ParamValues[const ParamName: WideString]: OleVariant read Get_ParamValues write Set_ParamValues;
  end;

  TwrpCheckConstraints = class(TwrpCollection, IgsCheckConstraints)
  private
    function  GetCheckConstraints: TCheckConstraints;
  protected
    function  Add: IgsCheckConstraint; safecall;
    function  Get_Items(Index: Integer): IgsCheckConstraint; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsCheckConstraint); safecall;
    property Items[Index: Integer]: IgsCheckConstraint read Get_Items write Set_Items; default;
  end;

  TwrpCheckConstraint = class(TwrpCollectionItem, IgsCheckConstraint)
  private
    function  GetCheckConstraint: TCheckConstraint;
  protected
    function  GetDisplayName: WideString; safecall;
    function  Get_CustomConstraint: WideString; safecall;
    procedure Set_CustomConstraint(const Value: WideString); safecall;
    function  Get_ErrorMessage: WideString; safecall;
    procedure Set_ErrorMessage(const Value: WideString); safecall;
    function  Get_FromDictionary: WordBool; safecall;
    procedure Set_FromDictionary(Value: WordBool); safecall;
    function  Get_ImportedConstraint: WideString; safecall;
    procedure Set_ImportedConstraint(const Value: WideString); safecall;
  end;

  TwrpParaAttributes = class(TwrpPersistent, IgsParaAttributes)
  private
    function  GetParaAttributes: TParaAttributes;
  protected
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_FirstIndent: Integer; safecall;
    procedure Set_FirstIndent(Value: Integer); safecall;
    function  Get_LeftIndent: Integer; safecall;
    procedure Set_LeftIndent(Value: Integer); safecall;
    function  Get_Numbering: TgsNumberingStyle; safecall;
    procedure Set_Numbering(Value: TgsNumberingStyle); safecall;
    function  Get_RightIndent: Integer; safecall;
    procedure Set_RightIndent(Value: Integer); safecall;
    function  Get_Tab(Index: Integer): Integer; safecall;
    procedure Set_Tab(Index: Integer; Value: Integer); safecall;
    function  Get_TabCount: Integer; safecall;
    procedure Set_TabCount(Value: Integer); safecall;
  end;

  TwrpTextAttributes = class(TwrpPersistent, IgsTextAttributes)
  private
    function  GetTextAttributes: TTextAttributes;
  protected
    function  Get_Charset: Word; safecall;
    procedure Set_Charset(Value: Word); safecall;
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function  Get_Pitch: TgsFontPitch; safecall;
    procedure Set_Pitch(Value: TgsFontPitch); safecall;
    function  Get_Protected_: WordBool; safecall;
    procedure Set_Protected_(Value: WordBool); safecall;
    function  Get_Size: Integer; safecall;
    procedure Set_Size(Value: Integer); safecall;
    function  Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function  Get_Style: WideString; safecall;
    procedure Set_Style(const Value: WideString); safecall;
  end;

  TwrpIBBatch = class(TwrpObject, IgsIBBatch)
  private
    function  GetIBBatch: TIBBatch;
  protected
    procedure ReadyFile; safecall;
    function  Get_Columns: IgsIBXSQLDA; safecall;
    procedure Set_Columns(const Value: IgsIBXSQLDA); safecall;
    function  Get_FileName: WideString; safecall;
    procedure Set_FileName(const Value: WideString); safecall;
    function  Get_Params: IgsIBXSQLDA; safecall;
    procedure Set_Params(const Value: IgsIBXSQLDA); safecall;
  end;

  TwrpIBBatchOutput = class(TwrpIBBatch, IgsIBBatchOutput)
  private
    function  GetIBBatchOutput: TIBBatchOutput;
  protected
    function  WriteColumns: WordBool; safecall;
  end;

  TwrpIBBatchInput = class(TwrpIBBatch, IgsIBBatchInput)
  private
    function  GetIBBatchInput: TIBBatchInput;
  protected
    function  ReadParameters: WordBool; safecall;
  end;

  TwrpIBGeneratorField = class(TwrpPersistent, IgsIBGeneratorField)
  private
    function  GetIBGeneratorField: TIBGeneratorField;
  protected
    function  ValueName: WideString; safecall;
    procedure Apply; safecall;
    function  Get_Field: WideString; safecall;
    procedure Set_Field(const Value: WideString); safecall;
    function  Get_Generator: WideString; safecall;
    procedure Set_Generator(const Value: WideString); safecall;
    function  Get_IncrementBy: Integer; safecall;
    procedure Set_IncrementBy(Value: Integer); safecall;
    function  Get_ApplyEvent: TgsIBGeneratorApplyEvent; safecall;
    procedure Set_ApplyEvent(Value: TgsIBGeneratorApplyEvent); safecall;
  end;

  TwrpListItems = class(TwrpPersistent, IgsListItems)
  private
    function  GetListItems: TListItems;
  protected
    function  Add: IgsListItem; safecall;
    procedure BeginUpdate; safecall;
    procedure Clear; safecall;
    procedure Delete(Index: Integer); safecall;
    procedure EndUpdate; safecall;
    function  IndexOf(const Value: IgsListItem): Integer; safecall;
    function  Insert(Index: Integer): IgsListItem; safecall;
    function  Get_Count: Integer; safecall;
    procedure Set_Count(Value: Integer); safecall;
    function  Get_Handle: LongWord; safecall;
    function  Get_Item(Index: Integer): IgsListItem; safecall;
    procedure Set_Item(Index: Integer; const Value: IgsListItem); safecall;
    function  Get_Owner: IgsCustomListView; safecall;
  end;

  TwrpListItem = class(TwrpPersistent, IgsListItem)
  private
    function  GetListItem: TListItem;
  protected
    procedure CancelEdit; safecall;
    procedure Delete; safecall;
    function  EditCaption: WordBool; safecall;
    procedure MakeVisible(PartialOK: WordBool); safecall;
    procedure Update; safecall;
    function  WorkArea: Integer; safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function  Get_Cut: WordBool; safecall;
    procedure Set_Cut(Value: WordBool); safecall;
    function  Get_DropTarget: WordBool; safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    function  Get_Focused: WordBool; safecall;
    procedure Set_Focused(Value: WordBool); safecall;
    function  Get_Handle: LongWord; safecall;
    function  Get_ImageIndex: Integer; safecall;
    procedure Set_ImageIndex(Value: Integer); safecall;
    function  Get_Indent: Integer; safecall;
    procedure Set_Indent(Value: Integer); safecall;
    function  Get_Index: Integer; safecall;
    function  Get_Left: Integer; safecall;
    procedure Set_Left(Value: Integer); safecall;
    function  Get_ListView: IgsCustomListView; safecall;
    function  Get_Owner: IgsListItems; safecall;
    function  Get_Selected: WordBool; safecall;
    procedure Set_Selected(Value: WordBool); safecall;
    function  Get_StateIndex: Integer; safecall;
    procedure Set_StateIndex(Value: Integer); safecall;
    function  Get_SubItems: IgsStrings; safecall;
    procedure Set_SubItems(const Value: IgsStrings); safecall;
    function  Get_SubItemImages(Index: Integer): Integer; safecall;
    procedure Set_SubItemImages(Index: Integer; Value: Integer); safecall;
    function  Get_Top: Integer; safecall;
    procedure Set_Top(Value: Integer); safecall;
    function  Get_Data: Integer; safecall;
    procedure Set_Data(Value: Integer); safecall;
  end;

  TwrpListColumn = class(TwrpCollectionItem, IgsListColumn)
  private
    function  GetListColumn: TListColumn;
  protected
    function  Get_WidthType: Integer; safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function  Get_ImageIndex: Integer; safecall;
    procedure Set_ImageIndex(Value: Integer); safecall;
    function  Get_MaxWidth: Integer; safecall;
    procedure Set_MaxWidth(Value: Integer); safecall;
    function  Get_MinWidth: Integer; safecall;
    procedure Set_MinWidth(Value: Integer); safecall;
    function  Get_Tag: Integer; safecall;
    procedure Set_Tag(Value: Integer); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
  end;

  TwrpStatusPanel = class(TwrpCollectionItem, IgsStatusPanel)
  private
    function  GetStatusPanel: TStatusPanel;
  protected
    procedure ParentBiDiModeChanged; safecall;
    function  UseRightToLeftAlignment: WordBool; safecall;
    function  UseRightToLeftReading: WordBool; safecall;
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_Bevel: TgsStatusPanelBevel; safecall;
    procedure Set_Bevel(Value: TgsStatusPanelBevel); safecall;
    function  Get_BiDiMode: TgsBiDiMode; safecall;
    procedure Set_BiDiMode(Value: TgsBiDiMode); safecall;
    function  Get_ParentBiDiMode: WordBool; safecall;
    procedure Set_ParentBiDiMode(Value: WordBool); safecall;
    function  Get_Style: TgsStatusPanelStyle; safecall;
    procedure Set_Style(Value: TgsStatusPanelStyle); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
  end;

  TwrpStatusPanels = class(TwrpCollection, IgsStatusPanels)
  private
    function  GetStatusPanels: TStatusPanels;
  protected
    function  Add: IgsStatusPanel; safecall;
    function  Get_Items(Index: Integer): IgsStatusPanel; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsStatusPanel); safecall;
    property Items[Index: Integer]: IgsStatusPanel read Get_Items write Set_Items; default;
  end;

  TwrpIBBase = class(TwrpObject, IgsIBBase)
  private
    function  GetIBBase: TIBBase;
  protected
    procedure CheckDatabase; safecall;
    procedure CheckTransaction; safecall;
    function  Get_Owner: IgsObject; safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
  end;

  TwrpBasicActionLink = class(TwrpObject, IgsBasicActionLink)
  private
    function  GetBasicActionLink: TBasicActionLink;
  protected
    function  Execute: WordBool; safecall;
    function  Update: WordBool; safecall;
    function  Get_Action: IgsBasicAction; safecall;
    procedure Set_Action(const Value: IgsBasicAction); safecall;
  end;

  TwrpBookmarkList = class(TwrpObject, IgsBookmarkList)
  private
    function  GetBookmarkList: TBookmarkList;
  protected
    procedure Clear; safecall;
    procedure Delete; safecall;
    function  Find(const Item: WideString; var Index: OleVariant): WordBool; safecall;
    function  IndexOf(const Item: WideString): Integer; safecall;
    function  Refresh: WordBool; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_CurrentRowSelected: WordBool; safecall;
    procedure Set_CurrentRowSelected(Value: WordBool); safecall;
    function  Get_Items(Index: Integer): WideString; safecall;
  end;

  TwrpTreeNodes = class(TwrpPersistent, IgsTreeNodes)
  private
    function  GetTreeNodes: TTreeNodes;
  protected
    function  Get_Count: Integer; safecall;
    function  Get_Handle: Integer; safecall;
    function  Get_Item(Index: Integer): IgsTreeNode; safecall;
    function  Get_Owner: IgsCustomTreeView; safecall;
    function  Add(const Node: IgsTreeNode; const S: WideString): IgsTreeNode; safecall;
    function  AddChild(const Node: IgsTreeNode; const S: WideString): IgsTreeNode; safecall;
    function  AddChildFist(const Node: IgsTreeNode; const S: WideString): IgsTreeNode; safecall;
    procedure BeginUpdate; safecall;
    procedure Clear; safecall;
    procedure Delete(const Node: IgsTreeNode); safecall;
    procedure EndUpdate; safecall;
    function  GetFirstNode: IgsTreeNode; safecall;
    function  Insert(const Node: IgsTreeNode; const S: WideString): IgsTreeNode; safecall;
  end;

  TwrpTreeNode = class(TwrpPersistent, IgsTreeNode)
  private
    function  GetTreeNode: TTreeNode;
  protected
    function  Get_AbsoluteIndex: Integer; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Cut: WordBool; safecall;
    procedure Set_Cut(Value: WordBool); safecall;
    function  Get_Deleting: WordBool; safecall;
    function  Get_DropTarget: WordBool; safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    function  Get_Expanded: WordBool; safecall;
    procedure Set_Expanded(Value: WordBool); safecall;
    function  Get_Focused: WordBool; safecall;
    procedure Set_Focused(Value: WordBool); safecall;
    function  Get_Handle: Integer; safecall;
    function  Get_HasChildren: WordBool; safecall;
    procedure Set_HasChildren(Value: WordBool); safecall;
    function  Get_ImageIndex: Integer; safecall;
    procedure Set_ImageIndex(Value: Integer); safecall;
    function  Get_Index: Integer; safecall;
    function  Get_IsVisible: WordBool; safecall;
    function  Get_Item(Index: Integer): IgsTreeNode; safecall;
    function  Get_Level: Integer; safecall;
    function  Get_OverlayIndex: Integer; safecall;
    procedure Set_OverlayIndex(Value: Integer); safecall;
    function  Get_Owner: IgsTreeNodes; safecall;
    function  Get_Parent: IgsTreeNode; safecall;
    function  Get_Selected: WordBool; safecall;
    procedure Set_Selected(Value: WordBool); safecall;
    function  Get_SelectedIndex: Integer; safecall;
    procedure Set_SelectedIndex(Value: Integer); safecall;
    function  Get_StateIndex: Integer; safecall;
    procedure Set_StateIndex(Value: Integer); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_TreeView: IgsCustomTreeView; safecall;
    function  AlphaSort: WordBool; safecall;
    procedure Collapse(Recurse: WordBool); safecall;
    procedure Delete; safecall;
    procedure DeleteChildren; safecall;
    function  EditText: WordBool; safecall;
    procedure EndEdit(Cancel: WordBool); safecall;
    procedure Expand(Recurse: WordBool); safecall;
    function  GetFirstChild: IgsTreeNode; safecall;
    function  GetHandle: Integer; safecall;
    function  GetLastChild: IgsTreeNode; safecall;
    function  GetNextChild(const Value: IgsTreeNode): IgsTreeNode; safecall;
    function  GetNext: IgsTreeNode; safecall;
    function  GetNextSibling: IgsTreeNode; safecall;
    function  GetNextVisible: IgsTreeNode; safecall;
    function  GetPrev: IgsTreeNode; safecall;
    function  GetPrevChild(const Value: IgsTreeNode): IgsTreeNode; safecall;
    function  GetPrevSibling: IgsTreeNode; safecall;
    function  GetPrevVisible: IgsTreeNode; safecall;
    function  HasAsParent(const Value: IgsTreeNode): WordBool; safecall;
    function  IndexOf(const Value: IgsTreeNode): Integer; safecall;
    procedure MakeVisible; safecall;
    procedure MoveTo(const Destination: IgsTreeNode; Mode: TgsNodeAttachMode); safecall;
    function  Get_Data: Integer; safecall;
    procedure Set_Data(Value: Integer); safecall;
  end;

  TwrpDataLink = class(TwrpPersistent, IgsDataLink)
  private
    function  GetDataLink: TDataLink;
  protected
    function  Edit: WordBool; safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpdateAction(const Action: IgsBasicAction): WordBool; safecall;
    procedure UpdateRecord; safecall;
    function  Get_Active: WordBool; safecall;
    function  Get_ActiveRecord: Integer; safecall;
    procedure Set_ActiveRecord(Value: Integer); safecall;
    function  Get_BOF: WordBool; safecall;
    function  Get_BufferCount: Integer; safecall;
    procedure Set_BufferCount(Value: Integer); safecall;
    function  Get_DataSet: IgsDataSet; safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Editing: WordBool; safecall;
    function  Get_Eof: WordBool; safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_RecordCount: Integer; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGridDataLink = class(TwrpDataLink, IgsGridDataLink)
  private
    function  GetGridDataLink: TGridDataLink;
  protected
    function  AddMapping(const FieldName: WideString): WordBool; safecall;
    procedure ClearMapping; safecall;
    procedure Modified; safecall;
    procedure Reset; safecall;
    function  Get_DefaultFields: WordBool; safecall;
    function  Get_FieldCount: Integer; safecall;
    function  Get_Fields(I: Integer): IgsFieldComponent; safecall;
    function  Get_SparseMap: WordBool; safecall;
    procedure Set_SparseMap(Value: WordBool); safecall;
  end;

  TwrpFiler = class(TwrpObject, IgsFiler)
  private
    function  GetFiler: TFiler;
  protected
    function  Get_Ancestor: IgsPersistent; safecall;
    procedure Set_Ancestor(const Value: IgsPersistent); safecall;
    function  Get_IgnoreChildren: WordBool; safecall;
    procedure Set_IgnoreChildren(Value: WordBool); safecall;
    function  Get_LookupRoot: IgsComponent; safecall;
    function  Get_Root: IgsComponent; safecall;
    procedure Set_Root(const Value: IgsComponent); safecall;
    procedure FlushBuffer; safecall;
  end;

  TwrpReader = class(TwrpFiler, IgsReader)
  private
    function  GetReader: TReader;
  protected
    function  Get_Owner: IgsComponent; safecall;
    procedure Set_Owner(const Value: IgsComponent); safecall;
    function  Get_Parent: IgsComponent; safecall;
    procedure Set_Parent(const Value: IgsComponent); safecall;
    function  Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    procedure BeginReferences; safecall;
    procedure CheckValue(Value: TgsValueType); safecall;
    procedure CopyValue(const Writer: IgsWriter); safecall;
    function  EndOfList: WordBool; safecall;
    procedure EndReferences; safecall;
    procedure FixupReferences; safecall;
    function  NextValue:TgsValueType ; safecall;
    function  ReadBoolean: WordBool; safecall;
    function  ReadChar: Byte; safecall;
    procedure ReadCollection(const Collection: IgsCollection); safecall;
    function  ReadComponent(const Component: IgsComponent): IgsComponent; safecall;
    function  ReadCurrency: Currency; safecall;
    function  ReadDate: TDateTime; safecall;
    function  ReadIdent: WideString; safecall;
    function  ReadInt64: Int64; safecall;
    function  ReadInteger: Integer; safecall;
    procedure ReadListBegin; safecall;
    procedure ReadListEnd; safecall;
    procedure ReadPrefix(const Flag: WideString; var AChildPos: OleVariant); safecall;
    function  ReadRootComponent(const Root: IgsComponent): IgsComponent; safecall;
    procedure ReadSignature; safecall;
    function  ReadStr: WideString; safecall;
    function  ReadString: WideString; safecall;
    function  ReadValue: TgsValueType; safecall;
    function  ReadWideString: WideString; safecall;
  end;

  TwrpWriter = class(TwrpFiler, IgsWriter)
  private
    function  GetWriter: TWriter;
  protected
    function  Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    function  Get_RootAncestor: IgsComponent; safecall;
    procedure Set_RootAncestor(const Value: IgsComponent); safecall;
    procedure WriteBoolean(Value: WordBool); safecall;
    procedure WriteChar(Value: Byte); safecall;
    procedure WriteCollection(const Value: IgsCollection); safecall;
    procedure WriteComponent(const Value: IgsComponent); safecall;
    procedure WriteCurrency(Value: Currency); safecall;
    procedure WriteDate(Value: TDateTime); safecall;
    procedure WriteDescendent(const Root: IgsComponent; const AAncestor: IgsComponent); safecall;
    procedure WriteInteger(Value: Integer); safecall;
    procedure WriteRootComponent(const Value: IgsComponent); safecall;
    procedure WriteStr(const Value: WideString); safecall;
    procedure WriteListBegin; safecall;
    procedure WriteListEnd; safecall;
    procedure WriteSignature; safecall;
    procedure WriteString(const Value: WideString); safecall;
    procedure WriteWideString(const Value: WideString); safecall;
  end;

  TwrpDBGridColumns = class(TwrpCollection, IgsDBGridColumns)
  private
    function  GetDBGridColumns: TDBGridColumns;
  protected
    function  Get_Grid: IgsCustomDBGrid; safecall;
    function  Get_Items(Index: Integer): IgsColumn; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsColumn); safecall;
    function  Get_State: TgsDBGridColumnsState; safecall;
    procedure Set_State(Value: TgsDBGridColumnsState); safecall;
    function  Add: IgsColumn; safecall;
    procedure LoadFromFile(const FileName: WideString); safecall;
    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure RebuildColumns; safecall;
    procedure RestoreDefaults; safecall;
    procedure SaveToFile(const FileName: WideString); safecall;
    procedure SaveToStream(const S: IgsStream); safecall;
  end;

  TwrpColumnTitle = class(TwrpPersistent, IgsColumnTitle)
  private
    function  GetColumnTitle: TColumnTitle;
  protected
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_Column: IgsColumn; safecall;
    function  Get_Font: IgsFont; safecall;
    procedure Set_Font(const Value: IgsFont); safecall;
    function  DefaultAlignment: TgsAlignment; safecall;
    function  DefaultCaption: WideString; safecall;
    function  DefaultColor: Integer; safecall;
    function  DefaultFont: IgsFont; safecall;
    procedure RestoreDefaults; safecall;
  end;

  TwrpColumn = class(TwrpCollectionItem, IgsColumn)
  private
    function  GetColumn: TColumn;
  protected
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_AssignedValues: WideString; safecall;
    function  Get_ButtonStyle: TgsColumnButtonStyle; safecall;
    procedure Set_ButtonStyle(Value: TgsColumnButtonStyle); safecall;
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_DisplayName_: WideString; safecall;
    procedure Set_DisplayName_(const Value: WideString); safecall;
    function  Get_DropDownRows: LongWord; safecall;
    procedure Set_DropDownRows(Value: LongWord); safecall;
    function  Get_Expandable: WordBool; safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    procedure Set_Field(const Value: IgsFieldComponent); safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;
    function  Get_Font: IgsFont; safecall;
    procedure Set_Font(const Value: IgsFont); safecall;
    function  Get_Grid: IgsCustomDBGrid; safecall;
    function  Get_ImeMode: TgsImeMode; safecall;
    procedure Set_ImeMode(Value: TgsImeMode); safecall;
    function  Get_ImeName: WideString; safecall;
    procedure Set_ImeName(const Value: WideString); safecall;
    function  Get_ParentColumn: IgsColumn; safecall;
    function  Get_PickList: IgsStrings; safecall;
    procedure Set_PickList(const Value: IgsStrings); safecall;
    function  Get_PopupMenu: IgsPopupMenu; safecall;
    procedure Set_PopupMenu(const Value: IgsPopupMenu); safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_Showing: WordBool; safecall;
    function  Get_Title: IgsColumnTitle; safecall;
    procedure Set_Title(const Value: IgsColumnTitle); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function  DefaultAlignment: TgsAlignment; safecall;
    function  DefaultColor: Integer; safecall;
    function  DefaultFont: IgsFont; safecall;
    function  DefaultImeMode: TgsImeMode; safecall;
    function  DefaultImeName: WideString; safecall;
    function  DefaultReadOnly: WordBool; safecall;
    function  DefaultWidth: Integer; safecall;
    function  Depth: Integer; safecall;
    procedure RestoreDefaults; safecall;
  end;

  TwrpMonitor = class(TwrpObject, IgsMonitor)
  private
    function  GetMonitor: TMonitor;
  protected
    function  Get_Handle: Integer; safecall;
    function  Get_Height: Integer; safecall;
    function  Get_Left: Integer; safecall;
    function  Get_MonitorNum: Integer; safecall;
    function  Get_Top: Integer; safecall;
    function  Get_Width: Integer; safecall;
  end;

  TwrpOwnedCollection = class(TwrpCollection, IgsOwnedCollection)
  private
    function  GetOwnedCollection: TOwnedCollection;
  protected
    function  Get_Items(Index: Integer): IgsCollectionItem; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsCollectionItem); safecall;
  end;

  TwrpDefCollection = class(TwrpOwnedCollection, IgsDefCollection)
  private
    function  GetDefCollection: TDefCollection;
  protected
    function  Get_DataSet: IgsDataSet; safecall;
    function  Get_Updated: WordBool; safecall;
    procedure Set_Updated(Value: WordBool); safecall;
    function  Find(const AName: WideString): IgsNamedItem; safecall;
    procedure GetItemNames(const List: IgsStrings); safecall;
    function  IndexOf(const AName: WideString): Integer; safecall;
  end;

  TwrpIndexDefs = class(TwrpDefCollection, IgsIndexDefs)
  private
    function  GetIndexDefs: TIndexDefs;
  protected
    function  AddIndexDef: IgsIndexDef; safecall;
    function  Find_(const Name: WideString): IgsIndexDef; safecall;
    procedure Update; safecall;
    function  FindIndexForFields(const Fields: WideString): IgsIndexDef; safecall;
    function  GetIndexForFields(const Fields: WideString; CaseInsensitive: WordBool): IgsIndexDef; safecall;
    function  Get_Items_(Index: Integer): IgsIndexDef; safecall;
    procedure Set_Items_(Index: Integer; const Value: IgsIndexDef); safecall;
    property Items_[Index: Integer]: IgsIndexDef read Get_Items_ write Set_Items_; default;
  end;

  TwrpFieldDefs = class(TwrpDefCollection, IgsFieldDefs)
  private
    function  GetFieldDefs: TFieldDefs;
  protected
    function  Get_HiddenFields: WordBool; safecall;
    procedure Set_HiddenFields(Value: WordBool); safecall;
    function  Get_Items_(Index: Integer): IgsFieldDef; safecall;
    procedure Set_Items_(Index: Integer; const Value: IgsFieldDef); safecall;
    function  Get_ParentDef: IgsFieldDef; safecall;
    procedure Add(const Name: WideString; DataType: TgsFieldType; Size: Integer; Required: WordBool); safecall;
    function  AddFieldDef: IgsFieldDef; safecall;
    function  Find_(const Name: WideString): IgsFieldDef; safecall;
    procedure Update; safecall;
  end;

  TwrpSizeConstraints = class(TwrpPersistent, IgsSizeConstraints)
  private
    function  GetSizeConstraints: TSizeConstraints;
  protected
    function  Get_MaxHeight: Integer; safecall;
    procedure Set_MaxHeight(Value: Integer); safecall;
    function  Get_MaxWidth: Integer; safecall;
    procedure Set_MaxWidth(Value: Integer); safecall;
    function  Get_MinHeight: Integer; safecall;
    procedure Set_MinHeight(Value: Integer); safecall;
    function  Get_MinWidth: Integer; safecall;
    procedure Set_MinWidth(Value: Integer); safecall;
  end;

  TwrpStream = class(TwrpObject, IgsStream)
  private
    function GetStream: TStream;
  protected
    function  Get_Size: Integer; safecall;
    procedure Set_Size(Value: Integer); safecall;
    function  Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    function  CopyFrom(const ASource: IgsStream; ACount: Integer): Integer; safecall;

    procedure FixupResourceHeader(Value: Integer); safecall;
    function  ReadComponent(const Instance: IgsComponent): IgsComponent; safecall;
    function  ReadComponentRes(const Instance: IgsComponent): IgsComponent; safecall;
    procedure ReadResHeader; safecall;
    function  Seek(Offset: Integer; Origin: Word): Integer; safecall;
    procedure WriteComponent(const Instance: IgsComponent); safecall;
    procedure WriteComponentRes(const ResName: WideString; const Instance: IgsComponent); safecall;
    procedure WriteDescendent(const Instance: IgsComponent; const Ancestor: IgsComponent); safecall;
    procedure WriteDescendentRes(const ResName: WideString; const Instance, Ancestor: IgsComponent); safecall;
    procedure WriteResourceHeader(const ResName: WideString; out FixupInfo: OleVariant); safecall;
    function  ReadInteger: Integer; safecall;
    function  ReadSingle: Single; safecall;
    function  ReadCurrency: Currency; safecall;
    function  ReadDate: TDateTime; safecall;
    function  ReadStr(Count: Integer): WideString; safecall;
    function  ReadBoolean: WordBool; safecall;
    function  WriteInteger(Buffer: Integer): Integer; safecall;
    function  WriteSingle(Buffer: Single): Integer; safecall;
    function  WriteCurrency(Buffer: Currency): Integer; safecall;
    function  WriteDate(Buffer: TDateTime): Integer; safecall;
    function  WriteStr(const Buffer: WideString; Count: Integer): Integer; safecall;
    function  WriteBoolean(Buffer: WordBool): Integer; safecall;
  end;

  TwrpHandleStream = class(TwrpStream, IgsHandleStream)
  private
    function  GetHandleStream: THandleStream;
  protected
    function  Get_Handle: Integer; safecall;
    function  ReadInteger: Integer; safecall;
    function  ReadSingle: Single; safecall;
    function  ReadCurrency: Currency; safecall;
    function  ReadDate: TDateTime; safecall;
    function  ReadString(Count: Integer): WideString; safecall;
    function  ReadBoolean: WordBool; safecall;
    function  WriteInteger(Buffer: Integer): Integer; safecall;
    function  WriteSingle(Buffer: Single): Integer; safecall;
    function  WriteCurrency(Buffer: Currency): Integer; safecall;
    function  WriteDate(Buffer: TDateTime): Integer; safecall;
    function  WriteString(const Buffer: WideString; Count: Integer): Integer; safecall;
    function  WriteBoolean(Buffer: WordBool): Integer; safecall;
  end;

  TwrpFileStream = class(TwrpHandleStream, IgsFileStream)
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpStringStream = class(TwrpStream, IgsStringStream)
  private
    function  GetStringStream: TStringStream;
  protected
    function  ReadString(Count: Integer): WideString; safecall;
    procedure WriteString(const AString: WideString); safecall;
    function  Get_DataString: WideString; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpCustomMemoryStream = class(TwrpStream, IgsCustomMemoryStream)
  private
    function  GetCustomMemoryStream: TCustomMemoryStream;
  protected
    procedure SaveToStream(const Stream: IgsStream); safecall;
    procedure SaveToFile(const FileName: WideString); safecall;
    function  ReadInteger: Integer; safecall;
    function  ReadSingle: Single; safecall;
    function  ReadCurrency: Currency; safecall;
    function  ReadDate: TDateTime; safecall;
    function  ReadString(Count: Integer): WideString; safecall;
    function  ReadBoolean: WordBool; safecall;
  end;

  TwrpMemoryStream = class(TwrpCustomMemoryStream, IgsMemoryStream)
  private
    function  GetMemoryStream: TMemoryStream;
  protected
    procedure Clear; safecall;
    procedure LoadFromStream(const Stream: IgsStream); safecall;
    procedure LoadFromFile(const FileName: WideString); safecall;
    procedure SetSize(NewSize: Integer); safecall;
    function  WriteInteger(Buffer: Integer): Integer; safecall;
    function  WriteSingle(Buffer: Single): Integer; safecall;
    function  WriteCurrency(Buffer: Currency): Integer; safecall;
    function  WriteDate(Buffer: TDateTime): Integer; safecall;
    function  WriteString(const Buffer: WideString; Count: Integer): Integer; safecall;
    function  WriteBoolean(Buffer: WordBool): Integer; safecall;
  end;

  TwrpNamedItem = class(TwrpCollectionItem, IgsNamedItem)
  private
    function  GetNamedItem: TNamedItem;
  protected
    function  Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
  end;

  TwrpIndexDef = class(TwrpNamedItem, IgsIndexDef)
  private
    function  GetIndexDef: TIndexDef;
  protected
    function  Get_FieldExpression: WideString; safecall;
    function  Get_CaseInsFields: WideString; safecall;
    procedure Set_CaseInsFields(const Value: WideString); safecall;
    function  Get_DescFields: WideString; safecall;
    procedure Set_DescFields(const Value: WideString); safecall;
    function  Get_Expression: WideString; safecall;
    procedure Set_Expression(const Value: WideString); safecall;
    function  Get_Fields: WideString; safecall;
    procedure Set_Fields(const Value: WideString); safecall;
    function  Get_Source: WideString; safecall;
    procedure Set_Source(const Value: WideString); safecall;
    function  Get_GroupingLevel: Integer; safecall;
    procedure Set_GroupingLevel(Value: Integer); safecall;
    property FieldExpression: WideString read Get_FieldExpression;
    property CaseInsFields: WideString read Get_CaseInsFields write Set_CaseInsFields;
    property DescFields: WideString read Get_DescFields write Set_DescFields;
    property Expression: WideString read Get_Expression write Set_Expression;
    property Fields: WideString read Get_Fields write Set_Fields;
    property Source: WideString read Get_Source write Set_Source;
    property GroupingLevel: Integer read Get_GroupingLevel write Set_GroupingLevel;
  end;

  TwrpFieldDef = class(TwrpNamedItem, IgsFieldDef)
  private
    function  GetFieldDef: TFieldDef;
  protected
    function  Get_Attributes: WideString; safecall;
    procedure Set_Attributes(const Value: WideString); safecall;
    function  Get_ChildDefs: IgsFieldDefs; safecall;
    procedure Set_ChildDefs(const Value: IgsFieldDefs); safecall;
    function  Get_DataType: TgsFieldType; safecall;
    procedure Set_DataType(Value: TgsFieldType); safecall;
    function  Get_FieldNo: Integer; safecall;
    procedure Set_FieldNo(Value: Integer); safecall;
    function  Get_InternalCalcField: WordBool; safecall;
    procedure Set_InternalCalcField(Value: WordBool); safecall;
    function  Get_ParentDef: IgsFieldDef; safecall;
    function  Get_Precision: Integer; safecall;
    procedure Set_Precision(Value: Integer); safecall;
    function  Get_Required: WordBool; safecall;
    procedure Set_Required(Value: WordBool); safecall;
    function  Get_Size: Integer; safecall;
    procedure Set_Size(Value: Integer); safecall;
    function  AddChild: IgsFieldDef; safecall;
    function  HasChildDefs: WordBool; safecall;
  end;

  TwrpApplication = class(TwrpComponent, IgsApplication)
  protected
    procedure ProcessMessages; safecall;
    function  Get_Active: WordBool; safecall;
    function  Get_MainForm: IgsForm; safecall;
    function  Get_Title: WideString; safecall;
    procedure Set_Title(const Value: WideString); safecall;
    procedure BringToFront; safecall;
    function  MessageBox(const Text: WideString; const Caption: WideString; Flags: Integer): Integer; safecall;
    procedure Minimize; safecall;
    procedure NormalizeAllTopMosts; safecall;
    procedure NormalizeTopMosts; safecall;
    procedure Restore; safecall;
    procedure RestoreTopMosts; safecall;
    procedure Terminate; safecall;
    function  Get_BiDiMode: TgsBiDiMode; safecall;
    procedure Set_BiDiMode(Value: TgsBiDiMode); safecall;
    function  Get_NonBiDiKeyboard: WideString; safecall;
    procedure Set_NonBiDiKeyboard(const Value: WideString); safecall;
    function  Get_Terminated: WordBool; safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    procedure HandleMessage; safecall;
    function  HelpCommand(Command: Integer; Data: Integer): WordBool; safecall;
    function  Get_Handle: Integer; safecall;

    function  Get_AllowTesting: WordBool; safecall;
    procedure Set_AllowTesting(Value: WordBool); safecall;
    function  Get_CurrentHelpFile: WideString; safecall;
    function  Get_DialogHandle: LongWord; safecall;
    procedure Set_DialogHandle(Value: LongWord); safecall;
    function  Get_ExeName: WideString; safecall;
    function  Get_HelpFile: WideString; safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    function  Get_Hint: WideString; safecall;
    procedure Set_Hint(const Value: WideString); safecall;
    function  Get_HintColor: Integer; safecall;
    procedure Set_HintColor(Value: Integer); safecall;
    function  Get_HintHidePause: Integer; safecall;
    procedure Set_HintHidePause(Value: Integer); safecall;
    function  Get_HintPause: Integer; safecall;
    procedure Set_HintPause(Value: Integer); safecall;
    function  Get_HintShortCuts: WordBool; safecall;
    procedure Set_HintShortCuts(Value: WordBool); safecall;
    function  Get_HintShortPause: Integer; safecall;
    procedure Set_HintShortPause(Value: Integer); safecall;
    function  Get_Icon: IgsIcon; safecall;
    procedure Set_Icon(const Value: IgsIcon); safecall;
    function  Get_BiDiKeyboard: WideString; safecall;
    procedure Set_BiDiKeyboard(const Value: WideString); safecall;
    function  Get_ShowHint: WordBool; safecall;
    procedure Set_ShowHint(Value: WordBool); safecall;
    function  Get_ShowMainForm: WordBool; safecall;
    procedure Set_ShowMainForm(Value: WordBool); safecall;
    function  Get_UpdateFormatSettings: WordBool; safecall;
    procedure Set_UpdateFormatSettings(Value: WordBool); safecall;
    function  Get_UpdateMetricSettings: WordBool; safecall;
    procedure Set_UpdateMetricSettings(Value: WordBool); safecall;
    procedure ActivateHint(X: Integer; Y: Integer); safecall;
    procedure CancelHint; safecall;
    procedure ControlDestroyed(const Control: IgsControl); safecall;
    procedure HandleException(const Sender: IgsObject); safecall;
    function  HelpContext(Context: Integer): WordBool; safecall;
    function  HelpJump(const JumpID: WideString): WordBool; safecall;
    procedure HideHint; safecall;
    procedure Initialize; safecall;
    function  IsRightToLeft: WordBool; safecall;
    function  UpdateAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UseRightToLeftAlignment: WordBool; safecall;
    function  UseRightToLeftReading: WordBool; safecall;
    function  UseRightToLeftScrollBar: WordBool; safecall;
    function  Get_DecimalSeparatorSys: WideString; safecall;
    function  Get_CurrencySeparatorSys: WideString; safecall;

    function  GetFIOCase(const SurName: WideString; const FirstName: WideString;
                      const MiddleName: WideString; Sex: Integer; TheCase: Integer): WideString; safecall;
    function  GetComplexCase(const TheWord: WideString; TheCase: Integer): WideString; safecall;
    function  GetNumericWordForm(ANum: Integer; const AStrForm1: WideString;
                               const AStrForm2: WideString; const AStrForm5: WideString): WideString; safecall;
    procedure MimeEncodeStream(const InputStream: IgsStream; const OutputStream: IgsStream;
                               WithCRLF: WordBool); safecall;
    procedure MimeDecodeStream(const InputStream: IgsStream; const OutputStream: IgsStream); safecall;
  end;

  TwrpScreen = class(TwrpComponent, IgsScreen)
  protected
    procedure DisableAlign; safecall;
    procedure EnableAlign; safecall;
    procedure Realign; safecall;
    procedure ResetFonts; safecall;
    function  Get_ActiveControl: IgsControl; safecall;
    function  Get_ActiveCustomForm: IgsCustomForm; safecall;
    function  Get_ActiveForm: IgsForm; safecall;
    function  Get_Cursor: Integer; safecall;
    procedure Set_Cursor(Value: Integer); safecall;
    function  Get_Cursors(Index: Integer): Integer; safecall;
    procedure Set_Cursors(Index: Integer; Value: Integer); safecall;
    function  Get_CustomFormCount: Integer; safecall;
    function  Get_CustomForms(Index: Integer): IgsCustomForm; safecall;
    function  Get_DataModuleCount: Integer; safecall;
    function  Get_DataModules(Index: Integer): IgsDataModule; safecall;
    function  Get_DefaultIme: WideString; safecall;
    function  Get_DefaultKbLayout: Integer; safecall;
    function  Get_DesktopHeight: Integer; safecall;
    function  Get_DesktopLeft: Integer; safecall;
    function  Get_DesktopTop: Integer; safecall;
    function  Get_DesktopWidth: Integer; safecall;
    function  Get_HintFont: IgsFont; safecall;
    procedure Set_HintFont(const Value: IgsFont); safecall;
    function  Get_IconFont: IgsFont; safecall;
    procedure Set_IconFont(const Value: IgsFont); safecall;
    function  Get_MenuFont: IgsFont; safecall;
    procedure Set_MenuFont(const Value: IgsFont); safecall;
    function  Get_Fonts: IgsStrings; safecall;
    function  Get_FormCount: Integer; safecall;
    function  Get_Forms(Index: Integer): IgsForm; safecall;
    function  Get_Imes: IgsStrings; safecall;
    function  Get_Height: Integer; safecall;
    function  Get_PixelsPerInch: Integer; safecall;
    function  Get_Width: Integer; safecall;
  end;

  TwrpDataModule = class(TwrpComponent, IgsDataModule)
  private
    function  GetDataModule: TDataModule;
  protected
    procedure AfterConstruction_; safecall;
    procedure BeforeDestruction_; safecall;
    function  Get_OldCreateOrder: WordBool; safecall;
    procedure Set_OldCreateOrder(Value: WordBool); safecall;
  end;

  TwrpBasicAction = class(TwrpComponent, IgsBasicAction)
  private
    function  GetBasicAction: TBasicAction;
  protected
    function  Execute: WordBool; safecall;
    procedure ExecuteTarget(const Target: IgsObject); safecall;
    procedure HandlesTarget(const Target: IgsObject); safecall;
    procedure RegisterChanges(const Value: IgsBasicActionLink); safecall;
    procedure UnRegisterChanges(const Value: IgsBasicActionLink); safecall;
    function  Update: WordBool; safecall;
    procedure UpdateTarget(const Target: IgsObject); safecall;
  end;

  TwrpControl = class(TwrpComponent, IgsControl)
  private
    function GetControl: TControl;
  protected
    procedure Refresh; safecall;
    procedure Repaint; safecall;
    function  HasParent: WordBool; safecall;
    function  Get_Anchors: WideString; safecall;
    procedure Set_Anchors(const Value: WideString); safecall;
    function  Get_Left: Integer; safecall;
    procedure Set_Left(Value: Integer); safecall;
    function  Get_Top: Integer; safecall;
    procedure Set_Top(Value: Integer); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function  Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function  Get_Hint: WideString; safecall;
    procedure Set_Hint(const Value: WideString); safecall;
    procedure InitiateAction; safecall;
    function  Get_Align: TgsAlign; safecall;
    procedure Set_Align(Value: TgsAlign); safecall;
    function  Get_BiDiMode: TgsBiDiMode; safecall;
    procedure Set_BiDiMode(Value: TgsBiDiMode); safecall;
    function  Get_ClientHeight: Integer; safecall;
    procedure Set_ClientHeight(Value: Integer); safecall;
    function  Get_ClientWidth: Integer; safecall;
    procedure Set_ClientWidth(Value: Integer); safecall;
    function  Get_Constraints: IgsSizeConstraints; safecall;
    procedure Set_Constraints(const Value: IgsSizeConstraints); safecall;
    function  Get_ControlState: WideString; safecall;
    procedure Set_ControlState(const Value: WideString); safecall;
    function  Get_ControlStyle: WideString; safecall;
    procedure Set_ControlStyle(const Value: WideString); safecall;
    function  Get_Cursor: Smallint; safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    function  Get_DockOrientation: TgsDockOrientation; safecall;
    procedure Set_DockOrientation(Value: TgsDockOrientation); safecall;
    function  Get_LRDockWidth: Integer; safecall;
    procedure Set_LRDockWidth(Value: Integer); safecall;
    function  Get_ShowHint: WordBool; safecall;
    procedure Set_ShowHint(Value: WordBool); safecall;
    function  Get_TBDockHeight: Integer; safecall;
    procedure Set_TBDockHeight(Value: Integer); safecall;
    function  Get_UndockHeight: Integer; safecall;
    procedure Set_UndockHeight(Value: Integer); safecall;
    function  Get_UndockWidth: Integer; safecall;
    procedure Set_UndockWidth(Value: Integer); safecall;
    procedure BringToFront; safecall;
    function  DrawTextBiDiModeFlags(Flags: Integer): Integer; safecall;
    function  DrawTextBiDiModeFlagsReadingOnly: Integer; safecall;
    procedure EndDrag(Drop: WordBool); safecall;
    function  IsRightToLeft: WordBool; safecall;
    procedure SendToBack; safecall;
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); safecall;
    procedure Show; safecall;
    procedure Update; safecall;
    function  UseRightToLeftAlignment: WordBool; safecall;
    function  UseRightToLeftReading: WordBool; safecall;
    function  UseRightToLeftScrollBar: WordBool; safecall;
    function  Get_Action: IgsBasicAction; safecall;
    procedure Set_Action(const Value: IgsBasicAction); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_AutoSize: WordBool; safecall;
    procedure Set_AutoSize(Value: WordBool); safecall;
    function  Get_DesktopFont: WordBool; safecall;
    procedure Set_DesktopFont(Value: WordBool); safecall;
    function  Get_DragCursor: Smallint; safecall;
    procedure Set_DragCursor(Value: Smallint); safecall;
    function  Get_DragKind: TgsDragKind; safecall;
    procedure Set_DragKind(Value: TgsDragKind); safecall;
    function  Get_DragMode: TgsDragMode; safecall;
    procedure Set_DragMode(Value: TgsDragMode); safecall;
    function  Get_Font: IgsFont; safecall;
    procedure Set_Font(const Value: IgsFont); safecall;
    function  Get_IsControl: WordBool; safecall;
    procedure Set_IsControl(Value: WordBool); safecall;
    function  Get_ParentColor: WordBool; safecall;
    procedure Set_ParentColor(Value: WordBool); safecall;
    function  Get_ParentBiDiMode: WordBool; safecall;
    procedure Set_ParentBiDiMode(Value: WordBool); safecall;
    function  Get_ParentFont: WordBool; safecall;
    procedure Set_ParentFont(Value: WordBool); safecall;
    function  Get_ParentShowHint: WordBool; safecall;
    procedure Set_ParentShowHint(Value: WordBool); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_Name_: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    procedure AdjustSize; safecall;
    procedure BeginAutoDrag; safecall;
    procedure Changed; safecall;
    procedure ChangeScale(M: Integer; D: Integer); safecall;
    procedure ConstrainedResize(MinWidth: Integer; MinHeight: Integer; MaxWidth: Integer;
                                MaxHeight: Integer); safecall;
    procedure DblClick; safecall;
    function  PaletteChanged(Foreground: WordBool): WordBool; safecall;
    procedure RequestAlign; safecall;
    procedure Resize; safecall;
    procedure VisibleChanging; safecall;
    procedure Hide; safecall;
    function  Get_Parent: IgsWinControl; safecall;
    procedure Set_Parent(const Value: IgsWinControl); safecall;
    function  Get_Floating: WordBool; safecall;
    function  Get_HostDockSite: IgsWinControl; safecall;
    procedure Set_HostDockSite(const Value: IgsWinControl); safecall;
    function  Get_PopupMenu: IgsPopupMenu; safecall;
    procedure Set_PopupMenu(const Value: IgsPopupMenu); safecall;
    procedure BeginDrag(Immediate: WordBool; Threshold: Integer); safecall;
    procedure DragDrop(const Source: IgsObject; X: Integer; Y: Integer); safecall;
    function  Dragging: WordBool; safecall;
    function  GetControlsAlignment: TgsAlignment; safecall;
    procedure Invalidate; safecall;
    function  ManualDock(const NewDockSite: IgsWinControl; const DropControl: IgsControl;
                         ControlSide: TgsAlign): WordBool; safecall;
    function  Perform(Msg: LongWord; WParam: Integer; LParam: Integer): Integer; safecall;
    function  ReplaceDockedControl(const Control: IgsControl; const NewDockSite: IgsWinControl;
                                   const DropControl: IgsControl; ControlSide: TgsAlign): WordBool; safecall;
    procedure ClientToScreen(ClientX: Integer; ClientY: Integer; out ScreenX: OleVariant;
                             out ScreenY: OleVariant); safecall;
    procedure ScreenToClient(out ClientX: OleVariant; out ClientY: OleVariant; ScreenX: Integer;
                             ScreenY: Integer); safecall;
  end;

  TwrpDragObject = class(TwrpObject, IgsDragObject)
  private
    function  GetDragObject: TDragObject;
  protected
    procedure Assign_(const Source: IgsDragObject); safecall;
    function  GetName: WideString; safecall;
    procedure HideDragImage; safecall;
    function  Instance: LongWord; safecall;
    procedure ShowDragImage; safecall;
    function  Get_Cancelling: WordBool; safecall;
    procedure Set_Cancelling(Value: WordBool); safecall;
    function  Get_DragHandle: LongWord; safecall;
    procedure Set_DragHandle(Value: LongWord); safecall;
  end;

  TwrpBaseDragControlObject = class(TwrpDragObject, IgsBaseDragControlObject)
  private
    function  GetBaseDragControlObject: TBaseDragControlObject;
  protected
    function  Get_Control: IgsControl; safecall;
    procedure Set_Control(const Value: IgsControl); safecall;
  end;

  TwrpDragDockObject = class(TwrpBaseDragControlObject, IgsDragDockObject)
  private
    function  GetDragDockObject: TDragDockObject;
  protected
    function  Get_Brush: IgsBrush; safecall;
    procedure Set_Brush(const Value: IgsBrush); safecall;
    function  Get_DropAlign: TgsAlign; safecall;
    function  Get_DropOnControl: IgsControl; safecall;
    function  Get_Floating: WordBool; safecall;
    procedure Set_Floating(Value: WordBool); safecall;
    function  Get_FrameWidth: Integer; safecall;
  end;

  TwrpWinControl = class(TwrpControl, IgsWinControl)
  private
    function GetWinControl: TWinControl;
  protected
    procedure Repaint; safecall;
    function Focused: WordBool; safecall;
    procedure SetFocus; safecall;
    function  Get_TabStop: WordBool; safecall;
    procedure Set_TabStop(Value: WordBool); safecall;
    function  Get_TabOrder: Integer; safecall;
    procedure Set_TabOrder(Value: Integer); safecall;
    function  Get_Handle: LongWord; safecall;
    function  Get_BevelInner: TgsBevelCut; safecall;
    procedure Set_BevelInner(Value: TgsBevelCut); safecall;
    function  Get_BevelOuter: TgsBevelCut; safecall;
    procedure Set_BevelOuter(Value: TgsBevelCut); safecall;
    function  Get_BevelKind: TgsBevelKind; safecall;
    procedure Set_BevelKind(Value: TgsBevelKind); safecall;
    function  Get_BevelWidth: Integer; safecall;
    procedure Set_BevelWidth(Value: Integer); safecall;
    function  Get_BorderWidth: Integer; safecall;
    procedure Set_BorderWidth(Value: Integer); safecall;
    function  Get_Ctl3D: WordBool; safecall;
    procedure Set_Ctl3D(Value: WordBool); safecall;
    function  Get_DockSite: WordBool; safecall;
    procedure Set_DockSite(Value: WordBool); safecall;
    function  Get_ImeMode: TgsImeMode; safecall;
    procedure Set_ImeMode(Value: TgsImeMode); safecall;
    function  Get_ImeName: WideString; safecall;
    procedure Set_ImeName(const Value: WideString); safecall;
    function  Get_ParentCtl3D: WordBool; safecall;
    procedure Set_ParentCtl3D(Value: WordBool); safecall;
    function  Get_UseDockManager: WordBool; safecall;
    procedure Set_UseDockManager(Value: WordBool); safecall;
    function  Get_WheelAccumulator: Integer; safecall;
    procedure Set_WheelAccumulator(Value: Integer); safecall;

    function  Get_Brush: IgsBrush; safecall;
    function  Get_ControlCount: Integer; safecall;
    function  Get_DockClientCount: Integer; safecall;
    function  Get_DockClients(Index: Integer): IgsControl; safecall;
    function  Get_DoubleBuffered: WordBool; safecall;
    procedure Set_DoubleBuffered(Value: WordBool); safecall;
    function  Get_HelpContext: Integer; safecall;
    procedure Set_HelpContext(Value: Integer); safecall;
    function  Get_ParentWindow: Integer; safecall;
    procedure Set_ParentWindow(Value: Integer); safecall;
    function  Get_Showing: WordBool; safecall;
    function  Get_VisibleDockClientCount: Integer; safecall;
    function  CanFocus: WordBool; safecall;
    function  ContainsControl(const Control: IgsControl): WordBool; safecall;
    function  Get_Controls(Index: Integer): IgsControl; safecall;
    procedure DisableAlign; safecall;
    procedure DockDrop(const Source: IgsDragDockObject; X: Integer; Y: Integer); safecall;
    procedure EnableAlign; safecall;
    function  FindChildControl(const ControlName: WideString): IgsControl; safecall;
    procedure FlipChildren(AllLevels: WordBool); safecall;
    procedure GetTabOrderList(const List: IgsList); safecall;
    procedure PaintTo(DC: Integer; X: Integer; Y: Integer); safecall;
    procedure Realign; safecall;
    procedure RemoveControl(const AControl: IgsControl); safecall;
    procedure ScaleBy(M: Integer; D: Integer); safecall;
    procedure ScrollBy(DeltaX: Integer; DeltaY: Integer); safecall;
    procedure UpdateControlState; safecall;
    procedure InsertControl(const Control: IgsControl); safecall;
    function  ControlAtPos(X: Integer; Y: Integer; AllowDisabled: WordBool;
                           AllowWinControls: WordBool): IgsControl; safecall;
  end;

  TwrpOLEControl = class(TwrpWinControl, IgsOLEControl)
  end;

  TwrpWebBrowser = class(TwrpOLEControl, IgsWebBrowser)
  private
    function GetWebBrowser: TWebBrowser;
  protected
    procedure GoForward; safecall;
    procedure GoBack; safecall;
    procedure GoHome; safecall;
    procedure GoSearch; safecall;
    procedure Navigate(const URL: WideString; var Flags: OleVariant;
                       var TargetFrameName: OleVariant; var PostData: OleVariant;
                       var Headers: OleVariant); safecall;
    procedure Refresh_; safecall;
    procedure Refresh2(var Level: OleVariant); safecall;
    procedure Stop; safecall;
    function  Get_Application: IDispatch; safecall;
    function  Get_Container: IDispatch; safecall;
    function  Get_Document: IDispatch; safecall;
    function  Get_TopLevelContainer: WordBool; safecall;
    function  Get_Type_: WideString; safecall;
    function  Get_LocationName: WideString; safecall;
    function  Get_LocationURL: WideString; safecall;
    function  Get_Busy: WordBool; safecall;
    procedure Navigate2(var URL: OleVariant; var Flags: OleVariant;
                        var TargetFrameName: OleVariant; var PostData: OleVariant;
                        var Headers: OleVariant); safecall;
    function  QueryStatusWB(cmdID: Integer): Integer; safecall;
    procedure ExecWB(cmdID: Integer; cmdExecOpt: Integer; var pvaIn: OleVariant;
                     var pvaOut: OleVariant); safecall;
    procedure ShowBrowserBar(var pvaClsID: OleVariant; var pvarShow: OleVariant;
                             var pvarSize: OleVariant); safecall;
    function  Get_ReadyState: Integer; safecall;
    function  Get_Offline: WordBool; safecall;
    procedure Set_Offline(Value: WordBool); safecall;
    function  Get_Silent: WordBool; safecall;
    procedure Set_Silent(Value: WordBool); safecall;
    function  Get_RegisterAsBrowser: WordBool; safecall;
    procedure Set_RegisterAsBrowser(Value: WordBool); safecall;
    function  Get_RegisterAsDropTarget: WordBool; safecall;
    procedure Set_RegisterAsDropTarget(Value: WordBool); safecall;
    function  Get_TheaterMode: WordBool; safecall;
    procedure Set_TheaterMode(Value: WordBool); safecall;
    function  Get_AddressBar: WordBool; safecall;
    procedure Set_AddressBar(Value: WordBool); safecall;
    function  Get_Resizable: WordBool; safecall;
    procedure Set_Resizable(Value: WordBool); safecall;
  end;

  TwrpControlScrollBar = class(TwrpPersistent, IgsControlScrollBar)
  private
    function  GetControlScrollBar: TControlScrollBar;
  protected
    function  Get_ButtonSize: Integer; safecall;
    procedure Set_ButtonSize(Value: Integer); safecall;
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_Increment: Word; safecall;
    procedure Set_Increment(Value: Word); safecall;
    function  Get_Kind: TgsScrollBarKind; safecall;
    function  Get_Margin: Word; safecall;
    procedure Set_Margin(Value: Word); safecall;
    function  Get_ParentColor: WordBool; safecall;
    procedure Set_ParentColor(Value: WordBool); safecall;
    function  Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    function  Get_Range: Integer; safecall;
    procedure Set_Range(Value: Integer); safecall;
    function  Get_ScrollPos: Integer; safecall;
    function  Get_Size: Integer; safecall;
    procedure Set_Size(Value: Integer); safecall;
    function  Get_Smooth: WordBool; safecall;
    procedure Set_Smooth(Value: WordBool); safecall;
    function  Get_Style: TgsScrollBarStyle; safecall;
    procedure Set_Style(Value: TgsScrollBarStyle); safecall;
    function  Get_ThumbSize: Integer; safecall;
    procedure Set_ThumbSize(Value: Integer); safecall;
    function  Get_Tracking: WordBool; safecall;
    procedure Set_Tracking(Value: WordBool); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    procedure ChangeBiDiPosition; safecall;
    function  IsScrollBarVisible: WordBool; safecall;
  end;

  TwrpScrollingWinControl = class(TwrpWinControl, IgsScrollingWinControl)
  private
    function GetScrollingWinControl: TScrollingWinControl;
  protected
    function  Get_AutoScroll: WordBool; safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    function  Get_HorzScrollBar: IgsControlScrollBar; safecall;
    procedure Set_HorzScrollBar(const Value: IgsControlScrollBar); safecall;
    function  Get_VertScrollBar: IgsControlScrollBar; safecall;
    procedure Set_VertScrollBar(const Value: IgsControlScrollBar); safecall;
    procedure DisableAutoRange; safecall;
    procedure EnableAutoRange; safecall;
    procedure ScrollInView(const AControl: IgsControl); safecall;
  end;

  TwrpGraphicControl = class(TwrpControl, IgsGraphicControl)
  private
    function GetGraphicControl: TGraphicControl;
  public
    function  Get_Canvas: IgsCanvas; safecall;
    procedure Paint; safecall;
  end;

  TwrpToolButton = class(TwrpGraphicControl, IgsToolButton)
  private
    function  GetToolButton: TToolButton;
  protected
    function  CheckMenuDropdown: WordBool; safecall;
    procedure Click; safecall;
    function  Get_Index: Integer; safecall;
    function  Get_AllowAllUp: WordBool; safecall;
    procedure Set_AllowAllUp(Value: WordBool); safecall;
    function  Get_Down: WordBool; safecall;
    procedure Set_Down(Value: WordBool); safecall;
    function  Get_DropdownMenu: IgsPopupMenu; safecall;
    procedure Set_DropdownMenu(const Value: IgsPopupMenu); safecall;
    function  Get_Grouped: WordBool; safecall;
    procedure Set_Grouped(Value: WordBool); safecall;
    function  Get_ImageIndex: Integer; safecall;
    procedure Set_ImageIndex(Value: Integer); safecall;
    function  Get_Indeterminate: WordBool; safecall;
    procedure Set_Indeterminate(Value: WordBool); safecall;
    function  Get_Marked: WordBool; safecall;
    procedure Set_Marked(Value: WordBool); safecall;
    function  Get_MenuItem: IgsMenuItem; safecall;
    procedure Set_MenuItem(const Value: IgsMenuItem); safecall;
    function  Get_Wrap: WordBool; safecall;
    procedure Set_Wrap(Value: WordBool); safecall;
    function  Get_Style: TgsToolButtonStyle; safecall;
    procedure Set_Style(Value: TgsToolButtonStyle); safecall;
    property Index: Integer read Get_Index;
    property AllowAllUp: WordBool read Get_AllowAllUp write Set_AllowAllUp;
    property Down: WordBool read Get_Down write Set_Down;
    property DropdownMenu: IgsPopupMenu read Get_DropdownMenu write Set_DropdownMenu;
    property Grouped: WordBool read Get_Grouped write Set_Grouped;
    property ImageIndex: Integer read Get_ImageIndex write Set_ImageIndex;
    property Indeterminate: WordBool read Get_Indeterminate write Set_Indeterminate;
    property Marked: WordBool read Get_Marked write Set_Marked;
    property MenuItem: IgsMenuItem read Get_MenuItem write Set_MenuItem;
    property Wrap: WordBool read Get_Wrap write Set_Wrap;
    property Style: TgsToolButtonStyle read Get_Style write Set_Style;
  end;

  TwrpCustomForm = class(TwrpScrollingWinControl, IgsCustomForm)
  private
    function GetCustomForm: TCustomForm;
  protected
    procedure Close; safecall;
    procedure Release; safecall;
    function  Get_Active: WordBool; safecall;
    function  Get_BorderStyle: TgsFormBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsFormBorderStyle); safecall;
    function  Get_DefaultMonitor: TgsDefaultMonitor; safecall;
    procedure Set_DefaultMonitor(Value: TgsDefaultMonitor); safecall;
    function  Get_FormStyle: TgsFormStyle; safecall;
    procedure Set_FormStyle(Value: TgsFormStyle); safecall;
    function  Get_KeyPrewiew: WordBool; safecall;
    procedure Set_KeyPrewiew(Value: WordBool); safecall;
    function  Get_MDIChildCount: Integer; safecall;
    function  Get_PixelsPerInch: Integer; safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    function  Get_Position: TgsPosition; safecall;
    procedure Set_Position(Value: TgsPosition); safecall;
    function  Get_PrintScale: TgsPrintScale; safecall;
    procedure Set_PrintScale(Value: TgsPrintScale); safecall;
    function  Get_Scaled: WordBool; safecall;
    procedure Set_Scaled(Value: WordBool); safecall;
    function  Get_TileMode: TgsTileMode; safecall;
    procedure Set_TileMode(Value: TgsTileMode); safecall;
    function  Get_ModalResult: Integer; safecall;
    procedure Set_ModalResult(Value: Integer); safecall;
    function  Get_Canvas: IgsCanvas; safecall;
    procedure Print; safecall;
    function ShowModal: Integer; safecall;
    procedure UpdateActions; safecall;
    procedure UpdateWindowState ; safecall;
    function  Get_WindowState: TgsWindowState; safecall;
    procedure Set_WindowState(Value: TgsWindowState); safecall;
    function  Get_WindowMenu: IgsMenuItem; safecall;
    procedure Set_WindowMenu(const Value: IgsMenuItem); safecall;

    function  Get_ActiveControl: IgsWinControl; safecall;
    procedure Set_ActiveControl(const Value: IgsWinControl); safecall;
    function  Get_ActiveOLEControl: IgsWinControl; safecall;
    procedure Set_ActiveOLEControl(const Value: IgsWinControl); safecall;
    function  Get_DropTarget: WordBool; safecall;
    procedure Set_DropTarget(Value: WordBool); safecall;
    function  Get_FormState: WideString; safecall;
    function  Get_HelpFile: WideString; safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    function  Get_KeyPreview: WordBool; safecall;
    procedure Set_KeyPreview(Value: WordBool); safecall;
    function  Get_Menu: IgsMainMenu; safecall;
    procedure Set_Menu(const Value: IgsMainMenu); safecall;
    function  Get_Monitor: IgsMonitor; safecall;
    function  CloseQuery: WordBool; safecall;
    procedure DefocusControl(const Control: IgsWinControl; Removing: WordBool); safecall;
    procedure FocusControl(const Control: IgsWinControl); safecall;
    function  GetFormImage: IgsBitmap; safecall;
    procedure SendCancelMode(const Sender: IgsControl); safecall;
    procedure Activate; safecall;
  end;

  TwrpCustomLabel = class(TwrpGraphicControl, IgsCustomLabel)
  private
    function  GetCustomLabel: TCustomLabel;
  protected
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;

    function  Get_FocusControl: IgsWinControl; safecall;
    procedure Set_FocusControl(const Value: IgsWinControl); safecall;
    function  Get_Layout: TgsTextLayout; safecall;
    procedure Set_Layout(Value: TgsTextLayout); safecall;
    function  Get_ShowAccelChar: WordBool; safecall;
    procedure Set_ShowAccelChar(Value: WordBool); safecall;
    function  Get_WordWrap: WordBool; safecall;
    procedure Set_WordWrap(Value: WordBool); safecall;
  end;

  TwrpLabel = class(TwrpCustomLabel, IgsLabel)
  end;

  TwrpButtonControl = class(TwrpWinControl, IgsButtonControl)
  private
    function GetButtonControl: TButtonControl;
  protected
    function  Get_Checked: WordBool; safecall;
    procedure Set_Checked(Value: WordBool); safecall;
    function  Get_ClicksDisabled: WordBool; safecall;
    procedure Set_ClicksDisabled(Value: WordBool); safecall;
  end;

  TwrpButton = class(TwrpButtonControl, IgsButton)
  private
    function GetButton: TButton;
  protected
    procedure Click; safecall;
    function  Get_Cancel: WordBool; safecall;
    procedure Set_Cancel(Value: WordBool); safecall;
    function  Get_Default: WordBool; safecall;
    procedure Set_Default(Value: WordBool); safecall;
    function  Get_ModalResult: Integer; safecall;
    procedure Set_ModalResult(Value: Integer); safecall;
  end;

  TwrpForm = class(TwrpCustomForm, IgsForm)
  private
    function GetForm: TForm;
  protected
    procedure ArrangeIcons; safecall;
    procedure Cascade; safecall;
    procedure Tile; safecall;
    procedure Next; safecall;
    procedure Previous; safecall;
  end;

  TwrpObjectField = class(TwrpField, IgsObjectField)
  private
    function  GetObjectField: TObjectField;
  protected
    function  Get_FieldCount: Integer; safecall;
    function  Get_Fields: IgsFields; safecall;
    function  Get_FieldValues(Index: Integer): OleVariant; safecall;
    procedure Set_FieldValues(Index: Integer; Value: OleVariant); safecall;
    function  Get_ObjectType: WideString; safecall;
    procedure Set_ObjectType(const Value: WideString); safecall;
    function  Get_UnNamed: WordBool; safecall;
  end;

  TwrpDataSetField = class(TwrpObjectField, IgsDataSetField)
  private
    function  GetDataSetField: TDataSetField;
  protected
    function  Get_IncludeObjectField: WordBool; safecall;
    procedure Set_IncludeObjectField(Value: WordBool); safecall;
    function  Get_NestedDataSet: IgsDataSet; safecall;
  end;

  TwrpFields = class(TwrpObject, IgsFields)
  private
    function  GetFields: TFields;
  protected
    function  Get_Count: Integer; safecall;
    function  Get_DataSet: IgsDataSet; safecall;
    function  Get_Fields(Index: Integer): IgsFieldComponent; safecall;
    procedure Set_Fields(Index: Integer; const Value: IgsFieldComponent); safecall;
    procedure Add(const Field: IgsFieldComponent); safecall;
    procedure CheckFieldName(const FieldName: WideString); safecall;
    procedure CheckFieldNames(const FieldNames: WideString); safecall;
    procedure Clear; safecall;
    function  FieldByName(const FieldName: WideString): IgsFieldComponent; safecall;
    function  FieldByNumber(FieldNo: Integer): IgsFieldComponent; safecall;
    function  FindField(const FieldName: WideString): IgsFieldComponent; safecall;
    procedure GetFieldNames(const List: IgsStrings); safecall;
    function  IndexOf(const Field: IgsFieldComponent): Integer; safecall;
    procedure Remove(const Field: IgsFieldComponent); safecall;
  end;


  TwrpDataSet = class(TwrpComponent, IgsDataSet)
  private
    function GetDataSet: TDataSet;
  protected
    procedure Open; safecall;
    procedure Close; safecall;
    procedure Edit; safecall;
    procedure First; safecall;
    procedure Last; safecall;
    procedure Delete; safecall;
    procedure Post; safecall;
    procedure Prior; safecall;
    procedure Next; safecall;
    function  Get_Active: WordBool; safecall;
    procedure Set_Active(Value: WordBool); safecall;
    function  FieldByName(const FieldName: WideString): IgsFieldComponent; safecall;
    function  Get_Eof: WordBool; safecall;
    function  Get_Bof: WordBool; safecall;
    function  Get_State: TgsDataSetState; safecall;
    function  Get_DataSetField: IgsDataSetField; safecall;
    procedure Set_DataSetField(const Value: IgsDataSetField); safecall;
    procedure Append; safecall;
    procedure Insert; safecall;
    procedure Cancel; safecall;
    procedure CheckBrowseMode; safecall;
    procedure ClearFields; safecall;
    function  ControlsDisabled: WordBool; safecall;
    procedure CursorPosChanged; safecall;
    procedure DisableControls; safecall;
    procedure EnableControls; safecall;
    function  FindField(const FieldName: WideString): IgsFieldComponent; safecall;
    function  FindFirst: WordBool; safecall;
    function  FindLast: WordBool; safecall;
    function  FindNext: WordBool; safecall;
    function  FindPrior: WordBool; safecall;
    function  IsEmpty: WordBool; safecall;
    function  IsLinkedTo(const DataSource: IgsDataSource): WordBool; safecall;
    function  IsSequenced: WordBool; safecall;
    procedure Refresh; safecall;
    procedure UpdateCursorPos; safecall;
    procedure UpdateRecord; safecall;
    function  Get_ActiveRecord: Integer; safecall;
    function  Get_AggFields: IgsFields; safecall;
    function  Get_AutoCalcFields: WordBool; safecall;
    procedure Set_AutoCalcFields(Value: WordBool); safecall;
    function  Get_BlobFieldCount: Integer; safecall;
    function  Get_BlockReadSize: Integer; safecall;
    procedure Set_BlockReadSize(Value: Integer); safecall;
    function  Get_Bookmark: WideString; safecall;
    procedure Set_Bookmark(const Value: WideString); safecall;
    function  Get_BookmarkSize: Integer; safecall;
    procedure Set_BookmarkSize(Value: Integer); safecall;
    function  Get_BufferCount: Integer; safecall;
    function  Get_CalcFieldsSize: Integer; safecall;
    function  Get_CanModify: WordBool; safecall;
    function  Get_CurrentRecord: Integer; safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    function  Get_DefaultFields: WordBool; safecall;
    function  Get_FieldCount: Integer; safecall;
    function  Get_FieldNoOfs: Integer; safecall;
    procedure Set_FieldNoOfs(Value: Integer); safecall;
    function  Get_Fields: IgsFields; safecall;
    function  Get_FieldValues(const FieldName: WideString): OleVariant; safecall;
    procedure Set_FieldValues(const FieldName: WideString; Value: OleVariant); safecall;
    function  Get_Filter: WideString; safecall;
    procedure Set_Filter(const Value: WideString); safecall;
    function  Get_Filtered: WordBool; safecall;
    procedure Set_Filtered(Value: WordBool); safecall;
    function  Get_Found: WordBool; safecall;
    function  Get_InternalCalcFields: WordBool; safecall;
    function  Get_Modified: WordBool; safecall;
    function  Get_NestedDataSets: IgsList; safecall;
    function  Get_ObjectView: WordBool; safecall;
    procedure Set_ObjectView(Value: WordBool); safecall;
    function  Get_RecNo: Integer; safecall;
    procedure Set_RecNo(Value: Integer); safecall;
    function  Get_RecordCount: Integer; safecall;
    function  Get_RecordSize: Integer; safecall;
    function  Get_SparseArrays: WordBool; safecall;

    procedure GetDetailDataSets(const List: IgsList); safecall;
    procedure GetDetailLinkFields(const MasterFields: IgsList; const DetailFields: IgsList); safecall;
    procedure GetFieldList(const List: IgsList; const FieldName: WideString); safecall;
    function  Lookup(const KeyFields: WideString; KeyValues: OleVariant;
                     const ResultFields: WideString): OleVariant; safecall;
    function  MoveBy(Distance: Integer): Integer; safecall;
    function  UpdateStatus: TgsUpdateStatus; safecall;
    function  Get_FieldDefList: IgsFieldDefList; safecall;
    function  Get_FieldDefs: IgsFieldDefs; safecall;
    procedure Set_FieldDefs(const Value: IgsFieldDefs); safecall;
    function  Get_FieldList: IgsFieldList; safecall;
    function  Get_FilterOptions: WideString; safecall;
    procedure Set_FilterOptions(const Value: WideString); safecall;
    procedure GetFieldNames(const List: IgsStrings); safecall;

    function  BookmarkValid(Bookmark: Integer): WordBool; safecall;
    function  CompareBookmarks(Bookmark1: Integer; Bookmark2: Integer): Integer; safecall;
    function  CreateBlobStream(const Field: IgsFieldComponent; Mode: TgsBlobStreamMode): IgsStream; safecall;
    procedure FreeBookmark(Bookmark: Integer); safecall;
    function  GetBookmark: Integer; safecall;
    procedure GotoBookmark(Bookmark: Integer); safecall;
    function  Locate(const KeyFields: WideString; KeyValues: OleVariant; const Options: WideString): WordBool; safecall;
    procedure Resync(const Mode: WideString); safecall;
    function Get_RealDataSet: TDataSet; safecall;
  end;

  TwrpIBCustomDataSet = class(TwrpDataSet, IgsIBCustomDataSet)
  private
    function GetIBCustomDataSet: TIBCustomDataSet;
  protected
    procedure Undelete; safecall;
    function  Get_ForcedRefresh: WordBool; safecall;
    procedure Set_ForcedRefresh(Value: WordBool); safecall;

    function  Get_BufferChunks: Integer; safecall;
    procedure Set_BufferChunks(Value: Integer); safecall;
    function  Get_CachedUpdates: WordBool; safecall;
    procedure Set_CachedUpdates(Value: WordBool); safecall;
    function  Get_DeleteSQL: IgsStrings; safecall;
    procedure Set_DeleteSQL(const Value: IgsStrings); safecall;
    function  Get_InsertSQL: IgsStrings; safecall;
    procedure Set_InsertSQL(const Value: IgsStrings); safecall;
    function  Get_InternalPrepared: WordBool; safecall;
    function  Get_ModifySQL: IgsStrings; safecall;
    procedure Set_ModifySQL(const Value: IgsStrings); safecall;
    function  Get_ParamCheck: WordBool; safecall;
    procedure Set_ParamCheck(Value: WordBool); safecall;
    function  Get_Params: IgsIBXSQLDA; safecall;
    function  Get_Plan: WideString; safecall;
    function  Get_RefreshSQL: IgsStrings; safecall;
    procedure Set_RefreshSQL(const Value: IgsStrings); safecall;
    function  Get_RowsAffected: Integer; safecall;
    function  Get_SelectSQL: IgsStrings; safecall;
    procedure Set_SelectSQL(const Value: IgsStrings); safecall;
    function  Get_SQLParams: IgsIBXSQLDA; safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
    function  Get_UniDirectional: WordBool; safecall;
    procedure Set_UniDirectional(Value: WordBool); safecall;
    function  Get_UpdateMode: TgsUpdateMode; safecall;
    procedure Set_UpdateMode(Value: TgsUpdateMode); safecall;
    function  Get_UpdatesPending: WordBool; safecall;
    procedure ApplyUpdates; safecall;
    function  CachedUpdateStatus: TgsCachedUpdateStatus; safecall;
    procedure CancelUpdates; safecall;
    function  Current: IgsIBXSQLDA; safecall;
    procedure FetchAll; safecall;
    procedure RecordModified(Value: WordBool); safecall;
    procedure RevertRecord; safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;
    function  Get_ReadTransaction: IgsIBTransaction; safecall;
    procedure Set_ReadTransaction(const Value: IgsIBTransaction); safecall;

    function  Get_UpdateObject: IgsIBDataSetUpdateObject; safecall;
    procedure Set_UpdateObject(const Value: IgsIBDataSetUpdateObject); safecall;
    function  Get_UpdateRecordTypes: WideString; safecall;
    procedure Set_UpdateRecordTypes(const Value: WideString); safecall;
    function  Get_CacheSize: Integer; safecall;
    function  Get_AggregatesObsolete: WordBool; safecall;
    function  Get_OpenCounter: Integer; safecall;
    function  SQLType: TgsIBSQLTypes; safecall;
    procedure Sort(const F: IgsFieldComponent; Ascending: WordBool); safecall;

  end;

  TwrpCustomFrame = class (TwrpScrollingWinControl, IgsCustomFrame)
  protected
    function GetCustomFrame: TCustomFrame;
  end;


  TwrpFrame = class (TwrpCustomFrame, IgsFrame)
  end;

  TwrpfrAcctAnalytics = class (TwrpFrame, IgsfrAcctAnalytics)
  private
    function GetFrame: TfrAcctAnalytics;
  protected
    function  Get_Values: WideString; safecall;
    procedure Set_Values(const Value: WideString); safecall;
    function  Get_Description: WideString; safecall;
    property Values: WideString read Get_Values write Set_Values;
  end;

  TwrpMenu = class(TwrpComponent, IgsMenu)
  private
    function GetMenu: TMenu;
  protected
    function  Get_OwnerDraw: WordBool; safecall;
    procedure Set_OwnerDraw(Value: WordBool); safecall;
    function  Get_AutoHotKey: TgsMenuItemAutoFlag; safecall;
    procedure Set_AutoHotKey(Value: TgsMenuItemAutoFlag); safecall;
    function  Get_AutoLineReduction: TgsMenuItemAutoFlag; safecall;
    procedure Set_AutoLineReduction(Value: TgsMenuItemAutoFlag); safecall;
    function  Get_BiDiMode: TgsBiDiMode; safecall;
    procedure Set_BiDiMode(Value: TgsBiDiMode); safecall;
    function  Get_Items: IgsMenuItem; safecall;
    function  Get_Handle: Integer; safecall;
    function  Get_ParentBiDiMode: WordBool; safecall;
    procedure Set_ParentBiDiMode(Value: WordBool); safecall;
    function  Get_WindowHandle: Integer; safecall;
    procedure Set_WindowHandle(Value: Integer); safecall;
  end;

  TwrpMainMenu = class (TwrpMenu, IgsMainMenu)
  private
    function GetMainMenu: TMainMenu;
  protected
    function  Get_AutoMerge: WordBool; safecall;
    procedure Set_AutoMerge(Value: WordBool); safecall;
    procedure Merge(const Menu: IgsMainMenu); safecall;
    procedure UnMerge(const Menu: IgsMainMenu); safecall;
  end;

  TwrpPopupMenu = class (TwrpMenu, IgsPopupMenu)
  private
    function GetPopupMenu: TPopupMenu;
  protected
    function  Get_AutoPopup: WordBool; safecall;
    procedure Set_AutoPopup(Value: WordBool); safecall;
    procedure Popup(x: Integer; y: Integer); safecall;
    function  Get_Alignment: TgsPopupAlignment; safecall;
    procedure Set_Alignment(Value: TgsPopupAlignment); safecall;

    function  Get_HelpContext: Integer; safecall;
    procedure Set_HelpContext(Value: Integer); safecall;
    function  Get_MenuAnimation: WideString; safecall;
    procedure Set_MenuAnimation(const Value: WideString); safecall;
    function  Get_PopupComponent: IgsComponent; safecall;
    procedure Set_PopupComponent(const Value: IgsComponent); safecall;
    function  Get_TrackButton: TgsTrackButton; safecall;
    procedure Set_TrackButton(Value: TgsTrackButton); safecall;
  end;


  TwrpCustomEdit = class (TwrpWinControl, IgsCustomEdit)
  protected
    function  GetCustomEdit: TCustomEdit;
  protected
    function  Get_CanUndo: WordBool; safecall;
    function  Get_Modified: WordBool; safecall;
    procedure Set_Modified(Value: WordBool); safecall;
    procedure Clear; virtual; safecall ;
    procedure ClearSelection; safecall;
    procedure ClearUndo; safecall;
    procedure CopyToClipBoard; safecall;
    procedure CutToClipboard; safecall;
    procedure PasteFromClipboard; safecall;
    procedure SelectAll; safecall;
    procedure Undo; safecall;
    function  Get_BorderStyle: TgsFormBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsFormBorderStyle); safecall;
    function  Get_CharCase: TgsEditCharCase; safecall;
    procedure Set_CharCase(Value: TgsEditCharCase); safecall;

    function  Get_SelLength: Integer; safecall;
    procedure Set_SelLength(Value: Integer); safecall;
    function  Get_SelStart: Integer; safecall;
    procedure Set_SelStart(Value: Integer); safecall;
    function  Get_SelText: WideString; safecall;
    procedure Set_SelText(const Value: WideString); safecall;

    function  Get_HideSelection: WordBool; safecall;
    procedure Set_HideSelection(Value: WordBool); safecall;
    function  Get_OEMConvert: WordBool; safecall;
    procedure Set_OEMConvert(Value: WordBool); safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_MaxLength: Integer; safecall;
    procedure Set_MaxLength(Value: Integer); safecall;
    function  Get_AutoSelect: WordBool; safecall;
    procedure Set_AutoSelect(Value: WordBool); safecall;
    function  Get_PasswordChar: WideString; safecall;
    procedure Set_PasswordChar(const Value: WideString); safecall;
  end;

  TwrpEdit = class (TwrpCustomEdit, IgsEdit)
  end;

  TwrpCustomMemo = class (TwrpCustomEdit, IgsCustomMemo)
  private
    function GetCustomMemo: TCustomMemo;
  protected
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_Lines: IgsStrings; safecall;
    procedure Set_Lines(const Value: IgsStrings); safecall;
    function  Get_ScrollBars: TgsScrollStyle; safecall;
    procedure Set_ScrollBars(Value: TgsScrollStyle); safecall;
    function  Get_WantTabs: WordBool; safecall;
    procedure Set_WantTabs(Value: WordBool); safecall;
    function  Get_WordWrap: WordBool; safecall;
    procedure Set_WordWrap(Value: WordBool); safecall;
    procedure CaretPos(out X: OleVariant; out Y: OleVariant); safecall;
  end;

  TwrpMemo = class(TwrpCustomMemo, IgsMemo)
  private
    function GetMemo: TMemo;
  protected
    function  Get_WantReturns: WordBool; safecall;
    procedure Set_WantReturns(Value: WordBool); safecall;
  end;

  TwrpCustomCheckBox = class(TwrpButtonControl, IgsCustomCheckBox)
  private
    function GetCustomCheckBox: TCustomCheckBox;
  protected
    function  Get_AllowGrayed: WordBool; safecall;
    procedure Set_AllowGrayed(Value: WordBool); safecall;
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_State: TgsCheckBoxState; safecall;
    procedure Set_State(Value: TgsCheckBoxState); safecall;
    procedure Toggle; safecall;
  end;

  TwrpRadioButton = class(TwrpButtonControl, IgsRadioButton)
  private
    function GetRadioButton: TRadioButton;
  protected
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
  end;

  TwrpCustomListBox = class(TwrpWinControl, IgsCustomListBox)
  private
    function GetCustomListBox: TCustomListBox;
  protected
    function  Get_BorderStyle: TgsBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsBorderStyle); safecall;
    function  Get_Columns: Integer; safecall;
    procedure Set_Columns(Value: Integer); safecall;
    function  Get_ExtendedSelect: WordBool; safecall;
    procedure Set_ExtendedSelect(Value: WordBool); safecall;
    function  Get_IntegralHeight: WordBool; safecall;
    procedure Set_IntegralHeight(Value: WordBool); safecall;
    function  Get_ItemIndex: Integer; safecall;
    procedure Set_ItemIndex(Value: Integer); safecall;
    function  Get_Items: IgsStrings; safecall;
    procedure Set_Items(const Value: IgsStrings); safecall;
    function  Get_MultiSelect: WordBool; safecall;
    procedure Set_MultiSelect(Value: WordBool); safecall;
    function  Get_SelCount: Integer; safecall;
    function  Get_Selected(Index: Integer): WordBool; safecall;
    procedure Set_Selected(Index: Integer; Value: WordBool); safecall;
    function  Get_Sorted: WordBool; safecall;
    procedure Set_Sorted(Value: WordBool); safecall;
    function  Get_Style: TgsListBoxStyle; safecall;
    procedure Set_Style(Value: TgsListBoxStyle); safecall;
    function  Get_TabWidth: Integer; safecall;
    procedure Set_TabWidth(Value: Integer); safecall;
    function  Get_TopIndex: Integer; safecall;
    procedure Set_TopIndex(Value: Integer); safecall;
    function  Get_ItemHeight: Integer; safecall;
    procedure Set_ItemHeight(Value: Integer); safecall;
    procedure ClearBox; safecall;
    procedure DeleteString(Index: Integer); safecall;
    procedure ResetContent; safecall;
    function  Get_Canvas: IgsCanvas; safecall;
    function  ItemAtPos(X: Integer; Y: Integer; Existing: WordBool): Integer; safecall;
    procedure ItemRect(Item: Integer; out Left: OleVariant; out Top: OleVariant;
                       out Right: OleVariant; out Bottom: OleVariant); safecall;
  end;

  TwrpListBox = class(TwrpCustomListBox, IgsListBox)
  private
    function  GetListBox: TListBox;
  protected
    procedure Clear; safecall;
  end;

  TwrpCustomComboBox = class(TwrpWinControl, IgsCustomComboBox)
  private
    function GetCustomComboBox: TCustomComboBox;
  protected
    function  Get_CharCase: TgsEditCharCase; safecall;
    procedure Set_CharCase(Value: TgsEditCharCase); safecall;
    function  Get_DropDownCount: Integer; safecall;
    procedure Set_DropDownCount(Value: Integer); safecall;
    function  Get_DroppedDown: WordBool; safecall;
    procedure Set_DroppedDown(Value: WordBool); safecall;
    function  Get_ItemHeight: Integer; safecall;
    procedure Set_ItemHeight(Value: Integer); safecall;
    function  Get_ItemIndex: Integer; safecall;
    procedure Set_ItemIndex(Value: Integer); safecall;
    function  Get_Items: IgsStrings; safecall;
    procedure Set_Items(const Value: IgsStrings); safecall;
    function  Get_MaxLength: Integer; safecall;
    procedure Set_MaxLength(Value: Integer); safecall;
    function  Get_SelLength: Integer; safecall;
    procedure Set_SelLength(Value: Integer); safecall;
    function  Get_SelStart: Integer; safecall;
    procedure Set_SelStart(Value: Integer); safecall;
    function  Get_SelText: WideString; safecall;
    procedure Set_SelText(const Value: WideString); safecall;
    function  Get_Sorted: WordBool; safecall;
    procedure Set_Sorted(Value: WordBool); safecall;
    function  Get_Style: TgsComboBoxStyle; safecall;
    procedure Set_Style(Value: TgsComboBoxStyle); safecall;
    procedure Clear; safecall;
    procedure SelectAll; safecall;
    function  Get_Canvas: IgsCanvas; safecall;
    function  Get_EditHandle: Integer; safecall;
    function  Get_ListHandle: Integer; safecall;
  end;

  TwrpComboBox = class(TwrpCustomComboBox, IgsComboBox)
  end;

  TwrpScrollBar = class(TwrpWinControl, IgsScrollBar)
  private
    function  GetScrollBar: TScrollBar;
  protected
    procedure SetParams(APosition: Integer; AMin: Integer; AMax: Integer); safecall;
    function  Get_LargeChange: Smallint; safecall;
    procedure Set_LargeChange(Value: Smallint); safecall;
    function  Get_Max: Integer; safecall;
    procedure Set_Max(Value: Integer); safecall;
    function  Get_Min: Integer; safecall;
    procedure Set_Min(Value: Integer); safecall;
    function  Get_PageSize: Integer; safecall;
    procedure Set_PageSize(Value: Integer); safecall;
    function  Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    function  Get_SmallChange: Smallint; safecall;
    procedure Set_SmallChange(Value: Smallint); safecall;
    function  Get_Kind: TgsScrollBarKind; safecall;
    procedure Set_Kind(Value: TgsScrollBarKind); safecall;
  end;

  TwrpGraphicsObject = class(TwrpPersistent, IgsGraphicsObject)
  end;

  TwrpPen = class(TwrpGraphicsObject, IgsPen)
  private
    function  GetPen: TPen;
  protected
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_Handle: LongWord; safecall;
    procedure Set_Handle(Value: LongWord); safecall;
    function  Get_Mode: TgsPenMode; safecall;
    procedure Set_Mode(Value: TgsPenMode); safecall;
    function  Get_Style: TgsPenStyle; safecall;
    procedure Set_Style(Value: TgsPenStyle); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpFont = class(TwrpGraphicsObject, IgsFont)
  private
    function  GetFont: TFont;
  protected
    function  Get_Charset: Byte; safecall;
    procedure Set_Charset(Value: Byte); safecall;
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_Handle: Integer; safecall;
    procedure Set_Handle(Value: Integer); safecall;
    function  Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function  Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function  Get_Pitch: TgsFontPitch; safecall;
    procedure Set_Pitch(Value: TgsFontPitch); safecall;
    function  Get_PixelsPerInch: Integer; safecall;
    procedure Set_PixelsPerInch(Value: Integer); safecall;
    function  Get_Size: Integer; safecall;
    procedure Set_Size(Value: Integer); safecall;
    function  Get_Style: WideString; safecall;
    procedure Set_Style(const Value: WideString); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpBrush = class(TwrpGraphicsObject, IgsBrush)
  private
    function GetBrush: TBrush;

  protected
    function  Get_Color: Integer; safecall;
    procedure Set_Color(Value: Integer); safecall;
    function  Get_Style: Integer; safecall;
    procedure Set_Style(Value: Integer); safecall;
    function  Get_Handle: Integer; safecall;
    procedure Set_Handle(Value: Integer); safecall;
    function  Get_Bitmap: IgsBitmap; safecall;
    procedure Set_Bitmap(const Value: IgsBitmap); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpPicture = class(TwrpPersistent, IgsPicture)
  private
    function GetPicture: TPicture;

  protected
    function  Get_Height: Integer; safecall;
    function  Get_Width: Integer; safecall;
    function  Get_Graphic: IgsGraphic; safecall;
    function  Get_Bitmap: IgsBitmap; safecall;
    procedure LoadFromFile(const Param1: WideString); safecall;
    procedure SaveToFile(const Param1: WideString); safecall;
    function  Get_Icon: IgsIcon; safecall;
    procedure Set_Icon(const Value: IgsIcon); safecall;
    function  Get_Metafile: IgsMetafile; safecall;
    procedure Set_Metafile(const Value: IgsMetafile); safecall;
    procedure LoadFromClipboardFormat(AFormat: Byte; AData: LongWord; APalette: LongWord); safecall;
    procedure SaveToClipboardFormat(var AFormat: OleVariant; var AData: OleVariant;
                                    var APalette: OleVariant); safecall;
    function  SupportsClipboardFormat(AFormat: Word): WordBool; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpGraphic = class(TwrpPersistent, IgsGraphic)
  private
    function GetGraphic: TGraphic;

  protected
    function  Get_Empty: WordBool; safecall;
    function  Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function  Get_Modified: WordBool; safecall;
    procedure Set_Modified(Value: WordBool); safecall;
    function  Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;
    function  Get_Palette: LongWord; safecall;
    procedure Set_Palette(Value: LongWord); safecall;
    function  Get_PaletteModified: WordBool; safecall;
    procedure Set_PaletteModified(Value: WordBool); safecall;
    procedure LoadFromClipboardFormat(AFormat: Word; AData: LongWord; APalette: LongWord); safecall;
    procedure LoadFromFile(const AFileName: WideString); safecall;
    procedure SaveToClipboardFormat(var AFormat: OleVariant; var AData: OleVariant; var APalette: OleVariant); safecall;
    procedure SaveToFile(const AFileName: WideString); safecall;
    procedure LoadFromStream(const Param1: IgsStream); safecall;
    procedure SaveToStream(const Param1: IgsStream); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpMetafile = class(TwrpGraphic, IgsMetafile)
  private
    function  GetMetafile: TMetafile;
  protected
    function  ReleaseHandle: LongWord; safecall;
    function  Get_CreatedBy: WideString; safecall;
    function  Get_Description: WideString; safecall;
    function  Get_Enhanced: WordBool; safecall;
    procedure Set_Enhanced(Value: WordBool); safecall;
    function  Get_Handle: LongWord; safecall;
    procedure Set_Handle(Value: LongWord); safecall;
    function  Get_MMWidth: Integer; safecall;
    procedure Set_MMWidth(Value: Integer); safecall;
    function  Get_MMHeight: Integer; safecall;
    procedure Set_MMHeight(Value: Integer); safecall;
    function  Get_Inch: Word; safecall;
    procedure Set_Inch(Value: Word); safecall;
    procedure Clear; safecall;
  end;

  TwrpIcon = class(TwrpGraphic, IgsIcon)
  private
    function  GetIcon: TIcon;
  protected
    function  ReleaseHandle: LongWord; safecall;
    function  Get_Handle: LongWord; safecall;
    procedure Set_Handle(Value: LongWord); safecall;
  end;

  TwrpBitmap = class(TwrpGraphic, IgsBitmap)
  private
    function GetBitmap: TBitmap;

  protected
    function  Get_Canvas: IgsCanvas; safecall;
    procedure Dormant; safecall;
    procedure FreeImage; safecall;
    procedure LoadFromResourceID(Instance: Integer; ResID: Integer); safecall;
    procedure LoadFromResourceName(Instance: Integer; const ResName: WideString); safecall;
    procedure Mask(TransparentColor: Integer); safecall;
    function  ReleaseHandle: Integer; safecall;
    function  ReleaseMaskHandle: Integer; safecall;
    function  ReleasePalette: Integer; safecall;
    function  Get_Handle: Integer; safecall;
    procedure Set_Handle(Value: Integer); safecall;
    function  Get_HandleType: TgsBitmapHandleType; safecall;
    procedure Set_HandleType(Value: TgsBitmapHandleType); safecall;
    function  Get_IgnorePalette: WordBool; safecall;
    procedure Set_IgnorePalette(Value: WordBool); safecall;
    function  Get_MaskHandle: Integer; safecall;
    function  Get_Monochrome: WordBool; safecall;
    procedure Set_Monochrome(Value: WordBool); safecall;
    function  Get_PixelFormat: TgsPixelFormat; safecall;
    procedure Set_PixelFormat(Value: TgsPixelFormat); safecall;
    function  Get_TransparentColor: Integer; safecall;
    procedure Set_TransparentColor(Value: Integer); safecall;
    function  Get_TransparentMode: TgsTransparentMode; safecall;
    procedure Set_TransparentMode(Value: TgsTransparentMode); safecall;
  end;

  TwrpCanvas = class(TwrpPersistent, IgsCanvas)
  private
    function  GetCanvas: TCanvas;

  protected
    function  Get_CanvasOrientation: TgsCanvasOrientation; safecall;
    function  Get_CopyMode: Integer; safecall;
    procedure Set_CopyMode(Value: Integer); safecall;
    function  Get_Font: IgsFont; safecall;
    procedure Set_Font(const Value: IgsFont); safecall;
    function  Get_Handle: Integer; safecall;
    procedure Set_Handle(Value: Integer); safecall;
    function  Get_LockCount: Integer; safecall;
    function  Get_Pixels(X: Integer; Y: Integer): Integer; safecall;
    procedure Set_Pixels(X: Integer; Y: Integer; Value: Integer); safecall;
    function  Get_TextFlags: Integer; safecall;
    procedure Set_TextFlags(Value: Integer); safecall;
    function  Get_Brush: IgsBrush; safecall;
    procedure Set_Brush(const Value: IgsBrush); safecall;
    procedure Arc(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer; X3: Integer; Y3: Integer;
                  X4: Integer; Y4: Integer); safecall;
    procedure Chord(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer; X3: Integer; Y3: Integer;
                    X4: Integer; Y4: Integer); safecall;
    procedure Ellipse(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer); safecall;
    procedure FloodFill(X: Integer; Y: Integer; Color: Integer; FillStyle: TgsFillStyle); safecall;
    procedure LineTo(X: Integer; Y: Integer); safecall;
    procedure Lock; safecall;
    procedure MoveTo(X: Integer; Y: Integer); safecall;
    procedure Pie(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer; X3: Integer; Y3: Integer;
                  X4: Integer; Y4: Integer); safecall;
    procedure Rectangle(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer); safecall;
    procedure Refresh; safecall;
    procedure RoundRect(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer; X3: Integer; Y3: Integer); safecall;
    function  TextExtent(const Text: WideString): TgsSize; safecall;
    function  TextHeight(const Text: WideString): Integer; safecall;
    procedure TextOut(X: Integer; Y: Integer; const Text: WideString); safecall;
    function  TextWidth(const Text: WideString): Integer; safecall;
    procedure TryLock; safecall;
    procedure Unlock; safecall;
    procedure Draw(X: Integer; Y: Integer; const Graphic: IgsGraphic); safecall;
    procedure CopyRect(DestLeft: Integer; DestTop: Integer; DestRight: Integer;
                       DestBottom: Integer; const Canvas: IgsCanvas; SourceLeft: Integer;
                       SourceTop: Integer; SourceRight: Integer; SourceBottom: Integer); safecall;
    procedure FillRect(ALeft: Integer; ATop: Integer; ARight: Integer; ABottom: Integer); safecall;
    function  Get_Pen: IgsPen; safecall;
    procedure Set_Pen(const Value: IgsPen); safecall;
    procedure ClipRect(out Left: OleVariant; out Top: OleVariant;out  Right: OleVariant;out  Botton: OleVariant); safecall;
    procedure SetPenPos(X: Integer; Y: Integer); safecall;
    procedure GetPenPos(out X: OleVariant; out Y: OleVariant); safecall;
    procedure DrawFocusRect(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer); safecall;
    procedure FrameRect(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer); safecall;
    procedure PolyBezier(APoints: OleVariant); safecall;
    procedure PolyBezierTo(APoints: OleVariant); safecall;
    procedure Polygon(APoints: OleVariant); safecall;
    procedure Polyline(APoints: OleVariant); safecall;
    procedure StretchDraw(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer;
                          const AGraphic: IgsGraphic); safecall;
    procedure BrushCopy(DestX1: Integer; DestY1: Integer; DestX2: Integer; DestY2: Integer;
                        const ABitmap: IgsBitmap; SourceX1: Integer; SourceY1: Integer;
                        SourceX2: Integer; SourceY2: Integer; Color: Integer); safecall;
    procedure TextRect(Left: Integer; Top: Integer; Right: Integer; Bottom: Integer; X: Integer;
                       Y: Integer; const Text: WideString); safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpCustomControl = class(TwrpWinControl, IgsCustomControl)
  private
    function GetCustomControl: TCustomControl;
  protected
    function  Get_Canvas: IgsCanvas; safecall;
    procedure Paint; safecall;
  end;

  TwrpCustomGroupBox = class(TwrpCustomControl, IgsCustomGroupBox)
  protected
    function GetCustomGroupBox: TCustomGroupBox;
  end;

  TwrpGroupBox = class(TwrpCustomGroupBox, IgsGroupBox)
  end;

  TwrpCustomRadioGroup = class(TwrpCustomGroupBox, IgsCustomRadioGroup)
  private
    function GetCustomRadioGroup: TCustomRadioGroup;
  protected
    function  Get_ItemIndex: Integer; safecall;
    procedure Set_ItemIndex(Value: Integer); safecall;
    function  Get_Columns: Integer; safecall;
    procedure Set_Columns(Value: Integer); safecall;
    function  Get_Items: IgsStrings; safecall;
    procedure Set_Items(const Value: IgsStrings); safecall;
  end;

  TwrpRadioGroup = class(TwrpCustomRadioGroup, IgsRadioGroup)
  private
    function GetRadioGroup: TRadioGroup;
  protected
    function  Get_Columns: Integer; safecall;
    procedure Set_Columns(Value: Integer); safecall;
  end;

  TwrpCustomPanel = class(TwrpCustomControl, IgsCustomPanel)
  end;

  TwrpPanel = class(TwrpCustomPanel, IgsPanel)
  private
    function GetPanel: TPanel;
  protected
    function  Get_FullRepaint: WordBool; safecall;
    procedure Set_FullRepaint(Value: WordBool); safecall;
    function  Get_Locked: WordBool; safecall;
    procedure Set_Locked(Value: WordBool); safecall;
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_BorderStyle: TgsFormBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsFormBorderStyle); safecall;
    function  Get_BevelInner: TgsPanelBevel; safecall;
    procedure Set_BevelInner(Value: TgsPanelBevel); safecall;
    function  Get_BevelOuter: TgsBevelCut; safecall;
    procedure Set_BevelOuter(Value: TgsBevelCut); safecall;
  end;

  TwrpgsPanel = class(TwrpPanel, IgsgsPanel)
  private
    function GetPanel: TgsPanel;
  protected
    function  Get_BorderColor: Integer; safecall;
    procedure Set_BorderColor(Value: Integer); safecall;
    function  Get_TextArea1: IgsStrings; safecall;
    procedure Set_TextArea1(const Value: IgsStrings); safecall;
    function  Get_TextArea2: IgsStrings; safecall;
    procedure Set_TextArea2(const Value: IgsStrings); safecall;
    function  Get_FontArea2: IgsFont; safecall;
    procedure Set_FontArea2(const Value: IgsFont); safecall;
    function  Get_FontArea3: IgsFont; safecall;
    procedure Set_FontArea3(const Value: IgsFont); safecall;
    function  Get_HeightArea1: Integer; safecall;
    procedure Set_HeightArea1(Value: Integer); safecall;
    function  Get_WidthArea2: Integer; safecall;
    procedure Set_WidthArea2(Value: Integer); safecall;
    function  Get_TextArea3: IgsStrings; safecall;
    procedure Set_TextArea3(const Value: IgsStrings); safecall;
    function  Get_FontArea1: IgsFont; safecall;
    procedure Set_FontArea1(const Value: IgsFont); safecall;
  end;

  TwrpCustomActionList = class(TwrpComponent, IgsCustomActionList)
  private
    function GetCustomActionList: TCustomActionList;
  protected
    function  Get_ActionCount: Integer; safecall;
    function  Get_Actions(Index: Integer): IgsContainedAction; safecall;
    procedure Set_Actions(Index: Integer; const Value: IgsContainedAction); safecall;
    function  ExecuteAction(const Action: IgsContainedAction): WordBool; safecall;
    function  UpDateAction(const Action: IgsContainedAction): WordBool; safecall;
    function  Get_Images: IgsCustomImageList; safecall;
    procedure Set_Images(const Value: IgsCustomImageList); safecall;
  end;

  TwrpActionList = class(TwrpCustomActionList, IgsActionList)
  protected
    function GetActionList: TActionList;
  end;

  TwrpCheckBox = class(TwrpCustomCheckBox, IgsCheckBox)
  end;

  TwrpMenuItem = class(TwrpComponent, IgsMenuItem)
  private
    function GetMenuItem: TMenuItem;
    function TMenuItemToIgsMenuItem(Value: TMenuItem): IgsMenuItem;
    function IgsMenuItemToTMenuItem(Value: IgsMenuItem): TMenuItem;
  protected
    function  Get_Action: IgsBasicAction; safecall;
    procedure Set_Action(const Value: IgsBasicAction); safecall;
    function  Get_AutoHotkeys: TgsMenuItemAutoFlag; safecall;
    procedure Set_AutoHotkeys(Value: TgsMenuItemAutoFlag); safecall;
    function  Get_Break: TgsMenuBreak; safecall;
    procedure Set_Break(Value: TgsMenuBreak); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function  Get_Checked: WordBool; safecall;
    procedure Set_Checked(Value: WordBool); safecall;
    function  Get_Command: Word; safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Default: WordBool; safecall;
    procedure Set_Default(Value: WordBool); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function  Get_Handle: Smallint; safecall;
    function  Get_Hint: WideString; safecall;
    procedure Set_Hint(const Value: WideString); safecall;
    function  Get_Items(Index: Integer): IgsMenuItem; safecall;
    function  Get_MenuIndex: Integer; safecall;
    procedure Set_MenuIndex(Value: Integer); safecall;
    function  Get_Parent: IgsMenuItem; safecall;
    function  Get_RadioItem: WordBool; safecall;
    procedure Set_RadioItem(Value: WordBool); safecall;
    function  Get_ShortCut: Smallint; safecall;
    procedure Set_ShortCut(Value: Smallint); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function  Get_GroupIndex: Integer; safecall;
    procedure Set_GroupIndex(Value: Integer); safecall;
    function  Get_AutoLineReduction: TgsMenuItemAutoFlag; safecall;
    procedure Set_AutoLineReduction(Value: TgsMenuItemAutoFlag); safecall;
    procedure Add(const Item: IgsMenuItem); safecall;
    procedure Clear; safecall;
    procedure Click; safecall;
    function  Find(const ACaption: WideString): IgsMenuItem; safecall;
    function  IndexOf(const Item: IgsMenuItem): Integer; safecall;
    procedure InitiateAction; safecall;
    procedure Insert(Index: Integer; const Item: IgsMenuItem); safecall;
    function  InsertNewLineAfter(const AnItem: IgsMenuItem): Integer; safecall;
    function  IsLine: WordBool; safecall;
    function  NewBottomLine: Integer; safecall;
    procedure Remove(const Item: IgsMenuItem); safecall;
    function  RethinkHotkeys: WordBool; safecall;
    function  InsertNewLineBefore(const AnItem: IgsMenuItem): Integer; safecall;
    function  NewTopLine: Integer; safecall;
    function  RethinkLines: WordBool; safecall;

    function  Get_Bitmap: IgsBitmap; safecall;
    procedure Set_Bitmap(const Value: IgsBitmap); safecall;
    function  Get_HelpContext: Integer; safecall;
    procedure Set_HelpContext(Value: Integer); safecall;
    function  Get_ImageIndex: Integer; safecall;
    procedure Set_ImageIndex(Value: Integer); safecall;
    function  Get_SubMenuImages: IgsCustomImageList; safecall;
    procedure Set_SubMenuImages(const Value: IgsCustomImageList); safecall;
    procedure Delete(Index: Integer); safecall;
    function  GetImageList: IgsCustomImageList; safecall;
    function  GetParentComponent: IgsComponent; safecall;
    function  GetParentMenu: IgsMenu; safecall;
    function  HasParent: WordBool; safecall;
  end;

  TwrpList = class(TwrpObject, IgsList)
  private
    function  GetList: TList;
  protected
    function  Get_Capacity: Integer; safecall;
    procedure Set_Capacity(Value: Integer); safecall;
    function  Get_Count: Integer; safecall;
    procedure Set_Count(Value: Integer); safecall;
    function  Get_List: Integer; safecall;
    procedure Exchange(Index1: Integer; Index2: Integer); safecall;
    function  Expand: IgsList; safecall;
    function  Extract(Item: Integer): Integer; safecall;
    function  First: Integer; safecall;
    function  Last: Integer; safecall;
    procedure Move(CurIndex: Integer; NewIndex: Integer); safecall;
    procedure Pack; safecall;

    function  Add(const AObject: IgsObject): Integer; safecall;
    procedure Clear; safecall;
    procedure Delete(Index: Integer); safecall;
    function  IndexOf(const AnObject: IgsObject): Integer; safecall;
    procedure Insert(Index: Integer; const AnObject: IgsObject); safecall;
    function  Remove(const AnObject: IgsObject): Integer; safecall;

    function  Get_Items(Index: Integer): IgsObject; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsObject); safecall;
  end;

  TwrpObjectList = class(TwrpList, IgsObjectList)
  private
    function  GetObjectList: TObjectList;
  protected
    function  Get_Items_(Index: Integer): IgsObject; safecall;
    procedure Set_Items_(Index: Integer; const Value: IgsObject); safecall;
    function  Get_OwnsObjects: WordBool; safecall;
    procedure Set_OwnsObjects(Value: WordBool); safecall;
    function  Add(const AObject: IgsObject): Integer; safecall;
    procedure Clear; safecall;
    procedure Delete(Index: Integer); safecall;
    function  IndexOf(const AObject: IgsObject): Integer; safecall;
    procedure Insert(Index: Integer; const AObject: IgsObject); safecall;
    function  Remove(const AObject: IgsObject): Integer; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpIBTransaction = class(TwrpComponent, IgsIBTransaction)
  private
    function  GetTransaction: TIBTransaction;
  protected
    function  Get_Active: WordBool; safecall;
    procedure Set_Active(Value: WordBool); safecall;
    function  Get_AutoStopAction: TgsAutoStopAction; safecall;
    procedure Set_AutoStopAction(Value: TgsAutoStopAction); safecall;
    function  Get_DefaultAction: TgsTransactionAction; safecall;
    procedure Set_DefaultAction(Value: TgsTransactionAction); safecall;
    function  Get_IdleTimer: Integer; safecall;
    procedure Set_IdleTimer(Value: Integer); safecall;
    function  Get_InTransaction: WordBool; safecall;
    function  Get_Params: IgsStrings; safecall;
    procedure Set_Params(const Value: IgsStrings); safecall;
    procedure CheckAutoStop; safecall;
    procedure Commit; safecall;
    procedure CommitRetaining; safecall;
    procedure Rollback; safecall;
    procedure RollbackRetaining; safecall;
    procedure StartTransaction; safecall;
    function  Get_DefaultDatabase: IgsIBDatabase; safecall;
    procedure  Set_DefaultDatabase(const Value: IgsIBDatabase); safecall;

    function  Get_DatabaseCount: Integer; safecall;
    function  Get_Databases(Index: Integer): IgsIBDatabase; safecall;
    function  Get_HandleIsShared: WordBool; safecall;
    function  Get_SQLObjectCount: Integer; safecall;
    function  Get_SQLObjects(Index: Integer): IgsIBBase; safecall;
    function  Get_TPBLength: Smallint; safecall;
    function  AddDatabase(const db: IgsIBDatabase): Integer; safecall;
    function  Call(ErrCode: Integer; RaiseError: WordBool): Integer; safecall;
    procedure CheckDatabasesInList; safecall;
    procedure CheckInTransaction; safecall;
    procedure CheckNotInTransaction; safecall;
    function  FindDatabase(const db: IgsIBDatabase): Integer; safecall;
    function  FindDefaultDatabase: IgsIBDatabase; safecall;
    procedure RemoveDatabase(Idx: Integer); safecall;
    procedure RemoveDatabases; safecall;
  end;

  TwrpDataSource = class(TwrpComponent, IgsDataSource)
  private
    function  GetDataSource: TDataSource;
  protected
    function  Get_AutoEdit: WordBool; safecall;
    procedure Set_AutoEdit(Value: WordBool); safecall;
    function  Get_DataSet: IgsDataSet; safecall;
    procedure Set_DataSet(const Value: IgsDataSet); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function  Get_State: TgsDataSetState; safecall;
    procedure Edit; safecall;
    function  IsLinkedTo(const DataSet: IgsDataSet): WordBool; safecall;
  end;

  TwrpStrings = class(TwrpPersistent, IgsStrings)
  private
    function  GetStrings: TStrings;
  protected
    function  Get_Capacity: Integer; safecall;
    procedure Set_Capacity(Value: Integer); safecall;
    function  Get_CommaText: WideString; safecall;
    procedure Set_CommaText(const Value: WideString); safecall;
    function  Get_Count: Integer; safecall;
    function  Get_Names(Index: Integer): WideString; safecall;
    function  Get_Objects(Index: Integer): IgsObject; safecall;
    procedure Set_Objects(Index: Integer; const Value: IgsObject); safecall;
    function  Get_Strings(Index: Integer): WideString; safecall;
    procedure Set_Strings(Index: Integer; const Value: WideString); safecall;
    function  Get_ValueFromIndex(Index: Integer): WideString; safecall;
    procedure Set_ValueFromIndex(Index: Integer; const Value: WideString); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_Values(const Name: WideString): WideString; safecall;
    procedure Set_Values(const Name: WideString; const Value: WideString); safecall;
    function  Add(const S: WideString): Integer; safecall;
    function  AddObject(const S: WideString; const AObject: IgsObject): Integer; safecall;
    procedure AddStrings(const Strings: IgsStrings); safecall;
    procedure Append(const S: WideString); safecall;
    procedure BeginUpdate; safecall;
    procedure Clear; safecall;
    procedure Delete(Index: Integer); safecall;
    procedure EndUpdate; safecall;
    function  Equals(const Strings: IgsStrings): WordBool; safecall;
    procedure Exchange(Index1: Integer; Index2: Integer); safecall;
    function  IndexOf(const S: WideString): Integer; safecall;
    function  IndexOfName(const Name: WideString): Integer; safecall;
    function IndexOfObject(const AObject: IgsObject): Integer; safecall;
    procedure Insert(Index: Integer; const S: WideString); safecall;
    procedure InsertObject(Index: Integer; const S: WideString; const AObject: IgsObject); safecall;
    procedure LoadFromFile(const FileName: WideString); safecall;
    procedure Move(CurIndex: Integer; NewIndex: Integer); safecall;
    procedure SaveToFile(const NameFile: WideString); safecall;
    procedure LoadFromStream(const S: IgsStream); safecall;
    procedure SaveToStream(const S: IgsStream); safecall;
  end;

  TwrpStringList = class(TwrpStrings,  IgsStringList)
  private
    function  GetStringList: TStringList;
  protected
    function  Get_Duplicates: TgsDuplicates; safecall;
    procedure Set_Duplicates(Value: TgsDuplicates); safecall;
    function  Get_Sorted: WordBool; safecall;
    procedure Set_Sorted(Value: WordBool); safecall;
    function  Find(const S: WideString; var Index: OleVariant): WordBool; safecall;
    procedure Sort; safecall;
  end;

  TwrpFlatList = class(TwrpStringList, IgsFlatList)
  private
    function  GetFlatList: TFlatList;
  protected
    function  Get_DataSet: IgsDataSet; safecall;
    procedure Update; safecall;
  end;

  TwrpFieldList = class(TwrpFlatList, IgsFieldList)
  private
    function  GetFieldList: TFieldList;
  protected
    function  Get_Fields(Index: Integer): IgsFieldComponent; safecall;
    function  FieldByName(const FieldName: WideString): IgsFieldComponent; safecall;
    function  Find_(const FieldName: WideString): IgsFieldComponent; safecall;
  end;

  TwrpFieldDefList = class(TwrpFlatList, IgsFieldDefList)
  private
    function  GetFieldDefList: TFieldDefList;
  protected
    function  Get_FieldDefs(Index: Integer): IgsFieldDef; safecall;
  end;

  TwrpContainedAction = class(TwrpBasicAction, IgsContainedAction)
  private
    function  GetContainedAction: TContainedAction;
  protected
    function  Get_ActionList: IgsCustomActionList; safecall;
    procedure Set_ActionList(const Value: IgsCustomActionList); safecall;
    function  Get_Category: WideString; safecall;
    procedure Set_Category(const Value: WideString); safecall;
    function  Get_Index: Integer; safecall;
    procedure Set_Index(Value: Integer); safecall;
    function  Execute: WordBool; safecall;
    function  GetParentComponent: IgsComponent; safecall;
    function  HasParent: WordBool; safecall;
  end;

  TwrpCustomAction = class(TwrpContainedAction, IgsCustomAction)
  private
    function  GetCustomAction: TCustomAction;
  protected
    function  DoHint(var HintStr: OleVariant): WordBool; safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function  Get_Hint: WideString; safecall;
    procedure Set_Hint(const Value: WideString); safecall;
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function  Get_DisableIfNoHandler: WordBool; safecall;
    procedure Set_DisableIfNoHandler(Value: WordBool); safecall;
    function  Get_Checked: WordBool; safecall;
    procedure Set_Checked(Value: WordBool); safecall;
    function  Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function  Get_HelpContext: Integer; safecall;
    procedure Set_HelpContext(Value: Integer); safecall;
    function  Get_ImageIndex: Integer; safecall;
    procedure Set_ImageIndex(Value: Integer); safecall;
    function  Get_ShortCut: Word; safecall;
    procedure Set_ShortCut(Value: Word); safecall;
  end;

  TwrpIBDataSet = class(TwrpIBCustomDataSet, IgsIBDataSet)
  private
    function  GetIBDataSet: TIBDataSet;
  protected
    function  Get_Prepared: WordBool; safecall;
    procedure ExecSQL; safecall;
    function  ParamByName(const Idx: WideString): IgsIBXSQLVAR; safecall;
    procedure Prepare; safecall;
    procedure UnPrepare; safecall;
    procedure PSSetCommandText(const CommandText: WideString); safecall;
    procedure SetFiltered(Value: WordBool); safecall;
    procedure InternalOpen; safecall;
    property Prepared: WordBool read Get_Prepared;
    function  Get_Trans: IgsIBTransaction; safecall;
    procedure Set_Trans(const Value: IgsIBTransaction); safecall;

    function  Get_StatementType: TgsIBSQLTypes; safecall;
    function  Get_QDelete: IgsIBSQL; safecall;
    function  Get_QInsert: IgsIBSQL; safecall;
    function  Get_QRefresh: IgsIBSQL; safecall;
    function  Get_QSelect: IgsIBSQL; safecall;
    function  Get_QModify: IgsIBSQL; safecall;
    function  Get_GeneratorField: IgsIBGeneratorField; safecall;
    procedure Set_GeneratorField(const Value: IgsIBGeneratorField); safecall;
    procedure BatchInput(const InputObject: IgsIBBatchInput); safecall;
    procedure BatchOutput(const OutputObject: IgsIBBatchOutput); safecall;
    function  Get_DataSource_: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;

  end;

  TwrpBevel = class(TwrpControl, IgsBevel)
  private
    function  GetBevel: TBevel;
  protected
    function  Get_Shape: TgsBevelShape; safecall;
    procedure Set_Shape(Value: TgsBevelShape); safecall;
    function  Get_Style: TgsBevelStyle; safecall;
    procedure Set_Style(Value: TgsBevelStyle); safecall;
  end;

  TwrpCheckListBox = class(TwrpCustomListBox, IgsCheckListBox)
  private
    function  GetCheckListBox: TCheckListBox;
  protected
    function  Get_Checked(Index: Integer): WordBool; safecall;
    procedure Set_Checked(Index: Integer; Value: WordBool); safecall;
    function  Get_AllowGrayed: WordBool; safecall;
    procedure Set_AllowGrayed(Value: WordBool); safecall;
    function  Get_Flat: WordBool; safecall;
    procedure Set_Flat(Value: WordBool); safecall;
    function  Get_ItemEnabled(Index: Integer): WordBool; safecall;
    procedure Set_ItemEnabled(Index: Integer; Value: WordBool); safecall;
    function  Get_State(Index: Integer): TgsCheckBoxState; safecall;
    procedure Set_State(Index: Integer; Value: TgsCheckBoxState); safecall;
  end;

  TwrpCustomTabControl = class(TwrpWinControl, IgsCustomTabControl)
  private
    function  GetCustomTabControl: TCustomTabControl;
  protected
    function  Get_HotTrack: WordBool; safecall;
    procedure Set_HotTrack(Value: WordBool); safecall;
    function  Get_MultiLine: WordBool; safecall;
    procedure Set_MultiLine(Value: WordBool); safecall;
    function  Get_MultiSelect: WordBool; safecall;
    procedure Set_MultiSelect(Value: WordBool); safecall;
    function  Get_OwnerDraw: WordBool; safecall;
    procedure Set_OwnerDraw(Value: WordBool); safecall;
    function  Get_RaggedRight: WordBool; safecall;
    procedure Set_RaggedRight(Value: WordBool); safecall;
    function  Get_ScrollOpposite: WordBool; safecall;
    procedure Set_ScrollOpposite(Value: WordBool); safecall;
    function  Get_Style: TgsTabStyle; safecall;
    procedure Set_Style(Value: TgsTabStyle); safecall;
    function  Get_TabHeight: Smallint; safecall;
    procedure Set_TabHeight(Value: Smallint); safecall;
    function  Get_TabIndex: Integer; safecall;
    procedure Set_TabIndex(Value: Integer); safecall;
    function  Get_TabPosition: TgsTabPosition; safecall;
    procedure Set_TabPosition(Value: TgsTabPosition); safecall;
    function  Get_Tabs: IgsStrings; safecall;
    procedure Set_Tabs(const Value: IgsStrings); safecall;
    function  Get_TabWidth: Smallint; safecall;
    procedure Set_TabWidth(Value: Smallint); safecall;
    function  Get_Canvas: IgsCanvas; safecall;
    function  Get_Images: IgsCustomImageList; safecall;
    procedure Set_Images(const Value: IgsCustomImageList); safecall;
    function  IndexOfTabAt(X: Integer; Y: Integer): Integer; safecall;
    function  RowCount: Integer; safecall;
    procedure ScrollTabs(Delta: Integer); safecall;
    procedure TabRect(Index: Integer; out Left: OleVariant; out Top: OleVariant;
                      out Right: OleVariant; out Bottom: OleVariant); safecall;
  end;

  TwrpTabSheet = class(TwrpWinControl, IgsTabSheet)
  private
    function  GetTabSheet: TTabSheet;
  protected
    function  Get_PageControl: IgsPageControl; safecall;
    procedure Set_PageControl(const Value: IgsPageControl); safecall;
    function  Get_TabIndex: Integer; safecall;
    function  Get_Highlighted: WordBool; safecall;
    procedure Set_Highlighted(Value: WordBool); safecall;
    function  Get_ImageIndex: Integer; safecall;
    procedure Set_ImageIndex(Value: Integer); safecall;
    function  Get_PageIndex: Integer; safecall;
    procedure Set_PageIndex(Value: Integer); safecall;
    function  Get_TabVisible: WordBool; safecall;
    procedure Set_TabVisible(Value: WordBool); safecall;
  end;

  TwrpPageControl = class(TwrpCustomTabControl, IgsPageControl)
  private
    function  GetPageControl: TPageControl;
  protected
    function  Get_ActivePageIndex: Integer; safecall;
    procedure Set_ActivePageIndex(Value: Integer); safecall;
    function  Get_PageCount: Integer; safecall;
    function  CanShowTab(TabIndex: Integer): WordBool; safecall;
    function  GetImageIndex(TabIndex: Integer): Integer; safecall;
    procedure SelectNextPage(GoForward: WordBool); safecall;
    procedure UpdateActivePage; safecall;
    function  Get_Pages(Index: Integer): IgsTabSheet; safecall;
    function  FindNextPage(const CurPage: IgsTabSheet; GoForward: WordBool;
                           CheckTabVisible: WordBool): IgsTabSheet; safecall;
    function Get_ActivePage: IgsTabSheet; safecall;
    procedure Set_ActivePage(const Value: IgsTabSheet); safecall;
  end;

  TwrpBitBtn = class(TwrpButton, IgsBitBtn)
  private
    function  GetBitBtn: TBitBtn;
  protected
    function  Get_Kind: TgsBitBtnKind; safecall;
    procedure Set_Kind(Value: TgsBitBtnKind); safecall;
    function  Get_Layout: TgsButtonLayout; safecall;
    procedure Set_Layout(Value: TgsButtonLayout); safecall;
    function  Get_Margin: Integer; safecall;
    procedure Set_Margin(Value: Integer); safecall;
    function  Get_NumGlyphs: Word; safecall;
    procedure Set_NumGlyphs(Value: Word); safecall;
    function  Get_Spacing: Integer; safecall;
    procedure Set_Spacing(Value: Integer); safecall;
    function  Get_Style: TgsButtonStyle; safecall;
    procedure Set_Style(Value: TgsButtonStyle); safecall;
    function  Get_Glyph: IgsBitmap; safecall;
    procedure Set_Glyph(const Value: IgsBitmap); safecall;
  end;

  TwrpSpeedButton = class(TwrpControl, IgsSpeedButton)
  private
    function  GetSpeedButton: TSpeedButton;
  protected
    function  Get_AllowAllUp: WordBool; safecall;
    procedure Set_AllowAllUp(Value: WordBool); safecall;
    function  Get_Down: WordBool; safecall;
    procedure Set_Down(Value: WordBool); safecall;
    function  Get_Flat: WordBool; safecall;
    procedure Set_Flat(Value: WordBool); safecall;
    function  Get_GroupIndex: Integer; safecall;
    procedure Set_GroupIndex(Value: Integer); safecall;
    function  Get_Layout: TgsButtonLayout; safecall;
    procedure Set_Layout(Value: TgsButtonLayout); safecall;
    function  Get_Margin: Integer; safecall;
    procedure Set_Margin(Value: Integer); safecall;
    function  Get_MouseInControl: WordBool; safecall;
    function  Get_NumGlyphs: Integer; safecall;
    procedure Set_NumGlyphs(Value: Integer); safecall;
    function  Get_Spacing: Integer; safecall;
    procedure Set_Spacing(Value: Integer); safecall;
    function  Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;
    procedure Click; safecall;
    function  Get_Glyph: IgsBitmap; safecall;
    procedure Set_Glyph(const Value: IgsBitmap); safecall;
  end;

  TwrpSplitter = class(TwrpGraphicControl, IgsSplitter)
  private
    function  GetSplitter: TSplitter;
  protected
    function  Get_AutoSnap: WordBool; safecall;
    procedure Set_AutoSnap(Value: WordBool); safecall;
    function  Get_Beveled: WordBool; safecall;
    procedure Set_Beveled(Value: WordBool); safecall;
    function  Get_MinSize: Integer; safecall;
    procedure Set_MinSize(Value: Integer); safecall;
    function  Get_ResizeStyle: TgsResizeStyle; safecall;
    procedure Set_ResizeStyle(Value: TgsResizeStyle); safecall;
  end;

  TwrpCustomStaticText = class(TwrpWinControl, IgsCustomStaticText)
  private
    function  GetCustomStaticText: TCustomStaticText;
  protected
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_BorderStyle: TgsStaticBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsStaticBorderStyle); safecall;
    function  Get_FocusControl: IgsWinControl; safecall;
    procedure Set_FocusControl(const Value: IgsWinControl); safecall;
    function  Get_ShowAccelChar: WordBool; safecall;
    procedure Set_ShowAccelChar(Value: WordBool); safecall;
  end;

  TwrpStaticText = class(TwrpCustomStaticText, IgsStaticText)
  end;

  TwrpStatusBar = class(TwrpWinControl, IgsStatusBar)
  private
    function  GetStatusBar: TStatusBar;
  protected
    function  Get_AutoHint: WordBool; safecall;
    procedure Set_AutoHint(Value: WordBool); safecall;
    function  Get_UseSystemFont: WordBool; safecall;
    procedure Set_UseSystemFont(Value: WordBool); safecall;
    function  Get_SimplePanel: WordBool; safecall;
    procedure Set_SimplePanel(Value: WordBool); safecall;
    function  Get_SimpleText: WideString; safecall;
    procedure Set_SimpleText(const Value: WideString); safecall;
    function  Get_SizeGrip: WordBool; safecall;
    procedure Set_SizeGrip(Value: WordBool); safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;

    function  Get_Panels: IgsStatusPanels; safecall;
    procedure Set_Panels(const Value: IgsStatusPanels); safecall;
    function  Get_Canvas: IgsCanvas; safecall;
  end;

  TwrpCustomGrid = class(TwrpCustomControl, IgsCustomGrid)
  private
    function GetCustomGrid: TCustomGrid;
  protected
    function  Get_BorderStyle: TgsBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsBorderStyle); safecall;
    function  Get_Col: Integer; safecall;
    procedure Set_Col(Value: Integer); safecall;
    function  Get_ColCount: Integer; safecall;
    procedure Set_ColCount(Value: Integer); safecall;
    function  Get_ColWidths(Index: Integer): Integer; safecall;
    procedure Set_ColWidths(Index: Integer; Value: Integer); safecall;
    function  Get_DefaultColWidth: Integer; safecall;
    procedure Set_DefaultColWidth(Value: Integer); safecall;
    function  Get_DefaultDrawing: WordBool; safecall;
    procedure Set_DefaultDrawing(Value: WordBool); safecall;
    function  Get_EditorMode: WordBool; safecall;
    procedure Set_EditorMode(Value: WordBool); safecall;
    function  Get_FixedColor: Integer; safecall;
    procedure Set_FixedColor(Value: Integer); safecall;
    function  Get_FixedCols: Integer; safecall;
    procedure Set_FixedCols(Value: Integer); safecall;
    function  Get_FixedRows: Integer; safecall;
    procedure Set_FixedRows(Value: Integer); safecall;
    function  Get_GridHeight: Integer; safecall;
    function  Get_GridLineWidth: Integer; safecall;
    procedure Set_GridLineWidth(Value: Integer); safecall;
    function  Get_GridWidth: Integer; safecall;
    function  Get_LeftCol: Integer; safecall;
    procedure Set_LeftCol(Value: Integer); safecall;
    function  Get_Options: WideString; safecall;
    procedure Set_Options(const Value: WideString); safecall;
    function  Get_Row: Integer; safecall;
    procedure Set_Row(Value: Integer); safecall;
    function  Get_RowCount: Integer; safecall;
    procedure Set_RowCount(Value: Integer); safecall;
    function  Get_RowHeights(Index: Integer): Integer; safecall;
    procedure Set_RowHeights(Index: Integer; Value: Integer); safecall;
    function  Get_ScrollBars: TgsScrollStyle; safecall;
    procedure Set_ScrollBars(Value: TgsScrollStyle); safecall;
    function  Get_TabStops(Index: Integer): WordBool; safecall;
    procedure Set_TabStops(Index: Integer; Value: WordBool); safecall;
    function  Get_TopRow: Integer; safecall;
    procedure Set_TopRow(Value: Integer); safecall;
    function  Get_VisibleColCount: Integer; safecall;
    function  MouseCoord(X: Integer; Y: Integer): TgsGridCoord; safecall;

    function  Get_DefaultRowHeight: Integer; safecall;
    procedure Set_DefaultRowHeight(Value: Integer); safecall;
    function  Get_VisibleRowCount: Integer; safecall;
  end;

  TwrpDrawGrid = class(TwrpCustomGrid, IgsDrawGrid)
  private
    function  GetDrawGrid: TDrawGrid;
  protected
    procedure MouseToCell(X: Integer; Y: Integer; var ACol: OleVariant; var ARow: OleVariant); safecall;
  end;

  TwrpStringGrid = class(TwrpDrawGrid, IgsStringGrid)
  private
    function  GetStringGrid: TStringGrid;
  protected
    function  Get_Cells(ACol: Integer; ARow: Integer): WideString; safecall;
    procedure Set_Cells(ACol: Integer; ARow: Integer; const Value: WideString); safecall;
    function  Get_Cols(Index: Integer): IgsStrings; safecall;
    procedure Set_Cols(Index: Integer; const Value: IgsStrings); safecall;
    function  Get_Objects(ACol: Integer; ARow: Integer): IgsObject; safecall;
    procedure Set_Objects(ACol: Integer; ARow: Integer; const Value: IgsObject); safecall;
    function  Get_Rows(Index: Integer): IgsStrings; safecall;
    procedure Set_Rows(Index: Integer; const Value: IgsStrings); safecall;
  end;

  TwrpCustomTreeView = class(TwrpWinControl, IgsCustomTreeView)
  private
    function  GetCustomTreeView: TCustomTreeView;
  protected
    function  Get_AutoExpand: WordBool; safecall;
    procedure Set_AutoExpand(Value: WordBool); safecall;
    function  Get_BorderStyle: TgsBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsBorderStyle); safecall;
    function  Get_ChangeDelay: Integer; safecall;
    procedure Set_ChangeDelay(Value: Integer); safecall;
    function  Get_HideSelection: WordBool; safecall;
    procedure Set_HideSelection(Value: WordBool); safecall;
    function  Get_HotTrack: WordBool; safecall;
    procedure Set_HotTrack(Value: WordBool); safecall;
    function  Get_Indent: Integer; safecall;
    procedure Set_Indent(Value: Integer); safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_RightClickSelect: WordBool; safecall;
    procedure Set_RightClickSelect(Value: WordBool); safecall;
    function  Get_RowSelect: WordBool; safecall;
    procedure Set_RowSelect(Value: WordBool); safecall;
    function  Get_ShowButtons: WordBool; safecall;
    procedure Set_ShowButtons(Value: WordBool); safecall;
    function  Get_ShowLines: WordBool; safecall;
    procedure Set_ShowLines(Value: WordBool); safecall;
    function  Get_ShowRoot: WordBool; safecall;
    procedure Set_ShowRoot(Value: WordBool); safecall;
    function  Get_SortType: TgsSortType; safecall;
    procedure Set_SortType(Value: TgsSortType); safecall;
    function  Get_ToolTips: WordBool; safecall;
    procedure Set_ToolTips(Value: WordBool); safecall;
    function  AlphaSort: WordBool; safecall;
    procedure FullCollapse; safecall;
    procedure FullExpand; safecall;
    function  IsEditing: WordBool; safecall;
    procedure LoadFromFile(const FileName: WideString); safecall;
    procedure SaveToFile(const FileName: WideString); safecall;
    function  Get_Canvas: IgsCanvas; safecall;
    function  Get_Images: IgsCustomImageList; safecall;
    procedure Set_Images(const Value: IgsCustomImageList); safecall;
    function  Get_StateImages: IgsCustomImageList; safecall;
    procedure Set_StateImages(const Value: IgsCustomImageList); safecall;

    function  Get_DropTarget: IgsTreeNode; safecall;
    procedure Set_DropTarget(const Value: IgsTreeNode); safecall;
    function  Get_Selected: IgsTreeNode; safecall;
    procedure Set_Selected(const Value: IgsTreeNode); safecall;
    function  Get_TopItem: IgsTreeNode; safecall;
    procedure Set_TopItem(const Value: IgsTreeNode); safecall;
    function  GetNodeAt(x: Integer; y: Integer): IgsTreeNode; safecall;
    procedure LoadFromStream(const Stream: IgsStream); safecall;
    procedure SaveToStream(const Stream: IgsStream); safecall;
    function  Get_Items: IgsTreeNodes; safecall;
    procedure Set_Items(const Value: IgsTreeNodes); safecall;
  end;

  TwrpTreeView = class(TwrpCustomTreeView, IgsTreeView)
  end;

  TwrpCustomListView = class(TwrpWinControl, IgsCustomListView)
  private
    function  GetCustomListView: TCustomListView;
  protected
    function  Get_AllocBy: Integer; safecall;
    procedure Set_AllocBy(Value: Integer); safecall;
    function  Get_BorderStyle: TgsBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsBorderStyle); safecall;
    function  Get_Checkboxes: WordBool; safecall;
    procedure Set_Checkboxes(Value: WordBool); safecall;
    function  Get_FlatScrollBars: WordBool; safecall;
    procedure Set_FlatScrollBars(Value: WordBool); safecall;
    function  Get_FullDrag: WordBool; safecall;
    procedure Set_FullDrag(Value: WordBool); safecall;
    function  Get_GridLines: WordBool; safecall;
    procedure Set_GridLines(Value: WordBool); safecall;
    function  Get_HideSelection: WordBool; safecall;
    procedure Set_HideSelection(Value: WordBool); safecall;
    function  Get_HotTrack: WordBool; safecall;
    procedure Set_HotTrack(Value: WordBool); safecall;
    function  Get_HoverTime: Integer; safecall;
    procedure Set_HoverTime(Value: Integer); safecall;
    function  Get_MultiSelect: WordBool; safecall;
    procedure Set_MultiSelect(Value: WordBool); safecall;
    function  Get_OwnerData: WordBool; safecall;
    procedure Set_OwnerData(Value: WordBool); safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_RowSelect: WordBool; safecall;
    procedure Set_RowSelect(Value: WordBool); safecall;
    function  Get_SelCount: Integer; safecall;
    function  Get_ShowColumnHeaders: WordBool; safecall;
    procedure Set_ShowColumnHeaders(Value: WordBool); safecall;
    function  Get_ShowWorkAreas: WordBool; safecall;
    procedure Set_ShowWorkAreas(Value: WordBool); safecall;
    function  Get_SortType: TgsSortType; safecall;
    procedure Set_SortType(Value: TgsSortType); safecall;
    function  Get_ViewStyle: TgsViewStyle; safecall;
    procedure Set_ViewStyle(Value: TgsViewStyle); safecall;
    function  Get_VisibleRowCount: Integer; safecall;
    function  AlphaSort: WordBool; safecall;
    procedure Arrange(Code: TgsListArrangement); safecall;
    function  GetSearchString: WideString; safecall;
    function  IsEditing: WordBool; safecall;
    procedure Scroll(DX: Integer; DY: Integer); safecall;
    function  StringWidth(const S: WideString): Integer; safecall;
    procedure UpdateItems(FirstIndex: Integer; LastIndex: Integer); safecall;

    function  Get_Canvas: IgsCanvas; safecall;
    function  Get_Column(Index: Integer): IgsListColumn; safecall;
    function  Get_DropTarget: IgsListItem; safecall;
    procedure Set_DropTarget(const Value: IgsListItem); safecall;
    function  Get_ItemFocused: IgsListItem; safecall;
    procedure Set_ItemFocused(const Value: IgsListItem); safecall;
    function  Get_Selected: IgsListItem; safecall;
    procedure Set_Selected(const Value: IgsListItem); safecall;
    function  Get_TopItem: IgsListItem; safecall;
    function  Get_Items: IgsListItems; safecall;
    procedure Set_Items(const Value: IgsListItems); safecall;

    function  FindCaption(StartIndex: Integer; const Value: WideString; Partial: WordBool;
                          Inclusive: WordBool; Wrap: WordBool): IgsListView; safecall;
    function  FindData(StartIndex: Integer; Value: Integer; Inclusive: WordBool; Wrap: WordBool): IgsListItem; safecall;
    function  GetItemAt(X: Integer; Y: Integer): IgsListItem; safecall;
    function  GetNearestItem(X: Integer; Y: Integer; Direction: TgsSearchDirection): IgsListItem; safecall;
    function  GetNextItem(const StartItem: IgsListItem; Direction: TgsSearchDirection;
                          const States: WideString): IgsListItem; safecall;
  end;

  TwrpListView = class(TwrpCustomListView, IgsListView)
  private
    function  GetListView: TListView;
  protected
    function  Get_SmallImages: IgsCustomImageList; safecall;
    procedure Set_SmallImages(const Value: IgsCustomImageList); safecall;
    function  Get_StateImages: IgsCustomImageList; safecall;
    procedure Set_StateImages(const Value: IgsCustomImageList); safecall;
  end;

  TwrpDBCheckBox = class(TwrpCustomCheckBox, IgsDBCheckBox)
  private
    function GetDBCheckBox: TDBCheckBox;
  protected
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_ValueChecked: WideString; safecall;
    procedure Set_ValueChecked(const Value: WideString); safecall;
    function  Get_ValueUnchecked: WideString; safecall;
    procedure Set_ValueUnchecked(const Value: WideString); safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpdateAction(const Action: IgsBasicAction): WordBool; safecall;
  end;

  TwrpDBComboBox = class(TwrpCustomComboBox, IgsDBComboBox)
  private
    function GetDBComboBox: TDBComboBox;
  protected
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpdateAction(const Action: IgsBasicAction): WordBool; safecall;
  end;

  TwrpCustomMaskEdit = class(TwrpCustomEdit, IgsCustomMaskEdit)
  private
    function GetCustomMaskEdit: TCustomMaskEdit;
  protected
    function  Get_EditText: WideString; safecall;
    procedure Set_EditText(const Value: WideString); safecall;
    function  Get_IsMasked: WordBool; safecall;
    function  GetTextLen: Integer; safecall;
    procedure ValidateEdit; safecall;
    function  Get_EditMask: WideString; safecall;
    procedure Set_EditMask(const Value: WideString); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
  end;

  TwrpMaskEdit = class(TwrpCustomMaskEdit, IgsMaskEdit)
  end;

  TwrpDBEdit = class(TwrpCustomMaskEdit, IgsDBEdit)
  private
    function  GetDBEdit: TDBEdit;
  protected
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpdateAction(const Action: IgsBasicAction): WordBool; safecall;
  end;

  TwrpIBSQL = class(TwrpComponent, IgsIBSQL)
  private
    function  GetIBSQL: TIBSQL;
  protected
    function  Get_Bof: WordBool; safecall;
    function  Get_Eof: WordBool; safecall;
    function  Get_FieldIndex(const FieldName: WideString): Integer; safecall;
    function  Get_Fields(Idx: Integer): IgsIBXSQLVAR; safecall;
    function  Get_GenerateParamNames: WordBool; safecall;
    procedure Set_GenerateParamNames(Value: WordBool); safecall;
    function  Get_GoToFirstRecordOnExecute: WordBool; safecall;
    procedure Set_GoToFirstRecordOnExecute(Value: WordBool); safecall;
    function  Get_Open: WordBool; safecall;
    function  Get_ParamCheck: WordBool; safecall;
    procedure Set_ParamCheck(Value: WordBool); safecall;
    function  Get_Params: IgsIBXSQLDA; safecall;
    function  Get_Plan: WideString; safecall;
    function  Get_Prepared: WordBool; safecall;
    function  Get_RecordCount: Integer; safecall;
    function  Get_RowsAffected: Integer; safecall;
    function  Get_SQL: IgsStrings; safecall;
    procedure Set_SQL(const Value: IgsStrings); safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
    function  Get_UniqueRelationName: WideString; safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;
    procedure CheckClosed; safecall;
    procedure CheckOpen; safecall;
    procedure CheckValidStatement; safecall;
    procedure Close; safecall;
    function  Current: IgsIBXSQLDA; safecall;
    procedure ExecQuery; safecall;
    function  FieldByName(const FieldName: WideString): IgsIBXSQLVAR; safecall;
    procedure FreeHandle; safecall;
    function  GetUniqueRelationName: WideString; safecall;
    function  Next: IgsIBXSQLDA; safecall;
    function  ParamByName(const Idx: WideString): IgsIBXSQLVAR; safecall;
    procedure Prepare; safecall;

    function  Get_SQLType: TgsIBSQLTypes; safecall;
    procedure BatchInput(const InputObject: IgsIBBatchInput); safecall;
    procedure BatchOutput(const OutputObject: IgsIBBatchOutput); safecall;
    procedure Call(ErrCode: Integer; RaiseError: WordBool); safecall;
    function  GetAsCSVString: WideString; safecall;
  end;

  TwrpClientDataSet = class(TwrpDataset, IgsClientDataSet)
  private
    function  GetClientDataSet: TClientDataSet;
  protected
    function  Get_ActiveAggs(Index: Integer): IgsList; safecall;
    function  Get_AggregatesActive: WordBool; safecall;
    procedure Set_AggregatesActive(Value: WordBool); safecall;
    function  Get_ChangeCount: Integer; safecall;
    function  Get_CloneSource: IgsClientDataSet; safecall;
    function  Get_CommandText: WideString; safecall;
    procedure Set_CommandText(const Value: WideString); safecall;
    function  Get_Data: OleVariant; safecall;
    procedure Set_Data(Value: OleVariant); safecall;
    function  Get_DataSize: Integer; safecall;
    function  Get_Delta: OleVariant; safecall;
    function  Get_FetchOnDemand: WordBool; safecall;
    procedure Set_FetchOnDemand(Value: WordBool); safecall;
    function  Get_FileName: WideString; safecall;
    procedure Set_FileName(const Value: WideString); safecall;
    function  Get_GroupingLevel: Integer; safecall;
    function  Get_HasAppServer: WordBool; safecall;
    function  Get_IndexFieldCount: Integer; safecall;
    function  Get_IndexFieldNames: WideString; safecall;
    procedure Set_IndexFieldNames(const Value: WideString); safecall;
    function  Get_IndexFields(Index: Integer): IgsFieldComponent; safecall;
    procedure Set_IndexFields(Index: Integer; const Value: IgsFieldComponent); safecall;
    function  Get_KeyExclusive: WordBool; safecall;
    procedure Set_KeyExclusive(Value: WordBool); safecall;
    function  Get_KeyFieldCount: Integer; safecall;
    procedure Set_KeyFieldCount(Value: Integer); safecall;
    function  Get_KeySize: Word; safecall;
    function  Get_LogChanges: WordBool; safecall;
    procedure Set_LogChanges(Value: WordBool); safecall;
    function  Get_MasterFields: WideString; safecall;
    procedure Set_MasterFields(const Value: WideString); safecall;
    function  Get_MasterSource: IgsDataSource; safecall;
    procedure Set_MasterSource(const Value: IgsDataSource); safecall;
    function  Get_PacketRecords: Integer; safecall;
    procedure Set_PacketRecords(Value: Integer); safecall;
    function  Get_ProviderName: WideString; safecall;
    procedure Set_ProviderName(const Value: WideString); safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_SavePoint: Integer; safecall;
    procedure Set_SavePoint(Value: Integer); safecall;
    function  Get_StoreDefs: WordBool; safecall;
    procedure Set_StoreDefs(Value: WordBool); safecall;
    procedure AppendData(Data: OleVariant; HitEOF: WordBool); safecall;
    procedure ApplyRange; safecall;
    function  ApplyUpdates(MaxErrors: Integer): Integer; safecall;
    procedure CancelRange; safecall;
    procedure CancelUpdates; safecall;
    function  ConstraintsDisabled: WordBool; safecall;
    procedure CreateDataSet; safecall;
    function  DataRequest(Data: OleVariant): OleVariant; safecall;
    procedure DeleteIndex(const Name: WideString); safecall;
    procedure DisableConstraints; safecall;
    procedure EditKey; safecall;
    procedure EditRangeEnd; safecall;
    procedure EditRangeStart; safecall;
    procedure EmptyDataSet; safecall;
    procedure EnableConstraints; safecall;
    procedure Execute; safecall;
    procedure FetchBlobs; safecall;
    procedure FetchDetails; safecall;
    procedure FetchParams; safecall;
    procedure GetIndexInfo(const IndexName: WideString); safecall;
    procedure GetIndexNames(const List: IgsStrings); safecall;
    function  GetNextPacket: Integer; safecall;
    function  GetOptionalParam(const ParamName: WideString): WordBool; safecall;
    procedure GotoCurrent(const DataSet: IgsClientDataSet); safecall;
    function  GotoKey: WordBool; safecall;
    procedure GotoNearest; safecall;
    procedure LoadFromFile(const FileName: WideString); safecall;
    procedure MergeChangeLog; safecall;
    function  Reconcile(Results: OleVariant): WordBool; safecall;
    procedure RefreshRecord; safecall;
    procedure RevertRecord; safecall;
    procedure SaveToFile(const FileName: WideString; Format: TgsDataPacketFormat); safecall;
    procedure SetKey; safecall;
    procedure SetOptionalParam(const ParamName: WideString; Value: OleVariant;
                               IncludeInDelta: WordBool); safecall;
    procedure SetProvider(const Provider: IgsComponent); safecall;
    procedure SetRangeEnd; safecall;
    procedure SetRangeStart; safecall;
    function  UndoLastChange(FollowChange: WordBool): WordBool; safecall;

    procedure CloneCursor(const Source: IgsClientDataSet; Reset: WordBool; KeepSettings: WordBool); safecall;
    procedure LoadFromStream(const Stream: IgsStream); safecall;
    procedure SaveToStream(const Stream: IgsStream; Format: TgsDataPacketFormat); safecall;

    function  Get_Aggregates: IgsAggregates; safecall;
    procedure Set_Aggregates(const Value: IgsAggregates); safecall;
    function  Get_StatusFilter: WideString; safecall;
    procedure Set_StatusFilter(const Value: WideString); safecall;
    function  Get_IndexDefs: IgsIndexDefs; safecall;
    procedure Set_IndexDefs(const Value: IgsIndexDefs); safecall;
    function  Get_IndexName: WideString; safecall;
    procedure Set_IndexName(const Value: WideString); safecall;
    function  Get_Params: IgsParams; safecall;
    procedure Set_Params(const Value: IgsParams); safecall;
    procedure AddIndex(const Name: WideString; const Fields: WideString; const Options: WideString;
                       const DescFields: WideString; const CaseInsFields: WideString; 
                       GroupingLevel: Integer); safecall;
    function  GetGroupState(Level: Integer): WideString; safecall;
  end;

  TwrpDBImage = class(TwrpCustomControl, IgsDBImage)
  private
    function  GetDBImage: TDBImage;
  protected
    function  Get_AutoDisplay: WordBool; safecall;
    procedure Set_AutoDisplay(Value: WordBool); safecall;
    function  Get_BorderStyle: TgsBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsBorderStyle); safecall;
    function  Get_Center: WordBool; safecall;
    procedure Set_Center(Value: WordBool); safecall;
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  Get_QuickDraw: WordBool; safecall;
    procedure Set_QuickDraw(Value: WordBool); safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_Stretch: WordBool; safecall;
    procedure Set_Stretch(Value: WordBool); safecall;
    function  Get_Picture: IgsPicture; safecall;
    procedure CopyToClipboard; safecall;
    procedure CutToClipboard; safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpdateAction(const Action: IgsBasicAction): WordBool; safecall;
    procedure LoadPicture; safecall;
    procedure PasteFromClipboard; safecall;
  end;

  TwrpDBListBox = class(TwrpCustomListBox, IgsDBListBox)
  private
    function  GetDBListBox: TDBListBox;
  protected
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpdateAction(const Action: IgsBasicAction): WordBool; safecall;
  end;

  TwrpDBMemo = class(TwrpCustomMemo, IgsDBMemo)
  private
    function  GetDBMemo: TDBMemo;
  protected
    function  Get_AutoDisplay: WordBool; safecall;
    procedure Set_AutoDisplay(Value: WordBool); safecall;
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpDateAction(const Action: IgsBasicAction): WordBool; safecall;
    procedure LoadMemo; safecall;
  end;

  TwrpDBNavigator = class(TwrpCustomPanel, IgsDBNavigator)
  private
    function  GetDBNavigator: TDBNavigator;
  protected
    function  Get_ConfirmDelete: WordBool; safecall;
    procedure Set_ConfirmDelete(Value: WordBool); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Flat: WordBool; safecall;
    procedure Set_Flat(Value: WordBool); safecall;
    function  Get_Hints: IgsStrings; safecall;
    procedure Set_Hints(const Value: IgsStrings); safecall;
    function  Get_VisibleButtons: WideString; safecall;
    procedure Set_VisibleButtons(const Value: WideString); safecall;
    procedure BtnClick(Index: TgsNavigateBtn); safecall;
  end;

  TwrpDBRadioGroup = class(TwrpCustomRadioGroup, IgsDBRadioGroup)
  private
    function  GetDBRadioGroup: TDBRadioGroup;
  protected
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_Value: WideString; safecall;
    procedure Set_Value(const Value: WideString); safecall;
    function  Get_Values: IgsStrings; safecall;
    procedure Set_Values(const Value: IgsStrings); safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpDateAction(const Action: IgsBasicAction): WordBool; safecall;
  end;

  TwrpCustomRichEdit = class(TwrpCustomMemo, IgsCustomRichEdit)
  private
    function  GetCustomRichEdit: TCustomRichEdit;
  protected
    function  Get_HideScrollBars: WordBool; safecall;
    procedure Set_HideScrollBars(Value: WordBool); safecall;
    function  Get_PlainText: WordBool; safecall;
    procedure Set_PlainText(Value: WordBool); safecall;
    procedure DoSetMaxLength(Value: Integer); safecall;
    procedure Print(const Caption: WideString); safecall;
    procedure SelectionChange; safecall;

    function  Get_DefAttributes: IgsTextAttributes; safecall;
    procedure Set_DefAttributes(const Value: IgsTextAttributes); safecall;
    function  Get_SelAttributes: IgsTextAttributes; safecall;
    procedure Set_SelAttributes(const Value: IgsTextAttributes); safecall;
    function  Get_Paragraph: IgsParaAttributes; safecall;
  end;

  TwrpDBRichEdit = class(TwrpCustomRichEdit, IgsDBRichEdit)
  private
    function  GetDBRichEdit: TDBRichEdit;
  protected
    function  Get_AutoDisplay: WordBool; safecall;
    procedure Set_AutoDisplay(Value: WordBool); safecall;
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpDateAction(const Action: IgsBasicAction): WordBool; safecall;
    procedure LoadMemo; safecall;
  end;

  TwrpDBText = class(TwrpCustomLabel, IgsDBText)
  private
    function  GetDBText: TDBText;
  protected
    function  Get_DataField: WideString; safecall;
    procedure Set_DataField(const Value: WideString); safecall;
    function  Get_DataSource: IgsDataSource; safecall;
    procedure Set_DataSource(const Value: IgsDataSource); safecall;
    function  Get_Field: IgsFieldComponent; safecall;
    function  ExecuteAction(const Action: IgsBasicAction): WordBool; safecall;
    function  UpDateAction(const Action: IgsBasicAction): WordBool; safecall;
  end;

  TwrpIBDatabaseInfo = class(TwrpComponent, IgsIBDatabaseInfo)
  private
    function  GetIBDatabaseInfo: TIBDatabaseInfo;
  protected
    function  Get_Allocation: Integer; safecall;
    function  Get_BackoutCount: IgsStringList; safecall;
    function  Get_BaseLevel: Integer; safecall;
    function  Get_CurrentMemory: Integer; safecall;
    function  Get_DBFileName: WideString; safecall;
    function  Get_DBImplementationClass: Integer; safecall;
    function  Get_DBImplementationNo: Integer; safecall;
    function  Get_DBSiteName: WideString; safecall;
    function  Get_DBSQLDialect: Integer; safecall;
    function  Get_DeleteCount: IgsStringList; safecall;
    function  Get_ExpungeCount: IgsStringList; safecall;
    function  Get_Fetches: Integer; safecall;
    function  Get_ForcedWrites: Integer; safecall;
    function  Get_InsertCount: IgsStringList; safecall;
    function  Get_Marks: Integer; safecall;
    function  Get_MaxMemory: Integer; safecall;
    function  Get_NoReserve: Integer; safecall;
    function  Get_NumBuffers: Integer; safecall;
    function  Get_ODSMajorVersion: Integer; safecall;
    function  Get_ODSMinorVersion: Integer; safecall;
    function  Get_PageSize: Integer; safecall;
    function  Get_PurgeCount: IgsStringList; safecall;
    function  Get_ReadIdxCount: IgsStringList; safecall;
    function  Get_ReadOnly: Integer; safecall;
    function  Get_Reads: Integer; safecall;
    function  Get_ReadSeqCount: IgsStringList; safecall;
    function  Get_SweepInterval: Integer; safecall;
    function  Get_UpdateCount: IgsStringList; safecall;
    function  Get_Version: WideString; safecall;
    function  Get_Writes: Integer; safecall;
    function  GetLongDatabaseInfo(DatabaseInfoCommand: Integer): Integer; safecall;

    function  Get_UserNames: IgsStringList; safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;
    function  Call(ErrCode: Integer; RaiseError: WordBool): Integer; safecall;
  end;

  TwrpIBEvents = class(TwrpComponent, IgsIBEvents)
  private
    function  GetIBEvents: TIBEvents;
  protected
    function  Get_AutoRegister: WordBool; safecall;
    procedure Set_AutoRegister(Value: WordBool); safecall;
    function  Get_Events: IgsStrings; safecall;
    procedure Set_Events(const Value: IgsStrings); safecall;
    function  Get_Registered: WordBool; safecall;
    procedure Set_Registered(Value: WordBool); safecall;
    procedure RegisterEvents; safecall;
    procedure UnRegisterEvents; safecall;
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;
  end;

  TwrpCustomConnection = class(TwrpComponent, IgsCustomConnection)
  private
    function  GetCustomConnection: TCustomConnection;
  protected
    function  Get_DataSetCount: Integer; safecall;
    function  Get_DataSets(Index: Integer): IgsDataSet; safecall;
    function  Get_LoginPrompt: WordBool; safecall;
    procedure Set_LoginPrompt(Value: WordBool); safecall;
    procedure Open; safecall;
    procedure Close; safecall;
    function  Get_Connected: WordBool; safecall;
    procedure Set_Connected(Value: WordBool); safecall;
  end;

  TwrpIBDatabase = class(TwrpCustomConnection, IgsIBDatabase)
  private
    function  GetIBDatabase: TIBDatabase;

  protected
    function  Get_AllowStreamedConnected: WordBool; safecall;
    procedure Set_AllowStreamedConnected(Value: WordBool); safecall;
    function  Get_DatabaseName: WideString; safecall;
    procedure Set_DatabaseName(const Value: WideString); safecall;
    function  Get_DBParamByDPB(Idx: Integer): WideString; safecall;
    procedure Set_DBParamByDPB(Idx: Integer; const Value: WideString); safecall;
    function  Get_DBSQLDialect: Integer; safecall;
    function  Get_DefaultTransaction: IgsIBTransaction; safecall;
    procedure Set_DefaultTransaction(const Value: IgsIBTransaction); safecall;
    function  Get_HandleIsShared: WordBool; safecall;
    function  Get_IdleTimer: Integer; safecall;
    procedure Set_IdleTimer(Value: Integer); safecall;
    function  Get_InternalTransaction: IgsIBTransaction; safecall;
    function  Get_IsReadOnly: WordBool; safecall;
    function  Get_Params: IgsStrings; safecall;
    procedure Set_Params(const Value: IgsStrings); safecall;
    function  Get_SQLDialect: Integer; safecall;
    procedure Set_SQLDialect(Value: Integer); safecall;
    function  Get_SQLObjectCount: Integer; safecall;
    function  Get_TransactionCount: Integer; safecall;
    function  Get_Transactions(Index: Integer): IgsIBTransaction; safecall;
    function  AddTransaction(const TR: IgsIBTransaction): Integer; safecall;
    procedure CheckActive; safecall;
    procedure CheckDatabaseName; safecall;
    procedure CheckInactive; safecall;
    procedure CloseDataSets; safecall;
    procedure CreateDatabase; safecall;
    procedure DropDatabase; safecall;
    function  FindTransaction(const TR: IgsIBTransaction): Integer; safecall;
    procedure FlushSchema; safecall;
    procedure ForceClose; safecall;
    procedure GetFieldNames(const TableName: WideString; const List: IgsStrings); safecall;
    procedure GetTableNames(const List: IgsStrings; SystemTables: WordBool); safecall;
    function  Has_COMPUTED_BLR(const Relation: WideString; const Field: WideString): WordBool; safecall;
    function  Has_DEFAULT_VALUE(const Relation: WideString; const Field: WideString): WordBool; safecall;
    function  IndexOfDBConst(const st: WideString): Integer; safecall;
    procedure RemoveTransaction(Idx: Integer); safecall;
    procedure RemoveTransactions; safecall;
    function  TestConnected: WordBool; safecall;

    function  Get_SQLObjects(Index: Integer): IgsIBBase; safecall;
    function  Call(ErrCode: Integer; RaiseError: WordBool): Integer; safecall;
    function  FindDefaultTransaction: IgsIBTransaction; safecall;
    function  Get_DEFAULT_VALUE(const Relation: WideString; const Field: WideString): WideString; safecall;
  end;

  TwrpIBExtract = class(TwrpComponent, IgsIBExtract)
  private
    function  GetIBExtract: TIBExtract;
  protected
    function  Get_Database: IgsIBDatabase; safecall;
    procedure Set_Database(const Value: IgsIBDatabase); safecall;
    function  Get_DatabaseInfo: IgsIBDatabaseInfo; safecall;
    function  Get_Items: IgsStrings; safecall;
    function  Get_ShowSystem: WordBool; safecall;
    procedure Set_ShowSystem(Value: WordBool); safecall;
    function  Get_Transaction: IgsIBTransaction; safecall;
    procedure Set_Transaction(const Value: IgsIBTransaction); safecall;
    function  GetArrayField(var FieldName: OleVariant): WideString; safecall;
    function  GetCharacterSets(CharSetId: Smallint; Collation: Smallint; CollateOnly: WordBool): WideString; safecall;
    function  GetFieldType(FieldType: Integer; FieldSubType: Integer; FieldScale: Integer;
                           FieldSize: Integer; FieldPrec: Integer; FieldLen: Integer): WideString; safecall;
    procedure Notification(const AComponent: IgsComponent; Operation: TgsOperation); safecall;
  end;

  TwrpIBQuery = class(TwrpIBCustomDataSet, IgsIBQuery)
  private
    function  GetIBQuery: TIBQuery;
  protected
    function  Get_GenerateParamNames: WordBool; safecall;
    procedure Set_GenerateParamNames(Value: WordBool); safecall;
    function  Get_ParamCount: Word; safecall;
    function  Get_Prepared: WordBool; safecall;
    procedure Set_Prepared(Value: WordBool); safecall;
    function  Get_SQL: IgsStrings; safecall;
    function  Get_Text: WideString; safecall;
    procedure ExecSQL; safecall;
    procedure Prepare; safecall;
    procedure UnPrepare; safecall;
    function  ParamByName(const Name: WideString): IgsParam; safecall;

    function  Get_StatementType: TgsIBSQLTypes; safecall;
    function  Get_Constraints: IgsCheckConstraints; safecall;
    procedure Set_Constraints(const Value: IgsCheckConstraints); safecall;
    function  Get_GeneratorField: IgsIBGeneratorField; safecall;
    procedure Set_GeneratorField(const Value: IgsIBGeneratorField); safecall;
    procedure BatchInput(const InputObject: IgsIBBatchInput); safecall;
    procedure BatchOutput(const OutputObject: IgsIBBatchOutput); safecall;
  end;

  TwrpIBStoredProc = class(TwrpIBCustomDataSet, IgsIBStoredProc)
  private
    function  GetIBStoredProc: TIBStoredProc;
  protected
    function  Get_ParamCount: Word; safecall;
    function  Get_Prepared: WordBool; safecall;
    procedure Set_Prepared(Value: WordBool); safecall;
    function  Get_StoredProcedureNames: IgsStrings; safecall;
    function  Get_StoredProcName: WideString; safecall;
    procedure Set_StoredProcName(const Value: WideString); safecall;
    procedure ExecProc; safecall;
    procedure Prepare; safecall;
    procedure UnPrepare; safecall;
    procedure CopyParams(const Value: IgsParams); safecall;
    function  ParamByName(const Value: WideString): IgsParam; safecall;
  end;

  TwrpIBTable = class(TwrpIBCustomDataSet, IgsIBTable)
  private
    function  GetIBTable: TIBTable;
  protected
    function  Get_DefaultIndex: WordBool; safecall;
    procedure Set_DefaultIndex(Value: WordBool); safecall;
    function  Get_Exists: WordBool; safecall;
    function  Get_IndexFieldCount: Integer; safecall;
    function  Get_IndexFieldNames: WideString; safecall;
    procedure Set_IndexFieldNames(const Value: WideString); safecall;
    function  Get_IndexFields(Index: Integer): IgsFieldComponent; safecall;
    procedure Set_IndexFields(Index: Integer; const Value: IgsFieldComponent); safecall;
    function  Get_IndexName: WideString; safecall;
    procedure Set_IndexName(const Value: WideString); safecall;
    function  Get_MasterFields: WideString; safecall;
    procedure Set_MasterFields(const Value: WideString); safecall;
    function  Get_MasterSource: IgsDataSource; safecall;
    procedure Set_MasterSource(const Value: IgsDataSource); safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_StoreDefs: WordBool; safecall;
    procedure Set_StoreDefs(Value: WordBool); safecall;
    function  Get_TableName: WideString; safecall;
    procedure Set_TableName(const Value: WideString); safecall;
    function  Get_TableNames: IgsStrings; safecall;
    procedure CreateTable; safecall;
    procedure DeleteIndex(const Name: WideString); safecall;
    procedure DeleteTable; safecall;
    procedure EmptyTable; safecall;
    procedure GetIndexNames(const List: IgsStrings); safecall;
    procedure GotoCurrent(const Table: IgsIBTable); safecall;

    function  Get_Constraints: IgsCheckConstraints; safecall;
    procedure Set_Constraints(const Value: IgsCheckConstraints); safecall;
    function  Get_IndexDefs: IgsIndexDefs; safecall;
    procedure Set_IndexDefs(const Value: IgsIndexDefs); safecall;
  end;

  TwrpIBDataSetUpdateObject = class(TwrpComponent, IgsIBDataSetUpdateObject)
  private
    function  GetIBDataSetUpdateObject: TIBDataSetUpdateObject;
  protected
    function  Get_RefreshSQL: IgsStrings; safecall;
    procedure Set_RefreshSQL(const Value: IgsStrings); safecall;
    procedure Apply(UpdateKind: TgsUpdateKind); safecall;
    function  GetSQL(UpdateKind: TgsUpdateKind): IgsStrings; safecall;
    function  Get_DataSet: IgsIBCustomDataSet; safecall;
    procedure Set_DataSet(const Value: IgsIBCustomDataSet); safecall;
  end;

  TwrpIBUpdateSQL = class(TwrpIBDataSetUpdateObject, IgsIBUpdateSQL)
  private
    function  GetIBUpdateSQL: TIBUpdateSQL;
  protected
    procedure ExecSQL(UpdateKind: TgsUpdateKind); safecall;
    procedure SetParams(UpdateKind: TgsUpdateKind); safecall;
    function  Get_Query(UpdateKind: TgsUpdateKind): IgsQuery; safecall;
    function  Get_SQL(UpdateKind: TgsUpdateKind): IgsStrings; safecall;
    procedure Set_SQL(UpdateKind: TgsUpdateKind; const Value: IgsStrings); safecall;
    function  Get_ModifySQL: IgsStrings; safecall;
    procedure Set_ModifySQL(const Value: IgsStrings); safecall;
    function  Get_InsertSQL: IgsStrings; safecall;
    procedure Set_InsertSQL(const Value: IgsStrings); safecall;
    function  Get_DeleteSQL: IgsStrings; safecall;
    procedure Set_DeleteSQL(const Value: IgsStrings); safecall;
  end;

  TwrpHeaderControl = class(TwrpWinControl, IgsHeaderControl)
  private
    function  GetHeaderControl: THeaderControl;
  protected
    function  Get_DragReorder: WordBool; safecall;
    procedure Set_DragReorder(Value: WordBool); safecall;
    function  Get_FullDrag: WordBool; safecall;
    procedure Set_FullDrag(Value: WordBool); safecall;
    function  Get_HotTrack: WordBool; safecall;
    procedure Set_HotTrack(Value: WordBool); safecall;
    function  Get_Style: TgsHeaderStyle; safecall;
    procedure Set_Style(Value: TgsHeaderStyle); safecall;

    function  Get_Canvas: IgsCanvas; safecall;
    function  Get_Images: IgsCustomImageList; safecall;
    procedure Set_Images(const Value: IgsCustomImageList); safecall;
    function  Get_Sections: IgsHeaderSections; safecall;
    procedure Set_Sections(const Value: IgsHeaderSections); safecall;
  end;

  TwrpHotKey = class(TwrpWinControl, IgsHotKey)
  private
    function  GetHotKey: THotKey;
  protected
    function  Get_HotKey: Word; safecall;
    procedure Set_HotKey(Value: Word); safecall;
  end;

  TwrpCustomImageList = class(TwrpComponent, IgsCustomImageList)
  private
    function  GetCustomImageList: TCustomImageList;
  protected
    function  Get_AllocBy: Integer; safecall;
    procedure Set_AllocBy(Value: Integer); safecall;
    function  Get_BkColor: Integer; safecall;
    procedure Set_BkColor(Value: Integer); safecall;
    function  Get_BlendColor: Integer; safecall;
    procedure Set_BlendColor(Value: Integer); safecall;
    function  Get_Count: Integer; safecall;
    function  Get_DrawingStyle: TgsDrawingStyle; safecall;
    procedure Set_DrawingStyle(Value: TgsDrawingStyle); safecall;
    function  Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function  Get_ImageType: TgsImageType; safecall;
    procedure Set_ImageType(Value: TgsImageType); safecall;
    function  Get_Masked: WordBool; safecall;
    procedure Set_Masked(Value: WordBool); safecall;
    function  Get_ShareImages: WordBool; safecall;
    procedure Set_ShareImages(Value: WordBool); safecall;
    function  Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    procedure AddImages(const Value: IgsCustomImageList); safecall;
    procedure Clear; safecall;
    procedure Delete(Index: Integer); safecall;
    function  FileLoad(ResType: TgsResType; const Name: WideString; MaskColor: Integer): WordBool; safecall;
    function  HandleAllocated: WordBool; safecall;
    procedure Move(CurIndex: Integer; NewIndex: Integer); safecall;
    function  ResInstLoad(Instance: Integer; ResType: TgsResType; const Name: WideString;
                          MaskColor: Integer): WordBool; safecall;
    function  ResourceLoad(ResType: TgsResType; const Name: WideString; MaskColor: Integer): WordBool; safecall;
    function  Get_Handle: Integer; safecall;
    procedure Set_Handle(Value: Integer); safecall;

    function  AddMasked(const Image: IgsBitmap; MaskColor: Integer): Integer; safecall;
    procedure Draw(const Canvas: IgsCanvas; X: Integer; Y: Integer; Index: Integer;
                   Enabled: WordBool); safecall;
    procedure DrawOverlay(const Canvas: IgsCanvas; X: Integer; Y: Integer; ImageIndex: Integer;
                          Overlay: TgsOverlay; Enabled: WordBool); safecall;
    procedure GetBitmap(Index: Integer; const Image: IgsBitmap); safecall;
    function  Add(const Image: IgsBitmap; const Mask: IgsBitmap): Integer; safecall;
    function  AddIcon(const Image: IgsIcon): Integer; safecall;
    procedure GetHotSpot(out X: OleVariant; out Y: OleVariant); safecall;
    procedure GetIcon(Index: Integer; const Image: IgsIcon); safecall;
    function  GetImageBitmap: Integer; safecall;
    function  GetMaskBitmap: Integer; safecall;
    procedure Insert(Index: Integer; const Image: IgsBitmap; const Mask: IgsBitmap); safecall;
    procedure InsertIcon(Index: Integer; const Image: IgsIcon); safecall;
    function  Overlay(Index: Integer; Overlay: TgsOverlay): WordBool; safecall;
    procedure RegisterChanges(const Value: IgsChangeLink); safecall;
    procedure Replace(Index: Integer; const Image: IgsBitmap; const Mask: IgsBitmap); safecall;
    procedure ReplaceIcon(Index: Integer; const Image: IgsIcon); safecall;
    procedure ReplaceMasked(Index: Integer; const NewImage: IgsBitmap; MaskColor: Integer); safecall;
  end;

  TwrpDragImageList = class(TwrpCustomImageList, IgsDragImageList)
  private
    function  GetDragImageList: TDragImageList;
  protected
    function  Get_Dragging: WordBool; safecall;
    function  BeginDrag(Window: Integer; X: Integer; Y: Integer): WordBool; safecall;
    function  DragLock(Window: Integer; XPos: Integer; YPos: Integer): WordBool; safecall;
    function  DragMove(X: Integer; Y: Integer): WordBool; safecall;
    procedure DragUnlock; safecall;
    function  EndDrag: WordBool; safecall;
    procedure HideDragImage; safecall;
    function  SetDragImage(Index: Integer; HotSpotX: Integer; HotSpotY: Integer): WordBool; safecall;
    procedure ShowDragImage; safecall;
    function  Get_DragCursor: Smallint; safecall;
    procedure Set_DragCursor(Value: Smallint); safecall;
  end;

  TwrpCustomOutline = class(TwrpCustomGrid, IgsCustomOutline)
  private
    function  GetCustomOutline: TCustomOutline;
  protected
    function  Get_ItemCount: Integer; safecall;
    function  Get_ItemHeight: Integer; safecall;
    procedure Set_ItemHeight(Value: Integer); safecall;
    function  Get_ItemSeparator: WideString; safecall;
    procedure Set_ItemSeparator(const Value: WideString); safecall;
    function  Get_Lines: IgsStrings; safecall;
    procedure Set_Lines(const Value: IgsStrings); safecall;
    function  Get_OutlineStyle: TgsOutlineStyle; safecall;
    procedure Set_OutlineStyle(Value: TgsOutlineStyle); safecall;
    function  Get_SelectedItem: Integer; safecall;
    procedure Set_SelectedItem(Value: Integer); safecall;
    function  Get_Style: TgsOutlineType; safecall;
    procedure Set_Style(Value: TgsOutlineType); safecall;
    function  Add(Index: Integer; const Text: WideString): Integer; safecall;
    function  AddChild(Index: Integer; const Text: WideString): Integer; safecall;
    procedure BeginUpdate; safecall;
    procedure Clear; safecall;
    procedure Delete(Index: Integer); safecall;
    procedure EndUpdate; safecall;
    procedure FullCollapse; safecall;
    procedure FullExpand; safecall;
    function  GetItem(X: Integer; Y: Integer): Integer; safecall;
    function  GetTextItem(const Value: WideString): Integer; safecall;
    function  Insert(Index: Integer; const Text: WideString): Integer; safecall;
    procedure LoadFromFile(const FileName: WideString); safecall;
    procedure SaveToFile(const FileName: WideString); safecall;
    procedure SetUpdateState(Value: WordBool); safecall;
    function  Get_Items(Index: Integer): IgsOutlineNode; safecall;
    function  GetNodeDisplayWidth(const Node: IgsOutlineNode): Integer; safecall;
    function  GetVisibleNode(Index: Integer): IgsOutlineNode; safecall;
    procedure LoadFromStream(const Stream: IgsStream); safecall;
    procedure SaveToStream(const Stream: IgsStream); safecall;
  end;

  TwrpOutline = class(TwrpCustomOutline, IgsOutline)
  private
    function  GetOutline: TOutline;
  protected
    function  Get_PicturePlus: IgsBitmap; safecall;
    procedure Set_PicturePlus(const Value: IgsBitmap); safecall;
    function  Get_PictureMinus: IgsBitmap; safecall;
    procedure Set_PictureMinus(const Value: IgsBitmap); safecall;
    function  Get_PictureOpen: IgsBitmap; safecall;
    procedure Set_PictureOpen(const Value: IgsBitmap); safecall;
    function  Get_PictureClosed: IgsBitmap; safecall;
    procedure Set_PictureClosed(const Value: IgsBitmap); safecall;
    function  Get_PictureLeaf: IgsBitmap; safecall;
    procedure Set_PictureLeaf(const Value: IgsBitmap); safecall;
  end;

  TwrpTimer = class(TwrpComponent, IgsTimer)
  private
    function  GetTimer: TTimer;
  protected
    function  Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function  Get_Interval: Integer; safecall;
    procedure Set_Interval(Value: Integer); safecall;
  end;

  TwrpAnimate = class(TwrpWinControl, IgsAnimate)
  private
    function  GetAnimate: TAnimate;
  protected
    function  Get_Active: WordBool; safecall;
    procedure Set_Active(Value: WordBool); safecall;
    function  Get_Center: WordBool; safecall;
    procedure Set_Center(Value: WordBool); safecall;
    function  Get_CommonAVI: TgsCommonAVI; safecall;
    procedure Set_CommonAVI(Value: TgsCommonAVI); safecall;
    function  Get_FileName: WideString; safecall;
    procedure Set_FileName(const Value: WideString); safecall;
    function  Get_FrameCount: Integer; safecall;
    function  Get_FrameHeight: Integer; safecall;
    function  Get_FrameWidth: Integer; safecall;
    function  Get_Open: WordBool; safecall;
    procedure Set_Open(Value: WordBool); safecall;
    function  Get_Repetitions: Integer; safecall;
    procedure Set_Repetitions(Value: Integer); safecall;
    function  Get_ResHandle: Integer; safecall;
    procedure Set_ResHandle(Value: Integer); safecall;
    function  Get_ResID: Integer; safecall;
    procedure Set_ResID(Value: Integer); safecall;
    function  Get_ResName: WideString; safecall;
    procedure Set_ResName(const Value: WideString); safecall;
    function  Get_StartFrame: Smallint; safecall;
    procedure Set_StartFrame(Value: Smallint); safecall;
    function  Get_StopFrame: Smallint; safecall;
    procedure Set_StopFrame(Value: Smallint); safecall;
    function  Get_Timers: WordBool; safecall;
    procedure Set_Timers(Value: WordBool); safecall;
    function  Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;
    procedure Play(FromFrame: Word; ToFrame: Word; Count: Integer); safecall;
    procedure Reset; safecall;
    procedure Seek(Frame: Smallint); safecall;
    procedure Stop; safecall;
  end;

  TwrpDirectoryListBox = class(TwrpCustomListBox, IgsDirectoryListBox)
  private
    function  GetDirectoryListBox: TDirectoryListBox;
  protected
    function  Get_CaseSensitive: WordBool; safecall;
    function  Get_Directory: WideString; safecall;
    procedure Set_Directory(const Value: WideString); safecall;
    function  Get_DirLabel: IgsLabel; safecall;
    procedure Set_DirLabel(const Value: IgsLabel); safecall;
    function  Get_Drive: Byte; safecall;
    procedure Set_Drive(Value: Byte); safecall;
    function  Get_PreserveCase: WordBool; safecall;
    function  DisplayCase(const S: WideString): WideString; safecall;
    function  FileCompareText(const A: WideString; const B: WideString): Integer; safecall;
    function  GetItemPath(Index: Integer): WideString; safecall;
    procedure OpenCurrent; safecall;
    function  Get_FileList: IgsFileListBox; safecall;
    procedure Set_FileList(const Value: IgsFileListBox); safecall;
  end;

  TwrpColorGrid = class(TwrpCustomControl, IgsColorGrid)
  private
    function  GetColorGrid: TColorGrid;
  protected
    function  ColorToIndex(AColor: Integer): Integer; safecall;
    function  Get_ForegroundColor: Integer; safecall;
    function  Get_BackgroundColor: Integer; safecall;
    function  Get_ClickEnablesColor: WordBool; safecall;
    procedure Set_ClickEnablesColor(Value: WordBool); safecall;
    function  Get_GridOrdering: TgsGridOrdering; safecall;
    procedure Set_GridOrdering(Value: TgsGridOrdering); safecall;
    function  Get_ForegroundIndex: Integer; safecall;
    procedure Set_ForegroundIndex(Value: Integer); safecall;
    function  Get_BackgroundIndex: Integer; safecall;
    procedure Set_BackgroundIndex(Value: Integer); safecall;
    function  Get_ForegroundEnabled: WordBool; safecall;
    procedure Set_ForegroundEnabled(Value: WordBool); safecall;
    function  Get_BackgroundEnabled: WordBool; safecall;
    procedure Set_BackgroundEnabled(Value: WordBool); safecall;
    function  Get_Selection: Integer; safecall;
    procedure Set_Selection(Value: Integer); safecall;
  end;

  TwrpCustomControlBar = class(TwrpCustomControl, IgsCustomControlBar)
  private
    function  GetCustomControlBar: TCustomControlBar;
  protected
    function  Get_AutoDock: WordBool; safecall;
    procedure Set_AutoDock(Value: WordBool); safecall;
    function  Get_AutoDrag: WordBool; safecall;
    procedure Set_AutoDrag(Value: WordBool); safecall;
    function  Get_RowSize: Integer; safecall;
    procedure Set_RowSize(Value: Integer); safecall;
    function  Get_RowSnap: WordBool; safecall;
    procedure Set_RowSnap(Value: WordBool); safecall;
    procedure StickControls; safecall;
    function  Get_Picture: IgsPicture; safecall;
    procedure Set_Picture(const Value: IgsPicture); safecall;
  end;

  TwrpToolWindow = class(TwrpWinControl, IgsToolWindow)
  private
    function  GetToolWindow: TToolWindow;
  protected
    function  Get_EdgeInner: TgsEdgeStyle; safecall;
    procedure Set_EdgeInner(Value: TgsEdgeStyle); safecall;
    function  Get_EdgeOuter: TgsEdgeStyle; safecall;
    procedure Set_EdgeOuter(Value: TgsEdgeStyle); safecall;
  end;

  TwrpCoolBar = class(TwrpToolWindow, IgsCoolBar)
  private
    function  GetCoolBar: TCoolBar;
  protected
    function  Get_BandBorderStyle: TgsBorderStyle; safecall;
    procedure Set_BandBorderStyle(Value: TgsBorderStyle); safecall;
    function  Get_FixedOrder: WordBool; safecall;
    procedure Set_FixedOrder(Value: WordBool); safecall;
    function  Get_FixedSize: WordBool; safecall;
    procedure Set_FixedSize(Value: WordBool); safecall;
    function  Get_Images: IgsCustomImageList; safecall;
    procedure Set_Images(const Value: IgsCustomImageList); safecall;
    function  Get_ShowText: WordBool; safecall;
    procedure Set_ShowText(Value: WordBool); safecall;
    function  Get_Vertical: WordBool; safecall;
    procedure Set_Vertical(Value: WordBool); safecall;
    function  Get_Bitmap: IgsBitmap; safecall;
    procedure Set_Bitmap(const Value: IgsBitmap); safecall;
  end;

  TwrpCommonCalendar = class(TwrpWinControl, IgsCommonCalendar)
  private
    function  GetCommonCalendar: TCommonCalendar;
  protected
    function  Get_Date: TDateTime; safecall;
    procedure Set_Date(Value: TDateTime); safecall;
    function  Get_DateTime: TDateTime; safecall;
    procedure Set_DateTime(Value: TDateTime); safecall;
    function  Get_MaxDate: TDateTime; safecall;
    procedure Set_MaxDate(Value: TDateTime); safecall;
    function  Get_MinDate: TDateTime; safecall;
    procedure Set_MinDate(Value: TDateTime); safecall;
    function  Get_EndDate: TDateTime; safecall;
    procedure Set_EndDate(Value: TDateTime); safecall;
    function  Get_FirstDayOfWeek: TgsCalDayOfWeek; safecall;
    procedure Set_FirstDayOfWeek(Value: TgsCalDayOfWeek); safecall;
    function  Get_MaxSelectRange: Integer; safecall;
    procedure Set_MaxSelectRange(Value: Integer); safecall;
    function  Get_MultiSelect: WordBool; safecall;
    procedure Set_MultiSelect(Value: WordBool); safecall;
    function  Get_ShowToday: WordBool; safecall;
    procedure Set_ShowToday(Value: WordBool); safecall;
    function  Get_ShowTodayCircle: WordBool; safecall;
    procedure Set_ShowTodayCircle(Value: WordBool); safecall;
    function  Get_WeekNumbers: WordBool; safecall;
    procedure Set_WeekNumbers(Value: WordBool); safecall;
  end;

  TwrpDateTimePicker = class(TwrpCommonCalendar, IgsDateTimePicker)
  private
    function  GetDateTimePicker: TDateTimePicker;
  protected
    function  Get_CalAlignment: TgsDTCalAlignment; safecall;
    procedure Set_CalAlignment(Value: TgsDTCalAlignment); safecall;
    function  Get_Checked: WordBool; safecall;
    procedure Set_Checked(Value: WordBool); safecall;
    function  Get_DateFormat: TgsDTDateFormat; safecall;
    procedure Set_DateFormat(Value: TgsDTDateFormat); safecall;
    function  Get_DateMode: TgsDTDateMode; safecall;
    procedure Set_DateMode(Value: TgsDTDateMode); safecall;
    function  Get_DroppedDown: WordBool; safecall;
    function  Get_Kind: TgsDateTimeKind; safecall;
    procedure Set_Kind(Value: TgsDateTimeKind); safecall;
    function  Get_ParseInput: WordBool; safecall;
    procedure Set_ParseInput(Value: WordBool); safecall;
    function  Get_ShowCheckbox: WordBool; safecall;
    procedure Set_ShowCheckbox(Value: WordBool); safecall;
    function  Get_Time: TDateTime; safecall;
    procedure Set_Time(Value: TDateTime); safecall;
  end;

  TwrpDriveComboBox = class(TwrpCustomComboBox, IgsDriveComboBox)
  private
    function  GetDriveComboBox: TDriveComboBox;
  protected
    function  Get_DirList: IgsDirectoryListBox; safecall;
    procedure Set_DirList(const Value: IgsDirectoryListBox); safecall;
    function  Get_Drive: Byte; safecall;
    procedure Set_Drive(Value: Byte); safecall;
    function  Get_TextCase: TgsTextCase; safecall;
    procedure Set_TextCase(Value: TgsTextCase); safecall;
  end;

  TwrpFileListBox = class(TwrpCustomListBox, IgsFileListBox)
  private
    function  GetFileListBox: TFileListBox;
  protected
    function  Get_Directory: WideString; safecall;
    procedure Set_Directory(const Value: WideString); safecall;
    function  Get_Drive: Byte; safecall;
    procedure Set_Drive(Value: Byte); safecall;
    function  Get_FileEdit: IgsEdit; safecall;
    procedure Set_FileEdit(const Value: IgsEdit); safecall;
    function  Get_FileName: WideString; safecall;
    procedure Set_FileName(const Value: WideString); safecall;
    function  Get_Mask: WideString; safecall;
    procedure Set_Mask(const Value: WideString); safecall;
    function  Get_ShowGlyphs: WordBool; safecall;
    procedure Set_ShowGlyphs(Value: WordBool); safecall;
    procedure ApplyFilePath(const EditText: WideString); safecall;
  end;

  TwrpFilterComboBox = class(TwrpCustomComboBox, IgsFilterComboBox)
  private
    function  GetFilterComboBox: TFilterComboBox;
  protected
    function  Get_FileList: IgsFileListBox; safecall;
    procedure Set_FileList(const Value: IgsFileListBox); safecall;
    function  Get_Filter: WideString; safecall;
    procedure Set_Filter(const Value: WideString); safecall;
    function  Get_Mask: WideString; safecall;
  end;

  TwrpGauge = class(TwrpGraphicControl, IgsGauge)
  private
    function  GetGauge: TGauge;
  protected
    procedure AddProgress(Value: Integer); safecall;
    function  Get_PercentDone: Integer; safecall;
    function  Get_BackColor: Integer; safecall;
    procedure Set_BackColor(Value: Integer); safecall;
    function  Get_BorderStyle: TgsBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsBorderStyle); safecall;
    function  Get_ForeColor: Integer; safecall;
    procedure Set_ForeColor(Value: Integer); safecall;
    function  Get_Kind: TgsGaugeKind; safecall;
    procedure Set_Kind(Value: TgsGaugeKind); safecall;
    function  Get_MinValue: Integer; safecall;
    procedure Set_MinValue(Value: Integer); safecall;
    function  Get_MaxValue: Integer; safecall;
    procedure Set_MaxValue(Value: Integer); safecall;
    function  Get_Progress: Integer; safecall;
    procedure Set_Progress(Value: Integer); safecall;
    function  Get_ShowText: WordBool; safecall;
    procedure Set_ShowText(Value: WordBool); safecall;
  end;

  TwrpImage = class(TwrpGraphicControl, IgsImage)
  private
    function  GetImage: TImage;
  protected
    function  Get_Center: WordBool; safecall;
    procedure Set_Center(Value: WordBool); safecall;
    function  Get_IncrementalDisplay: WordBool; safecall;
    procedure Set_IncrementalDisplay(Value: WordBool); safecall;
    function  Get_Stretch: WordBool; safecall;
    procedure Set_Stretch(Value: WordBool); safecall;
    function  Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;
    function  Get_Picture: IgsPicture; safecall;
    procedure Set_Picture(const Value: IgsPicture); safecall;
  end;

  TwrpJPEGImage = class(TwrpGraphic, IgsJPEGImage)
  end;

  TwrpPageScroller = class(TwrpWinControl, IgsPageScroller)
  private
    function  GetPageScroller: TPageScroller;
  protected
    function  Get_AutoScroll: WordBool; safecall;
    procedure Set_AutoScroll(Value: WordBool); safecall;
    function  Get_ButtonSize: Integer; safecall;
    procedure Set_ButtonSize(Value: Integer); safecall;
    function  Get_Control: IgsWinControl; safecall;
    procedure Set_Control(const Value: IgsWinControl); safecall;
    function  Get_DragScroll: WordBool; safecall;
    procedure Set_DragScroll(Value: WordBool); safecall;
    function  Get_Margin: Integer; safecall;
    procedure Set_Margin(Value: Integer); safecall;
    function  Get_Orientation: TgsPageScrollerOrientation; safecall;
    procedure Set_Orientation(Value: TgsPageScrollerOrientation); safecall;
    function  Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    function  GetButtonState(Button: TgsPageScrollerButton): TgsPageScrollerButtonState; safecall;
  end;

  TwrpProgressBar = class(TwrpWinControl, IgsProgressBar)
  private
    function  GetProgressBar: TProgressBar;
  protected
    function  Get_Max: Integer; safecall;
    procedure Set_Max(Value: Integer); safecall;
    function  Get_Min: Integer; safecall;
    procedure Set_Min(Value: Integer); safecall;
    function  Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    function  Get_Orientation: TgsProgressBarOrientation; safecall;
    procedure Set_Orientation(Value: TgsProgressBarOrientation); safecall;
    function  Get_Smooth: WordBool; safecall;
    procedure Set_Smooth(Value: WordBool); safecall;
    function  Get_Step: Integer; safecall;
    procedure Set_Step(Value: Integer); safecall;
    procedure StepBy(Delta: Integer); safecall;
    procedure StepIt; safecall;
  end;

  TwrpScrollBox = class(TwrpScrollingWinControl, IgsScrollBox)
  private
    function  GetScrollBox: TScrollBox;
  protected
    function  Get_BorderStyle: TgsBorderStyle; safecall;
    procedure Set_BorderStyle(Value: TgsBorderStyle); safecall;
  end;

  TwrpShape = class(TwrpGraphicControl, IgsShape)
  private
    function  GetShape: TShape;
  protected
    function  Get_Shape: TgsShapeType; safecall;
    procedure Set_Shape(Value: TgsShapeType); safecall;
    function  Get_Brush: IgsBrush; safecall;
    procedure Set_Brush(const Value: IgsBrush); safecall;
    function  Get_Pen: IgsPen; safecall;
    procedure Set_Pen(const Value: IgsPen); safecall;
    procedure StyleChanged(const Sender: IgsObject); safecall;
  end;

  TwrpSpinButton = class(TwrpWinControl, IgsSpinButton)
  private
    function  GetSpinButton: TSpinButton;
  protected
    function  Get_DownNumGlyphs: Shortint; safecall;
    procedure Set_DownNumGlyphs(Value: Shortint); safecall;
    function  Get_FocusControl: IgsWinControl; safecall;
    procedure Set_FocusControl(const Value: IgsWinControl); safecall;
    function  Get_UpNumGlyphs: Shortint; safecall;
    procedure Set_UpNumGlyphs(Value: Shortint); safecall;
    function  Get_DownGlyph: IgsBitmap; safecall;
    procedure Set_DownGlyph(const Value: IgsBitmap); safecall;
    function  Get_UpGlyph: IgsBitmap; safecall;
    procedure Set_UpGlyph(const Value: IgsBitmap); safecall;
  end;

  TwrpSpinEdit = class(TwrpCustomEdit, IgsSpinEdit)
  private
    function  GetSpinEdit: TSpinEdit;
  protected
    function  Get_Button: IgsSpinButton; safecall;
    function  Get_EditorEnabled: WordBool; safecall;
    procedure Set_EditorEnabled(Value: WordBool); safecall;
    function  Get_Increment: Integer; safecall;
    procedure Set_Increment(Value: Integer); safecall;
    function  Get_MaxValue: Integer; safecall;
    procedure Set_MaxValue(Value: Integer); safecall;
    function  Get_MinValue: Integer; safecall;
    procedure Set_MinValue(Value: Integer); safecall;
    function  Get_Value: Integer; safecall;
    procedure Set_Value(Value: Integer); safecall;
  end;

  TwrpToolBar = class(TwrpToolWindow, IgsToolBar)
  private
    function  GetToolBar: TToolBar;
  protected
    function  Get_ButtonCount: Integer; safecall;
    function  Get_ButtonHeight: Integer; safecall;
    procedure Set_ButtonHeight(Value: Integer); safecall;
    function  Get_ButtonWidth: Integer; safecall;
    procedure Set_ButtonWidth(Value: Integer); safecall;
    function  Get_Canvas: IgsCanvas; safecall;
    function  Get_DisabledImages: IgsCustomImageList; safecall;
    procedure Set_DisabledImages(const Value: IgsCustomImageList); safecall;
    function  Get_Flat: WordBool; safecall;
    procedure Set_Flat(Value: WordBool); safecall;
    function  Get_HotImages: IgsCustomImageList; safecall;
    procedure Set_HotImages(const Value: IgsCustomImageList); safecall;
    function  Get_Images: IgsCustomImageList; safecall;
    procedure Set_Images(const Value: IgsCustomImageList); safecall;
    function  Get_Indent: Integer; safecall;
    procedure Set_Indent(Value: Integer); safecall;
    function  Get_List: WordBool; safecall;
    procedure Set_List(Value: WordBool); safecall;
    function  Get_RowCount: Integer; safecall;
    function  Get_ShowCaptions: WordBool; safecall;
    procedure Set_ShowCaptions(Value: WordBool); safecall;
    function  Get_Transparent: WordBool; safecall;
    procedure Set_Transparent(Value: WordBool); safecall;
    function  Get_Wrapable: WordBool; safecall;
    procedure Set_Wrapable(Value: WordBool); safecall;
    function  TrackMenu(const Button: IgsToolButton): WordBool; safecall;
    function  Get_Buttons(Index: Integer): IgsToolButton; safecall;
  end;

  TwrpTrackBar = class(TwrpWinControl, IgsTrackBar)
  private
    function  GetTrackBar: TTrackBar;
  protected
    function  Get_Frequency: Integer; safecall;
    procedure Set_Frequency(Value: Integer); safecall;
    function  Get_LineSize: Integer; safecall;
    procedure Set_LineSize(Value: Integer); safecall;
    function  Get_Max: Integer; safecall;
    procedure Set_Max(Value: Integer); safecall;
    function  Get_Min: Integer; safecall;
    procedure Set_Min(Value: Integer); safecall;
    function  Get_Orientation: TgsTrackBarOrientation; safecall;
    procedure Set_Orientation(Value: TgsTrackBarOrientation); safecall;
    function  Get_PageSize: Integer; safecall;
    procedure Set_PageSize(Value: Integer); safecall;
    function  Get_SelEnd: Integer; safecall;
    procedure Set_SelEnd(Value: Integer); safecall;
    function  Get_SelStart: Integer; safecall;
    procedure Set_SelStart(Value: Integer); safecall;
    function  Get_SliderVisible: WordBool; safecall;
    procedure Set_SliderVisible(Value: WordBool); safecall;
    function  Get_ThumbLength: Integer; safecall;
    procedure Set_ThumbLength(Value: Integer); safecall;
    function  Get_TickMarks: TgsTickMark; safecall;
    procedure Set_TickMarks(Value: TgsTickMark); safecall;
    function  Get_TickStyle: TgsTickStyle; safecall;
    procedure Set_TickStyle(Value: TgsTickStyle); safecall;
    function  Get_Position: Integer; safecall;
    procedure Set_Position(Value: Integer); safecall;
    procedure SetTick(Value: Integer); safecall;
  end;

  TwrpCustomUpDown = class(TwrpWinControl, IgsCustomUpDown)
  private
    function  GetCustomUpDown: TCustomUpDown;
  protected
    function  Get_AlignButton: TgsUDAlignButton; safecall;
    procedure Set_AlignButton(Value: TgsUDAlignButton); safecall;
    function  Get_ArrowKeys: WordBool; safecall;
    procedure Set_ArrowKeys(Value: WordBool); safecall;
    function  Get_Associate: IgsWinControl; safecall;
    procedure Set_Associate(const Value: IgsWinControl); safecall;
    function  Get_Increment: Integer; safecall;
    procedure Set_Increment(Value: Integer); safecall;
    function  Get_Max: Smallint; safecall;
    procedure Set_Max(Value: Smallint); safecall;
    function  Get_Min: Smallint; safecall;
    procedure Set_Min(Value: Smallint); safecall;
    function  Get_Orientation: TgsUDOrientation; safecall;
    procedure Set_Orientation(Value: TgsUDOrientation); safecall;
    function  Get_Position: Smallint; safecall;
    procedure Set_Position(Value: Smallint); safecall;
    function  Get_Thousands: WordBool; safecall;
    procedure Set_Thousands(Value: WordBool); safecall;
    function  Get_Wrap: WordBool; safecall;
    procedure Set_Wrap(Value: WordBool); safecall;
  end;

  TwrpCommonDialog = class(TwrpComponent, IgsCommonDialog)
  private
    function  GetCommonDialog: TCommonDialog;
  protected
    function  Get_Ctl3D: WordBool; safecall;
    procedure Set_Ctl3D(Value: WordBool); safecall;
    function  Get_Handle: LongWord; safecall;
    function  Get_HelpContext: Integer; safecall;
    procedure Set_HelpContext(Value: Integer); safecall;
  end;

  TwrpOpenDialog = class(TwrpCommonDialog, IgsOpenDialog)
  private
    function  GetOpenDialog: TOpenDialog;
  protected
    function  Execute: WordBool; safecall;
    function  Get_DefaultExt: WideString; safecall;
    procedure Set_DefaultExt(const Value: WideString); safecall;
    function  Get_FileEditStyle: TgsFileEditStyle; safecall;
    procedure Set_FileEditStyle(Value: TgsFileEditStyle); safecall;
    function  Get_FileName: WideString; safecall;
    procedure Set_FileName(const Value: WideString); safecall;
    function  Get_Files: IgsStrings; safecall;
    function  Get_Filter: WideString; safecall;
    procedure Set_Filter(const Value: WideString); safecall;
    function  Get_FilterIndex: Integer; safecall;
    procedure Set_FilterIndex(Value: Integer); safecall;
    function  Get_HistoryList: IgsStrings; safecall;
    procedure Set_HistoryList(const Value: IgsStrings); safecall;
    function  Get_InitialDir: WideString; safecall;
    procedure Set_InitialDir(const Value: WideString); safecall;
    function  Get_Options: WideString; safecall;
    procedure Set_Options(const Value: WideString); safecall;
    function  Get_Title: WideString; safecall;
    procedure Set_Title(const Value: WideString); safecall;
  end;

  TwrpSaveDialog = class(TwrpOpenDialog, IgsSaveDialog)
  end;

  TwrpAggregate = class(TwrpCollectionItem, IgsAggregate)
  private
    function  GetAggregate: TAggregate;
  protected
    function  Get_Active: WordBool; safecall;
    procedure Set_Active(Value: WordBool); safecall;
    function  Get_AggHandle: Integer; safecall;
    procedure Set_AggHandle(Value: Integer); safecall;
    function  Get_AggregateName: WideString; safecall;
    procedure Set_AggregateName(const Value: WideString); safecall;
    function  Get_DataSet: IgsClientDataSet; safecall;
    function  Get_DataSize: Integer; safecall;
    function  Get_DataType: TgsFieldType; safecall;
    function  Get_Expression: WideString; safecall;
    procedure Set_Expression(const Value: WideString); safecall;
    function  Get_GroupingLevel: Integer; safecall;
    procedure Set_GroupingLevel(Value: Integer); safecall;
    function  Get_IndexName: WideString; safecall;
    procedure Set_IndexName(const Value: WideString); safecall;
    function  Get_InUse: WordBool; safecall;
    procedure Set_InUse(Value: WordBool); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function  GetDisplayName: WideString; safecall;
    function  Value: OleVariant; safecall;
  end;

  TwrpAggregates = class(TwrpCollection, IgsAggregates)
  private
    function  GetAggregates: TAggregates;
  protected
    function  Get_Items(Index: Integer): IgsAggregate; safecall;
    procedure Set_Items(Index: Integer; const Value: IgsAggregate); safecall;
    function  Add: IgsAggregate; safecall;
    function  Find(const DisplayName: WideString): IgsAggregate; safecall;
    function  IndexOf(const DisplayName: WideString): Integer; safecall;
  end;

  TwrpPrinter = class(TwrpObject, IgsPrinter)
  private
    function  GetPrinter: TPrinter;
  protected
    function  Get_Aborted: WordBool; safecall;
    function  Get_Canvas: IgsCanvas; safecall;
    function  Get_Capabilities: WideString; safecall;
    function  Get_Copies: Integer; safecall;
    procedure Set_Copies(Value: Integer); safecall;
    function  Get_Fonts: IgsStrings; safecall;
    function  Get_Handle: Integer; safecall;
    function  Get_Orientation: TgsPrinterOrientation; safecall;
    procedure Set_Orientation(Value: TgsPrinterOrientation); safecall;
    function  Get_PageHeight: Integer; safecall;
    function  Get_PageNumber: Integer; safecall;
    function  Get_PageWidth: Integer; safecall;
    function  Get_PrinterIndex: Integer; safecall;
    procedure Set_PrinterIndex(Value: Integer); safecall;
    function  Get_Printers: IgsStrings; safecall;
    function  Get_Printing: WordBool; safecall;
    function  Get_Title: WideString; safecall;
    procedure Set_Title(const Value: WideString); safecall;
    procedure Abort; safecall;
    procedure BeginDoc; safecall;
    procedure EndDoc; safecall;
    procedure NewPage; safecall;
    procedure Refresh; safecall;
  public
    class function CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject; override;
  end;

  TwrpPeriodEdit  = class(TwrpCustomEdit, IgsPeriodEdit)
  private
    function GetPeriodEdit: TgsPeriodEdit;
  protected
    function Get_Date: TDateTime; safecall;
    function Get_EndDate: TDateTime; safecall;
    procedure AssignPeriod(ADate: TDateTime; AnEndDate: TDateTime); safecall;
  end;

implementation

uses
  IBHeader, gdcOLEClassList, ComServ, prp_Methods, obj_VarParam, obj_QueryList,
  OleCtrls, jpeg, TypInfo, JclMime, gsCSV, gd_WebClientControl_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  cTypeStreamExc = 'Тип %d не поддерживается.';

type
  TCrackCustomUpDown = class(TCustomUpDown);
  TCrackCommonCalendar = class(TCommonCalendar);
  TCrackCustomControlBar = class(TCustomControlBar);
  TCrackCustomControl = class(TCustomControl);
  TCrackCustomOutline = class(TCustomOutline);
  TCrackIBDataSetUpdateObject = class(TIBDataSetUpdateObject);
  TCrackCustomLabel = class(TCustomLabel);
  TCrackCustomRichEdit = class(TCustomRichEdit);
  TCrackCustomMemo = class(TCustomMemo);
  TCrackCustomListBox = class(TCustomListBox);
  TCrackCustomMaskEdit = class(TCustomMaskEdit);
  TCrackCustomListView = class(TCustomListView);
  TCrackCustomTreeView = class(TCustomTreeView);
  TCrackCustomGrid = class(TCustomGrid);
  TCrackCustomStaticText = class(TCustomStaticText);
  TCrackSpeedButton = class(TSpeedButton);
  TCrackPageControl = class(TPageControl);
  TCrackCustomTabControl = class(TCustomTabControl);
  TCrackControl = class(TControl);
  TCrackWinControl = class(TWinControl);
  TCrackGraphicControl = class(TGraphicControl);
  TCrackScrollingWinControl = class(TScrollingWinControl);
  TCrackCustomForm = class(TCustomForm);
  TCrackButtonControl = class(TButtonControl);
  TCrackCustomCheckBox = class(TCustomCheckBox);
  TCrackCustomComboBox = class(TCustomComboBox);
  TCrackCustomRadioGroup = class(TCustomRadioGroup);
  TCrackCustomEdit = class(TCustomEdit);
  TCrackDataSet = class(TDataSet);
  TCrackIBCustomDataSet = class(TIBCustomDataSet);
  TCrackIBDataSet = class(TIBDataSet);
  TCrackGraphic = class(TGraphic);
  TCrackGraphicClass = class of TCrackGraphic;

{
function  IgsStringsToTStrings(const AnOleStrings: IgsStrings): TStrings;
begin
  Result := InterfaceToObject(AnOleStrings) as TStrings;
end;
 }
{
function  TStringsToIgsStrings(const AStrings: TStrings): IgsStrings;
begin
  Result := GetGDCOleObject(AStrings) as IgsStrings;
end;
 }
{
function InterfaceToObject(AValue: IDispatch): TObject;
begin
  if AValue <> nil then
  begin
    try
      Result := TObject((AValue as IgsObject).Self);
    except
      raise Exception.Create('Передан некорректный интерфейс');
    end
  end else
    raise Exception.Create('Переданный интерфейс не существует');
end;
 }

function TControlStateToStr(Value: TControlState): String;
begin
  Result := ' ';
  if csLButtonDown in Value then
    Result := Result + 'csLButtonDown ';
  if csClicked in Value then
    Result := Result + 'csClicked ';
  if csPalette in Value then
    Result := Result + 'csPalette ';
  if csReadingState in Value then
    Result := Result + 'csReadingState ';
  if csAlignmentNeeded in Value then
    Result := Result + 'csAlignmentNeeded ';
  if csFocusing in Value then
    Result := Result + 'csFocusing ';
  if csCreating in Value then
    Result := Result + 'csCreating ';
  if csPaintCopy in Value then
    Result := Result + 'csPaintCopy ';
  if csCustomPaint in Value then
    Result := Result + 'csCustomPaint ';
  if csDestroyingHandle in Value then
    Result := Result + 'csDestroyingHandle ';
  if csDocking in Value then
    Result := Result + 'csDocking ';
end;

function StrToTControlState(const Value: String): TControlState;
begin
  Result := [];
  if Pos('CSLBUTTONDOWN', AnsiUpperCase(Value)) > 0 then
    include(Result, csLButtonDown);
  if Pos('CSCLICKED', AnsiUpperCase(Value)) > 0 then
    include(Result, csClicked);
  if Pos('CSPALETTE', AnsiUpperCase(Value)) > 0 then
    include(Result, csPalette);
  if Pos('CSREADINGSTATE', AnsiUpperCase(Value)) > 0 then
    include(Result, csReadingState);
  if Pos('CSALIGNMENTNEEDED', AnsiUpperCase(Value)) > 0 then
    include(Result, csAlignmentNeeded);
  if Pos('CSFOCUSING', AnsiUpperCase(Value)) > 0 then
    include(Result, csFocusing);
  if Pos('CSCREATING', AnsiUpperCase(Value)) > 0 then
    include(Result, csCreating);
  if Pos('CSPAINTCOPY', AnsiUpperCase(Value)) > 0 then
    include(Result, CSPAINTCOPY);
  if Pos('CSCUSTOMPAINT', AnsiUpperCase(Value)) > 0 then
    include(Result, CSCUSTOMPAINT);
  if Pos('CSDESTROYINGHANDLE', AnsiUpperCase(Value)) > 0 then
    include(Result, CSDESTROYINGHANDLE);
  if Pos('CSDOCKING', AnsiUpperCase(Value)) > 0 then
    include(Result, CSDOCKING);
end;

function  TScalingFlagsToStr(Value: TScalingFlags): String;
begin
  Result := ' ';
  if sfLeft in Value then
    Result := Result + 'sfLeft ';
  if sfTop in Value then
    Result := Result + 'sfTop ';
  if sfWidth in Value then
    Result := Result + 'sfWidth ';
  if sfHeight in Value then
    Result := Result + 'sfHeight ';
  if sfFont in Value then
    Result := Result + 'sfFont ';
end;

function  StrToTScalingFlags(Value: String): TScalingFlags;
begin
  Result := [];
  if Pos('SFLEFT', AnsiUpperCase(Value)) > 0 then
    include(Result, SFLEFT);
  if Pos('SFTOP', AnsiUpperCase(Value)) > 0 then
    include(Result, SFTOP);
  if Pos('SFWIDTH', AnsiUpperCase(Value)) > 0 then
    include(Result, SFWIDTH);
  if Pos('SFHEIGHT', AnsiUpperCase(Value)) > 0 then
    include(Result, SFHEIGHT);
  if Pos('SFFONT', AnsiUpperCase(Value)) > 0 then
    include(Result, SFFONT);
end;


function TControlStyleToStr(Value: TControlStyle): String;
begin
  Result := ' ';
  if csAcceptsControls in Value then
    Result := Result + 'csAcceptsControls ';
  if csCaptureMouse in Value then
    Result := Result + 'csCaptureMouse ';
  if csDesignInteractive in Value then
    Result := Result + 'csDesignInteractive ';
  if csClickEvents in Value then
    Result := Result + 'csClickEvents ';
  if csFramed in Value then
    Result := Result + 'csFramed ';
  if csSetCaption in Value then
    Result := Result + 'csSetCaption ';
  if csOpaque in Value then
    Result := Result + 'csOpaque ';
  if csDoubleClicks in Value then
    Result := Result + 'csDoubleClicks ';
  if csFixedWidth in Value then
    Result := Result + 'csFixedWidth ';
  if csFixedHeight in Value then
    Result := Result + 'csFixedHeight ';
  if csNoDesignVisible in Value then
    Result := Result + 'csNoDesignVisible ';
  if csReplicatable in Value then
    Result := Result + 'csReplicatable ';
  if csNoStdEvents in Value then
    Result := Result + 'csNoStdEvents ';
  if csDisplayDragImage in Value then
    Result := Result + 'csDisplayDragImage ';
  if csReflector in Value then
    Result := Result + 'csReflector ';
  if csActionClient in Value then
    Result := Result + 'csActionClient ';
  if csMenuEvents in Value then
    Result := Result + 'csMenuEvents ';
end;

function StrToTControlStyle(Value: String): TControlStyle;
begin
  if Pos('CSACCEPTSCONTROLS', AnsiUpperCase(Value)) > 0 then
    include(Result, CSACCEPTSCONTROLS);
  if Pos('CSCAPTUREMOUSE', AnsiUpperCase(Value)) > 0 then
    include(Result, CSCAPTUREMOUSE);
  if Pos('CSDESIGNINTERACTIVE', AnsiUpperCase(Value)) > 0 then
    include(Result, CSDESIGNINTERACTIVE);
  if Pos('CSCLICKEVENTS', AnsiUpperCase(Value)) > 0 then
    include(Result, CSCLICKEVENTS);
  if Pos('CSFRAMED', AnsiUpperCase(Value)) > 0 then
    include(Result, CSFRAMED);
  if Pos('CSSETCAPTION', AnsiUpperCase(Value)) > 0 then
    include(Result, CSSETCAPTION);
  if Pos('CSOPAQUE', AnsiUpperCase(Value)) > 0 then
    include(Result, CSOPAQUE);
  if Pos('CSDOUBLECLICKS', AnsiUpperCase(Value)) > 0 then
    include(Result, CSDOUBLECLICKS);
  if Pos('CSFIXEDWIDTH', AnsiUpperCase(Value)) > 0 then
    include(Result, CSFIXEDWIDTH);
  if Pos('CSFIXEDHEIGHT', AnsiUpperCase(Value)) > 0 then
    include(Result, CSFIXEDHEIGHT);
  if Pos('CSNODESIGNVISIBLE', AnsiUpperCase(Value)) > 0 then
    include(Result, CSNODESIGNVISIBLE);
  if Pos('CSREPLICATABLE', AnsiUpperCase(Value)) > 0 then
    include(Result, CSREPLICATABLE);
  if Pos('CSNOSTDEVENTS', AnsiUpperCase(Value)) > 0 then
    include(Result, CSNOSTDEVENTS);
  if Pos('CSDISPLAYDRAGIMAGE', AnsiUpperCase(Value)) > 0 then
    include(Result, CSDISPLAYDRAGIMAGE);
  if Pos('CSREFLECTOR', AnsiUpperCase(Value)) > 0 then
    include(Result, CSREFLECTOR);
  if Pos('CSACTIONCLIENT', AnsiUpperCase(Value)) > 0 then
    include(Result, CSACTIONCLIENT);
  if Pos('CSMENUEVENTS', AnsiUpperCase(Value)) > 0 then
    include(Result, CSMENUEVENTS);
end;




function TOpenOptionsToStr(AValue: TOpenOptions): String;
begin
  Result := ' ';
  if ofReadOnly in AValue then
    Result := Result + 'ofReadOnly ';
  if ofOverwritePrompt in AValue then
    Result := Result + 'ofOverwritePrompt ';
  if ofHideReadOnly in AValue then
    Result := Result + 'ofHideReadOnly ';
  if ofNoChangeDir in AValue then
    Result := Result + 'ofNoChangeDir ';
  if ofShowHelp in AValue then
    Result := Result + 'ofShowHelp ';
  if ofNoValidate in AValue then
    Result := Result + 'ofNoValidate ';
  if ofAllowMultiSelect in AValue then
    Result := Result + 'ofAllowMultiSelect ';
  if ofExtensionDifferent in AValue then
    Result := Result + 'ofExtensionDifferent ';
  if ofPathMustExist in AValue then
    Result := Result + 'ofPathMustExist ';
  if ofFileMustExist in AValue then
    Result := Result + 'ofFileMustExist ';
  if ofCreatePrompt in AValue then
    Result := Result + 'ofCreatePrompt ';
  if ofShareAware in AValue then
    Result := Result + 'ofShareAware ';
  if ofNoReadOnlyReturn in AValue then
    Result := Result + 'ofNoReadOnlyReturn ';
  if ofNoTestFileCreate in AValue then
    Result := Result + 'ofNoTestFileCreate ';
  if ofNoNetworkButton in AValue then
    Result := Result + 'ofNoNetworkButton ';
  if ofNoLongNames in AValue then
    Result := Result + 'ofNoLongNames ';
  if ofOldStyleDialog in AValue then
    Result := Result + 'ofOldStyleDialog ';
  if ofNoDereferenceLinks in AValue then
    Result := Result + 'ofNoDereferenceLinks ';
  if ofEnableIncludeNotify in AValue then
    Result := Result + 'ofEnableIncludeNotify ';
  if ofEnableSizing in AValue then
    Result := Result + 'ofEnableSizing ';
end;

function StrToTOpenOptions(AValue: String): TOpenOptions;
begin
  Result := [];
  if Pos('OFREADONLY', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFREADONLY);
  if Pos('OFOVERWRITEPROMPT', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFOVERWRITEPROMPT);
  if Pos('OFHIDEREADONLY', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFHIDEREADONLY);
  if Pos('OFNOCHANGEDIR', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFNOCHANGEDIR);
  if Pos('OFSHOWHELP', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFSHOWHELP);
  if Pos('OFNOVALIDATE', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFNOVALIDATE);
  if Pos('OFALLOWMULTISELECT', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFALLOWMULTISELECT);
  if Pos('OFEXTENSIONDIFFERENT', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFEXTENSIONDIFFERENT);
  if Pos('OFPATHMUSTEXIST', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFPATHMUSTEXIST);
  if Pos('OFFILEMUSTEXIST', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFFILEMUSTEXIST);
  if Pos('OFCREATEPROMPT', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFCREATEPROMPT);
  if Pos('OFSHAREAWARE', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFSHAREAWARE);
  if Pos('OFNOREADONLYRETURN', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFNOREADONLYRETURN);
  if Pos('OFNOTESTFILECREATE', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFNOTESTFILECREATE);
  if Pos('OFNONETWORKBUTTON', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFNONETWORKBUTTON);
  if Pos('OFNOLONGNAMES', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFNOLONGNAMES);
  if Pos('OFOLDSTYLEDIALOG', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFOLDSTYLEDIALOG);
  if Pos('OFNODEREFERENCELINKS', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFNODEREFERENCELINKS);
  if Pos('OFENABLEINCLUDENOTIFY', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFENABLEINCLUDENOTIFY);
  if Pos('OFENABLESIZING', AnsiUpperCase(AValue)) > 0 then
    Include(Result, OFENABLESIZING);
end;

function TButtonSetToStr(AValue: TButtonSet): String;
begin
  Result := ' ';
  if nbFirst in AValue then
    Result := Result + 'nbFirst ';
  if nbPrior in AValue then
    Result := Result + 'nbPrior ';
  if nbNext in AValue then
    Result := Result + 'nbNext ';
  if nbLast in AValue then
    Result := Result + 'nbLast ';
  if nbInsert in AValue then
    Result := Result + 'nbInsert ';
  if nbDelete in AValue then
    Result := Result + 'nbDelete ';
  if nbEdit in AValue then
    Result := Result + 'nbEdit ';
  if nbPost in AValue then
    Result := Result + 'nbPost ';
  if nbCancel in AValue then
    Result := Result + 'nbCancel ';
  if nbRefresh in AValue then
    Result := Result + 'nbRefresh ';
end;

function StrToTButtonSet(AValue: String): TButtonSet;
begin
  Result := [];
  if Pos('NBFIRST', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbFirst);
  if Pos('NBPRIOR', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbPrior);
  if Pos('NBNEXT', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbNext);
  if Pos('NBLAST', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbLast);
  if Pos('NBINSERT', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbInsert);
  if Pos('NBDELETE', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbDelete);
  if Pos('NBEDIT', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbEdit);
  if Pos('NBPOST', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbPost);
  if Pos('NBCANCEL', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbCancel);
  if Pos('NBREFRESH', AnsiUpperCase(AValue)) > 0 then
    Include(Result, nbRefresh);
end;

function GetStrFromFieldType(const AnFieldType: TFieldType): String;
begin
  Result := GetEnumName(TypeInfo(TFieldType), Integer(AnFieldType));
end;

function VarArrayToPointArray(AVar: OleVariant; out ARes: TPointArray): boolean;
var
  i: integer;
begin
  if VariantIsArray(AVar) then begin
    try
      SetLength(ARes, VarArrayHighBound(AVar, 1) + 1);
      for i:= VarArrayLowBound(AVar, 1) to VarArrayHighBound(AVar, 1) do begin
        ARes[i].X:= AVar[i, 0];
        ARes[i].Y:= AVar[i, 1];
      end;
      Result:= True;
    except
      Result:= False;
    end;
  end
  else begin
    Result:= False;
  end;
  if not Result then
    raise Exception.Create('Входящим параметром должен быть двумерный массив целых чисел: ((X1, Y1), (X2, Y2), (X3, Y3), ..., (Xn, Yn))');
end;

{ TwrpDataSet }

procedure TwrpDataSet.Close;
begin
  GetDataSet.Close;
end;

procedure TwrpDataSet.Delete;
begin
  GetDataSet.Delete;
end;

procedure TwrpDataSet.Edit;
begin
  GetDataSet.Edit;
end;

procedure TwrpDataSet.First;
begin
  GetDataSet.First;
end;

function TwrpDataSet.Get_Active: WordBool;
begin
  Result := GetDataSet.Active;
end;

function TwrpDataSet.GetDataSet: TDataSet;
begin
  Result := GetObject as TDataSet;
end;

procedure TwrpDataSet.Last;
begin
  GetDataSet.Last;
end;

procedure TwrpDataSet.Next;
begin
  GetDataSet.Next;
end;

procedure TwrpDataSet.Open;
begin
  GetDataSet.Open;
end;

procedure TwrpDataSet.Post;
begin
  GetDataSet.Post;
end;

procedure TwrpDataSet.Prior;
begin
  GetDataSet.Prior;
end;

procedure TwrpDataSet.Set_Active(Value: WordBool);
begin
  GetDataSet.Active := Value;
end;

function TwrpDataSet.FieldByName(const FieldName: WideString): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetDataSet.FieldByName(FieldName)) as IgsFieldComponent;
end;

function TwrpDataSet.Get_Bof: WordBool;
begin
  Result :=  GetDataSet.Bof;
end;

function TwrpDataSet.Get_Eof: WordBool;
begin
  Result := GetDataSet.Eof;
end;

function TwrpDataSet.Get_State: TgsDataSetState;
begin
  Result := TgsDataSetState(GetDataSet.State);
end;

procedure TwrpDataSet.Append;
begin
  GetDataSet.Append;
end;

procedure TwrpDataSet.Insert;
begin
  GetDataSet.Insert;
end;

procedure TwrpDataSet.Cancel;
begin
  GetDataSet.Cancel;
end;

procedure TwrpDataSet.CheckBrowseMode;
begin
  GetDataSet.CheckBrowseMode;
end;

procedure TwrpDataSet.ClearFields;
begin
  GetDataSet.ClearFields;
end;

function TwrpDataSet.ControlsDisabled: WordBool;
begin
  Result := GetDataSet.ControlsDisabled;
end;

procedure TwrpDataSet.CursorPosChanged;
begin
  GetDataSet.CursorPosChanged;
end;

procedure TwrpDataSet.DisableControls;
begin
  GetDataSet.DisableControls;
end;

procedure TwrpDataSet.EnableControls;
begin
  GetDataSet.EnableControls;
end;

function TwrpDataSet.FindField(const FieldName: WideString): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetDataSet.FindField(FieldName)) as IgsFieldComponent;
end;

function TwrpDataSet.FindFirst: WordBool;
begin
  Result := GetDataSet.FindFirst;
end;

function TwrpDataSet.FindLast: WordBool;
begin
  Result := GetDataSet.FindLast;
end;

function TwrpDataSet.FindNext: WordBool;
begin
  Result := GetDataSet.FindNext;
end;

function TwrpDataSet.FindPrior: WordBool;
begin
  Result := GetDataSet.FindPrior;
end;

function TwrpDataSet.IsEmpty: WordBool;
begin
  Result := GetDataSet.IsEmpty;
end;

function TwrpDataSet.IsLinkedTo(const DataSource: IgsDataSource): WordBool;
begin
  Result := GetDataSet.IsLinkedTo(InterfaceToObject(DataSource) as TDataSource);
end;

function TwrpDataSet.IsSequenced: WordBool;
begin
  Result := GetDataSet.IsSequenced;
end;

procedure TwrpDataSet.Refresh;
begin
  GetDataSet.Refresh;
end;

procedure TwrpDataSet.UpdateCursorPos;
begin
  GetDataSet.UpdateCursorPos;
end;

procedure TwrpDataSet.UpdateRecord;
begin
  GetDataSet.UpdateRecord;
end;

function TwrpDataSet.Get_ActiveRecord: Integer;
begin
  Result := TCrackDataSet(GetDataSet).ActiveRecord;
end;

function TwrpDataSet.Get_AggFields: IgsFields;
begin
  Result := GetGdcOLEObject(GetDataSet.AggFields) as IgsFields;
end;

function TwrpDataSet.Get_AutoCalcFields: WordBool;
begin
  Result := GetDataSet.AutoCalcFields;
end;

function TwrpDataSet.Get_BlobFieldCount: Integer;
begin
  Result := TCrackDataSet(GetDataSet).BlobFieldCount;
end;

function TwrpDataSet.Get_BlockReadSize: Integer;
begin
  Result := GetDataSet.BlockReadSize;
end;

function TwrpDataSet.Get_Bookmark: WideString;
begin
  Result := GetDataSet.Bookmark;
end;

function TwrpDataSet.Get_BookmarkSize: Integer;
begin
  Result := TCrackDataSet(GetDataSet).BookmarkSize;
end;

function TwrpDataSet.Get_BufferCount: Integer;
begin
  Result := TCrackDataSet(GetDataSet).BufferCount;
end;

function TwrpDataSet.Get_CalcFieldsSize: Integer;
begin
  Result := TCrackDataSet(GetDataSet).CalcFieldsSize;
end;

function TwrpDataSet.Get_CanModify: WordBool;
begin
  Result := GetDataSet.CanModify;
end;

function TwrpDataSet.Get_CurrentRecord: Integer;
begin
  Result := TCrackDataSet(GetDataSet).CurrentRecord;
end;

function TwrpDataSet.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetDataSet.DataSource) as IgsDataSource;
end;

function TwrpDataSet.Get_DefaultFields: WordBool;
begin
  Result := GetDataSet.DefaultFields;
end;

function TwrpDataSet.Get_FieldCount: Integer;
begin
  Result := GetDataSet.FieldCount;
end;

function TwrpDataSet.Get_FieldNoOfs: Integer;
begin
  Result := TCrackDataSet(GetDataSet).FieldNoOfs;
end;

function TwrpDataSet.Get_Fields: IgsFields;
begin
  Result := GetGdcOLEObject(GetDataSet.Fields) as IgsFields;
end;

function TwrpDataSet.Get_FieldValues(
  const FieldName: WideString): OleVariant;
begin
  Result := GetDataSet.FieldValues[FieldName];
end;

function TwrpDataSet.Get_Filter: WideString;
begin
  Result := GetDataSet.Filter;
end;

function TwrpDataSet.Get_Filtered: WordBool;
begin
  Result := GetDataSet.Filtered;
end;

function TwrpDataSet.Get_Found: WordBool;
begin
  Result := GetDataSet.Found;
end;

function TwrpDataSet.Get_InternalCalcFields: WordBool;
begin
  Result := TCrackDataSet(GetDataSet).InternalCalcFields;
end;

function TwrpDataSet.Get_Modified: WordBool;
begin
  Result := GetDataSet.Modified;
end;

function TwrpDataSet.Get_NestedDataSets: IgsList;
begin
  Result := GetGdcOLEObject(TCrackDataSet(GetDataSet).NestedDataSets) as IgsList;
end;

function TwrpDataSet.Get_ObjectView: WordBool;
begin
  Result := GetDataSet.ObjectView;
end;

function TwrpDataSet.Get_RecNo: Integer;
begin
  Result := GetDataSet.RecNo;
end;

function TwrpDataSet.Get_RecordCount: Integer;
begin
  Result := GetDataSet.RecordCount;
end;

function TwrpDataSet.Get_RecordSize: Integer;
begin
  Result := GetDataSet.RecordSize;
end;

function TwrpDataSet.Get_SparseArrays: WordBool;
begin
  Result := GetDataSet.SparseArrays;
end;

procedure TwrpDataSet.Set_AutoCalcFields(Value: WordBool);
begin
  GetDataSet.AutoCalcFields := Value;
end;

procedure TwrpDataSet.Set_BlockReadSize(Value: Integer);
begin
  GetDataSet.BlockReadSize := Value;
end;

procedure TwrpDataSet.Set_Bookmark(const Value: WideString);
begin
  GetDataSet.Bookmark := Value;
end;

procedure TwrpDataSet.Set_BookmarkSize(Value: Integer);
begin
  TCrackDataSet(GetDataSet).BookmarkSize := Value;
end;

procedure TwrpDataSet.Set_FieldNoOfs(Value: Integer);
begin
  TCrackDataSet(GetDataSet).FieldNoOfs := Value;
end;

procedure TwrpDataSet.Set_FieldValues(const FieldName: WideString;
  Value: OleVariant);
begin
  GetDataSet.FieldValues[FieldName] := Value;
end;

procedure TwrpDataSet.Set_Filter(const Value: WideString);
begin
  GetDataSet.Filter := Value;
end;

procedure TwrpDataSet.Set_Filtered(Value: WordBool);
begin
  GetDataSet.Filtered := Value;
end;

procedure TwrpDataSet.Set_ObjectView(Value: WordBool);
begin
  GetDataSet.ObjectView := Value;
end;

procedure TwrpDataSet.Set_RecNo(Value: Integer);
begin
  GetDataSet.RecNo := Value;
end;

procedure TwrpDataSet.GetDetailDataSets(const List: IgsList);
begin
  GetDataSet.GetDetailDataSets(InterfaceToObject(List) as TList);
end;

procedure TwrpDataSet.GetDetailLinkFields(const MasterFields,
  DetailFields: IgsList);
begin
  GetDataSet.GetDetailLinkFields(InterfaceToObject(MasterFields) as TList,
    InterfaceToObject(DetailFields) as TList);
end;

procedure TwrpDataSet.GetFieldList(const List: IgsList;
  const FieldName: WideString);
begin
  GetDataSet.GetFieldList(InterfaceToObject(List) as TList, FieldName);
end;

function TwrpDataSet.Lookup(const KeyFields: WideString;
  KeyValues: OleVariant; const ResultFields: WideString): OleVariant;
begin
  Result := GetDataSet.Lookup(KeyFields, KeyValues, ResultFields);
end;

function TwrpDataSet.MoveBy(Distance: Integer): Integer;
begin
  Result := GetDataSet.MoveBy(Distance);
end;

function TwrpDataSet.UpdateStatus: TgsUpdateStatus;
begin
  Result := TgsUpdateStatus(GetDataSet.UpdateStatus);
end;

function TwrpDataSet.Get_DataSetField: IgsDataSetField;
begin
  Result := GetGdcOLEObject(GetDataSet.DataSetField) as IgsDataSetField;
end;

procedure TwrpDataSet.Set_DataSetField(const Value: IgsDataSetField);
begin
  GetDataSet.DataSetField := InterfaceToObject(Value) as TDataSetField;
end;

function TwrpDataSet.Get_FieldDefList: IgsFieldDefList;
begin
  Result := GetGdcOLEObject(GetDataSet.FieldDefList) as IgsFieldDefList;
end;

function TwrpDataSet.Get_FieldDefs: IgsFieldDefs;
begin
  Result := GetGdcOLEObject(GetDataSet.FieldDefs) as IgsFieldDefs;
end;

procedure TwrpDataSet.Set_FieldDefs(const Value: IgsFieldDefs);
begin
  GetDataSet.FieldDefs := InterfaceToObject(Value) as TFieldDefs;
end;

function TwrpDataSet.Get_FieldList: IgsFieldList;
begin
  Result := GetGdcOLEObject(GetDataSet.FieldList) as IgsFieldList;
end;

function TwrpDataSet.Get_FilterOptions: WideString;
begin
  Result := ' ';
  if foCaseInsensitive in GetDataSet.FilterOptions then
    Result := Result + 'foCaseInsensitive ';
  if foNoPartialCompare in GetDataSet.FilterOptions then
    Result := Result + 'foNoPartialCompare ';
end;

procedure TwrpDataSet.Set_FilterOptions(const Value: WideString);
var
  LFilterOptions: TFilterOptions;
begin
  LFilterOptions := [];
  if Pos('CASEINSENSITIVE', AnsiUpperCase(Value)) > 0 then
    include(LFilterOptions, DB.FOCASEINSENSITIVE);
  if Pos('NOPARTIALCOMPARE', AnsiUpperCase(Value)) > 0 then
    include(LFilterOptions, DB.FONOPARTIALCOMPARE);
  GetDataSet.FilterOptions := LFilterOptions;

end;

procedure TwrpDataSet.GetFieldNames(const List: IgsStrings);
begin
  GetDataSet.GetFieldNames(IgsStringsToTStrings(List));
end;

function TwrpDataSet.BookmarkValid(Bookmark: Integer): WordBool;
begin
  Result := GetDataSet.BookmarkValid(Pointer(Bookmark));
end;

function TwrpDataSet.CompareBookmarks(Bookmark1,
  Bookmark2: Integer): Integer;
begin
  Result := GetDataSet.CompareBookmarks(Pointer(Bookmark1), Pointer(Bookmark2));
end;

function TwrpDataSet.CreateBlobStream(const Field: IgsFieldComponent;
  Mode: TgsBlobStreamMode): IgsStream;
begin
  Result := GetGdcOLEObject(GetDataSet.CreateBlobStream(interfaceToObject(Field) as
    TField, TBlobStreamMode(Mode))) as IgsStream;
end;

procedure TwrpDataSet.FreeBookmark(Bookmark: Integer);
begin
//  Assert(SizeOf(Pointer) <> SizeOf(Integer), 'Размерности типов Pointer и Integer не равны');
  GetDataSet.FreeBookmark(Pointer(Bookmark));
end;

function TwrpDataSet.GetBookmark: Integer;
begin
  Result := Integer(GetDataSet.GetBookmark);
end;

procedure TwrpDataSet.GotoBookmark(Bookmark: Integer);
begin
  GetDataSet.GotoBookmark(Pointer(Bookmark))
end;

function TwrpDataSet.Locate(const KeyFields: WideString;
  KeyValues: OleVariant; const Options: WideString): WordBool;
var
  LO: TLocateOptions;
begin
  LO := [];
  if Pos('CASEINSENSITIVE', AnsiUpperCase(Options)) > 0 then
    include(LO, loCaseInsensitive);
  if Pos('PARTIALKEY', AnsiUpperCase(Options)) > 0 then
    include(LO, loPartialKey);
  Result := GetDataSet.Locate(KeyFields, KeyValues, LO)
end;

procedure TwrpDataSet.Resync(const Mode: WideString);
var
  RM: TResyncMode;
begin
  RM := [];
  if Pos('EXACT', AnsiUpperCase(Mode)) > 0 then
    include(RM, rmExact);
  if Pos('CENTER', AnsiUpperCase(Mode)) > 0 then
    include(RM, rmCenter);

  GetDataSet.Resync(RM);
end;

function TwrpDataSet.Get_RealDataSet: TDataSet;
begin
  Result := GetObject as TDataSet;
end;

{ TwrpIBCustomDataSet }

function TwrpIBCustomDataSet.Get_ForcedRefresh: WordBool;
begin
  Result := GetIBCustomDataSet.ForcedRefresh;
end;

function TwrpIBCustomDataSet.GetIBCustomDataSet: TIBCustomDataSet;
begin
  Result := GetObject as TIBCustomDataSet;
end;

procedure TwrpIBCustomDataSet.Set_ForcedRefresh(Value: WordBool);
begin
  GetIBCustomDataSet.ForcedRefresh := Value;
end;

procedure TwrpIBCustomDataSet.Undelete;
begin
  GetIBCustomDataSet.Undelete;
end;

procedure TwrpIBCustomDataSet.ApplyUpdates;
begin
  GetIBCustomDataSet.ApplyUpdates;
end;

function TwrpIBCustomDataSet.CachedUpdateStatus: TgsCachedUpdateStatus;
begin
  Result := TgsCachedUpdateStatus(GetIBCustomDataSet.CachedUpdateStatus);
end;

procedure TwrpIBCustomDataSet.CancelUpdates;
begin
  GetIBCustomDataSet.CancelUpdates;
end;

function TwrpIBCustomDataSet.Current: IgsIBXSQLDA;
begin
  Result := GetGdcOLEObject(GetIBCustomDataSet.Current) as IgsIBXSQLDA;
end;

procedure TwrpIBCustomDataSet.FetchAll;
begin
  GetIBCustomDataSet.FetchAll;
end;

function TwrpIBCustomDataSet.Get_BufferChunks: Integer;
begin
  Result := TCrackIBCustomDataSet(GetIBCustomDataSet).BufferChunks;
end;

function TwrpIBCustomDataSet.Get_CachedUpdates: WordBool;
begin
  Result := TCrackIBCustomDataSet(GetIBCustomDataSet).CachedUpdates;
end;

function TwrpIBCustomDataSet.Get_DeleteSQL: IgsStrings;
begin
  Result := TStringsToIGSStrings(TCrackIBCustomDataSet(GetIBCustomDataSet).DeleteSQL);
end;

function TwrpIBCustomDataSet.Get_InsertSQL: IgsStrings;
begin
  Result := TStringsToIGSStrings(TCrackIBCustomDataSet(GetIBCustomDataSet).InsertSQL);
end;

function TwrpIBCustomDataSet.Get_InternalPrepared: WordBool;
begin
  Result := TCrackIBCustomDataSet(GetIBCustomDataSet).InternalPrepared;
end;

function TwrpIBCustomDataSet.Get_ModifySQL: IgsStrings;
begin
  Result := TStringsToIGSStrings(TCrackIBCustomDataSet(GetIBCustomDataSet).ModifySQL);
end;

function TwrpIBCustomDataSet.Get_ParamCheck: WordBool;
begin
  Result := TCrackIBCustomDataSet(GetIBCustomDataSet).ParamCheck;
end;

function TwrpIBCustomDataSet.Get_Params: IgsIBXSQLDA;
begin
  Result := GetGdcOLEObject(TCrackIBCustomDataSet(GetIBCustomDataSet).Params) as IgsIBXSQLDA;
end;

function TwrpIBCustomDataSet.Get_Plan: WideString;
begin
  Result := GetIBCustomDataSet.Plan;
end;

function TwrpIBCustomDataSet.Get_RefreshSQL: IgsStrings;
begin
  Result := TStringsToIGSStrings(TCrackIBCustomDataSet(GetIBCustomDataSet).RefreshSQL);
end;

function TwrpIBCustomDataSet.Get_RowsAffected: Integer;
begin
  Result := GetIBCustomDataSet.RowsAffected;
end;

function TwrpIBCustomDataSet.Get_SelectSQL: IgsStrings;
begin
  Result :=  TStringsToIGSStrings(TCrackIBCustomDataSet(GetIBCustomDataSet).SelectSQL);
end;

function TwrpIBCustomDataSet.Get_SQLParams: IgsIBXSQLDA;
begin
  Result := GetGdcOLEObject(TCrackIBCustomDataSet(GetIBCustomDataSet).SQLParams)
    as IgsIBXSQLDA;
end;

function TwrpIBCustomDataSet.Get_Transaction: IgsIBTransaction;
begin
  Result :=  GetGdcOLEObject(GetIBCustomDataSet.Transaction) as IgsIBTransaction;
end;

function TwrpIBCustomDataSet.Get_UniDirectional: WordBool;
begin
  Result := TCrackIBCustomDataSet(GetIBCustomDataSet).UniDirectional;
end;

function TwrpIBCustomDataSet.Get_UpdateMode: TgsUpdateMode;
begin
  Result := TgsUpdateMode(TCrackIBCustomDataSet(GetIBCustomDataSet).UpdateMode)
end;

function TwrpIBCustomDataSet.Get_UpdatesPending: WordBool;
begin
  Result := GetIBCustomDataSet.UpdatesPending;
end;

procedure TwrpIBCustomDataSet.RecordModified(Value: WordBool);
begin
  GetIBCustomDataSet.RecordModified(Value);
end;

procedure TwrpIBCustomDataSet.RevertRecord;
begin
  GetIBCustomDataSet.RevertRecord;
end;

procedure TwrpIBCustomDataSet.Set_BufferChunks(Value: Integer);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).BufferChunks := Value;
end;

procedure TwrpIBCustomDataSet.Set_CachedUpdates(Value: WordBool);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).CachedUpdates := Value;
end;

procedure TwrpIBCustomDataSet.Set_DeleteSQL(const Value: IgsStrings);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).DeleteSQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBCustomDataSet.Set_InsertSQL(const Value: IgsStrings);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).InsertSQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBCustomDataSet.Set_ModifySQL(const Value: IgsStrings);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).ModifySQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBCustomDataSet.Set_ParamCheck(Value: WordBool);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).ParamCheck := Value;
end;

procedure TwrpIBCustomDataSet.Set_RefreshSQL(const Value: IgsStrings);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).RefreshSQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBCustomDataSet.Set_SelectSQL(const Value: IgsStrings);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).SelectSQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBCustomDataSet.Set_Transaction(const Value: IgsIBTransaction);
begin
  GetIBCustomDataSet.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

procedure TwrpIBCustomDataSet.Set_UniDirectional(Value: WordBool);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).UniDirectional := Value;
end;

procedure TwrpIBCustomDataSet.Set_UpdateMode(Value: TgsUpdateMode);
begin
  TCrackIBCustomDataSet(GetIBCustomDataSet).UpdateMode := TUpdateMode(Value);
end;

function TwrpIBCustomDataSet.Get_Database: IgsIBDatabase;
begin
  Result :=  GetGdcOLEObject(GetIBCustomDataSet.Database) as IgsIBDatabase;
end;

procedure TwrpIBCustomDataSet.Set_Database(const Value: IgsIBDatabase);
begin
  GetIBCustomDataSet.Database := InterfaceToObject(Value) as TIBDatabase;
end;

function TwrpIBCustomDataSet.Get_ReadTransaction: IgsIBTransaction;
begin
  Result := GetGDCOleObject(GetIBCustomDataSet.ReadTransaction) as IgsIBTransaction;
end;

procedure TwrpIBCustomDataSet.Set_ReadTransaction(
  const Value: IgsIBTransaction);
begin
  GetIBCustomDataSet.ReadTransaction := InterfaceToObject(Value) as TIBTransaction;
end;

function TwrpIBCustomDataSet.Get_AggregatesObsolete: WordBool;
begin
  Result := GetIBCustomDataSet.AggregatesObsolete;  
end;

function TwrpIBCustomDataSet.Get_CacheSize: Integer;
begin
  Result := GetIBCustomDataSet.CacheSize;
end;

function TwrpIBCustomDataSet.Get_OpenCounter: Integer;
begin
  Result := GetIBCustomDataSet.OpenCounter;
end;

function TwrpIBCustomDataSet.Get_UpdateObject: IgsIBDataSetUpdateObject;
begin
  Result := GetGdcOLEObject(GetIBCustomDataSet.UpdateObject) as IgsIBDataSetUpdateObject;
end;

function TwrpIBCustomDataSet.Get_UpdateRecordTypes: WideString;
begin
  Result := ' ';
  if cusUnmodified in GetIBCustomDataSet.UpdateRecordTypes then
    Result := 'cusUnmodified ';
  if cusModified in GetIBCustomDataSet.UpdateRecordTypes then
    Result := 'cusModified ';
  if cusInserted in GetIBCustomDataSet.UpdateRecordTypes then
    Result := 'cusInserted ';
  if cusDeleted in GetIBCustomDataSet.UpdateRecordTypes then
    Result := 'cusDeleted ';
  if cusUninserted in GetIBCustomDataSet.UpdateRecordTypes then
    Result := 'cusUninserted ';
end;

procedure TwrpIBCustomDataSet.Set_UpdateObject(
  const Value: IgsIBDataSetUpdateObject);
begin
  GetIBCustomDataSet.UpdateObject := InterfaceToObject(Value) as TIBDataSetUpdateObject;
end;

procedure TwrpIBCustomDataSet.Set_UpdateRecordTypes(
  const Value: WideString);
var
  LIBUpdateRecordTypes: TIBUpdateRecordTypes;
begin
  LIBUpdateRecordTypes := [];
  if Pos('CUSUNMODIFIED', Value) > 0 then
    Include(LIBUpdateRecordTypes, CUSUNMODIFIED);
  if Pos('CUSMODIFIED', Value) > 0 then
    Include(LIBUpdateRecordTypes, CUSMODIFIED);
  if Pos('CUSINSERTED', Value) > 0 then
    Include(LIBUpdateRecordTypes, CUSINSERTED);
  if Pos('CUSDELETED', Value) > 0 then
    Include(LIBUpdateRecordTypes, CUSDELETED);
  if Pos('CUSUNINSERTED', Value) > 0 then
    Include(LIBUpdateRecordTypes, CUSUNINSERTED);
  GetIBCustomDataSet.UpdateRecordTypes := LIBUpdateRecordTypes;
end;

procedure TwrpIBCustomDataSet.Sort(const F: IgsFieldComponent;
  Ascending: WordBool);
begin
  GetIBCustomDataSet.Sort(InterfaceToObject(F) as TField, Ascending);
end;

function TwrpIBCustomDataSet.SQLType: TgsIBSQLTypes;
begin
  Result := TgsIBSQLTypes(GetIBCustomDataSet.SQLType);
end;

{ TwrpControl }

function TwrpControl.Get_Enabled: WordBool;
begin
  Result := GetControl.Enabled;
end;

function TwrpControl.Get_Height: Integer;
begin
  Result := GetControl.Height;
end;

function TwrpControl.Get_Hint: WideString;
begin
  Result := GetControl.Hint;
end;

function TwrpControl.Get_Left: Integer;
begin
  Result := GetControl.Left;
end;

function TwrpControl.Get_Top: Integer;
begin
  Result := GetControl.Top;
end;

function TwrpControl.Get_Visible: WordBool;
begin
  Result := GetControl.Visible;
end;

function TwrpControl.Get_Width: Integer;
begin
  Result := GetControl.Width;
end;

function TwrpControl.GetControl: TControl;
begin
  Result := GetObject as TControl;
end;

function TwrpControl.HasParent;
begin
  Result := GetControl.HasParent;
end;

procedure TwrpControl.Refresh;
begin
  GetControl.Refresh;
end;

procedure TwrpControl.Repaint;
begin
  GetControl.Repaint;
end;

procedure TwrpControl.Set_Enabled(Value: WordBool);
begin
  GetControl.Enabled := Value;
end;

procedure TwrpControl.Set_Height(Value: Integer);
begin
  GetControl.Height := Value;
end;

procedure TwrpControl.Set_Hint(const Value: WideString);
begin
  GetControl.Hint := Value;
end;

procedure TwrpControl.Set_Left(Value: Integer);
begin
  GetControl.Left := Value;
end;

procedure TwrpControl.Set_Top(Value: Integer);
begin
  GetControl.Top := Value;
end;

procedure TwrpControl.Set_Visible(Value: WordBool);
begin
  GetControl.Visible := Value;
end;

procedure TwrpControl.Set_Width(Value: Integer);
begin
  GetControl.Width := Value;
end;

procedure TwrpControl.InitiateAction;
begin
  GetControl.InitiateAction;
end;

procedure TwrpControl.BringToFront;
begin
  GetControl.BringToFront;
end;

function TwrpControl.DrawTextBiDiModeFlags(Flags: Integer): Integer;
begin
  Result := GetControl.DrawTextBiDiModeFlags(Flags);
end;

function TwrpControl.DrawTextBiDiModeFlagsReadingOnly: Integer;
begin
  Result := GetControl.DrawTextBiDiModeFlagsReadingOnly;
end;

procedure TwrpControl.EndDrag(Drop: WordBool);
begin
  GetControl.EndDrag(Drop);
end;

function TwrpControl.Get_Align: TgsAlign;
begin
  Result := TgsAlign(GetControl.Align);
end;

function TwrpControl.Get_BiDiMode: TgsBiDiMode;
begin
  Result := TgsBiDiMode(GetControl.BiDiMode);
end;

function TwrpControl.Get_ClientHeight: Integer;
begin
  Result := GetControl.ClientHeight;
end;

function TwrpControl.Get_ClientWidth: Integer;
begin
  Result := GetControl.ClientWidth;
end;

function TwrpControl.Get_Cursor: Smallint;
begin
  Result := TCursor(GetControl.Cursor);
end;

function TwrpControl.Get_DockOrientation: TgsDockOrientation;
begin
  Result := TgsDockOrientation(GetControl.DockOrientation);
end;

function TwrpControl.Get_LRDockWidth: Integer;
begin
  Result := GetControl.LRDockWidth;
end;

function TwrpControl.Get_ShowHint: WordBool;
begin
  Result := GetControl.ShowHint;
end;

function TwrpControl.Get_TBDockHeight: Integer;
begin
  Result := GetControl.TBDockHeight;
end;

function TwrpControl.Get_UndockHeight: Integer;
begin
  Result := GetControl.UndockHeight;
end;

function TwrpControl.Get_UndockWidth: Integer;
begin
  Result := GetControl.UndockWidth;
end;

function TwrpControl.IsRightToLeft: WordBool;
begin
  Result := GetControl.IsRightToLeft;
end;

procedure TwrpControl.SendToBack;
begin
  GetControl.SendToBack
end;

procedure TwrpControl.Set_Align(Value: TgsAlign);
begin
  GetControl.Align := TAlign(Value);
end;

procedure TwrpControl.Set_BiDiMode(Value: TgsBiDiMode);
begin
  GetControl.BiDiMode := TBiDiMode(Value);
end;

procedure TwrpControl.Set_ClientHeight(Value: Integer);
begin
  GetControl.ClientHeight := Value;
end;

procedure TwrpControl.Set_ClientWidth(Value: Integer);
begin
  GetControl.ClientWidth := Value;
end;

procedure TwrpControl.Set_Cursor(Value: Smallint);
begin
  GetControl.Cursor := TCursor(Value);
end;

procedure TwrpControl.Set_DockOrientation(Value: TgsDockOrientation);
begin
  GetControl.DockOrientation := TDockOrientation(Value);
end;

procedure TwrpControl.Set_LRDockWidth(Value: Integer);
begin
  GetControl.LRDockWidth := Value;
end;

procedure TwrpControl.Set_ShowHint(Value: WordBool);
begin
  GetControl.ShowHint := Value;
end;

procedure TwrpControl.Set_TBDockHeight(Value: Integer);
begin
  GetControl.TBDockHeight := Value;
end;

procedure TwrpControl.Set_UndockHeight(Value: Integer);
begin
  GetControl.UndockHeight := Value;
end;

procedure TwrpControl.Set_UndockWidth(Value: Integer);
begin
  GetControl.UndockWidth := Value;
end;

procedure TwrpControl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  GetControl.SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TwrpControl.Show;
begin
  GetControl.Show;
end;

procedure TwrpControl.Update;
begin
  GetControl.Update;
end;

function TwrpControl.UseRightToLeftAlignment: WordBool;
begin
  Result := GetControl.UseRightToLeftAlignment;
end;

function TwrpControl.UseRightToLeftReading: WordBool;
begin
  Result := GetControl.UseRightToLeftReading;
end;

function TwrpControl.UseRightToLeftScrollBar: WordBool;
begin
  Result := GetControl.UseRightToLeftScrollBar;
end;

function TwrpControl.Get_Action: IgsBasicAction;
begin
  Result := GetGdcOLEObject(GetControl.Action) as IgsBasicAction;
end;

procedure TwrpControl.Set_Action(const Value: IgsBasicAction);
begin
  if InterfaceToObject(Value) is TBasicAction then
    GetControl.Action := TBasicAction(InterfaceToObject(Value));

end;

function TwrpControl.Get_Caption: WideString;
begin
  Result := TCrackControl(GetControl).Caption;
end;

procedure TwrpControl.Set_Caption(const Value: WideString);
begin
  TCrackControl(GetControl).Caption := TCaption(Value);
end;

function TwrpControl.Get_Color: Integer;
begin
  Result := Integer(TCrackControl(GetControl).Color);
end;

procedure TwrpControl.Set_Color(Value: Integer);
begin
  TCrackControl(GetControl).Color := TColor(Value);
end;

function TwrpControl.Get_AutoSize: WordBool;
begin
  Result := TCrackControl(GetControl).AutoSize;
end;

procedure TwrpControl.Set_AutoSize(Value: WordBool);
begin
  TCrackControl(GetControl).AutoSize := Value;
end;

function TwrpControl.Get_DesktopFont: WordBool;
begin
  Result := TCrackControl(GetControl).DesktopFont;
end;

procedure TwrpControl.Set_DesktopFont(Value: WordBool);
begin
  TCrackControl(GetControl).DesktopFont := Value;
end;

function TwrpControl.Get_DragCursor: Smallint;
begin
  Result := TCrackControl(GetControl).DragCursor;
end;

procedure TwrpControl.Set_DragCursor(Value: Smallint);
begin
  TCrackControl(GetControl).DragCursor := TCursor(Value);
end;

function TwrpControl.Get_DragKind: TgsDragKind;
begin
  Result := TgsDragKind(TCrackControl(GetControl).DragKind);
end;

function TwrpControl.Get_DragMode: TgsDragMode;
begin
  Result := TgsDragMode(TCrackControl(GetControl).DragMode);
end;

procedure TwrpControl.Set_DragKind(Value: TgsDragKind);
begin
  TCrackControl(GetControl).DragKind := TDragKind(Value);
end;

procedure TwrpControl.Set_DragMode(Value: TgsDragMode);
begin
  TCrackControl(GetControl).DragMode := TDragMode(Value);
end;

function TwrpControl.Get_Font: IgsFont;
begin
  Result := GetGdcOLEObject(TCrackControl(GetControl).Font) as IgsFont;
end;

procedure TwrpControl.Set_Font(const Value: IgsFont);
begin
  TCrackControl(GetControl).Font := InterfaceToObject(Value) as TFont;
end;

function TwrpControl.Get_IsControl: WordBool;
begin
  Result := TCrackControl(GetControl).IsControl;
end;

function TwrpControl.Get_ParentBiDiMode: WordBool;
begin
  Result := TCrackControl(GetControl).ParentBiDiMode;
end;

function TwrpControl.Get_ParentColor: WordBool;
begin
  Result := TCrackControl(GetControl).ParentColor;
end;

function TwrpControl.Get_ParentFont: WordBool;
begin
  Result := TCrackControl(GetControl).ParentFont;
end;

function TwrpControl.Get_ParentShowHint: WordBool;
begin
  Result := TCrackControl(GetControl).ParentShowHint;
end;

function TwrpControl.Get_Text: WideString;
begin
  Result := TCrackControl(GetControl).Text;
end;

procedure TwrpControl.Set_IsControl(Value: WordBool);
begin
  TCrackControl(GetControl).IsControl := Value;
end;

procedure TwrpControl.Set_ParentBiDiMode(Value: WordBool);
begin
  TCrackControl(GetControl).ParentBiDiMode := Value;
end;

procedure TwrpControl.Set_ParentColor(Value: WordBool);
begin
  TCrackControl(GetControl).ParentColor := Value;
end;

procedure TwrpControl.Set_ParentFont(Value: WordBool);
begin
  TCrackControl(GetControl).ParentFont := Value;
end;

procedure TwrpControl.Set_ParentShowHint(Value: WordBool);
begin
  TCrackControl(GetControl).ParentShowHint := Value;
end;

procedure TwrpControl.Set_Text(const Value: WideString);
begin
  TCrackControl(GetControl).Text := TCaption(Value);
end;

procedure TwrpControl.AdjustSize;
begin
  TCrackControl(GetControl).AdjustSize;
end;

procedure TwrpControl.BeginAutoDrag;
begin
  TCrackControl(GetControl).BeginAutoDrag;
end;
{
function TwrpControl.CanAutoSize(NewWidth, NewHeight: Integer): WordBool;
begin
  Result :=  TCrackControl(GetControl).CanAutoSize(NewWidth, NewHeight);
end;

function TwrpControl.CanResize(NewWidth, NewHeight: Integer): WordBool;
begin
  Result :=  TCrackControl(GetControl).CanResize(NewWidth, NewHeight);
end;
}
procedure TwrpControl.Changed;
begin
  TCrackControl(GetControl).Changed;
end;

procedure TwrpControl.ChangeScale(M, D: Integer);
begin
  TCrackControl(GetControl).ChangeScale(M, D);
end;

procedure TwrpControl.ConstrainedResize(MinWidth, MinHeight, MaxWidth,
  MaxHeight: Integer);
begin
  TCrackControl(GetControl).ConstrainedResize(MinWidth, MinHeight,
    MaxWidth, MaxHeight);
end;

procedure TwrpControl.DblClick;
begin
  TCrackControl(GetControl).DblClick;
end;

function TwrpControl.PaletteChanged(Foreground: WordBool): WordBool;
begin
  Result :=  TCrackControl(GetControl).PaletteChanged(Foreground);
end;

procedure TwrpControl.RequestAlign;
begin
  TCrackControl(GetControl).RequestAlign;
end;

procedure TwrpControl.Resize;
begin
  TCrackControl(GetControl).Resize
end;

procedure TwrpControl.VisibleChanging;
begin
  TCrackControl(GetControl).VisibleChanging;
end;

procedure TwrpControl.Hide;
begin
  GetControl.Hide;
end;

function TwrpControl.Get_Name_: WideString;
begin
  Result := GetControl.Name;
end;

procedure TwrpControl.Set_Name(const Value: WideString);
begin
  GetControl.Name := Value;
end;

function TwrpControl.Get_Parent: IgsWinControl;
begin
  Result := GetGdcOLEObject(GetControl.Parent) as IgsWinControl;
end;

procedure TwrpControl.Set_Parent(const Value: IgsWinControl);
begin
  GetControl.Parent := InterfaceToObject(Value) as TWinControl;
end;

function TwrpControl.Get_Anchors: WideString;
begin
  Result := ' ';
  if akTop in GetControl.Anchors then
    Result := Result + 'akTop ';
  if akLeft in GetControl.Anchors then
    Result := Result + 'akLeft ';
  if akRight in GetControl.Anchors then
    Result := Result + 'akRight ';
  if akBottom in GetControl.Anchors then
    Result := Result + 'akBottom ';

end;

procedure TwrpControl.Set_Anchors(const Value: WideString);
var
  LAnchors: TAnchors;
  UpperValue: String;
begin
  UpperValue := UpperCase(Value);
  if Pos('AKTOP', UpperValue) > 0 then
    Include(LAnchors, akTop);
  if Pos('AKLEFT', UpperValue) > 0 then
    Include(LAnchors, akLeft);
  if Pos('AKRIGHT', UpperValue) > 0 then
    Include(LAnchors, akRight);
  if Pos('AKBOTTOM', UpperValue) > 0 then
    Include(LAnchors, akBottom);
  GetControl.Anchors := LAnchors;
end;

function TwrpControl.Get_Constraints: IgsSizeConstraints;
begin
  Result := GetGdcOLEObject(GetControl.Constraints) as IgsSizeConstraints;
end;

procedure TwrpControl.Set_Constraints(const Value: IgsSizeConstraints);
begin
  GetControl.Constraints := InterfaceToObject(Value) as TSizeConstraints;
end;

function TwrpControl.Get_ControlState: WideString;
begin
  Result := TControlStateToStr(GetControl.ControlState);
end;

procedure TwrpControl.Set_ControlState(const Value: WideString);
begin
  GetControl.ControlState := StrToTControlState(Value);
end;

function TwrpControl.Get_ControlStyle: WideString;
begin
  Result := TControlStyleToStr(GetControl.ControlStyle);
end;

procedure TwrpControl.Set_ControlStyle(const Value: WideString);
begin
  GetControl.ControlStyle := StrToTControlStyle(Value);
end;

function TwrpControl.Get_Floating: WordBool;
begin
  Result :=  GetControl.Floating;
end;

function TwrpControl.Get_HostDockSite: IgsWinControl;
begin
  Result := GetGdcOLEObject(GetControl.HostDockSite) as IgsWinControl;
end;

procedure TwrpControl.Set_HostDockSite(const Value: IgsWinControl);
begin
  GetControl.HostDockSite := InterfaceToObject(Value) as TWinControl;
end;

function TwrpControl.Get_PopupMenu: IgsPopupMenu;
begin
  Result := GetGdcOLEObject(TCrackControl(GetControl).PopupMenu) as IgsPopupMenu;
end;

procedure TwrpControl.Set_PopupMenu(const Value: IgsPopupMenu);
begin
  TCrackControl(GetControl).PopupMenu := InterfaceToObject(Value) as TPopupMenu;
end;

procedure TwrpControl.BeginDrag(Immediate: WordBool; Threshold: Integer);
begin
  GetControl.BeginDrag(Immediate, Threshold);
end;

procedure TwrpControl.DragDrop(const Source: IgsObject; X, Y: Integer);
begin
  GetControl.DragDrop(InterfaceToObject(Source), X, Y);
end;

function TwrpControl.Dragging: WordBool;
begin
  Result := GetControl.Dragging;
end;

function TwrpControl.GetControlsAlignment: TgsAlignment;
begin
  Result := TgsAlignment(GetControl.GetControlsAlignment);
end;

procedure TwrpControl.Invalidate;
begin
  GetControl.Invalidate;
end;

function TwrpControl.ManualDock(const NewDockSite: IgsWinControl;
  const DropControl: IgsControl; ControlSide: TgsAlign): WordBool;
begin
  Result := GetControl.ManualDock(InterfaceToObject(NewDockSite) as
    TWinControl, InterfaceToObject(DropControl) as TControl,
    TAlign(ControlSide));
end;

function TwrpControl.Perform(Msg: LongWord; WParam,
  LParam: Integer): Integer;
begin
  Result := GetControl.Perform(Msg, WParam, LParam);
end;

function TwrpControl.ReplaceDockedControl(const Control: IgsControl;
  const NewDockSite: IgsWinControl; const DropControl: IgsControl;
  ControlSide: TgsAlign): WordBool;
begin
  Result := GetControl.ReplaceDockedControl(InterfaceToObject(Control) as TControl,
    InterfaceToObject(NewDockSite) as TWinControl,
    InterfaceToObject(DropControl) as TControl, TAlign(ControlSide));
end;

procedure TwrpControl.ClientToScreen(ClientX, ClientY: Integer;
  out ScreenX, ScreenY: OleVariant);
var
  P: TPoint;
begin
  with P do
  begin
    x := ClientX;
    y := ClientY;
  end;
  P := GetControl.ClientToScreen(P);
  with P do
  begin
    ScreenX := X;
    ScreenY := Y;
  end;
end;

procedure TwrpControl.ScreenToClient(out ClientX, ClientY: OleVariant;
  ScreenX, ScreenY: Integer);
var
  P: TPoint;
begin
  with P do
  begin
    x := ScreenX;
    y := ScreenY;
  end;
  P := GetControl.ScreenToClient(P);
  with P do
  begin
    ClientX := X;
    ClientY := Y;
  end;
end;

{ TwrpWinControl }

function TwrpWinControl.Focused: WordBool;
begin
  Result := GetWinControl.Focused;
end;

function TwrpWinControl.Get_TabOrder: Integer;
begin
  Result := GetWinControl.TabOrder;
end;

function TwrpWinControl.Get_TabStop: WordBool;
begin
  Result := GetWinControl.TabStop;
end;

function TwrpWinControl.GetWinControl: TWinControl;
begin
  Result := GetObject as TWinControl;
end;

procedure TwrpWinControl.Repaint;
begin
  GetWinControl.Repaint;
end;

procedure TwrpWinControl.Set_TabOrder(Value: Integer);
begin
  GetWinControl.TabOrder := Value
end;

procedure TwrpWinControl.Set_TabStop(Value: WordBool);
begin
  GetWinControl.TabStop := Value;
end;

procedure TwrpWinControl.SetFocus;
begin
  GetWinControl.SetFocus;
end;

{ TwrpGraphicControl }

function TwrpGraphicControl.GetGraphicControl: TGraphicControl;
begin
  Result := GetObject as TGraphicControl;
end;

function TwrpGraphicControl.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(TCrackGraphicControl(GetGraphicControl).Canvas) as IgsCanvas;
end;

procedure TwrpGraphicControl.Paint;
begin
  TCrackGraphicControl(GetGraphicControl).Paint;
end;

{ TwrpWinControl }

function TwrpWinControl.Get_Handle: LongWord;
begin
  Result := GetWinControl.Handle;
end;

function TwrpWinControl.Get_BevelKind: TgsBevelKind;
begin
  Result := TgsBevelKind(TCrackWinControl(GetWinControl).BevelKind);
end;

function TwrpWinControl.Get_BevelOuter: TgsBevelCut;
begin
  Result := TgsBevelCut(TCrackWinControl(GetWinControl).BevelOuter);
end;

function TwrpWinControl.Get_BevelWidth: Integer;
begin
  Result := Integer(TCrackWinControl(GetWinControl).BevelWidth);
end;

function TwrpWinControl.Get_BorderWidth: Integer;
begin
  Result := Integer(TCrackWinControl(GetWinControl).BorderWidth);
end;

function TwrpWinControl.Get_Ctl3D: WordBool;
begin
  Result := TCrackWinControl(GetWinControl).Ctl3D;
end;

function TwrpWinControl.Get_DockSite: WordBool;
begin
  Result := TCrackWinControl(GetWinControl).DockSite;
end;

function TwrpWinControl.Get_ImeMode: TgsImeMode;
begin
  Result := TgsImeMode(TCrackWinControl(GetWinControl).ImeMode);
end;

function TwrpWinControl.Get_ImeName: WideString;
begin
  Result := TCrackWinControl(GetWinControl).ImeName;
end;

function TwrpWinControl.Get_ParentCtl3D: WordBool;
begin
  Result := TCrackWinControl(GetWinControl).ParentCtl3D;
end;

function TwrpWinControl.Get_UseDockManager: WordBool;
begin
  Result := TCrackWinControl(GetWinControl).UseDockManager
end;

function TwrpWinControl.Get_WheelAccumulator: Integer;
begin
  Result := TCrackWinControl(GetWinControl).WheelAccumulator;
end;

procedure TwrpWinControl.Set_BevelKind(Value: TgsBevelKind);
begin
  TCrackWinControl(GetWinControl).BevelKind := TBevelKind(Value);
end;

procedure TwrpWinControl.Set_BevelOuter(Value: TgsBevelCut);
begin
  TCrackWinControl(GetWinControl).BevelOuter := TBevelCut(Value);
end;

procedure TwrpWinControl.Set_BevelWidth(Value: Integer);
begin
  TCrackWinControl(GetWinControl).BevelWidth := TBevelWidth(Value);
end;

procedure TwrpWinControl.Set_BorderWidth(Value: Integer);
begin
  TCrackWinControl(GetWinControl).BorderWidth := TBorderWidth(Value);
end;

procedure TwrpWinControl.Set_Ctl3D(Value: WordBool);
begin
  TCrackWinControl(GetWinControl).Ctl3D := Value;
end;

procedure TwrpWinControl.Set_DockSite(Value: WordBool);
begin
  TCrackWinControl(GetWinControl).DockSite := Value;
end;

procedure TwrpWinControl.Set_ImeMode(Value: TgsImeMode);
begin
  TCrackWinControl(GetWinControl).ImeMode := TImeMode(Value);
end;

procedure TwrpWinControl.Set_ImeName(const Value: WideString);
begin
  TCrackWinControl(GetWinControl).ImeName := TImeName(Value);
end;

procedure TwrpWinControl.Set_ParentCtl3D(Value: WordBool);
begin
  TCrackWinControl(GetWinControl).ParentCtl3D := Value;
end;

procedure TwrpWinControl.Set_UseDockManager(Value: WordBool);
begin
  TCrackWinControl(GetWinControl).UseDockManager := Value;
end;

procedure TwrpWinControl.Set_WheelAccumulator(Value: Integer);
begin
  TCrackWinControl(GetWinControl).WheelAccumulator := Value;
end;

function TwrpWinControl.Get_BevelInner: TgsBevelCut;
begin
  Result := TgsBevelCut(TCrackWinControl(GetWinControl).BevelInner);
end;

procedure TwrpWinControl.Set_BevelInner(Value: TgsBevelCut);
begin
  TCrackWinControl(GetWinControl).BevelInner := TBevelCut(Value);
end;

function TwrpWinControl.Get_Brush: IgsBrush;
begin
  Result := GetGdcOLEObject(GetWinControl.Brush) as IgsBrush;
end;

function TwrpWinControl.Get_ControlCount: Integer;
begin
  Result := GetWinControl.ControlCount;
end;

function TwrpWinControl.Get_DockClientCount: Integer;
begin
  Result := GetWinControl.DockClientCount;
end;

function TwrpWinControl.Get_DockClients(Index: Integer): IgsControl;
begin
  Result := GetGdcOLEObject(GetWinControl.DockClients[Index]) as IgsControl;
end;

function TwrpWinControl.Get_DoubleBuffered: WordBool;
begin
  Result := GetWinControl.DoubleBuffered;
end;

function TwrpWinControl.Get_HelpContext: Integer;
begin
  Result := GetWinControl.HelpContext;
end;

function TwrpWinControl.Get_ParentWindow: Integer;
begin
  Result := GetWinControl.ParentWindow;
end;

function TwrpWinControl.Get_Showing: WordBool;
begin
  Result := GetWinControl.Showing;
end;

function TwrpWinControl.Get_VisibleDockClientCount: Integer;
begin
  Result := GetWinControl.VisibleDockClientCount;
end;

procedure TwrpWinControl.Set_DoubleBuffered(Value: WordBool);
begin
  GetWinControl.DoubleBuffered := Value;
end;

procedure TwrpWinControl.Set_HelpContext(Value: Integer);
begin
  GetWinControl.HelpContext := Value;
end;

procedure TwrpWinControl.Set_ParentWindow(Value: Integer);
begin
  GetWinControl.ParentWindow := Value;
end;

function TwrpWinControl.CanFocus: WordBool;
begin
  Result := GetWinControl.CanFocus;
end;

function TwrpWinControl.ContainsControl(
  const Control: IgsControl): WordBool;
begin
  Result := GetWinControl.ContainsControl(InterfaceToObject(Control) as TControl);
end;

procedure TwrpWinControl.DisableAlign;
begin
  GetWinControl.DisableAlign;
end;

function TwrpWinControl.Get_Controls(Index: Integer): IgsControl;
begin
  Result := GetGdcOLEObject(GetWinControl.Controls[Index]) as IgsControl;
end;

procedure TwrpWinControl.DockDrop(const Source: IgsDragDockObject; X,
  Y: Integer);
begin
  GetWinControl.DockDrop(InterfaceToObject(Source) as TDragDockObject, X, Y);
end;

procedure TwrpWinControl.EnableAlign;
begin
  GetWinControl.EnableAlign;
end;

function TwrpWinControl.FindChildControl(
  const ControlName: WideString): IgsControl;
begin
  Result := GetGdcOLEObject(GetWinControl.FindChildControl(ControlName)) as IgsControl;
end;

procedure TwrpWinControl.FlipChildren(AllLevels: WordBool);
begin
  GetWinControl.FlipChildren(AllLevels);
end;

procedure TwrpWinControl.GetTabOrderList(const List: IgsList);
begin
  GetWinControl.GetTabOrderList(InterfaceToObject(List) as TList);
end;

procedure TwrpWinControl.PaintTo(DC, X, Y: Integer);
begin
  GetWinControl.PaintTo(DC, X, Y);
end;

procedure TwrpWinControl.Realign;
begin
  GetWinControl.Realign;
end;

procedure TwrpWinControl.RemoveControl(const AControl: IgsControl);
begin
  GetWinControl.RemoveControl(InterfaceToObject(AControl) as TControl);
end;

procedure TwrpWinControl.ScaleBy(M, D: Integer);
begin
  GetWinControl.ScaleBy(M, D);
end;

procedure TwrpWinControl.ScrollBy(DeltaX, DeltaY: Integer);
begin
  GetWinControl.ScrollBy(DeltaX, DeltaY);
end;

procedure TwrpWinControl.UpdateControlState;
begin
  GetWinControl.UpdateControlState;
end;

procedure TwrpWinControl.InsertControl(const Control: IgsControl);
var
  LControl: TControl;
begin
  LControl := InterfaceToObject(Control) as TControl;
  LControl.Parent := nil;
  GetWinControl.InsertControl(LControl);
end;

function TwrpWinControl.ControlAtPos(X, Y: Integer; AllowDisabled,
  AllowWinControls: WordBool): IgsControl;
begin
  Result := GetGdcOLEObject(GetWinControl.ControlAtPos(Point(X, Y), AllowDisabled,
    AllowWinControls)) as IgsControl;
end;

{ TwrpButtonControl }

function TwrpButtonControl.GetButtonControl: TButtonControl;
begin
  Result := GetObject as TButtonControl;
end;

function TwrpButtonControl.Get_Checked: WordBool;
begin
  Result := TCrackButtonControl(GetButtonControl).Checked;
end;

function TwrpButtonControl.Get_ClicksDisabled: WordBool;
begin
  Result := TCrackButtonControl(GetButtonControl).ClicksDisabled;
end;

procedure TwrpButtonControl.Set_Checked(Value: WordBool);
begin
  TCrackButtonControl(GetButtonControl).Checked := Value;
end;

procedure TwrpButtonControl.Set_ClicksDisabled(Value: WordBool);
begin
  TCrackButtonControl(GetButtonControl).ClicksDisabled := Value;
end;

{ TwrpButton }

procedure TwrpButton.Click;
begin
  GetButton.Click;
end;

function TwrpButton.GetButton: TButton;
begin
  Result := GetObject as TButton;
end;

function TwrpButton.Get_Cancel: WordBool;
begin
  Result := GetButton.Cancel;
end;

function TwrpButton.Get_Default: WordBool;
begin
  Result := GetButton.Default;
end;

function TwrpButton.Get_ModalResult: Integer;
begin
  Result := GetButton.ModalResult;
end;

procedure TwrpButton.Set_Cancel(Value: WordBool);
begin
  GetButton.Cancel := Value;
end;

procedure TwrpButton.Set_Default(Value: WordBool);
begin
  GetButton.Default := Value;
end;

procedure TwrpButton.Set_ModalResult(Value: Integer);
begin
  GetButton.ModalResult := Value;
end;

{ TwrpForm }

procedure TwrpForm.ArrangeIcons;
begin
  GetForm.ArrangeIcons;
end;

procedure TwrpForm.Cascade;
begin
  GetForm.Cascade;
end;

function TwrpForm.GetForm: TForm;
begin
  Result := GetObject as TForm;
end;

procedure TwrpForm.Next;
begin
  GetForm.Next;
end;

procedure TwrpForm.Previous;
begin
  GetForm.Previous;
end;

procedure TwrpForm.Tile;
begin
  GetForm.Tile;
end;

{ TwrpCustomForm }

procedure TwrpCustomForm.Close;
begin
  GetCustomForm.Close;
end;

function TwrpCustomForm.Get_Active: WordBool;
begin
  Result := GetCustomForm.Active;
end;

function TwrpCustomForm.GetCustomForm: TCustomForm;
begin
  Result := GetObject as TCustomForm;
end;

function TwrpCustomForm.Get_BorderStyle: TgsFormBorderStyle;
begin
  Result := TgsFormBorderStyle(GetCustomForm.BorderStyle);
end;

function TwrpCustomForm.Get_DefaultMonitor: TgsDefaultMonitor;
begin
  Result := TgsDefaultMonitor(TCrackCustomForm(GetCustomForm).DefaultMonitor);
end;

function TwrpCustomForm.Get_FormStyle: TgsFormStyle;
begin
  Result := TgsFormStyle(TCrackCustomForm(GetCustomForm).FormStyle);
end;

function TwrpCustomForm.Get_KeyPrewiew: WordBool;
begin
  Result := GetCustomForm.KeyPreview;
end;

function TwrpCustomForm.Get_MDIChildCount: Integer;
begin
  Result := TCrackCustomForm(GetCustomForm).MDIChildCount;
end;

function TwrpCustomForm.Get_PixelsPerInch: Integer;
begin
  Result := TCrackCustomForm(GetCustomForm).PixelsPerInch;
end;

function TwrpCustomForm.Get_Position: TgsPosition;
begin
  Result := TgsPosition(TCrackCustomForm(GetCustomForm).Position);
end;

function TwrpCustomForm.Get_PrintScale: TgsPrintScale;
begin
  Result := TgsPrintScale(TCrackCustomForm(GetCustomForm).PrintScale);
end;

function TwrpCustomForm.Get_Scaled: WordBool;
begin
  Result := TCrackCustomForm(GetCustomForm).Scaled;
end;

function TwrpCustomForm.Get_TileMode: TgsTileMode;
begin
  Result := TgsTileMode(TCrackCustomForm(GetCustomForm).TileMode);
end;

procedure TwrpCustomForm.Set_BorderStyle(Value: TgsFormBorderStyle);
begin
  TCrackCustomForm(GetCustomForm).BorderStyle := TBorderStyle(Value);
end;

procedure TwrpCustomForm.Set_DefaultMonitor(Value: TgsDefaultMonitor);
begin
  TCrackCustomForm(GetCustomForm).DefaultMonitor := TDefaultMonitor(Value);
end;

procedure TwrpCustomForm.Set_FormStyle(Value: TgsFormStyle);
begin
  TCrackCustomForm(GetCustomForm).FormStyle := TFormStyle(Value);
end;

procedure TwrpCustomForm.Set_KeyPrewiew(Value: WordBool);
begin
  TCrackCustomForm(GetCustomForm).KeyPreview := Value;
end;

procedure TwrpCustomForm.Set_PixelsPerInch(Value: Integer);
begin
  TCrackCustomForm(GetCustomForm).PixelsPerInch := Value;
end;

procedure TwrpCustomForm.Set_Position(Value: TgsPosition);
begin
  TCrackCustomForm(GetCustomForm).Position := TPosition(Value);
end;

procedure TwrpCustomForm.Set_PrintScale(Value: TgsPrintScale);
begin
  TCrackCustomForm(GetCustomForm).PrintScale := TPrintScale(Value);
end;

procedure TwrpCustomForm.Set_Scaled(Value: WordBool);
begin
  TCrackCustomForm(GetCustomForm).Scaled := Value;
end;

procedure TwrpCustomForm.Set_TileMode(Value: TgsTileMode);
begin
  TCrackCustomForm(GetCustomForm).TileMode := TTileMode(Value);
end;

procedure TwrpCustomForm.Print;
begin
  GetCustomForm.Print;
end;

function TwrpCustomForm.ShowModal: Integer;
begin
  Result := GetCustomForm.ShowModal;
end;

procedure TwrpCustomForm.UpdateActions;
begin
  TCrackCustomForm(GetCustomForm).UpdateActions;
end;

procedure TwrpCustomForm.UpdateWindowState;
begin
  TCrackCustomForm(GetCustomForm).UpdateWindowState;
end;

function TwrpCustomForm.Get_ModalResult: Integer;
begin
  Result := TCrackCustomForm(GetCustomForm).ModalResult;
end;

procedure TwrpCustomForm.Set_ModalResult(Value: Integer);
begin
  TCrackCustomForm(GetCustomForm).ModalResult := Value;
end;

function TwrpCustomForm.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetCustomForm.Canvas) as IgsCanvas;
end;

function TwrpCustomForm.Get_WindowMenu: IgsMenuItem;
begin
  Result := GetGdcOLEObject(TCrackCustomForm(GetCustomForm).WindowMenu) as IgsMenuItem;
end;

function TwrpCustomForm.Get_WindowState: TgsWindowState;
begin
  Result := TgsWindowState(GetCustomForm.WindowState);
end;

procedure TwrpCustomForm.Set_WindowMenu(const Value: IgsMenuItem);
begin
  TCrackCustomForm(GetCustomForm).WindowMenu := InterfaceToObject(Value) as TMenuItem;
end;

procedure TwrpCustomForm.Set_WindowState(Value: TgsWindowState);
begin
  GetCustomForm.WindowState := TWindowState(Value)
end;

function TwrpCustomForm.Get_ActiveControl: IgsWinControl;
begin
  Result := GetGdcOLEObject(GetCustomForm.ActiveControl) as IgsWinControl;
end;

function TwrpCustomForm.Get_ActiveOLEControl: IgsWinControl;
begin
  Result := GetGdcOLEObject(GetCustomForm.ActiveOLEControl) as IgsWinControl;
end;

function TwrpCustomForm.Get_DropTarget: WordBool;
begin
  Result := GetCustomForm.DropTarget;
end;

function TwrpCustomForm.Get_FormState: WideString;
begin
  Result := ' ';
  if fsCreating in GetCustomForm.FormState then
    Result := Result + 'fsCreating ';
  if fsVisible in GetCustomForm.FormState then
    Result := Result + 'fsVisible ';
  if fsShowing in GetCustomForm.FormState then
    Result := Result + 'fsShowing ';
  if fsModal in GetCustomForm.FormState then
    Result := Result + 'fsModal ';
  if fsCreatedMDIChild in GetCustomForm.FormState then
    Result := Result + 'fsCreatedMDIChild ';
  if fsActivated in GetCustomForm.FormState then
    Result := Result + 'fsActivated ';
end;

function TwrpCustomForm.Get_HelpFile: WideString;
begin
  Result := GetCustomForm.HelpFile;
end;

function TwrpCustomForm.Get_KeyPreview: WordBool;
begin
  Result := GetCustomForm.KeyPreview;
end;

function TwrpCustomForm.Get_Menu: IgsMainMenu;
begin
  Result := GetGdcOLEObject(GetCustomForm.Menu) as IgsMainMenu;
end;

function TwrpCustomForm.Get_Monitor: IgsMonitor;
begin
  Result := GetGdcOLEObject(GetCustomForm.Monitor) as IgsMonitor;
end;

procedure TwrpCustomForm.Set_ActiveControl(const Value: IgsWinControl);
begin
  GetCustomForm.ActiveControl := InterfaceToObject(Value) as TWinControl;
end;

procedure TwrpCustomForm.Set_ActiveOLEControl(const Value: IgsWinControl);
begin
  GetCustomForm.ActiveOLEControl := InterfaceToObject(Value) as TWinControl;
end;

procedure TwrpCustomForm.Set_DropTarget(Value: WordBool);
begin
  GetCustomForm.DropTarget := Value;
end;

procedure TwrpCustomForm.Set_HelpFile(const Value: WideString);
begin
  GetCustomForm.HelpFile := Value;
end;

procedure TwrpCustomForm.Set_KeyPreview(Value: WordBool);
begin
  GetCustomForm.KeyPreview := Value;
end;

procedure TwrpCustomForm.Set_Menu(const Value: IgsMainMenu);
begin
  GetCustomForm.Menu := InterfaceToObject(Value) as TMainMenu;
end;

function TwrpCustomForm.CloseQuery: WordBool;
begin
  Result := GetCustomForm.CloseQuery;
end;

procedure TwrpCustomForm.DefocusControl(const Control: IgsWinControl;
  Removing: WordBool);
begin
  GetCustomForm.DefocusControl(InterfaceToObject(Control) as TWinControl, Removing);
end;

procedure TwrpCustomForm.FocusControl(const Control: IgsWinControl);
begin
  GetCustomForm.FocusControl(InterfaceToObject(Control) as TWinControl);
end;

function TwrpCustomForm.GetFormImage: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetCustomForm.GetFormImage) as IgsBitmap;
end;

procedure TwrpCustomForm.SendCancelMode(const Sender: IgsControl);
begin
  GetCustomForm.SendCancelMode(InterfaceToObject(Sender) as TControl);
end;

procedure TwrpCustomForm.Activate;
begin
  TCrackCustomForm(GetCustomForm).Activate;
end;

procedure TwrpCustomForm.Release;
begin
  GetCustomForm.Release;
end;

{ TwrpScrollingWinControl }

procedure TwrpScrollingWinControl.DisableAutoRange;
begin
  GetScrollingWinControl.DisableAutoRange;
end;

procedure TwrpScrollingWinControl.EnableAutoRange;
begin
  GetScrollingWinControl.EnableAutoRange;
end;

function TwrpScrollingWinControl.GetScrollingWinControl: TScrollingWinControl;
begin
  Result := GetObject as TScrollingWinControl;
end;

function TwrpScrollingWinControl.Get_AutoScroll: WordBool;
begin
  Result := TCrackScrollingWinControl(GetScrollingWinControl).AutoScroll;
end;

function TwrpScrollingWinControl.Get_HorzScrollBar: IgsControlScrollBar;
begin
  Result := GetGdcOLEObject(GetScrollingWinControl.HorzScrollBar) as IgsControlScrollBar;
end;

function TwrpScrollingWinControl.Get_VertScrollBar: IgsControlScrollBar;
begin
  Result := GetGdcOLEObject(GetScrollingWinControl.VertScrollBar) as IgsControlScrollBar;
end;

procedure TwrpScrollingWinControl.ScrollInView(const AControl: IgsControl);
begin
  GetScrollingWinControl.ScrollInView(InterfaceToObject(AControl) as TControl);
end;

procedure TwrpScrollingWinControl.Set_AutoScroll(Value: WordBool);
begin
  TCrackScrollingWinControl(GetScrollingWinControl).AutoScroll := Value;
end;

procedure TwrpScrollingWinControl.Set_HorzScrollBar(
  const Value: IgsControlScrollBar);
begin
  GetScrollingWinControl.HorzScrollBar := InterfaceToObject(Value) as TControlScrollBar;
end;

procedure TwrpScrollingWinControl.Set_VertScrollBar(
  const Value: IgsControlScrollBar);
begin
  GetScrollingWinControl.VertScrollBar := InterfaceToObject(Value) as TControlScrollBar;
end;

{ TwrpCustomFrame }

function TwrpCustomFrame.GetCustomFrame: TCustomFrame;
begin
  Result := GetObject as TCustomFrame;
end;

{ TwrpMenu }

function TwrpMenu.Get_OwnerDraw: WordBool;
begin
  Result := GetMenu.OwnerDraw;
end;

function TwrpMenu.GetMenu: TMenu;
begin
  Result := GetObject as TMenu;
end;

procedure TwrpMenu.Set_OwnerDraw(Value: WordBool);
begin
  GetMenu.OwnerDraw := Value;
end;

function TwrpMenu.Get_AutoHotKey: TgsMenuItemAutoFlag;
begin
  Result := TgsMenuItemAutoFlag(GetMenu.AutoHotkeys);
end;

function TwrpMenu.Get_AutoLineReduction: TgsMenuItemAutoFlag;
begin
  Result := TgsMenuItemAutoFlag(GetMenu.AutoLineReduction);
end;

function TwrpMenu.Get_BiDiMode: TgsBiDiMode;
begin
  Result := TgsBiDiMode(GetMenu.BiDiMode);
end;

procedure TwrpMenu.Set_AutoHotKey(Value: TgsMenuItemAutoFlag);
begin
  GetMenu.AutoHotkeys := TMenuAutoFlag(Value);
end;

procedure TwrpMenu.Set_AutoLineReduction(Value: TgsMenuItemAutoFlag);
begin
  GetMenu.AutoLineReduction := TMenuAutoFlag(Value);
end;

procedure TwrpMenu.Set_BiDiMode(Value: TgsBiDiMode);
begin
  GetMenu.BiDiMode := TBiDiMode(Value);
end;

function TwrpMenu.Get_Items: IgsMenuItem;
begin
  Result := GetGdcOLEObject(GetMenu.Items) as IgsMenuItem;
end;

function TwrpMenu.Get_Handle: Integer;
begin
  Result := GetMenu.Handle;
end;

function TwrpMenu.Get_ParentBiDiMode: WordBool;
begin
  Result := GetMenu.ParentBiDiMode;
end;

function TwrpMenu.Get_WindowHandle: Integer;
begin
  Result := GetMenu.WindowHandle;
end;

procedure TwrpMenu.Set_ParentBiDiMode(Value: WordBool);
begin
  GetMenu.ParentBiDiMode := Value;
end;

procedure TwrpMenu.Set_WindowHandle(Value: Integer);
begin
  GetMenu.WindowHandle := Value;
end;

{ TwrpMainMenu }

function TwrpMainMenu.Get_AutoMerge: WordBool;
begin
  Result := GetMainMenu.AutoMerge;
end;

function TwrpMainMenu.GetMainMenu: TMainMenu;
begin
  Result := GetObject as TMainMenu;
end;

procedure TwrpMainMenu.Set_AutoMerge(Value: WordBool);
begin
  GetMainMenu.AutoMerge := Value;
end;

procedure TwrpMainMenu.Merge(const Menu: IgsMainMenu);
begin
  GetMainMenu.Merge(InterfaceToObject(Menu) as TMainMenu);
end;

procedure TwrpMainMenu.UnMerge(const Menu: IgsMainMenu);
begin
  GetMainMenu.UnMerge(InterfaceToObject(Menu) as TMainMenu);
end;

{ TwrpPopupMenu }

function TwrpPopupMenu.Get_AutoPopup: WordBool;
begin
  Result := GetPopupMenu.AutoPopup;
end;

function TwrpPopupMenu.GetPopupMenu: TPopupMenu;
begin
  Result := GetObject as TPopupMenu;
end;

procedure TwrpPopupMenu.Popup(x, y: Integer);
begin
  GetPopupMenu.Popup(x, y);
end;

procedure TwrpPopupMenu.Set_AutoPopup(Value: WordBool);
begin
  GetPopupMenu.AutoPopup := Value;
end;

function TwrpPopupMenu.Get_Alignment: TgsPopupAlignment;
begin
  Result := TgsPopupAlignment(GetPopupMenu.Alignment);
end;

procedure TwrpPopupMenu.Set_Alignment(Value: TgsPopupAlignment);
begin
  GetPopupMenu.Alignment := TPopupAlignment(Value);
end;

function TwrpPopupMenu.Get_HelpContext: Integer;
begin
  Result := GetPopupMenu.HelpContext;
end;

function TwrpPopupMenu.Get_MenuAnimation: WideString;
begin
  Result := ' ';
  if maLeftToRight in GetPopupMenu.MenuAnimation then
    Result := Result + 'maLeftToRight ';
  if maRightToLeft in GetPopupMenu.MenuAnimation then
    Result := Result + 'maRightToLeft ';
  if maTopToBottom in GetPopupMenu.MenuAnimation then
    Result := Result + 'maTopToBottom ';
  if maBottomToTop in GetPopupMenu.MenuAnimation then
    Result := Result + 'maBottomToTop ';
  if maNone in GetPopupMenu.MenuAnimation then
    Result := Result + 'maNone ';
end;

function TwrpPopupMenu.Get_PopupComponent: IgsComponent;
begin
  Result := GetGdcOLEObject(GetPopupMenu.PopupComponent) as IgsComponent;
end;

function TwrpPopupMenu.Get_TrackButton: TgsTrackButton;
begin
  Result := TgsTrackButton(GetPopupMenu.TrackButton);
end;

procedure TwrpPopupMenu.Set_HelpContext(Value: Integer);
begin
  GetPopupMenu.HelpContext := Value;
end;

procedure TwrpPopupMenu.Set_MenuAnimation(const Value: WideString);
var
  LMenuAnimation: TMenuAnimation;
begin
  LMenuAnimation := [];
  if Pos('MALEFTTORIGHT', Value) > 0 then
    Include(LMenuAnimation, MALEFTTORIGHT);
  if Pos('MARIGHTTOLEFT', Value) > 0 then
    Include(LMenuAnimation, MARIGHTTOLEFT);
  if Pos('MATOPTOBOTTOM', Value) > 0 then
    Include(LMenuAnimation, MATOPTOBOTTOM);
  if Pos('MABOTTOMTOTOP', Value) > 0 then
    Include(LMenuAnimation, MABOTTOMTOTOP);
  if Pos('MANONE', Value) > 0 then
    Include(LMenuAnimation, MANONE);
  GetPopupMenu.MenuAnimation := LMenuAnimation;
end;

procedure TwrpPopupMenu.Set_PopupComponent(const Value: IgsComponent);
begin
  GetPopupMenu.PopupComponent := InterfaceToObject(Value) as TComponent;
end;

procedure TwrpPopupMenu.Set_TrackButton(Value: TgsTrackButton);
begin
  GetPopupMenu.TrackButton := TTrackButton(Value);
end;

{ TwrpCustomEdit }

procedure TwrpCustomEdit.Clear;
begin
  GetCustomEdit.Clear;
end;

procedure TwrpCustomEdit.ClearSelection;
begin
  GetCustomEdit.ClearSelection;
end;

procedure TwrpCustomEdit.ClearUndo;
begin
  GetCustomEdit.ClearUndo;
end;

procedure TwrpCustomEdit.CopyToClipBoard;
begin
  GetCustomEdit.CopyToClipboard;
end;

procedure TwrpCustomEdit.CutToClipboard;
begin
  GetCustomEdit.CutToClipboard;
end;

function TwrpCustomEdit.Get_CanUndo: WordBool;
begin
  Result := GetCustomEdit.CanUndo;
end;

function TwrpCustomEdit.Get_Modified: WordBool;
begin
  Result := GetCustomEdit.Modified;
end;

function TwrpCustomEdit.GetCustomEdit: TCustomEdit;
begin
  Result := GetObject as TCustomEdit;
end;

procedure TwrpCustomEdit.PasteFromClipboard;
begin
  GetCustomEdit.PasteFromClipboard;
end;

procedure TwrpCustomEdit.SelectAll;
begin
  GetCustomEdit.SelectAll;
end;

procedure TwrpCustomEdit.Set_Modified(Value: WordBool);
begin
  GetCustomEdit.Modified := Value;
end;

procedure TwrpCustomEdit.Set_SelStart(Value: Integer);
begin
  GetCustomEdit.SelStart := Value;
end;

procedure TwrpCustomEdit.Undo;
begin
  GetCustomEdit.Undo;
end;

function TwrpCustomEdit.Get_BorderStyle: TgsFormBorderStyle;
begin
  Result := TgsFormBorderStyle(TCrackCustomEdit(GetCustomEdit).BorderStyle);
end;

procedure TwrpCustomEdit.Set_BorderStyle(Value: TgsFormBorderStyle);
begin
  TCrackCustomEdit(GetCustomEdit).BorderStyle := TBorderStyle(Value);
end;

function TwrpCustomEdit.Get_CharCase: TgsEditCharCase;
begin
  Result := TgsEditCharCase(TCrackCustomEdit(GetCustomEdit).CharCase);
end;

procedure TwrpCustomEdit.Set_CharCase(Value: TgsEditCharCase);
begin
  TCrackCustomEdit(GetCustomEdit).CharCase := TEditCharCase(Value);
end;

function TwrpCustomEdit.Get_SelLength: Integer;
begin
  Result := GetCustomEdit.SelLength;
end;

function TwrpCustomEdit.Get_SelStart: Integer;
begin
  Result := GetCustomEdit.SelStart;
end;

function TwrpCustomEdit.Get_SelText: WideString;
begin
  Result := GetCustomEdit.SelText;
end;

procedure TwrpCustomEdit.Set_SelLength(Value: Integer);
begin
  GetCustomEdit.SelLength := Value;
end;

procedure TwrpCustomEdit.Set_SelText(const Value: WideString);
begin
  GetCustomEdit.SelText := Value;
end;

function TwrpCustomEdit.Get_HideSelection: WordBool;
begin
  Result := TCrackCustomEdit(GetCustomEdit).HideSelection;
end;

function TwrpCustomEdit.Get_OEMConvert: WordBool;
begin
  Result := TCrackCustomEdit(GetCustomEdit).OEMConvert;
end;

function TwrpCustomEdit.Get_ReadOnly: WordBool;
begin
  Result := TCrackCustomEdit(GetCustomEdit).ReadOnly;
end;

procedure TwrpCustomEdit.Set_HideSelection(Value: WordBool);
begin
  TCrackCustomEdit(GetCustomEdit).HideSelection := Value;
end;

procedure TwrpCustomEdit.Set_OEMConvert(Value: WordBool);
begin
  TCrackCustomEdit(GetCustomEdit).OEMConvert := Value;
end;

procedure TwrpCustomEdit.Set_ReadOnly(Value: WordBool);
begin
  TCrackCustomEdit(GetCustomEdit).ReadOnly := Value;
end;

function TwrpCustomEdit.Get_MaxLength: Integer;
begin
  Result := TCrackCustomEdit(GetCustomEdit).MaxLength;
end;

procedure TwrpCustomEdit.Set_MaxLength(Value: Integer);
begin
  TCrackCustomEdit(GetCustomEdit).MaxLength := Value;
end;

function TwrpCustomEdit.Get_AutoSelect: WordBool;
begin
  Result := TCrackCustomEdit(GetCustomEdit).AutoSelect;
end;

procedure TwrpCustomEdit.Set_AutoSelect(Value: WordBool);
begin
  TCrackCustomEdit(GetCustomEdit).AutoSelect := Value;
end;

function TwrpCustomEdit.Get_PasswordChar: WideString;
begin
  Result := TCrackCustomEdit(GetCustomEdit).PasswordChar;
end;

procedure TwrpCustomEdit.Set_PasswordChar(const Value: WideString);
var
  LStr: String;
begin
  LStr := Value;
  LStr := TrimLeft(LStr);
  if Length(LStr) > 0 then
    TCrackCustomEdit(GetCustomEdit).PasswordChar := LStr[1]
  else
    TCrackCustomEdit(GetCustomEdit).PasswordChar := #0;
end;

{ TwrpCustomMemo }

function TwrpCustomMemo.GetCustomMemo: TCustomMemo;
begin
  Result := GetObject as TCustomMemo;
end;

function TwrpCustomMemo.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(TCrackCustomMemo(GetCustomMemo).Alignment);
end;

procedure TwrpCustomMemo.CaretPos(out X: OleVariant; out Y: OleVariant); safecall;
begin
  X := GetCustomMemo.CaretPos.X;
  Y := GetCustomMemo.CaretPos.Y;
end;

function TwrpCustomMemo.Get_Lines: IgsStrings;
begin
  Result := TStringsToIGSStrings(GetCustomMemo.Lines);
end;

function TwrpCustomMemo.Get_ScrollBars: TgsScrollStyle;
begin
  Result := TgsScrollStyle(TCrackCustomMemo(GetCustomMemo).ScrollBars);
end;

function TwrpCustomMemo.Get_WantTabs: WordBool;
begin
  Result := TCrackCustomMemo(GetCustomMemo).WantTabs;
end;

function TwrpCustomMemo.Get_WordWrap: WordBool;
begin
  Result := TCrackCustomMemo(GetCustomMemo).WordWrap;
end;

procedure TwrpCustomMemo.Set_Alignment(Value: TgsAlignment);
begin
  TCrackCustomMemo(GetCustomMemo).Alignment := TAlignment(Value);
end;

procedure TwrpCustomMemo.Set_Lines(const Value: IgsStrings);
begin
  GetCustomMemo.Lines := IgsStringsToTStrings(Value);
end;

procedure TwrpCustomMemo.Set_ScrollBars(Value: TgsScrollStyle);
begin
  TCrackCustomMemo(GetCustomMemo).ScrollBars := TScrollStyle(Value);
end;

procedure TwrpCustomMemo.Set_WantTabs(Value: WordBool);
begin
  TCrackCustomMemo(GetCustomMemo).WantTabs := Value;
end;

procedure TwrpCustomMemo.Set_WordWrap(Value: WordBool);
begin
  TCrackCustomMemo(GetCustomMemo).WordWrap := Value;
end;

{ TwrpMemo }

function TwrpMemo.Get_WantReturns: WordBool;
begin
  Result := GetMemo.WantReturns;
end;

function TwrpMemo.GetMemo: TMemo;
begin
  Result := GetObject as TMemo
end;

procedure TwrpMemo.Set_WantReturns(Value: WordBool);
begin
  GetMemo.WantReturns := Value;
end;

{ TwrpCustomCheckBox }

function TwrpCustomCheckBox.GetCustomCheckBox: TCustomCheckBox;
begin
  Result := GetObject as TCustomCheckBox;
end;

function TwrpCustomCheckBox.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(TCrackCustomCheckBox(GetCustomCheckBox).Alignment);
end;

function TwrpCustomCheckBox.Get_AllowGrayed: WordBool;
begin
  Result := TCrackCustomCheckBox(GetCustomCheckBox).AllowGrayed;
end;

function TwrpCustomCheckBox.Get_State: TgsCheckBoxState;
begin
  Result := TgsCheckBoxState(TCrackCustomCheckBox(GetCustomCheckBox).State);
end;

procedure TwrpCustomCheckBox.Set_Alignment(Value: TgsAlignment);
begin
  TCrackCustomCheckBox(GetCustomCheckBox).Alignment := TAlignment(Value);
end;

procedure TwrpCustomCheckBox.Set_AllowGrayed(Value: WordBool);
begin
  TCrackCustomCheckBox(GetCustomCheckBox).AllowGrayed := Value;
end;

procedure TwrpCustomCheckBox.Set_State(Value: TgsCheckBoxState);
begin
  TCrackCustomCheckBox(GetCustomCheckBox).State := TCheckBoxState(Value);
end;

procedure TwrpCustomCheckBox.Toggle;
begin
  TCrackCustomCheckBox(GetCustomCheckBox).Toggle;
end;

{ TwrpRadioButton }

function TwrpRadioButton.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(GetRadioButton.Alignment);
end;

function TwrpRadioButton.GetRadioButton: TRadioButton;
begin
  Result := GetObject as TRadioButton;
end;

procedure TwrpRadioButton.Set_Alignment(Value: TgsAlignment);
begin
  GetRadioButton.Alignment := TLeftRight(Value);
end;

{ TwrpCustomListBox }

procedure TwrpCustomListBox.ClearBox;
begin
  GetCustomListBox.Clear;
end;

procedure TwrpCustomListBox.DeleteString(Index: Integer);
begin
  TCrackCustomListBox(GetCustomListBox).DeleteString(Index);
end;

function TwrpCustomListBox.GetCustomListBox: TCustomListBox;
begin
  Result := GetObject as TCustomListBox;
end;

function TwrpCustomListBox.Get_BorderStyle: TgsBorderStyle;
begin
  Result := TgsBorderStyle(TCrackCustomListBox(GetCustomListBox).BorderStyle);
end;

function TwrpCustomListBox.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetCustomListBox.Canvas) as IgsCanvas;
end;

function TwrpCustomListBox.Get_Columns: Integer;
begin
  Result := TCrackCustomListBox(GetCustomListBox).Columns;
end;

function TwrpCustomListBox.Get_ExtendedSelect: WordBool;
begin
  Result := TCrackCustomListBox(GetCustomListBox).ExtendedSelect;
end;

function TwrpCustomListBox.Get_IntegralHeight: WordBool;
begin
  Result := TCrackCustomListBox(GetCustomListBox).IntegralHeight;
end;

function TwrpCustomListBox.Get_ItemHeight: Integer;
begin
  Result := TCrackCustomListBox(GetCustomListBox).ItemHeight;
end;

function TwrpCustomListBox.Get_ItemIndex: Integer;
begin
  Result := GetCustomListBox.ItemIndex;
end;

function TwrpCustomListBox.Get_Items: IgsStrings;
begin
  Result := TStringsToIGSStrings(GetCustomListBox.Items);
end;

function TwrpCustomListBox.Get_MultiSelect: WordBool;
begin
  Result := TCrackCustomListBox(GetCustomListBox).MultiSelect;
end;

function TwrpCustomListBox.Get_SelCount: Integer;
begin
  Result := GetCustomListBox.SelCount;
end;

function TwrpCustomListBox.Get_Selected(Index: Integer): WordBool;
begin
  Result := GetCustomListBox.Selected[Index];
end;

function TwrpCustomListBox.Get_Sorted: WordBool;
begin
  Result := TCrackCustomListBox(GetCustomListBox).Sorted;
end;

function TwrpCustomListBox.Get_Style: TgsListBoxStyle;
begin
  Result := TgsListBoxStyle(TCrackCustomListBox(GetCustomListBox).Style);
end;

function TwrpCustomListBox.Get_TabWidth: Integer;
begin
  Result := TCrackCustomListBox(GetCustomListBox).TabWidth;
end;

function TwrpCustomListBox.Get_TopIndex: Integer;
begin
  Result := GetCustomListBox.TopIndex;
end;

function TwrpCustomListBox.ItemAtPos(X, Y: Integer;
  Existing: WordBool): Integer;
var
  tmpPoin: TPoint;
begin
  tmpPoin.x := X;
  tmpPoin.y := Y;
  Result := GetCustomListBox.ItemAtPos(tmpPoin, Existing);
end;

procedure TwrpCustomListBox.ItemRect(Item: Integer; out Left, Top, Right,
  Bottom: OleVariant);
var
  tmpRect: TRect;
begin
  tmpRect := GetCustomListBox.ItemRect(Item);
  Left := tmpRect.Left;
  Top := tmpRect.Top;
  Right := tmpRect.Right;
  Bottom := tmpRect.Bottom;
end;

procedure TwrpCustomListBox.ResetContent;
begin
  TCrackCustomListBox(GetCustomListBox).ResetContent;
end;

procedure TwrpCustomListBox.Set_BorderStyle(Value: TgsBorderStyle);
begin
  TCrackCustomListBox(GetCustomListBox).BorderStyle := TBorderStyle(Value);
end;

procedure TwrpCustomListBox.Set_Columns(Value: Integer);
begin
  TCrackCustomListBox(GetCustomListBox).Columns := Value;
end;

procedure TwrpCustomListBox.Set_ExtendedSelect(Value: WordBool);
begin
  TCrackCustomListBox(GetCustomListBox).ExtendedSelect := Value;
end;

procedure TwrpCustomListBox.Set_IntegralHeight(Value: WordBool);
begin
  TCrackCustomListBox(GetCustomListBox).IntegralHeight := Value;
end;

procedure TwrpCustomListBox.Set_ItemHeight(Value: Integer);
begin
  TCrackCustomListBox(GetCustomListBox).ItemHeight := Value;
end;

procedure TwrpCustomListBox.Set_ItemIndex(Value: Integer);
begin
  TCrackCustomListBox(GetCustomListBox).ItemIndex := Value;
end;

procedure TwrpCustomListBox.Set_Items(const Value: IgsStrings);
begin
  GetCustomListBox.Items := IgsStringsToTStrings(Value);
end;

procedure TwrpCustomListBox.Set_MultiSelect(Value: WordBool);
begin
  TCrackCustomListBox(GetCustomListBox).MultiSelect := Value;
end;

procedure TwrpCustomListBox.Set_Selected(Index: Integer; Value: WordBool);
begin
  GetCustomListBox.Selected[Index] :=  Value;
end;

procedure TwrpCustomListBox.Set_Sorted(Value: WordBool);
begin
  TCrackCustomListBox(GetCustomListBox).Sorted := Value;
end;

procedure TwrpCustomListBox.Set_Style(Value: TgsListBoxStyle);
begin
  TCrackCustomListBox(GetCustomListBox).Style := TListBoxStyle(Value);
end;

procedure TwrpCustomListBox.Set_TabWidth(Value: Integer);
begin
  TCrackCustomListBox(GetCustomListBox).TabWidth := Value;
end;

procedure TwrpCustomListBox.Set_TopIndex(Value: Integer);
begin
  GetCustomListBox.TopIndex := Value;
end;

{ TwrpListBox }

procedure TwrpListBox.Clear;
begin
  GetListBox.Clear;
end;

function TwrpListBox.GetListBox: TListBox;
begin
  Result := GetObject as TListBox;
end;

{ TwrpCustomComboBox }

procedure TwrpCustomComboBox.Clear;
begin
  GetCustomComboBox.Clear;
end;

function TwrpCustomComboBox.GetCustomComboBox: TCustomComboBox;
begin
  Result := GetObject as TCustomComboBox;
end;

function TwrpCustomComboBox.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetCustomComboBox.Canvas) as IgsCanvas;
end;

function TwrpCustomComboBox.Get_CharCase: TgsEditCharCase;
begin
  Result := TgsEditCharCase(TCrackCustomComboBox(GetCustomComboBox).CharCase);

end;

function TwrpCustomComboBox.Get_DropDownCount: Integer;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).DropDownCount;
end;

function TwrpCustomComboBox.Get_DroppedDown: WordBool;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).DroppedDown;
end;

function TwrpCustomComboBox.Get_EditHandle: Integer;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).EditHandle;
end;

function TwrpCustomComboBox.Get_ItemHeight: Integer;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).ItemHeight;
end;

function TwrpCustomComboBox.Get_ItemIndex: Integer;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).ItemIndex;
end;

function TwrpCustomComboBox.Get_Items: IgsStrings;
begin
  Result := TStringsToIGSStrings(TCrackCustomComboBox(GetCustomComboBox).Items);
end;

function TwrpCustomComboBox.Get_ListHandle: Integer;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).ListHandle;
end;

function TwrpCustomComboBox.Get_MaxLength: Integer;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).MaxLength;
end;

function TwrpCustomComboBox.Get_SelLength: Integer;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).SelLength;
end;

function TwrpCustomComboBox.Get_SelStart: Integer;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).SelStart;
end;

function TwrpCustomComboBox.Get_SelText: WideString;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).SelText;
end;

function TwrpCustomComboBox.Get_Sorted: WordBool;
begin
  Result := TCrackCustomComboBox(GetCustomComboBox).Sorted;
end;

function TwrpCustomComboBox.Get_Style: TgsComboBoxStyle;
begin
  Result := TgsComboBoxStyle(TCrackCustomComboBox(GetCustomComboBox).Style);
end;

procedure TwrpCustomComboBox.SelectAll;
begin
  GetCustomComboBox.SelectAll;
end;

procedure TwrpCustomComboBox.Set_CharCase(Value: TgsEditCharCase);
begin
  TCrackCustomComboBox(GetCustomComboBox).CharCase := TEditCharCase(Value);
end;

procedure TwrpCustomComboBox.Set_DropDownCount(Value: Integer);
begin
  TCrackCustomComboBox(GetCustomComboBox).DropDownCount := Value;
end;

procedure TwrpCustomComboBox.Set_DroppedDown(Value: WordBool);
begin
  TCrackCustomComboBox(GetCustomComboBox).DroppedDown := Value;
end;

procedure TwrpCustomComboBox.Set_ItemHeight(Value: Integer);
begin
  TCrackCustomComboBox(GetCustomComboBox).ItemHeight := Value;
end;

procedure TwrpCustomComboBox.Set_ItemIndex(Value: Integer);
begin
  TCrackCustomComboBox(GetCustomComboBox).ItemIndex := Value;
end;

procedure TwrpCustomComboBox.Set_Items(const Value: IgsStrings);
begin
  TCrackCustomComboBox(GetCustomComboBox).Items := IgsStringsToTStrings(Value);
end;

procedure TwrpCustomComboBox.Set_MaxLength(Value: Integer);
begin
  TCrackCustomComboBox(GetCustomComboBox).MaxLength := Value;
end;

procedure TwrpCustomComboBox.Set_SelLength(Value: Integer);
begin
  TCrackCustomComboBox(GetCustomComboBox).SelLength := Value;
end;

procedure TwrpCustomComboBox.Set_SelStart(Value: Integer);
begin
  TCrackCustomComboBox(GetCustomComboBox).SelStart := Value;
end;

procedure TwrpCustomComboBox.Set_SelText(const Value: WideString);
begin
  TCrackCustomComboBox(GetCustomComboBox).SelText := Value;
end;

procedure TwrpCustomComboBox.Set_Sorted(Value: WordBool);
begin
  TCrackCustomComboBox(GetCustomComboBox).Sorted := Value;
end;

procedure TwrpCustomComboBox.Set_Style(Value: TgsComboBoxStyle);
begin
  TCrackCustomComboBox(GetCustomComboBox).Style := TComboBoxStyle(Value);
end;

{ TwrpScrollBar }

function TwrpScrollBar.Get_Kind: TgsScrollBarKind;
begin
  Result := TgsScrollBarKind(GetScrollBar.Kind);
end;

function TwrpScrollBar.Get_LargeChange: Smallint;
begin
  Result := Smallint(GetScrollBar.LargeChange);
end;

function TwrpScrollBar.Get_Max: Integer;
begin
  Result := GetScrollBar.Max;
end;

function TwrpScrollBar.Get_Min: Integer;
begin
  Result := GetScrollBar.Min;
end;

function TwrpScrollBar.Get_PageSize: Integer;
begin
  Result := GetScrollBar.PageSize;
end;

function TwrpScrollBar.Get_Position: Integer;
begin
  Result := GetScrollBar.Position;
end;

function TwrpScrollBar.Get_SmallChange: Smallint;
begin
  Result := Smallint(GetScrollBar.SmallChange);
end;

function TwrpScrollBar.GetScrollBar: TScrollBar;
begin
  Result := GetObject as TScrollBar;
end;

procedure TwrpScrollBar.Set_Kind(Value: TgsScrollBarKind);
begin
  GetScrollBar.Kind := TScrollBarKind(Value);
end;

procedure TwrpScrollBar.Set_LargeChange(Value: Smallint);
begin
  GetScrollBar.LargeChange := Smallint(Value);
end;

procedure TwrpScrollBar.Set_Max(Value: Integer);
begin
  GetScrollBar.Max := Value;
end;

procedure TwrpScrollBar.Set_Min(Value: Integer);
begin
  GetScrollBar.Min := Value;
end;

procedure TwrpScrollBar.Set_PageSize(Value: Integer);
begin
  GetScrollBar.PageSize := Value;
end;

procedure TwrpScrollBar.Set_Position(Value: Integer);
begin
  GetScrollBar.Position := Value;
end;

procedure TwrpScrollBar.Set_SmallChange(Value: Smallint);
begin
  GetScrollBar.SmallChange := Smallint(Value);
end;

procedure TwrpScrollBar.SetParams(APosition, AMin, AMax: Integer);
begin
  GetScrollBar.SetParams(APosition, AMin, AMax);
end;

{ TwrpCustomControl }

function TwrpCustomControl.GetCustomControl: TCustomControl;
begin
  Result := GetObject as TCustomControl;
end;

function TwrpCustomControl.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(TCrackCustomControl(GetCustomControl).Canvas) as IgsCanvas;
end;

procedure TwrpCustomControl.Paint;
begin
  TCrackCustomControl(GetCustomControl).Paint;
end;

{ TwrpCustomGroupBox }

function TwrpCustomGroupBox.GetCustomGroupBox: TCustomGroupBox;
begin
  Result := GetObject as TCustomGroupBox;
end;

{ TwrpCustomRadioGroup }

function TwrpCustomRadioGroup.GetCustomRadioGroup: TCustomRadioGroup;
begin
  Result := GetObject as TCustomRadioGroup;
end;

function TwrpCustomRadioGroup.Get_Columns: Integer;
begin
  Result := TCrackCustomRadioGroup(GetCustomRadioGroup).Columns;
end;

function TwrpCustomRadioGroup.Get_ItemIndex: Integer;
begin
  Result := TCrackCustomRadioGroup(GetCustomRadioGroup).ItemIndex;
end;

function TwrpCustomRadioGroup.Get_Items: IgsStrings;
begin
  Result := TStringsToIgsStrings(TCrackCustomRadioGroup(GetCustomRadioGroup).Items);
end;

procedure TwrpCustomRadioGroup.Set_Columns(Value: Integer);
begin
  TCrackCustomRadioGroup(GetCustomRadioGroup).Columns := Value;
end;

procedure TwrpCustomRadioGroup.Set_ItemIndex(Value: Integer);
begin
  TCrackCustomRadioGroup(GetCustomRadioGroup).ItemIndex := Value;
end;

procedure TwrpCustomRadioGroup.Set_Items(const Value: IgsStrings);
begin
  TCrackCustomRadioGroup(GetCustomRadioGroup).Items := IgsStringsToTStrings(Value);
end;

{ TwrpRadioGroup }

function TwrpRadioGroup.Get_Columns: Integer;
begin
  Result := GetRadioGroup.Columns;
end;

function TwrpRadioGroup.GetRadioGroup: TRadioGroup;
begin
  Result := GetObject as TRadioGroup;
end;

procedure TwrpRadioGroup.Set_Columns(Value: Integer);
begin
  GetRadioGroup.Columns := Value;
end;

{ TwrpPanel }

function TwrpPanel.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(GetPanel.Alignment);
end;

function TwrpPanel.Get_BorderStyle: TgsFormBorderStyle;
begin
  Result := TgsFormBorderStyle(GetPanel.BorderStyle);
end;


function TwrpPanel.Get_FullRepaint: WordBool;
begin
  Result := GetPanel.FullRepaint;
end;

function TwrpPanel.Get_Locked: WordBool;
begin
  Result := GetPanel.Locked;
end;

function TwrpPanel.GetPanel: TPanel;
begin
  Result := GetObject as TPanel;
end;

procedure TwrpPanel.Set_Alignment(Value: TgsAlignment);
begin
  GetPanel.Alignment := TAlignment(Value);
end;

procedure TwrpPanel.Set_BorderStyle(Value: TgsFormBorderStyle);
begin
  GetPanel.BorderStyle := TBorderStyle(Value);
end;


procedure TwrpPanel.Set_FullRepaint(Value: WordBool);
begin
  GetPanel.FullRepaint := Value;
end;

procedure TwrpPanel.Set_Locked(Value: WordBool);
begin
  GetPanel.Locked := Value;
end;


function TwrpPanel.Get_BevelInner: TgsPanelBevel;
begin
  Result := TgsPanelBevel(GetPanel.BevelInner);
end;

procedure TwrpPanel.Set_BevelInner(Value: TgsPanelBevel);
begin
  GetPanel.BevelInner := TPanelBevel(value);
end;

function TwrpPanel.Get_BevelOuter: TgsBevelCut;
begin
  Result := TgsPanelBevel(GetPanel.BevelOuter);
end;

procedure TwrpPanel.Set_BevelOuter(Value: TgsBevelCut);
begin
  GetPanel.BevelOuter := TPanelBevel(value);
end;

{ TwrpCustomActionList }

function TwrpCustomActionList.ExecuteAction(
  const Action: IgsContainedAction): WordBool;
begin
  Result := GetCustomActionList.ExecuteAction(InterfaceToObject(Action)
    as TBasicAction);
end;

function TwrpCustomActionList.GetCustomActionList: TCustomActionList;
begin
  Result := GetObject as TCustomActionList;
end;

function TwrpCustomActionList.Get_ActionCount: Integer;
begin
  Result :=  GetCustomActionList.ActionCount;
end;

function TwrpCustomActionList.Get_Actions(Index: Integer): IgsContainedAction;
begin
  Result := GetGdcOLEObject(GetCustomActionList.Actions[Index]) as IgsContainedAction;
end;

function TwrpCustomActionList.Get_Images: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetCustomActionList.Images) as IgsCustomImageList;
end;

procedure TwrpCustomActionList.Set_Actions(Index: Integer;
  const Value: IgsContainedAction);
begin
  GetCustomActionList.Actions[Index] := InterfaceToObject(Value) as TContainedAction;
end;

procedure TwrpCustomActionList.Set_Images(const Value: IgsCustomImageList);
begin
  GetCustomActionList.Images := InterfaceToObject(Value) as TCustomImageList;
end;

function TwrpCustomActionList.UpDateAction(
  const Action: IgsContainedAction): WordBool;
begin
  Result := GetCustomActionList.UpdateAction(InterfaceToObject(Action)
    as TBasicAction);
end;

{ TwrpActionList }

function TwrpActionList.GetActionList: TActionList;
begin
  Result := GetObject as TActionList;
end;

{ TwrpMenuItem }

procedure TwrpMenuItem.Add(const Item: IgsMenuItem);
begin
  GetMenuItem.Add(IgsMenuItemToTMenuItem(Item));
end;

procedure TwrpMenuItem.Clear;
begin
  GetMenuItem.Clear;
end;

procedure TwrpMenuItem.Click;
begin
  GetMenuItem.Clear;
end;

function TwrpMenuItem.Find(const ACaption: WideString): IgsMenuItem;
begin
  Result := TMenuItemToIgsMenuItem(GetMenuItem.Find(ACaption));
end;

function TwrpMenuItem.Get_Action: IgsBasicAction;
begin
  Result := GetGdcOLEObject(GetMenuItem.Action) as IgsBasicAction;
end;

function TwrpMenuItem.Get_AutoHotkeys: TgsMenuItemAutoFlag;
begin
  Result := TgsMenuItemAutoFlag(GetMenuItem.AutoHotKeys);
end;

function TwrpMenuItem.Get_AutoLineReduction: TgsMenuItemAutoFlag;
begin
  Result := TgsMenuItemAutoFlag(GetMenuItem.AutoLineReduction);
end;

function TwrpMenuItem.Get_Break: TgsMenuBreak;
begin
  Result := TgsMenuBreak(GetMenuItem.Break);
end;

function TwrpMenuItem.Get_Caption: WideString;
begin
  Result := GetMenuItem.Caption;
end;

function TwrpMenuItem.Get_Checked: WordBool;
begin
  Result := GetMenuItem.Checked;
end;

function TwrpMenuItem.Get_Command: Word;
begin
  Result := GetMenuItem.Command;
end;

function TwrpMenuItem.Get_Count: Integer;
begin
  Result := GetMenuItem.Count;
end;

function TwrpMenuItem.Get_Default: WordBool;
begin
  Result := GetMenuItem.Default;
end;

function TwrpMenuItem.Get_Enabled: WordBool;
begin
  Result := GetMenuItem.Enabled;
end;

function TwrpMenuItem.Get_GroupIndex: Integer;
begin
  Result := GetMenuItem.GroupIndex;
end;

function TwrpMenuItem.Get_Handle: Smallint;
begin
  Result := GetMenuItem.Handle;
end;

function TwrpMenuItem.Get_Hint: WideString;
begin
  Result := GetMenuItem.Hint;
end;

function TwrpMenuItem.Get_Items(Index: Integer): IgsMenuItem;
begin
  Result := TMenuItemToIgsMenuItem(GetMenuItem.Items[Index]);
end;

function TwrpMenuItem.Get_MenuIndex: Integer;
begin
  Result := GetMenuItem.MenuIndex;
end;

function TwrpMenuItem.Get_Parent: IgsMenuItem;
begin
  Result := TMenuItemToIgsMenuItem(GetMenuItem.Parent);
end;

function TwrpMenuItem.Get_RadioItem: WordBool;
begin
  Result := GetMenuItem.RadioItem;
end;

function TwrpMenuItem.Get_ShortCut: Smallint;
begin
  Result := TShortCut(GetMenuItem.ShortCut);
end;

function TwrpMenuItem.Get_Visible: WordBool;
begin
  Result := GetMenuItem.Visible;
end;

function TwrpMenuItem.GetMenuItem: TMenuItem;
begin
  Result := GetObject as TMenuItem;
end;

function TwrpMenuItem.IndexOf(const Item: IgsMenuItem): Integer;
begin
  Result := GetMenuItem.IndexOf(IgsMenuItemToTMenuItem(Item));
end;

procedure TwrpMenuItem.InitiateAction;
begin
  GetMenuItem.InitiateAction;
end;

procedure TwrpMenuItem.Insert(Index: Integer; const Item: IgsMenuItem);
begin
  GetMenuItem.Insert(Index, IgsMenuItemToTMenuItem(Item));
end;

function TwrpMenuItem.InsertNewLineAfter(
  const AnItem: IgsMenuItem): Integer;
begin
  Result := GetMenuItem.InsertNewLineAfter(IgsMenuItemToTMenuItem(AnItem));
end;

function TwrpMenuItem.InsertNewLineBefore(
  const AnItem: IgsMenuItem): Integer;
begin
  Result := GetMenuItem.InsertNewLineBefore(IgsMenuItemToTMenuItem(AnItem));
end;

function TwrpMenuItem.IsLine: WordBool;
begin
  Result := GetMenuItem.IsLine;
end;

function TwrpMenuItem.NewBottomLine: Integer;
begin
  Result := GetMenuItem.NewBottomLine;
end;

function TwrpMenuItem.NewTopLine: Integer;
begin
  Result := GetMenuItem.NewTopLine;
end;

procedure TwrpMenuItem.Remove(const Item: IgsMenuItem);
begin
  GetMenuItem.Remove(IgsMenuItemToTMenuItem(Item));
end;

function TwrpMenuItem.RethinkHotkeys: WordBool;
begin
  Result := GetMenuItem.RethinkHotkeys;
end;

function TwrpMenuItem.RethinkLines: WordBool;
begin
  Result := GetMenuItem.RethinkLines;
end;

procedure TwrpMenuItem.Set_Action(const Value: IgsBasicAction);
begin
  GetMenuItem.Action := InterfaceToObject(Value) as TBasicAction;
end;

procedure TwrpMenuItem.Set_AutoHotkeys(Value: TgsMenuItemAutoFlag);
begin
  GetMenuItem.AutoHotkeys := TMenuItemAutoFlag(Value);
end;

procedure TwrpMenuItem.Set_AutoLineReduction(Value: TgsMenuItemAutoFlag);
begin
  GetMenuItem.AutoLineReduction := TMenuItemAutoFlag(Value);
end;

procedure TwrpMenuItem.Set_Break(Value: TgsMenuBreak);
begin
  GetMenuItem.Break := TMenuBreak(Value);
end;

procedure TwrpMenuItem.Set_Caption(const Value: WideString);
begin
  GetMenuItem.Caption := Value;
end;

procedure TwrpMenuItem.Set_Checked(Value: WordBool);
begin
  GetMenuItem.Checked := Value;
end;

procedure TwrpMenuItem.Set_Default(Value: WordBool);
begin
  GetMenuItem.Default := Value;
end;

procedure TwrpMenuItem.Set_Enabled(Value: WordBool);
begin
  GetMenuItem.Enabled := Value;
end;

procedure TwrpMenuItem.Set_GroupIndex(Value: Integer);
begin
  GetMenuItem.GroupIndex := Value;
end;

procedure TwrpMenuItem.Set_Hint(const Value: WideString);
begin
  GetMenuItem.Hint := Value;
end;

procedure TwrpMenuItem.Set_MenuIndex(Value: Integer);
begin
  GetMenuItem.MenuIndex := Value;
end;

procedure TwrpMenuItem.Set_RadioItem(Value: WordBool);
begin
  GetMenuItem.RadioItem := Value;
end;

procedure TwrpMenuItem.Set_ShortCut(Value: Smallint);
begin
  GetMenuItem.ShortCut := Value;
end;

procedure TwrpMenuItem.Set_Visible(Value: WordBool);
begin
  GetMenuItem.Visible := Value;
end;

function TwrpMenuItem.IgsMenuItemToTMenuItem(
  Value: IgsMenuItem): TMenuItem;
begin
  if InterfaceToObject(Value) is TMenuItem then
    Result := TMenuItem(InterfaceToObject(Value))
  else
    raise Exception.Create('Передан некорректный интерфейс');
end;

function TwrpMenuItem.TMenuItemToIgsMenuItem(
  Value: TMenuItem): IgsMenuItem;
begin
  Result := GetGdcOLEObject(Value) as IgsMenuItem;
end;

procedure TwrpMenuItem.Delete(Index: Integer);
begin
  GetMenuItem.Delete(Index);
end;

function TwrpMenuItem.Get_Bitmap: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetMenuItem.Bitmap) as IgsBitmap;
end;

function TwrpMenuItem.Get_HelpContext: Integer;
begin
  Result := GetMenuItem.HelpContext;
end;

function TwrpMenuItem.Get_ImageIndex: Integer;
begin
  Result := GetMenuItem.ImageIndex;
end;

function TwrpMenuItem.Get_SubMenuImages: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetMenuItem.SubMenuImages) as IgsCustomImageList;
end;

function TwrpMenuItem.GetImageList: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetMenuItem.GetImageList) as IgsCustomImageList;
end;

function TwrpMenuItem.GetParentComponent: IgsComponent;
begin
  Result := GetGdcOLEObject(GetMenuItem.GetParentComponent) as IgsComponent;
end;

function TwrpMenuItem.GetParentMenu: IgsMenu;
begin
  Result := GetGdcOLEObject(GetMenuItem.GetParentMenu) as IgsMenu;
end;

function TwrpMenuItem.HasParent: WordBool;
begin
  Result := GetMenuItem.HasParent;
end;

procedure TwrpMenuItem.Set_Bitmap(const Value: IgsBitmap);
begin
  GetMenuItem.Bitmap := InterfaceToObject(Value) as TBitmap;
end;

procedure TwrpMenuItem.Set_HelpContext(Value: Integer);
begin
  GetMenuItem.HelpContext := Value;
end;

procedure TwrpMenuItem.Set_ImageIndex(Value: Integer);
begin
  GetMenuItem.ImageIndex := Value;
end;

procedure TwrpMenuItem.Set_SubMenuImages(const Value: IgsCustomImageList);
begin
  GetMenuItem.SubMenuImages := InterfaceToObject(Value) as TCustomImageList;
end;

{ TwrpList }

procedure TwrpList.Exchange(Index1, Index2: Integer);
begin
  GetList.Exchange(Index1, Index2);
end;

function TwrpList.Expand: IgsList;
begin
  Result := GetGdcOLEObject(GetList.Expand) as IgsList;
end;

function TwrpList.Extract(Item: Integer): Integer;
begin
  Result := Integer(GetList.Extract(Pointer(Item)));
end;

function TwrpList.First: Integer;
begin
  Result := Integer(GetList.First);
end;

function TwrpList.Get_Capacity: Integer;
begin
  Result := GetList.Capacity;
end;

function TwrpList.Get_Count: Integer;
begin
  Result := GetList.Count;
end;

function TwrpList.Get_List: Integer;
begin
  Result := Integer(GetList.List);
end;
                     
function TwrpList.GetList: TList;
begin
  Result := GetObject as TList;
end;

function TwrpList.Last: Integer;
begin
  Result := Integer(GetList.Last);
end;

procedure TwrpList.Move(CurIndex, NewIndex: Integer);
begin
  GetList.Move(CurIndex, NewIndex);
end;

procedure TwrpList.Pack;
begin
  GetList.Pack;
end;

procedure TwrpList.Set_Capacity(Value: Integer);
begin
  GetList.Capacity := Value;
end;

procedure TwrpList.Set_Count(Value: Integer);
begin
  GetList.Count := Value;
end;

function TwrpList.Add(const AObject: IgsObject): Integer;
begin
  Result := GetList.Add(Pointer(InterfaceToObject(AObject)));
end;

procedure TwrpList.Clear;
begin
  GetList.Clear;
end;

procedure TwrpList.Delete(Index: Integer);
begin
  GetList.Delete(Index);
end;

function TwrpList.IndexOf(const AnObject: IgsObject): Integer;
begin
  Result := GetList.IndexOf(Pointer(InterfaceToObject(AnObject)));
end;

procedure TwrpList.Insert(Index: Integer; const AnObject: IgsObject);
begin
  GetList.Insert(Index, Pointer(InterfaceToObject(AnObject)));
end;

function TwrpList.Remove(const AnObject: IgsObject): Integer;
begin
  Result := GetList.Remove(Pointer(InterfaceToObject(AnObject)))
end;

function TwrpList.Get_Items(Index: Integer): IgsObject;
begin
  Result := GetGdcOLEObject(GetList.Items[Index]) as IgsObject;
end;

procedure TwrpList.Set_Items(Index: Integer; const Value: IgsObject);
begin
  GetList.Items[Index] := InterfaceToObject(Value);
end;

{ TwrpIBTransaction }

procedure TwrpIBTransaction.CheckAutoStop;
begin
  GetTransaction.CheckAutoStop;
end;

procedure TwrpIBTransaction.Commit;
begin
  GetTransaction.Commit;
end;

procedure TwrpIBTransaction.CommitRetaining;
begin
  GetTransaction.CommitRetaining
end;

function TwrpIBTransaction.Get_Active: WordBool;
begin
  Result := GetTransaction.Active;
end;

function TwrpIBTransaction.Get_AutoStopAction: TgsAutoStopAction;
begin
  Result := TgsAutoStopAction(GetTransaction.AutoStopAction);
end;

function TwrpIBTransaction.Get_DefaultAction: TgsTransactionAction;
begin
  Result := TgsTransactionAction(GetTransaction.DefaultAction);
end;

function TwrpIBTransaction.Get_DefaultDatabase: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetTransaction.DefaultDatabase) as IgsIBDatabase;
end;

function TwrpIBTransaction.Get_IdleTimer: Integer;
begin
  Result := GetTransaction.IdleTimer;
end;

function TwrpIBTransaction.Get_InTransaction: WordBool;
begin
  Result := GetTransaction.InTransaction;
end;

function TwrpIBTransaction.Get_Params: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetTransaction.Params);
end;

function TwrpIBTransaction.GetTransaction: TIBTransaction;
begin
  Result := GetObject as TIBTransaction;
end;

procedure TwrpIBTransaction.Rollback;
begin
  GetTransaction.Rollback;
end;

procedure TwrpIBTransaction.RollbackRetaining;
begin
  GetTransaction.RollbackRetaining;
end;

procedure TwrpIBTransaction.Set_Active(Value: WordBool);
begin
  GetTransaction.Active := Value;
end;

procedure TwrpIBTransaction.Set_AutoStopAction(Value: TgsAutoStopAction);
begin
  GetTransaction.AutoStopAction := TAutoStopAction(Value);
end;

procedure TwrpIBTransaction.Set_DefaultAction(Value: TgsTransactionAction);
begin
  GetTransaction.DefaultAction := TTransactionAction(Value);
end;

procedure TwrpIBTransaction.Set_IdleTimer(Value: Integer);
begin
  GetTransaction.IdleTimer := Value;
end;

procedure TwrpIBTransaction.Set_Params(const Value: IgsStrings);
begin
  GetTransaction.Params := IgsStringsToTStrings(Value);
end;

procedure TwrpIBTransaction.StartTransaction;
begin
  GetTransaction.StartTransaction;
end;

procedure TwrpIBTransaction.Set_DefaultDatabase(
  const Value: IgsIBDatabase);
begin
  GetTransaction.DefaultDatabase := InterfaceToObject(Value) as TIBDatabase;
end;

function TwrpIBTransaction.AddDatabase(const db: IgsIBDatabase): Integer;
begin
  Result := GetTransaction.AddDatabase(InterfaceToObject(db) as TIBDatabase);
end;

function TwrpIBTransaction.Call(ErrCode: Integer;
  RaiseError: WordBool): Integer;
begin
  Result := GetTransaction.Call(ErrCode, RaiseError);
end;

procedure TwrpIBTransaction.CheckDatabasesInList;
begin
  GetTransaction.CheckDatabasesInList;
end;

procedure TwrpIBTransaction.CheckInTransaction;
begin
  GetTransaction.CheckInTransaction;
end;

procedure TwrpIBTransaction.CheckNotInTransaction;
begin
  GetTransaction.CheckNotInTransaction;
end;

function TwrpIBTransaction.FindDatabase(const db: IgsIBDatabase): Integer;
begin
  Result := GetTransaction.FindDatabase(InterfaceToObject(db) as TIBDatabase);
end;

function TwrpIBTransaction.FindDefaultDatabase: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetTransaction.FindDefaultDatabase) as IgsIBDatabase;
end;

function TwrpIBTransaction.Get_DatabaseCount: Integer;
begin
  Result := GetTransaction.DatabaseCount;
end;

function TwrpIBTransaction.Get_Databases(Index: Integer): IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetTransaction.Databases[index]) as IgsIBDatabase;
end;

function TwrpIBTransaction.Get_HandleIsShared: WordBool;
begin
  Result := GetTransaction.HandleIsShared;
end;

function TwrpIBTransaction.Get_SQLObjectCount: Integer;
begin
  Result := GetTransaction.SQLObjectCount;
end;

function TwrpIBTransaction.Get_SQLObjects(Index: Integer): IgsIBBase;
begin
  Result := GetGdcOLEObject(GetTransaction.SQLObjects[index]) as IgsIBBase;
end;

function TwrpIBTransaction.Get_TPBLength: Smallint;
begin
  Result := GetTransaction.TPBLength;
end;

procedure TwrpIBTransaction.RemoveDatabase(Idx: Integer);
begin
  GetTransaction.RemoveDatabase(Idx);
end;

procedure TwrpIBTransaction.RemoveDatabases;
begin
  GetTransaction.RemoveDatabases;
end;

{ TwrpDataSource }

procedure TwrpDataSource.Edit;
begin
  GetDataSource.Edit;
end;

function TwrpDataSource.Get_AutoEdit: WordBool;
begin
  Result := GetDataSource.AutoEdit;
end;

function TwrpDataSource.Get_DataSet: IgsDataSet;
begin
  Result := GetGdcOLEObject(GetDataSource.DataSet) as IgsDataSet;
end;

function TwrpDataSource.Get_Enabled: WordBool;
begin
  Result := GetDataSource.Enabled;
end;

function TwrpDataSource.Get_State: TgsDataSetState;
begin
  Result := TgsDataSetState(GetDataSource.State);
end;

function TwrpDataSource.GetDataSource: TDataSource;
begin
  Result := GetObject as TDataSource;
end;

function TwrpDataSource.IsLinkedTo(const DataSet: IgsDataSet): WordBool;
begin
  Result := GetDataSource.IsLinkedTo(InterfaceToObject(DataSet) as TDataSet);
end;

procedure TwrpDataSource.Set_AutoEdit(Value: WordBool);
begin
  GetDataSource.AutoEdit := Value;
end;

procedure TwrpDataSource.Set_DataSet(const Value: IgsDataSet);
begin
  GetDataSource.DataSet := InterfaceToObject(Value) as TDataSet;
end;

procedure TwrpDataSource.Set_Enabled(Value: WordBool);
begin
  GetDataSource.Enabled := Value;
end;

{ TwrpStringList }

function TwrpStringList.Find(const S: WideString;
  var Index: OleVariant): WordBool;
var
  tmp: Integer;
begin
  tmp := Index;
  Result := GetStringList.Find(S, tmp);
  Index := tmp;
end;

function TwrpStringList.Get_Duplicates: TgsDuplicates;
begin
  Result := TgsDuplicates(GetStringList.Duplicates);
end;

function TwrpStringList.Get_Sorted: WordBool;
begin
  Result := GetStringList.Sorted;
end;

function TwrpStringList.GetStringList: TStringList;
begin
  Result := GetObject as TStringList;
end;

procedure TwrpStringList.Set_Duplicates(Value: TgsDuplicates);
begin
  GetStringList.Duplicates := TDuplicates(Value);
end;

procedure TwrpStringList.Set_Sorted(Value: WordBool);
begin
  GetStringList.Sorted := Value;
end;

procedure TwrpStringList.Sort;
begin
  GetStringList.Sort;
end;

{ TwrpContainedAction }

function TwrpContainedAction.Execute: WordBool;
begin
  Result := GetContainedAction.Execute;
end;

function TwrpContainedAction.Get_ActionList: IgsCustomActionList;
begin
  Result := GetGdcOLEObject(GetContainedAction.ActionList) as IgsCustomActionList;
end;

function TwrpContainedAction.Get_Category: WideString;
begin
  Result := GetContainedAction.Category;
end;

function TwrpContainedAction.Get_Index: Integer;
begin
  Result := GetContainedAction.Index;
end;

function TwrpContainedAction.GetContainedAction: TContainedAction;
begin
  Result := GetObject as TContainedAction;
end;

procedure TwrpContainedAction.Set_ActionList(const Value: IgsCustomActionList);
begin
  GetContainedAction.ActionList := InterfaceToObject(Value) as TCustomActionList;
end;

procedure TwrpContainedAction.Set_Category(const Value: WideString);
begin
  GetContainedAction.Category := Value;
end;

procedure TwrpContainedAction.Set_Index(Value: Integer);
begin
  GetContainedAction.Index := Value;
end;

function TwrpContainedAction.GetParentComponent: IgsComponent;
begin
  Result := GetGdcOLEObject(GetContainedAction.GetParentComponent) as IgsComponent;
end;

function TwrpContainedAction.HasParent: WordBool;
begin
  Result := GetContainedAction.HasParent;
end;

{ TwrpCustomAction }

function TwrpCustomAction.DoHint(var HintStr: OleVariant): WordBool;
var
  str: String;
begin
  str := HintStr;
  Result := GetCustomAction.DoHint(Str);
  HintStr := str;
end;

function TwrpCustomAction.Get_Caption: WideString;
begin
  Result := GetCustomAction.Caption;
end;

function TwrpCustomAction.Get_Checked: WordBool;
begin
  Result := GetCustomAction.Checked;
end;

function TwrpCustomAction.Get_DisableIfNoHandler: WordBool;
begin
  Result := GetCustomAction.DisableIfNoHandler;
end;

function TwrpCustomAction.Get_Enabled: WordBool;
begin
  Result := GetCustomAction.Enabled;
end;

function TwrpCustomAction.Get_Hint: WideString;
begin
  Result :=  GetCustomAction.Hint;
end;

function TwrpCustomAction.Get_Visible: WordBool;
begin
  Result := GetCustomAction.Visible;
end;

function TwrpCustomAction.GetCustomAction: TCustomAction;
begin
  Result := GetObject as TCustomAction;
end;

procedure TwrpCustomAction.Set_Caption(const Value: WideString);
begin
  GetCustomAction.Caption := Value;
end;

procedure TwrpCustomAction.Set_Checked(Value: WordBool);
begin
  GetCustomAction.Checked := Value;
end;

procedure TwrpCustomAction.Set_DisableIfNoHandler(Value: WordBool);
begin
  GetCustomAction.DisableIfNoHandler := Value;
end;

procedure TwrpCustomAction.Set_Enabled(Value: WordBool);
begin
  GetCustomAction.Enabled := Value;
end;

procedure TwrpCustomAction.Set_Hint(const Value: WideString);
begin
  GetCustomAction.Hint := Value;
end;

procedure TwrpCustomAction.Set_Visible(Value: WordBool);
begin
  GetCustomAction.Visible := Value;
end;

function TwrpCustomAction.Get_HelpContext: Integer;
begin
  Result := GetCustomAction.HelpContext;
end;

function TwrpCustomAction.Get_ImageIndex: Integer;
begin
  Result := GetCustomAction.ImageIndex;
end;

function TwrpCustomAction.Get_ShortCut: Word;
begin
  Result := GetCustomAction.ShortCut;
end;

procedure TwrpCustomAction.Set_HelpContext(Value: Integer);
begin
  GetCustomAction.HelpContext := Value;
end;

procedure TwrpCustomAction.Set_ImageIndex(Value: Integer);
begin
  GetCustomAction.ImageIndex := Value;
end;

procedure TwrpCustomAction.Set_ShortCut(Value: Word);
begin
  GetCustomAction.ShortCut := Value;
end;

{ TwrpIBDataSet }

procedure TwrpIBDataSet.ExecSQL;
begin
  GetIBDataSet.ExecSQL;
end;

function TwrpIBDataSet.Get_Prepared: WordBool;
begin
  Result := GetIBDataSet.Prepared;
end;

function TwrpIBDataSet.GetIBDataSet: TIBDataSet;
begin
  Result := GetObject as TIBDataSet;
end;

procedure TwrpIBDataSet.InternalOpen;
begin
  TCrackIBDataSet(GetIBDataSet).InternalOpen;
end;

function TwrpIBDataSet.ParamByName(const Idx: WideString): IgsIBXSQLVAR;
begin
  Result := GetGdcOLEObject(GetIBDataSet.ParamByName(Idx)) as IgsIBXSQLVAR;
end;

procedure TwrpIBDataSet.Prepare;
begin
  GetIBDataSet.Prepare;
end;

procedure TwrpIBDataSet.PSSetCommandText(const CommandText: WideString);
begin
  TCrackIBDataSet(GetIBDataSet).PSSetCommandText(CommandText);
end;

procedure TwrpIBDataSet.SetFiltered(Value: WordBool);
begin
  TCrackIBDataSet(GetIBDataSet).SetFiltered(Value);
end;

procedure TwrpIBDataSet.UnPrepare;
begin
  GetIBDataSet.UnPrepare;
end;

function TwrpIBDataSet.Get_Trans: IgsIBTransaction;
begin
  Result := GetGDCOleObject(GetIBDataSet.Transaction) as IgsIBTransaction;
end;

procedure TwrpIBDataSet.Set_Trans(const Value: IgsIBTransaction);
begin
  GetIBDataSet.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

procedure TwrpIBDataSet.BatchInput(const InputObject: IgsIBBatchInput);
begin
  GetIBDataSet.BatchInput(InterfaceToObject(InputObject) as TIBBatchInput);
end;

procedure TwrpIBDataSet.BatchOutput(const OutputObject: IgsIBBatchOutput);
begin
  GetIBDataSet.BatchOutput(InterfaceToObject(OutputObject) as TIBBatchOutput);
end;

function TwrpIBDataSet.Get_GeneratorField: IgsIBGeneratorField;
begin
  Result := GetGdcOLEObject(GetIBDataSet.GeneratorField) as IgsIBGeneratorField;
end;

function TwrpIBDataSet.Get_QDelete: IgsIBSQL;
begin
  Result := GetGdcOLEObject(GetIBDataSet.QDelete) as IgsIBSQL;
end;

function TwrpIBDataSet.Get_QInsert: IgsIBSQL;
begin
  Result := GetGdcOLEObject(GetIBDataSet.QInsert) as IgsIBSQL;
end;

function TwrpIBDataSet.Get_QModify: IgsIBSQL;
begin
  Result := GetGdcOLEObject(GetIBDataSet.QModify) as IgsIBSQL;
end;

function TwrpIBDataSet.Get_QRefresh: IgsIBSQL;
begin
  Result := GetGdcOLEObject(GetIBDataSet.QRefresh) as IgsIBSQL;
end;

function TwrpIBDataSet.Get_QSelect: IgsIBSQL;
begin
  Result := GetGdcOLEObject(GetIBDataSet.QSelect) as IgsIBSQL;
end;

function TwrpIBDataSet.Get_StatementType: TgsIBSQLTypes;
begin
  Result := TgsIBSQLTypes(GetIBDataSet.StatementType);
end;

procedure TwrpIBDataSet.Set_GeneratorField(
  const Value: IgsIBGeneratorField);
begin
  GetIBDataSet.GeneratorField := InterfaceToObject(VarParam) as TIBGeneratorField;
end;

function TwrpIBDataSet.Get_DataSource_: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetIBDataSet.DataSource) as IgsDataSource;
end;

procedure TwrpIBDataSet.Set_DataSource(const Value: IgsDataSource);
begin
 GetIBDataSet.DataSource := InterfaceToObject(Value) as TDataSource;
end;

{ TwrpBevel }

function TwrpBevel.Get_Shape: TgsBevelShape;
begin
  Result := TgsBevelShape(GetBevel.Shape);
end;

function TwrpBevel.Get_Style: TgsBevelStyle;
begin
  Result := TgsBevelStyle(GetBevel.Style);
end;

function TwrpBevel.GetBevel: TBevel;
begin
  Result := GetObject as TBevel;
end;

procedure TwrpBevel.Set_Shape(Value: TgsBevelShape);
begin
  GetBevel.Shape := TBevelShape(Value);
end;

procedure TwrpBevel.Set_Style(Value: TgsBevelStyle);
begin
  GetBevel.Style := TBevelStyle(Value);
end;

{ TwrpCheckListBox }

function TwrpCheckListBox.Get_AllowGrayed: WordBool;
begin
  Result := GetCheckListBox.AllowGrayed;
end;

function TwrpCheckListBox.Get_Checked(Index: Integer): WordBool;
begin
  Result := GetCheckListBox.Checked[Index];
end;

function TwrpCheckListBox.Get_Flat: WordBool;
begin
  Result := GetCheckListBox.Flat;
end;

function TwrpCheckListBox.Get_ItemEnabled(Index: Integer): WordBool;
begin
  Result := GetCheckListBox.ItemEnabled[Index];
end;

function TwrpCheckListBox.Get_State(Index: Integer): TgsCheckBoxState;
begin
  Result :=  TgsCheckBoxState(GetCheckListBox.State[Index]);
end;

function TwrpCheckListBox.GetCheckListBox: TCheckListBox;
begin
  Result := GetObject as TCheckListBox;
end;

procedure TwrpCheckListBox.Set_AllowGrayed(Value: WordBool);
begin
  GetCheckListBox.AllowGrayed := Value;
end;

procedure TwrpCheckListBox.Set_Checked(Index: Integer; Value: WordBool);
begin
  GetCheckListBox.Checked[Index] := Value;
end;

procedure TwrpCheckListBox.Set_Flat(Value: WordBool);
begin
  GetCheckListBox.Flat :=  Value;
end;

procedure TwrpCheckListBox.Set_ItemEnabled(Index: Integer;
  Value: WordBool);
begin
  GetCheckListBox.ItemEnabled[Index] := Value;
end;

procedure TwrpCheckListBox.Set_State(Index: Integer;
  Value: TgsCheckBoxState);
begin
  GetCheckListBox.State[Index] := TCheckBoxState(Value);
end;

{ TwrpCustomTabControl }

function TwrpCustomTabControl.Get_HotTrack: WordBool;
begin
  Result := TCrackCustomTabControl(GetCustomTabControl).HotTrack;
end;

function TwrpCustomTabControl.Get_MultiLine: WordBool;
begin
  Result := TCrackCustomTabControl(GetCustomTabControl).MultiLine;
end;

function TwrpCustomTabControl.Get_MultiSelect: WordBool;
begin
  Result := TCrackCustomTabControl(GetCustomTabControl).MultiSelect;
end;

function TwrpCustomTabControl.Get_OwnerDraw: WordBool;
begin
  Result := TCrackCustomTabControl(GetCustomTabControl).OwnerDraw;
end;

function TwrpCustomTabControl.Get_RaggedRight: WordBool;
begin
  Result := TCrackCustomTabControl(GetCustomTabControl).RaggedRight;
end;

function TwrpCustomTabControl.Get_ScrollOpposite: WordBool;
begin
  Result := TCrackCustomTabControl(GetCustomTabControl).ScrollOpposite;
end;

function TwrpCustomTabControl.Get_Style: TgsTabStyle;
begin
  Result := TgsTabStyle(TCrackCustomTabControl(GetCustomTabControl).Style);
end;

function TwrpCustomTabControl.Get_TabHeight: Smallint;
begin
  Result := TCrackCustomTabControl(GetCustomTabControl).TabHeight;
end;

function TwrpCustomTabControl.Get_TabIndex: Integer;
begin
  Result := TCrackCustomTabControl(GetCustomTabControl).TabIndex;
end;

function TwrpCustomTabControl.Get_TabPosition: TgsTabPosition;
begin
  Result := TgsTabPosition(TCrackCustomTabControl(GetCustomTabControl).TabPosition);
end;

function TwrpCustomTabControl.Get_Tabs: IgsStrings;
begin
  Result := TStringsToIgsStrings(TCrackCustomTabControl(GetCustomTabControl).Tabs);
end;

function TwrpCustomTabControl.Get_TabWidth: Smallint;
begin
  Result := TCrackCustomTabControl(GetCustomTabControl).TabWidth;
end;

function TwrpCustomTabControl.GetCustomTabControl: TCustomTabControl;
begin
  Result := GetObject as TCustomTabControl;
end;

procedure TwrpCustomTabControl.Set_HotTrack(Value: WordBool);
begin
  TCrackCustomTabControl(GetCustomTabControl).HotTrack := Value;
end;

procedure TwrpCustomTabControl.Set_MultiLine(Value: WordBool);
begin
  TCrackCustomTabControl(GetCustomTabControl).MultiLine := Value;
end;

procedure TwrpCustomTabControl.Set_MultiSelect(Value: WordBool);
begin
  TCrackCustomTabControl(GetCustomTabControl).MultiSelect := Value;
end;

procedure TwrpCustomTabControl.Set_OwnerDraw(Value: WordBool);
begin
  TCrackCustomTabControl(GetCustomTabControl).OwnerDraw := Value;
end;

procedure TwrpCustomTabControl.Set_RaggedRight(Value: WordBool);
begin
  TCrackCustomTabControl(GetCustomTabControl).RaggedRight := Value;
end;

procedure TwrpCustomTabControl.Set_ScrollOpposite(Value: WordBool);
begin
  TCrackCustomTabControl(GetCustomTabControl).ScrollOpposite := Value;
end;

procedure TwrpCustomTabControl.Set_Style(Value: TgsTabStyle);
begin
  TCrackCustomTabControl(GetCustomTabControl).Style := TTabStyle(Value);
end;

procedure TwrpCustomTabControl.Set_TabHeight(Value: Smallint);
begin
  TCrackCustomTabControl(GetCustomTabControl).TabHeight := Value;
end;

procedure TwrpCustomTabControl.Set_TabIndex(Value: Integer);
begin
  TCrackCustomTabControl(GetCustomTabControl).TabIndex := Value;
end;

procedure TwrpCustomTabControl.Set_TabPosition(Value: TgsTabPosition);
begin
  TCrackCustomTabControl(GetCustomTabControl).TabPosition := TTabPosition(Value);
end;

procedure TwrpCustomTabControl.Set_Tabs(const Value: IgsStrings);
begin
  TCrackCustomTabControl(GetCustomTabControl).Tabs := IgsStringsToTStrings(Value);
end;

procedure TwrpCustomTabControl.Set_TabWidth(Value: Smallint);
begin
  TCrackCustomTabControl(GetCustomTabControl).TabWidth := Value;
end;

function TwrpCustomTabControl.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetCustomTabControl.Canvas) as IgsCanvas;
end;

function TwrpCustomTabControl.Get_Images: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(TCrackCustomTabControl(GetCustomTabControl).Images) as
    IgsCustomImageList;
end;

function TwrpCustomTabControl.IndexOfTabAt(X, Y: Integer): Integer;
begin
  Result := GetCustomTabControl.IndexOfTabAt(X, Y);
end;

function TwrpCustomTabControl.RowCount: Integer;
begin
  Result := GetCustomTabControl.RowCount;
end;

procedure TwrpCustomTabControl.ScrollTabs(Delta: Integer);
begin
  GetCustomTabControl.ScrollTabs(Delta);
end;

procedure TwrpCustomTabControl.Set_Images(const Value: IgsCustomImageList);
begin
  TCrackCustomTabControl(GetCustomTabControl).Images :=
    InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpCustomTabControl.TabRect(Index: Integer; out Left, Top,
  Right, Bottom: OleVariant);
begin
  Left := GetCustomTabControl.TabRect(Index).Left;
  Top := GetCustomTabControl.TabRect(Index).Top;
  Right := GetCustomTabControl.TabRect(Index).Right;
  Bottom := GetCustomTabControl.TabRect(Index).Bottom;
end;

{ TwrpPageControl }

function TwrpPageControl.CanShowTab(TabIndex: Integer): WordBool;
begin
  Result := TCrackPageControl(GetPageControl).CanShowTab(TabIndex);
end;

function TwrpPageControl.Get_ActivePageIndex: Integer;
begin
  Result := GetPageControl.ActivePageIndex;
end;

function TwrpPageControl.Get_PageCount: Integer;
begin
  Result := GetPageControl.PageCount;
end;

function TwrpPageControl.GetImageIndex(TabIndex: Integer): Integer;
begin
  Result := TCrackPageControl(GetPageControl).GetImageIndex(TabIndex);
end;

function TwrpPageControl.GetPageControl: TPageControl;
begin
  Result := GetObject as TPageControl;
end;

procedure TwrpPageControl.SelectNextPage(GoForward: WordBool);
begin
  GetPageControl.SelectNextPage(GoForward);
end;

procedure TwrpPageControl.Set_ActivePageIndex(Value: Integer);
begin
  GetPageControl.ActivePageIndex := Value;
end;

procedure TwrpPageControl.UpdateActivePage;
begin
  TCrackPageControl(GetPageControl).UpdateActivePage;
end;

function TwrpPageControl.FindNextPage(const CurPage: IgsTabSheet;
  GoForward, CheckTabVisible: WordBool): IgsTabSheet;
begin
  Result := GetGdcOLEObject(GetPageControl.FindNextPage(InterfaceToObject(CurPage) as
    TTabSheet, GoForward, CheckTabVisible)) as IgsTabSheet;
end;

function TwrpPageControl.Get_Pages(Index: Integer): IgsTabSheet;
begin
  Result := GetGdcOLEObject(GetPageControl.Pages[Index]) as IgsTabSheet;
end;

function TwrpPageControl.Get_ActivePage: IgsTabSheet;
begin
  Result := GetGdcOLEObject(GetPageControl.ActivePage) as IgsTabSheet;
end;

procedure TwrpPageControl.Set_ActivePage(const Value: IgsTabSheet);
begin
  GetPageControl.ActivePage := InterfaceToObject(Value) as TTabSheet;
end;

{ TwrpBitBtn }

function TwrpBitBtn.Get_Kind: TgsBitBtnKind;
begin
  Result := TgsBitBtnKind(GetBitBtn.Kind);
end;

function TwrpBitBtn.Get_Layout: TgsButtonLayout;
begin
  Result := TgsButtonLayout(GetBitBtn.Layout);
end;

function TwrpBitBtn.Get_Margin: Integer;
begin
  Result := GetBitBtn.Margin;
end;

function TwrpBitBtn.Get_NumGlyphs: Word;
begin
  Result := GetBitBtn.NumGlyphs;
end;

function TwrpBitBtn.Get_Spacing: Integer;
begin
  Result := GetBitBtn.Spacing;
end;

function TwrpBitBtn.Get_Style: TgsButtonStyle;
begin
  Result := TgsButtonStyle(GetBitBtn.Style);
end;

function TwrpBitBtn.GetBitBtn: TBitBtn;
begin
  Result := GetObject as TBitBtn;
end;

procedure TwrpBitBtn.Set_Kind(Value: TgsBitBtnKind);
begin
  GetBitBtn.Kind := TBitBtnKind(Value);
end;

procedure TwrpBitBtn.Set_Layout(Value: TgsButtonLayout);
begin
  GetBitBtn.Layout := TButtonLayout(Value);
end;

procedure TwrpBitBtn.Set_Margin(Value: Integer);
begin
  GetBitBtn.Margin := Value;
end;

procedure TwrpBitBtn.Set_NumGlyphs(Value: Word);
begin
  if (0 < Value) and (Value < 5) then
    GetBitBtn.NumGlyphs := Value;
end;

procedure TwrpBitBtn.Set_Spacing(Value: Integer);
begin
  GetBitBtn.Spacing := Value;
end;

procedure TwrpBitBtn.Set_Style(Value: TgsButtonStyle);
begin
  GetBitBtn.Style := TButtonStyle(Value);
end;

function TwrpBitBtn.Get_Glyph: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetBitBtn.Glyph) as IgsBitmap;
end;

procedure TwrpBitBtn.Set_Glyph(const Value: IgsBitmap);
begin
  GetBitBtn.Glyph := InterfaceToObject(Value) as TBitmap;
end;

{ TwrpSpeedButton }

procedure TwrpSpeedButton.Click;
begin
  GetSpeedButton.Click;
end;

function TwrpSpeedButton.Get_AllowAllUp: WordBool;
begin
  Result := GetSpeedButton.AllowAllUp;
end;

function TwrpSpeedButton.Get_Down: WordBool;
begin
  Result := GetSpeedButton.Down;
end;

function TwrpSpeedButton.Get_Flat: WordBool;
begin
  Result := GetSpeedButton.Flat;
end;

function TwrpSpeedButton.Get_GroupIndex: Integer;
begin
  Result := GetSpeedButton.GroupIndex;
end;

function TwrpSpeedButton.Get_Layout: TgsButtonLayout;
begin
  Result := TgsButtonLayout(GetSpeedButton.Layout);
end;

function TwrpSpeedButton.Get_Margin: Integer;
begin
  Result := GetSpeedButton.Margin;
end;

function TwrpSpeedButton.Get_MouseInControl: WordBool;
begin
  Result := TCrackSpeedButton(GetSpeedButton).MouseInControl;
end;

function TwrpSpeedButton.Get_NumGlyphs: Integer;
begin
  Result := GetSpeedButton.NumGlyphs;
end;

function TwrpSpeedButton.Get_Spacing: Integer;
begin
  Result := GetSpeedButton.Spacing;
end;

function TwrpSpeedButton.Get_Transparent: WordBool;
begin
  Result := GetSpeedButton.Transparent;
end;

function TwrpSpeedButton.GetSpeedButton: TSpeedButton;
begin
  Result := GetObject as TSpeedButton;
end;

procedure TwrpSpeedButton.Set_AllowAllUp(Value: WordBool);
begin
  GetSpeedButton.AllowAllUp := Value;
end;

procedure TwrpSpeedButton.Set_Down(Value: WordBool);
begin
  GetSpeedButton.Down := Value;
end;

procedure TwrpSpeedButton.Set_Flat(Value: WordBool);
begin
  GetSpeedButton.Flat := Value;
end;

procedure TwrpSpeedButton.Set_GroupIndex(Value: Integer);
begin
  GetSpeedButton.GroupIndex := Value;
end;

procedure TwrpSpeedButton.Set_Layout(Value: TgsButtonLayout);
begin
  GetSpeedButton.Layout := TButtonLayout(Value);
end;

procedure TwrpSpeedButton.Set_Margin(Value: Integer);
begin
  GetSpeedButton.Margin := Value;
end;

procedure TwrpSpeedButton.Set_NumGlyphs(Value: Integer);
begin
  if (0 < Value) and (Value < 5) then
    GetSpeedButton.NumGlyphs := Value;
end;

procedure TwrpSpeedButton.Set_Spacing(Value: Integer);
begin
  GetSpeedButton.Spacing := Value;
end;

procedure TwrpSpeedButton.Set_Transparent(Value: WordBool);
begin
  GetSpeedButton.Transparent := Value;
end;

function TwrpSpeedButton.Get_Glyph: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetSpeedButton.Glyph) as IgsBitmap;
end;

procedure TwrpSpeedButton.Set_Glyph(const Value: IgsBitmap);
begin
  GetSpeedButton.Glyph := InterfaceToObject(Value) as TBitmap;
end;

{ TwrpSplitter }

function TwrpSplitter.Get_AutoSnap: WordBool;
begin
  Result := GetSplitter.AutoSnap;
end;

function TwrpSplitter.Get_Beveled: WordBool;
begin
  Result := GetSplitter.Beveled;
end;

function TwrpSplitter.Get_MinSize: Integer;
begin
  Result := GetSplitter.MinSize;
end;

function TwrpSplitter.Get_ResizeStyle: TgsResizeStyle;
begin
  Result := TgsResizeStyle(GetSplitter.ResizeStyle);
end;

function TwrpSplitter.GetSplitter: TSplitter;
begin
  Result := GetObject as TSplitter;
end;

procedure TwrpSplitter.Set_AutoSnap(Value: WordBool);
begin
  GetSplitter.AutoSnap := Value;
end;

procedure TwrpSplitter.Set_Beveled(Value: WordBool);
begin
  GetSplitter.Beveled := Value;
end;

procedure TwrpSplitter.Set_MinSize(Value: Integer);
begin
  if 0 < Value then
    GetSplitter.MinSize := Value;
end;

procedure TwrpSplitter.Set_ResizeStyle(Value: TgsResizeStyle);
begin
  GetSplitter.ResizeStyle := TResizeStyle(Value);
end;

{ TwrpCustomStaticText }

function TwrpCustomStaticText.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(TCrackCustomStaticText(GetCustomStaticText).Alignment);
end;

function TwrpCustomStaticText.Get_BorderStyle: TgsStaticBorderStyle;
begin
  Result := TgsStaticBorderStyle(TCrackCustomStaticText(GetCustomStaticText).BorderStyle);
end;

function TwrpCustomStaticText.Get_FocusControl: IgsWinControl;
begin
  Result :=GetGdcOLEObject(TCrackCustomStaticText(GetCustomStaticText).FocusControl)
    as IgsWinControl;
end;

function TwrpCustomStaticText.Get_ShowAccelChar: WordBool;
begin
  Result := TCrackCustomStaticText(GetCustomStaticText).ShowAccelChar;
end;

function TwrpCustomStaticText.GetCustomStaticText: TCustomStaticText;
begin
  Result := GetObject as TCustomStaticText;
end;

procedure TwrpCustomStaticText.Set_Alignment(Value: TgsAlignment);
begin
  TCrackCustomStaticText(GetCustomStaticText).Alignment := TAlignment(Value);
end;

procedure TwrpCustomStaticText.Set_BorderStyle(
  Value: TgsStaticBorderStyle);
begin
  TCrackCustomStaticText(GetCustomStaticText).BorderStyle := TStaticBorderStyle(Value);
end;

procedure TwrpCustomStaticText.Set_FocusControl(
  const Value: IgsWinControl);
begin
  TCrackCustomStaticText(GetCustomStaticText).FocusControl :=
    InterfaceToObject(Value) as TWinControl;
end;

procedure TwrpCustomStaticText.Set_ShowAccelChar(Value: WordBool);
begin
  TCrackCustomStaticText(GetCustomStaticText).ShowAccelChar := Value;
end;

{ TwrpStatusBar }

function TwrpStatusBar.ExecuteAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetStatusBar.ExecuteAction(InterfaceToObject(Action)
    as TBasicAction);
end;

function TwrpStatusBar.Get_AutoHint: WordBool;
begin
  Result := GetStatusBar.AutoHint;
end;

function TwrpStatusBar.Get_SimplePanel: WordBool;
begin
  Result := GetStatusBar.SimplePanel;
end;

function TwrpStatusBar.Get_SimpleText: WideString;
begin
  Result := GetStatusBar.SimpleText;
end;

function TwrpStatusBar.Get_SizeGrip: WordBool;
begin
  Result := GetStatusBar.SizeGrip;
end;

function TwrpStatusBar.Get_UseSystemFont: WordBool;
begin
  Result := GetStatusBar.UseSystemFont;
end;

function TwrpStatusBar.GetStatusBar: TStatusBar;
begin
  Result := GetObject as TStatusBar;
end;

procedure TwrpStatusBar.Set_AutoHint(Value: WordBool);
begin
  GetStatusBar.AutoHint := Value;
end;

procedure TwrpStatusBar.Set_SimplePanel(Value: WordBool);
begin
  GetStatusBar.SimplePanel := Value;
end;

procedure TwrpStatusBar.Set_SimpleText(const Value: WideString);
begin
  GetStatusBar.SimpleText := Value;
end;

procedure TwrpStatusBar.Set_SizeGrip(Value: WordBool);
begin
  GetStatusBar.SizeGrip := Value;
end;

procedure TwrpStatusBar.Set_UseSystemFont(Value: WordBool);
begin
  GetStatusBar.UseSystemFont := Value;
end;

function TwrpStatusBar.Get_Panels: IgsStatusPanels;
begin
  Result := GetGdcOLEObject(GetStatusBar.Panels) as IgsStatusPanels;
end;

procedure TwrpStatusBar.Set_Panels(const Value: IgsStatusPanels);
begin
  GetStatusBar.Panels := InterfaceToObject(Value) as TStatusPanels;
end;

function TwrpStatusBar.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetStatusBar.Canvas) as IgsCanvas;
end;

{ TwrpCustomGrid }

function TwrpCustomGrid.GetCustomGrid: TCustomGrid;
begin
  Result := GetObject as TCustomGrid;
end;


function TwrpCustomGrid.Get_BorderStyle: TgsBorderStyle;
begin
  Result := TgsBorderStyle(TCrackCustomGrid(GetCustomGrid).BorderStyle);
end;

function TwrpCustomGrid.Get_Col: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).Col;
end;

function TwrpCustomGrid.Get_ColCount: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).ColCount;
end;

function TwrpCustomGrid.Get_ColWidths(Index: Integer): Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).ColWidths[Index];
end;

function TwrpCustomGrid.Get_DefaultColWidth: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).DefaultColWidth;
end;

function TwrpCustomGrid.Get_DefaultDrawing: WordBool;
begin
  Result := TCrackCustomGrid(GetCustomGrid).DefaultDrawing;
end;

function TwrpCustomGrid.Get_DefaultRowHeight: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).DefaultRowHeight;
end;

function TwrpCustomGrid.Get_EditorMode: WordBool;
begin
  Result := TCrackCustomGrid(GetCustomGrid).EditorMode;
end;

function TwrpCustomGrid.Get_FixedColor: Integer;
begin
  Result := Integer(TCrackCustomGrid(GetCustomGrid).FixedColor);
end;

function TwrpCustomGrid.Get_FixedCols: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).FixedCols;
end;

function TwrpCustomGrid.Get_FixedRows: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).FixedRows;
end;

function TwrpCustomGrid.Get_GridHeight: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).GridHeight;
end;

function TwrpCustomGrid.Get_GridLineWidth: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).GridLineWidth;
end;

function TwrpCustomGrid.Get_GridWidth: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).GridWidth;
end;

function TwrpCustomGrid.Get_LeftCol: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).LeftCol;
end;

function TwrpCustomGrid.Get_Options: WideString;
begin
  Result := ' ';
  if goFixedVertLine in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goFixedVertLine ';
  if goFixedVertLine in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goFixedVertLine ';
  if goFixedHorzLine in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goFixedHorzLine ';
  if goVertLine in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goVertLine ';
  if goHorzLine in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goHorzLine ';
  if goRangeSelect in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goRangeSelect ';
  if goDrawFocusSelected in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goDrawFocusSelected ';
  if goRowSizing in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goRowSizing ';
  if goColSizing in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goColSizing ';
  if goRowMoving in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goRowMoving ';
  if goColMoving in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goColMoving ';
  if goEditing in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goEditing ';
  if goTabs in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goTabs ';
  if goRowSelect in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goRowSelect ';
  if goAlwaysShowEditor in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goAlwaysShowEditor ';
  if goThumbTracking in TCrackCustomGrid(GetCustomGrid).Options then
    Result := Result + 'goThumbTracking ';
end;

function TwrpCustomGrid.Get_Row: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).Row;
end;

function TwrpCustomGrid.Get_RowCount: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).RowCount;
end;

function TwrpCustomGrid.Get_RowHeights(Index: Integer): Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).RowHeights[Index];
end;

function TwrpCustomGrid.Get_ScrollBars: TgsScrollStyle;
begin
  Result := TgsScrollStyle(TCrackCustomGrid(GetCustomGrid).ScrollBars);
end;

function TwrpCustomGrid.Get_TabStops(Index: Integer): WordBool;
begin
  Result := TCrackCustomGrid(GetCustomGrid).TabStops[Index];
end;

function TwrpCustomGrid.Get_TopRow: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).TopRow;
end;

function TwrpCustomGrid.Get_VisibleColCount: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).VisibleColCount;
end;

function TwrpCustomGrid.Get_VisibleRowCount: Integer;
begin
  Result := TCrackCustomGrid(GetCustomGrid).VisibleRowCount;
end;

function TwrpCustomGrid.MouseCoord(X, Y: Integer): TgsGridCoord;
begin
  Result := TgsGridCoord(TCrackCustomGrid(GetCustomGrid).MouseCoord(X, Y));
end;

procedure TwrpCustomGrid.Set_BorderStyle(Value: TgsBorderStyle);
begin
  TCrackCustomGrid(GetCustomGrid).BorderStyle := TBorderStyle(Value);
end;

procedure TwrpCustomGrid.Set_Col(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).Col := Value;
end;

procedure TwrpCustomGrid.Set_ColCount(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).ColCount := Value;
end;

procedure TwrpCustomGrid.Set_ColWidths(Index, Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).ColWidths[Index] := Value;
end;

procedure TwrpCustomGrid.Set_DefaultColWidth(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).DefaultColWidth := Value;
end;

procedure TwrpCustomGrid.Set_DefaultDrawing(Value: WordBool);
begin
  TCrackCustomGrid(GetCustomGrid).DefaultDrawing := Value;
end;

procedure TwrpCustomGrid.Set_DefaultRowHeight(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).DefaultRowHeight := Value;
end;

procedure TwrpCustomGrid.Set_EditorMode(Value: WordBool);
begin
  TCrackCustomGrid(GetCustomGrid).EditorMode := Value;
end;

procedure TwrpCustomGrid.Set_FixedColor(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).FixedColor := TColor(Value);
end;

procedure TwrpCustomGrid.Set_FixedCols(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).FixedCols := Value;
end;

procedure TwrpCustomGrid.Set_FixedRows(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).FixedRows := Value;
end;

procedure TwrpCustomGrid.Set_GridLineWidth(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).GridLineWidth := Value;
end;

procedure TwrpCustomGrid.Set_LeftCol(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).LeftCol := Value;
end;

procedure TwrpCustomGrid.Set_Options(const Value: WideString);
var
  LocOption: TGridOptions;
begin
  if Pos(UpperCase('goFixedVertLine'), UpperCase(Value)) > 0 then
    Include(LocOption, goFixedVertLine);
  if Pos(UpperCase('goFixedHorzLine'), UpperCase(Value)) > 0 then
    Include(LocOption, goFixedHorzLine);
  if Pos(UpperCase('goVertLine'), UpperCase(Value)) > 0 then
    Include(LocOption, goVertLine);
  if Pos(UpperCase('goHorzLine'), UpperCase(Value)) > 0 then
    Include(LocOption, goHorzLine);
  if Pos(UpperCase('goRangeSelect'), UpperCase(Value)) > 0 then
    Include(LocOption, goRangeSelect);
  if Pos(UpperCase('goDrawFocusSelected'), UpperCase(Value)) > 0 then
    Include(LocOption, goDrawFocusSelected);
  if Pos(UpperCase('goRowSizing'), UpperCase(Value)) > 0 then
    Include(LocOption, goRowSizing);
  if Pos(UpperCase('goColSizing'), UpperCase(Value)) > 0 then
    Include(LocOption, goColSizing);
  if Pos(UpperCase('goRowMoving'), UpperCase(Value)) > 0 then
    Include(LocOption, goRowMoving);
  if Pos(UpperCase('goColMoving'), UpperCase(Value)) > 0 then
    Include(LocOption, goColMoving);
  if Pos(UpperCase('goEditing'), UpperCase(Value)) > 0 then
    Include(LocOption, goEditing);
  if Pos(UpperCase('goTabs'), UpperCase(Value)) > 0 then
    Include(LocOption, goTabs);
  if Pos(UpperCase('goRowSelect'), UpperCase(Value)) > 0 then
    Include(LocOption, goRowSelect);
  if Pos(UpperCase('goAlwaysShowEditor'), UpperCase(Value)) > 0 then
    Include(LocOption, goAlwaysShowEditor);
  if Pos(UpperCase('goThumbTracking'), UpperCase(Value)) > 0 then
    Include(LocOption, goThumbTracking);

  TCrackCustomGrid(GetCustomGrid).Options := LocOption;
end;

procedure TwrpCustomGrid.Set_Row(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).Row := Value;
end;

procedure TwrpCustomGrid.Set_RowCount(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).RowCount := Value;
end;

procedure TwrpCustomGrid.Set_RowHeights(Index, Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).RowHeights[Index] := Value;
end;

procedure TwrpCustomGrid.Set_ScrollBars(Value: TgsScrollStyle);
begin
  TCrackCustomGrid(GetCustomGrid).ScrollBars := TScrollStyle(Value);
end;

procedure TwrpCustomGrid.Set_TabStops(Index: Integer; Value: WordBool);
begin
  TCrackCustomGrid(GetCustomGrid).TabStops[Index] := Value;
end;

procedure TwrpCustomGrid.Set_TopRow(Value: Integer);
begin
  TCrackCustomGrid(GetCustomGrid).TopRow := Value;
end;

{ TwrpDrawGrid }

function TwrpDrawGrid.GetDrawGrid: TDrawGrid;
begin
  Result := GetObject as TDrawGrid;
end;

procedure TwrpDrawGrid.MouseToCell(X, Y: Integer; var ACol: OleVariant; var ARow: OleVariant);
var
  ci, ri: Integer;
begin
  ci := ACol;
  ri := ARow;
  GetDrawGrid.MouseToCell(X, Y, ci, ri);
  ACol := ci;
  ARow := ri;
end;

{ TwrpStringGrid }

function TwrpStringGrid.Get_Cells(ACol, ARow: Integer): WideString;
begin
  Result := GetStringGrid.Cells[ACol, ARow];
end;

function TwrpStringGrid.Get_Cols(Index: Integer): IgsStrings;
begin
  Result := TStringsToIgsStrings(GetStringGrid.Cols[Index]);
end;

function TwrpStringGrid.Get_Objects(ACol, ARow: Integer): IgsObject;
begin
  Result := GetGdcOLEObject(GetStringGrid.Objects[ACol, ARow]) as IgsObject;
end;

function TwrpStringGrid.Get_Rows(Index: Integer): IgsStrings;
begin
  Result := TStringsToIgsStrings(GetStringGrid.Rows[Index]);
end;

function TwrpStringGrid.GetStringGrid: TStringGrid;
begin
  Result := GetObject as TStringGrid;
end;

procedure TwrpStringGrid.Set_Cells(ACol, ARow: Integer;
  const Value: WideString);
begin
  GetStringGrid.Cells[ACol, ARow] := Value;
end;

procedure TwrpStringGrid.Set_Cols(Index: Integer; const Value: IgsStrings);
begin
  GetStringGrid.Cols[Index] := IgsStringsToTStrings(Value);
end;

procedure TwrpStringGrid.Set_Objects(ACol, ARow: Integer;
  const Value: IgsObject);
begin
  GetStringGrid.Objects[ACol, ARow] := InterfaceToObject(Value);
end;

procedure TwrpStringGrid.Set_Rows(Index: Integer; const Value: IgsStrings);
begin
  GetStringGrid.Rows[Index] := IgsStringsToTStrings(Value);
end;

{ TwrpCustomTreeView }

function TwrpCustomTreeView.AlphaSort: WordBool;
begin
  Result := GetCustomTreeView.AlphaSort;
end;

procedure TwrpCustomTreeView.FullCollapse;
begin
  GetCustomTreeView.FullCollapse;
end;

procedure TwrpCustomTreeView.FullExpand;
begin
  GetCustomTreeView.FullExpand;
end;

function TwrpCustomTreeView.Get_AutoExpand: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).AutoExpand;
end;

function TwrpCustomTreeView.Get_BorderStyle: TgsBorderStyle;
begin
  Result := TgsBorderStyle(TCrackCustomTreeView(GetCustomTreeView).BorderStyle);
end;

function TwrpCustomTreeView.Get_ChangeDelay: Integer;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).ChangeDelay;
end;

function TwrpCustomTreeView.Get_HideSelection: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).HideSelection;
end;

function TwrpCustomTreeView.Get_HotTrack: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).HotTrack;
end;

function TwrpCustomTreeView.Get_Indent: Integer;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).Indent;
end;

function TwrpCustomTreeView.Get_ReadOnly: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).ReadOnly;
end;

function TwrpCustomTreeView.Get_RightClickSelect: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).RightClickSelect;
end;

function TwrpCustomTreeView.Get_RowSelect: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).RowSelect;
end;

function TwrpCustomTreeView.Get_ShowButtons: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).ShowButtons;
end;

function TwrpCustomTreeView.Get_ShowLines: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).ShowLines;
end;

function TwrpCustomTreeView.Get_ShowRoot: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).ShowRoot;
end;

function TwrpCustomTreeView.Get_SortType: TgsSortType;
begin
  Result := TgsSortType(TCrackCustomTreeView(GetCustomTreeView).SortType);
end;

function TwrpCustomTreeView.Get_ToolTips: WordBool;
begin
  Result := TCrackCustomTreeView(GetCustomTreeView).ToolTips;
end;

function TwrpCustomTreeView.GetCustomTreeView: TCustomTreeView;
begin
  Result := GetObject as TCustomTreeView;
end;

function TwrpCustomTreeView.IsEditing: WordBool;
begin
  Result := GetCustomTreeView.IsEditing;
end;

procedure TwrpCustomTreeView.LoadFromFile(const FileName: WideString);
begin
  GetCustomTreeView.LoadFromFile(FileName);
end;

procedure TwrpCustomTreeView.SaveToFile(const FileName: WideString);
begin
  GetCustomTreeView.SaveToFile(FileName);
end;

procedure TwrpCustomTreeView.Set_AutoExpand(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).AutoExpand := Value;
end;

procedure TwrpCustomTreeView.Set_BorderStyle(Value: TgsBorderStyle);
begin
  TCrackCustomTreeView(GetCustomTreeView).BorderStyle := TBorderStyle(Value);
end;

procedure TwrpCustomTreeView.Set_ChangeDelay(Value: Integer);
begin
  TCrackCustomTreeView(GetCustomTreeView).ChangeDelay := Value;
end;

procedure TwrpCustomTreeView.Set_HideSelection(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).HideSelection := Value;
end;

procedure TwrpCustomTreeView.Set_HotTrack(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).HotTrack := Value;
end;

procedure TwrpCustomTreeView.Set_Indent(Value: Integer);
begin
  TCrackCustomTreeView(GetCustomTreeView).Indent := Value;
end;

procedure TwrpCustomTreeView.Set_ReadOnly(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).ReadOnly := Value;
end;

procedure TwrpCustomTreeView.Set_RightClickSelect(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).RightClickSelect := Value;
end;

procedure TwrpCustomTreeView.Set_RowSelect(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).RowSelect := Value;
end;

procedure TwrpCustomTreeView.Set_ShowButtons(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).ShowButtons := Value;
end;

procedure TwrpCustomTreeView.Set_ShowLines(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).ShowLines := Value;
end;

procedure TwrpCustomTreeView.Set_ShowRoot(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).ShowRoot := Value;
end;

procedure TwrpCustomTreeView.Set_SortType(Value: TgsSortType);
begin
  TCrackCustomTreeView(GetCustomTreeView).SortType := TSortType(Value);
end;

procedure TwrpCustomTreeView.Set_ToolTips(Value: WordBool);
begin
  TCrackCustomTreeView(GetCustomTreeView).ToolTips := Value;
end;

function TwrpCustomTreeView.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetCustomTreeView.Canvas) as IgsCanvas;
end;

function TwrpCustomTreeView.Get_Images: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(TCrackCustomTreeView(GetCustomTreeView).Images) as IgsCustomImageList;
end;

function TwrpCustomTreeView.Get_StateImages: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(TCrackCustomTreeView(GetCustomTreeView).StateImages) as IgsCustomImageList;
end;

procedure TwrpCustomTreeView.Set_Images(const Value: IgsCustomImageList);
begin
  TCrackCustomTreeView(GetCustomTreeView).Images := InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpCustomTreeView.Set_StateImages(
  const Value: IgsCustomImageList);
begin
  TCrackCustomTreeView(GetCustomTreeView).StateImages := InterfaceToObject(Value) as TCustomImageList;
end;

function TwrpCustomTreeView.Get_DropTarget: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetCustomTreeView.DropTarget) as IgsTreeNode;
end;

function TwrpCustomTreeView.Get_Selected: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetCustomTreeView.Selected) as IgsTreeNode;
end;

function TwrpCustomTreeView.Get_TopItem: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetCustomTreeView.TopItem) as IgsTreeNode;
end;

function TwrpCustomTreeView.GetNodeAt(x, y: Integer): IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetCustomTreeView.GetNodeAt(x, y)) as IgsTreeNode;
end;

procedure TwrpCustomTreeView.LoadFromStream(const Stream: IgsStream);
begin
  GetCustomTreeView.LoadFromStream(InterfaceToObject(Stream) as TStream);
end;

procedure TwrpCustomTreeView.SaveToStream(const Stream: IgsStream);
begin
  GetCustomTreeView.SaveToStream(InterfaceToObject(Stream) as TStream);
end;

procedure TwrpCustomTreeView.Set_DropTarget(const Value: IgsTreeNode);
begin
  GetCustomTreeView.DropTarget := InterfaceToObject(Value) as TTreeNode;
end;

procedure TwrpCustomTreeView.Set_Selected(const Value: IgsTreeNode);
begin
  GetCustomTreeView.Selected := InterfaceToObject(Value) as TTreeNode;
end;

procedure TwrpCustomTreeView.Set_TopItem(const Value: IgsTreeNode);
begin
  GetCustomTreeView.TopItem := InterfaceToObject(Value) as TTreeNode;
end;

function TwrpCustomTreeView.Get_Items: IgsTreeNodes;
begin
  Result := GetGdcOLEObject(TCrackCustomTreeView(GetCustomTreeView).Items) as IgsTreeNodes;
end;

procedure TwrpCustomTreeView.Set_Items(const Value: IgsTreeNodes);
begin
  TCrackCustomTreeView(GetCustomTreeView).Items := InterfaceToObject(Value) as TTreeNodes;
end;

{ TwrpCustomListView }

function TwrpCustomListView.AlphaSort: WordBool;
begin
  Result := GetCustomListView.AlphaSort;
end;

procedure TwrpCustomListView.Arrange(Code: TgsListArrangement);
begin
  GetCustomListView.Arrange(TListArrangement(Code));
end;

function TwrpCustomListView.Get_AllocBy: Integer;
begin
  Result := TCrackCustomListView(GetCustomListView).AllocBy;
end;

function TwrpCustomListView.Get_BorderStyle: TgsBorderStyle;
begin
  Result := TgsBorderStyle(TCrackCustomListView(GetCustomListView).BorderStyle);
end;

function TwrpCustomListView.Get_Checkboxes: WordBool;
begin
  Result := GetCustomListView.Checkboxes;
end;

function TwrpCustomListView.Get_FlatScrollBars: WordBool;
begin
  Result := GetCustomListView.FlatScrollBars;
end;

function TwrpCustomListView.Get_FullDrag: WordBool;
begin
  Result := GetCustomListView.FullDrag;
end;

function TwrpCustomListView.Get_GridLines: WordBool;
begin
  Result := GetCustomListView.GridLines;
end;

function TwrpCustomListView.Get_HideSelection: WordBool;
begin
  Result := TCrackCustomListView(GetCustomListView).HideSelection;
end;

function TwrpCustomListView.Get_HotTrack: WordBool;
begin
  Result := GetCustomListView.HotTrack;
end;

function TwrpCustomListView.Get_HoverTime: Integer;
begin
  Result := TCrackCustomListView(GetCustomListView).HoverTime;
end;

function TwrpCustomListView.Get_MultiSelect: WordBool;
begin
  Result := TCrackCustomListView(GetCustomListView).MultiSelect;
end;

function TwrpCustomListView.Get_OwnerData: WordBool;
begin
  Result := TCrackCustomListView(GetCustomListView).OwnerData;
end;

function TwrpCustomListView.Get_ReadOnly: WordBool;
begin
  Result := TCrackCustomListView(GetCustomListView).ReadOnly;
end;

function TwrpCustomListView.Get_RowSelect: WordBool;
begin
  Result := GetCustomListView.RowSelect;
end;

function TwrpCustomListView.Get_SelCount: Integer;
begin
  Result := GetCustomListView.SelCount;
end;

function TwrpCustomListView.Get_ShowColumnHeaders: WordBool;
begin
  Result := TCrackCustomListView(GetCustomListView).ShowColumnHeaders;
end;

function TwrpCustomListView.Get_ShowWorkAreas: WordBool;
begin
  Result := TCrackCustomListView(GetCustomListView).ShowWorkAreas;
end;

function TwrpCustomListView.Get_SortType: TgsSortType;
begin
  Result := TgsSortType(TCrackCustomListView(GetCustomListView).SortType);
end;

function TwrpCustomListView.Get_ViewStyle: TgsViewStyle;
begin
  Result := TgsViewStyle(TCrackCustomListView(GetCustomListView).ViewStyle);
end;

function TwrpCustomListView.Get_VisibleRowCount: Integer;
begin
  Result := GetCustomListView.VisibleRowCount;
end;

function TwrpCustomListView.GetCustomListView: TCustomListView;
begin
  Result := GetObject as TCustomListView;
end;

function TwrpCustomListView.GetSearchString: WideString;
begin
  Result := GetCustomListView.GetSearchString;
end;

function TwrpCustomListView.IsEditing: WordBool;
begin
  Result := GetCustomListView.IsEditing;
end;

procedure TwrpCustomListView.Scroll(DX, DY: Integer);
begin
  GetCustomListView.Scroll(DX, DY);
end;

procedure TwrpCustomListView.Set_AllocBy(Value: Integer);
begin
  TCrackCustomListView(GetCustomListView).AllocBy := Value;
end;

procedure TwrpCustomListView.Set_BorderStyle(Value: TgsBorderStyle);
begin
  TCrackCustomListView(GetCustomListView).BorderStyle := TBorderStyle(Value);
end;

procedure TwrpCustomListView.Set_Checkboxes(Value: WordBool);
begin
  GetCustomListView.Checkboxes := Value;
end;

procedure TwrpCustomListView.Set_FlatScrollBars(Value: WordBool);
begin
  GetCustomListView.FlatScrollBars := Value;
end;

procedure TwrpCustomListView.Set_FullDrag(Value: WordBool);
begin
  GetCustomListView.FullDrag := Value;
end;

procedure TwrpCustomListView.Set_GridLines(Value: WordBool);
begin
  GetCustomListView.GridLines := Value;
end;

procedure TwrpCustomListView.Set_HideSelection(Value: WordBool);
begin
  TCrackCustomListView(GetCustomListView).HideSelection := Value;
end;

procedure TwrpCustomListView.Set_HotTrack(Value: WordBool);
begin
  GetCustomListView.HotTrack := Value;
end;

procedure TwrpCustomListView.Set_HoverTime(Value: Integer);
begin
  TCrackCustomListView(GetCustomListView).HoverTime := Value;
end;

procedure TwrpCustomListView.Set_MultiSelect(Value: WordBool);
begin
  TCrackCustomListView(GetCustomListView).MultiSelect := Value;
end;

procedure TwrpCustomListView.Set_OwnerData(Value: WordBool);
begin
  TCrackCustomListView(GetCustomListView).OwnerData := Value;
end;

procedure TwrpCustomListView.Set_ReadOnly(Value: WordBool);
begin
  TCrackCustomListView(GetCustomListView).ReadOnly := Value;
end;

procedure TwrpCustomListView.Set_RowSelect(Value: WordBool);
begin
  GetCustomListView.RowSelect := Value;
end;

procedure TwrpCustomListView.Set_ShowColumnHeaders(Value: WordBool);
begin
  TCrackCustomListView(GetCustomListView).ShowColumnHeaders := Value;
end;

procedure TwrpCustomListView.Set_ShowWorkAreas(Value: WordBool);
begin
  TCrackCustomListView(GetCustomListView).ShowWorkAreas := Value;
end;

procedure TwrpCustomListView.Set_SortType(Value: TgsSortType);
begin
  TCrackCustomListView(GetCustomListView).SortType := TSortType(Value);
end;

procedure TwrpCustomListView.Set_ViewStyle(Value: TgsViewStyle);
begin
  TCrackCustomListView(GetCustomListView).ViewStyle := TViewStyle(Value);
end;

function TwrpCustomListView.StringWidth(const S: WideString): Integer;
begin
  Result := GetCustomListView.StringWidth(S);
end;

procedure TwrpCustomListView.UpdateItems(FirstIndex, LastIndex: Integer);
begin
  GetCustomListView.UpdateItems(FirstIndex, LastIndex);
end;

function TwrpCustomListView.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetCustomListView.Canvas) as IgsCanvas;
end;

function TwrpCustomListView.Get_Column(Index: Integer): IgsListColumn;
begin
  Result := GetGdcOLEObject(GetCustomListView.Column[Index]) as IgsListColumn;
end;

function TwrpCustomListView.Get_DropTarget: IgsListItem;
begin
  Result := GetGdcOLEObject(GetCustomListView.DropTarget) as IgsListItem;
end;

function TwrpCustomListView.Get_ItemFocused: IgsListItem;
begin
  Result := GetGdcOLEObject(GetCustomListView.ItemFocused) as IgsListItem;
end;

function TwrpCustomListView.Get_Selected: IgsListItem;
begin
  Result := GetGdcOLEObject(GetCustomListView.Selected) as IgsListItem;
end;

function TwrpCustomListView.Get_TopItem: IgsListItem;
begin
  Result := GetGdcOLEObject(GetCustomListView.TopItem) as IgsListItem;
end;

procedure TwrpCustomListView.Set_DropTarget(const Value: IgsListItem);
begin
  GetCustomListView.DropTarget := InterfaceToObject(Value) as TListItem;
end;

procedure TwrpCustomListView.Set_ItemFocused(const Value: IgsListItem);
begin
  GetCustomListView.ItemFocused := InterfaceToObject(Value) as TListItem;
end;

procedure TwrpCustomListView.Set_Selected(const Value: IgsListItem);
begin
  GetCustomListView.Selected := InterfaceToObject(Value) as TListItem;
end;

function TwrpCustomListView.Get_Items: IgsListItems;
begin
  Result := GetGdcOLEObject(TCrackCustomListView(GetCustomListView).Items) as IgsListItems;
end;

procedure TwrpCustomListView.Set_Items(const Value: IgsListItems);
begin
  TCrackCustomListView(GetCustomListView).Items :=
    InterfaceToObject(Value) as TListItems;
end;

function TwrpCustomListView.FindCaption(StartIndex: Integer;
  const Value: WideString; Partial, Inclusive,
  Wrap: WordBool): IgsListView;
begin
  Result := GetGdcOLEObject(GetCustomListView.FindCaption(StartIndex, Value, Partial, Inclusive, Wrap)) as IgsListView;
end;

function TwrpCustomListView.FindData(StartIndex, Value: Integer; Inclusive,
  Wrap: WordBool): IgsListItem;
begin
  Result := GetGdcOLEObject(GetCustomListView.FindData(StartIndex, Pointer(Value), Inclusive, Wrap)) as IgsListItem;
end;

function TwrpCustomListView.GetItemAt(X, Y: Integer): IgsListItem;
begin
  Result := GetGdcOLEObject(GetCustomListView.GetItemAt(x, y)) as IgsListItem;
end;

function TwrpCustomListView.GetNearestItem(X, Y: Integer;
  Direction: TgsSearchDirection): IgsListItem;
var
  LPoint: TPoint;
begin
  LPoint.X := X;
  LPoint.Y := Y;
  Result := GetGdcOLEObject(GetCustomListView.GetNearestItem(LPoint, TSearchDirection(Direction))) as IgsListItem;
end;

function TwrpCustomListView.GetNextItem(const StartItem: IgsListItem;
  Direction: TgsSearchDirection; const States: WideString): IgsListItem;
var
  LStates: TItemStates;
begin
  LStates := [];
  if Pos('NONE', States) > 0 then Include(LStates, ISNONE);
  if Pos('CUT', States) > 0 then Include(LStates, ISCUT);
  if Pos('DROPHILITED', States) > 0 then Include(LStates, ISDROPHILITED);
  if Pos('FOCUSED', States) > 0 then Include(LStates, ISFOCUSED);
  if Pos('SELECTED', States) > 0 then Include(LStates, ISSELECTED);
  if Pos('ACTIVATING', States) > 0 then Include(LStates, ISACTIVATING);

  Result := GetGdcOLEObject(GetCustomListView.GetNextItem(
    InterfaceToObject(StartItem) as TListItem, TSearchDirection(Direction), LStates)) as IgsListItem;
end;

{ TwrpDBCheckBox }

function TwrpDBCheckBox.ExecuteAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBCheckBox.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBCheckBox.Get_DataField: WideString;
begin
  Result := GetDBCheckBox.DataField;
end;

function TwrpDBCheckBox.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetDBCheckBox.DataSource) as IgsDataSource;
end;

function TwrpDBCheckBox.Get_Field: IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetDBCheckBox.Field) as IgsFieldComponent;
end;

function TwrpDBCheckBox.Get_ReadOnly: WordBool;
begin
  Result := GetDBCheckBox.ReadOnly;
end;

function TwrpDBCheckBox.Get_ValueChecked: WideString;
begin
  Result := GetDBCheckBox.ValueChecked;
end;

function TwrpDBCheckBox.Get_ValueUnchecked: WideString;
begin
  Result := GetDBCheckBox.ValueUnchecked;
end;

function TwrpDBCheckBox.GetDBCheckBox: TDBCheckBox;
begin
  Result := GetObject as TDBCheckBox;
end;

procedure TwrpDBCheckBox.Set_DataField(const Value: WideString);
begin
  GetDBCheckBox.DataField := Value;
end;

procedure TwrpDBCheckBox.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBCheckBox.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpDBCheckBox.Set_ReadOnly(Value: WordBool);
begin
  GetDBCheckBox.ReadOnly := Value;
end;

procedure TwrpDBCheckBox.Set_ValueChecked(const Value: WideString);
begin
  GetDBCheckBox.ValueChecked := Value;
end;

procedure TwrpDBCheckBox.Set_ValueUnchecked(const Value: WideString);
begin
  GetDBCheckBox.ValueUnchecked := Value;
end;

function TwrpDBCheckBox.UpdateAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBCheckBox.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

{ TwrpDBComboBox }

function TwrpDBComboBox.ExecuteAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBComboBox.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBComboBox.Get_DataField: WideString;
begin
  Result := GetDBComboBox.DataField;
end;

function TwrpDBComboBox.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetDBComboBox.DataSource) as IgsDataSource;
end;

function TwrpDBComboBox.Get_Field: IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetDBComboBox.Field) as IgsFieldComponent;
end;

function TwrpDBComboBox.Get_ReadOnly: WordBool;
begin
  Result := GetDBComboBox.ReadOnly;
end;

function TwrpDBComboBox.GetDBComboBox: TDBComboBox;
begin
  Result := GetObject as TDBComboBox;
end;

procedure TwrpDBComboBox.Set_DataField(const Value: WideString);
begin
  GetDBComboBox.DataField := Value;
end;

procedure TwrpDBComboBox.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBComboBox.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpDBComboBox.Set_ReadOnly(Value: WordBool);
begin
  GetDBComboBox.ReadOnly := Value;
end;

function TwrpDBComboBox.UpdateAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBComboBox.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

{ TwrpCustomMaskEdit }

function TwrpCustomMaskEdit.Get_EditText: WideString;
begin
  Result := GetCustomMaskEdit.EditText;
end;

function TwrpCustomMaskEdit.Get_IsMasked: WordBool;
begin
  Result := GetCustomMaskEdit.IsMasked;
end;

function TwrpCustomMaskEdit.GetCustomMaskEdit: TCustomMaskEdit;
begin
  Result := GetObject as TCustomMaskEdit;
end;

function TwrpCustomMaskEdit.GetTextLen: Integer;
begin
  Result := GetCustomMaskEdit.GetTextLen;
end;

procedure TwrpCustomMaskEdit.Set_EditText(const Value: WideString);
begin
  GetCustomMaskEdit.EditText := String(Value);
end;

procedure TwrpCustomMaskEdit.ValidateEdit;
begin
  GetCustomMaskEdit.ValidateEdit;
end;

function TwrpCustomMaskEdit.Get_EditMask: WideString;
begin
  Result := TCrackCustomMaskEdit(GetCustomMaskEdit).EditMask;
end;

procedure TwrpCustomMaskEdit.Set_EditMask(const Value: WideString);
begin
  TCrackCustomMaskEdit(GetCustomMaskEdit).EditMask := Value;
end;

function TwrpCustomMaskEdit.Get_Text: WideString;
begin
  Result := GetCustomMaskEdit.Text;
end;

procedure TwrpCustomMaskEdit.Set_Text(const Value: WideString);
begin
  GetCustomMaskEdit.Text := Value;
end;

{ TwrpDBEdit }

function TwrpDBEdit.ExecuteAction(const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBEdit.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBEdit.Get_DataField: WideString;
begin
  Result := GetDBEdit.DataField;
end;

function TwrpDBEdit.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetDBEdit.DataSource) as IgsDataSource;
end;

function TwrpDBEdit.Get_Field: IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetDBEdit.Field) as IgsFieldComponent;
end;

function TwrpDBEdit.GetDBEdit: TDBEdit;
begin
  Result := GetObject as TDBEdit;
end;

procedure TwrpDBEdit.Set_DataField(const Value: WideString);
begin
  GetDBEdit.DataField := Value;
end;

procedure TwrpDBEdit.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBEdit.DataSource := InterfaceToObject(Value) as TDataSource;
end;

function TwrpDBEdit.UpdateAction(const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBEdit.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

{ TwrpIBSQL }

procedure TwrpIBSQL.CheckClosed;
begin
  GetIBSQL.CheckClosed;
end;

procedure TwrpIBSQL.CheckOpen;
begin
  GetIBSQL.CheckOpen;
end;

procedure TwrpIBSQL.CheckValidStatement;
begin
  GetIBSQL.CheckValidStatement;
end;

procedure TwrpIBSQL.Close;
begin
  GetIBSQL.Close;
end;

function TwrpIBSQL.Current: IgsIBXSQLDA;
begin
  Result := GetGdcOLEObject(GetIBSQL.Current) as IgsIBXSQLDA;
end;

procedure TwrpIBSQL.ExecQuery;
begin
  GetIBSQL.ExecQuery;
end;

function TwrpIBSQL.FieldByName(const FieldName: WideString): IgsIBXSQLVAR;
begin
  Result := GetGdcOLEObject(GetIBSQL.FieldByName(FieldName)) as IgsIBXSQLVAR;
end;

procedure TwrpIBSQL.FreeHandle;
begin
  GetIBSQL.FreeHandle;
end;

function TwrpIBSQL.Get_Bof: WordBool;
begin
  Result := GetIBSQL.Bof;
end;

function TwrpIBSQL.Get_Eof: WordBool;
begin
  Result := GetIBSQL.Eof;
end;

function TwrpIBSQL.Get_FieldIndex(const FieldName: WideString): Integer;
begin
  Result := GetIBSQL.FieldIndex[FieldName];
end;

function TwrpIBSQL.Get_Fields(Idx: Integer): IgsIBXSQLVAR;
begin
  Result := GetGdcOLEObject(GetIBSQL.Fields[Idx]) as IgsIBXSQLVAR;
end;

function TwrpIBSQL.Get_GenerateParamNames: WordBool;
begin
  Result := GetIBSQL.GenerateParamNames;
end;

function TwrpIBSQL.Get_GoToFirstRecordOnExecute: WordBool;
begin
  Result := GetIBSQL.GoToFirstRecordOnExecute;
end;

function TwrpIBSQL.Get_Open: WordBool;
begin
  Result := GetIBSQL.Open;
end;

function TwrpIBSQL.Get_ParamCheck: WordBool;
begin
  Result := GetIBSQL.ParamCheck;
end;

function TwrpIBSQL.Get_Params: IgsIBXSQLDA;
begin
  Result := GetGdcOLEObject(GetIBSQL.Params) as IgsIBXSQLDA;
end;

function TwrpIBSQL.Get_Plan: WideString;
begin
  Result := GetIBSQL.Plan;
end;

function TwrpIBSQL.Get_Prepared: WordBool;
begin
  Result := GetIBSQL.Prepared;
end;

function TwrpIBSQL.Get_RecordCount: Integer;
begin
  Result := GetIBSQL.RecordCount;
end;

function TwrpIBSQL.Get_RowsAffected: Integer;
begin
  Result := GetIBSQL.RowsAffected;
end;

function TwrpIBSQL.Get_SQL: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBSQL.SQL);
end;

function TwrpIBSQL.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGdcOLEObject(GetIBSQL.Transaction) as IgsIBTransaction;
end;

function TwrpIBSQL.Get_UniqueRelationName: WideString;
begin
  Result := GetIBSQL.UniqueRelationName;
end;

function TwrpIBSQL.GetIBSQL: TIBSQL;
begin
  Result := GetObject as TIBSQL;
end;

function TwrpIBSQL.GetUniqueRelationName: WideString;
begin
  Result := GetIBSQL.GetUniqueRelationName;
end;

function TwrpIBSQL.Next: IgsIBXSQLDA;
begin
  Result := GetGdcOLEObject(GetIBSQL.Next) as IgsIBXSQLDA;
end;

function TwrpIBSQL.ParamByName(const Idx: WideString): IgsIBXSQLVAR;
begin
  Result := GetGdcOLEObject(GetIBSQL.ParamByName(Idx)) as IgsIBXSQLVAR;
end;

procedure TwrpIBSQL.Prepare;
begin
  GetIBSQL.Prepare;
end;

procedure TwrpIBSQL.Set_GenerateParamNames(Value: WordBool);
begin
  GetIBSQL.GenerateParamNames := Value;
end;

procedure TwrpIBSQL.Set_GoToFirstRecordOnExecute(Value: WordBool);
begin
  GetIBSQL.GoToFirstRecordOnExecute := Value;
end;

procedure TwrpIBSQL.Set_ParamCheck(Value: WordBool);
begin
  GetIBSQL.ParamCheck := Value;
end;

procedure TwrpIBSQL.Set_SQL(const Value: IgsStrings);
begin
  GetIBSQL.SQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBSQL.Set_Transaction(const Value: IgsIBTransaction);
begin
  GetIBSQL.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

function TwrpIBSQL.Get_Database: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetIBSQL.Database) as IgsIBDatabase;
end;

procedure TwrpIBSQL.Set_Database(const Value: IgsIBDatabase);
begin
  GetIBSQL.Database := InterfaceToObject(Value) as TIBDatabase;
end;

procedure TwrpIBSQL.BatchInput(const InputObject: IgsIBBatchInput);
begin
  GetIBSQL.BatchInput(InterfaceToObject(InputObject) as TIBBatchInput);
end;

procedure TwrpIBSQL.BatchOutput(const OutputObject: IgsIBBatchOutput);
begin
  GetIBSQL.BatchOutput(InterfaceToObject(OutputObject) as TIBBatchOutput);
end;

procedure TwrpIBSQL.Call(ErrCode: Integer; RaiseError: WordBool);
begin
  GetIBSQL.Call(ErrCode, RaiseError);
end;

function TwrpIBSQL.Get_SQLType: TgsIBSQLTypes;
begin
  Result := TgsIBSQLTypes(GetIBSQL.SQLType);
end;

function TwrpIBSQL.GetAsCSVString: WideString;
var
  CSV: TgsCSVWriter;
  I: Integer;
  S: TStringStream;
  F: TIBXSQLVAR;
begin
  CSV := TgsCSVWriter.Create;
  S := TStringStream.Create('');
  try
    CSV.Stream := S;
    for I := 0 to GetIBSQL.Current.Count - 1 do
    begin
      F := GetIBSQL.Fields[I];

      if F.IsNull then
        CSV.WriteNull
      else
        case F.SQLType of
          SQL_DOUBLE, SQL_FLOAT: CSV.WriteFloat(F.AsFloat);
          SQL_SHORT:
          begin
            if (F.AsXSQLVar.sqlscale = 0) then
              CSV.WriteInteger(F.AsInteger)
            else
              CSV.WriteCurrency(F.AsCurrency);
          end;
          SQL_LONG:
          begin
            if (F.AsXSQLVar.sqlscale = 0) then
              CSV.WriteInteger(F.AsInteger)
            else
              if (F.AsXSQLVar.sqlscale >= (-4)) then
                CSV.WriteCurrency(F.AsCurrency)
              else
                CSV.WriteFloat(F.AsFloat);
          end;
          SQL_INT64:
          begin
            if (F.AsXSQLVar.sqlscale = 0) then
              CSV.WriteLargeInt(F.AsInt64)
            else
              if (F.AsXSQLVar.sqlscale >= (-4)) then
                CSV.WriteCurrency(F.AsCurrency)
              else
                CSV.WriteFloat(F.AsFloat);
          end;
          SQL_TIMESTAMP: CSV.WriteTimestamp(F.AsDateTime);
          SQL_TYPE_TIME: CSV.WriteTimestamp(F.AsDateTime);
          SQL_TYPE_DATE: CSV.WriteDate(F.AsDate);
        else
          CSV.WriteString(F.AsString);
        end;
    end;
    Result := S.DataString;
  finally
    S.Free;
    CSV.Free;
  end;
end;

{ TwrpClientDataSet }

procedure TwrpClientDataSet.AppendData(Data: OleVariant; HitEOF: WordBool);
begin
  GetClientDataSet.AppendData(Data, HitEOF);
end;

procedure TwrpClientDataSet.ApplyRange;
begin
  GetClientDataSet.ApplyRange;
end;

function TwrpClientDataSet.ApplyUpdates(MaxErrors: Integer): Integer;
begin
  Result := GetClientDataSet.ApplyUpdates(MaxErrors);
end;

procedure TwrpClientDataSet.CancelRange;
begin
  GetClientDataSet.CancelRange;
end;

procedure TwrpClientDataSet.CancelUpdates;
begin
  GetClientDataSet.CancelUpdates;
end;

function TwrpClientDataSet.ConstraintsDisabled: WordBool;
begin
  Result := GetClientDataSet.ConstraintsDisabled;
end;

procedure TwrpClientDataSet.CreateDataSet;
begin
  GetClientDataSet.CreateDataSet;
end;

function TwrpClientDataSet.DataRequest(Data: OleVariant): OleVariant;
begin
  Result := GetClientDataSet.DataRequest(Data);
end;

procedure TwrpClientDataSet.DeleteIndex(const Name: WideString);
begin
  GetClientDataSet.DeleteIndex(Name);
end;

procedure TwrpClientDataSet.DisableConstraints;
begin
  GetClientDataSet.DisableConstraints;
end;

procedure TwrpClientDataSet.EditKey;
begin
  GetClientDataSet.EditKey;
end;

procedure TwrpClientDataSet.EditRangeEnd;
begin
  GetClientDataSet.EditRangeEnd;
end;

procedure TwrpClientDataSet.EditRangeStart;
begin
  GetClientDataSet.EditRangeStart;
end;

procedure TwrpClientDataSet.EmptyDataSet;
begin
  GetClientDataSet.EmptyDataSet;
end;

procedure TwrpClientDataSet.EnableConstraints;
begin
  GetClientDataSet.EnableConstraints;
end;

procedure TwrpClientDataSet.Execute;
begin
  GetClientDataSet.Execute;
end;

procedure TwrpClientDataSet.FetchBlobs;
begin
  GetClientDataSet.FetchBlobs;
end;

procedure TwrpClientDataSet.FetchDetails;
begin
  GetClientDataSet.FetchDetails;
end;

procedure TwrpClientDataSet.FetchParams;
begin
  GetClientDataSet.FetchParams;
end;

function TwrpClientDataSet.Get_ActiveAggs(Index: Integer): IgsList;
begin
  Result := GetGDCOleObject(GetClientDataSet.ActiveAggs[Index]) as IgsList;
end;

function TwrpClientDataSet.Get_AggregatesActive: WordBool;
begin
  Result := GetClientDataSet.AggregatesActive;
end;

function TwrpClientDataSet.Get_ChangeCount: Integer;
begin
  Result := GetClientDataSet.ChangeCount;
end;

function TwrpClientDataSet.Get_CloneSource: IgsClientDataSet;
begin
  Result := GetGDCOleObject(GetClientDataSet.CloneSource) as IgsClientDataSet;
end;

function TwrpClientDataSet.Get_CommandText: WideString;
begin
  Result := GetClientDataSet.CommandText;
end;

function TwrpClientDataSet.Get_Data: OleVariant;
begin
  Result := GetClientDataSet.Data;
end;

function TwrpClientDataSet.Get_DataSize: Integer;
begin
  Result := GetClientDataSet.DataSize;
end;

function TwrpClientDataSet.Get_Delta: OleVariant;
begin
  Result := GetClientDataSet.Delta;
end;

function TwrpClientDataSet.Get_FetchOnDemand: WordBool;
begin
  Result := GetClientDataSet.FetchOnDemand;
end;

function TwrpClientDataSet.Get_FileName: WideString;
begin
  Result := GetClientDataSet.FileName;
end;

function TwrpClientDataSet.Get_GroupingLevel: Integer;
begin
  Result := GetClientDataSet.GroupingLevel;
end;

function TwrpClientDataSet.Get_HasAppServer: WordBool;
begin
  Result := GetClientDataSet.HasAppServer;
end;

function TwrpClientDataSet.Get_IndexFieldCount: Integer;
begin
  Result := GetClientDataSet.IndexFieldCount;
end;

function TwrpClientDataSet.Get_IndexFieldNames: WideString;
begin
  Result := GetClientDataSet.IndexFieldNames;
end;

function TwrpClientDataSet.Get_IndexFields(Index: Integer): IgsFieldComponent;
begin
  Result := GetGDCOleObject(GetClientDataSet.IndexFields[Index]) as IgsFieldComponent;
end;

function TwrpClientDataSet.Get_KeyExclusive: WordBool;
begin
  Result := GetClientDataSet.KeyExclusive;
end;

function TwrpClientDataSet.Get_KeyFieldCount: Integer;
begin
  Result := GetClientDataSet.KeyFieldCount;
end;

function TwrpClientDataSet.Get_KeySize: Word;
begin
  Result := GetClientDataSet.KeySize;
end;

function TwrpClientDataSet.Get_LogChanges: WordBool;
begin
  Result := GetClientDataSet.LogChanges;
end;

function TwrpClientDataSet.Get_MasterFields: WideString;
begin
  Result := GetClientDataSet.MasterFields;
end;

function TwrpClientDataSet.Get_MasterSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetClientDataSet.MasterSource) as IgsDataSource;
end;

function TwrpClientDataSet.Get_PacketRecords: Integer;
begin
  Result := GetClientDataSet.PacketRecords;
end;

function TwrpClientDataSet.Get_ProviderName: WideString;
begin
  Result := GetClientDataSet.ProviderName
end;

function TwrpClientDataSet.Get_ReadOnly: WordBool;
begin
  Result := GetClientDataSet.ReadOnly;
end;

function TwrpClientDataSet.Get_SavePoint: Integer;
begin
  Result := GetClientDataSet.SavePoint;
end;

function TwrpClientDataSet.Get_StoreDefs: WordBool;
begin
  Result := GetClientDataSet.StoreDefs;
end;

function TwrpClientDataSet.GetClientDataSet: TClientDataSet;
begin
  Result := GetObject as TClientDataSet;
end;

procedure TwrpClientDataSet.GetIndexInfo(const IndexName: WideString);
begin
  GetClientDataSet.GetIndexInfo(IndexName);
end;

procedure TwrpClientDataSet.GetIndexNames(const List: IgsStrings);
begin
  GetClientDataSet.GetIndexNames(IgsStringsToTStrings(List));
end;

function TwrpClientDataSet.GetNextPacket: Integer;
begin
  Result := GetClientDataSet.GetNextPacket;
end;

function TwrpClientDataSet.GetOptionalParam(
  const ParamName: WideString): WordBool;
begin
  Result := GetClientDataSet.GetOptionalParam(ParamName);
end;

procedure TwrpClientDataSet.GotoCurrent(const DataSet: IgsClientDataSet);
begin
  GetClientDataSet.GotoCurrent(InterfaceToObject(DataSet) as TClientDataset);
end;

function TwrpClientDataSet.GotoKey: WordBool;
begin
  Result := GetClientDataSet.GotoKey;
end;

procedure TwrpClientDataSet.GotoNearest;
begin
  GetClientDataSet.GotoNearest;
end;

procedure TwrpClientDataSet.LoadFromFile(const FileName: WideString);
begin
  GetClientDataSet.LoadFromFile(FileName);
end;

procedure TwrpClientDataSet.MergeChangeLog;
begin
  GetClientDataSet.MergeChangeLog;
end;

function TwrpClientDataSet.Reconcile(Results: OleVariant): WordBool;
begin
  Result := GetClientDataSet.Reconcile(Results);
end;

procedure TwrpClientDataSet.RefreshRecord;
begin
  GetClientDataSet.RefreshRecord;
end;

procedure TwrpClientDataSet.RevertRecord;
begin
  GetClientDataSet.RevertRecord;
end;

procedure TwrpClientDataSet.SaveToFile(const FileName: WideString;
  Format: TgsDataPacketFormat);
begin
  GetClientDataSet.SaveToFile(FileName, TDataPacketFormat(Format));
end;

procedure TwrpClientDataSet.Set_AggregatesActive(Value: WordBool);
begin
  GetClientDataSet.AggregatesActive := Value;
end;

procedure TwrpClientDataSet.Set_CommandText(const Value: WideString);
begin
  GetClientDataSet.CommandText := Value;
end;

procedure TwrpClientDataSet.Set_Data(Value: OleVariant);
begin
  GetClientDataSet.Data := Value;
end;

procedure TwrpClientDataSet.Set_FetchOnDemand(Value: WordBool);
begin
  GetClientDataSet.FetchOnDemand := Value;
end;

procedure TwrpClientDataSet.Set_FileName(const Value: WideString);
begin
  GetClientDataSet.FileName := Value;
end;

procedure TwrpClientDataSet.Set_IndexFieldNames(const Value: WideString);
begin
  GetClientDataSet.IndexFieldNames := Value;
end;

procedure TwrpClientDataSet.Set_IndexFields(Index: Integer;
  const Value: IgsFieldComponent);
begin
  GetClientDataSet.IndexFields[Index] := InterfaceToObject(Value) as TField;
end;

procedure TwrpClientDataSet.Set_KeyExclusive(Value: WordBool);
begin
  GetClientDataSet.KeyExclusive := Value;
end;

procedure TwrpClientDataSet.Set_KeyFieldCount(Value: Integer);
begin
  GetClientDataSet.KeyFieldCount := Value;
end;

procedure TwrpClientDataSet.Set_LogChanges(Value: WordBool);
begin
  GetClientDataSet.LogChanges := Value;
end;

procedure TwrpClientDataSet.Set_MasterFields(const Value: WideString);
begin
  GetClientDataSet.MasterFields := Value;
end;

procedure TwrpClientDataSet.Set_MasterSource(const Value: IgsDataSource);
begin
  GetClientDataSet.MasterSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpClientDataSet.Set_PacketRecords(Value: Integer);
begin
  GetClientDataSet.PacketRecords := Value;
end;

procedure TwrpClientDataSet.Set_ProviderName(const Value: WideString);
begin
  GetClientDataSet.ProviderName := Value;
end;

procedure TwrpClientDataSet.Set_ReadOnly(Value: WordBool);
begin
  GetClientDataSet.ReadOnly := Value;
end;

procedure TwrpClientDataSet.Set_SavePoint(Value: Integer);
begin
  GetClientDataSet.SavePoint := Value;
end;

procedure TwrpClientDataSet.Set_StoreDefs(Value: WordBool);
begin
  GetClientDataSet.StoreDefs := Value;
end;

procedure TwrpClientDataSet.SetKey;
begin
  GetClientDataSet.SetKey;
end;

procedure TwrpClientDataSet.SetOptionalParam(const ParamName: WideString;
  Value: OleVariant; IncludeInDelta: WordBool);
begin
  GetClientDataSet.SetOptionalParam(ParamName, Value, IncludeInDelta);
end;

procedure TwrpClientDataSet.SetProvider(const Provider: IgsComponent);
begin
  GetClientDataSet.SetProvider(InterfaceToObject(Provider) as TComponent);
end;

procedure TwrpClientDataSet.SetRangeEnd;
begin
  GetClientDataSet.SetRangeEnd;
end;

procedure TwrpClientDataSet.SetRangeStart;
begin
  GetClientDataSet.SetRangeStart;
end;

function TwrpClientDataSet.UndoLastChange(FollowChange: WordBool): WordBool;
begin
  Result := GetClientDataSet.UndoLastChange(FollowChange);
end;

procedure TwrpClientDataSet.CloneCursor(const Source: IgsClientDataSet; Reset,
  KeepSettings: WordBool);
begin
  GetClientDataSet.CloneCursor(InterfaceToObject(Source) as TClientDataSet, Reset, KeepSettings);
end;

procedure TwrpClientDataSet.LoadFromStream(const Stream: IgsStream);
begin
  GetClientDataSet.LoadFromStream(InterfaceToObject(Stream) as TStream);
end;

procedure TwrpClientDataSet.SaveToStream(const Stream: IgsStream;
  Format: TgsDataPacketFormat);
begin
  GetClientDataSet.SaveToStream(InterfaceToObject(Stream) as TStream, TDataPacketFormat(Format));
end;

procedure TwrpClientDataSet.AddIndex(const Name, Fields, Options, DescFields,
  CaseInsFields: WideString; GroupingLevel: Integer);
var
  IndexOptions: TIndexOptions;
begin
  IndexOptions := [];
  if Pos('PRIMARY', AnsiUpperCase(Options)) > 0 then
    Include(IndexOptions, IXPRIMARY);
  if Pos('UNIQUE', AnsiUpperCase(Options)) > 0 then
    Include(IndexOptions, IXUNIQUE);
  if Pos('DESCENDING', AnsiUpperCase(Options)) > 0 then
    Include(IndexOptions, IXDESCENDING);
  if Pos('CASEINSENSITIVE', AnsiUpperCase(Options)) > 0 then
    Include(IndexOptions, IXCASEINSENSITIVE);
  if Pos('EXPRESSION', AnsiUpperCase(Options)) > 0 then
    Include(IndexOptions, IXEXPRESSION);
  if Pos('NONMAINTAINED', AnsiUpperCase(Options)) > 0 then
    Include(IndexOptions, IXNONMAINTAINED);

  GetClientDataSet.AddIndex(Name, Fields, IndexOptions, DescFields, CaseInsFields, GroupingLevel);
end;

function TwrpClientDataSet.Get_IndexDefs: IgsIndexDefs;
begin
  Result := GetGdcOLEObject(GetClientDataSet.IndexDefs) as IgsIndexDefs;
end;

function TwrpClientDataSet.Get_IndexName: WideString;
begin
  Result := GetClientDataSet.IndexName;
end;

function TwrpClientDataSet.Get_Params: IgsParams;
begin
  Result := GetGdcOLEObject(GetClientDataSet.Params) as IgsParams;
end;

function TwrpClientDataSet.Get_StatusFilter: WideString;
begin
  Result := ' ';
  if usUnmodified in GetClientDataSet.StatusFilter then
    Result := Result + 'usUnmodified ';
  if usModified in GetClientDataSet.StatusFilter then
    Result := Result + 'usModified ';
  if usInserted in GetClientDataSet.StatusFilter then
    Result := Result + 'usInserted ';
  if usDeleted in GetClientDataSet.StatusFilter then
    Result := Result + 'usDeleted ';
end;

function TwrpClientDataSet.GetGroupState(Level: Integer): WideString;
begin
  Result := ' ';
  if gbFirst in GetClientDataSet.GetGroupState(Level) then
    Result := Result + 'gbFirst ';
  if gbMiddle in GetClientDataSet.GetGroupState(Level) then
    Result := Result + 'gbMiddle ';
  if gbLast in GetClientDataSet.GetGroupState(Level) then
    Result := Result + 'gbLast ';
end;

procedure TwrpClientDataSet.Set_Aggregates(const Value: IgsAggregates);
begin
  GetClientDataSet.Aggregates := InterfaceToObject(Value) as TAggregates;
end;

procedure TwrpClientDataSet.Set_IndexDefs(const Value: IgsIndexDefs);
begin
  GetClientDataSet.IndexDefs := InterfaceToObject(Value) as TIndexDefs;
end;

procedure TwrpClientDataSet.Set_IndexName(const Value: WideString);
begin
  GetClientDataSet.IndexName := Value;
end;

procedure TwrpClientDataSet.Set_Params(const Value: IgsParams);
begin
  GetClientDataSet.Params := InterfaceToObject(Value) as TParams;
end;

procedure TwrpClientDataSet.Set_StatusFilter(const Value: WideString);
var
  Status: TUpdateStatusSet;
begin
  Status := [];
  if Pos('UNMODIFIED', AnsiUpperCase(Value)) > 0 then
    Include(Status, USUNMODIFIED);
  if Pos('MODIFIED', AnsiUpperCase(Value)) > 0 then
    Include(Status, USMODIFIED);
  if Pos('INSERTED', AnsiUpperCase(Value)) > 0 then
    Include(Status, USINSERTED);
  if Pos('DELETED', AnsiUpperCase(Value)) > 0 then
    Include(Status, USDELETED);

  GetClientDataSet.StatusFilter := Status;
end;

function TwrpClientDataSet.Get_Aggregates: IgsAggregates;
begin
  Result := GetGdcOLEObject(GetClientDataSet.Aggregates) as IgsAggregates;
end;

{ TwrpDBImage }

procedure TwrpDBImage.CopyToClipboard;
begin
  GetDBImage.CopyToClipboard;
end;

procedure TwrpDBImage.CutToClipboard;
begin
  GetDBImage.CutToClipboard;
end;

function TwrpDBImage.ExecuteAction(const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBImage.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBImage.Get_AutoDisplay: WordBool;
begin
  Result := GetDBImage.AutoDisplay;
end;

function TwrpDBImage.Get_BorderStyle: TgsBorderStyle;
begin
  Result := TgsBorderStyle(GetDBImage.BorderStyle);
end;

function TwrpDBImage.Get_Center: WordBool;
begin
  Result := GetDBImage.Center;
end;

function TwrpDBImage.Get_DataField: WideString;
begin
  Result := GetDBImage.DataField;
end;

function TwrpDBImage.Get_DataSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetDBImage.DataSource) as IgsDataSource;
end;

function TwrpDBImage.Get_Field: IgsFieldComponent;
begin
  Result := GetGDCOleObject(GetDBImage.Field) as IgsFieldComponent;
end;

function TwrpDBImage.Get_QuickDraw: WordBool;
begin
  Result := GetDBImage.QuickDraw;
end;

function TwrpDBImage.Get_ReadOnly: WordBool;
begin
  Result := GetDBImage.ReadOnly;
end;

function TwrpDBImage.Get_Stretch: WordBool;
begin
  Result := GetDBImage.Stretch;
end;

function TwrpDBImage.GetDBImage: TDBImage;
begin
  Result := GetObject as TDBImage;
end;

procedure TwrpDBImage.LoadPicture;
begin
  GetDBImage.LoadPicture;
end;

procedure TwrpDBImage.PasteFromClipboard;
begin
  GetDBImage.PasteFromClipboard;
end;

procedure TwrpDBImage.Set_AutoDisplay(Value: WordBool);
begin
  GetDBImage.AutoDisplay := Value;
end;

procedure TwrpDBImage.Set_BorderStyle(Value: TgsBorderStyle);
begin
  GetDBImage.BorderStyle := TBorderStyle(Value);
end;

procedure TwrpDBImage.Set_Center(Value: WordBool);
begin
  GetDBImage.Center := Value;
end;

procedure TwrpDBImage.Set_DataField(const Value: WideString);
begin
  GetDBImage.DataField := Value;
end;

procedure TwrpDBImage.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBImage.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpDBImage.Set_QuickDraw(Value: WordBool);
begin
  GetDBImage.QuickDraw := Value;
end;

procedure TwrpDBImage.Set_ReadOnly(Value: WordBool);
begin
  GetDBImage.ReadOnly := Value;
end;

procedure TwrpDBImage.Set_Stretch(Value: WordBool);
begin
  GetDBImage.Stretch := Value;
end;

function TwrpDBImage.UpdateAction(const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBImage.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBImage.Get_Picture: IgsPicture;
begin
  Result := GetGDCOleObject(GetDBImage.Picture) as IgsPicture;
end;

{ TwrpDBListBox }

function TwrpDBListBox.ExecuteAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBListBox.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBListBox.Get_DataField: WideString;
begin
  Result := GetDBListBox.DataField;
end;

function TwrpDBListBox.Get_DataSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetDBListBox.DataSource) as IgsDataSource;
end;

function TwrpDBListBox.Get_Field: IgsFieldComponent;
begin
  Result := GetGDCOleObject(GetDBListBox.Field) as IgsFieldComponent;
end;

function TwrpDBListBox.Get_ReadOnly: WordBool;
begin
  Result := GetDBListBox.ReadOnly;
end;

function TwrpDBListBox.GetDBListBox: TDBListBox;
begin
  Result := GetObject as TDBListBox;
end;

procedure TwrpDBListBox.Set_DataField(const Value: WideString);
begin
  GetDBListBox.DataField := Value;
end;

procedure TwrpDBListBox.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBListBox.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpDBListBox.Set_ReadOnly(Value: WordBool);
begin
  GetDBListBox.ReadOnly := Value;
end;

function TwrpDBListBox.UpdateAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBListBox.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

{ TwrpDBMemo }

function TwrpDBMemo.ExecuteAction(const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBMemo.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBMemo.Get_AutoDisplay: WordBool;
begin
  Result := GetDBMemo.AutoDisplay;
end;

function TwrpDBMemo.Get_DataField: WideString;
begin
  Result := GetDBMemo.DataField;
end;

function TwrpDBMemo.Get_DataSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetDBMemo.DataSource) as IgsDataSource;
end;

function TwrpDBMemo.Get_Field: IgsFieldComponent;
begin
  Result := GetGDCOleObject(GetDBMemo.Field) as IgsFieldComponent;
end;

function TwrpDBMemo.GetDBMemo: TDBMemo;
begin
  Result := GetObject as TDBMemo;
end;

procedure TwrpDBMemo.LoadMemo;
begin
  GetDBMemo.LoadMemo;
end;

procedure TwrpDBMemo.Set_AutoDisplay(Value: WordBool);
begin
  GetDBMemo.AutoDisplay := Value;
end;

procedure TwrpDBMemo.Set_DataField(const Value: WideString);
begin
  GetDBMemo.DataField := Value;
end;

procedure TwrpDBMemo.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBMemo.DataSource := InterfaceToObject(Value) as TDataSource;
end;

function TwrpDBMemo.UpDateAction(const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBMemo.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

{ TwrpDBNavigator }

procedure TwrpDBNavigator.BtnClick(Index: TgsNavigateBtn);
begin
  GetDBNavigator.BtnClick(TNavigateBtn(Index));
end;

function TwrpDBNavigator.Get_ConfirmDelete: WordBool;
begin
  Result := GetDBNavigator.ConfirmDelete;
end;

function TwrpDBNavigator.Get_DataSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetDBNavigator.DataSource) as IgsDataSource;
end;

function TwrpDBNavigator.Get_Flat: WordBool;
begin
  Result := GetDBNavigator.Flat;
end;

function TwrpDBNavigator.Get_Hints: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetDBNavigator.Hints);
end;

function TwrpDBNavigator.Get_VisibleButtons: WideString;
begin
  Result := TButtonSetToStr(GetDBNavigator.VisibleButtons);
end;

function TwrpDBNavigator.GetDBNavigator: TDBNavigator;
begin
  Result := GetObject as TDBNavigator;
end;

procedure TwrpDBNavigator.Set_ConfirmDelete(Value: WordBool);
begin
  GetDBNavigator.ConfirmDelete := Value;
end;

procedure TwrpDBNavigator.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBNavigator.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpDBNavigator.Set_Flat(Value: WordBool);
begin
  GetDBNavigator.Flat := Value;
end;

procedure TwrpDBNavigator.Set_Hints(const Value: IgsStrings);
begin
  GetDBNavigator.Hints := IgsStringsToTStrings(Value);
end;

procedure TwrpDBNavigator.Set_VisibleButtons(const Value: WideString);
begin
  GetDBNavigator.VisibleButtons := StrToTButtonSet(Value);
end;

{ TwrpDBRadioGroup }

function TwrpDBRadioGroup.ExecuteAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBRadioGroup.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBRadioGroup.Get_DataField: WideString;
begin
  Result := GetDBRadioGroup.DataField;
end;

function TwrpDBRadioGroup.Get_DataSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetDBRadioGroup.DataSource) as IgsDataSource;
end;

function TwrpDBRadioGroup.Get_Field: IgsFieldComponent;
begin
  Result := GetGDCOleObject(GetDBRadioGroup.Field) as IgsFieldComponent;
end;

function TwrpDBRadioGroup.Get_ReadOnly: WordBool;
begin
  Result := GetDBRadioGroup.ReadOnly;
end;

function TwrpDBRadioGroup.Get_Value: WideString;
begin
  Result := GetDBRadioGroup.Value;
end;

function TwrpDBRadioGroup.Get_Values: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetDBRadioGroup.Values);
end;

function TwrpDBRadioGroup.GetDBRadioGroup: TDBRadioGroup;
begin
  Result := GetObject as TDBRadioGroup;
end;

procedure TwrpDBRadioGroup.Set_DataField(const Value: WideString);
begin
  GetDBRadioGroup.DataField := Value;
end;

procedure TwrpDBRadioGroup.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBRadioGroup.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpDBRadioGroup.Set_ReadOnly(Value: WordBool);
begin
  GetDBRadioGroup.ReadOnly := Value;
end;

procedure TwrpDBRadioGroup.Set_Value(const Value: WideString);
begin
  GetDBRadioGroup.Value := Value;
end;

procedure TwrpDBRadioGroup.Set_Values(const Value: IgsStrings);
begin
  GetDBRadioGroup.Values := IgsStringsToTStrings(Value);
end;

function TwrpDBRadioGroup.UpDateAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBRadioGroup.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

{ TwrpCustomRichEdit }

procedure TwrpCustomRichEdit.DoSetMaxLength(Value: Integer);
begin
  TCrackCustomRichEdit(GetCustomRichEdit).DoSetMaxLength(Value);
end;

function TwrpCustomRichEdit.Get_HideScrollBars: WordBool;
begin
  Result := TCrackCustomRichEdit(GetCustomRichEdit).HideScrollBars;
end;

function TwrpCustomRichEdit.Get_PlainText: WordBool;
begin
  Result := TCrackCustomRichEdit(GetCustomRichEdit).PlainText;
end;

function TwrpCustomRichEdit.GetCustomRichEdit: TCustomRichEdit;
begin
  Result := GetObject as TCustomRichEdit;
end;

procedure TwrpCustomRichEdit.Print(const Caption: WideString);
begin
  GetCustomRichEdit.Print(Caption);
end;

procedure TwrpCustomRichEdit.SelectionChange;
begin
  TCrackCustomRichEdit(GetCustomRichEdit).SelectionChange;
end;

procedure TwrpCustomRichEdit.Set_HideScrollBars(Value: WordBool);
begin
  TCrackCustomRichEdit(GetCustomRichEdit).HideScrollBars := Value;
end;

procedure TwrpCustomRichEdit.Set_PlainText(Value: WordBool);
begin
  TCrackCustomRichEdit(GetCustomRichEdit).PlainText := Value;
end;

function TwrpCustomRichEdit.Get_DefAttributes: IgsTextAttributes;
begin
  Result := GetGdcOLEObject(GetCustomRichEdit.DefAttributes) as IgsTextAttributes;
end;

function TwrpCustomRichEdit.Get_Paragraph: IgsParaAttributes;
begin
  Result := GetGdcOLEObject(GetCustomRichEdit.Paragraph) as IgsParaAttributes;
end;

function TwrpCustomRichEdit.Get_SelAttributes: IgsTextAttributes;
begin
  Result := GetGdcOLEObject(GetCustomRichEdit.SelAttributes) as IgsTextAttributes;
end;

procedure TwrpCustomRichEdit.Set_DefAttributes(
  const Value: IgsTextAttributes);
begin
  GetCustomRichEdit.DefAttributes := InterfaceToObject(Value) as TTextAttributes;
end;

procedure TwrpCustomRichEdit.Set_SelAttributes(
  const Value: IgsTextAttributes);
begin
  GetCustomRichEdit.SelAttributes := InterfaceToObject(Value) as TTextAttributes;
end;

{ TwrpDBRichEdit }

function TwrpDBRichEdit.ExecuteAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBRichEdit.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBRichEdit.Get_AutoDisplay: WordBool;
begin
  Result := GetDBRichEdit.AutoDisplay;
end;

function TwrpDBRichEdit.Get_DataField: WideString;
begin
  Result := GetDBRichEdit.DataField;
end;

function TwrpDBRichEdit.Get_DataSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetDBRichEdit.DataSource) as IgsDataSource;
end;

function TwrpDBRichEdit.Get_Field: IgsFieldComponent;
begin
  Result := GetGDCOleObject(GetDBRichEdit.Field) as IgsFieldComponent;
end;

function TwrpDBRichEdit.GetDBRichEdit: TDBRichEdit;
begin
  Result := GetObject as TDBRichEdit;
end;

procedure TwrpDBRichEdit.LoadMemo;
begin
  GetDBRichEdit.LoadMemo;
end;

procedure TwrpDBRichEdit.Set_AutoDisplay(Value: WordBool);
begin
  GetDBRichEdit.AutoDisplay := Value;
end;

procedure TwrpDBRichEdit.Set_DataField(const Value: WideString);
begin
  GetDBRichEdit.DataField := Value;
end;

procedure TwrpDBRichEdit.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBRichEdit.DataSource := InterfaceToObject(Value) as TDataSource;
end;

function TwrpDBRichEdit.UpDateAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBRichEdit.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

{ TwrpCustomLabel }

function TwrpCustomLabel.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(TCrackCustomLabel(GetCustomLabel).Alignment);
end;

function TwrpCustomLabel.Get_Transparent: WordBool;
begin
  Result := TCrackCustomLabel(GetCustomLabel).Transparent;
end;

function TwrpCustomLabel.GetCustomLabel: TCustomLabel;
begin
  Result := GetObject as TCustomLabel;
end;

procedure TwrpCustomLabel.Set_Alignment(Value: TgsAlignment);
begin
  TCrackCustomLabel(GetCustomLabel).Alignment := TAlignment(Value);
end;

procedure TwrpCustomLabel.Set_Transparent(Value: WordBool);
begin
  TCrackCustomLabel(GetCustomLabel).Transparent := Value;
end;

function TwrpCustomLabel.Get_FocusControl: IgsWinControl;
begin
  Result := GetGdcOLEObject(TCrackCustomLabel(GetCustomLabel).FocusControl) as IgsWinControl;
end;

function TwrpCustomLabel.Get_Layout: TgsTextLayout;
begin
  Result := TgsTextLayout(TCrackCustomLabel(GetCustomLabel).Layout);
end;

function TwrpCustomLabel.Get_ShowAccelChar: WordBool;
begin
  Result := TCrackCustomLabel(GetCustomLabel).ShowAccelChar;
end;

function TwrpCustomLabel.Get_WordWrap: WordBool;
begin
  Result := TCrackCustomLabel(GetCustomLabel).WordWrap;
end;

procedure TwrpCustomLabel.Set_FocusControl(const Value: IgsWinControl);
begin
  TCrackCustomLabel(GetCustomLabel).FocusControl := InterfaceToObject(Value) as TWinControl;
end;

procedure TwrpCustomLabel.Set_Layout(Value: TgsTextLayout);
begin
  TCrackCustomLabel(GetCustomLabel).Layout := TTextLayout(Value);
end;

procedure TwrpCustomLabel.Set_ShowAccelChar(Value: WordBool);
begin
  TCrackCustomLabel(GetCustomLabel).ShowAccelChar := Value;
end;

procedure TwrpCustomLabel.Set_WordWrap(Value: WordBool);
begin
  TCrackCustomLabel(GetCustomLabel).WordWrap := Value;
end;

{ TwrpDBText }

function TwrpDBText.ExecuteAction(const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBText.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDBText.Get_DataField: WideString;
begin
  Result := GetDBText.DataField;
end;

function TwrpDBText.Get_DataSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetDBText.DataSource) as IgsDataSource;
end;

function TwrpDBText.Get_Field: IgsFieldComponent;
begin
  Result := GetGDCOleObject(GetDBText.Field) as IgsFieldComponent;
end;

function TwrpDBText.GetDBText: TDBText;
begin
  Result := GetObject as TDBText;
end;

procedure TwrpDBText.Set_DataField(const Value: WideString);
begin
  GetDBText.DataField := Value;
end;

procedure TwrpDBText.Set_DataSource(const Value: IgsDataSource);
begin
  GetDBText.DataSource := InterfaceToObject(Value) as TDataSource;
end;

function TwrpDBText.UpDateAction(const Action: IgsBasicAction): WordBool;
begin
  Result := GetDBText.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

{ TwrpIBDatabaseInfo }

function TwrpIBDatabaseInfo.Get_Allocation: Integer;
begin
  Result := GetIBDatabaseInfo.Allocation;
end;

function TwrpIBDatabaseInfo.Get_BackoutCount: IgsStringList;
begin
  Result := GetGDCOleObject(GetIBDatabaseInfo.BackoutCount) as IgsStringList;
end;

function TwrpIBDatabaseInfo.Get_BaseLevel: Integer;
begin
  Result := GetIBDatabaseInfo.BaseLevel;
end;

function TwrpIBDatabaseInfo.Get_CurrentMemory: Integer;
begin
  Result := GetIBDatabaseInfo.CurrentMemory;
end;

function TwrpIBDatabaseInfo.Get_DBFileName: WideString;
begin
  Result := GetIBDatabaseInfo.DBFileName;
end;

function TwrpIBDatabaseInfo.Get_DBImplementationClass: Integer;
begin
  Result := GetIBDatabaseInfo.DBImplementationClass;
end;

function TwrpIBDatabaseInfo.Get_DBImplementationNo: Integer;
begin
  Result := GetIBDatabaseInfo.DBImplementationNo;
end;

function TwrpIBDatabaseInfo.Get_DBSiteName: WideString;
begin
  Result := GetIBDatabaseInfo.DBSiteName;
end;

function TwrpIBDatabaseInfo.Get_DBSQLDialect: Integer;
begin
  Result := GetIBDatabaseInfo.DBSQLDialect;
end;

function TwrpIBDatabaseInfo.Get_DeleteCount: IgsStringList;
begin
  Result := GetGDCOleObject(GetIBDatabaseInfo.DeleteCount) as IgsStringList;
end;

function TwrpIBDatabaseInfo.Get_ExpungeCount: IgsStringList;
begin
  Result := GetGDCOleObject(GetIBDatabaseInfo.ExpungeCount) as IgsStringList;
end;

function TwrpIBDatabaseInfo.Get_Fetches: Integer;
begin
  Result := GetIBDatabaseInfo.Fetches;
end;

function TwrpIBDatabaseInfo.Get_ForcedWrites: Integer;
begin
  Result := GetIBDatabaseInfo.ForcedWrites;
end;

function TwrpIBDatabaseInfo.Get_InsertCount: IgsStringList;
begin
  Result := GetGDCOleObject(GetIBDatabaseInfo.InsertCount) as IgsStringList;
end;

function TwrpIBDatabaseInfo.Get_Marks: Integer;
begin
  Result := GetIBDatabaseInfo.Marks;
end;

function TwrpIBDatabaseInfo.Get_MaxMemory: Integer;
begin
  Result := GetIBDatabaseInfo.MaxMemory;
end;

function TwrpIBDatabaseInfo.Get_NoReserve: Integer;
begin
  Result := GetIBDatabaseInfo.NoReserve;
end;

function TwrpIBDatabaseInfo.Get_NumBuffers: Integer;
begin
  Result := GetIBDatabaseInfo.NumBuffers;
end;

function TwrpIBDatabaseInfo.Get_ODSMajorVersion: Integer;
begin
  Result := GetIBDatabaseInfo.ODSMajorVersion;
end;

function TwrpIBDatabaseInfo.Get_ODSMinorVersion: Integer;
begin
  Result := GetIBDatabaseInfo.ODSMinorVersion;
end;

function TwrpIBDatabaseInfo.Get_PageSize: Integer;
begin
  Result := GetIBDatabaseInfo.PageSize;
end;

function TwrpIBDatabaseInfo.Get_PurgeCount: IgsStringList;
begin
  Result := GetGDCOleObject(GetIBDatabaseInfo.PurgeCount) as IgsStringList;
end;

function TwrpIBDatabaseInfo.Get_ReadIdxCount: IgsStringList;
begin
  Result := GetGDCOleObject(GetIBDatabaseInfo.ReadIdxCount) as IgsStringList;
end;

function TwrpIBDatabaseInfo.Get_ReadOnly: Integer;
begin
  Result := GetIBDatabaseInfo.ReadOnly;
end;

function TwrpIBDatabaseInfo.Get_Reads: Integer;
begin
  Result := GetIBDatabaseInfo.Reads;
end;

function TwrpIBDatabaseInfo.Get_ReadSeqCount: IgsStringList;
begin
  Result := GetGDCOleObject(GetIBDatabaseInfo.ReadSeqCount) as IgsStringList;
end;

function TwrpIBDatabaseInfo.Get_SweepInterval: Integer;
begin
  Result := GetIBDatabaseInfo.SweepInterval;
end;

function TwrpIBDatabaseInfo.Get_UpdateCount: IgsStringList;
begin
  Result := GetGDCOleObject(GetIBDatabaseInfo.UpdateCount) as IgsStringList;
end;

function TwrpIBDatabaseInfo.Get_Version: WideString;
begin
  Result := GetIBDatabaseInfo.Version;
end;

function TwrpIBDatabaseInfo.Get_Writes: Integer;
begin
  Result := GetIBDatabaseInfo.Writes;
end;

function TwrpIBDatabaseInfo.GetIBDatabaseInfo: TIBDatabaseInfo;
begin
  Result := GetObject as TIBDatabaseInfo;
end;

function TwrpIBDatabaseInfo.GetLongDatabaseInfo(
  DatabaseInfoCommand: Integer): Integer;
begin
  Result := GetIBDatabaseInfo.GetLongDatabaseInfo(DatabaseInfoCommand);
end;

function TwrpIBDatabaseInfo.Call(ErrCode: Integer;
  RaiseError: WordBool): Integer;
begin
  Result := GetIBDatabaseInfo.Call(ErrCode, RaiseError);
end;

function TwrpIBDatabaseInfo.Get_Database: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetIBDatabaseInfo.Database) as IgsIBDatabase;
end;

function TwrpIBDatabaseInfo.Get_UserNames: IgsStringList;
begin
  Result := GetGdcOLEObject(GetIBDatabaseInfo.UserNames) as IgsStringList;
end;

procedure TwrpIBDatabaseInfo.Set_Database(const Value: IgsIBDatabase);
begin
  GetIBDatabaseInfo.Database := InterfaceToObject(Value) as TIBDatabase;
end;

{ TwrpIBEvents }

function TwrpIBEvents.Get_AutoRegister: WordBool;
begin
  Result := GetIBEvents.AutoRegister;
end;

function TwrpIBEvents.Get_Events: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBEvents.Events);
end;

function TwrpIBEvents.Get_Registered: WordBool;
begin
  Result := GetIBEvents.Registered;
end;

function TwrpIBEvents.GetIBEvents: TIBEvents;
begin
  Result := GetObject as TIBEvents;
end;

procedure TwrpIBEvents.RegisterEvents;
begin
  GetIBEvents.RegisterEvents;
end;

procedure TwrpIBEvents.Set_AutoRegister(Value: WordBool);
begin
  GetIBEvents.AutoRegister := Value;
end;

procedure TwrpIBEvents.Set_Events(const Value: IgsStrings);
begin
  GetIBEvents.Events := IgsStringsToTStrings(Value);
end;

procedure TwrpIBEvents.Set_Registered(Value: WordBool);
begin
  GetIBEvents.Registered := Value;
end;

procedure TwrpIBEvents.UnRegisterEvents;
begin
  GetIBEvents.UnRegisterEvents
end;

function TwrpIBEvents.Get_Database: IgsIBDatabase;
begin
  Result := GetGdcOLEObject(GetIBEvents.Database) as IgsIBDatabase;
end;

procedure TwrpIBEvents.Set_Database(const Value: IgsIBDatabase);
begin
  GetIBEvents.Database := InterfaceToObject(Value) as TIBDatabase;
end;

{ TwrpCustomConnection }

procedure TwrpCustomConnection.Close;
begin
  GetCustomConnection.Close;
end;

function TwrpCustomConnection.Get_DataSetCount: Integer;
begin
  Result := GetCustomConnection.DataSetCount;
end;

function TwrpCustomConnection.Get_DataSets(Index: Integer): IgsDataSet;
begin
  Result := GetGDCOleObject(GetCustomConnection.DataSets[index]) as IgsDataSet;
end;

function TwrpCustomConnection.Get_LoginPrompt: WordBool;
begin
  Result := GetCustomConnection.LoginPrompt;
end;

function TwrpCustomConnection.GetCustomConnection: TCustomConnection;
begin
  Result := GetObject as TCustomConnection;
end;

procedure TwrpCustomConnection.Open;
begin
  GetCustomConnection.Open;
end;

procedure TwrpCustomConnection.Set_LoginPrompt(Value: WordBool);
begin
  GetCustomConnection.LoginPrompt := Value;
end;

function TwrpCustomConnection.Get_Connected: WordBool;
begin
  Result := GetCustomConnection.Connected;
end;

procedure TwrpCustomConnection.Set_Connected(Value: WordBool);
begin
  GetCustomConnection.Connected := Value;
end;

{ TwrpIBDatabase }

function TwrpIBDatabase.AddTransaction(const TR: IgsIBTransaction): Integer;
begin
  Result := GetIBDatabase.AddTransaction(InterfaceToObject(TR) as TIBTransaction);
end;

procedure TwrpIBDatabase.CheckActive;
begin
  GetIBDatabase.CheckActive;
end;

procedure TwrpIBDatabase.CheckDatabaseName;
begin
  GetIBDatabase.CheckDatabaseName;
end;

procedure TwrpIBDatabase.CheckInactive;
begin
  GetIBDatabase.CheckInactive;
end;

procedure TwrpIBDatabase.CloseDataSets;
begin
  GetIBDatabase.CloseDataSets;
end;

procedure TwrpIBDatabase.CreateDatabase;
begin
  GetIBDatabase.CreateDatabase;
end;

procedure TwrpIBDatabase.DropDatabase;
begin
  GetIBDatabase.DropDatabase;
end;

function TwrpIBDatabase.FindTransaction(const TR: IgsIBTransaction): Integer;
begin
  Result := GetIBDatabase.FindTransaction(InterfaceToObject(TR) as TIBTransaction);
end;

procedure TwrpIBDatabase.FlushSchema;
begin
  GetIBDatabase.FlushSchema;
end;

procedure TwrpIBDatabase.ForceClose;
begin
  GetIBDatabase.ForceClose;
end;

function TwrpIBDatabase.Get_AllowStreamedConnected: WordBool;
begin
  Result := GetIBDatabase.AllowStreamedConnected;
end;

function TwrpIBDatabase.Get_DatabaseName: WideString;
begin
  Result := GetIBDatabase.DatabaseName;
end;

function TwrpIBDatabase.Get_DBParamByDPB(Idx: Integer): WideString;
begin
  Result := GetIBDatabase.DBParamByDPB[Idx];
end;

function TwrpIBDatabase.Get_DBSQLDialect: Integer;
begin
  Result := GetIBDatabase.DBSQLDialect;
end;

function TwrpIBDatabase.Get_DefaultTransaction: IgsIBTransaction;
begin
  Result := GetGDCOleObject(GetIBDatabase.DefaultTransaction) as IgsIBTransaction;
end;

function TwrpIBDatabase.Get_HandleIsShared: WordBool;
begin
  Result := GetIBDatabase.HandleIsShared;
end;

function TwrpIBDatabase.Get_IdleTimer: Integer;
begin
  Result := GetIBDatabase.IdleTimer;
end;

function TwrpIBDatabase.Get_InternalTransaction: IgsIBTransaction;
begin
  Result := GetGDCOleObject(GetIBDatabase.InternalTransaction) as IgsIBTransaction;
end;

function TwrpIBDatabase.Get_IsReadOnly: WordBool;
begin
  Result := GetIBDatabase.IsReadOnly;
end;

function TwrpIBDatabase.Get_Params: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBDatabase.Params);
end;

function TwrpIBDatabase.Get_SQLDialect: Integer;
begin
  Result := GetIBDatabase.SQLDialect;
end;

function TwrpIBDatabase.Get_SQLObjectCount: Integer;
begin
  Result := GetIBDatabase.SQLObjectCount;
end;

function TwrpIBDatabase.Get_TransactionCount: Integer;
begin
  Result := GetIBDatabase.TransactionCount;
end;

function TwrpIBDatabase.Get_Transactions(Index: Integer): IgsIBTransaction;
begin
  Result := GetGDCOleObject(GetIBDatabase.Transactions[Index]) as IgsIBTransaction;
end;

procedure TwrpIBDatabase.GetFieldNames(const TableName: WideString;
  const List: IgsStrings);
begin
  GetIBDatabase.GetFieldNames(TableName, IgsStringsToTStrings(List));
end;

function TwrpIBDatabase.GetIBDatabase: TIBDatabase;
begin
  Result := GetObject as TIBDatabase;
end;

procedure TwrpIBDatabase.GetTableNames(const List: IgsStrings;
  SystemTables: WordBool);
begin
  GetIBDatabase.GetTableNames(IgsStringsToTStrings(List), SystemTables);
end;

function TwrpIBDatabase.Has_COMPUTED_BLR(const Relation,
  Field: WideString): WordBool;
begin
  Result :=  GetIBDatabase.Has_COMPUTED_BLR(Relation, Field);
end;

function TwrpIBDatabase.Has_DEFAULT_VALUE(const Relation,
  Field: WideString): WordBool;
begin
  Result :=  GetIBDatabase.Has_DEFAULT_VALUE(Relation, Field);
end;

function TwrpIBDatabase.IndexOfDBConst(const st: WideString): Integer;
begin
  Result :=  GetIBDatabase.IndexOfDBConst(st);
end;

procedure TwrpIBDatabase.RemoveTransaction(Idx: Integer);
begin
  GetIBDatabase.RemoveTransaction(Idx);
end;

procedure TwrpIBDatabase.RemoveTransactions;
begin
  GetIBDatabase.RemoveTransactions;
end;

procedure TwrpIBDatabase.Set_AllowStreamedConnected(Value: WordBool);
begin
  GetIBDatabase.AllowStreamedConnected := Value;
end;

procedure TwrpIBDatabase.Set_DatabaseName(const Value: WideString);
begin
  GetIBDatabase.DatabaseName := Value;
end;

procedure TwrpIBDatabase.Set_DBParamByDPB(Idx: Integer;
  const Value: WideString);
begin
  GetIBDatabase.DBParamByDPB[Idx] := Value;
end;

procedure TwrpIBDatabase.Set_DefaultTransaction(
  const Value: IgsIBTransaction);
begin
  GetIBDatabase.DefaultTransaction := InterfaceToObject(Value) as TIBTransaction;
end;

procedure TwrpIBDatabase.Set_IdleTimer(Value: Integer);
begin
  GetIBDatabase.IdleTimer := Value;
end;

procedure TwrpIBDatabase.Set_Params(const Value: IgsStrings);
begin
  GetIBDatabase.Params := IgsStringsToTStrings(Value);
end;

procedure TwrpIBDatabase.Set_SQLDialect(Value: Integer);
begin
  GetIBDatabase.SQLDialect := Value;
end;

function TwrpIBDatabase.TestConnected: WordBool;
begin
  Result := GetIBDatabase.TestConnected;
end;

function TwrpIBDatabase.Call(ErrCode: Integer;
  RaiseError: WordBool): Integer;
begin
  Result := GetIBDatabase.Call(ErrCode, RaiseError);
end;

function TwrpIBDatabase.FindDefaultTransaction: IgsIBTransaction;
begin
  Result := GetGdcOLEObject(GetIBDatabase.FindDefaultTransaction) as IgsIBTransaction;
end;

function TwrpIBDatabase.Get_DEFAULT_VALUE(const Relation,
  Field: WideString): WideString;
begin
  Result := GetIBDatabase.Get_DEFAULT_VALUE(Relation, Field);
end;

function TwrpIBDatabase.Get_SQLObjects(Index: Integer): IgsIBBase;
begin
  Result := GetGdcOLEObject(GetIBDatabase.SQLObjects[Index]) as IgsIBBase;
end;

{ TwrpStrings }

function TwrpStrings.Add(const S: WideString): Integer;
begin
  Result := GetStrings.Add(S);
end;

function TwrpStrings.AddObject(const S: WideString;
  const AObject: IgsObject): Integer;
begin
  Result := GetStrings.AddObject(S, InterfaceToObject(AObject));
end;

procedure TwrpStrings.AddStrings(const Strings: IgsStrings);
begin
  GetStrings.AddStrings(InterfaceToObject(Strings) as TStrings);
end;

procedure TwrpStrings.Append(const S: WideString);
begin
  GetStrings.Append(S);
end;

procedure TwrpStrings.BeginUpdate;
begin
  GetStrings.BeginUpdate;
end;

procedure TwrpStrings.Clear;
begin
  GetStrings.Clear;
end;

procedure TwrpStrings.Delete(Index: Integer);
begin
  GetStrings.Delete(Index);
end;

procedure TwrpStrings.EndUpdate;
begin
  GetStrings.EndUpdate;
end;

function TwrpStrings.Equals(const Strings: IgsStrings): WordBool;
begin
  Result := GetStrings.Equals(InterfaceToObject(Strings) as TStrings);
end;

procedure TwrpStrings.Exchange(Index1, Index2: Integer);
begin
  GetStrings.Exchange(Index1, Index2);
end;

function TwrpStrings.Get_Capacity: Integer;
begin
  Result := GetStrings.Capacity;
end;

function TwrpStrings.Get_CommaText: WideString;
begin
  Result := GetStrings.CommaText;
end;

function TwrpStrings.Get_Count: Integer;
begin
  Result := GetStrings.Count;
end;

function TwrpStrings.Get_Names(Index: Integer): WideString;
begin
  Result := GetStrings.Names[Index];
end;

function TwrpStrings.Get_Objects(Index: Integer): IgsObject;
begin
  Result := GetGDCOleObject(GetStrings.Objects[Index]) as IgsObject;
end;

function TwrpStrings.Get_Strings(Index: Integer): WideString;
begin
  Result := GetStrings.Strings[Index];
end;

function TwrpStrings.Get_Text: WideString;
begin
  Result := GetStrings.Text;
end;

function TwrpStrings.Get_Values(const Name: WideString): WideString;
begin
  Result := GetStrings.Values[Name];
end;

function TwrpStrings.GetStrings: TStrings;
begin
  Result := GetObject as TStrings;
end;

function TwrpStrings.IndexOf(const S: WideString): Integer;
begin
  Result := GetStrings.IndexOf(S);
end;

function TwrpStrings.IndexOfName(const Name: WideString): Integer;
begin
  Result := GetStrings.IndexOfName(Name);
end;

function TwrpStrings.IndexOfObject(const AObject: IgsObject): Integer;
begin
  Result := GetStrings.IndexOfObject(InterfaceToObject(AObject));
end;

procedure TwrpStrings.Insert(Index: Integer; const S: WideString);
begin
  GetStrings.Insert(Index, S);
end;

procedure TwrpStrings.InsertObject(Index: Integer; const S: WideString;
  const AObject: IgsObject);
begin
  GetStrings.InsertObject(Index, S, InterfaceToObject(AObject));
end;

procedure TwrpStrings.LoadFromFile(const FileName: WideString);
begin
  GetStrings.LoadFromFile(FileName);
end;

procedure TwrpStrings.Move(CurIndex, NewIndex: Integer);
begin
  GetStrings.Move(CurIndex, NewIndex);
end;

procedure TwrpStrings.SaveToFile(const NameFile: WideString);
begin
  GetStrings.SaveToFile(NameFile);
end;

procedure TwrpStrings.Set_Capacity(Value: Integer);
begin
  GetStrings.Capacity := Value;
end;

procedure TwrpStrings.Set_CommaText(const Value: WideString);
begin
  GetStrings.CommaText := Value;
end;

procedure TwrpStrings.Set_Objects(Index: Integer; const Value: IgsObject);
begin
  GetStrings.Objects[Index] := InterfaceToObject(Value);
end;

procedure TwrpStrings.Set_Strings(Index: Integer; const Value: WideString);
begin
  GetStrings.Strings[Index] := Value;
end;

procedure TwrpStrings.Set_Text(const Value: WideString);
begin
  GetStrings.Text := Value;
end;

procedure TwrpStrings.Set_Values(const Name, Value: WideString);
begin
  GetStrings.Values[Name] := Value;
end;

procedure TwrpStrings.LoadFromStream(const S: IgsStream);
begin
  GetStrings.LoadFromStream(InterfaceToObject(S) as TStream);
end;

procedure TwrpStrings.SaveToStream(const S: IgsStream);
begin
  GetStrings.SaveToStream(InterfaceToObject(S) as TStream);
end;

function TwrpStrings.Get_ValueFromIndex(Index: Integer): WideString;
var
  S: String;
begin
  S := GetStrings.Strings[Index];
  Result := Copy(S, Pos('=', S) + 1, MAXINT);
end;

procedure TwrpStrings.Set_ValueFromIndex(Index: Integer;
  const Value: WideString);
var
  S: String;
begin
  S := GetStrings.Strings[Index];
  GetStrings.Strings[Index] := Copy(S, 1, Pos('=', S)) + Value;
end;

{ TwrpIBExtract }

function TwrpIBExtract.Get_Database: IgsIBDatabase;
begin
  Result := GetGDCOleObject(GetIBExtract.Database) as IgsIBDatabase;
end;

function TwrpIBExtract.Get_DatabaseInfo: IgsIBDatabaseInfo;
begin
  Result := GetGDCOleObject(GetIBExtract.DatabaseInfo) as IgsIBDatabaseInfo;
end;

function TwrpIBExtract.Get_Items: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBExtract.Items);
end;

function TwrpIBExtract.Get_ShowSystem: WordBool;
begin
  Result := GetIBExtract.ShowSystem;
end;

function TwrpIBExtract.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGDCOleObject(GetIBExtract.Transaction) as IgsIBTransaction;
end;

function TwrpIBExtract.GetArrayField(
  var FieldName: OleVariant): WideString;
var
  fs: String;
begin
  fs := FieldName;
//  Result := GetIBExtract.GetArrayField(fs);
  Result := GetIBExtract.GetArrayField(FieldName);
  FieldName := fs;
end;

function TwrpIBExtract.GetCharacterSets(CharSetId, Collation: Smallint;
  CollateOnly: WordBool): WideString;
begin
  Result := GetIBExtract.GetCharacterSets(CharSetId, Collation, CollateOnly);
end;

function TwrpIBExtract.GetFieldType(FieldType, FieldSubType, FieldScale,
  FieldSize, FieldPrec, FieldLen: Integer): WideString;
begin
  Result := GetIBExtract.GetFieldType(FieldType, FieldSubType, FieldScale,FieldSize, FieldPrec, FieldLen);
end;

function TwrpIBExtract.GetIBExtract: TIBExtract;
begin
  Result := GetObject as TIBExtract;
end;

procedure TwrpIBExtract.Set_Database(const Value: IgsIBDatabase);
begin
  GetIBExtract.Database := InterfaceToObject(Value) as TIBDatabase;
end;

procedure TwrpIBExtract.Set_ShowSystem(Value: WordBool);
begin
  GetIBExtract.ShowSystem := Value;
end;

procedure TwrpIBExtract.Set_Transaction(const Value: IgsIBTransaction);
begin
  GetIBExtract.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

procedure TwrpIBExtract.Notification(const AComponent: IgsComponent;
  Operation: TgsOperation);
begin
  GetIBExtract.Notification(InterfaceToObject(AComponent) as  TComponent, TOperation(operation));
end;

{ TwrpIBQuery }

procedure TwrpIBQuery.ExecSQL;
begin
  GetIBQuery.ExecSQL;
end;

function TwrpIBQuery.Get_GenerateParamNames: WordBool;
begin
  Result := GetIBQuery.GenerateParamNames;
end;

function TwrpIBQuery.Get_ParamCount: Word;
begin
  Result := GetIBQuery.ParamCount;
end;

function TwrpIBQuery.Get_Prepared: WordBool;
begin
  Result := GetIBQuery.Prepared;
end;

function TwrpIBQuery.Get_SQL: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBQuery.SQL);
end;

function TwrpIBQuery.Get_Text: WideString;
begin
  Result := GetIBQuery.Text;
end;

function TwrpIBQuery.GetIBQuery: TIBQuery;
begin
  Result := GetObject as TIBQuery;
end;

procedure TwrpIBQuery.Prepare;
begin
  GetIBQuery.Prepare;
end;

procedure TwrpIBQuery.Set_GenerateParamNames(Value: WordBool);
begin
  GetIBQuery.GenerateParamNames := Value;
end;

procedure TwrpIBQuery.Set_Prepared(Value: WordBool);
begin
  GetIBQuery.Prepared := Value;
end;

procedure TwrpIBQuery.UnPrepare;
begin
  GetIBQuery.UnPrepare;
end;


function TwrpIBQuery.ParamByName(const Name: WideString): IgsParam;
begin
  Result := GetGdcOLEObject(GetIBQuery.ParamByName(Name)) as IgsParam;
end;

function TwrpIBQuery.Get_Constraints: IgsCheckConstraints;
begin
  Result := GetGdcOLEObject(GetIBQuery.Constraints) as IgsCheckConstraints;
end;

function TwrpIBQuery.Get_GeneratorField: IgsIBGeneratorField;
begin
  Result := GetGdcOLEObject(GetIBQuery.GeneratorField) as IgsIBGeneratorField;
end;

function TwrpIBQuery.Get_StatementType: TgsIBSQLTypes;
begin
  Result := TgsIBSQLTypes(GetIBQuery.StatementType);
end;

procedure TwrpIBQuery.Set_Constraints(const Value: IgsCheckConstraints);
begin
  GetIBQuery.Constraints := InterfaceToObject(value) as TCheckConstraints;
end;

procedure TwrpIBQuery.Set_GeneratorField(const Value: IgsIBGeneratorField);
begin
  GetIBQuery.GeneratorField := InterfaceToObject(Value) as TIBGeneratorField;
end;

procedure TwrpIBQuery.BatchInput(const InputObject: IgsIBBatchInput);
begin
  GetIBQuery.BatchInput(InterfaceToObject(InputObject) as TIBBatchInput);
end;

procedure TwrpIBQuery.BatchOutput(const OutputObject: IgsIBBatchOutput);
begin
  GetIBQuery.BatchOutput(InterfaceToObject(OutputObject) as TIBBatchOutput);
end;

{ TwrpIBStoredProc }

procedure TwrpIBStoredProc.ExecProc;
begin
  GetIBStoredProc.ExecProc;
end;

function TwrpIBStoredProc.Get_ParamCount: Word;
begin
  Result := GetIBStoredProc.ParamCount;
end;

function TwrpIBStoredProc.Get_Prepared: WordBool;
begin
  Result := GetIBStoredProc.Prepared;
end;

function TwrpIBStoredProc.Get_StoredProcedureNames: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBStoredProc.StoredProcedureNames);
end;

function TwrpIBStoredProc.Get_StoredProcName: WideString;
begin
  Result := GetIBStoredProc.StoredProcName;
end;

function TwrpIBStoredProc.GetIBStoredProc: TIBStoredProc;
begin
  Result := GetObject as TIBStoredProc;
end;

procedure TwrpIBStoredProc.Prepare;
begin
  GetIBStoredProc.Prepare;
end;

procedure TwrpIBStoredProc.Set_Prepared(Value: WordBool);
begin
  GetIBStoredProc.Prepared := Value;
end;

procedure TwrpIBStoredProc.Set_StoredProcName(const Value: WideString);
begin
  GetIBStoredProc.StoredProcName := Value;
end;

procedure TwrpIBStoredProc.UnPrepare;
begin
  GetIBStoredProc.UnPrepare;
end;

procedure TwrpIBStoredProc.CopyParams(const Value: IgsParams);
begin
  GetIBStoredProc.CopyParams(InterfaceToObject(Value) as TParams);
end;

function TwrpIBStoredProc.ParamByName(const Value: WideString): IgsParam;
begin
  Result := GetGdcOLEObject(GetIBStoredProc.ParamByName(Value)) as IgsParam;
end;

{ TwrpIBTable }

procedure TwrpIBTable.CreateTable;
begin
  GetIBTable.CreateTable;
end;

procedure TwrpIBTable.DeleteIndex(const Name: WideString);
begin
  GetIBTable.DeleteIndex(Name);
end;

procedure TwrpIBTable.DeleteTable;
begin
  GetIBTable.DeleteTable;
end;

procedure TwrpIBTable.EmptyTable;
begin
  GetIBTable.EmptyTable;
end;

function TwrpIBTable.Get_DefaultIndex: WordBool;
begin
  Result := GetIBTable.DefaultIndex;
end;

function TwrpIBTable.Get_Exists: WordBool;
begin
  Result := GetIBTable.Exists;
end;

function TwrpIBTable.Get_IndexFieldCount: Integer;
begin
  Result := GetIBTable.IndexFieldCount;
end;

function TwrpIBTable.Get_IndexFieldNames: WideString;
begin
  Result := GetIBTable.IndexFieldNames;
end;

function TwrpIBTable.Get_IndexFields(Index: Integer): IgsFieldComponent;
begin
  Result := GetGDCOleObject(GetIBTable.IndexFields[Index]) as IgsFieldComponent;
end;

function TwrpIBTable.Get_IndexName: WideString;
begin
  Result := GetIBTable.IndexName;
end;

function TwrpIBTable.Get_MasterFields: WideString;
begin
  Result := GetIBTable.MasterFields;
end;

function TwrpIBTable.Get_MasterSource: IgsDataSource;
begin
  Result := GetGDCOleObject(GetIBTable.MasterSource) as IgsDataSource;
end;

function TwrpIBTable.Get_ReadOnly: WordBool;
begin
  Result := GetIBTable.ReadOnly;
end;

function TwrpIBTable.Get_StoreDefs: WordBool;
begin
  Result := GetIBTable.StoreDefs;
end;

function TwrpIBTable.Get_TableName: WideString;
begin
  Result := GetIBTable.TableName;
end;

function TwrpIBTable.Get_TableNames: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBTable.TableNames);
end;

function TwrpIBTable.GetIBTable: TIBTable;
begin
  Result := GetObject as TIBTable;
end;

procedure TwrpIBTable.GetIndexNames(const List: IgsStrings);
begin
  GetIBTable.GetIndexNames(IgsStringsToTStrings(List));
end;

procedure TwrpIBTable.GotoCurrent(const Table: IgsIBTable);
begin
  GetIBTable.GotoCurrent(InterfaceToObject(Table) as TIBTable);
end;

procedure TwrpIBTable.Set_DefaultIndex(Value: WordBool);
begin
  GetIBTable.DefaultIndex := Value;
end;

procedure TwrpIBTable.Set_IndexFieldNames(const Value: WideString);
begin
  GetIBTable.IndexFieldNames := Value;
end;

procedure TwrpIBTable.Set_IndexFields(Index: Integer;
  const Value: IgsFieldComponent);
begin
  GetIBTable.IndexFields[Index] := InterfaceToObject(Value) as TField;
end;

procedure TwrpIBTable.Set_IndexName(const Value: WideString);
begin
  GetIBTable.IndexName := Value;
end;

procedure TwrpIBTable.Set_MasterFields(const Value: WideString);
begin
  GetIBTable.MasterFields := Value;
end;

procedure TwrpIBTable.Set_MasterSource(const Value: IgsDataSource);
begin
  GetIBTable.MasterSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpIBTable.Set_ReadOnly(Value: WordBool);
begin
  GetIBTable.ReadOnly := Value;
end;

procedure TwrpIBTable.Set_StoreDefs(Value: WordBool);
begin
  GetIBTable.StoreDefs := Value;
end;

procedure TwrpIBTable.Set_TableName(const Value: WideString);
begin
  GetIBTable.TableName := Value;
end;

function TwrpIBTable.Get_Constraints: IgsCheckConstraints;
begin
  Result := GetGdcOLEObject(GetIBTable.Constraints) as IgsCheckConstraints;
end;

function TwrpIBTable.Get_IndexDefs: IgsIndexDefs;
begin
  Result := GetGdcOLEObject(GetIBTable.IndexDefs) as IgsIndexDefs;
end;

procedure TwrpIBTable.Set_Constraints(const Value: IgsCheckConstraints);
begin
  GetIBTable.Constraints := InterfaceToObject(Value) as TCheckConstraints;
end;

procedure TwrpIBTable.Set_IndexDefs(const Value: IgsIndexDefs);
begin
  GetIBTable.IndexDefs := InterfaceToObject(Value) as TIndexDefs;
end;

{ TwrpIBDataSetUpdateObject }

function TwrpIBDataSetUpdateObject.Get_RefreshSQL: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBDataSetUpdateObject.RefreshSQL);
end;

function TwrpIBDataSetUpdateObject.GetIBDataSetUpdateObject: TIBDataSetUpdateObject;
begin
  Result := GetObject as TIBDataSetUpdateObject;
end;

procedure TwrpIBDataSetUpdateObject.Set_RefreshSQL(const Value: IgsStrings);
begin
  GetIBDataSetUpdateObject.RefreshSQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBDataSetUpdateObject.Apply(UpdateKind: TgsUpdateKind);
begin
  GetIBDataSetUpdateObject.Apply(TUpdateKind(UpdateKind))
end;

function TwrpIBDataSetUpdateObject.GetSQL(
  UpdateKind: TgsUpdateKind): IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBDataSetUpdateObject.GetSQL(TUpdateKind(UpdateKind)));
end;

function TwrpIBDataSetUpdateObject.Get_DataSet: IgsIBCustomDataSet;
begin
  Result := GetGdcOLEObject(TCrackIBDataSetUpdateObject(GetIBDataSetUpdateObject).DataSet) as
     IgsIBCustomDataSet;
end;

procedure TwrpIBDataSetUpdateObject.Set_DataSet(
  const Value: IgsIBCustomDataSet);
begin
  TCrackIBDataSetUpdateObject(GetIBDataSetUpdateObject).DataSet :=
    InterfaceToObject(Value) as TIBCustomDataSet;
end;

{ TwrpIBUpdateSQL }

procedure TwrpIBUpdateSQL.ExecSQL(UpdateKind: TgsUpdateKind);
begin
  GetIBUpdateSQL.ExecSQL(TUpdateKind(UpdateKind));
end;

function TwrpIBUpdateSQL.Get_DeleteSQL: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBUpdateSQL.DeleteSQL);
end;

function TwrpIBUpdateSQL.Get_InsertSQL: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBUpdateSQL.InsertSQL);
end;

function TwrpIBUpdateSQL.Get_ModifySQL: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBUpdateSQL.ModifySQL);
end;

function TwrpIBUpdateSQL.Get_Query(UpdateKind: TgsUpdateKind): IgsQuery;
begin
  Result := GetGdcOLEObject(GetIBUpdateSQL.Query[TUpdateKind(UpdateKind)]) as IgsQuery;
end;

function TwrpIBUpdateSQL.Get_SQL(UpdateKind: TgsUpdateKind): IgsStrings;
begin
  Result := TStringsToIgsStrings(GetIBUpdateSQL.SQL[TUpdateKind(UpdateKind)]);
end;

function TwrpIBUpdateSQL.GetIBUpdateSQL: TIBUpdateSQL;
begin
  Result := GetObject as TIBUpdateSQL;
end;

procedure TwrpIBUpdateSQL.Set_DeleteSQL(const Value: IgsStrings);
begin
  GetIBUpdateSQL.DeleteSQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBUpdateSQL.Set_InsertSQL(const Value: IgsStrings);
begin
  GetIBUpdateSQL.InsertSQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBUpdateSQL.Set_ModifySQL(const Value: IgsStrings);
begin
  GetIBUpdateSQL.ModifySQL := IgsStringsToTStrings(Value);
end;

procedure TwrpIBUpdateSQL.Set_SQL(UpdateKind: TgsUpdateKind;
  const Value: IgsStrings);
begin
  GetIBUpdateSQL.SQL[TUpdateKind(UpdateKind)] := IgsStringsToTStrings(Value);
end;

procedure TwrpIBUpdateSQL.SetParams(UpdateKind: TgsUpdateKind);
begin
  GetIBUpdateSQL.SetParams(TUpdateKind(UpdateKind));
end;

{ TwrpHeaderControl }

function TwrpHeaderControl.Get_DragReorder: WordBool;
begin
  Result := GetHeaderControl.DragReorder;
end;

function TwrpHeaderControl.Get_FullDrag: WordBool;
begin
  Result := GetHeaderControl.FullDrag;
end;

function TwrpHeaderControl.Get_HotTrack: WordBool;
begin
  Result := GetHeaderControl.HotTrack;
end;

function TwrpHeaderControl.Get_Style: TgsHeaderStyle;
begin
  Result := TgsHeaderStyle(GetHeaderControl.Style);
end;

function TwrpHeaderControl.GetHeaderControl: THeaderControl;
begin
  Result := GetObject as THeaderControl;
end;

procedure TwrpHeaderControl.Set_DragReorder(Value: WordBool);
begin
  GetHeaderControl.DragReorder := Value;
end;

procedure TwrpHeaderControl.Set_FullDrag(Value: WordBool);
begin
  GetHeaderControl.FullDrag := Value;
end;

procedure TwrpHeaderControl.Set_HotTrack(Value: WordBool);
begin
  GetHeaderControl.HotTrack := Value;
end;

procedure TwrpHeaderControl.Set_Style(Value: TgsHeaderStyle);
begin
  GetHeaderControl.Style := THeaderStyle(Value);
end;

function TwrpHeaderControl.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetHeaderControl.Canvas ) as IgsCanvas;
end;

function TwrpHeaderControl.Get_Images: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetHeaderControl.Images) as IgsCustomImageList;
end;

function TwrpHeaderControl.Get_Sections: IgsHeaderSections;
begin
  Result := GetGdcOLEObject(GetHeaderControl.Sections) as IgsHeaderSections;
end;

procedure TwrpHeaderControl.Set_Images(const Value: IgsCustomImageList);
begin
  GetHeaderControl.Images := InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpHeaderControl.Set_Sections(const Value: IgsHeaderSections);
begin
  GetHeaderControl.Sections := InterfaceToObject(Value) as THeaderSections;
end;

{ TwrpHotKey }

function TwrpHotKey.Get_HotKey: Word;
begin
  Result := GetHotKey.HotKey;
end;

function TwrpHotKey.GetHotKey: THotKey;
begin
  Result := GetObject as THotKey;
end;

procedure TwrpHotKey.Set_HotKey(Value: Word);
begin
  GetHotKey.HotKey := TShortCut(Value);
end;

{ TwrpCustomImageList }

procedure TwrpCustomImageList.AddImages(const Value: IgsCustomImageList);
begin
  GetCustomImageList.AddImages(InterfaceToObject(Value) as TCustomImageList);
end;

procedure TwrpCustomImageList.Clear;
begin
  GetCustomImageList.Clear;
end;

procedure TwrpCustomImageList.Delete(Index: Integer);
begin
  GetCustomImageList.Delete(Index);
end;

function TwrpCustomImageList.FileLoad(ResType: TgsResType;
  const Name: WideString; MaskColor: Integer): WordBool;
begin
  Result := GetCustomImageList.FileLoad(TResType(ResType), Name, MaskColor);
end;

function TwrpCustomImageList.Get_AllocBy: Integer;
begin
  Result := GetCustomImageList.AllocBy;
end;

function TwrpCustomImageList.Get_BkColor: Integer;
begin
  Result := GetCustomImageList.BkColor;
end;

function TwrpCustomImageList.Get_BlendColor: Integer;
begin
  Result := GetCustomImageList.BlendColor;
end;

function TwrpCustomImageList.Get_Count: Integer;
begin
  Result := GetCustomImageList.Count;
end;

function TwrpCustomImageList.Get_DrawingStyle: TgsDrawingStyle;
begin
  Result := TgsDrawingStyle(GetCustomImageList.DrawingStyle);
end;

function TwrpCustomImageList.Get_Height: Integer;
begin
  Result := GetCustomImageList.Height;
end;

function TwrpCustomImageList.Get_ImageType: TgsImageType;
begin
  Result := TgsImageType(GetCustomImageList.ImageType);
end;

function TwrpCustomImageList.Get_Masked: WordBool;
begin
  Result := GetCustomImageList.Masked;
end;

function TwrpCustomImageList.Get_ShareImages: WordBool;
begin
  Result := GetCustomImageList.ShareImages;
end;

function TwrpCustomImageList.Get_Width: Integer;
begin
  Result := GetCustomImageList.Width;
end;

function TwrpCustomImageList.GetCustomImageList: TCustomImageList;
begin
  Result := GetObject as TCustomImageList;
end;

function TwrpCustomImageList.HandleAllocated: WordBool;
begin
  Result := GetCustomImageList.HandleAllocated;
end;

procedure TwrpCustomImageList.Move(CurIndex, NewIndex: Integer);
begin
  GetCustomImageList.Move(CurIndex, NewIndex);
end;

function TwrpCustomImageList.ResInstLoad(Instance: Integer;
  ResType: TgsResType; const Name: WideString;
  MaskColor: Integer): WordBool;
begin
  Result := GetCustomImageList.ResInstLoad(Instance, TResType(ResType), Name, MaskColor);
end;

function TwrpCustomImageList.ResourceLoad(ResType: TgsResType;
  const Name: WideString; MaskColor: Integer): WordBool;
begin
  Result := GetCustomImageList.ResourceLoad(TResType(ResType), Name, MaskColor);
end;

procedure TwrpCustomImageList.Set_AllocBy(Value: Integer);
begin
  GetCustomImageList.AllocBy := Value;
end;

procedure TwrpCustomImageList.Set_BkColor(Value: Integer);
begin
  GetCustomImageList.BkColor := Value;
end;

procedure TwrpCustomImageList.Set_BlendColor(Value: Integer);
begin
  GetCustomImageList.BlendColor := Value;
end;

procedure TwrpCustomImageList.Set_DrawingStyle(Value: TgsDrawingStyle);
begin
  GetCustomImageList.DrawingStyle := TDrawingStyle(Value);
end;

procedure TwrpCustomImageList.Set_Height(Value: Integer);
begin
  GetCustomImageList.Height := Value;
end;

procedure TwrpCustomImageList.Set_ImageType(Value: TgsImageType);
begin
  GetCustomImageList.ImageType := TImageType(Value);
end;

procedure TwrpCustomImageList.Set_Masked(Value: WordBool);
begin
  GetCustomImageList.Masked := Value;
end;

procedure TwrpCustomImageList.Set_ShareImages(Value: WordBool);
begin
  GetCustomImageList.ShareImages := Value;
end;

procedure TwrpCustomImageList.Set_Width(Value: Integer);
begin
  GetCustomImageList.Width := Value;
end;

function TwrpCustomImageList.Get_Handle: Integer;
begin
  Result := GetCustomImageList.Handle;
end;

procedure TwrpCustomImageList.Set_Handle(Value: Integer);
begin
  GetCustomImageList.Handle := Value;
end;

function TwrpCustomImageList.Add(const Image, Mask: IgsBitmap): Integer;
begin
  Result := GetCustomImageList.Add(InterfaceToObject(Image) as TBitmap,
    InterfaceToObject(Mask) as TBitmap);
end;

function TwrpCustomImageList.AddIcon(const Image: IgsIcon): Integer;
begin
  Result := GetCustomImageList.AddIcon(InterfaceToObject(Image) as TIcon);
end;

function TwrpCustomImageList.AddMasked(const Image: IgsBitmap;
  MaskColor: Integer): Integer;
begin
  Result := GetCustomImageList.AddMasked(InterfaceToObject(Image) as TBitmap, MaskColor);
end;

procedure TwrpCustomImageList.Draw(const Canvas: IgsCanvas; X, Y,
  Index: Integer; Enabled: WordBool);
begin
  GetCustomImageList.Draw(InterfaceToObject(Canvas) as TCanvas, X, Y, Index, Enabled);
end;

procedure TwrpCustomImageList.DrawOverlay(const Canvas: IgsCanvas; X, Y,
  ImageIndex: Integer; Overlay: TgsOverlay; Enabled: WordBool);
begin
  GetCustomImageList.DrawOverlay(InterfaceToObject(Canvas) as TCanvas, X,
    Y, ImageIndex, Overlay, Enabled);
end;

procedure TwrpCustomImageList.GetBitmap(Index: Integer;
  const Image: IgsBitmap);
begin
  GetCustomImageList.GetBitmap(Index, InterfaceToObject(Image) as TBitmap);
end;

procedure TwrpCustomImageList.GetHotSpot(out X, Y: OleVariant);
begin
  x := GetCustomImageList.GetHotSpot.x;
  y := GetCustomImageList.GetHotSpot.y;
end;

procedure TwrpCustomImageList.GetIcon(Index: Integer;
  const Image: IgsIcon);
begin
  GetCustomImageList.GetIcon(Index, InterfaceToObject(Image) as TIcon);
end;

function TwrpCustomImageList.GetImageBitmap: Integer;
begin
  Result := GetCustomImageList.GetImageBitmap;
end;

function TwrpCustomImageList.GetMaskBitmap: Integer;
begin
  Result := GetCustomImageList.GetMaskBitmap;
end;

procedure TwrpCustomImageList.Insert(Index: Integer; const Image,
  Mask: IgsBitmap);
begin
  GetCustomImageList.Insert(Index,
    InterfaceToObject(Image) as TBitmap, InterfaceToObject(Mask) as TBitmap);
end;

procedure TwrpCustomImageList.InsertIcon(Index: Integer;
  const Image: IgsIcon);
begin
  GetCustomImageList.InsertIcon(Index,
     InterfaceToObject(Image) as TIcon);
end;

function TwrpCustomImageList.Overlay(Index: Integer;
  Overlay: TgsOverlay): WordBool;
begin
  Result := GetCustomImageList.Overlay(Index, Overlay);
end;

procedure TwrpCustomImageList.RegisterChanges(const Value: IgsChangeLink);
begin
  GetCustomImageList.RegisterChanges(InterfaceToObject(Value) as TChangeLink);
end;

procedure TwrpCustomImageList.Replace(Index: Integer; const Image,
  Mask: IgsBitmap);
begin
  GetCustomImageList.Replace(Index,
    InterfaceToObject(Image) as TBitmap, InterfaceToObject(Mask) as TBitmap);
end;

procedure TwrpCustomImageList.ReplaceIcon(Index: Integer;
  const Image: IgsIcon);
begin
  GetCustomImageList.ReplaceIcon(Index,
    InterfaceToObject(Image) as TIcon);
end;

procedure TwrpCustomImageList.ReplaceMasked(Index: Integer;
  const NewImage: IgsBitmap; MaskColor: Integer);
begin
  GetCustomImageList.ReplaceMasked(Index,
    InterfaceToObject(NewImage) as TBitmap, MaskColor);
end;

{ TwrpDragImageList }

function TwrpDragImageList.BeginDrag(Window, X, Y: Integer): WordBool;
begin
  Result := GetDragImageList.BeginDrag(Window, X, Y);
end;

function TwrpDragImageList.DragLock(Window, XPos, YPos: Integer): WordBool;
begin
  Result := GetDragImageList.DragLock(Window, XPos, YPos);
end;

function TwrpDragImageList.DragMove(X, Y: Integer): WordBool;
begin
  Result := GetDragImageList.DragMove(X, Y);
end;

procedure TwrpDragImageList.DragUnlock;
begin
  GetDragImageList.DragUnlock;
end;

function TwrpDragImageList.EndDrag: WordBool;
begin
  Result := GetDragImageList.EndDrag;
end;

function TwrpDragImageList.Get_Dragging: WordBool;
begin
  Result := GetDragImageList.Dragging;
end;

function TwrpDragImageList.GetDragImageList: TDragImageList;
begin
  Result := GetObject as TDragImageList;
end;

procedure TwrpDragImageList.HideDragImage;
begin
  GetDragImageList.HideDragImage;
end;

function TwrpDragImageList.SetDragImage(Index, HotSpotX,
  HotSpotY: Integer): WordBool;
begin
  Result := GetDragImageList.SetDragImage(Index, HotSpotX, HotSpotY);
end;

procedure TwrpDragImageList.ShowDragImage;
begin
  GetDragImageList.ShowDragImage;
end;

function TwrpDragImageList.Get_DragCursor: Smallint;
begin
  Result := GetDragImageList.DragCursor;
end;

procedure TwrpDragImageList.Set_DragCursor(Value: Smallint);
begin
  GetDragImageList.DragCursor := Value;
end;

{ TwrpCustomOutline }

function TwrpCustomOutline.Add(Index: Integer;
  const Text: WideString): Integer;
begin
  Result := GetCustomOutline.Add(Index, Text);
end;

function TwrpCustomOutline.AddChild(Index: Integer;
  const Text: WideString): Integer;
begin
  Result := GetCustomOutline.AddChild(Index,  Text);
end;

procedure TwrpCustomOutline.BeginUpdate;
begin
  GetCustomOutline.BeginUpdate;
end;

procedure TwrpCustomOutline.Clear;
begin
  GetCustomOutline.Clear;
end;

procedure TwrpCustomOutline.Delete(Index: Integer);
begin
  GetCustomOutline.Delete(Index);
end;

procedure TwrpCustomOutline.EndUpdate;
begin
  GetCustomOutline.EndUpdate;
end;

procedure TwrpCustomOutline.FullCollapse;
begin
  GetCustomOutline.FullCollapse;
end;

procedure TwrpCustomOutline.FullExpand;
begin
  GetCustomOutline.FullExpand;
end;

function TwrpCustomOutline.Get_ItemCount: Integer;
begin
  Result := GetCustomOutline.ItemCount;
end;

function TwrpCustomOutline.Get_ItemHeight: Integer;
begin
  Result := TCrackCustomOutline(GetCustomOutline).ItemHeight;
end;

function TwrpCustomOutline.Get_ItemSeparator: WideString;
begin
  Result := TCrackCustomOutline(GetCustomOutline).ItemSeparator;
end;

function TwrpCustomOutline.Get_Lines: IgsStrings;
begin
  Result := TStringsToIgsStrings(TCrackCustomOutline(GetCustomOutline).Lines);
end;

function TwrpCustomOutline.Get_OutlineStyle: TgsOutlineStyle;
begin
  Result := TgsOutlineStyle(TCrackCustomOutline(GetCustomOutline).OutlineStyle);
end;

function TwrpCustomOutline.Get_SelectedItem: Integer;
begin
  Result := GetCustomOutline.SelectedItem;
end;

function TwrpCustomOutline.Get_Style: TgsOutlineType;
begin
  Result := TgsOutlineStyle(TCrackCustomOutline(GetCustomOutline).Style);
end;

function TwrpCustomOutline.GetCustomOutline: TCustomOutline;
begin
  Result := GetObject as TCustomOutline;
end;

function TwrpCustomOutline.GetItem(X, Y: Integer): Integer;
begin
  Result := GetCustomOutline.GetItem(X, Y);
end;

function TwrpCustomOutline.GetTextItem(const Value: WideString): Integer;
begin
  Result := GetCustomOutline.GetTextItem(Value);
end;

function TwrpCustomOutline.Insert(Index: Integer;
  const Text: WideString): Integer;
begin
  Result := GetCustomOutline.Insert(Index, Text);
end;

procedure TwrpCustomOutline.LoadFromFile(const FileName: WideString);
begin
  GetCustomOutline.LoadFromFile(FileName);
end;

procedure TwrpCustomOutline.SaveToFile(const FileName: WideString);
begin
  GetCustomOutline.SaveToFile(FileName);
end;

procedure TwrpCustomOutline.Set_ItemHeight(Value: Integer);
begin
  TCrackCustomOutline(GetCustomOutline).ItemHeight := Value;
end;

procedure TwrpCustomOutline.Set_ItemSeparator(const Value: WideString);
begin
  TCrackCustomOutline(GetCustomOutline).ItemSeparator := Value;
end;

procedure TwrpCustomOutline.Set_Lines(const Value: IgsStrings);
begin
  TCrackCustomOutline(GetCustomOutline).Lines := IgsStringsToTStrings(Value);
end;

procedure TwrpCustomOutline.Set_OutlineStyle(Value: TgsOutlineStyle);
begin
  TCrackCustomOutline(GetCustomOutline).OutlineStyle := TOutlineStyle(Value);
end;

procedure TwrpCustomOutline.Set_SelectedItem(Value: Integer);
begin
  GetCustomOutline.SelectedItem := Value;
end;

procedure TwrpCustomOutline.Set_Style(Value: TgsOutlineType);
begin
  TCrackCustomOutline(GetCustomOutline).Style := TOutLineType(Value);
end;

procedure TwrpCustomOutline.SetUpdateState(Value: WordBool);
begin
  GetCustomOutline.SetUpdateState(Value);
end;

function TwrpCustomOutline.Get_Items(Index: Integer): IgsOutlineNode;
begin
  Result := GetGdcOLEObject(GetCustomOutline.Items[Index]) as  IgsOutlineNode;
end;

function TwrpCustomOutline.GetNodeDisplayWidth(
  const Node: IgsOutlineNode): Integer;
begin
  Result := GetCustomOutline.GetNodeDisplayWidth(InterfaceToObject(Node) as TOutlineNode);
end;

function TwrpCustomOutline.GetVisibleNode(Index: Integer): IgsOutlineNode; safecall;
begin
  Result := GetGdcOLEObject(GetCustomOutline.GetVisibleNode(Index)) as IgsOutlineNode;
end;

procedure TwrpCustomOutline.LoadFromStream(const Stream: IgsStream);
begin
  GetCustomOutline.LoadFromStream(InterfaceToObject(Stream) as TStream)
end;

procedure TwrpCustomOutline.SaveToStream(const Stream: IgsStream);
begin
  GetCustomOutline.SaveToStream(InterfaceToObject(Stream) as TStream);
end;

{ TwrpTimer }

function TwrpTimer.Get_Enabled: WordBool;
begin
  Result := GetTimer.Enabled;
end;

function TwrpTimer.Get_Interval: Integer;
begin
  Result := GetTimer.Interval;
end;

function TwrpTimer.GetTimer: TTimer;
begin
  Result := GetObject as TTimer;
end;

procedure TwrpTimer.Set_Enabled(Value: WordBool);
begin
  GetTimer.Enabled := Value;
end;

procedure TwrpTimer.Set_Interval(Value: Integer);
begin
  GetTimer.Interval := Value;
end;

{ TwrpAnimate }

function TwrpAnimate.Get_Active: WordBool;
begin
  Result := GetAnimate.Active;
end;

function TwrpAnimate.Get_Center: WordBool;
begin
  Result := GetAnimate.Center;
end;

function TwrpAnimate.Get_CommonAVI: TgsCommonAVI;
begin
  Result := TgsCommonAVI(GetAnimate.CommonAVI);
end;

function TwrpAnimate.Get_FileName: WideString;
begin
  Result := GetAnimate.FileName;
end;

function TwrpAnimate.Get_FrameCount: Integer;
begin
  Result := GetAnimate.FrameCount;
end;

function TwrpAnimate.Get_FrameHeight: Integer;
begin
  Result := GetAnimate.FrameHeight;
end;

function TwrpAnimate.Get_FrameWidth: Integer;
begin
  Result := GetAnimate.FrameWidth;
end;

function TwrpAnimate.Get_Open: WordBool;
begin
  Result := GetAnimate.Open;
end;

function TwrpAnimate.Get_Repetitions: Integer;
begin
  Result := GetAnimate.Repetitions;
end;

function TwrpAnimate.Get_ResHandle: Integer;
begin
  Result := GetAnimate.ResHandle;
end;

function TwrpAnimate.Get_ResID: Integer;
begin
  Result := GetAnimate.ResId;
end;

function TwrpAnimate.Get_ResName: WideString;
begin
  Result := GetAnimate.ResName;
end;

function TwrpAnimate.Get_StartFrame: Smallint;
begin
  Result := GetAnimate.StartFrame;
end;

function TwrpAnimate.Get_StopFrame: Smallint;
begin
  Result := GetAnimate.StopFrame;
end;

function TwrpAnimate.Get_Timers: WordBool;
begin
  Result := GetAnimate.Timers;
end;

function TwrpAnimate.Get_Transparent: WordBool;
begin
  Result := GetAnimate.Transparent;
end;

function TwrpAnimate.GetAnimate: TAnimate;
begin
  Result := GetObject as TAnimate;
end;

procedure TwrpAnimate.Play(FromFrame: Word; ToFrame: Word; Count: Integer);
begin
  GetAnimate.Play(FromFrame, ToFrame, Count);
end;

procedure TwrpAnimate.Reset;
begin
  GetAnimate.Reset;
end;

procedure TwrpAnimate.Seek(Frame: Smallint);
begin
  GetAnimate.Seek(Frame);
end;

procedure TwrpAnimate.Set_Active(Value: WordBool);
begin
  GetAnimate.Active := Value;
end;

procedure TwrpAnimate.Set_Center(Value: WordBool);
begin
  GetAnimate.Center := Value;
end;

procedure TwrpAnimate.Set_CommonAVI(Value: TgsCommonAVI);
begin
  GetAnimate.CommonAVI := TCommonAVI(Value);
end;

procedure TwrpAnimate.Set_FileName(const Value: WideString);
begin
  GetAnimate.FileName := Value;
end;

procedure TwrpAnimate.Set_Open(Value: WordBool);
begin
  GetAnimate.Open := Value;
end;

procedure TwrpAnimate.Set_Repetitions(Value: Integer);
begin
  GetAnimate.Repetitions := Value;
end;

procedure TwrpAnimate.Set_ResHandle(Value: Integer);
begin
  GetAnimate.ResHandle := Value;
end;

procedure TwrpAnimate.Set_ResID(Value: Integer);
begin
  GetAnimate.ResId := Value;
end;

procedure TwrpAnimate.Set_ResName(const Value: WideString);
begin
  GetAnimate.ResName := Value;
end;

procedure TwrpAnimate.Set_StartFrame(Value: Smallint);
begin
  GetAnimate.StartFrame := Value;
end;

procedure TwrpAnimate.Set_StopFrame(Value: Smallint);
begin
  GetAnimate.StopFrame := Value;
end;

procedure TwrpAnimate.Set_Timers(Value: WordBool);
begin
  GetAnimate.Timers := Value;
end;

procedure TwrpAnimate.Set_Transparent(Value: WordBool);
begin
  GetAnimate.Transparent := Value;
end;

procedure TwrpAnimate.Stop;
begin
  GetAnimate.Stop;
end;

{ TwrpDirectoryListBox }

function TwrpDirectoryListBox.DisplayCase(const S: WideString): WideString;
begin
  Result := GetDirectoryListBox.DisplayCase(S);
end;

function TwrpDirectoryListBox.FileCompareText(const A,
  B: WideString): Integer;
begin
  Result := GetDirectoryListBox.FileCompareText(A, B);
end;

function TwrpDirectoryListBox.Get_CaseSensitive: WordBool;
begin
  Result := GetDirectoryListBox.CaseSensitive;
end;

function TwrpDirectoryListBox.Get_Directory: WideString;
begin
  Result := GetDirectoryListBox.Directory;
end;

function TwrpDirectoryListBox.Get_DirLabel: IgsLabel;
begin
  Result := GetGdcOLEObject(GetDirectoryListBox.DirLabel) as IgsLabel;
end;

function TwrpDirectoryListBox.Get_Drive: Byte;
begin
  Result := Ord(GetDirectoryListBox.Drive);
end;

function TwrpDirectoryListBox.Get_PreserveCase: WordBool;
begin
  Result := GetDirectoryListBox.PreserveCase;
end;

function TwrpDirectoryListBox.GetDirectoryListBox: TDirectoryListBox;
begin
  Result := GetObject as TDirectoryListBox;
end;

function TwrpDirectoryListBox.GetItemPath(Index: Integer): WideString;
begin
  Result := GetDirectoryListBox.GetItemPath(Index);
end;

procedure TwrpDirectoryListBox.OpenCurrent;
begin
  GetDirectoryListBox.OpenCurrent;
end;

procedure TwrpDirectoryListBox.Set_Directory(const Value: WideString);
begin
  GetDirectoryListBox.Directory := Value;
end;

procedure TwrpDirectoryListBox.Set_DirLabel(const Value: IgsLabel);
begin
  GetDirectoryListBox.DirLabel := InterfaceToObject(Value) as TLabel;
end;

procedure TwrpDirectoryListBox.Set_Drive(Value: Byte);
begin
  GetDirectoryListBox.Drive := Chr(Value);
end;

function TwrpDirectoryListBox.Get_FileList: IgsFileListBox;
begin
  Result := GetGdcOLEObject(GetDirectoryListBox.FileList) as IgsFileListBox;
end;

procedure TwrpDirectoryListBox.Set_FileList(const Value: IgsFileListBox);
begin
  GetDirectoryListBox.FileList := InterfaceToObject(Value) as TFileListBox;
end;

{ TwrpColorGrid }

function TwrpColorGrid.ColorToIndex(AColor: Integer): Integer;
begin
  Result := GetColorGrid.ColorToIndex(AColor);
end;

function TwrpColorGrid.Get_BackgroundColor: Integer;
begin
  Result := GetColorGrid.BackgroundColor;
end;

function TwrpColorGrid.Get_BackgroundEnabled: WordBool;
begin
  Result := GetColorGrid.BackgroundEnabled;
end;

function TwrpColorGrid.Get_BackgroundIndex: Integer;
begin
  Result := GetColorGrid.BackgroundIndex;
end;

function TwrpColorGrid.Get_ClickEnablesColor: WordBool;
begin
  Result := GetColorGrid.ClickEnablesColor;
end;

function TwrpColorGrid.Get_ForegroundColor: Integer;
begin
  Result := GetColorGrid.ForegroundColor;
end;

function TwrpColorGrid.Get_ForegroundEnabled: WordBool;
begin
  Result := GetColorGrid.ForegroundEnabled;
end;

function TwrpColorGrid.Get_ForegroundIndex: Integer;
begin
  Result := GetColorGrid.ForegroundIndex;
end;

function TwrpColorGrid.Get_GridOrdering: TgsGridOrdering;
begin
  Result := TgsGridOrdering(GetColorGrid.GridOrdering);
end;

function TwrpColorGrid.Get_Selection: Integer;
begin
  Result := GetColorGrid.Selection;
end;

function TwrpColorGrid.GetColorGrid: TColorGrid;
begin
  Result := GetObject as TColorGrid;
end;

procedure TwrpColorGrid.Set_BackgroundEnabled(Value: WordBool);
begin
  GetColorGrid.BackgroundEnabled := Value;
end;

procedure TwrpColorGrid.Set_BackgroundIndex(Value: Integer);
begin
  GetColorGrid.BackgroundIndex := Value;
end;

procedure TwrpColorGrid.Set_ClickEnablesColor(Value: WordBool);
begin
  GetColorGrid.ClickEnablesColor := Value;
end;

procedure TwrpColorGrid.Set_ForegroundEnabled(Value: WordBool);
begin
  GetColorGrid.ForegroundEnabled := Value;
end;

procedure TwrpColorGrid.Set_ForegroundIndex(Value: Integer);
begin
  GetColorGrid.ForegroundIndex := Value;
end;

procedure TwrpColorGrid.Set_GridOrdering(Value: TgsGridOrdering);
begin
  GetColorGrid.GridOrdering := TGridOrdering(Value);
end;

procedure TwrpColorGrid.Set_Selection(Value: Integer);
begin
  GetColorGrid.Selection := Value;
end;

{ TwrpCanvas }

procedure TwrpCanvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
  GetCanvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;

procedure TwrpCanvas.Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
  GetCanvas.Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;

procedure TwrpCanvas.Ellipse(X1, Y1, X2, Y2: Integer);
begin
  GetCanvas.Ellipse(X1, Y1, X2, Y2);
end;

procedure TwrpCanvas.FloodFill(X, Y: Integer; Color: Integer;
  FillStyle: TgsFillStyle);
begin
  GetCanvas.FloodFill(X, Y, Color, TFillStyle(FillStyle));
end;

function TwrpCanvas.Get_CanvasOrientation: TgsCanvasOrientation;
begin
  Result := TgsCanvasOrientation(GetCanvas.CanvasOrientation);
end;

function TwrpCanvas.Get_CopyMode: Integer;
begin
  Result := GetCanvas.CopyMode;
end;

function TwrpCanvas.Get_Font: IgsFont;
begin
  Result := GetGdcOLEObject(GetCanvas.Font) as IgsFont;
end;

function TwrpCanvas.Get_Handle: Integer;
begin
  Result := GetCanvas.Handle;
end;

function TwrpCanvas.Get_LockCount: Integer;
begin
  Result := GetCanvas.LockCount;
end;

function TwrpCanvas.Get_Pixels(X, Y: Integer): Integer;
begin
  Result := GetCanvas.Pixels[X, Y];
end;

function TwrpCanvas.Get_TextFlags: Integer;
begin
  Result := GetCanvas.TextFlags;
end;

function TwrpCanvas.GetCanvas: TCanvas;
begin
  Result := GetObject as TCanvas;
end;

procedure TwrpCanvas.LineTo(X, Y: Integer);
begin
  GetCanvas.LineTo(X, Y);
end;

procedure TwrpCanvas.Lock;
begin
  GetCanvas.Lock;
end;

procedure TwrpCanvas.MoveTo(X, Y: Integer);
begin
  GetCanvas.MoveTo(X, Y);
end;

procedure TwrpCanvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);
begin
  GetCanvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4);
end;

procedure TwrpCanvas.Rectangle(X1, Y1, X2, Y2: Integer);
begin
  GetCanvas.Rectangle(X1, Y1, X2, Y2);
end;

procedure TwrpCanvas.Refresh;
begin
  GetCanvas.Refresh;
end;

procedure TwrpCanvas.RoundRect(X1, Y1, X2, Y2, X3, Y3: Integer);
begin
  GetCanvas.RoundRect(X1, Y1, X2, Y2, X3, Y3);
end;

procedure TwrpCanvas.Set_CopyMode(Value: Integer);
begin
  GetCanvas.CopyMode := Value;
end;

procedure TwrpCanvas.Set_Font(const Value: IgsFont);
begin
  GetCanvas.Font := InterfaceToObject(Value) as TFont;
end;

procedure TwrpCanvas.Set_Handle(Value: Integer);
begin
  GetCanvas.Handle := Value;
end;

procedure TwrpCanvas.Set_Pixels(X, Y: Integer; Value: Integer);
begin
  GetCanvas.Pixels[X, Y] := Value;
end;

procedure TwrpCanvas.Set_TextFlags(Value: Integer);
begin
  GetCanvas.TextFlags := Value;
end;

function TwrpCanvas.TextExtent(const Text: WideString): TgsSize;
begin
  Result := TgsSize(GetCanvas.TextExtent(Text));
end;

function TwrpCanvas.TextHeight(const Text: WideString): Integer;
begin
  Result := GetCanvas.TextHeight(Text);
end;

procedure TwrpCanvas.TextOut(X, Y: Integer; const Text: WideString);
begin
  GetCanvas.TextOut(X, Y, Text);
end;

function TwrpCanvas.TextWidth(const Text: WideString): Integer;
begin
  Result := GetCanvas.TextWidth(Text);
end;

procedure TwrpCanvas.TryLock;
begin
  GetCanvas.TryLock;
end;

procedure TwrpCanvas.Unlock;
begin
  GetCanvas.Unlock;
end;

procedure TwrpCanvas.Draw(X, Y: Integer; const Graphic: IgsGraphic);
begin
  GetCanvas.Draw(X, Y, InterfaceToObject(Graphic) as TGraphic);
end;

procedure TwrpCanvas.CopyRect(DestLeft, DestTop, DestRight,
  DestBottom: Integer; const Canvas: IgsCanvas; SourceLeft, SourceTop,
  SourceRight, SourceBottom: Integer);
var
  Source: TCanvas;
begin
  Source:= InterfaceToObject(Canvas) as TCanvas;
  if Assigned(Source) then
    GetCanvas.CopyRect(Rect(DestLeft, DestTop, DestRight, DestBottom),
      Source, Rect(SourceLeft, SourceTop, SourceRight, SourceBottom));
end;

procedure TwrpCanvas.FillRect(ALeft, ATop, ARight, ABottom: Integer);
begin
  GetCanvas.FillRect(Rect(ALeft, ATop, ARight, ABottom));
end;

function TwrpCanvas.Get_Brush: IgsBrush;
begin
  Result := GetGDCOleObject(GetCanvas.Brush) as IgsBrush;
end;

procedure TwrpCanvas.Set_Brush(const Value: IgsBrush);
begin
  GetCanvas.Brush := InterfaceToObject(Value) as TBrush;
end;

function TwrpCanvas.Get_Pen: IgsPen;
begin
  Result := GetGdcOLEObject(GetCanvas.Pen) as IgsPen;
end;

procedure TwrpCanvas.Set_Pen(const Value: IgsPen);
begin
  GetCanvas.Pen := InterfaceToObject(Value) as TPen;
end;

procedure TwrpCanvas.ClipRect(out Left, Top, Right,  Botton: OleVariant);
var
  LP: TRect;
begin
  LP := GetCanvas.ClipRect;
  Left := LP.Left;
  Top := LP.Top;
  Right := LP.Right;
  Botton := LP.Bottom;
end;

procedure TwrpCanvas.GetPenPos(out X, Y: OleVariant);
begin
  X := GetCanvas.PenPos.x;
  Y := GetCanvas.PenPos.y;
end;

procedure TwrpCanvas.SetPenPos(X, Y: Integer);
var
  LP: TPoint;
begin
  LP.x := X;
  LP.y := Y;
  GetCanvas.PenPos := LP;
end;

class function TwrpCanvas.CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Result := TCanvas.Create;
end;

procedure TwrpCanvas.DrawFocusRect(X1, Y1, X2, Y2: Integer);
begin
  GetCanvas.DrawFocusRect(Rect(X1, Y1, X2, Y2));
end;

procedure TwrpCanvas.FrameRect(X1, Y1, X2, Y2: Integer);
begin
  GetCanvas.FrameRect(Rect(X1, Y1, X2, Y2));
end;

procedure TwrpCanvas.PolyBezier(APoints: OleVariant);
var
  ar: TPointArray;
begin
  if VarArrayToPointArray(APoints, ar) then
    GetCanvas.PolyBezier(ar);
end;

procedure TwrpCanvas.PolyBezierTo(APoints: OleVariant);
var
  ar: TPointArray;
begin
  if VarArrayToPointArray(APoints, ar) then
    GetCanvas.PolyBezierTo(ar);
end;

procedure TwrpCanvas.Polygon(APoints: OleVariant);
var
  ar: TPointArray;
begin
  if VarArrayToPointArray(APoints, ar) then
    GetCanvas.Polygon(ar);
end;

procedure TwrpCanvas.Polyline(APoints: OleVariant);
var
  ar: TPointArray;
begin
  if VarArrayToPointArray(APoints, ar) then
    GetCanvas.Polyline(ar);
end;

procedure TwrpCanvas.StretchDraw(X1, Y1, X2, Y2: Integer;
  const AGraphic: IgsGraphic);
begin
  GetCanvas.StretchDraw(Rect(X1, Y1, X2, Y2), InterfaceToObject(AGraphic) as TGraphic);
end;

procedure TwrpCanvas.BrushCopy(DestX1, DestY1, DestX2, DestY2: Integer;
  const ABitmap: IgsBitmap; SourceX1, SourceY1, SourceX2, SourceY2,
  Color: Integer);
begin
  GetCanvas.BrushCopy(Rect(DestX1, DestY1, DestX2, DestY2), InterfaceToObject(ABitmap) as TBitmap,
    Rect(SourceX1, SourceY1, SourceX2, SourceY2), Color);
end;

procedure TwrpCanvas.TextRect(Left, Top, Right, Bottom, X, Y: Integer;
  const Text: WideString);
begin
  GetCanvas.TextRect(Rect(Left, Top, Right, Bottom), X, Y, Text);
end;

{ TwrpCustomControlBar }

function TwrpCustomControlBar.Get_AutoDock: WordBool;
begin
  Result := TCrackCustomControlBar(GetCustomControlBar).AutoDock;
end;

function TwrpCustomControlBar.Get_AutoDrag: WordBool;
begin
  Result := TCrackCustomControlBar(GetCustomControlBar).AutoDrag;
end;

function TwrpCustomControlBar.Get_RowSize: Integer;
begin
  Result := TCrackCustomControlBar(GetCustomControlBar).RowSize;
end;

function TwrpCustomControlBar.Get_RowSnap: WordBool;
begin
  Result := TCrackCustomControlBar(GetCustomControlBar).RowSnap;
end;

function TwrpCustomControlBar.GetCustomControlBar: TCustomControlBar;
begin
  Result := GetObject as TCustomControlBar;
end;

procedure TwrpCustomControlBar.Set_AutoDock(Value: WordBool);
begin
  TCrackCustomControlBar(GetCustomControlBar).AutoDock := Value;
end;

procedure TwrpCustomControlBar.Set_AutoDrag(Value: WordBool);
begin
  TCrackCustomControlBar(GetCustomControlBar).AutoDrag := Value;
end;

procedure TwrpCustomControlBar.Set_RowSize(Value: Integer);
begin
  TCrackCustomControlBar(GetCustomControlBar).RowSize := Value;
end;

procedure TwrpCustomControlBar.Set_RowSnap(Value: WordBool);
begin
  TCrackCustomControlBar(GetCustomControlBar).RowSnap := Value;
end;

procedure TwrpCustomControlBar.StickControls;
begin
  GetCustomControlBar.StickControls;
end;

function TwrpCustomControlBar.Get_Picture: IgsPicture;
begin
  Result := GetGdcOLEObject(GetCustomControlBar.Picture) as IgsPicture;
end;

procedure TwrpCustomControlBar.Set_Picture(const Value: IgsPicture);
begin
  GetCustomControlBar.Picture := InterfaceToObject(Value) as TPicture;
end;

{ TwrpToolWindow }

function TwrpToolWindow.Get_EdgeInner: TgsEdgeStyle;
begin
  Result := TgsEdgeStyle(GetToolWindow.EdgeInner);
end;

function TwrpToolWindow.Get_EdgeOuter: TgsEdgeStyle;
begin
  Result := TgsEdgeStyle(GetToolWindow.EdgeOuter);
end;

function TwrpToolWindow.GetToolWindow: TToolWindow;
begin
  Result := GetObject as TToolWindow;
end;

procedure TwrpToolWindow.Set_EdgeInner(Value: TgsEdgeStyle);
begin
  GetToolWindow.EdgeInner := TEdgeStyle(Value);
end;

procedure TwrpToolWindow.Set_EdgeOuter(Value: TgsEdgeStyle);
begin
  GetToolWindow.EdgeOuter := TEdgeStyle(Value);
end;

{ TwrpCoolBar }

function TwrpCoolBar.Get_BandBorderStyle: TgsBorderStyle;
begin
  Result := TgsBorderStyle(GetCoolBar.BandBorderStyle);
end;

function TwrpCoolBar.Get_FixedOrder: WordBool;
begin
  Result := GetCoolBar.FixedOrder;
end;

function TwrpCoolBar.Get_FixedSize: WordBool;
begin
  Result := GetCoolBar.FixedSize;
end;

function TwrpCoolBar.Get_Images: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetCoolBar.Images) as IgsCustomImageList;
end;

function TwrpCoolBar.Get_ShowText: WordBool;
begin
  Result := GetCoolBar.ShowText;
end;

function TwrpCoolBar.Get_Vertical: WordBool;
begin
  Result := GetCoolBar.Vertical;
end;

function TwrpCoolBar.GetCoolBar: TCoolBar;
begin
  Result := GetObject as TCoolBar;
end;

procedure TwrpCoolBar.Set_BandBorderStyle(Value: TgsBorderStyle);
begin
  GetCoolBar.BandBorderStyle := TBorderStyle(Value);
end;

procedure TwrpCoolBar.Set_FixedOrder(Value: WordBool);
begin
  GetCoolBar.FixedOrder := Value;
end;

procedure TwrpCoolBar.Set_FixedSize(Value: WordBool);
begin
  GetCoolBar.FixedSize := Value;
end;

procedure TwrpCoolBar.Set_Images(const Value: IgsCustomImageList);
begin
  GetCoolBar.Images := InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpCoolBar.Set_ShowText(Value: WordBool);
begin
  GetCoolBar.ShowText := Value;
end;

procedure TwrpCoolBar.Set_Vertical(Value: WordBool);
begin
  GetCoolBar.Vertical := Value;
end;

function TwrpCoolBar.Get_Bitmap: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetCoolBar.Bitmap) as IgsBitmap;
end;

procedure TwrpCoolBar.Set_Bitmap(const Value: IgsBitmap);
begin
  GetCoolBar.Bitmap := InterfaceToObject(Value) as TBitmap;
end;

{ TwrpCommonCalendar }

function TwrpCommonCalendar.Get_Date: TDateTime;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).Date;
end;

function TwrpCommonCalendar.Get_DateTime: TDateTime;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).DateTime;
end;

function TwrpCommonCalendar.Get_MaxDate: TDateTime;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).MaxDate;
end;

function TwrpCommonCalendar.Get_MinDate: TDateTime;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).MinDate;
end;

function TwrpCommonCalendar.GetCommonCalendar: TCommonCalendar;
begin
  Result := GetObject as TCommonCalendar;
end;

procedure TwrpCommonCalendar.Set_Date(Value: TDateTime);
begin
  TCrackCommonCalendar(GetCommonCalendar).Date := Value;
end;

procedure TwrpCommonCalendar.Set_DateTime(Value: TDateTime);
begin
  TCrackCommonCalendar(GetCommonCalendar).DateTime := Value;
end;

procedure TwrpCommonCalendar.Set_MaxDate(Value: TDateTime);
begin
  TCrackCommonCalendar(GetCommonCalendar).MaxDate := Value;
end;

procedure TwrpCommonCalendar.Set_MinDate(Value: TDateTime);
begin
  TCrackCommonCalendar(GetCommonCalendar).MinDate := Value;
end;

function TwrpCommonCalendar.Get_EndDate: TDateTime;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).EndDate;
end;

function TwrpCommonCalendar.Get_FirstDayOfWeek: TgsCalDayOfWeek;
begin
  Result := TgsCalDayofWeek(TCrackCommonCalendar(GetCommonCalendar).FirstDayOfWeek);
end;

function TwrpCommonCalendar.Get_MaxSelectRange: Integer;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).MaxSelectRange;
end;

function TwrpCommonCalendar.Get_MultiSelect: WordBool;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).MultiSelect;
end;

function TwrpCommonCalendar.Get_ShowToday: WordBool;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).ShowToday;
end;

function TwrpCommonCalendar.Get_ShowTodayCircle: WordBool;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).ShowTodayCircle;
end;

function TwrpCommonCalendar.Get_WeekNumbers: WordBool;
begin
  Result := TCrackCommonCalendar(GetCommonCalendar).WeekNumbers;
end;

procedure TwrpCommonCalendar.Set_EndDate(Value: TDateTime);
begin
  TCrackCommonCalendar(GetCommonCalendar).EndDate := Value;
end;

procedure TwrpCommonCalendar.Set_FirstDayOfWeek(Value: TgsCalDayOfWeek);
begin
  TCrackCommonCalendar(GetCommonCalendar).FirstDayOfWeek := TCalDayOfWeek(Value);
end;

procedure TwrpCommonCalendar.Set_MaxSelectRange(Value: Integer);
begin
  TCrackCommonCalendar(GetCommonCalendar).MaxSelectRange := Value;
end;

procedure TwrpCommonCalendar.Set_MultiSelect(Value: WordBool);
begin
  TCrackCommonCalendar(GetCommonCalendar).MultiSelect := Value;
end;

procedure TwrpCommonCalendar.Set_ShowToday(Value: WordBool);
begin
  TCrackCommonCalendar(GetCommonCalendar).ShowToday := Value;
end;

procedure TwrpCommonCalendar.Set_ShowTodayCircle(Value: WordBool);
begin
  TCrackCommonCalendar(GetCommonCalendar).ShowTodayCircle := Value;
end;

procedure TwrpCommonCalendar.Set_WeekNumbers(Value: WordBool);
begin
  TCrackCommonCalendar(GetCommonCalendar).WeekNumbers := Value;
end;

{ TwrpDateTimePicker }

function TwrpDateTimePicker.Get_CalAlignment: TgsDTCalAlignment;
begin
  Result := TgsDTCalAlignment(GetDateTimePicker.CalAlignment);
end;

function TwrpDateTimePicker.Get_Checked: WordBool;
begin
  Result := GetDateTimePicker.Checked;
end;

function TwrpDateTimePicker.Get_DateFormat: TgsDTDateFormat;
begin
  Result := TgsDTDateFormat(GetDateTimePicker.DateFormat);
end;

function TwrpDateTimePicker.Get_DateMode: TgsDTDateMode;
begin
  Result := TgsDTDateMode(GetDateTimePicker.DateMode);
end;

function TwrpDateTimePicker.Get_DroppedDown: WordBool;
begin
  Result := GetDateTimePicker.DroppedDown;
end;

function TwrpDateTimePicker.Get_Kind: TgsDateTimeKind;
begin
  Result := TgsDateTimeKind(GetDateTimePicker.Kind);
end;

function TwrpDateTimePicker.Get_ParseInput: WordBool;
begin
  Result := GetDateTimePicker.ParseInput;
end;

function TwrpDateTimePicker.Get_ShowCheckbox: WordBool;
begin
  Result := GetDateTimePicker.ShowCheckbox;
end;

function TwrpDateTimePicker.Get_Time: TDateTime;
begin
  Result := GetDateTimePicker.Time;
end;

function TwrpDateTimePicker.GetDateTimePicker: TDateTimePicker;
begin
  Result := GetObject as TDateTimePicker;
end;

procedure TwrpDateTimePicker.Set_CalAlignment(Value: TgsDTCalAlignment);
begin
  GetDateTimePicker.CalAlignment := TDTCalAlignment(Value);
end;

procedure TwrpDateTimePicker.Set_Checked(Value: WordBool);
begin
  GetDateTimePicker.Checked := Value;
end;

procedure TwrpDateTimePicker.Set_DateFormat(Value: TgsDTDateFormat);
begin
  GetDateTimePicker.DateFormat := TDTDateFormat(Value);
end;

procedure TwrpDateTimePicker.Set_DateMode(Value: TgsDTDateMode);
begin
  GetDateTimePicker.DateMode := TDTDateMode(Value);
end;

procedure TwrpDateTimePicker.Set_Kind(Value: TgsDateTimeKind);
begin
  GetDateTimePicker.Kind := TDateTimeKind(Value);
end;

procedure TwrpDateTimePicker.Set_ParseInput(Value: WordBool);
begin
  GetDateTimePicker.ParseInput := Value;
end;

procedure TwrpDateTimePicker.Set_ShowCheckbox(Value: WordBool);
begin
  GetDateTimePicker.ShowCheckbox := Value;
end;

procedure TwrpDateTimePicker.Set_Time(Value: TDateTime);
begin
  GetDateTimePicker.Time := Value;
end;

{ TwrpDriveComboBox }

function TwrpDriveComboBox.Get_DirList: IgsDirectoryListBox;
begin
  Result := GetGdcOLEObject(GetDriveComboBox.DirList) as IgsDirectoryListBox;
end;

function TwrpDriveComboBox.Get_Drive: Byte;
begin
  Result := Ord(GetDriveComboBox.Drive);
end;

function TwrpDriveComboBox.Get_TextCase: TgsTextCase;
begin
  Result := TgsTextCase(GetDriveComboBox.TextCase);
end;

function TwrpDriveComboBox.GetDriveComboBox: TDriveComboBox;
begin
  Result := GetObject as TDriveComboBox;
end;

procedure TwrpDriveComboBox.Set_DirList(const Value: IgsDirectoryListBox);
begin
  GetDriveComboBox.DirList := InterfaceToObject(Value) as TDirectoryListBox;
end;

procedure TwrpDriveComboBox.Set_Drive(Value: Byte);
begin
  GetDriveComboBox.Drive := Chr(Value);
end;

procedure TwrpDriveComboBox.Set_TextCase(Value: TgsTextCase);
begin
  GetDriveComboBox.TextCase := TTextCase(Value);
end;

{ TwrpFileListBox }

procedure TwrpFileListBox.ApplyFilePath(const EditText: WideString);
begin
  GetFileListBox.ApplyFilePath(EditText);
end;

function TwrpFileListBox.Get_Directory: WideString;
begin
  Result := GetFileListBox.Directory;
end;

function TwrpFileListBox.Get_Drive: Byte;
begin
  Result := Ord(GetFileListBox.Drive);
end;

function TwrpFileListBox.Get_FileEdit: IgsEdit;
begin
  Result := GetGDCOleObject(GetFileListBox.FileEdit) as IgsEdit;
end;

function TwrpFileListBox.Get_FileName: WideString;
begin
  Result := GetFileListBox.FileName;
end;

function TwrpFileListBox.Get_Mask: WideString;
begin
  Result := GetFileListBox.Mask;
end;

function TwrpFileListBox.Get_ShowGlyphs: WordBool;
begin
  Result := GetFileListBox.ShowGlyphs;
end;

function TwrpFileListBox.GetFileListBox: TFileListBox;
begin
  Result := GetObject as TFileListBox;
end;

procedure TwrpFileListBox.Set_Directory(const Value: WideString);
begin
  GetFileListBox.Directory := Value;
end;

procedure TwrpFileListBox.Set_Drive(Value: Byte);
begin
  GetFileListBox.Drive := Chr(Value);
end;

procedure TwrpFileListBox.Set_FileEdit(const Value: IgsEdit);
begin
  GetFileListBox.FileEdit := InterfaceToObject(Value) as TEdit;
end;

procedure TwrpFileListBox.Set_FileName(const Value: WideString);
begin
  GetFileListBox.FileName := Value;
end;

procedure TwrpFileListBox.Set_Mask(const Value: WideString);
begin
  GetFileListBox.Mask := Value;
end;

procedure TwrpFileListBox.Set_ShowGlyphs(Value: WordBool);
begin
  GetFileListBox.ShowGlyphs := Value;
end;

{ TwrpFilterComboBox }

function TwrpFilterComboBox.Get_FileList: IgsFileListBox;
begin
  Result := GetGdcOLEObject(GetFilterComboBox.FileList) as IgsFileListBox;
end;

function TwrpFilterComboBox.Get_Filter: WideString;
begin
  Result := GetFilterComboBox.Filter;
end;

function TwrpFilterComboBox.Get_Mask: WideString;
begin
  Result := GetFilterComboBox.Mask;
end;

function TwrpFilterComboBox.GetFilterComboBox: TFilterComboBox;
begin
  Result := GetObject as TFilterComboBox;
end;

procedure TwrpFilterComboBox.Set_FileList(const Value: IgsFileListBox);
begin
  GetFilterComboBox.FileList := InterfaceToObject(Value) as TFileListBox;
end;

procedure TwrpFilterComboBox.Set_Filter(const Value: WideString);
begin
  GetFilterComboBox.Filter := Value;
end;

{ TwrpGauge }

procedure TwrpGauge.AddProgress(Value: Integer);
begin
  GetGauge.AddProgress(Value);
end;

function TwrpGauge.Get_BackColor: Integer;
begin
  Result := GetGauge.BackColor;
end;

function TwrpGauge.Get_BorderStyle: TgsBorderStyle;
begin
  Result := TgsBorderStyle(GetGauge.BorderStyle);
end;

function TwrpGauge.Get_ForeColor: Integer;
begin
  Result := GetGauge.ForeColor;
end;

function TwrpGauge.Get_Kind: TgsGaugeKind;
begin
  Result := TgsGaugekind(GetGauge.Kind);
end;

function TwrpGauge.Get_MaxValue: Integer;
begin
  Result := GetGauge.MaxValue;
end;

function TwrpGauge.Get_MinValue: Integer;
begin
  Result := GetGauge.MinValue;
end;

function TwrpGauge.Get_PercentDone: Integer;
begin
  Result := GetGauge.PercentDone;
end;

function TwrpGauge.Get_Progress: Integer;
begin
  Result := GetGauge.Progress;
end;

function TwrpGauge.Get_ShowText: WordBool;
begin
  Result := GetGauge.ShowText;
end;

function TwrpGauge.GetGauge: TGauge;
begin
  Result := GetObject as TGauge;
end;

procedure TwrpGauge.Set_BackColor(Value: Integer);
begin
  GetGauge.BackColor := Value;
end;

procedure TwrpGauge.Set_BorderStyle(Value: TgsBorderStyle);
begin
  GetGauge.BorderStyle := TBorderStyle(Value);
end;

procedure TwrpGauge.Set_ForeColor(Value: Integer);
begin
  GetGauge.ForeColor := Value;
end;

procedure TwrpGauge.Set_Kind(Value: TgsGaugeKind);
begin
  GetGauge.Kind := TGaugeKind(Value);
end;

procedure TwrpGauge.Set_MaxValue(Value: Integer);
begin
  GetGauge.MaxValue := Value;
end;

procedure TwrpGauge.Set_MinValue(Value: Integer);
begin
  GetGauge.MinValue := Value;
end;

procedure TwrpGauge.Set_Progress(Value: Integer);
begin
  GetGauge.Progress := Value;
end;

procedure TwrpGauge.Set_ShowText(Value: WordBool);
begin
  GetGauge.ShowHint := Value;
end;

{ TwrpImage }

function TwrpImage.Get_Center: WordBool;
begin
  Result := GetImage.Center;
end;

function TwrpImage.Get_IncrementalDisplay: WordBool;
begin
  Result := GetImage.IncrementalDisplay;
end;

function TwrpImage.Get_Stretch: WordBool;
begin
  Result := GetImage.Stretch;
end;

function TwrpImage.Get_Transparent: WordBool;
begin
  Result := GetImage.Transparent;
end;

function TwrpImage.GetImage: TImage;
begin
  Result := GetObject as TImage;
end;

procedure TwrpImage.Set_Center(Value: WordBool);
begin
  GetImage.Center := Value;
end;

procedure TwrpImage.Set_IncrementalDisplay(Value: WordBool);
begin
  GetImage.IncrementalDisplay := Value;
end;

procedure TwrpImage.Set_Stretch(Value: WordBool);
begin
  GetImage.Stretch := Value;
end;

procedure TwrpImage.Set_Transparent(Value: WordBool);
begin
  GetImage.Transparent := Value;
end;

function TwrpImage.Get_Picture: IgsPicture;
begin
  Result := GetGdcOLEObject(GetImage.Picture) as IgsPicture;
end;

procedure TwrpImage.Set_Picture(const Value: IgsPicture);
begin
  GetImage.Picture := InterfaceToObject(Value) as TPicture;
end;

{ TwrpPageScroller }

function TwrpPageScroller.Get_AutoScroll: WordBool;
begin
  Result := GetPageScroller.AutoScroll;
end;

function TwrpPageScroller.Get_ButtonSize: Integer;
begin
  Result := GetPageScroller.ButtonSize;
end;

function TwrpPageScroller.Get_Control: IgsWinControl;
begin
  Result := GetGdcOLEObject(GetPageScroller.Control) as IgsWinControl;
end;

function TwrpPageScroller.Get_DragScroll: WordBool;
begin
  Result := GetPageScroller.DragScroll;
end;

function TwrpPageScroller.Get_Margin: Integer;
begin
  Result := GetPageScroller.Margin;
end;

function TwrpPageScroller.Get_Orientation: TgsPageScrollerOrientation;
begin
  Result := TgsPageScrollerOrientation(GetPageScroller.Orientation);
end;

function TwrpPageScroller.Get_Position: Integer;
begin
  Result := GetPageScroller.Position;
end;

function TwrpPageScroller.GetButtonState(
  Button: TgsPageScrollerButton): TgsPageScrollerButtonState;
begin
  Result := TgsPageScrollerButtonState(GetPageScroller.GetButtonState(
    TPageScrollerButton(Button)));
end;

function TwrpPageScroller.GetPageScroller: TPageScroller;
begin
  Result := GetObject as TPageScroller;
end;

procedure TwrpPageScroller.Set_AutoScroll(Value: WordBool);
begin
  GetPageScroller.AutoScroll := Value;
end;

procedure TwrpPageScroller.Set_ButtonSize(Value: Integer);
begin
  GetPageScroller.ButtonSize := Value;
end;

procedure TwrpPageScroller.Set_Control(const Value: IgsWinControl);
begin
  GetPageScroller.Control := InterfaceToObject(Value) as TWinControl;
end;

procedure TwrpPageScroller.Set_DragScroll(Value: WordBool);
begin
  GetPageScroller.DragScroll := Value;
end;

procedure TwrpPageScroller.Set_Margin(Value: Integer);
begin
  GetPageScroller.Margin := Value;
end;

procedure TwrpPageScroller.Set_Orientation(
  Value: TgsPageScrollerOrientation);
begin
  GetPageScroller.Orientation := TPageScrollerOrientation(Value);
end;

procedure TwrpPageScroller.Set_Position(Value: Integer);
begin
  GetPageScroller.Position := Value;
end;

{ TwrpProgressBar }

function TwrpProgressBar.Get_Max: Integer;
begin
  Result := GetProgressBar.Max;
end;

function TwrpProgressBar.Get_Min: Integer;
begin
  Result := GetProgressBar.Min;
end;

function TwrpProgressBar.Get_Orientation: TgsProgressBarOrientation;
begin
  Result := TgsProgressBarOrientation(GetProgressBar.Orientation);
end;

function TwrpProgressBar.Get_Smooth: WordBool;
begin
  Result := GetProgressBar.Smooth;
end;

function TwrpProgressBar.Get_Step: Integer;
begin
  Result := GetProgressBar.Step;
end;

function TwrpProgressBar.GetProgressBar: TProgressBar;
begin
  Result := GetObject as TProgressBar;
end;

procedure TwrpProgressBar.Set_Max(Value: Integer);
begin
  GetProgressBar.Max := Value;
end;

procedure TwrpProgressBar.Set_Min(Value: Integer);
begin
  GetProgressBar.Min := Value;
end;

procedure TwrpProgressBar.Set_Orientation(
  Value: TgsProgressBarOrientation);
begin
  GetProgressBar.Orientation := TProgressBarOrientation(Value);
end;

procedure TwrpProgressBar.Set_Smooth(Value: WordBool);
begin
  GetProgressBar.Smooth := Value;
end;

procedure TwrpProgressBar.Set_Step(Value: Integer);
begin
  GetProgressBar.Step := Value;
end;

procedure TwrpProgressBar.StepBy(Delta: Integer);
begin
  GetProgressBar.StepBy(Delta);
end;

procedure TwrpProgressBar.StepIt;
begin
  GetProgressBar.StepIt;
end;

function TwrpProgressBar.Get_Position: Integer;
begin
  Result := GetProgressBar.Position;
end;

procedure TwrpProgressBar.Set_Position(Value: Integer);
begin
  GetProgressBar.Position := Value;
end;

{ TwrpScrollBox }

function TwrpScrollBox.Get_BorderStyle: TgsBorderStyle;
begin
  Result := TgsBorderStyle(GetScrollBox.BorderStyle);
end;

function TwrpScrollBox.GetScrollBox: TScrollBox;
begin
  Result := GetObject as TScrollBox;
end;

procedure TwrpScrollBox.Set_BorderStyle(Value: TgsBorderStyle);
begin
  GetScrollBox.BorderStyle := TBorderStyle(Value);
end;

{ TwrpShape }

function TwrpShape.Get_Shape: TgsShapeType;
begin
  Result := TgsShapeType(GetShape.Shape);
end;

function TwrpShape.GetShape: TShape;
begin
  Result := GetObject as TShape;
end;

procedure TwrpShape.Set_Shape(Value: TgsShapeType);
begin
  GetShape.Shape := TShapeType(Value);
end;

function TwrpShape.Get_Brush: IgsBrush;
begin
  Result := GetGdcOLEObject(GetShape.Brush) as IgsBrush;
end;

function TwrpShape.Get_Pen: IgsPen;
begin
  Result := GetGdcOLEObject(GetShape.Pen) as IgsPen;
end;

procedure TwrpShape.Set_Brush(const Value: IgsBrush);
begin
  GetShape.Brush := InterfaceToObject(Value) as TBrush;
end;

procedure TwrpShape.Set_Pen(const Value: IgsPen);
begin
  GetShape.Pen := InterfaceToObject(Value) as TPen;
end;

procedure TwrpShape.StyleChanged(const Sender: IgsObject);
begin
  GetShape.StyleChanged(InterfaceToObject(Sender));
end;

{ TwrpSpinButton }

function TwrpSpinButton.Get_DownNumGlyphs: Shortint;
begin
  Result := GetSpinButton.DownNumGlyphs;
end;

function TwrpSpinButton.Get_FocusControl: IgsWinControl;
begin
  Result := GetGdcOLEObject(GetSpinButton.FocusControl) as IgsWinControl;
end;

function TwrpSpinButton.Get_UpNumGlyphs: Shortint;
begin
  Result := GetSpinButton.UpNumGlyphs;
end;

function TwrpSpinButton.GetSpinButton: TSpinButton;
begin
  Result := GetObject as TSpinButton;
end;

procedure TwrpSpinButton.Set_DownNumGlyphs(Value: Shortint);
begin
  if (0 < Value) and (Value < 5) then
    GetSpinButton.DownNumGlyphs := Value;
end;

procedure TwrpSpinButton.Set_FocusControl(const Value: IgsWinControl);
begin
  GetSpinButton.FocusControl := InterfaceToObject(Value) as TWinControl;
end;

procedure TwrpSpinButton.Set_UpNumGlyphs(Value: Shortint);
begin
  if (0 < Value) and (Value < 5) then
    GetSpinButton.UpNumGlyphs := Value;
end;

function TwrpSpinButton.Get_DownGlyph: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetSpinButton.DownGlyph) as IgsBitmap;
end;

function TwrpSpinButton.Get_UpGlyph: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetSpinButton.UpGlyph) as IgsBitmap;
end;

procedure TwrpSpinButton.Set_DownGlyph(const Value: IgsBitmap);
begin
  GetSpinButton.DownGlyph := InterfaceToObject(Value) as TBitmap;
end;

procedure TwrpSpinButton.Set_UpGlyph(const Value: IgsBitmap);
begin
  GetSpinButton.UpGlyph := InterfaceToObject(Value) as TBitmap;
end;

{ TwrpSpinEdit }

function TwrpSpinEdit.Get_Button: IgsSpinButton;
begin
  Result := GetGdcOLEObject(GetSpinEdit.Button) as IgsSpinButton;
end;

function TwrpSpinEdit.Get_EditorEnabled: WordBool;
begin
  Result := GetSpinEdit.EditorEnabled;
end;

function TwrpSpinEdit.Get_Increment: Integer;
begin
  Result := GetSpinEdit.Increment;
end;

function TwrpSpinEdit.Get_MaxValue: Integer;
begin
  Result := GetSpinEdit.MaxValue;
end;

function TwrpSpinEdit.Get_MinValue: Integer;
begin
  Result := GetSpinEdit.MinValue;
end;

function TwrpSpinEdit.Get_Value: Integer;
begin
  Result := GetSpinEdit.Value;
end;

function TwrpSpinEdit.GetSpinEdit: TSpinEdit;
begin
  Result := GetObject as TSpinEdit;
end;

procedure TwrpSpinEdit.Set_EditorEnabled(Value: WordBool);
begin
  GetSpinEdit.EditorEnabled := Value;
end;

procedure TwrpSpinEdit.Set_Increment(Value: Integer);
begin
  GetSpinEdit.Increment := Value;
end;

procedure TwrpSpinEdit.Set_MaxValue(Value: Integer);
begin
  GetSpinEdit.MaxValue := Value;
end;

procedure TwrpSpinEdit.Set_MinValue(Value: Integer);
begin
  GetSpinEdit.MinValue := Value;
end;

procedure TwrpSpinEdit.Set_Value(Value: Integer);
begin
  GetSpinEdit.Value := Value;
end;

{ TwrpToolBar }

function TwrpToolBar.Get_ButtonCount: Integer;
begin
  Result := GetToolBar.ButtonCount;
end;

function TwrpToolBar.Get_ButtonHeight: Integer;
begin
  Result := GetToolBar.ButtonHeight;
end;

function TwrpToolBar.Get_ButtonWidth: Integer;
begin
  Result := GetToolBar.ButtonWidth;
end;

function TwrpToolBar.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetToolBar.Canvas) as IgsCanvas;
end;

function TwrpToolBar.Get_DisabledImages: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetToolBar.DisabledImages) as IgsCustomImageList;
end;

function TwrpToolBar.Get_Flat: WordBool;
begin
  Result := GetToolBar.Flat;
end;

function TwrpToolBar.Get_HotImages: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetToolBar.HotImages) as IgsCustomImageList;
end;

function TwrpToolBar.Get_Images: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetToolBar.Images) as IgsCustomImageList;
end;

function TwrpToolBar.Get_Indent: Integer;
begin
  Result := GetToolBar.Indent;
end;

function TwrpToolBar.Get_List: WordBool;
begin
  Result := GetToolBar.List;
end;

function TwrpToolBar.Get_RowCount: Integer;
begin
  Result := GetToolBar.RowCount;
end;

function TwrpToolBar.Get_ShowCaptions: WordBool;
begin
  Result := GetToolBar.ShowCaptions;
end;

function TwrpToolBar.Get_Transparent: WordBool;
begin
  Result := GetToolBar.Transparent;
end;

function TwrpToolBar.Get_Wrapable: WordBool;
begin
  Result := GetToolBar.Wrapable;
end;

function TwrpToolBar.GetToolBar: TToolBar;
begin
  Result := GetObject as TToolBar;
end;

procedure TwrpToolBar.Set_ButtonHeight(Value: Integer);
begin
  GetToolBar.ButtonHeight := Value;
end;

procedure TwrpToolBar.Set_ButtonWidth(Value: Integer);
begin
  GetToolBar.ButtonWidth := Value;
end;

procedure TwrpToolBar.Set_DisabledImages(const Value: IgsCustomImageList);
begin
  GetToolBar.DisabledImages := InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpToolBar.Set_Flat(Value: WordBool);
begin
  GetToolBar.Flat := Value;
end;

procedure TwrpToolBar.Set_HotImages(const Value: IgsCustomImageList);
begin
  GetToolBar.HotImages := InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpToolBar.Set_Images(const Value: IgsCustomImageList);
begin
  GetToolBar.Images := InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpToolBar.Set_Indent(Value: Integer);
begin
  GetToolBar.Indent := Value;
end;

procedure TwrpToolBar.Set_List(Value: WordBool);
begin
  GetToolBar.List := Value;
end;

procedure TwrpToolBar.Set_ShowCaptions(Value: WordBool);
begin
  GetToolBar.ShowCaptions := Value;
end;

procedure TwrpToolBar.Set_Transparent(Value: WordBool);
begin
  GetToolBar.Transparent := Value;
end;

procedure TwrpToolBar.Set_Wrapable(Value: WordBool);
begin
  GetToolBar.Wrapable := Value;
end;

function TwrpToolBar.Get_Buttons(Index: Integer): IgsToolButton;
begin
  Result := GetGdcOLEObject(GetToolBar.Buttons[Index]) as IgsToolButton;
end;

function TwrpToolBar.TrackMenu(const Button: IgsToolButton): WordBool;
begin
  Result := GetToolBar.TrackMenu(InterfaceToObject(Button) as TToolButton);
end;

{ TwrpTrackBar }

function TwrpTrackBar.Get_Frequency: Integer;
begin
  Result := GetTrackBar.Frequency;
end;

function TwrpTrackBar.Get_LineSize: Integer;
begin
  Result := GetTrackBar.LineSize;
end;

function TwrpTrackBar.Get_Max: Integer;
begin
  Result := GetTrackBar.Max;
end;

function TwrpTrackBar.Get_Min: Integer;
begin
  Result := GetTrackBar.Min;
end;

function TwrpTrackBar.Get_Orientation: TgsTrackBarOrientation;
begin
  Result := TgsTrackBarOrientation(GetTrackBar.Orientation);
end;

function TwrpTrackBar.Get_PageSize: Integer;
begin
  Result := GetTrackBar.PageSize;
end;

function TwrpTrackBar.Get_SelEnd: Integer;
begin
  Result := GetTrackBar.SelEnd;
end;

function TwrpTrackBar.Get_SelStart: Integer;
begin
  Result := GetTrackBar.SelStart;
end;

function TwrpTrackBar.Get_SliderVisible: WordBool;
begin
  Result := GetTrackBar.SliderVisible;
end;

function TwrpTrackBar.Get_ThumbLength: Integer;
begin
  Result := GetTrackBar.ThumbLength;
end;

function TwrpTrackBar.Get_TickMarks: TgsTickMark;
begin
  Result := TgsTickMark(GetTrackBar.TickMarks);
end;

function TwrpTrackBar.Get_TickStyle: TgsTickStyle;
begin
  Result := TgsTickStyle(GetTrackBar.TickStyle);
end;

function TwrpTrackBar.GetTrackBar: TTrackBar;
begin
  Result := GetObject as TTrackBar;
end;

procedure TwrpTrackBar.Set_Frequency(Value: Integer);
begin
  GetTrackBar.Frequency := Value;
end;

procedure TwrpTrackBar.Set_LineSize(Value: Integer);
begin
  GetTrackBar.LineSize := Value;
end;

procedure TwrpTrackBar.Set_Max(Value: Integer);
begin
  GetTrackBar.Max := Value;
end;

procedure TwrpTrackBar.Set_Min(Value: Integer);
begin
  GetTrackBar.Min := Value;
end;

procedure TwrpTrackBar.Set_Orientation(Value: TgsTrackBarOrientation);
begin
  GetTrackBar.Orientation := TTrackBarOrientation(Value);
end;

procedure TwrpTrackBar.Set_PageSize(Value: Integer);
begin
  GetTrackBar.PageSize := Value;
end;

procedure TwrpTrackBar.Set_SelEnd(Value: Integer);
begin
  GetTrackBar.SelEnd := Value;
end;

procedure TwrpTrackBar.Set_SelStart(Value: Integer);
begin
  GetTrackBar.SelStart := Value;
end;

procedure TwrpTrackBar.Set_SliderVisible(Value: WordBool);
begin
  GetTrackBar.SliderVisible := Value;
end;

procedure TwrpTrackBar.Set_ThumbLength(Value: Integer);
begin
  GetTrackBar.ThumbLength := Value;
end;

procedure TwrpTrackBar.Set_TickMarks(Value: TgsTickMark);
begin
  GetTrackBar.TickMarks := TTickMark(Value);
end;

procedure TwrpTrackBar.Set_TickStyle(Value: TgsTickStyle);
begin
  GetTrackBar.TickStyle := TTickStyle(Value);
end;

function TwrpTrackBar.Get_Position: Integer;
begin
  Result := GetTrackBar.Position;
end;

procedure TwrpTrackBar.Set_Position(Value: Integer);
begin
  GetTrackBar.Position := Value;
end;

procedure TwrpTrackBar.SetTick(Value: Integer);
begin
  GetTrackBar.SetTick(Value);
end;

{ TwrpCustomUpDown }

function TwrpCustomUpDown.Get_AlignButton: TgsUDAlignButton;
begin
  Result := TgsUDAlignButton(TCrackCustomUpDown(GetCustomUpDown).AlignButton);
end;

function TwrpCustomUpDown.Get_ArrowKeys: WordBool;
begin
  Result := TCrackCustomUpDown(GetCustomUpDown).ArrowKeys;
end;

function TwrpCustomUpDown.Get_Associate: IgsWinControl;
begin
  Result := GetGdcOLEObject(TCrackCustomUpDown(GetCustomUpDown).Associate) as IgsWinControl;
end;

function TwrpCustomUpDown.Get_Increment: Integer;
begin
  Result := TCrackCustomUpDown(GetCustomUpDown).Increment;
end;

function TwrpCustomUpDown.Get_Max: Smallint;
begin
  Result := TCrackCustomUpDown(GetCustomUpDown).Max;
end;

function TwrpCustomUpDown.Get_Min: Smallint;
begin
  Result := TCrackCustomUpDown(GetCustomUpDown).Min;
end;

function TwrpCustomUpDown.Get_Orientation: TgsUDOrientation;
begin
  Result := TgsUDOrientation(TCrackCustomUpDown(GetCustomUpDown).Orientation);
end;

function TwrpCustomUpDown.Get_Position: Smallint;
begin
  Result := TCrackCustomUpDown(GetCustomUpDown).Position;
end;

function TwrpCustomUpDown.Get_Thousands: WordBool;
begin
  Result := TCrackCustomUpDown(GetCustomUpDown).Thousands;
end;

function TwrpCustomUpDown.Get_Wrap: WordBool;
begin
  Result := TCrackCustomUpDown(GetCustomUpDown).Wrap;
end;

function TwrpCustomUpDown.GetCustomUpDown: TCustomUpDown;
begin
  Result := GetObject as TCustomUpDown;
end;

procedure TwrpCustomUpDown.Set_AlignButton(Value: TgsUDAlignButton);
begin
  TCrackCustomUpDown(GetCustomUpDown).AlignButton := TUDAlignButton(Value);
end;

procedure TwrpCustomUpDown.Set_ArrowKeys(Value: WordBool);
begin
  TCrackCustomUpDown(GetCustomUpDown).ArrowKeys := Value;
end;

procedure TwrpCustomUpDown.Set_Associate(const Value: IgsWinControl);
begin
  TCrackCustomUpDown(GetCustomUpDown).Associate := InterfaceToObject(Value) as TWinControl;
end;

procedure TwrpCustomUpDown.Set_Increment(Value: Integer);
begin
  TCrackCustomUpDown(GetCustomUpDown).Increment := Value;
end;

procedure TwrpCustomUpDown.Set_Max(Value: Smallint);
begin
  TCrackCustomUpDown(GetCustomUpDown).Max := Value;
end;

procedure TwrpCustomUpDown.Set_Min(Value: Smallint);
begin
  TCrackCustomUpDown(GetCustomUpDown).Min := Value;
end;

procedure TwrpCustomUpDown.Set_Orientation(Value: TgsUDOrientation);
begin
  TCrackCustomUpDown(GetCustomUpDown).Orientation := TUDOrientation(Value);
end;

procedure TwrpCustomUpDown.Set_Position(Value: Smallint);
begin
  TCrackCustomUpDown(GetCustomUpDown).Position := Value;
end;

procedure TwrpCustomUpDown.Set_Thousands(Value: WordBool);
begin
  TCrackCustomUpDown(GetCustomUpDown).Thousands := Value;
end;

procedure TwrpCustomUpDown.Set_Wrap(Value: WordBool);
begin
  TCrackCustomUpDown(GetCustomUpDown).Wrap := Value;
end;

{ TwrpGraphic }

function TwrpGraphic.Get_Empty: WordBool;
begin
  Result := GetGraphic.Empty;
end;

function TwrpGraphic.Get_Height: Integer;
begin
  Result := GetGraphic.Height;
end;

function TwrpGraphic.Get_Modified: WordBool;
begin
  Result := GetGraphic.Modified;
end;

function TwrpGraphic.Get_Palette: LongWord;
begin
  Result := GetGraphic.Palette;
end;

function TwrpGraphic.Get_PaletteModified: WordBool;
begin
  Result := GetGraphic.PaletteModified;
end;

function TwrpGraphic.Get_Transparent: WordBool;
begin
  Result := GetGraphic.Transparent;
end;

function TwrpGraphic.Get_Width: Integer;
begin
  Result := GetGraphic.Width;
end;

function TwrpGraphic.GetGraphic: TGraphic;
begin
  Result := GetObject as TGraphic;
end;

procedure TwrpGraphic.LoadFromClipboardFormat(AFormat: Word;
  AData: LongWord; APalette: LongWord);
begin
  GetGraphic.LoadFromClipboardFormat(AFormat, AData, APalette);
end;

procedure TwrpGraphic.LoadFromFile(const AFileName: WideString);
begin
  GetGraphic.LoadFromFile(AFileName);
end;

procedure TwrpGraphic.SaveToClipboardFormat(var AFormat, AData,
  APalette: OleVariant);
var
  Format: Word;
  Data: THandle;
  Palette: HPalette;
begin
  Format := AFormat;
  Data := AData;
  Palette := APalette;
  GetGraphic.SaveToClipboardFormat(Format, Data, Palette);
  AFormat := Format;
  AData := LongInt(Data);
  APalette := LongInt(Palette);
end;

procedure TwrpGraphic.SaveToFile(const AFileName: WideString);
begin
  GetGraphic.SaveToFile(AFileName);
end;

procedure TwrpGraphic.Set_Height(Value: Integer);
begin
  GetGraphic.Height := Value;
end;

procedure TwrpGraphic.Set_Modified(Value: WordBool);
begin
  GetGraphic.Modified := Value;
end;

procedure TwrpGraphic.Set_Palette(Value: LongWord);
begin
  GetGraphic.Palette := Value;
end;

procedure TwrpGraphic.Set_PaletteModified(Value: WordBool);
begin
  GetGraphic.PaletteModified := Value;
end;

procedure TwrpGraphic.Set_Transparent(Value: WordBool);
begin
  GetGraphic.Transparent := Value;
end;

procedure TwrpGraphic.Set_Width(Value: Integer);
begin
  GetGraphic.Width := Value;
end;

procedure TwrpGraphic.LoadFromStream(const Param1: IgsStream);
begin
  GetGraphic.LoadFromStream(InterfaceToObject(Param1) as TStream);
end;

procedure TwrpGraphic.SaveToStream(const Param1: IgsStream);
begin
  GetGraphic.SaveToStream(InterfaceToObject(Param1) as TStream);
end;

class function TwrpGraphic.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Result := nil;
  if DelphiClass.InheritsFrom(TGraphic) then
  begin
    Result := TCrackGraphicClass(DelphiClass).Create;
  end else
    ErrorClassName(TGraphic.ClassName);
end;

{ TwrpBitmap }

procedure TwrpBitmap.Dormant;
begin
  GetBitmap.Dormant;
end;

procedure TwrpBitmap.FreeImage;
begin
  GetBitmap.FreeImage;
end;

function TwrpBitmap.GetBitmap: Graphics.TBitmap;
begin
  Result := GetObject as Graphics.TBitmap;
end;

function TwrpBitmap.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetBitmap.Canvas) as IgsCanvas;
end;

function TwrpBitmap.Get_Handle: Integer;
begin
  Result := GetBitmap.Handle;
end;

function TwrpBitmap.Get_HandleType: TgsBitmapHandleType;
begin
  Result := TgsBitmapHandleType(GetBitmap.HandleType);
end;

function TwrpBitmap.Get_IgnorePalette: WordBool;
begin
  Result := GetBitmap.IgnorePalette;
end;

function TwrpBitmap.Get_MaskHandle: Integer;
begin
  Result := GetBitmap.MaskHandle;
end;

function TwrpBitmap.Get_Monochrome: WordBool;
begin
  Result := GetBitmap.Monochrome;
end;

function TwrpBitmap.Get_PixelFormat: TgsPixelFormat;
begin
  Result := TgsPixelFormat(GetBitmap.PixelFormat);
end;

function TwrpBitmap.Get_TransparentColor: Integer;
begin
  Result := GetBitmap.TransparentColor;
end;

function TwrpBitmap.Get_TransparentMode: TgsTransparentMode;
begin
  Result := TgsTransparentMode(GetBitmap.TransparentMode);
end;

procedure TwrpBitmap.LoadFromResourceID(Instance, ResID: Integer);
begin
  GetBitmap.LoadFromResourceID(Instance, ResID);
end;

procedure TwrpBitmap.LoadFromResourceName(Instance: Integer;
  const ResName: WideString);
begin
  GetBitmap.LoadFromResourceName(Instance, ResName);
end;

procedure TwrpBitmap.Mask(TransparentColor: Integer);
begin
  GetBitmap.Mask(TransparentColor);
end;

function TwrpBitmap.ReleaseHandle: Integer;
begin
  Result := GetBitmap.ReleaseHandle;
end;

function TwrpBitmap.ReleaseMaskHandle: Integer;
begin
  Result := GetBitmap.ReleaseMaskHandle;
end;

function TwrpBitmap.ReleasePalette: Integer;
begin
  Result := GetBitmap.ReleasePalette;
end;

procedure TwrpBitmap.Set_Handle(Value: Integer);
begin
  GetBitmap.Handle := Value;
end;

procedure TwrpBitmap.Set_HandleType(Value: TgsBitmapHandleType);
begin
  GetBitmap.HandleType := TBitmapHandleType(Value);
end;

procedure TwrpBitmap.Set_IgnorePalette(Value: WordBool);
begin
  GetBitmap.IgnorePalette := Value;
end;

procedure TwrpBitmap.Set_Monochrome(Value: WordBool);
begin
  GetBitmap.Monochrome := Value;
end;

procedure TwrpBitmap.Set_PixelFormat(Value: TgsPixelFormat);
begin
  GetBitmap.PixelFormat := TPixelFormat(Value);
end;

procedure TwrpBitmap.Set_TransparentColor(Value: Integer);
begin
  GetBitmap.TransparentColor := Value;
end;

{ TgsApplication }

procedure TwrpApplication.BringToFront;
begin
  Application.BringToFront;
end;

function TwrpApplication.ExecuteAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := Application.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpApplication.Get_Handle: Integer;
begin
  Result := Application.Handle;
end;

function TwrpApplication.Get_Active: WordBool;
begin
  Result := Application.Active;
end;

function TwrpApplication.Get_BiDiMode: TgsBiDiMode;
begin
  Result := TgsBiDiMode(Application.BiDiMode);
end;

function TwrpApplication.Get_MainForm: IgsForm;
begin
  Result := GetGdcOLEObject(Application.MainForm) as IgsForm;
end;

function TwrpApplication.Get_NonBiDiKeyboard: WideString;
begin
  Result := Application.NonBiDiKeyboard;
end;

function TwrpApplication.Get_Terminated: WordBool;
begin
  Result := Application.Terminated;
end;

function TwrpApplication.Get_Title: WideString;
begin
  Result := Application.Title;
end;

procedure TwrpApplication.HandleMessage;
begin
  Application.HandleMessage;
end;

function TwrpApplication.HelpCommand(Command, Data: Integer): WordBool;
begin
  Result := Application.HelpCommand(Command, Data);
end;

function TwrpApplication.MessageBox(const Text, Caption: WideString;
  Flags: Integer): Integer;
begin
  Result := Application.MessageBox(PChar(String(Text)), PChar(String(Caption)), Flags);
end;

procedure TwrpApplication.Minimize;
begin
  Application.Minimize;
end;

procedure TwrpApplication.NormalizeAllTopMosts;
begin
  Application.NormalizeAllTopMosts;
end;

procedure TwrpApplication.NormalizeTopMosts;
begin
  Application.NormalizeTopMosts;
end;

procedure TwrpApplication.ProcessMessages;
begin
  Application.ProcessMessages;
end;

procedure TwrpBitmap.Set_TransparentMode(Value: TgsTransparentMode);
begin
  GetBitmap.TransparentMode := TTransparentMode(Value);
end;

{ TwrpCommonDialog }

function TwrpCommonDialog.Get_Ctl3D: WordBool;
begin
  Result := GetCommonDialog.Ctl3D;
end;

function TwrpCommonDialog.Get_Handle: LongWord;
begin
  Result := GetCommonDialog.Handle;
end;

function TwrpCommonDialog.GetCommonDialog: TCommonDialog;
begin
  Result := GetObject as TCommonDialog;
end;

procedure TwrpCommonDialog.Set_Ctl3D(Value: WordBool);
begin
  GetCommonDialog.Ctl3D := Value;
end;

function TwrpCommonDialog.Get_HelpContext: Integer;
begin
  Result := GetCommonDialog.HelpContext;
end;

procedure TwrpCommonDialog.Set_HelpContext(Value: Integer);
begin
  GetCommonDialog.HelpContext := Value;
end;

{ TwrpOpenDialog }

function TwrpOpenDialog.Execute: WordBool;
begin
  Result := GetOpenDialog.Execute;
end;

function TwrpOpenDialog.Get_DefaultExt: WideString;
begin
  Result := GetOpenDialog.DefaultExt;
end;

function TwrpOpenDialog.Get_FileEditStyle: TgsFileEditStyle;
begin
  Result := TgsFileEditStyle(GetOpenDialog.FileEditStyle);
end;

function TwrpOpenDialog.Get_FileName: WideString;
begin
  Result := GetOpenDialog.FileName;
end;

function TwrpOpenDialog.Get_Files: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetOpenDialog.Files);
end;

function TwrpOpenDialog.Get_Filter: WideString;
begin
  Result := GetOpenDialog.Filter;
end;

function TwrpOpenDialog.Get_FilterIndex: Integer;
begin
  Result := GetOpenDialog.FilterIndex;
end;

function TwrpOpenDialog.Get_HistoryList: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetOpenDialog.HistoryList);
end;

function TwrpOpenDialog.Get_InitialDir: WideString;
begin
  Result := GetOpenDialog.InitialDir;
end;

function TwrpOpenDialog.Get_Options: WideString;
begin
  Result := TOpenOptionsToStr(GetOpenDialog.Options);
end;

function TwrpOpenDialog.Get_Title: WideString;
begin
  Result := GetOpenDialog.Title;
end;

function TwrpOpenDialog.GetOpenDialog: TOpenDialog;
begin
  Result := GetObject as TOpenDialog;
end;

procedure TwrpOpenDialog.Set_DefaultExt(const Value: WideString);
begin
  GetOpenDialog.DefaultExt := Value;
end;

procedure TwrpOpenDialog.Set_FileEditStyle(Value: TgsFileEditStyle);
begin
  GetOpenDialog.FileEditStyle := TFileEditStyle(Value);
end;

procedure TwrpOpenDialog.Set_FileName(const Value: WideString);
begin
  GetOpenDialog.FileName := Value;
end;

procedure TwrpOpenDialog.Set_Filter(const Value: WideString);
begin
  GetOpenDialog.Filter := Value;
end;

procedure TwrpOpenDialog.Set_FilterIndex(Value: Integer);
begin
  GetOpenDialog.FilterIndex := Value;
end;

procedure TwrpOpenDialog.Set_HistoryList(const Value: IgsStrings);
begin
  GetOpenDialog.HistoryList := IgsStringsToTStrings(Value);
end;

procedure TwrpOpenDialog.Set_InitialDir(const Value: WideString);
begin
  GetOpenDialog.InitialDir := Value;
end;

procedure TwrpOpenDialog.Set_Options(const Value: WideString);
begin
  GetOpenDialog.Options := StrToTOpenOptions(Value);
end;

procedure TwrpOpenDialog.Set_Title(const Value: WideString);
begin
  GetOpenDialog.Title := Value;
end;

procedure TwrpApplication.Restore;
begin
  Application.Restore;
end;

procedure TwrpApplication.RestoreTopMosts;
begin
  Application.RestoreTopMosts;
end;

procedure TwrpApplication.Set_BiDiMode(Value: TgsBiDiMode);
begin
  Application.BiDiMode := TBiDiMode(Value);
end;

procedure TwrpApplication.Set_NonBiDiKeyboard(const Value: WideString);
begin
  Application.NonBiDiKeyboard := Value;
end;

procedure TwrpApplication.Set_Title(const Value: WideString);
begin
  Application.Title := Value;
end;

procedure TwrpApplication.Terminate;
begin
  Application.Terminate;
end;

{ TwrpPicture }

function TwrpPicture.GetPicture: TPicture;
begin
  Result := GetObject as TPicture;
end;

function TwrpPicture.Get_Bitmap: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetPicture.Bitmap) as IgsBitmap;
end;

function TwrpPicture.Get_Graphic: IgsGraphic;
begin
  Result := GetGdcOLEObject(GetPicture.Graphic) as IgsGraphic;
end;

function TwrpPicture.Get_Height: Integer;
begin
  Result := GetPicture.Height;
end;

function TwrpPicture.Get_Icon: IgsIcon;
begin
  Result := GetGdcOLEObject(GetPicture.Icon) as IgsIcon;
end;

function TwrpPicture.Get_Metafile: IgsMetafile;
begin
  Result := GetGdcOLEObject(GetPicture.Metafile) as IgsMetafile;
end;

function TwrpPicture.Get_Width: Integer;
begin
  Result := GetPicture.Width;
end;

procedure TwrpPicture.LoadFromClipboardFormat(AFormat: Byte; AData,
  APalette: LongWord);
begin
  GetPicture.LoadFromClipboardFormat(AFormat, AData, APalette)
end;

procedure TwrpPicture.LoadFromFile(const Param1: WideString);
begin
  GetPicture.LoadFromFile(Param1);
end;

procedure TwrpPicture.SaveToFile(const Param1: WideString);
begin
  GetPicture.SaveToFile(Param1);
end;

procedure TwrpPicture.SaveToClipboardFormat(var AFormat: OleVariant;
  var AData: OleVariant; var APalette: OleVariant); safecall;
var
  LFormat: Word;
  LData: Cardinal;
  LPalette: HPALETTE;
begin
  LFormat := AFormat;
  LData := AData;
  LPalette := APalette;
  GetPicture.SaveToClipboardFormat(LFormat, LData, LPalette);
  AFormat := LFormat;
  AData := Integer(LData);
  APalette := Integer(LPalette);
end;

procedure TwrpPicture.Set_Icon(const Value: IgsIcon);
begin
  GetPicture.Icon := InterfaceToObject(Value) as TIcon;
end;

procedure TwrpPicture.Set_Metafile(const Value: IgsMetafile);
begin
  GetPicture.Metafile := InterfaceToObject(Value) as TMetafile;
end;

function TwrpPicture.SupportsClipboardFormat(AFormat: Word): WordBool;
begin
  Result := GetPicture.SupportsClipboardFormat(AFormat);
end;

class function TwrpPicture.CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Result := TPicture.Create;
end;

{ TwrpStream }

function TwrpStream.CopyFrom(const ASource: IgsStream;
  ACount: Integer): Integer;
begin
  Result := GetStream.CopyFrom(InterfaceToObject(ASource) as TStream, ACount);
end;

procedure TwrpStream.FixupResourceHeader(Value: Integer);
begin
  GetStream.FixupResourceHeader(Value);
end;

function TwrpStream.GetStream: TStream;
begin
  Result := GetObject as TStream;
end;

function TwrpStream.Get_Position: Integer;
begin
  Result := GetStream.Position;
end;

function TwrpStream.Get_Size: Integer;
begin
  Result := GetStream.Size;
end;

function TwrpStream.ReadComponent(
  const Instance: IgsComponent): IgsComponent;
begin
  Result := GetGdcOLEObject(GetStream.ReadComponent(InterfaceToObject(Instance) as
    TComponent)) as IgsComponent;
end;

function TwrpStream.ReadComponentRes(
  const Instance: IgsComponent): IgsComponent;
begin
  Result := GetGdcOLEObject(GetStream.ReadComponentRes(InterfaceToObject(Instance) as
    TComponent)) as IgsComponent;
end;

procedure TwrpStream.ReadResHeader;
begin
  GetStream.ReadResHeader;
end;

function TwrpStream.Seek(Offset: Integer; Origin: Word): Integer;
begin
  Result := GetStream.Seek(Offset, Origin);
end;

procedure TwrpStream.Set_Position(Value: Integer);
begin
  GetStream.Position := Value;
end;

procedure TwrpStream.Set_Size(Value: Integer);
begin
  GetStream.Size := Value;
end;

procedure TwrpStream.WriteComponent(const Instance: IgsComponent);
begin
  GetStream.WriteComponent(InterfaceToObject(Instance) as TComponent);
end;

procedure TwrpStream.WriteComponentRes(const ResName: WideString;
  const Instance: IgsComponent);
begin
  GetStream.WriteComponentRes(ResName ,InterfaceToObject(Instance) as TComponent);
end;

procedure TwrpStream.WriteDescendent(const Instance,
  Ancestor: IgsComponent);
begin
  GetStream.WriteDescendent(InterfaceToObject(Instance) as TComponent, InterfaceToObject(Ancestor) as TComponent);
end;

procedure TwrpStream.WriteDescendentRes(const ResName: WideString;
  const Instance, Ancestor: IgsComponent);
begin
  GetStream.WriteDescendentRes(ResName,InterfaceToObject(Instance) as TComponent,
    InterfaceToObject(Ancestor) as TComponent);
end;

procedure TwrpStream.WriteResourceHeader(const ResName: WideString;
  out FixupInfo: OleVariant);
var
  fi: Integer;
begin
  GetStream.WriteResourceHeader(ResName, Fi);
  FixupInfo := fi;
end;

function  TwrpStream.ReadInteger: Integer; safecall;
begin
  GetStream.Read(Result, SizeOf(Result));
end;

function TwrpStream.ReadBoolean: WordBool;
begin
  GetStream.Read(Result, SizeOf(Result));
end;

function TwrpStream.ReadCurrency: Currency;
begin
  GetStream.Read(Result, SizeOf(Result));
end;

function TwrpStream.ReadDate: TDateTime;
begin
  GetStream.Read(Result, SizeOf(Result));
end;

function TwrpStream.ReadSingle: Single;
begin
  GetStream.Read(Result, SizeOf(Result));
end;

function TwrpStream.ReadStr(Count: Integer): WideString;
var
  S: String;
begin
  if Count < 1 then
    raise Exception.Create('Количество символов считывания должно быть больше 0.');

  SetLength(S, Count);
  GetStream.Read(S[1], Count);
  Result := S;
end;

function TwrpStream.WriteBoolean(Buffer: WordBool): Integer;
begin
  Result := GetStream.Write(Buffer, SizeOf(WordBool));
end;

function TwrpStream.WriteCurrency(Buffer: Currency): Integer;
begin
  Result := GetStream.Write(Buffer, SizeOf(Currency));
end;

function TwrpStream.WriteDate(Buffer: TDateTime): Integer;
begin
  Result := GetStream.Write(Buffer, SizeOf(TDateTime));
end;

function TwrpStream.WriteInteger(Buffer: Integer): Integer;
begin
  Result := GetStream.Write(Buffer, SizeOf(Integer));
end;

function TwrpStream.WriteSingle(Buffer: Single): Integer;
begin
  Result := GetStream.Write(Buffer, SizeOf(Single));
end;

function TwrpStream.WriteStr(const Buffer: WideString;
  Count: Integer): Integer;
var
  S: String;
begin
  if Length(Buffer) < Count then
    raise Exception.Create('Длина переданной строки меньше количества меньше количества записываемых символов.');
  if Length(Buffer) = 0 then
    raise Exception.Create('Строка пустая.');

  S := Buffer;
  Result := GetStream.Write(S[1], Count);
end;


{ TwrpBrush }

function TwrpBrush.Get_Bitmap: IgsBitmap;
begin
  Result := GetGDCOleObject(GetBrush.Bitmap) as IgsBitmap;
end;

function TwrpBrush.Get_Color: Integer;
begin
  Result := GetBrush.Color;
end;

function TwrpBrush.Get_Handle: Integer;
begin
  Result := GetBrush.Handle;
end;

function TwrpBrush.Get_Style: Integer;
begin
  Result := Integer(GetBrush.Style);
end;

function TwrpBrush.GetBrush: TBrush;
begin
  Result := GetObject as TBrush;
end;

procedure TwrpBrush.Set_Bitmap(const Value: IgsBitmap);
begin
  GetBrush.Bitmap := InterfaceToObject(Value) as TBitmap;
end;

procedure TwrpBrush.Set_Color(Value: Integer);
begin
  GetBrush.Color := Value;
end;

procedure TwrpBrush.Set_Handle(Value: Integer);
begin
  GetBrush.Handle := Value;
end;

procedure TwrpBrush.Set_Style(Value: Integer);
begin
  GetBrush.Style := TBrushStyle(Value);
end;

class function TwrpBrush.CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Result := TBrush.Create;
end;

{ TwrpFields }

procedure TwrpFields.Add(const Field: IgsFieldComponent);
begin
  GetFields.Add(InterfaceToObject(Field) as TField);
end;

procedure TwrpFields.CheckFieldName(const FieldName: WideString);
begin
  GetFields.CheckFieldName(FieldName);
end;

procedure TwrpFields.CheckFieldNames(const FieldNames: WideString);
begin
  GetFields.CheckFieldNames(FieldNames);
end;

procedure TwrpFields.Clear;
begin
  GetFields.Clear;
end;

function TwrpFields.FieldByName(const FieldName: WideString): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetFields.FieldByName(FieldName)) as IgsFieldComponent;
end;

function TwrpFields.FieldByNumber(FieldNo: Integer): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetFields.FieldByNumber(FieldNo)) as IgsFieldComponent;
end;

function TwrpFields.FindField(const FieldName: WideString): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetFields.FindField(FieldName)) as IgsFieldComponent;
end;

function TwrpFields.Get_Count: Integer;
begin
  Result := GetFields.Count;
end;

function TwrpFields.Get_DataSet: IgsDataSet;
begin
  Result := GetGdcOLEObject(GetFields.DataSet) as IgsDataSet;
end;

function TwrpFields.Get_Fields(Index: Integer): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetFields.Fields[Index]) as IgsFieldComponent;
end;

procedure TwrpFields.GetFieldNames(const List: IgsStrings);
begin
  GetFields.GetFieldNames(IgsStringsToTStrings(List));
end;

function TwrpFields.GetFields: TFields;
begin
  Result := GetObject as TFields;
end;

function TwrpFields.IndexOf(const Field: IgsFieldComponent): Integer;
begin
  Result := GetFields.IndexOf(InterfaceToObject(Field) as TField);
end;

procedure TwrpFields.Remove(const Field: IgsFieldComponent);
begin
  GetFields.Remove(InterfaceToObject(Field) as TField);
end;

procedure TwrpFields.Set_Fields(Index: Integer; const Value: IgsFieldComponent);
begin
  GetFields.Fields[Index] := InterfaceToObject(Value) as TField;
end;

{ TwrpSizeConstraints }

function TwrpSizeConstraints.Get_MaxHeight: Integer;
begin
  Result := GetSizeConstraints.MaxHeight;
end;

function TwrpSizeConstraints.Get_MaxWidth: Integer;
begin
  Result := GetSizeConstraints.MaxWidth;
end;

function TwrpSizeConstraints.Get_MinWidth: Integer;
begin
  Result := GetSizeConstraints.MinWidth;
end;

function TwrpSizeConstraints.Get_MinHeight: Integer;
begin
  Result := GetSizeConstraints.MinHeight;
end;

function TwrpSizeConstraints.GetSizeConstraints: TSizeConstraints;
begin
  Result := GetObject as TSizeConstraints;
end;

procedure TwrpSizeConstraints.Set_MaxHeight(Value: Integer);
begin
  if Value < 0 then
    GetSizeConstraints.MaxHeight := 0
  else
    GetSizeConstraints.MaxHeight := Value;
end;

procedure TwrpSizeConstraints.Set_MaxWidth(Value: Integer);
begin
  if Value < 0 then
    GetSizeConstraints.MaxWidth := 0
  else
    GetSizeConstraints.MaxWidth := Value;
end;

procedure TwrpSizeConstraints.Set_MinWidth(Value: Integer);
begin
  GetSizeConstraints.MinWidth := Abs(Value);
end;

procedure TwrpSizeConstraints.Set_MinHeight(Value: Integer);
begin
  GetSizeConstraints.MinHeight := Abs(Value);
end;

{ TwrpDragObject }

procedure TwrpDragObject.Assign_(const Source: IgsDragObject);
begin
  GetDragObject.Assign(InterfaceToObject(Source) as TDragObject);
end;

function TwrpDragObject.GetDragObject: TDragObject;
begin
  Result := GetObject as TDragObject;
end;

function TwrpDragObject.GetName: WideString;
begin
  Result := GetDragObject.GetName;
end;

function TwrpDragObject.Get_Cancelling: WordBool;
begin
  Result := GetDragObject.Cancelling;
end;

function TwrpDragObject.Get_DragHandle: LongWord;
begin
  Result := GetDragObject.DragHandle;
end;

procedure TwrpDragObject.HideDragImage;
begin
  GetDragObject.HideDragImage;
end;

function TwrpDragObject.Instance: LongWord;
begin
  Result := GetDragObject.Instance;
end;

procedure TwrpDragObject.Set_Cancelling(Value: WordBool);
begin
  GetDragObject.Cancelling := Value;
end;

procedure TwrpDragObject.Set_DragHandle(Value: LongWord);
begin
  GetDragObject.DragHandle := Value;
end;

procedure TwrpDragObject.ShowDragImage;
begin
  GetDragObject.ShowDragImage;
end;

{ TwrpBaseDragControlObject }

function TwrpBaseDragControlObject.Get_Control: IgsControl;
begin
  Result := GetGdcOLEObject(GetBaseDragControlObject.Control) as IgsControl;
end;

function TwrpBaseDragControlObject.GetBaseDragControlObject: TBaseDragControlObject;
begin
  Result := GetObject as TBaseDragControlObject;
end;

procedure TwrpBaseDragControlObject.Set_Control(const Value: IgsControl);
begin
  GetBaseDragControlObject.Control := InterfaceToObject(Value) as  TControl;
end;

{ TwrpDragDockObject }

function TwrpDragDockObject.Get_Brush: IgsBrush;
begin
  Result := GetGdcOLEObject(GetDragDockObject.Brush) as IgsBrush;
end;

function TwrpDragDockObject.Get_DropAlign: TgsAlign;
begin
  Result := TgsAlign(GetDragDockObject.DropAlign);
end;

function TwrpDragDockObject.Get_DropOnControl: IgsControl;
begin
  Result :=  GetGdcOLEObject(GetDragDockObject.DropOnControl) as IgsControl;
end;

function TwrpDragDockObject.Get_Floating: WordBool;
begin
  Result := GetDragDockObject.Floating;
end;

function TwrpDragDockObject.Get_FrameWidth: Integer;
begin
  Result := GetDragDockObject.FrameWidth;
end;

function TwrpDragDockObject.GetDragDockObject: TDragDockObject;
begin
  Result := GetObject as TDragDockObject;
end;

procedure TwrpDragDockObject.Set_Brush(const Value: IgsBrush);
begin
  GetDragDockObject.Brush := InterfaceToObject(Value) as TBrush;
end;

procedure TwrpDragDockObject.Set_Floating(Value: WordBool);
begin
  GetDragDockObject.Floating := Value;
end;

{ TwrpObjectField }

function TwrpObjectField.Get_FieldCount: Integer;
begin
  Result := GetObjectField.FieldCount;
end;

function TwrpObjectField.Get_Fields: IgsFields;
begin
  Result := GetGdcOLEObject(GetObjectField.Fields) as IgsFields;
end;

function TwrpObjectField.Get_FieldValues(Index: Integer): OleVariant;
begin
  Result := GetObjectField.FieldValues[Index];
end;

function TwrpObjectField.Get_ObjectType: WideString;
begin
  Result := GetObjectField.ObjectType;
end;

function TwrpObjectField.Get_UnNamed: WordBool;
begin
  Result := GetObjectField.UnNamed;
end;

function TwrpObjectField.GetObjectField: TObjectField;
begin
  Result := GetObject as TObjectField;
end;

procedure TwrpObjectField.Set_FieldValues(Index: Integer;
  Value: OleVariant);
begin
  GetObjectField.FieldValues[Index] := Value;
end;

procedure TwrpObjectField.Set_ObjectType(const Value: WideString);
begin
  GetObjectField.ObjectType := Value;
end;

{ TwrpDataSetField }

function TwrpDataSetField.Get_IncludeObjectField: WordBool;
begin
  Result := GetDataSetField.IncludeObjectField;
end;

function TwrpDataSetField.Get_NestedDataSet: IgsDataSet;
begin
  Result := GetGdcOLEObject(GetDataSetField.NestedDataSet) as IgsDataSet;
end;

function TwrpDataSetField.GetDataSetField: TDataSetField;
begin
  Result := GetObject as TDataSetField;
end;

procedure TwrpDataSetField.Set_IncludeObjectField(Value: WordBool);
begin
  GetDataSetField.IncludeObjectField := Value;
end;

{ TwrpNamedItem }

function TwrpNamedItem.Get_Name: WideString;
begin
  Result := GetNamedItem.Name;
end;

function TwrpNamedItem.GetNamedItem: TNamedItem;
begin
  Result := GetObject as TNamedItem;
end;

procedure TwrpNamedItem.Set_Name(const Value: WideString);
begin
  GetNamedItem.Name := Value;
end;

{ TwrpFieldDef }

function TwrpFieldDef.Get_Attributes: WideString;
  function TFieldAttributeToStr(Value: TFieldAttributes): String;
  begin
    Result := ' ';
    if faHiddenCol in Value then
      Result := Result + 'faHiddenCol ';
    if DB.faReadonly in Value then
      Result := Result + 'faReadonly ';
    if faRequired in Value then
      Result := Result + 'faRequired ';
    if faLink in Value then
      Result := Result + 'faLink ';
    if faUnNamed in Value then
      Result := Result + 'faUnNamed ';
    if faFixed in Value then
      Result := Result + 'faFixed ';
  end;
begin
  Result := TFieldAttributeToStr(GetFieldDef.Attributes);
end;

function TwrpFieldDef.Get_ChildDefs: IgsFieldDefs;
begin
  Result := GetGdcOLEObject(GetFieldDef.ChildDefs) as IgsFieldDefs;
end;

function TwrpFieldDef.Get_DataType: TgsFieldType;
begin
  Result := TgsFieldType(GetFieldDef.DataType);
end;

function TwrpFieldDef.Get_FieldNo: Integer;
begin
  Result := GetFieldDef.FieldNo;
end;

function TwrpFieldDef.Get_InternalCalcField: WordBool;
begin
  Result := GetFieldDef.InternalCalcField;
end;

function TwrpFieldDef.Get_ParentDef: IgsFieldDef;
begin
  Result := GetGdcOLEObject(GetFieldDef.ParentDef) as IgsFieldDef;
end;

function TwrpFieldDef.Get_Precision: Integer;
begin
  Result := GetFieldDef.Precision;
end;

function TwrpFieldDef.Get_Required: WordBool;
begin
  Result := GetFieldDef.Required;
end;

function TwrpFieldDef.Get_Size: Integer;
begin
  Result := GetFieldDef.Size;
end;

function TwrpFieldDef.GetFieldDef: TFieldDef;
begin
  Result := GetObject as TFieldDef;
end;

procedure TwrpFieldDef.Set_Attributes(const Value: WideString);
var
  LAttributes: TFieldAttributes;
begin
  LAttributes := [];
  if Pos('FAHIDDENCOL', Value) > 0 then
    Include(LAttributes, FAHIDDENCOL);
  if Pos('FAREADONLY', Value) > 0 then
    Include(LAttributes, DB.FAREADONLY);
  if Pos('FAREQUIRED', Value) > 0 then
    Include(LAttributes, FAREQUIRED);
  if Pos('FALINK', Value) > 0 then
    Include(LAttributes, FALINK);
  if Pos('FAUNNAMED', Value) > 0 then
    Include(LAttributes, FAUNNAMED);
  if Pos('FAFIXED', Value) > 0 then
    Include(LAttributes, FAFIXED);
  GetFieldDef.Attributes := LAttributes;
end;

procedure TwrpFieldDef.Set_ChildDefs(const Value: IgsFieldDefs);
begin
  GetFieldDef.ChildDefs := InterfaceToObject(Value) as TFieldDefs;
end;

procedure TwrpFieldDef.Set_DataType(Value: TgsFieldType);
begin
  GetFieldDef.DataType := TFieldType(Value);
end;

procedure TwrpFieldDef.Set_FieldNo(Value: Integer);
begin
  GetFieldDef.FieldNo := Value;
end;

procedure TwrpFieldDef.Set_InternalCalcField(Value: WordBool);
begin
  GetFieldDef.InternalCalcField := Value;
end;

procedure TwrpFieldDef.Set_Precision(Value: Integer);
begin
  GetFieldDef.Precision := Value;
end;

procedure TwrpFieldDef.Set_Required(Value: WordBool);
begin
  GetFieldDef.Required := Value;
end;

procedure TwrpFieldDef.Set_Size(Value: Integer);
begin
  GetFieldDef.Size := Value;
end;

function TwrpFieldDef.AddChild: IgsFieldDef;
begin
  Result := GetGdcOLEObject(GetFieldDef.AddChild) as IgsFieldDef;
end;

function TwrpFieldDef.HasChildDefs: WordBool;
begin
  Result := GetFieldDef.HasChildDefs;
end;

{ TwrpFlatList }

function TwrpFlatList.Get_DataSet: IgsDataSet;
begin
  Result := GetGdcOLEObject(GetFlatList.DataSet) as IgsDataSet;
end;

function TwrpFlatList.GetFlatList: TFlatList;
begin
  Result := GetObject as TFlatList;
end;

procedure TwrpFlatList.Update;
begin
  GetFlatList.Update;
end;

{ TwrpFieldDefList }

function TwrpFieldDefList.Get_FieldDefs(Index: Integer): IgsFieldDef;
begin
  Result := GetGdcOLEObject(GetFieldDefList.FieldDefs[Index]) as IgsFieldDef;
end;

function TwrpFieldDefList.GetFieldDefList: TFieldDefList;
begin
  Result := GetObject as TFieldDefList;
end;

{ TwrpOwnedCollection }

function TwrpOwnedCollection.Get_Items(Index: Integer): IgsCollectionItem;
begin
  Result := GetGdcOLEObject(GetOwnedCollection.Items[Index]) as IgsCollectionItem;
end;

function TwrpOwnedCollection.GetOwnedCollection: TOwnedCollection;
begin
  Result := GetObject as TOwnedCollection;
end;

procedure TwrpOwnedCollection.Set_Items(Index: Integer;
  const Value: IgsCollectionItem);
begin
  GetOwnedCollection.Items[Index] := InterfaceToObject(Value) as TCollectionItem;
end;

{ TwrpDefCollection }

function TwrpDefCollection.Find(const AName: WideString): IgsNamedItem;
begin
  Result := GetGdcOLEObject(GetDefCollection.Find(AName)) as IgsNamedItem;
end;

function TwrpDefCollection.Get_DataSet: IgsDataSet;
begin
  Result := GetGdcOLEObject(GetDefCollection.DataSet) as IgsDataSet;
end;

function TwrpDefCollection.Get_Updated: WordBool;
begin
  Result := GetDefCollection.Updated;
end;

function TwrpDefCollection.GetDefCollection: TDefCollection;
begin
  Result := GetObject as TDefCollection;
end;

procedure TwrpDefCollection.GetItemNames(const List: IgsStrings);
begin
  GetDefCollection.GetItemNames(IgsStringsToTStrings(List));
end;

function TwrpDefCollection.IndexOf(const AName: WideString): Integer;
begin
  Result := GetDefCollection.IndexOf(AName);
end;

procedure TwrpDefCollection.Set_Updated(Value: WordBool);
begin
  GetDefCollection.Updated := Value;
end;

{ TwrpFieldDefs }

procedure TwrpFieldDefs.Add(const Name: WideString; DataType: TgsFieldType;
  Size: Integer; Required: WordBool);
begin
  GetFieldDefs.Add(Name, TFieldType(DataType), Size, Required);
end;

function TwrpFieldDefs.AddFieldDef: IgsFieldDef;
begin
  Result := GetGdcOLEObject(GetFieldDefs.AddFieldDef) as IgsFieldDef;
end;

function TwrpFieldDefs.Find_(const Name: WideString): IgsFieldDef;
begin
  Result := GetGdcOLEObject(GetFieldDefs.Find(Name)) as IgsFieldDef;
end;

function TwrpFieldDefs.Get_HiddenFields: WordBool;
begin
  Result := GetFieldDefs.HiddenFields;
end;

function TwrpFieldDefs.Get_Items_(Index: Integer): IgsFieldDef;
begin
  Result := GetGdcOLEObject(GetFieldDefs.Items[Index]) as IgsFieldDef;
end;

function TwrpFieldDefs.Get_ParentDef: IgsFieldDef;
begin
  Result := GetGdcOLEObject(GetFieldDefs.ParentDef) as IgsFieldDef;
end;

function TwrpFieldDefs.GetFieldDefs: TFieldDefs;
begin
  Result := GetObject as TFieldDefs;
end;

procedure TwrpFieldDefs.Set_HiddenFields(Value: WordBool);
begin
  GetFieldDefs.HiddenFields := Value;
end;

procedure TwrpFieldDefs.Set_Items_(Index: Integer;
  const Value: IgsFieldDef);
begin
  GetFieldDefs.Items[Index] := InterfaceToObject(Value) as TFieldDef;
end;

procedure TwrpFieldDefs.Update;
begin
  GetFieldDefs.Update;
end;

{ TwrpFieldList }

function TwrpFieldList.FieldByName(const FieldName: WideString): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetFieldList.FieldByName(FieldName)) as IgsFieldComponent;
end;

function TwrpFieldList.Find_(const FieldName: WideString): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetFieldList.Find(FieldName)) as IgsFieldComponent;
end;

function TwrpFieldList.Get_Fields(Index: Integer): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetFieldList.Fields[Index]) as IgsFieldComponent;
end;

function TwrpFieldList.GetFieldList: TFieldList;
begin
  Result := GetObject as TFieldList;
end;

{ TwrpControlScrollBar }

procedure TwrpControlScrollBar.ChangeBiDiPosition;
begin
  GetControlScrollBar.ChangeBiDiPosition;
end;

function TwrpControlScrollBar.Get_ButtonSize: Integer;
begin
  Result := GetControlScrollBar.ButtonSize;
end;

function TwrpControlScrollBar.Get_Color: Integer;
begin
  Result := GetControlScrollBar.Color;
end;

function TwrpControlScrollBar.Get_Increment: Word;
begin
  Result := GetControlScrollBar.Increment;
end;

function TwrpControlScrollBar.Get_Kind: TgsScrollBarKind;
begin
  Result := TgsScrollBarKind(GetControlScrollBar.Kind);
end;

function TwrpControlScrollBar.Get_Margin: Word;
begin
  Result := GetControlScrollBar.Margin;
end;

function TwrpControlScrollBar.Get_ParentColor: WordBool;
begin
  Result := GetControlScrollBar.ParentColor;
end;

function TwrpControlScrollBar.Get_Position: Integer;
begin
  Result := GetControlScrollBar.Position;
end;

function TwrpControlScrollBar.Get_Range: Integer;
begin
  Result := GetControlScrollBar.Range;
end;

function TwrpControlScrollBar.Get_ScrollPos: Integer;
begin
  Result := GetControlScrollBar.ScrollPos;
end;

function TwrpControlScrollBar.Get_Size: Integer;
begin
  Result := GetControlScrollBar.Size;
end;

function TwrpControlScrollBar.Get_Smooth: WordBool;
begin
  Result := GetControlScrollBar.Smooth;
end;

function TwrpControlScrollBar.Get_Style: TgsScrollBarStyle;
begin
  Result := TgsScrollBarStyle(GetControlScrollBar.Style);
end;

function TwrpControlScrollBar.Get_ThumbSize: Integer;
begin
  Result := GetControlScrollBar.ThumbSize;
end;

function TwrpControlScrollBar.Get_Tracking: WordBool;
begin
  Result := GetControlScrollBar.Tracking;
end;

function TwrpControlScrollBar.Get_Visible: WordBool;
begin
  Result := GetControlScrollBar.Visible;
end;

function TwrpControlScrollBar.GetControlScrollBar: TControlScrollBar;
begin
  Result := GetObject as TControlScrollBar;
end;

function TwrpControlScrollBar.IsScrollBarVisible: WordBool;
begin
  Result := GetControlScrollBar.IsScrollBarVisible;
end;

procedure TwrpControlScrollBar.Set_ButtonSize(Value: Integer);
begin
  GetControlScrollBar.ButtonSize := Value;
end;

procedure TwrpControlScrollBar.Set_Color(Value: Integer);
begin
  GetControlScrollBar.Color := Value;
end;

procedure TwrpControlScrollBar.Set_Increment(Value: Word);
begin
  GetControlScrollBar.Increment := Value;
end;

procedure TwrpControlScrollBar.Set_Margin(Value: Word);
begin
  GetControlScrollBar.Margin := Value;
end;

procedure TwrpControlScrollBar.Set_ParentColor(Value: WordBool);
begin
  GetControlScrollBar.ParentColor := Value;
end;

procedure TwrpControlScrollBar.Set_Position(Value: Integer);
begin
  GetControlScrollBar.Position := Value;
end;

procedure TwrpControlScrollBar.Set_Range(Value: Integer);
begin
  GetControlScrollBar.Range := Value;
end;

procedure TwrpControlScrollBar.Set_Size(Value: Integer);
begin
  GetControlScrollBar.Size := Value;
end;

procedure TwrpControlScrollBar.Set_Smooth(Value: WordBool);
begin
  GetControlScrollBar.Smooth := Value;
end;

procedure TwrpControlScrollBar.Set_Style(Value: TgsScrollBarStyle);
begin
  GetControlScrollBar.Style := TScrollBarStyle(Value);
end;

procedure TwrpControlScrollBar.Set_ThumbSize(Value: Integer);
begin
  GetControlScrollBar.ThumbSize := Value;
end;

procedure TwrpControlScrollBar.Set_Tracking(Value: WordBool);
begin
  GetControlScrollBar.Tracking := Value;
end;

procedure TwrpControlScrollBar.Set_Visible(Value: WordBool);
begin
  GetControlScrollBar.Visible := Value;
end;

{ TwrpMonitor }

function TwrpMonitor.Get_Handle: Integer;
begin
  Result := GetMonitor.Handle;
end;

function TwrpMonitor.Get_Height: Integer;
begin
  Result := GetMonitor.Height;
end;

function TwrpMonitor.Get_Left: Integer;
begin
  Result := GetMonitor.Left;
end;

function TwrpMonitor.Get_MonitorNum: Integer;
begin
  Result := GetMonitor.MonitorNum;
end;

function TwrpMonitor.Get_Top: Integer;
begin
  Result := GetMonitor.Top;
end;

function TwrpMonitor.Get_Width: Integer;
begin
  Result := GetMonitor.Width;
end;

function TwrpMonitor.GetMonitor: TMonitor;
begin
  Result := GetObject as TMonitor;
end;

{ TwrpFont }

function TwrpFont.Get_Charset: Byte;
begin
  Result := GetFont.Charset;
end;

function TwrpFont.Get_Color: Integer;
begin
  Result := GetFont.Color;
end;

function TwrpFont.Get_Handle: Integer;
begin
  Result := GetFont.Handle;
end;

function TwrpFont.Get_Height: Integer;
begin
  Result := GetFont.Height;
end;

function TwrpFont.Get_Name: WideString;
begin
  Result := GetFont.Name;
end;

function TwrpFont.Get_Pitch: TgsFontPitch;
begin
  Result := TgsFontPitch(GetFont.Pitch);
end;

function TwrpFont.Get_PixelsPerInch: Integer;
begin
  Result := GetFont.PixelsPerInch;
end;

function TwrpFont.Get_Size: Integer;
begin
  Result := GetFont.Size;
end;

function TwrpFont.Get_Style: WideString;
begin
  Result := ' ';
  if fsBold in GetFont.Style then
    Result := Result + 'fsBold ';
  if fsItalic in GetFont.Style then
    Result := Result + 'fsItalic ';
  if fsUnderline in GetFont.Style then
    Result := Result + 'fsUnderline ';
  if fsStrikeOut in GetFont.Style then
    Result := Result + 'fsStrikeOut ';
end;

function TwrpFont.GetFont: TFont;
begin
  Result := GetObject as TFont;
end;

procedure TwrpFont.Set_Charset(Value: Byte);
begin
  GetFont.Charset := Value;
end;

procedure TwrpFont.Set_Color(Value: Integer);
begin
  GetFont.Color := Value;
end;

procedure TwrpFont.Set_Handle(Value: Integer);
begin
  GetFont.Handle := Value;
end;

procedure TwrpFont.Set_Height(Value: Integer);
begin
  GetFont.Height := Value;
end;

procedure TwrpFont.Set_Name(const Value: WideString);
begin
  GetFont.Name := Value;
end;

procedure TwrpFont.Set_Pitch(Value: TgsFontPitch);
begin
  GetFont.Pitch := TFontPitch(Value);
end;

procedure TwrpFont.Set_PixelsPerInch(Value: Integer);
begin
  GetFont.PixelsPerInch := Value;
end;

procedure TwrpFont.Set_Size(Value: Integer);
begin
  GetFont.Size := Value;
end;

procedure TwrpFont.Set_Style(const Value: WideString);
var
  LFontStyle: TFontStyles;
begin
  LFontStyle := [];
  if Pos('FSBOLD', AnsiUpperCase(Value)) > 0 then
    Include(LFontStyle, FSBOLD);
  if Pos('FSITALIC', AnsiUpperCase(Value)) > 0 then
    Include(LFontStyle, FSITALIC);
  if Pos('FSUNDERLINE', AnsiUpperCase(Value)) > 0 then
    Include(LFontStyle, FSUNDERLINE);
  if Pos('FSSTRIKEOUT', AnsiUpperCase(Value)) > 0 then
    Include(LFontStyle, FSSTRIKEOUT);
  GetFont.Style := LFontStyle
end;

class function TwrpFont.CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Result := TFont.Create;
end;

{ TwrpColumnTitle }

function TwrpColumnTitle.DefaultAlignment: TgsAlignment;
begin
  Result := TgsAlignment(GetColumnTitle.DefaultAlignment);
end;

function TwrpColumnTitle.DefaultCaption: WideString;
begin
  Result := GetColumnTitle.DefaultCaption;
end;

function TwrpColumnTitle.DefaultColor: Integer;
begin
  Result := GetColumnTitle.DefaultColor;
end;

function TwrpColumnTitle.DefaultFont: IgsFont;
begin
  Result := GetGdcOLEObject(GetColumnTitle.DefaultFont) as IgsFont;
end;

function TwrpColumnTitle.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(GetColumnTitle.Alignment);
end;

function TwrpColumnTitle.Get_Caption: WideString;
begin
  Result := GetColumnTitle.Caption;
end;

function TwrpColumnTitle.Get_Color: Integer;
begin
  Result := GetColumnTitle.Color;
end;

function TwrpColumnTitle.Get_Column: IgsColumn;
begin
  Result := GetGdcOLEObject(GetColumnTitle.Column) as IgsColumn;
end;

function TwrpColumnTitle.Get_Font: IgsFont;
begin
  Result := GetGdcOLEObject(GetColumnTitle.Font) as IgsFont;
end;

function TwrpColumnTitle.GetColumnTitle: TColumnTitle;
begin
  Result := GetObject as TColumnTitle;
end;

procedure TwrpColumnTitle.RestoreDefaults;
begin
  GetColumnTitle.RestoreDefaults;
end;

procedure TwrpColumnTitle.Set_Alignment(Value: TgsAlignment);
begin
  GetColumnTitle.Alignment := TAlignment(Value);
end;

procedure TwrpColumnTitle.Set_Caption(const Value: WideString);
begin
  GetColumnTitle.Caption := Value;
end;

procedure TwrpColumnTitle.Set_Color(Value: Integer);
begin
  GetColumnTitle.Color := Value;
end;

procedure TwrpColumnTitle.Set_Font(const Value: IgsFont);
begin
  GetColumnTitle.Font := InterfaceToObject(Value) as TFont;
end;

{ TwrpColumn }

function TwrpColumn.DefaultAlignment: TgsAlignment;
begin
  Result := TgsAlignment(GetColumn.DefaultAlignment);
end;

function TwrpColumn.DefaultColor: Integer;
begin
  Result := GetColumn.DefaultColor;
end;

function TwrpColumn.DefaultFont: IgsFont;
begin
  Result := GetGdcOLEObject(GetColumn.DefaultFont) as IgsFont;
end;

function TwrpColumn.DefaultImeMode: TgsImeMode;
begin
  Result := TgsImeMode(GetColumn.DefaultImeMode);
end;

function TwrpColumn.DefaultImeName: WideString;
begin
  Result := GetColumn.DefaultImeName;
end;

function TwrpColumn.DefaultReadOnly: WordBool;
begin
  Result := GetColumn.DefaultReadOnly;
end;

function TwrpColumn.DefaultWidth: Integer;
begin
  Result := GetColumn.DefaultWidth;
end;

function TwrpColumn.Depth: Integer;
begin
  Result := GetColumn.Depth;
end;

function TwrpColumn.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(GetColumn.Alignment);
end;

function TwrpColumn.Get_AssignedValues: WideString;
begin
  Result := ' ';
  if cvColor in GetColumn.AssignedValues then
    Result := Result + 'cvColor ';
  if cvWidth in GetColumn.AssignedValues then
    Result := Result + 'cvWidth ';
  if cvFont in GetColumn.AssignedValues then
    Result := Result + 'cvFont ';
  if cvAlignment in GetColumn.AssignedValues then
    Result := Result + 'cvAlignment ';
  if cvReadOnly in GetColumn.AssignedValues then
    Result := Result + 'cvReadOnly ';
  if cvTitleColor in GetColumn.AssignedValues then
    Result := Result + 'cvTitleColor ';
  if cvTitleCaption in GetColumn.AssignedValues then
    Result := Result + 'cvTitleCaption ';
  if cvTitleAlignment in GetColumn.AssignedValues then
    Result := Result + 'cvTitleAlignment ';
  if cvTitleFont in GetColumn.AssignedValues then
    Result := Result + 'cvTitleFont ';
  if cvImeMode in GetColumn.AssignedValues then
    Result := Result + 'cvImeMode ';
  if cvImeName in GetColumn.AssignedValues then
    Result := Result + 'cvImeName ';
end;

function TwrpColumn.Get_ButtonStyle: TgsColumnButtonStyle;
begin
  Result := TgsColumnButtonStyle(GetColumn.ButtonStyle);
end;

function TwrpColumn.Get_Color: Integer;
begin
  Result := GetColumn.Color;
end;

function TwrpColumn.Get_DisplayName_: WideString;
begin
  Result := GetColumn.DisplayName;
end;

function TwrpColumn.Get_DropDownRows: LongWord;
begin
  Result := GetColumn.DropDownRows;
end;

function TwrpColumn.Get_Expandable: WordBool;
begin
  Result := GetColumn.Expandable;
end;

function TwrpColumn.Get_Field: IgsFieldComponent;
begin
  Result := GetGdcOleObject(GetColumn.Field) as IgsFieldComponent;
end;

function TwrpColumn.Get_FieldName: WideString;
begin
  Result := GetColumn.FieldName;
end;

function TwrpColumn.Get_Font: IgsFont;
begin
  Result := GetGdcOLEObject(GetColumn.Font) as IgsFont;
end;

function TwrpColumn.Get_Grid: IgsCustomDBGrid;
begin
  Result := GetGdcOLEObject(GetColumn.Grid) as IgsCustomDBGrid;
end;

function TwrpColumn.Get_ImeMode: TgsImeMode;
begin
  Result := TgsImeMode(GetColumn.Font);
end;

function TwrpColumn.Get_ImeName: WideString;
begin
  Result := GetColumn.ImeName;
end;

function TwrpColumn.Get_ParentColumn: IgsColumn;
begin
  Result := GetGdcOLEObject(GetColumn.ParentColumn) as IgsColumn;
end;

function TwrpColumn.Get_PickList: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetColumn.PickList);
end;

function TwrpColumn.Get_PopupMenu: IgsPopupMenu;
begin
  Result := GetGdcOLEObject(GetColumn.PopupMenu) as IgsPopupMenu;
end;

function TwrpColumn.Get_ReadOnly: WordBool;
begin
  Result := GetColumn.ReadOnly;
end;

function TwrpColumn.Get_Showing: WordBool;
begin
  Result := GetColumn.Showing;
end;

function TwrpColumn.Get_Title: IgsColumnTitle;
begin
  Result := GetGdcOLEObject(GetColumn.Title) as IgsColumnTitle;
end;

function TwrpColumn.Get_Visible: WordBool;
begin
  Result := GetColumn.Visible;
end;

function TwrpColumn.Get_Width: Integer;
begin
  Result := GetColumn.Width;
end;

function TwrpColumn.GetColumn: TColumn;
begin
  Result := GetObject as TColumn;
end;

procedure TwrpColumn.RestoreDefaults;
begin
  GetColumn.RestoreDefaults;
end;

procedure TwrpColumn.Set_Alignment(Value: TgsAlignment);
begin
  GetColumn.Alignment := TAlignment(Value);
end;

procedure TwrpColumn.Set_ButtonStyle(Value: TgsColumnButtonStyle);
begin
  GetColumn.ButtonStyle := TColumnButtonStyle(Value);
end;

procedure TwrpColumn.Set_Color(Value: Integer);
begin
  GetColumn.Color := Value;
end;

procedure TwrpColumn.Set_DisplayName_(const Value: WideString);
begin
  GetColumn.DisplayName := Value;
end;

procedure TwrpColumn.Set_DropDownRows(Value: LongWord);
begin
  GetColumn.DropDownRows := Value;
end;

procedure TwrpColumn.Set_Field(const Value: IgsFieldComponent);
begin
  GetColumn.Field := InterfaceToObject(Value) as TField;
end;

procedure TwrpColumn.Set_FieldName(const Value: WideString);
begin
  GetColumn.FieldName := Value;
end;

procedure TwrpColumn.Set_Font(const Value: IgsFont);
begin
  GetColumn.Font := InterfaceToObject(Value) as TFont;
end;

procedure TwrpColumn.Set_ImeMode(Value: TgsImeMode);
begin
  GetColumn.ImeMode := TImeMode(Value);
end;

procedure TwrpColumn.Set_ImeName(const Value: WideString);
begin
  GetColumn.ImeName := Value;
end;

procedure TwrpColumn.Set_PickList(const Value: IgsStrings);
begin
  GetColumn.PickList := IgsStringsToTStrings(Value);
end;

procedure TwrpColumn.Set_PopupMenu(const Value: IgsPopupMenu);
begin
  GetColumn.PopupMenu := InterfaceToObject(Value) as TPopupMenu;
end;

procedure TwrpColumn.Set_ReadOnly(Value: WordBool);
begin
  GetColumn.ReadOnly := Value;
end;

procedure TwrpColumn.Set_Title(const Value: IgsColumnTitle);
begin
  GetColumn.Title := InterfaceToObject(Value) as TColumnTitle;
end;

procedure TwrpColumn.Set_Visible(Value: WordBool);
begin
  GetColumn.Visible := Value;
end;

procedure TwrpColumn.Set_Width(Value: Integer);
begin
  GetColumn.Width := Value;
end;

{ TwrpDBGridColumns }

function TwrpDBGridColumns.Add: IgsColumn;
begin
  Result := GetGdcOLEObject(GetDBGridColumns.Add) as IgsColumn;
end;

function TwrpDBGridColumns.Get_Grid: IgsCustomDBGrid;
begin
  Result := GetGdcOLEObject(GetDBGridColumns.Grid) as IgsCustomDBGrid;
end;

function TwrpDBGridColumns.Get_Items(Index: Integer): IgsColumn;
begin
  Result := GetGdcOLEObject(GetDBGridColumns.Items[Index]) as IgsColumn;
end;

function TwrpDBGridColumns.Get_State: TgsDBGridColumnsState;
begin
  Result := TgsDBGridColumnsState(GetDBGridColumns.State);
end;

function TwrpDBGridColumns.GetDBGridColumns: TDBGridColumns;
begin
  Result := GetObject as TDBGridColumns;
end;

procedure TwrpDBGridColumns.LoadFromFile(const FileName: WideString);
begin
  GetDBGridColumns.LoadFromFile(FileName);
end;

procedure TwrpDBGridColumns.LoadFromStream(const S: IgsStream);
begin
  GetDBGridColumns.LoadFromStream(InterfaceToObject(S) as TStream)
end;

procedure TwrpDBGridColumns.RebuildColumns;
begin
  GetDBGridColumns.RebuildColumns;
end;

procedure TwrpDBGridColumns.RestoreDefaults;
begin
  GetDBGridColumns.RestoreDefaults;
end;

procedure TwrpDBGridColumns.SaveToFile(const FileName: WideString);
begin
  GetDBGridColumns.SaveToFile(FileName);
end;

procedure TwrpDBGridColumns.SaveToStream(const S: IgsStream);
begin
  GetDBGridColumns.SaveToStream(InterfaceToObject(S) as TStream)
end;

procedure TwrpDBGridColumns.Set_Items(Index: Integer;
  const Value: IgsColumn);
begin
  GetDBGridColumns.Items[Index] := InterfaceToObject(Value) as TColumn;
end;

procedure TwrpDBGridColumns.Set_State(Value: TgsDBGridColumnsState);
begin
  GetDBGridColumns.State := TDBGridColumnsState(Value);
end;

{ TwrpFiler }

procedure TwrpFiler.FlushBuffer;
begin
  GetFiler.FlushBuffer;
end;

function TwrpFiler.Get_Ancestor: IgsPersistent;
begin
  Result := GetGdcOLEObject(GetFiler.Ancestor) as IgsPersistent;
end;

function TwrpFiler.Get_IgnoreChildren: WordBool;
begin
  Result := GetFiler.IgnoreChildren;
end;

function TwrpFiler.Get_LookupRoot: IgsComponent;
begin
  Result := GetGdcOLEObject(GetFiler.LookupRoot) as IgsComponent;
end;

function TwrpFiler.Get_Root: IgsComponent;
begin
  Result := GetGdcOLEObject(GetFiler.Root) as IgsComponent;
end;

function TwrpFiler.GetFiler: TFiler;
begin
  Result := GetObject as TFiler;
end;

procedure TwrpFiler.Set_Ancestor(const Value: IgsPersistent);
begin
  GetFiler.Ancestor := InterfaceToObject(Value) as TPersistent;
end;

procedure TwrpFiler.Set_IgnoreChildren(Value: WordBool);
begin
  GetFiler.IgnoreChildren := Value;
end;

procedure TwrpFiler.Set_Root(const Value: IgsComponent);
begin
  GetFiler.Root := InterfaceToObject(Value) as TComponent;
end;

{ TwrpReader }

procedure TwrpReader.BeginReferences;
begin
  GetReader.BeginReferences;
end;

procedure TwrpReader.CheckValue(Value: TgsValueType);
begin
  GetReader.CheckValue(TValueType(Value));
end;

procedure TwrpReader.CopyValue(const Writer: IgsWriter);
begin
  GetReader.CopyValue(InterfaceToObject(Writer) as TWriter);
end;

function TwrpReader.EndOfList: WordBool;
begin
  Result := GetReader.EndOfList;
end;

procedure TwrpReader.EndReferences;
begin
  GetReader.EndReferences;
end;

procedure TwrpReader.FixupReferences;
begin
  GetReader.FixupReferences;
end;

function TwrpReader.Get_Owner: IgsComponent;
begin
  Result := GetGdcOLEObject(GetReader.Owner) as IgsComponent;
end;

function TwrpReader.Get_Parent: IgsComponent;
begin
  Result := GetGdcOLEObject(GetReader.Owner) as IgsComponent;
end;

function TwrpReader.Get_Position: Integer;
begin
  Result := GetReader.Position;
end;

function TwrpReader.GetReader: TReader;
begin
  Result := GetObject as TReader;
end;

function TwrpReader.NextValue: TgsValueType;
begin
  Result := TgsValueType(GetReader.NextValue);
end;

function TwrpReader.ReadBoolean: WordBool;
begin
  Result := GetReader.ReadBoolean;
end;

function TwrpReader.ReadChar: Byte;
begin
  Result := Byte(GetReader.ReadChar);
end;

procedure TwrpReader.ReadCollection(const Collection: IgsCollection);
begin
  GetReader.ReadCollection(InterfaceToObject(Collection) as TCollection);
end;

function TwrpReader.ReadComponent(
  const Component: IgsComponent): IgsComponent;
begin
  Result := GetGdcOleObject(GetReader.ReadComponent(InterfaceToObject(Component)as TComponent)) as IgsComponent;
end;

function TwrpReader.ReadCurrency: Currency;
begin
  Result := GetReader.ReadCurrency;
end;

function TwrpReader.ReadDate: TDateTime;
begin
  Result := GetReader.ReadDate;
end;

function TwrpReader.ReadIdent: WideString;
begin
  Result := GetReader.ReadIdent;
end;

function TwrpReader.ReadInt64: Int64;
begin
  Result := GetReader.ReadInt64;
end;

function TwrpReader.ReadInteger: Integer;
begin
  Result := GetReader.ReadInteger;
end;

procedure TwrpReader.ReadListBegin;
begin
  GetReader.ReadListBegin;
end;

procedure TwrpReader.ReadListEnd;
begin
  GetReader.ReadListEnd;
end;

procedure TwrpReader.ReadPrefix(const Flag: WideString;
  var AChildPos: OleVariant);
var
  LFlag: TFilerFlags;
  cp: Integer;
begin
  LFlag := [];
  if Pos('FFINHERITED', AnsiUpperCase(Flag)) > 0 then
    Include(LFlag, ffInherited);
  if Pos('FFCHILDPOS', AnsiUpperCase(Flag)) > 0 then
    Include(LFlag, ffChildPos);
  if Pos('FFINLINE', AnsiUpperCase(Flag)) > 0 then
    Include(LFlag, ffInline);

  cp := AChildPos;
  GetReader.ReadPrefix(LFlag, cp);
  AChildPos := cp;
end;

function TwrpReader.ReadRootComponent(
  const Root: IgsComponent): IgsComponent;
begin
  Result := GetGdcOleObject(GetReader.ReadRootComponent(InterfaceToObject(Root) as TComponent)) as IgsComponent;
end;

procedure TwrpReader.ReadSignature;
begin
  GetReader.ReadSignature;
end;

function TwrpReader.ReadStr: WideString;
begin
  Result := GetReader.ReadStr;
end;

function TwrpReader.ReadString: WideString;
begin
  Result := GetReader.ReadString;
end;

function TwrpReader.ReadValue: TgsValueType;
begin
  Result := TgsValueType(GetReader.readValue);
end;

function TwrpReader.ReadWideString: WideString;
begin
  Result := GetReader.ReadWideString;
end;

procedure TwrpReader.Set_Owner(const Value: IgsComponent);
begin
  GetReader.Owner := InterfaceToObject(Value) as TComponent;
end;

procedure TwrpReader.Set_Parent(const Value: IgsComponent);
begin
  GetReader.Parent := InterfaceToObject(Value) as TComponent;
end;

procedure TwrpReader.Set_Position(Value: Integer);
begin
  GetReader.Position := Value;
end;

{ TwrpWriter }

function TwrpWriter.Get_Position: Integer;
begin
  Result := GetWriter.Position;
end;

function TwrpWriter.Get_RootAncestor: IgsComponent;
begin
  Result := GetGdcOLEObject(GetWriter.RootAncestor) as IgsComponent;
end;

function TwrpWriter.GetWriter: TWriter;
begin
  Result := GetObject as TWriter;
end;

procedure TwrpWriter.Set_Position(Value: Integer);
begin
  GetWriter.Position := Value;
end;

procedure TwrpWriter.Set_RootAncestor(const Value: IgsComponent);
begin
  GetWriter.RootAncestor := InterfacetoObject(Value) as TComponent;
end;

procedure TwrpWriter.WriteBoolean(Value: WordBool);
begin
  GetWriter.WriteBoolean(Value);
end;

procedure TwrpWriter.WriteChar(Value: Byte);
begin
  GetWriter.WriteChar(Chr(Value));
end;

procedure TwrpWriter.WriteCollection(const Value: IgsCollection);
begin
  GetWriter.WriteCollection(InterfaceToObject(Value) as TCollection);
end;

procedure TwrpWriter.WriteComponent(const Value: IgsComponent);
begin
  GetWriter.WriteComponent(InterfaceToObject(Value) as TComponent);
end;

procedure TwrpWriter.WriteCurrency(Value: Currency);
begin
  GetWriter.WriteCurrency(Value);
end;

procedure TwrpWriter.WriteDate(Value: TDateTime);
begin
  GetWriter.WriteDate(Value);
end;

procedure TwrpWriter.WriteDescendent(const Root, AAncestor: IgsComponent);
begin
  GetWriter.WriteDescendent(InterfaceToObject(Root) as TComponent, InterfaceToObject(AAncestor) as TComponent);
end;

procedure TwrpWriter.WriteInteger(Value: Integer);
begin
  GetWriter.WriteInteger(Value);
end;

procedure TwrpWriter.WriteListBegin;
begin
  GetWriter.WriteListBegin;
end;

procedure TwrpWriter.WriteListEnd;
begin
  GetWriter.WriteListEnd;
end;

procedure TwrpWriter.WriteRootComponent(const Value: IgsComponent);
begin
  GetWriter.WriteRootComponent(InterfaceToObject(Value) as TComponent);
end;

procedure TwrpWriter.WriteSignature;
begin
  GetWriter.WriteSignature;
end;

procedure TwrpWriter.WriteStr(const Value: WideString);
begin
  GetWriter.WriteStr(Value);
end;

procedure TwrpWriter.WriteString(const Value: WideString);
begin
  GetWriter.WriteString(Value);
end;

procedure TwrpWriter.WriteWideString(const Value: WideString);
begin
  GetWriter.WriteWideString(Value);
end;

{ TwrpDataLink }

function TwrpDataLink.Edit: WordBool;
begin
  Result := GetDataLink.Edit;
end;

function TwrpDataLink.ExecuteAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := GetDataLink.ExecuteAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpDataLink.Get_Active: WordBool;
begin
  Result := GetDataLink.Active;
end;

function TwrpDataLink.Get_ActiveRecord: Integer;
begin
  Result := GetDataLink.ActiveRecord;
end;

function TwrpDataLink.Get_BOF: WordBool;
begin
  Result := GetDataLink.BOF;
end;

function TwrpDataLink.Get_BufferCount: Integer;
begin
  Result := GetDataLink.BufferCount;
end;

function TwrpDataLink.Get_DataSet: IgsDataSet;
begin
  Result := GetGdcOLEObject(GetDataLink.DataSet) as IgsDataSet;
end;

function TwrpDataLink.Get_DataSource: IgsDataSource;
begin
  Result := GetGdcOLEObject(GetDataLink.DataSource) as IgsDataSource;
end;

function TwrpDataLink.Get_Editing: WordBool;
begin
  Result := GetDataLink.Editing;
end;

function TwrpDataLink.Get_Eof: WordBool;
begin
  Result := GetDataLink.Eof;
end;

function TwrpDataLink.Get_ReadOnly: WordBool;
begin
  Result := GetDataLink.ReadOnly;
end;

function TwrpDataLink.Get_RecordCount: Integer;
begin
  Result := GetDataLink.RecordCount;
end;

function TwrpDataLink.GetDataLink: TDataLink;
begin
  Result := GetObject as TDataLink;
end;

procedure TwrpDataLink.Set_ActiveRecord(Value: Integer);
begin
  GetDataLink.ActiveRecord := Value;
end;

procedure TwrpDataLink.Set_BufferCount(Value: Integer);
begin
  GetDataLink.BufferCount := Value;
end;

procedure TwrpDataLink.Set_DataSource(const Value: IgsDataSource);
begin
  GetDataLink.DataSource := InterfaceToObject(Value) as TDataSource;
end;

procedure TwrpDataLink.Set_ReadOnly(Value: WordBool);
begin
  GetDataLink.ReadOnly := Value;
end;

function TwrpDataLink.UpdateAction(const Action: IgsBasicAction): WordBool;
begin
  Result := GetDataLink.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

procedure TwrpDataLink.UpdateRecord;
begin
  GetDataLink.UpdateRecord;
end;

class function TwrpDataLink.CreateObject(const DelphiClass: TClass; 
  const Params: OleVariant): TObject;
begin
  Result := TDataLink.Create;
end;

{ TwrpGridDataLink }

function TwrpGridDataLink.AddMapping(
  const FieldName: WideString): WordBool;
begin
  Result := GetGridDataLink.AddMapping(FieldName);
end;

procedure TwrpGridDataLink.ClearMapping;
begin
  GetGridDataLink.ClearMapping;
end;

function TwrpGridDataLink.Get_DefaultFields: WordBool;
begin
  Result := GetGridDataLink.DefaultFields;
end;

function TwrpGridDataLink.Get_FieldCount: Integer;
begin
  Result := GetGridDataLink.FieldCount;
end;

function TwrpGridDataLink.Get_Fields(I: Integer): IgsFieldComponent;
begin
  Result := GetGdcOLEObject(GetGridDataLink.Fields[i]) as IgsFieldComponent;
end;

function TwrpGridDataLink.Get_SparseMap: WordBool;
begin
  Result := GetGridDataLink.SparseMap;
end;

function TwrpGridDataLink.GetGridDataLink: TGridDataLink;
begin
  Result := GetObject as TGridDataLink;
end;

procedure TwrpGridDataLink.Modified;
begin
  GetGridDataLink.Modified;
end;

procedure TwrpGridDataLink.Reset;
begin
  GetGridDataLink.Reset;
end;

procedure TwrpGridDataLink.Set_SparseMap(Value: WordBool);
begin
  GetGridDataLink.SparseMap := Value;
end;

{ TwrpObjectList }

function TwrpObjectList.Add(const AObject: IgsObject): Integer;
begin
  Result := GetObjectList.Add(InterfaceToObject(AObject) as TObject);
end;

procedure TwrpObjectList.Clear;
begin
  GetObjectList.Clear;
end;

procedure TwrpObjectList.Delete(Index: Integer);
begin
  GetObjectList.Delete(Index);
end;

function TwrpObjectList.Get_Items_(Index: Integer): IgsObject;
begin
  Result := GetGdcOLEObject(GetObjectList.Items[Index]) as IgsObject;
end;

function TwrpObjectList.Get_OwnsObjects: WordBool;
begin
  Result := GetObjectList.OwnsObjects;
end;

function TwrpObjectList.GetObjectList: TObjectList;
begin
  Result := GetObject as TObjectList;
end;

function TwrpObjectList.IndexOf(const AObject: IgsObject): Integer;
begin
  Result := GetObjectList.IndexOf(InterfaceToObject(AObject));
end;

procedure TwrpObjectList.Insert(Index: Integer; const AObject: IgsObject);
begin
  GetObjectList.Insert(Index, InterfaceToObject(AObject))
end;

function TwrpObjectList.Remove(const AObject: IgsObject): Integer;
begin
  Result := GetObjectList.Remove(InterfaceToObject(AObject))
end;

procedure TwrpObjectList.Set_Items_(Index: Integer; const Value: IgsObject);
begin
  GetObjectList.Items[Index] := InterfaceToObject(Value);
end;

procedure TwrpObjectList.Set_OwnsObjects(Value: WordBool);
begin
  GetObjectList.OwnsObjects := Value;
end;

class function TwrpObjectList.CreateObject(const DelphiClass: TClass; 
  const Params: OleVariant): TObject;
begin
  if VariantIsArray(Params) and (VarArrayHighBound(Params, 1) = 0) then
    Result := TObjectList.Create(Boolean(Params[0]))
  else
    if VarType(Params) = varBoolean then
      Result := TObjectList.Create(Boolean(Params))
    else
      Result := TObjectList.Create;
end;

{ TwrpTreeNode }

function TwrpTreeNode.AlphaSort: WordBool;
begin
  Result := GetTreeNode.AlphaSort;
end;

procedure TwrpTreeNode.Collapse(Recurse: WordBool);
begin
  GetTreeNode.Collapse(Recurse);
end;

procedure TwrpTreeNode.Delete;
begin
  GetTreeNode.Delete;
end;

procedure TwrpTreeNode.DeleteChildren;
begin
  GetTreeNode.DeleteChildren;
end;

function TwrpTreeNode.EditText: WordBool;
begin
  Result := GetTreeNode.EditText;
end;

procedure TwrpTreeNode.EndEdit(Cancel: WordBool);
begin
  GetTreeNode.EndEdit(Cancel);
end;

procedure TwrpTreeNode.Expand(Recurse: WordBool);
begin
  GetTreeNode.Expand(Recurse);
end;

function TwrpTreeNode.Get_AbsoluteIndex: Integer;
begin
  Result := GetTreeNode.AbsoluteIndex;
end;

function TwrpTreeNode.Get_Count: Integer;
begin
  Result := GetTreeNode.Count;
end;

function TwrpTreeNode.Get_Cut: WordBool;
begin
  Result := GetTreeNode.Cut;
end;

function TwrpTreeNode.Get_Deleting: WordBool;
begin
  Result := GetTreeNode.Deleting;
end;

function TwrpTreeNode.Get_DropTarget: WordBool;
begin
  Result := GetTreeNode.DropTarget;
end;

function TwrpTreeNode.Get_Expanded: WordBool;
begin
  Result := GetTreeNode.Expanded;
end;

function TwrpTreeNode.Get_Focused: WordBool;
begin
  Result := GetTreeNode.Focused;
end;

function TwrpTreeNode.Get_Handle: Integer;
begin
  Result := GetTreeNode.Handle;
end;

function TwrpTreeNode.Get_HasChildren: WordBool;
begin
  Result := GetTreeNode.HasChildren;
end;

function TwrpTreeNode.Get_ImageIndex: Integer;
begin
  Result := GetTreeNode.ImageIndex;
end;

function TwrpTreeNode.Get_Index: Integer;
begin
  Result := GetTreeNode.Index;
end;

function TwrpTreeNode.Get_IsVisible: WordBool;
begin
  Result := GetTreeNode.IsVisible;
end;

function TwrpTreeNode.Get_Item(Index: Integer): IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.Item[Index]) as IgsTreeNode;
end;

function TwrpTreeNode.Get_Level: Integer;
begin
  Result := GetTreeNode.Level;
end;

function TwrpTreeNode.Get_OverlayIndex: Integer;
begin
  Result := GetTreeNode.OverlayIndex;
end;

function TwrpTreeNode.Get_Owner: IgsTreeNodes;
begin
  Result := GetGdcOleObject(GetTreeNode.Owner) as IgsTreeNodes;
end;

function TwrpTreeNode.Get_Parent: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.Parent) as IgsTreeNode;
end;

function TwrpTreeNode.Get_Selected: WordBool;
begin
  Result := GetTreeNode.Selected;
end;

function TwrpTreeNode.Get_SelectedIndex: Integer;
begin
  Result := GetTreeNode.SelectedIndex;
end;

function TwrpTreeNode.Get_StateIndex: Integer;
begin
  Result := GetTreeNode.StateIndex;
end;

function TwrpTreeNode.Get_Text: WideString;
begin
  Result := GetTreeNode.Text;
end;

function TwrpTreeNode.Get_TreeView: IgsCustomTreeView;
begin
  Result := GetGdcOLEObject(GetTreeNode.TreeView) as IgsCustomTreeView;
end;

function TwrpTreeNode.GetFirstChild: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.getFirstChild) as IgsTreeNode;
end;

function TwrpTreeNode.GetHandle: Integer;
begin
  Result := GetTreeNode.GetHandle;
end;

function TwrpTreeNode.GetLastChild: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.GetLastChild) as IgsTreeNode;
end;

function TwrpTreeNode.GetNext: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.GetNext) as IgsTreeNode;
end;

function TwrpTreeNode.GetNextChild(const Value: IgsTreeNode): IgsTreeNode;
begin
  Result :=
    GetGdcOLEObject(GetTreeNode.GetNextChild(InterfaceToObject(Value) as TTreeNode)) as IgsTreeNode;
end;

function TwrpTreeNode.GetNextSibling: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.getNextSibling) as IgsTreeNode;
end;

function TwrpTreeNode.GetNextVisible: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.GetNextVisible) as IgsTreeNode;
end;

function TwrpTreeNode.GetPrev: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.GetPrev) as IgsTreeNode;
end;

function TwrpTreeNode.GetPrevChild(const Value: IgsTreeNode): IgsTreeNode;
begin
  Result :=
    GetGdcOLEObject(GetTreeNode.GetPrevChild(InterfaceToObject(Value) as TTreeNode)) as IgsTreeNode;
end;

function TwrpTreeNode.GetPrevSibling: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.getPrevSibling) as IgsTreeNode;
end;

function TwrpTreeNode.GetPrevVisible: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNode.GetPrevVisible) as IgsTreeNode;
end;

function TwrpTreeNode.GetTreeNode: TTreeNode;
begin
  Result := GetObject as TTreeNode;
end;

function TwrpTreeNode.HasAsParent(const Value: IgsTreeNode): WordBool;
begin
  Result := GetTreeNode.HasAsParent(InterfaceToObject(Value) as TTreeNode);
end;

function TwrpTreeNode.IndexOf(const Value: IgsTreeNode): Integer;
begin
  Result := GetTreeNode.IndexOf(InterfaceToObject(Value) as TTreeNode);
end;

procedure TwrpTreeNode.MakeVisible;
begin
  GetTreeNode.MakeVisible;
end;

procedure TwrpTreeNode.MoveTo(const Destination: IgsTreeNode;
  Mode: TgsNodeAttachMode);
begin
  GetTreeNode.MoveTo(InterfaceToObject(Destination) as TTreeNode,
    TNodeAttachMode(Mode));
end;

procedure TwrpTreeNode.Set_Cut(Value: WordBool);
begin
  GetTreeNode.Cut := Value;
end;

procedure TwrpTreeNode.Set_DropTarget(Value: WordBool);
begin
  GetTreeNode.DropTarget := Value;
end;

procedure TwrpTreeNode.Set_Expanded(Value: WordBool);
begin
  GetTreeNode.Expanded := Value;
end;

procedure TwrpTreeNode.Set_Focused(Value: WordBool);
begin
  GetTreeNode.Focused := Value;
end;

procedure TwrpTreeNode.Set_HasChildren(Value: WordBool);
begin
  GetTreeNode.HasChildren := Value;
end;

procedure TwrpTreeNode.Set_ImageIndex(Value: Integer);
begin
  GetTreeNode.ImageIndex := Value;
end;

procedure TwrpTreeNode.Set_OverlayIndex(Value: Integer);
begin
  GetTreeNode.OverlayIndex := Value;
end;

procedure TwrpTreeNode.Set_Selected(Value: WordBool);
begin
  GetTreeNode.Selected := Value;
end;

procedure TwrpTreeNode.Set_SelectedIndex(Value: Integer);
begin
  GetTreeNode.SelectedIndex := Value;
end;

procedure TwrpTreeNode.Set_StateIndex(Value: Integer);
begin
  GetTreeNode.StateIndex := Value;
end;

procedure TwrpTreeNode.Set_Text(const Value: WideString);
begin
  GetTreeNode.Text := Value;
end;

function TwrpTreeNode.Get_Data: Integer;
begin
  Result := Integer(GetTreeNode.Data);
end;

procedure TwrpTreeNode.Set_Data(Value: Integer);
begin
  GetTreeNode.Data := Pointer(Value);
end;

{ TwrpTreeNodes }

function TwrpTreeNodes.Add(const Node: IgsTreeNode;
  const S: WideString): IgsTreeNode;
begin
  Result :=  GetGdcOLEObject(GetTreeNodes.Add(InterfaceToObject(Node) as TTreeNode, S)) as IgsTreeNode;
end;

function TwrpTreeNodes.AddChild(const Node: IgsTreeNode;
  const S: WideString): IgsTreeNode;
begin
  Result :=  GetGdcOLEObject(GetTreeNodes.AddChild(InterfaceToObject(Node) as TTreeNode, S)) as IgsTreeNode;
end;

function TwrpTreeNodes.AddChildFist(const Node: IgsTreeNode;
  const S: WideString): IgsTreeNode;
begin
  Result :=  GetGdcOLEObject(GetTreeNodes.AddChildFirst(InterfaceToObject(Node) as TTreeNode, S )) as IgsTreeNode;
end;

procedure TwrpTreeNodes.BeginUpdate;
begin
  GetTreeNodes.BeginUpdate;
end;

procedure TwrpTreeNodes.Clear;
begin
  GetTreeNodes.Clear;
end;

procedure TwrpTreeNodes.Delete(const Node: IgsTreeNode);
begin
  GetTreeNodes.Delete(InterfaceToObject(Node) as TTreeNode);
end;

procedure TwrpTreeNodes.EndUpdate;
begin
  GetTreeNodes.EndUpdate;
end;

function TwrpTreeNodes.Get_Count: Integer;
begin
  Result := GetTreeNodes.Count;
end;

function TwrpTreeNodes.Get_Handle: Integer;
begin
  Result := GetTreeNodes.Handle;
end;

function TwrpTreeNodes.Get_Item(Index: Integer): IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNodes.Item[Index]) as IgsTreeNode;
end;

function TwrpTreeNodes.Get_Owner: IgsCustomTreeView;
begin
  Result := GetGdcOLEObject(GetTreeNodes.Owner) as IgsCustomTreeView;
end;

function TwrpTreeNodes.GetFirstNode: IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNodes.GetFirstNode) as IgsTreeNode;
end;

function TwrpTreeNodes.GetTreeNodes: TTreeNodes;
begin
  Result := GetObject as TTreeNodes;
end;

function TwrpTreeNodes.Insert(const Node: IgsTreeNode;
  const S: WideString): IgsTreeNode;
begin
  Result := GetGdcOLEObject(GetTreeNodes.Insert(InterfaceToObject(Node) as TTreeNode, S)) as IgsTreeNode;
end;

{ TwrpStringStream }

function TwrpStringStream.Get_DataString: WideString;
begin
  Result := GetStringStream.DataString;
end;

function TwrpStringStream.GetStringStream: TStringStream;
begin
  Result := GetObject as TStringStream;
end;

function TwrpStringStream.ReadString(Count: Integer): WideString;
begin
  Result := GetStringStream.ReadString(Count);
end;

procedure TwrpStringStream.WriteString(const AString: WideString);
begin
  GetStringStream.WriteString(AString);
end;

class function TwrpStringStream.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Result := nil;
  if VariantIsArray(Params) and (VarArrayHighBound(Params, 1) = 0) then
    Result := TStringStream.Create(String(Params[0]))
  else
    ErrorParamsCount('1');
end;

{ TwrpBasicAction }

function TwrpBasicAction.Execute: WordBool;
begin
  Result := GetBasicAction.Execute;
end;

procedure TwrpBasicAction.ExecuteTarget(const Target: IgsObject);
begin
  GetBasicAction.ExecuteTarget(InterfaceToObject(Target));
end;

function TwrpBasicAction.GetBasicAction: TBasicAction;
begin
  Result := GetObject as TBasicAction;
end;

procedure TwrpBasicAction.HandlesTarget(const Target: IgsObject);
begin
  GetBasicAction.HandlesTarget(InterfaceToObject(Target));
end;

procedure TwrpBasicAction.RegisterChanges(const Value: IgsBasicActionLink);
begin
  GetBasicAction.RegisterChanges(InterfaceToObject(Value) as TBasicActionLink);
end;

procedure TwrpBasicAction.UnRegisterChanges(
  const Value: IgsBasicActionLink);
begin
  GetBasicAction.UnRegisterChanges(InterfaceToObject(Value) as TBasicActionLink);
end;

function TwrpBasicAction.Update: WordBool;
begin
  Result := GetBasicAction.Update;
end;

procedure TwrpBasicAction.UpdateTarget(const Target: IgsObject);
begin
  GetBasicAction.UpdateTarget(InterfaceToObject(Target));
end;

{ TwrpBookmarkList }

procedure TwrpBookmarkList.Clear;
begin
  GetBookmarkList.Clear;
end;

procedure TwrpBookmarkList.Delete;
begin
  GetBookmarkList.Delete;
end;

function TwrpBookmarkList.Find(const Item: WideString;
  var Index: OleVariant): WordBool;
var
  LIndex: Integer;
begin
  LIndex := Index;
  Result := GetBookmarkList.Find(Item, LIndex);
  Index := LIndex;
end;

function TwrpBookmarkList.Get_Count: Integer;
begin
  Result := GetBookmarkList.Count;
end;

function TwrpBookmarkList.Get_CurrentRowSelected: WordBool;
begin
  Result := GetBookmarkList.CurrentRowSelected;
end;

function TwrpBookmarkList.Get_Items(Index: Integer): WideString;
begin
//  Result := Integer(Pointer(GetBookmarkList.Items[Index]));
//  Result := Integer(GetBookmarkList.Items[Index]);
  Result := GetBookmarkList.Items[Index];
end;

function TwrpBookmarkList.GetBookmarkList: TBookmarkList;
begin
  Result := GetObject as TBookmarkList;
end;

function TwrpBookmarkList.IndexOf(const Item: WideString): Integer;
begin
  Result := GetBookmarkList.IndexOf(Item);
end;

function TwrpBookmarkList.Refresh: WordBool;
begin
  Result := GetBookmarkList.Refresh;
end;

procedure TwrpBookmarkList.Set_CurrentRowSelected(Value: WordBool);
begin
  GetBookmarkList.CurrentRowSelected := Value;
end;

{ TwrpBasicActionLink }

function TwrpBasicActionLink.Execute: WordBool;
begin
  Result := GetBasicActionLink.Execute;
end;

function TwrpBasicActionLink.Get_Action: IgsBasicAction;
begin
  Result := GetGdcOLEObject(GetBasicActionLink.Action) as IgsBasicAction;
end;

function TwrpBasicActionLink.GetBasicActionLink: TBasicActionLink;
begin
  Result := GetObject as TBasicActionLink;
end;

procedure TwrpBasicActionLink.Set_Action(const Value: IgsBasicAction);
begin
  GetBasicActionLink.Action :=  InterfaceToObject(Value) as TBasicAction;
end;

function TwrpBasicActionLink.Update: WordBool;
begin
  Result := GetBasicActionLink.Update;
end;

{ TwrpIBBase }

procedure TwrpIBBase.CheckDatabase;
begin
  GetIBBase.CheckDatabase;
end;

procedure TwrpIBBase.CheckTransaction;
begin
  GetIBBase.CheckTransaction;
end;

function TwrpIBBase.Get_Owner: IgsObject;
begin
  Result := GetGdcOLEObject(GetIBBase.Owner) as IgsObject;
end;

function TwrpIBBase.Get_Transaction: IgsIBTransaction;
begin
  Result := GetGdcOLEObject(GetIBBase.Transaction) as IgsIBTransaction;
end;

function TwrpIBBase.GetIBBase: TIBBase;
begin
  Result := GetObject as TIBBase;
end;

procedure TwrpIBBase.Set_Transaction(const Value: IgsIBTransaction);
begin
  GetIBBase.Transaction := InterfaceToObject(Value) as TIBTransaction;
end;

{ TwrpTabSheet }

function TwrpTabSheet.Get_Highlighted: WordBool;
begin
  Result := GetTabSheet.Highlighted;
end;

function TwrpTabSheet.Get_ImageIndex: Integer;
begin
  Result := GetTabSheet.ImageIndex;
end;

function TwrpTabSheet.Get_PageControl: IgsPageControl;
begin
  Result := GetGdcOLEObject(GetTabSheet.PageControl) as IgsPageControl;
end;

function TwrpTabSheet.Get_PageIndex: Integer;
begin
  Result := GetTabSheet.PageIndex;
end;

function TwrpTabSheet.Get_TabIndex: Integer;
begin
  Result := GetTabSheet.TabIndex;
end;

function TwrpTabSheet.Get_TabVisible: WordBool;
begin
  Result := GetTabSheet.TabVisible;
end;

function TwrpTabSheet.GetTabSheet: TTabSheet;
begin
  Result := GetObject as TTabSheet;
end;

procedure TwrpTabSheet.Set_Highlighted(Value: WordBool);
begin
  GetTabSheet.Highlighted := Value;
end;

procedure TwrpTabSheet.Set_ImageIndex(Value: Integer);
begin
  GetTabSheet.ImageIndex := Value;
end;

procedure TwrpTabSheet.Set_PageControl(const Value: IgsPageControl);
begin
  GetTabSheet.PageControl := InterfaceToObject(Value) as TPageControl;
end;

procedure TwrpTabSheet.Set_PageIndex(Value: Integer);
begin
  GetTabSheet.PageIndex := Value;
end;

procedure TwrpTabSheet.Set_TabVisible(Value: WordBool);
begin
  GetTabSheet.TabVisible := Value;
end;

{ TwrpStatusPanels }

function TwrpStatusPanels.Add: IgsStatusPanel;
begin
  Result := GetGdcOLEObject(GetStatusPanels.Add) as IgsStatusPanel;
end;

function TwrpStatusPanels.Get_Items(Index: Integer): IgsStatusPanel;
begin
  Result := GetGdcOLEObject(GetStatusPanels.Items[index]) as IgsStatusPanel;
end;

function TwrpStatusPanels.GetStatusPanels: TStatusPanels;
begin
  Result := GetObject as TStatusPanels;
end;

procedure TwrpStatusPanels.Set_Items(Index: Integer;
  const Value: IgsStatusPanel);
begin
  GetStatusPanels.Items[Index] :=  InterfaceToObject(Value) as TStatusPanel;
end;

{ TwrpStatusPanel }

function TwrpStatusPanel.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(GetStatusPanel.Alignment);
end;

function TwrpStatusPanel.Get_Bevel: TgsStatusPanelBevel;
begin
  Result := TgsStatusPanelBevel(GetStatusPanel.Bevel);
end;

function TwrpStatusPanel.Get_BiDiMode: TgsBiDiMode;
begin
  Result := TgsBiDiMode(GetStatusPanel.BiDiMode);
end;

function TwrpStatusPanel.Get_ParentBiDiMode: WordBool;
begin
  Result := GetStatusPanel.ParentBiDiMode;
end;

function TwrpStatusPanel.Get_Style: TgsStatusPanelStyle;
begin
  Result := TgsStatusPanelStyle(GetStatusPanel.Style);
end;

function TwrpStatusPanel.Get_Text: WideString;
begin
  Result := GetStatusPanel.Text;
end;

function TwrpStatusPanel.Get_Width: Integer;
begin
  Result := GetStatusPanel.Width;
end;

function TwrpStatusPanel.GetStatusPanel: TStatusPanel;
begin
  Result := GetObject as TStatusPanel;
end;

procedure TwrpStatusPanel.ParentBiDiModeChanged;
begin
  GetStatusPanel.ParentBiDiModeChanged;
end;

procedure TwrpStatusPanel.Set_Alignment(Value: TgsAlignment);
begin
  GetStatusPanel.Alignment := TAlignment(Value);
end;

procedure TwrpStatusPanel.Set_Bevel(Value: TgsStatusPanelBevel);
begin
  GetStatusPanel.Bevel := TStatusPanelBevel(Value);
end;

procedure TwrpStatusPanel.Set_BiDiMode(Value: TgsBiDiMode);
begin
  GetStatusPanel.BiDiMode := TBiDiMode(Value);
end;

procedure TwrpStatusPanel.Set_ParentBiDiMode(Value: WordBool);
begin
  GetStatusPanel.ParentBiDiMode := Value;
end;

procedure TwrpStatusPanel.Set_Style(Value: TgsStatusPanelStyle);
begin
  GetStatusPanel.Style := TStatusPanelStyle(Value);
end;

procedure TwrpStatusPanel.Set_Text(const Value: WideString);
begin
  GetStatusPanel.Text := Value;
end;

procedure TwrpStatusPanel.Set_Width(Value: Integer);
begin
  GetStatusPanel.Width := Value;
end;

function TwrpStatusPanel.UseRightToLeftAlignment: WordBool;
begin
  Result := GetStatusPanel.UseRightToLeftAlignment;
end;

function TwrpStatusPanel.UseRightToLeftReading: WordBool;
begin
  Result := GetStatusPanel.UseRightToLeftReading;
end;

{ TwrpListView }

function TwrpListView.Get_SmallImages: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetListView.SmallImages) as IgsCustomImageList;
end;

function TwrpListView.Get_StateImages: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetListView.StateImages) as IgsCustomImageList;
end;

function TwrpListView.GetListView: TListView;
begin
  Result := GetObject as TListView;
end;

procedure TwrpListView.Set_SmallImages(const Value: IgsCustomImageList);
begin
  GetListView.SmallImages := InterfaceToObject(Value) as TCustomImageList;
end;

procedure TwrpListView.Set_StateImages(const Value: IgsCustomImageList);
begin
  GetListView.StateImages := InterfaceToObject(Value) as TCustomImageList;
end;

{ TwrpListColumn }

function TwrpListColumn.Get_AutoSize: WordBool;
begin
  Result := GetListColumn.AutoSize;
end;

function TwrpListColumn.Get_Caption: WideString;
begin
  Result := GetListColumn.Caption;
end;

function TwrpListColumn.Get_ImageIndex: Integer;
begin
  Result := GetListColumn.ImageIndex;
end;

function TwrpListColumn.Get_MaxWidth: Integer;
begin
  Result := GetListColumn.MaxWidth;
end;

function TwrpListColumn.Get_MinWidth: Integer;
begin
  Result := GetListColumn.MinWidth;
end;

function TwrpListColumn.Get_Tag: Integer;
begin
  Result := GetListColumn.Tag;
end;

function TwrpListColumn.Get_Width: Integer;
begin
  Result := GetListColumn.Width;
end;

function TwrpListColumn.Get_WidthType: Integer;
begin
  Result := GetListColumn.WidthType;
end;

function TwrpListColumn.GetListColumn: TListColumn;
begin
  Result := GetObject as TListColumn;
end;

procedure TwrpListColumn.Set_AutoSize(Value: WordBool);
begin
  GetListColumn.AutoSize := Value;
end;

procedure TwrpListColumn.Set_Caption(const Value: WideString);
begin
  GetListColumn.Caption := Value;
end;

procedure TwrpListColumn.Set_ImageIndex(Value: Integer);
begin
  GetListColumn.ImageIndex := Value;
end;

procedure TwrpListColumn.Set_MaxWidth(Value: Integer);
begin
  GetListColumn.MaxWidth := Value;
end;

procedure TwrpListColumn.Set_MinWidth(Value: Integer);
begin
  GetListColumn.MinWidth := Value;
end;

procedure TwrpListColumn.Set_Tag(Value: Integer);
begin
  GetListColumn.Tag := Value;
end;

procedure TwrpListColumn.Set_Width(Value: Integer);
begin
  GetListColumn.Width := Value;
end;

{ TwrpListItem }

procedure TwrpListItem.CancelEdit;
begin
  GetListItem.CancelEdit;
end;

procedure TwrpListItem.Delete;
begin
  GetListItem.Delete;
end;

function TwrpListItem.EditCaption: WordBool;
begin
  Result := GetListItem.EditCaption;
end;

function TwrpListItem.Get_Caption: WideString;
begin
  Result := GetListItem.Caption;
end;

function TwrpListItem.Get_Cut: WordBool;
begin
  Result := GetListItem.Cut;
end;

function TwrpListItem.Get_DropTarget: WordBool;
begin
  Result := GetListItem.DropTarget;
end;

function TwrpListItem.Get_Focused: WordBool;
begin
  Result := GetListItem.Focused;
end;

function TwrpListItem.Get_Handle: LongWord;
begin
  Result := GetListItem.Handle;
end;

function TwrpListItem.Get_ImageIndex: Integer;
begin
  Result := GetListItem.ImageIndex;
end;

function TwrpListItem.Get_Indent: Integer;
begin
  Result := GetListItem.Indent;
end;

function TwrpListItem.Get_Index: Integer;
begin
  Result := GetListItem.Index;
end;

function TwrpListItem.Get_Left: Integer;
begin
  Result := GetListItem.Left;
end;

function TwrpListItem.Get_ListView: IgsCustomListView;
begin
  Result := GetGdcOLEObject(GetListItem.ListView) as IgsCustomListView;
end;

function TwrpListItem.Get_Owner: IgsListItems;
begin
  Result := GetGdcOLEObject(GetListItem.Owner) as IgsListItems;
end;

function TwrpListItem.Get_Selected: WordBool;
begin
  Result := GetListItem.Selected;
end;

function TwrpListItem.Get_StateIndex: Integer;
begin
  Result := GetListItem.StateIndex;
end;

function TwrpListItem.Get_SubItemImages(Index: Integer): Integer;
begin
  Result := GetListItem.SubItemImages[Index];
end;

function TwrpListItem.Get_SubItems: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetListItem.SubItems);
end;

function TwrpListItem.Get_Top: Integer;
begin
  Result := GetListItem.Top;
end;

function TwrpListItem.GetListItem: TListItem;
begin
  Result := GetObject as TListItem;
end;

procedure TwrpListItem.MakeVisible(PartialOK: WordBool);
begin
  GetListItem.MakeVisible(PartialOK);
end;

procedure TwrpListItem.Set_Caption(const Value: WideString);
begin
  GetListItem.Caption := Value;
end;

procedure TwrpListItem.Set_Cut(Value: WordBool);
begin
  GetListItem.Cut := Value;
end;

procedure TwrpListItem.Set_DropTarget(Value: WordBool);
begin
  GetListItem.DropTarget := Value;
end;

procedure TwrpListItem.Set_Focused(Value: WordBool);
begin
  GetListItem.Focused := Value;
end;

procedure TwrpListItem.Set_ImageIndex(Value: Integer);
begin
  GetListItem.ImageIndex := Value;
end;

procedure TwrpListItem.Set_Indent(Value: Integer);
begin
  GetListItem.Indent := Value;
end;

procedure TwrpListItem.Set_Left(Value: Integer);
begin
  GetListItem.Left := Value;
end;

procedure TwrpListItem.Set_Selected(Value: WordBool);
begin
  GetListItem.Selected := Value;
end;

procedure TwrpListItem.Set_StateIndex(Value: Integer);
begin
  GetListItem.StateIndex := Value;
end;

procedure TwrpListItem.Set_SubItemImages(Index, Value: Integer);
begin
  GetListItem.SubItemImages[Index] := Value;
end;

procedure TwrpListItem.Set_SubItems(const Value: IgsStrings);
begin
  GetListItem.SubItems := IgsStringsToTStrings(Value);
end;

procedure TwrpListItem.Set_Top(Value: Integer);
begin
  GetListItem.Top := Value;
end;

procedure TwrpListItem.Update;
begin
  GetListItem.Update;
end;

function TwrpListItem.WorkArea: Integer;
begin
  Result := GetListItem.WorkArea;
end;

function TwrpListItem.Get_Data: Integer;
begin
  Result := Integer(GetListItem.Data);
end;

procedure TwrpListItem.Set_Data(Value: Integer);
begin
  GetListItem.Data := Pointer(Value);
end;

{ TwrpListItems }

function TwrpListItems.Add: IgsListItem;
begin
  Result := GetGdcOLEObject(GetListItems.Add) as IgsListItem;
end;

procedure TwrpListItems.BeginUpdate;
begin
  GetListItems.BeginUpdate;
end;

procedure TwrpListItems.Clear;
begin
  GetListItems.Clear;
end;

procedure TwrpListItems.Delete(Index: Integer);
begin
  GetListItems.Delete(Index);
end;

procedure TwrpListItems.EndUpdate;
begin
  GetListItems.EndUpdate;
end;

function TwrpListItems.Get_Count: Integer;
begin
  Result := GetListItems.Count;
end;

function TwrpListItems.Get_Handle: LongWord;
begin
  Result := GetListItems.Handle;
end;

function TwrpListItems.Get_Item(Index: Integer): IgsListItem;
begin
  Result := GetGdcOLEObject(GetListItems.Item[Index]) as  IgsListItem;
end;

function TwrpListItems.Get_Owner: IgsCustomListView;
begin
  Result := GetGdcOLEObject(GetListItems.Owner) as IgsCustomListView;
end;

function TwrpListItems.GetListItems: TListItems;
begin
  Result := GetObject as TListItems;
end;

function TwrpListItems.IndexOf(const Value: IgsListItem): Integer;
begin
  Result := GetListItems.IndexOf(InterfaceToObject(Value) as TListItem);
end;

function TwrpListItems.Insert(Index: Integer): IgsListItem;
begin
  Result := GetGdcOLEObject(GetListItems.Insert(Index)) as IgsListItem;
end;

procedure TwrpListItems.Set_Count(Value: Integer);
begin
  GetListItems.Count := Value;
end;

procedure TwrpListItems.Set_Item(Index: Integer; const Value: IgsListItem);
begin
  GetListItems.Item[Index] := InterfaceToObject(Value) as TListItem;
end;

{ TwrpIBGeneratorField }

procedure TwrpIBGeneratorField.Apply;
begin
  GetIBGeneratorField.Apply;
end;

function TwrpIBGeneratorField.Get_ApplyEvent: TgsIBGeneratorApplyEvent;
begin
  Result := TgsIBGeneratorApplyEvent(GetIBGeneratorField.ApplyEvent);
end;

function TwrpIBGeneratorField.Get_Field: WideString;
begin
  Result := GetIBGeneratorField.Field;
end;

function TwrpIBGeneratorField.Get_Generator: WideString;
begin
  Result := GetIBGeneratorField.Generator;
end;

function TwrpIBGeneratorField.Get_IncrementBy: Integer;
begin
  Result := GetIBGeneratorField.IncrementBy;
end;

function TwrpIBGeneratorField.GetIBGeneratorField: TIBGeneratorField;
begin
  Result := GetObject as TIBGeneratorField;
end;

procedure TwrpIBGeneratorField.Set_ApplyEvent(
  Value: TgsIBGeneratorApplyEvent);
begin
  GetIBGeneratorField.ApplyEvent := TIBGeneratorApplyEvent(Value);
end;

procedure TwrpIBGeneratorField.Set_Field(const Value: WideString);
begin
  GetIBGeneratorField.Field := Value;
end;

procedure TwrpIBGeneratorField.Set_Generator(const Value: WideString);
begin
  GetIBGeneratorField.Generator := Value;
end;

procedure TwrpIBGeneratorField.Set_IncrementBy(Value: Integer);
begin
  GetIBGeneratorField.IncrementBy := Value;
end;

function TwrpIBGeneratorField.ValueName: WideString;
begin
  Result := GetIBGeneratorField.ValueName;
end;

{ TwrpIBBatch }

function TwrpIBBatch.Get_Columns: IgsIBXSQLDA;
begin
  Result := GetGdcOLEObject(GetIBBatch.Columns) as IgsIBXSQLDA;
end;

function TwrpIBBatch.Get_FileName: WideString;
begin
  Result := GetIBBatch.Filename;
end;

function TwrpIBBatch.Get_Params: IgsIBXSQLDA;
begin
  Result := GetGdcOLEObject(GetIBBatch.Params) as IgsIBXSQLDA;
end;

function TwrpIBBatch.GetIBBatch: TIBBatch;
begin
  Result := GetObject as TIBBatch;
end;

procedure TwrpIBBatch.ReadyFile;
begin
  GetIBBatch.ReadyFile;
end;

procedure TwrpIBBatch.Set_Columns(const Value: IgsIBXSQLDA);
begin
  GetIBBatch.Columns := InterfaceToObject(Value) as TIBXSQLDA;
end;

procedure TwrpIBBatch.Set_FileName(const Value: WideString);
begin
  GetIBBatch.Filename := Value;
end;

procedure TwrpIBBatch.Set_Params(const Value: IgsIBXSQLDA);
begin
  GetIBBatch.Params := InterfaceToObject(Value) as TIBXSQLDA;
end;

{ TwrpIBBatchInput }

function TwrpIBBatchInput.GetIBBatchInput: TIBBatchInput;
begin
  Result := GetObject as TIBBatchInput;
end;

function TwrpIBBatchInput.ReadParameters: WordBool;
begin
  Result := GetIBBatchInput.ReadParameters;
end;

{ TwrpIBBatchOutput }

function TwrpIBBatchOutput.GetIBBatchOutput: TIBBatchOutput;
begin
  Result := GetObject as TIBBatchOutput;
end;

function TwrpIBBatchOutput.WriteColumns: WordBool;
begin
  Result := GetIBBatchOutput.WriteColumns;
end;

{ TwrpPen }

function TwrpPen.Get_Color: Integer;
begin
  Result := GetPen.Color;
end;

function TwrpPen.Get_Handle: LongWord;
begin
  Result := GetPen.Handle;
end;

function TwrpPen.Get_Mode: TgsPenMode;
begin
  Result := TgsPenMode(GetPen.Mode);
end;

function TwrpPen.Get_Style: TgsPenStyle;
begin
  Result := TgsPenStyle(GetPen.Style);
end;

function TwrpPen.Get_Width: Integer;
begin
  Result := GetPen.Width;
end;

function TwrpPen.GetPen: TPen;
begin
  Result := GetObject as TPen;
end;

procedure TwrpPen.Set_Color(Value: Integer);
begin
  GetPen.Color := Value;
end;

procedure TwrpPen.Set_Handle(Value: LongWord);
begin
  GetPen.Handle := Value;
end;

procedure TwrpPen.Set_Mode(Value: TgsPenMode);
begin
  GetPen.Mode := TPenMode(Value);
end;

procedure TwrpPen.Set_Style(Value: TgsPenStyle);
begin
  GetPen.Style := TPenStyle(Value);
end;

procedure TwrpPen.Set_Width(Value: Integer);
begin
  GetPen.Width := Value;
end;

class function TwrpPen.CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Result := TPen.Create;
end;

{ TwrpTextAttributes }

function TwrpTextAttributes.Get_Charset: Word;
begin
  Result := GetTextAttributes.Charset;
end;

function TwrpTextAttributes.Get_Color: Integer;
begin
  Result := GetTextAttributes.Color;
end;

function TwrpTextAttributes.Get_Height: Integer;
begin
  Result := GetTextAttributes.Height;
end;

function TwrpTextAttributes.Get_Name: WideString;
begin
  Result := GetTextAttributes.Name;
end;

function TwrpTextAttributes.Get_Pitch: TgsFontPitch;
begin
  Result := TgsFontPitch(GetTextAttributes.Pitch);
end;

function TwrpTextAttributes.Get_Protected_: WordBool;
begin
  Result := GetTextAttributes.Protected;
end;

function TwrpTextAttributes.Get_Size: Integer;
begin
  Result := GetTextAttributes.Size;
end;

function TwrpTextAttributes.GetTextAttributes: TTextAttributes;
begin
  Result := GetObject as TTextAttributes;
end;

procedure TwrpTextAttributes.Set_Charset(Value: Word);
begin
  GetTextAttributes.Charset := Value;
end;

procedure TwrpTextAttributes.Set_Color(Value: Integer);
begin
  GetTextAttributes.Color := Value;
end;

procedure TwrpTextAttributes.Set_Height(Value: Integer);
begin
  GetTextAttributes.Height := Value;
end;

procedure TwrpTextAttributes.Set_Name(const Value: WideString);
begin
  GetTextAttributes.Name := Value;
end;

procedure TwrpTextAttributes.Set_Pitch(Value: TgsFontPitch);
begin
  GetTextAttributes.Pitch := TFontPitch(Value);
end;

procedure TwrpTextAttributes.Set_Protected_(Value: WordBool);
begin
  GetTextAttributes.Protected := Value;
end;

procedure TwrpTextAttributes.Set_Size(Value: Integer);
begin
  GetTextAttributes.Size := Value;
end;

function TwrpTextAttributes.Get_Style: WideString;
begin
  Result := ' ';
  if fsBold in GetTextAttributes.Style then
    Result := Result + 'fsBold ';
  if fsItalic in GetTextAttributes.Style then
    Result := Result + 'fsItalic ';
  if fsUnderline in GetTextAttributes.Style then
    Result := Result + 'fsUnderline ';
  if fsStrikeOut in GetTextAttributes.Style then
    Result := Result + 'fsStrikeOut ';
end;

procedure TwrpTextAttributes.Set_Style(const Value: WideString);
var
  LFontStyle: TFontStyles;
begin
  LFontStyle := [];
  if Pos('FSBOLD', AnsiUpperCase(Value)) > 0 then
    Include(LFontStyle, FSBOLD);
  if Pos('FSITALIC', AnsiUpperCase(Value)) > 0 then
    Include(LFontStyle, FSITALIC);
  if Pos('FSUNDERLINE', AnsiUpperCase(Value)) > 0 then
    Include(LFontStyle, FSUNDERLINE);
  if Pos('FSSTRIKEOUT', AnsiUpperCase(Value)) > 0 then
    Include(LFontStyle, FSSTRIKEOUT);
  GetTextAttributes.Style := LFontStyle
end;

{ TwrpParaAttributes }

function TwrpParaAttributes.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(GetParaAttributes.Alignment);
end;

function TwrpParaAttributes.Get_FirstIndent: Integer;
begin
  Result := GetParaAttributes.FirstIndent;
end;

function TwrpParaAttributes.Get_LeftIndent: Integer;
begin
  Result := GetParaAttributes.LeftIndent;
end;

function TwrpParaAttributes.Get_Numbering: TgsNumberingStyle;
begin
  Result := TgsNumberingStyle(GetParaAttributes.Numbering);
end;

function TwrpParaAttributes.Get_RightIndent: Integer;
begin
  Result := GetParaAttributes.RightIndent;
end;

function TwrpParaAttributes.Get_Tab(Index: Integer): Integer;
begin
  Result := GetParaAttributes.Tab[Index];
end;

function TwrpParaAttributes.Get_TabCount: Integer;
begin
  Result := GetParaAttributes.TabCount;
end;

function TwrpParaAttributes.GetParaAttributes: TParaAttributes;
begin
  Result := GetObject as TParaAttributes;
end;

procedure TwrpParaAttributes.Set_Alignment(Value: TgsAlignment);
begin
  GetParaAttributes.Alignment := TAlignment(Value);
end;

procedure TwrpParaAttributes.Set_FirstIndent(Value: Integer);
begin
  GetParaAttributes.FirstIndent := Value;
end;

procedure TwrpParaAttributes.Set_LeftIndent(Value: Integer);
begin
  GetParaAttributes.LeftIndent := Value;
end;

procedure TwrpParaAttributes.Set_Numbering(Value: TgsNumberingStyle);
begin
  GetParaAttributes.Numbering := TNumberingStyle(Value);
end;

procedure TwrpParaAttributes.Set_RightIndent(Value: Integer);
begin
  GetParaAttributes.RightIndent := Value;
end;

procedure TwrpParaAttributes.Set_Tab(Index, Value: Integer);
begin
  GetParaAttributes.Tab[Index] := Value;
end;

procedure TwrpParaAttributes.Set_TabCount(Value: Integer);
begin
  GetParaAttributes.TabCount := Value;
end;

{ TwrpCheckConstraint }

function TwrpCheckConstraint.Get_CustomConstraint: WideString;
begin
  Result := GetCheckConstraint.CustomConstraint;
end;

function TwrpCheckConstraint.Get_ErrorMessage: WideString;
begin
  Result := GetCheckConstraint.ErrorMessage;
end;

function TwrpCheckConstraint.Get_FromDictionary: WordBool;
begin
  Result := GetCheckConstraint.FromDictionary;
end;

function TwrpCheckConstraint.Get_ImportedConstraint: WideString;
begin
  Result := GetCheckConstraint.ImportedConstraint;
end;

function TwrpCheckConstraint.GetCheckConstraint: TCheckConstraint;
begin
  Result := GetObject as TCheckConstraint;
end;

function TwrpCheckConstraint.GetDisplayName: WideString;
begin
  Result := GetCheckConstraint.DisplayName;
end;

procedure TwrpCheckConstraint.Set_CustomConstraint(
  const Value: WideString);
begin
  GetCheckConstraint.CustomConstraint := Value;
end;

procedure TwrpCheckConstraint.Set_ErrorMessage(const Value: WideString);
begin
  GetCheckConstraint.ErrorMessage := Value;
end;

procedure TwrpCheckConstraint.Set_FromDictionary(Value: WordBool);
begin
  GetCheckConstraint.FromDictionary := Value;
end;

procedure TwrpCheckConstraint.Set_ImportedConstraint(
  const Value: WideString);
begin
  GetCheckConstraint.ImportedConstraint := Value;
end;

{ TwrpCheckConstraints }

function TwrpCheckConstraints.Add: IgsCheckConstraint;
begin
  Result := GetGdcOLEObject(GetCheckConstraints.Add) as IgsCheckConstraint;
end;

function TwrpCheckConstraints.Get_Items(
  Index: Integer): IgsCheckConstraint;
begin
  Result := GetGdcOLEObject(GetCheckConstraints.Items[Index]) as IgsCheckConstraint;
end;

function TwrpCheckConstraints.GetCheckConstraints: TCheckConstraints;
begin
  Result := GetObject as TCheckConstraints;
end;

procedure TwrpCheckConstraints.Set_Items(Index: Integer;
  const Value: IgsCheckConstraint);
begin
  GetCheckConstraints.Items[Index] := InterfaceToObject(Value) as TCheckConstraint;
end;

{ TwrpParams }

procedure TwrpParams.AddParam(const Value: IgsParam);
begin
  GetParams.AddParam(InterfaceToObject(Value) as TParam) ;
end;

procedure TwrpParams.AssignValues(const Value: IgsParams);
begin
  GetParams.AssignValues(InterfaceToObject(Value) as TParams) ;
end;

function TwrpParams.CreateParam(FldType: TgsFieldType;
  const ParamName: WideString; ParamType: TgsParamType): IgsParam;
begin
  Result := GetGdcOLEObject(GetParams.CreateParam(TFieldType(FldType),
    ParamName, TParamType(ParamType))) as  IgsParam;
end;

function TwrpParams.FindParam(const Value: WideString): IgsParam;
begin
  Result := GetGdcOLEObject(GetParams.FindParam(Value)) as IgsParam;
end;

function TwrpParams.Get_Items(Index: Integer): IgsParam;
begin
  Result := GetGdcOLEObject(GetParams.Items[Index]) as IgsParam;
end;

function TwrpParams.Get_ParamValues(
  const ParamName: WideString): OleVariant;
begin
  Result := GetParams.ParamValues[ParamName];
end;

procedure TwrpParams.GetParamList(const List: IgsList;
  const ParamNames: WideString);
begin
  GetParams.GetParamList(InterfaceToObject(List) as TList, ParamNames);
end;

function TwrpParams.GetParams: TParams;
begin
  Result := GetObject as TParams;
end;

function TwrpParams.IsEqual(const Value: IgsParams): WordBool;
begin
  Result := GetParams.IsEqual(InterfaceToObject(Value) as TParams);
end;

function TwrpParams.ParamByName(const Value: WideString): IgsParam;
begin
  Result := GetGdcOLEObject(GetParams.ParamByName(Value)) as IgsParam;
end;

function TwrpParams.ParseSQL(const SQL: WideString;
  DoCreate: WordBool): WideString;
begin
  Result := GetParams.ParseSQL(SQL, DoCreate);
end;

procedure TwrpParams.RemoveParam(const Value: IgsParam);
begin
  GetParams.RemoveParam(InterfaceToObject(Value) as TParam);
end;

procedure TwrpParams.Set_Items(Index: Integer; const Value: IgsParam);
begin
  GetParams.Items[Index] := InterfaceToObject(Value) as TParam;
end;

procedure TwrpParams.Set_ParamValues(const ParamName: WideString;
  Value: OleVariant);
begin
  GetParams.ParamValues[ParamName] := Value;
end;

{ TwrpIndexDefs }

function TwrpIndexDefs.AddIndexDef: IgsIndexDef;
begin
  Result := GetGdcOLEObject(GetIndexDefs.AddIndexDef) as IgsIndexDef;
end;

function TwrpIndexDefs.Find_(const Name: WideString): IgsIndexDef;
begin
  Result := GetGdcOLEObject(GetIndexDefs.Find(Name)) as IgsIndexDef;
end;

function TwrpIndexDefs.FindIndexForFields(
  const Fields: WideString): IgsIndexDef;
begin
  Result := GetGdcOLEObject(GetIndexDefs.FindIndexForFields(Fields)) as IgsIndexDef;
end;

function TwrpIndexDefs.Get_Items_(Index: Integer): IgsIndexDef;
begin
  Result := GetGdcOLEObject(GetIndexDefs.Items[index]) as IgsIndexDef;
end;

function TwrpIndexDefs.GetIndexDefs: TIndexDefs;
begin
  Result := GetObject as TIndexDefs;
end;

function TwrpIndexDefs.GetIndexForFields(const Fields: WideString;
  CaseInsensitive: WordBool): IgsIndexDef;
begin
  Result := GetGdcOLEObject(GetIndexDefs.GetIndexForFields(Fields, CaseInsensitive)) as IgsIndexDef;
end;

procedure TwrpIndexDefs.Set_Items_(Index: Integer;
  const Value: IgsIndexDef);
begin
  GetIndexDefs.Items[Index] := InterfaceToObject(Value) as TIndexDef;
end;

procedure TwrpIndexDefs.Update;
begin
  GetIndexDefs.Update;
end;

{ TwrpIndexDef }

function TwrpIndexDef.Get_CaseInsFields: WideString;
begin
  Result := GetIndexDef.CaseInsFields;
end;

function TwrpIndexDef.Get_DescFields: WideString;
begin
  Result := GetIndexDef.DescFields;
end;

function TwrpIndexDef.Get_Expression: WideString;
begin
  Result := GetIndexDef.Expression;
end;

function TwrpIndexDef.Get_FieldExpression: WideString;
begin
  Result := GetIndexDef.FieldExpression;
end;

function TwrpIndexDef.Get_Fields: WideString;
begin
  Result := GetIndexDef.Fields;
end;

function TwrpIndexDef.Get_GroupingLevel: Integer;
begin
  Result := GetIndexDef.GroupingLevel;
end;

function TwrpIndexDef.Get_Source: WideString;
begin
  Result := GetIndexDef.Source;
end;

function TwrpIndexDef.GetIndexDef: TIndexDef;
begin
  Result := GetObject as TIndexDef;
end;

procedure TwrpIndexDef.Set_CaseInsFields(const Value: WideString);
begin
  GetIndexDef.CaseInsFields := Value;
end;

procedure TwrpIndexDef.Set_DescFields(const Value: WideString);
begin
  GetIndexDef.DescFields := Value;
end;

procedure TwrpIndexDef.Set_Expression(const Value: WideString);
begin
  GetIndexDef.Expression := Value;
end;

procedure TwrpIndexDef.Set_Fields(const Value: WideString);
begin
  GetIndexDef.Fields := Value;
end;

procedure TwrpIndexDef.Set_GroupingLevel(Value: Integer);
begin
  GetIndexDef.GroupingLevel := Value;
end;

procedure TwrpIndexDef.Set_Source(const Value: WideString);
begin
  GetIndexDef.Source := Value;
end;

{ TwrpIcon }

function TwrpIcon.Get_Handle: LongWord;
begin
  Result := GetIcon.Handle;
end;

function TwrpIcon.GetIcon: TIcon;
begin
  Result := GetObject as TIcon;
end;

function TwrpIcon.ReleaseHandle: LongWord;
begin
  Result := GetIcon.ReleaseHandle;
end;

procedure TwrpIcon.Set_Handle(Value: LongWord);
begin
  GetIcon.Handle := Value;
end;

{ TwrpChangeLink }

procedure TwrpChangeLink.Change;
begin
  GetChangeLink.Change;
end;

function TwrpChangeLink.Get_Sender: IgsCustomImageList;
begin
  Result := GetGdcOLEObject(GetChangeLink.Sender) as IgsCustomImageList;
end;

function TwrpChangeLink.GetChangeLink: TChangeLink;
begin
  Result := GetObject as TChangeLink;
end;

procedure TwrpChangeLink.Set_Sender(const Value: IgsCustomImageList);
begin
  GetChangeLink.Sender := InterfaceToObject(Value) as TCustomImageList;
end;

{ TwrpHeaderSections }

function TwrpHeaderSections.Add: IgsHeaderSection;
begin
  Result := GetGdcOLEObject(GetHeaderSections.Add) as IgsHeaderSection;
end;

function TwrpHeaderSections.Get_Items(Index: Integer): IgsHeaderSection;
begin
  Result := GetGdcOLEObject(GetHeaderSections.Items[index]) as IgsHeaderSection;
end;

function TwrpHeaderSections.GetHeaderSections: THeaderSections;
begin
  Result := GetObject as THeaderSections;
end;

procedure TwrpHeaderSections.Set_Items(Index: Integer;
  const Value: IgsHeaderSection);
begin
  GetHeaderSections.Items[Index] := InterfaceToObject(Value) as THeaderSection;
end;

{ TwrpHeaderSection }

function TwrpHeaderSection.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(GetHeaderSection.Alignment);
end;

function TwrpHeaderSection.Get_AllowClick: WordBool;
begin
  Result := GetHeaderSection.AllowClick;
end;

function TwrpHeaderSection.Get_AutoSize: WordBool;
begin
  Result := GetHeaderSection.AutoSize;
end;

function TwrpHeaderSection.Get_BiDiMode: TgsBiDiMode;
begin
  Result := TgsBiDiMode(GetHeaderSection.BiDiMode);
end;

function TwrpHeaderSection.Get_ImageIndex: Integer;
begin
  Result := GetHeaderSection.ImageIndex;
end;

function TwrpHeaderSection.Get_Left: Integer;
begin
  Result := GetHeaderSection.Left;
end;

function TwrpHeaderSection.Get_MaxWidth: Integer;
begin
  Result := GetHeaderSection.MaxWidth;
end;

function TwrpHeaderSection.Get_MinWidth: Integer;
begin
  Result := GetHeaderSection.MinWidth;
end;

function TwrpHeaderSection.Get_ParentBiDiMode: WordBool;
begin
  Result := GetHeaderSection.ParentBiDiMode;
end;

function TwrpHeaderSection.Get_Right: Integer;
begin
  Result := GetHeaderSection.Right;
end;

function TwrpHeaderSection.Get_Style: TgsHeaderSectionStyle;
begin
  Result := TgsHeaderSectionStyle(GetHeaderSection.Style);
end;

function TwrpHeaderSection.Get_Text: WideString;
begin
  Result := GetHeaderSection.Text;
end;

function TwrpHeaderSection.Get_Width: Integer;
begin
  Result := GetHeaderSection.Width;
end;

function TwrpHeaderSection.GetHeaderSection: THeaderSection;
begin
  Result := GetObject as THeaderSection;
end;

procedure TwrpHeaderSection.ParentBiDiModeChanged;
begin
  GetHeaderSection.ParentBiDiModeChanged;
end;

procedure TwrpHeaderSection.Set_Alignment(Value: TgsAlignment);
begin
  GetHeaderSection.Alignment := TAlignment(Value);
end;

procedure TwrpHeaderSection.Set_AllowClick(Value: WordBool);
begin
  GetHeaderSection.AllowClick := Value;
end;

procedure TwrpHeaderSection.Set_AutoSize(Value: WordBool);
begin
  GetHeaderSection.AutoSize := Value;
end;

procedure TwrpHeaderSection.Set_BiDiMode(Value: TgsBiDiMode);
begin
  GetHeaderSection.BiDiMode := TBiDiMode(Value);
end;

procedure TwrpHeaderSection.Set_ImageIndex(Value: Integer);
begin
  GetHeaderSection.ImageIndex := Value;
end;

procedure TwrpHeaderSection.Set_MaxWidth(Value: Integer);
begin
  GetHeaderSection.MaxWidth := Value;
end;

procedure TwrpHeaderSection.Set_MinWidth(Value: Integer);
begin
  GetHeaderSection.MinWidth := Value;
end;

procedure TwrpHeaderSection.Set_ParentBiDiMode(Value: WordBool);
begin
  GetHeaderSection.ParentBiDiMode := Value;
end;

procedure TwrpHeaderSection.Set_Style(Value: TgsHeaderSectionStyle);
begin
  GetHeaderSection.Style := THeaderSectionStyle(Value);
end;

procedure TwrpHeaderSection.Set_Text(const Value: WideString);
begin
  GetHeaderSection.Text := Value;
end;

procedure TwrpHeaderSection.Set_Width(Value: Integer);
begin
  GetHeaderSection.Width := Value;
end;

function TwrpHeaderSection.UseRightToLeftAlignment: WordBool;
begin
  Result := GetHeaderSection.UseRightToLeftAlignment;
end;

function TwrpHeaderSection.UseRightToLeftReading: WordBool;
begin
  Result := GetHeaderSection.UseRightToLeftReading;
end;

{ TwrpOutlineNode }

procedure TwrpOutlineNode.ChangeLevelBy(Value: Integer);
begin
  GetOutlineNode.ChangeLevelBy(Value);
end;

procedure TwrpOutlineNode.Collapse;
begin
  GetOutlineNode.Collapse;
end;

procedure TwrpOutlineNode.Expand;
begin
  GetOutlineNode.Expand;
end;

procedure TwrpOutlineNode.FullExpand;
begin
  GetOutlineNode.FullExpand;
end;

function TwrpOutlineNode.Get_Expanded: WordBool;
begin
  Result := GetOutlineNode.Expanded;
end;

function TwrpOutlineNode.Get_FullPath: WideString;
begin
  Result := GetOutlineNode.FullPath;
end;

function TwrpOutlineNode.Get_HasItems: WordBool;
begin
  Result := GetOutlineNode.HasItems;
end;

function TwrpOutlineNode.Get_Index: Integer;
begin
  Result := GetOutlineNode.Index;
end;

function TwrpOutlineNode.Get_IsVisible: WordBool;
begin
  Result := GetOutlineNode.IsVisible;
end;

function TwrpOutlineNode.Get_Level: LongWord;
begin
  Result := GetOutlineNode.Level;
end;

function TwrpOutlineNode.Get_Parent: IgsOutlineNode;
begin
  Result := GetGdcOLEObject(GetOutlineNode.Parent) as IgsOutlineNode;
end;

function TwrpOutlineNode.Get_Text: WideString;
begin
  Result := GetOutlineNode.Text;
end;

function TwrpOutlineNode.Get_TopItem: Integer;
begin
  Result := GetOutlineNode.TopItem;
end;

function TwrpOutlineNode.GetDisplayWidth: Integer;
begin
  Result := GetOutlineNode.GetDisplayWidth;
end;

function TwrpOutlineNode.GetFirstChild: Integer;
begin
  Result := GetOutlineNode.getFirstChild;
end;

function TwrpOutlineNode.GetLastChild: Integer;
begin
  Result := GetOutlineNode.GetLastChild;
end;

function TwrpOutlineNode.GetNextChild(Value: Integer): Integer;
begin
  Result := GetOutlineNode.GetNextChild(Value);
end;

function TwrpOutlineNode.GetOutlineNode: TOutlineNode;
begin
  Result := GetObject as TOutlineNode;
end;

function TwrpOutlineNode.GetPrevChild(Value: Integer): Integer;
begin
  Result := GetOutlineNode.GetPrevChild(Value);
end;

procedure TwrpOutlineNode.MoveTo(Destination: Integer;
  AttachMode: TgsAttachMode);
begin
  GetOutlineNode.MoveTo(Destination, TAttachMode(AttachMode));
end;

procedure TwrpOutlineNode.Set_Expanded(Value: WordBool);
begin
  GetOutlineNode.Expanded := Value;
end;

procedure TwrpOutlineNode.Set_Level(Value: LongWord);
begin
  GetOutlineNode.Level := Value;
end;

procedure TwrpOutlineNode.Set_Text(const Value: WideString);
begin
  GetOutlineNode.Text := Value;
end;

{ TwrpOutline }

function TwrpOutline.Get_PictureClosed: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetOutline.PictureClosed) as IgsBitmap;
end;

function TwrpOutline.Get_PictureLeaf: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetOutline.PictureLeaf) as IgsBitmap;
end;

function TwrpOutline.Get_PictureMinus: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetOutline.PictureMinus) as IgsBitmap;
end;

function TwrpOutline.Get_PictureOpen: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetOutline.PictureOpen) as IgsBitmap;
end;

function TwrpOutline.Get_PicturePlus: IgsBitmap;
begin
  Result := GetGdcOLEObject(GetOutline.PicturePlus) as IgsBitmap;
end;

function TwrpOutline.GetOutline: TOutline;
begin
  Result := GetObject as TOutline;
end;

procedure TwrpOutline.Set_PictureClosed(const Value: IgsBitmap);
begin
  GetOutline.PictureClosed := InterfaceToObject(Value) as TBitmap;
end;

procedure TwrpOutline.Set_PictureLeaf(const Value: IgsBitmap);
begin
  GetOutline.PictureLeaf := InterfaceToObject(Value) as TBitmap;
end;

procedure TwrpOutline.Set_PictureMinus(const Value: IgsBitmap);
begin
  GetOutline.PictureMinus := InterfaceToObject(Value) as TBitmap;
end;

procedure TwrpOutline.Set_PictureOpen(const Value: IgsBitmap);
begin
  GetOutline.PictureOpen := InterfaceToObject(Value) as TBitmap;
end;

procedure TwrpOutline.Set_PicturePlus(const Value: IgsBitmap);
begin
  GetOutline.PicturePlus := InterfaceToObject(Value) as TBitmap;
end;

{ TwrpToolButton }

function TwrpToolButton.CheckMenuDropdown: WordBool;
begin
  Result := GetToolButton.CheckMenuDropdown;
end;

procedure TwrpToolButton.Click;
begin
  GetToolButton.Click;
end;

function TwrpToolButton.Get_AllowAllUp: WordBool;
begin
  Result := GetToolButton.AllowAllUp;
end;

function TwrpToolButton.Get_Down: WordBool;
begin
  Result := GetToolButton.Down;
end;

function TwrpToolButton.Get_DropdownMenu: IgsPopupMenu;
begin
  Result := getGdcOLEObject(GetToolButton.DropdownMenu) as IgsPopupMenu;
end;

function TwrpToolButton.Get_Grouped: WordBool;
begin
  Result := GetToolButton.Grouped;
end;

function TwrpToolButton.Get_ImageIndex: Integer;
begin
  Result := GetToolButton.ImageIndex;
end;

function TwrpToolButton.Get_Indeterminate: WordBool;
begin
  Result := GetToolButton.Indeterminate;
end;

function TwrpToolButton.Get_Index: Integer;
begin
  Result := GetToolButton.Index;
end;

function TwrpToolButton.Get_Marked: WordBool;
begin
  Result := GetToolButton.Marked;
end;

function TwrpToolButton.Get_MenuItem: IgsMenuItem;
begin
  Result := GetGdcOLEObject(GetToolButton.MenuItem) as IgsMenuItem;
end;

function TwrpToolButton.Get_Style: TgsToolButtonStyle;
begin
  Result := TgsToolButtonStyle(GetToolButton.Style);
end;

function TwrpToolButton.Get_Wrap: WordBool;
begin
  Result := GetToolButton.Wrap;
end;

function TwrpToolButton.GetToolButton: TToolButton;
begin
  Result := GetObject as TToolButton;
end;

procedure TwrpToolButton.Set_AllowAllUp(Value: WordBool);
begin
  GetToolButton.AllowAllUp := Value;
end;

procedure TwrpToolButton.Set_Down(Value: WordBool);
begin
  GetToolButton.Down := Value;
end;

procedure TwrpToolButton.Set_DropdownMenu(const Value: IgsPopupMenu);
begin
  GetToolButton.DropdownMenu := InterfaceToObject(Value) as TPopupMenu;
end;

procedure TwrpToolButton.Set_Grouped(Value: WordBool);
begin
  GetToolButton.Grouped := Value;
end;

procedure TwrpToolButton.Set_ImageIndex(Value: Integer);
begin
  GetToolButton.ImageIndex := Value;
end;

procedure TwrpToolButton.Set_Indeterminate(Value: WordBool);
begin
  GetToolButton.Indeterminate := Value;
end;

procedure TwrpToolButton.Set_Marked(Value: WordBool);
begin
  GetToolButton.Marked := Value;
end;

procedure TwrpToolButton.Set_MenuItem(const Value: IgsMenuItem);
begin
  GetToolButton.MenuItem := InterfaceToObject(Value) as TMenuItem;
end;

procedure TwrpToolButton.Set_Style(Value: TgsToolButtonStyle);
begin
  GetToolButton.Style := TToolButtonStyle(Value);
end;

procedure TwrpToolButton.Set_Wrap(Value: WordBool);
begin
  GetToolButton.Wrap := Value;
end;

{ TwrpHandleStream }

function TwrpHandleStream.Get_Handle: Integer;
begin
  Result := GetHandleStream.Handle;
end;

function TwrpHandleStream.GetHandleStream: THandleStream;
begin
  Result := GetObject as THandleStream;
end;

function  TwrpHandleStream.ReadInteger: Integer; safecall;
begin
  GetHandleStream.Read(Result, SizeOf(Result));
end;

function TwrpHandleStream.ReadBoolean: WordBool;
begin
  GetHandleStream.Read(Result, SizeOf(Result));
end;

function TwrpHandleStream.ReadCurrency: Currency;
begin
  GetHandleStream.Read(Result, SizeOf(Result));
end;

function TwrpHandleStream.ReadDate: TDateTime;
begin
  GetHandleStream.Read(Result, SizeOf(Result));
end;

function TwrpHandleStream.ReadSingle: Single;
begin
  GetHandleStream.Read(Result, SizeOf(Result));
end;

function TwrpHandleStream.ReadString(Count: Integer): WideString;
var
  S: String;
begin
  if Count < 1 then
    raise Exception.Create('Количество символов считывания должно быть больше 0.');

  SetLength(S, Count);
  GetHandleStream.Read(S[1], Count);
  Result := S;
end;

function TwrpHandleStream.WriteBoolean(Buffer: WordBool): Integer;
begin
  Result := GetHandleStream.Write(Buffer, SizeOf(WordBool));
end;

function TwrpHandleStream.WriteCurrency(Buffer: Currency): Integer;
begin
  Result := GetHandleStream.Write(Buffer, SizeOf(Currency));
end;

function TwrpHandleStream.WriteDate(Buffer: TDateTime): Integer;
begin
  Result := GetHandleStream.Write(Buffer, SizeOf(TDateTime));
end;

function TwrpHandleStream.WriteInteger(Buffer: Integer): Integer;
begin
  Result := GetHandleStream.Write(Buffer, SizeOf(Integer));
end;

function TwrpHandleStream.WriteSingle(Buffer: Single): Integer;
begin
  Result := GetHandleStream.Write(Buffer, SizeOf(Single));
end;

function TwrpHandleStream.WriteString(const Buffer: WideString;
  Count: Integer): Integer;
var
  S: String;
begin
  if Length(Buffer) < Count then
    raise Exception.Create('Длина переданной строки меньше количества меньше количества записываемых символов.');
  if Length(Buffer) = 0 then
    raise Exception.Create('Строка пустая.');

  S := Buffer;
  Result := GetHandleStream.Write(S[1], Count);
end;

{ TwrpMetafile }

procedure TwrpMetafile.Clear;
begin
  GetMetafile.Clear;
end;

function TwrpMetafile.Get_CreatedBy: WideString;
begin
  Result := GetMetafile.CreatedBy;
end;

function TwrpMetafile.Get_Description: WideString;
begin
  Result := GetMetafile.Description;
end;

function TwrpMetafile.Get_Enhanced: WordBool;
begin
  Result := GetMetafile.Enhanced;
end;

function TwrpMetafile.Get_Handle: LongWord;
begin
  Result := GetMetafile.Handle;
end;

function TwrpMetafile.Get_Inch: Word;
begin
  Result := GetMetafile.Inch;
end;

function TwrpMetafile.Get_MMHeight: Integer;
begin
  Result := GetMetafile.MMHeight;
end;

function TwrpMetafile.Get_MMWidth: Integer;
begin
  Result := GetMetafile.MMWidth;
end;

function TwrpMetafile.GetMetafile: TMetafile;
begin
  Result := GetObject as TMetafile;
end;

function TwrpMetafile.ReleaseHandle: LongWord;
begin
  Result := GetMetafile.ReleaseHandle;
end;

procedure TwrpMetafile.Set_Enhanced(Value: WordBool);
begin
  GetMetafile.Enhanced := Value;
end;

procedure TwrpMetafile.Set_Handle(Value: LongWord);
begin
  GetMetafile.Handle := Value;
end;

procedure TwrpMetafile.Set_Inch(Value: Word);
begin
  GetMetafile.Inch := Value;
end;

procedure TwrpMetafile.Set_MMHeight(Value: Integer);
begin
  GetMetafile.MMHeight := Value;
end;

procedure TwrpMetafile.Set_MMWidth(Value: Integer);
begin
  GetMetafile.MMWidth := Value;
end;

{ TwrpCustomMemoryStream }

function TwrpCustomMemoryStream.GetCustomMemoryStream: TCustomMemoryStream;
begin
  Result := GetObject as TCustomMemoryStream;
end;

function TwrpCustomMemoryStream.ReadBoolean: WordBool;
begin
  GetCustomMemoryStream.Read(Result, SizeOf(Result));
end;

function TwrpCustomMemoryStream.ReadCurrency: Currency;
begin
  GetCustomMemoryStream.Read(Result, SizeOf(Result));
end;

function TwrpCustomMemoryStream.ReadDate: TDateTime;
begin
  GetCustomMemoryStream.Read(Result, SizeOf(Result));
end;

function TwrpCustomMemoryStream.ReadInteger: Integer;
begin
  GetCustomMemoryStream.Read(Result, SizeOf(Result));
end;

function TwrpCustomMemoryStream.ReadSingle: Single;
begin
  GetCustomMemoryStream.Read(Result, SizeOf(Result));
end;

function TwrpCustomMemoryStream.ReadString(Count: Integer): WideString;
var
  S: String;
begin
  if Count < 1 then
    raise Exception.Create('Количество символов считывания должно быть больше 0.');

  SetLength(S, Count);
  GetCustomMemoryStream.Read(S[1], Count);
  Result := S;
end;

procedure TwrpCustomMemoryStream.SaveToFile(const FileName: WideString);
begin
  GetCustomMemoryStream.SaveToFile(FileName);
end;

procedure TwrpCustomMemoryStream.SaveToStream(const Stream: IgsStream);
begin
  GetCustomMemoryStream.SaveToStream(InterfaceToObject(Stream) as TStream);
end;

{ TwrpMemoryStream }

procedure TwrpMemoryStream.Clear;
begin
  GetMemoryStream.Clear;
end;

function TwrpMemoryStream.GetMemoryStream: TMemoryStream;
begin
  Result := GetObject as TMemoryStream;
end;

procedure TwrpMemoryStream.LoadFromFile(const FileName: WideString);
begin
  GetMemoryStream.LoadFromFile(FileName);
end;

procedure TwrpMemoryStream.LoadFromStream(const Stream: IgsStream);
begin
  GetMemoryStream.LoadFromStream(InterfaceToObject(Stream) as TStream);
end;

procedure TwrpMemoryStream.SetSize(NewSize: Integer);
begin
  GetMemoryStream.SetSize(NewSize);
end;

procedure TwrpApplication.ActivateHint(X, Y: Integer);
var
  LPoint: TPoint;
begin
  LPoint.x := X;
  LPoint.y := Y;
  Application.ActivateHint(LPoint);
end;

procedure TwrpApplication.CancelHint;
begin
  Application.CancelHint;
end;

procedure TwrpApplication.ControlDestroyed(const Control: IgsControl);
begin
  Application.ControlDestroyed(InterfaceToObject(Control) as TControl);
end;

function TwrpApplication.Get_AllowTesting: WordBool;
begin
  Result := Application.AllowTesting;
end;

function TwrpApplication.Get_BiDiKeyboard: WideString;
begin
  Result :=  Application.BiDiKeyboard;
end;

function TwrpApplication.Get_CurrentHelpFile: WideString;
begin
  Result := Application.CurrentHelpFile;
end;

function TwrpApplication.Get_DialogHandle: LongWord;
begin
  Result :=  Application.DialogHandle;
end;

function TwrpApplication.Get_ExeName: WideString;
begin
  Result :=  Application.ExeName;
end;

function TwrpApplication.Get_HelpFile: WideString;
begin
  Result :=  Application.HelpFile;
end;

function TwrpApplication.Get_Hint: WideString;
begin
  Result :=  Application.Hint;
end;

function TwrpApplication.Get_HintColor: Integer;
begin
  Result :=  Application.HintColor;
end;

function TwrpApplication.Get_HintHidePause: Integer;
begin
  Result :=  Application.HintHidePause;
end;

function TwrpApplication.Get_HintPause: Integer;
begin
  Result :=  Application.HintPause;
end;

function TwrpApplication.Get_HintShortCuts: WordBool;
begin
  Result :=  Application.HintShortCuts;
end;

function TwrpApplication.Get_HintShortPause: Integer;
begin
  Result :=  Application.HintShortPause;
end;

function TwrpApplication.Get_Icon: IgsIcon;
begin
  Result :=  GetGdcOleObject(Application.Icon) as IgsIcon;
end;

function TwrpApplication.Get_ShowHint: WordBool;
begin
  Result := Application.ShowHint;
end;

function TwrpApplication.Get_ShowMainForm: WordBool;
begin
  Result :=  Application.ShowMainForm;
end;

function TwrpApplication.Get_UpdateFormatSettings: WordBool;
begin
  Result :=  Application.UpdateFormatSettings;
end;

function TwrpApplication.Get_UpdateMetricSettings: WordBool;
begin
  Result :=  Application.UpdateMetricSettings;
end;

procedure TwrpApplication.HandleException(const Sender: IgsObject);
begin
  Application.HandleException(InterfaceToObject(Sender));
end;

function TwrpApplication.HelpContext(Context: Integer): WordBool;
begin
  Result :=  Application.HelpContext(Context);
end;

function TwrpApplication.HelpJump(const JumpID: WideString): WordBool;
begin
  Result :=  Application.HelpJump(JumpID);
end;

procedure TwrpApplication.HideHint;
begin
  Application.HideHint;
end;

procedure TwrpApplication.Initialize;
begin
  Application.Initialize;
end;

function TwrpApplication.IsRightToLeft: WordBool;
begin
  Result := Application.IsRightToLeft;
end;

procedure TwrpApplication.Set_AllowTesting(Value: WordBool);
begin
  Application.AllowTesting := Value;
end;

procedure TwrpApplication.Set_BiDiKeyboard(const Value: WideString);
begin
  Application.BiDiKeyboard := Value;
end;

procedure TwrpApplication.Set_DialogHandle(Value: LongWord);
begin
  Application.DialogHandle := Value;
end;

procedure TwrpApplication.Set_HelpFile(const Value: WideString);
begin
  Application.HelpFile := Value;
end;

procedure TwrpApplication.Set_Hint(const Value: WideString);
begin
  Application.Hint := Value;
end;

procedure TwrpApplication.Set_HintColor(Value: Integer);
begin
  Application.HintColor := Value;
end;

procedure TwrpApplication.Set_HintHidePause(Value: Integer);
begin
  Application.HintHidePause := Value;
end;

procedure TwrpApplication.Set_HintPause(Value: Integer);
begin
  Application.HintPause := Value;
end;

procedure TwrpApplication.Set_HintShortCuts(Value: WordBool);
begin
  Application.HintShortCuts := Value;
end;

procedure TwrpApplication.Set_HintShortPause(Value: Integer);
begin
  Application.HintShortPause := Value;
end;

procedure TwrpApplication.Set_Icon(const Value: IgsIcon);
begin
  Application.Icon := InterfaceToObject(Value) as TIcon;
end;

procedure TwrpApplication.Set_ShowHint(Value: WordBool);
begin
  Application.ShowHint := Value;
end;

procedure TwrpApplication.Set_ShowMainForm(Value: WordBool);
begin
  Application.ShowMainForm := Value;
end;

procedure TwrpApplication.Set_UpdateFormatSettings(Value: WordBool);
begin
  Application.UpdateFormatSettings := Value;
end;

procedure TwrpApplication.Set_UpdateMetricSettings(Value: WordBool);
begin
  Application.UpdateMetricSettings := Value;
end;

function TwrpApplication.UpdateAction(
  const Action: IgsBasicAction): WordBool;
begin
  Result := Application.UpdateAction(InterfaceToObject(Action) as TBasicAction);
end;

function TwrpApplication.UseRightToLeftAlignment: WordBool;
begin
  Result := Application.UseRightToLeftAlignment;
end;

function TwrpApplication.UseRightToLeftReading: WordBool;
begin
  Result := Application.UseRightToLeftReading;
end;

function TwrpApplication.UseRightToLeftScrollBar: WordBool;
begin
  Result := Application.UseRightToLeftScrollBar;
end;

function TwrpMemoryStream.WriteBoolean(Buffer: WordBool): Integer;
begin
  Result := GetMemoryStream.Write(Buffer, SizeOf(Buffer));
end;

function TwrpMemoryStream.WriteCurrency(Buffer: Currency): Integer;
begin
  Result := GetMemoryStream.Write(Buffer, SizeOf(Buffer));
end;

function TwrpMemoryStream.WriteDate(Buffer: TDateTime): Integer;
begin
  Result := GetMemoryStream.Write(Buffer, SizeOf(Buffer));
end;

function TwrpMemoryStream.WriteInteger(Buffer: Integer): Integer;
begin
  Result := GetMemoryStream.Write(Buffer, SizeOf(Buffer));
end;

function TwrpMemoryStream.WriteSingle(Buffer: Single): Integer;
begin
  Result := GetMemoryStream.Write(Buffer, SizeOf(Buffer));
end;

function TwrpMemoryStream.WriteString(const Buffer: WideString;
  Count: Integer): Integer;
var
  S: String;
begin
  if Length(Buffer) < Count then
    raise Exception.Create('Длина переданной строки меньше количества меньше количества записываемых символов.');
  if Length(Buffer) = 0 then
    raise Exception.Create('Строка пустая.');

  S := Buffer;
  Result := GetMemoryStream.Write(S[1], Count);
end;

{ TwrpScreen }

procedure TwrpScreen.DisableAlign;
begin
  Screen.DisableAlign;
end;

procedure TwrpScreen.EnableAlign;
begin
  Screen.EnableAlign;
end;

function TwrpScreen.Get_ActiveControl: IgsControl;
begin
  Result := GetGdcOLEObject(Screen.ActiveControl) as IgsControl;
end;

function TwrpScreen.Get_ActiveCustomForm: IgsCustomForm;
begin
  Result := GetGdcOLEObject(Screen.ActiveCustomForm) as IgsCustomForm;
end;

function TwrpScreen.Get_ActiveForm: IgsForm;
begin
  Result := GetGdcOLEObject(Screen.ActiveForm) as IgsForm;
end;

function TwrpScreen.Get_Cursor: Integer;
begin
  Result := Screen.Cursor;
end;

function TwrpScreen.Get_Cursors(Index: Integer): Integer;
begin
  Result := Screen.Cursors[Index];
end;

function TwrpScreen.Get_CustomFormCount: Integer;
begin
  Result := Screen.CustomFormCount;
end;

function TwrpScreen.Get_CustomForms(Index: Integer): IgsCustomForm;
begin
  Result := GetGdcOLEObject(Screen.CustomForms[Index]) as IgsCustomForm;
end;

function TwrpScreen.Get_DataModuleCount: Integer;
begin
  Result := Screen.DataModuleCount;
end;

function TwrpScreen.Get_DataModules(Index: Integer): IgsDataModule;
begin
  Result := GetGdcOLEObject(Screen.DataModules[Index]) as IgsDataModule;
end;

function TwrpScreen.Get_DefaultIme: WideString;
begin
  Result := Screen.DefaultIme;
end;

function TwrpScreen.Get_DefaultKbLayout: Integer;
begin
  Result := Screen.DefaultKbLayout;
end;

function TwrpScreen.Get_DesktopHeight: Integer;
begin
  Result := Screen.DesktopHeight;
end;

function TwrpScreen.Get_DesktopLeft: Integer;
begin
  Result := Screen.DesktopLeft;
end;

function TwrpScreen.Get_DesktopTop: Integer;
begin
  Result := Screen.DesktopTop;
end;

function TwrpScreen.Get_DesktopWidth: Integer;
begin
  Result := Screen.DesktopWidth;
end;

function TwrpScreen.Get_Fonts: IgsStrings;
begin
  Result := TStringsToIgsStrings(Screen.Fonts);
end;

function TwrpScreen.Get_FormCount: Integer;
begin
  Result := Screen.FormCount;
end;

function TwrpScreen.Get_Forms(Index: Integer): IgsForm;
begin
  Result := GetGdcOLEObject(Screen.Forms[Index]) as IgsForm;
end;

function TwrpScreen.Get_Height: Integer;
begin
  Result := Screen.Height;
end;

function TwrpScreen.Get_HintFont: IgsFont;
begin
  Result := GetGdcOLEObject(Screen.HintFont) as IgsFont;
end;

function TwrpScreen.Get_IconFont: IgsFont;
begin
  Result := GetGdcOLEObject(Screen.IconFont) as IgsFont;
end;

function TwrpScreen.Get_Imes: IgsStrings;
begin
  Result := TStringsToIgsStrings(Screen.Imes);
end;

function TwrpScreen.Get_MenuFont: IgsFont;
begin
  Result := GetGdcOLEObject(Screen.MenuFont) as IgsFont;
end;

function TwrpScreen.Get_PixelsPerInch: Integer;
begin
  Result := Screen.PixelsPerInch;
end;

function TwrpScreen.Get_Width: Integer;
begin
  Result := Screen.Width;
end;

procedure TwrpScreen.Realign;
begin
  Screen.Realign;
end;

procedure TwrpScreen.ResetFonts;
begin
  Screen.ResetFonts;
end;

procedure TwrpScreen.Set_Cursor(Value: Integer);
begin
  Screen.Cursor := Value;
end;

procedure TwrpScreen.Set_Cursors(Index, Value: Integer);
begin
  Screen.Cursors[Index] := Value;
end;

procedure TwrpScreen.Set_HintFont(const Value: IgsFont);
begin
  Screen.HintFont := InterfaceToObject(Value) as TFont;
end;

procedure TwrpScreen.Set_IconFont(const Value: IgsFont);
begin
  Screen.IconFont := InterfaceToObject(Value) as TFont;
end;

procedure TwrpScreen.Set_MenuFont(const Value: IgsFont);
begin
  Screen.MenuFont := InterfaceToObject(Value) as TFont;
end;

{ TwrpDataModule }

procedure TwrpDataModule.AfterConstruction_;
begin
  GetDataModule.AfterConstruction;
end;

procedure TwrpDataModule.BeforeDestruction_;
begin
  GetDataModule.BeforeDestruction;
end;

function TwrpDataModule.GetDataModule: TDataModule;
begin
  Result:= GetObject as TDataModule;
end;

function TwrpDataModule.Get_OldCreateOrder: WordBool;
begin
  Result := GetDataModule.OldCreateOrder;
end;

procedure TwrpDataModule.Set_OldCreateOrder(Value: WordBool);
begin
  GetDataModule.OldCreateOrder := Value;
end;

{ TwrpAggregate }

function TwrpAggregate.Get_Active: WordBool;
begin
  Result := GetAggregate.Active
end;

function TwrpAggregate.Get_AggHandle: Integer;
begin
  Result := GetAggregate.AggHandle;
end;

function TwrpAggregate.Get_AggregateName: WideString;
begin
  Result := GetAggregate.AggregateName;
end;

function TwrpAggregate.Get_DataSet: IgsClientDataSet;
begin
  Result := GetGdcOLEObject(GetAggregate.DataSet) as IgsClientDataSet;
end;

function TwrpAggregate.Get_DataSize: Integer;
begin
  Result := GetAggregate.DataSize;
end;

function TwrpAggregate.Get_DataType: TgsFieldType;
begin
  Result := TgsFieldType(GetAggregate.DataType);
end;

function TwrpAggregate.Get_Expression: WideString;
begin
  Result := GetAggregate.Expression;
end;

function TwrpAggregate.Get_GroupingLevel: Integer;
begin
  Result := GetAggregate.GroupingLevel;
end;

function TwrpAggregate.Get_IndexName: WideString;
begin
  Result := GetAggregate.IndexName;
end;

function TwrpAggregate.Get_InUse: WordBool;
begin
  Result := GetAggregate.InUse;
end;

function TwrpAggregate.Get_Visible: WordBool;
begin
  Result := GetAggregate.Visible;
end;

function TwrpAggregate.GetAggregate: TAggregate;
begin
  Result := GetObject as TAggregate;
end;

function TwrpAggregate.GetDisplayName: WideString;
begin
  Result := GetAggregate.GetDisplayName;
end;

procedure TwrpAggregate.Set_Active(Value: WordBool);
begin
  GetAggregate.Active := Value;
end;

procedure TwrpAggregate.Set_AggHandle(Value: Integer);
begin
  GetAggregate.AggHandle := Value;
end;

procedure TwrpAggregate.Set_AggregateName(const Value: WideString);
begin
   GetAggregate.AggregateName := Value;
end;

procedure TwrpAggregate.Set_Expression(const Value: WideString);
begin
  GetAggregate.Expression := Value;
end;

procedure TwrpAggregate.Set_GroupingLevel(Value: Integer);
begin
  GetAggregate.GroupingLevel := Value;
end;

procedure TwrpAggregate.Set_IndexName(const Value: WideString);
begin
  GetAggregate.IndexName := Value;
end;

procedure TwrpAggregate.Set_InUse(Value: WordBool);
begin
  GetAggregate.InUse := Value;
end;

procedure TwrpAggregate.Set_Visible(Value: WordBool);
begin
  GetAggregate.Visible := Value;
end;

function TwrpAggregate.Value: OleVariant;
begin
  Value := GetAggregate.Value;
end;

{ TwrpAggregates }

function TwrpAggregates.Add: IgsAggregate;
begin
  Result := GetGdcOLEObject(GetAggregates.Add) as IgsAggregate;
end;

function TwrpAggregates.Find(const DisplayName: WideString): IgsAggregate;
begin
  Result := GetGdcOLEObject(GetAggregates.Find(DisplayName)) as IgsAggregate;
end;

function TwrpAggregates.Get_Items(Index: Integer): IgsAggregate;
begin
  Result := GetGdcOLEObject(GetAggregates.Items[Index]) as IgsAggregate;
end;

function TwrpAggregates.GetAggregates: TAggregates;
begin
  Result := GetObject as TAggregates;
end;

function TwrpAggregates.IndexOf(const DisplayName: WideString): Integer;
begin
  Result := GetAggregates.IndexOf(DisplayName);
end;

procedure TwrpAggregates.Set_Items(Index: Integer;
  const Value: IgsAggregate);
begin
  GetAggregates.Items[Index] := InterfaceToObject(Value) as TAggregate;
end;

function TwrpApplication.Get_CurrencySeparatorSys: WideString;
var
  S: PChar;
  I: Integer;
begin
  I := SizeOf(Char);
  GetMem(S, I);
  GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SMONDECIMALSEP, S, I);
  Result := String(S^);
  FreeMem(S, I)
end;

function TwrpApplication.Get_DecimalSeparatorSys: WideString;
var
  S: PChar;
  I: Integer;
begin
  I := SizeOf(Char);
  GetMem(S, I);
  GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SDECIMAL, S, I);
  Result := String(S^);
  FreeMem(S, I)
end;

{ TwrpMouse }

function TwrpMouse.Get_CursorPosX: Integer;
begin
  Result := Mouse.CursorPos.x
end;

function TwrpMouse.Get_CursorPosY: Integer;
begin
  Result := Mouse.CursorPos.y
end;

function TwrpMouse.Get_DragImmediate: WordBool;
begin
  Result := Mouse.DragImmediate;
end;

function TwrpMouse.Get_DragThreshold: Integer;
begin
  Result := Mouse.DragThreshold
end;

function TwrpMouse.Get_MousePresent: WordBool;
begin
  Result := Mouse.MousePresent
end;

function TwrpMouse.Get_WheelPresent: WordBool;
begin
  Result := Mouse.WheelPresent
end;

function TwrpMouse.Get_WheelScrollLines: Integer;
begin
  Result := Mouse.WheelScrollLines
end;

procedure TwrpMouse.Set_CursorPosX(Value: Integer);
var
  CursorPos: TPoint;
begin
  CursorPos.y := Mouse.CursorPos.y;
  CursorPos.x := Value;

  Mouse.CursorPos := CursorPos;
end;

procedure TwrpMouse.Set_CursorPosY(Value: Integer);
var
  CursorPos: TPoint;
begin
  CursorPos.x := Mouse.CursorPos.x;
  CursorPos.y := Value;

  Mouse.CursorPos := CursorPos;
end;

{ TwrpPrinter }

procedure TwrpPrinter.Abort;
begin
  GetPrinter.Abort;
end;

procedure TwrpPrinter.BeginDoc;
begin
  GetPrinter.BeginDoc;
end;

procedure TwrpPrinter.EndDoc;
begin
  GetPrinter.EndDoc;
end;

function TwrpPrinter.Get_Aborted: WordBool;
begin
  Result := GetPrinter.Aborted;
end;

function TwrpPrinter.Get_Canvas: IgsCanvas;
begin
  Result := GetGdcOLEObject(GetPrinter.Canvas) as IgsCanvas;
end;

function TwrpPrinter.Get_Capabilities: WideString;
begin
  Result := ' ';
  if pcCopies in GetPrinter.Capabilities then
    Result := 'pcCopies ';
  if pcOrientation in GetPrinter.Capabilities then
    Result := Result + 'pcOrientation ';
  if pcCollation in GetPrinter.Capabilities then
    Result := Result + 'pcCollation ';
end;

function TwrpPrinter.Get_Copies: Integer;
begin
  Result := GetPrinter.Copies;
end;

function TwrpPrinter.Get_Fonts: IgsStrings;
begin
  Result := GetGdcOLEObject(GetPrinter.Fonts) as IgsStrings;
end;

function TwrpPrinter.Get_Handle: Integer;
begin
  Result := GetPrinter.Handle;
end;

function TwrpPrinter.Get_Orientation: TgsPrinterOrientation;
begin
  Result := TgsPrinterOrientation(GetPrinter.Orientation);
end;

function TwrpPrinter.Get_PageHeight: Integer;
begin
  Result := GetPrinter.PageHeight;
end;

function TwrpPrinter.Get_PageNumber: Integer;
begin
  Result := GetPrinter.PageNumber;
end;

function TwrpPrinter.Get_PageWidth: Integer;
begin
  Result := GetPrinter.PageWidth;
end;

function TwrpPrinter.Get_PrinterIndex: Integer;
begin
  Result := GetPrinter.PrinterIndex;
end;

function TwrpPrinter.Get_Printers: IgsStrings;
begin
  Result := GetGdcOLEObject(GetPrinter.Printers) as IgsStrings;
end;

function TwrpPrinter.Get_Printing: WordBool;
begin
  Result := GetPrinter.Printing;
end;

function TwrpPrinter.Get_Title: WideString;
begin
  Result := GetPrinter.Title;
end;

function TwrpPrinter.GetPrinter: TPrinter;
begin
  Result := GetObject as TPrinter;
end;

procedure TwrpPrinter.NewPage;
begin
  GetPrinter.NewPage;
end;

procedure TwrpPrinter.Refresh;
begin
  GetPrinter.Refresh;
end;

procedure TwrpPrinter.Set_Copies(Value: Integer);
begin
  GetPrinter.Copies := Value;
end;

procedure TwrpPrinter.Set_Orientation(Value: TgsPrinterOrientation);
begin
  GetPrinter.Orientation := TPrinterOrientation(Value);
end;

procedure TwrpPrinter.Set_PrinterIndex(Value: Integer);
begin
  GetPrinter.PrinterIndex := Value;
end;

procedure TwrpPrinter.Set_Title(const Value: WideString);
begin
  GetPrinter.Title := Value;
end;

class function TwrpPrinter.CreateObject(const DelphiClass: TClass; const Params: OleVariant): TObject;
begin
  Result := TPrinter.Create;
end;

{ TwrpFileStream }


{ TwrpFileStream }

class function TwrpFileStream.CreateObject(const DelphiClass: TClass;
  const Params: OleVariant): TObject;
begin
  Result := nil;
  if VariantIsArray(Params) and (VarArrayHighBound(Params, 1) = 1) then
    Result := TFileStream.Create(String(Params[0]), Word(Params[1]))
  else
    ErrorParamsCount('2');
end;

{ TwrpfrAcctAnalytics }

function TwrpfrAcctAnalytics.GetFrame: TfrAcctAnalytics;
begin
  Result := GetObject as TfrAcctAnalytics;
end;

function TwrpfrAcctAnalytics.Get_Values: WideString;
begin
  Result := GetFrame.Values;
end;

procedure TwrpfrAcctAnalytics.Set_Values(const Value: WideString);
begin
  GetFrame.Values := Value
end;

function  TwrpfrAcctAnalytics.Get_Description: WideString;
begin
  Result := GetFrame.Description;
end;

{TwrpPeriodEdit}
function TwrpPeriodEdit.GetPeriodEdit: TgsPeriodEdit;
begin
  Result := GetObject as TgsPeriodEdit;
end;

function TwrpPeriodEdit.Get_Date: TDateTime;
begin
  Result := GetPeriodEdit.Date;
end;

function TwrpPeriodEdit.Get_EndDate: TDateTime;
begin
  Result := GetPeriodEdit.EndDate;
end;

procedure TwrpPeriodEdit.AssignPeriod(ADate, AnEndDate: TDateTime);
begin
  GetPeriodEdit.AssignPeriod(ADate, AnEndDate);
end;

{ TwrpWebBrowser }

function TwrpWebBrowser.GetWebBrowser: TWebBrowser;
begin
  Result := GetObject as TWebBrowser;
end;

function TwrpWebBrowser.Get_Application: IDispatch;
begin
  Result := GetWebBrowser.Application;
end;

function TwrpWebBrowser.Get_Busy: WordBool;
begin
  Result := GetWebBrowser.Busy;
end;

function TwrpWebBrowser.Get_Container: IDispatch;
begin
  Result := GetWebBrowser.Container;
end;

function TwrpWebBrowser.Get_Document: IDispatch;
begin
  Result := GetWebBrowser.Document;
end;

function TwrpWebBrowser.Get_LocationName: WideString;
begin
  Result := GetWebBrowser.LocationName;
end;

function TwrpWebBrowser.Get_LocationURL: WideString;
begin
  Result := GetWebBrowser.LocationURL;
end;

function TwrpWebBrowser.Get_TopLevelContainer: WordBool;
begin
  Result := GetWebBrowser.TopLevelContainer;
end;

function TwrpWebBrowser.Get_Type_: WideString;
begin
  Result := GetWebBrowser.Type_;
end;

procedure TwrpWebBrowser.GoBack;
begin
  GetWebBrowser.GoBack;
end;

procedure TwrpWebBrowser.GoForward;
begin
  GetWebBrowser.GoForward;
end;

procedure TwrpWebBrowser.GoHome;
begin
  GetWebBrowser.GoHome;
end;

procedure TwrpWebBrowser.GoSearch;
begin
  GetWebBrowser.GoSearch;
end;

procedure TwrpWebBrowser.Navigate(const URL: WideString; var Flags,
  TargetFrameName, PostData, Headers: OleVariant);
begin
  GetWebBrowser.Navigate(URL, Flags, TargetFrameName, PostData, Headers);
end;

procedure TwrpWebBrowser.Refresh_;
begin
  GetWebBrowser.Refresh;
end;

procedure TwrpWebBrowser.Refresh2(var Level: OleVariant);
begin
  GetWebBrowser.Refresh2(Level);
end;

procedure TwrpWebBrowser.Stop;
begin
  GetWebBrowser.Stop;
end;

procedure TwrpWebBrowser.ExecWB(cmdID, cmdExecOpt: Integer; var pvaIn,
  pvaOut: OleVariant);
begin
  GetWebBrowser.ExecWB(cmdID, cmdExecOpt, pvaIn, pvaOut);
end;

function TwrpWebBrowser.Get_AddressBar: WordBool;
begin
  Result := GetWebBrowser.AddressBar;
end;

function TwrpWebBrowser.Get_Offline: WordBool;
begin
  Result := GetWebBrowser.Offline;
end;

function TwrpWebBrowser.Get_ReadyState: Integer;
begin
  Result := GetWebBrowser.ReadyState;
end;

function TwrpWebBrowser.Get_RegisterAsBrowser: WordBool;
begin
  Result := GetWebBrowser.RegisterAsBrowser;
end;

function TwrpWebBrowser.Get_RegisterAsDropTarget: WordBool;
begin
  Result := GetWebBrowser.RegisterAsDropTarget;
end;

function TwrpWebBrowser.Get_Resizable: WordBool;
begin
  Result := GetWebBrowser.Resizable;
end;

function TwrpWebBrowser.Get_Silent: WordBool;
begin
  Result := GetWebBrowser.Silent;
end;

function TwrpWebBrowser.Get_TheaterMode: WordBool;
begin
  Result := GetWebBrowser.TheaterMode;
end;

procedure TwrpWebBrowser.Navigate2(var URL, Flags, TargetFrameName,
  PostData, Headers: OleVariant);
begin
  GetWebBrowser.Navigate2(URL, Flags, TargetFrameName, PostData, Headers);
end;

function TwrpWebBrowser.QueryStatusWB(cmdID: Integer): Integer;
begin
  Result := GetWebBrowser.QueryStatusWB(cmdID);
end;

procedure TwrpWebBrowser.Set_AddressBar(Value: WordBool);
begin
  GetWebBrowser.AddressBar := Value;
end;

procedure TwrpWebBrowser.Set_Offline(Value: WordBool);
begin
  GetWebBrowser.Offline := Value;
end;

procedure TwrpWebBrowser.Set_RegisterAsBrowser(Value: WordBool);
begin
  GetWebBrowser.RegisterAsBrowser := Value;
end;

procedure TwrpWebBrowser.Set_RegisterAsDropTarget(Value: WordBool);
begin
  GetWebBrowser.RegisterAsDropTarget := Value;
end;

procedure TwrpWebBrowser.Set_Resizable(Value: WordBool);
begin
  GetWebBrowser.Resizable := Value;
end;

procedure TwrpWebBrowser.Set_Silent(Value: WordBool);
begin
  GetWebBrowser.Silent := Value;
end;

procedure TwrpWebBrowser.Set_TheaterMode(Value: WordBool);
begin
  GetWebBrowser.TheaterMode := Value;
end;

procedure TwrpWebBrowser.ShowBrowserBar(var pvaClsID, pvarShow,
  pvarSize: OleVariant);
begin
  GetWebBrowser.ShowBrowserBar(pvaClsID, pvarShow, pvarSize);
end;

function TwrpApplication.GetFIOCase(const SurName: WideString; const FirstName: WideString;
  const MiddleName: WideString; Sex: Integer; TheCase: Integer): WideString;
begin
  Result := FIOCase(SurName, FirstName, MiddleName, Sex, TheCase);
end;

function TwrpApplication.GetComplexCase(const TheWord: WideString;
  TheCase: Integer): WideString;
begin
  Result := ComplexCase(TheWord, TheCase);
end;

function TwrpApplication.GetNumericWordForm(ANum: Integer; const AStrForm1,
  AStrForm2, AStrForm5: WideString): WideString;
begin
  Result := gsMorph.GetNumericWordForm(ANum, AStrForm1, AStrForm2, AStrForm5);
end;

{ TwrpgsPanel }


function TwrpgsPanel.Get_FontArea1: IgsFont;
begin
  Result := GetGdcOLEObject(GetPanel.FontArea1) as IgsFont;
end;

function TwrpgsPanel.Get_FontArea2: IgsFont;
begin
  Result := GetGdcOLEObject(GetPanel.FontArea2) as IgsFont;
end;

function TwrpgsPanel.Get_FontArea3: IgsFont;
begin
  Result := GetGdcOLEObject(GetPanel.FontArea3) as IgsFont;
end;

function TwrpgsPanel.Get_HeightArea1: Integer;
begin
  Result := GetPanel.HeightArea1;
end;

function TwrpgsPanel.Get_TextArea1: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetPanel.TextArea1);
end;

function TwrpgsPanel.Get_TextArea2: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetPanel.TextArea2);
end;

function TwrpgsPanel.Get_TextArea3: IgsStrings;
begin
  Result := TStringsToIgsStrings(GetPanel.TextArea3);
end;

function TwrpgsPanel.Get_WidthArea2: Integer;
begin
  Result := GetPanel.WidthArea2;
end;

function TwrpgsPanel.GetPanel: TgsPanel;
begin
  Result := GetObject as TgsPanel;
end;

procedure TwrpgsPanel.Set_FontArea1(const Value: IgsFont);
begin
  GetPanel.FontArea1 := InterfaceToObject(Value) as TFont;
end;

procedure TwrpgsPanel.Set_FontArea2(const Value: IgsFont);
begin
  GetPanel.FontArea2 := InterfaceToObject(Value) as TFont;
end;

procedure TwrpgsPanel.Set_FontArea3(const Value: IgsFont);
begin
  GetPanel.FontArea3 := InterfaceToObject(Value) as TFont;
end;

procedure TwrpgsPanel.Set_HeightArea1(Value: Integer);
begin
  GetPanel.HeightArea1 := Value;
end;

procedure TwrpgsPanel.Set_TextArea1(const Value: IgsStrings);
begin
  GetPanel.TextArea1 := IgsStringsToTStrings(Value);
end;

procedure TwrpgsPanel.Set_TextArea2(const Value: IgsStrings);
begin
  GetPanel.TextArea2 := IgsStringsToTStrings(Value);
end;

procedure TwrpgsPanel.Set_TextArea3(const Value: IgsStrings);
begin
  GetPanel.TextArea3 := IgsStringsToTStrings(Value);
end;

procedure TwrpgsPanel.Set_WidthArea2(Value: Integer);
begin
  GetPanel.WidthArea2 := Value;
end;

function TwrpgsPanel.Get_BorderColor: Integer;
begin
  Result := GetPanel.BorderColor;
end;

procedure TwrpgsPanel.Set_BorderColor(Value: Integer);
begin
  GetPanel.BorderColor := Value;
end;

procedure TwrpApplication.MimeDecodeStream(const InputStream,
  OutputStream: IgsStream);
begin
  JclMime.MimeDecodeStream(InterfaceToObject(InputStream) as TStream,
    InterfaceToObject(OutputStream) as TStream);
end;

procedure TwrpApplication.MimeEncodeStream(const InputStream,
  OutputStream: IgsStream; WithCRLF: WordBool);
begin
  if WithCRLF then
    JclMime.MimeEncodeStream(InterfaceToObject(InputStream) as TStream,
      InterfaceToObject(OutputStream) as TStream)
  else
    JclMime.MimeEncodeStreamNoCRLF(InterfaceToObject(InputStream) as TStream,
      InterfaceToObject(OutputStream) as TStream);
end;

initialization
(*  TAutoObjectFactory.Create(ComServer, TwrpObject, CLASS_gs_Object,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpComponent, CLASS_gs_Component,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCollectionItem, CLASS_gs_CollectionItem,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCollection, CLASS_gs_Collection,
    ciMultiInstance, tmApartment);


  TAutoObjectFactory.Create(ComServer, TwrpList, CLASS_gs_List,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpControl, CLASS_gs_Control,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpWinControl, CLASS_gs_WinControl,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpGraphicControl, CLASS_gs_GraphicControl,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomForm, CLASS_gs_CustomForm,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpForm, CLASS_gs_Form,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDataSet, CLASS_gs_DataSet,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBCustomDataSet, CLASS_gs_IBCustomDataSet,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpFrames, CLASS_gs_Frame,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpMainMenu, CLASS_gs_MainMenu,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpPopupMenu, CLASS_gs_PopupMenu,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpLabel, CLASS_gs_Label,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpEdit, CLASS_gs_Edit,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpMemo, CLASS_gs_Memo,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpButton, CLASS_gs_Button,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCheckBox, CLASS_gs_CheckBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpRadioButton, CLASS_gs_RadioButton,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpListBox, CLASS_gs_ListBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpComboBox, CLASS_gs_ComboBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpScrollBar, CLASS_gs_ScrollBar,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpGroupBox, CLASS_gs_GroupBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpRadioGroup, CLASS_gs_RadioGroup,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpPanel, CLASS_gs_Panel,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpActionList, CLASS_gs_ActionList,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpMenuItem, CLASS_gs_MenuItem,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpPoint, CLASS_gs_Point,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpRect, CLASS_gs_Rect,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpIBTransaction, CLASS_gs_Transaction,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpField, CLASS_gs_FieldComponent,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBXSQLVAR, CLASS_gs_IBXSQLVAR,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBXSQLDA, CLASS_gs_IBXSQLDA,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpDataSet, CLASS_gs_DataSet,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpDataSource, CLASS_gs_DataSource,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpStringList, CLASS_gs_StringList,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpContainedAction, CLASS_gs_ContainedAction,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomAction, CLASS_gs_CustomAction,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpIBDataSet, CLASS_gs_IBDataSet,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpBevel, CLASS_gs_Bevel,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCheckListBox, CLASS_gs_CheckListBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpPageControl, CLASS_gs_PageControl,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpBitBtn, CLASS_gs_BitBtn,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpSpeedButton, CLASS_gs_SpeedButton,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpSplitter, CLASS_gs_Splitter,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpStaticText, CLASS_gs_StaticText,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpStatusBar, CLASS_gs_StatusBar,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpStringGrid, CLASS_gs_StringGrid,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpTreeView, CLASS_gs_TreeView,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpListView, CLASS_gs_ListView,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpStrings, CLASS_gs_Strings,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpDBCheckBox, CLASS_gs_DBCheckBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDBComboBox, CLASS_gs_DBComboBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDBEdit, CLASS_gs_DBEdit,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDBImage, CLASS_gs_DBImage,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDBListBox, CLASS_gs_DBListBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDBMemo, CLASS_gs_DBMemo,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDBNavigator, CLASS_gs_DBNavigator,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDBRadioGroup, CLASS_gs_DBRadioGroup,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDBRichEdit, CLASS_gs_DBRichEdit,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDBText, CLASS_gs_DBText,
    ciMultiInstance, tmApartment);

  TAutoObjectFactory.Create(ComServer, TwrpIBSQL, CLASS_gs_IBSQL,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpClientDataSet, CLASS_gs_ClientDataSet,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBDatabaseInfo, CLASS_gs_IBDatabaseInfo,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBEvents, CLASS_gs_IBEvents,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBDatabase, CLASS_gs_IBDatabase,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBExtract, CLASS_gs_IBExtract,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBQuery, CLASS_gs_IBQuery,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBStoredProc, CLASS_gs_IBStoredProc,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBTable, CLASS_gs_IBTable,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpIBUpdateSQL, CLASS_gs_IBUpdateSQL,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpPersistent, CLASS_gs_Persistent,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpHeaderControl, CLASS_gs_HeaderControl,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpHotKey, CLASS_gs_HotKey,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomImageList, CLASS_gs_CustomImageList,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDragImageList, CLASS_gs_DragImageList,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomOutline, CLASS_gs_CustomOutline,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpTimer, CLASS_gs_Timer,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpAnimate, CLASS_gs_Animate,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDirectoryListBox, CLASS_gs_DirectoryListBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpColorGrid, CLASS_gs_ColorGrid,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomControlBar, CLASS_gs_CustomControlBar,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpToolWindow, CLASS_gs_ToolWindow,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCoolBar, CLASS_gs_CoolBar,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDateTimePicker, CLASS_gs_DateTimePicker,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomGrid, CLASS_gs_CustomGrid,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDrawGrid, CLASS_gs_DrawGrid,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpDriveComboBox, CLASS_gs_DriveComboBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomListBox, CLASS_gs_CustomListBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpFileListBox, CLASS_gs_FileListBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpFilterComboBox, CLASS_gs_FilterComboBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpGauge, CLASS_gs_Gauge,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpImage, CLASS_gs_Image,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpMaskEdit, CLASS_gs_MaskEdit,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomMaskEdit, CLASS_gs_CustomMaskEdit,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpPageScroller, CLASS_gs_PageScroller,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpProgressBar, CLASS_gs_ProgressBar,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomRichEdit, CLASS_gs_CustomRichEdit,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpScrollBox, CLASS_gs_ScrollBox,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpShape, CLASS_gs_Shape,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpSpinButton, CLASS_gs_SpinButton,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpSpinEdit, CLASS_gs_SpinEdit,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomTabControl, CLASS_gs_CustomTabControl,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpToolBar, CLASS_gs_ToolBar,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpTrackBar, CLASS_gs_TrackBar,
    ciMultiInstance, tmApartment);
  TAutoObjectFactory.Create(ComServer, TwrpCustomUpDown, CLASS_gs_CustomUpDown,
    ciMultiInstance, tmApartment);
*)

  RegisterGdcOLEClass(TMouse, TwrpMouse, ComServer.TypeLib, IID_IgsMouse);
  RegisterGdcOLEClass(TList, TwrpList, ComServer.TypeLib, IID_IgsList);
  RegisterGdcOLEClass(TControl, TwrpControl, ComServer.TypeLib, IID_IgsControl);
  RegisterGdcOLEClass(TWinControl, TwrpWinControl, ComServer.TypeLib, IID_IgsWinControl);
  RegisterGdcOLEClass(TGraphicControl, TwrpGraphicControl, ComServer.TypeLib, IID_IgsGraphicControl);
  RegisterGdcOLEClass(TCustomForm, TwrpCustomForm, ComServer.TypeLib, IID_IgsCustomForm);

  RegisterGdcOLEClass(TLabel, TwrpLabel, ComServer.TypeLib, IID_IgsLabel);
  RegisterGdcOLEClass(TButton, TwrpButton, ComServer.TypeLib, IID_IgsButton);
  RegisterGdcOLEClass(TDataSet, TwrpDataSet, ComServer.TypeLib, IID_IgsDataSet);
  RegisterGdcOLEClass(TIBCustomDataSet, TwrpIBCustomDataSet, ComServer.TypeLib, IID_IgsIBCustomDataSet);
  RegisterGdcOLEClass(TForm, TwrpForm, ComServer.TypeLib, IID_IgsForm);
  RegisterGdcOLEClass(TForm, TwrpForm, ComServer.TypeLib, IID_IgsForm);

  RegisterGdcOLEClass(TFrame, TwrpFrame, ComServer.TypeLib, IID_IgsFrame);
  RegisterGdcOLEClass(TMainMenu, TwrpMainMenu, ComServer.TypeLib, IID_IgsMainMenu);
  RegisterGdcOLEClass(TPopupMenu, TwrpPopupMenu, ComServer.TypeLib, IID_IgsPopupMenu);
  RegisterGdcOLEClass(TEdit, TwrpEdit, ComServer.TypeLib, IID_IgsEdit);
  RegisterGdcOLEClass(TMemo, TwrpMemo, ComServer.TypeLib, IID_IgsMemo);
  RegisterGdcOLEClass(TCheckBox, TwrpCheckBox, ComServer.TypeLib, IID_IgsCheckBox);
  RegisterGdcOLEClass(TRadioButton, TwrpRadioButton, ComServer.TypeLib, IID_IgsRadioButton);
  RegisterGdcOLEClass(TListBox, TwrpListBox, ComServer.TypeLib, IID_IgsListBox);
  RegisterGdcOLEClass(TComboBox, TwrpComboBox, ComServer.TypeLib, IID_IgsComboBox);
  RegisterGdcOLEClass(TScrollBar, TwrpScrollBar, ComServer.TypeLib, IID_IgsScrollBar);
  RegisterGdcOLEClass(TGroupBox, TwrpGroupBox, ComServer.TypeLib, IID_IgsGroupBox);
  RegisterGdcOLEClass(TRadioGroup, TwrpRadioGroup, ComServer.TypeLib, IID_IgsRadioGroup);
  RegisterGdcOLEClass(TPanel, TwrpPanel, ComServer.TypeLib, IID_IgsPanel);
  RegisterGdcOLEClass(TgsPanel, TwrpgsPanel, ComServer.TypeLib, IID_IgsgsPanel);
  RegisterGdcOLEClass(TActionList, TwrpActionList, ComServer.TypeLib, IID_IgsActionList);
  RegisterGdcOLEClass(TMenuItem, TwrpMenuItem, ComServer.TypeLib, IID_IgsMenuItem);
  RegisterGdcOLEClass(TIBTransaction, TwrpIBTransaction, ComServer.TypeLib, IID_IgsIBTransaction);
  RegisterGdcOLEClass(TDataSet, TwrpDataSet, ComServer.TypeLib, IID_IgsDataSet);
  RegisterGdcOLEClass(TDataSource, TwrpDataSource, ComServer.TypeLib, IID_IgsDataSource);
  RegisterGdcOLEClass(TStringList, TwrpStringList, ComServer.TypeLib, IID_IgsStringList);
  RegisterGdcOLEClass(TContainedAction, TwrpContainedAction, ComServer.TypeLib, IID_IgsContainedAction);
  RegisterGdcOLEClass(TCustomAction, TwrpCustomAction, ComServer.TypeLib, IID_IgsCustomAction);
  RegisterGdcOLEClass(TMenu, TwrpMenu, ComServer.TypeLib, IID_IgsMenu);


  RegisterGdcOLEClass(TIBDataSet, TwrpIBDataSet, ComServer.TypeLib, IID_IgsIBDataSet);

  RegisterGdcOLEClass(TBevel, TwrpBevel, ComServer.TypeLib, IID_IgsBevel);
  RegisterGdcOLEClass(TCheckListBox, TwrpCheckListBox, ComServer.TypeLib, IID_IgsCheckListBox);
  RegisterGdcOLEClass(TPageControl, TwrpPageControl, ComServer.TypeLib, IID_IgsPageControl);
  RegisterGdcOLEClass(TBitBtn, TwrpBitBtn, ComServer.TypeLib, IID_IgsBitBtn);
  RegisterGdcOLEClass(TSpeedButton, TwrpSpeedButton, ComServer.TypeLib, IID_IgsSpeedButton);
  RegisterGdcOLEClass(TSplitter, TwrpSplitter, ComServer.TypeLib, IID_IgsSplitter);
  RegisterGdcOLEClass(TStaticText, TwrpStaticText, ComServer.TypeLib, IID_IgsStaticText);
  RegisterGdcOLEClass(TStatusBar, TwrpStatusBar, ComServer.TypeLib, IID_IgsStatusBar);
  RegisterGdcOLEClass(TStringGrid, TwrpStringGrid, ComServer.TypeLib, IID_IgsStringGrid);
  RegisterGdcOLEClass(TTreeView, TwrpTreeView, ComServer.TypeLib, IID_IgsTreeView);
  RegisterGdcOLEClass(TListView, TwrpListView, ComServer.TypeLib, IID_IgsListView);
  RegisterGdcOLEClass(TStrings, TwrpStrings, ComServer.TypeLib, IID_IgsStrings);

  RegisterGdcOLEClass(TDBCheckBox, TwrpDBCheckBox, ComServer.TypeLib, IID_IgsDBCheckBox);
  RegisterGdcOLEClass(TDBComboBox, TwrpDBComboBox, ComServer.TypeLib, IID_IgsDBComboBox);
  RegisterGdcOLEClass(TDBEdit, TwrpDBEdit, ComServer.TypeLib, IID_IgsDBEdit);
  RegisterGdcOLEClass(TDBImage, TwrpDBImage, ComServer.TypeLib, IID_IgsDBImage);
  RegisterGdcOLEClass(TJvDBImage, TwrpDBImage, ComServer.TypeLib, IID_IgsDBImage);
  RegisterGdcOLEClass(TDBListBox, TwrpDBListBox, ComServer.TypeLib, IID_IgsDBListBox);
  RegisterGdcOLEClass(TDBMemo, TwrpDBMemo, ComServer.TypeLib, IID_IgsDBMemo);
  RegisterGdcOLEClass(TDBNavigator, TwrpDBNavigator, ComServer.TypeLib, IID_IgsDBNavigator);
  RegisterGdcOLEClass(TDBRadioGroup, TwrpDBRadioGroup, ComServer.TypeLib, IID_IgsDBRadioGroup);
  RegisterGdcOLEClass(TDBRichEdit, TwrpDBRichEdit, ComServer.TypeLib, IID_IgsDBRichEdit);
  RegisterGdcOLEClass(TDBText, TwrpDBText, ComServer.TypeLib, IID_IgsDBText);

  RegisterGdcOLEClass(TIBSQL, TwrpIBSQL, ComServer.TypeLib, IID_IgsIBSQL);
  RegisterGdcOLEClass(TClientDataSet, TwrpClientDataSet, ComServer.TypeLib, IID_IgsClientDataSet);
  RegisterGdcOLEClass(TIBDatabaseInfo, TwrpIBDatabaseInfo, ComServer.TypeLib, IID_IgsIBDatabaseInfo);
  RegisterGdcOLEClass(TIBEvents, TwrpIBEvents, ComServer.TypeLib, IID_IgsIBEvents);
  RegisterGdcOLEClass(TIBDatabase, TwrpIBDatabase, ComServer.TypeLib, IID_IgsIBDatabase);
  RegisterGdcOLEClass(TIBExtract, TwrpIBExtract, ComServer.TypeLib, IID_IgsIBExtract);
  RegisterGdcOLEClass(TIBQuery, TwrpIBQuery, ComServer.TypeLib, IID_IgsIBQuery);
  RegisterGdcOLEClass(TIBStoredProc, TwrpIBStoredProc, ComServer.TypeLib, IID_IgsIBStoredProc);
  RegisterGdcOLEClass(TIBTable, TwrpIBTable, ComServer.TypeLib, IID_IgsIBTable);
  RegisterGdcOLEClass(TIBUpdateSQL, TwrpIBUpdateSQL, ComServer.TypeLib, IID_IgsIBUpdateSQL);
  RegisterGdcOLEClass(THeaderControl, TwrpHeaderControl, ComServer.TypeLib, IID_IgsHeaderControl);
  RegisterGdcOLEClass(THotKey, TwrpHotKey, ComServer.TypeLib, IID_IgsHotKey);
  RegisterGdcOLEClass(TCustomImageList, TwrpCustomImageList, ComServer.TypeLib, IID_IgsCustomImageList);
  RegisterGdcOLEClass(TDragImageList, TwrpDragImageList, ComServer.TypeLib, IID_IgsDragImageList);
  RegisterGdcOLEClass(TCustomOutline, TwrpCustomOutline, ComServer.TypeLib, IID_IgsCustomOutline);
  RegisterGdcOLEClass(TTimer, TwrpTimer, ComServer.TypeLib, IID_IgsTimer);
  RegisterGdcOLEClass(TAnimate, TwrpAnimate, ComServer.TypeLib, IID_IgsAnimate);
  RegisterGdcOLEClass(TDirectoryListBox, TwrpDirectoryListBox, ComServer.TypeLib, IID_IgsDirectoryListBox);
  RegisterGdcOLEClass(TColorGrid, TwrpColorGrid, ComServer.TypeLib, IID_IgsColorGrid);
  RegisterGdcOLEClass(TCustomControlBar, TwrpCustomControlBar, ComServer.TypeLib, IID_IgsCustomControlBar);
  RegisterGdcOLEClass(TToolWindow, TwrpToolWindow, ComServer.TypeLib, IID_IgsToolWindow);
  RegisterGdcOLEClass(TCoolBar, TwrpCoolBar, ComServer.TypeLib, IID_IgsCoolBar);
  RegisterGdcOLEClass(TDateTimePicker, TwrpDateTimePicker, ComServer.TypeLib, IID_IgsDateTimePicker);
  RegisterGdcOLEClass(TCustomGrid, TwrpCustomGrid, ComServer.TypeLib, IID_IgsCustomGrid);
  RegisterGdcOLEClass(TDrawGrid, TwrpDrawGrid, ComServer.TypeLib, IID_IgsDrawGrid);
  RegisterGdcOLEClass(TDriveComboBox, TwrpDriveComboBox, ComServer.TypeLib, IID_IgsDriveComboBox);
  RegisterGdcOLEClass(TCustomListBox, TwrpCustomListBox, ComServer.TypeLib, IID_IgsCustomListBox);
  RegisterGdcOLEClass(TFileListBox, TwrpFileListBox, ComServer.TypeLib, IID_IgsFileListBox);
  RegisterGdcOLEClass(TFilterComboBox, TwrpFilterComboBox, ComServer.TypeLib, IID_IgsFilterComboBox);
  RegisterGdcOLEClass(TGauge, TwrpGauge, ComServer.TypeLib, IID_IgsGauge);
  RegisterGdcOLEClass(TImage, TwrpImage, ComServer.TypeLib, IID_IgsImage);
  RegisterGdcOLEClass(TJPEGImage, TwrpJPEGImage, ComServer.TypeLib, IID_IgsJPEGImage);
  RegisterGdcOLEClass(TMaskEdit, TwrpMaskEdit, ComServer.TypeLib, IID_IgsMaskEdit);
  RegisterGdcOLEClass(TCustomMaskEdit, TwrpCustomMaskEdit, ComServer.TypeLib, IID_IgsCustomMaskEdit);
  RegisterGdcOLEClass(TPageScroller, TwrpPageScroller, ComServer.TypeLib, IID_IgsPageScroller);
  RegisterGdcOLEClass(TProgressBar, TwrpProgressBar, ComServer.TypeLib, IID_IgsProgressBar);
  RegisterGdcOLEClass(TCustomRichEdit, TwrpCustomRichEdit, ComServer.TypeLib, IID_IgsCustomRichEdit);
  RegisterGdcOLEClass(TScrollBox, TwrpScrollBox, ComServer.TypeLib, IID_IgsScrollBox);
  RegisterGdcOLEClass(TShape, TwrpShape, ComServer.TypeLib, IID_IgsShape);
  RegisterGdcOLEClass(TSpinButton, TwrpSpinButton, ComServer.TypeLib, IID_IgsSpinButton);
  RegisterGdcOLEClass(TSpinEdit, TwrpSpinEdit, ComServer.TypeLib, IID_IgsSpinEdit);
  RegisterGdcOLEClass(TCustomTabControl, TwrpCustomTabControl, ComServer.TypeLib, IID_IgsCustomTabControl);
  RegisterGdcOLEClass(TToolBar, TwrpToolBar, ComServer.TypeLib, IID_IgsToolBar);
  RegisterGdcOLEClass(TTrackBar, TwrpTrackBar, ComServer.TypeLib, IID_IgsTrackBar);
  RegisterGdcOLEClass(TCustomUpDown, TwrpCustomUpDown, ComServer.TypeLib, IID_IgsCustomUpDown);

  RegisterGdcOLEClass(TCanvas, TwrpCanvas, ComServer.TypeLib, IID_IgsCanvas);
  RegisterGdcOLEClass(TGraphic, TwrpGraphic, ComServer.TypeLib, IID_IgsGraphic);
  RegisterGdcOLEClass(TPicture, TwrpPicture, ComServer.TypeLib, IID_IgsPicture);
  RegisterGdcOLEClass(Graphics.TBitmap, TwrpBitmap, ComServer.TypeLib, IID_IgsBitmap);

  RegisterGdcOLEClass(TStream, TwrpStream, ComServer.TypeLib, IID_IgsStream);
  RegisterGdcOLEClass(TCustomMemoryStream, TwrpCustomMemoryStream, ComServer.TypeLib, IID_IgsCustomMemoryStream);
  RegisterGdcOLEClass(TMemoryStream, TwrpMemoryStream, ComServer.TypeLib, IID_IgsMemoryStream);

  RegisterGdcOLEClass(TApplication, TwrpApplication, ComServer.TypeLib, IID_IgsApplication);
  RegisterGdcOLEClass(TOpenDialog, TwrpOpenDialog, ComServer.TypeLib, IID_IgsOpenDialog);
  RegisterGdcOLEClass(TSaveDialog, TwrpSaveDialog, ComServer.TypeLib, IID_IgsSaveDialog);

  RegisterGdcOLEClass(TFields, TwrpFields, ComServer.TypeLib, IID_IgsFields);
  RegisterGdcOLEClass(TSizeConstraints, TwrpSizeConstraints, ComServer.TypeLib, IID_IgsSizeConstraints);
  RegisterGdcOLEClass(TDragObject, TwrpDragObject, ComServer.TypeLib, IID_IgsDragObject);
  RegisterGdcOLEClass(TBaseDragControlObject, TwrpBaseDragControlObject, ComServer.TypeLib, IID_IgsBaseDragControlObject);
  RegisterGdcOLEClass(TDragDockObject, TwrpDragDockObject, ComServer.TypeLib, IID_IgsDragDockObject);
  RegisterGdcOLEClass(TObjectField, TwrpObjectField, ComServer.TypeLib, IID_IgsObjectField);
  RegisterGdcOLEClass(TDataSetField, TwrpDataSetField, ComServer.TypeLib, IID_IgsDataSetField);
  RegisterGdcOLEClass(TNamedItem, TwrpNamedItem, ComServer.TypeLib, IID_IgsNamedItem);
  RegisterGdcOLEClass(TFieldDef, TwrpFieldDef, ComServer.TypeLib, IID_IgsFieldDef);
  RegisterGdcOLEClass(TFlatList, TwrpFlatList, ComServer.TypeLib, IID_IgsFlatList);
  RegisterGdcOLEClass(TFieldDefList, TwrpFieldDefList, ComServer.TypeLib, IID_IgsFieldDefList);

  RegisterGdcOLEClass(TOwnedCollection, TwrpOwnedCollection, ComServer.TypeLib, IID_IgsOwnedCollection);
  RegisterGdcOLEClass(TDefCollection, TwrpDefCollection, ComServer.TypeLib, IID_IgsDefCollection);
  RegisterGdcOLEClass(TFieldDefs, TwrpFieldDefs, ComServer.TypeLib, IID_IgsFieldDefs);
  RegisterGdcOLEClass(TFieldList, TwrpFieldList, ComServer.TypeLib, IID_IgsFieldList);
  RegisterGdcOLEClass(TControlScrollBar, TwrpControlScrollBar, ComServer.TypeLib, IID_IgsControlScrollBar);
  RegisterGdcOLEClass(TOLEControl, TwrpOLEControl, ComServer.TypeLib, IID_IgsOLEControl);
  RegisterGdcOLEClass(TWebBrowser, TwrpWebBrowser, ComServer.TypeLib, IID_IgsWebBrowser);
  RegisterGdcOLEClass(TMonitor, TwrpMonitor, ComServer.TypeLib, IID_IgsMonitor);
  RegisterGdcOLEClass(TFont, TwrpFont, ComServer.TypeLib, IID_IgsFont);
  RegisterGdcOLEClass(TColumnTitle, TwrpColumnTitle, ComServer.TypeLib, IID_IgsColumnTitle);
  RegisterGdcOLEClass(TColumn, TwrpColumn, ComServer.TypeLib, IID_IgsColumn);
  RegisterGdcOLEClass(TDBGridColumns, TwrpDBGridColumns, ComServer.TypeLib, IID_IgsDBGridColumns);
  RegisterGdcOLEClass(TFiler, TwrpFiler, ComServer.TypeLib, IID_IgsFiler);
  RegisterGdcOLEClass(TReader, TwrpReader, ComServer.TypeLib, IID_IgsReader);
  RegisterGdcOLEClass(TWriter, TwrpWriter, ComServer.TypeLib, IID_IgsWriter);
  RegisterGdcOLEClass(TDataLink, TwrpDataLink, ComServer.TypeLib, IID_IgsDataLink);
  RegisterGdcOLEClass(TGridDataLink, TwrpGridDataLink, ComServer.TypeLib, IID_IgsGridDataLink);
  RegisterGdcOLEClass(TObjectList, TwrpObjectList, ComServer.TypeLib, IID_IgsObjectList);
  RegisterGdcOLEClass(TTreeNode, TwrpTreeNode, ComServer.TypeLib, IID_IgsTreeNode);
  RegisterGdcOLEClass(TTreeNodes, TwrpTreeNodes, ComServer.TypeLib, IID_IgsTreeNodes);
  RegisterGdcOLEClass(TStringStream, TwrpStringStream, ComServer.TypeLib, IID_IgsStringStream);
  RegisterGdcOLEClass(TBasicAction, TwrpBasicAction, ComServer.TypeLib, IID_IgsBasicAction);
  RegisterGdcOLEClass(TBookmarkList, TwrpBookmarkList, ComServer.TypeLib, IID_IgsBookmarkList);
  RegisterGdcOLEClass(TBasicActionLink, TwrpBasicActionLink, ComServer.TypeLib, IID_IgsBasicActionLink);
  RegisterGdcOLEClass(TIBBase, TwrpIBBase, ComServer.TypeLib, IID_IgsIBBase);
  RegisterGdcOLEClass(TTabSheet, TwrpTabSheet, ComServer.TypeLib, IID_IgsTabSheet);
  RegisterGdcOLEClass(TStatusPanels, TwrpStatusPanels, ComServer.TypeLib, IID_IgsStatusPanels);
  RegisterGdcOLEClass(TStatusPanel, TwrpStatusPanel, ComServer.TypeLib, IID_IgsStatusPanel);
  RegisterGdcOLEClass(TListColumn, TwrpListColumn, ComServer.TypeLib, IID_IgsListColumn);
  RegisterGdcOLEClass(TListItem, TwrpListItem, ComServer.TypeLib, IID_IgsListItem);
  RegisterGdcOLEClass(TListItems, TwrpListItems, ComServer.TypeLib, IID_IgsListItems);
  RegisterGdcOLEClass(TIBGeneratorField, TwrpIBGeneratorField, ComServer.TypeLib, IID_IgsIBGeneratorField);
  RegisterGdcOLEClass(TIBBatch, TwrpIBBatch, ComServer.TypeLib, IID_IgsIBBatch);
  RegisterGdcOLEClass(TIBBatchInput, TwrpIBBatchInput, ComServer.TypeLib, IID_IgsIBBatchInput);
  RegisterGdcOLEClass(TIBBatchOutput, TwrpIBBatchOutput, ComServer.TypeLib, IID_IgsIBBatchOutput);
  RegisterGdcOLEClass(TPen, TwrpPen, ComServer.TypeLib, IID_IgsPen);
  RegisterGdcOLEClass(TTextAttributes, TwrpTextAttributes, ComServer.TypeLib, IID_IgsTextAttributes);
  RegisterGdcOLEClass(TParaAttributes, TwrpParaAttributes, ComServer.TypeLib, IID_IgsParaAttributes);
  RegisterGdcOLEClass(TCheckConstraint, TwrpCheckConstraint, ComServer.TypeLib, IID_IgsCheckConstraint);
  RegisterGdcOLEClass(TCheckConstraints, TwrpCheckConstraints, ComServer.TypeLib, IID_IgsCheckConstraints);
  RegisterGdcOLEClass(TParams, TwrpParams, ComServer.TypeLib, IID_IgsParams);
  RegisterGdcOLEClass(TIndexDefs, TwrpIndexDefs, ComServer.TypeLib, IID_IgsIndexDefs);
  RegisterGdcOLEClass(TIndexDef, TwrpIndexDef, ComServer.TypeLib, IID_IgsIndexDef);
  RegisterGdcOLEClass(TIcon, TwrpIcon, ComServer.TypeLib, IID_IgsIcon);
  RegisterGdcOLEClass(TChangeLink, TwrpChangeLink, ComServer.TypeLib, IID_IgsChangeLink);
  RegisterGdcOLEClass(THeaderSections, TwrpHeaderSections, ComServer.TypeLib, IID_IgsHeaderSections);
  RegisterGdcOLEClass(THeaderSection, TwrpHeaderSection, ComServer.TypeLib, IID_IgsHeaderSection);
  RegisterGdcOLEClass(TOutlineNode, TwrpOutlineNode, ComServer.TypeLib, IID_IgsOutlineNode);
  RegisterGdcOLEClass(TOutline, TwrpOutline, ComServer.TypeLib, IID_IgsOutline);
  RegisterGdcOLEClass(THandleStream, TwrpHandleStream, ComServer.TypeLib, IID_IgsHandleStream);
  RegisterGdcOLEClass(TFileStream, TwrpFileStream, ComServer.TypeLib, IID_IgsFileStream);
  RegisterGdcOLEClass(TMetafile, TwrpMetafile, ComServer.TypeLib, IID_IgsMetafile);
  RegisterGdcOLEClass(TScreen, TwrpScreen, ComServer.TypeLib, IID_IgsScreen);
  RegisterGdcOLEClass(TDataModule, TwrpDataModule, ComServer.TypeLib, IID_IgsDataModule);
  RegisterGdcOLEClass(TScrollingWinControl, TwrpScrollingWinControl, ComServer.TypeLib, IID_IgsScrollingWinControl);
  RegisterGdcOLEClass(TBrush, TwrpBrush, ComServer.TypeLib, IID_IgsBrush);
  RegisterGdcOLEClass(TIBDataSetUpdateObject, TwrpIBDataSetUpdateObject, ComServer.TypeLib, IID_IgsIBDataSetUpdateObject);
  RegisterGdcOLEClass(TAggregate, TwrpAggregate, ComServer.TypeLib, IID_IgsAggregate);
  RegisterGdcOLEClass(TAggregates, TwrpAggregates, ComServer.TypeLib, IID_IgsAggregates);
  RegisterGdcOLEClass(TPrinter, TwrpPrinter, ComServer.TypeLib, IID_IgsPrinter);
  RegisterGdcOLEClass(TfrAcctAnalytics, TwrpfrAcctAnalytics, ComServer.TypeLib, IID_IgsfrAcctAnalytics);
  RegisterGdcOLEClass(TCommonCalendar, TwrpCommonCalendar, ComServer.TypeLib, IID_IgsCommonCalendar);
  RegisterGdcOLEClass(TgsPeriodEdit, TwrpPeriodEdit, ComServer.TypeLib, IID_IgsPeriodEdit);
end.
