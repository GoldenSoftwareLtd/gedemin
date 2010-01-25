
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gsIBLargeTreeView.pas

  Abstract

    Ibterbase Database Tree View. That loads tree data gradually.

  Author

    Denis Romanovski  (06.02.2001)

  Revisions history

    1.0    06.02.2001    Dennis    Initial version.


--}

unit gsIBLargeTreeView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, IBDatabase, IBSQL;

type
  TgsIBLargeTreeView = class;


  TgsIBTreeNode = class(TTreeNode)
  private
    FID: String;
    FParent: String;

    FLB, FRB: String;

    FIsBlank: Boolean;
    FIsTopBranch: Boolean;
    FChecked: Boolean;

    procedure SetChecked(const Value: Boolean);
    function GetTreeView: TgsIBLargeTreeView;

  protected

  public
    constructor Create(AOwner: TTreeNodes);
    destructor Destroy; override;

    property ID: String read FID write FID;
    property ParentID: String read FParent write FParent;
    property LB: String read FLB write FLB;
    property RB: String read FRB write FRB;

    property IsBlank: Boolean read FIsBlank;
    property IsTopBranch: Boolean read FIsTopBranch;
    property Checked: Boolean read FChecked write SetChecked;

    property TreeView: TgsIBLargeTreeView read GetTreeView;
  end;

  TgsIBLargeTreeView = class(TCustomTreeView)
  private
    FIDField: String;
    FParentField: String;
    FListField: String;
    FOrderByField: String;

    FRelationName: String;
    FTopBranchID: String;

    FTransaction: TIBTransaction;
    FDatabase: TIBDatabase;

    FAutoLoad: Boolean;
    FStopOnCount: Integer;
    FShowTopBranch: Boolean;
    FTopBranchText: String;

    FLoaded: Boolean;
    FCheckBoxes: Boolean;
    FInternalImages: TImageList;

    FOnNewNode: TTVExpandedEvent;
    FOnCheckStateChaged: TTVExpandedEvent;
    FLBField: String;
    FRBField: String;
    FLBRBMode: Boolean;
    FCondition: String;

    procedure WMChar(var Message: TWMChar);
      message WM_Char;

    procedure SetIDField(const Value: String);
    procedure SetParentField(const Value: String);
    procedure SetRelationName(const Value: String);

    procedure SetDatabase(const Value: TIBDatabase);

    procedure SetAutoLoad(const Value: Boolean);
    procedure SetTopBranchID(const Value: String);
    procedure SetOrderByField(const Value: String);
    procedure SetListField(const Value: String);
    procedure SetStopOnCount(const Value: Integer);
    procedure SetShowTopBranch(const Value: Boolean);
    procedure SetTopBranchText(const Value: String);
    procedure SetCheckBoxes(const Value: Boolean);
    procedure SetLBField(const Value: String);
    procedure SetRBField(const Value: String);
    procedure SetLBRBMode(const Value: Boolean);

  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

    procedure Expand(Node: TTreeNode); override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    function CreateNode: TTreeNode; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure LoadFromDatabase;
    procedure Clear;
    procedure ClearCheckBoxes;

    procedure RefreshBranch(const AnID: String);
    procedure OpenBranch(AnID: String);
    function NodeByID(const AnID: String): TTreeNode;

    property Items stored False;
    property IsLoaded: Boolean read FLoaded;

  published
    property IDField: String read FIDField write SetIDField;
    property ParentField: String read FParentField write SetParentField;

    property LBField: String read FLBField write SetLBField;
    property RBField: String read FRBField write SetRBField;
    property LBRBMode: Boolean read FLBRBMode write SetLBRBMode;

    property ListField: String read FListField write SetListField;
    property OrderByField: String read FOrderByField write SetOrderByField;
    property RelationName: String read FRelationName write SetRelationName;
    property TopBranchID: String read FTopBranchID write SetTopBranchID;
    property Condition: String read FCondition write FCondition;

    property Database: TIBDatabase read FDatabase write SetDatabase;

    property AutoLoad: Boolean read FAutoLoad write SetAutoLoad;
    property StopOnCount: Integer read FStopOnCount write SetStopOnCount;
    property ShowTopBranch: Boolean read FShowTopBranch write SetShowTopBranch;
    property TopBranchText: String read FTopBranchText write SetTopBranchText;

    property CheckBoxes: Boolean read FCheckBoxes write SetCheckBoxes;

    property OnNewNode: TTVExpandedEvent read FOnNewNode write FOnNewNode;
    property OnCheckStateChaged: TTVExpandedEvent read FOnCheckStateChaged write FOnCheckStateChaged;

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
  end;

procedure Register;

implementation

  {$IFDEF LOCALIZATION}
uses
  {must be placed after Windows unit!}
  gd_localization_stub
  ;
  {$ENDIF}

{ TgsIBLargeTreeView }

const
  CHECK_WIDTH = 13;
  CHECK_HEIGHT = 13;

procedure LoadCheckBox(ABitmap: TBitmap; Checked: Boolean);
var
  B: TBitmap;
  R: TRect;
begin
  B := TBitmap.Create;

  try
    B.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_CHECKBOXES));

    ABitmap.Width := CHECK_WIDTH;
    ABitmap.Height := CHECK_HEIGHT;

    if Checked then
      R := Rect(CHECK_WIDTH, 0, CHECK_WIDTH * 2, CHECK_HEIGHT)
    else
      R := Rect(0, 0, 13, 13);

    ABitmap.Canvas.CopyRect(Rect(0, 0, CHECK_WIDTH, CHECK_HEIGHT), B.Canvas, R);
  finally
    B.Free;
  end;
end;

procedure TgsIBLargeTreeView.Clear;
begin
  Items.Clear;
  FLoaded := False;
end;

procedure TgsIBLargeTreeView.ClearCheckBoxes;
var
  I: Integer;
begin
  Items.BeginUpdate;

  for I := 0 to Items.Count - 1 do
  with (Items[I] as TgsIBTreeNode) do
    Checked := not Checked;

  Items.EndUpdate;
end;

constructor TgsIBLargeTreeView.Create(AnOwner: TComponent);
var
  B: TBitmap;
begin
  inherited;

  FIDField := 'ID';
  FParentField := 'PARENT';
  FRelationName := 'NAME';
  FTopBranchID := 'NULL';

  FLBField := 'LB';
  FRBField := 'RB';
  FLBRBMode := False;
  FCondition := '';

  FShowTopBranch := False;
  FTopBranchText := 'Все';

  FTransaction := nil;
  FDatabase := nil;

  FAutoLoad := False;
  FStopOnCount := 150;
  FCheckBoxes := False;

  FOnCheckStateChaged := nil;
  FOnNewNode := nil;

  ReadOnly := True;

  if not (csDesigning in ComponentState) then
  begin
    FInternalImages := TImageList.Create(Self);
    FInternalImages.Width := 13;
    FInternalImages.Height := 13;

    B := TBitmap.Create;
    try
      B.Width := 13;
      B.Height := 13;
      FInternalImages.Add(B, nil);

      LoadCheckBox(B, False);
      FInternalImages.Add(B, nil);

      LoadCheckBox(B, True);
      FInternalImages.Add(B, nil);
    finally
      B.Free;
    end;
  end else
    FInternalImages := nil;
end;

function TgsIBLargeTreeView.CreateNode: TTreeNode;
begin
  Result := TgsIBTreeNode.Create(Items);
end;

destructor TgsIBLargeTreeView.Destroy;
begin
  FreeAndNil(FTransaction);
  inherited;
end;

procedure TgsIBLargeTreeView.Expand(Node: TTreeNode);
var
  ibsql: TIBSQL;
  Item, SubItem: TgsIBTreeNode;
  I: Integer;
  Cond: String;
begin
  //////////////////////////////////////////////////////////////////////////////
  //  Если нужно открыть вложенную ветку
  //////////////////////////////////////////////////////////////////////////////

  if
    ([csDestroying, csLoading] * ComponentState = [])
      and
    (Node.Count = 1)
      and
    (Node[0] as TgsIBTreeNode).FIsBlank
      and
    not (Node[0] as TgsIBTreeNode).FIsTopBranch
  then begin
    ibsql := TIBSQL.Create(nil);
    try
      if not Assigned(FTransaction) then
      begin
        FTransaction := TIBTransaction.Create(nil);
        FTransaction.Defaultdatabase := FDatabase;
      end;

      ibsql.Database := FDatabase;
      ibsql.Transaction := FTransaction;

      FTransaction.Active := True;

      //////////////////////////////////////////////////////////////////////////
      //  Считываем верхний уровень
      //////////////////////////////////////////////////////////////////////////

      if FCondition > '' then
        Cond := ' AND ' + FCondition
      else
        Cond := '';

      if
        ((Node as TgsIBTreeNode).FID = FTopBranchID)
          and
        (AnsiComparetext(FTopBranchID, 'NULL') = 0)
      then begin
        if FLBRBMode then
          ibsql.SQL.Text := Format(
            'SELECT %0:s, %1:s, %2:s, %3:s, %4:s FROM %5:s WHERE %1:s IS %6:s %7:s',
            [FIDField, FParentField, FLBField, FRBField, FListField,
              FRelationName, FTopBranchID, Cond]
          )
        else
          ibsql.SQL.Text := Format(
            'SELECT %0:s, %1:s, %2:s FROM %3:s WHERE %1:s IS %4:s 5:s',
            [FIDField, FParentField, FListField, FRelationName, FTopBranchID, Cond]
          );
      end else begin
        if FLBRBMode then
          ibsql.SQL.Text := Format(
            'SELECT %0:s, %1:s, %2:s, %3:s, %4:s FROM %5:s WHERE %1:s = %6:s %7:s',
            [FIDField, FParentField, FLBField, FRBField, FListField,
              FRelationName, (Node as TgsIBTreeNode).FID, Cond]
          )
        else
          ibsql.SQL.Text := Format(
            'SELECT %0:s, %1:s, %2:s FROM %3:s WHERE %1:s = %4:s %5:s',
            [FIDField, FParentField, FListField, FRelationName,
              (Node as TgsIBTreeNode).FID, Cond]
          );
      end;

      if FOrderByField > '' then
        ibsql.SQL.Text := ibsql.SQL.Text + ' ORDER BY ' + FOrderByField;

      ibsql.ExecQuery;

      Items.BeginUpdate;
      I := 0;

      while not ibsql.EOF do
      begin
        Inc(I);

        if I = 1 then
        begin
          Item := Node[0] as TgsIBTreeNode;
          Item.FIsBlank := False;
        end else begin
          Item := Items.AddChild(Node, '') as TgsIBTreeNode;
          if FCheckBoxes then Item.StateIndex := 1;
        end;

        Item.Text := ibsql.FieldByName(FListField).AsString;
        Item.FID := ibsql.FieldByName(FIDField).AsString;
        Item.FParent := ibsql.FieldByName(FParentField).AsString;

        if FLBRBMode then
        begin
          Item.FLB := ibsql.FieldByName(FLBField).AsString;
          Item.FRB := ibsql.FieldByName(FRBField).AsString;
        end;

        if FCheckBoxes then Item.StateIndex := 1;
        if Assigned(FOnNewNode) then FOnNewNode(Self, Item);

        if
          ((Node as TgsIBTreeNode).FID <> FTopBranchID)
            and
          (I mod 500 = 0)
            and
          (MessageBox(
            Handle,
            'Добавлено 500 элементов. Продолжить?',
            'Внимание',
            MB_ICONQUESTION or MB_YESNO or MB_TASKMODAL) = ID_NO)
        then
          Break;

        ibsql.Next;
      end;

      ibsql.Close;

      //////////////////////////////////////////////////////////////////////////
      //  Проверяем нижний уровень
      //////////////////////////////////////////////////////////////////////////

      if FCondition > '' then
        Cond := ' AND ' + FCondition
      else
        Cond := '';

      ibsql.SQL.Text := Format(
        'SELECT 1 FROM RDB$DATABASE WHERE '#13#10 +
        'EXISTS(SELECT %0:s FROM %1:s WHERE %0:s = :ID %2:s)',
        [FParentField, FRelationName, Cond]
      );
      ibsql.Prepare;

      for I := Node.Count - 1 downto 0 do
      begin
        Item := Node[I] as TgsIBTreeNode;
        ibsql.Params.ByName('ID').AsString := Item.FID;
        ibsql.ExecQuery;

        if ibsql.RecordCount > 0 then
        begin
          SubItem := Items.AddChild(Item, '') as TgsIBTreeNode;
          if FCheckBoxes then SubItem.StateIndex := 1;
          SubItem.FIsBlank := True;
        end;

        ibsql.Close;
      end;

      FTransaction.Commit;
      Items.EndUpdate;
    finally
      ibsql.Free;
    end;
  end;

  inherited;
end;

procedure TgsIBLargeTreeView.Loaded;
begin
  inherited;

  if FAutoload and not (csDesigning in ComponentState) then
    LoadFromDatabase;
end;

procedure TgsIBLargeTreeView.LoadFromDatabase;
var
  ibsql: TIBSQL;
  Item, SubItem: TgsIBTreeNode;
  I: Integer;
  TopBranch: TgsIBTreeNode;
  List: TList;
  Cond: String;
begin
  if FLoaded then Exit;

  FLoaded := True;
  ibsql := TIBSQL.Create(nil);
  List := TList.Create;

  try
    if not Assigned(FTransaction) then
    begin
      FTransaction := TIBTransaction.Create(nil);
      FTransaction.Defaultdatabase := FDatabase;
    end;

    ibsql.Transaction := FTransaction;
    ibsql.Database := FDatabase;

    FTransaction.Active := True;

    ////////////////////////////////////////////////////////////////////////////
    //  Считываем верхний уровень
    ////////////////////////////////////////////////////////////////////////////

    if FCondition > '' then
      Cond := ' AND ' + FCondition
    else
      Cond := '';

    if AnsiCompareText(FTopBranchID, 'NULL') = 0 then
    begin
      if FLBRBMode then
        ibsql.SQL.Text := Format(
          'SELECT %0:s, %1:s, %2:s, %3:s, %4:s FROM %5:s WHERE %1:s IS %6:s %7:s',
          [FIDField, FParentField, FLBField, FRBField, FListField,
            FRelationName, FTopBranchID, Cond]
        )
      else
        ibsql.SQL.Text := Format(
          'SELECT %0:s, %1:s, %2:s FROM %3:s WHERE %1:s IS %4:s %5:s',
          [FIDField, FParentField, FListField, FRelationName, FTopBranchID, Cond]
        );
    end else begin
      if FLBRBMode then
        ibsql.SQL.Text := Format(
          'SELECT %0:s, %1:s, %2:s, %3:s, %4:s FROM %5:s WHERE %1:s = %6:s %7:s',
          [FIDField, FParentField, FLBField, FRBField, FListField,
            FRelationName, FTopBranchID, Cond]
        )
      else
        ibsql.SQL.Text := Format(
          'SELECT %0:s, %1:s, %2:s FROM %3:s WHERE %1:s = %4:s %5:s',
          [FIDField, FParentField, FListField, FRelationName, FTopBranchID, Cond]
        );
    end;

    if FOrderByField > '' then
      ibsql.SQL.Text := ibsql.SQL.Text + ' ORDER BY ' + FOrderByField;

    ibsql.ExecQuery;

    Items.BeginUpdate;
    Items.Clear;

    if FShowTopBranch then
    begin
      TopBranch := Items.Add(nil, FTopBranchText) as TgsIBTreeNode;
      if FCheckBoxes then TopBranch.StateIndex := 1;
      TopBranch.FIsTopBranch := True;
      TopBranch.FID := FTopBranchID;
    end else
      TopBranch := nil;

    while not ibsql.EOF do
    begin
      Item := Items.AddChild(TopBranch, '') as TgsIBTreeNode;
      Item.Text := ibsql.FieldByName(FListField).AsString;
      Item.FID := ibsql.FieldByName(FIDField).AsString;
      Item.FParent := ibsql.FieldByName(FParentField).AsString;

      if FLBRBMode then
      begin
        Item.FLB := ibsql.FieldByName(FLBField).AsString;
        Item.FRB := ibsql.FieldByName(FRBField).AsString;
      end;

      if FCheckBoxes then Item.StateIndex := 1;
      if Assigned(FOnNewNode) then FOnNewNode(Self, Item);
      List.Add(Item);

      ibsql.Next;
    end;

    ibsql.Close;

    ////////////////////////////////////////////////////////////////////////////
    //  Проверяем нижний уровень
    ////////////////////////////////////////////////////////////////////////////

    if FCondition > '' then
      Cond := ' AND ' + FCondition
    else
      Cond := '';

    ibsql.SQL.Text := Format(
      'SELECT 1 FROM RDB$DATABASE WHERE '#13#10 +
      'EXISTS(SELECT %0:s FROM %1:s WHERE %0:s = :ID %2:s)',
      [FParentField, FRelationName, Cond]
    );
    ibsql.Prepare;

    for I := 0 to List.Count - 1 do
    begin
      Item := List[I];
      if Item.FIsTopBranch or Item.FIsBlank then Continue;

      ibsql.Params.ByName('ID').AsString := Item.FID;
      ibsql.ExecQuery;

      if ibsql.RecordCount > 0 then
      begin
        SubItem := Items.AddChild(Item, '') as TgsIBTreeNode;
        if FCheckBoxes then SubItem.StateIndex := 1;
        SubItem.FIsBlank := True;
      end;

      ibsql.Close;
    end;

    FTransaction.Commit;
    Items.EndUpdate;
  finally
    ibsql.Free;
    List.Free;
  end;
end;

procedure TgsIBLargeTreeView.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: TgsIBTreeNode;  
begin
  inherited;

  if FCheckBoxes and (htOnStateIcon in GetHitTestInfoAt(X, Y)) then
  begin
    Node := GetNodeAt(X, Y) as TgsIBTreeNode;

    if Assigned(Node) then
      Node.Checked := not Node.Checked;
  end;
end;

function TgsIBLargeTreeView.NodeByID(const AnID: String): TTreeNode;
var
  I: Integer;
begin
  for I := 0 to Items.Count - 1 do
    if
      not (Items[I] as TgsIBTreeNode).FIsBlank
        and
      (AnsiCompareText((Items[I] as TgsIBTreeNode).FID, AnID) = 0)
    then begin
      Result := Items[I];
      Exit;
    end;

  Result := nil;
end;

procedure TgsIBLargeTreeView.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if Operation = opRemove then
  begin
    if AComponent = FDatabase then
      FDatabase := nil;
  end;
end;

procedure TgsIBLargeTreeView.OpenBranch(AnID: String);
var
  ibsql: TIBSQL;
  TreeBranches: array of String;
  I: Integer;
  TheID: String;
  CurrNode: TgsIBTreeNode;
  Cond: String;
begin
  ibsql := TIBSQL.Create(nil);
  Items.BeginUpdate;
  try
    if not Assigned(FTransaction) then
    begin
      FTransaction := TIBTransaction.Create(nil);
      FTransaction.Defaultdatabase := FDatabase;
    end;

    ibsql.Database := FDatabase;
    ibsql.Transaction := FTransaction;

    FTransaction.Active := True;

    //
    // Осуществляем считывание всех ветвей

    if FCondition > '' then
      Cond := ' AND ' + FCondition
    else
      Cond := '';
     
    ibsql.SQL.Text := Format(
      'SELECT %s FROM %s WHERE %s = :BRANCH %s',
      [FParentField, FRelationName, FIDField, Cond]
    );

    ibsql.Prepare;
    TheID := AnID;
    SetLength(TreeBranches, 0);

    repeat
      ibsql.Close;
      ibsql.ParamByName('BRANCH').AsString := TheID;
      ibsql.ExecQuery;

      if ibsql.RecordCount > 0 then
      begin
        SetLength(TreeBranches, Length(TreeBranches) + 1);

        if ibsql.FieldByName(FParentField).IsNull then
          TheID := 'NULL'
        else
          TheID := ibsql.FieldByName(FParentField).AsString;

        TreeBranches[Length(TreeBranches) - 1] := TheID;
      end else
        Break;
    until
      (AnsiCompareText(TheID, TopBranchID) = 0) or
      (AnsiCompareText(TheID, 'NULL') = 0);

    //
    //  Если не была считана верхняя ветка,
    //  значит невозможно построить дерево,
    //  выходим из процедуры без изменений
    //  в дереве.

    if AnsiCompareText(TheID, TopBranchID) <> 0 then
      Exit;

    for I := High(TreeBranches) downto Low(TreeBranches) do
    begin
      CurrNode := NodeByID(TreeBranches[I]) as TgsIBTreeNode;

      if Assigned(CurrNode) then
        CurrNode.Expand(False);
    end;

    CurrNode := NodeByID(AnID) as TgsIBTreeNode;
    if Assigned(CurrNode) then
      Selected := CurrNode;
  finally
    ibsql.Free;
    Items.EndUpdate;
  end;
end;

procedure TgsIBLargeTreeView.RefreshBranch(const AnID: String);
var
  Node: TgsIbTreeNode;
  BlankItem: TgsIBTreeNode;
  WasExpanded: Boolean;
begin
  Node := NodeByID(AnID) as TgsIBTreeNode;

  if Assigned(Node) then
  begin
    Items.BeginUpdate;

    WasExpanded := Node.Expanded;
    Node.Collapse(True);
    Node.DeleteChildren;
    BlankItem := Items.AddChild(Node, '') as TgsIBTreeNode;
    if FCheckBoxes then BlankItem.StateIndex := 1;
    BlankItem.FIsBlank := True;
    if WasExpanded or (Node as TgsIBTreeNode).FIsTopBranch then
      Node.Expand(False);

    Items.EndUpdate;
  end;
end;

procedure TgsIBLargeTreeView.SetAutoLoad(const Value: Boolean);
begin
  FAutoLoad := Value;
end;

procedure TgsIBLargeTreeView.SetCheckBoxes(const Value: Boolean);
begin
  if FCheckBoxes <> Value then
  begin
    FCheckBoxes := Value;

    if not (csDesigning in ComponentState) then
    begin
      if FCheckBoxes then
        StateImages := FInternalImages
      else
        StateImages := nil;

      { TODO 1 -oденис -cсделать : Установить рисунки }
    end;
  end;
end;

procedure TgsIBLargeTreeView.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if Assigned(FDatabase) then
      FDatabase.RemoveFreeNotification(Self);
    FDatabase := Value;
    if Assigned(FDatabase) then
      FDatabase.FreeNotification(Self);
    if Assigned(FTransaction) then FTransaction.DefaultDatabase :=
      FDatabase;
  end;
end;

procedure TgsIBLargeTreeView.SetIDField(const Value: String);
begin
  FIDField := Value;
end;

procedure TgsIBLargeTreeView.SetLBField(const Value: String);
begin
  FLBField := Value;
end;

procedure TgsIBLargeTreeView.SetLBRBMode(const Value: Boolean);
begin
  FLBRBMode := Value;
end;

procedure TgsIBLargeTreeView.SetListField(const Value: String);
begin
  FListField := Value;
end;

procedure TgsIBLargeTreeView.SetOrderByField(const Value: String);
begin
  FOrderByField := Value;
end;

procedure TgsIBLargeTreeView.SetParentField(const Value: String);
begin
  FParentField := Value;
end;

procedure TgsIBLargeTreeView.SetRBField(const Value: String);
begin
  FRBField := Value;
end;

procedure TgsIBLargeTreeView.SetRelationName(const Value: String);
begin
  FRelationName := Value;
end;

procedure TgsIBLargeTreeView.SetShowTopBranch(const Value: Boolean);
begin
  FShowTopBranch := Value;
end;

procedure TgsIBLargeTreeView.SetStopOnCount(const Value: Integer);
begin
  FStopOnCount := Value;
end;

procedure TgsIBLargeTreeView.SetTopBranchID(const Value: String);
begin
  FTopBranchID := Value;
end;

procedure TgsIBLargeTreeView.SetTopBranchText(const Value: String);
begin
  FTopBranchText := Value;
end;

procedure TgsIBLargeTreeView.WMChar(var Message: TWMChar);
begin
  if FCheckBoxes and (Message.CharCode = VK_SPACE) and Assigned(Selected) then
  begin
    (Selected as TgsIBTreeNode).Checked := not (Selected as TgsIBTreeNode).Checked;
    //Message.CharCode := 0;
  end else
    inherited;
end;

{ TgsIBTreeNode }

constructor TgsIBTreeNode.Create(AOwner: TTreeNodes);
begin
  inherited;

  FID := '';
  FParent := '';
  FLB := '';
  FRB := '';
  FChecked := False;
end;

destructor TgsIBTreeNode.Destroy;
begin
  inherited;
end;

function TgsIBTreeNode.GetTreeView: TgsIBLargeTreeView;
begin
  Result := inherited TreeView as TgsIBLargeTreeView;
end;

procedure TgsIBTreeNode.SetChecked(const Value: Boolean);
begin
  if (FIsBlank or FIsTopBranch) then
  begin
    StateIndex := -1;
    Exit;
  end;

  if FChecked <> Value then
  begin
    FChecked := Value;

    if (TreeView as TgsIBLargeTreeView).CheckBoxes then
    begin
      if FChecked then
        StateIndex := 2
      else
        StateIndex := 1;
    end;

    if Assigned(TreeView.FOnCheckStateChaged) then
      TreeView.FOnCheckStateChaged(TreeView, Self);
  end;
end;

{ Register }

procedure Register;
begin
  RegisterComponents('gsNew', [TgsIBLargeTreeView]);
end;

end.

