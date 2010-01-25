unit tr_frmAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, ExtCtrls, ImgList, Db, IBCustomDataSet, gd_createable_form,
  dmDatabase_unit, IBDatabase, gsDBTreeView, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ActnList, IBSQL,  Menus, flt_sqlFilter,
  dmImages_unit;

type
  TfrmAccount = class(TCreateableForm)
    Panel1: TPanel;
    ToolBar1: TToolBar;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ibdsGroupAccount: TIBDataSet;
    ibdsAccount: TIBDataSet;
    dsGroupAccount: TDataSource;
    dsAccount: TDataSource;
    IBTransaction: TIBTransaction;
    gsdbtvGroupAccount: TgsDBTreeView;
    gsibgrAccount: TgsIBGrid;
    ActionList1: TActionList;
    actNew: TAction;
    actEdit: TAction;
    actDel: TAction;
    Timer: TTimer;
    pOperation: TPopupMenu;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    gsqfAccount: TgsQueryFilter;
    pOperAccount: TPopupMenu;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    ibsqlChangeGroupKey: TIBSQL;
    actPlanForFirm: TAction;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure gsdbtvGroupAccountGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure gsdbtvGroupAccountGetSelectedIndex(Sender: TObject;
      Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure gsdbtvGroupAccountChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure TimerTimer(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDelExecute(Sender: TObject);
    procedure gsibgrAccountDblClick(Sender: TObject);
    procedure gsdbtvGroupAccountDblClick(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure LoadSettings; override;
    procedure SaveSettings; override;
    procedure gsibgrAccountDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure gsibgrAccountMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure gsibgrAccountStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure gsdbtvGroupAccountDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure gsdbtvGroupAccountDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure actPlanForFirmExecute(Sender: TObject);
  private
    { Private declarations }
    procedure ShowAccount;
    procedure EditAccount(const isEdit: Boolean);
    procedure RefreshTree(const aCurrentID: Integer);
  public
    { Public declarations }
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmAccount: TfrmAccount;

implementation

{$R *.DFM}

uses
  tr_dlgEditAccount_unit, tr_dlgPlanForCompany_unit, Storages;

class function TfrmAccount.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmAccount) then
    frmAccount := TfrmAccount.Create(AnOwner);

  Result := frmAccount;
end;

procedure TfrmAccount.gsdbtvGroupAccountGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Expanded then
    Node.ImageIndex := 1
  else
    Node.ImageIndex := 0;
end;

procedure TfrmAccount.gsdbtvGroupAccountGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Expanded then
    Node.SelectedIndex := 1
  else
    Node.SelectedIndex := 0;
end;

procedure TfrmAccount.FormCreate(Sender: TObject);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  ibdsGroupAccount.Open;
  ShowAccount;  
end;

procedure TfrmAccount.ShowAccount;
begin
  if gsdbtvGroupAccount.Selected <> nil then
  begin
    gsibgrAccount.Visible := True;
    ibdsAccount.Close;
    ibdsAccount.Params.ByName('LB').AsInteger :=
      ibdsGroupAccount.FieldByName('lb').AsInteger;
    ibdsAccount.Params.ByName('RB').AsInteger :=
      ibdsGroupAccount.FieldByName('rb').AsInteger;
    ibdsAccount.Open;
  end
  else
    gsibgrAccount.Visible := False;
end;

procedure TfrmAccount.gsdbtvGroupAccountChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  Timer.Enabled := False;
  Timer.Enabled := True;
end;

procedure TfrmAccount.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  ShowAccount;
end;

procedure TfrmAccount.RefreshTree(const aCurrentID: Integer);
begin
  ibdsGroupAccount.Close;
  ibdsGroupAccount.Open;
  if aCurrentID <> -1 then
    gsdbtvGroupAccount.GoToID(aCurrentID);
end;

procedure TfrmAccount.actNewExecute(Sender: TObject);
begin
  EditAccount(False);
end;

procedure TfrmAccount.actEditExecute(Sender: TObject);
begin
  EditAccount(True);
end;

procedure TfrmAccount.actDelExecute(Sender: TObject);
var
  ibsql: TIBSQL;
  ID: Integer;
  isGroup: Boolean;
  aMessage: String;
begin

  ibsql := TIBSQL.Create(Self);
  try
    if gsdbtvGroupAccount.Focused then
    begin
      if Assigned(gsdbtvGroupAccount.Selected) and Assigned(gsdbtvGroupAccount.Selected.Data)
      then
      begin
        ID := gsdbtvGroupAccount.ID;
        isGroup := True;
        if gsdbtvGroupAccount.Selected.HasChildren then
          aMessage := Format('Удалить ''%s''?', [gsdbtvGroupAccount.Selected.Text])
        else
          aMessage := Format('Удалить раздел ''%s''?', [gsdbtvGroupAccount.Selected.Text]);
      end
      else
        exit;
    end
    else
    begin
      aMessage := Format('Удалить счет ''%s''?', [ibdsAccount.FieldByName('name').AsString]);
      isGroup := False;
      if ibdsAccount.FieldByName('ID').IsNull then
        exit
      else
        ID := ibdsAccount.FieldByName('ID').AsInteger;
    end;

    if MessageBox(HANDLE, PChar(aMessage), 'Внимание', mb_YesNo or mb_IconQuestion) = idYes
    then
    begin
      if isGroup then
      begin
        ibsql.Transaction := IBTransaction;
        ibsql.SQL.Text := Format('DELETE FROM gd_cardaccount WHERE ID = %d', [ID]);
        try
          ibsql.ExecQuery;
          ibdsGroupAccount.Close;
          ibdsGroupAccount.Open;
        except
          MessageBox(HANDLE, 'Невозможно удалить запись.', 'Внимание', mb_Ok or mb_IconExclamation);
        end;
      end
      else
        ibdsAccount.Delete;
      IBTransaction.CommitRetaining;    
    end;
  finally
    ibsql.Free;
  end;
end;

procedure TfrmAccount.gsibgrAccountDblClick(Sender: TObject);
begin
  if ibdsAccount.FieldByName('id').AsInteger > 0 then
    actEdit.Execute;
end;

procedure TfrmAccount.gsdbtvGroupAccountDblClick(Sender: TObject);
begin
  actEdit.Execute;
end;

procedure TfrmAccount.N6Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmAccount.LoadSettings;
begin
  inherited;
  UserStorage.LoadComponent(gsibgrAccount, gsibgrAccount.LoadFromStream);
end;

procedure TfrmAccount.SaveSettings;
begin
  inherited;
  UserStorage.SaveComponent(gsibgrAccount, gsibgrAccount.SaveToStream);
end;

procedure TfrmAccount.gsibgrAccountDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  //Accept := Source is TgsDBDragObject;
end;

procedure TfrmAccount.gsibgrAccountMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) and (Y > 20) then
    gsibgrAccount.BeginDrag(False);
end;

procedure TfrmAccount.gsibgrAccountStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  {if (gsibgrAccount.SelectedRows.Count > 0) and (ibdsAccount.State = dsBrowse) then
  begin
    DragObject := TgsDBDragObject.Create;
    (DragObject as TgsDBDragObject).BL := gsibgrAccount.SelectedRows;
  end;}
end;

procedure TfrmAccount.gsdbtvGroupAccountDragDrop(Sender, Source: TObject;
  X, Y: Integer);
begin
  {if (Source is TgsDBDragObject) and Assigned(gsdbtvGroupAccount.GetNodeAt(X, Y)) then
  begin
    ibsqlChangeGroupKey.Prepare;
    (Source as TgsDBDragObject).BL.Refresh;
    ibsqlChangeGroupKey.Params.ByName('p').AsInteger :=
      TgsDBTreeNode(gsdbtvGroupAccount.GetNodeAt(X, Y).Data).ID;

    for i:= 0 to (Source as TgsDBDragObject).BL.Count - 1 do
    begin
      ibdsAccount.GotoBookmark(Pointer((Source as TgsDBDragObject).BL.Items[i]));
      ibsqlChangeGroupKey.Params.ByName('id').AsInteger :=
        ibdsAccount.FieldByName('ID').AsInteger;
      ibsqlChangeGroupKey.ExecQuery;
      ibsqlChangeGroupKey.Close;
    end;

    IBTransaction.CommitRetaining;
    RefreshTree(-1);
    ShowAccount;
  end;}

end;

procedure TfrmAccount.gsdbtvGroupAccountDragOver(Sender, Source: TObject;
  X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  {Accept := (Source is TgsDBDragObject)
    and Assigned(gsdbtvGroupAccount.GetNodeAt(X, Y))
    and Assigned(gsdbtvGroupAccount.GetNodeAt(X, Y).Data)
    and (ibdsGroupAccount.State = dsBrowse)
    and (ibdsAccount.State = dsBrowse);}
end;

procedure TfrmAccount.actPlanForFirmExecute(Sender: TObject);
begin
  { Установки по плану счетов }
  with TdlgPlanForCompany.Create(Self) do
    try
      SetupDialog;
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfrmAccount.EditAccount(const isEdit: Boolean);
var
  aID, aParent, aGrade: Integer;
  ibsql: TIBSQL;
begin
  if gsdbtvGroupAccount.Focused then
  begin
    if Assigned(gsdbtvGroupAccount.Selected) and Assigned(gsdbtvGroupAccount.Selected.Data)
    then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := IBTransaction;
        ibsql.SQL.Text := Format('SELECT grade FROM gd_cardaccount WHERE id = %d',
          [gsdbtvGroupAccount.ID]);
        ibsql.ExecQuery;
        aGrade := ibsql.FieldByName('grade').AsInteger;
        ibsql.Close;
      finally
        ibsql.Free;
      end;

      if not isEdit then
      begin
        if aGrade = 0 then
          aParent := gsdbtvGroupAccount.ID
        else
          aParent := gsdbtvGroupAccount.ParentID;
        aID := -1;
      end
      else
      begin
        aID := gsdbtvGroupAccount.ID;
        aParent := gsdbtvGroupAccount.ParentID;
      end;

    end
    else
      if isEdit then
        exit
      else
      begin
        aParent := -1;
        aID := -1;
        aGrade := 0;
      end;

  end
  else
  begin
    if isEdit then
    begin
      aParent := ibdsAccount.FieldByName('Parent').AsInteger;
      aGrade := ibdsAccount.FieldByName('Grade').AsInteger;
      aID := ibdsAccount.FieldByName('ID').AsInteger;
    end
    else
    begin
      aID := -1;
      aGrade := 2;
      if Assigned(gsdbtvGroupAccount.Selected) and Assigned(gsdbtvGroupAccount.Selected.Data)
      then
        aParent := gsdbtvGroupAccount.ID
      else
        aParent := -1;
    end;
  end;

  with TdlgEditAccount.Create(Self) do
    try
      SetupDialog(aID, aID, aParent, aGrade);
      ShowModal;
      if isOk then
      begin
        if Grade < 2 then
          RefreshTree(ID)
        else
          if isEdit then
            Self.ibdsAccount.Refresh
          else
          begin
            Self.ibdsAccount.Close;
            Self.ibdsAccount.Open;
            Self.ibdsAccount.Locate('id', ID, []);
          end;
      end;
    finally
      Free;
    end;
end;

initialization
  RegisterClass(TfrmAccount);


end.
