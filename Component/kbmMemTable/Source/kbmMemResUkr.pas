unit kbmMemResUkr;

interface

const
  kbmMasterlinkErr = 'Число master-полів не відповідає числу індексних полів.';
  kbmSelfRef = 'Неприпустимі відносини, що самопосилаються, master/detail.';
  kbmFindNearestErr = 'FindNearest нездійсненна для не відсортованих даних.';
  kbminternalOpen1Err = 'Визначення поля ';
  kbminternalOpen2Err = ' Тип даних %d не підтримується.)';
  kbmReadOnlyErr = 'Поле %s тільки для читання';
  kbmVarArrayErr = 'Масив даних variant має неприпустиму розмірність';
  kbmVarReason1Err = 'Полів більше, ніж даних';
  kbmVarReason2Err = 'Повинно бути принаймні одне поле';
  kbmBookmErr = 'Закладка %d не знайдена.';
  kbmUnknownFieldErr1 = 'Невідомий тип поля (%s)';
  kbmUnknownFieldErr2 = ' у файлі CSV (%s).';
  kbmIndexErr = 'Неприпустимий індекс для поля %s';
  kbmEditModeErr = 'Таблиця не в режимі редагування.';
  kbmDatasetRemoveLockedErr = 'Спроба видалити таблицю коли вона заблокована';
  kbmSetDatasetLockErr = 'Таблиця заблокована і не може бути змінена.';
  kbmOutOfBookmarks = 'Лічильник закладок поза припустимим діапазоном. Закрийте і знову відкрийте таблицю.';
  kbmIndexNotExist = 'Індекс %s не існує';
  kbmKeyFieldsChanged = 'Не можу виконати операцію через зміну індексних полів.';
  kbmDupIndex = 'Дублюється значення індексу. Операція перервана.';
  kbmMissingNames = 'Пропущено Name чи FieldNames у IndexDef!';
  kbmInvalidRecord = 'Некоректний запис ';
  kbmTransactionVersioning = 'Транзактування вимагає мультиверсійного версіонування.';
  kbmNoCurrentRecord = 'Немає поточного запису.';
  kbmCantAttachToSelf = 'Не можу підключити таблицу-в-пам''яті саму до себе.';
  kbmCantAttachToSelf2 = 'Не можу підключитися до іншої таблиці, що сама вже підключена.';
  kbmUnknownOperator = 'Невідомий оператор (%d)';
  kbmUnknownFieldType = 'Невідомий тип полючи (%d)';
  kbmOperatorNotSupported = 'Оператор не підтримується (%d).';
  kbmSavingDeltasBinary = 'Збереження дельт підтримується тільки в двоїчному форматі.';
  kbmCantCheckpointAttached = 'Неможливо зареєструватися в таблиці, до якої підключаємося.';
  kbmDeltaHandlerAssign = 'Оброблювач дельт не призначенийі ні однієї таблиці-в-пам''яті.';
  kbmOutOfRange = 'Поза діапазоном (%d)';
  kbmInvArgument = 'Некоректний аргумент.';
  kbmInvOptions = 'Некоректна опція.';

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
