
unit gd_resourcestring;

interface

resourcestring
  sDeleteMessageQuestion = 'Вы действительно хотите удалить сообщение(я)?';

  sMailDownloadCaption   = 'Прием сообщений';
  sMailDownloadServer    = 'Сервер %s';
  sMailDownloadCount     = 'Получено сообщений: %d';
  sMailUploadServer      = 'Сервер %s';
  sMailUploadCount       = 'Отправлено сообщений: %d';

  sConnectionLostToIBServer = 'Невозможно установить соединение с сервером базы данных.'#13#10 +
    'Выполнение программы будет прекращено.'#13#10 +
    'Имя сервера: %s'#13#10 +
    'Код ошибки IBError: %d' +
    ''
    ;
  sCannotConnectToSpecifiedFile = 'Файл базы данных не найден.'#13#10 +
    'Выполнение программы будет прекращено.'#13#10 +
    'Имя сервера: %s'#13#10 +
    'Код ошибки IBError: %d' +
    ''
    ;

  sError                 = 'Ошибка!';
  sAttention             = 'Внимание!';

  sIncorrectPassword     = 'Введен неверный пароль.'#13#10#13#10'Пожалуйста, проверьте правильно ли '#13#10'установлена раскладка клавиатуры.';

  sBugBaseIncorrectRecordUpdate =
                           'Проверьте правильность заполнения всех полей.';

  sAttrNotInAdministratorModeCannotDropRelation =
                           'Только Администратор системы имеет право на удаление таблицы.';

  sgsDatabaseShutdownShutdownDlgCaption =
                           'Перевод базы в однопользовательский режим';
  sgsDatabaseShutdownShowUsersDlgCaption =
                           'Пользователи, подключенные к базе данных';

  sIncorrectShutdown     = 'Сеанс работы был завершен некорректно.';

  sDeleteDesktopQuery    = 'Вы действительно хотите удалить рабочий стол "%s"?';

  s_gdcRelationField_NameTooLong =
    'Длина имени поля превышает 16 символов. Мета-данные могут быть не созданы '#13#10 +
    'при создании поля-ссылки, поля-множества. Продолжить?';

  sDublicateDocumentNumber = 'Дублируется номер документа!';
  sSetDocumentDate = 'Необходимо указать дату документа!';
  s_InvBadChangeCloseWindow = 'Произвести данное изменение нельзя! Окно будет закрыто без сохранения всех изменений !';
  s_InvChooseGood = 'Необходимо указать ТМЦ !';
  s_InvEmptyField = 'Незаполнено поле ';
  s_InvErrorSaveHeadDocument =
    'При сохранении шапки документа произошла следующая ошибка: %s';
  s_InvErrorEditDocument =
    'В результате редактирования возникла ошибка: %s'#13#10'Произведена отмена изменений.';
  s_InvErrorSaveMovement =    
    'При формировании движения возникла ошибка. Произведена отмена изменений.';
  s_InvFullErrorSaveMovement =
    'При формировании движения возникла ошибка: %s'#13#10'Произведена отмена изменений.';
  s_InvErrorChooseRemains = 'Нельзя выбрать больше ТМЦ, чем имеется по данным учета.';
  
  sDBConnect = 'Соединение с базой данных';
  sReadingDbScheme = 'Считывание структуры базы данных';
  sLoadingStorage = 'Загрузка хранилища';
  sLoadingUserDefinedClasses = 'Загрузка бизнес-классов';
  sSynchronizationAtRelations = 'Синхронизация таблиц';
  sReadingDomains = 'Считывание доменов';
  sReadingRelations = 'Считывание таблиц';
  sReadingFields = 'Считывание полей';
  sReadingPrimKeys = 'Считывание первичных ключей';
  sReadingForeignKeys = 'Считывание внешних ключей';
  sLoadingGlobalStorage = 'Загрузка глобального хранилища';
  sLoadingUserStorage = 'Загрузка пользовательского хранилища';
  //sLoadingCompanyStorage = 'Загрузка хранилища организации';
  sInitMacrosSystem = 'Инициализация системы макросов';
  sLoadingExplorer = 'Загрузка исследователя';
  sLoadingDesktop = 'Загрузка рабочего стола';
  sItisAll = 'Загрузка завершена';
  sInventoryDocumentDontFound = 'Складской документ не найден!';

implementation

end.