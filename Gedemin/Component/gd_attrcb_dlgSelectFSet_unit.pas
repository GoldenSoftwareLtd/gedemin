// ShlTanya, 10.02.2019, #4135

 {++

   Project ADDRESSBOOK
   Copyright © 2000-2019 by Golden Software of Belarus, Ltd

   Модуль

     gd_attrcb_dlgSelectFSet_unit.pas

   Описание

     Окно для выбора множества элементов

   Автор

     Shadevsky Andrey

   История

     ver    date    who    what
     1.00 - 14.06.2000 - JKL - Первая версия
     1.01 - 03.11.2001 - JKL - Оптимизирован запрос. Условие добавлено.

 --}

unit gd_attrcb_dlgSelectFSet_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, IBCustomDataSet, IBQuery, ComCtrls, ExtCtrls, StdCtrls,
  Menus, ActnList, gd_security, IBSQL, ImgList, gdcBaseInterface, Buttons;

const
  TreeLeftBorder = 'LB';
  TreeRightBorder = 'RB';
  ViewCount = 250;

type
  TdlgSelectFSet = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    edName: TEdit;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    ActionList1: TActionList;
    btnOk: TButton;
    btnCancel: TButton;
    ibqryFind: TIBQuery;
    actFind: TAction;
    cbCondition: TComboBox;
    Label2: TLabel;
    Button6: TButton;
    actTo: TAction;
    actFrom: TAction;
    Button7: TButton;
    ibsqlTree: TIBSQL;
    tvAttrSet: TTreeView;
    Button3: TButton;
    actNext: TAction;
    ibsqlTarget: TIBSQL;
    tvTarget: TTreeView;
    ImageList1: TImageList;
    btnFind: TButton;
    btnAll: TButton;
    actToAll: TAction;
    Button1: TButton;
    actFromAll: TAction;
    Button2: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ibsqlSimpleTree: TIBSQL;
    actExpand: TAction;
    actCollapse: TAction;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    lblSelCount: TLabel;
    procedure btnAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure edNameKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure actToExecute(Sender: TObject);
    procedure actFromExecute(Sender: TObject);
    procedure tvAttrSetDblClick(Sender: TObject);
    procedure lvTargetDblClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actNextUpdate(Sender: TObject);
    procedure actFromUpdate(Sender: TObject);
    procedure actToUpdate(Sender: TObject);
    procedure actToAllExecute(Sender: TObject);
    procedure actToAllUpdate(Sender: TObject);
    procedure actFromAllExecute(Sender: TObject);
    procedure actFromAllUpdate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure edNameEnter(Sender: TObject);
    procedure edNameExit(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure actExpandExecute(Sender: TObject);
    procedure actCollapseExecute(Sender: TObject);
    procedure tvAttrSetKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tvTargetKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    FIsIntervalTree: Boolean;
    FIsSimpleTree: Boolean;
    FTableName: String;
    FFieldName: String;
    FPrimaryName: String;
    FParentList: TList;
    FValueList: TStringList;
    FCondition, FSortOrder, FSortField: String;

    procedure ShowAttrSet;
    procedure ShowFind(Qry: Boolean);
    procedure ShowTargetList(SL: TStrings);
    function CheckValue(StartP, EndP, Value: TID): Integer;
    procedure Draw500Item;
    function SetAliasPrefix(AnCondition, AnAlias: String): String;
    function FieldWithAlias(AFieldName, AAlias: String): String;
    function FindInTreeView(TreeView: TTreeView; Value: TID): Integer;

  public
    function GetElements(var SetList: TStrings; const TableName, FieldName,
     PrimaryName, ACondition, ASortField, ASortOrder, AContext: String): Boolean;
  end;

var
  dlgSelectFSet: TdlgSelectFSet;
  //FreeConvertContext вызывается из формы-родителя gd_AttrComboBox
  FContext: string;

  function ValueListCompare(List: TStringList; Index1, Index2: Integer): Integer;

implementation

uses
  at_Classes;

{$R *.DFM}


procedure TdlgSelectFSet.Draw500Item;
var
  L: TTreeNode;
  I: Integer;
begin
  I := 0;
  while not ibqryFind.Eof and (I < ViewCount) do
  begin
    if not (FIsIntervalTree or FIsSimpleTree ) then
    begin
      L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName(FFieldName).AsString);
      L.ImageIndex := 1;
      L.SelectedIndex := 3;
    end else
    begin
      if ibqryFind.FieldByName('parent').IsNull then
        FParentList.Clear
      else
        while (FParentList.Count > 0) and
         (GetTID(ibqryFind.FieldByName('parent')) <>
         GetTID(TTreeNode(FParentList.Items[FParentList.Count - 1]).Data, FContext)) do
          FParentList.Delete(FParentList.Count - 1);
      if FParentList.Count = 0 then
      begin
        L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName(FFieldName).AsString);
        L.ImageIndex := 1;
        L.SelectedIndex := 3;
      end
      else
      begin
        L := tvAttrSet.Items.AddChild(TTreeNode(FParentList.Items[FParentList.Count - 1]),
         ibqryFind.FieldByName(FFieldName).AsString);
        L.ImageIndex := 1;
        L.SelectedIndex := 3;
        if TTreeNode(FParentList.Items[FParentList.Count - 1]).ImageIndex <> 4 then
        begin
          TTreeNode(FParentList.Items[FParentList.Count - 1]).ImageIndex := 0;
          TTreeNode(FParentList.Items[FParentList.Count - 1]).SelectedIndex := 2;
        end;
      end;

      FParentList.Add(L);
    end;
    L.Data := TID2Pointer(GetTID(ibqryFind.FieldByName(FPrimaryName)), FContext);

    if CheckValue(0, FValueList.Count - 1,
        GetTID(ibqryFind.FieldByName(FPrimaryName))) <> -1 then begin
        L.ImageIndex := 4;
        L.SelectedIndex := 4;
    end;

    Inc(I);
    ibqryFind.Next;
  end;

  if (FIsIntervalTree) or ((FSortField = '') and (FSortOrder = '') and (not FIsSimpleTree)) then
    tvAttrSet.AlphaSort;

end;

procedure TdlgSelectFSet.ShowTargetList(SL: TStrings);
var
  L: TTreeNode;
  I: Integer;
  TempList: TStrings;
  TargetParentList: TList;
  S: String;
begin
  if SL.Count = 0 then
  begin
    tvTarget.Items.BeginUpdate;
    tvTarget.Items.Clear;
    tvTarget.Items.EndUpdate;
    Exit;
  end;
  // Визуадьное отображение начального списка
  ibsqlTarget.Close;
  ibsqlTarget.SQL.Clear;

  // В модифицированном запросе существует один нюанс. Если сумма будет равна 0,
  // то данные будут неверно отображаться. Можно попробывать что нибудь с булевой
  // алгеброй попробывать, желательно без создания новых функций в GUDF.dll.
  // Зато данный запрос позволяет получить выйгрыш в скорости в 1.5 раза.

  // JKL: !!!Классно!!! Только результат не правильный возвращает в принципе.
  // Востановлен старый

  TempList := TStringList.Create;
  try
    for I := 0 to SL.Count - 1 do
    begin
      TempList.Add(TID2S(GetTID(SL.Objects[I], FContext)));
      TempList.Add(',');
    end;
    TempList.Strings[TempList.Count - 1] := ')';

    if FIsIntervalTree then
    begin
      ibsqlTarget.SQL.Text := 'SELECT gg2.' + FPrimaryName +
       ', CASE WHEN gg2.Id IN ( ';
       ibsqlTarget.SQL.AddStrings(TempList);
       ibsqlTarget.SQL.Text := ibsqlTarget.SQL.Text +
       ' THEN 0 ELSE 1 END as isinclude, gg2.lb, gg2.parent, gg2.rb, gg2.' +
       FFieldName + ' FROM ' + FTableName + ' gg1, ' + FTableName + ' gg2 ';
    end
    else if FIsSimpleTree then
      begin
        ibsqlTarget.SQL.Text := 'SELECT gg1.*, CASE WHEN gg1.Id IN ( ';
        ibsqlTarget.SQL.AddStrings(TempList);
        ibsqlTarget.SQL.Text := ibsqlTarget.SQL.Text +
          ' THEN 0 ELSE 1 END as isinclude FROM ' + FTableName + ' gg1 ' +
          ' JOIN (WITH RECURSIVE INTERNAL_TREE AS ' +
          ' ( SELECT Id,Parent FROM ' + FTableName + ' WHERE ' + FPrimaryName + ' IN(';
        ibsqlTarget.SQL.AddStrings(TempList);
        ibsqlTarget.SQL.Text := ibsqlTarget.SQL.Text +
          '   UNION ALL ' +
          '   SELECT Z.Id,Z.Parent FROM ' + FTableName +' Z ' +
          '   JOIN INTERNAL_TREE IT ON IT.Parent = Z.Id) ' +
          ' SELECT distinct Id FROM INTERNAL_TREE) Z2 ON gg1.Id  =  Z2.ID ' +
          ' JOIN ( WITH RECURSIVE INTERNAL_TREE (Id, level) AS ' +
          ' (SELECT ID, 0 as level FROM ' + FTableName+' WHERE ID IN (SELECT ID FROM '+FTableName+' WHERE Parent is null) '+
          '   UNION ALL ' +
          '   SELECT Z.ID, level+1 as level FROM ' + FTableName +' Z '+
          '   JOIN INTERNAL_TREE IT  ON IT.Id = Z.Parent) ' +
          ' SELECT ID, level FROM INTERNAL_TREE ) Z1 ON gg1.ID  =  Z1.ID WHERE (1=1) ';
      end
    else
      ibsqlTarget.SQL.Text := 'SELECT gg1.*, 0 isinclude FROM ' + FTableName + ' gg1';

    if not FIsSimpleTree then
    begin
      ibsqlTarget.SQL.Add('WHERE gg1.' + FPrimaryName + ' IN(');
      ibsqlTarget.SQL.AddStrings(TempList);
    end;

    if FIsIntervalTree then
    begin
      ibsqlTarget.SQL.Add('AND gg2.lb <= gg1.lb AND gg2.rb >= gg1.rb');
// Кусок старого запроса <--
      S := ibsqlTarget.SQL.Text;
      ibsqlTarget.SQL.Add('AND gg2.' + FPrimaryName + ' NOT IN (');
      ibsqlTarget.SQL.AddStrings(TempList);
//-->
      if Trim(FCondition) > '' then
      begin
        ibsqlTarget.SQL.Add(' AND ' + SetAliasPrefix(FCondition, 'gg1'));
        // Вот так, вот. Типа вместо OR.
        // Можно попробывать в фильтры такую обработку вставить.
        // Либо дятлам послать suggestion.
        ibsqlTarget.SQL.Add('UNION');
        ibsqlTarget.SQL.Add(S);
        ibsqlTarget.SQL.Add('AND gg2.' + FPrimaryName + ' IN (');
        ibsqlTarget.SQL.AddStrings(TempList);
        ibsqlTarget.SQL.Add(' AND NOT(' + SetAliasPrefix(FCondition, 'gg1') + ')');
      end;
      //ibsqlTarget.SQL.Add ('ORDER BY NAME DESC')

// Кусок старого запроса <--
      ibsqlTarget.SQL.Add('UNION');
      ibsqlTarget.SQL.Add('SELECT gg1.' + FPrimaryName + ', 0 isinclude, gg1.lb, ' +
       ' gg1.parent, gg1.rb, gg1.' + FFieldName + ' FROM ' + FTableName + ' gg1 ');
      ibsqlTarget.SQL.Add('WHERE gg1.' + FPrimaryName + ' IN(');
      ibsqlTarget.SQL.AddStrings(TempList);
      if Trim(FCondition) > '' then
        ibsqlTarget.SQL.Add(' AND ' + SetAliasPrefix(FCondition, 'gg1'));
      ibsqlTarget.SQL.Add(' ORDER BY 3');
// -->

// Кусок нового кода <--
{      ibsqlTarget.SQL.Add(' GROUP BY gg2.' + FPrimaryName + ', gg2.lb, gg2.parent, gg2.rb' +
       ', gg2.' + FFieldName);
      ibsqlTarget.SQL.Add(' ORDER BY gg2.lb');}
// -->
    end
    else if not FIsSimpleTree then
      ibsqlTarget.SQL.Add(' ORDER BY gg1.' + FFieldName);
  finally
    TempList.Free;
  end;
  ibsqlTarget.ExecQuery;

  TargetParentList := TList.Create;
  try
    // Визуальное отображение
    tvTarget.Items.BeginUpdate;
    tvTarget.Items.Clear;
    SL.Clear;

    while not ibsqlTarget.Eof do
    begin
      if not (FIsIntervalTree or FIsSimpleTree) then
      begin
        L := tvTarget.Items.Add(nil, ibsqlTarget.FieldByName(FFieldName).AsString);
        L.ImageIndex := 1;
        L.SelectedIndex := 3;
      end
      else
      begin
        if ibsqlTarget.FieldByName('parent').IsNull then
          TargetParentList.Clear
        else
          while (TargetParentList.Count > 0) and
           (GetTID(ibsqlTarget.FieldByName('parent')) <>
           GetTID(TTreeNode(TargetParentList.Items[TargetParentList.Count - 1]).Data, FContext)) do
            TargetParentList.Delete(TargetParentList.Count - 1);
        if TargetParentList.Count = 0 then
        begin
          L := tvTarget.Items.Add(nil, ibsqlTarget.FieldByName(FFieldName).AsString);
          L.ImageIndex := 1;
          L.SelectedIndex := 3;
        end
        else
        begin
          L := tvTarget.Items.AddChild(TTreeNode(TargetParentList.Items[TargetParentList.Count - 1]),
           ibsqlTarget.FieldByName(FFieldName).AsString);
          L.ImageIndex := 1;
          L.SelectedIndex := 3;
          TTreeNode(TargetParentList.Items[TargetParentList.Count - 1]).ImageIndex := 0;
          TTreeNode(TargetParentList.Items[TargetParentList.Count - 1]).SelectedIndex := 2;
        end;
        TargetParentList.Add(L);
      end;
      L.Data := TID2Pointer(GetTID(ibsqlTarget.FieldByName(FPrimaryName)), FContext);

      if ibsqlTarget.FieldByName('isinclude').AsInteger = 0 then
        SL.AddObject(ibsqlTarget.FieldByName(FFieldName).AsString,
         TID2TObject(GetTID(ibsqlTarget.FieldByName(FPrimaryName)), FContext));

      ibsqlTarget.Next;
    end;

    (SL as TStringList).CustomSort(ValueListCompare);
    if not FIsSimpleTree then
      tvTarget.AlphaSort;
  finally
    TargetParentList.Free;
    tvTarget.FullExpand;
    tvTarget.Items.EndUpdate;
    lblSelCount.Caption := '(' + inttostr(SL.Count) + ')';
  end;
end;

procedure TdlgSelectFSet.ShowAttrSet;
begin
  // Вывод всех атрибутов
  // Запрос
  ibqryFind.Close;
  ibqryFind.SQL.Clear;

  if FIsIntervalTree then
    {ibqryFind.SQL.Text := 'SELECT DISTINCT(gg2.' + FPrimaryName + '), gg2.* FROM ' + FTableName + ' gg1, '
      + FTableName + ' gg2 WHERE (1=1) ' }
     ibqryFind.SQL.Text := 'SELECT * FROM ' + FTableName + ' gg1 WHERE (1=1)'
  else if FIsSimpleTree then
    ibqryFind.SQL.Text := 'SELECT gg1.* FROM ' + FTableName + ' gg1 ' +
      ' JOIN ( WITH RECURSIVE INTERNAL_TREE (Id, level) AS ' +
      ' (SELECT ID, 0 as level FROM ' + FTableName+' WHERE ID in (SELECT ID FROM '+FTableName+' WHERE Parent is null) '+
      '   UNION ALL ' +
      '   SELECT Z.ID, level+1 as level FROM ' + FTableName +' Z '+
      '   JOIN INTERNAL_TREE IT  ON IT.Id  =  Z.Parent) ' +
      'SELECT ID, level FROM INTERNAL_TREE ) Z1 ON gg1.ID  =  Z1.ID WHERE (1=1) '
  else
    ibqryFind.SQL.Text := 'SELECT gg1.* FROM ' + FTableName + ' gg1 WHERE (1=1) ';

  if Trim(FCondition) > '' then
    ibqryFind.SQL.Add(' AND ' + SetAliasPrefix(FCondition, 'gg1'));

  if FIsIntervalTree then
    ibqryFind.SQL.Add(' ORDER BY gg1.lb');
    //ibqryFind.SQL.Add(' AND gg2.lb <= gg1.lb AND gg2.rb >= gg1.rb ORDER BY gg2.lb');
  if not (FIsSimpleTree or FIsIntervalTree) then
    if FSortField > '' then
      ibqryFind.SQL.Add(' ORDER BY ' + FieldWithAlias(FSortField, 'gg1'))
    else if FSortOrder > '' then
      ibqryFind.SQL.Add(' ORDER BY ' + FieldWithAlias(FFieldName, 'gg1') + FSortOrder);

  ibqryFind.Open;

  // Визуальное отображение
  tvAttrSet.Items.BeginUpdate;
  try
    tvAttrSet.Items.Clear;

    ibqryFind.First;
    Draw500Item;

    if (tvAttrSet.Selected = nil) and (tvAttrSet.Items.Count > 0) then
    begin
      tvAttrSet.Items[0].Expand(False);
      tvAttrSet.Items[0].Selected := True;
    end;

  finally
    tvAttrSet.Items.EndUpdate;
  end;
end;

procedure TdlgSelectFSet.ShowFind(Qry: Boolean);
var
  Pref, Post, strFind: String;
begin
  // Вывод поиска
  // Выполнение запроса
  if Qry then
  begin
    ibqryFind.Close;
    ibqryFind.SQL.Clear;

    Pref := '%';
    Post := '%';
    case cbCondition.ItemIndex of
    0: Pref := '';
    2: Post := '';
    end;
    strFind := 'UPPER(';
    if not FIsSimpleTree then
      strFind := strFind + 'gg1.';
    strFind := strFind + FFieldName + ') LIKE ''' + Pref + AnsiUpperCase(edName.Text) + Post + '''';

    if FIsIntervalTree then
      ibqryFind.SQL.Text := 'SELECT DISTINCT(gg2.' + FPrimaryName + '), gg2.* FROM ' + FTableName + ' gg1, '
        + FTableName + ' gg2 WHERE ' + strFind
    else if FIsSimpleTree then
      ibqryFind.SQL.Text := 'SELECT gg1.* FROM ' + FTableName + ' gg1 ' +
        ' JOIN (WITH RECURSIVE INTERNAL_TREE AS ' +
        ' ( SELECT Id,Parent FROM ' + FTableName + ' where ' + strFind +
        '   UNION ALL ' +
        '   SELECT Z.Id, Z.Parent FROM ' + FTableName +' Z ' +
        '   JOIN INTERNAL_TREE IT ON IT.Parent  =  Z.Id) ' +
        ' SELECT distinct Id FROM INTERNAL_TREE) Z2 ON gg1.Id  =  Z2.ID ' +
        ' JOIN ( WITH RECURSIVE INTERNAL_TREE (Id, level) AS ' +
        ' (SELECT ID, 0 as level FROM ' + FTableName+' WHERE ID in (SELECT ID FROM '+FTableName+' WHERE Parent is null) '+
        '   UNION ALL ' +
        '   SELECT Z.ID, level+1 as level FROM ' + FTableName +' Z '+
        '   JOIN INTERNAL_TREE IT  ON IT.Id  =  Z.Parent) ' +
        ' SELECT ID, level FROM INTERNAL_TREE ) Z1 ON gg1.ID  =  Z1.ID WHERE (1=1) '
    else
      ibqryFind.SQL.Text := 'SELECT gg1.* FROM ' + FTableName + ' gg1 WHERE ' + strFind;

    if Trim(FCondition) > '' then
      ibqryFind.SQL.Add(' AND ' + SetAliasPrefix(FCondition, 'gg1'));
      
    if FIsIntervalTree then
      ibqryFind.SQL.Add(' AND gg2.lb <= gg1.lb AND gg2.rb >= gg1.rb ORDER BY gg2.lb');
    if not (FIsSimpleTree or FIsIntervalTree) then
      if FSortField > '' then
        ibqryFind.SQL.Add(' ORDER BY ' + FieldWithAlias(FSortField, 'gg1'))
      else if FSortOrder > '' then
        ibqryFind.SQL.Add(' ORDER BY ' + FieldWithAlias(FFieldName, 'gg1') + FSortOrder);
    ibqryFind.Open;
  end;

  // Визуальное отображение
  tvAttrSet.Items.BeginUpdate;
  try
    tvAttrSet.Items.Clear;
    FParentList.Clear;
    ibqryFind.First;
    Draw500Item;

    tvAttrSet.FullExpand;
  finally
    tvAttrSet.Items.EndUpdate;
  end;  
end;

function TdlgSelectFSet.CheckValue(StartP, EndP, Value: TID): Integer;
var
  Posit: Integer;
  Diff: TID;
begin
  // Функция двоичного поиска в списке
  Result := -1;  
  if StartP > EndP then
  begin
    Result := -1;
    Exit;
  end;
  Posit := StartP + (EndP - StartP) div 2;
  Diff := Value - GetTID(FValueList.Objects[Posit], FContext);
  if Diff = 0 then
    Result := Posit
  else
    if Diff > 0 then
      Result := CheckValue(Posit + 1, EndP, Value)
    else
      if Diff < 0 then
        Result := CheckValue(StartP, Posit - 1, Value);
end;

function TdlgSelectFSet.GetElements(var SetList: TStrings; const TableName,
 FieldName, PrimaryName, ACondition, ASortField, ASortOrder, AContext: String): Boolean;
begin
  Assert(((ASortOrder > '') xor (ASortField > ''))
    or ((ASortField = '') and (ASortOrder = '')));

  FTableName := TableName;
  FFieldName := FieldName;
  FPrimaryName := PrimaryName;
  FCondition := ACondition;
  FSortField := ASortField;
  FSortOrder := ASortOrder;
  FContext := AContext;

  FIsIntervalTree := False;
  FIsSimpleTree := False;
  // Основная функция формы
  // Выводим начальный список

  // проверяем - это интервальное дерево
  ibsqlTree.Close;
  ibsqlTree.Params[0].AsString := AnsiUpperCase(FTableName);
  try
    ibsqlTree.ExecQuery;
    FIsIntervalTree := ibsqlTree.Fields[0].AsInteger = 1;
  except
  end;

  // если не интервальное, проверяем может это простое дерево
  if not FIsIntervalTree and (AnsiUpperCase(FTableName) <> 'GD_DOCUMENT') then
  begin
    ibsqlSimpleTree.Close;
    ibsqlSimpleTree.Params[0].AsString := AnsiUpperCase(FTableName);
    try
      ibsqlSimpleTree.ExecQuery;
      FIsSimpleTree := ibsqlSimpleTree.Fields[0].AsInteger = 1;
    except
    end;
  end;

  tvAttrSet.ShowLines := FIsIntervalTree or FIsSimpleTree;
  tvTarget.ShowLines := FIsIntervalTree or FIsSimpleTree;

  FValueList.Assign(SetList);
  FValueList.CustomSort(ValueListCompare);

  ShowTargetList(FValueList);
  Result := False;

  if ShowModal = mrOk then
  begin
    Result := True;
    SetList.Assign(FValueList);
  end;
end;

procedure TdlgSelectFSet.btnAllClick(Sender: TObject);
begin
  FParentList.Clear;
  ShowAttrSet;
  edName.Text := '';
end;

procedure TdlgSelectFSet.FormCreate(Sender: TObject);
begin
  Assert(gdcBaseManager <> nil);
  cbCondition.ItemIndex := 1;
  FParentList := TList.Create;
  FValueList := TStringList.Create;
  ibsqlTarget.Transaction := gdcBaseManager.ReadTransaction;
  ibsqlTree.Transaction := gdcBaseManager.ReadTransaction;
  ibsqlSimpleTree.Transaction := gdcBaseManager.ReadTransaction;
  ibqryFind.Transaction := gdcBaseManager.ReadTransaction;
end;

procedure TdlgSelectFSet.actFindExecute(Sender: TObject);
begin
  if edName.Text = '' then
    MessageBox(Handle,
      'Укажите строку поиска!',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL)
  else
    ShowFind(True);
end;

procedure TdlgSelectFSet.edNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    actFind.Execute;
    Key := 0;
  end;
end;

procedure TdlgSelectFSet.actToExecute(Sender: TObject);
var
  I: Integer;
  Flag: Boolean;
begin
  Flag := False;
  // Перенос выделенных элементов в правую часть
  for I := 0 to tvAttrSet.Items.Count - 1 do
    if tvAttrSet.Items[I].Selected then
      if CheckValue(0, FValueList.Count - 1,
       GetTID(tvAttrSet.Items[I].Data, FContext)) = -1 then
      begin
        FValueList.AddObject(tvAttrSet.Items[I].Text, tvAttrSet.Items[I].Data);
        tvAttrSet.Items[I].ImageIndex := 4;
        tvAttrSet.Items[I].SelectedIndex := 4;
        Flag := True;
        FValueList.CustomSort(ValueListCompare);
      end;
  if Flag then
  begin
    tvAttrSet.Repaint;
    ShowTargetList(FValueList);
  end;
end;

function ValueListCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := GetTID(List.Objects[Index1], FContext) - GetTID(List.Objects[Index2], FContext);
end;

procedure TdlgSelectFSet.actFromExecute(Sender: TObject);
var
  I, J, f: Integer;
  Flag: Boolean;
begin
  Flag := False;
  // Удаление из правой части
  for I := tvTarget.Items.Count - 1 downto 0 do
    if tvTarget.Items[I].Selected then
    begin
      J := CheckValue(0, FValueList.Count - 1, GetTID(tvTarget.Items[I].Data, FContext));
      if J <> -1 then
      begin
        FValueList.Delete(J);
        Flag := True;
        f := FindInTreeView(tvAttrSet, GetTID(tvTarget.Items[I].Data, FContext));
        if f <> -1 then
        begin
          if not tvAttrSet.Items[f].HasChildren then
          begin
            tvAttrSet.Items[f].ImageIndex := 1;
            tvAttrSet.Items[f].SelectedIndex := 3;
          end else
          begin
            tvAttrSet.Items[f].ImageIndex := 0;
            tvAttrSet.Items[f].SelectedIndex := 2;
          end;
        end;
      end;
    end;
  if Flag then
  begin
    tvAttrSet.Repaint;
    ShowTargetList(FValueList);
  end;
end;

procedure TdlgSelectFSet.tvAttrSetDblClick(Sender: TObject);
begin
  actTo.Execute;
end;

procedure TdlgSelectFSet.lvTargetDblClick(Sender: TObject);
begin
  actFrom.Execute;
end;

procedure TdlgSelectFSet.FormDestroy(Sender: TObject);
begin
  FParentList.Free;
  FValueList.Free;
end;

procedure TdlgSelectFSet.actNextExecute(Sender: TObject);
begin
  Draw500Item;
end;

procedure TdlgSelectFSet.actNextUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not ibqryFind.Eof;
  label3.Enabled := (Sender as TAction).Enabled;
end;

function TdlgSelectFSet.SetAliasPrefix(AnCondition, AnAlias: String): String;
const
  cSymbols = ['=', ' ', '.', ',', '<', '>', '(', ')'];
var
  LastWord, CurrWord: String;
  LastSeparator: Char;
  I, J, p: Integer;
begin
  Result := FCondition;
  if Assigned(atDatabase) and (Result > '') then
  begin
    LastWord := '';
    LastSeparator := #0;

    J := 1;
    I := 1;
    while I <= Length(Result) do
    begin
      if (Result[I] in cSymbols) or (I = Length(Result)) then
      begin
        // Если окончание строки, копируем вместе с последним символом
        if I = Length(Result) then
          Inc(I);
        CurrWord := Copy(Result, J, I - J);
        if Assigned(atDatabase.FindRelationField(FTableName, CurrWord)) and (LastSeparator <> '.') then
        begin
          // делаем проверку на теги
          if (LastSeparator = '<')  then
          begin
            p := pos('/>', copy(Result, j, Length(Result)));
            if not ((p > 0) and  (pos('<', copy(Result, J + 1, p - 1)) = 0)) then
            begin
              Insert(AnAlias + '.', Result, J);
              I := I + Length(AnAlias + '.');
            end;
          end
          else
          begin
              Insert(AnAlias + '.', Result, J);
              I := I + Length(AnAlias + '.');
          end;
        end;
        J := I + 1;
        LastSeparator := Result[I];
        LastWord := CurrWord;
      end;
      Inc(I);
    end;
  end;
end;

procedure TdlgSelectFSet.actFromUpdate(Sender: TObject);
begin
  actFrom.Enabled := tvTarget.Selected <> nil; //tvTarget.Items.Count > 0;
end;

procedure TdlgSelectFSet.actToUpdate(Sender: TObject);
begin
  actTo.Enabled := tvAttrSet.Selected <> nil; //tvAttrSet.Items.Count > 0;
end;

procedure TdlgSelectFSet.actToAllExecute(Sender: TObject);
var
  I: Integer;
  Flag: Boolean;
begin
  Flag := False;
  for I := 0 to tvAttrSet.Items.Count - 1 do
    if CheckValue(0, FValueList.Count - 1,
     GetTID(tvAttrSet.Items[I].Data, FContext)) = -1 then
    begin
      FValueList.AddObject(tvAttrSet.Items[I].Text, tvAttrSet.Items[I].Data);
      tvAttrSet.Items[I].ImageIndex := 4;
      tvAttrSet.Items[I].SelectedIndex := 4;
      Flag := True;
      FValueList.CustomSort(ValueListCompare);
    end;
  if Flag then
  begin
    tvAttrSet.Repaint;
    ShowTargetList(FValueList);
  end;
end;

procedure TdlgSelectFSet.actToAllUpdate(Sender: TObject);
begin
  actToAll.Enabled := tvAttrSet.Items.Count > 0;
end;

procedure TdlgSelectFSet.actFromAllExecute(Sender: TObject);
var
  I, J, f: Integer;
  Flag: Boolean;
begin
  Flag := False;
  // Удаление из правой части
  for I := tvTarget.Items.Count - 1 downto 0 do
  begin
    J := CheckValue(0, FValueList.Count - 1, GetTID(tvTarget.Items[I].Data, FContext));
    if J <> -1 then
    begin
      FValueList.Delete(J);
      Flag := True;
      f := FindInTreeView(tvAttrSet, GetTID(tvTarget.Items[I].Data, FContext));
      if f <> -1 then
      begin
        if not tvAttrSet.Items[f].HasChildren then
          begin
            tvAttrSet.Items[f].ImageIndex := 1;
            tvAttrSet.Items[f].SelectedIndex := 3;
          end else
          begin
            tvAttrSet.Items[f].ImageIndex := 0;
            tvAttrSet.Items[f].SelectedIndex := 2;
          end;
      end;
    end;
  end;
  if Flag then
  begin
    tvAttrSet.Repaint;
    ShowTargetList(FValueList);
  end;
end;

procedure TdlgSelectFSet.actFromAllUpdate(Sender: TObject);
begin
  actFromAll.Enabled := tvTarget.Items.Count > 0;
end;

procedure TdlgSelectFSet.FormActivate(Sender: TObject);
begin
  ShowAttrSet;
  edName.Text := '';
end;

function TdlgSelectFSet.FieldWithAlias(AFieldName, AAlias: String): String;

  procedure ParseFieldsString(const AFields: String; SL: TStrings);
  var
    I, B: Integer;
  begin
    I := 1;
    B := 1;
    while I < Length(AFields) do
    begin
      if AFields[I] = '''' then
      begin
        repeat
          Inc(I);
        until (I >= Length(AFields)) or (AFields[I] = '''');
      end
      else if AFields[I] = ',' then
      begin
        SL.Add(Copy(AFields, B, I - B));
        B := I + 1;
      end;
      Inc(I);
    end;
    if B <= Length(AFields) then
      SL.Add(Copy(AFields, B, 255));
  end;

var
  StList: TStringList;
  I: Integer;
begin
  Result := Trim(AFieldName);
  if Result > '' then
  begin
    if Pos(',', Result) = 0 then
      Result := AAlias + '.' + Result
    else begin
      StList := TStringList.Create;
      try
        ParseFieldsString(Result, StList);
        Result := '';
        for I := 0 to StList.Count - 1 do
        begin
          if I > 0 then
            Result := Result + ',';
          Result := Result + AAlias + '.' + Trim(StList[I]);
        end;
      finally
        StList.Free;
      end;
    end;
  end;
end;

procedure TdlgSelectFSet.edNameEnter(Sender: TObject);
begin
  btnOk.Default := False;
end;

procedure TdlgSelectFSet.edNameExit(Sender: TObject);
begin
  btnOk.Default := True;
end;

function TdlgSelectFSet.FindInTreeView(TreeView: TTreeView;
  Value: TID): Integer;
var i: integer;
begin
  Result := -1;
  for i := 0 to TreeView.Items.Count - 1 do
  begin
    if GetTID(TreeView.Items[i].Data, FContext) = Value then
    begin
      Result := i;
      break;
    end;
  end;
end;

procedure TdlgSelectFSet.actFindUpdate(Sender: TObject);
begin
  actFind.Enabled := edName.Text <> '';
end;

procedure TdlgSelectFSet.actExpandExecute(Sender: TObject);
begin
    tvAttrSet.FullExpand;
end;

procedure TdlgSelectFSet.actCollapseExecute(Sender: TObject);
begin
    tvAttrSet.FullCollapse;
end;

procedure TdlgSelectFSet.tvAttrSetKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 32 then // пробел
    actTo.Execute;
end;

procedure TdlgSelectFSet.tvTargetKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 32 then // пробел
    actFrom.Execute;
end;

end.
