
{++

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    xTreeGrid.pas

  Abstract

    Grid with tree inside.

  Author

    Romanovski Denis (13-08-98)

  Revisions history

    Initial  13-08-98  Dennis  Initial version.

    beta1    14-08-98  Dennis  Tree viewing and exploring is possible.

    beta2    18-08-98  Dennis  Different colors included.

    beta3    18-08-98  Dennis  Bitmaps are included.

    beta3    20-08-98  Dennis  Columns resizing included.

    beta4    22-08-98  Dennis  Bugs fixed. Some functions included.
    
--}

unit xTreeGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExList, ExtCtrls, StdCtrls;

const
  DefFirstColor = $00D6E7E7;
  DefSecondColor = $00E7F3F7;
  DefSelColor = $009CDFF7;

type
  TxTree = class;
  TxTreeGrid = class;

  TxTreeItem = class
  private
    FText: TStringList; // Текстовые данные записи
    FParent: TxTreeItem; // Родитель
    FChildren: TExList; // Дети
    FVisible: Boolean; // Видима ли ветка
    FTree: TxTree; // Дерево
    FRow: Integer; // Номер строки
    FExpanded: Boolean; // Раскрыта ди ветка
    FImportant: Boolean; // Является ли элемент важным
    FData: Pointer; // Данные пользователя
    FImageNums: Variant; // Список рисунков для каждой колонки

    function GetChild(Index: Integer): TxTreeItem;
    function GetChildrenCount: Integer;
    function GetLevel: Integer;
    function GetExpanded: Boolean;
    function GetImageCount(ACol: Integer): Integer;

    procedure SetExpanded(AnExpanded: Boolean);
    procedure SetVisible(AVisible: Boolean);
    procedure SetText(AText: TStringList);
    procedure SetRow(ARow: Integer);

    function GetNext: TxTreeItem;
    function GetPrev: TxTreeItem;
    function GetTextByColumn(Index: Integer): String;
    procedure SetTextByColumn(Index: Integer; const Value: String);
    function GetTextByIndex(Index: Integer): String;
    procedure SetTextByIndex(Index: Integer; const Value: String);

  protected
    property Text: TStringList read FText write SetText;

  public
    constructor Create(AText: TStringList; AColCount: Integer);
    destructor Destroy; override;

    procedure AddChild(AnItem: TxTreeItem);
    procedure InsertChild(AnItem: TxTreeItem; Index: Integer);
    procedure DeleteChild(Index: Integer);
    procedure RemoveChild(AnItem: TxTreeItem);

    procedure AddImage(ACol: Integer; ImageIndex, ImageNum: Integer);
    procedure DeleteImage(ACol: Integer; ImageIndex: Integer);
    procedure DeleteImages(ACol: Integer);

    function IndexByChild(AChild: TxTreeItem): Integer; // Индекс ребенка в спике детей

    // Данные строки по индексу
    property TextByIndex[Index: Integer]: String read GetTextByIndex write SetTextByIndex;
    // Данные строки по индексу колонки
    property TextByColumn[Index: Integer]: String read GetTextByColumn write SetTextByColumn;

    // Родитель элемента
    property Parent: TxTreeItem read FParent write FParent;
    // Дети элемента по индексу
    property Child[Index: Integer]: TxTreeItem read GetChild;
    // Кол-во детей
    property ChildrenCount: Integer read GetChildrenCount;
    // Видим ли элемент
    property Visible: Boolean read FVisible write SetVisible;
    // Уровень
    property Level: Integer read GetLevel;
    // Раскрыт ли элемент
    property Expanded: Boolean read GetExpanded write SetExpanded;
    // Номер строки в Grid-е
    property Row: Integer read FRow write SetRow;
    // Дерево элемента
    property Tree: TxTree read Ftree write FTree;

    // Следющий элемент
    property Next: TxTreeItem read GetNext;
    // Предыдущий элемент
    property Prev: TxTreeItem read GetPrev;

    // Использовать ли стить FontImportant
    property Important: Boolean read FImportant write FImportant;
    // Данные пользователя
    property Data: Pointer read FData write FData;
    // Массив колонок с индексами рисунков
    property ImageNums: Variant read FImageNums;
    // Кол-во рисунков по индексу колонки
    property ImageCount[ACol: Integer]: Integer read GetImageCount;
  end;

  TxTree = class
  private
    FItems: TExList; // Список главных веток
    FGrid: TxTreeGrid; // Grid дерева

    function GetItem(Index: Integer): TxTreeItem;
    function GetItemsCount: Integer;
    function GetItemByRow(Index: Integer): TxTreeItem;
    function GetSelected: TxTreeItem;

  protected

  public
    constructor Create;
    destructor Destroy; override;

    function Add(AText: TStringList): TxTreeItem; overload;
    function Add(const AText: array of String): TxTreeItem; overload;
    function Insert(AText: TStringList; Index: Integer): TxTreeItem; overload;
    function Insert(const AText: array of String; Index: Integer): TxTreeItem; overload;
    function AddItem(AText: TStringList; Item: TxTreeItem): TxTreeItem; overload;
    function AddItem(const AText: array of String; Item: TxTreeItem): TxTreeItem; overload;
    function InsertItem(AText: TStringList; Item: TxTreeItem; Index: Integer): TxTreeItem; overload;
    function InsertItem(const AText: array of String; Item: TxTreeItem; Index: Integer): TxTreeItem; overload;
    procedure Delete(Index: Integer);
    procedure Remove(AnItem: TxTreeItem);

    // Элемент по индексу
    property Item[Index: Integer]: TxTreeItem read GetItem;
    // Кол-во элементов
    property ItemsCount: Integer read GetItemsCount;
    // Grid- дерева
    property Grid: TxTreeGrid read FGrid write FGrid;
    // Выдает элемент по индексу строки
    property ItemByRow[Index: Integer]: TxTreeItem read GetItemByRow;
    // Возвращает выделенный элемент
    property Selected: TxTreeItem read GetSelected;

  end;

  TxTreeColumn = class
  private
    FColName: String; // Имя колонки (для использования с базами данных)
    FColTitle: String; // Текст колонки при перерисовке
    FColIndex: Integer; // Индекс колонки
    FGrid: TxTreeGrid; // Grid данной колонки

    procedure SetColTitle(ATitle: String);
  public
    constructor Create(AColName, AColTitle: String; AColIndex: Integer; AGrid: TxTreeGrid);

    // Название колонки (на случай использования баз даных)
    property ColName: String read FColName write FColName;
    // Заголовок колонки
    property ColTitle: String read FColTitle write SetColTitle;
    // Индекс колонки для реальных данных
    property ColIndex: Integer read FColIndex write FColIndex;
  end;

  TxTreeGrid = class(TStringGrid)
  private
    FTree: TxTree; // Дерево всех элементов
    FTreeColumn: Integer; // № колонки, в которой производятся действия с деревом
    FBranchIndent: Integer; // Отступ от предыдущей ветки
    OldOnSetEditText: TSetEditEvent; // Event редактирования текста пользователя
    OldOnColumnMoved: TMovedEvent; // Event по перемещению колонки пользователя
    FRowCount: Integer; // Кол-во строк в Grid-е
    FSplitPosition: Integer; // Позиция Split-а на экране
    FSplitting: Boolean; // Производится ли перетаскивание веток или нет
    FSkipColumns: Integer; // Кол-во колонок, пропускаемых при изменении размеров таблицы

    FFirstColor: TColor; // Первый цвет
    FSecondColor: TColor; // Второй цыет
    FSelectedColor: TColor; // Цыет выделения
    FFontImportant: TFont; // Важный шрифт
    FPictures: TImageList; // Список картинок
    FBitmapGap: Integer; // Расстояние между картинками
    FMinColWidth: Integer; // Минимальный размер колонки
    FColumns: TExList; // Список колонок

    CanUpdate: Boolean; // Можно ли менять размеры колонок
    CurrLine: Integer; // Текущая линия между колонками
    OldColWidth: Integer; // Сдвиг

    procedure SetBranchIndent(const Value: Integer);
    procedure SetTreeColumn(const Value: Integer);

    procedure DoOnSetEditText(Sender: TObject; ACol, ARow: Longint; const Value: string);
    procedure DoOnColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);

    procedure DrawMinus(X, Y: Integer);
    procedure DrawPlus(X, Y: Integer);

    function GetRowCount: Integer;
    procedure SetRowCount(const Value: Integer);
    procedure SetFirstColor(const Value: TColor);
    procedure SetSecondColor(const Value: TColor);
    procedure SetSelectedColor(const Value: TColor);
    procedure SetImportant(const Value: TFont);
    procedure SetImages(const Value: TImageList);
    function GetColCount: Integer;
    procedure SetColCount(const Value: Integer);
    function GetColumn(AnIndex: Integer): TxTreeColumn;

    function CountGridWidth: Integer;

  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure ColWidthsChanged; override;
    procedure CalcSizingState(X, Y: Integer; var State: TGridState;
      var Index: Longint; var SizingPos, SizingOfs: Integer;
      var FixedInfo: TGridDrawInfo); override;

    property Rows;
    property Cols;
    property Cells;
    property Objects;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function IsRowClear(Text: TStrings): Boolean;
    function IsBelowClear(ARow: Integer): Boolean;
    function GetClearCount: Integer;

    procedure MoveDown(ARow: Integer; Count: Integer);
    procedure MoveUp(ARow: Integer; Count: Integer);
    procedure ChangeColumns(FromIndex, ToIndex: Integer);
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    function ItemByPoint(P: TPoint): TxTreeItem;

    // Дерево grid-а
    property Tree: TxTree read FTree;
    // Колонка по индексу
    property Columns[Index: Integer]: TxTreeColumn read GetColumn;

  published
    // Колонк, в которой будут производиться действия с деревом
    property TreeColumn: Integer read FTreeColumn write SetTreeColumn;
    // Минимальный размер колонки
    property MinColWidth: Integer read FMinColWidth write FMinColWidth;
    // Специальный стиль для наиболее важных элементов
    property FontImportant: TFont read FFontImportant write SetImportant;
    // Отступ от предыдушей ветки
    property BranchIndent: Integer read FBranchIndent write SetBranchIndent;
    // Кол-во строк
    property RowCount: Integer read GetRowCount write SetRowCount;
    // Кол-во колонок
    property ColCount: Integer read GetColCount write SetColCount;
    // Первый цвет
    property FirstColor: TColor read FFirstColor write SetFirstColor default DefFirstColor;
    // Второй цвет
    property SecondColor: TColor read FSecondColor write SetSecondColor default DefSecondColor;
    // Цвет выделения
    property SelectedColor: TColor read FSelectedColor write SetSelectedColor default DefSelColor;
    // Рисунки
    property Pictures: TImageList read FPictures write SetImages;
    // Отступ между рисунками
    property BitmapGap: Integer read FBitmapGap write FBitmapGap;
    // Кол-во, колонок с начала, которые неменяют свой размер
    property SkipColumns: Integer read FSkipColumns write FSkipColumns;

  end;

procedure Register;

implementation

const
  SplittingSize = 20;
  MinColWidth = 10;
  CommonBMP: TBitmap = nil;
  Users: Integer = 0;

{
  Входит ли точка в Rect
}

function IsInRect(R: TRect; X, Y: Integer): Boolean;
begin
  Result := (X >= R.Left) and (X <= R.Right) and (Y >= R.Top) and (Y <= R.Bottom);
end;

// Создает список картинок
function CreateImageList(S: String): Variant;
var
  K, N: Integer;

  // Считывает индекс картинки
  function ReadNum: Integer;
  var
    L: Integer;
    Z: String;
  begin
    L := 1;
    Z := '';

    while S[L] in ['0'..'9'] do
    begin
      Z := Z + S[L];
      Inc(L);
    end;

    if Length(Z) > 0 then
      Result := StrToInt(Z)
    else
      Result := -1;
  end;

begin
  N := 0;
  Result := VarArrayCreate([0, N], varInteger);
  Result[0] := -1;

  repeat
    K := Pos('$', S);

    if (K > 0) and (Length(S) > K) then
    begin
      if not (S[K + 1] in ['0'..'9']) then Break;
      S := Copy(S, K + 1, Length(S));

      if (VarArrayHighBound(Result, 1) = 0) and (Result[0] = -1) then
        Result := VarArrayCreate([0, N], varInteger)
      else begin
        Inc(N);
        VarArrayRedim(Result, N);
      end;

      if Length(S) > 0 then
        Result[N] := ReadNum
      else
        Result[N] := NULL;
    end else
      Break;
  until K = 0;
end;

// Удаляет знаки доллара
function RemoveDollars(S: String): String;
var
  I: Integer;
begin
  repeat
    I := Pos('$', S);

    if (I <> 0) and (Length(S) > I) and (S[I + 1] in ['0'..'9', ' ']) then
      S := Copy(S, I + 1, Length(S))
    else
      Break;
  until I = 0;

    while (Length(S) > 0) and (S[1] in ['0'..'9', ' ']) do
      S := Copy(S, 2, Length(S));

  Result := S;
end;

{
  ----------------------------
  ---   TxTreeItem Class   ---
  ----------------------------
}


{
  ***********************
  ***  Private Part   ***
  ***********************
}


{
  Возвращает элемент по индексу
}

function TxTreeItem.GetChild(Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem(FChildren[Index]);
end;

{
  Возвращает кол-во элементов
}

function TxTreeItem.GetChildrenCount: Integer;
begin
  Result := FChildren.Count;
end;

{
  Уровень ветки
}

function TxTreeItem.GetLevel: Integer;
var
  OldParent: TxTreeItem;
begin
  Result := 1;
  OldParent := Self;

  while OldParent.Parent <> nil do
  begin
    Inc(Result);
    OldParent := OldParent.Parent;
  end;
end;

{
  Раскрыта ли ветка или нет!
}

function TxTreeItem.GetExpanded: Boolean;
begin
  Result := FExpanded;
end;

{
  Передает кол-во рисунков для данной колонки
}

function TxTreeItem.GetImageCount(ACol: Integer): Integer;
begin
  Result := VarArrayHighBound(FImageNums[ACol], 1);
end;

{
  Устанавливает детей видимыми или нет
}

procedure TxTreeItem.SetExpanded(AnExpanded: Boolean);
var
  I: Integer;
begin
  if FExpanded <> AnExpanded then
  begin
    FExpanded := AnExpanded;
    if FVisible then
    begin
      for I := 0 to ChildrenCount - 1 do Child[I].Visible := FExpanded;
      Tree.Grid.InvalidateRow(FRow);
    end;  
  end;
end;

{
  Делает элемент видимым в Grid-е или удаляет его
}

procedure TxTreeItem.SetVisible(AVisible: Boolean);
var
  I: Integer;

  // Дает последнюю строку данной главной ветки
  function GetLastRow: Integer;
  var
    I: TxTreeItem;
  begin
    I := Prev;

    while (I.ChildrenCount > 0) and I.Child[I.ChildrenCount - 1].Visible do
      I := I.Child[I.ChildrenCount - 1];

    Result := I.Row + 1;
  end;

begin
  if AVisible <> FVisible then
  begin
    // Если родитель невидим или не раскрыт, то его следует сделать видимым и раскрыть
    if AVisible and (Parent <> nil) then
      if not Parent.Visible then
      begin
        Parent.Visible := True;
        Parent.Expanded := True;
        Exit;
      end else if not Parent.Expanded then
      begin
        Parent.Expanded := True;
        Exit;
      end;

    FVisible := AVisible;

    if FVisible then
    begin
      // Устанавливаем номер позиции в Grid-е
      if (Prev <> nil) and Prev.Visible then
      begin
        if Prev.Expanded then
          FRow := GetLastRow
        else
          FRow := Prev.Row + 1
      end else if FParent <> nil then
        FRow := Parent.Row + 1
      else
        FRow := Tree.Grid.FixedRows;

      if FTree.Grid.IsBelowClear(FRow) then
      begin
        if FTree.Grid.RowCount < FRow + 1 then
          FTree.Grid.RowCount := FTree.Grid.RowCount + 1;
      end else begin
        FTree.Grid.MoveDown(FRow, 1);
      end;

      // Устанавливаем текст
      for I := 0 to FText.Count - 1 do
        FTree.Grid.Cells[I, FRow] := FText[Tree.Grid.Columns[I].ColIndex];

      // Устанавливаем данные класса
      for I := 0 to FTree.Grid.Rows[FRow].Count - 1 do
        FTree.Grid.Rows[FRow].Objects[I] := Self;

     // Делаем видимыми детей, если нужно
      if FExpanded then
        for I := 0 to ChildrenCount - 1 do
          Child[I].Visible := True;
    end else begin
     // Делаем невидимыми детей, если нужно
      if FExpanded then
        for I := 0 to ChildrenCount - 1 do
          Child[I].Visible := False;

      // Освобождаем строку от данных    
      FTree.Grid.Rows[FRow].Clear;

      if FRow < FTree.Grid.RowCount - 1 then
        FTree.Grid.MoveUp(FRow + 1, 1)
      else
        FTree.Grid.RowCount := FTree.Grid.RowCount - 1;
    end;
  end;
end;

{
  Устанавливает текстовую информацию
}

procedure TxTreeItem.SetText(AText: TStringList);
var
  I: Integer;
begin
  FText.Assign(AText);

  for I := 0 to FText.Count - 1 do FText.Objects[I] := Self;
  if FVisible then FTree.Grid.Rows[FRow] := FText;

  FImageNums := VarArrayCreate([0, FText.Count - 1], varVariant);

  for I := 0 to FText.Count - 1 do
  begin
    FImageNums[I] := CreateImageList(FText[I]);
    FText[I] := RemoveDollars(FText[I]);
  end;
end;

{
  Устанавливает номер строки
}

procedure TxTreeItem.SetRow(ARow: Integer);
var
  I: Integer;
begin
  if FVisible then
  begin
    FTree.Grid.Rows[FRow].Clear;
    FRow := ARow;

    for I := 0 to FText.Count - 1 do
      FTree.Grid.Cells[I, FRow] := FText[Tree.Grid.Columns[I].ColIndex];

    for I := 0 to FTree.Grid.Rows[FRow].Count - 1 do
      FTree.Grid.Rows[FRow].Objects[I] := Self;
  end;
end;

{
  Дает следующий элемент в даной ветке
}

function TxTreeItem.GetNext: TxTreeItem;
var
  I: Integer;
begin
  Result := nil;

  if Parent <> nil then
  begin
    I := Parent.FChildren.IndexOf(Self);
    if Parent.ChildrenCount > I + 1 then Result := Parent.Child[I + 1];
  end else begin
    I := Tree.FItems.IndexOf(Self);
    if Tree.ItemsCount > I + 1 then Result := Tree.Item[I + 1];
  end;
end;

{
  Дает предыдущий элемент в данной ветке
}

function TxTreeItem.GetPrev: TxTreeItem;
var
  I: Integer;
begin
  Result := nil;

  if Parent <> nil then
  begin
    I := Parent.FChildren.IndexOf(Self);
    if I > 0 then Result := Parent.Child[I - 1];
  end else begin
    I := Tree.FItems.IndexOf(Self);
    if I > 0 then Result := Tree.Item[I - 1];
  end;
end;

{
  Получает строку по индексу колонки (сделано на случай, если
  пользователь меняет колонки местами)
}

function TxTreeItem.GetTextByColumn(Index: Integer): String;
begin
  Result := FText[Tree.Grid.Columns[Index].ColIndex];
end;

{
  Получает строку по индексу
}

function TxTreeItem.GetTextByIndex(Index: Integer): String;
begin
  Result := FText[Index];
end;

{
  Устнавлвает строку по индексу колонки (сделано на случай, если
  пользователь меняет колонки местами)
}

procedure TxTreeItem.SetTextByColumn(Index: Integer; const Value: String);
var
  CurrCol: Variant;
begin
  if Tree = nil then
  begin
    CurrCol := CreateImageList(Value);
    FImageNums[Tree.Grid.Columns[Index].ColIndex] := CurrCol;
    FText[Tree.Grid.Columns[Index].ColIndex] := RemoveDollars(Value);
  end else begin
    FText[Tree.Grid.Columns[Index].ColIndex] := Value;
    if FVisible then
      Tree.Grid.Cells[Index, FRow] := Value;
  end;
end;

{
  Устанавливает строку по индексу
}

procedure TxTreeItem.SetTextByIndex(Index: Integer; const Value: String);
var
  CurrCol: Variant;
  I: Integer;
begin
  if Tree = nil then
  begin
    CurrCol := CreateImageList(Value);
    FImageNums[Index] := CurrCol;
    FText[Index] := RemoveDollars(Value);
  end else begin
    FText[Index] := Value;
    if FVisible then
      for I := 0 to FText.Count - 1 do
        FTree.Grid.Cells[I, FRow] := FText[Tree.Grid.Columns[I].ColIndex];
  end;
end;

{
  *************************
  ***  Protected Part   ***
  *************************
}

{
  **********************
  ***  Public Part   ***
  **********************
}


{
  Начальные установки
}

constructor TxTreeItem.Create(AText: TStringList; AColCount: Integer);
var
  I: Integer;
  V: Variant;
begin
  FText := TStringList.Create;

  if AText <> nil then
  begin
    // Проверка на наличие точного числа колонок
    if AText.Count < AColCount then
      for I := AText.Count to AColCount do AText.Add('');

    Text := AText;
  end else begin // Если текста нет, то создаем нулевые строки самостоятельно
    for I := 1 to AColCount do FText.Add('');
    FImageNums := VarArrayCreate([0, FText.Count - 1], varVariant);

    for I := 0 to FText.Count - 1 do
    begin
      V := VarArrayCreate([0, 0], varInteger);
      V[0] := -1;
      FImageNums[I] := V;
    end;  
  end;

  for I := 0 to FText.Count - 1 do
    FText.Objects[I] := Self;

  FParent := nil;
  FVisible := False;
  FExpanded := False;
  FData := nil;
  FChildren := TExList.Create;
end;

{
  Высвобождение памяти
}

destructor TxTreeItem.Destroy;
begin
  FText.Free;
  FChildren.Free;

  inherited Destroy;
end;

{
  Добавляет элемент в список детей
}

procedure TxTreeItem.AddChild(AnItem: TxTreeItem);
begin
  FChildren.Add(AnItem);
  AnItem.Parent := Self;
  AnItem.Tree := FTree;
  if Expanded then AnItem.Visible := True;
  Tree.Grid.InvalidateRow(FRow);
end;

{
  Вставляет элемент в список детей по индексу
}

procedure TxTreeItem.InsertChild(AnItem: TxTreeItem; Index: Integer);
begin
  FChildren.Insert(Index, AnItem);
  AnItem.Parent := Self;
  AnItem.Tree := FTree;
  if Expanded and Visible then AnItem.Visible := True;
  Tree.Grid.InvalidateRow(FRow);
end;

{
  Удаляет эелемент по индексу
}

procedure TxTreeItem.DeleteChild(Index: Integer);
var
  CurrItem: TxTreeItem;
begin
  CurrItem := Child[Index];
  
  if Visible then
  begin
    CurrItem.Expanded := False;
    CurrItem.Visible := False;
  end;

  FChildren.RemoveAndFree(CurrItem);

  if ChildrenCount = 0 then
    FTree.Grid.InvalidateRow(FRow);
end;

{
  Удаляет элемент по его классу
}

procedure TxTreeItem.RemoveChild(AnItem: TxTreeItem);
begin
  if Visible then
  begin
    AnItem.Expanded := False;
    AnItem.Visible := False;
  end;

  FChildren.RemoveAndFree(AnItem);

  if ChildrenCount = 0 then
    FTree.Grid.InvalidateRow(FRow);
end;

{
  Добавляет индекс картинки в список
}

procedure TxTreeItem.AddImage(ACol: Integer; ImageIndex, ImageNum: Integer);
var
  CurrCol: Variant;
  I: Integer;
begin
  CurrCol := FImageNums[ACol];
  VarArrayRedim(CurrCol, VarArrayHighBound(CurrCol, 1) + 1);

  for I := VarArrayHighBound(CurrCol, 1) downto ImageIndex + 1 do
    CurrCol[I] := CurrCol[I - 1];

  CurrCol[ImageIndex] := ImageNum;
  FImageNums[ACol] := CurrCol;
  if FVisible then Tree.Grid.InvalidateRow(FRow);
end;

{
  Удаляет картинку из списка по индексу
}

procedure TxTreeItem.DeleteImage(ACol: Integer; ImageIndex: Integer);
var
  CurrCol: Variant;
  I: Integer;
begin
  CurrCol := FImageNums[ACol];

  if ImageIndex < VarArrayHighBound(CurrCol, 1) then
    for I := ImageIndex to VarArrayHighBound(CurrCol, 1) - 1 do
      CurrCol[I] := CurrCol[I + 1];

  if VarArrayHighBound(CurrCol, 1) > 0 then
    VarArrayRedim(CurrCol, VarArrayHighBound(CurrCol, 1) - 1)
  else
    CurrCol[0] := -1;

  FImageNums[ACol] := CurrCol;
  if FVisible then Tree.Grid.InvalidateRow(FRow);
end;

{
  Удаляет все картинки
}

procedure TxTreeItem.DeleteImages(ACol: Integer);
var
  CurrCol: Variant;
begin
  CurrCol := FImageNums[ACol];
  VarArrayRedim(CurrCol, 0);
  CurrCol[0] := -1;
  FImageNums[ACol] := CurrCol;
  if FVisible then Tree.Grid.InvalidateRow(FRow);
end;

{
  Вовзращает индекс ребенка в списке детей
}

function TxTreeItem.IndexByChild(AChild: TxTreeItem): Integer;
begin
  Result := FChildren.IndexOf(AChild);
end;

{
  ------------------------
  ---   TxTree Class   ---
  ------------------------
}


{
  ***********************
  ***  Private Part   ***
  ***********************
}


{
  Возвращает элемент по индексу
}

function TxTree.GetItem(Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem(FItems[Index]);
end;

{
  Возвращает кол-во элементов
}

function TxTree.GetItemsCount: Integer;
begin
  Result := FItems.Count;
end;

{
  Выдает элемент по индексу строки
}

function TxTree.GetItemByRow(Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem(FGrid.Rows[Index].Objects[0]);
end;

{
  Возвращает выделенный в данный момент элемент
}

function TxTree.GetSelected: TxTreeItem;
begin
  Result := GetItemByRow(FGrid.Row);
end;

{
  *************************
  ***  Protected Part   ***
  *************************
}


{
  **********************
  ***  Public Part   ***
  **********************
}

{
  Начальные установки
}

constructor TxTree.Create;
begin
  FItems := TExList.Create;
end;

{
  Высвобождение памяти
}

destructor TxTree.Destroy;
begin
  FItems.Free;

  inherited Destroy;
end;

{
  Добавляет элемент в конец списка
}

function TxTree.Add(AText: TStringList): TxTreeItem;
begin
  Result := TxTreeItem.Create(AText, Grid.ColCount);
  Result.Parent := nil;
  Result.Tree := Self;
  FItems.Add(Result);
  Result.Visible := True;
end;

{
  Добавляет элемент в конец списка
}

function TxTree.Add(const AText: array of String): TxTreeItem;
var
  I: Integer;
begin
  Result := TxTreeItem.Create(nil, Grid.ColCount);
  
  for I := Low(AText) to High(AText) do
    Result.TextByIndex[I] := AText[I];

  Result.Parent := nil;
  Result.Tree := Self;
  FItems.Add(Result);
  Result.Visible := True;
end;

{
  Вставляет элемент в список по индексу
}

function TxTree.Insert(AText: TStringList; Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem.Create(AText, Grid.ColCount);
  Result.Parent := nil;
  Result.Tree := Self;
  FItems.Insert(Index, Result);
  Result.Visible := True;
end;

{
  Вставляет элемент в список по индексу
}

function TxTree.Insert(const AText: array of String; Index: Integer): TxTreeItem;
var
  I: Integer;
begin
  Result := TxTreeItem.Create(nil, Grid.ColCount);

  for I := Low(AText) to High(AText) do
    Result.TextByIndex[I] := AText[I];

  Result.Tree := Self;
  FItems.Insert(Index, Result);
  Result.Visible := True;
end;

{
  Добавляет элемент в ветку в конец списка
}

function TxTree.AddItem(AText: TStringList; Item: TxTreeItem): TxTreeItem;
begin
  Result := TxTreeItem.Create(AText, Grid.ColCount);
  Item.AddChild(Result);
end;

{
  Добавляет элемент в ветку в конец списка
}

function TxTree.AddItem(const AText: array of String; Item: TxTreeItem): TxTreeItem;
var
  I: Integer;
begin
  Result := TxTreeItem.Create(nil, Grid.ColCount);
  for I := Low(AText) to High(AText) do Result.TextByIndex[I] := AText[I];
  Item.AddChild(Result);
end;

{
  Вставляет элемент в ветку по индексу
}

function TxTree.InsertItem(AText: TStringList; Item: TxTreeItem;
  Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem.Create(AText, Grid.ColCount);
  Item.InsertChild(Result, Index);
end;

{
  Вставляет элемент в ветку по индексу
}

function TxTree.InsertItem(const AText: array of String; Item: TxTreeItem; Index: Integer): TxTreeItem;
var
  I: Integer;
begin
  Result := TxTreeItem.Create(nil, Grid.ColCount);
  for I := Low(AText) to High(AText) do Result.TextByIndex[I] := AText[I];
  Item.InsertChild(Result, Index);
end;

{
  Удаляет элемент по индексу
}

procedure TxTree.Delete(Index: Integer);
var
  CurrItem: TxTreeItem;
begin
  CurrItem := TxTreeItem(FItems[Index]);

  if CurrItem.Visible then
  begin
    CurrItem.Expanded := False;
    CurrItem.Visible := False;
  end;

  FItems.RemoveAndFree(CurrItem);
end;

{
  Удаляет элемент по классу
}

procedure TxTree.Remove(AnItem: TxTreeItem);
begin
  if AnItem.Visible then
  begin
    AnItem.Expanded := False;
    AnItem.Visible := False;
  end;

  FItems.RemoveAndFree(AnItem);
end;


{
  ------------------------------
  ---   TxTreeColumn Class   ---
  ------------------------------
}


{
  ***********************
  ***  Private Part   ***
  ***********************
}

{
  Устанавливает текст колонки
}

procedure TxTreeColumn.SetColTitle(ATitle: String);
begin
  FColTitle := ATitle;
  if FGrid.FixedRows > 0 then
    FGrid.Cells[FGrid.FColumns.IndexOf(Self), 0] := FColTitle;
end;


{
  **********************
  ***  Public Part   ***
  **********************
}


{
  Делает начальные установки
}

constructor TxTreeColumn.Create(AColName, AColTitle: String; AColIndex: Integer; AGrid: TxTreeGrid);
begin
  FColName := AColName;
  FColTitle := AColTitle;
  FColIndex := AColIndex;
  FGrid := AGrid;
end;

{
  ----------------------------
  ---   TxTreeGrid Class   ---
  ----------------------------
}


{
  ***********************
  ***  Private Part   ***
  ***********************
}

{
  Устанавливает отступ
}

procedure TxTreeGrid.SetBranchIndent(const Value: Integer);
begin
  FBranchIndent := Value;
  Repaint;
end;

{
  Устанавливает № колонки для действий с деревом
}

procedure TxTreeGrid.SetTreeColumn(const Value: Integer);
begin
  FTreeColumn := Value;
  Repaint;
end;

{
  По вводу нового текста производим свои действия
}

procedure TxTreeGrid.DoOnSetEditText(Sender: TObject; ACol, ARow: Longint; const Value: string);
var
  CurrItem: TxTreeItem;
begin
  CurrItem := TxTreeItem(Rows[ARow].Objects[0]);

  if CurrItem <> nil then
    CurrItem.FText[Columns[ACol].ColIndex] := Cells[ACol, ARow];

  if Assigned(OldOnSetEditText) then OldOnSetEditText(Sender, ACol, ARow, Value);
end;

{
  По передвижению колонки производим проверку на передвижения колонки с
  деревом
}

procedure TxTreeGrid.DoOnColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
begin
  ChangeColumns(FromIndex, ToIndex);

  if FromIndex = FTreeColumn then
    FTreeColumn := ToIndex
  else if (FromIndex < FTreeColumn) and (ToIndex >= FTreeColumn) then
    Dec(FTreeColumn)
  else if (FromIndex > FTreeColumn) and (ToIndex <= FTreeColumn) then
    Inc(FTreeColumn);

  CurrLine := 0;
  OldColWidth := ColWidths[CurrLine];

  Repaint;
  if Assigned(OldOnCOlumnMoved) then OldOnColumnMoved(Sender, FromIndex, ToIndex);
end;

{
  Рисует плюс
}

procedure TxTreeGrid.DrawMinus(X, Y: Integer);
var
  OldBrushColor, OldPenColor: TColor;
begin
  OldBrushColor := Canvas.Brush.Color;
  OldPenColor := Canvas.Pen.Color;

  Canvas.Pen.Color := clGray;
  Canvas.Brush.Color := clGray;
  Canvas.FrameRect(Rect(X, Y, X + 9, Y + 9));

  Canvas.Pen.Color := clBlack;
  Canvas.MoveTo(X + 2, Y + 4);
  Canvas.LineTo(X + 7, Y + 4);

  Canvas.Brush.Color := OldBrushColor;
  Canvas.Pen.Color := OldPenColor;
end;

{
  Рисует минус
}

procedure TxTreeGrid.DrawPlus(X, Y: Integer);
var
  OldBrushColor, OldPenColor: TColor;
begin
  OldBrushColor := Canvas.Brush.Color;
  OldPenColor := Canvas.Pen.Color;

  Canvas.Pen.Color := clGray;
  Canvas.Brush.Color := clGray;
  Canvas.FrameRect(Rect(X, Y, X + 9, Y + 9));

  Canvas.Pen.Color := clBlack;
  Canvas.MoveTo(X + 2, Y + 4);
  Canvas.LineTo(X + 7, Y + 4);

  Canvas.MoveTo(X + 4, Y + 2);
  Canvas.LineTo(X + 4, Y + 7);

  Canvas.Brush.Color := OldBrushColor;
  Canvas.Pen.Color := OldPenColor;
end;

{
  Берет кол-во строк в Grid-е
}

function TxTreeGrid.GetRowCount: Integer;
begin
  Result := inherited RowCount;
end;

{
  Устанавливает кол-во строк в Grid-е
}

procedure TxTreeGrid.SetRowCount(const Value: Integer);
begin
  if (csLoading in ComponentState) or (csDesigning in ComponentState) or (Value >= FRowCount) then
  begin
    inherited RowCount := Value;
    if (csLoading in ComponentState) then FRowCount := Value;
  end;
end;

{
  Устанавливается первый цвет
}

procedure TxTreeGrid.SetFirstColor(const Value: TColor);
begin
  FFirstColor := Value;
  Repaint;
end;

{
  Устанавливается второй цвет
}

procedure TxTreeGrid.SetSecondColor(const Value: TColor);
begin
  FSecondColor := Value;
  Repaint;
end;

{
  Устанавливается цвет выделения
}

procedure TxTreeGrid.SetSelectedColor(const Value: TColor);
begin
  FSelectedColor := Value;
  Repaint;
end;

{
  Устанавливает шрифт важных строк
}

procedure TxTreeGrid.SetImportant(const Value: TFont);
begin
  FFontImportant.Assign(Value);
end;

{
  Устанавливаем список рисунков
}

procedure TxTreeGrid.SetImages(const Value: TImageList);
begin
  FPictures := Value;
  Repaint;
end;

{
  Возвращает кол-во колонок
}

function TxTreeGrid.GetColCount: Integer;
begin
  Result := inherited ColCount;
end;

{
  Устанавливает кол-во колонок
}

procedure TxTreeGrid.SetColCount(const Value: Integer);
var
  I: Integer;
begin
  inherited ColCount := Value;
  if not (csDesigning in ComponentState) then
  begin
    ColWidthsChanged;
    
    if FColumns.Count < ColCount then
      for I := FColumns.Count to ColCount do
        FColumns.Add(TxTreeColumn.Create('', '', FColumns.Count, Self))
    else if FColumns.Count > ColCount then
      for I := ColCount downto FColumns.Count do FColumns.DeleteAndFree(FColumns.Count - 1);
  end;
end;

{
  Выдает колонку по индексу
}

function TxTreeGrid.GetColumn(AnIndex: Integer): TxTreeColumn;
begin
  Result := TxTreeColumn(FColumns[AnIndex]);
end;

{
  Размер колонок Grid-а
}

function TxTreeGrid.CountGridWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to ColCount - 1 do Inc(Result, ColWidths[I] + GridLineWidth);
end;

{
  *************************
  ***  Protected Part   ***
  *************************
}


{
  Производит перерисовку Grid-а
}

procedure TxTreeGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  CurrItem: TxTreeItem;
  CurrCol: Variant;
  I: Integer;
  Pos: Integer;

  // Рисует bitmap
  procedure DrawImage(const BMP: TBitmap);
  begin
    Pos := (BMP.Width - (ARect.Bottom - ARect.Top)) div 2;

    Canvas.BrushCopy(
      Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom),
      BMP,
      Rect(0, Pos, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top + Pos),
      BMP.TransparentColor);

    ARect.Left := ARect.Left + BMP.Width + FBitmapGap;
  end;

begin
  CurrItem := TxTreeItem(Rows[ARow].Objects[0]);

  // Прорисовка фона
  if not (gdFixed in AState) then
  begin
    if ((gdSelected in AState) or (gdFocused in AState)) then
      Canvas.Brush.Color := FSelectedColor
    else if ARow mod 2 = 0 then
      Canvas.Brush.Color := FSecondColor
    else
      Canvas.Brush.Color := FFirstColor;
  end else
    Canvas.Brush.Color := FixedColor;

  Canvas.FillRect(ARect);

  if (CurrItem <> nil) and CurrItem.Important then
    Canvas.Font.Assign(FFontImportant)
  else
    Canvas.Font.Assign(Font);

  // Рисование текста
  if CurrItem = nil then
    inherited DrawCell(ACol, ARow, ARect, AState)
  else begin // Если происходит перерисовка колонки для действий с деревом

    if ACol = FTreeColumn then
    begin
      ARect.Left := ARect.Left + FBranchIndent * (CurrItem.Level - 1);

      if CurrItem.ChildrenCount > 0 then
      begin
        if CurrItem.Expanded then
          DrawMinus(ARect.Left + 2, ARect.Top + (ARect.Bottom - ARect.Top) div 2 - 5)
        else
          DrawPlus(ARect.Left + 2, ARect.Top + (ARect.Bottom - ARect.Top) div 2 - 5);
      end;

      if (CurrItem.Level > 1) or (CurrItem.ChildrenCount > 0) then
        ARect.Left := ARect.Left + 12;
    end;

    CurrCol := CurrItem.ImageNums[Columns[ACol].ColIndex];
    // Если нужно вставить рисунки
    if FPictures <> nil then
      for I := 0 to CurrItem.ImageCount[Columns[ACol].ColIndex] do
        if CurrCol[I] <> -1 then
        begin
          Inc(ARect.Left, FBitmapGap);
          CommonBMP.Width := 0;
          CommonBMP.Height := 0;
          FPictures.GetBitmap(CurrCol[I], CommonBMP);
          DrawImage(CommonBMP);
        end;

    if ARect.Right - ARect.Left > 0 then
    begin
      Pos := ((ARect.Bottom - ARect.Top) - Canvas.TextHeight(Cells[ACol, ARow])) div 2;
      Canvas.TextRect(ARect, ARect.Left + 2, ARect.Top + Pos, Cells[ACol, ARow]);
    end;
  end;
end;

{
  Производим свои действия после загрузки значений свойств
}

procedure TxTreeGrid.Loaded;
var
  I: Integer;
begin
  inherited Loaded;

  if not (csDesigning in ComponentState) then
  begin
    CanUpdate := True;

    OldOnSetEditText := OnSetEditText;
    OnSetEditText := DoOnSetEditText;

    OldOnColumnMoved := OnColumnMoved;
    OnColumnMoved := DoOnColumnMoved;

    FRowCount := RowCount;

    for I := FixedRows to RowCount - 1 do
      Rows[I].Clear;
  end;
end;

{
  По нажатию мыши производим действия с деревом
}

procedure TxTreeGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Integer;
  R: TRect;
  CurrItem: TxTreeItem;
begin
  MouseToCell(X, Y, ACol, ARow);
  R := CellRect(ACol, ARow);

  if Button = mbLeft then
  begin
    if (ACol >= 0) and (ARow >= 0) then
      CurrItem := TxTreeItem(Rows[ARow].Objects[0])
    else
      CurrItem := nil;

    if (CurrItem <> nil) and (CurrItem.ChildrenCount > 0) and (TreeColumn = ACol) then
    begin
      R.Left := R.Left + FBranchIndent * (CurrItem.Level - 1);

      R.Left := R.Left + 2;
      R.Right := R.Left + 9;
      R.Top := R.Top + (R.Bottom - R.Top) div 2 - 5;
      R.Bottom := R.Top + 9;

      if IsInRect(R, X, Y) then
      begin
        CurrItem.Expanded := not CurrItem.Expanded;
        Repaint;
      end else
        inherited MouseDown(Button, Shift, X, Y);
    end else
      inherited MouseDown(Button, Shift, X, Y);
  end else
    inherited MouseDown(Button, Shift, X, Y);

  if (CurrLine >= 0) and (CurrLine <= ColCount - 1) then
    OldColWidth := ColWidths[CurrLine];
end;

{
  По двойному щелчку производим действия с деревом
}

procedure TxTreeGrid.DblClick;
var
  P: TPoint;
  ACol, ARow: Integer;
  CurrItem: TxTreeItem;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
  MouseToCell(P.X, P.Y, ACol, ARow);

  if (ACol >= 0) and (ARow >= 0) then
    CurrItem := TxTreeItem(Rows[ARow].Objects[0])
  else
    CurrItem := nil;

  if (CurrItem <> nil) then
    CurrItem.Expanded := not CurrItem.Expanded;

  inherited DblClick;
end;

{
  По изменению размеров колонки производим их проверку
}

procedure TxTreeGrid.ColWidthsChanged;
var
  ChangeWidth: Integer;
begin
  if CanUpdate and not (csDesigning in ComponentState) then
  begin
    ChangeWidth := OldColWidth - ColWidths[CurrLine];
    CanUpdate := False;

    if CurrLine <> ColCount - 1 then
    begin
      if ColWidths[CurrLine] < FMinColWidth then
      begin
        ColWidths[CurrLine + 1] := ColWidths[CurrLine + 1] + OldColWidth - FMinColWidth;
        ColWidths[CurrLine] := FMinColWidth;
      end else if ColWidths[CurrLine + 1] + ChangeWidth < FMinColWidth then
      begin
        ColWidths[CurrLine] := ColWidths[CurrLine + 1] + OldColWidth - FMinColWidth;
        ColWidths[CurrLine + 1] := FMinColWidth;
      end else begin
        ColWidths[CurrLine + 1] := ColWidths[CurrLine + 1] + ChangeWidth;
      end;
    end else begin
      ColWidths[CurrLine] := OldColWidth;
    end;

    CanUpdate := True;

    if (ScrollBars = ssHorizontal) then
      ScrollBars := ssNone
    else if (ScrollBars = ssBoth) then
      ScrollBars := ssVertical;

  end;

  inherited ColWidthsChanged;
end;

{
  Устанавливаю какую колонку пользователь будет перемещать
}

procedure TxTreeGrid.CalcSizingState(X, Y: Integer; var State: TGridState;
  var Index: Longint; var SizingPos, SizingOfs: Integer;
  var FixedInfo: TGridDrawInfo);
begin
  inherited CalcSizingState(X, Y, State, Index, SizingPos, SizingOfs, FixedInfo);
  
  if State = gsColSizing then
    CurrLine := Index
  else
    CurrLine := -1;   
end;

{
  **********************
  ***  Public Part   ***
  **********************
}

{
  Делаем начальные установки!
}

constructor TxTreeGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FTree := TxTree.Create;
  FTree.Grid := Self;
  FFontImportant := TFont.Create;
  FColumns := TExList.Create;

  if Users = 0 then
  begin
    CommonBMP := TBitmap.Create;
    CommonBMP.Transparent := True;
  end;

  Inc(Users);

  FPictures := nil;
  FTreeColumn := 0;
  FBranchIndent := 10;
  FRowCount := 0;
  FSplitPosition := 0;
  FSplitting := False;
  FSkipColumns := 0;
  FBitmapGap := 2;
  CanUpdate := False;
  CurrLine := -1;
  OldColWidth := 0;
  FMinColWidth := MinColWidth;

  FFirstColor := DefFirstColor;
  FSecondColor := DefSecondColor;
  FSelectedColor := DefSelColor;

  OldOnColumnMoved := nil;
  OldOnSetEditText := nil;
end;

{
  Высвобождаем память
}

destructor TxTreeGrid.Destroy;
begin
  FTree.Free;
  FColumns.Free;
  FFontImportant.Free;

  Dec(Users);
  if Users = 0 then CommonBMP.Free;
    
  inherited Destroy;
end;

{
  Является ли список строк пустым
}

function TxTreeGrid.IsRowClear(Text: TStrings): Boolean;
var
  K: Integer;
begin
  Result := True;

  for K := 0 to Text.Count - 1 do
    if Text[K] <> '' then
    begin
      Result := False;
      Break;
    end;
end;

{
  Являются ли все нижеследующие строки пустыми
}

function TxTreeGrid.IsBelowClear(ARow: Integer): Boolean;
var
  I: Integer;
begin
  Result := True;

  for I := ARow to RowCount - 1 do
    if not IsRowClear(Rows[I]) then
    begin
      Result := False;
      Break;
    end;
end;

{
  Выдает кол-во свободных строк снизу
}

function TxTreeGrid.GetClearCount: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := RowCount - 1 downto FixedRows do
    if IsRowClear(Rows[I]) then
      Inc(Result)
    else
      Break;
end;

{
  Сдвигает все данные вниз
}

procedure TxTreeGrid.MoveDown(ARow: Integer; Count: Integer);
var
  LastUsed: Integer;
  CurrItem: TxTreeItem;
  I: Integer;
begin
  // Если не хватает строк снизу, то добавляем их!
  if GetClearCount < Count then RowCount := RowCount + Count - GetClearCount;

  LastUsed := RowCount - GetClearCount - FixedRows;

  for I := LastUsed downto ARow do
  begin
    CurrItem := TxTreeItem(Rows[I].Objects[0]);

    if CurrItem <> nil then
      CurrItem.Row := CurrItem.Row + Count
    else
      Rows[I + Count].Clear;
  end;
end;

{
  Сдвигает все данные вверх
}

procedure TxTreeGrid.MoveUp(ARow: Integer; Count: Integer);
var
  CurrItem: TxTreeItem;
  I: Integer;
  OldClearCount: Integer;
begin
  OldClearCount := GetClearCount;

  for I := ARow to RowCount - 1 do
  begin
    CurrItem := TxTreeItem(Rows[I].Objects[0]);

    if CurrItem <> nil then
      CurrItem.Row := CurrItem.Row - Count
    else
      Rows[I - Count].Clear;
  end;

  // Удаляем ненужные строки снизу
  RowCount := RowCount - (GetClearCount - OldClearCount);
end;

{
  Меняет местами все колонки для всех элементов
}

procedure TxTreeGrid.ChangeColumns(FromIndex, ToIndex: Integer);
var
  P: Pointer;
begin
  P := FColumns[FromIndex];
  FColumns.Remove(P);
  FColumns.Insert(ToIndex, P);
end;

{
  Устанавливает размеры окна. Здесь идет проверка размеров колонок и
  их изменение
}

procedure TxTreeGrid.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  Rest: Integer;
  I: Integer;
  N: Integer;
  OldClientWidth: Integer;
begin
  // Сохраняем старую ширину окна
  if (Parent <> nil) and CanUpdate and not (csDesigning in ComponentState)
  then
    OldClientWidth := ClientWidth
  else
    OldClientWidth := 0;

  inherited SetBounds(ALeft, ATop, AWidth, AHeight);

  // Производим изменения
  if (Parent <> nil) and CanUpdate and not (csDesigning in ComponentState) then
  begin
    CanUpdate := False;
    if OldClientWidth < CountGridWidth then OldClientWidth := CountGridWidth;

    for I := FSkipColumns + FixedCols to ColCount - 1 do // Check it
    begin
      N := Round(ClientWidth * ColWidths[I] / OldClientWidth);

      if N < FMinColWidth then
        ColWidths[I] := FMinColWidth
      else begin
        ColWidths[I] := N;
        if ColWidths[I] <> N then Messagebeep(0);
      end;
    end;

    // Оставшаяся часть
    Rest := ClientWidth - CountGridWidth;

    for I := FSkipColumns + FixedCols to ColCount - 1 do // Check it
    begin
      if ((ColWidths[I] > FMinColWidth) and (Rest < 0)) or (Rest > 0) then
      begin
        N := ColWidths[I] + Rest;

        if N >= FMinColWidth then
        begin
          ColWidths[I] := N;
          Rest := 0;
        end else begin
          ColWidths[I] := FMinColWidth;
          Rest := N - FMinColWidth;
        end;

        if Rest = 0 then Break;
      end;
    end;

    CanUpdate := True;

    if (ScrollBars = ssHorizontal) then
      ScrollBars := ssNone
    else if (ScrollBars = ssBoth) then
      ScrollBars := ssVertical;

  end;
end;

{
  Получает элемент по координатам окна.
}

function TxTreeGrid.ItemByPoint(P: TPoint): TxTreeItem;
var
  ACol, ARow: Integer;
begin
  MouseToCell(P.X, P.Y, ACol, ARow);

  if (ACol >= 0) and (ARow >= 0) then
    Result := TxTreeItem(Rows[ARow].Objects[0])
  else
    Result := nil;
end;

{
  -----------------------------
  ---   Registration Part   ---
  -----------------------------
}

procedure Register;
begin
  RegisterComponents('gsVC', [TxTreeGrid]);
end;

end.

