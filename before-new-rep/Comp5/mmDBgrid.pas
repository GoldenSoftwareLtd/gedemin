
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

    Beta24   31-07-99  andreik ��������� ����������� �������� ������� ��������.
    Beta25   01-08-99  andreik ��������� ������� ������������� ������ ��������.

    Beta26   31-03-99  Dennis  coPos added. Some other things changed.

    Beta27   12-10-99  Denis   Delphi5 incompatability fixed.
    Beta28   20-10-99  andreik Minor bug fixed.

    Beta29   07-02-00  dennis  Sorting event included. Filters removed.

 Additional Information:

    1. ���� ������������ ����������� ����� ������ �������� ������� "�� ���������", ��
    ��� ���������� �������� �� � ��������������� ������ Conditions � ������� ���������
    PrepareConditions, ������� ���������� ���������� ������� � ������.
    2. ��� ���������� ������ ������ ���������� �������� ����� �� ������ ���������
    ��������!
--}

unit mmDBGrid;

{ TODO 2 -oAndreik -cerror : ���� � ������� �������� �� ������ ������ ������! }

interface

uses
  Windows,        Messages,       SysUtils,       Classes,        Graphics,
  Controls,       Forms,          Dialogs,        Grids,          DBGrids,
  Menus,          StdCtrls,       mBitButton,     ExList,         DB,
  xCalc,          mmDBSearch;

// ��������� �� ��, ��� ���� ����� ���� ��������� ��� ������ ��� ��� ���������
type
  TPopupMenuKind = (pmkSubMenu, pmkItemMenu);

// ��������� �� ���������.
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

// ���� �������� ��������� �������������.
type
  TConditionOperation = (
                         coEqual, coNonEqual, coIn, coOut, coBigger, coSmaller,
                         coBiggerEqual, coSmallerEqual, coPos
                         );

type
  TCheckField = class
  private
    FChecks: TStringList; // ������ ��������� ���������
    FCheckField, FShowField: String; // ����, � ������� ������������ ������

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
    FColor: TColor; // ���� �������
    FUseColor: Boolean; // ������������ �� ���� ��� �������

    FFont: TFont; // ����� �������
    FOperation: TConditionOperation; // ��� ��������� ��������������
    FUseFont: Boolean; // ������������ �� ���� ��� �������

    FCondition1: String; // �������
    FCondition2: String; // �������
    FFieldName: String; // ������������ ����
    FDisplayFields: TStringList; // ������ ����� ����������� ��������� ��������������
    FFormula: Boolean; // ������������ �� �������

    procedure SetFont(const Value: TFont);

  public
    TypedCompare: Boolean; // ���� ��������� �������� �� ������ �� �����
    DoubleValue1, DoubleValue2: Double; // ������ � �������� ����

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
    FMinWidth, FMaxWidth: Integer; // �����������, ������������ ������ ������� � ��������
    FScaled: Boolean; // ��������� �� ������������ �������
    FFieldName: String; // ��� ����, �������� ������������� ������ �������

  public
    constructor Create;

    property MinWidth: Integer read FMinWidth write FMinWidth;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth;
    property Scaled: Boolean read FScaled write FScaled;
    property FieldName: String read FFieldName write FFieldName;

  end;

  //////////////////////////////////////////
  // �������, �� �������� ������������ �����
  // ������������ ��������� ����������

type
  TmmDBGridSortEvent = function
  (
    Sender: TObject; // TmmDBGrid, � ������� ������������� ����������
    SortField: TField; // TField - ����, �� �������� ������������� ����������
    var SortFieldText: String // ��� ����, ������� ����������� � ���������� (����� ��������)
  ): Boolean of object; // True, ���� ����� ������ ����������� � ORDER BY
  TmmDBGridOnCheck = procedure(const Index: String; const State: Boolean) of object;
type
  TmmDBGrid = class(TDBGrid)
  private
    FStripeTwo: TColor; // ���� ������ ������
    FStripeOne: TColor; // ���� ������ ������
    FStriped: Boolean; // ����� �����������
    FColorSelected: TColor; // ���� ���������� ������
    FPopupMenu: TPopupMenu; // ����������� PopupMenu � ����������� ���� ������������
    FPopupMenuKind: TPopupMenuKind; // ��� ����������� ���� � ����� ����
    FScaleColumns: Boolean; // ������������ �� ��������������� ������� ��� ���?
    FMinColWidth: Integer; // ����������� ������ ������� �� ���������
    FColorDialogs: TColor; // ���� ������� ��������� �������� �������
    FConditionalFormatting: Boolean; // ������������ �� �������� ��������������
    FConditions: TExList; // ������� ��������������
    FFieldOptions: TExList; // ������ ��������� ��� ������� �������
    FLineCount: Integer; // ���-�� ����� � ����� �������
    FLineFields: TStringList; // ������ ����� �� ����...
    FShowLines: Boolean; // ���������� �� ������������� �����

    FShowCheckBoxes: Boolean; // ���������� �� Checkbox-� ��� ���
    FCheckFields: TStringList; // ������ �����, �� ������� ����� ������������ CheckBox-�
    FChecks: TExList; // ������ �������� �� ����� � CheckBox-���

    FSearch: TmmDBSearch; // ���������� ������

    FGlyphChecked: TBitmap; // ������� ���������� CheckBox-�
    FGlyphUnChecked: TBitmap; // ������� �� ���������� CheckBox-�

    FUltraChanges: Boolean; // ����������� ���������� ����������, ���� �� ��������� � ���-�� ����������
    FFoCal: TxFoCal; // ���������� ������� ������

    FUseSorting: Boolean; // ������������ ��������� ��� ���

    FOnReadDefaults: TNotifyEvent; // Event ���������� ��������� ���������
    FSortEvent: TmmDBGridSortEvent; // ������� �������� ����������

    FOnCheck: TmmDBGridOnCheck; // ������� �� Check

    FontDlg: TFontDialog; // ������ ������ ������
    ColorDlg: TColorDialog; // ������ ������ �����

    PopupColumn: TColumn; // �������, �� ������� ����� ������������ ���������.
    OldOnPopup: TNotifyEvent; // Event OnPopup ������������
    OldOnColumnMoved: TMovedEvent; // Event �� ����������� ������� ������������
    OldColumnsCount: Integer; // ������ ����� �������

    OldColWidth: Integer; // ����� �������
    CurrLine: Integer; // ������� ����� ����� ���������
    CurrResting: Integer; // � ����� ������� ������ ���������� ����������
    RestingKind: Boolean; // True - ����������, False - ����������
    CanUpdateScale: Boolean; // ����� �� ������ ������� �������

    ShowingLines: TStringList; // ������������ �����

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

    // ������������ � ������. ��������� ������� �� ����������� ������ ��� ���������
    // ������ ��� �����������
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

    // ������ ������� ��������� ��������������.
    property Conditions: TExList read FConditions;
    // ������ ��������� ��� �������
    property FieldOptions: TExList read FFieldOptions;
    // ������ ��������� �� �������� ����
    property ShowChecksByName[AField: String]: TStringList read GetShowChecksByName;
    // ���� ������ �� ������������� ���� (��� CheckBox-��)
    property CheckFieldByShowField[AField: String]: String read GetCheckFieldByShowField;
    // ����������, ���� �� �������� ������������� ��������� (������. ������., ���. �������.)
    property UltraChanges: Boolean read FUltraChanges write FUltraChanges;

  published
    // ���� ������ ������
    property StripeOne: TColor read FStripeOne write SetStripeOne default DefStripeOne;
    // ���� ������ ������
    property StripeTwo: TColor read FStripeTwo write SetStripeTwo default DefStripeTwo;
    // ������������ �� ����� ��������� ������� ��� ���
    property Striped: Boolean read FStriped write SetStriped default DefStriped;
    // ���� ���������� ������ �������
    property ColorSelected: TColor read FColorSelected write SetColorSelected default DefColorSelected;
    // ������� PopupMenu
    property PopupMenu: TPopupMenu read GetPopup write SetPopup;
    // ��� ����������� ��������� ���� � ����� ����.
    property PopupMenuKind: TPopupMenuKind read FPopupMenuKind write SetPopupMenuKind default DefPopupMenuKind;
    // ������������ �� ��������������� ������� ��� ���.
    property ScaleColumns: Boolean read FScaleColumns write SetScaleColumns default DefScaleColumns;
    // ����������� ������ ������� �� ���������
    property MinColWidth: Integer read FMinColWidth write FMinColWidth default DefMinColWidth;
    // ���-��, ������� � ������, ������� �������� ���� ������
    property ColorDialogs: TColor read FColorDialogs write FColorDialogs default DefColorDialogs;
    // ������������ �� �������� ��������������?
    property ConditionalFormatting: Boolean read FConditionalFormatting write SetConditionalFormatting default DefConditionalFormatting;
    // ���-�� ������� � ����� ������
    property LineCount: Integer read FLineCount write SetLineCount;
    // ������ ����� �� ����
    property LineFields: TStringList read FLineFields write SetLineFields;
    // ���������� �� �������������� �����
    property ShowLines: Boolean read FShowLines write SetShowLines;
    // ���������� �� � ������� CheckBox-� ��� ���
    property ShowCheckBoxes: Boolean read FShowCheckBoxes write SetShowCheckBoxes;
    // ������ �����, �� ������� ����� ������������ CheckBox-�
    property CheckFields: TStringList read FCheckFields write SetCheckFields;
    // ������� ���������� CheckBox-�
    property GlyphChecked: TBitmap read FGlyphChecked write SetGlyphChecked;
    // ������� �� ���������� CheckBox-�
    property GlyphUnChecked: TBitmap read FGlyphUnChecked write SetGlyphUnChecked;
    // ������������ ���������� ��� ���
    property UseSorting: Boolean read FUseSorting write SetUseSorting;
    // Event ���������� ��������� ��������� ����� mmRunTimeStore
    property OnReadDefaults: TNotifyEvent read FOnReadDefaults write FOnReadDefaults;
    // ������� �������� ����������
    property SortEvent: TmmDBGridSortEvent read FSortEvent write FSortEvent;

    property OnCheck: TmmDBGridOnCheck read FOnCheck write FOnCheck;
  end;

{
  ��������� ��� ������ � ��������
  ���������������.
}

const
  ConditionText: array[TConditionOperation] of String =
    (
     '�����', '�� �����', '�����', '���', '������',
     '������', '������ ��� �����', '������ ��� �����',
     '��������'
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

// ��������� �������� �������� CheckBox-��
const
  CheckBoxWidth = 13;
  CheckBoxHeight = 13;

  SQL_ORDERBY = 'ORDER BY';
  SQL_DESC = 'DESC';
  SQL_DESCENDING = 'DESCENDING';
  SQL_ASC = 'ASC';
  SQL_ASCENDING = 'ASCENDING';

const
  mmdbg_UserCount: Integer = 0; // ���-�� ���������, ��������� � ��������� � ������ ������
  TAG_ADDITIONALMENU = 1234567890; // ����������� ������������� ��� ����������� ����� ��������� ����.

var
  DrawBitmap: TBitmap = nil; // ������������ �� WriteText.

{
  -----------------------------------------------
  ---                                         ---
  ---   Additional functions and procedures   ---
  ---                                         ---
  -----------------------------------------------
}

{
  ������ �� ����� � Rect
}

function IsInRect(R: TRect; X, Y: Integer): Boolean;
begin
  Result := (X >= R.Left) and (X <= R.Right) and (Y >= R.Top) and (Y <= R.Bottom);
end;

{
  ������������ ����� �� ��������� ���������� ��������.
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
  Borland-������ ������� �� ��������� ������. ����� �� DBGrids.pas.
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

  //  ����� �� ����� ������?
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
  ������ ��������� ���������.
}

constructor TCheckField.Create(ACheckField, AShowField: String);
begin
  FChecks := TStringList.Create;
  FCheckField := ACheckField;
  FShowField := AShowField;
end;

{
  ������������ ������.
}

destructor TCheckField.Destroy;
begin
  FChecks.Free;
  
  inherited Destroy;
end;

{
  ���������� ����� ���������� �������� � ������.
}

function TCheckField.FindCheck(ACheck: String; var Index: Integer): Boolean;
begin
  Index := FChecks.IndexOf(ACheck);
  Result := (Index >= 0);
end;

{
  ��������� ������.
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
  ������ ��������� ���������.
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
  ������ ��������� ���������.
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
  ������������ ������.
}

destructor TCondition.Destroy;
begin
  FFont.Free;
  FDisplayFields.Free;

  inherited Destroy;
end;

{
  ���������� ����� �� ����� ����� ������.
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
  ������������� ����� �������.
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
  ������� ����������, ������������ ��������� ���������.
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

  // ��������� ������� ����������� Checkbox-�
  FGlyphChecked := TBitmap.Create;
  LoadCheckBoxBitmap(FGlyphChecked, TRUE);

  // ��������� ������� �� ����������� Checkbox-�
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

  // � ����� ������ ������� bitmap ��� ��������� ������ � �������
  if mmdbg_UserCount = 0 then
    DrawBitmap := TBitmap.Create;

  Inc(mmdbg_UserCount);
end;

{
  ������� �� ������ ����������, �������� �������� ���������.
}

destructor TmmDBGrid.Destroy;
begin
  // ���������� �������� ������������� ������ ����������.
  // � ����� ������ ������� bitmap ��� �������� ������

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
  ������������� ������� ����. ����� ���� �������� �������� ������� �
  �� ���������.
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

  // ���������� ����� ���������� ������� �������
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

  // ���������� ����� ���� ��� ������� ��������������� �������.
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

  // �������� ��������� ������� ��� ���������� (����������) ��������
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
  // ���������� �������� ��� �������� ������� ���������� � ����� �������
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

  // ���������� ���������
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
      // �������� ��������� ��� ������ �������
      if i >= ColCount then Break;
      CurrOption := FindFieldOption(Columns[I].FieldName);

      // ���� ��������� ����������
      if CurrOption <> nil then
      begin
        // ���� ������� ������ �����������, �� ���������� ��
        if not CurrOption.FScaled then
          Continue;

        // ������������� ����������� � ������������ �������
        MinWidth := CountWidthByChar(Canvas, Self, CurrOption.MinWidth, Columns[I].Font);
        MaxWidth := CountWidthByChar(Canvas, Self, CurrOption.MaxWidth, Columns[I].Font);

        if MinWidth < FMinColWidth then MinWidth := FMinColWidth;
      end else begin // ���� �� ���
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

    // ���������� �����
    Rest := ScaleClientWidth - GetScaleGridWidth;

    AllreadyRested := 0;

    while Rest <> 0 do
    begin
      if CurrResting >= Columns.Count - 1 then
        CurrResting := 0
      else
        Inc(CurrResting);

      // ���� ������ �������� �� � ��� �� ���������� ������, �� �������
      if (CurrResting < 0) or (AllreadyRested >= Columns.Count) then
      begin
        CanUpdateScale := True;
        Exit;
      end;

      Inc(AllreadyRested);

      CurrOption := FindFieldOption(Columns[CurrResting].FieldName);

      // ���� ��������� ����������
      if CurrOption <> nil then
      begin
        // ���� ������� ������ �����������, �� ���������� ��
        if not CurrOption.FScaled then Continue;

        // ������������� ����������� � ������������ �������
        MinWidth := CountWidthByChar(Canvas, Self, CurrOption.MinWidth, Columns[CurrResting].Font);
        MaxWidth := CountWidthByChar(Canvas, Self, CurrOption.MaxWidth, Columns[CurrResting].Font);

        if MinWidth < FMinColWidth then MinWidth := FMinColWidth;
      end else begin // ���� �� ���
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
  ���������� �������� �� ������ ���������� ������� �� ���������
  ��������.
}

procedure TmmDbGrid.PrepareConditions;
var
  I: Integer;
  CurrCondition: TCondition;

  // ���������� �������� ����� ������.
  // ���� False, �� ������� ������
  function CheckValue(S: String; T: TFieldType; var Value: Double): Boolean;
  var
    D: Double;
    K: Integer;

    // ����������� ���� ������ ��������
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

    // ���� �����
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
    // ���� ���� � (���) �����
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

  // ���������� ������� ����������� ��������� �� ����
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
  ���������� �������� ����� ����������� ������� ���� �� FromMenu.
}

procedure TmmDBGrid.DeletePopupSettings(FromMenu: TMenuItem);
var
  I: Integer;
begin
  for I := FromMenu.Count - 1 downto 0 do
    if FromMenu.Items[I].Tag = TAG_ADDITIONALMENU then FromMenu.Delete(I);
end;

{
  ��������� Check � ������.
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
  ������� Check �� ������.
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
  ���������� �������� �������!
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
  ���������� ����������� DisplayLabel � FieldName.
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
  ���������� ����������� FieldName � DisplayLabel.
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
  ���������� ��������� �� ���������� ������.
}

function TmmDBGrid.GetSearch: TmmDBSearch;
begin
  Result := FSearch;
end;

{
  ����� �� �������� ��� �����������
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
  ���������� ����������� ������ �������.
}

procedure TmmDBGrid.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  OldActive: LongInt; // ����������� � �� � �������
  HighLight: Boolean; // ���� ��������� ������� �������
  Value: string; // ��������, ������� ����� ����������
  DrawColumn: TColumn; // ������� �������, � ������� ������������ ���������
  CheckMoveBy: Integer; // ����� ������ ��� ��������� CheckBox-��.
  CheckField: TCheckField; // ������ ������ ���������� CheckBox-��
  OldBrushColor, OldPenColor: TColor;
  Fmt, Fld: String;
  IsASC: Boolean;
  K: Integer;
  Checked: Boolean;

  // ���������� ��������� ������� ����� ����������.
  function MakeConditionSettings(CheckField: TField): Boolean;
  var
    I: Integer;
    CurrCondition: TCondition;
    ConditionField: TField;

    // �������� �� ������� ������� �����������.
    function IsConditionFulFilled: Boolean;
    begin
      Result := False;

      // ���� ���� ��������� �� ���� ������
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
      // ���� ���� ��������� �����
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

      // ���������� ����� ������������ ����
      if CurrCondition.DisplayFields.IndexOf(CheckField.FieldName) >= 0 then
      begin
        ConditionField := DataLink.DataSet.FindField(CurrCondition.FieldName);

        // ���� ��� ���������� ���� ������� �����������, �� ����������
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

  // ������ CheckBox.
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
  // ���� �� ������� ����� ����������� ��� �� ������������� ������, �� �� ���������
  // �������� �������� ������ ����������.
  if gdFixed in AState then
  begin
    inherited DrawCell(ACol, ARow, ARect, AState);

    // �������� �������, � ������� ����� ��������
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

    // ���������� ����������� ����������
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
  // � ������ ������ ��������� ���������� ��������������
  end else with Canvas do
  begin
    // ������ ��� ��� ���� � �������� Borland International �� ���������� DBGrid,
    // �� ������������ � ���� ���� ������� ���������.
    DrawColumn := Columns[ACol - Integer(dgIndicator in Options)];

    // ������������� ����� � ����
    Font := DrawColumn.Font;
    Brush.Color := DrawColumn.Color;

    CheckMoveBy := 0;

    // ���� ������ ���, �� ������ ������� �������������
    if (DataLink = nil) or not DataLink.Active then
    begin
      FillRect(ARect);
    // � ������ ������ ���������� ���������� ������
    end else begin
      // ������������� ��������� � ���� ������ �� ����������� ������ ���
      // ��������� ������
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

        // ������������� ������������� ��������� ������ ������ ����������
        Highlight := HighlightCell(ACol, ARow, Value, AState);

        // ������������� ���� ��� ��������� ������
        if Highlight then
          Brush.Color := FColorSelected
        else begin
          // �������� ���� ������� ������ � �������
          if FStriped then
          begin
            if (ARow mod 2) = 0 then
              Brush.Color := FStripeTwo
            else
              Brush.Color := FStripeOne;
          end;

        end;

        // ���������� �������� �� �������� ��������������.
        if FConditionalFormatting then MakeConditionSettings(DrawColumn.Field);

        // ������ �����
        if DefaultDrawing then
        begin
          CheckField := nil;
          Checked := False;

          // ���� ������� ���������� CheckBox-�
          if FShowCheckBoxes then
          begin
            CheckField := GetCheckFieldByName(FChecks, DrawColumn.FieldName);

            // ���� ���� � CheckBox-��� �������
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

          // � ���� ����� ������������ ����� ������ � ����� �� TreeMoveBy.
          // ��� ������� ����������� ��� ������, ���������� �� ������ �������,
          // � ������� ����� ���������� ������ (�.�. mmDBGridTree)!
          WriteText(Self.Canvas, ARect, 2 + GetTreeMoveBy(True, False, nil) + CheckMoveBy, 2, Value, DrawColumn.Alignment,
            UseRightToLeftAlignmentForField(DrawColumn.Field, DrawColumn.Alignment));

          // ������ CheckBox-�
          if FShowCheckBoxes and (CheckField <> nil) then
            if Checked then
              DrawCheck(FGlyphChecked, Rect(ARect.Left + 2 + GetTreeMoveBy(True, False, nil), ARect.Top,
                ARect.Right, ARect.Top + (ARect.Bottom - ARect.Top) div CurrLineCount))
            else
              DrawCheck(FGlyphUnChecked, Rect(ARect.Left + 2 + GetTreeMoveBy(True, False, nil), ARect.Top, ARect.Right,
                ARect.Top + (ARect.Bottom - ARect.Top) div CurrLineCount));

          // ���� ���������� ���������� �����, �� ���������� �� �����������
          if FShowLines and GetDetailLines(DrawColumn.FieldName, ShowingLines) then
          begin
            // ������� ������, �.�. �� �� �����
            if (ShowingLines.Count > 0) and (Pos('format ', ShowingLines[0]) > 0) then
              ShowingLines.Delete(0);

            for K := 0 to ShowingLines.Count - 1 do
            begin
              // ���������� ������ �������� ����

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

      // ������ Focus
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
  �� ���������� ���������� ����������� ������.
}

procedure TmmDBGrid.Scroll(Distance: Integer);
begin
  inherited Scroll(Distance);
  if FStriped and (Distance <> 0) then Invalidate;
end;

{
  ����� ��������� �������� ���� ������� ���������� ���� ���������.
}

procedure TmmDBGrid.Loaded;
begin
  inherited Loaded;

  // ������ ��������� ���������� ������ � ������ ������� ���������
  if not (csDesigning in ComponentState) then
  begin
    OldOnColumnMoved := OnColumnMoved;
    OnColumnMoved := DoOnColumnMoved;

    CanUpdateScale := True;

    // ���� ���� �� ���������.
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
  �� ������� ������ ���� ���������� ���� ��������.
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

  // ���� ������ ����� ������ ����.
  if Button = mbLeft then
  begin
    // �������� ���������� ������� � �������, rectangle ������, ����
    C := MouseCoord(X, Y);
    R := CellRect(C.X, C.Y);
    F := GetColField(C.X - Integer(dgIndicator in Options));

    // ���� ������� ����� ������ CheckBox-��
    if FShowCheckBoxes and (F <> nil) and (C.Y - Integer(dgTitles in Options) >= 0) then
    begin
      CheckField := GetCheckFieldByName(FChecks, F.FieldName);

      // ���� ���������� CheckBox ������ �� ������� ����
      if CheckField <> nil then
      begin
        // �������� ����������� ������ ��� ������������ ��������� CheckBox-�
        OldActive := DataLink.ActiveRecord;
        try
          DataLink.ActiveRecord := C.Y - Integer(dgTitles in Options);

          // ������ ��������� CheckBox-�
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
          // ���������� ������ �� ����� ������������� ������
          DataLink.ActiveRecord := OldActive;
        end;

        if not IsInRect(R, X, Y) then CheckField := nil;
      end;
    end;
  end;

  inherited MouseDown(Button, Shift, X, Y);

  // ���� ����� ����������� CheckBox-�� � ������� ���� ��� CheckBox-��
  if FShowCheckBoxes and (CheckField <> nil) then
  begin
    HideEditor;

    // ��������� ���� ������� ������ �� ������
    if Checked then
      DoOnDeleteCheck(CheckField, Index)
    else begin
      DoOnAddCheck(CheckField, DataLink.DataSet.FieldByName(CheckField.CheckField).AsString);
    end;

    InvalidateCell(Col, Row);
  end;

  // ���������, ����������� ��� ������������
  if (CurrLine >= 0) and (CurrLine <= ColCount - 1) and not
    (csDesigning in ComponentState)
  then
    OldColWidth := ColWidths[CurrLine];
end;

{
  ������� ������� ����! ���������� ��������� ������ �������.
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
        // ���� ���� ������� � �� ��� ����!
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

          // ���� ������ ������, ��� ������ ��������, �� ����� ������ ��������
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
  �� ��������� �������� ������� ���������� ���� ��������.
}

procedure TmmDBGrid.ColWidthsChanged;
var
  MinWidth, MaxWidth: Integer;
  CurrWidth, NextWidth: Integer;
  NextMinWidth, NextMaxWidth: Integer;
  CurrOption, NextOption: TFieldOption;
begin
  // �������� �������� ���� ������ ����� �������� ����� ����������
  if (DataLink <> nil) and (DataLink.Active) and CanUpdateScale and not
    (csDesigning in ComponentState) then
  begin
    // ���� ����������� ���������� �������������� �������� (TQuery),
    // �������������, ������ ��� �������.
    if CurrLine < 0 then
    begin
      inherited ColWidthsChanged;
      if FScaleColumns then SetBounds(Left, Top, Width, Height);
      Exit;
    // ��� ������������ ��������� ��������� ��������� �������
    end else if FScaleColumns and (CurrLine = ColCount - 1) then
    begin
      ColWidths[CurrLine] := OldColWidth;
      inherited ColWidthsChanged;
      Exit;
    end;

    // �������� ��������� ��� ������ �������
    CurrOption := FindFieldOption(Columns[CurrLine - Integer(dgIndicator in Options)].FieldName);
    // �������� ��������� ��� ��������� �������

    if FScaleColumns then
      NextOption := FindFieldOption(Columns[CurrLine + 1 - Integer(dgIndicator in Options)].FieldName)
    else
      NextOption := nil;

    // ���� ���������� ��� ������ ������� ���������
    if CurrOption <> nil then
    begin
      // ���� ������� ������ �����������, �� ���������� ��
      if not CurrOption.FScaled then
      begin
        ColWidths[CurrLine] := OldColWidth;
        inherited ColWidthsChanged;
        Exit;
      end;

      // ������������� ����������� � ������������ �������
      MinWidth := CountWidthByChar(Canvas, Self, CurrOption.MinWidth,
        Columns[CurrLine - Integer(dgIndicator in Options)].Font);
      MaxWidth := CountWidthByChar(Canvas, Self, CurrOption.MaxWidth,
        Columns[CurrLine - Integer(dgIndicator in Options)].Font);

      if MinWidth < FMinColWidth then MinWidth := FMinColWidth;
    end else begin // ���� �� ���
      MinWidth := FMinColWidth;
      MaxWidth := -1;
    end;

    // ���� ���������� ��� ��������� ������� ���������
    if NextOption <> nil then
    begin
      // ���� ������� ������ �����������, �� ���������� ��
      if not NextOption.FScaled then
      begin
        ColWidths[CurrLine] := OldColWidth;
        inherited ColWidthsChanged;
        Exit;
      end;

      // ������������� ����������� � ������������ �������
      NextMinWidth := CountWidthByChar(Canvas, Self, NextOption.MinWidth,
        Columns[CurrLine - Integer(dgIndicator in Options)].Font);
      NextMaxWidth := CountWidthByChar(Canvas, Self, NextOption.MaxWidth,
        Columns[CurrLine - Integer(dgIndicator in Options)].Font);

      if NextMinWidth < FMinColWidth then NextMinWidth := FMinColWidth;
    end else begin // ���� �� ���
      NextMinWidth := FMinColWidth;
      NextMaxWidth := -1;
    end;

    // ��������� �������� ��������� �������� �������
    CanUpdateScale := False;

    // ������������� �������������� ������� ������� � ��������� �������
    CurrWidth := ColWidths[CurrLine];
    if FScaleColumns then
      NextWidth := ColWidths[CurrLine + 1]
    else
      NextWidth := -1;


    // ���� ������� ������ ������������� �������
    if (CurrWidth > MaxWidth) and (MaxWidth <> -1) then
    begin
      if FScaleColumns then NextWidth := NextWidth - (MaxWidth - OldColWidth);
      CurrWidth := MaxWidth;
    // ���� ������� ������ ������������ �������
    end else if CurrWidth < MinWidth then
    begin
      if FScaleColumns then NextWidth := NextWidth - (MinWidth - OldColWidth);
      CurrWidth := MinWidth;
    end else
      NextWidth := NextWidth + OldColWidth - CurrWidth;

    if ((dgIndicator in Options) and (CurrLine <> 0)) or
      not (dgIndicator in Options)
    then
      // ���� ��������� ������� ������ ������������� �������
      if FScaleColumns and (NextWidth > NextMaxWidth) and (NextMaxWidth <> -1) then
      begin
        CurrWidth := CurrWidth + (NextWidth - NextMaxWidth);
        NextWidth := NextWidth - (NextWidth - NextMaxWidth);
      // ���� ��������� ������� ������ ������������ �������
      end else if FScaleColumns and (NextWidth < NextMinWidth) then
      begin
        CurrWidth := CurrWidth - (NextMinWidth - NextWidth);
        NextWidth := NextWidth + (NextMinWidth - NextWidth);
      end;

    ColWidths[CurrLine] := CurrWidth;
    if FScaleColumns then ColWidths[CurrLine + 1] := NextWidth;

    // ��������� �������� ��������� �������� �������
    CanUpdateScale := True;
  end;

  inherited ColWidthsChanged;

  OldColumnsCount := Columns.Count;
end;

{
  �� ��������� ������� ������ ������ ���������� �������� �� ��������������.
}

procedure TmmDBGrid.RowHeightsChanged;
var
  OldHeight: Integer;
begin
  if FShowLines then
  begin
    // ��������� ������ ��������
    if dgTitles in Options then
      OldHeight := RowHeights[0]
    else
      OldHeight := 0;

    // ������������� ���� ������
    if DefaultRowHeight <> GetDefaultRowHeight * FLineCount then
    begin
      DefaultRowHeight := GetDefaultRowHeight * FLineCount;
      if dgTitles in Options then RowHeights[0] := OldHeight;
    end;
  end; 

  inherited RowHeightsChanged;
end;

{
  ������������ ����� ������� ������������ ����� ����������.
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
  ��������������� �������� �������.
}

procedure TmmDBGrid.SetColumnAttributes;
begin
  inherited SetColumnAttributes;

  LineCount := GetMaxLineCount;

  // ���� ������������ �������� ������ �� ����� Visible = False, �� ����������
  // ���������� ���������� ��������.
  if Columns.Count < OldColumnsCount then SetBounds(Left, Top, Width, Height);
end;

{
  �� �������� �������� ���������� ���� ��������.
}

procedure TmmDBGrid.LinkActive(Value: Boolean);
var
  OldScaleColumns: Boolean;
begin
  OldScaleColumns := FScaleColumns;
  FScaleColumns := False;

  inherited LinkActive(Value);

  ScaleColumns := OldScaleColumns;

  // ������� ������ ��� ����������� CheckBox-��
  if Value and FShowCheckBoxes and (FChecks.Count = 0) then CreateCheckData;
end;

{
  ���������� ������� ���������� ����� �� �������
}

function TmmDBGrid.CurrLineCount: Integer;
begin
  if FShowLines then
    Result := FLineCount
  else
    Result := 1;
end;

{
  ���������� ����� ����� ��� ������ (TmmDBGridTree).
}

function TmmDBGrid.GetTreeMoveBy(WhileDrawing: Boolean; CheckField: Boolean; F: TField): Integer;
begin
  Result := 0;
end;

{
  ���������� ���������� ���� ������.
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
  ������ �����-���� �������� ����� ���������� ������ ��������.
}

procedure TmmDBGrid.DoOnAddCheck(C: TCheckField; S: String);
begin
  C.AddCheck(S);
  if Assigned(FOnCheck) then
    FOnCheck(S, True);
end;

{
  ���������� �������� ��������.
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
  ���������� ����� ���������.
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
  ������������� ���� ������ ������.
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
  ������������� ���� ������ ������.
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
  ������������� ���� ��������� ��������� ����� � �������.
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
  ������������� ���� ���������� ������ �������.
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
  ������������� PopupMenu.
}

procedure TmmDBGrid.SetPopup(const Value: TPopupMenu);
begin
  // ���� ������������� ����� ��������.
  if Assigned(Value) then
  begin
    // ���� ���� ������� ����������� ����, �� ��� ���������� �������.
    if Assigned(FPopupMenu) then
    begin
      FPopupMenu.Free;
      FPopupMenu := nil;
    end;

    inherited PopupMenu := Value;
  end else begin
    // ���� �� ���� ��������� ���������

    if not Assigned(FPopupMenu) then
    begin
      FPopupMenu := TPopupMenu.Create(Self);
      MakePopupSettings(FPopupMenu, False);
    end;

    inherited PopupMenu := FPopupMenu;
  end;
end;

{
  ������������� ��� ����������� ���� � ����� ����.
}

procedure TmmDBGrid.SetPopupMenuKind(const Value: TPopupMenuKind);
begin
  FPopupMenuKind := Value;
end;

{
  ������������ �� ��������������� ������� ��� ���.
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
  ������������ ���� ��������� ��������������.
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
  ������������� ���������� ����� � ����� ������.
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
  ������������ ���� �� ����...
}

procedure TmmDBGrid.SetLineFields(const Value: TStringList);
begin
  FLineFields.Assign(Value);
  LineCount := GetMaxLineCount;
  Invalidate;
end;

{
  ���������� �� �������������� ����� ��� ���.
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
  ������������� ���� ����������� CheckBox-��.
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
  ������������� ����, �� ������� ����� ������������ CheckBox-�.
  ������:
  Key - ���� ���� ������, ������� ����� ��������� � ������
  Name - ���� ����, ��� ����� ������������ CheckBox-�
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
  ������������� ������� CheckBox-� ����������.
}

procedure TmmDBGrid.SetGlyphChecked(const Value: TBitmap);
begin
  if Value <> nil then
    FGlyphChecked.Assign(Value)
  else
    LoadCheckBoxBitmap(FGlyphChecked, TRUE);
end;

{
  ������������ ������� CheckBox-� �� ����������.
}

procedure TmmDBGrid.SetGlyphUnChecked(const Value: TBitmap);
begin
  if Value <> nil then
    FGlyphUnchecked.Assign(Value)
  else
    LoadCheckBoxBitmap(FGlyphUnchecked, FALSE);
end;

{
  ��������������� ���� ������������� ������ ���������� ������������.
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
  ���������� PopupMenu.
}

function TmmDBGrid.GetPopup: TPopupMenu;
begin
  Result := inherited PopupMenu;
end;

{
  ���������� ������ ��������� ��������� �� �������� ���� (��� CheckBox).
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
  ���������� ���� ������ �� ������������� ���� (��� CheckBox-��).
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
  �� ������� ������ ������� ���� ���������� ����������� � ����
  ����������� ���������.
}

procedure TmmDBGrid.WMRButtonDown(var Message: TWMLButtonDown);
var
  C: Integer;
begin
  inherited;

  // ��������� ���������� ��������� �������
  C := MouseCoord(Message.XPos, {Message.YPos}1).X - Integer(dgIndicator in Options);

  if C >= 0 then
    PopupColumn := Columns[C]
  else
    PopupColumn := nil;

  // ���� ������� ���� �� ������� �������, �� �������� � �� ����.
  if (PopupColumn <> nil) and (PopupColumn.PopupMenu <> nil) then
  begin
    OldOnPopup := PopupColumn.PopupMenu.OnPopup;
    PopupColumn.PopupMenu.OnPopup := DoOnPopupMenu;
  // ���� �� ������� �� ���� �� �������, �� �������� � ������� ���� ����������.
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

    // ���� ���������� CheckBox ������ �� ������� ����
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
  �� ����������� ���� ���������� ���� ��������.
}

procedure TmmDBGrid.DoOnPopupMenu(Sender: TObject);
begin
  // ���� ���� �� ��������� �������
  if PopupColumn <> nil then
  begin
    // ���� � ������� ���� ���� ����������� ����
    if PopupColumn.PopupMenu <> nil then
    begin
      // ������� ����� ������������� ����
      DeletePopupSettings(PopupColumn.PopupMenu.Items);
      // ��������� ����� ������ ����
      MakePopupSettings(PopupColumn.PopupMenu, True);

    // ���� �� ��� ���
    end else begin
      // ������� ����� ������������� ����
      DeletePopupSettings(PopupMenu.Items);
      // ��������� ����� ������ ����
      MakePopupSettings(PopupMenu, True);
    end;

  // ���� ���� �����
  end else begin
    // ������� ����� ������������� ����
    DeletePopupSettings(PopupMenu.Items);
    // ��������� ����� ������ ����
    MakePopupSettings(PopupMenu, False);
  end;

  // �������� Event ������������ �����������
  if Assigned(OldOnPopup) then OldOnPopup(Sender);

  // ���������� Event ������������ �������
  if (PopupColumn <> nil) and (PopupColumn.PopupMenu <> nil) then
    PopupColumn.PopupMenu.OnPopup := OldOnPopup
  else
    PopupMenu.OnPopup := OldOnPopup;

  OldOnPopup := nil;
end;

{
  �� ������ ������� "����� �������" ���������� ��������� ������� ������
  ������. ���� ����� ����� �������, �� ����������� ��� � �������.
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
  �� ������ ������� "����� �������� �������" ���������� ��������� ������� ������
  ������. ���� ����� ����� �������, �� ����������� ��� � �������.
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
  �� ������ ������� "�����" ���������� ��������� ������� ������
  ������. ���� ����� ����� �������, �� ����������� ��� � �������.
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
  �� ������ ������� "�����" ���������� ��������� ������� ������
  ������. ���� ����� ����� �������, �� ����������� ��� � �������� �������.
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
  �� ������ ������� "���� �������" ���������� ��������� ������� ������
  �����. ���� ����� ���� �������, �� ����������� ��� � �������.
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
  ������������� ���� ���������� ������.
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
  �� ������ ������� "���� �������� �������" ���������� ��������� ������� ������
  �����. ���� ����� ���� �������, �� ����������� ��� � �������.
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
  �� ������ ������� "����" ���������� ��������� ������� ������
  �����. ���� ����� ���� �������, �� ����������� ��� � ������ �������.
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
  �� ������ ������� "����" ���������� ��������� ������� ������
  �����. ���� ����� ���� �������, �� ����������� ��� � ������ �������� �������.
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
  ������������� ���� ������ ������.
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
  ������������� ���� ������ ������.
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
  �� ������ ������� "������������" � ������ ���������������� ��� ����
  ����������� ��������� � �������.
}

procedure TmmDBGrid.DoOnColAlign(Sender: TObject);
begin
  if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('����������� �� ������')) = 0 then
    PopupColumn.Alignment := taCenter
  else if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('����������� �� ������ ����')) = 0 then
    PopupColumn.Alignment := taLeftJustify
  else if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('����������� �� ������� ����')) = 0 then
    PopupColumn.Alignment := taRightJustify;

  (Sender as TMenuItem).Checked := True;
end;

{
  �� ������ ������� "������������" � ������ ���������������� ��� ����
  ����������� ��������� ��� ����� ������� � �������.
}

procedure TmmDBGrid.DoOnColTitleAlign(Sender: TObject);
begin
  if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('����������� �� ������')) = 0 then
    PopupColumn.Title.Alignment := taCenter
  else if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('����������� �� ������ ����')) = 0 then
    PopupColumn.Title.Alignment := taLeftJustify
  else if AnsiCompareText((Sender as TMenuItem).Caption, TranslateText('����������� �� ������� ����')) = 0 then
    PopupColumn.Title.Alignment := taRightJustify;

  (Sender as TMenuItem).Checked := True;
end;

{
  ������������ ������ ��� ��������� ��� ���?
}

procedure TmmDBGrid.DoOnCheckStriped(Sender: TObject);
begin
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  Striped := (Sender as TMenuItem).Checked;
end;

{
  ������������ �������� �������������� ��� ���.
}

procedure TmmDBGrid.DoOnCheckConditionalFormatting(Sender: TObject);
begin
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  ConditionalFormatting := (Sender as TMenuItem).Checked;
end;

{
  ������������� ��� �������� ������������ �������.
}

procedure TmmDBGrid.DoOnCheckScaleColumns(Sender: TObject);
begin
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  ScaleColumns := (Sender as TMenuItem).Checked;
end;

{
  ���������� �������� �������� ��������.
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
  ���������� ����� ����������� ������� ��� ����������� �����������.
}

procedure TmmDBGrid.DoOnChooseColumns(Sender: TObject);
var
  btnOk, btnCancel: TmBitButton;
  clbFields: TCheckListBox;
  I: Integer;

  // ���������� ����� ������� � Grid-� �� ��������� �� ����.
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
    Caption := TranslateText('������������ �������:');
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
    btnOk.Caption := TranslateText('&������');
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;

    btnCancel := TmBitButton.Create(Self);
    btnCancel.Left := 114;
    btnCancel.Top := 250;
    btnCancel.Width := 100;
    btnCancel.Height := 20;
    btnCancel.Caption := TranslateText('&��������');
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
  ����������� ����� �������������� ������� ��������� � ������ �� �������.
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
  ���������� ��������� ��������� ��������� �������������� ����������
  � ������ ��� �� �������.
}

procedure TmmDBGrid.DoOnShowLines(Sender: TObject);
begin
  (Sender as TMenuItem).Checked := not (Sender as TMenuItem).Checked;
  ShowLines := (Sender as TMenuItem).Checked;
end;

{
  �� ������ ������� ���� "�������� ��������" ����������� ������ �������
  ������ �������� ������� � ����� ������������� � �������.
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
    AskTitle.Caption := TranslateText('�������� �������');
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
    btnOk.Caption := TranslateText('&������');
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;

    btnCancel := TmBitButton.Create(Self);
    btnCancel.Left := 114;
    btnCancel.Top := 30;
    btnCancel.Width := 100;
    btnCancel.Height := 20;
    btnCancel.Caption := TranslateText('&��������');
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
  �� ������������ ������� ���������� ���� ��������.
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
  �������� ������ ��������� ��� ���� �������.
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
  ���������� ���������� ����� ������� � ���� �������� Grid-� ���
  �� � ��������� �������������� ���� Grid-�.
}

procedure TmmDBGrid.MakePopupSettings(MakeMenu: TPopupMenu; WithColumn: Boolean);
var
  Group, Item, CurrItem: TMenuItem;

  // ��������� ������� ������
  function AddItem(S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := S;
    Result.Tag := TAG_ADDITIONALMENU;
    Group.Add(Result);
  end;

  // ��������� ������� � ���������
  function AddSubItem(AGroup: TMenuItem; S: String): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    Result.Caption := S;
    Result.Tag := TAG_ADDITIONALMENU;
    AGroup.Add(Result);
  end;

begin
  if FPopupMenuKind = pmkSubMenu then // ���� ��������� ���������
  begin
    Group := TMenuItem.Create(Self);
    Group.Caption := TranslateText('��������� �������');

    MakeMenu.Items.Add(Group);
  end else begin // ���� ���� ������������ � ����� ������ �������
    Group := MakeMenu.Items;

    // ��������� � ����� ���� ����� ����������, ���� ��� ������� �������������
    if Group.Count <> 0 then
    begin
      Item := TMenuItem.Create(Self);
      Item.Caption := '-';
      Item.Tag := TAG_ADDITIONALMENU;
      Group.Add(Item);
    end;
  end;

  Group.Tag := TAG_ADDITIONALMENU;

  // ���������� ���� ����������� ������� � ����� ����
  AddItem(TranslateText('������ ��������� �������')).OnClick := DoOnTableMaster;

  Item := AddItem(TranslateText('�����'));
  Item.ShortCut := VK_F3;
  Item.OnClick := DoOnSearch;

  AddItem('-');

  // ���������� ���� ����������� ������� � ����� ����
  AddItem(TranslateText('����� �������')).OnClick := DoOnTableFont;
  AddItem(TranslateText('���� �������')).OnClick := DoOnTableColor;
  AddItem(TranslateText('����� ���������')).OnClick := DoOnTableTitleFont;
  AddItem(TranslateText('���� ��������')).OnClick := DoOnTableTitleColor;
  AddItem(TranslateText('���� ���������� ������')).OnClick := DoOnSelectedColor;

  AddItem('-');

  // ���� ��� ������ � �������, �� � ��� ������ ��������� ��������� ����� � ��.
  if (DataLink <> nil) and DataLink.Active then
  begin
    Item := AddItem(TranslateText('������������� �����'));

    CurrItem := AddSubItem(Item, TranslateText('������������'));
    CurrItem.Checked := FStriped;
    CurrItem.OnClick := DoOnCheckStriped;

    CurrItem := AddSubItem(Item, TranslateText('������ ������'));
    CurrItem.OnClick := DoOnFirstStripeColor;
    CurrItem := AddSubItem(Item, TranslateText('������ ������'));
    CurrItem.OnClick := DoOnSecondStripeColor;

    Item := AddItem(TranslateText('�������� ��������������'));
    CurrItem := AddSubItem(Item, TranslateText('������������'));
    CurrItem.Checked := FConditionalFormatting;
    CurrItem.OnClick := DoOnCheckConditionalFormatting;

    AddSubItem(Item, TranslateText('������ �������')).OnClick := DoOnCondition;

    AddItem('-');
    AddItem(TranslateText('������� ������� �������')).OnClick := DoOnChooseColumns;

    // added 31.07.99-01.08.99 by andreik
    AddItem('-');
    AddItem(TranslateText('�������� ������...')).OnClick := DoOnViewDataSource;
    Item := AddItem(TranslateText('�������� ������'));
    Item.OnClick := DoOnReopenDataSet;
    Item.ShortCut := VK_F5;
    AddItem('-');
    // end of added
  end;

  Item := AddItem(TranslateText('����������� �������'));
  Item.Checked := FScaleColumns;
  Item.OnClick := DoOnCheckScaleColumns;

  if LineCount > 1 then
  begin
    Item := AddItem(TranslateText('��������� �����������'));
    Item.Checked := FShowLines;
    Item.OnClick := DoOnShowLines;
  end;

  if WithColumn then
  begin
    // ��������� ������ � ������� �������
    Group := AddItem(TranslateText('��������� �� �������'));
    AddItem(TranslateText('�����')).OnClick := DoOnColFont;

    if not FStriped then
      AddItem(TranslateText('����')).OnClick := DoOnColColor;

    AddItem(TranslateText('�����������')).OnClick := DoOnChooseLines;

    // ��������� ������ � ������� ������������
    Item := Group;
    AddItem('-');

    CurrItem := AddSubItem(Item, TranslateText('����������� �� ������'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColAlign;
    if PopupColumn.Alignment = taCenter then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, TranslateText('����������� �� ������ ����'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColAlign;
    if PopupColumn.Alignment = taLeftJustify then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, TranslateText('����������� �� ������� ����'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColAlign;
    if PopupColumn.Alignment = taRightJustify then CurrItem.Checked := True;

    AddItem('-');

    // ��������� ������ � ������� ���������
    Item := AddItem(TranslateText('��������� �� ��������'));
    AddSubItem(Item, TranslateText('�����')).OnClick := DoOnColTitleFont;
    AddSubItem(Item, TranslateText('����')).OnClick := DoOnColTitleColor;
    AddSubItem(Item, '-');
    AddSubItem(Item, TranslateText('�������� ��������')).OnClick := DoOnNewTitle;

    // ��������� ������ � ������� ������������
    AddSubItem(Item, '-');
    CurrItem := AddSubItem(Item, TranslateText('����������� �� ������'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColTitleAlign;
    if PopupColumn.Title.Alignment = taCenter then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, TranslateText('����������� �� ������ ����'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColTitleAlign;
    if PopupColumn.Title.Alignment = taLeftJustify then CurrItem.Checked := True;

    CurrItem := AddSubItem(Item, TranslateText('����������� �� ������� ����'));
    CurrItem.GroupIndex := 1;
    CurrItem.RadioItem := True;
    CurrItem.OnClick := DoOnColTitleAlign;
    if PopupColumn.Title.Alignment = taRightJustify then CurrItem.Checked := True;
  end;
end;

{
  ��������� ������� CheckBox-��.
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
  ������� ������ ������ ��� CheckBox��.
}

procedure TmmDBGrid.CreateCheckData;
var
  I: Integer;
begin
  // ������� ������ ������
  for I := 0 to FChecks.Count - 1 do FChecks.Delete(0);

  // ������� ������ ������
  for I := FCheckFields.Count - 1 downto 0 do
    if FCheckFields[I] = '' then FCheckFields.Delete(I);

  // ������� ����� ������
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
  ���������� ����� ����������� ��������� ��� ���� �� ��� ��������.
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
  ���������� ���������� �������������� ������� ������ �� ������������ �������.
  ������:

  field Name - ������� �������� ����, �� �������� ���� �������������� ������
  ���: %s - ����� ������� ��������������� �����
  price - ������ ���� �������������� ������
  quatity - ������ ���� �������������� ������

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
        // ��������� ������, ���� �� ����
        if (K < FLineFields.Count - 1) and (Pos('%s', FLineFields[K + 1]) > 0) then
          FoundLines[FoundLines.Count - 1] := FoundLines[FoundLines.Count - 1] + ' ' + FLineFields[K + 1];
      end else if Pos('field ', FLineFields[K]) > 0 then
        Break;
  end;
end;

{
  ���������� ������ �������� ����.
}

function TmmDBGrid.GetDetailField(AField: String; var FieldFormat: String): Boolean;
var
  I, K: Integer;
begin
  Result := False;
  I := FLineFields.IndexOf('field ' + AField);

  // ���� �� ��������� ������
  if (I >= 0) and (I + 1 < FLineFields.Count) then
  begin
    K := Pos('format ', FLineFields[I + 1]);

    // ���� ������� ����� "format"
    if K > 0 then
    begin
      FieldFormat := Copy(FLineFields[I + 1], K + 7, Length(FLineFields[I + 1]));
      Result := Pos('%s', FieldFormat) > 0;
    end;
  end;
end;

{
  ������������� ��������� ����������� � ������.
}

procedure TmmDBGrid.SetDetailLines(AField: String; Details: TStringList);
var
  I: Integer;

  // ������� ������ ������
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
  ���������� ������������ ���������� �����.
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
  ������ ������ �� ���������.
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
  ���������� ���������� ����������.
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

// ������� ������� �������
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

// ������� ������� ����� � ����� � �������
function CutBackSpaces(T: String): String;
var
  I: Integer;
begin
  I := Length(T);
  while (I > 1) and (T[I] in [' ', ',', ';']) do Dec(I);
  Result := Copy(T, 1, I);
end;

// ������� ��� #13#10 ����� ORDER BY
function DeleteAllWordWraps(T: String): String;
var
  L, N: Integer;
  O: String;
begin
  Result := T;

  // �������� ����� � ORDER BY
  N := AnsiPos(SQL_ORDERBY, T);
  if N > 0 then
    O := Copy(T, N, Length(T))
  else
    Exit;

  // ������� ��������
  repeat
    L := AnsiPos(#13#10, O);

    if L > 0 then
      O := Copy(O, 1, L - 1) + Copy(O, L + 2, Length(O));
  until L = 0;

  Result := Copy(T, 1, N - 2) + O;
end;

// ������� " ,"
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
  ��������� �� �������� ������� ���� � ������, ���������� ORDER BY.
}

function TmmDBGrid.IsFieldInOrderBy(F: String; var ASC: boolean): Boolean;
var
  I: Integer;
  S: String;

  // ���������� ���� ����� � ����
  function CopyNextWord(T: String): String;
  var
    K, L: Integer;
  begin
    Result := '';

    // ����������� �� ��������
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
  ��������� ���������� � SQL.
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
  // �������� ���������, ���� ������ ���� � ��������, � �� � ��������

{$IFDEF MMDBGRID_IBEXPRESS}
  if (DataSource = nil) or (DataSource.DataSet = nil) or not (DataSource.DataSet is TIBQuery) then Exit;
{$ELSE}
  if (DataSource = nil) or (DataSource.DataSet = nil) or not (DataSource.DataSet is TQuery) then Exit;
{$ENDIF}

  // ������� �� ���� �  ���������� ��� ��� - ����������
  IsInOrderBy := IsFieldInOrderBy(F, OldASC);

  // �������� ������ � ORDER BY
{$IFDEF MMDBGRID_IBEXPRESS}
  S := AnsiUpperCase((DataSource.DataSet as TIBQuery).SQL.Text);
{$ELSE}
  S := AnsiUpperCase((DataSource.DataSet as TQuery).SQL.Text);
{$ENDIF}

  // ������� ��� �������� �� ������� ����� ORDER BY
  S := DeleteAllWordWraps(S);

  // ������� ������� �������
  S := DeleteDoubleSpaces(S);

  // ���� �� ��������� ����������� ����������, �� ������ ���
  if IsInOrderBy and (OldASC <> ASC) then
  begin
    K := AnsiPos(SQL_ORDERBY, S);
    BeforePart := Copy(S, 1, K - 1);
    S := Copy(S, K, Length(S));

    // ���� ����� ���������� ������������ ����������
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
    end else begin // ���� ����� ��������� �������, �� ������� ���������� ������
      K := AnsiPos(AnsiUpperCase(F), S);
      M := 0;
    end;

    if ASC then
      S2 := ''
    else
      S2 := ' ' + SQL_DESC;

    if OldASC then // ��������� ��� ����������
      S := Copy(S, 1, K + Length(F) - 1) + S2 + Copy(S, K + Length(F) + M, Length(S))
    else begin // ������� ���� �� ����������
      S := DeleteBadSpaces(S);
      S := Copy(S, 1, K - 1) + Copy(S, K + Length(F) + M + 1, Length(S));
      S := CutBackSpaces(S);

      // � ���� ����� ���������� ������� ORDERBY
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
  // ���� ���� ��� � ����������, �� ��������� ��� + ��� ����������
  end else begin
    if ASC then
      S2 := ''
    else
      S2 := ' ' + SQL_DESC;

    // ������� ������� ����� � ����� � �������, ��������� ����
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

