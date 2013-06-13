unit mdf_proclist;

interface

uses
  gdModify, mdf_CreateUniqueFunctionName,
  mdf_AddBranchKey, mdf_ChangeReportForm, mdf_ChangeSyncProcedures,
  mdf_ChangeSetting, mdf_UpdateRemainsCommand, mdf_UpdateStorageCommand,
  mdf_ChangeFilterFullName, mfd_UserGroupNameToRUID, mdf_UpdateDocumenttypeRUID,
  mdf_DivideFullClassName, mdf_ChangeRUID, mdf_ChangeFilterReportName,
  mfd_UpdateLocalName, mdf_AddEditionDate, mdf_UpdateContact, mdf_AlterTriggerGoodTax,
  mdf_ChangeTemplatesName, mdf_ChangeForeignForAtFields, mdf_ChangeJournal,
  mdf_UpdateHolidays, mdf_AddMacrosRightsFields, mdf_AddAccountStoredProc,
  mdf_AddHolding, mdf_InsertAnaliseCommands, mdf_AddTaxTables, mdf_AlterViewGD_CONTACTLIST,
  mdf_AddFbUdfSupport, mdf_SpySFChange, mdf_AddUdfDelChar, mdf_UpdateModuleCode,
  mdf_AddMacrosListIndices, mdf_Correct_gd_function, mdf_AddZeroAccount,
  mdf_AddEntryDate, mdf_ModifyAccountCirculation, mdf_AddFieldFUNCSTOR,
  mdf_InsertLedgerCommands, mdf_AddNewInventTable, mdf_CreateViewGd_V_COMPANY,
  mdf_EntryQuantitySupport, mdf_AddFieldSaveNullEntry, mdf_ModifyAnaliticalForeignKey,
  mdf_AddFieldDocumentType, mdf_AutoTransactionTables, mdf_UpdateContact2,
  mdf_AddDisplayInMenuField, mdf_InsertGeneralLedgerCommands,
  mdf_ChangeAtRelations, mfd_Create_gd_File, mdf_ModifyACBALANCEENTRY,
  mdf_Add_AC_OVERTURNBYANAL, mdf_AddIncludeInternalMovmentField, mdf_AddEntryIndices,
  mdf_AddQuantityField, mdf_AddEntryIndices2, mdf_SetDomainCondition, mdf_AddIsCheckNumberField,
  mdf_ChangeDGoldQuantity, mdf_ChangeINV_AU_MOVEMENT, mdf_AddLongNameFieldInScript,
  mdf_AddGSFFieldsToSettings, mdf_NewAcctReports, mdf_UniqueLName, mdf_UpdateFiles,
  mdf_AddAccountKeyToTypeEntry, mdf_NewTaxies, mdf_NewTrEntries, mdf_GrantTables,
  mdf_QuckLedger, mdf_AddTransactionFunctionFields, mdf_GetSimpleLedger2,
  mdf_AddQuantityFK, mdf_DocumentAndCommandUpdate, mdf_QuckLedger2,
  mdf_AddSettingPosIndices, mdf_AddPK_AC_G_LEDGERACCOUNT, mdf_Add_Transaction_triggers,
  mdf_AddFieldsToInv_BalanceOptions, mdf_CorrectCMD_InExplorer, mdf_AddEditorKeyConst,
  mdf_AddRateInStatement, mdf_AddAccountKeyInStatementLine, mdf_AddUdfDataParamStr,
  mdf_AddFixNumberInDocumenttype, mdf_ChangeBranchKey, mdf_AddFieldPlaceCode,
  mdf_QuckLedger3, mdf_AddFieldFolderKey, mdf_QuckLedger_Last, mdf_Add_Account_triggers,
  mdf_CirculationList, mdf_QuckLedger4, mdf_AddBalanceIndice, mdf_QuckLedger5,
  mdf_CirculationList2, mdf_NewGeneralLedger, mdf_AddFieldTo_RPLLOG, mdf_Fix_GD_TAXTYPE,
  mdf_AlterBankStatementTrigger, mdf_QuckLedger6, mdf_AddLinkTables, mdf_TblCalDayFields,
  mdf_AddGoodkeyFK_Inv_PriceLine, mdf_ModifyBlockTriggers, mdf_EvtObject,
  mdf_ModifyBlockTriggers2, mdf_ModifyRecordTriggers, mdf_CirculationList3,
  mdf_DropLBRBUniqueIndices, msf_CorrectBadInvCard, mdf_AddGoodKeyIntoMovement_unit,
  mdf_SuperNewGeneralLedger, mdf_SQLMonitor, mdf_AddBranchToBankAndIndex,
  mdf_AddEmployeeCmd, mdf_AddDTBlock, mdf_RemakeAcEntry, mdf_CorrectInvTrigger,
  mdf_AddInvMakeRest, mdf_ModifyBlockTriggers3, mdf_ModifyBlockTriggers4,
  mdf_wageUpdateFields, mdf_AddGenerators, mdf_AddCheckConstraints,
  mdf_AddUseCompanyKey_Balance, mdf_AddRPLTables, mdf_AddAcEntryBalanceAndAT_P_SYNC,
  mdf_AddOKULPCodeToCompanyCode, mdf_AddIsInternalField, mdf_AddSQLHistTables,
  mdf_ConvertStorage, mdf_AddFKManagerMetadata, mdf_RegenerateLBRBTree, mdf_AddDefaultToBoolean,
  mdf_ConvertBNStatementCommentToBlob, mdf_AddFieldReportlistModalPreview,
  mdf_ChangeUSRCOEF, mdf_ChangeDuplicateAccount, mdf_MovementDocument,
  mdf_Delete_BITrigger_AtSettingPos, mdf_ReportCommand, mdf_DeleteInvCardParams,
  mdf_DeletecbAnalyticFromScript;

const
  cProcCount = 191;

type
  TModifyProc = record
    ModifyProc: TProcAddr;      // Адрес процедуры выполняющей действия по модификации
    ModifyVersion: String;      // Max версия БД для которой выполнять данную модификацию
    NeedDBShutdown: Boolean;    // Требуется монопольный режим
  end;

  // !!! ЭТО ВАЖНО !!!
  //   Следует разделить модификацию данных и структуры БД. Например функция
  // ChangeFilterFullName модифицировала данные в таблице FLT_FILTERCOMPONENT
  // после этого была создана процедура CustomTableModify которая добавляла
  // поле NOT NULL в таблицу GD_CUSTOMTABLE. Т.к. Upgrade не пройдет без запуска модифай
  // в котором заполняется значение поля, мы меняем версию базы данных после
  // добавления поля (Причем менять надо не в CustomTableModify а в SQL скриптах,
  // по которым генерится эталонная база и в которую переносятся данные утилитой
  // Upgrade). При этом процедура модификации фильтра привязывается к той же версии БД
  // что и процедура добавления поля. И если версия выше, то она не выполняется.
  // ПРИ ЭТОМ КАЖДАЯ ПРОЦЕДУРА ДОЛЖНА САМОСТОЯТЕЛЬНО ОСТЛЕЖИВАТЬ НЕОБХОДИМОСТЬ
  // ВЫПОЛНЕНИЯ МОДИФИКАЦИИ. Так в первом случае в процедуре ChangeFilterFullName
  // должна выполняться проверка формата хранения наименования фильтра.
  // Во втором случае в процедуре CustomTableModify должно проверяться наличие
  // добавляемого поля. Данный способ позволяет всего лишь не вызывать устаревшие
  // процедуры, которые для БД начиная с определенной версии не могут пригодится.
  // Кроме того, если добавляется поле которое допускает значение NULL версию БД
  // менять не надо, в противном случае необходимо также увеличить версию БД
  // для процедур которые были привязаны к предыдущей версии БД.
  // Т.е. если процедура ChangeFilterFullName привязана к версии 0000.0001.0000.0038,
  // а процедура CustomTableModify добавляет поле с возможным значением NULL,
  // то есть два варианта действий :
  // 1. Оставляем версию БД неизменной, т.е. CustomTableModify также привязана к
  // версии 0000.0001.0000.0038.
  // 2. Увеличиваем версию БД до 0000.0001.0000.0039, а для процедуры CustomTableModify
  // и для всех процедур с версией 0000.0001.0000.0038 (в частности для ChangeFilterFullName)
  // увеличиваем версию до 0000.0001.0000.0039.
  // Последняя версия БД находится в файле gd_version.sql

  TProcList = array[0..cProcCount - 1] of TModifyProc;

const
  cProcList: TProcList = (
    (ModifyProc: CreateUniqueFunctionName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // Добавление поля branchkey в таблицу at_relations
    (ModifyProc: AddBranchKey; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // Изменение формы отчетов
    (ModifyProc: ChangeReportForm; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // Изменение процедур синхронизации
    (ModifyProc: ChangeSyncProcedures; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // Изменение настроек
    (ModifyProc: ChangeSetting; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // Изменение комманды просморта остатков
    (ModifyProc: ChangeRemainsCommand; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // Изменение комманды просморта хранилища
    (ModifyProc: ChangeStorageCommand; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // Изменение строки компонентов фильтров под классы
    //(ModifyProc: ChangeFilterFullName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Изменение ruid для стандратных документов
    (ModifyProc: ChangeDocumentTypeRUID; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Изменение таблицы gd_ruid
    (ModifyProc: ChangeRUID; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // разделение "полного" имени класса
    (ModifyProc: DivideFullClassName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Изменение названий фильтров и отчетов и создание уникалтных индексов
    (ModifyProc: ChangeFilterReportName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Изменение структуры таблиц настроек
    (ModifyProc: AddEditionDate; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    (ModifyProc: UpdateLocalName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // для всех контактов котрые не входят в папки присвоим пэрент
    (ModifyProc: UpdateContact; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Изменяет триггер в таблице gd_goodtax (инициализация datetax)
    (ModifyProc: AlterTriggerGoodTax; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Изменяет названия шаблонов отчетов на уникальные
    (ModifyProc: ChangeTemplatesName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    (ModifyProc: ChangeForeignForAtFields; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    (ModifyProc: ChangeJournal; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Замена полей день и месяц одним полем дата в таблице Праздники
    (ModifyProc: UpdateHolidays; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //добавление поле доступа к записи для табл. evt_macroslist, rp_reportlist
    (ModifyProc: AddMacrosrightsFields; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //добавление процедур AC_ACCOUNTEXSALDO и AC_CIRCULATIONLIST
    (ModifyProc: AddAccountStoredProc; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //добавление холдинга
    (ModifyProc: AddHolding; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //добавление команд в таблицу GD_COMMAND для аналитики
    (ModifyProc: InsertAnaliseCommands; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //добавление метаданных для поддержки бухгалтерских отчетов
    (ModifyProc: AddTaxTables; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //корректировка представления GD_CONTACTLIST
    (ModifyProc: AlterViewContactList; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Добавление поддержки FBUdf
    (ModifyProc: AddFBUdfSupport; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Добавление счетчика изменений скрипт-функций
    (ModifyProc: SpySFChange; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Добавление udf g_s_delchar
    (ModifyProc: AddUdfDelChar; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Изменение модулекоде для старых функций отчетов
    (ModifyProc: UpdateModuleCode; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //обавление индексов в таблицу evt_macroslist
    (ModifyProc: AddMacrosListIndices; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Корректировка поля displayscript таблицы gd_function для поддержки компиляции
    (ModifyProc: Correct_gd_function; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Добавление раздела Забалансовые и счета 00
    (ModifyProc: AddZeroAccount; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Добавление даты проводки в AC_ENTRY
    (ModifyProc: AddAccountEntryDate; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Добавляет поле в AC_SCRIPT для поддержки конструктора функций проводок
    (ModifyProc: AddFieldFUNCSTOR; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Обновление процедуры корректировки баланса проводки
    (ModifyProc: ModifyAccBalanceEntry; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //Добавляет таблицу для настройки остатков, уникальный индекс NAME на gd_tax
    (ModifyProc: AddNewInventTable; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
    //Добавляет представление с реквизитами клиента
    (ModifyProc: CreateViewGd_V_COMPANY; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
    //Добавляет поддержки кол-нных пок-лей проводки
    (ModifyProc: AddQuantityMetaData; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
    //Корректировка FOREIGN KEY на главную аналитику в счете
    (ModifyProc: ModifyAnaliticalForeignKey; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
     //Добавлениее полей в gd_documenttype
    (ModifyProc: AddFieldDocumentType; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
    //Добавление таблиц автоматичесих проводок
    (ModifyProc: AddAutoTransactionTables; ModifyVersion: '0000.0001.0000.0036'; NeedDBShutdown: True),
    //Добавляет поле в AC_LEDGER и запись в GD_COMMAND для поддержки конструктора функций проводок
    (ModifyProc: InsertLedgerCommands; ModifyVersion: '0000.0001.0000.0036'; NeedDBShutdown: True),
    //
    (ModifyProc: UpdateContact2; ModifyVersion: '0000.0001.0000.0036'; NeedDBShutdown: True),
    //Добавляет поле DISPLAYINMENU в EVT_MARCOSLIST(отображение макроса в меню формы)
    (ModifyProc: AddDisplayInMenuField; ModifyVersion: '0000.0001.0000.0036'; NeedDBShutdown: True),
    //Добавление полей для отображения
    (ModifyProc: ChangeAtRelations; ModifyVersion: '0000.0001.0000.0038'; NeedDBShutdown: True),
    //Добавление структуры для хранения файлов в БД
    (ModifyProc: Create_gd_File; ModifyVersion: '0000.0001.0000.0039'; NeedDBShutdown: True),
    //добавление таблицы для хранения настроек Оборотки по аналитике
    (ModifyProc: AddOverTurnByAnal; ModifyVersion: '0000.0001.0000.0040'; NeedDBShutdown: True),
    //добавление полей IncludeInternalMovement
    (ModifyProc: AddIncludeInternalMovment; ModifyVersion: '0000.0001.0000.0041'; NeedDBShutdown: True),
    //добавление индексов
    (ModifyProc: AddEntryIndices; ModifyVersion: '0000.0001.0000.0042'; NeedDBShutdown: True),
    (ModifyProc: AddQuantityField; ModifyVersion: '0000.0001.0000.0043'; NeedDBShutdown: True),
    (ModifyProc: AddEntryIndices2; ModifyVersion: '0000.0001.0000.0044'; NeedDBShutdown: True),
    //Increase length of fields setcondition and refcondition in at_fields
    (ModifyProc: SetDomainCondition; ModifyVersion: '0000.0001.0000.0044'; NeedDBShutdown: True),
    // Добавление поля ischecknumber в gd_documenttype
    (ModifyProc: AddIsCheckNumberField; ModifyVersion: '0000.0001.0000.0044'; NeedDBShutdown: True),
    // Изменение домена DGOLDQUANTITY на NUMERIC(15, 8)
    (ModifyProc: ChangeDGoldQuantity; ModifyVersion: '0000.0001.0000.0045'; NeedDBShutdown: True),
    // Изменение триггера INV_AU_MOVEMENT
    (ModifyProc: ChangeINV_AU_MOVEMENT; ModifyVersion: '0000.0001.0000.0046'; NeedDBShutdown: True),
    // Увеличение длины поля name в gd_function
    (ModifyProc: AddLongNameFieldInScript; ModifyVersion: '0000.0001.0000.0046'; NeedDBShutdown: True),
    // Добавление полей в AT_SETTING для нового формата настроек. Yuri.
    (ModifyProc: AddGSFFields; ModifyVersion: '0000.0001.0000.0047'; NeedDBShutdown: True),
    //Обновление процедуры оборотной ведомости
    (ModifyProc: ModifyAccountCirculation; ModifyVersion: '0000.0001.0000.0047'; NeedDBShutdown: True),
    //Новые бух. отчеты
    (ModifyProc: NewAcctReports; ModifyVersion: '0000.0001.0000.0048'; NeedDBShutdown: True),
    (ModifyProc: UniqueLName; ModifyVersion: '0000.0001.0000.0049'; NeedDBShutdown: True),
    //Добавление поля description в gd_files
    (ModifyProc: UpdateFiles; ModifyVersion: '0000.0001.0000.0049'; NeedDBShutdown: True),
    //Добавление поля accountkey  в таблицу ac_trrecord
    (ModifyProc: AddAccountKeyToTypeEntry; ModifyVersion: '0000.0001.0000.0050'; NeedDBShutdown: True),
    //Добавляет поле в AC_TRRECORD сохранять нулевые проводки или нет
    (ModifyProc: AddFieldSaveNullEntry; ModifyVersion: '0000.0001.0000.0050'; NeedDBShutdown: True),
    (ModifyProc: NewTaxies; ModifyVersion: '0000.0001.0000.0051'; NeedDBShutdown: True),
    //Преоразование поля usergroupname в таблице rp_reportgroup к РУИДу
    (ModifyProc: UserGroupToRUID; ModifyVersion: '0000.0001.0000.0052'; NeedDBShutdown: True),
    (ModifyProc: NewTrEntries; ModifyVersion: '0000.0001.0000.0053'; NeedDBShutdown: True),
    (ModifyProc: GrantTables; ModifyVersion: '0000.0001.0000.0053'; NeedDBShutdown: True),
    (ModifyProc: QuickLedger; ModifyVersion: '0000.0001.0000.0054'; NeedDBShutdown: True),
    (ModifyProc: AddTransactionFuntionField; ModifyVersion: '0000.0001.0000.0055'; NeedDBShutdown: True),
    (ModifyProc: AddQuantityFK; ModifyVersion: '0000.0001.0000.0057'; NeedDBShutdown: True),
    (ModifyProc: DocumentAndCommandUpdate; ModifyVersion: '0000.0001.0000.0058'; NeedDBShutdown: True),
    //Исправление ошибки в триггере на таблицу ac_entry
    (ModifyProc: QuickLedger2; ModifyVersion: '0000.0001.0000.0059'; NeedDBShutdown: True),
    //Добавление индексов на таблицу at_settingpos
    (ModifyProc: AddSettingPosIndices; ModifyVersion: '0000.0001.0000.0059'; NeedDBShutdown: True),
    (ModifyProc: AddPK_AC_G_LEDGERACCOUNT; ModifyVersion: '0000.0001.0000.0060'; NeedDBShutdown: True),
    (ModifyProc: Add_Transaction_triggers; ModifyVersion: '0000.0001.0000.0060'; NeedDBShutdown: True),
    (ModifyProc: AddFieldsToInv_BalanceOptions; ModifyVersion: '0000.0001.0000.0061'; NeedDBShutdown: True),
    (ModifyProc: AddEditorKeyConst; ModifyVersion: '0000.0001.0000.0063'; NeedDBShutdown: True),
    //Добавление поля rate в бансковскую выписку
    (ModifyProc: AddRateInStatement; ModifyVersion: '0000.0001.0000.0064'; NeedDBShutdown: True),
    //Добавление ссылки на ac_account в таблицу bn_bankstatementline
    (ModifyProc: AddAccountKeyInStatementLine; ModifyVersion: '0000.0001.0000.0066'; NeedDBShutdown: True),
    (ModifyProc: AddUdfDataParamStr; ModifyVersion: '0000.0001.0000.0067'; NeedDBShutdown: True),
    //Добавление флага фиксированной длины номера в gd_lastnumber
    (ModifyProc: AddFixNumberInDocumenttype; ModifyVersion: '0000.0001.0000.0068'; NeedDBShutdown: True),
    //Изменение branchkey в at_relations и gd_documenttype
    (ModifyProc: ChangeBranchKey; ModifyVersion: '0000.0001.0000.0069'; NeedDBShutdown: True),
    (ModifyProc: AddFieldPlaceCode; ModifyVersion: '0000.0001.0000.0070'; NeedDBShutdown: True),
    (ModifyProc: QuickLedger3; ModifyVersion: '0000.0001.0000.0071'; NeedDBShutdown: True),
    (ModifyProc: AddFieldFolderKey; ModifyVersion: '0000.0001.0000.0072'; NeedDBShutdown: True),
    //Добавление таблиц и команд для Главной книги
    (ModifyProc: InsertGeneralLedgerCommands; ModifyVersion: '0000.0001.0000.0074'; NeedDBShutdown: True),
    (ModifyProc: Add_Account_Triggers; ModifyVersion: '0000.0001.0000.0075'; NeedDBShutdown: True),
    (ModifyProc: QuickLedger_last; ModifyVersion: '0000.0001.0000.0076'; NeedDBShutdown: True),
    {Здесь изменена версия БД!!!!}
    (ModifyProc: CorrectCMD_InExplorer; ModifyVersion: '0000.0001.0000.0077'; NeedDBShutdown: True),
    (ModifyProc: CirculationList; ModifyVersion: '0000.0001.0000.0077'; NeedDBShutdown: True),
    (ModifyProc: GetSimpleLedger2; ModifyVersion: '0000.0001.0000.0078'; NeedDBShutdown: True),
    (ModifyProc: QuickLedger4; ModifyVersion: '0000.0001.0000.0079'; NeedDBShutdown: True),
    (ModifyProc: AddBalanceIndice; ModifyVersion: '0000.0001.0000.0080'; NeedDBShutdown: True),
    (ModifyProc: CirculationList2; ModifyVersion: '0000.0001.0000.0083'; NeedDBShutdown: True),
    (ModifyProc: NewGeneralLedger; ModifyVersion: '0000.0001.0000.0084'; NeedDBShutdown: True),
    (ModifyProc: AddFieldTo_RPLLOG; ModifyVersion: '0000.0001.0000.0085'; NeedDBShutdown: True),
    (ModifyProc: Fix_GD_TAXTYPE; ModifyVersion: '0000.0001.0000.0086'; NeedDBShutdown: True),
    (ModifyProc: QuickLedger5; ModifyVersion: '0000.0001.0000.0087'; NeedDBShutdown: True),
    (ModifyProc: AlterBankStatementTrigger; ModifyVersion: '0000.0001.0000.0087'; NeedDBShutdown: True),
    (ModifyProc: QuickLedger6; ModifyVersion: '0000.0001.0000.0088'; NeedDBShutdown: True),
    (ModifyProc: AddLinkTables; ModifyVersion: '0000.0001.0000.0089'; NeedDBShutdown: True),
    (ModifyProc: ModifyTblCalFields; ModifyVersion: '0000.0001.0000.0089'; NeedDBShutdown: True),
    (ModifyProc: ModifyTblCalDayFields; ModifyVersion: '0000.0001.0000.0089'; NeedDBShutdown: True),
    (ModifyProc: AddGoodkeyFK_Inv_PriceLine; ModifyVersion: '0000.0001.0000.0090'; NeedDBShutdown: True),
    (ModifyProc: ModifyBlockTriggers; ModifyVersion: '0000.0001.0000.0092'; NeedDBShutdown: True),
    (ModifyProc: AddAccountReview; ModifyVersion: '0000.0001.0000.0094'; NeedDBShutdown: True),
    (ModifyProc: ModifyBlockTriggers2; ModifyVersion: '0000.0001.0000.0095'; NeedDBShutdown: True),
    (ModifyProc: ModifyRecordTriggers; ModifyVersion: '0000.0001.0000.0096'; NeedDBShutdown: True),
    (ModifyProc: CirculationList3; ModifyVersion: '0000.0001.0000.0096'; NeedDBShutdown: True),
    (ModifyProc: DropLBRBUniqueIndices; ModifyVersion: '0000.0001.0000.0096'; NeedDBShutdown: True),
    (ModifyProc: ClearEvtObject; ModifyVersion: '0000.0001.0000.0096'; NeedDBShutdown: True),
    (ModifyProc: CorrectBadInvCard; ModifyVersion: '0000.0001.0000.0096'; NeedDBShutdown: True),
    (ModifyProc: SuperNewGeneralLedger; ModifyVersion: '0000.0001.0000.0097'; NeedDBShutdown: True),
    (ModifyProc: AddGoodKeyIntoMovement; ModifyVersion: '0000.0001.0000.0098'; NeedDBShutdown: True),
    (ModifyProc: SQLMonitor; ModifyVersion: '0000.0001.0000.0099'; NeedDBShutdown: True),
    (ModifyProc: AddBranchToBankAndIndex; ModifyVersion: '0000.0001.0000.0100'; NeedDBShutdown: True),
    (ModifyProc: AddBranchToBankStatement; ModifyVersion: '0000.0001.0000.0101'; NeedDBShutdown: True),
    (ModifyProc: AddEmployeeCmd; ModifyVersion: '0000.0001.0000.0102'; NeedDBShutdown: True),
    (ModifyProc: AddDTBlock; ModifyVersion: '0000.0001.0000.0105'; NeedDBShutdown: True),
    (ModifyProc: RemakeACENTRY; ModifyVersion: '0000.0001.0000.0105'; NeedDBShutdown: True),
    (ModifyProc: RemakeACENTRY_NEW; ModifyVersion: '0000.0001.0000.0105'; NeedDBShutdown: True),
    (ModifyProc: RemakeExStored; ModifyVersion: '0000.0001.0000.0106'; NeedDBShutdown: True),
    (ModifyProc: CorrectInvTrigger; ModifyVersion: '0000.0001.0000.0107'; NeedDBShutdown: True),
    (ModifyProc: Add_INV_GETCARDMOVEMENT; ModifyVersion: '0000.0001.0000.0109'; NeedDBShutdown: True),
    (ModifyProc: ModifyBlockTriggers3; ModifyVersion: '0000.0001.0000.0115'; NeedDBShutdown: True),
    (ModifyProc: ModifyBlockTriggers4; ModifyVersion: '0000.0001.0000.0117'; NeedDBShutdown: True),
    (ModifyProc: ModifyWageFields; ModifyVersion: '0000.0001.0000.0118'; NeedDBShutdown: True),
    (ModifyProc: ModifyBankRuid; ModifyVersion: '0000.0001.0000.0120'; NeedDBShutdown: True),
    (ModifyProc: ModifyWageFields1; ModifyVersion: '0000.0001.0000.0121'; NeedDBShutdown: True),
    (ModifyProc: AddGenerators; ModifyVersion: '0000.0001.0000.0123'; NeedDBShutdown: True),
    (ModifyProc: AddCheckConstraints; ModifyVersion: '0000.0001.0000.0125'; NeedDBShutdown: True),
    (ModifyProc: AddUseCompanyKey_Balance; ModifyVersion: '0000.0001.0000.0126'; NeedDBShutdown: True),
    (ModifyProc: ModifyRpTemplateTrigger; ModifyVersion: '0000.0001.0000.0127'; NeedDBShutdown: True),
    (ModifyProc: AddSQLHistTables; ModifyVersion: '0000.0001.0000.0138'; NeedDBShutdown: True),
    (ModifyProc: AddRPLTables; ModifyVersion: '0000.0001.0000.0139'; NeedDBShutdown: True),
    (ModifyProc: AddAcEntryBalanceAndAT_P_SYNC; ModifyVersion: '0000.0001.0000.0140'; NeedDBShutdown: True),
    (ModifyProc: AddOKULPCodeToCompanyCode; ModifyVersion: '0000.0001.0000.0141'; NeedDBShutdown: True),
    (ModifyProc: AddIsInternalField; ModifyVersion: '0000.0001.0000.0142'; NeedDBShutdown: True),
    (ModifyProc: AddMissedGrantsToAcEntryBalanceProcedures; ModifyVersion: '0000.0001.0000.0143'; NeedDBShutdown: True),
    (ModifyProc: ConvertStorage; ModifyVersion: '0000.0001.0000.0144'; NeedDBShutdown: True),
    (ModifyProc: AddEdtiorKeyEditionDate2Storage; ModifyVersion: '0000.0001.0000.0145'; NeedDBShutdown: True),
    (ModifyProc: DropLBRBStorageTree; ModifyVersion: '0000.0001.0000.0146'; NeedDBShutdown: True),
    (ModifyProc: AddAcEntryBalanceAndAT_P_SYNC_Second; ModifyVersion: '0000.0001.0000.0147'; NeedDBShutdown: True),
    (ModifyProc: MakeLBIndexNonUnique; ModifyVersion: '0000.0001.0000.0148'; NeedDBShutdown: True),
    (ModifyProc: AddFKManagerMetadata; ModifyVersion: '0000.0001.0000.0149'; NeedDBShutdown: True),
    (ModifyProc: RegenerateLBRBTree; ModifyVersion: '0000.0001.0000.0150'; NeedDBShutdown: True),
    (ModifyProc: AddDefaultToBoolean; ModifyVersion: '0000.0001.0000.0151'; NeedDBShutdown: True),
    (ModifyProc: ChangeIsCheckNumberType; ModifyVersion: '0000.0001.0000.0152'; NeedDBShutdown: True),
    (ModifyProc: DropRGIndex; ModifyVersion: '0000.0001.0000.0153'; NeedDBShutdown: True),
    (ModifyProc: CreateRGIndex; ModifyVersion: '0000.0001.0000.0154'; NeedDBShutdown: True),
    (ModifyProc: RegenerateLBRBTree2; ModifyVersion: '0000.0001.0000.0155'; NeedDBShutdown: True),
    (ModifyProc: ConvertBNStatementCommentToBlob; ModifyVersion: '0000.0001.0000.0156'; NeedDBShutdown: True),
    (ModifyProc: ConvertDatePeriodComponent; ModifyVersion: '0000.0001.0000.0158'; NeedDBShutdown: True),
    (ModifyProc: UpdateGDRefConstraints; ModifyVersion: '0000.0001.0000.0159'; NeedDBShutdown: True),
    (ModifyProc: AlterUserStorageTrigger; ModifyVersion: '0000.0001.0000.0160'; NeedDBShutdown: True),
    (ModifyProc: AddGDRUIDCheck; ModifyVersion: '0000.0001.0000.0161'; NeedDBShutdown: True),
    (ModifyProc: ModifyRUIDProcedure; ModifyVersion: '0000.0001.0000.0162'; NeedDBShutdown: True),
    (ModifyProc: ModifyGDRUIDCheck; ModifyVersion: '0000.0001.0000.0163'; NeedDBShutdown: True),
    (ModifyProc: DeleteLBRBFromSettingPos; ModifyVersion: '0000.0001.0000.0164'; NeedDBShutdown: True),
    (ModifyProc: AddFieldReportlistModalPreview; ModifyVersion: '0000.0001.0000.0166'; NeedDBShutdown: True),
    (ModifyProc: ChangeUSRCOEF; ModifyVersion: '0000.0001.0000.0167'; NeedDBShutdown: True),
    (ModifyProc: AddFieldMacrosListRunLogIn; ModifyVersion: '0000.0001.0000.0169'; NeedDBShutdown: True),
    (ModifyProc: ChangeDuplicateAccount; ModifyVersion: '0000.0001.0000.0171'; NeedDBShutdown: True),
    (ModifyProc: MovementDocument; ModifyVersion: '0000.0001.0000.0175'; NeedDBShutdown: True),
    (ModifyProc: DeleteBITRiggerAtSettingPos; ModifyVersion: '0000.0001.0000.0178'; NeedDBShutdown: True),
    (ModifyProc: DeleteMetaDataSimpleTableAtSettingPos; ModifyVersion: '0000.0001.0000.0179'; NeedDBShutdown: True),
    (ModifyProc: DeleteMetaDataTableToTableAtSettingPos; ModifyVersion: '0000.0001.0000.0180'; NeedDBShutdown: True),
    (ModifyProc: DeleteMetaDataTreeTableAtSettingPos; ModifyVersion: '0000.0001.0000.0181'; NeedDBShutdown: True),
    (ModifyProc: AddContractorKeyToBNStatementLine; ModifyVersion: '0000.0001.0000.0182'; NeedDBShutdown: True),
    (ModifyProc: DeleteBI5Triggers; ModifyVersion: '0000.0001.0000.0183'; NeedDBShutdown: True),
    (ModifyProc: DeleteMetaDataSet; ModifyVersion: '0000.0001.0000.0184'; NeedDBShutdown: True),
    (ModifyProc: DeleteDomain; ModifyVersion: '0000.0001.0000.0185'; NeedDBShutdown: True),
    (ModifyProc: Correct_gd_ai_goodgroup_protect; ModifyVersion: '0000.0001.0000.0186'; NeedDBShutdown: True),
    (ModifyProc: Correct_ac_companyaccount_triggers; ModifyVersion: '0000.0001.0000.0187'; NeedDBShutdown: True),
    (ModifyProc: DeleteSF; ModifyVersion: '0000.0001.0000.0188'; NeedDBShutdown: True),
    (ModifyProc: DeleteCardParamsItem; ModifyVersion: '0000.0001.0000.0189'; NeedDBShutdown: True),
    (ModifyProc: Correct_inv_bu_movement_triggers; ModifyVersion: '0000.0001.0000.0190'; NeedDBShutdown: True),
    (ModifyProc: ChangeDuplicateAccount2; ModifyVersion: '0000.0001.0000.0191'; NeedDBShutdown: True),
    (ModifyProc: DeletecbAnalyticFromScript; ModifyVersion: '0000.0001.0000.0192'; NeedDBShutdown: True),
    (ModifyProc: AddNSMetadata; ModifyVersion: '0000.0001.0000.0193'; NeedDBShutdown: True),
    (ModifyProc: Issue2846; ModifyVersion: '0000.0001.0000.0194'; NeedDBShutdown: False),
    (ModifyProc: Issue2688; ModifyVersion: '0000.0001.0000.0195'; NeedDBShutdown: False),
    (ModifyProc: AddUqConstraintToGD_RUID; ModifyVersion: '0000.0001.0000.0196'; NeedDBShutdown: True),
    (ModifyProc: DropConstraintFromAT_OBJECT; ModifyVersion: '0000.0001.0000.0197'; NeedDBShutdown: True),
    (ModifyProc: MoveSubObjects; ModifyVersion: '0000.0001.0000.0200'; NeedDBShutdown: False),
    (ModifyProc: AddUqConstraintToGD_RUID2; ModifyVersion: '0000.0001.0000.0201'; NeedDBShutdown: True),
    (ModifyProc: AddCurrModified; ModifyVersion: '0000.0001.0000.0202'; NeedDBShutdown: False),
    (ModifyProc: AddEditionDate; ModifyVersion: '0000.0001.0000.0203'; NeedDBShutdown: False),
    (ModifyProc: CorrectNSTriggers; ModifyVersion: '0000.0001.0000.0204'; NeedDBShutdown: False),
    (ModifyProc: AddEditionDate2; ModifyVersion: '0000.0001.0000.0205'; NeedDBShutdown: True),
    (ModifyProc: AddADAtObjectTrigger; ModifyVersion: '0000.0001.0000.0206'; NeedDBShutdown: False)
  );

implementation

end.

