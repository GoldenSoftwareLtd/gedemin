unit CheckTreeView;

interface

uses
  SysUtils, Classes, Controls, ComCtrls, Graphics;

type
  //Тип события на выбор нода
  TTVCheckEvent = procedure(Sender: TObject; Node: TTreeNode) of object;

  TCheckTreeNode = class(TTreeNode)
  private
    FChecked: Boolean;
    FShowChecked: Boolean;
    procedure SetChecked(const Value: Boolean);
    procedure SetShowChecked(const Value: Boolean);
  protected
    procedure UpdateStateIndex;
  public
    property Checked: Boolean read FChecked write SetChecked;
    property ShowChecked: Boolean read FShowChecked write SetShowChecked;
  end;

  TCheckTreeView = class(TCustomTreeView)
  private
    FSImages: TImageList;
    FWithCheck: Boolean;
    FOnCheck: TTVCheckEvent;
    procedure SetWithCheck(const Value: Boolean);
    procedure SetOnCheck(const Value: TTVCheckEvent);
  protected
    procedure CreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    function CreateNode: TTreeNode; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property AutoExpand;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind default bkNone;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property BorderWidth;
    property ChangeDelay;
    property Color;
    property Ctl3D;
    property Constraints;
    property DragKind;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property HotTrack;
    property Images;
    property Indent;
    property MultiSelect;
    property MultiSelectStyle;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property RightClickSelect;
    property RowSelect;
    property ShowButtons;
    property ShowHint;
    property ShowLines;
    property ShowRoot;
    property SortType;
//    property StateImages;
    property TabOrder;
    property TabStop default True;
    property ToolTips;
    property Visible;
    property WithCheck: Boolean read FWithCheck write SetWithCheck;
    property OnAddition;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnCheck: TTVCheckEvent read FOnCheck write SetOnCheck;
    property OnCollapsed;
    property OnCollapsing;
    property OnCompare;
    property OnContextPopup;
    property OnCreateNodeClass;
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnDblClick;
    property OnDeletion;
    property OnDragDrop;
    property OnDragOver;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnExpanding;
    property OnExpanded;
    property OnGetImageIndex;
    property OnGetSelectedIndex;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;

    { Items must be published after OnGetImageIndex and OnGetSelectedIndex }
    property Items;
  end;

implementation

uses Math;
{$R *.res}
const
 CHECK_WIDTH = 13;
 CHECK_HEIGHT = 13;
 CST_CHECKED = 1;
 CST_UNCHECKED = 2;
 CST_GRAYED = 3;
 CST_GRAYCHECKED = 4;

 CST_CHECKED_NAME = 'CHECKED';
 CST_UNCHECKED_NAME = 'UNCHECKED';
 CST_CHECKED_NEW_NAME = 'CHECKED_NEW';
 CST_UNCHECKED_NEW_NAME = 'UNCHECKED_NEW';

{ TCheckTreeView }

constructor TCheckTreeView.Create(AOwner: TComponent);
begin
  inherited;
  OnCreateNodeClass := CreateNodeClass;
end;

function TCheckTreeView.CreateNode: TTreeNode;
begin
  Result := inherited CreateNode;
  Result.StateIndex := CST_UNCHECKED;  
end;

procedure TCheckTreeView.CreateNodeClass(Sender: TCustomTreeView;
  var NodeClass: TTreeNodeClass);
begin
  NodeClass := TCheckTreeNode;
end;

procedure TCheckTreeView.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if htOnStateIcon in GetHitTestInfoAt(X, Y) then
  begin
    Items.BeginUpdate;
    TCheckTreeNode(Selected).Checked := not TCheckTreeNode(Selected).Checked;
    Items.EndUpdate;
  end;
end;

procedure TCheckTreeView.SetOnCheck(const Value: TTVCheckEvent);
begin
  FOnCheck := Value;
end;

procedure TCheckTreeView.SetWithCheck(const Value: Boolean);
var
  B: TBitmap;
begin
  FWithCheck := Value;
  if FWithCheck then
  begin
    FSImages := TImageList.Create(Self);
    StateImages := FSImages;
    FSImages.Width := CHECK_WIDTH;
    FSImages.Height := CHECK_HEIGHT;

    B := TBitmap.Create;
    try
      B.LoadFromResourceName(HInstance, CST_CHECKED_NAME);
      Assert(FSImages.Add(B, nil) > - 1, '');
      Assert(FSImages.Add(B, nil) > - 1, '');
      B.LoadFromResourceName(HInstance, CST_UNCHECKED_NAME);
      Assert(FSImages.Add(B, nil) > - 1, '');
    finally
      B.Free;
    end;
  end else
  begin
    FSImages.Free;
    StateImages := nil;
  end;
end;

{ TCheckTreeNode }

procedure TCheckTreeNode.SetChecked(const Value: Boolean);
begin
  FChecked := Value;
  if (TreeView <> nil) and Assigned(TCheckTreeView(TreeView).OnCheck) then
    TCheckTreeView(TreeView).OnCheck(TreeView, Self);
  UpdateStateIndex;
end;

procedure TCheckTreeNode.SetShowChecked(const Value: Boolean);
begin
  FShowChecked := Value;
  UpdateStateIndex;
end;

procedure TCheckTreeNode.UpdateStateIndex;
begin
  StateIndex := - 1;
  if FShowChecked then
  begin
    if FChecked then
      StateIndex := CST_CHECKED
    else
      StateIndex := CST_UNCHECKED;
  end else
    StateIndex := - 1;
end;

end.
