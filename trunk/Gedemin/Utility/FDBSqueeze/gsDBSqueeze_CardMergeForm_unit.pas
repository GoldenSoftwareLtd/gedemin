unit gsDBSqueeze_CardMergeForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Grids, contnrs, ActnList;

type
  EgsDBSqueeze = class(Exception);
  
  TgsDBSqueeze_CardMergeForm = class(TForm)
    strngrdDocTypes: TStringGrid;
    txt5: TStaticText;
    txt1: TStaticText;
    tvDocTypes: TTreeView;
    mDocTypes: TMemo;
    txt2: TStaticText;
    mmo1: TMemo;
    btnMergeGo: TButton;
    dtpClosingDate: TDateTimePicker;
    btn1: TButton;
    strngrdCardFeatures: TStringGrid;
    mCardFeatures: TMemo;
    actlstCardMerge: TActionList;
    actSelectAllDocs: TAction;
    procedure tvDocTypesClick(Sender: TObject);
    procedure tvDocTypesCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure strngrdDocTypesDblClick(Sender: TObject);
    procedure strngrdDocTypesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure strngrdCardFeaturesDblClick(Sender: TObject);
    procedure strngrdCardFeaturesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure actSelectAllDocsExecute(Sender: TObject);
    procedure btnMergeGoClick(Sender: TObject);
    procedure btnIsMergeOption(Sender: TObject);
  private
    FCurBranchIndex: Integer;
    FSelectedDocTypesList: TStringList;
    FAllDocTypesList: TStringList;
    FDocTypesBitsList: TObjectList;

    FSelectedCardFeatures: TStringList;
    FAllCardFeatures: TStringList;
    FCardFeaturesBits: TBits;

    procedure UpdateCardFeaturesMemo;
    procedure UpdateDocTypesMemo;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetCardFeatures(const ACardFatures: TStringList);

    procedure SetDocTypeBranch(const ABranchList: TStringList);
    procedure SetDocTypes(const ADocTypes: TStringList);
    //procedure SetSelectedDocTypes(const ASelectedTypesStr: String; const ASelectedRowsStr: String);

    //procedure ClearData;


    function GetDate: TDateTime;
    function GetSelectedCardFeatures: String;
    function GetSelectedIdDocTypes: String;
   // function GetSelectedDocTypesStr: String;
   // function GetSelectedBranchRowsStr: String;
   // function GetDocTypeMemoText: String;
  end;

var
  gsDBSqueeze_CardMergeForm: TgsDBSqueeze_CardMergeForm;

implementation

{$R *.DFM}

constructor TgsDBSqueeze_CardMergeForm.Create(AnOwner: TComponent);
begin
  inherited;

  dtpClosingDate.Date := Date;
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
  FAllDocTypesList.Text :=  ADocTypes.Text;
  FDocTypesBitsList.Clear;

  with strngrdDocTypes do
    for I:=0 to ColCount-1 do
      Cols[I].Clear;
  strngrdDocTypes.RowCount := 0;
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
procedure TgsDBSqueeze_CardMergeForm.SetCardFeatures(const ACardFatures: TStringList);
var
  I: Integer;
begin
   with strngrdCardFeatures do
    for I:=0 to ColCount-1 do
      Cols[I].Clear;
  strngrdCardFeatures.RowCount := 0;

  FCardFeaturesBits.Free;
  FSelectedCardFeatures.Clear;       //
  FAllCardFeatures.CommaText := ACardFatures.CommaText;
  
  FCardFeaturesBits := TBits.Create;
  FCardFeaturesBits.Size := ACardFatures.Count;
  strngrdCardFeatures.RowCount := ACardFatures.Count;
  for I:=0 to ACardFatures.Count-1 do
  begin
    strngrdCardFeatures.Cells[0, I] := ACardFatures[I];
  end;

  strngrdCardFeatures.Repaint;
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
    Sender.Canvas.Brush.Color := $001F67FC;
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
       AGrid.Canvas.Brush.Color := $0088AEFF;

     if (gdSelected in State) then
     begin
       if not TBits(FDocTypesBitsList[FCurBranchIndex])[ARow] then
       begin
         AGrid.Canvas.Brush.Color := $0088AEFF;
       end
       else
         AGrid.Canvas.Brush.Color := $001F67FC;
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
     AGrid.Canvas.Brush.Color := $0088AEFF;

   if (gdSelected in State) then
   begin
     if not FCardFeaturesBits[ARow] then
     begin
       AGrid.Canvas.Brush.Color := $0088AEFF;
     end
     else
       AGrid.Canvas.Brush.Color := $001F67FC;
   end;
    AGrid.Canvas.FillRect(Rect);
    AGrid.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, AGrid.Cells[ACol, ARow]);
  end;  
end;
//---------------------------------------------------------------------------

procedure TgsDBSqueeze_CardMergeForm.actSelectAllDocsExecute(
  Sender: TObject);
var
  Rect: TGridRect;
begin
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := strngrdDocTypes.ColCount-1;
  Rect.Bottom := strngrdDocTypes.RowCount-1;
  strngrdDocTypes.Selection := Rect;
end;

procedure TgsDBSqueeze_CardMergeForm.btnMergeGoClick(Sender: TObject);
begin
  Self.ModalResult := mrYes;
  Self.Close;
end;

procedure TgsDBSqueeze_CardMergeForm.btnIsMergeOption(Sender: TObject);
begin
  Self.ModalResult := mrOK;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_CardMergeForm.GetDate: TDateTime;
begin
  Result := dtpClosingDate.Date;
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
  
end.
