unit at_dlgCompareNSRecords_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, ExtCtrls, Grids, db;

type
  TLoadRecord = (lrNone, lrFromFile, lrNotLoad);

  TdlgCompareNSRecords = class(TForm)
    Panel1: TPanel;
    actList: TActionList;
    lCaption: TLabel;
    sgMain: TStringGrid;
    Panel2: TPanel;
    actOK: TAction;
    actCancel: TAction;
    btnOK: TButton;
    btnCancel: TButton;
    lTitle: TLabel;
    lObjClass: TLabel;
    lblClassName: TLabel;
    lblName: TLabel;
    lObjName: TLabel;
    lObjID: TLabel;
    lblID: TLabel;
    cbShowOnlyDiff: TCheckBox;
    actShowOnlyDiff: TAction; 
    procedure FormShow(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure sgMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgMainDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure actShowOnlyDiffExecute(Sender: TObject);
  private
    { Private declarations }
  public
    Records: TDataSet;   
  end;

var
  dlgCompareNSRecords: TdlgCompareNSRecords;

implementation

{$R *.DFM}

procedure TdlgCompareNSRecords.FormShow(Sender: TObject);
begin 
  sgMain.ColWidths[1] := Trunc((sgMain.Width - GetSystemMetrics(SM_CYHSCROLL)) / 2.8);
  sgMain.ColWidths[2] := sgMain.ColWidths[1];
  sgMain.ColWidths[0] := Trunc(sgMain.Width - sgMain.ColWidths[1] * 2 - GetSystemMetrics(SM_CYHSCROLL) * 1.5);
  sgMain.Cells[0, 0] := 'Поле';
  sgMain.Cells[1, 0] := 'Объект из базы';
  sgMain.Cells[2, 0] := 'Загружаемый объект';

  actShowOnlyDiff.Execute;   
end;

procedure TdlgCompareNSRecords.actOKExecute(Sender: TObject);
begin
  Self.Close;
  Self.ModalResult := mrOK;
end;


procedure TdlgCompareNSRecords.actCancelExecute(Sender: TObject);
begin
  Self.Close;
  Self.ModalResult := mrCancel;
end;

procedure TdlgCompareNSRecords.sgMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (ssDouble in Shift) then
  begin
    if Records.Locate('LR_FieldName', sgMain.Cells[0, sgMain.Row], []) then
    begin
      if sgMain.Col = 1 then
      begin
        Records.Edit;
        Records.FieldByName('LR_NewValue').AsInteger := 0;
        Records.Post;
      end else
        if sgMain.Col = 2 then
        begin
          Records.Edit;
          Records.FieldByName('LR_NewValue').AsInteger := 1;
          Records.Post;
        end;
      sgMain.Refresh;
    end;
  end; 
end;

procedure TdlgCompareNSRecords.sgMainDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if (State * [gdSelected, gdFocused]) <> [] then
  begin
    sgMain.Canvas.Brush.Color := clBtnFace;
    sgMain.Canvas.FillRect(Rect);
  end;
  
  Records.Locate('LR_FieldName', sgMain.Cells[0, ARow], []);
  if (ACol <> 0) and (ARow <> 0) then
  begin
    if ((ACol = 1) and (Records.FieldByName('LR_NewValue').AsInteger = 1))
      or ((ACol = 2) and (Records.FieldByName('LR_NewValue').AsInteger = 0))
    then
      sgMain.Canvas.Font.Color := clGray
    else
    begin
      sgMain.Canvas.Font.Style := [fsBold];
      sgMain.Canvas.Font.Color := clBlack;
    end;
      
    sgMain.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, sgMain.Cells[ACol, ARow]);
  end;
end;

procedure TdlgCompareNSRecords.actShowOnlyDiffExecute(Sender: TObject);
var
  FieldsCount: Integer;
  FN: String;
begin
  FieldsCount := 0;
  Records.First;
  if cbShowOnlyDiff.Checked then
  begin
    while not Records.Eof do
    begin
      FN := Records.FieldByName('LR_FieldName').AsString;
      if AnsiCompareStr(Records.FieldByName('L_' + FN).AsString, Records.FieldByName('R_' + FN).AsString) <> 0 then
      begin
        sgMain.Cells[0, FieldsCount + 1] := FN;
        sgMain.Cells[1, FieldsCount + 1] := Records.FieldByName('L_' + FN).AsString;
        sgMain.Cells[2, FieldsCount + 1] := Records.FieldByName('R_' + FN).AsString;
        Inc(FieldsCount);
      end;
      Records.Next;
    end;

    if FieldsCount = 0 then
      sgMain.RowCount := 2
    else
      sgMain.RowCount := FieldsCount + 1;
  end else
  begin
    while not Records.Eof do
    begin
      FN := Records.FieldByName('LR_FieldName').AsString;
      sgMain.Cells[0, FieldsCount + 1] := FN;
      sgMain.Cells[1, FieldsCount + 1] := Records.FieldByName('L_' + FN).AsString; 
      sgMain.Cells[2, FieldsCount + 1] := Records.FieldByName('R_' + FN).AsString;
      Inc(FieldsCount);
      Records.Next;
    end;
    sgMain.RowCount := FieldsCount + 1;
  end;
  sgMain.Refresh;
end;

end.
