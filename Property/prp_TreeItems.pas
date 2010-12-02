
unit prp_TreeItems;

interface

uses
  Forms, classes, evt_Base, comctrls, mtd_Base, gdcBaseInterface;

type
  //типы нодов дерева
  TTreeItemType = (tiMacrosFolder, tiMacros, tiReportFolder, tiReport,
    tiReportFunction, tiReportTemplate, tiVBClassFolder, tiVBClass, tiConstFolder,
    tiConst, tiGDCClassFolder, tiGDCClass, tiMethod, tiObjectFolder, tiForm, tiObject,
    tiEvent, tiSFFolder, tiSF, tiGlobalObjectFolder, tiGlobalObject, tiUnknown);
  sfTypes = (sfMacros, sfReport, sfEvent, sfMethod, sfUnknown);

//значения ид папок
const
  idAppReportRootFolder = -1;
  idSFFoulder = - 2;
  idVBClassFolder = - 3;
  idConstFolder = - 4;
  idGDCClassFolder = - 5;
  idObjectFolder = - 6;
  idGlobalObjectFolder = -7;
  idMacrosRootFolder = - 8;
  idObjectReportRootFolder = -9;

type
  TCustomTreeItem = class
  private
    FMainOwnerName: string;
    procedure SetMainOwnerName(const Value: string);
  protected
    FOwnerId: Integer;
    FId: Integer;
    FEditorFrame: TFrame;
    FName: string;
    FItemType: TTreeItemType;
    FNode: TTreeNode;
    procedure SetEditorFrame(const Value: TFrame);
    procedure SetId(const Value: Integer); virtual;
    procedure SetOwnerId(const Value: Integer);
    procedure SetName(const Value: string);
    procedure SetItemType(const Value: TTreeItemType);
    procedure SetNode(const Value: TTreeNode);
  public
    constructor Create; virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    property Id: Integer read FId write SetId;
    property OwnerId: Integer read FOwnerId write SetOwnerId;
    property EditorFrame: TFrame read FEditorFrame write SetEditorFrame;
    property Name: string read FName write SetName;
    property ItemType: TTreeItemType read FItemType write SetItemType;
    property Node: TTreeNode read FNode write SetNode;
    property MainOwnerName: string read FMainOwnerName write SetMainOwnerName;
  end;

  TMacrosTreeItem = class(TCustomTreeItem)
  private
    FMacrosFolderId: Integer;
    procedure SetMacrosFolderId(const Value: Integer);
  public
    constructor Create; override;
    property MacrosFolderId: Integer read FMacrosFolderId write SetMacrosFolderId;
  end;

  TReportTreeItem = class(TCustomTreeItem)
  private
    FReportFolderId: Integer;
    procedure SetReportFolderId(const Value: Integer);
  public
    constructor Create; override;
    property ReportFolderId: Integer read FReportFolderId write SetReportFolderId;
  end;

  TReportFunctionTreeItem = class(TCustomTreeItem)
  public
    constructor Create; override;
  end;

  TReportTemplateTreeItem = class(TCustomTreeItem)
  public
    constructor Create; override;
  end;

  TVBClassTreeItem = class(TCustomTreeItem)
  public
    constructor Create; override;
  end;

  TConstTreeItem = class(TCustomTreeItem)
  public
    constructor Create; override;
  end;

  TObjectTreeItem = class;

  TEventTreeItem = class(TCustomTreeItem)
  private
    FObjectItem: TObjectTreeItem;
    procedure SetObjectItem(const Value: TObjectTreeItem);
  protected
    FEventItem: TEventItem;
    procedure SetEventItem(const Value: TEventItem);
    procedure SetId(const Value: Integer); override;
  public
    constructor Create; override;
    property EventItem: TEventItem read FEventItem write SetEventItem;
    property ObjectItem: TObjectTreeItem read FObjectItem write SetObjectItem;
  end;

  TgdcClassTreeItem = class;
  TMethodTreeItem = class(TCustomTreeItem)
  private
    FClassItem: TgdcClassTreeItem;
    FTheMethod: TMethodItem;
    procedure SetClassItem(const Value: TgdcClassTreeItem);
    procedure SetTheMethod(const Value: TMethodItem);
  protected
    procedure SetId(const Value: Integer); override;
  public
    constructor Create; override;
    property TheMethod: TMethodItem read FTheMethod write SetTheMethod;
    property ClassItem: TgdcClassTreeItem read FClassItem write SetClassItem;
  end;

  TSFTreeItem = class(TCustomTreeItem)
  private
    FSFType: sfTypes;
    procedure SetSFType(const Value: sfTypes);
  public
    constructor Create; override;
    property SFType: sfTypes read FSFType write SetSFType;
  end;

  TGlobalObjectTreeItem = class(TCustomTreeItem)
  public
    constructor Create; override;
  end;

  TCustomTreeFolder = class(TCustomTreeItem)
  private
    FParent: TCustomTreeFolder;
    FChildsCreated: Boolean;
    procedure SetParent(const Value: TCustomTreeFolder);
    procedure SetChildsCreated(const Value: Boolean);
  public
    constructor Create; override; abstract;
    property Parent: TCustomTreeFolder read FParent write SetParent;
    property ChildsCreated: Boolean read FChildsCreated write SetChildsCreated;
  end;

  TMacrosTreeFolder = class(TCustomTreeFolder)
  public
    constructor Create; override;
  end;

  TReportTreeFolder = class(TCustomTreeFolder)
  public
    constructor Create; override;
  end;

  TVBClassTreeFolder = class(TCustomTreeFolder)
  public
    constructor Create; override;
  end;

  TConstTreeFolder = class(TCustomTreeFolder)
  public
    constructor Create; override;
  end;

  TGDCClassTreeFolder = class(TCustomTreeFolder)
  public
    constructor Create; override;
  end;

  TObjectTreeFolder = class(TCustomTreeFolder)
  public
    constructor Create; override;
  end;

  TObjectTreeItem = class(TCustomTreeFolder)
  private
    FEventObject: TEventObject;
    FOverloadEnevts: Integer;
    FFilteredObjects: Integer;
    FDisabledEvents: Integer;
    procedure SetEventObject(const Value: TEventObject);
    procedure SetFilteredObjects(const Value: Integer);
    procedure SetOverloadEnevts(const Value: Integer);
    procedure SetDisabledEvents(const Value: Integer);
  public
    constructor Create; override;
    property EventObject: TEventObject read FEventObject write SetEventObject;
    property DisabledEvents: Integer read FDisabledEvents write SetDisabledEvents;
    property OverloadEnevts: Integer read FOverloadEnevts write SetOverloadEnevts;
    property FilteredObjects: Integer read FFilteredObjects write SetFilteredObjects;
  end;

  TFormTreeItem = class(TObjectTreeItem)
  public
    constructor Create; override;
  end;

  TgdcClassTreeItem = class(TCustomTreeFolder)
  private
    FTheClass: TMethodClass;
    FIndex: Integer;
    FDisabledMethods: Integer;
    procedure SetTheClass(const Value: TMethodClass);
    procedure SetOverloadMethods(const Value: Integer);
    procedure SetIndex(const Value: Integer);
    function GetSubType: string;
    function GetOverloadMethods: Integer;
    function GetSubTypeComent: string;
    procedure SetDisabledMethods(const Value: Integer);
  public
    constructor Create; override;
    property TheClass: TMethodClass read FTheClass write SetTheClass;
    property OverloadMethods: Integer read GetOverloadMethods write SetOverloadMethods;
    property DisabledMethods: Integer read FDisabledMethods write SetDisabledMethods;
    property SubType: string read GetSubType;
    property SubTypeComent: string read GetSubTypeComent;
    property Index: Integer read FIndex write SetIndex; //Индекс в списке классов
  end;

  TSFTreeFolder = class(TCustomTreeFolder)
  public
    constructor Create; override;
  end;

  TGlobalObjectTreeFolder = class(TCustomTreeFolder)
  public
    constructor Create; override;
  end;

type
  TLabelStream = array[0..3] of char;
const
  LblSize = SizeOf(TLabelStream);

procedure SaveStringToStream(Stream: TStream; S: String);
function LoadStringFromStream(Stream: TStream): string;
//сохраняет метку в поток
procedure SaveLabelToStream(lb: TLabelStream; Stream: TStream);
//проверяет метку в потоке
procedure CheckLabel(const Lb: TLabelStream; const Stream: TStream);


implementation
uses prp_MessageConst, sysutils;

const
//Значения меток потока
  TreeItemLabel = 'TILS';

procedure SaveStringToStream(Stream: TStream; S: String);
var
  L: Integer;
begin
  L := Length(S);
  Stream.WriteBuffer(L, SizeOF(L));
  Stream.WriteBuffer(S[1], L);
end;

function LoadStringFromStream(Stream: TStream): string;
var
  L: Integer;
begin
  Stream.ReadBuffer(L, SizeOf(L));
  SetLength(Result, L);
  Stream.ReadBuffer(Result[1], L);
end;

procedure SaveLabelToStream(lb: TLabelStream; Stream: TStream);
begin
  Stream.WriteBuffer(Lb, LblSize);
end;

procedure CheckLabel(const Lb: TLabelStream; const Stream: TStream);
var
  LocLb: TLabelStream;
begin
  Stream.ReadBuffer(LocLb, LblSize);
  if LocLb <> Lb then
    raise Exception.Create(MSG_WRONG_DATA);
end;

{ TCustomTreeItem }

procedure TCustomTreeItem.LoadFromStream(Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  CheckLabel(TreeItemLabel, Stream);
  Stream.ReadBuffer(FId, SizeOf(FId));
  Stream.ReadBuffer(FOwnerId, SizeOf(FOwnerID));
  FName := LoadStringFromStream(Stream);
  Stream.ReadBuffer(FItemType, SizeOf(FItemType));
  FMainOwnerName := LoadStringFromStream(Stream);  
end;

procedure TCustomTreeItem.SaveToStream(Stream: TStream);
begin
  if not Assigned(Stream) then
    raise Exception.Create(MSG_STREAM_DO_NOT_INIT);

  SaveLabelToStream(TreeItemLabel, Stream);
  Stream.WriteBuffer(FId, SizeOf(FId));
  Stream.WriteBuffer(FOwnerId, SizeOf(FOwnerID));
  SaveStringToStream(Stream, FName);
  Stream.WriteBuffer(FItemType, SizeOf(FItemType));
  SaveStringToStream(Stream, FMainOwnerName);
end;

procedure TCustomTreeItem.SetEditorFrame(const Value: TFrame);
begin
  FEditorFrame := Value;
end;

procedure TCustomTreeItem.SetMainOwnerName(const Value: string);
begin
  FMainOwnerName := Value;
end;

procedure TCustomTreeItem.SetId(const Value: Integer);
begin
  FId := Value;
end;

procedure TCustomTreeItem.SetItemType(const Value: TTreeItemType);
begin
  FItemType := Value;
end;

procedure TCustomTreeItem.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TCustomTreeItem.SetNode(const Value: TTreeNode);
begin
  FNode := Value;
end;

procedure TCustomTreeItem.SetOwnerId(const Value: Integer);
begin
  FOwnerId := Value;
end;

{ TMacrosFolder }

constructor TMacrosTreeFolder.Create;
begin
  FItemType := tiMacrosFolder;
end;

{ TReportFolder }

constructor TReportTreeFolder.Create;
begin
  FItemType := tiReportFolder;
end;

{ TVBClassFolder }

constructor TVBClassTreeFolder.Create;
begin
  FItemType := tiVBClassFolder;
  FId := idVBClassFolder;
end;

{ TConstFolder }

constructor TConstTreeFolder.Create;
begin
  FItemType := tiConstFolder;
  FId := idConstFolder;
end;

{ TGDCClassFolder }

constructor TGDCClassTreeFolder.Create;
begin
  FItemType := tiGDCClassFolder;
  FId := idGDCClassFolder;
end;

{ TObjectFolder }

constructor TObjectTreeFolder.Create;
begin
  FItemType := tiObjectFolder;
  FId := idObjectFolder;
end;

{ TSFFolder }

constructor TSFTreeFolder.Create;
begin
  FItemType := tiSFFolder;
  FID := idSFFoulder;
end;

{ TGlobalObjectFolder }

constructor TGlobalObjectTreeFolder.Create;
begin
  FItemType := tiGlobalObjectFolder;
  FId := idGlobalObjectFolder;
end;

{ TMacrosTreeItem }

constructor TMacrosTreeItem.Create;
begin
  FItemType := tiMacros;
end;

procedure TMacrosTreeItem.SetMacrosFolderId(const Value: Integer);
begin
  FMacrosFolderId := Value;
end;

{ TReportTreeItem }

constructor TReportTreeItem.Create;
begin
  FItemType := tiReport; 
end;

procedure TReportTreeItem.SetReportFolderId(const Value: Integer);
begin
  FReportFolderId := Value;
end;

{ TReportFunctionTreeItem }

constructor TReportFunctionTreeItem.Create;
begin
  FItemType := tiReportFunction;
end;

{ TReportTemplateTreeItem }

constructor TReportTemplateTreeItem.Create;
begin
  FItemType := tiReportTemplate;
end;

{ TVBClassTreeItem }

constructor TVBClassTreeItem.Create;
begin
  FItemType := tiVBClass;
end;

{ TConstTreeItem }

constructor TConstTreeItem.Create;
begin
  FItemType := tiConst;
end;

{ TgdcClassTreeItem }

constructor TgdcClassTreeItem.Create;
begin
  FItemType := tiGDCClass;
end;

function TgdcClassTreeItem.GetOverloadMethods: Integer;
begin
  if assigned(TheClass) then
    Result := TheClass.SpecMethodCount
  else
    Result := 0;
end;

function TgdcClassTreeItem.GetSubType: string;
begin
  if Assigned(TheClass) then
    Result := TheClass.SubType
  else
    Result := '';  
end;

function TgdcClassTreeItem.GetSubTypeComent: string;
begin
  if Assigned(TheClass) then
    Result := TheClass.SubTypeComment
  else
    Result := '';
end;

procedure TgdcClassTreeItem.SetDisabledMethods(const Value: Integer);
begin
  FDisabledMethods := Value;
end;

procedure TgdcClassTreeItem.SetIndex(const Value: Integer);
begin
  FIndex := Value;
end;

procedure TgdcClassTreeItem.SetOverloadMethods(const Value: Integer);
begin
  if Assigned(TheClass) then TheClass.SpecMethodCount := Value;
end;

procedure TgdcClassTreeItem.SetTheClass(const Value: TMethodClass);
begin
  FTheClass := Value;
end;

{ TMethodTreeItem }

constructor TMethodTreeItem.Create;
begin
  FItemType := tiMethod;
end;

procedure TMethodTreeItem.SetClassItem(const Value: TgdcClassTreeItem);
begin
  FClassItem := Value;
end;

procedure TMethodTreeItem.SetId(const Value: Integer);
begin
  inherited;
  if Assigned(FTheMethod) then
    FTheMethod.MethodID := Value;
end;

procedure TMethodTreeItem.SetTheMethod(const Value: TMethodItem);
begin
  FTheMethod := Value;
end;

{ TEventTreeItem }

constructor TEventTreeItem.Create;
begin
  FItemType := tiEvent;
end;



procedure TEventTreeItem.SetEventItem(const Value: TEventItem);
begin
  FEventItem := Value;
end;


procedure TEventTreeItem.SetId(const Value: Integer);
begin
  inherited;
  if Assigned(FEventItem) then
    FEventItem.EventID := Value;
end;

procedure TEventTreeItem.SetObjectItem(const Value: TObjectTreeItem);
begin
  FObjectItem := Value;
end;

{ TObjectTreeItem }

constructor TObjectTreeItem.Create;
begin
  FItemType := tiObject;
end;



procedure TObjectTreeItem.SetDisabledEvents(const Value: Integer);
begin
  FDisabledEvents := Value;
end;

procedure TObjectTreeItem.SetEventObject(const Value: TEventObject);
begin
  FEventObject := Value;
end;

procedure TObjectTreeItem.SetFilteredObjects(const Value: Integer);
begin
  FFilteredObjects := Value;
end;

procedure TObjectTreeItem.SetOverloadEnevts(const Value: Integer);
begin
  FOverloadEnevts := Value;
end;

{ TSFTreeItem }

constructor TSFTreeItem.Create;
begin
  FItemType := tiSF;
end;

procedure TSFTreeItem.SetSFType(const Value: sfTypes);
begin
  FSFType := Value;
end;

{ TGlobalObjectTreeItem }

constructor TGlobalObjectTreeItem.Create;
begin
  FItemType := tiGlobalObject;
end;

{ TCustomTreeFolder }

procedure TCustomTreeFolder.SetChildsCreated(const Value: Boolean);
begin
  FChildsCreated := Value;
end;

procedure TCustomTreeFolder.SetParent(const Value: TCustomTreeFolder);
begin
  FParent := Value;
end;

{ TForm }

constructor TFormTreeItem.Create;
begin
  FItemType := tiForm;
end;

end.
