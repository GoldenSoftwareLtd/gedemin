
{******************************************}
{                                          }
{             FastReport v2.53             }
{             Report Designer              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Desgn;

interface

{$I FR.inc}

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Printers, ComCtrls,
  Menus {$IFDEF Delphi4}, ImgList {$ENDIF}, FR_Class, FR_Color,
  FR_Ctrls, FR_Dock, FR_Insp, FR_Flds1, FR_Combo, FR_Edit, FR_Edit1;

const
  MaxUndoBuffer = 100;
  crPencil = 11;

type
  TLoadReportEvent = procedure(Report: TfrReport; var ReportName: String;
    var Opened: Boolean) of object;
  TSaveReportEvent = procedure(Report: TfrReport; var ReportName: String;
    SaveAs: Boolean; var Saved: Boolean) of object;

  TfrDesignerForm = class;

  TfrDesigner = class(TComponent)  // fake component
  private
    FCloseQuery: Boolean;
    FHideDisabledButtons: Boolean;
    FTemplDir, FOpenDir, FSaveDir: String;
    FOnLoadReport: TLoadReportEvent;
    FOnSaveReport: TSaveReportEvent;
    FOnShow: TNotifyEvent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property CloseQuery: Boolean read FCloseQuery write FCloseQuery default True;
    property HideDisabledButtons: Boolean read FHideDisabledButtons write FHideDisabledButtons default True;
    property OpenDir: String read FOpenDir write FOpenDir;
    property SaveDir: String read FSaveDir write FSaveDir;
    property TemplateDir: String read FTemplDir write FTemplDir;
    property OnLoadReport: TLoadReportEvent read FOnLoadReport write FOnLoadReport;
    property OnSaveReport: TSaveReportEvent read FOnSaveReport write FOnSaveReport;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
  end;

  TfrSelectionType = (ssBand, ssMemo, ssOther, ssMultiple, ssClipboardFull);
  TfrSelectionStatus = set of TfrSelectionType;
  TfrReportUnits = (ruPixels, ruMM, ruInches);
  TfrShapeMode = (smFrame, smAll);
  TfrDesignerDrawMode = (dmAll, dmSelection, dmShape);
  TfrDesignerRestriction =
    (frdrDontEditObj, frdrDontModifyObj, frdrDontSizeObj, frdrDontMoveObj,
     frdrDontDeleteObj, frdrDontCreateObj,
     frdrDontDeletePage, frdrDontCreatePage, frdrDontEditPage,
     frdrDontCreateReport, frdrDontLoadReport, frdrDontSaveReport,
     frdrDontPreviewReport, frdrDontEditVariables, frdrDontChangeReportOptions);
  TfrDesignerRestrictions = set of TfrDesignerRestriction;

  TfrUndoAction = (acInsert, acDelete, acEdit, acZOrder);
  PfrUndoObj = ^TfrUndoObj;
  TfrUndoObj = record
    Next: PfrUndoObj;
    ObjID: Integer;
    ObjPtr: TfrView;
    Int: Integer;
  end;

  TfrUndoRec = record
    Action: TfrUndoAction;
    Page: Integer;
    Objects: PfrUndoObj;
  end;

  PfrUndoRec1 = ^TfrUndoRec1;
  TfrUndoRec1 = record
    ObjPtr: TfrView;
    Int: Integer;
  end;

  PfrUndoBuffer = ^TfrUndoBuffer;
  TfrUndoBuffer = Array[0..MaxUndoBuffer - 1] of TfrUndoRec;

  TfrMenuItemInfo = class(TObject)
  private
    MenuItem: TMenuItem;
    Btn: TfrSpeedButton;
  end;

  TfrSplitInfo = record
    SplRect: TRect;
    SplX: Integer;
    View1, View2: TfrView;
  end;

  TfrDesignerPage = class(TPanel)
  private
    Down,                          // mouse button was pressed
    Moved,                         // mouse was moved (with pressed btn)
    DFlag,                         // was double click
    RFlag: Boolean;                // selecting objects by framing
    Mode: (mdInsert, mdSelect);    // current mode
    CT: (ctNone, ct1, ct2, ct3, ct4, ct5, ct6, ct7, ct8);  // cursor type
    LastX, LastY: Integer;         // here stored last mouse coords
    SplitInfo: TfrSplitInfo;
    RightBottom: Integer;
    LeftTop: TPoint;
    FirstBandMove: Boolean;
    WasCtrl: Boolean;
    FDesigner: TfrDesignerForm;
    FDrag: Boolean;
    DisableDraw: Boolean;
    procedure NormalizeRect(var r: TRect);
    procedure NormalizeCoord(t: TfrView);
    function FindNearestEdge(var x, y: Integer): Boolean;
    procedure RoundCoord(var x, y: Integer);
    procedure Draw(N: Integer; ClipRgn: HRGN);
    procedure DrawPage(DrawMode: TfrDesignerDrawMode);
    procedure DrawRectLine(Rect: TRect);
    procedure DrawFocusRect(Rect: TRect);
    procedure DrawHSplitter(Rect: TRect);
    procedure DrawSelection(t: TfrView);
    procedure DrawShape(t: TfrView);
    procedure MDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure DClick(Sender: TObject);
    procedure DoDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DoDragDrop(Sender, Source: TObject; X, Y: Integer);
  protected
    procedure Paint; override;
    procedure WMEraseBackground(var Message: TMessage); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Init;
    procedure SetPage;
    procedure GetMultipleSelected;
  end;

  TfrDesignerForm = class(TfrReportDesigner)
    StatusBar1: TStatusBar;
    frDock1: TfrDock;
    frDock2: TfrDock;
    frDock3: TfrDock;
    Popup1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    MainMenu1: TMainMenu;
    FileMenu: TMenuItem;
    EditMenu: TMenuItem;
    ToolMenu: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    N23: TMenuItem;
    N24: TMenuItem;
    N25: TMenuItem;
    N27: TMenuItem;
    N28: TMenuItem;
    N26: TMenuItem;
    N29: TMenuItem;
    N30: TMenuItem;
    N31: TMenuItem;
    N32: TMenuItem;
    N33: TMenuItem;
    N36: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ImageList1: TImageList;
    Pan5: TMenuItem;
    N8: TMenuItem;
    N38: TMenuItem;
    Pan6: TMenuItem;
    N39: TMenuItem;
    N40: TMenuItem;
    N42: TMenuItem;
    MastMenu: TMenuItem;
    N16: TMenuItem;
    Panel2: TfrToolBar;
    FileBtn1: TfrTBButton;
    FileBtn2: TfrTBButton;
    FileBtn3: TfrTBButton;
    FileBtn4: TfrTBButton;
    CutB: TfrTBButton;
    CopyB: TfrTBButton;
    PstB: TfrTBButton;
    ZB1: TfrTBButton;
    ZB2: TfrTBButton;
    SelAllB: TfrTBButton;
    PgB1: TfrTBButton;
    PgB2: TfrTBButton;
    PgB3: TfrTBButton;
    GB1: TfrTBButton;
    GB2: TfrTBButton;
    ExitB: TfrTBButton;
    Panel3: TfrToolBar;
    AlB1: TfrTBButton;
    AlB2: TfrTBButton;
    AlB3: TfrTBButton;
    AlB4: TfrTBButton;
    AlB5: TfrTBButton;
    FnB1: TfrTBButton;
    FnB2: TfrTBButton;
    FnB3: TfrTBButton;
    ClB2: TfrTBButton;
    HlB1: TfrTBButton;
    AlB6: TfrTBButton;
    AlB7: TfrTBButton;
    Panel1: TfrToolBar;
    FrB1: TfrTBButton;
    FrB2: TfrTBButton;
    FrB3: TfrTBButton;
    FrB4: TfrTBButton;
    ClB1: TfrTBButton;
    ClB3: TfrTBButton;
    FrB5: TfrTBButton;
    FrB6: TfrTBButton;
    frTBSeparator1: TfrTBSeparator;
    frTBSeparator2: TfrTBSeparator;
    frTBSeparator3: TfrTBSeparator;
    frTBSeparator4: TfrTBSeparator;
    frTBSeparator5: TfrTBSeparator;
    frTBPanel1: TfrTBPanel;
    C3: TfrComboBox;
    C2: TfrFontComboBox;
    frTBPanel2: TfrTBPanel;
    frTBSeparator6: TfrTBSeparator;
    frTBSeparator7: TfrTBSeparator;
    frTBSeparator8: TfrTBSeparator;
    frTBSeparator9: TfrTBSeparator;
    frTBSeparator10: TfrTBSeparator;
    N37: TMenuItem;
    Pan2: TMenuItem;
    Pan3: TMenuItem;
    Pan1: TMenuItem;
    Pan4: TMenuItem;
    Panel4: TfrToolBar;
    OB1: TfrTBButton;
    OB2: TfrTBButton;
    OB3: TfrTBButton;
    OB4: TfrTBButton;
    OB5: TfrTBButton;
    frTBSeparator12: TfrTBSeparator;
    Panel5: TfrToolBar;
    Align1: TfrTBButton;
    Align2: TfrTBButton;
    Align3: TfrTBButton;
    Align4: TfrTBButton;
    Align5: TfrTBButton;
    Align6: TfrTBButton;
    Align7: TfrTBButton;
    Align8: TfrTBButton;
    Align9: TfrTBButton;
    Align10: TfrTBButton;
    frTBSeparator13: TfrTBSeparator;
    Tab1: TTabControl;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    frDock4: TfrDock;
    HelpMenu: TMenuItem;
    N34: TMenuItem;
    GB3: TfrTBButton;
    N46: TMenuItem;
    N47: TMenuItem;
    UndoB: TfrTBButton;
    frTBSeparator14: TfrTBSeparator;
    AlB8: TfrTBButton;
    RedoB: TfrTBButton;
    N48: TMenuItem;
    OB6: TfrTBButton;
    frTBSeparator15: TfrTBSeparator;
    Panel6: TfrToolBar;
    Pan7: TMenuItem;
    Image2: TImage;
    N14: TMenuItem;
    Panel7: TPanel;
    PBox1: TPaintBox;
    N17: TMenuItem;
    HelpBtn: TfrTBButton;
    frTBSeparator11: TfrTBSeparator;
    N18: TMenuItem;
    N22: TMenuItem;
    N35: TMenuItem;
    Popup2: TPopupMenu;
    N41: TMenuItem;
    N43: TMenuItem;
    N44: TMenuItem;
    LinePanel: TPanel;
    frSpeedButton1: TfrSpeedButton;
    frSpeedButton2: TfrSpeedButton;
    frSpeedButton3: TfrSpeedButton;
    frSpeedButton4: TfrSpeedButton;
    frSpeedButton5: TfrSpeedButton;
    StB1: TfrTBButton;
    frSpeedButton6: TfrSpeedButton;
    C4: TfrComboBox;
    Pan8: TMenuItem;
    N45: TMenuItem;
    PgB4: TfrTBButton;
    N15: TMenuItem;
    Bevel1: TBevel;
    FontDialog1: TFontDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure DoClick(Sender: TObject);
    procedure ClB1Click(Sender: TObject);
    procedure GB1Click(Sender: TObject);
    procedure ZB1Click(Sender: TObject);
    procedure ZB2Click(Sender: TObject);
    procedure PgB1Click(Sender: TObject);
    procedure PgB2Click(Sender: TObject);
    procedure OB2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OB1Click(Sender: TObject);
    procedure CutBClick(Sender: TObject);
    procedure CopyBClick(Sender: TObject);
    procedure PstBClick(Sender: TObject);
    procedure SelAllBClick(Sender: TObject);
    procedure ExitBClick(Sender: TObject);
    procedure PgB3Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure GB2Click(Sender: TObject);
    procedure FileBtn1Click(Sender: TObject);
    procedure FileBtn2Click(Sender: TObject);
    procedure FileBtn3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure HlB1Click(Sender: TObject);
    procedure FileBtn4Click(Sender: TObject);
    procedure N42Click(Sender: TObject);
    procedure Popup1Popup(Sender: TObject);
    procedure N23Click(Sender: TObject);
    procedure N37Click(Sender: TObject);
    procedure Pan2Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure Align1Click(Sender: TObject);
    procedure Align2Click(Sender: TObject);
    procedure Align3Click(Sender: TObject);
    procedure Align4Click(Sender: TObject);
    procedure Align5Click(Sender: TObject);
    procedure Align6Click(Sender: TObject);
    procedure Align7Click(Sender: TObject);
    procedure Align8Click(Sender: TObject);
    procedure Align9Click(Sender: TObject);
    procedure Align10Click(Sender: TObject);
    procedure Tab1Change(Sender: TObject);
    procedure N34Click(Sender: TObject);
    procedure GB3Click(Sender: TObject);
    procedure UndoBClick(Sender: TObject);
    procedure RedoBClick(Sender: TObject);
    procedure N20Click(Sender: TObject);
    procedure PBox1Paint(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N22Click(Sender: TObject);
    procedure Tab1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure frSpeedButton1Click(Sender: TObject);
    procedure StB1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ScrollBox1Resize(Sender: TObject);
    procedure Tab1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure Tab1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Tab1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Tab1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PgB4Click(Sender: TObject);
    procedure StatusBar1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StatusBar1DblClick(Sender: TObject);
    procedure C2DblClick(Sender: TObject);
{$IFDEF 1CScript}
    procedure N99Click(Sender: TObject);
{$ENDIF}
  private
    { Private declarations }
{$IFDEF 1CScript}
    N99: TMenuItem;
{$ENDIF}
    PageForm: TForm;
    PageView: TfrDesignerPage;
    InspForm: TfrInspForm;
    EditorForm: TfrEditorForm;
    EditorForm1: TfrEditorForm1;
    ColorSelector: TColorSelector;
    MenuItems: TList;
    ItemWidths: TStringList;
    FCurPage: Integer;
    FGridSizeX, FGridSizeY: Integer;
    FGridShow, FGridAlign: Boolean;
    FUnits: TfrReportUnits;
    FGrayedButtons: Boolean;
    FUndoBuffer, FRedoBuffer: TfrUndoBuffer;
    FUndoBufferLength, FRedoBufferLength: Integer;
    FirstTime: Boolean;
    MaxItemWidth, MaxShortCutWidth: Integer;
    fld: Array[0..63] of String;
    EditAfterInsert: Boolean;
    FCurDocName, FCaption: String;
    ShapeMode: TfrShapeMode;
    PagePosition: TAlign;
    FPageType: TfrPageType;
    MDown, ChangeUnits: Boolean;
    UnlimitedHeight: Boolean;
    DisableUndo : Boolean;
    SyntaxHighlight : Boolean;
    procedure SetMenuBitmaps;
    procedure SetCurPage(Value: Integer);
    procedure SetGridSize(Value: Integer);
    procedure SetGridShow(Value: Boolean);
    procedure SetGridAlign(Value: Boolean);
    procedure SetUnits(Value: TfrReportUnits);
    procedure SetGrayedButtons(Value: Boolean);
    procedure SetCurDocName(Value: String);
    procedure SelectionChanged;
    procedure ShowPosition;
    procedure ShowContent;
    procedure EnableControls;
    procedure ResetSelection;
    procedure DeleteObjects;
    procedure AddPage;
    procedure RemovePage(n: Integer);
    procedure SetPageTitles;
    procedure DefMemoEditor(Sender: TObject);
    procedure DefPictureEditor(Sender: TObject);
    procedure DefRestrEditor(Sender: TObject);
    procedure DefHighlightEditor(Sender: TObject);
    procedure DefFieldEditor(Sender: TObject);
    procedure DefDataSourceEditor(Sender: TObject);
    procedure DefCrossDataSourceEditor(Sender: TObject);
    procedure DefGroupEditor(Sender: TObject);
    procedure DefFontEditor(Sender: TObject);
    procedure FillInspFields;
    procedure HighLightSwitch;
    function RectTypEnabled: Boolean;
    function FontTypEnabled: Boolean;
    function ZEnabled: Boolean;
    function CutEnabled: Boolean;
    function CopyEnabled: Boolean;
    function PasteEnabled: Boolean;
    function DelEnabled: Boolean;
    function EditEnabled: Boolean;
    procedure ColorSelected(Sender: TObject);
    procedure MoveObjects(dx, dy: Integer; Resize: Boolean);
    procedure SelectAll;
    procedure Unselect;
    procedure CutToClipboard;
    procedure CopyToClipboard;
    procedure SaveState;
    procedure RestoreState;
    procedure ClearBuffer(Buffer: TfrUndoBuffer; var BufferLength: Integer);
    procedure ClearUndoBuffer;
    procedure ClearRedoBuffer;
    procedure Undo(Buffer: PfrUndoBuffer);
    procedure ReleaseAction(ActionRec: TfrUndoRec);
    procedure AddAction(Buffer: PfrUndoBuffer; a: TfrUndoAction; List: TList);
    procedure AddUndoAction(a: TfrUndoAction);
    procedure DoDrawText(Canvas: TCanvas; Caption: string;
      Rect: TRect; Selected, Enabled: Boolean; Flags: Longint);
    procedure MeasureItem(AMenuItem: TMenuItem; ACanvas: TCanvas;
      var AWidth, AHeight: Integer);
    procedure DrawItem(AMenuItem: TMenuItem; ACanvas: TCanvas;
      ARect: TRect; Selected: Boolean);
    procedure InsFieldsClick(Sender: TObject);
    function FindMenuItem(AMenuItem: TMenuItem): TfrMenuItemInfo;
    procedure SetMenuItemBitmap(AMenuItem: TMenuItem; ABtn:TfrSpeedButton);
    procedure FillMenuItems(MenuItem: TMenuItem);
    procedure DeleteMenuItems(MenuItem: TMenuItem);
    procedure GetDefaultSize(var dx, dy: Integer);
    function SelStatus: TfrSelectionStatus;
    procedure OnModify(Item: Integer);
    procedure PageFormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PageFormResize(Sender: TObject);
    procedure PageFormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
    function BeforeEdit: Boolean;
    procedure AfterEdit;
    procedure DoEdit(ClassRef: TClass);
    procedure ShowFieldsDialog(Show: Boolean);
    procedure HeightChanged(Sender: TObject);
    procedure NotifyParentBands(OldName, NewName: String);
    procedure NotifySubReports(OldIndex, NewIndex: Integer);
    procedure InspSelectionChanged(ObjName: String);
    procedure InspGetObjects(List: TStrings);
    procedure AssignDefEditors;
    procedure Localize;
{$IFDEF Delphi4}
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
{$ENDIF}
  public
    { Public declarations }
    procedure DefTagEditor(Sender: TObject);
    function GetModified: Boolean; override;
    procedure SetModified(Value: Boolean); override;
    procedure WndProc(var Message: TMessage); override;
    procedure RegisterObject(ButtonBmp: TBitmap; ButtonHint: String;
      ButtonTag: Integer; IsControl: Boolean);
    procedure RegisterTool(MenuCaption: String; ButtonBmp: TBitmap;
      OnClick: TNotifyEvent);
    procedure BeforeChange; override;
    procedure AfterChange; override;
    procedure SelectObject(ObjName: String); override;
    function InsertDBField: String; override;
    function InsertExpression: String; override;
    procedure ShowMemoEditor(Sender: TObject);
    procedure ShowEditor;
    procedure RedrawPage; override;
    function PointsToUnits(x: Double): Double;
    function UnitsToPoints(x: Double): Double;
    property CurDocName: String read FCurDocName write SetCurDocName;
    property CurPage: Integer read FCurPage write SetCurPage;
    property GridSizeX: Integer read FGridSizeX write SetGridSize;
    property GridSizeY: Integer read FGridSizeY write SetGridSize;
    property ShowGrid: Boolean read FGridShow write SetGridShow;
    property GridAlign: Boolean read FGridAlign write SetGridAlign;
    property Units: TfrReportUnits read FUnits write SetUnits;
    property GrayedButtons: Boolean read FGrayedButtons write SetGrayedButtons;
    property PageType: TfrPageType read FPageType;
  end;


procedure frSetGlyph(Color: TColor; sb: TfrSpeedButton; n: Integer);
function frCheckBand(b: TfrBandType): Boolean;

var
  frTemplateDir: String;
  DesignerRestrictions: TfrDesignerRestrictions;


implementation

{$R *.DFM}
{$R *.RES}
{$R FR_Lng2.RES}
{$R FR_Lng3.RES}

uses
  FR_Pgopt, FR_GEdit, FR_Templ, FR_Newrp, FR_DsOpt, FR_Const, FR_AttrE,
  FR_Prntr, FR_Hilit, FR_Dopt, FR_Dict, FR_BndEd, FR_VBnd, FR_Flds,
  FR_BTyp, FR_Utils, FR_GrpEd, FR_About, FR_IFlds, FR_Pars, FR_DBRel,
  FR_Restr, FR_DBSet, FR_PageF, FR_Expr, Registry, CommCtrl, FR_Funcs, FR_Passw
{$IFDEF Delphi6}
, Variants
{$ENDIF};

type
  THackView = class(TfrView)
  end;

var
  FirstSelected: TfrView;
  SelNum: Integer;               // number of objects currently selected
  MRFlag,                        // several objects was selected
  ObjRepeat,                     // was pressed Shift + Insert Object
  WasOk: Boolean;                // was Ok pressed in dialog
  OldRect, OldRect1: TRect;      // object rect after mouse was clicked
  Busy: Boolean;                 // busy flag. need!
  ShowSizes: Boolean;
  LastFontName: String;
  LastFontSize, LastAlignment: Integer;
  LastFrameWidth, LastLineWidth: Single;
  LastFrameTyp, LastFontStyle, LastCharset: Word;
  LastFrameColor, LastFillColor, LastFontColor: TColor;
  ClrButton: TfrSpeedButton;
  FirstChange: Boolean;
  ClipRgn: HRGN;
  DesignerComp: TfrDesigner;
  InspBusy: Boolean;

// globals
  ClipBd: TList;                 // clipboard
  GridBitmap: TBitmap;           // for drawing grid in design time


{----------------------------------------------------------------------------}
// miscellaneous routines
function Objects: TList;
begin
  Result := frDesigner.Page.Objects;
end;

procedure frSetGlyph(Color: TColor; sb: TfrSpeedButton; n: Integer);
var
  b: TBitmap;
  r: TRect;
  i, j: Integer;
begin
  b := TBitmap.Create;
  b.Width := 32;
  b.Height := 16;
  with b.Canvas do
  begin
    r := Rect(n * 32, 0, n * 32 + 32, 16);
    CopyRect(Rect(0, 0, 32, 16), TfrDesignerForm(frDesigner).Image1.Picture.Bitmap.Canvas, r);
    for i := 0 to 32 do
      for j := 0 to 16 do
        if Pixels[i, j] = clRed then
          Pixels[i, j] := Color;
    if Color = clNone then
      for i := 1 to 14 do
        Pixels[i, 13] := clBtnFace;
  end;
  sb.Glyph.Assign(b);
  sb.NumGlyphs := 2;
  b.Free;
end;

function TopSelected: Integer;
var
  i: Integer;
begin
  Result := Objects.Count - 1;
  for i := Objects.Count - 1 downto 0 do
    if TfrView(Objects[i]).Selected then
    begin
      Result := i;
      break;
    end;
end;

function frCheckBand(b: TfrBandType): Boolean;
var
  i: Integer;
  t: TfrView;
begin
  Result := False;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Typ = gtBand then
      if b = TfrBandType(t.FrameTyp) then
      begin
        Result := True;
        break;
      end;
  end;
end;

function GetUnusedBand: TfrBandType;
var
  b: TfrBandType;
begin
  Result := btNone;
  for b := btReportTitle to btNone do
    if not frCheckBand(b) then
    begin
      Result := b;
      break;
    end;
  if Result = btNone then Result := btMasterData;
end;

procedure SendBandsToDown;
var
  i, j, n, k: Integer;
  t: TfrView;
begin
  n := Objects.Count; j := 0; i := n - 1;
  k := 0;
  while j < n do
  begin
    t := Objects[i];
    if t.Typ = gtBand then
    begin
      Objects.Delete(i);
      Objects.Insert(0, t);
      Inc(k);
    end
    else
      Dec(i);
    Inc(j);
  end;
  for i := 0 to n - 1 do // sends btOverlay to back
  begin
    t := Objects[i];
    if (t.Typ = gtBand) and (t.FrameTyp = Integer(btOverlay)) then
    begin
      Objects.Delete(i);
      Objects.Insert(0, t);
      break;
    end;
  end;
  i := 0; j := 0;
  while j < n do // sends btCrossXXX to front
  begin
    t := Objects[i];
    if (t.Typ = gtBand) and
       (TfrBandType(t.FrameTyp) in [btCrossHeader..btCrossFooter]) then
    begin
      Objects.Delete(i);
      Objects.Insert(k - 1, t);
    end
    else Inc(i);
    Inc(j);
  end;
end;

procedure ClearClipBoard;
var
  m: TMemoryStream;
begin
  if Assigned(ClipBd) then
    with ClipBd do
    while Count > 0 do
    begin
      m := Items[0];
      m.Free;
      Delete(0);
    end;
end;

procedure GetRegion;
var
  i: Integer;
  t: TfrView;
  R: HRGN;
begin
  ClipRgn := CreateRectRgn(0, 0, 0, 0);
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
    begin
      R := t.GetClipRgn(rtExtended);
      CombineRgn(ClipRgn, ClipRgn, R, RGN_OR);
      DeleteObject(R);
    end;
  end;
  FirstChange := False;
end;

function IsBandsSelect(var Value: TfrView): Boolean;
var
  i: Integer;
begin
  Result := False;
  Value := nil;
  for i := 0 to Objects.Count - 1 do
  begin
    Value := Objects[i];
    if Value.Selected and (Value.Typ = gtBand) then
    begin
      Result := True;
      break;
    end;
  end;
end;


{----------------------------------------------------------------------------}
constructor TfrDesigner.Create(AOwner: TComponent);
begin
  if Assigned(DesignerComp) then
    raise Exception.Create('You already have one TfrDesigner component');
  inherited Create(AOwner);
  FCloseQuery := True;
  DesignerComp := Self;
  HideDisabledButtons := True;
end;

destructor TfrDesigner.Destroy;
begin
  DesignerComp := nil;
  inherited Destroy;
end;


{--------------------------------------------------}
constructor TfrDesignerPage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Parent := AOwner as TWinControl;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Color  := clWhite;
  BorderStyle := bsNone;
  OnMouseDown := MDown;
  OnMouseUp := MUp;
  OnMouseMove := MMove;
  OnDblClick := DClick;
  OnDragOver := DoDragOver;
  OnDragDrop := DoDragDrop;
end;

procedure TfrDesignerPage.Init;
begin
  Down := False; DFlag := False; RFlag := False;
  Cursor := crDefault; CT := ctNone;
end;

procedure TfrDesignerPage.SetPage;
var
  Pgw, Pgh, Pgl, Pgt: Integer;
begin
  if (FDesigner.Page = nil) or DisableDraw then Exit;
  Pgw := FDesigner.Page.PrnInfo.Pgw;
  Pgh := FDesigner.Page.PrnInfo.Pgh;
  if FDesigner.UnlimitedHeight then
    Pgh := Pgh * 3;
  Pgt := 10;
  if (Pgw > Parent.ClientWidth - 11) or (FDesigner.PagePosition = alLeft) then
    Pgl := 10
  else if FDesigner.PagePosition = alClient then
    Pgl := (Parent.ClientWidth - Pgw) div 2
  else
    Pgl := Parent.ClientWidth - Pgw - 11;

  if FDesigner.PageType = ptDialog then
  begin
    FDesigner.PageForm.OnResize := nil;
    Align := alClient;
    FDesigner.PageForm.OnResize := FDesigner.PageFormResize;
  end
  else
  begin
    Align := alNone;
    SetBounds(Pgl, Pgt, Pgw, Pgh);
    TScrollBox(Parent).VertScrollBar.Range := Top + Height + 10;
    TScrollBox(Parent).HorzScrollBar.Range := Left + Width + 10
{$IFDEF Delphi2}
{$ELSE}
{$IFDEF Delphi3}
{$ELSE}
     - GetSystemMetrics(SM_CXVSCROLL)
{$ENDIF}
{$ENDIF};
  end;
end;

procedure TfrDesignerPage.WMEraseBackground(var Message: TMessage);
begin
end;

procedure TfrDesignerPage.Paint;
begin
  Draw(10000, 0);
end;

procedure TfrDesignerPage.NormalizeCoord(t: TfrView);
begin
  if t.dx < 0 then
  begin
    t.dx := -t.dx;
    t.x := t.x - t.dx;
  end;
  if t.dy < 0 then
  begin
    t.dy := -t.dy;
    t.y := t.y - t.dy;
  end;
end;

procedure TfrDesignerPage.NormalizeRect(var r: TRect);
var
  i: Integer;
begin
  with r do
  begin
    if Left > Right then begin i := Left; Left := Right; Right := i end;
    if Top > Bottom then begin i := Top; Top := Bottom; Bottom := i end;
  end;
end;

procedure TfrDesignerPage.DrawHSplitter(Rect: TRect);
begin
  with Canvas do
  begin
    Pen.Mode := pmXor;
    Pen.Color := clSilver;
    Pen.Width := 1;
    MoveTo(Rect.Left, Rect.Top);
    LineTo(Rect.Right, Rect.Bottom);
    Pen.Mode := pmCopy;
  end;
end;

procedure TfrDesignerPage.DrawRectLine(Rect: TRect);
begin
  with Canvas do
  begin
    Pen.Mode := pmNot;
    Pen.Style := psSolid;
    Pen.Width := Round(LastLineWidth);
    with Rect do
      if Abs(Right - Left) > Abs(Bottom - Top) then
      begin
        MoveTo(Left, Top);
        LineTo(Right, Top);
      end
      else
      begin
        MoveTo(Left, Top);
        LineTo(Left, Bottom);
      end;
    Pen.Mode := pmCopy;
  end;
end;

procedure TfrDesignerPage.DrawFocusRect(Rect: TRect);
begin
  with Canvas do
  begin
    Pen.Mode := pmXor;
    Pen.Color := clSilver;
    Pen.Width := 1;
    Pen.Style := psSolid;
    Brush.Style := bsClear;
    if (Rect.Right = Rect.Left + 1) or (Rect.Bottom = Rect.Top + 1) then
    begin
      if Rect.Right = Rect.Left + 1 then
        Dec(Rect.Right, 1) else
        Dec(Rect.Bottom, 1);
      MoveTo(Rect.Left, Rect.Top);
      LineTo(Rect.Right, Rect.Bottom);
    end
    else
      Rectangle(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
    Pen.Mode := pmCopy;
    Brush.Style := bsSolid;
  end;
end;

procedure TfrDesignerPage.DrawSelection(t: TfrView);
var
  px, py: Word;

  procedure DrawPoint(x, y: Word);
  begin
    Canvas.MoveTo(x, y);
    Canvas.LineTo(x, y);
  end;

begin
  if t.Selected then
  with t, Canvas do
  begin
    Pen.Width := 5;
    Pen.Mode := pmXor;
    Pen.Color := clWhite;
    px := x + dx div 2;
    py := y + dy div 2;
    DrawPoint(x, y);
    if (dx <> 0) and (dy <> 0) then
    begin
      DrawPoint(x + dx, y);
      DrawPoint(x, y + dy);
    end;
    if Objects.IndexOf(t) = RightBottom then
      Pen.Color := clTeal;
    DrawPoint(x + dx, y + dy);
    Pen.Color := clWhite;
    if (SelNum = 1) and (dx <> 0) and (dy <> 0) then
    begin
      DrawPoint(px, y); DrawPoint(px, y + dy);
      DrawPoint(x, py); DrawPoint(x + dx, py);
    end;
    Pen.Mode := pmCopy;
  end;
end;

procedure TfrDesignerPage.DrawShape(t: TfrView);
begin
  with t do
    if Selected then
      DrawFocusRect(Rect(x, y, x + dx + 1, y + dy + 1))
end;

procedure TfrDesignerPage.Draw(N: Integer; ClipRgn: HRGN);
var
  i: Integer;
  t: TfrView;
  R, R1: HRGN;
  Objects: TList;
  c: TColor;
  Bmp, Bmp1: TBitmap;

  procedure DrawBackground;
  var
    i, j: Integer;
  begin
    with Canvas do
    begin
      c := clBlack;
      if FDesigner.ShowGrid and (FDesigner.GridSizeX <> 18) then
      begin
        with GridBitmap.Canvas do
        begin
          if FDesigner.PageType = ptDialog then
            Brush.Color := FDesigner.Page.Color else
            Brush.Color := clWhite;
          FillRect(Rect(0, 0, 8, 8));
          Pixels[0, 0] := c;
          if FDesigner.GridSizeX = 4 then
          begin
            Pixels[4, 0] := c;
            Pixels[0, 4] := c;
            Pixels[4, 4] := c;
          end;
        end;
        Brush.Bitmap := GridBitmap;
      end
      else
      begin
        if FDesigner.PageType = ptDialog then
          Brush.Color := FDesigner.Page.Color else
          Brush.Color := clWhite;
        Brush.Style := bsSolid;
      end;
      FillRgn(Handle, R, Brush.Handle);
      if FDesigner.ShowGrid and (FDesigner.GridSizeX = 18) then
      begin
        i := 0;
        while i < Width do
        begin
          j := 0;
          while j < Height do
          begin
            if RectVisible(Handle, Rect(i, j, i + 1, j + 1)) then
              SetPixel(Handle, i, j, c);
            Inc(j, FDesigner.GridSizeY);
          end;
          Inc(i, FDesigner.GridSizeX);
        end;
      end;
    end;
  end;

  procedure DrawMargins;
  var
    i, j: Integer;
  begin
    with Canvas do
    begin
      Brush.Style := bsClear;
      Pen.Width := 1;
      Pen.Color := clGray;
      Pen.Style := psSolid;
      Pen.Mode := pmCopy;
      if FDesigner.PageType = ptReport then
        with FDesigner.Page do
        begin
          if UseMargins then
            Rectangle(LeftMargin, TopMargin, RightMargin, BottomMargin);
          if ColCount > 1 then
          begin
            ColWidth := (RightMargin - LeftMargin -
              ((ColCount - 1) * ColGap)) div ColCount;
            Pen.Style := psDot;
            j := LeftMargin;
            for i := 1 to ColCount do
            begin
              Rectangle(j, -1, j + ColWidth + 1,  PrnInfo.Pgh + 1);
              Inc(j, ColWidth + ColGap);
            end;
            Pen.Style := psSolid;
          end;
        end;
    end;
  end;

  function IsVisible(t: TfrView): Boolean;
  var
    R: HRGN;
  begin
    R := t.GetClipRgn(rtNormal);
    Result := CombineRgn(R, R, ClipRgn, RGN_AND) <> NULLREGION;
    DeleteObject(R);
  end;

  procedure DrawObject(t: TfrView; Canvas: TCanvas);
  begin
    t.Draw(Canvas);
    if t.Script.Count > 0 then
      Canvas.Draw(t.x + 1, t.y + 1, Bmp);
    if (t is TfrMemoView) and (TfrMemoView(t).HighlightStr <> '') then
      Canvas.Draw(t.x + 1, t.y + 10, Bmp1);
  end;

begin
  if (FDesigner.Page = nil) or DisableDraw then Exit;
  Bmp := TBitmap.Create;
  Bmp.LoadFromResourceName(hInstance, 'FR_SCRIPT');
  Bmp1 := TBitmap.Create;
  Bmp1.LoadFromResourceName(hInstance, 'FR_HIGHLIGHT');
  DocMode := dmDesigning;
  Objects := FDesigner.Page.Objects;
  if ClipRgn = 0 then
    with Canvas.ClipRect do
      ClipRgn := CreateRectRgn(Left, Top, Right, Bottom);
  SetTextCharacterExtra(Canvas.Handle, 0);
  R := CreateRectRgn(0, 0, Width, Height);
  for i := Objects.Count - 1 downto 0 do
  begin
    t := Objects[i];
    if i <= N then
      if t.Selected then
        DrawObject(t, Canvas)
      else if IsVisible(t) then
      begin
        R1 := CreateRectRgn(0, 0, 1, 1);
        CombineRgn(R1, ClipRgn, R, RGN_AND);
        SelectClipRgn(Canvas.Handle, R1);
        DeleteObject(R1);
        DrawObject(t, Canvas);
      end;
    SetTextCharacterExtra(Canvas.Handle, 0);
    R1 := t.GetClipRgn(rtNormal);
    CombineRgn(R, R, R1, RGN_DIFF);
    DeleteObject(R1);
    SelectClipRgn(Canvas.Handle, R);
  end;
  CombineRgn(R, R, ClipRgn, RGN_AND);
  DrawBackground;

  DeleteObject(R);
  DeleteObject(ClipRgn);
  SelectClipRgn(Canvas.Handle, 0);
  DrawMargins;
  if not Down then
    DrawPage(dmSelection);
  Bmp.Free;
  Bmp1.Free;
end;

procedure TfrDesignerPage.DrawPage(DrawMode: TfrDesignerDrawMode);
var
  i: Integer;
  t: TfrView;
begin
  if DocMode <> dmDesigning then Exit;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    case DrawMode of
      dmAll: t.Draw(Canvas);
      dmSelection: DrawSelection(t);
      dmShape: DrawShape(t);
    end;
  end;
end;

function TfrDesignerPage.FindNearestEdge(var x, y: Integer): Boolean;
var
  i: Integer;
  t: TfrView;
  min: Double;
  p: TPoint;
  function DoMin(a: Array of TPoint): Boolean;
  var
    i: Integer;
    d: Double;
  begin
    Result := False;
    for i := Low(a) to High(a) do
    begin
      d := sqrt((x - a[i].x) * (x - a[i].x) + (y - a[i].y) * (y - a[i].y));
      if d < min then
      begin
        min := d;
        p := a[i];
        Result := True;
      end;
    end;
  end;
begin
  Result := False;
  min := FDesigner.GridSizeX;
  p := Point(x, y);
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if DoMin([Point(t.x, t.y), Point(t.x + t.dx, t.y),
         Point(t.x + t.dx, t.y + t.dy),  Point(t.x, t.y + t.dy)]) then
      Result := True;
  end;
  x := p.x; y := p.y;
end;

procedure TfrDesignerPage.RoundCoord(var x, y: Integer);
begin
  with FDesigner do
    if GridAlign then
    begin
      x := x div GridSizeX * GridSizeX;
      y := y div GridSizeY * GridSizeY;
    end;
end;

procedure TfrDesignerPage.GetMultipleSelected;
var
  i, j, k: Integer;
  t: TfrView;
begin
  j := 0; k := 0;
  LeftTop := Point(10000, 10000);
  RightBottom := -1;
  MRFlag := False;
  if SelNum > 1 then                  {find right-bottom element}
  begin
    for i := 0 to Objects.Count-1 do
    begin
      t := Objects[i];
      if t.Selected then
      begin
        t.OriginalRect := Rect(t.x, t.y, t.dx, t.dy);
        if (t.x + t.dx > j) or ((t.x + t.dx = j) and (t.y + t.dy > k)) then
        begin
          j := t.x + t.dx;
          k := t.y + t.dy;
          RightBottom := i;
        end;
        if t.x < LeftTop.x then LeftTop.x := t.x;
        if t.y < LeftTop.y then LeftTop.y := t.y;
      end;
    end;
    t := Objects[RightBottom];
    OldRect := Rect(LeftTop.x, LeftTop.y, t.x + t.dx, t.y + t.dy);
    OldRect1 := OldRect;
    MRFlag := True;
  end;
end;

procedure TfrDesignerPage.MDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
  f, v: Boolean;
  t: TfrView;
  Rgn: HRGN;
  p: TPoint;
begin
  WasCtrl := ssCtrl in Shift;
  if DFlag then
  begin
    DFlag := False;
    Exit;
  end;
  if (Button = mbRight) and Down and RFlag then
    DrawFocusRect(OldRect);
  RFlag := False;
  DrawPage(dmSelection);
  Down := True;
  if Button = mbLeft then
    if (ssCtrl in Shift) or (Cursor = crCross) then
    begin
      RFlag := True;
      if Cursor = crCross then
      begin
        if FDesigner.PageType = ptReport then
          DrawFocusRect(OldRect);
        RoundCoord(x, y);
        OldRect1 := OldRect;
      end;
      OldRect := Rect(x, y, x, y);
      FDesigner.Unselect;
      SelNum := 0;
      RightBottom := -1;
      MRFlag := False;
      FirstSelected := nil;
      Exit;
    end
    else if Cursor = crPencil then
    begin
      with FDesigner do
      if GridAlign then
        if not FindNearestEdge(x, y) then
        begin
          x := Round(x / GridSizeX) * GridSizeX;
          y := Round(y / GridSizeY) * GridSizeY;
        end;
      OldRect := Rect(x, y, x, y);
      FDesigner.Unselect;
      SelNum := 0;
      RightBottom := -1;
      MRFlag := False;
      FirstSelected := nil;
      LastX := x;
      LastY := y;
      Exit;
    end;
  if Cursor = crDefault then
  begin
    f := False;
    for i := Objects.Count - 1 downto 0 do
    begin
      t := Objects[i];
      if (t.dx < 3) or (t.dy < 3) then
      begin
        v := PtInRect(Rect(t.x - 3, t.y - 3, t.x + t.dx + 3, t.y + t.dy + 3),
          Point(X, Y));
      end
      else
      begin
        Rgn := t.GetClipRgn(rtNormal);
        v := PtInRegion(Rgn, X, Y);
        DeleteObject(Rgn);
      end;
      if v then
      begin
        if ssShift in Shift then
        begin
          t.Selected := not t.Selected;
          if t.Selected then Inc(SelNum) else Dec(SelNum);
        end
        else if not t.Selected then
        begin
          FDesigner.Unselect;
          SelNum := 1;
          t.Selected := True;
        end;
        if SelNum = 0 then FirstSelected := nil
        else if SelNum = 1 then FirstSelected := t
        else if FirstSelected <> nil then
          if not FirstSelected.Selected then FirstSelected := nil;
        f := True;
        break;
      end;
    end;
    if not f then
    begin
      FDesigner.Unselect;
      SelNum := 0;
      FirstSelected := nil;
      if Button = mbLeft then
      begin
        RFlag := True;
        OldRect := Rect(x, y, x, y);
        Exit;
      end;
    end;
    GetMultipleSelected;
  end;
  if SelNum = 0 then
  begin // reset multiple selection
    RightBottom := -1;
    MRFlag := False;
  end;
  LastX := x;
  LastY := y;
  Moved := False;
  FirstChange := True;
  FirstBandMove := True;
  if Button = mbRight then
  begin
    DrawPage(dmSelection);
    Down := False;
    GetCursorPos(p);
    FDesigner.SelectionChanged;
    FDesigner.Popup1Popup(nil);
    TrackPopupMenu(FDesigner.Popup1.Handle,
      TPM_LEFTALIGN or TPM_RIGHTBUTTON, p.X, p.Y, 0, FDesigner.Handle, nil);
  end
  else if FDesigner.ShapeMode = smFrame then
    DrawPage(dmShape);
end;

procedure TfrDesignerPage.MUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  i, k, dx, dy: Integer;
  t: TfrView;
  ObjectInserted: Boolean;

  procedure AddObject(ot: Byte);
  begin
    Objects.Add(frCreateObject(ot, ''));
    t := Objects.Last;
  end;

  procedure CreateSection;
  var
    s: String;
    frBandTypesForm: TfrBandTypesForm;

    function IsSubreport(PageN: Integer): Boolean;
    var
      i, j: Integer;
      t: TfrView;
    begin
      Result := False;
      with CurReport do
        for i := 0 to Pages.Count - 1 do
          for j := 0 to Pages[i].Objects.Count - 1 do
          begin
            t := Pages[i].Objects[j];
            if t.Typ = gtSubReport then
              if TfrSubReportView(t).SubPage = PageN then
              begin
                Result := True;
                Exit;
              end;
          end;
    end;

  begin
    frBandTypesForm := TfrBandTypesForm.Create(nil);
    frBandTypesForm.IsSubreport := IsSubreport(FDesigner.CurPage);
    ObjectInserted := frBandTypesForm.ShowModal = mrOk;
    if ObjectInserted then
    begin
      Objects.Add(TfrBandView.Create);
      t := Objects.Last;
      (t as TfrBandView).BandType := frBandTypesForm.SelectedTyp;
      s := frBandNames[Integer(frBandTypesForm.SelectedTyp)];
      if Pos(' ', s) <> 0 then
      begin
        s[Pos(' ', s) + 1] := UpCase(s[Pos(' ', s) + 1]);
        Delete(s, Pos(' ', s), 1);
      end;
      THackView(t).BaseName := s;
      SendBandsToDown;
    end;
    frBandTypesForm.Free;
  end;

  procedure CreateSubReport;
  begin
    Objects.Add(TfrSubReportView.Create);
    t := Objects.Last;
    (t as TfrSubReportView).SubPage := CurReport.Pages.Count;
    CurReport.Pages.Add;
  end;

  function CheckUnique(Name: String): Boolean;
  var
    i: Integer;
  begin
    Result := True;
    for i := 0 to Objects.Count - 1 do
      if TfrView(Objects[i]).ClassName = Name then
        if (TfrView(Objects[i]).Flags and flOnePerPage) <> 0 then
          Result := False;
  end;

begin
  if Button <> mbLeft then Exit;
  Down := False;
  if FDesigner.ShapeMode = smFrame then
    DrawPage(dmShape);
// inserting a new object
  if Cursor = crCross then
  begin
    Mode := mdSelect;
    if FDesigner.PageType = ptReport then
    begin
      DrawFocusRect(OldRect);
      if (OldRect.Left = OldRect.Right) and (OldRect.Top = OldRect.Bottom) then
        OldRect := OldRect1;
    end;
    NormalizeRect(OldRect);
    RFlag := False;
    if DesignerRestrictions * [frdrDontCreateObj] = [] then
    begin
      ObjectInserted := True;
      with FDesigner.Panel4 do
      for i := 0 to ControlCount - 1 do
        if Controls[i] is TfrSpeedButton then
        with Controls[i] as TfrSpeedButton do
          if Down then
          begin
            if Tag = gtBand then
              if GetUnusedBand <> btNone then
                CreateSection else
                Exit
            else if Tag = gtSubReport then
              CreateSubReport
            else if Tag >= gtAddIn then
            begin
              k := Tag - gtAddIn;
              if CheckUnique(frAddIns[k].ClassRef.ClassName) then
              begin
                t := frCreateObject(gtAddIn, frAddIns[k].ClassRef.ClassName);
                Objects.Add(t);
              end
              else
              begin
                ObjectInserted := False;
                Application.MessageBox(
                  PChar(Format(frLoadStr(SOnePerPage), [frAddIns[k].ClassRef.ClassName])),
                  PChar(frLoadStr(SError)), mb_IconError + mb_Ok);
              end;
            end
            else
              AddObject(Tag);
            break;
          end;
    end
    else
      ObjectInserted := False;
    if ObjectInserted then
    begin
      t.CreateUniqueName;
      if t is TfrSubReportView then
        FDesigner.SetPageTitles;
      with OldRect do
        if (Left = Right) or (Top = Bottom) then
        begin
          dx := 36; dy := 36;
          if t is TfrMemoView then
            FDesigner.GetDefaultSize(dx, dy)
          else if FDesigner.PageType = ptDialog then
          begin
            dx := t.dx;
            dy := t.dy;
          end;
          OldRect := Rect(Left, Top, Left + dx, Top + dy);
        end;
      FDesigner.Unselect;
      t.x := OldRect.Left; t.y := OldRect.Top;
      if (t.dx = 0) and (t.dy = 0) then
      begin
        t.dx := OldRect.Right - OldRect.Left; t.dy := OldRect.Bottom - OldRect.Top;
      end;
      if (t is TfrBandView) and
         (TfrBandType(t.FrameTyp) in [btCrossHeader..btCrossFooter]) and
         (t.dx > Width - 10) then
         t.dx := 40;
      if t.Typ <> gtAddIn then
        t.FrameWidth := LastFrameWidth;
      t.FrameColor := LastFrameColor;
      t.FillColor := LastFillColor;
      t.Selected := True;
      if t is TfrMemoView then
        with t as TfrMemoView do
        begin
          FrameTyp := LastFrameTyp;
          Font.Name := LastFontName;
          Font.Size := LastFontSize;
          Font.Color := LastFontColor;
          Font.Style := frSetFontStyle(LastFontStyle);
{$IFNDEF Delphi2}
          Font.Charset := LastCharset;
{$ENDIF}
          Alignment := LastAlignment;
        end;
      SelNum := 1;
      if t.Typ = gtBand then
        Draw(10000, t.GetClipRgn(rtExtended))
      else
      begin
        t.Draw(Canvas);
        DrawSelection(t);
      end;
      with FDesigner do
      begin
        SelectionChanged;
        AddUndoAction(acInsert);
        if EditAfterInsert and not FDrag and not (t is TfrControl) then
          ShowEditor;
      end;
    end;
    if not ObjRepeat then
      FDesigner.OB1.Down := True else
      DrawFocusRect(OldRect);
    Exit;
  end;
// line drawing
  if Cursor = crPencil then
  begin
    with OldRect do
      if (Left = Right) and (Top = Bottom) then
        Exit;
    if DesignerRestrictions * [frdrDontCreateObj] <> [] then Exit;
    DrawRectLine(OldRect);
    AddObject(gtLine);
    t.CreateUniqueName;
    t.x := OldRect.Left; t.y := OldRect.Top;
    t.dx := OldRect.Right - OldRect.Left; t.dy := OldRect.Bottom - OldRect.Top;
    if t.dx < 0 then
    begin
      t.dx := -t.dx; if Abs(t.dx) > Abs(t.dy) then t.x := OldRect.Right;
    end;
    if t.dy < 0 then
    begin
      t.dy := -t.dy; if Abs(t.dy) > Abs(t.dx) then t.y := OldRect.Bottom;
    end;
    t.Selected := True;
    t.FrameWidth := LastLineWidth;
    t.FrameColor := LastFrameColor;
    SelNum := 1;
    t.Draw(Canvas);
    DrawSelection(t);
    FDesigner.SelectionChanged;
    FDesigner.AddUndoAction(acInsert);
    Exit;
  end;

// calculating which objects contains in frame (if user select it with mouse+Ctrl key)
  if RFlag then
  begin
    DrawFocusRect(OldRect);
    RFlag := False;
    NormalizeRect(OldRect);
    SelNum := 0;
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      with OldRect do
      if t.Typ <> gtBand then
        if not ((t.x > Right) or (t.x + t.dx < Left) or
                (t.y > Bottom) or (t.y + t.dy < Top)) then
        begin
          t.Selected := True;
          Inc(SelNum);
        end;
    end;

    if SelNum = 0 then
      for i := 0 to Objects.Count - 1 do
      begin
        t := Objects[i];
        with OldRect do
          if not ((t.x > Right) or (t.x + t.dx < Left) or
                  (t.y > Bottom) or (t.y + t.dy < Top)) then
          begin
            t.Selected := True;
            Inc(SelNum);
          end;
      end;

    GetMultipleSelected;
    FDesigner.SelectionChanged;
    DrawPage(dmSelection);
    Exit;
  end;
// splitting
  if Moved and MRFlag and (Cursor = crHSplit) then
  begin
    with SplitInfo do
    begin
      dx := SplRect.Left - SplX;
      if DesignerRestrictions * [frdrDontMoveObj, frdrDontSizeObj] = [] then
        if ((View1.Restrictions and frrfDontSize) = 0) and
          ((View2.Restrictions and (frrfDontMove + frrfDontSize)) = 0) then
          if (View1.dx + dx > 0) and (View2.dx - dx > 0) then
          begin
            Inc(View1.dx, dx);
            Inc(View2.x, dx);
            Dec(View2.dx, dx);
          end;
    end;
    GetMultipleSelected;
    Draw(TopSelected, ClipRgn);
    Exit;
  end;
// resizing several objects
  if Moved and MRFlag and (Cursor <> crDefault) then
  begin
    Draw(TopSelected, ClipRgn);
    Exit;
  end;
// redrawing all moved or resized objects
  if not Moved then
  begin
    FDesigner.SelectionChanged;
    DrawPage(dmSelection);
  end;
  if (SelNum >= 1) and Moved then
    if SelNum > 1 then
    begin
      Draw(TopSelected, ClipRgn);
      GetMultipleSelected;
      FDesigner.ShowPosition;
    end
    else
    begin
      t := Objects[TopSelected];
      NormalizeCoord(t);
      if Cursor <> crDefault then t.Resized;
      Draw(TopSelected, ClipRgn);
      FDesigner.SelectionChanged;
      FDesigner.ShowPosition;
    end;
  Moved := False;
  CT := ctNone;
end;

procedure TfrDesignerPage.MMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  i, j, kx, ky, w, dx, dy: Integer;
  t, t1, Bnd: TfrView;
  nx, ny, x1, x2, y1, y2: Double;
  hr, hr1: HRGN;
  FAlign, cv: Boolean;
  ii: Integer;

  function Cont(px, py, x, y: Integer): Boolean;
  begin
    Result := (x >= px - w) and (x <= px + w + 1) and
      (y >= py - w) and (y <= py + w + 1);
  end;

  function GridCheck: Boolean;
  begin
    with FDesigner do
    begin
      Result := (kx >= GridSizeX) or (kx <= -GridSizeX) or
                (ky >= GridSizeY) or (ky <= -GridSizeY);
      if Result then
      begin
        kx := kx - kx mod GridSizeX;
        ky := ky - ky mod GridSizeY;
      end;
    end;
  end;

  procedure AddRgn(var HR: HRGN; T: TfrView);
  var
    tr: HRGN;
  begin
    tr := t.GetClipRgn(rtExtended);
    CombineRgn(HR, HR, TR, RGN_OR);
    DeleteObject(TR);
  end;

  function CheckNegative(t: TfrView): Boolean;
  begin
    if (t.dx < 0) or (t.dy < 0) then
    begin
      NormalizeCoord(t);
      Result := True;
    end
    else
      Result := False;
  end;

begin
  Moved := True;
  FDrag := False;
  FAlign := FDesigner.GridAlign;
  if ssAlt in Shift then
    FAlign := not FAlign;

  w := 2;
  if FirstChange and Down and not RFlag then
  begin
    kx := x - LastX;
    ky := y - LastY;
    if not FAlign or GridCheck then
    begin
      GetRegion;
      FDesigner.AddUndoAction(acEdit);
    end;
  end;

  if not Down then
    if FDesigner.OB6.Down then
    begin
      Mode := mdSelect;
      Cursor := crPencil;
    end
    else if FDesigner.OB1.Down then
    begin
      Mode := mdSelect;
      Cursor := crDefault;
      if SelNum = 0 then
      begin
        ShowSizes := False;
        OldRect := Rect(x, y, x, y);
        FDesigner.PBox1Paint(nil);
      end;
    end
    else
    begin
      Mode := mdInsert;
      if Cursor <> crCross then
      begin
        RoundCoord(x, y);
        FDesigner.GetDefaultSize(kx, ky);
        if FDesigner.OB3.Down then
          kx := Width;
        OldRect := Rect(x, y, x + kx, y + ky);
        if FDesigner.PageType = ptReport then
          DrawFocusRect(OldRect);
      end;
      Cursor := crCross;
    end;

  if (Mode = mdInsert) and not Down then
  begin
    if FDesigner.PageType = ptReport then
      DrawFocusRect(OldRect);
    RoundCoord(x, y);
    OffsetRect(OldRect, x - OldRect.Left, y - OldRect.Top);
    if FDesigner.PageType = ptReport then
      DrawFocusRect(OldRect);
    ShowSizes := True;
    FDesigner.PBox1Paint(nil);
    ShowSizes := False;
    Exit;
  end;

 // cursor shapes
  if not Down and (SelNum = 1) and (Mode = mdSelect) and
    not FDesigner.OB6.Down then
  begin
    t := Objects[TopSelected];
    if Cont(t.x, t.y, x, y) or Cont(t.x + t.dx, t.y + t.dy, x, y) then
      Cursor := crSizeNWSE
    else if Cont(t.x + t.dx, t.y, x, y) or Cont(t.x, t.y + t.dy, x, y)then
      Cursor := crSizeNESW
    else if Cont(t.x + t.dx div 2, t.y, x, y) or Cont(t.x + t.dx div 2, t.y + t.dy, x, y) then
      Cursor := crSizeNS
    else if Cont(t.x, t.y + t.dy div 2, x, y) or Cont(t.x + t.dx, t.y + t.dy div 2, x, y) then
      Cursor := crSizeWE
    else
      Cursor := crDefault;
  end;
  // selecting a lot of objects
  if Down and RFlag then
  begin
    DrawFocusRect(OldRect);
    if Cursor = crCross then
      RoundCoord(x, y);
    OldRect := Rect(OldRect.Left, OldRect.Top, x, y);
    DrawFocusRect(OldRect);
    ShowSizes := True;
    if Cursor = crCross then
      FDesigner.PBox1Paint(nil);
    ShowSizes := False;
    Exit;
  end;
  // line drawing
  if Down and (Cursor = crPencil) then
  begin
    kx := x - LastX;
    ky := y - LastY;
    if FAlign and not GridCheck then Exit;
    DrawRectLine(OldRect);
    OldRect := Rect(OldRect.Left, OldRect.Top, OldRect.Right + kx, OldRect.Bottom + ky);
    DrawRectLine(OldRect);
    Inc(LastX, kx);
    Inc(LastY, ky);
    Exit;
  end;
  // check for multiple selected objects - right-bottom corner
  if not Down and (SelNum > 1) and (Mode = mdSelect) then
  begin
    t := Objects[RightBottom];
    if Cont(t.x + t.dx, t.y + t.dy, x, y) then
      Cursor := crSizeNWSE
  end;
  // split checking
  if not Down and (SelNum > 1) and (Mode = mdSelect) then
  begin
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if (t.Typ <> gtBand) and (t.Typ <> gtLine) and t.Selected then
        if (x >= t.x) and (x <= t.x + t.dx) and (y >= t.y) and (y <= t.y + t.dy) then
        begin
          for j := 0 to Objects.Count - 1 do
          begin
            t1 := Objects[j];
            if (t1.Typ <> gtBand) and (t1 <> t) and t1.Selected then
              if ((t.x = t1.x + t1.dx) and ((x >= t.x) and (x <= t.x + 2))) or
                ((t1.x = t.x + t.dx) and ((x >= t1.x - 2) and (x <= t.x))) then
              begin
                Cursor := crHSplit;
                with SplitInfo do
                begin
                  SplRect := Rect(x, t.y, x, t.y + t.dy);
                  if t.x = t1.x + t1.dx then
                  begin
                    SplX := t.x;
                    View1 := t1;
                    View2 := t;
                  end
                  else
                  begin
                    SplX := t1.x;
                    View1 := t;
                    View2 := t1;
                  end;
                  SplRect.Left := SplX;
                  SplRect.Right := SplX;
                end;
              end;
          end;
        end;
    end;
  end;
  // splitting
  if Down and MRFlag and (Mode = mdSelect) and (Cursor = crHSplit) then
  begin
    kx := x - LastX;
    ky := 0;
    if FAlign and not GridCheck then Exit;
    with SplitInfo do
    begin
      DrawHSplitter(SplRect);
      SplRect := Rect(SplRect.Left + kx, SplRect.Top, SplRect.Right + kx, SplRect.Bottom);
      DrawHSplitter(SplRect);
    end;
    Inc(LastX, kx);
    Exit;
  end;
  // sizing several objects
  if Down and MRFlag and (Mode = mdSelect) and (Cursor <> crDefault) then
  begin
    kx := x - LastX;
    ky := y - LastY;
    if FAlign and not GridCheck then Exit;

    if FDesigner.ShapeMode = smFrame then
      DrawPage(dmShape)
    else
    begin
      hr := CreateRectRgn(0, 0, 0, 0);
      hr1 := CreateRectRgn(0, 0, 0, 0);
    end;
    if not ((OldRect.Right + kx < OldRect.Left) or (OldRect.Bottom + ky < OldRect.Top)) then
      OldRect := Rect(OldRect.Left, OldRect.Top, OldRect.Right + kx, OldRect.Bottom + ky);
    nx := (OldRect.Right - OldRect.Left) / (OldRect1.Right - OldRect1.Left);
    ny := (OldRect.Bottom - OldRect.Top) / (OldRect1.Bottom - OldRect1.Top);
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if t.Selected then
      begin
        if FDesigner.ShapeMode = smAll then
          AddRgn(hr, t);
        x1 := (t.OriginalRect.Left - LeftTop.x) * nx;
        x2 := t.OriginalRect.Right * nx;
        dx := Round(x1 + x2) - (Round(x1) + Round(x2));
        if DesignerRestrictions * [frdrDontSizeObj] = [] then
          if (t.Restrictions and frrfDontSize) = 0 then
          begin
            t.x := LeftTop.x + Round(x1); t.dx := Round(x2) + dx;
          end;

        y1 := (t.OriginalRect.Top - LeftTop.y) * ny;
        y2 := t.OriginalRect.Bottom * ny;
        dy := Round(y1 + y2) - (Round(y1) + Round(y2));
        if DesignerRestrictions * [frdrDontSizeObj] = [] then
          if (t.Restrictions and frrfDontSize) = 0 then
          begin
            t.y := LeftTop.y + Round(y1); t.dy := Round(y2) + dy;
          end;
        if FDesigner.ShapeMode = smAll then
          AddRgn(hr1, t);
      end;
    end;
    if FDesigner.ShapeMode = smFrame then
      DrawPage(dmShape)
    else
    begin
      Draw(10000, hr);
      Draw(10000, hr1);
    end;
    Inc(LastX, kx);
    Inc(LastY, ky);
    FDesigner.PBox1Paint(nil);
    Exit;
  end;
  // moving
  if Down and (Mode = mdSelect) and (SelNum >= 1) and (Cursor = crDefault) then
  begin
    kx := x - LastX;
    ky := y - LastY;
    if FAlign and not GridCheck then Exit;
    if FirstBandMove and (SelNum = 1) and ((kx <> 0) or (ky <> 0)) and
      not (ssAlt in Shift) then
      if TfrView(Objects[TopSelected]).Typ = gtBand then
      begin
        Bnd := Objects[TopSelected];
        if (Bnd.Restrictions and frrfDontMove) = 0 then
        begin
          for i := 0 to Objects.Count - 1 do
          begin
            t := Objects[i];
            if t.Typ <> gtBand then
              if (t.x >= Bnd.x) and (t.x + t.dx <= Bnd.x + Bnd.dx) and
                 (t.y >= Bnd.y) and (t.y + t.dy <= Bnd.y + Bnd.dy) then
              begin
                t.Selected := True;
                Inc(SelNum);
              end;
          end;
          FDesigner.SelectionChanged;
          GetMultipleSelected;
        end;
      end;
    FirstBandMove := False;
    if FDesigner.ShapeMode = smFrame then
      DrawPage(dmShape)
    else
    begin
      hr := CreateRectRgn(0, 0, 0, 0);
      hr1 := CreateRectRgn(0, 0, 0, 0);
    end;
    cv := false;
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if not t.Selected then continue;
      if t.ClassName = 'TfrCrossView' then
        cv := True;
      if FDesigner.ShapeMode = smAll then
        AddRgn(hr, t);
      if DesignerRestrictions * [frdrDontMoveObj] = [] then
        if (t.Restrictions and frrfDontMove) = 0 then
        begin
          t.x := t.x + kx;
          t.y := t.y + ky;
        end;
      if FDesigner.ShapeMode = smAll then
        AddRgn(hr1, t);
    end;
    if FDesigner.ShapeMode = smFrame then
      DrawPage(dmShape)
    else
    begin
      CombineRgn(hr, hr, hr1, RGN_OR);
      DeleteObject(hr1);
      Draw(10000, hr);
      if cv then
        Draw(10000, 0);
    end;
    Inc(LastX, kx);
    Inc(LastY, ky);
    FDesigner.PBox1Paint(nil);
  end;
 // resizing
  if Down and (Mode = mdSelect) and (SelNum = 1) and (Cursor <> crDefault) then
  begin
    kx := x - LastX;
    ky := y - LastY;
    if FAlign and not GridCheck then Exit;
    t := Objects[TopSelected];
    if FDesigner.ShapeMode = smFrame then
      DrawPage(dmShape) else
      hr := t.GetClipRgn(rtExtended);
    w := 3;
    if (DesignerRestrictions * [frdrDontSizeObj] = []) and
       ((t.Restrictions and frrfDontSize) = 0) then
    begin
      if Cursor = crSizeNWSE then
        if (CT <> ct2) and ((CT = ct1) or Cont(t.x, t.y, LastX, LastY)) then
        begin
          t.x := t.x + kx;
          t.dx := t.dx - kx;
          t.y := t.y + ky;
          t.dy := t.dy - ky;
          if CheckNegative(t) then
            CT := ct2 else
            CT := ct1;
        end
        else
        begin
          t.dx := t.dx + kx;
          t.dy := t.dy + ky;
          if CheckNegative(t) then
            CT := ct1 else
            CT := ct2;
        end;
      if Cursor = crSizeNESW then
        if (CT <> ct4) and ((CT = ct3) or Cont(t.x + t.dx, t.y, LastX, LastY)) then
        begin
          t.y := t.y + ky;
          t.dx := t.dx + kx;
          t.dy := t.dy - ky;
          if CheckNegative(t) then
            CT := ct4 else
            CT := ct3;
        end
        else
        begin
          t.x := t.x + kx;
          t.dx := t.dx - kx;
          t.dy := t.dy + ky;
          if CheckNegative(t) then
            CT := ct3 else
            CT := ct4;
        end;
      if Cursor = crSizeWE then
        if (CT <> ct6) and ((CT = ct5) or Cont(t.x, t.y + t.dy div 2, LastX, LastY)) then
        begin
          t.x := t.x + kx;
          t.dx := t.dx - kx;
          if CheckNegative(t) then
            CT := ct6 else
            CT := ct5;
        end
        else
        begin
          t.dx := t.dx + kx;
          if CheckNegative(t) then
            CT := ct5 else
            CT := ct6;
        end;
      if Cursor = crSizeNS then
        if (CT <> ct8) and ((CT = ct7) or Cont(t.x + t.dx div 2, t.y, LastX, LastY)) then
        begin
          t.y := t.y + ky;
          t.dy := t.dy - ky;
          if CheckNegative(t) then
            CT := ct8 else
            CT := ct7;
        end
        else
        begin
          t.dy := t.dy + ky;
          if CheckNegative(t) then
            CT := ct7 else
            CT := ct8;
        end;
    end;
    if FDesigner.ShapeMode = smFrame then
      DrawPage(dmShape)
    else
    begin
      CombineRgn(hr, hr, t.GetClipRgn(rtExtended), RGN_OR);
      Draw(10000, hr);
    end;
    Inc(LastX, kx);
    Inc(LastY, ky);
    FDesigner.PBox1Paint(nil);
  end;

  if shift = [ssLeft] then
  begin
    ii := 0;
    with TScrollBox(Parent) do
    begin
      if x > (ClientRect.Right + HorzScrollBar.Position) then
      begin
        ii := x - (ClientRect.Right + HorzScrollBar.Position);
        HorzScrollBar.Position := HorzScrollBar.Position + ii;
      end;
      if x < HorzScrollBar.Position then
      begin
        ii := HorzScrollBar.Position - x;
        HorzScrollBar.Position := HorzScrollBar.Position - ii;
      end;
      if y > (ClientRect.Bottom + VertScrollBar.Position) then
      begin
        ii := y - (ClientRect.Bottom + VertScrollBar.Position);
        VertScrollBar.Position := VertScrollBar.Position + ii;
      end;
      if y < VertScrollBar.Position then
      begin
        ii := VertScrollBar.Position - y;
        VertScrollBar.Position := VertScrollBar.Position - ii;
      end;
    end;
    if ii <> 0 then
    begin
      self.Refresh;
      DrawFocusRect(OldRect);
    end;
  end;
end;

procedure TfrDesignerPage.DClick(Sender: TObject);
begin
  Down := False;
  if SelNum = 0 then
    if FDesigner.PageType = ptReport then
    begin
      FDesigner.PgB3Click(nil);
      DFlag := True;
    end
    else
    begin
      DFlag := True;
      FDesigner.Page.ScriptEditor(nil);
    end
  else if SelNum = 1 then
  begin
    DFlag := True;
    if WasCtrl then
      FDesigner.ShowMemoEditor(nil) else
      FDesigner.ShowEditor;
  end
  else Exit;
end;

procedure TfrDesignerPage.CMMouseLeave(var Message: TMessage);
begin
  if ((Mode = mdInsert) and not Down) or FDrag then
  begin
    if FDesigner.PageType = ptReport then
      DrawFocusRect(OldRect);
    OffsetRect(OldRect, -10000, -10000);
  end;
end;

procedure TfrDesignerPage.DoDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  kx, ky: Integer;
begin
  Accept := (Source is TListBox) and
            (DesignerRestrictions * [frdrDontCreateObj] = []) and
            (FDesigner.PageType = ptReport);
  if not Accept then Exit;
  if not FDrag then
  begin
    FDrag := True;
    FDesigner.GetDefaultSize(kx, ky);
    OldRect := Rect(x - 4, y - 4, x + kx - 4, y + ky - 4);
  end
  else
    DrawFocusRect(OldRect);
  RoundCoord(x, y);
  OffsetRect(OldRect, x - OldRect.Left - 4, y - OldRect.Top - 4);
  DrawFocusRect(OldRect);
end;

procedure TfrDesignerPage.DoDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  t: TfrView;
begin
  DrawPage(dmSelection);
// emulating object insertion
  FDesigner.OB2.Down := True;
  Cursor := crCross;
  MUp(nil, mbLeft, [], 0, 0);
  t := Objects[TopSelected];
  t.Memo.Text := '[' + frFieldsDialog.DBField + ']';
  DrawSelection(t);
  t.Draw(Canvas);
  DrawSelection(t);
end;


{-----------------------------------------------------------------------------}
procedure BDown(SB: TfrSpeedButton);
begin
  SB.Down := True;
end;

procedure BUp(SB: TfrSpeedButton);
begin
  SB.Down := False;
end;

procedure TfrDesignerForm.Localize;
begin
  FCaption :=         frLoadStr(frRes + 080);
  Panel1.Caption :=   frLoadStr(frRes + 081);
  Panel2.Caption :=   frLoadStr(frRes + 082);
  Panel3.Caption :=   frLoadStr(frRes + 083);
  Panel4.Caption :=   frLoadStr(frRes + 084);
  Panel5.Caption :=   frLoadStr(frRes + 085);
  Panel6.Caption :=   frLoadStr(frRes + 086);
  FileBtn1.Hint :=    frLoadStr(frRes + 087);
  FileBtn2.Hint :=    frLoadStr(frRes + 088);
  FileBtn3.Hint :=    frLoadStr(frRes + 089);
  FileBtn4.Hint :=    frLoadStr(frRes + 090);
  CutB.Hint :=        frLoadStr(frRes + 091);
  CopyB.Hint :=       frLoadStr(frRes + 092);
  PstB.Hint :=        frLoadStr(frRes + 093);
  UndoB.Hint :=       frLoadStr(frRes + 094);
  RedoB.Hint :=       frLoadStr(frRes + 095);
  ZB1.Hint :=         frLoadStr(frRes + 096);
  ZB2.Hint :=         frLoadStr(frRes + 097);
  SelAllB.Hint :=     frLoadStr(frRes + 098);
  PgB1.Hint :=        frLoadStr(frRes + 099);
  PgB2.Hint :=        frLoadStr(frRes + 100);
  PgB3.Hint :=        frLoadStr(frRes + 101);
  PgB4.Hint :=        frLoadStr(frRes + 193);
  GB1.Hint :=         frLoadStr(frRes + 102);
  GB2.Hint :=         frLoadStr(frRes + 103);
  GB3.Hint :=         frLoadStr(frRes + 104);
  HelpBtn.Hint :=     frLoadStr(frRes + 032);
  ExitB.Caption :=    frLoadStr(frRes + 105);
  ExitB.Hint :=       frLoadStr(frRes + 106);
  AlB1.Hint :=        frLoadStr(frRes + 107);
  AlB2.Hint :=        frLoadStr(frRes + 108);
  AlB3.Hint :=        frLoadStr(frRes + 109);
  AlB4.Hint :=        frLoadStr(frRes + 110);
  AlB5.Hint :=        frLoadStr(frRes + 111);
  AlB6.Hint :=        frLoadStr(frRes + 112);
  AlB7.Hint :=        frLoadStr(frRes + 113);
  AlB8.Hint :=        frLoadStr(frRes + 114);
  FnB1.Hint :=        frLoadStr(frRes + 115);
  FnB2.Hint :=        frLoadStr(frRes + 116);
  FnB3.Hint :=        frLoadStr(frRes + 117);
  ClB2.Hint :=        frLoadStr(frRes + 118);
  HlB1.Hint :=        frLoadStr(frRes + 119);
  C3.Hint :=          frLoadStr(frRes + 120);
  C2.Hint :=          frLoadStr(frRes + 121);
  FrB1.Hint :=        frLoadStr(frRes + 122);
  FrB2.Hint :=        frLoadStr(frRes + 123);
  FrB3.Hint :=        frLoadStr(frRes + 124);
  FrB4.Hint :=        frLoadStr(frRes + 125);
  FrB5.Hint :=        frLoadStr(frRes + 126);
  FrB6.Hint :=        frLoadStr(frRes + 127);
  ClB1.Hint :=        frLoadStr(frRes + 128);
  ClB3.Hint :=        frLoadStr(frRes + 129);
  C4.Hint :=          frLoadStr(frRes + 130);
  OB1.Hint :=         frLoadStr(frRes + 132);
  OB2.Hint :=         frLoadStr(frRes + 133);
  OB3.Hint :=         frLoadStr(frRes + 134);
  OB4.Hint :=         frLoadStr(frRes + 135);
  OB5.Hint :=         frLoadStr(frRes + 136);
  OB6.Hint :=         frLoadStr(frRes + 137);
  Align1.Hint :=      frLoadStr(frRes + 138);
  Align2.Hint :=      frLoadStr(frRes + 139);
  Align3.Hint :=      frLoadStr(frRes + 140);
  Align4.Hint :=      frLoadStr(frRes + 141);
  Align5.Hint :=      frLoadStr(frRes + 142);
  Align6.Hint :=      frLoadStr(frRes + 143);
  Align7.Hint :=      frLoadStr(frRes + 144);
  Align8.Hint :=      frLoadStr(frRes + 145);
  Align9.Hint :=      frLoadStr(frRes + 146);
  Align10.Hint :=     frLoadStr(frRes + 147);
  N2.Caption :=       frLoadStr(frRes + 148);
  N1.Caption :=       frLoadStr(frRes + 149);
  N3.Caption :=       frLoadStr(frRes + 150);
  N5.Caption :=       frLoadStr(frRes + 151);
  N16.Caption :=      frLoadStr(frRes + 152);
  N6.Caption :=       frLoadStr(frRes + 153);
  FileMenu.Caption := frLoadStr(frRes + 154);
  N23.Caption :=      frLoadStr(frRes + 155);
  N19.Caption :=      frLoadStr(frRes + 156);
  N20.Caption :=      frLoadStr(frRes + 157);
  N42.Caption :=      frLoadStr(frRes + 158);
  N8.Caption :=       frLoadStr(frRes + 159);
  N25.Caption :=      frLoadStr(frRes + 160);
  N39.Caption :=      frLoadStr(frRes + 161);
  N10.Caption :=      frLoadStr(frRes + 162);
  EditMenu.Caption := frLoadStr(frRes + 163);
  N46.Caption :=      frLoadStr(frRes + 164);
  N48.Caption :=      frLoadStr(frRes + 165);
  N11.Caption :=      frLoadStr(frRes + 166);
  N12.Caption :=      frLoadStr(frRes + 167);
  N13.Caption :=      frLoadStr(frRes + 168);
  N27.Caption :=      frLoadStr(frRes + 169);
  N28.Caption :=      frLoadStr(frRes + 170);
  N36.Caption :=      frLoadStr(frRes + 171);
  N29.Caption :=      frLoadStr(frRes + 172);
  N30.Caption :=      frLoadStr(frRes + 173);
  N32.Caption :=      frLoadStr(frRes + 174);
  N33.Caption :=      frLoadStr(frRes + 175);
  ToolMenu.Caption := frLoadStr(frRes + 176);
  N37.Caption :=      frLoadStr(frRes + 177);
  MastMenu.Caption := frLoadStr(frRes + 178);
  N14.Caption :=      frLoadStr(frRes + 179);
  Pan1.Caption :=     frLoadStr(frRes + 180);
  Pan2.Caption :=     frLoadStr(frRes + 181);
  Pan3.Caption :=     frLoadStr(frRes + 182);
  Pan4.Caption :=     frLoadStr(frRes + 183);
  Pan5.Caption :=     frLoadStr(frRes + 184);
  Pan6.Caption :=     frLoadStr(frRes + 185);
  Pan7.Caption :=     frLoadStr(frRes + 186);
  Pan8.Caption :=     frLoadStr(frRes + 450);
  N34.Caption :=      frLoadStr(frRes + 187);
  N17.Caption :=      frLoadStr(frRes + 188);
  N22.Caption :=      frLoadStr(frRes + 189);
  N35.Caption :=      frLoadStr(frRes + 190);
  N15.Caption :=      frLoadStr(frRes + 192);
  StB1.Hint   :=      frLoadStr(frRes + 191);
  N41.Caption :=      N29.Caption;
  N41.OnClick :=      N29.OnClick;
  N43.Caption :=      N30.Caption;
  N43.OnClick :=      N30.OnClick;
  N44.Caption :=      N25.Caption;
  N44.OnClick :=      N25.OnClick;
  N45.Caption :=      N15.Caption;
  N45.OnClick :=      N15.OnClick;

  FnB1.Glyph.Handle := frLocale.LoadBmp('FR_BOLD');
  FnB2.Glyph.Handle := frLocale.LoadBmp('FR_ITALIC');
  FnB3.Glyph.Handle := frLocale.LoadBmp('FR_UNDRLINE');
end;

procedure TfrDesignerForm.HighLightSwitch;
begin
  if SyntaxHighlight then
    EditorForm.Free
  else
    EditorForm1.Free;
  SyntaxHighLight := not SyntaxHighLight;
  if SyntaxHighlight then
    EditorForm := TfrEditorForm.Create(self)
  else
    EditorForm1 := TfrEditorForm1.Create(self);
end;

procedure TfrDesignerForm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Localize;
  Busy := True;
  FirstTime := True;

  PageView := TfrDesignerPage.Create(ScrollBox1);
  PageView.FDesigner := Self;
  PageView.PopupMenu := Popup1;
  PageView.ShowHint := True;

  ColorSelector := TColorSelector.Create(Self);
  ColorSelector.OnColorSelected := ColorSelected;

  for i := 0 to frAddInsCount - 1 do
  with frAddIns[i] do
    RegisterObject(ButtonBmp, ButtonHint, Integer(gtAddIn) + i, IsControl);

  if FirstInstance then
  begin
    RegisterTool(frLoadStr(SInsertFields), Image2.Picture.Bitmap, InsFieldsClick);
    for i := 0 to frToolsCount - 1 do
    with frTools[i] do
      RegisterTool(Caption, ButtonBmp, OnClick);
  end;


  MenuItems := TList.Create;
  ItemWidths := TStringlist.Create;
  if SyntaxHighlight then
    EditorForm := TfrEditorForm.Create(self)
  else
    EditorForm1 := TfrEditorForm1.Create(self);

{$IFDEF Delphi4}
  OnMouseWheelUp := FormMouseWheelUp;
  OnMouseWheelDown := FormMouseWheelDown;
{$ENDIF}
{$IFDEF Delphi5}
  MainMenu1.AutoHotkeys := maManual;
  MainMenu1.AutoLineReduction := maManual;
{$ENDIF}
{$IFDEF 1CScript}
  N99 := NewItem(frLoadStr(frRes + 194), 0, False, True, N99Click, 0, 'N99');
  EditMenu.Insert(EditMenu.IndexOf(N30) + 1, N99);
{$ENDIF}
end;

procedure TfrDesignerForm.FormShow(Sender: TObject);

  procedure DoHide(Obj: TObject; Enabled: Boolean);
  begin
    if Obj is TMenuItem then
      TMenuItem(Obj).Enabled := Enabled
    else
    begin
      if (DesignerComp <> nil) and DesignerComp.HideDisabledButtons then
        TControl(Obj).Visible := Enabled else
        TControl(Obj).Enabled := Enabled
    end
  end;

begin
  Screen.Cursors[crPencil] := LoadCursor(hInstance, 'FR_PENCIL');
  Panel7.Hide;

  DoHide(FileBtn1, FirstInstance and (DesignerRestrictions * [frdrDontCreateReport] = []));
  DoHide(N23, FirstInstance and (DesignerRestrictions * [frdrDontCreateReport] = []));

  DoHide(FileBtn4, FirstInstance and not (CurReport is TfrCompositeReport) and
    (DesignerRestrictions * [frdrDontPreviewReport] = []));
  DoHide(N39, FirstInstance and not (CurReport is TfrCompositeReport) and
    (DesignerRestrictions * [frdrDontPreviewReport] = []));

  DoHide(OB3, FirstInstance);
  DoHide(OB5, FirstInstance);

  DoHide(FileBtn2, FirstInstance and (DesignerRestrictions * [frdrDontLoadReport] = []));
  DoHide(N19, FirstInstance and (DesignerRestrictions * [frdrDontLoadReport] = []));

  DoHide(FileBtn3, DesignerRestrictions * [frdrDontSaveReport] = []);
  DoHide(N17, DesignerRestrictions * [frdrDontSaveReport] = []);
  DoHide(N20, DesignerRestrictions * [frdrDontSaveReport] = []);

  DoHide(PgB1, FirstInstance and (DesignerRestrictions * [frdrDontCreatePage] = []));
  DoHide(N29, FirstInstance and (DesignerRestrictions * [frdrDontCreatePage] = []));
  DoHide(N41, FirstInstance and (DesignerRestrictions * [frdrDontCreatePage] = []));

  DoHide(PgB2, FirstInstance and (DesignerRestrictions * [frdrDontDeletePage] = []));
  DoHide(N30, FirstInstance and (DesignerRestrictions * [frdrDontDeletePage] = []));
  DoHide(N43, FirstInstance and (DesignerRestrictions * [frdrDontDeletePage] = []));

  DoHide(PgB3, FirstInstance and (DesignerRestrictions * [frdrDontEditPage] = []));
  DoHide(N25, FirstInstance and (DesignerRestrictions * [frdrDontEditPage] = []));
  DoHide(N44, FirstInstance and (DesignerRestrictions * [frdrDontEditPage] = []));

  DoHide(PgB4, FirstInstance and (DesignerRestrictions * [frdrDontCreatePage] = []));
  DoHide(N15, FirstInstance and (DesignerRestrictions * [frdrDontCreatePage] = []));
  DoHide(N45, FirstInstance and (DesignerRestrictions * [frdrDontCreatePage] = []));

  DoHide(N42, FirstInstance and (DesignerRestrictions * [frdrDontEditVariables] = []));
  DoHide(N8, FirstInstance and (DesignerRestrictions * [frdrDontChangeReportOptions] = []));

  InspForm := TfrInspForm.Create(nil);
  with InspForm do
  begin
    ClearProperties;
    AddProperty('', 0, [frdtString], nil, Null, nil);
    OnModify := Self.OnModify;
    OnHeightChanged := HeightChanged;
    OnSelectionChanged := InspSelectionChanged;
    OnGetObjects := InspGetObjects;
  end;

  ClearUndoBuffer;
  ClearRedoBuffer;
  Modified := False;
  CurReport.ComponentModified := False;
  Busy := True;
  DocMode := dmDesigning;

  LastFontName := C2.Items[0];
  if C2.Items.IndexOf('Arial') <> -1 then
    LastFontName := 'Arial';
  LastFontSize := 10;

  CurPage := 0; // this cause page sizing
  if PageForm <> nil then
    PageForm.Show;

  if FirstInstance then
    CurDocName := CurReport.FileName else
    CurDocName := frLoadStr(SUntitled);
  Unselect;
  PageView.Init;
  EnableControls;
  BDown(OB1);
  frSetGlyph(0, ClB1, 1); frSetGlyph(0, ClB2, 0); frSetGlyph(0, ClB3, 2);
  ColorSelector.Hide;
  LinePanel.Hide;
  ShowPosition;
  RestoreState;
  FormResize(nil);
  ScrollBox1.OnResize := ScrollBox1Resize;
  AssignDefEditors;
  if (DesignerComp <> nil) and Assigned(DesignerComp.OnShow) then
    DesignerComp.OnShow(Self);
  if FirstTime then
    SetMenuBitmaps;
  FirstTime := False;
end;

procedure TfrDesignerForm.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  ClearUndoBuffer;
  ClearRedoBuffer;
  SaveState;
  CurReport.FileName := CurDocName;
  InspForm.Free;
  if PageForm <> nil then
    PageForm.Hide;
  ScrollBox1.OnResize := nil;

  for i := 0 to MenuItems.Count - 1 do
    TfrMenuItemInfo(MenuItems[i]).Free;
  MenuItems.Free;
  ItemWidths.Free;
  PageView.Free;
  if PageForm <> nil then
  begin
    PageForm.Free;
    PageForm := nil;
  end;
  if FirstInstance then
    ShowFieldsDialog(False);
  ColorSelector.Free;
  if SyntaxHighlight then
    EditorForm.Free
  else
    EditorForm1.Free;
end;

procedure TfrDesignerForm.FormResize(Sender: TObject);
begin
  if csDestroying in ComponentState then Exit;
  with ScrollBox1 do
  begin
    HorzScrollBar.Position := 0;
    VertScrollBar.Position := 0;
  end;
  PageView.SetPage;
  Panel7.Top := StatusBar1.Top + 3;
  Panel7.Show;
end;

procedure TfrDesignerForm.AssignDefEditors;
begin
  frMemoEditor := DefMemoEditor;
  frPictureEditor := DefPictureEditor;
  frTagEditor := DefTagEditor;
  frRestrEditor := DefRestrEditor;
  frHighlightEditor := DefHighlightEditor;
  frFieldEditor := DefFieldEditor;
  frDataSourceEditor := DefDataSourceEditor;
  frCrossDataSourceEditor := DefCrossDataSourceEditor;
  frGroupEditor := DefGroupEditor;
  frFontEditor := DefFontEditor;
end;

procedure TfrDesignerForm.ScrollBox1Resize(Sender: TObject);
begin
  PageView.SetPage;
end;

procedure TfrDesignerForm.SetCurPage(Value: Integer);

  procedure SwitchObjectsToolbar;
  var
    i: Integer;
    c: TControl;
  begin
    for i := 0 to Panel4.ControlCount - 1 do
    begin
      c := Panel4.Controls[i];
      if (c is TfrTBButton) and (c <> OB1) then
      begin
        c.Visible := not c.Visible;
        c.SetBounds(1000, 1000, 22, 22);
      end;
    end;
    Panel4.AdjustBounds;
    if Panel4.IsFloat then
    begin
      Panel4.FloatWindow.ClientWidth := Panel4.Width;
      Panel4.FloatWindow.ClientHeight := Panel4.Height;
    end;
  end;

  procedure PrepareObjects;
  var
    i: Integer;
    t: TfrView;
  begin
    DocMode := dmDesigning;
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      t.Draw(GridBitmap.Canvas);
    end;
  end;

begin
  FCurPage := Value;
  Page := CurReport.Pages[FCurPage];
  FPageType := Page.PageType;
  FR_Class.CurPage := Page;

  if (FPageType = ptDialog) and (PageForm = nil) then
  begin
    if OB2.Visible then
      SwitchObjectsToolbar;
    PageForm := TfrPageForm.Create(nil);
    PageForm.SetBounds(Page.Left, Page.Top, Page.Width, Page.Height);
    PageForm.OnCloseQuery := PageFormCloseQuery;
    PageForm.OnKeyDown := PageFormKeyDown;
    PageView.Color := clBtnFace;
    PageView.Parent := PageForm;
    PageForm.Icon := Icon;
    PageForm.Show;
  end
  else if (FPageType = ptReport) and (PageForm <> nil) then
  begin
    PageForm.OnResize := nil;
    if not OB2.Visible then
      SwitchObjectsToolbar;
    PageView.Parent := ScrollBox1;
    PageView.Color := clWhite;
    PageForm.Free;
    PageForm := nil;
  end;

  if PageForm <> nil then
  begin
    PageForm.OnResize := nil;
    PageForm.SetBounds(Page.Left, Page.Top, Page.Width, Page.Height);
    PageForm.OnResize := PageFormResize;
    PageForm.Caption := Page.Caption;
    PageForm.Color := Page.Color;
  end;
  ScrollBox1.VertScrollBar.Position := 0;
  ScrollBox1.HorzScrollBar.Position := 0;
  PageView.SetPage;
  SetPageTitles;
  Tab1.TabIndex := Value;
  ResetSelection;
  SendBandsToDown;
  PrepareObjects;
  PageView.Repaint;
end;

procedure TfrDesignerForm.SetGridSize(Value: Integer);
begin
  if FGridSizeX = Value then Exit;
  FGridSizeX := Value;
  FGridSizeY := Value;
  RedrawPage;
end;

procedure TfrDesignerForm.SetGridShow(Value: Boolean);
begin
  if FGridShow = Value then Exit;
  FGridShow := Value;
  GB1.Down := Value;
  RedrawPage;
end;

procedure TfrDesignerForm.SetGridAlign(Value: Boolean);
begin
  if FGridAlign = Value then Exit;
  GB2.Down := Value;
  FGridAlign := Value;
end;

procedure TfrDesignerForm.SetUnits(Value: TfrReportUnits);
var
  s: String;
begin
  FUnits := Value;
  case Value of
    ruPixels: s := frLoadStr(SPixels);
    ruMM:     s := frLoadStr(SMM);
    ruInches: s := frLoadStr(SInches);
  end;
  StatusBar1.Panels[0].Text := s;
  ShowPosition;
end;

procedure TfrDesignerForm.SetGrayedButtons(Value: Boolean);
  procedure DoButtons(t: Array of TControl);
  var
    i, j: Integer;
    c: TWinControl;
    c1: TControl;
  begin
    for i := Low(t) to High(t) do
    begin
      c := TWinControl(t[i]);
      for j := 0 to c.ControlCount - 1 do
      begin
        c1 := c.Controls[j];
        if c1 is TfrSpeedButton then
          TfrSpeedButton(c1).GrayedInactive := FGrayedButtons;
      end;
    end;
  end;
begin
  FGrayedButtons := Value;
  DoButtons([Panel1, Panel2, Panel3, Panel4, Panel5, Panel6]);
end;

procedure TfrDesignerForm.SetCurDocName(Value: String);
begin
  FCurDocName := Value;
  Caption := FCaption + ' - ' + ExtractFileName(Value);
end;

procedure TfrDesignerForm.SetModified(Value: Boolean);
begin
  CurReport.Modified := Value;
  if Value and FirstInstance then
    CurReport.ComponentModified := True;
  FileBtn3.Enabled := Value and (DesignerRestrictions * [frdrDontSaveReport] = []);
  N20.Enabled := FileBtn3.Enabled;
end;

function TfrDesignerForm.GetModified: Boolean;
begin
  Result := CurReport.Modified;
end;

procedure TfrDesignerForm.SelectObject(ObjName: String);
var
  t: TfrView;
begin
  t := Page.FindObject(ObjName);
  if t <> nil then // it's object name
  begin
    Unselect;
    SelNum := 1;
    t.Selected := True;
    SelectionChanged;
    RedrawPage;
    PageView.GetMultipleSelected;
    ShowPosition;
  end
  else if Pos('Page', ObjName) = 1 then // it's page name
    CurPage := StrToInt(Copy(ObjName, 5, 255)) - 1;
end;

function TfrDesignerForm.InsertDBField: String;
begin
  Result := '';
  with TfrFieldsForm.Create(nil) do
  begin
    if ShowModal = mrOk then
      if DBField <> '' then
        Result := '[' + DBField + ']';
    Free;
  end;
end;

function TfrDesignerForm.InsertExpression: String;
begin
  Result := '';
  with TfrExprForm.Create(nil) do
  begin
    if ShowModal = mrOk then
    begin
      Result := ExprMemo.Text;
      if Result <> '' then
        if not ((Result[1] = '[') and (Result[Length(Result)] = ']') and
          (Pos('[', Copy(Result, 2, 255)) = 0)) then
          Result := '[' + Result + ']';
    end;
    Free;
  end;
end;

procedure TfrDesignerForm.RegisterObject(ButtonBmp: TBitmap;
  ButtonHint: String; ButtonTag: Integer; IsControl: Boolean);
var
  b: TfrTBButton;
  i, j: Integer;
begin
  b := TfrTBButton.Create(Self);
  with b do
  begin
    Parent := Panel4;
    Visible := not IsControl;
    Glyph := ButtonBmp;

    Val(ButtonHint, i, j);
    if j = 0 then
      ButtonHint := frLoadStr(i);

    Hint := ButtonHint;
    GroupIndex := 1;
    Flat := True;
    SetBounds(1000, 1000, 22, 22);
    Tag := ButtonTag;
    GrayedInactive := False;
    OnMouseDown := OB2MouseDown;
  end;
end;

procedure TfrDesignerForm.RegisterTool(MenuCaption: String; ButtonBmp: TBitmap;
  OnClick: TNotifyEvent);
var
  m: TMenuItem;
  b: TfrTBButton;
  i, j: Integer;
begin
  m := TMenuItem.Create(MastMenu);

  Val(MenuCaption, i, j);
  if j = 0 then
    MenuCaption := frLoadStr(i);

  m.Caption := MenuCaption;
  m.OnClick := OnClick;
  MastMenu.Enabled := True;
  MastMenu.Add(m);
  Panel6.Height := 26; Panel6.Width := 26;
  b := TfrTBButton.Create(Self);
  with b do
  begin
    Parent := Panel6;
    Glyph := ButtonBmp;
    Hint := MenuCaption;
    Flat := True;
    SetBounds(1000, 1000, 22, 22);
    Tag := 36;
  end;
  b.OnClick := OnClick;
  Panel6.AdjustBounds;
end;

procedure TfrDesignerForm.AddPage;
begin
  if DesignerRestrictions * [frdrDontCreatePage] <> [] then Exit;
  CurReport.Pages.Add;
  Page := CurReport.Pages[CurReport.Pages.Count - 1];
  Page.CreateUniqueName;
  PgB3Click(nil);
  if WasOk then
  begin
    Modified := True;
    CurPage := CurReport.Pages.Count - 1
  end
  else
  begin
    CurReport.Pages.Delete(CurReport.Pages.Count - 1);
    CurPage := CurPage;
  end;
end;

procedure TfrDesignerForm.RemovePage(n: Integer);
  procedure AdjustSubReports;
  var
    i, j: Integer;
    t: TfrView;
  begin
    with CurReport do
      for i := 0 to Pages.Count - 1 do
      begin
        j := 0;
        while j < Pages[i].Objects.Count do
        begin
          t := Pages[i].Objects[j];
          if t.Typ = gtSubReport then
            if TfrSubReportView(t).SubPage = n then
            begin
              Pages[i].Delete(j);
              Dec(j);
            end
            else if TfrSubReportView(t).SubPage > n then
              Dec(TfrSubReportView(t).SubPage);
          Inc(j);
        end;
      end;
  end;
begin
  if DesignerRestrictions * [frdrDontDeletePage] <> [] then Exit;
  Modified := True;
  with CurReport do
    if (n >= 0) and (n < Pages.Count) then
      if Pages.Count = 1 then
        Pages[n].Clear else
      begin
        CurReport.Pages.Delete(n);
        Tab1.Tabs.Delete(n);
        Tab1.TabIndex := 0;
        AdjustSubReports;
        CurPage := 0;
      end;
  ClearUndoBuffer;
  ClearRedoBuffer;
end;

procedure TfrDesignerForm.SetPageTitles;
var
  i: Integer;
  s: String;

  function IsSubreport(PageN: Integer): Boolean;
  var
    i, j: Integer;
    t: TfrView;
  begin
    Result := False;
    with CurReport do
      for i := 0 to Pages.Count - 1 do
        for j := 0 to Pages[i].Objects.Count - 1 do
        begin
          t := Pages[i].Objects[j];
          if t.Typ = gtSubReport then
            if TfrSubReportView(t).SubPage = PageN then
            begin
              s := t.Name;
              Result := True;
              Exit;
            end;
        end;
  end;

begin
  if Tab1.Tabs.Count = CurReport.Pages.Count then
    for i := 0 to Tab1.Tabs.Count - 1 do
    begin
      if not IsSubreport(i) then
        s := frLoadStr(SPg) + IntToStr(i + 1);// CurReport.Pages[i].Name;
      if Tab1.Tabs[i] <> s then
        Tab1.Tabs[i] := s;
    end
  else
  begin
    Tab1.Tabs.Clear;
    for i := 0 to CurReport.Pages.Count - 1 do
    begin
      if not IsSubreport(i) then
        s := frLoadStr(SPg) + IntToStr(i + 1); //CurReport.Pages[i].Name;
      Tab1.Tabs.Add(s);
    end;
  end;
end;

procedure TfrDesignerForm.CutToClipboard;
var
  i: Integer;
  t: TfrView;
  m: TMemoryStream;
begin
  ClearClipBoard;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
    begin
      m := TMemoryStream.Create;
      frWriteByte(m, t.Typ);
      frWriteString(m, t.ClassName);
      t.SaveToStream(m);
      ClipBd.Add(m);
    end;
  end;
  DeleteObjects;
end;

procedure TfrDesignerForm.CopyToClipboard;
var
  i: Integer;
  t: TfrView;
  m: TMemoryStream;
begin
  ClearClipBoard;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
    begin
      m := TMemoryStream.Create;
      frWriteByte(m, t.Typ);
      frWriteString(m, t.ClassName);
      t.SaveToStream(m);
      ClipBd.Add(m);
    end;
  end;
end;

procedure TfrDesignerForm.SelectAll;
var
  i: Integer;
begin
  SelNum := 0;
  for i := 0 to Objects.Count - 1 do
  begin
    TfrView(Objects[i]).Selected := True;
    Inc(SelNum);
  end;
end;

procedure TfrDesignerForm.Unselect;
var
  i: Integer;
begin
  SelNum := 0;
  for i := 0 to Objects.Count - 1 do
    TfrView(Objects[i]).Selected := False;
end;

procedure TfrDesignerForm.ResetSelection;
begin
  Unselect;
  EnableControls;
  ShowPosition;
end;

function TfrDesignerForm.PointsToUnits(x: Double): Double;
begin
  Result := x;
  case FUnits of
    ruMM: Result := x / 18 * 5;
    ruInches: Result := x / 18 * 5 / 25.4;
  end;
end;

function TfrDesignerForm.UnitsToPoints(x: Double): Double;
begin
  Result := x;
  case FUnits of
    ruMM: Result := x / 5 * 18;
    ruInches: Result := x * 25.4 / 5 * 18;
  end;
end;

procedure TfrDesignerForm.RedrawPage;
begin
  PageView.Draw(10000, 0);
end;

procedure TfrDesignerForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  StepX, StepY: Integer;
  i, tx, ty, tx1, ty1, d, d1: Integer;
  t, t1: TfrView;
begin
  StepX := 0; StepY := 0;
  if (Key = vk_Escape) and not PageView.Down then
  begin
    OB1.Down := True;
    PageView.Perform(CM_MOUSELEAVE, 0, 0);
    PageView.MMove(nil, [], 0, 0);
    Unselect;
    RedrawPage;
    SelectionChanged;
  end;
  if Key = vk_F11 then
    InspForm.Grow;
  if (Key = vk_Return) and (ActiveControl = C3) then
  begin
    Key := 0;
    DoClick(C3);
  end;
  if (Key = vk_Return) and (ActiveControl = C4) then
  begin
    Key := 0;
    DoClick(C4);
  end;
  if (Key = vk_Insert) and (Shift = []) and (PageType = ptReport) then
  begin
    ShowFieldsDialog(True);
    Key := 0;
  end;
  if (Key = vk_Delete) and DelEnabled and (ActiveControl <> C3) then
  begin
    DeleteObjects;
    Key := 0;
  end;
  if (Key = vk_Return) and EditEnabled then
  begin
    if ssCtrl in Shift then
      ShowMemoEditor(nil) else
      ShowEditor;
  end;
  if (Chr(Key) in ['1'..'9']) and (ssCtrl in Shift) and DelEnabled then
  begin
    C4.Text := Chr(Key);
    DoClick(C4);
    Key := 0;
  end;
  if (Chr(Key) = 'F') and (ssCtrl in Shift) and DelEnabled then
  begin
    FrB5.Click;
    Key := 0;
  end;
  if (Chr(Key) = 'D') and (ssCtrl in Shift) and DelEnabled then
  begin
    FrB6.Click;
    Key := 0;
  end;
  if (Chr(Key) = 'G') and (ssCtrl in Shift) then
  begin
    ShowGrid := not ShowGrid;
    Key := 0;
  end;
  if (ssCtrl in Shift) and EditEnabled then
  begin
    if Chr(Key) = 'B' then
    begin
      FnB1.Down := not FnB1.Down;
      DoClick(FnB1);
    end;
    if Chr(Key) = 'I' then
    begin
      FnB2.Down := not FnB2.Down;
      DoClick(FnB2);
    end;
    if Chr(Key) = 'U' then
    begin
      FnB3.Down := not FnB3.Down;
      DoClick(FnB3);
    end;
  end;
  if CutEnabled then
    if (Key = vk_Delete) and (ssShift in Shift) then CutBClick(Self);
  if CopyEnabled then
    if (Key = vk_Insert) and (ssCtrl in Shift) then CopyBClick(Self);
  if PasteEnabled then
    if (Key = vk_Insert) and (ssShift in Shift) then PstBClick(Self);
  if Key = vk_Prior then
    with ScrollBox1.VertScrollBar do
    begin
      Position := Position - 200;
      Key := 0;
    end;
  if Key = vk_Next then
    with ScrollBox1.VertScrollBar do
    begin
      Position := Position + 200;
      Key := 0;
    end;
  if SelNum > 0 then
  begin
    if Key = vk_Up then StepY := -1
    else if Key = vk_Down then StepY := 1
    else if Key = vk_Left then StepX := -1
    else if Key = vk_Right then StepX := 1;
    if (StepX <> 0) or (StepY <> 0) then
    begin
      if ssCtrl in Shift then
        MoveObjects(StepX, StepY, False)
      else if ssShift in Shift then
        MoveObjects(StepX, StepY, True)
      else if SelNum = 1 then
      begin
        t := Objects[TopSelected];
        tx := t.x; ty := t.y; tx1 := t.x + t.dx; ty1 := t.y + t.dy;
        d := 10000; t1 := nil;
        for i := 0 to Objects.Count-1 do
        begin
          t := Objects[i];
          if not t.Selected and (t.Typ <> gtBand) then
          begin
            d1 := 10000;
            if StepX <> 0 then
            begin
              if t.y + t.dy < ty then
                d1 := ty - (t.y + t.dy)
              else if t.y > ty1 then
                d1 := t.y - ty1
              else if (t.y <= ty) and (t.y + t.dy >= ty1) then
                d1 := 0
              else
                d1 := t.y - ty;
              if ((t.x <= tx) and (StepX = 1)) or
                 ((t.x + t.dx >= tx1) and (StepX = -1)) then
                d1 := 10000;
              if StepX = 1 then
                if t.x >= tx1 then
                  d1 := d1 + t.x - tx1 else
                  d1 := d1 + t.x - tx
              else if t.x + t.dx <= tx then
                  d1 := d1 + tx - (t.x + t.dx) else
                  d1 := d1 + tx1 - (t.x + t.dx);
            end
            else if StepY <> 0 then
            begin
              if t.x + t.dx < tx then
                d1 := tx - (t.x + t.dx)
              else if t.x > tx1 then
                d1 := t.x - tx1
              else if (t.x <= tx) and (t.x + t.dx >= tx1) then
                d1 := 0
              else
                d1 := t.x - tx;
              if ((t.y <= ty) and (StepY = 1)) or
                 ((t.y + t.dy >= ty1) and (StepY = -1)) then
                d1 := 10000;
              if StepY = 1 then
                if t.y >= ty1 then
                  d1 := d1 + t.y - ty1 else
                  d1 := d1 + t.y - ty
              else if t.y + t.dy <= ty then
                  d1 := d1 + ty - (t.y + t.dy) else
                  d1 := d1 + ty1 - (t.y + t.dy);
            end;
            if d1 < d then
            begin
              d := d1;
              t1 := t;
            end;
          end;
        end;
        if t1 <> nil then
        begin
          t := Objects[TopSelected];
          if not (ssAlt in Shift) then
          begin
            PageView.DrawPage(dmSelection);
            Unselect;
            SelNum := 1;
            t1.Selected := True;
            PageView.DrawPage(dmSelection);
          end
          else if (DesignerRestrictions * [frdrDontMoveObj] = []) and
            ((t.Restrictions and frrfDontMove) = 0) then
          begin
            if (t1.x >= t.x + t.dx) and (Key = vk_Right) then
              t.x := t1.x - t.dx
            else if (t1.y > t.y + t.dy) and (Key = vk_Down) then
              t.y := t1.y - t.dy
            else if (t1.x + t1.dx <= t.x) and (Key = vk_Left) then
              t.x := t1.x + t1.dx
            else if (t1.y + t1.dy <= t.y) and (Key = vk_Up) then
              t.y := t1.y + t1.dy;
            RedrawPage;
          end;
          SelectionChanged;
        end;
      end;
    end;
  end;
end;

procedure TfrDesignerForm.MoveObjects(dx, dy: Integer; Resize: Boolean);
var
  i: Integer;
  t: TfrView;
begin
  AddUndoAction(acEdit);
  GetRegion;
  PageView.DrawPage(dmSelection);
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
      if Resize and (DesignerRestrictions * [frdrDontSizeObj] = []) and
        ((t.Restrictions and frrfDontSize) = 0) then
      begin
        Inc(t.dx, dx); Inc(t.dy, dy);
      end
      else if (DesignerRestrictions * [frdrDontMoveObj] = []) and
        ((t.Restrictions and frrfDontMove) = 0) then
      begin
        Inc(t.x, dx); Inc(t.y, dy);
      end;
  end;
  ShowPosition;
  PageView.GetMultipleSelected;
  PageView.Draw(TopSelected, ClipRgn);
end;

procedure TfrDesignerForm.DeleteObjects;
var
  i: Integer;
  t: TfrView;
begin
  AddUndoAction(acDelete);
  GetRegion;
  PageView.DrawPage(dmSelection);
  for i := Objects.Count - 1 downto 0 do
  begin
    t := Objects[i];
    if t.Selected and (DesignerRestrictions * [frdrDontDeleteObj] = []) and
      ((t.Restrictions and frrfDontDelete) = 0) then
    begin
      if (t is TfrBandView) and (TfrBandView(t).BandType = btChild) then
        NotifyParentBands(t.Name, '');
      Page.Delete(i);
    end;
  end;
  SetPageTitles;
  ResetSelection;
  FirstSelected := nil;
  PageView.Draw(10000, ClipRgn);
end;

procedure TfrDesignerForm.NotifyParentBands(OldName, NewName: String);
var
  i: Integer;
  t: TfrView;
begin
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if (t is TfrBandView) and (TfrBandView(t).ChildBand = OldName) then
      TfrBandView(t).ChildBand := NewName;
  end;
end;

procedure TfrDesignerForm.NotifySubReports(OldIndex, NewIndex: Integer);
var
  i, j: Integer;
  t: TfrView;
begin
  with CurReport do
    for i := 0 to Pages.Count - 1 do
      for j := 0 to Pages[i].Objects.Count - 1 do
      begin
        t := Pages[i].Objects[j];
        if (t is TfrSubReportView) and (TfrSubReportView(t).SubPage = OldIndex) then
          TfrSubReportView(t).SubPage := NewIndex;
      end;
end;

function TfrDesignerForm.SelStatus: TfrSelectionStatus;
var
  t: TfrView;
begin
  Result := [];
  if SelNum = 1 then
  begin
    t := Objects[TopSelected];
    if t.Typ = gtBand then
      Result := [ssBand]
    else if t is TfrMemoView then
      Result := [ssMemo] else
      Result := [ssOther];
  end
  else if SelNum > 1 then
    Result := [ssMultiple];
  if ClipBd.Count > 0 then
    Result := Result + [ssClipboardFull];
end;

function TfrDesignerForm.RectTypEnabled: Boolean;
begin
  Result := [ssMemo, ssOther, ssMultiple] * SelStatus <> [];
end;

function TfrDesignerForm.FontTypEnabled: Boolean;
begin
  Result := [ssMemo, ssMultiple] * SelStatus <> [];
end;

function TfrDesignerForm.ZEnabled: Boolean;
begin
  Result := [ssBand, ssMemo, ssOther, ssMultiple] * SelStatus <> [];
end;

function TfrDesignerForm.CutEnabled: Boolean;
begin
  Result := [ssBand, ssMemo, ssOther, ssMultiple] * SelStatus <> [];
end;

function TfrDesignerForm.CopyEnabled: Boolean;
begin
  Result := [ssBand, ssMemo, ssOther, ssMultiple] * SelStatus <> [];
end;

function TfrDesignerForm.PasteEnabled: Boolean;
begin
  Result := ssClipboardFull in SelStatus;
end;

function TfrDesignerForm.DelEnabled: Boolean;
begin
  Result := [ssBand, ssMemo, ssOther, ssMultiple] * SelStatus <> [];
end;

function TfrDesignerForm.EditEnabled: Boolean;
begin
  Result := [ssBand, ssMemo, ssOther] * SelStatus <> [];
end;

procedure TfrDesignerForm.EnableControls;
  procedure SetEnabled(const Ar: Array of TObject; en: Boolean);
  var
    i: Integer;
  begin
    for i := Low(Ar) to High(Ar) do
      if Ar[i] is TControl then
        (Ar[i] as TControl).Enabled := en
      else if Ar[i] is TMenuItem then
        (Ar[i] as TMenuItem).Enabled := en;
  end;
begin
  SetEnabled([FrB1, FrB2, FrB3, FrB4, FrB5, FrB6, ClB1, ClB3, C4, StB1],
    RectTypEnabled and (PageType = ptReport));
  SetEnabled([ClB2, C2, C3, FnB1, FnB2, FnB3, AlB1, AlB2, AlB3, AlB4, AlB5, AlB6, AlB7, AlB8, HlB1],
    FontTypEnabled);
  SetEnabled([ZB1, ZB2, N32, N33, GB3], ZEnabled);
  SetEnabled([CutB, N11, N2], CutEnabled);
  SetEnabled([CopyB, N12, N1], CopyEnabled);
  SetEnabled([PstB, N13, N3], PasteEnabled);
  SetEnabled([N27, N5], DelEnabled);
  SetEnabled([N36, N6], EditEnabled);
  StatusBar1.Repaint;
  PBox1Paint(nil);
end;

procedure TfrDesignerForm.SelectionChanged;
var
  t: TfrView;
begin
  Busy := True;
  ColorSelector.Hide;
  LinePanel.Hide;
  EnableControls;
  if SelNum = 1 then
  begin
    t := Objects[TopSelected];
    if t.Typ <> gtBand then
    with t do
    begin
      FrB1.Down := (FrameTyp and $8) <> 0;
      FrB2.Down := (FrameTyp and $4) <> 0;
      FrB3.Down := (FrameTyp and $2) <> 0;
      FrB4.Down := (FrameTyp and $1) <> 0;
      C4.Text := FloatToStrF(FrameWidth, ffGeneral, 2, 2);
      frSetGlyph(FillColor, ClB1, 1);
      frSetGlyph(FrameColor, ClB3, 2);
      if t is TfrMemoView then
      with t as TfrMemoView do
      begin
        frSetGlyph(Font.Color, ClB2, 0);
        if C2.Text <> Font.Name then
          C2.Text := Font.Name;
        if C3.Text <> IntToStr(Font.Size) then
          C3.Text := IntToStr(Font.Size);
        FnB1.Down := fsBold in Font.Style;
        FnB2.Down := fsItalic in Font.Style;
        FnB3.Down := fsUnderline in Font.Style;
        AlB4.Down := (Alignment and $4) <> 0;
        AlB5.Down := (Alignment and $18) = $8;
        AlB6.Down := (Alignment and $18) = 0;
        AlB7.Down := (Alignment and $18) = $10;
        case (Alignment and $3) of
          0: BDown(AlB1);
          1: BDown(AlB2);
          2: BDown(AlB3);
          3: BDown(AlB8);
        end;
      end;
    end;
  end
  else if SelNum > 1 then
  begin
    BUp(FrB1); BUp(FrB2); BUp(FrB3); BUp(FrB4);
    frSetGlyph(0, ClB1, 1); C4.Text := '1'; C2.Text := ''; C3.Text := '';
    BUp(FnB1); BUp(FnB2); BUp(FnB3);
    BDown(AlB1); BUp(AlB4); BUp(AlB5);
  end;
  ShowPosition;
  ShowContent;
  ActiveControl := nil;
  Busy := False;
end;

procedure TfrDesignerForm.ShowPosition;
begin
  FillInspFields;
  if not InspBusy then
    InspForm.ItemsChanged;
  StatusBar1.Repaint;
  PBox1Paint(nil);
end;

procedure TfrDesignerForm.ShowContent;
var
  t: TfrView;
  s: String;
begin
  s := '';
  if SelNum = 1 then
  begin
    t := Objects[TopSelected];
    s := t.Name;
    if t is TfrBandView then
      s := s + ': ' + frBandNames[Integer(TfrBandView(t).BandType)]
    else if t.Memo.Count > 0 then
      s := s + ': ' + t.Memo[0];
  end;
  StatusBar1.Panels[2].Text := s;
end;

procedure SetBit(var w: Word; e: Boolean; m: Integer);
begin
  if e then
    w := w or m else
    w := w and not m;
end;

procedure TfrDesignerForm.DoClick(Sender: TObject);
var
  i, b: Integer;
  DRect: TRect;
  t: TfrView;
begin
  if Busy then Exit;
  AddUndoAction(acEdit);
  PageView.DrawPage(dmSelection);
  GetRegion;
  b := (Sender as TControl).Tag;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if (DesignerRestrictions * [frdrDontModifyObj] = []) then
      if t.Selected and ((t.Restrictions and frrfDontModify) = 0) and
        ((t.Typ <> gtBand) or (b = 16)) then
      with t do
      begin
        if t is TfrMemoView then
        with t as TfrMemoView do
          case b of
            7: begin
                 LastFontName := C2.Text;
                 Font.Name := LastFontName;
               end;
            8: begin
                 Font.Size := StrToInt(C3.Text);
                 LastFontSize := Font.Size;
               end;
            9: begin
                 LastFontStyle := frGetFontStyle(Font.Style);
                 SetBit(LastFontStyle, FnB1.Down, 2);
                 Font.Style := frSetFontStyle(LastFontStyle);
               end;
           10: begin
                 LastFontStyle := frGetFontStyle(Font.Style);
                 SetBit(LastFontStyle, FnB2.Down, 1);
                 Font.Style := frSetFontStyle(LastFontStyle);
               end;
           11..13:
               begin
                 Alignment := (Alignment and $FC) + (b - 11);
                 LastAlignment := Alignment;
               end;
           14: begin
                 Alignment := (Alignment and $FB) + Word(AlB4.Down) * 4;
                 LastAlignment := Alignment;
               end;
           15: begin
                 Alignment := (Alignment and $E7) + Word(AlB5.Down) * 8 + Word(AlB7.Down) * $10;
                 LastAlignment := Alignment;
               end;
           17: begin
                 Font.Color := ColorSelector.Color;
                 LastFontColor := Font.Color;
               end;
           18: begin
                 LastFontStyle := frGetFontStyle(Font.Style);
                 SetBit(LastFontStyle, FnB3.Down, 4);
                 Font.Style := frSetFontStyle(LastFontStyle);
               end;
           22: begin
                 Alignment := (Alignment and $FC) + 3;
                 LastAlignment := Alignment;
               end;
          end;
        case b of
          1:
            begin
              SetBit(FrameTyp, FrB1.Down, 8);
              DRect := Rect(t.x - 10, t.y - 10, t.x + t.dx + 10, t.y + 10)
            end;
          2:
            begin
              SetBit(FrameTyp, FrB2.Down, 4);
              DRect := Rect(t.x - 10, t.y - 10, t.x + 10, t.y + t.dy + 10)
            end;
          3:
            begin
              SetBit(FrameTyp, FrB3.Down, 2);
              DRect := Rect(t.x - 10, t.y + t.dy - 10, t.x + t.dx + 10, t.y + t.dy + 10)
            end;
          4:
            begin
              SetBit(FrameTyp, FrB4.Down, 1);
              DRect := Rect(t.x + t.dx - 10, t.y - 10, t.x + t.dx + 10, t.y + t.dy + 10)
            end;
          20:
            begin
              FrameTyp := FrameTyp or $F;
              LastFrameTyp := $F;
            end;
          21:
            begin
              FrameTyp := FrameTyp and not $F;
              LastFrameTyp := 0;
            end;
          5:
            begin
              FillColor := ColorSelector.Color;
              LastFillColor := FillColor;
            end;
          6:
            begin
              FrameWidth := frStrToFloat(C4.Text);
              if t is TfrLineView then
                LastLineWidth := FrameWidth else
                LastFrameWidth := FrameWidth;
            end;
          19:
            begin
              FrameColor := ColorSelector.Color;
              LastFrameColor := FrameColor;
            end;
          25..30:
            FrameStyle := b - 25;
        end;
      end;
  end;
  PageView.Draw(TopSelected, ClipRgn);
  FillInspFields;
  InspForm.ItemsChanged;
  ActiveControl := nil;
  if b in [20, 21] then SelectionChanged;
end;

procedure TfrDesignerForm.frSpeedButton1Click(Sender: TObject);
begin
  LinePanel.Hide;
  DoClick(Sender);
end;

procedure TfrDesignerForm.HlB1Click(Sender: TObject);
var
  i: Integer;
  t: TfrMemoView;
begin
  t := Objects[TopSelected];
  with TfrHilightForm.Create(nil) do
  begin
    FontColor := t.Highlight.FontColor;
    FillColor := t.Highlight.FillColor;
    CB1.Checked := (t.Highlight.FontStyle and $2) <> 0;
    CB2.Checked := (t.Highlight.FontStyle and $1) <> 0;
    CB3.Checked := (t.Highlight.FontStyle and $4) <> 0;
    Edit1.Text := t.HighlightStr;
    if ShowModal = mrOk then
    begin
      AddUndoAction(acEdit);
      for i := 0 to Objects.Count - 1 do
      begin
        t := Objects[i];
        if t.Selected and (t is TfrMemoView) then
        begin
          t.HighlightStr := Edit1.Text;
          t.Highlight.FontColor := FontColor;
          t.Highlight.FillColor := FillColor;
          SetBit(t.Highlight.FontStyle, CB1.Checked, 2);
          SetBit(t.Highlight.FontStyle, CB2.Checked, 1);
          SetBit(t.Highlight.FontStyle, CB3.Checked, 4);
          SetBit(t.Highlight.FontStyle, False, 8);
        end;
      end;
    end;
    Free;
  end;
  RedrawPage;
end;


// ---------------------------------------------------- inspector section begin
function TfrDesignerForm.BeforeEdit: Boolean;
begin
  Result := (DesignerRestrictions * [frdrDontEditObj] = []) and
    ((TfrView(Objects[TopSelected]).Restrictions and frrfDontEditContents) = 0);
  if Result then
    PageView.DrawPage(dmSelection);
end;

procedure TfrDesignerForm.AfterEdit;
begin
  PageView.Draw(TopSelected, TfrView(Objects[TopSelected]).GetClipRgn(rtExtended));
end;

procedure TfrDesignerForm.DoEdit(ClassRef: TClass);
var
  f: TfrObjEditorForm;
begin
  if BeforeEdit then
  begin
    f := TfrObjEditorForm(ClassRef.NewInstance);
    f.Create(nil);
    f.ShowEditor(Objects[TopSelected]);
    f.Free;
    AfterEdit;
  end;
end;

procedure TfrDesignerForm.DefMemoEditor(Sender: TObject);
begin
  ShowMemoEditor(Sender);
end;

procedure TfrDesignerForm.DefPictureEditor(Sender: TObject);
begin
  DoEdit(TfrGEditorForm);
end;

procedure TfrDesignerForm.DefTagEditor(Sender: TObject);
var
  t: TfrView;
begin
  if Sender = nil then
    t := Objects[TopSelected] else
    t := TfrView(Sender);
  if BeforeEdit then
  begin
    with TfrAttrEditorForm.Create(nil) do
    begin
      ShowEditor(t);
      Free;
    end;
    AfterEdit;
  end;
end;

procedure TfrDesignerForm.DefRestrEditor(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  if Sender = nil then
    t := Objects[TopSelected] else
    t := TfrView(Sender);
  with TfrRestrictionsForm.Create(nil) do
  begin
    with t do
    begin
      CB1.Checked := (Restrictions and frrfDontEditMemo) <> 0;
      CB2.Checked := (Restrictions and frrfDontEditScript) <> 0;
      CB3.Checked := (Restrictions and frrfDontEditContents) <> 0;
      CB4.Checked := (Restrictions and frrfDontModify) <> 0;
      CB5.Checked := (Restrictions and frrfDontSize) <> 0;
      CB6.Checked := (Restrictions and frrfDontMove) <> 0;
      CB7.Checked := (Restrictions and frrfDontDelete) <> 0;
    end;
    if ShowModal = mrOk then
    begin
      BeforeEdit;
      for i := 0 to frDesigner.Page.Objects.Count - 1 do
      begin
        t := frDesigner.Page.Objects[i];
        if t.Selected then
          t.Restrictions :=
            Word(CB1.Checked) * frrfDontEditMemo +
            Word(CB2.Checked) * frrfDontEditScript +
            Word(CB3.Checked) * frrfDontEditContents +
            Word(CB4.Checked) * frrfDontModify +
            Word(CB5.Checked) * frrfDontSize +
            Word(CB6.Checked) * frrfDontMove +
            Word(CB7.Checked) * frrfDontDelete;
      end;
      AfterEdit;
    end;
    Free;
  end;
end;

procedure TfrDesignerForm.DefHighlightEditor(Sender: TObject);
begin
  HlB1Click(nil);
end;

procedure TfrDesignerForm.DefFieldEditor(Sender: TObject);
var
  t: TfrView;
  s: String;
begin
  if BeforeEdit then
  begin
    t := Objects[TopSelected];
    s := InsertDBField;
    if s <> '' then
    begin
      BeforeChange;
      t.Prop['DataField'] := s;
    end;
    FillInspFields;
    InspForm.ItemsChanged;
    AfterEdit;
  end;
end;

procedure TfrDesignerForm.DefDataSourceEditor(Sender: TObject);
begin
  DoEdit(TfrBandEditorForm);
end;

procedure TfrDesignerForm.DefCrossDataSourceEditor(Sender: TObject);
begin
  DoEdit(TfrVBandEditorForm);
end;

procedure TfrDesignerForm.DefGroupEditor(Sender: TObject);
begin
  DoEdit(TfrGroupEditorForm);
end;

procedure TfrDesignerForm.DefFontEditor(Sender: TObject);
var
  t: TfrView;
  t1: TfrMemoView;
  i: Integer;
  fd: TFontDialog;
begin
  if BeforeEdit then
  begin
    t1 := TfrMemoView(Objects[TopSelected]);
    fd := TFontDialog.Create(nil);
    with fd do
    begin
      Device := fdBoth;
      Font.Assign(t1.Font);
      if Execute then
      begin
        BeforeChange;
        for i := 0 to Objects.Count - 1 do
        begin
          t := Objects[i];
          if t.Selected and ((t.Restrictions and frrfDontModify) = 0) then
          begin
            if Font.Name <> t1.Font.Name then
              TfrMemoView(t).Font.Name := Font.Name;
            if Font.Size <> t1.Font.Size then
              TfrMemoView(t).Font.Size := Font.Size;
            if Font.Color <> t1.Font.Color then
              TfrMemoView(t).Font.Color := Font.Color;
            if Font.Style <> t1.Font.Style then
              TfrMemoView(t).Font.Style := Font.Style;
{$IFNDEF Delphi2}
            if Font.Charset <> t1.Font.Charset then
            begin
              TfrMemoView(t).Font.Charset := Font.Charset;
              LastCharset := Font.Charset;
            end;
{$ENDIF}
          end;
        end;
        AfterChange;
      end;
    end;
    fd.Free;
    AfterEdit;
  end;
end;


type
  THackObject = class(TfrObject)
  end;

procedure TfrDesignerForm.InspSelectionChanged(ObjName: String);
begin
  SelectObject(ObjName);
end;

procedure TfrDesignerForm.InspGetObjects(List: TStrings);
var
  i: Integer;
begin
  List.Clear;
  for i := 0 to Objects.Count - 1 do
    List.Add(TfrView(Objects[i]).Name);
  for i := 0 to CurReport.Pages.Count - 1 do
    List.Add('Page' + IntToStr(i + 1));
end;

procedure TfrDesignerForm.FillInspFields;
var
  t: TfrObject;
  s, s1: TStringList;
  i: Integer;

  procedure GetObjectProperties(t: TfrObject; s: TStrings);
  var
    i: Integer;
    p: PfrPropRec;
  begin
    s.Clear;
    for i := 0 to THackObject(t).PropList.Count - 1 do
    begin
      p := THackObject(t).PropList[i];
      if p^.PropType <> [] then
        s.Add(p^.PropName);
    end;
  end;

  procedure ExcludeStrings(t: TfrObject);
  var
    i: Integer;
    p: PfrPropRec;
  begin
    i := 0;
    while i < s.Count do
    begin
      p := t.PropRec[s[i]];
      if (s1.IndexOf(s[i]) = -1) or
        ((frdtOneObject in p^.PropType) and (SelNum > 1)) then
        s.Delete(i) else
        Inc(i);
    end;
  end;

  procedure FillProperties(t: TfrObject);
  var
    i: Integer;
    p: PfrPropRec;
    st: String;
  begin
    for i := 0 to s.Count - 1 do
    begin
      p := t.PropRec[s[i]];
      if (frdtHasEditor in p^.PropType) and not (frdtString in p^.PropType) then
        fld[i] := '(' + p^.PropName + ')'
      else
      begin
        st := t.Prop[p^.PropName];
        if (st <> fld[i]) and (fld[i] <> '-') then
          st := '';
        fld[i] := st;
      end;
    end;
  end;

  function ConvertToSize(s: String): String;
  var
    v: Double;
  begin
    v := frStrToFloat(s);
    if (FUnits = ruPixels) or (PageType = ptDialog) then
      Result := FloatToStrF(v, ffGeneral, 4, 2) else
      Result := FloatToStrF(PointsToUnits(v), ffFixed, 4, 2);
  end;

  procedure CreateProperties(t: TfrObject);
  var
    p: PfrPropRec;
    i: Integer;
    dt: TfrDataTypes;
  begin
    for i := 0 to s.Count - 1 do
    begin
      p := t.PropRec[s[i]];
      dt := p^.PropType;
      if frdtSize in p^.PropType then
      begin
        if fld[i] <> '' then
          fld[i] := ConvertToSize(fld[i]);
        if p^.PropType = [frdtSize] then
          if (Units = ruPixels) or (PageType = ptDialog) then
            dt := dt + [frdtInteger] else
            dt := dt + [frdtFloat];
      end;

      if not (frdtHasEditor in p^.PropType) then
        InspForm.AddProperty(s[i], fld[i], dt, p^.Enum, p^.EnumValues, p^.PropEditor) else
        InspForm.AddProperty(s[i], fld[i], p^.PropType, p^.Enum, p^.EnumValues, p^.PropEditor);
    end;
  end;

begin
  if InspBusy then Exit;
  InspForm.ClearProperties;
  InspForm.ObjectName := '';
  InspForm.CurObject := nil;

  s := TStringList.Create;
  s1 := TStringList.Create;

  if SelNum > 0 then
  begin
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if TfrView(t).Selected then
      begin
        t.DefineProperties;
        GetObjectProperties(t, s1);
        if s.Count = 0 then
          s.Assign(s1) else
          ExcludeStrings(t);
      end;
    end;

    t := Objects[TopSelected];
    if SelNum = 1 then
    begin
      InspForm.ObjectName := TfrView(t).Name;
      InspForm.CurObject := t;
    end;
    s.Sort;

    for i := 0 to s.Count - 1 do
      fld[i] := '-';

    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if TfrView(t).Selected then
        FillProperties(t);
    end;

    t := Objects[TopSelected];
    CreateProperties(t);
  end
  else
  begin
    t := Page;
    t.DefineProperties;
    GetObjectProperties(t, s);
    s.Sort;
    InspForm.CurObject := Page;
    InspForm.ObjectName := 'Page' + IntToStr(CurPage + 1);
    for i := 0 to s.Count - 1 do
      fld[i] := '-';
    FillProperties(t);
    CreateProperties(t);
  end;

  s.Free;
  s1.Free;
end;

procedure TfrDesignerForm.OnModify(Item: Integer);
var
  t: TfrView;
  t1: TfrObject;
  PropName: String;
  i: Integer;
  v: Variant;
  CantAssign: Boolean;

  function CheckUnique(Obj: TfrView; Name: String): Boolean;
  begin
    Result := (CurReport.FindObject(Name) = nil) and
       (not (Obj is TfrControl) or (frDialogForm.FindComponent(Name) = nil));
  end;

begin
  try
    PropName := InspForm.Items[Item];
    v := InspForm.PropValue[Item];
    if SelNum > 0 then
    begin
      if DesignerRestrictions * [frdrDontModifyObj] = [] then
      begin
        AddUndoAction(acEdit);
        for i := 0 to Objects.Count - 1 do
        begin
          t := Objects[i];
          if t.Selected then
          begin
            if PropName = 'Name' then
            begin
              if CheckUnique(t, v) then
              begin
                if (DesignerRestrictions * [frdrDontModifyObj] = []) and
                  ((t.Restrictions and frrfDontModify) = 0) then
                begin
                  NotifyParentBands(t.Name, v);
                  t.Prop[PropName] := v;
                end;
              end
            end
            else
            begin
              CantAssign := ((PropName = 'Left') or (PropName = 'Top')) and
                 (((t.Restrictions and frrfDontMove) <> 0) or
                 (DesignerRestrictions * [frdrDontMoveObj] <> []));
              CantAssign := CantAssign or
                 ((PropName = 'Width') or (PropName = 'Height')) and
                 (((t.Restrictions and frrfDontSize) <> 0) or
                 (DesignerRestrictions * [frdrDontSizeObj] <> []));
              if not CantAssign then
                if (frdtSize in t.PropRec[PropName].PropType) and (PageType = ptReport) then
                  t.Prop[PropName] := UnitsToPoints(v) else
                  t.Prop[PropName] := v;
            end;
          end;
        end;
      end
    end
    else if DesignerRestrictions * [frdrDontEditPage] = [] then
    begin
      CantAssign := False;
      t1 := Page;
      if frdtSize in t1.PropRec[PropName].PropType then
        v := UnitsToPoints(v);
      if (PropName = 'Type') and (Page.Objects.Count > 0) then
      begin
        CantAssign := Application.MessageBox(PChar(frLoadStr(SDeleteObjects)),
          PChar(frLoadStr(SWarning)), mb_YesNo + mb_IconWarning) <> mrYes;
        if not CantAssign then
          Page.Clear;
      end;

      if not CantAssign then
      begin
        t1.Prop[PropName] := v;
        Modified := True;
        with Page do
          ChangePaper(pgSize, pgWidth, pgHeight, pgBin, pgOr);
        if PropName <> 'Type' then
          InspBusy := True;
        CurPage := CurPage;
        InspBusy := False;
      end;
    end;

  finally
    FillInspFields;
    InspForm.ItemsChanged;
    RedrawPage;
    SetPageTitles;
    if frFieldsDialog <> nil then
      frFieldsDialog.RefreshData;
    StatusBar1.Repaint;
    PBox1Paint(nil);
  end;
end;
// ---------------------------------------------------- inspector section end

procedure TfrDesignerForm.StB1Click(Sender: TObject);
var
  p: TPoint;
begin
  ColorSelector.Hide;
  if not LinePanel.Visible then
  begin
    LinePanel.Parent := Self;
    with (Sender as TControl) do
      p := Self.ScreenToClient(Parent.ClientToScreen(Point(Left, Top)));
    LinePanel.Left := p.X;
    LinePanel.Top := p.Y + 26;
  end;
  LinePanel.Visible := not LinePanel.Visible;
end;

procedure TfrDesignerForm.ClB1Click(Sender: TObject);
var
  p: TPoint;
begin
  LinePanel.Hide;
  with (Sender as TControl) do
    p := Self.ScreenToClient(Parent.ClientToScreen(Point(Left, Top)));
  if ColorSelector.Left = p.X then
    ColorSelector.Visible := not ColorSelector.Visible
  else
  begin
    ColorSelector.Left := p.X;
    ColorSelector.Top := p.Y + 26;
    ColorSelector.Visible := True;
  end;
  ClrButton := Sender as TfrSpeedButton;
  with ClrButton.Glyph.Canvas do
    if Pixels[2, 14] <> Pixels[1, 13] then
      ColorSelector.Color := clNone else
      ColorSelector.Color := Pixels[2, 14];
end;

procedure TfrDesignerForm.ColorSelected(Sender: TObject);
var
  n: Integer;
begin
  n := 0;
  if ClrButton = ClB1 then
    n := 1
  else if ClrButton = ClB3 then
    n := 2;
  frSetGlyph(ColorSelector.Color, ClrButton, n);
  DoClick(ClrButton);
end;

procedure TfrDesignerForm.PBox1Paint(Sender: TObject);
var
  t: TfrView;
  p: TPoint;
  s: String;
  nx, ny: Double;
  x, y, dx, dy: Integer;

  function TopLeft: TPoint;
  var
    i: Integer;
    t: TfrView;
  begin
    Result.x := 10000; Result.y := 10000;
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if t.Selected then
      begin
        if t.x < Result.x then
          Result.x := t.x;
        if t.y < Result.y then
          Result.y := t.y;
      end;
    end;
  end;

begin
  with PBox1.Canvas do
  begin
    FillRect(Rect(0, 0, PBox1.Width, PBox1.Height));
    ImageList1.Draw(PBox1.Canvas, 2, 0, 0);
    if not ((SelNum = 0) and (PageView.Mode = mdSelect)) then
      ImageList1.Draw(PBox1.Canvas, 92, 0, 1);
    if (SelNum = 1) or ShowSizes then
    begin
      t := nil;
      if ShowSizes then
      begin
        x := OldRect.Left; y := OldRect.Top;
        dx := OldRect.Right - x; dy := OldRect.Bottom - y;
      end
      else
      begin
        t := Objects[TopSelected];
        x := t.x; y := t.y; dx := t.dx; dy := t.dy;
      end;
      if FUnits = ruPixels then
        s := IntToStr(x) + ';' + IntToStr(y) else
        s := FloatToStrF(PointsToUnits(x), ffFixed, 4, 2) + '; ' +
          FloatToStrF(PointsToUnits(y), ffFixed, 4, 2);
      TextOut(20, 1, s);
      if FUnits = ruPixels then
        s := IntToStr(dx) + ';' + IntToStr(dy) else
        s := FloatToStrF(PointsToUnits(dx), ffFixed, 4, 2) + '; ' +
          FloatToStrF(PointsToUnits(dy), ffFixed, 4, 2);
      TextOut(110, 1, s);
      if not ShowSizes and (t.Typ = gtPicture) then
        with t as TfrPictureView do
        if (Picture.Graphic <> nil) and not Picture.Graphic.Empty then
        begin
          s := IntToStr(dx * 100 div Picture.Width) + ',' +
               IntToStr(dy * 100 div Picture.Height);
          TextOut(170, 1, '% ' + s);
        end;
    end
    else if (SelNum > 0) and MRFlag then
    begin
      p := TopLeft;
      if FUnits = ruPixels then
        s := IntToStr(p.x) + ';' + IntToStr(p.y) else
        s := FloatToStrF(PointsToUnits(p.x), ffFixed, 4, 2) + '; ' +
          FloatToStrF(PointsToUnits(p.y), ffFixed, 4, 2);
      TextOut(20, 1, s);

      nx := 0; ny := 0;
      if OldRect1.Right - OldRect1.Left <> 0 then
        nx := (OldRect.Right - OldRect.Left) / (OldRect1.Right - OldRect1.Left);
      if OldRect1.Bottom - OldRect1.Top <> 0 then
        ny := (OldRect.Bottom - OldRect.Top) / (OldRect1.Bottom - OldRect1.Top);
      s := IntToStr(Round(nx * 100)) + ',' + IntToStr(Round(ny * 100));
      TextOut(170, 1, '% ' + s);
    end
    else if (SelNum = 0) and (PageView.Mode = mdSelect) then
    begin
      x := OldRect.Left; y := OldRect.Top;
      if FUnits = ruPixels then
        s := IntToStr(x) + ';' + IntToStr(y) else
        s := FloatToStrF(PointsToUnits(x), ffFixed, 4, 2) + '; ' +
          FloatToStrF(PointsToUnits(y), ffFixed, 4, 2);
      TextOut(20, 1, s);
    end
  end;
end;

procedure TfrDesignerForm.ShowMemoEditor(Sender: TObject);
var
  t: TfrView;
begin
  if Sender = nil then
    t := Objects[TopSelected] else
    t := TfrView(Sender);
  if SyntaxHighlight then
  begin
    if EditorForm.ShowEditor(t) = mrOk then
    begin
      PageView.DrawPage(dmSelection);
      PageView.Draw(TopSelected, t.GetClipRgn(rtExtended));
    end
  end
  else
    if EditorForm1.ShowEditor(t) = mrOk then
    begin
      PageView.DrawPage(dmSelection);
      PageView.Draw(TopSelected, t.GetClipRgn(rtExtended));
    end;

  ActiveControl := nil;
end;

procedure TfrDesignerForm.ShowEditor;
var
  t: TfrView;
  bt: TfrBandType;
begin
  t := Objects[TopSelected];
  if (DesignerRestrictions * [frdrDontEditObj] <> []) or
    ((t.Restrictions and frrfDontEditContents) <> 0) then Exit;
  if t.Typ = gtSubReport then
    CurPage := (t as TfrSubReportView).SubPage
  else if t.Typ <> gtBand then
  begin
    PageView.DrawPage(dmSelection);
    t.ShowEditor;
    PageView.Draw(TopSelected, t.GetClipRgn(rtExtended));
  end
  else
  begin
    PageView.DrawPage(dmSelection);
    bt := (t as TfrBandView).BandType;
    if bt in [btMasterData, btDetailData, btSubDetailData] then
      with TfrBandEditorForm.Create(nil) do
      begin
        ShowEditor(t);
        Free;
      end
    else if bt = btGroupHeader then
      with TfrGroupEditorForm.Create(nil) do
      begin
        ShowEditor(t);
        Free;
      end
    else if bt = btCrossData then
      with TfrVBandEditorForm.Create(nil) do
      begin
        ShowEditor(t);
        Free;
      end
    else
      PageView.DFlag := False;
    PageView.Draw(TopSelected, t.GetClipRgn(rtExtended));
  end;
  ShowContent;
  ShowPosition;
  ActiveControl := nil;
end;

procedure TfrDesignerForm.ReleaseAction(ActionRec: TfrUndoRec);
var
  p, p1: PfrUndoObj;
begin
  p := ActionRec.Objects;
  while p <> nil do
  begin
    if ActionRec.Action in [acDelete, acEdit] then
      p^.ObjPtr.Free;
    p1 := p;
    p := p^.Next;
    FreeMem(p1, SizeOf(TfrUndoObj));
  end;
end;

procedure TfrDesignerForm.ClearBuffer(Buffer: TfrUndoBuffer; var BufferLength: Integer);
var
  i: Integer;
begin
  for i := 0 to BufferLength - 1 do
    ReleaseAction(Buffer[i]);
  BufferLength := 0;
end;

procedure TfrDesignerForm.ClearUndoBuffer;
begin
  ClearBuffer(FUndoBuffer, FUndoBufferLength);
  N46.Enabled := False;
  UndoB.Enabled := N46.Enabled;
end;

procedure TfrDesignerForm.ClearRedoBuffer;
begin
  ClearBuffer(FRedoBuffer, FRedoBufferLength);
  N48.Enabled := False;
  RedoB.Enabled := N48.Enabled;
end;

procedure TfrDesignerForm.Undo(Buffer: PfrUndoBuffer);
var
  p, p1: PfrUndoObj;
  r: PfrUndoRec1;
  BufferLength: Integer;
  List: TList;
  a: TfrUndoAction;
begin
  if Buffer = @FUndoBuffer then
    BufferLength := FUndoBufferLength else
    BufferLength := FRedoBufferLength;

  if Buffer[BufferLength - 1].Page <> CurPage then Exit;
  List := TList.Create;
  a := Buffer[BufferLength - 1].Action;
  p := Buffer[BufferLength - 1].Objects;
  while p <> nil do
  begin
    GetMem(r, SizeOf(TfrUndoRec1));
    r^.ObjPtr := p^.ObjPtr;
    r^.Int := p^.Int;
    List.Add(r);
    case Buffer[BufferLength - 1].Action of
      acInsert:
        begin
          r^.Int := Page.FindObjectByID(p^.ObjID);
          r^.ObjPtr := Objects[r^.Int];
          a := acDelete;
        end;
      acDelete: a := acInsert;
      acEdit:   r^.ObjPtr := Objects[p^.Int];
      acZOrder:
        begin
          r^.Int := Page.FindObjectByID(p^.ObjID);
          r^.ObjPtr := Objects[r^.Int];
          p^.ObjPtr := r^.ObjPtr;
        end;
    end;
    p := p^.Next;
  end;
  if Buffer = @FUndoBuffer then
    AddAction(@FRedoBuffer, a, List) else
    AddAction(@FUndoBuffer, a, List);
  List.Free;

  p := Buffer[BufferLength - 1].Objects;
  while p <> nil do
  begin
    case Buffer[BufferLength - 1].Action of
      acInsert: Page.Delete(Page.FindObjectByID(p^.ObjID));
      acDelete: Objects.Insert(p^.Int, p^.ObjPtr);
      acEdit:
        begin
          TfrView(Objects[p^.Int]).Assign(p^.ObjPtr);
          p^.ObjPtr.Free;
        end;
      acZOrder: Objects[p^.Int] := p^.ObjPtr;
    end;
    p1 := p;
    p := p^.Next;
    FreeMem(p1, SizeOf(TfrUndoObj));
  end;

  if Buffer = @FUndoBuffer then
    Dec(FUndoBufferLength) else
    Dec(FRedoBufferLength);

  ResetSelection;
  RedrawPage;
  N46.Enabled := FUndoBufferLength > 0;
  UndoB.Enabled := N46.Enabled;
  N48.Enabled := FRedoBufferLength > 0;
  RedoB.Enabled := N48.Enabled;
end;

procedure TfrDesignerForm.AddAction(Buffer: PfrUndoBuffer; a: TfrUndoAction; List: TList);
var
  i: Integer;
  p, p1: PfrUndoObj;
  r: PfrUndoRec1;
  t, t1: TfrView;
  BufferLength: Integer;
begin
  if Buffer = @FUndoBuffer then
    BufferLength := FUndoBufferLength else
    BufferLength := FRedoBufferLength;
  if BufferLength >= MaxUndoBuffer then
  begin
    ReleaseAction(Buffer[0]);
    for i := 0 to MaxUndoBuffer - 2 do
      Buffer^[i] := Buffer^[i + 1];
    BufferLength := MaxUndoBuffer - 1;
  end;
  Buffer[BufferLength].Action := a;
  Buffer[BufferLength].Page := CurPage;
  Buffer[BufferLength].Objects := nil;
  p := nil;
  for i := 0 to List.Count - 1 do
  begin
    r := List[i];
    t := r^.ObjPtr;
    GetMem(p1, SizeOf(TfrUndoObj));
    p1^.Next := nil;
    if Buffer[BufferLength].Objects = nil then
      Buffer[BufferLength].Objects := p1 else
      p^.Next := p1;
    p := p1;
    case a of
      acInsert: p^.ObjID := t.ID;
      acDelete, acEdit:
        begin
          t1 := frCreateObject(t.Typ, t.ClassName);
          t1.Assign(t);
          t1.ID := t.ID;
          p^.ObjID := t.ID;
          p^.ObjPtr := t1;
          p^.Int := r^.Int;
        end;
      acZOrder:
        begin
          p^.ObjID := t.ID;
          p^.Int := r^.Int;
        end;
    end;
    FreeMem(r, SizeOf(TfrUndoRec1));
  end;
  if Buffer = @FUndoBuffer then
  begin
    FUndoBufferLength := BufferLength + 1;
    N46.Enabled := True;
    UndoB.Enabled := True;
  end
  else
  begin
    FRedoBufferLength := BufferLength + 1;
    N48.Enabled := True;
    RedoB.Enabled := True;
  end;
  Modified := True;
end;

procedure TfrDesignerForm.AddUndoAction(a: TfrUndoAction);
var
  i: Integer;
  t: TfrView;
  List: TList;
  p: PfrUndoRec1;
  Flag: Boolean;
begin
  if not DisableUndo then
  begin
    ClearRedoBuffer;
    List := TList.Create;
    Flag := False;
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if t.Selected and (t is TfrNonVisualControl) then
        Flag := True;
      if (t.Selected or (a = acZOrder)) and ((t.Flags and flDontUndo) = 0) then
      begin
        GetMem(p, SizeOf(TfrUndoRec1));
        p^.ObjPtr := t;
        p^.Int := i;
        List.Add(p);
      end;
    end;
    if List.Count > 0 then
      AddAction(@FUndoBuffer, a, List) else
      Modified := True;
    List.Free;

    if Flag and (frFieldsDialog <> nil) then
      frFieldsDialog.RefreshData;
  end
  else
    Modified := True;

end;

procedure TfrDesignerForm.BeforeChange;
begin
  AddUndoAction(acEdit);
end;

procedure TfrDesignerForm.AfterChange;
begin
  PageView.DrawPage(dmSelection);
  PageView.Draw(TopSelected, 0);
  FillInspFields;
  InspForm.ItemsChanged;
end;

procedure TfrDesignerForm.ZB1Click(Sender: TObject);   // go up
var
  i, j, n: Integer;
  t: TfrView;
begin
  AddUndoAction(acZOrder);
  n := Objects.Count; i := 0; j := 0;
  while j < n do
  begin
    t := Objects[i];
    if t.Selected and (DesignerRestrictions * [frdrDontMoveObj] = []) and
      ((t.Restrictions and frrfDontMove) = 0) then
    begin
      Objects.Delete(i);
      Objects.Add(t);
    end
    else
      Inc(i);
    Inc(j);
  end;
  SendBandsToDown;
  RedrawPage;
end;

procedure TfrDesignerForm.ZB2Click(Sender: TObject);    // go down
var
  t: TfrView;
  i, j, n: Integer;
begin
  AddUndoAction(acZOrder);
  n := Objects.Count; j := 0; i := n - 1;
  while j < n do
  begin
    t := Objects[i];
    if t.Selected and (DesignerRestrictions * [frdrDontMoveObj] = []) and
      ((t.Restrictions and frrfDontMove) = 0) then
    begin
      Objects.Delete(i);
      Objects.Insert(0, t);
    end
    else
      Dec(i);
    Inc(j);
  end;
  SendBandsToDown;
  RedrawPage;
end;

procedure TfrDesignerForm.PgB1Click(Sender: TObject); // add page
begin
  ResetSelection;
  AddPage;
end;

procedure TfrDesignerForm.PgB2Click(Sender: TObject); // remove page
begin
  if CurReport.Pages.Count > 1 then
    if Application.MessageBox(PChar(frLoadStr(SRemovePg)),
      PChar(frLoadStr(SConfirm)), mb_IconQuestion + mb_YesNo) = mrYes then
      RemovePage(CurPage);
end;

procedure TfrDesignerForm.PgB4Click(Sender: TObject); // add dialog page
begin
  if DesignerRestrictions * [frdrDontCreatePage] <> [] then Exit;
  CurReport.Pages.Add;
  Page := CurReport.Pages[CurReport.Pages.Count - 1];
  Page.CreateUniqueName;
  Page.PageType := ptDialog;
  Modified := True;
  CurPage := CurReport.Pages.Count - 1;
end;

procedure TfrDesignerForm.OB1Click(Sender: TObject);
begin
  ObjRepeat := False;
end;

procedure TfrDesignerForm.OB2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ObjRepeat := ssShift in Shift;
  PageView.Cursor := crDefault;
end;

procedure TfrDesignerForm.CutBClick(Sender: TObject); //cut
begin
  AddUndoAction(acDelete);
  CutToClipboard;
  FirstSelected := nil;
  EnableControls;
  ShowPosition;
  RedrawPage;
end;

procedure TfrDesignerForm.CopyBClick(Sender: TObject); //copy
begin
  CopyToClipboard;
  EnableControls;
end;

procedure TfrDesignerForm.PstBClick(Sender: TObject); //paste
var
  i, minx, miny: Integer;
  t: TfrView;
  b: Byte;
  m: TMemoryStream;
  Band: TfrView;
  s: String;

  procedure UnselectLeaveBand;
  var
    i: Integer;
  begin
    SelNum := 0;
    for i := 0 to Objects.Count - 1 do
      if TfrView(Objects[i]).Typ <> gtBand then
          TfrView(Objects[i]).Selected := False;
  end;

  procedure CreateName(t: TfrView);
  begin
    if CurReport.FindObject(t.Name) <> nil then
      t.CreateUniqueName;
    t.Prop['Name'] := t.Name;
  end;

  function CheckOne(b: Byte; s: String): Boolean;
  var
    i: Integer;
    t: TfrView;
  begin
    Result := True;
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if (t.Typ = b) and (t.ClassName = s) and ((t.Flags and flOnePerPage) <> 0) then
      begin
        Result := False;
        Exit;
      end;
    end;
  end;

begin
  if DesignerRestrictions * [frdrDontCreateObj] <> [] then Exit;
  UnselectLeaveBand;
  if not IsBandsSelect(Band) then
    Band := nil else
    Band.Selected := False;
  SelNum := 0;
  minx := 32767; miny := 32767;
  with ClipBd do
    for i := 0 to Count - 1 do
    begin
      m := Items[i];
      m.Position := 0;
      b := frReadByte(m);
      s := frReadString(m);
      if CheckOne(b, s) then
      begin
        t := frCreateObject(b, s);
        frVersion := frCurrentVersion;
        t.LoadFromStream(m);
        if t.x < minx then minx := t.x;
        if t.y < miny then miny := t.y;
        t.Free;
      end;
    end;

  for i := 0 to ClipBd.Count - 1 do
  begin
    m := ClipBd.Items[i];
    m.Position := 0;
    b := frReadByte(m);
    s := frReadString(m);
    if not CheckOne(b, s) then
      continue;
    t := frCreateObject(b, s);
    frVersion := frCurrentVersion;
    t.LoadFromStream(m);
    CreateName(t);

    if t.Typ = gtBand then
      if not (TfrBandType(t.FrameTyp) in [btMasterHeader..btSubDetailFooter,
                                          btGroupHeader, btGroupFooter]) and
        frCheckBand(TfrBandType(t.FrameTyp)) then
      begin
        t.Free;
        continue;
      end;
    if PageView.Left < 0 then
      t.x := t.x - minx + ((-PageView.Left) div GridSizeX * GridSizeX) else
      t.x := t.x - minx;

    if PageView.Top < 0 then
      t.y := t.y - miny + ((-PageView.Top) div GridSizeY * GridSizeY) else
      t.y := t.y - miny;
    if Band <> nil then
      t.y := band.y;
    t.Selected := True;
    Inc(SelNum);
    Objects.Add(t);
  end;
  SelectionChanged;
  SendBandsToDown;
  PageView.GetMultipleSelected;
  RedrawPage;
  AddUndoAction(acInsert);
end;

procedure TfrDesignerForm.UndoBClick(Sender: TObject); // undo
begin
  Undo(@FUndoBuffer);
end;

procedure TfrDesignerForm.RedoBClick(Sender: TObject); // redo
begin
  Undo(@FRedoBuffer);
end;

procedure TfrDesignerForm.SelAllBClick(Sender: TObject); // select all
begin
  PageView.DrawPage(dmSelection);
  SelectAll;
  PageView.GetMultipleSelected;
  PageView.DrawPage(dmSelection);
  SelectionChanged;
end;

procedure TfrDesignerForm.ExitBClick(Sender: TObject);
begin
  if FormStyle = fsNormal then
    ModalResult := mrOk else
    Close;
end;


procedure TfrDesignerForm.N5Click(Sender: TObject); // popup delete command
begin
  DeleteObjects;
end;

procedure TfrDesignerForm.N6Click(Sender: TObject); // popup edit command
begin
  ShowEditor;
end;

procedure TfrDesignerForm.FileBtn1Click(Sender: TObject); // create new
var
  w: Word;
begin
  if DesignerRestrictions * [frdrDontCreateReport] <> [] then Exit;
  if Modified then
  begin
    w := Application.MessageBox(PChar(frLoadStr(SSaveChanges) + ' ' + frLoadStr(STo) + ' ' +
      ExtractFileName(CurDocName) + '?'),
      PChar(frLoadStr(SConfirm)), mb_IconQuestion + mb_YesNoCancel);
    if w = mrCancel then Exit;
    if w = mrYes then
    begin
      FileBtn3Click(nil);
      if not WasOk then Exit;
    end;
  end;
  ClearUndoBuffer;
  CurReport.Clear;
  CurReport.Pages.Add;
  CurReport.Pages[CurReport.Pages.Count - 1].CreateUniqueName;
  CurPage := 0;
  CurDocName := frLoadStr(SUntitled);
  Modified := False;
  CurReport.ComponentModified := True;
  if frFieldsDialog <> nil then
    frFieldsDialog.RefreshData;
end;

procedure TfrDesignerForm.N23Click(Sender: TObject); // create new from template
begin
  if DesignerComp <> nil then
    frTemplateDir := DesignerComp.TemplateDir;
  if DesignerRestrictions * [frdrDontCreateReport] <> [] then Exit;
  with TfrTemplForm.Create(nil) do
  begin
    if ShowModal = mrOk then
    begin
      ClearUndoBuffer;
      CurReport.LoadTemplate(TemplName, nil, nil, True);
      CurDocName := frLoadStr(SUntitled);
      CurPage := 0; // do all
    end;
    Free;
  end;
end;

procedure TfrDesignerForm.FileBtn2Click(Sender: TObject); // open
var
  w: Word;
  rName: String;
  Opened: Boolean;
begin
  if DesignerRestrictions * [frdrDontLoadReport] <> [] then Exit;
  w := mrNo;
  if Modified then
    w := Application.MessageBox(PChar(frLoadStr(SSaveChanges) + ' ' + frLoadStr(STo) + ' ' +
      ExtractFileName(CurDocName) + '?'),
      PChar(frLoadStr(SConfirm)), mb_IconQuestion + mb_YesNoCancel);
  if w = mrCancel then Exit;
  if w = mrYes then
  begin
    FileBtn3Click(nil);
    if not WasOk then Exit;
  end;

  PageView.DisableDraw := True;
  Opened := True;
  if (DesignerComp <> nil) and Assigned(DesignerComp.OnLoadReport) then
  begin
    rName := '';
    DesignerComp.OnLoadReport(CurReport, rName, Opened);
  end
  else
  begin
    OpenDialog1.Filter :=
      frLoadStr(SFormFile) + ' (*.frf)|*.frf|' +
      frLoadStr(SDictFile) + ' (*.frd)|*.frd';
    if (DesignerComp <> nil) and (DesignerComp.OpenDir <> '') then
      OpenDialog1.InitialDir := DesignerComp.OpenDir;
    Opened := OpenDialog1.Execute;
    rName := OpenDialog1.FileName;
    if Opened then
      if OpenDialog1.FilterIndex = 1 then
        CurReport.LoadFromFile(rName)
      else
      begin
        CurReport.Dictionary.LoadFromFile(rName);
        Opened := False;
      end;
  end;

  PageView.DisableDraw := False;
  if Opened then
  begin
    ClearUndoBuffer;
    CurDocName := rName;
    Modified := False;
    CurReport.ComponentModified := True;
    CurPage := 0; // do all
    if frFieldsDialog <> nil then
      frFieldsDialog.RefreshData;
  end;
end;

procedure TfrDesignerForm.N20Click(Sender: TObject); // save as
var
  rName: String;
  Saved: Boolean;
begin
  if DesignerRestrictions * [frdrDontSaveReport] <> [] then Exit;
  WasOk := False;

  if (DesignerComp <> nil) and Assigned(DesignerComp.OnSaveReport) then
  begin
    Saved := True;
    rName := CurDocName;
    DesignerComp.OnSaveReport(CurReport, rName, True, Saved);
    if Saved then
    begin
      CurDocName := rName;
      WasOk := True;
    end;
  end
  else
  begin
    with SaveDialog1 do
    begin
      Filter := frLoadStr(SFormFile) + ' (*.frf)|*.frf|' +
                frLoadStr(SForm3File) + ' (*.fr3)|*.fr3|' +
                frLoadStr(STemplFile) + ' (*.frt)|*.frt|' +
                frLoadStr(SDictFile) + ' (*.frd)|*.frd';
      if (DesignerComp <> nil) and (DesignerComp.SaveDir <> '') then
        InitialDir := DesignerComp.SaveDir;
      FileName := CurDocName;
      FilterIndex := 1;
      if Execute then
        if FilterIndex = 1 then
        begin
          rName := ChangeFileExt(FileName, '.frf');
          CurReport.SaveToFile(rName);
          CurDocName := rName;
          WasOk := True;
        end
        else if FilterIndex = 2 then
        begin
          rName := ChangeFileExt(FileName, '.fr3');
          CurReport.SaveToFR3File(rName);
          CurDocName := rName;
          WasOk := True;
        end
        else if FilterIndex = 3 then
        begin
          rName := ChangeFileExt(FileName, '.frt');
          if DesignerComp <> nil then
            frTemplateDir := DesignerComp.TemplateDir;
          if frTemplateDir <> '' then
            rName := frTemplateDir + '\' + ExtractFileName(rName);
          with TfrTemplNewForm.Create(nil) do
          begin
            if ShowModal = mrOk then
            begin
              CurReport.SaveTemplate(rName, Memo1.Lines, Image1.Picture.Bitmap);
              WasOk := True;
            end;
            Free;
          end;
        end
        else
        begin
          rName := ChangeFileExt(FileName, '.frd');
          CurReport.Dictionary.SaveToFile(rName);
        end;
    end;
  end;
  if WasOk then
    Modified := False;
end;

procedure TfrDesignerForm.FileBtn3Click(Sender: TObject); // save
var
  rName: String;
  Saved: Boolean;
begin
  if DesignerRestrictions * [frdrDontSaveReport] <> [] then Exit;
  if CurDocName <> frLoadStr(SUntitled) then
  begin
    WasOk := True;
    if (DesignerComp <> nil) and Assigned(DesignerComp.OnSaveReport) then
    begin
      Saved := True;
      rName := CurDocName;
      DesignerComp.OnSaveReport(CurReport, rName, False, Saved);
      if Saved then
        Modified := False;
    end
    else
    begin
      CurReport.SaveToFile(CurDocName);
      Modified := False;
    end;
  end
  else
    N20Click(nil);
end;

procedure TfrDesignerForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  w: Word;
begin
  if (CurReport = nil) or
    ((csDesigning in CurReport.ComponentState) and CurReport.StoreInDFM) or
    not Modified or not FirstInstance or
    (DesignerRestrictions * [frdrDontSaveReport] <> []) or
    ((DesignerComp <> nil) and not DesignerComp.CloseQuery) then
    CanClose := True
  else
  begin
    w := Application.MessageBox(PChar(frLoadStr(SSaveChanges) + ' ' + frLoadStr(STo) + ' ' +
      ExtractFileName(CurDocName) + '?'),
      PChar(frLoadStr(SConfirm)), mb_IconQuestion + mb_YesNoCancel);
    CanClose := False;
    if w = mrNo then
    begin
      CanClose := True;
      ModalResult := mrCancel;
    end
    else if w = mrYes then
    begin
      FileBtn3Click(nil);
      CanClose := WasOk;
    end;
  end;
end;

procedure TfrDesignerForm.PageFormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := False;
end;

procedure TfrDesignerForm.PageFormResize(Sender: TObject);
begin
  Page.Left := PageForm.Left;
  Page.Top := PageForm.Top;
  Page.Width := PageForm.Width;
  Page.Height := PageForm.Height;
  Modified := True;
end;

procedure TfrDesignerForm.PageFormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Chr(Key) = 'C') and (ssCtrl in Shift) then
    Key := vk_Insert;
  if (Chr(Key) = 'X') and (ssCtrl in Shift) then
  begin
    Key := vk_Delete;
    Shift := [ssShift];
  end;
  if (Chr(Key) = 'V') and (ssCtrl in Shift) then
  begin
    Key := vk_Insert;
    Shift := [ssShift];
  end;
  if (Chr(Key) = 'A') and (ssCtrl in Shift) then
    SelAllBClick(nil);
  FormKeyDown(Sender, Key, Shift);
end;

procedure TfrDesignerForm.FileBtn4Click(Sender: TObject); // preview
var
  v: Boolean;
begin
  if CurReport is TfrCompositeReport then Exit;
  v := CurReport.ModalPreview;
  Application.ProcessMessages;
  if Application.Terminated then
    exit;
  CurReport.ModalPreview := True;
  Unselect;
  RedrawPage;
  Page := nil;
  try
    PageView.DisableDraw := True;
    InspForm.HideProperties := True;
    InspForm.ItemsChanged;
    CurReport.PrepareReport;
    if not CurReport.Terminated then
    begin
      CurReport.Preview := nil;
      CurReport.ShowPreparedReport;
    end;
  finally
    CurReport.ModalPreview := v;
    SetFocus;
    PageView.DisableDraw := False;
    InspForm.HideProperties := False;
    CurPage := CurPage;
    SelectionChanged;
    AssignDefEditors;
    if (DesignerComp <> nil) and Assigned(DesignerComp.OnShow) then
      DesignerComp.OnShow(Self);
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrDesignerForm.N42Click(Sender: TObject); // data dictionary editor
begin
  with TfrDictForm.Create(nil) do
  begin
    Doc := CurReport;
    if ShowModal = mrOk then
    begin
      if frFieldsDialog <> nil then
        frFieldsDialog.RefreshData;
      Modified := True;
    end;
    Free;
  end;
end;

procedure TfrDesignerForm.PgB3Click(Sender: TObject); // page setup
var
  w, h, p: Integer;
  frPgoptForm: TfrPgoptForm;
begin
  frPgoptForm := TfrPgoptForm.Create(nil);
  with frPgoptForm, Page do
  begin
    CB1.Checked := PrintToPrevPage;
    CB5.Checked := not UseMargins;
    CB2.Checked := UnlimitedHeight;
    if pgOr = poPortrait then
      RB1.Checked := True else
      RB2.Checked := True;
    ComB1.Items := Prn.PaperNames;
    ComB1.ItemIndex := Prn.GetSizeIndex(pgSize);
    E1.Text := ''; E2.Text := '';
    if pgSize = $100 then
    begin
      E1.Text := FloatToStrF(pgWidth / 10, ffGeneral, 4, 2);
      E2.Text := FloatToStrF(pgHeight / 10, ffGeneral, 4, 2);
    end;
    BinList.Items := Prn.BinNames;
    BinList.ItemIndex := Prn.GetBinIndex(pgBin);
    E3.Text := FloatToStrF(pgMargins.Left * 5 / 18, ffGeneral, 4, 2);
    E4.Text := FloatToStrF(pgMargins.Top * 5 / 18, ffGeneral, 4, 2);
    E5.Text := FloatToStrF(pgMargins.Right * 5 / 18, ffGeneral, 4, 2);
    E6.Text := FloatToStrF(pgMargins.Bottom * 5 / 18, ffGeneral, 4, 2);
    E7.Text := FloatToStrF(ColGap * 5 / 18, ffGeneral, 4, 2);
    Edit1.Text := IntToStr(ColCount);
    WasOk := False;
    if (ShowModal = mrOk) and (DesignerRestrictions * [frdrDontEditPage] = []) then
    begin
      Modified := True;
      WasOk := True;
      PrintToPrevPage := CB1.Checked;
      UseMargins := not CB5.Checked;
      UnlimitedHeight := CB2.Checked;
      if RB1.Checked then
        pgOr := poPortrait else
        pgOr := poLandscape;
      p := Prn.PaperSizes[ComB1.ItemIndex];
      w := 0; h := 0;
      if p = $100 then
        try
          w := Round(frStrToFloat(E1.Text) * 10);
          h := Round(frStrToFloat(E2.Text) * 10);
        except
          on exception do p := 9; // A4
        end;
      try
        pgMargins := Rect(Round(frStrToFloat(E3.Text) * 18 / 5),
                          Round(frStrToFloat(E4.Text) * 18 / 5),
                          Round(frStrToFloat(E5.Text) * 18 / 5),
                          Round(frStrToFloat(E6.Text) * 18 / 5));
        ColGap := Round(frStrToFloat(E7.Text) * 18 / 5);
      except
        on exception do
        begin
          pgMargins := Rect(0, 0, 0, 0);
          ColGap := 0;
        end;
      end;
      ColCount := StrToInt(Edit1.Text);
      pgBin := Prn.Bins[BinList.ItemIndex];
      ChangePaper(p, w, h, pgBin, pgOr);
      CurPage := CurPage; // for repaint and other
    end;
  end;
  frPgoptForm.Free;
end;

procedure TfrDesignerForm.N8Click(Sender: TObject); // report setup
var
   PassForm : TfrPasswForm;
   TmpPass : String;
begin
  with TfrDocOptForm.Create(nil) do
  begin
    CB1.Checked := not CurReport.PrintToDefault;
    CB2.Checked := CurReport.DoublePass;
    M1.Text := CurReport.ReportComment;
    E1.Text := CurReport.ReportName;
    E2.Text := CurReport.ReportAutor;
    E3.Text := CurReport.ReportVersionMajor;
    E4.Text := CurReport.ReportVersionMinor;
    E5.Text := CurReport.ReportVersionRelease;
    E6.Text := CurReport.ReportVersionBuild;
    CB3.Checked := CurReport.ReportPasswordProtected;
    LM1.Caption := DateTimeToStr(CurReport.ReportCreateDate);
    LM2.Caption := DateTimeToStr(CurReport.ReportLastChange);
    if ShowModal = mrOk then
    begin
      CurReport.PrintToDefault := not CB1.Checked;
      CurReport.DoublePass := CB2.Checked;
      CurReport.ChangePrinter(Prn.PrinterIndex, LB1.ItemIndex);
      Modified := True;
      CurReport.ReportComment := M1.Text;
      CurReport.ReportName := E1.Text;
      CurReport.ReportAutor := E2.Text;
      CurReport.ReportVersionMajor := E3.Text;
      CurReport.ReportVersionMinor := E4.Text;
      CurReport.ReportVersionRelease := E5.Text;
      CurReport.ReportVersionBuild := E6.Text;
      if (not CurReport.ReportPasswordProtected) and CB3.Checked then
      begin
        PassForm := TfrPasswForm.Create(nil);
        if PassForm.ShowModal = mrOk then
        begin
          PassForm.L1.Caption := PassForm.L2.Caption;
          TmpPass := PassForm.E1.Text;
          PassForm.E1.Text := '';
          if (PassForm.ShowModal = mrOk) and (TmpPass = PassForm.E1.Text) then
          begin
            CurReport.ReportPasswordProtected := CB3.Checked;
            CurReport.ReportPassword := PassForm.E1.Text;
          end
          else
            CB3.Checked := False;
        end
        else
        begin
          CurReport.ReportPassword := '';
          CB3.Checked := False;
          CurReport.ReportPasswordProtected := False;
        end;
        PassForm.Free;
      end;
      CurReport.ReportPasswordProtected := CB3.Checked;
      if not CurReport.ReportPasswordProtected then
         CurReport.ReportPassword := '';
    end;
    CurPage := CurPage;
    Free;
  end;
end;

procedure TfrDesignerForm.N14Click(Sender: TObject); // grid menu
var
  DesOptionsForm: TfrDesOptionsForm;
begin
  DesOptionsForm := TfrDesOptionsForm.Create(nil);
  with DesOptionsForm do
  begin
    CB1.Checked := ShowGrid;
    CB2.Checked := GridAlign;
    CB8.Checked := DisableUndo;
    CB9.Checked := SyntaxHighlight;
    case GridSizeX of
      4: RB1.Checked := True;
      8: RB2.Checked := True;
      18: RB3.Checked := True;
    end;
    CB6.Checked := ShapeMode = smAll;
    case Units of
      ruPixels: RB6.Checked := True;
      ruMM:     RB7.Checked := True;
      ruInches: RB8.Checked := True;
    end;
    CB3.Checked := not GrayedButtons;
    CB4.Checked := EditAfterInsert;
    CB5.Checked := ShowBandTitles;
    case PagePosition of
      alClient: RB9.Checked := True;
      alLeft:   RB10.Checked := True;
      alRight:  RB11.Checked := True;
    end;
    CB7.Checked := frLocale.LocalizedPropertyNames;
    if ShowModal = mrOk then
    begin
      ShowGrid := CB1.Checked;
      GridAlign := CB2.Checked;
      DisableUndo := CB8.Checked;
      if CB9.Checked<>SyntaxHighlight then
        HighlightSwitch;
      SyntaxHighlight := CB9.Checked;

      if RB1.Checked then
        GridSizeX := 4
      else if RB2.Checked then
        GridSizeX := 8
      else
        GridSizeX := 18;
      if CB6.Checked then
        ShapeMode := smAll else
        ShapeMode := smFrame;
      if RB6.Checked then
        Units := ruPixels
      else if RB7.Checked then
        Units := ruMM
      else
        Units := ruInches;
      if RB9.Checked then
        PagePosition := alClient
      else if RB10.Checked then
        PagePosition := alLeft
      else
        PagePosition := alRight;
      GrayedButtons := not CB3.Checked;
      EditAfterInsert := CB4.Checked;
      ShowBandTitles := CB5.Checked;
      frLocale.LocalizedPropertyNames := CB7.Checked;
      CurPage := CurPage;
    end;
    Free;
  end;
end;

procedure TfrDesignerForm.GB1Click(Sender: TObject);
begin
  ShowGrid := GB1.Down;
end;

procedure TfrDesignerForm.GB2Click(Sender: TObject);
begin
  GridAlign := GB2.Down;
end;

procedure TfrDesignerForm.GB3Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
begin
  AddUndoAction(acEdit);
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
    begin
      t.x := Round(t.x / GridSizeX) * GridSizeX;
      t.y := Round(t.y / GridSizeY) * GridSizeY;
      t.dx := Round(t.dx / GridSizeX) * GridSizeX;
      t.dy := Round(t.dy / GridSizeY) * GridSizeY;
      if t.dx = 0 then t.dx := GridSizeX;
      if t.dy = 0 then t.dy := GridSizeY;
    end;
  end;
  RedrawPage;
  ShowPosition;
  PageView.GetMultipleSelected;
end;

procedure TfrDesignerForm.Tab1Change(Sender: TObject);
begin
  CurPage := Tab1.TabIndex;
end;

procedure TfrDesignerForm.Popup1Popup(Sender: TObject);
var
  i: Integer;
  t, t1: TfrView;
  fl: Boolean;
begin
  DeleteMenuItems(N2.Parent);
  EnableControls;
  while Popup1.Items.Count > 7 do
    Popup1.Items.Delete(7);

  if SelNum = 1 then
  begin
    t := Objects[TopSelected];
    t.DefinePopupMenu(Popup1);
  end
  else if SelNum > 1 then
  begin
    t := Objects[TopSelected];
    fl := True;
    for i := 0 to Objects.Count - 1 do
    begin
      t1 := Objects[i];
      if t1.Selected then
        if not (((t is TfrMemoView) and (t1 is TfrMemoView)) or
           ((t.Typ <> gtAddIn) and (t.Typ = t1.Typ)) or
           ((t.Typ = gtAddIn) and (t.ClassName = t1.ClassName))) then
        begin
          fl := False;
          break;
        end;
    end;
    if fl and not (t.Typ = gtBand) then t.DefinePopupMenu(Popup1);
  end;

  FillMenuItems(N2.Parent);
  SetMenuItemBitmap(N2, CutB);
  SetMenuItemBitmap(N1, CopyB);
  SetMenuItemBitmap(N3, PstB);
  SetMenuItemBitmap(N16, SelAllB);
end;

procedure TfrDesignerForm.N37Click(Sender: TObject);
begin // toolbars
  Pan1.Checked := Panel1.IsVisible;
  Pan2.Checked := Panel2.IsVisible;
  Pan3.Checked := Panel3.IsVisible;
  Pan4.Checked := Panel4.IsVisible;
  Pan5.Checked := InspForm.Visible;
  Pan6.Checked := Panel5.IsVisible;
  Pan7.Checked := Panel6.IsVisible;
  Pan8.Checked := frFieldsDialog <> nil;
end;

procedure TfrDesignerForm.Pan2Click(Sender: TObject);
  procedure SetShow(c: Array of TWinControl; i: Integer; b: Boolean);
  begin
    if c[i] is TfrToolBar then
    with c[i] as TfrToolBar do
    begin
      if IsFloat then
        FloatWindow.Visible := b
      else
      begin
        if b then
          AddToDock(Parent as TfrDock);
        Visible := b;
        (Parent as TfrDock).AdjustBounds;
      end;
    end
    else
      (c[i] as TForm).Visible := b;
  end;
begin // each toolbar
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    if Tag = 7 then // insert fields
      ShowFieldsDialog(Checked)
    else
      SetShow([Panel1, Panel2, Panel3, Panel4, Panel5, InspForm, Panel6], Tag, Checked);
  end;
end;

procedure TfrDesignerForm.N34Click(Sender: TObject);
{var
  b: TBitmap;
  w: Integer;

  procedure EnumButtons(p: TfrToolBar);
  var
    i: Integer;
  begin
    for i := 0 to p.ControlCount - 1 do
      if p.Controls[i] is TfrTBButton then
        with TfrTBButton(p.Controls[i]) do
          if Glyph.Width <> 0 then
          begin
            DrawGlyph(b.Canvas, w, 0, True);
            Inc(w, 16);
            DrawGlyph(b.Canvas, w, 0, False);
            Inc(w, 16);
          end;
  end;}

begin // about box
{  b := TBitmap.Create;
  b.Height := 16;
  b.Width := 2600;
  with b.Canvas do
  begin
    Brush.Color := clBtnFace;
    FillRect(Rect(0, 0, 2600, 16));
  end;
  w := 0;
  EnumButtons(Panel1);
  EnumButtons(Panel2);
  EnumButtons(Panel3);
  EnumButtons(Panel4);
  EnumButtons(Panel5);
  b.Width := w;
  b.SaveToFile('c:\fr.bmp');
  b.Free;}

  with TfrAboutForm.Create(nil) do
  begin
    ShowModal;
    Free;
  end;
end;

{$IFDEF 1CScript}
procedure TfrDesignerForm.N99Click(Sender: TObject);
begin
  if SyntaxHighlight then
    EditorForm.How := True
  else
    EditorForm1.How := True;
  if SyntaxHighlight then
  begin
    if EditorForm._ShowEditor(CurReport.Script) = mrOk then
      PageView.DrawPage(dmSelection)
  end else
    if EditorForm1._ShowEditor(CurReport.Script) = mrOk then
      PageView.DrawPage(dmSelection)
  if SyntaxHighlight then
    EditorForm.How := False
  else
    EditorForm1.How := False;
  ActiveControl := nil;
end;
{$ENDIF}

{$HINTS OFF}
procedure TfrDesignerForm.InsFieldsClick(Sender: TObject);
var
  i, x, y, dx, dy, pdx, adx: Integer;
  HeaderL, DataL: TList;
  t, t1: TfrView;
  b: TfrBandView;
  f: TfrTField;
  fSize: Integer;
  fName: String;
  DSName, FieldName: String;

  function FindDataset(DataSet: TfrTDataSet): String;
  var
    i: Integer;
    function EnumComponents(f: TComponent): String;
    var
      i: Integer;
      c: TComponent;
      d: TfrDBDataSet;
    begin
      Result := '';
      for i := 0 to f.ComponentCount - 1 do
      begin
        c := f.Components[i];
        if c is TfrDBDataSet then
        begin
          d := c as TfrDBDataSet;
          if d.GetDataSet = DataSet then
          begin
            if d.Owner = CurReport.Owner then
              Result := d.Name else
              Result := d.Owner.Name + '.' + d.Name;
            break;
          end;
        end;
      end;
    end;
  begin
    Result := '';
    for i := 0 to Screen.FormCount - 1 do
    begin
      Result := EnumComponents(Screen.Forms[i]);
      if Result <> '' then Exit;
    end;
    for i := 0 to Screen.DataModuleCount - 1 do
    begin
      Result := EnumComponents(Screen.DataModules[i]);
      if Result <> '' then Exit;
    end;
  end;

begin
  if PageType = ptDialog then Exit;
  HeaderL := TList.Create;
  DataL := TList.Create;
  with TfrInsertFieldsForm.Create(nil) do
  begin
    if (ShowModal = mrOk) and (DataSet <> nil) and
      (FieldsL.Items.Count > 0) and (FieldsL.SelCount > 0) then
    begin
      DSName := DatasetCB.Items[DatasetCB.ItemIndex];
      x := Page.LeftMargin; y := Page.TopMargin;
      Unselect;
      SelNum := 0;
      for i := 0 to FieldsL.Items.Count - 1 do
        if FieldsL.Selected[i] then
        begin
          FieldName := FieldsL.Items[i];
          f := TfrTField(DataSet.FindField(CurReport.Dictionary.RealFieldName[FieldsL.Items[i]]));
          fSize := 0;
          if f <> nil then
          begin
            fSize := f.DisplayWidth;
            fName := f.DisplayName;
          end
          else
            fName := FieldName;
          if (fSize = 0) or (fSize > 255) then
            fSize := 6;

          t := frCreateObject(gtMemo, '');
          t.CreateUniqueName;
          t.x := x;
          t.y := y;
          GetDefaultSize(t.dx, t.dy);
          with t as TfrMemoView do
          begin
            Font.Name := LastFontName;
            Font.Size := LastFontSize;
            if HeaderCB.Checked then
              Font.Style := [fsBold];
          end;
          PageView.Canvas.Font.Assign(TfrMemoView(t).Font);
          t.Selected := True;
          Inc(SelNum);
          if HeaderCB.Checked then
          begin
            t.Memo.Add(fName);
            t.dx := PageView.Canvas.TextWidth(fName + '   ') div GridSizeX * GridSizeX;
          end
          else
          begin
            t.Memo.Add('[' + DSName + '."' + FieldName + '"]');
            t.dx := (fSize * PageView.Canvas.TextWidth('=')) div GridSizeX * GridSizeX;
          end;
          dx := t.dx;
          Page.Objects.Add(t);
          if HeaderCB.Checked then
            HeaderL.Add(t) else
            DataL.Add(t);
          if HeaderCB.Checked then
          begin
            t := frCreateObject(gtMemo, '');
            t.CreateUniqueName;
            t.x := x;
            t.y := y;
            GetDefaultSize(t.dx, t.dy);
            if HorzRB.Checked then
              Inc(t.y, 72) else
              Inc(t.x, dx + GridSizeX * 2);
            with t as TfrMemoView do
            begin
              Font.Name := LastFontName;
              Font.Size := LastFontSize;
            end;
            t.Selected := True;
            Inc(SelNum);
            t.Memo.Add('[' + DSName + '."' + FieldName + '"]');
            t.dx := (fSize * PageView.Canvas.TextWidth('=')) div GridSizeX * GridSizeX;
            Page.Objects.Add(t);
            DataL.Add(t);
          end;
          if HorzRB.Checked then
            Inc(x, t.dx + GridSizeX) else
            Inc(y, t.dy + GridSizeY);
        end;

      if HorzRB.Checked then
      begin
        t := DataL[DataL.Count - 1];
        adx := t.x + t.dx;
        pdx := Page.RightMargin - Page.LeftMargin;
        x := Page.LeftMargin;
        if adx > pdx then
        begin
          for i := 0 to DataL.Count - 1 do
          begin
            t := DataL[i];
            t.x := Round((t.x - x) / (adx / pdx)) + x;
            t.dx := Round(t.dx / (adx / pdx));
          end;
          if HeaderCB.Checked then
            for i := 0 to DataL.Count - 1 do
            begin
              t := HeaderL[i];
              t1 := DataL[i];
              t.x := Round((t.x - x) / (adx / pdx)) + x;
              if t.dx > t1.dx then
                t.dx := t1.dx;
            end;
        end;
      end;

      if BandCB.Checked then
      begin
        if HeaderCB.Checked then
          t := HeaderL[DataL.Count - 1] else
          t := DataL[DataL.Count - 1];
        dy := t.y + t.dy - Page.TopMargin;
        b := frCreateObject(gtBand, '') as TfrBandView;
        b.CreateUniqueName;
        b.y := Page.TopMargin;
        b.dy := dy;
        b.Selected := True;
        Inc(SelNum);
        if not HeaderCB.Checked or not HorzRB.Checked then
        begin
          Page.Objects.Add(b);
          b.BandType := btMasterData;
          b.DataSet := FindDataset(DataSet);
        end
        else
        begin
          if frCheckBand(btPageHeader) then
          begin
            Dec(SelNum);
            b.Free;
          end
          else
          begin
            b.BandType := btPageHeader;
            Page.Objects.Add(b);
          end;
          b := frCreateObject(gtBand, '') as TfrBandView;
          b.BandType := btMasterData;
          b.DataSet := FindDataset(DataSet);
          b.CreateUniqueName;
          b.y := Page.TopMargin + 72;
          b.dy := dy;
          b.Selected := True;
          Inc(SelNum);
          Page.Objects.Add(b);
        end;
      end;
      SelectionChanged;
      SendBandsToDown;
      PageView.GetMultipleSelected;
      RedrawPage;
      AddUndoAction(acInsert);
    end;
    Free;
  end;
  HeaderL.Free;
  DataL.Free;
end;
{$HINTS ON}

procedure TfrDesignerForm.Tab1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  GetCursorPos(p);
  if Button = mbRight then
    TrackPopupMenu(Popup2.Handle,
      TPM_LEFTALIGN or TPM_RIGHTBUTTON, p.X, p.Y, 0, Handle, nil)
  else
    MDown := True;
end;

procedure TfrDesignerForm.Tab1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TTabControl;
end;

procedure TfrDesignerForm.Tab1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MDown := False;
end;

procedure TfrDesignerForm.Tab1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if MDown then
    Tab1.BeginDrag(False);
end;

procedure TfrDesignerForm.Tab1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  i, HitIndex: Integer;
  HitTestInfo: TTCHitTestInfo;
begin
  HitTestInfo.pt := Point(X, Y);
  HitIndex := SendMessage(Tab1.Handle, TCM_HITTEST, 0, Longint(@HitTestInfo));

  if CurPage > HitIndex then
  begin
    NotifySubReports(CurPage, -1);
    for i := CurPage - 1 downto HitIndex do
      NotifySubReports(i, i + 1);
    NotifySubReports(-1, HitIndex);
  end
  else
  begin
    NotifySubReports(CurPage, -1);
    for i := CurPage + 1 to HitIndex do
      NotifySubReports(i, i - 1);
    NotifySubReports(-1, HitIndex);
  end;

  Tab1.Tabs.Move(CurPage, HitIndex);
  CurReport.Pages.Move(CurPage, HitIndex);
  SetPageTitles;
  ClearUndoBuffer;
  ClearRedoBuffer;
  Modified := True;
  RedrawPage;
end;

procedure TfrDesignerForm.ShowFieldsDialog(Show: Boolean);
begin
  if Show then
  begin
    if frFieldsDialog = nil then
    begin
      frFieldsDialog := TfrInsFieldsForm.Create(Self);
      frFieldsDialog.OnHeightChanged := HeightChanged;
      frFieldsDialog.Show;
    end
    else
      frFieldsDialog.Grow;
    frFieldsDialog.SetFocus;
  end
  else
  begin
    if frFieldsDialog <> nil then
    begin
      frFieldsDialog.Free;
      frFieldsDialog := nil;
    end;
  end;
end;

procedure TfrDesignerForm.HeightChanged(Sender: TObject);
var
  r1, r2: TRect;
  p: TPoint;
  Panel, Pan1, Pan2: TPanel;
  h: Integer;
begin
  if (frFieldsDialog = nil) or not InspForm.Visible then Exit;
  r1 := InspForm.BoundsRect;
  r2 := frFieldsDialog.BoundsRect;

  if ((r1.Left >= r2.Left) and (r1.Left <= r2.Right)) or
     ((r1.Right >= r2.Left) and (r1.Right <= r2.Right)) then
  begin
    Panel := TPanel.Create(Panel7);
    Panel.Parent := Panel7;
    Panel.SetBounds(2000, 0, 10, ScrollBox1.Height - 2);

    Pan1 := TPanel.Create(Panel);
    Pan1.Parent := Panel;

    Pan2 := TPanel.Create(Panel);
    Pan2.Parent := Panel;
    Pan2.SetBounds(r2.Left, r2.Top, r2.Right - r2.Left, r2.Bottom - r2.Top);

    if r1.Top < r2.Top then
      Pan2.Align := alBottom else
      Pan2.Align := alTop;
    Pan1.Align := alClient;

    p := ScrollBox1.ClientToScreen(Point(0, -1));
    if InspForm.ClientHeight < 20 then
      h := 0 else
      h := Pan1.Height;
    InspForm.SetBounds(InspForm.Left, Pan1.Top + p.Y,
      InspForm.Width, h);
    frFieldsDialog.SetBounds(frFieldsDialog.Left, Pan2.Top + p.Y,
      frFieldsDialog.Width, Pan2.Height);
    Pan1.Free;
    Pan2.Free;
    Panel.Free;
  end;
end;


{----------------------------------------------------------------------------}
// state storing/retrieving
const
  rsGridShow = 'GridShow';
  rsGridAlign = 'GridAlign';
  rsGridSize = 'GridSize';
  rsUnits = 'Units';
  rsButtons = 'GrayButtons';
  rsEdit = 'EditAfterInsert';
  rsSelection = 'Selection';
  rsPagePos = 'PagePosition';
  rsBandTitles = 'BandTitles';
  rsProps = 'LocalizedPropNames';
  rsPgHeight = 'UnlimitedHeight';
  rsPgUndo = 'DisableUndo';
  rsSyntHL =  'SyntaxHighlight';

procedure TfrDesignerForm.SaveState;
var
  Ini: TRegIniFile;
  Nm: String;

  procedure DoSaveToolbars(t: Array of TfrToolBar);
  var
    i: Integer;
  begin
    for i := Low(t) to High(t) do
    begin
      if FirstInstance or (t[i] <> Panel6) then
        SaveToolbarPosition(t[i]);
      t[i].IsVisible := False;
    end;
  end;

begin
  Ini := TRegIniFile.Create(RegRootKey);
  Nm := rsForm + ClassName;
  Ini.WriteBool(Nm, rsGridShow, ShowGrid);
  Ini.WriteBool(Nm, rsGridAlign, GridAlign);
  Ini.WriteInteger(Nm, rsGridSize, GridSizeX);
  Ini.WriteInteger(Nm, rsUnits, Word(Units));
  Ini.WriteBool(Nm, rsButtons, GrayedButtons);
  Ini.WriteBool(Nm, rsEdit, EditAfterInsert);
  Ini.WriteInteger(Nm, rsSelection, Integer(ShapeMode));
  Ini.WriteInteger(Nm, rsPagePos, Integer(PagePosition));
  Ini.WriteBool(Nm, rsBandTitles, ShowBandTitles);
  Ini.WriteBool(rsForm + InspForm.ClassName, rsVisible, InspForm.Visible);
  Ini.WriteInteger(rsForm + InspForm.ClassName, 'SplitPos', InspForm.SplitterPos);
  Ini.WriteBool(rsForm + TfrInsFieldsForm.ClassName, rsVisible,
    (frFieldsDialog <> nil) and frFieldsDialog.Visible);
  Ini.WriteBool(Nm, rsProps, frLocale.LocalizedPropertyNames);
  Ini.WriteBool(Nm, rsPgHeight, UnlimitedHeight);
  Ini.WriteBool(Nm, rsPgUndo, DisableUndo);
  Ini.WriteBool(Nm, rsSyntHL, SyntaxHighlight);

  Ini.Free;
  DoSaveToolbars([Panel1, Panel2, Panel3, Panel4, Panel5, Panel6]);
  SaveFormPosition(InspForm);
  SaveFormPosition(Self);
end;

procedure TfrDesignerForm.RestoreState;
var
  Ini: TRegIniFile;
  Nm: String;
  hl : boolean;
  procedure DoRestoreToolbars(t: Array of TfrToolBar);
  var
    i: Integer;
  begin
    for i := Low(t) to High(t) do
      RestoreToolbarPosition(t[i]);
  end;

begin
  Ini := TRegIniFile.Create(RegRootKey);
  Nm := rsForm + ClassName;
  GridSizeX := Ini.ReadInteger(Nm, rsGridSize, 4);
  if GridSizeX = 0 then
    GridSizeX := 4;
  GridAlign := Ini.ReadBool(Nm, rsGridAlign, True);
  ShowGrid := Ini.ReadBool(Nm, rsGridShow, True);
  Units := TfrReportUnits(Ini.ReadInteger(Nm, rsUnits, 0));
  GrayedButtons := Ini.ReadBool(Nm, rsButtons, False);
  EditAfterInsert := Ini.ReadBool(Nm, rsEdit, True);
  ShapeMode := TfrShapeMode(Ini.ReadInteger(Nm, rsSelection, 1));
  PagePosition := TAlign(Ini.ReadInteger(Nm, rsPagePos, 5));
  ShowBandTitles := Ini.ReadBool(Nm, rsBandTitles, True);
  frLocale.LocalizedPropertyNames := Ini.ReadBool(Nm, rsProps, False);
  UnlimitedHeight := Ini.ReadBool(Nm, rsPgHeight, False);
  DisableUndo := Ini.ReadBool(Nm, rsPgUndo, False);
  hl := Ini.ReadBool(Nm, rsSyntHL, True);
  if hl<>SyntaxHighlight then
     HighlightSwitch;
  SyntaxHighlight := hl;

  RestoreFormPosition(InspForm);
  InspForm.SplitterPos := Ini.ReadInteger(rsForm + InspForm.ClassName, 'SplitPos', 75);
  if InspForm.SplitterPos < 20 then
    InspForm.SplitterPos := 20;
  InspForm.Visible := Ini.ReadBool(rsForm + InspForm.ClassName, rsVisible, True);

  if FirstInstance then
    if Ini.ReadBool(rsForm + TfrInsFieldsForm.ClassName, rsVisible, True) then
      ShowFieldsDialog(True);
  Ini.Free;

  DoRestoreToolbars([Panel1, Panel2, Panel3, Panel4, Panel5, Panel6]);
  if Panel6.Height < 26 then
    Panel6.Height := 26;
  if Panel6.Width < 26 then
    Panel6.Width := 26;
  if Panel6.ControlCount < 2 then
    Panel6.Hide;
  frDock1.AdjustBounds;
  frDock2.AdjustBounds;
  frDock3.AdjustBounds;
  frDock4.AdjustBounds;
  RestoreFormPosition(Self);
end;


{----------------------------------------------------------------------------}
// menu bitmaps
procedure TfrDesignerForm.SetMenuBitmaps;
var
  i: Integer;
begin
  MaxItemWidth := 0; MaxShortCutWidth := 0;
  FillMenuItems(FileMenu);
  FillMenuItems(EditMenu);
  FillMenuItems(ToolMenu);
  FillMenuItems(HelpMenu);

  SetMenuItemBitmap(N23, FileBtn1);
  SetMenuItemBitmap(N19, FileBtn2);
  SetMenuItemBitmap(N20, FileBtn3);
  SetMenuItemBitmap(N39, FileBtn4);

  SetMenuItemBitmap(N46, UndoB);
  SetMenuItemBitmap(N48, RedoB);
  SetMenuItemBitmap(N11, CutB);
  SetMenuItemBitmap(N12, CopyB);
  SetMenuItemBitmap(N13, PstB);
  SetMenuItemBitmap(N28, SelAllB);
  SetMenuItemBitmap(N29, PgB1);
  SetMenuItemBitmap(N30, PgB2);
  SetMenuItemBitmap(N32, ZB1);
  SetMenuItemBitmap(N33, ZB2);
  SetMenuItemBitmap(N35, HelpBtn);
  SetMenuItemBitmap(N15, PgB4);
  for i := 0 to MastMenu.Count - 1 do
    SetMenuItemBitmap(MastMenu.Items[i], Panel6.Controls[i + 1] as TfrTBButton);

  SetMenuItemBitmap(N41, PgB1);
  SetMenuItemBitmap(N43, PgB2);
  SetMenuItemBitmap(N44, PgB3);
  SetMenuItemBitmap(N45, PgB4);
end;

function TfrDesignerForm.FindMenuItem(AMenuItem: TMenuItem): TfrMenuItemInfo;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to MenuItems.Count - 1 do
    if TfrMenuItemInfo(MenuItems[i]).MenuItem = AMenuItem then
    begin
      Result := TfrMenuItemInfo(MenuItems[i]);
      Exit;
    end;
end;

procedure TfrDesignerForm.SetMenuItemBitmap(AMenuItem: TMenuItem; ABtn: TfrSpeedButton);
var
  m: TfrMenuItemInfo;
begin
  m := FindMenuItem(AMenuItem);
  if m = nil then
  begin
    m := TfrMenuItemInfo.Create;
    m.MenuItem := AMenuItem;
    MenuItems.Add(m);
  end;
  m.Btn := ABtn;
  ModifyMenu(AMenuItem.Parent.Handle, AMenuItem.MenuIndex,
    MF_BYPOSITION + MF_OWNERDRAW, AMenuItem.Command, nil);
end;

procedure TfrDesignerForm.FillMenuItems(MenuItem: TMenuItem);
var
  i: Integer;
  m: TMenuItem;
begin
  for i := 0 to MenuItem.Count - 1 do
  begin
    m := MenuItem.Items[i];
    SetMenuItemBitmap(m, nil);
    if m.Count > 0 then FillMenuItems(m);
  end;
end;

procedure TfrDesignerForm.DeleteMenuItems(MenuItem: TMenuItem);
var
  i, j: Integer;
  m: TMenuItem;
begin
  for i := 0 to MenuItem.Count - 1 do
  begin
    m := MenuItem.Items[i];
    for j := 0 to MenuItems.Count - 1 do
    if TfrMenuItemInfo(MenuItems[j]).MenuItem = m then
    begin
      TfrMenuItemInfo(MenuItems[j]).Free;
      MenuItems.Delete(j);
      break;
    end;
  end;
end;

procedure TfrDesignerForm.DoDrawText(Canvas: TCanvas; Caption: string;
  Rect: TRect; Selected, Enabled: Boolean; Flags: Longint);
begin
  with Canvas do
  begin
    Brush.Style := bsClear;
    if not Enabled then
    begin
      if not Selected then
      begin
        OffsetRect(Rect, 1, 1);
        Font.Color := clBtnHighlight;
        DrawText(Handle, PChar(Caption), Length(Caption), Rect, Flags);
        OffsetRect(Rect, -1, -1);
      end;
      Font.Color := clBtnShadow;
    end;
    DrawText(Handle, PChar(Caption), Length(Caption), Rect, Flags);
  end;
end;

procedure TfrDesignerForm.DrawItem(AMenuItem: TMenuItem; ACanvas: TCanvas;
  ARect: TRect; Selected: Boolean);
var
  GlyphRect: TRect;
  Btn: TfrSpeedButton;
  Glyph: TBitmap;
begin
  MaxItemWidth := 0;
  MaxShortCutWidth := 0;
  with ACanvas do
  begin
    if Selected then
    begin
      Brush.Color := clHighlight;
      Font.Color := clHighlightText
    end
    else
    begin
      Brush.Color := clMenu;
      Font.Color := clMenuText;
    end;
    if AMenuItem.Caption <> '-' then
    begin
      FillRect(ARect);
      Btn := FindMenuItem(AMenuItem).Btn;
      GlyphRect := Bounds(ARect.Left + 1, ARect.Top + (ARect.Bottom - ARect.Top - 16) div 2, 16, 16);

      if AMenuItem.Checked then
      begin
        Glyph := TBitmap.Create;
        if AMenuItem.RadioItem then
        begin
          Glyph.Handle := LoadBitmap(hInstance, 'FR_RADIO');
          BrushCopy(GlyphRect, Glyph, Rect(0, 0, 16, 16), Glyph.TransparentColor);
        end
        else
        begin
          Glyph.Handle := LoadBitmap(hInstance, 'FR_CHECK');
          Draw(GlyphRect.Left, GlyphRect.Top, Glyph);
        end;
        Glyph.Free;
      end
      else if Btn <> nil then
      begin
        Glyph := TBitmap.Create;
        Glyph.Width := 16; Glyph.Height := 16;
        Btn.DrawGlyph(Glyph.Canvas, 0, 0, AMenuItem.Enabled);
        BrushCopy(GlyphRect, Glyph, Rect(0, 0, 16, 16), Glyph.TransparentColor);
        Glyph.Free;
      end;
      ARect.Left := GlyphRect.Right + 4;
    end;

    if AMenuItem.Caption <> '-' then
    begin
      OffsetRect(ARect, 0, 2);
      DoDrawText(ACanvas, AMenuItem.Caption, ARect, Selected, AMenuItem.Enabled, DT_LEFT);
      if AMenuItem.ShortCut <> 0 then
      begin
        ARect.Left := StrToInt(ItemWidths.Values[AMenuItem.Parent.Name]) + 6;
        DoDrawText(ACanvas, ShortCutToText(AMenuItem.ShortCut), ARect,
          Selected, AMenuItem.Enabled, DT_LEFT);
      end;
    end
    else
    begin
      Inc(ARect.Top, 4);
      DrawEdge(Handle, ARect, EDGE_ETCHED, BF_TOP);
    end;
  end;
end;

procedure TfrDesignerForm.MeasureItem(AMenuItem: TMenuItem; ACanvas: TCanvas;
  var AWidth, AHeight: Integer);
var
  w: Integer;
begin
  w := ACanvas.TextWidth(AMenuItem.Caption) + 31;
  if MaxItemWidth < w then
    MaxItemWidth := w;
  ItemWidths.Values[AMenuItem.Parent.Name] := IntToStr(MaxItemWidth);

  if AMenuItem.ShortCut <> 0 then
  begin
    w := ACanvas.TextWidth(ShortCutToText(AMenuItem.ShortCut)) + 15;
    if MaxShortCutWidth < w then
      MaxShortCutWidth := w;
  end;

  if frGetWindowsVersion = '98' then
    AWidth := MaxItemWidth else
    AWidth := MaxItemWidth + MaxShortCutWidth;
  if AMenuItem.Caption <> '-' then
    AHeight := 19 else
    AHeight := 10;
end;

procedure TfrDesignerForm.WndProc(var Message: TMessage);
var
  MenuItem: TMenuItem;
  CCanvas: TCanvas;

  function FindItem(ItemId: Integer): TMenuItem;
  begin
    Result := MainMenu1.FindItem(ItemID, fkCommand);
    if Result = nil then
      Result := Popup1.FindItem(ItemID, fkCommand);
    if Result = nil then
      Result := Popup2.FindItem(ItemID, fkCommand);
  end;

begin
  case Message.Msg of
    WM_COMMAND:
      if Popup1.DispatchCommand(Message.wParam) or
         Popup2.DispatchCommand(Message.wParam) then Exit;
    WM_INITMENUPOPUP:
      with TWMInitMenuPopup(Message) do
        if Popup1.DispatchPopup(MenuPopup) or
           Popup2.DispatchPopup(MenuPopup) then Exit;
    WM_DRAWITEM:
      with PDrawItemStruct(Message.LParam)^ do
      begin
        if (CtlType = ODT_MENU) and (Message.WParam = 0) then
        begin
          MenuItem := FindItem(ItemId);
          if MenuItem <> nil then
          begin
            CCanvas := TControlCanvas.Create;
            with CCanvas do
            begin
              Handle := hDC;
              DrawItem(MenuItem, CCanvas, rcItem, ItemState and ODS_SELECTED <> 0);
              Free;
            end;
            Exit;
          end;
        end;
      end;
    WM_MEASUREITEM:
      with PMeasureItemStruct(Message.LParam)^ do
      begin
        if (CtlType = ODT_MENU) and (Message.WParam = 0) then
        begin
          MenuItem := FindItem(ItemId);
          if MenuItem <> nil then
          begin
            MeasureItem(MenuItem, Canvas, Integer(ItemWidth), Integer(ItemHeight));
            Exit;
          end;
        end;
      end;
  end;
  inherited WndProc(Message);
end;


{----------------------------------------------------------------------------}
// alignment palette
function GetFirstSelected: TfrView;
begin
  if FirstSelected <> nil then
    Result := FirstSelected else
    Result := Objects[TopSelected];
end;

function GetLeftObject: Integer;
var
  i: Integer;
  t: TfrView;
  x: Integer;
begin
  t := Objects[TopSelected];
  x := t.x;
  Result := TopSelected;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
      if t.x < x then
      begin
        x := t.x;
        Result := i;
      end;
  end;
end;

function GetRightObject: Integer;
var
  i: Integer;
  t: TfrView;
  x: Integer;
begin
  t := Objects[TopSelected];
  x := t.x + t.dx;
  Result := TopSelected;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
      if t.x + t.dx > x then
      begin
        x := t.x + t.dx;
        Result := i;
      end;
  end;
end;

function GetTopObject: Integer;
var
  i: Integer;
  t: TfrView;
  y: Integer;
begin
  t := Objects[TopSelected];
  y := t.y;
  Result := TopSelected;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
      if t.y < y then
      begin
        y := t.y;
        Result := i;
      end;
  end;
end;

function GetBottomObject: Integer;
var
  i: Integer;
  t: TfrView;
  y: Integer;
begin
  t := Objects[TopSelected];
  y := t.y + t.dy;
  Result := TopSelected;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then
      if t.y + t.dy > y then
      begin
        y := t.y + t.dy;
        Result := i;
      end;
  end;
end;

procedure TfrDesignerForm.Align1Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
  x: Integer;
  band: TfrView;
  s: TStringList;
  y: Integer;
begin
  if DesignerRestrictions * [frdrDontMoveObj] <> [] then Exit;
  if IsBandsSelect(band) then
  begin
    BeforeChange;
    s := TStringList.Create;
    s.Sorted := True;
    s.Duplicates := dupAccept;
    t := Objects[GetLeftObject];
    x := Page.LeftMargin;
    y := t.y;
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if (t.y >= band.y) and (t.y + t.dy <= band.y + band.dy) and
         (t.Typ <> gtBand) then
        s.AddObject(Format('%4.4d', [t.x]), t);
    end;
    for i := 0 to s.Count - 1 do
    begin
      t := TfrView(s.Objects[i]);
      if (t.Restrictions and frrfDontMove) = 0 then
      begin
        t.x := x;
        t.y := y;
      end;
      x := x + t.dx;
    end;
    s.Free;
    PageView.GetMultipleSelected;
    RedrawPage;
    Exit;
  end;

  if SelNum < 2 then Exit;
  BeforeChange;
  t := GetFirstSelected;
  x := t.x;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      t.x := x;
  end;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;

procedure TfrDesignerForm.Align6Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
  y: Integer;
begin
  if (SelNum < 2) or (DesignerRestrictions * [frdrDontMoveObj] <> []) then Exit;
  BeforeChange;
  t := GetFirstSelected;
  y := t.y;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      t.y := y;
  end;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;

procedure TfrDesignerForm.Align5Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
  x: Integer;
  band: TfrView;
  s: TStringList;
  y: Integer;
begin
  if DesignerRestrictions * [frdrDontMoveObj] <> [] then Exit;
  if IsBandsSelect(band) then
  begin
    BeforeChange;
    s := TStringList.Create;
    s.Sorted := True;
    s.Duplicates := dupAccept;
    t := Objects[GetRightObject];
    x := Page.RightMargin;
    y := t.y;
    for i := 0 to Objects.Count - 1 do
    begin
      t := Objects[i];
      if (t.y >= band.y) and (t.y + t.dy <= band.y + band.dy) and
         (t.Typ <> gtBand) then
        s.AddObject(Format('%4.4d', [t.x]), t);
    end;
    for i := s.Count - 1 downto 0 do
    begin
      t := TfrView(s.Objects[i]);
      if (t.Restrictions and frrfDontMove) = 0 then
      begin
        t.x := x - t.dx;
        t.y := y;
      end;
      x := x - t.dx;
    end;
    s.Free;
    PageView.GetMultipleSelected;
    RedrawPage;
    Exit;
  end;

  if SelNum < 2 then Exit;
  BeforeChange;
  t := GetFirstSelected;
  x := t.x + t.dx;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      t.x := x - t.dx;
  end;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;

procedure TfrDesignerForm.Align10Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
  y: Integer;
begin
  if (SelNum < 2) or (DesignerRestrictions * [frdrDontMoveObj] <> []) then Exit;
  BeforeChange;
  t := GetFirstSelected;
  y := t.y + t.dy;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      t.y := y - t.dy;
  end;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;

procedure TfrDesignerForm.Align2Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
  x: Integer;
begin
  if (SelNum < 2) or (DesignerRestrictions * [frdrDontMoveObj] <> []) then Exit;
  BeforeChange;
  t := GetFirstSelected;
  x := t.x + t.dx div 2;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      t.x := x - t.dx div 2;
  end;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;

procedure TfrDesignerForm.Align7Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
  y: Integer;
begin
  if (SelNum < 2) or (DesignerRestrictions * [frdrDontMoveObj] <> []) then Exit;
  BeforeChange;
  t := GetFirstSelected;
  y := t.y + t.dy div 2;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      t.y := y - t.dy div 2;
  end;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;

procedure TfrDesignerForm.Align3Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
  x: Integer;
begin
  if (SelNum = 0) or (DesignerRestrictions * [frdrDontMoveObj] <> []) then Exit;
  BeforeChange;
  t := Objects[GetLeftObject];
  x := t.x;
  t := Objects[GetRightObject];
  x := x + (t.x + t.dx - x - PageView.Width) div 2;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      Dec(t.x, x);
  end;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;

procedure TfrDesignerForm.Align8Click(Sender: TObject);
var
  i: Integer;
  t: TfrView;
  y: Integer;
begin
  if (SelNum = 0) or (DesignerRestrictions * [frdrDontMoveObj] <> []) then Exit;
  BeforeChange;
  t := Objects[GetTopObject];
  y := t.y;
  t := Objects[GetBottomObject];
  y := y + (t.y + t.dy - y - PageView.Height) div 2;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      Dec(t.y, y);
  end;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;

procedure TfrDesignerForm.Align4Click(Sender: TObject);
var
  s: TStringList;
  i, dx: Integer;
  t: TfrView;
begin
  if (SelNum < 3) or (DesignerRestrictions * [frdrDontMoveObj] <> []) then Exit;
  BeforeChange;
  s := TStringList.Create;
  s.Sorted := True;
  s.Duplicates := dupAccept;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then s.AddObject(Format('%4.4d', [t.x]), t);
  end;
  dx := (TfrView(s.Objects[s.Count - 1]).x - TfrView(s.Objects[0]).x) div (s.Count - 1);
  for i := 1 to s.Count - 2 do
  begin
    t := TfrView(s.Objects[i]);
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      t.x := TfrView(s.Objects[i - 1]).x + dx;
  end;
  s.Free;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;

procedure TfrDesignerForm.Align9Click(Sender: TObject);
var
  s: TStringList;
  i, dy: Integer;
  t: TfrView;
begin
  if (SelNum < 3) or (DesignerRestrictions * [frdrDontMoveObj] <> []) then Exit;
  BeforeChange;
  s := TStringList.Create;
  s.Sorted := True;
  s.Duplicates := dupAccept;
  for i := 0 to Objects.Count - 1 do
  begin
    t := Objects[i];
    if t.Selected then s.AddObject(Format('%4.4d', [t.y]), t);
  end;
  dy := (TfrView(s.Objects[s.Count - 1]).y - TfrView(s.Objects[0]).y) div (s.Count - 1);
  for i := 1 to s.Count - 2 do
  begin
    t := TfrView(s.Objects[i]);
    if t.Selected and ((t.Restrictions and frrfDontMove) = 0) then
      t.y := TfrView(s.Objects[i - 1]).y + dy;
  end;
  s.Free;
  PageView.GetMultipleSelected;
  FillInspFields;
  InspForm.ItemsChanged;
  RedrawPage;
end;


procedure TfrDesignerForm.GetDefaultSize(var dx, dy: Integer);
begin
  dx := 96;
  if GridSizeX = 18 then dx := 18 * 6;
  dy := 20;
  if GridSizeY = 18 then dy := 18;
  if LastFontSize in [12, 13] then dy := 20;
  if LastFontSize in [14..16] then dy := 24;
end;


type
  THackBtn = class(TfrSpeedButton)
  end;

procedure TfrDesignerForm.HelpBtnClick(Sender: TObject);
begin
  HelpBtn.Down := True;
  Screen.Cursor := crHelp;
  SetCapture(Handle);
  THackBtn(HelpBtn).FMouseInControl := False;
  HelpBtn.Invalidate;
end;

procedure TfrDesignerForm.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  c: TControl;
  t: Integer;
begin
  HelpBtn.Down := False;
  Screen.Cursor := crDefault;
  c := frControlAtPos(Self, Point(X, Y));
  if (c <> nil) and (c <> HelpBtn) then
  begin
    t := c.Tag;
    if (c.Parent = Panel4) and (t > 4) then
      t := 5;
    if c.Parent = Panel4 then
      Inc(t, 430) else
      Inc(t, 400);
    Application.HelpCommand(HELP_CONTEXTPOPUP, t);
  end;
end;

procedure TfrDesignerForm.N22Click(Sender: TObject);
begin
  Application.HelpCommand(HELP_FINDER, 0);
end;

{$IFDEF Delphi4}
procedure TfrDesignerForm.FormMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position - 8;
end;

procedure TfrDesignerForm.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  ScrollBox1.VertScrollBar.Position := ScrollBox1.VertScrollBar.Position + 8;
end;
{$ENDIF}


procedure TfrDesignerForm.StatusBar1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ChangeUnits := X < 75;
end;

procedure TfrDesignerForm.StatusBar1DblClick(Sender: TObject);
begin
  if ChangeUnits then
    if Units = ruInches then
      Units := ruPixels else
      Units := Succ(Units)
end;

procedure TfrDesignerForm.C2DblClick(Sender: TObject);
begin
  frFontEditor(nil);
end;

{$HINTS OFF}
procedure DoInit;
begin
  frDesignerClass := TfrDesignerForm;
  ClipBd := TList.Create;
  GridBitmap := TBitmap.Create;
  with GridBitmap do
  begin
    Width := 8; Height := 8;
  end;
  LastFrameTyp := 0;
  LastFrameWidth := 1;
  LastLineWidth := 2;
  LastFillColor := clNone;
  LastFrameColor := clBlack;
  LastFontColor := clBlack;
  LastFontStyle := 0;
  LastAlignment := 0;
  LastCharset := frCharset;
  RegRootKey := 'Software\FastReport\' + Application.Title;
end;
{$HINTS ON}

initialization
  DoInit;

finalization
  ClearClipBoard;
  ClipBd.Free;
  GridBitmap.Free;

end.

