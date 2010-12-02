unit tr_TransactionType_unit;

interface

type
{ TODO 1 -oденис -cнедочет : Где префикс F }
  TCondition = class
    Value: String;
    TextValue: String;
    constructor Create(const aValue, aTextValue: String);
  end;

  TFieldCondition = class
    FieldName: String;
    FieldSource: String;
    ReferencyName: String;
    ReferencyField: String;
    constructor Create(const aFieldName, aFieldSource, aReferencyName,
      aReferencyField: String);
  end;

  TRelationCondition = class
    RelationName: String;
    ShortName: String;
    constructor Create(const aRelationName, aShortName: String);
  end;

implementation

{ TCondition }

constructor TCondition.Create(const aValue, aTextValue: String);
begin
  Value := aValue;
  TextValue := aTextValue;
end;

{ TFieldCondition }

constructor TFieldCondition.Create(const aFieldName, aFieldSource, aReferencyName,
  aReferencyField: String);
begin
  FieldName := aFieldName;
  FieldSource := aFieldSource;
  ReferencyName := aReferencyName;
  ReferencyField := aReferencyField;
end;

{ TRelationCondition }

constructor TRelationCondition.Create(const aRelationName,
  aShortName: String);
begin
  RelationName := aRelationName;
  ShortName := aShortName;
end;

end.
