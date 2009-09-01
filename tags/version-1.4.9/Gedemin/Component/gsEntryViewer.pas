
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gsEntryViewer.pas

  Abstract

    Super Viewer for accounting entries.

  Author

    Romanovski Denis (06-10-2001)

  Revisions history

    Initial  06-10-2001  Dennis  Initial version.


--}

unit gsEntryViewer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, Contnrs, IBDatabase, IBCustomDataSet, IBSQL;

const
  CONST_DATEFIELD = 'DOCUMENTDATE';

  CONST_DOCUMENTNUMBERFIELD = 'NUMBER';
  CONST_DOCUMENTNAMEFIELD = 'DOCUMENTNAME';

  CONST_TRANSACTIONNAMEFIELD = 'TRANSACTIONNAME';

  CONST_RECORDDESCRIPTIONFIELD = 'RECDESCRIPTION';

  CONST_ACCOUNTNAMEFIELD = 'ACCOUNTNAME';
  CONST_ACCOUNTALIASFIELD = 'ACCOUNTALIAS';
  CONST_ACCOUNTPARTFIELD = 'ACCOUNTPART';

  CONST_DEBITSUMFIELD = 'DEBITNCU';
  CONST_CREDITSUMFIELD = 'CREDITNCU';


  CONST_IDFIELD = 'ID';
  CONST_FRECORDKEYFIELD = 'RECORDKEY';


type
  // Что отображать в визуальной таблице
  TevViewPart = (vpDescription, vpEntry, vpTotal);
  // vpDescription - описание проводки
  // vpEntry - позиции проводки
  // vpTotal - итого по проводке

  TevViewParts = set of TevViewPart;


  // Что отображать в описании проводки
  TevDescriptionOption = (
    doDocumentDate, doDocumentNumber, doDocumentName,
    doRecordDescription, doTransactionName
  );
  // doDocumentDate - отображать дату
  // doDocumentNumber - отображать номер
  // doDocumentName - отображать наиемнование документа
  // doRecordDescription - отображать описание проводки
  // doTransactionName - отображать наименование типовой операции

  TevDescriptionOptions = set of TevDescriptionOption;


  // Что отобжарать для позиции проводки
  TevEntryOption = (
    eoAccountName, eoAccountAlias, eoSum, eoAccountAliasInsteadOfSum, eoAnalytic
  );
  // eoAccountName - наименование бухгалтерского счета
  // eoAccountAlias - код бухгалтерского счета
  // eoSum - сумма по позиции проводки
  // eoAccountAliasInsteadOfSum - код бухгалтерского счета вместо суммы
  // eoAnalytic - аналитику по позиции проводки

  TevEntryOptions = set of TevEntryOption;

  // Вид колонки в визуальной таблице
  TevColumnKind = (ckRecord, ckAccount, ckDebit, ckCredit);
  // ckRecord - проводка
  // ckAccount - бухгалтерский счет
  // ckDebit - дебит
  // ckCredit - кредит

  TevColumnKinds = set of TevColumnKind;


  // Как осуществляется перемещение по визуальной таблице
  TevMovementStep = (msByRecord, msByEntry);
  // msByRecord - перемещаться по проводкам
  // msByEntry - перемещаться по записям проводки

  // Как отображать самую верхнюю проводку
  TevTopEntryState = (tesDrawFull, tesJustEntries);
  // tesDrawFull - тображать полностью
  // tesJustEntries - отображать, начиная с позиций проводки

  // Сосотояние верхней проводки
  TevTopEntry = record
    Index: Integer;
    State: TevTopEntryState;
  end;

  // Элемент визуальной таблицы
  TevDrawInfo = (
    diAnalytic, diEntry, diEntryList, diDescription, diTotal,
    diRecord, diRecordList, diColumn, diColumns);
  // diAnalytic - аналитика
  // diEntry - запись в проводке
  // diEntryList - список записей в проводке
  // diDescription - описание проводки
  // diTotal - итого по проводке
  // diRecord - проводка
  // diRecordList - список проводок
  // diColumn - колонка
  // diColumns - колонки

type
  TevEntry = class;
  TevEntryList = class;
  TevEntryRecord = class;
  TevEntryRecordList = class;
  TevColumns = class;

  TgsEntryViewer = class;


  //
  //  Абстрактный класс для рисования всех
  //  элементов

  TevAbstract = class(TPersistent)
  protected
    procedure Paint(const Y: Integer); virtual; abstract;
    function MouseDown(X, Y: Integer): Boolean; virtual; abstract;
    function CalculateHeight: Integer; virtual; abstract;

  end;

  //
  //  Класс для рисования аналитических признаков

  TevAnalytic = class(TevAbstract)
  private
    FEntry: TevEntry;

    function GetViewer: TgsEntryViewer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    function CalculateHeight: Integer; override;

  public
    constructor Create(AnOwner: TevEntry);
    destructor Destroy; override;

    property Entry: TevEntry read FEntry;

    property Viewer: TgsEntryViewer read GetViewer;

  end;

  //
  //  Класс для рисования записи проводки

  TevEntry = class(TevAbstract)
  private
    FEntryList: TevEntryList;

    FAnalytic: TevAnalytic;

    FEntryBM: TBookmark;

    function HasAnalytic: Boolean;

    function GetViewer: TgsEntryViewer;
    function GetEntryIndex: Integer;
    function GetGlobalEntryIndex: Integer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;

    function CalculateHeight: Integer; override;
    function CalculateJustEntryHeight: Integer;

    property EntryBM: TBookmark read FEntryBM;

  public
    constructor Create(AnOwner: TevEntryList); overload;
    constructor Create(AnOwner: TevEntryList; ABM: Tbookmark); overload;

    destructor Destroy; override;

    property EntryList: TevEntryList read FEntryList;
    property Analytic: TevAnalytic read FAnalytic;

    property Viewer: TgsEntryViewer read GetViewer;

    property EntryIndex: Integer read GetEntryIndex;
    property GlobalEntryIndex: Integer read GetGlobalEntryIndex;

  end;

  //
  //  Класс для рисования списка записей в проводке

  TevEntryList = class(TevAbstract)
  private
    FEntryRecord: TevEntryRecord;

    FEntries: TObjectList;

    function GetEntryCount: Integer;
    function GetEntry(Index: Integer): TevEntry;
    function GetViewer: TgsEntryViewer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    function CalculateHeight: Integer; override;

    function ReadEntries: Boolean;

  public
    constructor Create(AnOwner: TevEntryRecord);
    destructor Destroy; override;

    property EntryCount: Integer read GetEntryCount;
    property Entries[Index: Integer]: TevEntry read GetEntry; default;

    property EntryRecord: TevEntryRecord read FEntryRecord;

    property Viewer: TgsEntryViewer read GetViewer;

  end;

  //
  //  Класс для рисования описания проводки

  TevDescription = class(TevAbstract)
  private
    FEntryRecord: TevEntryRecord;

    function GetViewer: TgsEntryViewer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    function CalculateHeight: Integer; override;

    function GetDescriptionText(const ShouldGotoBookmark: Boolean = True): String;

  public
    constructor Create(AnOwner: TevEntryRecord);
    destructor Destroy; override;

    property EntryRecord: TevEntryRecord read FEntryRecord;

    property Viewer: TgsEntryViewer read GetViewer;

  end;

  //
  //  Класс для рисования итоговой строки

  TevEntryRecordTotal = class(TevAbstract)
  private
    FEntryRecord: TevEntryRecord;

    function GetViewer: TgsEntryViewer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    function CalculateHeight: Integer; override;

  public
    constructor Create(AnOwner: TevEntryRecord);
    destructor Destroy; override;

    property EntryRecord: TevEntryRecord read FEntryRecord;

    property Viewer: TgsEntryViewer read GetViewer;

  end;

  //
  //  Класс для рисования проводки

  TevEntryRecord = class(TevAbstract)
  private
    FEntryRecordList: TevEntryRecordList;
    FTotal: TevEntryRecordTotal;

    FDescription: TevDescription;
    FEntryList: TevEntryList;

    FGlobalOffSet: Integer;

    function GetViewer: TgsEntryViewer;
    function GetRecordBM: TBookmark;
    function GetRecordIndex: Integer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    function CalculateHeight: Integer; override;

    property RecordBM: TBookmark read GetRecordBM;
    property GlobalOffSet: Integer read FGlobalOffSet;

  public
    constructor Create(AnOwner: TevEntryRecordList);

    destructor Destroy; override;

    property EntryRecordList: TevEntryRecordList read FEntryRecordList;

    property Description: TevDescription read FDescription;
    property EntryList: TevEntryList read FEntryList;
    property Total: TevEntryRecordTotal read FTotal;

    property Viewer: TgsEntryViewer read GetViewer;

    property RecordIndex: Integer read GetRecordIndex;

  end;

  //
  //  Класс для рисования списка проводок

  TevEntryRecordList = class(TevAbstract)
  private
    FViewer: TgsEntryViewer;
    FRecords: TObjectList;

    FTopEntry: TevTopEntry;

    FActiveEntryIndex: Integer;

    function GetRecordCount: Integer;
    function GetRecord(Index: Integer): TevEntryRecord;

    function GetActiveRecord: TevEntryRecord;
    function GetActiveEntry: TevEntry;
    function GetActiveRecordIndex: Integer;

    function GetFirstVisibleRecord: TevEntryRecord;
    function GetLastVisibleRecord: TevEntryRecord;

    function GetTopEntryIndex: Integer;
    function GetTopEntryState: TevTopEntryState;

    function GetFirstVisibleEntry: TevEntry;
    function GetLastVisibleEntry: TevEntry;

    function GetGlobalEntryCount: Integer;
    function GetEntryByGlobalEntryIndex(Index: Integer): TevEntry;

    function GetVisibleEntryCount: Integer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    function CalculateHeight: Integer; override;

    function ReadNextRecord: TevEntryRecord;
    procedure FetchAll;

  public
    constructor Create(AnOwner: TgsEntryViewer);
    destructor Destroy; override;

    procedure MoveByRecord(Distance: Integer);
    procedure MoveByEntry(Distance: Integer);

    property Records[Index: Integer]: TevEntryRecord read GetRecord; default;
    property RecordCount: Integer read GetRecordCount;

    property Viewer: TgsEntryViewer read FViewer;

    property TopEntryIndex: Integer read GetTopEntryIndex;
    property TopEntryState: TevTopEntryState read GetTopEntryState;

    property ActiveEntryIndex: Integer read FActiveEntryIndex;
    property ActiveEntry: TevEntry read GetActiveEntry;

    property ActiveRecordIndex: Integer read GetActiveRecordIndex;
    property ActiveRecord: TevEntryRecord read GetActiveRecord;

    property FirstVisibleRecord: TevEntryRecord read GetFirstVisibleRecord;
    property LastVisibleRecord: TevEntryRecord read GetLastVisibleRecord;

    property FirstVisibleEntry: TevEntry read GetFirstVisibleEntry;
    property LastVisibleEntry: TevEntry read GetLastVisibleEntry;

    property VisibleEntryCount: Integer read GetVisibleEntryCount;

    property GlobalEntryCount: Integer read GetGlobalEntryCount;
    property EntryByGlobalEntryIndex[Index: Integer]: TevEntry read
      GetEntryByGlobalEntryIndex;

  end;

  //
  //  Класс для рисования колонки

  TevColumn = class(TevAbstract)
  private
    FColumns: TevColumns;

    FKind: TevColumnKind;

    FColumnWidth: Integer;

    FTitleAlignment: TAlignment;
    FAlignment: TAlignment;

    function GetViewer: TgsEntryViewer;

    procedure SetColumnIndex(const Value: Integer);
    procedure SetColumnWidth(const Value: Integer);

    function GetColumnLeft: Integer;
    function GetDisplayName: String;
    function GetColumnIndex: Integer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    function CalculateHeight: Integer; override;

  public
    constructor Create(AnOwner: TevColumns; AKind: TevColumnKind;
      ATitleAlignment, AnAlignment: TAlignment);
    destructor Destroy; override;

    property Columns: TevColumns read FColumns;
    property Viewer: TgsEntryViewer read GetViewer;

    property Kind: TevColumnKind read FKind;

    property ColumnIndex: Integer read GetColumnIndex write SetColumnIndex;

    property ColumnLeft: Integer read GetColumnLeft;
    property ColumnWidth: Integer read FColumnWidth write SetColumnWidth;
    property DisplayName: String read GetDisplayName;

    property TitleAlignment: TAlignment read FTitleAlignment;
    property Alignment: TAlignment read FAlignment;

  end;

  //
  //  Класс для рисования всех проводок

  TevColumns = class(TevAbstract)
  private
    FViewer: TgsEntryViewer;

    FColumns: TObjectList;

    FDateField: String;

    FDocumentNumberField: String;
    FDocumentNameField: String;

    FTransactionNameField: String;

    FRecordDescriptionField: String;

    FAccountAliasField: String;
    FAccountNameField: String;
    FAccountPartField: String;

    FDebitSumField: String;
    FCreditSumField: String;

    FIdField: String;
    FRecordKeyField: String;

    function GetColumn(Index: Integer): TevColumn;
    function GetColumnCount: Integer;

    function GetColumnByKind(const Index: Integer): TevColumn;

  protected
    function GetOwner: TPersistent; override;

    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    function CalculateHeight: Integer; override;

    procedure CreateColumns;
    procedure CheckFieldNames;

    procedure ScaleColumns;

    function GetUsedColumnKinds: TevColumnKinds;

  public
    constructor Create(AnOwner: TgsEntryViewer);
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function GetNamePath: string; override;

    property Viewer: TgsEntryViewer read FViewer;

    property ColumnCount: Integer read GetColumnCount;
    property Columns[Index: Integer]: TevColumn read GetColumn; default;

    property RecordColumn: TevColumn index 0 read GetColumnByKind;
    property AccountColumn: TevColumn index 1 read GetColumnByKind;
    property DebitColumn: TevColumn index 2 read GetColumnByKind;
    property CreditColumn: TevColumn index 3 read GetColumnByKind;

  published
    property DateField: String read FDateField write FDateField;

    property DocumentNameField: String read FDocumentNameField write
      FDocumentNameField;
    property DocumentNumberField: String read FDocumentNumberField write
      FDocumentNumberField;

    property TransactionNameField: String read FTransactionNameField write
      FTransactionNameField;

    property AccountNameField: String read FAccountNameField write
      FAccountNameField;
    property AccountAliasField: String read FAccountAliasField write
      FAccountAliasField;
    property AccountPartField: String read FAccountPartField write
      FAccountPartField;

    property RecordDescriptionField: String read FRecordDescriptionField write
      FRecordDescriptionField;

    property DebitSumField: String read FDebitSumField write FDebitSumField;
    property CreditSumField: String read FCreditSumField write FCreditSumField;

    property IdField: String read FIdField write FIdField;
    property RecordKeyField: String read FRecordKeyField write FRecordKeyField;

  end;

  //
  //  Класс контроля изменения состояния
  //  источника данных

  TevEntryDataLink = class(TDataLink)
  private
    FViewer: TgsEntryViewer;

  protected
    procedure ActiveChanged; override;
    procedure RecordChanged(Field: TField); override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure LayoutChanged; override;

  public
    constructor Create(AnOwner: TgsEntryViewer);
    destructor Destroy; override;

  end;

  //
  //  Содержит список всех шрифтов и
  //  цветов, используемых другими классами

  TevFontManager = class(TPersistent)
  private
    FViewer: TgsEntryViewer;

    FFontBitmap: TBitmap;

    FColumnFont, FDescriptionFont, FEntryFont,
    FAnalyticFont, FTotalFont, FSelectedRecordFont,
    FSelectedEntryFont: TFont;

    FColumnColor, FDescriptionColor, FEntryColor,
    FAnalyticColor, FTotalColor, FSelectedRecordColor,
    FSelectedEntryColor: TColor;

    FEmptySpaceColor: TColor;

    procedure DoFontChanged(Sender: TObject);

    function GetFont(const Index: Integer): TFont;
    procedure SetFont(const Index: Integer; const Value: TFont);

    function GetColor(const Index: Integer): TColor;
    procedure SetColor(const Index: Integer; const Value: TColor);

  protected
    function GetOwner: TPersistent; override;

    function GetLineHeight(Font: TFont): Integer;
    function GetTextHeightInClientRect(const Text: String; Font: TFont): Integer;

  public
    constructor Create(AnOwner: TgsEntryViewer);
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    function GetNamePath: string; override;

    property Viewer: TgsEntryViewer read FViewer;

  published
    property ColumnFont: TFont index 0 read GetFont write SetFont;
    property DescriptionFont: TFont index 1 read GetFont write SetFont;
    property EntryFont: TFont index 2 read GetFont write SetFont;
    property AnalyticFont: TFont index 3 read GetFont write SetFont;
    property TotalFont: TFont index 4 read GetFont write SetFont;
    property SelectedRecordFont: TFont index 5 read GetFont write SetFont;
    property SelectedEntryFont: TFont index 6 read GetFont write SetFont;

    property ColumnColor: TColor index 0 read GetColor write SetColor;
    property DescriptionColor: TColor index 1 read GetColor write SetColor;
    property EntryColor: TColor index 2 read GetColor write SetColor;
    property AnalyticColor: TColor index 3 read GetColor write SetColor;
    property TotalColor: TColor index 4 read GetColor write SetColor;
    property SelectedRecordColor: TColor index 5 read GetColor write SetColor;
    property SelectedEntryColor: TColor index 6 read GetColor write SetColor;

    property EmptySpaceColor: TColor index 7 read GetColor write SetColor;

  end;

  //
  //  Главный класс, осуществляющий отображение
  //  проводок

  TgsEntryViewer = class(TCustomControl)
  private
    FDataLink: TevEntryDataLink;

    FViewParts: TevViewParts;
    FDescriptionOptions: TevDescriptionOptions;
    FEntryOptions: TevEntryOptions;

    FBorderStyle: TBorderStyle;

    FFontManager: TevFontManager;
    FColumns: TevColumns;
    FEntryRecordList: TevEntryRecordList;

    FScaleColumns: Boolean;
    FGridLines: Boolean;

    FMovementStep: TevMovementStep;

    FUpdateLock: Integer;
    FScrollBarLock: Integer;

    procedure WMGetDlgCode(var Msg: TWMGetDlgCode);
      message WM_GETDLGCODE;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd);
      message WM_ERASEBKGND;
    procedure WMVScroll(var Message: TWMVScroll);
      message WM_VSCROLL;

    procedure UpdateScrollBar;

    procedure SetDataSource(const Value: TDataSource);
    function GetDataSource: TDataSource;

    procedure SetBorderStyle(const Value: TBorderStyle);
    procedure SetScaleColumns(const Value: Boolean);
    procedure SetGridLines(const Value: Boolean);
    procedure SetMovementStep(const Value: TevMovementStep);
    procedure SetColumns(const Value: TevColumns);
    procedure SetFontManager(const Value: TevFontManager);
    function GetIsUpdating: Boolean;

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Paint; override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure DoEnter; override;
    procedure DoExit; override;

    function CalcDrawInfo(Info: TevDrawInfo; const Index, SubIndex: Integer;
      out R: TRect): Boolean;

    procedure ActiveChanged;
    procedure UpdateRecordList;

    procedure BeginUpdate;
    procedure EndUpdate;
    procedure StopUpdate;

    procedure UpdateViewer;

    procedure BeginUpdateScrollBar;
    procedure EndUpdateScrollBar;

    property DataLink: TevEntryDataLink read FDataLink;

    property UpdateLock: Integer read FUpdateLock;
    property ScrollBarLock: Integer read FScrollBarLock;
    property IsUpdating: Boolean read GetIsUpdating;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property EntryRecordList: TevEntryRecordList read FEntryRecordList;
    property MovementStep: TevMovementStep read FMovementStep write SetMovementStep;

  published
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property Columns: TevColumns read FColumns write SetColumns;
    property FontManager: TevFontManager read FFontManager write SetFontManager;

    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle
      default bsSingle;

    property ScaleColumns: Boolean read FScaleColumns write SetScaleColumns;
    property GridLines: Boolean read FGridLines write SetGridLines;

    property ViewParts: TevViewParts read FViewParts write FViewParts;
    property DescriptionOptions: TevDescriptionOptions read FDescriptionOptions
      write FDescriptionOptions;
    property EntryOptions: TevEntryOptions read FEntryOptions
      write FEntryOptions;

    property Align;
    property Ctl3D;
    property TabOrder;
    property TabStop;
    property Anchors;
    property Constraints;
    property Enabled;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ParentFont;
    property ShowHint;
    property Visible;
    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

  EgsEntryViewer = class(Exception);

procedure Register;

implementation

uses Math;

var
  DrawBitmap: TBitmap;

procedure Register;
begin
  RegisterComponents('gsNew', [TgsEntryViewer]);
end;

function PointInRect(X, Y: Integer; R: TRect): Boolean;
begin
  with R do
    Result := (X >= Left) and (X <= Right) and (Y >= Top) and (Y <= Bottom);
end;

procedure WriteText(ACanvas: TCanvas; ARect: TRect; DX, DY: Integer;
  const Text: string; Alignment: TAlignment; Multiline: Boolean = False);
const
  AlignFlags : array [TAlignment] of Integer =
    ( DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX or DT_TOP,
      DT_RIGHT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX or DT_TOP,
      DT_CENTER or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX or DT_TOP);
var
  B, R: TRect;
  Hold, Left: Integer;
  I: TColorRef;
begin
  I := ColorToRGB(ACanvas.Brush.Color);
  if (GetNearestColor(ACanvas.Handle, I) = I) and not Multiline then
  begin
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
  else begin
    DrawBitmap.Canvas.Lock;
    try
      with DrawBitmap, ARect do
      begin
        Width := Max(Width, Right - Left);
        Height := Max(Height, Bottom - Top);
        R := Rect(DX, DY, Right - Left, Bottom - Top);
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
          AlignFlags[Alignment]);
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

//
// Возвращает текущее состояние клавиатуры и мыши

function GetShiftState: TShiftState;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := KeyboardStateToShiftState(State);
end;


{ TgsEntryViewer }

procedure TgsEntryViewer.ActiveChanged;
begin
  BeginUpdate;
  

  try
    FColumns.FColumns.Clear;
    FEntryRecordList.FRecords.Clear;

    if DataLink.Active then
    begin
      Columns.CheckFieldNames;
      Columns.CreateColumns;
      Columns.ScaleColumns;
      UpdateRecordList;
    end else begin
      FEntryRecordList.FActiveEntryIndex := -1;
      FEntryRecordList.FTopEntry.Index := -1;
      FEntryRecordList.FTopEntry.State := tesDrawFull;
      UpdateViewer;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TgsEntryViewer.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TgsEntryViewer.BeginUpdateScrollBar;
begin
  Inc(FScrollBarLock);
end;

function TgsEntryViewer.CalcDrawInfo(Info: TevDrawInfo; const Index,
  SubIndex: Integer; out R: TRect): Boolean;
var
  I: Integer;
  StartIndex: Integer;
begin
  Result := False;

  with GetClientRect do
  case Info of
    diColumns:
    begin
      with GetClientRect do
        R := Rect(Left, Top, Right, Top + FColumns.CalculateHeight);

      Result := True;
    end;
    diColumn:
    begin
      R := Rect(
        Columns[Index].ColumnLeft,
        Top,
        Columns[Index].ColumnLeft + Columns[Index].ColumnWidth,
        Top + FColumns.CalculateHeight
      );

      Result := True;
    end;
    diRecordList:
    begin
      R := Rect(
        Left,
        Top + FColumns.CalculateHeight + 1,
        Right,
        Bottom
      );

      Result := True;
    end;
    diRecord:
    begin
      CalcDrawInfo(diColumns, 0, 0, R);

      with FEntryRecordList do
      for I := FirstVisibleRecord.RecordIndex to Index do
      begin
        R.Top := R.Bottom + 1;
        R.Bottom := R.Top + Records[I].CalculateHeight;
        Result := True;
      end;

      if not Result then
        R := Rect(-1, -1, -1, -1);
    end;
    diTotal:
    begin
      if (Index > 0) and
        (FEntryRecordList.FirstVisibleRecord.RecordIndex < Index) then
      begin
        Result := CalcDrawInfo(diRecord, Index - 1, 0, R);

        // Если запрашиваемая проводка не вида,
        // обнуляем значение и выходим
        if not Result then
        begin
          R := Rect(-1, -1, -1, -1);
          Exit;
        end;
      end else
        CalcDrawInfo(diColumns, 0, 0, R);

      R.Top := R.Bottom + 1;

      with FEntryRecordList do
      begin
        if vpDescription in ViewParts then
        begin
          if
            (TopEntryState = tesDrawFull)
              or
            (
              (TopEntryState = tesJustEntries)
                and
              (FirstVisibleRecord.RecordIndex <> Index)
            )
          then begin
            Inc(R.Top, Records[Index].Description.CalculateHeight);
            Inc(R.Top, 1);
          end;

          if vpEntry in ViewParts then
          begin
            Inc(R.Top, Records[Index].EntryList.CalculateHeight);
            Inc(R.Top, 1);
          end;

          R.Bottom := R.Top + Records[Index].Total.CalculateHeight;
          Result := True;
        end;
      end;
    end;
    diDescription:
    begin
      if (Index > 0) and
        (FEntryRecordList.FirstVisibleRecord.RecordIndex < Index) then
      begin
        Result := CalcDrawInfo(diRecord, Index - 1, 0, R);

        // Если запрашиваемая проводка не вида,
        // обнуляем значение и выходим
        if not Result then
        begin
          R := Rect(-1, -1, -1, -1);
          Exit;
        end;
      end else
        CalcDrawInfo(diColumns, 0, 0, R);

      R.Bottom := R.Bottom + 1;
      R.Top := R.Bottom;

      with FEntryRecordList do
      if vpDescription in ViewParts then
      begin
        if
          (TopEntryState = tesDrawFull)
            or
          (
            (TopEntryState = tesJustEntries)
              and
            (FirstVisibleRecord.RecordIndex <> Index)
          )
        then begin
          R.Bottom := R.Bottom + Records[Index].Description.CalculateHeight;
          Result := True;
        end else
          R := Rect(-1, -1, -1, -1);
      end;
    end;
    diEntryList:
    begin
      if (Index > 0) and
        (FEntryRecordList.FirstVisibleRecord.RecordIndex < Index) then
      begin
        Result := CalcDrawInfo(diRecord, Index - 1, 0, R);

        // Если запрашиваемая проводка не вида,
        // обнуляем значение и выходим
        if not Result then
        begin
          R := Rect(-1, -1, -1, -1);
          Exit;
        end;

      end else
        CalcDrawInfo(diColumns, 0, 0, R);

      R.Bottom := R.Bottom + 1;
      R.Top := R.Bottom;

      with FEntryRecordList do
      begin
        if vpDescription in ViewParts then
        begin
          if
            (TopEntryState = tesDrawFull)
              or
            (
              (TopEntryState = tesJustEntries)
                and
              (FirstVisibleRecord.RecordIndex <> Index)
            )
          then begin
            Inc(R.Top, Records[Index].Description.CalculateHeight);
            Inc(R.Top, 1);
          end;

          R.Bottom := R.Top + Records[Index].EntryList.CalculateHeight;
        end;

        Result := True;
      end;
    end;
    diEntry:
    begin
      if (Index > 0) and
        (FEntryRecordList.FirstVisibleRecord.RecordIndex < Index) then
      begin
        Result := CalcDrawInfo(diRecord, Index - 1, 0, R);

        // Если запрашиваемая проводка не вида,
        // обнуляем значение и выходим
        if not Result then
        begin
          R := Rect(-1, -1, -1, -1);
          Exit;
        end;
      end else
        CalcDrawInfo(diColumns, 0, 0, R);

      R.Bottom := R.Bottom + 1;
      R.Top := R.Bottom;

      with FEntryRecordList do
      begin
        if vpDescription in ViewParts then
        begin
          if
            (TopEntryState = tesDrawFull)
              or
            (
              (TopEntryState = tesJustEntries)
                and
              (FirstVisibleRecord.RecordIndex <> Index)
            )
          then begin
            Inc(R.Top, Records[Index].Description.CalculateHeight);
            Inc(R.Top, 1);
            R.Bottom := R.Top;
          end;
        end;

        if
          (TopEntryState = tesJustEntries)
            and
          (FirstVisibleRecord.RecordIndex = Index)
        then
          StartIndex := Records[Index].EntryRecordList.TopEntryIndex -
            Records[Index].GlobalOffSet
        else
          StartIndex := 0;

        // Если запись проводки
        // является невидимой - прерываем
        // расчет
        if StartIndex > SubIndex then
        begin
          Result := False;
          R := Rect(-1, -1, -1, -1);
          Exit;
        end;

        with Records[Index] do
          for I := StartIndex to SubIndex do
          begin
           if I > StartIndex then
             Inc(R.Bottom);

            R.Top := R.Bottom;
            R.Bottom := R.Top + EntryList[I].CalculateHeight;
          end;
      end;

      Result := True;
    end;
    diAnalytic:
    begin
      if SubIndex > 0 then
      begin
        Result := CalcDrawInfo(diEntry, Index, SubIndex - 1, R);

        if not Result then
        begin
          R := Rect(-1, -1, -1, -1);
          Exit;
        end;
      end else begin
        if (Index > 0) and
          (FEntryRecordList.FirstVisibleRecord.RecordIndex < Index) then
        begin
          Result := CalcDrawInfo(diRecord, Index - 1, 0, R);

          // Если запрашиваемая проводка не вида,
          // обнуляем значение и выходим
          if not Result then
          begin
            R := Rect(-1, -1, -1, -1);
            Exit;
          end;
        end else
          CalcDrawInfo(diColumns, 0, 0, R);

        R.Bottom := R.Bottom + 1;
        R.Top := R.Bottom;

        with FEntryRecordList do
          if vpDescription in ViewParts then
          begin
            if
              (TopEntryState = tesDrawFull)
                or
              (
                (TopEntryState = tesJustEntries)
                  and
                (FirstVisibleRecord.RecordIndex <> Index)
              )
            then begin
              Inc(R.Top, Records[Index].Description.CalculateHeight);
              Inc(R.Top, 1);
            end;
          end;
      end;

      with FEntryRecordList, Records[Index].EntryList[SubIndex] do
      begin
        Inc(R.Top, CalculateJustEntryHeight);
        Inc(R.Bottom, CalculateJustEntryHeight + Analytic.CalculateHeight);
      end;

      Result := True;
    end;
  end;
end;

constructor TgsEntryViewer.Create(AnOwner: TComponent);
begin
  inherited;

  FDataLink := TevEntryDataLink.Create(Self);

  FFontManager := TevFontManager.Create(Self);
  FColumns := TevColumns.Create(Self);
  FEntryRecordList := TevEntryRecordList.Create(Self);

  FBorderStyle := bsSingle;

  FViewParts := [vpDescription, vpEntry, vpTotal];

  FDescriptionOptions := [doDocumentDate, doDocumentNumber, doDocumentName,
    doRecordDescription, doTransactionName];

  FEntryOptions := [eoAccountName, eoAccountAlias, eoSum, eoAnalytic];

  FScaleColumns := True;
  FGridLines := True;

  FMovementStep := msByRecord;

  FUpdateLock := 0;
  FScrollBarLock := 0;

  TabStop := True;
end;

procedure TgsEntryViewer.CreateParams(var Params: TCreateParams);
begin
  inherited;

  with Params do
  begin
    Style := Style or WS_VSCROLL;

    if FBorderStyle = bsSingle then
      if NewStyleControls and Ctl3D then
      begin
        Style := Style and not WS_BORDER;
        ExStyle := ExStyle or WS_EX_CLIENTEDGE;
      end else
        Style := Style or WS_BORDER;

    WindowClass.style := CS_DBLCLKS;
  end;
end;

procedure TgsEntryViewer.CreateWnd;
begin
  inherited;

  //UpdateScrollBar;
end;

destructor TgsEntryViewer.Destroy;
begin
  FDataLink.Free;

  FColumns.Free;
  FEntryRecordList.Free;

  inherited;
end;

procedure TgsEntryViewer.DoEnter;
begin
  inherited;
  UpdateViewer;
end;

procedure TgsEntryViewer.DoExit;
begin
  inherited;
  UpdateViewer;
end;

procedure TgsEntryViewer.EndUpdate;
begin
  Dec(FUpdateLock);
  if FUpdateLock <= 0 then UpdateViewer;
end;

procedure TgsEntryViewer.EndUpdateScrollBar;
begin
  if FScrollBarLock > 0 then
    Dec(FScrollBarLock);
end;

function TgsEntryViewer.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

function TgsEntryViewer.GetIsUpdating: Boolean;
begin
  Result := FUpdateLock > 0; 
end;

procedure TgsEntryViewer.KeyDown(var Key: Word; Shift: TShiftState);

  procedure Jump;
  begin
    if MovementStep = msByRecord then
      MovementStep := msByEntry else
    if MovementStep = msByEntry then
      MovementStep := msByRecord;
  end;

begin
  inherited;

  if not DataLink.Active then Exit;

  with FEntryRecordList do
  begin
    BeginUpdate;

    try
      case Key of
        VK_UP:
        begin
          if (ssCtrl in Shift) then
          begin
            if MovementStep = msByRecord then
            begin
              MovementStep := msByEntry;
              MoveByEntry(-1);
            end else

            if MovementStep = msByEntry then
            begin
              MovementStep := msByRecord;
              DataLink.DataSet.GotoBookmark(ActiveRecord.RecordBM);

              if (TopEntryState = tesJustEntries) and
                (ActiveRecord = FirstVisibleRecord)
              then
                FTopEntry.State := tesDrawFull;

              UpdateViewer;
            end;
          end else

          if MovementStep = msByRecord then
            MoveByRecord(-1) else

          if MovementStep = msByEntry then
            MoveByEntry(-1);
        end;
        VK_DOWN:
        begin
          if (ssCtrl in Shift) then
          begin
            if MovementStep = msByRecord then
            begin
              MovementStep := msByEntry;
              UpdateViewer;
            end else

            if MovementStep = msByEntry then
            begin
              MovementStep := msByRecord;
              MoveByRecord(1);
            end;
          end else

          if MovementStep = msByRecord then
            MoveByRecord(1) else

          if MovementStep = msByEntry then
            MoveByEntry(1);
        end;
        VK_PRIOR:
        begin
          if (ssCtrl in Shift) then
            Jump;

          if MovementStep = msByRecord then
            MoveByRecord(FirstVisibleRecord.Recordindex -
              LastVisibleRecord.RecordIndex - 1) else

          if MovementStep = msByEntry then
            MoveByEntry(FirstVisibleEntry.GlobalEntryIndex -
              LastVisibleEntry.GlobalEntryIndex - 1);
        end;
        VK_NEXT:
        begin
          if (ssCtrl in Shift) then
            Jump;

          if MovementStep = msByRecord then
            MoveByRecord(LastVisibleRecord.Recordindex -
              FirstVisibleRecord.RecordIndex + 1) else

          if MovementStep = msByEntry then
            MoveByEntry(LastVisibleEntry.GlobalEntryIndex -
              FirstVisibleEntry.GlobalEntryIndex + 1);
        end;
      end;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TgsEntryViewer.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;  
begin
  inherited;

  if DataLink.Active then
  begin
    if not Focused then
      SetFocus;

    for I := 0 to FEntryRecordList.RecordCount - 1 do
      if FEntryRecordList.Records[I].MouseDown(X, Y) then Break;
  end;
end;

procedure TgsEntryViewer.Paint;
var
  R: TRect;
begin
  BeginUpdate;

  try
    if DataLink.Active then
    begin
      try
        Columns.CheckFieldNames;
      except
        Canvas.Brush.Color := FontManager.EmptySpaceColor;
        Canvas.FillRect(GetClientRect);
        raise;
      end;

      DataLink.DataSet.DisableControls;
      try
        FEntryRecordList.Paint(FColumns.CalculateHeight + 1);
        FColumns.Paint(0);

        R := GetClientRect;

        Inc(R.Top, FColumns.CalculateHeight);
        Inc(R.Top, 1);
        Inc(R.Top, FEntryRecordList.CalculateHeight);
      finally
        DataLink.DataSet.EnableControls;
      end;

      Canvas.Brush.Color := FontManager.EmptySpaceColor;
      Canvas.FillRect(R);
    end else begin
      Canvas.Brush.Color := FontManager.EmptySpaceColor;
      Canvas.FillRect(GetClientRect);
    end;
  finally
    StopUpdate;
  end;
end;

procedure TgsEntryViewer.SetBorderStyle(const Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TgsEntryViewer.SetColumns(const Value: TevColumns);
begin
  FColumns.Assign(Value);
end;

procedure TgsEntryViewer.SetDataSource(const Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

procedure TgsEntryViewer.SetFontManager(const Value: TevFontManager);
begin
  FFontManager.Assign(Value);
end;

procedure TgsEntryViewer.SetGridLines(const Value: Boolean);
begin
  if FGridLines <> Value then
  begin
    FGridLines := Value;
    UpdateViewer;
  end;
end;

procedure TgsEntryViewer.SetMovementStep(const Value: TevMovementStep);
begin
  if MovementStep <> Value then
  begin
    FMovementStep := Value;
    UpdateScrollBar;
  end;  
end;

procedure TgsEntryViewer.SetScaleColumns(const Value: Boolean);
begin
  if FScaleColumns <> Value then
  begin
    FScaleColumns := Value;

    if FScaleColumns then
    begin
      Columns.ScaleColumns;
      UpdateViewer;
    end;
  end;
end;

procedure TgsEntryViewer.StopUpdate;
begin
  Dec(FUpdateLock);
end;

procedure TgsEntryViewer.UpdateRecordList;
var
  R: TRect;
  CurrentRecord: TevEntryRecord;
begin
  //
  //  Осуществляем первое считывание
  //  проводок

  R := GetClientRect;

  Dec(R.Bottom, FColumns.CalculateHeight);
  Dec(R.Bottom, 1);

  FEntryRecordList.FRecords.Clear;

  with DataLink.DataSet do
  begin
    First;

    while (R.Bottom - R.Top > 0) and not EOF do
    begin
      CurrentRecord := FEntryRecordList.ReadNextRecord;

      if CurrentRecord <> nil then
      begin
        FEntryRecordList.FRecords.Add(CurrentRecord);
        Dec(R.Bottom, CurrentRecord.CalculateHeight);
      end;
    end;

    with FEntryRecordList do
      if ActiveEntry <> nil then
        GotoBookmark(ActiveEntry.EntryBM)
      else begin
        if RecordCount > 0 then
        begin
          FTopEntry.Index := 0;
          FActiveEntryIndex := 0;
        end else begin
          FTopEntry.Index := -1;
          FActiveEntryIndex := -1;
        end;
      end;
  end;
end;

procedure TgsEntryViewer.UpdateScrollBar;
var
  SIOld, SINew: TScrollInfo;
begin
  if not HandleAllocated or (ScrollBarLock > 0) then Exit;

  BeginUpdateScrollBar;
  try
    SIOld.cbSize := sizeof(SIOld);
    SIOld.fMask := SIF_ALL;

    GetScrollInfo(Self.Handle, SB_VERT, SIOld);
    SINew := SIOld;

    with FEntryRecordList do
    if DataLink.Active and DataLink.DataSet.IsSequenced then
    begin
      SINew.nMin := 1;
      SINew.nPage := RecordCount;

      SINew.nMax := GlobalEntryCount;

      if vpDescription in ViewParts then
        SINew.nMax := SINew.nMax + RecordCount - 2
      else
        SINew.nMax := SINew.nMax + RecordCount - 2;

      SINew.nPos := ActiveEntryIndex;
    end
    else
    begin
      SINew.nMin := 0;
      SINew.nPage := 0;
      SINew.nMax := 4;
      if ActiveEntryIndex = 0 then
        SINew.nPos := 0
      else
        SINew.nPos := 2;
    end;

    //
    //  Производим обновление только, если были изменения

    if
      (SINew.nMin <> SIOld.nMin) or (SINew.nMax <> SIOld.nMax) or
      (SINew.nPage <> SIOld.nPage) or (SINew.nPos <> SIOld.nPos)
    then
      SetScrollInfo(Self.Handle, SB_VERT, SINew, True);
  finally
    EndUpdateScrollBar;
  end;
end;

procedure TgsEntryViewer.UpdateViewer;
begin
  if FUpdateLock = 0 then
  begin
    UpdateScrollBar;
    Invalidate;
  end;
end;

procedure TgsEntryViewer.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := -1;
end;

procedure TgsEntryViewer.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  // Указываем, что для работы нам нужно откликаться
  // на нажатия кнопок клавиатуры
  Msg.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TgsEntryViewer.WMSize(var Message: TWMSize);
begin
  inherited;

  if FScaleColumns and HandleAllocated then
    FColumns.ScaleColumns;

  if DataLink.Active then {};

end;

procedure TgsEntryViewer.WMVScroll(var Message: TWMVScroll);
var
  SI: TScrollInfo;
begin
  BeginUpdate;
  try
    with Message, FEntryRecordList do
      case ScrollCode of
        SB_LINEUP:
          if MovementStep = msByRecord then
            MoveByRecord(-1)
          else
            MoveByEntry(-1);
        SB_LINEDOWN:
          if MovementStep = msByRecord then
            MoveByRecord(1)
          else
            MoveByEntry(1);
        SB_PAGEUP:
          if MovementStep = msByRecord then
            MoveByRecord(FirstVisibleRecord.Recordindex -
              LastVisibleRecord.RecordIndex - 1) else

          if MovementStep = msByEntry then
            MoveByEntry(FirstVisibleEntry.GlobalEntryIndex -
              LastVisibleEntry.GlobalEntryIndex - 1);
        SB_PAGEDOWN:
          if MovementStep = msByRecord then
            MoveByRecord(LastVisibleRecord.Recordindex -
              FirstVisibleRecord.RecordIndex + 1) else

          if MovementStep = msByEntry then
            MoveByEntry(LastVisibleEntry.GlobalEntryIndex -
              FirstVisibleEntry.GlobalEntryIndex + 1);
        SB_THUMBPOSITION:
          begin
            if DataLink.DataSet.IsSequenced then
            begin
              SI.cbSize := sizeof(SI);
              SI.fMask := SIF_ALL;
              GetScrollInfo(Self.Handle, SB_VERT, SI);

              if SI.nTrackPos <= 1 then
              begin
                if MovementStep = msByRecord then
                  MoveByRecord(-RecordCount)
                else
                  MoveByEntry(-GlobalEntryCount);
              end else

              if SI.nTrackPos >= GlobalEntryCount then
              begin
                if MovementStep = msByRecord then
                  MoveByRecord(RecordCount)
                else
                  MoveByEntry(GlobalEntryCount);
              end else

              begin
                if MovementStep = msByRecord then
                  MoveByRecord(EntryByGlobalEntryIndex[SI.nTrackPos].EntryList.EntryRecord.
                    RecordIndex - ActiveRecord.RecordIndex + 1)
                else
                  MoveByEntry(SI.nTrackPos - ActiveEntryIndex + 1);
              end;
            end
            else
              case Pos of
                0:
                  if MovementStep = msByRecord then
                    MoveByRecord(-RecordCount)
                  else
                    MoveByEntry(-GlobalEntryCount);
                1:
                  if MovementStep = msByRecord then
                    MoveByRecord(FirstVisibleRecord.Recordindex -
                      LastVisibleRecord.RecordIndex - 1) else

                  if MovementStep = msByEntry then
                    MoveByEntry(FirstVisibleEntry.GlobalEntryIndex -
                      LastVisibleEntry.GlobalEntryIndex - 1);
                2: { nothing };
                3:
                  if MovementStep = msByRecord then
                    MoveByRecord(LastVisibleRecord.Recordindex -
                      FirstVisibleRecord.RecordIndex + 1) else

                  if MovementStep = msByEntry then
                    MoveByEntry(LastVisibleEntry.GlobalEntryIndex -
                      FirstVisibleEntry.GlobalEntryIndex + 1);
                4:
                begin
                  FetchAll;

                  if MovementStep = msByRecord then
                    MoveByRecord(RecordCount)
                  else
                    MoveByEntry(GlobalEntryCount);
                end;
              end;
          end;
        SB_BOTTOM:
        begin
          FetchAll;

          if MovementStep = msByRecord then
            MoveByRecord(RecordCount)
          else
            MoveByEntry(GlobalEntryCount);
        end;
        SB_TOP:
          if MovementStep = msByRecord then
            MoveByRecord(-RecordCount)
          else
            MoveByEntry(-GlobalEntryCount);
      end;
  finally
    StopUpdate;
  end;
end;

{ TevEntryDataLink }

procedure TevEntryDataLink.ActiveChanged;
begin
  inherited;
  
  if not FViewer.IsUpdating then
    FViewer.ActiveChanged;
end;

constructor TevEntryDataLink.Create(AnOwner: TgsEntryViewer);
begin
  FViewer := AnOwner;
end;

procedure TevEntryDataLink.DataSetScrolled(Distance: Integer);
begin
  inherited;

  if not FViewer.IsUpdating then
  begin
    FViewer.BeginUpdate;
    try
      FViewer.MovementStep := msByEntry;
      FViewer.EntryRecordList.MoveByEntry(Distance);
    finally
      FViewer.EndUpdate;
    end;
  end;
end;

destructor TevEntryDataLink.Destroy;
begin
  inherited;
end;

procedure TevEntryDataLink.LayoutChanged;
begin
  inherited;

  if not FViewer.IsUpdating then
  begin
    FViewer.BeginUpdate;
    try
      FViewer.ActiveChanged;
    finally
      FViewer.EndUpdate;
    end;
  end;
end;

procedure TevEntryDataLink.RecordChanged(Field: TField);
begin
  inherited;

  if not FViewer.IsUpdating then
  begin
    FViewer.BeginUpdate;
    try
      FViewer.UpdateViewer;
    finally
      FViewer.EndUpdate;
    end;
  end;
end;

{ TevFontManager }

procedure TevFontManager.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TevFontManager then
  begin
    FColumnFont.Assign((Source as TevFontManager).FColumnFont);
    FDescriptionFont.Assign((Source as TevFontManager).FDescriptionFont);
    FEntryFont.Assign((Source as TevFontManager).FEntryFont);
    FAnalyticFont.Assign((Source as TevFontManager).FAnalyticFont);
    FTotalFont.Assign((Source as TevFontManager).FTotalFont);
    FSelectedRecordFont.Assign((Source as TevFontManager).FSelectedRecordFont);
    FSelectedEntryFont.Assign((Source as TevFontManager).FSelectedEntryFont);

    FColumnColor := (Source as TevFontManager).FColumnColor;
    FDescriptionColor := (Source as TevFontManager).FDescriptionColor;
    FEntryColor := (Source as TevFontManager).FEntryColor;
    FAnalyticColor := (Source as TevFontManager).FAnalyticColor;
    FTotalColor := (Source as TevFontManager).FTotalColor;
    FSelectedRecordColor := (Source as TevFontManager).FSelectedRecordColor;
    FSelectedEntryColor := (Source as TevFontManager).FSelectedEntryColor;
    FEmptySpaceColor := (Source as TevFontManager).FEmptySpaceColor;
  end;  
end;

constructor TevFontManager.Create(AnOwner: TgsEntryViewer);
  function CreateNewFont: TFont;
  begin
    Result := TFont.Create;
    Result.Color := clWindowText;
    Result.Style := [];
    Result.Name := 'Tahoma';
    Result.OnChange := DoFontChanged;
  end;
begin
  FViewer := AnOwner;

  FColumnFont := CreateNewFont;
  FDescriptionFont := CreateNewFont;
  FEntryFont := CreateNewFont;
  FAnalyticFont := CreateNewFont;
  FTotalFont := CreateNewFont;

  FSelectedRecordFont := CreateNewFont;
  FSelectedRecordFont.Color := clHighlightText;

  FSelectedEntryFont := CreateNewFont;
  FSelectedEntryFont.Color := clHighlightText;

  FColumnColor := clBtnFace;
  FDescriptionColor := clWhite;
  FEntryColor := $00E1E1E1;
  FAnalyticColor := $00E1E1E1;
  FTotalColor := clNavy;
  FSelectedRecordColor := clHighlight;
  FSelectedEntryColor := clHighlight;

  FEmptySpaceColor := clWhite;

  FFontBitmap := TBitmap.Create;
  // На всякий случай укажем размер рисунка
  FFontBitmap.Width := 10;
  FFontBitmap.Height := 10;
end;

destructor TevFontManager.Destroy;
begin
  FFontBitmap.Free;

  FColumnFont.Free;
  FDescriptionFont.Free;
  FEntryFont.Free;
  FAnalyticFont.Free;
  FTotalFont.Free;
  FSelectedRecordFont.Free;
  FSelectedEntryFont.Free;

  inherited;
end;

procedure TevFontManager.DoFontChanged(Sender: TObject);
begin
  with Viewer do
  begin
    ParentFont := False;

    if UpdateLock = 0 then
      UpdateViewer;
  end;
end;

function TevFontManager.GetColor(const Index: Integer): TColor;
begin
  case Index of
    0: Result := FColumnColor;
    1: Result := FDescriptionColor;
    2: Result := FEntryColor;
    3: Result := FAnalyticColor;
    4: Result := FTotalColor;
    5: Result := FSelectedRecordColor;
    6: Result := FSelectedEntryColor;
    7: Result := FEmptySpaceColor;
    else
      Result := clNone;
  end;
end;

function TevFontManager.GetFont(const Index: Integer): TFont;
begin
  case Index of
    0: Result := FColumnFont;
    1: Result := FDescriptionFont;
    2: Result := FEntryFont;
    3: Result := FAnalyticFont;
    4: Result := FTotalFont;
    5: Result := FSelectedRecordFont;
    6: Result := FSelectedEntryFont;
    else
      Result := nil;
  end;
end;

function TevFontManager.GetLineHeight(Font: TFont): Integer;
begin
  FFontBitmap.Canvas.Font := Font;
  Result := FFontBitmap.Canvas.TextHeight('Wg') + 4;
end;

function TevFontManager.GetNamePath: string;
begin
  Result := 'FontManager';
end;

function TevFontManager.GetOwner: TPersistent;
begin
  Result := FViewer;
end;

function TevFontManager.GetTextHeightInClientRect(const Text: String;
  Font: TFont): Integer;
var
  R: TRect;
begin
  R.Left := Viewer.ClientRect.Left;
  R.Right := Viewer.ClientRect.Right;
  R.Top := 0;

  FFontBitmap.Canvas.Font := Font;

  DrawText(FFontBitmap.Canvas.Handle, PChar(Text), -1, R,
    DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX or DT_CALCRECT);

  Result := (R.Bottom - R.Top);
end;

procedure TevFontManager.SetColor(const Index: Integer;
  const Value: TColor);
begin
  case Index of
    0:
      if FColumnColor <> Value then
      begin
        FColumnColor := Value;
        Viewer.UpdateViewer;
      end;
    1:
      if FDescriptionColor <> Value then
      begin
        FDescriptionColor := Value;
        Viewer.UpdateViewer;
      end;
    2:
      if FEntryColor <> Value then
      begin
        FEntryColor := Value;
        Viewer.UpdateViewer;
      end;
    3:
      if FAnalyticColor <> Value then
      begin
        FAnalyticColor := Value;
        Viewer.UpdateViewer;
      end;
    4:
      if FTotalColor <> Value then
      begin
        FTotalColor := Value;
        Viewer.UpdateViewer;
      end;
    5:
      if FSelectedRecordColor <> Value then
      begin
        FSelectedRecordColor := Value;
        Viewer.UpdateViewer;
      end;
    6:
      if FSelectedEntryColor <> Value then
      begin
        FSelectedEntryColor := Value;
        Viewer.UpdateViewer;
      end;
    7:
      if FEmptySpaceColor <> Value then
      begin
        FEmptySpaceColor := Value;
        Viewer.UpdateViewer;
      end;
  end;
end;

procedure TevFontManager.SetFont(const Index: Integer; const Value: TFont);
begin
  if not Assigned(Value) then Exit;

  case Index of
    0: FColumnFont.Assign(Value);
    1: FDescriptionFont.Assign(Value);
    2: FEntryFont.Assign(Value);
    3: FAnalyticFont.Assign(Value);
    4: FTotalFont.Assign(Value);
    5: FSelectedRecordFont.Assign(Value);
    6: FSelectedEntryFont.Assign(Value);
  end;
end;

{ TevColumns }

procedure TevColumns.Assign(Source: TPersistent);
begin
  inherited;

  if Source is TevColumns then
  begin
    FDateField := (Source as TevColumns).FDateField;

    FDocumentNumberField := (Source as TevColumns).FDocumentNumberField;
    FDocumentNameField := (Source as TevColumns).FDocumentNameField;

    FTransactionNameField := (Source as TevColumns).FTransactionNameField;

    FRecordDescriptionField := (Source as TevColumns).FRecordDescriptionField;

    FAccountAliasField := (Source as TevColumns).FAccountAliasField;
    FAccountNameField := (Source as TevColumns).FAccountNameField;
    FAccountPartField := (Source as TevColumns).FAccountPartField;

    FDebitSumField := (Source as TevColumns).FDebitSumField;
    FCreditSumField := (Source as TevColumns).FCreditSumField;

    FIdField := (Source as TevColumns).FIdField;
    FRecordKeyField := (Source as TevColumns).FRecordKeyField;
  end;
end;

function TevColumns.CalculateHeight: Integer;
begin
  with Viewer.FontManager do
    Result := GetLineHeight(ColumnFont);
end;

procedure TevColumns.CheckFieldNames;
begin
  with Viewer, DataLink.DataSet do
  begin
    if vpDescription in ViewParts then
    begin
      if
        (doDocumentDate in DescriptionOptions)
          and
        (FindField(FDateField) = nil)
      then
        raise EgsEntryViewer.CreateFmt(
          'Can''t start reading entries. Field %s not found!',
          [FDateField]);

      if
        (doDocumentNumber in DescriptionOptions)
          and
        (FindField(FDocumentNumberField)  = nil)
      then
        raise EgsEntryViewer.CreateFmt(
          'Can''t start reading entries. Field %s not found!',
          [FDocumentNumberField]);

      if
        (doDocumentName in DescriptionOptions)
          and
        (FindField(FDocumentNameField) = nil)
      then
        raise EgsEntryViewer.CreateFmt(
          'Can''t start reading entries. Field %s not found!',
          [FDocumentNameField]);

      if
        (doRecordDescription in DescriptionOptions)
          and
        (FindField(FRecordDescriptionField) = nil)
      then
        raise EgsEntryViewer.CreateFmt(
          'Can''t start reading entries. Field %s not found!',
          [FRecordDescriptionField]);

      if
        (doTransactionName in DescriptionOptions)
          and
        (FindField(FTransactionNameField) = nil)
      then
        raise EgsEntryViewer.CreateFmt(
          'Can''t start reading entries. Field %s not found!',
          [FTransactionNameField]);
    end;

    if vpEntry in ViewParts then
    begin
      if
        (eoAccountName in EntryOptions)
          and
        (FindField(FAccountNameField) = nil)
      then
        raise EgsEntryViewer.CreateFmt(
          'Can''t start reading entries. Field %s not found!',
          [FAccountNameField]);

      if
        ([eoAccountAlias, eoAccountAliasInsteadOfSum] * EntryOptions <> [])
          and
        (FindField(FAccountAliasField) = nil)
      then
        raise EgsEntryViewer.CreateFmt(
          'Can''t start reading entries. Field %s not found!',
          [FAccountAliasField]);

      if eoSum in EntryOptions then
      begin
        if (FindField(FDebitSumField) = nil) then
          raise EgsEntryViewer.CreateFmt(
            'Can''t start reading entries. Field %s not found!',
            [FDebitSumField]);

        if (FindField(FCreditSumField) = nil) then
          raise EgsEntryViewer.CreateFmt(
            'Can''t start reading entries. Field %s not found!',
            [FCreditSumField]);
      end;
    end;

    if (FindField(FAccountPartField) = nil) then
      raise EgsEntryViewer.CreateFmt(
        'Can''t start reading entries. Field %s not found!',
        [FAccountPartField]);

    if (FindField(FIdField) = nil) then
      raise EgsEntryViewer.CreateFmt(
        'Can''t start reading entries. Field %s not found!',
        [FIdField]);

    if (FindField(FRecordKeyField) = nil) then
      raise EgsEntryViewer.CreateFmt(
        'Can''t start reading entries. Field %s not found!',
        [FRecordKeyField]);
  end;
end;

constructor TevColumns.Create(AnOwner: TgsEntryViewer);
begin
  FViewer := AnOwner;
  FColumns := TObjectList.Create;

  FDateField := CONST_DATEFIELD;

  FDocumentNumberField := CONST_DOCUMENTNUMBERFIELD;
  FDocumentNameField := CONST_DOCUMENTNAMEFIELD;

  FTransactionNameField := CONST_TRANSACTIONNAMEFIELD;

  FRecordDescriptionField := CONST_RECORDDESCRIPTIONFIELD;

  FAccountAliasField := CONST_ACCOUNTALIASFIELD;
  FAccountNameField := CONST_ACCOUNTNAMEFIELD;
  FAccountPartField := CONST_ACCOUNTPARTFIELD;

  FDebitSumField := CONST_DEBITSUMFIELD;
  FCreditSumField := CONST_CREDITSUMFIELD;

  FIdField := CONST_IDFIELD;
  FRecordKeyField := CONST_FRECORDKEYFIELD;
end;

procedure TevColumns.CreateColumns;
begin
  // Удаляем ранее созданные колонки
  Viewer.BeginUpdate;
  try
    FColumns.Clear;

    //
    //  Колонка "проводка"
    //  присутствует обязательно

    FColumns.Add(TevColumn.Create(Self, ckRecord, taCenter, taLeftJustify));

    //
    //  Если используется режим отображения позиций проводок и
    //  режим отображения кодов счетов, то добавляем
    //  колонку "Счет"

    if
      (vpEntry in Viewer.ViewParts)
        and
       (eoAccountAlias in Viewer.EntryOptions)
    then
      FColumns.Add(TevColumn.Create(Self, ckAccount, taCenter, taRightJustify));

    //
    //  Если используется режим отображения позиций проводок и,
    //  или режим отображения сумм, или режим отображения
    //  кодов счетов вместо сумм, то добавляем колонку
    //  Дебит и Кредит

    if
      (vpEntry in Viewer.ViewParts) and
      ([eoSum, eoAccountAliasInsteadOfSum] * Viewer.EntryOptions <> []) then
    begin
      FColumns.Add(TevColumn.Create(Self, ckDebit, taCenter, taRightJustify));
      FColumns.Add(TevColumn.Create(Self, ckCredit, taCenter, taRightJustify));
    end;
  finally
    Viewer.EndUpdate;
  end;
end;

destructor TevColumns.Destroy;
begin
  FColumns.Free;

  inherited;
end;

function TevColumns.GetColumn(Index: Integer): TevColumn;
begin
  Result := FColumns[Index] as TevColumn;
end;

function TevColumns.GetColumnByKind(const Index: Integer): TevColumn;
var
  I: Integer;
  Kind: TevColumnKind;
begin
  case Index of
    0: Kind := ckRecord;
    1: Kind := ckAccount;
    2: Kind := ckDebit;
    3: Kind := ckCredit;
    else begin
      Result := nil;
      Exit;
    end;
  end;

  for I := 0 to ColumnCount - 1 do
    if Columns[I].Kind = Kind then
    begin
      Result := Columns[I];
      Exit;
    end;

  Result := nil;
end;

function TevColumns.GetColumnCount: Integer;
begin
  Result := FColumns.Count;
end;

function TevColumns.GetNamePath: string;
begin
  Result := 'Columns';
end;

function TevColumns.GetOwner: TPersistent;
begin
  Result := FViewer;
end;

function TevColumns.GetUsedColumnKinds: TevColumnKinds;
var
  I: Integer;
begin
  Result := [];

  for I := 0 to ColumnCount - 1 do
    Include(Result, Columns[I].Kind);
end;

function TevColumns.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TevColumns.Paint(const Y: Integer);
var
  I: Integer;
begin
  for I := 0 to ColumnCount - 1 do
    Columns[I].Paint(0);
end;

procedure TevColumns.ScaleColumns;
var
  Kind: TevColumnKinds;
begin
  Kind := GetUsedColumnKinds;

  Viewer.BeginUpdate;
  try
    if [ckRecord, ckAccount, ckDebit, ckCredit] * Kind =
      [ckRecord, ckAccount, ckDebit, ckCredit] then
    begin
      with Viewer.ClientRect do
      begin
        RecordColumn.ColumnWidth := Round((Right - Left) * 0.4);
        AccountColumn.ColumnWidth := Round((Right - Left) * 0.2);
        DebitColumn.ColumnWidth := Round((Right - Left) * 0.2);
        CreditColumn.ColumnWidth := Round((Right - Left) * 0.2);
      end;
    end else

    if [ckRecord, ckDebit, ckCredit] * Kind =
      [ckRecord, ckDebit, ckCredit] then
    begin
      with Viewer.ClientRect do
      begin
        RecordColumn.ColumnWidth := Round((Right - Left) * 0.8);
        DebitColumn.ColumnWidth := Round((Right - Left) * 0.1);
        CreditColumn.ColumnWidth := Round((Right - Left) * 0.1);
      end;
    end;
  finally
    Viewer.EndUpdate;
  end;
end;

{ TevColumn }

function TevColumn.CalculateHeight: Integer;
begin
  with Viewer.FontManager do
    Result := GetLineHeight(ColumnFont);
end;

constructor TevColumn.Create(AnOwner: TevColumns; AKind: TevColumnKind;
  ATitleAlignment, AnAlignment: TAlignment);
begin
  FColumns := AnOwner;
  FKind := AKind;

  FTitleAlignment := ATitleAlignment;
  FAlignment := AnAlignment;
end;

destructor TevColumn.Destroy;
begin
  inherited;
end;

function TevColumn.GetColumnIndex: Integer;
begin
  Result := FColumns.FColumns.IndexOf(Self);
end;

function TevColumn.GetColumnLeft: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to ColumnIndex - 1 do
    Inc(Result, Columns[I].ColumnWidth + 1);
end;

function TevColumn.GetDisplayName: String;
begin
  case Kind of
    ckRecord: Result := 'Проводка';
    ckAccount: Result := 'Счет';
    ckDebit: Result := 'Дебет';
    ckCredit: Result := 'Кредит';
    else
      Result := '';
  end;
end;

function TevColumn.GetViewer: TgsEntryViewer;
begin
  Result := Columns.Viewer;
end;

function TevColumn.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TevColumn.Paint(const Y: Integer);
var
  R: TRect;
begin
  with Viewer.FontManager, Viewer do
  begin
    Canvas.Font := ColumnFont;
    Canvas.Brush.Color := ColumnColor;

    R := Rect(ColumnLeft, Y, ColumnLeft + ColumnWidth, Y + GetLineHeight(ColumnFont));

    //
    //  Рисуем текс колонки

    WriteText(
      Canvas,
      R,
      2, 1,
      DisplayName,
      FTitleAlignment
    );

    //
    //  Рисуем линии колонки

    Canvas.Pen.Color := clBlack;

    Canvas.MoveTo(R.Right, R.Top);
    Canvas.LineTo(R.Right, R.Bottom + 1);

    Canvas.MoveTo(R.Left, R.Bottom);
    Canvas.LineTo(R.Right, R.Bottom);
  end;
end;

procedure TevColumn.SetColumnIndex(const Value: Integer);
var
  I: Integer;
begin
  if ColumnIndex <> Value then
  begin
    I := FColumns.FColumns.IndexOf(Self);
    FColumns.FColumns.Move(I, Value);
    Viewer.UpdateViewer;
  end;
end;

procedure TevColumn.SetColumnWidth(const Value: Integer);
begin
  if FColumnWidth <> Value then
  begin
    FColumnWidth := Value;
    Viewer.UpdateViewer;
  end;
end;

{ TevEntryRecordList }

function TevEntryRecordList.CalculateHeight: Integer;
var
  I: Integer;
  LastIndex: Integer;
begin
  Result := 0;

  if not Assigned(LastVisibleRecord) then Exit;

  LastIndex := LastVisibleRecord.RecordIndex;
  if LastIndex < RecordCount - 1 then
    Inc(LastIndex);

  for I := FirstVisibleRecord.RecordIndex to LastIndex do
  begin
    Inc(Result, Records[I].CalculateHeight);

    // Идет разделительная линия
    Inc(Result, 1);
  end;
end;

constructor TevEntryRecordList.Create(AnOwner: TgsEntryViewer);
begin
  FViewer := AnOwner;
  FRecords := TObjectList.Create;

  FActiveEntryIndex := -1;

  FTopEntry.Index := -1;
  FTopEntry.State := tesDrawFull;
end;

destructor TevEntryRecordList.Destroy;
begin
  FRecords.Free;
  
  inherited;
end;

function TevEntryRecordList.GetRecordCount: Integer;
begin
  Result := FRecords.Count;
end;

function TevEntryRecordList.GetRecord(Index: Integer): TevEntryRecord;
begin
  Result := FRecords[Index] as TevEntryRecord;
end;

function TevEntryRecordList.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TevEntryRecordList.Paint(const Y: Integer);
var
  I: Integer;
  YPos: Integer;
  LastIndex: Integer;
begin
  YPos := Y;

  if not Assigned(LastVisibleRecord) then Exit;

  LastIndex := LastVisibleRecord.RecordIndex;
  if LastIndex < RecordCount - 1 then
    Inc(LastIndex);

  for I := FirstVisibleRecord.RecordIndex to LastIndex do
  begin
    Records[I].Paint(YPos);
    Inc(YPos, Records[I].CalculateHeight);

    // Идет разделительная линия
    Inc(YPos, 1);
  end;
end;

procedure TevEntryRecordList.MoveByEntry(Distance: Integer);
var
  CurrentRecord: TevEntryRecord;
  CurrentEntry: TevEntry;
  R: TRect;
  I: Integer;
begin
  if
    (FirstVisibleEntry.GlobalEntryIndex <= ActiveEntryIndex + Distance)
      and
    (LastVisibleEntry.GlobalEntryIndex >= ActiveEntryIndex + Distance) then
  begin
    FActiveEntryIndex := ActiveEntryIndex + Distance;
    Viewer.DataLink.DataSet.GotoBookmark(ActiveEntry.EntryBM);
    Viewer.UpdateViewer;
    Exit;
  end;

  if Distance < 0 then
  begin
    if (ActiveEntryIndex + Distance < 0) then
      FActiveEntryIndex := 0
    else
      FActiveEntryIndex := ActiveEntryIndex + Distance;

    Viewer.DataLink.DataSet.GotoBookmark(ActiveEntry.EntryBM);

    FTopEntry.Index := ActiveEntryIndex;
    FTopEntry.State := tesDrawFull;
    Viewer.UpdateViewer;
  end else

  if Distance > 0 then
  begin
    Distance := Distance - (GlobalEntryCount - ActiveEntryIndex - 1);

    //
    //  Если необходим переход на большее кол-во
    //  записей, чем считано, пробуем
    //  считать их из источника данных

    while Distance > 0 do
    begin
      CurrentRecord := ReadNextRecord;

      if not Assigned(CurrentRecord) then
      begin
        Distance := 0;
        Break;
      end else
        FRecords.Add(CurrentRecord);

      Dec(Distance, CurrentRecord.EntryList.EntryCount);
    end;

    // Если переход осуществлен на указанное кол-во
    // проводок
    if Distance = 0 then
      FActiveEntryIndex := GlobalEntryCount - 1

    // Если проводок недостаточно, то переходим на последнюю возможную
    else
      FActiveEntryIndex := GlobalEntryCount + Distance - 1;

    CurrentEntry := ActiveEntry;
    CurrentRecord := CurrentEntry.EntryList.EntryRecord;

    I := ActiveEntryIndex;
    FTopEntry.Index := I;
    R := Viewer.GetClientRect;

    Inc(R.Top, Viewer.Columns.CalculateHeight);
    Inc(R.Top, 1);

    while I >= 0 do
    begin
      // Если есть место на запись проводки учитываем ее,
      // указываем новый индекс верхней проводки,
      // указываем, что рисовать нужно с конкретной проводки
      if R.Top + CurrentEntry.CalculateHeight < R.Bottom then
      begin
        FTopEntry.Index := I;
        FTopEntry.State := tesJustEntries;
      end;

      Inc(R.Top, CurrentEntry.CalculateHeight);

      // Если дошли до первой записи в проводке
      // необходимо учесть описание проводки
      if (CurrentEntry.EntryIndex = 0) and
        (vpDescription in Viewer.ViewParts)
      then begin
        Inc(R.Top);

        // Если описание вмещается, указываем, что
        // рисовать нужно с описанием проводки
        if R.Top + CurrentRecord.Description.CalculateHeight < R.Bottom then
          FTopEntry.State := tesDrawFull;

        Inc(R.Top, CurrentRecord.Description.CalculateHeight);
      end;

      if (R.Top < R.Bottom) and (I > 0) then
        Dec(I)
      else
        Break;

      // Переходим на предыдущую проводку
      if (CurrentEntry.EntryIndex = 0) and (I > 0) then
      begin
        Inc(R.Top);
        CurrentRecord := Records[CurrentRecord.RecordIndex - 1];

        // Если используется итого, берем его в расчет
        if (vpTotal in Viewer.ViewParts) then
        begin
          Inc(R.Top, CurrentRecord.Total.CalculateHeight);
          Inc(R.Top, 1);
        end;
      end;

      CurrentEntry := CurrentRecord.EntryList[I - CurrentRecord.GlobalOffSet];
    end;

    Viewer.DataLink.DataSet.GotoBookmark(ActiveEntry.EntryBM);
    Viewer.UpdateViewer;
  end;
end;

procedure TevEntryRecordList.MoveByRecord(Distance: Integer);
var
  E: TevEntry;
  CurrentRecord: TevEntryRecord;
  I, K: Integer;
  R: TRect;
begin
  //
  //  Если перемещение в пределах экрана

  if
    (ActiveRecord.RecordIndex + Distance >= FirstVisibleRecord.RecordIndex)
      and
    (ActiveRecord.RecordIndex + Distance <= LastVisibleRecord.RecordIndex)
  then begin
    if
      (FTopEntry.State = tesJustEntries)
        and
      (FirstVisibleRecord = Records[ActiveRecord.RecordIndex + Distance])
    then
      FTopEntry.State := tesDrawFull;

    E := Records[ActiveRecord.RecordIndex + Distance].EntryList[0];
    FActiveEntryIndex := E.EntryList[0].GlobalEntryIndex;

    Viewer.DataLink.DataSet.GotoBookmark(E.EntryBM);
    Viewer.UpdateViewer;
    Exit;
  end;

  //
  //  Если перемещение вверх на определенное
  //  число проводок

  if Distance < 0 then
  begin
    if (ActiveRecordIndex + Distance < 0) then
    begin
      FActiveEntryIndex := 0;
      Viewer.DataLink.DataSet.GotoBookmark(Records[0].EntryList[0].EntryBM);
    end else begin
      E := Records[ActiveRecordIndex + Distance].EntryList[0];
      FActiveEntryIndex := E.GlobalEntryIndex;
      Viewer.DataLink.DataSet.GotoBookmark(E.EntryBM);
    end;

    FTopEntry.Index := FActiveEntryIndex;
    FTopEntry.State := tesDrawFull;
    Viewer.UpdateViewer;
  end else

  //
  //  Если перемещение вниз на определенное число проводок

  if Distance > 0 then
  begin
    Distance := Distance - (RecordCount - ActiveRecordIndex - 1);

    //
    //  Если необходим переход на большее кол-во
    //  проводок, чем считано, пробуем
    //  считать их из источника данных

    while Distance > 0 do
    begin
      CurrentRecord := ReadNextRecord;

      if not Assigned(CurrentRecord) then
      begin
        Distance := 0;
        Break;
      end else
        FRecords.Add(CurrentRecord);

      Dec(Distance);
    end;

    // Если переход осуществлен на указанное кол-во
    // проводок
    if Distance = 0 then
      FActiveEntryIndex := Records[RecordCount - 1].EntryList[0].
        GlobalEntryIndex

    // Если проводок недостаточно, то переходим на последнюю возможную
    else
      FActiveEntryIndex := Records[RecordCount + Distance - 1].EntryList[0].
        GlobalEntryIndex;

    //
    //  Определяем верхнюю первую видимую запись проводки

    E := ActiveRecord.EntryList[0];
    R := Viewer.GetClientRect;
    Inc(R.Top, Viewer.Columns.CalculateHeight);
    Inc(R.Top, 1);

    for I := ActiveRecordIndex downto 0 do
    begin
      // Если вмещается вся проводка, берем ее в расчет
      if R.Bottom - Records[I].CalculateHeight > R.Top then
      begin
        Dec(R.Bottom, Records[I].CalculateHeight);
        Dec(R.Bottom, 1);
        FTopEntry.Index := Records[I].EntryList.Entries[0].GlobalEntryIndex;
        FTopEntry.State := tesDrawFull;
      end else

      // Если вся проводка не вмещается берем в расчет
      // позиции проводки, если они отображаются
      if vpEntry in Viewer.ViewParts then
      begin
        with Records[I].EntryList, Viewer do
        begin
          // Если итог - необходимо высчитать его
          if vpTotal in ViewParts then
          begin
            Dec(R.Bottom, Records[I].Total.CalculateHeight);
            Dec(R.Bottom, 1);
          end;

          // Указываем, что уже отображаем сверху, начиная
          // не с проводки, а с записи проводки
          FTopEntry.State := tesJustEntries;

          for K := EntryCount - 1 downto 0 do
          begin
            if R.Bottom - Entries[K].CalculateHeight > R.Top then
            begin
              FTopEntry.Index := Entries[K].GlobalEntryIndex;
              Dec(R.Bottom, Entries[K].CalculateHeight);
            end else
              Break;
          end;
        end;

        Break;
      end;
    end;

    //
    //  Устанавливаем курсор на активную запись

    Viewer.DataLink.DataSet.GotoBookmark(E.EntryBM);
    Viewer.UpdateViewer;
  end;
end;

function TevEntryRecordList.ReadNextRecord: TevEntryRecord;
var
  CurrRecord: TevEntryRecord;
  RecordKey: Integer;
begin
  Result := nil;

  Viewer.BeginUpdate;
  try
    with Viewer.DataLink.DataSet, Viewer.Columns do
    begin
      // Переходим на последнюю проводку
      if Self.RecordCount > 0 then
      begin
        GotoBookmark(Records[Self.RecordCount - 1].RecordBM);

        RecordKey := FieldByName(RecordKeyField).AsInteger;

        // Переходим на первую запись новой проводки
        while
          not EOF
            and
          (RecordKey = FieldByName(RecordKeyField).AsInteger)
        do
          Next;

        // Если новая проводка не обнаружена - выходим
        if RecordKey = FieldByName(RecordKeyField).AsInteger then
          Exit;
      end;

      // Считываем новую проводку

      CurrRecord := TevEntryRecord.Create(Self);

      if not CurrRecord.EntryList.ReadEntries then
        CurrRecord.Free
      else
        Result := CurrRecord;
    end;
  finally
    Viewer.StopUpdate;
  end;
end;

function TevEntryRecordList.GetActiveRecord: TevEntryRecord;
var
  E: TevEntry;
begin
  E := ActiveEntry;
  if Assigned(E) then
    Result := ActiveEntry.EntryList.EntryRecord
  else
    Result := nil;
end;

function TevEntryRecordList.GetActiveEntry: TevEntry;
var
  CurrPos: Integer;
  I: Integer;
begin
  CurrPos := 0;
  for I := 0 to RecordCount - 1 do
  begin
    if
      (FActiveEntryIndex >= CurrPos) and
      (FActiveEntryIndex < CurrPos + Records[I].EntryList.EntryCount)
    then begin
      Result := Records[I].EntryList[FActiveEntryIndex - CurrPos];
      Exit;
    end;

    Inc(CurrPos, Records[I].EntryList.EntryCount);
  end;

  Result := nil;
end;

function TevEntryRecordList.GetActiveRecordIndex: Integer;
var
  R: TevEntryREcord;
begin
  R := ActiveRecord;

  if Assigned(R) then
    Result := FRecords.IndexOf(R)
  else
    Result := -1;
end;

function TevEntryRecordList.GetFirstVisibleRecord: TevEntryRecord;
var
  CurrPos: Integer;
  I: Integer;
begin
  CurrPos := 0;
  for I := 0 to RecordCount - 1 do
  begin
    if
      (FTopEntry.Index >= CurrPos) and
      (FTopEntry.Index < CurrPos + Records[I].EntryList.EntryCount)
    then begin
      Result := Records[I].EntryList[FTopEntry.Index - CurrPos].FEntryList.FEntryRecord;
      Exit;
    end;

    Inc(CurrPos, Records[I].EntryList.EntryCount);
  end;

  Result := nil;
end;

function TevEntryRecordList.GetLastVisibleRecord: TevEntryRecord;
var
  I: Integer;
  R: TRect;
  CurrRecord: TevEntryRecord;
  BM: TBookmark;
begin
  Result := FirstVisibleRecord;
  if not Assigned(Result) then Exit;

  R := Viewer.ClientRect;
  Inc(R.Top, Viewer.Columns.CalculateHeight);

  I := Result.RecordIndex;

  while I < RecordCount do
  begin
    // Пока есть свободное место на экране берем
    // записи в расчет
    if R.Top + Records[I].CalculateHeight < R.Bottom then
    begin
      Inc(R.Top, Records[I].CalculateHeight);
      Result := Records[I];
    end else
      Break;

    Inc(I);

    // Если закончились записи пытаемся
    // считать оставшиеся

    if (I = RecordCount) then
    with Viewer.DataLink.DataSet do
    begin
      BM := GetBookmark;
      try
        while R.Top < R.Bottom do
        begin
          GotoBookmark(Records[I - 1].RecordBM);
          CurrRecord := ReadNextRecord;

          if CurrRecord <> nil then
          begin
            FRecords.Add(CurrRecord);
            Inc(R.Top, Records[I].CalculateHeight);
            Result := Records[I];
          end else
            Break;

          Inc(I);  
        end;
      finally
        if BookmarkValid(BM) then
          GotoBookMark(BM);

        FreeBookmark(BM);
      end;
    end;
  end;
end;

function TevEntryRecordList.GetTopEntryIndex: Integer;
begin
  Result := FTopEntry.index;
end;

function TevEntryRecordList.GetTopEntryState: TevTopEntryState;
begin
  Result := FTopEntry.State;
end;

function TevEntryRecordList.GetFirstVisibleEntry: TevEntry;
var
  Rec: TevEntryRecord;
begin
  if not (vpEntry in Viewer.ViewParts) then
  begin
    Result := nil;
    Exit;
  end;

  Rec := FirstVisibleRecord;
  Result := Rec.EntryList[TopEntryIndex - Rec.GlobalOffSet];
end;

function TevEntryRecordList.GetLastVisibleEntry: TevEntry;
var
  R: TRect;
  I, K: Integer;
begin
  Result := nil;

  if not (vpEntry in Viewer.ViewParts) then
    Exit;

  R := Viewer.GetClientRect;
  Inc(R.Top, Viewer.Columns.CalculateHeight);
  Inc(R.Top, 1);

  for I := FirstVisibleRecord.RecordIndex to RecordCount - 1 do
  begin
    if R.Top + Records[I].CalculateHeight < R.Bottom then
    begin
      Inc(R.Top, Records[I].CalculateHeight);
      Inc(R.Top, 1);
      Result := Records[I].EntryList[Records[I].EntryList.EntryCount - 1];
    end else begin
      Inc(R.Top, 1);

      with Records[I] do
      begin
        if vpDescription in Viewer.ViewParts then
        begin
          Inc(R.Top, Description.CalculateHeight);
          Inc(R.Top, 1);
        end;

        for K := 0 to EntryList.EntryCount - 1 do
        begin
          Inc(R.Top, EntryList.Entries[K].CalculateHeight);

          if R.Top < R.Bottom then
            Result := EntryList[K]
          else
            Break;
        end;
      end;
    end;
  end;
end;

function TevEntryRecordList.GetGlobalEntryCount: Integer;
begin
  Result := 0;

  if RecordCount > 0 then
  with Records[RecordCount - 1].EntryList do
    if EntryCount > 0 then
      Result := Entries[EntryCount - 1].GlobalEntryIndex + 1;
end;

procedure TevEntryRecordList.FetchAll;
var
  CurrentRecord: TevEntryRecord;
begin
  with Viewer.DataLink.DataSet do
  while not EOF do
  begin
    CurrentRecord := ReadNextRecord;

    if CurrentRecord <> nil then
      FRecords.Add(CurrentRecord)
    else
      Break;  
  end;
end;

function TevEntryRecordList.GetEntryByGlobalEntryIndex(
  Index: Integer): TevEntry;
var
  CurrPos: Integer;
  I: Integer;
begin
  CurrPos := 0;
  for I := 0 to RecordCount - 1 do
  begin
    if
      (Index >= CurrPos) and
      (Index < CurrPos + Records[I].EntryList.EntryCount)
    then begin
      Result := Records[I].EntryList[Index - CurrPos];
      Exit;
    end;

    Inc(CurrPos, Records[I].EntryList.EntryCount);
  end;

  Result := nil;
end;

function TevEntryRecordList.GetVisibleEntryCount: Integer;
var
  I: Integer;
  R: TRect;
begin
  Result := 0;

  for I := FirstVisibleRecord.RecordIndex to LastVisibleRecord.RecordIndex - 1 do
    Inc(Result, Records[I].EntryList.EntryCount);

  with LastVisibleRecord.EntryList do
    for I := 0 to EntryCount - 1 do
    begin
      Viewer.CalcDrawInfo(diEntry, FEntryRecord.RecordIndex, I, R);
      if R.Bottom < Viewer.GetClientRect.Bottom then Inc(Result);
    end;  
end;

{ TevEntryRecord }

function TevEntryRecord.CalculateHeight: Integer;
var
  ShouldInc: Boolean;
begin
  Result := 0;
  ShouldInc := False;

  if vpDescription in Viewer.ViewParts then
  begin
    // Если запись является самой первой видимой
    // и используется режим отображения только
    // записей - не берем в расчет описание проводки
    if
      (EntryRecordList.TopEntryState = tesDrawFull)
        or
      (
        (EntryRecordList.TopEntryState = tesJustEntries)
           and
        (EntryRecordList.FirstVisibleRecord <> Self)
      )
    then begin
      Inc(Result, FDescription.CalculateHeight);
      ShouldInc := True;
    end;
  end;

  if vpEntry in Viewer.ViewParts then
  begin
    if ShouldInc then
      Inc(Result);

    Inc(Result, FEntryList.CalculateHeight);
  end;

  if vpTotal in Viewer.ViewParts then
    Inc(Result, FTotal.CalculateHeight);
end;

constructor TevEntryRecord.Create(AnOwner: TevEntryRecordList);
begin
  FEntryRecordList := AnOwner;

  if vpDescription in Viewer.ViewParts then
    FDescription := TevDescription.Create(Self)
  else
    FDescription := nil;

  if vpTotal in Viewer.ViewParts then
    FTotal := TevEntryRecordTotal.Create(Self)
  else
    FTotal := nil;

  FEntryList := TevEntryList.Create(Self);

  with FEntryRecordList do
  begin
    if RecordCount > 0 then
      FGlobalOffSet := Records[RecordCount - 1].FGlobalOffSet +
        Records[RecordCount - 1].EntryList.EntryCount
    else
      FGlobalOffSet := 0;
  end;
end;

destructor TevEntryRecord.Destroy;
begin
  if Assigned(FDescription) then
    FDescription.Free;
  if Assigned(FTotal) then
    FTotal.Free;
  FEntryList.Free;

  inherited;
end;

function TevEntryRecord.GetRecordBM: TBookmark;
begin
  if EntryList.EntryCount > 0 then
    Result := EntryList[0].EntryBM
  else
    Result := nil;  
end;

function TevEntryRecord.GetRecordIndex: Integer;
begin
  Result := EntryRecordList.FRecords.IndexOf(Self);
end;

function TevEntryRecord.GetViewer: TgsEntryViewer;
begin
  Result := FEntryRecordList.Viewer;
end;

function TevEntryRecord.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;

  /// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  if EntryRecordList.FirstVisibleRecord.RecordIndex > RecordIndex then
    Exit;

  if vpDescription in Viewer.ViewParts then
    Result := Description.MouseDown(X, Y);

  if not Result then
    Result := EntryList.MouseDown(X, Y);
end;

procedure TevEntryRecord.Paint(const Y: Integer);
var
  YPos: Integer;
  ShouldInc: Boolean;
begin
  YPos := Y;
  ShouldInc := False;

  if vpDescription in Viewer.ViewParts then
  begin
    // Если запись является самой первой видимой
    // и используется режим отображения только
    // записей - не отображаем описание проводки
    if
      (EntryRecordList.TopEntryState = tesDrawFull)
        or
      (
        (EntryRecordList.TopEntryState = tesJustEntries)
           and
        (EntryRecordList.FirstVisibleRecord <> Self)
      )
    then begin
      FDescription.Paint(YPos);
      Inc(YPos, FDescription.CalculateHeight);
      ShouldInc := True;
    end
  end;

  if vpEntry in Viewer.ViewParts then
  begin
    if ShouldInc then
      Inc(YPos)
    else
      ShouldInc := True;

    FEntryList.Paint(YPos);
    Inc(YPos, FEntryList.CalculateHeight);
  end;

  if vpTotal in Viewer.ViewParts then
  begin
    if ShouldInc then
      Inc(YPos);

    FTotal.Paint(YPos);
    Inc(YPos, FTotal.CalculateHeight);
  end;

  with Viewer do
  begin
    Canvas.MoveTo(ClientRect.Left, YPos);
    Canvas.LineTo(ClientRect.Right, YPos);
  end;
end;

{ TevEntryRecordTotal }

function TevEntryRecordTotal.CalculateHeight: Integer;
begin
  with Viewer.FontManager do
    Result := GetLineHeight(FTotalFont);

  // Дополнительные полосы для красоты  
  Inc(Result, 2);
end;

constructor TevEntryRecordTotal.Create(AnOwner: TevEntryRecord);
begin
  FEntryRecord := AnOwner;
end;

destructor TevEntryRecordTotal.Destroy;
begin
  inherited;
end;

function TevEntryRecordTotal.GetViewer: TgsEntryViewer;
begin
  Result := FEntryRecord.Viewer;
end;

function TevEntryRecordTotal.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TevEntryRecordTotal.Paint(const Y: Integer);
begin
end;

{ TevDescription }

function TevDescription.CalculateHeight: Integer;
begin
  with Viewer.FontManager do
    Result := GetLineHeight(DescriptionFont);

  // Дополнительная разделительная полоса  
  //Inc(Result, 1);
end;

constructor TevDescription.Create(AnOwner: TevEntryRecord);
begin
  FEntryRecord := AnOwner;
end;

destructor TevDescription.Destroy;
begin
  inherited;
end;

function TevDescription.GetDescriptionText(const ShouldGotoBookmark:
  Boolean = True): String;
var
  BM: Tbookmark;
begin
  Result := '';

  with Viewer, Viewer.DataLink.DataSet, Viewer.Columns do
  begin
    if ShouldGotoBookmark then
      BM := GetBookmark
    else
      BM := nil;

    try
      if doDocumentName in DescriptionOptions then
        Result := FieldByName(DocumentNameField).AsString;

      if doDocumentNumber in DescriptionOptions then
      begin
        if Result > '' then
          Result := Result + ', ';

        Result := Result +
          FieldByName(DocumentNumberField).AsString;
      end;

      if doRecordDescription in DescriptionOptions then
      begin
        if Result > '' then
          Result := Result + ', ';

        Result := Result +
          FieldByName(RecordDescriptionField).AsString;
      end;

      if doTransactionName in DescriptionOptions then
      begin
        if Result > '' then
          Result := Result + ', ';

        Result := Result +
          FieldByName(TransactionNameField).AsString;
      end;
    finally
      if ShouldGotoBookmark then
      begin
        if BookmarkValid(BM) then
          GotoBookmark(BM);

          FreeBookmark(BM);
      end;
    end;
  end;
end;

function TevDescription.GetViewer: TgsEntryViewer;
begin
  Result := FEntryRecord.Viewer;
end;

function TevDescription.MouseDown(X, Y: Integer): Boolean;
var
  R: TRect;
begin
  with FEntryRecord.EntryRecordList do
  begin
    Viewer.CalcDrawInfo(diDescription, FEntryRecord.RecordIndex, 0, R);

    Result := PointInRect(X, Y, R);

    if Result then
    with Viewer, Viewer.DataLink.DataSet do
    begin
      MovementStep := msByRecord;
      GotoBookmark(FEntryRecord.RecordBM);

      Viewer.FEntryRecordList.FActiveEntryIndex :=
        FEntryRecord.EntryList[0].GlobalEntryIndex;

      UpdateViewer;
    end;
  end;  
end;

procedure TevDescription.Paint(const Y: Integer);
var
  YPos, XPos: Integer;
  R: TRect;
  BM: Tbookmark;
begin
  YPos := Y;
  XPos := 2;

  with Viewer, Viewer.FontManager, Viewer.DataLink.DataSet, Viewer.Columns do
  begin
    BM := GetBookmark;

    try

      // Если запись является выделенной, применяем соответсвующие
      // шшрифт и цвет, не забываем, что может применяться режим
      // выделения тодельной записи в проводке.
      if
        (MovementStep = msByRecord)
          and
        (CompareBookmarks(BM, EntryRecord.RecordBM) = 0)
      then begin
        Canvas.Font := SelectedRecordFont;
        Canvas.Brush.Color := SelectedRecordColor;
      end else begin
        Canvas.Font := DescriptionFont;
        Canvas.Brush.Color := DescriptionColor;
      end;

      GotoBookmark(EntryRecord.RecordBM);

      if doDocumentDate in DescriptionOptions then
      begin
        R := Rect(
          ClientRect.Left, YPos,
          ClientRect.Right, YPos + GetLineHeight(DescriptionFont)
        );

        WriteText(Canvas, R, 2, 1, FieldByName(DateField).AsString,
          taLeftJustify);

        XPos := 60;
      end;

      if [doDocumentNumber, doDocumentName, doRecordDescription,
        doTransactionName] * DescriptionOptions <> [] then
      begin
        R := Rect(
          ClientRect.Left, YPos,
          ClientRect.Right, YPos + GetLineHeight(DescriptionFont)
        );

        WriteText(Canvas, R, XPos, 1, GetDescriptionText(False), taLeftJustify);
      end;

      Canvas.Pen.Color := clBlack;
      Canvas.MoveTo(ClientRect.Left, YPos + GetLineHeight(DescriptionFont));
      Canvas.LineTo(ClientRect.Right, YPos + GetLineHeight(DescriptionFont));

      // Если запись является выделенной, рисуем
      // фокусировку
      if
        Focused
          and
        (MovementStep = msByRecord)
          and
        (CompareBookmarks(BM, EntryRecord.RecordBM) = 0)
      then begin
        Windows.DrawFocusRect(Canvas.Handle, Rect(
          ClientRect.Left,
          YPos + 1,
          ClientRect.Right,
          YPos + GetLineHeight(DescriptionFont) - 1)
        );
      end;
    finally
      if BookmarkValid(BM) then
        GotoBookmark(BM);

      FreeBookmark(BM);
    end;
  end;
end;

{ TevEntryList }

function TevEntryList.CalculateHeight: Integer;
var
  I: Integer;
  StartIndex: Integer;
begin
  Result := 0;

  // Если запись является самой первой видимой
  // и используется режим отображения только
  // записей - не отображаем описание проводки
  if
    (EntryRecord.EntryRecordList.TopEntryState = tesJustEntries)
       and
    (EntryRecord.EntryRecordList.FirstVisibleRecord = EntryRecord)
  then
    StartIndex := EntryRecord.EntryRecordList.TopEntryIndex -
      EntryRecord.GlobalOffSet
  else
    StartIndex := 0;

  for I := StartIndex to EntryCount - 1 do
    Inc(Result, Entries[I].CalculateHeight);
end;

constructor TevEntryList.Create(AnOwner: TevEntryRecord);
begin
  FEntryRecord := AnOwner;
  FEntries := TObjectList.Create;
end;

destructor TevEntryList.Destroy;
begin
  FEntries.Free;

  inherited;
end;

function TevEntryList.GetEntryCount: Integer;
begin
  Result := FEntries.Count;
end;

function TevEntryList.GetEntry(Index: Integer): TevEntry;
begin
  Result := FEntries[Index] as TevEntry;
end;

function TevEntryList.GetViewer: TgsEntryViewer;
begin
  Result := FEntryRecord.Viewer;
end;

function TevEntryList.MouseDown(X, Y: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;

  for I := 0 to EntryCount - 1 do
  begin
    Result := Entries[I].MouseDown(X, Y);
    if Result then Break;
  end;
end;

procedure TevEntryList.Paint(const Y: Integer);
var
  I: Integer;
  StartIndex: Integer;
  YPos: Integer;
begin
  YPos := Y;

  // Если запись является самой первой видимой
  // и используется режим отображения только
  // записей - не отображаем описание проводки
  if
    (EntryRecord.EntryRecordList.TopEntryState = tesJustEntries)
       and
    (EntryRecord.EntryRecordList.FirstVisibleRecord = EntryRecord)
  then
    StartIndex := EntryRecord.EntryRecordList.TopEntryIndex -
      EntryRecord.GlobalOffSet
  else
    StartIndex := 0;

  for I := StartIndex to EntryCount - 1 do
  begin
    Entries[I].Paint(YPos);
    Inc(YPos, Entries[I].CalculateHeight);
  end;

  if Viewer.GridLines then
    for I := 0 to Viewer.Columns.ColumnCount - 1 do
    begin
      Viewer.Canvas.MoveTo(
        Viewer.Columns[I].ColumnLeft + Viewer.Columns[I].ColumnWidth, Y);
      Viewer.Canvas.LineTo(
        Viewer.Columns[I].ColumnLeft + Viewer.Columns[I].ColumnWidth, YPos);
    end;
end;

function TevEntryList.ReadEntries: Boolean;
var
  RecordKey: Integer;
begin
  with Viewer.DataLink.DataSet, Viewer.Columns do
  begin
    RecordKey := FieldByName(RecordKeyField).AsInteger;

    while
      not EOF
        and
      (RecordKey = FieldByName(RecordKeyField).AsInteger)
    do begin
      FEntries.Add(TevEntry.Create(Self, GetBookmark));
      Next;
    end;
  end;

  Result := FEntries.Count > 0;
end;

{ TevEntry }

function TevEntry.CalculateHeight: Integer;
begin
  Result := CalculateJustEntryHeight;

  if (eoAnalytic in Viewer.EntryOptions) and HasAnalytic then
    Result := Result + FAnalytic.CalculateHeight;
end;

constructor TevEntry.Create(AnOwner: TevEntryList);
begin
  FEntryList := AnOwner;
  FAnalytic := nil;
  FEntryBM := nil;
end;

constructor TevEntry.Create(AnOwner: TevEntryList; ABM: Tbookmark);
begin
  Create(AnOwner);
  FEntryBM := ABM;
end;

destructor TevEntry.Destroy;
begin
  if Assigned(FAnalytic) then
    FAnalytic.Free;

  if FEntryBM <> nil then
  begin
    if Viewer.DataLink.Active then
      Viewer.DataLink.DataSet.FreeBookmark(FEntryBM)
    else
      FreeMem(FEntryBM);
  end;

  inherited;
end;

function TevEntry.GetGlobalEntryIndex: Integer;
begin
  Result := FEntryList.EntryRecord.FGlobalOffSet + EntryIndex;
end;

function TevEntry.GetEntryIndex: Integer;
begin
  Result := EntryList.FEntries.IndexOf(Self);
end;

function TevEntry.GetViewer: TgsEntryViewer;
begin
  Result := FEntryList.Viewer;
end;

function TevEntry.HasAnalytic: Boolean;
begin
  Result := FAnalytic <> nil;
end;

function TevEntry.MouseDown(X, Y: Integer): Boolean;
var
  R: TRect;
begin
  with FEntryList.FEntryRecord do
    Viewer.CalcDrawInfo(
      diEntry,
      RecordIndex,
      EntryIndex,
      R
    );

  Result := PointInRect(X, Y, R);

  if Result then
  with Viewer, Viewer.DataLink.DataSet do
  begin
    MovementStep := msByEntry;
    GotoBookmark(EntryBM);
    Viewer.FEntryRecordList.FActiveEntryIndex := Self.GlobalEntryIndex;
    UpdateViewer;
  end;
end;

procedure TevEntry.Paint(const Y: Integer);
var
  R: TRect;
  YPos: Integer;
  AccountText: String;
  BM: TBookmark;
begin
  YPos := Y;

  with Viewer.DataLink.DataSet do
  begin
    BM := GetBookmark;
    GotoBookMark(EntryBM);

    try
      with Viewer, Viewer.Columns, Viewer.FontManager, Viewer.DataLink.DataSet do
      begin
        // Если запись является выделенной, применяем соответсвующие
        // шшрифт и цвет, не забываем, что может применяться режим
        // выделения тодельной проводки.
        if
          (MovementStep = msByEntry)
            and
          (CompareBookmarks(BM, EntryBM) = 0)
        then begin
          Canvas.Font := SelectedEntryFont;
          Canvas.Brush.Color := SelectedEntryColor;
        end else begin
          Canvas.Font := EntryFont;
          Canvas.Brush.Color := EntryColor;
        end;

        with GetClientRect do
          Canvas.FillRect(Rect(Left, YPos, Right, YPos + CalculateHeight));

        //
        //  Наименование счета

        if eoAccountName in EntryOptions then
        begin
          R := Rect(
            RecordColumn.ColumnLeft,
            YPos,
            RecordColumn.ColumnLeft + RecordColumn.ColumnWidth,
            YPos + GetLineHeight(EntryFont)
          );

          WriteText(Canvas, R, 2, 2, FieldByName(AccountNameField).AsString,
            RecordColumn.Alignment);
        end;

        //
        //  Код счета

        if eoAccountAlias in EntryOptions then
        begin
          R := Rect(
            AccountColumn.ColumnLeft,
            YPos,
            AccountColumn.ColumnLeft + AccountColumn.ColumnWidth,
            YPos + GetLineHeight(EntryFont)
          );

          WriteText(Canvas, R, 2, 2, FieldByName(AccountAliasField).AsString,
            AccountColumn.Alignment);
        end;

        //
        //  Сумма по счету

        if eoSum in EntryOptions then
        begin
          R := Rect(
            DebitColumn.ColumnLeft,
            YPos,
            DebitColumn.ColumnLeft + DebitColumn.ColumnWidth,
            YPos + GetLineHeight(EntryFont)
          );

          WriteText(Canvas, R, 2, 2, FieldByName(DebitSumField).AsString,
            DebitColumn.Alignment);

          R := Rect(
            CreditColumn.ColumnLeft,
            YPos,
            CreditColumn.ColumnLeft + CreditColumn.ColumnWidth,
            YPos + GetLineHeight(EntryFont)
          );

          WriteText(Canvas, R, 2, 2, FieldByName(CreditSumField).AsString,
            CreditColumn.Alignment);
        end;

        //
        // Если наименование счета вместо суммы

        if eoAccountAliasInsteadOfSum in EntryOptions then
        begin
          R := Rect(
            DebitColumn.ColumnLeft,
            YPos,
            DebitColumn.ColumnLeft + DebitColumn.ColumnWidth,
            YPos + GetLineHeight(EntryFont)
          );

          if FieldByName(AccountPartField).AsString = 'D' then
            AccountText := FieldByName(AccountAliasField).AsString else
            AccountText := '';

          WriteText(Canvas, R, 2, 2, AccountText, DebitColumn.Alignment);


          R := Rect(
            CreditColumn.ColumnLeft,
            YPos,
            CreditColumn.ColumnLeft + CreditColumn.ColumnWidth,
            YPos + GetLineHeight(EntryFont)
          );

          if FieldByName(AccountPartField).AsString = 'C' then
            AccountText := FieldByName(AccountAliasField).AsString else
            AccountText := '';

          WriteText(Canvas, R, 2, 2, AccountText, CreditColumn.Alignment);
        end;

        // Если запись является выделенной, рисуем
        // фокусировку
        if
          Focused
            and
          (MovementStep = msByEntry)
            and
          (CompareBookmarks(BM, EntryBM) = 0)
        then begin
          Windows.DrawFocusRect(Canvas.Handle, Rect(
            ClientRect.Left,
            YPos + 1,
            ClientRect.Right,
            YPos + GetLineHeight(EntryFont) - 1)
          );
        end;
      end;
    finally
      if BookmarkValid(BM) then
        GotoBookMark(BM);
        
      FreeBookmark(BM);
    end;
  end;
end;

function TevEntry.CalculateJustEntryHeight: Integer;
begin
  with Viewer.FontManager do
    Result := GetLineHeight(EntryFont);
end;

{ TevAnalytic }

function TevAnalytic.CalculateHeight: Integer;
begin
  Result := 0;
end;

constructor TevAnalytic.Create(AnOwner: TevEntry);
begin
  FEntry := AnOwner;
end;

destructor TevAnalytic.Destroy;
begin
  inherited;

end;

function TevAnalytic.GetViewer: TgsEntryViewer;
begin
  Result := FEntry.Viewer;
end;

function TevAnalytic.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TevAnalytic.Paint(const Y: Integer);
begin
end;

initialization

  DrawBitmap := TBitmap.Create;

finalization

  DrawBitmap.Free;

end.

