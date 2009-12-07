
{******************************************}
{                                          }
{             FastReport v2.4              }
{             Report classes               }
{                                          }
{ Copyright (c) 1998-2001 by Tzyganenko A. }
{                                          }
{******************************************}

unit FR_Class;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Printers, Controls,
  Forms, StdCtrls, ComCtrls, Dialogs, Menus, Buttons,
  FR_View, FR_Pars, FR_Intrp, FR_DSet, FR_DBSet, FR_DBRel
{$IFDEF IBO}
, IB_Components, IB_Header
{$ELSE}
, DB
{$ENDIF}
{$IFDEF Delphi6}
, Variants
{$ENDIF};


const
// object flags
  flStretched = 1;
  flWordWrap = 2;
  flWordBreak = 4;
  flAutoSize = 8;
  flTextOnly = $10;
  flSuppressRepeated = $20;
  flHideZeros = $40;
  flUnderlines = $80;
  flRTLReading = $100;
  flBandNewPageAfter = 2;
  flBandPrintifSubsetEmpty = 4;
  flBandBreaked = 8;
  flBandOnFirstPage = $10;
  flBandOnLastPage = $20;
  flBandRepeatHeader = $40;
  flBandPrintChildIfInvisible = $80;
  flPictCenter = 2;
  flPictRatio = 4;
  flWantHook = $8000;
  flDontUndo = $4000;
  flOnePerPage = $2000;

// object types
  gtMemo = 0;
  gtPicture = 1;
  gtBand = 2;
  gtSubReport = 3;
  gtLine = 4;
  gtCross = 5;
  gtAddIn = 10;

// frame types
  frftNone = 0;
  frftRight = 1;
  frftBottom = 2;
  frftLeft = 4;
  frftTop = 8;

// text align
  frtaLeft = 0;
  frtaRight = 1;
  frtaCenter = 2;
  frtaVertical = 4;
  frtaMiddle = 8;
  frtaDown = 16;

// band align
  baNone = 0;
  baLeft = 1;
  baRight = 2;
  baCenter = 3;
  baWidth = 4;
  baBottom = 5;
  baTop = 6;
  baRest = 7;

// restriction flags
  frrfDontEditMemo = 1;
  frrfDontEditScript = 2;
  frrfDontEditContents = 4;
  frrfDontModify = 8;
  frrfDontSize = 16;
  frrfDontMove = 32;
  frrfDontDelete = 64;

  psDouble = 5;

type
  TfrDocMode = (dmDesigning, dmPrinting);
  TfrDrawMode = (drAll, drAfterCalcHeight, drPart);
  TfrBandType = (btReportTitle, btReportSummary,
                 btPageHeader, btPageFooter,
                 btMasterHeader, btMasterData, btMasterFooter,
                 btDetailHeader, btDetailData, btDetailFooter,
                 btSubDetailHeader, btSubDetailData, btSubDetailFooter,
                 btOverlay, btColumnHeader, btColumnFooter,
                 btGroupHeader, btGroupFooter,
                 btCrossHeader, btCrossData, btCrossFooter,
                 btChild, btNone);

  TfrPageType = (ptReport, ptDialog);
  TfrDataSetPosition = (psLocal, psGlobal);
  TfrPageMode = (pmNormal, pmBuildList);
  TfrBandRecType = (rtShowBand, rtFirst, rtNext);
  TfrRgnType = (rtNormal, rtExtended);
  TfrReportType = (rtSimple, rtMultiple);
  TfrDataType = (frdtString, frdtInteger, frdtFloat, frdtBoolean,
                 frdtColor, frdtEnum, frdtHasEditor, frdtSize,
                 frdtOneObject);
  TfrDataTypes = set of TfrDataType;
  TfrPrintPages = (frAll, frOdd, frEven);

  TfrView = class;
  TfrBand = class;
  TfrPage = class;
  TfrReport = class;
  TfrExportFilter = class;

  TDetailEvent = procedure(const ParName: String; var ParValue: Variant) of object;
  TEnterRectEvent = procedure(Memo: TStringList; View: TfrView) of object;
  TBeginDocEvent = procedure of object;
  TEndDocEvent = procedure of object;
  TBeginPageEvent = procedure(pgNo: Integer) of object;
  TEndPageEvent = procedure(pgNo: Integer) of object;
  TBeginBandEvent = procedure(Band: TfrBand) of object;
  TEndBandEvent = procedure(Band: TfrBand) of object;
  TProgressEvent = procedure(n: Integer) of object;
  TBeginColumnEvent = procedure(Band: TfrBand) of object;
  TPrintColumnEvent = procedure(ColNo: Integer; var Width: Integer) of object;
  TManualBuildEvent = procedure(Page: TfrPage) of object;
  TObjectClickEvent = procedure(View: TfrView) of object;
  TMouseOverObjectEvent = procedure(View: TfrView; var Cursor: TCursor) of object;
  TBeforeExportEvent = procedure(var FileName: String; var bContinue: Boolean) of object;
  TAfterExportEvent = procedure(const FileName: String) of object;
  TPrintReportEvent = procedure of object;
  TLocalizeEvent = procedure(StringID: Integer; var ResultString: String) of object;

  TfrHighlightAttr = packed record
    FontStyle: Word;
    FontColor, FillColor: TColor;
  end;

  TfrPrnInfo = record // print info about page size, margins e.t.c
    PPgw, PPgh, Pgw, Pgh: Integer; // page width/height (printer/screen)
    POfx, POfy, Ofx, Ofy: Integer; // offset x/y
    PPw, PPh, Pw, Ph: Integer;     // printable width/height
  end;

  PfrPageInfo = ^TfrPageInfo;
  TfrPageInfo = packed record // pages of a preview
    R: TRect;
    pgSize: Word;
    pgWidth, pgHeight: Integer;
    pgOr: TPrinterOrientation;
    pgBin: Integer;
    UseMargins: Boolean;
    pgMargins: TRect;
    PrnInfo: TfrPrnInfo;
    Visible: Boolean;
    Stream: TMemoryStream;
    Page: TfrPage;
  end;

  PfrBandRec = ^TfrBandRec;
  TfrBandRec = packed record
    Band: TfrBand;
    Action: TfrBandRecType;
  end;

  PfrPropRec = ^TfrPropRec;
  TfrPropRec = record
    PropName: String[32];
    PropType: TfrDataTypes;
    Enum: TStringList;
    EnumValues: Variant;
    PropEditor: TNotifyEvent;
  end;

  TfrObject = class(TObject)
  protected
    PropList: TList;
    procedure ClearPropList;
    procedure AddProperty(PropName: String; PropType: TfrDataTypes;
      PropEditor: TNotifyEvent);
    procedure AddEnumProperty(PropName: String; Enum: String;
      const EnumValues: array of Variant);
    procedure DelProperty(PropName: String);
    procedure SetPropValue(Index: String; Value: Variant); virtual;
    function GetPropValue(Index: String): Variant; virtual;
    function GetPropRec(Index: String): PfrPropRec;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; virtual;
// helper methods
    procedure SetFontProp(Font: TFont; Prop: String; Value: Variant);
    function GetFontProp(Font: TFont; Prop: String): Variant;
    function LinesMethod(Lines: TStrings; MethodName, LinesName: String;
      Par1, Par2, Par3: Variant): Variant;
  public
    constructor Create;
    destructor Destroy; override;
    procedure DefineProperties; virtual;
    property Prop[Index: String]: Variant read GetPropValue write SetPropValue;
    property PropRec[Index: String]: PfrPropRec read GetPropRec;
  end;

  TfrView = class(TfrObject)
  private
    procedure P1Click(Sender: TObject);
  protected
  {!!! добавлено для считываения типа парента из потока}
    FParentType: TfrBandType;
  {!!!}
    Parent: TfrBand;
    ParentPage: TfrPage;
    SaveX, SaveY, SaveDX, SaveDY, SaveGX, SaveGY: Integer;
    SaveFW: Single;
    BaseName: String;
    Canvas: TCanvas;
    DRect: TRect;
    Memo1: TStringList;
    FDataSet: TfrTDataSet;
    FField: String;
    olddy: Integer;
    StreamMode: (smFRF, smFRP);
    procedure ShowBackground; virtual;
    procedure ShowFrame; virtual;
    procedure BeginDraw(ACanvas: TCanvas);
    procedure GetBlob(b: TfrTField); virtual;
    procedure OnHook(View: TfrView); virtual;
    procedure ExpandVariables(var s: String);
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    procedure Loaded; virtual;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
    function ParentBand: TfrView;
  public
    Name: String;
    Typ: Byte;                // One of gtXXX constants
    HVersion, LVersion: Byte;
    ID: Integer;              // UID - used in designer (undo support)
    Selected: Boolean;        // used in designer
    OriginalRect: TRect;
    ScaleX, ScaleY: Double;   // used for scaling objects in preview
    OffsX, OffsY: Integer;    //
    IsPrinting: Boolean;      // True if printing on printer canvas
    x, y, dx, dy: Integer;
    Flags: Word;
    FrameTyp: Word;
    FrameWidth: Single;
    FrameColor: TColor;
    FrameStyle: Word;
    FillColor: TColor;
    Format: Integer;
    FormatStr: String;
    Visible: WordBool;
    gapx, gapy: Integer;
    Restrictions: Word;
    Tag: String;
    Memo, Script: TStringList;
    BandAlign: Byte;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(From: TfrView);
    procedure CalcGaps; virtual;
    procedure RestoreCoord; virtual;
    procedure Draw(Canvas: TCanvas); virtual; abstract;
    procedure StreamOut(Stream: TStream); virtual;
    procedure ExportData; virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    procedure Resized; virtual;
    procedure DefinePopupMenu(Popup: TPopupMenu); virtual;
    function GetClipRgn(rt: TfrRgnType): HRGN; virtual;
    procedure CreateUniqueName;
    procedure SetBounds(Left, Top, Width, Height: Integer);
    procedure DefineProperties; override;
    procedure ShowEditor; virtual;
{!!! Добавлено для считывания парента из потока}
{ Используется в конвертере в Word для определения }
{ типа бенда, на котором лежит мемо-поле}
    property ParentType: TfrBandType read FParentType;
{!!!}
  end;

  TfrControl = class(TfrView)
  protected
    FControl: TControl;
    procedure PaintDesignControl; virtual;
    procedure SetPropValue(Index: String; Value: Variant); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure DefineProperties; override;
    procedure PlaceControl(Form: TForm);
    procedure Draw(Canvas: TCanvas); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    property Control: TControl read FControl;
  end;

  TfrNonVisualControl = class(TfrControl)
  protected
    Bmp: TBitmap;
    Component: TComponent;
    FFixupList: TfrVariables;
    procedure SetPropValue(Index: String; Value: Variant); override;
    procedure PaintDesignControl; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure DefineProperties; override;
    procedure PlaceControl(Form: TForm);
    procedure Draw(Canvas: TCanvas); override;
  end;

  TfrStretcheable = class(TfrView)
  protected
    ActualHeight: Integer;
    DrawMode: TfrDrawMode;
    function CalcHeight: Integer; virtual; abstract;
    function MinHeight: Integer; virtual; abstract;
    function RemainHeight: Integer; virtual; abstract;
  end;

  TfrMemoView = class(TfrStretcheable)
  private
    FFont: TFont;
    LastValue: String;
    FWrapped: Boolean;
    procedure P1Click(Sender: TObject);
    procedure P2Click(Sender: TObject);
    procedure P3Click(Sender: TObject);
    procedure P5Click(Sender: TObject);
    procedure P6Click(Sender: TObject);
    procedure P8Click(Sender: TObject);
    procedure P9Click(Sender: TObject);
    procedure P10Click(Sender: TObject);
    procedure P11Click(Sender: TObject);
    procedure SetFont(Value: TFont);
  protected
    Streaming: Boolean;
    TextHeight: Integer;
    CurStrNo: Integer;
    Exporting: Boolean;
    procedure ExpandMemoVariables;
    procedure AssignFont(Canvas: TCanvas);
    procedure WrapMemo;
    procedure ShowMemo;
    procedure ShowUnderLines;
    function CalcWidth(Memo: TStringList): Integer;
    function CalcHeight: Integer; override;
    function MinHeight: Integer; override;
    function RemainHeight: Integer; override;
    procedure GetBlob(b: TfrTField); override;
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
  public
    Alignment: Integer;
    Highlight: TfrHighlightAttr;
    HighlightStr: String;
    LineSpacing, CharacterSpacing: Integer;
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure StreamOut(Stream: TStream); override;
    procedure ExportData; override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    procedure DefineProperties; override;
    procedure ShowEditor; override;
    property Font: TFont read FFont write SetFont;
  end;

  TfrBandView = class(TfrView)
  private
    procedure P1Click(Sender: TObject);
    procedure P2Click(Sender: TObject);
    procedure P3Click(Sender: TObject);
    procedure P4Click(Sender: TObject);
    procedure P5Click(Sender: TObject);
    procedure P6Click(Sender: TObject);
    procedure P7Click(Sender: TObject);
    function GetBandType: TfrBandType;
    procedure SetBandType(const Value: TfrBandType);
    function GetRectangleWidth: Integer;
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
  public
    ChildBand, Master: String;
    Columns: Integer;
    ColumnWidth: Integer;
    ColumnGap: Integer;
    NewColumnAfter: Integer;
    constructor Create; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    procedure DefineProperties; override;
    function GetClipRgn(rt: TfrRgnType): HRGN; override;
    property BandType: TfrBandType read GetBandType write SetBandType;
    property DataSet: String read FormatStr write FormatStr;
    property GroupCondition: String read FormatStr write FormatStr;
  end;

  TfrSubReportView = class(TfrView)
  public
    SubPage: Integer;
    constructor Create; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
  end;

  TfrPictureView = class(TfrView)
  private
    procedure P1Click(Sender: TObject);
    procedure P2Click(Sender: TObject);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    function DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant; override;
    procedure GetBlob(b: TfrTField); override;
  public
    Picture: TPicture;
    BlobType: Byte;
    constructor Create; override;
    destructor Destroy; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure SaveToStream(Stream: TStream); override;
    procedure DefinePopupMenu(Popup: TPopupMenu); override;
    procedure DefineProperties; override;
    procedure ShowEditor; override;
  end;

  TfrLineView = class(TfrStretcheable)
  private
    FHeight: Integer;
  public
    constructor Create; override;
    procedure Draw(Canvas: TCanvas); override;
    procedure StreamOut(Stream: TStream); override;
    function CalcHeight: Integer; override;
    function MinHeight: Integer; override;
    function RemainHeight: Integer; override;
    function GetClipRgn(rt: TfrRgnType): HRGN; override;
    procedure DefineProperties; override;
  end;

  TfrBand = class(TObject)
  private
    Parent: TfrPage;
    View: TfrBandView;
    Flags: Word;
    Next, Prev: TfrBand;
    NextGroup, PrevGroup: TfrBand;
    FirstGroup, LastGroup: TfrBand;
    Child: TfrBand;
    AggrBand: TfrBand;
    SubIndex, MaxY: Integer;
    EOFReached: Boolean;
    EOFArr: Array[0..31] of Boolean;
    Positions: Array[TfrDatasetPosition] of Integer;
    LastGroupValue: Variant;
    HeaderBand, FooterBand, DataBand, LastBand: TfrBand;
    Values: TfrVariables;
    Count: Integer;
    DisableInit: Boolean;
    CalculatedHeight: Integer;
    CurColumn: Integer;
    SaveXAdjust: Integer;
    SaveCurY: Boolean;
    MaxColumns: Integer;
    DisableBandScript: Boolean;
    procedure FreeDataSet;
    function CalcHeight: Integer;
    procedure StretchObjects(MaxHeight: Integer);
    procedure UnStretchObjects;
    procedure DrawObject(t: TfrView);
    procedure PrepareSubReports;
    procedure DoSubReports;
    function DrawObjects: Boolean;
    procedure DrawCrossCell(Parnt: TfrBand; CurX: Integer);
    procedure DrawCross;
    function CheckPageBreak(y, dy: Integer; PBreak: Boolean): Boolean;
    procedure DrawPageBreak;
    function HasCross: Boolean;
    function DoCalcHeight: Integer;
    procedure DoDraw;
    function Draw: Boolean;
    procedure InitValues;
    procedure DoAggregate;
    function ExtractField(const s: String; FieldNo: Integer): String;
    procedure AddAggregateValue(s: String; v: Variant);
    function GetAggregateValue(s: String): Variant;
  protected
    procedure InitDataSet(Desc: String); virtual; {!!!}
  public
    x, y, dx, dy, maxdy: Integer;
    Typ: TfrBandType;
    Name: String;
    PrintIfSubsetEmpty, NewPageAfter, Stretched, PageBreak,
    PrintChildIfInvisible, Visible: Boolean;
    Objects: TList;
    Memo, Script: TStringList;
    DataSet: TfrDataSet;
    IsVirtualDS: Boolean;
    VCDataSet: TfrDataSet;
    IsVirtualVCDS: Boolean;
    GroupCondition: String;
    CallNewPage, CallNewColumn: Integer;
    constructor Create(ATyp: TfrBandType; AParent: TfrPage);
    destructor Destroy; override;
  end;

  TfrPage = class(TfrObject)
  private
    Bands: Array[TfrBandType] of TfrBand;
    Skip, InitFlag: Boolean;
    CurColumn, LastStaticColumnY, XAdjust: Integer;
    List: TList;
    Mode: TfrPageMode;
    PlayFrom: Integer;
    LastBand: TfrBand;
    ColPos, CurPos: Integer;
    WasBand: TfrBand;
    DisableRepeatHeader: Boolean;
    procedure InitPage;
    procedure DonePage;
    procedure TossObjects;
    procedure PrepareObjects;
    procedure FormPage;
    procedure AddRecord(b: TfrBand; rt: TfrBandRecType);
    procedure ClearRecList;
    function PlayRecList: Boolean;
    procedure DrawPageFooters;
    function BandExists(b: TfrBand): Boolean;
    procedure AfterPrint;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure ShowBand(b: TfrBand);
    function LeftOffset: Integer;
    procedure DoScript(Script: TStrings);
    procedure DialogFormActivate(Sender: TObject);
    procedure ResetPosition(b: TfrBand; ResetTo: Integer);
  protected
    procedure SetPropValue(Index: String; Value: Variant); override;
    function GetPropValue(Index: String): Variant; override;
    {!!! JKL}
    procedure SelfCreateDS(Desc: String; var DataSet: TfrDataSet; var IsVirtualDS: Boolean); virtual;
    procedure gsGetDataSetandField(ComplexName: String; var DataSet: TfrTDataSet;
     var Field: String); virtual;
    function CreateBand(ATyp: TfrBandType; AParent: TfrPage): TfrBand; virtual;
  public
    pgSize, pgWidth, pgHeight: Integer;
    pgMargins: TRect;
    pgOr: TPrinterOrientation;
    pgBin: Integer;
    PrintToPrevPage, UseMargins: WordBool;
    PrnInfo: TfrPrnInfo;
    ColCount, ColWidth, ColGap: Integer;
    PageType: TfrPageType;
    Objects: TList;
    CurY, CurBottomY: Integer;
    Name: String;
    // dialog properties
    BorderStyle: Byte;
    Caption: String;
    Color: TColor;
    Left, Top, Width, Height: Integer;
    Position: Byte;
    Form: TForm;
    Script: TStringList;
    Visible: Boolean;
    PageNumber: Integer;
    constructor Create(ASize, AWidth, AHeight, ABin: Integer;
      AOr: TPrinterOrientation); virtual;
    destructor Destroy; override;
    procedure DefineProperties; override;
    procedure CreateUniqueName;
    function TopMargin: Integer;
    function BottomMargin: Integer;
    function LeftMargin: Integer;
    function RightMargin: Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    function FindObjectByID(ID: Integer): Integer;
    function FindObject(Name: String): TfrView;
    procedure ChangePaper(ASize, AWidth, AHeight, ABin: Integer; AOr: TPrinterOrientation);
    procedure ShowBandByName(s: String);
    procedure ShowBandByType(bt: TfrBandType);
    procedure NewPage;
    procedure NewColumn(Band: TfrBand);
    procedure ScriptEditor(Sender: TObject);
  end;

  TfrPages = class(TObject)
  private
    function GetCount: Integer;
    function GetPages(Index: Integer): TfrPage;
    procedure RefreshObjects;
  protected
    {!!!}
    FPages: TList;
    Parent: TfrReport;
  public
    constructor Create(AParent: TfrReport);
    destructor Destroy; override;
    procedure Clear;
    procedure Add; virtual; {!!!}
    procedure Delete(Index: Integer);
    procedure Move(OldIndex, NewIndex: Integer);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Pages[Index: Integer]: TfrPage read GetPages; default;
    property Count: Integer read GetCount;
  end;

  TfrEMFPages = class(TObject)
  private
    FPages: TList;
    Parent: TfrReport;
    function GetCount: Integer;
    function GetPages(Index: Integer): PfrPageInfo;
    procedure ExportData(Index: Integer);
    procedure PageToObjects(Index: Integer);
    procedure ObjectsToPage(Index: Integer);
  protected
    function CreateNewPage(ASize, AWidth, AHeight, ABin: Integer;
      AOr: TPrinterOrientation): TfrPage; virtual;
  public
    constructor Create(AParent: TfrReport);
    destructor Destroy; override;
    procedure Clear;
    procedure Draw(Index: Integer; Canvas: TCanvas; DrawRect: TRect);
    procedure Add(APage: TfrPage);
    procedure AddFrom(Report: TfrReport);
    procedure Insert(Index: Integer; APage: TfrPage);
    procedure Delete(Index: Integer);
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    function DoClick(Index: Integer; pt: TPoint; Click: Boolean; var Cursor: TCursor): Boolean;
    property Pages[Index: Integer]: PfrPageInfo read GetPages; default;
    property Count: Integer read GetCount;
  end;

  PfrCacheItem = ^TfrCacheItem;
  TfrCacheItem = record
    DataSet: TfrTDataSet;
    DataField: String;
  end;

  TfrDataDictionary = class(TObject)
  protected
    Cache: TStringList;
    function GetValue(VarName: String): Variant;
    function GetRealFieldName(ItemName: String): String;
    function GetRealDataSetName(ItemName: String): String;
    function GetRealDataSourceName(ItemName: String): String;
    function GetAliasName(ItemName: String): String;
    procedure AddCacheItem(VarName: String; DataSet: TfrTDataSet; DataField: String);
    procedure ClearCache;
  public
    Variables: TfrVariables;
    FieldAliases: TfrVariables;
    BandDatasources: TfrVariables;
    DisabledDatasets: TStringList;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream); virtual; {!!!}
    procedure SaveToStream(Stream: TStream);
    procedure LoadFromFile(FName: String); virtual; {!!!}
    procedure SaveToFile(FName: String);
    procedure ExtractFieldName(ComplexName: String;
      var DSName, FieldName: String);
    function IsVariable(VarName: String): Boolean; virtual; {!!!}
    function DatasetEnabled(DatasetName: String): Boolean;
    procedure GetDatasetList(List: TStrings); virtual; {!!!}
    procedure GetFieldList(DSName: String; List: TStrings); virtual; {!!!}
    procedure GetBandDatasourceList(List: TStrings); virtual; {!!!}
    function gsGetDataSet(ComplexName: String): TfrTDataSet; virtual; {!!!}
    procedure GetCategoryList(List: TStrings);
    procedure GetVariablesList(Category: String; List: TStrings);
    property Value[Index: String]: Variant read GetValue;
    property RealDataSetName[Index: String]: String read GetRealDataSetName;
    property RealDataSourceName[Index: String]: String read GetRealDataSourceName;
    property RealFieldName[Index: String]: String read GetRealFieldName;
    property AliasName[Index: String]: String read GetAliasName;
  end;

  TfrReport = class(TComponent)
  private
    FPages: TfrPages;
    FEMFPages: TfrEMFPages;
    FDictionary: TfrDataDictionary;
    FDataset: TfrDataset;
    FGrayedButtons: Boolean;
    FReportType: TfrReportType;
    FTitle: String;
    FShowProgress: Boolean;
    FModalPreview: Boolean;
    FModifyPrepared: Boolean;
    FStoreInDFM: Boolean;
    FPreview: TfrPreview;
    FPreviewButtons: TfrPreviewButtons;
    FInitialZoom: TfrPreviewZoom;
    FOnBeginDoc: TBeginDocEvent;
    FOnEndDoc: TEndDocEvent;
    FOnBeginPage: TBeginPageEvent;
    FOnEndPage: TEndPageEvent;
    FOnBeginBand: TBeginBandEvent;
    FOnEndBand: TEndBandEvent;
    FOnGetValue: TDetailEvent;
    FOnEnterRect: TEnterRectEvent;
    FOnProgress: TProgressEvent;
    FOnFunction: TFunctionEvent;
    FOnBeginColumn: TBeginColumnEvent;
    FOnPrintColumn: TPrintColumnEvent;
    FOnManualBuild: TManualBuildEvent;
    FObjectClick: TObjectClickEvent;
    FMouseOverObject: TMouseOverObjectEvent;
    FOnPrintReportEvent: TPrintReportEvent;
    FCurrentFilter: TfrExportFilter;
    FPageNumbers: String;
    FCopies: Integer;
    FCollate: Boolean;
    FPrintPages: TfrPrintPages;
    FCurPage: TfrPage;
    _DoublePass: Boolean;
    FMDIPreview: Boolean;
    FDefaultCopies: Integer;
    FDefaultCollate: Boolean;
    FPrnName: String;
    FDFMStream: TStream;
    FPrintIfEmpty: Boolean;
    FShowPrintDialog: Boolean;
    FOnCrossBeginDoc: TBeginDocEvent;
    function FormatValue(V: Variant; Format: Integer;
      const FormatStr: String): String;
    procedure BuildBeforeModal(Sender: TObject);
    procedure ExportBeforeModal(Sender: TObject);
    procedure PrintBeforeModal(Sender: TObject);
    function DoPrepareReport: Boolean;
    procedure DoBuildReport; virtual;
    procedure SetPrinterTo(PrnName: String);
    procedure GetIntrpValue(const Name: String; var Value: Variant);
    procedure GetIntrpFunction(const Name: String; p1, p2, p3: Variant;
      var Val: Variant);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadBinaryData(Stream: TStream);
    procedure WriteBinaryData(Stream: TStream);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoPrintReport(PageNumbers: String; Copies: Integer;
      Collate: Boolean; PrintPages: TfrPrintPages); virtual;
    procedure Loaded; override;
  public
    CanRebuild: Boolean;            // true, if report can be rebuilded
    Terminated: Boolean;
    PrintToDefault, DoublePass: WordBool;
    FinalPass: Boolean;
    FileName: String;
    Modified, ComponentModified: Boolean;
    MixVariablesAndDBFields: Boolean;
{$IFDEF 1CScript}
    Script : TStringList;
{$ENDIF}
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    // internal events used through report building
    property OnCrossBeginDoc: TBeginDocEvent read FOnCrossBeginDoc write FOnCrossBeginDoc;
    procedure InternalOnEnterRect(Memo: TStringList; View: TfrView);
    procedure InternalOnExportData(View: TfrView);
    procedure InternalOnExportText(DrawRect: TRect; x, y: Integer;
      const text: String; FrameTyp: Integer; View: TfrView);
    procedure InternalOnGetValue(ParName: String; var ParValue: String);
    procedure InternalOnProgress(Percent: Integer);
    procedure InternalOnBeginColumn(Band: TfrBand);
    procedure InternalOnPrintColumn(ColNo: Integer; var ColWidth: Integer);
    procedure FillQueryParams;
    procedure GetVariableValue(const s: String; var v: Variant);
{$IFDEF 1CScript}
    procedure GetVariableV(const s: String; var v: Variant);
{$ENDIF}
    procedure OnGetParsFunction(const name: String; p1, p2, p3: Variant;
                                var val: Variant);
    function FindObject(Name: String): TfrView;
    // load/save methods
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    function LoadFromFile(FName: String): Boolean;
    procedure SaveToFile(FName: String);
{$IFDEF IBO}
    procedure LoadFromDB(Table: TIB_DataSet; DocN: Integer);
    procedure SaveToDB(Table: TIB_DataSet; DocN: Integer);
    procedure SaveToBlobField(Blob: TIB_ColumnBlob);
    procedure LoadFromBlobField(Blob: TIB_ColumnBlob);
{$ELSE}
    procedure LoadFromDB(Table: TDataSet; DocN: Integer);
    procedure SaveToDB(Table: TDataSet; DocN: Integer);
    procedure SaveToBlobField(Blob: TField);
    procedure LoadFromBlobField(Blob: TField);
{$ENDIF}
    procedure LoadFromResourceName(Instance: THandle; const ResName: string);
    procedure LoadFromResourceID(Instance: THandle; ResID: Integer);
    procedure LoadTemplate(fname: String; comm: TStrings;
      Bmp: TBitmap; Load: Boolean);
    procedure SaveTemplate(fname: String; comm: TStrings; Bmp: TBitmap);
    procedure LoadPreparedReport(FName: String);
    procedure SavePreparedReport(FName: String);
    // report manipulation methods
    function DesignReport: TModalResult;
    function PrepareReport: Boolean;
    procedure ExportTo(Filter: TfrExportFilter; FileName: String);
    procedure ShowReport;
    procedure ShowPreparedReport; virtual; {!!!}
    procedure PrintPreparedReportDlg;
    procedure PrintPreparedReport(PageNumbers: String; Copies: Integer;
      Collate: Boolean; PrintPages: TfrPrintPages);
    function ChangePrinter(OldIndex, NewIndex: Integer): Boolean;
    procedure EditPreparedReport(PageIndex: Integer);
    //
    property Pages: TfrPages read FPages write FPages; {!!!}
    property EMFPages: TfrEMFPages read FEMFPages write FEMFPages;
    property Dictionary: TfrDataDictionary read FDictionary write FDictionary;
  published
    property Dataset: TfrDataset read FDataset write FDataset;
    property DefaultCopies: Integer read FDefaultCopies write FDefaultCopies default 1;
    property DefaultCollate: Boolean read FDefaultCollate write FDefaultCollate default True;
    property GrayedButtons: Boolean read FGrayedButtons write FGrayedButtons default False;
    property InitialZoom: TfrPreviewZoom read FInitialZoom write FInitialZoom;
    property MDIPreview: Boolean read FMDIPreview write FMDIPreview default False;
    property ModalPreview: Boolean read FModalPreview write FModalPreview default True;
    property ModifyPrepared: Boolean read FModifyPrepared write FModifyPrepared default True;
    property Preview: TfrPreview read FPreview write FPreview;
    property PreviewButtons: TfrPreviewButtons read FPreviewButtons write FPreviewButtons;
    property PrintIfEmpty: Boolean read FPrintIfEmpty write FPrintIfEmpty default True;
    property ReportType: TfrReportType read FReportType write FReportType default rtSimple;
    property ShowPrintDialog: Boolean read FShowPrintDialog write FShowPrintDialog default True;
    property ShowProgress: Boolean read FShowProgress write FShowProgress default True;
    property StoreInDFM: Boolean read FStoreInDFM write FStoreInDFM default False;
    property Title: String read FTitle write FTitle;
    property OnBeginDoc: TBeginDocEvent read FOnBeginDoc write FOnBeginDoc;
    property OnEndDoc: TEndDocEvent read FOnEndDoc write FOnEndDoc;
    property OnBeginPage: TBeginPageEvent read FOnBeginPage write FOnBeginPage;
    property OnEndPage: TEndPageEvent read FOnEndPage write FOnEndPage;
    property OnBeginBand: TBeginBandEvent read FOnBeginBand write FOnBeginBand;
    property OnEndBand: TEndBandEvent read FOnEndBand write FOnEndBand;
    property OnGetValue: TDetailEvent read FOnGetValue write FOnGetValue;
    property OnBeforePrint: TEnterRectEvent read FOnEnterRect write FOnEnterRect;
    property OnUserFunction: TFunctionEvent read FOnFunction write FOnFunction;
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
    property OnBeginColumn: TBeginColumnEvent read FOnBeginColumn write FOnBeginColumn;
    property OnPrintColumn: TPrintColumnEvent read FOnPrintColumn write FOnPrintColumn;
    property OnManualBuild: TManualBuildEvent read FOnManualBuild write FOnManualBuild;
    property OnObjectClick: TObjectClickEvent read FObjectClick write FObjectClick;
    property OnMouseOverObject: TMouseOverObjectEvent read FMouseOverObject write FMouseOverObject;
    property OnPrintReport: TPrintReportEvent read FOnPrintReportEvent write FOnPrintReportEvent;
  end;

  TfrCompositeReport = class(TfrReport)
  private
    procedure DoBuildReport; override;
  public
    Reports: TList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TfrReportDesigner = class(TForm)
  protected
    function GetModified: Boolean; virtual; abstract;
    procedure SetModified(Value: Boolean); virtual; abstract;
  public
    Page: TfrPage;
    FirstInstance: Boolean;
    constructor CreateDesigner(AFirstInstance: Boolean); virtual;
    procedure BeforeChange; virtual; abstract;
    procedure AfterChange; virtual; abstract;
    procedure RedrawPage; virtual; abstract;
    procedure SelectObject(ObjName: String); virtual; abstract;
    function InsertDBField: String; virtual; abstract;
    function InsertExpression: String; virtual; abstract;
    property Modified: Boolean read GetModified write SetModified;
  end;

  TfrDataManager = class(TObject)
  public
    procedure Clear; virtual; abstract;
    procedure LoadFromStream(Stream: TStream); virtual; abstract;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    procedure BeforePreparing; virtual; abstract;
    procedure AfterPreparing; virtual; abstract;
    procedure PrepareDataSet(ds: TfrTDataSet); virtual; abstract;
    function ShowParamsDialog: Boolean; virtual; abstract;
    procedure AfterParamsDialog; virtual; abstract;
  end;

  TfrObjEditorForm = class(TForm)
  public
    function ShowEditor(View: TfrView): TModalResult; virtual;
  end;

  TfrExportFilter = class(TComponent)
  protected
    FileName: String;
    Stream: TStream;
    Lines: TList;
    FShowDialog: Boolean;
    FDefault: Boolean;
    FOnBeforeExport: TBeforeExportEvent;
    FOnAfterExport: TAfterExportEvent;
    procedure ClearLines; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ShowModal: Word; virtual;
    procedure OnBeginDoc; virtual;
    procedure OnEndDoc; virtual;
    procedure OnBeginPage; virtual;
    procedure OnEndPage; virtual;
    procedure OnData(x, y: Integer; View: TfrView); virtual;
    procedure OnText(DrawRect: TRect; x, y: Integer;
      const text: String; FrameTyp: Integer; View: TfrView); virtual;
  published
    property Default: Boolean read FDefault write FDefault default False;
    property ShowDialog: Boolean read FShowDialog write FShowDialog default True;
    property OnBeforeExport: TBeforeExportEvent read FOnBeforeExport write FOnBeforeExport;
    property OnAfterExport: TAfterExportEvent read FOnAfterExport write FOnAfterExport;
  end;

  TfrFunctionLibrary = class(TObject)
  public
    List: TStringList;
    constructor Create; virtual;
    destructor Destroy; override;
    function OnFunction(const FName: String; p1, p2, p3: Variant;
      var val: Variant): Boolean; virtual;
    procedure DoFunction(FNo: Integer; p1, p2, p3: Variant; var val: Variant);
      virtual; abstract;
    procedure AddFunctionDesc(FuncName, Category, Description: String);
  end;

  TfrCompressor = class(TObject)
  public
    Enabled: Boolean;
    constructor Create; virtual;
    procedure Compress(StreamIn, StreamOut: TStream); virtual;
    procedure DeCompress(StreamIn, StreamOut: TStream); virtual;
  end;

  TfrInstalledFunctions = class(TObject)
  private
    FList: TList;
    procedure UnRegisterFunctionLibrary(FunctionLibrary: TfrFunctionLibrary);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(FunctionLibrary: TfrFunctionLibrary;
      FuncName, Category, Description: String);
    function GetFunctionDesc(FuncName: String): String;
    procedure GetCategoryList(List: TStrings);
    procedure GetFunctionList(Category: String; List: TStrings);
  end;

{ TfrLocale class contains methods and properties for localization.
  You can use global function frLocale: TfrLocale to access these methods.
  FR localization can come from .exe resources (default) or dll resource file.

  To make dll resource file, go RES folder and subfolder with needed language
  and run mkdll.bat file. To use dll in your project, write the following code:

  frLocale.LoadDll('FR_ENGL.DLL');

  To use default .exe resources, unload dll by code:

  frLocale.UnloadDll;

  If you want to make own localization file (for instance, text file), use
  event handler frLocale.OnLocalize. It takes StringID parameter and must
  return ResultString string (see TLocalizeEvent for syntax). You handler
  may look like this:

  frLocale.OnLocalize := MyClass.OnLocalize;
  ...
  procedure TMyClass.OnLocalize(StringID: Integer; var ResultString: String);
  begin
    if StringID = 53000 then
      ResultString := 'Search';
  end;
}

  TfrLocale = class
  private
    FDllHandle: THandle;
    FLoaded: Boolean;
    FLocalizedPropertyNames: Boolean;
    FOnLocalize: TLocalizeEvent;
    FIDEMode: Boolean;
  public
    constructor Create;
    function LoadBmp(ID: String): HBitmap;
    function LoadStr(ID: Integer): String;
    procedure LoadDll(Name: String);
    procedure UnloadDll;
    property LocalizedPropertyNames: Boolean read FLocalizedPropertyNames
      write FLocalizedPropertyNames;
    property OnLocalize: TLocalizeEvent read FOnLocalize write FOnLocalize;
  end;

  TfrGlobals = class
  public
    constructor Create;
    destructor Destroy; override;
    procedure Localize;
  end;


function frCreateObject(Typ: Byte; const ClassName: String): TfrView;
procedure frRegisterObject(ClassRef: TClass; ButtonBmp: TBitmap;
  const ButtonHint: String);
procedure frRegisterControl(ClassRef: TClass; ButtonBmp: TBitmap;
  const ButtonHint: String);
procedure frUnRegisterObject(ClassRef: TClass);
procedure frRegisterExportFilter(Filter: TfrExportFilter;
  const FilterDesc, FilterExt: String);
procedure frUnRegisterExportFilter(Filter: TfrExportFilter);
procedure frRegisterFunctionLibrary(ClassRef: TClass);
procedure frUnRegisterFunctionLibrary(ClassRef: TClass);
procedure frRegisterTool(MenuCaption: String; ButtonBmp: TBitmap; OnClick: TNotifyEvent);
procedure frAddFunctionDesc(FuncLibrary: TfrFunctionLibrary;
  FuncName, Category, Description: String);
function GetDefaultDataSet: TfrTDataSet;
function frLocale: TfrLocale;

const
  frCurrentVersion = 24; // this is current version (2.4)
  frSpecCount = 9;
  frSpecFuncs: Array[0..frSpecCount - 1] of String =
    ('PAGE#', '', 'DATE', 'TIME', 'LINE#', 'LINETHROUGH#', 'COLUMN#',
     'CURRENT#', 'TOTALPAGES');
  frColors: Array[0..41] of TColor =
    (clWhite, clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple, clTeal,
     clGray, clSilver, clRed, clLime, clYellow, clBlue, clFuchsia,
     clAqua, clNone,
     clScrollBar, clBackground, clActiveCaption, clInactiveCaption,
     clMenu, clWindow, clWindowFrame, clMenuText, clWindowText,
     clCaptionText, clActiveBorder, clInactiveBorder, clAppWorkSpace,
     clHighlight, clHighlightText, clBtnFace, clBtnShadow, clGrayText,
     clBtnText, clInactiveCaptionText, clBtnHighlight, cl3DDkShadow,
     cl3DLight, clInfoText, clInfoBk);
  frColorNames: Array[0..41] of String =
    ('clWhite', 'clBlack', 'clMaroon', 'clGreen', 'clOlive', 'clNavy',
     'clPurple', 'clTeal', 'clGray', 'clSilver', 'clRed', 'clLime',
     'clYellow', 'clBlue', 'clFuchsia', 'clAqua', 'clTransparent',
     'clScrollBar', 'clBackground', 'clActiveCaption', 'clInactiveCaption',
     'clMenu', 'clWindow', 'clWindowFrame', 'clMenuText', 'clWindowText',
     'clCaptionText', 'clActiveBorder', 'clInactiveBorder', 'clAppWorkSpace',
     'clHighlight', 'clHighlightText', 'clBtnFace', 'clBtnShadow', 'clGrayText',
     'clBtnText', 'clInactiveCaptionText', 'clBtnHighlight', 'cl3DDkShadow',
     'cl3DLight', 'clInfoText', 'clInfoBk');


type
  PfrTextRec = ^TfrTextRec;
  TfrTextRec = record
    Next: PfrTextRec;
    X, Y: Integer;
    Text: String;
    FontName: String[32];
    FontSize, FontStyle, FontColor, FontCharset, FillColor: Integer;
    DrawRect: TRect;
    FrameTyp, FrameWidth, FrameColor, Alignment: Integer;
  end;

  TfrAddInObjectInfo = record
    ClassRef: TClass;
    ButtonBmp: TBitmap;
    ButtonHint: String;
    IsControl: Boolean;
  end;

  TfrExportFilterInfo = record
    Filter: TfrExportFilter;
    FilterDesc, FilterExt: String;
  end;

  TfrFunctionInfo = record
    FunctionLibrary: TfrFunctionLibrary;
  end;

  TfrToolsInfo = record
    Caption: String;
    ButtonBmp: TBitmap;
    OnClick: TNotifyEvent;
  end;

  {!!!}
  TAggregateFunctionsSplitter = class(TfrFunctionSplitter)
  public
    constructor CreateSplitter(SplitTo: TStrings);
    destructor Destroy; override;
    procedure SplitMemo(Memo: TStrings);
    procedure SplitScript(Script: TStrings);
  end;

var
  frDesigner: TfrReportDesigner;                  // designer reference
  frDesignerClass: TClass;
  frDataManager: TfrDataManager;                  // data manager reference
  frParser: TfrParser;                            // parser reference
  frInterpretator: TfrInterpretator;              // interpretator reference
  frVariables: TfrVariables;                      // report variables reference
  frConsts: TfrVariables;                         // some constants like 'clRed'
  frCompressor: TfrCompressor;                    // compressor reference
  frDialogForm: TForm;                            // dialog form reference
  CurReport: TfrReport;                           // currently proceeded report
  MasterReport: TfrReport;               // reference to main composite report
  CurView: TfrView;                               // currently proceeded view
  CurBand: TfrBand;                               // currently proceeded band
  CurPage: TfrPage;                               // currently proceeded page
  DocMode: TfrDocMode;                            // current mode
  DisableDrawing: Boolean;
  frAddIns: Array[0..31] of TfrAddInObjectInfo;   // add-in objects
  frAddInsCount: Integer;
  frFilters: Array[0..31] of TfrExportFilterInfo; // export filters
  frFiltersCount: Integer;
  frFunctions: Array[0..31] of TfrFunctionInfo;   // function libraries
  frFunctionsCount: Integer;
  frTools: Array[0..31] of TfrToolsInfo;          // tools
  frToolsCount: Integer;
  frInstalledFunctions: TfrInstalledFunctions;
  PageNo: Integer;                       // current page number in Building mode
  frCharset: 0..255;
  frBandNames: Array[0..22] of String;
  frDateFormats, frTimeFormats: Array[0..3] of String;
  frVersion: Byte;                       // version of currently loaded report
  ErrorFlag: Boolean;          // error occured through TfrView drawing
  ErrorStr: String;            // error description
  SMemo: TStringList;          // temporary memo used during TfrView drawing
  ShowBandTitles: Boolean = True;
  frThreadDone: Boolean;
// editors
  frMemoEditor: TNotifyEvent;
  frTagEditor: TNotifyEvent;
  frRestrEditor: TNotifyEvent;
  frHighlightEditor: TNotifyEvent;
  frFieldEditor: TNotifyEvent;
  frDataSourceEditor: TNotifyEvent;
  frCrossDataSourceEditor: TNotifyEvent;
  frGroupEditor: TNotifyEvent;
  frPictureEditor: TNotifyEvent;
  frFontEditor: TNotifyEvent;
  frGlobals: TfrGlobals;


implementation

uses
  FR_Fmted, FR_PrDlg, FR_Prntr, FR_Progr, FR_Utils, FR_Const
  {$IFDEF Delphi6}, MaskUtils {$ELSE}, Mask{$ENDIF}
  {$IFDEF JPEG}, JPEG {$ENDIF};

{$R FR_Lng1.RES}
//{$DEFINE Trial}

type
  TfrStdFunctionLibrary = class(TfrFunctionLibrary)
  public
    constructor Create; override;
    procedure DoFunction(FNo: Integer; p1, p2, p3: Variant;
      var val: Variant); override;
  end;

  TInterpretator = class(TfrInterpretator)
  public
    procedure GetValue(const Name: String; var Value: Variant); override;
    procedure SetValue(const Name: String; Value: Variant); override;
    procedure DoFunction(const name: String; p1, p2, p3: Variant;
      var val: Variant); override;
  end;

  PfrFunctionDesc = ^TfrFunctionDesc;
  TfrFunctionDesc = record
    FunctionLibrary: TfrFunctionLibrary;
    Name, Category, Description: String;
  end;


const
  atNone = 10;
  atSum = 11;
  atMin = 12;
  atMax = 13;
  atAvg = 14;
  atCount = 15;


var
  VHeight: Integer;            // used for height calculation of TfrMemoView
  SBmp: TBitmap;               // small bitmap used by TfrBandView drawing
  TempBmp: TBitmap;            // temporary bitmap used by TfrMemoView
  CurDate, CurTime: TDateTime; // date/time of report starting
  CurValue: Variant;           // used for highlighting
  CurVariable: String;
  IsColumns: Boolean;
  SavedAllPages: Integer;      // number of pages in entire report
  SubValue: String;            // used in GetValue event handler
  ObjID: Integer = 0;
  BoolStr: Array[0..3] of String;
  HookList: TList;

// aggregate handling
  InitAggregate: Boolean;
  AggrBand: TfrBand;

// variables used through report building
  PrevY, PrevBottomY, ColumnXAdjust: Integer;
  Append, WasPF: Boolean;
  CompositeMode: Boolean;
  DontShowReport: Boolean;
  frProgressForm: TfrProgressForm;
  FLocale: TfrLocale = nil;

{----------------------------------------------------------------------------}
function frCreateObject(Typ: Byte; const ClassName: String): TfrView;
var
  i: Integer;
begin
  Result := nil;
  case Typ of
    gtMemo:      Result := TfrMemoView.Create;
    gtPicture:   Result := TfrPictureView.Create;
    gtBand:      Result := TfrBandView.Create;
    gtSubReport: Result := TfrSubReportView.Create;
    gtLine:      Result := TfrLineView.Create;
//    gtCross:     Result := TfrCrossView.Create;
    gtAddIn:
      begin
        for i := 0 to frAddInsCount - 1 do
          if frAddIns[i].ClassRef.ClassName = ClassName then
          begin
            Result := TfrView(frAddIns[i].ClassRef.NewInstance);
            Result.Create;
            Result.Typ := gtAddIn;
            break;
          end;
        if Result = nil then
        begin
          ErrorFlag := True;
          ErrorStr := ErrorStr + ClassName + #13;
          raise EClassNotFound.Create(ErrorStr);
        end;
      end;
  end;
  if Result <> nil then
  begin
    Result.ID := ObjID;
    Inc(ObjID);
  end;
end;

procedure frRegisterObject(ClassRef: TClass; ButtonBmp: TBitmap;
  const ButtonHint: String);
var
  i: Integer;
begin
  for i := 0 to frAddInsCount - 1 do
    if frAddIns[i].ClassRef = ClassRef then Exit;

  i := frAddInsCount;
  frAddIns[i].ClassRef := ClassRef;
  frAddIns[i].ButtonBmp := ButtonBmp;
  frAddIns[i].ButtonHint := ButtonHint;
  frAddIns[i].IsControl := False;
  if ButtonBmp <> nil then
    ButtonBmp.Dormant;
  Inc(frAddInsCount);
end;

procedure frRegisterControl(ClassRef: TClass; ButtonBmp: TBitmap;
  const ButtonHint: String);
var
  i: Integer;
begin
  for i := 0 to frAddInsCount - 1 do
    if frAddIns[i].ClassRef = ClassRef then Exit;

  i := frAddInsCount;
  frAddIns[i].ClassRef := ClassRef;
  frAddIns[i].ButtonBmp := ButtonBmp;
  frAddIns[i].ButtonHint := ButtonHint;
  frAddIns[i].IsControl := True;
  if ButtonBmp <> nil then
    ButtonBmp.Dormant;
  Inc(frAddInsCount);
end;

procedure frUnRegisterObject(ClassRef: TClass);
var
  i, j: Integer;
begin
  for i := 0 to frAddInsCount - 1 do
    if frAddIns[i].ClassRef = ClassRef then
    begin
      for j := i to frAddInsCount - 2 do
        frAddIns[j] := frAddIns[j + 1];
      Dec(frAddInsCount);
    end;
end;

procedure frRegisterExportFilter(Filter: TfrExportFilter;
  const FilterDesc, FilterExt: String);
var
  i: Integer;
begin
  for i := 0 to frFiltersCount - 1 do
    if frFilters[i].Filter.ClassName = Filter.ClassName then Exit;
  frFilters[frFiltersCount].Filter := Filter;
  frFilters[frFiltersCount].FilterDesc := FilterDesc;
  frFilters[frFiltersCount].FilterExt := FilterExt;
  Inc(frFiltersCount);
end;

procedure frUnRegisterExportFilter(Filter: TfrExportFilter);
var
  i, j: Integer;
begin
  for i := 0 to frFiltersCount - 1 do
    if frFilters[i].Filter.ClassName = Filter.ClassName then
    begin
      for j := i to frFiltersCount - 2 do
        frFilters[j] := frFilters[j + 1];
      Dec(frFiltersCount);
    end;
end;

procedure frRegisterFunctionLibrary(ClassRef: TClass);
var
  i: Integer;
begin
  for i := 0 to frFunctionsCount - 1 do
    if frFunctions[i].FunctionLibrary.ClassName = ClassRef.ClassName then Exit;
  frFunctions[frFunctionsCount].FunctionLibrary :=
    TfrFunctionLibrary(ClassRef.NewInstance);
  frFunctions[frFunctionsCount].FunctionLibrary.Create;
  Inc(frFunctionsCount);
end;

procedure frUnRegisterFunctionLibrary(ClassRef: TClass);
var
  i, j: Integer;
begin
  for i := 0 to frFunctionsCount - 1 do
    if frFunctions[i].FunctionLibrary.ClassName = ClassRef.ClassName then
    begin
      frInstalledFunctions.UnRegisterFunctionLibrary(frFunctions[i].FunctionLibrary);
      frFunctions[i].FunctionLibrary.Free;
      for j := i to frFunctionsCount - 2 do
        frFunctions[j] := frFunctions[j + 1];
      Dec(frFunctionsCount);
    end;
end;

procedure frRegisterTool(MenuCaption: String; ButtonBmp: TBitmap; OnClick: TNotifyEvent);
var
  i: Integer;
  Exist: Boolean;
begin
  Exist := False;
  for i := 0 to frToolsCount - 1 do
    if frTools[i].Caption = MenuCaption then
    begin
      Exist := True;
      break;
    end;
  if not Exist then
    i := frToolsCount;

  frTools[i].Caption := MenuCaption;
  frTools[i].ButtonBmp := ButtonBmp;
  frTools[i].OnClick := OnClick;
  if ButtonBmp <> nil then
    ButtonBmp.Dormant;
  if not Exist then
    Inc(frToolsCount);
end;

procedure frAddFunctionDesc(FuncLibrary: TfrFunctionLibrary;
  FuncName, Category, Description: String);
begin
  frInstalledFunctions.Add(FuncLibrary, FuncName, Category, Description);
end;

function Create90Font(Font: TFont): HFont;
var
  F: TLogFont;
begin
  GetObject(Font.Handle, SizeOf(TLogFont), @F);
  F.lfEscapement := 900;
  F.lfOrientation := 900;
  Result := CreateFontIndirect(F);
end;

function GetDefaultDataSet: TfrTDataSet;
var
  Res: TfrDataset;
begin
  Result := nil; Res := nil;
  if (CurBand <> nil) and (CurPage <> nil) and (CurPage.PageType = ptReport) then
    case CurBand.Typ of
      btReportTitle, btReportSummary,
      btPageHeader, btPageFooter,
      btMasterHeader, btMasterData, btMasterFooter,
      btGroupHeader, btGroupFooter:
        Res := CurPage.Bands[btMasterData].DataSet;
      btDetailData, btDetailFooter:
        Res := CurPage.Bands[btDetailData].DataSet;
      btSubDetailData, btSubDetailFooter:
        Res := CurPage.Bands[btSubDetailData].DataSet;
      btCrossData, btCrossFooter:
        Res := CurPage.Bands[btCrossData].DataSet;
    end;
  if (Res <> nil) and (Res is TfrDBDataset) then
    Result := TfrDBDataSet(Res).GetDataSet;
end;

function ReadString(Stream: TStream): String;
begin
  if frVersion >= 23 then
    Result := frReadString(Stream) else
    Result := frReadString22(Stream);
end;

procedure ReadMemo(Stream: TStream; Memo: TStrings);
begin
  if frVersion >= 23 then
    frReadMemo(Stream, Memo) else
    frReadMemo22(Stream, Memo);
end;

procedure CreateDS(Desc: String; var DataSet: TfrDataSet; var IsVirtualDS: Boolean);
begin
  if (Desc <> '') and (Desc[1] in ['1'..'9']) then
  begin
    DataSet := TfrUserDataSet.Create(nil);
    DataSet.RangeEnd := reCount;
    DataSet.RangeEndCount := StrToInt(Desc);
    IsVirtualDS := True;
  end
  else
    DataSet := frFindComponent(CurReport.Owner, Desc) as TfrDataSet;
  if DataSet <> nil then
    DataSet.Init;
end;

procedure DoError(E: Exception);
var
  i: Integer;
  s: String;
begin
  ErrorFlag := True;
  ErrorStr := frLoadStr(SErrorOccured);
  if CurView <> nil then
  begin
    for i := 0 to CurView.Memo.Count - 1 do
      ErrorStr := ErrorStr + #13 + CurView.Memo[i];
    s := frLoadStr(SObject) + ' ' + CurView.Name + #13;
  end
  else
    s := '';
  ErrorStr := ErrorStr + #13#13 + frLoadStr(SDoc) + ' ' + CurReport.Name +
    #13 + s + #13 + E.Message;
  MasterReport.Terminated := True;
end;

procedure ParseObjectName(const Name: String; var Obj: TfrObject; var Prop: String);
var
  ObjName: String;
  PageNo: Integer;

  procedure DefineProperties(Obj: TfrObject);
  begin
    if Obj <> nil then
      if Obj.PropList.Count = 0 then
        Obj.DefineProperties;
  end;

begin
  Obj := CurView;
  Prop := Name;
  if Pos('.', Name) <> 0 then
  begin
    ObjName := Copy(Name, 1, Pos('.', Name) - 1);
    Prop := Copy(Name, Pos('.', Name) + 1, 255);

    if (Pos('PAGE', AnsiUpperCase(ObjName)) = 1) and (Length(ObjName) > 4) and
       (ObjName[5] in ['0'..'9']) then
    begin
      PageNo := StrToInt(Copy(ObjName, 5, 255));
      Obj := CurReport.Pages[PageNo - 1];
    end
    else
    begin
      Obj := CurReport.FindObject(ObjName);

      if Obj = nil then
      begin
        DefineProperties(CurView);
        if (CurView <> nil) and (CurView.PropRec[ObjName] <> nil) then
        begin
          Obj := CurView;
          Prop := Name;
        end
      end;
    end;
  end;

  DefineProperties(Obj);
end;


{ TfrObject }

constructor TfrObject.Create;
begin
  inherited Create;
  PropList := TList.Create;
end;

destructor TfrObject.Destroy;
begin
  ClearPropList;
  PropList.Free;
  inherited Destroy;
end;

procedure TfrObject.ClearPropList;
var
  p: PfrPropRec;
begin
  while PropList.Count > 0 do
  begin
    p := PropList[0];
    if p^.Enum <> nil then
      p^.Enum.Free;
    Dispose(p);
    PropList.Delete(0);
  end;
end;

procedure TfrObject.AddProperty(PropName: String; PropType: TfrDataTypes;
  PropEditor: TNotifyEvent);
var
  p: PfrPropRec;
begin
  New(p);
  p^.PropName := PropName;
  p^.PropType := PropType;
  p^.PropEditor := PropEditor;
  p^.Enum := nil;
  PropList.Add(p);
end;

procedure TfrObject.AddEnumProperty(PropName: String; Enum: String;
  const EnumValues: Array of Variant);
var
  p: PfrPropRec;
  vv: Variant;
begin
  New(p);
  p^.PropName := PropName;
  p^.PropType := [frdtEnum];
  p^.PropEditor := nil;
  p^.Enum := TStringList.Create;
  frSetCommaText(Enum, p^.Enum);

  if TVarData(EnumValues[0]).VType = varArray + varVariant then
    vv := EnumValues[0] else
    vv := VarArrayOf(EnumValues);

  if vv[0] = Null then
    p^.EnumValues := Null else
    p^.EnumValues := vv;
  PropList.Add(p);
end;

procedure TfrObject.DelProperty(PropName: String);
var
  p: PfrPropRec;
begin
  p := PropRec[PropName];
  if p <> nil then
  begin
    PropList.Delete(PropList.IndexOf(p));
    Dispose(p);
  end;
end;

procedure TfrObject.DefineProperties;
begin
// abstract method
end;

procedure TfrObject.SetPropValue(Index: String; Value: Variant);
begin
// abstract method
end;

function TfrObject.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := Null;
end;

function TfrObject.GetPropValue(Index: String): Variant;
begin
  Result := Null;
end;

function TfrObject.GetPropRec(Index: String): PfrPropRec;
var
  i: Integer;
  p: PfrPropRec;
begin
  Result := nil;
  for i := 0 to PropList.Count - 1 do
  begin
    p := PropList[i];
    if AnsiCompareText(p^.PropName, Index) = 0 then
    begin
      Result := p;
      break;
    end;
  end;
end;

procedure TfrObject.SetFontProp(Font: TFont; Prop: String; Value: Variant);
begin
  if Prop = 'FONT.NAME' then
    Font.Name := Value
  else if Prop = 'FONT.SIZE' then
    Font.Size := Value
  else if Prop = 'FONT.STYLE' then
    Font.Style := frSetFontStyle(Value)
  else if Prop = 'FONT.COLOR' then
    Font.Color := Value
end;

function TfrObject.GetFontProp(Font: TFont; Prop: String): Variant;
begin
  Result := Null;
  if Prop = 'FONT.NAME' then
    Result := Font.Name
  else if Prop = 'FONT.SIZE' then
    Result := Font.Size
  else if Prop = 'FONT.STYLE' then
    Result := frGetFontStyle(Font.Style)
  else if Prop = 'FONT.COLOR' then
    Result := Font.Color
end;

function TfrObject.LinesMethod(Lines: TStrings; MethodName, LinesName: String;
  Par1, Par2, Par3: Variant): Variant;
begin
  if MethodName = 'SETINDEXPROPERTY' then
  begin
// Par1 is index property name (e.g. 'Lines')
// Par2 is index (e.g. 1)
// Par3 is value which you must assign to the index property
    if Par1 = LinesName then
      Lines[Par2] := Par3;
  end
  else if MethodName = 'GETINDEXPROPERTY' then
  begin
// Par1 is index property name
// Par2 is index
// Par3 is Null - don't use it
    if Par1 = LinesName then
      Result := Lines[Par2];
  end
  else if MethodName = LinesName + '.ADD' then
    Lines.Add(frParser.Calc(Par1))
  else if MethodName = LinesName + '.CLEAR' then
    Lines.Clear
  else if MethodName = LinesName + '.DELETE' then
    Lines.Delete(frParser.Calc(Par1))
  else if MethodName = LinesName + '.INDEXOF' then
    Result := Lines.IndexOf(frParser.Calc(Par1))
end;


{ TfrView }

constructor TfrView.Create;
begin
  inherited Create;
  Parent := nil;
  Memo := TStringList.Create;
  Memo1 := TStringList.Create;
  Script := TStringList.Create;
  FrameWidth := 1;
  FrameColor := clBlack;
  FillColor := clNone;
  Format := 2 * 256 + Ord(DecimalSeparator);
  BaseName := 'View';
  Visible := True;
  StreamMode := smFRF;
  ScaleX := 1; ScaleY := 1;
  OffsX := 0; OffsY := 0;
  Flags := flStretched;
  gapx := 2; gapy := 1;
  Typ := gtAddIn;
end;

destructor TfrView.Destroy;
begin
  Memo.Free;
  Memo1.Free;
  Script.Free;
  inherited Destroy;
end;

procedure TfrView.Assign(From: TfrView);
var
  Stream: TMemoryStream;
begin
  Name := From.Name;
  Typ := From.Typ;
  Selected := From.Selected;
  Stream := TMemoryStream.Create;
  frVersion := frCurrentVersion;
  From.StreamMode := smFRF;
  From.SaveToStream(Stream);
  Stream.Position := 0;
  StreamMode := smFRF;
  LoadFromStream(Stream);
  Stream.Free;
end;

procedure TfrView.DefineProperties;
begin
  ClearPropList;
  AddProperty('Name', [frdtString, frdtOneObject], nil);
  AddProperty('Left', [frdtSize], nil);
  AddProperty('Top', [frdtSize], nil);
  AddProperty('Width', [frdtSize], nil);
  AddProperty('Height', [frdtSize], nil);
  AddProperty('Flags', [], nil);
  if (ClassName <> 'TfrBandView') and (ClassName <> 'TfrSubReportView') then
  begin
    AddProperty('FrameTyp', [frdtInteger], nil);
    AddProperty('FrameWidth', [frdtSize, frdtFloat], nil);
    AddProperty('FrameColor', [frdtColor], nil);
    AddEnumProperty('FrameStyle',
      'psSolid;psDash;psDot;psDashDot;psDashDotDot;psDouble',
      [psSolid,psDash,psDot,psDashDot,psDashDotDot,psDouble]);
    AddProperty('FillColor', [frdtColor], nil);
    AddProperty('Tag', [frdtHasEditor, frdtOneObject], frTagEditor);
    AddEnumProperty('BandAlign',
      'baNone;baLeft;baRight;baCenter;baWidth;baBottom;baTop;baRest',
      [baNone,baLeft,baRight,baCenter,baWidth,baBottom,baTop,baRest]);
  end;
  AddProperty('Visible', [frdtBoolean], nil);
  AddProperty('Memo', [frdtOneObject, frdtHasEditor], frMemoEditor);
  AddProperty('Memo.Count', [], nil);
  AddProperty('Restrictions', [frdtHasEditor], frRestrEditor);
end;

procedure TfrView.SetPropValue(Index: String; Value: Variant);
begin
  Index := AnsiUpperCase(Index);
  if Index = 'NAME' then
    Name := Value
  else if Index = 'LEFT' then
    x := Value
  else if Index = 'TOP' then
    y := Value
  else if Index = 'WIDTH' then
    dx := Value
  else if Index = 'HEIGHT' then
    dy := Value
  else if Index = 'FLAGS' then
    Flags := Value
  else if Index = 'FRAMETYP' then
    FrameTyp := Value
  else if Index = 'FRAMEWIDTH' then
    FrameWidth := Value
  else if Index = 'FRAMECOLOR' then
    FrameColor := Value
  else if Index = 'FRAMESTYLE' then
    FrameStyle := Value
  else if Index = 'FILLCOLOR' then
    FillColor := Value
  else if Index = 'VISIBLE' then
    Visible := Value
  else if Index = 'MEMO' then
    Memo.Text := Value
  else if Index = 'GAPX' then
    gapx := Value
  else if Index = 'GAPY' then
    gapy := Value
  else if Index = 'STRETCHED' then
    Flags := (Flags and not flStretched) or Word(Boolean(Value)) * flStretched
  else if Index = 'BANDALIGN' then
    BandAlign := Value
  else if Index = 'DATAFIELD' then
    Memo.Text := Value
  else if Index = 'TAG' then
    Tag := Value
end;

function TfrView.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := Null;
  if Index = 'NAME' then
    Result := Name
  else if Index = 'LEFT' then
    Result := x
  else if Index = 'TOP' then
    Result := y
  else if Index = 'WIDTH' then
    Result := dx
  else if Index = 'HEIGHT' then
    Result := dy
  else if Index = 'FLAGS' then
    Result := Flags
  else if Index = 'FRAMETYP' then
    Result := FrameTyp
  else if Index = 'FRAMEWIDTH' then
    Result := FrameWidth
  else if Index = 'FRAMECOLOR' then
    Result := FrameColor
  else if Index = 'FRAMESTYLE' then
    Result := FrameStyle
  else if Index = 'FILLCOLOR' then
    Result := FillColor
  else if Index = 'VISIBLE' then
    Result := Visible
  else if Index = 'MEMO' then
    Result := Memo.Text
  else if Index = 'GAPX' then
    Result := gapx
  else if Index = 'GAPY' then
    Result := gapy
  else if Index = 'STRETCHED' then
    Result := (Flags and flStretched) <> 0
  else if Index = 'DATAFIELD' then
    if Memo.Count > 0 then
      Result := Memo[0] else
      Result := ''
  else if Index = 'BANDALIGN' then
    Result := BandAlign
  else if Index = 'MEMO.COUNT' then
    Result := Memo.Count
  else if Index = 'DATAFIELD' then
    Result := Memo.Text
  else if Index = 'TAG' then
    Result := Tag
end;

function TfrView.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if Result = Null then
    Result := LinesMethod(Memo, MethodName, 'MEMO', Par1, Par2, Par3);
  if MethodName = 'HIDE' then
    Prop['Visible'] := False
  else if MethodName = 'SHOW' then
    Prop['Visible'] := True;
end;

procedure TfrView.CalcGaps;
var
  bx, by, bx1, by1, wx1, wx2, wy1, wy2: Integer;
begin
  SaveX := x; SaveY := y; SaveDX := dx; SaveDY := dy;
  SaveFW := FrameWidth;
  SaveGX := gapx; SaveGY := gapy;
  if DocMode = dmDesigning then
  begin
    ScaleX := 1; ScaleY := 1;
    OffsX := 0; OffsY := 0;
  end;
  x := Round(x * ScaleX) + OffsX;
  y := Round(y * ScaleY) + OffsY;
  dx := Round(dx * ScaleX);
  dy := Round(dy * ScaleY);

  wx1 := Round((FrameWidth * ScaleX - 1) / 2);
  wx2 := Round(FrameWidth * ScaleX / 2);
  wy1 := Round((FrameWidth * ScaleY - 1) / 2);
  wy2 := Round(FrameWidth * ScaleY / 2);
  FrameWidth := FrameWidth * ScaleX;
  gapx := wx2 + Round(gapx * ScaleX); gapy := wy2 div 2 + Round(gapy * ScaleY);
  bx := x;
  by := y;
  bx1 := Round((SaveX + SaveDX) * ScaleX + OffsX);
  by1 := Round((SaveY + SaveDY) * ScaleY + OffsY);
  if (FrameTyp and $1) <> 0 then Dec(bx1, wx2);
  if (FrameTyp and $2) <> 0 then Dec(by1, wy2);
  if (FrameTyp and $4) <> 0 then Inc(bx, wx1);
  if (FrameTyp and $8) <> 0 then Inc(by, wy1);
  DRect := Rect(bx, by, bx1 + 1, by1 + 1);
end;

procedure TfrView.RestoreCoord;
begin
  x := SaveX;
  y := SaveY;
  dx := SaveDX;
  dy := SaveDY;
  FrameWidth := SaveFW;
  gapx := SaveGX;
  gapy := SaveGY;
end;

procedure TfrView.ShowBackground;
var
  fp: TColor;
begin
  if DisableDrawing then Exit;
  if (DocMode = dmPrinting) and (FillColor = clNone) then Exit;
  fp := FillColor;
  if (DocMode = dmDesigning) and (fp = clNone) then
    fp := clWhite;
  SetBkMode(Canvas.Handle, Opaque);
  Canvas.Brush.Color := fp;
  if DocMode = dmDesigning then
    Canvas.FillRect(DRect) else
    Canvas.FillRect(Rect(x, y,
// use calculating coords instead of dx, dy - for best view
      Round((SaveX + SaveDX) * ScaleX + OffsX), Round((SaveY + SaveDY) * ScaleY + OffsY)));
end;

procedure TfrView.ShowFrame;
var
  x1, y1: Integer;

  procedure Line(x, y, dx, dy: Integer);
  begin
    Canvas.MoveTo(x, y);
    Canvas.LineTo(x + dx, y + dy);
  end;

  procedure Line1(x, y, x1, y1: Integer);
  var
    i, w: Integer;
  begin
    if Canvas.Pen.Style = psSolid then
    begin
      if FrameStyle <> 5 then
      begin
        Canvas.MoveTo(x, y);
        Canvas.LineTo(x1, y1);
      end
      else
      begin
        if x = x1 then
        begin
          Canvas.MoveTo(x - Round(FrameWidth), y);
          Canvas.LineTo(x1 - Round(FrameWidth), y1);
          Canvas.Pen.Color := FillColor;
          Canvas.MoveTo(x, y);
          Canvas.LineTo(x1, y1);
          Canvas.Pen.Color := FrameColor;
          Canvas.MoveTo(x + Round(FrameWidth), y);
          Canvas.LineTo(x1 + Round(FrameWidth), y1);
        end
        else
        begin
          Canvas.MoveTo(x, y - Round(FrameWidth));
          Canvas.LineTo(x1, y1 - Round(FrameWidth));
          Canvas.Pen.Color := FillColor;
          Canvas.MoveTo(x, y);
          Canvas.LineTo(x1, y1);
          Canvas.Pen.Color := FrameColor;
          Canvas.MoveTo(x, y + Round(FrameWidth));
          Canvas.LineTo(x1, y1 + Round(FrameWidth));
        end;
      end
    end
    else
    begin
      Canvas.Brush.Color := FillColor;
      w := Canvas.Pen.Width;
      Canvas.Pen.Width := 1;
      if x = x1 then
        for i := 0 to w - 1 do
        begin
          Canvas.MoveTo(x - w div 2 + i, y);
          Canvas.LineTo(x - w div 2 + i, y1);
        end
      else
        for i := 0 to w - 1 do
        begin
          Canvas.MoveTo(x, y - w div 2 + i);
          Canvas.LineTo(x1, y - w div 2 + i);
        end;
      Canvas.Pen.Width := w;
    end;
  end;

begin
  if DisableDrawing then Exit;
  if (DocMode = dmPrinting) and ((FrameTyp and $F) = 0) then Exit;
  with Canvas do
  begin
    Brush.Style := bsSolid;
    Pen.Style := psSolid;
    if (dx > 0) and (dy > 0) and (DocMode = dmDesigning) then
    begin
      Pen.Color := clBlack;
      Pen.Width := 1;
      Line(x, y + 3, 0, -3); Line(x, y, 4, 0);
      Line(x, y + dy - 3, 0, 3); Line(x, y + dy, 4, 0);
      Line(x + dx - 3, y, 3, 0); Line(x + dx, y, 0, 4);
      Line(x + dx - 3, y + dy, 3, 0); Line(x + dx, y + dy, 0, -4);
    end;
    Pen.Color := FrameColor;
    Pen.Width := Round(FrameWidth);
    if FrameStyle <> 5 then
      Pen.Style := TPenStyle(FrameStyle);
// use calculating coords instead of dx, dy - for best view
    x1 := Round((SaveX + SaveDX) * ScaleX + OffsX);
    y1 := Round((SaveY + SaveDY) * ScaleY + OffsY);
{    if ((FrameTyp and $F) = $F) and (FrameStyle = 0) then
    begin
      Rectangle(x, y, x1 + 1, y1 + 1);
    end
    else}
    if (FrameTyp and $1) <> 0 then Line1(x1, y, x1, y1);
    if (FrameTyp and $4) <> 0 then Line1(x, y, x, y1);
    if (FrameTyp and $2) <> 0 then Line1(x, y1, x1, y1);
    if (FrameTyp and $8) <> 0 then Line1(x, y, x1, y);
  end;
end;

procedure TfrView.BeginDraw(ACanvas: TCanvas);
var
  lm, rm: Integer;
  t: TfrView;
  thePage : TfrPage;

  function GetLeftOffset: TfrView;
  var
    s: TStringList;
    theLObj: TfrView;
    i, yy: Integer;
  begin
    s := TStringList.Create;
    s.Sorted := True;
    s.Duplicates := dupAccept;
    for i := 0 to thePage.Objects.Count - 1 do
    begin
      theLObj := thePage.Objects[i];
      //need to see where we are for y comparison
      if (DocMode <> dmDesigning) then
      begin
        if (CurBand <> nil) and (CurPage <> nil) then
        begin
         if theLObj.Parent = CurPage.Bands[btNone] then
           yy := y  //objects that don't have band
         else
           yy := y - CurBand.y; //bands get pushed up and rearranged so adjust for y -TEST Band Order may be important
        end
        else
          yy := y;
      end
      else
        yy := y;

      if (theLObj.y = yy) and (theLObj.y + theLObj.dy >= yy + dy) and
        (theLObj.x < x) and(theLObj.Typ <> gtBand) and
        (theLObj.BandAlign = baLeft) then
        s.AddObject(SysUtils.Format('%4.4d', [theLObj.x]), theLObj);
    end; //end for loop getting all objects to left of current object

    if s.Count > 0 then
      Result := TfrView(s.Objects[s.Count - 1]) //want last on list
    else
      Result := nil;
    s.free;
  end;

  function GetRightOffset: TfrView;
  var
    s: TStringList;
    theObj: TfrView;
    i, yy: Integer;
  begin
    s := TStringList.Create;
    s.Sorted := True;
    s.Duplicates := dupAccept;
    for i := 0 to thePage.Objects.Count - 1 do
    begin
      theObj := thePage.Objects[i];
      if (DocMode <> dmDesigning) then
      begin
        if (CurBand <> nil) and (CurPage <> nil) then
        begin
          if theObj.Parent = CurPage.Bands[btNone] then
            yy := y
          else
            yy := y - CurBand.y;
        end
        else
          yy := y;
      end
      else
        yy := y;

      if (theObj.y = yy) and (theObj.y + theObj.dy >= yy + dy) and
        (theObj.x > x) and (theObj.Typ <> gtBand) and
        (theObj.BandAlign = baRight) then
        s.AddObject(SysUtils.Format('%4.4d', [theObj.x]), theObj);
    end;//end for loop getting all object on left

    if s.Count > 0 then
      Result := TfrView(s.Objects[0])//want first on list for leftmost Right obj
    else
      Result := nil;
    s.free;
  end;

begin
  Canvas := ACanvas;
  CurView := Self;
  if CurPage = nil then Exit;
  if DocMode = dmDesigning then
  begin
    lm := frDesigner.Page.LeftMargin;
    rm := frDesigner.Page.RightMargin;
    thePage := frDesigner.Page;
  end
  else
  begin
    lm := CurPage.LeftMargin;
    rm := CurPage.RightMargin;
    thePage := CurPage;
  end;

  if BandAlign = baLeft then
  begin
    t := GetLeftOffset;
    if t <> nil then
    begin
      x := t.x + t.dx;
      if t.x + t.dx > rm then
        dx := t.x - rm;
    end
    else
      x := lm;
  end
  else if BandAlign = baRight then
  begin
    t := GetRightOffset;
    if t <> nil then
      x := t.x - dx - 1 else
      x := rm - dx
  end
  else if BandAlign = baRest then
  begin
    t := GetLeftOffset;
    if t <> nil then
      x := t.x + t.dx else
      x := lm;
    t := GetRightOffset;
    if t <> nil then
      dx := t.x - x - 1 else
      dx := rm - x;
  end
  else if BandAlign = baCenter then
    x := lm + (rm - lm - dx) div 2
  else if BandAlign = baWidth then
  begin
    if DocMode = dmDesigning then
    begin
      t := ParentBand;
      if (t = nil) or not (TfrBandView(t).BandType in [btCrossHeader..btCrossFooter]) then
      begin
        x := lm;
        dx := rm - lm;
      end
      else
      begin
        x := t.x;
        dx := t.dx;
      end;
    end
    else if CurBand = nil then
    begin
      x := lm;
      dx := rm - lm - 1;
    end;
  end
  else if BandAlign = baBottom then
  begin
    if DocMode = dmDesigning then
    begin
      t := ParentBand;
      if t <> nil then
        y := t.y + t.dy - dy;
    end
  end
  else if BandAlign = baTop then
  begin
    if DocMode = dmDesigning then
    begin
      t := ParentBand;
      if t <> nil then
        y := t.y;
    end
  end;
end;

procedure TfrView.ExpandVariables(var s: String);
var
  i, j: Integer;
  s1, s2: String;
begin
  i := 1;
  repeat
    while (i < Length(s)) and (s[i] <> '[') do Inc(i);
    s1 := GetBrackedVariable(s, i, j);
    if i <> j then
    begin
      Delete(s, i, j - i + 1);
      s2 := '';
      CurReport.InternalOnGetValue(s1, s2);
      Insert(s2, s, i);
      Inc(i, Length(s2));
      j := 0;
    end;
  until i = j;
end;

procedure TfrView.StreamOut(Stream: TStream);
var
  SaveTag: String;
begin
  BeginDraw(Canvas);
  Memo1.Assign(Memo);
  CurReport.InternalOnEnterRect(Memo1, Self);
  frInterpretator.DoScript(Script);
  if not Visible then Exit;

  SaveTag := Tag;
  if (Tag <> '') and (Pos('[', Tag) <> 0) then
    ExpandVariables(Tag);

  if (BandAlign = baBottom) and (CurBand <> nil) then
    y := CurBand.y + CurBand.CalculatedHeight - dy;
  if (BandAlign = baTop) and (CurBand <> nil) then
    y := CurBand.y;
  if (BandAlign = baWidth) and (CurBand <> nil) and (CurBand.Typ in [btCrossHeader..btCrossFooter]) then
    dx := CurBand.dx;
  Stream.Write(Typ, 1);
  if Typ = gtAddIn then
    frWriteString(Stream, ClassName);
  SaveToStream(Stream);

  Tag := SaveTag;
end;

procedure TfrView.ExportData;
begin
  CurReport.InternalOnExportData(Self);
end;

procedure TfrView.LoadFromStream(Stream: TStream);
var
  w: Integer;
begin
  with Stream do
  begin
    if (frVersion > 23) or ((frVersion = 23) and (StreamMode = smFRF)) then
      Name := ReadString(Stream) else
      CreateUniqueName;
    if frVersion > 23 then
    begin
      Read(HVersion, 1);
      Read(LVersion, 1);
    end;
    Read(x, 30);
{    Read(x, 4); Read(y, 4); Read(dx, 4); Read(dy, 4);
    Read(Flags, 2); Read(FrameTyp, 2); Read(FrameWidth, 4);
    Read(FrameColor, 4); Read(FrameStyle, 2);}
    Read(FillColor, 4);
    if StreamMode = smFRF then
    begin
      Read(Format, 4);
      FormatStr := ReadString(Stream);
    end;
    ReadMemo(Stream, Memo);
    if (frVersion >= 23) and (StreamMode = smFRF) then
    begin
      ReadMemo(Stream, Script);
      Read(Visible, 2);
    end;
    if frVersion >= 24 then
    begin
      Read(Restrictions, 2);
      Tag := ReadString(Stream);
      Read(gapx, 8);
    end;
    w := PInteger(@FrameWidth)^;
    if w <= 10 then
      w := w * 1000;
    if HVersion > 1 then
      Read(BandAlign, 1);
    FrameWidth := w / 1000;
  end;
end;

procedure TfrView.SaveToStream(Stream: TStream);
var
  w: Integer;
  f: Single;
begin
  HVersion := 2;
  f := FrameWidth;
  if f <> Int(f) then
    w := Round(FrameWidth * 1000) else
    w := Round(f);
  PInteger(@FrameWidth)^ := w;
  with Stream do
  begin
    frWriteString(Stream, Name);
    Write(HVersion, 1);
    Write(LVersion, 1);
    Write(x, 30);
{    Write(x, 4); Write(y, 4); Write(dx, 4); Write(dy, 4);
    Write(Flags, 2); Write(FrameTyp, 2); Write(FrameWidth, 4);
    Write(FrameColor, 4); Write(FrameStyle, 2);}
    Write(FillColor, 4);
    if StreamMode = smFRF then
    begin
      Write(Format, 4);
      frWriteString(Stream, FormatStr);
      frWriteMemo(Stream, Memo);
    end
    else
      frWriteMemo(Stream, Memo1);
    if StreamMode = smFRF then
    begin
      frWriteMemo(Stream, Script);
      Write(Visible, 2);
    end;
    Write(Restrictions, 2);
    frWriteString(Stream, Tag);
    Write(gapx, 8);
    Write(BandAlign, 1);
  end;
  FrameWidth := f;
end;

procedure TfrView.Resized;
begin
end;

procedure TfrView.Loaded;
begin
end;

procedure TfrView.GetBlob(b: TfrTField);
begin
end;

procedure TfrView.OnHook(View: TfrView);
begin
end;

function TfrView.GetClipRgn(rt: TfrRgnType): HRGN;
var
  bx, by, bx1, by1, w1, w2: Integer;
begin
  if FrameStyle = 5 then
  begin
    w1 := Round(FrameWidth * 1.5);
    w2 := Round((FrameWidth - 1) / 2 + FrameWidth);
  end
  else
  begin
    w1 := Round(FrameWidth / 2);
    w2 := Round((FrameWidth - 1) / 2);
  end;
  bx := x; by := y; bx1 := x + dx + 1; by1 := y + dy + 1;
  if (FrameTyp and $1) <> 0 then Inc(bx1, w2);
  if (FrameTyp and $2) <> 0 then Inc(by1, w2);
  if (FrameTyp and $4) <> 0 then Dec(bx, w1);
  if (FrameTyp and $8) <> 0 then Dec(by, w1);
  if rt = rtNormal then
    Result := CreateRectRgn(bx, by, bx1, by1) else
    Result := CreateRectRgn(bx - 10, by - 10, bx1 + 10, by1 + 10);
end;

procedure TfrView.CreateUniqueName;
var
  i: Integer;

  function CheckUnique(Name: String): Boolean;
  begin
    Result := (CurReport.FindObject(Name) = nil) and
       (not (Self is TfrControl) or (frDialogForm.FindComponent(Name) = nil));
  end;

begin
  Name := '';
  for i := 1 to 10000 do
    if CheckUnique(BaseName + IntToStr(i)) then
    begin
      Prop['Name'] := BaseName + IntToStr(i);
      Exit;
    end;
end;

procedure TfrView.SetBounds(Left, Top, Width, Height: Integer);
begin
  x := Left;
  y := Top;
  dx := Width;
  dy := Height;
end;

procedure TfrView.ShowEditor;
begin
// abstract method
end;

function TfrView.ParentBand: TfrView;
var
  i: Integer;
  t: TfrView;
begin
  Result := nil;
  for i := 0 to frDesigner.Page.Objects.Count - 1 do
  begin
    t := frDesigner.Page.Objects[i];
    if (t.Typ = gtBand) and (x >= t.x) and (x <= t.x + t.dx) and
      (y >= t.y) and (y <= t.y + t.dy) then
      Result := t;
  end;
end;

procedure TfrView.DefinePopupMenu(Popup: TPopupMenu);
var
  m: TMenuItem;
begin
  m := TMenuItem.Create(Popup);
  m.Caption := '-';
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SStretched);
  m.OnClick := P1Click;
  m.Checked := (Flags and flStretched) <> 0;
  Popup.Items.Add(m);
end;

procedure TfrView.P1Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flStretched) + Word(Checked);
    end;
  end;
  frDesigner.AfterChange;
end;


{ TfrControl }

constructor TfrControl.Create;
begin
  inherited Create;
  Typ := gtAddIn;
  FillColor := clBtnFace;
  FrameTyp := 0;
end;

destructor TfrControl.Destroy;
begin
  inherited Destroy;
end;

procedure TfrControl.DefineProperties;
begin
  ClearPropList;
  AddProperty('Name', [frdtString, frdtOneObject], nil);
  AddProperty('Left', [frdtSize], nil);
  AddProperty('Top', [frdtSize], nil);
  AddProperty('Width', [frdtSize], nil);
  AddProperty('Height', [frdtSize], nil);
  AddProperty('Visible', [frdtBoolean], nil);
  AddProperty('Restrictions', [frdtHasEditor], frRestrEditor);
end;

procedure TfrControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'VISIBLE' then
    Control.Visible := Value;
end;

procedure TfrControl.PaintDesignControl;
var
  Bmp: TBitmap;
  MemDC: HDC;
  OldBitmap: HBITMAP;
begin
  Bmp := TBitmap.Create;
  Bmp.Width := dx + 1;
  Bmp.Height := dy + 1;
  Bmp.Canvas.Brush.Color := clBtnFace;
  Bmp.Canvas.FillRect(Rect(0, 0, dx + 1, dy + 1));
  Control.Left := 0;
  Control.Top := 0;
  if not frDialogForm.Visible then
    frDialogForm.Show;

  MemDC := CreateCompatibleDC(0);
  OldBitmap := SelectObject(MemDC, Bmp.Handle);
  if Control is TWinControl then
    Control.Perform(WM_PRINT, MemDC, PRF_CLIENT + PRF_ERASEBKGND + PRF_NONCLIENT)
  else
  begin
    Control.Perform(WM_ERASEBKGND, MemDC, MemDC);
    Control.Perform(WM_PAINT, MemDC, MemDC);
  end;
  SelectObject(MemDC, OldBitmap);
  DeleteDC(MemDC);

  Canvas.Draw(x, y, Bmp);
  Bmp.Free;
end;

procedure TfrControl.Draw(Canvas: TCanvas);
begin
  BeginDraw(Canvas);
  Control.Width := dx;
  Control.Height := dy;
  CalcGaps;
  PaintDesignControl;
  RestoreCoord;
end;

procedure TfrControl.PlaceControl(Form: TForm);
begin
  Control.Parent := Form;
  Control.SetBounds(x, y, dx, dy);
end;

procedure TfrControl.DefinePopupMenu(Popup: TPopupMenu);
begin
// no specific items in popup menu
end;


{ TfrNonVisualControl }

constructor TfrNonVisualControl.Create;
begin
  inherited Create;
  FFixupList := TfrVariables.Create;
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_NONVISUALCOMPONENT');
  dx := 28;
  dy := 28;
end;

destructor TfrNonVisualControl.Destroy;
begin
  FFixupList.Free;
  Bmp.Free;
  inherited Destroy;
end;

procedure TfrNonVisualControl.DefineProperties;
begin
  ClearPropList;
  AddProperty('Name', [frdtString, frdtOneObject], nil);
  AddProperty('Restrictions', [frdtHasEditor], frRestrEditor);
end;

procedure TfrNonVisualControl.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'NAME' then
    Component.Name := Value;
end;

procedure TfrNonVisualControl.PaintDesignControl;
begin
  DrawEdge(Canvas.Handle, DRect, EDGE_RAISED, BF_RECT);
  Canvas.Draw(DRect.Left + 2, DRect.Top + 2, Bmp);
end;

procedure TfrNonVisualControl.Draw(Canvas: TCanvas);
begin
  dx := 28;
  dy := 28;
  BeginDraw(Canvas);
  CalcGaps;
  FillColor := clBtnFace;
  ShowBackground;
  PaintDesignControl;
  RestoreCoord;
end;

procedure TfrNonVisualControl.PlaceControl(Form: TForm);
begin
//  Control.Parent := Form;
//  Control.SetBounds(x, y, dx, dy);
end;


{ TfrMemoView }

constructor TfrMemoView.Create;
begin
  inherited Create;
  Typ := gtMemo;
  FFont := TFont.Create;
  FFont.Name := 'Arial';
  FFont.Size := 10;
  FFont.Color := clBlack;
{$IFNDEF Delphi2}
  FFont.Charset := frCharset;
{$ENDIF}
  Highlight.FontColor := clBlack;
  Highlight.FillColor := clWhite;
  Highlight.FontStyle := 2; // fsBold
  BaseName := 'Memo';
  Flags := flStretched + flWordWrap;
  LineSpacing := 2;
  CharacterSpacing := 0;
end;

destructor TfrMemoView.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TfrMemoView.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Font.Name', [], nil);
  AddProperty('Font.Size', [], nil);
  AddProperty('Font.Style', [], nil);
  AddProperty('Font.Color', [], nil);
  AddProperty('Font', [frdtHasEditor], frFontEditor);
  AddProperty('Alignment', [], nil);
  AddProperty('DisplayFormat', [frdtHasEditor], P1Click);
  AddProperty('Highlight', [frdtHasEditor], frHighlightEditor);
  AddProperty('LineSpacing', [frdtInteger], nil);
  AddProperty('CharSpacing', [frdtInteger], nil);
  AddProperty('GapX', [frdtInteger], nil);
  AddProperty('GapY', [frdtInteger], nil);
  AddProperty('Stretched', [frdtBoolean], nil);
  AddProperty('WordWrap', [frdtBoolean], nil);
  AddProperty('WordBreak', [frdtBoolean], nil);
  AddProperty('AutoWidth', [frdtBoolean], nil);
  AddProperty('TextOnly', [frdtBoolean], nil);
  AddProperty('Suppress', [frdtBoolean], nil);
  AddProperty('HideZeros', [frdtBoolean], nil);
  AddProperty('Lines.Count', [], nil);
  AddProperty('Underlines', [frdtBoolean], nil);
  AddProperty('RTLReading', [frdtBoolean], nil);
end;

procedure TfrMemoView.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  SetFontProp(Font, Index, Value);
  if Index = 'ALIGNMENT' then
    Alignment := Value
  else if Index = 'LINESPACING' then
    LineSpacing := Value
  else if Index = 'CHARSPACING' then
    CharacterSpacing := Value
  else if Index = 'WORDWRAP' then
    Flags := (Flags and not flWordWrap) or Word(Boolean(Value)) * flWordWrap
  else if Index = 'WORDBREAK' then
    Flags := (Flags and not flWordBreak) or Word(Boolean(Value)) * flWordBreak
  else if Index = 'AUTOWIDTH' then
    Flags := (Flags and not flAutoSize) or Word(Boolean(Value)) * flAutoSize
  else if Index = 'TEXTONLY' then
    Flags := (Flags and not flTextOnly) or Word(Boolean(Value)) * flTextOnly
  else if Index = 'SUPPRESS' then
    Flags := (Flags and not flSuppressRepeated) or Word(Boolean(Value)) * flSuppressRepeated
  else if Index = 'HIDEZEROS' then
    Flags := (Flags and not flHideZeros) or Word(Boolean(Value)) * flHideZeros
  else if Index = 'UNDERLINES' then
    Flags := (Flags and not flUnderlines) or Word(Boolean(Value)) * flUnderlines
  else if Index = 'RTLREADING' then
    Flags := (Flags and not flRTLReading) or Word(Boolean(Value)) * flRTLReading
end;

function TfrMemoView.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  Result := GetFontProp(Font, Index);
  if Index = 'ALIGNMENT' then
    Result := Alignment
  else if Index = 'LINESPACING' then
    Result := LineSpacing
  else if Index = 'CHARSPACING' then
    Result := CharacterSpacing
  else if Index = 'WORDWRAP' then
    Result := (Flags and flWordWrap) <> 0
  else if Index = 'WORDBREAK' then
    Result := (Flags and flWordBreak) <> 0
  else if Index = 'AUTOWIDTH' then
    Result := (Flags and flAutoSize) <> 0
  else if Index = 'TEXTONLY' then
    Result := (Flags and flTextOnly) <> 0
  else if Index = 'SUPPRESS' then
    Result := (Flags and flSuppressRepeated) <> 0
  else if Index = 'HIDEZEROS' then
    Result := (Flags and flHideZeros) <> 0
  else if Index = 'LINES.COUNT' then
    Result := Memo.Count
  else if Index = 'UNDERLINES' then
    Result := (Flags and flUnderlines) <> 0
  else if Index = 'RTLREADING' then
    Result := (Flags and flRTLReading) <> 0
end;

function TfrMemoView.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if Result = Null then
    Result := LinesMethod(Memo, MethodName, 'LINES', Par1, Par2, Par3);
end;

procedure TfrMemoView.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TfrMemoView.ExpandMemoVariables;
var
  i: Integer;
  s: String;
begin
  Memo1.Clear;
  for i := 0 to Memo.Count - 1 do
  begin
    s := Memo[i];
    if (s <> '') and ((Flags and flTextOnly) = 0) then ExpandVariables(s);
    if s <> '' then
      Memo1.Text := Memo1.Text + s else
      Memo1.Add('');
  end;
end;

procedure TfrMemoView.AssignFont(Canvas: TCanvas);
begin
  with Canvas do
  begin
    SetBkMode(Handle, Transparent);
    Font := Self.Font;
    if not IsPrinting then
      if ScaleY = 1 then
        Font.Height := -Round(Font.Size * 96 / 72 * ScaleY) else
        Font.Height := -Trunc(Font.Size * 96 / 72 * ScaleY);
  end;
end;


type
  TWordBreaks = string;

const
  gl: set of Char = ['А', 'Е', 'Ё', 'И', 'О', 'У', 'Ы', 'Э', 'Ю', 'Я'];
  r_sogl: set of Char = ['Ъ', 'Ь'];
  spaces: set of Char = [' ', '.', ',', '-'];

function BreakWord(s: String): TWordBreaks;
var
  i: Integer;
  CanBreak: Boolean;
begin
  Result := '';
  s := AnsiUpperCase(s);
  if Length(s) >= 4 then
  begin
    i := 2;
    repeat
      CanBreak := False;
      if s[i] in gl then
      begin
        if (s[i + 1] in gl) or (s[i + 2] in gl) then CanBreak := True;
      end
      else
      begin
        if not (s[i + 1] in gl) and not (s[i + 1] in r_sogl) and
           (s[i + 2] in gl) then
          CanBreak := True;
      end;
      if CanBreak then
        Result := Result + Chr(i);
      Inc(i);
    until i > Length(s) - 2;
  end;
end;

procedure TfrMemoView.WrapMemo;
var
  size, size1, maxwidth: Integer;
  b: TWordBreaks;
  WCanvas: TCanvas;

  procedure OutLine(const str: String);
  begin
    SMemo.Add(str);
    Inc(size, size1);
  end;

  procedure WrapLine(const s: String);
  var
    i, cur, beg, last, LoopPos: Integer;
    WasBreak, CRLF: Boolean;
  begin
    CRLF := False;
    LoopPos := 0;
    for i := 1 to Length(s) do
      if s[i] in [#10, #13] then
      begin
        CRLF := True;
        break;
      end;
    last := 1; beg := 1;
    if not CRLF and ((Length(s) <= 1) or (WCanvas.TextWidth(s) <= maxwidth)) then
      OutLine(s + #1)
    else
    begin
      cur := 1;
      while cur <= Length(s) do
      begin
        if s[cur] in [#10, #13] then
        begin
          OutLine(Copy(s, beg, cur - beg) + #1);
          while (cur < Length(s)) and (s[cur] in [#10, #13]) do Inc(cur);
          beg := cur; last := beg;
          if s[cur] in [#13, #10] then
            Exit else
            continue;
        end;
        if s[cur] <> ' ' then
        if WCanvas.TextWidth(Copy(s, beg, cur - beg + 1)) > maxwidth then
        begin
          WasBreak := False;
          if (Flags and flWordBreak) <> 0 then
          begin
            i := cur;
            while (i <= Length(s)) and not (s[i] in spaces) do
              Inc(i);
            b := BreakWord(Copy(s, last + 1, i - last - 1));
            if Length(b) > 0 then
            begin
              i := 1;
              cur := last;
              while (i <= Length(b)) and
                (WCanvas.TextWidth(Copy(s, beg, last - beg + 1 + Ord(b[i])) + '-') <= maxwidth) do
              begin
                WasBreak := True;
                cur := last + Ord(b[i]);
                Inc(i);
              end;
              last := cur;
            end;
          end
          else
            if last = beg then last := cur;
          if WasBreak then
            OutLine(Copy(s, beg, last - beg + 1) + '-')
          else if s[last] = ' ' then
            OutLine(Copy(s, beg, last - beg)) else
          begin
            OutLine(Copy(s, beg, last - beg));
            Dec(last);
          end;
          if ((Flags and flWordBreak) <> 0) and not WasBreak and (last = cur - 1) then
            if LoopPos = cur then
            begin
              beg := cur + 1;
              cur := Length(s);
              break;
            end
            else
              LoopPos := cur;
          beg := last + 1; last := beg;
        end;
//        if s[cur] in spaces then last := cur;
        if s[cur] = ' ' then last := cur;
        Inc(cur);
      end;
      if beg <> cur then OutLine(Copy(s, beg, cur - beg + 1) + #1);
    end;
  end;

  procedure OutMemo;
  var
    i: Integer;
  begin
    size := y + gapy;
    size1 := -WCanvas.Font.Height + LineSpacing;
    maxwidth := dx - gapx - gapx;

    if (DocMode = dmDesigning) and (Memo1.Count = 1) and
       (WCanvas.TextWidth(Memo1[0]) > maxwidth) and
       (Memo1[0] <> '') and (Memo1[0][1] = '[') then
      OutLine(Memo1[0])
    else
      for i := 0 to Memo1.Count - 1 do
        if FWrapped then
          OutLine(Memo1[i])
        else
          if (Flags and flWordWrap) <> 0 then
            WrapLine(Memo1[i]) else
            OutLine(Memo1[i] + #1);
    VHeight := size - y + gapy;
    TextHeight := size1;
  end;

  procedure OutMemo90;
  var
    i: Integer;
    h, oldh: HFont;
  begin
    h := Create90Font(WCanvas.Font);
    oldh := SelectObject(WCanvas.Handle, h);
    size := x + gapx;
    size1 := -WCanvas.Font.Height + LineSpacing;
    maxwidth := dy - gapy - gapy;
    for i := 0 to Memo1.Count - 1 do
      if FWrapped then
        OutLine(Memo1[i])
      else
        if (Flags and flWordWrap) <> 0 then
          WrapLine(Memo1[i]) else
          OutLine(Memo1[i]);
    SelectObject(WCanvas.Handle, oldh);
    DeleteObject(h);

    VHeight := size - x + gapx;
    TextHeight := size1;
  end;

begin
  WCanvas := TempBmp.Canvas;
  WCanvas.Font.Assign(Font);
  WCanvas.Font.Height := -Round(Font.Size * 96 / 72);
  SetTextCharacterExtra(WCanvas.Handle, CharacterSpacing);
  SMemo.Clear;
  if (Alignment and $4) <> 0 then OutMemo90 else OutMemo;
end;

procedure TfrMemoView.ShowMemo;
var
  DR: TRect;
  ad, ox, oy: Integer;

  procedure StrOut(const Str: String; curx, cury: Integer; bVertText: Boolean);
  var
    f: Integer;
  begin
    f := ETO_CLIPPED;
    if (Flags and flRTLReading) <> 0 then
      f := f or ETO_RTLREADING;
    ExtTextOut(Canvas.Handle, curx, cury, f, @DR,
      PChar(str), Length(str), nil)
  end;

  procedure OutMemo;
  var
    i, cury, th, SaveAlign: Integer;

    function OutLine(str: String): Boolean;
    var
      i, n, curx: Integer;
      ParaEnd: Boolean;

      procedure DrawText;
      begin
        StrOut(str, curx, cury, False);
      end;

    begin
      if not Streaming or (cury + th <= DR.Bottom) then
      begin
        ParaEnd := True;
        if Length(str) > 0 then
          if str[Length(str)] = #1 then
            SetLength(str, Length(str) - 1) else
            ParaEnd := False;

        if Alignment <> 3 then
        begin
          if Alignment = 0 then
            curx := x + gapx
          else if Alignment = 1 then
            curx := x + {dx}(DRect.Right - DRect.Left) - 1 - gapx - Canvas.TextWidth(str)
          else
            curx := x + gapx + ({dx}(DRect.Right - DRect.Left) - gapx - gapx - Canvas.TextWidth(str)) div 2;

          if not Exporting then
            DrawText;
        end
        else
        begin
          curx := x + gapx;
          if not Exporting then
          begin
            n := 0;
            for i := 1 to Length(str) do
              if str[i] = ' ' then Inc(n);
            if (n <> 0) and not ParaEnd then
              SetTextJustification(Canvas.Handle,
                {dx}(DRect.Right - DRect.Left) - gapx - gapx - Canvas.TextWidth(str), n);

            DrawText;
            SetTextJustification(Canvas.Handle, 0, 0);
          end;
        end;
        if Exporting then
        begin
          n := FrameTyp;
          if not ((CurStrNo = 0) and (Memo1.Count = 1)) then
            if (CurStrNo = 0) and (CurStrNo <> Memo1.Count - 1) then
              n := n and not frftBottom
            else if (CurStrNo = Memo1.Count - 1) and (CurStrNo <> 0) then
              n := n and not frftTop
            else
              n := (n and not frftTop) and not frftBottom;
          CurReport.InternalOnExportText(DRect, curx, cury, str, n, Self);
        end;
        Inc(CurStrNo);
        Result := False;
      end
      else Result := True;
      Inc(cury, th)
    end;

  begin
    cury := y + gapy;
    th := -Canvas.Font.Height + Round(LineSpacing * ScaleY);
    CurStrNo := 0;
{    if Exporting and (cury > DR.Top + th) then
    begin
      n := (cury - DR.Top) div th;
      for i := 0 to n - 1 do
        Memo1.Insert(0, '');
    end;}
{    if Exporting and (th * Memo1.Count < DR.Bottom - DR.Top - th) then
    begin
      n := (DR.Bottom - DR.Top - th * Memo1.Count) div th;
      for i := 0 to n - 1 do
        Memo1.Add('');
    end;}

    SaveAlign := Alignment;
    if (DocMode = dmDesigning) and (Memo1.Count = 1) and
       (Canvas.TextWidth(Memo1[0]) > DR.Right - DR.Left) and
       (Memo1[0][1] = '[') then
      Alignment := 1;

    for i := 0 to Memo1.Count - 1 do
      if OutLine(Memo1[i]) then
        break;
    Alignment := SaveAlign;
  end;

  procedure OutMemo90;
  var
    i, th, curx: Integer;
    h, oldh: HFont;

    procedure OutLine(str: String);
    var
      i, n, cury: Integer;
      ParaEnd: Boolean;
    begin
      ParaEnd := True;
      if Length(str) > 0 then
        if str[Length(str)] = #1 then
          SetLength(str, Length(str) - 1) else
          ParaEnd := False;

      cury := 0;
      if Alignment = 4 then
        cury := DRect.Bottom - gapy
      else if Alignment = 5 then
        cury := y + gapy + Canvas.TextWidth(str)
      else if Alignment = 6 then
        cury := DRect.Bottom - 1 - gapy -
          ({dy}(DRect.Bottom - DRect.Top - gapy - gapy) - Canvas.TextWidth(str)) div 2
      else if not Exporting then
      begin
        cury := y + {dy}(DRect.Bottom - DRect.Top) - gapy;
        n := 0;
        for i := 1 to Length(str) do
          if str[i] = ' ' then Inc(n);
        if (n <> 0) and not ParaEnd then
          SetTextJustification(Canvas.Handle,
            {dy}(DRect.Bottom - DRect.Top) - gapy - gapy - Canvas.TextWidth(str), n);
      end;
      if not Exporting then
      begin
        StrOut(str, curx, cury, True);
        if Alignment <> 7 then
          SetTextJustification(Canvas.Handle, 0, 0);
      end;
      if Exporting then
        CurReport.InternalOnExportText(DRect, curx, cury, str, 0, Self);
      Inc(CurStrNo);
      Inc(curx, th);
    end;
  begin
    h := Create90Font(Canvas.Font);
    oldh := SelectObject(Canvas.Handle,h);
    curx := x + gapx;
    th := -Canvas.Font.Height + Round(LineSpacing * ScaleX);
    CurStrNo := 0;
    for i := 0 to Memo1.Count - 1 do
      OutLine(Memo1[i]);
    SelectObject(Canvas.Handle, oldh);
    DeleteObject(h);
  end;

begin
  AssignFont(Canvas);
  SetTextCharacterExtra(Canvas.Handle, Round(CharacterSpacing * ScaleX));
  DR := Rect(DRect.Left + 1, DRect.Top, DRect.Right - 2, DRect.Bottom - 1);
  VHeight := Round(VHeight * ScaleY);
  if (Alignment and $18) <> 0 then
  begin
    ad := Alignment;
    ox := x; oy := y;
    Alignment := Alignment and $7;
    if (ad and $4) <> 0 then
    begin
      if (ad and $18) = $8 then
        x := x + ({dx}(DRect.Right - DRect.Left) - VHeight) div 2
      else if (ad and $18) = $10 then
        x := DRect.Right - VHeight;
      OutMemo90;
    end
    else
    begin
      if not Streaming then
        if (ad and $18) = $8 then
          y := y + ({dy}(DRect.Bottom - DRect.Top) - VHeight) div 2
        else if (ad and $18) = $10 then
          y := DRect.Bottom - VHeight - 1;
      OutMemo;
    end;
    Alignment := ad;
    x := ox; y := oy;
  end
  else if (Alignment and $4) <> 0 then OutMemo90 else OutMemo;
end;

procedure TfrMemoView.ShowUnderLines;
var
  i, n, h1, h2: Integer;
begin
  if (Flags and flUnderlines) = 0 then Exit;
  AssignFont(Canvas);
  with Canvas do
  begin
    Pen.Color := FrameColor;
    Pen.Width := Round(FrameWidth);
    Pen.Style := psSolid;
  end;
  h1 := -Canvas.Font.Height + Round(LineSpacing * ScaleY);
  h2 := -Canvas.Font.Height + Round(2 * ScaleY);
  n := dy div h1;
  for i := 1 to n do
  with Canvas do
  begin
    MoveTo(x, y + gapy + (i - 1) * h1 + h2);
    LineTo(x + dx - 1, y + gapy + (i - 1) * h1 + h2);
  end;
end;

function TfrMemoView.CalcWidth(Memo: TStringList): Integer;
var
  CalcRect: TRect;
  s: String;
  i, n: Integer;
begin
  CalcRect := Rect(0, 0, dx, dy);
  s := Memo.Text;
  i := 1;
  if Pos(#1, s) <> 0 then
    while i < Length(s) do
    begin
      if s[i] = #1 then
        Delete(s, i, 1) else
        Inc(i);
    end;
  n := Length(s);
  if n > 2 then
    if (s[n - 1] = #13) and (s[n] = #10) then
      SetLength(s, n - 2);
  AssignFont(Canvas);
  SetTextCharacterExtra(Canvas.Handle, Round(CharacterSpacing * ScaleX));
  DrawText(Canvas.Handle, PChar(s), Length(s), CalcRect, DT_CALCRECT);
  Result := Round(CalcRect.Right / ScaleX + FrameWidth + 2 * gapx + 1);
end;

procedure TfrMemoView.Draw(Canvas: TCanvas);
var
  newdx: Integer;
  OldScaleX, OldScaleY: Double;
begin
  Self.Canvas := Canvas;
  if ((Flags and flAutoSize) <> 0) and (Memo.Count > 0) and
     (DocMode <> dmDesigning) then
  begin
    newdx := CalcWidth(Memo);
    if (Alignment and frtaVertical) <> 0 then
    begin
      dy := newdx;
    end
    else if (Alignment and frtaRight) <> 0 then
    begin
      x := x + dx - newdx;
      dx := newdx;
    end
    else
      dx := newdx;
  end;

  BeginDraw(Canvas);
  Streaming := False;
  Memo1.Assign(Memo);

  if Memo1.Count > 0 then
  begin
    FWrapped := Pos(#1, Memo1.Text) <> 0;
    if Memo1[Memo1.Count - 1] = #1 then
      Memo1.Delete(Memo1.Count - 1);
    OldScaleX := ScaleX; OldScaleY := ScaleY;
    ScaleX := 1; ScaleY := 1;
    CalcGaps;
    if ((Flags and flAutoSize) <> 0) and (DocMode <> dmDesigning) then
      dx := dx + 100;
    WrapMemo;
    ScaleX := OldScaleX; ScaleY := OldScaleY;
    RestoreCoord;
    Memo1.Assign(SMemo);
  end;

  CalcGaps;
  if not Exporting then
  begin
    ShowBackground;
    ShowFrame;
    ShowUnderLines;
  end;
  if Memo1.Count > 0 then
    ShowMemo;
  SetTextCharacterExtra(Canvas.Handle, 0);
  RestoreCoord;
end;

procedure TfrMemoView.StreamOut(Stream: TStream);
var
  s: String;
  CanExpandVar: Boolean;
  OldFont: TFont;
  OldFill: Integer;
  i: Integer;
  SaveTag: String;
  SaveFmt: Integer;
  SaveAlign: Byte;
begin
  BeginDraw(TempBmp.Canvas);
  Streaming := True;

  if DrawMode = drAll then
    frInterpretator.DoScript(Script);

  CanExpandVar := True;
  if (DrawMode = drAll) and Assigned(CurReport.OnBeforePrint) then
  begin
    Memo1.Assign(Memo);
    s := Memo1.Text;
    CurReport.InternalOnEnterRect(Memo1, Self);
    if s <> Memo1.Text then CanExpandVar := False;
  end
  else if DrawMode = drAfterCalcHeight then
    CanExpandVar := False;
  if DrawMode <> drPart then
    if CanExpandVar then ExpandMemoVariables;

  if not Visible then
  begin
    DrawMode := drAll;
    Exit;
  end;

{  if ((Flags and flAutoSize) <> 0) and (Memo1.Count > 0) then
    dx := CalcWidth(Memo1);}

  OldFont := TFont.Create;
  OldFont.Assign(Font);
  OldFill := FillColor;
  if HighlightStr <> '' then
    try
      if frParser.CalcOPZ(HighlightStr) <> 0 then
      begin
        Font.Style := frSetFontStyle(Highlight.FontStyle);
        Font.Color := Highlight.FontColor;
        FillColor := Highlight.FillColor;
      end;
    except
    end;

  if DrawMode = drPart then
  begin
    CalcGaps;
    ShowMemo;
    SMemo.Assign(Memo1);
    while Memo1.Count > CurStrNo do
      Memo1.Delete(CurStrNo);
    if Pos(#1, Memo1.Text) = 0 then
      Memo1.Add(#1);
    RestoreCoord;
  end;

  SaveTag := Tag;
  SaveFmt := Format;
  SaveAlign := BandAlign;
  Format := 0;
  if (Tag <> '') and (Pos('[', Tag) <> 0) then
    ExpandVariables(Tag);
  Format := SaveFmt;

  if (BandAlign = baBottom) and (CurBand <> nil) then
    y := CurBand.y + CurBand.CalculatedHeight - dy;
  if (BandAlign = baTop) and (CurBand <> nil) then
    y := CurBand.y;
  if (BandAlign = baWidth) and (CurBand <> nil) and (CurBand.Typ in [btCrossHeader..btCrossFooter]) then
  begin
    dx := CurBand.dx;
    BandAlign := baNone;
  end;

  if ((Flags and flSuppressRepeated) = 0) or (Memo1.Text <> LastValue) then
  begin
    Stream.Write(Typ, 1);
    if Typ = gtAddIn then
      frWriteString(Stream, ClassName);
    SaveToStream(Stream);
    if (Flags and flSuppressRepeated) <> 0 then
      LastValue := Memo1.Text;
  end;

  if DrawMode = drPart then
  begin
    Memo1.Assign(SMemo);
    for i := 0 to CurStrNo - 1 do
      Memo1.Delete(0);
  end;
  Font.Assign(OldFont);
  OldFont.Free;
  FillColor := OldFill;
  Tag := SaveTag;
  BandAlign := SaveAlign;
  DrawMode := drAll;
end;

procedure TfrMemoView.ExportData;
begin
  inherited;
  Exporting := True;
  Draw(TempBmp.Canvas);
  Exporting := False;
end;

function TfrMemoView.CalcHeight: Integer;
var
  s: String;
  CanExpandVar: Boolean;
  OldFont: TFont;
  OldFill: Integer;
begin
  Result := 0;
  DrawMode := drAfterCalcHeight;
  BeginDraw(TempBmp.Canvas);
  frInterpretator.DoScript(Script);
  if not Visible then Exit;

  CanExpandVar := True;
  Memo1.Assign(Memo);
  s := Memo1.Text;
  CurReport.InternalOnEnterRect(Memo1, Self);
  if s <> Memo1.Text then CanExpandVar := False;
  if CanExpandVar then ExpandMemoVariables;

  OldFont := TFont.Create;
  OldFont.Assign(Font);
  OldFill := FillColor;
  if HighlightStr <> '' then
    try
      if frParser.CalcOPZ(HighlightStr) <> 0 then
      begin
        Font.Style := frSetFontStyle(Highlight.FontStyle);
        Font.Color := Highlight.FontColor;
        FillColor := Highlight.FillColor;
      end;
    except
    end;

  CalcGaps;
  if Memo1.Count <> 0 then
  begin
    WrapMemo;
    Memo1.Assign(SMemo);
    Result := VHeight;
  end;
  RestoreCoord;
  Font.Assign(OldFont);
  OldFont.Free;
  FillColor := OldFill;
end;

function TfrMemoView.MinHeight: Integer;
begin
  Result := TextHeight;
end;

function TfrMemoView.RemainHeight: Integer;
begin
  Result := Memo1.Count * TextHeight;
end;

procedure TfrMemoView.LoadFromStream(Stream: TStream);
var
  w: Word;
  i: Integer;
  {!!! считывание типа парента из потока}
  fTyp: TfrBandType;
  {!!!}
begin
  inherited LoadFromStream(Stream);
  Font.Name := ReadString(Stream);
  with Stream do
  begin
    Read(i, 4);
    Font.Size := i;
    Read(w, 2);
    Font.Style := frSetFontStyle(w);
    Read(i, 4);
    Font.Color := i;
    Read(Alignment, 4);
    Read(w, 2);
    if frVersion < 23 then
      w := frCharset;
{$IFNDEF Delphi2}
    Font.Charset := w;
{$ENDIF}
    if StreamMode = smFRF then
    begin
      Read(Highlight, 10);
      HighlightStr := ReadString(Stream);
    end;
    if frVersion >= 24 then
      Read(LineSpacing, 8);
  {!!!!!!! считываение типа парента из потока}
    Read(fTyp, sizeof(fTyp));
    FParentType := fTyp;
  {!!!!!!!}
  end;
  if frVersion = 21 then
    Flags := Flags or flWordWrap;
end;

procedure TfrMemoView.SaveToStream(Stream: TStream);
var
  i: Integer;
  w: Word;
  {!!!!! Добавлено для сохранения в потоке типа парента}
  fTyp: TfrBandType;
  {!!!!!!}
begin
  inherited SaveToStream(Stream);
  frWriteString(Stream, Font.Name);
  with Stream do
  begin
    i := Font.Size;
    Write(i, 4);
    w := frGetFontStyle(Font.Style);
    Write(w, 2);
    i := Font.Color;
    Write(i, 4);
    Write(Alignment, 4);
{$IFDEF Delphi2}
    w := frCharset;
{$ELSE}
    w := Font.Charset;
{$ENDIF}
    Write(w, 2);
    if StreamMode = smFRF then
    begin
      Write(Highlight, 10);
      frWriteString(Stream, HighlightStr);
    end;
    Write(LineSpacing, 8);
  {!!!!!!! Сохранение в потоке типа парента}
    if Parent <> nil then
      fTyp := Parent.Typ
    else
      fTyp := btNone;
    Write(fTyp, sizeof(fTyp));
  {!!!!!!!!!!}
  end;
end;

procedure TfrMemoView.GetBlob(b: TfrTField);
begin
  frAssignBlobTo(b, Memo1);
end;

procedure TfrMemoView.ShowEditor;
begin
  frMemoEditor(nil);
end;

procedure TfrMemoView.DefinePopupMenu(Popup: TPopupMenu);
var
  m: TMenuItem;
begin
  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SVarFormat);
  m.OnClick := P1Click;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SFont);
  m.OnClick := frFontEditor;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SClearContents);
  m.OnClick := P6Click;
  Popup.Items.Add(m);
  inherited DefinePopupMenu(Popup);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SWordWrap);
  m.OnClick := P2Click;
  m.Checked := (Flags and flWordWrap) <> 0;
  Popup.Items.Add(m);

  if frLoadStr(SWordBreak) <> '' then
  begin
    m := TMenuItem.Create(Popup);
    m.Caption := frLoadStr(SWordBreak);
    m.OnClick := P3Click;
    m.Enabled := (Flags and flWordWrap) <> 0;
    if m.Enabled then
      m.Checked := (Flags and flWordBreak) <> 0;
    Popup.Items.Add(m);
  end;

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SAutoSize);
  m.OnClick := P5Click;
  m.Checked := (Flags and flAutoSize) <> 0;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(STextOnly);
  m.OnClick := P8Click;
  m.Checked := (Flags and flTextOnly) <> 0;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SSuppressRepeated);
  m.OnClick := P9Click;
  m.Checked := (Flags and flSuppressRepeated) <> 0;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SHideZeros);
  m.OnClick := P10Click;
  m.Checked := (Flags and flHideZeros) <> 0;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SUnderlines);
  m.OnClick := P11Click;
  m.Checked := (Flags and flUnderlines) <> 0;
  Popup.Items.Add(m);
end;

procedure TfrMemoView.P1Click(Sender: TObject);
var
  t: TfrView;
  i: Integer;
begin
  frDesigner.BeforeChange;
  with TfrFmtForm.Create(nil) do
  begin
    Format := Self.Format;
    FormatStr := Self.FormatStr;
    if ShowModal = mrOk then
      for i := 0 to frDesigner.Page.Objects.Count - 1 do
      begin
        t := frDesigner.Page.Objects[i];
        if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        begin
          (t as TfrMemoView).Format := Format;
          (t as TfrMemoView).FormatStr := FormatStr;
        end;
      end;
    Free;
  end;
end;

procedure TfrMemoView.P2Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flWordWrap) + Word(Checked) * flWordWrap;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrMemoView.P3Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flWordBreak) + Word(Checked) * flWordBreak;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrMemoView.P5Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flAutoSize) + Word(Checked) * flAutoSize;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrMemoView.P6Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  for i := 0 to frDesigner.Page.Objects.Count - 1 do
  begin
    t := frDesigner.Page.Objects[i];
    if t.Selected and ((t.Restrictions and frrfDontEditContents) = 0) then
    begin
      t.Memo.Clear;
      t.Script.Clear;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrMemoView.P8Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flTextOnly) + Word(Checked) * flTextOnly;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrMemoView.P9Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flSuppressRepeated) + Word(Checked) * flSuppressRepeated;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrMemoView.P10Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flHideZeros) + Word(Checked) * flHideZeros;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrMemoView.P11Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flUnderlines) + Word(Checked) * flUnderlines;
    end;
  end;
  frDesigner.AfterChange;
end;


{ TfrBandView }

constructor TfrBandView.Create;
begin
  inherited Create;
  Typ := gtBand;
  Format := 0;
  BaseName := 'Band';
  Flags := flBandOnFirstPage + flBandOnLastPage;
  Columns := 1;
  ColumnWidth := 200;
  ColumnGap := 20;
  NewColumnAfter := 1;
end;

procedure TfrBandView.DefineProperties;
var
  b: TfrBandType;
  p: PfrPropRec;

  function GetChildBands: String;
  var
    i: Integer;
    t: TfrView;
  begin
    Result := '';
    if DocMode <> dmDesigning then Exit;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if (t.Name <> Name) and (t is TfrBandView) and
         (t.FrameTyp = Integer(btChild)) then
        Result := Result + t.Name + ';';
    end;
  end;

  function GetDataBands: String;
  var
    i: Integer;
    t: TfrView;
  begin
    Result := '';
    if DocMode <> dmDesigning then Exit;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if (t.Name <> Name) and (t is TfrBandView) and
         (TfrBandType(t.FrameTyp) in [btMasterData, btDetailData, btSubDetailData]) then
        Result := Result + t.Name + ';';
    end;
  end;

begin
  inherited DefineProperties;
  b := TfrBandType(FrameTyp);
  if b <> btPageFooter then
  begin
    AddEnumProperty('ChildBand', GetChildBands, [Null]);
    AddProperty('PrintChildIfInvisible', [frdtBoolean], nil);
  end;
  if b in [btReportTitle, btReportSummary, btPageHeader, btCrossHeader,
    btMasterHeader..btSubDetailFooter, btGroupHeader, btGroupFooter, btChild] then
    AddProperty('Stretched', [frdtBoolean], nil);
  if b in [btReportTitle, btReportSummary, btMasterData, btDetailData,
    btSubDetailData, btMasterFooter, btDetailFooter,
    btSubDetailFooter, btGroupHeader] then
    AddProperty('FormNewPage', [frdtBoolean], nil);
  if b in [btMasterData, btDetailData] then
    AddProperty('PrintIfSubsetEmpty', [frdtBoolean], nil);
  if b in [btReportTitle, btReportSummary, btMasterHeader..btSubDetailFooter,
    btGroupHeader, btGroupFooter, btChild] then
    AddProperty('Breaked', [frdtBoolean], nil);
  if b in [btPageHeader, btPageFooter] then
    AddProperty('OnFirstPage', [frdtBoolean], nil);
  if b = btPageFooter then
    AddProperty('OnLastPage', [frdtBoolean], nil);
  if b in [btMasterHeader, btDetailHeader, btSubDetailHeader,
    btCrossHeader, btGroupHeader] then
    AddProperty('RepeatHeader', [frdtBoolean], nil);
  if b = btCrossData then
    AddProperty('DataSource', [frdtHasEditor], frCrossDataSourceEditor);
  if b in [btMasterData, btDetailData, btSubDetailData] then
  begin
    AddProperty('Columns', [frdtInteger], nil);
    AddProperty('ColumnWidth', [frdtSize], nil);
    AddProperty('ColumnGap', [frdtSize], nil);
    AddProperty('DataSource', [frdtHasEditor], frDataSourceEditor);
  end;
  if b = btGroupHeader then
  begin
    AddProperty('Condition', [frdtString], nil);
    AddEnumProperty('Master', GetDataBands, [Null]);
  end;
  AddProperty('EOF', [], nil);
  p := PropRec['Memo'];
  p^.PropName := 'OnBeforePrint';
end;

procedure TfrBandView.SetPropValue(Index: String; Value: Variant);
var
  b: TfrView;
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'CHILDBAND' then
  begin
    if DocMode = dmPrinting then
    begin
      b := CurPage.FindObject(Value);
      if b <> nil then
        Parent.Child := b.Parent else
        Parent.Child := nil;
    end;
    ChildBand := Value;
  end
  else if Index = 'MASTER' then
    Master := Value
  else if Index = 'FORMNEWPAGE' then
    Flags := (Flags and not flBandNewPageAfter) or Word(Boolean(Value)) * flBandNewPageAfter
  else if Index = 'PRINTIFSUBSETEMPTY' then
    Flags := (Flags and not flBandPrintIfSubsetEmpty) or Word(Boolean(Value)) * flBandPrintIfSubsetEmpty
  else if Index = 'BREAKED' then
    Flags := (Flags and not flBandBreaked) or Word(Boolean(Value)) * flBandBreaked
  else if Index = 'ONFIRSTPAGE' then
    Flags := (Flags and not flBandOnFirstPage) or Word(Boolean(Value)) * flBandOnFirstPage
  else if Index = 'ONLASTPAGE' then
    Flags := (Flags and not flBandOnLastPage) or Word(Boolean(Value)) * flBandOnLastPage
  else if Index = 'REPEATHEADER' then
    Flags := (Flags and not flBandRepeatHeader) or Word(Boolean(Value)) * flBandRepeatHeader
  else if Index = 'PRINTCHILDIFINVISIBLE' then
    Flags := (Flags and not flBandPrintChildIfInvisible) or Word(Boolean(Value)) * flBandPrintChildIfInvisible
  else if Index = 'CONDITION' then
  begin
    GroupCondition := Value;
    if DocMode = dmPrinting then
      Parent.GroupCondition := Value
  end
  else if Index = 'COLUMNS' then
    Columns := Value
  else if Index = 'COLUMNGAP' then
    ColumnGap := Value
  else if Index = 'COLUMNWIDTH' then
    ColumnWidth := Value
  else if Index = 'NEWCOLUMNAFTER' then
    NewColumnAfter := Value
  else if DocMode = dmPrinting then
    if Index = 'LEFT' then
      Parent.x := Value
    else if Index = 'TOP' then
      Parent.y := Value
    else if Index = 'WIDTH' then
      Parent.dx := Value
    else if Index = 'HEIGHT' then
      Parent.dy := Value
    else if Index = 'VISIBLE' then
      Parent.Visible := Value
    else if Index = 'DATASOURCE' then
    begin
      Parent.FreeDataSet;
      Parent.InitDataSet(Value);
    end;
end;

function TfrBandView.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Index = 'LEFT' then
  begin
    if DocMode = dmPrinting then
      Result := Parent.x
  end
  else if Index = 'TOP' then
  begin
    if DocMode = dmPrinting then
      Result := Parent.y
  end
  else if Index = 'WIDTH' then
  begin
    if DocMode = dmPrinting then
      Result := Parent.dx
  end
  else if Index = 'HEIGHT' then
  begin
    if DocMode = dmPrinting then
      Result := Parent.dy
  end
  else if Index = 'VISIBLE' then
  begin
    if DocMode = dmPrinting then
      Result := Parent.Visible
  end;
  if Result <> Null then Exit;
  if Index = 'CHILDBAND' then
    Result := ChildBand
  else if Index = 'MASTER' then
    Result := Master
  else if Index = 'EOF' then
    Result := Parent.DataSet.Eof
  else if Index = 'FORMNEWPAGE' then
    Result := (Flags and flBandNewPageAfter) <> 0
  else if Index = 'PRINTIFSUBSETEMPTY' then
    Result := (Flags and flBandPrintIfSubsetEmpty) <> 0
  else if Index = 'BREAKED' then
    Result := (Flags and flBandBreaked) <> 0
  else if Index = 'ONFIRSTPAGE' then
    Result := (Flags and flBandOnFirstPage) <> 0
  else if Index = 'ONLASTPAGE' then
    Result := (Flags and flBandOnLastPage) <> 0
  else if Index = 'REPEATHEADER' then
    Result := (Flags and flBandRepeatHeader) <> 0
  else if Index = 'PRINTCHILDIFINVISIBLE' then
    Result := (Flags and flBandPrintChildIfInvisible) <> 0
  else if Index = 'CONDITION' then
    Result := GroupCondition
  else if Index = 'COLUMNS' then
    Result := Columns
  else if Index = 'COLUMNGAP' then
    Result := ColumnGap
  else if Index = 'NEWCOLUMNAFTER' then
    Result := NewColumnAfter
  else if Index = 'COLUMNWIDTH' then
    Result := ColumnWidth;
end;

function TfrBandView.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if (Parent <> nil) and (Parent.Dataset <> nil) then
    if MethodName = 'NEXT' then
      Parent.Dataset.Next
    else if MethodName = 'PRIOR' then
      Parent.Dataset.Prior
    else if MethodName = 'FIRST' then
      Parent.Dataset.First
end;

function TfrBandView.GetRectangleWidth: Integer;
begin
  with TempBmp.Canvas do
  begin
    Font.Name := 'Arial';
    Font.Style := [];
    Font.Size := 8;
    SetTextCharacterExtra(Handle, 0);
    Result := TextWidth(frBandNames[FrameTyp]) + 8;
    if Result < 100 then
      Result := 100;
  end;
end;

procedure TfrBandView.Draw(Canvas: TCanvas);
var
  h, oldh: HFont;
  i, RWidth: Integer;
begin
  FrameWidth := 1;
  if TfrBandType(FrameTyp) in [btCrossHeader..btCrossFooter] then
  begin
    y := 0; dy := frDesigner.Page.PrnInfo.Pgh;
  end
  else
  begin
    x := 0; dx := frDesigner.Page.PrnInfo.Pgw;
  end;
  BeginDraw(Canvas);
  CalcGaps;
  with Canvas do
  begin
    Brush.Bitmap := SBmp;
    FillRect(DRect);
    Font.Name := 'Arial';
    Font.Style := [];
    Font.Size := 8;
    Font.Color := clBlack;
{$IFNDEF Delphi2}
    Font.Charset := frCharset;
{$ENDIF}
    Pen.Style := psSolid;
    Pen.Width := 1;
    Pen.Color := clBtnFace;
    Brush.Style := bsClear;
    Rectangle(x, y, x + dx + 1, y + dy + 1);
    if Columns > 1 then
    begin
      Pen.Style := psDot;
      Pen.Color := clBlack;
      for i := 1 to Columns do
        Rectangle(frDesigner.Page.LeftMargin + (i - 1) * (ColumnWidth + ColumnGap), y,
          frDesigner.Page.LeftMargin + (i - 1) * (ColumnWidth + ColumnGap) + ColumnWidth, y + dy);
    end;
    Pen.Style := psSolid;
    Pen.Color := clBtnFace;
    Brush.Color := clBtnFace;

    RWidth := GetRectangleWidth;
    if ShowBandTitles then
      if TfrBandType(FrameTyp) in [btCrossHeader..btCrossFooter] then
      begin
        FillRect(Rect(x - 18, y, x, y + RWidth));
        Pen.Color := clBtnShadow;
        MoveTo(x - 18, y + RWidth - 2); LineTo(x, y + RWidth - 2);
        Pen.Color := clBlack;
        MoveTo(x - 18, y + RWidth - 1); LineTo(x, y + RWidth - 1);
        Pen.Color := clBtnHighlight;
        MoveTo(x - 18, y + RWidth - 1); LineTo(x - 18, y);
        h := Create90Font(Font);
        oldh := SelectObject(Handle, h);
        TextOut(x - 15, y + TextWidth(frBandNames[FrameTyp]) + 4, frBandNames[FrameTyp]);
        SelectObject(Handle, oldh);
        DeleteObject(h);
      end
      else
      begin
        FillRect(Rect(x, y - 18, x + RWidth, y));
        Pen.Color := clBtnShadow;
        MoveTo(x + RWidth - 2, y - 18); LineTo(x + RWidth - 2, y);
        Pen.Color := clBlack;
        MoveTo(x + RWidth - 1, y - 18); LineTo(x + RWidth - 1, y);
        TextOut(x + 4, y - 17, frBandNames[FrameTyp]);
      end
    else
    begin
      Brush.Style := bsClear;
      if TfrBandType(FrameTyp) in [btCrossHeader..btCrossFooter] then
      begin
        h := Create90Font(Font);
        oldh := SelectObject(Handle, h);
        TextOut(x + 2, y + 94, frBandNames[FrameTyp]);
        SelectObject(Handle, oldh);
        DeleteObject(h);
      end
      else
        TextOut(x + 4, y + 2, frBandNames[FrameTyp]);
    end;
  end;
end;

function TfrBandView.GetClipRgn(rt: TfrRgnType): HRGN;
var
  R: HRGN;
begin
  if not ShowBandTitles then
  begin
    Result := inherited GetClipRgn(rt);
    Exit;
  end;
  if rt = rtNormal then
    Result := CreateRectRgn(x, y, x + dx + 1, y + dy + 1) else
    Result := CreateRectRgn(x - 10, y - 10, x + dx + 10, y + dy + 10);
  if TfrBandType(FrameTyp) in [btCrossHeader..btCrossFooter] then
    R := CreateRectRgn(x - 18, y, x, y + GetRectangleWidth)
  else
    R := CreateRectRgn(x, y - 18, x + GetRectangleWidth, y);
  CombineRgn(Result, Result, R, RGN_OR);
  DeleteObject(R);
end;

procedure TfrBandView.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  if frVersion > 23 then
  begin
    ChildBand := frReadString(Stream);
    Stream.Read(Columns, 16);
    if HVersion * 10 + LVersion > 20 then
      Master := frReadString(Stream);
  end;
end;

procedure TfrBandView.SaveToStream(Stream: TStream);
begin
  LVersion := 1;
  inherited SaveToStream(Stream);
  frWriteString(Stream, ChildBand);
  Stream.Write(Columns, 16);
  frWriteString(Stream, Master);
end;

procedure TfrBandView.DefinePopupMenu(Popup: TPopupMenu);
var
  m: TMenuItem;
  b: TfrBandType;
begin
  b := TfrBandType(FrameTyp);
  if b in [btReportTitle, btReportSummary, btPageHeader, btCrossHeader,
    btMasterHeader..btSubDetailFooter, btGroupHeader, btGroupFooter, btChild] then
    inherited DefinePopupMenu(Popup)
  else if b = btPageFooter then
  begin
    m := TMenuItem.Create(Popup);
    m.Caption := '-';
    Popup.Items.Add(m);
  end;

  if b in [btReportTitle, btReportSummary, btMasterData, btDetailData,
    btSubDetailData, btMasterFooter, btDetailFooter,
    btSubDetailFooter, btGroupHeader] then
  begin
    m := TMenuItem.Create(Popup);
    m.Caption := frLoadStr(SFormNewPage);
    m.OnClick := P1Click;
    m.Checked := (Flags and flBandNewPageAfter) <> 0;
    Popup.Items.Add(m);
  end;

  if b in [btMasterData, btDetailData] then
  begin
    m := TMenuItem.Create(Popup);
    m.Caption := frLoadStr(SPrintIfSubsetEmpty);
    m.OnClick := P2Click;
    m.Checked := (Flags and flBandPrintIfSubsetEmpty) <> 0;
    Popup.Items.Add(m);
  end;

  if b in [btReportTitle, btReportSummary, btMasterHeader..btSubDetailFooter,
    btGroupHeader, btGroupFooter, btChild] then
  begin
    m := TMenuItem.Create(Popup);
    m.Caption := frLoadStr(SBreaked);
    m.OnClick := P3Click;
    m.Checked := (Flags and flBandBreaked) <> 0;
    Popup.Items.Add(m);
  end;

  if b in [btPageHeader, btPageFooter] then
  begin
    m := TMenuItem.Create(Popup);
    m.Caption := frLoadStr(SOnFirstPage);
    m.OnClick := P4Click;
    m.Checked := (Flags and flBandOnFirstPage) <> 0;
    Popup.Items.Add(m);
  end;

  if b = btPageFooter then
  begin
    m := TMenuItem.Create(Popup);
    m.Caption := frLoadStr(SOnLastPage);
    m.OnClick := P5Click;
    m.Checked := (Flags and flBandOnLastPage) <> 0;
    Popup.Items.Add(m);
  end;

  if b in [btMasterHeader, btDetailHeader, btSubDetailHeader,
    btCrossHeader, btGroupHeader] then
  begin
    m := TMenuItem.Create(Popup);
    m.Caption := frLoadStr(SRepeatHeader);
    m.OnClick := P6Click;
    m.Checked := (Flags and flBandRepeatHeader) <> 0;
    Popup.Items.Add(m);
  end;

  if b <> btPageFooter then
  begin
    m := TMenuItem.Create(Popup);
    m.Caption := frLoadStr(SPrintChild);
    m.OnClick := P7Click;
    m.Checked := (Flags and flBandPrintChildIfInvisible) <> 0;
    Popup.Items.Add(m);
  end;
end;

procedure TfrBandView.P1Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flBandNewPageAfter) +
          Word(Checked) * flBandNewPageAfter;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrBandView.P2Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flBandPrintifSubsetEmpty) +
          Word(Checked) * flBandPrintifSubsetEmpty;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrBandView.P3Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flBandBreaked) + Word(Checked) * flBandBreaked;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrBandView.P4Click(Sender: TObject);
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    if (Restrictions and frrfDontModify) = 0 then
      Flags := (Flags and not flBandOnFirstPage) + Word(Checked) * flBandOnFirstPage;
  end;
  frDesigner.AfterChange;
end;

procedure TfrBandView.P5Click(Sender: TObject);
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    if (Restrictions and frrfDontModify) = 0 then
      Flags := (Flags and not flBandOnLastPage) + Word(Checked) * flBandOnLastPage;
  end;
  frDesigner.AfterChange;
end;

procedure TfrBandView.P6Click(Sender: TObject);
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    if (Restrictions and frrfDontModify) = 0 then
      Flags := (Flags and not flBandRepeatHeader) + Word(Checked) * flBandRepeatHeader;
  end;
  frDesigner.AfterChange;
end;

procedure TfrBandView.P7Click(Sender: TObject);
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    if (Restrictions and frrfDontModify) = 0 then
      Flags := (Flags and not flBandPrintChildIfInvisible) + Word(Checked) * flBandPrintChildIfInvisible;
  end;
  frDesigner.AfterChange;
end;

function TfrBandView.GetBandType: TfrBandType;
begin
  Result := TfrBandType(FrameTyp);
end;

procedure TfrBandView.SetBandType(const Value: TfrBandType);
begin
  FrameTyp := Integer(Value);
end;


{ TfrSubReportView }

constructor TfrSubReportView.Create;
begin
  inherited Create;
  Typ := gtSubReport;
  BaseName := 'SubReport';
end;

procedure TfrSubReportView.Draw(Canvas: TCanvas);
begin
  BeginDraw(Canvas);
  FrameWidth := 1;
  CalcGaps;
  with Canvas do
  begin
    Font.Name := 'Arial';
    Font.Style := [];
    Font.Size := 8;
    Font.Color := clBlack;
{$IFNDEF Delphi2}
    Font.Charset := frCharset;
{$ENDIF}
    Pen.Width := 1;
    Pen.Color := clBlack;
    Pen.Style := psSolid;
    Brush.Color := clWhite;
    Rectangle(x, y, x + dx + 1, y + dy + 1);
    Brush.Style := bsClear;
    TextRect(DRect, x + 2, y + 2, Name{frLoadStr(SSubReportOnPage) + ' ' +
      IntToStr(SubPage + 1)});
  end;
  RestoreCoord;
end;

procedure TfrSubReportView.DefinePopupMenu(Popup: TPopupMenu);
begin
  // no specific items in popup menu
end;

procedure TfrSubReportView.LoadFromStream(Stream: TStream);
begin
  inherited LoadFromStream(Stream);
  Stream.Read(SubPage, 4);
end;

procedure TfrSubReportView.SaveToStream(Stream: TStream);
begin
  inherited SaveToStream(Stream);
  Stream.Write(SubPage, 4);
end;


{ TfrPictureView }

constructor TfrPictureView.Create;
begin
  inherited Create;
  Typ := gtPicture;
  Picture := TPicture.Create;
  Flags := flStretched + flPictRatio;
  BaseName := 'Picture';
  frConsts['btBMP'] := 0; frConsts['btJPG'] := 1;
  frConsts['btICO'] := 2; frConsts['btWMF'] := 3;
end;

destructor TfrPictureView.Destroy;
begin
  Picture.Free;
  inherited Destroy;
end;

procedure TfrPictureView.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Picture', [frdtHasEditor], frPictureEditor);
  AddProperty('Stretched', [frdtBoolean], nil);
  AddProperty('Center', [frdtBoolean], nil);
  AddProperty('KeepAspect', [frdtBoolean], nil);
  AddProperty('DataField', [frdtOneObject, frdtHasEditor, frdtString], frFieldEditor);
  AddEnumProperty('BlobType', 'btBMP;btJPG;btICO;btWMF', [0,1,2,3]);
end;

procedure TfrPictureView.SetPropValue(Index: String; Value: Variant);
begin
  inherited SetPropValue(Index, Value);
  Index := AnsiUpperCase(Index);
  if Index = 'CENTER' then
    Flags := (Flags and not flPictCenter) or Word(Boolean(Value)) * flPictCenter
  else if Index = 'KEEPASPECT' then
    Flags := (Flags and not flPictRatio) or Word(Boolean(Value)) * flPictRatio
  else if Index = 'BLOBTYPE' then
    BlobType := Value
end;

function TfrPictureView.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := inherited GetPropValue(Index);
  if Result <> Null then Exit;
  if Index = 'CENTER' then
    Result := (Flags and flPictCenter) <> 0
  else if Index = 'KEEPASPECT' then
    Result := (Flags and flPictRatio) <> 0
  else if Index = 'BLOBTYPE' then
    Result := BlobType
end;

function TfrPictureView.DoMethod(MethodName: String; Par1, Par2, Par3: Variant): Variant;
var
  s: String;
begin
  Result := inherited DoMethod(MethodName, Par1, Par2, Par3);
  if MethodName = 'LOADFROMFILE' then
  begin
    s := frParser.Calc(Par1);
    if ((s <> '') and FileExists(s)) then
      Picture.LoadFromFile(s) else
      Picture.Bitmap := nil;  
  end;
end;

procedure TfrPictureView.Draw(Canvas: TCanvas);
var
  r: TRect;
  kx, ky: Double;
  w, h, w1, h1: Integer;
  Bmp: TBitmap;

  procedure PrintGraphic(Canvas: TCanvas; DestRect: TRect; aGraph: TGraphic);
  var
    BitmapHeader: pBitmapInfo;
    BitmapImage : Pointer;
    HeaderSize  : DWORD;     // D3/D4 compatibility
    ImageSize   : DWORD;
    Bitmap      : TBitmap;
  begin
    if not IsPrinting then
    begin
      Canvas.StretchDraw(DestRect, aGraph);
      Exit;
    end;

    if aGraph is TMetaFile then
    begin
      Canvas.StretchDraw(DestRect, aGraph);
      Exit;
    end;
    if aGraph is TBitmap then
    begin
      Bitmap := TBitmap(aGraph);
{$IFNDEF Delphi2}
      Bitmap.PixelFormat := pf24Bit;
{$ENDIF}
    end
    else
    begin
      Bitmap := TBitmap.Create;
      Bitmap.Width := aGraph.Width;
      Bitmap.Height := aGraph.Height;
{$IFNDEF Delphi2}
      Bitmap.PixelFormat := pf24Bit;
{$ENDIF}
      Bitmap.Canvas.Draw(0, 0, aGraph);
    end;

    try
      GetDIBSizes(Bitmap.Handle, HeaderSize, ImageSize);
      GetMem(BitmapHeader, HeaderSize);
      GetMem(BitmapImage,  ImageSize);
      try
        SetStretchBltMode(Canvas.Handle, STRETCH_DELETESCANS);
        GetDIB(Bitmap.Handle, Bitmap.Palette, BitmapHeader^, BitmapImage^);
        StretchDIBits(Canvas.Handle,
                    DestRect.Left, DestRect.Top,     {Destination Origin}
                    DestRect.Right  - DestRect.Left, {Destination Width}
                    DestRect.Bottom - DestRect.Top,  {Destination Height}
                    0, 0,                            {Source Origin}
                    Bitmap.Width, Bitmap.Height,     {Source Width & Height}
                    BitmapImage,
                    TBitmapInfo(BitmapHeader^),
                    DIB_RGB_COLORS,
                    SRCCOPY)
      finally
        FreeMem(BitmapHeader);
        FreeMem(BitmapImage);
      end;
    finally
      if not (aGraph is TBitmap) then
        Bitmap.Free
    end;
  end;

begin
  BeginDraw(Canvas);
  CalcGaps;
  with Canvas do
  begin
    ShowBackground;
    if ((Picture.Graphic = nil) or Picture.Graphic.Empty) and (DocMode = dmDesigning) then
    begin
      Font.Name := 'Arial';
      Font.Size := 8;
      Font.Style := [];
      Font.Color := clBlack;
{$IFNDEF Delphi2}
      Font.Charset := frCharset;
{$ENDIF}
      TextRect(DRect, x + 20, y + 3, frLoadStr(SPicture));
      Bmp := TBitmap.Create;
      Bmp.Handle := LoadBitmap(hInstance, 'FR_EMPTY');
      Draw(x + 1, y + 2, Bmp);
      Bmp.Free;
    end
    else if not ((Picture.Graphic = nil) or Picture.Graphic.Empty) then
    begin
      if (Flags and flStretched) <> 0 then
      begin
        r := DRect;
        if (Flags and flPictRatio) <> 0 then
        begin
          kx := dx / Picture.Width;
          ky := dy / Picture.Height;
          if kx < ky then
            r := Rect(DRect.Left, DRect.Top,
              DRect.Right, DRect.Top + Round(Picture.Height * kx))
          else
            r := Rect(DRect.Left, DRect.Top,
              DRect.Left + Round(Picture.Width * ky), DRect.Bottom);
          w := DRect.Right - DRect.Left;
          h := DRect.Bottom - DRect.Top;
          w1 := r.Right - r.Left;
          h1 := r.Bottom - r.Top;
          if (Flags and flPictCenter) <> 0 then
            OffsetRect(r, (w - w1) div 2, (h - h1) div 2);
        end;
        PrintGraphic(Canvas, r, Picture.Graphic);
      end
      else
      begin
        r := DRect;
        if (Flags and flPictCenter) <> 0 then
        begin
          w := DRect.Right - DRect.Left;
          h := DRect.Bottom - DRect.Top;
          OffsetRect(r, (w - Round(ScaleX * Picture.Width)) div 2,
            (h - Round(ScaleY * Picture.Height)) div 2);
        end;
        r.Right := r.Left + Round(Picture.Width * ScaleX);
        r.Bottom := r.Top + Round(Picture.Height * ScaleY);
        PrintGraphic(Canvas, r, Picture.Graphic);
      end;
    end;
    ShowFrame;
  end;
  RestoreCoord;
end;

const
  pkNone = 0;
  pkBitmap = 1;
  pkMetafile = 2;
  pkIcon = 3;
  pkJPEG = 4;

procedure TfrPictureView.LoadFromStream(Stream: TStream);
var
  b: Byte;
  n: Integer;
  Graphic: TGraphic;
  TempStream: TMemoryStream;
begin
  inherited LoadFromStream(Stream);
  Stream.Read(b, 1);
  if HVersion * 10 + LVersion > 10 then
    Stream.Read(BlobType, 1);
  Stream.Read(n, 4);
  Graphic := nil;
  case b of
    pkBitmap:   Graphic := TBitmap.Create;
    pkMetafile: Graphic := TMetafile.Create;
    pkIcon:     Graphic := TIcon.Create;
{$IFDEF JPEG}
    pkJPEG:     Graphic := TJPEGImage.Create;
{$ENDIF}
  end;
  Picture.Graphic := Graphic;
  if Graphic <> nil then
  begin
    Graphic.Free;
    TempStream := TMemoryStream.Create;
    TempStream.CopyFrom(Stream, n - Stream.Position);
    TempStream.Position := 0;
    Picture.Graphic.LoadFromStream(TempStream);
    TempStream.Free;
  end;
  Stream.Seek(n, soFromBeginning);
end;

procedure TfrPictureView.SaveToStream(Stream: TStream);
var
  b: Byte;
  n, o: Integer;
begin
  inherited SaveToStream(Stream);
  b := pkNone;
  if Picture.Graphic <> nil then
    if Picture.Graphic is TBitmap then
      b := pkBitmap
    else if Picture.Graphic is TMetafile then
      b := pkMetafile
    else if Picture.Graphic is TIcon then
      b := pkIcon
{$IFDEF JPEG}
    else if Picture.Graphic is TJPEGImage then
      b := pkJPEG
{$ENDIF};
  Stream.Write(b, 1);
  Stream.Write(BlobType, 1);
  n := Stream.Position;
  Stream.Write(n, 4);
  if b <> pkNone then
    Picture.Graphic.SaveToStream(Stream);
  o := Stream.Position;
  Stream.Seek(n, soFromBeginning);
  Stream.Write(o, 4);
  Stream.Seek(0, soFromEnd);
end;

{$HINTS OFF}
procedure TfrPictureView.GetBlob(b: TfrTField);
var
  Graphic: TGraphic;
  bs: TMemoryStream;
begin
  Graphic := nil;
  case BlobType of
    0: Graphic := TBitmap.Create;
{$IFDEF JPEG}
    1: Graphic := TJPEGImage.Create;
{$ENDIF}
    2: Graphic := TMetafile.Create;
    3: Graphic := TIcon.Create;
  end;
  Picture.Graphic := Graphic;
  if Graphic <> nil then
    Graphic.Free;
  if b.IsNull then
    Picture.Assign(nil)
  else if BlobType <> 0 then
  begin
    bs := TMemoryStream.Create;
    frAssignBlobTo(b, bs);
    Picture.Graphic.LoadFromStream(bs);
    bs.Free;
  end
  else
    frAssignBlobTo(b, Picture);
end;
{$HINTS ON}

procedure TfrPictureView.ShowEditor;
begin
  frPictureEditor(nil);
end;

procedure TfrPictureView.DefinePopupMenu(Popup: TPopupMenu);
var
  m: TMenuItem;
begin
  inherited DefinePopupMenu(Popup);
  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SPictureCenter);
  m.OnClick := P1Click;
  m.Checked := (Flags and flPictCenter) <> 0;
  Popup.Items.Add(m);

  m := TMenuItem.Create(Popup);
  m.Caption := frLoadStr(SKeepAspectRatio);
  m.OnClick := P2Click;
  m.Enabled := (Flags and flStretched) <> 0;
  if m.Enabled then
    m.Checked := (Flags and flPictRatio) <> 0;
  Popup.Items.Add(m);
end;

procedure TfrPictureView.P1Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flPictCenter) + Word(Checked) * flPictCenter;
    end;
  end;
  frDesigner.AfterChange;
end;

procedure TfrPictureView.P2Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  frDesigner.BeforeChange;
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    for i := 0 to frDesigner.Page.Objects.Count - 1 do
    begin
      t := frDesigner.Page.Objects[i];
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
        t.Flags := (t.Flags and not flPictRatio) + Word(Checked) * flPictRatio;
    end;
  end;
  frDesigner.AfterChange;
end;


{ TfrLineView }

constructor TfrLineView.Create;
begin
  inherited Create;
  Typ := gtLine;
  FrameTyp := 4;
  FillColor := clWhite;
  BaseName := 'Line';
end;

procedure TfrLineView.DefineProperties;
begin
  inherited DefineProperties;
  AddProperty('Stretched', [frdtBoolean], nil);
end;

procedure TfrLineView.Draw(Canvas: TCanvas);
begin
  BeginDraw(Canvas);
  if dx > dy then
  begin
    dy := 0;
    FrameTyp := 8;
  end
  else
  begin
    dx := 0;
    FrameTyp := 4;
  end;
  CalcGaps;
  ShowFrame;
  RestoreCoord;
end;

procedure TfrLineView.StreamOut(Stream: TStream);
begin
  inherited StreamOut(Stream);
  if DrawMode = drPart then
    Dec(FHeight, dy);
end;

function TfrLineView.CalcHeight: Integer;
begin
  Result := dy;
  FHeight := dy;
end;

function TfrLineView.MinHeight: Integer;
begin
  Result := 1;
end;

function TfrLineView.RemainHeight: Integer;
begin
  Result := FHeight;
end;

function TfrLineView.GetClipRgn(rt: TfrRgnType): HRGN;
var
  bx, by, bx1, by1, dd, dd1: Integer;
begin
  bx := x; by := y; bx1 := x + dx + 1; by1 := y + dy + 1;
  if FrameStyle <> 5 then
    dd := Trunc(FrameWidth / 2) else
    dd := Trunc(FrameWidth * 1.5);
  if FrameStyle <> 5 then
    dd1 := Trunc((FrameWidth - 1) / 2) else
    dd1 := Trunc(FrameWidth + Trunc((FrameWidth - 1) / 2));
  if FrameTyp = 4 then
  begin
    Dec(bx, dd);
    Inc(bx1, dd1);
  end
  else
  begin
    Dec(by, dd);
    Inc(by1, dd1);
  end;
  if rt = rtNormal then
    Result := CreateRectRgn(bx, by, bx1, by1) else
    Result := CreateRectRgn(bx - 10, by - 10, bx1 + 10, by1 + 10);
end;


{ TfrBand }

type
  TfrBandParts = (bpHeader, bpData, bpFooter);

const
  MAXBNDS = 3;
  Bnds: Array[1..MAXBNDS, TfrBandParts] of TfrBandType =
   ((btMasterHeader, btMasterData, btMasterFooter),
    (btDetailHeader, btDetailData, btDetailFooter),
    (btSubDetailHeader, btSubDetailData, btSubDetailFooter));


constructor TfrBand.Create(ATyp: TfrBandType; AParent: TfrPage);
begin
  inherited Create;
  Typ := ATyp;
  Parent := AParent;
  Objects := TList.Create;
  Memo := TStringList.Create;
  Script := TStringList.Create;
  Values := TfrVariables.Create;
  Next := nil;
  Positions[psLocal] := 1;
  Positions[psGlobal] := 1;
  Visible := True;
end;

destructor TfrBand.Destroy;
begin
  if Next <> nil then
    Next.Free;
  Objects.Free;
  Memo.Free;
  Script.Free;
  Values.Free;
  FreeDataSet;
  inherited Destroy;
end;

procedure TfrBand.InitDataSet(Desc: String);
begin
  if Typ = btGroupHeader then
    GroupCondition := frParser.Str2OPZ(Desc)
  else
    if Pos(';', Desc) = 0 then
      CreateDS(Desc, DataSet, IsVirtualDS);
  if (Typ = btMasterData) and (Dataset = nil) and
     (CurReport.ReportType = rtSimple) then
    DataSet := CurReport.Dataset;
end;

procedure TfrBand.FreeDataSet;
begin
  if DataSet <> nil then
    DataSet.Exit;
  if IsVirtualDS then
    DataSet.Free;
  if VCDataSet <> nil then
    VCDataSet.Exit;
  if IsVirtualVCDS then
    VCDataSet.Free;
end;

function TfrBand.CalcHeight: Integer;
var
  Bnd: TfrBand;
  DS: TfrDataSet;
  ddx: Integer;

  function DoCalcHeight(CheckAll: Boolean): Integer;
  var
    i, h: Integer;
    t: TfrView;
  begin
    CurBand := Self;
    Result := dy;
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      t.olddy := t.dy;
      if t is TfrStretcheable then
        if (t.Parent = Self) or CheckAll then
        begin
          h := TfrStretcheable(t).CalcHeight + t.y;
          if h > Result then
            Result := h;
          if CheckAll then
            TfrStretcheable(t).DrawMode := drAll;
        end
    end;
  end;
begin
  Result := dy;
  if HasCross and (Typ <> btPageFooter) then
  begin
    Parent.ColPos := 1;
    CurReport.InternalOnBeginColumn(Self);
    if Parent.BandExists(Parent.Bands[btCrossData]) then
    begin
      Bnd := Parent.Bands[btCrossData];
      if Bnd.DataSet <> nil then
        DS := Bnd.DataSet else
        DS := VCDataSet;
      DS.First;
      while not DS.Eof do
      begin
        ddx := 0;
        CurReport.InternalOnPrintColumn(Parent.ColPos, ddx);
        CalculatedHeight := DoCalcHeight(True);
        if CalculatedHeight > Result then
          Result := CalculatedHeight;
        Inc(Parent.ColPos);
        DS.Next;
        if MasterReport.Terminated then break;
      end;
    end;
  end
  else
    Result := DoCalcHeight(False);
  CalculatedHeight := Result;
end;

procedure TfrBand.StretchObjects(MaxHeight: Integer);
var
  i: Integer;
  t: TfrView;
begin
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if (t is TfrStretcheable) {or (t is TfrLineView)} then
      if ((t.Flags and flStretched) <> 0) and (t.dy > 0) then
      begin
        t.dy := MaxHeight - t.y;
        if t is TfrLineView then
          TfrLineView(t).CalcHeight;
      end;
  end;
end;

procedure TfrBand.UnStretchObjects;
var
  i: Integer;
  t: TfrView;
begin
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    t.dy := t.olddy;
  end;
end;

procedure TfrBand.DrawObject(t: TfrView);
var
  ox, oy: Integer;
begin
  CurPage := Parent;
  CurBand := Self;
  try
    if t.Parent = Self then
      if PageBreak or not DisableDrawing then
      begin
        ox := t.x; Inc(t.x, Parent.XAdjust - Parent.LeftMargin + Parent.LeftOffset);
        oy := t.y; Inc(t.y, y);
        t.StreamOut(MasterReport.EMFPages[PageNo].Stream);
        t.x := ox; t.y := oy;
        if (t is TfrMemoView) and
           (TfrMemoView(t).DrawMode in [drAll, drAfterCalcHeight]) then
          Parent.AfterPrint;
      end
      else
      begin
        CurView := t;
        if not (t is TfrMemoView) or
           (TfrMemoView(t).DrawMode = drAll) then
          frInterpretator.DoScript(t.Script);
      end;
  except
    on E: exception do DoError(E);
  end;
end;

procedure TfrBand.PrepareSubReports;
var
  i: Integer;
  t: TfrView;
  Page: TfrPage;
begin
  for i := SubIndex to Objects.Count - 1 do
  begin
    t := Objects[i];
    if not t.Visible then continue;
    Page := CurReport.Pages[(t as TfrSubReportView).SubPage];
    Page.Mode := pmBuildList;
    Page.FormPage;
    Page.CurY := y + t.y;
    Page.CurBottomY := Parent.CurBottomY;
    Page.XAdjust := Parent.XAdjust + t.x;
    Page.UseMargins := Parent.UseMargins;
    Page.pgMargins := Parent.pgMargins;
    Page.ColCount := 1;
    Page.PlayFrom := 0;
    EOFArr[i - SubIndex] := False;
  end;
  Parent.LastBand := nil;
end;

procedure TfrBand.DoSubReports;
var
  i: Integer;
  t: TfrView;
  Page: TfrPage;
begin
  repeat
    if not EOFReached then
      for i := SubIndex to Objects.Count - 1 do
      begin
        t := Objects[i];
        Page := CurReport.Pages[(t as TfrSubReportView).SubPage];
        Page.CurY := Parent.CurY;
        Page.CurBottomY := Parent.CurBottomY;
      end;
    EOFReached := True;
    MaxY := Parent.CurY;
    for i := SubIndex to Objects.Count - 1 do
      if not EOFArr[i - SubIndex] then
      begin
        t := Objects[i];
        if not t.Visible then continue;
        Page := CurReport.Pages[(t as TfrSubReportView).SubPage];
        if Page.PlayRecList then
          EOFReached := False
        else
        begin
          EOFArr[i - SubIndex] := True;
          if Page.CurY > MaxY then MaxY := Page.CurY;
        end;
      end;
    if not EOFReached then
    begin
      if Parent.Skip then
      begin
        Parent.LastBand := Self;
        Exit;
      end
      else
      begin
        CurBand.DisableBandScript := True;
        Parent.NewPage;
      end;
    end;
  until EOFReached or MasterReport.Terminated;
  for i := SubIndex to Objects.Count - 1 do
  begin
    t := Objects[i];
    Page := CurReport.Pages[(t as TfrSubReportView).SubPage];
    Page.ClearRecList;
  end;
  Parent.CurY := MaxY;
  Parent.LastBand := nil;
end;

function TfrBand.DrawObjects: Boolean;
var
  i, MaxY, sfPage: Integer;
  t: TfrView;
begin
  Result := False;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if (t.Typ = gtSubReport) and t.Visible then
    begin
      SubIndex := i;
      Result := True;
      MaxY := Parent.CurY + dy;
      sfPage := PageNo;
      PrepareSubReports;
      DoSubReports;
      if sfPage = PageNo then
        if Parent.CurY < MaxY then
          Parent.CurY := MaxY;
      break;
    end;
    DrawObject(t);
    if MasterReport.Terminated then break;
  end;
end;

procedure TfrBand.DrawCrossCell(Parnt: TfrBand; CurX: Integer);
var
  i, sfx, sfy: Integer;
  t: TfrView;
begin
  CurBand := Self;
  CurBand.Positions[psGlobal] := Parnt.Positions[psGlobal];
  CurBand.Positions[psLocal] := Parnt.Positions[psLocal];
  if Typ = btCrossData then
    AggrBand := Parnt;
  try
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if Parnt.Objects.IndexOf(t) <> -1 then
        if not DisableDrawing then
        begin
          sfx := t.x; Inc(t.x, CurX + Parent.LeftOffset);
          sfy := t.y; Inc(t.y, Parnt.y);
//          t.Parent := Parnt;
          t.StreamOut(MasterReport.EMFPages[PageNo].Stream);
          if (t is TfrMemoView) and
             (TfrMemoView(t).DrawMode in [drAll, drAfterCalcHeight]) then
            Parent.AfterPrint;
          t.Parent := Self;
          t.x := sfx;
          t.y := sfy;
        end
        else
        begin
          CurView := t;
          frInterpretator.DoScript(t.Script);
        end;
    end;
  except
    on E: exception do DoError(E);
  end;
end;

procedure TfrBand.DrawCross;
var
  Bnd: TfrBand;
  sfpage: Integer;
  CurX: Integer;
  DS: TfrDataSet;
  needDestroyDS: Boolean;

  procedure CheckColumnPageBreak(ddx: Integer);
  var
    sfy: Integer;
    b: TfrBand;
  begin
    if CurX + ddx > Parent.RightMargin - Parent.LeftOffset then
    begin
      Inc(ColumnXAdjust, CurX - Parent.LeftMargin);
      CurX := Parent.LeftMargin;
      Inc(PageNo);
      if PageNo >= MasterReport.EMFPages.Count then
      begin
        MasterReport.EMFPages.Add(Parent);
        sfy := Parent.CurY;
        Parent.ShowBand(Parent.Bands[btOverlay]);
        Parent.CurY := Parent.TopMargin;
        if (sfPage <> 0) or
          ((Parent.Bands[btPageHeader].Flags and flBandOnFirstPage) <> 0) then
          Parent.ShowBand(Parent.Bands[btPageHeader]);
        Parent.CurY := sfy;
        CurReport.InternalOnProgress(PageNo);
      end;
      if Parent.BandExists(Parent.Bands[btCrossHeader]) then
        if (Parent.Bands[btCrossHeader].Flags and flBandRepeatHeader) <> 0 then
        begin
          b := Parent.Bands[btCrossHeader];
          b.DrawCrossCell(Self, Parent.LeftMargin);
          CurX := Parent.LeftMargin + b.dx;
        end;
    end;
  end;

begin
  ColumnXAdjust := 0;
  Parent.ColPos := 1;
  CurX := 0;
  sfpage := PageNo;
  if Typ = btPageFooter then Exit;
  IsColumns := True;
  CurReport.InternalOnBeginColumn(Self);

  if Parent.BandExists(Parent.Bands[btCrossHeader]) then
  begin
    Bnd := Parent.Bands[btCrossHeader];
    frInterpretator.DoScript(Bnd.Script);
    Bnd.DrawCrossCell(Self, Bnd.x);
    CurX := Bnd.x + Bnd.dx;
  end;

  if Parent.BandExists(Parent.Bands[btCrossData]) then
  begin
    Bnd := Parent.Bands[btCrossData];
    if CurX = 0 then CurX := Bnd.x;
    if Bnd.DataSet <> nil then
      DS := Bnd.DataSet else
      DS := VCDataSet;
    if DS <> nil then
    begin
      DS.First;

      needDestroyDS := False;
      if (Typ = btMasterFooter) and DS.Eof then
      begin
        CreateDS(IntToStr(Bnd.MaxColumns), DS, needDestroyDS);
        DS.First;
      end;

      while not DS.Eof do
      begin
        CurView := Bnd.View;
        CurReport.InternalOnPrintColumn(Parent.ColPos, Bnd.dx);
        frInterpretator.DoScript(Bnd.Script);
        CheckColumnPageBreak(Bnd.dx);
        Bnd.DrawCrossCell(Self, CurX);
        Bnd.DoAggregate;

        if Typ in [btMasterData, btDetailData, btSubdetailData] then
          DoAggregate;

        Inc(CurX, Bnd.dx);
        Inc(Parent.ColPos);
        DS.Next;
        if MasterReport.Terminated then break;
      end;
      if Bnd.MaxColumns < DS.RecNo then
        Bnd.MaxColumns := DS.RecNo;
      if needDestroyDS then
        DS.Free;
    end;
  end;

  if Parent.BandExists(Parent.Bands[btCrossFooter]) then
  begin
    Bnd := Parent.Bands[btCrossFooter];
    if CurX = 0 then CurX := Bnd.x;
    frInterpretator.DoScript(Bnd.Script);
    CheckColumnPageBreak(Bnd.dx);
    Bnd.DrawCrossCell(Self, CurX);
    Bnd.InitValues;
  end;

  PageNo := sfpage;
  ColumnXAdjust := 0;
  IsColumns := False;
end;

function TfrBand.CheckPageBreak(y, dy: Integer; PBreak: Boolean): Boolean;
begin
  Result := False;
  if Typ = btColumnFooter then Exit;
  with Parent do
  if y + Bands[btColumnFooter].dy + dy > CurBottomY then
  begin
    if not PBreak then
      NewColumn(Self);
    Result := True;
  end;
end;

procedure TfrBand.DrawPageBreak;
var
  i: Integer;
  dy, oldy, olddy, maxy: Integer;
  t: TfrView;
  Flag: Boolean;

  procedure CorrY(t: TfrView; dy: Integer);
  var
    i: Integer;
    t1: TfrView;
  begin
    for i := 0 to Objects.Count - 1 do
    begin
      t1 := Objects[i];
      if t1 <> t then
        if (t1.y > t.y + t.dy) and (t1.x >= t.x) and (t1.x <= t.x + t.dx) then
          Inc(t1.y, dy);
    end;
  end;

begin
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    t.Selected := True;
    t.OriginalRect := Rect(t.x, t.y, t.dx, t.dy);
  end;
  if not CheckPageBreak(y, maxdy, True) then
    DrawObjects
  else
  begin
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if t is TfrStretcheable then
        TfrStretcheable(t).ActualHeight := 0;
      if t is TfrMemoView then
        TfrMemoView(t).CalcHeight; // wraps a memo onto separate lines
    end;
    repeat
      dy := Parent.CurBottomY - Parent.Bands[btColumnFooter].dy - y - 2;
      maxy := 0;
      for i := 0 to Objects.Count - 1 do
      begin
        t := Objects[i];
        if t.Selected then
        if (t.y >= 0) and (t.y < dy) then
          if (t.y + t.dy < dy) then
          begin
            if maxy < t.y + t.dy then maxy := t.y + t.dy;
            DrawObject(t);
            t.Selected := False;
          end
          else
          begin
            if t is TfrStretcheable then
            begin
              olddy := t.dy;
              t.dy := dy - t.y + 1;
              Inc(TfrStretcheable(t).ActualHeight, t.dy);
              CurView := t;
              if t.dy > TfrStretcheable(t).MinHeight then
              begin
                TfrStretcheable(t).DrawMode := drPart;
                DrawObject(t);
              end;
              t.dy := olddy;
            end
            else
              t.y := dy
          end
        else if t is TfrStretcheable then
          if (t.y < 0) and (t.y + t.dy >= 0) then
            if t.y + t.dy < dy then
            begin
              oldy := t.y; olddy := t.dy;
              t.dy := t.y + t.dy;
              t.y := 0;
              CurView := t;
//              if t.dy > TfrStretcheable(t).MinHeight div 2 then
              begin
                t.dy := TfrStretcheable(t).RemainHeight + t.gapy * 2 + 1;
                Inc(TfrStretcheable(t).ActualHeight, t.dy - 1);
                if maxy < t.y + t.dy then
                  maxy := t.y + t.dy;
                TfrStretcheable(t).DrawMode := drPart;
                DrawObject(t);
              end;
              t.y := oldy; t.dy := olddy;
              CorrY(t, TfrStretcheable(t).ActualHeight - t.dy);
              t.Selected := False;
            end
            else
            begin
              oldy := t.y; olddy := t.dy;
              t.y := 0; t.dy := dy;
              Inc(TfrStretcheable(t).ActualHeight, t.dy);
              TfrStretcheable(t).DrawMode := drPart;
              DrawObject(t);
              t.y := oldy; t.dy := olddy;
            end;
      end;
      Flag := False;
      for i := 0 to Objects.Count - 1 do
      begin
        t := Objects[i];
        if t.Selected then Flag := True;
        Dec(t.y, dy);
      end;
      if Flag then CheckPageBreak(y, 10000, False);
      y := Parent.CurY;
      if MasterReport.Terminated then break;
    until not Flag;
    maxdy := maxy;
  end;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    t.y := t.OriginalRect.Top;
    t.dy := t.OriginalRect.Bottom;
  end;
  Inc(Parent.CurY, maxdy);
end;

function TfrBand.HasCross: Boolean;
var
  i: Integer;
  t: TfrView;
begin
  Result := False;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Parent <> Self then
    begin
      Result := True;
      break;
    end;
  end;
end;

procedure TfrBand.DoDraw;
var
  sfy, sh: Integer;
  UseY, WasSub: Boolean;
begin
  if not Parent.BandExists(Self) then Exit;
  sfy := y;
  UseY := not (Typ in [btPageFooter, btOverlay, btNone]);
  if UseY then y := Parent.CurY;
  if Stretched then
  begin
    sh := CalculatedHeight;
//    sh := CalcHeight;
    if sh > dy then StretchObjects(sh);
    maxdy := sh;
    if not PageBreak then CheckPageBreak(y, sh, False);
    y := Parent.CurY;
    WasSub := False;
    if PageBreak then
    begin
      DrawPageBreak;
      sh := 0;
    end
    else
    begin
      WasSub := DrawObjects;
      if HasCross then DrawCross;
    end;
    UnStretchObjects;
    if not WasSub then Inc(Parent.CurY, sh);
  end
  else
  begin
    if UseY then
    begin
      if not PageBreak then CheckPageBreak(y, dy, False);
      y := Parent.CurY;
    end;
    if PageBreak then
    begin
      maxdy := CalculatedHeight;
//      maxdy := CalcHeight;
      DrawPageBreak;
    end
    else
    begin
      WasSub := DrawObjects;
      if HasCross then DrawCross;
      if UseY and not WasSub then Inc(Parent.CurY, dy);
    end;
  end;

  if Parent.WasBand <> Self then
    CurColumn := 1;
  Parent.WasBand := Self;
  if (View <> nil) and (View.Columns > 1) and (View.NewColumnAfter = 1) then
  begin
    if CurColumn = 1 then
      SaveXAdjust := Parent.XAdjust;
    Inc(CurColumn);
    if CurColumn > View.Columns then
    begin
      Parent.XAdjust := SaveXAdjust;
      CurColumn := 1;
    end
    else
    begin
      Parent.XAdjust := SaveXAdjust + (CurColumn - 1) * (View.ColumnWidth + View.ColumnGap);
      Dec(Parent.CurY, CalculatedHeight);
    end;
  end;

  y := sfy;
  if Typ in [btMasterData, btDetailData, btSubDetailData] then
    DoAggregate;
end;

function TfrBand.DoCalcHeight: Integer;
var
  b: TfrBand;
begin
  if (Typ in [btMasterData, btDetailData, btSubDetailData]) and
    (Next <> nil) and (Next.Dataset = nil) then
  begin
    b := Self;
    Result := 0;
    repeat
      Result := Result + b.CalcHeight;
      b := b.Next;
    until b = nil;
  end
  else if Child <> nil then
  begin
    b := Self;
    Result := 0;
    repeat
      if b.Visible then
        if b.Stretched then
          Result := Result + b.CalcHeight else
          Result := Result + b.dy;
      b := b.Child;
    until b = nil;
  end
  else
  begin
    Result := dy;
    CalculatedHeight := dy;
    if Stretched then Result := CalcHeight;
  end;
end;

function TfrBand.Draw: Boolean;
var
  b: TfrBand;
  i, SaveY: Integer;
begin
  Result := False;
  CurView := View;
  CurBand := Self;
  CalculatedHeight := -1;

  CallNewPage := 0;
  CallNewColumn := 0;

  if Assigned(CurReport.FOnBeginBand) then
    CurReport.FOnBeginBand(Self);

  if (Parent.WasBand <> nil) and (Parent.WasBand <> Self) and
    Parent.BandExists(Parent.WasBand) and (Parent.WasBand.CurColumn > 1) then
  begin
    Parent.XAdjust := Parent.WasBand.SaveXAdjust;
    Inc(Parent.CurY, Parent.WasBand.dy);
  end;

  SaveCurY := False;
  if not DisableBandScript then
    frInterpretator.DoScript(Script);
  DisableBandScript := False;
  SaveY := Parent.CurY;

  if CurReport.Terminated then Exit;
// new page was requested in script
  for i := 1 to CallNewPage do
  begin
    Parent.CurColumn := Parent.ColCount - 1;
    Parent.NewColumn(Self);
  end;
  for i := 1 to CallNewColumn do
    Parent.NewColumn(Self);

  if SaveCurY then
    Parent.CurY := SaveY;
  if Visible then
  begin
    if Typ = btColumnHeader then
      Parent.LastStaticColumnY := Parent.CurY;
    if Typ = btPageFooter then
      y := Parent.CurBottomY;
    if Parent.BandExists(Self) then
    begin
      CalculatedHeight := dy;
      if not (Typ in [btPageFooter, btColumnFooter, btOverlay, btNone]) then
        if (Parent.CurY + DoCalcHeight > Parent.CurBottomY) and not PageBreak then
        begin
          Result := True;
          if Parent.Skip then
            Exit else
            CheckPageBreak(0, 10000, False);
        end;
      EOFReached := True;

// dealing with multiple bands
      if (Typ in [btMasterData, btDetailData, btSubDetailData]) and
        (Next <> nil) and (Next.Dataset = nil) and (DataSet <> nil) then
      begin
        b := Self;
        repeat
          b.DoDraw;
          b := b.Next;
        until b = nil;
      end
      else
      begin
        DoDraw;
        if Child <> nil then
          Child.Draw;
        if not (Typ in [btMasterData, btDetailData, btSubDetailData, btGroupHeader]) and
          NewPageAfter and Visible then
          Parent.NewPage;
      end;
      if not EOFReached then Result := True;
    end;
  end
// if band is not visible, just performing aggregate calculations
// relative to it and showing its child bands
  else
  begin
    if (Child <> nil) and PrintChildIfInvisible then
      Child.Draw;
    if Typ in [btMasterData, btDetailData, btSubDetailData] then
      DoAggregate;
  end;

// check if multiple pagefooters (in cross-tab report) - resets last of them
  if not DisableInit then
    if (Typ <> btPageFooter) or (PageNo = MasterReport.EMFPages.Count - 1) then
      InitValues;
  if Assigned(CurReport.FOnEndBand) then
    CurReport.FOnEndBand(Self);
end;

procedure TfrBand.InitValues;
var
  b: TfrBand;
  i: Integer;
  s, t: String;
  v: Variant;
begin
  if Typ = btGroupHeader then
  begin
    b := Self;
    while b <> nil do
    begin
      b.LastGroupValue := frParser.CalcOPZ(b.GroupCondition);
      b := b.Next;
    end;
  end
  else
  begin
    if AggrBand <> nil then
    begin
      for i := 0 to AggrBand.Values.Count - 1 do
      begin
        s := AggrBand.Values.Name[i];
        if (s <> '') and (s[1] in ['0'..'9']) then
        begin
          t := ExtractField(s, 3);
          s := ExtractField(s, 2)
        end
        else
        begin
          t := ExtractField(s, 2);
          s := ExtractField(s, 1);
        end;
        if Ord(t[1]) <> atMin then
          v := 0 else
          v := 1e300;
        if AnsiCompareText(s, Name) = 0 then
          AggrBand.Values.Value[i] := v;
      end;
      AggrBand.Count := 0;
    end;
  end
end;

function TfrBand.ExtractField(const s: String; FieldNo: Integer): String;
var
  i, j, k: Integer;
begin
  Result := '';
  j := 1; k := 0;
  for i := 1 to Length(s) do
  begin
    if s[i] = #1 then
    begin
      Inc(k);
      if k = FieldNo then
      begin
        Result := Copy(s, j, i - j);
        break;
      end
      else
        j := i + 1;
    end;
  end;
end;

procedure TfrBand.DoAggregate;
var
  at: Integer;
  i: Integer;
  s, s1, s2, LastExpr: String;
  v, d, LastValue: Variant;
begin
  if HasCross then
  begin
    i := 0;
    while i < Values.Count do
    begin
      s := Values.Name[i];
      s1 := ExtractField(s, 1);
      s2 := IntToStr(Parent.ColPos) + Copy(s, 2, 255);
      if s1 = '0' then
        if Values.IndexOf(s2) = -1 then
        begin
          Values[s2] := 0;
          i := -1;
        end;
      Inc(i);
    end;
  end;

  LastExpr := ''; LastValue := 0;
  for i := 0 to Values.Count - 1 do
  begin
    s := Values.Name[i];
    if HasCross then
    begin
      s1 := ExtractField(s, 1);
      s2 := IntToStr(Parent.ColPos) + Copy(s, 2, 255);
      if (s1 = '0') or (StrToInt(s1) <> Parent.ColPos) then
        continue else
        s := Copy(s, Pos(#1, s) + 1, 255);
    end;

    v := Values.Value[i];
    s1 := ExtractField(s, 2);
    at := Ord(s1[1]);
    s1 := ExtractField(s, 3);            // expression
    s2 := Trim(ExtractField(s, 4));      // include invisible bands
    d := 0;
    if at <> atCount then
    begin
      if LastExpr <> s1 then
        d := frParser.Calc(s1) else
        d := LastValue;
      LastExpr := s1;
      LastValue := d;
    end;

    if v = Null then
      v := 0;
    if d = Null then
      d := 0;
{ !!! изменено Golden Software }
{   if Visible or (s2 = '1') then}
    if (Visible or (s2 = '1')) and
       (VarType(d) <> varNULL) and (VarType(d) <> varEmpty) then
      case at of
        atSum, atAvg: v := v + d;
        atMin: if d < v then v := d;
        atMax: if d > v then v := d;
        atCount: v := v + 1;
      end;

    Values.Value[i] := v;
  end;
  Inc(Count);
end;

procedure TfrBand.AddAggregateValue(s: String; v: Variant);
begin
  Values[s] := v;
end;

function TfrBand.GetAggregateValue(s: String): Variant;
begin
  Result := Values[s];
  if ExtractField(s, 2) = Chr(Ord(atAvg)) then
    Result := Result / Count;
end;


{ TfrPage }

constructor TfrPage.Create(ASize, AWidth, AHeight, ABin: Integer;
  AOr: TPrinterOrientation);
begin
  inherited Create;
  List := TList.Create;
  Objects := TList.Create;
  ChangePaper(ASize, AWidth, AHeight, ABin, AOr);
  PrintToPrevPage := False;
  UseMargins := True;
  PageType := ptReport;
  Left := 220; Top := 120;
  Width := 380; Height := 300;
  Caption := 'Form';
  Color := clBtnFace;
  Position := Byte(poScreenCenter);
  BorderStyle := Byte(bsDialog);
  Script := TStringList.Create;
  Visible := True;
end;

destructor TfrPage.Destroy;
begin
  Clear;
  Objects.Free;
  List.Free;
  Script.Free;
  inherited Destroy;
end;

procedure TfrPage.ChangePaper(ASize, AWidth, AHeight, ABin: Integer;
  AOr: TPrinterOrientation);
begin
  try
    Prn.SetPrinterInfo(ASize, AWidth, AHeight, ABin, AOr, False);
    Prn.FillPrnInfo(PrnInfo);
  except
    on exception do
    begin
      Prn.SetPrinterInfo($100, AWidth, AHeight, -1, AOr, False);
      Prn.FillPrnInfo(PrnInfo);
    end;
  end;
  pgSize := Prn.PaperSize;
  pgWidth := Prn.PaperWidth;
  pgHeight := Prn.PaperHeight;
  pgOr := Prn.Orientation;
  if (ABin and $FFFF) <> $FFFF then
    pgBin := Prn.Bin else
    pgBin := $FFFF;
end;

procedure TfrPage.Clear;
begin
  while Objects.Count > 0 do
    Delete(0);
end;

procedure TfrPage.Delete(Index: Integer);
begin
  TfrView(Objects[Index]).Free;
  Objects.Delete(Index);
end;

function TfrPage.FindObjectByID(ID: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Objects.Count - 1 do
    if TfrView(Objects[i]).ID = ID then
    begin
      Result := i;
      break;
    end;
end;

function TfrPage.FindObject(Name: String): TfrView;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Objects.Count - 1 do
    if AnsiCompareText(TfrView(Objects[i]).Name, Name) = 0 then
    begin
      Result := Objects[i];
      Exit;
    end;
end;

procedure TfrPage.DialogFormActivate(Sender: TObject);
begin
  try
    DoScript(Script);
  except
    on E: exception do DoError(E);
  end;
end;

procedure TfrPage.InitPage;
var
  b: TfrBandType;
  i: Integer;
  t: TfrView;
  HasControls: Boolean;
  SaveVisible: Boolean;
begin
  if not MasterReport.DoublePass or not MasterReport.FinalPass then
  begin
    if PageType = ptDialog then
    begin
      CurPage := Self;
      Form := TForm.Create(nil);
      HasControls := False;
      for i := 0 to Objects.Count - 1 do
      begin
        t := Objects[i];
        t.ParentPage := Self;
        if not (t is TfrNonVisualControl) then
        begin
          TfrControl(t).PlaceControl(Form);
          HasControls := True;
        end;
      end;
      if HasControls and Visible then
      begin
        SaveVisible := frProgressForm.Visible;
        frProgressForm.Hide;
        Form.BorderStyle := TFormBorderStyle(BorderStyle);
        Form.Caption := Caption;
        Form.Color := Color;
        Form.SetBounds(Left, Top, Width, Height);
        Form.OnActivate := DialogFormActivate;
        Form.Position := TPosition(Position);
//
        Form.OnActivate(Self);
        Form.OnActivate := nil;

        if Form.ModalResult = mrNone then
        begin
          if Form.ShowModal = mrCancel then
            DontShowReport := True;
        end
        else
          DontShowReport := Form.ModalResult = mrCancel;

        frProgressForm.Visible := SaveVisible;
      end
      else
        DoScript(Script);
    end
    else
    begin
      for b := btReportTitle to btNone do
        Bands[b] := CreateBand(b, Self); {!!!}
      TossObjects;
      CurPos := 1; ColPos := 1;
    end;
    InitFlag := True;
  end;
end;

procedure TfrPage.DonePage;
var
  b: TfrBandType;
begin
  if not MasterReport.DoublePass or MasterReport.FinalPass then
  begin
    if InitFlag then
    begin
      if PageType = ptDialog then
      begin
        Clear;
        if Form <> nil then
          Form.Free;
        Form := nil;
      end
      else
      begin
        for b := btReportTitle to btNone do
          Bands[b].Free;
      end;
    end;
    InitFlag := False;
  end;
end;

function TfrPage.TopMargin: Integer;
begin
  if UseMargins then
    if pgMargins.Top = 0 then
      Result := PrnInfo.Ofy else
      Result := pgMargins.Top
  else
    Result := 0;
end;

function TfrPage.BottomMargin: Integer;
begin
  with PrnInfo do
    if UseMargins then
      if pgMargins.Bottom = 0 then
        Result := Ofy + Ph else
        Result := Pgh - pgMargins.Bottom
    else
      Result := Pgh;
  if (DocMode <> dmDesigning) and BandExists(Bands[btPageFooter]) then
    Result := Result - Bands[btPageFooter].dy;
end;

function TfrPage.LeftMargin: Integer;
begin
  if UseMargins then
    if pgMargins.Left = 0 then
      Result := PrnInfo.Ofx else
      Result := pgMargins.Left
  else
    Result := 0;
end;

function TfrPage.LeftOffset: Integer;
begin
  Result := 0;
{  if UseMargins and (pgMargins.Left <> 0) then
    Result := pgMargins.Left - PrnInfo.Ofx;}
end;

function TfrPage.RightMargin: Integer;
begin
  with PrnInfo do
    if UseMargins then
      if pgMargins.Right = 0 then
        Result := Ofx + Pw else
        Result := Pgw - pgMargins.Right
    else
      Result := Pgw;
end;

procedure TfrPage.TossObjects;
var
  i, j, n, last, miny: Integer;
  b: TfrBandType;
  bt, t: TfrView;
  Bnd, Bnd1, Bnd2: TfrBand;
  FirstBand, Flag: Boolean;
  BArr: Array[0..31] of TfrBand;
  s, s1: String;
begin
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    t.StreamMode := smFRP;
    if t is TfrMemoView then
      TfrMemoView(t).HighlightStr := frParser.Str2OPZ(TfrMemoView(t).HighlightStr);
    if (t.Flags and flWantHook) <> 0 then
      HookList.Add(t);

    t.Selected := t.Typ <> gtBand;
    t.Parent := nil;
    frInterpretator.PrepareScript(t.Script, t.Script, SMemo);
    if t.Typ = gtSubReport then
      CurReport.Pages[(t as TfrSubReportView).SubPage].Skip := True;
  end;

  Flag := False;
  for i := 0 to Objects.Count - 1 do // search for btCrossXXX bands
  begin
    bt := Objects[i];
    if (bt.Typ = gtBand) and
       (TfrBandType(bt.FrameTyp) in [btCrossHeader..btCrossFooter]) then
    with Bands[TfrBandType(bt.FrameTyp)] do
    begin
      Memo.Assign(bt.Memo);
      Script.Assign(bt.Script);
      x := bt.x; dx := bt.dx;
      InitDataSet(bt.FormatStr);
      View := TfrBandView(bt);
      Flags := bt.Flags;
      Visible := bt.Visible;
      Name := bt.Name;
      bt.Parent := Bands[TfrBandType(bt.FrameTyp)];
      Flag := True;
    end;
  end;

  if Flag then // fill a CrossXXX bands at first
    for b := btCrossHeader to btCrossFooter do
    begin
      Bnd := Bands[b];
      for i := 0 to Objects.Count - 1 do
      begin
        t := Objects[i];
        if t.Selected then
         if (t.x >= Bnd.x) and (t.x + t.dx <= Bnd.x + Bnd.dx) then
         begin
           t.x := t.x - Bnd.x;
           t.Parent := Bnd;
           Bnd.Objects.Add(t);
         end;
      end;
    end;

  for b := btReportTitle to btChild do // fill other bands
  begin
    if b in [btCrossHeader..btCrossFooter] then continue;
    FirstBand := True;
    Bnd := Bands[b];
    BArr[0] := Bnd;
    Last := 1;
    for i := 0 to Objects.Count - 1 do // search for specified band
    begin
      bt := Objects[i];
      if (bt.Typ = gtBand) and (bt.FrameTyp = Integer(b)) then
      begin
        if not FirstBand then
        begin
          Bnd.Next := CreateBand(b, Self); {!!!}
          Bnd := Bnd.Next;
          BArr[Last] := Bnd;
          Inc(Last);
        end;
        FirstBand := False;
        Bnd.Memo.Assign(bt.Memo);
        Bnd.Script.Assign(bt.Script);
        Bnd.y := bt.y;
        Bnd.dy := bt.dy;
        Bnd.View := TfrBandView(bt);
        Bnd.Flags := bt.Flags;
        Bnd.Visible := bt.Visible;
        Bnd.Name := bt.Name;
        Bnd.CurColumn := 1;
        bt.Parent := Bnd;
        with bt as TfrBandView, Bnd do
        begin
          InitDataSet(FormatStr);
          Stretched := (Flags and flStretched) <> 0;
          PrintIfSubsetEmpty := (Flags and flBandPrintIfSubsetEmpty) <> 0;
          PrintChildIfInvisible := (Flags and flBandPrintChildIfInvisible) <> 0;
          if Skip then
          begin
            NewPageAfter := False;
            PageBreak := False;
          end
          else
          begin
            NewPageAfter := (Flags and flBandNewPageAfter) <> 0;
            PageBreak := (Flags and flBandBreaked) <> 0;
          end;
        end;
        for j := 0 to Objects.Count - 1 do // placing objects over band
        begin
          t := Objects[j];
          if (t.Parent = nil) and (t.Typ <> gtSubReport) then
           if t.Selected then
            if (t.y >= Bnd.y) and (t.y <= Bnd.y + Bnd.dy) then
            begin
              t.Parent := Bnd;
              t.y := t.y - Bnd.y;
              t.Selected := False;
              Bnd.Objects.Add(t);
            end;
        end;
        for j := 0 to Objects.Count - 1 do // placing ColumnXXX objects over band
        begin
          t := Objects[j];
          if t.Parent <> nil then
           if t.Selected then
            if (t.y >= Bnd.y) and (t.y <= Bnd.y + Bnd.dy) then
            begin
              t.y := t.y - Bnd.y;
              t.Selected := False;
              Bnd.Objects.Add(t);
            end;
        end;
        for j := 0 to Objects.Count - 1 do // placing subreports over band
        begin
          t := Objects[j];
          if (t.Parent = nil) and (t.Typ = gtSubReport) then
           if t.Selected then
            if (t.y >= Bnd.y) and (t.y <= Bnd.y + Bnd.dy) then
            begin
              t.Parent := Bnd;
              t.y := t.y - Bnd.y;
              t.Selected := False;
              Bnd.Objects.Add(t);
            end;
        end;
      end;
    end;
    for i := 0 to Last - 1 do // sorting bands
    begin
      miny := BArr[i].y; n := i;
      for j := i + 1 to Last - 1 do
        if BArr[j].y < miny then
        begin
          miny := BArr[j].y;
          n := j;
        end;
      Bnd := BArr[i]; BArr[i] := BArr[n]; BArr[n] := Bnd;
    end;
    Bnd := BArr[0]; Bands[b] := Bnd;
    Bnd.Prev := nil;
    for i := 1 to Last - 1 do  // finally ordering
    begin
      Bnd.Next := BArr[i];
      Bnd := Bnd.Next;
      Bnd.Prev := BArr[i - 1];
    end;
    Bnd.Next := nil;
    Bands[b].LastBand := Bnd;
  end;

  for i := 0 to Objects.Count - 1 do // place other objects on btNone band
  begin
    t := Objects[i];
    if t.Selected then
    begin
      t.Parent := Bands[btNone];
      Bands[btNone].y := 0;
      Bands[btNone].Objects.Add(t);
    end;
  end;

  for i := 1 to MAXBNDS do  // connect header & footer to each data-band
  begin
    Bnd := Bands[Bnds[i, bpHeader]];
    while Bnd <> nil do
    begin
      Bnd1 := Bands[Bnds[i, bpData]];
      while Bnd1 <> nil do
      begin
        if Bnd1.y > Bnd.y + Bnd.dy then break;
        Bnd1 := Bnd1.Next;
      end;
      if (Bnd1 <> nil) and (Bnd1.HeaderBand = nil) then
      begin
        Bnd1.HeaderBand := Bnd;
        Bnd.DataBand := Bnd1;
      end;

      Bnd := Bnd.Next;
    end;

    Bnd := Bands[Bnds[i, bpFooter]];
    while Bnd <> nil do
    begin
      Bnd1 := Bands[Bnds[i, bpData]];
      while Bnd1 <> nil do
      begin
        if Bnd1.y + Bnd1.dy > Bnd.y then
        begin
          Bnd1 := Bnd1.Prev;
          break;
        end;
        if Bnd1.Next = nil then break;
        Bnd1 := Bnd1.Next;
      end;
      if (Bnd1 <> nil) and (Bnd1.FooterBand = nil) then
      begin
        Bnd1.FooterBand := Bnd;
        Bnd.DataBand := Bnd1;
      end;

      Bnd := Bnd.Next;
    end;
  end;

  Bnd := Bands[btGroupHeader].LastBand;
  Bnd1 := Bands[btGroupFooter];
  repeat
    Bnd.FooterBand := Bnd1;
    Bnd := Bnd.Prev;
    Bnd1 := Bnd1.Next;
  until (Bnd = nil) or (Bnd1 = nil);

  if BandExists(Bands[btCrossData]) and (Pos(';', Bands[btCrossData].View.FormatStr) <> 0) then
  begin
    s := Bands[btCrossData].View.FormatStr;
    i := 1;
    while i < Length(s) do
    begin
      j := i;
      while s[j] <> '=' do Inc(j);
      n := j;
      while s[n] <> ';' do Inc(n);
      for b := btMasterHeader to btChild do
      begin
        Bnd := Bands[b];
        while Bnd <> nil do
        begin
          if Bnd.View <> nil then
            if AnsiCompareText(Bnd.View.Name, Copy(s, i, j - i)) = 0 then
              SelfCreateDS(Copy(s, j + 1, n - j - 1), Bnd.VCDataSet, Bnd.IsVirtualVCDS); {!!!}
          Bnd := Bnd.Next;
        end;
      end;
      i := n + 1;
    end;
  end;

  for b := btReportTitle to btChild do // connecting child bands
  begin
    Bnd := Bands[b];
    while Bnd <> nil do
    begin
      if Bnd.View <> nil then
      begin
        s := TfrBandView(Bnd.View).ChildBand;
        if s <> '' then
          Bnd.Child := TfrBandView(FindObject(s)).Parent;
      end;
      Bnd := Bnd.Next;
    end;
  end;

  if BandExists(Bands[btMasterData]) then  // tossing group headers
  begin
    s := Bands[btMasterData].View.Name;
    Bnd := Bands[btGroupHeader];
    while (Bnd <> nil) and (Bnd.View <> nil) do
    begin
      if Bnd.View.Master = '' then
        s1 := s else
        s1 := Bnd.View.Master;
      t := FindObject(s1);
      if (t <> nil) and (t is TfrBandView) then
      begin
        Bnd1 := t.Parent;
        Bnd2 := Bnd1.LastGroup;
        if Bnd2 = nil then
        begin
          Bnd1.FirstGroup := Bnd;
          Bnd1.LastGroup := Bnd;
        end
        else
        begin
          Bnd2.NextGroup := Bnd;
          Bnd.PrevGroup := Bnd2;
          Bnd1.LastGroup := Bnd;
        end;
      end;
      Bnd := Bnd.Next;
    end;
  end;

  if ColCount = 0 then ColCount := 1;
  ColWidth := (RightMargin - LeftMargin - ((ColCount - 1) * ColGap)) div ColCount;
end;

procedure TfrPage.PrepareObjects;
var
  i, j: Integer;
  t: TfrView;
  s: String;
  Bnd: TfrBand;
  DSet: TfrTDataSet;
  Field: String;
  p: PfrCacheItem;

  procedure ExpandVariables(Bnd: TfrBand);
  var
    i: Integer;
    t: TfrView;
    a: TAggregateFunctionsSplitter;
    SplitTo: TStringList;
  begin
    SplitTo := TStringList.Create;
    CurBand := Bnd;
    CurView := Bnd.View;
    a := TAggregateFunctionsSplitter.CreateSplitter(SplitTo);
    a.SplitScript(Bnd.Script);
    for i := 0 to Bnd.Objects.Count - 1 do
    begin
      t := Bnd.Objects[i];
      CurView := t;
      if t is TfrMemoView then
        a.SplitMemo(t.Memo);
      a.SplitScript(t.Script);
    end;
    a.Free;
    for i := 0 to SplitTo.Count - 1 do
      frParser.CalcOPZ(SplitTo[i]);
    SplitTo.Free;
  end;

  procedure AddAggregate(b: Array of TfrBandType);
  var
    i: Integer;
    Bnd: TfrBand;
  begin
    for i := Low(b) to High(b) do
    begin
      Bnd := Bands[b[i]];
      while Bnd <> nil do
      begin
        ExpandVariables(Bnd);
        Bnd := Bnd.Child;
      end;
      Bnd := Bands[b[i]];
      Bnd := Bnd.Next;
      while Bnd <> nil do
      begin
        ExpandVariables(Bnd);
        Bnd := Bnd.Next;
      end;
    end;
  end;

begin
  if (PageType = ptDialog) or (MasterReport.DoublePass and MasterReport.FinalPass) then Exit;
  CurPage := Self;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    t.FField := '';
    s := t.Memo.Text;
    j := Length(s);
    if (j > 2) and (s[1] = '[') and not
       ((t is TfrMemoView) and ((t.Flags and flTextOnly) <> 0)) then
    begin
      while (j > 0) and (s[j] <> ']') do Dec(j);
      s := Copy(s, 2, j - 2);
      t.FDataSet := nil;
      t.FField := '';
      CurBand := t.Parent;
      if CurReport.Dictionary.IsVariable(s) then
      begin
        if CurReport.Dictionary.Cache.Find(s, j) then
        begin
          p := PfrCacheItem(CurReport.Dictionary.Cache.Objects[j]);
          t.FDataSet := p.DataSet;
          t.FField := p.DataField;
        end;
      end
      else
      begin
        CurBand := t.Parent;
        DSet := GetDefaultDataset;
        gsGetDataSetandField(s, DSet, Field); {!!!}
        if Field <> '' then
        begin
          t.FDataSet := DSet;
          t.FField := Field;
        end;
      end;
    end;
  end;

// aggregate handling
  InitAggregate := True;
  CurPage := Self;
  try
    for i := 1 to MAXBNDS do
    begin
      Bnd := Bands[Bnds[i, bpData]];
      while Bnd <> nil do
      begin
        AggrBand := Bnd;
        case Bnd.Typ of
          btMasterData:
            AddAggregate([btPageFooter, btColumnFooter, btMasterFooter,
                          btGroupFooter, btReportSummary]);
          btDetailData:
            AddAggregate([btPageFooter, btColumnFooter, btMasterFooter,
                          btDetailFooter, btGroupFooter, btReportSummary]);
          btSubdetailData:
            AddAggregate([btPageFooter, btColumnFooter, btMasterFooter,
                          btDetailFooter, btSubdetailFooter, btGroupFooter, btReportSummary]);
        end;
        Bnd := Bnd.Next;
        if (Bnd = nil) or (Bnd.DataSet = nil) then break;
      end;
    end;
    AggrBand := Bands[btCrossData];
    if AggrBand <> nil then
      AddAggregate([btCrossFooter]);
  except
    on E: Exception do DoError(E);
  end;
  InitAggregate := False;
end;

procedure TfrPage.ShowBand(b: TfrBand);
begin
  if b <> nil then
    if Mode = pmBuildList then
      AddRecord(b, rtShowBand) else
      b.Draw;
end;

procedure TfrPage.ShowBandByName(s: String);
var
  bt: TfrBandType;
  b: TfrBand;
begin
  for bt := btReportTitle to btNone do
  begin
    b := Bands[bt];
    while b <> nil do
    begin
      if b.View <> nil then
        if AnsiCompareText(b.View.Name, s) = 0 then
        begin
          b.Draw;
          Exit;
        end;
      b := b.Next;
    end;
  end;
end;

procedure TfrPage.ShowBandByType(bt: TfrBandType);
var
  b: TfrBand;
begin
  b := Bands[bt];
  if b <> nil then
    b.Draw;
end;

procedure TfrPage.ResetPosition(b: TfrBand; ResetTo: Integer);
var
  i: Integer;
  t: TfrView;
begin
  b.Positions[psLocal] := ResetTo;
  for i := 0 to b.Objects.Count - 1 do
  begin
    t := b.Objects[i];
    if t is TfrMemoView then
      TfrMemoView(t).LastValue := '';
  end;
end;

procedure TfrPage.AddRecord(b: TfrBand; rt: TfrBandRecType);
var
  p: PfrBandRec;
begin
  New(p);
  p^.Band := b;
  p^.Action := rt;
  List.Add(p);
end;

procedure TfrPage.ClearRecList;
var
  i: Integer;
  p: PfrBandRec;
begin
  for i := 0 to List.Count - 1 do
  begin
    p := List[i];
    Dispose(p);
  end;
  List.Clear;
end;

function TfrPage.PlayRecList: Boolean;
var
  p: PfrBandRec;
  b: TfrBand;
begin
  Result := False;
  while PlayFrom < List.Count do
  begin
    p := List[PlayFrom];
    b := p^.Band;
    case p^.Action of
      rtShowBand:
        begin
          if LastBand <> nil then
          begin
            LastBand.DoSubReports;
            if LastBand <> nil then
            begin
              Result := True;
              Exit;
            end;
          end
          else
            if b.Draw then
            begin
              Result := True;
              Exit;
            end;
        end;
      rtFirst:
        begin
          b.DataSet.First;
          ResetPosition(b, 1);
        end;
      rtNext:
        begin
          b.DataSet.Next;
          Inc(CurPos);
          Inc(b.Positions[psGlobal]);
          Inc(b.Positions[psLocal]);
        end;
    end;
    Inc(PlayFrom);
  end;
end;

procedure TfrPage.DrawPageFooters;
begin
  CurColumn := 0;
  XAdjust := LeftMargin;
  if (PageNo <> 0) or ((Bands[btPageFooter].Flags and flBandOnFirstPage) <> 0) then
    while PageNo < MasterReport.EMFPages.Count do
    begin
      if not (Append and WasPF) then
      begin
        if (CurReport <> nil) and Assigned(CurReport.FOnEndPage) then
          CurReport.FOnEndPage(PageNo);
        if (MasterReport <> CurReport) and (MasterReport <> nil) and
          Assigned(MasterReport.FOnEndPage) then
          MasterReport.FOnEndPage(PageNo);
        ShowBand(Bands[btPageFooter]);
      end;
      Inc(PageNo);
    end;
  PageNo := MasterReport.EMFPages.Count;
end;

procedure TfrPage.NewPage;
begin
  CurReport.InternalOnProgress(PageNo + 1);
  if not DisableRepeatHeader then
    ShowBand(Bands[btColumnFooter]);
  DrawPageFooters;
  CurBottomY := BottomMargin;
  MasterReport.EMFPages.Add(Self);
  Append := False;
  ShowBand(Bands[btOverlay]);
  CurY := TopMargin;
  ShowBand(Bands[btPageHeader]);
  ShowBand(Bands[btColumnHeader]);
end;

procedure TfrPage.NewColumn(Band: TfrBand);
var
  b: TfrBand;
begin
  if CurColumn < ColCount - 1 then
  begin
    ShowBand(Bands[btColumnFooter]);
    Inc(CurColumn);
    Inc(XAdjust, ColWidth + ColGap);
    CurY := LastStaticColumnY;
    ShowBand(Bands[btColumnHeader]);
  end
  else
    NewPage;
  b := Bands[btGroupHeader];
  if b <> nil then
    while (b <> nil) and (b <> Band) do
    begin
      b.DisableInit := True;
      if (b.Flags and flBandRepeatHeader) <> 0 then
        if (b.Typ <> btGroupHeader) or not DisableRepeatHeader then
          ShowBand(b);
      b.DisableInit := False;
      b := b.Next;
    end;
  if Band.Typ in [btMasterData, btDetailData, btSubDetailData] then
    if (Band.HeaderBand <> nil) and
      ((Band.HeaderBand.Flags and flBandRepeatHeader) <> 0) then
      ShowBand(Band.HeaderBand);
end;

procedure TfrPage.FormPage;
var
  BndStack: Array[1..100] of TfrBand;
  MaxLevel, BndStackTop: Integer;
  i, sfPage: Integer;
  sfFlags: Word;
  Empty: Boolean;
{$IFDEF IBO}
  bEOF: Boolean;
{$ENDIF}

  procedure AddToStack(b: TfrBand);
  begin
    if b <> nil then
    begin
      Inc(BndStackTop);
      BndStack[BndStackTop] := b;
    end;
  end;

  procedure ShowStack;
  var
    i: Integer;
  begin
    for i := 1 to BndStackTop do
      if BandExists(BndStack[i]) then
        ShowBand(BndStack[i]);
    BndStackTop := 0;
  end;

  procedure DoLoop(Level: Integer);
  var
    WasPrinted: Boolean;
    b, b1, b2: TfrBand;

    procedure InitGroups(b: TfrBand);
    begin
      while b <> nil do
      begin
        Inc(b.Positions[psLocal]);
        Inc(b.Positions[psGlobal]);
        AddToStack(b);
        b := b.NextGroup;
      end;
    end;

  begin
    b := Bands[Bnds[Level, bpData]];
    while b <> nil do
    begin
      if b.Dataset = nil then
      begin
        b := b.Next;
        continue;
      end;

      b.DataSet.First;
      if Mode = pmBuildList then
        AddRecord(b, rtFirst)
      else
      begin
        ResetPosition(b, 1);
        b.Positions[psGlobal] := 1;
      end;

      b1 := b.FirstGroup;
      while b1 <> nil do
      begin
        ResetPosition(b1, 0);
        b1.Positions[psGlobal] := 0;
        b1 := b1.NextGroup;
      end;

      if not b.DataSet.Eof then
      begin
        InitGroups(b.FirstGroup);
        if b.HeaderBand <> nil then
          AddToStack(b.HeaderBand);

        if b.FooterBand <> nil then
          b.FooterBand.InitValues;

        while not b.DataSet.Eof do
        begin
//          Application.ProcessMessages;
          if MasterReport.Terminated then break;
          AddToStack(b);
          WasPrinted := True;
          if Level < MaxLevel then
          begin
            DoLoop(Level + 1);
            if BndStackTop > 0 then
              if b.PrintIfSubsetEmpty then
                ShowStack
              else
              begin
                Dec(BndStackTop);
                WasPrinted := False;
              end;
          end
          else
            ShowStack;

          b.DataSet.Next;

          b1 := b.FirstGroup;
          while b1 <> nil do
          begin
            if b.Dataset.Eof or VarIsEmpty(b1.LastGroupValue) or
              (frParser.CalcOPZ(b1.GroupCondition) <> b1.LastGroupValue) then
            begin
{$IFDEF IBO}
              bEOF := b.Dataset.Eof;
              try
                b.DataSet.Prior;
              except
              end;
{$ELSE}
              if not b.Dataset.Eof then
                b.DataSet.Prior;
{$ENDIF}
              b2 := b.LastGroup;
              while b2 <> b1 do
              begin
                AddToStack(b2.FooterBand);
                ResetPosition(b2, 0);
                if b2.FooterBand <> nil then
                  ResetPosition(b2.FooterBand, 0);
                b2 := b2.Prev;
              end;
              AddToStack(b1.FooterBand);
              ShowStack;
{$IFDEF IBO}
  {$IFDEF IBO4}
              if not bEOF then b.Dataset.Next;
  {$ELSE}
              if bEOF then b.Dataset.Next;
  {$ENDIF}
{$ENDIF}
              if not b.DataSet.Eof then
              begin
                b.DataSet.Next;
                if b1.NewPageAfter and b1.Visible then NewPage;
                InitGroups(b1);
                ResetPosition(b, 0);
              end;

              break;
            end;
            b1 := b1.NextGroup;
          end;

          if Mode = pmBuildList then
            AddRecord(b, rtNext)
          else if WasPrinted then
          begin
            Inc(CurPos);
            Inc(b.Positions[psGlobal]);
            Inc(b.Positions[psLocal]);
            if not b.DataSet.Eof and b.NewPageAfter and b.Visible then NewPage;
          end;
          if MasterReport.Terminated then break;
        end;
        if BndStackTop = 0 then
          ShowBand(b.FooterBand) else
          Dec(BndStackTop)
      end;
      b := b.Next;
    end;
  end;

begin
  Empty := False;
  if not CurReport.PrintIfEmpty then
  try
    Bands[btMasterData].DataSet.First;
    if Bands[btMasterData].DataSet.Eof then
      Empty := True;
  except
    Empty := True;
  end;

  if Empty then
  begin
    if Append then
      Inc(PageNo);
    Exit;
  end;
  DisableRepeatHeader := False;
  if Mode = pmNormal then
  begin
    DoScript(Script);
    if Append then
      if PrevY = PrevBottomY then
      begin
        Append := False;
        WasPF := False;
        PageNo := MasterReport.EMFPages.Count;
      end;
    if Append and WasPF then
      CurBottomY := PrevBottomY else
      CurBottomY := BottomMargin;
    CurColumn := 0;
    XAdjust := LeftMargin;
    if not Append then
    begin
      MasterReport.EMFPages.Add(Self);
      CurY := TopMargin;
      ShowBand(Bands[btOverlay]);
      ShowBand(Bands[btNone]);
    end
    else
      CurY := PrevY;
    sfPage := PageNo;

    if not Assigned(CurReport.FOnManualBuild) then
      ShowBand(Bands[btReportTitle]);
    if PageNo = sfPage then // check if new page was formed
    begin
      if BandExists(Bands[btPageHeader]) and
        ((Bands[btPageHeader].Flags and flBandOnFirstPage) <> 0) then
        ShowBand(Bands[btPageHeader]);
      ShowBand(Bands[btColumnHeader]);
    end;
  end;

  if not Assigned(CurReport.FOnManualBuild) then
  begin
    BndStackTop := 0;
    for i := 1 to MAXBNDS do
      if BandExists(Bands[Bnds[i, bpData]]) then
        MaxLevel := i;
    DoLoop(1);
  end;
  if Mode = pmNormal then
  begin
    if not Assigned(CurReport.FOnManualBuild) then
    begin
      DisableRepeatHeader := True;
      ShowBand(Bands[btColumnFooter]);
      i := Bands[btColumnFooter].dy;
      Bands[btColumnFooter].dy := 0;
      ShowBand(Bands[btReportSummary]);
      Bands[btColumnFooter].dy := i;
      DisableRepeatHeader := False;
    end
    else
      CurReport.OnManualBuild(Self);
    PrevY := CurY;
    PrevBottomY := CurBottomY;
    if CurColumn > 0 then
      PrevY := BottomMargin;
    CurColumn := 0;
    XAdjust := LeftMargin;
    sfPage := PageNo;
    WasPF := False;
    if not Assigned(CurReport.FOnManualBuild) then
    begin
      if ((PageNo = 0) and ((Bands[btPageFooter].Flags and flBandOnFirstPage) <> 0)) or
         ((Bands[btPageFooter].Flags and flBandOnLastPage) <> 0) then
      begin
        sfFlags := Bands[btPageFooter].Flags;
        Bands[btPageFooter].Flags := sfFlags or flBandOnFirstPage;
        WasPF := BandExists(Bands[btPageFooter]);
        if WasPF then DrawPageFooters;
        Bands[btPageFooter].Flags := sfFlags;
      end;
    end;
    if (CurReport <> nil) and Assigned(CurReport.FOnEndPage) then
      CurReport.FOnEndPage(PageNo);
    if (MasterReport <> CurReport) and (MasterReport <> nil) and
      Assigned(MasterReport.FOnEndPage) then
      MasterReport.FOnEndPage(PageNo);
    PageNo := sfPage + 1;
  end;
  WasBand := nil;
end;

function TfrPage.BandExists(b: TfrBand): Boolean;
begin
  Result := ((b <> nil) and (b.View <> nil)) or
    ((b <> nil) and (b.Typ = btNone) and (b.Objects.Count > 0));
end;

procedure TfrPage.AfterPrint;
var
  i: Integer;
begin
  for i := 0 to HookList.Count - 1 do
    TfrView(HookList[i]).OnHook(CurView);
end;

procedure TfrPage.LoadFromStream(Stream: TStream);
var
  i: Integer;
  b: Byte;
  s: String[6];
begin
  Script.Clear;
  with Stream do
  begin
    Read(i, 4);
    if i = -1 then
      Read(pgSize, 4) else
      pgSize := i;
    Read(pgWidth, 4);
    Read(pgHeight, 4);
    Read(pgMargins, Sizeof(pgMargins));
    Read(b, 1);
    pgOr := TPrinterOrientation(b);
    if frVersion < 23 then
      Read(s[1], 6);
    pgBin := -1;
    if frVersion > 23 then
      Read(pgBin, 4);
    Read(PrintToPrevPage, 2);
    Read(UseMargins, 2);
    Read(ColCount, 4);
    Read(ColGap, 4);
    if frVersion > 23 then
    begin
      Read(PageType, 1);
      Self.Name := frReadString(Stream);
      Read(BorderStyle, 1);
      if BorderStyle = 0 then
        BorderStyle := Byte(bsDialog)
      else if BorderStyle = 1 then
        BorderStyle := Byte(bsSizeable);
      Caption := frReadString(Stream);
      Read(Color, 4);
      Read(Left, 16);
      Read(b, 1);
      if b <> 0 then
        b := Byte(poScreenCenter);
      Self.Position := b;
      if i = -1 then
        frReadMemo(Stream, Script);
    end
    else
      CreateUniqueName;
  end;
  ChangePaper(pgSize, pgWidth, pgHeight, pgBin, pgOr);
end;

procedure TfrPage.SaveToStream(Stream: TStream);
var
  b: Byte;
begin
  with Stream do
  begin
    frWriteInteger(Stream, -1);
    Write(pgSize, 4);
    Write(pgWidth, 4);
    Write(pgHeight, 4);
    Write(pgMargins, Sizeof(pgMargins));
    b := Byte(pgOr);
    Write(b, 1);
    Write(pgBin, 4);
    Write(PrintToPrevPage, 2);
    Write(UseMargins, 2);
    Write(ColCount, 4);
    Write(ColGap, 4);
    Write(PageType, 1);
    frWriteString(Stream, Self.Name);
    Write(BorderStyle, 1);
    frWriteString(Stream, Caption);
    Write(Color, 4);
    Write(Left, 16);
    Write(Self.Position, 1);
    frWriteMemo(Stream, Script);
  end;
end;

procedure TfrPage.ScriptEditor(Sender: TObject);
var
  t: TfrControl;
begin
  t := TfrControl.Create; // create fake object
  t.Script.Assign(Script);
  frMemoEditor(t);
  Script.Assign(t.Script);
  t.Free;
end;

procedure TfrPage.DefineProperties;
var
  v: Variant;

  function GetPaperNames: String;
  var
    i: Integer;
  begin
    Result := '';
    for i := 0 to Prn.PaperNames.Count - 1 do
      Result := Result + Prn.PaperNames[i] + ';';
    SetLength(Result, Length(Result) - 1);
  end;

  function GetPaperSizes: Variant;
  var
    i: Integer;
  begin
    Result := VarArrayCreate([0, Prn.PaperNames.Count - 1], varVariant);
    for i := 0 to Prn.PaperNames.Count - 1 do
      Result[i] := Prn.PaperSizes[i];
  end;

begin
  ClearPropList;
  AddEnumProperty('Type', 'ptReport;ptDialog', [0, 1]);
  AddProperty('Visible', [], nil);
  if PageType = ptDialog then
  begin
    AddEnumProperty('BorderStyle', 'bsDialog;bsSizeable', [bsDialog,bsSizeable]);
    AddProperty('Caption', [frdtString], nil);
    AddProperty('Color', [frdtColor], nil);
    AddProperty('Left', [frdtSize], nil);
    AddProperty('Top', [frdtSize], nil);
    AddProperty('Width', [frdtInteger], nil);
    AddProperty('Height', [frdtInteger], nil);
    AddEnumProperty('Position', 'poDesigned;poScreenCenter', [poDesigned,poScreenCenter]);
    AddProperty('OnActivate', [frdtHasEditor, frdtOneObject], ScriptEditor);
  end
  else
  begin
    v := GetPaperSizes;
    AddEnumProperty('Size', GetPaperNames, v);
    AddProperty('Width', [frdtSize], nil);
    AddProperty('Height', [frdtSize], nil);
    AddProperty('LeftMargin', [frdtSize], nil);
    AddProperty('TopMargin', [frdtSize], nil);
    AddProperty('RightMargin', [frdtSize], nil);
    AddProperty('BottomMargin', [frdtSize], nil);
    AddEnumProperty('Orientation',
      'poPortrait;poLandscape',
      [poPortrait,poLandscape]);
    AddProperty('PrintToPrevPage', [frdtBoolean], nil);
    AddProperty('StretchToPrintable', [frdtBoolean], nil);
    AddProperty('Columns', [frdtInteger], nil);
    AddProperty('ColumnGap', [frdtSize], nil);
    AddProperty('OnBeforePrint', [frdtHasEditor, frdtOneObject], ScriptEditor);
  end;
end;

procedure TfrPage.SetPropValue(Index: String; Value: Variant);
begin
  Index := AnsiUpperCase(Index);
  if Index = 'LEFT' then
    Left := Value
  else if Index = 'TOP' then
    Top := Value
  else if Index = 'WIDTH' then
    if PageType = ptDialog then
      Width := Value else
      pgWidth := Round(Value * 10 * 5 / 18)
  else if Index = 'HEIGHT' then
    if PageType = ptDialog then
      Height := Value else
      pgHeight := Round(Value * 10 * 5 / 18)
  else if Index = 'TYPE' then
    PageType := TfrPageType(Value)
  else if Index = 'BORDERSTYLE' then
    BorderStyle := Value
  else if Index = 'CAPTION' then
    Caption := Value
  else if Index = 'NAME' then
    Name := Value
  else if Index = 'COLOR' then
    Color := Value
  else if Index = 'POSITION' then
    Position := Value
  else if Index = 'SIZE' then
    pgSize := Value
  else if Index = 'LEFTMARGIN' then
    pgMargins.Left := Value
  else if Index = 'TOPMARGIN' then
    pgMargins.Top := Value
  else if Index = 'RIGHTMARGIN' then
    pgMargins.Right := Value
  else if Index = 'BOTTOMMARGIN' then
    pgMargins.Bottom := Value
  else if Index = 'ORIENTATION' then
    pgOr := TPrinterOrientation(Value)
  else if Index = 'PRINTTOPREVPAGE' then
    PrintToPrevPage := Value
  else if Index = 'STRETCHTOPRINTABLE' then
    UseMargins := not Value
  else if Index = 'COLUMNS' then
    ColCount := Value
  else if Index = 'COLUMNGAP' then
    ColGap := Value
  else if Index = 'VISIBLE' then
    Visible := Value
end;

function TfrPage.GetPropValue(Index: String): Variant;
begin
  Index := AnsiUpperCase(Index);
  Result := Null;
  if Index = 'LEFT' then
    Result := Left
  else if Index = 'TOP' then
    Result := Top
  else if Index = 'WIDTH' then
    if PageType = ptDialog then
      Result := Width else
      Result := Integer(Round(pgWidth / 10 * 18 / 5))
  else if Index = 'HEIGHT' then
    if PageType = ptDialog then
      Result := Height else
      Result := Integer(Round(pgHeight / 10 * 18 / 5))
  else if Index = 'TYPE' then
    Result := Integer(PageType)
  else if Index = 'BORDERSTYLE' then
    Result := BorderStyle
  else if Index = 'NAME' then
    Result := Name
  else if Index = 'CAPTION' then
    Result := Caption
  else if Index = 'COLOR' then
    Result := Color
  else if Index = 'POSITION' then
    Result := Position
  else if Index = 'SIZE' then
    Result := pgSize
  else if Index = 'LEFTMARGIN' then
    if DocMode = dmDesigning then
      Result := pgMargins.Left else
      Result := LeftMargin
  else if Index = 'TOPMARGIN' then
    if DocMode = dmDesigning then
      Result := pgMargins.Top else
      Result := TopMargin
  else if Index = 'RIGHTMARGIN' then
    if DocMode = dmDesigning then
      Result := pgMargins.Right else
      Result := RightMargin
  else if Index = 'BOTTOMMARGIN' then
    if DocMode = dmDesigning then
      Result := pgMargins.Bottom else
      Result := BottomMargin
  else if Index = 'ORIENTATION' then
    Result := Byte(pgOr)
  else if Index = 'PRINTTOPREVPAGE' then
    Result := PrintToPrevPage
  else if Index = 'STRETCHTOPRINTABLE' then
    Result := not UseMargins
  else if Index = 'COLUMNS' then
    Result := ColCount
  else if Index = 'COLUMNGAP' then
    Result := ColGap
  else if Index = 'VISIBLE' then
    Result := Visible
end;

procedure TfrPage.CreateUniqueName;
var
  i, j: Integer;
  Found: Boolean;
begin
  Name := 'Page';
  for i := 1 to 10000 do
  begin
    Found := False;
    for j := 0 to CurReport.Pages.Count - 1 do
      if CurReport.Pages[j].Name = Name + IntToStr(i) then
        Found := True;
    if not Found then
    begin
      Name := Name + IntToStr(i);
      break;
    end;
  end;
end;

procedure TfrPage.DoScript(Script: TStrings);
var
  sl, sl1: TStringList;
begin
  if Script.Text <> '' then
  begin
    CurView := nil;
    sl := TStringList.Create;
    sl1 := TStringList.Create;
    frInterpretator.PrepareScript(Script, sl, sl1);
    frInterpretator.DoScript(sl);
    sl.Free;
    sl1.Free;
  end;
end;

{!!!}
function TfrPage.CreateBand(ATyp: TfrBandType; AParent: TfrPage): TfrBand;
begin
  Result := TfrBand.Create(ATyp, AParent);
end;

procedure TfrPage.gsGetDataSetandField(ComplexName: String;
  var DataSet: TfrTDataSet; var Field: String);
begin
  frGetDatasetAndField(ComplexName, DataSet, Field);
end;

procedure TfrPage.SelfCreateDS(Desc: String; var DataSet: TfrDataSet; var IsVirtualDS: Boolean);
begin
  CreateDS(Desc, DataSet, IsVirtualDS);
end;


{ TfrPages }

constructor TfrPages.Create(AParent: TfrReport);
begin
  inherited Create;
  Parent := AParent;
  FPages := TList.Create;
end;

destructor TfrPages.Destroy;
begin
  Clear;
  FPages.Free;
  inherited Destroy;
end;

function TfrPages.GetCount: Integer;
begin
  Result := FPages.Count;
end;

function TfrPages.GetPages(Index: Integer): TfrPage;
begin
  Result := FPages[Index];
end;

procedure TfrPages.Clear;
var
  i: Integer;
begin
  for i := 0 to FPages.Count - 1 do
    Pages[i].Free;
  FPages.Clear;
end;

procedure TfrPages.Add;
begin
  FPages.Add(TfrPage.Create(frDefaultPaper, 0, 0, -1, poPortrait));
end;

procedure TfrPages.Delete(Index: Integer);
begin
  Pages[Index].Free;
  FPages.Delete(Index);
end;

procedure TfrPages.Move(OldIndex, NewIndex: Integer);
begin
  FPages.Move(OldIndex, NewIndex);
end;

procedure TfrPages.LoadFromStream(Stream: TStream);
var
  b: Byte;
  i, j, n: Integer;
  t: TfrView;
  s: String;
  buf: String[8];

  procedure AddObject(ot: Byte; clname: String);
  begin
    Stream.Read(b, 1);
    CurPage := Pages[b];
    t := frCreateObject(ot, clname);
    if t <> nil then
      CurPage.Objects.Add(t);
  end;

begin
  Parent.Clear;
  Stream.Read(Parent.PrintToDefault, 2);
  Stream.Read(Parent.DoublePass, 2);
  s := ReadString(Stream);
  if s = #1 then
    s := frLoadStr(SDefaultPrinter);
  Parent.SetPrinterTo(s);
  while Stream.Position < Stream.Size do
  begin
    Stream.Read(b, 1);
    if b = $FF then  // page info
    begin
      Add;
      Pages[Count - 1].LoadFromStream(Stream);
    end
    else if b = $FE then // data dictionary
      Parent.Dictionary.LoadFromStream(Stream)
    else if b = $FD then // datasets
    begin
      if frDataManager <> nil then
        frDataManager.LoadFromStream(Stream);
      break;
    end
    else
    begin
      if b > Integer(gtAddIn) then
      begin
        raise Exception.Create('');
        break;
      end;
      s := ''; n := 0;
      try
        if b = gtAddIn then
        begin
          s := ReadString(Stream);
          if (AnsiUpperCase(s) = 'TFRBDELOOKUPCONTROL') or
             (AnsiUpperCase(s) = 'TFRIBXLOOKUPCONTROL') then
            s := 'TfrDBLookupControl';
          if AnsiUpperCase(s) = 'TFRFRAMEDMEMOVIEW' then
            AddObject(gtMemo, '') else
            AddObject(gtAddIn, s);
        end
        else
          AddObject(b, '');
        if frVersion > 23 then
          Stream.Read(n, 4);
        if t <> nil then
          try
            t.LoadFromStream(Stream);
          finally
            t.Prop['Name'] := t.Name;
          end;
        if AnsiUpperCase(s) = 'TFRFRAMEDMEMOVIEW' then
          Stream.Read(buf[1], 8);
        if n <> 0 then
          Stream.Position := n;
      except
        if frVersion > 23 then
        begin
          if n = 0 then
            Stream.Read(n, 4);
          Stream.Seek(n, soFromBeginning);
        end;
      end;
    end;
  end;
  if ErrorFlag then
    raise EClassNotFound.Create(ErrorStr)
  else
    for i := 0 to Count - 1 do
      for j := 0 to Pages[i].Objects.Count - 1 do
      begin
        t := Pages[i].Objects[j];
        t.Loaded;
      end;
end;

procedure TfrPages.SaveToStream(Stream: TStream);
var
  b: Byte;
  i, j, n: Integer;
  t: TfrView;
  SavePos: Integer;
  s: String;
begin
  Stream.Write(Parent.PrintToDefault, 2);
  Stream.Write(Parent.DoublePass, 2);
  s := Prn.Printers[Prn.PrinterIndex];
  if s = frLoadStr(SDefaultPrinter) then
    s := #1;
  frWriteString(Stream, s);
  for i := 0 to Count - 1 do // adding pages at first
  begin
    b := $FF;
    Stream.Write(b, 1);      // page info
    Pages[i].SaveToStream(Stream);
  end;
  for i := 0 to Count - 1 do
  begin
    for j := 0 to Pages[i].Objects.Count - 1 do // then adding objects
    begin
      t := Pages[i].Objects[j];
      b := Byte(t.Typ);
      Stream.Write(b, 1);
      if t.Typ = gtAddIn then
        frWriteString(Stream, t.ClassName);
      Stream.Write(i, 1);
      SavePos := Stream.Position;
      Stream.Write(i, 4);
      t.SaveToStream(Stream);
      n := Stream.Position;
      Stream.Position := SavePos;
      Stream.Write(n, 4);
      Stream.Seek(0, soFromEnd);
    end;
  end;
  b := $FE;
  Stream.Write(b, 1);
  Parent.Dictionary.SaveToStream(Stream);
  if frDataManager <> nil then
  begin
    b := $FD;
    Stream.Write(b, 1);
    frDataManager.SaveToStream(Stream);
  end;
end;

procedure TfrPages.RefreshObjects;
var
  i, j: Integer;
  v: TfrObject;
begin
  for i := 0 to Count - 1 do
    for j := 0 to Pages[i].Objects.Count - 1 do
    begin
      CurPage := Pages[i];
      v := Pages[i].Objects[j];
      if (v is TfrView) and (TfrView(v).BandAlign <> baNone) then
        TfrView(v).Draw(TempBmp.Canvas);
    end;
end;


{ TfrEMFPages }

constructor TfrEMFPages.Create(AParent: TfrReport);
begin
  inherited Create;
  Parent := AParent;
  FPages := TList.Create;
end;

destructor TfrEMFPages.Destroy;
begin
  Clear;
  FPages.Free;
  inherited Destroy;
end;

function TfrEMFPages.GetCount: Integer;
begin
  Result := FPages.Count;
end;

function TfrEMFPages.GetPages(Index: Integer): PfrPageInfo;
begin
  Result := FPages[Index];
end;

procedure TfrEMFPages.Clear;
begin
  while FPages.Count > 0 do
    Delete(0);
end;

procedure TfrEMFPages.Draw(Index: Integer; Canvas: TCanvas; DrawRect: TRect);
var
  p: PfrPageInfo;
  t: TfrView;
  i: Integer;
  sx, sy: Double;
  v, IsPrinting: Boolean;
  h: THandle;
begin
  IsPrinting := Printer.Printing and (Canvas.Handle = Printer.Canvas.Handle);
  DocMode := dmPrinting;
  p := FPages[Index];
  with p^ do
  if Visible then
  begin
    if Page = nil then
      ObjectsToPage(Index);
    CurPage := Page;
    sx := (DrawRect.Right - DrawRect.Left) / PrnInfo.PgW;
    sy := (DrawRect.Bottom - DrawRect.Top) / PrnInfo.PgH;
    h := Canvas.Handle;
    for i := 0 to Page.Objects.Count - 1 do
    begin
      t := Page.Objects[i];
      v := True;
      if not IsPrinting and not (Canvas is TMetafileCanvas) then
        with t, DrawRect do
          v := RectVisible(h, Rect(Round(x * sx) + Left - 10,
                                   Round(y * sy) + Top - 10,
                                   Round((x + dx) * sx) + Left + 10,
                                   Round((y + dy) * sy) + Top + 10));
      if v then
      begin
        t.ScaleX := sx; t.ScaleY := sy;
        t.OffsX := DrawRect.Left; t.OffsY := DrawRect.Top;
        t.IsPrinting := IsPrinting;
        t.Draw(Canvas);
      end;
    end;
  end
  else
  begin
    Page.Free;
    Page := nil;
  end;
end;

procedure TfrEMFPages.ExportData(Index: Integer);
var
  p: PfrPageInfo;
  b: Byte;
  t: TfrView;
  s: String;
begin
  p := FPages[Index];
  with p^ do
  begin
    Stream.Position := 0;
    Stream.Read(frVersion, 1);
    while Stream.Position < Stream.Size do
    begin
      Stream.Read(b, 1);
      if b = gtAddIn then
        s := ReadString(Stream) else
        s := '';
      t := frCreateObject(b, s);
      t.StreamMode := smFRP;
      t.LoadFromStream(Stream);
      t.ExportData;
      t.Free;
    end;
  end;
end;

procedure TfrEMFPages.ObjectsToPage(Index: Integer);
var
  p: PfrPageInfo;
  b: Byte;
  t: TfrView;
  s: String;
begin
  p := FPages[Index];
  with p^ do
  begin
    if Page <> nil then
      Page.Free;
    Page := CreateNewPage(pgSize, pgWidth, pgHeight, pgBin, pgOr); {!!!}
    Page.pgMargins := pgMargins;
    Page.UseMargins := UseMargins;
    CurPage := Page;
    Stream.Position := 0;
    Stream.Read(frVersion, 1);
    while Stream.Position < Stream.Size do
    begin
      Stream.Read(b, 1);
      if b = gtAddIn then
        s := ReadString(Stream) else
        s := '';
      t := frCreateObject(b, s);
      t.StreamMode := smFRP;
      t.LoadFromStream(Stream);
      t.StreamMode := smFRF;
      if (t is TfrMemoView) and ((t.Flags and flAutoSize) <> 0) then
        t.Draw(TempBmp.Canvas);
      Page.Objects.Add(t);
    end;
  end;
end;

procedure TfrEMFPages.PageToObjects(Index: Integer);
var
  i: Integer;
  p: PfrPageInfo;
  t: TfrView;
begin
  p := FPages[Index];
  with p^ do
  begin
    Stream.Clear;
    frVersion := frCurrentVersion;
    Stream.Write(frVersion, 1);
    for i := 0 to Page.Objects.Count - 1 do
    begin
      t := Page.Objects[i];
      t.StreamMode := smFRP;
      Stream.Write(t.Typ, 1);
      if t.Typ = gtAddIn then
        frWriteString(Stream, t.ClassName);
      t.Memo1.Assign(t.Memo);
      t.SaveToStream(Stream);
    end;
  end;
end;

procedure TfrEMFPages.Insert(Index: Integer; APage: TfrPage);
var
  p: PfrPageInfo;
begin
  New(p);
  FillChar(p^, SizeOf(TfrPageInfo), 0);
  if Index >= FPages.Count then
    FPages.Add(p) else
    FPages.Insert(Index, p);
  with p^ do
  begin
    Stream := TMemoryStream.Create;
    frVersion := frCurrentVersion;
    Stream.Write(frVersion, 1);
    pgSize := APage.pgSize;
    pgWidth := APage.pgWidth;
    pgHeight := APage.pgHeight;
    pgOr := APage.pgOr;
    pgBin := APage.pgBin;
    UseMargins := APage.UseMargins;
    pgMargins := APage.pgMargins;
    PrnInfo := APage.PrnInfo;
  end;
end;

procedure TfrEMFPages.Add(APage: TfrPage);
begin
  Insert(FPages.Count, APage);
  if (CurReport <> nil) and Assigned(CurReport.FOnBeginPage) then
    CurReport.FOnBeginPage(PageNo);
  if (MasterReport <> CurReport) and (MasterReport <> nil) and
    Assigned(MasterReport.FOnBeginPage) then
    MasterReport.FOnBeginPage(PageNo);
end;

procedure TfrEMFPages.AddFrom(Report: TfrReport);
begin
  if (Report <> nil) and (Report.EMFPages.Count > 0) then
    while Report.EMFPages.Count > 0 do
    begin
      FPages.Add(Report.EMFPages.FPages[0]);
      Report.EMFPages.FPages.Delete(0);
    end;
end;

procedure TfrEMFPages.Delete(Index: Integer);
var
  p: PfrPageInfo;
begin
  if Pages[Index]^.Page <> nil then Pages[Index]^.Page.Free;
  if Pages[Index]^.Stream <> nil then Pages[Index]^.Stream.Free;
  p := Pages[Index];
  Dispose(p);
  FPages.Delete(Index);
end;

procedure TfrEMFPages.LoadFromStream(AStream: TStream);
var
  i, o, c: Integer;
  b, compr, Vers: Byte;
  p: PfrPageInfo;
  s: TMemoryStream;

  procedure ReadVersion22;
  var
    Pict: TfrPictureView;
  begin
    frReadMemo22(AStream, SMemo);
    if SMemo.Count > 0 then
      Parent.SetPrinterTo(SMemo[0]);
    AStream.Read(c, 4);
    i := 0;
    repeat
      AStream.Read(o, 4);
      New(p);
      FillChar(p^, SizeOf(TfrPageInfo), 0);
      FPages.Add(p);
      with p^ do
      begin
        AStream.Read(pgSize, 2);
        AStream.Read(pgWidth, 4);
        AStream.Read(pgHeight, 4);
        AStream.Read(b, 1);
        pgOr := TPrinterOrientation(b);
        pgBin := -1;
        AStream.Read(b, 1);
        UseMargins := Boolean(b);
        Prn.SetPrinterInfo(pgSize, pgWidth, pgHeight, -1, pgOr, False);
        Prn.FillPrnInfo(PrnInfo);

        Pict := TfrPictureView.Create;
        Pict.SetBounds(0, 0, PrnInfo.PgW, PrnInfo.PgH);
        Pict.Picture.Metafile.LoadFromStream(AStream);

        Stream := TMemoryStream.Create;
        b := frCurrentVersion;
        Stream.Write(b, 1);
        Pict.StreamMode := smFRP;
        Stream.Write(Pict.Typ, 1);
        Pict.SaveToStream(Stream);
        Pict.Free;
      end;
      AStream.Seek(o, soFromBeginning);
      Inc(i);
    until i >= c;
  end;

begin
  Clear;
  if AStream = nil then Exit;
  AStream.Read(Vers, 1);
  if not ((Vers > 23) and (Vers < 32)) then
  begin
    Vers := 0;
    AStream.Seek(0, soFromBeginning);
  end;
  AStream.Read(compr, 1);
  if not (compr in [0, 1, 255]) then
  begin
    AStream.Seek(0, soFromBeginning);
    ReadVersion22;
    Exit;
  end;
  Parent.SetPrinterTo(frReadString(AStream));
  AStream.Read(c, 4);
  i := 0;
  repeat
    AStream.Read(o, 4);
    New(p);
    FillChar(p^, SizeOf(TfrPageInfo), 0);
    FPages.Add(p);
    with p^ do
    begin
      AStream.Read(pgSize, 2);
      AStream.Read(pgWidth, 4);
      AStream.Read(pgHeight, 4);
      AStream.Read(b, 1);
      pgOr := TPrinterOrientation(b);
      pgBin := -1;
      if Vers > 23 then
        AStream.Read(pgBin, 4);
      AStream.Read(b, 1);
      UseMargins := Boolean(b);
      if Vers > 23 then
        AStream.Read(pgMargins, Sizeof(pgMargins));
      if compr <> 0 then
      begin
        s := TMemoryStream.Create;
        s.CopyFrom(AStream, o - AStream.Position);
        s.Position := 0;
        Stream := TMemoryStream.Create;
        frCompressor.DeCompress(s, Stream);
        s.Free;
      end
      else
      begin
        Stream := TMemoryStream.Create;
        Stream.CopyFrom(AStream, o - AStream.Position);
      end;
      Prn.SetPrinterInfo(pgSize, pgWidth, pgHeight, pgBin, pgOr, False);
      Prn.FillPrnInfo(PrnInfo);
    end;
    AStream.Seek(o, soFromBeginning);
    Inc(i);
  until i >= c;
end;

procedure TfrEMFPages.SaveToStream(AStream: TStream);
var
  i, o, n: Integer;
  b: Byte;
  s: TMemoryStream;
begin
  if AStream = nil then Exit;
  b := frCurrentVersion;
  AStream.Write(b, 1);
  b := Byte(frCompressor.Enabled);
  AStream.Write(b, 1);
  frWriteString(AStream, Prn.Printers[Prn.PrinterIndex]);
  n := Count;
  AStream.Write(n, 4);
  for i := 0 to Count - 1 do
  begin
    o := AStream.Position;
    AStream.Write(o, 4); // dummy write
    with Pages[i]^ do
    begin
      AStream.Write(pgSize, 2);
      AStream.Write(pgWidth, 4);
      AStream.Write(pgHeight, 4);
      b := Byte(pgOr);
      AStream.Write(b, 1);
      AStream.Write(pgBin, 4);
      b := Byte(UseMargins);
      AStream.Write(b, 1);
      AStream.Write(pgMargins, Sizeof(pgMargins));
      Stream.Position := 0;
      if frCompressor.Enabled then
      begin
        s := TMemoryStream.Create;
        frCompressor.Compress(Stream, s);
        AStream.CopyFrom(s, 0);
        s.Free;
      end
      else
        AStream.CopyFrom(Stream, 0);
    end;
    n := AStream.Position;
    AStream.Seek(o, soFromBeginning);
    AStream.Write(n, 4);
    AStream.Seek(0, soFromEnd);
  end;
end;

function TfrEMFPages.DoClick(Index: Integer; pt: TPoint; Click: Boolean;
  var Cursor: TCursor): Boolean;
var
  p: PfrPageInfo;
  t: TfrView;
  i: Integer;
  sx, sy, ofsx, ofsy: Double;
begin
  Result := False;
  p := FPages[Index];
  with p^ do
  begin
    if Page = nil then
      ObjectsToPage(Index);
    if UseMargins then
    begin
      sx := 1; sy := 1;
      ofsx := 0; ofsy := 0;
    end
    else
    with PrnInfo, pgMargins do
    begin
      sx := (Pw - (Left + Right)) / Pgw; sy := (Ph - (Top + Bottom)) / Pgh;
      ofsx := Ofx + Left; ofsy := Ofy + Top;
    end;

    for i := Page.Objects.Count - 1 downto 0 do
    begin
      t := Page.Objects[i];
      with t do
      if PtInRect(Rect(Round(x * sx + ofsx), Round(y * sy + ofsy),
        Round((x + dx) * sx + ofsx), Round((y + dy) * sy + ofsy)), pt) then
      begin
        if Click then
        begin
          if Assigned(Self.Parent.OnObjectClick) then
          begin
            Self.Parent.OnObjectClick(t);
            Result := True;
          end;
        end
        else
          if Assigned(Self.Parent.OnMouseOverObject) then
          begin
            Self.Parent.OnMouseOverObject(t, Cursor);
            Result := True;
          end;
        break;
      end;
    end;
  end;
end;

{!!!}
function TfrEMFPages.CreateNewPage(ASize, AWidth, AHeight, ABin: Integer;
  AOr: TPrinterOrientation): TfrPage;
begin
  Result := TfrPage.Create(ASize, AWidth, AHeight, ABin, AOr);
end;


{ TfrDataDictionary }

constructor TfrDataDictionary.Create;
begin
  inherited Create;
  Variables := TfrVariables.Create;
  FieldAliases := TfrVariables.Create;
  BandDatasources := TfrVariables.Create;
  DisabledDatasets := TStringList.Create;
  Cache := TStringList.Create;
end;

destructor TfrDataDictionary.Destroy;
begin
  Variables.Free;
  FieldAliases.Free;
  BandDatasources.Free;
  DisabledDatasets.Free;
  ClearCache;
  Cache.Free;
  inherited Destroy;
end;

procedure TfrDataDictionary.Clear;
begin
  Variables.Clear;
  FieldAliases.Clear;
  BandDatasources.Clear;
end;

procedure TfrDataDictionary.ClearCache;
var
  p: PfrCacheItem;
begin
  while Cache.Count > 0 do
  begin
    p := PfrCacheItem(Cache.Objects[0]);
    Dispose(p);
    Cache.Delete(0);
  end;
end;

procedure TfrDataDictionary.AddCacheItem(VarName: String; DataSet: TfrTDataSet;
  DataField: String);
var
  p: PfrCacheItem;
begin
  New(p);
  p.DataSet := DataSet;
  p.DataField := DataField;
  Cache.AddObject(VarName, TObject(p));
end;

procedure TfrDataDictionary.LoadFromStream(Stream: TStream);
var
  w: Word;
  NewVersion: Boolean;

  procedure LoadFRVariables(Value: TfrVariables);
  var
    i, n: Integer;
    s: String;
  begin
    Stream.Read(n, 4);
    for i := 0 to n - 1 do
    begin
      s := frReadString(Stream);
      Value[s] := frReadString(Stream);
    end;
  end;

  procedure LoadOldVariables;
  var
    i, n, d: Integer;
    b: Byte;
    s, s1, s2: String;

    function ReadStr: String;
    var
      n: Byte;
    begin
      Stream.Read(n, 1);
      SetLength(Result, n);
      Stream.Read(Result[1], n);
    end;

  begin
    with Stream do
    begin
      ReadBuffer(n, SizeOf(n));
      for i := 0 to n - 1 do
      begin
        Read(b, 1); // typ
        Read(d, 4); // otherkind
        s1 := ReadStr; // dataset
        s2 := ReadStr; // field
        s := ReadStr;  // var name
        if b = 2 then      // it's system variable or expression
          if d = 1 then
            s1 := s2 else
            s1 := frSpecFuncs[d]
        else if b = 1 then // it's data field
          s1 := s1 + '."' + s2 + '"'
        else
          s1 := '';
        FieldAliases[' ' + s] := s1;
      end;
    end;

    ReadMemo(Stream, SMemo);
    for i := 0 to SMemo.Count - 1 do
    begin
      s := SMemo[i];
      if (s <> '') and (s[1] <> ' ') then
        Variables[s] := '' else
        Variables[s] := FieldAliases[s];
    end;
    FieldAliases.Clear;
  end;

  procedure ConvertToNewFormat;
  var
    i: Integer;
    s: String;
  begin
    for i := 0 to Variables.Count - 1 do
    begin
      s := Variables.Name[i];
      if s <> '' then
        if s[1] = ' ' then
          s := Copy(s, 2, 255) else
          s := ' ' + s;
      Variables.Name[i] := s;
    end;
  end;

  procedure ConvertAliases;
  var
    i: Integer;
    DSet: TfrTDataSet;
    F: String;
  begin
    i := 0;
    while i < FieldAliases.Count do
    begin
      if FieldAliases.Value[i] = '' then
      begin
        frGetDataSetandField(FieldAliases.Name[i], DSet, F);
        if F = '' then
        begin
          FieldAliases.Delete(i);
          Dec(i);
        end;
      end;
      Inc(i);
    end;

    i := 0;
    while i < BandDataSources.Count do
      if BandDataSources.Value[i] = '' then
        BandDataSources.Delete(i) else
        Inc(i);
  end;

begin
  Clear;
  w := frReadWord(Stream);
  NewVersion := (w = $FFFF) or (w = $FFFE);
  if NewVersion then
  begin
    LoadFRVariables(Variables);
    LoadFRVariables(FieldAliases);
    LoadFRVariables(BandDatasources);
  end
  else
  begin
    Stream.Seek(-2, soFromCurrent);
    LoadOldVariables;
  end;
  if (Variables.Count > 0) and (Variables.Name[0] <> '') and (Variables.Name[0][1] <> ' ') then
    ConvertToNewFormat;
  if w = $FFFF then
    ConvertAliases;
end;

procedure TfrDataDictionary.SaveToStream(Stream: TStream);
  procedure SaveFRVariables(Value: TfrVariables);
  var
    i, n: Integer;
  begin
    n := Value.Count;
    Stream.Write(n, 4);
    for i := 0 to n - 1 do
    begin
      frWriteString(Stream, Value.Name[i]);
      frWriteString(Stream, Value.Value[i]);
    end;
  end;
begin
  frWriteWord(Stream, $FFFE);
  SaveFRVariables(Variables);
  SaveFRVariables(FieldAliases);
  SaveFRVariables(BandDatasources);
end;

procedure TfrDataDictionary.LoadFromFile(FName: String);
var
  Stream: TFileStream;
  vers: Byte;
begin
  Stream := TFileStream.Create(FName, fmOpenRead);
  Stream.Read(vers, 1); // not used now
  LoadFromStream(Stream);
  Stream.Free;
end;

procedure TfrDataDictionary.SaveToFile(FName: String);
var
  Stream: TFileStream;
  vers: Byte;
begin
  Stream := TFileStream.Create(FName, fmCreate);
  vers := frCurrentVersion;
  Stream.Write(vers, 1);
  SaveToStream(Stream);
  Stream.Free;
end;

procedure TfrDataDictionary.ExtractFieldName(ComplexName: String;
  var DSName, FieldName: String);
var
  i: Integer;
  fl: Boolean;
begin
  fl := False;
  for i := Length(ComplexName) downto 1 do
  begin
    if ComplexName[i] = '"' then
      fl := not fl;
    if (ComplexName[i] = '.') and not fl then
    begin
      DSName := Copy(ComplexName, 1, i - 1);
      FieldName := frRemoveQuotes(Copy(ComplexName, i + 1, 255));
      break;
    end;
  end;
end;

function TfrDataDictionary.IsVariable(VarName: String): Boolean;
var
  i: Integer;
  s, s1, s2: String;
  F: String;
  DSet: TfrTDataSet;
  v: Variant;

  function RealFieldName(DataSetName, FieldName: String): String;
  var
    i: Integer;
    s: String;
  begin
    Result := FieldName;
    for i := 0 to FieldAliases.Count - 1 do
      if AnsiCompareText(FieldAliases.Value[i], FieldName) = 0 then
        if Pos(DataSetName, FieldAliases.Name[i]) = 1 then
        begin
          Result := FieldAliases.Name[i];
          ExtractFieldName(Result, s, Result);
          break;
        end;
  end;

begin
  if Cache.Find(VarName, i) then
    Result := True
  else
  begin
    Result := Variables.IndexOf(VarName) <> -1;
    if Result then
    begin
      v := Variables[VarName];
      if v <> Null then
      begin
        s := v;
        if Pos('.', s) <> 0 then
        begin
          DSet := GetDefaultDataset;
          frGetDataSetandField(s, DSet, F);
          if F <> '' then
          begin
            AddCacheItem(VarName, DSet, F);
            Cache.Sort;
          end;
        end;
      end;
    end;
  end;

  if not Result then
  begin
    if Pos('.', VarName) <> 0 then
    begin
      ExtractFieldName(VarName, s1, s2);
      s := RealDataSetName[s1];
      if s <> s1 then
        s1 := s;
      s := s1 + '."' + RealFieldName(s1, s2) + '"';
    end
    else
      s := VarName;
    DSet := GetDefaultDataset;
    frGetDataSetandField(s, DSet, F);
    if F <> '' then
    begin
      AddCacheItem(VarName, DSet, F);
      Cache.Sort;
      Result := True;
    end;
  end;
end;

function TfrDataDictionary.DatasetEnabled(DatasetName: String): Boolean;
var
  i: Integer;
  Mask: Boolean;
  s: String;
begin
  Result := True;
  for i := 0 to DisabledDatasets.Count - 1 do
  begin
    s := DisabledDatasets[i];
    Mask := (s <> '') and (s[Length(s)] = '*');
    if Mask then
      s := Copy(s, 1, Length(s) - 1);
    if (Mask and (Pos(s, DatasetName) = 1)) or
       (AnsiCompareText(s, DatasetName) = 0) then
    begin
      Result := False;
      break;
    end;
  end;
end;

function TfrDataDictionary.GetValue(VarName: String): Variant;
var
  i: Integer;
  p: PfrCacheItem;
  F: TfrTField;
begin
  Result := Null;
  if Cache.Find(VarName, i) then
  begin
    p := PfrCacheItem(Cache.Objects[i]);
    if not p.DataSet.Active then
      p.DataSet.Open;
    F := TfrTField(p.DataSet.FindField(p.DataField));
    Result := frGetFieldValue(F);
  end
  else if Variables.IndexOf(VarName) <> -1 then
  begin
    if frVariables.IndexOf(VarName) <> -1 then
      Result := frVariables[VarName]
    else
    begin
      Result := Variables[VarName];
      if TVarData(Result).VType = varString then
        if Result <> '' then
          Result := frParser.Calc(Result);
    end;
  end;
end;

function TfrDataDictionary.GetRealDataSetName(ItemName: String): String;
var
  i: Integer;
begin
  Result := ItemName;
  for i := 0 to FieldAliases.Count - 1 do
    if AnsiCompareText(FieldAliases.Value[i], ItemName) = 0 then
    begin
      Result := FieldAliases.Name[i];
      break;
    end;
end;

function TfrDataDictionary.GetRealDataSourceName(ItemName: String): String;
var
  i: Integer;
begin
  Result := ItemName;
  for i := 0 to BandDataSources.Count - 1 do
    if AnsiCompareText(BandDataSources.Value[i], ItemName) = 0 then
    begin
      Result := BandDataSources.Name[i];
      break;
    end;
end;

function TfrDataDictionary.GetRealFieldName(ItemName: String): String;
var
  i: Integer;
begin
  Result := GetRealDataSetName(ItemName);
  if Pos('.', Result) <> 0 then
  begin
    for i := Length(Result) downto 1 do
      if Result[i] = '.' then
      begin
        Result := Copy(Result, i + 1, 255);
        break;
      end;
  end;
end;

function TfrDataDictionary.GetAliasName(ItemName: String): String;
  function CheckList(s: String; List: TfrVariables): String;
  begin
    Result := '';
    if List.IndexOf(s) <> -1 then
      Result := List[s];
  end;
begin
  Result := CheckList(ItemName, FieldAliases);
  if Result = '' then
    Result := CheckList(ItemName, BandDatasources);
  if Result = '' then
    Result := ItemName;
end;

procedure TfrDataDictionary.GetDatasetList(List: TStrings);
var
  i: Integer;
  s: String;
  sl: TStringList;
begin
  sl := TStringList.Create;
{$IFDEF IBO}
  if CurReport <> nil then
    frGetComponents(CurReport.Owner, TIB_DataSet, sl, nil)
  else
    frGetComponents(nil, TIB_DataSet, sl, nil);
{$ELSE}
  if CurReport <> nil then
    frGetComponents(CurReport.Owner, TDataSet, sl, nil)
  else
    frGetComponents(nil, TDataSet, sl, nil);
{$ENDIF}

  i := 0;
  while i < sl.Count do
  begin
    if DatasetEnabled(sl[i]) then
    begin
      if FieldAliases.Count > 0 then
        if FieldAliases.IndexOf(sl[i]) <> -1 then
        begin
          s := FieldAliases[sl[i]];
          if s <> '' then
            sl[i] := s;
        end
        else
        begin
          sl.Delete(i);
          Dec(i);
        end;
      Inc(i);
    end
    else
      sl.Delete(i);
  end;

  sl.Sort;
  List.Assign(sl);
  sl.Free;
end;

procedure TfrDataDictionary.GetFieldList(DSName: String; List: TStrings);
var
  i: Integer;
  s: String;
  sl: TStringList;
  DataSet: TfrTDataSet;
begin
  sl := TStringList.Create;
  DataSet := frGetDataSet(DSName);
  if DataSet = nil then
  begin
    DSName := GetRealDataSetName(DSName);
    DataSet := frGetDataSet(DSName);
  end;
  if DataSet <> nil then
  try
    frGetFieldNames(DataSet, sl);
  except;
  end;

  i := 0;
  while i < sl.Count do
  begin
    if FieldAliases.IndexOf(DSName + '.' + sl[i]) <> -1 then
    begin
      s := FieldAliases[DSName + '.' + sl[i]];
      if s <> '' then
        sl[i] := s
      else
      begin
        sl.Delete(i);
        Dec(i);
      end;
    end;
    Inc(i);
  end;

//  sl.Sort;
  List.Assign(sl);
  sl.Free;
end;

procedure TfrDataDictionary.GetBandDatasourceList(List: TStrings);
var
  i: Integer;
  s: String;
  sl: TStringList;
begin
  sl := TStringList.Create;
  frGetComponents(CurReport.Owner, TfrDataset, sl, nil);

  i := 0;
  while i < sl.Count do
  begin
    if BandDatasources.Count > 0 then
      if BandDatasources.IndexOf(sl[i]) <> -1 then
      begin
        s := BandDatasources[sl[i]];
        if s <> '' then
          sl[i] := s;
      end
      else
      begin
        sl.Delete(i);
        Dec(i);
      end;
    Inc(i);
  end;

  sl.Sort;
  List.Assign(sl);
  sl.Free;
end;

procedure TfrDataDictionary.GetCategoryList(List: TStrings);
var
  i: Integer;
  s: String;
begin
  List.Clear;
  for i := 0 to Variables.Count - 1 do
  begin
    s := Variables.Name[i];
    if (s <> '') and (s[1] = ' ') then
      List.Add(Copy(s, 2, 255));
  end;
end;

procedure TfrDataDictionary.GetVariablesList(Category: String; List: TStrings);
var
  i, j: Integer;
  s: String;
begin
  List.Clear;
  for i := 0 to Variables.Count - 1 do
  begin
    if AnsiCompareText(Variables.Name[i], ' ' + Category) = 0 then
    begin
      j := i + 1;
      while j < Variables.Count do
      begin
        s := Variables.Name[j];
        Inc(j);
        if (s <> '') and (s[1] <> ' ') then
          List.Add(s) else
          break
      end;
      break;
    end;
  end;
end;

{!!!}
function TfrDataDictionary.gsGetDataSet(ComplexName: String): TfrTDataSet;
begin
  Result := frGetDataSet(ComplexName);
end;

{ TfrReport }

constructor TfrReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPages := TfrPages.Create(Self);
  FEMFPages := TfrEMFPages.Create(Self);
  FDictionary := TfrDataDictionary.Create;
  FShowProgress := True;
  FModalPreview := True;
  FModifyPrepared := True;
  FPreviewButtons := [pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbHelp, pbExit];
  FInitialZoom := pzDefault;
  FileName := frLoadStr(SUntitled);
  FDefaultCopies := 1;
  FDefaultCollate := True;
  FPrintIfEmpty := True;
  FShowPrintDialog := True;
{$IFDEF 1CScript}
  Script := TStringList.Create;
{$ENDIF}
end;

destructor TfrReport.Destroy;
begin
  FDictionary.Free;
  FEMFPages.Free;
  FEMFPages := nil;
  FPages.Free;
{$IFDEF 1CScript}
  Script.Free;
{$ENDIF}
  inherited Destroy;
end;

procedure TfrReport.Clear;
begin
  Pages.Clear;
  Dictionary.Clear;
  if frDataManager <> nil then
    frDataManager.Clear;
end;

procedure TfrReport.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('ReportForm', ReadBinaryData, WriteBinaryData, True);
end;

procedure TfrReport.WriteBinaryData(Stream: TStream);
var
  n: Integer;
  Stream1: TMemoryStream;
begin
  n := frCurrentVersion;
  Stream.Write(n, 4);
  if FStoreInDFM then
  begin
    Stream1 := TMemoryStream.Create;
    SaveToStream(Stream1);
    Stream1.Position := 0;
    n := Stream1.Size;
    Stream.Write(n, 4);
    Stream.CopyFrom(Stream1, n);
    Stream1.Free;
  end;
end;

procedure TfrReport.ReadBinaryData(Stream: TStream);
var
  n: Integer;
begin
  Stream.Read(n, 4); // version
  if FStoreInDFM then
  begin
    Stream.Read(n, 4);
    FDFMStream := TMemoryStream.Create;
    FDFMStream.CopyFrom(Stream, n);
    FDFMStream.Position := 0;
  end;
end;

procedure TfrReport.Loaded;
begin
  inherited;
  if FStoreInDFM then
  begin
    LoadFromStream(FDFMStream);
    FDFMStream.Free;
  end;
end;

procedure TfrReport.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Dataset) then
    Dataset := nil;
  if (Operation = opRemove) and (AComponent = Preview) then
    Preview := nil;
end;

// report building events
procedure TfrReport.InternalOnProgress(Percent: Integer);
begin
  if Assigned(FOnProgress) then
    FOnProgress(Percent)
  else if FShowProgress then
  with frProgressForm do
  begin
    if (MasterReport.DoublePass and MasterReport.FinalPass) or
       (FCurrentFilter <> nil) then
      Label1.Caption := FirstCaption + '  ' + IntToStr(Percent) + ' ' +
        frLoadStr(SFrom) + ' ' + IntToStr(SavedAllPages)
    else
      Label1.Caption := FirstCaption + '  ' + IntToStr(Percent);
    Application.ProcessMessages;
  end;
end;

procedure TfrReport.InternalOnGetValue(ParName: String; var ParValue: String);
var
  i, j, Format: Integer;
  FormatStr: String;
begin
  SubValue := '';
  Format := CurView.Format;
  FormatStr := CurView.FormatStr;
  i := Pos(' #', ParName);
  if i <> 0 then
  begin
    FormatStr := Copy(ParName, i + 2, Length(ParName) - i - 1);
    ParName := Copy(ParName, 1, i - 1);

    if FormatStr[1] in ['0'..'9', 'N', 'n'] then
    begin
      if FormatStr[1] in ['0'..'9'] then
        FormatStr := 'N' + FormatStr;
      Format := $01000000;
      if FormatStr[2] in ['0'..'9'] then
        Format := Format + $00010000;
      i := Length(FormatStr);
      while i > 1 do
      begin
        if FormatStr[i] in ['.', ',', '-'] then
        begin
          Format := Format + Ord(FormatStr[i]);
          FormatStr[i] := '.';
          if FormatStr[2] in ['0'..'9'] then
          begin
            Inc(i);
            j := i;
            while (i <= Length(FormatStr)) and (FormatStr[i] in ['0'..'9']) do
              Inc(i);
            Format := Format + 256 * StrToInt(Copy(FormatStr, j, i - j));
          end;
          break;
        end;
        Dec(i);
      end;
      if not (FormatStr[2] in ['0'..'9']) then
      begin
        FormatStr := Copy(FormatStr, 2, 255);
        Format := Format + $00040000;
      end;
    end
    else if FormatStr[1] in ['D', 'T', 'd', 't'] then
    begin
      Format := $02040000;
      FormatStr := Copy(FormatStr, 2, 255);
    end
    else if FormatStr[1] in ['B', 'b'] then
    begin
      Format := $04040000;
      FormatStr := Copy(FormatStr, 2, 255);
    end;
  end;

  CurVariable := ParName;
  CurValue := 0;
  GetVariableValue(ParName, CurValue);
  try
    if ((CurView.Flags and flHideZeros) <> 0) and
       (TVarData(CurValue).VType <> varOleStr) and
       (TVarData(CurValue).VType <> varString) and
       (CurValue = 0) then
      CurValue := '';
  except;
  end;
  if not InitAggregate then
    ParValue := FormatValue(CurValue, Format, FormatStr);
end;

procedure TfrReport.InternalOnEnterRect(Memo: TStringList; View: TfrView);
begin
  with View do
    if (FDataSet <> nil) and frIsBlob(TfrTField(FDataSet.FindField(FField))) then
      GetBlob(TfrTField(FDataSet.FindField(FField)));
  if Assigned(FOnEnterRect) then FOnEnterRect(Memo, View);
end;

procedure TfrReport.InternalOnExportData(View: TfrView);
begin
  FCurrentFilter.OnData(View.x, View.y, View);
end;

procedure TfrReport.InternalOnExportText(DrawRect: TRect; x, y: Integer;
  const text: String; FrameTyp: Integer; View: TfrView);
begin
  FCurrentFilter.OnText(DrawRect, x, y, text, FrameTyp, View);
end;

procedure TfrReport.InternalOnBeginColumn(Band: TfrBand);
begin
  if Assigned(FOnBeginColumn) then FOnBeginColumn(Band);
end;

procedure TfrReport.InternalOnPrintColumn(ColNo: Integer; var ColWidth: Integer);
begin
  if Assigned(FOnPrintColumn) then FOnPrintColumn(ColNo, ColWidth);
end;

function TfrReport.FormatValue(V: Variant; Format: Integer;
  const FormatStr: String): String;
var
  f1, f2: Integer;
  c: Char;
  s: String;

  function Dup(ch: Char; Count: Integer): String;
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Count do
      Result := Result + ch;
  end;

  function frGetDateFormat(v: Variant): String;
  var
    DateTime: TDateTime;
    Buffer: array[0..1023] of Char;
    SystemTime: TSystemTime;
  begin
    DateTime := VarToDateTime(v);
    with SystemTime do
    begin
      DecodeDate(DateTime, wYear, wMonth, wDay);
      wDayOfWeek := Word(Abs(Trunc(DateTime) - 1) mod 7);
    end;
    GetDateFormat(GetThreadLocale, DATE_LONGDATE,
      @SystemTime, nil, Buffer, SizeOf(Buffer) - 1);
    Result := Buffer;
  end;

begin
  if (TVarData(v).VType = varEmpty) or (v = Null)
    or ((TVarData(v).VType = varString) and (Trim(v) = '')) then
  begin
    Result := '';
    Exit;
  end;
  c := DecimalSeparator;
  f1 := (Format div $01000000) and $0F;
  f2 := (Format div $00010000) and $FF;
  try
    case f1 of
      0: Result := v;
      1:
        begin
          DecimalSeparator := Chr(Format and $FF);
          case f2 of
            0: Result := FormatFloat('##0.' + Dup('#', (Format div $0100) and $FF), v);
            1: Result := FloatToStrF(v, ffFixed, 15, (Format div $0100) and $FF);
            2: Result := FormatFloat('#,##0.' + Dup('#', (Format div $0100) and $FF), v);
            3: Result := FloatToStrF(v, ffNumber, 15, (Format div $0100) and $FF);
            4: Result := FormatFloat(FormatStr, v);
          end;
        end;
      2: if f2 = 4 then
           Result := FormatDateTime(FormatStr, v)
         else if f2 = 3 then
           Result := frGetDateFormat(v)
         else
           Result := FormatDateTime(frDateFormats[f2], v);
      3: if f2 = 4 then
           Result := FormatDateTime(FormatStr, v) else
           Result := FormatDateTime(frTimeFormats[f2], v);
      4:
         begin
           if f2 = 4 then
             s := FormatStr else
             s := BoolStr[f2];
           if Integer(v) = 0 then
             Result := Copy(s, 1, Pos(';', s) - 1) else
             Result := Copy(s, Pos(';', s) + 1, 255);
         end;
    end;
  except
    Result := v;
  end;
  DecimalSeparator := c;
end;

procedure TfrReport.GetVariableValue(const s: String; var v: Variant);

  function MasterBand: TfrBand;
  begin
    Result := CurBand;
    if Result.DataSet = nil then
      while Result.Prev <> nil do
        Result := Result.Prev;
  end;

begin
  TVarData(v).VType := varEmpty;
  if Assigned(FOnGetValue) then FOnGetValue(s, v);
  if TVarData(v).VType = varEmpty then
  begin
    v := 0;
    if Dictionary.IsVariable(s) then
      v := Dictionary.Value[s]
    else
    begin
      if s = 'VALUE' then
        v := CurValue
      else if s = frSpecFuncs[0] then
        v := PageNo + 1
      else if s = frSpecFuncs[2] then
        v := CurDate
      else if s = frSpecFuncs[3] then
        v := CurTime
      else if s = frSpecFuncs[4] then
        v := MasterBand.Positions[psLocal]
      else if s = frSpecFuncs[5] then
        v := MasterBand.Positions[psGlobal]
      else if s = frSpecFuncs[6] then
        v := CurPage.ColPos
      else if s = frSpecFuncs[7] then
        v := CurPage.CurPos
      else if s = frSpecFuncs[8] then
        v := SavedAllPages
      else if s = 'CALCWIDTH' then
      begin
        if not Assigned(CurView) then
          v := 0
        else if CurView is TfrMemoView then
          with TfrMemoView(CurView) do
          begin
            ExpandMemoVariables;
            v := CalcWidth(Memo1);
          end
        else v := CurView.dx
      end
      else
      begin
        if frVariables.IndexOf(s) <> -1 then
        begin
          v := frVariables[s];
          Exit;
        end;
        TVarData(v).VType := varEmpty;
        GetIntrpValue(s, v);
        if TVarData(v).VType = varEmpty then
          if s <> SubValue then
          begin
            SubValue := s;
            v := frParser.Calc(s);
            SubValue := '';
          end
          else if not InitAggregate then
{$IFDEF 1CScript}
          begin
            V := frInterpretator.QueryValue(s);
            if TVarData(v).VType = varEmpty then
{$ENDIF}
            raise(EParserError.Create(frLoadStr(SUndefinedSymbol) + ' "' + SubValue + '"'));
{$IFDEF 1CScript}
          end;
{$ENDIF}
      end;
    end;
  end;
end;

{$IFDEF 1CScript}
procedure TfrReport.GetVariableV(const s: String; var v: Variant);

  procedure GetIntrpValue(const Name: String; var Value: Variant);
  var
    t: TfrObject;
    Prop: String;
  begin
    if (Name = 'CURY') or (Name = 'FREESPACE') or (Name = 'FINALPASS') or
       (Name = 'PAGEHEIGHT') or (Name = 'PAGEWIDTH') then Value := '0';
    ParseObjectName(Name, t, Prop);
    if (t <> nil) and (t.PropRec[Prop] <> nil) then
      Value := '0'
    else if frConsts.IndexOf(Name) <> -1 then
      Value := frConsts[Name];
  end;

begin
  TVarData(v).VType := varEmpty;
  if Assigned(FOnGetValue) then FOnGetValue(s, v);
  if TVarData(v).VType = varEmpty then
  begin
    if Dictionary.IsVariable(s) then
      v := Dictionary.Value[s]
    else
    begin
      if s = 'VALUE' then
        v := '0'
      else if s = frSpecFuncs[0] then
        v := '0'
      else if s = frSpecFuncs[2] then
        v := '0'
      else if s = frSpecFuncs[3] then
        v := '0'
      else if s = frSpecFuncs[4] then
        v := '0'
      else if s = frSpecFuncs[5] then
        v := '0'
      else if s = frSpecFuncs[6] then
        v := '0'
      else if s = frSpecFuncs[7] then
        v := '0'
      else if s = frSpecFuncs[8] then
        v := '0'
      else if s = 'CALCWIDTH' then
      begin
        if not Assigned(CurView) then
          v := 0
        else if CurView is TfrMemoView then
          with TfrMemoView(CurView) do
          begin
            ExpandMemoVariables;
            v := '0'
          end
        else v := '0'
      end
      else
      begin
        if frVariables.IndexOf(s) <> -1 then
        begin
          v := frVariables[s];
          Exit;
        end;
        TVarData(v).VType := varEmpty;
        GetIntrpValue(s, v);
      end;
    end;
  end;
end;
{$ENDIF}

procedure TfrReport.GetIntrpValue(const Name: String; var Value: Variant);
var
  t: TfrObject;
  Prop: String;
begin
  if Name = 'CURY' then
  begin
    Value := CurPage.CurY;
    Exit;
  end;
  if Name = 'FREESPACE' then
  begin
    Value := CurPage.CurBottomY - CurPage.CurY;
    Exit;
  end;
  if Name = 'FINALPASS' then
  begin
    Value := MasterReport.FinalPass;
    Exit;
  end;
  if Name = 'PAGEHEIGHT' then
  begin
    Value := CurPage.CurBottomY;
    Exit;
  end;
  if Name = 'PAGEWIDTH' then
  begin
    Value := CurPage.RightMargin;
    Exit;
  end;

  ParseObjectName(Name, t, Prop);
  if (t <> nil) and (t.PropRec[Prop] <> nil) then
    Value := t.Prop[Prop]
  else if frConsts.IndexOf(Name) <> -1 then
    Value := frConsts[Name];
end;

procedure TfrReport.OnGetParsFunction(const name: String; p1, p2, p3: Variant;
  var val: Variant);
var
  i: Integer;
begin
  val := '0';
  for i := 0 to frFunctionsCount - 1 do
    if frFunctions[i].FunctionLibrary.OnFunction(name, p1, p2, p3, val) then
      Exit;
  GetIntrpFunction(name, p1, p2, p3, val);
  if Assigned(FOnFunction) then FOnFunction(name, p1, p2, p3, val);
end;

procedure TfrReport.GetIntrpFunction(const Name: String; p1, p2, p3: Variant;
  var Val: Variant);
var
  Prop, s: String;
  t: TfrObject;
  v: Variant;
begin
  if Name = 'STOPREPORT' then
    CurReport.Terminated := True
  else if Name = 'NEWPAGE' then
    Inc(CurBand.CallNewPage)
  else if Name = 'NEWCOLUMN' then
    Inc(CurBand.CallNewColumn)
  else if Name = 'SHOWBAND' then
    CurPage.ShowBandByName(p1)
  else if Name = 'INC' then
  begin
    frParser.OnGetValue(p1, v);
    frInterpretator.SetValue(p1, v + 1);
  end
  else if Name = 'DEC' then
  begin
    frParser.OnGetValue(p1, v);
    frInterpretator.SetValue(p1, v - 1);
  end
  else if Name = 'SETARRAY' then
  begin
    if Pos('.', p1) <> 0 then
    begin
      ParseObjectName(p1, t, Prop);
      if t <> nil then
        t.DoMethod('SETINDEXPROPERTY', AnsiUpperCase(Prop),
          frParser.Calc(p2), frParser.Calc(p3));
    end
    else
    begin
      v := frParser.Calc(p2);
      if TVarData(v).VType = varString then
        s := v else
        s := IntToStr(v);
      frVariables['Arr_' + p1 + '_' + s] := frParser.Calc(p3);
    end;
  end
  else if Name = 'GETARRAY' then
  begin
    if Pos('.', p1) <> 0 then
    begin
      ParseObjectName(p1, t, Prop);
      if t <> nil then
        Val := t.DoMethod('GETINDEXPROPERTY', AnsiUpperCase(Prop),
          frParser.Calc(p2), Null);
    end
    else
    begin
      v := frParser.Calc(p2);
      if TVarData(v).VType = varString then
        s := v else
        s := IntToStr(v);
      Val := frVariables['Arr_' + p1 + '_' + s];
    end;
  end
  else
  begin
    ParseObjectName(Name, t, Prop);
    if t <> nil then
      Val := t.DoMethod(Prop, p1, p2, p3)
  end
end;


// load/save methods
procedure TfrReport.LoadFromStream(Stream: TStream);
{$IFDEF 1CScript}
const Signature : array[0..2] of Byte = ($F0, $C0, $00);
var
  b: byte;
  p, pp, i: Integer;
  MemStream: TMemoryStream;
  pc: PChar;
{$ENDIF}
begin
  DocMode := dmDesigning;
  while not frThreadDone do
    Application.ProcessMessages;
  CurReport := Self;
  Dictionary.Clear;
  if Stream.Size = 0 then Exit;

  Stream.Read(frVersion, 1);
  if frVersion < 21 then
  begin
    frVersion := 21;
    Stream.Position := 0;
  end;
  ErrorFlag := False;
  ErrorStr := '';
  if frVersion <= frCurrentVersion then
  try
{$IFDEF 1CScript}
    Script.Clear;
    for i := 0 to 2 do
    begin
      Stream.Read(b, 1);
      if b <> Signature[i] then
      begin
        Stream.Position := Stream.Position - i - 1;
        break;
      end
      else if i = 2 then
      begin
        Stream.Read(p, 4);
        pp := Stream.Position;
        MemStream := TMemoryStream.Create;
        GetMem(pc, p);
        Stream.Read(pc^, p);
        MemStream.Write(pc^, p);
        MemStream.Position := 0;
        Script.LoadFromStream(MemStream);
        FreeMem(pc, p);
        MemStream.Free;
        Stream.Position := pp + p;
      end;
    end;
{$ENDIF}
    Pages.LoadFromStream(Stream);
  except
    on E: EClassNotFound do
      Application.MessageBox(PChar('Report contains the following non-plugged components:' +
        #13 + E.Message + 'You must include these components into your project.'), PChar(frLoadStr(SError)),
        mb_Ok or MB_IconError);
    else
    begin
      Application.MessageBox(PChar(frLoadStr(SFRFError)), PChar(frLoadStr(SError)),
        mb_Ok or MB_IconError);
      Pages.Clear;
      Pages.Add;
    end;
  end
  else
    Application.MessageBox(PChar(frLoadStr(SFRFError)), PChar(frLoadStr(SError)),
      mb_Ok or MB_IconError);
end;

procedure TfrReport.SaveToStream(Stream: TStream);
{$IFDEF 1CScript}
const Signature : array[0..2] of Byte = ($F0, $C0, $00);
var MemStream : TMemoryStream;
    b : byte;
    i : integer;
{$ENDIF}
begin
  CurReport := Self;
  frVersion := frCurrentVersion;
  Stream.Write(frVersion, 1);
{$IFDEF 1CScript}
  if Script.Count > 0 then
  begin
    for i := 0 to 2 do
    begin
      b := Signature[i];
      Stream.Write(b, 1);
    end;
    MemStream := TMemoryStream.Create;
    Script.SaveToStream(MemStream);
    i := MemStream.Size;
    Stream.Write(i, 4);
    MemStream.Position := 0;
    MemStream.SaveToStream(Stream);
    MemStream.Free;
  end;
{$ENDIF}
  Pages.SaveToStream(Stream);
end;

function TfrReport.LoadFromFile(FName: String): Boolean;
var
  Stream: TFileStream;
begin
  Result := FileExists(FName);
  if Result then
  begin
    Stream := TFileStream.Create(FName, fmOpenRead);
    try
      LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
    FileName := FName;
  end;
end;

procedure TfrReport.SaveToFile(FName: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

{$IFDEF IBO}
procedure TfrReport.LoadFromDB(Table: TIB_DataSet; DocN: Integer);
{$ELSE}
procedure TfrReport.LoadFromDB(Table: TDataSet; DocN: Integer);
{$ENDIF}
var
  Stream: TMemoryStream;
begin
  Table.First;
  while not Table.Eof do
  begin
    if Table.Fields[0].AsInteger = DocN then
    begin
      Stream := TMemoryStream.Create;
{$IFDEF IBO}
      TfrTBlobField(Table.Fields[1]).AssignTo(Stream);
{$ELSE}
      TfrTBlobField(Table.Fields[1]).SaveToStream(Stream);
{$ENDIF}
      Stream.Position := 0;
      LoadFromStream(Stream);
      Stream.Free;
      Exit;
    end;
    Table.Next;
  end;
end;

{$IFDEF IBO}
procedure TfrReport.SaveToDB(Table: TIB_DataSet; DocN: Integer);
{$ELSE}
procedure TfrReport.SaveToDB(Table: TDataSet; DocN: Integer);
{$ENDIF}
var
  Stream: TMemoryStream;
  Found: Boolean;
begin
  Found := False;
  Table.First;
  while not Table.Eof do
  begin
    if Table.Fields[0].AsInteger = DocN then
    begin
      Found := True;
      break;
    end;
    Table.Next;
  end;

  if Found then
    Table.Edit else
    Table.Append;
  Table.Fields[0].AsInteger := DocN;
  Stream := TMemoryStream.Create;
  SaveToStream(Stream);
  Stream.Position := 0;
{$IFDEF IBO}
  TfrTBlobField(Table.Fields[1]).Assign(Stream);
{$ELSE}
  TfrTBlobField(Table.Fields[1]).LoadFromStream(Stream);
{$ENDIF}
  Stream.Free;
  Table.Post;
end;

{$IFDEF IBO}
procedure TfrReport.SaveToBlobField(Blob: TIB_ColumnBlob);
{$ELSE}
procedure TfrReport.SaveToBlobField(Blob: TField);
{$ENDIF}
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    SaveToStream(Stream);
    Stream.Position := 0;
{$IFDEF IBO}
    Blob.Assign(Stream);
{$ELSE}
    TfrTBlobField(Blob).LoadFromStream(Stream);
{$ENDIF}
  finally
    Stream.Free;
  end;
end;

{$IFDEF IBO}
procedure TfrReport.LoadFromBlobField(Blob: TIB_ColumnBlob);
{$ELSE}
procedure TfrReport.LoadFromBlobField(Blob: TField);
{$ENDIF}
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
{$IFDEF IBO}
    Blob.AssignTo(Stream);
{$ELSE}
    TfrTBlobField(Blob).SaveToStream(Stream);
{$ENDIF}
    Stream.Position := 0;
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TfrReport.LoadFromResourceName(Instance: THandle;
  const ResName: string);
var
  Stream: TCustomMemoryStream;
begin
  Stream := TResourceStream.Create(Instance, ResName, RT_RCDATA);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TfrReport.LoadFromResourceID(Instance: THandle; ResID: Integer);
var
  Stream: TCustomMemoryStream;
begin
  Stream := TResourceStream.CreateFromID(Instance, ResID, RT_RCDATA);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TfrReport.LoadPreparedReport(FName: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FName, fmOpenRead);
  EMFPages.LoadFromStream(Stream);
  Stream.Free;
  CanRebuild := False;
end;

procedure TfrReport.SavePreparedReport(FName: String);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FName, fmCreate);
  EMFPages.SaveToStream(Stream);
  Stream.Free;
end;

procedure TfrReport.LoadTemplate(FName: String; comm: TStrings;
  Bmp: TBitmap; Load: Boolean);
var
  Stream: TFileStream;
  b: Byte;
  fb: TBitmap;
  fm: TStringList;
  pos: Integer;
begin
  fb := TBitmap.Create;
  fm := TStringList.Create;
  Stream := TFileStream.Create(FName, fmOpenRead);
  frVersion := frCurrentVersion;
  if Load then
  begin
    ReadMemo(Stream, fm);
    Stream.Read(pos, 4);
    Stream.Read(b, 1);
    if b <> 0 then
      fb.LoadFromStream(Stream);
    Stream.Position := pos;
    Pages.LoadFromStream(Stream);
  end
  else
  begin
    ReadMemo(Stream, Comm);
    Stream.Read(pos, 4);
    Bmp.Assign(nil);
    Stream.Read(b, 1);
    if b <> 0 then
      Bmp.LoadFromStream(Stream);
  end;
  fm.Free; fb.Free;
  Stream.Free;
end;

procedure TfrReport.SaveTemplate(FName: String; Comm: TStrings; Bmp: TBitmap);
var
  Stream: TFileStream;
  b: Byte;
  pos, lpos: Integer;
begin
  Stream := TFileStream.Create(FName, fmCreate);
  frVersion := frCurrentVersion;
  frWriteMemo(Stream, Comm);
  b := 0;
  pos := Stream.Position;
  lpos := 0;
  Stream.Write(lpos, 4);
  if Bmp.Empty then
    Stream.Write(b, 1)
  else
  begin
    b := 1;
    Stream.Write(b, 1);
    Bmp.SaveToStream(Stream);
  end;
  lpos := Stream.Position;
  Stream.Position := pos;
  Stream.Write(lpos, 4);
  Stream.Position := lpos;
  Pages.SaveToStream(Stream);
  Stream.Free;
end;

// report manipulation methods
function TfrReport.DesignReport: TModalResult;
var
  HF: String;
begin
  SetPrinterTo(FPrnName);
  if Pages.Count = 0 then Pages.Add;
  CurReport := Self;
  HF := Application.HelpFile;
  Application.HelpFile := 'FRuser.hlp';
  Result := mrCancel;
  if frDesignerClass <> nil then
  begin
    frDesigner := TfrReportDesigner(frDesignerClass.NewInstance);
    frDesigner.CreateDesigner(True);
    {$IFDEF 1CScript}
    frInterpretator.OnGetValue := GetVariableV;
    frInterpretator.Global := True;
    frInterpretator.PrepareScript(Script, Script, SMemo);
    frInterpretator.Global := False;
    {$ENDIF}
    Result := frDesigner.ShowModal;
    frDesigner.Free;
    frDesigner := nil;
  end;
  Application.HelpFile := HF;
end;

procedure TfrReport.BuildBeforeModal(Sender: TObject);
begin
  DoBuildReport;
  if FinalPass then
    if Terminated then
      frProgressForm.ModalResult := mrCancel else
      frProgressForm.ModalResult := mrOk
  else
  begin
    SavedAllPages := EMFPages.Count;
    DoublePass := False;
    if not Terminated then
      DoPrepareReport
    else
    begin
      EMFPages.Clear;
      frProgressForm.ModalResult := mrCancel
    end;
    DoublePass := True;
  end;
end;

{$WARNINGS OFF}
function TfrReport.PrepareReport: Boolean;
var
  ParamOk: Boolean;
  StreamList: TList;
  TempStream: TMemoryStream;
  SaveErrorFlag: Boolean;
  SaveError: String;
  i: Integer;
  r: TfrReport;
begin
  SetPrinterTo(FPrnName);
  DocMode := dmPrinting;
  CurDate := Date; CurTime := Time;
  Pages.RefreshObjects;
  CurPage := nil; CurBand := nil;
  MasterReport := Self;
  CurReport := Self;
  _DoublePass := DoublePass;
  frParser.OnGetValue := GetVariableValue;
  frParser.OnFunction := OnGetParsFunction;

  Result := False;
{$IFDEF 1CScript}
  frInterpretator.Global := True;
  frInterpretator.DoScript(Script);
  frInterpretator.Global := False;
{$ENDIF}

  if Self is TfrCompositeReport then
  begin
    StreamList := TList.Create;
    for i := 0 to TfrCompositeReport(Self).Reports.Count - 1 do
    begin
      TempStream := TMemoryStream.Create;
      StreamList.Add(TempStream);
      r := TfrReport(TfrCompositeReport(Self).Reports[i]);
      r.SaveToStream(TempStream);
      if Assigned(r.FOnBeginDoc) then r.FOnBeginDoc;
    end;
    if Assigned(FOnBeginDoc) then FOnBeginDoc;

    ParamOk := True;
    if frDataManager <> nil then
    begin
      FillQueryParams;
      ParamOk := frDataManager.ShowParamsDialog;
    end;
    if ParamOk then
      Result := DoPrepareReport;
    if Assigned(FOnEndDoc) then FOnEndDoc;
    SaveErrorFlag := ErrorFlag;
    SaveError := ErrorStr;
    for i := 0 to TfrCompositeReport(Self).Reports.Count - 1 do
    begin
      TempStream := StreamList[i];
      TempStream.Position := 0;
      r := TfrReport(TfrCompositeReport(Self).Reports[i]);
      if Assigned(r.FOnEndDoc) then r.FOnEndDoc;
      r.LoadFromStream(TempStream);
      TempStream.Free;
    end;
    StreamList.Free;
  end
  else
  begin
    TempStream := TMemoryStream.Create;
    SaveToStream(TempStream);
    if Assigned(FOnBeginDoc) then FOnBeginDoc;

    ParamOk := True;
    if frDataManager <> nil then
    begin
      FillQueryParams;
      ParamOk := frDataManager.ShowParamsDialog;
    end;
    if ParamOk then
      Result := DoPrepareReport;
    if Assigned(FOnEndDoc) then FOnEndDoc;

    SaveErrorFlag := ErrorFlag;
    SaveError := ErrorStr;
    TempStream.Position := 0;
    LoadFromStream(TempStream);
    TempStream.Free;
  end;

  FinalPass := False;

  if Result and DontShowReport then
    Result := False;
  if SaveErrorFlag then
  begin
    Application.MessageBox(PChar(SaveError), PChar(frLoadStr(SError)),
      mb_Ok or MB_IconError);
    EMFPages.Clear;
  end
  else if DontShowReport then
    EMFPages.Clear;
  DisableDrawing := False;
  CurBand := nil;
end;
{$WARNINGS ON}

function TfrReport.DoPrepareReport: Boolean;
var
  s: String;
begin
  Result := True;
  Terminated := False;
  Append := False;
  DisableDrawing := False;
  FinalPass := True;
  PageNo := 0;
  EMFPages.Clear;

  s := frLoadStr(SReportPreparing);
  if DoublePass then
  begin
    DisableDrawing := True;
    FinalPass := False;
    if not Assigned(FOnProgress) and FShowProgress then
      with frProgressForm do
      begin
        if Title = '' then
          Caption := s else
          Caption := s + ' - ' + Title;
        FirstCaption := frLoadStr(SFirstPass);
        Label1.Caption := FirstCaption + '  1';
        OnBeforeModal := BuildBeforeModal;
        Show_Modal(Self);
      end
    else
      BuildBeforeModal(nil);
    Exit;
  end;
  if not Assigned(FOnProgress) and FShowProgress then
    with frProgressForm do
    begin
      if Title = '' then
        Caption := s else
        Caption := s + ' - ' + Title;
      FirstCaption := frLoadStr(SPagePreparing);
      Label1.Caption := FirstCaption + '  1';
      OnBeforeModal := BuildBeforeModal;
      if _DoublePass then
      begin
        DoublePass := True;
        BuildBeforeModal(nil);
      end
      else
      begin
        SavedAllPages := 0;
        if Show_Modal(Self) = mrCancel then
          Result := False;
      end;
    end
  else
  begin
    DoublePass := _DoublePass;
    BuildBeforeModal(nil);
  end;
//  Terminated := False;
end;

var
  ExportStream: TFileStream;

procedure TfrReport.ExportBeforeModal(Sender: TObject);
var
  i: Integer;
begin
  Application.ProcessMessages;
  for i := 0 to EMFPages.Count - 1 do
  begin
    FCurrentFilter.OnBeginPage;
    EMFPages.ExportData(i);
    InternalOnProgress(i + 1);
    Application.ProcessMessages;
    FCurrentFilter.OnEndPage;
  end;
  FCurrentFilter.OnEndDoc;
  frProgressForm.ModalResult := mrOk;
end;

procedure TfrReport.ExportTo(Filter: TfrExportFilter; FileName: String);
var
  s: String;
  Flag, NeedConnect: Boolean;
begin
  DocMode := dmPrinting;
  FCurrentFilter := Filter;
  FCurrentFilter.FileName := FileName;
  if (Preview <> nil) and (EMFPages.Count = 0) then
  begin
    Preview.Disconnect;
    NeedConnect := True;
  end
  else
    NeedConnect := False;

  Flag := True;
  if Assigned(FCurrentFilter.OnBeforeExport) then
    FCurrentFilter.OnBeforeExport(FCurrentFilter.FileName, Flag);
  if Flag and (FCurrentFilter.ShowModal = mrOk) then
  begin
    ExportStream := TFileStream.Create(FileName, fmCreate);
    FCurrentFilter.Stream := ExportStream;
    FCurrentFilter.OnBeginDoc;

    CurReport := Self;
    MasterReport := Self;
    SavedAllPages := EMFPages.Count;

    if FShowProgress then
    begin
      with frProgressForm do
      begin
        s := frLoadStr(SReportPreparing);
        if Title = '' then
          Caption := s else
          Caption := s + ' - ' + Title;
        FirstCaption := frLoadStr(SPagePreparing);
        Label1.Caption := FirstCaption + '  1';
        OnBeforeModal := ExportBeforeModal;
        Show_Modal(Self);
      end;
    end
    else
      ExportBeforeModal(Self);

    ExportStream.Free;
    if Assigned(FCurrentFilter.OnAfterExport) then
      FCurrentFilter.OnAfterExport(FCurrentFilter.FileName);
  end;

  if NeedConnect then
    Preview.Connect(Self);
  FCurrentFilter := nil;
end;

procedure TfrReport.FillQueryParams;
var
  i, j: Integer;
  t: TfrView;

  procedure PrepareDS(ds: TfrDataSet);
  begin
    if (ds <> nil) and (ds is TfrDBDataSet) then
      frDataManager.PrepareDataSet(TfrTDataSet((ds as TfrDBDataSet).GetDataSet));
  end;

begin
  if frDataManager = nil then Exit;
  frDataManager.BeforePreparing;
  if Dataset <> nil then
    PrepareDS(DataSet);
  for i := 0 to Pages.Count - 1 do
    for j := 0 to Pages[i].Objects.Count - 1 do
    begin
      t := Pages[i].Objects[j];
      if t is TfrBandView then
        PrepareDS(frFindComponent(CurReport.Owner, t.FormatStr) as TfrDataSet);
    end;
  frDataManager.AfterPreparing;
end;

procedure TfrReport.DoBuildReport;
var
  i: Integer;
  b: Boolean;
begin
  Application.ProcessMessages;
  CanRebuild := True;
  DocMode := dmPrinting;
  CurReport := Self;
  Dictionary.ClearCache;
  frParser.OnGetValue := GetVariableValue;
  frParser.OnFunction := OnGetParsFunction;
  ErrorFlag := False;
  b := (Dataset <> nil) and (ReportType = rtMultiple);
  if b then
  begin
    Dataset.Init;
    Dataset.First;
  end;
  if not MasterReport.DoublePass or not MasterReport.FinalPass then
  begin
    HookList.Clear;
    for i := 0 to Pages.Count - 1 do
      Pages[i].Skip := False;
    DontShowReport := False;
  end;
  for i := 0 to Pages.Count - 1 do
  begin
    if Pages[i].PageType = ptDialog then
      Pages[i].InitPage;
    if DontShowReport then break;
  end;

  try
    if not DontShowReport then
    begin
      if not MasterReport.DoublePass or not MasterReport.FinalPass then
        if Assigned(FOnCrossBeginDoc) then FOnCrossBeginDoc;
      for i := 0 to Pages.Count - 1 do
        if Pages[i].PageType = ptReport then
          Pages[i].InitPage;
      for i := 0 to Pages.Count - 1 do
        if Pages[i].PageType = ptReport then
          Pages[i].PrepareObjects;

      repeat
        InternalOnProgress(PageNo + 1);
        for i := 0 to Pages.Count - 1 do
        begin
          FCurPage := Pages[i];
          CurPage := FCurPage;
          CurPage.PageNumber := i + 1;
          with FCurPage do
          begin
            if not Visible then
              DoScript(Script);
            if Skip or (PageType = ptDialog) or not Visible then continue;
            Mode := pmNormal;
          end;
          FCurPage.FormPage;

          Append := False;
          if ((i = Pages.Count - 1) and CompositeMode and (not b or Dataset.Eof)) or
             ((i <> Pages.Count - 1) and Pages[i + 1].PrintToPrevPage) then
          begin
            Dec(PageNo);
            Append := True;
          end;
          if not Append then
          begin
            PageNo := MasterReport.EMFPages.Count;
            InternalOnProgress(PageNo);
          end;
          if MasterReport.Terminated then break;
        end;
        InternalOnProgress(PageNo);
        if b then Dataset.Next;
      until MasterReport.Terminated or not b or Dataset.Eof;
    end;

  finally
    for i := 0 to Pages.Count - 1 do
      if Pages[i].PageType = ptReport then
        Pages[i].DonePage;
    for i := 0 to Pages.Count - 1 do
      if Pages[i].PageType = ptDialog then
        Pages[i].DonePage;
  end;
  if b then
    Dataset.Exit;
  if (frDataManager <> nil) and MasterReport.FinalPass then
    frDataManager.AfterPreparing;
end;

procedure TfrReport.ShowReport;
begin
  PrepareReport;
  ShowPreparedReport;
end;

procedure TfrReport.ShowPreparedReport;
var
  s: String;
  p: TfrPreviewForm;
begin
  CurReport := Self;
  MasterReport := Self;
  DocMode := dmPrinting;
  CurBand := nil;
  if EMFPages.Count = 0 then Exit;
  s := frLoadStr(SPreview);
  if Title <> '' then s := s + ' - ' + Title;
  if not (csDesigning in ComponentState) and Assigned(Preview) then
    Preview.Connect(Self)
  else
  begin
    if csDesigning in ComponentState then
      p := TfrPreviewForm.Create(nil) else
      p := TfrPreviewForm.Create(Self);
    if MDIPreview then
    begin
      p.WindowState := wsNormal;
      p.FormStyle := fsMDIChild;
    end;
    p.Caption := s;
    p.Show_Modal(Self);
    Application.ProcessMessages;
  end;
end;

procedure TfrReport.PrintBeforeModal(Sender: TObject);
begin
  DoPrintReport(FPageNumbers, FCopies, FCollate, FPrintPages);
  frProgressForm.ModalResult := mrOk;
end;

procedure TfrReport.PrintPreparedReport(PageNumbers: String; Copies: Integer;
  Collate: Boolean; PrintPages: TfrPrintPages);
var
  s: String;
  NeedConnect: Boolean;
  SaveMouseOverEvent: TMouseOverObjectEvent;
begin
  CurReport := Self;
  MasterReport := Self;
  s := frLoadStr(SReportPreparing);
  Terminated := False;
  FPageNumbers := PageNumbers;
  FCopies := Copies;
  FCollate := Collate;
  FPrintPages := PrintPages;
  if (Preview <> nil) and (EMFPages.Count = 0) then
  begin
    Preview.Disconnect;
    NeedConnect := True;
  end
  else
    NeedConnect := False;

  if not Assigned(FOnProgress) and FShowProgress then
    with frProgressForm do
    begin
      if Title = '' then
        Caption := s else
        Caption := s + ' - ' + Title;
      FirstCaption := frLoadStr(SPagePrinting);
      Label1.Caption := FirstCaption;
      OnBeforeModal := PrintBeforeModal;
      Show_Modal(Self);
    end
  else
  begin
    SaveMouseOverEvent := OnMouseOverObject;
    OnMouseOverObject := nil;
    PrintBeforeModal(nil);
    OnMouseOverObject := SaveMouseOverEvent;
  end;
//  Terminated := False;
  if NeedConnect then
    Preview.Connect(Self);
end;

procedure TfrReport.PrintPreparedReportDlg;
var
  Pages: String;
begin
  if (EMFPages = nil) or (Printer.Printers.Count = 0) then Exit;
  if Preview <> nil then
    Preview.Print else
  begin
    with TfrPrintForm.Create(nil) do
    begin
      RB2.Enabled := False;
      E1.Text := IntToStr(FDefaultCopies);
      CollateCB.Checked := FDefaultCollate;
      if not FShowPrintDialog or (ShowModal = mrOk) then
      begin
{        if Printer.PrinterIndex <> ind then
          if CanRebuild then
            if ChangePrinter(ind, Printer.PrinterIndex) then
              PrepareReport
            else
            begin
              Free;
              Exit;
            end;}
        if RB1.Checked then
          Pages := ''
        else
          Pages := E2.Text;
        PrintPreparedReport(Pages, StrToInt(E1.Text),
          CollateCB.Checked, TfrPrintPages(CB2.ItemIndex));
      end;
      Free;
    end;
  end;
end;

{$IFDEF Trial}
{$HINTS OFF}
procedure TfrReport.DoPrintReport(PageNumbers: String; Copies: Integer;
  Collate: Boolean; PrintPages: TfrPrintPages);
var
  i, j: Integer;
  f: Boolean;
  pgList: TStringList;

  procedure ParsePageNumbers;
  var
    i, j, n1, n2: Integer;
    s: String;
    IsRange: Boolean;
  begin
    s := PageNumbers;
    while Pos(' ', s) <> 0 do
      Delete(s, Pos(' ', s), 1);
    if s = '' then Exit;

    s := s + ',';
    i := 1; j := 1; n1 := 1;
    IsRange := False;
    while i <= Length(s) do
    begin
      if s[i] = ',' then
      begin
        n2 := StrToInt(Copy(s, j, i - j));
        j := i + 1;
        if IsRange then
          while n1 <= n2 do
          begin
            pgList.Add(IntToStr(n1));
            Inc(n1);
          end
        else
          pgList.Add(IntToStr(n2));
        IsRange := False;
      end
      else if s[i] = '-' then
      begin
        IsRange := True;
        n1 := StrToInt(Copy(s, j, i - j));
        j := i + 1;
      end;
      Inc(i);
    end;
  end;

  procedure PrintPage(n: Integer);
  var
    s: String[40];
  begin
    with Printer, EMFPages[n]^ do
    begin
      if not Prn.IsEqual(pgSize, pgWidth, pgHeight, pgBin, pgOr) then
      begin
        EndDoc;
        Prn.SetPrinterInfo(pgSize, pgWidth, pgHeight, pgBin, pgOr, True);
        BeginDoc;
      end
      else if not f then NewPage;
      Prn.FillPrnInfo(PrnInfo);
      Visible := True;

      with PrnInfo, pgMargins do
        if UseMargins then
          EMFPages.Draw(n, Printer.Canvas, Rect(-POfx, -POfy, PPgw - POfx, PPgh - POfy))
        else
          EMFPages.Draw(n, Printer.Canvas,
            Rect(Round(Left * PPw / Pw), Round(Top * PPh / Ph),
                 PPw - Round(Right * PPw / Pw),
                 PPh - Round(Bottom * PPh / Ph)));

      Visible := False;
      EMFPages.Draw(n, Printer.Canvas, Rect(0, 0, 0, 0));

      s[0] := #25;
      s[1] := 'F';
      s[2] := 'a';
      s[3] := 's';
      s[4] := 't';
      s[5] := 'R';
      s[6] := 'e';
      s[7] := 'p';
      s[8] := 'o';
      s[9] := LowerCase(s[5])[1];
      s[10] := s[4];
      s[11] := ' ';
      s[12] := '-';
      s[13] := s[11];
      s[14] := 'u';
      s[15] := 'n';
      s[16] := s[9];
      s[17] := s[6];
      s[18] := 'g';
      s[19] := 'i';
      s[20] := s[3];
      s[21] := s[4];
      s[22] := s[6];
      s[23] := s[9];
      s[24] := s[6];
      s[25] := 'd';
      Canvas.TextOut(10, 10, s);
    end;
    InternalOnProgress(n + 1);
    Application.ProcessMessages;
    f := False;
    Printer.EndDoc;
    pgList.Free;
  end;

begin
  Prn.Printer := Printer;
  pgList := TStringList.Create;

  ParsePageNumbers;
  if Copies <= 0 then
    Copies := 1;

  with EMFPages[0]^ do
  begin
    Prn.SetPrinterInfo(pgSize, pgWidth, pgHeight, pgBin, pgOr, True);
    Prn.FillPrnInfo(PrnInfo);
  end;
  if Title <> '' then
    Printer.Title := Title else
    Printer.Title := frLoadStr(SUntitled);
  if Assigned(FOnPrintReportEvent) then
    FOnPrintReportEvent;

  Printer.BeginDoc;
  f := True;
  for i := 0 to EMFPages.Count - 1 do
    if (pgList.Count = 0) or (pgList.IndexOf(IntToStr(i + 1)) <> -1) then
    begin
      PrintPage(i);
      Exit;
    end;
end;
{$HINTS ON}
{$ELSE}
procedure TfrReport.DoPrintReport(PageNumbers: String; Copies: Integer;
  Collate: Boolean; PrintPages: TfrPrintPages);
var
  i, j: Integer;
  f: Boolean;
  pgList: TStringList;

  procedure ParsePageNumbers;
  var
    i, j, n1, n2: Integer;
    s: String;
    IsRange: Boolean;
  begin
    s := PageNumbers;
    while Pos(' ', s) <> 0 do
      Delete(s, Pos(' ', s), 1);
    if s = '' then Exit;

    if s[Length(s)] = '-' then
      s := s + IntToStr(EMFPages.Count);
    s := s + ',';
    i := 1; j := 1; n1 := 1;
    IsRange := False;
    while i <= Length(s) do
    begin
      if s[i] = ',' then
      begin
        n2 := StrToInt(Copy(s, j, i - j));
        j := i + 1;
        if IsRange then
          while n1 <= n2 do
          begin
            pgList.Add(IntToStr(n1));
            Inc(n1);
          end
        else
          pgList.Add(IntToStr(n2));
        IsRange := False;
      end
      else if s[i] = '-' then
      begin
        IsRange := True;
        n1 := StrToInt(Copy(s, j, i - j));
        j := i + 1;
      end;
      Inc(i);
    end;
  end;

  procedure PrintPage(n: Integer);
  begin
    if not ((PrintPages = frAll) or
       ((PrintPages = frOdd) and ((n + 1) mod 2 = 1)) or
       ((PrintPages = frEven) and ((n + 1) mod 2 = 0))) then Exit;

    with Printer, EMFPages[n]^ do
    begin
      if not Prn.IsEqual(pgSize, pgWidth, pgHeight, pgBin, pgOr) then
      begin
        EndDoc;
        Prn.SetPrinterInfo(pgSize, pgWidth, pgHeight, pgBin, pgOr, True);
        BeginDoc;
      end
      else if not f then
        NewPage;
      Prn.FillPrnInfo(PrnInfo);
      Visible := True;

      with PrnInfo, pgMargins do
        if UseMargins then
          EMFPages.Draw(n, Printer.Canvas, Rect(-POfx, -POfy, PPgw - POfx, PPgh - POfy))
        else
          EMFPages.Draw(n, Printer.Canvas,
            Rect(Round(Left * PPw / Pw), Round(Top * PPh / Ph),
                 PPw - Round(Right * PPw / Pw),
                 PPh - Round(Bottom * PPh / Ph)));

      Visible := False;
      EMFPages.Draw(n, Printer.Canvas, Rect(0, 0, 0, 0));
    end;
    InternalOnProgress(n + 1);
    Application.ProcessMessages;
    f := False;
  end;

begin
  Prn.Printer := Printer;
  pgList := TStringList.Create;

  ParsePageNumbers;
  if Copies <= 0 then
    Copies := 1;

  with EMFPages[0]^ do
  begin
    Prn.SetPrinterInfo(pgSize, pgWidth, pgHeight, pgBin, pgOr, True);
    Prn.FillPrnInfo(PrnInfo);
  end;
  if Title <> '' then
    Printer.Title := Title else
    Printer.Title := frLoadStr(SUntitled);
  if Assigned(FOnPrintReportEvent) then
    FOnPrintReportEvent;

  if Collate then
    Printer.Copies := 1 else
    Printer.Copies := Copies;
  Printer.BeginDoc;
  f := True;
  if Collate then
  begin
    for j := 0 to Copies - 1 do
      for i := 0 to EMFPages.Count - 1 do
        if (pgList.Count = 0) or (pgList.IndexOf(IntToStr(i + 1)) <> -1) then
        begin
          PrintPage(i);
          if Terminated then
          begin
            Printer.Abort;
            pgList.Free;
            Exit;
          end;
        end;
  end
  else
    for i := 0 to EMFPages.Count - 1 do
      if (pgList.Count = 0) or (pgList.IndexOf(IntToStr(i + 1)) <> -1) then
//        for j := 0 to Copies - 1 do
        begin
          PrintPage(i);
          if Terminated then
          begin
            Printer.Abort;
            pgList.Free;
            Exit;
          end;
        end;
  Printer.EndDoc;
  pgList.Free;
end;
{$ENDIF}

// printer manipulation methods

procedure TfrReport.SetPrinterTo(PrnName: String);
begin
  if not PrintToDefault then
    if Prn.Printers.IndexOf(PrnName) <> -1 then
      Prn.PrinterIndex := Prn.Printers.IndexOf(PrnName);
  FPrnName := PrnName;
end;

function TfrReport.ChangePrinter(OldIndex, NewIndex: Integer): Boolean;
  procedure ChangePages;
  var
    i: Integer;
  begin
    for i := 0 to Pages.Count - 1 do
      with Pages[i] do
        ChangePaper(pgSize, pgWidth, pgHeight, pgBin, pgOr);
  end;
begin
  Result := True;
  try
    Prn.PrinterIndex := NewIndex;
    FPrnName := Prn.Printers[Prn.PrinterIndex];
    Prn.PaperSize := -1;
    ChangePages;
  except
    on Exception do
    begin
      Application.MessageBox(PChar(frLoadStr(SPrinterError)),
        PChar(frLoadStr(SError)), mb_IconError or MB_Ok);
      Prn.PrinterIndex := OldIndex;
      FPrnName := Prn.Printers[Prn.PrinterIndex];
      ChangePages;
      Result := False;
    end;
  end;
end;

procedure TfrReport.EditPreparedReport(PageIndex: Integer);
var
  p: PfrPageInfo;
  Stream: TMemoryStream;
  Designer: TfrReportDesigner;
begin
  if frDesignerClass = nil then Exit;
  Screen.Cursor := crHourGlass;
  Designer := frDesigner;
  if Designer <> nil then
    Designer.Page := nil;

  frDesigner := TfrReportDesigner(frDesignerClass.NewInstance);
  frDesigner.CreateDesigner(False);

  Stream := TMemoryStream.Create;
  SaveToStream(Stream);
  Pages.Clear;
  EMFPages.ObjectsToPage(PageIndex);
  p := EMFPages[PageIndex];
  Pages.FPages.Add(p^.Page);
  CurReport := Self;
  Screen.Cursor := crDefault;
  try
    frDesigner.ShowModal;
    if frDesigner.Modified then
      if Application.MessageBox(PChar(frLoadStr(SSaveChanges) + '?'),
        PChar(frLoadStr(SConfirm)), mb_YesNo or MB_IconQuestion) = mrYes then
        EMFPages.PageToObjects(PageIndex);
  finally
    Pages.FPages.Clear;
    Stream.Position := 0;
    LoadFromStream(Stream);
    Stream.Free;
    frDesigner.Free;
    frDesigner := Designer;
    if frDesigner <> nil then
      frDesigner.Page := Pages[0];
  end;
end;

function TfrReport.FindObject(Name: String): TfrView;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Pages.Count - 1 do
  begin
    Result := Pages[i].FindObject(Name);
    if Result <> nil then
      break;
  end;
end;

{ TfrCompositeReport }

constructor TfrCompositeReport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Reports := TList.Create;
end;

destructor TfrCompositeReport.Destroy;
begin
  Reports.Free;
  inherited Destroy;
end;

procedure TfrCompositeReport.DoBuildReport;
var
  i: Integer;
  Doc, NextDoc: TfrReport;
  ParamOk: Boolean;
  b: Boolean;
  TempStream: TMemoryStream;
begin
  CanRebuild := True;
  PageNo := 0;
  b := Dataset <> nil;
  if b then
  begin
    Dataset.Init;
    Dataset.First;
  end;
  repeat
    for i := 0 to Reports.Count - 1 do
    begin
      TempStream := TMemoryStream.Create;
      Doc := TfrReport(Reports[i]);
      if b then
        Doc.SaveToStream(TempStream);
      CompositeMode := False;
      if i <> Reports.Count - 1 then
      begin
        NextDoc := TfrReport(Reports[i + 1]);
        if (NextDoc.Pages.Count > 0) and
          NextDoc.Pages[0].PrintToPrevPage then
          CompositeMode := True;
        if EMFPages.Count > 0 then
        begin
          if (NextDoc.Pages.Count > 0) and
            ((EMFPages[EMFPages.Count - 1].pgOr <> NextDoc.Pages[0].pgOr) or
             (EMFPages[EMFPages.Count - 1].pgSize <> NextDoc.Pages[0].pgSize)) then
            CompositeMode := False;
        end
        else
        begin
          if (NextDoc.Pages.Count > 0) and
            ((Doc.Pages[Doc.Pages.Count - 1].pgOr <> NextDoc.Pages[0].pgOr) or
             (Doc.Pages[Doc.Pages.Count - 1].pgSize <> NextDoc.Pages[0].pgSize)) then
            CompositeMode := False;
        end;
      end;
      ParamOk := True;
      if frDataManager <> nil then
      begin
        Doc.FillQueryParams;
        ParamOk := frDataManager.ShowParamsDialog;
      end;
      if ParamOk then
        Doc.DoBuildReport;
      if (frDataManager <> nil) and FinalPass then
        frDataManager.AfterParamsDialog;
      TempStream.Position := 0;
      if b then
        Doc.LoadFromStream(TempStream);
      TempStream.Free;

      Append := CompositeMode;
      CompositeMode := False;
      if Terminated then break;
    end;
    if b then Dataset.Next;
  until Terminated or not b or Dataset.Eof;
  if b then
    Dataset.Exit;
end;


{ TfrReportDesigner }

constructor TfrReportDesigner.CreateDesigner(AFirstInstance: Boolean);
begin
  FirstInstance := AFirstInstance;
  inherited Create(nil);
end;


{ TfrObjEditorForm }

function TfrObjEditorForm.ShowEditor(View: TfrView): TModalResult;
begin
  Result := mrOk;
end;


{ TfrExportFilter }

constructor TfrExportFilter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Lines := TList.Create;
end;

destructor TfrExportFilter.Destroy;
begin
  ClearLines;
  Lines.Free;
  inherited Destroy;
end;

procedure TfrExportFilter.ClearLines;
var
  i: Integer;
  p, p1: PfrTextRec;
begin
  for i := 0 to Lines.Count - 1 do
  begin
    p := PfrTextRec(Lines[i]);
    while p <> nil do
    begin
      p1 := p;
      p := p^.Next;
      Dispose(p1);
    end;
  end;
  Lines.Clear;
end;

function TfrExportFilter.ShowModal: Word;
begin
  Result := mrOk;
end;

procedure TfrExportFilter.OnBeginDoc;
begin
// abstract method
end;

procedure TfrExportFilter.OnEndDoc;
begin
// abstract method
end;

procedure TfrExportFilter.OnBeginPage;
begin
// abstract method
end;

procedure TfrExportFilter.OnEndPage;
begin
// abstract method
end;

procedure TfrExportFilter.OnData(x, y: Integer; View: TfrView);
begin
// abstract method
end;

procedure TfrExportFilter.OnText(DrawRect: TRect; x, y: Integer;
  const text: String; FrameTyp: Integer; View: TfrView);
begin
// abstract method
end;


{ TfrFunctionLibrary }

constructor TfrFunctionLibrary.Create;
begin
  inherited Create;
  List := TStringList.Create;
//  List.Sorted := True;
end;

destructor TfrFunctionLibrary.Destroy;
begin
  List.Free;
  inherited Destroy;
end;

function TfrFunctionLibrary.OnFunction(const FName: String; p1, p2, p3: Variant;
  var val: Variant): Boolean;
var
  i: Integer;
begin
  Result := False;
  i := List.IndexOf(FName);
  if i >= 0 then
  begin
    DoFunction(i, p1, p2, p3, val);
    Result := True;
  end;
end;

procedure TfrFunctionLibrary.AddFunctionDesc(FuncName, Category, Description: String);
begin
  frAddFunctionDesc(Self, FuncName, Category, Description);
end;

{ TfrCompressor }

constructor TfrCompressor.Create;
begin
  inherited Create;
// abstract method
end;

procedure TfrCompressor.Compress(StreamIn, StreamOut: TStream);
begin
// abstract method
end;

procedure TfrCompressor.DeCompress(StreamIn, StreamOut: TStream);
begin
// abstract method
end;

{ TfrInstalledFunctions }

constructor TfrInstalledFunctions.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TfrInstalledFunctions.Destroy;
var
  p: PfrFunctionDesc;
begin
  while FList.Count > 0 do
  begin
    p := FList[0];
    Dispose(p);
    FList.Delete(0);
  end;
  FList.Free;
  inherited Destroy;
end;

procedure TfrInstalledFunctions.Add(FunctionLibrary: TfrFunctionLibrary;
  FuncName, Category, Description: String);
var
  p: PfrFunctionDesc;
  i: Integer;
begin
  if Category = '' then Exit;
  for i := 0 to FList.Count - 1 do
  begin
    p := FList[i];
    if p.Name = FuncName then Exit;
  end;

  New(p);
  p.FunctionLibrary := FunctionLibrary;
  p.Name := FuncName;
  p.Category := Category;
  p.Description := Description;
  FList.Add(p);
end;

function TfrInstalledFunctions.GetFunctionDesc(FuncName: String): String;
var
  i: Integer;
  p: PfrFunctionDesc;
begin
  Result := '';
  for i := 0 to FList.Count - 1 do
  begin
    p := FList[i];
    if AnsiCompareText(p.Name, FuncName) = 0 then
    begin
      Result := p.Description;
      break;
    end;
  end;
end;

procedure TfrInstalledFunctions.GetCategoryList(List: TStrings);
var
  i: Integer;
  p: PfrFunctionDesc;
  sl: TStringList;
begin
  sl := TStringList.Create;
  for i := 0 to FList.Count - 1 do
  begin
    p := FList[i];
    if sl.IndexOf(p.Category) = -1 then
      sl.Add(p.Category);
  end;
  sl.Sort;
  List.Assign(sl);
  sl.Free;
end;

procedure TfrInstalledFunctions.GetFunctionList(Category: String;
  List: TStrings);
var
  i: Integer;
  p: PfrFunctionDesc;
  sl: TStringList;
begin
  sl := TStringList.Create;
  if Category = frLoadStr(SAllCategories) then
    Category := '';
  for i := 0 to FList.Count - 1 do
  begin
    p := FList[i];
    if (Category = '') or (AnsiCompareText(p.Category, Category) = 0) then
      sl.Add(p.Name);
  end;
  sl.Sort;
  List.Assign(sl);
  sl.Free;
end;

procedure TfrInstalledFunctions.UnRegisterFunctionLibrary(FunctionLibrary: TfrFunctionLibrary);
var
  p: PfrFunctionDesc;
  i: Integer;
begin
  i := 0;
  while i < FList.Count do
  begin
    p := FList[i];
    if (p.FunctionLibrary <> nil) and (p.FunctionLibrary.ClassName = FunctionLibrary.ClassName) then
    begin
      Dispose(p);
      FList.Delete(i);
    end
    else
      Inc(i);
  end;
end;



function frLocale: TfrLocale;
begin
  if FLocale = nil then
    FLocale := TfrLocale.Create;
  Result := FLocale;
end;


{ TfrLocale }

constructor TfrLocale.Create;
begin
  FIDEMode := AnsiUpperCase(ExtractFileName(Application.ExeName)) = 'DELPHI32.EXE';
end;

function TfrLocale.LoadBmp(ID: String): HBitmap;
var
  Handle: THandle;
begin
  if FLoaded then
    Handle := FDllHandle else
    Handle := HInstance;
  try
    Result := LoadBitmap(Handle, PChar(ID));
  except
    Result := 0;
  end;
end;

function TfrLocale.LoadStr(ID: Integer): String;
var
  Buffer: array[0..1023] of Char;
  Handle: THandle;
begin
  if Assigned(FOnLocalize) then
  begin
    Result := '';
    FOnLocalize(ID, Result);
    if Result <> '' then
      Exit;
  end;

  if FLoaded then
    Handle := FDllHandle else
    Handle := HInstance;

  if FIDEMode then
    Result := SysUtils.LoadStr(ID) else
    SetString(Result, Buffer, LoadString(Handle, ID, Buffer, SizeOf(Buffer)));
end;

procedure TfrLocale.LoadDll(Name: String);
begin
  if FLoaded then
    UnloadDll;
  FDllHandle := LoadLibrary(PChar(Name));
  FLoaded := FDllHandle <> HINSTANCE_ERROR;
  if frGlobals <> nil then
    frGlobals.Localize;
  if Prn <> nil then
    Prn.Localize;
end;

procedure TfrLocale.UnloadDll;
begin
  if FLoaded then
    FreeLibrary(FDllHandle);
  FLoaded := False;
  if frGlobals <> nil then
    frGlobals.Localize;
  if Prn <> nil then
    Prn.Localize;
end;


{ TfrGlobals }

constructor TfrGlobals.Create;
const
  Clr: Array[0..1] of TColor = (clWhite, clSilver);
var
  i, j: Integer;
begin
  Localize;
  SMemo := TStringList.Create;
  SBmp := TBitmap.Create;
  TempBmp := TBitmap.Create;
  SBmp.Width := 8; SBmp.Height := 8;
  TempBmp.Width := 8; TempBmp.Height := 8;
  for j := 0 to 7 do
    for i := 0 to 7 do
      SBmp.Canvas.Pixels[i, j] := Clr[(j + i) mod 2];
  frProgressForm := TfrProgressForm.Create(nil);
  frInstalledFunctions := TfrInstalledFunctions.Create;
  frRegisterFunctionLibrary(TfrStdFunctionLibrary);

  frParser := TfrParser.Create;
  frInterpretator := TInterpretator.Create;
  frVariables := TfrVariables.Create;
  frVariables.Sorted := True;

  frConsts := TfrVariables.Create;
  frConsts.Sorted := True;
  for i := 0 to 41 do
    if i <> 16 then
      frConsts[frColorNames[i]] := frColors[i] else
      frConsts[frColorNames[i]] := clNone;

  frConsts['mrNone'] := mrNone;
  frConsts['mrOk'] := mrOk;
  frConsts['mrCancel'] := mrCancel;
  frConsts['mrYes'] := mrYes;
  frConsts['mrNo'] := mrNo;

  frConsts['CRLF'] := #13#10;
  frConsts['Null'] := Null;

  frConsts['fsBold'] := 2;
  frConsts['fsItalic'] := 1;
  frConsts['fsUnderline'] := 4;
  frConsts['fsStrikeOut'] := 8;

  frConsts['frftNone'] := 0;
  frConsts['frftRight'] := 1;
  frConsts['frftBottom'] := 2;
  frConsts['frftLeft'] := 4;
  frConsts['frftTop'] := 8;

  frConsts['frtaLeft'] := 0;
  frConsts['frtaRight'] := 1;
  frConsts['frtaCenter'] := 2;
  frConsts['frtaVertical'] := 4;
  frConsts['frtaMiddle'] := 8;
  frConsts['frtaDown'] := 16;

  frConsts['baNone'] := 0;
  frConsts['baLeft'] := 1;
  frConsts['baRight'] := 2;
  frConsts['baCenter'] := 3;
  frConsts['baWidth'] := 4;
  frConsts['baBottom'] := 5;
  frConsts['baTop'] := 6;
  frConsts['baRest'] := 7;

  frConsts['psSolid'] := psSolid;
  frConsts['psDash'] := psDash;
  frConsts['psDot'] := psDot;
  frConsts['psDashDot'] := psDashDot;
  frConsts['psDashDotDot'] := psDashDotDot;
  frConsts['psDouble'] := psDouble;

  frConsts['mb_Ok'] := mb_Ok;
  frConsts['mb_OkCancel'] := mb_OkCancel;
  frConsts['mb_YesNo'] := mb_YesNo;
  frConsts['mb_YesNoCancel'] := mb_YesNoCancel;
  frConsts['mb_IconError'] := mb_IconError;
  frConsts['mb_IconQuestion'] := mb_IconQuestion;
  frConsts['mb_IconInformation'] := mb_IconInformation;
  frConsts['mb_IconWarning'] := mb_IconWarning;

  frConsts['psDashDotDot'] := psDashDotDot;
  frConsts['psDouble'] := psDouble;

  frCompressor := TfrCompressor.Create;
  HookList := TList.Create;
  frDialogForm := TForm.Create(nil);
  frDialogForm.SetBounds(-100, -100, 10, 10);
  frDialogForm.Name := 'DialogForm';
end;

destructor TfrGlobals.Destroy;
begin       
  FLocale.Free;
  FLocale := nil;
  SBmp.Free;
  TempBmp.Free;
  SMemo.Free;
  frProgressForm.Free;
  frDialogForm.Free;
  frUnRegisterFunctionLibrary(TfrStdFunctionLibrary);
  frParser.Free;
  frInterpretator.Free;
  frVariables.Free;
  frConsts.Free;
  frCompressor.Free;
  HookList.Free;
  frInstalledFunctions.Free;
  inherited Destroy;
end;

procedure TfrGlobals.Localize;
var
  i: Integer;
begin
  frCharset := StrToInt(frLoadStr(SCharset));
  for i := 0 to 22 do
    frBandNames[i] := frLoadStr(SBand1 + i);
  for i := 0 to 3 do
    BoolStr[i] := frLoadStr(SFormat51 + i);
  for i := 0 to 3 do
  begin
    frDateFormats[i] := frLoadStr(SDateFormat1 + i);
    frTimeFormats[i] := frLoadStr(STimeFormat1 + i);
  end;
end;

{ TfrStdFunctionLibrary }

constructor TfrStdFunctionLibrary.Create;
var
  rsAggregate, rsDateTime, rsString, rsOther, rsMath, rsBool, rsInterpr: String;
begin
  inherited Create;
  with List do
  begin
    Add('AVG');
    Add('COUNT');
    Add('DAYOF');
    Add('FORMATDATETIME');
    Add('FORMATFLOAT');
    Add('FORMATTEXT');
    Add('INPUT');
    Add('LENGTH');
    Add('LOWERCASE');
    Add('MAX');
    Add('MAXNUM');
    Add('MESSAGEBOX');
    Add('MIN');
    Add('MINNUM');
    Add('MONTHOF');
    Add('NAMECASE');
    Add('POS');
    Add('SUM');
    Add('TRIM');
    Add('UPPERCASE');
    Add('YEAROF');
  end;

  rsAggregate := frLoadStr(SAggregateCategory);
  rsDateTime := frLoadStr(SDateTimeCategory);
  rsString := frLoadStr(SStringCategory);
  rsOther := frLoadStr(SOtherCategory);
  rsMath := frLoadStr(SMathCategory);
  rsBool := frLoadStr(SBoolCategory);
  rsInterpr := frLoadStr(SIntrpCategory);

  AddFunctionDesc('AVG', rsAggregate, frLoadStr(SDescriptionAVG));
  AddFunctionDesc('COUNT', rsAggregate, frLoadStr(SDescriptionCOUNT));
  AddFunctionDesc('DAYOF', rsDateTime, frLoadStr(SDescriptionDAYOF));
  AddFunctionDesc('FORMATDATETIME', rsString, frLoadStr(SDescriptionFORMATDATETIME));
  AddFunctionDesc('FORMATFLOAT', rsString, frLoadStr(SDescriptionFORMATFLOAT));
  AddFunctionDesc('FORMATTEXT', rsString, frLoadStr(SDescriptionFORMATTEXT));
  AddFunctionDesc('INPUT', rsOther, frLoadStr(SDescriptionINPUT));
  AddFunctionDesc('LENGTH', rsString, frLoadStr(SDescriptionLENGTH));
  AddFunctionDesc('LOWERCASE', rsString, frLoadStr(SDescriptionLOWERCASE));
  AddFunctionDesc('MAX', rsAggregate, frLoadStr(SDescriptionMAX));
  AddFunctionDesc('MIN', rsAggregate, frLoadStr(SDescriptionMIN));
  AddFunctionDesc('MONTHOF', rsDateTime, frLoadStr(SDescriptionMONTHOF));
  AddFunctionDesc('NAMECASE', rsString, frLoadStr(SDescriptionNAMECASE));
  AddFunctionDesc('STRTODATE', rsDateTime, frLoadStr(SDescriptionSTRTODATE));
  AddFunctionDesc('STRTOTIME', rsDateTime, frLoadStr(SDescriptionSTRTOTIME));
  AddFunctionDesc('SUM', rsAggregate, frLoadStr(SDescriptionSUM));
  AddFunctionDesc('TRIM', rsString, frLoadStr(SDescriptionTRIM));
  AddFunctionDesc('UPPERCASE', rsString, frLoadStr(SDescriptionUPPERCASE));
  AddFunctionDesc('YEAROF', rsDateTime, frLoadStr(SDescriptionYEAROF));
  AddFunctionDesc('MAXNUM', rsMath, frLoadStr(SDescriptionMAXNUM));
  AddFunctionDesc('MINNUM', rsMath, frLoadStr(SDescriptionMINNUM));
  AddFunctionDesc('POS', rsString, frLoadStr(SDescriptionPOS));
  AddFunctionDesc('MESSAGEBOX', rsOther, frLoadStr(SDescriptionMESSAGEBOX));


// Other standard functions not included in this library
  AddFunctionDesc('IF', rsOther, frLoadStr(SDescriptionIF));
  AddFunctionDesc('COPY', rsString, frLoadStr(SDescriptionCOPY));
  AddFunctionDesc('MOD', rsMath, frLoadStr(SDescriptionMOD));
  AddFunctionDesc('STR', rsString, frLoadStr(SDescriptionSTR));
  AddFunctionDesc('NOT', rsBool, frLoadStr(SDescriptionNOT));
  AddFunctionDesc('AND', rsBool, frLoadStr(SDescriptionAND));
  AddFunctionDesc('OR', rsBool, frLoadStr(SDescriptionOR));
  AddFunctionDesc('ROUND', rsMath, frLoadStr(SDescriptionROUND));
  AddFunctionDesc('FRAC', rsMath, frLoadStr(SDescriptionFRAC));
  AddFunctionDesc('INT', rsMath, frLoadStr(SDescriptionINT));
  AddFunctionDesc('TRUE', rsBool, frLoadStr(SDescriptionTRUE));
  AddFunctionDesc('FALSE', rsBool, frLoadStr(SDescriptionFALSE));

// Special functions
  AddFunctionDesc('PAGE#', rsOther, frLoadStr(SDescriptionPAGE));
  AddFunctionDesc('DATE', rsDateTime, frLoadStr(SDescriptionDATE));
  AddFunctionDesc('TIME', rsDateTime, frLoadStr(SDescriptionTIME));
  AddFunctionDesc('LINE#', rsOther, frLoadStr(SDescriptionLINE));
  AddFunctionDesc('LINETHROUGH#', rsOther, frLoadStr(SDescriptionLINETHROUGH));
  AddFunctionDesc('COLUMN#', rsOther, frLoadStr(SDescriptionCOLUMN));
  AddFunctionDesc('TOTALPAGES', rsOther, frLoadStr(SDescriptionTOTALPAGES));

// Interpreter
  AddFunctionDesc('MROK', rsInterpr, frLoadStr(SDescriptionMROK));
  AddFunctionDesc('MRCANCEL', rsInterpr, frLoadStr(SDescriptionMRCANCEL));
  AddFunctionDesc('CURY', rsInterpr, frLoadStr(SDescriptionCURY));
  AddFunctionDesc('FREESPACE', rsInterpr, frLoadStr(SDescriptionFREESPACE));
  AddFunctionDesc('FINALPASS', rsInterpr, frLoadStr(SDescriptionFINALPASS));
  AddFunctionDesc('PAGEHEIGHT', rsInterpr, frLoadStr(SDescriptionPAGEHEIGHT));
  AddFunctionDesc('PAGEWIDTH', rsInterpr, frLoadStr(SDescriptionPAGEWIDTH));
  AddFunctionDesc('PROGRESS', rsInterpr, frLoadStr(SDescriptionPROGRESS));
  AddFunctionDesc('MODALRESULT', rsInterpr, frLoadStr(SDescriptionMODALRESULT));
  AddFunctionDesc('STOPREPORT', rsInterpr, frLoadStr(SDescriptionSTOPREPORT));
  AddFunctionDesc('NEWPAGE', rsInterpr, frLoadStr(SDescriptionNEWPAGE));
  AddFunctionDesc('NEWCOLUMN', rsInterpr, frLoadStr(SDescriptionNEWCOLUMN));
  AddFunctionDesc('SHOWBAND', rsInterpr, frLoadStr(SDescriptionSHOWBAND));
  AddFunctionDesc('INC', rsInterpr, frLoadStr(SDescriptionINC));
  AddFunctionDesc('DEC', rsInterpr, frLoadStr(SDescriptionDEC));
end;

procedure TfrStdFunctionLibrary.DoFunction(FNo: Integer; p1, p2, p3: Variant;
  var val: Variant);
var
  at: Integer;
  s: String;
  Want: TfrBandType;
  b: TfrBand;
  v, v1: Variant;
begin
  at := atNone;
  val := '0';
  case FNo of
    0: at := atAvg;
    1: at := atCount;
    2: val := StrToInt(FormatDateTime('d', frParser.Calc(p1)));
    3: val := FormatDateTime(frParser.Calc(p1), frParser.Calc(p2));
    4: val := FormatFloat(frParser.Calc(p1), frParser.Calc(p2));
    5: val := FormatMaskText(frParser.Calc(p1) + ';0; ', frParser.Calc(p2));
    6: val := InputBox('', frParser.Calc(p1), frParser.Calc(p2));
    7: val := Length(frParser.Calc(p1));
    8: val := AnsiLowerCase(frParser.Calc(p1));
    9: at := atMax;
   10:
      begin
        v := frParser.Calc(p1);
        v1 := frParser.Calc(p2);
        if v > v1 then
          val := v else
          val := v1;
      end;
   11: val := Application.MessageBox(PChar(String(frParser.Calc(p1))),
          PChar(String(frParser.Calc(p2))), frParser.Calc(p3));
   12: at := atMin;
   13:
      begin
        v := frParser.Calc(p1);
        v1 := frParser.Calc(p2);
        if v < v1 then
          val := v else
          val := v1;
      end;
   14: val := StrToInt(FormatDateTime('m', frParser.Calc(p1)));
   15:
      begin
        s := AnsiLowerCase(frParser.Calc(p1));
        if Length(s) > 0 then
          val := AnsiUpperCase(s[1]) + Copy(s, 2, Length(s) - 1) else
          val := '';
      end;
   16: val := Pos(frParser.Calc(p1), frParser.Calc(p2));
   17: at := atSum;
   18: val := Trim(frParser.Calc(p1));
   19: val := AnsiUpperCase(frParser.Calc(p1));
   20: val := StrToInt(FormatDateTime('yyyy', frParser.Calc(p1)));
  end;
  if at <> atNone then
  begin
    s := p2;
    if at = atCount then
    begin
      s := p1;
      p3 := p2;
    end;
    if InitAggregate then
    begin
      if s = '' then
      begin
        Want := btNone;
        case CurBand.Typ of
          btPageFooter, btMasterFooter, btGroupFooter, btReportSummary:
            Want := btMasterData;
          btDetailFooter:
            Want := btDetailData;
          btSubdetailFooter:
            Want := btSubdetailData;
          btCrossFooter:
            Want := btCrossData;
        end;
        if AggrBand.Typ <> Want then
          Exit else
          s := AggrBand.Name;
      end;
// format is: BandName # AggrTyp # Expression # IncludeNonVisible #
// for Count: BandName # AggrTyp # NotUsed    # IncludeNonVisible #
      if AnsiCompareText(AggrBand.Name, Trim(s)) = 0 then
      begin
        s := CurBand.Name;
        if (CurBand.Typ <> btCrossFooter) and CurBand.HasCross then
          s := '0' + #1 + s;
        if at = atMin then
          v := 1e300 else
          v := 0;
        AggrBand.AddAggregateValue(s + #1 + Chr(at) + #1 + p1 + #1 + p3 + #1, v);
        CurBand.AggrBand := AggrBand;
      end;
    end
    else if CurBand.AggrBand <> nil then
    begin
      b := CurBand;
      s := b.Name;
      if b.Typ = btCrossData then
      begin
        b := b.AggrBand;
        s := IntToStr(CurPage.ColPos) + #1 + b.Name;
      end;
      val := b.AggrBand.GetAggregateValue(s + #1 + Chr(at) + #1 + p1 + #1 + p3 + #1);
    end;
  end;
end;

{ TInterpretator }

procedure TInterpretator.GetValue(const Name: String; var Value: Variant);
begin
  frParser.OnGetValue(Name, Value);
end;

procedure TInterpretator.SetValue(const Name: String; Value: Variant);
var
  t: TfrObject;
  Prop: String;
begin
  if frVariables.IndexOf(Name) <> -1 then
  begin
    frVariables[Name] := Value;
    Exit;
  end;
  if CurReport.Dictionary.IsVariable(Name) then
  begin
    CurReport.Dictionary.Variables[Name] := Value;
    Exit;
  end;
  if AnsiCompareText(Name, 'MODALRESULT') = 0 then
  begin
    if CurPage.PageType = ptDialog then
      CurPage.Form.ModalResult := Value;
    Exit;
  end;
  if AnsiCompareText(Name, 'CURY') = 0 then
  begin
    if (CurBand.CallNewPage > 0) or (CurBand.CallNewColumn > 0) then
      CurBand.SaveCurY := True;
    CurPage.CurY := Value;
    Exit;
  end;
  if AnsiCompareText(Name, 'PROGRESS') = 0 then
  begin
    frProgressForm.Label2.Caption := Value;
    Application.ProcessMessages;
    Exit;
  end;

  ParseObjectName(Name, t, Prop);
  if (t <> nil) and (t.PropRec[Prop] <> nil) then
    t.Prop[Prop] := Value else
    frVariables[Name] := Value;
end;

procedure TInterpretator.DoFunction(const Name: String; p1, p2, p3: Variant;
  var Val: Variant);
begin
  frParser.OnFunction(Name, p1, p2, p3, val);
end;

{ TAggregateFunctionsSplitter }

constructor TAggregateFunctionsSplitter.CreateSplitter(SplitTo: TStrings);
begin
  FMatchFuncs := TStringList.Create;
  FMatchFuncs.Add('AVG');
  FMatchFuncs.Add('COUNT');
  FMatchFuncs.Add('MAX');
  FMatchFuncs.Add('MIN');
  FMatchFuncs.Add('SUM');
  inherited Create(FMatchFuncs, SplitTo, CurReport.Dictionary.Variables);
end;

destructor TAggregateFunctionsSplitter.Destroy;
begin
  FMatchFuncs.Free;
  inherited Destroy;
end;

procedure TAggregateFunctionsSplitter.SplitMemo(Memo: TStrings);
var
  i: Integer;

  procedure SplitStr(s: String);
  var
    i, j: Integer;
    s1: String;
  begin
    i := 1;
    repeat
      while (i < Length(s)) and (s[i] <> '[') do Inc(i);
      s1 := GetBrackedVariable(s, i, j);
      if i <> j then
      begin
        Split('[' + s1 + ']');
        i := j + 1;
      end;
    until i = j;
  end;

begin
  for i := 0 to Memo.Count - 1 do
    SplitStr(Memo[i]);
end;

procedure TAggregateFunctionsSplitter.SplitScript(Script: TStrings);
begin
  if Script.Count = 0 then Exit;
  with TfrInterpretator.Create do
  begin
    SplitExpressions(Script, FMatchFuncs, FSplitTo, FVariables);
    Free;
  end;
end;


initialization
  frGlobals := TfrGlobals.Create;

finalization
  frGlobals.Free;
  frGlobals := nil;

end.

