unit kbmMemResRus;

interface

const
  kbmMasterlinkErr = 'Число master-полей не соответствует числу индексных полей.';
  kbmSelfRef = 'Недопустимы самоссылающиеся отношения master/detail.';
  kbmFindNearestErr = 'FindNearest невыполнима для не отсортированных данных.';
  kbminternalOpen1Err = 'Определение поля ';
  kbminternalOpen2Err = ' Тип данных %d не поддерживается.)';
  kbmReadOnlyErr = 'Поле %s только для чтения';
  kbmVarArrayErr = 'Массив данных variant имеет недопустимую размерность';
  kbmVarReason1Err = 'Полей больше, чем данных';
  kbmVarReason2Err = 'Должно быть по крайней мере одно поле';
  kbmBookmErr = 'Закладка %d не найдена.';
  kbmUnknownFieldErr1 = 'Неизвестный тип поля (%s)';
  kbmUnknownFieldErr2 = ' в файле CSV (%s).';
  kbmIndexErr = 'Недопустимый индекс для поля %s';
  kbmEditModeErr = 'Таблица не в режиме редактирования.';
  kbmDatasetRemoveLockedErr = 'Попытка удалить таблицу, когда она заблокирована';
  kbmSetDatasetLockErr = 'Таблица заблокирована и не может быть изменена.';
  kbmOutOfBookmarks = 'Счетчик закладок вне допустимого диапазона. Закройте и снова откройте таблицу.';
  kbmIndexNotExist = 'Индекс %s не существует';
  kbmKeyFieldsChanged = 'Не могу выполнить операцию из-за изменения индексных полей.';
  kbmDupIndex = 'Дублирующееся значение индекса. Операция прервана.';
  kbmMissingNames = 'Пропущено Name или FieldNames в IndexDef!';
  kbmInvalidRecord = 'Некорректная запись ';
  kbmTransactionVersioning = 'Транзакционирование требует мультиверсийное версионирование.';
  kbmNoCurrentRecord = 'Нет текущей записи.';
  kbmCantAttachToSelf = 'Не могу подключить таблицу-в-памяти саму к себе.';
  kbmCantAttachToSelf2 = 'Не могу подключиться к другой таблице, которая сама уже подключена.';
  kbmUnknownOperator = 'Неизвестный оператор (%d)';
  kbmUnknownFieldType = 'Неизвестный тип поля (%d)';
  kbmOperatorNotSupported = 'Оператор не поддерживается (%d).';
  kbmSavingDeltasBinary = 'Сохранение дельт поддерживается только в двоичном формате.';
  kbmCantCheckpointAttached = 'Невозможно зарегистрироваться у таблицы, к которой подключаемся.';
  kbmDeltaHandlerAssign = 'Обработчик дельт не назначен ни одной таблице-в-памяти.';
  kbmOutOfRange = 'Вне диапазона (%d)';
  kbmInvArgument = 'Некорректный аргумент.';
  kbmInvOptions = 'Некорректная опция.';

  kbmTableMustBeClosed = 'Table must be closed for this operation.';
  kbmChildrenAttached = 'Children are attached to this table.';
  kbmIsAttached = 'Table is attached to another table.';
  kbmInvalidLocale = 'Invalid locale.';
  kbmInvFunction = 'Invalid function name %s';
  kbmInvMissParam = 'Invalid or missing parameter for function %s';
  kbmNoFormat = 'No format specified.';
  kbmTooManyFieldDefs = 'Too many fielddefs. Please raise KBM_MAX_FIELDS value.';
  kbmCannotMixAppendStructure = 'Cannot both append and copy structure.';

implementation


end.
