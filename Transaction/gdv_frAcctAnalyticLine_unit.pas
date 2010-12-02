unit gdv_frAcctAnalyticLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Mask, xDateEdits, StdCtrls, at_classes, gsIBLookupComboBox, ActnList,
  Buttons, ExtCtrls;


type
  TAnalyticFieldType = (aftReference, aftString, aftDate, aftTime, aftDateTime);

  TfrAcctAnalyticLine = class(TFrame)
    lAnaliticName: TLabel;
    eAnalitic: TEdit;
    cbAnalitic: TgsIBLookupComboBox;
    xdeDateTime: TxDateEdit;
    spSelectDocument: TSpeedButton;
    chkNull: TCheckBox;
    procedure actSelectDocumentUpdate(Sender: TObject);
    procedure actSelectDocumentExecute(Sender: TObject);
  private
    FField: TatRelationField;
    FOnValueChange: TNotifyEvent;
    FNeedNull: boolean;
    { Private declarations }
    procedure SetField(const Value: TatRelationField);
    procedure Check;
    procedure SetValue(const Value: string);
    function GetValue: string;
    function FieldType: TAnalyticFieldType;
    procedure SetOnValueChange(const Value: TNotifyEvent);
    function GetIsNull: boolean;
    procedure SetIsNull(const Value: boolean);
    procedure SetNeedNull(const Value: boolean);

  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;

  public
    { Public declarations }
    procedure SetControlPosition(ALeft: Integer);
    property Field: TatRelationField read FField write SetField;
    property Value: string read GetValue write SetValue;
    function IsEmpty: boolean;
    property IsNull: boolean read GetIsNull write SetIsNull;
    property OnValueChange: TNotifyEvent read FOnValueChange write SetOnValueChange;
    property NeedNull: boolean read FNeedNull write SetNeedNull;
  end;

implementation
uses gdv_dlgSelectDocument_unit;
{$R *.DFM}

{ TfrAcctAnalyticLine }

procedure TfrAcctAnalyticLine.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
  inherited;
{  lAnaliticName.Left := 5;
  cbAnalitic.Left := lAnaliticName.Left + lAnaliticName.Width + 3;
  eAnalitic.Left := cbAnalitic.Left;
  xdeDateTime.Left := cbAnalitic.Left;
  cbAnalitic.Width := Width - cbAnalitic.Left - 5;
  eAnalitic.Width := Width - eAnalitic.Left - 5;
  xdeDateTime.Width := Width - xdeDateTime.Left - 5;}
end;

procedure TfrAcctAnalyticLine.Check;
begin
  Assert(FField <> nil, 'не присвоено значение поля аналитики');

end;

function TfrAcctAnalyticLine.FieldType: TAnalyticFieldType;
begin
  Check;
  if FField.References <> nil then
    Result := aftReference
  else
  if FField.Field.SQLType in [12, 13, 35] then
  begin
    case FField.Field.SQLType of
      12: Result := aftdate;
      13: Result := aftTime;
      35: Result := aftDateTime;
    else
      Result := aftString;
    end;
  end else
    Result := aftString;
end;

function TfrAcctAnalyticLine.GetValue: string;
var
  lDateSeparator: char;
  lShortDateFormat: string;
begin
  Check;
  Result := '';
  //всегда попадет в формате YYYY-MM-DD и если на компьюторе региональные
  //установки не совпадают, то функции преобразования строки в число выдадут ошибку
  //Поэтому перед репликацией сохраняем рег установки и записываем новые
  lDateSeparator := DateSeparator;
  lShortDateFormat := ShortDateFormat;
  try
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-MM-dd';
    case FieldType of
      aftReference: Result := cbAnalitic.CurrentKey;
      aftDate:
      begin
        if xdeDateTime.Date <> 0 then
          Result := '''' + DateToStr(xdeDateTime.Date) + '''';
      end;
      aftTime:
      begin
        if xdeDateTime.Time <> 0 then
          Result := '''' + TimeToStr(xdeDateTime.Time) + '''';
      end;
      aftDateTime:
      begin
        if xdeDateTime.DateTime <> 0 then
          Result :=  '''' + DateTimeToStr(xdeDateTime.DateTime) + '''';
      end;
    else
      if eAnalitic.Text > '' then
        Result := '''' + eAnalitic.Text + '''';
    end;
  finally
    DateSeparator := lDateSeparator;
    ShortDateFormat := lShortDateFormat;
  end;
end;

function TfrAcctAnalyticLine.IsEmpty: boolean;
begin
  Result := Value = '';
end;

procedure TfrAcctAnalyticLine.SetField(const Value: TatRelationField);
begin
  FField := Value;
  if FField <> nil then
  begin
    lAnaliticName.Caption := FField.LName + ':';
    if FField.References <> nil then
    begin
      cbAnalitic.SubType := FField.gdSubType;
      cbAnalitic.gdClassName := FField.gdClassName;
    
      cbAnalitic.ListTable := FField.References.RelationName;
      if FField.Field.RefListFieldName <> '' then
        cbAnalitic.ListField := FField.Field.RefListFieldName
      else
        cbAnalitic.ListField := FField.References.ListField.FieldName;

      cbAnalitic.KeyField := FField.ReferencesField.FieldName;
      cbAnalitic.Visible := True;

      {cbAnalitic.Condition := 'EXISTS (SELECT * FROM ac_entry e WHERE e.' +
        Value.FieldName + ' = ' +
        Value.Field.RefTable.RelationName + '.' +
        Value.Field.RefTable.PrimaryKey.ConstraintFields[0].FieldName + ')';}
    end else
    begin
      if FField.Field.SQLType in [12, 13, 35] then
      begin
        xdeDateTime.Visible := True;
        case FField.Field.SQLType of
          12: xdeDateTime.Kind := kDate;
          13: xdeDateTime.Kind := kTime;
          35: xdeDateTime.Kind := kDateTime;
        end;
      end else
        eAnalitic.Visible := True;
    end;
  end;
end;

procedure TfrAcctAnalyticLine.SetOnValueChange(const Value: TNotifyEvent);
begin
  FOnValueChange := Value;
  eAnalitic.OnChange := OnValueChange;
  cbAnalitic.OnChange := OnValueChange;
  xdeDateTime.OnChange := OnValueChange;
end;

procedure TfrAcctAnalyticLine.SetValue(const Value: string);

function ConvertStrToDate(const strDate: String): TDateTime;
var
  Day, Month, Year: Word;
  strTmp: String;
begin
  if Pos('-', strDate) > 0 then
  begin
    Year := StrToInt(copy(strDate, 1, Pos('-', strDate) - 1));
    strTmp := copy(strDate, Pos('-', strDate) + 1, 255);
    Month := StrToInt(copy(strTmp, 1, Pos('-', strTmp) - 1));
    Day := StrToInt(copy(strTmp, Pos('-', strTmp) + 1, 255));
    Result := EncodeDate(Year, Month, Day);
  end
  else
    Result := StrToDate(strDate);
end;

begin
  Check;
  if Value = 'NULL' then begin
    chkNull.Checked:= True;
    Exit;
  end;
  case FieldType of
    aftReference: cbAnalitic.CurrentKey := Value;
    aftDate:
    begin
      if Value > '' then
        xdeDateTime.Date := ConvertStrToDate(Value)
      else
        xdeDateTime.Text := '';
    end;
    aftTime:
    begin
      if Value > '' then
        xdeDateTime.Time := StrToTime(Value)
      else
        xdeDateTime.Text := '';
    end;
    aftDateTime:
    begin
      if Value > '' then
        xdeDateTime.DateTime := StrToDateTime(Value)
      else
        xdeDateTime.Text := '';
    end;
  else
    eAnalitic.Text := Value;
  end;
end;

procedure TfrAcctAnalyticLine.actSelectDocumentUpdate(Sender: TObject);
begin
  TAction(Sender).Visible := (cbAnalitic <> nil) and (UpperCase(cbAnalitic.ListTable) = 'GD_DOCUMENT');
end;

procedure TfrAcctAnalyticLine.actSelectDocumentExecute(Sender: TObject);
var
  F: TdlgSelectDocument;
begin
  F := TdlgSelectDocument.Create(nil);
  try
    F.ShowModal;
    if F.SelectedId > - 1 then
    begin
      cbAnalitic.CurrentKeyInt := F.SelectedId;
    end;
  finally
    F.Free;
  end;
end;

procedure TfrAcctAnalyticLine.SetControlPosition(ALeft: Integer);
var
  W: Integer;
begin
  if (cbAnalitic = nil) or ((cbAnalitic <> nil) and (UpperCase(cbAnalitic.ListTable) <> 'GD_DOCUMENT')) then
  begin
    W := ClientWidth - 2 - ALeft;
    spSelectDocument.Visible := False;
  end else
  begin
    spSelectDocument.Left := ClientWidth - spSelectDocument.Width;
    W := spSelectDocument.Left - 2 - ALeft;
    spSelectDocument.Visible := True;
  end;

  ALeft:= ALeft;
  cbAnalitic.Left := ALeft;
  cbAnalitic.Width := W;
  eAnalitic.Left := ALeft;
  eAnalitic.Width := W;
  xdeDateTime.Left := ALeft;
  xdeDateTime.Width := W;
end;

function TfrAcctAnalyticLine.GetIsNull: boolean;
begin
  Result:= chkNull.Checked and (Value = '');
end;

procedure TfrAcctAnalyticLine.SetIsNull(const Value: boolean);
begin
  chkNull.Checked:= not Value;
end;

procedure TfrAcctAnalyticLine.SetNeedNull(const Value: boolean);
begin
  FNeedNull := Value;
  if not FNeedNull then begin
    lAnaliticName.Left:= 8;
  end
  else
    lAnaliticName.Left:= 16;
  chkNull.Visible:= FNeedNull;
end;

end.
