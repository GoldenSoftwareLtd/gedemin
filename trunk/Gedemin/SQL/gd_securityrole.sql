
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    gd_securityrole.sql

  Abstract

    An Interbase script with basic ROLE.

  Author

    Andrey Shadevsky (21.09.00)

  Revisions history

    Initial  21.09.00  JKL    Initial version

  Status

    Complete.

*/

GRANT ALL ON gd_ruid TO administrator;
GRANT ALL ON gd_link TO administrator;
GRANT ALL ON FIN_VERSIONINFO TO administrator;
GRANT ALL ON GD_USER TO administrator;
GRANT ALL ON GD_SUBSYSTEM TO administrator;
GRANT ALL ON GD_USERGROUP TO administrator;
GRANT ALL ON GD_JOURNAL TO administrator;
GRANT ALL ON GD_DOCUMENTTYPE TO administrator;

GRANT ALL ON GD_CONST TO administrator;
GRANT ALL ON GD_CONSTVALUE TO administrator;
GRANT ALL ON AC_ACCOUNT TO administrator;

GRANT ALL ON GD_DOCUMENT TO administrator;
GRANT ALL ON GD_CURR TO administrator;
GRANT ALL ON GD_LASTNUMBER TO administrator;
GRANT ALL ON GD_CURRRATE TO administrator;
GRANT ALL ON GD_CONTACT TO administrator;

GRANT ALL ON GD_BANK TO administrator;
GRANT ALL ON GD_OURCOMPANY TO administrator;
GRANT ALL ON GD_PEOPLE TO administrator;
GRANT ALL ON GD_USERCOMPANY TO administrator;
GRANT ALL ON FLT_SAVEDFILTER TO administrator;
GRANT ALL ON FLT_PROCEDUREFILTER TO administrator;
GRANT ALL ON FLT_COMPONENTFILTER TO administrator;
GRANT ALL ON FLT_LASTFILTER TO administrator;
GRANT ALL ON GD_COMPANY TO administrator;
GRANT ALL ON GD_COMPANYCODE TO administrator;
GRANT ALL ON GD_COMPANYACCOUNT TO administrator;
GRANT ALL ON BN_BANKSTATEMENT TO administrator;
GRANT ALL ON GD_CONTACTLIST TO administrator;
GRANT ALL ON BN_BANKSTATEMENTLINE TO administrator;
GRANT ALL ON GD_FUNCTION TO administrator;
GRANT ALL ON GD_FUNCTION_LOG TO administrator;
GRANT ALL ON BUG_BUGBASE TO administrator;
GRANT ALL ON GD_COMMAND TO administrator;
GRANT ALL ON GD_DESKTOP TO administrator;
GRANT ALL ON GD_GOODGROUP TO administrator;
GRANT ALL ON GD_VALUE TO administrator;
GRANT ALL ON GD_TNVD TO administrator;
GRANT ALL ON GD_GOOD TO administrator;
GRANT ALL ON GD_GOODSET TO administrator;
GRANT ALL ON GD_GOODVALUE TO administrator;
GRANT ALL ON GD_GOODTAX TO administrator;
GRANT ALL ON GD_TAX TO administrator;
GRANT ALL ON GD_GOODBARCODE TO administrator;
GRANT ALL ON GD_PRECIOUSEMETAL TO administrator;
GRANT ALL ON GD_GOODPRMETAL TO administrator;

GRANT ALL ON inv_card TO administrator;
GRANT ALL ON inv_movement TO administrator;
GRANT ALL ON inv_balance TO administrator;
GRANT ALL ON inv_price TO administrator;
GRANT ALL ON inv_priceline TO administrator;
GRANT ALL ON inv_balanceoption TO administrator;

GRANT ALL ON MSG_BOX TO administrator;
GRANT ALL ON MSG_MESSAGE TO administrator;
GRANT ALL ON MSG_MESSAGERULES TO administrator;
GRANT ALL ON MSG_TARGET TO administrator;
GRANT ALL ON MSG_ATTACHMENT TO administrator;
GRANT ALL ON MSG_ACCOUNT TO administrator;
GRANT ALL ON AT_RELATIONS TO administrator;
GRANT ALL ON AT_FIELDS TO administrator;
GRANT ALL ON AT_RELATION_FIELDS TO administrator;
GRANT ALL ON AT_TRANSACTION TO administrator;
GRANT ALL ON AT_GENERATORS TO administrator;
GRANT ALL ON AT_CHECK_CONSTRAINTS TO administrator;
GRANT ALL ON GD_GLOBALSTORAGE TO administrator;
GRANT ALL ON GD_COMPANYSTORAGE TO administrator;
GRANT ALL ON GD_USERSTORAGE TO administrator;
GRANT ALL ON RP_REGISTRY TO administrator;
GRANT ALL ON RP_REPORTGROUP TO administrator;
GRANT ALL ON RP_REPORTLIST TO administrator;
GRANT ALL ON RP_REPORTRESULT TO administrator;
GRANT ALL ON RP_REPORTSERVER TO administrator;
GRANT ALL ON RP_REPORTDEFAULTSERVER TO administrator;
GRANT ALL ON RP_REPORTTEMPLATE TO administrator;
GRANT ALL ON RP_ADDITIONALFUNCTION TO administrator;

GRANT ALL ON evt_object TO administrator;
GRANT ALL ON evt_objectevent TO administrator;
GRANT ALL ON evt_macrosgroup TO administrator;
GRANT ALL ON evt_macrosgroup TO administrator;
GRANT ALL ON evt_macroslist TO administrator;

GRANT ALL ON BN_BANKCATALOGUE TO administrator;
GRANT ALL ON BN_BANKCATALOGUELINE TO administrator;
GRANT ALL ON GD_DOCUMENTLINK TO administrator;
GRANT ALL ON GD_PLACE TO administrator;
GRANT ALL ON GD_COMPACCTYPE TO administrator;

GRANT ALL ON ac_companyaccount TO administrator;
GRANT ALL ON ac_transaction TO administrator;
GRANT ALL ON ac_trrecord TO administrator;
GRANT ALL ON ac_record TO administrator;
GRANT ALL ON ac_entry TO administrator;
GRANT ALL ON ac_entry_balance TO administrator;
GRANT ALL ON ac_accvalue TO administrator;

GRANT ALL ON GD_V_USER_GENERATORS TO administrator;
GRANT ALL ON GD_V_USER_TRIGGERS TO administrator;
GRANT ALL ON GD_V_FOREIGN_KEYS TO administrator;
GRANT ALL ON GD_V_PRIMARY_KEYS TO administrator;
GRANT ALL ON GD_V_USER_INDICES TO administrator;
GRANT ALL ON GD_V_TABLES_WBLOB TO administrator;
GRANT ALL ON GD_V_CONTACTLIST TO administrator;
GRANT ALL ON GD_V_COMPANY TO administrator;

GRANT EXECUTE ON PROCEDURE FIN_P_VER_GETDBVERSION TO administrator;
GRANT EXECUTE ON PROCEDURE GD_P_SEC_GETGROUPSFORUSER TO administrator;
GRANT EXECUTE ON PROCEDURE GD_P_SEC_LOGINUSER TO administrator;
GRANT EXECUTE ON PROCEDURE GD_P_GETFOLDERELEMENT TO administrator;

GRANT EXECUTE ON PROCEDURE GD_P_RELATION_FORMATS TO administrator;

GRANT EXECUTE ON PROCEDURE gd_p_SetCompanyToPeople TO administrator;
GRANT EXECUTE ON PROCEDURE bn_p_update_bankstatement TO administrator;
GRANT EXECUTE ON PROCEDURE bn_p_update_all_bankstatements TO administrator;
GRANT EXECUTE ON PROCEDURE at_p_sync TO administrator;

GRANT EXECUTE ON PROCEDURE gd_p_getnextusergroupid TO administrator;
GRANT EXECUTE ON PROCEDURE gd_p_gettableswithdescriptors TO administrator;

GRANT EXECUTE ON PROCEDURE inv_p_getcards TO administrator;

GRANT ALL ON AT_EXCEPTIONS TO administrator;
GRANT ALL ON AT_INDICES TO administrator;
GRANT EXECUTE ON PROCEDURE at_p_sync_indexes TO administrator;

GRANT ALL ON AT_TRIGGERS TO administrator;
GRANT EXECUTE ON PROCEDURE at_p_sync_triggers TO administrator;

GRANT ALL ON AT_SETTING TO administrator;
GRANT ALL ON AT_SETTINGPOS TO administrator;
GRANT ALL ON AT_SETTING_STORAGE TO administrator;

GRANT ALL ON AT_PROCEDURES TO administrator;

GRANT ALL ON WG_HOLIDAY TO administrator;
GRANT ALL ON WG_TBLCAL TO administrator;
GRANT ALL ON WG_TBLCALDAY TO administrator;
GRANT ALL ON WG_POSITION TO administrator;

GRANT ALL ON GD_SQL_STATEMENT TO administrator;
GRANT ALL ON GD_SQL_LOG TO administrator;

GRANT ALL ON GD_SQL_HISTORY TO administrator;

GRANT ALL ON GD_STORAGE_DATA TO administrator;

GRANT EXECUTE ON PROCEDURE at_p_sync_indexes_all TO administrator;
GRANT EXECUTE ON PROCEDURE at_p_sync_triggers_all TO administrator;

GRANT EXECUTE ON PROCEDURE gd_p_getruid TO administrator;
GRANT EXECUTE ON PROCEDURE gd_p_getid TO administrator;
GRANT EXECUTE ON PROCEDURE AC_ACCOUNTEXSALDO TO administrator;
GRANT EXECUTE ON PROCEDURE AC_ACCOUNTEXSALDO_BAL TO administrator;
GRANT EXECUTE ON PROCEDURE AC_CIRCULATIONLIST TO administrator;
GRANT EXECUTE ON PROCEDURE AC_CIRCULATIONLIST_BAL TO administrator;
GRANT EXECUTE ON PROCEDURE ac_q_circulation TO administrator;
GRANT EXECUTE ON PROCEDURE AC_L_S TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_Q_S TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_L_S1 TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_Q_S1 TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_L_Q TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_E_L_S TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_E_Q_S TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_E_L_S1 TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_E_Q_S1 TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_G_L_S TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE AC_Q_G_L TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE  AC_GETSIMPLEENTRY TO ADMINISTRATOR;
GRANT EXECUTE ON PROCEDURE  INV_GETCARDMOVEMENT TO ADMINISTRATOR;

GRANT ALL ON AC_AUTOTRRECORD TO ADMINISTRATOR;
GRANT ALL ON AC_GENERALLEDGER TO ADMINISTRATOR;
GRANT ALL ON AC_G_LEDGERACCOUNT TO ADMINISTRATOR;
GRANT ALL ON AC_ACCT_CONFIG TO ADMINISTRATOR;
GRANT ALL ON AC_LEDGER_ACCOUNTS TO ADMINISTRATOR;
GRANT ALL ON ac_ledger_entries TO ADMINISTRATOR;
GRANT ALL ON ac_autoentry TO ADMINISTRATOR;

GRANT ALL ON gd_ruid TO PROCEDURE gd_p_getruid;
GRANT ALL ON gd_ruid TO PROCEDURE gd_p_getid;

GRANT ALL ON gd_holding TO administrator;

GRANT ALL ON gd_taxtype       TO administrator;
GRANT ALL ON gd_taxname       TO administrator;
GRANT ALL ON gd_taxactual     TO administrator;
GRANT ALL ON gd_taxdesigndate TO administrator;
GRANT ALL ON gd_taxresult     TO administrator;

GRANT ALL ON ac_quantity      TO administrator;
GRANT ALL ON GD_FILE          TO ADMINISTRATOR;

GRANT ALL ON GD_V_OURCOMPANY  TO administrator;

GRANT ALL ON rpl_database     TO administrator;
GRANT ALL ON rpl_record       TO administrator;

GRANT ALL ON gd_ref_constraints TO administrator;
GRANT ALL ON gd_ref_constraint_data TO administrator;

GRANT ALL ON gd_weblog        TO administrator;
GRANT ALL ON gd_weblogdata    TO administrator;

GRANT ALL ON gd_object_dependencies TO administrator;

COMMIT;
