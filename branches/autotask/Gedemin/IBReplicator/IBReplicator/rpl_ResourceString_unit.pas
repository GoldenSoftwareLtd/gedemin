unit rpl_ResourceString_unit;

interface
resourcestring
  //Снизу добавлять по английски
  {$IFNDEF RP_ENG}
    InvalidDataBaseName = 'Неверное имя файла базы данныз ''%s''';
    ReplicationSchemaNotFound =  'База данных не подготовлена к репликации';
    DataBaseIsNotConnected = 'База данных не подключена';
    DataBaseTestConnectSucces = 'Успешное подключение';
    InvalidDataBaseKey = //'Неверный ключ базы данных';
        'Обработка данных из этого файла невозможна (неверный ключ репликации).'#13#10 +
        #13#10 +
        'Наиболее вероятные причины :'#13#10 +
        #13#10 +
        '1. Вы перепутали входной файл базы данных ("Источника") с выходным файлом Вашей базы данных ("Приемника").'#13#10 +
        '2. Вы получили файл предназначенный для обмена данными  не с Вашей базой данных (при наличии в схеме обмена данными больше двух участников).'#13#10 +
        '3. Была изменена схема обмена данными. Свяжитесь с администратором обмена данными.';

    DataBaseNotAssigned = 'База данных не присвоена';
    InvalidFieldIndex = 'Неверный индекс поля';
    InvalidParamIndex = 'Неверный индекс параметра';
    RelationNotAssigned = 'Таблица не присвоена';
    InvalidRelationKey = 'Ошибочный ключ таблицы';
    InvalidProtocol = 'Несуществующий протокол';
    InvalidFieldName = 'Неправильное имя поля';
    InvalidRelationName = 'Неправильное имя таблицы ''%s''';
    CantReturnBlobValue = 'Невозможно вернуть значение поля типа BLOB';
    CantSaveRigistryInfo = 'Невозможно сохранить информацию о регистрации';
    CantLoadRegistryInfo = 'Невозможно загрузить информацию о регистрации';
    InvalidStreamData = 'Поток содержит ошибочные данные';
    InvalidSchema = //'Ошибочная схема репликации';
        'Обработка данных из этого файла невозможна (неверный ключ репликации).'#13#10 +
        #13#10 +
        'Наиболее вероятные причины :'#13#10 +
        #13#10 +
        '1. Вы перепутали входной файл базы данных ("Источника") с выходным файлом Вашей базы данных ("Приемника").'#13#10 +
        '2. Вы получили файл предназначенный для обмена данными  не с Вашей базой данных (при наличии в схеме обмена данными больше двух участников).'#13#10 +
        '3. Была изменена схема обмена данными. Свяжитесь с администратором обмена данными.';
    InvalidStreamversion = 'Ошибочная версия потока';
    MissingFiles = 'Пропущено %d файлов реплики';
    OneNotConfirmedTransaction = //'В базе данных имеется одна не подтвержденная передача данных.';
      'Обработка данных из этого файла невозможна (не подтвержденная передача данных).'#13#10 +
      #13#10 +
      'Наиболее вероятные причины :'#13#10 +
      #13#10 +
      '1. Вы пытаетесь принять файл который сформирован на базе данных ("Источнике") ' +
      'без обработки Вашего файла отправленного Вами на "Источник" ранее. ' +
      'Свяжитесь с администратором обмена данными. ' +
      'Скорей всего, по согласованию с администратором обмена данными для завершения цикла последовательного обмена Вам необходимо будет :'#13#10 +
      '	1) произвести отмену передачи данных;'#13#10 +
      '	2) обработать принятый с "Источника" файл;'#13#10 +
      '	3) сформировать новый файл обмена и передать его на "Источник"'#13#10 +
      '2. В процессе приема-передачи произошла потеря файла обмена данными. Нарушилось условие последовательности обмена. Для координации действий свяжитесь с администратором обмена данными.';

    ManyNotConfirmedTransaction = //'В базе данных %d не подтвержденных передач данных.';
      'Обработка данных из этого файла невозможна (%d не подтвержденных передач данных).'#13#10 +
      #13#10 +
      'Наиболее вероятные причины :'#13#10 +
      #13#10 +
      '1. Вы пытаетесь принять файл который сформирован на базе данных ("Источнике") без обработки ' +
      'Вашего файла отправленного Вами на "Источник" ранее. Свяжитесь с администратором обмена данными. ' +
      'Скорей всего, по согласованию с администратором обмена данными для завершения цикла последовательного обмена Вам необходимо будет :'#13#10 +
      '	1) произвести отмену передачи данных;'#13#10 +
      '	2) обработать принятый с "Источника" файл;'#13#10 +
      '	3) сформировать новый файл обмена и передать его на "Источник"'#13#10 +
      '2. В процессе приема-передачи произошла потеря файла обмена данными. Нарушилось условие последовательности обмена. Для координации действий свяжитесь с администратором обмена данными.';

    FieldNotFound = 'Поле "%s" не найдено в таблице "%s"'; //???
    SeqnoNotFound = 'Seqno not found'; //????
    Question_On_Delete_Base =
      'Вы действительно хотите удалить выбранную базу из'#13#10 +
      'схемы репликации?';
    QuestionBackupDatabase =
      'Хотите сделать архивную копиию базы данных?';

    AlreadyReplicated = //'Файл уже среплецирован';
      'Обработка данных из этого файла невозможна (файл уже среплецирован).'#13#10 +
      #13#10 +
      'Наиболее вероятные причины :'#13#10 +
      #13#10 +
      '1. Вы пытаетесь принять файл который был уже ранее Вами обработан.';

    EnterServerName = 'Введите имя сервера';
    EnterProtocol = 'Выберите протокол';
    EnterDataBaseFileName = 'Введите имя базы данных';
    EnterUserName = 'Введите имя пользователя';
    EnterPassword = 'Введите пароль';
    EnterCharset = 'Введите кодировку';
    ConnectionError = 'Ошибка соединения с базой данных';
    ConnectionTest = 'Тестовое подключение';

    BeginExport = 'Начат процесс передачи данных...';
    BeginExportConfirm = 'Создание файла подтверждения...';
    PrepareLog = 'Подготовка журнала изменений';
    PrepareGDRUID = 'Подготовка таблицы GD_RUID';
    DeletedFromGDRUID = 'Из таблицы GD_RUID удалено %d записей';
    PreparedForExport = 'Подготовлено %d записей для передачи';
    NRecordPassed = 'Переданно %d записей';
    ReplicationStarting = 'Начат процесс репликации ...';

    CountChanges = '%d изменений в базе данных';
    FileExists =  'файл "%s" уже существует.'#13#10 +
            'вы хотите его переписать?';

    OpenDBFilter = 'Базы данных|*.gdb;*.fdb|Все файлы|*.*';
    ReplFileFilter = 'Файлы реплики|*.rpl|Все файлы|*.*';
    SQLFileFilter = 'SQL-скрипт|*.sql|Текстовые файлы|*.txt|All files|*.*';
    ReplSchemaFileFilter = 'Файлы схем реплики|*.rpd|Все файлы|*.*';
    ReplTriggersFileFilter = 'Текстовые файлы|*.txt|Все файлы|*.*';
    NotEnoughDiskSpace =
      'На диске недостаточно свободного места.'#13#10 +
       'Введите другой путь.';
    DoYouWantExstractDBFromRepl = 'Вы действительно хотите удалить %s из схемы репликации?';
    CannotDetermineFilePath = 'Can`t determine path to source data base.';//????
    TerminatedByUser = 'Прервано пользователем';//????
    EnterReplicationFileName = 'Введите имя файла реплики';
    EnterDBName = 'Введите имя базы данных';

    ServerList = '\ServerList';

    DropTriggers = 'Удаление триггеров';
    DropTriggersMainDB = 'Удаление триггеров из главной базы данных';
    DropOldTriggers = 'Удаление старых триггеров';
    CreateTriggers = 'Создание триггеров';

    DropTables = 'Удаление таблиц';
    DropOldTables = 'Удаление старых таблиц';
    CreateTables = 'Создание таблиц';

    DropDomanes = 'Удаление доменов';
    DropOldDomanes = 'Удаление старых доменов';
    CreateDomanes = 'Создание доменов';

    DropGenerators = 'Удаление генераторов';
    DropOldGenerators = 'Удаление старых генераторов';
    CreateGenerators = 'Создание генераторов';

    CreateRuid = 'Создание РУИДов для существующих записей';

    MakeCopy = 'Создание копии ''%s''';
    FillTables = 'Заполнение таблиц репликации';
    Activization = 'Активизация';
    Deactivization = 'Деактивизация';
    CreateRole = 'Создание роли пользователя';
    DropRole = 'Удаление роли пользователя';
    UpdateReplDBList = 'Обновление списка реплицируемых баз';

    RelationFields = 'Поля';
    RelationTriggers = 'Триггеры';
    RelationGenerator = 'Генератор: ';
    RelationGeneratorCant = 'Первичный ключ натуральный';
    SetConformity = 'Set conformity';//????

    RelationTriggerBI = 'Перед вставкой';
    RelationTriggerBU = 'Перед изменением';
    RelationTriggerBD = 'Перед удалением';
    RelationTriggerAI = 'После вставки';
    RelationTriggerAU = 'После изменения';
    RelationTriggerAD = 'После удаления';

    ErrorOnAction = 'Ошибка при %s в таблице %s';
    rtInsert = 'вставка записи';
    rtUpdate = 'обновление записи';
    rtDelete = 'удаление записи';

    //Сообщения об ошибке в подготовке к репликации
    ERR_OK = 'Ошибок нет.';
    ERR_NOONE_FIELD_SELECTED =
      'Невыбрано ни одного поля.'#13#10 +
      'Вы должны добовить хотябы одно поле в схему репликации'#13#10 +
      'или удалить таблицу из схемы репликации.';

    ERR_PK_NOT_SELECT =
      'Необходимо выбрать один из уникальных индексов для поиска записи';
    ERR_PK_NOT_MARK =
      'Необходимо выбрать один из уникальных индексов для поиска записи';
    ERR_NOTNULL_NOT_SELECTED =
      'В схему репликации должны входить все NOT NULL поля выбранной таблицы.';
    ERR_GENERATOR_DEF_NOT_SELECT = 'Необходимо выбрать генератор по умолчанию.';
    ERR_GENERATOR_DB_NOT_SELECT = 'Необходимо выбрать генератор.';
    ERR_GENERATOR_NAME_MISSING =
      'Неуказано имя генератора';
    ERR_THERE_ARE_ERRORS = 'Имеются ошибки';

    ERR_MAKE_DB_COPY = 'Не удалось создать копию базы данных.'#13#10 +
      'Возможно нет доступа к папке в которой расположен файл базы данных.';

    MSG_SET_ALT_KEY_AS_PRIME_KEY =
      'Таблица %s содержит один альтернативный ключ.'#13#10 +
      'Рекомендуется выбрать его для поиска записей.'#13#10 +
      'Вы хотите этого?';

    MSG_SELECT_REFERENCE_FIELD =
      'Поле %s в таблице %s ссылается'#13#10 +
      'на поле %s. Поле %s или таблица %s не входит'#13#10 +
      'в схему репликации. Вы хотите включить поле и таблицу'#13#10 +
      'в схему репликации?';

    MSG_DESELECT_REFERENCE_FIELD =
      'Имеются поля, ссылающиеся на поле %s.'#13#10 +
      'Вы хотите исключить эти поля'#13#10 +
      'из схемы репликации?';

    MSG_SELECT_REFERENCE_FIELDS =
      'Имеются внешние ссылки на таблицу %s.'#13#10 +
      'Вы хотите удалить из схемы репликации поля и'#13#10 +
      'таблицы, ссылающиесы на данное поле?';

    MSG_INFORMATION = 'Информация';
    MSG_WARNING = 'Предупреждение';
    MSG_QUESTION = 'Вопрос';

    dbs_Main = 'Main';
    dbs_Secondary = 'Второстепенная';
    dbp_Highest = 'Наивысший';
    dbp_High = 'Высокий';
    dbp_Normal = 'Нормальный';
    dbp_Low = 'Низкий';
    dbp_Lowest = 'Нижайший';

    cap_DBState = 'Статус';
    cap_DBPriority = 'Приоритет';
    cap_DBName = 'Имя';

  //отчет после подготовки к репликации
    MSG_REPORT_READING_DBINFO = 'Чтение информации о базе данных...';
    MSG_REPORT_DATE = 'Дата: %s';
    MSG_REPORT_LAST_PROCESS_REPL_DATE = '  Дата последней обработки реплики: %s';
    MSG_REPORT_LAST_REPL_DATE = '  Дата последней передачи данных: %s';
    MSG_REPORT_REPLTYPE = 'Тип схемы репликации: %s';
    MSG_REPORT_ERROR_DECISION = 'Разрешение конфликтных ситуаций: %s';
    MSG_REPORT_REPL_KEY = 'Ключ схемы репликации: %d';
    MSG_REPORT_DB = 'База данных:';
    MSG_REPORT_DB_ALIAS = '  Имя базы: %s';
    MSG_REPORT_DB_FILE_NAME = '  Имя файла: %s';
    MSG_REPORT_DB_STATE = '  Статус: %s';
    MSG_REPORT_DB_PRIORITY = '  Приоритет: %s';
    MSG_REPORT_DB_KEY = '  Ключ базы данных: %d';
    MSG_REPORT_NOT_COMMIT = '  Количество неподтвержденных передач данных: %d';
    MSG_REPORT_REGISTRED_CHANGES_COUNT = '  Количество изменений: %d';
    MSG_REPORT_REPL_COUNT = '  Количество передач данных: %d';
    MSG_REPORT_PROCESS_REPL_COUNT = '  Количество обработанных реплик: %d';
    MSG_REPORT_CONFLICT_COUNT = '  Количество неразрешенных конфликтов: %d';
    MSG_REPORT_DUAL = 'Двунаправленная';
    MSG_REPORT_FROMSERVER = 'Однонапрвленная от сервера';
    MSG_REPORT_TOSERVER = 'Однонапрвленная к серверу';
    MSG_REPORT_CURRENT_DB_ALIAS = 'Текущая база данных: %s';
    MSG_REPORT_TRANSFER_DATA_TO = 'Возможна передача данных:';

    MSG_REPORT_ERR_DECISION_SERVER = 'Изменения на базе имеют приоритет';
    MSG_REPORT_ERR_DECISION_PRIORITY = 'По приоритету';
    MSG_REPORT_ERR_DECISION_TIME = 'Новые изменения имеют приоритет';

    MSG_METADATA_DELETE_SUCCES = 'Все метаданные репликации были успешно удалены.';//????
    { TODO : Написать хорошее сообщение }
    MSG_METADATA_DELETE_ERROR = 'При удалении метаданных возникли ошибки:';
    MSG_CREATE_METADATA_ERROR = 'Во время создания метаданных возникли ошибки:';

  {    'Дата подготовки к репликации: %s'#13#10 +
      'Тип схемы репликации: %s'#13#10 +
      'Способ разрешения конфликных ситуаций: %s'#13#10 +
      'Ключ схемы репликации: %d'#13#10 +
      'Базы данных, участвующие в репликации:'#13#10 +
      '%s'#13#10;}

  //Заголовок заклатки отчета выполнения скрипта
    MSG_REPORT_CAPTION_SUCCES = 'Успешное завершение';
    MSG_REPORT_CAPTION_ERROR = 'Ошибка';

    MSG_REPORT_EXPORT_SUCCES = 'Успешная передача данных.';
    MSG_REPORT_EXPORT_UNSUCCES = 'Во время передачи данных возникли ошибки.';
    MSG_REPORT_EXPORT_CONFIRM_SUCCES = 'Создан файл подтверждения передачи данных.';
    MSG_REPORT_EXPORT_CONFIRM_UNSUCCES = 'Во время создания файла подтверждения передачи данных возникли ошибки.';

    MSG_REPORT_IMPORT_SUCCES = 'Успешная обработка данных.';
    MSG_REPORT_IMPORT_UNSUCCES = 'Во время обработки файла реплики возникли ошибки.';
    MSG_REPORT_IMPORT_CONFIRM_SUCCES = 'Передача данных подтверждена.';
    MSG_REPORT_IMPORT_CONFIRM_UNSUCCES = 'Во время обработки файла подтверждения возникли ошибки.';

    MSG_DROP_METADATA_CAPTION = 'Удаление метаданных.';
    MSG_WANT_DROP_METADATA = 'Вы действительно хотите удалить все'#13#10 +
     'метаданные репликации?';
    MSG_WANT_EDIT_METADATA = 'Вы действительно хотите изменить'#13#10 +
      'схему репликации?';
    MSG_EXPORT_DATA_CAPTION = 'Передача данных.';
    MSG_IMPORT_DATA_CAPTION = 'Обработка данных.';
    MSG_ROLLBACK_TRANSACTION_SUCCES = 'Удачная отмена передачи данных';
    MSG_ROLLBACK_TRANSACTION_ERROR = 'Во время отмены передачи данных возникли ошибки';
    MSG_DROP_FK = 'Отключение внешней ссылки %s на таблицу %s';
    MSG_DROPING_FK = 'Удаление внешних ссылок...';
    MSG_RESTORE_FKs = 'Восстановление внешних ссылок...';
    MSG_RESTORE_FK = 'Восстановление внешней ссылки %s на таблицу %s';
    MSG_FIND_NOT_RESTORE_FK = 'Обнаруженно %d невосстановленных внешних ссылок. Восстановление...';
    MSG_FOUND_NOT_RESTORED_TRIGGERS = 'Обнаружено %d невосстановленных триггеров. Восстановление...';
    MSG_INACTIVATE_TRIGGERS = 'Отключение триггеров...';
    MSG_ACTIVATE_TRIGGERS = 'Подключение триггеров...';
    MSG_RESTOREDB_CAPTION = 'Восстановление базы данных';
    MSG_RING_FKS_UPDATE = 'Обновление полей внешних ссылок';
    MSG_THERE_ARE_CONTENTION = 'Имеется %d неразрешенных конфликтных ситуаций';
    MSG_CONFLICT_RESOLUTION = 'Начат процесс разрешения конфликтных ситуаций';
    MSG_LOG_RESTORING_METADATA = 'Ход восстановления метаданных';
    MSG_LOG_REPLICATION = 'Ход репликации';
    MSG_START_REPL_FILE = 'Начата обработка файла: %s';
    MSG_END_REPL_FILE = 'Закончена обработка файла: %s';
    MSG_START_EXPORT_DB = 'База данных: %s';
    MSG_END_EXPORT_DB = 'Получен файл реплики: %s'#13#10;
    MSG_WANT_RESET_TRIGGER = 'Вы действительно хотите отменить все изменения в теле триггера?';
    MSG_SET_TRIGGER = 'Сохранить изменения в теле триггера?';
    MSG_RESTRUCT = 'Перестройка интервальных деревьев';
    MSG_MAKE_REST = 'Восстановление остатков';

    ERR_SHUTDOWN = 'Ошибка при переводе базы данных в однопользовательский режим.'#13#10;
    ERR_BRINGONLINE = 'Ошибка при возврате базы данных в нориальный режим.'#13#10;
    ERR_CREATE_TRIGGER = 'Ошибка при создании триггера %s:'#13#10;
    ERR_DROP_TRIGGER = 'Ошибка при создании триггера %s:'#13#10;
    ERR_CREATE_TABLE = 'Ошибка при создании таблицы %s:'#13#10;
    ERR_CREATE_GRAND = 'Error on create grand'#13#10;//????
    ERR_DROP_TABLE = 'Ошибка при удалении таблицы %s:'#13#10;
    ERR_CREATE_DOMANE = 'Ошибка при создании домена %s:'#13#10;
    ERR_DROP_DOMANE = 'Ошибка при удалении домена %s:'#13#10;
    ERR_CREATE_EXCEPTION = 'Ошибка при создании исключения %s:'#13#10;
    ERR_DROP_EXCEPTION = 'Ошибка при удалении исключения %s:'#13#10;
    ERR_CREATE_GENERATOR = 'Ошибка при создании генератора %s:'#13#10;
    ERR_DROP_GENERATOR = 'Ошибка при удалении генератора %s:'#13#10;
    ERR_CREATE_ROLE = 'Ошибка при создании роли пользователя %s:'#13#10;
    ERR_DROP_ROLE = 'Ошибка при удалении роли пользователя %s:'#13#10;
    ERR_ROLLBACK_TRANSACTION = 'Отменено %d  передач данных';
    ERR_DROP_FK = 'Ошибка при удалении внешнего ключа %s в таблице %s: %s';
    ERR_RESTORE_FK = 'Ошибка при востановлении внешнего ключа %s на таблицу %s: %s';
    ERR_INACTIVATE_TRIGGERS = 'Ошибка при отключении триггеров: %s';
    ERR_ACTIVATE_TRIGGERS = 'Ошибка при подключении триггера: %s';
    ERR_CANT_ROLLBACK_TRANSACTION = 'Ошибка при отмене передачи данных: %s';
    ERR_ON_READING_FILE = 'Ошибка при чтении файла %s';

    CAPTION_DEPEND_ON = ' Объекты, от которых зависит %s';
    CAPTION_DEPENDS_ON = 'Объекты, зависящие от %s';

    ALL_CONFLICT_RESOLUTION = 'Все конфликты разрешены';
    CANT_REPL = 'Репликация не возможна.';
    MSG_STREAM_DO_NOT_INIT = 'Поток неинициализирован';
    MSG_FILE_NOT_FOUND = 'Файл ''%s'' не найден';

    MSG_UPDATE_INSERT_RECORDS = ' Вставка и изменение записей';
    MSG_DELETE_RECORDS = ' Удаление записей';

    ERR_CANT_RESTORE_DB = 'Ошибка при попытке восстановления базы данных.'#13#10 +
                          '  Необходимо запустить программу восстановления ссылок'#13#10' (IBRRestoreFK.exe).';
    ERR_CANT_ADD_DIRECTION_FIELD = 'Ошибка при добавлении информации о направлении репликации.';


    CAPTION_DBALIAS_EXPORT = 'База на которую передаются данные:';
    CAPTION_DBALIASES_EXPORT = 'Базы на которые передаются данные:';
    CAPTION_DBALIAS_CONFIRM = 'База для которой создается файл подтверждения';
    CAPTION_DBALIASES_CONFIRM = 'База для которых создаются файлы подтверждения';
    CAPTION_FILENAME_EXPORT = 'Имя файла реплики:';
    CAPTION_FILENAME_EXPORT_CONFIRM = 'Имя файла подтверждения:';

    CAPTION_FILENAME_IMPORT = 'Имя файла реплики:';
    CAPTION_FILENAMES_IMPORT = 'Имена файлов реплики:';
    CAPTION_FILENAME_IMPORT_CONFIRM = 'Имя файла подтверждения:';
    CAPTION_FILENAMES_IMPORT_CONFIRM = 'Имена файлов подтверждения:';


    MSG_RELATION = 'Таблица %s';

    MSG_CAPTION = 'ИБ Репликатор';

    {$ELSE}

    InvalidDataBaseName = 'Invalid data base name ''%s''';
    ReplicationSchemaNotFound =  'Database is not prepared for replication';
    DataBaseIsNotConnected = 'Database is not connected';
    DataBaseTestConnectSucces = 'Succeseful connection test';
    InvalidDataBaseKey = 'Invalid database key';
    DataBaseNotAssigned = 'Database not assigned';
    InvalidFieldIndex = 'Invalid field index';
    InvalidParamIndex = 'Invalid param index';
    RelationNotAssigned = 'Relation not assigned';
    InvalidRelationKey = 'Invalid relation key';
    InvalidProtocol = 'Invalid protocol';
    SeqnoNotFound = 'Seqno not found';
    InvalidFieldName = 'Invalid field name';
    InvalidRelationName = 'Invalid relation name ''%s''';
    CantReturnBlobValue = 'Can`t return blob`s value';
    CantSaveRigistryInfo = 'Can`t save registry info';
    CantLoadRegistryInfo = 'Can`t load registry info';
    InvalidStreamData = 'Invalid stream data';
    InvalidSchema = 'Invalid schema';
    InvalidStreamversion = 'Invalid stream version';
    MissingFiles = 'Missing %d files';
    OneNotConfirmedTransaction = 'DataBase have one not confirmed transaction.'#13#10 +
      'Server rollback her';
    ManyNotConfirmedTransaction = 'DataBase have %d not confirmed transactions.'#13#10 +
      'Server rollback them';
    FieldNotFound = 'Field "%s" not found in table "%s"';
    Question_On_Delete_Base =
      'Do you realy want to delete selected base from'#13#10 +
      'replication scheme?';
    QuestionBackupDatabase =
      'Do you want make an archive copy of database?';

    AlreadyReplicated = 'Already replicated';

    EnterServerName = 'Enter server name';
    EnterProtocol = 'Enter protocol';
    EnterDataBaseFileName = 'Enter database file name';
    EnterUserName = 'Enter user name';
    EnterPassword = 'Enter password';
    EnterCharset = 'Enter charset';
    ConnectionError = 'Connection error';
    ConnectionTest = 'Connection test';

    BeginExport = 'Begin export data...';
    PrepareLog = 'Prepare log';
    PrepareGDRUID = 'Prepare table GD_RUID';
    PreparedForExport = 'Prepared for export %d records';
    NRecordPassed = '%d record passed';
    ReplicationStarting = 'Replication starting ...';

  {  CompressingFile = 'Compressing output file ...';
    CopressSucces = 'Succeseful. Output file: %s';
    CopressError = 'Compresiing error.';}

    CountChanges = '%d changes in data base';
    FileExists = 'File ''%s'' alredy exist.'#13#10 +
      'Do you want replace him?';

    OpenDBFilter = 'Interbase data base|*.gdb;*.fdb|All files|*.*';
    ReplFileFilter = 'RPL files|*.rpl|Compressed RPL files|*.z|All files|*.*';
    SQLFileFilter = 'SQL-script|*.sql|Text files|*.txt|All files|*.*';
    ReplSchemaFileFilter = 'RPD files|*.rpd|All files|*.*';
    NotEnoughDiskSpace =
      'Do not enough disk space.'#13#10 +
      'Please select other file path.';
    DoYouWantExstractDBFromRepl = 'Do you want extract %s from replication scheme?';
    CannotDetermineFilePath = 'Can`t determine path to source data base.';
    TerminatedByUser = 'Terminated by user';
    EnterReplicationFileName = 'Enter replication`s file name';
    EnterDBName = 'Enter data base name';

    ServerList = '\ServerList';

    DropTriggers = 'Drop triggers';
    DropTriggersMainDB = 'Drop triggers from main database';
    DropOldTriggers = 'Drop old triggers';
    CreateTriggers = 'Create triggers';

    DropTables = 'Drop tables';
    DropOldTables = 'Drop old tables';
    CreateTables = 'Create tables';

    DropDomanes = 'Drop domains';
    DropOldDomanes = 'Drop old domains';
    CreateDomanes = 'Create domains';

    DropGenerators = 'Drop generators';
    DropOldGenerators = 'Drop old generators';
    CreateGenerators = 'Create generators';

    CreateRuid = 'Create RUID for existing records';

    MakeCopy = 'Make copy ''%s''';
    FillTables = 'Fill replication tables';
    Activization = 'Activization';
    Deactivization = 'Deactivization';
    CreateRole = 'Create role';
    DropRole = 'Drop role';
    UpdateReplDBList = 'Update replication DB list';

    RelationFields = 'Fields';
    RelationTriggers = 'Triggers';
    RelationGenerator = 'Genarator: ';
    SetConformity = 'Set conformity';

    RelationTriggerBI = 'Before insert';
    RelationTriggerBU = 'Before update';
    RelationTriggerBD = 'Before delete';
    RelationTriggerAI = 'After insert';
    RelationTriggerAU = 'After update';
    RelationTriggerAD = 'After delete';

    ErrorOnAction = 'Error on %s in table %s';
    rtInsert = 'insert record';
    rtUpdate = 'update record';
    rtDelete = 'delete record';

    //Сообщения об ошибке в подготовке к репликации
    ERR_OK = 'No one error was found.';
    ERR_NOONE_FIELD_SELECTED =
      'No one field selected.'#13#10 +
      'You must select field'#13#10 +
      'or deselect relation.';
    ERR_PK_NOT_SELECT =
      'No one PRIMARY KEY field selected';
    ERR_PK_NOT_MARK =
      'No one field mark as PRIMARY KEY'#13#10 +
      'Please mark one or more UNIQUE fields as'#13#10 +
      'PRIMARY KEY and select it';
    ERR_NOTNULL_NOT_SELECTED =
      'One or more NOT NULL field not selected.'#13#10 +
      'You must select all NOT NULL fields or'#13#10 +
      'deselect relation.';
    ERR_GENERATOR_NAME_MISSING =
      'Generator name is missing';
    ERR_THERE_ARE_ERRORS = 'There are errors';

    MSG_SET_ALT_KEY_AS_PRIME_KEY =
      'The relation %s have one alternative key.'#13#10 +
      'Recommend select him as PRIME KEY.'#13#10 +
      'Do you want do it?';

    MSG_SELECT_REFERENCE_FIELD =
      'There is FOREIGN KEY on field %s in relation %s'#13#10 +
      'for field %s. The field %s or relation %s is not'#13#10 +
      'include in replication scheme. Do you want include this'#13#10 +
      'field and relation in scheme?';
    MSG_DESELECT_REFERENCE_FIELD =
      'There is referencies on field %s.'#13#10 +
      'Do you want remove this '#13#10 +
      'fields and relations from scheme?';
    MSG_SELECT_REFERENCE_FIELDS =
      'There is referencies on relation %s.'#13#10 +
      'Do you want remove reference fields and'#13#10 +
      'relations from replication scheme?';

    MSG_INFORMATION = 'Information';
    MSG_WARNING = 'Warning';
    MSG_QUESTION = 'Question';

    dbs_Main = 'Main';
    dbs_Secondary = 'Secondary';
    dbp_Highest = 'Highest';
    dbp_High = 'High';
    dbp_Normal = 'Normal';
    dbp_Low = 'Low';
    dbp_Lowest = 'Lowest';

    cap_DBState = 'State';
    cap_DBPriority = 'Priority';
    cap_DBName = 'Name';

  //отчет после подготовки к репликации
    MSG_REPORT_READING_DBINFO = 'Reading database info...';
    MSG_REPORT_DATE = 'Date: %s';
    MSG_REPORT_REPLTYPE = 'Replication scheme type: %s';
    MSG_REPORT_ERROR_DECISION = 'Error decision: %s';
    MSG_REPORT_REPL_KEY = 'Replication scheme key: %d';
    MSG_REPORT_DB = 'Data bases:';
    MSG_REPORT_DB_ALIAS = '  Alias: %s';
    MSG_REPORT_DB_FILE_NAME = '  File name: %s';
    MSG_REPORT_DB_STATE = '  State: %s';
    MSG_REPORT_DB_PRIORITY = '  Priority: %s';
    MSG_REPORT_DB_KEY = '  Database key: %d';
    MSG_REPORT_NOT_COMMIT = '  Not commited transaction: %d';
    MSG_REPORT_REGISTRED_CHANGES_COUNT = '  Registred changes: %d';
    MSG_REPORT_CONFLICT_COUNT = '  Conflict count: %d';
    MSG_REPORT_DUAL = 'Dual';
    MSG_REPORT_FROMSERVER = 'From server';
    MSG_REPORT_TOSERVER = 'To server';
    MSG_REPORT_CURRENT_DB_ALIAS = 'Current database: %s';
    MSG_REPORT_TRANSFER_DATA_TO = 'Can transfer data to:';

    MSG_REPORT_ERR_DECISION_SERVER = 'Server changes have priority';
    MSG_REPORT_ERR_DECISION_PRIORITY = 'By priority';
    MSG_REPORT_ERR_DECISION_TIME = 'Newest changes have priority';

    MSG_METADATA_DELETE_SUCCES = 'All replication metadate have been succeseful deleted.';
    { TODO : Написать хорошее сообщение }
    MSG_METADATA_DELETE_ERROR = 'There are errors:';
    MSG_CREATE_METADATA_ERROR = 'There are errors:';

  {    'Дата подготовки к репликации: %s'#13#10 +
      'Тип схемы репликации: %s'#13#10 +
      'Способ разрешения конфликных ситуаций: %s'#13#10 +
      'Ключ схемы репликации: %d'#13#10 +
      'Базы данных, участвующие в репликации:'#13#10 +
      '%s'#13#10;}

  //Заголовок заклатки отчета выполнения скрипта
    MSG_REPORT_CAPTION_SUCCES = 'Succes';
    MSG_REPORT_CAPTION_ERROR = 'Error';

    MSG_REPORT_EXPORT_SUCCES = 'Successful export.';
    MSG_REPORT_EXPORT_UNSUCCES = 'Unuccessful export.';

    MSG_REPORT_IMPORT_SUCCES = 'Successful import.';
    MSG_REPORT_IMPORT_UNSUCCES = 'Unuccessful import.';

    MSG_DROP_METADATA_CAPTION = 'Drop metadata.';
    MSG_WANT_DROP_METADATA = 'Do you realy want to delete all'#13#10 +
     'replication metadata?';
    MSG_WANT_EDIT_METADATA = 'Do you realy want to edit'#13#10 +
      'replication scheme?';
    MSG_EXPORT_DATA_CAPTION = 'Export data.';
    MSG_IMPORT_DATA_CAPTION = 'Import data.';
    MSG_ROLLBACK_TRANSACTION_SUCCES = 'Successful rollback transaction';
    MSG_ROLLBACK_TRANSACTION_ERROR = 'Unuccessful rollback transaction';
    MSG_DROP_FK = 'Drop foreign key %s on table %s';
    MSG_DROPING_FK = 'Dropping foreign keys...';
    MSG_RESTORE_FKs = 'Restore foreign keys...';
    MSG_RESTORE_FK = 'Restore foreign key %s on table %s';
    MSG_FIND_NOT_RESTORE_FK = 'Found %d not restored foreign keys. Restoring...';
    MSG_FOUND_NOT_RESTORED_TRIGGERS = 'Found %d not restored triggers. Restoring...';
    MSG_INACTIVATE_TRIGGERS = 'Inactivate triggers...';
    MSG_ACTIVATE_TRIGGERS = 'Activate triggers...';
    MSG_RESTOREDB_CAPTION = 'Restore data base';
    MSG_THERE_ARE_CONTENTION = 'There are %d contention';
    MSG_CONFLICT_RESOLUTION = 'Start conflict resolution';
    MSG_LOG_RESTORING_METADATA = 'Metadata restoring log';
    MSG_LOG_REPLICATION = 'Replication log';
    MSG_START_REPL_FILE = 'Begin process file: %s';
    MSG_END_REPL_FILE = 'End process file: %s';
    MSG_WANT_RESET_TRIGGER = 'You really want to cancel all changes in a body of the trigger?';
    MSG_SET_TRIGGER = 'Save changes in a body of the trigger?';

    ERR_CREATE_TRIGGER = 'Error on create trigger %s:'#13#10;
    ERR_DROP_TRIGGER = 'Error on drop trigger %s:'#13#10;
    ERR_CREATE_TABLE = 'Error on create table %s:'#13#10;
    ERR_CREATE_GRAND = 'Error on create grand'#13#10;
    ERR_DROP_TABLE = 'Error on drop table %s:'#13#10;
    ERR_CREATE_DOMANE = 'Error on create domane %s:'#13#10;
    ERR_DROP_DOMANE = 'Error on drop domane %s:'#13#10;
    ERR_CREATE_EXCEPTION = 'Error on create exception %s:'#13#10;
    ERR_DROP_EXCEPTION = 'Error on drop exception %s:'#13#10;
    ERR_CREATE_GENERATOR = 'Error on create generator %s:'#13#10;
    ERR_DROP_GENERATOR = 'Error on drop generator %s:'#13#10;
    ERR_CREATE_ROLE = 'Error on create role %s:'#13#10;
    ERR_DROP_ROLE = 'Error on drop role %s:'#13#10;
    ERR_ROLLBACK_TRANSACTION = '%d transaction was rollbacked';
    ERR_DROP_FK = 'Error on drop foreign key %s on table %s: %s';
    ERR_RESTORE_FK = 'Error on restore foreign key %s on table %s: %s';
    ERR_INACTIVATE_TRIGGERS = 'Error on inactivate triggers: %s';
    ERR_ACTIVATE_TRIGGERS = 'Error on activate triggers: %s';
    ERR_CANT_ROLLBACK_TRANSACTION = 'Can`t rollback transaction: %s';
    ERR_ON_READING_FILE = 'Error on reading file %s';

    CAPTION_DEPEND_ON = ' Objects, that depend on %s';
    CAPTION_DEPENDS_ON = ' Objects, that %s depends on';

    ALL_CONFLICT_RESOLUTION = 'All conflict resolutioned';
    CANT_REPL = 'Replication impossible.';
    MSG_STREAM_DO_NOT_INIT = 'Stream do not init';
    MSG_FILE_NOT_FOUND = 'File ''%s'' not found';

    MSG_UPDATE_INSERT_RECORDS = ' Inserting and updating records';
    MSG_DELETE_RECORDS = ' Deleting records';

    ERR_CANT_ADD_DIRECTION_FIELD = 'Error while trying adding information about replication direction.';

    MSG_RELATION = 'Relation %s';

    MSG_CAPTION = 'IBReplicator';

    {$ENDIF}

implementation

end.
