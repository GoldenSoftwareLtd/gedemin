
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBGrid.pas

  Abstract

    Improved DBGrid: stripes technology, font, color, conditional formatting, e.c.
                     change options.

  Author

    Romanovski Denis (22-01-99)

  Revisions history

    Initial  22-01-99  Dennis  Initial version.

    Beta1    24-01-99  Dennis  Everything works.

    Beta2    26-01-99  Dennis  Condition formatting added.

    Beta3    28-01-99  Dennis  Some bugs fixed.

    Beta4    01-02-99  Dennis  Some progressive things added.

    Beta5    06-02-99  Dennis  Fields visible property changing option included.

    Beta6    07-02-99  Dennis  Some bugs on columns scaling fixed.

    Beta7    08-02-99  Dennis  ScaleColumns menu item included.

    Beta8    10-02-99  Dennis  Scaling code in component is complitely changed and improved.
                               Field scaling option class added.

    Beta9    11-02-99  Dennis  Some bugs on columns scaling fixed.
                               SkipColumns property deleted.

    Beta10   13-02-99  Dennis  Some bugs on columns scaling fixed.

    Beta11   15-02-99  Dennis  Some bugs fixed. Menu changed. Bitmap horrible bug fixed.

    Beta12   16-02-99  Dennis  Table options master dialog included.

    Beta13   25-02-99  Dennis  TreeMoveBy added. For Tree descendant class.

    Beta14   02-03-99  Dennis  SkipActiveRecord added. For Tree descendant class.

    Beta15   03-03-99  Dennis  FShowLines, LineCount, LineFields properties added.

    Beta16   04-03-99  Dennis  Bug on ScaleColumns fixed through LinkActive procedure.

    Beta17   05-03-99  Dennis  Runtime Visual Detail View settings added.
                               CheckBox fields supported. Drawing speed improved.
                               TreeMoveBy removed, but GetTreeMoveBy function included.

    Beta18   17-03-99  Dennis  Bugs in internal code of DBGrid.pas fixed. Columns
                               calculating problem solved!

    Beta19   17-03-99  Dennis  UltraChanges property added.

    Beta20   22-03-99  Dennis  Double Click size counting added.

    Beta21   25-03-99  Dennis  Formules in conditional formatting supported!

    Beta22   31-03-99  Dennis  Filters supported.

    Beta23   19-04-99  Dennis  Search component added. search on all the levels avalaible
                               (except TmmDBGridTreeEx). Deatil format for main field added.

    Beta24   31-07-99  andreik Дададзена магчымасьць прагляду крынщцы дадзеных.
    Beta25   01-08-99  andreik Дададзена каманда пераадчынення крыніцы дадзеных.

    Beta26   31-03-99  Dennis  coPos added. Some other things changed.

    Beta27   12-10-99  Denis   Delphi5 incompatability fixed.
    Beta28   20-10-99  andreik Minor bug fixed.

    Beta29   07-02-00  dennis  Sorting event included. Filters removed.

 Additional Information:

    1. Если пользователь компонентой хочет ввести условные форматы "не визуально", то
    ему необходимо добавить их в соответствующий список Conditions и вызвать процедуру
    PrepareConditions, которая произведет подготовку условий к работе.
    2. Для правильной работы данной компоненты названия полей не должны содержать
    пробелов!
--}

unit mmDBGrid;

{ TODO 2 -oAndreik -cerror : Акно з крыніцай дадзеных не павінна мяняць памеры! }

interface

uses
  Windows,        Messages,       SysUtils,       Classes,        Graphics,
  Controls,       Forms,          Dialogs,        Grids,          DBGrids,
  Menus,          StdCtrls,       mBitButton,     ExList,         DB,
  xCalc,          mmDBSearch;

// Указывают на то, что меню может быть добавлено как список или как подгруппа
type
  TPopupMenuKind = (pmkSubMenu, pmkItemMenu);

// Установки по умолчанию.
const
    DefStripeOne = $00D6E7E7;
    DefStripeTwo = $00E7F3F7;
    DefStriped = True;
    DefColorSelected = $009CDFF7;
    DefPopupMenuKind = pmkSubMenu;
    DefScaleColumns = False;
    DefMinColWidth = 40;
    DefColorDialogs = $00E7F3F7;
    DefConditionalFormatting = False;
    DefFiltered = False;

// Виды операций условного форматирвания.
type
  TConditionOperation = (
                         coEqual, coNonEqual, coIn, coOut, coBigger, coSmaller,
                         coBiggerEqual, coSmallerEqual, coPos
                         );

type
  TCheckField = class
  private
    FChecks: TStringList; // Список выбранных элементов
    FCheckField, FShowField: String; // Поле, в котором отображаются данные

  public
    constructor Create(ACheckField, AShowField: String);
    destructor Destroy; override;

    function FindCheck(ACheck: String; var Index: Integer): Boolean;
    procedure AddCheck(ACheck: String);

    property Checks: TStringList read FChecks;
    property CheckField: String read FCheckField;
    property ShowField: String read FShowField;
  end;

type
  TCondition = class
  private
    FColor: TColor; // Цвет условия
    FUseColor: Boolean; // Использовать ли цвет для условия

    FFont: TFont; // Шрифт условия
    FOperation: TConditionOperation; // Вид условного форматирования
    FUseFont: Boolean; // Использовать ли цвет для условия

    FCondition1: String; // Условие
    FCondition2: String; // Условие
    FFieldName: String; // Наименование поля
    FDisplayFields: TStringList; // Список полей отображения условного форматирования
    FFormula: Boolean; // Использованы ли формулы

    procedure SetFont(const Value: TFont);

  public
    TypedCompare: Boolean; // Если сравнение значений по одному из типов
    DoubleValue1, DoubleValue2: Double; // Данные в числовом виде

    constructor Create;
    destructor Destroy; override;

    function MakeCopy: TCondition;

    property Color: TColor read FColor write FColor;
    property UseColor: Boolean read FUseColor write FUseColor;
    property UseFont: Boolean read FUseFont write FUseFont;
    property Font: TFont read FFont write SetFont;
    property Condition1: String read FCondition1 write FCondition1;
    property Condition2: String read FCondition2 write FCondition2;
    property Operation: TConditionOperation read FOperation write FOperation;
    property FieldName: String read FFieldName write FFieldName;
    property Formula: Boolean read FFormula write FFormula;
    property DisplayFields: TStringList read FDisplayFields;

  end;

type
  TFieldOption = class
  private
    FMinWidth, FMaxWidth: Integer; // Минимальный, максимальный размер колонки в символах
    FScaled: Boolean; // Разрешать ли растягивание колонки
    FFieldName: String; // Имя поля, которому соответствует данная колонка

  public
    constructor Create;

    property MinWidth: Integer read FMinWidth write FMinWidth;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth;
    property Scaled: Boolean read FScaled write FScaled;
    property FieldName: String read FFieldName write FFieldName;

  end;

  //////////////////////////////////////////
  // Событие, по которому пользователь может
  // регулировать установку сортировки

type
  TmmDBGridSortEvent = function
  (
    Sender: TObject; // TmmDBGrid, в котором устанавливаем сортировку
    SortField: TField; // TField - поле, по которому устанавливаем сортировку
    var SortFieldText: String // Имя поля, которое подставляем в сортировку (можно изменить)
  ): Boolean of object; // True, если можно вообще подставлять в ORDER BY
  TmmDBGridOnCheck = procedure(const Index: String; const State: Boolean) of object;
type
  TmmDBGrid = class(TDBGrid)
  private
    FStripeTwo: TColor; // Цвет первой полосы
    FStripeOne: TColor; // Цвет второй полосы
    FStriped: Boolean; // Режим полосатости
    FColorSelected: TColor; // Цвет выделенной ячейки
    FPopupMenu: TPopupMenu; // Собственное PopupMenu с изменениями меню пользователя
    FPopupMenuKind: TPopupMenuKind; // Вид подстановки меню в общее меню
    FScaleColumns: Boolean; // Использовать ли масштабирование колонок или нет?
    FMinColWidth: Integer; // Минимальный размер колонки по умолчанию
    FColorDialogs: TColor; // Цвет диалога изменения названия колонки
    FConditionalFormatting: Boolean; // Использовать ли условное форматирование
    FConditions: TExList; // Условия форматирования
    FFieldOptions: TExList; // Список установок для колонок таблицы
    FLineCount: Integer; // Кол-во линий в одной строчке
    FLineFields: TStringList; // Список полей по полю...
    FShowLines: Boolean; // Показывать ли допонительные линии

    FShowCheckBoxes: Boolean; // Показывать ли Checkbox-ы или нет
    FCheckFields: TStringList; // Список полей, по которым будут отображаться CheckBox-ы
    FChecks: TExList; // Список объектов по полям с CheckBox-ами

    FSearch: TmmDBSearch; // Компонента поиска

    FGlyphChecked: TBitmap; // Рисунок выбранного CheckBox-а
    FGlyphUnChecked: TBitmap; // Рисунок не выбранного CheckBox-а

    FUltraChanges: Boolean; // Специальная переменная показывает, были ли изменения в доп-ых установках
    FFoCal: TxFoCal; // Компонента расчета формул

    FUseSorting: Boolean; // Использовать сорировку или нет

    FOnReadDefaults: TNotifyEvent; // Event считывания начальных установок
    FSortEvent: TmmDBGridSortEvent; // События проверки сортировки

    FOnCheck: TmmDBGridOnCheck; // Событие на Check

    FontDlg: TFontDialog; // Диалог выбора шрифта
    ColorDlg: TColorDialog; // Диалог выбора цвета

    PopupColumn: TColumn; // Колонка, по которой будут производится изменения.
    OldOnPopup: TNotifyEvent; // Event OnPopup пользователя
    OldOnColumnMoved: TMovedEvent; // Event по перемещению колонки пользователя
    OldColumnsCount: Integer; // Старое число колонок

    OldColWidth: Integer; // Сдвиг колонки
    CurrLine: Integer; // Текущая линия между колонками
    CurrResting: Integer; // К какой колонке сейчас производим добавление
    RestingKind: Boolean; // True - увеличение, False - уменьшение
    CanUpdateScale: Boolean; // Можно ли менять размеры колонок

    ShowingLines: TStringList; // Показываемые линии

    procedure SetStripeOne(const Value: TColor);
    procedure SetStripeTwo(const Value: TColor);
    procedure SetStriped(const Value: Boolean);
    procedure SetColorSelected(const Value: TColor);
    procedure SetPopup(const Value: TPopupMenu);
    procedure SetPopupMenuKind(const Value: TPopupMenuKind);
    procedure SetScaleColumns(const Value: Boolean);
    procedure SetConditionalFormatting(const Value: Boolean);
    procedure SetLineCount(const Value: Integer);
    procedure SetLineFields(const Value: TStringList);
    procedure SetShowLines(const Value: Boolean);
    procedure SetShowCheckBoxes(const Value: Boolean);
    procedure SetCheckFields(const Value: TStringList);
    procedure SetGlyphChecked(const Value: TBitmap);
    procedure SetGlyphUnChecked(const Value: TBitmap);
    procedure SetUseSorting(const Value: Boolean);

    function GetPopup: TPopupMenu;
    function GetShowChecksByName(Value: String): TStringList;
    function GetCheckFieldByShowField(Value: String): String;

    procedure WMRButtonDown(var Message: TWMLButtonDown);
      message WM_RBUTTONDOWN;
    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;

    procedure DoOnPopupMenu(Sender: TObject);

    procedure DoOnTableFont(Sender: TObject);
    procedure DoOnTableTitleFont(Sender: TObject);
    procedure DoOnColFont(Sender: TObject);
    procedure DoOnColTitleFont(Sender: TObject);

    procedure DoOnTableColor(Sender: TObject);
    procedure DoOnSelectedColor(Sender: TObject);
    procedure DoOnTableTitleColor(Sender: TObject);
    procedure DoOnColColor(Sender: TObject);
    procedure DoOnColTitleColor(Sender: TObject);
    procedure DoOnFirstStripeColor(Sender: TObject);
    procedure DoOnSecondStripeColor(Sender: TObject);

    procedure DoOnColAlign(Sender: TObject);
    procedure DoOnColTitleAlign(Sender: TObject);
    procedure DoOnCheckStriped(Sender: TObject);
    procedure DoOnCheckConditionalFormatting(Sender: TObject);
    procedure DoOnCheckScaleColumns(Sender: TObject);

    procedure DoOnCondition(Sender: TObject);
    procedure DoOnChooseColumns(Sender: TObject);
    procedure DoOnChooseLines(Sender: TObject);
    procedure DoOnShowLines(Sender: TObject);

    procedure DoOnNewTitle(Sender: TObject);
    procedure DoOnColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
    procedure DoOnTableMaster(Sender: TObject);

    procedure DoOnViewDataSource(Sender: TObject);
    procedure DoOnReopenDataSet(Sender: TObject);

    procedure MakePopupSettings(MakeMenu: TPopupMenu; WithColumn: Boolean);
    procedure LoadCheckBoxBitmap(ABitmap: TBitmap; Checked: Boolean);
    procedure CreateCheckData;

    function FindFieldOption(AFieldName: String): TFieldOption;

    function GetDetailLines(AField: String; var FoundLines: TStringList): Boolean;
    function GetDetailField(AField: String; var FieldFormat: String): Boolean;
    procedure SetDetailLines(AField: String; Details: TStringList);

    function GetMaxLineCount: Integer;
    function GetDefaultRowHeight: Integer;

    procedure MakeVariables;

    function IsFieldInOrderBy(F: String; var ASC: Boolean): Boolean;
    procedure InsertFieldOrderBy(F: String; ASC: Boolean);

  protected

    // Используется в дереве. Запрещает переход на необходимую запись для получения
    // данных при перерисовке
    SkipActiveRecord: Boolean;

    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure Scroll(Distance: Integer); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure ColWidthsChanged; override;
    procedure RowHeightsChanged; override;
    procedure CalcSizingState(X, Y: Integer; var State: TGridState;
      var Index: Longint; var SizingPos, SizingOfs: Integer;
      var FixedInfo: TGridDrawInfo); override;
    procedure SetColumnAttributes; override;
    procedure LinkActive(Value: Boolean); override;

    function CurrLineCount: Integer;
    function GetTreeMoveBy(WhileDrawing: Boolean; CheckField: Boolean; F: TField): Integer; dynamic;

    procedure DoOnSearch(Sender: TObject); dynamic;

    procedure DoOnAddCheck(C: TCheckField; S: String); dynamic;
    procedure DoOnDeleteCheck(C: TCheckField; Index: Integer); dynamic;
    function DoOnFindCheck(C: TCheckField; ACheck: String; var Index: Integer): Boolean; dynamic;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    procedure PrepareConditions;
    procedure DeletePopupSettings(FromMenu: TMenuItem);

    procedure AddCheck(AField, ACheck: String);
    procedure DeleteCheck(AField, ACheck: String);

    function CheckFormula(S: String; var D: Double): Boolean;
    function ConvertFormulaToFields(S: String): String;
    function ConvertFormulaToDisplays(S: String): String;

    function GetSearch: TmmDBSearch;
    function CanBeSortedFiltered: Boolean;

    // Список условий условного форматирования.
    property Conditions: TExList read FConditions;
    // Список установок для колонок
    property FieldOptions: TExList read FFieldOptions;
    // Список элементов по названию поля
    property ShowChecksByName[AField: String]: TStringList read GetShowChecksByName;
    // Поле данных по отображаемому полю (для CheckBox-ов)
    property CheckFieldByShowField[AField: String]: String read GetCheckFieldByShowField;
    // Показывает, были ли изменены допонительные установки (условн. формат., дет. отображ.)
    property UltraChanges: Boolean read FUltraChanges write FUltraChanges;

  published
    // Цвет первой полосы
    property StripeOne: TColor read FStripeOne write SetStripeOne default DefStripeOne;
    // Цвет второй полосы
    property StripeTwo: TColor read FStripeTwo write SetStripeTwo default DefStripeTwo;
    // Использовать ли режим полосатой таблицы или нет
    property Striped: Boolean read FStriped write SetStriped default DefStriped;
    // Цвет выделенной ячейки таблицы
    property ColorSelected: TColor read FColorSelected write SetColorSelected default DefColorSelected;
    // Обычный PopupMenu
    property PopupMenu: TPopupMenu read GetPopup write SetPopup;
    // Вид подстановки элементов меню в общее меню.
    property PopupMenuKind: TPopupMenuKind read FPopupMenuKind write SetPopupMenuKind default DefPopupMenuKind;
    // использовать ли масштабирование колонок или нет.
    property ScaleColumns: Boolean read FScaleColumns write SetScaleColumns default DefScaleColumns;
    // Минимальный размер колонки по умолчанию
    property MinColWidth: Integer read FMinColWidth write FMinColWidth default DefMinColWidth;
    // Кол-во, колонок с начала, которые неменяют свой размер
    property ColorDialogs: TColor read FColorDialogs write FColorDialogs default DefColorDialogs;
    // Использовать ли условное форматирование?
    property ConditionalFormatting: Boolean read FConditionalFormatting write SetConditionalFormatting default DefConditionalFormatting;
    // Кол-во строчек в одной ячейке
    property LineCount: Integer read FLineCount write SetLineCount;
    // Список полей по полю
    property LineFields: TStringList read FLineFields write SetLineFields;
    // Показывать ли дополнительные линии
    property ShowLines: Boolean read FShowLines write SetShowLines;
    // Показывать ли в таблице CheckBox-ы или нет
    property ShowCheckBoxes: Boolean read FShowCheckBoxes write SetShowCheckBoxes;
    // Список полей, по которым будут отображаться CheckBox-ы
    property CheckFields: TStringList read FCheckFields write SetCheckFields;
    // Рисунок выбранного CheckBox-а
    property GlyphChecked: TBitmap read FGlyphChecked write SetGlyphChecked;
    // Рисунок не выбранного CheckBox-а
    property GlyphUnChecked: TBitmap read FGlyphUnChecked write SetGlyphUnChecked;
    // Использовать сортировку или нет
    property UseSorting: Boolean read FUseSorting write SetUseSorting;
    // Event считывания начальных установок через mmRunTimeStore
    property OnReadDefaults: TNotifyEvent read FOnReadDefaults write FOnReadDefaults;
    // События проверки сортировки
    property SortEvent: TmmDBGridSortEvent read FSortEvent write FSortEvent;

    property OnCheck: TmmDBGridOnCheck read FOnCheck write FOnCheck;
  end;

{
  Константы для работы с условным
  форматированием.
}

const
  ConditionText: array[TConditionOperation] of String =
    (
     'равно', 'не равно', 'между', 'вне', 'больше',
     'меньше', 'больше или равно', 'меньше или равно',
     'содержит'
    );

  DoubleConditionInterval: array[TConditionOperation] of Boolean =
    (
     False, False, True, True, False, False, False, False, False
    );

  DoubleConditionIntervalInt: array[0..8] of Boolean =
    (
     False, False, True, True, False, False, False, False, False
    );

  OperationByIndex: array[0..8] of TConditionOperation =
    (
     coEqual, coNonEqual, coIn, coOut, coBigger, coSmaller,
     coBiggerEqual, coSmallerEqual, coPos
    );

function IsInRect(R: TRect; X, Y: Integer): Boolean;
function CountWidthByChar(Canvas: TCanvas; Grid: TDBGrid; CharCount: Integer; CheckFont: TFont): Integer;

implementation

uses
  mmDBGridCondition, mmDBGridOptions, mmDBGridDetail, CheckLst,
  mmDBGrid_dlgViewDataSource, gsMultilingualSupport

  (*{$DEFINE MMDBGRID_IBEXPRESS}*)

  {$IFDEF MMDBGRID_IBEXPRESS}
  ,IBQuery, IBTable, IBCustomDataSet

  {$ELSE}
  ,DBTables
  {$ENDIF}

  ;

// Константы размеров рисунков CheckBox-ов
const
  CheckBoxWidth = 13;
  CheckBoxHeight = 13;

  SQL_ORDERBY = 'ORDER BY';
  SQL_DESC = 'DESC';
  SQL_DESCENDING = 'DESCENDING';
  SQL_ASC = 'ASC';
  SQL_ASCENDING = 'ASCENDING';

const
  mmdbg_UserCount: Integer = 0; // Кол-во компонент, созданных в программе в данный момент
  TAG_ADDITIONALMENU = 1234567890; // Специальный итендификатор для распознания своих элементов меню.

var
  DrawBitmap: TBitmap = nil; // Используется во WriteText.

{
  -----------------------------------------------
  ---                                         ---
  ---   Additional functions and procedures   ---
  ---                                         ---
  -----------------------------------------------
}

{
  Входит ли точка в Rect
}

function IsInRect(R: TRect; X, Y: Integer): Boolean;
begin
  Result := (X >= R.Left) and (X <= R.Right) and (Y >= R.Top) and (Y <= R.Bottom);
end;

{
  Рассчитывает длину на основании количества символов.
}

function CountWidthByChar(Canvas: TCanvas; Grid: TDBGrid; CharCount: Integer; CheckFont: TFont): Integer;
var
  RestoreCanvas: Boolean;
  TM: TTextMetric;
begin
  if CharCount <= 0 then
  begin
    Result := -1;
    Exit;
  end;

  RestoreCanvas := not Grid.HandleAllocated;
  if RestoreCanvas then Canvas.Handle := GetDC(0);

  try
    Canvas.Font := CheckFont;
    GetTextMetrics(Canvas.Handle, TM);
//    Result := CharCount * (Canvas.TextWidth('0') - TM.tmOverhang) + TM.tmOverhang + 4;
    Result := CharCount * TM.tmAveCharWidth - (TM.tmAveCharWidth div 2) + TM.tmOverhang + 3;
  finally
    if RestoreCanvas then
    begin
      ReleaseDC(0,Canvas.Handle);
      Canvas.Handle := 0;
    end;
  end;
end;

{
  Borland-овская функция по рисованию текста. Взята из DBGrids.pas.
}

procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: string; Alignment: TAlignment; ARightToLeft: Boolean);

const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX );
  RTL: array [Boolean] of Integer = (0, DT_RTLREADING);

var
  B, R: TRect;
  Hold, Left: Integer;
  I: TColorRef;

  //  Какое из чисел больше?
  function Max(X, Y: Integer): Integer;
  begin
    Result := Y;
    if X > Y then Result := X;
  end;

begin
  I := ColorToRGB(ACanvas.Brush.Color);
  if GetNearestColor(ACanvas.Handle, I) = I then
  begin
    if (ACanvas.CanvasOrientation = coRightToLeft) and (not ARightToLeft) then
      ChangeBiDiModeAlignment(Alignment);
    case Alignment of
      taLeftJustify:
        Left := ARect.Left + DX;
      taRightJustify:
        Left := ARect.Right - ACanvas.TextWidth(Text) - 3;
    else { taCenter }
      Left := ARect.Left + (ARect.Right - ARect.Left) shr 1
        - (ACanvas.TextWidth(Text) shr 1);
    end;
    ACanvas.TextRect(ARect, Left, ARect.Top + DY, Text);
  end
  else begin                  { Use FillRect and DrawText for dithered colors }
    DrawBitmap.Canvas.Lock;
    try
      with DrawBitmap, ARect do { Use offscreen bitmap to eliminate flicker and }
      begin                     { brush origin tics in painting / scrolling.    }
        Width := Max(Width, Right - Left);
        Height := Max(Height, Bottom - Top);
        R := Rect(DX, DY, Right - Left - 1, Bottom - Top - 1);
        B := Rect(0, 0, Right - Left, Bottom - Top);
      end;
      with DrawBitmap.Canvas do
      begin
        Font := ACanvas.Font;
        Font.Color := ACanvas.Font.Color;
        Brush := ACanvas.Brush;
        Brush.Style := bsSolid;
        FillRect(B);
        SetBkMode(Handle, TRANSPARENT);
        if (ACanvas.CanvasOrientation = coRightToLeft) then
          ChangeBiDiModeAlignment(Alignment);
        DrawText(Handle, PChar(Text), Length(Text), R,
          AlignFlags[Alignment] or RTL[ARightToLeft]);
      end;
      if (ACanvas.CanvasOrientation = coRightToLeft) then
      begin
        Hold := ARect.Left;
        ARect.Left := ARect.Right;
        ARect.Right := Hold;
      end;
      ACanvas.CopyRect(ARect, DrawBitmap.Canvas, B);
    finally
      DrawBitmap.Canvas.Unlock;
    end;
  end;
end;

{
  -----------------------
  ---                 ---
  ---   TCheckField   ---
  ---                 ---
  -----------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TCheckField.Create(ACheckField, AShowField: String);
begin
  FChecks := TStringList.Create;
  FCheckField := ACheckField;
  FShowField := AShowField;
end;

{
  Высвобождаем память.
}

destructor TCheckField.Destroy;
begin
  FChecks.Free;
  
  inherited Destroy;
end;

{
  Производим поиск указанного элемента в списке.
}

function TCheckField.FindCheck(ACheck: String; var Index: Integer): Boolean;
begin
  Index := FChecks.IndexOf(ACheck);
  Result := (Index >= 0);
end;

{
  Добавляем данные.
}

procedure TCheckField.AddCheck(ACheck: String);
begin
  if FChecks.IndexOf(Acheck) = -1 then
    FChecks.Add(ACheck);
end;

{
  ------------------------
  ---                  ---
  ---   TFieldOption   ---
  ---                  ---
  ------------------------
}


{
  Делаем начальные установки.
}

constructor TFieldOption.Create;
begin
  FMinWidth := -1;
  FMaxWidth := -1;
  FScaled := True;
end;


{
  ----------------------
  ---                ---
  ---   TCondition   ---
  ---                ---
  ----------------------
}


{
  **********************
  ***  Public Part   ***
  **********************
}

{
  Делаем начальные установки.
}

constructor TCondition.Create;
begin
  FColor := clWhite;
  FUseColor := False;

  FFont := TFont.Create;
  FUseFont := False;

  FOperation := coEqual;

  FCondition1 := '';
  FCondition2 := '';
  FFieldName := '';
  FFormula := False;

  FDisplayFields := TStringList.Create;

  TypedCompare := False;

  DoubleValue1 := 0;
  DoubleValue2 := 0;
end;

{
  Высвобождаем память.
}

destructor TCondition.Destroy;
begin
  FFont.Free;
  FDisplayFields.Free;

  inherited Destroy;
end;

{
  Возвращает такую же копию этого класса.
}

function TCondition.MakeCopy: TCondition;
begin
  Result := TCondition.Create;
  Result.Color := FColor;
  Result.UseColor := FUseColor;
  Result.UseFont := FUseFont;
  Result.Font := FFont;
  Result.Condition1 := FCondition1;
  Result.Condition2 := FCondition2;
  Result.Formula := FFormula;
  Result.Operation := FOperation;
  Result.FieldName := FFieldName;
  Result.DisplayFields.Assign(FDisplayFields);
end;


{
  ***********************
  ***  Private Part   ***
  ***********************
}


{
  Устанавливаем шрифт условия.
}

procedure TCondition.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;


{
  ---------------------
  ---               ---
  ---   TmmDBGrid   ---
  ---               ---
  ---------------------
}

function GetCheckFieldByName(Checks: TExList; AField: String): TCheckField;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Checks.Count - 1 do
    if AnsiCompareText(TCheckField(Checks[I]).ShowField, AField) = 0 then
    begin
      Result := Checks[I];
      Break;
    end;
end;

{
  **********************
  ***  Public Part   ***
  **********************
}


{
  Создает компоненту, производятся начальные установки.
}

constructor TmmDBGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  SkipActiveRecord := False;

  FConditions := TExList.Create;
  FFieldOptions := TExList.Create;
  FChecks := TExList.Create;

  FSearch := TmmDBSearch.Create(Self);

  FStripeOne := DefStripeOne;
  FStripeTwo := DefStripeTwo;
  FStriped := DefStriped;
  FColorSelected := DefColorSelected;
  FPopupMenuKind := DefPopupMenuKind;

  FScaleColumns := DefScaleColumns;
  FMinColWidth := DefMinColWidth;
  FColorDialogs := DefColorDialogs;
  FConditionalFormatting := DefConditionalFormatting;
  FUseSorting := False;

  FLineCount := 1;
  FShowLines := False;
  FLineFields := TStringList.Create;
  ShowingLines := TStringList.Create;

  FShowCheckBoxes := False;
  FCheckFields := TStringList.Create;

  // Загружаем рисунок выделенного Checkbox-а
  FGlyphChecked := TBitmap.Create;
  LoadCheckBoxBitmap(FGlyphChecked, TRUE);

  // Загружаем рисунок не выделенного Checkbox-а
  FGlyphUnchecked := TBitmap.Create;
  LoadCheckBoxBitmap(FGlyphUnchecked, FALSE);

  FOnReadDefaults := nil;

  CanUpdateScale := False;
  CurrLine := -1;
  CurrResting := -1;
  RestingKind := False;
  OldColWidth := 0;
  OldColumnsCount := 0;

  FPopupMenu := nil;
  FUltraChanges := False;

  FFoCal := nil;

  if not (csDesigning in ComponentState) then
    FFoCal := TxFoCal.Create(Self);

  // В самом начале создаем bitmap для рисования текста в таблице
  if mmdbg_UserCount = 0 then
    DrawBitmap := TBitmap.Create;

  Inc(mmdbg_UserCount);
end;

{
  Удаляет из памяти компоненту, делаются конечные установки.
}

destructor TmmDBGrid.Destroy;
begin
  // Производим проверку использования данной компоненты.
  // В конце работы удаляем bitmap для риования текста

  if (FPopupMenu = PopupMenu) and not (csDesigning in ComponentState) then
  begin
    PopupMenu := nil;
    FPopupMenu.Free;
  end;

  Dec(mmdbg_UserCount);
  if (mmdbg_UserCount <= 0) and (DrawBitmap <> nil) then
  begin
    DrawBitmap.Free;
    DrawBitmap := nil;
  end;

  FCheckFields.Free;
  ShowingLines.Free;
  FLineFields.Free;
  FChecks.Free;
  FConditions.Free;
  FFieldOptions.Free;

  inherited Destroy;
end;

{
  Устанавливает размеры окна. Здесь идет проверка размеров колонок и
  их изменение.
}

procedure TmmDBGrid.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  Rest: Integer;
  I: Integer;
  N: Integer;
  AllreadyRested: Integer;
  OldGridWidth, ScaleClientWidth: Integer;
  CurrOption: TFieldOption;
  MinWidth, MaxWidth: Integer;

  // Возвращает длину изменяемых колонок таблицы
  function GetScaleGridWidth: Integer;
  var
    K: Integer;
    FO: TFieldOption;
  begin
    Result := 0;

    for K := 0 to ColCount - 1 - Integer(dgIndicator in Options) do
    begin
      FO := FindFieldOption(Columns[K].FieldName);

      if (FO = nil) or ((FO <> nil) and FO.FScaled) then
        Inc(Result, ColWidths[K + Integer(dgIndicator in Options)] + GridLineWidth);
    end;
  end;

  // Возвращает длину окна без размера нерастягиваемых колонок.
  function GetScaleClientWidth: Integer;
  var
    K: Integer;
    FO: TFieldOption;
  begin
    Result := ClientWidth - Integer(dgIndicator in Options) *
      (ColWidths[0] + GridLineWidth);

    for K := 0 to ColCount - 1 - Integer(dgIndicator in Options) do
    begin
      FO := FindFieldOption(Columns[K].FieldName);

      if (FO <> nil) and not FO.FScaled then
        Dec(Result, ColWidths[K + Integer(dgIndicator in Options)] + GridLineWidth);
    end;
  end;

  // Получаем следующую колонку для добавления (уменьшения) размеров
  procedure GetNextResting;
  var
    FO: TFieldOption;
  begin
    if CurrResting >= Columns.Count - 1 then
      CurrResting := 0
    else
      Inc(CurrResting);

    FO := FindFieldOption(Columns[CurrResting].FieldName);
    if (FO <> nil) and not FO.FScaled then GetNextResting;
  end;

begin
  // Производим проверку для указания порядка добавления в длину колонки
  if (AWidth > Width) and not RestingKind then
  begin
    RestingKind := True;
    CurrResting := -1;
  end else if (AWidth < Width) and RestingKind then
  begin
    RestingKind := False;
    CurrResting := -1;
  end;

  inherited SetBounds(ALeft, ATop, AWidth, AHeight);

  // Производим изменения
  if (DataLink <> nil) and (DataLink.Active) and FScaleColumns and (Parent <> nil) and
    CanUpdateScale and not (csDesigning in ComponentState) then
  begin
    CanUpdateScale := False;

    MinWidth := -1;
    MaxWidth := -1;

    OldGridWidth := GetScaleGridWidth;
    ScaleClientWidth := GetScaleClientWidth;

    for I := 0 to ColCount - 1 - Integer(dgIndicator in Options) do
    begin
      // Получаем установки для данной колонки
      if i >= ColCount then Break;
      CurrOption := FindFieldOption(Columns[I].FieldName);

      // Если установки существуют
      if CurrOption <> nil then
      begin
        // Если колонку нельзя растягивать, то пропускаем ее
        if not CurrOption.FScaled then
          Continue;

        // Устанавливаем минимальные и максимальные размеры
        MinWidth := CountWidthByChar(Canvas, Self, CurrOption.MinWidth, Columns[I].Font);
        MaxWidth := CountWidthByChar(Canvas, Self, CurrOption.MaxWidth, Columns[I].Font);

        if MinWidth < FMinColWidth then MinWidth := FMinColWidth;
      end else begin // Если их нет
        MinWidth := FMinColWidth;
        MaxWidth := -1;
      end;

      N := Round(ScaleClientWidth * ColWidths[I + Integer(dgIndicator in Options)] / OldGridWidth);

      if N < MinWidth then
        ColWidths[I + Integer(dgIndicator in Options)] := MinWidth
      else if (MaxWidth <> -1) and (N > MaxWidth) then
        ColWidths[I + Integer(dgIndicator in Options)] := MaxWidth
      else
        ColWidths[I + Integer(dgIndicator in Options)] := N;
    end;

    // Оставшаяся часть
    Rest := ScaleClientWidth - GetScaleGridWidth;

    AllreadyRested := 0;

    while Rest <> 0 do
    begin
      if CurrResting >= Columns.Count - 1 then
        CurrResting := 0
      else
        Inc(CurrResting);

      // Если нельзя добавить ни в оду из оставшихся частей, то выходим
      if (CurrResting < 0) or (AllreadyRested >= Columns.Count) then
      begin
        CanUpdateScale := True;
        Exit;
      end;

      Inc(AllreadyRested);

      CurrOption := FindFieldOption(Columns[CurrResting].FieldName);

      // Если установки существуют
      if CurrOption <> nil then
      begin
        // Если колонку нельзя растягивать, то пропускаем ее
        if not CurrOption.FScaled then Continue;

        // Устанавливаем минимальные и максимальные размеры
        MinWidth := CountWidthByChar(Canvas, Self, CurrOption.MinWidth, Columns[CurrResting].Font);
        MaxWidth := CountWidthByChar(Canvas, Self, CurrOption.MaxWidth, Columns[CurrResting].Font);

        if MinWidth < FMinColWidth then MinWidth := FMinColWidth;
      end else begin // Если их нет
        MinWidth := FMinColWidth;
        MaxWidth := -1;
      end;

      N := ColWidths[CurrResting + Integer(dgIndicator in Options)] + Rest;

      if ((N < MaxWidth) and (N > MinWidth)) or
        ((MaxWidth = -1) and (N > MinWidth)) then
      begin
        ColWidths[CurrResting + Integer(dgIndicator in Options)] := N;
        Rest := 0;
      end else begin
        if Rest > 0 then
        begin
          ColWidths[CurrResting + Integer(dgIndicator in Options)] := MaxWidth;
          Rest := N - MaxWidth;
        end else begin
          ColWidths[CurrResting + Integer(dgIndicator in Options)] := MinWidth;
          Rest := N - MinWidth;
        end;
      end;
    end;

    CanUpdateScale := True;
  end;
end;

{
  Производит проверку на случай выполнения условия на указанное
  значение.
}

procedure TmmDbGrid.PrepareConditions;
var
  I: Integer;
  CurrCondition: TCondition;

  // Производит проверку типов данных.
  // Если False, то обычная строка
  function CheckValue(S: String; T: TFieldType; var Value: Double): Boolean;
  var
    D: Double;
    K: Integer;

    // Подставляет дату вместо символов
    procedure CheckNowDate;
    var
      Day, Month, Year: Word;
    begin
      DecodeDate(Now, Year, Month, Day);
      K := Pos('dd', S);
      if K > 0 then
        S := Copy(S, 1, K - 1) + IntToStr(Day) + Copy(S, K + 2, Length(S));

      K := Pos('mm', S);
      if K > 0 then
        S := Copy(S, 1, K - 1) + IntToStr(Month) + Copy(S, K + 2, Length(S));

      K := Pos('yyyy', S);
      if K > 0 then
        S := Copy(S, 1, K - 1) + IntToStr(Year) + Copy(S, K + 4, Length(S));

      K := Pos('yy', S);
      if K > 0 then
        S := Copy(S, 1, K - 1) + IntToStr(Year) + Copy(S, K + 2, Length(S));
    end;

  begin
    Result := False;

    // Если число
    if T in [ftString, ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency,
      ftAutoInc, ftLargeint] then
    begin
      try
        CheckNowDate;
        D := StrToFloat(S);
        Value := D;
        Result := True;
      except
        on Exception do Result := False;
      end;
    // Если дата и (или) время
    end else if T in [ftDate, ftTime, ftDateTime] then
    begin
      try
        CheckNowDate;
        D := StrToDateTime(S);
        Value := D;
        Result := True;
      except
        on Exception do Result := False;
      end;
    end;
  end;

  // Производит проверу возможности сравнения по типу
  procedure CheckTypedCondition(ConditionField: TField);
  var
    D1, D2: Double;
  begin
    if ConditionField = nil then
    begin
      CurrCondition.TypedCompare := False;
      Exit;
    end;

    case CurrCondition.Operation of
      coEqual, coNonEqual, coBigger, coSmaller,
      coBiggerEqual, coSmallerEqual:
      begin
        if CurrCondition.Formula and CheckFormula(CurrCondition.Condition1, D1) then
          CurrCondition.TypedCompare := True
        else begin
          CurrCondition.TypedCompare := CheckValue(CurrCondition.Condition1,
            ConditionField.DataType, D1);

          if CurrCondition.TypedCompare then CurrCondition.DoubleValue1 := D1;
        end;
      end;
      coIn, coOut:
      begin
        if CurrCondition.Formula and CheckFormula(CurrCondition.Condition1, D1) and
          CheckFormula(CurrCondition.Condition2, D2)
        then
          CurrCondition.TypedCompare := True
        else begin
          CurrCondition.TypedCompare :=
            CheckValue(CurrCondition.Condition1, ConditionField.DataType, D1) and
            CheckValue(CurrCondition.Condition2, ConditionField.DataType, D2);

          if CurrCondition.TypedCompare then
          begin
            CurrCondition.DoubleValue1 := D1;
            CurrCondition.DoubleValue2 := D2;
          end;
        end;
      end;
    end;
  end;

begin
  FUltraChanges := True;

  for I := 0 to FConditions.Count - 1 do
  begin
    CurrCondition := FConditions[I];
    CheckTypedCondition(DataSource.DataSet.FindField(CurrCondition.FieldName));
  end;
end;


{
  Производим удаление ранее вставленных пунктов меню из FromMenu.
}

procedure TmmDBGrid.DeletePopupSettings(FromMenu: TMenuItem);
var
  I: Integer;
begin
  for I := FromMenu.Count - 1 downto 0 do
    if FromMenu.Items[I].Tag = TAG_ADDITIONALMENU then FromMenu.Delete(I);
end;

{
  Добавляет Check в список.
}

procedure TmmDBGrid.AddCheck(AField, ACheck: String);
var
  CheckField: TCheckField;
begin
  CheckField := GetCheckFieldByName(FChecks, AField);
                            
  if CheckField <> nil then
    CheckField.AddCheck(ACheck);
end;

{
  Удаляем Check из списка.
}

procedure TmmDBGrid.DeleteCheck(AField, ACheck: String);
var
  CheckField: TCheckField;
  I: Integer;
begin
  CheckField := GetCheckFieldByName(FChecks, AField);

  if (CheckField <> nil) and DoOnFindCheck(CheckField, ACheck, I) then
    DoOnDeleteCheck(CheckField, I);
end;

{
  Производит проверку формулы!
}

function TmmDBGrid.CheckFormula(S: String; var D: Double): Boolean;
begin
  try
    MakeVariables;
    FFoCal.Expression := S;
    Result := FFoCal.Expression = S;
    if Result then D := FFoCal.Value;
  except
    on Exception do Result := False;
  end;
end;

{
  Производит конвертацию DisplayLabel в FieldName.
}

function TmmDBGrid.ConvertFormulaToFields(S: String): String;
var
  I, K: Integer;
begin
  Result := S;

  for I := 0 to DataLink.DataSet.FieldCount - 1 do
    repeat
      K := Pos(AnsiUpperCase(DataLink.DataSet.Fields[I].DisplayLabel), AnsiUpperCase(Result));

      if AnsiCompareText(DataLink.DataSet.Fields[I].FieldName,
        DataLink.DataSet.Fields[I].DisplayLabel) = 0
      then
        Break;

      if K > 0 then
        Result := Copy(Result, 1, K - 1) + DataLink.DataSet.Fields[I].FieldName +
          Copy(Result, K + Length(DataLink.DataSet.Fields[I].DisplayLabel), Length(Result));
    until K = 0;
end;

{
  Производит конвертацию FieldName в DisplayLabel.
}

function TmmDBGrid.ConvertFormulaToDisplays(S: String): String;
var
  I, K: Integer;
begin
  Result := S;

  for I := 0 to DataLink.DataSet.FieldCount - 1 do
    repeat
      K := Pos(AnsiUpperCase(DataLink.DataSet.Fields[I].FieldName), AnsiUpperCase(Result));

      if AnsiCompareText(DataLink.DataSet.Fields[I].FieldName,
        DataLink.DataSet.Fields[I].DisplayLabel) = 0
      then
        Break;

      if K > 0 then
        Result := Copy(Result, 1, K - 1) + DataLink.DataSet.Fields[I].DisplayLabel +
          Copy(Result, K + Length(DataLink.DataSet.Fields[I].FieldName), Length(Result));
    until K = 0;
end;

{
  Вовзращает указатель на компоненту поиска.
}

function TmmDBGrid.GetSearch: TmmDBSearch;
begin
  Result := FSearch;
end;

{
  Можно ли работать над сортировкой
}

function TmmDBGrid.CanBeSortedFiltered: Boolean;
begin
  Result :=
    Assigned(DataSource)
      and
    Assigned(DataSource.DataSet)
      and
  {$IFDEF MMDBGRID_IBEXPRESS}
    (DataSource.DataSet is TIBQuery);
  {$ELSE}
    (DataSource.DataSet is TQuery);
  {$ENDIF}
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}


{
  Производит перерисовку ячейки таблицы.
}

procedure TmmDBGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  OldActive: LongInt; // Сохраненный № пп в таблице
  HighLight: Boolean; // Флаг выделения записей таблицы
  Value: string; // Значение, которое будет нарисовано
  DrawColumn: TColumn; // Текущая таблица, в которой производится рисование
  CheckMoveBy: Integer; // Сдвиг вправо при рисовании CheckBox-ов.
  CheckField: TCheckField; // Объект списка выделенных CheckBox-ов
  OldBrushColor, OldPenColor: TColor;
  Fmt, Fld: String;
  IsASC: Boolean;
  K: Integer;
  Checked: Boolean;

  // Производит установки условий перед рисованием.
  function MakeConditionSettings(CheckField: TField): Boolean;
  var
    I: Integer;
    CurrCondition: TCondition;
    ConditionField: TField;

    // Является ли текущее условие выполненным.
    function IsConditionFulFilled: Boolean;
    begin
      Result := False;

      // Если идет сравнение по типу данных
      if CurrCondition.TypedCompare and (ConditionField.DataType <> ftString) then
      begin
        CheckFormula(CurrCondition.Condition1, CurrCondition.DoubleValue1);

        case CurrCondition.Operation of
          coEqual: Result := CurrCondition.DoubleValue1 = ConditionField.AsFloat;
          coNonEqual: Result := CurrCondition.DoubleValue1 <> ConditionField.AsFloat;
          coIn:
          begin
            CheckFormula(CurrCondition.Condition2, CurrCondition.DoubleValue2);
            Result := (CurrCondition.DoubleValue1 <= ConditionField.AsFloat) and
              (CurrCondition.DoubleValue2 >= ConditionField.AsFloat);
          end;
          coOut:
          begin
            CheckFormula(CurrCondition.Condition2, CurrCondition.DoubleValue2);
            Result := (CurrCondition.DoubleValue1 > ConditionField.AsFloat) or
              (CurrCondition.DoubleValue2 < ConditionField.AsFloat);
          end;
          coBigger: Result := CurrCondition.DoubleValue1 < ConditionField.AsFloat;
          coSmaller: Result := CurrCondition.DoubleValue1 > ConditionField.AsFloat;
          coBiggerEqual: Result := CurrCondition.DoubleValue1 <= ConditionField.AsFloat;
          coSmallerEqual: Result := CurrCondition.DoubleValue1 >= ConditionField.AsFloat;
          coPos: Result := AnsiPos(CurrCondition.Condition1, ConditionField.AsString) > 0;
        end;
      // Если идет сравнение строк
      end else begin
        case CurrCondition.Operation of
          coEqual: Result := AnsiCompareText(CurrCondition.Condition1, ConditionField.AsString) = 0;
          coNonEqual: Result := CurrCondition.Condition1 <> ConditionField.AsString;
          coIn: Result := (CurrCondition.Condition1 <= ConditionField.AsString) and
            (CurrCondition.Condition1 >= ConditionField.AsString);
          coOut: Result := (CurrCondition.Condition1 > ConditionField.AsString) or
            (CurrCondition.Condition1 < ConditionField.AsString);
          coBigger: Result := CurrCondition.Condition1 < ConditionField.AsString;
          coSmaller: Result := CurrCondition.Condition1 > ConditionField.AsString;
          coBiggerEqual: Result := CurrCondition.Condition1 <= ConditionField.AsString;
          coSmallerEqual: Result := CurrCondition.Condition1 >= ConditionField.AsString;
          coPos: Result := AnsiPos(
            ANSIUpperCase(CurrCondition.Condition1), ANSIUpperCase(ConditionField.AsString)) > 0;
        end;
      end;
    end;

  begin
    Result := False;
    if CheckField = nil then Exit;

    for I := 0 to FConditions.Count - 1 do
    begin
      CurrCondition := FConditions[I];

      // Производим поиск необходимого поля
      if CurrCondition.DisplayFields.IndexOf(CheckField.FieldName) >= 0 then
      begin
        ConditionField := DataLink.DataSet.FindField(CurrCondition.FieldName);

        // Если для расчетного поля условие выполняется, то продолжаем
        if (ConditionField <> nil) and IsConditionFulFilled then
        begin
          Result := True;

          with Canvas do
          begin
            if CurrCondition.UseColor and not HighLight then Brush.Color := CurrCondition.Color;
            if CurrCondition.UseFont then Font := CurrCondition.Font;
          end;

        end;
      end;
    end;
  end;

  // Рисует CheckBox.
  procedure DrawCheck(const BMP: TBitmap; R: TRect);
  var
    Pos: Integer;
  begin
    Pos := (BMP.Height - (R.Bottom - R.Top)) div 2;

    Canvas.BrushCopy(
      Rect(R.Left, R.Top, R.Right, R.Bottom),
      BMP,
      Rect(0, Pos, R.Right - R.Left, R.Bottom - R.Top + Pos),
      BMP.TransparentColor);
  end;

begin
  // Если не включен режим полосатости или же фиксированная ячейка, то ее рисование
  // передаем родителю данной компоненты.
  if gdFixed in AState then
  begin
    inherited DrawCell(ACol, ARow, ARect, AState);

    // Получаем колонку, в которой будем рисовать
    K := ACol - Integer(dgIndicator in Options);

    if (K >= 0) and (ARow = 0) then
      DrawColumn := Columns[K]
    else
      DrawColumn := nil;

    Value := '';

    if (DrawColumn <> nil) and (DrawColumn.Field <> nil) then
    begin
      Value := DrawColumn.FieldName;

      if Assigned(FSortEvent) then
        FSortEvent(Self, DrawColumn.Field, Value);
    end;

    // Производим перерисовку сортировки
    if CanBeSortedFiltered and FUseSorting and (DrawColumn <> nil) and
      (DrawColumn.Field <> nil) and IsFieldInOrderBy(Value, IsASC) then
    begin
      with ARect do
      begin
        OldBrushColor := Canvas.Brush.Color;
        OldPenColor := Canvas.Pen.Color;

        Canvas.Brush.Color := clRed;//clFuchsia;
        Canvas.Pen.Color := clRed;//clRed;

        if IsASC then
          Canvas.Polygon([Point(Right - 6, Top), Point(Right - 1, Top), Point(Right - 1, Top + 5)])
        else
          Canvas.Polygon([Point(Right - 6, Bottom - 1), Point(Right - 1, Bottom - 1), Point(Right - 1, Bottom - 6)]);

        Canvas.Brush.Color := OldBrushColor;
        Canvas.Pen.Color := OldPenColor;
      end;
    end;
  // В другом случае рисование производим самостоятельно
  end else with Canvas do
  begin
    // Данный код был взят у компании Borland International из компоненты DBGrid,
    // но впоследствии в него были внесены изменения.
    DrawColumn := Columns[ACol - Integer(dgIndicator in Options)];

    // Устанавливаем шрифт и цвет
    Font := DrawColumn.Font;
    Brush.Color := DrawColumn.Color;

    CheckMoveBy := 0;

    // Если текста нет, то рисуем простой прямоугольник
    if (DataLink = nil) or not DataLink.Active then
    begin
      FillRect(ARect);
    // В другом случае производим прорисовку данных
    end else begin
      // Устанавливаем указатель в базе данных на необходимую запись для
      // получения данных
      OldActive := DataLink.ActiveRecord;
      try
        if not SkipActiveRecord then DataLink.ActiveRecord := ARow - Integer(dgTitles in Options);

        if Assigned(DrawColumn.Field) then
        begin
          if FShowLines and GetDetailField(DrawColumn.FieldName, Fmt) then
            Value := Format(Fmt, [DrawColumn.Field.DisplayText])
          else
            Value := DrawColumn.Field.DisplayText;
        end else
          Value := '';

        // Устанавливаем необходимость рисования данной ячейки выделенной
        Highlight := HighlightCell(ACol, ARow, Value, AState);

        // Устанавливаем цвет для рисования текста
        if Highlight then
          Brush.Color := FColorSelected
        else begin
          // Выбираем цвет текущей полосы в таблице
          if FStriped then
          begin
            if (ARow mod 2) = 0 then
              Brush.Color := FStripeTwo
            else
              Brush.Color := FStripeOne;
          end;

        end;

        // Производим проверку на условное форматирование.
        if FConditionalFormatting then MakeConditionSettings(DrawColumn.Field);

        // Рисуем текст
        if DefaultDrawing then
        begin
          CheckField := nil;
          Checked := False;

          // Если таблица использует CheckBox-ы
          if FShowCheckBoxes then
          begin
            CheckField := GetCheckFieldByName(FChecks, DrawColumn.FieldName);

            // Если поле с CheckBox-ами найдено
            if CheckField <> nil then
            begin
              Checked := DoOnFindCheck(CheckField, DataLink.DataSet.
                FieldByName(CheckField.CheckField).AsString, K);

              if Checked then
                CheckMoveBy := FGlyphChecked.Width + 1
              else
                CheckMoveBy := FGlyphUnChecked.Width + 1;
            end;
          end;

          // В этом месте производится сдвиг текста в право на TreeMoveBy.
          // Это сделано спеецаильно для класса, созданного на основе данного,
          // в котором будет рисоваться дерево (т.е. mmDBGridTree)!
          WriteText(Self.Canvas, ARect, 2 + GetTreeMoveBy(True, False, nil) + CheckMoveBy, 2, Value, DrawColumn.Alignment,
            UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment));

          // Рисуем CheckBox-ы
          if FShowCheckBoxes and (CheckField <> nil) then
            if Checked then
              DrawCheck(FGlyphChecked, Rect(ARect.Left + 2 + GetTreeMoveBy(True, False, nil), ARect.Top,
                ARect.Right, ARect.Top + (ARect.Bottom - ARect.Top) div CurrLineCount))
            else
              DrawCheck(FGlyphUnChecked, Rect(ARect.Left + 2 + GetTreeMoveBy(True, False, nil), ARect.Top, ARect.Right,
                ARect.Top + (ARect.Bottom - ARect.Top) div CurrLineCount));

          // Если необходимо показывать линии, то производим их перерисовку
          if FShowLines and GetDetailLines(DrawColumn.FieldName, ShowingLines) then
          begin
            // Удаляем формат, т.к. он не нужен
            if (ShowingLines.Count > 0) and (Pos('format ', ShowingLines[0]) > 0) then
              ShowingLines.Delete(0);

            for K := 0 to ShowingLines.Count - 1 do
            begin
              // Пропускаем формат главного поля

              if Pos('%s', ShowingLines[K]) > 0 then
              begin
                Fld := Copy(ShowingLines[K], 1, Pos(' ', ShowingLines[K]) - 1);
                Fmt := Copy(ShowingLines[K], Pos(' ', ShowingLines[K]) + 1,  Length(ShowingLines[K]));

                Value := Format(
                  Fmt,
                  [DataLink.DataSet.FieldByName(Fld).DisplayText]);
              end else
                Value := DataLink.DataSet.FieldByName(ShowingLines[K]).DisplayText;

                WriteText(Self.Canvas,
                  Rect(ARect.Left, ARect.Top + GetDefaultRowHeight * (K + 1), ARect.Right, ARect.Bottom),
                  2 + GetTreeMoveBy(True, False, nil), 2, Value, DrawColumn.Alignment,
                  UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment));
            end;
          end;  
        end;

        if Columns.State = csDefault then
          DrawDataCell(ARect, DrawColumn.Field, AState);

        DrawColumnCell(ARect, ACol, DrawColumn, AState);
      finally
        if not SkipActiveRecord then DataLink.ActiveRecord := OldActive;
      end;

      // Ресуем Focus
      if DefaultDrawing and (gdSelected in AState)
        and ((dgAlwaysShowSelection in Options) or Focused)
        and not (csDesigning in ComponentState)
        and not (dgRowSelect in Options)
        and (UpdateLock = 0)
        and (ValidParentForm(Self).ActiveControl = Self)
      then
        Windows.DrawFocusRect(Handle, ARect);
    end;
  end;
end;

{
  По скроллингу производим перерисовку текста.
}

procedure TmmDBGrid.Scroll(Distance: Integer);
begin
  inherited Scroll(Distance);
  if FStriped and (Distance <> 0) then Invalidate;
end;

{
  После установки значений всех свойств производим свои установки.
}

procedure TmmDBGrid.Loaded;
begin
  inherited Loaded;

  // Данные установки производим только в режиме запуска программы
  if not (csDesigning in ComponentState) then
  begin
    OldOnColumnMoved := OnColumnMoved;
    OnColumnMoved := DoOnColumnMoved;

    CanUpdateScale := True;

    // Если меню не присвоено.
    if PopupMenu = nil then
    begin
      if FPopupMenu = nil then FPopupMenu := TPopupMenu.Create(Self);
      inherited PopupMenu := FPopupMenu;
    end;

    DeletePopupSettings(PopupMenu.Items);
    MakePopupSettings(PopupMenu, False);
  end;

  FUltraChanges := False;
end;

{
  По нажатию кнопки мыши производим свои действия.
}

procedure TmmDBGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  C: TGridCoord;
  R: TRect;
  F: TField;
  CheckField: TCheckField;
  Checked: Boolean;
  Index: Integer;
  OldActive: Integer;
begin
  CheckField := nil;
  Checked := False;

  // Если нажата левая кнопка мыши.
  if Button = mbLeft then
  begin
    // Получаем координаты курсора в таблице, rectangle ячейки, поле
    C := MouseCoord(X, Y);
    R := CellRect(C.X, C.Y);
    F := GetColField(C.X - Integer(dgIndicator in Options));

    // Если включен режим показа CheckBox-ов
    if FShowCheckBoxes and (F <> nil) and (C.Y - Integer(dgTitles in Options) >= 0) then
    begin
      CheckField := GetCheckFieldByName(FChecks, F.FieldName);

      // Если существует CheckBox объект по данному полю
      if CheckField <> nil then
      begin
        // Получаем необходимую запись для установления состояния CheckBox-а
        OldActive := DataLink.ActiveRecord;
        try
          DataLink.ActiveRecord := C.Y - Integer(dgTitles in Options);

          // Узнаем состояние CheckBox-а
          Checked := DoOnFindCheck(CheckField, DataLink.DataSet.
            FieldByName(CheckField.CheckField).AsString, Index);

          R.Left := R.Left + 2 + GetTreeMoveBy(False, False, nil); 

          if Checked then
            R.Right := R.Left + FGlyphChecked.Width
          else
            R.Right := R.Left + FGlyphUnChecked.Width;

          R.Top := R.Top;
          R.Bottom := R.Top + (R.Bottom - R.Top) div CurrLineCount;
        finally
          // Возвращаем курсор на ранее установленную запись
          DataLink.ActiveRecord := OldActive;
        end;

        if not IsInRect(R, X, Y) then CheckField := nil;
      end;
    end;
  end;

  inherited MouseDown(Button, Shift, X, Y);

  // Если режим отображения CheckBox-ов и найдено поле для CheckBox-ов
  if FShowCheckBoxes and (CheckField <> nil) then
  begin
    HideEditor;

    // Добавляем либо удаляем запись из списка
    if Checked then
      DoOnDeleteCheck(CheckField, Index)
    else begin
      DoOnAddCheck(CheckField, DataLink.DataSet.FieldByName(CheckField.CheckField).AsString);
    end;

    InvalidateCell(Col, Row);
  end;

  // Установки, необходимые для растягивания
  if (CurrLine >= 0) and (CurrLine <= ColCount - 1) and not
    (csDesigning in ComponentState)
  then
    OldColWidth := ColWidths[CurrLine];
end;

{
  Двойной счелчек мыши! Производим установку нового размера.
}

procedure TmmDBGrid.DblClick;
var
  C: TColumn;
  D: TGridCoord;
  I: Integer;
  List: TStringList;
  F: TField;
  ASC: Boolean;
  CanSort: Boolean;
  SortText: String;
  FieldSelected: String;
begin
  if not (csDesigning in ComponentState) then
  begin

    if Sizing(HitTest.X, HitTest.Y) and
      (CurrLine >= 0) and (CurrLine <= ColCount - 1) then
    begin
      C := Columns[CurrLine - Integer(dgIndicator in Options)];

      if (C <> nil) and (C.Field <> nil) then
      begin
        // Если есть колонка и по ней поле!
        with Canvas do
        begin
          Font := C.Font;
          List := ShowChecksByName[C.Field.FieldName];

          if List <> nil then
          begin
            F := DataLink.DataSet.FindField(CheckFieldByShowField[C.Field.FieldName]);

            if (F <> nil) and (List.IndexOf(F.DisplayText) >= 0) then
              I := FGlyphChecked.Width
            else
              I := FGlyphUnChecked.Width;
          end else
            I := 0;

          I := I + TextWidth(C.Field.DisplayText) + GetTreeMoveBy(False, True, C.Field);

          // Если размер меньше, чем размер заглавия, то берем размер заглавия
          Font := C.Title.Font;
          if I < TextWidth(C.Title.Caption) then I := TextWidth(C.Title.Caption);
        end;

        ColWidths[CurrLine] := I + 4;
      end;
    end else begin
      D := MouseCoord(HitTest.X, HitTest.Y);

      if (D.Y = 0) and (D.X > Integer(dgIndicator in Options) - 1) then
      begin
        C := Columns[D.X - Integer(dgIndicator in Options)];

        if FUseSorting and (C <> nil) and (C.Field <> nil) and not C.Field.Calculated then
        begin
          SortText := C.Field.FieldName;
          FieldSelected := C.Field.FieldName;

          CanSort :=
            not Assigned(FSortEvent)
              or
            (
              Assigned(FSortEvent)
                and
              FSortEvent(Self, C.Field, SortText)
            );

          if CanSort then
          begin
            if IsFieldInOrderBy(SortText,  ASC) then
              InsertFieldOrderBy(SortText, not ASC)
            else
              InsertFieldOrderBy(SortText, True);
          end;

          SelectedField := DataSource.DataSet.FieldByName(FieldSelected);
        end;
      end;
    end;
  end;

  inherited DblClick;
end;

{
  По изменению размеров колонок производим свои действия.
}

procedure TmmDBGrid.ColWidthsChanged;
var
  MinWidth, MaxWidth: Integer;
  CurrWidth, NextWidth: Integer;
  NextMinWidth, NextMaxWidth: Integer;
  CurrOption, NextOption: TFieldOption;
begin
  // Проверка загрузки базы данных после загрузки самой компоненты
  if (DataLink <> nil) and (DataLink.Active) and CanUpdateScale and not
    (csDesigning in ComponentState) then
  begin
    // Есть возможность случайного неустановления размеров (TQuery),
    // следовательно, делаем это вручную.
    if CurrLine < 0 then
    begin
      inherited ColWidthsChanged;
      if FScaleColumns then SetBounds(Left, Top, Width, Height);
      Exit;
    // При растягивании запрещаем изменение последней колонки
    end else if FScaleColumns and (CurrLine = ColCount - 1) then
    begin
      ColWidths[CurrLine] := OldColWidth;
      inherited ColWidthsChanged;
      Exit;
    end;

    // Получаем установки для данной колонки
    CurrOption := FindFieldOption(Columns[CurrLine - Integer(dgIndicator in Options)].FieldName);
    // Получаем установки для следующей колонки

    if FScaleColumns then
      NextOption := FindFieldOption(Columns[CurrLine + 1 - Integer(dgIndicator in Options)].FieldName)
    else
      NextOption := nil;

    // Если существуют для данной колонки установки
    if CurrOption <> nil then
    begin
      // Если колонку нельзя растягивать, то пропускаем ее
      if not CurrOption.FScaled then
      begin
        ColWidths[CurrLine] := OldColWidth;
        inherited ColWidthsChanged;
        Exit;
      end;

      // Устанавливаем минимальные и максимальные размеры
      MinWidth := CountWidthByChar(Canvas, Self, CurrOption.MinWidth,
        Columns[CurrLine - Integer(dgIndicator in Options)].Font);
      MaxWidth := CountWidthByChar(Canvas, Self, CurrOption.MaxWidth,
        Columns[CurrLine - Integer(dgIndicator in Options)].Font);

      if MinWidth < FMinColWidth then MinWidth := FMinColWidth;
    end else begin // Если их нет
      MinWidth := FMinColWidth;
      MaxWidth := -1;
    end;

    // Если существуют для следующей колонки установки
    if NextOption <> nil then
    begin
      // Если колонку нельзя растягивать, то пропускаем ее
      if not NextOption.FScaled then
      begin
        ColWidths[CurrLine] := OldColWidth;
        inherited ColWidthsChanged;
        Exit;
      end;

      // Устанавливаем минимальные и максимальные размеры
      NextMinWidth := CountWidthByChar(Canvas, Self, NextOption.MinWidth,
        Columns[CurrLine - Integer(dgIndicator in Options)].Font);
      NextMaxWidth := CountWidthByChar(Canvas, Self, NextOption.MaxWidth,
        Columns[CurrLine - Integer(dgIndicator in Options)].Font);

      if NextMinWidth < FMinColWidth then NextMinWidth := FMinColWidth;
    end else begin // Если их нет
      NextMinWidth := FMinColWidth;
      NextMaxWidth := -1;
    end;

    // Запрещаем проверку изменений размеров колонок
    CanUpdateScale := False;

    // Устанавливаем первоначальные размеры текущей и следующей колонок
    CurrWidth := ColWidths[CurrLine];
    if FScaleColumns then
      NextWidth := ColWidths[CurrLine + 1]
    else
      NextWidth := -1;


    // Если колонка больше максимального размера
    if (CurrWidth > MaxWidth) and (MaxWidth <> -1) then
    begin
      if FScaleColumns then NextWidth := NextWidth - (MaxWidth - OldColWidth);
      CurrWidth := MaxWidth;
    // Если колонка меньше минимального размера
    end else if CurrWidth < MinWidth then
    begin
      if FScaleColumns then NextWidth := NextWidth - (MinWidth - OldColWidth);
      CurrWidth := MinWidth;
    end else
      NextWidth := NextWidth + OldColWidth - CurrWidth;

    if ((dgIndicator in Options) and (CurrLine <> 0)) or
      not (dgIndicator in Options)
    then
      // Если следующая колонка больше максимального размера
      if FScaleColumns and (NextWidth > NextMaxWidth) and (NextMaxWidth <> -1) then
      begin
        CurrWidth := CurrWidth + (NextWidth - NextMaxWidth);
        NextWidth := NextWidth - (NextWidth - NextMaxWidth);
      // Если следующая колонка меньше минимального размера
      end else if FScaleColumns and (NextWidth < NextMinWidth) then
      begin
        CurrWidth := CurrWidth - (NextMinWidth - NextWidth);
        NextWidth := NextWidth + (NextMinWidth - NextWidth);
      end;

    ColWidths[CurrLine] := CurrWidth;
    if FScaleColumns then ColWidths[CurrLine + 1] := NextWidth;

    // Разрешаем проверку изменений размеров колонок
    CanUpdateScale := True;
  end;

  inherited ColWidthsChanged;

  OldColumnsCount := Columns.Count;
end;

{
  По изменению размера высоты ячейки производим устанвку ее самостоятельно.
}

procedure TmmDBGrid.RowHeightsChanged;
var
  OldHeight: Integer;
begin
  if FShowLines then
  begin
    // Сохраняем размер заглавий
    if dgTitles in Options then
      OldHeight := RowHeights[0]
    else
      OldHeight := 0;

    // Устанавливаем свой размер
    if DefaultRowHeight <> GetDefaultRowHeight * FLineCount then
    begin
      DefaultRowHeight := GetDefaultRowHeight * FLineCount;
      if dgTitles in Options then RowHeights[0] := OldHeight;
    end;
  end; 

  inherited RowHeightsChanged;
end;

{
  Устанавливаю какую колонку пользователь будет перемещать.
}

procedure TmmDBGrid.CalcSizingState(X, Y: Integer; var State: TGridState;
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
  Устанавливаются атрибуты колонок.
}

procedure TmmDBGrid.SetColumnAttributes;
begin
  inherited SetColumnAttributes;

  LineCount := GetMaxLineCount;

  // Если пользователь присвоил одному из полей Visible = False, то необходимо
  // произвости перерасчет размеров.
  if Columns.Count < OldColumnsCount then SetBounds(Left, Top, Width, Height);
end;

{
  По закрытию таблички производим свои действия.
}

procedure TmmDBGrid.LinkActive(Value: Boolean);
var
  OldScaleColumns: Boolean;
begin
  OldScaleColumns := FScaleColumns;
  FScaleColumns := False;

  inherited LinkActive(Value);

  ScaleColumns := OldScaleColumns;

  // Создаем данные для отображения CheckBox-ов
  if Value and FShowCheckBoxes and (FChecks.Count = 0) then CreateCheckData;
end;

{
  Возвращает текущее количество строк по колонке
}

function TmmDBGrid.CurrLineCount: Integer;
begin
  if FShowLines then
    Result := FLineCount
  else
    Result := 1;
end;

{
  Возвращает отсуп слева для дерева (TmmDBGridTree).
}

function TmmDBGrid.GetTreeMoveBy(WhileDrawing: Boolean; CheckField: Boolean; F: TField): Integer;
begin
  Result := 0;
end;

{
  Активируем диалоговое окно поиска.
}

procedure TmmDBGrid.DoOnSearch(Sender: TObject);
begin
  if (DataLink <> nil) and DataLink.Active and Assigned(SelectedField) then
  begin
    FSearch.CustomSearch := True;
    FSearch.Grid := Self;
    FSearch.DataField := '';
    FSearch.DataSource := nil;
    FSearch.DataSource := DataSource;
    FSearch.DataField := SelectedField.FieldName;
    FSearch.ColorDialog := FColorDialogs;
    FSearch.ExecuteDialog;
  end;
end;

{
  Делаем какие-либо действия после добавления нового элемента.
}

procedure TmmDBGrid.DoOnAddCheck(C: TCheckField; S: String);
begin
  C.AddCheck(S);
  if Assigned(FOnCheck) then
    FOnCheck(S, True);
end;

{
  Производим удаление элемента.
}

procedure TmmDBGrid.DoOnDeleteCheck(C: TCheckField; Index: Integer);
var
  S: String;
begin
  S := C.Checks[Index];
  C.Checks.Delete(Index);
  if Assigned(FOnCheck) then
    FOnCheck(S, False);
end;

{
  Производит поиск эелемента.
}

function TmmDBGrid.DoOnFindCheck(C: TCheckField; ACheck: String; var Index: Integer): Boolean;
begin
  Result := C.FindCheck(ACheck, Index);
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Устанавливаем цвет первой полосы.
}

procedure TmmDBGrid.SetStripeOne(const Value: TColor);
begin
  if FStripeOne <> Value then
  begin
    FStripeOne := Value;
    Invalidate;
  end;  
end;

{
  Устанавливаем цвет второй полосы.
}

procedure TmmDBGrid.SetStripeTwo(const Value: TColor);
begin
  if FStripeTwo <> Value then
  begin
    FStripeTwo := Value;
    Invalidate;
  end;
end;

{
  Устанавливаем флаг рисование полосатых строк в таблице.
}

procedure TmmDBGrid.SetStriped(const Value: Boolean);
begin
  if FStriped <> Value then
  begin
    FStriped := Value;
    Invalidate;
  end;
end;

{
  Устанавливаем цвет выделенной ячейки таблицы.
}

procedure TmmDBGrid.SetColorSelected(const Value: TColor);
begin
  if FColorSelected <> Value then
  begin
    FColorSelected := Value;
    Invalidate;
  end;  
end;

{
  Устанавливаем PopupMenu.
}

procedure TmmDBGrid.SetPopup(const Value: TPopupMenu);
begin
  // Если присваивается новое значение.
  if Assigned(Value) then
  begin
    // Если было создано собственное меню, то его необходимо удалить.
    if Assigned(FPopupMenu) then
    begin
      FPopupMenu.Free;
      FPopupMenu := nil;
    end;

    inherited PopupMenu := Value;
  end else begin
    // Если же меню полностью убирается

    if not Assigned(FPopupMenu) then
    begin
      FPopupMenu := TPopupMenu.Create(Self);
      MakePopupSettings(FPopupMenu, False);
    end;

    inherited PopupMenu := FPopupMenu;
  end;
end;

{
  Устанавливаем вид подстановки меню в общее меню.
}

procedure TmmDBGrid.SetPopupMenuKind(const Value: TPopupMenuKind);
begin
  FPopupMenuKind := Value;
end;

{
  Использовать ли масштабирование колонок или нет.
}

procedure TmmDBGrid.SetScaleColumns(const Value: Boolean);
begin
  if FScaleColumns <> Value then
  begin
    FScaleColumns := Value;
    
    if FScaleColumns and not (csDesigning in ComponentState) then 
      SetBounds(Left, Top, Width, Height);
  end;  
end;

{
  Устанавливам флаг условного форматирования.
}

procedure TmmDBGrid.SetConditionalFormatting(const Value: Boolean);
begin
  if Value <> FConditionalFormatting then
  begin
    FConditionalFormatting := Value;
    Invalidate;
  end;
end;

{
  Устанавливает количество строк в одной ячейке.
}

procedure TmmDBGrid.SetLineCount(const Value: Integer);
begin
  if Value <> FLineCount then
  begin
    FLineCount := Value;

    if FLineCount < 1 then FLineCount := 1;

    if FShowLines then
    begin
      RowHeightsChanged;
      LayoutChanged;
    end;  
  end;
end;

{
  Устаналвиает поля по полю...
}

procedure TmmDBGrid.SetLineFields(const Value: TStringList);
begin
  FLineFields.Assign(Value);
  LineCount := GetMaxLineCount;
  Invalidate;
end;

{
  Показывать ли дополнительные линии или нет.
}

procedure TmmDBGrid.SetShowLines(const Value: Boolean);
var
  OldHeight: Integer;
begin
  if FShowLines <> Value then
  begin
    FShowLines := Value;

    if FShowLines then
      RowHeightsChanged
    else begin
      if dgTitles in Options then
        OldHeight := RowHeights[0]
      else
        OldHeight := 0;

      DefaultRowHeight := GetDefaultRowHeight;
      if dgTitles in Options then RowHeights[0] := OldHeight;
    end;

    LayoutChanged;
    Invalidate;
  end;
end;

{
  Устанавливает флаг отображения CheckBox-ов.
}

procedure TmmDBGrid.SetShowCheckBoxes(const Value: Boolean);
begin
  if FShowCheckBoxes <> Value then
  begin
    FShowCheckBoxes := Value;

    if DataLink.Active and FShowCheckBoxes then
    begin
      if FChecks.Count = 0 then CreateCheckData;
      Invalidate;
    end;

    Invalidate;
  end;
end;

{
  Устанавливает поля, по которым дубут отображаться CheckBox-ы.
  Формат:
  Key - ключ поля данных, которые будут храниться в списке
  Name - ключ поля, где будут отображаться CheckBox-ы
}

procedure TmmDBGrid.SetCheckFields(const Value: TStringList);
begin
  FCheckFields.Assign(Value);

  if DataLink.Active and FShowCheckBoxes then
  begin
    CreateCheckData;
    Invalidate;
  end else
    FChecks.Clear;
end;

{
  Устанавливает рисунок CheckBox-а выбранного.
}

procedure TmmDBGrid.SetGlyphChecked(const Value: TBitmap);
begin
  if Value <> nil then
    FGlyphChecked.Assign(Value)
  else
    LoadCheckBoxBitmap(FGlyphChecked, TRUE);
end;

{
  Устанадивает рисунок CheckBox-а не выбранного.
}

procedure TmmDBGrid.SetGlyphUnChecked(const Value: TBitmap);
begin
  if Value <> nil then
    FGlyphUnchecked.Assign(Value)
  else
    LoadCheckBoxBitmap(FGlyphUnchecked, FALSE);
end;

{
  Устанавливается флаг использования режима сортировки пользователя.
}

procedure TmmDBGrid.SetUseSorting(const Value: Boolean);
begin
  if FUseSorting <> Value then
  begin
    FUseSorting := Value;
    Invalidate;
  end;
end;

{
  Возвращаем PopupMenu.
}

function TmmDBGrid.GetPopup: TPopupMenu;
begin
  Result := inherited PopupMenu;
end;

{
  Вовзращает список выбранных элементов по названию поля (для CheckBox).
}

function TmmDBGrid.GetShowChecksByName(Value: String): TStringList;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FChecks.Count - 1 do
    if AnsiCompareText(TCheckField(FChecks[I]).ShowField, Value) = 0 then
    begin
      Result := TCheckField(FChecks[I]).Checks;
      Break;
    end;
end;

{
  Возвращает поле данных по отображаемому полю (для CheckBox-ов).
}

function TmmDBGrid.GetCheckFieldByShowField(Value: String): String;
var
  I: Integer;
begin
  Result := '';

  for I := 0 to FChecks.Count - 1 do
    if AnsiCompareText(TCheckField(FChecks[I]).ShowField, Value) = 0 then
    begin
      Result := TCheckField(FChecks[I]).CheckField;
      Break;
    end;
end;

{
  По нажатию правой клавиши мыши производим подстановку в меню
  собственных изменений.
}

procedure TmmDBGrid.WMRButtonDown(var Message: TWMLButtonDown);
var
  C: Integer;
begin
  inherited;

  // Вычисляем координаты выбранной колонки
  C := MouseCoord(Message.XPos, {Message.YPos}1).X - Integer(dgIndicator in Options);

  if C >= 0 then
    PopupColumn := Columns[C]
  else
    PopupColumn := nil;

  // Если выбрана одна из колонок таблицы, то работаем с ее меню.
  if (PopupColumn <> nil) and (PopupColumn.PopupMenu <> nil) then
  begin
    OldOnPopup := PopupColumn.PopupMenu.OnPopup;
    PopupColumn.PopupMenu.OnPopup := DoOnPopupMenu;
  // Если не выбрана ни одна из колонок, то работаем с главным меню компоненты.
  end else begin
    if (PopupMenu = nil) and (FPopupMenu = nil) then
    begin
      FPopupMenu := TPopupMenu.Create(Self);
      MakePopupSettings(FPopupMenu, False);

      inherited PopupMenu := FPopupMenu;
    end;

    OldOnPopup := PopupMenu.OnPopup;
    PopupMenu.OnPopup := DoOnPopupMenu;
  end;
end;

procedure TmmDBGrid.WMChar(var Message: TWMChar);
var
  CheckField: TCheckField;
  Index: Integer;
begin
  if (Message.CharCode = VK_SPACE) and FShowCheckBoxes and (SelectedField <> nil) and
    ((InplaceEditor = nil) or ((InplaceEditor <> nil) and not InplaceEditor.Visible)) then
  begin
    CheckField := GetCheckFieldByName(FChecks, SelectedField.FieldName);

    // Если существует CheckBox объект по данному полю
    if CheckField <> nil then
    begin
      if DoOnFindCheck(CheckField, DataLink.DataSet.FieldByName(CheckField.CheckField).AsString, Index) then
        DoOnDeleteCheck(CheckField, Index)
      else begin
        DoOnAddCheck(CheckField, DataLink.DataSet.FieldByName(CheckField.CheckField).AsString);
      end;

      InvalidateCell(Col, Row);
    end;
  end else
    inherited;
end;

{
  По активизации меню производим свои действия.
}

procedure TmmDBGrid.DoOnPopupMenu(Sender: TObject);
begin
  // Если меню по отдельной колонке
  if PopupColumn <> nil then
  begin
    // Если в колонке есть свое собственное меню
    if PopupColumn.PopupMenu <> nil then
    begin
      // Удаляем ранее подставленное меню
      DeletePopupSettings(PopupColumn.PopupMenu.Items);
      // Добавляем новые пункты меню
      MakePopupSettings(PopupColumn.PopupMenu, True);

    // Если же его нет
    end else begin
      // Удаляем ранее подставленное меню
      DeletePopupSettings(PopupMenu.Items);
      // Добавляем новые пункты меню
      MakePopupSettings(PopupMenu, True);
    end;

  // Если меню общее
  end else begin
    // Удаляем ранее подставленное меню
    DeletePopupSettings(PopupMenu.Items);
    // Добавляем новые пункты меню
    MakePopupSettings(PopupMenu, False);
  end;

  // Вызываем Event пользователя компонентой
  if Assigned(OldOnPopup) then OldOnPopup(Sender);

  // Возвращаем Event пользователя обратно
  if (PopupColumn <> nil) and (PopupColumn.PopupMenu <> nil) then
    PopupColumn.PopupMenu.OnPopup := OldOnPopup
  else
    PopupMenu.OnPopup := OldOnPopup;

  OldOnPopup := nil;
end;

{
  По выбору позиции "Шрифт таблицы" производим активацию диалога выбора
  шрифта. Если новый шрифт получен, то подставляем его в таблицу.
}

procedure TmmDBGrid.DoOnTableFont(Sender: TObject);
var
  I: Integer;
begin
  FontDlg := TFontDialog.Create(Self);
  FontDlg.Font.Assign(Font);

  try
    if FontDlg.Execute then
    begin
      Font.Assign(FontDlg.Font);

      for I := 0 to Columns.Count - 1 do
        Columns[I].Font := Font;
    end;
  finally
    FontDlg.Free;
  end;
end;

{
  По выбору позиции "Шрифт заглавий таблицы" производим активацию диалога выбора
  шрифта. Если новый шрифт получен, то подставляем его в таблицу.
}

procedure TmmDBGrid.DoOnTableTitleFont(Sender: TObject);
var
  I: Integer;
begin
  FontDlg := TFontDialog.Create(Self);
  FontDlg.Font.Assign(TitleFont);

  try
    if FontDlg.Execute then
    begin
      TitleFont.Assign(FontDlg.Font);

      for I := 0 to Columns.Count - 1 do
        Columns[I].Title.Font := TitleFont;
    end;
  finally
    FontDlg.Free;
  end;
end;

{
  По выбору позиции "Шрифт" производим активацию диалога выбора
  шрифта. Если новый шрифт получен, то подставляем его в колонку.
}

procedure TmmDBGrid.DoOnColFont(Sender: TObject);
begin
  FontDlg := TFontDialog.Create(Self);

  if Sender is TMenuItem then
    FontDlg.Font.Assign(PopupColumn.Font);

  try
    if FontDlg.Execute then PopupColumn.Font.Assign(FontDlg.Font);
  finally
    FontDlg.Free;
  end;
end;

{
  По выбору позиции "Шрифт" производим активацию диалога выбора
  шрифта. Если новый шрифт получен, то подставляем его в название колонки.
}

procedure TmmDBGrid.DoOnColTitleFont(Sender: TObject);
begin
  FontDlg := TFontDialog.Create(Self);

  if Sender is TMenuItem then
    FontDlg.Font.Assign(PopupColumn.Title.Font);

  try
    if FontDlg.Execute then PopupColumn.Title.Font.Assign(FontDlg.Font);
  finally
    FontDlg.Free;
  end;
end;

{
  По выбору позиции "Цвет таблицы" производим активацию диалога выбора
  цвета. Если новый цвет получен, то подставляем его в таблицу.
}

procedure TmmDBGrid.DoOnTableColor(Sender: TObject);
var
  I: Integer;
begin
  ColorDlg := TColorDialog.Create(Self);
  ColorDlg.Color := Color;

  try
    if ColorDlg.Execute then
    begin
      Color := ColorDlg.Color;

      for I := 0 to Columns.Count - 1 do
        Columns[I].Color := Color;
    end;  
  finally
    ColorDlg.Free;
  end;
end;

{
  Устанавливаем цвет выделенной записи.
}

procedure TmmDBGrid.DoOnSelectedColor(Sender: TObject);
begin
  ColorDlg := TColorDialog.Create(Self);
  ColorDlg.Color := FColorSelected;

  try
    if ColorDlg.Execute then ColorSelected := ColorDlg.Color;
  finally
    ColorDlg.Free;
  end;
end;

{
  По выбору позиции "Цвет заглавий таблицы" производим активацию диалога выбора
  цвета. Если новый цвет получен, то подставляем его в таблицу.
}

procedure TmmDBGrid.DoOnTableTitleColor(Sender: TObject);
var
  I: Integer;
begin
  ColorDlg := TColorDialog.Create(Self);
  ColorDlg.Color := FixedColor;

  try
    if ColorDlg.Execute then
    begin
      FixedColor := ColorDlg.Color;

      for I := 0 to Columns.Count - 1 do
        Columns[I].Title.Color := FixedColor;
    end;  
  finally
    ColorDlg.Free;
  end;
end;

{
  По выбору позиции "Цвет" производим активацию диалога выбора
  цвета. Если новый цвет получен, то подставляем его в нужную колонку.
}

procedure TmmDBGrid.DoOnColColor(Sender: TObject);
begin
  ColorDlg := TColorDialog.Create(Self);
  ColorDlg.Color := PopupColumn.Color;

  try
    if ColorDlg.Execute then PopupColumn.Color := ColorDlg.Color;
  finally
    ColorDlg.Free;
  end;
end;

{
  По выбору позиции "Цвет" производим активацию диалога выбора
  цвета. Если новый цвет получен, то подставляем его в нужное название колонки.
}

procedure TmmDBGrid.DoOnColTitleColor(Sender: TObject);
begin
  ColorDlg := TColorDialog.Create(Self);
  ColorDlg.Color := PopupColumn.Title.Color;

  try
    if ColorDlg.Execute then PopupColumn.Title.Color := ColorDlg.Color;
  finally
    ColorDlg.Free;
  end;
end;

{
  Устанавливаем цвет первой полосы.
}

procedure TmmDBGrid.DoOnFirstStripeColor(Sender: TObject);
begin
  ColorDlg := TColorDialog.Create(Self);
  ColorDlg.Color := FStripeOne;

  try
    if ColorDlg.Execute then StripeOne := ColorDlg.Color;
  finally
    ColorDlg.Free;
  end;
end;

{
  Устанавливаем цвет второй полосы.
}

procedure TmmDBGrid.DoOnSecondStripeColor(Sender: TObject);
begin
  ColorDlg := TColorDialog.Create(Self);
  ColorDlg.Color := FStripeTwo;

  try
    if ColorDlg.Execute then StripeTwo := ColorDlg.Color;
  finally
    ColorDlg.Free;
  end;
end;

{
  По выбору позиции "Выравнивание" и выбору соответствующего его вида
  приоизводим установки в таблице.
}

procedure TmmDBGrid.DoOnColAlign(Sender: TObject);
begin
  if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('Выравнивать по центру')) = 0 then
    PopupColumn.Alignment := taCenter
  else if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('Выравнивать по левому краю')) = 0 then
    PopupColumn.Alignment := taLeftJustify
  else if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('Выравнивать по правому краю')) = 0 then
    PopupColumn.Alignment := taRightJustify;

  (Sender as TMenuItem).Checked := True;
end;

{
  По выбору позиции "Выравнивание" и выбору соответствующего его вида
  приоизводим установки для имени колонки в таблице.
}

procedure TmmDBGrid.DoOnColTitleAlign(Sender: TObject);
begin
  if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('Выравнивать по центру')) = 0 then
    PopupColumn.Title.Alignment := taCenter
  else if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('Выравнивать по левому краю')) = 0 then
    PopupColumn.Title.Alignment := taLeftJustify
  else if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('Выравнивать по правому краю')) = 0 then
    PopupColumn.Title.Alignment := taRightJustify;

  (Sender as TMenuItem).Checked := True;
end;

{
  Использовать полосы для рисования или нет?
}

procedure TmmDBGrid.DoOnCheckStriped(Sender: TObject);
begin
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  Striped := (Sender as TMenuItem).Checked;
end;

{
  Использовать условное форматирование или нет.
}

procedure TmmDBGrid.DoOnCheckConditionalFormatting(Sender: TObject);
begin
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  ConditionalFormatting := (Sender as TMenuItem).Checked;
end;

{
  Устанавливаем или отменяем растягивание колонок.
}

procedure TmmDBGrid.DoOnCheckScaleColumns(Sender: TObject);
begin
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  ScaleColumns := (Sender as TMenuItem).Checked;
end;

{
  Производим создание условных форматов.
}

procedure TmmDBGrid.DoOnCondition(Sender: TObject);
begin
  with TfrmConditionalFormatting.Create(Self) do
  try
    Grid := Self;
    OldConditions := FConditions;
    Color := FColorDialogs;

    if ShowModal = mrOk then
    begin
      PrepareConditions;
      Self.Invalidate;
    end;
  finally
    Free;
  end;
end;

{
  Производим выбор необходимых колонок для визуального отображения.
}

procedure TmmDBGrid.DoOnChooseColumns(Sender: TObject);
var
  btnOk, btnCancel: TmBitButton;
  clbFields: TCheckListBox;
  I: Integer;

  // Производит поиск колонки в Grid-е по указателю на поле.
  function FindColumn(G: TDBGrid; F: TField; var C: TColumn): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    C := nil;
    if F = nil then Exit;

    for I := 0 to G.Columns.Count - 1 do
      if G.Columns[I].Field = F then
      begin
        Result := True;
        C := G.Columns[I];
        Break;
      end;
  end;

begin
  with TForm.Create(Self) do
  try
    Width := 300;
    Height := 300; {80}
    Caption := TranslateText('Отображаемые колонки:');
    BorderStyle := bsDialog;
    Position := poScreenCenter;

    Color := FColorDialogs;

    clbFields := TCheckListBox.Create(Self);
    clbFields.Color := FColorDialogs;
    clbFields.ParentCtl3D := False;
    clbFields.Ctl3D := False;
    clbFields.Left := 4;
    clbFields.Top := 4;
    clbFields.Width := 286;
    clbFields.Height := 240;

    btnOk := TmBitButton.Create(Self);
    btnOk.Left := 4;
    btnOk.Top := 250;
    btnOk.Width := 100;
    btnOk.Height := 20;
    btnOk.Caption := TranslateText('&Готово');
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;

    btnCancel := TmBitButton.Create(Self);
    btnCancel.Left := 114;
    btnCancel.Top := 250;
    btnCancel.Width := 100;
    btnCancel.Height := 20;
    btnCancel.Caption := TranslateText('&Отменить');
    btnCancel.ModalResult := mrCancel;
    btnCancel.Cancel := True;

    InsertControl(clbFields);
    InsertControl(btnOk);
    InsertControl(btnCancel);

    for I := 0 to DataSource.DataSet.Fields.Count - 1 do
      if not (DataSource.DataSet.Fields[I].DataType in [ftUnknown, ftBCD,
        ftBytes, ftVarBytes, ftMemo, ftGraphic,
        ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
        ftADT, ftArray, ftReference, ftDataSet]) then
      begin
        clbFields.Items.Add(DataSource.DataSet.Fields[I].DisplayLabel);
        clbFields.Items.Objects[clbFields.Items.Count - 1] := Pointer(I);

        if DataSource.DataSet.Fields[I].Visible then
          clbFields.State[clbFields.Items.Count - 1] := cbChecked;
      end;

    if ShowModal = mrOk then
    begin
      for I := 0 to clbFields.Items.Count - 1 do
        DataSource.DataSet.Fields[Integer(clbFields.Items.Objects[I])].Visible :=
          clbFields.State[I] = cbChecked;
    end;
  finally
    Free;
  end;
end;

{
  Пролизводим выбор дополнительных видимых элементов в ячейке по колонке.
}

procedure TmmDBGrid.DoOnChooseLines(Sender: TObject);
begin
  with TfrmDetail.Create(Self) do
  try
    Grid := Self;
    DetailField := PopupColumn.Field.FieldName;
    GetDetailLines(PopupColumn.Field.FieldName, ShowingLines);
    Details := ShowingLines;
    if ShowModal = mrOk then
    begin
      SetDetailLines(PopupColumn.Field.FieldName, ShowingLines);
      LineCount := GetMaxLineCount;

      FUltraChanges := True;
      Self.Invalidate;
    end;
  finally
    Free;
  end;
end;

{
  Производим установку параметра рисования дополнительной информации
  в ячейки или ее убираем.
}

procedure TmmDBGrid.DoOnShowLines(Sender: TObject);
begin
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  ShowLines := (Sender as TMenuItem).Checked;
end;

{
  По выбору позиции меню "Изменить название" вызвывается диалог запроса
  нового названия колонки и затем подставляется в таблицу.
}

procedure TmmDBGrid.DoOnNewTitle(Sender: TObject);
var
  AskTitle: TForm;
  editTitle: TEdit;
  btnOk, btnCancel: TmBitButton;
begin
  AskTitle := TForm.Create(Self);
  try
    AskTitle.Width := 300;
    AskTitle.Height := 80;
    AskTitle.Caption := TranslateText('Заглавие колонки');
    AskTitle.BorderStyle := bsDialog;
    AskTitle.Position := poScreenCenter;

    AskTitle.Color := FColorDialogs;

    editTitle := TEdit.Create(Self);
    editTitle.ParentCtl3D := False;
    editTitle.Ctl3D := False;
    editTitle.Left := 4;
    editTitle.Top := 4;
    editTitle.Width := 286;

    btnOk := TmBitButton.Create(Self);
    btnOk.Left := 4;
    btnOk.Top := 30;
    btnOk.Width := 100;
    btnOk.Height := 20;
    btnOk.Caption := TranslateText('&Готово');
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;

    btnCancel := TmBitButton.Create(Self);
    btnCancel.Left := 114;
    btnCancel.Top := 30;
    btnCancel.Width := 100;
    btnCancel.Height := 20;
    btnCancel.Caption := TranslateText('&Отменить');
    btnCancel.ModalResult := mrCancel;
    btnCancel.Cancel := True;

    AskTitle.InsertControl(editTitle);
    AskTitle.InsertControl(btnOk);
    AskTitle.InsertControl(btnCancel);

    editTitle.Text := PopupColumn.Title.Caption;

    if AskTitle.ShowModal = mrOk then
      PopupColumn.Title.Caption := editTitle.Text;
  finally
    AskTitle.Free;
  end;
end;

{
  По передвижению колонки производим свои действия.
}

procedure TmmDBGrid.DoOnColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
begin
  if not (csDesigning in ComponentState) then
  begin
    CurrLine := Integer(dgIndicator in Options);
    OldColWidth := ColWidths[CurrLine];
    if Assigned(OldOnColumnMoved) then OldOnColumnMoved(Sender, FromIndex, ToIndex);
  end;
end;

{
  Вызывает мастер установок для всей таблицы.
}

procedure TmmDBGrid.DoOnTableMaster(Sender: TObject);
begin
  with TfrmDBGridOptions.Create(Self) do
  try
    SetupGrid := Self;
    ShowModal;
  finally
    Free;
  end;
end;

{
  Производим добавление своих пунктов в меню текущего Grid-а или
  же в созданное самостоятельно меню Grid-а.
}

procedure TmmDBGrid.MakePopupSettings(MakeMenu: TPopupMenu; WithColumn: Boolean);
var
  Group, Item, CurrItem: TMenuItem;

  // Добавляем элемент группы
  function AddItem(S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := S;
    Result.Tag := TAG_ADDITIONALMENU;
    Group.Add(Result);
  end;

  // Добавляет элемент в подгруппу
  function AddSubItem(AGroup: TMenuItem; S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := S;
    Result.Tag := TAG_ADDITIONALMENU;
    AGroup.Add(Result);
  end;

begin
  if FPopupMenuKind = pmkSubMenu then // Если создается подгруппа
  begin
    Group := TMenuItem.Create(Self);
    Group.Caption := TranslateText('Установки таблицы');

    MakeMenu.Items.Add(Group);
  end else begin // Если меню дописывается в конец списка комманд
    Group := MakeMenu.Items;

    // Добавляем в конец меню линию разделения, если оно создано пользователем
    if Group.Count <> 0 then
    begin
      Item := TMenuItem.Create(Self);
      Item.Caption := '-';
      Item.Tag := TAG_ADDITIONALMENU;
      Group.Add(Item);
    end;
  end;

  Group.Tag := TAG_ADDITIONALMENU;

  // Дописываем свои собственные команды в общее меню
  AddItem(TranslateText('Мастер установок таблицы')).OnClick := DoOnTableMaster;

  Item := AddItem(TranslateText('Найти'));
  Item.ShortCut := VK_F3;
  Item.OnClick := DoOnSearch;

  AddItem('-');

  // Дописываем свои собственные команды в общее меню
  AddItem(TranslateText('Шрифт таблицы')).OnClick := DoOnTableFont;
  AddItem(TranslateText('Цвет таблицы')).OnClick := DoOnTableColor;
  AddItem(TranslateText('Шрифт заглавиий')).OnClick := DoOnTableTitleFont;
  AddItem(TranslateText('Цвет заглавий')).OnClick := DoOnTableTitleColor;
  AddItem(TranslateText('Цвет выделенной записи')).OnClick := DoOnSelectedColor;

  AddItem('-');

  // Если нет данных в таблице, то и нет смысла позволять установку полос и др.
  if (DataLink <> nil) and DataLink.Active then
  begin
    Item := AddItem(TranslateText('Использование полос'));

    CurrItem := AddSubItem(Item, TranslateText('Использовать'));
    CurrItem.Checked := FStriped;
    CurrItem.OnClick := DoOnCheckStriped;

    CurrItem := AddSubItem(Item, TranslateText('Первая полоса'));
    CurrItem.OnClick := DoOnFirstStripeColor;
    CurrItem := AddSubItem(Item, TranslateText('Вторая полоса'));
    CurrItem.OnClick := DoOnSecondStripeColor;

    Item := AddItem(TranslateText('Условное форматирование'));
    CurrItem := AddSubItem(Item, TranslateText('Использовать'));
    CurrItem.Checked := FConditionalFormatting;
    CurrItem.OnClick := DoOnCheckConditionalFormatting;

    AddSubItem(Item, TranslateText('Задать условия')).OnClick := DoOnCondition;

    AddItem('-');
    AddItem(TranslateText('Выбрать видимые колонки')).OnClick := DoOnChooseColumns;

    // added 31.07.99-01.08.99 by andreik
    AddItem('-');
    AddItem(TranslateText('Источник данных...')).OnClick := DoOnViewDataSource;
    Item := AddItem(TranslateText('Обновить данные'));
    Item.OnClick := DoOnReopenDataSet;
    Item.ShortCut := VK_F5;
    AddItem('-');
    // end of added
  end;

  Item := AddItem(TranslateText('Растягивать колонки'));
  Item.Checked := FScaleColumns;
  Item.OnClick := DoOnCheckScaleColumns;

  if LineCount > 1 then
  begin
    Item := AddItem(TranslateText('Детальное отображение'));
    Item.Checked := FShowLines;
    Item.OnClick := DoOnShowLines;
  end;

  if WithColumn then
  begin
    // Добавляем данные в подменю колонка
    Group := AddItem(TranslateText('Установки по колонке'));
    AddItem(TranslateText('Шрифт')).OnClick := DoOnColFont;

    if not FStriped then
      AddItem(TranslateText('Цвет')).OnClick := DoOnColColor;

    AddItem(TranslateText('Детальность')).OnClick := DoOnChooseLines;

    // Добавляем данныу в подменю выравнивание
    Item := Group;
    AddItem('-');

    CurrItem := AddSubItem(Item, TranslateText('Выравнивать по центру'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColAlign;
    if PopupColumn.Alignment = taCenter then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, TranslateText('Выравнивать по левому краю'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColAlign;
    if PopupColumn.Alignment = taLeftJustify then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, TranslateText('Выравнивать по правому краю'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColAlign;
    if PopupColumn.Alignment = taRightJustify then CurrItem.Checked := True;

    AddItem('-');

    // Добавляем данные в подменю заголовок
    Item := AddItem(TranslateText('Установки по заглавию'));
    AddSubItem(Item, TranslateText('Шрифт')).OnClick := DoOnColTitleFont;
    AddSubItem(Item, TranslateText('Цвет')).OnClick := DoOnColTitleColor;
    AddSubItem(Item, '-');
    AddSubItem(Item, TranslateText('Изменить заглавие')).OnClick := DoOnNewTitle;

    // Добавляем данные в подменю выравнивание
    AddSubItem(Item, '-');
    CurrItem := AddSubItem(Item, TranslateText('Выравнивать по центру'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColTitleAlign;
    if PopupColumn.Title.Alignment = taCenter then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, TranslateText('Выравнивать по левому краю'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColTitleAlign;
    if PopupColumn.Title.Alignment = taLeftJustify then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, TranslateText('Выравнивать по правому краю'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColTitleAlign;
    if PopupColumn.Title.Alignment = taRightJustify then CurrItem.Checked := True;
  end;
end;

{
  Загружает рисунки CheckBox-ов.
}

procedure TmmDBGrid.LoadCheckBoxBitmap(ABitmap: TBitmap; Checked: Boolean);
var
  B: TBitmap;
  R: TRect;
begin
  B := TBitmap.Create;

  try
    B.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_CHECKBOXES));

    ABitmap.Width := CheckBoxWidth;
    ABitmap.Height := CheckBoxHeight;

    if Checked then
      R := Rect(CheckBoxWidth, 0, CheckBoxWidth * 2, CheckBoxHeight)
    else
      R := Rect(0, 0, CheckBoxWidth, CheckBoxHeight);

    ABitmap.Canvas.CopyRect(Rect(0, 0, CheckBoxWidth, CheckBoxHeight), B.Canvas, R);
  finally
    B.Free;
  end;
end;

{
  Создаем список данных для CheckBoxов.
}

procedure TmmDBGrid.CreateCheckData;
var
  I: Integer;
begin
  // Удаляем старые данные
  for I := 0 to FChecks.Count - 1 do FChecks.Delete(0);

  // Удаляем пустые строки
  for I := FCheckFields.Count - 1 downto 0 do
    if FCheckFields[I] = '' then FCheckFields.Delete(I);

  // Создаем новые данные
  I := 0;
  while I < FCheckFields.Count - 1 do
  begin
    if (DataLink.DataSet.FindField(FCheckFields[I]) <> nil) and
      (I + 1 < FCheckFields.Count) and
      (DataLink.DataSet.FindField(FCheckFields[I + 1]) <> nil)
    then
      FChecks.Add(TCheckField.Create(FCheckFields[I], FCheckFields[I + 1]));

    Inc(I, 2);
  end;

  Invalidate;
end;

{
  Производит поиск необходимых установок для поля по его названию.
}

function TmmDBGrid.FindFieldOption(AFieldName: String): TFieldOption;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to FFieldOptions.Count - 1 do
    if AnsiCompareText(TFieldOption(FFieldOptions[I]).FFieldName, AFieldName) = 0 then
    begin
      Result := FFieldOptions[I];
      Break;
    end;
end;

{
  Возвращает количество дополнительных колонок данных по наименованию колонки.
  Формат:

  field Name - сначала задается поле, по которому идут дополнительные данные
  Имя: %s - Будет показан форматированный текст
  price - первое поле дополнительных данных
  quatity - второе поле дополнительных данных

}

function TmmDBGrid.GetDetailLines(AField: String; var FoundLines: TStringList): Boolean;
var
  I, K: Integer;
begin
  Result := False;
  FoundLines.Clear;
  I := FLineFields.IndexOf('field ' + AField);

  if I >= 0 then
  begin
    Result := True;

    if (I + 1 < FLineFields.Count) and (Pos('format ', FLineFields[I + 1]) > 0) then
    begin
      FoundLines.Add(FLineFields[I + 1]);
      Inc(I);
    end;

    for K := I + 1 to FLineFields.Count - 1 do
      if DataLink.DataSet.FindField(FLineFields[K]) <> nil then
      begin
        FoundLines.Add(FLineFields[K]);
        // Добавляем формат, если он есть
        if (K < FLineFields.Count - 1) and (Pos('%s', FLineFields[K + 1]) > 0) then
          FoundLines[FoundLines.Count - 1] := FoundLines[FoundLines.Count - 1] + ' ' + FLineFields[K + 1];
      end else if Pos('field ', FLineFields[K]) > 0 then
        Break;
  end;
end;

{
  Вовзращает формат главного поля.
}

function TmmDBGrid.GetDetailField(AField: String; var FieldFormat: String): Boolean;
var
  I, K: Integer;
begin
  Result := False;
  I := FLineFields.IndexOf('field ' + AField);

  // Если не последняя строка
  if (I >= 0) and (I + 1 < FLineFields.Count) then
  begin
    K := Pos('format ', FLineFields[I + 1]);

    // Если найдено слофо "format"
    if K > 0 then
    begin
      FieldFormat := Copy(FLineFields[I + 1], K + 7, Length(FLineFields[I + 1]));
      Result := Pos('%s', FieldFormat) > 0;
    end;
  end;
end;

{
  Устанавливает детальное отображение в список.
}

procedure TmmDBGrid.SetDetailLines(AField: String; Details: TStringList);
var
  I: Integer;

  // Удаляем старые данные
  procedure RemoveOldDetails;
  var
    K: Integer;
    DoDelete: Boolean;
  begin
    K := 0;
    DoDelete := False;

    while K < FLineFields.Count do
    begin
      if not DoDelete and (AnsiCompareText(FLineFields[K], 'field ' + AField) = 0) then
      begin
        DoDelete := True;
        FLineFields.Delete(K);
        Continue;
      end;

      if DoDelete then
      begin
        if Pos('field ', FLineFields[K]) > 0 then
          Break
        else
          FLineFields.Delete(K);
      end else if not DoDelete then
        Inc(K);
    end;
  end;

begin
  RemoveOldDetails;
  FLineFields.Add('field ' + AField);
  if (Details.Count > 0) and (Pos('format ', Details[0]) > 0) then
  begin
    FLineFields.Add(Details[0]);
    Details.Delete(0);
  end;

  for I := 0 to Details.Count - 1 do
  begin
    if Pos('%s', Details[I]) > 0 then
    begin
      FLineFields.Add(Copy(Details[I], 1, Pos(' ', Details[I]) - 1));
      FLineFields.Add(Copy(Details[I], Pos(' ', Details[I]) + 1,  Length(Details[I])));
    end else
      FLineFields.Add(Details[I]);
  end;
end;

{
  Возвращает максимальное количество строк.
}

function TmmDBGrid.GetMaxLineCount: Integer;
var
  I: Integer;
begin
  if not Assigned(DataLink.DataSet) then
  begin
    Result := FLineCount;
    Exit;
  end;

  Result := 1;

  for I := 0 to DataLink.DataSet.FieldCount - 1 do
    if DataLink.DataSet.Fields[I].Visible and
      GetDetailLines(DataLink.DataSet.Fields[I].Fieldname, ShowingLines) then
    begin
      if (ShowingLines.Count > 0) and (Pos('format ', ShowingLines[0]) > 0) then
        ShowingLines.Delete(0);

      if ShowingLines.Count + 1 > Result then
        Result := ShowingLines.Count + 1;
    end;
end;

{
  Высота ячейки по умолчанию.
}

function TmmDBGrid.GetDefaultRowHeight: Integer;
var
  F: TFont;
begin
  F := TFont.Create;
  try
    F.Assign(Canvas.Font);
    Canvas.Font := Font;
    Result := Canvas.TextHeight('Wg') + 3;
    if dgRowLines in Options then Inc(Result, GridLineWidth);
    Canvas.Font.Assign(F);
  finally
    F.Free;
  end;
end;

{
  Производит считывание переменных.
}

procedure TmmDBGrid.MakeVariables;
var
  I: Integer;
  Day, Month, Year: Word;
begin
  if FFoCal <> nil then
  begin
    FFoCal.ClearVariablesList;

    DecodeDate(Now, Year, Month, Day);
    FFoCal.AssignVariable('dd', Day);
    FFoCal.AssignVariable('mm', Month);
    FFoCal.AssignVariable('yy', Year);
    FFoCal.AssignVariable('yyyy', Year);

    for I := 0 to DataLink.DataSet.FieldCount - 1 do
      if DataSource.DataSet.Fields[I].DataType in [ftSmallint, ftInteger,
        ftWord, ftFloat, ftCurrency, ftAutoInc, ftLargeint, ftDate, ftTime, ftDateTime]
      then
        FFoCal.AssignVariable(DataLink.DataSet.Fields[I].FieldName,
          DataLink.DataSet.Fields[I].AsFloat);
  end;
end;

// Удаляет двойные пробелы
function DeleteDoubleSpaces(T: String): String;
var
  L: Integer;
begin
  repeat
    L := AnsiPos('  ', T);

    if L > 0 then
      T := Copy(T, 1, L - 1) + Copy(T, L + 1, Length(T));
  until L = 0;

  Result := T;
end;

// Удаляет пробелы сзади и точку с запятой
function CutBackSpaces(T: String): String;
var
  I: Integer;
begin
  I := Length(T);
  while (I > 1) and (T[I] in [' ', ',', ';']) do Dec(I);
  Result := Copy(T, 1, I);
end;

// Удаляет все #13#10 после ORDER BY
function DeleteAllWordWraps(T: String): String;
var
  L, N: Integer;
  O: String;
begin
  Result := T;

  // Получаем часть с ORDER BY
  N := AnsiPos(SQL_ORDERBY, T);
  if N > 0 then
    O := Copy(T, N, Length(T))
  else
    Exit;

  // Удаляем разбивки
  repeat
    L := AnsiPos(#13#10, O);

    if L > 0 then
      O := Copy(O, 1, L - 1) + Copy(O, L + 2, Length(O));
  until L = 0;

  Result := Copy(T, 1, N - 2) + O;
end;

// Удаляем " ,"
function DeleteBadSpaces(T: String): String;
var
  L: Integer;
begin
  repeat
    L := AnsiPos(' ,', T);

    if L > 0 then
      T := Copy(T, 1, L - 1) + Copy(T, L + 1, Length(T));
  until L = 0;

  Result := T;
end;

{
  Находится ли название данного поля в строке, содержащей ORDER BY.
}

function TmmDBGrid.IsFieldInOrderBy(F: String; var ASC: boolean): Boolean;
var
  I: Integer;
  S: String;

  // Возвращает одно слово с зади
  function CopyNextWord(T: String): String;
  var
    K, L: Integer;
  begin
    Result := '';

    // Избавляемся от пробелов
    L := 1;
    while (L < Length(T)) and (T[L] = ' ') do
      Inc(L);

    if AnsiPos(' ', Copy(T, L, Length(T))) = 0 then
      Result := Copy(T, L, Length(T))
    else
      for K := L to Length(T) do
        if (T[K] in [' ', ',']) or (L = Length(T)) then
        begin
          Result := Copy(T, L, K - 2);
          Break;
        end;
  end;

begin
  ASC := True;

  if
    (DataSource <> nil)
      and
    (DataSource.DataSet <> nil)
      and

  {$IFDEF MMDBGRID_IBEXPRESS}
    (DataSource.DataSet is TIBQuery)
      and
    (AnsiPos(SQL_ORDERBY, AnsiUpperCase((DataSource.DataSet as TIBQuery).SQL.Text)) > 0)
  {$ELSE}
    (DataSource.DataSet is TQuery)
      and
    (AnsiPos(SQL_ORDERBY, AnsiUpperCase((DataSource.DataSet as TQuery).SQL.Text)) > 0)
  {$ENDIF}

  then begin

  {$IFDEF MMDBGRID_IBEXPRESS}
    S := DeleteAllWordWraps(AnsiUpperCase((DataSource.DataSet as TIBQuery).SQL.Text));
  {$ELSE}
    S := DeleteAllWordWraps(AnsiUpperCase((DataSource.DataSet as TQuery).SQL.Text));
  {$ENDIF}
    I := AnsiPos(SQL_ORDERBY, S);

    if I > 0 then
    begin
      S := Copy(S, I, Length(S));
      I := AnsiPos(AnsiUpperCase(F), S);
      Result := (I > 0) and (S[I - 1] in [' ', ',']) and
        ((I + Length(F) - 1 <= Length(S)) or (S[I + Length(F)] in [' ', ',']));

      if Result then
      begin
        S := AnsiUpperCase(CopyNextWord(Copy(S, I + Length(F), Length(S))));
        ASC := not ((S = SQL_DESC) or (S = SQL_DESCENDING));
      end;
    end else
      Result := False;
  end else
    Result := False;
end;

{
  Добавляет сортировку в SQL.
}

procedure TmmDBGrid.InsertFieldOrderBy(F: String; ASC: Boolean);
var
  OldASC: Boolean;
  IsInOrderBy: Boolean;
  K, M: Integer;
  S: String;
  S2: String[30];
  BeforePart: String;
begin
  // Покадаем процедуру, если работа идет с таблицей, а не с запросом

{$IFDEF MMDBGRID_IBEXPRESS}
  if (DataSource = nil) or (DataSource.DataSet = nil) or not (DataSource.DataSet is TIBQuery) then Exit;
{$ELSE}
  if (DataSource = nil) or (DataSource.DataSet = nil) or not (DataSource.DataSet is TQuery) then Exit;
{$ENDIF}

  // Внесено ли поле в  сортировку или нет - определяем
  IsInOrderBy := IsFieldInOrderBy(F, OldASC);

  // Получаем строку с ORDER BY
{$IFDEF MMDBGRID_IBEXPRESS}
  S := AnsiUpperCase((DataSource.DataSet as TIBQuery).SQL.Text);
{$ELSE}
  S := AnsiUpperCase((DataSource.DataSet as TQuery).SQL.Text);
{$ENDIF}

  // Удаляем все разбивки на строчки после ORDER BY
  S := DeleteAllWordWraps(S);

  // Удаляем двойные пробелы
  S := DeleteDoubleSpaces(S);

  // Если не совпадает направление сортировки, то меняем его
  if IsInOrderBy and (OldASC <> ASC) then
  begin
    K := AnsiPos(SQL_ORDERBY, S);
    BeforePart := Copy(S, 1, K - 1);
    S := Copy(S, K, Length(S));

    // Если нужно установить возрастающую сортировку
    if ASC then
    begin
      K := AnsiPos(AnsiUpperCase(F + ' ' + SQL_DESC), S);
      if K > 0 then
        M := Length(SQL_DESC) + 1
      else begin
        K := AnsiPos(AnsiUpperCase(F + ' ' + SQL_DESCENDING), S);
        if K > 0 then
          M := Length(SQL_DESCENDING) + 1
        else
          raise Exception.Create('Error!');
      end;
    end else begin // Если стоит убывающий порядок, то убираем сортировку вообще
      K := AnsiPos(AnsiUpperCase(F), S);
      M := 0;
    end;

    if ASC then
      S2 := ''
    else
      S2 := ' ' + SQL_DESC;

    if OldASC then // Добавляем вид сортировки
      S := Copy(S, 1, K + Length(F) - 1) + S2 + Copy(S, K + Length(F) + M, Length(S))
    else begin // Убираем поле из сортировки
      S := DeleteBadSpaces(S);
      S := Copy(S, 1, K - 1) + Copy(S, K + Length(F) + M + 1, Length(S));
      S := CutBackSpaces(S);

      // В этом месте необходимо удалить ORDERBY
      K := AnsiPos(SQL_ORDERBY, S);
      if CutBackSpaces(Copy(S, K, Length(S))) = SQL_ORDERBY then
        S := Copy(S, 1, K - 1) + Copy(S, K + Length(F) + Length(SQL_ORDERBY), Length(S));
    end;

  {$IFDEF MMDBGRID_IBEXPRESS}
    (DataSource.DataSet as TIBQuery).SQL.Text := BeforePart + S;
  {$ELSE}
    (DataSource.DataSet as TQuery).SQL.Text := BeforePart + S;
  {$ENDIF}
    DataSource.DataSet.Close;
    DataSource.DataSet.Open;
  // Если поля нет в сортировке, то добавляем его + вид сортировки
  end else begin
    if ASC then
      S2 := ''
    else
      S2 := ' ' + SQL_DESC;

    // Удаляет пробелы сзади и точку с запятой, добавляем поле
    K := AnsiPos(SQL_ORDERBY, S);
    if K > 0 then
      S := CutBackSpaces(S) + ', ' + F + S2
    else
      S := CutBackSpaces(S) + ' ' + SQL_ORDERBY + ' ' + F + S2;

  {$IFDEF MMDBGRID_IBEXPRESS}
    (DataSource.DataSet as TIBQuery).SQL.Text := S;
  {$ELSE}
    (DataSource.DataSet as TQuery).SQL.Text := S;
  {$ENDIF}
    DataSource.DataSet.Close;
    DataSource.DataSet.Open;
  end;
end;

procedure TmmDBGrid.DoOnViewDataSource(Sender: TObject);
var
  SL: TStringList;
begin
  if (DataLink = nil) or (not DataLink.Active) or (DataLink.DataSource.DataSet = nil) then
    exit;

  if dlgViewDataSource = nil then
    dlgViewDataSource := TdlgViewDataSource.Create(Application);

  {$IFDEF MMDBGRID_IBEXPRESS}

  if (DataLink.DataSource.DataSet is TIBTable) then
  with dlgViewDataSource do
  begin
    Memo.Lines.Clear;
    Memo.Lines.Add('Table name: ' + (DataLink.DataSource.DataSet as TIBTable).TableName);
    dlgViewDataSource.chbxEditSQL.Enabled := False;
    ShowModal;
  end else if (DataLink.DataSource.DataSet is TIBQuery) then
    with dlgViewDataSource do
  begin
    {Memo.Lines.Clear;
    for I := 0 to (DataLink.DataSource.DataSet as TIBQuery).SQL.Count - 1 do
      Memo.Lines.Add((DataLink.DataSource.DataSet as TIBQuery).SQL[I]);}

    Memo.Lines.Assign((DataLink.DataSource.DataSet as TIBQuery).SQL);
    dlgViewDataSource.chbxEditSQL.Enabled := True;
    dlgViewDataSource.chbxEditSQL.Checked := False;
    ShowModal;
  end;

  {$ELSE}

  if (DataLink.DataSource.DataSet is TTable) then
  with dlgViewDataSource do
  begin
    Memo.Lines.Clear;
    Memo.Lines.Add('Table name: ' + (DataLink.DataSource.DataSet as TTable).TableName);
    dlgViewDataSource.chbxEditSQL.Enabled := False;
    ShowModal;
  end else if (DataLink.DataSource.DataSet is TQuery) then
    with dlgViewDataSource do
  begin
    {Memo.Lines.Clear;
    for I := 0 to (DataLink.DataSource.DataSet as TQuery).SQL.Count - 1 do
      Memo.Lines.Add((DataLink.DataSource.DataSet as TQuery).SQL[I]);}

    Memo.Lines.Assign((DataLink.DataSource.DataSet as TQuery).SQL);
    dlgViewDataSource.chbxEditSQL.Enabled := True;
    dlgViewDataSource.chbxEditSQL.Checked := False;
    ShowModal;
  end;

  {$ENDIF}

  if dlgViewDataSource.chbxEditSQL.Checked then
  begin
    SL := TStringList.Create;
    try
    {$IFDEF MMDBGRID_IBEXPRESS}
      SL.Assign((DataLink.DataSource.DataSet as TIBQuery).SQL);
      (DataLink.DataSource.DataSet as TIBQuery).SQL.Assign(dlgViewDataSource.Memo.Lines);
    {$ELSE}
      SL.Assign((DataLink.DataSource.DataSet as TQuery).SQL);
      (DataLink.DataSource.DataSet as TQuery).SQL.Assign(dlgViewDataSource.Memo.Lines);
    {$ENDIF}

      DataLink.DataSource.DataSet.Close;

      try
        DataLink.DataSource.DataSet.Open;
      except
        on Exception do
        begin
        {$IFDEF MMDBGRID_IBEXPRESS}
          (DataLink.DataSource.DataSet as TIBQuery).SQL.Assign(SL);
        {$ELSE}
          (DataLink.DataSource.DataSet as TQuery).SQL.Assign(SL);
        {$ENDIF}
          DataLink.DataSource.DataSet.Close;
          DataLink.DataSource.DataSet.Open;
        end;
      end;
    finally
      SL.Free;
    end;
  end;
end;

procedure TmmDBGrid.DoOnReopenDataSet(Sender: TObject);
begin
  if (DataLink = nil) or (not DataLink.Active) or (DataLink.DataSource.DataSet = nil) then
    exit;

  DataLink.DataSource.DataSet.Close;
  DataLink.DataSource.DataSet.Open;
end;

end.

