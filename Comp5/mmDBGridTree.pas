
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBGridTree.pas

  Abstract

    Improved DBGrid: Tree inside DBGrid.

  Author

    Romanovski Denis (23-02-99)

  Revisions history

    Initial  23-02-99  Dennis  Initial version.

    Beta1    26-02-99  Dennis  Everything works.

    Beta2    27-02-99  Dennis  Detail DataSet property included.
                               Work with images is possible.
                               Search by letters in tree column included.

    Beta3    01-03-99  Dennis  Buggs fixed. 

    Beta4    02-03-99  Dennis  Buggs fixed. Plus, Minus, Enter buttons added.
                               Speed improved.

    Beta5    04-03-99  Dennis  Returning all store parameters to real data set before closing
                               of it.

    Beta6    09-03-99  Dennis  Thread children search included.

    Beta7    10-03-99  Dennis  Bugs on threading fixed.

    Beta8    11-03-99  Dennis  Bugs on threading. I've decided to use API functions instead of methods of
                               TThread class.

    Beta9    13-03-99  Dennis  Bugs on threading. Synchronize is important!

    Beta10   18-03-99  Dennis  Bugs on threading. Before WM_KILLOCUS I terminate thread now!

    Beta11   22-03-99  Dennis  Bugs on threading. I make enablecontrols while controls are disabled.
                               Double Click size counting added to GetTreeMoveBy.

    Beta12   16-04-99  Dennis  Bugs fixed. Some code changed. Editing removed.

    Beta13   21-08-99  Dennis  Can work without threads.

    Beta14   23-08-99  Dennis  Bug on detail fixed.

    ver 15.  16-02-00  Dennis  Events included. Bugs fixed, tested.

--}

unit mmDBGridTree;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, DBClient, DB, DBTables, mmDBGrid, DBCtrls, ExtCtrls{, mmRunTimeStore};

type
  // Событие вызова списка детей по коду родителя
  TmmDBGridTreeGetChildren = procedure
    (
      Sender: TObject;
      Parent: Integer;
      var Dataset: TDataset
    )
  of object;

  // Событие получения ключа родителя по данном ключу
  TmmDBGridTreeGetParent = function
    (
      Sender: TObject;
      Key: Integer;
      var Parent: Integer
    ): Boolean
  of object;

  // Существует ли вложеная ветвь(ребенок) хоть одна (один)
  TmmDBGridTreeChildExists = function
    (
      Sender: TObject;
      Parent: Integer
    ): Boolean
  of object;

  // Возвращает список деталей
  TmmDBGridTreeGetDetails = procedure
    (
      Sender: TObject;
      Key: Integer;
      var Dataset: TDataset
    )
  of object;

  // Существует ли деталь или нет
  TmmDBGridTreeDetailExists = function
    (
      Sender: TObject;
      Parent: Integer
    ): Boolean
  of object;


// Установки для таблицы-дерева по умолчанию.
const
  DefIndent = 10;
  DefIndexGroup = -1;
  DefIndexGroupOpen = -1;
  DefIndexIndeterminate = -1;
  DefIndexSimple = -1;
  DefIndexDetail = -1;

type
  TmmDBGridTree = class(TmmDBGrid)
  private
    FTree: TClientDataSet; // Таблица данных дерева
    FTreeDataSource: TDataSource; // Источник данных дерева
    FRealDataSource: TDataSource; // Реальные данные для дерева

    FFieldKey, FFieldParent, FFieldTree: String; // Поля собственное, родителя, дерева

    OldRealStateChange: TNotifyEvent; // Event изменения состояния источника реальных данных
    OldState: TDataSetState; // Прошлое состояние источника данных
    FIndent: Integer; // Отступ слева для каждой ветки
    FDetailDataSource: TDataSource; // Таблица, зависимая от таблицы дерева!

    FImages: TImageList; // Список рисунков для отображения в дереве.

    FIndexGroup: Integer; // Закрытая группа
    FIndexGroupOpen: Integer; // Открытая группа
    FIndexIndeterminate: Integer; // Не определено есть дети или нет
    FIndexSimple: Integer; // Нет детей
    FIndexDetail: Integer; // Зависимая запись

    FDataAfterScroll: Boolean; // автоматическое передвижение данных в базе.

    DrawBMP: TBitmap; // BITMAP для рисования в ячейках

    PressProcessing: Boolean; // Происходит ввод символов поиска
    ReStartProcessing: Boolean; // Флаг перехода к начальной задержке
    SearchKey: String; // Ключ поиска по полю
    SkipStoreSettings: Boolean; // Пропускать ли запись установок

    FOpened: TList; // Список открытых эелеметов

    FGetChildren: TmmDBGridTreeGetChildren; // Событие вызова списка детей
    FGetParent: TmmDBGridTreeGetParent; // Событие получения кода родителя
    FChildExists: TmmDBGridTreeChildExists; // Событие на существование вложенного уровня (ребенка)
    FGetDetails: TmmDBGridTreeGetDetails; // Возвращает список деталей
    FDetailExists: TmmDBGridTreeDetailExists; // Существует ли деталь

    procedure DoOnRealStateChange(Sender: TObject);

    procedure SaveTableSettings;

    procedure OpenCurrLevel(const DataSet: TDataSet = nil);
    procedure CloseCurrLevel;

    function FindOpened(Key: Integer; var Index: Integer): Boolean;

    procedure DrawMinus(X, Y: Integer);
    procedure DrawPlus(X, Y: Integer; Assured: Boolean);

    procedure ProcessDelay;
    procedure Find;

    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;

    function GetDataSource: TDataSource;
    function GetRealDataSet: TDataSet;
    function GetDetailDataSet: TDataSet;

    function GetIsCustomTree: Boolean;

    procedure DoOnTreeAfterScroll(DataSet: TDataSet);

    procedure SetDataSource(const Value: TDataSource);
    procedure SetFieldKey(const Value: String);
    procedure SetFieldParent(const Value: String);
    procedure SetFieldTree(const Value: String);
    procedure SetIndent(const Value: Integer);
    procedure SetDetailDataSource(const Value: TDataSource);
    procedure SetImages(const Value: TImageList);
    procedure SetIndexGroup(const Value: Integer);
    procedure SetIndexGroupOpen(const Value: Integer);
    procedure SetIndexIndeterminate(const Value: Integer);
    procedure SetIndexSimple(const Value: Integer);
    procedure SetIndexDetail(const Value: Integer);

  protected
    TreeMoveBy: Integer;
    BlockDelete: Boolean;

    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure Notification(AComponent: TComponent; Operation: Toperation); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Loaded; override;
    procedure ColEnter; override;
    procedure SetColumnAttributes; override;
    function GetEditText(ACol, ARow: Longint): string; override;

    function GetTreeMoveBy(WhileDrawing: Boolean; CheckField: Boolean; F: TField): Integer; override;
    procedure DoOnSearch(Sender: TObject); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure CreateTreeTable;

    function OpenKey(Key: Integer; const OpenLast: Boolean = False): Boolean;
    function CloseKey(Key: Integer): Boolean;
    function IsDetail: Boolean;
    function IsOpened: Boolean;
    function HasChildren: Boolean;

    procedure Refresh;

    // Таблица реальных данных
    property RealDataSet: TDataSet read GetRealDataSet;
    // Таблица зависимых данных
    property DetailDataSet: TDataSet read GetDetailDataSet;
    // Таблица дерева
    property Tree: TClientDataSet read FTree;
    // Является ли пользовательским деревом (через события)
    property IsCustomTree: Boolean read GetIsCustomTree;

  published
    // Источник данных для формирования дерева
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    // Поле на себя
    property FieldKey: String read FFieldKey write SetFieldKey;
    // Поле на родителя
    property FieldParent: String read FFieldParent write SetFieldParent;
    // Поле, где будет отображаться дерево
    property FieldTree: String read FFieldTree write SetFieldTree;
    // Оступ слева для каждой ветки дерева
    property Indent: Integer read FIndent write SetIndent default DefIndent;
    // Таблица, являющаяся зависимой от таблицы дерева!
    property DetailDataSource: TDataSource read FDetailDataSource write SetDetailDataSource;
    // Список рисунков для отображения в дереве.
    property Images: TImageList read FImages write SetImages;
    // Закрытая группа
    property IndexGroup: Integer read FIndexGroup write SetIndexGroup
      default DefIndexGroup;
    // Открытая группа
    property IndexGroupOpen: Integer read FIndexGroupOpen write SetIndexGroupOpen
      default DefIndexGroupOpen;
    // Не определено есть дети или нет
    property IndexIndeterminate: Integer read FIndexIndeterminate write SetIndexIndeterminate
      default DefIndexIndeterminate;
    // Элемент без детей
    property IndexSimple: Integer read FIndexSimple write SetIndexSimple
      default DefIndexSimple;
      // Зависимый элемент
    property IndexDetail: Integer read FIndexDetail write SetIndexDetail
      default DefIndexDetail;
    // Производить ли передвижение курсора таблицы реальных данных
    property DataAfterScroll: Boolean read FDataAfterScroll write FDataAfterScroll;

    // Событие возвращающее список детей
    property Children: TmmDBGridTreeGetChildren read FGetChildren write FGetChildren;
    // Событие получения кода родителя
    property GetParent: TmmDBGridTreeGetParent read FGetParent write FGetParent;
    // Событие на существования вложенных веток (детей)
    property ChildExists: TmmDBGridTreeChildExists read FChildExists write FChildExists;
    // Возвращает список деталей
    property GetDetails: TmmDBGridTreeGetDetails read FGetDetails write FGetDetails;
    // Существует ли деталь
    property DetailExists: TmmDBGridTreeDetailExists read FDetailExists write FDetailExists;


  end;

// Внутренние поля
const
  NAME_BRANCHFIELD = 'TREE_BRANCH';
  NAME_GROUPFIELD = 'TREE_GROUP';

  // Кол-во символов на одном уровне
  SymbolsPerLevel = 3;

implementation

uses mmDBGridTreeThds, gsMultilingualSupport;

const
  GapBetween = 5;

  // Классы полей по их типам
  TreeDefaultFieldClasses: array[TFieldType] of TFieldClass = (
    nil,                { ftUnknown }
    TStringField,       { ftString }
    TSmallintField,     { ftSmallint }
    TIntegerField,      { ftInteger }
    TWordField,         { ftWord }
    TBooleanField,      { ftBoolean }
    TFloatField,        { ftFloat }
    TCurrencyField,     { ftCurrency }
    TBCDField,          { ftBCD }
    TDateField,         { ftDate }
    TTimeField,         { ftTime }
    TDateTimeField,     { ftDateTime }
    TBytesField,        { ftBytes }
    TVarBytesField,     { ftVarBytes }
    TIntegerField,      { ftAutoInc }
    TBlobField,         { ftBlob }
    TMemoField,         { ftMemo }
    TGraphicField,      { ftGraphic }
    TBlobField,         { ftFmtMemo }
    TBlobField,         { ftParadoxOle }
    TBlobField,         { ftDBaseOle }
    TBlobField,         { ftTypedBinary }
    nil,                { ftCursor }
    TStringField,       { ftFixedChar }
    TWideStringField,   { ftWideString }
    TLargeIntField,     { ftLargeInt }
    TADTField,          { ftADT }
    TArrayField,        { ftArray }
    TReferenceField,    { ftReference }
    TDataSetField,      { ftDataSet }
    TBlobField,         { ftOraBlob }
    TMemoField,         { ftOraClob }
    TVariantField,      { ftVariant }
    TInterfaceField,    { ftInterface }
    TIDispatchField,     { ftIDispatch }
    TGuidField);        { ftGuid }

{
  --------------------------------------------
  ---   Additional functions, procedures   ---
  --------------------------------------------
}

// Вовзращает следующий код
function GetNextCode(Code: String; NewLevel: Boolean): String;

const
  SymbolCount = 36;

  // Все символы, используемые для создания индекса
  Symbols: array[0..SymbolCount - 1] of Char =
  (
   '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
   'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
   'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'
  );

  // Следующий символ в массиве
  function GetNextSymbol(var C: Char): Boolean;
  var
    I: Integer;
  begin
    Result := False;

    for I := 0 to SymbolCount - 2 do
      if C = Symbols[I] then
      begin
        C := Symbols[I + 1];
        Result := True;
        Break;
      end;
  end;

var
  C1, C2, C3: Char;
begin
  // Если первый код
  if (Code = '') or NewLevel then
    Code := Code + Symbols[0] + Symbols[0] + Symbols[0]
  else begin
    // Если нет, то получаем следующий код
    C1 := Copy(Code, Length(Code) - 2, 3)[1];
    C2 := Copy(Code, Length(Code) - 2, 3)[2];
    C3 := Copy(Code, Length(Code) - 2, 3)[3];

    if not GetNextSymbol(C3) then
    begin
      C3 := Symbols[0];
      if not GetNextSymbol(C2) then
      begin
        C2 := Symbols[0];
        if not GetNextSymbol(C1) then
        begin
          raise Exception.Create(TranslateText('Нарушен лимит записей одного уровня!'));
        end;
      end;
    end;

    Code := Copy(Code, 0, Length(Code) - 3) + C1 + C2 + C3;
  end;

  Result := Code;
end;

{
  -------------------------------
  ---   TmmDBGridTree Class   ---
  -------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TmmDBGridTree.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FTree := nil;

  if not (csDesigning in ComponentState) then
  begin
    // Создаем таблицу для формирования дерева
    FTree := TClientDataSet.Create(Self);
    FTree.AfterScroll := DoOnTreeAfterScroll;

    FTreeDataSource := TDataSource.Create(Self);
    FTreeDataSource.DataSet := FTree;
  end;

  // В начале таблицу реальных данных ставим нулевую
  FRealDataSource := nil;
  FDetailDataSource := nil;

  OldRealStateChange := nil;
  OldState := dsInactive;

  FGetChildren := nil;
  FGetParent := nil;
  FChildExists := nil;
  FGetDetails := nil;
  FDetailExists := nil;

  // Для получения полей
  FFieldKey := '';
  FFieldParent := '';
  FFieldTree :=  '';

  FIndent := DefIndent;
  FIndexGroup := DefIndexGroup;
  FIndexGroupOpen := DefIndexGroupOpen;
  FIndexIndeterminate := DefIndexIndeterminate;
  FIndexSimple := DefIndexSimple;
  FIndexDetail := DefIndexDetail;

  FImages := nil;

  FDataAfterScroll := False;
  SkipStoreSettings := False;

  // Создаем BITMAP для рисования в ячейках
  DrawBMP := TBitmap.Create;

  PressProcessing := False;
  ReStartProcessing := False;

  FOpened := TList.Create;
  BlockDelete := False;
end;

{
  Высвобождаем память.
}

destructor TmmDBGridTree.Destroy;
begin
  FOpened.Free;
  DrawBMP.Free;

  inherited Destroy;
end;

{
  Создаем таблицу по образцу и подобию таблицы с реальными данными.
  Добавляем отдельное поле уровня дерева!
}

procedure TmmDBgridTree.CreateTreeTable;
var
  I: Integer;
  F: TField;
  IndDef: TIndexDef;
  CurrDataSet: TDataSet;
  CurrDetails: TDataSet;
begin
  if Assigned(FGetChildren) then
    FGetChildren(Self, 0, CurrDataSet)
  else
    CurrDataSet := RealDataSet;

  if Assigned(FGetDetails) then
    FGetDetails(Self, CurrDataSet.FieldByName(FFieldKey).AsInteger, CurrDetails)
  else
    CurrDetails := DetailDataSet;

  SkipStoreSettings := True;

  if
    not Assigned(FGetChildren)
      and
    (
      (FRealDataSource = nil)
        or
      (FRealDataSource.State = dsInactive)
    )
  then
    Exit;

  // Высвобождаем дерево от ранее использованных данных.
  FTree.Close;
  FTree.Fields.Clear;

  // Освобождаем список
  FOpened.Clear;

  // Устаналиваем опции фильтра для бытрого поиска
  CurrDataSet.FilterOptions := [foNoPartialCompare, foCaseInsensitive];

  // Производим копирование полей из таблицы с реальными данными
  for I := 0 to CurrDataSet.FieldCount - 1 do
  begin
    F := TreeDefaultFieldClasses[CurrDataSet.Fields[I].DataType].Create(Self);

    F.FieldName := CurrDataSet.Fields[I].FieldName;
    F.FieldKind := fkData;

    F.Visible := CurrDataSet.Fields[I].Visible;
    F.Size := CurrDataSet.Fields[I].Size;
    F.DisplayWidth := CurrDataSet.Fields[I].DisplayWidth;
    F.DisplayLabel := CurrDataSet.Fields[I].DisplayLabel;
    F.EditMask := CurrDataSet.Fields[I].EditMask;
    F.Alignment := CurrDataSet.Fields[I].Alignment;

    F.DataSet := FTree;
  end;

  if Assigned(CurrDetails) and (Assigned(FGetDetails) or (DetailDataSource.State <> dsInactive)) then
    // Производим копирование полей из таблицы с реальными данными
    for I := 0 to CurrDetails.FieldCount - 1 do
    begin
      // Нельза добавлять поля с одинаковыми названиями
      if FTree.FindField(CurrDetails.Fields[I].FieldName) <> nil then Continue;

      F := TreeDefaultFieldClasses[CurrDetails.Fields[I].DataType].Create(Self);

      F.FieldName := CurrDetails.Fields[I].FieldName;
      F.FieldKind := CurrDetails.Fields[I].FieldKind;
      F.Visible := CurrDetails.Fields[I].Visible;
      F.Size := CurrDetails.Fields[I].Size;
      F.DisplayWidth := CurrDetails.Fields[I].DisplayWidth;
      F.DisplayLabel := CurrDetails.Fields[I].DisplayLabel;
      F.EditMask := CurrDetails.Fields[I].EditMask;
      F.Alignment := CurrDetails.Fields[I].Alignment;

      F.DataSet := FTree;
    end;

  // Создаем поле индексации
  F := TStringField.Create(Self);
  F.FieldName := NAME_GROUPFIELD;
  F.Size := 254;
  F.Visible := False;
  F.DataSet := FTree;

  // Создаем поле индексации
  F := TIntegerField.Create(Self);
  F.FieldName := NAME_BRANCHFIELD;
  F.Visible := False;
  F.DataSet := FTree;

  // Создаем индекс по полю индексации
  IndDef := FTree.IndexDefs.AddIndexDef;
  IndDef.Fields := NAME_GROUPFIELD;
  IndDef.Options := [ixPrimary, ixUnique];

  // Устанавливаем индекс по таблице
  FTree.IndexFieldNames := IndDef.Fields;

  if Assigned(FGetChildren) then
    DataSource := FTreeDataSource
  else
    FTreeDataSource.DataSet := FTree;

  // Создаем таблицу в памяти
  FTree.EnableControls;
  FTree.CreateDataSet;

  // Открываем самый первый уровень
  OpenCurrLevel(CurrDataSet);
  SkipStoreSettings := False;
end;

{
  Открывает уровень по ключу.
}

function TmmDBGridTree.OpenKey(Key: Integer; const OpenLast: Boolean = False): Boolean;
var
  Keys: TList;
  I: Integer;
  Parent: Integer;
begin
  FTree.DisableControls;
  Result := False;
  Keys := TList.Create;

  // Находим позицию по ключу
  if Assigned(FGetParent) then
    FGetParent(Self, Key, Parent)
  else begin
    RealDataSet.DisableControls;

    if RealDataSet.Locate(FFieldKey, Key, []) then
      Parent := RealDataSet.FieldByName(FFieldParent).AsInteger
    else begin
      RealDataSet.EnableControls;
      FTree.EnableControls;
      Exit;
    end;
  end;

  try
    // Записываем всех родителей
    if Assigned(FGetParent) then
    begin
      while FGetParent(Self, Key, Parent) do
      begin
        Keys.Add(Pointer(Key));
        Key := Parent;
      end;
    end else
      while not RealDataSet.FieldByName(FFieldParent).isNull do
      begin
        Keys.Add(Pointer(Key));
        if RealDataSet.Locate(FFieldKey, Parent, []) then
        begin
          Key := RealDataSet.FieldByName(FFieldKey).AsInteger;
          Parent := RealDataSet.FieldByName(FFieldParent).AsInteger;
        end else
          abort;
      end;

    FTree.Locate(FFieldKey, Key, []);

    if not Assigned(FGetParent) then
      RealDataSet.EnableControls;

    // открываем всех родителей по порядку
    for I := Keys.Count - 1 downto 0 do
    begin
      if not IsOpened then OpenCurrLevel;
      FTree.Locate(FFieldKey, Integer(Keys[I]), []);
    end;

    if OpenLast and not IsOpened then OpenCurrLevel;

    Result := True;
  finally
    Keys.Free;
    FTree.EnableControls;
  end;
end;

{
  Закрывает ветвь дерева по ключу.
}

function TmmDBGridTree.CloseKey(Key: Integer): Boolean;
var
  Parent: Integer;
begin
  Result := False;

  // Находим позицию по ключу и закрываем ветвь

  if Assigned(FGetParent) then
  begin
    if FGetParent(Self, Key, Parent) then
    begin
      CloseCurrLevel;
      Result := True;
    end;
  end else
    if RealDataSet.Locate(FFieldKey, Key, []) then
    begin
      CloseCurrLevel;
      Result := True;
    end;
end;

{
  Является ли из данных "деталей".
}

function TmmDBGridTree.IsDetail: Boolean;
begin
  if (DataLink.DataSet = nil) or DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).IsNull then
    Result := False
  else
    Result := HiWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger) = 2;
end;

{
  Проверяет, если текущий уровень открыт.
}

function TmmDBGridTree.IsOpened: Boolean;
begin
  if (DataLink.DataSet = nil) or DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).IsNull then
    Result := False
  else
    Result := Boolean(HiWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger));
end;

{
  Определяет наличие у данной ветки детей.
}

function TmmDBGridTree.HasChildren: Boolean;
begin
  if DataLink.DataSet <> nil then
  begin
    // Если данные о наличии детей не созданы, то создаем их
    if DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).IsNull then
    begin
      // Нельзя допустить рекурсии из-за detail данных
      if IsDetail then
        Result := False
      else begin
        if Assigned(FChildExists) then
          Result := FChildExists(Self, FTree.FieldByName(FFieldKey).AsInteger)
        else
          Result := RealDataSet.Locate(FFieldParent, FTree.FieldByName(FFieldKey).Value, []);

        // Если отсутствуют данные по дереву, то смотрим зависимую таблицу
        if
          not Result
            and
          (
            Assigned(FDetailExists)
              or
            Assigned(DetailDataSource)
              and
            (DetailDataSource.State <> dsInactive)
          )
        then begin
          if Assigned(FDetailExists) then
            Result :=
              FDetailExists(Self, DataLink.DataSet.FieldByName(FFieldKey).AsInteger)
          else
            Result := RealDataSet.Locate
              (
                FFieldKey,
                DataLink.DataSet.FieldByName(FFieldKey).AsInteger,
                []
              )
                and
              (DetailDataSet.RecordCount > 0);
        end;
      end;

      DataLink.DataSet.Edit;
      DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(Word(Result), 0);
      DataLink.DataSet.Post;
    end else
      // Иначе просто считываем их
      Result := Boolean(LoWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger));
  end else
    Result := False;
end;

{
  Обновляет дерево.
}

procedure TmmDBGridTree.Refresh;
var
  Keys: TList;
  Key: Integer;
  I: Integer;
  OldField: String;
begin
  Keys := TList.Create;

  try
    if SelectedField <> nil then
      OldField := SelectedField.FieldName
    else
      OldField := '';
      
    FTree.DisableControls;

    Key := FTree.FieldByName(FFieldKey).AsInteger;

    FTree.First;

    while not FTree.EOF do
    begin
      if IsOpened then
        Keys.Add(Pointer(FTree.FieldByName(FFieldKey).AsInteger));

      FTree.Next;
    end;

    CreateTreeTable;

    for I := 0 to Keys.Count - 1 do
      OpenKey(Integer(Keys[I]), True);

    FTree.Locate(FFieldKey, Key, []);
    if OldField <> '' then SelectedField := DataLink.DataSet.FindField(OldField);
  finally
    FTree.EnableControls;
    Keys.Free;
  end;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Двойной щелчек в таблице.
}

procedure TmmDBGridTree.DblClick;
var
  C: TGridCoord;
  R: TRect;
  Level: Integer;
begin
  inherited DblClick;

  C := MouseCoord(HitTest.X, HitTest.Y);
  R := CellRect(C.X, C.Y);

  // Если поле, где отображается дерево, то производим раскрытие текущей ветки
  if (FTreeDataSource.State <> dsInactive) and (SelectedField <> nil) and
    (AnsiCompareText(SelectedField.FieldName, FFieldTree) = 0) and HasChildren and
    (C.X - Integer(dgIndicator in Options) >= 0) and
    (C.Y - Integer(dgTitles in Options) >= 0) then
  begin
    // Устанавливаем указатель в базе данных на необходимую запись для получения данных
    Level := Length(DataLink.DataSet.FieldByName(NAME_GROUPFIELD).DisplayText) div SymbolsPerLevel;

    R.Left := R.Left + FIndent * (Level - 1) + 2;
    R.Right := R.Left + 7;
    R.Top := R.Top + (R.Bottom - R.Top) div CurrLineCount div 2 - 4;
    R.Bottom := R.Top + 9;

    if not IsInRect(R, HitTest.X, HitTest.Y) then
    begin
      if not IsOpened then
        OpenCurrLevel
      else
        CloseCurrLevel;
    end;    
  end;
end;

{
  По нажатию мыши производим действия с деревом
}

procedure TmmDBGridTree.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  R, R2: TRect;
  C: TGridCoord;
  Level: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);

  C := MouseCoord(X, Y);
  R := CellRect(C.X, C.Y);

  if (FTreeDataSource.State <> dsInactive) and
    (Button = mbLeft) and
    (C.X - Integer(dgIndicator in Options) >= 0) and
    (C.Y - Integer(dgTitles in Options) >= 0) and
    Assigned(Columns[C.X - Integer(dgIndicator in Options)].Field) and
    (AnsiCompareText(Columns[C.X - Integer(dgIndicator in Options)].Field.FieldName,
      FFieldTree) = 0) then
  begin
    // Устанавливаем указатель в базе данных на необходимую запись для получения данных
    Level := Length(DataLink.DataSet.FieldByName(NAME_GROUPFIELD).AsString) div SymbolsPerLevel;

    R2 := R;

    R.Left := R.Left + FIndent * (Level - 1) + 2;
    R.Right := R.Left + 7;
    R.Top := R.Top + (R.Bottom - R.Top) div CurrLineCount div 2 - 4;
    R.Bottom := R.Top + 9;

    // Если курсор мыши находится в области раскрытия/закрытия ветви и она имеет детей
    if IsInRect(R, X, Y) and HasChildren then
    begin
      if not IsOpened then
        OpenCurrLevel
      else
        CloseCurrLevel;
    end;
  end;
end;

{
  Производит перерисовку ячейки таблицы.
}

procedure TmmDBGridTree.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  OldActive: Integer;
  IsChildren, IsOpen: Boolean;
  OldKey: String;
  Assured: Boolean;
  TheColumn: TColumn;
  BitmapIndex: Integer;

  // Рисует bitmap
  procedure DrawImage(const BMP: TBitmap; R: TRect);
  var
    Pos: Integer;
  begin
    Inc(R.Top);
    Dec(R.Bottom);

    Pos := (BMP.Height - (R.Bottom - R.Top)) div 2;

    Canvas.BrushCopy(
      Rect(R.Left, R.Top, R.Right, R.Bottom),
      BMP,
      Rect(0, Pos, R.Right - R.Left, R.Bottom - R.Top + Pos),
      BMP.TransparentColor);

    R.Left := R.Left + BMP.Width + GapBetween;
  end;

begin
  Assured := False;

  // Получаем текущую колонку
  if DataLink.Active and not (gdFixed in AState) then
    TheColumn := Columns[ACol - Integer(dgIndicator in Options)]
  else
    TheColumn := nil;

  if not (csDesigning in ComponentState) and (TheColumn <> nil) and (TheColumn.Field <> nil) and
    (AnsiCompareText(TheColumn.Field.FieldName, FFieldTree) = 0) then
  begin
    SkipActiveRecord := True;
    // Устанавливаем указатель в базе данных на необходимую запись для
    // получения данных
    OldActive := DataLink.ActiveRecord;
    try
      DataLink.ActiveRecord := ARow - Integer(dgTitles in Options);

      // Символы ключа ветки
      OldKey := DataLink.DataSet.FieldByName(NAME_GROUPFIELD).AsString;
      // Определяем сдвиг вправо
      TreeMoveBy := (Length(OldKey) div SymbolsPerLevel - 1) * FIndent + 12;

      // Узнаем, есть ли у данной ветки дети
      if DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).IsNull then
      begin
        IsChildren := True;
        IsOpen := False;
      end else begin
        IsChildren := Boolean(LoWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger));
        IsOpen := Boolean(HiWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger));
        Assured := True;
      end;

      if IsDetail then
        BitmapIndex := FIndexDetail
      else if IsChildren then
      begin
        if IsOpen then
          BitmapIndex := FIndexGroupOpen
        else if Assured then
          BitmapIndex := FIndexGroup
        else
          BitmapIndex := FIndexIndeterminate;
      end else begin
        BitmapIndex := FIndexSimple;

        if (OldActive = DataLink.ActiveRecord) and (FIndexGroup = FIndexSimple) then
          BitmapIndex := FIndexGroupOpen;
      end;

      DrawBMP.Width := 0;
      DrawBMP.Height := 0;

      if BitmapIndex > -1 then
        If FImages <> nil then
        begin
          FImages.GetBitmap(BitmapIndex, DrawBMP);

          if (DrawBMP.Width = 0) or (DrawBMP.Height = 0) then
            BitmapIndex := -1
          else
            Inc(TreeMoveBy, DrawBMP.Width);
        end else
          BitmapIndex := -1;

      inherited DrawCell(ACol, ARow, ARect, AState);

      // Проверка на случай отсутствия данных в таблице
      if Length(OldKey) > 0 then
      begin
        // Рисуем плюс или минус
        if BitmapIndex > -1 then
          DrawImage(DrawBMP,
            Rect(ARect.Left + TreeMoveBy - DrawBMP.Width + 1, ARect.Top,
              ARect.Right, ARect.Top + (ARect.Bottom - ARect.Top) div CurrLineCount));

        if IsChildren then
        begin
          if IsOpen then
            DrawMinus(ARect.Left + FIndent * (Length(OldKey) div SymbolsPerLevel - 1) + 2,
              ARect.Top + (ARect.Bottom - ARect.Top) div CurrLineCount div 2 - 4)
          else
            DrawPlus(ARect.Left + FIndent * (Length(OldKey) div SymbolsPerLevel - 1) + 2,
              ARect.Top + (ARect.Bottom - ARect.Top) div CurrLineCount div 2 - 4, Assured);
        end;
      end;
    finally
      DataLink.ActiveRecord := OldActive;
    end;
  end else
    inherited DrawCell(ACol, ARow, ARect, AState);

  // Устанавливаем сдвиг на 0. Это обязательно!!!
  TreeMoveBy := 0;
  SkipActiveRecord := False;
end;

{
  Получаем сведения об удалении компонент!
}

procedure TmmDBGridTree.Notification(AComponent: TComponent; Operation: Toperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if (AComponent = FDetailDataSource) then
      DetailDataSource := nil
    else if (AComponent = FImages) then
      Images := nil;
  end;    
end;

{
  отлавливаем нажатие клавиши ввод
}

procedure TmmDBGridTree.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  if (SelectedField = FTree.FieldByName(FFieldTree)) and not (dgEditing in Options) then
    if Key = VK_RETURN then
    begin
      if not IsOpened then
        OpenCurrLevel
      else
        CloseCurrLevel;
    end;
end;

{
  По нажатиям клавиш производися поиск слова.
}

procedure TmmDBGridTree.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);

  if (SelectedField = FTree.FieldByName(FFieldTree)) and not (dgEditing in Options) then
    case Key of
      '+':
        if not IsOpened then OpenCurrLevel;
      '-':
        if IsOpened then CloseCurrLevel;
      else if Key in [#32..#255] then
      begin
        SearchKey := SearchKey + Key;
        Find;

        if not PressProcessing then
          ProcessDelay
        else
          ReStartProcessing := True;
      end;
    end;
end;

{
  После загрузки свойств делаем свои установки.
}

procedure TmmDBGridTree.Loaded;
begin
  inherited Loaded;
end;

{
  По входу в колонку с деревом запрещаем редактирование.
}

procedure TmmDBGridTree.ColEnter;
begin
  inherited ColEnter;
end;

{
  По установке атирибутов колонок производим их запись в реальную таблицу.
}

procedure TmmDBGridTree.SetColumnAttributes;
begin
  inherited SetColumnAttributes;
  if not SkipStoreSettings then SaveTableSettings;
end;

{
  Возвращает текст для редактирования в InpcaeEditor.
}

function TmmDBGridTree.GetEditText(ACol, ARow: Longint): string;
begin
  Result := inherited GetEditText(ACol, ARow);
end;

{
  Устанавливает отступ слева для дерева.
}

function TmmDBGridTree.GetTreeMoveBy(WhileDrawing: Boolean; CheckField: Boolean; F: TField): Integer;
var
  BitmapIndex: Integer;
  IsChildren, IsOpen, Assured: Boolean;
begin
  if WhileDrawing then // Если во время рисования текста
    Result := TreeMoveBy
  else begin // Если в другом случае, то вычисляем самостоятельно
    // Если не в поле дерева, то возвращает 0 при флаге CheckField
    if CheckField and (F <> DataLink.DataSet.FindField(FFieldTree)) then
    begin
      Result := 0;
      Exit;
    end;

    Result := (Length(DataLink.DataSet.FieldByName(NAME_GROUPFIELD).AsString)
      div SymbolsPerLevel - 1) * FIndent + 12;

    if DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).IsNull then
    begin
      IsChildren := True;
      IsOpen := False;
      Assured := False;
    end else begin
      IsChildren := Boolean(LoWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger));
      IsOpen := Boolean(HiWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger));
      Assured := True;
    end;

    if DataLink.DataSet.FieldByName(FFieldParent).IsNull and
      (Length(DataLink.DataSet.FieldByName(NAME_GROUPFIELD).AsString) div SymbolsPerLevel > 1)
    then
      BitmapIndex := FIndexDetail
    else if IsChildren then
    begin
      if IsOpen then
        BitmapIndex := FIndexGroupOpen
      else if Assured then
        BitmapIndex := FIndexGroup
      else
        BitmapIndex := FIndexIndeterminate;
    end else
      BitmapIndex := FIndexSimple;

    DrawBMP.Width := 0;
    DrawBMP.Height := 0;

    if BitmapIndex > -1 then
      If FImages <> nil then
      begin
        FImages.GetBitmap(BitmapIndex, DrawBMP);

        if (DrawBMP.Width <> 0) and (DrawBMP.Height <> 0) then
          Inc(Result, DrawBMP.Width);
      end;
  end;
end;

{
  Активируем диалоговое окно поиска.
}

procedure TmmDBGridTree.DoOnSearch(Sender: TObject);
begin
  if (DataLink <> nil) and DataLink.Active and Assigned(SelectedField) then
  begin
    GetSearch.Grid := Self;
    GetSearch.DataField := '';
    GetSearch.DataSource := nil;
    GetSearch.DataSource := FRealDataSource;
    GetSearch.DataField := SelectedField.FieldName;
    GetSearch.CustomSearch := True;
    GetSearch.ColorDialog := ColorDialogs;
    GetSearch.ExecuteDialog;
  end;
end;
{
  ************************
  ***   Private Part   ***
  ************************
}

{
  По изменению состояния реальных данных производим свои действия.
}

procedure TmmDBGridTree.DoOnRealStateChange(Sender: TObject);
begin
  if not Assigned(FGetChildren) then
  begin
    // По изменению состояния источника данных соответственно открываем либо закрываем
    // дерево!
    if (FRealDataSource.State = dsInactive) and (OldState <> dsInactive) then
    begin
      FTree.Close;
    end else if (OldState = dsInactive) and (FRealDataSource.State <> dsInactive) then
      CreateTreeTable;

    // Сохраняем старое состояние источника данных
    OldState := FRealDataSource.State;
  end;  
end;

{
  Сохраняет текущие установки по колонке.
}

procedure TmmDBGridTree.SaveTableSettings;
var
  I: Integer;
  F: TField;
begin
  if
    (csDesigning in ComponentState)
      or
    not Assigned(FTree)
      or
    not Assigned(RealDataSet)
  then
    Exit;

  // Производим копирование полей из таблицы с реальными данными
  for I := 0 to FTree.FieldCount - 1 do
  begin
    F := RealDataSet.FindField(FTree.Fields[I].FieldName);

    if F <> nil then
    begin
      F.Visible := FTree.Fields[I].Visible;
      F.DisplayWidth := FTree.Fields[I].DisplayWidth;
      F.DisplayLabel := FTree.Fields[I].DisplayLabel;
      F.Alignment := FTree.Fields[I].Alignment;
    end;
  end;
end;

{
  Открывает новый уровень в дереве.
}

procedure TmmDBGridTree.OpenCurrLevel(const DataSet: TDataSet = nil);
var
  Key, Parent: Integer;
  I, K: Integer;
  BM: TBookMark;
  NextCode: String;
  IsChildren: Boolean;
  NeedToGoto: Boolean;
  ShouldOpen, ShouldCheck: TList;
  ZeroLevel, ParentNULL: Boolean;
  CurrDataSet: TDataSet;
  CurrDetails: TDataSet;
begin
  // Проверка на случай неудачного уничтожения.
  while FTree.ControlsDisabled do FTree.EnableControls;

  FTree.DisableControls;

  NeedToGoto := False;
  ZeroLevel := False;

  // Получаем текущую ветвь
  Key := FTree.FieldByName(FFieldKey).AsInteger;
  Parent := FTree.FieldByName(FFieldParent).AsInteger;
  ParentNULL := FTree.FieldByName(FFieldParent).IsNull;

  // Нельзя допустить рекурсии из-за detail данных
  if IsDetail then
  begin
    FTree.Edit;
    FTree.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(0, 0);
    FTree.Post;

    FTree.EnableControls;
    Exit;
  end;

  if not Assigned(FGetChildren) then
  begin
    CurrDataSet := RealDataSet;
    CurrDataSet.Filtered := False;

    if FTree.RecordCount = 0 then
    begin
      NextCode := GetNextCode('', True);
      CurrDataSet.Filter := FFieldParent + '=NULL';
      ZeroLevel := True;
    end else begin
      CurrDataSet.Filter := Format(FFieldParent + '=%d', [Key]);
      NextCode := GetNextCode(FTree.FieldByName(NAME_GROUPFIELD).AsString, True);
    end;
  end else begin
    if FTree.RecordCount = 0 then
    begin
      CurrDataSet := DataSet;
      //FGetChildren(Self, 0, CurrDataSet);

      // Выборка не нужна, т.к. она уже сделана на более раннем уровне
      NextCode := GetNextCode('', True);
      ZeroLevel := True;
    end else begin
      FGetChildren(Self, Key, CurrDataSet);
      NextCode := GetNextCode(FTree.FieldByName(NAME_GROUPFIELD).AsString, True);
    end;
  end;

  CurrDataSet.DisableControls;

  if not Assigned(FGetChildren) then
    // Устанавливаем фильтр
    CurrDataSet.Filtered := True;

  // Сохраняем информацию о наличии детей у ветки
  IsChildren := (CurrDataSet.RecordCount > 0) or (FTree.RecordCount = 0);

  BM := FTree.GetBookMark;
  CurrDataSet.First;

  ShouldOpen := TList.Create;
  ShouldCheck := TList.Create;

  try
    // Считываем данные
    while not CurrDataSet.Eof do
    begin
      NeedToGoto := True;
      FTree.Append;

      // Добавляем реальные данные из таблицы
      for I := 0 to CurrDataSet.FieldCount - 1 do
        FTree.FieldByName(CurrDataSet.Fields[I].FieldName).Assign(CurrDataSet.Fields[I]);

      FTree.FieldByName(NAME_GROUPFIELD).AsString := NextCode;
      FTree.Post;

      ShouldCheck.Add(Pointer(CurrDataSet.FieldByName(FFieldKey).AsInteger));

      NextCode := GetNextCode(NextCode, False);

      if FindOpened(FTree.FieldByName(FFieldKey).AsInteger, I) then
        ShouldOpen.Add(FOpened[I]);

      CurrDataSet.Next;
    end;

    // Отключаем фильтр
    if not Assigned(FGetChildren) then
      CurrDataSet.Filtered := False;

    CurrDataSet.EnableControls;

    // Производим поиск необходимого места в реальной таблице по ключу открываемой ветки
    if
      (Assigned(FDetailDataSource) and (FDetailDataSource.State <> dsInactive))
        or
      Assigned(FGetDetails)
    then

      // Считываем данные из зависимой таблицы
      if
        (
          not Assigned(FGetParent)
            and
          (
            not ParentNULL and CurrDataSet.Locate(FFieldKey, Key, []))
              or
            (ParentNULL and CurrDataSet.Locate(FFieldKey, Key, [])
          )
        )
          or
        (
          Assigned(FGetParent)
            and
          FGetParent(Self, Key, Parent)
        )
      then begin
        if Assigned(FGetDetails) then
          FGetDetails(Self, Key, CurrDetails)
        else
          CurrDetails := DetailDataSet;

        CurrDetails.First;

        // Сохраняем информацию о наличии детей у ветки
        if not IsChildren then
          IsChildren := CurrDetails.RecordCount > 0;

        while not CurrDetails.EOF do
        begin
          NeedToGoto := True;
          FTree.Append;

          // Добавляем реальные данные из таблицы
          for I := 0 to FTree.FieldCount - 1 do
            for K := 0 to CurrDetails.FieldCount - 1 do
            begin
              // Если названия полей совпадают, то копируем их
              if AnsiCompareText(CurrDetails.Fields[K].FieldName,
                FTree.Fields[I].FieldName) = 0
              then
                FTree.Fields[I].Assign(CurrDetails.Fields[K]);
            end;

          FTree.FieldByName(NAME_GROUPFIELD).AsString := NextCode;
          FTree.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(0, 2);
          FTree.Post;

          NextCode := GetNextCode(NextCode, False);

          CurrDetails.Next;
        end;
      end;

    for I := 0 to ShouldOpen.Count - 1 do
      if FTree.Locate(FFieldKey, Integer(ShouldOpen[I]), []) then OpenCurrLevel;

    for I := 0 to ShouldCheck.Count - 1 do
      if FTree.Locate(FFieldKey, Integer(ShouldCheck[I]), []) then
        HasChildren;

    // Возвращаемся на заглавие ветки
    if NeedToGoto then
      FTree.GotoBookmark(BM);

    if (BM <> nil) and FTree.BookmarkValid(BM) then FTree.FreeBookmark(BM);

    if Length(NextCode) div SymbolsPerLevel > 1 then
    begin
      FTree.Edit;
      FTree.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(Word(IsChildren), Word(IsChildren));
      FTree.Post;
    end;

    FTree.EnableControls;

    if IsChildren and not FindOpened(Key, I) then
      FOpened.Add(Pointer(Key));

    if ZeroLevel then FTree.First;
  finally
    ShouldOpen.Free;
    ShouldCheck.Free;
  end;
end;

{
  Закрывает текущий уровень.
}

procedure TmmDBGridTree.CloseCurrLevel;
var
  BM: TBookmark;
  OldKey: String;
  IsChildren: Boolean;
  I: Integer;
  Blocked: Boolean;
begin
  // Проверка на случай неудачного уничтожения.
  while FTree.ControlsDisabled do FTree.EnableControls;

  Blocked := False;
  IsChildren := False;
  FTree.DisableControls;

  // Сохраняем старое положение в базе
  BM := FTree.GetBookMark;
  OldKey := FTree.FieldByName(NAME_GROUPFIELD).AsString;

  if not BlockDelete then
  begin
    BlockDelete := True;
    if FindOpened(FTree.FieldByName(FFieldKey).AsInteger, I) then
      FOpened.Delete(I);
    Blocked := True;
  end;

  FTree.Next;

  // Закрываем всех детей
  while not FTree.EOF do
  begin
    if Length(OldKey) < Length(FTree.FieldByName(NAME_GROUPFIELD).AsString) then
    begin
      IsChildren := True;

      // Если ребенок октрыт также, то закрываем и его
      if IsOpened then CloseCurrLevel;
      FTree.Delete;
    end else
      Break;
  end;

  FTree.GotoBookmark(BM);
  if BM <> nil then FTree.FreeBookmark(BM);

  FTree.Edit;
  FTree.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(Word(IsChildren), 0);
  FTree.Post;

  FTree.EnableControls;

  if Blocked then
    BlockDelete := False;
end;

{
  Производит поиск на наличие ключа открытой ветки.
}

function TmmDBGridTree.FindOpened(Key: Integer; var Index: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  Index := -1;

  for I := 0 to FOpened.Count - 1 do
    if Integer(FOpened[I]) = Key then
    begin
      Index := I;
      Result := True;
      Break;
    end;
end;

{
  Рисует плюс.
}

procedure TmmDBGridTree.DrawMinus(X, Y: Integer);
var
  OldBrushColor, OldPenColor: TColor;
begin
  with Canvas do
  begin
    OldBrushColor := Brush.Color;
    OldPenColor := Pen.Color;

    Pen.Style := psSolid;
    Pen.Color := clGray;
    Brush.Color := clGray;
    FrameRect(Rect(X, Y, X + 9, Y + 9));

    Pen.Color := clBlack;
    MoveTo(X + 2, Y + 4);
    LineTo(X + 7, Y + 4);

    Brush.Color := OldBrushColor;
    Pen.Color := OldPenColor;
  end;
end;

{
  Рисует минус
}

procedure TmmDBGridTree.DrawPlus(X, Y: Integer; Assured: Boolean);
var
  OldBrushColor, OldPenColor: TColor;
begin
  with Canvas do
  begin
    OldBrushColor := Brush.Color;
    OldPenColor := Pen.Color;

    // Если мы уверены, что дети существуют
    if Assured then
    begin
      Pen.Color := clGray;
      Brush.Color := clGray;

      FrameRect(Rect(X, Y, X + 9, Y + 9));

      Pen.Color := clBlack;
      MoveTo(X + 2, Y + 4);
      LineTo(X + 7, Y + 4);

      MoveTo(X + 4, Y + 2);
      LineTo(X + 4, Y + 7);
    end else begin // Если же нет
      // Квадратик
      Pixels[X, Y] := clBlack;
      Pixels[X + 2, Y] := clBlack;
      Pixels[X + 4, Y] := clBlack;
      Pixels[X + 6, Y] := clBlack;
      Pixels[X + 8, Y] := clBlack;

      Pixels[X, Y + 2] := clBlack;
      Pixels[X, Y + 4] := clBlack;
      Pixels[X, Y + 6] := clBlack;
      Pixels[X, Y + 8] := clBlack;

      Pixels[X + 8, Y + 2] := clBlack;
      Pixels[X + 8, Y + 4] := clBlack;
      Pixels[X + 8, Y + 6] := clBlack;
      Pixels[X + 8, Y + 8] := clBlack;

      Pixels[X + 2, Y + 8] := clBlack;
      Pixels[X + 4, Y + 8] := clBlack;
      Pixels[X + 6, Y + 8] := clBlack;
      Pixels[X + 8, Y + 8] := clBlack;

      // Крестик
      Pixels[X + 2, Y + 4] := clBlack;
      Pixels[X + 4, Y + 4] := clBlack;
      Pixels[X + 6, Y + 4] := clBlack;

      Pixels[X + 4, Y + 2] := clBlack;
      Pixels[X + 4, Y + 4] := clBlack;
      Pixels[X + 4, Y + 6] := clBlack;

      Pixels[X + 4, Y + 6] := clBlack;

    end;

    Brush.Color := OldBrushColor;
    Pen.Color := OldPenColor;
  end;
end;

{
  Возвращает источник данных.
}

function TmmDBGridTree.GetDataSource: TDataSource;
begin
  // В Design режиме работаем, как с простым Grid-ом
  if csDesigning in ComponentState then
    Result := inherited DataSource
  else // Во время работы возвращаем источник с реальными данными, а не свой источник
    Result := FRealDataSource;
end;

{
  По выходу из данного контрола производим остановку нити!
}

procedure TmmDBGridTree.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
end;

{
  Производит задержку.
}

procedure TmmDBGridTree.ProcessDelay;
const
  Pause = 1000;
var
  OldTime: LongWord;
begin
  OldTime := GetTickCount;
  PressProcessing := True;

  while GetTickCount - OldTime <= Pause do
  begin
    Application.ProcessMessages;

    // Если введен символ, то все начинаем сначала
    if ReStartProcessing then
    begin
      OldTime := GetTickCount;
      ReStartProcessing := False;
    end;
  end;

  SearchKey := '';
  ReStartProcessing := False;
  PressProcessing := False;
end;

{
  Производит поиск по ключу поиска
}

procedure TmmDBGridTree.Find;
var
  BM: TBookMark;
begin
  FTree.DisableControls;

  try
    BM := FTree.GetBookMark;

    if not FTree.Locate(FFieldTree, SearchKey, [loCaseInsensitive, loPartialKey]) then
    begin
      SearchKey := '';
      FTree.GotoBookMark(BM);
      MessageBeep(0);
    end;

    if BM <> nil then FTree.FreeBookMark(BM);
  finally
    FTree.EnableControls;
  end;
end;

{
  Таблица реальных данных.
}

function TmmDBGridTree.GetRealDataSet: TDataSet;
begin
  if FRealDataSource <> nil then
    Result := FRealDataSource.DataSet
  else
    Result := nil;
end;

{
  Таблица данных, зависимых от данных дерева.
}

function TmmDBGridTree.GetDetailDataSet: TDataSet;
begin
  if FDetailDataSource <> nil then
    Result := FDetailDataSource.DataSet
  else
    Result := nil;
end;

{
  Является ли пользовательским дерево (через события).
}

function TmmDBGridTree.GetIsCustomTree: Boolean;
begin
  Result := Assigned(FGetChildren);
end;

{
  По прокрутке данных производим свои дейтсвия
}

procedure TmmDBGridTree.DoOnTreeAfterScroll(DataSet: TDataSet);
begin
  // Нельзя допустить рекурсии из-за detail данных
  if
    not IsDetail
      and
    FDataAfterScroll
      and
    not Assigned(FGetParent)
  then
    RealDataSet.Locate(FFieldKey, FTree.FieldByName(FFieldKey).AsInteger, []);
end;

{
  Устанавливает новый источник данных.
}

procedure TmmDBGridTree.SetDataSource(const Value: TDataSource);
begin
  // В Design режиме работаем как с простым Grid-ом.
  if csDesigning in ComponentState then
    inherited DataSource := Value
  else begin
    // Во время работы программы реальный источник данных сохраняем, но
    // подставляем свой источник

    // Возвращаем старый Event
    if Assigned(FRealDataSource) then
      FRealDataSource.OnStateChange := OldRealStateChange;

    FRealDataSource := Value;

    // Сохраняем старый Event, подставляем свой
    if FRealDataSource <> nil then
    begin
      OldRealStateChange := FRealDataSource.OnStateChange;
      FRealDataSource.OnStateChange := DoOnRealStateChange;
    end;

    // Подставляем свой источник данных
    inherited DataSource := FTreeDataSource;
  end;
end;

{
  Устанавливаем поле на себя.
}

procedure TmmDBGridTree.SetFieldKey(const Value: String);
begin
  if Value <> FFieldKey then
  begin
    FFieldKey := Value;
    if not (csDesigning in ComponentState) then CreateTreeTable;
  end;
end;

{
  Устанавливаем поле на родимтеля.
}

procedure TmmDBGridTree.SetFieldParent(const Value: String);
begin
  if Value <> FFieldParent then
  begin
    FFieldParent := Value;
    if not (csDesigning in ComponentState) then CreateTreeTable;
  end;  
end;

{
  Устанавливаем поле на дерево.
}

procedure TmmDBGridTree.SetFieldTree(const Value: String);
begin
  if Value <> FFieldTree then
  begin
    FFieldTree := Value;
    if not (csDesigning in ComponentState) then Invalidate;
  end;
end;

{
  Устанавливает отступ слева для каждой ветки дерева.
}

procedure TmmDBGridTree.SetIndent(const Value: Integer);
begin
  if Value <> FIndent then
  begin
    FIndent := Value;
    if FIndent < 0 then FIndent := 0;
    Invalidate;
  end;
end;

{
  Устанавливат зависимую таблицу от таблицы дерева!
}

procedure TmmDBGridTree.SetDetailDataSource(const Value: TDataSource);
begin
  if Value <> FDetailDataSource then FDetailDataSource := Value;
end;

{
  Устанавливает список рисунков.
}

procedure TmmDBGridTree.SetImages(const Value: TImageList);
begin
  if FImages <> Value then
  begin
    FImages := Value;
    if not (csdesigning in ComponentState) then Invalidate;
  end;
end;

{
  Устанавливает индекс рисунка группы.
}

procedure TmmDBGridTree.SetIndexGroup(const Value: Integer);
begin
  if FIndexGroup <> Value then
  begin
    FIndexGroup := Value;
    if not (csdesigning in ComponentState) then Invalidate;
  end;
end;

{
  Устанавливает индекс рисунка открытой группы.
}

procedure TmmDBGridTree.SetIndexGroupOpen(const Value: Integer);
begin
  if FIndexGroupOpen <> Value then
  begin
    FIndexGroupOpen := Value;
    if not (csdesigning in ComponentState) then Invalidate;
  end;
end;

{
  Устаналивает индекс рисунка неопределенного состояния (запись/группа).
}

procedure TmmDBGridTree.SetIndexIndeterminate(const Value: Integer);
begin
  if FIndexIndeterminate <> Value then
  begin
    FIndexIndeterminate := Value;
    if not (csdesigning in ComponentState) then Invalidate;
  end;
end;

{
  Устаналивает индекс рисунка обычной записи.
}

procedure TmmDBGridTree.SetIndexSimple(const Value: Integer);
begin
  if FIndexSimple <> Value then
  begin
    FIndexSimple := Value;
    if not (csdesigning in ComponentState) then Invalidate;
  end;
end;

{
  Устаналивает индекс рисунка зависимой записи.
}

procedure TmmDBGridTree.SetIndexDetail(const Value: Integer);
begin
  if FIndexDetail <> Value then
  begin
    FIndexDetail := Value;
    if not (csdesigning in ComponentState) then Invalidate;
  end;
end;

end.

