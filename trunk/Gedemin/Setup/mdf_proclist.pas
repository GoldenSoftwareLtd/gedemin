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
    ModifyProc: TProcAddr;      // ����� ��������� ����������� �������� �� �����������
    ModifyVersion: String;      // Max ������ �� ��� ������� ��������� ������ �����������
  end;

  // !!! ��� ����� !!!
  //   ������� ��������� ����������� ������ � ��������� ��. �������� �������
  // ChangeFilterFullName �������������� ������ � ������� FLT_FILTERCOMPONENT
  // ����� ����� ���� ������� ��������� CustomTableModify ������� ���������
  // ���� NOT NULL � ������� GD_CUSTOMTABLE. �.�. Upgrade �� ������� ��� ������� �������
  // � ������� ����������� �������� ����, �� ������ ������ ���� ������ �����
  // ���������� ���� (������ ������ ���� �� � CustomTableModify � � SQL ��������,
  // �� ������� ��������� ��������� ���� � � ������� ����������� ������ ��������
  // Upgrade). ��� ���� ��������� ����������� ������� ������������� � ��� �� ������ ��
  // ��� � ��������� ���������� ����. � ���� ������ ����, �� ��� �� �����������.
  // ��� ���� ������ ��������� ������ �������������� ����������� �������������
  // ���������� �����������. ��� � ������ ������ � ��������� ChangeFilterFullName
  // ������ ����������� �������� ������� �������� ������������ �������.
  // �� ������ ������ � ��������� CustomTableModify ������ ����������� �������
  // ������������ ����. ������ ������ ��������� ����� ���� �� �������� ����������
  // ���������, ������� ��� �� ������� � ������������ ������ �� ����� ����������.
  // ����� ����, ���� ����������� ���� ������� ��������� �������� NULL ������ ��
  // ������ �� ����, � ��������� ������ ���������� ����� ��������� ������ ��
  // ��� �������� ������� ���� ��������� � ���������� ������ ��.
  // �.�. ���� ��������� ChangeFilterFullName ��������� � ������ 0000.0001.0000.0038,
  // � ��������� CustomTableModify ��������� ���� � ��������� ��������� NULL,
  // �� ���� ��� �������� �������� :
  // 1. ��������� ������ �� ����������, �.�. CustomTableModify ����� ��������� �
  // ������ 0000.0001.0000.0038.
  // 2. ����������� ������ �� �� 0000.0001.0000.0039, � ��� ��������� CustomTableModify
  // � ��� ���� �������� � ������� 0000.0001.0000.0038 (� ��������� ��� ChangeFilterFullName)
  // ����������� ������ �� 0000.0001.0000.0039.
  // ��������� ������ �� ��������� � ����� gd_version.sql

  TProcList = array[0..cProcCount - 1] of TModifyProc;

const
  cProcList: TProcList = (
    (ModifyProc: CreateUniqueFunctionName; ModifyVersion: '0000.0001.0000.0034'),
    // ���������� ���� branchkey � ������� at_relations
    (ModifyProc: AddBranchKey; ModifyVersion: '0000.0001.0000.0034'),
    // ��������� ����� �������
    (ModifyProc: ChangeReportForm; ModifyVersion: '0000.0001.0000.0034'),
    // ��������� �������� �������������
    (ModifyProc: ChangeSyncProcedures; ModifyVersion: '0000.0001.0000.0034'),
    // ��������� ��������
    (ModifyProc: ChangeSetting; ModifyVersion: '0000.0001.0000.0034'),
    // ��������� �������� ��������� ��������
    (ModifyProc: ChangeRemainsCommand; ModifyVersion: '0000.0001.0000.0034'),
    // ��������� �������� ��������� ���������
    (ModifyProc: ChangeStorageCommand; ModifyVersion: '0000.0001.0000.0034'),
    // ��������� ������ ����������� �������� ��� ������
    //(ModifyProc: ChangeFilterFullName; ModifyVersion: '0000.0001.0000.0034'),
    //��������� ruid ��� ����������� ����������
    (ModifyProc: ChangeDocumentTypeRUID; ModifyVersion: '0000.0001.0000.0034'),
    //��������� ������� gd_ruid
    (ModifyProc: ChangeRUID; ModifyVersion: '0000.0001.0000.0034'),
    // ���������� "�������" ����� ������
    (ModifyProc: DivideFullClassName; ModifyVersion: '0000.0001.0000.0034'),
    //��������� �������� �������� � ������� � �������� ���������� ��������
    (ModifyProc: ChangeFilterReportName; ModifyVersion: '0000.0001.0000.0034'),
    //��������� ��������� ������ ��������
    (ModifyProc: AddEditionDate; ModifyVersion: '0000.0001.0000.0034'),
    (ModifyProc: UpdateLocalName; ModifyVersion: '0000.0001.0000.0034'),
    // ��� ���� ��������� ������ �� ������ � ����� �������� ������
    (ModifyProc: UpdateContact; ModifyVersion: '0000.0001.0000.0034'),
    //�������� ������� � ������� gd_goodtax (������������� datetax)
    (ModifyProc: AlterTriggerGoodTax; ModifyVersion: '0000.0001.0000.0034'),
    //�������� �������� �������� ������� �� ����������
    (ModifyProc: ChangeTemplatesName; ModifyVersion: '0000.0001.0000.0034'),
    (ModifyProc: ChangeForeignForAtFields; ModifyVersion: '0000.0001.0000.0034'),
    (ModifyProc: ChangeJournal; ModifyVersion: '0000.0001.0000.0034'),
    //������ ����� ���� � ����� ����� ����� ���� � ������� ���������
    (ModifyProc: UpdateHolidays; ModifyVersion: '0000.0001.0000.0034'),
    //���������� ���� ������� � ������ ��� ����. evt_macroslist, rp_reportlist
    (ModifyProc: AddMacrosrightsFields; ModifyVersion: '0000.0001.0000.0034'),
    //���������� �������� AC_ACCOUNTEXSALDO � AC_CIRCULATIONLIST
    (ModifyProc: AddAccountStoredProc; ModifyVersion: '0000.0001.0000.0034'),
    //���������� ��������
    (ModifyProc: AddHolding; ModifyVersion: '0000.0001.0000.0034'),
    //���������� ������ � ������� GD_COMMAND ��� ���������
    (ModifyProc: InsertAnaliseCommands; ModifyVersion: '0000.0001.0000.0034'),
    //���������� ���������� ��� ��������� ������������� �������
    (ModifyProc: AddTaxTables; ModifyVersion: '0000.0001.0000.0034'),
    //������������� ������������� GD_CONTACTLIST
    (ModifyProc: AlterViewContactList; ModifyVersion: '0000.0001.0000.0034'),
    //���������� ��������� FBUdf
    (ModifyProc: AddFBUdfSupport; ModifyVersion: '0000.0001.0000.0034'),
    //���������� �������� ��������� ������-�������
    (ModifyProc: SpySFChange; ModifyVersion: '0000.0001.0000.0034'),
    //���������� udf g_s_delchar
    (ModifyProc: AddUdfDelChar; ModifyVersion: '0000.0001.0000.0034'),
    //��������� ���������� ��� ������ ������� �������
    (ModifyProc: UpdateModuleCode; ModifyVersion: '0000.0001.0000.0034'),
    //��������� �������� � ������� evt_macroslist
    (ModifyProc: AddMacrosListIndices; ModifyVersion: '0000.0001.0000.0034'),
    //������������� ���� displayscript ������� gd_function ��� ��������� ����������
    (ModifyProc: Correct_gd_function; ModifyVersion: '0000.0001.0000.0034'),
    //���������� ������� ������������ � ����� 00
    (ModifyProc: AddZeroAccount; ModifyVersion: '0000.0001.0000.0034'),
    //���������� ���� �������� � AC_ENTRY
    (ModifyProc: AddAccountEntryDate; ModifyVersion: '0000.0001.0000.0034'),
    //��������� ���� � AC_SCRIPT ��� ��������� ������������ ������� ��������
    (ModifyProc: AddFieldFUNCSTOR; ModifyVersion: '0000.0001.0000.0034'),
    //���������� ��������� ������������� ������� ��������
    (ModifyProc: ModifyAccBalanceEntry; ModifyVersion: '0000.0001.0000.0034'),
    //��������� ������� ��� ��������� ��������, ���������� ������ NAME �� gd_tax
    (ModifyProc: AddNewInventTable; ModifyVersion: '0000.0001.0000.0035'),
    //��������� ������������� � ����������� �������
    (ModifyProc: CreateViewGd_V_COMPANY; ModifyVersion: '0000.0001.0000.0035'),
    //��������� ��������� ���-���� ���-��� ��������
    (ModifyProc: AddQuantityMetaData; ModifyVersion: '0000.0001.0000.0035'),
    //������������� FOREIGN KEY �� ������� ��������� � �����
    (ModifyProc: ModifyAnaliticalForeignKey; ModifyVersion: '0000.0001.0000.0035'),
     //����������� ����� � gd_documenttype
    (ModifyProc: AddFieldDocumentType; ModifyVersion: '0000.0001.0000.0035'),
    //���������� ������ ������������� ��������
    (ModifyProc: AddAutoTransactionTables; ModifyVersion: '0000.0001.0000.0036'),
    //��������� ���� � AC_LEDGER � ������ � GD_COMMAND ��� ��������� ������������ ������� ��������
    (ModifyProc: InsertLedgerCommands; ModifyVersion: '0000.0001.0000.0036'),
    //
    (ModifyProc: UpdateContact2; ModifyVersion: '0000.0001.0000.0036'),
    //��������� ���� DISPLAYINMENU � EVT_MARCOSLIST(����������� ������� � ���� �����)
    (ModifyProc: AddDisplayInMenuField; ModifyVersion: '0000.0001.0000.0036'),
    //���������� ����� ��� �����������
    (ModifyProc: ChangeAtRelations; ModifyVersion: '0000.0001.0000.0038'),
    //���������� ��������� ��� �������� ������ � ��
    (ModifyProc: Create_gd_File; ModifyVersion: '0000.0001.0000.0039'),
    //���������� ������� ��� �������� �������� �������� �� ���������
    (ModifyProc: AddOverTurnByAnal; ModifyVersion: '0000.0001.0000.0040'),
    //���������� ����� IncludeInternalMovement
    (ModifyProc: AddIncludeInternalMovment; ModifyVersion: '0000.0001.0000.0041'),
    //���������� ��������
    (ModifyProc: AddEntryIndices; ModifyVersion: '0000.0001.0000.0042'),
    (ModifyProc: AddQuantityField; ModifyVersion: '0000.0001.0000.0043'),
    (ModifyProc: AddEntryIndices2; ModifyVersion: '0000.0001.0000.0044'),
    //Increase length of fields setcondition and refcondition in at_fields
    (ModifyProc: SetDomainCondition; ModifyVersion: '0000.0001.0000.0044'),
    // ���������� ���� ischecknumber � gd_documenttype
    (ModifyProc: AddIsCheckNumberField; ModifyVersion: '0000.0001.0000.0044'),
    // ��������� ������ DGOLDQUANTITY �� NUMERIC(15, 8)
    (ModifyProc: ChangeDGoldQuantity; ModifyVersion: '0000.0001.0000.0045'),
    // ��������� �������� INV_AU_MOVEMENT
    (ModifyProc: ChangeINV_AU_MOVEMENT; ModifyVersion: '0000.0001.0000.0046'),
    // ���������� ����� ���� name � gd_function
    (ModifyProc: AddLongNameFieldInScript; ModifyVersion: '0000.0001.0000.0046'),
    // ���������� ����� � AT_SETTING ��� ������ ������� ��������. Yuri.
    (ModifyProc: AddGSFFields; ModifyVersion: '0000.0001.0000.0047'),
    //���������� ��������� ��������� ���������
    (ModifyProc: ModifyAccountCirculation; ModifyVersion: '0000.0001.0000.0047'),
    //����� ���. ������
    (ModifyProc: NewAcctReports; ModifyVersion: '0000.0001.0000.0048'),
    (ModifyProc: UniqueLName; ModifyVersion: '0000.0001.0000.0049'),
    //���������� ���� description � gd_files
    (ModifyProc: UpdateFiles; ModifyVersion: '0000.0001.0000.0049'),
    //���������� ���� accountkey  � ������� ac_trrecord
    (ModifyProc: AddAccountKeyToTypeEntry; ModifyVersion: '0000.0001.0000.0050'),
    //��������� ���� � AC_TRRECORD ��������� ������� �������� ��� ���
    (ModifyProc: AddFieldSaveNullEntry; ModifyVersion: '0000.0001.0000.0050'),
    (ModifyProc: NewTaxies; ModifyVersion: '0000.0001.0000.0051'),
    //������������� ���� usergroupname � ������� rp_reportgroup � �����
    (ModifyProc: UserGroupToRUID; ModifyVersion: '0000.0001.0000.0052'),
    (ModifyProc: NewTrEntries; ModifyVersion: '0000.0001.0000.0053'),
    (ModifyProc: GrantTables; ModifyVersion: '0000.0001.0000.0053'),
    (ModifyProc: QuickLedger; ModifyVersion: '0000.0001.0000.0054'),
    (ModifyProc: AddTransactionFuntionField; ModifyVersion: '0000.0001.0000.0055'),
    (ModifyProc: AddQuantityFK; ModifyVersion: '0000.0001.0000.0057'),
    (ModifyProc: DocumentAndCommandUpdate; ModifyVersion: '0000.0001.0000.0058'),
    //����������� ������ � �������� �� ������� ac_entry
    (ModifyProc: QuickLedger2; ModifyVersion: '0000.0001.0000.0059'),
    //���������� �������� �� ������� at_settingpos
    (ModifyProc: AddSettingPosIndices; ModifyVersion: '0000.0001.0000.0059'),
    (ModifyProc: AddPK_AC_G_LEDGERACCOUNT; ModifyVersion: '0000.0001.0000.0060'),
    (ModifyProc: Add_Transaction_triggers; ModifyVersion: '0000.0001.0000.0060'),
    (ModifyProc: AddFieldsToInv_BalanceOptions; ModifyVersion: '0000.0001.0000.0061'),
    (ModifyProc: AddEditorKeyConst; ModifyVersion: '0000.0001.0000.0063'),
    //���������� ���� rate � ����������� �������
    (ModifyProc: AddRateInStatement; ModifyVersion: '0000.0001.0000.0064'),
    //���������� ������ �� ac_account � ������� bn_bankstatementline
    (ModifyProc: AddAccountKeyInStatementLine; ModifyVersion: '0000.0001.0000.0066'),
    (ModifyProc: AddUdfDataParamStr; ModifyVersion: '0000.0001.0000.0067'),
    //���������� ����� ������������� ����� ������ � gd_lastnumber
    (ModifyProc: AddFixNumberInDocumenttype; ModifyVersion: '0000.0001.0000.0068'),
    //��������� branchkey � at_relations � gd_documenttype
    (ModifyProc: ChangeBranchKey; ModifyVersion: '0000.0001.0000.0069'),
    (ModifyProc: AddFieldPlaceCode; ModifyVersion: '0000.0001.0000.0070'),
    (ModifyProc: QuickLedger3; ModifyVersion: '0000.0001.0000.0071'),
    (ModifyProc: AddFieldFolderKey; ModifyVersion: '0000.0001.0000.0072'),
    //���������� ������ � ������ ��� ������� �����
    (ModifyProc: InsertGeneralLedgerCommands; ModifyVersion: '0000.0001.0000.0074'),
    (ModifyProc: Add_Account_Triggers; ModifyVersion: '0000.0001.0000.0075'),
    (ModifyProc: QuickLedger_last; ModifyVersion: '0000.0001.0000.0076'),
    {����� �������� ������ ��!!!!}
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

