unit wiz_Strings_unit;

interface
const
  ENG_BEGINDATE = 'BeginDate';
  ENG_ENDDATE = 'EndDate';
  ENG_ENTRYDATE = 'EntryDate';
  ISZERO = 'IsZero';

  RUS_BEGINDATE = 'Дата начала периода';
  RUS_ENDDATE = 'Дата окончания периода';
  RUS_ENTRYDATE = 'Дата проводки';

  ENG_GDCENTRY = 'gdcEntry';
  ENG_GDCDOCUMENT = 'gdcDocument';
  RUS_GDCENTRY = 'Бизнес объект проводки';
  RUS_GDCDOCUMENT = 'Бизнес объект документа';
  RUS_DONOTDELETE = 'Не удалять!';

  ENG_GDCTAXDESIGNDATE = 'gdcTaxDesignDate';
  ENG_GDCTAXRESULT = 'gdcTaxResult';

  RUS_ACCOUNT = 'Счёт...';
  RUS_INVALIDDOCUMENTTYPE = 'Выбран некорректный документ.';
  RUS_CURR = 'Валюта...';
  RUS_COMPANY = 'Компания...';
  RUS_EXPRESSION = 'Выражение...';

  cwHeader = 'шапка';
  cwLine   = 'позиция';

  AC_ACCOUNT = 'AC_ACCOUNT';
  AC_ENTRY = 'AC_ENTRY';
  GD_CURR = 'GD_CURR';
  AC_QUANTITY = 'AC_QUANTITY';
  AC_RECORD = 'AC_RECORD';

  RUS_INVALIDACCOUNT = 'Введено некорректное значение счета.';
  RUS_INVALIDTYPE = 'Тип функции не определен.';

  RUS_TRENTRY_ERROR1 = 'Необходимо добавить как минимум две позиции типовой проводки.';
  RUS_TRENTRY_ERROR2 =
    'Количество позиций типовой проводки с типом счета ''Дебет'' и '#13#10 +
    'количество позиций типовой проводки с типом счета ''Кредит'' не'#13#10 +
    'могут одновременно быть больше 1. Удалите лишние '#13#10 +
    'позиции типовой проводки или измените типы счетов.';
  RUS_TRENTRY_ERROR3 = 'Необходимо добавить позицию типовой проводки с типом счета ''Кредит''.';
  RUS_TRENTRY_ERROR4 = 'Необходимо добавить позицию типовой проводки с типом счета ''Дебет''.';
  RUS_TRENTRY_ERROR5 =
    'Количество позиций типовой проводки с одинаковыми счетами и'#13#10 +
    'одинаковыми типами счетов не может превышать 1. В следующих '#13#10 +
    'позициях типовой проводки указаны одинаковые счета и типы счетов:'#13#10+
    '%s';
  RUS_TRENTRY_DEBIT = '''Дебет''';
  RUS_TRENTRY_CREDIT = '''Кредит''';

  ENG_DEBITNCU = 'DebitNcu';
  ENG_CREDITNCU = 'CreditNcu';
  ENG_DEBITCURR = 'DebitCurr';
  ENG_CREDITCURR = 'CreditCurr';
  ENG_RECORDKEY = 'RecordKey';
  ENG_DEBITEQ = 'DebitEq';
  ENG_CREDITEQ= 'CreditEq';

  RUS_INVALID_VISUALBLOCK_NAME = 'Имя "%s" должно состоять из букв английского алфавита';
  RUS_NO_FOREIGN_KEY_ON_AC_QUANTITY =
    'В таблице AC_QUANTITY на поле VALUEKEY отсутствует '#13#10 +
    'внешняя ссылка на поле ID таблицы GD_VALUE.';

  RUS_SAVECHANGES = 'Функция была изменена. Сохранить изменения?';
  RUS_QUESTION  = 'Вопрос';

  MSG_INVALID_NAME = 'Введено некоректное наименование.';
  MSG_INVALID_EXPRESSION = 'Пожалуйста, введите условие.';
  MSG_INPUT_DEBIT_ACCOUNT = 'Пожалуйста, введите счет по дебету.';
  MSG_INPUT_CREDIT_ACCOUNT = 'Пожалуйста, введите счет по кредиту.';
  MSG_INPUT_SUM = 'Пожалуйста, укажите сумму проводки в НДЕ или'#13#10 +
    'сумму в валюте и валюту.';
  MSG_INPUT_ENTRYDATE = 'Пожалуйста, заполните поля "Начало периода", '#13#10 +
    '"Конец периода", "Дата проводки".';
  MSG_INPUT_EVAL = 'Пожалуйста, заполните поле "Выражение".';

  MSG_SQL_ERROR = 'SQL запрос содержит следущую ошибку:'#13#10'%s';
implementation

end.
