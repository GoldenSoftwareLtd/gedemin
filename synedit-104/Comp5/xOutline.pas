{$DEFINE xTool}

{*******************************************************}
{                                                       }
{       xTool - Component Collection                    }
{                                                       }
{       Copyright (c) 1995 Stefan Bother                }
{                                                       }
{*******************************************************}

{++

  Copyright (c) 1995 by Golden Software

  Module name

    xoutline.pas

  Abstract

    Delphi visual component. Extended outline control
    and outline combo box.

  Author

    Michael Shoihet (17-Nov-95)

  Contact address

    goldsoft%swatogor.belpak.minsk.by@demos.su

  Revisions history

    1.00    28-Nov-95    michael    Initial version.
    2.00    31-Jan-95    michael    Add inplace editor for edit line

--}

unit xOutLine;

interface

{*$R xoutline.res*}

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, Dialogs, Grids, ExList, Menus, Buttons, ExtCtrls,
  xInplace;

const
  MaxLevel = 79;

type
  TStateOutlineItem = (oiOpenItem, oiCloseItem, oiNoneItem);
  TTreeState = (tsLine, tsEndLine, tsMidleLine, tsNone);

  TxOutlineOption = (xoTreePictureText, xoTreeText, xoPictureText,
    xoText, xoPlusMinusTreePictureText, xoPlusMinusTreeText);

  TOnGetBitmap = function( Sender: TObject; Index: Integer ): TBitmap of Object;

const
  DefOptions = (xoPlusMinusTreePictureText);
  DefOutlineColor = clWindow;
  DefaultSelectColor = clNavy;
  DefItemIndex = 0;
  DefIndent = 16;
  DefIndentCombo = 6;
  DefSquareSize = 9;
  DefRowHeight = 16;
  DefOutlineHeight = 48;
  DefDistBitmapText = 1;

type

  ExOutlineError = class(Exception);


  TxOutlineItem = class
  public
    Level: Integer;
    NumberBitmap: Integer;
    StateItem: TStateOutlineItem;
    NameItem: PString;

    TreeStates: array[0..MaxLevel] of TTreeState;

    constructor Create(S: String);
    destructor Destroy; override;
    function NewState: Boolean;
    procedure NewItem(AItem: String);
    function GetItemWidth(Canvas: TCanvas): Integer;
  end;

  TxOutlineList = class(TExList)

  public
    function CalcViewItem: Integer;
    function GetViewItem(Row: Integer): Pointer;
    function SearchKey(OldIndex: Integer; Key: Char): Integer;
    function GetRow(NumItem: Integer): Integer;
    procedure MakeTreeState;
    function GetPath(Index: Integer): String;

  end;

  TxCustomOutline = class(TCustomGrid)
  private

    FLines: TStringList;
    FItemIndex: Integer;
    FSelectColor: TColor;
    FFontSize: Integer;
    FRowHeight: Integer;
    FCustomBitmap: TBitmap;
    FOnGetBitmap: TOnGetBitmap;
    FOnChange: TNotifyEvent;
    FIndent: Integer;
    FSquareSize: Integer;
    FItemHeight: Integer;
    FEmptyBitmap: Boolean;
    FDistBitmapText: Integer;
    FStretchBitmap: Boolean;
    FEditOutline: Boolean;
    FNotebook: TNotebook;
    FItemText: String;

    FOnGetEditText: TGetEditEvent;
    FOnSetEditText: TSetEditEvent;

    FxOutlineOption: TxOutlineOption;

    OutlineItem: TxOutlineList;
    OldPenChange: TNotifyEvent;
    OldItemIndex: Integer;
    ChangePen: Boolean;
    isChooseSquare: Boolean;

    procedure SetLines(ALines: TStringList);
    procedure SetItemHeight;
    procedure SetCellWidth;
    procedure MakeList;
    procedure SetSelectColor(AColor: TColor);
    function GetPen: TPen;
    procedure SetPen(aPen: TPen);
    function GetItemIndex: Integer;
    procedure SetItemIndex(aNewIndex: Integer);
    procedure SetIndent(aValue: Integer);
    procedure SetSquareSize(aValue: Integer);
    procedure SetNewRowHeight(aValue: Integer);
    procedure SetDistBitmapText(aValue: Integer);
    procedure SetStretchBitmap(aValue: Boolean);
    procedure SetEditOutline(aValue: Boolean);
    function ReadItemText: String;
    procedure SetItemText(aValue: String);

    procedure SetCustomBitmap(ABitmap: TBitmap);
    procedure SetxOutlineOption(AOption: TxOutlineOption);
    procedure StyleChanged(Sender: TObject);
    procedure LinesChanged(Sender: TObject);

    procedure WriteEmptyBitmap(Writer: TWriter);
    procedure ReadEmptyBitmap(Reader: TReader);

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LButtonDown;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MouseMove;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LButtonUp;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk);
      message WM_LBUTTONDBLCLK;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp);
      message WM_KEYUP;
    procedure WMChar(var Message: TWMChar);
      message WM_CHAR;
    procedure CMFontChanged(var Message: TMessage);
      message CM_FONTCHANGED;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
      message WM_ERASEBKGND;
    procedure WMVScroll(var Message: TWMVScroll);
      message WM_VSCROLL;
    procedure wmGetInplaceCoord(var Message: TMessage);
      message WM_GETINPLACECOORD;

  protected
    FSizeSquare: Word;
    isAlwaysOpen: Boolean;
    isRedrawGrid: Boolean;
    isDeleteSpace: Boolean;
    CountBitmap: Integer;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
          AState: TGridDrawState); override;
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure Paint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Change(Sender: TObject);

    procedure SetSizeBitmap; virtual;
    procedure RebuildOutline;
    function GetEditText(ACol, ARow: Longint): string; override;
    procedure SetEditText(ACol, ARow: Longint; const Value: string); override;
    function CreateEditor: TInplaceEdit; override;
    function isEditState: Boolean;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;

  public

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SwitchState(NumItem: Integer);

    function GetItemBitmap(aCanvas: TCanvas; Index: Integer): TBitmap;
    function GetItemText(Index: Integer): String;
    function GetItemHeight: Integer;

    function GetPath(Index: Integer): String;
    function GetCurrentPath: String;
    function GetState(Index: Integer): TStateOutlineItem;

    function GetIndexByPath(Path: String): Integer;
    function GetIndexByText(Text: String): Integer;
    function GetNumberLevel: Integer;

    procedure ChangeAllState(isOpen: Boolean);

    property Lines: TStringList read FLines write SetLines;
    property SelectColor: TColor read FSelectColor write SetSelectColor
      default DefaultSelectColor;
    property CustomBitmap: TBitmap read FCustomBitmap write SetCustomBitmap;
    property Options: TxOutlineOption read FxOutlineOption
      write SetxOutlineOption default DefOptions;
    property Pen: TPen read GetPen write SetPen;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex
      default DefItemIndex;
    property Indent: Integer read FIndent write SetIndent
      default DefIndent;
    property SquareSize: Integer read FSquareSize write SetSquareSize
      default DefSquareSize;
    property RowHeight: Integer read FRowHeight write SetNewRowHeight
      default DefRowHeight;
    property DistBitmapText: Integer read FDistBitmapText write SetDistBitmapText
      default DefDistBitmapText;
    property StretchBitmap: Boolean read FStretchBitmap write SetStretchBitmap
      default false;
    property EditOutline: Boolean read FEditOutline write SetEditOutline
      default True;
    property Notebook: TNotebook read FNotebook write FNotebook;
    property ItemText: String read ReadItemText write SetItemText;


    property OnGetEditText: TGetEditEvent read FOnGetEditText
      write FOnGetEditText;
    property OnSetEditText: TSetEditEvent read FOnSetEditText
      write FOnSetEditText;
    property OnGetBitmap: TOnGetBitmap read FOnGetBitmap write FOnGetBitmap;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

  end;

  TxOutline = class(TxCustomOutline)
  published
    property Lines;
    property SelectColor;
    property CustomBitmap;
    property Options;
    property Pen;
    property ItemIndex;
    property RowHeight;

    property Color;
    property Font;
    property Width;
    property Height;
    property ScrollBars;
    property Align;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property Indent;
    property SquareSize;
    property DistBitmapText;
    property StretchBitmap;
    property EditOutline;
    property BorderStyle;
    property Notebook;
    property ItemText;

    property OnChange;
    property OnGetEditText;
    property OnSetEditText;
    property OnGetBitmap;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

const
  DefWidth = 121;
  DefHeight = 21;

type
  TxOutlineWindow = class(TxCustomOutline)
  private
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMActivate(var Message: TWMActivate);
      message WM_ACTIVATE;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;

  protected
    procedure SetSizeBitmap; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;

  end;

  TxOutlineCombo = class(TCustomControl)
  private
    FLines: TStringList;
    FColor: TColor;
    FDown: Boolean;
    FOutlineShow: Boolean;
    FOutlineColor: TColor;
    FCustomBitmap: TBitmap;
    FItemIndex: Integer;
    FEmptyBitmap: Boolean;

    FOnChange: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnGetBitmap: TOnGetBitmap;

    FComboHeight: Integer;
    FOutlineHeight: Integer;

    KeyPressed: Boolean;
    isFirst: Boolean;
    isFocus: Boolean;
    OldShowHint: Boolean;

    procedure SetLines(aLines: TStringList);
    procedure SetColor(aColor: TColor);
    procedure SetOutlineColor(aColor: TColor);
    procedure SetDown(aDown: Boolean);
    procedure SetOutlineShow(aShow: Boolean);
    procedure SetOutlineHeight(aNewHeight: Integer);
    procedure SetCustomBitmap(aBitmap: TBitmap);
    procedure SetItemIndex(aIndex: Integer);
    procedure SetIndent(aValue: Integer);
    function GetIndent: Integer;
    procedure SetRowHeight(aValue: Integer);
    function GetRowHeight: Integer;
    procedure SetDistBitmapText(aValue: Integer);
    function GetDistBitmapText: Integer;
    procedure SetStretchBitmap(aValue: Boolean);
    function GetStretchBitmap: Boolean;

    procedure WriteEmptyBitmap(Writer: TWriter);
    procedure ReadEmptyBitmap(Reader: TReader);
    procedure WriteComboHeight(Writer: TWriter);
    procedure ReadComboHeight(Reader: TReader);

    procedure MoveOutlineWindow;
    procedure DrawButton;
    procedure DrawLine;

    procedure MakeOutline;

    procedure WMLButtonDown(var Message: TWMLButtonDown);
      message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp);
      message WM_LBUTTONUP;
    procedure WMMouseMove(var Message: TWMMouseMove);
      message WM_MOUSEMOVE;
    procedure WMSize(var Message: TWMSize);
      message WM_SIZE;
    procedure CMFontChanged(var Message: TMessage);
      message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage);
      message CM_ENABLEDCHANGED;
    procedure CMFocusChanged(var Message: TCMFocusChanged);
      message CM_FOCUSCHANGED;
    procedure WMKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode);
      message WM_GETDLGCODE;


    property Down: Boolean read FDown write SetDown;

  protected
    FOutlineWindow: TxCustomOutline;

    procedure Change; dynamic;
    procedure Paint; override;
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadState(Reader: TReader); override;
    function CreateOutline: TxCustomOutline; virtual;

  public
    isSetFocus: Boolean;
    OldIndex: Integer;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function GetItemText(Index: Integer): String;
    function GetPath(Index: Integer): String;
    function CurrentPath: String;

  published
    property Lines: TStringList read FLines write SetLines;
    property Color: TColor read FColor write SetColor
      default DefOutlineColor;
    property OutlineShow: Boolean read FOutlineShow write SetOutlineShow
      default false;
    property OutlineColor: TColor read FOutlineColor write SetOutlineColor
      default DefOutlineColor;
    property OutlineHeight: Integer read FOutlineHeight write SetOutlineHeight
      default DefOutlineHeight;
    property CustomBitmap: TBitmap read FCustomBitmap write SetCustomBitmap;
    property ItemIndex: Integer read FItemIndex write SetItemIndex
      default DefItemIndex;
    property RowHeight: Integer read GetRowHeight write SetRowHeight
      default DefRowHeight;
    property Indent: Integer read GetIndent write SetIndent
      default DefIndent;
    property DistBitmapText: Integer read GetDistBitmapText
      write SetDistBitmapText default DefDistBitmapText;
    property StretchBitmap: Boolean read GetStretchBitmap write SetStretchBitmap
      default false;

    property OnGetBitmap: TOnGetBitmap read FOnGetBitmap write FOnGetBitmap;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property Width default DefWidth;
    property Height default DefHeight;

    property Font;

    property Visible;
    property Enabled;
    property ShowHint;
    property ParentShowHint;
    property DragCursor;
    property TabStop;
    property TabOrder;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

const
  ButtonWidth = 18;

{ DrawVertDottedLine draws vertical column of the dotts with given      }
{ color and Indent between them.                                      }
procedure DrawVertDottedLine(Canvas: TCanvas; X, Y, Length, Indent: Integer);
var
  I: Integer;
begin
  Inc(Indent);

  if (Y > 0) and (Canvas.Pixels[X, Y - 1] = Canvas.Pen.Color) then begin
    Inc(Y);
    Dec(Length);
  end;

  for I := 0 to (Length div Indent) - 1 do
    Canvas.Pixels[X, Y + I * Indent]:= Canvas.Pen.Color;

end;

{ DrawHorzDottedLine draws horizontal line of the dotts with given      }
{ color and Indent between them.                                      }
procedure DrawHorzDottedLine(Canvas: TCanvas; X, Y, Length, Indent: Integer);
var
  I: Integer;
begin

  Inc(Indent);
  if (X > 0) and (Canvas.Pixels[X - 1, Y] = Canvas.Pen.Color) then begin
    Inc(X);
    Dec(Length);
  end;

  for I := 0 to (Length div Indent) - 1 do
    Canvas.Pixels[X + I * Indent, Y]:= Canvas.Pen.Color;

  if Canvas.Pixels[X + Length - 1, Y] <> Canvas.Pen.Color then
    Canvas.Pixels[X + Length - 1, Y]:= Canvas.Pen.Color;
end;


{ TExOtlineItem --------------------------------------------- }

constructor TxOutlineItem.Create(S: String);
var
  PerS: String;
  i: Integer;
begin
  if Pos('/', S) = 0 then
    raise ExOutlineError.Create('Invalid line:' + S);

  Level:= Pos('/', S) - 1;
  S:= copy(S, Pos('/', S) + 1, Length(S));

  if Pos('/', S) = 0 then
    raise ExOutlineError.Create('Invalid line:' + S);

  PerS:= copy(S, 1, Pos('/', S)-1);
  val(PerS, NumberBitmap, i);

  if Pos('/', S) = 0 then
    raise ExOutlineError.Create('Invalid line:' + S);

  S:= copy(S, Pos('/', S)+1, Length(S));
  case S[1] of
  '+': StateItem:= oiOpenItem;
  '-': StateItem:= oiCloseItem;
  '*': StateItem:= oiNoneItem;
  end;

  if Pos('/', S) = 0 then
    raise ExOutlineError.Create('Invalid line:' + S);

  S:= copy(S, Pos('/', S)+1, Length(S));
  AssignStr(NameItem, S);

end;

destructor TxOutlineItem.Destroy;
begin
  DisposeStr(NameItem);
  inherited Destroy;
end;

function TxOutlineItem.NewState: Boolean;
begin
   Result:= true;
   case StateItem of
   oiCloseItem: StateItem:= oiOpenItem;
   oiOpenItem: StateItem:= oiCloseItem;
   oiNoneItem: Result:= false;
  end;
end;

procedure TxOutlineItem.NewItem(AItem: String);
begin
  DisposeStr(NameItem);
  AssignStr(NameItem, AItem);
end;

function TxOutlineItem.GetItemWidth(Canvas: TCanvas): Integer;
begin

  Result:= 0;
  if NameItem <> nil then
    Result:= Canvas.TextWidth(NameItem^);

end;

{ TxOutlineList -------------------------------------------- }

procedure TxOutlineList.MakeTreeState;
var
////  PerArray: array[0..MaxLevel] of TTreeState;
  i, j: Integer;

function SearchLevel(ALevel, Num: Integer): Boolean;
var
  k: Integer;
begin

  Result:= false;

  for k:= Num + 1 to Count - 1 do
    with TxOutlineItem(Items[k]) do begin
      Result:= ALevel = Level;
      if Result or (ALevel > Level) then Break;
    end;

end;

begin

  for i:= 0 to Count - 1 do

    with TxOutlineItem(Items[i]) do begin

      for j:= 0 to Level - 1 do
        if SearchLevel(j, i) then
          TreeStates[j]:= tsLine
        else
          TreeStates[j]:= tsNone;

      if (i = Count - 1) or (Level > TxOutlineItem(Items[i + 1]).Level) or
         not SearchLevel(Level, i)
      then
        TreeStates[Level]:= tsEndLine
      else
        TreeStates[Level]:= tsMidleLine;

    end;

end;

function TxOutlineList.CalcViewItem: Integer;
var
  i: Integer;
  isOpen: Boolean;
  OldLevel: Integer;
begin

  isOpen:= true;
  Result:= 0;
  OldLevel:= 0;

  for i:= 0 to Count - 1 do
    with TxOutlineItem(Items[i]) do
      if (Level <= OldLevel) or isOpen then begin
        Inc(Result);
        isOpen:=  StateItem = oiOpenItem;
        OldLevel:= Level;
      end;
end;

function TxOutlineList.GetPath(Index: Integer): String;
var
  i: Integer;
  OldLevel: Integer;
begin
  Result:= '';
  OldLevel:= -1;

  if Index > Count then exit;

  for i:= Index downto 0 do
    with TxOutlineItem(Items[i]) do begin
      if OldLevel <> Level then
        Result:= NameItem^ + Result;
      if Level = 0 then exit;
      if OldLevel <> Level then
        Result:= '\' + Result;
      OldLevel:= Level;
    end;

end;


function TxOutlineList.GetViewItem(Row: Integer): Pointer;
var
  i, Num: Integer;
  isOpen: Boolean;
  OldLevel: Integer;
begin
{{*}  isOpen := False;
  Result:= nil;
  OldLevel:= 0;

  Num:= 0;

  for i:= 0 to Count - 1 do
    with TxOutlineItem(Items[i]) do
      if (Level <= OldLevel) or isOpen then begin
        if Num = Row then begin
          Result:= Items[i];
          Break;
        end;
        Inc(Num);
        isOpen:=  StateItem = oiOpenItem;
        OldLevel:= Level;
      end;
end;

function TxOutlineList.SearchKey(OldIndex: Integer; Key: Char): Integer;
var
  i: Integer;
  isOpen: Boolean;
  OldLevel: Integer;
begin
  isOpen := True;
  Result:= OldIndex;
  OldLevel:= 0;
  for i:= OldIndex + 1 to Count - 1 do
    with TxOutlineItem(Items[i]) do
      if (Level <= OldLevel) or isOpen then begin
        if CompareText(NameItem^[1], Key) = 0 then begin
          Result:= i;
          exit;
        end;
        isOpen:=  StateItem = oiOpenItem;
        OldLevel:= Level;
      end;

  isOpen:= true;
  OldLevel:= 0;

  for i:= 0 to OldIndex - 1 do
    with TxOutlineItem(Items[i]) do
      if (Level <= OldLevel) or isOpen then begin
        if CompareText(NameItem^[1], Key) = 0 then begin
          Result:= i;
          exit;
        end;
        isOpen:=  StateItem = oiOpenItem;
        OldLevel:= Level;
      end;

end;

function TxOutlineList.GetRow(NumItem: Integer): Integer;
var
  i: Integer;
  isOpen: Boolean;
  OldLevel: Integer;
begin
  isOpen := True;
  Result:= -1;
  OldLevel:= 0;

  if NumItem >= Count then exit;

  for i:= 0 to NumItem do
    with TxOutlineItem(Items[i]) do
      if (Level <= OldLevel) or isOpen then begin
        Inc(Result);
        isOpen:=  StateItem = oiOpenItem;
        OldLevel:= Level;
      end;

end;

{ TxCustomOutline ------------------------------------------------ }

const
  NameBitmap = 'XOUTLINEBMP';
  NameCombo = 'XOUTLINECOMBOBMP';

constructor TxCustomOutline.Create(AnOwner: TComponent);
begin

  inherited Create(AnOwner);

  isAlwaysOpen:= false;
  isDeleteSpace:= true;

  FLines:= TStringList.Create;
  FLines.Sorted:= false;
  ChangePen:= true;

  OutlineItem:= TxOutlineList.Create;

  ColCount:= 1;
  RowCount:= 0;

  DefaultDrawing:= false;

  FixedCols:= 0;
  FixedRows:= 0;

  FSelectColor:= DefaultSelectColor;

  FEditOutline:= true;
  inherited Options := [goThumbTracking, goEditing];

  FxOutlineOption:= DefOptions;

  SetCellWidth;

  FIndent:= DefIndent;
  FSquareSize:= DefSquareSize;
  FRowHeight:= DefRowHeight;

  if FRowHeight mod 2 = 0 then
    DefaultRowHeight:= FRowHeight
  else
    DefaultRowHeight:= FRowHeight + 1;

  Color:= DefOutlineColor;

  FCustomBitmap:= TBitmap.Create;
  if ComponentState = [csDesigning] then
    FCustomBitmap.HANDLE:= LoadBitmap(hInstance, NameBitmap);

  Canvas.Pen.Style:= psDot;

  OldPenChange:= Canvas.Pen.OnChange;
  Canvas.Pen.OnChange:= StyleChanged;

  FLines.OnChange:= LinesChanged;
  isRedrawGrid:= true;

  FEmptyBitmap:= false;
  FDistBitmapText:= DefDistBitmapText;

  isChooseSquare:= false;

  FNotebook:= nil;

end;

procedure TxCustomOutline.Loaded;
begin
  inherited Loaded;
  MakeList;

  if not FCustomBitmap.Empty then
    SetSizeBitmap;

  ItemIndex:= FItemIndex;
  SetCellWidth;

  if Assigned(FNotebook) then
    FNotebook.ActivePage:= GetItemText(ItemIndex);

  if (FCustomBitmap <> nil) and (FSizeSquare <> 0) then
    CountBitmap:= FCustomBitmap.Width div FSizeSquare
  else
    CountBitmap:= 0;

end;

procedure TxCustomOutline.CreateWnd;
begin
  inherited CreateWnd;
  SetItemHeight;

  if FEmptyBitmap then
    CustomBitmap:= nil;
end;

procedure TxCustomOutline.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('EmptyBitmap', ReadEmptyBitmap, WriteEmptyBitmap, True);
end;

procedure TxCustomOutline.Paint;
begin
  inherited Paint;
  if isEditState then DrawCell(Col, Row, CellRect(Col, Row), []);
  isRedrawGrid:= false;
end;

procedure TxCustomOutline.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if ((Key <> 13) and not IsCharAlphaNumeric(Chr(Key)) and (Key <> vk_BACK)) or
     (Key = VK_F2)
  then
    inherited KeyDown(Key, Shift);

end;

procedure TxCustomOutline.KeyPress(var Key: Char);
var
  Index: Integer;
begin
  if isEditState then begin
    inherited KeyPress(Key);
    exit;
  end;
  if Key in [#32..#255] then begin
    isRedrawGrid:= true;
    HideEditor;
    Index:= OutlineItem.SearchKey(ItemIndex, Key);
    ItemIndex:= Index;
    exit;
  end;
  if (Key <> #13) and (Key <> ^H) then
    inherited KeyPress(Key)
  else begin
    isRedrawGrid:= true;
    HideEditor;
  end;
end;

procedure TxCustomOutline.SetSizeBitmap;
begin
  FSizeSquare:= FCustomBitmap.Height div 2;
end;

procedure TxCustomOutline.DrawCell(ACol, ARow: Longint; ARect: TRect;
          AState: TGridDrawState);
var
  P, P1: TxOutlineItem;
  k: Integer;
  LeftSize: Integer;
  R, R1: TRect;
  Bitmap: TBitmap;
  OldStyle: TPenStyle;

procedure DrawLine(Level: Integer);
begin
  with Canvas, ARect do begin
    MoveTo(left + Level*FIndent + FIndent div 2, top);
    if Pen.Style <> psDot then
      LineTo(left + Level*FIndent + FIndent div 2, bottom)
    else begin
      DrawVertDottedLine(Canvas,
        left + Level*FIndent + FIndent div 2, top,
          DefaultRowHeight, 1);
    end;
  end;
end;

procedure DrawSecLine(Level: Integer);
begin
  with Canvas, ARect do begin
    if Pen.Style <> psDot then begin
      MoveTo(left + Level*FIndent + FIndent div 2, top);
      LineTo(left + Level*FIndent + FIndent div 2, bottom);
      MoveTo(left + Level*FIndent + FIndent div 2,
             top + (bottom - top) div 2);
      LineTo(left + Level*FIndent + FIndent,
        top + (bottom - top) div 2);
    end
    else begin
      DrawVertDottedLine(Canvas,
        left + Level*FIndent + FIndent div 2, top,
          DefaultRowHeight, 1);
      DrawHorzDottedLine(Canvas,
        left + Level*FIndent + FIndent div 2 + 1,
        top + DefaultRowHeight div 2, FIndent, 1);
    end;
  end;
end;

procedure DrawEndLine(Level: Integer);
begin
  with Canvas, ARect do begin
    if Pen.Style <> psDot then begin
      MoveTo(left + Level*FIndent + FIndent div 2, top);
      LineTo(left + Level*FIndent + FIndent div 2,
        top +  (bottom - top) div 2);
      LineTo(left + Level*FIndent + FIndent,
        top + (bottom - top) div 2);
    end
    else begin
      DrawVertDottedLine(Canvas,
        left + Level*FIndent + FIndent div 2, top,
          DefaultRowHeight div 2 + 1, 1);
      DrawHorzDottedLine(Canvas,
        left + Level*FIndent + FIndent div 2,
        top + DefaultRowHeight div 2, FIndent, 1);
    end;
  end;
end;

procedure DrawPlusMinus(StateItem: TStateOutlineItem; Level: Integer);

begin
  if StateItem in [oiOpenItem, oiCloseItem] then
    with Canvas, ARect do begin

      Rectangle(left + Level * FIndent + (FIndent - FSquareSize) div 2 + 1,
        top +  (bottom - top - FSquareSize) div 2,
        left + Level * FIndent + (FIndent - FSquareSize) div 2 + 1 +
        FSquareSize, top +  (bottom - top - FSquareSize) div 2 + FSquareSize);

      if StateItem = oiCloseItem then begin
        MoveTo(left + Level*FIndent + FIndent div 2,
          top +  (bottom - top - FSquareSize) div 2 + 2);

        LineTo(left + Level*FIndent + FIndent div 2,
          top +  (bottom - top - FSquareSize) div 2 + FSquareSize - 2);
      end;

      MoveTo( left + Level * FIndent + (FIndent - FSquareSize) div 2 + 3,
        top + DefaultRowHeight div 2 - 1 + DefaultRowHeight mod 2);

      LineTo( left + Level * FIndent + (FIndent - FSquareSize) div 2 +
        FSquareSize - 1,
        top + DefaultRowHeight div 2 - 1 + DefaultRowHeight mod 2);

    end;
end;

begin

  if OutlineItem.Count = 0 then exit;

  ChangePen:= false;

  P:= OutlineItem.GetViewItem(aRow);
  if P = nil then exit;

  k:= OutlineItem.IndexOf(P);
  if k < OutlineItem.Count - 1 then
    P1:= OutlineItem[k+1]
  else
    P1:= P;

  Canvas.Brush.Color:= Color;
  Canvas.Font.Color:= clWindowText;

  with P do begin


    if NameItem <> nil then begin

      if not isAlwaysOpen then
        LeftSize:= 0
      else
        LeftSize:= 4;

      if isRedrawGrid or (csDesigning in ComponentState) or isEditState
      then begin

      Canvas.FillRect(ARect);

      if FxOutlineOption in [xoTreePictureText, xoTreeText,
         xoPlusMinusTreePictureText, xoPlusMinusTreeText] then begin

        for k:= 0 to Level do begin
          case TreeStates[k] of
          tsLine: DrawLine(k);
          tsMidleLine: DrawSecLine(k);
          tsEndLine: DrawEndLine(k);
          end;
        end;

        if (FxOutlineOption in [xoPlusMinusTreePictureText, xoPlusMinusTreeText])
            and (P1.Level > Level)
        then begin
          OldStyle:= Canvas.Pen.Style;
          Canvas.Pen.Style:= psSolid;

          DrawPlusMinus(StateItem, Level);
          Canvas.Pen.Style:= OldStyle;
        end;
        LeftSize:= LeftSize + FIndent;

      end;

      if (FxOutlineOption in [xoTreePictureText, xoPictureText,
           xoPlusMinusTreePictureText]) and
         ( ((NumberBitmap > 0) and (not FCustomBitmap.Empty)) or
           Assigned(FOnGetBitmap))

      then begin

        if Assigned(FOnGetBitmap) then

            Bitmap:= FOnGetBitmap(Self, OutlineItem.IndexOf(P))

        else

           Bitmap:= TBitmap.Create;

        try


          if not Assigned(FOnGetBitmap) then begin

            Bitmap.Height:= FSizeSquare;
            Bitmap.Width:= FSizeSquare;
            Bitmap.Canvas.Brush:= Canvas.Brush;

            with R do begin
              left:= (NumberBitmap - 1) * FSizeSquare;
              right:= left + FSizeSquare;

              if left >= FCustomBitmap.Width then
                raise ExOutlineError.Create('Invalid the bitmap number');

              k:= OutlineItem.IndexOf(P);
              if (StateItem = oiOpenItem) and not isAlwaysOpen
                 and (k < OutlineItem.Count - 1) and
                 (TxOutlineItem(OutlineItem[k + 1]).Level > Level) 
              then
                top:= FSizeSquare
              else
                top:= 0;
              bottom:= top + FSizeSquare;
            end;

            SetRect(R1, 0, 0, FSizeSquare, FSizeSquare);

            Bitmap.Canvas.BrushCopy(R1, FCustomBitmap, R, clOlive);

          end;

          with R do begin
            Left:= ARect.Left + FIndent * Level + LeftSize;
            Right:= Left + FItemHeight;
            if StretchBitmap then begin
              Top:= ARect.Top + (ARect.Bottom - ARect.Top - FItemHeight) div 2;
              Bottom:= Top + FItemHeight;
            end
            else begin
              Top:= ARect.Top + (ARect.Bottom - ARect.Top - Bitmap.Height) div 2;
              Bottom:= Top + Bitmap.Height;
            end;
          end;

          if Bitmap <> nil then
            if StretchBitmap then
              Canvas.StretchDraw(R, Bitmap)
            else
              Canvas.Draw(R.left, R.top, Bitmap);


        finally
          Bitmap.Free;
        end;

        LeftSize:= LeftSize + FItemHeight + FDistBitmapText;

      end
      else
        if (FxOutlineOption in [xoPictureText]) and (not FCustomBitmap.Empty)
        then
          LeftSize:= LeftSize + FItemHeight + FDistBitmapText;

      end
      else begin

        if FxOutlineOption in [xoTreePictureText, xoTreeText,
         xoPlusMinusTreePictureText, xoPlusMinusTreeText] then
         LeftSize:= LeftSize + FIndent;

        if (FxOutlineOption in [xoTreePictureText, xoPictureText,
        xoPlusMinusTreePictureText]) and
           ( ((NumberBitmap > 0) and (not FCustomBitmap.Empty)) or
             Assigned(FOnGetBitmap))
        then
          LeftSize:= LeftSize + FItemHeight + FDistBitmapText
        else
          if (FxOutlineOption in [xoPictureText]) and (not FCustomBitmap.Empty)
          then
            LeftSize:= LeftSize + FItemHeight + FDistBitmapText;

        with R do begin

          if isAlwaysOpen then
            left:= ARect.left + FIndent * Level + LeftSize - 1
          else
             left:= ARect.left + FIndent * Level + LeftSize - 1;
          right:= ARect.Right;
          top:= ARect.Top;
          bottom:= ARect.Bottom;
        end;

        Canvas.FillRect(R);

      end;

      if gdSelected in AState then begin

        Canvas.Brush.Color:= SelectColor;
        Canvas.Font.Color:= Color;

      end;

      if not isEditState or (ARow <> Row) then
        Canvas.TextOut(ARect.left + FIndent * Level + LeftSize,
          ARect.Top + (ARect.Bottom - ARect.Top - FItemHeight) div 2, NameItem^);

      if (gdSelected in AState) and (gdFocused in AState) and not IsEditState
      then begin

        with R do begin
          left:= ARect.left + FIndent * Level + LeftSize - 1;
          right:= left + GetItemWidth(Canvas) + 2;
          top:= ARect.Top + (ARect.Bottom - ARect.Top - FItemHeight) div 2;
          bottom:= Top + FItemHeight;
        end;

        Canvas.DrawFocusRect(R);

      end;

    end;

  end;

  ChangePen:= true;

end;

procedure TxCustomOutline.SetItemHeight;
var
  ScreenDC: HDC;
  Num: Integer;
begin

  ScreenDC := GetDC(0);
  try

    FFontSize := MulDiv(Font.Size, GetDeviceCaps(ScreenDC, LOGPIXELSY), 72);
    Num := MulDiv(FFontSize, 120, 100);
    FItemHeight:= Num;

  finally
    ReleaseDC(0, ScreenDC);
  end;

end;

procedure TxCustomOutline.SetCellWidth;
var
  i, FW, PerWidth: Integer;
begin
  FW:= 0;

  Canvas.Font:= Font;

  for i:= 0 to OutlineItem.Count - 1 do
    with TxOutlineItem(OutlineItem[i]) do begin

      PerWidth:= (Level + 1)* FIndent + GetItemWidth(Canvas) +
        FRowHeight * 2 + 2;
      if FW < PerWidth then FW:= PerWidth;
    end;

  DefaultColWidth:= FW;

end;

procedure TxCustomOutline.SetLines(ALines: TStringList);
begin
  FLines.Assign(ALines);
  RebuildOutline;
end;

procedure TxCustomOutline.SetSelectColor(AColor: TColor);
begin
  if FSelectColor <> AColor then begin
    FSelectColor:= AColor;
    isRedrawGrid:= true;
    Invalidate;

  end;
end;

function TxCustomOutline.GetPen: TPen;
begin
  Result:= Canvas.Pen;
end;

procedure TxCustomOutline.SetPen(aPen: TPen);
begin
  Canvas.Pen.Assign(aPen);
  isRedrawGrid:= true;
  Invalidate;
end;

function TxCustomOutline.GetItemIndex: Integer;
var
  P: TObject;
begin
  P:= OutlineItem.GetViewItem(Row);
  if P = nil then
    Result:= -1
  else
    Result:= OutlineItem.IndexOf(P);
end;

procedure TxCustomOutline.SetItemIndex(aNewIndex: Integer);
var
  Num, OldIndex: Integer;
begin
  OldIndex:= FItemIndex;
  FItemIndex:= aNewIndex;

  Num:= OutlineItem.GetRow(aNewIndex);
  if (Num < RowCount) and (Num >= 0) then
    Row:= Num;

  if csDesigning in ComponentState then begin
    isRedrawGrid:= true;
    Invalidate;
  end;

  if (OldIndex <> FItemIndex) then Change(Self);

end;

procedure TxCustomOutline.SetIndent(aValue: Integer);
begin
  if FIndent <> aValue then begin
    FIndent:= aValue;

    if FSquareSize >= aValue then
      SquareSize:= aValue - 2;

    SetCellWidth;
    Invalidate;
  end;
end;

procedure TxCustomOutline.SetNewRowHeight(aValue: Integer);
begin
  if aValue <> FRowHeight then begin
    FRowHeight:= aValue;
    if aValue mod 2 <> 0 then Inc(aValue);
    DefaultRowHeight:= aValue;
  end;
end;

procedure TxCustomOutline.SetDistBitmapText(aValue: Integer);
begin
  if FDistBitmapText <> aValue then begin
    FDistBitmapText:= aValue;
    Invalidate;
  end;
end;

procedure TxCustomOutline.SetStretchBitmap(aValue: Boolean);
begin
  if FStretchBitmap <> aValue then begin
    FStretchBitmap:= aValue;
    Invalidate;
  end;
end;

procedure TxCustomOutline.SetEditOutline(aValue: Boolean);
begin
  if aValue <> FEditOutline then begin
    FEditOutline:= aValue;
    if aValue then
      inherited Options:= inherited Options + [goEditing]
    else
      inherited Options:= inherited Options - [goEditing]
  end;
end;

function TxCustomOutline.ReadItemText: String;
begin
  FItemText:= GetItemText(ItemIndex);
  ReadItemText:= FItemText;
end;

procedure TxCustomOutline.SetItemText(aValue: String);
begin
  FItemText:= aValue;
  ItemIndex:= GetIndexByText(FItemText);
end;

procedure TxCustomOutline.SetSquareSize(aValue: Integer);
begin

  if AValue > DefaultRowHeight then
    raise ExOutlineError.Create('SquareSize too large');

  if FSquareSize <> aValue then begin
    FSquareSize:= aValue;
    if FSquareSize >= FIndent then
      Indent:= FSquareSize + 2;
    Invalidate;
  end;
end;

procedure TxCustomOutline.SetCustomBitmap(ABitmap: TBitmap);
begin
  if Assigned(ABitmap) and (not ABitmap.Empty) then begin
    FCustomBitmap.Assign(ABitmap);
    SetSizeBitmap;
  end
  else begin
    FCustomBitmap.Free;
    FCustomBitmap:= TBitmap.Create;
  end;
  isRedrawGrid:= true;

  if not (csCreating in ControlState) and (csDesigning in ComponentState) then
    FEmptyBitmap:= FCustomBitmap.Empty;

  Invalidate;
end;

procedure TxCustomOutline.SetxOutlineOption(AOption: TxOutlineOption);
begin
  FxOutlineOption:= AOption;
  isRedrawGrid:= true;
  Invalidate;
end;

procedure TxCustomOutline.StyleChanged(Sender: TObject);
begin
  if ChangePen then begin
    isRedrawGrid:= true;
    Invalidate;
  end;

  if Assigned(OldPenChange) then OldPenChange(Sender);
end;

procedure TxCustomOutline.LinesChanged(Sender: TObject);
begin
  if not (csLoading in ComponentState) and (not (csDesigning in ComponentState))
  then
    RebuildOutline;
end;

procedure TxCustomOutline.WriteEmptyBitmap(Writer: TWriter);
begin
  Writer.WriteBoolean(FEmptyBitmap);
end;

procedure TxCustomOutline.ReadEmptyBitmap(Reader: TReader);
begin
  FEmptyBitmap:= Reader.ReadBoolean;
end;

procedure TxCustomOutline.Change(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Sender);
  if Assigned(FNotebook) then
    FNotebook.ActivePage:= GetItemText(ItemIndex);
end;

procedure TxCustomOutline.MakeList;
var
  i, j: Integer;
  Dec, Dec1: Integer;
begin

  OutlineItem.Free;
  OutlineItem:= TxOutlineList.Create;

  if FLines.Count = 0 then exit;

  Dec:= 0;
  if isDeleteSpace then begin

    while (Dec < Length(FLines.Strings[0])) and
          (FLines.Strings[0][Dec + 1] = ' ') do Inc(Dec);

    if Dec > 0 then
      FLines.Strings[0]:= copy(FLines.Strings[0], Dec + 1,
        Length(FLines.Strings[0]));

  end;
 
  for i:= 0 to FLines.Count - 1 do begin
    if Dec > 0 then begin
      Dec1:= Dec;
      for j:= 1 to Dec do
        if FLines.Strings[i][j] <> ' ' then begin
          Dec1:= j - 1;
          Break;
        end;
      if Dec1 > 0 then
        FLines.Strings[i]:= copy(FLines.Strings[i], Dec1 + 1,
      Length(FLines.Strings[i]));
    end;
    OutLineItem.Add(TxOutlineItem.Create(FLines[i]));
  end;

  RowCount:= OutlineItem.CalcViewItem;

  SetCellWidth;

  OutlineItem.MakeTreeState;

  if csDesigning in ComponentState then
    CustomBitmap:= CustomBitmap;

end;

destructor TxCustomOutline.Destroy;
begin
  FLines.Free;
  OutlineItem.Free;
  FCustomBitmap.Free;
  inherited Destroy;
end;

procedure TxCustomOutline.SwitchState(NumItem: Integer);
var
  P, P1: TxOutlineItem;
  i, j, Num: Integer;
  S: String;
begin
  if (NumItem >= 0) and (NumItem < OutlineItem.Count) then begin

    P:= OutlineItem.GetViewItem(NumItem);
    Num:= OutlineItem.IndexOf(P);
    if Num = OutlineItem.Count - 1 then exit;

    P1:= OutlineItem[Num + 1];

    if (P1.level > P.level) and P.NewState then begin
      RowCount:= OutlineItem.CalcViewItem;
      isRedrawGrid:= true;
      Invalidate;

      i:= OutlineItem.IndexOf(P);
      S:= FLines.Strings[i];
      j:= Pos('/-/', S);
      if j <> 0 then
        S:= copy(S, 1, j)+'+'+copy(S, j+2, length(S))
      else begin
        j:= Pos('/+/', S);
        if j <> 0 then
          S:= copy(S, 1, j)+'-'+copy(S, j+2, length(S));
      end;
      FLines.Strings[i]:= S;

    end;

  end;
end;

procedure TxCustomOutline.RebuildOutline;
begin
  MakeList;
  isRedrawGrid:= true;
  Invalidate;
end;

function TxCustomOutline.GetEditText(ACol, ARow: Longint): string;
begin
  if Assigned(FOnGetEditText) then
    FOnGetEditText(Self, ACol, ARow, Result)
  else
    Result:= GetItemText(ItemIndex);
end;

procedure TxCustomOutline.SetEditText(ACol, ARow: Longint; const Value: string);
begin
  if Assigned(FOnSetEditText) then
    FOnSetEditText(Self, ACol, ARow, Value);
end;

function TxCustomOutline.isEditState: Boolean;
begin
  Result:= (InplaceEditor <> nil) and InplaceEditor.Visible;
  if Result then
    Result:= true;
end;

procedure TxCustomOutline.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FNotebook <> nil) and
    (AComponent = FNotebook) then FNotebook := nil;
end;

function TxCustomOutline.CreateEditor: TInplaceEdit;
begin
  CreateEditor:= TxInplaceEdit.Create(Self);
end;

function TxCustomOutline.GetItemBitmap(aCanvas: TCanvas;
  Index: Integer): TBitmap;
var
  R, R1: TRect;
begin
  if (Index < 0) or (Index >= OutlineItem.Count) then
    Result:= nil
  else begin
    Result:= TBitmap.Create;

    with TxOutlineItem(OutlineItem[Index]) do

      if Assigned(FOnGetBitmap) then

        Result.Assign(FOnGetBitmap(Self, Index))

      else begin
        with R do begin

          left:= (NumberBitmap - 1) * FSizeSquare;
          right:= left + FSizeSquare;
          if (StateItem = oiOpenItem) and not isAlwaysOpen then
            top:= FSizeSquare
          else
            top:= 0;
          bottom:= top + FSizeSquare;

        end;

        SetRect(R1, 0, 0, FSizeSquare, FSizeSquare);

        Result.Height:= FSizeSquare;
        Result.Width:= FSizeSquare;
        Result.Canvas.Brush:= aCanvas.Brush;
        Result.Canvas.BrushCopy(R1, FCustomBitmap, R, clOlive);

      end;

  end;
end;

function TxCustomOutline.GetItemText(Index: Integer): String;
begin
  if (Index >= 0) and (Index < OutlineItem.Count) then
    Result:= TxOutlineItem(OutlineItem[Index]).NameItem^
  else
    Result:= '';
end;

function TxCustomOutline.GetItemHeight: Integer;
begin
  GetItemHeight:= FItemHeight;
end;

function TxCustomOutline.GetPath(Index: Integer): String;
begin
  Result:= OutlineItem.GetPath(Index);
end;

function TxCustomOutline.GetCurrentPath: String;
begin
  Result:= GetPath(ItemIndex);
end;

function TxCustomOutline.GetState(Index: Integer): TStateOutlineItem;
begin
  if (Index >= 0) and (Index < OutlineItem.Count) then
    with TxOutlineItem(OutlineItem[Index]) do
      Result:= StateItem
  else
    Result:= oiNoneItem;
end;

function TxCustomOutline.GetIndexByPath(Path: String): Integer;
var
  S: String;
  i, OldLevel, Num, K: Integer;
begin
  S:= '';
  Result:= -1;
  OldLevel:= 0;
  Num:= 0;

  while S <> Path do begin

    k:= Pos('\', Path);
    if K <> 0 then begin
      S:= copy(Path, 1, k - 1);
      Path:= copy(Path, k + 1, length(Path));
    end
    else
      S:= Path;

    for i:= Num to OutlineItem.Count - 1 do begin

      with TxOutlineItem(OutlineItem[i]) do begin
        if (Level = OldLevel) and (UpperCase(NameItem^) = UpperCase(S))
        then begin
          Result:= i;
          Num:= i;
          Inc(OldLevel);
          Break;
        end;
      end;

    end;

  end;

end;

function TxCustomOutline.GetIndexByText(Text: String): Integer;
var
  i: Integer;
begin

  Result:= -1;

  for i:= 0 to OutlineItem.Count - 1 do begin

    with TxOutlineItem(OutlineItem[i]) do begin
      if (UpperCase(NameItem^) = UpperCase(Text))
      then begin
        Result:= i;
        Break;
      end;
    end;

  end;

end;

function TxCustomOutline.GetNumberLevel: Integer;
begin
  if ItemIndex >= 0 then
    Result:= TxOutlineItem(OutlineItem[ItemIndex]).Level
  else
    Result:= -1;
end;

procedure TxCustomOutline.ChangeAllState(isOpen: Boolean);
var
  i: Integer;
  OldIndex: Integer;
begin
  OldIndex:= ItemIndex;
  for i:= Lines.Count - 1 downto 0 do begin
    if ((GetState(i) = oiCloseItem) and isOpen) or
       ((GetState(i) = oiOpenItem) and not isOpen) then
      SwitchState(OutlineItem.GetRow(i))
  end;
  if OldIndex <> ItemIndex then Change(Self);
end;

procedure TxCustomOutline.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  OldIndex: Integer;
begin
  OldIndex:= ItemIndex;
  inherited;
  if (OldIndex <> ItemIndex) then Change(Self);
  SwitchState(Row);
end;

procedure TxCustomOutline.WMKeyDown(var Message: TWMKeyDown);
var
  OldIndex: Integer;
begin
  OldIndex:= ItemIndex;
  if (Message.CharCode = vk_Return) then begin
    SwitchState(Row);
    Message.Result:= 0;
    exit;
  end;


  if (Message.CharCode <> vk_F2) and (IsCharAlphaNumeric(Chr(Message.CharCode))
     or (Message.CharCode = vk_BACK)) and (Message.CharCode <> vk_F1)
  then begin
    Message.Result:= 0;
    exit;
  end;

  inherited;

  if (OldIndex <> ItemIndex) then Change(Self);

  if (abs(OldIndex - ItemIndex) > VisibleRowCount) and
     ( ((OldIndex = 0) and (Row = RowCount - 1)) or (Row = 0))
  then begin
    isRedrawGrid:= true;
    Invalidate;
  end;
end;

procedure TxCustomOutline.WMKeyUp(var Message: TWMKeyUp);
begin
  if (Message.CharCode = vk_Return) then
    Message.Result:= 0
  else
    inherited;
end;

procedure TxCustomOutline.WMChar(var Message: TWMChar);
var
  OldOption: TGridOptions;
begin
  OldOption:= inherited Options;
  with Message do
    if not isEditState and (CharCode in [VK_BACK, 32..255]) then
      inherited Options:= inherited Options - [goEditing];
  inherited;
  inherited Options:= OldOption;
end;

procedure TxCustomOutline.WMMouseMove(var Message: TWMMouseMove);
begin
  if not isChooseSquare then
    inherited
  else
    Message.Result:= 1;
end;

procedure TxCustomOutline.WMLButtonDown(var Message: TWMLButtonUp);
var
  P: TxOutlineItem;
  R: TRect;
  OldIndex: Integer;
  GridC: TGridCoord;
  SBP: Integer;
  OldRow: Longint;
begin
  OldIndex:= ItemIndex;
  if ItemIndex = -1 then begin
    Message.Result:= 0;
    exit;
  end;

  if FxOutlineOption in [xoPlusMinusTreePictureText, xoPlusMinusTreeText]
  then begin
    with Message do
      GridC:= MouseCoord(Xpos, YPos);
    SBP:= GetScrollPos(HANDLE, SB_HORZ);
    R:= CellRect(GridC.X, GridC.Y);
    P:= OutlineItem.GetViewItem(GridC.Y);
    with P, Message, R do
      if (XPos + SBP >= left + Level * FIndent + FIndent div 2 -
          FSquareSize div 2) and
         (XPos + SBP <= left + Level * FIndent + FIndent div 2 +
          FSquareSize div 2) and
         (YPos >= top +  (bottom - top - FSquareSize) div 2) and
         (YPos <= top +  (bottom - top - FSquareSize) div 2 + FSquareSize)
      then begin
        if isEditState then exit;
{        LockWindowUpdate(HANDLE);}
        GridC.X:= TopRow;

        SwitchState(GridC.Y);
        Result:= 1;
        OldRow:= OutlineItem.GetRow(OldIndex);
        if Row <> OldRow then begin

          Row:= OldRow;
          if TopRow <> GridC.X then
            TopRow:= GridC.X;
          isRedrawGrid:= true;
          InvalidateRect(HANDLE, nil, true);

        end;
{        LockWindowUpdate(0);}
        exit;
      end;
  end;

  inherited;

  isChooseSquare:= false;
  if (OldIndex <> ItemIndex) then Change(Self);
  OldItemIndex:= ItemIndex;
end;

procedure TxCustomOutline.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if (OldItemIndex <> ItemIndex) then Change(Self);
end;

procedure TxCustomOutline.CMFontChanged(var Message: TMessage);
begin
  inherited;
  SetCellWidth;
  SetItemHeight;
  if FRowHeight < FItemHeight then
    RowHeight:= FItemHeight;
end;

procedure TxCustomOutline.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  isRedrawGrid:= true;
  inherited;
end;

procedure TxCustomOutline.WMVScroll(var Message: TWMVScroll);
begin
  isRedrawGrid:= true;
  inherited;
end;

procedure TxCustomOutline.wmGetInplaceCoord(var Message: TMessage);
var
  P: TxOutlineItem;
begin
  Message.Result:= 0;
  P:= OutlineItem.GetViewItem(Row);
  if P = nil then exit;

  with P, Message do begin
    Result:= 0;
    if FxOutlineOption in [xoTreePictureText, xoTreeText,
     xoPlusMinusTreePictureText, xoPlusMinusTreeText] then
     Result:= Result + FIndent;

    if (FxOutlineOption in [xoTreePictureText, xoPictureText,
    xoPlusMinusTreePictureText]) and
       ( ((NumberBitmap > 0) and (not FCustomBitmap.Empty)) or
         Assigned(FOnGetBitmap))
    then
      Result:= Result + FItemHeight + FDistBitmapText
    else
      if (FxOutlineOption in [xoPictureText]) and (not FCustomBitmap.Empty)
      then
        Result:= Result + FItemHeight + FDistBitmapText;

     Result:= FIndent * Level + Result - 1 - GetScrollPos(HANDLE, SB_HORZ);
     if Result < 0 then Result:= 0;
   end;
end;


const
  OutlineGraying = 'XOUTLINEGRAYBMP';

{ TExOtlineWindow --------------------------------------------- }

constructor TxOutlineWindow.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  isAlwaysOpen:= true;

  Options:= xoPictureText;
  Visible:= false;
  ScrollBars:= ssVertical;
  EditOutline:= false;

end;

procedure TxOutlineWindow.SetSizeBitmap;
begin
  FSizeSquare:= CustomBitmap.Height;
end;

procedure TxOutlineWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  with Params do
    if (csDesigning in Parent.ComponentState)
    then
      Style:= Style or ws_Child
    else
      Style:= Style or ws_Popup;

end;

procedure TxOutlineWindow.Loaded;
begin
  inherited Loaded;
  Ctl3d:= true;
  ParentCtl3d:= true;
  BorderStyle:= bsSingle;
  EditOutline:= false;
end;

procedure TxOutlineWindow.WMLButtonUp(var Message: TWMLButtonUp);
var
  ScrollSize: Integer;
begin
  inherited;
  if VisibleRowCount < RowCount then
    ScrollSize:= GetSystemMetrics(SM_CXVSCROLL)
  else
    ScrollSize:= 0;

  with Message do
    if (XPos >= Width - ScrollSize) and (XPos <= Width) and (ScrollSize > 0)
       and (YPos >= 0) and (YPos <= Height)
    then exit;

  with Parent as TxOutlineCombo do begin
    OutlineShow:= false;
    ItemIndex:= Self.ItemIndex;
  end;
end;

procedure TxOutlineWindow.WMMouseMove(var Message: TWMMouseMove);
var
  ScrollSize: Integer;
begin
  inherited;
  if VisibleRowCount < RowCount then
    ScrollSize:= GetSystemMetrics(SM_CXVSCROLL)
  else
    ScrollSize:= 0;

  with Message do
    if (XPos >= 0) and (XPos < Width - ScrollSize) and (YPos >= 0) and
       (YPos <= Height) and  not (csDesigning in Parent.ComponentState)
    then
      Row:= MouseCoord(XPos, YPos).Y;
end;

procedure TxOutlineWindow.WMActivate(var Message: TWMActivate);
begin
  inherited;
  if Message.Active = WA_INACTIVE then begin
    MouseCapture:= False;
    with Parent as TxOutlineCombo do begin
      isSetFocus:= False;
      OutlineShow:= False;
    end;
  end;
end;

procedure TxOutlineWindow.WMKeyDown(var Message: TWMKeyDown);
begin
  if Message.CharCode = VK_RETURN then begin
    with Parent as TxOutlineCombo do begin
      OutlineShow:= false;
      ItemIndex:= Self.ItemIndex;
    end;
    Message.Result:= 0;
  end
  else begin
    inherited;
    with Parent as TxOutlineCombo do begin
      ItemIndex:= Self.ItemIndex;
      if (Message.CharCode = VK_ESCAPE) or (Message.CharCode = VK_TAB) then
      begin
        OutlineShow:= false;
        ItemIndex:= OldIndex;
      end;
    end;
  end;
end;


{ TOtlineCombo ------------------------------------------------ }

constructor TxOutlineCombo.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ControlStyle := ControlStyle + [csOpaque, csFramed, csDoubleClicks];

  FLines:= TStringList.Create;
  FLines.Sorted:= false;

  FCustomBitmap:= TBitmap.Create;
  if ComponentState = [csDesigning] then
    FCustomBitmap.HANDLE:= LoadBitmap(hInstance, NameCombo);

  FOutlineWindow := CreateOutline;
  FOutlineWindow.Parent:= Self;

  FOutlineColor:= DefOutlineColor;

  FOutlineShow:= false;
  FItemIndex:= DefItemIndex;
  OldIndex:= 0;

  FDown:= false;
  isFirst:= true;
  isFocus:= false;

  FColor:= DefOutlineColor;

  KeyPressed:= false;

  Width:= DefWidth;
  Height:= DefHeight;

  FOutlineHeight:= DefOutlineHeight;

  FOutlineWindow.Width:= Width;
  FOutlineWindow.RowHeight:= DefRowHeight;
  FOutlineWindow.Indent:= DefIndentCombo;

  isSetFocus:= true;

end;

destructor TxOutlineCombo.Destroy;
begin
  FLines.Free;
  FCustomBitmap.Free;
  inherited Destroy;
end;

procedure TxOutlineCombo.SetDown(aDown: Boolean);
begin
  if FDown <> aDown then begin
    FDown:= aDown;
    DrawButton;
  end;
end;

procedure TxOutlineCombo.SetOutlineShow(aShow: Boolean);
begin
  if aShow <> FOutlineShow then begin

    FOutlineShow:= aShow;

    if (csDesigning in ComponentState)
    then begin

      if AShow then begin

        if not isFirst then
          FComboHeight:= Height;

        SetWindowPos(Handle, 0, Left, Top, Width,
          FComboHeight + FOutlineWindow.Height,  SWP_NOZORDER);

      end
      else
        SetWindowPos(Handle, 0, Left, Top, Width, FComboHeight,
          SWP_NOZORDER);

    end;

    if FOutlineShow then begin
      if isFirst  then begin

        if Height <> FComboHeight then
          Height:= FComboHeight;

        FOutlineShow:= False;
        isFirst:= false;
        exit;
      end;

      MoveOutlineWindow;
      FOutlineWindow.ItemIndex:= FItemIndex;
      FOutlineWindow.Show;
      if not (csDesigning in ComponentState)  then begin
        ShowHint:= false;
        FOutlineWindow.MouseCapture:= True;
        FOutlineWindow.SetFocus;
        OldIndex:= FItemIndex;
      end;
    end
    else begin
      FOutlineWindow.Hide;
      if not (csDesigning in ComponentState) and isSetFocus then
        SetFocus;
      ShowHint:= OldShowHint;
      isSetFocus:= True;
    end;
  end;
  isFirst:= false;
end;

procedure TxOutlineCombo.SetOutlineHeight(aNewHeight: Integer);
begin
  if FOutlineHeight <> aNewHeight then begin
    FOutlineHeight:= aNewHeight;
    FOutlineWindow.Height:= FOutlineHeight;
    if (csDesigning in ComponentState) and FOutlineShow then
      Height:= FOutlineWindow.Height + FComboHeight;
  end;
end;

procedure TxOutlineCombo.SetItemIndex(aIndex: Integer);
begin
  if FItemIndex <> aIndex then begin
    FItemIndex:= aIndex;
    FOutlineWindow.ItemIndex:= FItemIndex;
    if Assigned(FOnClick) then FOnClick(Self);
    DrawLine;
  end;
  if not FOutlineShow then Change;
end;

procedure TxOutlineCombo.SetIndent(aValue: Integer);
begin
  if aValue <> FOutlineWindow.Indent then begin
    FOutlineWindow.Indent:= aValue;
    Invalidate;
  end;
end;

function TxOutlineCombo.GetIndent: Integer;
begin
  Result:= FOutlineWindow.Indent;
end;

procedure TxOutlineCombo.SetRowHeight(aValue: Integer);
begin
  if aValue <> FOutlineWindow.RowHeight then begin
    FOutlineWindow.RowHeight:= aValue;
    Invalidate;
  end;
end;

function TxOutlineCombo.GetRowHeight: Integer;
begin
  Result:= FOutlineWindow.RowHeight;
end;

procedure TxOutlineCombo.SetDistBitmapText(aValue: Integer);
begin
  if aValue <> FOutlineWindow.DistBitmapText then begin
    FOutlineWindow.DistBitmapText:= aValue;
    Invalidate;
  end;
end;

function TxOutlineCombo.GetDistBitmapText: Integer;
begin
  Result:= FOutlineWindow.DistBitmapText;
end;

procedure TxOutlineCombo.SetStretchBitmap(aValue: Boolean);
begin
  if aValue <> FOutlineWindow.StretchBitmap then begin
    FOutlineWindow.StretchBitmap:= aValue;
    if not aValue and (FCustomBitmap.Height > FComboHeight - 6) then begin
      FComboHeight:= FCustomBitmap.Height + 6;
      if FOutlineShow then begin
        Height:= FComboHeight + FOutlineWindow.Height;
        FOutlineWindow.Top:= FComboHeight;
      end
      else
        Height:= FComboHeight;
    end;
    Invalidate;
  end;
end;

function TxOutlineCombo.GetStretchBitmap: Boolean;
begin
  Result:= FOutlineWindow.StretchBitmap;
end;

procedure TxOutlineCombo.SetCustomBitmap(aBitmap: TBitmap);
begin
  if Assigned(ABitmap) and (not ABitmap.Empty) then begin
    FCustomBitmap.Assign(ABitmap);
  end
  else begin
    FCustomBitmap.Free;
    FCustomBitmap:= TBitmap.Create;
  end;

  if not (csCreating in ControlState) and (csDesigning in ComponentState) then
    FEmptyBitmap:= FCustomBitmap.Empty;

  FOutlineWindow.CustomBitmap:= FCustomBitmap;

  Invalidate;
end;

procedure TxOutlineCombo.SetLines(aLines: TStringList);
begin
  FLines.Assign(aLines);

  MakeOutline;

  Invalidate;
end;

procedure TxOutlineCombo.SetColor(aColor: TColor);
begin
  FColor:= aColor;
  Invalidate;
end;

procedure TxOutlineCombo.SetOutlineColor(aColor: TColor);
begin
  if aColor <> FOutlineColor then begin
    FOutlineColor:= aColor;
    FOutlineWindow.Color:= FOutlineColor;
  end;
end;

procedure TxOutlineCombo.WriteEmptyBitmap(Writer: TWriter);
begin
  Writer.WriteBoolean(FEmptyBitmap);
end;

procedure TxOutlineCombo.ReadEmptyBitmap(Reader: TReader);
begin
  FEmptyBitmap:= Reader.ReadBoolean;
end;

procedure TxOutlineCombo.WriteComboHeight(Writer: TWriter);
begin
  Writer.WriteInteger(FComboHeight);
end;

procedure TxOutlineCombo.ReadComboHeight(Reader: TReader);
begin
  FComboHeight:= Reader.ReadInteger;
  if not (csDesigning in ComponentState) and (Height <> FComboHeight) then
    Height:= FComboHeight;
end;

procedure TxOutlineCombo.MoveOutlineWindow;
var
  P: TPoint;
begin
  if not (csDesigning in ComponentState) then begin
    P:= Point(Left, Top + Height);
    MapWindowPoints(Parent.Handle, GetDesktopWindow, P, 1);
    if FOutlineWindow.Parent <> nil then
      FOutlineWindow.SetBounds( P.X, P.Y, FOutlineWindow.Width,
        FOutlineWindow.Height );
  end
  else
    if FOutlineShow then
      with FOutlineWindow do
        SetBounds(0, FComboHeight, Width, Height);
end;

procedure TxOutlineCombo.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if not KeyPressed then begin
    MouseCapture:= true;
    SetFocus;
    with Message do
    Down:= (XPos >= Width - ButtonWidth) and (XPos < Width) and (YPos >= 0) and
        (YPos < Height);
    if Assigned(FOnClick) then FOnClick(Self);
  end;
end;

procedure TxOutlineCombo.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if not KeyPressed then begin
    MouseCapture:= false;
    Down:= false;
    OutlineShow:= true;
  end;
end;

procedure TxOutlineCombo.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
   if (not KeyPressed) and MouseCapture then
     with Message do
      Down := (XPos >= Width - ButtonWidth) and (XPos < Width) and (YPos >= 0) and
        (YPos < Height);
end;

procedure TxOutlineCombo.WMSize(var Message: TWMSize);
begin
  inherited;
  if (csDesigning in ComponentState) and FOutlineShow then begin
    OutlineHeight:= Message.Height - FComboHeight;
    FoutlineWindow.Width:= Message.Width;
  end
  else
    if not FOutlineShow then
      FComboHeight:= Message.Height;
end;

procedure TxOutlineCombo.CMFontChanged(var Message: TMessage);
begin
  FOutlineWindow.Font:= Font;
  Canvas.Font:= Font;
  if (csDesigning in ComponentState)  then begin
    FComboHeight:= FOutlineWindow.DefaultRowHeight + 5;
    if FOutlineShow then begin
      Height:= FOutlineWindow.DefaultRowHeight + 5 + FOutlineWindow.Height;
      with FOutlineWindow do
        SetBounds( 0, FComboHeight, Width, Height );
    end
    else
      Height:= FComboHeight;
  end;

  Invalidate;
end;

procedure TxOutlineCombo.CMEnabledChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TxOutlineCombo.CMFocusChanged(var Message: TCMFocusChanged);
begin
  inherited;
  if isFocus <> Focused then begin
   Invalidate;
   isFocus:= Focused;
  end;
end;

procedure TxOutlineCombo.WMKeyDown(var Message: TWMKeyDown);
begin
  inherited;
  if (Message.CharCode = VK_DOWN) or (Message.CharCode = VK_RIGHT) then
    OutlineShow:= true;
end;

procedure TxOutlineCombo.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result:= Message.Result or DLGC_WANTARROWS;
end;

procedure TxOutlineCombo.DrawButton;
var
  Bitmap, GrayBitmap, OldBitmap: TBitmap;
  R: TRect;
begin
  R:= ClientRect;
  if (csDesigning in ComponentState) and FOutlineShow then
    R.Bottom:= FComboHeight;

  R.left:= R.right - ButtonWidth;
  R.Top:= R.Top + 2;
  R.Bottom:= R.Bottom - 2;
  R.right:= R.Right - 2;

  R:= DrawButtonFace(Canvas, R, 2, bsNew, false, FDown, false);

   if Enabled then begin
     Canvas.Pen.Color:= clBtnText;
     Canvas.Brush.Color:= clBtnText;
   end
   else begin
     Canvas.Pen.Color:= clBtnShadow;
     Canvas.Brush.Color:= clBtnShadow;
   end;

  Bitmap:= TBitmap.Create;
  try
    Bitmap.Handle:= LoadBitmap(0, PChar(OBM_COMBO));
    Bitmap.Canvas.Draw(0,0, Bitmap);
    if Enabled then
      Canvas.Draw(R.left , R.Top + (R.bottom - R.top - 12) div 2, Bitmap)
    else begin
      GrayBitmap:= TBitmap.Create;
      try
        GrayBitmap.HANDLE:= LoadBitmap(hInstance, OutlineGraying);
        if GrayBitmap.Handle <> 0 then begin
          OldBitmap:= Canvas.Brush.Bitmap;
          Canvas.Brush.Bitmap:= GrayBitmap;
          UnrealizeObject(Canvas.Brush.HANDLE);
          BitBlt(Canvas.HANDLE, R.left, R.Top + (R.bottom - R.top - 12) div 2,
            Bitmap.Width, Bitmap.Height, Bitmap.Canvas.Handle, 0, 0,
            $00A803A9);
          Canvas.Brush.Bitmap:= OldBitmap;
        end;
      finally
        GrayBitmap.Free;
      end;
    end;

  finally
    Bitmap.Free;
  end;
end;

procedure TxOutlineCombo.DrawLine;
var
  Bitmap: TBitmap;
  R: TRect;
  OldColor: TColor;
  S: String;
begin

  R:= ClientRect;
  if (csDesigning in ComponentState) and FOutlineShow then
    R.Bottom:= FComboHeight;

  R.left:= R.left + 4;
  R.top:= R.top + 4;
  R.bottom:= R.bottom - 4;
  R.right:= Width - ButtonWidth - 1;

  Canvas.Brush.Color:= Color;

  Canvas.FillRect(R);

  Bitmap:= FOutlineWindow.GetItemBitmap(Canvas, FItemIndex);
  try
    if Assigned(Bitmap) and not Bitmap.Empty then begin
      with R do begin
        left:= left + 2;

      end;

      if StretchBitmap then begin
        with R do
          right:= left + bottom - top;
        Canvas.StretchDraw(R, Bitmap)
      end
      else begin
        Canvas.Draw(R.left, R.top + (R.bottom - R.top - Bitmap.Height) div 2,
          Bitmap);
        R.right:= R.left + Bitmap.Width;
      end;
      R.left:= R.right + FOutlineWindow.DistBitmapText;
    end;
  finally
    Bitmap.Free;
  end;

  Canvas.Font:= Font;
  R.right:= Width - ButtonWidth - 1;

  OldColor:= Canvas.Font.Color;
  if Focused then begin
    Canvas.Brush.Color:= FOutlineWindow.SelectColor;
    Canvas.Font.Color:= Color
  end;

  if Enabled then
    Canvas.TextRect(R, R.left, (R.top + (R.bottom - R.Top -
      FOutlineWindow.GetItemHeight) div 2), FOutlineWindow.GetItemText(FItemIndex))
  else begin
    Canvas.Brush.Color:= clGrayText;

    S:= FOutlineWindow.GetItemText(FItemIndex) + #0;
    GrayString(Canvas.HANDLE, Canvas.Brush.Handle, nil, Longint(@S[1]), 0,
      R.left, R.top + (R.bottom - R.Top -
      FOutlineWindow.GetItemHeight) div 2, R.right, R.bottom);
  end;

  Canvas.Brush.Color:= Color;
  Canvas.Font.Color:= OldColor;

end;

procedure TxOutlineCombo.Change;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TxOutlineCombo.CreateWnd;
begin
  inherited CreateWnd;
  if FEmptyBitmap then
    CustomBitmap:= nil;
end;

procedure TxOutlineCombo.ReadState(Reader: TReader);
begin
  FComboHeight:= DefHeight;
  FEmptyBitmap:= false;
  inherited ReadState(Reader);
end;

function TxOutlineCombo.CreateOutline: TxCustomOutline;
begin
  CreateOutline:= TxOutlineWindow.Create(nil);
end;

procedure TxOutlineCombo.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('GS_EmptyBitmap', ReadEmptyBitmap, WriteEmptyBitmap, True);
  Filer.DefineProperty('GS_ComboHeight', ReadComboHeight, WriteComboHeight, True);
end;

function TxOutlineCombo.GetItemText(Index: Integer): String;
begin
  Result:= FOutlineWindow.GetItemText(Index);
end;

function TxOutlineCombo.GetPath(Index: Integer): String;
begin
  Result:= FOutlineWindow.GetPath(Index);
end;

function TxOutlineCombo.CurrentPath: String;
begin
  Result:= FOutlineWindow.GetPath(ItemIndex);
end;

procedure TxOutlineCombo.Paint;
var
  R: TRect;
begin

  R:= ClientRect;
  if (csDesigning in ComponentState) and FOutlineShow then
    R.Bottom:= FComboHeight;

  Canvas.Brush.Color:= Color;
  Canvas.FillRect(R);

  Frame3D(Canvas, R, clBtnText, clBtnHighlight, 1);

  Canvas.Pen.Color:= clBtnText;
  Canvas.Rectangle(R.left - 1, R.top - 1, R.right + 1, R.bottom + 1);

  Canvas.Pen.Color:= clBtnFace;
  Canvas.Rectangle(R.left + 1, R.top + 1, R.right, R.bottom - 1);

  DrawLine;

  DrawButton;

  isFirst:= false;
end;

procedure TxOutlineCombo.MakeOutline;
var
  i, Num: Integer;
  S: TStringList;
  sl: String;
begin
  S:= TStringList.Create;
  try
    S.Assign(Lines);
    for i:= 0 to S.Count - 1 do begin
      sl:= S.Strings[i];
      Num:= Pos('+/', sl) + Pos('-/', sl) + Pos('*/', sl);
      if Num > 0 then
        sl:= copy(sl, 1, Num - 1) + copy(sl, Num + 2, length(sl));
      Insert('+/', Sl, Pos('/', Sl) + 3);
      S.Strings[i]:= Sl;
    end;
    FOutlineWindow.Lines:= S;
  finally
    S.Free;
  end;
  CustomBitmap:= FCustomBitmap;
end;

procedure TxOutlineCombo.Loaded;
begin
  inherited Loaded;

  OldShowHint:= ShowHint;
  FOutlineWindow.Width:= Width;
  FOutlineWindow.Height:= OutlineHeight;

  FOutlineWindow.CustomBitmap:= FCustomBitmap;
  FOutlineWindow.OnGetBitmap:= FOnGetBitmap;
  FOutlineWindow.SetItemHeight;

  MakeOutline;
end;

{ Registration -------------------------------------------}

{$IFNDEF xTool} {$I xLic.Inc} {$ENDIF}

procedure Register;
begin
  {$IFNDEF xTool} Check('TxOutline'); {$ENDIF}
  RegisterComponents('xTool', [TxOutline]);

  {$IFNDEF xTool} Check('TxOutlineCombo'); {$ENDIF}
  RegisterComponents('xTool', [TxOutlineCombo]);
end;

end.
