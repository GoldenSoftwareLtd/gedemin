// ShlTanya, 09.03.2019

unit gdv_frAcctAnalyticLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Mask, xDateEdits, StdCtrls, at_classes, gsIBLookupComboBox, ActnList,
  Buttons, ExtCtrls, contnrs, gd_KeyAssoc, gdcBase;


type
  TAnalyticFieldType = (aftReference, aftString, aftDate, aftTime, aftDateTime);

  TfrAcctAnalyticLine = class(TFrame)
    lAnaliticName: TLabel;
    eAnalitic: TEdit;
    xdeDateTime: TxDateEdit;
    chkNull: TCheckBox;
    procedure chkNullClick(Sender: TObject); 

  private
    FField: TatRelationField;
    FOnValueChange: TNotifyEvent;
    FNeedNull: Boolean;
    FNeedSet: Boolean;
    FButtons, FLookUp: TObjectList;
    FKASet: TgdKeyArray;
    FActionList: TActionList;
    FactVisible: TAction;

    procedure BtnPress(Sender: TObject);
    procedure LookUpChange(Sender: TObject);
    function CreateLookUp: TgsIBLookupComboBox;
    function CreateButton: TSpeedButton;
    procedure SetField(const Value: TatRelationField);
    procedure Check;
    procedure SetValue(const Value: String);
    function GetValue: String;
    function FieldType: TAnalyticFieldType;
    procedure SetOnValueChange(const Value: TNotifyEvent);
    function GetIsNull: Boolean;
    procedure SetIsNull(const Value: Boolean);
    procedure SetNeedNull(const Value: Boolean);
    function GetDescription: String;
    procedure OnVisibleUpdate(Sender: TObject);

  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure ReSizeControls;
    procedure Clear;
    property Field: TatRelationField read FField write SetField;
    property Value: String read GetValue write SetValue;
    function IsEmpty: Boolean;
    property IsNull: Boolean read GetIsNull write SetIsNull;
    property OnValueChange: TNotifyEvent read FOnValueChange write SetOnValueChange;
    property NeedNull: Boolean read FNeedNull write SetNeedNull;
    property NeedSet: Boolean read FNeedSet write FNeedSet;
    property Description: String read GetDescription;
  end;

implementation

uses
  gdv_dlgSelectDocument_unit, dmDataBase_unit, gdcBaseInterface;

{$R *.DFM}

const
  FrameHeight = 22;
  ButtonHeight = 19;
  ButtonWidth = 18;

{ TfrAcctAnalyticLine }

constructor TfrAcctAnalyticLine.Create(AOwner: TComponent);
begin
  inherited;

  FButtons := TObjectList.Create;
  FLookUp := TObjectList.Create;
  Height := FrameHeight;
  FKASet := TgdKeyArray.Create;
  lAnaliticName.Enabled := False;
  ParentFont := False;

  if not (csDesigning in ComponentState) then
  begin
    FActionList := TActionList.Create(nil);
    FActionList.Name := 'al' + Self.Name;

    FactVisible := TAction.Create(FActionList);
    FactVisible.ActionList := FActionList;
    FactVisible.OnUpdate := OnVisibleUpdate;
    FactVisible.Caption := 'X';
  end else
  begin
    FActionList := nil;
    FactVisible := nil;
  end;
end;

destructor TfrAcctAnalyticLine.Destroy;
begin
  FLookUp.Free;
  FButtons.Free;
  FKASet.Free;
  FActionList.Free;

  inherited;  
end;

procedure TfrAcctAnalyticLine.OnVisibleUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (FButtons.Count > 1)
    or ((FButtons.Count = 1) and (FLookUp.Count = 1) and ((FLookUp[0] as TgsIBLookupComboBox).CurrentKey <> ''));
end;

procedure TfrAcctAnalyticLine.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
  inherited;
end;

procedure TfrAcctAnalyticLine.Check;
begin
  Assert(FField <> nil, '�� ��������� �������� ���� ���������'); 
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

function TfrAcctAnalyticLine.GetValue: String;
var
  lDateSeparator: char;
  lShortDateFormat: String;
  I: Integer;
begin
  Check;
  Result := '';
  //������ ������� � ������� YYYY-MM-DD � ���� �� ���������� ������������
  //��������� �� ���������, �� ������� �������������� ������ � ����� ������� ������
  //������� ����� ����������� ��������� ��� ��������� � ���������� �����
  lDateSeparator := DateSeparator;
  lShortDateFormat := ShortDateFormat;
  try
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-MM-dd';

    case FieldType of
      aftReference:
      begin
        FKASet.Clear;
        for I := 0 to FLookUp.Count - 1 do
          if (FLookUp[I] as TgsIBLookupComboBox).CurrentKey <> '' then
            FKASet.Add((FLookUp[I] as TgsIBLookupComboBox).CurrentKeyInt, True);
        Result := FKASet.CommaText;
      end;

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

function TfrAcctAnalyticLine.IsEmpty: Boolean;
begin
  Result := (Value = '') or (not chkNull.Checked and FNeedNull);
end;

procedure TfrAcctAnalyticLine.SetField(const Value: TatRelationField);
begin
  FField := Value;
  if FField <> nil then
  begin
    lAnaliticName.Caption := FField.LName;
    if FField.References <> nil then
    begin
      FLookUp.Add(CreateLookUp);
      FButtons.Add(CreateButton);
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
    ReSizeControls;
  end;
end;

procedure TfrAcctAnalyticLine.SetOnValueChange(const Value: TNotifyEvent);
begin
  FOnValueChange := Value;
  eAnalitic.OnChange := OnValueChange;
  xdeDateTime.OnChange := OnValueChange;
end;

procedure TfrAcctAnalyticLine.SetValue(const Value: String);

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
  
var
  I: Integer;
begin
  Check;

  if UpperCase(Value) = 'NULL' then
  begin
    chkNull.Checked:= True;
    Exit;
  end;

  lAnaliticName.Enabled :=  not FNeedNull;
  chkNull.Checked := (Value <> '') and FNeedNull; 

  case FieldType of
    aftReference:
    begin
      FKASet.CommaText := Value;
      if FKASet.Count > 0 then
      begin
        for I := 0 to FKASet.Count - 1 do
          (FLookUp[I] as TgsIBLookupComboBox).CurrentKeyInt := FKASet[I]; 
      end;
    end;
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

function TfrAcctAnalyticLine.GetIsNull: Boolean;
begin
  Result:= chkNull.Checked and (Value = '');
end;

procedure TfrAcctAnalyticLine.SetIsNull(const Value: Boolean);
begin
  chkNull.Checked:= not Value;
end;

procedure TfrAcctAnalyticLine.SetNeedNull(const Value: Boolean);
begin
  FNeedNull := Value;
  if not FNeedNull then
  begin
    lAnaliticName.Enabled := True;
    lAnaliticName.Left:= 2;
  end
  else
    lAnaliticName.Left:= 20;
  chkNull.Visible:= FNeedNull;
end;

procedure TfrAcctAnalyticLine.BtnPress(Sender: TObject);
var
  Index: Integer;
begin
  if FButtons.Count > 1 then
  begin
    Index := FButtons.IndexOf(Sender as TSpeedButton);
    if Index <> -1 then
    begin
      FLookUp.Delete(Index);
      FButtons.Delete(Index);
    end;
    ReSizeControls;
  end else
    if FButtons.Count = 1 then
      (FLookUp[0] as TgsIBLookupComboBox).CurrentKey := '';
end;

procedure TfrAcctAnalyticLine.LookUpChange(Sender: TObject);
var
  Index: Integer;
begin
  Index := FLookUp.IndexOf(Sender as TgsIBLookupComboBox);
  if (Index = FLookUp.Count - 1) and ((Sender as TgsIBLookupComboBox).CurrentKey <> '')
    and FNeedSet then
  begin
    FLookUp.Add(CreateLookUp);
    FButtons.Add(CreateButton);
    ReSizeControls;
  end;
  if Assigned(FOnValueChange) then FOnValueChange(Sender);
end;

procedure TfrAcctAnalyticLine.ReSizeControls;
var
  AllHeight, I, LH: Integer;
begin
  if FField <> nil then
  begin
    AllHeight := FrameHeight;
    case FieldType of
      aftReference:
      begin
        if (FLookUp.Count > 0) and (FButtons.Count > 0) then
        begin
          LH := (FLookUp[0] as TgsIBLookupComboBox).Height + 2;
          for I := 0 to FLookUp.Count - 1 do
          begin
            (FLookUp[I] as TgsIBLookupComboBox).Top := AllHeight;
            (FLookUp[I] as TgsIBLookupComboBox).Width := Self.ClientWidth - ButtonWidth - 2;
            (FButtons[I] as TSpeedButton).Top := AllHeight;
            (FButtons[I] as TSpeedButton).Left := Self.ClientWidth - ButtonWidth;
            AllHeight :=  AllHeight + LH;
          end;
        end;
      end;
      aftDate, aftTime, aftDateTime:
      begin
        xdeDateTime.Top := AllHeight;
        xdeDateTime.Width := ClientWidth - 2;
        xdeDateTime.Left := 2;
        AllHeight := AllHeight + xdeDateTime.Height;
      end;
      aftString:
      begin
        eAnalitic.Top := AllHeight;
        eAnalitic.Width := ClientWidth - 2;
        eAnalitic.Left := 2;
        AllHeight := AllHeight + eAnalitic.Height;
      end;
    end;
    if (chkNull.Checked) or (not FNeedNull) then
      Self.Height := AllHeight
    else
      Self.Height := FrameHeight;
  end;
end;

function TfrAcctAnalyticLine.CreateLookUp: TgsIBLookupComboBox;
var
  C: TPersistentClass;
  gdcClass: CgdcBase;
begin
  Result := TgsIBLookupComboBox.Create(Self);
  with Result do
  begin
    Parent := Self;
    ParentFont := False;
    ParentColor := False;
    Font.Name := 'Tahoma';
    Font.Size := 8;
    Font.Color := clWindowText;
    Style := csDropDown;
    Database := dmDatabase.ibdbGAdmin;
    Transaction := gdcBaseManager.ReadTransaction;
    SubType := FField.gdSubType;
    gdClassName := FField.gdClassName;
    ListTable := FField.References.RelationName;
    Fields := FField.References.ExtendedFields;
    if gdClassName <> '' then
    begin
      C := GetClass(gdClassName);
      if Assigned(C) and C.InheritsFrom(TgdcBase) then
      begin
        gdcClass := CgdcBase(C);
        ListTable := gdcClass.GetListTable(SubType);
        Condition := gdcClass.GetRestrictCondition(ListTable, SubType);
        Condition := StringReplace(Condition, gdcClass.GetListTableAlias + '.', ListTable + '.', [rfReplaceAll, rfIgnoreCase]);
      end;
    end;

    if  Condition = '' then
      Condition := FField.Field.RefCondition;

    if FField.Field.RefListFieldName <> '' then
       ListField := FField.Field.RefListFieldName
    else
      ListField := FField.References.ListField.FieldName;

    KeyField := FField.ReferencesField.FieldName;
    ParentShowHint := False;
    SortOrder := soAsc;
    Left := 2;
    Width := Self.ClientWidth - ButtonWidth - 2;
    Visible := True;
    OnChange := LookUpChange;
  end;
end;

function TfrAcctAnalyticLine.CreateButton: TSpeedButton;
begin
  Result := TSpeedButton.Create(Self);
  with Result do
  begin
    Parent := Self;
    //ParentFont := False;
    Caption := 'X';
    //Font.Style := [fsBold];
    Action := FactVisible;
    Visible := True;
    Height := ButtonHeight;
    Left := Self.ClientWidth - ButtonWidth;
    Width := ButtonWidth;
    OnClick := BtnPress;
  end;
end;

procedure TfrAcctAnalyticLine.chkNullClick(Sender: TObject);
begin
  lAnaliticName.Enabled := chkNull.Checked;
  ReSizeControls;
end;

procedure TfrAcctAnalyticLine.Clear;
begin
  if FField.References <> nil then
  begin
    FKASet.Clear;
    While FLookUp.Count > 1 do
    begin
      FLookUp.Delete(0);
      FButtons.Delete(0);
    end;

    if FLookUp.Count = 1 then
      (FLookUp[0] as TgsIBLookupComboBox).CurrentKey := '';
  end;

  SetValue('');
end; 

function TfrAcctAnalyticLine.GetDescription: String;
var
  I: Integer;
begin
  Result := '';

  case FieldType of
    aftReference:
    begin
      for I := 0 to FLookUp.Count - 1 do
      begin
        if chkNull.Checked
          and ((FLookUp[I] as TgsIBLookupComboBox).CurrentKey > '')
        then
          Result := Result + lAnaliticName.Caption + ' ' + (FLookUp[I] as TgsIBLookupComboBox).Text + '; ';
      end;
      if Result > '' then
        SetLength(Result, Length(Result) - 2);
    end;

    aftDate, aftTime, aftDateTime:
      if xdeDateTime.Text > '' then
        Result := lAnaliticName.Caption + ' ' + xdeDateTime.Text;

    aftString:
      if eAnalitic.Text > '' then
        Result := lAnaliticName.Caption + ' ' + eAnalitic.Text;
  end;
end;

end.
