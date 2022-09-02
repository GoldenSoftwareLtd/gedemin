 // ShlTanya, 20.02.2019, #4135

 {++
   Project ADDRESSBOOK
   Copyright © 2000-2019 by Golden Software

   Модуль

     dlgSelectAttrSet_unit

   Описание

     Окно для выбора элемента множества или множества

   Автор

     Shadevsky Andrey

   История

     ver    date    who    what
     1.00 - 14.06.2000 - jkl - Первая версия

 --}

unit gd_attrcb_dlgSelectF_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, IBCustomDataSet, IBQuery, ComCtrls, ExtCtrls, StdCtrls,
  Menus, ActnList, gd_security, IBSQL, gdcBaseInterface;

const
  TreeLeftBorder = 'LB';
  TreeRightBorder = 'RB';
  ViewCount = 50;

type
  TdlgSelectF = class(TForm)
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
    ibsqlTree: TIBSQL;
    tvAttrSet: TTreeView;
    Button3: TButton;
    actNext: TAction;
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure edNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvAttrSetDblClick(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
  private
    OkEn: Boolean;
    FTableName: String;
    FFieldName: String;
    FPrimaryName: String;
    FIsTree: Boolean;
    FParentList: TList;

    procedure ShowAttrSet;
    procedure ShowFind(Qry: Boolean);
    procedure Draw500Item;
  public
    destructor Destroy; override;
    function GetElement(const NameOfTable, NameOfField,
     NameOfPrimary: String; var SetName: String): TID;
  end;

var
  dlgSelectF: TdlgSelectF;

implementation

{$R *.DFM}

destructor TdlgSelectF.Destroy;
begin
  FParentList.Free;
  {$IFDEF ID64}
  FreeConvertContext(Name); 
  {$ENDIF}  
  inherited;
end;

// Вывод всех атрибутов
procedure TdlgSelectF.ShowAttrSet;
begin
  // Выполнение запроса
  ibqryFind.Close;
  ibqryFind.SQL.Clear;
  ibqryFind.SQL.Text := 'SELECT * FROM ' + FTableName;
  if FIsTree then
    ibqryFind.SQL.Add('ORDER BY lb');
  ibqryFind.Open;

  // Визуальное отображение

  tvAttrSet.Items.BeginUpdate;
  tvAttrSet.Items.Clear;

  ibqryFind.First;
  Draw500Item;

  tvAttrSet.Items.EndUpdate;
end;

// Вывод результата поиска
procedure TdlgSelectF.ShowFind(Qry: Boolean);
begin
  // Выполнение запроса
  if Qry then
  begin
    ibqryFind.Close;                            
    ibqryFind.SQL.Clear;
    if not FIsTree then
      ibqryFind.SQL.Text := 'SELECT gg1.* FROM ' + FTableName + ' gg1 WHERE '
    else
      ibqryFind.SQL.Text := 'SELECT DISTINCT(gg2.id), gg2.* FROM ' + FTableName + ' gg1, '
        + FTableName + ' gg2 WHERE ';

    case cbCondition.ItemIndex of
    0: ibqryFind.SQL.Add('UPPER(gg1.' + FFieldName + ') LIKE '''
     + AnsiUpperCase(edName.Text) + '%''');
    1: ibqryFind.SQL.Add('gg1.' + FFieldName + ' CONTAINING ''' + edName.Text + '''');
    2: ibqryFind.SQL.Add('UPPER(gg1.' + FFieldName + ') LIKE ''%'
     + AnsiUpperCase(edName.Text) + '''');
    end;
    if FIsTree then
      ibqryFind.SQL.Add('AND gg2.lb <= gg1.lb AND gg2.rb >= gg1.rb ORDER BY gg2.lb');
    ibqryFind.Open;
  end;

  tvAttrSet.Items.BeginUpdate;
  tvAttrSet.Items.Clear;

  // Визуальное отображение
  ibqryFind.First;
  FParentList.Clear;

  Draw500Item;

  tvAttrSet.FullExpand;
  tvAttrSet.Items.EndUpdate;
end;

procedure TdlgSelectF.Draw500Item;
var
  L: TTreeNode;
  I: Integer;
begin
  I := 0;
  while not ibqryFind.Eof and (I < ViewCount) do
  begin
    if not FIsTree then
      L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName(FFieldName).AsString)
    else
    begin
      if ibqryFind.FieldByName('parent').IsNull then
        FParentList.Clear
      else
        while (FParentList.Count > 0) and
         (GetTID(ibqryFind.FieldByName('parent')) <>
         GetTID(TTreeNode(FParentList.Items[FParentList.Count - 1]).Data, Name)) do
          FParentList.Delete(FParentList.Count - 1);
      if FParentList.Count = 0 then
        L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName(FFieldName).AsString)
      else
        L := tvAttrSet.Items.AddChild(TTreeNode(FParentList.Items[FParentList.Count - 1]),
         ibqryFind.FieldByName(FFieldName).AsString);
      FParentList.Add(L);
    end;
    L.Data := TID2Pointer(GetTID(ibqryFind.FieldByName(FPrimaryName)), Name);

    Inc(I);
    ibqryFind.Next;
  end;
end;

// Основная функция проекта
function TdlgSelectF.GetElement(const NameOfTable, NameOfField,
 NameOfPrimary: String; var SetName: String): TID;
begin
  FIsTree := False;
  Result := -1;
  FTableName := Trim(NameOfTable);
  FFieldName := Trim(NameOfField);
  FPrimaryName := Trim(NameOfPrimary);
  edName.Text := SetName;

  ibsqlTree.Close;
  ibsqlTree.Params[0].AsString := AnsiUpperCase(FTableName);
  try
    ibsqlTree.ExecQuery;
    FIsTree := ibsqlTree.Fields[0].AsInteger = 1;
  except
  end;
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
        Result := GetTID(tvAttrSet.Selected.Data, Name);
        SetName := tvAttrSet.Selected.Text;
      end;
    end
  end else begin
    // Если параметр поиска задан
    // , то поиск
    cbCondition.ItemIndex := 1;
    ibqryFind.Close;
    ibqryFind.SQL.Text := 'SELECT * FROM ' + FTableName + ' WHERE ';
    ibqryFind.SQL.Add(FFieldName + ' CONTAINING ''' + edName.Text + '''');
    ibqryFind.Open;

    // Если ничего не найдено
    ibqryFind.First;
    if ibqryFind.Eof then
    begin
      if (ShowModal = mrOk) then
        if tvAttrSet.Selected <> nil then
        begin
          Result := GetTID(tvAttrSet.Selected.Data, Name);
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
            Result := GetTID(tvAttrSet.Selected.Data, Name);
            SetName := tvAttrSet.Selected.Text;
          end;
      // Если найдена одна запись
      end else begin
        Result := GetTID(ibqryFind.FieldByName(Trim(FPrimaryName)));
        SetName := ibqryFind.FieldByName(Trim(FFieldName)).AsString;
      end;
    end;
  end;
end;

// Выводим все атрибуты
procedure TdlgSelectF.Button2Click(Sender: TObject);
begin
  ShowAttrSet;
  edName.Text := '';
end;

procedure TdlgSelectF.FormCreate(Sender: TObject);
begin
  OkEn := False;
  cbCondition.ItemIndex := 0;
  FParentList := TList.Create;
end;

procedure TdlgSelectF.actFindExecute(Sender: TObject);
begin
  ShowFind(True);
end;

procedure TdlgSelectF.actFindUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := edName.Text > '';
  btnOk.Enabled := OkEn or (tvAttrSet.Selected <> nil);
end;

procedure TdlgSelectF.edNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    actFind.Execute;
    Key := 0;
  end;
end;

procedure TdlgSelectF.tvAttrSetDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;


procedure TdlgSelectF.actNextExecute(Sender: TObject);
begin
  Draw500Item;
end;

procedure TdlgSelectF.actNextUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not ibqryFind.Eof;
end;

end.
