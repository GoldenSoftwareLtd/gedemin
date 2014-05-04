unit gsDBSqueeze_CardMergeForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Grids, contnrs, ActnList;

const
  SELECTED_ITEMS_COLOR = $0088AEFF;
  BRUSH_COLOR = $001F67FC;
    
type
  EgsDBSqueeze = class(Exception);
  
  TgsDBSqueeze_CardMergeForm = class(TForm)
    actlstCardMerge: TActionList;
    actSelectAllDocs: TAction;
    btn1: TButton;
    btnMergeGo: TButton;
    dtpMergingDate: TDateTimePicker;
    mCardFeatures: TMemo;
    mDocTypes: TMemo;
    mmo1: TMemo;
    strngrdCardFeatures: TStringGrid;
    strngrdDocTypes: TStringGrid;
    tvDocTypes: TTreeView;
    txt1: TStaticText;
    txt2: TStaticText;
    txt5: TStaticText;
    procedure actSelectAllDocsExecute(Sender: TObject);
    procedure btnIsMergeOption(Sender: TObject);
    procedure btnMergeGoClick(Sender: TObject);
    procedure strngrdCardFeaturesDblClick(Sender: TObject);
    procedure strngrdCardFeaturesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure strngrdDocTypesDblClick(Sender: TObject);
    procedure strngrdDocTypesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure tvDocTypesClick(Sender: TObject);
    procedure tvDocTypesCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
  private
    FAllCardFeatures: TStringList;
    FAllDocTypesList: TStringList;
    FCardFeaturesBits: TBits;
    FCurBranchIndex: Integer;
    FDocTypesBitsList: TObjectList;
    FSelectedCardFeatures: TStringList;
    FSelectedDocTypesList: TStringList;

    procedure UpdateCardFeaturesMemo;
    procedure UpdateDocTypesMemo;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure ClearSelection;
    procedure DataDestroy;

    procedure SetCardFeatures(const ACardFatures: TStringList);
    procedure SetDocTypeBranch(const ABranchList: TStringList);
    procedure SetDocTypes(const ADocTypes: TStringList);

    procedure SetDate(const AMergingDate: TDateTime);
    procedure SetSelectedDocTypes(const ASelectedTypesStr: String; const ASelectedRowsStr: String);
    procedure SetSelectedCardFeatures(const ASelectedCardFeatures: String; const ASelectedFeaturesRows: String);

    function GetDate: TDateTime;
    function GetSelectedCardFeatures: String;
    function GetSelectedIdDocTypes: String;

    function GetSelectedDocTypesStr: String;
    function GetSelectedBranchRowsStr: String;
    function GetSelectedFeaturesRows: String;
  end;

var
  gsDBSqueeze_CardMergeForm: TgsDBSqueeze_CardMergeForm;

implementation

{$R *.DFM}

constructor TgsDBSqueeze_CardMergeForm.Create(AnOwner: TComponent);
begin
  inherited;

  dtpMergingDate.Date := Date;
  FCurBranchIndex := -1;
  FDocTypesBitsList := TObjectList.Create;
  FSelectedDocTypesList := TStringList.Create;
  FAllDocTypesList := TStringList.Create;
  strngrdDocTypes.ColCount := 2;
  strngrdDocTypes.RowCount := 0;

  FSelectedCardFeatures := TStringList.Create;
  FAllCardFeatures := TStringList.Create;
  FCardFeaturesBits := TBits.Create;
  
  strngrdCardFeatures.ColCount := 1;
  strngrdCardFeatures.RowCount := 0;
end;
//---------------------------------------------------------------------------
destructor TgsDBSqueeze_CardMergeForm.Destroy;
begin
  FSelectedDocTypesList.Free;
  FAllDocTypesList.Free;
  FDocTypesBitsList.Free;
  FCardFeaturesBits.Free;
  FAllCardFeatures.Free;
  FSelectedCardFeatures.Free;

  inherited;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.UpdateDocTypesMemo;
var
  I: Integer;
  Str: String;
  Delimiter: String;
begin
  if FCurBranchIndex <> -1 then
  begin
    for I:=0 to FSelectedDocTypesList.Count-1 do
    begin
      if Str <> '' then
        Delimiter := ', '
      else
        Delimiter := '';
      Str := Str + Delimiter + FSelectedDocTypesList.Values[FSelectedDocTypesList.Names[I]]+ ' (' + FSelectedDocTypesList.Names[I] + ')';
    end;
    mDocTypes.Clear;
    mDocTypes.Text := Str;
  end
  else
    mDocTypes.Clear;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.UpdateCardFeaturesMemo;
begin
  mCardFeatures.Clear;
  mCardFeatures.Text := FSelectedCardFeatures.Text;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.tvDocTypesClick(Sender: TObject);
var
  BranchDocTypes: TStringList;
  I: Integer;
begin
  if tvDocTypes.Selected.AbsoluteIndex <> FCurBranchIndex then
  begin
    with strngrdDocTypes do
      for I:=0 to ColCount-1 do
        Cols[I].Clear;
    strngrdDocTypes.RowCount := 0;
    
    FCurBranchIndex := tvDocTypes.Selected.AbsoluteIndex;

    if FAllDocTypesList.Values[FAllDocTypesList.Names[FCurBranchIndex]] <> '0' then
    begin
      BranchDocTypes := TStringList.Create;
      try
        BranchDocTypes.Text := StringReplace(FAllDocTypesList[FCurBranchIndex], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
        strngrdDocTypes.RowCount :=  BranchDocTypes.Count;
        for I:=0 to BranchDocTypes.Count-1 do
        begin
          strngrdDocTypes.Cells[0, I] := BranchDocTypes.Values[BranchDocTypes.Names[I]];  // имя типа дока
          strngrdDocTypes.Cells[1, I] := BranchDocTypes.Names[I];                         // id типа
        end;
      finally
        BranchDocTypes.Free;
      end;
    end;

    strngrdDocTypes.Repaint;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.tvDocTypesCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  if cdsSelected in State  then
    Sender.Canvas.Brush.Color := BRUSH_COLOR;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.strngrdDocTypesDblClick(
  Sender: TObject);
var
  I: Integer;
begin
  if FCurBranchIndex <> -1 then
  begin
    if Sender = strngrdDocTypes then
    begin
      for I:= (Sender as TStringGrid).Selection.Top to (Sender as TStringGrid).Selection.Bottom  do
      begin
        if not TBits(FDocTypesBitsList[FCurBranchIndex])[I] then
        begin
          TBits(FDocTypesBitsList[FCurBranchIndex])[I] := True;

          if FSelectedDocTypesList.IndexOfName(Trim(strngrdDocTypes.Cells[1, I])) = -1 then
            FSelectedDocTypesList.Append(Trim(strngrdDocTypes.Cells[1, I]) + '=' + Trim(strngrdDocTypes.Cells[0, I]));
        end
        else begin
          TBits(FDocTypesBitsList[FCurBranchIndex])[I] := False;
          if FSelectedDocTypesList.IndexOfName(Trim(strngrdDocTypes.Cells[1, I])) <> -1 then
            FSelectedDocTypesList.Delete(FSelectedDocTypesList.IndexOfName(Trim(strngrdDocTypes.Cells[1, I])));
        end;
      end;

      (Sender as TStringGrid).Repaint;

      UpdateDocTypesMemo;
    end;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.strngrdDocTypesDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
  AGrid : TStringGrid;
begin
  if FCurBranchIndex <> -1 then
  begin
    AGrid:=TStringGrid(Sender);

     if not TBits(FDocTypesBitsList[FCurBranchIndex])[ARow] then
       AGrid.Canvas.Brush.Color := clWhite
     else
       AGrid.Canvas.Brush.Color := SELECTED_ITEMS_COLOR;

     if (gdSelected in State) then
     begin
       if not TBits(FDocTypesBitsList[FCurBranchIndex])[ARow] then
       begin
         AGrid.Canvas.Brush.Color := BRUSH_COLOR;
       end
       else
         AGrid.Canvas.Brush.Color := SELECTED_ITEMS_COLOR;
     end;
      AGrid.Canvas.FillRect(Rect);
      AGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, AGrid.Cells[ACol, ARow]);
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.strngrdCardFeaturesDblClick(
  Sender: TObject);
var
  I: Integer;
begin
  if Sender = strngrdCardFeatures then
  begin
    for I:= (Sender as TStringGrid).Selection.Top to (Sender as TStringGrid).Selection.Bottom  do
    begin
      if not FCardFeaturesBits[I] then
      begin
        FCardFeaturesBits[I] := True;

        if FSelectedCardFeatures.IndexOf(Trim(strngrdCardFeatures.Cells[0, I])) = -1 then
          FSelectedCardFeatures.Append(Trim(strngrdCardFeatures.Cells[0, I]));
      end
      else begin
        FCardFeaturesBits[I] := False;
        if FSelectedCardFeatures.IndexOf(Trim(strngrdCardFeatures.Cells[0, I])) <> -1 then
          FSelectedCardFeatures.Delete(FSelectedCardFeatures.IndexOf(Trim(strngrdCardFeatures.Cells[0, I])));
      end;
    end;

    (Sender as TStringGrid).Repaint;

    UpdateCardFeaturesMemo;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.strngrdCardFeaturesDrawCell(
  Sender: TObject; ACol, ARow: Integer; Rect: TRect;
  State: TGridDrawState);
var
  AGrid : TStringGrid;
begin
  if FCurBranchIndex <> -1 then
  begin
    AGrid:=TStringGrid(Sender);

   if not FCardFeaturesBits[ARow] then
     AGrid.Canvas.Brush.Color := clWhite
   else
     AGrid.Canvas.Brush.Color := SELECTED_ITEMS_COLOR;

   if (gdSelected in State) then
   begin
     if not FCardFeaturesBits[ARow] then
     begin
       AGrid.Canvas.Brush.Color := BRUSH_COLOR;
     end
     else
       AGrid.Canvas.Brush.Color := SELECTED_ITEMS_COLOR;
   end;
    AGrid.Canvas.FillRect(Rect);
    AGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, AGrid.Cells[ACol, ARow]);
  end;  
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.actSelectAllDocsExecute(Sender: TObject);
var
  Rect: TGridRect;
begin
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := strngrdDocTypes.ColCount-1;
  Rect.Bottom := strngrdDocTypes.RowCount-1;
  strngrdDocTypes.Selection := Rect;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.btnMergeGoClick(Sender: TObject);
begin
  Self.ModalResult := mrYes;
  PostMessage(gsDBSqueeze_CardMergeForm.Handle, WM_CLOSE, 0, 0);
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.btnIsMergeOption(Sender: TObject);
begin
  Self.ModalResult := mrOK;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_CardMergeForm.GetDate: TDateTime;
begin
  Result := dtpMergingDate.Date;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_CardMergeForm.GetSelectedCardFeatures: String;
begin
  Result := FSelectedCardFeatures.CommaText;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_CardMergeForm.GetSelectedIdDocTypes: String;
var
  SelectedIdStr: String;
  I: Integer;
begin
  for I:=0 to FSelectedDocTypesList.Count-1 do
  begin
    if SelectedIdStr > '' then
      SelectedIdStr := SelectedIdStr + ',' + FSelectedDocTypesList.Names[I]
    else
      SelectedIdStr := FSelectedDocTypesList.Names[I];
  end;
  Result := SelectedIdStr;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_CardMergeForm.GetSelectedDocTypesStr: String;
var
  Str: String;
begin
  Str := StringReplace(FSelectedDocTypesList.Text, #13#10, '||', [rfReplaceAll, rfIgnoreCase]);
  Result := Str;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_CardMergeForm.GetSelectedBranchRowsStr: String;
var
  I, J: Integer;
  Str: String;
  SelectedBranchRows: TStringList;
begin
  SelectedBranchRows := TStringList.Create;
  try
    for I:=0 to FDocTypesBitsList.Count-1 do
    begin
      if TBits(FDocTypesBitsList[I]).Size > 0 then
      begin
        for J:=0 to TBits(FDocTypesBitsList[I]).Size-1 do
        begin
          if TBits(FDocTypesBitsList[I])[J] = true then
          begin
            if SelectedBranchRows.IndexOfName(IntToStr(I)) <> -1 then
              SelectedBranchRows[SelectedBranchRows.IndexOfName(IntToStr(I))] := SelectedBranchRows[SelectedBranchRows.IndexOfName(IntToStr(I))] + '||' + IntToStr(J)
            else
              SelectedBranchRows.Append(IntToStr(I) + '=' + IntToStr(J));
          end;
        end;
      end;  
    end;

    Str := StringReplace(SelectedBranchRows.Text, #13#10, ',', [rfReplaceAll, rfIgnoreCase]);
    Delete(Str, Length(Str), 1);
    Result := Str;
  finally
    SelectedBranchRows.Free;
  end;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_CardMergeForm.GetSelectedFeaturesRows: String;
var
  I: Integer;
  SelectedRows: TStringList;
begin
  SelectedRows := TStringList.Create;
  try
    if FCardFeaturesBits.Size > 0 then
    begin
      for I:=0 to FCardFeaturesBits.Size-1 do
      begin
        if FCardFeaturesBits[I] = True then
          SelectedRows.Append(IntToStr(I));
      end;
    end;

    Result := SelectedRows.CommaText;
  finally
    SelectedRows.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.SetDocTypeBranch(const ABranchList: TStringList);
var
  BranchListStream : TMemoryStream;
begin
  BranchListStream := TMemoryStream.Create;
  try
    ABranchList.SaveToStream(BranchListStream);
    BranchListStream.Position:=0;
    tvDocTypes.LoadFromStream(BranchListStream);
    tvDocTypes.ReadOnly := True;
    tvDocTypes.FullExpand;
  finally
    BranchListStream.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.SetDocTypes(const ADocTypes: TStringList);
var
  I: Integer;
  BranchDocTypes: TStringList;
begin
  FAllDocTypesList.Text := ADocTypes.Text;
  FCurBranchIndex := 0;

  if FAllDocTypesList.Values[FAllDocTypesList.Names[FCurBranchIndex]] <> '0' then
  begin
    BranchDocTypes := TStringList.Create;
    try
      BranchDocTypes.Text := StringReplace(FAllDocTypesList[FCurBranchIndex], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
      strngrdDocTypes.RowCount :=  BranchDocTypes.Count;
      for I:=0 to BranchDocTypes.Count-1 do
      begin
        strngrdDocTypes.Cells[0, I] := BranchDocTypes.Values[BranchDocTypes.Names[I]];  // имя типа дока
        strngrdDocTypes.Cells[1, I] := BranchDocTypes.Names[I];                         // id типа
      end;

      if ADocTypes.Count <> tvDocTypes.Items.Count then
        raise EgsDBSqueeze.Create('Типы документов получены не для всех веток!');

      for I:=0 to ADocTypes.Count-1 do
      begin
        BranchDocTypes.Clear;
        BranchDocTypes.Text := StringReplace(ADocTypes[I], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
        FDocTypesBitsList.Add(TBits.Create);
        TBits(FDocTypesBitsList[I]).Size := BranchDocTypes.Count;
      end;
    finally
      BranchDocTypes.Free;
    end;
  end;
  strngrdDocTypes.Repaint;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.SetCardFeatures(const ACardFatures: TStringList); ///
var
  I: Integer;
begin
  FAllCardFeatures.CommaText := ACardFatures.CommaText;
  FCardFeaturesBits.Size := FAllCardFeatures.Count;

  strngrdCardFeatures.RowCount := FAllCardFeatures.Count;
  for I:=0 to FAllCardFeatures.Count-1 do
    strngrdCardFeatures.Cells[0, I] := FAllCardFeatures[I];
  strngrdCardFeatures.Repaint;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.SetDate(const AMergingDate: TDateTime);
begin
  dtpMergingDate.Date := AMergingDate;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.SetSelectedDocTypes(const ASelectedTypesStr: String; const ASelectedRowsStr: String);
var
  I, J: Integer;
  Str: String;
  SelectedBranch: TStringList;    // ветка=номерастрок
  SelectedGridRows: TStringList;  // номера строк
  BranchDocTypes: TStringList;
begin
  SelectedBranch := TStringList.Create;
  SelectedGridRows := TStringList.Create;
  BranchDocTypes := TStringList.Create;
  try
    FSelectedDocTypesList.Text := StringReplace(ASelectedTypesStr, '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
    Str := '';
    for I:=0 to FSelectedDocTypesList.Count-1 do
    begin
      if Str > '' then
        Str := Str + ', ' + FSelectedDocTypesList.Values[FSelectedDocTypesList.Names[I]] + ' (' + FSelectedDocTypesList.Names[I] + ')'
      else
        Str := FSelectedDocTypesList.Values[FSelectedDocTypesList.Names[I]] + ' (' + FSelectedDocTypesList.Names[I] + ')';
    end;
    mDocTypes.Text := Str;

    SelectedBranch.Text := StringReplace(ASelectedRowsStr, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);
    for I:=0 to SelectedBranch.Count-1 do
    begin
      SelectedGridRows.Clear;
      SelectedGridRows.Text := StringReplace(SelectedBranch.Values[SelectedBranch.Names[I]], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
      for J:=0 to SelectedGridRows.Count-1 do
        TBits(FDocTypesBitsList[StrToInt(Trim(SelectedBranch.Names[I]))])[StrToInt(Trim(SelectedGridRows[J]))] := True;
    end;

    strngrdDocTypes.Repaint;
  finally
    SelectedBranch.Free;
    SelectedGridRows.Free;
    BranchDocTypes.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.SetSelectedCardFeatures(const ASelectedCardFeatures: String; const ASelectedFeaturesRows: String);
var
  I: Integer;
  SelectedGridRows: TStringList;  // номера строк
begin
  SelectedGridRows := TStringList.Create;
  try
    FSelectedCardFeatures.CommaText := ASelectedCardFeatures;
    mCardFeatures.Text := ASelectedCardFeatures;

    SelectedGridRows.CommaText := ASelectedFeaturesRows;
    for I:=0 to SelectedGridRows.Count-1 do
      FCardFeaturesBits[StrToInt(Trim(SelectedGridRows[I]))] := True;

    strngrdCardFeatures.RowCount := FAllCardFeatures.Count;
    for I:=0 to FAllCardFeatures.Count-1 do
    begin
      strngrdCardFeatures.Cells[0, I] := FAllCardFeatures[I];
    end;

    strngrdCardFeatures.Repaint;
  finally
    SelectedGridRows.Free;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.ClearSelection;
var
  I: Integer;
  SizeBitsArr: array of Integer;
begin
  mDocTypes.Clear;
  mCardFeatures.Clear;
  dtpMergingDate.Date := Date;

  FSelectedDocTypesList.Clear;
  FSelectedCardFeatures.Clear;

  SetLength(SizeBitsArr, FDocTypesBitsList.Count);
  for I:=0 to FDocTypesBitsList.Count-1 do
    SizeBitsArr[I] := TBits(FDocTypesBitsList[I]).Size;
  FDocTypesBitsList.Clear;
  for I:=0 to Length(SizeBitsArr)-1 do
  begin
    FDocTypesBitsList.Add(TBits.Create);
    TBits(FDocTypesBitsList[I]).Size := SizeBitsArr[I];
  end;

  I := FCardFeaturesBits.Size;
  if Assigned(FCardFeaturesBits) then
    FCardFeaturesBits.Free;
  FCardFeaturesBits := TBits.Create;
  FCardFeaturesBits.Size := I;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_CardMergeForm.DataDestroy;
var
  I: Integer;
begin
  FCurBranchIndex := -1;
  FDocTypesBitsList.Clear;
  FSelectedDocTypesList.Clear;
  FAllDocTypesList.Clear;
  FSelectedCardFeatures.Clear;
  FAllCardFeatures.Clear;
  FCardFeaturesBits.Free;
  FCardFeaturesBits := TBits.Create;

  ///tvDocTypes
  with strngrdDocTypes do
    for I:=0 to ColCount-1 do
      Cols[I].Clear;
  strngrdDocTypes.RowCount := 0;
  with strngrdCardFeatures do
    for I:=0 to ColCount-1 do
      Cols[I].Clear;
  strngrdCardFeatures.RowCount := 0;
  mDocTypes.Clear;
  mCardFeatures.Clear;
  dtpMergingDate.Date := Date;
end;

end.
