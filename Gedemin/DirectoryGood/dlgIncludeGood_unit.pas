// ShlTanya, 29.01.2019

unit dlgIncludeGood_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security, Menus, StdCtrls, ExtCtrls, ActnList, ComCtrls, Db, dmDatabase_unit,
  IBCustomDataSet, IBQuery, ImgList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  IBSQL, gsDBTreeView, at_sql_setup;

type
  TdlgIncludeGood = class(TForm)
    pnlView: TPanel;
    Splitter1: TSplitter;
    ActionList1: TActionList;
    actGoodSet: TAction;
    pmGood: TPopupMenu;
    actGoodSet1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    actShowGroup: TAction;
    actShowGood: TAction;
    pnlButton: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    actInvert: TAction;
    actSelectAll: TAction;
    actClear: TAction;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    ilGoodGroup: TImageList;
    gsibgrGoods: TgsIBGrid;
    ibdsGoods: TIBDataSet;
    dsGoods: TDataSource;
    ibsqlInsertGoodSet: TIBSQL;
    tvGoodGroup: TgsDBTreeView;
    ibdsGroup: TIBDataSet;
    dsGroup: TDataSource;
    Timer: TTimer;
    atSQLSetup: TatSQLSetup;
    Panel3: TPanel;
    cbInclude: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure actShowGroupExecute(Sender: TObject);
    procedure tvGoodGroupKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actInvertExecute(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure tvGoodGroupGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure tvGoodGroupGetSelectedIndex(Sender: TObject;
      Node: TTreeNode);
    procedure TimerTimer(Sender: TObject);
    procedure cbIncludeClick(Sender: TObject);
    procedure tvGoodGroupChange(Sender: TObject; Node: TTreeNode);
  private
    { Private declarations }
    FGoodParent: TID;
    EndPoint: TID;
    SetKey: TID;
    isFirst: Boolean;
    procedure SetGood(aGroupKey, aLB, aRB: TID);
    procedure SetSQL;
  public
    { Public declarations }
    slGoodList: TStringList;
    ibdsGoodSet: TIBDataSet;

    procedure ActiveDialog(aIBDSGoodSet: TIBDataSet; aSetKey: TID);
  end;

var
  dlgIncludeGood: TdlgIncludeGood;

implementation

uses
  dlgCompleteGoodSet_unit, GroupType_unit, Storages;

{$R *.DFM}

procedure TdlgIncludeGood.FormCreate(Sender: TObject);
begin
  // Создание формы
  EndPoint := -1;
  slGoodList := TStringList.Create;
  FGoodParent := 0;
  isFirst := False;
  UserStorage.LoadComponent(gsibgrGoods, gsibgrGoods.LoadFromStream);
  cbInclude.Checked := UserStorage.ReadInteger('dlgIncludeGood', 'cbInclude', 0) = 1;
end;

procedure TdlgIncludeGood.ActiveDialog(aIBDSGoodSet: TIBDataSet; aSetKey: TID);
begin
  // Показ групп и товаров

  SetKey := aSetKey;
  SetSQL;
  ibdsGoodSet := aIBdsGoodSet;
  if Assigned(ibdsGoodSet) then
  begin
    ibdsGroup.Transaction := ibdsGoodSet.Transaction;
    ibdsGoods.Transaction := ibdsGoodSet.Transaction;
  end;

  actShowGroup.Execute;
end;

procedure TdlgIncludeGood.actShowGroupExecute(Sender: TObject);
begin
  ibdsGroup.Open;
end;

procedure TdlgIncludeGood.tvGoodGroupKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Открытие дерева по Вводу
  if (Key = 13) and ((Sender as TTreeView).Selected <> nil) then
  begin
    (Sender as TTreeView).Selected.Expanded := not
     (Sender as TTreeView).Selected.Expanded;
    Key := 0;
  end;
end;

procedure TdlgIncludeGood.FormDestroy(Sender: TObject);
begin
  // Освобождаем список выбранных товаров
  slGoodList.Free;
  UserStorage.SaveComponent(gsibgrGoods, gsibgrGoods.SaveToStream);
  UserStorage.WriteInteger('dlgIncludeGood', 'cbInclude', Integer(cbInclude.Checked));
end;

procedure TdlgIncludeGood.actSelectAllExecute(Sender: TObject);
var
  Bookmark: TBookmark;
begin
  // Отмечаем все товары
  Bookmark := ibdsGoods.GetBookmark;
  ibdsGoods.DisableControls;
  gsibgrGoods.CheckBox.CheckList.Clear;
  try
    ibdsGoods.First;
    while not ibdsGoods.EOF do
    begin
      gsibgrGoods.CheckBox.AddCheck(GetTID(ibdsGoods.FieldByName('ID')));
      ibdsGoods.Next;
    end;
  finally
    ibdsGoods.GotoBookmark(Bookmark);
    ibdsGoods.FreeBookmark(Bookmark);
    ibdsGoods.EnableControls;
  end;
end;

procedure TdlgIncludeGood.actClearExecute(Sender: TObject);
begin
  // Очищаем все товары
  gsibgrGoods.CheckBox.CheckList.Clear;
  gsibgrGoods.Refresh;
end;

procedure TdlgIncludeGood.actInvertExecute(Sender: TObject);
var
  Bookmark: TBookmark;
begin
  // Отмечаем все товары
  Bookmark := ibdsGoods.GetBookmark;
  ibdsGoods.DisableControls;
  try
    ibdsGoods.First;
    while not ibdsGoods.EOF do
    begin
      if not gsibgrGoods.CheckBox.RecordChecked then
        gsibgrGoods.CheckBox.AddCheck(GetTID(ibdsGoods.FieldByName('ID')))
      else
        gsibgrGoods.CheckBox.DeleteCheck(GetTID(ibdsGoods.FieldByName('ID')));
      ibdsGoods.Next;
    end;
  finally
    ibdsGoods.GotoBookmark(Bookmark);
    ibdsGoods.FreeBookmark(Bookmark);
    ibdsGoods.EnableControls;
  end;
end;

procedure TdlgIncludeGood.SetGood(aGroupKey, aLB, aRB: TID);
begin
  if tvGoodGroup.Selected <> nil then
  begin
    ibdsGoods.Close;
    if not cbInclude.Checked then
      SetTID(ibdsGoods.ParamByName('rangecode'), aGroupKey)
    else
    begin
      SetTID(ibdsGoods.ParamByName('lb'), aLB);
      SetTID(ibdsGoods.ParamByName('rb'), aRB);
    end;
    if SetKey <> -1 then
    begin
      SetTID(ibdsGoods.ParamByName('setkey1'), SetKey);
      SetTID(ibdsGoods.ParamByName('setkey2'), SetKey);
    end;  
    ibdsGoods.Open;
    if isFirst then
    begin
      ibdsGoods.Close;
      SetTID(ibdsGoods.ParamByName('lb'), aLB);
      SetTID(ibdsGoods.ParamByName('rb'), aRB);
      ibdsGoods.Open;
    end;  
  end;  
end;

procedure TdlgIncludeGood.btnOkClick(Sender: TObject);
var
  i: TID;
begin
  if SetKey <> -1 then
  begin
    ibsqlInsertGoodSet.Transaction := ibdsGoods.Transaction;
    for i:= 0 to gsibgrGoods.CheckBox.CheckCount - 1 do
    begin
      SetTID(ibsqlInsertGoodSet.Params.ByName('goodkey'), SetKey);
      SetTID(ibsqlInsertGoodSet.Params.ByName('setkey'), gsibgrGoods.CheckBox.IntCheck[i]);
      ibsqlInsertGoodSet.ExecQuery;
      ibsqlInsertGoodSet.Close;
    end;
  end;  
end;

procedure TdlgIncludeGood.tvGoodGroupGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Expanded then
    Node.ImageIndex := 1
  else
    Node.ImageIndex := 0;
end;

procedure TdlgIncludeGood.tvGoodGroupGetSelectedIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Expanded then
    Node.SelectedIndex := 1
  else
    Node.SelectedIndex := 0;
end;

procedure TdlgIncludeGood.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := False;
  if tvGoodGroup.Selected <> nil then
    SetGood(tvGoodGroup.ID,
      GetTID(ibdsGroup.FieldByName('lb')),
      GetTID(ibdsGroup.FieldByName('rb')));
end;

procedure TdlgIncludeGood.SetSQL;
begin
  if SetKey = -1 then
  begin
    Caption := 'Выбор товаров';
    if not cbInclude.Checked then
      ibdsGoods.SelectSQL.Text :=
        'SELECT ' +
        '  gg.* ' +
        'FROM ' +
        '  gd_good gg ' +
        'WHERE ' +
        '  gg.groupkey = :rangecode '
    else
      ibdsGoods.SelectSQL.Text :=
        'SELECT ' +
        '  gg.* ' +
        'FROM ' +
        '  gd_good gg ' +
        'WHERE ' +
        '  gg.groupkey IN (SELECT id FROM gd_goodgroup g WHERE g.lb >= :lb and g.rb <= :rb)';
  end
  else
  begin
    ibdsGoods.SelectSQL.Text :=
      'SELECT' +
      '  gg.*' +
      'FROM' +
      '  gd_good gg' +
      'WHERE ' +
      '  gg.groupkey = :rangecode ' +
      '  AND NOT' +
      '       EXISTS(SELECT * FROM gd_goodset WHERE ' +
      '       setkey = :setkey1 AND gg.id = goodkey) ' +
      '  AND gg.id <> :setkey2 ';
  end;

end;

procedure TdlgIncludeGood.cbIncludeClick(Sender: TObject);
begin
  ibdsGoods.Close;
  SetSQL;
  if cbInclude.Checked then
    isFirst := True;
  if tvGoodGroup.Selected <> nil then
    SetGood(tvGoodGroup.ID, GetTID(ibdsGroup.FieldByName('lb')),
      GetTID(ibdsGroup.FieldByName('rb')));
  isFirst := False;
end;

procedure TdlgIncludeGood.tvGoodGroupChange(Sender: TObject;
  Node: TTreeNode);
begin
  SetGood(tvGoodGroup.ID,
    GetTID(ibdsGroup.FieldByName('lb')),
    GetTID(ibdsGroup.FieldByName('rb')));
end;

end.
