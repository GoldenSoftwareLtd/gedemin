
{++

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    xPrintCube.pas

  Abstract

    Delphi non visual components that allow to print desision grid.

  Author

    Michael Shoihet (17 jan 1998)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00   17-Jan-98    michael      Initial version.
--}


unit xPrintCube;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Grids,
  mxgrid, ExtCtrls, mxstore, Db, DBTables, mxtables, Printers;

type
  TxPrintCube = class(TComponent)
  private
    { Private declarations }
    FDecisionGrid: TDecisionGrid;
    FWorkSpaceFont: TFont;
    FTitleFont: TFont;
    FTitle: TStringList;
    FPen: TPen;

    FLeftMargin: Integer;
    FRightMargin: Integer;
    FTopMargin: Integer;
    FBottomMargin: Integer;

    ColWidths: Pointer;
    ColsPerPage: Integer;
    RowsPerPage: Integer;
    RowCount: Longint;
    ColCount: Longint;

    CurrentCol: Integer;
    CurrentRow: Integer;
    CurrentGridRow: Integer;
    NumPage: Integer;
    FirstGridRow, FirstRow: Integer;

    procedure SetTitle(aValue: TStringList);
    procedure SetTitleFont(aValue: TFont);
    procedure SetWorkSpaceFont(aValue: TFont);
    procedure SetPen(aValue: TPen);

    procedure InitializePrinter;
    procedure PrintPage;
  protected
    { Protected declarations }
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    destructor Destroy;
      override;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent);
      override;
    procedure Execute;
  published
    { Published declarations }
    property DecisionGrid: TDecisionGrid read FDecisionGrid write FDecisionGrid;
    property WorkSpaceFont: TFont read FWorkSpaceFont write SetWorkSpaceFont;
    property TitleFon: TFont read FTitleFont write SetTitleFont;
    property Title: TStringList read FTitle write SetTitle;
    property Pen: TPen read FPen write SetPen;
  end;

procedure Register;

implementation

type
  PIntArray = ^TIntArray;
  TIntArray = array[0..MaxCustomExtents] of Integer;

constructor TxPrintCube.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FDecisionGrid := nil;
  FTitle := TStringList.Create;
  ColWidths := nil;
  FWorkSpaceFont := TFont.Create;
  FWorkSpaceFont.Name := 'Arial Cyr';
  FWorkSpaceFont.Charset := RUSSIAN_CHARSET;
  FWorkSpaceFont.Size := 8;

  FTitleFont := TFont.Create;
  FTitleFont.Name := 'Arial Cyr';
  FTitleFont.Charset := RUSSIAN_CHARSET;
  FTitleFont.Size := 10;
  FTitleFont.Style := [fsBold];

  FPen := TPen.Create;
  FPen.Style := psSolid;
  FPen.Width := 2;

end;

destructor TxPrintCube.Destroy;
begin
  if ColWidths <> nil then FreeMem(ColWidths);
  FTitle.Free;
  FWorkSpaceFont.Free;
  FTitleFont.Free;
  inherited Destroy;
end;

procedure TxPrintCube.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (FDecisionGrid <> nil) and
     (AComponent = FDecisionGrid) then
    FDecisionGrid := nil;
end;

procedure TxPrintCube.Execute;
begin
  if FDecisionGrid = nil then exit;
  Printer.BeginDoc;
  NumPage:= 1;
  InitializePrinter;
  while CurrentRow < RowCount - 1 do begin
    PrintPage;
    if CurrentRow < RowCount then
      Printer.NewPage;
    Inc(NumPage);
  end;
  Printer.EndDoc;
end;

procedure TxPrintCube.SetTitle(aValue: TStringList);
begin
  FTitle.Assign(aValue);
end;

procedure TxPrintCube.SetTitleFont(aValue: TFont);
begin
  FTitleFont.Assign(aValue);
end;

procedure TxPrintCube.SetWorkSpaceFont(aValue: TFont);
begin
  FWorkSpaceFont.Assign(aValue);
end;

procedure TxPrintCube.SetPen(aValue: TPen);
begin
  FPen.Assign(aValue);
end;

procedure TxPrintCube.InitializePrinter;
var
  i, j, MaxWidth, WorkHeight, HeaderHeight: Integer;
begin
  ColCount := FDecisionGrid.ColCount - 1;
  ReAllocMem( ColWidths, ColCount * SizeOf(Integer) );

  Printer.Canvas.Font.Assign(WorkSpaceFont);

  FLeftMargin := Printer.Canvas.TextWidth('WWWW');
  FRightMargin := Printer.Canvas.TextWidth('WWWW');
  FTopMargin := Printer.Canvas.TextHeight('A') * 3;
  FBottomMargin := Printer.Canvas.TextHeight('A') * 3;


  WorkHeight := Printer.Canvas.TextHeight('AAA') + FPen.Width;
  for i := 0 to ColCount - 1 do begin
    MaxWidth := 0;
    for j:= 0 to FDecisionGrid.RowCount - 2 do begin
      if (FDecisionGrid.Cells[i - FDecisionGrid.FixedCols + 1,
          j - FDecisionGrid.FixedRows + 1] <> '') and
         (Printer.Canvas.TextWidth(FDecisionGrid.Cells[i - FDecisionGrid.FixedCols + 1,
          j - FDecisionGrid.FixedRows + 1] + 'W') > MaxWidth)
      then
        MaxWidth := Printer.Canvas.TextWidth(FDecisionGrid.Cells[i - FDecisionGrid.FixedCols + 1,
          j - FDecisionGrid.FixedRows + 1] + 'W');
    end;
    PIntArray(ColWidths)^[i] := MaxWidth;
  end;
  RowCount := 0;
  for j := 0 to FDecisionGrid.RowCount - 2 do begin
    if (FDecisionGrid.Cells[-1, j] <> 'Sum') then
      Inc(RowCount);
  end;
  Printer.Canvas.Font.Assign(FTitleFont);
  HeaderHeight := Printer.Canvas.TextHeight('AAA') * FTitle.Count;
  RowsPerPage := (Printer.PageHeight - HeaderHeight - FTopMargin - FBottomMargin) div WorkHeight - 1;
  CurrentCol := 0;
  CurrentRow := 0;
  CurrentGridRow := 1 - FDecisionGrid.FixedRows;
  FirstGridRow := 1 - FDecisionGrid.FixedRows;
  FirstRow := 0;
end;

procedure TxPrintCube.PrintPage;
var
  CurHeight, CurWidth, i, j: Integer;
  WorkHeight, PerHeight, PerWidth: Integer;
  OldAlign, PerNum, PerRow: Integer;

function PrintRow(aGridRow: Integer; var aRow: Integer): Boolean;
var
  i: Integer;
begin
  Result:= True;
  CurWidth := FLeftMargin;
  if (FDecisionGrid.Cells[-1, aGridRow] <> 'Sum') then begin
    if aRow > RowCount - 1 then begin
      Result:= False;
      exit;
    end;  
    for i := CurrentCol to CurrentCol + ColsPerPage - 1 do begin
      if i > ColCount - 1 then Break;
      if i < FDecisionGrid.Dimensions.Count then
        PerNum := i
      else
        PerNum := FDecisionGrid.Dimensions.Count - 1;
      case TDisplayDim(FDecisionGrid.Dimensions[PerNum]).Alignment of
      taLeftJustify:
        begin
          OldAlign := SetTextAlign(Printer.Canvas.Handle, TA_LEFT);
          PerWidth := CurWidth;
        end;
      taRightJustify:
        begin
          OldAlign := SetTextAlign(Printer.Canvas.Handle, TA_RIGHT);
          PerWidth := CurWidth + PIntArray(ColWidths)^[i];
        end;
      taCenter:
        begin
          OldAlign := SetTextAlign(Printer.Canvas.Handle, TA_CENTER);
          PerWidth := CurWidth + PIntArray(ColWidths)^[i] div 2;
        end;
      else
        begin
          OldAlign := SetTextAlign(Printer.Canvas.Handle, TA_LEFT);
          PerWidth := CurWidth;
        end;
      end;
      Printer.Canvas.TextOut(PerWidth, CurHeight, FDecisionGrid.Cells[i -
        FDecisionGrid.FixedCols + 1, aGridRow]);
      CurWidth := CurWidth + PIntArray(ColWidths)^[i] + FPen.Width;
      SetTextAlign(Printer.Canvas.Handle, OldAlign);
    end;
    CurHeight := CurHeight + FPen.Width;
    Printer.Canvas.MoveTo(FLeftMargin, CurHeight);
    Printer.Canvas.LineTo(CurWidth, CurHeight);
    CurHeight := CurHeight + WorkHeight;
    Inc(aRow);
  end;
end;

begin
  PerRow := CurrentGridRow;
  Printer.Canvas.Pen.Assign(FPen);
  CurHeight := FTopMargin;
  Printer.Canvas.Font.Assign(FTitleFont);
  if CurrentRow = 0 then begin
    for i := 0 to FTitle.Count - 1 do begin
      Printer.Canvas.TextOut(FLeftMargin, CurHeight, Title[i]);
      CurHeight := CurHeight + Printer.Canvas.TextHeight('AAA') + FPen.Width;
    end;
  end;
  Printer.Canvas.TextOut(Printer.PageWidth - FRightMargin - Printer.Canvas.TextWidth('Стр. AAAA'), FTopMargin,
    Format('Стр.%d', [NumPage]));
  if CurrentRow > 0 then
    CurHeight := CurHeight + Printer.Canvas.TextHeight('AAA') + FPen.Width;
  PerHeight := CurHeight;
  CurWidth := FLeftMargin;
  ColsPerPage := 1;
  for i := CurrentCol to ColCount - 1 do begin
    CurWidth := CurWidth + PIntArray(ColWidths)^[i] + FPen.Width;
    if CurWidth > Printer.PageWidth - FRightMargin then begin
      CurWidth := CurWidth - PIntArray(ColWidths)^[i];
      Break;
    end;
    Inc(ColsPerPage);
  end;
  Printer.Canvas.Font.Assign(FWorkSpaceFont);
  WorkHeight := Printer.Canvas.TextHeight('AAA');
  Printer.Canvas.MoveTo(FLeftMargin, CurHeight);
  Printer.Canvas.LineTo(CurWidth, CurHeight);
  Inc(CurHeight);
  if CurrentRow <> 0 then begin
    j:= FirstRow;
    PrintRow(FirstGridRow, j);
  end;  
  j := CurrentRow;
  while j <= CurrentRow + RowsPerPage - 1 do begin
    if not PrintRow(CurrentGridRow, j) then Break;
    Inc(CurrentGridRow);
  end;
  CurWidth := FLeftMargin + PIntArray(ColWidths)^[CurrentCol] + FPen.Width;
  for i := CurrentCol + 1 to CurrentCol + ColsPerPage - 1 do begin
    if i > ColCount - 1 then Break;
    Printer.Canvas.MoveTo(CurWidth - FPen.Width, PerHeight);
    Printer.Canvas.LineTo(CurWidth - FPen.Width, CurHeight);
    CurWidth := CurWidth + PIntArray(ColWidths)^[i] + FPen.Width;
  end;

  if CurrentCol + ColsPerPage > ColCount then begin
    CurrentRow := CurrentRow + RowsPerPage;
    CurrentCol := 0;
  end
  else begin
    CurrentGridRow := PerRow;
    CurrentCol := CurrentCol + ColsPerPage;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNV', [TxPrintCube]);
end;

end.
