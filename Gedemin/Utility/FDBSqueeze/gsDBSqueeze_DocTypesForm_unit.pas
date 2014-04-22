unit gsDBSqueeze_DocTypesForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ComCtrls, Db, ADODB, DBTables, DBGrids, contnrs,
  ActnList;

type
  EgsDBSqueeze = class(Exception);

  TgsDBSqueeze_DocTypesForm = class(TForm)
    strngrdIgnoreDocTypes: TStringGrid;
    mIgnoreDocTypes: TMemo;
    tvDocTypes: TTreeView;
    txt5: TStaticText;
    txt1: TStaticText;
    btnOK: TButton;
    btnCancel: TButton;
    actList: TActionList;
    actSelectAll: TAction;
    procedure strngrdIgnoreDocTypesDblClick(Sender: TObject);
    procedure strngrdIgnoreDocTypesDrawCell(Sender: TObject; ACol,
      ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure tvDocTypesCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure tvDocTypesClick(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
  private
    FSelectedDocTypesList: TStringList;
    FAllDocTypesList: TStringList;
    FBitsList: TObjectList;
    FCurBranchIndex: Integer;

    TmpList: TStringList;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetDocTypeBranch(const ABranchList: TStringList);
    procedure SetDocTypes(const ADocTypes: TStringList);

    procedure SetSelectedDocTypes(const ASelectedTypesStr: String; const ASelectedRowsStr: String);
    procedure UpdateDocTypesMemo;
    procedure ClearData;
    function GetSelectedIdDocTypes: String;
    function GetSelectedDocTypesStr: String;
    function GetSelectedBranchRowsStr: String;
    function GetDocTypeMemoText: String;
  end;




var
  gsDBSqueeze_DocTypesForm: TgsDBSqueeze_DocTypesForm;

implementation

uses gsDBSqueeze_MainForm_unit;

{$R *.DFM}

constructor TgsDBSqueeze_DocTypesForm.Create(AnOwner: TComponent);
begin
  inherited;

  FCurBranchIndex := -1;
  FBitsList :=  TObjectList.Create;
  FSelectedDocTypesList := TStringList.Create;
  FAllDocTypesList := TStringList.Create;
  TmpList := TStringList.Create;

  strngrdIgnoreDocTypes.ColCount := 2;
  strngrdIgnoreDocTypes.RowCount := 0;
end;
//---------------------------------------------------------------------------
destructor TgsDBSqueeze_DocTypesForm.Destroy;
begin
  FSelectedDocTypesList.Free;
  FAllDocTypesList.Free;
  TmpList.Free;
  FBitsList.Free;

  inherited;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.UpdateDocTypesMemo;
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
    mIgnoreDocTypes.Clear;
    mIgnoreDocTypes.Text := Str;
  end
  else
    mIgnoreDocTypes.Clear;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.strngrdIgnoreDocTypesDblClick(Sender: TObject);
var
  I: Integer;
begin
  if FCurBranchIndex <> -1 then
  begin
    if Sender = strngrdIgnoreDocTypes then
    begin
      for I:= (Sender as TStringGrid).Selection.Top to (Sender as TStringGrid).Selection.Bottom  do
      begin
        if not TBits(FBitsList[FCurBranchIndex])[I] then
        begin
          TBits(FBitsList[FCurBranchIndex])[I] := True;

          if FSelectedDocTypesList.IndexOfName(Trim(strngrdIgnoreDocTypes.Cells[1, I])) = -1 then
            FSelectedDocTypesList.Append(Trim(strngrdIgnoreDocTypes.Cells[1, I]) + '=' + Trim(strngrdIgnoreDocTypes.Cells[0, I]));
        end
        else begin
          TBits(FBitsList[FCurBranchIndex])[I] := False;
          if FSelectedDocTypesList.IndexOfName(Trim(strngrdIgnoreDocTypes.Cells[1, I])) <> -1 then
            FSelectedDocTypesList.Delete(FSelectedDocTypesList.IndexOfName(Trim(strngrdIgnoreDocTypes.Cells[1, I])));
        end;
      end;

      (Sender as TStringGrid).Repaint;

      UpdateDocTypesMemo;
    end;
  end;  
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.strngrdIgnoreDocTypesDrawCell(
  Sender: TObject;
  ACol, ARow: Integer;
  Rect: TRect;
  State: TGridDrawState);
var
  AGrid : TStringGrid;
begin
  if FCurBranchIndex <> -1 then
  begin
    AGrid:=TStringGrid(Sender);

     if not TBits(FBitsList[FCurBranchIndex])[ARow] then
       AGrid.Canvas.Brush.Color := clWhite
     else
       AGrid.Canvas.Brush.Color := $0088AEFF;

     if (gdSelected in State) then
     begin
       if not TBits(FBitsList[FCurBranchIndex])[ARow] then
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
procedure TgsDBSqueeze_DocTypesForm.tvDocTypesCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  if cdsSelected in State  then
    Sender.Canvas.Brush.Color := $001F67FC;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.tvDocTypesClick(Sender: TObject);
var
  BranchDocTypes: TStringList;
  I: Integer;
begin
  if tvDocTypes.Selected.AbsoluteIndex <> FCurBranchIndex then
  begin
    with strngrdIgnoreDocTypes do
      for I:=0 to ColCount-1 do
        Cols[I].Clear;
    strngrdIgnoreDocTypes.RowCount := 0;
    
    FCurBranchIndex := tvDocTypes.Selected.AbsoluteIndex;

    if FAllDocTypesList.Values[FAllDocTypesList.Names[FCurBranchIndex]] <> '0' then
    begin
      BranchDocTypes := TStringList.Create;
      try
        BranchDocTypes.Text := StringReplace(FAllDocTypesList[FCurBranchIndex], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
        strngrdIgnoreDocTypes.RowCount :=  BranchDocTypes.Count;
        for I:=0 to BranchDocTypes.Count-1 do
        begin
          strngrdIgnoreDocTypes.Cells[0, I] := BranchDocTypes.Values[BranchDocTypes.Names[I]];  // имя типа дока
          strngrdIgnoreDocTypes.Cells[1, I] := BranchDocTypes.Names[I];                         // id типа
        end;
      finally
        BranchDocTypes.Free;
      end;
    end;

    strngrdIgnoreDocTypes.Repaint;
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.SetDocTypeBranch(const ABranchList: TStringList);
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
procedure TgsDBSqueeze_DocTypesForm.SetDocTypes(const ADocTypes: TStringList);
var
  I: Integer;
  BranchDocTypes: TStringList;
begin
  FAllDocTypesList.Text :=  ADocTypes.Text;
  FBitsList.Clear;

  with strngrdIgnoreDocTypes do
    for I:=0 to ColCount-1 do
      Cols[I].Clear;
  strngrdIgnoreDocTypes.RowCount := 0;
  FCurBranchIndex := 0;

  if FAllDocTypesList.Values[FAllDocTypesList.Names[FCurBranchIndex]] <> '0' then
  begin
    BranchDocTypes := TStringList.Create;
    try
      BranchDocTypes.Text := StringReplace(FAllDocTypesList[FCurBranchIndex], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
      strngrdIgnoreDocTypes.RowCount :=  BranchDocTypes.Count;
      for I:=0 to BranchDocTypes.Count-1 do
      begin
        strngrdIgnoreDocTypes.Cells[0, I] := BranchDocTypes.Values[BranchDocTypes.Names[I]];  // имя типа дока
        strngrdIgnoreDocTypes.Cells[1, I] := BranchDocTypes.Names[I];                         // id типа
      end;

      if ADocTypes.Count <> tvDocTypes.Items.Count then
        raise EgsDBSqueeze.Create('Типы документов получены не для всех веток!');

      for I:=0 to ADocTypes.Count-1 do
      begin
        BranchDocTypes.Clear;
        BranchDocTypes.Text := StringReplace(ADocTypes[I], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
        FBitsList.Add(TBits.Create);
        TBits(FBitsList[I]).Size := BranchDocTypes.Count;
      end;
    finally
      BranchDocTypes.Free;
    end;
  end;
  strngrdIgnoreDocTypes.Repaint;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_DocTypesForm.GetSelectedIdDocTypes: String;
var
  SeledctedIdStr: String;
  I: Integer;
begin
  for I:=0 to FSelectedDocTypesList.Count-1 do
  begin
    if SeledctedIdStr > '' then
      SeledctedIdStr := SeledctedIdStr + ',' + FSelectedDocTypesList.Names[I]
    else
      SeledctedIdStr := FSelectedDocTypesList.Names[I];
  end;
  Result := SeledctedIdStr;
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_DocTypesForm.GetSelectedDocTypesStr: String;
var
  Str: String;
begin
  Str := StringReplace(FSelectedDocTypesList.Text, #13#10, '||', [rfReplaceAll, rfIgnoreCase]);
  Delete(Str, Length(Str), 1);
  Result := Str
end;
//---------------------------------------------------------------------------
function TgsDBSqueeze_DocTypesForm.GetSelectedBranchRowsStr: String;
var
  I, J: Integer;
  Str: String;
  SelectedBranchRows: TStringList;
begin
  SelectedBranchRows := TStringList.Create;
  try
    for I:=0 to FBitsList.Count-1 do
    begin
      if TBits(FBitsList[I]).Size > 0 then
      begin
        for J:=0 to TBits(FBitsList[I]).Size-1 do
        begin
          if TBits(FBitsList[I])[J] = true then
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
function TgsDBSqueeze_DocTypesForm.GetDocTypeMemoText: String;
begin
  Result := mIgnoreDocTypes.Text;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.btnOKClick(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(TButton(Sender), False);
  Self.ModalResult := mrOK;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.btnCancelClick(Sender: TObject);
begin
  gsDBSqueeze_MainForm.DefocusControl(TButton(Sender), False);
  Self.ModalResult := mrNone;
  Self.Close;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.SetSelectedDocTypes(const ASelectedTypesStr: String; const ASelectedRowsStr: String);
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
    ClearData;
    FSelectedDocTypesList.Text := StringReplace(ASelectedTypesStr, '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
    mIgnoreDocTypes.Clear;
    Str := '';
    for I:=0 to FSelectedDocTypesList.Count-1 do
    begin
      if Str > '' then
        Str := Str + ', ' + FSelectedDocTypesList.Values[FSelectedDocTypesList.Names[I]] + ' (' + FSelectedDocTypesList.Names[I] + ')'
      else
        Str := FSelectedDocTypesList.Values[FSelectedDocTypesList.Names[I]] + ' (' + FSelectedDocTypesList.Names[I] + ')';
    end;
    mIgnoreDocTypes.Text := Str;

    SelectedBranch.Text := StringReplace(ASelectedRowsStr, ',', #13#10, [rfReplaceAll, rfIgnoreCase]);

    for I:=0 to SelectedBranch.Count-1 do
    begin
      SelectedGridRows.Clear;
      SelectedGridRows.Text := StringReplace(SelectedBranch.Values[SelectedBranch.Names[I]], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
      for J:=0 to SelectedGridRows.Count-1 do
        TBits(FBitsList[StrToInt(Trim(SelectedBranch.Names[I]))])[StrToInt(Trim(SelectedGridRows[J]))] := True;
    end;

    FCurBranchIndex := 0;
    if FAllDocTypesList.Values[FAllDocTypesList.Names[FCurBranchIndex]] <> '0' then
    begin
      BranchDocTypes.Text := StringReplace(FAllDocTypesList[FCurBranchIndex], '||', #13#10, [rfReplaceAll, rfIgnoreCase]);
      strngrdIgnoreDocTypes.RowCount :=  BranchDocTypes.Count;
      for I:=0 to BranchDocTypes.Count-1 do
      begin
        strngrdIgnoreDocTypes.Cells[0, I] := BranchDocTypes.Values[BranchDocTypes.Names[I]];  // имя типа дока
        strngrdIgnoreDocTypes.Cells[1, I] := BranchDocTypes.Names[I];                         // id типа
      end;
    end;
    strngrdIgnoreDocTypes.Repaint;
  finally
    SelectedBranch.Free;
    SelectedGridRows.Free;
    BranchDocTypes.Free;
  end;                       
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.ClearData;
var
  I: Integer;
  SizeBitsArr:  array of Integer;
begin
  with strngrdIgnoreDocTypes do
  for I:=0 to ColCount-1 do
    Cols[I].Clear;

  mIgnoreDocTypes.Clear;
  FSelectedDocTypesList.Clear;

  SetLength(SizeBitsArr, FBitsList.Count);
  for I:=0 to FBitsList.Count-1 do
    SizeBitsArr[I] := TBits(FBitsList[I]).Size;
  FBitsList.Clear;
  for I:=0 to Length(SizeBitsArr)-1 do
  begin
    FBitsList.Add(TBits.Create);
    TBits(FBitsList[I]).Size := SizeBitsArr[I];
  end;
end;
//---------------------------------------------------------------------------
procedure TgsDBSqueeze_DocTypesForm.actSelectAllExecute(Sender: TObject);
var
  Rect: TGridRect;
begin
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := strngrdIgnoreDocTypes.ColCount-1;
  Rect.Bottom := strngrdIgnoreDocTypes.RowCount-1;
  strngrdIgnoreDocTypes.Selection := Rect;
end;

end.
