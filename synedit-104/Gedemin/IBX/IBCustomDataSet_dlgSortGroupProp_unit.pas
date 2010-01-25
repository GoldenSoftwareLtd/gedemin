unit IBCustomDataSet_dlgSortGroupProp_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ActnList, StdCtrls, ImgList, Menus,
  Commctrl, ExtCtrls, IBCustomDataSet, gsDBGrid;

type
  TIBCustomDataSet_dlgSortGroupProp = class(TForm)
    lv: TListView;
    gbSort: TGroupBox;
    btnAsc: TButton;
    btnDesc: TButton;
    btnNoSort: TButton;
    gbGroup: TGroupBox;
    btnGroup: TButton;
    btnNoGroup: TButton;
    gbFunction: TGroupBox;
    cbFormula: TComboBox;
    btnOk: TButton;
    act: TActionList;
    actOk: TAction;
    btnCancel: TButton;
    actCancel: TAction;
    gbOrder: TGroupBox;
    btnUp: TButton;
    btnDown: TButton;
    actSortAsc: TAction;
    actSortDesc: TAction;
    actSortNone: TAction;
    actUp: TAction;
    actDown: TAction;
    btnReset: TButton;
    actReset: TAction;
    btnApply: TButton;
    actApply: TAction;
    actGroup: TAction;
    actUnGroup: TAction;
    actSetFunction: TAction;
    actClearFunction: TAction;
    GroupBox1: TGroupBox;
    rbAll: TRadioButton;
    rbVisible: TRadioButton;
    GroupBox2: TGroupBox;
    cbScale: TComboBox;
    actScale: TAction;
    ImageList1: TImageList;
    ppm: TPopupMenu;
    miAsc: TMenuItem;
    miDesc: TMenuItem;
    miNoSort: TMenuItem;
    N7: TMenuItem;
    miGroup: TMenuItem;
    miNoGroup: TMenuItem;
    N1: TMenuItem;
    miUp: TMenuItem;
    miDown: TMenuItem;
    N4: TMenuItem;
    miScale: TMenuItem;
    N101: TMenuItem;
    N1001: TMenuItem;
    N10001: TMenuItem;
    N100001: TMenuItem;
    N1000001: TMenuItem;
    N10000001: TMenuItem;
    actScale1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N8: TMenuItem;
    miFormula: TMenuItem;
    SUM1: TMenuItem;
    COUNT1: TMenuItem;
    COUNTNOTNULL1: TMenuItem;
    AVG1: TMenuItem;
    MAX1: TMenuItem;
    MIN1: TMenuItem;
    paScale: TPanel;
    paFormula: TPanel;
    Label1: TLabel;
    procedure actCancelExecute(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actSortAscExecute(Sender: TObject);
    procedure actSortDescExecute(Sender: TObject);
    procedure actSortNoneExecute(Sender: TObject);
    procedure actUpUpdate(Sender: TObject);
    procedure actUpExecute(Sender: TObject);
    procedure actDownUpdate(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
    procedure actResetExecute(Sender: TObject);
    procedure actGroupUpdate(Sender: TObject);
    procedure actGroupExecute(Sender: TObject);
    procedure actUnGroupUpdate(Sender: TObject);
    procedure actUnGroupExecute(Sender: TObject);
    procedure actSortNoneUpdate(Sender: TObject);
    procedure actSetFunctionUpdate(Sender: TObject);
    procedure actSetFunctionExecute(Sender: TObject);
    procedure actClearFunctionUpdate(Sender: TObject);
    procedure actClearFunctionExecute(Sender: TObject);
    procedure lvCustomDrawItem(Sender: TCustomListView; Item: TListItem;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvInfoTip(Sender: TObject; Item: TListItem;
      var InfoTip: String);
    procedure actApplyExecute(Sender: TObject);
    procedure actUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure lvChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure rbAllClick(Sender: TObject);
    procedure rbVisibleClick(Sender: TObject);
    procedure lvDblClick(Sender: TObject);
    procedure actSortAscUpdate(Sender: TObject);
    procedure actSortDescUpdate(Sender: TObject);
    procedure cbFormulaChange(Sender: TObject);
    procedure cbScaleChange(Sender: TObject);
    procedure lvCustomDrawSubItem(Sender: TCustomListView; Item: TListItem;
      SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure actScaleExecute(Sender: TObject);
    procedure actScaleUpdate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miScaleClick(Sender: TObject);
    procedure miFormulaClick(Sender: TObject);
    procedure lvMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lvMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure cbScaleKeyPress(Sender: TObject; var Key: Char);
    procedure lvKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);

  private
    FDataSet: TIBCustomDataSet;
    FDBGrid: TgsCustomDBGrid;

    procedure Arrange(KeepFocused: Boolean = false);
  public
    procedure Setup(DS: TIBCustomDataSet; DBGrid: TgsCustomDBGrid);
  end;

var
  IBCustomDataSet_dlgSortGroupProp: TIBCustomDataSet_dlgSortGroupProp;

implementation

{$R *.DFM}

uses
  Db;

const
  siFieldName  = 0;
  siGroup      = 1;
  siSortOrder  = 2;
  siFormula    = 3;
  siScaleValue = 4;
  siScaleType  = 5;
  siVisible    = 6;
  siDataType   = 7;


  Codes: array[TDisplayCode] of Longint = (LVIR_BOUNDS, LVIR_ICON, LVIR_LABEL,
    LVIR_SELECTBOUNDS);

{ TIBCustomDataSet_dlgSortGroupProp }

procedure ListItemAllSubItemsAdd(LI: TListItem);
var
  I: Integer;
begin
  for I := 0 to siDataType do
    LI.SubItems.Add('');
end;

function GroupSortFieldsExist(DataSet: TIBCustomDataSet): Boolean;
begin
  Result := Assigned(DataSet.GroupSortFields)
        and (DataSet.GroupSortFields.Count > 0);
end;

function FindFieldInGroupSortFields(DataSet: TIBCustomDataSet; Field: TField): TGroupSortField;
var
  J: Integer;
begin
  Result := nil;
  if not GroupSortFieldsExist(DataSet) then
    exit;

  for J := 0 to DataSet.GroupSortFields.Count - 1 do
    if (DataSet.GroupSortFields[J].Field = Field) then
    begin
      Result := DataSet.GroupSortFields[J];
      Break;
    end;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.Setup(DS: TIBCustomDataSet;
  DBGrid: TgsCustomDBGrid);
var
  I, J: Integer;
  LI: TListItem;
  C: TgsColumn;
  FG: TGroupSortField;
  FA: TGroupAgg;
  liSort, liGroup,
  liFormula,
  liScaleValue, liScaleType,
  liVisible: string;
  maxWidthCaption: Integer;
  R: TRect; DX: Integer;
begin
  FDataSet := DS;
  FDBGrid := DBGrid;

  lv.Items.BeginUpdate;
  lv.OnChange := nil;
  try
    lv.Items.Clear;
    maxWidthCaption := 0;

    for I := 0 to FDataSet.FieldCount - 1 do
    begin
      //if FDataSet.Fields[I].Lookup then
      //  J:=I;
      if not FDataSet.Fields[I].Visible then
        continue;

      C := nil;
      for J := 0 to FDBGrid.Columns.Count - 1 do
      begin
        if FDBGrid.Columns[J].Field = FDataSet.Fields[I] then
        begin
          C := FDBGrid.Columns[J] as TgsColumn;
          Break;
        end;
      end;

      liSort := ''; liGroup := '';
      liFormula := '';
      liScaleValue := ''; liScaleType := '';
      liVisible := '';

      if FDataSet.Fields[I].DataType in [ftInteger, ftSmallint, ftWord,
           ftLargeint, ftFloat, ftCurrency, ftBCD, ftBoolean] then
        liScaleType := 'I'
      else if FDataSet.Fields[I].DataType in [ftDate, ftDateTime{, ftTime}] then
        liScaleType := 'D'
      else if FDataSet.Fields[I].DataType in [ftString, ftFixedChar] then
        liScaleType := ''{'S'}
      else begin
        if not (FDataSet.Fields[I].DataType in [ftTime]) then
          continue;
        //liScaleType := '';
        // FDataSet.Fields[I].DataType in [ftGraphic,ftFmtMemo,ftTypedBinary,
        //ftOraBlob,ftDBaseOle,ftParadoxOle]{TBlobField} then
        //             continue;
      end;

      FG := FindFieldInGroupSortFields(FDataSet, FDataSet.Fields[I]);
      if (FG <> nil) then
      begin
        case FG.GroupSortOrder of
          gsoSortAsc: liSort := 'A';
          gsoSortDesc: liSort := 'D';
          gsoGroupAsc: begin liGroup := 'G'; liSort := 'A'; end;
          gsoGroupDesc: begin liGroup := 'G'; liSort := 'D'; end;
        end;
        if FG.IntScale <> 1 then
          liScaleValue := IntToStr(FG.IntScale);
        if FG.DateScale <> dsType then
          liScaleValue := FG.GetScaleAsStr;
      end else begin
        if rbVisible.Checked then
          if (C <> nil) and (not C.Visible) then
            continue;
      end;

      if FDataSet.FormulaFields <> nil then
      for J := 0 to FDataSet.FormulaFields.Count - 1 do begin
         FA := (FDataSet.FormulaFields[J]);
         if (FA.Field = FDataSet.Fields[I]) then
         begin
           liFormula := FA.GetFuncAsStr;
           break;
         end;
      end;

      LI := lv.Items.Add;
      LI.Data := FDataSet.Fields[I];

      if C <> nil then
        LI.Caption := C.Title.Caption
      else
        LI.Caption := FDataSet.Fields[I].DisplayName;

      if lv.Canvas.TextWidth(LI.Caption) > maxWidthCaption then
        maxWidthCaption := lv.Canvas.TextWidth(LI.Caption);

      ListItemAllSubItemsAdd(LI);

      LI.SubItems[siFieldName] := FDataSet.Fields[I].FieldName;
      LI.SubItems[siGroup] := liGroup;
      LI.SubItems[siSortOrder] := liSort;
      LI.SubItems[siFormula] := liFormula;
      LI.SubItems[siScaleValue] := liScaleValue;
      LI.SubItems[siScaleType] := liScaleType;

      if (C = nil) then
        LI.SubItems[siVisible] := ''
      else if (not C.Visible) then
        LI.SubItems[siVisible] := 'U'
      else
        LI.SubItems[siVisible] := 'V';

    end;        {  --  for I := 0 to FDataSet.FieldCount  --  }

            {  Перемещаем вверх сортивочные и группировочные поля  }
    if Assigned(FDataSet.GroupSortFields) then//ниже процедура Arrange переместит групп. поля
      for J := FDataSet.GroupSortFields.Count - 1 downto 0 do//перед сортировочными
      begin                                     //если таковое есть
        for I := 1 to lv.Items.Count - 1 do begin
         if ((FDataSet.GroupSortFields[J]).Field = TField(lv.Items[I].Data))
           and (lv.Items[I].SubItems[siSortOrder] <> '') then
         begin
           LI := lv.Items.Insert(0);
           LI.Assign(lv.Items[I + 1]);
           lv.Items.Delete(I + 1);
         end;
       end;
      end;

    if lv.Items.Count > 0 then begin
      lv.Items[0].Selected := True;
      Arrange;
      lv.Columns[0].Width := maxWidthCaption;
    end;

  finally
    lv.Items.EndUpdate;
    lv.OnChange := lvChange;
    if lv.Selected <> nil then begin
      lvChange(nil, lv.Selected, ctState);

      R:=lv.Selected.DisplayRect(drBounds);
      DX := (lv.ClientRect.Right - R.Right);
      if DX > 1 then begin
        lv.Columns[0].Width := lv.Columns[0].Width + DX - 1;
      end;
    end;
  end;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actCancelExecute(
  Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actOkExecute(Sender: TObject);
begin
  actApply.Execute;
  ModalResult := mrOk;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actSortAscExecute(
  Sender: TObject);
begin
  if lv.Selected <> nil then
    lv.Selected.SubItems[siSortOrder] := 'A';
  Arrange(True);
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actSortDescExecute(
  Sender: TObject);
begin
  if lv.Selected <> nil then
    lv.Selected.SubItems[siSortOrder] := 'D';
  Arrange(True);
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actSortNoneExecute(
  Sender: TObject);
begin
  if lv.Selected <> nil then
    lv.Selected.SubItems[siSortOrder] := '';
  Arrange;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.Arrange(KeepFocused: Boolean = false);
var
  I: Integer;
  LI: TListItem;
  txtFieldName: string;
begin
  txtFieldName := '';
  if KeepFocused and (lv.Selected <> nil) then
    txtFieldName := lv.Selected.SubItems[siFieldName];

  lv.Items.BeginUpdate;
  lv.OnChange := nil;
  try
    I := lv.Items.Count - 1;
    while I >= 1 do
    begin
      if (lv.Items[I].SubItems[siSortOrder] = 'A') or (lv.Items[I].SubItems[siSortOrder] = 'D') then
      begin
        if lv.Items[I - 1].SubItems[siSortOrder] = '' then
        begin
          LI := lv.Items.Add;
          LI.Assign(lv.Items[I - 1]);
          lv.Items[I - 1].Assign(lv.Items[I]);
          lv.Items[I].Assign(LI);
          LI.Free;
          I := lv.Items.Count - 1;
          continue;
        end;
      end;
      Dec(I);
    end;

    I := lv.Items.Count - 1;
    while I >= 1 do
    begin
      if (lv.Items[I].SubItems[siGroup] = 'G') then
      begin
        if lv.Items[I - 1].SubItems[siGroup] <> 'G' then
        begin
          LI := lv.Items.Add;
          LI.Assign(lv.Items[I - 1]);
          lv.Items[I - 1].Assign(lv.Items[I]);
          lv.Items[I].Assign(LI);
          LI.Free;
          I := lv.Items.Count - 1;
          continue;
        end;
      end;
      Dec(I);
    end;

    if txtFieldName <> '' then
      for I := 0 to lv.Items.Count - 1 do
      begin
        if lv.Items[I].SubItems[siFieldName] = txtFieldName then begin
          lv.Items[I].Selected := True;
          break;
        end;
      end;

    if lv.Selected <> nil then
      lv.Selected.MakeVisible(False);
  finally
    lv.OnChange := lvChange;
    lv.Items.EndUpdate;
  end;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actUpUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (lv.Selected <> nil)
    and (lv.Selected.Index > 0)
    and (lv.Selected.SubItems[siSortOrder] > '')
    and (lv.Items[lv.Selected.Index - 1].SubItems[siSortOrder] > '')
    and (lv.Items[lv.Selected.Index - 1].SubItems[siGroup] = lv.Selected.SubItems[siGroup]);
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actUpExecute(Sender: TObject);
begin
  lv.OnChange := nil;
  try
  lv.Items.Insert(lv.Selected.Index + 1).Assign(lv.Items[lv.Selected.Index - 1]);
  lv.Items.Delete(lv.Selected.Index - 1);
  lv.Selected.MakeVisible(False);
  finally
    lv.OnChange := lvChange;
  end;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actDownUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (lv.Selected <> nil)
    and (lv.Selected.Index < (lv.Items.Count - 1))
    and (lv.Selected.SubItems[siSortOrder] > '')
    and (lv.Items[lv.Selected.Index + 1].SubItems[siSortOrder] > '')
    and (lv.Items[lv.Selected.Index + 1].SubItems[siGroup] = lv.Selected.SubItems[siGroup]);
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actDownExecute(
  Sender: TObject);
var
  LI: TListItem;
begin
  lv.OnChange := nil;
  try
   LI := lv.Items.Insert(lv.Selected.Index + 2);
   LI.Assign(lv.Selected);
   lv.Items.Delete(lv.Selected.Index);
   LI.Selected := True;
  finally
   lv.OnChange := lvChange;
   lv.Selected.MakeVisible(False);
  end;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actResetExecute(
  Sender: TObject);
var
  I, J: Integer;
begin
  lv.Items.BeginUpdate;
  try
    For I := 0 to lv.Items.Count - 1 do
    begin
      For J := 0 to lv.Items[I].SubItems.Count - 1 do
        if J in [siGroup, siSortOrder, siFormula, siScaleValue] then
           if (lv.Items[I].SubItems[J] <> '') then
             lv.Items[I].SubItems[J] := '';
    end;

    cbFormula.ItemIndex := -1;
    cbScale.ItemIndex := -1;
  finally
    lv.Items.EndUpdate;
    if lv.Selected <> nil then
      lvChange(nil, lv.Selected, ctState);
  end;
// Setup(FDataSet, FDBGrid);
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actGroupUpdate(
  Sender: TObject);
begin
  actGroup.Enabled := (lv.Selected <> nil)
   and (lv.Selected.SubItems[siGroup] <> 'G')
   and (not (TField(lv.Selected.Data) is TBlobField) );
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actGroupExecute(
  Sender: TObject);
begin
  if lv.Selected <> nil then
  begin
    lv.Selected.SubItems[siGroup] := 'G';
    lv.Selected.SubItems[siSortOrder] := 'A';
    lv.Selected.SubItems[siFormula] := '';
  end;
  Arrange(True);
  if lv.Selected <> nil then
    lvChange(nil, lv.Selected, ctState);
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actUnGroupUpdate(
  Sender: TObject);
begin
  actUngroup.Enabled := (lv.Selected <> nil) and (lv.Selected.SubItems[siGroup] = 'G');
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actUnGroupExecute(
  Sender: TObject);
begin
  if lv.Selected <> nil then
  begin
    lv.Selected.SubItems[siGroup] := '';
    lv.Selected.SubItems[siSortOrder] := '';
    lv.Selected.SubItems[siScaleValue] := '';
  end;
  Arrange(True);
  if lv.Selected <> nil then
    lvChange(nil, lv.Selected, ctState);
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actSortNoneUpdate(
  Sender: TObject);
begin
  actSortNone.Enabled := (lv.Selected <> nil) and
    ((lv.Selected.SubItems[siSortOrder] = 'A') or (lv.Selected.SubItems[siSortOrder] = 'D'))
    and (lv.Selected.SubItems[siGroup] = '');
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actSetFunctionUpdate(
  Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lv.Items.Count - 1 do
  begin
    if lv.Items[I].SubItems[siGroup] > '' then
      break;
    if I = lv.Items.Count - 1 then
    begin
      actSetFunction.Enabled := False;
      exit;
    end;
  end;
  actSetFunction.Enabled := (lv.Selected <> nil)
    and (lv.Selected.SubItems[siGroup] = '')
    and (not (TField(lv.Selected.Data) is TBlobField) );
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actSetFunctionExecute(
  Sender: TObject);
begin
  lv.Selected.SubItems[siFormula] := cbFormula.Text;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actClearFunctionUpdate(
  Sender: TObject);
begin
  actClearFunction.Enabled := (lv.Selected <> nil) and (lv.Selected.SubItems[siFormula] > '');
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actClearFunctionExecute(
  Sender: TObject);
begin
  lv.Selected.SubItems[siFormula] := '';
end;

function WidthBefore(lv: TListView; II: Integer): Integer;
var I: integer;
begin
    Result := 0;
    for I:=0 to 1 + II - 1 do
      //Result := Result + lv.Columns[I].Width;
      Result := Result + ListView_GetColumnWidth(lv.Handle, I);
end;

procedure DrawBmp(ImList: TImageList; Index: Integer;
  C: TCanvas; R: TRect);
var Bmp: TBitMap; XY: TRect; HI,DY: Integer;
begin             
  HI := R.Bottom - R.Top;
  Bmp:= TBitMap.Create;
  try
    XY := R;
    XY.Left := XY.Left;
    XY.Right:= XY.Left+16;
    ImList.GetBitmap(Index, Bmp);
    //C.BrushCopy(ARect, A, Rect(0,16,0, 16), clLime);
    //C.StretchDraw(XY,Bmp);
    DY := (HI - Bmp.Height) div 2;
    if DY < 0 then
      C.CopyRect(XY, Bmp.Canvas, Rect(0, DY, 16, HI))
    else
      C.CopyRect(XY, Bmp.Canvas, Rect(0, -DY, 16, HI));
   finally
    Bmp.Free;
 end;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.lvCustomDrawItem(
  Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var ARect,R: TRect; C: TCanvas;
    I: Integer;
    LeftCb3, WidthCb3: Integer;
    LeftCb4, WidthCb4: Integer;
    DX: Integer;
    GroupPresent: Boolean;
begin
  DefaultDraw:=false;

  GroupPresent := (lv.Items.Count>0) and (lv.Items[0].SubItems[siGroup] <> '');

  C := Sender.Canvas;
  if Sender.Checkboxes then
    DX := 16
  else
    DX := 0;
  with C do begin

    if Item.Selected then begin
      Brush.Color:=$00F0F0F0; Font.Color:=clBlack;
    end else begin
      Brush.Color:=clWhite; Font.Color:=clBlack;
    end;
    ARect:=Item.DisplayRect(drBounds);
    FillRect(ARect);

  //вывод Caption (1-я колонка)
    ARect:=Item.DisplayRect(drLabel);
    if Item.SubItems[siVisible] = '' then
     Font.Color := clDkGray{clTeal}
    else if Item.SubItems[siVisible] = 'U' then
     Font.Color := clDkGray{clGreen};

    if Item.StateIndex=1 then
      Font.Style:=[fsBold]
    else
      Font.Style:=[];
    ARect.Left := ARect.Left - DX;
    TextRect(ARect,ARect.Left + 1, ARect.Top + 1, Item.Caption);
    ARect.Left := ARect.Left + DX + 1;

    LeftCb3 := -1; WidthCb3 := -1;
    LeftCb4 := -1; WidthCb4 := -1;
  //вывод SubItems
    for i := 0 to siScaleValue do
    begin
     //ARect.Left:=WidthBefore(lv, i);
                                  {lv.Columns[i+1].Width}
     //ARect.Right:=ARect.Left+ListView_GetColumnWidth(lv.Handle, I+1);
     ListView_GetSubItemRect(lv.Handle, Item.Index, I + 1, LVIR_BOUNDS, @ARect);

     if i = siGroup then begin
       if (TField(Item.Data) is TBlobField) then
         DrawBmp(ImageList1, 4, C, ARect)
       else if Item.SubItems[siGroup] <> '' then
         DrawBmp(ImageList1, 3, C, ARect);
     end;

     if i = siSortOrder then begin
       if Item.SubItems[siSortOrder] = 'A' then
         DrawBmp(ImageList1, 1, C, ARect)
       else if Item.SubItems[siSortOrder] = 'D' then
         DrawBmp(ImageList1, 2, C, ARect)
     end;

     if i = siFormula then begin
       R := ARect; R.Left := R.Right - 6;
       if GroupPresent and (Item.SubItems[siGroup] = '')
         and (not (TField(Item.Data) is TBlobField) ) then begin
         DrawBmp(ImageList1, 0, C, R);
         LeftCb3 := ARect.Left; WidthCb3 := ARect.Right - LeftCb3;
       end;
       ARect.Right := ARect.Right - 6;
     end;

     if i = siScaleValue then begin
       R := ARect; R.Left := R.Right - 6;
       if Item.SubItems[siScaleType] <> '' then begin
         DrawBmp(ImageList1, 0, C, R);
         if GroupPresent then begin
           LeftCb4 := ARect.Left; WidthCb4 := ARect.Right - LeftCb4;
         end;
       end;
       ARect.Right := ARect.Right - 6;
     end;

     if I in [siFieldName, siFormula, siScaleValue] then
       TextRect(ARect,ARect.Left+2,ARect.Top+1,Item.SubItems[i]);

    end; { For I }

    if Item.Selected then begin
      ARect:=Item.DisplayRect(drBounds);
      ARect.Top := ARect.Top;
      ARect.Bottom := ARect.Bottom-1;
      Brush.Color:=clNavy;
      FrameRect(ARect);
              // ComboBorders
      if WidthCb3 <> -1 then begin
        //paFormula.Visible := True;

        paFormula.Parent := lv;
        paFormula.Height := ARect.Bottom - ARect.Top - 2;

        paFormula.Top := ARect.Top + 1;
        paFormula.Left := LeftCb3+1;
        paFormula.Width := WidthCb3-1;

        cbFormula.Parent := paFormula;
        cbFormula.Left := -1; cbFormula.Top := -3;
        cbFormula.Width := paFormula.Width + 3;
      end;

      if WidthCb4 <> -1 then begin
        //paScale.Visible := True;

        if paScale.Parent <> lv then begin
          paScale.Parent := lv;
          paScale.Height := ARect.Bottom - ARect.Top - 2;
        end;
        paScale.Top := ARect.Top + 1;
        paScale.Left := LeftCb4+1;
        paScale.Width := WidthCb4-1;

        cbScale.Parent := paScale;
        cbScale.Left := -1; cbScale.Top := -3;
        cbScale.Width := paScale.Width + 3;
      end;
    end;


  end;
  DefaultDraw:=false;
end; {  lvCustomDrawItem  }

procedure TIBCustomDataSet_dlgSortGroupProp.lvCustomDrawSubItem(
  Sender: TCustomListView; Item: TListItem; SubItem: Integer;
  State: TCustomDrawState; var DefaultDraw: Boolean);
//var ARect: TRect;
//    OldColor: TColor;
begin
//  lv.Canvas.Brush.Color := clWhite;
//  if SubItem = siScaleValue + 1 then
//    if Item.SubItems[siScaleType] = 'I' then begin
//      ARect := Item.DisplayRect(drBounds);
//      ARect.Left := WidthBefore(lv, siScaleValue);
//      ARect.Right := ARect.Left + lv.Columns[siScaleValue + 1].Width;
//      lv.Canvas.Brush.Color := $00BDFDFD;
//    end else if Item.SubItems[siScaleType] = 'D' then begin
//      lv.Canvas.Brush.Color := $00CCFFDD;
//    end else if Item.SubItems[siScaleType] = 'S' then begin
//      lv.Canvas.Brush.Color := $00FFFFBB;
//    end;
//
//  DefaultDraw := True;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.lvInfoTip(Sender: TObject;
  Item: TListItem; var InfoTip: String);
begin
  InfoTip := TField(Item.Data).Origin;
end;
{$WARNINGS OFF}
procedure TIBCustomDataSet_dlgSortGroupProp.actApplyExecute(
  Sender: TObject);
var
  I: Integer;
  GSO: TGroupSortOrder;
  IntScale: Integer;
  DateScale: TDateScale;
  StrScale: string;
  ScaleValueTxt: string;
begin
  FDataSet.ClearGroupSort;

  IntScale := 1;
  DateScale := dsType;
  StrScale := '';

  for I := 0 to lv.Items.Count - 1 do
  begin
    if lv.Items[I].SubItems[siGroup] = 'G' then
    begin
      if lv.Items[I].SubItems[siSortOrder] = 'A' then
        GSO := gsoGroupAsc
      else
        GSO := gsoGroupDesc;
    end
    else if lv.Items[I].SubItems[siSortOrder] > '' then
    begin
      if lv.Items[I].SubItems[siSortOrder] = 'A' then
        GSO := gsoSortAsc
      else
        GSO := gsoSortDesc;
    end else
      continue;

    ScaleValueTxt := lv.Items[I].SubItems[siScaleValue];

    if lv.Items[I].SubItems[siScaleType]='I' then begin
      if Trim(ScaleValueTxt) <> '' then
        IntScale := StrToInt(ScaleValueTxt);
    end;
    if lv.Items[I].SubItems[siScaleType]='D' then begin
      DateScale := FDataSet.GetDateScale(ScaleValueTxt);
    end;
//    if lv.Items[I].SubItems[siScaleType]='S' then begin
//      StrScale := ScaleValueTxt;
//    end;

    FDataSet.AddGroupSortField(TField(lv.Items[I].Data),
      GSO, IntScale, DateScale, StrScale);
  end;

  if GroupSortFieldsExist(FDataSet) then
    for I := 0 to lv.Items.Count - 1 do
      if lv.Items[I].SubItems[siFormula] > '' then
        FDataSet.AddFormulaField(TField(lv.Items[I].Data), lv.Items[I].SubItems[siFormula]);
  btnApply.Enabled:=false;
  FDataSet.Group;
  btnApply.Enabled:=True;
end;
{$WARNINGS ON}
procedure TIBCustomDataSet_dlgSortGroupProp.actUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  if (FDataSet = nil) and (Action is TAction) then
  begin
    TAction(Action).Enabled := False;
    Handled := True;
  end else
    Handled := False;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.cbFormulaChange(
  Sender: TObject);
begin
  actSetFunction.Execute;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.lvChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);

  procedure cbScaleFill();
  var D: TDateScale; I: Integer;
  begin
    if Item.SubItems[siScaleType] = 'I' then begin
      cbScale.Style := csDropDown;
      cbScale.Items.Clear;

      cbScale.Items.Add('');
      cbScale.Items.Add('10');
      cbScale.Items.Add('100');
      cbScale.Items.Add('1000');
      cbScale.Items.Add('10000');
      cbScale.Items.Add('100000');
      cbScale.Items.Add('1000000');
    end else
    if Item.SubItems[siScaleType] = 'D' then begin
      cbScale.Style := csDropDownList;
      cbScale.Items.Clear;
      for D := dsType to dsYear do
        cbScale.Items.Add(ArDateScale[D]);
    end else
    {if Item.SubItems[siScaleType] = 'S' then begin
      cbScale.Style := csDropDown;
      cbScale.Items.Clear;
    end;}

    for I := 0 to miScale.Count - 1 do begin
      miScale.Items[I].Checked := false;
      miScale.Items[I].Visible := false;
    end;

    if Item.SubItems[siScaleType] = 'I' then begin
      for I := 0 to miScale.Count - 1 do
         miScale.Items[I].Visible := (I in [0..6])
    end else
    if Item.SubItems[siScaleType] = 'D' then begin
      for I := 0 to miScale.Count - 1 do
         miScale.Items[I].Visible := (I in [7..12])
    end;

  end;
  function GroupPresent: Boolean;
  begin
    Result := (lv.Items.Count>0) and (lv.Items[0].SubItems[siGroup] <> '');
  end;

var
  I: Integer;
begin
  if Change = ctState then { TODO : DBG1 Formula: lvChange}

  if Item.Selected then begin
    // actSetFunctionUpdate(nil);
    paFormula.Visible := GroupPresent and (Item.SubItems[siGroup] = '')
      and not (TField(Item.Data) is TBlobField);
    miFormula.Enabled := paFormula.Visible;
    for I := 0 to miFormula.Count - 1 do
      miFormula.Items[I].Visible := miFormula.Enabled;
    cbFormula.ItemIndex := cbFormula.Items.IndexOf(Item.SubItems[siFormula]);

    cbScaleFill;
    cbScale.Text := Item.SubItems[siScaleValue];
    cbScale.ItemIndex := cbScale.Items.IndexOf(Item.SubItems[siScaleValue]);
    cbScale.Enabled := (Item.SubItems[siGroup] <>'') and (Item.SubItems[siScaleType] <> '');
    miScale.Enabled := cbScale.Enabled;
    paScale.Visible := miScale.Enabled;
    if cbScale.ItemIndex <> -1 then
      miScale.Items[cbScale.ItemIndex].Checked := True;
  end;
end;  {  lvChange  }

procedure TIBCustomDataSet_dlgSortGroupProp.rbAllClick(Sender: TObject);
begin
  Setup(FDataSet, FDBGrid);
end;

procedure TIBCustomDataSet_dlgSortGroupProp.rbVisibleClick(
  Sender: TObject);
begin
  Setup(FDataSet, FDBGrid);
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actSortAscUpdate(
  Sender: TObject);
begin
  actSortAsc.Enabled := (lv.Selected <> nil) and
    (lv.Selected.SubItems[siSortOrder] <> 'A');
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actSortDescUpdate(
  Sender: TObject);
begin
  actSortDesc.Enabled := (lv.Selected <> nil) and
    (lv.Selected.SubItems[siSortOrder] <> 'D');
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actScaleExecute(
  Sender: TObject);
begin
 lv.Selected.SubItems[siScaleValue] := cbScale.Text;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.actScaleUpdate(
  Sender: TObject);
begin
 actScale.Enabled := (lv.Selected <> nil) and
  (lv.Selected.SubItems[siScaleType] = 'I') or (lv.Selected.SubItems[siScaleType] = 'D');
end;

procedure TIBCustomDataSet_dlgSortGroupProp.cbScaleChange(Sender: TObject);
begin
  actScale.Execute;
  actGroup.Execute;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.miScaleClick(Sender: TObject);
var txt: string;
begin
  txt := StringReplace(TMenuItem(Sender).Caption, '&', '', [rfReplaceAll]);
  cbScale.ItemIndex := cbScale.Items.IndexOf(txt);
  actScale.Execute;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.FormShow(Sender: TObject);
begin
  //
end;

procedure TIBCustomDataSet_dlgSortGroupProp.miFormulaClick(Sender: TObject);
var txt: string;
begin
  txt := StringReplace(TMenuItem(Sender).Caption, '&', '', [rfReplaceAll]);
  cbFormula.ItemIndex := cbFormula.Items.IndexOf(txt);
  actSetFunction.Execute;
end;

var X_, Y_: Integer;
procedure TIBCustomDataSet_dlgSortGroupProp.lvMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 X_:=X; Y_:=Y;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.lvDblClick(Sender: TObject);
var LI: TListItem; R: TRect;
begin
 if actGroup.Enabled then
   actGroup.Execute
 else if actUnGroup.Enabled then
   actUnGroup.Execute;
 exit;
 { Ниже была предложена делать группировку и/или сортировку только при двойном }
 { щелчке мышью в пределах их столбцов. Не прошло. }
 LI := lv.GetItemAt(X_, Y_);
 if LI<>nil then begin
   ListView_GetSubItemRect(lv.Handle, LI.Index, siSortOrder + 1, LVIR_BOUNDS, @R);
   if (R.Left <= X_) and (X_ <= R.Right) then begin
     if LI.SubItems[siSortOrder] = '' then
       LI.SubItems[siSortOrder] := 'A'
     else if LI.SubItems[siSortOrder] = 'A' then
       LI.SubItems[siSortOrder] := 'D'
     else
       LI.SubItems[siSortOrder] := '';
     Arrange(True);
   end else begin
     ListView_GetSubItemRect(lv.Handle, LI.Index, siGroup + 1, LVIR_BOUNDS, @R);
     if (R.Left <= X_) and (X_ <= R.Right)
       and (not (TField(LI.Data) is TBlobField) ) then begin

       if LI.SubItems[siGroup] = '' then
         LI.SubItems[siGroup] := 'G'
       else
         LI.SubItems[siGroup] := '';
       Arrange(True);
     end;
   end;  
 end;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.lvMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var LI: TListItem; R: TRect;
begin
  exit; 
  LI := lv.GetItemAt(X, Y);
  if LI<>nil then begin
    ListView_GetSubItemRect(lv.Handle, LI.Index, siSortOrder + 1, LVIR_BOUNDS, @R);
    if (R.Left <= X) and (X <= R.Right) then
      Screen.Cursor := crHandPoint
    else begin
     ListView_GetSubItemRect(lv.Handle, LI.Index, siGroup + 1, LVIR_BOUNDS, @R);
     if (R.Left <= X) and (X <= R.Right) then
       Screen.Cursor := crHandPoint
     else
       Screen.Cursor := 0;
    end;
  end;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.cbScaleKeyPress(
  Sender: TObject; var Key: Char);
begin
 if not (Key in [#8, '0'..'9']) then
   Key := #0;
end;

procedure TIBCustomDataSet_dlgSortGroupProp.lvKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ADD) and ([ssCtrl] = Shift) then begin
    KEY:=0;
  end;
end;

end.
