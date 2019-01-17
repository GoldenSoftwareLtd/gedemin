unit gdv_AvailAnalytics_unit;

interface

uses
  contnrs, at_classes, classes, AcctUtils, AcctStrings;
  
type
  TgdvAnalytics = class
  private
    FFieldName: string;
    FCaption: string;
    FField: TatRelationField;
    FListField: TatRelationField;
    FAdditional: string;
    FTotal: boolean;
    procedure SetCaption(const Value: string);
    procedure SetField(const Value: TatRelationField);
    procedure SetFieldName(const Value: string);
    procedure SetAdditional(const Value: string);
    procedure SetTotal(const Value: boolean);
    procedure SetListField(const Value: TatRelationField);
  public
    procedure SetListFieldByFieldName(const Value: string); overload;

    property FieldName: string read FFieldName write SetFieldName;
    property Caption: string read FCaption write SetCaption;
    property Field: TatRelationField read FField write SetField;
    property ListField: TatRelationField read FListField write SetListField;
    property Additional: string read FAdditional write SetAdditional;
    property Total: boolean read FTotal write SetTotal;
  end;

  TgdvAvailAnalytics = class(TObjectList)
  private
    function GetAnalytics(Index: Integer): TgdvAnalytics;
  public
    procedure Refresh; virtual;
    procedure AddAnalytics(FieldName, Caption: string; Field: TatRelationField;
      Additional: string);
    function IndexOfByFieldName(FieldName: string): Integer;

    property Analytics[Index: Integer]: TgdvAnalytics read GetAnalytics; default;
  end;

  TgdvAnalyticsList = class(TList)
  private
    function GetAnalytics(Index: Integer): TgdvAnalytics;
  public
    property Analytics[Index: Integer]: TgdvAnalytics read GetAnalytics; default;
  end;

implementation

{ TgdvAvailAnalytics }

procedure TgdvAvailAnalytics.AddAnalytics(FieldName, Caption: string;
  Field: TatRelationField; Additional: string);
var
  A: TgdvAnalytics;
begin
  A := TgdvAnalytics.Create;
  A.Field := Field;
  A.FieldName := FieldName;
  A.Caption := Caption;
  A.Additional := Additional;
  Add(A);
end;

function TgdvAvailAnalytics.GetAnalytics(Index: Integer): TgdvAnalytics;
begin
  Result := TgdvAnalytics(Items[Index]);
end;

function TgdvAvailAnalytics.IndexOfByFieldName(FieldName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if Analytics[I].FieldName = FieldName then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TgdvAvailAnalytics.Refresh;
var
  L: TList;
  A: TgdvAnalytics;
  I: Integer;
  F: TatRelationField;
begin
  Clear;
  L := TList.Create;
  try
    GetAnalyticsFields(L);
    for I := 0 to L.Count -1 do
    begin
      A := TgdvAnalytics.Create;
      A.Field := TatRelationField(L[I]);
      Add(A);
    end;
  finally
    L.Free;
  end;

  F := atDatabase.FindRelationField(AC_ENTRY, ENTRYDATE);
  if F <> nil then
  begin
    AddAnalytics(ENTRYDATE, 'Дата проводки', F, '') 
  end;

  AddAnalytics(MONTH, 'Месяц', nil, '1');
  AddAnalytics('QUARTER', 'Квартал', nil, '4');
  AddAnalytics('YEAR', 'Год', nil, '3');
  F := atDatabase.FindRelationField(AC_ENTRY, 'ACCOUNTKEY');
  if F <> nil then
  begin
    AddAnalytics('ACCOUNTKEY', 'Счета и субсчета', F, '')
  end;

  F := atDatabase.FindRelationField(AC_ENTRY, 'COMPANYKEY');
  if F <> nil then
  begin
    AddAnalytics('COMPANYKEY', 'Рабочая компания', F, '');
  end;
end;

{ TgdvAnalytics }

procedure TgdvAnalytics.SetAdditional(const Value: string);
begin
  FAdditional := Value;
end;

procedure TgdvAnalytics.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TgdvAnalytics.SetField(const Value: TatRelationField);
begin
  FField := Value;
  if Value <> nil then
  begin
    FFieldName := Value.FieldName;
    FCaption := Value.LName;
  end;
end;

procedure TgdvAnalytics.SetFieldName(const Value: string);
begin
  FFieldName := Value;
end;

procedure TgdvAnalytics.SetListFieldByFieldName(const Value: string);
begin
  if Assigned(FField) and (Value <> '') then
    ListField := FField.References.RelationFields.ByFieldName(Value)
  else
    ListField := nil;
end;

procedure TgdvAnalytics.SetListField(const Value: TatRelationField);
begin
  FListField := Value;
end;

procedure TgdvAnalytics.SetTotal(const Value: boolean);
begin
  FTotal := Value;
end;

{ TgdvAnalyticsList }

function TgdvAnalyticsList.GetAnalytics(Index: Integer): TgdvAnalytics;
begin
  Result := TgdvAnalytics(Items[Index]);
end;

end.
