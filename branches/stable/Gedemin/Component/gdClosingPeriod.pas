unit gdClosingPeriod;

interface

uses
  IBDatabase, Classes, SysUtils, gd_KeyAssoc, gdcBaseInterface, stdctrls, comctrls,
  IBSQL, forms;

type
  TgsProcessState = (psUnknown, psWorking, psSuccess, psTerminating, psInterrupted, psError);

  TgsBeforeAfterProcessRoutine = procedure;
  TgsOnProcessInterruptionRoutine = procedure(const AErrorMessage: String);
  TgsOnProcessMessage = procedure(const APosition, AMaxPosition: Integer; const AMessage: String);

  TgdClosingPeriod = class(TObject)
  private
    FDontDeleteCardArray: TgdKeyArray;
    // Нить на которой закрывается период
    FWorkingThread: TThread;
    // Пишущая транзакция для закрытия периода
    FWriteTransaction: TIBTransaction;
    // Время начало отдельной части закрытия периода
    FLocalStartTime: TDateTime;
    // Параметры доступа к закрываемой БД
    FExtDatabasePath: String;
    FExtDatabaseServer: String;
    FExtDatabaseUser: String;
    FExtDatabasePassword: String;
    FCloseDate: TDateTime;
    // Список внешних ключей на таблицы:
    //   имя таблицы - объект-список внешних ключей
    FTableReferenceForeignKeysList: TStringList;
    // Список полей-признаков складской карточки из настроек
    FFeatureList: TStringList;
    // Количество созданных записей в AC_ENTRY_BALANCE
    FInsertedEntryBalanceRecordCount: Integer;
    // Список бухгалтерских аналитик, в разрезе которых строится бух. сальдо
    FEntryAvailableAnalytics: TStringList;
    // Сущестует ли поле-ссылка на позицию прихода
    FAddLineKeyFieldExists: Boolean;
    FInvDocumentTypeKey: TID;
    // Список аналитик AC_ENTRY по которым не надо расчитывать сальдо
    FDontBalanceAnalytic: String;

    FPseudoClientKey: TID;

    FUserDocumentTypesToDelete: TgdKeyArray;
    FDontDeleteDocumentTypes: TgdKeyArray;
    // Список заглушек по типам документов
    FDummyInvDocumentKeys: TgdKeyIntAssoc;

    FQueriesInitialized: Boolean;
    FIBSQLGetDepotHeaderKey: TIBSQL;
    FIBSQLInsertGdDocument: TIBSQL;
    FIBSQLInsertDocumentHeader: TIBSQL;
    FIBSQLInsertDocumentPosition: TIBSQL;
    FIBSQLInsertInvCard: TIBSQL;
    FIBSQLInsertInvMovement: TIBSQL;
    FIBSQLDeleteRUID: TIBSQL;

    FOnBeforeProcess: TgsBeforeAfterProcessRoutine;
    FOnAfterProcess: TgsBeforeAfterProcessRoutine;
    FOnProcessInterruption: TgsOnProcessInterruptionRoutine;
    FOnProcessMessage: TgsOnProcessMessage;

    FOnlyOurRemains: Boolean;
    // Поля определяют, будет ли модель выполнять
    //  соответствующие действия во время закрытия периода
    FDoCalculateEntryBalance: Boolean;  // Подсчет бухгалтерского сальдо
    FDoCalculateRemains: Boolean;       // Подсчет складских остатков
    FDoReBindDepotCards: Boolean;       // Перепривязка складских карточек и движения
    FDoDeleteEntry: Boolean;            // Удаление проводок
    FDoDeleteDocuments: Boolean;        // Удаление складских документов
    FDoDeleteUserDocuments: Boolean;    // Удаление пользовательских документов
    FDoTransferEntryBalance: Boolean;   // Перенос бухгалтерского сальдо из AC_ENTRY_BALANCE в AC_ENTRY

    //procedure InsertDatabaseRecord;
    function GetFeatureFieldList(AAlias: String): String;
    function IIF(const Condition: Boolean; const TrueString, FalseString: String): String;

    function AddDepotHeader(const FromContact, ToContact, CompanyKey: TID): TID;
    function AddDepotPosition(const FromContact, ToContact, CompanyKey,
      ADocumentParentKey, CardGoodkey: TID; const GoodQuantity: Currency; FeatureDataset: TIBSQL = nil): TID;

    function GetReplacementInvCardKey(const AOldCardKey: TID; AFeatureDataset: TIBSQL;
      const AFromContactkey: TID = -1; const AToContactkey: TID = -1): TID;
    // Процедура находит записи ссылающиеся на карточку по переданному документу и пытается убрать зависимость
    procedure TryToDeleteInvCardReferences(const ADocumentKey: TID);
    // Процедура пытается удалить записи ссылающиеся на переданную
    procedure TryToDeleteDocumentReferences(const AID: TID; const AdditionalRelationName: String; const ADocTypeKey: Integer = -1);
    function CreateDummyInvDocument(const ADocTypeKey: TID): TID;

    procedure DeleteRUID(const AID: Integer);

    procedure InitialFillOptions;
    procedure InitializeIBSQLQueries;

    function GetInProcess: Boolean;
  protected
    // Состояние объекта
    FProcessState: TgsProcessState;
  public
    constructor Create;
    destructor Destroy; override;

    // Заполнение и очистка списка типов складских документов, которые нельзя 'закрывать'
    procedure AddDontDeleteDocumentType(DocType: TID);
    procedure ClearDontDeleteDocumentTypes;
    // Заполнение и очистка списка типов пользовательских докуметов подлежащих 'закрытию'
    procedure AddUserDocumentTypeToDelete(DocType: TID);
    procedure ClearUserDocumentTypesToDelete;
    // Заполнение и очистка списка актуальных складских признаков
    procedure AddInvCardFeature(FeatureFieldName: String);
    procedure ClearInvCardFeatures;
    // Установливает параметры доступа к закрываемой БД
    procedure SetClosingDatabaseParams(const ADBPAth, ADBServer, ADBUser, ADBPAssword: String);

    // Последовательное выполнение всех действий для 'закрытия периода'
    procedure DoClosePeriod;
    // Остановить выполнение закрытия периода
    procedure StopProcess;

    // Подготавливает список документов которые нельзя удалять
    procedure PrepareDontDeleteDocumentList;
    // Включает\выключает триггеры которые мешают 'закрытию периода'
    procedure SetTriggerActive(SetActive: Boolean);
    // Подсчет бухгалтерского сальдо
    procedure CalculateEntryBalance;
    // Подсчет складских остатков
    procedure CalculateRemains;
    // Перепривязка складских карточек и движения
    procedure ReBindDepotCards;
    // Удаление проводок
    procedure DeleteEntry;
    // Удаление складских документов
    procedure DeleteDocuments;
    // Удаление пользовательских документов
    procedure DeleteUserDocuments;
    // Перенос бухгалтерского сальдо из AC_ENTRY_BALANCE в AC_ENTRY
    procedure TransferEntryBalance;

    procedure DoBeforeProcess;
    procedure DoAfterProcess;
    procedure DoOnProcessInterruption(const AErrorMessage: String);
    procedure DoOnProcessMessage(const APosition, AMaxPosition: Integer; const AMessage: String);

    // Работает ли сейчас закрытие периода
    property InProcess: Boolean read GetInProcess;
    // Состояние объекта
    property ProcessState: TgsProcessState read FProcessState;
    // Дата закрытия периода
    property CloseDate: TDateTime read FCloseDate write FCloseDate;

    // Свойства для процедуры обрабатывающих сообщения модели
    property OnBeforeProcessRoutine: TgsBeforeAfterProcessRoutine read FOnBeforeProcess write FOnBeforeProcess;
    property OnAfterProcessRoutine: TgsBeforeAfterProcessRoutine read FOnAfterProcess write FOnAfterProcess;
    property OnProcessInterruptionRoutine: TgsOnProcessInterruptionRoutine read FOnProcessInterruption write FOnProcessInterruption;
    property OnProcessMessageRoutine: TgsOnProcessMessage read FOnProcessMessage write FOnProcessMessage;

    // Считать остатки только по рабочим организациям, или по всем контактам
    property OnlyOurRemains: Boolean read FOnlyOurRemains write FOnlyOurRemains;
    // Список аналитик AC_ENTRY по которым не надо расчитывать сальдо (;FIELD1;FIELD2;FIELD3;)
    property DontBalanceAnalytic: String read FDontBalanceAnalytic write FDontBalanceAnalytic;
    // Свойства для доступа к полям, которые определяют, будет ли модель выполнять
    //  соответствующие действия во время закрытия периода
    property DoCalculateEntryBalance: Boolean read FDoCalculateEntryBalance write FDoCalculateEntryBalance;
    property DoCalculateRemains: Boolean read FDoCalculateRemains write FDoCalculateRemains;
    property DoReBindDepotCards: Boolean read FDoReBindDepotCards write FDoReBindDepotCards;
    property DoDeleteEntry: Boolean read FDoDeleteEntry write FDoDeleteEntry;
    property DoDeleteDocuments: Boolean read FDoDeleteDocuments write FDoDeleteDocuments;
    property DoDeleteUserDocuments: Boolean read FDoDeleteUserDocuments write FDoDeleteUserDocuments;
    property DoTransferEntryBalance: Boolean read FDoTransferEntryBalance write FDoTransferEntryBalance;
  end;

  TgdClosingThread = class(TThread)
  protected
    FModel: TgdClosingPeriod;
  public
    procedure Execute; override;

    property Model: TgdClosingPeriod read FModel write FModel;
  end;

implementation

uses
  gdcInvDocument_unit,          at_classes,             gd_security,
  Windows,                      db,                     contnrs,
  AcctUtils,                    AcctStrings,            controls,
  gdcAcctEntryRegister,         Storages;

const
  InvDocumentRUID = '174849703_1094302532';
  INV_DOCUMENT_HEAD = 'USR$INV_DOCUMENT';
  INV_DOCUMENT_LINE = 'USR$INV_DOCUMENTLINE';
  REFRESH_CLOSING_INFO_INTERVAL = 100;

  SEARCH_NEW_CARDKEY_TEMPLATE =
    'SELECT FIRST(1) ' +
    '  card.id AS cardkey, card.firstdocumentkey, card.firstdate ' +
    'FROM ' +
      INV_DOCUMENT_HEAD + ' head ' +
    '  LEFT JOIN gd_document doc ON doc.id = head.documentkey ' +
    '  LEFT JOIN ' + INV_DOCUMENT_LINE + ' line ON line.masterkey = head.documentkey ' +
    '  LEFT JOIN inv_card card ON card.id = line.fromcardkey ' +
    'WHERE ' +
    '  doc.documentdate = :closedate ' +
    '  AND card.goodkey = :goodkey ' +
    '  AND ' +
    '    ((head.usr$in_contactkey = :contact_01) ' +
    '    OR (head.usr$in_contactkey = :contact_02)) ';
  SEARCH_NEW_CARDKEY_TEMPLATE_SIMPLE =
    'SELECT FIRST(1) ' +
    '  card.id AS cardkey, card.firstdocumentkey, card.firstdate ' +
    'FROM ' +
      INV_DOCUMENT_LINE + ' line ' +
    '  JOIN gd_document doc ON doc.id = line.documentkey ' +
    '  JOIN inv_card card ON card.id = line.fromcardkey ' +
    'WHERE ' +
    '  doc.documentdate = :closedate ' +
    '  AND doc.documenttypekey = :doctypekey ' + 
    '  AND card.goodkey = :goodkey ';

{ TgdClosingPeriod }

constructor TgdClosingPeriod.Create;
begin
  FWriteTransaction := TIBTransaction.Create(Application);
  FWriteTransaction.DefaultDatabase := gdcBaseManager.Database;
  FWriteTransaction.Params.Add('no_auto_undo');

  FTableReferenceForeignKeysList := TStringList.Create;
  // Список полей-признаков складской карточки из настроек
  FFeatureList := TStringList.Create;

  FUserDocumentTypesToDelete := TgdKeyArray.Create;
  FDontDeleteDocumentTypes := TgdKeyArray.Create;
  FDontDeleteCardArray := TgdKeyArray.Create;
  FDontDeleteCardArray.Sorted := True;

  FDummyInvDocumentKeys := TgdKeyIntAssoc.Create;
  FDummyInvDocumentKeys.Sorted := True;

  FEntryAvailableAnalytics := TStringList.Create;

  FInsertedEntryBalanceRecordCount := 0;
  FProcessState := psUnknown;
  // Получить неучтенные в прошлом закрытии бух. аналитики
  FDontBalanceAnalytic := GetDontBalanceAnalyticList;

  FIBSQLGetDepotHeaderKey := TIBSQL.Create(Application);
  FIBSQLInsertGdDocument := TIBSQL.Create(Application);
  FIBSQLInsertDocumentHeader := TIBSQL.Create(Application);
  FIBSQLInsertDocumentPosition := TIBSQL.Create(Application);
  FIBSQLInsertInvCard := TIBSQL.Create(Application);
  FIBSQLInsertInvMovement := TIBSQL.Create(Application);
  FIBSQLDeleteRUID := TIBSQL.Create(Application);
  FQueriesInitialized := False;
end;

destructor TgdClosingPeriod.Destroy;
begin
  FreeAndNil(FWriteTransaction);

  FreeAndNil(FIBSQLDeleteRUID);
  FreeAndNil(FIBSQLInsertGdDocument);
  FreeAndNil(FIBSQLInsertDocumentHeader);
  FreeAndNil(FIBSQLInsertDocumentPosition);
  FreeAndNil(FIBSQLInsertInvCard);
  FreeAndNil(FIBSQLInsertInvMovement);
  FreeAndNil(FIBSQLGetDepotHeaderKey);

  FreeAndNil(FEntryAvailableAnalytics);
  FreeAndNil(FDontDeleteDocumentTypes);
  FreeAndNil(FDontDeleteCardArray);
  FreeAndNil(FDummyInvDocumentKeys);
  FreeAndNil(FUserDocumentTypesToDelete);
  FreeAndNil(FFeatureList);
  FreeAndNil(FTableReferenceForeignKeysList);
end;

procedure TgdClosingPeriod.AddDontDeleteDocumentType(DocType: TID);
begin
  FDontDeleteDocumentTypes.Add(DocType);
end;

procedure TgdClosingPeriod.ClearUserDocumentTypesToDelete;
begin
  FUserDocumentTypesToDelete.Clear;
end;

procedure TgdClosingPeriod.AddUserDocumentTypeToDelete(DocType: TID);
begin
  FUserDocumentTypesToDelete.Add(DocType);
end;

procedure TgdClosingPeriod.ClearDontDeleteDocumentTypes;
begin
  FDontDeleteDocumentTypes.Clear;
end;

procedure TgdClosingPeriod.AddInvCardFeature(FeatureFieldName: String);
begin
  FFeatureList.Add(FeatureFieldName);
end;

procedure TgdClosingPeriod.ClearInvCardFeatures;
begin
  FFeatureList.Clear;
end;

procedure TgdClosingPeriod.CalculateRemains;
var
  moveFieldList, balFieldList, cFieldList: String;
  ibsql: TIBSQL;
  ibsqlOurCompany: TIBSQL;
  OurCompanyListStr: String;
  CurrentContactKey, NextSupplierKey, CurrentSupplierKey: TID;
  LineCount: Integer;
  DocumentParentKey: TID;
begin
  // Запомним время начала расчета остатков
  FLocalStartTime := Time;
  // Визуализация процесса
  DoOnProcessMessage(0, 1, 'Формирование остатков...');

  // Заполним список полей-признаков складской карточки из настроек
  moveFieldList := GetFeatureFieldList('move.');
  balFieldList := GetFeatureFieldList('bal.');
  cFieldList := GetFeatureFieldList('c.');

  // Если указано что считаем остатки только по рабочим организациям, то
  if FOnlyOurRemains then
  begin
    ibsqlOurCompany := TIBSQL.Create(Application);
    try
      ibsqlOurCompany.Transaction := gdcBaseManager.ReadTransaction;
      ibsqlOurCompany.SQL.Text := 'SELECT companykey FROM gd_ourcompany';
      ibsqlOurCompany.ExecQuery;

      OurCompanyListStr := '';
      while not ibsqlOurCompany.Eof do
      begin
        OurCompanyListStr := OurCompanyListStr + ibsqlOurCompany.FieldByName('companykey').AsString;
        ibsqlOurCompany.Next;
        if not ibsqlOurCompany.Eof then
          OurCompanyListStr := OurCompanyListStr + ',';
      end;
    finally
      FreeAndNil(ibsqlOurCompany);
    end;
  end;

  ibsql := TIBSQL.Create(Application);
  try
    // Запрос на складские остатки
    // TODO: смотреть поле для поиска поставщика (usr$inv_addlinekey) по настройкам
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text :=
      ' SELECT ' +
      '  move.contactkey, ' +
      '  cont.name AS ContactName, ' +
      '  move.SupplierKey, ' +
      '  move.goodkey, ' +
      '  move.companykey, ' +
      '  move.balance ' +
        IIF(moveFieldList <> '', ', ' + moveFieldList, '') +
      ' FROM ' +
      '  ( ' +
      '  SELECT ' +
      '    bal.contactkey, ' +
      '    inv_doc.usr$contactkey AS SupplierKey, ' +
      '    bal.goodkey, ' +
      '    bal.companykey, ' +
      '    SUM(bal.balance) AS balance ' +
        IIF(balFieldList <> '', ', ' + balFieldList, '') +
      '  FROM ' +
      '    ( ' +
      '    SELECT ' +
      '      b.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey, ' +
      '      SUM(b.balance) AS balance ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      '    FROM ' +
      '      inv_balance b ' +
      '      JOIN inv_card c ON c.id = b.cardkey ' +
        IIF(FOnlyOurRemains,
          '      JOIN gd_contact cont ON cont.id = b.contactkey ' +
          '      JOIN gd_contact head_cont ON head_cont.lb <= cont.lb AND head_cont.rb >= cont.rb ', '') +
      '    WHERE ' +
      '      b.balance <> 0 ' +
        IIF(FOnlyOurRemains,
          '      AND head_cont.id IN (' + OurCompanyListStr + ') ', '') +
      '    GROUP BY ' +
      '      b.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      ' ' +
      '    UNION ALL ' +
      ' ' +
      '    SELECT ' +
      '      m.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey, ' +
      '      - SUM(m.debit - m.credit) AS balance ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      '    FROM ' +
      '      inv_movement m ' +
      '      JOIN inv_card c on m.cardkey = c.id ' +
        IIF(FOnlyOurRemains,
          '      JOIN gd_contact cont ON cont.id = m.contactkey ' +
          '      JOIN gd_contact head_cont ON head_cont.lb <= cont.lb AND head_cont.rb >= cont.rb ', '') +
      '    WHERE ' +
      '      m.disabled = 0 ' +
      '      AND m.movementdate > :remainsdate ' +
        IIF(FOnlyOurRemains,
          '      AND head_cont.id IN (' + OurCompanyListStr + ') ', '') +
      '    GROUP BY ' +
      '      m.contactkey, ' +
      '      c.goodkey, ' +
      '      c.companykey, ' +
      '      c.usr$inv_addlinekey ' +
        IIF(cFieldList <> '', ', ' + cFieldList, '') +
      '    ) bal ' +
      '    LEFT JOIN usr$inv_addwbillline inv_line ON inv_line.documentkey = bal.usr$inv_addlinekey ' +
      '    LEFT JOIN usr$inv_addwbill inv_doc ON inv_doc.documentkey = inv_line.masterkey ' +
      '  GROUP BY ' +
      '    bal.contactkey, ' +
      '    inv_doc.usr$contactkey, ' +
      '    bal.goodkey, ' +
      '    bal.companykey ' +
        IIF(balFieldList <> '', ', ' + balFieldList, '') +
      '  /*HAVING ' +
      '    SUM(bal.balance) >= 0*/ ' +
      '  ) move ' +
      '   LEFT JOIN gd_contact cont ON cont.id = move.contactkey ' +
      ' ORDER BY ' +
      '   cont.name, move.SupplierKey ';
    ibsql.ParamByName('REMAINSDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;                                              // Выберем все остатки ТМЦ

    LineCount := 0;
    CurrentContactKey := -1;
    CurrentSupplierKey := -1;

    // Цикл по остаткам ТМЦ
    while not ibsql.Eof do
    begin
      // При нажатии Escape прервем процесс
      if FProcessState = psTerminating then
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('Выполнение прервано')
        else
          FProcessState := psWorking;

      // Если по полю USR$INV_ADDLINEKEY карточки нашли поставщика, создадим приход остатка с него
      if not ibsql.FieldByName('SUPPLIERKEY').IsNull then
        NextSupplierKey := ibsql.FieldByName('SUPPLIERKEY').AsInteger
      else
        NextSupplierKey := FPseudoClientKey;

      // Если в цикле набрели на другой контакт, или другого поставщика,
      //   или кол-во позиций в документе превысило 2000 (оперативка не резиновая),
      //   то создадим новую шапку документа
      if (ibsql.FieldByName('CONTACTKEY').AsInteger <> CurrentContactKey)
         or (NextSupplierKey <> CurrentSupplierKey)
         or ((LineCount mod 2000) = 0) then
      begin
        // Если перешли на другой контакт
        if ibsql.FieldByName('CONTACTKEY').AsInteger <> CurrentContactKey then
        begin
          // Визуализация процесса
          // Выведем конечное число позиций предыдущего контакта
          if CurrentContactKey > 0 then
            DoOnProcessMessage(-1, -1, '  ' + IntToStr(LineCount) + ' позиций');
          DoOnProcessMessage(-1, -1, Format('> Контакт: %s', [ibsql.FieldByName('CONTACTNAME').AsString]));
          // Сбросим счетчик позиций
          LineCount := 0;
          // Запомним текущий контакт
          CurrentContactKey := ibsql.FieldByName('CONTACTKEY').AsInteger;
        end;
        // Запомним текущего поставщика
        CurrentSupplierKey := NextSupplierKey;
      end;

      // Если остаток положителен то будем делать обычный приход на CurrentContactKey с CurrentSupplierKey
      if ibsql.FieldByName('BALANCE').AsCurrency >= 0 then
      begin
        // Вставим шапку документа и получим ее ID
        DocumentParentKey := AddDepotHeader(CurrentSupplierKey, CurrentContactKey, ibsql.FieldByName('COMPANYKEY').AsInteger);
        // Создадим позицию INV_DOCUMENT
        AddDepotPosition(CurrentSupplierKey, CurrentContactKey, ibsql.FieldByName('COMPANYKEY').AsInteger,
          DocumentParentKey, ibsql.FieldByName('GOODKEY').AsInteger, ibsql.FieldByName('BALANCE').AsCurrency, ibsql);
      end
      else
      begin
        // Иначе будем делать приход на FPseudoClientKey с CurrentContactKey (с положительным значением кол-ва ТМЦ)
        DocumentParentKey := AddDepotHeader(CurrentContactKey, FPseudoClientKey, ibsql.FieldByName('COMPANYKEY').AsInteger);
        // Создадим позицию INV_DOCUMENT
        AddDepotPosition(CurrentContactKey, FPseudoClientKey, ibsql.FieldByName('COMPANYKEY').AsInteger,
          DocumentParentKey, ibsql.FieldByName('GOODKEY').AsInteger, - ibsql.FieldByName('BALANCE').AsCurrency, ibsql);
      end;

      // Увеличим счетчик позиций в одном документе
      Inc(LineCount);

      // TODO: при выборе признаков карточки которые будут подлежать сохранению, указывать поля которые ссылаются
      //   на документы подлежащие удалению, предупреждать пользователя что, при выборе таких полей может
      //   появится рассинхронизация в данных

      ibsql.Next;
    end;

    // Визуализация процесса
    DoOnProcessMessage(1, 1, 'Формирование остатков завершено...'#13#10 +
      'Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
  finally
    ibsql.Free;
  end;
end;

procedure TgdClosingPeriod.DeleteDocuments;
const
  UPDATE_INV_CARD_SET_NULL = 'UPDATE inv_card SET %0:s = NULL WHERE %0:s = :dockey;';
  //UPDATE_PACK_INV_CARD_SET_NULL = 'UPDATE inv_card SET %0:s = NULL WHERE %0:s IN (%1:s);';
  //PACK_DOCUMENT_COUNT = 100;
var
  ibsqlDocument: TIBSQL;
  ibsqlDeleteMovement: TIBSQL;
  ibsqlDeleteAddRecord: TIBSQL;
  ibsqlDeleteDocument: TIBSQL;
  ibsqlDeleteEntry: TIBSQL;
  ibsqlUpdateInvCard: TIBSQL;
  //ibsqlSavepointManager: TIBSQL;
  ibsqlBlockQuery: TIBSQL;
  DeletedCount, ErrorDocumentCount: Integer;
  I, DocumentListIndex, DontDeleteIndex: Integer;
  GDDocumentReferenceFieldList: TStringList;
  SQLText: String;
  //PackUpdateInvCardSQLText, PackEntrySQLText: String;
  R: TatRelation;
  DocumentToDelete, DocumentKeysToDelayedDelete: TgdKeyStringAssoc;
  //PackDocumentCounter: Integer;
  AddTableCounter: Integer;
  AddTableKeys: TStringList;

  procedure DeleteSingleDocument(const AID: TID; const AdditionalTableName: String; const ForceDelete: Boolean = false);
  begin
    // Удалим ссылки на удаляемый документ из полей-признаков складских карточек
    ibsqlUpdateInvCard.Close;
    ibsqlUpdateInvCard.ParamByName('DOCKEY').AsInteger := AID;
    ibsqlUpdateInvCard.ExecQuery;

    // Удалим позицию документа из дополнительной таблицы
    try
      ibsqlDeleteAddRecord.Close;
      ibsqlDeleteAddRecord.SQL.Text :=
        ' DELETE FROM ' + AdditionalTableName + ' WHERE documentkey = :dockey ';
      ibsqlDeleteAddRecord.ParamByName('DOCKEY').AsInteger := AID;
      ibsqlDeleteAddRecord.ExecQuery;
    except
      if ForceDelete then
      begin
        // Пробуем удалить ссылки на текущую запись
        TryToDeleteDocumentReferences(AID, AdditionalTableName);
        // Снова пробуем удалить запись
        ibsqlDeleteAddRecord.Close;
        ibsqlDeleteAddRecord.SQL.Text :=
          ' DELETE FROM ' + AdditionalTableName + ' WHERE documentkey = :dockey ';
        ibsqlDeleteAddRecord.ParamByName('DOCKEY').AsInteger := AID;
        ibsqlDeleteAddRecord.ExecQuery;
      end
      else
        raise;
    end;

    // Удалим проводки по этому документу
    ibsqlDeleteEntry.Close;
    ibsqlDeleteEntry.ParamByName('DOCKEY').AsInteger := AID;
    ibsqlDeleteEntry.ExecQuery;

    // Удалим складское движение по этому документу
    ibsqlDeleteMovement.Close;
    ibsqlDeleteMovement.ParamByName('DOCKEY').AsInteger := AID;
    ibsqlDeleteMovement.ExecQuery;

    // Удалим документ из GD_DOCUMENT
    try
      ibsqlDeleteDocument.Close;
      ibsqlDeleteDocument.ParamByName('DOCKEY').AsInteger := AID;
      ibsqlDeleteDocument.ExecQuery;

      DeleteRUID(AID);
    except
      on E: Exception do
      begin
        if ForceDelete then
        begin
          // Если ошибка удаления вылезла из-за ссылок на карточку, попробуем удалить эти ссылки
          if (AnsiPos('LINE_FC', E.Message) > 0)
             or (AnsiPos('INV_FK_CARD_PARENT', E.Message) > 0) then
            TryToDeleteInvCardReferences(AID);
          // Пробуем удалить ссылки на текущую запись
          TryToDeleteDocumentReferences(AID, 'GD_DOCUMENT', ibsqlDocument.FieldByName('DOCTYPEKEY').AsInteger);
          // Снова пробуем удалить запись
          ibsqlDeleteDocument.Close;
          ibsqlDeleteDocument.ParamByName('DOCKEY').AsInteger := AID;
          ibsqlDeleteDocument.ExecQuery;
        end
        else
          raise;
      end;
    end;
  end;

begin
  FLocalStartTime := Time;

  // Визуализация процесса
  DoOnProcessMessage(0, 1000, 'Удаление документов...');

  ibsqlDocument := TIBSQL.Create(Application);
  ibsqlDeleteAddRecord := TIBSQL.Create(Application);
  ibsqlDeleteMovement := TIBSQL.Create(Application);
  ibsqlDeleteDocument := TIBSQL.Create(Application);
  ibsqlDeleteEntry := TIBSQL.Create(Application);
  ibsqlUpdateInvCard := TIBSQL.Create(Application);
  //ibsqlSavepointManager := TIBSQL.Create(Application);
  ibsqlBlockQuery := TIBSQL.Create(Application);

  // Список для группового удаления документов
  DocumentToDelete := TgdKeyStringAssoc.Create;
  // Список отложенного удаления документов
  DocumentKeysToDelayedDelete := TgdKeyStringAssoc.Create;
  // Список ключей документов для группового удаления, сгруппированных по имени таблицы
  AddTableKeys := TStringList.Create;
  try
    DocumentToDelete.Sorted := False;
    DocumentKeysToDelayedDelete.Sorted := False;

    GDDocumentReferenceFieldList := TStringList.Create;
    try
      // Получим все ссылки из AC_ENTRY на GD_DOCUMENT
      R := atDatabase.Relations.ByRelationName('AC_ENTRY');
      for I := 0 to R.RelationFields.Count - 1 do
      begin
        if Assigned(R.RelationFields[I].ForeignKey) and Assigned(R.RelationFields[I].References) then
          if R.RelationFields[I].References.RelationName = 'GD_DOCUMENT' then
            GDDocumentReferenceFieldList.Add(R.RelationFields[I].FieldName);
      end;
      // Запрос на удаление проводки
      ibsqlDeleteEntry.Transaction := FWriteTransaction;
      SQLText := '';
      // Запрос будет использоваться в DeletePackDocuments
      for I := 0 to GDDocumentReferenceFieldList.Count - 1 do
      begin
        if SQLText <> '' then
        begin
          SQLText := SQLText + ' OR ';
        end;
        SQLText := SQLText + ' ( ' + GDDocumentReferenceFieldList.Strings[I] + ' = :dockey ) ';
      end;
      ibsqlDeleteEntry.SQL.Text :=
        'DELETE FROM ac_entry WHERE ' + SQLText;
      ibsqlDeleteEntry.Prepare;

      // Получим все пользовательские ссылки из INV_CARD на GD_DOCUMENT
      GDDocumentReferenceFieldList.Clear;
      R := atDatabase.Relations.ByRelationName('INV_CARD');
      for I := 0 to R.RelationFields.Count - 1 do
      begin
        if Assigned(R.RelationFields[I].ForeignKey) and Assigned(R.RelationFields[I].References) then
          if (R.RelationFields[I].References.RelationName = 'GD_DOCUMENT')
             and (R.RelationFields[I].IsUserDefined) then
            GDDocumentReferenceFieldList.Add(R.RelationFields[I].FieldName);
      end;
      // Запрос на удаление ссылок на удаляемые документы из складских карточек
      ibsqlUpdateInvCard.Transaction := FWriteTransaction;
      SQLText := #13#10;
      for I := 0 to GDDocumentReferenceFieldList.Count - 1 do
      begin
        SQLText := SQLText + Format(UPDATE_INV_CARD_SET_NULL, [GDDocumentReferenceFieldList.Strings[I]]) + #13#10;
      end;
      ibsqlUpdateInvCard.SQL.Text :=
        'EXECUTE BLOCK (dockey INTEGER = :dockey) AS BEGIN ' + SQLText + ' END ';
      ibsqlUpdateInvCard.Prepare;
    finally
      GDDocumentReferenceFieldList.Free;
    end;

    ibsqlBlockQuery.Transaction := FWriteTransaction;
    // Вытянем список документов на читающей транзакции, удалять будем на переданной
    ibsqlDocument.Transaction := gdcBaseManager.ReadTransaction;
    ibsqlDeleteAddRecord.Transaction := FWriteTransaction;
    // Запрос на удаление складского движения, относящегося к определенному документу
    ibsqlDeleteMovement.Transaction := FWriteTransaction;
    ibsqlDeleteMovement.SQL.Text :=
      ' DELETE FROM inv_movement WHERE documentkey = :dockey ';
    ibsqlDeleteMovement.Prepare;
    // Запрос на удаление документа из gd_document
    ibsqlDeleteDocument.Transaction := FWriteTransaction;
    ibsqlDeleteDocument.SQL.Text :=
      ' DELETE FROM gd_document WHERE id = :dockey ';
    ibsqlDeleteDocument.Prepare;
    // создание\уничтожение savepoint
    //ibsqlSavepointManager.Transaction := FWriteTransaction;

    // Запрос на получение складского движения, пытаемся упорядочить движение по времени создания,
    //   начиная с новейших записей
    ibsqlDocument.SQL.Text :=
      'SELECT ' +
      '  doc.documentdate, ' +
      '  doc.creationdate, ' +
      '  doc.documenttypekey AS doctypekey, ' +
      '  doc.id AS documentkey, ' +
      '  IIF(doc.parent IS NULL, 0, 1) AS is_position, ' +
      '  IIF(doc.parent IS NULL, headtable.relationname, linetable.relationname) AS addtablename ' +
      'FROM ' +
      '  gd_document doc ' +
      '  LEFT JOIN gd_documenttype t ON t.id = doc.documenttypekey ' +
      '  LEFT JOIN at_relations headtable ON headtable.id = t.headerrelkey ' +
      '  LEFT JOIN at_relations linetable ON linetable.id = t.linerelkey ' +
      'WHERE ' +
      '  doc.documentdate < :closedate ' +
      '  AND t.classname = ''TgdcInvDocumentType'' ' +
      '  AND t.documenttype = ''D'' ' +
      '  AND NOT headtable.id IS NULL ' +
      '  AND NOT linetable.id IS NULL ' +
      'ORDER BY ' +
      '  doc.documentdate DESC, 4 DESC, doc.creationdate DESC, doc.id DESC ';
    ibsqlDocument.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlDocument.ExecQuery;

    DeletedCount := 0;
    ErrorDocumentCount := 0;

    // Цикл по найденным документам, подлежащим удалению
    while not ibsqlDocument.Eof do
    begin
      // При нажатии Escape прервем процесс
      if FProcessState = psTerminating then
      begin
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
        begin
          // Выведем список документов, которые не получилось удалить
          if DocumentKeysToDelayedDelete.Count > 0 then
            DoOnProcessMessage(-1, -1, 'Не удаленные документы:');
          I := 0;
          while (I <= DocumentKeysToDelayedDelete.Count - 1) do
          begin
            try
              // Пробуем удалить документ
              DeleteSingleDocument(DocumentKeysToDelayedDelete.Keys[I],
                DocumentKeysToDelayedDelete.ValuesByIndex[I], True);
              // Удаляем документ из списка отложенных
              DocumentKeysToDelayedDelete.Delete(I);
            except
              on E: Exception do
              begin
                DoOnProcessMessage(-1, -1, E.Message + #13#10 +
                  DocumentKeysToDelayedDelete.ValuesByIndex[I] +
                  ' ( ' + IntToStr(DocumentKeysToDelayedDelete.Keys[I]) + ' )');
                Inc(I);  
              end;
            end;
          end;

          raise Exception.Create('Выполнение прервано');
        end
        else
          FProcessState := psWorking;
      end;

      // Проверим можно ли удалять документ
      if not FDontDeleteCardArray.Find(ibsqlDocument.FieldByName('DOCUMENTKEY').AsInteger, DontDeleteIndex) then
      begin
        // Удалим текущий документ и его проводки
        try
          // Пробуем удалить документ
          DeleteSingleDocument(ibsqlDocument.FieldByName('DOCUMENTKEY').AsInteger,
            ibsqlDocument.FieldByName('ADDTABLENAME').AsString, True);
          Inc(DeletedCount);
        except
          // Обрабатываем ошибку удаления документа
          on E: Exception do
          begin
            // Занесем документ в список отложенного удаления
            DocumentListIndex := DocumentKeysToDelayedDelete.Add(ibsqlDocument.FieldByName('DOCUMENTKEY').AsInteger);
            DocumentKeysToDelayedDelete.ValuesByIndex[DocumentListIndex] := ibsqlDocument.FieldByName('ADDTABLENAME').AsString;

            Inc(ErrorDocumentCount);
          end;
        end;

        if (DeletedCount > 0) and (DeletedCount mod 5000 = 0) then
        begin
          // Рестартанем транзакцию
          FWriteTransaction.Commit;
          FWriteTransaction.StartTransaction;
        end;

        // Каждые 50000 документов будем запускать отложенное удаление
        if (DeletedCount > 0) and (DeletedCount mod 50000 = 0) then
        begin
          DoOnProcessMessage(-1, -1, 'Ошибок: ' + IntToStr(ErrorDocumentCount));

          I := 0;
          while (I <= DocumentKeysToDelayedDelete.Count - 1) do
          begin
            try
              // Пробуем удалить документ
              DeleteSingleDocument(DocumentKeysToDelayedDelete.Keys[I],
                DocumentKeysToDelayedDelete.ValuesByIndex[I], True);
              Inc(DeletedCount);
              Dec(ErrorDocumentCount);
              // Удаляем документ из списка отложенных
              DocumentKeysToDelayedDelete.Delete(I);
            except
              Inc(I);
              // Если не получилось удалить, то ничего не делаем - пробуем удалить в следующий раз
            end;
          end;
        end;

        // Визуализация процесса
        DoOnProcessMessage(DeletedCount, -1, '');
      end;

      // Перейдем к следующему документу
      ibsqlDocument.Next;
    end;

    // Последний раз пробуем удалить отложенные документы
    if DocumentKeysToDelayedDelete.Count > 0 then
      DoOnProcessMessage(-1, -1, 'Не удаленные документы:');
    I := 0;
    while (I <= DocumentKeysToDelayedDelete.Count - 1) do
    begin
      try
        // Пробуем удалить документ
        DeleteSingleDocument(DocumentKeysToDelayedDelete.Keys[I],
          DocumentKeysToDelayedDelete.ValuesByIndex[I], True);
        Inc(DeletedCount);
        Dec(ErrorDocumentCount);
        // Удаляем документ из списка отложенных
        DocumentKeysToDelayedDelete.Delete(I);
      except
        on E: Exception do
        begin
          DoOnProcessMessage(-1, -1, E.Message + #13#10 +
            DocumentKeysToDelayedDelete.ValuesByIndex[I] +
            ' ( ' + IntToStr(DocumentKeysToDelayedDelete.Keys[I]) + ' )');
          Inc(I);
        end;
      end;
    end;

    // Визуализация процесса
    DoOnProcessMessage(DeletedCount, DeletedCount, '');
    DoOnProcessMessage(-1, -1, TimeToStr(Time) + ': Завершен процесс удаления документов...'#13#10 +
      IntToStr(DeletedCount) + ' удалено, ' + IntToStr(ErrorDocumentCount) + ' ошибок'#13#10 +
      'Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
  finally
    for AddTableCounter := 0 to AddTableKeys.Count - 1 do
      if Assigned(AddTableKeys.Objects[AddTableCounter]) then
        AddTableKeys.Objects[AddTableCounter].Free;
    FreeAndNil(AddTableKeys);
    FreeAndNil(DocumentKeysToDelayedDelete);
    FreeAndNil(DocumentToDelete);

    FreeAndNil(ibsqlBlockQuery);
    FreeAndNil(ibsqlUpdateInvCard);
    FreeAndNil(ibsqlDeleteEntry);
    FreeAndNil(ibsqlDeleteAddRecord);
    FreeAndNil(ibsqlDeleteDocument);
    FreeAndNil(ibsqlDeleteMovement);
    FreeAndNil(ibsqlDocument);
  end;
end;

procedure TgdClosingPeriod.DeleteEntry;
var
  ibsql: TIBSQL;
begin
  FLocalStartTime := Time;

  // Визуализация процесса
  DoOnProcessMessage(0, 1, 'Удаление проводок...');

  ibsql := TIBSQL.Create(Application);
  try
    ibsql.Transaction := FWriteTransaction;
    ibsql.SQL.Text := 'DELETE FROM ac_entry WHERE entrydate < :closedate ';
    ibsql.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;
  finally
    ibsql.Free;
  end;

  // Визуализация процесса
  DoOnProcessMessage(1, 1, 'Удаление проводок завершено'#13#10 +
    'Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
end;

procedure TgdClosingPeriod.DeleteUserDocuments;
var
  ibsqlSelectDocument: TIBSQL;
  ibsqlDeleteDocument, ibsqlDeleteUserRecord: TIBSQL;
  DocumentTypeCounter: Integer;
  DocumentTypeListStr: String;
  CurrentRelationName, NextRelationName: String;
  CurrentDocumentKey: Integer;
begin
  FLocalStartTime := Time;

  // Визуализация процесса
  DoOnProcessMessage(0, 1, 'Удаление пользовательских документов...');

  // Если выбран хотя бы один тип пользовательских документов
  if FUserDocumentTypesToDelete.Count > 0 then
  begin
    // Сформируем строку с ID типов пользовательских документов
    for DocumentTypeCounter := 0 to FUserDocumentTypesToDelete.Count - 1 do
    begin
      if DocumentTypeListStr <> '' then
        DocumentTypeListStr := DocumentTypeListStr + ', ';
      DocumentTypeListStr := DocumentTypeListStr + IntToStr(FUserDocumentTypesToDelete.Keys[DocumentTypeCounter]);
    end;

    ibsqlSelectDocument := TIBSQL.Create(Application);
    ibsqlDeleteDocument := TIBSQL.Create(Application);
    ibsqlDeleteUserRecord := TIBSQL.Create(Application);
    try
      // Запрос для удаления записи из gd_document по переданному ID
      ibsqlDeleteDocument.Transaction := FWriteTransaction;
      ibsqlDeleteDocument.SQL.Text := 'DELETE FROM gd_document WHERE id = :documentkey';
      ibsqlDeleteDocument.Prepare;

      ibsqlDeleteUserRecord.Transaction := FWriteTransaction;

      // Запрос выбирает пользовательские документы переданных типов, которые созданы до даты закрытия
      //   сортирует их в порядке убывания по дате, потом по ID
      ibsqlSelectDocument.Transaction := FWriteTransaction;
      ibsqlSelectDocument.SQL.Text := Format(
        'SELECT ' +
        '  d.id AS documentkey, ' +
        '  IIF(d.parent IS NULL, h_rel.relationname, l_rel.relationname) AS add_rel_name ' +
        'FROM ' +
        '  gd_document d ' +
        '  LEFT JOIN gd_documenttype t ON t.id = d.documenttypekey ' +
        '  LEFT JOIN at_relations h_rel ON h_rel.id = t.headerrelkey ' +
        '  LEFT JOIN at_relations l_rel ON l_rel.id = t.linerelkey ' +
        'WHERE ' +
        '  d.documentdate < :closedate ' +
        '  AND d.documenttypekey IN (%0:s) ' +
        '  AND NOT t.headerrelkey IS NULL ' +
        'ORDER BY ' +
        '  d.documentdate DESC, d.id DESC', [DocumentTypeListStr]);
      ibsqlSelectDocument.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
      ibsqlSelectDocument.ExecQuery;

      CurrentRelationName := '';
      while not ibsqlSelectDocument.Eof do
      begin
        CurrentDocumentKey := ibsqlSelectDocument.FieldByName('DOCUMENTKEY').AsInteger;
        NextRelationName := ibsqlSelectDocument.FieldByName('ADD_REL_NAME').AsString;
        if CurrentRelationName <> NextRelationName then
        begin
          CurrentRelationName := NextRelationName;
          ibsqlDeleteUserRecord.Close;
          ibsqlDeleteUserRecord.SQL.Text :=
            Format('DELETE FROM %0:s WHERE documentkey = :documentkey', [CurrentRelationName]);
          ibsqlDeleteUserRecord.Prepare;
        end;

        // Удалим запись из пользовательской таблицы
        try
          ibsqlDeleteUserRecord.Close;
          ibsqlDeleteUserRecord.ParamByName('DOCUMENTKEY').AsInteger := CurrentDocumentKey;
          ibsqlDeleteUserRecord.ExecQuery;
        except
          // Пробуем удалить ссылки на текущую запись
          TryToDeleteDocumentReferences(CurrentDocumentKey, CurrentRelationName);
        end;
        // Удалим запись из gd_document
        try
          ibsqlDeleteDocument.Close;
          ibsqlDeleteDocument.ParamByName('DOCUMENTKEY').AsInteger := CurrentDocumentKey;
          ibsqlDeleteDocument.ExecQuery;

          DeleteRUID(CurrentDocumentKey);
        except
          // Пробуем удалить ссылки на текущую запись
          TryToDeleteDocumentReferences(CurrentDocumentKey, 'GD_DOCUMENT');
        end;

        ibsqlSelectDocument.Next;
      end;
    finally
      ibsqlDeleteUserRecord.Free;
      ibsqlDeleteDocument.Free;
      ibsqlSelectDocument.Free;
    end;
  end;

  // Визуализация процесса
  DoOnProcessMessage(1, 1, 'Завершен процесс удаления пользовательских документов...'#13#10 +
    'Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
end;

procedure TgdClosingPeriod.DoClosePeriod;
begin
  // Создадим нить вызывающую процедуры закрытия
  FWorkingThread := TgdClosingThread.Create(True);             
  TgdClosingThread(FWorkingThread).Model := Self;
  FWorkingThread.FreeOnTerminate := True;
  FWorkingThread.Priority := tpLower;
  FWorkingThread.Resume;
end;

{procedure TgdClosingPeriod.InsertDatabaseRecord;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := FWriteTransaction;
    ibsql.SQL.Text :=
      'INSERT INTO db_closehistory (databasepath, server, username, userpassword, closedate) ' +
      'VALUES (:path, :server, :username, :userpassword, :closedate) ';
    ibsql.ParamByName('PATH').AsString := FExtDatabasePath;
    ibsql.ParamByName('SERVER').AsString := FExtDatabaseServer;
    ibsql.ParamByName('USERNAME').AsString := FExtDatabaseUser;
    ibsql.ParamByName('USERPASSWORD').AsString := FExtDatabasePassword;
    ibsql.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;
  finally
    ibsql.Free;
  end;
end;}

procedure TgdClosingPeriod.ReBindDepotCards;
const
  UPDATE_DOCUMENT_CARDKEY_TEMPLATE =
    'UPDATE ' +
    '  %0:s line ' +
    'SET ' +
    '  line.%1:s = :new_cardkey ' +
    'WHERE ' +
    '  line.%1:s = :old_cardkey ' +
    '  AND (SELECT doc.documentdate FROM gd_document doc WHERE doc.id = line.documentkey) >= :closedate ';
  CardkeyFieldCount = 2;
  CardkeyFieldNames: array[0..CardkeyFieldCount - 1] of String = ('FROMCARDKEY', 'TOCARDKEY');
var
  ibsql: TIBSQL;
  ibsqlSearchNewCardkey: TIBSQL;
  ibsqlUpdateCard: TIBSQL;
  ibsqlUpdateFirstDocKey: TIBSQL;
  ibsqlUpdateInvMovement: TIBSQL;
  ibsqlUpdateDocumentCardkey: TIBSQL;
  CurrentCardKey, CurrentFirstDocKey, CurrentFromContactkey, CurrentToContactkey: Integer;
  CurrentRelationName: String;
  DocumentParentKey: TID;
  NewCardKey, FirstDocumentKey: Integer;
  FirstDate: TDateTime;
  FeatureCounter, RecordCounter: Integer;
  cFeatureList: String;

  procedure UpdateInvCard(const OldCardkey, NewCardkey: TID);
  begin
    // обновим ссылку на родительскую карточку
    ibsqlUpdateCard.ParamByName('OLD_PARENT').AsInteger := OldCardkey;
    ibsqlUpdateCard.ParamByName('NEW_PARENT').AsInteger := NewCardkey;
    ibsqlUpdateCard.ExecQuery;
    ibsqlUpdateCard.Close;
  end;

  procedure UpdateFirstDocKey(const OldDocKey, NewDocKey: TID; const NewDocDate: TDateTime);
  begin
    if NewDocKey > -1 then
    begin
      // обновим ссылку на родительскую карточку
      ibsqlUpdateFirstDocKey.ParamByName('OLDDOCKEY').AsInteger := OldDocKey;
      ibsqlUpdateFirstDocKey.ParamByName('NEWDOCKEY').AsInteger := NewDocKey;
      ibsqlUpdateFirstDocKey.ParamByName('NEWDATE').AsDateTime := NewDocDate;
      ibsqlUpdateFirstDocKey.ExecQuery;
      ibsqlUpdateFirstDocKey.Close;
    end;  
  end;

  procedure UpdateInvMovement(const OldCardkey, NewCardkey: TID);
  begin
    // обновим ссылки на карточки из движения
    ibsqlUpdateInvMovement.ParamByName('OLD_CARDKEY').AsInteger := OldCardkey;
    ibsqlUpdateInvMovement.ParamByName('NEW_CARDKEY').AsInteger := NewCardkey;
    ibsqlUpdateInvMovement.ExecQuery;
    ibsqlUpdateInvMovement.Close;
  end;

  procedure UpdateDocumentCardkey(const RelationName: String; const OldCardkey, NewCardkey: TID);
  var
    I: Integer;
  begin
    for I := 0 to CardkeyFieldCount - 1 do
    begin
      if Assigned(atDatabase.FindRelationField(RelationName, CardkeyFieldNames[I])) then
      begin
        ibsqlUpdateDocumentCardkey.SQL.Text := Format(UPDATE_DOCUMENT_CARDKEY_TEMPLATE,
          [RelationName, CardkeyFieldNames[I]]);
        ibsqlUpdateDocumentCardkey.ParamByName('OLD_CARDKEY').AsInteger := OldCardkey;
        ibsqlUpdateDocumentCardkey.ParamByName('NEW_CARDKEY').AsInteger := NewCardkey;
        ibsqlUpdateDocumentCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
        ibsqlUpdateDocumentCardkey.ExecQuery;
        ibsqlUpdateDocumentCardkey.Close;
      end;
    end;
  end;

begin
  InitializeIBSQLQueries;
  
  FLocalStartTime := Time;

  // Визуализация процесса
  DoOnProcessMessage(0, 35000, 'Перепривязка складских карточек...');

  ibsql := TIBSQL.Create(Application);
  ibsqlSearchNewCardkey := TIBSQL.Create(Application);
  ibsqlUpdateCard := TIBSQL.Create(Application);
  ibsqlUpdateFirstDocKey := TIBSQL.Create(Application);
  ibsqlUpdateInvMovement := TIBSQL.Create(Application);
  ibsqlUpdateDocumentCardkey := TIBSQL.Create(Application);
  try
    // обновляет ссылку на родительскую карточку
    ibsqlUpdateCard.Transaction := FWriteTransaction;
    ibsqlUpdateCard.SQL.Text :=
      'UPDATE ' +
      '  inv_card c ' +
      'SET ' +
      '  c.parent = :new_parent ' +
      'WHERE ' +
      '  c.parent = :old_parent ' +
      '  AND (SELECT FIRST(1) m.movementdate ' +
      '       FROM inv_movement m ' +
      '       WHERE m.cardkey = c.id ' +
      '       ORDER BY m.movementdate DESC) >= :closedate ';
    ibsqlUpdateCard.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlUpdateCard.Prepare;
    // Обновляет ссылку на документ прихода и дату прихода
    ibsqlUpdateFirstDocKey.Transaction := FWriteTransaction;
    ibsqlUpdateFirstDocKey.SQL.Text :=
      'UPDATE inv_card c ' +
      'SET ' +
      '  c.firstdocumentkey = :newdockey, ' +
      '  c.firstdate = :newdate ' +
      'WHERE ' +
      '  c.firstdocumentkey = :olddockey ';
    ibsqlUpdateFirstDocKey.Prepare;
    // обновляет в движении ссылки на складские карточки
    ibsqlUpdateInvMovement.Transaction := FWriteTransaction;
    ibsqlUpdateInvMovement.SQL.Text :=
      'UPDATE ' +
      '  inv_movement m ' +
      'SET ' +
      '  m.cardkey = :new_cardkey ' +
      'WHERE ' +
      '  m.cardkey = :old_cardkey ' +
      '  AND m.movementdate >= :closedate ';
    ibsqlUpdateInvMovement.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlUpdateInvMovement.Prepare;
    // обновляет в дополнительнных таблицах складских документов ссылки на складские карточки
    ibsqlUpdateDocumentCardkey.Transaction := FWriteTransaction;

    // находит подходящую карточку в документе остатков
    ibsqlSearchNewCardkey.Transaction := FWriteTransaction;

    // Получим список выбранных признаков складской карточки
    cFeatureList := GetFeatureFieldList('c.');
    // выбирает все карточки которые находятся в движении во время закрытия
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text :=
      'SELECT' + #13#10 +
      '  m1.contactkey as fromcontactkey,' + #13#10 +
      '  m.contactkey as tocontactkey,' + #13#10 +
      '  linerel.relationname,' + #13#10 +
      '  c.id AS cardkey_new, ' + #13#10 +
      '  c1.id as cardkey_old,' + #13#10 +
      '  c.goodkey,' + #13#10 +
      '  c.companykey, c.firstdocumentkey' + #13#10 +
        IIF(cFeatureList <> '', ', ' + cFeatureList + #13#10, '') +
      'FROM' + #13#10 +
      '  gd_document d' + #13#10 +
      '  JOIN gd_documenttype t ON t.id = d.documenttypekey' + #13#10 +
      '  LEFT JOIN inv_movement m ON m.documentkey = d.id' + #13#10 +
      '  LEFT JOIN inv_movement m1 ON m1.movementkey = m.movementkey AND m1.id <> m.id' + #13#10 +
      '  LEFT JOIN inv_card c ON c.id = m.cardkey' + #13#10 +
      '  LEFT JOIN inv_card c1 ON c1.id = m1.cardkey' + #13#10 +
      '  LEFT JOIN gd_document d_old ON ((d_old.id = c.documentkey) or (d_old.id = c1.documentkey))' + #13#10 +
      '  LEFT JOIN at_relations linerel ON linerel.id = t.linerelkey' + #13#10 +
      'WHERE' + #13#10 +
      '  d.documentdate >= :closedate' + #13#10 +
      '  AND t.classname = ''TgdcInvDocumentType''' + #13#10 +
      '  AND t.documenttype = ''D''' + #13#10 +
      '  AND d_old.documentdate < :closedate';
    ibsql.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsql.ExecQuery;

    RecordCounter := 0;
    FirstDocumentKey := -1;
    FirstDate := FCloseDate;
    while not ibsql.Eof do
    begin
      // При нажатии Escape прервем процесс
      if FProcessState = psTerminating then
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('Выполнение прервано')
        else
          FProcessState := psWorking;

      // Визуализация процесса
      Inc(RecordCounter);
      DoOnProcessMessage(RecordCounter, -1, '');

      if ibsql.FieldByName('CARDKEY_OLD').IsNull then
        CurrentCardKey := ibsql.FieldByName('CARDKEY_NEW').AsInteger
      else
        CurrentCardKey := ibsql.FieldByName('CARDKEY_OLD').AsInteger;
      CurrentFirstDocKey := ibsql.FieldByName('FIRSTDOCUMENTKEY').AsInteger;
      CurrentFromContactkey := ibsql.FieldByName('FROMCONTACTKEY').AsInteger;
      CurrentToContactkey := ibsql.FieldByName('TOCONTACTKEY').AsInteger;
      CurrentRelationName := ibsql.FieldByName('RELATIONNAME').AsString;

      if (CurrentFromContactkey > 0) or (CurrentToContactkey > 0) then
      begin
        // Поищем подходящую карточку для замены удаляемой
        ibsqlSearchNewCardkey.SQL.Text := SEARCH_NEW_CARDKEY_TEMPLATE;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s = :%0:s ', [FFeatureList.Strings[FeatureCounter]])
          else
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s IS NULL ', [FFeatureList.Strings[FeatureCounter]]);
        end;
        ibsqlSearchNewCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
        ibsqlSearchNewCardkey.ParamByName('GOODKEY').AsInteger := ibsql.FieldByName('GOODKEY').AsInteger;
        ibsqlSearchNewCardkey.ParamByName('CONTACT_01').AsInteger := CurrentFromContactkey;
        ibsqlSearchNewCardkey.ParamByName('CONTACT_02').AsInteger := CurrentToContactkey;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.ParamByName(FFeatureList.Strings[FeatureCounter]).AsVariant :=
              ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).AsVariant;
        end;
        ibsqlSearchNewCardkey.ExecQuery;

        // Если мы нашли подходящую карточку, созданную документом остатков INV_DOCUMENT
        if ibsqlSearchNewCardkey.RecordCount > 0 then
        begin
          NewCardKey := ibsqlSearchNewCardkey.FieldByName('CARDKEY').AsInteger;
          FirstDocumentKey := ibsqlSearchNewCardkey.FieldByName('FIRSTDOCUMENTKEY').AsInteger;
          FirstDate := ibsqlSearchNewCardkey.FieldByName('FIRSTDATE').AsDateTime;
        end
        else
        begin
          // Поищем карточку без доп. признаков
          ibsqlSearchNewCardkey.Close;
          ibsqlSearchNewCardkey.SQL.Text := SEARCH_NEW_CARDKEY_TEMPLATE;
          ibsqlSearchNewCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
          ibsqlSearchNewCardkey.ParamByName('GOODKEY').AsInteger := ibsql.FieldByName('GOODKEY').AsInteger;
          ibsqlSearchNewCardkey.ParamByName('CONTACT_01').AsInteger := CurrentFromContactkey;
          ibsqlSearchNewCardkey.ParamByName('CONTACT_02').AsInteger := CurrentToContactkey;
          ibsqlSearchNewCardkey.ExecQuery;

          if ibsqlSearchNewCardkey.RecordCount > 0 then
          begin
            NewCardKey := ibsqlSearchNewCardkey.FieldByName('CARDKEY').AsInteger;
            FirstDocumentKey := ibsqlSearchNewCardkey.FieldByName('FIRSTDOCUMENTKEY').AsInteger;
            FirstDate := ibsqlSearchNewCardkey.FieldByName('FIRSTDATE').AsDateTime;
          end
          else
          begin
            // Иначе вставим документ нулевого прихода, и перепривяжем на созданную им карточку
            DocumentParentKey := AddDepotHeader(CurrentFromContactkey, CurrentFromContactkey, ibsql.FieldByName('COMPANYKEY').AsInteger);
            NewCardKey := AddDepotPosition(CurrentFromContactkey, CurrentFromContactkey, ibsql.FieldByName('COMPANYKEY').AsInteger,
              DocumentParentKey, ibsql.FieldByName('GOODKEY').AsInteger, 0);

            DoOnProcessMessage(-1, -1, Format('  Создан документ нулевого прихода ID = %0:d', [DocumentParentKey]));
          end;
        end;
        ibsqlSearchNewCardkey.Close;
      end
      else
      begin
        // Поищем подходящую карточку для замены удаляемой
        ibsqlSearchNewCardkey.SQL.Text := SEARCH_NEW_CARDKEY_TEMPLATE_SIMPLE;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s = :%0:s ', [FFeatureList.Strings[FeatureCounter]])
          else
            ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
              Format(' AND card.%0:s IS NULL ', [FFeatureList.Strings[FeatureCounter]]);
        end;
        ibsqlSearchNewCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
        ibsqlSearchNewCardkey.ParamByName('DOCTYPEKEY').AsInteger := FInvDocumentTypeKey;
        ibsqlSearchNewCardkey.ParamByName('GOODKEY').AsInteger := ibsql.FieldByName('GOODKEY').AsInteger;
        for FeatureCounter := 0 to FFeatureList.Count - 1 do
        begin
          if not ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
            ibsqlSearchNewCardkey.ParamByName(FFeatureList.Strings[FeatureCounter]).AsVariant :=
              ibsql.FieldByName(FFeatureList.Strings[FeatureCounter]).AsVariant;
        end;
        ibsqlSearchNewCardkey.ExecQuery;

        if ibsqlSearchNewCardkey.RecordCount > 0 then
          NewCardKey := ibsqlSearchNewCardkey.FieldByName('CARDKEY').AsInteger
        else
          NewCardKey := -1;
          
        ibsqlSearchNewCardkey.Close;
      end;

      if NewCardKey > 0 then
      begin
        UpdateInvCard(CurrentCardKey, NewCardKey);                                // обновим ссылку на родительскую карточку
        UpdateFirstDocKey(CurrentFirstDocKey, FirstDocumentKey, FirstDate);       // обновим ссылку на документ прихода и дату прихода
        UpdateInvMovement(CurrentCardKey, NewCardKey);                            // обновим ссылки на карточки из движения
        UpdateDocumentCardkey(CurrentRelationName, CurrentCardKey, NewCardKey);   // обновим ссылки на карточки в складских документах
      end
      else
      begin
        DoOnProcessMessage(-1, -1, Format('  Ошибка перепривязки карточки OLD_CARDKEY = %0:d', [CurrentCardKey]));
      end;

      ibsql.Next;
    end;

    // Визуализация процесса
    DoOnProcessMessage(RecordCounter, RecordCounter,
      'Завершен процесс перепривязки складских карточек...'#13#10 +
      'Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
  finally
    ibsqlUpdateDocumentCardkey.Free;
    ibsqlUpdateInvMovement.Free;
    ibsqlUpdateFirstDocKey.Free;
    ibsqlUpdateCard.Free;
    ibsqlSearchNewCardkey.Free;
    ibsql.Free;
  end;
end;

procedure TgdClosingPeriod.SetTriggerActive(SetActive: Boolean);
const
  AlterTriggerCount = 4;
  // Отключим INV_BU_CARD из-за ошибки Too many concurrent executions of the same request при обновлении
  //  parent карточек
  AlterTriggerArray: array[0 .. AlterTriggerCount - 1] of String =
    ('INV_BD_MOVEMENT', 'INV_BU_MOVEMENT', 'AC_ENTRY_DO_BALANCE', 'INV_BU_CARD');
var
  ibsql: TIBSQL;
  WasActive: Boolean;
  StateStr: String;
  I: Integer;
begin
  WasActive := FWriteTransaction.Active;
  // Активацию\деактивацию триггеров проводим на отдельной транзакции
  if WasActive then
    FWriteTransaction.Commit;
  FWriteTransaction.StartTransaction;

  if SetActive then
  begin
    StateStr := 'ACTIVE';
    DoOnProcessMessage(-1, -1, 'Активация триггеров');
  end
  else
  begin
    StateStr := 'INACTIVE';
    DoOnProcessMessage(-1, -1, 'Деактивация триггеров');
  end;

  ibsql := TIBSQL.Create(Application);
  try
    ibsql.Transaction := FWriteTransaction;

    for I := 0 to AlterTriggerCount - 1 do
    begin
      ibsql.SQL.Text := 'ALTER TRIGGER ' + AlterTriggerArray[I] + ' '  + StateStr;
      ibsql.ExecQuery;
      ibsql.Close;
    end;
  finally
    ibsql.Free;
  end;

  FWriteTransaction.Commit;
  if WasActive then
    FWriteTransaction.StartTransaction;
end;

procedure TgdClosingPeriod.TryToDeleteDocumentReferences(const AID: TID;
  const AdditionalRelationName: String; const ADocTypeKey: Integer = -1);
var
  TableReferenceIndex: Integer;
  OL: TObjectList;
  ibsql, ibsqlUpdate, ibsqlSelect: TIBSQL;
  ReferencesRelationName, ReferencesFieldName: String;
  AdditionalFieldName: String;
  ForeignKeyCounter: Integer;
begin
  // Заполним для переданной таблицы список внешних ключей, если его еще нет
  if not FTableReferenceForeignKeysList.Find(AdditionalRelationName, TableReferenceIndex) then
  begin
    // Создадим новый список внешних ключей ссылающихся на переданную таблицу
    TableReferenceIndex := FTableReferenceForeignKeysList.AddObject(AdditionalRelationName, TObjectList.Create(False));
    OL := TObjectList.Create(False);
    try
      // Получим список внешних ключей ссылающихся на переданную таблицу
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation(AdditionalRelationName, OL);
      // Возьмем только простые внешние ключи
      for ForeignKeyCounter := 0 to OL.Count - 1 do
      begin
        if TatForeignKey(OL.Items[ForeignKeyCounter]).IsSimpleKey
           and TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.IsUserDefined then
          TObjectList(FTableReferenceForeignKeysList.Objects[TableReferenceIndex]).Add(OL.Items[ForeignKeyCounter]);
      end;
    except
      OL.Free;
    end;
  end;

  // Пройдем по списку внешних ключей, и поищем записи ссылающиеся на переданную
  OL := TObjectList(FTableReferenceForeignKeysList.Objects[TableReferenceIndex]);
  ibsql := TIBSQL.Create(Application);
  ibsqlUpdate := TIBSQL.Create(Application);
  ibsqlSelect := TIBSQL.Create(Application);
  try
    ibsql.Transaction := FWriteTransaction;
    ibsqlUpdate.Transaction := FWriteTransaction;
    ibsqlSelect.Transaction := FWriteTransaction;
    // Цикл по внешним ключам
    for ForeignKeyCounter := 0 to OL.Count - 1 do
    begin
      // Имя таблицы которая содержит ссылку на переданную запись
      ReferencesRelationName := TatForeignKey(OL[ForeignKeyCounter]).Relation.RelationName;
      // Имя поля-ссылки на переданную запись
      ReferencesFieldName := TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.FieldName;
      // Имя поля из таблицы AdditionalRelationName на которое ссылается ReferencesFieldName
      AdditionalFieldName := TatForeignKey(OL.Items[ForeignKeyCounter]).ReferencesField.FieldName;
      // Найдем записи ссылающиеся на переданную запись в таблице по текущему внешнему ключу
      ibsql.Close;
      ibsql.SQL.Text := Format('SELECT * FROM %0:s WHERE %1:s = :aid', [ReferencesRelationName, ReferencesFieldName]);
      ibsql.ParamByName('AID').AsInteger := AID;
      ibsql.ExecQuery;
      // Если нашли запись
      if ibsql.RecordCount > 0 then
      begin
        // Если поле-ссылку можно обнулить, сделаем это.
        // Иначе поставим ссылку на заглушку такого же типа
        if TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.IsNullable then
        begin
          ibsqlUpdate.Close;
          ibsqlUpdate.SQL.Text := Format('UPDATE %0:s SET %1:s = NULL WHERE %1:s = :aid', [ReferencesRelationName, ReferencesFieldName]);
          ibsqlUpdate.ParamByName('AID').AsInteger := AID;
          ibsqlUpdate.ExecQuery;
        end
        else
        begin
          if ADocTypeKey <> -1 then
          begin
            ibsqlUpdate.Close;
            ibsqlUpdate.SQL.Text := Format('UPDATE %0:s SET %1:s = :newkey WHERE %1:s = :aid', [ReferencesRelationName, ReferencesFieldName]);
            ibsqlUpdate.ParamByName('AID').AsInteger := AID;
            ibsqlUpdate.ParamByName('NEWKEY').AsInteger := CreateDummyInvDocument(ADocTypeKey);
            ibsqlUpdate.ExecQuery;
          end  
          else
            DoOnProcessMessage(-1, -1, Format('NOT NULL: %1:s(%2:s) -> %0:s',
              [AdditionalRelationName, ReferencesRelationName, ReferencesFieldName]));
        end;
      end;
    end;
  finally
    ibsqlSelect.Free;
    ibsqlUpdate.Free; 
    ibsql.Free;
  end;
end;

function TgdClosingPeriod.GetFeatureFieldList(AAlias: String): String;
var
  I: Integer;
begin
  Result := '';
  // Пройдем по списку выбранных признаков
  for I := 0 to FFeatureList.Count - 1 do
  begin
    if Result <> '' then
      Result := Result + ', ';
    // Подставим следующее имя поля
    Result := Result + AAlias + FFeatureList.Strings[i];
  end;
end;

function TgdClosingPeriod.IIF(const Condition: Boolean; const TrueString, FalseString: String): String;
begin
  if Condition then
    Result := TrueString
  else
    Result := FalseString;
end;

procedure TgdClosingPeriod.CalculateEntryBalance;
const
  ibMainBegin =
    ' SELECT ' +
    '  companykey, ' +
    '  accountkey, ' +
    '  currkey, ' +
    '  SUM(debitncu) AS DebitNCU, ' +
    '  SUM(creditncu) AS CreditNCU, ' +
    '  SUM(debitcurr) AS DebitCURR, ' +
    '  SUM(creditcurr) AS CreditCURR, ' +
    '  SUM(debiteq) AS Debiteq, ' +
    '  SUM(crediteq) AS Crediteq ';
  ibMainMiddle =
    ' FROM ' +
    '  ac_entry ' +
    ' WHERE ' +
    '  accountkey = :acckey ' +
    '  AND entrydate < :balancedate ' +
    ' GROUP BY ' +
    '  companykey, ' +
    '  accountkey, ' +
    '  currkey ';
  ibMainEnd =
    ' HAVING ' +
    '   SUM(debitncu - creditncu) <> 0 ' +
    '   OR SUM(debitcurr - creditcurr) <> 0 ' +
    '   OR SUM(debiteq - crediteq) <> 0 ';
  ibWriteBegin =
    ' INSERT INTO ac_entry_balance ' +
    ' (companykey, accountkey, currkey, debitncu, creditncu, debitcurr, creditcurr, debiteq, crediteq ';
  ibWriteValues =
    ') VALUES (:companykey, :accountkey, :currkey, :debitncu, :creditncu, :debitcurr, :creditcurr, :debiteq, :crediteq ';

var
  ibsql: TIBSQL;
  ibsqlAccount: TIBSQL;
  AnalyticCounter: Integer;
  Analytics: String;
  BalanceAnalytics, InsertAnalytics: String;
  RecordCounter: Integer;
begin
  FLocalStartTime := Time;

  // Визуализация процесса
  DoOnProcessMessage(-1, -1, 'Вычисление бухгалтерских остатков...');

  // Занесем названия всех полей-аналитик в строку
  Analytics := '';
  for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
  begin
    if Analytics <> '' then
      Analytics := Analytics + ',';
    Analytics := Analytics + ' ac.' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
  end;

  ibsql := TIBSQL.Create(Application);
  ibsqlAccount := TIBSQL.Create(Application);
  try
    ibsql.Transaction := FWriteTransaction;
    ibsqlAccount.Transaction := gdcBaseManager.ReadTransaction;

    // Получим кол-во счетов
    ibsqlAccount.SQL.Text := 'SELECT COUNT(ag.id) as AccCount FROM ac_account ag';
    ibsqlAccount.ExecQuery;

    // Визуализация процесса
    DoOnProcessMessage(0, ibsqlAccount.FieldByName('AccCount').AsInteger, 'Удаление устаревших данных...');

    // Удалим старые данные сальдо
    ibsql.SQL.Text := 'DELETE FROM ac_entry_balance';
    ibsql.ExecQuery;

    DoOnProcessMessage(-1, -1, 'Расчет бухгалтерских остатков...');

    // Вытянем все счета
    ibsqlAccount.Close;
    ibsqlAccount.SQL.Text :=
      ' SELECT ' +
      '   ac.id, ac.alias ' +
        IIF(Analytics <> '', ', ' + Analytics, '') +
      ' FROM ' +
      '   ac_account ac ' +
      ' ORDER BY ' +
      '   ac.alias ';
    ibsqlAccount.ExecQuery;

    RecordCounter := 0;
    while not ibsqlAccount.Eof do
    begin
      // При нажатии Escape прервем процесс
      if FProcessState = psTerminating then
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('Выполнение прервано')
        else
          FProcessState := psWorking;

      // Визуализация процесса
      Inc(RecordCounter);
      DoOnProcessMessage(RecordCounter, -1, '');

      // возьмем выбранные аналитики по расчитываемому счету
      BalanceAnalytics := '';
      InsertAnalytics := '';
      for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      begin
        if ibsqlAccount.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsInteger = 1 then
        begin
          BalanceAnalytics := BalanceAnalytics + ', ' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
          InsertAnalytics := InsertAnalytics + ', :' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
        end;
      end;

      // Сформируем запрос на запись
      ibsql.Close;
      ibsql.SQL.Text := ibWriteBegin + BalanceAnalytics + ') ' + ibMainBegin +
        BalanceAnalytics + ibMainMiddle + BalanceAnalytics + ibMainEnd;
      ibsql.ParamByName('BALANCEDATE').AsDateTime := FCloseDate;
      ibsql.ParamByName('ACCKEY').AsInteger := ibsqlAccount.FieldByName('ID').AsInteger;
      ibsql.ExecQuery;

      // Запомним кол-во вставленных записей, будем использовать его при переносе бух. остатков в AC_ENTRY
      FInsertedEntryBalanceRecordCount := FInsertedEntryBalanceRecordCount + ibsql.RowsAffected;

      ibsqlAccount.Next;
    end;

    // Установим новое значение генератора gd_g_entry_balance_date
    ibsql.Close;
    ibsql.SQL.Text :=
      Format('SET GENERATOR gd_g_entry_balance_date TO %d', [Round(FCloseDate) + IBDateDelta]);
    ibsql.ExecQuery;

     // Если процесс завершился успешно, то сохраним введенные неучитываемые аналитики
    if Assigned(GlobalStorage) then
      GlobalStorage.WriteString(DontBalanceAnalyticStorageFolder, DontBalanceAnalyticStorageValue,
        FDontBalanceAnalytic);

    // Визуализация процесса
    DoOnProcessMessage(RecordCounter, RecordCounter, 'Вычисление бухгалтерских остатков завершено'#13#10 +
      'Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
  finally
    ibsqlAccount.Free;
    ibsql.Free;
  end;
end;

procedure TgdClosingPeriod.TransferEntryBalance;
const
  DocumentTypeKeyRUID = '806001_17';
  TRRecordKeyRUID = '807100_17';
  TransactionKeyRUID = '807001_17';

  ibMainBegin =
    ' SELECT ' +
    '  companykey, ' +
    '  accountkey, ' +
    '  currkey, ' +
    '  debitncu, ' +
    '  creditncu, ' +
    '  debitcurr, ' +
    '  creditcurr, ' +
    '  debiteq, ' +
    '  crediteq ';
  ibMainMiddle =
    ' FROM ' +
    '  ac_entry_balance ';
  ibACEntryWriteBegin =
    ' INSERT INTO ac_entry ' +
    ' (recordkey, entrydate, transactionkey, documentkey, masterdockey, companykey, accountkey, accountpart, currkey, issimple, ' +
    '  debitncu, creditncu, debitcurr, creditcurr, debiteq, crediteq ';
  ibACEntryWriteValues =
    ' VALUES ' +
    ' (:recordkey, :entrydate, :transactionkey, :documentkey, :masterdockey, :companykey, :accountkey, :accountpart, :currkey, 1, ' +
    '  :debitncu, :creditncu, :debitcurr, :creditcurr, :debiteq, :crediteq ';
var
  ibsqlSelect: TIBSQL;
  ibsqlInsertGDDocument: TIBSQL;
  ibsqlInsertACRecord: TIBSQL;
  ibsqlInsertACEntry: TIBSQL;
  DocumentTypeKey, TransactionKey, TRRecordKey: TID;
  NextDocumentKey, NextRecordKey: TID;
  InsertAnalytics, ValuesAnalytics: String;
  AnalyticCounter: Integer;
  CurrentCompanyKey: TID;
  RecordCounter: Integer;
begin
  FLocalStartTime := Time;

  // Визуализация процесса
  DoOnProcessMessage(-1, -1, 'Копирование бухгалтерских остатков...');

  ibsqlSelect := TIBSQL.Create(Application);
  ibsqlInsertACRecord := TIBSQL.Create(Application);
  ibsqlInsertGDDocument := TIBSQL.Create(Application);
  ibsqlInsertACEntry := TIBSQL.Create(Application);
  try
    ibsqlSelect.Transaction := FWriteTransaction;
    ibsqlInsertACRecord.Transaction := FWriteTransaction;
    ibsqlInsertGDDocument.Transaction := FWriteTransaction;
    ibsqlInsertACEntry.Transaction := FWriteTransaction;

    // Получим ключ типа складского документа для остатков
    DocumentTypeKey := gdcBaseManager.GetIDByRUIDString(DocumentTypeKeyRUID);
    // Запрос на вставку записи в gd_document
    ibsqlInsertGDDocument.SQL.Text := Format(
      'INSERT INTO gd_document ' +
      '  (id, documenttypekey, number, documentdate, companykey, afull, achag, aview, creatorkey, editorkey) ' +
      'VALUES ' +
      '  (:id, %0:d, ''1'', :documentdate, :companykey, -1, -1, -1, %1:d, %1:d) ', [DocumentTypeKey, IBLogin.ContactKey]);
    ibsqlInsertGDDocument.Prepare;

    // Получим ключ типовой проводки
    TRRecordKey := gdcBaseManager.GetIDByRUIDString(TRRecordKeyRUID);
    // Получим ключ типовой операции
    TransactionKey := gdcBaseManager.GetIDByRUIDString(TransactionKeyRUID);
    // Запрос на вставку проводки в AC_RECORD
    ibsqlInsertACRecord.SQL.Text := Format(
      'INSERT INTO ac_record ' +
      '  (id, trrecordkey, transactionkey, recorddate, documentkey, masterdockey, companykey, afull, achag, aview) ' +
      'VALUES ' +
      '  (:id, %0:d, %1:d, :recorddate, :documentkey, :documentkey, :companykey, -1, -1, -1) ', [TRRecordKey, TransactionKey]);
    ibsqlInsertACRecord.Prepare;

    // возьмем выбранные аналитики по расчитываемому счету
    ValuesAnalytics := '';
    for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      ValuesAnalytics := ValuesAnalytics + ', ' + FEntryAvailableAnalytics.Strings[AnalyticCounter];

    // Получим сальдо из AC_ENTRY_BALANCE
    ibsqlSelect.SQL.Text :=
      ' SELECT ' +
      '   companykey, accountkey, currkey, debitncu, creditncu, debitcurr, creditcurr, debiteq, crediteq ' +
        ValuesAnalytics +
      ' FROM ' +
      '   ac_entry_balance ';
    ibsqlSelect.ExecQuery;

    DoOnProcessMessage(0, FInsertedEntryBalanceRecordCount, '');

    CurrentCompanyKey := -1;
    NextDocumentKey := -1;
    RecordCounter := 0;
    while not ibsqlSelect.Eof do
    begin
      if FProcessState = psTerminating then
        if Application.MessageBox('Остановить закрытие периода?', 'Внимание',
           MB_YESNO or MB_ICONQUESTION or MB_SYSTEMMODAL) = IDYES then
          raise Exception.Create('Выполнение прервано')
        else
          FProcessState := psWorking;

      if CurrentCompanyKey <> ibsqlSelect.FieldByName('COMPANYKEY').AsInteger then
      begin
        CurrentCompanyKey := ibsqlSelect.FieldByName('COMPANYKEY').AsInteger;
        // Получение ключа для документа
        NextDocumentKey := gdcBaseManager.GetNextID;
        // Создание документа
        ibsqlInsertGDDocument.ParamByName('ID').AsInteger := NextDocumentKey;
        ibsqlInsertGDDocument.ParamByName('DOCUMENTDATE').AsDateTime := FCloseDate - 1;
        ibsqlInsertGDDocument.ParamByName('COMPANYKEY').AsInteger := CurrentCompanyKey;
        ibsqlInsertGDDocument.ExecQuery;
      end;

      // Получение ключа заголовка проводки
      NextRecordKey := gdcBaseManager.GetNextID;
      // Вставка заголовка проводки
      ibsqlInsertACRecord.Close;
      ibsqlInsertACRecord.ParamByName('ID').AsInteger := NextRecordKey;
      ibsqlInsertACRecord.ParamByName('RECORDDATE').AsDateTime := FCloseDate - 1;
      ibsqlInsertACRecord.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
      ibsqlInsertACRecord.ParamByName('COMPANYKEY').AsInteger := CurrentCompanyKey;
      ibsqlInsertACRecord.ExecQuery;

      // возьмем выбранные аналитики по расчитываемому счету
      InsertAnalytics := '';
      ValuesAnalytics := '';
      for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      begin
        if not ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).IsNull then
        begin
          InsertAnalytics := InsertAnalytics + ', ' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
          ValuesAnalytics := ValuesAnalytics + ', :' + FEntryAvailableAnalytics.Strings[AnalyticCounter];
        end;
      end;
      // Сформируем запрос на вставку проводки в AC_ENTRY
      ibsqlInsertACEntry.SQL.Text :=
        ibACEntryWriteBegin + InsertAnalytics + ')' +
        ibACEntryWriteValues + ValuesAnalytics + ')';
      // Вставка дебетовой части проводки
      ibsqlInsertACEntry.Close;
      ibsqlInsertACEntry.ParamByName('RECORDKEY').AsInteger := NextRecordKey;
      ibsqlInsertACEntry.ParamByName('ENTRYDATE').AsDateTime := FCloseDate - 1;
      ibsqlInsertACEntry.ParamByName('TRANSACTIONKEY').AsInteger := TransactionKey;
      ibsqlInsertACEntry.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
      ibsqlInsertACEntry.ParamByName('COMPANYKEY').AsInteger := CurrentCompanyKey;
      ibsqlInsertACEntry.ParamByName('ACCOUNTKEY').AsInteger := ibsqlSelect.FieldByName('ACCOUNTKEY').AsInteger;
      ibsqlInsertACEntry.ParamByName('ACCOUNTPART').AsString := 'D';
      ibsqlInsertACEntry.ParamByName('CURRKEY').AsInteger := ibsqlSelect.FieldByName('CURRKEY').AsInteger;
      ibsqlInsertACEntry.ParamByName('DEBITNCU').AsCurrency := ibsqlSelect.FieldByName('DEBITNCU').AsCurrency;
      ibsqlInsertACEntry.ParamByName('DEBITCURR').AsCurrency := ibsqlSelect.FieldByName('DEBITCURR').AsCurrency;
      ibsqlInsertACEntry.ParamByName('DEBITEQ').AsCurrency := ibsqlSelect.FieldByName('DEBITEQ').AsCurrency;
      ibsqlInsertACEntry.ParamByName('CREDITNCU').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('CREDITCURR').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('CREDITEQ').AsCurrency := 0;
      for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      begin
        if not ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).IsNull then
        begin
          ibsqlInsertACEntry.ParamByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsVariant :=
            ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsVariant;
        end;
      end;
      ibsqlInsertACEntry.ExecQuery;
      // Вставка кредитовой части проводки
      ibsqlInsertACEntry.Close;
      ibsqlInsertACEntry.ParamByName('RECORDKEY').AsInteger := NextRecordKey;
      ibsqlInsertACEntry.ParamByName('ENTRYDATE').AsDateTime := FCloseDate - 1;
      ibsqlInsertACEntry.ParamByName('TRANSACTIONKEY').AsInteger := TransactionKey;
      ibsqlInsertACEntry.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
      ibsqlInsertACEntry.ParamByName('COMPANYKEY').AsInteger := CurrentCompanyKey;
      ibsqlInsertACEntry.ParamByName('ACCOUNTKEY').AsInteger := ibsqlSelect.FieldByName('ACCOUNTKEY').AsInteger;
      ibsqlInsertACEntry.ParamByName('ACCOUNTPART').AsString := 'C';
      ibsqlInsertACEntry.ParamByName('CURRKEY').AsInteger := ibsqlSelect.FieldByName('CURRKEY').AsInteger;
      ibsqlInsertACEntry.ParamByName('DEBITNCU').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('DEBITCURR').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('DEBITEQ').AsCurrency := 0;
      ibsqlInsertACEntry.ParamByName('CREDITNCU').AsCurrency := ibsqlSelect.FieldByName('CREDITNCU').AsCurrency;
      ibsqlInsertACEntry.ParamByName('CREDITCURR').AsCurrency := ibsqlSelect.FieldByName('CREDITCURR').AsCurrency;
      ibsqlInsertACEntry.ParamByName('CREDITEQ').AsCurrency := ibsqlSelect.FieldByName('CREDITEQ').AsCurrency;
      for AnalyticCounter := 0 to FEntryAvailableAnalytics.Count - 1 do
      begin
        if not ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).IsNull then
        begin
          ibsqlInsertACEntry.ParamByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsVariant :=
            ibsqlSelect.FieldByName(FEntryAvailableAnalytics.Strings[AnalyticCounter]).AsVariant;
        end;
      end;
      ibsqlInsertACEntry.ExecQuery;

      // Визуализация процесса
      Inc(RecordCounter);
      DoOnProcessMessage(RecordCounter, -1, '');

      ibsqlSelect.Next;
    end;

    DoOnProcessMessage(-1, -1, 'Удаление временных данных...');

    ibsqlSelect.Close;
    ibsqlSelect.SQL.Text := 'DELETE FROM ac_entry_balance';
    ibsqlSelect.ExecQuery;

    ibsqlSelect.Close;
    ibsqlSelect.SQL.Text := 'SET GENERATOR gd_g_entry_balance_date TO 0';
    ibsqlSelect.ExecQuery;
  finally
    ibsqlInsertACEntry.Free;
    ibsqlInsertGDDocument.Free;
    ibsqlInsertACRecord.Free;
    ibsqlSelect.Free;
  end;
  // Визуализация процесса
  DoOnProcessMessage(FInsertedEntryBalanceRecordCount, FInsertedEntryBalanceRecordCount,
    'Копирование бухгалтерских остатков завершено'#13#10 +
    'Продолжительность процесса: ' + TimeToStr(Time - FLocalStartTime));
end;

procedure TgdClosingPeriod.InitialFillOptions;
var
  AcAccountRelation: TatRelation;
  AnalyticCounter, ForeignKeyCounter: Integer;
  TableReferenceIndex: Integer;
  OL: TObjectList;
begin
  // На Псевдоклиента будет оформлятся расход товара при формировании остатков
  FPseudoClientKey := gdcBaseManager.GetIDByRUID(147004309, 31587988);            // TODO: заменить взятие ИД на выбор контакта в настройках
  // Выберем подходящие бухгалтерские аналитики
  AcAccountRelation := atDatabase.Relations.ByRelationName('AC_ACCOUNT');
  if Assigned(AcAccountRelation) then
  begin
    for AnalyticCounter := 0 to AcAccountRelation.RelationFields.Count - 1 do
    begin
      if AcAccountRelation.RelationFields.Items[AnalyticCounter].IsUserDefined
         and (AnsiPos(';' + AcAccountRelation.RelationFields.Items[AnalyticCounter].FieldName + ';', FDontBalanceAnalytic) = 0) then
        FEntryAvailableAnalytics.Add(AcAccountRelation.RelationFields.Items[AnalyticCounter].FieldName);
    end;
  end
  else
    raise Exception.Create('AC_ACCOUNT not found!');

  // Заполним для INV_CARD список внешних ключей из складских таблиц
  if not FTableReferenceForeignKeysList.Find('INV_CARD', TableReferenceIndex) then
  begin
    // Создадим новый список внешних ключей ссылающихся на переданную таблицу
    TableReferenceIndex := FTableReferenceForeignKeysList.AddObject('INV_CARD', TObjectList.Create(False));
    OL := TObjectList.Create(False);
    try
      // Получим список внешних ключей ссылающихся на переданную таблицу
      atDatabase.ForeignKeys.ConstraintsByReferencedRelation('INV_CARD', OL);
      // Возьмем только простые внешние ключи
      for ForeignKeyCounter := 0 to OL.Count - 1 do
      begin
        if (TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.FieldName = 'FROMCARDKEY')
           or (TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.FieldName = 'TOCARDKEY')
           or (TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.FieldName = 'PARENT') then
          TObjectList(FTableReferenceForeignKeysList.Objects[TableReferenceIndex]).Add(OL.Items[ForeignKeyCounter]);
      end;
    except
      OL.Free;
    end;
  end;
end;

function TgdClosingPeriod.AddDepotHeader(const FromContact, ToContact, CompanyKey: TID): TID;
var
  NextDocumentKey: TID;
begin
  // Попробуем найти шапку с такими контактами
  FIBSQLGetDepotHeaderKey.Close;
  FIBSQLGetDepotHeaderKey.ParamByName('OUTCONTACT').AsInteger := FromContact;
  FIBSQLGetDepotHeaderKey.ParamByName('INCONTACT').AsInteger := ToContact;
  FIBSQLGetDepotHeaderKey.ExecQuery;

  if FIBSQLGetDepotHeaderKey.RecordCount > 0 then
  begin
    Result := FIBSQLGetDepotHeaderKey.FieldByName('DOCUMENTKEY').AsInteger;
  end
  else
  begin
    // Если такой шапки не нашлось, вставим новую
    
    // Получим ИД документа шапки
    NextDocumentKey := gdcBaseManager.GetNextID;
    // Вставим запись в gd_document
    FIBSQLInsertGdDocument.Close;
    FIBSQLInsertGdDocument.ParamByName('ID').AsInteger := NextDocumentKey;
    FIBSQLInsertGdDocument.ParamByName('PARENT').Clear;
    FIBSQLInsertGdDocument.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
    FIBSQLInsertGdDocument.ParamByName('DOCUMENTDATE').AsDateTime := FCloseDate;
    FIBSQLInsertGdDocument.ExecQuery;

    // Вставим запись в дополнительную таблицу документа шапки
    FIBSQLInsertDocumentHeader.Close;
    FIBSQLInsertDocumentHeader.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
    FIBSQLInsertDocumentHeader.ParamByName('OUTCONTACT').AsInteger := FromContact;
    FIBSQLInsertDocumentHeader.ParamByName('INCONTACT').AsInteger := ToContact;
    FIBSQLInsertDocumentHeader.ExecQuery;

    Result := NextDocumentKey;
  end;
end;

function TgdClosingPeriod.AddDepotPosition(const FromContact, ToContact, CompanyKey,
  ADocumentParentKey, CardGoodkey: TID; const GoodQuantity: Currency; FeatureDataset: TIBSQL = nil): TID;
var
  NextDocumentKey, NextMovementKey, NextCardKey: TID;
  FieldCounter: Integer;
begin
  // Получим ИД документа позиции
  NextDocumentKey := gdcBaseManager.GetNextID;
  // Вставим запись в gd_document
  FIBSQLInsertGdDocument.Close;
  FIBSQLInsertGdDocument.ParamByName('ID').AsInteger := NextDocumentKey;
  FIBSQLInsertGdDocument.ParamByName('PARENT').AsInteger := ADocumentParentKey;
  FIBSQLInsertGdDocument.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
  FIBSQLInsertGdDocument.ParamByName('DOCUMENTDATE').AsDateTime := FCloseDate;
  FIBSQLInsertGdDocument.ExecQuery;

  // Получим ИД новой складской карточки
  NextCardKey := gdcBaseManager.GetNextID;
  // Создадим новую складскую карточку
  FIBSQLInsertInvCard.Close;
  FIBSQLInsertInvCard.ParamByName('ID').AsInteger := NextCardKey;
  FIBSQLInsertInvCard.ParamByName('GOODKEY').AsInteger := CardGoodkey;
  FIBSQLInsertInvCard.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertInvCard.ParamByName('COMPANYKEY').AsInteger := CompanyKey;
  for FieldCounter := 0 to FFeatureList.Count - 1 do
    if Assigned(FeatureDataset) then
      FIBSQLInsertInvCard.ParamByName(FFeatureList.Strings[FieldCounter]).AsVariant :=
        FeatureDataset.FieldByName(FFeatureList.Strings[FieldCounter]).AsVariant
    else
      FIBSQLInsertInvCard.ParamByName(FFeatureList.Strings[FieldCounter]).Clear;
  // Заполним поле USR$INV_ADDLINEKEY карточки нового остатка ссылкой на позицию
  if FAddLineKeyFieldExists then
    FIBSQLInsertInvCard.ParamByName('USR$INV_ADDLINEKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertInvCard.ExecQuery;

  // Получим ИД складского движения
  NextMovementKey := gdcBaseManager.GetNextID;
  // Создадим дебетовую часть складского движения
  FIBSQLInsertInvMovement.Close;
  FIBSQLInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NextMovementKey;
  FIBSQLInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := ToContact;
  FIBSQLInsertInvMovement.ParamByName('CARDKEY').AsInteger := NextCardKey;
  FIBSQLInsertInvMovement.ParamByName('DEBIT').AsCurrency := GoodQuantity;
  FIBSQLInsertInvMovement.ParamByName('CREDIT').AsCurrency := 0;
  FIBSQLInsertInvMovement.ExecQuery;
  // Создадим кредитовую часть складского движения
  FIBSQLInsertInvMovement.Close;
  FIBSQLInsertInvMovement.ParamByName('MOVEMENTKEY').AsInteger := NextMovementKey;
  FIBSQLInsertInvMovement.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertInvMovement.ParamByName('CONTACTKEY').AsInteger := FromContact;
  FIBSQLInsertInvMovement.ParamByName('CARDKEY').AsInteger := NextCardKey;
  FIBSQLInsertInvMovement.ParamByName('DEBIT').AsCurrency := 0;
  FIBSQLInsertInvMovement.ParamByName('CREDIT').AsCurrency := GoodQuantity;
  FIBSQLInsertInvMovement.ExecQuery;

  // Вставим запись в дополнительную таблицу документа позиции
  FIBSQLInsertDocumentPosition.Close;
  FIBSQLInsertDocumentPosition.ParamByName('DOCUMENTKEY').AsInteger := NextDocumentKey;
  FIBSQLInsertDocumentPosition.ParamByName('MASTERKEY').AsInteger := ADocumentParentKey;
  FIBSQLInsertDocumentPosition.ParamByName('FROMCARDKEY').AsInteger := NextCardKey;
  FIBSQLInsertDocumentPosition.ParamByName('QUANTITY').AsCurrency := GoodQuantity;
  FIBSQLInsertDocumentPosition.ExecQuery;

  Result := NextCardKey;
end;

procedure TgdClosingPeriod.InitializeIBSQLQueries;
var
  gdcObject: TgdcInvDocument;
  InvDocumentInField, InvDocumentOutField: ShortString;
  InvRelationName, InvRelationLineName: ShortString;
  FieldCounter: Integer;
  SQLText: String;
begin
  if not FQueriesInitialized then
  begin
    // Получим ключ типа складского документа для остатков
    FInvDocumentTypeKey := gdcBaseManager.GetIDByRUIDString(InvDocumentRUID);

    if FInvDocumentTypeKey > 0 then
    begin
      // Сущестует ли поле-ссылка на позицию прихода
      FAddLineKeyFieldExists := Assigned(atDatabase.FindRelationField('INV_CARD', 'USR$INV_ADDLINEKEY'));
      // Получим необходимые наименования таблиц и полей
      gdcObject := TgdcInvDocument.Create(Application);
      try
        gdcObject.Transaction := FWriteTransaction;
        gdcObject.SubType := InvDocumentRUID;
        gdcObject.SubSet := 'ByID';
        // Названия полей-ссылок на контакты, на которые и с которых приходуются ТМЦ
        InvDocumentInField := gdcObject.MovementTarget.SourceFieldName;
        InvDocumentOutField := gdcObject.MovementSource.SourceFieldName;
        InvRelationName := gdcObject.RelationName;
        InvRelationLineName := gdcObject.RelationLineName;
      finally
        gdcObject.Free;
      end;

      // Запрос возвращает ключ документа из InvRelationName по указанным поставщику и складу
      FIBSQLGetDepotHeaderKey.Transaction := FWriteTransaction;
      FIBSQLGetDepotHeaderKey.SQL.Text := Format(
        ' SELECT documentkey FROM %0:s ' +
        ' WHERE %1:s = :incontact AND %2:s = :outcontact ', [InvRelationName, InvDocumentInField, InvDocumentOutField]);
      FIBSQLGetDepotHeaderKey.Prepare;

      // Запрос на вставку записи в gd_document
      FIBSQLInsertGdDocument.Transaction := FWriteTransaction;
      FIBSQLInsertGdDocument.SQL.Text := Format(
        'INSERT INTO gd_document ' +
        '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, creatorkey, editorkey) ' +
        'VALUES ' +
        '  (:id, :parent, %0:d, ''1'', :documentdate, :companykey, -1, -1, -1, %1:d, %1:d) ', [FInvDocumentTypeKey, IBLogin.ContactKey]);
      FIBSQLInsertGdDocument.Prepare;

      // Запрос на вставку записи в шапку складского документа
      FIBSQLInsertDocumentHeader.Transaction := FWriteTransaction;
      FIBSQLInsertDocumentHeader.SQL.Text := Format(
        'INSERT INTO %0:s ' +
        '  (documentkey, %1:s, %2:s) ' +
        'VALUES ' +
        '  (:documentkey, :incontact, :outcontact) ', [InvRelationName, InvDocumentInField, InvDocumentOutField]);
      FIBSQLInsertDocumentHeader.Prepare;

      // Запрос на вставку записи в позиции складского документа
      FIBSQLInsertDocumentPosition.Transaction := FWriteTransaction;
      FIBSQLInsertDocumentPosition.SQL.Text := Format(
        'INSERT INTO %0:s ' +
        '  (documentkey, masterkey, fromcardkey, quantity) ' +
        'VALUES ' +
        '  (:documentkey, :masterkey, :fromcardkey, :quantity) ', [InvRelationLineName]);
      FIBSQLInsertDocumentPosition.Prepare;
    end;

    // Запрос на создание складской карточки
    FIBSQLInsertInvCard.Transaction := FWriteTransaction;
    SQLText :=
      'INSERT INTO inv_card ' +
      '  (id, goodkey, documentkey, firstdocumentkey, firstdate, companykey';
    // Поля-признаки
    for FieldCounter := 0 to FFeatureList.Count - 1 do
      SQLText := SQLText + ', ' + FFeatureList.Strings[FieldCounter];
    // Если сущестует поле-ссылка на позицию прихода
    if FAddLineKeyFieldExists then
      SQLText := SQLText + ', USR$INV_ADDLINEKEY';
    SQLText := SQLText + ') VALUES ' +
      '  (:id, :goodkey, :documentkey, :documentkey, :firstdate, :companykey';
    // Поля-признаки
    for FieldCounter := 0 to FFeatureList.Count - 1 do
      SQLText := SQLText + ', :' + FFeatureList.Strings[FieldCounter];
    // Если сущестует поле-ссылка на позицию прихода
    if FAddLineKeyFieldExists then
      SQLText := SQLText + ', :USR$INV_ADDLINEKEY';
    SQLText := SQLText + ')';
    FIBSQLInsertInvCard.SQL.Text := SQLText;
    FIBSQLInsertInvCard.ParamByName('FIRSTDATE').AsDateTime := FCloseDate;
    FIBSQLInsertInvCard.Prepare;

    // Запрос на создание складского движения
    FIBSQLInsertInvMovement.Transaction := FWriteTransaction;
    FIBSQLInsertInvMovement.SQL.Text :=
      'INSERT INTO inv_movement ' +
      '  (movementkey, movementdate, documentkey, contactkey, cardkey, debit, credit) ' +
      'VALUES ' +
      '  (:movementkey, :movementdate, :documentkey, :contactkey, :cardkey, :debit, :credit) ';
    FIBSQLInsertInvMovement.ParamByName('MOVEMENTDATE').AsDateTime := FCloseDate;
    FIBSQLInsertInvMovement.Prepare;

    // Удаление РУИДа
    FIBSQLDeleteRUID.Transaction := FWriteTransaction;
    FIBSQLDeleteRUID.SQL.Text :=
      'DELETE FROM gd_ruid ' +
      'WHERE ' +
      '  id = :id ';
    FIBSQLDeleteRUID.Prepare;

    FQueriesInitialized := True;
  end;
end;

procedure TgdClosingPeriod.SetClosingDatabaseParams(const ADBPAth,
  ADBServer, ADBUser, ADBPAssword: String);
begin
  FExtDatabasePath := ADBPAth;
  FExtDatabaseServer := ADBServer;
  FExtDatabaseUser := ADBUser;
  FExtDatabasePassword := ADBPAssword;
end;

procedure TgdClosingPeriod.DoAfterProcess;
begin
  // Если процесс не прерывали, и он не прервался из-за ошибки, то укажем что все прошло успешно
  if not (FProcessState in [psInterrupted, psError]) then
    FProcessState := psSuccess;
  // Коммит рабочей транзакции  
  if FWriteTransaction.InTransaction then
    FWriteTransaction.Commit;
  if Assigned(FOnAfterProcess) then
    FOnAfterProcess;
end;

procedure TgdClosingPeriod.DoBeforeProcess;
begin
  // Укажем что объект начал работу
  FProcessState := psWorking;
  if Assigned(FOnBeforeProcess) then
    FOnBeforeProcess;
  FWriteTransaction.StartTransaction;
  InitialFillOptions;
  InitializeIBSQLQueries;  
end;

procedure TgdClosingPeriod.DoOnProcessInterruption(const AErrorMessage: String);
begin
  // Если процесс был  прерван пользователем, укажем это, иначе укажем что процесс завершился из-за ошибки
  if FProcessState = psTerminating then
    FProcessState := psInterrupted
  else
    FProcessState := psError;  
  // Откатим пишущую транзакцию
  if FWriteTransaction.InTransaction then
    FWriteTransaction.Rollback;
  if Assigned(FOnProcessInterruption) then
    FOnProcessInterruption(AErrorMessage);
end;

procedure TgdClosingPeriod.DoOnProcessMessage(const APosition, AMaxPosition: Integer; const AMessage: String);
begin
  if Assigned(FOnProcessMessage) then
    FOnProcessMessage(APosition, AMaxPosition, AMessage);
end;

function TgdClosingPeriod.GetInProcess: Boolean;
begin
  Result := (FProcessState = psWorking);
  {Result := False;
  if Assigned(FWorkingThread) and not FWorkingThread.Suspended then
    Result := True;}
end;

procedure TgdClosingPeriod.StopProcess;
begin
  if InProcess then
  begin
    FProcessState := psTerminating;
  end;
end;

procedure TgdClosingPeriod.PrepareDontDeleteDocumentList;
var
  ibsqlSelect: TIBSQL;
  DocTypeCounter: Integer;
  TempOutVariable: Integer;
begin
  ibsqlSelect := TIBSQL.Create(Application);
  try
    // Подготовим запрос который вытащит ключи документов типов, которые нельзя удалять
    ibsqlSelect.Transaction := FWriteTransaction;
    ibsqlSelect.SQL.Text :=
      ' SELECT ' +
      '   d.id, c.firstdocumentkey AS firstid ' +
      ' FROM ' +
      '   gd_document d ' +
      '   LEFT JOIN inv_card c ON c.documentkey = d.id ' +
      ' WHERE ' +
      '   d.documenttypekey = :doctypekey ' +
      '   AND d.documentdate < :closedate ' +
      '   AND NOT d.parent IS NULL ' +
      ' ORDER BY ' +
      '   d.id';
    ibsqlSelect.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;

    // Пройдем по типам документов, которые нельзя удалять
    for DocTypeCounter := 0 to FDontDeleteDocumentTypes.Count - 1 do
    begin
      ibsqlSelect.ParamByName('DOCTYPEKEY').AsInteger := FDontDeleteDocumentTypes.Keys[DocTypeCounter];
      ibsqlSelect.ExecQuery;

      // Пройдем по всем ключам и занесем их в список
      while not ibsqlSelect.Eof do
      begin
        if not FDontDeleteCardArray.Find(ibsqlSelect.FieldByName('ID').AsInteger, TempOutVariable) then
          FDontDeleteCardArray.Add(ibsqlSelect.FieldByName('ID').AsInteger);
        if not FDontDeleteCardArray.Find(ibsqlSelect.FieldByName('FIRSTID').AsInteger, TempOutVariable) then
          FDontDeleteCardArray.Add(ibsqlSelect.FieldByName('FIRSTID').AsInteger);

        ibsqlSelect.Next;
      end;

      ibsqlSelect.Close;
    end;

    //DoOnProcessMessage(-1, -1, Format('Кол-во документов: %d', [FDontDeleteCardArray.Count]));
  finally
    FreeAndNil(ibsqlSelect);
  end;
end;

function TgdClosingPeriod.CreateDummyInvDocument(const ADocTypeKey: TID): TID;
var
  ibsqlDocumentInsert: TIBSQL;
  NextDocumentKey: TID;
  DummyDocumentIndex: Integer;
begin
  // Поищем такой тип в списке, возможно для него уже создана заглушка
  if FDummyInvDocumentKeys.Find(ADocTypeKey, DummyDocumentIndex) then
  begin
    Result := FDummyInvDocumentKeys.ValuesByIndex[DummyDocumentIndex];
  end
  else
  begin
    ibsqlDocumentInsert := TIBSQL.Create(Application);
    try
      NextDocumentKey := gdcBaseManager.GetNextID;
      // Вставка записи в GD_DOCUMENT
      ibsqlDocumentInsert.Transaction := FWriteTransaction;
      ibsqlDocumentInsert.SQL.Text := Format(
        'INSERT INTO gd_document ' +
        '  (id, parent, documenttypekey, number, documentdate, companykey, afull, achag, aview, creatorkey, editorkey) ' +
        'VALUES ' +
        '  (%0:d, :parent, %1:d, ''CP_DUMMY'', :documentdate, %2:d, -1, -1, -1, %3d, %3d) ',
        [NextDocumentKey, ADocTypeKey, IBLogin.CompanyKey, IBLogin.ContactKey]);
      ibsqlDocumentInsert.FieldByName('DOCUMENTDATE').AsDateTime := FCloseDate;
      ibsqlDocumentInsert.ExecQuery;
    finally
      FreeAndNil(ibsqlDocumentInsert);
    end;

    // Запомним ключ заглушки
    DummyDocumentIndex := FDummyInvDocumentKeys.Add(ADocTypeKey);
    FDummyInvDocumentKeys.ValuesByIndex[DummyDocumentIndex] := NextDocumentKey;

    Result := NextDocumentKey;
  end;
end;

procedure TgdClosingPeriod.TryToDeleteInvCardReferences(const ADocumentKey: TID);
var
  TableReferenceIndex: Integer;
  OL: TObjectList;
  ibsqlCardSelect, ibsqlDocumentSelect, ibsqlDocumentUpdate: TIBSQL;
  ReferencesRelationName, ReferencesFieldName: String;
  ForeignKeyCounter, FeatureCounter: Integer;
  CardReplacementKey: Integer;
begin
  TableReferenceIndex := FTableReferenceForeignKeysList.IndexOf('INV_CARD');
  if TableReferenceIndex > -1 then
  begin
    OL := TObjectList(FTableReferenceForeignKeysList.Objects[TableReferenceIndex]);

    ibsqlCardSelect := TIBSQL.Create(Application);
    ibsqlDocumentSelect := TIBSQL.Create(Application);
    ibsqlDocumentUpdate := TIBSQL.Create(Application);
    try
      ibsqlDocumentSelect.Transaction := FWriteTransaction;
      ibsqlDocumentUpdate.Transaction := FWriteTransaction;

      // Получим ключи карточек которые ссылаются на переданный документ
      ibsqlCardSelect.Transaction := FWriteTransaction;
      ibsqlCardSelect.SQL.Text :=
        'SELECT ' +
        '  c.id, c.goodkey ';
      for FeatureCounter := 0 to FFeatureList.Count - 1 do
        ibsqlCardSelect.SQL.Text := ibsqlCardSelect.SQL.Text + ', c.' + FFeatureList.Strings[FeatureCounter];
      ibsqlCardSelect.SQL.Text := ibsqlCardSelect.SQL.Text + Format(
        'FROM ' +
        '  inv_card c ' +
        'WHERE ' +
        '  c.documentkey = %0:d ' +
        '  OR (c.firstdocumentkey = %0:d)', [ADocumentKey]);
      ibsqlCardSelect.ExecQuery;
      // Если такие карточки вообще есть
      while not ibsqlCardSelect.Eof do
      begin
        // Цикл по внешним ключам
        for ForeignKeyCounter := 0 to OL.Count - 1 do
        begin
          // Имя таблицы которая содержит ссылку на переданную запись
          ReferencesRelationName := TatForeignKey(OL[ForeignKeyCounter]).Relation.RelationName;
          // Имя поля-ссылки на переданную запись
          ReferencesFieldName := TatForeignKey(OL.Items[ForeignKeyCounter]).ConstraintField.FieldName;

          // Выберем записи из складских таблиц, ссылающиеся на найденные карточки
          ibsqlDocumentSelect.SQL.Text := Format(
            'SELECT ' +
            '  d.documentdate, d.id ' +
            'FROM ' +
            '  %0:s l ' +
            '  JOIN gd_document d ON d.id = l.documentkey ' +
            'WHERE ' +
            '  l.%1:s = %2:d ', [ReferencesRelationName, ReferencesFieldName, ibsqlCardSelect.FieldByName('ID').AsInteger]);
          ibsqlDocumentSelect.ExecQuery;

          if ibsqlDocumentSelect.RecordCount > 0 then
          begin
            while not ibsqlDocumentSelect.Eof do
            begin
              // Найти подходящую карточку для замены
              CardReplacementKey := GetReplacementInvCardKey(ibsqlCardSelect.FieldByName('ID').AsInteger, ibsqlCardSelect);
              if CardReplacementKey > -1 then
              begin
                ibsqlDocumentUpdate.SQL.Text := Format(
                  'UPDATE %0:s SET %1:s = %2:d WHERE %1:s = %3:d',
                  [ReferencesRelationName, ReferencesFieldName, CardReplacementKey, ibsqlCardSelect.FieldByName('ID').AsInteger]);
                ibsqlDocumentUpdate.ExecQuery;
                ibsqlDocumentUpdate.Close;
              end;
              ibsqlDocumentSelect.Next;
            end;
            ibsqlDocumentUpdate.Close;
          end;
          ibsqlDocumentSelect.Close;
        end;
        ibsqlCardSelect.Next;
      end;
    finally
      FreeAndNil(ibsqlDocumentUpdate);
      FreeAndNil(ibsqlDocumentSelect);
      FreeAndNil(ibsqlCardSelect);
    end;
  end;  
end;

function TgdClosingPeriod.GetReplacementInvCardKey(const AOldCardKey: TID;
  AFeatureDataset: TIBSQL; const AFromContactkey, AToContactkey: TID): TID;
var
  ibsqlSearchNewCardkey: TIBSQL;
begin
  Result := -1;

  ibsqlSearchNewCardkey := TIBSQL.Create(Application);
  try
    ibsqlSearchNewCardkey.Transaction := FWriteTransaction;
    // Поищем подходящую карточку для замены удаляемой
    ibsqlSearchNewCardkey.SQL.Text := SEARCH_NEW_CARDKEY_TEMPLATE_SIMPLE;
    {for FeatureCounter := 0 to FFeatureList.Count - 1 do
    begin
      if not AFeatureDataset.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
        ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
          Format(' AND card.%0:s = :%0:s ', [FFeatureList.Strings[FeatureCounter]])
      else
        ibsqlSearchNewCardkey.SQL.Text := ibsqlSearchNewCardkey.SQL.Text +
          Format(' AND card.%0:s IS NULL ', [FFeatureList.Strings[FeatureCounter]]);
    end;}
    ibsqlSearchNewCardkey.ParamByName('CLOSEDATE').AsDateTime := FCloseDate;
    ibsqlSearchNewCardkey.ParamByName('DOCTYPEKEY').AsInteger := FInvDocumentTypeKey;
    ibsqlSearchNewCardkey.ParamByName('GOODKEY').AsInteger := AFeatureDataset.FieldByName('GOODKEY').AsInteger;
    {for FeatureCounter := 0 to FFeatureList.Count - 1 do
    begin
      if not AFeatureDataset.FieldByName(FFeatureList.Strings[FeatureCounter]).IsNull then
        ibsqlSearchNewCardkey.ParamByName(FFeatureList.Strings[FeatureCounter]).AsVariant :=
          AFeatureDataset.FieldByName(FFeatureList.Strings[FeatureCounter]).AsVariant;
    end;}
    ibsqlSearchNewCardkey.ExecQuery;

    if ibsqlSearchNewCardkey.RecordCount > 0 then
      Result := ibsqlSearchNewCardkey.FieldByName('CARDKEY').AsInteger;
  finally
    FreeAndNil(ibsqlSearchNewCardkey);
  end;
end;

procedure TgdClosingPeriod.DeleteRUID(const AID: Integer);
begin
  // Закроем если еще открыт
  if FIBSQLDeleteRUID.Open then
    FIBSQLDeleteRUID.Close;
  // Удалим РУИД по переданному ключу  
  FIBSQLDeleteRUID.ParamByName('ID').AsInteger := AID;
  FIBSQLDeleteRUID.ExecQuery;
  FIBSQLDeleteRUID.Close;
end;

{ TgdClosingThread }

procedure TgdClosingThread.Execute;
begin
  // Вызовем обработчик начала процесса закрытия
  Model.DoBeforeProcess;

  Model.SetTriggerActive(False);
  try
    try
      Model.PrepareDontDeleteDocumentList;

      // Вычисление бухгалтерских остатков
      if Model.DoCalculateEntryBalance then
        Model.CalculateEntryBalance;

      // Удаление проводок
      if Model.DoDeleteEntry then
        Model.DeleteEntry;

      // Вычисление складских остатков
      if Model.DoCalculateRemains then
        Model.CalculateRemains;

      // Перепривязка складских карточек
      if Model.DoReBindDepotCards then
        Model.ReBindDepotCards;

      // Удаление документов
      if Model.DoDeleteDocuments then
        Model.DeleteDocuments;

      // Удаление пользовательских документов
      if Model.DoDeleteUserDocuments then
        Model.DeleteUserDocuments;

      // Копирование бухгалтерских остатков из AC_ENTRY_BALANCE в AC_ENTRY
      if Model.DoTransferEntryBalance then
        Model.TransferEntryBalance;
    except
      on E: Exception do
      begin
        // Вызовем обработчик исключительной ситуации
        Model.DoOnProcessInterruption(E.Message);
      end;
    end;
  finally
    // Включение триггеров
    Model.SetTriggerActive(True);
    // Вызовем обработчик окончания процесса закрытия
    Model.DoAfterProcess;

    Self.Terminate;
  end;
end;

end.
