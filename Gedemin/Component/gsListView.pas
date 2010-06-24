unit gsListView;

interface

uses
  SysUtils, Classes, Windows, Messages, ComCtrls, Graphics, Controls, Forms,
  CommCtrl {$IFDEF DELPHI6_UP}, Variants {$ENDIF}, ActnList;

type
  TSort = (svUp, svDown);
  THeadCell = record
    Sort: TSort;
  end;

  TSortNotifyEvent = procedure(Sender: TObject; Column: integer; Sort: TSort; Allowed: Boolean) of object;

{  TDVarMode = (vmInt, vmStr, vmFloat, vmBool, vmDate, vmObj, vmPtr, vmArr, vmNull);

  TgsSortType = (stText, stNumeric, stDateTime);

  TgsListColum = class(TListColumn)
  private
    FSortType: TgsSortType;
    procedure SetSortType(Value: TgsSortType);
  published
    property SortType: TgsSortType read FSortType write SetSortType default stText;
  end;      }

  TgsListView = class(TListView)
  private
    FHeadCells: array of THeadCell;
    SList: TStringList;
    FOnSorted:  TSortNotifyEvent;
    ColumnToSort, LastColumn: integer;
    FDefHeaderProc: Pointer;
    FHeaderHandle: HWND;
    FHeaderInstance: Pointer;
    FAdvancedShaft: Boolean;
    function Count: integer;
    function GetSort(index: integer): TSort;
    procedure SetSort(index: integer; const Value: TSort);
    procedure ReSort(index: integer);
    procedure DrawShaft(index: integer; dc: HDC);
    procedure WMParentNotify(var Message: TWMParentNotify); message WM_PARENTNOTIFY;
    procedure HeaderWndProc(var Message: TMessage);
    procedure OnItemsChange(Sender: TObject; Item: TListItem);
    procedure OnItemChanging(Sender: TObject; Item: TListItem; Change: TItemChange; var AllowChange: Boolean);
    procedure OnSectionClick(Sender: TObject; Column: TListColumn);
    procedure OnLVCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
//    procedure PrepareSort(Index: Integer);
  private
    FActionList: TActionList;
    FImages: TImageList;
    FFindAct, FFindNextAct: TAction;
    FSearchValue: String;

    procedure CreateActionList;
    procedure DoOnFindExecute(Sender: TObject);
    procedure DoOnFindNextExecute(Sender: TObject);
    procedure FindColumn(const FromStart: Boolean);
    procedure OnActionUpdate(Sender: TObject);

  protected
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
//    function DoCompare(Item1, Item2: Variant): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Sort[index: integer]: TSort read GetSort write SetSort;
    property OnSorted: TSortNotifyEvent read FOnSorted write FOnSorted;
    property AdvancedShaft: boolean read FAdvancedShaft write FAdvancedShaft default false;
  end;

//  function VarMode(AValue: Variant): TDVarMode;

  procedure Register;


implementation

uses
  Dialogs, JclStrings, ImgList, Menus;

const
  MENU_FIND = 'Найти...';
  MENU_FINDNEXT = 'Найти следующее';

{function VarMode(AValue: Variant): TDVarMode;
var
  I: Integer;
begin
  Result := vmNull;
  I := varType(AValue);
  case I of
    varSmallint, varInteger, varByte: Result := vmInt;
    varSingle, varDouble, varCurrency: Result := vmFloat;
    varDate: Result := vmDate;
    varOleStr, varString, varStrArg:
    begin
      try
        //Делфи не всегда определяет TDateTime как varDate, поэтому используем проверку
        VarToDateTime(AValue);
        Result := vmDate;
      except
        Result := vmStr;
      end;
    end;
    varBoolean: Result := vmBool;
    varDispatch, varAny: Result := vmObj;
    varEmpty, varNull, varError, varVariant, varUnknown: Result := vmNull;
    else begin
      i := i and not varTypeMask;
      if i = varArray then
        Result := vmArr;
      if i = varByRef then
        Result := vmPtr;
    end;
  end;
end;      }

procedure TgsListView.CreateWnd;
begin
  FHeaderHandle := 0;
  inherited CreateWnd;
  ColumnToSort := LastColumn;
end;

constructor TgsListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SList := TStringList.Create;
  {$IFDEF DELPHI6_UP}
  FHeaderInstance := Classes.MakeObjectInstance(HeaderWndProc);
  {$ELSE}
  FHeaderInstance := Forms.MakeObjectInstance(HeaderWndProc);
  {$ENDIF}
  FAdvancedShaft := false;
  ViewStyle := vsReport;
  LastColumn := -1;
  ColumnToSort := -1;
  SetLength(FHeadCells, Count);
  OnColumnClick := OnSectionClick;
  OnInsert := OnItemsChange;
  OnDeletion := OnItemsChange;
  OnChanging := OnItemChanging;
  OnCompare := OnLVCompare;

  FFindAct := nil;
  FFindNextAct := nil;

  if not (csDesigning in ComponentState) then
  begin
    FActionList := TActionList.Create(Self);
    FImages := TImageList.Create(Self);

    CreateActionList;
  end else
  begin
    FActionList := nil;
    FImages := nil;
  end;
end;

destructor TgsListView.Destroy;
begin
  if FHeaderHandle <> 0 then begin
    SetWindowLong(FHeaderHandle, GWL_WNDPROC, LongInt(FDefHeaderProc));
  end;
  SList.Free;
  {$IFDEF DELPHI6_UP}
  Classes.FreeObjectInstance(FHeaderInstance);
  {$ELSE}
  Forms.FreeObjectInstance(FHeaderInstance);
  {$ENDIF}
  inherited Destroy;
end;

procedure TgsListView.OnItemsChange(Sender: TObject; Item: TListItem);
begin
  ColumnToSort := -1;
  LastColumn := -1;
  RedrawWindow(FHeaderHandle, nil, 0, RDW_INVALIDATE);
end;

procedure TgsListView.OnItemChanging(Sender: TObject; Item: TListItem; Change: TItemChange; var AllowChange: Boolean);
begin
  if Change = ctState then
    LastColumn := -1;
end;

function TgsListView.Count;
begin
  Result := Length(FHeadCells);
end;

procedure TgsListView.DrawShaft(index: Integer; DC: HDC);
const
  diam = 6;
var
  x, koef, i, half_diam: integer;
  lPen: LOGPEN;
  aPen: HPEN;
  aBrush: HBRUSH;
begin
  half_diam := diam div 2;
  if Columns.Count-1 < index then exit;
  SetLength(FHeadCells, Columns.Count);
  if Visible or (csDesigning in ComponentState) then
  begin
    if Columns[index].Alignment = taLeftJustify then
    begin
      x := 0;
      for i := 0 to index - 1 do
        x := x + Columns[i].Width;
      if FAdvancedShaft then
        x := x + Canvas.TextWidth(Columns[index].Caption) + 22
      else
        x := x + Columns[index].Width;
      koef := 1;
    end else
    begin
      x := 0;
      for i := 0 to index-1 do
        x := x + Column[i].Width;
      if FAdvancedShaft then
        x := x + Columns[index].Width - Canvas.TextWidth(Columns[index].Caption) - 22;
      koef := -1;
    end;
    lPen.lopnStyle := PS_SOLID;
    lPen.lopnWidth.X := 1;
    lPen.lopnColor := ColorToRGB(clBtnShadow);
    aPen := CreatePenIndirect(lPen);
    SelectObject(DC, aPen);
    aBrush := CreateSolidBrush(ColorToRGB(clBtnShadow));
    SelectObject(DC, aBrush);
    try
      case FHeadCells[index].Sort of
        svUp: begin
          MoveToEx(DC, x - koef*((17 - diam) div 2 + diam), ((17 - half_diam) div 2) + half_diam, nil);
          LineTo(DC, x - koef*((17 - diam) div 2), ((17 - half_diam) div 2) + half_diam);
          LineTo(DC, x - koef*((17 - diam) div 2 + half_diam), (17 - half_diam) div 2);
          LineTo(DC, x - koef*((17 - diam) div 2 + diam), ((17 - half_diam) div 2) + half_diam);
          ExtFloodFill(DC, x - koef*((17 - diam) div 2 + diam div 2), ((17 - half_diam) div 2) + half_diam - 1, ColorToRGB(clBtnShadow), FLOODFILLBORDER);
        end;
        svDown: begin
          MoveToEx(DC, x - koef*((17 - diam) div 2 + diam), (17 - half_diam) div 2, nil);
          LineTo(DC, x - koef*((17 - diam) div 2), (17 - half_diam) div 2);
          LineTo(DC, x - koef*((17 - diam) div 2 + half_diam), ((17 - half_diam) div 2) + half_diam);
          LineTo(DC, x - koef*((17 - diam) div 2 + diam), (17 - half_diam) div 2);
          ExtFloodFill(DC, x - koef*((17 - diam) div 2 + diam div 2), ((17 - half_diam) div 2) + 1, ColorToRGB(clBtnShadow), FLOODFILLBORDER);
        end;
      end;
    finally
      DeleteObject(aPen);
      DeleteObject(aBrush);
    end;
  end;
end;

procedure TgsListView.SetSort(index: Integer; const Value: TSort);
begin
  SetLength(FHeadCells, Columns.Count);
  if (index >= 0) and (index <= Count-1)then
  begin
    if (ColumnToSort <> index) or (FHeadCells[index].Sort <> Value)then
    begin
      FHeadCells[index].Sort := Value;
      ColumnToSort := index;
      AlphaSort;
      LastColumn := index;
      RedrawWindow(FHeaderHandle, nil, 0, RDW_INVALIDATE);
    end;
  end;
end;

function TgsListView.GetSort(index: Integer): TSort;
begin
  SetLength(FHeadCells, Columns.Count);
  Result := svDown;
  if (index >= 0) and (index <= Count-1) then
    Result := FHeadCells[index].Sort;
end;

procedure TgsListView.ReSort(index: Integer);
begin
  if FHeadCells[index].Sort = svDown then
    FHeadCells[index].Sort := svUp
  else
    FHeadCells[index].Sort := svDown;
end;

procedure TgsListView.OnSectionClick(Sender: TObject; Column: TListColumn);
var
  sortAccepted: boolean;
begin
  SetLength(FHeadCells, Columns.Count);
  ColumnToSort := Column.Index;
  if ColumnToSort = LastColumn then
    ReSort(ColumnToSort);
  sortAccepted := True;
  if Assigned(FOnSorted) then
    FOnSorted(Self, ColumnToSort, FHeadCells[ColumnToSort].Sort, sortAccepted);
  if sortAccepted then
    AlphaSort;
  LastColumn := ColumnToSort;
  RedrawWindow(FHeaderHandle, nil, 0, RDW_INVALIDATE);
end;

procedure TgsListView.WMParentNotify(var Message: TWMParentNotify);
begin
  with Message do
    if (Event = WM_CREATE) and (FHeaderHandle = 0) then
    begin
      FHeaderHandle := ChildWnd;
      FDefHeaderProc := Pointer(GetWindowLong(FHeaderHandle, GWL_WNDPROC));
      SetWindowLong(FHeaderHandle, GWL_WNDPROC, LongInt(FHeaderInstance));
    end;
  inherited;
end;

procedure TgsListView.HeaderWndProc(var Message: TMessage);
var
  headDC: HDC;
begin
  try
    with Message do
    begin
      case Msg of
        WM_PAINT:
          begin
            Result := CallWindowProc(FDefHeaderProc, FHeaderHandle, Msg, WParam, LParam);
            if (ColumnToSort > -1) and (Columns.Count-1 >= ColumnToSort)
            and (Columns[ColumnToSort].Width - Canvas.TextWidth(Columns[ColumnToSort].Caption) >= 22) then
            begin
              headDC := GetWindowDC(FHeaderHandle);
              DrawShaft(ColumnToSort, headDC);
              ReleaseDC(FHeaderHandle, headDC);
            end;
          end;
        else
          Result := CallWindowProc(FDefHeaderProc, FHeaderHandle, Msg, WParam, LParam);
      end;
    end;
  except
    Application.HandleException(Self);
  end;
end;

procedure TgsListView.OnLVCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  ix: Integer;
begin
  if ColumnToSort = 0 then
  begin
    case FHeadCells[ColumnToSort].Sort of
      svUp: Compare := CompareStr(Item1.Caption, Item2.Caption);
      svDown: Compare := - CompareStr(Item1.Caption, Item2.Caption);
    end;
  end
  else begin
    ix := ColumnToSort - 1;
    case FHeadCells[ColumnToSort].Sort of
      svUp: Compare := CompareStr(Item1.SubItems[ix], Item2.SubItems[ix]);
      svDown: Compare := - CompareStr(Item1.SubItems[ix], Item2.SubItems[ix]);
    end;
  end;
end;

procedure TgsListView.CreateActionList;

  function NewAction: TAction;
  begin
    Result := TAction.Create(FActionList);
    Result.ActionList := FActionList;
    Result.OnUpdate := OnActionUpdate;
  end;

begin
  FImages.Width := 16;
  FImages.Height := 16;

  FImages.GetResource(rtBitmap, 'ALL', 16, [lrDefaultColor], clOlive);
  FActionList.Images := FImages;

  // Пункт Найти
  FFindAct := NewAction;
  FFindAct.OnExecute := DoOnFindExecute;
  FFindAct.ShortCut := TextToShortCut('Ctrl+F');
  FFindAct.Caption := MENU_FIND;
  FFindAct.ImageIndex := 23;
  FFindAct.Hint := MENU_FIND;

  // Пункт Найти След
  FFindNextAct := NewAction;
  FFindNextAct.OnExecute := DoOnFindNextExecute;
  FFindNextAct.ShortCut := VK_F3;
  FFindNextAct.Caption := MENU_FINDNEXT;
  FFindNextAct.ImageIndex := 24;
  FFindNextAct.Hint := MENU_FINDNEXT;

end;

procedure TgsListView.DoOnFindExecute(Sender: TObject);
begin
  if InputQuery('Поиск', 'Введите наименование:', FSearchValue) then
  begin
    FindColumn(True)
  end else
    FSearchValue := '';
end;

procedure TgsListView.DoOnFindNextExecute(Sender: TObject);
begin
  if FSearchValue = '' then
    FFindAct.Execute
  else
    FindColumn(False);
end;

procedure TgsListView.FindColumn(const FromStart: Boolean);
var
  K, I, J: Integer;
begin
  K := 0;
  if not FromStart then
    if Self.Selected <> nil then
      K := Self.Selected.Index + 1;
  for I := K to Self.Items.Count - 1 do
  begin
    if (StrIPos(FSearchValue, Self.Items[I].Caption) <> 0)
      or (StrIPos(FSearchValue, Self.Items[I].SubItems[0]) <> 0) then
    begin
      Self.ItemFocused := Self.Items[I];
      Self.Selected := Self.Items[I];

      for J := 0 to Self.Items.Count - 1 do
        if J <> I then
          Self.Items[J].Selected := False;

      Self.Items[I].MakeVisible(False);
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

procedure TgsListView.OnActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (Self.Items.Count > 1);
end;

procedure TgsListView.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);

  if (Key = VK_F3) and (Shift = []) and (Assigned(FFindNextAct)) then
    FFindNextAct.Execute
  else if (Key = Word('F')) and ([ssCtrl] = Shift) and (Assigned(FFindAct)) then
    FFindAct.Execute;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TgsListView]);
end;

{ TgsListColum }

{procedure TgsListColum.SetSortType(Value: TgsSortType);
begin
  if FSortType <> Value then
  begin
    FSortType := Value;
    Changed(False);
  end;
end;            }

end.
