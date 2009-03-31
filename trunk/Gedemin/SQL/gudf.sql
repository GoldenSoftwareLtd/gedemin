
/*********************************************************/
/*                                                       */
/*      InterBase User Defined Fuctions                  */
/*      GUDF library                                     */
/*      Copyright (c) 1999 by Golden Software            */
/*                                                       */
/*      Thanks to:                                       */
/*        Oleg Kukarthev                                 */
/*                                                       */
/*********************************************************/

/*

  First parameter  -- set of groups of user to be tested
  Second parameter -- set of groups allowed to access

  Returns 0 if access denied,
  !0 otherwise

*/


DECLARE EXTERNAL FUNCTION g_sec_test
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_sec_test'
module_name 'gudf';

/*

  First parameter  -- set of groups of user to be tested
  second, third and fourth parameters are sets of groups
  allowed to full access, change and view respectively

  Returns 0 if access denied,
  !0 otherwise

*/


DECLARE EXTERNAL FUNCTION g_sec_testall
  integer, integer, integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_sec_testall'
module_name 'gudf';


DECLARE EXTERNAL FUNCTION g_b_and
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_and'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_b_or
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_or'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_b_xor
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_xor'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_b_shl
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_shl'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_b_shr
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_shr'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_b_not
  integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_not'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_b_andex
  integer, integer, integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_andex'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_m_random
  integer
RETURNS
  integer BY value
ENTRY_POINT 'g_m_random'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION G_D_GETDATEPARAM
  DATE,
  INTEGER
RETURNS
  INTEGER BY VALUE
ENTRY_POINT 'g_d_getdateparam'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_encodedate
  smallint, smallint, smallint, TIMESTAMP
RETURNS
  TIMESTAMP
ENTRY_POINT 'g_d_encodedate'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_inchours
  integer, TIMESTAMP
RETURNS
  TIMESTAMP
ENTRY_POINT 'g_d_inchours'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_incmonth
  integer, TIMESTAMP
RETURNS
  TIMESTAMP
ENTRY_POINT 'g_d_incmonth'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_getdayofweek
  TIMESTAMP
RETURNS
  integer BY value
ENTRY_POINT 'g_d_getdayofweek'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_date2int
  TIMESTAMP
RETURNS
  integer BY value
ENTRY_POINT 'g_d_date2int'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_workdaysbetween
  TIMESTAMP, TIMESTAMP
RETURNS
  integer BY value
ENTRY_POINT 'g_d_workdaysbetween'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_date2str
  TIMESTAMP
RETURNS
  cstring(32)
ENTRY_POINT 'g_d_date2str'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_date2str_ymd
  TIMESTAMP
RETURNS
  cstring(32)
ENTRY_POINT 'g_d_date2str_ymd'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_formatdatetime
  cstring(64), TIMESTAMP
RETURNS
  cstring(64)
ENTRY_POINT 'g_d_formatdatetime'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_float2str
  double precision
RETURNS
  cstring(32)
ENTRY_POINT 'g_s_float2str'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_monthname
  smallint
RETURNS
  cstring(32)
ENTRY_POINT 'g_d_monthname'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_boolean2str
  smallint
RETURNS
  cstring(4)
ENTRY_POINT 'g_s_boolean2str'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ansicomparetext
  cstring(2000), cstring(2000)
RETURNS
  smallint BY value
ENTRY_POINT 'g_s_ansicomparetext'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_fuzzymatch
  integer, cstring(2000), cstring(2000)
RETURNS
  integer BY value
ENTRY_POINT 'g_s_fuzzymatch'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION G_S_COMPARENAME
    CSTRING (255),
    CSTRING (255)
    RETURNS SMALLINT BY VALUE
    ENTRY_POINT 'g_s_comparename' MODULE_NAME 'gudf';


DECLARE EXTERNAL FUNCTION g_s_ansiuppercase
  cstring(2000)
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_ansiuppercase'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ansilowercase
  cstring(2000)
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_ansilowercase'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ansipos
  cstring(2000), cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_ansipos'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_pos
  cstring(2000), cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_pos'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ansiposreg
  cstring(2000), cstring(2000), SMALLINT
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_ansiposreg'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_copy
  cstring(255), SMALLINT, SMALLINT
RETURNS
  cstring(255)
ENTRY_POINT 'g_s_copy'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_trim
  cstring(2000), cstring(2000)
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_trim'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ternary
  SMALLINT, cstring(2000), cstring(2000)
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_ternary'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_like
  cstring(2000), cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_like'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_length
  cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_length'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_delete
  cstring(2000), SMALLINT, SMALLINT
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_delete'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_d_serverdate
RETURNS
  TIMESTAMP
ENTRY_POINT 'g_d_serverdate'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_ais_getitemscount
  cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_ais_getitemscount'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_ais_getitembyindex
  cstring(2000), SMALLINT
RETURNS
  INTEGER BY value
ENTRY_POINT 'g_ais_getitembyindex'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_ais_inarray
  cstring(2000), INTEGER
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_ais_inarray'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_m_round
  DOUBLE PRECISION
RETURNS
  integer BY value
ENTRY_POINT 'g_m_round'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_m_roundnn
  DOUBLE PRECISION, DOUBLE PRECISION
RETURNS
  DOUBLE PRECISION BY value
ENTRY_POINT 'g_m_roundnn'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_m_complround
  DOUBLE PRECISION, INTEGER, DOUBLE PRECISION, DOUBLE PRECISION
RETURNS
  DOUBLE PRECISION BY value
ENTRY_POINT 'g_m_complround'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_info
  blob, cstring(255)
RETURNS
  PARAMETER 2
ENTRY_POINT 'g_blob_info'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_size
  blob
RETURNS
  integer BY value
ENTRY_POINT 'g_blob_size'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_searchsubstr
  blob, cstring(255)
RETURNS
  integer BY value
ENTRY_POINT 'g_blob_search'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_blobtocstring
  blob, cstring(16384)
RETURNS
  PARAMETER 2
ENTRY_POINT 'g_blob_blobtocstring'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_cstringtoblob
  cstring(16384), blob
RETURNS
  PARAMETER 2
ENTRY_POINT 'g_blob_cstringtoblob'
module_name 'gudf';

DECLARE EXTERNAL FUNCTION g_s_delchar 
  CSTRING(2000) 
RETURNS 
  INTEGER BY VALUE 
ENTRY_POINT 'g_s_delchar' 
MODULE_NAME 'gudf';

COMMIT;

