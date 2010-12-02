

/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    dp_securityrole.sql

  Abstract

    An Interbase script with basic ROLE for "DEPARTMENT".

  Author

    Anton Smirnov (15.10.00)

  Revisions history

    Initial  10.10.00  SAI    Initial version

  Status

    Draft

*/

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

GRANT ALL ON dp_authority TO administrator;
GRANT ALL ON dp_assetdest TO administrator;
GRANT ALL ON dp_decree TO administrator;
GRANT ALL ON dp_inventory TO administrator;
GRANT ALL ON dp_transfer TO administrator;
GRANT ALL ON dp_revaluation TO administrator;
GRANT ALL ON dp_withdrawal TO administrator;

GRANT EXECUTE ON PROCEDURE DP_CALC_DEBTS_FOR_ACTS TO administrator;

COMMIT;
