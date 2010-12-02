
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdEntryGrid.pas

  Abstract

    Super grid for accounting entries.

  Author

    Romanovski Denis (11-02-2001)

  Revisions history

    Initial  11-02-2001  Dennis  Initial version.


--}


unit gdEntryGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, Contnrs, IBDatabase, IBCustomDataSet, IBSQL;

type
  TenEntryGridOptions = set of (egoAnalytics, egoEntries, egoTotals);

type
  TenEntryAmount = (eaAmount, eaCurrency, eaEquivalent);
  TenAccountType = (atDebit, atCredit, atNone);

type
  TenDrawInfo = (diAnalizeBox, diEntry, diEntryList, diDescription, diOperation,
    diOperationList, diColumn, diColumns);

  TenMoveDirection = (mdUp, mdPageUp, mdFirst, mdDown, mdPageDown,
    mdLast, mdRecord);

  TenParam = (pDocumentKey, pEntryKey, pTrTypeKey, pTrTypeLB, pTrTypeRB,
    pPositionKey, pCompanyKey, pCurrKey);
  TenParams = set of TenParam;

  TenMovementKind = (mkDescription, mkEntry);

const
  ENTRY_RELATION_NAME = 'GD_ENTRYS';

  ParamNames: array[TenParam] of String = ('DOCUMENTKEY', 'ENTRYKEY',
    'TRTYPEKEY', 'LB', 'RB', 'POSITIONKEY', 'COMPANYKEY', 'CURRKEY');

type
  TgdEntryGrid = class;

  TgdOperationList = class;
  TgdOperation = class;
  TgdEntryList = class;
  TgdEntry = class;
  TgdColumns = class;
  TgdEntryDataList = class;
  TgdRecordDataList = class;

  PRecordData = ^TRecordData;
  TRecordData = record
    EntryKey: Integer;
    DocKey: Integer;
    TrTypeKey: Integer;
    DocDate: TDateTime;
    DocNumber: String[20];
    DocName: String[60];
    TrName: String[60];

    EntryData: TgdEntryDataList;
  end;

  PEntryData = ^TEntryData;
  TEntryData = record
    ID: Integer;

    AccountType: TenAccountType;
    AccountCode: String[8];
    AccountName: String[180];

    Currency: String[8];

    Analytics: TStringList;
    AnalyticsLoaded: Boolean;

    case TenAccountType of
    atDebit:
      (Debit: packed array[TenEntryAmount] of Double);
    atCredit:
      (Credit: packed array[TenEntryAmount] of Double);
  end;

  TgdBase = class
  protected
    procedure Paint(const Y: Integer); virtual; abstract;
    function MouseDown(X, Y: Integer): Boolean; virtual; abstract;

  end;

  TgdAnalyticBox = class(TgdBase)
  private
    FEntry: TgdEntry;

    function RowHeight: Integer;

    function GetHeight: Integer;
    function GetGrid: TgdEntryGrid;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    procedure UpdateAnalytics;

  public
    constructor Create(AnOwner: TgdEntry);
    destructor Destroy; override;

    property Height: Integer read GetHeight;
    property Grid: TgdEntryGrid read GetGrid;

  end;


  TgdEntry = class(TgdBase)
  private
    FEntryList: TgdEntryList;

    FAnalitics: TgdAnalyticBox;

    function RowHeight: Integer;

    function GetOperationGrid: TgdEntryGrid;
    function GetItemIndex: Integer;
    function GetHeight: Integer;
    function GetIsActive: Boolean;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;

  public
    constructor Create(AnOwner: TgdEntryList);
    destructor Destroy; override;

    property ItemIndex: Integer read GetItemIndex;
    property Grid: TgdEntryGrid read GetOperationGrid;
    property Height: Integer read GetHeight;
    property IsActive: Boolean read GetIsActive;

  end;


  TgdEntryList = class(TgdBase)
  private
    FOperation: TgdOperation;

    FItems: TObjectList;

    function GetCount: Integer;
    function GetItem(Index: Integer): TgdEntry;
    function GetHeight: Integer;
    function GetGrid: TgdEntryGrid;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;
    procedure UpdateEntryList;

  public
    constructor Create(AnOwner: TgdOperation);
    destructor Destroy; override;

    property Grid: TgdEntryGrid read GetGrid;

    property Height: Integer read GetHeight;

    property Item[Index: Integer]: TgdEntry read GetItem; default;
    property Count: Integer read GetCount;

  end;


  TgdDescription = class(TgdBase)
  private
    FOperation: TgdOperation;

    function GetGrid: TgdEntryGrid;

    function GetHeight: Integer;
    function GetDescriptionText: String;
    function GetIsActive: Boolean;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;

  public
    constructor Create(AnOwner: TgdOperation);
    destructor Destroy; override;

    property Grid: TgdEntryGrid read GetGrid;
    property Height: Integer read GetHeight;
    property IsActive: Boolean read GetIsActive;

  end;


  TgdOperation = class(TgdBase)
  private
    FList: TgdOperationList;

    FEntryList: TgdEntryList;
    FDescription: TgdDescription;

    function TotalRowHeight: Integer;
    function CountDebitTotal: Double;
    function CountCreditTotal: Double;

    function GetItemIndex: Integer;
    function GetGrid: TgdEntryGrid;
    function GetHeight: Integer;
    function GetEntryData: TgdRecordDataList;

    function GetGlobalIndex: Integer;
    function GetIsValid: Boolean;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;

  public
    constructor Create(AnOwner: TgdOperationList);
    destructor Destroy; override;

    property EntryData: TgdRecordDataList read GetEntryData;
    property Grid: TgdEntryGrid read GetGrid;

    property IsValid: Boolean read GetIsValid;
    property Height: Integer read GetHeight;

    property ItemIndex: Integer read GetItemIndex;
    property GlobalIndex: Integer read GetGlobalIndex;

  end;


  TgdOperationList = class(TgdBase)
  private
    FGrid: TgdEntryGrid;
    FItems: TObjectList;

    function GetCount: Integer;
    function GetItem(Index: Integer): TgdOperation;
    function GetGrid: TgdEntryGrid;
    function GetHeight: Integer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;

  public
    constructor Create(AnOwner: TgdEntryGrid);
    destructor Destroy; override;

    property Height: Integer read GetHeight;

    property Grid: TgdEntryGrid read GetGrid;
    property Item[Index: Integer]: TgdOperation read GetItem; default;
    property Count: Integer read GetCount;

  end;


  TgdColumn = class(TgdBase)
  private
    FColumns: TgdColumns;

    FCaption: String;
    FName: String;

    FCaptionAlignment: TAlignment;
    FAlignment: TAlignment;

    FLeft: Integer;
    FWidth: Integer;
    FPercent: Integer;

    function GetGrid: TgdEntryGrid;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;

  public
    constructor Create(AnOwner: TgdColumns);
    destructor Destroy; override;

    property Grid: TgdEntryGrid read GetGrid;

  end;


  TgdColumns = class(TgdBase)
  private
    FGrid: TgdEntryGrid;
    FColumns: TObjectList;

    procedure InitColumns;
    procedure CountColumnsSize;

    function RowHeight: Integer;

    function GetHieght: Integer;

    function GetColumn(Index: Integer): TgdColumn;
    function GetColumnByName(AName: String): TgdColumn;
    function GetColumnCount: Integer;

  protected
    procedure Paint(const Y: Integer); override;
    function MouseDown(X, Y: Integer): Boolean; override;

  public
    constructor Create(AnOwner: TgdEntryGrid);
    destructor Destroy; override;

    property Height: Integer read GetHieght;
    property Grid: TgdEntryGrid read FGrid;

    property ColumnCount: Integer read GetColumnCount;
    property Column[Index: Integer]: TgdColumn read GetColumn; default;
    property ColumnByName[AName: String]: TgdColumn read GetColumnByName;

  end;


  TgdEntryDataList = class(TList)
  private
    FOwnItems: Boolean;

  protected
    function GetItem(Index: Integer): PEntryData;
    procedure SetItem(Index: Integer; EntryData: PEntryData);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

  public
    constructor Create(const AnOwnItems: Boolean);

    function Add(EntryData: PEntryData): Integer;
    function Remove(EntryData: PEntryData): Integer;
    procedure Insert(Index: Integer; EntryData: PEntryData);

    function IndexOf(EntryData: PEntryData): Integer;

    property Items[Index: Integer]: PEntryData read GetItem write SetItem; default;
    property OwnItems: Boolean read FOwnItems write FOwnItems;

  end;


  TgdRecordDataList = class(TList)
  private
    FGrid: TgdEntryGrid;

    function GetNext: PRecordData;

  protected
    function GetItem(Index: Integer): PRecordData;
    procedure SetItem(Index: Integer; RecordData: PRecordData);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

  public
    constructor Create(AnOwner: TgdEntryGrid);

    function Add(RecordData: PRecordData): Integer;
    function Remove(RecordData: PRecordData): Integer;
    procedure Insert(Index: Integer; RecordData: PRecordData);

    function IndexOf(RecordData: PRecordData): Integer;

    property Items[Index: Integer]: PRecordData read GetItem write SetItem; default;

  end;


  TgdAnalyticSource = class
  private
    FGrid: TgdEntryGrid;
    FSQL: TIBSQL;
    FFieldName: String;

    function GetValue(Key: String): String;
    procedure SetFieldName(const Value: String);

  protected
    procedure PrepareSQL;

  public
    constructor Create(AnOwner: TgdEntryGrid);
    destructor Destroy; override;

    property FieldName: String read FFieldName write SetFieldName;
    property Value[Key: String]: String read GetValue;

  end;


  TgdEntryDataLink = class(TDataLink)
  private
    FGrid: TgdEntryGrid;

    procedure UpdateParams;

  protected
    procedure ActiveChanged; override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;

  public
    constructor Create(AnOwner: TgdEntryGrid);
    destructor Destroy; override;

  end;


  TgdEntrySQLEvent = procedure (Sender: TObject; var SQL: String) of object;
  TgdEntryTotalEvent = procedure (Sender: TObject; Debit, Credit: Double;
    SelCount: Integer) of object;


  TgdEntryGrid = class(TCustomControl)
  private
    FList: TgdOperationList;
    FColumns: TgdColumns;

    FEntrySQL: TIBSQL;
    FEntryData: TgdRecordDataList;
    FSelectedList: TgdEntryDataList;

    FUpdateLock: Integer; // Количество блокировок перерисовки

    FTopRecord: Integer; // первая видимая запись
    FActiveRecord: Integer; // текущая фокусированная запись
    FActiveEntry: Integer; // активная часть проводки

    FMovementKind: TenMovementKind;

    FTitleFont: TFont;
    FTitleColor: TColor;

    FDescriptionFont: TFont;
    FDescriptionColor: TColor;

    FEntryFont: TFont;
    FEntryColor: TColor;

    FTotalFont: TFont;
    FTotalColor: TColor;

    FAnalyticsFont: TFont;

    FSelectedFont: TFont;
    FSelectedColor: TColor;
    FFocusedColor: TColor;

    FDatabase: TIBDatabase;
    FTransaction: TIBTransaction;
    FIBBase: TIBBase;
    FSkipIBEvent: Boolean;

    FAutoLoad: Boolean; // осуществлять ли автоматическое подключение
    FActive: Boolean; // активно ли подключение к БД
    FIsLoaded: Boolean; // загружен ли весь список проводок

    FBorderStyle: TBorderStyle;

    FAnalyticSources: TObjectList; // Список источников аналитики
    FAttrList: TStringList; // Список полей аналитики

    FOptions: TenEntryGridOptions; // Опции отображения данных

    FDataLink: TgdEntryDataLink; // Если связь мастер-детаил, то используем DataLink
    FParams: TenParams; // Какие из параметров используются
    FEntryAmount: TenEntryAmount; // Вид денежных средств

    FSQLEvent: TgdEntrySQLEvent; // События для изменения запроса пользователем
    FTotalEvent: TgdEntryTotalEvent;

    procedure PrepareEntrySQL;
    procedure UpdateScrollBar;
    procedure DoBeforeDisconnect(Sender: TObject);
    procedure DoFontChanged(Sender: TObject);

    function GetShiftState: TShiftState;

    procedure ClearSelectedList;

    procedure CMParentFontChanged(var Message: TMessage);
      message CM_PARENTFONTCHANGED;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd);
      message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode);
      message WM_GETDLGCODE;
    procedure WMVScroll(var Message: TWMVScroll);
      message WM_VSCROLL;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;

    procedure SetFont(const Index: Integer; Value: TFont);
    procedure SetColor(const Index: Integer; Value: TColor);

    function GetUpdateLock: Integer;

    procedure SetDatabase(const Value: TIBDatabase);
    procedure SetIBTransaction(const Value: TIBTransaction);
    procedure SetAutoLoad(const Value: Boolean);

    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);

    procedure SetBorderStyle(const Value: TBorderStyle);

    function GetOperation(AnIndex: Integer): TgdOperation;
    function GetOperationCount: Integer;

    function GetGlobalActiveRecord: Integer;
    procedure SetIsLoaded(const Value: Boolean);

    function GetAnalyticSource(AnIndex: Integer): TgdAnalyticSource;
    function GetAnalyticSourceCount: Integer;
    function GetAnalyticSourceName(AName: String): TgdAnalyticSource;

    procedure SetOptions(const Value: TenEntryGridOptions);
    function GetEntryKey: Integer;

    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);

    procedure SetParams(const Value: TenParams);

    function GetParam(AParam: TenParam): String;
    procedure SetParam(AParam: TenParam; const Value: String);
    procedure SetEntryAmount(const Value: TenEntryAmount);

    function GetDocumentKey: Integer;
    function GetTrTypeKey: Integer;
    function GetID: Integer;
    function GetDocDate: TDateTime;

    function GetSelected(Entry: PEntryData): Boolean;
    procedure SetSelected(Entry: PEntryData; const Value: Boolean);

  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Paint; override;

    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;

    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    procedure DoEnter; override;
    procedure DoExit; override;

    procedure UpdateGrid;

    function CountVisible(const StartIndex: Integer): Integer;

    procedure CalcDrawInfo(Info: TenDrawInfo; const Index, SubIndex: Integer;
      var R: TRect);
    procedure GetObject(Info: TenDrawInfo; const Index, SubIndex: Integer;
      out Obj: TgdBase);
    procedure UpdateObject(Info: TenDrawInfo; const Index, SubIndex: Integer);

    procedure MoveBy(const Direction: TenMoveDirection; Step: Integer = 0);
    function CanMove(const Direction: TenMoveDirection; var Step: Integer): Boolean;

    procedure UpdateAnalyticsData(Analytics: TStringList);

    property UpdateLock: Integer read GetUpdateLock;

    property OperationCount: Integer read GetOperationCount;
    property Operation[AnIndex: Integer]: TgdOperation read GetOperation;

    property Selected[Entry: PEntryData]: Boolean read GetSelected write SetSelected;

    property AnalyticSourceCount: Integer read GetAnalyticSourceCount;
    property AnalyticSource[AnIndex: Integer]: TgdAnalyticSource read GetAnalyticSource;
    property AnalyticSourceName[AName: String]: TgdAnalyticSource read GetAnalyticSourceName;

    property IsLoaded: Boolean read FIsLoaded write SetIsLoaded;
    property GlobalActiveRecord: Integer read GetGlobalActiveRecord;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure BeginUpdate;
    procedure EndUpdate;

    procedure Open;
    procedure Close;
    procedure FreeSQLHandle;

    property Active: Boolean read GetActive write SetActive;
    property Param[AParam: TenParam]: String read GetParam write SetParam;

    property EntryKey: Integer read GetEntryKey;
    property DocumentKey: Integer read GetDocumentKey;
    property TrTypeKey: Integer read GetTrTypeKey;
    property ID: Integer read GetID;
    property DocDate: TDateTime read GetDocDate;

  published
    property TitleFont: TFont index 0 read FTitleFont write SetFont;
    property DescriptionFont: TFont index 1 read FDescriptionFont write SetFont;
    property EntryFont: TFont index 2 read FEntryFont write SetFont;
    property TotalFont: TFont index 3 read FTotalFont write SetFont;
    property AnalyticsFont: TFont index 4 read FAnalyticsFont write SetFont;
    property SelectedFont: TFont index 5 read FSelectedFont write SetFont;

    property TitleColor: TColor index 0 read FTitleColor write SetColor;
    property DescriptionColor: TColor index 1 read FDescriptionColor write SetColor;
    property EntryColor: TColor index 2 read FEntryColor write SetColor;
    property TotalColor: TColor index 3 read FTotalColor write SetColor;
    property SelectedColor: TColor index 4 read FSelectedColor write SetColor;
    property FocusedColor: TColor index 5 read FFocusedColor write SetColor;


    property Database: TIBDatabase read FDatabase write SetDatabase;
    property Transaction: TIBTransaction read FTransaction write SetIBTransaction;

    property AutoLoad: Boolean read FAutoLoad write SetAutoLoad;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Options: TenEntryGridOptions read FOptions write SetOptions;

    property MasterDataSource: TDataSource read GetDataSource write SetDataSource;
    property Params: TenParams read FParams write SetParams;
    property EntryAmount: TenEntryAmount read FEntryAmount write SetEntryAmount;

    property SQLEvent: TgdEntrySQLEvent read FSQLEvent write FSQLEvent;
    property TotalEvent: TgdEntryTotalEvent read FTotalEvent write FTotalEvent;

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

  EgdEntryGridError = class(Exception);

  { TODO 1 -oденис -cсделать : Query Filter }

procedure Register;

implementation

uses Math, at_Classes;

var
  DrawBitmap: TBitmap;
  TempFont: TFont;

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


{ TgdEntryGrid }

procedure TgdEntryGrid.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

constructor TgdEntryGrid.Create(AnOwner: TComponent);
begin
  inherited;

  ControlStyle := [csCaptureMouse, csOpaque, csDoubleClicks];

  FTopRecord := 0;
  FActiveRecord := 0;
  FActiveEntry := 0;

  FUpdateLock := 0;

  FTitleFont := TFont.Create;
  FTitleFont.Color := clBlack;
  FTitleFont.Style := [fsBold];
  FTitleFont.Name := 'Tahoma';
  FTitleFont.OnChange := DoFontChanged;

  FDescriptionFont := TFont.Create;
  FDescriptionFont.Color := clWindowText;
  FDescriptionFont.Style := [];
  FDescriptionFont.Name := 'Tahoma';
  FDescriptionFont.OnChange := DoFontChanged;

  FEntryFont := TFont.Create;
  FEntryFont.Color := clWindowText;
  FEntryFont.Style := [];
  FEntryFont.Name := 'Tahoma';
  FEntryFont.OnChange := DoFontChanged;

  FTotalFont := TFont.Create;
  FTotalFont.Color := clWhite;
  FTotalFont.Style := [];
  FTotalFont.Name := 'Tahoma';
  FTotalFont.OnChange := DoFontChanged;

  FAnalyticsFont := TFont.Create;
  FAnalyticsFont.Color := clWindowText;
  FAnalyticsFont.Style := [fsItalic];
  FAnalyticsFont.Name := 'Tahoma';
  FAnalyticsFont.OnChange := DoFontChanged;

  FSelectedFont := TFont.Create;
  FSelectedFont.Color := clBlack;
  FSelectedFont.Style := [fsBold];
  FSelectedFont.Name := 'Tahoma';
  FSelectedFont.OnChange := DoFontChanged;


  FTitleColor := clBtnFace;
  FDescriptionColor := clWhite;
  FEntryColor := $00E1E1E1;
  FTotalColor := clNavy;
  FSelectedColor := clHighlight;
  FFocusedColor := clMaroon;

  FAutoLoad := True;
  FActive := False;
  FIsLoaded := False;

  FBorderStyle := bsSingle;
  TabStop := True;
  FOptions := [egoAnalytics, egoEntries, egoTotals];
  FParams := [];

  FMovementKind := mkDescription;

  FList := TgdOperationList.Create(Self);
  FColumns := TgdColumns.Create(Self);

  FEntrySQL := TIBSQL.Create(nil);

  FIBBase := TIBBase.Create(nil);
  FIBBase.BeforeDatabaseDisconnect := DoBeforeDisconnect;
  FIBBase.AfterDatabaseDisconnect := DoBeforeDisconnect;
  FIBBase.OnDatabaseFree := DoBeforeDisconnect;
  FIBBase.BeforeTransactionEnd := DoBeforeDisconnect;
  FIBBase.AfterTransactionEnd := DoBeforeDisconnect;
  FIBBase.OnTransactionFree := DoBeforeDisconnect;

  FEntryData := TgdRecordDataList.Create(Self);
  FSelectedList := TgdEntryDataList.Create(False);
  FSkipIBEvent := True;

  FAnalyticSources := TObjectList.Create;
  FAttrList := TStringList.Create;

  FSQLEvent := nil;
  FTotalEvent := nil;

  FDataLink := TgdEntryDataLink.Create(Self);
end;

destructor TgdEntryGrid.Destroy;
begin
  FEntryData.Free;
  FSelectedList.Free;
  FEntrySQL.Free;
  FIBBase.Free;

  FTitleFont.Free;
  FDescriptionFont.Free;
  FEntryFont.Free;
  FTotalFont.Free;
  FAnalyticsFont.Free;
  FSelectedFont.Free;

  FColumns.Free;
  FList.Free;

  FAnalyticSources.Free;
  FAttrList.Free;

  FDataLink.Free;

  inherited;
end;

procedure TgdEntryGrid.EndUpdate;
begin
  if FUpdateLock > 0 then
  begin
    Dec(FUpdateLock);

    if FUpdateLock = 0 then
    begin
      UpdateScrollBar;
      Invalidate;
    end;
  end;
end;

function TgdEntryGrid.GetUpdateLock: Integer;
begin
  Result := FUpdateLock; 
end;

procedure TgdEntryGrid.Paint;
begin
  inherited;

  FColumns.Paint(ClientRect.Top);
  FList.Paint(ClientRect.Top + FColumns.Height + 1);
end;

procedure TgdEntryGrid.SetColor(const Index: Integer; Value: TColor);
begin
  case Index of
    0: FTitleColor := Value;
    1: FDescriptionColor := Value;
    2: FEntryColor := Value;
    3: FTotalColor := Value;
    4: FSelectedColor := Value;
    5: FFocusedColor := Value;
  end;

  if FUpdateLock = 0 then Invalidate;
end;

procedure TgdEntryGrid.SetFont(const Index: Integer; Value: TFont);
begin
  case Index of
    0: FTitleFont.Assign(Value);
    1: FDescriptionFont.Assign(Value);
    2: FEntryFont.Assign(Value);
    3: FTotalFont.Assign(Value);
    4: FAnalyticsFont.Assign(Value);
    5: FSelectedFont.Assign(Value);
  end;

  ParentFont := False;
  if FUpdateLock = 0 then Invalidate;
end;

procedure TgdEntryGrid.SetDatabase(const Value: TIBDatabase);
begin
  if FDatabase <> Value then
  begin
    if not (csDesigning in ComponentState) and Active then
      Active := False;

    if Assigned(FDatabase) then
      FDatabase.RemoveFreeNotification(Self);

    FDatabase := Value;

    if Assigned(FDatabase) then
      FDatabase.FreeNotification(Self);

    FSkipIBEvent := True;
    FIBBase.Database := FDatabase;
    FSkipIBEvent := False;
  end;
end;

procedure TgdEntryGrid.SetIBTransaction(const Value: TIBTransaction);
begin
  if FTransaction <> Value then
  begin
    if not (csDesigning in ComponentState) and Active then
      Active := False;

    if Assigned(FTransaction) then
      FTransaction.RemoveFreeNotification(Self);

    FTransaction := Value;

    if Assigned(FTransaction) then
      FTransaction.FreeNotification(Self);

    FSkipIBEvent := True;
    FIBBase.Transaction := FTransaction;
    FSkipIBEvent := False;
  end;
end;

procedure TgdEntryGrid.UpdateGrid;
var
  CurrOperation: TgdOperation;
  Rest: Integer;
  NewCount: Integer;
begin
  BeginUpdate;
  FList.FItems.Clear;

  FColumns.InitColumns;
  FColumns.CountColumnsSize;

  Rest := ClientHeight - FColumns.Height;

  try
    while True do
    begin
      CurrOperation := TgdOperation.Create(FList);
      FList.FItems.Add(CurrOperation);

      if CurrOperation.IsValid then
      begin
        if egoEntries in FOptions then
          CurrOperation.FEntryList.UpdateEntryList;

        if (CurrOperation.Height < Rest) then
          Dec(Rest, CurrOperation.Height)
        else begin

          //
          //  Если активный элемент не видим, то следует
          //  сдвинуть верний элемент на 1

          if (FActiveRecord > OperationCount - 2) and (OperationCount > 1) then
          begin
            FList.FItems.Clear;
            Rest := ClientHeight - FColumns.Height;
            Inc(FTopRecord);

            Dec(FActiveRecord);
          end else

          //
          //  Если все классно

          begin
            FList.FItems.Remove(CurrOperation);
            Break;
          end;
        end;
      end else begin

        //
        //  Если еще осталось незаполенное пространство
        //  и верхий элемент не является первым в списке

        if FTopRecord > 0 then
          NewCount := CountVisible(FTopRecord - 1)
        else
          NewCount := 0;

        if
          (FTopRecord > 0) and
          (NewCount > OperationCount - 1) and (NewCount - 1 > FActiveRecord)
        then begin
          FList.FItems.Clear;
          Rest := ClientHeight - FColumns.Height;
          Dec(FTopRecord);

          Inc(FActiveRecord);
        end else begin
          FList.FItems.Remove(CurrOperation);
          Break;
        end;
      end;
    end;

    if (OperationCount > 0) and (FActiveRecord < 0) then
      FActiveRecord := 0;  
  finally
    EndUpdate;
  end;
end;

procedure TgdEntryGrid.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  
  if Operation = opRemove then
  begin
    if AComponent = FDatabase then
      FDatabase := nil
    else

    if AComponent = FTransaction then
      FTransaction := nil;
  end;
end;

procedure TgdEntryGrid.SetAutoLoad(const Value: Boolean);
begin
  FAutoLoad := Value;
end;

procedure TgdEntryGrid.Loaded;
begin
  inherited;
  
  if not (csDesigning in ComponentState) and FAutoLoad then
    Active := True;
end;

function TgdEntryGrid.GetActive: Boolean;
begin
  Result := FActive;
end;

procedure TgdEntryGrid.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    FSelectedList.Clear;
    
    if Assigned(FTotalEvent) then
      FTotalEvent(Self, 0, 0, 0);

    if FActive then
    begin
      if FEntrySQL.SQL.Text = '' then
        PrepareEntrySQL;

      if not Assigned(FTransaction) then
        raise EgdEntryGridError.Create('Operation not assigned!')
      else
        FTransaction.Active := True;

      FTopRecord := 0;
      FActiveRecord := 0;
      FActiveEntry := 0;
    end else begin
      FEntrySQL.Close;
      FIsLoaded := False;
      FEntryData.Clear;
    end;

    UpdateGrid;
  end;
end;

procedure TgdEntryGrid.PrepareEntrySQL;
var
  AttrsPart, WherePart, TrTypePart: String;
  I: Integer;
  EntryRelation: TatRelation;
  P: TenParam;
  SQLText: String;
begin
  FEntrySQL.Transaction := FTransaction;
  FEntrySQL.Database := Database;

  EntryRelation := atDatabase.Relations.ByRelationName(ENTRY_RELATION_NAME);
  if not Assigned(EntryRelation) then
    raise EgdEntryGridError.Create(
      '''GD_ENTRYS'' relation not found in attributes structure!');

  //
  //  Добавляем параметры

  WherePart := '';
  for P := Low(TenParam) to High(TEnParam) do
    if (P in FParams) and not (P in [pTrTypeLB, ptrTypeRB]) then
    begin
      if WherePart = '' then
        WherePart := '  AND'#13#10
      else
        WherePart := WherePart + ' AND ';

      WherePart := WherePart + Format(#13#10'  E.%0:s = :%0:s', [ParamNames[P]]);
    end;

  if WherePart > '' then
    WherePart := WherePart + #13#10;

  if [pTrTypeLB, ptrTypeRB] * FParams = [pTrTypeLB, ptrTypeRB] then
    TrTypePart := '      AND TR.LB >= :LB AND TR.RB <= :RB'
  else
    TrTypePart := '';

  //
  //  Добавляем поля-аналитику

  AttrsPart := '';
  FAttrList.Clear;

  for I := 0 to EntryRelation.RelationFields.Count - 1 do
    if EntryRelation.RelationFields[I].IsUserDefined then
    begin
      FAttrList.Add(EntryRelation.RelationFields[I].FieldName);
      AttrsPart := AttrsPart + Format(
        '  E.%s,'#13#10,
        [EntryRelation.RelationFields[I].FieldName]
      );
    end;

  SQLText :=
    'SELECT '#13#10 +
    '  E.ID, '#13#10 +
    '  E.ENTRYKEY, '#13#10 +
    '  E.DOCUMENTKEY, '#13#10 +
    '  E.TRTYPEKEY, '#13#10 +
    '  E.DEBITSUMNCU, '#13#10 +
    '  E.DEBITSUMCURR, '#13#10 +
    '  E.DEBITSUMEQ, '#13#10 +
    '  E.CREDITSUMNCU, '#13#10 +
    '  E.CREDITSUMCURR, '#13#10 +
    '  E.CREDITSUMEQ, '#13#10 +
    '  E.ACCOUNTTYPE, '#13#10 +
    AttrsPart +
    '  C.CODE AS CURRCODE, '#13#10 +
    '  CC.ALIAS AS ACCOUNTCODE, '#13#10 +
    '  CC.NAME AS ACCOUNTNAME, '#13#10 +
    '  TR.NAME AS TRNAME, '#13#10 +
    '  D.NUMBER AS DOCNUMBER, '#13#10 +
    '  D.DOCUMENTDATE AS DOCDATE, '#13#10 +
    '  DOCTYPE.NAME AS DOCNAME '#13#10 +
    ' '#13#10 +
    'FROM '#13#10 +
    '  GD_ENTRYS E '#13#10 +
    '    LEFT JOIN GD_CARDACCOUNT CC ON CC.ID = E.ACCOUNTKEY '#13#10 +
    '    LEFT JOIN GD_LISTTRTYPE TR ON TR.ID = E.TRTYPEKEY '#13#10 +
    TrTypePart +
    '    LEFT JOIN '#13#10 +
    '      ( '#13#10 +
    '        GD_DOCUMENT D '#13#10 +
    '          LEFT JOIN GD_DOCUMENTTYPE DOCTYPE ON '#13#10 +
    '            D.DOCUMENTTYPEKEY = DOCTYPE.ID '#13#10 +
    '      ) '#13#10 +
    '    ON D.ID = E.DOCUMENTKEY '#13#10 +
    ' '#13#10 +
    '    LEFT JOIN GD_CURR C ON C.ID = E.CURRKEY '#13#10 +
    ' '#13#10 +
    'WHERE'#13#10 +
    '  E.ENTRYKEY <> 1001 AND E.DELAYEDENTRY = 0 '#13#10 +
    WherePart +
    'ORDER BY '#13#10 +
    '  D.DOCUMENTDATE, '#13#10 +
    '  E.ENTRYKEY, '#13#10 +
    '  E.ACCOUNTTYPE '#13#10;

  if Assigned(FSQLEvent) then
    FSQLEvent(Self, SQLText);

  FEntrySQL.SQL.Text := SQLText;
end;

procedure TgdEntryGrid.CreateParams(var Params: TCreateParams);
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

procedure TgdEntryGrid.SetBorderStyle(const Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TgdEntryGrid.CMParentFontChanged(var Message: TMessage);
var
  OldColor: TColor;
begin
  inherited;

  if ParentFont then
  begin
    OldColor := FTitleFont.Color;
    FTitleFont.Assign(Font);
    FTitleFont.Color := OldColor;

    OldColor := FDescriptionFont.Color;
    FDescriptionFont.Assign(Font);
    FDescriptionFont.Color := OldColor;

    OldColor := FEntryFont.Color;
    FEntryFont.Assign(Font);
    FEntryFont.Color := OldColor;

    OldColor := FTotalFont.Color;
    FTotalFont.Assign(Font);
    FTotalFont.Color := OldColor;

    OldColor := FAnalyticsFont.Color;
    FAnalyticsFont.Assign(Font);
    FAnalyticsFont.Color := OldColor;

    OldColor := FSelectedFont.Color;
    FSelectedFont.Assign(Font);
    FSelectedFont.Color := OldColor;
  end;
end;

procedure TgdEntryGrid.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := -1;
end;

procedure TgdEntryGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if Active and (FEntryData.Count > 0) then
  case Key of
    VK_UP:
    begin
      MoveBy(mdUp, 1);
    end;
    VK_DOWN:
    begin
      MoveBy(mdDown, 1);
    end;
    VK_PRIOR:
    begin
      MoveBy(mdPageUp, OperationCount);
    end;
    VK_NEXT:
    begin
      MoveBy(mdPageDown, OperationCount);
    end;
    VK_HOME:
    begin
      if ssCtrl in Shift then
        MoveBy(mdFirst, 0);
    end;
    VK_END:
    begin
      if ssCtrl in Shift then
        MoveBy(mdLast, 0);
    end;
  end;
end;

function TgdEntryGrid.GetOperation(AnIndex: Integer): TgdOperation;
begin
  Result := FList.Item[AnIndex];
end;

function TgdEntryGrid.GetOperationCount: Integer;
begin
  Result := FList.Count;
end;

procedure TgdEntryGrid.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  Msg.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TgdEntryGrid.CalcDrawInfo(Info: TenDrawInfo;
  const Index, SubIndex: Integer; var R: TRect);
var
  I: TenDrawInfo;
  Z: Integer;
  CurrPos: Integer;
begin
  CurrPos := ClientRect.Top;

  for I := High(TenDrawInfo) downto Low(TenDrawInfo) do
  begin
    case I of
      diColumns:
      begin
        if I = Info then
          R := Rect(
            ClientRect.Left, ClientRect.Top,
            ClientRect.Right, ClientRect.Top + FColumns.Height
          );

        Inc(CurrPos, FColumns.Height + 1);
      end;

      diColumn:
      begin
        if I = Info then
          R := Rect(
            FColumns[Index].FLeft ,
            ClientRect.Top,
            FColumns[Index].FLeft + FColumns[Index].FWidth,
            ClientRect.Top + FColumns.Height
          );

      end;

      diOperationList:
      begin
        if I = Info then
          R := Rect(
            ClientRect.Left, CurrPos,
            ClientRect.Right, FList.Height
          );
      end;

      diOperation:
      begin
        for Z := 0 to Index - 1 do
          Inc(CurrPos, FList[Z].Height);

        if I = Info then
          R := Rect(
            ClientRect.Left, CurrPos,
            ClientRect.Right, CurrPos + FList[Index].Height
          );
      end;
      diDescription:
      begin
        if I = Info then
          R := Rect(
            ClientRect.Left, CurrPos,
            ClientRect.Right, CurrPos + FList[Index].FDescription.Height
          );

        Inc(CurrPos, FList[Index].FDescription.Height + 1);
      end;
      diEntryList:
      begin
        if I = Info then
          R := Rect(
            ClientRect.Left, CurrPos,
            ClientRect.Right, CurrPos + FList[Index].FEntryList.Height
          );
      end;
      diEntry:
      begin
        for Z := 0 to SubIndex - 1 do
          Inc(CurrPos, FList[Index].FEntryList[Z].Height);

        if I = Info then
          R := Rect(
            ClientRect.Left, CurrPos,
            ClientRect.Right, CurrPos + FList[Index].FEntryList[SubIndex].Height
          );
      end;
      diAnalizeBox:
      begin
        if I = Info then
          R := Rect(
            ClientRect.Left,
            CurrPos + FList[Index].FEntryList[SubIndex].Height,
            ClientRect.Right,
            CurrPos + FList[Index].FEntryList[SubIndex].Height +
              FList[Index].FEntryList[SubIndex].FAnalitics.Height
          );
      end;
    end;

    if I = Info then Exit;
  end;
end;

procedure TgdEntryGrid.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  inherited;

  if Button <> mbLeft then Exit;

  if not Focused and Active and (FEntryData.Count > 0) then
  begin
    SetFocus;

    if FMovementKind = mkDescription then
      UpdateObject(diDescription, FActiveRecord, 0)
    else
      UpdateObject(diEntry, FActiveRecord, FActiveEntry);
  end;

  if Active and (FEntryData.Count > 0) then
    for I := 0 to OperationCount - 1 do
      if Operation[I].MouseDown(X, Y) then Break;
end;

function TgdEntryGrid.GetGlobalActiveRecord: Integer;
begin
  Result := FTopRecord + FActiveRecord;
end;

procedure TgdEntryGrid.WMVScroll(var Message: TWMVScroll);
var
  SI: TScrollInfo;
begin
  with Message do
    case ScrollCode of
      SB_LINEUP:
        MoveBy(mdUp, 1);
      SB_LINEDOWN:
        MoveBy(mdDown, 1);
      SB_PAGEUP:
        MoveBy(mdPageUp, OperationCount);
      SB_PAGEDOWN:
        MoveBy(mdPageDown, OperationCount);
      SB_THUMBPOSITION:
        begin
          if IsLoaded then
          begin
            SI.cbSize := sizeof(SI);
            SI.fMask := SIF_ALL;
            GetScrollInfo(Self.Handle, SB_VERT, SI);
            if SI.nTrackPos <= 1 then
              MoveBy(mdFirst, 0)
            else if SI.nTrackPos >= FEntryData.Count then
              MoveBy(mdLast, 0)
            else
              MoveBy(mdRecord, SI.nTrackPos - 1);
          end
          else
            case Pos of
              0: MoveBy(mdFirst, 0);
              1: MoveBy(mdPageUp, OperationCount);
              2: Exit;
              3: MoveBy(mdPageDown, OperationCount);
              4: MoveBy(mdLast, 0);
            end;
        end;
      SB_BOTTOM:
        MoveBy(mdLast, 0);
      SB_TOP:
        MoveBy(mdFirst, 0);
    end;
end;

procedure TgdEntryGrid.CreateWnd;
begin
  inherited;
  
  UpdateScrollBar;
end;

procedure TgdEntryGrid.UpdateScrollBar;
var
  SIOld, SINew: TScrollInfo;
begin
  SIOld.cbSize := sizeof(SIOld);
  SIOld.fMask := SIF_ALL;

  GetScrollInfo(Self.Handle, SB_VERT, SIOld);
  SINew := SIOld;

  if IsLoaded then
  begin
    SINew.nMin := 1;
    SINew.nPage := OperationCount;
    SINew.nMax := FEntryData.Count + OperationCount - 1;
    SINew.nPos := FTopRecord + FActiveRecord + 1;
  end
  else
  begin
    SINew.nMin := 0;
    SINew.nPage := 0;
    SINew.nMax := 4;
    if FTopRecord + FActiveRecord = 0 then
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
end;

procedure TgdEntryGrid.SetIsLoaded(const Value: Boolean);
begin
  if FIsLoaded <> Value then
  begin
    FIsLoaded := Value;
    if FIsLoaded then UpdateScrollBar;
  end;
end;

procedure TgdEntryGrid.MoveBy(const Direction: TenMoveDirection; Step: Integer);
var
  OldActive, OldEntry: Integer;
  Shift: TShiftState;
begin
  Shift := GetShiftState;

  if (FMovementKind = mkEntry) and (ssCtrl in Shift) and (egoEntries in FOptions) then
  begin
    case Direction of
      mdUp:
      begin
        if FActiveEntry > 0 then
        begin
          OldEntry := FActiveEntry;
          Dec(FActiveEntry);

          UpdateObject(diEntry, FActiveRecord, OldEntry);
          UpdateObject(diEntry, FActiveRecord, FActiveEntry);
          Exit;
        end;
      end;
      mdDown:
      begin
        if FActiveEntry < Operation[FActiveRecord].FEntryList.Count - 1 then
        begin
          OldEntry := FActiveEntry;
          Inc(FActiveEntry);

          UpdateObject(diEntry, FActiveRecord, OldEntry);
          UpdateObject(diEntry, FActiveRecord, FActiveEntry);
          Exit;
        end;
      end;
    end;
  end;

  //
  //  Проверяем возможность перемещения

  if not CanMove(Direction, Step) then Exit;

  //
  //  Если перемещение возможно...

  case Direction of
    mdUp:
    begin
      if FActiveRecord > 0 then
      begin
        OldActive := FActiveRecord;
        OldEntry := FActiveEntry;

        if (ssCtrl in Shift) and (egoEntries in FOptions) then
        begin
          Dec(FActiveRecord);
          FActiveEntry := Operation[FActiveRecord].FEntryList.Count - 1;

          if FMovementKind = mkEntry then
          begin
            UpdateObject(diEntry, OldActive, OldEntry);
            UpdateObject(diEntry, FActiveRecord, FActiveEntry);
          end else begin
            FMovementKind := mkEntry;
            UpdateObject(diDescription, OldActive, 0);
            UpdateObject(diEntry, FActiveRecord, FActiveEntry);
          end;
        end else begin
          if FMovementKind = mkEntry then
          begin
            FMovementKind := mkDescription;
            UpdateObject(diEntry, OldActive, OldEntry);
            UpdateObject(diDescription, FActiveRecord, 0);
          end else begin
            Dec(FActiveRecord);
            FActiveEntry := Operation[FActiveRecord].FEntryList.Count - 1;

            UpdateObject(diDescription, OldActive, 0);
            UpdateObject(diDescription, FActiveRecord, 0);
          end;
        end;
      end else begin
        Dec(FTopRecord);
        UpdateGrid;
      end;
    end;
    mdPageUp:
    begin
      FActiveRecord := 0;
      Dec(FTopRecord, Step);

      if (ssCtrl in Shift) and (egoEntries in FOptions) then
        FMovementKind := mkEntry else
        FMovementKind := mkDescription;

      UpdateGrid;
    end;
    mdFirst:
    begin
      FActiveRecord := 0;
      FTopRecord := 0;
      FMovementKind := mkDescription;

      UpdateGrid;
    end;
    mdDown:
    begin
      OldActive := FActiveRecord;
      OldEntry := FActiveEntry;
      FActiveEntry := 0;

      if (ssCtrl in Shift) and (egoEntries in FOptions) then
      begin
        if FMovementKind = mkEntry then
        begin
          Inc(FActiveRecord);

          if FActiveRecord < OperationCount then
          begin
            UpdateObject(diEntry, OldActive, OldEntry);
            UpdateObject(diEntry, FActiveRecord, FActiveEntry);
          end else
            UpdateGrid;
        end else

        begin
          FMovementKind := mkEntry;
          UpdateObject(diDescription, OldActive, 0);
          UpdateObject(diEntry, FActiveRecord, FActiveEntry);
        end;
      end else

      begin
        Inc(FActiveRecord);

        if FActiveRecord < OperationCount then
        begin
          if FMovementKind = mkEntry then
          begin
            FMovementKind := mkDescription;
            UpdateObject(diEntry, OldActive, OldEntry);
            UpdateObject(diDescription, FActiveRecord, 0);
          end else

          begin
            UpdateObject(diDescription, OldActive, 0);
            UpdateObject(diDescription, FActiveRecord, 0);
          end;
        end else
          UpdateGrid;
      end;
    end;
    mdPageDown:
    begin
      Inc(FTopRecord, Step);
      FActiveRecord := CountVisible(FTopRecord) - 1;

      if (ssCtrl in Shift) and (egoEntries in FOptions) then
        FMovementKind := mkEntry else
        FMovementKind := mkDescription;

      UpdateGrid;
    end;
    mdLast:
    begin
      FActiveRecord := 0;
      FTopRecord := FEntryData.Count - 1;
      FMovementKind := mkDescription;

      UpdateGrid;
    end;
    mdRecord:
    begin
      if (Step >= FTopRecord) and (Step <= FTopRecord + OperationCount) then
        FActiveRecord := Step - FTopRecord
      else begin
        FTopRecord := Step;
        FActiveRecord := 0;
      end;

      if (ssCtrl in Shift) and (egoEntries in FOptions) then
        FMovementKind := mkEntry else
        FMovementKind := mkDescription;

      UpdateGrid;
    end;
  end;

  if FActiveEntry > Operation[FActiveRecord].FEntryList.Count - 1 then
    FActiveEntry := Operation[FActiveRecord].FEntryList.Count - 1;

  UpdateScrollBar;
end;

function TgdEntryGrid.CanMove(const Direction: TenMoveDirection; var Step: Integer): Boolean;
begin
  case Direction of
    mdUp, mdFirst:
    begin
      Result := (FActiveRecord > 0) or (FTopRecord > 0);
    end;
    mdPageUp:
    begin
      Result := (FActiveRecord > 0) or (FTopRecord > 0);

      if Step > FTopRecord then
        Step := FTopRecord;
    end;
    mdDown:
    begin
      Result :=
        (FTopRecord + FActiveRecord < FEntryData.Count - 1)
          or
        (FEntryData[FTopRecord + FActiveRecord + 1] <> nil);
    end;
    mdPageDown:
    begin
      Step := OperationCount;
      Result := FEntryData.Count - 1 >= FTopRecord + FActiveRecord + Step;

      if not Result then
      begin
        if not FIsLoaded and (FEntryData[FTopRecord + FActiveRecord + Step] = nil) then
        begin
          Step := FEntryData.Count - (FTopRecord + FActiveRecord + 1);
          Result := True;
        end else

        if FIsLoaded and (FEntryData.Count - 1 > FTopRecord + FActiveRecord) then
        begin
          Step := FEntryData.Count - (FTopRecord + FActiveRecord + 1);
          Result := True;
        end;

      end else
    end;
    mdLast:
    begin
      if not FIsLoaded then
        while FEntryData[FEntryData.Count] <> nil do ;

      Step := FEntryData.Count - FTopRecord + FActiveRecord + Step - 1;
      Result := Step <> 0;
    end;
    mdRecord:
    begin
      Result := True;
    end;
    else
      Result := False;
  end;
end;

procedure TgdEntryGrid.UpdateObject(Info: TenDrawInfo; const Index,
  SubIndex: Integer);
var
  R: TRect;
  Obj: TgdBase;
begin
  CalcDrawInfo(Info, Index, SubIndex, R);
  GetObject(Info, Index, SubIndex, Obj);
  if FUpdateLock = 0 then Obj.Paint(R.Top);
end;

procedure TgdEntryGrid.GetObject(Info: TenDrawInfo; const Index,
  SubIndex: Integer; out Obj: TgdBase);
begin
  case Info of
    diColumns:
      Obj := FColumns;

    diColumn:
      Obj := FColumns[Index];

    diOperationList:
      Obj := FList;

    diOperation:
      Obj := FList[Index];

    diDescription:
      Obj := FList[Index].FDescription;

    diEntryList:
      Obj := FList[Index].FEntryList;

    diEntry:
      Obj := FList[Index].FEntryList[SubIndex];

    diAnalizeBox:
      Obj := FList[Index].FEntryList[SubIndex].FAnalitics;
  end;
end;

function TgdEntryGrid.CountVisible(const StartIndex: Integer): Integer;
var
  TempList: TgdOperationList;
  Rest: Integer;
  CurrOperation: TgdOperation;
  OldTopRecord: Integer;
begin
  TempList := TgdOperationList.Create(Self);
  OldTopRecord := FTopRecord;

  try
    FTopRecord := StartIndex;
    Rest := ClientHeight - FColumns.Height;

    while True do
    begin
      CurrOperation := TgdOperation.Create(TempList);
      TempList.FItems.Add(CurrOperation);

      if CurrOperation.IsValid then
      begin
        CurrOperation.FEntryList.UpdateEntryList;

        if CurrOperation.Height < Rest then
          Dec(Rest, CurrOperation.Height)
        else begin
          TempList.FItems.Remove(CurrOperation);
          Break;
        end;
      end else begin
        TempList.FItems.Remove(CurrOperation);
        Break;
      end;
    end;

    Result := TempList.Count;
  finally
    TempList.Free;
    FTopRecord := OldTopRecord;
  end;
end;

function TgdEntryGrid.GetAnalyticSource(AnIndex: Integer): TgdAnalyticSource;
begin
  Result := FAnalyticSources[AnIndex] as TgdAnalyticSource;
end;

function TgdEntryGrid.GetAnalyticSourceCount: Integer;
begin
  Result := FAnalyticSources.Count;
end;

function TgdEntryGrid.GetAnalyticSourceName(AName: String): TgdAnalyticSource;
var
  I: Integer;
begin
  for I := 0 to AnalyticSourceCount - 1 do
    if AnsiCompareText(
      (FAnalyticSources[I] as TgdAnalyticSource).FFieldName,
      AName) = 0
    then begin
      Result := FAnalyticSources[I] as TgdAnalyticSource;
      Exit;
    end;

  Result := nil;
end;

procedure TgdEntryGrid.SetOptions(const Value: TenEntryGridOptions);
begin
  if FOptions <> Value then
  begin
    FOptions := Value;

    if not (egoEntries in FOptions) then
      FMovementKind := mkDescription;

    UpdateGrid;
  end;
end;

procedure TgdEntryGrid.UpdateAnalyticsData(Analytics: TStringList);
var
  I: Integer;
  Source: TgdAnalyticSource;
  N: String;
begin
  for I := 0 to Analytics.Count - 1 do
  begin
    N := Analytics.Names[I];
    Source := AnalyticSourceName[N];

    if not Assigned(Source) then
    begin
      Source := TgdAnalyticSource.Create(Self);
      Source.FieldName := N;
      FAnalyticSources.Add(Source);
    end;

    Analytics.Values[N] := Source.Value[Analytics.Values[N]];
  end;
end;

function TgdEntryGrid.GetEntryKey: Integer;
begin
  if Active and Assigned(FEntryData[GlobalActiveRecord]) then
    Result := FEntryData[GlobalActiveRecord]^.EntryKey
  else
    Result := -1;
end;

function TgdEntryGrid.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TgdEntryGrid.SetDataSource(const Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

procedure TgdEntryGrid.SetParams(const Value: TenParams);
begin
  if FParams <> Value then
  begin
    FParams := Value;

    if
      ([pTrTypeLB, pTrTypeRB] * FParams = [pTrTypeLB, pTrTypeRB]) and
      (pTrTypeKey in FParams)
    then
      Exclude(FParams, pTrTypeKey);

    if not (csDesigning in ComponentState) then
    begin
      if Active then
      begin
        Active := False;
        Active := True;
      end;
    end;
  end;
end;

function TgdEntryGrid.GetParam(AParam: TenParam): String;
begin
  if (AParam in FParams) and not Active then
  begin
    if FEntrySQL.Prepared then
      Result := FEntrySQL.Params.ByName(ParamNames[AParam]).AsString
    else
      Result := '';
  end else
    Result := '';
end;

procedure TgdEntryGrid.SetParam(AParam: TenParam; const Value: String);
var
  OldActive: Boolean;
  P: TStringList;
  I: Integer;

  function ParamExists(const AName: String): Boolean;
  var
    Z: Integer;
  begin
    for Z := 0 to FEntrySQL.Params.Count - 1 do
      if FEntrySQL.Params[Z].Name = AName then
      begin
        Result := True;
        Exit;
      end;

    Result := False;
  end;

begin
  BeginUpdate;
  try
    OldActive := Active;
    if not (csDesigning in ComponentState) and Active then Active := False;

    //
    //  Если запрос не подготовлен - готовим его

    if not FEntrySQL.Prepared then
      PrepareEntrySQL
    else

    //
    //  Если появился новый параметр в готовом запросе

    if not ParamExists(ParamNames[AParam]) and (AParam in FParams) then
    begin
      P := TStringList.Create;
      try
        for I := 0 to FEntrySQL.Params.Count - 1 do
          P.Add(Format('%s=%s',
            [FEntrySQL.Params[I].Name, FEntrySQL.Params[I].AsString]));

        FEntrySQL.FreeHandle;
        PrepareEntrySQL;

        for I := 0 to P.Count - 1 do
          if ParamExists(P.Names[I]) then
            FEntrySQL.Params.ByName(P.Names[I]).AsString := P.Values[P.Names[I]];

      finally
        P.Free;
      end;
    end;

    if Value > '' then
      FEntrySQL.Params.ByName(ParamNames[AParam]).AsString := Value
    else
      FEntrySQL.Params.ByName(ParamNames[AParam]).Clear;

    if not (csDesigning in ComponentState) then
      Active := OldActive;
  finally
    EndUpdate;
  end;
end;

procedure TgdEntryGrid.DoEnter;
begin
  inherited;

  if Active and (FEntryData.Count > 0) then
  begin
    if FMovementKind = mkDescription then
      UpdateObject(diDescription, FActiveRecord, 0)
    else
      UpdateObject(diEntry, FActiveRecord, FActiveEntry);
  end;
end;

procedure TgdEntryGrid.DoExit;
begin
  inherited;

  if Active and (FEntryData.Count > 0) then
  begin
    if FMovementKind = mkDescription then
      UpdateObject(diDescription, FActiveRecord, 0)
    else
      UpdateObject(diEntry, FActiveRecord, FActiveEntry);
  end;
end;

procedure TgdEntryGrid.DoBeforeDisconnect(Sender: TObject);
begin
  if not FSkipIBEvent and Active and not (csDesigning in ComponentState) then
    Active := False;
end;

procedure TgdEntryGrid.SetEntryAmount(const Value: TenEntryAmount);
begin
  if FEntryAmount <> Value then
  begin
    FEntryAmount := Value;
    UpdateGrid;
  end;
end;

procedure TgdEntryGrid.WMSize(var Message: TWMSize);
begin
  inherited;
  
  if HandleAllocated then
  begin
    FColumns.CountColumnsSize;
    UpdateGrid;
  end;
end;

procedure TgdEntryGrid.DoFontChanged(Sender: TObject);
begin
  if FUpdateLock = 0 then Invalidate;
  ParentFont := False;
end;

function TgdEntryGrid.GetDocumentKey: Integer;
begin
  if Active and Assigned(FEntryData[GlobalActiveRecord]) then
    Result := FEntryData[GlobalActiveRecord]^.DocKey
  else
    Result := -1;
end;

function TgdEntryGrid.GetTrTypeKey: Integer;
begin
  if Active and Assigned(FEntryData[GlobalActiveRecord]) then
    Result := FEntryData[GlobalActiveRecord]^.TrTypeKey
  else
    Result := -1;
end;

function TgdEntryGrid.GetID: Integer;
begin
  if FMovementKind = mkEntry then
  begin
    if Active and Assigned(FEntryData[GlobalActiveRecord]) then
      Result := FEntryData[GlobalActiveRecord]^.EntryData[FActiveEntry]^.ID
    else
      Result := -1;
  end else
    Result := -1;
end;

function TgdEntryGrid.GetDocDate: TDateTime;
begin
  if Active and Assigned(FEntryData[GlobalActiveRecord]) then
    Result := FEntryData[GlobalActiveRecord]^.DocDate
  else
    Result := -1;
end;

function TgdEntryGrid.GetSelected(Entry: PEntryData): Boolean;
begin
  Result := FSelectedList.IndexOf(Entry) >= 0;
end;

procedure TgdEntryGrid.SetSelected(Entry: PEntryData;
  const Value: Boolean);
var
  D, C: Double;
  I: Integer;
begin
  if not Value then
    FSelectedList.Remove(Entry)
  else
    FSelectedList.Add(Entry);

  D := 0;
  C := 0;

  if Assigned(FTotalEvent) then
  begin
    for I := 0 to FSelectedList.Count - 1 do
      if FSelectedList[I]^.AccountType = atDebit then
        D := D + FSelectedList[I]^.Debit[FEntryAmount] else
      if FSelectedList[I]^.AccountType = atCredit then
        C := C + FSelectedList[I]^.Credit[FEntryAmount];

    FTotalEvent(Self, D, C, FSelectedList.Count);    
  end;
end;

function TgdEntryGrid.GetShiftState: TShiftState;
var
  State: TKeyboardState;
begin
  GetKeyboardState(State);
  Result := KeyboardStateToShiftState(State);
end;

procedure TgdEntryGrid.ClearSelectedList;
var
  I, K: Integer;
  Op: TgdOperation;
  E: PEntryData;
begin
  for I := 0 to OperationCount - 1 do
  begin
    Op := Operation[I];

    for K := 0 to Op.FEntryList.Count - 1 do
    begin
      E := FEntryData[Op.GlobalIndex]^.EntryData[K];

      if Selected[E] then
      begin
        Selected[E] := False;
        UpdateObject(diEntry, I, K);
      end;
    end;
  end;

  FSelectedList.Clear;
end;

procedure TgdEntryGrid.Close;
begin
  Active := False;
end;

procedure TgdEntryGrid.Open;
begin
  Active := True;
end;

procedure TgdEntryGrid.FreeSQLHandle;
begin
  Active := False;
  FEntrySQL.SQL.Text := '';
end;

{ TgdRecordDataList }

function TgdRecordDataList.Add(RecordData: PRecordData): Integer;
begin
  Result := inherited Add(RecordData);
end;

constructor TgdRecordDataList.Create(AnOwner: TgdEntryGrid);
begin
  FGrid := AnOwner;
end;

function TgdRecordDataList.GetItem(Index: Integer): PRecordData;
var
  D: PRecordData;
begin
  //
  // Если элемент уже загружен

  if Index < Count then
  begin
    Result := inherited Items[Index];
  end else

  //
  //  Если элемент новый и его нужно загрузить

  begin
    if not FGrid.IsLoaded then
      while Index > Count - 1 do
      begin
        D := GetNext;

        if Assigned(D) then
          Add(D)
        else
          Break;
      end;

    if Index < Count then
      Result := inherited Items[Index]
    else
      Result := nil;

    if not Assigned(Result) and FGrid.Active then
      FGrid.IsLoaded := True;
  end;
end;

function TgdRecordDataList.GetNext: PRecordData;
var
  Entry: PEntryData;
  CurrEntryKey: Integer;
  I: Integer;
begin
  if not FGrid.Active then
  begin
    Result := nil;
    Exit;
  end;

  with FGrid.FEntrySQL do
  begin
    //
    //  Получаем первую запись и проверяем наличие записи

    if not Open then
    begin
      Prepare;
      ExecQuery;

      if RecordCount = 0 then
      begin
        Result := nil;
        Exit;
      end;
    end else begin
      if EOF then
      begin
        Result := nil;
        Exit;
      end;
    end;

    //
    //  Производим считывание всех записей данной прводки

    GetMem(Result, SizeOf(TRecordData));
    Result^.EntryData := TgdEntryDataList.Create(True);
    CurrEntryKey := -1;

    with Result^ do
    try
      while not EOF do
      begin
        //
        //  Общие данные проводки

        if EntryData.Count = 0 then
        begin
          DocDate := FieldByName('DOCDATE').AsDateTime;
          DocNumber := FieldByName('DOCNUMBER').AsString;
          DocName := FieldByName('DOCNAME').AsString;
          TrName := FieldByName('TRNAME').AsString;
          EntryKey := FieldByName('ENTRYKEY').AsInteger;
          DocKey := FieldByName('DOCUMENTKEY').AsInteger;
          TrTypeKey := FieldByName('TRTYPEKEY').AsInteger;

          CurrEntryKey := EntryKey;
        end else
          if CurrEntryKey <> FieldByName('ENTRYKEY').AsInteger then
            Break;

        //
        //  Считываем все данные по каждой записи

        GetMem(Entry, Sizeof(TEntryData));
        with Entry^ do
        try
          ID := FieldByName('ID').AsInteger;
          AccountCode := FieldByName('ACCOUNTCODE').AsString;
          AccountName := FieldByName('ACCOUNTNAME').AsString;
          Currency := FieldByName('CURRCODE').AsString;

          AnalyticsLoaded := False;
          Analytics := nil;

          for I := 0 to FGrid.FAttrList.Count - 1 do
            if not FieldByName(FGrid.FAttrList[I]).IsNull then
            begin
              if not Assigned(Analytics) then
                Analytics := TStringList.Create;

              Analytics.Add(
                FGrid.FAttrList[I] + '=' +
                FieldByName(FGrid.FAttrList[I]).AsString
              );
            end;

          if FieldByName('ACCOUNTTYPE').AsString = 'D' then
          begin
            AccountType := atDebit;
            Debit[eaAmount] := FieldByName('DEBITSUMNCU').AsFloat;
            Debit[eaCurrency] := FieldByName('DEBITSUMCURR').AsFloat;
            Debit[eaEquivalent] := FieldByName('DEBITSUMEQ').AsFloat;
          end else

          if FieldByName('ACCOUNTTYPE').AsString = 'K' then
          begin
            AccountType := atCredit;
            Credit[eaAmount] := FieldByName('CREDITSUMNCU').AsFloat;
            Credit[eaCurrency] := FieldByName('CREDITSUMCURR').AsFloat;
            Credit[eaEquivalent] := FieldByName('CREDITSUMEQ').AsFloat;
          end else
            raise EgdEntryGridError.Create('Invalid account type!');

        except
          FreeMem(Entry, Sizeof(TEntryData));
          raise;
        end;

        EntryData.Add(Entry);
        Next;
      end;
    except
      EntryData.Free;
      FreeMem(Result, SizeOf(TRecordData));
      raise;
    end;
  end;

  //FGrid.UpdateScrollBar;
end;

function TgdRecordDataList.IndexOf(RecordData: PRecordData): Integer;
begin
  Result := inherited IndexOf(RecordData);
end;

procedure TgdRecordDataList.Insert(Index: Integer; RecordData: PRecordData);
begin
  inherited Insert(Index, RecordData);
end;

procedure TgdRecordDataList.Notify(Ptr: Pointer;
  Action: TListNotification);
begin
  if Action = lnDeleted then
  begin
    PRecordData(Ptr)^.EntryData.Free;
    FreeMem(Ptr, SizeOf(TRecordData));
  end;
end;

function TgdRecordDataList.Remove(RecordData: PRecordData): Integer;
begin
  Result := inherited Remove(RecordData);
end;

procedure TgdRecordDataList.SetItem(Index: Integer; RecordData: PRecordData);
begin
  inherited Items[Index] := RecordData;
end;

{ TgdColumns }

{
  Считает размеры колонок в зависимости от размера
  окна грида.
}

procedure TgdColumns.CountColumnsSize;
var
  I: Integer;
  Percent: Integer;
begin
  //
  //  Считаем размеры колонок первой строки

  Percent := 0;
  for I := 0 to ColumnCount - 1 do
  with Column[I] do
  begin
    Inc(Percent, Column[I].FPercent);

    if I = 0 then
    begin
      FLeft := 0;
      FWidth := Round(FGrid.ClientWidth * Percent / 100)
    end else begin
      FLeft := Column[I - 1].FLeft + Column[I - 1].FWidth;
      FWidth := Round(FGrid.ClientWidth * Percent / 100) - FLeft;
    end;
  end;

  //
  //  Уменьшаем размеры колонок на 1 для линии границы

  for I := 0 to ColumnCount - 1 do
    Dec(Column[I].FWidth);
end;

constructor TgdColumns.Create(AnOwner: TgdEntryGrid);
begin
  FGrid := AnOwner;
  FColumns := TObjectList.Create;
  InitColumns;
end;

destructor TgdColumns.Destroy;
begin
  FColumns.Free;

  inherited;
end;

function TgdColumns.RowHeight: Integer;
begin
  with FGrid do
  begin
    if Canvas.Handle <> 0 then
    begin
      TempFont.Assign(Grid.Canvas.Font);
      try
        Canvas.Font := TitleFont;
        Result := Canvas.TextHeight('Wg');
      finally
        Grid.Canvas.Font := TempFont;
      end;
    end else
      Result := 0;
  end;
end;

function TgdColumns.GetHieght: Integer;
begin
  Result := Round(RowHeight * 1.2);
end;

procedure TgdColumns.InitColumns;
var
  Column: TgdColumn;
begin
  FColumns.Clear;

  if egoEntries in FGrid.FOptions then
  begin
    Column := TgdColumn.Create(Self);
    Column.FCaption := 'Хозяйственная операция';
    Column.FName := 'TRNAME';
    Column.FPercent := 50;
    Column.FWidth := 0;
    Column.FLeft := 0;
    Column.FCaptionAlignment := taCenter;
    Column.FAlignment := taLeftJustify;
    FColumns.Add(Column);

    Column := TgdColumn.Create(Self);
    Column.FCaption := 'Счет';
    Column.FName := 'ACCOUNTCODE';
    Column.FPercent := 10;
    Column.FWidth := 0;
    Column.FLeft := 0;
    Column.FCaptionAlignment := taRightJustify;
    Column.FAlignment := taRightJustify;
    FColumns.Add(Column);

    Column := TgdColumn.Create(Self);
    Column.FCaption := 'Дебет';
    Column.FName := 'DEBIT';
    Column.FPercent := 20;
    Column.FWidth := 0;
    Column.FLeft := 0;
    Column.FCaptionAlignment := taRightJustify;
    Column.FAlignment := taRightJustify;
    FColumns.Add(Column);

    Column := TgdColumn.Create(Self);
    Column.FCaption := 'Кредит';
    Column.FName := 'CREDIT';
    Column.FPercent := 20;
    Column.FWidth := 0;
    Column.FLeft := 0;
    Column.FCaptionAlignment := taRightJustify;
    Column.FAlignment := taRightJustify;
    FColumns.Add(Column);
  end else begin
    Column := TgdColumn.Create(Self);
    Column.FCaption := 'Хозяйственная операция';
    Column.FName := 'TRNAME';
    Column.FPercent := 100;
    Column.FWidth := 0;
    Column.FLeft := 0;
    Column.FCaptionAlignment := taCenter;
    Column.FAlignment := taLeftJustify;
    FColumns.Add(Column);
  end;
end;

procedure TgdColumns.Paint(const Y: Integer);
var
  I: Integer;
  R: TRect;
begin
  with Grid.Canvas do
  begin
    Brush.Color := Grid.FTitleColor;
    Font := Grid.FTitleFont;

    R.Top := Y;
    R.Bottom := Y + Height;

    for I := 0 to ColumnCount - 1 do
    begin
      R.Left := Column[I].FLeft;
      R.Right := Column[I].FLeft + Column[I].FWidth;

      WriteText(Grid.Canvas, R, 2, (Height - RowHeight) div 2,
        PChar(Column[I].FCaption), Column[I].FCaptionAlignment);

      if I > 0 then
      begin
        MoveTo(Column[I].FLeft - 1, R.Top);
        LineTo(Column[I].FLeft - 1, R.Bottom);
      end;
    end;

    Pen.Color := clBlack;
    MoveTo(Grid.ClientRect.Left, R.Bottom);
    LineTo(Grid.ClientRect.Right, R.Bottom);
  end;
end;

{ TgdColumn }

constructor TgdColumn.Create(AnOwner: TgdColumns);
begin
  FColumns := AnOwner;

  FCaption := '';
  FName := '';
  FLeft := 0;
  FWidth := 0;
  FPercent := 0;

  FCaptionAlignment := taLeftJustify;
  FAlignment := taLeftJustify;
end;

destructor TgdColumn.Destroy;
begin
  inherited;
end;

function TgdColumn.GetGrid: TgdEntryGrid;
begin
  Result := FColumns.FGrid;
end;

function TgdColumn.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TgdColumn.Paint(const Y: Integer);
begin
  inherited;

end;

{ TgdOperationList }

constructor TgdOperationList.Create(AnOwner: TgdEntryGrid);
begin
  FGrid := AnOwner;
  FItems := TObjectList.Create;
end;

destructor TgdOperationList.Destroy;
begin
  FItems.Free;

  inherited;
end;

function TgdOperationList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TgdOperationList.GetGrid: TgdEntryGrid;
begin
  Result := FGrid;
end;

function TgdOperationList.GetHeight: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    Inc(Result, Item[I].Height);
end;

function TgdOperationList.GetItem(Index: Integer): TgdOperation;
begin
  Result := FItems[Index] as TgdOperation;
end;

function TgdOperationList.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TgdOperationList.Paint(const Y: Integer);
var
  I: Integer;
  CurrPos: Integer;
begin
  Grid.Canvas.Brush.Color := Grid.FDescriptionColor;

  CurrPos := Y;

  for I := 0 to Count - 1 do
  begin
    Item[I].Paint(CurrPos);
    Inc(CurrPos, Item[I].Height);
  end;

  Grid.Canvas.Brush.Color := Grid.FDescriptionColor;
  Grid.Canvas.FillRect(Rect(
    Grid.ClientRect.Left, CurrPos,
    Grid.ClientRect.Right, Grid.ClientRect.Bottom)
  );
end;

{ TgdOperation }

function TgdOperation.CountCreditTotal: Double;
var
  I: Integer;
begin
  Result := 0;

  with Grid.FEntryData[GlobalIndex]^ do
    for I := 0 to EntryData.Count - 1 do
      if EntryData[I]^.AccountType = atCredit then
        Result := Result + EntryData[I]^.Credit[Grid.FEntryAmount];
end;

function TgdOperation.CountDebitTotal: Double;
var
  I: Integer;
begin
  Result := 0;

  with Grid.FEntryData[GlobalIndex]^ do
    for I := 0 to EntryData.Count - 1 do
      if EntryData[I]^.AccountType = atDebit then
        Result := Result + EntryData[I]^.Debit[Grid.FEntryAmount];
end;

constructor TgdOperation.Create(AnOwner: TgdOperationList);
begin
  FList := AnOwner;

  FDescription := TgdDescription.Create(Self);
  FEntryList := TgdEntryList.Create(Self);
end;

destructor TgdOperation.Destroy;
begin
  FEntryList.Free;
  FDescription.Free;

  inherited;
end;

function TgdOperation.GetEntryData: TgdRecordDataList;
begin
  Result := FList.FGrid.FEntryData;
end;

function TgdOperation.GetGlobalIndex: Integer;
begin
  Result := ItemIndex + Grid.FTopRecord;
end;

function TgdOperation.GetGrid: TgdEntryGrid;
begin
  Result := FList.FGrid;
end;

function TgdOperation.GetHeight: Integer;
begin
  Result := FDescription.Height + 1;

  if egoEntries in Grid.FOptions then
    Inc(Result, FEntryList.Height + 1);

  if [egoTotals, egoEntries] * Grid.FOptions = [egoTotals, egoEntries] then
    Inc(Result, TotalRowHeight);
end;

function TgdOperation.GetIsValid: Boolean;
begin
  Result := Grid.FEntryData[GlobalIndex] <> nil;
end;

function TgdOperation.GetItemIndex: Integer;
begin
  Result := FList.FItems.IndexOf(Self);
end;

function TgdOperation.MouseDown(X, Y: Integer): Boolean;
var
  I: Integer;
begin
  Result := FDescription.MouseDown(X, Y);

  if not Result then
    for I := 0 to FEntryList.Count - 1 do
    begin
      Result := FEntryList[I].MouseDown(X, Y);
      if Result then Exit;
    end;
end;

procedure TgdOperation.Paint(const Y: Integer);
var
  CurrPos: Integer;
  R: TRect;
begin
  CurrPos := Y;

  //
  //  Рисуем описание хозяйственной операции

  FDescription.Paint(CurrPos);
  Inc(CurrPos, FDescription.Height);

  //
  //  Рисуем линию разделителя

  with Grid.Canvas do
  begin
    Pen.Color := clBlack;
    MoveTo(Grid.ClientRect.Left, CurrPos);
    LineTo(Grid.ClientRect.Right, CurrPos);
  end;

  //
  //  Рисуем список записей хозяйственной операции

  Inc(CurrPos, 1);
  FEntryList.Paint(CurrPos);
  Inc(CurrPos, FEntryList.Height);

  //
  //  Рисуем итоговую строку

  if [egoTotals, egoEntries] * Grid.FOptions = [egoTotals, egoEntries] then
  begin
    R.Top := CurrPos;
    R.Bottom := CurrPos + TotalRowHeight;

    with Grid.FColumns.ColumnByName['ACCOUNTCODE'] do
    begin
      Grid.Canvas.Brush.Color := Grid.FEntryColor;

      R.Left := Grid.ClientRect.Left;
      R.Right := FLeft;
      Grid.Canvas.FillRect(R);

      Grid.Canvas.Brush.Color := Grid.FTotalColor;
      Grid.Canvas.Font := Grid.FTotalFont;

      R.Left := FLeft {Grid.ClientRect.Left};
      R.Right := FLeft + FWidth;

      WriteText(Grid.Canvas, R, 2, 0, 'Итого:', taRightJustify);
    end;

    with Grid.FColumns.ColumnByName['DEBIT'] do
    begin
      R.Left := FLeft - 1;
      R.Right := FLeft + FWidth;

      WriteText(Grid.Canvas, R, 2, 0, CurrToStr(CountDebitTotal), FAlignment);
    end;

    with Grid.FColumns.ColumnByName['CREDIT'] do
    begin
      R.Left := FLeft - 1;
      R.Right := FLeft + FWidth;

      WriteText(Grid.Canvas, R, 2, 0, CurrToStr(CountCreditTotal), FAlignment);
    end;

    Inc(CurrPos, TotalRowHeight);
  end;

  Grid.Canvas.Pen.Color := clBlack;
  Grid.Canvas.MoveTo(Grid.ClientRect.Left, CurrPos);
  Grid.Canvas.LineTo(Grid.ClientRect.Right, CurrPos);
end;

function TgdOperation.TotalRowHeight: Integer;
begin
  with Grid do
  begin
    if Canvas.Handle <> 0 then
    begin
      TempFont.Assign(Grid.Canvas.Font);
      try
        Canvas.Font := FTotalFont;
        Result := Canvas.TextHeight('Wg');
      finally
        Grid.Canvas.Font := TempFont;
      end;
    end else
      Result := 0;
  end;
end;

{ TgdDescription }

constructor TgdDescription.Create(AnOwner: TgdOperation);
begin
  FOperation := AnOwner;
end;

destructor TgdDescription.Destroy;
begin
  inherited;
end;

function TgdDescription.GetGrid: TgdEntryGrid;
begin
  Result := FOperation.FList.FGrid;
end;

function TgdDescription.GetHeight: Integer;
var
  R: TRect;
begin
  R.Left := Grid.ClientRect.Left + 80;
  R.Right := Grid.ClientRect.Right - 10;
  R.Top := 0;

  TempFont.Assign(Grid.Canvas.Font);
  try
    Grid.Canvas.Font := Grid.FDescriptionFont;
    DrawText(Grid.Canvas.Handle, PChar(GetDescriptionText), -1, R,
      DT_LEFT or DT_WORDBREAK or DT_EXPANDTABS or DT_NOPREFIX or DT_CALCRECT);
  finally
    Grid.Canvas.Font := TempFont;
  end;

  Result := (R.Bottom - R.Top) + 2;
end;

procedure TgdDescription.Paint(const Y: Integer);
var
  R: TRect;
  Text: String;
begin
  if (Grid.FMovementKind = mkDescription) and IsActive then
  begin
    Grid.Canvas.Brush.Color := Grid.FocusedColor;
    Grid.Canvas.Font := Grid.FSelectedFont;
  end else
  
  begin
    Grid.Canvas.Brush.Color := Grid.FDescriptionColor;
    Grid.Canvas.Font := Grid.FDescriptionFont;
  end;

  R.Top := Y;
  R.Bottom := Y + Height;

  with Grid.FEntryData[FOperation.GlobalIndex]^ do
  begin
    R.Left := Grid.ClientRect.Left;
    R.Right := Grid.ClientRect.Right;

    Text := DateToStr(DocDate);
    WriteText(Grid.Canvas, R, 10, 1, Text, taLeftJustify, True);

    R.Left := Grid.ClientRect.Left + 80;
    R.Right := Grid.ClientRect.Right;

    Text := GetDescriptionText;
    WriteText(Grid.Canvas, R, 10, 1, Text, taLeftJustify, True);
  end;

  if (Grid.FMovementKind = mkDescription) and IsActive and Grid.Focused then
    Windows.DrawFocusRect(Grid.Canvas.Handle, Rect(
      Grid.ClientRect.Left,
      Y + 1,
      Grid.ClientRect.Right,
      Y + Height - 1)
    );
end;

function TgdDescription.GetDescriptionText: String;
begin
  with Grid.FEntryData[FOperation.GlobalIndex]^ do
    Result := DocName + ' ' + '№ ' + DocNumber + ' ' + TrName;
end;

function TgdDescription.MouseDown(X, Y: Integer): Boolean;
var
  R: TRect;
  OldActive, OldEntry: Integer;
  OldMovement: TenMovementKind;
begin
  Grid.CalcDrawInfo(diDescription, FOperation.ItemIndex, 0, R);

  if PointInRect(X, Y, R) then
  begin
    Result := True;
    if not (ssShift in Grid.GetShiftState) then Grid.ClearSelectedList;
    if IsActive and (Grid.FMovementKind <> mkEntry) then Exit;

    OldActive := Grid.FActiveRecord;
    OldEntry := Grid.FActiveEntry;
    Grid.FActiveRecord := FOperation.ItemIndex;
    Grid.FActiveEntry := 0;
    OldMovement := Grid.FMovementKind;
    Grid.FMovementKind := mkDescription;

    if OldMovement = mkEntry then
      Grid.UpdateObject(diEntry, OldActive, OldEntry)
    else
      Grid.UpdateObject(diDescription, OldActive, 0);

    Grid.UpdateObject(diDescription, Grid.FActiveRecord, 0);
    Grid.UpdateScrollBar;
  end else
    Result := False;
end;

function TgdDescription.GetIsActive: Boolean;
begin
  Result := (Grid.GlobalActiveRecord = FOperation.GlobalIndex);
end;

{ TgdEntryList }

constructor TgdEntryList.Create(AnOwner: TgdOperation);
begin
  FOperation := AnOwner;
  FItems := TObjectList.Create;
end;

destructor TgdEntryList.Destroy;
begin
  FItems.Free;
  
  inherited;
end;

function TgdEntryList.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TgdEntryList.GetGrid: TgdEntryGrid;
begin
  Result := FOperation.FList.FGrid;
end;

function TgdEntryList.GetHeight: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to Count - 1 do
    Inc(Result, Item[I].Height);
end;

function TgdEntryList.GetItem(Index: Integer): TgdEntry;
begin
  Result := FItems[Index] as TgdEntry;
end;

function TgdEntryList.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TgdEntryList.Paint(const Y: Integer);
var
  I: Integer;
  CurrPos: Integer;
begin
  CurrPos := Y;

  for I := 0 to Count - 1 do
  begin
    Item[I].Paint(CurrPos);
    Inc(CurrPos, Item[I].Height);
  end;
end;

procedure TgdEntryList.UpdateEntryList;
var
  I: Integer;
  Entry: TgdEntry;
begin
  FItems.Clear;

  with Grid.FEntryData[FOperation.GlobalIndex]^ do
    for I := 0 to EntryData.Count - 1 do
    begin
      Entry := TgdEntry.Create(Self);
      FItems.Add(Entry);

      if egoAnalytics in Grid.FOptions then
        with Grid.FEntryData[FOperation.GlobalIndex]^.
          EntryData[I]^ do
        begin
          if Assigned(Analytics) then
          begin
            Entry.FAnalitics := TgdAnalyticBox.Create(Entry);
            Entry.FAnalitics.UpdateAnalytics;
          end;
        end;
    end;
end;

{ TgdEntry }

constructor TgdEntry.Create(AnOwner: TgdEntryList);
begin
  FEntryList := AnOwner;
  FAnalitics := nil;
end;

destructor TgdEntry.Destroy;
begin
  if Assigned(FAnalitics) then FAnalitics.Free;
  inherited;
end;

function TgdEntry.RowHeight: Integer;
begin
  with Grid do
  begin
    if Canvas.Handle <> 0 then
    begin
      TempFont.Assign(Grid.Canvas.Font);
      try
        Canvas.Font := FEntryFont;
        Result := Canvas.TextHeight('Wg') + 2;
      finally
        Grid.Canvas.Font := TempFont;
      end;
    end else
      Result := 0;
  end;
end;

function TgdEntry.GetHeight: Integer;
begin
  Result := RowHeight;

  if (egoAnalytics in Grid.FOptions) and (Assigned(FAnalitics)) then
    Inc(Result, FAnalitics.Height);
end;

function TgdEntry.GetItemIndex: Integer;
begin
  Result := FEntryList.FItems.IndexOf(Self);
end;

function TgdEntry.GetOperationGrid: TgdEntryGrid;
begin
  Result := FEntryList.FOperation.FList.FGrid;
end;

procedure TgdEntry.Paint(const Y: Integer);
var
  R: TRect;
  Entry: PEntryData;
begin
  R.Top := Y;
  R.Bottom := Y + RowHeight;
  Entry := Grid.FEntryData[FEntryList.FOperation.GlobalIndex]^.EntryData[ItemIndex];

  with Entry^ do
  begin
    if IsActive and (Grid.FMovementKind = mkEntry) then
    begin
      Grid.Canvas.Brush.Color := Grid.FFocusedColor;
      Grid.Canvas.Font := Grid.FSelectedFont;
    end else

    if Grid.Selected[Entry] then
    begin
      Grid.Canvas.Brush.Color := Grid.FSelectedColor;
      Grid.Canvas.Font := Grid.FSelectedFont;
    end else

    begin
      Grid.Canvas.Brush.Color := Grid.FEntryColor;
      Grid.Canvas.Font := Grid.FEntryFont;
    end;

    // Наименование счета
    R.Left := Grid.ClientRect.Left;
    R.Right := Grid.ClientRect.Right;
    WriteText(Grid.Canvas, R, 10, 0, AccountName, taLeftJustify);

    // Код счета
    with Grid.FColumns.ColumnByName['ACCOUNTCODE'] do
    begin
      R.Left := FLeft;
      R.Right := R.Left + FWidth + 1;
      WriteText(Grid.Canvas, R, 2, 0, AccountCode, FAlignment);
    end;

    // Дебит
    with Grid.FColumns.ColumnByName['DEBIT'] do
    begin
      R.Left := FLeft;
      R.Right := R.Left + FWidth + 1;

      if AccountType = atDebit then
        WriteText(Grid.Canvas, R, 2, 0, CurrToStr(Debit[Grid.FEntryAmount]),
          FAlignment)
      else
        WriteText(Grid.Canvas, R, 2, 0, '', FAlignment);
    end;

    // Кредит
    with Grid.FColumns.ColumnByName['CREDIT'] do
    begin
      R.Left := FLeft;
      R.Right := R.Left + FWidth + 1;

      if AccountType = atCredit then
        WriteText(Grid.Canvas, R, 2, 0, CurrToStr(Credit[Grid.FEntryAmount]),
          FAlignment)
      else
        WriteText(Grid.Canvas, R, 2, 0, '', FAlignment);
    end;
  end;

  if (egoAnalytics in Grid.FOptions) and Assigned(FAnalitics) then
    FAnalitics.Paint(Y + RowHeight);

  if (Grid.FMovementKind = mkEntry) and IsActive and Grid.Focused then
    Windows.DrawFocusRect(Grid.Canvas.Handle, Rect(
      Grid.ClientRect.Left{ + 1},
      Y{ + 1},
      Grid.ClientRect.Right{ - 1},
      Y + Height{ - 1}));
end;

function TgdEntry.MouseDown(X, Y: Integer): Boolean;
var
  OldActive, OldEntry: Integer;
  R: TRect;
  OldMovement: TenMovementKind;
  Entry: PEntryData;
begin
  Grid.CalcDrawInfo(diEntry, FEntryList.FOperation.ItemIndex, ItemIndex, R);
  Entry := Grid.FEntryData[FEntryList.FOperation.GlobalIndex]^.EntryData[ItemIndex];

  if PointInRect(X, Y, R) then
  begin
    Result := True;

    if ssShift in Grid.GetShiftState then
      Grid.Selected[Entry] := not Grid.Selected[Entry]
    else begin
      Grid.ClearSelectedList;

      if IsActive and (Grid.FMovementKind <> mkDescription) then
        Exit;
    end;

    OldActive := Grid.FActiveRecord;
    OldEntry := Grid.FActiveEntry;

    Grid.FActiveRecord := FEntryList.FOperation.ItemIndex;
    Grid.FActiveEntry := ItemIndex;
    OldMovement := Grid.FMovementKind;
    Grid.FMovementKind := mkEntry;

    if
      (OldActive <> Grid.FActiveRecord) or
      (OldMovement = mkDescription)
    then begin
      Grid.UpdateObject(diDescription, OldActive, 0);
      Grid.UpdateObject(diDescription, Grid.FActiveRecord, 0);
    end;

    Grid.UpdateObject(diEntry, OldActive, OldEntry);
    Grid.UpdateObject(diEntry, Grid.FActiveRecord, Grid.FActiveEntry);

    Grid.UpdateScrollBar;
  end else
    Result := False;
end;

function TgdEntry.GetIsActive: Boolean;
begin
  Result :=
    FEntryList.FOperation.FDescription.IsActive
      and
    (ItemIndex = Grid.FActiveEntry);
end;

{ TgdAnalyticBox }

constructor TgdAnalyticBox.Create(AnOwner: TgdEntry);
begin
  FEntry := AnOwner;
end;

destructor TgdAnalyticBox.Destroy;
begin
  inherited;
end;

function TgdAnalyticBox.GetGrid: TgdEntryGrid;
begin
  Result := FEntry.FEntryList.FOperation.FList.FGrid;
end;

function TgdAnalyticBox.GetHeight: Integer;
begin
  with Grid.FEntryData[FEntry.FEntryList.FOperation.GlobalIndex]^.
    EntryData[FEntry.ItemIndex]^
  do
    Result := Self.RowHeight * Analytics.Count;
end;

function TgdAnalyticBox.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

procedure TgdAnalyticBox.Paint(const Y: Integer);
var
  R: TRect;
  I, H: Integer;
  Entry: PEntryData;
begin
  R.Left := Grid.ClientRect.Left;
  R.Right := Grid.ClientRect.Right;

  Entry := Grid.FEntryData[FEntry.FEntryList.FOperation.GlobalIndex]^.
    EntryData[FEntry.ItemIndex];

  with Entry^ do
  begin
    if FEntry.IsActive and (Grid.FMovementKind = mkEntry) then
    begin
      Grid.Canvas.Brush.Color := Grid.FFocusedColor;
      Grid.Canvas.Font := Grid.FAnalyticsFont;
      Grid.Canvas.Font.Color := Grid.FSelectedFont.Color;
    end else

    if Grid.Selected[Entry] then
    begin
      Grid.Canvas.Brush.Color := Grid.FSelectedColor;
      Grid.Canvas.Font := Grid.FAnalyticsFont;
      Grid.Canvas.Font.Color := Grid.FSelectedFont.Color;
    end else

    begin
      Grid.Canvas.Brush.Color := Grid.FEntryColor;
      Grid.Canvas.Font := Grid.FAnalyticsFont;
    end;

    H := RowHeight;

    // Аналитика

    for I := 0 to Analytics.Count - 1 do
    begin
      R.Top := Y + H * I;
      R.Bottom := Y + H * (I + 1);
      WriteText(Grid.Canvas, R, 20, 0, '- ' + Analytics.Values[Analytics.Names[I]],
        taLeftJustify);
    end;
  end;
end;

function TgdAnalyticBox.RowHeight: Integer;
begin
  with Grid do
  begin
    if Canvas.Handle <> 0 then
    begin
      TempFont.Assign(Grid.Canvas.Font);
      try
        Canvas.Font := FAnalyticsFont;
        Result := Canvas.TextHeight('Wg');
      finally
        Grid.Canvas.Font := TempFont;
      end;
    end else
      Result := 0;
  end;
end;

procedure TgdAnalyticBox.UpdateAnalytics;
begin
  with Grid.FEntryData[FEntry.FEntryList.FOperation.GlobalIndex]^.
    EntryData[FEntry.ItemIndex]^ do
  begin
    if not AnalyticsLoaded and not (csDesigning in Grid.ComponentState) then
    begin
      Grid.UpdateAnalyticsData(Analytics);
      AnalyticsLoaded := True;
    end;
  end;
end;

{ TgdEntryDataList }

function TgdEntryDataList.Add(EntryData: PEntryData): Integer;
begin
  Result := inherited Add(EntryData);
end;

constructor TgdEntryDataList.Create(const AnOwnItems: Boolean);
begin
  FOwnItems := AnOwnItems;
end;

function TgdEntryDataList.GetItem(Index: Integer): PEntryData;
begin
  Result := inherited Items[Index];
end;

function TgdEntryDataList.IndexOf(EntryData: PEntryData): Integer;
begin
  Result := inherited IndexOf(EntryData);
end;

procedure TgdEntryDataList.Insert(Index: Integer; EntryData: PEntryData);
begin
  inherited Insert(Index, EntryData);
end;

procedure TgdEntryDataList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if (Action = lnDeleted) and FOwnItems then
  begin
    if Assigned(PEntryData(Ptr)^.Analytics) then
      PEntryData(Ptr)^.Analytics.Free;

    FreeMem(Ptr, SizeOf(TEntryData));
  end;
end;

function TgdEntryDataList.Remove(EntryData: PEntryData): Integer;
begin
  Result := inherited Remove(EntryData);
end;

procedure TgdEntryDataList.SetItem(Index: Integer; EntryData: PEntryData);
begin
  inherited Items[Index] := EntryData;
end;

function TgdColumns.GetColumn(Index: Integer): TgdColumn;
begin
  Result := FColumns[Index] as TgdColumn;
end;

function TgdColumns.GetColumnByName(AName: String): TgdColumn;
var
  I: Integer;
begin
  for I := 0 to ColumnCount - 1 do
    if AnsiCompareText(Column[I].FName, AName) = 0 then
    begin
      Result := Column[I];
      Exit;
    end;

  Result := nil;
end;

function TgdColumns.GetColumnCount: Integer;
begin
  Result := FColumns.Count;
end;

function TgdColumns.MouseDown(X, Y: Integer): Boolean;
begin
  Result := False;
end;

{ TgdAnalyticSource }

constructor TgdAnalyticSource.Create(AnOwner: TgdEntryGrid);
begin
  FGrid := AnOwner;
  FSQL := nil;
  FFieldName := '';
end;

destructor TgdAnalyticSource.Destroy;
begin
  if Assigned(FSQL) then FSQL.Free;
  inherited;
end;

function TgdAnalyticSource.GetValue(Key: String): String;
begin
  PrepareSQL;

  if FSQL.Prepared then
  begin
    FSQL.Params.ByName('ID').AsString := Key;
    FSQL.ExecQuery;
    Result := FSQL.Fields[0].AsString;
    FSQL.Close;
  end else
    Result := '';  
end;

procedure TgdAnalyticSource.PrepareSQL;
var
  EntryRelation: TatRelation;
  AnalytField: TatRelationField;

begin
  if not Assigned(FSQL) then
  begin
    FSQL := TIBSQL.Create(nil);
    FSQL.Database := FGrid.FDatabase;
    FSQL.Transaction := FGrid.FTransaction;
  end;

  if FSQL.Prepared or (csDesigning in FGrid.ComponentState) then Exit;

  EntryRelation := atDatabase.Relations.ByRelationName(ENTRY_RELATION_NAME);
  if not Assigned(EntryRelation) then
    raise EgdEntryGridError.Create(
      '''GD_ENTRYS'' relation not found in attributes structure!');

  AnalytField := EntryRelation.RelationFields.ByFieldName(FFieldName);
  if not Assigned(AnalytField) then
    raise EgdEntryGridError.CreateFmt(
      '''%s'' field not found in attributes structure!',
      [FFieldName]);

  if not Assigned(AnalytField.References) then
    raise EgdEntryGridError.CreateFmt(
      'Field ''%s'' must have a reference!',
      [FFieldName]);

  FSQL.SQL.Text := Format(
    'SELECT %s FROM %s WHERE %s = :ID',
    [
      AnalytField.References.ListField.FieldName,
      AnalytField.References.RelationName,
      AnalytField.References.PrimaryKey.ConstraintFields[0].FieldName
    ]
  );
  FSQL.Prepare;
end;

procedure TgdAnalyticSource.SetFieldName(const Value: String);
begin
  if FFieldName <> Value then
  begin
    if Assigned(FSQL) and FSQL.Prepared then
      FSQL.FreeHandle;

    FFieldName := Value;
  end;
end;

{ TgdEntryDataLink }

procedure TgdEntryDataLink.ActiveChanged;
begin
  if [csDesigning, csLoading] * FGrid.ComponentState <> [] then Exit;

  if FGrid.Active then
  begin
    FGrid.BeginUpdate;
    try
      FGrid.Active := False;
      UpdateParams;
      FGrid.Active := True;
    finally
      FGrid.EndUpdate;
    end;
  end;
end;

constructor TgdEntryDataLink.Create(AnOwner: TgdEntryGrid);
begin
  FGrid := AnOwner;
end;

destructor TgdEntryDataLink.Destroy;
begin
  inherited;
end;

procedure TgdEntryDataLink.LayoutChanged;
begin
  if [csDesigning, csLoading] * FGrid.ComponentState <> [] then Exit;

  if FGrid.Active then
  begin
    FGrid.BeginUpdate;
    try
      FGrid.Active := False;
      UpdateParams;
      FGrid.Active := True;
    finally
      FGrid.EndUpdate;
    end;
  end;  
end;

procedure TgdEntryDataLink.RecordChanged(Field: TField);
begin
  if [csDesigning, csLoading] * FGrid.ComponentState <> [] then Exit;

  if FGrid.Active then
  begin
    FGrid.BeginUpdate;
    try
      FGrid.Active := False;
      UpdateParams;
      FGrid.Active := True;
    finally
      FGrid.EndUpdate;
    end;
  end;  
end;

procedure TgdEntryDataLink.UpdateParams;
var
  P: TenParam;
begin
  FGrid.BeginUpdate;
  try
    for P := Low(TenParam) to High(TenParam) do
      if P in FGrid.FParams then
      begin
        if Active then
          FGrid.Param[P] := DataSet.FieldByName(ParamNames[P]).AsString
        else
          FGrid.Param[P] := '';
      end;
  finally
    FGrid.EndUpdate;
  end;  
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TgdEntryGrid]);
end;

initialization

  DrawBitmap := TBitmap.Create;
  TempFont := TFont.Create;

finalization

  FreeAndNil(DrawBitmap);
  FreeAndNil(TempFont);

end.

