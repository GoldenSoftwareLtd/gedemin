 {++
   Project ADDRESSBOOK
   Copyright © 2000- by Golden Software

   Модуль

     dlgSelectAttr_unit

   Описание

     Окно для выбора элемента множества или множества

   Автор

     Shadevsky Andrey

   История

     ver    date    who    what
     1.00 - 14.06.2000 - jkl - Первая версия

 --}

unit gd_attrcb_dlgSelectAttr_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, IBCustomDataSet, IBQuery, ComCtrls, ExtCtrls, StdCtrls,
  Menus, ActnList, gd_security, IBSQL;

const
  TreeLeftBorder = 'LB';
  TreeRightBorder = 'RB';
  ViewCount = 50;

type
  TdlgSelectAttr = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edName: TEdit;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    Image1: TImage;
    ibqryFind: TIBQuery;
    PopupMenu1: TPopupMenu;
    ActionList1: TActionList;
    Panel4: TPanel;
    lItemsCount: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    actFind: TAction;
    cbCondition: TComboBox;
    Label2: TLabel;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    tvAttrSet: TTreeView;
    Button3: TButton;
    actNext: TAction;
    btnProperty: TButton;
    Button4: TButton;
    Button5: TButton;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure edNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvAttrSetDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
  private
    FIsTree: Boolean;
    FAttrKey: Integer;
    FParentList: TList;

    procedure ShowAttrSet;
    procedure ShowFind(Qry: Boolean);
    procedure Draw500Item;
  public
    function GetElement(const AnAttrKey: Integer; var SetName: String): Integer;
  end;

var
  dlgSelectAttr: TdlgSelectAttr;

implementation

uses
  gd_dlgAttrElement_unit;

{$R *.DFM}

// Вывод всех атрибутов
procedure TdlgSelectAttr.ShowAttrSet;
begin
  // Выполнение запроса
  ibqryFind.Close;
  ibqryFind.SQL.Clear;
  ibqryFind.SQL.Text := 'SELECT * FROM gd_attrset WHERE attrkey = ' + IntToStr(FAttrKey);
  ibqryFind.SQL.Add('ORDER BY lb');
  ibqryFind.Open;

  // Визуальное отображение

  tvAttrSet.Items.BeginUpdate;
  tvAttrSet.Items.Clear;

  ibqryFind.First;
  Draw500Item;

  tvAttrSet.ShowLines := FIsTree;
  tvAttrSet.Items.EndUpdate;
end;

// Вывод результата поиска
procedure TdlgSelectAttr.ShowFind(Qry: Boolean);
begin
  // Выполнение запроса
  if Qry then
  begin
    ibqryFind.Close;
    ibqryFind.SQL.Clear;
    ibqryFind.SQL.Text := 'SELECT DISTINCT(gg2.id), gg2.* FROM gd_attrset gg1, '
     + 'gd_attrset gg2 WHERE gg1.attrkey = ' + IntToStr(FAttrKey)
     + 'AND gg2.attrkey = ' + IntToStr(FAttrKey) + ' AND ';

    case cbCondition.ItemIndex of
    0: ibqryFind.SQL.Add('UPPER(gg1.name) LIKE '''
     + AnsiUpperCase(edName.Text) + '%''');
    1: ibqryFind.SQL.Add('gg1.name CONTAINING ''' + edName.Text + '''');
    2: ibqryFind.SQL.Add('UPPER(gg1.name) LIKE ''%'
     + AnsiUpperCase(edName.Text) + '''');
    end;
    ibqryFind.SQL.Add('AND gg2.lb <= gg1.lb AND gg2.rb >= gg1.rb ORDER BY gg2.lb');
    ibqryFind.Open;
  end;

  tvAttrSet.Items.BeginUpdate;
  tvAttrSet.Items.Clear;

  // Визуальное отображение
  ibqryFind.First;
  FParentList.Clear;

  Draw500Item;

  tvAttrSet.ShowLines := FIsTree;
  tvAttrSet.FullExpand;
  tvAttrSet.Items.EndUpdate;
end;

procedure TdlgSelectAttr.Draw500Item;
var
  L: TTreeNode;
  I: Integer;
begin
  I := 0;
  while not ibqryFind.Eof and (I < ViewCount) do
  begin
    if ibqryFind.FieldByName('parent').IsNull then
      FParentList.Clear
    else
      while (FParentList.Count > 0) and
       (ibqryFind.FieldByName('parent').AsInteger <>
       Integer(TTreeNode(FParentList.Items[FParentList.Count - 1]).Data)) do
        FParentList.Delete(FParentList.Count - 1);
    if FParentList.Count = 0 then
      L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName('name').AsString)
    else
    begin
      L := tvAttrSet.Items.AddChild(TTreeNode(FParentList.Items[FParentList.Count - 1]),
       ibqryFind.FieldByName('name').AsString);
      FIsTree := True;
    end;
    FParentList.Add(L);
    L.Data := Pointer(ibqryFind.FieldByName('id').AsInteger);

    Inc(I);
    ibqryFind.Next;
  end;
end;

// Основная функция проекта
function TdlgSelectAttr.GetElement(const AnAttrKey: Integer; var SetName: String): Integer;
begin
  FIsTree := False;
  Result := -1;
  FAttrKey := AnAttrKey;
  edName.Text := SetName;

  tvAttrSet.ShowLines := FIsTree;
  // Если параметр поиска не задан
  if SetName = '' then
  begin
    //ShowAttrSet;
    // Результат
    if ShowModal = mrOk then
    begin
      if tvAttrSet.Selected <> nil then
      begin
        Result := Integer(tvAttrSet.Selected.Data);
        SetName := tvAttrSet.Selected.Text;
      end;
    end
  end else begin
    // Если параметр поиска задан
    // , то поиск
    cbCondition.ItemIndex := 1;
    ibqryFind.Close;
    ibqryFind.SQL.Text := 'SELECT * FROM gd_attrset WHERE attrkey = ' + IntToStr(FAttrKey);
    ibqryFind.SQL.Add('AND name CONTAINING ''' + edName.Text + '''');
    ibqryFind.Open;

    // Если ничего не найдено
    ibqryFind.First;
    if ibqryFind.Eof then
    begin
      if (ShowModal = mrOk) then
        if tvAttrSet.Selected <> nil then
        begin
          Result := Integer(tvAttrSet.Selected.Data);
          SetName := tvAttrSet.Selected.Text;
        end;
    end else
    begin
      ibqryFind.Next;
      // Если найдено больше одной записи
      if (not ibqryFind.Eof) then
      begin
        ShowFind(FIsTree);
        if (ShowModal = mrOk) then
          if tvAttrSet.Selected <> nil then
          begin
            Result := Integer(tvAttrSet.Selected.Data);
            SetName := tvAttrSet.Selected.Text;
          end;
      // Если найдена одна запись
      end else begin
        Result := ibqryFind.FieldByName('id').AsInteger;
        SetName := ibqryFind.FieldByName('name').AsString;
      end;
    end;
  end;
end;

// Выводим все атрибуты
procedure TdlgSelectAttr.Button2Click(Sender: TObject);
begin
  ShowAttrSet;
  edName.Text := '';
end;

procedure TdlgSelectAttr.FormCreate(Sender: TObject);
begin
  cbCondition.ItemIndex := 0;
  FParentList := TList.Create;
end;

procedure TdlgSelectAttr.actFindExecute(Sender: TObject);
begin
  ShowFind(True);
end;

procedure TdlgSelectAttr.actFindUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := edName.Text > '';
  btnOk.Enabled := (tvAttrSet.Selected <> nil);
end;

procedure TdlgSelectAttr.edNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    actFind.Execute;
    Key := 0;
  end;
end;

procedure TdlgSelectAttr.tvAttrSetDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TdlgSelectAttr.FormDestroy(Sender: TObject);
begin
  FParentList.Free;
end;

procedure TdlgSelectAttr.actNextExecute(Sender: TObject);
begin
  Draw500Item;
end;

procedure TdlgSelectAttr.actNextUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not ibqryFind.Eof;
end;

procedure TdlgSelectAttr.actAddExecute(Sender: TObject);
begin
  with Tgd_dlgAttrElement.Create(Self) do
  try
    SetDatabase(ibqryFind.Database, ibqryFind.Transaction);
    if AddElement(FAttrKey) then
      tvAttrSet.Items.Clear;
  finally
    Free;
  end;
end;

procedure TdlgSelectAttr.actEditExecute(Sender: TObject);
begin
  if tvAttrSet.Selected = nil then
    Exit;
  with Tgd_dlgAttrElement.Create(Self) do
  try
    SetDatabase(ibqryFind.Database, ibqryFind.Transaction);
    if EditElement(Integer(tvAttrSet.Selected.Data)) then
      tvAttrSet.Selected.Text := dbeName.Text;
  finally
    Free;
  end;
end;

procedure TdlgSelectAttr.actDeleteExecute(Sender: TObject);
begin
  if tvAttrSet.Selected = nil then
    Exit;
  with Tgd_dlgAttrElement.Create(Self) do
  try
    SetDatabase(ibqryFind.Database, ibqryFind.Transaction);
    if DeleteElement(Integer(tvAttrSet.Selected.Data)) then
      tvAttrSet.Selected.Delete;
  finally
    Free;
  end;
end;

procedure TdlgSelectAttr.actEditUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := tvAttrSet.Selected <> nil;
end;

end.
