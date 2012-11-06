{$IMAGEBASE $00400000}

program gedemin;

{%ToDo 'gedemin.todo'}

uses
  FastMM4,
  {$IFNDEF DEBUG}
  FastMove,
  RTLVCLOptimize,
  {$ENDIF}
  {$IFDEF EXCMAGIC_GEDEMIN}
  ExcMagic_Gedemin,
  {$ENDIF}
  Classes,
  Forms,
  gd_main_form in 'gd_main_form.pas' {frmGedeminMain},
  dmDataBase_unit in '..\GAdmin\dmDataBase_unit.pas' {dmDatabase: TDataModule},
  dmLogin_unit in '..\GAdmin\dmLogin_unit.pas' {dmLogin: TDataModule},
  dmImages_unit in 'dmImages_unit.pas' {dmImages: TDataModule},
  gdHelp_body,
  Windows,
  SysUtils,
  gd_directories_const,
  Dialogs,
  Registry,  
  IBIntf,
  IBServices,
  gdcInvDocumentCache_body,
  gd_regionalsettings_dlgEdit,               
  gd_security,
  gd_CmdLineParams_unit,
  gdcRUID,
  dmClientReport_unit in '..\Report\dmClientReport_unit.pas' {dmClientReport: TDataModule},
  gdc_frmG_unit in '..\Component\Repository\gdc_frmG_unit.pas' {gdc_frmG},
  gdc_frmMDH_unit in '..\Component\Repository\gdc_frmMDH_unit.pas' {gdc_frmMDH},
  gdc_frmMDVTree_unit in '..\Component\Repository\gdc_frmMDVTree_unit.pas' {gdc_frmMDVTree},
  gdc_frmSGR_unit in '..\Component\Repository\gdc_frmSGR_unit.pas' {gdc_frmSGR},
  gdc_dlgCustomCompany_unit in '..\AddressBook\gdc_dlgCustomCompany_unit.pas' {gdc_dlgCustomCompany},
  gdc_dlgCustomGroup_unit in '..\AddressBook\gdc_dlgCustomGroup_unit.pas' {gdc_dlgCustomGroup},
  gdc_frmMDV_unit in '..\Component\Repository\gdc_frmMDV_unit.pas' {gdc_frmMDV},
  gdc_dlgG_unit in '..\Component\Repository\gdc_dlgG_unit.pas' {gdc_dlgG},
  gdc_dlgHGR_unit in '..\Component\Repository\gdc_dlgHGR_unit.pas' {gdc_dlgHGR},
  gdc_frmMDHGR_unit in '..\Component\Repository\gdc_frmMDHGR_unit.pas' {gdc_frmMDHGR},
  gdc_frmSGRAccount_unit in '..\Component\Repository\gdc_frmSGRAccount_unit.pas' {gdc_frmSGRAccount},
  gdc_frmMDHGRAccount_unit in '..\Component\Repository\gdc_frmMDHGRAccount_unit.pas' {gdc_frmMDHGRAccount},
  gdc_frmMDVGR_unit in '..\Component\Repository\gdc_frmMDVGR_unit.pas' {gdc_frmMDVGR},
  gdc_dlgTR_unit in '..\Component\Repository\gdc_dlgTR_unit.pas' {gdc_dlgTR},
  gdc_dlgCompany_unit in '..\AddressBook\gdc_dlgCompany_unit.pas' {gdc_dlgCompany},
  gdc_dlgGroup_unit in '..\AddressBook\gdc_dlgGroup_unit.pas' {gdc_dlgGroup},
  gdc_dlgConstValue_unit in '..\Const\gdc_dlgConstValue_unit.pas' {gdc_dlgConstValue},
  gdc_frmBankStatementBase_unit in '..\Bank\gdc_frmBankStatementBase_unit.pas' {gdc_frmBankStatementBase},
  gdc_dlgBaseStatementLine_unit in '..\Bank\gdc_dlgBaseStatementLine_unit.pas' {gdc_dlgBaseStatementLine},
  gdc_dlgTRPC_unit in '..\Component\Repository\gdc_dlgTRPC_unit.pas' {gdc_dlgTRPC},
  gdc_dlgAcctBaseAccount_unit in '..\Transaction\gdc_dlgAcctBaseAccount_unit.pas' {gdc_dlgAcctBaseAccount},
  gdc_frmInvCard_unit,
  at_Classes in '..\Attr\at_Classes.pas',
  gdcUser in '..\Component\GDC\gdcUser.pas',
  gdcLedger,
  gdcAcctTransaction in '..\Component\GDC\gdcAcctTransaction.pas',
  gdcAttrUserDefined in '..\Component\GDC\gdcAttrUserDefined.pas',
  gdcBase in '..\component\gdc\gdcBase.pas',
  gdcBaseInterface in '..\Component\GDC\gdcBaseInterface.pas',
  gdcClasses in '..\Component\GDC\gdcClasses.pas',
  gdcConst in '..\Component\GDC\gdcConst.pas',
  gdcContacts in '..\Component\GDC\gdcContacts.pas',
  gdcCurr in '..\Component\GDC\gdcCurr.pas',
  gdcGood in '..\Component\GDC\gdcGood.pas',
  gdcJournal in '..\Component\GDC\gdcJournal.pas',
  gdcPlace in '..\Component\GDC\gdcPlace.pas',
  gdcStatement in '..\Component\GDC\gdcStatement.pas',
  gdcFilter,
  gdcWgPosition,
  gdcLink,
  gdcSQLHistory,
  gdcStorage,
  gdcFKManager,
  gdcTableCalendar in '..\Component\GDC\gdcTableCalendar.pas',
  gdcAcctAccount in '..\Component\GDC\gdcAcctAccount.pas',
  gdc_frmInvBaseRemains_unit in '..\Inventory\gdc_frmInvBaseRemains_unit.pas' {gdc_frmInvBaseRemains},
  acctTransactionDatabase in '..\Transaction\acctTransactionDatabase.pas',
  gdc_frmDocumentType_unit in '..\Document\gdc_frmDocumentType_unit.pas' {gdc_frmDocumentType},
  gdc_dlgUserDocumentSetup_unit in '..\Document\gdc_dlgUserDocumentSetup_unit.pas' {gdc_dlgUserDocumentSetup},
  gdc_frmExplorer_unit in 'gdc_frmExplorer_unit.pas' {gdc_frmExplorer},
  gdc_attr_dlgView_unit in '..\Attr\gdc_attr_dlgView_unit.pas' {gdc_attr_dlgView},
  gdc_dlgRelation_unit in '..\Attr\gdc_dlgRelation_unit.pas' {gdc_dlgRelation},
  gdcOLEClassList in '..\Property\gdcOLEClassList.pas',
  obj_WrapperDelphiClasses in '..\Property\obj_WrapperDelphiClasses.pas',
  gdc_attr_frmStoredProc_unit in '..\Attr\gdc_attr_frmStoredProc_unit.pas' {gdc_attr_frmStoredProc},
  gdc_attr_dlgStoredProc_unit in '..\Attr\gdc_attr_dlgStoredProc_unit.pas' {gdc_attr_dlgStoredProc},
  gdc_frmUserSimpleDocument_unit in '..\Document\gdc_frmUserSimpleDocument_unit.pas' {gdc_frmUserSimpleDocument},
  gdc_frmUserComplexDocument_unit in '..\Document\gdc_frmUserComplexDocument_unit.pas' {gdc_frmUserComplexDocument},
  gdc_ab_frmmain_unit in '..\AddressBook\gdc_ab_frmmain_unit.pas' {gdc_ab_frmmain},
  gdc_dlgDocumentType_unit in '..\Document\gdc_dlgDocumentType_unit.pas' {gdc_dlgDocumentType},
  obj_WrapperGSClasses in '..\Property\obj_WrapperGSClasses.pas',
  obj_Inherited in '..\Property\obj_Inherited.pas',
  obj_GedeminApplication in '..\Report\obj_GedeminApplication.pas',
  gd_frmOLEMainForm_unit in 'gd_frmOLEMainForm_unit.pas' {frmOLEMainForm},
  Storages in '..\GAdmin\Storages.pas',
  gs_Exception in '..\Component\gs_Exception.pas',
  gdc_inv_dlgPredefinedField_unit in '..\Inventory\gdc_inv_dlgPredefinedField_unit.pas' {gdc_inv_dlgPredefinedField},
  gdc_attr_frmFunction_unit in '..\Attr\gdc_attr_frmFunction_unit.pas',
  frmSplash_unit in 'frmSplash_unit.pas' {frmSplash},
  gd_ScrException in '..\Report\gd_ScrException.pas',
  gd_splash in 'gd_splash.pas',
  frmSplashHidden_unit in 'frmSplashHidden_unit.pas' {frmSplashHidden},
  gdc_dlgAttrUserDefined_unit in '..\Attr\gdc_dlgAttrUserDefined_unit.pas' {gdc_dlgAttrUserDefined},
  dm_i_ClientReport_unit in '..\Report\dm_i_ClientReport_unit.pas',
  gd_ClassList in '..\Component\GDC\gd_ClassList.pas',
  rp_VBConsts in '..\Report\rp_VBConsts.pas',
  prp_Messages in '..\Property\prp_Messages.pas',
  gdc_dlgViewMovement_unit in '..\Inventory\gdc_dlgViewMovement_unit.pas' {gdc_dlgViewMovement},
  rp_dlgViewResult_unit in '..\Report\rp_dlgViewResult_unit.pas' {dlgViewResult},
  prp_Filter in '..\Property\prp_Filter.pas',
  gdc_dlgUserDocumentLine_unit in '..\Document\gdc_dlgUserDocumentLine_unit.pas' {gdc_dlgUserDocumentLine},
  gdc_dlgGMetaData_unit in '..\Component\Repository\gdc_dlgGMetaData_unit.pas' {gdc_dlgGMetaData},
  prp_DOCKFORM_unit in '..\Property\prp_DOCKFORM_unit.pas',
  prp_dfPropertyTree_Unit in '..\Property\prp_dfPropertyTree_Unit.pas',
  gdc_dlgTRMetaData_unit in '..\Component\Repository\gdc_dlgTRMetaData_unit.pas' {gdc_dlgTRMetaData},
  prp_FunctionFrame_Unit in '..\Property\PRP_FUNCTIONFRAME_UNIT.pas' {FunctionFrame: TFrame},
  prp_dlg_PropertySettings_unit in '..\Property\prp_dlg_PropertySettings_unit.pas' {dlgPropertySettings},
  prp_dlgPropertyFind in '..\Property\prp_dlgPropertyFind.pas' {dlgPropertyFind},
  gsGdcBaseManager_unit in '..\Report\gsGdcBaseManager_unit.pas',
  prp_dlgPropertyReplace in '..\Property\prp_dlgPropertyReplace.pas' {dlgPropertyReplace},
  prp_dlgPropertyReplacePromt in '..\Property\prp_dlgPropertyReplacePromt.pas' {dlgPropertyReplacePromt},
  gd_frmErrorInScript in '..\Report\gd_frmErrorInScript.pas' {frmErrorInScript},
  prp_frmRuntimeScript in '..\Property\prp_frmRuntimeScript.pas' {frmRuntimeScript},
  gdc_attr_frmRelationField_unit in '..\Attr\gdc_attr_frmRelationField_unit.pas' {gdc_attr_frmRelationField},
  AppEvnts, ComObj, ComServ,
  gdApplicationEventsHandler in 'gdApplicationEventsHandler.pas',
  flt_frmSQLEditorSyn_unit in '..\queryfilter\flt_frmSQLEditorSyn_unit.pas' {frmSQLEditorSyn},
  gdcCustomFunction in '..\Component\GDC\gdcCustomFunction.pas',
  prp_frmClassesInspector_unit in '..\Property\prp_frmClassesInspector_unit.pas' {frmClassesInspector},
  obj_ClassesInspector in '..\Property\obj_ClassesInspector.pas',
  gd_strings in '..\Common\gd_strings.pas',
  gdv_frmG_unit in '..\Component\Repository\gdv_frmG_unit.pas' {gdv_frmG},
  gdc_frmTaxActual_unit in '..\Tax\gdc_frmTaxActual_unit.pas' {gdc_frmTaxActual},
  gdc_dlgTaxActual_unit in '..\Tax\gdc_dlgTaxActual_unit.pas' {gdc_dlgTaxActual},
  gdc_frmTaxDesignTime_unit in '..\Tax\gdc_frmTaxDesignTime_unit.pas' {gdc_frmTaxDesignTime},
  tax_frmPeriod_unit in '..\Tax\tax_frmPeriod_unit.pas' {frmPeriod},
  tax_frmAvailableTaxFunc_unit in '..\Tax\tax_frmAvailableTaxFunc_unit.pas' {frmAvailableTaxFunc},
  at_ActivateSetting_unit in '..\Attr\at_ActivateSetting_unit.pas' {ActivateSetting},
  prp_dfBreakPoints_unit in '..\Property\prp_dfBreakPoints_unit.pas' {dfBreakPoints},
  prp_dlgBreakPointProperty_unit in '..\Property\prp_dlgBreakPointProperty_unit.pas' {dlgBreakPointProperty},
  obj_GSFunction in '..\Property\obj_GSFunction.pas',
  tax_objDesignDate in '..\Tax\tax_objDesignDate.pas',
  gdc_frmAccountSel_unit in '..\Tax\gdc_frmAccountSel_unit.pas' {frmAccountSel},
  gdv_frameMapOfAnalitic_unit in '..\Transaction\gdv_frameMapOfAnalitic_unit.pas' {frameMapOfAnaliticLine: TFrame},
  tax_frmAnalytics_unit in '..\Tax\tax_frmAnalytics_unit.pas' {frmAnalytics},
  gdc_dlgTaxName_unit in '..\Tax\gdc_dlgTaxName_unit.pas' {gdc_dlgTaxName},
  gdc_frmTaxName_unit in '..\Tax\gdc_frmTaxName_unit.pas' {gdc_frmTaxName},
  tax_frmAddParamsFunc_unit in '..\Tax\tax_frmAddParamsFunc_unit.pas' {frmAddParamsFunc},
  gd_dlgAbout_unit in 'gd_dlgAbout_unit.pas' {gd_dlgAbout},
  gsDBGrid_dlgFind_unit in '..\Component\gsDBGrid_dlgFind_unit.pas' {gsdbGrid_dlgFind},
  gd_security_dlgDatabases_unit in '..\Security\gd_security_dlgDatabases_unit.pas' {gd_security_dlgDatabases},
  gd_dlgEntryFunctionWizard in '..\Component\gd_dlgEntryFunctionWizard.pas' {dlgEntryFunctionWizard},
  prp_VBStandart_const in '..\Property\prp_VBStandart_const.pas',
  gd_dlgEntryFunctionEdit in '..\Component\gd_dlgEntryFunctionEdit.pas' {dlgEntryFunctionEdit.pas},
  gdc_dlgInvRemainsOption_unit in '..\Inventory\gdc_dlgInvRemainsOption_unit.pas' {gdc_dlgInvRemainsOption},
  gdc_frmInvRemainsOption_unit in '..\Inventory\gdc_frmInvRemainsOption_unit.pas' {gdc_frmInvRemainsOption},
  wiz_dlgEditFrom_unit in '..\PROPERTY\FUNCTIONWIZARD\WIZ_DLGEDITFROM_UNIT.pas' {BlockEditForm},
  wiz_dlgFunctionEditorForm_unit in '..\Property\FunctionWizard\wiz_dlgFunctionEditorForm_unit.pas' {dlgFunctionEditForm},
  gdc_frmAutoTransaction_unit in '..\Transaction\gdc_frmAutoTransaction_unit.pas',
  rp_frmParamLineSE_unit in '..\REPORT\RP_FRMPARAMLINESE_UNIT.pas' {frmParamLineSE: TFrame},
  wiz_dlgIfEditForm_unit in '..\Property\FunctionWizard\wiz_dlgIfEditForm_unit.pas' {dlgIfEditForm},
  gd_dlgQuantityEntryEdit in '..\Component\gd_dlgQuantityEntryEdit.pas' {dlgQuantityEntryEdit},
  rf_Control in '..\Component\rf_Control.pas',
  wiz_dlgVarSelect_unit in '..\Property\FunctionWizard\wiz_dlgVarSelect_unit.pas' {dlgVarSelect},
  wiz_frmAddParamFunc_unit in '..\Property\FunctionWizard\wiz_frmAddParamFunc_unit.pas' {wizfrmAddParamsFunc},
  wiz_frmAvailableTaxFunc_unit in '..\Property\FunctionWizard\wiz_frmAvailableTaxFunc_unit.pas' {wizfrmAvailableTaxFunc},
  MSScriptControl_TLB,
  gdc_frmValueSel_unit in '..\Tax\gdc_frmValueSel_unit.pas' {frmValueSel},
  gdcGeneralLedger in '..\Component\GDC\gdcGeneralLedger.pas',
  obj_FinallyObject in '..\Property\obj_FinallyObject.pas',
  gdv_dlgAccounts_unit in '..\Transaction\gdv_dlgAccounts_unit.pas' {gdv_dlgAccounts},
  xFRepView_unit in '..\Report\xFRepView_unit.pas' {xFRepView},
  gdc_dlgContact_unit in '..\AddressBook\gdc_dlgContact_unit.pas' {gdc_dlgContact},
  gdv_frameAnalyticValue_unit in '..\Transaction\gdv_frameAnalyticValue_unit.pas',
  gdv_frameBaseAnalitic_unit in '..\Transaction\gdv_frameBaseAnalitic_unit.pas' {frameBaseAnalitic: TFrame},
  gdv_frameSum_unit in '..\Transaction\gdv_frameSum_unit.pas' {frameSum: TFrame},
  gdv_frameAnalitic_unit in '..\Transaction\gdv_frameAnalitic_unit.pas' {frameAnalitic: TFrame},
  gdv_frameQuantity_unit in '..\Transaction\gdv_frameQuantity_unit.pas' {frameQuantity: TFrame},
  wiz_dlgReserveVarName_unit in '..\Property\FunctionWizard\wiz_dlgReserveVarName_unit.pas' {dlgReserveVarName},
  AcctUtils in '..\Transaction\AcctUtils.pas',
  AcctStrings in '..\Transaction\AcctStrings.pas',
  gdv_framParamBaseFrame_unit in '..\Transaction\gdv_framParamBaseFrame_unit.pas' {framParamBaseFrame: TFrame},
  gdv_frAcctSum_unit in '..\Transaction\gdv_frAcctSum_unit.pas' {frAcctSum: TFrame},
  gdv_frAcctQuantity_unit in '..\Transaction\gdv_frAcctQuantity_unit.pas' {frAcctQuantity: TFrame},
  gdv_frAcctAnalytics_unit in '..\Transaction\gdv_frAcctAnalytics_unit.pas' {frAcctAnalytics: TFrame},
  gdv_frAcctAnalyticLine_unit in '..\Transaction\gdv_frAcctAnalyticLine_unit.pas' {frAcctAnalyticLine: TFrame},
  at_dlgLoadPackages_unit in '..\Attr\at_dlgLoadPackages_unit.pas' {at_dlgLoadPackages},
  at_dlgChoosePackage_unit in '..\Attr\at_dlgChoosePackage_unit.pas' {at_dlgChoosePackage},
  gdv_AvailAnalytics_unit in '..\Transaction\gdv_AvailAnalytics_unit.pas',
  gdv_AcctConfig_unit in '..\Transaction\gdv_AcctConfig_unit.pas',
  gdv_dlgfrAcctAnalyticsGroup_unit in '..\Transaction\gdv_dlgfrAcctAnalyticsGroup_unit.pas' {dlgfrAcctAnalyticsGroup: TFrame},
  gdc_dlgBaseAcctConfig in '..\Transaction\gdc_dlgBaseAcctConfig.pas' {dlgBaseAcctConfig},
  gdc_dlgAcctAccCard_unit in '..\Transaction\gdc_dlgAcctAccCard_unit.pas' {dlgAcctAccCardConfig},
  gdc_dlgAcctLedger_unit in '..\Transaction\gdc_dlgAcctLedger_unit.pas' {dlgAcctLedgerConfig},
  gdv_frAcctAnalyticsGroup_unit in '..\Transaction\gdv_frAcctAnalyticsGroup_unit.pas' {frAcctAnalyticsGroup},
  gdv_frAcctBaseAnalyticGroup in '..\Transaction\gdv_frAcctBaseAnalyticGroup.pas' {frAcctBaseAnalyticsGroup: TFrame},
  gsSupportClasses in '..\Property\gsSupportClasses.pas',
  gdc_dlgAutoTrRecord_unit,
  gdc_dlgAutoTransaction_unit,
  gsDBGrid,
  gdv_dlgConfigName_unit in '..\Transaction\gdv_dlgConfigName_unit.pas' {dlgConfigName},
  gdv_frAcctCompany_unit in '..\transaction\gdv_frAcctCompany_unit.pas' {frAcctCompany: TFrame},
  wiz_Strings_unit in '..\Property\FunctionWizard\wiz_Strings_unit.pas',
  wiz_dlgTrEntryEditForm_unit in '..\Property\FunctionWizard\wiz_dlgTrEntryEditForm_unit.pas' {dlgTrEntryEditForm},
  wiz_ExpressionEditorForm_unit in '..\PROPERTY\FUNCTIONWIZARD\WIZ_EXPRESSIONEDITORFORM_UNIT.pas' {ExpressionEditorForm},
  wiz_dlgTrExpressionEditorForm_unit in '..\Property\FunctionWizard\wiz_dlgTrExpressionEditorForm_unit.pas' {dlgTrExpressionEditorForm},
  wiz_DocumentInfo_unit in '..\Property\FunctionWizard\wiz_DocumentInfo_unit.pas',
  wiz_frAnalyticLine_unit in '..\Property\FunctionWizard\wiz_frAnalyticLine_unit.pas' {frAnalyticLine: TFrame},
  wiz_dlgQunatyForm_unit in '..\Property\FunctionWizard\wiz_dlgQunatyForm_unit.pas' {dlgQuantiyForm},
  tax_Strings_unit in '..\Tax\tax_Strings_unit.pas',
  wiz_TrPosEntryEditFrame_Unit in '..\Property\FunctionWizard\wiz_TrPosEntryEditFrame_Unit.pas' {frTrPosEntryEditFrame: TFrame},
  prp_frmTypeInfo in '..\Property\prp_frmTypeInfo.pas' {frmTypeInfo},
  wiz_frEditFrame_unit in '..\PROPERTY\FUNCTIONWIZARD\WIZ_FREDITFRAME_UNIT.pas' {frEditFrame: TFrame},
  wiz_frWhileEditFrame_unit in '..\Property\FunctionWizard\wiz_frWhileEditFrame_unit.pas' {frWhileEditFrame: TFrame},
  wiz_frForCycleEditFrame_Unit in '..\Property\FunctionWizard\wiz_frForCycleEditFrame_Unit.pas' {frForCycleEditFrame: TFrame},
  wiz_frSelectEditFrame_unit in '..\Property\FunctionWizard\wiz_frSelectEditFrame_unit.pas' {frSelectEditFrame: TFrame},
  wiz_frCaseEditFrame_unit in '..\Property\FunctionWizard\wiz_frCaseEditFrame_unit.pas' {frCaseEditFrame: TFrame},
  wiz_frDocumentTransactionEditFrame_unit in '..\Property\FunctionWizard\wiz_frDocumentTransactionEditFrame_unit.pas' {frDocumentTransactionEditFrame: TFrame},
  wiz_frSQLCycleEditFrame_unit in '..\Property\FunctionWizard\wiz_frSQLCycleEditFrame_unit.pas' {frSQLCycleEditFrame: TFrame},
  wiz_frSQLCycleParamLine_unit in '..\Property\FunctionWizard\wiz_frSQLCycleParamLine_unit.pas' {SQLCycleParamLine: TFrame},
  wiz_dlgCustumAnalytic_unit in '..\Property\FunctionWizard\wiz_dlgCustumAnalytic_unit.pas' {CustomAnalyticForm},
  st_frmMain_unit in '..\Storage\st_frmMain_unit.pas' {st_frmMain},
  gdc_frmAcctBaseConfig_unit in '..\Transaction\gdc_frmAcctBaseConfig_unit.pas' {gdc_frmAcctBaseConfig},
  gdc_frmAcctLedger_unit in '..\Transaction\gdc_frmAcctLedger_unit.pas' {gdc_frmAcctLedger},
  gdc_frmAcctAccCard_Unit in '..\Transaction\gdc_frmAcctAccCard_Unit.pas' {gdc_frmAcctAccCard},
  gdc_frmInvSelectedGoods_unit in '..\Inventory\gdc_frmInvSelectedGoods_unit.pas' {gdc_frmInvSelectedGoods},
  gdvParamPanel in '..\Transaction\gdvParamPanel.pas',
  gdv_frameAccounts_unit in '..\Transaction\gdv_frameAccounts_unit.pas' {Frame1: TFrame},
  prp_frm_Unit in '..\Property\prp_frm_Unit.pas' {prp_frm},
  wiz_FunctionEditFrame_Unit in '..\PROPERTY\FUNCTIONWIZARD\WIZ_FUNCTIONEDITFRAME_UNIT.pas' {frFunctionEditFrame: TFrame},
  wiz_EntryFunctionEditFrame_Unit in '..\Property\FunctionWizard\wiz_EntryFunctionEditFrame_Unit.pas' {frEntryFunctionEditFrame: TFrame},
  gdc_frmCurrOnly_unit in '..\Common\gdc_frmCurrOnly_unit.pas' {gdc_frmCurrOnly},
  wiz_frBalanceOffTrEntry_unit in '..\Property\FunctionWizard\wiz_frBalanceOffTrEntry_unit.pas' {frBalanceOffTrEntry: TFrame},
  gd_registration in '..\Registration\gd_registration.pas',
  gd_dlgReg_unit in '..\Registration\gd_dlgReg_unit.pas' {gd_dlgReg},
  wiz_frAnalytics_unit in '..\Property\FunctionWizard\wiz_frAnalytics_unit.pas' {frAnalytics: TFrame},
  wiz_frFixedAnalytics_unit in '..\Property\FunctionWizard\wiz_frFixedAnalytics_unit.pas' {frFixedAnalytics: TFrame},
  gdc_dlgAcctCirculationList_unit in '..\Transaction\gdc_dlgAcctCirculationList_unit.pas' {dlgAcctCirculationList},
  gdc_frmAcctCirculationList_unit in '..\Transaction\gdc_frmAcctCirculationList_unit.pas' {gdc_frmAcctCirculationList},
  wiz_frQuantity_unit in '..\Property\FunctionWizard\wiz_frQuantity_unit.pas' {frQuantity: TFrame},
  gdc_attr_dlgSetToTxt_unit in '..\Attr\gdc_attr_dlgSetToTxt_unit.pas' {gdc_attr_dlgSetToTxt},
  gdv_frAcctTreeAnalytic_unit in '..\Transaction\gdv_frAcctTreeAnalytic_unit.pas' {gdv_frAcctTreeAnalytic: TFrame},
  gdv_frAcctTreeAnalyticLine_unit in '..\Transaction\gdv_frAcctTreeAnalyticLine_unit.pas' {gdv_frAcctTreeAnalyticLine: TFrame},
  gdcSetting in '..\Component\GDC\gdcSetting.pas',
  frAcctEntrySimpleLine_unit in '..\Transaction\frAcctEntrySimpleLine_unit.pas' {frAcctEntrySimpleLine: TFrame},
  frAcctEntrySimpleLineQuantity_unit in '..\Transaction\frAcctEntrySimpleLineQuantity_unit.pas' {frEntrySimpleLineQuantity: TFrame},
  frAcctQuantityLine_unit in '..\Transaction\frAcctQuantityLine_unit.pas' {frAcctQuantityLine: TFrame},
  gdv_dlgSelectDocument_unit in '..\Transaction\gdv_dlgSelectDocument_unit.pas' {dlgSelectDocument},
  gdc_frmAcctGeneralLedger_unit in '..\Transaction\gdc_frmAcctGeneralLedger_unit.pas' {gdc_frmAcctGeneralLedger},
  gdc_dlgAcctGeneralLedger_unit in '..\Transaction\gdc_dlgAcctGeneralLedger_unit.pas' {dlgAcctGeneralLedger},
  prp_BaseFrame_unit in '..\Property\prp_BaseFrame_unit.pas' {BaseFrame: TFrame},
  prp_TemplateFrame_unit in '..\Property\prp_TemplateFrame_unit.pas' {TemplateFrame: TFrame},
  prp_ReportFunctionFrame_unit in '..\Property\prp_ReportFunctionFrame_unit.pas' {ReportFunctionFrame: TFrame},
  gdc_frmDelphiObject_unit in '..\Property\gdc_frmDelphiObject_unit.pas' {gdc_frmDelphiObject},
  gd_dlgAddLinked_unit in 'gd_dlgAddLinked_unit.pas' {gd_dlgAddLinked},
  gdc_frmLink_unit in '..\Component\GDC\gdc_frmLink_unit.pas' {gdc_frmLink},
  gdc_dlgLink_unit in '..\Component\GDC\gdc_dlgLink_unit.pas' {gdc_dlgLink},
  gdc_frmMD2H_unit in '..\Component\Repository\gdc_frmMD2H_unit.pas' {gdc_frmMD2H},
  gdv_frmInvCard_unit in '..\Inventory\gdv_frmInvCard_unit.pas' {gdv_frmInvCard},
  gdv_InvCardConfig_unit in '..\Inventory\gdv_InvCardConfig_unit.pas',
  gdc_frmInvCardConfig_unit in '..\Inventory\gdc_frmInvCardConfig_unit.pas' {gdc_frmInvCardConfig},
  gdc_dlgInvCardConfig_unit in '..\Inventory\gdc_dlgInvCardConfig_unit.pas' {gdc_dlgInvCardConfig},
  frFieldVlues_unit in '..\Inventory\frFieldVlues_unit.pas' {frFieldValues: TFrame},
  frFieldValuesLine_unit in '..\Inventory\frFieldValuesLine_unit.pas' {frFieldValuesLine: TFrame},
  frFieldValuesLineConfig_unit in '..\Inventory\frFieldValuesLineConfig_unit.pas' {frFieldValuesLineConfig: TFrame},
  gdc_dlgChooseSet_unit in '..\Inventory\gdc_dlgChooseSet_unit.pas' {dlg_ChooseSet},
  gdv_dlgInvCardParams_unit in '..\Inventory\gdv_dlgInvCardParams_unit.pas' {gdv_dlgInvCardParams},
  gd_converttext in '..\Component\gd_converttext.pas',
  gdc_dlgAcctAccReview_unit in '..\Transaction\gdc_dlgAcctAccReview_unit.pas' {dlgAcctAccReviewConfig},
  gdc_frmAcctAccReview_Unit in '..\Transaction\gdc_frmAcctAccReview_Unit.pas' {gdc_frmAcctAccReview},
  gsIBLookupComboBox_dlgAction in '..\Component\gsIBLookupComboBox_dlgAction.pas' {gsIBLkUp_dlgAction},
  gdSQLMonitor in '..\Log\gdSQLMonitor.pas',
  gd_frmSQLMonitor_unit in '..\Log\gd_frmSQLMonitor_unit.pas' {gd_frmSQLMonitor},
  gdcSQLStatement in '..\Component\GDC\gdcSQLStatement.pas',
  gdc_frmSQLStatement_unit in '..\Log\gdc_frmSQLStatement_unit.pas' {gdc_frmSQLStatement},
  gdc_dlgSQLStatement_unit in '..\Log\gdc_dlgSQLStatement_unit.pas' {gdc_dlgSQLStatement},
  IBSQLCache in '..\IBX\IBSQLCache.pas',
  dlgClassInfo_unit in '..\Property\dlgClassInfo_unit.pas' {dlgClassInfo},
  gdcUserGroup_dlgSetRights_unit in '..\GAdmin\gdcUserGroup_dlgSetRights_unit.pas' {gdcUserGroup_dlgSetRights},
  gdDBImpExp_unit in '..\Common\gdDBImpExp_unit.pas',
  prp_FunctionHistoryFrame_unit in '..\Property\prp_FunctionHistoryFrame_unit.pas' {prp_FunctionHistoryFrame: TFrame},
  prp_ScriptComparer_unit in '..\Property\prp_ScriptComparer_unit.pas' {prp_ScriptComparer},
  cmp_frmDataBaseCompare in '..\Property\cmp_frmDataBaseCompare.pas' {DataBaseCompare},
  gd_dlgRestoreWarning_unit in 'gd_dlgRestoreWarning_unit.pas' {gd_dlgRestoreWarning},
  IBSQL_WaitWindow in '..\IBX\IBSQL_WaitWindow.pas',
  gdcStreamSaver in '..\Component\GDC\gdcStreamSaver.pas',
  gd_dlgStreamSaverOptions in '..\Attr\gd_dlgStreamSaverOptions.pas'
  {$IFDEF FR4}
  ,rp_StreamFR4 in '..\Report\rp_StreamFR4.pas',
  rp_FR4Functions in '..\Report\rp_FR4Functions.pas'
  {$ENDIF}
  , gdv_frmCalculateBalance in '..\Transaction\gdv_frmCalculateBalance.pas'
  , gdc_frmClosePeriod in '..\Attr\gdc_frmClosePeriod.pas'
  , gdvAcctBase in '..\Transaction\gdvAcctBase.pas'
  , gdvAcctAccCard in '..\Transaction\gdvAcctAccCard.pas'
  , gdvAcctAccReview in '..\Transaction\gdvAcctAccReview.pas'
  , gdvAcctLedger in '..\Transaction\gdvAcctLedger.pas'
  , gdvAcctGeneralLedger in '..\Transaction\gdvAcctGeneralLedger.pas'
  , gdvAcctCirculationList in '..\Transaction\gdvAcctCirculationList.pas'
  , gdv_frmAcctCirculationList_unit in '..\Transaction\gdv_frmAcctCirculationList_unit.pas'
  , gdv_frmAcctGeneralLedger_unit in '..\Transaction\gdv_frmAcctGeneralLedger_unit.pas'
  , gdv_frmAcctBaseForm_unit in '..\Transaction\gdv_frmAcctBaseForm_unit.pas'
  , gdv_frmAcctAccCard_unit in '..\Transaction\gdv_frmAcctAccCard_unit.pas'
  , gdv_frmAcctLedger_unit in '..\Transaction\gdv_frmAcctLedger_unit.pas'
  , gdv_frmAcctAccReview_unit in '..\Transaction\gdv_frmAcctAccReview_unit.pas'
  {$IFDEF DEBUG}
  , ExceptionDialog_unit in '..\Component\ExceptionDialog_unit.pas' {ExceptionDialog}
  {$ENDIF}
  , gd_frmMonitoring_unit in 'gd_frmMonitoring_unit.pas' {gd_frmMonitoring}
  , gdcBlockRule
  , gd_DatabasesList_unit;

{$R Gedemin.TLB}
{$R *.RES}

type
  TFactoryRegisterClass = class(TObject)
  private
    procedure FactoryRegisterClassObject(Factory: TComObjectFactory);
  end;

procedure TFactoryRegisterClass.FactoryRegisterClassObject(
  Factory: TComObjectFactory);
begin
  Factory.RegisterClassObject;
end;

procedure DoInitComServer;
begin
  with TFactoryRegisterClass.Create do
  try
    ComClassManager.ForEachFactory(ComServer, FactoryRegisterClassObject);
  finally
    Free;
  end;
  if ComServer.StartSuspended then
    ComObj.CoResumeClassObjects;
end;

var
  MutexHandle: THandle;
  MutexExisted: Boolean;
  BP: Integer;

function ShouldProceedLoading: Boolean;
begin
  Result := gd_CmdLineParams.Embedding or
    gd_CmdLineParams.QuietMode or
    (MessageBox(
      0,
      'Программный продукт GEDEMIN.EXE уже загружен в память!' + #13#10#13#10 +
      'Продолжить загрузку?',
      'Внимание',
      MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES);
end;

{$IFDEF VER130}
procedure DisableProcessWindowsGhosting;
var
  DisableProcessWindowsGhostingProc: procedure;
begin
  DisableProcessWindowsGhostingProc := GetProcAddress(
    GetModuleHandle('user32.dll'),
    'DisableProcessWindowsGhosting');
  if Assigned(DisableProcessWindowsGhostingProc) then
    DisableProcessWindowsGhostingProc;
end;
{$ENDIF}

function RestoreDatabase: Boolean;
var
  IBRestore: TIBRestoreService;
begin
  Result := False;

  if gd_CmdLineParams.RestoreServer > '' then
  begin
    IBRestore := TIBRestoreService.Create(nil);
    try
      if AnsiCompareText(gd_CmdLineParams.RestoreServer, 'EMBEDDED') = 0 then
      begin
        IBRestore.Protocol := Local;
        IBRestore.ServerName := '';
      end else
      begin
        IBRestore.Protocol := TCP;
        IBRestore.ServerName := gd_CmdLineParams.RestoreServer;
      end;

      IBRestore.BackupFile.Text := gd_CmdLineParams.RestoreBKFile;
      IBRestore.DatabaseName.Text := gd_CmdLineParams.RestoreDBFile;

      IBRestore.LoginPrompt := False;
      IBRestore.Params.Clear;
      IBRestore.Params.Add('user_name=' + gd_CmdLineParams.RestoreUser);
      IBRestore.Params.Add('password=' + gd_CmdLineParams.RestorePassword);

      IBRestore.PageSize := gd_CmdLineParams.RestorePageSize;
      IBRestore.PageBuffers := gd_CmdLineParams.RestoreBufferSize;

      IBRestore.Options := [CreateNewDB];
      IBRestore.Verbose := False;

      try
        IBRestore.Active := True;
        IBRestore.ServiceStart;
        while (not IBRestore.EOF) and IBRestore.IsServiceRunning do
        begin
          IBRestore.GetNextLine;
        end;
        IBRestore.Active := False;
        ExitCode := 0;
      except
        on E: Exception do
        begin
          MessageBox(0,
            PChar('Ошибка при распаковке БД: ' + E.Message),
            'Ошибка',
            MB_OK or MB_TASKMODAL or MB_ICONHAND);
          ExitCode := 1;
        end;
      end;
    finally
      IBRestore.Free;
    end;

    Result := True;
  end;
end;

function CheckRequiredFiles: Boolean;
const
  ReqFilesCount = 3;
  ReqFiles: array[1..ReqFilesCount] of String = (
    'midas.dll',
    'midas.sxs.manifest',
    'gedemin.exe.manifest'
  );
var
  I: Integer;
  S, AppPath, FullName: String;
begin
  AppPath := ExtractFilePath(Application.EXEName);
  S := '';
  for I := 1 to ReqFilesCount do
  begin
    FullName := AppPath + ReqFiles[I];
    if not FileExists(FullName) then
      S := S + FullName + #13#10;
  end;
  if S > '' then
  begin
    if not gd_CmdLineParams.QuietMode then
    begin
      MessageBox(0,
        PChar('Отсутствуют необходимые файлы:'#13#10#13#10 + S + #13#10 +
        'Повторите установку программы.'),
        'Внимание',
        MB_ICONHAND or MB_TASKMODAL or MB_OK);
    end;
    Result := False;
  end else
    Result := True;
end;

function CheckMIDASRegistered: Boolean;

  procedure DeleteKey(const K: String);
  var
    SL: TStrings;
    R: TRegistry;
    I: Integer;
  begin
    R := TRegistry.Create(KEY_ALL_ACCESS);
    SL := TStringList.Create;
    try
      R.RootKey := HKEY_CLASSES_ROOT;
      if R.OpenKey(K, False) then
      begin
        R.GetKeyNames(SL);
        for I := 0 to SL.Count - 1 do
          DeleteKey(K + '\' + SL[I]);
        R.CloseKey;
        R.DeleteKey(K);
      end;
    finally
      SL.Free;
      R.Free;
    end;
  end;

var
  Reg: TRegistry;
  FN: String;
begin
  Result := True;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;

    if Reg.OpenKeyReadOnly('CLSID\' + MIDAS_GUID1 + '\InProcServer32')
      and (Reg.GetDataType('') = rdString) and (Reg.ReadString('') > '') then
    begin
      FN := Reg.ReadString('');

      if not FileExists(FN) then
      begin
        if MessageBox(0,
          PChar('Библиотека ' + FN + #13#10 +
          'зарегистрирована в реестре, но отсутствует на диске!'#13#10#13#10 +
          'Удалить из реестра все элементы, относящиеся к MIDAS.DLL?'),
          'Внимание',
          MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES then
        begin
          Reg.CloseKey;
          try
            Reg.Access := KEY_ALL_ACCESS;
            DeleteKey('TypeLib\' + MIDAS_TYPELIB_GUID);
            DeleteKey('CLSID\' + MIDAS_GUID1);
            DeleteKey('CLSID\' + MIDAS_GUID2);
            DeleteKey('CLSID\' + MIDAS_GUID3);
            DeleteKey('CLSID\' + MIDAS_GUID4);
            MessageBox(0,
              'Для продолжения работы перезапустите программу.',
              'Внимание',
            MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
          except
            MessageBox(0,
              'Для изменения реестра необходимы права администратора на компьютере!',
              'Внимание',
            MB_OK or MB_ICONHAND or MB_TASKMODAL);
          end;
        end;
        Result := False;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

var
  DC: HDC;
  ApplicationEventsHandler: TgdApplicationEventsHandler;
  FApplicationEvents: TApplicationEvents;

begin
  if not CheckMIDASRegistered then
    exit;

  if not CheckRequiredFiles then
    exit;

{$IFDEF VER130}
  DisableProcessWindowsGhosting;
{$ENDIF}

  if RestoreDatabase then
    exit;

{$IFDEF GEDEMIN_LOCK}
  IsRegisteredCopy := CheckRegistration;
{$ENDIF}

  ApplicationEventsHandler := TgdApplicationEventsHandler.Create;
  try
    FApplicationEvents := TApplicationEvents.Create(Application);
    FApplicationEvents.OnException := ApplicationEventsHandler.ApplicationEventsException;
    FApplicationEvents.OnHelp := ApplicationEventsHandler.ApplicationEventsHelp;
    FApplicationEvents.OnShortCut :=  ApplicationEventsHandler.ApplicationEventsShortCut;

    // Проверяем загружено ли приложение в режиме COM-server
    if not gd_CmdLineParams.Embedding then
    begin
      DC := GetDC(0);
      try
        BP := GetDeviceCaps(DC, BITSPIXEL);
        if BP < 8 then
        begin
          MessageBox(0,
            'Для работы программы необходимо установить режим как минимум в 256 цветов.',
            'Внимание',
            MB_OK or MB_ICONHAND);
          exit;
        end
        else if BP < 16 then
        begin
          GridStripeProh := True;
        end;
      finally
        ReleaseDC(0, DC);
      end;
    end;

    /////////////////////////////////////////////////
    // Шмат дзе нашая праграма робіць дапушчэньне, што
    // памер цэлага раўняецца памеру ўказальніка

    Assert(SizeOf(TID) = SizeOf(Integer));
    Assert(SizeOf(Integer) = SizeOf(Pointer));
    Assert(SizeOf(AnsiChar) = SizeOf(Byte));

    ///////////////////
    // Создание мютекса

    MutexHandle := CreateMutex(nil, True, PChar(GedeminMutexName));
    MutexExisted := GetLastError = ERROR_ALREADY_EXISTS;
    try
      if (MutexHandle = 0) or (not MutexExisted)
        or (MutexExisted and ShouldProceedLoading) then
      begin

        try
          Application.Initialize;
        except
          on E: EOLESysError do
            if ComServer.StartMode in [smRegServer, smUnregServer] then
              raise
            else
              DoInitComServer;
          else
            raise;
        end;

        {$IFDEF NOGEDEMIN}
        Application.Title := '';
        {$ELSE}
        Application.Title := 'Гедымин';
        {$ENDIF}
        if not gd_CmdLineParams.Embedding then
        begin
          // При изменении этого блока кода необходимо синхронизировать код в obj_GedeminApplication.IsCanConnect
          {$IFDEF SPLASH}
          Application.ShowMainForm := False;
          Application.CreateForm(TfrmSplashHidden, frmSplashHidden);
          if (not gd_CmdLineParams.NoSplash) and (not GridStripeProh) then
            try
              Application.CreateForm(TfrmSplash, frmSplash);
            except
              frmSplash := nil;
            end;
          {$ENDIF}
          Application.CreateForm(TdmDatabase, dmDatabase);
          Application.CreateForm(TdmImages, dmImages);

          Application.CreateForm(TdmClientReport, dmClientReport);
          Application.CreateForm(TdmLogin, dmLogin);

          FreeAndNil(frmSplashHidden);
          Application.ShowMainForm := True;
          Application.CreateForm(TfrmGedeminMain, frmGedeminMain);
        end else
        begin
          // Если приложение COM-server, надо создать левую главную форму
          // При подключении она освобождается
          Application.ShowMainForm := False;
          Application.CreateForm(TfrmOLEMainForm, frmOLEMainForm);
        end;

        Application.Run;
      end;

    finally
      {при завершении процесса удалятся операционной системой
      ReleaseMutex(MutexHandle);
      CloseHandle(MutexHandle);}
    end;
  finally
    ApplicationEventsHandler.Free;
  end;
end.





