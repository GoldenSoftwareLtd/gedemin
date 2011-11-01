unit at_dlgCompareRecords;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, gdcBase, DB, ActnList, ExtCtrls;

type
  TdlgCompareRecords = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    btnOK: TButton;
    Button1: TButton;
    Label1: TLabel;
    lblClassName: TLabel;
    Label2: TLabel;
    lblName: TLabel;
    Label3: TLabel;
    lblID: TLabel;
    Label4: TLabel;
    sgMain: TStringGrid;
    cbShowOnlyDiff: TCheckBox;
    ActionList1: TActionList;
    actShowOnlyDiff: TAction;
    actOK: TAction;
    actCancel: TAction;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgMainDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgMainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure actShowOnlyDiffExecute(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
    FSLFields: TStringList;
    FSLLocFields: TStringList;
    FSLBaseValues: TStringList;
    FSLStreamValues: TStringList;
    // false - в поле останетс€ значение существующей записи, true - значение загружаемой записи
    FIsNewValue: array of Boolean;
  public
    BaseRecord: TgdcBase;
    StreamRecord: TDataSet;
    ReplaceFieldList: TStringList;
  end;

var
  dlgCompareRecords: TdlgCompareRecords;

implementation

{$R *.DFM}

procedure TdlgCompareRecords.FormShow(Sender: TObject);
const
  PassFieldName = ';ID;EDITIONDATE;CREATIONDATE;CREATORKEY;EDITORKEY;ACHAG;AVIEW;AFULL;LB;RB;RESERVED;';
var
  I: Integer;
  FD: TFieldDef;
  DiffFieldsCount: Integer;
begin
  lblClassname.Caption := BaseRecord.GetDisplayName(BaseRecord.SubType);
  lblName.Caption := BaseRecord.FieldByName(BaseRecord.GetListField(BaseRecord.SubType)).AsString;
  lblID.Caption := IntToStr(BaseRecord.ID);

  FSLFields := TStringList.Create;
  FSLLocFields := TStringList.Create;
  FSLBaseValues := TStringList.Create;
  FSLStreamValues := TStringList.Create;

  for I := 0 to BaseRecord.FieldList.Count - 1 do
  begin
    FD := BaseRecord.FieldDefs[I];
    if Assigned(StreamRecord.FindField(FD.Name))
       and (not FD.InternalCalcField)
       and (AnsiPos(';' + AnsiUpperCase(Trim(FD.Name)) + ';', PassFieldName) = 0)
       and (BaseRecord.Fields[I].DataType <> ftBlob) then
    begin
      FSLFields.Add(BaseRecord.Fields[I].FieldName);
      FSLLocFields.Add(BaseRecord.Fields[I].DisplayLabel);
      // ≈сли строка у нас содержит только пробелы
      //  “о оставл€ем ее такую как есть
      //  ¬ обратном случае убираем ведущие и закрывающие пробелы
      if (Trim(BaseRecord.Fields[I].AsString) = '') and (BaseRecord.Fields[I].AsString > '') then
        FSLBaseValues.Add(BaseRecord.Fields[I].AsString)
      else
        FSLBaseValues.Add(Trim(BaseRecord.Fields[I].AsString));
      if (Trim(StreamRecord.FieldByName(BaseRecord.Fields[I].FieldName).AsString) = '')
         and (StreamRecord.FieldByName(BaseRecord.Fields[I].FieldName).AsString > '') then
        FSLStreamValues.Add(StreamRecord.FieldByName(BaseRecord.Fields[I].FieldName).AsString)
      else
        FSLStreamValues.Add(Trim(StreamRecord.FieldByName(BaseRecord.Fields[I].FieldName).AsString));
      //FSLBaseValues.Add(BaseRecord.Fields[I].AsString);
      //FSLStreamValues.Add(StreamRecord.FieldByName(BaseRecord.Fields[I].FieldName).AsString);
    end;
  end;

  sgMain.ColWidths[1] := Trunc((sgMain.Width - GetSystemMetrics(SM_CYHSCROLL)) / 2.8);
  sgMain.ColWidths[2] := sgMain.ColWidths[1];
  sgMain.ColWidths[0] := Trunc(sgMain.Width - sgMain.ColWidths[1] * 2 - GetSystemMetrics(SM_CYHSCROLL) * 1.5);
  sgMain.Cells[0, 0] := 'ѕоле';
  sgMain.Cells[1, 0] := 'ќбъект из базы';
  sgMain.Cells[2, 0] := '«агружаемый объект';

  // выведем только отличающиес€ пол€ записей
  DiffFieldsCount := 0;
  for I := 0 to FSLFields.Count - 1 do
  begin
    if AnsiCompareStr(FSLBaseValues.Strings[I], FSLStreamValues.Strings[I]) <> 0 then
    begin
      sgMain.Cells[0, DiffFieldsCount + 1] := FSLLocFields.Strings[I];
      sgMain.Cells[1, DiffFieldsCount + 1] := FSLBaseValues.Strings[I];
      sgMain.Cells[2, DiffFieldsCount + 1] := FSLStreamValues.Strings[I];
      Inc(DiffFieldsCount);
    end;
  end;

  if DiffFieldsCount = 0 then
    sgMain.RowCount := 2
  else
    sgMain.RowCount := DiffFieldsCount + 1;

  SetLength(FIsNewValue, FSLFields.Count);
  for I := 0 to FSLFields.Count - 1 do
    FIsNewValue[I] := True;
end;

procedure TdlgCompareRecords.FormDestroy(Sender: TObject);
begin
  SetLength(FIsNewValue, 0);
  if Assigned(FSLFields) then
    FSLFields.Free;
  if Assigned(FSLLocFields) then
    FSLLocFields.Free;
  if Assigned(FSLBaseValues) then
    FSLBaseValues.Free;
  if Assigned(FSLStreamValues) then
    FSLStreamValues.Free;
  ReplaceFieldList := nil;  
end;

procedure TdlgCompareRecords.sgMainDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  FieldNum: Integer;
begin
  if (State * [gdSelected, gdFocused]) <> [] then
  begin
    sgMain.Canvas.Brush.Color := clBtnFace;
    sgMain.Canvas.FillRect(Rect);
  end;

  if (ACol <> 0) and (ARow <> 0) then
  begin
    FieldNum := FSLLocFields.IndexOf(sgMain.Cells[0, ARow]);
    if ((ACol = 1) and FIsNewValue[FieldNum]) or ((ACol = 2) and not FIsNewValue[FieldNum]) then
      sgMain.Canvas.Font.Color := clGray
    else
      sgMain.Canvas.Font.Style := [fsBold];
    sgMain.Canvas.TextOut(Rect.Left + 2, Rect.Top + 2, sgMain.Cells[ACol, ARow]);
  end;
end;

procedure TdlgCompareRecords.sgMainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  FieldNum: Integer;
begin
  if (ssDouble in Shift) then
  begin
    // поищем номер пол€
    FieldNum := FSLLocFields.IndexOf(sgMain.Cells[0, sgMain.Row]);
    // если кликнули на текущей записи
    if sgMain.Col = 1 then
      FIsNewValue[FieldNum] := False
    else
      // если кликнули на загружаемой записи
      if sgMain.Col = 2 then
        FIsNewValue[FieldNum] := True;
    sgMain.Refresh;
  end;
end;

procedure TdlgCompareRecords.actShowOnlyDiffExecute(Sender: TObject);
var
  I, DiffFieldsCount: Integer;
begin
  if cbShowOnlyDiff.Checked then
  begin
    // выведем только отличающиес€ пол€ записей
    DiffFieldsCount := 0;
    for I := 0 to FSLFields.Count - 1 do
    begin
      if AnsiCompareStr(FSLBaseValues.Strings[I], FSLStreamValues.Strings[I]) <> 0 then
      begin
        sgMain.Cells[0, DiffFieldsCount + 1] := FSLLocFields.Strings[I]{FSLFields.Strings[I]};
        sgMain.Cells[1, DiffFieldsCount + 1] := FSLBaseValues.Strings[I];
        sgMain.Cells[2, DiffFieldsCount + 1] := FSLStreamValues.Strings[I];
        Inc(DiffFieldsCount);
      end;
    end;
    sgMain.RowCount := DiffFieldsCount + 1;
  end
  else
  begin
    // выведем все пол€
    for I := 0 to FSLFields.Count - 1 do
    begin
      sgMain.Cells[0, I + 1] := FSLLocFields.Strings[I]{FSLFields.Strings[I]};
      sgMain.Cells[1, I + 1] := FSLBaseValues.Strings[I];
      sgMain.Cells[2, I + 1] := FSLStreamValues.Strings[I];
    end;
    sgMain.RowCount := FSLFields.Count + 1;
  end;
  sgMain.Refresh;
end;

procedure TdlgCompareRecords.actOKExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to FSLFields.Count - 1 do
    if not FIsNewValue[I] then
      ReplaceFieldList.Add(FSLFields.Strings[I]);

  Self.Close;
  Self.ModalResult := mrOK;
end;

procedure TdlgCompareRecords.actCancelExecute(Sender: TObject);
begin
  Self.Close;
  Self.ModalResult := mrCancel;
end;

end.
