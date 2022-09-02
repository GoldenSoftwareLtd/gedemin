// ShlTanya, 20.02.2019

 {++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    rf_Control.pas

  Abstract

    Delphi visual component .
    Create visual control for viewing and editing of variable of field type.

  Author

    Dubrovnik Alexander    (15.05.2003)

  Revisions history

    1.0    DAlex    15.05.2003    Initial version.

--}

unit rf_Control;

interface

uses
  classes, controls, at_Classes, stdctrls;

type
  TrfControl = class(TWinControl)
  private
    FDesignEdit: TEdit;
    FControl: TWinControl;
    FOnChange: TNotifyEvent;
    function GetCurrentValue: String;
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure ChangeValue(Sender: TObject);

  protected
    procedure SetName(const Value: TComponentName); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure CreateControl(const atRelationField: TatRelationField;
      const InitialValue: String);
    property Control: TWinControl read FControl;
    property CurrentValue: String read GetCurrentValue;

  published
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
  end;

procedure Register;

implementation

uses
  gsIBLookupComboBox, at_SetComboBox, Spin, DB, xCalculatorEdit,
  gdcBaseInterface, IBDatabase, Sysutils;

type
  TCrackWinControl = class(TWinControl);

procedure Register;
begin
  RegisterComponents('Samples', [TrfControl]);
end;

{ TrfControl }

procedure TrfControl.ChangeValue(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Sender);
end;

constructor TrfControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if AOwner.InheritsFrom(TWinControl) then
    TWinControl(AOwner).InsertControl(Self);

  Width := 171;
  Height := 24;

  if csDesigning in ComponentState then
  begin
    FDesignEdit := TEdit.Create(Self);
    InsertControl(FDesignEdit);
    FDesignEdit.Align := alClient;
  end;

  FControl := nil;
end;

procedure TrfControl.CreateControl(const atRelationField: TatRelationField;
  const InitialValue: String);
var
  I: Integer;

  procedure InsertAndCorrectControl;
  begin
    //Устанавливаем корректные размеры
    I := Parent.Height - Top - TCrackWinControl(Parent).BevelWidth -
      TCrackWinControl(Parent).BorderWidth;
    if I > FControl.Height then
      Self.Height := FControl.Height
    else
      Self.Height := I;

    I := Parent.Width - Left - TCrackWinControl(Parent).BevelWidth -
      TCrackWinControl(Parent).BorderWidth;
    if FControl.Width > Self.Width then
    begin
      if I > FControl.Width then
        Self.Width := FControl.Width
      else
        Self.Width := I;
    end;
    //Вставляем контрол
    InsertControl(FControl);
    FControl.Align := alClient;
  end;
begin
  if FControl <> nil then
    FControl.Free;

  if Assigned(atRelationField.References) then
  begin
    FControl :=  TgsIBLookupComboBox.Create(Self);
    with TgsIBLookupComboBox(FControl) do
    begin
      OnChange := ChangeValue;
      Transaction := TIBTransaction.Create(FControl);
      InsertAndCorrectControl;
      Transaction.DefaultDatabase := gdcBaseManager.Database;

      ViewType  := vtByClass;
      SortOrder := soAsc;
      gdClassName := atRelationField.References.ListField.gdClassName;
      SubType     := atRelationField.References.ListField.gdSubType;
      KeyField    := atRelationField.References.PrimaryKey.ConstraintFields[0].FieldName;
      ListTable   := atRelationField.References.RelationName;
      ListField   := atRelationField.References.ListField.FieldName;
      try
        CurrentKeyInt := GetTID(InitialValue);
      except
      end;
    end;
  end else

  if Assigned(atRelationField.CrossRelation) then
  begin
//    FControl :=  TatSetLookupComboBox.Create(Self);
//    InsertAndCorrectControl
//    TatSetLookupComboBox.OnChange := ChangeValue;
  end else

  case atRelationField.Field.FieldType of
    ftBoolean:
    begin
      FControl := TCheckBox.Create(Self);
      InsertAndCorrectControl;
      TCheckBox(FControl).Caption := atRelationField.LName;
      TCheckBox(FControl).OnClick := ChangeValue;
      try
        TCheckBox(FControl).Checked := Boolean(StrToInt(InitialValue));
      except
      end;
//      I := TCheckBox(FControl).ca
    end;
    ftInteger:
    begin
      FControl := TSpinEdit.Create(Self);
      InsertAndCorrectControl;
      TSpinEdit(FControl).MaxValue := High(Integer);
      TSpinEdit(FControl).MinValue := Low(Integer);
      TSpinEdit(FControl).OnChange := ChangeValue;
      try
        TSpinEdit(FControl).Value := StrToInt(InitialValue);
      except
      end;
    end;
    ftSmallInt:
    begin
      FControl := TSpinEdit.Create(Self);
      InsertAndCorrectControl;
      TSpinEdit(FControl).MaxValue := High(Smallint);
      TSpinEdit(FControl).MinValue := Low(Smallint);
      TSpinEdit(FControl).OnChange := ChangeValue;
      try
        TSpinEdit(FControl).Value := StrToInt(InitialValue);
      except
      end;
    end;
    ftBCD:
    begin
      FControl := TxCalculatorEdit.Create(Self);
      InsertAndCorrectControl;
      TxCalculatorEdit(FControl).OnChange := ChangeValue;
      try
        TxCalculatorEdit(FControl).Value := StrToCurr(InitialValue);
      except
      end;
    end;
    ftFloat:
    begin
      FControl := TEdit.Create(Self);
      InsertAndCorrectControl;
      TEdit(FControl).OnChange := ChangeValue;
      TEdit(FControl).Text := InitialValue;
    end;
    ftString, ftWideString:
    begin
      FControl := TEdit.Create(Self);
      InsertAndCorrectControl;
      TEdit(FControl).OnChange := ChangeValue;
      TEdit(FControl).Text := InitialValue;
    end;
    ftMemo:
    begin
      FControl := TMemo.Create(Self);
      InsertAndCorrectControl;
      TMemo(FControl).OnChange := ChangeValue;
      TMemo(FControl).Text := InitialValue;
    end;
    ftBlob:
    begin
      case atRelationField.Field.SQLSubType of
        0, 1:
        begin
          FControl := TMemo.Create(Self);
          InsertAndCorrectControl;
          TMemo(FControl).OnChange := ChangeValue;
          TMemo(FControl).Text := InitialValue;
        end;
        2:
        begin
        end;
      end;
    end;
    ftLargeInt:
    begin
      FControl := TSpinEdit.Create(Self);
      InsertAndCorrectControl;
      TSpinEdit(FControl).OnChange := ChangeValue;
      try
        TSpinEdit(FControl).Value := StrToInt(InitialValue);
      except
      end;

//      TSpinEdit(FControl).MaxValue := High(Int64);
//      TSpinEdit(FControl).MinValue := Low(Int64);
    end;
  end;
end;

destructor TrfControl.Destroy;
begin
  inherited;

end;

function TrfControl.GetCurrentValue: String;
begin
  if FControl = nil then
  begin
    Result := '';
    Exit;
  end;

  if FControl.InheritsFrom(TgsIBLookupComboBox) then
    Result := TID2S(TgsIBLookupComboBox(FControl).CurrentKeyInt)
  else
  if FControl.InheritsFrom(TatSetLookupComboBox) then
//    Result := TatSetLookupComboBox(FControl).
  else
  if FControl.InheritsFrom(TCheckBox) then
    Result := IntToStr(Integer(TCheckBox(FControl).Checked))
  else
  if FControl.InheritsFrom(TxCalculatorEdit) then
    Result := TxCalculatorEdit(FControl).Text
  else
  if FControl.InheritsFrom(TEdit) then
    Result := TEdit(FControl).Text
  else
  if FControl.InheritsFrom(TMemo) then
    Result := TMemo(FControl).Text
  else
  if FControl.InheritsFrom(TSpinEdit) then
    Result := TSpinEdit(FControl).Text
  ;
end;

procedure TrfControl.SetName(const Value: TComponentName);
begin
  inherited;
  if (csDesigning in ComponentState) and (FDesignEdit <> nil) then
    FDesignEdit.Text := Value;
end;

procedure TrfControl.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

end.
