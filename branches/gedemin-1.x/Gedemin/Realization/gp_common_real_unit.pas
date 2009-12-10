unit gp_common_real_unit;

interface

uses DB;

type
// Объект для хранения полей прайс-листа
  TPriceField = class
    FieldName: String; // Название поля
    ShortName: String; // Крактое наименование
    CurrKey: Integer;  // Код валюты
    constructor Create(const aFieldName, aShortName: String; const aCurrKey: Integer);
  end;

// Объект для хранения полей налогов
  TTaxField = class
    RelationName: String; // Наименование таблицы
    FieldName: String;    // Наименование пояя
    TaxKey: Integer;      // Код налога
    Expression: String;   // Формула расчета налога
    Rate: Currency;       // Ставка
    IsInclude: Boolean;   // Налог в цене или нет
    IsCurrency: Boolean;  // Налог валютный или нет
    Rounding: Currency;   // До какой суммы округлять
    constructor Create(const aRelationName, aFieldName, aExpression: String; const aTaxKey: Integer;
      const aisInclude, aIsCurrency: Boolean; const aRounding, aRate: Currency);
  end;

// Объект для хранения суммарных показателей по налогам
  TTaxAmountField = class
    RelationName: String; // Назавание таблицы
    FieldName: String;    // Название поля
    Amount: Currency;     // Сумма
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
