
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBGridTreeEx.pas

  Abstract

    Improved DBGrid: Tree inside DBGrid. With store procedures.

  Author

    Romanovski Denis (22-03-99)

  Revisions history

    Initial  22-03-99  Dennis  Initial version.

    Beta1    31-03-99  Dennis  Everything works.

    Beta2    01-04-99  Dennis  Buggs.

    Beta3    05-04-99  Dennis  Buggs. Don't ever try to use "owner" in
                               Create(AnOwner: TComponent) inside of
                               the class.

    Beta4    21-04-99  Dennis  Buggs. Don't know what to do with prepare and unprepare! Bug's still
                               active from time to time!
                               
    Beta5    26-04-99  Dennis  Buggs. FastTerminatethread put at several more places in code.
    
--}

{
  Для нормальной работы компоненты необходимы следующие store-процедуры:
  * ChildListProcName - процедура, возвращает список детей. Параметром служит
    какой-либо родитель (INTEGER).
  * DetailListProcName - процедура, возвращает список "деталей". Параметром служит
    какой-либо ключ (INTEGER).
  * ChildProcName - возвращает логическое значение (0 или 1), что означает - данный родитель
    имеет список детей. Параметр (INTEGER) - родитель.
  * ParentProcName - возвращает ключ родителя по ключу ребенка. Параметр INTEGER.
  * DetailProcName - возвращает логическое значение (0 или 1), что означает - данный элемент
    имеет список "деталей". Параметр (INTEGER) - ключ элемент.

}

unit mmDBGridTreeEx;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, DBGrids, DBClient, DB, DBTables, mmDBGrid, DBCtrls, ExtCtrls;

// Установки для таблицы-дерева по умолчанию.
const
  DefIndent = 10;
  DefIndexGroup = -1;
  DefIndexGroupOpen = -1;
  DefIndexIndeterminate = -1;
  DefIndexSimple = -1;
  DefIndexDetail = -1;

const
  CHECK_SIMPLE = $1;
  CHECK_DETAIL = $2;

type
  TmmDBGridTreeEx = class(TmmDBGrid)
  private
    FTree: TClientDataSet; // Таблица данных дерева
    FTreeDataSource: TDataSource; // Источник данных дерева

    FFieldKey, FFieldParent, FFieldTree: String; // Поля собственное, родителя, дерева

    FIndent: Integer; // Отступ слева для каждой ветки

    FImages: TImageList; // Список рисунков для отображения в дереве.

    FIndexGroup: Integer; // Закрытая группа
    FIndexGroupOpen: Integer; // Открытая группа
    FIndexIndeterminate: Integer; // Не определено есть дети или нет
    FIndexSimple: Integer; // Нет детей
    FIndexDetail: Integer; // Зависимая запись

    DrawBMP: TBitmap; // BITMAP для рисования в ячейках

    PressProcessing: Boolean; // Происходит ввод символов поиска
    ReStartProcessing: Boolean; // Флаг перехода к начальной задержке
    SearchKey: String; // Ключ поиска по полю

    CurrThread: TThread; // Нить параллельного процесса
    CanRunThread: Boolean; // Можно ли запускать нити

    FOpened: TList; // Список открытых эелеметов

    FDataBaseName: String; // Наименование базы данных

    FChildList, FDetailList: TQuery; // Запросы
    FChildProc, FParentProc, FDetailProc, FKeyByDetailProc: TStoredProc; // Процедуры

    FChildListProcName, FDetailListProcName, FKeyByDetailProcName: String; // Наименование Store-процедур
    FChildProcName, FParentProcName, FDetailProcName: String; // Наименования Store-процедур

    FAfterOpen: TNotifyEvent; // Событие по открытию таблицы

    procedure DoOnTerminateThread(Sender: TObject);

    procedure MakeChildList(AKey: Integer; const IsNull: Boolean = False);
    procedure MakeDetailList(AKey: Integer);

    function HasChildProc(AKey: Integer): Boolean;
    function HasDetailProc(AKey: Integer): Boolean;
    function GetParent(AKey: Integer; var Parent: Integer): Boolean;
    function GetParentByDetail(AKey: Integer; var Parent: Integer): Boolean;

    function WorkWithDetails: Boolean;

    procedure PrepeareDataBase;
    procedure CreateTreeTable;

    procedure OpenCurrLevel;
    procedure CloseCurrLevel;

    function FindOpened(Key: Integer; var Index: Integer): Boolean;

    function IsOpened: Boolean;
    function HasChildren: Boolean;

    procedure DrawMinus(X, Y: Integer);
    procedure DrawPlus(X, Y: Integer; Assured: Boolean);

    procedure ProcessDelay;
    procedure Find;
    procedure FastTerminateThread;

    procedure WMKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;

    function GetDataSource: TDataSource;

    procedure SetDataSource(const Value: TDataSource);
    procedure SetFieldKey(const Value: String);
    procedure SetFieldParent(const Value: String);
    procedure SetFieldTree(const Value: String);
    procedure SetIndent(const Value: Integer);
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

    function GetTreeMoveBy(WhileDrawing: Boolean; CheckField: Boolean; F: TField): Integer; override;

    procedure DoOnAddCheck(C: TCheckField; S: String); override;
    procedure DoOnDeleteCheck(C: TCheckField; Index: Integer); override;
    function DoOnFindCheck(C: TCheckField; ACheck: String; var Index: Integer): Boolean; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function OpenKey(Key: Integer; const IsDetail: Boolean = False;
      const OpenLast: Boolean = False): Boolean;
    function CloseKey(Key: Integer): Boolean;
    function IsThreaded: Boolean;
    function IsDetail: Boolean;

    procedure Refresh;

    procedure Open;
    procedure Close;

    // Таблица дерева
    property Tree: TClientDataSet read FTree;

  published
    // Источник данных
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    // Поле на себя
    property FieldKey: String read FFieldKey write SetFieldKey;
    // Поле на родителя
    property FieldParent: String read FFieldParent write SetFieldParent;
    // Поле, где будет отображаться дерево
    property FieldTree: String read FFieldTree write SetFieldTree;
    // Оступ слева для каждой ветки дерева
    property Indent: Integer read FIndent write SetIndent default DefIndent;
    // Список рисунков для отображения в дереве.
    property Images: TImageList read FImages write SetImages;
    // Закрытая группа
    property IndexGroup: Integer read FIndexGroup write SetIndexGroup default DefIndexGroup;
    // Открытая группа
    property IndexGroupOpen: Integer read FIndexGroupOpen write SetIndexGroupOpen default DefIndexGroupOpen;
    // Не определено есть дети или нет
    property IndexIndeterminate: Integer read FIndexIndeterminate write SetIndexIndeterminate default DefIndexIndeterminate;
    // Элемент без детей
    property IndexSimple: Integer read FIndexSimple write SetIndexSimple default DefIndexSimple;
    // Зависимый элемент
    property IndexDetail: Integer read FIndexDetail write SetIndexDetail default DefIndexDetail;
    // Наменование базы данных
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    // Наименование store-процедуры списка детей
    property ChildListProcName: String read FChildListProcName write FChildListProcName;
    // Наименование store-процедуры списка "деталей"
    property DetailListProcName: String read FDetailListProcName write FDetailListProcName;
    // Наименование store-процедуры существования детей
    property ChildProcName: String read FChildProcName write FChildProcName;
    // Наименование store-процедуры parent по key
    property ParentProcName: String read FParentProcName write FParentProcName;
    // Возвращает ключ в таблице по ключу деталей
    property KeyByDetailProcName: String read FKeyByDetailProcName write FKeyByDetailProcName;
    // Наименование store-процедуры существования деталей
    property DetailProcName: String read FDetailProcName write FDetailProcName;
    // Событие по открытию таблицы
    property AfterOpen: TNotifyEvent read FAfterOpen write FAfterOpen;

  end;

// Внутренние поля
const
  NAME_BRANCHFIELD = 'TREE_BRANCH';
  NAME_GROUPFIELD = 'TREE_GROUP';

  // Кол-во символов на одном уровне
  SymbolsPerLevel = 3;

implementation

uses mmDBGridTreeThdsEx;

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
    TAutoIncField,      { ftAutoInc }
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
          raise Exception.Create('Нарушен лимит записей одного уровня!');
        end;
      end;
    end;

    Code := Copy(Code, 0, Length(Code) - 3) + C1 + C2 + C3;
  end;

  Result := Code;
end;

{
  ---------------------------------
  ---   TmmDBGridTreeEx Class   ---
  ---------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TmmDBGridTreeEx.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FTree := nil;
  FDatabaseName := 'xxx';

  FChildList := nil;
  FDetailList := nil;

  FChildProc := nil;
  FParentProc := nil;
  FDetailProc := nil;
  FKeyByDetailProc := nil;

  FChildListProcName := '';
  FDetailListProcName := '';

  FChildProcName := '';
  FParentProcName := '';
  FDetailProcName := '';
  FKeyByDetailProcName := '';
  FAfterOpen := nil;

  if not (csDesigning in ComponentState) then
  begin
    FChildList := TQuery.Create(Self);
    FDetailList := TQuery.Create(Self);
    FChildProc := TStoredProc.Create(Self);
    FParentProc := TStoredProc.Create(Self);
    FDetailProc := TStoredProc.Create(Self);
    FKeyByDetailProc := TStoredProc.Create(Self);

    // Создаем таблицу для формирования дерева
    FTree := TClientDataSet.Create(Self);

    FTreeDataSource := TDataSource.Create(Self);
    FTreeDataSource.DataSet := FTree;
  end;

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

  // Создаем BITMAP для рисования в ячейках
  DrawBMP := TBitmap.Create;

  PressProcessing := False;
  ReStartProcessing := False;

  CurrThread := nil;
  CanRunThread := True; 

  FOpened := TList.Create;
  BlockDelete := False;
end;

{
  Высвобождаем память.
}

destructor TmmDBGridTreeEx.Destroy;
begin
  FastTerminateThread;
  
  if (FChildProc <> nil) and (FChildProc.Prepared) then FChildProc.UnPrepare;
  if (FParentProc <> nil) and (FParentProc.Prepared) then FParentProc.UnPrepare;
  if (FDetailProc <> nil) and (FDetailProc.Prepared) then FDetailProc.UnPrepare;
  if (FKeyByDetailProc <> nil) and (FKeyByDetailProc.Prepared) then FKeyByDetailProc.UnPrepare;


  FOpened.Free;
  DrawBMP.Free;

  inherited Destroy;
end;

{
  Открывает уровень по ключу.
}

function TmmDBGridTreeEx.OpenKey(Key: Integer; const IsDetail: Boolean = False;
  const OpenLast: Boolean = False): Boolean;
var
  Keys: TList;
  I: Integer;
  Parent, DetailKey: Integer;
begin
  Result := False;

  FastTerminateThread;
  FTree.DisableControls;
  Keys := TList.Create;

  if IsDetail then
  begin
    DetailKey := Key;

    if not GetParentByDetail(Key, Key) then
    begin
      Keys.Free;
      FTree.DisableControls;
      Abort;
    end;
  end else
    DetailKey := -1;

  // Находим позицию по ключу
  if not GetParent(Key, Parent) then
  begin
    if FTree.Locate(FFieldKey, Key, []) and (OpenLast or IsDetail) and not IsOpened then
    begin
      OpenCurrLevel;
      FTree.Next;

      if IsDetail then // Производим поиск детали
        while not FTree.EOF do
        begin
          if FTree.FieldByName(FieldKey).AsInteger = DetailKey then Break;
          FTree.Next;
        end;
    end;

    Keys.Free;  
    FTree.EnableControls;
    Exit;
  end;

  try
    while GetParent(Key, Parent) do
    begin
      Keys.Add(Pointer(Key));
      Key := Parent;
    end;

    FTree.Locate(FFieldKey, Key, []);

    // Открываем всех родителей по порядку
    for I := Keys.Count - 1 downto 0 do
    begin
      if not IsOpened then OpenCurrLevel;
      FTree.Locate(FFieldKey, Integer(Keys[I]), []);
    end;

    if (OpenLast or IsDetail) and not IsOpened then
      OpenCurrLevel;

    if IsDetail then // Производим поиск детали
      while not FTree.EOF do
      begin
        if FTree.FieldByName(FieldKey).AsInteger = DetailKey then Break;
        FTree.Next;
      end;

    Result := True;
  finally
    Keys.Free;
    FTree.EnableControls;
  end;
end;

{
  Закрывает ветвь дерева по ключу.
}

function TmmDBGridTreeEx.CloseKey(Key: Integer): Boolean;
begin
  Result := False;

  // Находим позицию по ключу и закрываем ветвь
  if FTree.Locate(FFieldKey, Key, []) then
  begin
    CloseCurrLevel;
    Result := True;
  end;
end;

function TmmDBGridTreeEx.IsThreaded: Boolean;
begin
  Result := CurrThread <> nil;
end;

{
  Является ли данная запись "детальной".
}

function TmmDBGridTreeEx.IsDetail: Boolean;
begin
  if DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).IsNull then
    Result := False
  else
    Result := HiWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger) = 2;
end;

{
  Обновляет дерево.
}

procedure TmmDBGridTreeEx.Refresh;
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
      
    FastTerminateThread;
    FTree.DisableControls;

    CanRunThread := False;

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
    begin
      OpenKey(Integer(Keys[I]), False, True);
    end;

    // Восстаенавливаем положение, установленное ранее.
    FTree.Locate(FFieldKey, Key, []);
    if OldField <> '' then SelectedField := DataLink.DataSet.FindField(OldField);

    // Запускаем нить
    CanRunThread := True;

    if CurrThread = nil then
    begin
      if WorkWithDetails then
        CurrThread := TmmDBGridTreeThdEx.Create(FTree, FChildProc, FDetailProc, FFieldKey,
          FFieldParent, Self)
      else
        CurrThread := TmmDBGridTreeThdEx.Create(FTree, FChildProc, nil, FFieldKey,
          FFieldParent, Self);

      CurrThread.OnTerminate := DoOnTerminateThread;
    end;
  finally
    CanRunThread := True;
    FTree.EnableControls;
    Keys.Free;
  end;
end;

{
  Открывает дерево.
}

procedure TmmDBGridTreeEx.Open;
begin
  CreateTreeTable;
  if Assigned(FAfterOpen) then FAfterOpen(Self);
end;

{
  Закрывает дерево.
}

procedure TmmDBGridTreeEx.Close;
begin
  FastTerminateThread;
  FTree.Close;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Двойной щелчек в таблице.
}

procedure TmmDBGridTreeEx.DblClick;
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
    Options := Options - [dgEditing];

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

procedure TmmDBGridTreeEx.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  R, R2: TRect;
  C: TGridCoord;
  Level: Integer;
begin
  if (Button = mbRight) then FastTerminateThread;

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

procedure TmmDBGridTreeEx.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
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

      // Определяем индекс рисунка 
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

procedure TmmDBGridTreeEx.Notification(AComponent: TComponent; Operation: Toperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
    if (AComponent = FImages) then Images := nil;
end;

{
  отлавливаем нажатие клавиши ввод
}

procedure TmmDBGridTreeEx.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

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

procedure TmmDBGridTreeEx.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);

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

procedure TmmDBGridTreeEx.Loaded;
begin
  inherited Loaded;
  
  if not (csDesigning in ComponentState) then
  begin
    Options := Options - [dgEditing];
    PrepeareDatabase;
    inherited DataSource := FTreeDataSource;
  end;
end;

{
  Устанавливает отступ слева для дерева.
}

function TmmDBGridTreeEx.GetTreeMoveBy(WhileDrawing: Boolean; CheckField: Boolean; F: TField): Integer;
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
  Добавляем элемент.
}

procedure TmmDBGridTreeEx.DoOnAddCheck(C: TCheckField; S: String);
var
  I: Integer;
begin
  I := C.Checks.IndexOf(S);

  if I >= 0 then
  begin
    if IsDetail then
      C.Checks.Objects[I] := Pointer(Integer(C.Checks.Objects[I]) or CHECK_DETAIL)
    else
      C.Checks.Objects[I] := Pointer(Integer(C.Checks.Objects[I]) or CHECK_SIMPLE);
  end else begin
    C.AddCheck(S);

    if IsDetail then
      C.Checks.Objects[C.Checks.Count - 1] := Pointer(CHECK_DETAIL)
    else
      C.Checks.Objects[C.Checks.Count - 1] := Pointer(CHECK_SIMPLE);
  end;
end;

{
  Удаляем элемент.
}

procedure TmmDBGridTreeEx.DoOnDeleteCheck(C: TCheckField; Index: Integer);
begin
  if IsDetail then
  begin
    if (Integer(C.Checks.Objects[Index]) and CHECK_DETAIL) <> 0 then
      C.Checks.Objects[Index] := Pointer(Integer(C.Checks.Objects[Index]) and not CHECK_DETAIL);

    if Integer(C.Checks.Objects[Index]) <> CHECK_SIMPLE then
      C.Checks.Delete(Index);
  end else begin
    if (Integer(C.Checks.Objects[Index]) and CHECK_SIMPLE) <> 0 then
      C.Checks.Objects[Index] := Pointer(Integer(C.Checks.Objects[Index]) and not CHECK_SIMPLE);

    if Integer(C.Checks.Objects[Index]) <> CHECK_DETAIL then
      C.Checks.Delete(Index);
  end;
end;
                                    // (List.Objects[I] and CHECK_SIMPLE) <> 0
                                    // (List.Objects[I] and CHECK_DETAIL) <> 0
{
  Производим поиск элемента.
}

function TmmDBGridTreeEx.DoOnFindCheck(C: TCheckField; ACheck: String; var Index: Integer): Boolean;
begin
  Result := C.FindCheck(ACheck, Index);

  if Result then
  begin
    if IsDetail and ((Integer(C.Checks.Objects[Index]) and CHECK_DETAIL) = 0) then
      Result := False;

    if not IsDetail and ((Integer(C.Checks.Objects[Index]) and CHECK_SIMPLE) = 0) then
      Result := False;
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  По окончанию нити производим отключение соответствующего флага.
}

procedure TmmDBGridTreeEx.DoOnTerminateThread(Sender: TObject);
begin
  CurrThread := nil;
end;

{
  Вызывает store-процедуру списка детей.
}

procedure TmmDBGridTreeEx.MakeChildList(AKey: Integer; const IsNull: Boolean = False);
begin
  FChildList.Close;

  FChildList.SQL.Clear;
  FChildList.SQL.Add('SELECT * FROM '+ FChildListProcName + '(:Parent)');
  FChildList.ParamByName('Parent').DataType := ftInteger;

  if not IsNull then FChildList.ParamByName('Parent').AsInteger := AKey;

  FChildList.Open;
end;

{
  Вызывает store-процедуру списка "деталей".
}


{ Деник попробуй также как и со списком детей
  }
procedure TmmDBGridTreeEx.MakeDetailList(AKey: Integer);
begin
  FDetailList.Close;
  FDetailList.SQL.Text := 'SELECT * FROM ' + FDetailListProcName + Format('(%d)', [AKey]);
  FDetailList.Open;
end;

{
  Вызывает store-процедуру списка детей.
}

function TmmDBGridTreeEx.HasChildProc(AKey: Integer): Boolean;
begin
  FChildProc.StoredProcName := FChildProcName;
  if FChildProc.Prepared then FChildProc.UnPrepare;
  if not FChildProc.Prepared then FChildProc.Prepare;
  FChildProc.Params[0].AsInteger := AKey;
  FChildProc.ExecProc;
  Result := FChildProc.Params[1].AsBoolean;
end;

{
  Вызывает store-процедуру списка "деталей".
}

function TmmDBGridTreeEx.HasDetailProc(AKey: Integer): Boolean;
begin
  FDetailProc.StoredProcName := FDetailProcName;
  if FDetailProc.Prepared then FDetailProc.UnPrepare;
  if not FDetailProc.Prepared then FDetailProc.Prepare;
  FDetailProc.Params[0].AsInteger := AKey;
  FDetailProc.ExecProc;
  Result := FDetailProc.Params[1].AsBoolean;
end;

{
  Возвращает Parent по Key.
}

function TmmDBGridTreeEx.GetParent(AKey: Integer; var Parent: Integer): Boolean;
begin
  FParentProc.StoredProcName := FParentProcName;
//  if not FParentProc.Prepared then FParentProc.Prepare;
  if FParentProc.Prepared then FParentProc.UnPrepare;
  FParentProc.Prepare;
  FParentProc.Params[0].AsInteger := AKey;
  FParentProc.ExecProc;
  Parent := FParentProc.Params[1].AsInteger;
  Result := not FParentProc.Params[1].IsNull;
end;

{
  Возвращает ключ по ключу "деталей".
}

function TmmDBGridTreeEx.GetParentByDetail(AKey: Integer; var Parent: Integer): Boolean;
begin
  FKeyByDetailProc.StoredProcName := FKeyByDetailProcName;
  if FKeyByDetailProc.Prepared then FKeyByDetailProc.UnPrepare;
  FKeyByDetailProc.Prepare;
  FKeyByDetailProc.Params[0].AsInteger := AKey;
  FKeyByDetailProc.ExecProc;
  Parent := FKeyByDetailProc.Params[1].AsInteger;
  Result := not FKeyByDetailProc.Params[1].IsNull;
end;

{
  работаем с "деталями или нет"
}

function TmmDBGridTreeEx.WorkWithDetails: Boolean;
begin
  Result := FDetailProcName <> '';
end;

{
  Подготавливает базу данных.
}

procedure TmmDBGridTreeEx.PrepeareDataBase;
begin
  FChildList.DatabaseName := FDatabaseName;
  FDetailList.DatabaseName := FDatabaseName;

  FChildProc.DatabaseName := FDatabaseName;
  FChildProc.StoredProcName := FChildProcName;

  FParentProc.DatabaseName := FDatabaseName;
  FParentProc.StoredProcName := FParentProcName;

  FDetailProc.DatabaseName := FDatabaseName;
  FDetailProc.StoredProcName := FDetailProcName;

  FKeyByDetailProc.DatabaseName := FDatabaseName;
  FKeyByDetailProc.StoredProcName := FDetailProcName;
end;

{
  Создаем таблицу по образцу и подобию таблицы с реальными данными.
  Добавляем отдельное поле уровня дерева!
}

procedure TmmDBGridTreeEx.CreateTreeTable;
var
  I: Integer;
  F: TField;
  IndDef: TIndexDef;
begin
  // Высвобождаем дерево от ранее использованных данных.
  FTree.Close;
  FTree.Fields.Clear;

  // Освобождаем список
  FOpened.Clear;

  // Открываем первый уровень
  MakeChildList(0, True);

  // Производим копирование полей из таблицы с реальными данными
  for I := 0 to FChildList.FieldCount - 1 do
  begin
    F := TreeDefaultFieldClasses[FChildList.Fields[I].DataType].Create(Self);

    F.FieldName := FChildList.Fields[I].FieldName;
    F.FieldKind := FChildList.Fields[I].FieldKind;
    F.Visible := FChildList.Fields[I].Visible;
    F.Size := FChildList.Fields[I].Size;
    F.DisplayWidth := FChildList.Fields[I].DisplayWidth;
    F.DisplayLabel := FChildList.Fields[I].DisplayLabel;
    F.EditMask := FChildList.Fields[I].EditMask;
    F.Alignment := FChildList.Fields[I].Alignment;

    F.DataSet := FTree;
  end;

  if WorkWithDetails then
    // Производим копирование полей из таблицы с реальными данными
    for I := 0 to FDetailList.FieldCount - 1 do
    begin
      // Нельзя добавлять поля с одинаковыми названиями
      if FTree.FindField(FDetailList.Fields[I].FieldName) <> nil then Continue;

      F := TreeDefaultFieldClasses[FDetailList.Fields[I].DataType].Create(Self);

      F.FieldName := FDetailList.Fields[I].FieldName;
      F.FieldKind := FDetailList.Fields[I].FieldKind;
      F.Visible := FDetailList.Fields[I].Visible;
      F.Size := FDetailList.Fields[I].Size;
      F.DisplayWidth := FDetailList.Fields[I].DisplayWidth;
      F.DisplayLabel := FDetailList.Fields[I].DisplayLabel;
      F.EditMask := FDetailList.Fields[I].EditMask;
      F.Alignment := FDetailList.Fields[I].Alignment;

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

  // Создаем таблицу в памяти
  FTree.EnableControls;
  FTree.CreateDataSet;

  // Открываем самый первый уровень
  OpenCurrLevel;
end;

{
  Открывает новый уровень в дереве.
}

procedure TmmDBGridTreeEx.OpenCurrLevel;
var
  Key: Integer;
  I, K: Integer;
  BM: TBookMark;
  NextCode: String;
  IsChildren: Boolean;
  NeedToGoto: Boolean;
  ShouldOpen: TList;
  ZeroLevel: Boolean;
begin
  FastTerminateThread;

  // Проверка на случай неудачного уничтожения.
  while FTree.ControlsDisabled do FTree.EnableControls;

  FTree.DisableControls;

  NeedToGoto := False;
  ZeroLevel := False;

  // Получаем текущую ветвь
  Key := FTree.FieldByName(FFieldKey).AsInteger;

  // Нельзя допустить рекурсии из-за detail данных
  if IsDetail then
  begin
    FTree.Edit;
    FTree.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(0, 0);
    FTree.Post;

    FTree.EnableControls;
    Exit;
  end;

  if FTree.RecordCount = 0 then
  begin
    NextCode := GetNextCode('', True);
    MakeChildList(Key, True);
    ZeroLevel := True;
  end else begin
    NextCode := GetNextCode(FTree.FieldByName(NAME_GROUPFIELD).AsString, True);
    MakeChildList(Key);
  end;

  // Сохраняем информацию о наличии детей у ветки
  IsChildren := (FChildList.RecordCount > 0) or (FTree.RecordCount = 0);

  BM := FTree.GetBookMark;
  FChildList.First;

  ShouldOpen := TList.Create;

  try
    // Считываем данные
    while not FChildList.Eof do
    begin
      NeedToGoto := True;
      FTree.Append;

      // Добавляем реальные данные из таблицы
      for I := 0 to FChildList.FieldCount - 1 do
        FTree.FieldByName(FChildList.Fields[I].FieldName).Assign(FChildList.Fields[I]);

      FTree.FieldByName(NAME_GROUPFIELD).AsString := NextCode;
      FTree.Post;
      NextCode := GetNextCode(NextCode, False);

      if FindOpened(FTree.FieldByName(FFieldKey).AsInteger, I) then
        ShouldOpen.Add(FOpened[I]);

      FChildList.Next;
    end;

    // Производим поиск необходимого места в реальной таблице по ключу открываемой ветки
    // Считываем данные из зависимой таблицы
    if WorkWithDetails and HasDetailProc(Key) then
    begin
      MakeDetailList(Key);
      FDetailList.First;

      // Сохраняем информацию о наличии детей у ветки
      if not IsChildren then IsChildren := FDetailList.RecordCount > 0;

      while not FDetailList.EOF do
      begin
        NeedToGoto := True;
        FTree.Append;

        // Добавляем реальные данные из таблицы
        for I := 0 to FTree.FieldCount - 1 do
          for K := 0 to FDetailList.FieldCount - 1 do
          begin
            // Если названия полей совпадают, то копируем их
            if AnsiCompareText(FDetailList.Fields[K].FieldName, FTree.Fields[I].FieldName) = 0 then
              FTree.Fields[I].Assign(FDetailList.Fields[K]);
          end;

        FTree.FieldByName(NAME_GROUPFIELD).AsString := NextCode;
        FTree.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(0, 2);
        FTree.Post;
        NextCode := GetNextCode(NextCode, False);

        FDetailList.Next;
      end;
    end;

    for I := 0 to ShouldOpen.Count - 1 do
      if FTree.Locate(FFieldKey, Integer(ShouldOpen[I]), []) then OpenCurrLevel;

    // Возвращаемся на заглавие ветки
    if NeedToGoto then FTree.GotoBookmark(BM);
    if BM <> nil then FTree.FreeBookmark(BM);

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

    if (CurrThread = nil) and CanRunThread then
    begin
      if WorkWithDetails then
        CurrThread := TmmDBGridTreeThdEx.Create(FTree, FChildProc, FDetailProc, FFieldKey,
          FFieldParent, Self)
      else
        CurrThread := TmmDBGridTreeThdEx.Create(FTree, FChildProc, nil, FFieldKey,
          FFieldParent, Self);

      CurrThread.OnTerminate := DoOnTerminateThread;
    end;
  finally
    ShouldOpen.Free;
  end;
end;

{
  Закрывает текущий уровень.
}

procedure TmmDBGridTreeEx.CloseCurrLevel;
var
  BM: TBookmark;
  OldKey: String;
  IsChildren: Boolean;
  I: Integer;
  Blocked: Boolean;
begin
  FastTerminateThread;

  Blocked := False;
  IsChildren := False;

  // Проверка на случай неудачного уничтожения.
  while FTree.ControlsDisabled do FTree.EnableControls;

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

  if Blocked then BlockDelete := False;
end;

{
  Производит поиск на наличие ключа открытой ветки.
}

function TmmDBGridTreeEx.FindOpened(Key: Integer; var Index: Integer): Boolean;
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
  Проверяет, если текущий уровень открыт.
}

function TmmDBGridTreeEx.IsOpened: Boolean;
begin
  FastTerminateThread;

  if DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).IsNull then
    Result := False
  else if HiWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger) < 2 then
    Result := Boolean(HiWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger))
  else
    Result := False;
end;

{
  Определяет наличие у данной ветки детей.
}

function TmmDBGridTreeEx.HasChildren: Boolean;
begin
  if CurrThread <> nil then CurrThread.Suspend;

  // Если данные о наличии детей не созданы, то создаем их
  if DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).IsNull then
  begin
    // Нельзя допустить рекурсии из-за detail данных
    if IsDetail then
      Result := False
    else begin
      Result := HasChildProc(DataLink.DataSet.FieldByName(FFieldKey).AsInteger);

      // Если отсутствуют данные по дереву, то смотрим зависимую таблицу
      if not Result and WorkWithDetails then
        Result := HasDetailProc(DataLink.DataSet.FieldByName(FFieldKey).Value);
    end;

    DataLink.DataSet.Edit;
    DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger := MakeLong(Word(Result), 0);
    DataLink.DataSet.Post;
  end else
    // Иначе просто считываем их
    Result := Boolean(LoWord(DataLink.DataSet.FieldByName(NAME_BRANCHFIELD).AsInteger));

  if CurrThread <> nil then CurrThread.Resume;
end;

{
  Рисует плюс.
}

procedure TmmDBGridTreeEx.DrawMinus(X, Y: Integer);
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

procedure TmmDBGridTreeEx.DrawPlus(X, Y: Integer; Assured: Boolean);
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
  По выходу из данного контрола производим остановку нити!
}

procedure TmmDBGridTreeEx.WMKillFocus(var Message: TWMKillFocus);
begin
  FastTerminateThread;
  inherited;
end;

{
  Производит задержку.
}

procedure TmmDBGridTreeEx.ProcessDelay;
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

procedure TmmDBGridTreeEx.Find;
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
  Производит быстрое уничтожение нити.
}

procedure TmmDBGridTreeEx.FastTerminateThread;
var
  W: Cardinal;
begin
  if CurrThread <> nil then
  begin
    if GetExitCodeThread(CurrThread.Handle, W) and (W = STILL_ACTIVE) then
      TerminateThread(CurrThread.Handle, W);

    CurrThread := nil;
  end;
end;

{
  Возвращает DataSource.
}

function TmmDBGridTreeEx.GetDataSource: TDataSource;
begin
  if csDesigning in ComponentState then
    Result := nil
  else
    Result := FTreeDataSource;
end;

{
  Устанавливает DataSource.
}

procedure TmmDBGridTreeEx.SetDataSource(const Value: TDataSource);
begin
  if csDesigning in ComponentState then
    inherited DataSource := nil
  else
    inherited DataSource := FTreeDataSource;
end;

{
  Устанавливаем поле на себя.
}

procedure TmmDBGridTreeEx.SetFieldKey(const Value: String);
begin
  if Value <> FFieldKey then
  begin
    FFieldKey := Value;
    if not (csDesigning in ComponentState) and FTree.Active then CreateTreeTable;
  end;
end;

{
  Устанавливаем поле на родимтеля.
}

procedure TmmDBGridTreeEx.SetFieldParent(const Value: String);
begin
  if Value <> FFieldParent then
  begin
    FFieldParent := Value;
    if not (csDesigning in ComponentState) and FTree.Active then CreateTreeTable;
  end;
end;

{
  Устанавливаем поле на дерево.
}

procedure TmmDBGridTreeEx.SetFieldTree(const Value: String);
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

procedure TmmDBGridTreeEx.SetIndent(const Value: Integer);
begin
  if Value <> FIndent then
  begin
    FIndent := Value;
    if FIndent < 0 then FIndent := 0;
    Invalidate;
  end;
end;

{
  Устанавливает список рисунков.
}

procedure TmmDBGridTreeEx.SetImages(const Value: TImageList);
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

procedure TmmDBGridTreeEx.SetIndexGroup(const Value: Integer);
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

procedure TmmDBGridTreeEx.SetIndexGroupOpen(const Value: Integer);
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

procedure TmmDBGridTreeEx.SetIndexIndeterminate(const Value: Integer);
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

procedure TmmDBGridTreeEx.SetIndexSimple(const Value: Integer);
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

procedure TmmDBGridTreeEx.SetIndexDetail(const Value: Integer);
begin
  if FIndexDetail <> Value then
  begin
    FIndexDetail := Value;
    if not (csdesigning in ComponentState) then Invalidate;
  end;
end;

end.

