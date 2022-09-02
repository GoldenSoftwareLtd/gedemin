// ShlTanya, 20.02.2019

{*******************************************************}
{                                                       }
{       Borland Delphi Visual Component Library         }
{                                                       }
{       Copyright (c) 1997,99 Inprise Corporation       }
{                                                       }
{*******************************************************}

unit DbConsts;

interface

resourcestring
  SInvalidFieldSize = 'Invalid field size';
  SInvalidFieldKind = 'Invalid FieldKind';
  SInvalidFieldRegistration = 'Invalid field registration';
  SUnknownFieldType = 'Field ''%s'' is of an unknown type';
  SFieldNameMissing = 'Field name missing';
  SDuplicateFieldName = 'Duplicate field name ''%s''';
  SFieldNotFound = 'Поле ''%s'' не найдено!';//'Field ''%s'' not found';
  SFieldAccessError = 'Cannot access field ''%s'' as type %s';
  SFieldValueError = 'Некорректное значение для поля ''%s''';//'Invalid value for field ''%s''';
  SFieldRangeError = '%g is not a valid value for field ''%s''. The allowed range is %g to %g';
  SInvalidIntegerValue = '''%s'' is not a valid integer value for field ''%s''';
  SInvalidBoolValue = '''%s'' is not a valid boolean value for field ''%s''';
  SInvalidFloatValue = '''%s'' is not a valid floating point value for field ''%s''';
  SFieldTypeMismatch = 'Type mismatch for field ''%s'', expecting: %s actual: %s';
  SFieldSizeMismatch = 'Size mismatch for field ''%s'', expecting: %d actual: %d';
  SInvalidVarByteArray = 'Invalid variant type or size for field ''%s''';
  SFieldOutOfRange = 'Value of field ''%s'' is out of range';
  SBCDOverflow = '(Overflow)';
  SFieldRequired = 'Поле ''%s'' должно быть заполнено!';//'Field ''%s'' must have a value';
  SDataSetMissing = 'Field ''%s'' has no dataset';
  SInvalidCalcType = 'Field ''%s'' cannot be a calculated or lookup field';
  SFieldReadOnly = 'Field ''%s'' cannot be modified';
  SFieldIndexError = 'Field index out of range';
  SNoFieldIndexes = 'No index currently active';
  SNotIndexField = 'Field ''%s'' is not indexed and cannot be modified';
  SIndexFieldMissing = 'Cannot access index field ''%s''';
  SDuplicateIndexName = 'Duplicate index name ''%s''';
  SNoIndexForFields = 'No index for fields ''%s''';
  SIndexNotFound = 'Index ''%s'' not found';
  SDuplicateName = 'Дублирование наименований ''%s'' в %s!';//'Duplicate name ''%s'' in %s';
  SCircularDataLink = 'Circular datalinks are not allowed';
  SLookupInfoError = 'Lookup information for field ''%s'' is incomplete';
  SDataSourceChange = 'DataSource cannot be changed';
  SNoNestedMasterSource = 'Nested datasets cannot have a MasterSource';
  SDataSetOpen = 'Невозможно выполнить эту операцию на открытом наборе данных!'; //'Cannot perform this operation on an open dataset';
  SNotEditing = 'Набор данных не в режиме редактирования или вставки!'; //'Dataset not in edit or insert mode';
  SDataSetClosed = 'Невозможно выполнить эту операцию на закрытом наборе данных!';//'Cannot perform this operation on a closed dataset';
  SDataSetEmpty = 'Невозможно выполнить эту операцию на пустом наборе данных!';//'Cannot perform this operation on an empty dataset';
  SDataSetReadOnly = 'Нельзя модифицировать набор данных, открытый только для чтения!';//'Cannot modify a read-only dataset';
  SNestedDataSetClass = 'Nested dataset must inherit from %s';
  SExprTermination = 'Filter expression incorrectly terminated';
  SExprNameError = 'Unterminated field name';
  SExprStringError = 'Unterminated string constant';
  SExprInvalidChar = 'Invalid filter expression character: ''%s''';
  SExprNoLParen = '''('' expected but %s found';
  SExprNoRParen = ''')'' expected but %s found';
  SExprNoRParenOrComma = ''')'' or '','' expected but %s found';
  SExprExpected = 'Expression expected but %s found';
  SExprBadField = 'Field ''%s'' cannot be used in a filter expression';
  SExprBadNullTest = 'NULL only allowed with ''='' and ''<>''';
  SExprRangeError = 'Constant out of range';
  SExprNotBoolean = 'Field ''%s'' is not of type Boolean';
  SExprIncorrect = 'Incorrectly formed filter expression';
  SExprNothing = 'nothing';
  SExprTypeMis = 'Несовместимость типов в выражении!';//'Type mismatch in expression';
  SExprBadScope = 'Operation cannot mix aggregate value with record-varying value';
  SExprNoArith = 'Arithmetic in filter expressions not supported';
  SExprNotAgg = 'Expression is not an aggregate expression';
  SExprBadConst = 'Constant is not correct type %s';
  SExprNoAggFilter = 'Aggregate expressions not allowed in filters';
  SExprEmptyInList = 'IN predicate list may not be empty';
  SInvalidKeywordUse = 'Invalid use of keyword';
  STextFalse = 'Ложь';//'False';
  STextTrue = 'Истина';//'True';
  SParameterNotFound = 'Параметр ''%s'' не найден!';//'Parameter ''%s'' not found';
  SInvalidVersion = 'Unable to load bind parameters';
  SParamTooBig = 'Parameter ''%s'', cannot save data larger than %d bytes';
  SBadFieldType = 'Field ''%s'' is of an unsupported type';
  SAggActive = 'Property may not be modified while aggregate is active';
  SProviderSQLNotSupported = 'SQL not supported: %s';
  SProviderExecuteNotSupported = 'Execute not supported: %s';
  SExprNoAggOnCalcs = 'Field ''%s'' is not the correct type of calculated field to be used in an aggregate, use an internalcalc';
  SRecordChanged = 'Запись изменена другим пользователем!';//'Record changed by another user';

  { DBCtrls }
  SFirstRecord = 'Первая запись';//'First record';
  SPriorRecord = 'Предыдущая запись';//'Prior record';
  SNextRecord = 'Следующая запись';//'Next record';
  SLastRecord = 'Последняя запись';//'Last record';
  SInsertRecord = 'Вставить запись';//'Insert record';
  SDeleteRecord = 'Удалить запись';//'Delete record';
  SEditRecord = 'Редактировать запись';//'Edit record';
  SPostEdit = 'Сохранить запись'; //'Post edit';
  SCancelEdit = 'Cancel edit';
  SRefreshRecord = 'Refresh data';
  SDeleteRecordQuestion = 'Удалить запись?';//'Delete record?';
  SDeleteMultipleRecordsQuestion = 'Удалить все выделенные записи?';//'Delete all selected records?';
  SRecordNotFound = 'Запись не найдена!';//'Record not found';
  SDataSourceFixed = 'Operation not allowed in a DBCtrlGrid';
  SNotReplicatable = 'Control cannot be used in a DBCtrlGrid';
  SPropDefByLookup = 'Property already defined by lookup field';
  STooManyColumns = 'Grid requested to display more than 256 columns';

  { DBLogDlg }
  SRemoteLogin = 'Remote Login';

  { DBOleEdt }
  SDataBindings = 'Data Bindings...';

implementation

end.
