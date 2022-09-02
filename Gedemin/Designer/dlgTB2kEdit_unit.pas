// ShlTanya, 24.02.2019

unit dlgTB2kEdit_unit;
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ComCtrls, ImgList, Menus, gd_messages_const,
  TB2Item, TB2Toolbar, TB2Dock, DsgnIntf, gsResizerInterface;


type
  TdlgTB2kEdit = class(TForm)
    TreeView: TTreeView;
    ListView: TListView;
    Splitter1: TSplitter;
    Toolbar: TTBToolbar;
    NewSubmenuButton: TTBItem;
    NewItemButton: TTBItem;
    NewSepButton: TTBItem;
    TBPopupMenu1: TTBPopupMenu;
    TBItemContainer1: TTBItemContainer;
    ToolbarItems: TTBSubmenuItem;
    TBSeparatorItem2: TTBSeparatorItem;
    MoveUpButton: TTBItem;
    MoveDownButton: TTBItem;
    ItemImageList: TImageList;
    TBSeparatorItem1: TTBSeparatorItem;
    DeleteButton: TTBItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure NewSubmenuButtonClick(Sender: TObject);
    procedure NewItemButtonClick(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure DeleteButtonClick(Sender: TObject);
    procedure NewSepButtonClick(Sender: TObject);
    procedure ListViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ListViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewEnter(Sender: TObject);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure ListViewKeyPress(Sender: TObject; var Key: Char);
    procedure ListViewEnter(Sender: TObject);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TConvertMenuClick(Sender: TObject);
    procedure TreeViewKeyPress(Sender: TObject; var Key: Char);
    procedure MoveUpButtonClick(Sender: TObject);
    procedure MoveDownButtonClick(Sender: TObject);
  private
    FObjectInspectorForm: IgsObjectInspectorForm;
    FComponent: TComponent;
    FRootItem, FSelParentItem: TTBCustomItem;
    FSettingSel, FRebuildingTree, FRebuildingList: Integer;
    function AddListViewItem (const Index: Integer;
      const Item: TTBCustomItem): TListItem;
    procedure CreateNewItem (const AClass: TTBCustomItemClass);

    procedure Delete;
    procedure DeleteItem (const Item: TTBCustomItem);
    function GetItemTreeCaption (AItem: TTBCustomItem): String;
    procedure GetSelItemList (const AList: TList);
    procedure MoveItem (CurIndex, NewIndex: Integer);

    procedure RebuildList;
    procedure RebuildTree;
    procedure SelectInObjectInspector (AList: TList);
    procedure SetSelParentItem (ASelParentItem: TTBCustomItem);
    function TreeViewDragHandler (Sender, Source: TObject; X, Y: Integer;
      Drop: Boolean): Boolean;
    procedure LoadItemImage;

    procedure CMPropertyChanged(var Message: TMessage);  message CM_PROPERTYCHANGED;
  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  function ShowTB2kEditForm (AObjectInspector: IgsObjectInspectorForm; AComponent: TComponent; ARootItem: TTBCustomItem): TdlgTB2kEdit;


  procedure KillTb2kEditors;

  implementation

{$R *.DFM}

uses
  TypInfo, CommCtrl, TB2Version, TB2Common,
  {TB2DsgnConverter,} contnrs, TB2ExtItems, TB2MDI, dmImages_unit;

type
  {}TTBCustomItemAccess = class(TTBCustomItem);
  {}TControlAccess = class(TControl);
  TDesignerSelectionList = TComponentList;

  PItemClassInfo = ^TItemClassInfo;
  TItemClassInfo = record
    ItemClass: TTBCustomItemClass;
    Caption: String;
    ImageIndex: Integer;
  end;

var
  tb2kEditorsList: TObjectList = nil;

function GetItemClassImageIndex (AClass: TTBCustomItemClass): Integer;
begin
  if AClass.InheritsFrom(TTBSeparatorItem) then
    Result := 2
  else if AClass.InheritsFrom(TTBSubmenuItem) then
    Result := 1
  else
    Result := 0;
end;

procedure TdlgTB2kEdit.LoadItemImage;
var
  B: TBitmap;
  MaskColor: TColor;
begin
  B := TBitmap.Create;
  try
    dmImages.il16x16.GEtBitmap(2, B); // Delete 3
    MaskColor := B.Canvas.Pixels[0, b.Height - 1];
    ItemImageList.AddMasked(B, MaskColor);
    dmImages.il16x16.GEtBitmap(10, B); // Copy 4
    MaskColor := B.Canvas.Pixels[0, b.Height - 1];
    ItemImageList.AddMasked(B, MaskColor);
    dmImages.il16x16.GEtBitmap(9, B); // Cut 5
    MaskColor := B.Canvas.Pixels[0, b.Height - 1];
    ItemImageList.AddMasked(B, MaskColor);
    dmImages.il16x16.GEtBitmap(11, B); // Paste 6
    MaskColor := B.Canvas.Pixels[0, b.Height - 1];
    ItemImageList.AddMasked(B, MaskColor);

  finally
    B.Free;
  end;
end;

procedure KillTb2kEditors;
begin
  if Assigned(tb2kEditorsList) then
    tb2kEditorsList.Clear;
end;

function ShowTB2kEditForm (AObjectInspector: IgsObjectInspectorForm; AComponent: TComponent; ARootItem: TTBCustomItem): TdlgTB2kEdit;
var
  I: Integer;
begin
  if TB2kEditorsList = nil then
    TB2kEditorsList := TObjectList.Create;
  for I := 0 to TB2kEditorsList.Count-1 do
  begin

    Result := TdlgTB2kEdit(Tb2kEditorsList[I]);
    with Result do
      if (FObjectInspectorForm = AObjectInspector) and (FComponent = AComponent)
        and (FRootItem = ARootItem) then
      begin
        RebuildTree;
        RebuildList;

        Show;
        BringToFront;
        Exit;
      end;
  end;
  Result := TdlgTB2kEdit.Create(nil);
  with Result do
  try
    TB2kEditorsList.Add(Result);
    FComponent := AComponent;
    FRootItem := ARootItem;
    FSelParentItem := ARootItem;
    Caption := 'Редактирование ' + AComponent.Name;
    FObjectInspectorForm := AObjectInspector;
    FObjectInspectorForm.Manager.AddPropertyNotification(Result);

    RebuildTree;
    RebuildList;

    Show;
  except
    Free;
    Result := nil;
  end;
end;

function IsSubmenuItem (Item: TTBCustomItem): Boolean;
begin
  Result := tbisSubitemsEditable in TTBCustomItemAccess(Item).ItemStyle;
end;

constructor TdlgTB2kEdit.Create (AOwner: TComponent);
begin
  inherited;
  LoadItemImage;
end;


procedure TdlgTB2kEdit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TdlgTB2kEdit.FormActivate(Sender: TObject);
begin
  SetSelParentItem (FSelParentItem);
end;


function TdlgTB2kEdit.GetItemTreeCaption (AItem: TTBCustomItem): String;
begin
  if AItem <> FRootItem then begin
    Result := AItem.Caption;
    if Result = '' then
      Result := '[' + AItem.Name + ']';
  end
  else
    Result := '(Root)';
end;

procedure TdlgTB2kEdit.RebuildTree;

  procedure Recurse (const AParentItem: TTBCustomItem; const ATreeNode: TTreeNode;
    var FoundSelParentItem: TTreeNode);
  var
    I: Integer;
    NewNode: TTreeNode;
    ChildItem: TTBCustomItem;
  begin
    NewNode := TreeView.Items.AddChild(ATreeNode, GetItemTreeCaption(AParentItem));
    NewNode.Data := AParentItem;
    if AParentItem = FSelParentItem then
      FoundSelParentItem := NewNode;
    for I := 0 to AParentItem.Count-1 do begin
      ChildItem := AParentItem[I];
      if IsSubmenuItem(ChildItem) then
        Recurse (ChildItem, NewNode, FoundSelParentItem);
    end;
  end;

var
  FoundSelParentItem: TTreeNode;
begin
  Inc (FRebuildingTree);
  try
    TreeView.Items.BeginUpdate;
    try
      TreeView.Items.Clear;
      FoundSelParentItem := nil;
      Recurse (FRootItem, nil, FoundSelParentItem);
      if FoundSelParentItem = nil then
        SetSelParentItem (FRootItem)
      else
        TreeView.Selected := FoundSelParentItem;
      TreeView.Items[0].Expand (True);
    finally
      TreeView.Items.EndUpdate;
    end;
  finally
    Dec (FRebuildingTree);
  end;
end;

function TdlgTB2kEdit.AddListViewItem (const Index: Integer;
  const Item: TTBCustomItem): TListItem;
begin
  Result := ListView.Items.Insert(Index);
  Result.Data := Item;
  if not(Item is TTBControlItem) then begin
    Result.Caption := Item.Caption;
    Result.Subitems.Add (Item.ClassName);
    Result.ImageIndex := GetItemClassImageIndex(TTBCustomItemClass(Item.ClassType));
  end
  else begin
    Result.Caption := '(Control)';
    Result.Subitems.Add (Item.ClassName);
    Result.ImageIndex := -1;
  end;
end;

procedure TdlgTB2kEdit.RebuildList;
var
  ChildItem: TTBCustomItem;
  I: Integer;
begin
  Inc (FRebuildingList);
  try
    ListView.Items.BeginUpdate;
    try
      ListView.Items.Clear;
      if Assigned(FSelParentItem) then begin
        for I := 0 to FSelParentItem.Count-1 do begin
          ChildItem := FSelParentItem[I];
          { Check for csDestroying because deleting an item in the tree view
            causes the parent item to be selected, and the parent item won't
            get a notification that the item is deleting since notifications
            were already sent }
          if not(csDestroying in ChildItem.ComponentState) then
            AddListViewItem (I, ChildItem);
        end;
        { Add an empty item to the end }
        ListView.Items.Add.ImageIndex := -1;
      end;
    finally
      ListView.Items.EndUpdate;
    end;
    { Work around a strange TListView bug(?). Without this, the column header
      isn't painted properly. }
    if HandleAllocated then
      SetWindowPos (ListView.Handle, 0, 0, 0, 0, 0, SWP_FRAMECHANGED or
        SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER);
  finally
    Dec (FRebuildingList);
  end;
end;

procedure TdlgTB2kEdit.SelectInObjectInspector (AList: TList);
{var
  CompList1, CompList2: TDesignerSelectionList;
  I: Integer;
  C: TComponent;}
begin
 (* { Designer.SetSelections will make components appear selected on the form.
    It will also select the component in Object Inspector, but only if the
    form has the focus. TDesignWindow.SetSelection will select the component
    in Object Inspector regardless of whether the form has the focus. }
{  CompList1 := CreateSelectionList;
  CompList2 := CreateSelectionList;
  for I := 0 to AList.Count-1 do begin
    C := AList[I];
    { Must check for csDestroying. If SetSelection is passed a component that's
      destroying, Delphi will crash. }
    if not(csDestroying in C.ComponentState) then begin
      CompList1.Add (C);
      CompList2.Add (C);
    end;
  end;
  if CompList1.Count = 0 then begin
    CompList1.Free;
    CompList2.Free;
  end
  else begin
    Designer.SetSelections (CompList1);
    { Note: Never pass an empty list to SetSelection or Delphi will crash }
    { History here:
      - 1.34: SetSelection call remarked out because it fixed Delphi 6 issue
        with random AV's after the editor was closed.
      - 1.38: SetSelection call restored because without it, Ctrl+X/C/V didn't
        work.
      - 1.40: SetSelection call disabled on Delphi 6 only because AV problem
        still seems to exist despite another change which I thought fixed it.
        On D6 it isn't necessary to call SetSelection for Ctrl+X/C/V to work.
        Note: Using "ComponentDesigner.SetSelection (Designer, nil, CompList2);"
        instead seems to fix the AV problem, but for consistency with Delphi's
        TMainMenu editor (which only selects items when its parent form is
        focused), I decided not to call SetSelection at all on D6.
    }
    SetSelection (CompList2);
  end;*)
end;

procedure TdlgTB2kEdit.GetSelItemList (const AList: TList);
var
  ListItem: TListItem;
begin
  ListItem := nil;
  while True do begin
    ListItem := ListView.GetNextItem(ListItem, sdAll, [isSelected]);
    if ListItem = nil then
      Break;
    if Assigned(ListItem.Data) then
      AList.Add (ListItem.Data);
  end;
end;

procedure TdlgTB2kEdit.SetSelParentItem (ASelParentItem: TTBCustomItem);
{ - Rebuilds the list view to match a new selection (ASelParentItem) in the
    tree view
  - Updates toolbar
  - Selects selected item(s) into Object Inspector }
var
  TreeNode: TTreeNode;
  ItemIsSelected: Boolean;
  List: TList;
begin
  if FSettingSel > 0 then
    Exit;
  List := TList.Create;
  Inc (FSettingSel);
  try
    if FSelParentItem <> ASelParentItem then begin
      FSelParentItem := ASelParentItem;
      NewSubmenuButton.Enabled := Assigned(ASelParentItem);
      NewItemButton.Enabled := Assigned(ASelParentItem);
      NewSepButton.Enabled := Assigned(ASelParentItem);
{      for I := 0 to MoreMenu.Count-1 do
        MoreMenu[I].Enabled := Assigned(ASelParentItem);}
      if not Assigned(TreeView.Selected) or (TreeView.Selected.Data <> FSelParentItem) then begin
        if FSelParentItem = nil then
          TreeView.Selected := nil
        else begin
          TreeNode := TreeView.Items.GetFirstNode;
          while Assigned(TreeNode) do begin
            if TreeNode.Data = FSelParentItem then begin
              TreeView.Selected := TreeNode;
              Break;
            end;
            TreeNode := TreeNode.GetNext;
          end;
        end;
      end;
      RebuildList;
    end;

    ItemIsSelected := (ActiveControl = ListView) and Assigned(ListView.Selected) and
      Assigned(ListView.Selected.Data);
    if ItemIsSelected then
      GetSelItemList (List);

    DeleteButton.Enabled := ItemIsSelected or
      ((ActiveControl = TreeView) and (FSelParentItem <> FRootItem));
    MoveUpButton.Enabled := ItemIsSelected and
      (FSelParentItem.IndexOf(List.First) > 0);
    MoveDownButton.Enabled := ItemIsSelected and
      (FSelParentItem.IndexOf(List.Last) < FSelParentItem.Count-1);

    if ActiveControl = ListView then begin
      if List.Count = 0 then
        { No item was selected, or the blank item was selected.
          Select the root item so it looks like no item was selected in
          Object Inspector }
        List.Add (FRootItem);
    end
    else if not Assigned(ASelParentItem) or (ASelParentItem = FRootItem) then
      List.Add (FComponent)
    else
      List.Add (ASelParentItem);
    SelectInObjectInspector (List);
  finally
    Dec (FSettingSel);
    List.Free;
  end;
end;


procedure TdlgTB2kEdit.DeleteItem (const Item: TTBCustomItem);
begin
  if csAncestor in Item.ComponentState then
    raise EInvalidOperation.Create('Items introduced in an ancestor form cannot be deleted');
  Item.Free;
end;

procedure TdlgTB2kEdit.Delete;
var
  List: TList;
  Item: TTBCustomItem;
  ListItem: TListItem;
begin
  List := TList.Create;
  try
    List.Add (FSelParentItem);
    SelectInObjectInspector (List);
  finally
    List.Free;
  end;
  FSelParentItem.ViewBeginUpdate;
  try
    while Assigned(ListView.Selected) do begin
      Item := ListView.Selected.Data;
      if Item = nil then
        Break;
      DeleteItem (Item);
      ListView.Selected.Free;
    end;
  finally
    FSelParentItem.ViewEndUpdate;
  end;
  { After deleting the items, select the item with the focus }
  ListItem := ListView.GetNextItem(nil, sdAll, [isFocused]);
  if Assigned(ListItem) then
    ListItem.Selected := True;
end;

procedure TdlgTB2kEdit.MoveItem (CurIndex, NewIndex: Integer);
var
  WasFocused: Boolean;
begin
  WasFocused := ListView.Items[CurIndex].Focused;

  FSelParentItem.Move (CurIndex, NewIndex);

  RebuildTree;
  RebuildList;

  if WasFocused then
    ListView.Items[NewIndex].Focused := True;
  ListView.Items[NewIndex].Selected := True;


end;

procedure TdlgTB2kEdit.TreeViewChange(Sender: TObject; Node: TTreeNode);
var
  NewSelectedParentItem: TTBCustomItem;
begin
  if (FRebuildingTree > 0) or (FSettingSel > 0) then Exit;
  if Node = nil then
    NewSelectedParentItem := nil
  else
    NewSelectedParentItem := Node.Data;
  SetSelParentItem (NewSelectedParentItem);

  if TreeView.Selected <> nil then
  begin
    if TreeView.Selected.Data = FRootItem then
      FObjectInspectorForm.AddEditComponent(FComponent, False)
    else
      FObjectInspectorForm.AddEditSubComponent(TTBCustomItem(TreeView.Selected.Data));
  end;
end;

procedure TdlgTB2kEdit.TreeViewEnter(Sender: TObject);
{ When the tree view gets the focus, act as if the currently selected item
  was clicked. }
begin
  ListView.Selected := nil;
  SetSelParentItem (FSelParentItem);
end;

procedure TdlgTB2kEdit.ListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if (FRebuildingList > 0) or (FSettingSel > 0) or (Change <> ctState) or
     (csDestroying in ListView.ComponentState) then
    Exit;
  SetSelParentItem (FSelParentItem);
  if ListView.Selected <> nil then
    FObjectInspectorForm.AddEditSubComponent(TTBCustomItem(ListView.Selected.Data));
end;

procedure TdlgTB2kEdit.ListViewEnter(Sender: TObject);
begin
  { When list view gets the focus, update the toolbar }
  SetSelParentItem (FSelParentItem);
end;


procedure TdlgTB2kEdit.ListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin
        Key := 0;
//        ActivateInspector (#0);
      end;
    VK_INSERT: begin
        Key := 0;
        if ssCtrl in Shift then
          NewSubmenuButtonClick (Sender)
        else
          NewItemButtonClick (Sender);
      end;
    VK_DELETE: begin
        Key := 0;
        Delete;
      end;
  end;
end;

procedure TdlgTB2kEdit.TreeViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin
        Key := 0;
//        ActivateInspector (#0);
      end;
    VK_DELETE: begin
        Key := 0;
        DeleteButtonClick (Sender);
      end;
  end;
end;

procedure TdlgTB2kEdit.TreeViewKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in [#33..#126] then begin
//    ActivateInspector (Key);
    Key := #0;
  end
  else if Key = #13 then
    Key := #0;  { suppress beep }
end;

procedure TdlgTB2kEdit.ListViewKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '-' then begin
    NewSepButtonClick (Sender);
    Key := #0;
  end
  else if Key in [#33..#126] then begin
//    ActivateInspector (Key);
    Key := #0;
  end;
end;

procedure TdlgTB2kEdit.ListViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
{ List item dragged over the list view }
var
  Item: TListItem;
begin
  Accept := False;
  if (Sender = ListView) and (Source = ListView) and (ListView.SelCount = 1) then begin
    Item := ListView.GetItemAt(X, Y);
    if Assigned(Item) and (Item <> ListView.Selected) then
      Accept := True;
  end;
end;

procedure TdlgTB2kEdit.ListViewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
{ List item dropped onto another list item }
var
  ListItem: TListItem;
  Item: TTBCustomItem;
  NewIndex: Integer;
begin
  if (Sender = ListView) and (Source = ListView) and (ListView.SelCount = 1) then begin
    ListItem := ListView.GetItemAt(X, Y);
    if Assigned(ListItem) and (ListItem <> ListView.Selected) and Assigned(FSelParentItem) then begin
      NewIndex := FSelParentItem.IndexOf(ListItem.Data);
      if NewIndex <> -1 then begin
        ListView.Items.BeginUpdate;
        { For good performance and to prevent Object Inspector flicker, increment
          FSettingSel to prevent calls to SetSelParentItem while moving items }
        Inc (FSettingSel);
        try
          Item := ListView.Selected.Data;
          MoveItem (FSelParentItem.IndexOf(Item), NewIndex);
        finally
          Dec (FSettingSel);
          ListView.Items.EndUpdate;
        end;
        { After decrementing FSettingSel, now call SetSelParentItem, to update
          the toolbar buttons }
        SetSelParentItem (FSelParentItem);
      end;
    end;
  end;
end;

function TdlgTB2kEdit.TreeViewDragHandler (Sender, Source: TObject;
  X, Y: Integer; Drop: Boolean): Boolean;
var
  Node: TTreeNode;
  ListItem: TListItem;
  Item, NewParentItem: TTBCustomItem;
  ItemList: TList;
  I: Integer;
  NeedRebuildTree: Boolean;
begin
  Result := False;
  if (Sender = TreeView) and (Source = ListView) then begin
    Node := TreeView.GetNodeAt(X, Y);
    if Assigned(Node) and (Node <> TreeView.Selected) then begin
      NewParentItem := Node.Data;
      ItemList := TList.Create;
      try
        ListItem := nil;
        while True do begin
          ListItem := ListView.GetNextItem(ListItem, sdAll, [isSelected]);
          if ListItem = nil then
            Break;
          Item := ListItem.Data;
          if Assigned(Item) and (Item <> NewParentItem) and
             not Item.ContainsItem(NewParentItem) and
             not(Item is TTBControlItem) then begin
            Result := True;
            ItemList.Add (Item);
          end;
        end;
        if Drop then begin
          NeedRebuildTree := False;
          for I := 0 to ItemList.Count-1 do begin
            Item := ItemList[I];
            Item.Parent.Remove (Item);
            NewParentItem.Add (Item);

            if IsSubmenuItem(Item) then
              NeedRebuildTree := True;
          end;
          if NeedRebuildTree then
            RebuildTree;
        end;
      finally
        ItemList.Free;
      end;
    end;
  end;
end;

procedure TdlgTB2kEdit.TreeViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
{ List item dragged over the tree view }
begin
  Accept := TreeViewDragHandler(Sender, Source, X, Y, False);
end;

procedure TdlgTB2kEdit.TreeViewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
{ List item dropped onto the tree view }
begin
  TreeViewDragHandler (Sender, Source, X, Y, True);
end;

procedure TdlgTB2kEdit.CreateNewItem (const AClass: TTBCustomItemClass);
var
  NewIndex: Integer;
  NewItem: TTBCustomItem;
  ListItem: TListItem;
begin
  if FSelParentItem = nil then Exit;
  NewIndex := -1;
  if (GetKeyState(VK_SHIFT) >= 0) and Assigned(ListView.Selected) then
    NewIndex := FSelParentItem.IndexOf(ListView.Selected.Data);
  if NewIndex = -1 then
    NewIndex := FSelParentItem.Count;
  NewItem := AClass.Create(FComponent.Owner{Designer.Form});
  try

    NewItem.Name := FObjectInspectorForm.Manager.GetNewControlName(NewItem.ClassName);

    FSelParentItem.Insert (NewIndex, NewItem);
  except
    NewItem.Free;
    raise;
  end;
  RebuildTree;
  RebuildList;

  ListView.Selected := nil;
  ListItem := ListView.FindData(0, NewItem, True, False);
  if Assigned(ListItem) then begin
    ListItem.Selected := True;
    ListItem.Focused := True;
    ListItem.MakeVisible (False);
    ListView.SetFocus;
  end;
end;

procedure TdlgTB2kEdit.NewSubmenuButtonClick(Sender: TObject);
begin
  CreateNewItem (TTBSubmenuItem);
end;

procedure TdlgTB2kEdit.NewItemButtonClick(Sender: TObject);
begin
  CreateNewItem (TTBItem);
end;

procedure TdlgTB2kEdit.NewSepButtonClick(Sender: TObject);
begin
  CreateNewItem (TTBSeparatorItem);
end;

procedure TdlgTB2kEdit.DeleteButtonClick(Sender: TObject);
begin
  if ActiveControl = ListView then
  begin
    if Assigned(ListView.Selected) and
       ((Pos(USERCOMPONENT_PREFIX, TTBCustomItem(ListView.Selected.Data).Name) = 1) or
        ((FObjectInspectorForm.Manager.DesignerType = dtGlobal) and
         (Pos(GLOBALUSERCOMPONENT_PREFIX, TTBCustomItem(ListView.Selected.Data).Name) = 1)
        )
       ) then
    Delete;
//    Exit;
  end
  else if (ActiveControl = TreeView) and (FSelParentItem <> FRootItem) then
  begin
    if (Pos(USERCOMPONENT_PREFIX, FSelParentItem.Name) = 1) or
      ((FObjectInspectorForm.Manager.DesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, FSelParentItem.Name) = 1)) then
//      Exit;
    DeleteItem (FSelParentItem);
  end;
  RebuildTree;
  RebuildList;
end;

procedure TdlgTB2kEdit.MoveUpButtonClick(Sender: TObject);
var
  SelList: TList;
  I, J: Integer;
  Item: TTBCustomItem;
  ListItem: TListItem;
begin
  if FSelParentItem = nil then Exit;
  SelList := TList.Create;
  try
    GetSelItemList (SelList);
    if SelList.Count = 0 then Exit;

    ListView.Items.BeginUpdate;
    FSelParentItem.ViewBeginUpdate;
    { For good performance and to prevent Object Inspector flicker, increment
      FSettingSel to prevent calls to SetSelParentItem while moving items }
    Inc (FSettingSel);
    try
      for I := 0 to SelList.Count-1 do begin
        Item := SelList[I];
        J := FSelParentItem.IndexOf(Item);
        if J <> -1 then
          MoveItem (J, J-1);
      end;
      ListItem := ListView.FindData(0, SelList[0], True, False);
      if Assigned(ListItem) then
        ListItem.MakeVisible (False);
    finally
      Dec (FSettingSel);
      FSelParentItem.ViewEndUpdate;
      ListView.Items.EndUpdate;
    end;
    { After decrementing FSettingSel, now call SetSelParentItem, to update
      the toolbar buttons }
    SetSelParentItem (FSelParentItem);
  finally
    SelList.Free;
  end;
end;

procedure TdlgTB2kEdit.MoveDownButtonClick(Sender: TObject);
var
  SelList: TList;
  I, J: Integer;
  Item: TTBCustomItem;
  ListItem: TListItem;
begin
  if FSelParentItem = nil then Exit;
  SelList := TList.Create;
  try
    GetSelItemList (SelList);
    if SelList.Count = 0 then Exit;

    ListView.Items.BeginUpdate;
    FSelParentItem.ViewBeginUpdate;
    { For good performance and to prevent Object Inspector flicker, increment
      FSettingSel to prevent calls to SetSelParentItem while moving items }
    Inc (FSettingSel);
    try
      for I := SelList.Count-1 downto 0 do begin
        Item := SelList[I];
        J := FSelParentItem.IndexOf(Item);
        if J <> -1 then
          MoveItem (J, J+1);
      end;
      ListItem := ListView.FindData(0, SelList[SelList.Count-1], True, False);
      if Assigned(ListItem) then
        ListItem.MakeVisible (False);
    finally
      Dec (FSettingSel);
      FSelParentItem.ViewEndUpdate;
      ListView.Items.EndUpdate;
    end;
    { After decrementing FSettingSel, now call SetSelParentItem, to update
      the toolbar buttons }
    SetSelParentItem (FSelParentItem);
  finally
    SelList.Free;
  end;
end;

procedure TdlgTB2kEdit.TConvertMenuClick(Sender: TObject);
begin
  if FSelParentItem = nil then Exit;
//  DoConvert (FSelParentItem, FParentComponent.Owner);
end;

procedure TdlgTB2kEdit.CMPropertyChanged(var Message: TMessage);
var
  I: Integer;
begin
  for I := 0 to ListView.Items.Count - 1 do
  begin
    if ListView.Items[I].Data = Pointer(Message.WParam) then
    begin
      ListView.Items[I].Caption := TTBCustomItem(Pointer(Message.WParam)).Caption;
      Break;
    end;
  end;
  for I := 0 to TreeView.Items.Count - 1 do
  begin
    if TreeView.Items[I].Data = Pointer(Message.WParam) then
    begin
      TreeView.Items[I].Text := TTBCustomItem(Pointer(Message.WParam)).Caption;
      Break;
    end;
  end;
end;

destructor TdlgTB2kEdit.Destroy;
begin
  Inherited;
end;


initialization
finalization
//  FreeItemClasses;

  tb2kEditorsList.Free;
  tb2kEditorsList := nil;

end.
