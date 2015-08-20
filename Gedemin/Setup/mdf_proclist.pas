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
  mdf_DeletecbAnalyticFromScript, mdf_ModifyBLOBDdocumentdate, mdf_ModifyAC_ACCOUNTEXSALDO_BAL,
  mdf_AddAutoTask, mdf_AddSMTP, mdf_AddSendReport;

const
  {$IFDEF FULL_MODIFY}
  cProcCount = 211;
  {$ELSE}
  cProcCount = 61;
  {$ENDIF}

type
  TModifyProc = record
    ModifyProc: TProcAddr;      // ����� ��������� ����������� �������� �� �����������
    ModifyVersion: String;      // Max ������ �� ��� ������� ��������� ������ �����������
    NeedDBShutdown: Boolean;    // ��������� ����������� �����
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
    {$IFDEF FULL_MODIFY}
    (ModifyProc: CreateUniqueFunctionName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // ���������� ���� branchkey � ������� at_relations
    (ModifyProc: AddBranchKey; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // ��������� ����� �������
    (ModifyProc: ChangeReportForm; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // ��������� �������� �������������
    (ModifyProc: ChangeSyncProcedures; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // ��������� ��������
    (ModifyProc: ChangeSetting; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // ��������� �������� ��������� ��������
    (ModifyProc: ChangeRemainsCommand; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // ��������� �������� ��������� ���������
    (ModifyProc: ChangeStorageCommand; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // ��������� ������ ����������� �������� ��� ������
    //(ModifyProc: ChangeFilterFullName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //��������� ruid ��� ����������� ����������
    (ModifyProc: ChangeDocumentTypeRUID; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //��������� ������� gd_ruid
    (ModifyProc: ChangeRUID; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // ���������� "�������" ����� ������
    (ModifyProc: DivideFullClassName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //��������� �������� �������� � ������� � �������� ���������� ��������
    (ModifyProc: ChangeFilterReportName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //��������� ��������� ������ ��������
    (ModifyProc: AddEditionDate; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    (ModifyProc: UpdateLocalName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    // ��� ���� ��������� ������ �� ������ � ����� �������� ������
    (ModifyProc: UpdateContact; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //�������� ������� � ������� gd_goodtax (������������� datetax)
    (ModifyProc: AlterTriggerGoodTax; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //�������� �������� �������� ������� �� ����������
    (ModifyProc: ChangeTemplatesName; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    (ModifyProc: ChangeForeignForAtFields; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    (ModifyProc: ChangeJournal; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //������ ����� ���� � ����� ����� ����� ���� � ������� ���������
    (ModifyProc: UpdateHolidays; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� ���� ������� � ������ ��� ����. evt_macroslist, rp_reportlist
    (ModifyProc: AddMacrosrightsFields; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� �������� AC_ACCOUNTEXSALDO � AC_CIRCULATIONLIST
    (ModifyProc: AddAccountStoredProc; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� ��������
    (ModifyProc: AddHolding; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� ������ � ������� GD_COMMAND ��� ���������
    (ModifyProc: InsertAnaliseCommands; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� ���������� ��� ��������� ������������� �������
    (ModifyProc: AddTaxTables; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //������������� ������������� GD_CONTACTLIST
    (ModifyProc: AlterViewContactList; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� ��������� FBUdf
    (ModifyProc: AddFBUdfSupport; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� �������� ��������� ������-�������
    (ModifyProc: SpySFChange; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� udf g_s_delchar
    (ModifyProc: AddUdfDelChar; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //��������� ���������� ��� ������ ������� �������
    (ModifyProc: UpdateModuleCode; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //��������� �������� � ������� evt_macroslist
    (ModifyProc: AddMacrosListIndices; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //������������� ���� displayscript ������� gd_function ��� ��������� ����������
    (ModifyProc: Correct_gd_function; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� ������� ������������ � ����� 00
    (ModifyProc: AddZeroAccount; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� ���� �������� � AC_ENTRY
    (ModifyProc: AddAccountEntryDate; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //��������� ���� � AC_SCRIPT ��� ��������� ������������ ������� ��������
    (ModifyProc: AddFieldFUNCSTOR; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //���������� ��������� ������������� ������� ��������
    (ModifyProc: ModifyAccBalanceEntry; ModifyVersion: '0000.0001.0000.0034'; NeedDBShutdown: True),
    //��������� ������� ��� ��������� ��������, ���������� ������ NAME �� gd_tax
    (ModifyProc: AddNewInventTable; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
    //��������� ������������� � ����������� �������
    (ModifyProc: CreateViewGd_V_COMPANY; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
    //��������� ��������� ���-���� ���-��� ��������
    (ModifyProc: AddQuantityMetaData; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
    //������������� FOREIGN KEY �� ������� ��������� � �����
    (ModifyProc: ModifyAnaliticalForeignKey; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
     //����������� ����� � gd_documenttype
    (ModifyProc: AddFieldDocumentType; ModifyVersion: '0000.0001.0000.0035'; NeedDBShutdown: True),
    //���������� ������ ������������� ��������
    (ModifyProc: AddAutoTransactionTables; ModifyVersion: '0000.0001.0000.0036'; NeedDBShutdown: True),
    //��������� ���� � AC_LEDGER � ������ � GD_COMMAND ��� ��������� ������������ ������� ��������
    (ModifyProc: InsertLedgerCommands; ModifyVersion: '0000.0001.0000.0036'; NeedDBShutdown: True),
    //
    (ModifyProc: UpdateContact2; ModifyVersion: '0000.0001.0000.0036'; NeedDBShutdown: True),
    //��������� ���� DISPLAYINMENU � EVT_MARCOSLIST(����������� ������� � ���� �����)
    (ModifyProc: AddDisplayInMenuField; ModifyVersion: '0000.0001.0000.0036'; NeedDBShutdown: True),
    //���������� ����� ��� �����������
    (ModifyProc: ChangeAtRelations; ModifyVersion: '0000.0001.0000.0038'; NeedDBShutdown: True),
    //���������� ��������� ��� �������� ������ � ��
    (ModifyProc: Create_gd_File; ModifyVersion: '0000.0001.0000.0039'; NeedDBShutdown: True),
    //���������� ������� ��� �������� �������� �������� �� ���������
    (ModifyProc: AddOverTurnByAnal; ModifyVersion: '0000.0001.0000.0040'; NeedDBShutdown: True),
    //���������� ����� IncludeInternalMovement
    (ModifyProc: AddIncludeInternalMovment; ModifyVersion: '0000.0001.0000.0041'; NeedDBShutdown: True),
    //���������� ��������
    (ModifyProc: AddEntryIndices; ModifyVersion: '0000.0001.0000.0042'; NeedDBShutdown: True),
    (ModifyProc: AddQuantityField; ModifyVersion: '0000.0001.0000.0043'; NeedDBShutdown: True),
    (ModifyProc: AddEntryIndices2; ModifyVersion: '0000.0001.0000.0044'; NeedDBShutdown: True),
    //Increase length of fields setcondition and refcondition in at_fields
    (ModifyProc: SetDomainCondition; ModifyVersion: '0000.0001.0000.0044'; NeedDBShutdown: True),
    // ���������� ���� ischecknumber � gd_documenttype
    (ModifyProc: AddIsCheckNumberField; ModifyVersion: '0000.0001.0000.0044'; NeedDBShutdown: True),
    // ��������� ������ DGOLDQUANTITY �� NUMERIC(15, 8)
    (ModifyProc: ChangeDGoldQuantity; ModifyVersion: '0000.0001.0000.0045'; NeedDBShutdown: True),
    // ��������� �������� INV_AU_MOVEMENT
    (ModifyProc: ChangeINV_AU_MOVEMENT; ModifyVersion: '0000.0001.0000.0046'; NeedDBShutdown: True),
    // ���������� ����� ���� name � gd_function
    (ModifyProc: AddLongNameFieldInScript; ModifyVersion: '0000.0001.0000.0046'; NeedDBShutdown: True),
    // ���������� ����� � AT_SETTING ��� ������ ������� ��������. Yuri.
    (ModifyProc: AddGSFFields; ModifyVersion: '0000.0001.0000.0047'; NeedDBShutdown: True),
    //���������� ��������� ��������� ���������
    (ModifyProc: ModifyAccountCirculation; ModifyVersion: '0000.0001.0000.0047'; NeedDBShutdown: True),
    //����� ���. ������
    (ModifyProc: NewAcctReports; ModifyVersion: '0000.0001.0000.0048'; NeedDBShutdown: True),
    (ModifyProc: UniqueLName; ModifyVersion: '0000.0001.0000.0049'; NeedDBShutdown: True),
    //���������� ���� description � gd_files
    (ModifyProc: UpdateFiles; ModifyVersion: '0000.0001.0000.0049'; NeedDBShutdown: True),
    //���������� ���� accountkey  � ������� ac_trrecord
    (ModifyProc: AddAccountKeyToTypeEntry; ModifyVersion: '0000.0001.0000.0050'; NeedDBShutdown: True),
    //��������� ���� � AC_TRRECORD ��������� ������� �������� ��� ���
    (ModifyProc: AddFieldSaveNullEntry; ModifyVersion: '0000.0001.0000.0050'; NeedDBShutdown: True),
    (ModifyProc: NewTaxies; ModifyVersion: '0000.0001.0000.0051'; NeedDBShutdown: True),
    //������������� ���� usergroupname � ������� rp_reportgroup � �����
    (ModifyProc: UserGroupToRUID; ModifyVersion: '0000.0001.0000.0052'; NeedDBShutdown: True),
    (ModifyProc: NewTrEntries; ModifyVersion: '0000.0001.0000.0053'; NeedDBShutdown: True),
    (ModifyProc: GrantTables; ModifyVersion: '0000.0001.0000.0053'; NeedDBShutdown: True),
    (ModifyProc: QuickLedger; ModifyVersion: '0000.0001.0000.0054'; NeedDBShutdown: True),
    (ModifyProc: AddTransactionFuntionField; ModifyVersion: '0000.0001.0000.0055'; NeedDBShutdown: True),
    (ModifyProc: AddQuantityFK; ModifyVersion: '0000.0001.0000.0057'; NeedDBShutdown: True),
    (ModifyProc: DocumentAndCommandUpdate; ModifyVersion: '0000.0001.0000.0058'; NeedDBShutdown: True),
    //����������� ������ � �������� �� ������� ac_entry
    (ModifyProc: QuickLedger2; ModifyVersion: '0000.0001.0000.0059'; NeedDBShutdown: True),
    //���������� �������� �� ������� at_settingpos
    (ModifyProc: AddSettingPosIndices; ModifyVersion: '0000.0001.0000.0059'; NeedDBShutdown: True),
    (ModifyProc: AddPK_AC_G_LEDGERACCOUNT; ModifyVersion: '0000.0001.0000.0060'; NeedDBShutdown: True),
    (ModifyProc: Add_Transaction_triggers; ModifyVersion: '0000.0001.0000.0060'; NeedDBShutdown: True),
    (ModifyProc: AddFieldsToInv_BalanceOptions; ModifyVersion: '0000.0001.0000.0061'; NeedDBShutdown: True),
    (ModifyProc: AddEditorKeyConst; ModifyVersion: '0000.0001.0000.0063'; NeedDBShutdown: True),
    //���������� ���� rate � ����������� �������
    (ModifyProc: AddRateInStatement; ModifyVersion: '0000.0001.0000.0064'; NeedDBShutdown: True),
    //���������� ������ �� ac_account � ������� bn_bankstatementline
    (ModifyProc: AddAccountKeyInStatementLine; ModifyVersion: '0000.0001.0000.0066'; NeedDBShutdown: True),
    (ModifyProc: AddUdfDataParamStr; ModifyVersion: '0000.0001.0000.0067'; NeedDBShutdown: True),
    //���������� ����� ������������� ����� ������ � gd_lastnumber
    (ModifyProc: AddFixNumberInDocumenttype; ModifyVersion: '0000.0001.0000.0068'; NeedDBShutdown: True),
    //��������� branchkey � at_relations � gd_documenttype
    (ModifyProc: ChangeBranchKey; ModifyVersion: '0000.0001.0000.0069'; NeedDBShutdown: True),
    (ModifyProc: AddFieldPlaceCode; ModifyVersion: '0000.0001.0000.0070'; NeedDBShutdown: True),
    (ModifyProc: QuickLedger3; ModifyVersion: '0000.0001.0000.0071'; NeedDBShutdown: True),
    (ModifyProc: AddFieldFolderKey; ModifyVersion: '0000.0001.0000.0072'; NeedDBShutdown: True),
    //���������� ������ � ������ ��� ������� �����
    (ModifyProc: InsertGeneralLedgerCommands; ModifyVersion: '0000.0001.0000.0074'; NeedDBShutdown: True),
    (ModifyProc: Add_Account_Triggers; ModifyVersion: '0000.0001.0000.0075'; NeedDBShutdown: True),
    (ModifyProc: QuickLedger_last; ModifyVersion: '0000.0001.0000.0076'; NeedDBShutdown: True),
    {����� �������� ������ ��!!!!}
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
    {$ENDIF}

    
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
    (ModifyProc: AddADAtObjectTrigger; ModifyVersion: '0000.0001.0000.0207'; NeedDBShutdown: False),
    (ModifyProc: SetDefaultForAccountType; ModifyVersion: '0000.0001.0000.0209'; NeedDBShutdown: False),
    (ModifyProc: AddGdObjectDependencies; ModifyVersion: '0000.0001.0000.0210'; NeedDBShutdown: True),
    (ModifyProc: Issue1041; ModifyVersion: '0000.0001.0000.0211'; NeedDBShutdown: False),
    (ModifyProc: Issue3218; ModifyVersion: '0000.0001.0000.0212'; NeedDBShutdown: False),
    (ModifyProc: AddNSSyncTables; ModifyVersion: '0000.0001.0000.0220'; NeedDBShutdown: True),
    (ModifyProc: DeletecbAnalyticFromAcc_BuildAcctCard; ModifyVersion: '0000.0001.0000.0221'; NeedDBShutdown: True),
    (ModifyProc: ChangeAcLedgerAccounts; ModifyVersion: '0000.0001.0000.0223'; NeedDBShutdown: False),
    (ModifyProc: RUIDsForGdStorageData; ModifyVersion: '0000.0001.0000.0225'; NeedDBShutdown: True),
    (ModifyProc: AddAtNamespaceChanged; ModifyVersion: '0000.0001.0000.0227'; NeedDBShutdown: True),
    (ModifyProc: CorrectDocumentType; ModifyVersion: '0000.0001.0000.0228'; NeedDBShutdown: False),
    (ModifyProc: CorrectEntryTriggers; ModifyVersion: '0000.0001.0000.0230'; NeedDBShutdown: True),
    (ModifyProc: CorrectAutoEntryScript; ModifyVersion: '0000.0001.0000.0231'; NeedDBShutdown: False),
    (ModifyProc: ModifyBLOB; ModifyVersion: '0000.0001.0000.0233'; NeedDBShutdown: True),
    (ModifyProc: ModifyAC_ACCOUNTEXSALDO_BAL; ModifyVersion: '0000.0001.0000.0237'; NeedDBShutdown: False),
    (ModifyProc: IntroduceIncorrectRecordGTT; ModifyVersion: '0000.0001.0000.0241'; NeedDBShutdown: True),
    (ModifyProc: Issue3373; ModifyVersion: '0000.0001.0000.0243'; NeedDBShutdown: False),
    (ModifyProc: AddGD_WEBLOG; ModifyVersion: '0000.0001.0000.0247'; NeedDBShutdown: True),
    (ModifyProc: AddAutoTaskTables; ModifyVersion: '0000.0001.0000.0250'; NeedDBShutdown: True),
    (ModifyProc: AddSMTPTable; ModifyVersion: '0000.0001.0000.0251'; NeedDBShutdown: True),
    (ModifyProc: ModifyAutoTaskAndSMTPTable; ModifyVersion: '0000.0001.0000.0256'; NeedDBShutdown: True)
  );

implementation

end.

