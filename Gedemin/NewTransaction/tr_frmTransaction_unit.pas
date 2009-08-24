unit tr_frmTransaction_unit;

interface
                                  
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, gd_createable_form, ComCtrls, ToolWin, Grids, DBGrids, gsDBGrid, gsIBGrid,
  dmDatabase_unit, gsDBTreeView, ExtCtrls, ImgList, Menus, ActnList, Db, 
  flt_sqlFilter, IBCustomDataSet, StdCtrls, IBSQL, at_sql_setup, tr_Type_unit,
  dmImages_unit, gd_security;

type
  TfrmTransaction = class(TCreateableForm)
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    gsdbtvListTrType: TgsDBTreeView;
    Panel3: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ibdsListTrType: TIBDataSet;
    ibdsListTrTypeCond: TIBDataSet;
    Timer: TTimer;
    pOperation: TPopupMenu;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    dsListTrTypeCond: TDataSource;
    dsGroupAccount: TDataSource;
    IBTransaction: TIBTransaction;
    ActionList1: TActionList;
    actNew: TAction;
    actEdit: TAction;
    actDel: TAction;
    N1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    pTypeEntry: TPanel;
    Splitter2: TSplitter;
    Panel5: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    gsibgrEntry: TgsIBGrid;
    gsibgrTrTypeCondition: TgsIBGrid;
    Label3: TLabel;
    ibdsEntry: TIBDataSet;
    dsEntry: TDataSource;
    ToolButton5: TToolButton;
    actAddSubLevel: TAction;
    N10: TMenuItem;
    N11: TMenuItem;
    atSQLSetup: TatSQLSetup;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    actAddGroupCondition: TAction;
    actAddGroupEntry: TAction;
    actAddGroupDocument: TAction;
    N15: TMenuItem;
    PopupMenu1: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    ibsqlChangeParent: TIBSQL;
    procedure N9Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actDelExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure gsdbtvListTrTypeChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure gsdbtvListTrTypeGetImageIndex(Sender: TObject;
      Node: TTreeNode);
    procedure gsdbtvListTrTypeGetSelectedIndex(Sender: TObject;
      Node: TTreeNode);
    procedure actAddSubLevelUpdate(Sender: TObject);
    procedure actAddSubLevelExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actAddGroupConditionExecute(Sender: TObject);
    procedure actAddGroupEntryExecute(Sender: TObject);
    procedure actAddGroupDocumentExecute(Sender: TObject);
    procedure actAddGroupConditionUpdate(Sender: TObject);
    procedure actAddGroupEntryUpdate(Sender: TObject);
    procedure actAddGroupDocumentUpdate(Sender: TObject);
    procedure gsdbtvListTrTypeStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure gsdbtvListTrTypeDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure gsdbtvListTrTypeDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure gsdbtvListTrTypeMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
  private
    procedure ShowAddInfo;

    procedure AddListTrType(const isSubLevel: Boolean);
    procedure EditListTrType;
    procedure DelListTrType;

    procedure AddEntry;
    procedure DelEntry;
    procedure EditEntry;

    procedure DelCondition;
    procedure EditCondition(const aID: Integer; const isIncludeTransaction: Boolean);

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmTransaction: TfrmTransaction;

implementation

{$R *.DFM}

uses
  tr_dlgAddTran_unit, tr_dlgAddTypeEntry_unit, tr_dlgSetTrCondition_unit,
  flt_dlgShowFilter_unit, flt_sqlfilter_condition_type, tr_dlgChooseDocumentType_unit,
  Storages;

class function TfrmTransaction.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmTransaction) then
    frmTransaction := TfrmTransaction.Create(AnOwner);

  Result := frmTransaction;
end;

procedure TfrmTransaction.N9Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmTransaction.FormCreate(Sender: TObject);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  with UserStorage.OpenFolder('\tr_frmTransaction_unit', True) do
    pTypeEntry.Height := ReadInteger('pTypeEntry', pTypeEntry.Height);

  UserStorage.LoadComponent(gsibgrEntry, gsibgrEntry.LoadFromStream);
  UserStorage.LoadComponent(gsibgrTrTypeCondition, gsibgrTrTypeCondition.LoadFromStream);


  ibdsListTrType.Prepare;
  ibdsListTrType.ParamByName('ck').AsInteger := IBLogin.CompanyKey;

  ibdsListTrType.Open;
end;

procedure TfrmTransaction.ShowAddInfo;
begin
  if Assigned(gsdbtvListTrType.Selected) and Assigned(gsdbtvListTrType.Selected.Data) then
  begin
    ibdsEntry.Close;
    ibdsEntry.Params.ByName('trkey').AsInteger := gsdbtvListTrType.ID;
    ibdsEntry.Open;

    ibdsListTrTypeCond.Close;
    ibdsListTrTypeCond.Params.ByName('trkey').AsInteger :=
      gsdbtvListTrType.ID;
    ibdsListTrTypeCond.Open;
    ibdsListTrTypeCond.FieldByName('name').Required := False;
  end;
end;

procedure TfrmTransaction.AddListTrType(const isSubLevel: Boolean);
var
  aParent: Integer;
begin
  { Добавление новой типовой операции }
  with TdlgAddTran.Create(Self) do
    try
      if Assigned(gsdbtvListTrType.Selected) and Assigned(gsdbtvListTrType.Selected.Data)
      then
      begin
        if not isSubLevel then
          aParent := gsdbtvListTrType.ParentID
        else
          aParent := gsdbtvListTrType.ID;
      end
      else
        if isSubLevel then
          exit
        else
          aParent := -1;
      SetupDialog(-1, aParent);
      if ShowModal = mrOk then
      begin
        ibdsListTrType.Close;
        ibdsListTrType.Open;
        gsdbtvListTrType.GoToID(ID);
      end;
    finally
      Free;
    end;
end;

procedure TfrmTransaction.DelListTrType;
var
  ibsql: TIBSQL;
  isDel: Boolean;
begin
  { Удаление существующей типовой операции }
  if Assigned(gsdbtvListTrType.Selected) and Assigned(gsdbtvListTrType.Selected.Data)
  then
    if gsdbtvListTrType.ID = RemainderTransactionKey then
    begin
      MessageBox(HANDLE, 'Нельзя удалить системную операцию', 'Внимание',
        mb_OK or mb_IconInformation);
      exit;
    end;

    if MessageBox(HANDLE, PChar(Format('Удалить типовою операцию ''%s''?', [gsdbtvListTrType.Selected.Text])), 'Внимание',
       mb_YesNo or mb_IconQuestion) = idYes
    then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := IBTransaction;
        ibsql.SQL.Text := Format('DELETE FROM gd_listtrtype WHERE id = %d',
          [gsdbtvListTrType.ID]);
        try
          ibsql.ExecQuery;
          isDel := True;
        except
{          if not gsDBDelete.isUse(IntToStr(gsdbtvListTrType.ID)) then}
            MessageBox(Handle,
               Pchar(gsdbtvListTrType.Selected.Text + ' где-то используется'),
               'Внимание',
               MB_OK or MB_ICONHAND);
          isDel := False;
        end;
        ibsql.Close;
        if isDel then
          gsdbtvListTrType.Items.Delete(gsdbtvListTrType.Selected);
      finally
        ibsql.Free;
      end;
    end;
end;

procedure TfrmTransaction.EditListTrType;
var
  aID, aParent: Integer;
begin
  { Редактирование существующей типовой операции }
  if Assigned(gsdbtvListTrType.Selected) and Assigned(gsdbtvListTrType.Selected.Data)
  then
  begin
    with TdlgAddTran.Create(Self) do
      try
        aParent := gsdbtvListTrType.ParentID;
        aID := gsdbtvListTrType.ID;
        SetupDialog(aID, aParent);
        if ShowModal = mrOk then
        begin
          ibdsListTrType.Close;
          ibdsListTrType.Open;
          gsdbtvListTrType.GoToID(ID);
        end;
      finally
        Free;
      end;
  end;
end;

procedure TfrmTransaction.actDelExecute(Sender: TObject);
begin
  if gsdbtvListTrType.Focused then
    DelListTrType
  else
    if gsibgrEntry.Focused then
      DelEntry
    else
      DelCondition;    
end;

procedure TfrmTransaction.actEditExecute(Sender: TObject);
begin
  if gsdbtvListTrType.Focused then
    EditListTrType
  else
    if gsibgrEntry.Focused then
      EditEntry
    else
      EditCondition(ibdsListTrTypeCond.FieldByName('id').AsInteger, False);
end;

procedure TfrmTransaction.actNewExecute(Sender: TObject);
begin
  if gsdbtvListTrType.Focused then
    AddListTrType(False)
  else
    if gsibgrEntry.Focused then
      AddEntry
    else
      EditCondition(-1, False);
end;

procedure TfrmTransaction.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  ShowAddInfo;
end;

procedure TfrmTransaction.gsdbtvListTrTypeChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  Timer.Enabled := True;
end;

procedure TfrmTransaction.gsdbtvListTrTypeGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.HasChildren then
  begin
    if Node.Expanded then
      Node.ImageIndex := 1
    else
      Node.ImageIndex := 0;
  end
  else
    Node.ImageIndex := 17;
end;

procedure TfrmTransaction.gsdbtvListTrTypeGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.HasChildren then
  begin
    if Node.Expanded then
      Node.SelectedIndex := 1
    else
      Node.SelectedIndex := 0;
  end
  else
    Node.SelectedIndex := 17;    
end;

procedure TfrmTransaction.actAddSubLevelUpdate(Sender: TObject);
begin
  actAddSubLevel.Enabled := gsdbtvListTrType.Focused and
    Assigned(gsdbtvListTrType.Selected) and
    Assigned(gsdbtvListTrType.Selected.Data);
end;

procedure TfrmTransaction.actAddSubLevelExecute(Sender: TObject);
begin
  AddListTrType(True);
end;

{ Добавление новой типовой проводки }
procedure TfrmTransaction.AddEntry;
begin
  if not Assigned(gsdbtvListTrType.Selected) or not Assigned(gsdbtvListTrType.Selected.Data)
  then
    exit;

  with TdlgAddTypeEntry.Create(Self) do
    try
      SetupDialog(-1, gsdbtvListTrType.ID);
      if ShowModal = mrOk then
      begin
        Self.ibdsEntry.Close;
        Self.ibdsEntry.Open;
      end;
    finally
      Free;
    end;
end;

{ Удаление текущей типовой проводки }

procedure TfrmTransaction.DelEntry;
var
  Msg: String;
  i: Integer;
begin

(*
   При удалении типовой проводки необходимо предусмотреть два варианта -
   это удаление части проводки и удаление всей проводки.
   Пока это будет проигнорировано и удаляться будет только запись или
   набор записей.
*)

  if not ibdsEntry.FieldByName('ID').IsNull then
  begin
    if gsibgrEntry.SelectedRows.Count > 1 then
      Msg := 'Удалить выделенные записи?'
    else
      Msg := Format('Удалить запись по счету %s?', [ibdsEntry.FieldByName('alias').AsString]);

    if MessageBox(HANDLE, @Msg[1], 'Внимание', mb_YesNo or mb_IconQuestion) = idYes
    then
    begin
      if gsibgrEntry.SelectedRows.Count > 0 then
      begin
        for i:= 0 to gsibgrEntry.SelectedRows.Count - 1 do
        begin
          ibdsEntry.GotoBookmark(TBookmark(gsibgrEntry.SelectedRows[i]));
          ibdsEntry.Delete;
        end
      end
      else
        ibdsEntry.Delete;;
      IBTransaction.CommitRetaining;  
    end;
  end;  
end;

procedure TfrmTransaction.EditEntry;
begin
  { Редактирование текущей типовой проводки }
  if not ibdsEntry.FieldByName('ID').IsNull then
  begin
    with TdlgAddTypeEntry.Create(Self) do
      try
        SetupDialog(Self.ibdsEntry.FieldByName('EntryKey').AsInteger,
          Self.ibdsEntry.FieldByName('trtypekey').AsInteger);
        if ShowModal = mrOk then
        begin
          Self.ibdsEntry.Close;
          Self.ibdsEntry.Open;
        end;
      finally
        Free;
      end;

  end;
end;

procedure TfrmTransaction.EditCondition(const aID: Integer;
  const isIncludeTransaction: Boolean);
var
  FilterData: TFilterData;
  TableList: TfltStringList;
  ibsql: TIBSQL;
  documenttypekey: Integer;
  LocBlobStream: TIBDSBlobStream;
begin
{ Добавление условия формирования операции }

  Assert(not isIncludeTransaction or (aId > -1), 'Неверно указано ID для групповой установки');

  if not Assigned(gsdbtvListTrType.Selected) or not Assigned(gsdbtvListTrType.Selected.Data)
  then
    exit;

  FilterData := TFilterData.Create;
  TableList := TfltStringList.Create;

  ibsql := TIBSQL.Create(Self);
  try
    if (aID <> -1) and not isIncludeTransaction then
      DocumentTypeKey := ibdsListTrTypeCond.FieldByName('documenttypekey').AsInteger
    else
    begin
      documenttypekey := -1;
      ibsql.Transaction := IBTransaction;
      ibsql.SQL.Text :=
        Format(
          'SELECT COUNT(*) FROM gd_documenttrtype WHERE trtypekey = %d',
          [gsdbtvListTrType.ID]);
      ibsql.ExecQuery;
      if (ibsql.RecordCount = 1) and (ibsql.Fields[0].AsInteger = 1) then
      begin
        ibsql.Close;
        ibsql.SQL.Text :=
          Format(
            'SELECT documenttypekey FROM gd_documenttrtype WHERE trtypekey = %d',
            [gsdbtvListTrType.ID]);
        ibsql.ExecQuery;
        documenttypekey := ibsql.Fields[0].AsInteger;
      end;

      ibsql.Close;
      if documenttypekey = -1 then
      begin
        with TdlgChooseDocumentType.Create(Self) do
          try
            if SetupDialog(gsdbtvListTrType.ID, IBTransaction) then
              documenttypekey := DocTypeKey;
          finally
            Free;
          end;
      end;
    end;

    if DocumentTypeKey > 0 then
    begin
      ibsql.Transaction := IBTransaction;
      ibsql.SQL.Text :=
        Format(
          'SELECT relationname FROM gd_relationtypedoc WHERE doctypekey = %d',
          [documenttypekey]);

      ibsql.ExecQuery;
      while not ibsql.EOF do
      begin
        TableList.Add(ibsql.Fields[0].AsString + '=a');
        ibsql.Next;
      end;
      ibsql.Close;

      LocBlobStream := ibdsListTrTypeCond.CreateBlobStream(ibdsListTrTypeCond.FieldByName('data'),
                 bmRead) as TIBDSBlobStream;
      try
        try
          FilterData.ConditionList.ReadFromStream(LocBlobStream);
        except
        end;
      finally
        FreeAndNil(LocBlobStream);
      end;

      with TdlgShowFilter.Create(Self) do
        try
          Transaction := IBTransaction;
          Database := IBTransaction.DefaultDatabase;
          Caption := 'Задание условий формирования операции';
          if ShowFilter(FilterData.ConditionList, nil, nil, TableList, nil, True) then
          begin
            if not isIncludeTransaction then
            begin
              if (aID = -1) then
              begin
                Self.ibdsListTrTypeCond.Insert;
                Self.ibdsListTrTypeCond.FieldByName('ID').AsInteger := GenUniqueID;
                Self.ibdsListTrTypeCond.FieldByName('listtrtypekey').AsInteger :=
                  gsdbtvListTrType.ID;
                Self.ibdsListTrTypeCond.FieldByName('documenttypekey').AsInteger :=
                  documenttypekey;
              end
              else
              begin
                ibdsListTrTypeCond.Edit;
              end;
              LocBlobStream :=
                Self.ibdsListTrTypeCond.CreateBlobStream(ibdsListTrTypeCond.FieldByName('data'),
                   bmWrite) as TIBDSBlobStream;
              try
                FilterData.ConditionList.WriteToStream(LocBlobStream);
                ibdsListTrTypeCond.FieldByName('textcondition').AsString :=
                   FilterData.FilterText;
                ibdsListTrTypeCond.Post;
              finally
                FreeAndNil(LocBlobStream);
              end;
            end
            else
            begin
              ibsql.SQL.Text := 'SELECT id FROM gd_listtrtype WHERE (lb > ' +
                ' (SELECT LB FROM gd_listtrtype WHERE id = :id)) AND ' +
                ' (rb < (SELECT RB FROM gd_listtrtype WHERE id = :id))';
              ibsql.ParamByName('ID').AsInteger := aID;
              ibsql.ExecQuery;
              while not ibsql.EOF do
              begin
                Self.ibdsListTrTypeCond.Insert;
                LocBlobStream :=
                  Self.ibdsListTrTypeCond.CreateBlobStream(ibdsListTrTypeCond.FieldByName('data'),
                     bmWrite) as TIBDSBlobStream;
                try
                  Self.ibdsListTrTypeCond.FieldByName('ID').AsInteger := GenUniqueID;
                  Self.ibdsListTrTypeCond.FieldByName('listtrtypekey').AsInteger :=
                    ibsql.FieldByName('id').AsInteger;
                  Self.ibdsListTrTypeCond.FieldByName('documenttypekey').AsInteger :=
                    documenttypekey;
                  FilterData.ConditionList.WriteToStream(LocBlobStream);
                  ibdsListTrTypeCond.FieldByName('textcondition').AsString :=
                     FilterData.FilterText;
                  ibdsListTrTypeCond.Post;
                finally
                  FreeAndNil(LocBlobStream);
                end;
                ibsql.Next;
              end;
            end;
            IBTransaction.CommitRetaining;
          end;
        finally
          Free;
        end;
    end;

  finally
    FilterData.Free;
    TableList.Free;
    ibsql.Free;
  end;
end;


procedure TfrmTransaction.DelCondition;
begin
{ Удаление условия формирования операции }
  if ibdsListTrTypeCond.FieldByName('ID').IsNull then exit;

  if MessageBox(HANDLE, PChar(Format('Удалить условие ''%s''?',
    [ibdsListTrTypeCond.FieldByName('textcondition').AsString])), 'Внимание',
     mb_YesNo or mb_IconQuestion) = idYes
  then
  begin
    ibdsListTrTypeCond.Delete;
  end;
end;


procedure TfrmTransaction.FormDestroy(Sender: TObject);
begin
  with UserStorage.OpenFolder('\tr_frmTransaction_unit', True) do
    WriteInteger('pTypeEntry', pTypeEntry.Height);

  UserStorage.SaveComponent(gsibgrEntry, gsibgrEntry.SaveToStream);
  UserStorage.SaveComponent(gsibgrTrTypeCondition, gsibgrTrTypeCondition.SaveToStream);
   
end;

{ DONE 1 -oденис -cнедочет : Это надо переделать по новой схеме }
procedure TfrmTransaction.actAddGroupConditionExecute(Sender: TObject);
begin
  { Устновка условий на вложенные операции }
  if Assigned(gsdbtvListTrType.Selected) and Assigned(gsdbtvListTrType.Selected.Data) then
    EditCondition(gsdbtvListTrType.ID,
      True);
end;

procedure TfrmTransaction.actAddGroupEntryExecute(Sender: TObject);
begin
  { Установка проводок на вложенные операции }
end;

procedure TfrmTransaction.actAddGroupDocumentExecute(Sender: TObject);
var
  ibsql: TIBSQL;
  ID: Integer;
begin
  { Установка документа на вложенные операции }
  if not Assigned(gsdbtvListTrType.Selected) or not Assigned(gsdbtvListTrType.Selected.Data)
  then
    exit;

  ID := gsdbtvListTrType.ID;

  with TdlgChooseDocumentType.Create(Self) do
    try
      if SetupDialog(-1, IBTransaction) then
      begin
        ibsql := TIBSQL.Create(Self);
        try
          ibsql.Transaction := IBTransaction;
          ibsql.SQL.Text :=
          Format(
            'INSERT INTO gd_documenttrtype (trtypekey, documenttypekey) ' +
            '  SELECT id, %d FROM gd_listtrtype WHERE (lb > ' +
                ' (SELECT LB FROM gd_listtrtype WHERE id = :id)) AND ' +
                ' (rb < (SELECT RB FROM gd_listtrtype WHERE id = :id)) AND ' +
                ' NOT (ID IN (SELECT trtypekey FROM gd_documenttrtype WHERE ' +
                ' documenttypekey = %0:d))',
            [DocTypeKey]);
          ibsql.ParamByName('id').AsInteger := ID;
          ibsql.ExecQuery;
          ibsql.Close;
          IBTransaction.CommitRetaining;
        finally
          ibsql.Free;
        end;
      end;
    finally
      Free;
    end;
end;

procedure TfrmTransaction.actAddGroupConditionUpdate(Sender: TObject);
begin
  actAddGroupCondition.Enabled := gsdbtvListTrType.Focused and
    Assigned(gsdbtvListTrType.Selected) and
    gsdbtvListTrType.Selected.HasChildren;
end;

procedure TfrmTransaction.actAddGroupEntryUpdate(Sender: TObject);
begin
  actAddGroupEntry.Enabled := gsdbtvListTrType.Focused and
    Assigned(gsdbtvListTrType.Selected) and
    gsdbtvListTrType.Selected.HasChildren;
end;

procedure TfrmTransaction.actAddGroupDocumentUpdate(Sender: TObject);
begin
  actAddGroupDocument.Enabled := gsdbtvListTrType.Focused and
    Assigned(gsdbtvListTrType.Selected) and
    gsdbtvListTrType.Selected.HasChildren;
end;

procedure TfrmTransaction.gsdbtvListTrTypeStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  {if Assigned(gsdbtvListTrType.Selected) and Assigned(gsdbtvListTrType.Selected.Data)
  then
  begin
    DragObject := TgsTNDragObject.Create;
    (DragObject as TgsTNDragObject).TN := gsdbtvListTrType.Selected;
  end;}
end;

procedure TfrmTransaction.gsdbtvListTrTypeDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  //Accept := Source is TgsTNDragObject;
end;

procedure TfrmTransaction.gsdbtvListTrTypeDragDrop(Sender, Source: TObject;
  X, Y: Integer);
{var
  T: TTreeNode;}
begin
  {if (Source is TgsTNDragObject) and Assigned(gsdbtvListTrType.GetNodeAt(X, Y)) and
     ((Source as TgsTNDragObject).TN <> gsdbtvListTrType.GetNodeAt(X, Y)) and
     (MessageBox(HANDLE, PChar(Format('Перенести операцию %s?', [gsdbtvListTrType.Selected.Text])), 'Внимание', mb_YesNo or mb_IconQuestion) = idYes)
  then
  begin
    T := gsdbtvListTrType.GetNodeAt(X, Y);
    ibsqlChangeParent.Prepare;
    ibsqlChangeParent.Params.ByName('Parent').AsInteger :=
      TgsDBTreeNode(gsdbtvListTrType.GetNodeAt(X, Y).Data).ID;
    ibsqlChangeParent.Params.ByName('ID').AsInteger :=
      TgsDBTreeNode((Source as TgsTNDragObject).TN.Data).ID;

    ibsqlChangeParent.ExecQuery;
    ibsqlChangeParent.Close;

    IBTransaction.CommitRetaining;

    gsdbtvListTrType.Selected := gsdbtvListTrType.Items.AddChildObject(T,
      (Source as TgsTNDragObject).TN.Text,
      (Source as TgsTNDragObject).TN.Data);

    gsdbtvListTrType.Items.Delete((Source as TgsTNDragObject).TN);
  end;}
end;

procedure TfrmTransaction.gsdbtvListTrTypeMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) and (Y > 20) then
    gsdbtvListTrType.BeginDrag(False);
end;

initialization
  RegisterClass(TfrmTransaction);


end.
