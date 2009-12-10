 {++
   Project ADDRESSBOOK
   Copyright © 2000-2001 by Golden Software

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
  Menus, ActnList, gd_security, IBSQL, ImgList;

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
  private
    FIsTree: Boolean;
    FTableName: String;
    FFieldName: String;
    FPrimaryName: String;
    FParentList: TList;
    FValueList: TStringList;
    FCondition: String;

    procedure ShowAttrSet;
    procedure ShowFind(Qry: Boolean);
    procedure ShowTargetList(SL: TStrings);
    function CheckValue(StartP, EndP, Value: Integer): Integer;
    procedure Draw500Item;
    function SetAliasPrefix(AnCondition, AnAlias: String): String;
  public
    function GetElements(var SetList: TStrings; const TableName, FieldName,
     PrimaryName, AnCondition: String): Boolean;
  end;

var
  dlgSelectFSet: TdlgSelectFSet;

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
    if not FIsTree then
    begin
      L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName(FFieldName).AsString);
      L.ImageIndex := 1;
      L.SelectedIndex := 1;
    end else
    begin
      if ibqryFind.FieldByName('parent').IsNull then
        FParentList.Clear
      else
        while (FParentList.Count > 0) and
         (ibqryFind.FieldByName('parent').AsInteger <>
         Integer(TTreeNode(FParentList.Items[FParentList.Count - 1]).Data)) do
          FParentList.Delete(FParentList.Count - 1);
      if FParentList.Count = 0 then
        L := tvAttrSet.Items.Add(nil, ibqryFind.FieldByName(FFieldName).AsString)
      else
        L := tvAttrSet.Items.AddChild(TTreeNode(FParentList.Items[FParentList.Count - 1]),
         ibqryFind.FieldByName(FFieldName).AsString);
      FParentList.Add(L);
    end;
    L.Data := Pointer(ibqryFind.FieldByName(FPrimaryName).AsInteger);

    Inc(I);
    ibqryFind.Next;
  end;
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
  if not FIsTree then
    ibsqlTarget.SQL.Text := 'SELECT gg1.*, 0 isinclude FROM ' + FTableName + ' gg1'
  else
    ibsqlTarget.SQL.Text := 'SELECT gg2.' + FPrimaryName +
//     ', SUM(gg2.lb - gg1.lb) isinclude,' +
     ', 1 isinclude, gg2.lb, gg2.parent, gg2.rb, gg2.' +
     FFieldName + ' FROM ' + FTableName + ' gg1, ' + FTableName + ' gg2 ';

  ibsqlTarget.SQL.Add('WHERE gg1.' + FPrimaryName + ' IN(');
  TempList := TStringList.Create;
  try
    for I := 0 to SL.Count - 1 do
    begin
      TempList.Add(IntToStr(Integer(SL.Objects[I])));
      TempList.Add(',');
    end;
    TempList.Strings[TempList.Count - 1] := ')';
    ibsqlTarget.SQL.AddStrings(TempList);

    if FIsTree then
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
    end else
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
      if not FIsTree then
        L := tvTarget.Items.Add(nil, ibsqlTarget.FieldByName(FFieldName).AsString)
      else
      begin
        if ibsqlTarget.FieldByName('parent').IsNull then
          TargetParentList.Clear
        else
          while (TargetParentList.Count > 0) and
           (ibsqlTarget.FieldByName('parent').AsInteger <>
           Integer(TTreeNode(TargetParentList.Items[TargetParentList.Count - 1]).Data)) do
            TargetParentList.Delete(TargetParentList.Count - 1);
        if TargetParentList.Count = 0 then
          L := tvTarget.Items.Add(nil, ibsqlTarget.FieldByName(FFieldName).AsString)
        else
          L := tvTarget.Items.AddChild(TTreeNode(TargetParentList.Items[TargetParentList.Count - 1]),
           ibsqlTarget.FieldByName(FFieldName).AsString);
        TargetParentList.Add(L);
      end;
      L.Data := Pointer(ibsqlTarget.FieldByName(FPrimaryName).AsInteger);
      if ibsqlTarget.FieldByName('isinclude').AsInteger = 0 then
      begin
        L.ImageIndex := 1;
        L.SelectedIndex := 3;
      end else
      begin
        L.ImageIndex := 0;
        L.SelectedIndex := 2;
      end;
      if ibsqlTarget.FieldByName('isinclude').AsInteger = 0 then
        SL.AddObject(ibsqlTarget.FieldByName(FFieldName).AsString,
         Pointer(ibsqlTarget.FieldByName(FPrimaryName).AsInteger));

      ibsqlTarget.Next;
    end;
    (SL as TStringList).CustomSort(ValueListCompare);
  finally
    TargetParentList.Free;
    tvTarget.FullExpand;
    tvTarget.Items.EndUpdate;
  end;
end;

procedure TdlgSelectFSet.ShowAttrSet;
begin
  // Вывод всех атрибутов
  // Запрос
  ibqryFind.Close;
  ibqryFind.SQL.Clear;
  ibqryFind.SQL.Text := 'SELECT * FROM ' + FTableName + ' gg1 ';
  if Trim(FCondition) > '' then
  begin
    ibqryFind.SQL.Add(' WHERE ' +
      StringReplace(FCondition,       // FB2 не позволяет использовать имя
        FTableName + '.',             // таблицы, если у нее есть алиас
        'gg1.', [rfReplaceAll, rfIgnoreCase]));
  end;
  if FIsTree then
    ibqryFind.SQL.Add(' ORDER BY gg1.lb')
  else
    ibqryFind.SQL.Add(' ORDER BY gg1.' + FFieldName);
  ibqryFind.Open;

  // Визуальное отображение
  tvAttrSet.Items.BeginUpdate;
  try
    tvAttrSet.Items.Clear;

    ibqryFind.First;
    Draw500Item;

    if (tvAttrSet.Selected = nil) and (tvAttrSet.Items.Count > 0) then
      tvAttrSet.Items[0].Selected := True;

  finally
    tvAttrSet.Items.EndUpdate;
  end;
end;

procedure TdlgSelectFSet.ShowFind(Qry: Boolean);
var
  Pref, Post: String;
begin
  // Вывод поиска
  // Выполнение запроса
  if Qry then
  begin
    ibqryFind.Close;
    ibqryFind.SQL.Clear;
    if not FIsTree then
      ibqryFind.SQL.Text := 'SELECT gg1.* FROM ' + FTableName + ' gg1 WHERE '
    else
      ibqryFind.SQL.Text := 'SELECT DISTINCT(gg2.' + FPrimaryName + '), gg2.* FROM ' + FTableName + ' gg1, '
        + FTableName + ' gg2 WHERE ';

    Pref := '%';
    Post := '%';
    case cbCondition.ItemIndex of
    0: Pref := '';
    2: Post := '';
    end;
    ibqryFind.SQL.Add(
      'UPPER(gg1.' + FFieldName + ') LIKE '''
      + Pref
      + AnsiUpperCase(edName.Text)
      + Post + '''');
    if Trim(FCondition) > '' then
      ibqryFind.SQL.Add(' AND ' + SetAliasPrefix(FCondition, 'gg1'));
    if FIsTree then
      ibqryFind.SQL.Add(' AND gg2.lb <= gg1.lb AND gg2.rb >= gg1.rb ORDER BY gg2.lb')
    else
      ibqryFind.SQL.Add(' ORDER BY gg1.' + FFieldName);
    ibqryFind.Open;
  end;

  // Визуальное отображение
  tvAttrSet.Items.BeginUpdate;
  tvAttrSet.Items.Clear;

  ibqryFind.First;
  Draw500Item;

  tvAttrSet.FullExpand;
  tvAttrSet.Items.EndUpdate;
end;

function TdlgSelectFSet.CheckValue(StartP, EndP, Value: Integer): Integer;
var
  Posit: Integer;
begin
  // Функция двоичного поиска в списке
  if StartP > EndP then
  begin
    Result := -1;
    Exit;
  end;
  Posit := StartP + (EndP - StartP) div 2;
  Result := Value - Integer(FValueList.Objects[Posit]);
  if Result = 0 then
    Result := Posit
  else
    if Result > 0 then
      Result := CheckValue(Posit + 1, EndP, Value)
    else
      if Result < 0 then
        Result := CheckValue(StartP, Posit - 1, Value);
end;

function TdlgSelectFSet.GetElements(var SetList: TStrings; const TableName,
 FieldName, PrimaryName, AnCondition: String): Boolean;
begin
  FTableName := TableName;
  FFieldName := FieldName;
  FPrimaryName := PrimaryName;
  FCondition := AnCondition;

  FIsTree := False;
  // Основная функция формы
  // Выводим начальный список

  ibsqlTree.Close;
  ibsqlTree.Params[0].AsString := AnsiUpperCase(FTableName);
  try
    ibsqlTree.ExecQuery;
    FIsTree := ibsqlTree.Fields[0].AsInteger = 1;
  except
  end;
  tvAttrSet.ShowLines := FIsTree;
  tvTarget.ShowLines := FIsTree;

  FValueList.Assign(SetList);
  FValueList.CustomSort(ValueListCompare);

  ShowTargetList(FValueList);
  Result := False;

  //ShowAttrSet;
  if ShowModal = mrOk then
  begin
    // Составляем результат
    {SetList.Clear;
    Result := True;
    if SetList <> nil then
      for I := 0 to lvTarget.Items.Count - 1 do
        if lvTarget.Items[I].Checked then
          SetList.AddObject(lvTarget.Items[I].Caption, Pointer(lvTarget.Items[I].Data));
    }
    Result := True;
    SetList.Assign(FValueList);
  end;
end;

//Очисчаем поля поиска
procedure TdlgSelectFSet.btnAllClick(Sender: TObject);
begin
  ShowAttrSet;
  edName.Text := '';
end;

procedure TdlgSelectFSet.FormCreate(Sender: TObject);
begin
  cbCondition.ItemIndex := 1;
  FParentList := TList.Create;
  FValueList := TStringList.Create;
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
       Integer(tvAttrSet.Items[I].Data)) = -1 then
      begin
        FValueList.AddObject(tvAttrSet.Items[I].Text, tvAttrSet.Items[I].Data);
        Flag := True;
        FValueList.CustomSort(ValueListCompare);
        {L := lvTarget.Items.Add;
        L.Caption := tvAttrSet.Items[I].Text;
        L.Data := tvAttrSet.Items[I].Data;}
      end;
  if Flag then
    ShowTargetList(FValueList);
end;

function ValueListCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  // Функция сортировки
  Result := Integer(List.Objects[Index1]) - Integer(List.Objects[Index2]);
end;

procedure TdlgSelectFSet.actFromExecute(Sender: TObject);
var
  I, J: Integer;
  Flag: Boolean;
begin
  Flag := False;
  // Удаление из правой части
  for I := tvTarget.Items.Count - 1 downto 0 do
    if tvTarget.Items[I].Selected then
    begin
      J := CheckValue(0, FValueList.Count - 1, Integer(tvTarget.Items[I].Data));
      if J <> -1 then
      begin
        FValueList.Delete(J);
        Flag := True;
      end;
    end;
  if Flag then
    ShowTargetList(FValueList);
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
  I, J: Integer;
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
          Insert(AnAlias + '.', Result, J);
          I := I + Length(AnAlias + '.');
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
     Integer(tvAttrSet.Items[I].Data)) = -1 then
    begin
      FValueList.AddObject(tvAttrSet.Items[I].Text, tvAttrSet.Items[I].Data);
      Flag := True;
      FValueList.CustomSort(ValueListCompare);
    end;
  if Flag then
    ShowTargetList(FValueList);
end;

procedure TdlgSelectFSet.actToAllUpdate(Sender: TObject);
begin
  actToAll.Enabled := tvAttrSet.Items.Count > 0;
end;

procedure TdlgSelectFSet.actFromAllExecute(Sender: TObject);
var
  I, J: Integer;
  Flag: Boolean;
begin
  Flag := False;
  // Удаление из правой части
  for I := tvTarget.Items.Count - 1 downto 0 do
  begin
    J := CheckValue(0, FValueList.Count - 1, Integer(tvTarget.Items[I].Data));
    if J <> -1 then
    begin
      FValueList.Delete(J);
      Flag := True;
    end;
  end;
  if Flag then
    ShowTargetList(FValueList);
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

end.
