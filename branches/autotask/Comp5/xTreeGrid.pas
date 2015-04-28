
{++

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    xTreeGrid.pas

  Abstract

    Grid with tree inside.

  Author

    Romanovski Denis (13-08-98)

  Revisions history

    Initial  13-08-98  Dennis  Initial version.

    beta1    14-08-98  Dennis  Tree viewing and exploring is possible.

    beta2    18-08-98  Dennis  Different colors included.

    beta3    18-08-98  Dennis  Bitmaps are included.

    beta3    20-08-98  Dennis  Columns resizing included.

    beta4    22-08-98  Dennis  Bugs fixed. Some functions included.
    
--}

unit xTreeGrid;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExList, ExtCtrls, StdCtrls;

const
  DefFirstColor = $00D6E7E7;
  DefSecondColor = $00E7F3F7;
  DefSelColor = $009CDFF7;

type
  TxTree = class;
  TxTreeGrid = class;

  TxTreeItem = class
  private
    FText: TStringList; // ��������� ������ ������
    FParent: TxTreeItem; // ��������
    FChildren: TExList; // ����
    FVisible: Boolean; // ������ �� �����
    FTree: TxTree; // ������
    FRow: Integer; // ����� ������
    FExpanded: Boolean; // �������� �� �����
    FImportant: Boolean; // �������� �� ������� ������
    FData: Pointer; // ������ ������������
    FImageNums: Variant; // ������ �������� ��� ������ �������

    function GetChild(Index: Integer): TxTreeItem;
    function GetChildrenCount: Integer;
    function GetLevel: Integer;
    function GetExpanded: Boolean;
    function GetImageCount(ACol: Integer): Integer;

    procedure SetExpanded(AnExpanded: Boolean);
    procedure SetVisible(AVisible: Boolean);
    procedure SetText(AText: TStringList);
    procedure SetRow(ARow: Integer);

    function GetNext: TxTreeItem;
    function GetPrev: TxTreeItem;
    function GetTextByColumn(Index: Integer): String;
    procedure SetTextByColumn(Index: Integer; const Value: String);
    function GetTextByIndex(Index: Integer): String;
    procedure SetTextByIndex(Index: Integer; const Value: String);

  protected
    property Text: TStringList read FText write SetText;

  public
    constructor Create(AText: TStringList; AColCount: Integer);
    destructor Destroy; override;

    procedure AddChild(AnItem: TxTreeItem);
    procedure InsertChild(AnItem: TxTreeItem; Index: Integer);
    procedure DeleteChild(Index: Integer);
    procedure RemoveChild(AnItem: TxTreeItem);

    procedure AddImage(ACol: Integer; ImageIndex, ImageNum: Integer);
    procedure DeleteImage(ACol: Integer; ImageIndex: Integer);
    procedure DeleteImages(ACol: Integer);

    function IndexByChild(AChild: TxTreeItem): Integer; // ������ ������� � ����� �����

    // ������ ������ �� �������
    property TextByIndex[Index: Integer]: String read GetTextByIndex write SetTextByIndex;
    // ������ ������ �� ������� �������
    property TextByColumn[Index: Integer]: String read GetTextByColumn write SetTextByColumn;

    // �������� ��������
    property Parent: TxTreeItem read FParent write FParent;
    // ���� �������� �� �������
    property Child[Index: Integer]: TxTreeItem read GetChild;
    // ���-�� �����
    property ChildrenCount: Integer read GetChildrenCount;
    // ����� �� �������
    property Visible: Boolean read FVisible write SetVisible;
    // �������
    property Level: Integer read GetLevel;
    // ������� �� �������
    property Expanded: Boolean read GetExpanded write SetExpanded;
    // ����� ������ � Grid-�
    property Row: Integer read FRow write SetRow;
    // ������ ��������
    property Tree: TxTree read Ftree write FTree;

    // �������� �������
    property Next: TxTreeItem read GetNext;
    // ���������� �������
    property Prev: TxTreeItem read GetPrev;

    // ������������ �� ����� FontImportant
    property Important: Boolean read FImportant write FImportant;
    // ������ ������������
    property Data: Pointer read FData write FData;
    // ������ ������� � ��������� ��������
    property ImageNums: Variant read FImageNums;
    // ���-�� �������� �� ������� �������
    property ImageCount[ACol: Integer]: Integer read GetImageCount;
  end;

  TxTree = class
  private
    FItems: TExList; // ������ ������� �����
    FGrid: TxTreeGrid; // Grid ������

    function GetItem(Index: Integer): TxTreeItem;
    function GetItemsCount: Integer;
    function GetItemByRow(Index: Integer): TxTreeItem;
    function GetSelected: TxTreeItem;

  protected

  public
    constructor Create;
    destructor Destroy; override;

    function Add(AText: TStringList): TxTreeItem; overload;
    function Add(const AText: array of String): TxTreeItem; overload;
    function Insert(AText: TStringList; Index: Integer): TxTreeItem; overload;
    function Insert(const AText: array of String; Index: Integer): TxTreeItem; overload;
    function AddItem(AText: TStringList; Item: TxTreeItem): TxTreeItem; overload;
    function AddItem(const AText: array of String; Item: TxTreeItem): TxTreeItem; overload;
    function InsertItem(AText: TStringList; Item: TxTreeItem; Index: Integer): TxTreeItem; overload;
    function InsertItem(const AText: array of String; Item: TxTreeItem; Index: Integer): TxTreeItem; overload;
    procedure Delete(Index: Integer);
    procedure Remove(AnItem: TxTreeItem);

    // ������� �� �������
    property Item[Index: Integer]: TxTreeItem read GetItem;
    // ���-�� ���������
    property ItemsCount: Integer read GetItemsCount;
    // Grid- ������
    property Grid: TxTreeGrid read FGrid write FGrid;
    // ������ ������� �� ������� ������
    property ItemByRow[Index: Integer]: TxTreeItem read GetItemByRow;
    // ���������� ���������� �������
    property Selected: TxTreeItem read GetSelected;

  end;

  TxTreeColumn = class
  private
    FColName: String; // ��� ������� (��� ������������� � ������ ������)
    FColTitle: String; // ����� ������� ��� �����������
    FColIndex: Integer; // ������ �������
    FGrid: TxTreeGrid; // Grid ������ �������

    procedure SetColTitle(ATitle: String);
  public
    constructor Create(AColName, AColTitle: String; AColIndex: Integer; AGrid: TxTreeGrid);

    // �������� ������� (�� ������ ������������� ��� �����)
    property ColName: String read FColName write FColName;
    // ��������� �������
    property ColTitle: String read FColTitle write SetColTitle;
    // ������ ������� ��� �������� ������
    property ColIndex: Integer read FColIndex write FColIndex;
  end;

  TxTreeGrid = class(TStringGrid)
  private
    FTree: TxTree; // ������ ���� ���������
    FTreeColumn: Integer; // � �������, � ������� ������������ �������� � �������
    FBranchIndent: Integer; // ������ �� ���������� �����
    OldOnSetEditText: TSetEditEvent; // Event �������������� ������ ������������
    OldOnColumnMoved: TMovedEvent; // Event �� ����������� ������� ������������
    FRowCount: Integer; // ���-�� ����� � Grid-�
    FSplitPosition: Integer; // ������� Split-� �� ������
    FSplitting: Boolean; // ������������ �� �������������� ����� ��� ���
    FSkipColumns: Integer; // ���-�� �������, ������������ ��� ��������� �������� �������

    FFirstColor: TColor; // ������ ����
    FSecondColor: TColor; // ������ ����
    FSelectedColor: TColor; // ���� ���������
    FFontImportant: TFont; // ������ �����
    FPictures: TImageList; // ������ ��������
    FBitmapGap: Integer; // ���������� ����� ����������
    FMinColWidth: Integer; // ����������� ������ �������
    FColumns: TExList; // ������ �������

    CanUpdate: Boolean; // ����� �� ������ ������� �������
    CurrLine: Integer; // ������� ����� ����� ���������
    OldColWidth: Integer; // �����

    procedure SetBranchIndent(const Value: Integer);
    procedure SetTreeColumn(const Value: Integer);

    procedure DoOnSetEditText(Sender: TObject; ACol, ARow: Longint; const Value: string);
    procedure DoOnColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);

    procedure DrawMinus(X, Y: Integer);
    procedure DrawPlus(X, Y: Integer);

    function GetRowCount: Integer;
    procedure SetRowCount(const Value: Integer);
    procedure SetFirstColor(const Value: TColor);
    procedure SetSecondColor(const Value: TColor);
    procedure SetSelectedColor(const Value: TColor);
    procedure SetImportant(const Value: TFont);
    procedure SetImages(const Value: TImageList);
    function GetColCount: Integer;
    procedure SetColCount(const Value: Integer);
    function GetColumn(AnIndex: Integer): TxTreeColumn;

    function CountGridWidth: Integer;

  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure ColWidthsChanged; override;
    procedure CalcSizingState(X, Y: Integer; var State: TGridState;
      var Index: Longint; var SizingPos, SizingOfs: Integer;
      var FixedInfo: TGridDrawInfo); override;

    property Rows;
    property Cols;
    property Cells;
    property Objects;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    function IsRowClear(Text: TStrings): Boolean;
    function IsBelowClear(ARow: Integer): Boolean;
    function GetClearCount: Integer;

    procedure MoveDown(ARow: Integer; Count: Integer);
    procedure MoveUp(ARow: Integer; Count: Integer);
    procedure ChangeColumns(FromIndex, ToIndex: Integer);
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    function ItemByPoint(P: TPoint): TxTreeItem;

    // ������ grid-�
    property Tree: TxTree read FTree;
    // ������� �� �������
    property Columns[Index: Integer]: TxTreeColumn read GetColumn;

  published
    // ������, � ������� ����� ������������� �������� � �������
    property TreeColumn: Integer read FTreeColumn write SetTreeColumn;
    // ����������� ������ �������
    property MinColWidth: Integer read FMinColWidth write FMinColWidth;
    // ����������� ����� ��� �������� ������ ���������
    property FontImportant: TFont read FFontImportant write SetImportant;
    // ������ �� ���������� �����
    property BranchIndent: Integer read FBranchIndent write SetBranchIndent;
    // ���-�� �����
    property RowCount: Integer read GetRowCount write SetRowCount;
    // ���-�� �������
    property ColCount: Integer read GetColCount write SetColCount;
    // ������ ����
    property FirstColor: TColor read FFirstColor write SetFirstColor default DefFirstColor;
    // ������ ����
    property SecondColor: TColor read FSecondColor write SetSecondColor default DefSecondColor;
    // ���� ���������
    property SelectedColor: TColor read FSelectedColor write SetSelectedColor default DefSelColor;
    // �������
    property Pictures: TImageList read FPictures write SetImages;
    // ������ ����� ���������
    property BitmapGap: Integer read FBitmapGap write FBitmapGap;
    // ���-��, ������� � ������, ������� �������� ���� ������
    property SkipColumns: Integer read FSkipColumns write FSkipColumns;

  end;

procedure Register;

implementation

const
  SplittingSize = 20;
  MinColWidth = 10;
  CommonBMP: TBitmap = nil;
  Users: Integer = 0;

{
  ������ �� ����� � Rect
}

function IsInRect(R: TRect; X, Y: Integer): Boolean;
begin
  Result := (X >= R.Left) and (X <= R.Right) and (Y >= R.Top) and (Y <= R.Bottom);
end;

// ������� ������ ��������
function CreateImageList(S: String): Variant;
var
  K, N: Integer;

  // ��������� ������ ��������
  function ReadNum: Integer;
  var
    L: Integer;
    Z: String;
  begin
    L := 1;
    Z := '';

    while S[L] in ['0'..'9'] do
    begin
      Z := Z + S[L];
      Inc(L);
    end;

    if Length(Z) > 0 then
      Result := StrToInt(Z)
    else
      Result := -1;
  end;

begin
  N := 0;
  Result := VarArrayCreate([0, N], varInteger);
  Result[0] := -1;

  repeat
    K := Pos('$', S);

    if (K > 0) and (Length(S) > K) then
    begin
      if not (S[K + 1] in ['0'..'9']) then Break;
      S := Copy(S, K + 1, Length(S));

      if (VarArrayHighBound(Result, 1) = 0) and (Result[0] = -1) then
        Result := VarArrayCreate([0, N], varInteger)
      else begin
        Inc(N);
        VarArrayRedim(Result, N);
      end;

      if Length(S) > 0 then
        Result[N] := ReadNum
      else
        Result[N] := NULL;
    end else
      Break;
  until K = 0;
end;

// ������� ����� �������
function RemoveDollars(S: String): String;
var
  I: Integer;
begin
  repeat
    I := Pos('$', S);

    if (I <> 0) and (Length(S) > I) and (S[I + 1] in ['0'..'9', ' ']) then
      S := Copy(S, I + 1, Length(S))
    else
      Break;
  until I = 0;

    while (Length(S) > 0) and (S[1] in ['0'..'9', ' ']) do
      S := Copy(S, 2, Length(S));

  Result := S;
end;

{
  ----------------------------
  ---   TxTreeItem Class   ---
  ----------------------------
}


{
  ***********************
  ***  Private Part   ***
  ***********************
}


{
  ���������� ������� �� �������
}

function TxTreeItem.GetChild(Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem(FChildren[Index]);
end;

{
  ���������� ���-�� ���������
}

function TxTreeItem.GetChildrenCount: Integer;
begin
  Result := FChildren.Count;
end;

{
  ������� �����
}

function TxTreeItem.GetLevel: Integer;
var
  OldParent: TxTreeItem;
begin
  Result := 1;
  OldParent := Self;

  while OldParent.Parent <> nil do
  begin
    Inc(Result);
    OldParent := OldParent.Parent;
  end;
end;

{
  �������� �� ����� ��� ���!
}

function TxTreeItem.GetExpanded: Boolean;
begin
  Result := FExpanded;
end;

{
  �������� ���-�� �������� ��� ������ �������
}

function TxTreeItem.GetImageCount(ACol: Integer): Integer;
begin
  Result := VarArrayHighBound(FImageNums[ACol], 1);
end;

{
  ������������� ����� �������� ��� ���
}

procedure TxTreeItem.SetExpanded(AnExpanded: Boolean);
var
  I: Integer;
begin
  if FExpanded <> AnExpanded then
  begin
    FExpanded := AnExpanded;
    if FVisible then
    begin
      for I := 0 to ChildrenCount - 1 do Child[I].Visible := FExpanded;
      Tree.Grid.InvalidateRow(FRow);
    end;  
  end;
end;

{
  ������ ������� ������� � Grid-� ��� ������� ���
}

procedure TxTreeItem.SetVisible(AVisible: Boolean);
var
  I: Integer;

  // ���� ��������� ������ ������ ������� �����
  function GetLastRow: Integer;
  var
    I: TxTreeItem;
  begin
    I := Prev;

    while (I.ChildrenCount > 0) and I.Child[I.ChildrenCount - 1].Visible do
      I := I.Child[I.ChildrenCount - 1];

    Result := I.Row + 1;
  end;

begin
  if AVisible <> FVisible then
  begin
    // ���� �������� ������� ��� �� �������, �� ��� ������� ������� ������� � ��������
    if AVisible and (Parent <> nil) then
      if not Parent.Visible then
      begin
        Parent.Visible := True;
        Parent.Expanded := True;
        Exit;
      end else if not Parent.Expanded then
      begin
        Parent.Expanded := True;
        Exit;
      end;

    FVisible := AVisible;

    if FVisible then
    begin
      // ������������� ����� ������� � Grid-�
      if (Prev <> nil) and Prev.Visible then
      begin
        if Prev.Expanded then
          FRow := GetLastRow
        else
          FRow := Prev.Row + 1
      end else if FParent <> nil then
        FRow := Parent.Row + 1
      else
        FRow := Tree.Grid.FixedRows;

      if FTree.Grid.IsBelowClear(FRow) then
      begin
        if FTree.Grid.RowCount < FRow + 1 then
          FTree.Grid.RowCount := FTree.Grid.RowCount + 1;
      end else begin
        FTree.Grid.MoveDown(FRow, 1);
      end;

      // ������������� �����
      for I := 0 to FText.Count - 1 do
        FTree.Grid.Cells[I, FRow] := FText[Tree.Grid.Columns[I].ColIndex];

      // ������������� ������ ������
      for I := 0 to FTree.Grid.Rows[FRow].Count - 1 do
        FTree.Grid.Rows[FRow].Objects[I] := Self;

     // ������ �������� �����, ���� �����
      if FExpanded then
        for I := 0 to ChildrenCount - 1 do
          Child[I].Visible := True;
    end else begin
     // ������ ���������� �����, ���� �����
      if FExpanded then
        for I := 0 to ChildrenCount - 1 do
          Child[I].Visible := False;

      // ����������� ������ �� ������    
      FTree.Grid.Rows[FRow].Clear;

      if FRow < FTree.Grid.RowCount - 1 then
        FTree.Grid.MoveUp(FRow + 1, 1)
      else
        FTree.Grid.RowCount := FTree.Grid.RowCount - 1;
    end;
  end;
end;

{
  ������������� ��������� ����������
}

procedure TxTreeItem.SetText(AText: TStringList);
var
  I: Integer;
begin
  FText.Assign(AText);

  for I := 0 to FText.Count - 1 do FText.Objects[I] := Self;
  if FVisible then FTree.Grid.Rows[FRow] := FText;

  FImageNums := VarArrayCreate([0, FText.Count - 1], varVariant);

  for I := 0 to FText.Count - 1 do
  begin
    FImageNums[I] := CreateImageList(FText[I]);
    FText[I] := RemoveDollars(FText[I]);
  end;
end;

{
  ������������� ����� ������
}

procedure TxTreeItem.SetRow(ARow: Integer);
var
  I: Integer;
begin
  if FVisible then
  begin
    FTree.Grid.Rows[FRow].Clear;
    FRow := ARow;

    for I := 0 to FText.Count - 1 do
      FTree.Grid.Cells[I, FRow] := FText[Tree.Grid.Columns[I].ColIndex];

    for I := 0 to FTree.Grid.Rows[FRow].Count - 1 do
      FTree.Grid.Rows[FRow].Objects[I] := Self;
  end;
end;

{
  ���� ��������� ������� � ����� �����
}

function TxTreeItem.GetNext: TxTreeItem;
var
  I: Integer;
begin
  Result := nil;

  if Parent <> nil then
  begin
    I := Parent.FChildren.IndexOf(Self);
    if Parent.ChildrenCount > I + 1 then Result := Parent.Child[I + 1];
  end else begin
    I := Tree.FItems.IndexOf(Self);
    if Tree.ItemsCount > I + 1 then Result := Tree.Item[I + 1];
  end;
end;

{
  ���� ���������� ������� � ������ �����
}

function TxTreeItem.GetPrev: TxTreeItem;
var
  I: Integer;
begin
  Result := nil;

  if Parent <> nil then
  begin
    I := Parent.FChildren.IndexOf(Self);
    if I > 0 then Result := Parent.Child[I - 1];
  end else begin
    I := Tree.FItems.IndexOf(Self);
    if I > 0 then Result := Tree.Item[I - 1];
  end;
end;

{
  �������� ������ �� ������� ������� (������� �� ������, ����
  ������������ ������ ������� �������)
}

function TxTreeItem.GetTextByColumn(Index: Integer): String;
begin
  Result := FText[Tree.Grid.Columns[Index].ColIndex];
end;

{
  �������� ������ �� �������
}

function TxTreeItem.GetTextByIndex(Index: Integer): String;
begin
  Result := FText[Index];
end;

{
  ����������� ������ �� ������� ������� (������� �� ������, ����
  ������������ ������ ������� �������)
}

procedure TxTreeItem.SetTextByColumn(Index: Integer; const Value: String);
var
  CurrCol: Variant;
begin
  if Tree = nil then
  begin
    CurrCol := CreateImageList(Value);
    FImageNums[Tree.Grid.Columns[Index].ColIndex] := CurrCol;
    FText[Tree.Grid.Columns[Index].ColIndex] := RemoveDollars(Value);
  end else begin
    FText[Tree.Grid.Columns[Index].ColIndex] := Value;
    if FVisible then
      Tree.Grid.Cells[Index, FRow] := Value;
  end;
end;

{
  ������������� ������ �� �������
}

procedure TxTreeItem.SetTextByIndex(Index: Integer; const Value: String);
var
  CurrCol: Variant;
  I: Integer;
begin
  if Tree = nil then
  begin
    CurrCol := CreateImageList(Value);
    FImageNums[Index] := CurrCol;
    FText[Index] := RemoveDollars(Value);
  end else begin
    FText[Index] := Value;
    if FVisible then
      for I := 0 to FText.Count - 1 do
        FTree.Grid.Cells[I, FRow] := FText[Tree.Grid.Columns[I].ColIndex];
  end;
end;

{
  *************************
  ***  Protected Part   ***
  *************************
}

{
  **********************
  ***  Public Part   ***
  **********************
}


{
  ��������� ���������
}

constructor TxTreeItem.Create(AText: TStringList; AColCount: Integer);
var
  I: Integer;
  V: Variant;
begin
  FText := TStringList.Create;

  if AText <> nil then
  begin
    // �������� �� ������� ������� ����� �������
    if AText.Count < AColCount then
      for I := AText.Count to AColCount do AText.Add('');

    Text := AText;
  end else begin // ���� ������ ���, �� ������� ������� ������ ��������������
    for I := 1 to AColCount do FText.Add('');
    FImageNums := VarArrayCreate([0, FText.Count - 1], varVariant);

    for I := 0 to FText.Count - 1 do
    begin
      V := VarArrayCreate([0, 0], varInteger);
      V[0] := -1;
      FImageNums[I] := V;
    end;  
  end;

  for I := 0 to FText.Count - 1 do
    FText.Objects[I] := Self;

  FParent := nil;
  FVisible := False;
  FExpanded := False;
  FData := nil;
  FChildren := TExList.Create;
end;

{
  ������������� ������
}

destructor TxTreeItem.Destroy;
begin
  FText.Free;
  FChildren.Free;

  inherited Destroy;
end;

{
  ��������� ������� � ������ �����
}

procedure TxTreeItem.AddChild(AnItem: TxTreeItem);
begin
  FChildren.Add(AnItem);
  AnItem.Parent := Self;
  AnItem.Tree := FTree;
  if Expanded then AnItem.Visible := True;
  Tree.Grid.InvalidateRow(FRow);
end;

{
  ��������� ������� � ������ ����� �� �������
}

procedure TxTreeItem.InsertChild(AnItem: TxTreeItem; Index: Integer);
begin
  FChildren.Insert(Index, AnItem);
  AnItem.Parent := Self;
  AnItem.Tree := FTree;
  if Expanded and Visible then AnItem.Visible := True;
  Tree.Grid.InvalidateRow(FRow);
end;

{
  ������� �������� �� �������
}

procedure TxTreeItem.DeleteChild(Index: Integer);
var
  CurrItem: TxTreeItem;
begin
  CurrItem := Child[Index];
  
  if Visible then
  begin
    CurrItem.Expanded := False;
    CurrItem.Visible := False;
  end;

  FChildren.RemoveAndFree(CurrItem);

  if ChildrenCount = 0 then
    FTree.Grid.InvalidateRow(FRow);
end;

{
  ������� ������� �� ��� ������
}

procedure TxTreeItem.RemoveChild(AnItem: TxTreeItem);
begin
  if Visible then
  begin
    AnItem.Expanded := False;
    AnItem.Visible := False;
  end;

  FChildren.RemoveAndFree(AnItem);

  if ChildrenCount = 0 then
    FTree.Grid.InvalidateRow(FRow);
end;

{
  ��������� ������ �������� � ������
}

procedure TxTreeItem.AddImage(ACol: Integer; ImageIndex, ImageNum: Integer);
var
  CurrCol: Variant;
  I: Integer;
begin
  CurrCol := FImageNums[ACol];
  VarArrayRedim(CurrCol, VarArrayHighBound(CurrCol, 1) + 1);

  for I := VarArrayHighBound(CurrCol, 1) downto ImageIndex + 1 do
    CurrCol[I] := CurrCol[I - 1];

  CurrCol[ImageIndex] := ImageNum;
  FImageNums[ACol] := CurrCol;
  if FVisible then Tree.Grid.InvalidateRow(FRow);
end;

{
  ������� �������� �� ������ �� �������
}

procedure TxTreeItem.DeleteImage(ACol: Integer; ImageIndex: Integer);
var
  CurrCol: Variant;
  I: Integer;
begin
  CurrCol := FImageNums[ACol];

  if ImageIndex < VarArrayHighBound(CurrCol, 1) then
    for I := ImageIndex to VarArrayHighBound(CurrCol, 1) - 1 do
      CurrCol[I] := CurrCol[I + 1];

  if VarArrayHighBound(CurrCol, 1) > 0 then
    VarArrayRedim(CurrCol, VarArrayHighBound(CurrCol, 1) - 1)
  else
    CurrCol[0] := -1;

  FImageNums[ACol] := CurrCol;
  if FVisible then Tree.Grid.InvalidateRow(FRow);
end;

{
  ������� ��� ��������
}

procedure TxTreeItem.DeleteImages(ACol: Integer);
var
  CurrCol: Variant;
begin
  CurrCol := FImageNums[ACol];
  VarArrayRedim(CurrCol, 0);
  CurrCol[0] := -1;
  FImageNums[ACol] := CurrCol;
  if FVisible then Tree.Grid.InvalidateRow(FRow);
end;

{
  ���������� ������ ������� � ������ �����
}

function TxTreeItem.IndexByChild(AChild: TxTreeItem): Integer;
begin
  Result := FChildren.IndexOf(AChild);
end;

{
  ------------------------
  ---   TxTree Class   ---
  ------------------------
}


{
  ***********************
  ***  Private Part   ***
  ***********************
}


{
  ���������� ������� �� �������
}

function TxTree.GetItem(Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem(FItems[Index]);
end;

{
  ���������� ���-�� ���������
}

function TxTree.GetItemsCount: Integer;
begin
  Result := FItems.Count;
end;

{
  ������ ������� �� ������� ������
}

function TxTree.GetItemByRow(Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem(FGrid.Rows[Index].Objects[0]);
end;

{
  ���������� ���������� � ������ ������ �������
}

function TxTree.GetSelected: TxTreeItem;
begin
  Result := GetItemByRow(FGrid.Row);
end;

{
  *************************
  ***  Protected Part   ***
  *************************
}


{
  **********************
  ***  Public Part   ***
  **********************
}

{
  ��������� ���������
}

constructor TxTree.Create;
begin
  FItems := TExList.Create;
end;

{
  ������������� ������
}

destructor TxTree.Destroy;
begin
  FItems.Free;

  inherited Destroy;
end;

{
  ��������� ������� � ����� ������
}

function TxTree.Add(AText: TStringList): TxTreeItem;
begin
  Result := TxTreeItem.Create(AText, Grid.ColCount);
  Result.Parent := nil;
  Result.Tree := Self;
  FItems.Add(Result);
  Result.Visible := True;
end;

{
  ��������� ������� � ����� ������
}

function TxTree.Add(const AText: array of String): TxTreeItem;
var
  I: Integer;
begin
  Result := TxTreeItem.Create(nil, Grid.ColCount);
  
  for I := Low(AText) to High(AText) do
    Result.TextByIndex[I] := AText[I];

  Result.Parent := nil;
  Result.Tree := Self;
  FItems.Add(Result);
  Result.Visible := True;
end;

{
  ��������� ������� � ������ �� �������
}

function TxTree.Insert(AText: TStringList; Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem.Create(AText, Grid.ColCount);
  Result.Parent := nil;
  Result.Tree := Self;
  FItems.Insert(Index, Result);
  Result.Visible := True;
end;

{
  ��������� ������� � ������ �� �������
}

function TxTree.Insert(const AText: array of String; Index: Integer): TxTreeItem;
var
  I: Integer;
begin
  Result := TxTreeItem.Create(nil, Grid.ColCount);

  for I := Low(AText) to High(AText) do
    Result.TextByIndex[I] := AText[I];

  Result.Tree := Self;
  FItems.Insert(Index, Result);
  Result.Visible := True;
end;

{
  ��������� ������� � ����� � ����� ������
}

function TxTree.AddItem(AText: TStringList; Item: TxTreeItem): TxTreeItem;
begin
  Result := TxTreeItem.Create(AText, Grid.ColCount);
  Item.AddChild(Result);
end;

{
  ��������� ������� � ����� � ����� ������
}

function TxTree.AddItem(const AText: array of String; Item: TxTreeItem): TxTreeItem;
var
  I: Integer;
begin
  Result := TxTreeItem.Create(nil, Grid.ColCount);
  for I := Low(AText) to High(AText) do Result.TextByIndex[I] := AText[I];
  Item.AddChild(Result);
end;

{
  ��������� ������� � ����� �� �������
}

function TxTree.InsertItem(AText: TStringList; Item: TxTreeItem;
  Index: Integer): TxTreeItem;
begin
  Result := TxTreeItem.Create(AText, Grid.ColCount);
  Item.InsertChild(Result, Index);
end;

{
  ��������� ������� � ����� �� �������
}

function TxTree.InsertItem(const AText: array of String; Item: TxTreeItem; Index: Integer): TxTreeItem;
var
  I: Integer;
begin
  Result := TxTreeItem.Create(nil, Grid.ColCount);
  for I := Low(AText) to High(AText) do Result.TextByIndex[I] := AText[I];
  Item.InsertChild(Result, Index);
end;

{
  ������� ������� �� �������
}

procedure TxTree.Delete(Index: Integer);
var
  CurrItem: TxTreeItem;
begin
  CurrItem := TxTreeItem(FItems[Index]);

  if CurrItem.Visible then
  begin
    CurrItem.Expanded := False;
    CurrItem.Visible := False;
  end;

  FItems.RemoveAndFree(CurrItem);
end;

{
  ������� ������� �� ������
}

procedure TxTree.Remove(AnItem: TxTreeItem);
begin
  if AnItem.Visible then
  begin
    AnItem.Expanded := False;
    AnItem.Visible := False;
  end;

  FItems.RemoveAndFree(AnItem);
end;


{
  ------------------------------
  ---   TxTreeColumn Class   ---
  ------------------------------
}


{
  ***********************
  ***  Private Part   ***
  ***********************
}

{
  ������������� ����� �������
}

procedure TxTreeColumn.SetColTitle(ATitle: String);
begin
  FColTitle := ATitle;
  if FGrid.FixedRows > 0 then
    FGrid.Cells[FGrid.FColumns.IndexOf(Self), 0] := FColTitle;
end;


{
  **********************
  ***  Public Part   ***
  **********************
}


{
  ������ ��������� ���������
}

constructor TxTreeColumn.Create(AColName, AColTitle: String; AColIndex: Integer; AGrid: TxTreeGrid);
begin
  FColName := AColName;
  FColTitle := AColTitle;
  FColIndex := AColIndex;
  FGrid := AGrid;
end;

{
  ----------------------------
  ---   TxTreeGrid Class   ---
  ----------------------------
}


{
  ***********************
  ***  Private Part   ***
  ***********************
}

{
  ������������� ������
}

procedure TxTreeGrid.SetBranchIndent(const Value: Integer);
begin
  FBranchIndent := Value;
  Repaint;
end;

{
  ������������� � ������� ��� �������� � �������
}

procedure TxTreeGrid.SetTreeColumn(const Value: Integer);
begin
  FTreeColumn := Value;
  Repaint;
end;

{
  �� ����� ������ ������ ���������� ���� ��������
}

procedure TxTreeGrid.DoOnSetEditText(Sender: TObject; ACol, ARow: Longint; const Value: string);
var
  CurrItem: TxTreeItem;
begin
  CurrItem := TxTreeItem(Rows[ARow].Objects[0]);

  if CurrItem <> nil then
    CurrItem.FText[Columns[ACol].ColIndex] := Cells[ACol, ARow];

  if Assigned(OldOnSetEditText) then OldOnSetEditText(Sender, ACol, ARow, Value);
end;

{
  �� ������������ ������� ���������� �������� �� ������������ ������� �
  �������
}

procedure TxTreeGrid.DoOnColumnMoved(Sender: TObject; FromIndex, ToIndex: Integer);
begin
  ChangeColumns(FromIndex, ToIndex);

  if FromIndex = FTreeColumn then
    FTreeColumn := ToIndex
  else if (FromIndex < FTreeColumn) and (ToIndex >= FTreeColumn) then
    Dec(FTreeColumn)
  else if (FromIndex > FTreeColumn) and (ToIndex <= FTreeColumn) then
    Inc(FTreeColumn);

  CurrLine := 0;
  OldColWidth := ColWidths[CurrLine];

  Repaint;
  if Assigned(OldOnCOlumnMoved) then OldOnColumnMoved(Sender, FromIndex, ToIndex);
end;

{
  ������ ����
}

procedure TxTreeGrid.DrawMinus(X, Y: Integer);
var
  OldBrushColor, OldPenColor: TColor;
begin
  OldBrushColor := Canvas.Brush.Color;
  OldPenColor := Canvas.Pen.Color;

  Canvas.Pen.Color := clGray;
  Canvas.Brush.Color := clGray;
  Canvas.FrameRect(Rect(X, Y, X + 9, Y + 9));

  Canvas.Pen.Color := clBlack;
  Canvas.MoveTo(X + 2, Y + 4);
  Canvas.LineTo(X + 7, Y + 4);

  Canvas.Brush.Color := OldBrushColor;
  Canvas.Pen.Color := OldPenColor;
end;

{
  ������ �����
}

procedure TxTreeGrid.DrawPlus(X, Y: Integer);
var
  OldBrushColor, OldPenColor: TColor;
begin
  OldBrushColor := Canvas.Brush.Color;
  OldPenColor := Canvas.Pen.Color;

  Canvas.Pen.Color := clGray;
  Canvas.Brush.Color := clGray;
  Canvas.FrameRect(Rect(X, Y, X + 9, Y + 9));

  Canvas.Pen.Color := clBlack;
  Canvas.MoveTo(X + 2, Y + 4);
  Canvas.LineTo(X + 7, Y + 4);

  Canvas.MoveTo(X + 4, Y + 2);
  Canvas.LineTo(X + 4, Y + 7);

  Canvas.Brush.Color := OldBrushColor;
  Canvas.Pen.Color := OldPenColor;
end;

{
  ����� ���-�� ����� � Grid-�
}

function TxTreeGrid.GetRowCount: Integer;
begin
  Result := inherited RowCount;
end;

{
  ������������� ���-�� ����� � Grid-�
}

procedure TxTreeGrid.SetRowCount(const Value: Integer);
begin
  if (csLoading in ComponentState) or (csDesigning in ComponentState) or (Value >= FRowCount) then
  begin
    inherited RowCount := Value;
    if (csLoading in ComponentState) then FRowCount := Value;
  end;
end;

{
  ��������������� ������ ����
}

procedure TxTreeGrid.SetFirstColor(const Value: TColor);
begin
  FFirstColor := Value;
  Repaint;
end;

{
  ��������������� ������ ����
}

procedure TxTreeGrid.SetSecondColor(const Value: TColor);
begin
  FSecondColor := Value;
  Repaint;
end;

{
  ��������������� ���� ���������
}

procedure TxTreeGrid.SetSelectedColor(const Value: TColor);
begin
  FSelectedColor := Value;
  Repaint;
end;

{
  ������������� ����� ������ �����
}

procedure TxTreeGrid.SetImportant(const Value: TFont);
begin
  FFontImportant.Assign(Value);
end;

{
  ������������� ������ ��������
}

procedure TxTreeGrid.SetImages(const Value: TImageList);
begin
  FPictures := Value;
  Repaint;
end;

{
  ���������� ���-�� �������
}

function TxTreeGrid.GetColCount: Integer;
begin
  Result := inherited ColCount;
end;

{
  ������������� ���-�� �������
}

procedure TxTreeGrid.SetColCount(const Value: Integer);
var
  I: Integer;
begin
  inherited ColCount := Value;
  if not (csDesigning in ComponentState) then
  begin
    ColWidthsChanged;
    
    if FColumns.Count < ColCount then
      for I := FColumns.Count to ColCount do
        FColumns.Add(TxTreeColumn.Create('', '', FColumns.Count, Self))
    else if FColumns.Count > ColCount then
      for I := ColCount downto FColumns.Count do FColumns.DeleteAndFree(FColumns.Count - 1);
  end;
end;

{
  ������ ������� �� �������
}

function TxTreeGrid.GetColumn(AnIndex: Integer): TxTreeColumn;
begin
  Result := TxTreeColumn(FColumns[AnIndex]);
end;

{
  ������ ������� Grid-�
}

function TxTreeGrid.CountGridWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to ColCount - 1 do Inc(Result, ColWidths[I] + GridLineWidth);
end;

{
  *************************
  ***  Protected Part   ***
  *************************
}


{
  ���������� ����������� Grid-�
}

procedure TxTreeGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  CurrItem: TxTreeItem;
  CurrCol: Variant;
  I: Integer;
  Pos: Integer;

  // ������ bitmap
  procedure DrawImage(const BMP: TBitmap);
  begin
    Pos := (BMP.Width - (ARect.Bottom - ARect.Top)) div 2;

    Canvas.BrushCopy(
      Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom),
      BMP,
      Rect(0, Pos, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top + Pos),
      BMP.TransparentColor);

    ARect.Left := ARect.Left + BMP.Width + FBitmapGap;
  end;

begin
  CurrItem := TxTreeItem(Rows[ARow].Objects[0]);

  // ���������� ����
  if not (gdFixed in AState) then
  begin
    if ((gdSelected in AState) or (gdFocused in AState)) then
      Canvas.Brush.Color := FSelectedColor
    else if ARow mod 2 = 0 then
      Canvas.Brush.Color := FSecondColor
    else
      Canvas.Brush.Color := FFirstColor;
  end else
    Canvas.Brush.Color := FixedColor;

  Canvas.FillRect(ARect);

  if (CurrItem <> nil) and CurrItem.Important then
    Canvas.Font.Assign(FFontImportant)
  else
    Canvas.Font.Assign(Font);

  // ��������� ������
  if CurrItem = nil then
    inherited DrawCell(ACol, ARow, ARect, AState)
  else begin // ���� ���������� ����������� ������� ��� �������� � �������

    if ACol = FTreeColumn then
    begin
      ARect.Left := ARect.Left + FBranchIndent * (CurrItem.Level - 1);

      if CurrItem.ChildrenCount > 0 then
      begin
        if CurrItem.Expanded then
          DrawMinus(ARect.Left + 2, ARect.Top + (ARect.Bottom - ARect.Top) div 2 - 5)
        else
          DrawPlus(ARect.Left + 2, ARect.Top + (ARect.Bottom - ARect.Top) div 2 - 5);
      end;

      if (CurrItem.Level > 1) or (CurrItem.ChildrenCount > 0) then
        ARect.Left := ARect.Left + 12;
    end;

    CurrCol := CurrItem.ImageNums[Columns[ACol].ColIndex];
    // ���� ����� �������� �������
    if FPictures <> nil then
      for I := 0 to CurrItem.ImageCount[Columns[ACol].ColIndex] do
        if CurrCol[I] <> -1 then
        begin
          Inc(ARect.Left, FBitmapGap);
          CommonBMP.Width := 0;
          CommonBMP.Height := 0;
          FPictures.GetBitmap(CurrCol[I], CommonBMP);
          DrawImage(CommonBMP);
        end;

    if ARect.Right - ARect.Left > 0 then
    begin
      Pos := ((ARect.Bottom - ARect.Top) - Canvas.TextHeight(Cells[ACol, ARow])) div 2;
      Canvas.TextRect(ARect, ARect.Left + 2, ARect.Top + Pos, Cells[ACol, ARow]);
    end;
  end;
end;

{
  ���������� ���� �������� ����� �������� �������� �������
}

procedure TxTreeGrid.Loaded;
var
  I: Integer;
begin
  inherited Loaded;

  if not (csDesigning in ComponentState) then
  begin
    CanUpdate := True;

    OldOnSetEditText := OnSetEditText;
    OnSetEditText := DoOnSetEditText;

    OldOnColumnMoved := OnColumnMoved;
    OnColumnMoved := DoOnColumnMoved;

    FRowCount := RowCount;

    for I := FixedRows to RowCount - 1 do
      Rows[I].Clear;
  end;
end;

{
  �� ������� ���� ���������� �������� � �������
}

procedure TxTreeGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Integer;
  R: TRect;
  CurrItem: TxTreeItem;
begin
  MouseToCell(X, Y, ACol, ARow);
  R := CellRect(ACol, ARow);

  if Button = mbLeft then
  begin
    if (ACol >= 0) and (ARow >= 0) then
      CurrItem := TxTreeItem(Rows[ARow].Objects[0])
    else
      CurrItem := nil;

    if (CurrItem <> nil) and (CurrItem.ChildrenCount > 0) and (TreeColumn = ACol) then
    begin
      R.Left := R.Left + FBranchIndent * (CurrItem.Level - 1);

      R.Left := R.Left + 2;
      R.Right := R.Left + 9;
      R.Top := R.Top + (R.Bottom - R.Top) div 2 - 5;
      R.Bottom := R.Top + 9;

      if IsInRect(R, X, Y) then
      begin
        CurrItem.Expanded := not CurrItem.Expanded;
        Repaint;
      end else
        inherited MouseDown(Button, Shift, X, Y);
    end else
      inherited MouseDown(Button, Shift, X, Y);
  end else
    inherited MouseDown(Button, Shift, X, Y);

  if (CurrLine >= 0) and (CurrLine <= ColCount - 1) then
    OldColWidth := ColWidths[CurrLine];
end;

{
  �� �������� ������ ���������� �������� � �������
}

procedure TxTreeGrid.DblClick;
var
  P: TPoint;
  ACol, ARow: Integer;
  CurrItem: TxTreeItem;
begin
  GetCursorPos(P);
  P := ScreenToClient(P);
  MouseToCell(P.X, P.Y, ACol, ARow);

  if (ACol >= 0) and (ARow >= 0) then
    CurrItem := TxTreeItem(Rows[ARow].Objects[0])
  else
    CurrItem := nil;

  if (CurrItem <> nil) then
    CurrItem.Expanded := not CurrItem.Expanded;

  inherited DblClick;
end;

{
  �� ��������� �������� ������� ���������� �� ��������
}

procedure TxTreeGrid.ColWidthsChanged;
var
  ChangeWidth: Integer;
begin
  if CanUpdate and not (csDesigning in ComponentState) then
  begin
    ChangeWidth := OldColWidth - ColWidths[CurrLine];
    CanUpdate := False;

    if CurrLine <> ColCount - 1 then
    begin
      if ColWidths[CurrLine] < FMinColWidth then
      begin
        ColWidths[CurrLine + 1] := ColWidths[CurrLine + 1] + OldColWidth - FMinColWidth;
        ColWidths[CurrLine] := FMinColWidth;
      end else if ColWidths[CurrLine + 1] + ChangeWidth < FMinColWidth then
      begin
        ColWidths[CurrLine] := ColWidths[CurrLine + 1] + OldColWidth - FMinColWidth;
        ColWidths[CurrLine + 1] := FMinColWidth;
      end else begin
        ColWidths[CurrLine + 1] := ColWidths[CurrLine + 1] + ChangeWidth;
      end;
    end else begin
      ColWidths[CurrLine] := OldColWidth;
    end;

    CanUpdate := True;

    if (ScrollBars = ssHorizontal) then
      ScrollBars := ssNone
    else if (ScrollBars = ssBoth) then
      ScrollBars := ssVertical;

  end;

  inherited ColWidthsChanged;
end;

{
  ������������ ����� ������� ������������ ����� ����������
}

procedure TxTreeGrid.CalcSizingState(X, Y: Integer; var State: TGridState;
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
  **********************
  ***  Public Part   ***
  **********************
}

{
  ������ ��������� ���������!
}

constructor TxTreeGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FTree := TxTree.Create;
  FTree.Grid := Self;
  FFontImportant := TFont.Create;
  FColumns := TExList.Create;

  if Users = 0 then
  begin
    CommonBMP := TBitmap.Create;
    CommonBMP.Transparent := True;
  end;

  Inc(Users);

  FPictures := nil;
  FTreeColumn := 0;
  FBranchIndent := 10;
  FRowCount := 0;
  FSplitPosition := 0;
  FSplitting := False;
  FSkipColumns := 0;
  FBitmapGap := 2;
  CanUpdate := False;
  CurrLine := -1;
  OldColWidth := 0;
  FMinColWidth := MinColWidth;

  FFirstColor := DefFirstColor;
  FSecondColor := DefSecondColor;
  FSelectedColor := DefSelColor;

  OldOnColumnMoved := nil;
  OldOnSetEditText := nil;
end;

{
  ������������ ������
}

destructor TxTreeGrid.Destroy;
begin
  FTree.Free;
  FColumns.Free;
  FFontImportant.Free;

  Dec(Users);
  if Users = 0 then CommonBMP.Free;
    
  inherited Destroy;
end;

{
  �������� �� ������ ����� ������
}

function TxTreeGrid.IsRowClear(Text: TStrings): Boolean;
var
  K: Integer;
begin
  Result := True;

  for K := 0 to Text.Count - 1 do
    if Text[K] <> '' then
    begin
      Result := False;
      Break;
    end;
end;

{
  �������� �� ��� ������������� ������ �������
}

function TxTreeGrid.IsBelowClear(ARow: Integer): Boolean;
var
  I: Integer;
begin
  Result := True;

  for I := ARow to RowCount - 1 do
    if not IsRowClear(Rows[I]) then
    begin
      Result := False;
      Break;
    end;
end;

{
  ������ ���-�� ��������� ����� �����
}

function TxTreeGrid.GetClearCount: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := RowCount - 1 downto FixedRows do
    if IsRowClear(Rows[I]) then
      Inc(Result)
    else
      Break;
end;

{
  �������� ��� ������ ����
}

procedure TxTreeGrid.MoveDown(ARow: Integer; Count: Integer);
var
  LastUsed: Integer;
  CurrItem: TxTreeItem;
  I: Integer;
begin
  // ���� �� ������� ����� �����, �� ��������� ��!
  if GetClearCount < Count then RowCount := RowCount + Count - GetClearCount;

  LastUsed := RowCount - GetClearCount - FixedRows;

  for I := LastUsed downto ARow do
  begin
    CurrItem := TxTreeItem(Rows[I].Objects[0]);

    if CurrItem <> nil then
      CurrItem.Row := CurrItem.Row + Count
    else
      Rows[I + Count].Clear;
  end;
end;

{
  �������� ��� ������ �����
}

procedure TxTreeGrid.MoveUp(ARow: Integer; Count: Integer);
var
  CurrItem: TxTreeItem;
  I: Integer;
  OldClearCount: Integer;
begin
  OldClearCount := GetClearCount;

  for I := ARow to RowCount - 1 do
  begin
    CurrItem := TxTreeItem(Rows[I].Objects[0]);

    if CurrItem <> nil then
      CurrItem.Row := CurrItem.Row - Count
    else
      Rows[I - Count].Clear;
  end;

  // ������� �������� ������ �����
  RowCount := RowCount - (GetClearCount - OldClearCount);
end;

{
  ������ ������� ��� ������� ��� ���� ���������
}

procedure TxTreeGrid.ChangeColumns(FromIndex, ToIndex: Integer);
var
  P: Pointer;
begin
  P := FColumns[FromIndex];
  FColumns.Remove(P);
  FColumns.Insert(ToIndex, P);
end;

{
  ������������� ������� ����. ����� ���� �������� �������� ������� �
  �� ���������
}

procedure TxTreeGrid.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  Rest: Integer;
  I: Integer;
  N: Integer;
  OldClientWidth: Integer;
begin
  // ��������� ������ ������ ����
  if (Parent <> nil) and CanUpdate and not (csDesigning in ComponentState)
  then
    OldClientWidth := ClientWidth
  else
    OldClientWidth := 0;

  inherited SetBounds(ALeft, ATop, AWidth, AHeight);

  // ���������� ���������
  if (Parent <> nil) and CanUpdate and not (csDesigning in ComponentState) then
  begin
    CanUpdate := False;
    if OldClientWidth < CountGridWidth then OldClientWidth := CountGridWidth;

    for I := FSkipColumns + FixedCols to ColCount - 1 do // Check it
    begin
      N := Round(ClientWidth * ColWidths[I] / OldClientWidth);

      if N < FMinColWidth then
        ColWidths[I] := FMinColWidth
      else begin
        ColWidths[I] := N;
        if ColWidths[I] <> N then Messagebeep(0);
      end;
    end;

    // ���������� �����
    Rest := ClientWidth - CountGridWidth;

    for I := FSkipColumns + FixedCols to ColCount - 1 do // Check it
    begin
      if ((ColWidths[I] > FMinColWidth) and (Rest < 0)) or (Rest > 0) then
      begin
        N := ColWidths[I] + Rest;

        if N >= FMinColWidth then
        begin
          ColWidths[I] := N;
          Rest := 0;
        end else begin
          ColWidths[I] := FMinColWidth;
          Rest := N - FMinColWidth;
        end;

        if Rest = 0 then Break;
      end;
    end;

    CanUpdate := True;

    if (ScrollBars = ssHorizontal) then
      ScrollBars := ssNone
    else if (ScrollBars = ssBoth) then
      ScrollBars := ssVertical;

  end;
end;

{
  �������� ������� �� ����������� ����.
}

function TxTreeGrid.ItemByPoint(P: TPoint): TxTreeItem;
var
  ACol, ARow: Integer;
begin
  MouseToCell(P.X, P.Y, ACol, ARow);

  if (ACol >= 0) and (ARow >= 0) then
    Result := TxTreeItem(Rows[ARow].Objects[0])
  else
    Result := nil;
end;

{
  -----------------------------
  ---   Registration Part   ---
  -----------------------------
}

procedure Register;
begin
  RegisterComponents('gsVC', [TxTreeGrid]);
end;

end.

