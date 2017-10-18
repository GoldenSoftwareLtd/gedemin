unit at_dlgCompareNSRecords_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls, Grids, gdcNamespaceRecCmpController,
  TB2Item, TB2Dock, TB2Toolbar;

type
  TLoadRecord = (lrNone, lrFromFile, lrNotLoad);

  TdlgCompareNSRecords = class(TForm)
    pnlWorkArea: TPanel;
    actList: TActionList;
    lCaption: TLabel;
    pnlBottom: TPanel;
    actShowOnlyDiff: TAction;
    pnlGrid: TPanel;
    sgMain: TStringGrid;
    pnlTop: TPanel;
    actContinue: TAction;
    pnlRightBottom: TPanel;
    btnSave: TButton;
    actView: TAction;
    btnCancel: TButton;
    actCancel: TAction;
    mObject: TMemo;
    rbSkip: TRadioButton;
    rbOverwrite: TRadioButton;
    rbSelected: TRadioButton;
    actObject: TAction;
    actProperties: TAction;
    tbDock: TTBDock;
    tb: TTBToolbar;
    TBControlItem1: TTBControlItem;
    tbView: TTBItem;
    chbxShowOnlyDiff: TCheckBox;
    TBSeparatorItem1: TTBSeparatorItem;
    pnlButtons: TPanel;
    btnProperties: TButton;
    btnObject: TButton;
    actCopyValue: TAction;
    TBItem1: TTBItem;
    procedure sgMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgMainDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure actShowOnlyDiffExecute(Sender: TObject);
    procedure pnlGridResize(Sender: TObject);
    procedure actContinueExecute(Sender: TObject);
    procedure actViewExecute(Sender: TObject);
    procedure actViewUpdate(Sender: TObject);
    procedure actShowOnlyDiffUpdate(Sender: TObject);
    procedure actContinueUpdate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actCancelUpdate(Sender: TObject);
    procedure rbSkipClick(Sender: TObject);
    procedure rbOverwriteClick(Sender: TObject);
    procedure rbSelectedClick(Sender: TObject);
    procedure actObjectUpdate(Sender: TObject);
    procedure actPropertiesUpdate(Sender: TObject);
    procedure actPropertiesExecute(Sender: TObject);
    procedure actObjectExecute(Sender: TObject);
    procedure actCopyValueUpdate(Sender: TObject);
    procedure actCopyValueExecute(Sender: TObject);

  private
    FGlyphChecked: TBitmap;
    FGlyphUnChecked: TBitmap;

    procedure SelectRow(const ARow: Integer);

  public
    FgdcNamespaceRecCmpController: TgdcNamespaceRecCmpController;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  dlgCompareNSRecords: TdlgCompareNSRecords;

implementation

{$R *.DFM}

uses
  Clipbrd, prp_ScriptComparer_unit, dmImages_unit;

const
  CHECK_WIDTH = 13;
  CHECK_HEIGHT = 13;

procedure TdlgCompareNSRecords.sgMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Integer;  
begin
  if FgdcNamespaceRecCmpController = nil then
    exit;

  if (ssLeft in Shift) and (X <= CHECK_WIDTH + 4) then
  begin
    sgMain.MouseToCell(X, Y, ACol, ARow);
    SelectRow(ARow);
  end;
end;

procedure TdlgCompareNSRecords.sgMainDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  FN: String;
begin
  if FgdcNamespaceRecCmpController = nil then
    exit;

  sgMain.Canvas.Font.Style := [];

  if (gdSelected in State) or (gdFocused in State) then
  begin
    sgMain.Canvas.Brush.Color := clActiveCaption;
    sgMain.Canvas.Font.Color := clCaptionText;
  end
  else if gdFixed in State then
  begin
    sgMain.Canvas.Brush.Color := clBtnFace;
    sgMain.Canvas.Font.Color := clBtnText;
  end
  else if rbSelected.Checked then
  begin
    sgMain.Canvas.Brush.Color := clWindow;
    sgMain.Canvas.Font.Color := clWindowText;
  end else
  begin
    sgMain.Canvas.Brush.Color := clBtnFace;
    sgMain.Canvas.Font.Color := clBtnText;
  end;

  if (ARow > 0) and (ACol > 0) then
  begin
    FN := sgMain.Cells[0, ARow];

    if FgdcNamespaceRecCmpController.OverwriteField(FN) then
    begin
      if (gdSelected in State) or (gdFocused in State) then
        sgMain.Canvas.Brush.Color := clMaroon
      else
        sgMain.Canvas.Brush.Color := clRed;
      sgMain.Canvas.Font.Color := clWhite;
    end else
    begin
      if sgMain.Cells[1, ARow] = sgMain.Cells[2, ARow] then
        sgMain.Canvas.Font.Color := clGrayText;
    end;
  end;

  sgMain.Canvas.FillRect(Rect);

  if (ACol = 0) and (ARow > 0) then
  begin
    if rbSelected.Checked and (sgMain.Cells[1, ARow] <> sgMain.Cells[2, ARow]) then
    begin
      FN := sgMain.Cells[0, ARow];

      if FgdcNamespaceRecCmpController.OverwriteField(FN) then
        sgMain.Canvas.BrushCopy
        (
          Classes.Rect(Rect.Left + 2, Rect.Top + 2, Rect.Left + 2 + CHECK_WIDTH, Rect.Top + 2 + CHECK_HEIGHT),
          FGlyphChecked,
          Classes.Rect(0, 0, CHECK_WIDTH, CHECK_HEIGHT),
          clNone
        )
      else
        sgMain.Canvas.BrushCopy
        (
          Classes.Rect(Rect.Left + 2, Rect.Top + 2, Rect.Left + 2 + CHECK_WIDTH, Rect.Top + 2 + CHECK_HEIGHT),
          FGlyphUnChecked,
          Classes.Rect(0, 0, CHECK_WIDTH, CHECK_HEIGHT),
          clNone
        );
    end;    

    sgMain.Canvas.TextOut(Rect.Left + 2 + CHECK_WIDTH + 2, Rect.Top + 2, sgMain.Cells[ACol, ARow]);
  end else
    sgMain.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, sgMain.Cells[ACol, ARow]);
end;

procedure TdlgCompareNSRecords.actShowOnlyDiffExecute(Sender: TObject);
begin
  FgdcNamespaceRecCmpController.FillGrid(sgMain, not chbxShowOnlyDiff.Checked);
end;

procedure TdlgCompareNSRecords.pnlGridResize(Sender: TObject);
begin
  sgMain.ColWidths[1] := Trunc((sgMain.Width - GetSystemMetrics(SM_CYHSCROLL)) / 3);
  sgMain.ColWidths[2] := sgMain.ColWidths[1];
  sgMain.ColWidths[0] := Trunc(sgMain.Width - sgMain.ColWidths[1] * 2 - GetSystemMetrics(SM_CYHSCROLL) * 1.5);
end;

procedure TdlgCompareNSRecords.actContinueExecute(Sender: TObject);
begin
  if rbSkip.Checked then
    ModalResult := mrCancel
  else begin
    if rbOverwrite.Checked then
      FgdcNamespaceRecCmpController.OverwriteFields.Assign(
        FgdcNamespaceRecCmpController.InequalFields);
    ModalResult := mrOk;
  end;
end;

procedure TdlgCompareNSRecords.actViewExecute(Sender: TObject);
var
  ScriptComparer: Tprp_ScriptComparer;
begin
  ScriptComparer := Tprp_ScriptComparer.Create(nil);
  try
    ScriptComparer.Compare(sgMain.Cells[1, sgMain.Row], sgMain.Cells[2, sgMain.Row]);
    ScriptComparer.LeftCaption('В базе данных:');
    ScriptComparer.RightCaption('В файле:');
    ScriptComparer.ShowModal;
  finally
    ScriptComparer.Free;
  end;
end;

procedure TdlgCompareNSRecords.actViewUpdate(Sender: TObject);
begin
  actView.Enabled := sgMain.RowCount > 1;
end;

procedure TdlgCompareNSRecords.actShowOnlyDiffUpdate(Sender: TObject);
begin
  actShowOnlyDiff.Enabled := FgdcNamespaceRecCmpController <> nil;
end;

procedure TdlgCompareNSRecords.actContinueUpdate(Sender: TObject);
begin
  actContinue.Enabled := (FgdcNamespaceRecCmpController <> nil)
    and (rbSkip.Checked or rbOverwrite.Checked or (rbSelected.Checked
      and (FgdcNamespaceRecCmpController.OverwriteFields.Count > 0)));
end;

procedure TdlgCompareNSRecords.actCancelExecute(Sender: TObject);
begin
  FgdcNamespaceRecCmpController.CancelLoad := True;
  ModalResult := mrCancel;
end;

procedure TdlgCompareNSRecords.actCancelUpdate(Sender: TObject);
begin
  actCancel.Enabled := FgdcNamespaceRecCmpController <> nil;
end;

procedure TdlgCompareNSRecords.rbSkipClick(Sender: TObject);
begin
  sgMain.Refresh;
end;

procedure TdlgCompareNSRecords.rbOverwriteClick(Sender: TObject);
begin
  sgMain.Refresh;
end;

procedure TdlgCompareNSRecords.rbSelectedClick(Sender: TObject);
begin
  sgMain.Refresh;
end;

procedure TdlgCompareNSRecords.actObjectUpdate(Sender: TObject);
begin
  actObject.Enabled := FgdcNamespaceRecCmpController <> nil;
end;

procedure TdlgCompareNSRecords.actPropertiesUpdate(Sender: TObject);
begin
  actProperties.Enabled := FgdcNamespaceRecCmpController <> nil;
end;

procedure TdlgCompareNSRecords.actPropertiesExecute(Sender: TObject);
begin
  FgdcNamespaceRecCmpController.ViewObjectProperties;
end;

procedure TdlgCompareNSRecords.actObjectExecute(Sender: TObject);
begin
  FgdcNamespaceRecCmpController.EditObject;
end;

constructor TdlgCompareNSRecords.Create(AnOwner: TComponent);

  procedure LoadCheckBox(ABitmap: TBitmap; Checked: Boolean);
  var
    B: TBitmap;
    R: TRect;
  begin
    B := TBitmap.Create;
    try
      B.Handle := LoadBitmap(0, MAKEINTRESOURCE(OBM_CHECKBOXES));

      ABitmap.Width := CHECK_WIDTH;
      ABitmap.Height := CHECK_HEIGHT;

      if Checked then
        R := Rect(CHECK_WIDTH, 0, CHECK_WIDTH * 2, CHECK_HEIGHT)
      else
        R := Rect(0, 0, CHECK_WIDTH, CHECK_HEIGHT);

      ABitmap.Canvas.CopyRect(Rect(0, 0, CHECK_WIDTH, CHECK_HEIGHT), B.Canvas, R);
    finally
      B.Free;
    end;
  end;

begin
  inherited;
  FGlyphChecked := TBitmap.Create;
  LoadCheckBox(FGlyphChecked, True);
  FGlyphUnChecked := TBitmap.Create;
  LoadCheckBox(FGlyphUnChecked, False);
end;

destructor TdlgCompareNSRecords.Destroy;
begin
  FGlyphChecked.Free;
  FGlyphUnChecked.Free;
  inherited;
end;

procedure TdlgCompareNSRecords.SelectRow(const ARow: Integer);
var
  Idx: Integer;
  FN: String;
begin
  if rbSelected.Checked and (sgMain.Cells[1, ARow] <> sgMain.Cells[2, ARow]) then
  begin
    FN := sgMain.Cells[0, ARow];
    Idx := FgdcNamespaceRecCmpController.OverwriteFields.IndexOf(FN);

    if Idx > -1 then
      FgdcNamespaceRecCmpController.OverwriteFields.Delete(Idx)
    else
      FgdcNamespaceRecCmpController.OverwriteFields.Add(FN);

    sgMain.Refresh;
  end;
end;

procedure TdlgCompareNSRecords.actCopyValueUpdate(Sender: TObject);
begin
  actCopyValue.Enabled := (sgMain.Row > 0) and (sgMain.Col > 0);
end;

procedure TdlgCompareNSRecords.actCopyValueExecute(Sender: TObject);
begin
  Clipboard.AsText := sgMain.Cells[sgMain.Col, sgMain.Row];
end;

end.
