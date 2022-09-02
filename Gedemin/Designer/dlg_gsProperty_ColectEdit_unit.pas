// ShlTanya, 24.02.2019

unit dlg_gsProperty_ColectEdit_unit;
                       
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Menus, ExtCtrls, DsgnIntf, ComCtrls, ImgList, ActnList,
  ToolWin, gsResizerInterface, contnrs, gd_messages_const;

type
  TColOption = (coAdd, coDelete, coMove);
  TColOptions = set of TColOption;

  Tdlg_gsProperty_ColectEdit = class(TForm)
    Panel3: TPanel;
    ListView1: TListView;
    ImageList1: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    AddCmd: TAction;
    DeleteCmd: TAction;
    MoveUpCmd: TAction;
    MoveDownCmd: TAction;
    SelectAllCmd: TAction;
    N2: TMenuItem;
    edSearch: TEdit;
    btn1: TToolButton;
    procedure AddClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure MoveUpClick(Sender: TObject);
    procedure ListView1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ListView1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure MoveDownClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure SelectAll1Click(Sender: TObject);
    procedure SelectAllCommandUpdate(Sender: TObject);
    procedure SelectionUpdate(Sender: TObject);
    procedure edSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FCollectionPropertyName: string;
    FStateLock: Integer;
    FItemIDList: TList;
    FCollectionClassName: string;
    FSelectionError: Boolean;
    FColOptions: TColOptions;
    FObjectInspectorForm: IgsObjectInspectorForm;
    FCollection: TCollection;
    FComponent: TComponent;

    procedure SetCollectionPropertyName(const Value: string);
    procedure AMDeferUpdate(var Msg); message AM_DeferUpdate;
    procedure SetColOptions(Value: TColOptions);
  protected
    procedure Activated;
    function  CanAdd(Index: Integer): Boolean; virtual;
    procedure LockState;
    procedure UnlockState;
    property StateLock: Integer read FStateLock;
    procedure SelectAll(DoUpdate: Boolean = True);
    procedure SelectNone(DoUpdate: Boolean = True);
  public
    property Options: TColOptions read FColOptions write SetColOptions;
    procedure ComponentDeleted(Component: IPersistent);
    procedure FormClosed(AForm: TCustomForm);
    procedure FormModified;
    function GetItemName(Index, ItemIndex: Integer): string;
    procedure GetSelection;
    procedure SetSelection;
    procedure UpdateListbox;
    property CollectionPropertyName: string read FCollectionPropertyName
      write SetCollectionPropertyName;
  end;

function gsShowCollectionEditor(AObjectInspector: IgsObjectInspectorForm; AComponent: TComponent;
  ACollection: TCollection; const PropertyName: string; ColOptions: TColOptions = [coAdd, coDelete, coMove]): Tdlg_gsProperty_ColectEdit;
procedure KillCollections;
implementation

{$R *.DFM}

uses TypInfo;

type
  TAccessCollection = class(TCollection); // used for protected method access
  TPersistentCracker = class(TPersistent);
var
  CollectionEditorsList: TObjectList = nil;

procedure KillCollections;
begin
  if Assigned(CollectionEditorsList) then
    CollectionEditorsList.Clear;
end;

function gsShowCollectionEditor(AObjectInspector: IgsObjectInspectorForm; AComponent: TComponent;
  ACollection: TCollection; const PropertyName: string; ColOptions: TColOptions = [coAdd, coDelete, coMove]): Tdlg_gsProperty_ColectEdit;
var
  I: Integer;
begin
  if CollectionEditorsList = nil then
    CollectionEditorsList := TObjectList.Create;
  for I := 0 to CollectionEditorsList.Count-1 do
  begin
    Result := Tdlg_gsProperty_ColectEdit(CollectionEditorsList[I]);
    with Result do
      if (FObjectInspectorForm = AObjectInspector) and (FComponent = AComponent)
        and (FCollection = ACollection)
        and (CompareText(CollectionPropertyName, PropertyName) = 0) then
      begin
        Show;
        BringToFront;
        Exit;
      end;
  end;
  Result := Tdlg_gsProperty_ColectEdit.Create(nil);
  with Result do
  try
    FObjectInspectorForm := AObjectInspector;
    Options := ColOptions;
    FCollection := ACollection;
    FCollectionClassName := ACollection.ClassName;
    FComponent := AComponent;
    CollectionPropertyName := PropertyName;
    UpdateListbox;
    Show;
  except
    Free;
    Result := nil;
  end;
end;

{ TCollectionEditor }

procedure Tdlg_gsProperty_ColectEdit.Activated;
var
  Msg: TMessage;
begin
  Msg.Msg := WM_ACTIVATE;
  Msg.WParam := 1;
  SetSelection;
end;

procedure Tdlg_gsProperty_ColectEdit.SetColOptions(Value: TColOptions);
begin
  FColOptions := Value;
  AddCmd.Enabled := coAdd in Value;
end;

procedure Tdlg_gsProperty_ColectEdit.ComponentDeleted(Component: IPersistent);

  function IsOwnedBy(Owner, Child: TPersistent): Boolean;
  begin
    Result := False;
    if Owner = nil then Exit;
    while (Child <> nil) and (Child <> Owner) and not (Child is TComponent) do
      Child := TPersistentCracker(Child).GetOwner;
    Result := Child = Owner;
  end;

var
  Temp: TPersistent;
begin
  Temp := TryExtractPersistent(Component);
  if Temp = nil then Exit;
  if (Self.FComponent = nil) or (csDestroying in Self.FComponent.ComponentState) or
    (Temp = Self.FComponent) or IsOwnedBy(Temp, FCollection) then
  begin
    FCollection := nil;  // Component is already in its destructor; collection is gone
    Self.FComponent := nil;
    Close;
  end
  else if IsOwnedBy(FCollection, Temp) then
    PostMessage(Handle, AM_DeferUpdate, 1, 0);
end;

procedure Tdlg_gsProperty_ColectEdit.FormClosed(AForm: TCustomForm);
begin
{  if Designer.Form = AForm then
  begin
    Collection := nil;
    Component := nil;
    Close;
  end;}
end;

procedure Tdlg_gsProperty_ColectEdit.FormModified;
begin
  if FCollection <> nil then
  begin
    UpdateListbox;
    GetSelection;
  end;
end;

function Tdlg_gsProperty_ColectEdit.GetItemName(Index, ItemIndex: Integer): string;
begin
  with TAccessCollection(FCollection) do
    if GetAttrCount < 1 then
      Result := Format('%d - %s',[ItemIndex, FCollection.Items[ItemIndex].DisplayName])
    else Result := GetItemAttr(Index, ItemIndex);
end;

procedure Tdlg_gsProperty_ColectEdit.GetSelection;
var
  I: Integer;
  Item: TCollectionItem;
  //List: TDesignerSelectionList;
begin
  LockState;
  try
    ListView1.Selected := nil;

    UpdateListbox;

    for I := FItemIDList.Count - 1 downto 0 do
    begin
      Item := FCollection.FindItemID(Integer(FItemIDList[I]));
      if Item <> nil then
        ListView1.Items[Item.Index].Selected := True
      else FItemIDList.Delete(I);
    end;
  finally
    UnlockState;
  end;
end;

procedure Tdlg_gsProperty_ColectEdit.LockState;
begin
  Inc(FStateLock);
end;


procedure Tdlg_gsProperty_ColectEdit.SetCollectionPropertyName(const Value: string);
begin
  if Value <> FCollectionPropertyName then
  begin
    FCollectionPropertyName := Value;
    Caption := FComponent.Name + DotSep + Value;
  end;
end;

procedure Tdlg_gsProperty_ColectEdit.SetSelection;
var
  I: Integer;
//  List: TDesignerSelectionList;
begin
  if FSelectionError then Exit;
  try
    if ListView1.SelCount > 0 then
    begin
      try
        FItemIDList.Clear;
        for I := 0 to ListView1.Items.Count - 1 do
          if ListView1.Items[I].Selected then
          begin
            FObjectInspectorForm.AddEditSubComponent(FCollection.Items[I]);
            FItemIDList.Add(Pointer(FCollection.Items[I].ID));
          end;
      finally
      end;
    end
    else
      FObjectInspectorForm.AddEditComponent(FComponent, False);
  except
    FSelectionError := True;
    Application.HandleException(ExceptObject);
    Close;
  end;
end;

procedure Tdlg_gsProperty_ColectEdit.UnlockState;
begin
  Dec(FStateLock);
end;

procedure Tdlg_gsProperty_ColectEdit.UpdateListbox;
var
  I, J: Integer;

  procedure UpdateColumns;
  var
    I: Integer;
  begin
    if (FCollection <> nil) and
      (((TAccessCollection(FCollection).GetAttrCount > 0) and
      (ListView1.Columns.Count <> TAccessCollection(FCollection).GetAttrCount)) or
      ((ListView1.Columns.Count = 0) and
      (TAccessCollection(FCollection).GetAttrCount < 1))) then
    begin
      ListView1.HandleNeeded;
      with TAccessCollection(FCollection) do
      begin
        if GetAttrCount >= 1 then
          for I := 0 to GetAttrCount - 1 do
            with ListView1.Columns.Add do
            begin
              Caption := GetAttr(I);
              Width := -2;
            end
        else
          with ListView1.Columns.Add do
            Width := -1;
        if GetAttrCount >= 1 then
          ListView1.ShowColumnHeaders := True
      end;
    end;
  end;

  procedure FetchItems(List: TStrings);
  var
    I, J: Integer;
    SubList: TStringList;
  begin
    if FCollection <> nil then
      for I := 0 to FCollection.Count - 1 do
        if CanAdd(I) then
        begin
          SubList := TStringList.Create;
          for J := 1 to TAccessCollection(FCollection).GetAttrCount - 1 do
            SubList.Add(GetItemName(J, I));
          List.AddObject(GetItemName(0, I), SubList);
        end;

  end;

  function ItemsEqual(ListItems: TListItems; Items: TStrings): Boolean;
  var
    I, J: Integer;
  begin
    Result := False;
    if ListItems.Count <> Items.Count then Exit;
    for I := 0 to ListItems.Count - 1 do
    begin
      if ListItems[I].Caption = Items[I] then
      begin
        for J := 0 to ListItems[I].SubItems.Count - 1 do
          if ListItems[I].SubItems[J] <> TStrings(Items.Objects[I])[J] then
            Exit;
      end
      else
        Exit;
    end;
    Result := True;
  end;

var
  TmpItems: TStringList;
begin
  if FCollection = nil then Exit;
  LockState;
  try
    TmpItems := TStringList.Create;
    FetchItems(TmpItems);
    try
      if (TmpItems.Count = 0) or not ItemsEqual(ListView1.Items, TmpItems) then
      begin
        ListView1.Items.BeginUpdate;
        try
          UpdateColumns;

          ListView1.Items.Clear;
          for I := 0 to TmpItems.Count - 1 do
            with ListView1.Items.Add do
            begin
              Caption := TmpItems[I];
              for J := 0 to TStrings(TmpItems.Objects[I]).Count - 1 do
                SubItems.Add(TStrings(TmpItems.Objects[I])[J]);
            end;
        finally
          ListView1.Items.EndUpdate;
        end;
      end;
    finally
      for I := 0 to TmpItems.Count - 1 do
        TStrings(TmpItems.Objects[I]).Free;
      TmpItems.Free;
    end;
  finally
    UnlockState;
  end;
end;

procedure Tdlg_gsProperty_ColectEdit.AddClick(Sender: TObject);
var
  Item: TListItem;
  PrevCount: Integer;
begin
  SelectNone(False);
  FCollection.BeginUpdate;
  try
    PrevCount := FCollection.Count + 1;
    FCollection.Add;
    { Take into account collections that free items }
    if PrevCount <> FCollection.Count then
      UpdateListBox
    else
    begin
      ListView1.Selected := ListView1.Items.Add;
      GetSelection;
    end;  
  finally
    FCollection.EndUpdate;
  end;
  SetSelection;
  { Focus last added item }
  Item := ListView1.Items[ListView1.Items.Count-1];
  Item.Focused := True;
  Item.MakeVisible(False);
end;

procedure Tdlg_gsProperty_ColectEdit.DeleteClick(Sender: TObject);
var
  I, J: Integer;
begin
  FCollection.BeginUpdate;
  try
    if ListView1.Selected <> nil then
      J := ListView1.Selected.Index
    else J := -1;
    if ListView1.SelCount = FCollection.Count then
      FCollection.Clear
    else if ListView1.SelCount > 0 then
      for I := ListView1.Items.Count - 1 downto 0 do
        if ListView1.Items[I].Selected then
          FCollection.Items[I].Free;
  finally
    FCollection.EndUpdate;
  end;
  UpdateListbox;
  if J >= ListView1.Items.Count then
    J := ListView1.Items.Count - 1;
  if (J > -1) and (J < ListView1.Items.Count) then
    ListView1.Selected := ListView1.Items[J];
  SetSelection;
end;

procedure Tdlg_gsProperty_ColectEdit.MoveUpClick(Sender: TObject);
var
  I, InsPos: Integer;
begin
  if (ListView1.SelCount = 0) or
    (ListView1.SelCount = FCollection.Count) then Exit;

  InsPos := 0;
  while not ListView1.Items[InsPos].Selected do
    Inc(InsPos);

  if InsPos > 0 then Dec(InsPos);

  FCollection.BeginUpdate;
  try
    for I := 0 to ListView1.Items.Count - 1 do
      if ListView1.Items[I].Selected then
      begin
        FCollection.Items[I].Index := InsPos;
        Inc(InsPos);
      end;
  finally
    FCollection.EndUpdate;
  end;
  GetSelection;
  PostMessage(Handle, AM_DeferUpdate, 0, 0)
//  UpdateListbox;
end;

procedure Tdlg_gsProperty_ColectEdit.MoveDownClick(Sender: TObject);
var
  I, InsPos: Integer;
begin
  if (ListView1.SelCount = 0) or
    (ListView1.SelCount = FCollection.Count) then Exit;

  InsPos := ListView1.Items.Count - 1;
  while not ListView1.Items[InsPos].Selected do
    Dec(InsPos);
  if InsPos < (ListView1.Items.Count -1) then Inc(InsPos);

  FCollection.BeginUpdate;
  try
     for I := ListView1.Items.Count - 1 downto 0 do
       if ListView1.Items[I].Selected then
       begin
         FCollection.Items[I].Index := InsPos;
         Dec(InsPos);
       end;
  finally
    FCollection.EndUpdate;
  end;
  GetSelection;
  PostMessage(Handle, AM_DeferUpdate, 0, 0)
//  UpdateListbox;
end;

procedure Tdlg_gsProperty_ColectEdit.ListView1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  Item: TListItem;
begin
  Item := ListView1.GetItemAt(X, Y);
  Accept := (Item <> nil) and (Source = ListView1) and
    (not Item.Selected);
end;

procedure Tdlg_gsProperty_ColectEdit.ListView1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  Item: TListItem;
  I, J, InsPos: Integer;
  L: TList;
begin
  Item := ListView1.GetItemAt(X, Y);
  if Item <> nil then
    InsPos := Item.Index
  else Exit;
  L := TList.Create;
  try
    for I := 0 to ListView1.Items.Count - 1 do
      if ListView1.Items[I].Selected then
        L.Add(FCollection.Items[I]);

    FCollection.BeginUpdate;
    try
      for I := 0 to L.Count - 1 do
      with TCollectionItem(L[I]) do
      begin
        J := Index;
        Index := InsPos;
        if (J > InsPos) and (InsPos < FCollection.Count) then
          Inc(InsPos);
      end;
    finally
      FCollection.EndUpdate;
    end;
  finally
    L.Free;
  end;
  GetSelection;
end;


procedure Tdlg_gsProperty_ColectEdit.FormCreate(Sender: TObject);
begin
  FItemIdList := TList.Create;
  CollectionEditorsList.Add(Self);
end;

procedure Tdlg_gsProperty_ColectEdit.FormDestroy(Sender: TObject);
begin
  FItemIdList.Free;
end;

procedure Tdlg_gsProperty_ColectEdit.ListView1Change(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
  Msg: TMsg;
begin
  if (Change = ctState) and (FStateLock = 0) then
    if not PeekMessage(Msg, Handle, AM_DeferUpdate, AM_DeferUpdate, PM_NOREMOVE) then
      PostMessage(Handle, AM_DeferUpdate, 0, 0);
end;

procedure Tdlg_gsProperty_ColectEdit.AMDeferUpdate(var Msg);
begin
  if FStateLock = 0 then
  begin
    if TMessage(Msg).WParam = 0 then
      SetSelection
    else
      FormModified;
  end
  else
    PostMessage(Handle, AM_DeferUpdate, TMessage(Msg).WParam, TMessage(Msg).LParam);
end;

procedure Tdlg_gsProperty_ColectEdit.SelectAll1Click(Sender: TObject);
begin
  SelectAll();
end;

procedure Tdlg_gsProperty_ColectEdit.SelectionUpdate(Sender: TObject);
var
  Enabled: Boolean;
begin
  Enabled := ListView1.Selected <> nil;
  if Enabled then
    if Sender = DeleteCmd then
      Enabled := coDelete in Options else
    if (Sender = MoveUpCmd) or (Sender = MoveDownCmd) then
      Enabled := coMove in Options;
  (Sender as TAction).Enabled := Enabled;
end;

procedure Tdlg_gsProperty_ColectEdit.SelectAllCommandUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := ListView1.Items.Count > 0;
end;

procedure Tdlg_gsProperty_ColectEdit.SelectAll(DoUpdate: Boolean);
var
  I: Integer;
begin
  LockState;
  ListView1.Items.BeginUpdate;
  try
    for I := 0 to Listview1.Items.Count-1 do
      Listview1.Items[I].Selected := True;
  finally
    ListView1.Items.EndUpdate;
    UnlockState;
    if DoUpdate then SetSelection;
  end;
end;

procedure Tdlg_gsProperty_ColectEdit.SelectNone(DoUpdate: Boolean);
var
  I: Integer;
begin
  LockState;
  ListView1.Items.BeginUpdate;
  try
    for I := 0 to Listview1.Items.Count-1 do
      Listview1.Items[I].Selected := False;
  finally
    ListView1.Items.EndUpdate;
    UnlockState;
    if DoUpdate then SetSelection;
  end;
end;

function Tdlg_gsProperty_ColectEdit.CanAdd(Index: Integer): Boolean;
begin
  Result := True;
end;

procedure Tdlg_gsProperty_ColectEdit.edSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  I: Integer;
  First: Boolean;
  S1,S2: string;
begin
  S1 := Trim(edSearch.Text);
  if (Key = VK_RETURN) and (S1 <> '') then
  begin
    First := True;
    for i := 0 to ListView1.Items.Count -1 do
    begin
      S2 := ListView1.Items.Item[i].Caption;
      Delete(S2, 1, Pos(' - ', S2)+2);
      if AnsiPos(AnsiUpperCase(S1), AnsiUpperCase(S2)) = 1 then
      begin
        ListView1.Items.Item[i].Selected := True;
        if First then
        begin
          ListView1.Items.Item[i].MakeVisible(False);
          First := False;
        end;  
      end
      else ListView1.Items.Item[i].Selected := False;
    end;
  end;
end;

initialization

finalization
  CollectionEditorsList.Free;
  CollectionEditorsList := nil;

end.

