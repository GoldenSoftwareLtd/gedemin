
{******************************************}
{                                          }
{             FastReport v2.53             }
{              Cross methods               }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}
{ Copyright(c) by Pavel Ishenin            }
{ <webpirat@mail.ru>                       }
{******************************************}

unit FR_Cross1;

interface

{$I FR.inc}

uses
  Windows, SysUtils, Classes, FR_Class, FR_Utils, FR_DBRel, FR_Pars
{$IFNDEF IBO}
, DB
{$ELSE}
, IB_Components
{$ENDIF};

type
  TIntArrayCell = array[0..0] of Integer;
  PIntArrayCell = ^TIntArrayCell;
  TQuickIntArray = class
  private
    arr : PIntArrayCell;
    len : Integer;
    function GetCell(Index: Integer): Integer;
    procedure SetCell(Index: Integer; const Value: Integer);
  public
    constructor Create(Length : Integer);
    destructor  Destroy; override;                                            
    property Cell[Index : Integer] : Integer read GetCell write SetCell; default;
  end;

  TfrArray = class(TObject)
  private
    FArray          : TStringList;
    FColumns        : TStringList;
    FCellItemsCount : Integer;
    function    GetCell(Index1, Index2: String; Index3: Integer): Variant;
    procedure   SetCell(Index1, Index2: String; Index3: Integer; Value: Variant);
    function    GetCellByIndex(Index1, Index2, Index3: Integer): Variant;
    function    GetCellArray(Index1, Index2: Integer): Variant;
    procedure   SetCellArray(Index1, Index2: Integer; Value: Variant);
  public
    constructor Create(CellItemsCount: Integer);
    destructor  Destroy; override;
    procedure   Clear;
    property    Columns: TStringList read FColumns;
    property    Rows: TStringList read FArray;
    property    CellItemsCount: Integer read FCellItemsCount;
    property    Cell[Index1, Index2: String; Index3: Integer]: Variant read GetCell write SetCell;
    property    CellByIndex[Index1, Index2, Index3: Integer]: Variant read GetCellByIndex;
    property    CellArray[Index1, Index2: Integer]: Variant read GetCellArray write SetCellArray;
  end;

  TfrCross = class(TfrArray)
  private
    FDataSet: TfrTDataSet;
    FRowFields, FColFields, FCellFields: TStringList;
    FRowTypes, FColTypes: Array[0..31] of Variant;
    FTopLeftSize: TSize;
    FHeaderString: String;
    FRowTotalString: String;
    FRowGrandTotalString: String;
    FColumnTotalString: String;
    FColumnGrandTotalString: String;
    function GetIsTotalRow(Index: Integer): Boolean;
    function GetIsTotalColumn(Index: Integer): Boolean;
  public
    DoDataCol : Boolean;
    DataStr   : String;
{$IFNDEF IBO}
    constructor Create(DS: TDataSet; RowFields, ColFields, CellFields: String);
{$ELSE}
    constructor Create(DS: TIB_Dataset; RowFields, ColFields, CellFields: String);
{$ENDIF}
    destructor Destroy; override;
    procedure  Build;
    property   HeaderString: String read FHeaderString write FHeaderString;
    property   RowTotalString: String read FRowTotalString write FRowTotalString;
    property   RowGrandTotalString: String read FRowGrandTotalString write FRowGrandTotalString;
    property   ColumnTotalString: String read FColumnTotalString write FColumnTotalString;
    property   ColumnGrandTotalString: String read FColumnGrandTotalString write FColumnGrandTotalString;
    property   TopLeftSize: TSize read FTopLeftSize;
    property   IsTotalRow[Index: Integer]: Boolean read GetIsTotalRow;
    property   IsTotalColumn[Index: Integer]: Boolean read GetIsTotalColumn;
  end;

function CharCount(ch: Char; s: String): Integer;

implementation

{$IFDEF Delphi6}
uses Variants;
{$ENDIF}


type
  PfrArrayCell = ^TfrArrayCell;
  TfrArrayCell = record
    Items: Variant;
  end;

  TfrCrossGroupItem = class(TObject)
  private
    Parent: TfrCross;
    FArray: Variant;
    FCellItemsCount: Integer;
    FGroupName: TStringList;
    FIndex: Integer;
    FCount: TQuickIntArray;
    FStartFrom: Integer;
    procedure Reset(NewGroupName: String; StartFrom: Integer);
    procedure AddValue(Value: Variant);
    function IsBreak(GroupName: String): Boolean;
    procedure CheckAvg;
    property Value: Variant read FArray;
  public
    constructor Create(AParent: TfrCross; GroupName: String; Index, CellItemsCount: Integer);
    destructor Destroy; override;
  end;


function HasTotal(s: String): Boolean;
begin
  Result := Pos('+', s) <> 0;
end;

function FuncName(s: String): String;
begin
  if HasTotal(s) then
  begin
    Result := LowerCase(Copy(s, Pos('+', s) + 1, 255));
    if Result = '' then
      Result := 'sum';
  end
  else
    Result := '';
end;

function PureName(s: String): String;
begin
  if HasTotal(s) then
    Result := Copy(s, 1, Pos('+', s) - 1) else
    Result := s;
end;

function CharCount(ch: Char; s: String): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(s) do
    if s[i] = ch then
      Inc(Result);
end;


{ TfrCrossGroupItem }

constructor TfrCrossGroupItem.Create(AParent: TfrCross; GroupName: String;
  Index, CellItemsCount: Integer);
begin
  inherited Create;
  Parent := AParent;
  FCellItemsCount := CellItemsCount;
  FArray := VarArrayCreate([0, CellItemsCount - 1], varVariant);
  FCount := TQuickIntArray.Create(CellItemsCount);
  FGroupName := TStringList.Create;
  FIndex := Index;
  Reset(GroupName, 0);
end;

destructor TfrCrossGroupItem.Destroy;
begin
  FGroupName.Free;
  VarClear(FArray);
  {VarClear(FCount)}FCount.Free;
  inherited Destroy;
end;

procedure TfrCrossGroupItem.Reset(NewGroupName: String; StartFrom: Integer);
var
  i: Integer;
  s: String;
begin
  FStartFrom := StartFrom;
  frSetCommaText(NewGroupName, FGroupName);
  for i := 0 to FCellItemsCount - 1 do
  begin
    FCount[i] := 0;
    s := FuncName(Parent.FCellFields[i]);
    if (s = 'max') or (s = 'min') then
      FArray[i] := Null else
      FArray[i] := 0;
  end;
end;

function TfrCrossGroupItem.IsBreak(GroupName: String): Boolean;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  frSetCommaText(GroupName, sl);
  Result := (FIndex < sl.Count) and (FIndex < FGroupName.Count) and
    (sl[FIndex] <> FGroupName[FIndex]);
  sl.Free;
end;

procedure TfrCrossGroupItem.AddValue(Value: Variant);
var
  i: Integer;
  s: String;
begin
  if TVarData(Value).VType >= varArray then
    for i := 0 to FCellItemsCount - 1 do
      if (Value[i] <> Null) and HasTotal(Parent.FCellFields[i]) then
      begin
        s := FuncName(Parent.FCellFields[i]);
        if (s = 'sum') or (s = 'count') then
          FArray[i] := FArray[i] + Value[i]
        else if s = 'min' then
        begin
          if (FArray[i] = Null) or (FArray[i] > Value[i]) then
            FArray[i] := Value[i];
        end
        else if s = 'max' then
        begin
          if FArray[i] < Value[i] then
            FArray[i] := Value[i];
        end
        else if s = 'avg' then
        begin
          FArray[i] := FArray[i] + Value[i];
          FCount[i] := FCount[i] + 1;
        end;
      end;
end;

procedure TfrCrossGroupItem.CheckAvg;
var
  i: Integer;
  s: String;
begin
  for i := 0 to FCellItemsCount - 1 do
  begin
    s := FuncName(Parent.FCellFields[i]);
    if s = 'avg' then
      if FCount[i] <> 0 then
        FArray[i] := FArray[i] / FCount[i] else
        FArray[i] := Null;
  end;
end;


{ TfrArray }

constructor TfrArray.Create(CellItemsCount: Integer);
begin
  inherited Create;
  FCellItemsCount := CellItemsCount;
  FArray := TStringList.Create;
  FArray.Sorted := True;
  FColumns := TStringList.Create;
  FColumns.Sorted := True;
end;

destructor TfrArray.Destroy;
begin
  Clear;
  FArray.Free;
  FColumns.Free;
  inherited Destroy;
end;

procedure TfrArray.Clear;
var
  i, j: Integer;
  sl: TList;
  p: PfrArrayCell;
begin
  for i := 0 to FArray.Count - 1 do
  begin
    sl := Pointer(FArray.Objects[i]);
    if sl <> nil then
      for j := 0 to sl.Count - 1 do
      begin
        p := sl[j];
        if p <> nil then
        begin
          VarClear(p.Items);
          Dispose(p);
        end;
      end;
    sl.Free;
  end;

  FArray.Clear;
end;

function TfrArray.GetCell(Index1, Index2: String; Index3: Integer): Variant;
var
  i1, i2: Integer;
  sl: TList;
  p: PfrArrayCell;
begin
  Result := Null;
  i1 := FArray.IndexOf(Index1);
  i2 := FColumns.IndexOf(Index2);
  if (i1 = -1) or (i2 = -1) or (Index3 >= FCellItemsCount) then Exit;
  i2 := Integer(FColumns.Objects[i2]);

  if i1 < FArray.Count then
    sl := Pointer(FArray.Objects[i1]) else
    sl := nil;
  if sl <> nil then
  begin
    if i2 < sl.Count then
      p := sl[i2] else
      p := nil;
    if p <> nil then
      Result := p^.Items[Index3];
  end;
end;

procedure TfrArray.SetCell(Index1, Index2: String; Index3: Integer; Value: Variant);
var
  i, j, i1, i2: Integer;
  sl: TList;
  p: PfrArrayCell;
begin
  i1 := FArray.IndexOf(Index1);
  i2 := FColumns.IndexOf(Index2);
  if i2 <> -1 then
    i2 := Integer(FColumns.Objects[i2]);

  if i1 = -1 then  // row does'nt exists, so create it
  begin
    sl := TList.Create;
    FArray.AddObject(Index1, sl);
    i1 := FArray.IndexOf(Index1);
  end;

  if i2 = -1 then  // column does'nt exists, so create it
  begin
    FColumns.AddObject(Index2, TObject(FColumns.Count));
    i2 := FColumns.Count - 1;
  end;

  sl := Pointer(FArray.Objects[i1]);
  p := nil;
  if i2 < sl.Count then
    p := sl[i2]
  else
  begin
    i2 := i2 - sl.Count;
    for i := 0 to i2 do
    begin
      New(p);
      p^.Items := VarArrayCreate([-1, FCellItemsCount - 1], varVariant);
      for j := -1 to FCellItemsCount - 1 do
        p^.Items[j] := Null;
      sl.Add(p);
    end;
  end;
  p^.Items[Index3] := Value;
end;

function TfrArray.GetCellByIndex(Index1, Index2, Index3: Integer): Variant;
var
  sl: TList;
  p: PfrArrayCell;
begin
  Result := Null;
  if (Index1 = -1) or (Index2 = -1) or (Index3 >= FCellItemsCount) then Exit;
  if Index2 < FColumns.Count then
    Index2 := Integer(FColumns.Objects[Index2]);

  if Index1 < FArray.Count then
    sl := Pointer(FArray.Objects[Index1]) else
    sl := nil;
  if sl <> nil then
  begin
    if Index2 < sl.Count then
      p := sl[Index2] else
      p := nil;
    if p <> nil then
      Result := p^.Items[Index3];
  end;
end;

function TfrArray.GetCellArray(Index1, Index2: Integer): Variant;
var
  sl: TList;
  p: PfrArrayCell;
begin
  Result := Null;
  if (Index1 = -1) or (Index2 = -1) then Exit;
  if Index2 < FColumns.Count then
    Index2 := Integer(FColumns.Objects[Index2]);

  if Index1 < FArray.Count then
    sl := Pointer(FArray.Objects[Index1]) else
    sl := nil;
  if sl <> nil then
  begin
    if Index2 < sl.Count then
      p := sl[Index2] else
      p := nil;
    if p <> nil then
      Result := p^.Items;
  end;
end;

procedure TfrArray.SetCellArray(Index1, Index2: Integer; Value: Variant);
var
  i: Integer;
  sl: TList;
  p: PfrArrayCell;
begin
  if (Index1 = -1) or (Index2 = -1) then Exit;
  Cell[FArray[Index1], Columns[Index2], 0] := 0;

  if Index2 < FColumns.Count then
    Index2 := Integer(FColumns.Objects[Index2]);

  if Index1 < FArray.Count then
    sl := Pointer(FArray.Objects[Index1]) else
    sl := nil;
  if sl <> nil then
  begin
    if Index2 < sl.Count then
      p := sl[Index2] else
      p := nil;
    if p <> nil then
      for i := 0 to FCellItemsCount - 1 do
        p^.Items[i] := Value[i];
  end;
end;


{ TfrCross }

{$IFNDEF IBO}
constructor TfrCross.Create(DS: TDataSet; RowFields, ColFields, CellFields: String);
{$ELSE}
constructor TfrCross.Create(DS: TIB_Dataset; RowFields, ColFields, CellFields: String);
{$ENDIF}
begin
  FDataSet := TfrTDataSet(DS);
  FRowFields := TStringList.Create;
  FColFields := TStringList.Create;
  FCellFields := TStringList.Create;

  while RowFields[Length(RowFields)] in ['+', ';'] do
    RowFields := Copy(RowFields, 1, Length(RowFields) - 1);
  while ColFields[Length(ColFields)] in ['+', ';'] do
    ColFields := Copy(ColFields, 1, Length(ColFields) - 1);

  frSetCommaText(RowFields, FRowFields);
  frSetCommaText(ColFields, FColFields);
  frSetCommaText(CellFields, FCellFields);

  inherited Create(FCellFields.Count);
end;

destructor TfrCross.Destroy;
begin
  FRowFields.Free;
  FColFields.Free;
  FCellFields.Free;
  inherited Destroy;
end;

procedure TfrCross.Build;
var
  i: Integer;
  f: TfrTField;
  v: Variant;
  s1, s2: String;

  function GetFieldValues(sl: TStringList): String;
  var
    i, j, n: Integer;
    s: String;
    f: TfrTField;
    v: Variant;
    d: Double;
  begin
    Result := '';
    for i := 0 to sl.Count - 1 do
    begin
      s := PureName(sl[i]);
      f := TfrTField(FDataSet.FindField(CurReport.Dictionary.RealFieldName[s]));
      v := f.Value;
      if (TVarData(v).VType = varOleStr) or (TVarData(v).VType = varString) then
        Result := Result + f.AsString + ';'
      else
      begin
        if v = Null then
          d := 0
        else
        begin
          d := v;
          if sl = FRowFields then
            FRowTypes[i] := v
          else if sl = FColFields then
            FColTypes[i] := v;
        end;
        s := Format('%2.6f', [d]);
        n := 32 - Length(s);
        for j := 1 to n do
          s := ' ' + s;

        Result := Result + s + ';';
      end;
    end;
    if Result <> '' then
      Result := Copy(Result, 1, Length(Result) - 1);
  end;

  procedure FormGroup(NewGroup, OldGroup: String; Direction: Boolean);
  var
    i, j: Integer;
    sl1, sl2: TStringList;

    procedure FormGroup1(Index: Integer);
    var
      i: Integer;
      s: String;
    begin
      s := '';
      for i := 0 to Index - 1 do
        s := s + sl1[i] + ';';
      s := s + sl1[Index] + '+;+';
      if Direction then
      begin
      // !!!!!!!!!!!!!!!!! START_GS
        if Index < FColFields.Count then
      // !!!!!!!!!!!!!!!!! FINISH_GS
          if HasTotal(FColFields[Index]) then
            Cell[Rows[0], s, 0] := 0
      end
      else
      // !!!!!!!!!!!!!!!!! START_GS
        if Index < FRowFields.Count then
      // !!!!!!!!!!!!!!!!! FINISH_GS
          if HasTotal(FRowFields[Index]) then
            Cell[s, Columns[0], 0] := 0;
    end;

  begin
    sl1 := TStringList.Create;
    sl2 := TStringList.Create;
    frSetCommaText(OldGroup, sl1);
    frSetCommaText(NewGroup, sl2);
    for i := 0 to sl1.Count - 1 do
      if (NewGroup = '') or (sl1[i] <> sl2[i]) then
      begin
        for j := sl1.Count - 1 downto i do
          FormGroup1(j);
        break;
      end;
    sl1.Free;
    sl2.Free;
  end;

  procedure MakeTotals(sl: TStringList; Direction: Boolean);
  var
    i: Integer;
    s, Old: String;
  begin
    Old := sl[0];
    i := 0;
    while i < sl.Count do
    begin
      s := sl[i];
      if (s <> Old) and (Pos('+', s) = 0) then
      begin
        FormGroup(s, Old, Direction);
        Old := s;
      end;
      Inc(i);
    end;
    FormGroup('', sl[sl.Count - 1], Direction);
  end;

  procedure CalcTotals(FieldsSl, RowsSl, ColumnsSl: TStringList);
  var
    i, j, k, i1: Integer;
    l: TList;
    cg: TfrCrossGroupItem;
  begin
    l := TList.Create;
    l.Add(TfrCrossGroupItem.Create(Self, '', FieldsSl.Count, FCellItemsCount)); // grand total
    for i := 0 to FieldsSl.Count - 1 do
      l.Add(TfrCrossGroupItem.Create(Self, ColumnsSl[0], i, FCellItemsCount));

    for i := 0 to RowsSl.Count - 1 do
    begin
      for k := 0 to FieldsSl.Count do
        TfrCrossGroupItem(l[k]).Reset(ColumnsSl[0], 0);
      for j := 0 to ColumnsSl.Count - 1 do
      begin
        for k := 0 to FieldsSl.Count do
        begin
          cg := TfrCrossGroupItem(l[k]);
          if cg.IsBreak(ColumnsSl[j]) or
            ((k = 0) and (j = ColumnsSl.Count - 1)) then
          begin
            if (k = 0) or HasTotal(FieldsSl[k - 1]) then
            begin
              cg.CheckAvg;
              if RowsSl = Rows then
              begin
                CellArray[i, j] := cg.Value;
                Cell[Rows[0], Columns[j], -1] := cg.FStartFrom;
              end
              else
              begin
                CellArray[j, i] := cg.Value;
                Cell[Rows[j], Columns[0], -1] := cg.FStartFrom;
              end;
            end;

            i1 := j;
            while i1 < ColumnsSl.Count do
            begin
              if Pos('+;+', ColumnsSl[i1]) = 0 then
                break;
              Inc(i1);
            end;
            if i1 < ColumnsSl.Count then
              cg.Reset(ColumnsSl[i1], j);
            break;
          end
          else if Pos('+;+', ColumnsSl[j]) = 0 then
            if RowsSl = Rows then
              cg.AddValue(CellArray[i, j]) else
              cg.AddValue(CellArray[j, i]);
        end;
      end;
    end;

    for i := 0 to FieldsSl.Count do
      TfrCrossGroupItem(l[i]).Free;
    l.Free;
  end;

  procedure CheckAvg;
  var
    i, j: Integer;
    v: Variant;
    n: TQuickIntArray;
    Check: Boolean;

    procedure CalcAvg(i1, j1: Integer);
    var
      i, j, k: Integer;
      v1: Variant;
    begin
      for i := 0 to FCellFields.Count - 1 do
      begin
        v[i] := 0;
        n[i] := 0;
      end;

      for i := CellByIndex[i1, 0, -1] to i1 - 1 do
        for j := CellByIndex[0, j1, -1] to j1 - 1 do
          if (not IsTotalRow[i]) and (not IsTotalColumn[j]) then
            for k := 0 to FCellFields.Count - 1 do
              if FuncName(FCellFields[k]) = 'avg' then
              begin
                v1 := CellByIndex[i, j, k];
                if v1 <> Null then
                begin
                  n[k] := n[k] + 1;
                  v[k] := v[k] + v1;
                end;
              end;
      for i := 0 to FCellFields.Count - 1 do
        if FuncName(FCellFields[i]) = 'avg' then
          if n[i] <> 0 then
            Cell[Rows[i1], Columns[j1], i] := v[i] / n[i] else
            Cell[Rows[i1], Columns[j1], i] := Null;
    end;

  begin
    v := VarArrayCreate([0, FCellFields.Count - 1], varVariant);
    n := TQuickIntArray.Create(FCellFields.Count);

    Check := False;
    for i := 0 to FCellFields.Count - 1 do
      if FuncName(FCellFields[i]) = 'avg' then
      begin
        Check := True;
        break;
      end;

    if Check then
      for i := 0 to Rows.Count - 1 do
        if IsTotalRow[i] or (i = Rows.Count - 1) then
          for j := 0 to Columns.Count - 1 do
            if IsTotalColumn[j] or (j = Columns.Count - 1) then
              CalcAvg(i, j);

    for i := 0 to Rows.Count - 1 do
      Cell[Rows[i], Columns[0], -1] := Null;
    for i := 0 to Columns.Count - 1 do
      Cell[Rows[0], Columns[i], -1] := Null;

    VarClear(v);
    n.Free;//VarClear(n);
  end;

  procedure MakeColumnHeader;
  var
    i, j, n, cn: Integer;
    s: String;
    sl, sl1: TStringList;
    Flag: Boolean;
    d: Double;
    v: Variant;

    function CompareSl(Index: Integer): Boolean;
    begin
      Result := (sl.Count > Index) and (sl1.Count > Index) and (sl[Index] = sl1[Index]);
    end;

  begin
    sl := TStringList.Create;
    sl1 := TStringList.Create;
    cn := CharCount(';', Columns[0]) + 1; // height of header
    FTopLeftSize.cy := cn;

    for i := 0 to cn do
      Cell[Chr(i), Columns[0], 0] := '';

    for i := 0 to Columns.Count - 1 do
      Cell[#0, Columns[i], -1] := frftTop or frftBottom;

    Cell[#0, Columns[0], 0] := FHeaderString;
    Cell[#0, Columns[0], -1] := frftLeft or frftTop or frftBottom;
    Cell[#0, Columns[Columns.Count - 1], -1] := frftTop or frftRight;

    for i := 1 to cn do
      Cell[Chr(i), Columns[Columns.Count - 1], -1] := frftLeft or frftRight;

    Cell[#1, Columns[Columns.Count - 1],  0] := FColumnGrandTotalString;
    Cell[#1, Columns[Columns.Count - 1], -1] := frftLeft or frftTop or frftRight;

    for i := 0 to Columns.Count - 2 do
    begin
      s := Columns[i];
      frSetCommaText(s, sl);
      if Pos('+;+', s) <> 0 then
      begin
        n := CharCount(';', s);

        for j := 1 to n - 1 do
          Cell[Chr(j), s, -1] := frftTop;

        for j := n to cn do
          if j = n then
          begin
            Cell[Chr(j), s, 0] := FColumnTotalString;
            Cell[Chr(j), s, -1] := frftRight or frftLeft or frftTop;
          end
          else
            Cell[Chr(j), s, -1] := frftRight or frftLeft;
      end
      else
      begin
        Flag := False;
        for j := 0 to cn - 1 do
          if (not Flag) and CompareSl(j) then
            Cell[Chr(j + 1), s, -1] := frftTop
          else
          begin
            if TVarData(FColTypes[j]).VType = varDate then
            begin
              d := StrToFloat(Trim(sl[j]));
              TVarData(FColTypes[j]).VDate := d;
              v := FColTypes[j];
            end
            else if (TVarData(FColTypes[j]).VType = varString) or
                    (TVarData(FColTypes[j]).VType = varOleStr) or
                    (TVarData(FColTypes[j]).VType = varEmpty) or
                    (TVarData(FColTypes[j]).VType = varNull) then
              v := Trim(sl[j])
            else
            begin
              d := StrToFloat(Trim(sl[j]));
              v := FloatToStr(d);
            end;
            Cell[Chr(j + 1), s, 0] := v;
            Cell[Chr(j + 1), s, -1] := frftTop or frftLeft or frftRight;
            Flag := True;
          end;
      end;
      sl1.Assign(sl);
    end;

    sl.Free;
    sl1.Free;
  end;

  procedure MakeRowHeader;
  var
    i, j, n, cn: Integer;
    s: String;
    sl, sl1: TStringList;
    Flag: Boolean;
    d: Double;
    v: Variant;

    function CompareSl(Index: Integer): Boolean;
    begin
      Result := (sl.Count > Index) and (sl1.Count > Index) and (sl[Index] = sl1[Index]);
    end;

    procedure CellOr(Index1, Index2: String; Value: Integer);
    var
      v: Variant;
    begin
      v := Cell[Index1, Index2, -1];
      if v = Null then
        v := 0;
      v := v or Value;
      Cell[Index1, Index2, -1] := v;
    end;

  begin
    sl := TStringList.Create;
    sl1 := TStringList.Create;
    cn := CharCount(';', Rows[FTopLeftSize.cy + 1]) + 1 + Ord(DoDataCol); // width of header
    FTopLeftSize.cx := cn;

    for i := 0 to cn - 1 do
      Cell[Rows[0], Chr(i), 0] := '';

    Cell[Rows[Rows.Count - 1], #0, 0] := FRowGrandTotalString;
    Cell[Rows[Rows.Count - 1], #0, -1] := frftTop or frftBottom or frftLeft;

    for i := 1 to cn - 1 do
      Cell[Rows[Rows.Count - 1], Chr(i), -1] := frftTop or frftBottom;

    if DoDataCol then
    begin
      for i := FTopLeftSize.cy + 1 to Rows.Count - 1 do
      begin
        Cell[Rows[i], Chr(cn-1), 0]  := DataStr;
        Cell[Rows[i], Chr(cn-1), -1] := 15;
      end;
    end;

    for i := 0 to FTopLeftSize.cy do
      for j := 0 to cn - 1 do
        Cell[Chr(i), Chr(j), -1] := 0;

    for i := FTopLeftSize.cy + 1 to Rows.Count - 2 do
    begin
      s := Rows[i];
      frSetCommaText(s, sl);
      if Pos('+;+', s) <> 0 then
      begin
        n := CharCount(';', s);

        for j := 1 to n - 1 do
          Cell[s, Chr(j - 1), -1] := frftLeft;

        for j := n to cn - ord(DoDataCol) do
          if j = n then
          begin
            Cell[s, Chr(j - 1), 0] := FRowTotalString;
            Cell[s, Chr(j - 1), -1] := frftLeft or frftTop;
          end
          else
            Cell[s, Chr(j - 1), -1] := frftTop or frftBottom;
      end
      else
      begin
        Flag := False;
        for j := 0 to cn - 1 - ord(DoDataCol) do
          if (not Flag) and CompareSl(j) then
            Cell[s, Chr(j), -1] := frftLeft
          else
          begin
            if TVarData(FRowTypes[j]).VType = varDate then
            begin
              d := StrToFloat(Trim(sl[j]));
              TVarData(FRowTypes[j]).VDate := d;
              v := FRowTypes[j];
            end
            else if (TVarData(FRowTypes[j]).VType = varString) or
                    (TVarData(FRowTypes[j]).VType = varOleStr) or
                    (TVarData(FRowTypes[j]).VType = varEmpty) or
                    (TVarData(FRowTypes[j]).VType = varNull) then
              v := Trim(sl[j])
            else
            begin
              d := StrToFloat(Trim(sl[j]));
              v := FloatToStr(d);
            end;
            Cell[s, Chr(j), 0] := v;
            Cell[s, Chr(j), -1] := frftTop or frftLeft;
            Flag := True;
          end;
      end;
      sl1.Assign(sl);
    end;

    sl.Free;
    sl1.Free;

    for i := cn to Columns.Count - 1 do
      CellOr(Rows[Rows.Count - 1], Columns[i], 15);
    for i := cn to Columns.Count - 1 do
      CellOr(Rows[FTopLeftSize.cy], Columns[i], frftBottom);
    for i := 0 to cn - 1 - ord(DoDataCol) do
      CellOr(Rows[Rows.Count - 2], Columns[i], frftBottom);
  end;

begin
  FDataSet.Open;
  FDataSet.First;
  while not FDataSet.EOF do
  begin
    for i := 0 to FCellFields.Count - 1 do
    begin
      f := TfrTField(FDataSet.FindField(CurReport.Dictionary.RealFieldName[PureName(FCellFields[i])]));

      if f = nil then
        raise Exception.Create('В отчете используется поле "'
          + CurReport.Dictionary.RealFieldName[PureName(FCellFields[i])]
          + '", которого нет в запросе.');

      if FuncName(FCellFields[i]) = 'count' then
      begin
        v := 0;
        if f.Value <> Null then
          v := 1;
      end
      else
        v := f.Value;

      s1 := GetFieldValues(FRowFields);
      s2 := GetFieldValues(FColFields);
      if Cell[s1, s2, i] = Null then
        Cell[s1, s2, i] := v else
        Cell[s1, s2, i] := Cell[s1, s2, i] + v;
    end;
    FDataSet.Next;
  end;

  if Columns.Count = 0 then Exit;
  MakeTotals(Columns, True);
  Cell[Rows[0], Columns[Columns.Count - 1] + '+', 0] := 0;
  MakeTotals(Rows, False);
  Cell[Rows[Rows.Count - 1] + '+', Columns[0], 0] := 0;

  CalcTotals(FColFields, Rows, Columns);
  CalcTotals(FRowFields, Columns, Rows);
  CheckAvg;

  MakeColumnHeader;
  MakeRowHeader;
end;

function TfrCross.GetIsTotalRow(Index: Integer): Boolean;
begin
  Result := Pos('+;+', Rows[Index]) <> 0;
end;

function TfrCross.GetIsTotalColumn(Index: Integer): Boolean;
begin
  Result := Pos('+;+', Columns[Index]) <> 0;
end;

{ TQuickArray }

constructor TQuickIntArray.Create(Length: Integer);
begin
  Len := Length;
  GetMem(arr, Len * SizeOf(TIntArrayCell));
  for Length := 0 to Len - 1 do
    arr[Length] := 0;
end;

destructor TQuickIntArray.Destroy;
begin
  FreeMem(arr, Len *  SizeOf(TIntArrayCell));
  inherited;
end;

function TQuickIntArray.GetCell(Index: Integer): Integer;
begin
  Result := arr[Index];
end;

procedure TQuickIntArray.SetCell(Index: Integer; const Value: Integer);
begin
  arr[Index] := Value;
end;

end.
