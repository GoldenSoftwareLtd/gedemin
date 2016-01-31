unit gedemin_cc_frmMain_unit;

interface

uses
  Classes, Controls, Forms, SysUtils, FileCtrl, StdCtrls, Windows,
  Menus, ExtCtrls, ComCtrls, Grids, DBGrids, Db, IBCustomDataSet, DBCtrls, Messages,
  gedemin_cc_const, Buttons, Dialogs, Graphics, SyncObjs, Gauges, xProgr;

const
  RowColors: array[Boolean] of TColor = ($E7E7E7, $FFFFFF);

  SizeArr = 12;

  StrArr: array[0..SizeArr] of String = (
    'Дата и время',
    'ИП платформы',
    'ИП ОС',
    'Путь к БД',
    'Имя хоста',
    'IP-адрес хоста',
    'Класс объекта',
    'Подтип объекта',
    'Имя объекта',
    'ID объекта',
    'ID операции',
    'Хэш запроса',
    'Сообщение'
  );

type
  TDBGrid = class(DBGrids.TDBGrid)
  private
    LB: TListBox;
    procedure _OnExit(Sender: TObject);
    procedure _OnClick(Sender: TObject);
    procedure _OnMouseDown(Sender: TObject; Button: TMouseButton;
                           Shift: TShiftState; X, Y: Integer);
  protected
    procedure DoExit; override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
  public
    FFilterableColumns: TList;
    FFilteredColumns: TList;
    FFilteringColumn: TColumn;
    FFilteredCache: TStringList;
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  published
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  end;

  Tfrm_gedemin_cc_main = class(TForm)
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlBottom: TPanel;
    pnlCenter: TPanel;
    pnlFilt: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    DBGr: TDBGrid;
    SB: TStatusBar;
    PopMenuLB: TPopupMenu;
    DoneClient: TMenuItem;
    lbClients: TListBox;
    mLog: TMemo;
    sbtnLeft: TSpeedButton;
    sbtnRight: TSpeedButton;
    SaveLog1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    OpenLog1: TMenuItem;
    btnDoneAll: TButton;
    PB: TProgressBar;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbClientsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoneClientClick(Sender: TObject);
    procedure btnDoneAllClick(Sender: TObject);
    procedure sbtnLeftClick(Sender: TObject);
    procedure sbtnRightClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SaveLog1Click(Sender: TObject);
    procedure OpenLog1Click(Sender: TObject);
    procedure DBGrDrawColumnCell(Sender: TObject; const ARect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);

  private
    FCurrStr: String;
    FCriticalSection: TCriticalSection;

    procedure WMLBRef(var Msg: TMessage);
      message WM_CC_REFRESH_LB;

    procedure WMMemoRef(var Msg: TMessage);
      message WM_CC_REFRESH_MEMO;

    procedure WMGridRef(var Msg: TMessage);
      message WM_CC_REFRESH_GRID;
  end;

var
  frm_gedemin_cc_main: Tfrm_gedemin_cc_main;
  WArr: array of Integer;

implementation

uses
  gedemin_cc_DataModule_unit, gedemin_cc_TCPServer_unit;

{$R *.DFM}

procedure Tfrm_gedemin_cc_main.FormCreate(Sender: TObject);
begin
  FCriticalSection := TCriticalSection.Create;
  SB.Panels[0].Text := DM.IBDB.DatabaseName;
  ccTCPServer.RefGrHandle := Self.Handle;
  ccTCPServer.RefMemoHandle := Self.Handle;
  ccTCPServer.RefLBHandle := Self.Handle;
  ccTCPServer.Update;
  btnDoneAll.Enabled := false;
end;

procedure Tfrm_gedemin_cc_main.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  i, c : Integer;
begin
  ccTCPServer.RefLBHandle := 0;
  ccTCPServer.RefMemoHandle := 0;
  ccTCPServer.RefGrHandle := 0;
  c := lbClients.Items.Count;
  if c > 0 then
  begin
    for i := 0 to c - 1 do
      Dispose(TClientP(lbClients.Items.Objects[i]));
  end;
  FCriticalSection.Free;
end;

procedure Tfrm_gedemin_cc_main.WMLBRef(var Msg: TMessage);
var
  i: Integer;
  ClientP: TClientP;
begin
  try
    with ccTCPServer.FClients.LockList do
    begin
      lbClients.Clear;
      if Count > 0 then
      begin
        for i := 0 to Count - 1 do
        begin
          ClientP := TClientP(Items[i]);
          lbClients.Items.AddObject(ClientP.Host, TObject(ClientP));
        end;
        btnDoneAll.Enabled := true;
      end
      else
      begin
        btnDoneAll.Enabled := false;
      end;
    end;
  finally
    ccTCPServer.FClients.UnlockList;
  end;
end;

procedure Tfrm_gedemin_cc_main.WMMemoRef(var Msg: TMessage);
begin
  FCurrStr := PChar(Msg.LParam);
  mLog.Lines.Add(FCurrStr);
end;

procedure Tfrm_gedemin_cc_main.WMGridRef(var Msg: TMessage);
var
  i, cf, cc, FWidth, CWidth: Integer;
begin
  DBGr.Refresh;
  for i := 0 to SizeArr do
  begin
    DBGr.Columns[i].Title.Caption := StrArr[i];
  end;
  FWidth := 0;
  if DM.IBQ.RecordCount > 0 then
  begin
    cf := DBGr.FieldCount;
    cc := DBGr.Columns.Count;
    if (not Assigned(WArr)) then
    begin
      SetLength(WArr, cf);
      for i := 0 to cf - 1 do
        WArr[i] := Length(StrArr[i]) + 3;
    end;
    for i := 0 to cf - 1 do
    begin
      if (WArr[i] < Length(DBGr.Fields[i].Value)) then
      begin
        WArr[i] := Length(DBGr.Fields[i].Value);
      end;
      DBGr.Fields[i].DisplayWidth := WArr[i] + 1;
    end;
    for i := 0 to cc - 1 do
      FWidth := FWidth + DBGr.Columns[i].Width;
    FWidth := FWidth + DBGr.FieldCount;
    CWidth := DBGr.ClientWidth - FWidth;
    if CWidth > 0 then
      DBGr.Columns[cc - 1].Width := DBGr.Columns[cc - 1].Width + CWidth;
  end;
  DBGr.SetFocus;
end;

procedure Tfrm_gedemin_cc_main.lbClientsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pos: TPoint;
  i: Integer;
begin
  if (Button = mbRight) then
  begin
    pos.X := X;
    pos.Y := Y;
    i := lbClients.ItemAtPos(pos, true);
    if i >= 0 then
    begin
      lbClients.ItemIndex := i;
      lbClients.PopupMenu.AutoPopup := True;
    end
    else
      lbClients.PopupMenu.AutoPopup := False;
  end;
end;

procedure Tfrm_gedemin_cc_main.DoneClientClick(Sender: TObject);
var
  i, id: Integer;
  ClientP: TClientP;
begin
  i := lbClients.ItemIndex;
  ClientP := TClientP(lbClients.Items.Objects[i]);
  id := ClientP.ID;
  mLog.Lines.Add(IntToStr(id));
  FCriticalSection.Enter;
  try
    ccTCPServer.FDone := true;
    ccTCPServer.FID := ClientP.ID;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure Tfrm_gedemin_cc_main.btnDoneAllClick(Sender: TObject);
begin
  FCriticalSection.Enter;
  try
    ccTCPServer.FDoneAll := true;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure Tfrm_gedemin_cc_main.sbtnLeftClick(Sender: TObject);
begin
  if sbtnLeft.Caption = '<' then
  begin
    sbtnLeft.Caption := '>';
    pnlLeft.Width := 15;
    pnlFilt.Left := 15;
    pnlFilt.Width := pnlFilt.Width + 195;
    pnlCenter.Left := 15;
    pnlCenter.Width := pnlCenter.Width + 195;
  end
  else
  begin
    sbtnLeft.Caption := '<';
    pnlLeft.Width := 210;
    pnlFilt.Left := 210;
    pnlFilt.Width := pnlFilt.Width - 195;
    pnlCenter.Left := 210;
    pnlCenter.Width := pnlCenter.Width - 195;
  end;
end;

procedure Tfrm_gedemin_cc_main.sbtnRightClick(Sender: TObject);
begin
  if sbtnRight.Caption = '>' then
  begin
    sbtnRight.Caption := '<';
    pnlRight.Width := 15;
    pnlFilt.Width := pnlFilt.Width + 195;
    pnlCenter.Width := pnlCenter.Width + 195;
  end
  else
  begin
    sbtnRight.Caption := '>';
    pnlRight.Width := 210;
    pnlFilt.Width := pnlFilt.Width - 195;
    pnlCenter.Width := pnlCenter.Width - 195;
  end;
end;

procedure Tfrm_gedemin_cc_main.Exit1Click(Sender: TObject);
begin
  frm_gedemin_cc_main.Close;
end;

procedure Tfrm_gedemin_cc_main.SaveLog1Click(Sender: TObject);
var
  i: Integer;
  str: String;
  SL: TStrings;
  SD: TSaveDialog;
begin
  SL := TStringList.Create;
  try
    if not DBGr.DataSource.DataSet.Active then
      exit;
    DBGr.DataSource.DataSet.First;
    while not DBGr.DataSource.DataSet.Eof do
    begin
      str := '';
      for i := 0 to DBGr.FieldCount - 1 do
      begin
        str := str + DBGr.Fields[i].AsString + ' || ';
      end;
      SL.Add(str);
      DBGr.DataSource.DataSet.Next;
    end;
    SD := TSaveDialog.Create(Self);
    try
      SD.Title := 'Сохранение лога в файл ';
      SD.DefaultExt := 'txt';
      SD.Filter := 'Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*.*';
      SD.FileName := 'log.txt';
      SD.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing];
      if SD.Execute then
        SL.SaveToFile(SD.FileName);
    finally
      SD.Free;
    end;
  finally
    SL.Free;
  end;
end;

procedure Tfrm_gedemin_cc_main.OpenLog1Click(Sender: TObject);
var
  OD: TOpenDialog;
begin
  OD := TOpenDialog.Create(Self);
  try
    OD.Title := 'Открытие лога из файла ';
    OD.DefaultExt := 'txt';
    OD.Filter := 'Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*.*';
    OD.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing];
    if OD.Execute then
      mLog.Lines.LoadFromFile(OD.FileName);
  finally
    OD.Free;
  end;
end;

procedure Tfrm_gedemin_cc_main.DBGrDrawColumnCell(Sender: TObject;
  const ARect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  OddRow: Boolean;
  NewRect : TRect;
  PrevColor: TColor;
begin
  if (Sender is TDBGrid) then
  begin
    NewRect := ARect;
    NewRect.Left := NewRect.Left - 1;
    PrevColor := TDBGrid(Sender).Canvas.Brush.Color;
    TDBGrid(Sender).TitleFont.Style := [fsBold];
    TDBGrid(Sender).Canvas.Brush.Color := clBlack;
    TDBGrid(Sender).Canvas.FrameRect(NewRect);
    TDBGrid(Sender).Canvas.Brush.Color := PrevColor;
    TDBGrid(Sender).Options := [dgEditing,dgTitles,dgColumnResize,dgColLines,dgTabs,dgRowSelect,dgConfirmDelete,dgCancelOnExit];
    OddRow := Odd(TDBGrid(Sender).DataSource.DataSet.RecNo);
    TDBGrid(Sender).Canvas.Brush.Color := RowColors[OddRow];
    TDBGrid(Sender).Canvas.Font.Color := clBlack;

    if (gdSelected in State) or (gdFocused in State) then // ?
      TDBGrid(Sender).Canvas.Brush.Color := clHighlight;

    TDBGrid(Sender).DefaultDrawColumnCell(ARect, DataCol, Column, State);
  end;
end;

constructor TDBGrid.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FFilterableColumns := TList.Create;
  FFilteredColumns := TList.Create;
  FFilteringColumn := nil;
  LB := nil;
end;

destructor TDBGrid.Destroy;
begin
  FFilterableColumns.Free;
  FFilteredColumns.Free;
  FFilteringColumn.Free;

  inherited Destroy;
end;

procedure TDBGrid.DrawCell(ACol, ARow: Integer; ARect: TRect; AState: TGridDrawState);
var
  Sort: Boolean;
  DrawColumn: TColumn;
begin
  inherited;

  if (ACol >= 0) and (ACol < Columns.Count)
  then
    DrawColumn := Columns[ACol]
  else
    DrawColumn := nil;

  if (ARow = 0) and (gdFixed in AState) then
  begin
    with ARect, Canvas do
    begin
      if FFilteredColumns.IndexOf(DrawColumn) = -1 then
      begin
        Brush.Style := bsSolid;
        Brush.Color := clBtnFace;
        Pen.Style := psSolid;
        Pen.Color := clBlack;
        Pen.Mode := pmBlack;
      end else
      begin
        Brush.Style := bsSolid;
        Brush.Color := clBtnFace;
        Pen.Style := psSolid;
        Pen.Color := clBlue;
        Pen.Mode := pmBlack;
      end;

      FillRect(Rect(Right - 13, Bottom - 14, Right - 1, Bottom - 1));

      Polygon([Point(Right - 11, Bottom - 10),
               Point(Right - 3, Bottom - 10),
               Point(Right - 7, Bottom - 6)]);
    end;

    if (DrawColumn <> nil)
      and (DataSource <> nil)
      and (DataSource.DataSet is TIBCustomDataSet)
      and (DrawColumn.FieldName > '') then
    begin
      if DrawColumn.FieldName = TIBCustomDataSet(DataSource.DataSet).SortField then
      with ARect, Canvas do
      begin
        Brush.Style := bsSolid;
        Brush.Color := clRed;
        Pen.Style := psSolid;
        Pen.Color := clMaroon;
        Pen.Mode := pmCopy;

        Sort := TIBCustomDataSet(DataSource.DataSet).SortAscending;

        if Sort then
          Polygon([Point(Right, Top),
            Point(Right - 6, Top),
            Point(Right, Top + 6)])
        else
          Polygon([Point(Left, Top),
            Point(Left + 6, Top),
            Point(Left, Top + 6)]);
      end;
    end;
  end;

  if SelectedRows.Count > 0 then
  begin
    //
  end;
end;

function SortItemsDesc(List: TStringList; Index1,
  Index2: Integer): Integer;
begin
  Assert(List <> nil);
  Result := AnsiCompareText(List[Index2], List[Index1]);
end;

procedure TDBGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  GridCoord: TGridCoord;
  SelField: TField;
  R, CR: TRect;
  C: TColumn;
  Filterable: Boolean;
  I: Integer;
  {Bm, TempS, DT: String;
  OldFiltered: Boolean;
  OldCursor: TCursor;
  FlagShowZero: Boolean;}
begin
  inherited MouseUp(Button, Shift, X, Y);
  
  GridCoord := MouseCoord(X, Y);
  R := CellRect(GridCoord.X, GridCoord.Y);

  if (GridCoord.X < 0) or (GridCoord.Y < 0) then
    exit;

  if (Button = mbRight) and DataLink.Active and (GridCoord.Y < RowCount) then
  begin
    SelectedRows.CurrentRowSelected := True;
  end;

  if (DataLink.Active and (GridCoord.X >= 0)) then
    SelField := GetColField(GridCoord.X)
  else
    SelField := nil;

  CR := CellRect(GridCoord.X, GridCoord.Y);
  CR.Left := CR.Right - 14;
  CR.Top := CR.Bottom - 14;

  C := Columns[GridCoord.X];

  Filterable := (C.Field <> nil) and (C.Field.DataType in [
    ftString, ftSmallint, ftInteger, ftWord, ftLargeint, ftFloat, ftCurrency, ftBCD,
    ftBoolean, ftDate, ftTime, ftDateTime, ftBlob, ftMemo, ftGraphic, ftFmtMemo
    ]);

  if Filterable
    and PtInRect(CR, Point(X, Y))
    and (Button = mbLeft)
    and (dgTitles in Options)
    and (DataSource.DataSet is TIBCustomDataSet)
    and (GridCoord.Y = 0) then
  begin
    if EditorMode then
      EditorMode := False;

    with DataSource.DataSet as TIBCustomDataSet do
    begin
      if (not Filtered) and (FFilterableColumns.Count > 0) then
      begin
        for I := 0 to FFilterableColumns.Count - 1 do
          with TColumn(FFilterableColumns[I]) do
            if FFilteredCache <> nil then
              FFilteredCache.Clear;
        FFilterableColumns.Clear;
      end;
    end;

    if FFilterableColumns.Count = 0 then
    begin
      for I := 0 to Columns.Count - 1 do
      begin
        with Columns[I] as TColumn do
        begin
          if Filterable then
          begin
            if FFilteredCache = nil then
            begin
              FFilteredCache := TStringList.Create;
              FFilteredCache.Sorted := True;
              FFilteredCache.Duplicates := dupIgnore;
            end
            else begin
              FFilteredCache.Clear;
              FFilteredCache.Sorted := True;
            end;
            FFilterableColumns.Add(Columns[I]);
          end;
        end;
      end;
      //
      (*
      with DataSource.DataSet as TIBCustomDataSet do
        begin
          DisableControls;
          Bm := Bookmark;
          OldFiltered := Filtered;
          OldCursor := Screen.Cursor;
          Screen.Cursor := crHourGlass;
          {$IFDEF GEDEMIN}
          if (UserStorage <> nil) and (not UserStorage.ReadBoolean('Options', 'ShowZero', False, False)) then
            FlagShowZero := True
          else
          {$ENDIF}
            FlagShowZero := False;
          try
            if Filtered then
              Filtered := False;
            Last;
            while not BOF do
            begin
              for I := 0 to FFilterableColumns.Count - 1 do
              begin
                with TColumn(FFilterableColumns[I]) do
                if (FFilteredCache <> nil) and (FFilteredCache.Count < 4000)
                  and (not (Field.DataType in [ftBlob, ftMemo, ftGraphic, ftFmtMemo])) then
                begin
                  DT := Field.DisplayText;
                  if DT > '' then
                  begin
                    if Field is TDateTimeField then
                    begin
                      if Field.AsDateTime < 1 then
                        TempS := FormatDateTime('hh:nn:ss', Field.AsDateTime)
                      else
                        TempS := FormatDateTime('yyyy.mm.dd', Field.AsDateTime)
                    end else
                      TempS := Copy(DT, 1, 80);

                    FFilteredCache.Add(TempS);

                  end else
                  begin
                    if (not FlagShowZero) and (Field is TNumericField)
                      and (not Field.IsNull) then
                    begin
                      FFilteredCache.Add('0');
                    end;
                  end;
                end;
              end;

              Prior;
            end;

            for I := 0 to FFilterableColumns.Count - 1 do
              with TColumn(FFilterableColumns[I]) do
                if (FFilteredCache <> nil) and (Field is TDateTimeField) then
                begin
                  FFilteredCache.Sorted := False;
                  FFilteredCache.CustomSort(SortItemsDesc);
                end;
          finally
            Screen.Cursor := OldCursor;
            if Filtered <> OldFiltered then
              Filtered := OldFiltered;
            Bookmark := Bm;
            EnableControls;
          end;
        end;
      //end;
      *)
      //
    end;

    FFilteringColumn := C;

    if LB = nil then
    begin
      LB := TListBox.Create(Self);
      LB.Font.Name := 'Trebuchet MS';
      LB.Font.Size := 8;
      LB.Font.Height := -12;
      LB.ParentColor := False;
      LB.ParentCtl3D := False;
      LB.OnExit := _OnExit;
      LB.OnClick := _OnClick;
      LB.OnMouseDown := _OnMouseDown;
      LB.Parent := Self;
    end;

    LB.Left := R.Left;
    LB.Top := R.Bottom;
    LB.Width := Columns[GridCoord.X].Width;

    LB.Items.Clear;
    LB.Items.Assign(FFilteredCache);
    LB.Items.Insert(0, '<Все>');
    LB.Items.Insert(1, '<Пустые>');
    LB.Items.Insert(2, '<Не пустые>');
    if (C.Field.DataType in [ftInteger, ftSmallInt, ftWord, ftCurrency, ftBCD, ftLargeInt, ftFloat]) then
      LB.Items.Insert(3, '<Не 0 и не пустые>');
    if not (C.Field.DataType in [ftBlob, ftGraphic]) then
      LB.Items.Insert(1, '<Содержит...>');

    LB.Show;
    LB.SetFocus;
  end
  else if (Button = mbLeft) and
    (dgTitles in Options) and
    (GridCoord.Y = 0) and
    (SelField <> nil) then
  begin
    if (DataSource <> nil)
      and (not DataSource.DataSet.IsEmpty) then
    begin
      if EditorMode then
        EditorMode := False;

      if (C.FieldName = TIBCustomDataSet(DataSource.DataSet).SortField)
        and (TIBCustomDataSet(DataSource.DataSet).SortAscending) then
      begin
        TIBCustomDataSet(DataSource.DataSet).Sort(SelField, False);
      end else
      begin
        if TIBCustomDataSet(DataSource.DataSet).SortField = '' then
          TIBCustomDataSet(DataSource.DataSet).Sort(SelField,
            not (C.Field is TDateTimeField))
        else
          TIBCustomDataSet(DataSource.DataSet).Sort(SelField);
      end;

      SelectedRows.Clear;
    end;
  end;
end;

procedure TDBGrid.DoExit;
begin
  inherited;
  if (LB <> nil) then
    FreeAndNil(LB);
end;

procedure TDBGrid._OnExit(Sender: TObject);
begin
  (Sender as TWinControl).Hide;
  (Sender as TWinControl).Parent.SetFocus;
  //FFilteringColumn := nil;
end;

procedure TDBGrid._OnClick(Sender: TObject);
begin
  (Sender as TWinControl).Hide;
  (Sender as TWinControl).Parent.SetFocus;
  FFilteringColumn := nil;
end;

procedure TDBGrid._OnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //
end;

function TDBGrid.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
var
  Key: Word;
begin
  if (not (csDesigning in ComponentState))
    and Assigned(DataSource)
    and Assigned(DataSource.DataSet)
    and Focused then
  begin
    Key := VK_DOWN;
    KeyDown(Key, Shift);
  end;
  Result := True;
end;

function TDBGrid.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
var
  Key: Word;
begin
  if (not (csDesigning in ComponentState))
    and Assigned(DataSource)
    and Assigned(DataSource.DataSet)
    and Focused then
  begin
    Key := VK_UP;
    KeyDown(Key, Shift);
  end;
  Result := True;
end;



end.
