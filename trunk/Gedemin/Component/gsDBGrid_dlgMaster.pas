

{++

  Copyright (c) 2000-2014 by Golden Software of Belarus

  Module

    gsDBGrid_dlgMaster.pas

  Abstract

    Dialog window with options for gsDBgrid component.

  Author

    Romanovski Denis (31-08-2000)

  Revisions history

    Initial  31-08-2000  Dennis  Initial version.


--}

unit gsDBGrid_dlgMaster;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ComCtrls, ExtCtrls, xSpin, ActnList, DBGrids, DB, gsDBgrid,
  ImgList, ToolWin, Menus, Clipbrd, SynEditHighlighter, SynHighlighterSQL,
  SynEdit,  dmImages_unit;

type
  TQueryChangeNotify = procedure (Sender: TObject; WithPlan: Boolean) of object;

type
  TdlgMaster = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    pcOptions: TPageControl;
    tsTable: TTabSheet;
    tsColumn: TTabSheet;
    tsCondition: TTabSheet;
    Panel3: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    sgTableExample: TStringGrid;
    GroupBox1: TGroupBox;
    cbStriped: TCheckBox;
    btnStripeOddColor: TButton;
    btnStripeEvenColor: TButton;
    Label4: TLabel;
    Label5: TLabel;
    cbScaleColumns: TCheckBox;
    Panel4: TPanel;
    pcColumns: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet5: TTabSheet;
    Panel5: TPanel;
    Label10: TLabel;
    sgColumn: TStringGrid;
    lbExpandedLines: TListBox;
    btnAddExp: TButton;
    btnDeleteExp: TButton;
    btnUpExp: TButton;
    btnDownExp: TButton;
    Panel6: TPanel;
    pcConditions: TPageControl;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    Panel8: TPanel;
    lbConditions: TListBox;
    btnConditonAdd: TButton;
    btnConditionDelete: TButton;
    btnConditionUp: TButton;
    btnConditionDown: TButton;
    cbConditionActive: TCheckBox;
    Label20: TLabel;
    pnlConditionPreview: TPanel;
    lbConditionColumns: TListBox;
    btnConditionColumns: TButton;
    alMaster: TActionList;
    actTableFont: TAction;
    actTableColor: TAction;
    actTitleFont: TAction;
    actTitleColor: TAction;
    actSelectedFont: TAction;
    actSelectedColor: TAction;
    actStriped: TAction;
    actStipe1Color: TAction;
    actStipe2Color: TAction;
    actColumnFont: TAction;
    actColumnColor: TAction;
    actColumnTitleFont: TAction;
    actColumnTitleColor: TAction;
    actColumnFormat: TAction;
    actColumnLineCount: TAction;
    actColumnExpaneded: TAction;
    actColumnAddExp: TAction;
    actColumnDeleteExp: TAction;
    actColumnUpExp: TAction;
    actColumnDownExp: TAction;
    actConditionAdd: TAction;
    actConditionDelete: TAction;
    actConditionUp: TAction;
    actConditionDown: TAction;
    actConditionsActive: TAction;
    actConditionFont: TAction;
    actConditionColor: TAction;
    actConditionFontUse: TAction;
    actConditionColorUse: TAction;
    actConditionColumns: TAction;
    btnHelp: TButton;
    actOk: TAction;
    actCancel: TAction;
    actHelp: TAction;
    actVisible: TAction;
    btnEditExp: TButton;
    actColumnEditExp: TAction;
    lvColumns: TListView;
    actColumnSeparateExp: TAction;
    actApply: TAction;
    btnApply: TButton;
    actChooseColumnFormat: TAction;
    actTemplate: TAction;
    TabSheet2: TTabSheet;
    Label6: TLabel;
    lbTemplate: TListBox;
    btnSetTemplate: TButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Shape1: TShape;
    Label2: TLabel;
    Shape2: TShape;
    Label3: TLabel;
    Shape3: TShape;
    btnTableFont: TButton;
    btnTableColor: TButton;
    btnSelectedFont: TButton;
    btnSelectedColor: TButton;
    btnTitleFont: TButton;
    btnTitleColor: TButton;
    Label7: TLabel;
    GroupBox3: TGroupBox;
    btnColumnFont: TButton;
    btnColumnColor: TButton;
    rgColumnAlign: TRadioGroup;
    rgColumnTitleAlign: TRadioGroup;
    GroupBox4: TGroupBox;
    btnColumnTitleFont: TButton;
    btnColumnTitleColor: TButton;
    GroupBox5: TGroupBox;
    btnChooseColumnFormat: TButton;
    Label12: TLabel;
    editColumnFormat: TEdit;
    cbColumnFormat: TCheckBox;
    cbColumnLineCount: TCheckBox;
    editColumnLineCount: TxSpinEdit;
    editColumnTitle: TEdit;
    cbColumnVisible: TCheckBox;
    GroupBox6: TGroupBox;
    Label16: TLabel;
    editConditionName: TEdit;
    Label13: TLabel;
    editConditionColumn: TComboBox;
    GroupBox7: TGroupBox;
    Label14: TLabel;
    lblAnd: TLabel;
    Label19: TLabel;
    editConditionKind: TComboBox;
    editConditionText1: TEdit;
    editConditionText2: TEdit;
    cbEvaluateExpression: TCheckBox;
    Label8: TLabel;
    GroupBox8: TGroupBox;
    btnConditionFont: TButton;
    btnConditionColor: TButton;
    cbConditionFontUse: TCheckBox;
    cbConditionColorUse: TCheckBox;
    Label9: TLabel;
    Label11: TLabel;
    Panel7: TPanel;
    cbColumnsChooseAll: TCheckBox;
    tsQuery: TTabSheet;
    actLoadQuery: TAction;
    actSaveQuery: TAction;
    actApplyQuery: TAction;
    actApplyQueryWithPlan: TAction;
    btnSaveTemplate: TButton;
    btnLoadTemplate: TButton;
    actLoadTemplate: TAction;
    actSaveTemplate: TAction;
    ilQuery: TImageList;
    cbQuery: TControlBar;
    tbQuery: TToolBar;
    tbLoad: TToolButton;
    tbSave: TToolButton;
    ToolButton3: TToolButton;
    tbApplyWithPlan: TToolButton;
    tbApplyWithoutPlan: TToolButton;
    ToolButton6: TToolButton;
    tbCut: TToolButton;
    tbCopy: TToolButton;
    tbPaste: TToolButton;
    actCutQuery: TAction;
    actCopyQuery: TAction;
    actPasteQuery: TAction;
    pmQuery: TPopupMenu;
    lblColumnWidth: TLabel;
    editColumnWidth: TxSpinEdit;
    Label15: TLabel;
    GroupBox9: TGroupBox;
    cbColumnExpanded: TCheckBox;
    cbColumnSeparateExp: TCheckBox;
    lblExpands: TLabel;
    cbColumnTitleExp: TCheckBox;
    actColumnTitleExp: TAction;
    cbHorizLines: TCheckBox;
    btnDefaults: TButton;
    lblDefaults: TLabel;
    seQuery: TSynEdit;
    SynSQLSyn: TSynSQLSyn;
    cbShowTotals: TCheckBox;
    cbShowFooter: TCheckBox;
    cbColReadOnly: TCheckBox;
    cbTotal: TCheckBox;
    pmFields: TPopupMenu;
    alFields: TActionList;
    actFieldNameCopy: TAction;
    actFieldNameCopy1: TMenuItem;
    actUpperVisible: TAction;
    N1: TMenuItem;
    btnReset: TButton;
    actReset: TAction;
    actFind: TAction;
    actFindNext: TAction;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;

    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);

    procedure actTableFontExecute(Sender: TObject);
    procedure actTableColorExecute(Sender: TObject);
    procedure actTitleFontExecute(Sender: TObject);
    procedure actTitleColorExecute(Sender: TObject);
    procedure actSelectedFontExecute(Sender: TObject);
    procedure actSelectedColorExecute(Sender: TObject);
    procedure actChooseColumnsExecute(Sender: TObject);
    procedure actStripedExecute(Sender: TObject);
    procedure actStipe1ColorExecute(Sender: TObject);
    procedure actStipe2ColorExecute(Sender: TObject);

    procedure sgTableExampleDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);

    procedure actColumnFontExecute(Sender: TObject);
    procedure actColumnColorExecute(Sender: TObject);
    procedure actColumnTitleFontExecute(Sender: TObject);
    procedure actColumnTitleColorExecute(Sender: TObject);

    procedure sgColumnDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure actVisibleExecute(Sender: TObject);
    procedure actColumnLineCountExecute(Sender: TObject);
    procedure actColumnExpanededExecute(Sender: TObject);
    procedure editColumnTitleChange(Sender: TObject);
    procedure editColumnFormatExit(Sender: TObject);

    procedure rgColumnAlignClick(Sender: TObject);
    procedure rgColumnTitleAlignClick(Sender: TObject);
    procedure actColumnAddExpExecute(Sender: TObject);
    procedure actColumnDeleteExpExecute(Sender: TObject);
    procedure actColumnUpExpExecute(Sender: TObject);
    procedure actColumnDownExpExecute(Sender: TObject);
    procedure actColumnEditExpExecute(Sender: TObject);
    procedure lbExpandedLinesClick(Sender: TObject);
    procedure editColumnLineCountChange(Sender: TObject);

    procedure lvColumnsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure actColumnSeparateExpExecute(Sender: TObject);
    procedure actConditionsActiveExecute(Sender: TObject);

    procedure lbConditionsClick(Sender: TObject);
    procedure editConditionNameChange(Sender: TObject);
    procedure editConditionColumnClick(Sender: TObject);
    procedure editConditionKindClick(Sender: TObject);
    procedure editConditionText1Change(Sender: TObject);
    procedure editConditionText2Change(Sender: TObject);
    procedure cbEvaluateExpressionClick(Sender: TObject);
    procedure actConditionAddExecute(Sender: TObject);
    procedure actConditionDeleteExecute(Sender: TObject);
    procedure actConditionUpExecute(Sender: TObject);
    procedure actConditionDownExecute(Sender: TObject);
    procedure actConditionFontExecute(Sender: TObject);
    procedure actConditionColorExecute(Sender: TObject);
    procedure btnConditionFontUseClick(Sender: TObject);
    procedure btnConditionColorUseClick(Sender: TObject);

    procedure actConditionColumnsExecute(Sender: TObject);
    procedure actColumnFormatExecute(Sender: TObject);
    procedure actChooseColumnFormatExecute(Sender: TObject);
    procedure actTemplateExecute(Sender: TObject);
    procedure cbColumnsChooseAllClick(Sender: TObject);
    procedure actLoadQueryExecute(Sender: TObject);
    procedure actSaveQueryExecute(Sender: TObject);
    procedure actApplyQueryExecute(Sender: TObject);
    procedure actApplyQueryWithPlanExecute(Sender: TObject);
    procedure actLoadTemplateExecute(Sender: TObject);
    procedure actSaveTemplateExecute(Sender: TObject);
    procedure actCutQueryExecute(Sender: TObject);
    procedure actCopyQueryExecute(Sender: TObject);
    procedure actPasteQueryExecute(Sender: TObject);
    procedure editColumnWidthChange(Sender: TObject);
    procedure pcOptionsChange(Sender: TObject);
    procedure lvColumnsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lvColumnsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lvColumnsCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure actColumnTitleExpExecute(Sender: TObject);
    procedure cbHorizLinesClick(Sender: TObject);
    procedure actConditionDeleteUpdate(Sender: TObject);
    procedure actFieldNameCopyExecute(Sender: TObject);
    procedure actUpperVisibleExecute(Sender: TObject);
    procedure actResetExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actFieldNameCopyUpdate(Sender: TObject);
    procedure actFindUpdate(Sender: TObject);
    procedure actFindNextUpdate(Sender: TObject);
    procedure actFindExecute(Sender: TObject);
    procedure actFindNextExecute(Sender: TObject);
    procedure actConditionUpUpdate(Sender: TObject);
    procedure actConditionDownUpdate(Sender: TObject);

  private
    FNewColumns: TgsColumns; // Новые, измененные колонки
    FOldColumns: TgsColumns; // Старые колонки

    FTitleFont: TFont; // Шрифт заглавия
    FTitleColor: TColor; // Цвет заглавия

    FSelectedFont: TFont; // Шрифт выделенного текста
    FSelectedColor: TColor; // Цвет выделенного текста

    FStripeEven, FStripeOdd: TColor; // Цвет полос

    FFontDlg: TFontDialog; // Диалог шрифтов
    FColorDlg: TColorDialog; // Диалог цветов

    FDataLink: TGridDataLink; // Связь с источником данных визуальной таблицы

    FNewExpands: TColumnExpands; // Список элементов расширенного отображения
    FOldExpands: TColumnExpands; // Список старых элементов расширенного отображения

    FNewConditions: TGridConditions; // Список новых элементов условного форматирования
    FOldConditions: TGridConditions; // Список старых элементов условного форматирования

    FOptions: TDBGridOptions; // опции таблицы

    FQueryChanged: TQueryChangeNotify; // Изменился запрос
    FOwnerGridClass: TgsDBGridClass; // Класс визуальной таблицы
    FColumnClass: TgsColumnClass; // Класс колоноки

    FOldClipboard, FClipboard: TClipboard; // Работа с клипбоардом

    FBlockColumnSelection: Boolean; // Запретить изменения выделенных колонок
    FBlockSetDataLink: Boolean; // Запретить устовку связи с данными

    //FFields: TStringList; // Список полей
    FFields: TList;
    FPreparingForEditing: Boolean;

    FSearchValue: String;

    function GetTableFont: TFont;
    function GetTableColor: TColor;

    function GetTitleFont: TFont;
    function GetTitleColor: TColor;

    function GetSelectedFont: TFont;
    function GetSelectedColor: TColor;

    function GetStriped: Boolean;
    function GetStripeEven: TColor;
    function GetStripeOdd: TColor;

    function GetScaleColumns: Boolean;
    function GetExpandsActive: Boolean;
    function GetExpandsSeparate: Boolean;
    function GetConditionsActive: Boolean;
    function GetTitlesExpanding: Boolean;
    function GetOptions: TDBGridOptions;

    procedure SetTableFont(const Value: TFont);
    procedure SetTableColor(const Value: TColor);

    procedure SetTitleFont(const Value: TFont);
    procedure SetTitleColor(const Value: TColor);

    procedure SetSelectedFont(const Value: TFont);
    procedure SetSelectedColor(const Value: TColor);

    procedure SetStriped(const Value: Boolean);
    procedure SetStripeEven(const Value: TColor);
    procedure SetStripeOdd(const Value: TColor);

    procedure SetScaleColumns(const Value: Boolean);
    procedure SetExpandsActive(const Value: Boolean);
    procedure SetExpandsSeparate(const Value: Boolean);

    procedure SetConditionsActive(const Value: Boolean);
    procedure SetTitlesExpanding(const Value: Boolean);
    procedure SetOptions(const Value: TDBGridOptions);

    procedure SetDataLink(Value: TGridDataLink);

    function GetCurrColumn: TgsColumn;
    function GetCurrField: TField;
    function GetCurrCondition: TCondition;

    function GetNewExpands: TColumnExpands;
    function GetGrid: TgsCustomDBGrid;
    function GetShowTotals: Boolean;
    procedure SetShowTotals(const Value: Boolean);
    function GetShowFooter: Boolean;
    procedure SetShowFooter(const Value: Boolean);
    procedure FindColumn(const FromStart: Boolean);

  protected
    procedure EditColumn(AColumn: TgsColumn);

    procedure PrepareExpands(AColumn: TgsColumn);
    function FindCurrExpand: TColumnExpand;

    procedure EditCondition(ACondition: TCondition);
    procedure EnableConditions(Enable, All: Boolean);
    procedure UpdateConditionVisibleColumns;
    procedure PrepareConditionButtons;

    function ColumnByFieldName(AFieldName: String): TgsColumn;
    procedure GetSelectedColumns(List: TList);
    function ItemIndexByExpand(AnExpand: TColumnExpand): Integer;

    procedure CheckConditions;

    procedure LoadRegistryOptions;
    procedure SaveRegistryOptions;

    // Возвращает текущую колонку
    property CurrColumn: TgsColumn read GetCurrColumn;
    // Возвращает текущее поле
    property CurrField: TField read GetCurrField;
    // Возвращает текущее условие
    property CurrCondition: TCondition read GetCurrCondition;

  public
    FReset: Boolean;

    constructor Create(AnOwner: TgsCustomDBGrid;
      AnOwnerGridClass: TgsDBGridClass; AColumnClass: TgsColumnClass); reintroduce;
    destructor Destroy; override;

    function ShowModal: Integer; override;

    procedure SetOldColumns(Value: TgsColumns);
    procedure SetOldExpands(Value: TColumnExpands);
    procedure SetOldConditions(Value: TGridConditions);

    procedure UpdateColumnsView;

    procedure CheckSettings;
    procedure EnableCategory(Category: String; Enable: Boolean);

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

    // Новые колонки
    property NewColumns: TgsColumns read FNewColumns;

    // Для текста таблицы
    property TableFont: TFont read GetTableFont write SetTableFont;
    property TableColor: TColor read GetTableColor write SetTableColor;

    // Для заголовков
    property TitleFont: TFont read GetTitleFont write SetTitleFont;
    property TitleColor: TColor read GetTitleColor write SetTitleColor;

    // Для выделенного текста
    property SelectedFont: TFont read GetSelectedFont write SetSelectedFont;
    property SelectedColor: TColor read GetSelectedColor write SetSelectedColor;

    // Полосатая таблица
    property Striped: Boolean read GetStriped write SetStriped;
    property StripeEven: TColor read GetStripeEven write SetStripeEven;
    property StripeOdd: TColor read GetStripeOdd write SetStripeOdd;

    // Растягивание колонок
    property ScaleColumns: Boolean read GetScaleColumns write SetScaleColumns;

    //
    property ShowTotals: Boolean read GetShowTotals write SetShowTotals;
    property ShowFooter: Boolean read GetShowFooter write SetShowFooter;

    // Использовать ли расширенное отображение
    property ExpandsActive: Boolean read GetExpandsActive write SetExpandsActive;
    // Список элементов расширенного отображения
    property NewExpands: TColumnExpands read GetNewExpands;
    // Отображать разделитель
    property ExpandsSeparate: Boolean read GetExpandsSeparate write SetExpandsSeparate;
    // Отображение сложных колонок
    property TitlesExpanding: Boolean read GetTitlesExpanding write SetTitlesExpanding;
    // Опции таблицы
    property Options: TDBGridOptions read GetOptions write SetOptions;




    // Использовать ли условное форматирование
    property ConditionsActive: Boolean read GetConditionsActive write SetConditionsActive;
    // Список элементов расширенного отображения
    property NewConditions: TGridConditions read FNewConditions;

    // Связь с источником данных визуальной таблицы
    property DataLink: TGridDataLink write SetDataLink;
    // Таблица, с которой работает данный компонент
    property Grid: TgsCustomDBGrid read GetGrid;
    // Событие изменения запроса
    property QueryChanged: TQueryChangeNotify read FQueryChanged write FQueryChanged;

  end;

var
  dlgMaster: TdlgMaster;

function SymbolsToPixels(const Symbols: Integer; Canvas: TCanvas): Integer;
function PixelsToSymbols(const Pixels: Integer; Canvas: TCanvas): Integer;

implementation

{$R *.DFM}

uses
  Registry,      CheckLst,         gsDBGrid_dlgColumnExpand,      gsDBGrid_dlgColFormat,
  gsDBGrid_dlgConditionColumns,    JclStrings,                    gdcBase,
  gd_directories_const
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub, gd_localization
  {$ENDIF}
  ;

const
  GRID_OPTION_SAVE_PATH = ClientRootRegistrySubKey + 'Grid Options\';

const
  MaxConditionCount = 13;

  ConditionText: array[TConditionKind] of String =
    (
     'равно',
     'не равно',
     'между',
     'вне',
     'больше',
     'меньше',
     'больше или равно',
     'меньше или равно',
     'начинается',
     'содержит',
     'существует',
     'не существует',
     ''
    );

  ConditionKindByIndex: array[0..MaxConditionCount - 1] of TConditionKind =
    (
     ckEqual, ckNotEqual, ckIn, ckOut, ckBigger, ckSmaller,
     ckBiggerEqual, ckSmallerEqual, ckStarts, ckContains, ckExist, ckNotExist, ckNone
    );

function SymbolsToPixels(const Symbols: Integer; Canvas: TCanvas): Integer;
var
  TM: TTextMetric;
begin
  GetTextMetrics(Canvas.Handle, TM);

  Result := Symbols * (TM.tmAveCharWidth - (TM.tmAveCharWidth div 2) +
    TM.tmOverhang + 3);
end;

function PixelsToSymbols(const Pixels: Integer; Canvas: TCanvas): Integer;
var
  TM: TTextMetric;
begin
  GetTextMetrics(Canvas.Handle, TM);

  Result := Pixels div (TM.tmAveCharWidth - (TM.tmAveCharWidth div 2) +
    TM.tmOverhang + 3);

end;

{
    --------------------------------
    ----    TdlgMaster Class    ----
    --------------------------------
}

{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TdlgMaster.Create(AnOwner: TgsCustomDBGrid;
  AnOwnerGridClass: TgsDBGridClass; AColumnClass: TgsColumnClass);
begin
  inherited Create(AnOwner);

  FReset := False;

  FClipboard := TClipboard.Create;
  FOldClipboard := SetClipboard(FClipboard);

  FBlockColumnSelection := False;
  FBlockSetDataLink := False;

  FNewColumns := nil;
  FOldColumns := nil;

  FTitleFont := TFont.Create;
  FTitleColor := clNone;

  FSelectedFont := TFont.Create;
  FSelectedColor := clNone;

  FStripeEven := clNone;
  FStripeOdd := clNone;

  FFontDlg := TFontDialog.Create(Self);
  FColorDlg := TColorDialog.Create(Self);
  FColorDlg.Options := [cdSolidColor, cdAnyColor];

  FDataLink := nil;
  FNewExpands := nil;
  FOldExpands := nil;

  FNewConditions := nil;
  FOldConditions := nil;

  FOptions := [];

  FQueryChanged := nil;
  FOwnerGridClass := AnOwnerGridClass;
  FColumnClass := AColumnClass;

  //FFields := TStringList.Create;
  FFields := TList.Create;

  FPreparingForEditing := False;
end;

destructor TdlgMaster.Destroy;
var
  P: PString;
  I: Integer;
begin
  for I := 0 to FFields.Count - 1 do
  begin
    P := FFields[I];
    Dispose(P);
  end;
  FFields.Free;

  //FFields.Free;
  FTitleFont.Free;
  FSelectedFont.Free;

  { внимание! oldcolumns и пр. удалять не надо! они являются ссылками на }
  { соответствующие объекты в гриде                                      }
  if Assigned(FNewColumns) then FNewColumns.Free;
  if Assigned(FNewExpands) then FNewExpands.Free;
  if Assigned(FNewConditions) then FNewConditions.Free;

  SetClipboard(FOldClipboard);
  FreeAndNil(FClipboard);

  inherited Destroy;
end;

{
  Вывод окна на экран в модальном виде.
  Перед выводом делаем свои установки.
}

function TdlgMaster.ShowModal: Integer;
begin
  EnableCategory('Result', True);

  LoadRegistryOptions;

  Result := inherited ShowModal;

  SaveRegistryOptions;
end;

{
  Устанавливает колонки, которые будем редактироватью.
}

procedure TdlgMaster.SetOldColumns(Value: TgsColumns);
var
  I: Integer;
  NewColumn, OldColumn: TgsColumn;
  CurrItem: TListItem;
  P: PString;
begin
  if Assigned(FNewColumns) then
    FreeAndNil(FNewColumns);

  FOldColumns := Value;
  FNewColumns := TgsColumns.Create(Grid, FColumnClass, True);

  lvColumns.Items.Clear;
  editConditionColumn.Items.Clear;
  //FFields.Clear;

  if Assigned(FOldColumns) then
  begin
    // Для начала переносим сведения созданных колонок в
    // во внутренние колонки
    for I := 0 to FOldColumns.Count - 1 do
    begin
      OldColumn := FOldColumns[I];

      if Assigned(FDataLink)
        and Assigned(FDataLink.DataSet)
        and (FDataLink.DataSet is TgdcBase)
        and (OldColumn.Field <> nil)
        and (OldColumn.Field.DataSet = FDataLink.DataSet) then
      begin
        if not (FDataLink.DataSet as TgdcBase).ShowFieldInGrid(OldColumn.Field) then
          continue;
      end;                   

      NewColumn := FNewColumns.Add;
      NewColumn.Assign(OldColumn);
      NewColumn.Field := OldColumn.Field;
      NewColumn.Title.Caption := OldColumn.Title.Caption;

      if NewColumn.WasFrozen then
      begin
        NewColumn.Visible := True;
        {$IFDEF GEDEMIN}
        NewColumn.Width := OldColumn.GetRealWidth;
        {$ENDIF}
      end;

      // Создаем список колонок для раздела установок по колонкам
      CurrItem := lvColumns.Items.Add;
      CurrItem.Caption := NewColumn.Title.Caption;
      CurrItem.SubItems.Add(NewColumn.FieldName);
      CurrItem.Data := NewColumn;

      // Создаем список колонок для раздела условного форматирования
      New(P);
      FFields.Add(P);
      P^ := NewColumn.FieldName;
      editConditionColumn.Items.AddObject(NewColumn.Title.Caption, Pointer(P));
      //FFields.Add(NewColumn.FieldName);
    end;

    EnableCategory('Column', True);
    actColumnFont.Enabled := True;
  end else begin
    tsColumn.TabVisible := False;
    tsCondition.TabVisible := False;
  end;

  EnableCategory('Table', True);

  btnStripeEvenColor.Enabled := cbStriped.Checked;
  btnStripeOddColor.Enabled := cbStriped.Checked;

  if lvColumns.Items.Count > 0 then
  begin
    lvColumns.Selected := lvColumns.Items[0];
    lvColumns.Selected.Focused := True;
  end;
end;

{
  Устанавливаем элементы расширенного отображения
  для дальнейшего редактирования.
}

procedure TdlgMaster.SetOldExpands(Value: TColumnExpands);
begin
  if Assigned(FNewExpands) then
    FreeAndNil(FNewExpands);

  FNewExpands := TColumnExpands.Create(nil);
  FNewExpands.Assign(Value);
  
  if (lvColumns.Items.Count > 0) and Assigned(CurrColumn) then
    PrepareExpands(CurrColumn);
end;

{
  Устанавливаем элементы условного форматирования
  для дальнейшего редактирования. 
}

procedure TdlgMaster.SetOldConditions(Value: TGridConditions);
var
  I: Integer;
begin
  if Assigned(FNewConditions) then
    FreeAndNil(FNewConditions);

  EnableCategory('Condition', True);

  FNewConditions := TGridConditions.Create(nil);
  FNewConditions.Assign(Value);

  editConditionKind.Items.Clear;

  // Добавляем стандартные условия
  for I := 0 to MaxConditionCount - 2 do
  editConditionKind.Items.Add(ConditionText[ConditionKindByIndex[I]]);

  for I := 0 to FNewConditions.Count - 1 do
  begin
    lbConditions.Items.Add(FNewConditions[I].ConditionName);
    lbConditions.Items.Objects[I] := FNewConditions[I];
  end;

  lbConditions.ItemIndex := 0;
  //EditCondition(CurrCondition);
  lbConditionsClick(lbConditions);
end;

procedure TdlgMaster.CheckSettings;
begin
  CheckConditions;
end;

{
  Делает категорию действий активной или нет.
}

procedure TdlgMaster.EnableCategory(Category: String; Enable: Boolean);
var
  I: Integer;
  CurrAction: TContainedAction;
begin
  for I := 0 to alMaster.ActionCount - 1 do
  begin
    CurrAction := alMaster.Actions[I];

    if AnsiCompareText(CurrAction.Category, Category) = 0 then
      (CurrAction as TAction).Enabled := Enable;
  end;
end;

procedure TdlgMaster.LoadFromStream(Stream: TStream);
var
  TempGrid: TgsCustomDBGrid;
begin
  TempGrid := FOwnerGridClass.Create(Self);

  try
    TempGrid.DontLoadSettings := True;
    TempGrid.DataSource := FDataLink.DataSource;
    TempGrid.LoadFromStream(Stream);
    TempGrid.PrepareMaster(Self);
  finally
    TempGrid.Free;
  end;
end;

procedure TdlgMaster.SaveToStream(Stream: TStream);
var
  TempGrid: TgsCustomDBGrid;
begin
  TempGrid := FOwnerGridClass.Create(Self);
  try
    TempGrid.DontLoadSettings := True;
    TempGrid.DataSource := FDataLink.DataSource;
    TempGrid.SetupGrid(Self, False);
    TempGrid.SaveToStream(Stream);
  finally
    TempGrid.Free;
  end;
end;


{
  ************************
  ***  Protected Part  ***
  ************************
}

{
  Подготавливает колонку к редактированию.
}

procedure TdlgMaster.EditColumn(AColumn: TgsColumn);
type
  TGridFieldType = (ftOther, ftNumeric, ftDateTime);
var
  CurrState: TCheckBoxState;
  I: Integer;
  OldVisible: Boolean;

  FirstFormat: String;
  FirstType: TGridFieldType;
  FirstState: TCheckBoxState;
  F: TField;
  FT: TFieldType;
begin
  FPreparingForEditing := True;
  try
    editColumnTitle.Text := AColumn.Title.Caption;

    if not Assigned(CurrField)
      or not ((CurrField is TNumericField) or (CurrField is TDateTimeField))
    then begin
      cbColumnFormat.Checked := False;
      actColumnFormat.Enabled := False;

      editColumnFormat.Text := '';
    end else begin
      if lvColumns.SelCount = 1 then
      begin
        editColumnFormat.Text := AColumn.DisplayFormat;
        actColumnFormat.Enabled := True;
        cbColumnFormat.Enabled := True;

        cbColumnFormat.Checked := editColumnFormat.Text > '';
      end
      else if lvColumns.SelCount > 1 then
      begin
        FirstFormat := AColumn.DisplayFormat;

        if (CurrField is TNumericField) then
          FirstType := ftNumeric
        else if (CurrField is TDateTimeField) then
          FirstType := ftDateTime
        else
          FirstType := ftOther;

        if FirstFormat <> '' then
          FirstState := cbChecked
        else
          FirstState := cbUnChecked;

        for I := 0 to lvColumns.Items.Count - 1 do
          if lvColumns.Items[I].Selected then
          begin
            F := FDataLink.DataSet.FindField(TgsColumn(lvColumns.Items[I].Data).FieldName);
            if not (((F is TDateTimeField) and(FirstType = ftDateTime)) or
                    ((F is TNumericField) and (FirstType = ftNumeric))) then
              begin
                FirstType := ftOther;
                Break;
              end;
            if FirstState = cbGrayed then
              Continue;
            if (TgsColumn(lvColumns.Items[I].Data).DisplayFormat = '') <> (FirstState = cbUnChecked) then
            begin
              FirstState := cbGrayed;
              FirstFormat := '';
            end;
            if FirstFormat <> TgsColumn(lvColumns.Items[I].Data).DisplayFormat then
              FirstFormat := '';
          end;
        if FirstType <> ftOther then
        begin
          editColumnFormat.Text := FirstFormat;
          actColumnFormat.Enabled := True;
          cbColumnFormat.Enabled := True;
          cbColumnFormat.State := FirstState;
        end
        else
        begin
          cbColumnFormat.Checked := False;
          actColumnFormat.Enabled := False;
          editColumnFormat.Text := '';
        end;
      end;
    end;

    actColumnFormatExecute(cbColumnFormat);

    if Assigned(CurrField) then
      if (lvColumns.SelCount = 1) then
      begin
        // Для одной выдленной колонки устанавливаем выравнивание

        case CurrColumn.Alignment of
          taLeftJustify: rgColumnAlign.ItemIndex := 0;
          taCenter: rgColumnAlign.ItemIndex := 1;
          taRightJustify: rgColumnAlign.ItemIndex := 2;
        end;

        case CurrColumn.Title.Alignment of
          taLeftJustify: rgColumnTitleAlign.ItemIndex := 0;
          taCenter: rgColumnTitleAlign.ItemIndex := 1;
          taRightJustify: rgColumnTitleAlign.ItemIndex := 2;
        end;
      end else begin
        // Для нескольких колонок следует выбрать
        // общее выравнивание отдельно
        rgColumnAlign.ItemIndex := -1;
        rgColumnTitleAlign.ItemIndex := -1;
      end;

    // Если выделено несколько записей - некоторые команды следует запретить
    editColumnTitle.Enabled := lvColumns.SelCount = 1;

    actChooseColumnFormat.Enabled := editColumnFormat.Enabled;
    if actChooseColumnFormat.Enabled and (lvColumns.SelCount > 1) then
    begin
      FT := ftUnknown;
      for I := 0 to lvColumns.Items.Count - 1 do
      begin
        if lvColumns.Items[I].Selected then
        begin
          if FT = ftUnknown then
            FT := TgsColumn(lvColumns.Items[I].Data).Field.DataType
          else if FT <> TgsColumn(lvColumns.Items[I].Data).Field.DataType then
          begin
            actChooseColumnFormat.Enabled := False;
            break;
          end;
        end;
      end;
    end;

    cbColumnLineCount.Enabled := lvColumns.SelCount = 1;
    editColumnLineCount.Enabled := lvColumns.SelCount = 1;
    lbExpandedLines.Enabled := lvColumns.SelCount = 1;
    btnAddExp.Enabled := lvColumns.SelCount = 1;
    btnDeleteExp.Enabled := lvColumns.SelCount = 1;
    btnEditExp.Enabled := lvColumns.SelCount = 1;
    btnUpExp.Enabled := lvColumns.SelCount = 1;
    btnDownExp.Enabled := lvColumns.SelCount = 1;

    if lvColumns.SelCount > 1 then
    begin
      if AColumn.Visible then
        CurrState := cbChecked
      else
        CurrState := cbUnChecked;

      for I := 0 to lvColumns.Items.Count - 1 do
        if lvColumns.Items[I].Selected then
        begin
          if
            TgsColumn(lvColumns.Items[I].Data).Visible
              and
            (CurrState = cbUnChecked)
              or
            not TgsColumn(lvColumns.Items[I].Data).Visible
              and
            (CurrState = cbChecked)
          then begin
            CurrState := cbGrayed;
            Break;
          end;
        end;

      cbColumnVisible.State := CurrState;

      // тоже самое для реад онли
      if AColumn.ReadOnly then
        CurrState := cbChecked
      else
        CurrState := cbUnChecked;

      for I := 0 to lvColumns.Items.Count - 1 do
        if lvColumns.Items[I].Selected then
        begin
          if
            TgsColumn(lvColumns.Items[I].Data).ReadOnly
              and
            (CurrState = cbUnChecked)
              or
            not TgsColumn(lvColumns.Items[I].Data).ReadOnly
              and
            (CurrState = cbChecked)
          then begin
            CurrState := cbGrayed;
            Break;
          end;
        end;

      cbColReadOnly.State := CurrState;

      // тоже самое для total
      if AColumn.TotalType = ttSum then
        CurrState := cbChecked
      else
        CurrState := cbUnChecked;

      for I := 0 to lvColumns.Items.Count - 1 do
        if lvColumns.Items[I].Selected then
        begin
          if
            (TgsColumn(lvColumns.Items[I].Data).TotalType = ttSum)
              and
            (CurrState = cbUnChecked)
              or
            (TgsColumn(lvColumns.Items[I].Data).TotalType = ttNone)
              and
            (CurrState = cbChecked)
          then begin
            CurrState := cbGrayed;
            Break;
          end;
        end;

      cbTotal.State := CurrState;

      // ширина колонки
      editColumnWidth.OnChange := nil;
      editColumnWidth.Text := '';
      editColumnWidth.OnChange := editColumnWidthChange;
    end else begin
      cbColumnVisible.Checked := AColumn.Visible;
      cbColReadOnly.Checked := AColumn.ReadOnly;
      cbTotal.Checked := AColumn.TotalType = ttSum;

      // ширина колонки
      Canvas.Font := AColumn.Font;
      editColumnWidth.OnChange := nil;

      OldVisible := AColumn.Visible;
      AColumn.Visible := True;

      editColumnWidth.IntValue := PixelsToSymbols(AColumn.Width, Canvas);

      AColumn.Visible := OldVisible;
      editColumnWidth.OnChange := editColumnWidthChange;
    end;

    PrepareExpands(AColumn);
  finally
    FPreparingForEditing := False;
  end;
end;

{
  Подготавливаем дополнительное отображение к редактированию.
}

procedure TdlgMaster.PrepareExpands(AColumn: TgsColumn);
var
  I: Integer;
  MainExpand: TColumnExpand;
  Column: TgsColumn;
begin
  if not Assigned(FNewExpands) then Exit;

  lbExpandedLines.Clear;

  for I := 0 to FNewExpands.Count - 1 do
    if
      not (ceoMultiline in FNewExpands[I].Options)
        and
      (AnsiCompareText(FNewExpands[I].DisplayField, AColumn.FieldName) = 0)
    then begin
      Column := ColumnByFieldName(FNewExpands[I].FieldName);

      if Assigned(Column) then
      begin
        lbExpandedLines.Items.Add(Column.Title.Caption);
        lbExpandedLines.Items.Objects[lbExpandedLines.Items.Count - 1] :=
          FNewExpands[I]; 
      end;
    end;

  MainExpand := FindCurrExpand;
  if not Assigned(MainExpand) then
  begin
    cbColumnLineCount.Checked := False;
    editColumnLineCount.IntValue := 1;
  end else begin
    editColumnLineCount.OnChange := nil;

    editColumnLineCount.IntValue := MainExpand.LineCount;
    cbColumnLineCount.Checked := True;

    editColumnLineCount.OnChange := editColumnLineCountChange;
  end;

  editColumnLineCount.Enabled := cbColumnLineCount.Checked;

  actColumnExpanededExecute(cbColumnExpanded);
end;

{
   Находит главный для колонки
   элемент расширенного отображения.
}

function TdlgMaster.FindCurrExpand: TColumnExpand;
var
  Z: Integer;
begin
  for Z := 0 to FNewExpands.Count - 1 do
    if
      (ceoMultiline in FNewExpands[Z].Options)
        and
      (AnsiCompareText(FNewExpands[Z].DisplayField, CurrColumn.FieldName) = 0)
    then begin
      Result := FNewExpands[Z];
      Exit;
    end;

  Result := nil;
end;

{
  Подготавливаем условие к редактированию.
}

procedure TdlgMaster.EditCondition(ACondition: TCondition);
var
  TheField: TField;
  I: Integer;
begin
  if Assigned(ACondition) then
  begin
    TheField := FDataLink.DataSet.FindField(ACondition.FieldName);
    editConditionName.Text := ACondition.ConditionName;

    if Assigned(TheField) then
    begin
      for I := 0 to editConditionColumn.Items.Count - 1 do
      begin
        if AnsiCompareText(TheField.FieldName,
          PString(editConditionColumn.Items.Objects[I])^) = 0 then
        begin
          editConditionColumn.ItemIndex := I;
          break;
        end;
      end;
    end
//      editConditionColumn.ItemIndex := FFields.IndexOf(TheField.FieldName)
    else
      editConditionColumn.ItemIndex := -1;

    editConditionKind.ItemIndex :=
      editConditionKind.Items.IndexOf(ConditionText[ACondition.ConditionKind]);

    editConditionText1.Text := ACondition.Expression1;
    editConditionText2.Text := ACondition.Expression2;
    cbEvaluateExpression.Checked := ACondition.EvaluateFormula;

    pnlConditionPreview.ParentColor := True;
    pnlConditionPreview.ParentFont := True;

    cbConditionFontUse.Checked := doFont in ACondition.DisplayOptions;
    actConditionFontUse.Execute;
    btnConditionFont.Enabled := cbConditionFontUse.Checked;

    cbConditionColorUse.Checked := doColor in ACondition.DisplayOptions;
    actConditionColorUse.Execute;
    btnConditionColor.Enabled := cbConditionColorUse.Checked;

    editConditionText1.Visible :=
      not (CurrCondition.ConditionKind in [ckExist, ckNotExist]);

    editConditionText2.Visible := CurrCondition.ConditionKind in [ckIn, ckOut];
    lblAnd.Visible := CurrCondition.ConditionKind in [ckIn, ckOut];

    UpdateConditionVisibleColumns;
  end;  
end;

{
  Разрешает или запрещает редактировать условия.
}

procedure TdlgMaster.EnableConditions(Enable, All: Boolean);
begin
  if All then
  begin
    actConditionAdd.Enabled := Enable;
    actConditionDelete.Enabled := Enable;
  end;

  editConditionName.Enabled := Enable;
  editConditionColumn.Enabled := Enable;
  editConditionKind.Enabled := Enable;
  editConditionText1.Enabled := Enable;
  editConditionText2.Enabled := Enable;
  cbEvaluateExpression.Enabled := Enable;

  actConditionFont.Enabled := Enable;
  actConditionFontUse.Enabled := Enable;
  actConditionColor.Enabled := Enable;
  actConditionColorUse.Enabled := Enable;
  actConditionColumns.Enabled := Enable;
  actConditionColumns.Enabled := Enable;

  pnlConditionPreview.ParentFont := not Enable;
  pnlConditionPreview.ParentColor := not Enable;

  if Enable and Assigned(CurrCondition) then EditCondition(CurrCondition);
end;

{
  Выводит список видимых колонок.
}

procedure TdlgMaster.UpdateConditionVisibleColumns;
var
  I: Integer;
  S: String;
  Column: TgsColumn;
begin
  lbConditionColumns.Items.Clear;
  S := CurrCondition.DisplayFields;

  repeat
    I := AnsiPos(';', S);

    if (I = 0) and (Length(S) > 0) then
      I := Length(S) + 1;

    if I > 0 then
    begin
      Column := ColumnByFieldName(Copy(S, 1, I - 1));

      if Assigned(Column) then
        lbConditionColumns.Items.Add(Column.Title.Caption);
      S := Copy(S, I + 1, Length(S));
    end;
  until I = 0;
end;

procedure TdlgMaster.PrepareConditionButtons;
begin
  actConditionAdd.Enabled := True;
  actConditionDelete.Enabled := lbConditions.Items.Count > 0;
  actConditionUp.Enabled := lbConditions.ItemIndex > 0;
  actConditionDown.Enabled := lbConditions.ItemIndex < lbConditions.Items.Count - 1;
end;

{
  Колонка по имени поля.
}

function TdlgMaster.ColumnByFieldName(AFieldName: String): TgsColumn;
var
  I: Integer;
begin
  for I := 0 to FNewColumns.Count - 1 do
    if AnsiCompareText(FNewColumns[I].FieldName, AFieldName) = 0 then
    begin
      Result := FNewColumns[I];
      Exit;
    end;

  Result := nil;
end;

{
  Возвращает список выделенных колонок.
}

procedure TdlgMaster.GetSelectedColumns(List: TList);
var
  I: Integer;
begin
  for I := 0 to lvColumns.Items.Count - 1 do
    if lvColumns.Items[I].Selected then
      List.Add(lvColumns.Items[I].Data);
end;

{
  Номер элемента в списке по элементу расширенного отображения.
}

function TdlgMaster.ItemIndexByExpand(AnExpand: TColumnExpand): Integer;
var
  I: Integer;
begin
  for I := 0 to lbExpandedLines.Items.Count - 1 do
    if lbExpandedLines.Items.Objects[I] = AnExpand then
    begin
      Result := I;
      Exit;
    end;

  Result := -1;
end;

{
  Производит проверку условий форматирования.
}

procedure TdlgMaster.CheckConditions;
var
  I, K: Integer;
  CurrCondition: TCondition;
  Fields: String;
begin
  try
    for I := 0 to FNewConditions.Count - 1 do
    begin
      CurrCondition := FNewConditions[I];

      if CurrCondition.DisplayOptions = [] then
      begin
        pcOptions.ActivePageIndex := 2;
        pcConditions.ActivePageIndex := 1;
        lbConditions.ItemIndex := I;
        lbConditionsClick(lbConditions);

        raise EgsDBGridException.Create('В условии "' + CurrCondition.ConditionName +
          '" не установлен формат отображения!');
      end;

      if CurrCondition.DisplayFields = '' then
      begin
        {pcOptions.ActivePageIndex := 2;
        pcConditions.ActivePageIndex := 1;
        lbConditions.ItemIndex := I;
        lbConditionsClick(lbConditions);}

        for K := 0 to FDataLink.DataSet.FieldCount - 1 do
          Fields := Fields + FDataLink.DataSet.Fields[K].FieldName + ';';

        CurrCondition.DisplayFields := Fields;

        //raise EgsDBGridException.Create(Format('В условии "%s" не установлены колонки для отображения!',
        //  [CurrCondition.ConditionName]));
      end;

      if CurrCondition.ConditionName = '' then
      begin
        CurrCondition.ConditionName :=
          CurrCondition.FieldName + '[' +
          ConditionText[CurrCondition.ConditionKind] + ']';

        lbConditions.Items[I] := CurrCondition.ConditionName;
      end;
    end;

  except
    ModalResult := mrNone;
    raise;
  end;
end;

{
  Производит загрузку опций из реестра.
}

procedure TdlgMaster.LoadRegistryOptions;
var
  Reg: TRegistry;
  Index: Integer;
begin
  Reg := TRegistry.Create;

  try
    Reg.RootKey := {HKEY_LOCAL_MACHINE}HKEY_CURRENT_USER;

    if Reg.OpenKey(GRID_OPTION_SAVE_PATH, False) then
    begin
      try
        Index := Reg.ReadInteger('Active Page');

        if pcOptions.PageCount <= Index then
          pcOptions.ActivePageIndex := pcOptions.PageCount - 1
        else
          pcOptions.ActivePageIndex := Index;

{ TODO : почему именно -2 ? }
        if not pcOptions.Pages[pcOptions.ActivePageIndex].TabVisible then
          pcOptions.ActivePageIndex := pcOptions.PageCount - 2;
      except
        pcOptions.ActivePageIndex := 0;
      end;

      try
        Index := Reg.ReadInteger('Active Columns Page');

        if pcOptions.PageCount <= Index then
          pcColumns.ActivePageIndex := pcColumns.PageCount - 1
        else
          pcColumns.ActivePageIndex := Index;
      except
        pcColumns.ActivePageIndex := 0;
      end;

      try
        Index := Reg.ReadInteger('Active Conditions Page');

        if pcConditions.PageCount <= Index then
          pcConditions.ActivePageIndex := pcConditions.PageCount - 1
        else
          pcConditions.ActivePageIndex := Index;
      except
        pcConditions.ActivePageIndex := 0;
      end;
    end;

  finally
    Reg.CloseKey;
    Reg.Free;
  end;

end;

{
  Производит сохранение опций в реестре.
}

procedure TdlgMaster.SaveRegistryOptions;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;

  try
    Reg.RootKey := {HKEY_LOCAL_MACHINE}HKEY_CURRENT_USER;

    if Reg.OpenKey(GRID_OPTION_SAVE_PATH, True) then
    begin
      Reg.WriteInteger('Active Page', pcOptions.ActivePageIndex);
      Reg.WriteInteger('Active Columns Page', pcColumns.ActivePageIndex);
      Reg.WriteInteger('Active Conditions Page', pcConditions.ActivePageIndex);
    end;

  finally
    Reg.CloseKey;
    Reg.Free;
  end;
end;


{
  **********************
  ***  Private Part  ***
  **********************
}

function TdlgMaster.GetTableFont: TFont;
begin
  Result := sgTableExample.Font;
end;

function TdlgMaster.GetTableColor: TColor;
begin
  Result := sgTableExample.Color;
end;

function TdlgMaster.GetTitleFont: TFont;
begin
  Result := FTitleFont;
end;

function TdlgMaster.GetTitleColor: TColor;
begin
  Result := FTitleColor;
end;

function TdlgMaster.GetSelectedFont: TFont;
begin
  Result := FSelectedFont;
end;

function TdlgMaster.GetSelectedColor: TColor;
begin
  Result := FSelectedColor;
end;

function TdlgMaster.GetStriped: Boolean;
begin
  Result := cbStriped.Checked;
end;

function TdlgMaster.GetStripeEven: TColor;
begin
  Result := FStripeEven;
end;

function TdlgMaster.GetStripeOdd: TColor;
begin
  Result := FStripeOdd;
end;

function TdlgMaster.GetScaleColumns: Boolean;
begin
  Result := cbScaleColumns.Checked;
end;

function TdlgMaster.GetExpandsActive: Boolean;
begin
  Result := cbColumnExpanded.Checked;
end;

function TdlgMaster.GetExpandsSeparate: Boolean;
begin
  Result := cbColumnSeparateExp.Checked;
end;

function TdlgMaster.GetConditionsActive: Boolean;
begin
  Result := cbConditionActive.Checked;
end;

function TdlgMaster.GetTitlesExpanding: Boolean;
begin
  Result := cbColumnTitleExp.Checked;
end;

function TdlgMaster.GetOptions: TDBGridOptions;
begin
  Result := FOptions;
end;


procedure TdlgMaster.SetTableFont(const Value: TFont);
begin
  sgTableExample.Font := Value;
end;

procedure TdlgMaster.SetTableColor(const Value: TColor);
begin
  sgTableExample.Color := Value;
end;

procedure TdlgMaster.SetTitleFont(const Value: TFont);
begin
  FTitleFont.Assign(Value);
end;

procedure TdlgMaster.SetTitleColor(const Value: TColor);
begin
  FTitleColor := Value;
end;

procedure TdlgMaster.SetSelectedFont(const Value: TFont);
begin
  FSelectedFont.Assign(Value);
end;

procedure TdlgMaster.SetSelectedColor(const Value: TColor);
begin
  FSelectedColor := Value;
end;

procedure TdlgMaster.SetStriped(const Value: Boolean);
begin
  cbStriped.Checked := Value;
end;

procedure TdlgMaster.SetStripeEven(const Value: TColor);
begin
  FStripeEven := Value;
end;

procedure TdlgMaster.SetStripeOdd(const Value: TColor);
begin
  FStripeOdd := Value;
end;

procedure TdlgMaster.SetScaleColumns(const Value: Boolean);
begin
  cbScaleColumns.Checked := Value;
end;

procedure TdlgMaster.SetExpandsActive(const Value: Boolean);
begin
  cbColumnExpanded.Checked := Value;
end;

procedure TdlgMaster.SetExpandsSeparate(const Value: Boolean);
begin
  cbColumnSeparateExp.Checked := Value;
end;

procedure TdlgMaster.SetConditionsActive(const Value: Boolean);
begin
  cbConditionActive.Checked := Value;
end;

procedure TdlgMaster.SetTitlesExpanding(const Value: Boolean);
begin
  cbColumnTitleExp.Checked := Value;
end;

procedure TdlgMaster.SetOptions(const Value: TDBGridOptions);
begin
  FOptions := Value;

  sgTableExample.Ctl3d := [dgColLines, dgRowLines] * Options =
    [dgColLines, dgRowLines];

  cbHorizLines.Checked := dgRowLines in Options;

  if dgColLines in Options then
    sgTableExample.Options := sgTableExample.Options +
      [goFixedVertLine, goVertLine]
  else
    sgTableExample.Options := sgTableExample.Options -
      [goFixedVertLine, goVertLine];

  if dgRowLines in Options then
    sgTableExample.Options := sgTableExample.Options +
      [goFixedHorzLine, goHorzLine]
  else
    sgTableExample.Options := sgTableExample.Options -
      [goFixedHorzLine, goHorzLine];
end;

procedure TdlgMaster.SetDataLink(Value: TGridDataLink);
begin
  if (FDataLink <> Value) and (not FBlockSetDataLink) then
  begin
    FDataLink := Value;
    FBlockSetDataLink := True;
  end;
end;

{
  Возвращает текущую колонку для редактирования.
}

function TdlgMaster.GetCurrColumn: TgsColumn;
begin
  if Assigned(lvColumns.Selected) then
    Result := lvColumns.Selected.Data
  else
    Result := nil;
end;

{
  Возвращает текущее поле.
}

function TdlgMaster.GetCurrField: TField;
begin
  if Assigned(CurrColumn) then
    Result := FDataLink.DataSet.FindField(CurrColumn.FieldName)
  else
    Result := nil;
end;

{
  Возвращает текущее условие.
}
function TdlgMaster.GetCurrCondition: TCondition;
begin
  if lbConditions.ItemIndex >= 0 then
    Result := lbConditions.Items.Objects[lbConditions.ItemIndex] as TCondition
  else
    Result := nil;
end;

{
  Возвращает новый список элементов расширенного отображения.
}

function TdlgMaster.GetNewExpands: TColumnExpands;
var
  I: Integer;
begin
  Result := FNewExpands;

  for I := Result.Count - 1 downto 0 do
    if
      (ceoMultiline in Result[I].Options)
        and
      (Result[I].LineCount = 1)
    then
      Result[I].Free;
end;

function TdlgMaster.GetGrid: TgsCustomDBGrid;
begin
  Result := Owner as TgsCustomDBGrid;
end;

{
  *********************
  ***  Events Part  ***
  *********************
}



{
  Кнопка ОК - сохраняем данные
}

procedure TdlgMaster.actOkExecute(Sender: TObject);
begin
  CheckSettings;
  actUpperVisible.Execute;
  ModalResult := mrOk;
end;

{
  Отмена - откат.
}

procedure TdlgMaster.actCancelExecute(Sender: TObject);
begin
end;

{
  Шрифт таблицы.
}

procedure TdlgMaster.actTableFontExecute(Sender: TObject);
var
  I: Integer;
begin
  FFontDlg.Font := sgTableExample.Font;
  if FFontDlg.Execute then
  begin
    sgTableExample.Font := FFontDlg.Font;
    sgTableExample.Invalidate;

    for I := 0 to FNewColumns.Count - 1 do
      FNewColumns[I].Font := FFontDlg.Font;
  end;
end;

{
  Цвет таблицы.
}

procedure TdlgMaster.actTableColorExecute(Sender: TObject);
var
  I: Integer;
begin
  FColorDlg.Color := sgTableExample.Color;
  //Считываемый цвет не обязательно находится в основной палитре
  //поэтому добавляем его в пользовательскую палитру
  //а по окончании работы ее очистим
  //единственная проблема с системными цветами типа clBtnFace
  //они не хотят отображаться в пользовательской палитре
  //однако свойства цвета при этом определяются (яркость, контрастность и т.д.)
  FColorDlg.CustomColors.Add('ColorA=' + IntToHex(sgTableExample.Color, 4));
  if FColorDlg.Execute then
  begin
    sgTableExample.Color := FColorDlg.Color;
    sgTableExample.Invalidate;

    for I := 0 to FNewColumns.Count - 1 do
      FNewColumns[I].Color := FColorDlg.Color;
  end;
  FColorDlg.CustomColors.Clear;
end;

{
  Шрифт заголовков.
}

procedure TdlgMaster.actTitleFontExecute(Sender: TObject);
var
  I: Integer;
begin
  FFontDlg.Font := FTitleFont;
  if FFontDlg.Execute then
  begin
    FTitleFont.Assign(FFontDlg.Font);
    sgTableExample.Invalidate;

    for I := 0 to FNewColumns.Count - 1 do
      FNewColumns[I].Title.Font := FFontDlg.Font;
  end;
end;

{
  Цвет заголовков.
}

procedure TdlgMaster.actTitleColorExecute(Sender: TObject);
var
  I: Integer;
begin
  FColorDlg.Color := FTitleColor;
  FColorDlg.CustomColors.Add('ColorA=' + IntToHex(FTitleColor, 4));
  if FColorDlg.Execute then
  begin
    FTitleColor := FColorDlg.Color;
    sgTableExample.Invalidate;

    for I := 0 to FNewColumns.Count - 1 do
      FNewColumns[I].Title.Color := FColorDlg.Color;
  end;
  FColorDlg.CustomColors.Clear;
end;

{
  Шрифт выделенного текста.
}

procedure TdlgMaster.actSelectedFontExecute(Sender: TObject);
begin
  FFontDlg.Font := FSelectedFont;
  if FFontDlg.Execute then
  begin
    FSelectedFont.Assign(FFontDlg.Font);
    sgTableExample.Invalidate;
  end;
end;

{
  Цвет выделенного текста.
}

procedure TdlgMaster.actSelectedColorExecute(Sender: TObject);
begin
  FColorDlg.Color := FSelectedColor;
  FColorDlg.CustomColors.Add('ColorA=' + IntToHex(FSelectedColor, 4));
  if FColorDlg.Execute then
  begin
    FSelectedColor := FColorDlg.Color;
    sgTableExample.Invalidate;
  end;
  FColorDlg.CustomColors.Clear;
end;

{
  Выбор видимых колонок.
}

procedure TdlgMaster.actChooseColumnsExecute(Sender: TObject);
begin
//
end;

{
  Режим полосатости.
}

procedure TdlgMaster.actStripedExecute(Sender: TObject);
begin
  btnStripeEvenColor.Enabled := cbStriped.Checked;
  btnStripeOddColor.Enabled := cbStriped.Checked;
  sgTableExample.Invalidate;
end;

{
  Первая полоса.
}

procedure TdlgMaster.actStipe1ColorExecute(Sender: TObject);
begin
  FColorDlg.Color := FStripeEven;
  FColorDlg.CustomColors.Add('ColorA=' + IntToHex(FStripeEven, 4));
  if FColorDlg.Execute then
  begin
    FStripeEven := FColorDlg.Color;
    Striped := True;
    sgTableExample.Invalidate;
  end;
  FColorDlg.CustomColors.Clear;
end;

{
  Вторая полоса.
}

procedure TdlgMaster.actStipe2ColorExecute(Sender: TObject);
begin
  FColorDlg.Color := FStripeOdd;
  FColorDlg.CustomColors.Add('ColorA=' + IntToHex(FStripeOdd, 4));
  if FColorDlg.Execute then
  begin
    FStripeOdd := FColorDlg.Color;
    Striped := True;
    sgTableExample.Invalidate;
  end;
  FColorDlg.CustomColors.Clear;
end;

procedure TdlgMaster.sgTableExampleDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if gdFixed in State then
  begin
    sgTableExample.Canvas.Font := TitleFont;
    sgTableExample.Canvas.Brush.Color := TitleColor;
    sgTableExample.Canvas.FillRect(Rect);
    sgTableExample.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, 'Колонка');
    Exit;
  end;

  if (State * [gdFocused, gdSelected]) <> [] then
  begin
    sgTableExample.Canvas.Font := SelectedFont;
    sgTableExample.Canvas.Brush.Color := SelectedColor;
  end else begin
    sgTableExample.Canvas.Font := sgTableExample.Font;
    sgTableExample.Canvas.Brush.Color := sgTableExample.Color;

    if Striped then
    begin
      if (ARow - 1) mod 2 = 0 then
        sgTableExample.Canvas.Brush.Color := StripeOdd
      else
        sgTableExample.Canvas.Brush.Color := StripeEven;
    end;
  end;

  sgTableExample.Canvas.FillRect(Rect);
  sgTableExample.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, 'Текст');
end;

{
  Шрифт колонки.
}

procedure TdlgMaster.actColumnFontExecute(Sender: TObject);
var
  I: Integer;
  List: TList;
begin
  FFontDlg.Font := CurrColumn.Font;
  if FFontDlg.Execute then
  begin
    if lvColumns.SelCount = 1 then
      CurrColumn.Font.Assign(FFontDlg.Font)
    else begin
      List := TList.Create;
      try
        GetSelectedColumns(List);

        for I := 0 to List.Count - 1 do
          TgsColumn(List[I]).Font.Assign(FFontDlg.Font);
      finally
        List.Free;
      end;
    end;

    sgColumn.Invalidate;
  end;
end;

{
  Цвет колонки.
}

procedure TdlgMaster.actColumnColorExecute(Sender: TObject);
var
  I: Integer;
  List: TList;
begin
  FColorDlg.Color := CurrColumn.Color;
  FColorDlg.CustomColors.Add('ColorA=' + IntToHex(CurrColumn.Color, 4));
  if FColorDlg.Execute then
  begin
    if lvColumns.SelCount = 1 then
      CurrColumn.Color := FColorDlg.Color
    else begin
      List := TList.Create;
      try
        GetSelectedColumns(List);

        for I := 0 to List.Count - 1 do
          TgsColumn(List[I]).Color := FColorDlg.Color;
      finally
        List.Free;
      end;
    end;

    sgColumn.Invalidate;
  end;
  FColorDlg.CustomColors.Clear;
end;

{
  Шрифт заглавия колонки.
}

procedure TdlgMaster.actColumnTitleFontExecute(Sender: TObject);
var
  I: Integer;
  List: TList;
begin
  FFontDlg.Font := CurrColumn.Title.Font;
  if FFontDlg.Execute then
  begin
    if lvColumns.SelCount = 1 then
      CurrColumn.Title.Font.Assign(FFontDlg.Font)
    else begin
      List := TList.Create;
      try
        GetSelectedColumns(List);

        for I := 0 to List.Count - 1 do
          TgsColumn(List[I]).Title.Font.Assign(FFontDlg.Font);
      finally
        List.Free;
      end;
    end;

    sgColumn.Invalidate;
  end;
end;

{
  Цвет заглавия колонки.
}

procedure TdlgMaster.actColumnTitleColorExecute(Sender: TObject);
var
  I: Integer;
  List: TList;
begin
  FColorDlg.Color := CurrColumn.Title.Color;
  FColorDlg.CustomColors.Add('ColorA=' + IntToHex(CurrColumn.Title.Color, 4));
  if FColorDlg.Execute then
  begin
    if lvColumns.SelCount = 1 then
      CurrColumn.Title.Color := FColorDlg.Color
    else begin
      List := TList.Create;
      try
        GetSelectedColumns(List);

        for I := 0 to List.Count - 1 do
          TgsColumn(List[I]).Title.Color := FColorDlg.Color;
      finally
        List.Free;
      end;
    end;

    sgColumn.Invalidate;
  end;
  FColorDlg.CustomColors.Clear;
end;

{
  Рисование примера для колонки.
}

procedure TdlgMaster.sgColumnDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  Column: TgsColumn;
  L: Integer;
begin
  Column := CurrColumn;
  if not Assigned(Column) then Exit;

  if gdFixed in State then
  begin
    sgColumn.Canvas.Font := Column.Title.Font;
    sgColumn.Canvas.Brush.Color := Column.Title.Color;
    sgColumn.Canvas.FillRect(Rect);

    case Column.Title.Alignment of
      taLeftJustify:
        L := Rect.Left + 2;
      taRightJustify:
        L := Rect.Right - sgColumn.Canvas.TextWidth(Column.Title.Caption) - 3;
    else { taCenter }
      L := Rect.Left + (Rect.Right - Rect.Left) shr 1
        - (sgColumn.Canvas.TextWidth(Column.Title.Caption) shr 1);
    end;

    sgColumn.Canvas.TextRect(Rect, L, Rect.Top + 2, Column.Title.Caption);
    Exit;
  end;

  if (State * [gdFocused, gdSelected]) <> [] then
  begin
    sgColumn.Canvas.Font := SelectedFont;
    sgColumn.Canvas.Brush.Color := SelectedColor;
  end else begin
    sgColumn.Canvas.Font := Column.Font;
    sgColumn.Canvas.Brush.Color := Column.Color;
  end;

  sgColumn.Canvas.FillRect(Rect);

  case Column.Alignment of
    taLeftJustify:
      L := Rect.Left + 2;
    taRightJustify:
      L := Rect.Right - sgColumn.Canvas.TextWidth('Текст') - 3;
  else { taCenter }
    L := Rect.Left + (Rect.Right - Rect.Left) shr 1
      - (sgColumn.Canvas.TextWidth('Текст') shr 1);
  end;
  
  sgColumn.Canvas.TextRect(Rect, L, Rect.Top + 2, 'Текст');
end;

{
  Указывает видимые колонки.
}

procedure TdlgMaster.actVisibleExecute(Sender: TObject);
var
  List: TList;
  I: Integer;
begin
  if FPreparingForEditing then
    exit;

  if cbColumnVisible.State <> cbGrayed then
  begin
    if lvColumns.SelCount = 1 then
      CurrColumn.Visible := cbColumnVisible.Checked
    else begin
      List := TList.Create;
      try
        GetSelectedColumns(List);

        for I := 0 to List.Count - 1 do
          TgsColumn(List[I]).Visible := cbColumnVisible.Checked;
      finally
        List.Free;
      end;
    end;
  end;

  if cbColReadOnly.State <> cbGrayed then
  begin
    if lvColumns.SelCount = 1 then
      CurrColumn.ReadOnly := cbColReadOnly.Checked
    else begin
      List := TList.Create;
      try
        GetSelectedColumns(List);

        for I := 0 to List.Count - 1 do
          TgsColumn(List[I]).ReadOnly := cbColReadOnly.Checked;
      finally
        List.Free;
      end;
    end;
  end;

  if cbTotal.State <> cbGrayed then
  begin
    if lvColumns.SelCount = 1 then
    begin
      if cbTotal.Checked then
        CurrColumn.TotalType := ttSum
      else
        CurrColumn.TotalType := ttNone;
    end else begin
      List := TList.Create;
      try
        GetSelectedColumns(List);

        for I := 0 to List.Count - 1 do
          if cbTotal.Checked then
            TgsColumn(List[I]).TotalType := ttSum
          else
            TgsColumn(List[I]).TotalType := ttNone;
      finally
        List.Free;
      end;
    end;
  end;

  lvColumns.Repaint;
end;

{
  Разрешаем редактировать кол-во строчек.
}

procedure TdlgMaster.actColumnLineCountExecute(Sender: TObject);
var
  TheExpand: TColumnExpand;
begin
  editColumnLineCount.Enabled := cbColumnLineCount.Checked;
  if not cbColumnLineCount.Checked then
  begin
    editColumnLineCount.IntValue := 1;
    TheExpand := FindCurrExpand;
    if Assigned(TheExpand) then TheExpand.Free;
  end;
end;

{
  Разрешаем редактировать расширенное отображение
}

procedure TdlgMaster.actColumnExpanededExecute(Sender: TObject);
begin
  lbExpandedLines.Enabled := cbColumnExpanded.Checked;

  btnAddExp.Enabled := cbColumnExpanded.Checked;
  btnDeleteExp.Enabled := cbColumnExpanded.Checked and (lbExpandedLines.Items.Count >= 0);
  btnEditExp.Enabled := cbColumnExpanded.Checked and (lbExpandedLines.ItemIndex >= 0);

  btnUpExp.Enabled := cbColumnExpanded.Checked;
  btnDownExp.Enabled := cbColumnExpanded.Checked;

  lbExpandedLinesClick(lbExpandedLines);
end;

{
  Изменяется заглавие колонки.
}

procedure TdlgMaster.editColumnTitleChange(Sender: TObject);
begin
  if Assigned(CurrColumn) then
  begin
    CurrColumn.Title.Caption := editColumnTitle.Text;
    lvColumns.Selected.Caption := editColumnTitle.Text;
  end;
end;

{
  При выходе из контрола формата отображения
  устанавливаем формат вывода поля.
}

procedure TdlgMaster.editColumnFormatExit(Sender: TObject);
var
  I: Integer;
begin
  if lvColumns.SelCount = 1 then
    CurrColumn.DisplayFormat := editColumnFormat.Text
  else
    for I := 0 to lvColumns.Items.Count - 1 do
      if lvColumns.Items[I].Selected then
        TgsColumn(lvColumns.Items[I].Data).DisplayFormat := editColumnFormat.Text


end;

{
  Выравнивание колонки.
}

procedure TdlgMaster.rgColumnAlignClick(Sender: TObject);
var
  I: Integer;
  List: TList;
begin
  if lvColumns.SelCount = 1 then
  begin
    case rgColumnAlign.ItemIndex of
      0: CurrColumn.Alignment := taLeftJustify;
      1: CurrColumn.Alignment := taCenter;
      2: CurrColumn.Alignment := taRightJustify;
    end;
  end else begin
    List := TList.Create;
    try
      GetSelectedColumns(List);

      for I := 0 to List.Count - 1 do
        case rgColumnAlign.ItemIndex of
          0: TgsColumn(List[I]).Alignment := taLeftJustify;
          1: TgsColumn(List[I]).Alignment := taCenter;
          2: TgsColumn(List[I]).Alignment := taRightJustify;
        end;
    finally
      List.Free;
    end;
  end;

  sgColumn.Invalidate;
end;

{
  Выравнивание заглавия.
}

procedure TdlgMaster.rgColumnTitleAlignClick(Sender: TObject);
var
  I: Integer;
  List: TList;
begin
  if lvColumns.SelCount = 1 then
  begin
    case rgColumnTitleAlign.ItemIndex of
      0: CurrColumn.Title.Alignment := taLeftJustify;
      1: CurrColumn.Title.Alignment := taCenter;
      2: CurrColumn.Title.Alignment := taRightJustify;
    end;
  end else begin
    List := TList.Create;
    try
      GetSelectedColumns(List);

      for I := 0 to List.Count - 1 do
        case rgColumnTitleAlign.ItemIndex of
          0: TgsColumn(List[I]).Title.Alignment := taLeftJustify;
          1: TgsColumn(List[I]).Title.Alignment := taCenter;
          2: TgsColumn(List[I]).Title.Alignment := taRightJustify;
        end;
    finally
      List.Free;
    end;
  end;
  
  sgColumn.Invalidate;
end;

{
  Добавление нового элемента расширенного отображения.
}

procedure TdlgMaster.actColumnAddExpExecute(Sender: TObject);
var
  NewExpand: TColumnExpand;
  Column: TgsColumn;
begin
  NewExpand := FNewExpands.Add;
  NewExpand.DisplayField := CurrField.FieldName;
  NewExpand.Options := [ceoAddField];

  with TdlgColumnExpand.Create(Self, FNewColumns, CurrColumn, NewExpand, False) do
  try
    if ShowModal <> mrOk then
      NewExpand.Free
    else begin
      PrepareExpands(CurrColumn);
      cbColumnExpanded.Checked := True;
      Column := ColumnByFieldName(NewExpand.FieldName);
      if (Column <> nil) and not FNewExpands.IsMain(Column) then
      begin
        Column.Visible := False;
        lvColumns.Invalidate;
      end;
    end;
  finally
    Free;
  end;
end;

{
  Удаление элемента расширенного отображения.
}

procedure TdlgMaster.actColumnDeleteExpExecute(Sender: TObject);
begin
  Assert(lbExpandedLines.ItemIndex >= 0, 'No Expand Selected');

  TColumnExpand(lbExpandedLines.Items.Objects[lbExpandedLines.ItemIndex]).Free;
  PrepareExpands(CurrColumn);
end;

{
  Перемещение вверх.
}

procedure TdlgMaster.actColumnUpExpExecute(Sender: TObject);
var
  Upper, Lower: TColumnExpand;
begin
  Lower := lbExpandedLines.Items.Objects[lbExpandedLines.ItemIndex] as TColumnExpand;
  Upper := lbExpandedLines.Items.Objects[lbExpandedLines.ItemIndex - 1] as TColumnExpand;

  Lower.Index := Upper.Index;

  // Обновляем отображение элементов
  PrepareExpands(CurrColumn);
  lbExpandedLines.ItemIndex := ItemIndexByExpand(Lower);
  lbExpandedLinesClick(lbExpandedLines);
end;

{
  Перемещение вниз.
}

procedure TdlgMaster.actColumnDownExpExecute(Sender: TObject);
var
  Upper, Lower: TColumnExpand;
begin
  Upper := lbExpandedLines.Items.Objects[lbExpandedLines.ItemIndex] as TColumnExpand;
  Lower := lbExpandedLines.Items.Objects[lbExpandedLines.ItemIndex + 1] as TColumnExpand;

  Upper.Index := Lower.Index;

  // Обновляем отображение элементов
  PrepareExpands(CurrColumn);
  lbExpandedLines.ItemIndex := ItemIndexByExpand(Upper);
  lbExpandedLinesClick(lbExpandedLines);
end;

procedure TdlgMaster.actColumnEditExpExecute(Sender: TObject);
var
  E: TColumnExpand;
  C: TgsColumn;
begin
  E :=  TColumnExpand(lbExpandedLines.Items.Objects[lbExpandedLines.ItemIndex]);
  with TdlgColumnExpand.Create
  (
    Self,
    FNewColumns,
    CurrColumn,
    E,
    True
  ) do
  try
    if ShowModal = mrOk then
    begin
      PrepareExpands(CurrColumn);
      C := ColumnByFieldName(E.FieldName);
      if (C <> nil) and not FNewExpands.IsMain(C) then
      begin
        C.Visible := False;
        lvColumns.Invalidate;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TdlgMaster.lbExpandedLinesClick(Sender: TObject);
begin
  btnEditExp.Enabled := lbExpandedLines.ItemIndex >= 0;
  btnDeleteExp.Enabled := lbExpandedLines.ItemIndex >= 0;
  btnUpExp.Enabled :=
    (lbExpandedLines.ItemIndex > 0) and (lbExpandedLines.Items.Count > 1);
  btnDownExp.Enabled :=
    (lbExpandedLines.ItemIndex >= 0) and
    (lbExpandedLines.ItemIndex < lbExpandedLines.Items.Count - 1) and
    (lbExpandedLines.Items.Count > 1);
end;

procedure TdlgMaster.editColumnLineCountChange(Sender: TObject);
var
  TheExpand: TColumnExpand;
begin
  if not cbColumnLineCount.Checked then Exit;
  TheExpand := FindCurrExpand;

  if not Assigned(TheExpand) then
    TheExpand := FNewExpands.Add;

  TheExpand.Options := [ceoMultiline];
  TheExpand.DisplayField := CurrColumn.FieldName;
  TheExpand.LineCount := editColumnLineCount.IntValue;

  if TheExpand.LineCount = 1 then
    TheExpand.Free;

  if editColumnLineCount.IntValue > 1 then
    cbColumnExpanded.Checked := True;
end;

procedure TdlgMaster.lvColumnsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
  I: Integer;
begin
  if Selected then
  begin
    EditColumn(lvColumns.Selected.Data);
    sgColumn.Invalidate;
  end;

  if not FBlockColumnSelection then
  begin
    FBlockColumnSelection := True;

    try
      for I := 0 to lvColumns.Items.Count - 1 do
        if not lvColumns.Items[I].Selected then
        begin
          cbColumnsChooseAll.Checked := False;
          Exit;
        end;

      cbColumnsChooseAll.Checked := True;
    finally
      FBlockColumnSelection := False;
    end;
  end;
end;

procedure TdlgMaster.actColumnSeparateExpExecute(Sender: TObject);
begin
//
end;

{
  Запрет или разрешение на редактирование условий.
}

procedure TdlgMaster.actConditionsActiveExecute(Sender: TObject);
begin
  EnableConditions(cbConditionActive.Checked, True);
end;

{
  Подготавливаем условия к редактированию.
}

procedure TdlgMaster.lbConditionsClick(Sender: TObject);
begin
  if (lbConditions.Items.Count > 0) and cbConditionActive.Checked then
  begin
    EnableConditions(True, False);
    //actConditionUp.Enabled := lbConditions.ItemIndex > 0;
    //actConditionDown.Enabled := lbConditions.ItemIndex < lbConditions.Items.Count - 1;
  end else begin
    editConditionName.Text := '';

    editConditionColumn.ItemIndex := -1;

    editConditionKind.ItemIndex := -1;

    editConditionText1.Text := '';
    editConditionText2.Text := '';
    cbEvaluateExpression.Checked := False;

    EnableConditions(False, not cbConditionActive.Checked);

    lbConditionColumns.Items.Clear;
  end;

  PrepareConditionButtons;
end;

{
  Устанавливает изменение наименования условия.
}

procedure TdlgMaster.editConditionNameChange(Sender: TObject);
begin
  if Assigned(CurrCondition) and cbConditionActive.Checked then
  begin
    CurrCondition.ConditionName := editConditionName.Text;
    lbConditions.Items[lbConditions.ItemIndex] := editConditionName.Text;
  end;
end;

{
  Устанавливает изменение поля условия.
}

procedure TdlgMaster.editConditionColumnClick(Sender: TObject);
begin
  if
    Assigned(CurrCondition)
      and
    cbConditionActive.Checked
      and
    (editConditionColumn.ItemIndex >= 0)
  then
    CurrCondition.FieldName := PString(editConditionColumn.Items.Objects[editConditionColumn.ItemIndex])^;
//    CurrCondition.FieldName := FFields[editConditionColumn.ItemIndex];
end;

{
  Устанавливается операция условного форматирования.
}

procedure TdlgMaster.editConditionKindClick(Sender: TObject);
begin
  if Assigned(CurrCondition) and cbConditionActive.Checked then
  begin
    CurrCondition.ConditionKind := ConditionKindByIndex[editConditionKind.ItemIndex];

    editConditionText1.Visible :=
      not (CurrCondition.ConditionKind in [ckExist, ckNotExist]);

    editConditionText2.Visible := CurrCondition.ConditionKind in [ckIn, ckOut];
    lblAnd.Visible := CurrCondition.ConditionKind in [ckIn, ckOut];
  end;
end;

{
  Устанавливаем текст первого условия.
}

procedure TdlgMaster.editConditionText1Change(Sender: TObject);
begin
  if Assigned(CurrCondition) and cbConditionActive.Checked then
    CurrCondition.Expression1 := editConditionText1.Text;
end;

{
  Устанавливаем текст второго условия.
}

procedure TdlgMaster.editConditionText2Change(Sender: TObject);
begin
  if Assigned(CurrCondition) and cbConditionActive.Checked then
    CurrCondition.Expression2 := editConditionText2.Text;
end;

{
  Устанавливается флаг расчета формул.
}

procedure TdlgMaster.cbEvaluateExpressionClick(Sender: TObject);
begin
  if Assigned(CurrCondition) and cbConditionActive.Checked then
    CurrCondition.EvaluateFormula := cbEvaluateExpression.Checked;
end;

{
  Добавление нового условия.
}

procedure TdlgMaster.actConditionAddExecute(Sender: TObject);
var
  Condition: TCondition;
begin
  cbConditionActive.Checked := True;
  CheckConditions;

  Condition := FNewConditions.Add;
  lbConditions.Items.Add('');
  lbConditions.Items.Objects[lbConditions.Items.Count - 1] := Condition;
  lbConditions.ItemIndex := lbConditions.Items.Count - 1;
  lbConditionsClick(lbConditions);

  pcConditions.ActivePageIndex := 0;
  editConditionName.SetFocus;
  actConditionDelete.Enabled := lbConditions.Items.Count > 0;
end;

{
  Удаление условия.
}

procedure TdlgMaster.actConditionDeleteExecute(Sender: TObject);
var
  Index: Integer;
begin
  Index := lbConditions.ItemIndex;
  FNewConditions[Index].Free;
  lbConditions.Items.Delete(Index);

  if lbConditions.Items.Count > 0 then
    if lbConditions.Items.Count - 1 >= Index then
      lbConditions.ItemIndex := Index
    else
      lbConditions.ItemIndex := lbConditions.Items.Count - 1;

  actConditionDelete.Enabled := lbConditions.Items.Count > 0;
  lbConditionsClick(lbConditions);
end;

{
  Условие вверх.
}

procedure TdlgMaster.actConditionUpExecute(Sender: TObject);
begin
  (lbConditions.Items.Objects[lbConditions.ItemIndex] as TCondition).Index :=
    lbConditions.ItemIndex - 1;

  lbConditions.Items.Exchange(lbConditions.ItemIndex, lbConditions.ItemIndex - 1);
  lbConditionsClick(lbConditions);
end;

{
  Условие вниз.
}

procedure TdlgMaster.actConditionDownExecute(Sender: TObject);
begin
  (lbConditions.Items.Objects[lbConditions.ItemIndex] as TCondition).Index :=
    lbConditions.ItemIndex + 1;

  lbConditions.Items.Exchange(lbConditions.ItemIndex, lbConditions.ItemIndex + 1);
  lbConditionsClick(lbConditions);
end;

procedure TdlgMaster.actConditionFontExecute(Sender: TObject);
begin
  FFontDlg.Font := pnlConditionPreview.Font;

  if FFontDlg.Execute then
  begin
    pnlConditionPreview.Font := FFontDlg.Font;
    CurrCondition.Font := FFontDlg.Font;
  end;
end;

procedure TdlgMaster.actConditionColorExecute(Sender: TObject);
begin
  FColorDlg.Color := pnlConditionPreview.Color;
  FColorDlg.CustomColors.Add('ColorA=' + IntToHex(pnlConditionPreview.Color, 4));
  if FColorDlg.Execute then
  begin
    pnlConditionPreview.Color := FColorDlg.Color;
    CurrCondition.Color := FColorDlg.Color;
  end;
  FColorDlg.CustomColors.Clear;
end;

procedure TdlgMaster.btnConditionFontUseClick(Sender: TObject);
begin
  if Assigned(CurrCondition) and cbConditionActive.Checked then
  begin
    btnConditionFont.Enabled := cbConditionFontUse.Checked;
    pnlConditionPreview.ParentFont := not cbConditionFontUse.Checked;

    if cbConditionFontUse.Checked then
    begin
      pnlConditionPreview.Font := CurrCondition.Font;
      CurrCondition.DisplayOptions := CurrCondition.DisplayOptions + [doFont];
    end else
      CurrCondition.DisplayOptions := CurrCondition.DisplayOptions - [doFont];
  end;
end;

procedure TdlgMaster.btnConditionColorUseClick(Sender: TObject);
begin
  if Assigned(CurrCondition) and cbConditionActive.Checked then
  begin
    btnConditionColor.Enabled := cbConditionColorUse.Checked;
    pnlConditionPreview.ParentColor := not cbConditionColorUse.Checked;

    if cbConditionColorUse.Checked then
    begin
      pnlConditionPreview.Color := CurrCondition.Color;
      CurrCondition.DisplayOptions := CurrCondition.DisplayOptions + [doColor];
    end else
      CurrCondition.DisplayOptions := CurrCondition.DisplayOptions - [doColor];
  end;
end;

{
  Выбор колонок отображения для условия.
}

procedure TdlgMaster.actConditionColumnsExecute(Sender: TObject);
var
  I: Integer;
  Fields: String;
  Column: TColumn;
begin
  with TdlgConditionColumns.Create(Self) do
  try
    for I := 0 to FDataLink.DataSet.FieldCount - 1 do
    begin
      Column := ColumnByFieldName(FDataLink.DataSet.Fields[I].FieldName);
      if Assigned(Column) then
      begin
        clbFields.Items.Add(Column.Title.Caption);
        clbFields.Items.Objects[clbFields.Items.Count - 1] := FDataLink.DataSet.Fields[I];
        if CurrCondition.Suits(FDataLink.DataSet.Fields[I]) then
          clbFields.State[clbFields.Items.Count - 1] := cbChecked;
      end;
    end;

    if ShowModal = mrOk then
    begin
      Fields := '';

      for I := 0 to clbFields.Items.Count - 1 do
        if clbFields.State[I] = cbChecked then
          Fields := Fields + TField(clbFields.Items.Objects[I]).FieldName + ';';

      CurrCondition.DisplayFields := Fields;
      UpdateConditionVisibleColumns;
    end;
  finally
    Free;
  end;
end;

{
  Разрешаем редактировать формат колонки.
}

procedure TdlgMaster.actColumnFormatExecute(Sender: TObject);
begin
  editColumnFormat.Enabled := cbColumnFormat.Checked;
  actChooseColumnFormat.Enabled := cbColumnFormat.Checked;
  if not actChooseColumnFormat.Enabled then
  begin
    editColumnFormat.Text := '';
    CurrColumn.DisplayFormat := editColumnFormat.Text;
  end else

  if editColumnFormat.Enabled and (editColumnFormat.Text = '') then
    actChooseColumnFormat.Execute;
end;

{
  Выбр формата отображения данных колонки.
}

procedure TdlgMaster.actChooseColumnFormatExecute(Sender: TObject);
begin
  with TdlgColFormat.Create(Self, CurrField) do
  try
    if ShowModal = mrOk then
    begin
      editColumnFormat.Text := DisplayFormat;
      editColumnFormatExit(editColumnFormat);
    end;
  finally
    Free;
  end;
end;

{
  Выбор шаблона настроек
}

procedure TdlgMaster.actTemplateExecute(Sender: TObject);
var
  I: Integer;
  TheField: TField;
begin
  case lbTemplate.ItemIndex of
  0: // Стандартная таблица
  begin
    Striped := False;

    //FNewColumns.RestoreDefaults;
    sgTableExample.Color := clWindow;
    sgTableExample.FixedColor := clBtnFace;
    FTitleColor := clBtnFace;
    FSelectedColor := clHighlight;

    FSelectedFont.Assign(GetParentForm(Grid).Font);
    FSelectedFont.Color := clHighlightText;

    sgTableExample.Font := GetParentForm(Grid).Font;
    FTitleFont.Assign(GetParentForm(Grid).Font);
    sgTableExample.Invalidate;
  end;
  1: // Полосатая таблица
  begin
    //FNewColumns.RestoreDefaults;

    StripeEven := DefStripeEven;
    StripeOdd := DefStripeOdd;
    Striped := True;

    sgTableExample.Color := clWindow;
    sgTableExample.FixedColor := clBtnFace;
    FTitleColor := clBtnFace;
    FSelectedColor := $009CDFF7;

    FSelectedFont.Assign(GetParentForm(Grid).Font);
    FSelectedFont.Color := Font.Color;

    sgTableExample.Font := GetParentForm(Grid).Font;
    FTitleFont.Assign(GetParentForm(Grid).Font);
    sgTableExample.Invalidate;
  end;
  2: // Изысканный формат
  begin
    //FNewColumns.RestoreDefaults;

    StripeEven := DefStripeEven;
    StripeOdd := DefStripeOdd;
    Striped := True;

    sgTableExample.Color := DefStripeEven;
    sgTableExample.FixedColor := DefStripeEven;
    FTitleColor := DefStripeEven;

    FSelectedColor := $009CDFF7;

    FSelectedFont.Assign(Font);
    FSelectedFont.Name := 'Times New Roman';
    FSelectedFont.Color := Font.Color;
    FSelectedFont.Size := 10;
    FSelectedFont.Style := [fsBold];

    sgTableExample.Font := Font;
    sgTableExample.Font.Name := 'Times New Roman';
    sgTableExample.Font.Size := 10;

    FTitleFont.Assign(Font);
    FTitleFont.Name := 'Times New Roman';
    FTitleFont.Style := [fsBold, fsItalic];
    FTitleFont.Size := 10;

    for I := 0 to FNewColumns.Count - 1 do
    begin
      FNewColumns[I].Color := sgTableExample.Color;
      FNewColumns[I].Font := sgTableExample.Font;
      FNewColumns[I].Title.Color := FTitleColor;
      FNewColumns[I].Title.Font := FTitleFont;
    end;

    sgTableExample.Invalidate;
  end;
  3: ; // Пропускаем
  4: // Разделители в числах
  begin
    for I := 0 to FNewColumns.Count - 1 do
    begin
      TheField := FDataLink.DataSet.FindField((FNewColumns[I] as TgsColumn).
        FieldName);

      if
        Assigned(TheField) and (TheField.DataType in
          [ftCurrency, ftFloat, ftBCD])
      then
        FNewColumns[I].DisplayFormat := '#,##0.00';
    end;
  end;
  5: // Без дробной части
  begin
    for I := 0 to FNewColumns.Count - 1 do
    begin
      TheField := FDataLink.DataSet.FindField((FNewColumns[I] as TgsColumn).
        FieldName);

      if Assigned(TheField) and (TheField.DataType in [ftCurrency, ftFloat, ftBCD]) then
        FNewColumns[I].DisplayFormat := '#,##0';
    end;
  end;
  6: ; // Пропускаем
  7: // Только строковые колонки
  begin
    for I := 0 to FNewColumns.Count - 1 do
    begin
      TheField := FDataLink.DataSet.FindField((FNewColumns[I] as TgsColumn).
        FieldName);

      FNewColumns[I].Visible :=
        Assigned(TheField)
          and
        (TheField.DataType in [ftString, ftMemo, ftFmtMemo, ftWideString]);
    end;
  end;
  8: // Только числовые колонки
  begin
    for I := 0 to FNewColumns.Count - 1 do
    begin
      TheField := FDataLink.DataSet.FindField((FNewColumns[I] as TgsColumn).
        FieldName);

      FNewColumns[I].Visible :=
        Assigned(TheField)
          and
        (TheField.DataType in [ftCurrency, ftFloat, ftBCD, ftInteger, ftSmallInt]);
    end;
  end;
  end;
end;

{
  Выбор всех колонок.
}

procedure TdlgMaster.cbColumnsChooseAllClick(Sender: TObject);
var
  I: Integer;
  Checked: Boolean;
  OldSelected: TListItem;
begin
  if not FBlockColumnSelection then
  begin
    FBlockColumnSelection := True;

    try
      lvColumns.Items.BeginUpdate;
      Checked := cbColumnsChooseAll.Checked;
      OldSelected := lvColumns.Selected;

      for I := 0 to lvColumns.Items.Count - 1 do
        lvColumns.Items[I].Selected := Checked;

      lvColumns.Selected := OldSelected;
      OldSelected.Focused := True;

      lvColumns.Items.EndUpdate;
    finally
      FBlockColumnSelection := False;
    end;
  end;
end;

procedure TdlgMaster.actLoadQueryExecute(Sender: TObject);
begin
  with TOpenDialog.Create(Self) do
  try
    DefaultExt := '*.sql';
    Filter := '*.sql|*.sql';
    Title := 'Загрузить текст из файла.';
    if Execute then
      seQuery.Lines.LoadFromFile(FileName);
  finally
    Free;
  end;
end;

procedure TdlgMaster.actSaveQueryExecute(Sender: TObject);
begin
  with TSaveDialog.Create(Self) do
  try
    DefaultExt := '*.sql';
    Filter := '*.sql|*.sql';
    Title := 'Сохранить текст в файл.';
    if Execute then
      seQuery.Lines.SaveToFile(FileName);
  finally
    Free;
  end;
end;

procedure TdlgMaster.actApplyQueryExecute(Sender: TObject);
begin
  if Assigned(FQueryChanged) then
  begin
    FDataLink.DataSet.Close;
    FQueryChanged(Self, False);
    FDataLink.DataSet.Open;
  end;
end;

procedure TdlgMaster.actApplyQueryWithPlanExecute(Sender: TObject);
begin
  if Assigned(FQueryChanged) then
  begin
    FDataLink.DataSet.Close;
    FQueryChanged(Self, True);
    FDataLink.DataSet.Open;
  end;
end;

procedure TdlgMaster.actLoadTemplateExecute(Sender: TObject);
var
  Stream: TFileStream;
begin
  with TOpenDialog.Create(Self) do
  try
    DefaultExt := '*.dbg';
    Filter := '*.dbg|*.dbg';
    Title := 'Загрузить шаблон из файла.';
    if Execute then
    begin
      try
        Stream := TFileStream.Create(FileName, fmOpenRead);

        try
          LoadFromStream(Stream);
        finally
          Stream.Free;
        end;
      except
        raise EgsDBGridException.Create(Format('Can''t read from file %s', [FileName]));
      end;
    end;
  finally
    Free;
  end;
end;

procedure TdlgMaster.actSaveTemplateExecute(Sender: TObject);
var
  Stream: TFileStream;
begin
  with TSaveDialog.Create(Self) do
  try
    DefaultExt := '*.dbg';
    Filter := '*.dbg|*.dbg';
    Title := 'Сохранить шаблон в файл.';
    if Execute then
    begin
      if
        not FileExists(FileName)
          or
        (MessageBox(Handle, PChar(Format('Заменить существующий файл %s?', [FileName])),
          'Внимание', MB_YESNO or MB_ICONQUESTION) = ID_YES)
      then
      try
        Stream := TFileStream.Create(FileName, fmCreate);

        try
          SaveToStream(Stream);
        finally
          Stream.Free;
        end;
      except
        raise EgsDBGridException.Create(Format('Can''t write to file %s', [FileName]));
      end;
    end;
  finally
    Free;
  end;
end;

procedure TdlgMaster.actCutQueryExecute(Sender: TObject);
begin
  seQuery.CutToClipboard;
end;

procedure TdlgMaster.actCopyQueryExecute(Sender: TObject);
begin
  seQuery.CopyToClipboard;
end;

procedure TdlgMaster.actPasteQueryExecute(Sender: TObject);
begin
  seQuery.PasteFromClipboard;
end;

procedure TdlgMaster.editColumnWidthChange(Sender: TObject);
var
  I: Integer;
  TheColumn: TgsColumn;
begin
  for I := 0 to lvColumns.Items.Count - 1 do
    if lvColumns.Items[I].Selected then
    begin
      TheColumn := lvColumns.Items[I].Data;
      Canvas.Font := TheColumn.Font;
      TheColumn.Width := SymbolsToPixels(editColumnWidth.IntValue, Canvas);
    end;
end;

procedure TdlgMaster.pcOptionsChange(Sender: TObject);
var
  I, II: Integer;
begin
  if pcOptions.ActivePage = tsCondition then
  begin
    // Список колонок для раздела условного форматирования
    II := editConditionColumn.ItemIndex;
    for I := 0 to FNewColumns.Count - 1 do
      editConditionColumn.Items[I] := FNewColumns[I].Title.Caption;
    editConditionColumn.ItemIndex := II;  
  end;
end;

procedure TdlgMaster.lvColumnsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept :=
    (Sender = lvColumns)
      and
    Assigned(lvColumns.GetItemAt(X, Y))
      and
    not lvColumns.GetItemAt(X, Y).Selected;
end;

procedure TdlgMaster.lvColumnsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  I, K: Integer;
  Columns: TgsColumns;
  NewColumn: TgsColumn;
  Item: TListItem;
  VisibleIndex: Integer;
  SelectedList: TList;
  P: PString;
  FN: String;
begin
  if Assigned(lvColumns.DropTarget) then
  begin
    Columns := TgsColumns.Create(nil, TgsColumn, True);
    SelectedList := TList.Create;

    lvColumns.Items.BeginUpdate;
    FNewColumns.BeginUpdate;
    VisibleIndex := lvColumns.DropTarget.Index;

    try
      I := 0;
      while I < lvColumns.DropTarget.Index do
        if not lvColumns.Items[I].Selected then
        begin
          NewColumn := Columns.Add;
          NewColumn.Assign(lvColumns.Items[I].Data);
          lvColumns.Items[I].Delete;
        end else
          Inc(I);

      I := 0;
      while I < lvColumns.Items.Count do
        if lvColumns.Items[I].Selected then
        begin
          NewColumn := Columns.Add;
          NewColumn.Assign(lvColumns.Items[I].Data);
          SelectedList.Add(NewColumn);
          lvColumns.Items[I].Delete;
        end else
          Inc(I);

      for I := 0 to lvColumns.Items.Count - 1 do
      begin
        NewColumn := Columns.Add;
        NewColumn.Assign(lvColumns.Items[I].Data);
      end;

      FNewColumns.Free;
      FNewColumns := Columns;

      lvColumns.Items.Clear;
      if editConditionColumn.ItemIndex = -1 then
        FN := ''
      else
        FN := PString(editConditionColumn.Items.Objects[editConditionColumn.ItemIndex])^;
      editConditionColumn.Items.Clear;

      for I := 0 to FNewColumns.Count - 1 do
      begin
        Item := lvColumns.Items.Add;
        Item.Caption := FNewColumns[I].Title.Caption;
        Item.SubItems.Add(FNewColumns[I].FieldName);
        Item.Data := FNewColumns[I];

        for K := SelectedList.Count - 1 downto 0 do
          if SelectedList[K] = FNewColumns[I] then
          begin
            Item.Selected := True;
            SelectedList.Delete(K);
            Break;
          end;

        New(P);
        FFields.Add(P);
        P^ := FNewColumns[I].FieldName;
        editConditionColumn.Items.AddObject(FNewColumns[I].Title.Caption,
          Pointer(P));
      end;

      if FN > '' then
        for I := 0 to editConditionColumn.Items.Count - 1 do
        begin
          if AnsiCompareText(FN, PString(editConditionColumn.Items.Objects[I])^) = 0 then
          begin
            editConditionColumn.ItemIndex := I;
            break;
          end;
        end;

    finally
      lvColumns.Items.EndUpdate;
      FNewColumns.EndUpdate;
      lvColumns.Items[VisibleIndex].MakeVisible(False);
      SelectedList.Free;
    end;
  end;
end;

{ TODO 1 -oденис -cнедочет : Нужно доделать серый цвет при выделении. }

procedure TdlgMaster.lvColumnsCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  TheColumn: TgsColumn;
begin
  TheColumn := Item.Data;
  with (Sender as TListView) do
  begin
    Canvas.Font := Font;

    if Item.Selected or Item.Focused then
    begin
      Canvas.Brush.Color := clHighlight;
      Canvas.Font.Color := clWhite;
    end else begin
      Canvas.Brush.Color := clWhite;
      Canvas.Font.Color := clBlack;
    end;

    if not TheColumn.Visible then
      Canvas.Font.Style := [fsStrikeOut];
  end;
end;

procedure TdlgMaster.actColumnTitleExpExecute(Sender: TObject);
begin
//
end;

procedure TdlgMaster.cbHorizLinesClick(Sender: TObject);
begin
  if cbHorizLines.Checked then
    Options := Options + [dgRowLines]
  else
    Options := Options - [dgRowLines];
end;

procedure TdlgMaster.UpdateColumnsView;
var
  I: Integer;
begin
  for I := 0 to FNewColumns.Count - 1 do
    lvColumns.Items[I].Caption := FNewColumns[I].Title.Caption;
end;

procedure TdlgMaster.actConditionDeleteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbConditions.Items.Count > 0;
end;

function TdlgMaster.GetShowTotals: Boolean;
begin
  Result := cbShowTotals.Checked;
end;

procedure TdlgMaster.SetShowTotals(const Value: Boolean);
begin
  cbShowTotals.Checked := Value;
end;

function TdlgMaster.GetShowFooter: Boolean;
begin
  Result := cbShowFooter.Checked;  
end;

procedure TdlgMaster.SetShowFooter(const Value: Boolean);
begin
  cbShowFooter.Checked := Value;
end;

procedure TdlgMaster.actFieldNameCopyExecute(Sender: TObject);
var
  i, SLen: Integer;
  Str: String;
  Mem: HGLOBAL;
  P: PChar;
  Failed: boolean;
begin
  Str := '';
  for i := 0 to lvColumns.Items.Count - 1 do
  begin
    if lvColumns.Items[i].Selected then
    begin
      if Length(Str) = 0 then
        Str := lvColumns.Items[i].SubItems[0]
      else
        Str := Str + #13#10 + lvColumns.Items[i].SubItems[0];
    end;
  end;
  SLen := Length(Str);
  if SLen > 0 then
  begin
    Failed := True;
    Clipboard.Open;
    try
      EmptyClipboard;
      Mem := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, SLen + 1);
      if Mem <> 0 then
      begin
        P := GlobalLock(Mem);
        try
          if P <> nil then
          begin
            Move(PChar(Str)^, P^, SLen + 1);
            Failed := SetClipboardData(CF_TEXT, Mem) = 0;
          end;
        finally
          GlobalUnlock(Mem);
        end;
      end;
    finally
      Clipboard.Close;
      if Failed then
        raise Exception.Create('Ошибка копирования в буфер.');
    end;
  end;
end;

procedure TdlgMaster.actUpperVisibleExecute(Sender: TObject);
var
  Columns: TgsColumns;
  VisibleIndex: Integer;
  NewColumn: TgsColumn;
  I: Integer;
  Item: TListItem;
  P: PString;
begin

  Columns := TgsColumns.Create(nil, TgsColumn, True);
  try
    lvColumns.Items.BeginUpdate;
    FNewColumns.BeginUpdate;

    if Assigned(lvColumns.Selected) then
      VisibleIndex := lvColumns.Selected.Index
    else
      VisibleIndex := -1;

    try
      for I := 0 to lvColumns.Items.Count - 1 do
      begin
        if TgsColumn(lvColumns.Items[I].Data).Visible then
        begin
          NewColumn := Columns.Add;
          NewColumn.Assign(lvColumns.Items[I].Data);
        end
      end;

      for I := 0 to lvColumns.Items.Count - 1 do
      begin
        if not TgsColumn(lvColumns.Items[I].Data).Visible then
        begin
          NewColumn := Columns.Add;
          NewColumn.Assign(lvColumns.Items[I].Data);
        end
      end;

      FNewColumns.Free;
      FNewColumns := Columns;
      Columns := nil;

      lvColumns.Items.Clear;

      for I := 0 to FNewColumns.Count - 1 do
      begin
        Item := lvColumns.Items.Add;
        Item.Caption := FNewColumns[I].Title.Caption;
        Item.SubItems.Add(FNewColumns[I].FieldName);
        Item.Data := FNewColumns[I];
        New(P);
        FFields.Add(P);
        P^ := FNewColumns[I].FieldName;
        editConditionColumn.Items.AddObject(FNewColumns[I].Title.Caption,
          Pointer(P));
      end;

    finally
      lvColumns.Items.EndUpdate;
      FNewColumns.EndUpdate;
      if VisibleIndex >= 0 then
      begin
        lvColumns.Selected := lvColumns.Items[VisibleIndex];
        lvColumns.Items[VisibleIndex].MakeVisible(False);
      end
    end;

  finally
    Columns.Free;
  end;
end;

procedure TdlgMaster.actResetExecute(Sender: TObject);
begin
  FReset := True;
  ModalResult := mrOk;
end;

procedure TdlgMaster.actHelpExecute(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TdlgMaster.FormCreate(Sender: TObject);
begin
  {$IFDEF LOCALIZATION}
  LocalizeComponent(Self);
  {$ENDIF}
end;

procedure TdlgMaster.actFieldNameCopyUpdate(Sender: TObject);
begin
  actFieldNameCopy.Enabled := pcOptions.ActivePage = tsColumn;
end;

procedure TdlgMaster.actFindUpdate(Sender: TObject);
begin
  actFind.Enabled := (pcOptions.ActivePage = tsColumn)
    and (lvColumns.Items.Count > 1);
end;

procedure TdlgMaster.actFindNextUpdate(Sender: TObject);
begin
  actFindNext.Enabled := (pcOptions.ActivePage = tsColumn)
    and (lvColumns.Items.Count > 1);
end;

procedure TdlgMaster.actFindExecute(Sender: TObject);
begin
  if InputQuery('Поиск', 'Введите наименование колонки или поля:', FSearchValue) then
  begin
    FindColumn(True)
  end else
    FSearchValue := '';
end;

procedure TdlgMaster.actFindNextExecute(Sender: TObject);
begin
  if FSearchValue = '' then
    actFind.Execute
  else
    FindColumn(False);
end;

procedure TdlgMaster.FindColumn(const FromStart: Boolean);
var
  K, I, J: Integer;
begin
  K := 0;
  if not FromStart then
  begin
    if lvColumns.Selected <> nil then
      K := lvColumns.Selected.Index + 1;
  end;
  for I := K to lvColumns.Items.Count - 1 do
  begin
    if (StrIPos(FSearchValue, lvColumns.Items[I].Caption) <> 0)
      or (StrIPos(FSearchValue, lvColumns.Items[I].SubItems[0]) <> 0) then
    begin
      lvColumns.ItemFocused := lvColumns.Items[I];
      lvColumns.Selected := lvColumns.Items[I];

      for J := 0 to lvColumns.Items.Count - 1 do
        if J <> I then
          lvColumns.Items[J].Selected := False;

      lvColumns.Items[I].MakeVisible(False);
      exit;
    end;
  end;
  if not FromStart then
    FindColumn(True)
  else
    MessageBox(Handle,
      'Заданное значение не найдено.',
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
end;

procedure TdlgMaster.actConditionUpUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (lbConditions.Items.Count > 0)
    and (lbConditions.ItemIndex > 0);
end;

procedure TdlgMaster.actConditionDownUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (lbConditions.Items.Count > 0)
    and (lbConditions.ItemIndex < (lbConditions.Items.Count - 1));
end;

end.

