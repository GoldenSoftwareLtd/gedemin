unit dlgMenuEditor_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TB2Item, ImgList, TB2Dock, TB2Toolbar, ComCtrls, gsResizerInterface,
  menus, ActnList, gd_messages_const;

type
  TdlgMenuEditor = class(TForm)
    tvMenu: TTreeView;
    TBToolbar1: TTBToolbar;
    TBImageList1: TTBImageList;
    TBItem5: TTBItem;
    TBItem6: TTBItem;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem7: TTBItem;
    TBItem8: TTBItem;
    alMenu: TActionList;
    actAdd: TAction;
    actAddSub: TAction;
    actDel: TAction;
    actUp: TAction;
    actDown: TAction;
    TBItem1: TTBItem;
    procedure tvMenuChange(Sender: TObject; Node: TTreeNode);
    procedure actAddExecute(Sender: TObject);
    procedure actAddSubExecute(Sender: TObject);
    procedure actDelUpdate(Sender: TObject);
    procedure actDelExecute(Sender: TObject);
    procedure actUpExecute(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
  private
    { Private declarations }
    FObjectInspectorForm: IgsObjectInspectorForm;
    FComponent: TMenu;
    FRootItem: TMenuItem;
    FTreeRoot: TTreeNode;
    procedure RebuildTree;
    procedure CMPropertyChanged(var Message: TMessage);  message CM_PROPERTYCHANGED;
  public
    { Public declarations }

  end;
  procedure KillMenuEditors;
  function ShowMenuEditForm (AObjectInspector: IgsObjectInspectorForm; AComponent: TComponent; ARootItem: TMenuItem): TdlgMenuEditor;
var
  dlgMenuEditor: TdlgMenuEditor;

implementation
uses contnrs;
{$R *.DFM}
var
  MenuEditorsList: TObjectList = nil;

procedure KillMenuEditors;
begin
  if Assigned(MenuEditorsList) then
    MenuEditorsList.Clear;
end;

function ShowMenuEditForm (AObjectInspector: IgsObjectInspectorForm; AComponent: TComponent; ARootItem: TMenuItem): TdlgMenuEditor;
var
  I: Integer;
begin
  if MenuEditorsList = nil then
    MenuEditorsList := TObjectList.Create;
  for I := 0 to MenuEditorsList.Count-1 do
  begin

    Result := TdlgMenuEditor(MenuEditorsList[I]);
    with Result do
      if (FObjectInspectorForm = AObjectInspector) and (FComponent = AComponent)
        and (FRootItem = ARootItem)then
      begin
        RebuildTree;
        Show;
        BringToFront;
        Exit;
      end;
  end;
  Result := TdlgMenuEditor.Create(nil);
  with Result do
  try
    MenuEditorsList.Add(Result);
    FComponent := TMenu(AComponent);
    FRootItem := ARootItem;
    Caption := 'Редактирование ' + AComponent.Name;

    FObjectInspectorForm := AObjectInspector;
    FObjectInspectorForm.Manager.AddPropertyNotification(Result);

    RebuildTree;
    Show;
  except
    Free;
    Result := nil;
  end;
end;
{ TdlgMenuEditor }

procedure TdlgMenuEditor.CMPropertyChanged(var Message: TMessage);
var
  I: Integer;
begin
  for I := 0 to tvMenu.Items.Count - 1 do
  begin
    if tvMenu.Items[I].Data = Pointer(Message.WParam) then
    begin
      tvMenu.Items[I].Text := TMenuItem(Pointer(Message.WParam)).Caption;
      Break;
    end;
  end;
end;

procedure TdlgMenuEditor.RebuildTree;
  procedure AddMenuToTree(AMenuItem: TMenuItem; ATreeNode: TTreeNode);
  var
    I: Integer;
    Node: TTreeNode;
  begin
    for I := 0 to AMenuItem.Count - 1 do
    begin
      Node := tvMenu.Items.AddChildObject(ATreeNode, AMenuItem[I].Caption, AMenuItem[I]);
      AddMenuToTree(AMenuItem[I], Node);
    end;

  end;

var
  I: Integer;
  Node: TTreeNode;
begin
  tvMenu.Items.Clear;
  FTreeRoot := tvMenu.Items.AddObject(nil, 'Root', FRootItem);
  for I := 0 to FRootItem.Count - 1 do
  begin
    Node := tvMenu.Items.AddChildObject(FTreeRoot, FRootItem[I].Caption, FRootItem[I]);
    AddMenuToTree(FRootItem[I], Node);
  end;
end;

procedure TdlgMenuEditor.tvMenuChange(Sender: TObject; Node: TTreeNode);
begin
  if tvMenu.Selected <> nil then
  begin
    if tvMenu.Selected.Data = FRootItem then
      FObjectInspectorForm.AddEditComponent(FComponent, False)
    else
      FObjectInspectorForm.AddEditSubComponent(TMenuItem(tvMenu.Selected.Data));
  end;
end;

procedure TdlgMenuEditor.actAddExecute(Sender: TObject);
var
  ParentItem, NewItem: TMenuItem;
  CurrNode: TTreeNode;
begin
  if (tvMenu.Selected = nil) or (tvMenu.Selected.Data = FRootItem) then
  begin
    ParentItem := FRootItem;
    CurrNode := FTreeRoot;
  end
  else
  begin
    ParentItem := TMenuItem(tvMenu.Selected.Parent.Data);
    CurrNode := tvMenu.Selected.Parent;
  end;
  NewItem := TMenuItem.Create(FObjectInspectorForm.Manager.EditForm);
  NewItem.Name := FObjectInspectorForm.Manager.GetNewControlName(NewItem.ClassName);

  ParentItem.Add(NewItem);
  CurrNode := tvMenu.Items.AddChildObject(CurrNode, NewItem.Caption, NewItem);
  tvMenu.Selected := CurrNode;
end;

procedure TdlgMenuEditor.actAddSubExecute(Sender: TObject);
var
  ParentItem, NewItem: TMenuItem;
  CurrNode: TTreeNode;
begin
  if (tvMenu.Selected = nil) or (tvMenu.Selected.Data = FRootItem) then
  begin
    ParentItem := FRootItem;
    CurrNode := FTreeRoot;
  end
  else
  begin
    ParentItem := TMenuItem(tvMenu.Selected.Data);
    CurrNode := tvMenu.Selected;
  end;
  NewItem := TMenuItem.Create(FObjectInspectorForm.Manager.EditForm);

  NewItem.Name := FObjectInspectorForm.Manager.GetNewControlName(NewItem.ClassName);

  ParentItem.Add(NewItem);
  CurrNode := tvMenu.Items.AddChildObject(CurrNode, NewItem.Caption, NewItem);
  tvMenu.Selected := CurrNode;
end;

procedure TdlgMenuEditor.actDelUpdate(Sender: TObject);
begin
  if (tvMenu.Selected <> nil) and (tvMenu.Selected <> FTreeRoot) then
    TAction(Sender).Enabled := (Pos(USERCOMPONENT_PREFIX, TMenuItem(tvMenu.Selected.Data).Name) = 1) or
     ((FObjectInspectorForm.Manager.DesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, TMenuItem(tvMenu.Selected.Data).Name) = 1))
  else
    TAction(Sender).Enabled := False;
end;

procedure TdlgMenuEditor.actDelExecute(Sender: TObject);
var
  ParentItem: TMenuItem;
//  CurrNode: TTreeNode;
begin
  ParentItem := TMenuItem(tvMenu.Selected.Parent.Data);
  ParentItem.Delete(ParentItem.IndexOf(TMenuItem(tvMenu.Selected.Data)));
  tvMenu.Selected.Delete;
end;

procedure TdlgMenuEditor.actUpExecute(Sender: TObject);
begin
  if (tvMenu.Selected = nil) or (tvMenu.Selected.Data = FRootItem) then
    exit;
  if tvMenu.Selected.Index > 0 then
  begin
    tvMenu.Selected.MoveTo(tvMenu.Selected.GetPrev, naInsert);
    TMenuItem(tvMenu.Selected.Data).MenuIndex := TMenuItem(tvMenu.Selected.Data).MenuIndex - 1;
  end;

end;

procedure TdlgMenuEditor.actDownExecute(Sender: TObject);
begin
  if (tvMenu.Selected = nil) or (tvMenu.Selected.Data = FRootItem) then
    exit;

  if tvMenu.Selected.Index < (tvMenu.Selected.Parent.Count - 2) then
  begin
    tvMenu.Selected.MoveTo(tvMenu.Selected.GetNext.GetNext, naInsert);
    TMenuItem(tvMenu.Selected.Data).MenuIndex := TMenuItem(tvMenu.Selected.Data).MenuIndex + 1;
  end else
  if tvMenu.Selected.Index = (tvMenu.Selected.Parent.Count - 2) then
  begin
    tvMenu.Selected.MoveTo(tvMenu.Selected.GetNext, naAdd);
    TMenuItem(tvMenu.Selected.Data).MenuIndex := TMenuItem(tvMenu.Selected.Data).MenuIndex + 1;
  end
end;

initialization
finalization
  MenuEditorsList.Free;
  MenuEditorsList := nil;

end.
