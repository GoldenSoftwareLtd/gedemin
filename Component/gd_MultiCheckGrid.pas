
unit gd_MultiCheckGrid;

interface

uses
  Windows, Classes, Grids, Graphics, Controls;

const
  BigCardValue = $FFFFFFFF;

type
  TMultiCheckGrid = class(TDrawGrid)
  private
    FCheckList, FColumnHeader: TStrings;
    FNameColCount: Integer;
    FUseInclude: Boolean;
    FCheckIm, FUncheckIm: TBitmap;

    procedure SetColumnHeader(AnValue: TStrings);
    procedure SetCheckList(AnValue: TStrings);
    procedure LoadBitmapResource(ABitmap: TBitmap; Checked: Boolean);
    procedure ChangeCheck;

  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
     AState: TGridDrawState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    property ColumnHeader: TStrings read FColumnHeader write SetColumnHeader;
    property CheckList: TStrings read FCheckList write SetCheckList;
    property NameColCount: Integer read FNameColCount write FNameColCount;
    property UseInclude: Boolean read FUseInclude write FUseInclude;
  end;

procedure Register;

implementation

const
  BMPWidth       = 13;
  BMPHeight      = 13;
  LeftSpace      = 5;
  TopSpace       = 2;

procedure TMultiCheckGrid.ChangeCheck;
var
  IsChecked: Boolean;
begin
  if Selection.Left >= FNameColCount then
  begin
    if FUseInclude and
     ((Cardinal(FCheckList.Objects[Selection.Top - FixedRows]) and
     not ($FFFFFFFF shl (Selection.Left - FNameColCount))) > 0) then
      Exit;
    IsChecked := ((Cardinal(FCheckList.Objects[Selection.Top - FixedRows])
     shr (Selection.Left - FNameColCount)) and 1) = 1;
    if IsChecked or not FUseInclude then
      FCheckList.Objects[Selection.Top - FixedRows] :=
       Pointer(Cardinal(FCheckList.Objects[Selection.Top - FixedRows]) xor
       (1 shl (Selection.Left - FNameColCount)))
    else
      FCheckList.Objects[Selection.Top - FixedRows] :=
       Pointer(Cardinal(FCheckList.Objects[Selection.Top - FixedRows]) or
       ($FFFFFFFF shl (Selection.Left - FNameColCount)));
    Refresh;
  end;
end;

constructor TMultiCheckGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FCheckList := TStringList.Create;
  FColumnHeader := TStringList.Create;
  FCheckIm := TBitmap.Create;
  FUncheckIm := TBitmap.Create;
  LoadBitmapResource(FCheckIm, True);
  LoadBitmapResource(FUncheckIm, False);
end;

destructor TMultiCheckGrid.Destroy;
begin
  FCheckIm.Free;
  FUncheckIm.Free;
  FColumnHeader.Free;
  FCheckList.Free;

  inherited Destroy;
end;

procedure TMultiCheckGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  TempCaption: String;
begin
  try
    if Font.Size * 2 <> DefaultRowHeight then
      DefaultRowHeight := Font.Size * 2;
    if FCheckList.Count > 0 then
      RowCount := FCheckList.Count + FixedRows;
    ColCount := FColumnHeader.Count;
    TempCaption := '';
    if {not (csDesigning in ComponentState) and }(FColumnHeader.Count > 0) and
     (FCheckList.Count > 0) then
    begin
      if (gdFixed in AState) and (ARow = 0) then
        TempCaption := FColumnHeader.Strings[ACol]
      else
        if ACol < FNameColCount then
          TempCaption := FCheckList.Strings[ARow - FixedRows]
        else
        begin
          if FUseInclude and ((Cardinal(FCheckList.Objects[ARow - FixedRows]) and
           not (BigCardValue shl (ACol - FNameColCount))) > 0) then
          begin
            Canvas.Brush.Color := clBtnFace;
            Canvas.FillRect(ARect);
            Canvas.Brush.Color := clWhite;
          end;

          if ((Cardinal(FCheckList.Objects[ARow - FixedRows]) shr (ACol - FNameColCount)) and 1) = 1 then
            Canvas.Draw(ARect.Left + LeftSpace, ARect.Top + TopSpace, FCheckIm)
          else
            Canvas.Draw(ARect.Left + LeftSpace, ARect.Top + TopSpace, FUncheckIm);
        end;
      if TempCaption > '' then
        Canvas.TextOut(ARect.Left + LeftSpace, ARect.Top + TopSpace, TempCaption);
    end;

  finally
    inherited DrawCell(ACol, ARow, ARect, AState);
  end;
end;

procedure TMultiCheckGrid.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if not (csDesigning in ComponentState) and (Key = VK_SPACE) then
    ChangeCheck;
  inherited KeyUp(Key, Shift);
end;

procedure TMultiCheckGrid.LoadBitmapResource(ABitmap: TBitmap; Checked: Boolean);
var
  B: TBitmap;
  R: TRect;
begin
  B := TBitmap.Create;
  try
    B.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_CHECKBOXES));

    ABitmap.Width := BMPWidth;
    ABitmap.Height := BMPHeight;

    if Checked then
      R := Rect(BMPWidth, 0, BMPWidth * 2, BMPHeight)
    else
      R := Rect(0, 0, BMPWidth, BMPHeight);

    ABitmap.Canvas.CopyRect(Rect(0, 0, BMPWidth, BMPHeight), B.Canvas, R);
  finally
    B.Free;
  end;
end;

procedure TMultiCheckGrid.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  TempRect: TRect;
begin
  TempRect := CellRect(Selection.Left, Selection.Top);
  if (TempRect.Left + LeftSpace <= X) and (TempRect.Left + LeftSpace + BMPWidth >= X) and
   (TempRect.Top + TopSpace <= Y) and (TempRect.Top + TopSpace + BMPHeight >= Y) then
    ChangeCheck;
  inherited MouseUp(Button, Shift, X, Y);
end;

procedure TMultiCheckGrid.SetCheckList(AnValue: TStrings);
begin
  if Assigned(AnValue) then
  begin
    FCheckList.Assign(AnValue);
    Refresh;
  end;
end;

procedure TMultiCheckGrid.SetColumnHeader(AnValue: TStrings);
begin
  if Assigned(AnValue) then
  begin
    FColumnHeader.Assign(AnValue);
    Refresh;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TMultiCheckGrid]);
end;

end.
