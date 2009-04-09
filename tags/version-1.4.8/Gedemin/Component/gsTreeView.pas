 {++

   Project COMPONENTS
   Copyright © 2002 by Golden Software

   Модуль

     gsTreeView.pas

   Описание

     Дерево с checkbox-ами

   Автор

     Julie

   История

     ver    date       who     what

     1.00   04.10.01   Julie   Первая версия


 --}
unit gsTreeView;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Contnrs, ActnList, Menus;

type
  TgsCustomTreeView = class(TCustomTreeView)
  private
    FWithCheckBox: Boolean;
    FSImages: TImageList;
    OldNode: TTreeNode;
    FChangeState: TTVChangedEvent;
    FSelectedDown: Boolean;
    FWithGrayChecked: Boolean;

    procedure SetWithCheckBox(const Value: Boolean);
    procedure ChangeState(Node: TTreeNode);

  protected

    procedure Check(Node: TTreeNode); virtual;
    procedure SetCheck(Node: TTreeNode; Check: Boolean); virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure KeyPress(var Key: Char); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // загружать или нет картинку GrayChecked
    property WithGrayChecked: Boolean read FWithGrayChecked write FWithGrayChecked default False;
    property WithCheckBox: Boolean read FWithCheckBox write SetWithCheckBox;
    // вызывается после изменения статуса ветви
    property OnChangeState: TTVChangedEvent read FChangeState write FChangeState;
    // переходить на ветвь по правой кнопке или нет
    property SelectedDown: Boolean read FSelectedDown write FSelectedDown default False;
  end;

  TgsTreeView = class(TgsCustomTreeView)
  published
    {}
    property Align;
    property Anchors;
    property AutoExpand;
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
    property StateImages;
    property TabOrder;
    property TabStop default True;
    property ToolTips;
    property Visible;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnCompare;
    property OnContextPopup;
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
    property Items;

    property WithCheckBox;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('gsNew', [TgsTreeView]);
end;

{
  Производит загрузку стандартных рисунокв CheckBox
}

const
 CHECK_WIDTH = 13;
 CHECK_HEIGHT = 13;
 CST_CHECKED = 1;
 CST_UNCHECKED = 2;
 CST_GRAYED = 3;
 CST_GRAYCHECKED = 4;

procedure LoadCheckBox(ABitmap: TBitmap; Checked: Integer);
var
  B: TBitmap;
  R: TRect;
begin
  B := TBitmap.Create;

  try
    B.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_CHECKBOXES));

    ABitmap.Width := CHECK_WIDTH;
    ABitmap.Height := CHECK_HEIGHT;

    case Checked of
      CST_CHECKED:  R := Rect(CHECK_WIDTH, 0, CHECK_WIDTH * 2, CHECK_HEIGHT);
      CST_UNCHECKED:  R := Rect(0, 0, 13, 13);
      CST_GRAYED: R := Rect(CHECK_WIDTH * 2, 0, CHECK_WIDTH * 3, CHECK_HEIGHT);
      CST_GRAYCHECKED: R := Rect(CHECK_WIDTH * 3, 0, CHECK_WIDTH * 4, CHECK_HEIGHT);
    end;

    ABitmap.Canvas.CopyRect(Rect(0, 0, CHECK_WIDTH, CHECK_HEIGHT), B.Canvas, R);
  finally
    B.Free;
  end;
end;

{ TgsCustomTreeView }

procedure TgsCustomTreeView.ChangeState(Node: TTreeNode);
begin
  if Assigned(FChangeState) then FChangeState(Self, Node);
end;

procedure TgsCustomTreeView.Check(Node: TTreeNode);
begin
//  if (Node.Data <> nil) then
    SetCheck(Node, Node.StateIndex <> 1);
end;

constructor TgsCustomTreeView.Create(AOwner: TComponent);
begin
  inherited;
  FSImages := TImageList.Create(nil);
  FSImages.Width := 13;
  FSImages.Height := 13;
end;

destructor TgsCustomTreeView.Destroy;
begin
  FSImages.Free;
  inherited;
end;

procedure TgsCustomTreeView.KeyPress(var Key: Char);
begin
  if Key = ' ' then
    Check(Selected);
end;

procedure TgsCustomTreeView.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

  if htOnStateIcon in GetHitTestInfoAt(X, Y) then
  begin
    Items.BeginUpdate;
    Check(Selected);
    if (not SelectedDown) and (OldNode <> nil) then
      Selected := OldNode;
    Items.EndUpdate;
  end;

end;

procedure TgsCustomTreeView.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if (not SelectedDown) and (htOnStateIcon in GetHitTestInfoAt(X, Y)) then
    OldNode := Selected
  else
    OldNode := nil;
end;

procedure TgsCustomTreeView.SetCheck(Node: TTreeNode; Check: Boolean);
  procedure SetChecked(N: TTreeNode);
  var
    NN: TTreeNode;
  begin
    NN := N.Parent;

    while (NN <> nil) and (NN.StateIndex <> 1) do
    begin
      NN.StateIndex := 3;
      NN := NN.Parent;
    end;
  end;

  procedure SetUnchecked(N: TTreeNode);
  var
    NN: TTreeNode;
    I: Integer;

  begin
    for I := 0 to N.Count - 1 do
      if N.Item[I].StateIndex <> 2 then
      begin
        N.StateIndex := 3;
        exit;
      end;

    NN := N.Parent;

    while (NN <> nil) and (NN.StateIndex <> 1) do
    begin
      for I := 0 to NN.Count - 1 do
        if NN.Item[I].StateIndex <> 2 then
          exit;

      NN.StateIndex := 2;
      NN := NN.Parent;
    end;
  end;

begin
  if {(Node.Data <> nil)}true then
  begin
    if Check then
    begin
      Node.StateIndex := 1;
      SetChecked(Node);
    end
    else
    begin
      Node.StateIndex := 2;
      SetUnChecked(Node);
    end;
  end;

  ChangeState(Node);

end;

procedure TgsCustomTreeView.SetWithCheckBox(const Value: Boolean);
var
  B: TBitMap;
begin
  FWithCheckBox := Value;
  if FWithCheckBox then
  begin
    StateImages := FSImages;
    FSImages.Clear;

    B := TBitmap.Create;
    try
      LoadCheckBox(B, CST_UNCHECKED);
      FSImages.Add(B, nil);
      LoadCheckBox(B, CST_CHECKED);
      FSImages.Add(B, nil);
      LoadCheckBox(B, CST_UNCHECKED);
      FSImages.Add(B, nil);
      LoadCheckBox(B, CST_GRAYED);
      FSImages.Add(B, nil);
      if WithGrayChecked then
      begin
        LoadCheckBox(B, CST_GRAYCHECKED);
        FSImages.Add(B, nil);
      end;
    finally
      B.Free;
    end;
  end
  else
    if StateImages = FSImages then
      StateImages := nil;
end;

end.
