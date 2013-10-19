unit at_dlgCompareNSRecords_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls, Grids, gdcNamespaceRecCmpController;

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
    lTitle: TLabel;
    lObjClass: TLabel;
    lObjName: TLabel;
    lObjID: TLabel;
    lblID: TLabel;
    lblName: TLabel;
    lblClassName: TLabel;
    actSave: TAction;
    pnlRightBottom: TPanel;
    btnOK: TButton;
    actView: TAction;
    Button1: TButton;
    actSkip: TAction;
    chbxShowOnlyDiff: TCheckBox;
    procedure sgMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgMainDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure actShowOnlyDiffExecute(Sender: TObject);
    procedure pnlGridResize(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actViewExecute(Sender: TObject);
    procedure actViewUpdate(Sender: TObject);
    procedure actShowOnlyDiffUpdate(Sender: TObject);
    procedure actSkipExecute(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);

  public
    FgdcNamespaceRecCmpController: TgdcNamespaceRecCmpController;
  end;

var
  dlgCompareNSRecords: TdlgCompareNSRecords;

implementation

{$R *.DFM}

uses
  prp_ScriptComparer_unit;

procedure TdlgCompareNSRecords.sgMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Idx: Integer;
  FN: String;
begin
  if FgdcNamespaceRecCmpController = nil then
    exit;

  if (ssDouble in Shift) then
    actView.Execute
  else if (ssLeft in Shift) then
  begin
    FN := sgMain.Cells[0, sgMain.Row];
    Idx := FgdcNamespaceRecCmpController.OverwriteFields.IndexOf(FN);

    if (sgMain.Col = 1) and (Idx > -1) then
    begin
      FgdcNamespaceRecCmpController.OverwriteFields.Delete(Idx);
      sgMain.Refresh;
    end
    else if (sgMain.Col = 2) and (Idx = -1) then
    begin
      FgdcNamespaceRecCmpController.OverwriteFields.Add(FN);
      sgMain.Refresh;
    end
  end;
end;

procedure TdlgCompareNSRecords.sgMainDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  FN: String;
begin
  if FgdcNamespaceRecCmpController = nil then
    exit;

  sgMain.Canvas.Brush.Color := clWindow;
  sgMain.Canvas.Font.Color := clWindowText;
  sgMain.Canvas.Font.Style := [];

  if (gdSelected in State) or (gdFocused in State) then
  begin
    sgMain.Canvas.Brush.Color := clActiveCaption;
    sgMain.Canvas.Font.Color := clCaptionText;
  end;

  if gdFixed in State then
  begin
    sgMain.Canvas.Brush.Color := clBtnFace;
    sgMain.Canvas.Font.Color := clBtnText;
  end;

  sgMain.Canvas.FillRect(Rect);

  if (ARow > 0) and (ACol > 0) then
  begin
    FN := sgMain.Cells[0, ARow];

    if
      (
        (ACol = 1) and (not FgdcNamespaceRecCmpController.OverwriteField(FN))
      )
      or
      (
        (ACol = 2) and FgdcNamespaceRecCmpController.OverwriteField(FN)
      ) then
    begin
      sgMain.Canvas.Font.Style := [fsBold];
      sgMain.Canvas.Font.Color := clWindowText;
    end else
    begin
      sgMain.Canvas.Font.Style := [];
      sgMain.Canvas.Font.Color := clGrayText;
    end;
  end;

  sgMain.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, sgMain.Cells[ACol, ARow]);
end;

procedure TdlgCompareNSRecords.actShowOnlyDiffExecute(Sender: TObject);
begin
  FgdcNamespaceRecCmpController.FillGrid(sgMain, not chbxShowOnlyDiff.Checked);
end;

procedure TdlgCompareNSRecords.pnlGridResize(Sender: TObject);
begin
  sgMain.ColWidths[1] := Trunc((sgMain.Width - GetSystemMetrics(SM_CYHSCROLL)) / 2.8);
  sgMain.ColWidths[2] := sgMain.ColWidths[1];
  sgMain.ColWidths[0] := Trunc(sgMain.Width - sgMain.ColWidths[1] * 2 - GetSystemMetrics(SM_CYHSCROLL) * 1.5);
end;

procedure TdlgCompareNSRecords.actSaveExecute(Sender: TObject);
begin
  ModalResult := mrOk;
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

procedure TdlgCompareNSRecords.actSkipExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgCompareNSRecords.actSaveUpdate(Sender: TObject);
begin
  actSave.Enabled := FgdcNamespaceRecCmpController.OverwriteFields.Count > 0;
end;

end.
