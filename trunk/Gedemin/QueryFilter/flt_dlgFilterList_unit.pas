unit flt_dlgFilterList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ComCtrls, gd_security, Db, IBCustomDataSet, IBQuery,
  flt_dlgShowFilter_unit, IBSQL, Menus, ExtCtrls;

type
  TdlgFilterList = class(TForm)
    alFilter: TActionList;
    acDelete: TAction;
    acEdit: TAction;
    actSelect: TAction;
    ibsqlFilter: TIBSQL;
    pm: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Panel1: TPanel;
    lvFilter: TListView;
    pnlRightButtons: TPanel;
    btnEdit: TButton;
    btnDelete: TButton;
    btnSelect: TButton;
    btnClose: TButton;
    actNew: TAction;
    btnNew: TButton;
    N4: TMenuItem;
    procedure acEditExecute(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);
    procedure actSelectExecute(Sender: TObject);
    procedure lvFilterDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure acDeleteUpdate(Sender: TObject);
    procedure acEditUpdate(Sender: TObject);
    procedure actSelectUpdate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actNewUpdate(Sender: TObject);
  private
    FComponentKey: Integer;
    FChange: Boolean;
    FDialogFilter: TdlgShowFilter;
    FSQLText: String;
    procedure ShowFilter(SelKey: Integer);
    function GetUserKey: String;
  public
    function ViewFilterList(const ComponentKey: Integer; var ChangeFlag: Boolean; const AnSQLText: String): Integer;
  end;

var
  dlgFilterList: TdlgFilterList;

implementation

{$R *.DFM}

uses
  gd_directories_const,
  flt_sqlFilter
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

// Получаем ключ пользователя
function TdlgFilterList.GetUserKey: String;
begin
  if IBLogin <> nil then
    Result := IntToStr(IBLogin.UserKey)
  else
    Result := IntToStr(ADMIN_KEY);
end;

// Выводим список фильтров
procedure TdlgFilterList.ShowFilter(SelKey: Integer);
var
  L: TListItem;
  Flag: Boolean;
begin
  // Вытягиваем список
  ibsqlFilter.Close;
  ibsqlFilter.Params.ByName('componentkey').AsInteger := FComponentKey;
  ibsqlFilter.Params.ByName('userkey').AsString := GetUserKey;
  ibsqlFilter.ExecQuery;
  lvFilter.Items.BeginUpdate;
  lvFilter.Items.Clear;
  Flag := False;
  // Визуальное отображение
  while not ibsqlFilter.Eof do
  begin
    L := lvFilter.Items.Add;
    L.Caption := ibsqlFilter.FieldByName('name').AsString;
    L.SubItems.Add(ibsqlFilter.FieldByName('lastextime').AsString);
    L.SubItems.Add(ibsqlFilter.FieldByName('readcount').AsString);
    L.Data := Pointer(ibsqlFilter.FieldByName('id').AsInteger);
    if SelKey = Integer(L.Data) then
    begin
      L.Selected := True;
      Flag := True;
    end;
    ibsqlFilter.Next;
  end;
  lvFilter.Items.EndUpdate;
  if not Flag and (lvFilter.Items.Count > 0) then
    lvFilter.Items[0].Selected := True;
end;

function TdlgFilterList.ViewFilterList(const ComponentKey: Integer; var ChangeFlag: Boolean; const AnSQLText: String): Integer;
begin
  // Присваиваем локальные переменные
  FChange := False;
  FComponentKey := ComponentKey;
  FSQLText := AnSQLText;
  // Выводим список
  ShowFilter(0);
  // Присваиваем результат
  if (ShowModal = mrOk) and (lvFilter.Selected <> nil) then
    Result := Integer(lvFilter.Selected.Data)
  else
    Result := 0;
  ChangeFlag := FChange;
end;

procedure TdlgFilterList.acEditExecute(Sender: TObject);
var
  LocRes: Boolean;
begin
  if lvFilter.Selected = nil then
    Exit;

  FDialogFilter.Database := ibsqlFilter.Database;
  FDialogFilter.Transaction := ibsqlFilter.Transaction;
  // Вызываем редактирование фильтра
  FDialogFilter.EditFilter(Integer(lvFilter.Selected.Data), FSQLText, nil, True, LocRes);
  if LocRes then
  begin
    ShowFilter(Integer(lvFilter.Selected.Data));
    FChange := True;
  end;
end;

procedure TdlgFilterList.acDeleteExecute(Sender: TObject);
begin
  if lvFilter.Selected = nil then
    Exit;

  FDialogFilter.Database := ibsqlFilter.Database;
  FDialogFilter.Transaction := ibsqlFilter.Transaction;
  // Вызываем удаление фильтра
  if FDialogFilter.DeleteFilter(Integer(lvFilter.Selected.Data)) then
  begin
    ShowFilter(0);
    FChange := True;
  end;
end;

procedure TdlgFilterList.actSelectExecute(Sender: TObject);
begin
  if lvFilter.Selected = nil then
  begin
    MessageBox(Self.Handle, 'Не выбран фильтр', 'Внимание', MB_OK or MB_ICONINFORMATION);
    ModalResult := mrNone;
  end else
    FChange := True;
end;

procedure TdlgFilterList.lvFilterDblClick(Sender: TObject);
begin
  acEdit.Execute;
end;

procedure TdlgFilterList.FormCreate(Sender: TObject);
begin
  FDialogFilter := TdlgShowFilter.Create(Self);
end;

procedure TdlgFilterList.FormDestroy(Sender: TObject);
begin
  FDialogFilter.Free;
end;

procedure TdlgFilterList.N3Click(Sender: TObject);
begin
  actSelect.Execute;
  ModalResult := mrOk;
end;

procedure TdlgFilterList.acDeleteUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (lvFilter.Selected <> nil)
    and (IBLogin <> nil) and IBLogin.IsUserAdmin;
end;

procedure TdlgFilterList.acEditUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lvFilter.Selected <> nil;
end;

procedure TdlgFilterList.actSelectUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lvFilter.Selected <> nil;
end;

procedure TdlgFilterList.actNewExecute(Sender: TObject);
begin
  if (Self.Owner <> nil) and (Self.Owner is TgsQueryFilter) then
  begin
    (Self.Owner as TgsQueryFilter).CreateFilterExecute;
    ShowFilter(0);
    FChange := True;
  end;
end;

procedure TdlgFilterList.actNewUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (Self.Owner <> nil) and (Self.Owner is TgsQueryFilter);
end;

end.
