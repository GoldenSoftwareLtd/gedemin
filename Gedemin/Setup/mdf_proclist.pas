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
  mdf_AddEmployeeCmd, mdf_AddDTBlock, mdf_RemakeAcEntry, mdf_CorrectInvTrigger, mdf_AddInvMakeRest,
  mdf_ModifyBlockTriggers3, mdf_ModifyBlockTriggers4, mdf_wageUpdateFields, mdf_AddGenerators,
  mdf_AddCheckConstraints, mdf_AddUseCompanyKey_Balance, mdf_AddRPLTables, mdf_AddAcEntryBalanceAndAT_P_SYNC,
  mdf_AddOKULPCodeToCompanyCode, mdf_AddIsInternalField, mdf_AddSQLHistTables, mdf_ConvertStorage,
  mdf_AddFKManagerMetadata, mdf_RegenerateLBRBTree, mdf_AddDefaultToBoolean, mdf_ConvertBNStatementCommentToBlob, mdf_AddFieldReportlistModalPreview,
  mdf_ChangeUSRCOEF, mdf_ChangeDuplicateAccount, mdf_MovementDocument;

const
  cProcCount = 164;

type
  TModifyProc = record
    ModifyProc: TProcAddr;      // Адрес процедуры выполняющей действия по модификации
    ModifyVersion: String;      // Max версия БД для которой выполнять данную модификацию
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
    (ModifyProc: CreateUniqueFunctionName; ModifyVersion: '0000.0001.0000.0034'),
    // Добавление поля branchkey в таблицу at_relations
    (ModifyProc: AddBranchKey; ModifyVersion: '0000.0001.0000.0034'),
    // Изменение формы отчетов
    (ModifyProc: ChangeReportForm; ModifyVersion: '0000.0001.0000.0034'),
    // Изменение процедур синхронизации
    (ModifyProc: ChangeSyncProcedures; ModifyVersion: '0000.0001.0000.0034'),
    // Изменение настроек
    (ModifyProc: ChangeSetting; ModifyVersion: '0000.0001.0000.0034'),
    // Изменение комманды просморта остатков
    (ModifyProc: ChangeRemainsCommand; ModifyVersion: '0000.0001.0000.0034'),
    // Изменение комманды просморта хранилища
    (ModifyProc: ChangeStorageCommand; ModifyVersion: '0000.0001.0000.0034'),
    // Изменение строки компонентов фильтров под классы
    //(ModifyProc: ChangeFilterFullName; ModifyVersion: '0000.0001.0000.0034'),
    //Изменение ruid для стандратных документов
    (ModifyProc: ChangeDocumentTypeRUID; ModifyVersion: '0000.0001.0000.0034'),
    //Изменение таблицы gd_ruid
    (ModifyProc: ChangeRUID; ModifyVersion: '0000.0001.0000.0034'),
    // разделение "полного" имени класса
    (ModifyProc: DivideFullClassName; ModifyVersion: '0000.0001.0000.0034'),
    //Изменение названий фильтров и отчетов и создание уникалтных индексов
    (ModifyProc: ChangeFilterReportName; ModifyVersion: '0000.0001.0000.0034'),
    //Изменение структуры таблиц настроек
    (ModifyProc: AddEditionDate; ModifyVersion: '0000.0001.0000.0034'),
    (ModifyProc: UpdateLocalName; ModifyVersion: '0000.0001.0000.0034'),
    // для всех контактов котрые не входят в папки присвоим пэрент
    (ModifyProc: UpdateContact; ModifyVersion: '0000.0001.0000.0034'),
    //Изменяет триггер в таблице gd_goodtax (инициализация datetax)
    (ModifyProc: AlterTriggerGoodTax; ModifyVersion: '0000.0001.0000.0034'),
    //Изменяет названия шаблонов отчетов на уникальные
    (ModifyProc: ChangeTemplatesName; ModifyVersion: '0000.0001.0000.0034'),
    (ModifyProc: ChangeForeignForAtFields; ModifyVersion: '0000.0001.0000.0034'),
    (ModifyProc: ChangeJournal; ModifyVersion: '0000.0001.0000.0034'),
    //Замена полей день и месяц одним полем дата в таблице Праздники
    (ModifyProc: UpdateHolidays; ModifyVersion: '0000.0001.0000.0034'),
    //добавление поле доступа к записи для табл. evt_macroslist, rp_reportlist
    (ModifyProc: AddMacrosrightsFields; ModifyVersion: '0000.0001.0000.0034'),
    //добавление процедур AC_ACCOUNTEXSALDO и AC_CIRCULATIONLIST
    (ModifyProc: AddAccountStoredProc; ModifyVersion: '0000.0001.0000.0034'),
    //добавление холдинга
    (ModifyProc: AddHolding; ModifyVersion: '0000.0001.0000.0034'),
    //добавление команд в таблицу GD_COMMAND для аналитики
    (ModifyProc: InsertAnaliseCommands; ModifyVersion: '0000.0001.0000.0034'),
    //добавление метаданных для поддержки бухгалтерских отчетов
    (ModifyProc: AddTaxTables; ModifyVersion: '0000.0001.0000.0034'),
    //корректировка представления GD_CONTACTLIST
    (ModifyProc: AlterViewContactList; ModifyVersion: '0000.0001.0000.0034'),
    //Добавление поддержки FBUdf
    (ModifyProc: AddFBUdfSupport; ModifyVersion: '0000.0001.0000.0034'),
    //Добавление счетчика изменений скрипт-функций
    (ModifyProc: SpySFChange; ModifyVersion: '0000.0001.0000.0034'),
    //Добавление udf g_s_delchar
    (ModifyProc: AddUdfDelChar; ModifyVersion: '0000.0001.0000.0034'),
    //Изменение модулекоде для старых функций отчетов
    (ModifyProc: UpdateModuleCode; ModifyVersion: '0000.0001.0000.0034'),
    //обавление индексов в таблицу evt_macroslist
    (ModifyProc: AddMacrosListIndices; ModifyVersion: '0000.0001.0000.0034'),
    //Корректировка поля displayscript таблицы gd_function для поддержки компиляции
    (ModifyProc: Correct_gd_function; ModifyVersion: '0000.0001.0000.0034'),
    //Добавление раздела Забалансовые и счета 00
    (ModifyProc: AddZeroAccount; ModifyVersion: '0000.0001.0000.0034'),
    //Добавление даты проводки в AC_ENTRY
    (ModifyProc: AddAccountEntryDate; ModifyVersion: '0000.0001.0000.0034'),
    //Добавляет поле в AC_SCRIPT для поддержки конструктора функций проводок
    (ModifyProc: AddFieldFUNCSTOR; ModifyVersion: '0000.0001.0000.0034'),
    //Обновление процедуры корректировки баланса проводки
    (ModifyProc: ModifyAccBalanceEntry; ModifyVersion: '0000.0001.0000.0034'),
    //Добавляет таблицу для настройки остатков, уникальный индекс NAME на gd_tax
    (ModifyProc: AddNewInventTable; ModifyVersion: '0000.0001.0000.0035'),
    //Добавляет представление с реквизитами клиента
    (ModifyProc: CreateViewGd_V_COMPANY; ModifyVersion: '0000.0001.0000.0035'),
    //Добавляет поддержки кол-нных пок-лей проводки
    (ModifyProc: AddQuantityMetaData; ModifyVersion: '0000.0001.0000.0035'),
    //Корректировка FOREIGN KEY на главную аналитику в счете
    (ModifyProc: ModifyAnaliticalForeignKey; ModifyVersion: '0000.0001.0000.0035'),
     //Добавлениее полей в gd_documenttype
    (ModifyProc: AddFieldDocumentType; ModifyVersion: '0000.0001.0000.0035'),
    //Добавление таблиц автоматичесих проводок
    (ModifyProc: AddAutoTransactionTables; ModifyVersion: '0000.0001.0000.0036'),
    //Добавляет поле в AC_LEDGER и запись в GD_COMMAND для поддержки конструктора функций проводок
    (ModifyProc: InsertLedgerCommands; ModifyVersion: '0000.0001.0000.0036'),
    //
    (ModifyProc: UpdateContact2; ModifyVersion: '0000.0001.0000.0036'),
    //Добавляет поле DISPLAYINMENU в EVT_MARCOSLIST(отображение макроса в меню формы)
    (ModifyProc: AddDisplayInMenuField; ModifyVersion: '0000.0001.0000.0036'),
    //Добавление полей для отображения
    (ModifyProc: ChangeAtRelations; ModifyVersion: '0000.0001.0000.0038'),
    //Добавление структуры для хранения файлов в БД
    (ModifyProc: Create_gd_File; ModifyVersion: '0000.0001.0000.0039'),
    //добавление таблицы для хранения настроек Оборотки по аналитике
    (ModifyProc: AddOverTurnByAnal; ModifyVersion: '0000.0001.0000.0040'),
    //добавление полей IncludeInternalMovement
    (ModifyProc: AddIncludeInternalMovment; ModifyVersion: '0000.0001.0000.0041'),
    //добавление индексов
    (ModifyProc: AddEntryIndices; ModifyVersion: '0000.0001.0000.0042'),
    (ModifyProc: AddQuantityField; ModifyVersion: '0000.0001.0000.0043'),
    (ModifyProc: AddEntryIndices2; ModifyVersion: '0000.0001.0000.0044'),
    //Increase length of fields setcondition and refcondition in at_fields
    (ModifyProc: SetDomainCondition; ModifyVersion: '0000.0001.0000.0044'),
    // Добавление поля ischecknumber в gd_documenttype
    (ModifyProc: AddIsCheckNumberField; ModifyVersion: '0000.0001.0000.0044'),
    // Изменение домена DGOLDQUANTITY на NUMERIC(15, 8)
    (ModifyProc: ChangeDGoldQuantity; ModifyVersion: '0000.0001.0000.0045'),
    // Изменение триггера INV_AU_MOVEMENT
    (ModifyProc: ChangeINV_AU_MOVEMENT; ModifyVersion: '0000.0001.0000.0046'),
    // Увеличение длины поля name в gd_function
    (ModifyProc: AddLongNameFieldInScript; ModifyVersion: '0000.0001.0000.0046'),
    // Добавление полей в AT_SETTING для нового формата настроек. Yuri.
    (ModifyProc: AddGSFFields; ModifyVersion: '0000.0001.0000.0047'),
    //Обновление процедуры оборотной ведомости
    (ModifyProc: ModifyAccountCirculation; ModifyVersion: '0000.0001.0000.0047'),
    //Новые бух. отчеты
    (ModifyProc: NewAcctReports; ModifyVersion: '0000.0001.0000.0048'),
    (ModifyProc: UniqueLName; ModifyVersion: '0000.0001.0000.0049'),
    //Добавление поля description в gd_files
    (ModifyProc: UpdateFiles; ModifyVersion: '0000.0001.0000.0049'),
    //Добавление поля accountkey  в таблицу ac_trrecord
    (ModifyProc: AddAccountKeyToTypeEntry; ModifyVersion: '0000.0001.0000.0050'),
    //Добавляет поле в AC_TRRECORD сохранять нулевые проводки или нет
    (ModifyProc: AddFieldSaveNullEntry; ModifyVersion: '0000.0001.0000.0050'),
    (ModifyProc: NewTaxies; ModifyVersion: '0000.0001.0000.0051'),
    //Преоразование поля usergroupname в таблице rp_reportgroup к РУИДу
    (ModifyProc: UserGroupToRUID; ModifyVersion: '0000.0001.0000.0052'),
    (ModifyProc: NewTrEntries; ModifyVersion: '0000.0001.0000.0053'),
    (ModifyProc: GrantTables; ModifyVersion: '0000.0001.0000.0053'),
    (ModifyProc: QuickLedger; ModifyVersion: '0000.0001.0000.0054'),
    (ModifyProc: AddTransactionFuntionField; ModifyVersion: '0000.0001.0000.0055'),
    (ModifyProc: AddQuantityFK; ModifyVersion: '0000.0001.0000.0057'),
    (ModifyProc: DocumentAndCommandUpdate; ModifyVersion: '0000.0001.0000.0058'),
    //Исправление ошибки в триггере на таблицу ac_entry
    (ModifyProc: QuickLedger2; ModifyVersion: '0000.0001.0000.0059'),
    //Добавление индексов на таблицу at_settingpos
    (ModifyProc: AddSettingPosIndices; ModifyVersion: '0000.0001.0000.0059'),
    (ModifyProc: AddPK_AC_G_LEDGERACCOUNT; ModifyVersion: '0000.0001.0000.0060'),
    (ModifyProc: Add_Transaction_triggers; ModifyVersion: '0000.0001.0000.0060'),
    (ModifyProc: AddFieldsToInv_BalanceOptions; ModifyVersion: '0000.0001.0000.0061'),
    (ModifyProc: AddEditorKeyConst; ModifyVersion: '0000.0001.0000.0063'),
    //Добавление поля rate в бансковскую выписку
    (ModifyProc: AddRateInStatement; ModifyVersion: '0000.0001.0000.0064'),
    //Добавление ссылки на ac_account в таблицу bn_bankstatementline
    (ModifyProc: AddAccountKeyInStatementLine; ModifyVersion: '0000.0001.0000.0066'),
    (ModifyProc: AddUdfDataParamStr; ModifyVersion: '0000.0001.0000.0067'),
    //Добавление флага фиксированной длины номера в gd_lastnumber
    (ModifyProc: AddFixNumberInDocumenttype; ModifyVersion: '0000.0001.0000.0068'),
    //Изменение branchkey в at_relations и gd_documenttype
    (ModifyProc: ChangeBranchKey; ModifyVersion: '0000.0001.0000.0069'),
    (ModifyProc: AddFieldPlaceCode; ModifyVersion: '0000.0001.0000.0070'),
    (ModifyProc: QuickLedger3; ModifyVersion: '0000.0001.0000.0071'),
    (ModifyProc: AddFieldFolderKey; ModifyVersion: '0000.0001.0000.0072'),
    //Добавление таблиц и команд для Главной книги
    (ModifyProc: InsertGeneralLedgerCommands; ModifyVersion: '0000.0001.0000.0074'),
    (ModifyProc: Add_Account_Triggers; ModifyVersion: '0000.0001.0000.0075'),
    (ModifyProc: QuickLedger_last; ModifyVersion: '0000.0001.0000.0076'),
    {Здесь изменена версия БД!!!!}
    (ModifyProc: CorrectCMD_InExplorer; ModifyVersion: '0000.0001.0000.0077'),
    (ModifyProc: CirculationList; ModifyVersion: '0000.0001.0000.0077'),
    (ModifyProc: GetSimpleLedger2; ModifyVersion: '0000.0001.0000.0078'),
    (ModifyProc: QuickLedger4; ModifyVersion: '0000.0001.0000.0079'),
    (ModifyProc: AddBalanceIndice; ModifyVersion: '0000.0001.0000.0080'),
    (ModifyProc: CirculationList2; ModifyVersion: '0000.0001.0000.0083'),
    (ModifyProc: NewGeneralLedger; ModifyVersion: '0000.0001.0000.0084'),
    (ModifyProc: AddFieldTo_RPLLOG; ModifyVersion: '0000.0001.0000.0085'),
    (ModifyProc: Fix_GD_TAXTYPE; ModifyVersion: '0000.0001.0000.0086'),
    (ModifyProc: QuickLedger5; ModifyVersion: '0000.0001.0000.0087'),
    (ModifyProc: AlterBankStatementTrigger; ModifyVersion: '0000.0001.0000.0087'),
    (ModifyProc: QuickLedger6; ModifyVersion: '0000.0001.0000.0088'),
    (ModifyProc: AddLinkTables; ModifyVersion: '0000.0001.0000.0089'),
    (ModifyProc: ModifyTblCalFields; ModifyVersion: '0000.0001.0000.0089'),
    (ModifyProc: ModifyTblCalDayFields; ModifyVersion: '0000.0001.0000.0089'),
    (ModifyProc: AddGoodkeyFK_Inv_PriceLine; ModifyVersion: '0000.0001.0000.0090'),
    (ModifyProc: ModifyBlockTriggers; ModifyVersion: '0000.0001.0000.0092'),
    (ModifyProc: AddAccountReview; ModifyVersion: '0000.0001.0000.0094'),
    (ModifyProc: ModifyBlockTriggers2; ModifyVersion: '0000.0001.0000.0095'),
    (ModifyProc: ModifyRecordTriggers; ModifyVersion: '0000.0001.0000.0096'),
    (ModifyProc: CirculationList3; ModifyVersion: '0000.0001.0000.0096'),
    (ModifyProc: DropLBRBUniqueIndices; ModifyVersion: '0000.0001.0000.0096'),
    (ModifyProc: ClearEvtObject; ModifyVersion: '0000.0001.0000.0096'),
    (ModifyProc: CorrectBadInvCard; ModifyVersion: '0000.0001.0000.0096'),
    (ModifyProc: SuperNewGeneralLedger; ModifyVersion: '0000.0001.0000.0097'),
    (ModifyProc: AddGoodKeyIntoMovement; ModifyVersion: '0000.0001.0000.0098'),
    (ModifyProc: SQLMonitor; ModifyVersion: '0000.0001.0000.0099'),
    (ModifyProc: AddBranchToBankAndIndex; ModifyVersion: '0000.0001.0000.0100'),
    (ModifyProc: AddBranchToBankStatement; ModifyVersion: '0000.0001.0000.0101'),
    (ModifyProc: AddEmployeeCmd; ModifyVersion: '0000.0001.0000.0102'),
    (ModifyProc: AddDTBlock; ModifyVersion: '0000.0001.0000.0105'),
    (ModifyProc: RemakeACENTRY; ModifyVersion: '0000.0001.0000.0105'),
    (ModifyProc: RemakeACENTRY_NEW; ModifyVersion: '0000.0001.0000.0105'),
    (ModifyProc: RemakeExStored; ModifyVersion: '0000.0001.0000.0106'),
    (ModifyProc: CorrectInvTrigger; ModifyVersion: '0000.0001.0000.0107'),
    (ModifyProc: Add_INV_GETCARDMOVEMENT; ModifyVersion: '0000.0001.0000.0109'),
    (ModifyProc: ModifyBlockTriggers3; ModifyVersion: '0000.0001.0000.0115'),
    (ModifyProc: ModifyBlockTriggers4; ModifyVersion: '0000.0001.0000.0117'),
    (ModifyProc: ModifyWageFields; ModifyVersion: '0000.0001.0000.0118'),
    (ModifyProc: ModifyBankRuid; ModifyVersion: '0000.0001.0000.0120'),
    (ModifyProc: ModifyWageFields1; ModifyVersion: '0000.0001.0000.0121'),
    (ModifyProc: AddGenerators; ModifyVersion: '0000.0001.0000.0123'),
    (ModifyProc: AddCheckConstraints; ModifyVersion: '0000.0001.0000.0125'),
    (ModifyProc: AddUseCompanyKey_Balance; ModifyVersion: '0000.0001.0000.0126'),
    (ModifyProc: ModifyRpTemplateTrigger; ModifyVersion: '0000.0001.0000.0127'),
    (ModifyProc: AddSQLHistTables; ModifyVersion: '0000.0001.0000.0138'),
    (ModifyProc: AddRPLTables; ModifyVersion: '0000.0001.0000.0139'),
    (ModifyProc: AddAcEntryBalanceAndAT_P_SYNC; ModifyVersion: '0000.0001.0000.0140'),
    (ModifyProc: AddOKULPCodeToCompanyCode; ModifyVersion: '0000.0001.0000.0141'),
    (ModifyProc: AddIsInternalField; ModifyVersion: '0000.0001.0000.0142'),
    (ModifyProc: AddMissedGrantsToAcEntryBalanceProcedures; ModifyVersion: '0000.0001.0000.0143'),
    (ModifyProc: ConvertStorage; ModifyVersion: '0000.0001.0000.0144'),
    (ModifyProc: AddEdtiorKeyEditionDate2Storage; ModifyVersion: '0000.0001.0000.0145'),
    (ModifyProc: DropLBRBStorageTree; ModifyVersion: '0000.0001.0000.0146'),
    (ModifyProc: AddAcEntryBalanceAndAT_P_SYNC_Second; ModifyVersion: '0000.0001.0000.0147'),
    (ModifyProc: MakeLBIndexNonUnique; ModifyVersion: '0000.0001.0000.0148'),
    (ModifyProc: AddFKManagerMetadata; ModifyVersion: '0000.0001.0000.0149'),
    (ModifyProc: RegenerateLBRBTree; ModifyVersion: '0000.0001.0000.0150'),
    (ModifyProc: AddDefaultToBoolean; ModifyVersion: '0000.0001.0000.0151'),
    (ModifyProc: ChangeIsCheckNumberType; ModifyVersion: '0000.0001.0000.0152'),
    (ModifyProc: DropRGIndex; ModifyVersion: '0000.0001.0000.0153'),
    (ModifyProc: CreateRGIndex; ModifyVersion: '0000.0001.0000.0154'),
    (ModifyProc: RegenerateLBRBTree2; ModifyVersion: '0000.0001.0000.0155'),
    (ModifyProc: ConvertBNStatementCommentToBlob; ModifyVersion: '0000.0001.0000.0156'),
    (ModifyProc: ConvertDatePeriodComponent; ModifyVersion: '0000.0001.0000.0158'),
    (ModifyProc: UpdateGDRefConstraints; ModifyVersion: '0000.0001.0000.0159'),
    (ModifyProc: AlterUserStorageTrigger; ModifyVersion: '0000.0001.0000.0160'),
    (ModifyProc: AddGDRUIDCheck; ModifyVersion: '0000.0001.0000.0161'),
    (ModifyProc: ModifyRUIDProcedure; ModifyVersion: '0000.0001.0000.0162'),
    (ModifyProc: ModifyGDRUIDCheck; ModifyVersion: '0000.0001.0000.0163'),
    (ModifyProc: DeleteLBRBFromSettingPos; ModifyVersion: '0000.0001.0000.0164'),
    (ModifyProc: AddFieldReportlistModalPreview; ModifyVersion: '0000.0001.0000.0166'),
    (ModifyProc: ChangeUSRCOEF; ModifyVersion: '0000.0001.0000.0167'),
    (ModifyProc: AddFieldMacrosListRunLogIn; ModifyVersion: '0000.0001.0000.0169'),
    (ModifyProc: ChangeDuplicateAccount; ModifyVersion: '0000.0001.0000.0171'),
    (ModifyProc: MovementDocument; ModifyVersion: '0000.0001.0000.0174')
  );

implementation

end.

