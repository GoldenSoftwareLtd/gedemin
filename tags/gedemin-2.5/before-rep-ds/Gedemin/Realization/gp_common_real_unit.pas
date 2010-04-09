unit gp_common_real_unit;

interface

uses DB;

type
// ������ ��� �������� ����� �����-�����
  TPriceField = class
    FieldName: String; // �������� ����
    ShortName: String; // ������� ������������
    CurrKey: Integer;  // ��� ������
    constructor Create(const aFieldName, aShortName: String; const aCurrKey: Integer);
  end;

// ������ ��� �������� ����� �������
  TTaxField = class
    RelationName: String; // ������������ �������
    FieldName: String;    // ������������ ����
    TaxKey: Integer;      // ��� ������
    Expression: String;   // ������� ������� ������
    Rate: Currency;       // ������
    IsInclude: Boolean;   // ����� � ���� ��� ���
    IsCurrency: Boolean;  // ����� �������� ��� ���
    Rounding: Currency;   // �� ����� ����� ���������
    constructor Create(const aRelationName, aFieldName, aExpression: String; const aTaxKey: Integer;
      const aisInclude, aIsCurrency: Boolean; const aRounding, aRate: Currency);
  end;

// ������ ��� �������� ��������� ����������� �� �������
  TTaxAmountField = class
    RelationName: String; // ��������� �������
    FieldName: String;    // �������� ����
    Amount: Currency;     // �����
    constructor Create(const aRelationName, aFieldName: String; const aAmount: Currency);
    procedure AddAmount(DataSet: TDataSet);
  end;

function RoundCurrency(const aValue, Rounding: Currency): Currency;  

implementation

{ TPriceField }

constructor TPriceField.Create(const aFieldName, aShortName: String; const aCurrKey: Integer);
begin
  FieldName := aFieldName;
  ShortName := aShortName;
  CurrKey := aCurrKey;
end;

{ TTaxField }

constructor TTaxField.Create(const aRelationName, aFieldName, aExpression: String; const aTaxKey: Integer;
      const aIsInclude, aIsCurrency: Boolean; const aRounding, aRate: Currency);
begin
  RelationName := aRelationName;
  FieldName := aFieldName;
  Expression := aExpression;
  TaxKey := aTaxKey;
  IsInclude := aIsInclude;
  IsCurrency := aIsCurrency;
  Rounding := aRounding;
  Rate := aRate;
end;

{ TTaxAmountField }

constructor TTaxAmountField.Create(const aRelationName, aFieldName: String; const aAmount: Currency);
begin
  RelationName := aRelationName;
  FieldName := aFieldName;
  Amount := aAmount;
end;

procedure TTaxAmountField.AddAmount(DataSet: TDataSet);
begin
  Amount := Amount + DataSet.FieldByName(FieldName).AsCurrency;
end;

function RoundCurrency(const aValue, Rounding: Currency): Currency;
begin
  Result := aValue;
end;

end.
