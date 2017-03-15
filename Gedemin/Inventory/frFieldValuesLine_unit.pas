unit frFieldValuesLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Mask, xDateEdits, StdCtrls, at_classes, gsIBLookupComboBox, ActnList,
  Buttons, xCalculatorEdit, dmImages_unit, gdcBase, gd_KeyAssoc, gdcBaseInterface,
  gdc_dlgChooseSet_unit, gdvParamPanel, ibsql, menus;

type
  TFieldValueType = (fvtReference, fvtString, fvtDate, fvtTime, fvtDateTime, fvtDigits);

  CfrFieldValuesLine = class of TfrFieldValuesLine;

  TfrFieldValuesLine = class(TFrame)
    lblName: TLabel;
    edtValue: TEdit;
    cmbValue: TgsIBLookupComboBox;
    xdeStart: TxDateEdit;
    xceStart: TxCalculatorEdit;
    btnSelect: TSpeedButton;
    lbValue: TListBox;
    btnType: TSpeedButton;
    xceFinish: TxCalculatorEdit;
    xdeFinish: TxDateEdit;
    lbl: TLabel;
    procedure btnSelectClick(Sender: TObject);
    procedure btnTypeClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
    FField: TatRelationField;
    FOnValueChange: TNotifyEvent;
    FAlias: string;
    FIds: string;
    FConditionType: byte;
    FConditionForChooseSet: string;
    procedure SetField(const Value: TatRelationField);
    procedure Check;
    procedure SetOnValueChange(const Value: TNotifyEvent);
    procedure SetIDs(const Value: string);
    function GetIds: string;
    procedure SetConditionType(const Value: byte);
    function GetCondition: string;
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure SetValue(const Value: string); virtual;
    function GetValue: string; virtual;
  public
    function FieldType: TFieldValueType;
    procedure SetControlPosition(ALeft: Integer);
    property Field: TatRelationField read FField write SetField;
    property Value: string read GetValue write SetValue;
    function IsEmpty: boolean; virtual;
    property OnValueChange: TNotifyEvent read FOnValueChange write SetOnValueChange;
    property Alias: string read FAlias write FAlias;
    property IDs: string read GetIds write SetIDs;
    property Condition: string read GetCondition;
    property ConditionType: byte read FConditionType write SetConditionType default 0;
    procedure PopUpConditionMenu(Sender: TObject);
    procedure ClickConditionMenuItem(Sender: TObject);
    property ConditionForChooseSet: string read FConditionForChooseSet write FConditionForChooseSet;
  end;

implementation

uses frFieldVlues_unit, frFieldValuesLineConfig_unit, gdv_dlgSelectDocument_unit,
     gdcGood;

{$R *.DFM}

{ TfrFieldValuesLine }

procedure TfrFieldValuesLine.Check;
begin
  Assert(FField <> nil, 'Не присвоено значение поля');
end;

procedure TfrFieldValuesLine.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
  inherited;
end;

function TfrFieldValuesLine.FieldType: TFieldValueType;
begin
  Check;
  Result := fvtString;
  if FField.References <> nil then
    Result := fvtReference
  else
  if FField.Field.SQLType in [12, 13, 35] then begin
    case FField.Field.SQLType of
      12: Result := fvtdate;
      13: Result := fvtTime;
      35: Result := fvtDateTime;
    end;
  end
  else if FField.Field.SQLType in [11, 27, 10, 16, 8, 9, 7] then begin
    Result := fvtDigits;
  end;
end;

function TfrFieldValuesLine.GetValue: string;
var
  lDateSeparator: char;
  lShortDateFormat: string;
begin
  Check;
  Result := '';
  lDateSeparator := DateSeparator;
  lShortDateFormat := ShortDateFormat;
  try
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-MM-dd';
    case FieldType of
      fvtReference: begin
          if cmbValue.Visible then
            Result := cmbValue.CurrentKey
          else
            Result := FIds;
        end;
      fvtDate: begin
          if xdeStart.Date <> 0 then
            if FConditionType in [8, 9] then
              Result:= QuotedStr(DateToStr(xdeStart.Date)) + '|' + QuotedStr(DateToStr(xdeFinish.Date))
            else
              Result:= QuotedStr(DateToStr(xdeStart.Date));
        end;
      fvtTime: begin
          if xdeStart.Time <> 0 then
            if FConditionType in [8, 9] then
              Result:= QuotedStr(DateToStr(xdeStart.Time)) + '|' + QuotedStr(DateToStr(xdeFinish.Time))
            else
              Result:= QuotedStr(TimeToStr(xdeStart.Time));
        end;
      fvtDateTime: begin
          if xdeStart.DateTime <> 0 then
            if FConditionType in [8, 9] then
              Result:= QuotedStr(DateToStr(xdeStart.DateTime)) + '|' + QuotedStr(DateToStr(xdeFinish.DateTime))
            else
              Result:= QuotedStr(DateTimeToStr(xdeStart.DateTime));
        end;
      fvtDigits: begin
          if xceStart.Text <> '' then
            if FConditionType in [8, 9] then
              Result:= FloatToStr(xceStart.Value) + '|' + FloatToStr(xceFinish.Value)
            else
              Result:= FloatToStr(xceStart.Value);
        end;
      else
        if edtValue.Text > '' then
          Result := '''' + edtValue.Text + '''';
    end;
  finally
    Result:= '$' + IntToHex(ConditionType, 1) + Result;
    DateSeparator := lDateSeparator;
    ShortDateFormat := lShortDateFormat;
  end;
end;

function TfrFieldValuesLine.IsEmpty: boolean;
begin
  Result:= True;
  if ConditionType in [8, 9] then
    case FieldType of
      fvtDate: Result:= (xdeStart.Date = 0) and (xdeFinish.Date = 0);
      fvtTime: Result:= (xdeStart.Time = 0) and (xdeFinish.Time = 0);
      fvtDateTime: Result:= (xdeStart.DateTime = 0) and (xdeFinish.DateTime = 0);
      fvtDigits: Result:= (xceStart.Text = '') and (xceFinish.Text = '')
    end
  else
    Result:= (Length(Value) < 3) and not (ConditionType in [6, 7]);
end;

procedure TfrFieldValuesLine.SetField(const Value: TatRelationField);
begin
  FField := Value;
  if FField <> nil then begin
    lblName.Caption := FField.LName;// + ':';
    if FField.References <> nil then begin
      try
        cmbValue.SubType:= FField.gdSubType;
        if cmbValue.SubType <> '' then
          cmbValue.gdClassName := FField.gdClassName;
      except
      end;

      cmbValue.ListTable := FField.References.RelationName;
      if FField.Field.RefListFieldName <> '' then
        cmbValue.ListField := FField.Field.RefListFieldName
      else
        cmbValue.ListField := FField.References.ListField.FieldName;

      cmbValue.KeyField := FField.ReferencesField.FieldName;
      cmbValue.Visible := True;
      btnSelect.Visible:= True;

    end else begin
      if FField.Field.SQLType in [12, 13, 35] then begin
        xdeStart.Visible := True;
        case FField.Field.SQLType of
          12:begin
              xdeStart.Kind := kDate;
              xdeFinish.Kind := kDate;
            end;
          13:begin
              xdeStart.Kind := kTime;
              xdeFinish.Kind := kTime;
            end;
          35:begin
              xdeStart.Kind := kDateTime;
              xdeFinish.Kind := kDateTime;
            end;
        end;
      end
      else if FField.Field.SQLType in [11, 27, 10, 16, 8, 9, 7] then begin
        xceStart.Visible := True;
      end else
        edtValue.Visible := True;
    end;
    ConditionType:= 0;
  end;
end;

procedure TfrFieldValuesLine.SetOnValueChange(const Value: TNotifyEvent);
begin
  FOnValueChange:= Value;
  edtValue.OnChange:= OnValueChange;
  cmbValue.OnChange:= OnValueChange;
  xdeStart.OnChange:= OnValueChange;
  xdeFinish.OnChange:= OnValueChange;
  xceStart.OnChange:= OnValueChange;
  xceFinish.OnChange:= OnValueChange;
end;

procedure TfrFieldValuesLine.SetValue(const Value: string);
var
  Val: string;
  lDateSeparator: char;
  lShortDateFormat: string;
begin
  Check;
  try
  if Value > '' then begin
    ConditionType:= StrToInt(Copy(Value, 1, 2));
    Val:= Copy(Value, 3, Length(Value) - 2);
  end;
  lDateSeparator := DateSeparator;
  lShortDateFormat := ShortDateFormat;
  try
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-MM-dd';
    if (Val > '') and (Val[1] = '''') and (FieldType <> fvtString) then
      while Pos('''', Val) > 0 do
        Delete(Val, Pos('''', Val), 1);
  case FieldType of
    fvtReference: begin
      IDs:= Val;
      end;
    fvtDate: begin
        if Val > '' then begin
          if FConditionType in [8, 9] then begin
            xdeStart.Date:= StrToDate(Copy(Val, 1, Pos('|', Val) - 1));
            Delete(Val, 1, Pos('|', Val));
            xdeFinish.Date:= StrToDate(Val);
          end
          else
            xdeStart.Date:= StrToDate(Val);
        end
        else
          xdeStart.Text:= '';
      end;
    fvtTime: begin
        if Val > '' then begin
          if FConditionType in [8, 9] then begin
            xdeStart.Time:= StrToTime(Copy(Val, 1, Pos('|', Val) - 1));
            Delete(Val, 1, Pos('|', Val));
            xdeFinish.Time:= StrToTime(Val);
          end
          else
            xdeStart.Time:= StrToTime(Val);
        end
        else
          xdeStart.Text:= '';
      end;
    fvtDateTime: begin
        if Val > '' then begin
          if FConditionType in [8, 9] then begin
            xdeStart.DateTime:= StrToDateTime(Copy(Val, 1, Pos('|', Val) - 1));
            Delete(Val, 1, Pos('|', Val));
            xdeFinish.DateTime:= StrToDateTime(Val);
          end
          else
            xdeStart.DateTime:= StrToDateTime(Val);
        end
        else
          xdeStart.Text:= '';
      end;
    fvtDigits: begin
        if Val > '' then begin
          if FConditionType in [8, 9] then begin
            xceStart.Value:= StrToFloat(Copy(Val, 1, Pos('|', Val) - 1));
            Delete(Val, 1, Pos('|', Val));
            xceFinish.Value:= StrToFloat(Val);
          end
          else
            xceStart.Value:= StrToFloat(Val);
        end
        else
          xceStart.Text := '';
      end;
    else
      edtValue.Text := Val;
  end;
  finally
    DateSeparator := lDateSeparator;
    ShortDateFormat := lShortDateFormat;
  end;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TfrFieldValuesLine.SetControlPosition(ALeft: Integer);
var
  W: Integer;
begin
  if Align = alLeft then
    ALeft:= lblName.Left + lblName.Width + 5;

  btnType.Left:= ALeft;
  Inc(Aleft, btnType.Width);

  if FieldType = fvtReference then begin
    btnSelect.Left := ClientWidth - btnSelect.Width;
    W := ClientWidth - btnSelect.Width - ALeft;
  end
  else begin
    W:= ClientWidth - ALeft;
  end;

  lbValue.Left:= ALeft;
  lbValue.Width:= W;
  cmbValue.Left:= ALeft;
  cmbValue.Width:= W;
  edtValue.Left:= ALeft;
  edtValue.Width:= W;
  xdeStart.Left:= ALeft;
  xceStart.Left:= ALeft;
  if FConditionType in [8, 9] then begin
    xdeStart.Width:= (W - lbl.Width) div 2;
    xceStart.Width:= (W - lbl.Width) div 2;
    xdeFinish.Width:= W - lbl.Width - xdeStart.Width;
    xceFinish.Width:= W - lbl.Width - xdeStart.Width;
    xdeFinish.Left:= ALeft + xdeStart.Width + lbl.Width;
    xceFinish.Left:= ALeft + xceStart.Width + lbl.Width;
    lbl.Left:= ALeft + xdeStart.Width;
  end
  else begin
    xdeStart.Width:= W;
    xceStart.Width:= W;
  end;
end;

procedure TfrFieldValuesLine.btnSelectClick(Sender: TObject);
var
  frm: Tdlg_ChooseSet;
  F: TdlgSelectDocument;
  gdcGood: TgdcGood;
  V: OleVariant;
  I, J: Integer;
  SL: TStringList;
begin
  if Field.References.RelationName = 'GD_DOCUMENT' then begin
    F := TdlgSelectDocument.Create(nil);
    try
      F.ShowModal;
      if F.SelectedId > - 1 then
      begin
        IDs := IntToStr(F.SelectedId);
      end;
    finally
      F.Free;
    end;
  end
  else if Field.References.RelationName = 'GD_GOOD' then begin
    gdcGood := TgdcGood.Create(nil);
    try
      if IDs > '' then 
      begin
        SL := TStringList.Create;
        try
          SL.CommaText := IDs;
          for J := 0 to SL.Count - 1 do
            gdcGood.SelectedID.Add(StrToIntDef(SL[J], -1));
        finally
          SL.Free;
        end;
      end;

      if gdcGood.ChooseItems(V, 'gdcGood') then 
      begin
        SL := TStringList.Create;
        try
          for I := 0 to VarArrayHighBound(V, 1) do
            SL.Add(IntToStr(V[I]));
          IDs := SL.CommaText;
        finally
          SL.Free;
        end;
      end;
    finally
      gdcGood.Free;
    end;
  end
  else begin
    frm:= Tdlg_ChooseSet.Create(nil);
    try
      frm.ListTable:= Field.References.RelationName;
      frm.ListField:= Field.References.ListField.FieldName;
      frm.KeyField := Field.ReferencesField.FieldName;
      frm.Caption:= Field.LName + ': выбор значений';
      frm.CreateList(IDs);
      frm.ShowModal;
      if frm.ModalResult = mrOk then
        IDs:= frm.ChoosenIDs;
    finally
      frm.Free;
    end;
  end;
end;

procedure TfrFieldValuesLine.SetIDs(const Value: string);
var
  ibsql: TIBSQL;
  s: string;
begin
  FIds := Value;
  s := Value + ',';
  s := StringReplace(s, ' ', '', [rfReplaceAll]);
  cmbValue.Visible:= not (Pos(',', Value) > 0);
  lbValue.Visible:= Pos(',', Value) > 0;
  if Pos(',', Value) > 0 then begin
    lbValue.Items.Clear;
    ibsql:= TIBSQL.Create(nil);
    try
      ibsql.Transaction:= gdcBaseManager.ReadTransaction;
      ibsql.SQL.Text:=
        ' SELECT ' + Field.References.ListField.FieldName + ' AS name ' +
        ' FROM ' + Field.References.RelationName +
        ' WHERE ' + Field.ReferencesField.FieldName + ' = :id';
      while Pos(',', s) > 0 do begin
        ibsql.Close;
        ibsql.ParamByName('id').AsInteger:= StrToInt(Copy(s, 1, Pos(',', s) - 1));
        ibsql.ExecQuery;
        lbValue.Items.Add(ibsql.FieldByName('name').AsString);
        System.Delete(s, 1, Pos(',', s));
      end;
      if lbValue.Items.Count > 2 then begin
        lbValue.Height:= lbValue.ItemHeight * 3 + 4;
        Height:= lbValue.Height + 2;
      end
      else if lbValue.Items.Count = 2 then begin
        lbValue.Height:= lbValue.ItemHeight * 2 + 4;
        Height:= lbValue.Height + 2;
      end;
    finally
      ibsql.Free;
    end;
  end
  else begin
    Height:= 23;
    cmbValue.CurrentKey := Value;
  end;
  if self is TfrFieldValuesLineConfig then
    Height:= Height + 18;
  if Parent.Parent is TfrFieldValues then
    (Parent.Parent as TfrFieldValues).UpdateFrameHeight;
end;

function TfrFieldValuesLine.GetIds: string;
begin
  if cmbValue.Visible then
    FIDs:= cmbValue.CurrentKey;
  Result:= FIDs;
end;

procedure TfrFieldValuesLine.SetConditionType(const Value: byte);
var
  bmp: TBitmap;
begin
  FConditionType:= Value;
  xceFinish.Visible:= FConditionType in [8, 9];
  xdeFinish.Visible:= FConditionType in [8, 9];
  lbl.Visible:= FConditionType in [8, 9];
  SetControlPosition(lblNAme.Left + lblName.Width);
  bmp:= TBitmap.Create;
  try
    dmImages.ilConditionType.GetBitmap(FConditionType, bmp);
    btnType.Glyph.Assign(bmp);
  finally
    bmp.Free;
  end;
end;

function TfrFieldValuesLine.GetCondition: string;
var
  Val: string;
begin
  Result:= '';
  if IsEmpty then Exit;
  Val:= Copy(Value, 3, Length(Value) - 2);
  case ConditionType of
    0:begin
        if FieldType = fvtReference then
          Result:= ' IN (' + Val + ')'
        else
          Result:= ' = ' + Val;
      end;
    1:begin
        if FieldType = fvtReference then
          Result:= ' NOT IN (' + Val + ')'
        else
          Result:= ' <> ' + Val;
      end;
    2:begin
        if FieldType = fvtString then
          Result:= ' LIKE ' + QuotedStr(Val + '%')
        else
          Result:= ' < ' + Val;
      end;
    3:begin
        if FieldType = fvtString then
          Result:= ' LIKE ' + QuotedStr('%' + Val + '%')
        else
          Result:= ' <= ' + Val;
      end;
    4:begin
        if FieldType = fvtString then
          Result:= ' NOT LIKE ' + QuotedStr('%' + Val + '%')
        else
          Result:= ' > ' + Val;
      end;
    5:begin
        if FieldType = fvtString then
          Result:= ' LIKE ' + QuotedStr('%' + Val)
        else
          Result:= ' >= ' + Val;
      end;
    6:begin
        Result:= ' NOT IS NULL ';
      end;
    7:begin
        Result:= ' IS NULL ';
      end;
    8:begin
        Result:= ' BETWEEN ' + Copy(Val, 1, Pos('|', Val) - 1);
        Delete(Val, 1, Pos('|', Val));
        Result:= Result + ' AND ' + Val;
      end;
    9:begin
        Result:= ' NOT BETWEEN ' + Copy(Val, 1, Pos('|', Val) - 1);
        Delete(Val, 1, Pos('|', Val));
        Result:= Result + ' AND ' + Val;
      end;
  end;
end;

procedure TfrFieldValuesLine.btnTypeClick(Sender: TObject);
var
  i: integer;
  pm: TPopupMenu;
begin
  if not (Parent.Parent is TfrFieldValues) then
    Exit;
  pm:= (Parent.Parent as TfrFieldValues).pmCondition;
  pm.OnPopup:= PopUpConditionMenu;
  for i:= 0 to pm.Items.Count - 1 do
    pm.Items[i].OnClick:= ClickConditionMenuItem;
  pm.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TfrFieldValuesLine.PopUpConditionMenu(Sender: TObject);
begin
  case FieldType of
    fvtReference: begin
      (Sender as TPopupMenu).Items[0].Caption:= 'Один из';
      (Sender as TPopupMenu).Items[1].Caption:= 'Не включает';
      (Sender as TPopupMenu).Items[2].Visible:= False;
      (Sender as TPopupMenu).Items[3].Visible:= False;
      (Sender as TPopupMenu).Items[4].Visible:= False;
      (Sender as TPopupMenu).Items[5].Visible:= False;
      (Sender as TPopupMenu).Items[8].Visible:= False;
      (Sender as TPopupMenu).Items[9].Visible:= False;
    end;
    fvtDate, fvtTime, fvtDateTime, fvtDigits: begin
      (Sender as TPopupMenu).Items[0].Caption:= 'Равно';
      (Sender as TPopupMenu).Items[1].Caption:= 'Не равно';
      (Sender as TPopupMenu).Items[2].Caption:= 'Меньше';
      (Sender as TPopupMenu).Items[3].Caption:= 'Меньше или равно';
      (Sender as TPopupMenu).Items[4].Caption:= 'Больше';
      (Sender as TPopupMenu).Items[5].Caption:= 'Больше или равно';
      (Sender as TPopupMenu).Items[2].Visible:= True;
      (Sender as TPopupMenu).Items[3].Visible:= True;
      (Sender as TPopupMenu).Items[4].Visible:= True;
      (Sender as TPopupMenu).Items[5].Visible:= True;
      (Sender as TPopupMenu).Items[8].Visible:= True;
      (Sender as TPopupMenu).Items[9].Visible:= True;
    end;
  else
    (Sender as TPopupMenu).Items[0].Caption:= 'Равно';
    (Sender as TPopupMenu).Items[1].Caption:= 'Не равно';
    (Sender as TPopupMenu).Items[2].Caption:= 'Начинается с';
    (Sender as TPopupMenu).Items[3].Caption:= 'Содержит';
    (Sender as TPopupMenu).Items[4].Caption:= 'Не содержит';
    (Sender as TPopupMenu).Items[5].Caption:= 'Заканчивается на';
    (Sender as TPopupMenu).Items[2].Visible:= True;
    (Sender as TPopupMenu).Items[3].Visible:= True;
    (Sender as TPopupMenu).Items[4].Visible:= True;
    (Sender as TPopupMenu).Items[5].Visible:= True;
    (Sender as TPopupMenu).Items[8].Visible:= False;
    (Sender as TPopupMenu).Items[9].Visible:= False;
  end;
end;

procedure TfrFieldValuesLine.ClickConditionMenuItem(Sender: TObject);
begin
  ConditionType:= (Sender as TMenuItem).Tag;
  btnType.Hint:= (Sender as TMenuItem).Caption;
end;

procedure TfrFieldValuesLine.FrameResize(Sender: TObject);
begin
  if FConditionType in [8, 9] then
    SetControlPosition(lblNAme.Left + lblName.Width);
end;

initialization
  RegisterClass(TfrFieldValuesLine);

finalization
  UnRegisterClass(TfrFieldValuesLine);

end.
