SET NAMES WIN1251;                        
SET SQL DIALECT 3;                        
CREATE DATABASE 'put_your_database_name'  
USER 'SYSDBA' PASSWORD 'masterkey'         
PAGE_SIZE 8192                            
DEFAULT CHARACTER SET WIN1251;            

/****************************************************/
/****************************************************/
/**                                                **/
/**   Gedemin project                              **/
/**   Copyright (c) 1999-2016 by                   **/
/**   Golden Software of Belarus, Ltd              **/
/**                                                **/
/****************************************************/
/****************************************************/

COMMIT;

CREATE ROLE administrator;

COMMIT;

CREATE GENERATOR gd_g_unique;
SET GENERATOR gd_g_unique TO 147000000;

CREATE GENERATOR gd_g_offset;
SET GENERATOR gd_g_offset TO 0;

CREATE GENERATOR gd_g_dbid;
SET GENERATOR gd_g_dbid TO 0;

/* в новой системе блокировки периода следующие два */
/* генератора не используются                       */
CREATE GENERATOR gd_g_block;
SET GENERATOR gd_g_block TO 0;

CREATE GENERATOR gd_g_block_group;
SET GENERATOR gd_g_block_group TO 0;

/*

  Внимание! Текст этого исключения нельзя менять,
  он используется в программе в gdc_dlgG

*/
CREATE EXCEPTION gd_e_block 'Period zablokirovan!';

CREATE EXCEPTION tree_e_invalid_parent 'Invalid parent specified';

CREATE EXCEPTION gd_e_exception 'General exception!';

COMMIT;

/*********************************************************/
/*                                                       */
/*      InterBase User Defined Fuctions                  */
/*      GUDF library                                     */
/*      Copyright (c) 2000-2012 by Golden Software       */
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
MODULE_NAME 'gudf';

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
MODULE_NAME 'gudf';


DECLARE EXTERNAL FUNCTION g_b_and
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_and'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_b_or
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_or'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_b_xor
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_xor'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_b_shl
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_shl'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_b_shr
  integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_shr'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_b_not
  integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_not'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_b_andex
  integer, integer, integer, integer
RETURNS
  integer BY value
ENTRY_POINT 'g_b_andex'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_m_random
  integer
RETURNS
  integer BY value
ENTRY_POINT 'g_m_random'
MODULE_NAME 'gudf';

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
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_inchours
  integer, TIMESTAMP
RETURNS
  TIMESTAMP
ENTRY_POINT 'g_d_inchours'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_incmonth
  integer, TIMESTAMP
RETURNS
  TIMESTAMP
ENTRY_POINT 'g_d_incmonth'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_getdayofweek
  TIMESTAMP
RETURNS
  integer BY value
ENTRY_POINT 'g_d_getdayofweek'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_date2int
  TIMESTAMP
RETURNS
  integer BY value
ENTRY_POINT 'g_d_date2int'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_workdaysbetween
  TIMESTAMP, TIMESTAMP
RETURNS
  integer BY value
ENTRY_POINT 'g_d_workdaysbetween'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_date2str
  TIMESTAMP
RETURNS
  cstring(32)
ENTRY_POINT 'g_d_date2str'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_date2str_ymd
  TIMESTAMP
RETURNS
  cstring(32)
ENTRY_POINT 'g_d_date2str_ymd'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_formatdatetime
  cstring(64), TIMESTAMP
RETURNS
  cstring(64)
ENTRY_POINT 'g_d_formatdatetime'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_float2str
  double precision
RETURNS
  cstring(32)
ENTRY_POINT 'g_s_float2str'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_monthname
  smallint
RETURNS
  cstring(32)
ENTRY_POINT 'g_d_monthname'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_boolean2str
  smallint
RETURNS
  cstring(4)
ENTRY_POINT 'g_s_boolean2str'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ansicomparetext
  cstring(2000), cstring(2000)
RETURNS
  smallint BY value
ENTRY_POINT 'g_s_ansicomparetext'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_fuzzymatch
  integer, cstring(2000), cstring(2000)
RETURNS
  integer BY value
ENTRY_POINT 'g_s_fuzzymatch'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION G_S_COMPARENAME
    CSTRING (255),
    CSTRING (255)
RETURNS
  SMALLINT BY VALUE
ENTRY_POINT 'g_s_comparename'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ansiuppercase
  cstring(2000)
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_ansiuppercase'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ansilowercase
  cstring(2000)
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_ansilowercase'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ansipos
  cstring(2000), cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_ansipos'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_pos
  cstring(2000), cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_pos'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ansiposreg
  cstring(2000), cstring(2000), SMALLINT
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_ansiposreg'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_copy
  cstring(255), SMALLINT, SMALLINT
RETURNS
  cstring(255)
ENTRY_POINT 'g_s_copy'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_trim
  cstring(2000), cstring(2000)
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_trim'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_ternary
  SMALLINT, cstring(2000), cstring(2000)
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_ternary'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_like
  cstring(2000), cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_like'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_length
  cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_s_length'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_delete
  cstring(2000), SMALLINT, SMALLINT
RETURNS
  cstring(2000)
ENTRY_POINT 'g_s_delete'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_d_serverdate
RETURNS
  TIMESTAMP
ENTRY_POINT 'g_d_serverdate'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_ais_getitemscount
  cstring(2000)
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_ais_getitemscount'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_ais_getitembyindex
  cstring(2000), SMALLINT
RETURNS
  INTEGER BY value
ENTRY_POINT 'g_ais_getitembyindex'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_ais_inarray
  cstring(2000), INTEGER
RETURNS
  SMALLINT BY value
ENTRY_POINT 'g_ais_inarray'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_m_round
  DOUBLE PRECISION
RETURNS
  integer BY value
ENTRY_POINT 'g_m_round'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_m_roundnn
  DOUBLE PRECISION, DOUBLE PRECISION
RETURNS
  DOUBLE PRECISION BY value
ENTRY_POINT 'g_m_roundnn'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_m_complround
  DOUBLE PRECISION, INTEGER, DOUBLE PRECISION, DOUBLE PRECISION
RETURNS
  DOUBLE PRECISION BY value
ENTRY_POINT 'g_m_complround'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_info
  blob, cstring(255)
RETURNS
  PARAMETER 2
ENTRY_POINT 'g_blob_info'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_size
  blob
RETURNS
  integer BY value
ENTRY_POINT 'g_blob_size'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_searchsubstr
  blob, cstring(255)
RETURNS
  integer BY value
ENTRY_POINT 'g_blob_search'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_blobtocstring
  blob, cstring(16384)
RETURNS
  PARAMETER 2
ENTRY_POINT 'g_blob_blobtocstring'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_blob_cstringtoblob
  cstring(16384), blob
RETURNS
  PARAMETER 2
ENTRY_POINT 'g_blob_cstringtoblob'
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION g_s_delchar 
  CSTRING(2000) 
RETURNS 
  INTEGER BY VALUE 
ENTRY_POINT 'g_s_delchar' 
MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION G_HIS_CREATE
  INTEGER,
  INTEGER
RETURNS INTEGER BY VALUE
ENTRY_POINT 'g_his_create' MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION G_HIS_INCLUDE
 INTEGER,
 INTEGER
RETURNS INTEGER BY VALUE
ENTRY_POINT 'g_his_include' MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION G_HIS_HAS
 INTEGER,
 INTEGER
RETURNS INTEGER BY VALUE
ENTRY_POINT 'g_his_has' MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION G_HIS_COUNT
 INTEGER
RETURNS INTEGER BY VALUE
ENTRY_POINT 'g_his_count' MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION G_HIS_EXCLUDE
  INTEGER,
  INTEGER
RETURNS INTEGER BY VALUE
ENTRY_POINT 'g_his_exclude' MODULE_NAME 'gudf';

DECLARE EXTERNAL FUNCTION G_HIS_DESTROY
  INTEGER
RETURNS INTEGER BY VALUE
ENTRY_POINT 'g_his_destroy' MODULE_NAME 'gudf';

COMMIT;


/* домен для первичных ключей */
CREATE DOMAIN dintkey
  AS INTEGER NOT NULL
  CHECK (VALUE > 0);

/* домен для первичных ключей */
CREATE DOMAIN ddbkey
  AS INTEGER NOT NULL;

/* будем использовать этот домен для всех полей ссылок */
CREATE DOMAIN dforeignkey
  AS INTEGER;

/* */  
CREATE DOMAIN dmasterkey
  AS INTEGER NOT NULL;

CREATE DOMAIN dlb
  AS INTEGER DEFAULT 1 NOT NULL;

CREATE DOMAIN drb
  AS INTEGER DEFAULT 2 NOT NULL;

CREATE DOMAIN dparent
  AS INTEGER;

CREATE DOMAIN dinteger
  AS INTEGER;

CREATE DOMAIN dinteger_notnull
  AS INTEGER NOT NULL;

CREATE DOMAIN ddouble
  AS DOUBLE PRECISION;

/****************************************************/
/**   Строковые                                    **/
/****************************************************/

CREATE DOMAIN dalias
  AS VARCHAR(8) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL;

CREATE DOMAIN dISO
  AS VARCHAR(3) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtemplatetype
  AS VARCHAR(3) CHARACTER SET WIN1251 DEFAULT '' NOT NULL COLLATE PXW_CYRL;

CREATE DOMAIN dnullalias
  AS VARCHAR(16) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtablename
  AS VARCHAR(31)
  CHECK ((VALUE IS NULL) OR (VALUE > ''));

CREATE DOMAIN dfieldname
  AS VARCHAR(31)
  CHECK ((VALUE IS NULL) OR (VALUE > ''));

CREATE DOMAIN dname
  AS VARCHAR(60) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL;

CREATE DOMAIN dlongname 
  AS VARCHAR(80) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL;

CREATE DOMAIN dbarcode
  AS VARCHAR(24) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dqueue
  AS VARCHAR(2) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext8
  AS VARCHAR(8) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext10
  AS VARCHAR(10) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext20
  AS VARCHAR(20) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext40
  AS VARCHAR(40) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dbankaccount
  AS VARCHAR(40) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dbankcode
  AS VARCHAR(20) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext60
  AS VARCHAR(60) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext80
  AS VARCHAR(80) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext120
  AS VARCHAR(120) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext180
  AS VARCHAR(180) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext254
  AS VARCHAR(254) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext255
  AS VARCHAR(255) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext1024
  AS VARCHAR(1024) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dclassname
  AS VARCHAR(40) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dusername
  AS VARCHAR(20) CHARACTER SET WIN1251 NOT NULL 
  CHECK (VALUE > '')
  COLLATE PXW_CYRL;

CREATE DOMAIN dusergroupname
  AS VARCHAR(20) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL;

CREATE DOMAIN dpassword
  AS VARCHAR(20) CHARACTER SET WIN1251 NOT NULL 
  CHECK (VALUE > '')
  COLLATE PXW_CYRL;

CREATE DOMAIN dsubsystemname
  AS VARCHAR(20) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL;

CREATE DOMAIN ddecdigits
  AS SMALLINT
  CHECK ((VALUE IS NULL) OR (VALUE BETWEEN 0 AND 16));

CREATE DOMAIN dlanguage
  AS VARCHAR(1);

CREATE DOMAIN daccount
  AS VARCHAR(6) CHARACTER SET WIN1251
  COLLATE PXW_CYRL;

CREATE DOMAIN dtext32
  AS VARCHAR(32) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN druid
  AS VARCHAR(21)
  NOT NULL;

CREATE DOMAIN dtax
  AS DECIMAL(7, 4)
  CHECK ((VALUE IS NULL) OR (VALUE BETWEEN 0 AND 99));

CREATE DOMAIN dpercent
  AS DECIMAL(7, 4);

CREATE DOMAIN dpositive
  AS DECIMAL(15, 8)
  CHECK ((VALUE IS NULL) OR (VALUE >= 0));

CREATE DOMAIN dcurrency
  AS DECIMAL(15, 4);

CREATE DOMAIN dquantity
  AS DECIMAL(15, 4);

CREATE DOMAIN dgoldquantity
  AS NUMERIC(15, 8);

CREATE DOMAIN dfactor
  AS DOUBLE PRECISION;  

CREATE DOMAIN dboolean
  AS SMALLINT
  DEFAULT 0
  CHECK ((VALUE IS NULL) OR (VALUE IN (0, 1)));

CREATE DOMAIN dboolean_notnull
  AS SMALLINT
  DEFAULT 0
  NOT NULL
  CHECK (VALUE IN (0, 1));

CREATE DOMAIN ddisabled
  AS SMALLINT DEFAULT 0
  CHECK ((VALUE IS NULL) OR (VALUE IN (0, 1)));

CREATE DOMAIN dreserved
  AS INTEGER;

CREATE DOMAIN dentryid
  AS VARCHAR(32) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dpersonalid
  AS VARCHAR(16) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dfilename
  AS VARCHAR(255) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

/* почтовый индекс */
CREATE DOMAIN dzipcode
  AS VARCHAR(12);

/* почтовый индекс */
CREATE DOMAIN dpobox
  AS VARCHAR(8);

/* горячая клавиша */
CREATE DOMAIN dhotkey
  AS INTEGER;

/* тэлефонны нумар */
CREATE DOMAIN dtel
  AS VARCHAR(40) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

/* number of pager */
CREATE DOMAIN dpager
  AS VARCHAR(40) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

/* адрас электроннай пошты */
CREATE DOMAIN demail
  AS VARCHAR(40);

/* УРЛ */
CREATE DOMAIN durl
  AS VARCHAR(40);

/* выкарыстоўваецца для захоўвання полу */
/* М -- мужчынск_, F -- жаночы          */
CREATE DOMAIN dgender
  AS VARCHAR(1)
  CHECK ((VALUE IS NULL) OR (VALUE = 'M') OR (VALUE = 'F') OR (VALUE = 'N'));

/* часовой пояс относительно Гринвича */
CREATE DOMAIN dgmtoffset
  AS SMALLINT
  CHECK ((VALUE IS NULL) OR (VALUE >= -12) OR (VALUE <= 12));

CREATE DOMAIN dBMP
  AS BLOB SUB_TYPE 0 SEGMENT SIZE 1024;

CREATE DOMAIN dRTF
  AS BLOB SUB_TYPE 0 SEGMENT SIZE 1024;

CREATE DOMAIN dsecurity
  AS INTEGER DEFAULT -1
  NOT NULL;

CREATE DOMAIN dtextalignment
  AS VARCHAR(1)
  DEFAULT 'L'
  CHECK((VALUE IS NULL) OR (VALUE IN ('L', 'R', 'C', 'J')));  

CREATE DOMAIN daccounttype 
  AS VARCHAR(1)
  CHECK((VALUE IS NULL) OR (VALUE IN ('D', 'K')));

CREATE DOMAIN dpricetype
  AS VARCHAR(1)
  CHECK (VALUE IN ('P', 'C'));

CREATE DOMAIN dcontacttype
  AS VARCHAR(1)
  CHECK (VALUE IN ('D', 'K'));

CREATE DOMAIN dreplicationtype
  AS VARCHAR(1)
  CHECK (VALUE IN ('I', 'U', 'D'));

CREATE DOMAIN dreplidset
  AS VARCHAR(255) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtypetransport
  AS VARCHAR(1)
  CHECK ((VALUE IS NULL) OR (VALUE IN ('C', 'S', 'R', 'O', 'W')));

CREATE DOMAIN ddate
  AS DATE;

CREATE DOMAIN ddate_notnull
  AS DATE NOT NULL;

CREATE DOMAIN dtime
  AS TIME;

CREATE DOMAIN dtime_notnull
  AS TIME NOT NULL;

CREATE DOMAIN dtimestamp
  AS TIMESTAMP;

CREATE DOMAIN dtimestamp_notnull
  AS TIMESTAMP NOT NULL;

CREATE DOMAIN dsmallint
  AS SMALLINT;

CREATE DOMAIN dversionstring
  AS VARCHAR(20) NOT NULL;

CREATE DOMAIN dfilterdata
  AS BLOB SUB_TYPE 0 SEGMENT SIZE 512;

CREATE DOMAIN dblob4096
  AS BLOB SEGMENT SIZE 4096;

CREATE DOMAIN dblobtext80
  AS BLOB SUB_TYPE 1 SEGMENT SIZE 80;

CREATE DOMAIN dblobtext80_1251
  AS BLOB SUB_TYPE 1 SEGMENT SIZE 80 CHARACTER SET win1251;

CREATE DOMAIN dblob80
  AS BLOB SEGMENT SIZE 80;

CREATE DOMAIN dblob
  AS BLOB;

CREATE DOMAIN dscript
  AS BLOB SUB_TYPE 1 SEGMENT SIZE 1024;

CREATE DOMAIN dreporttemplate
  AS BLOB SEGMENT SIZE 1024;

CREATE DOMAIN djournalblob
  AS BLOB SUB_TYPE 1 SEGMENT SIZE 1024;

CREATE DOMAIN dlisttrtypeconddata
  AS BLOB SUB_TYPE 0 SEGMENT SIZE 512;

CREATE DOMAIN dnumerationblob
  AS BLOB SUB_TYPE 0 SEGMENT SIZE 256;

CREATE DOMAIN dmsgtype
  AS VARCHAR(1) NOT NULL;

CREATE DOMAIN daccountingdiscipline
  AS VARCHAR(1)
  CHECK ((VALUE IS NULL) OR (VALUE IN ('F', 'L', 'A')));

CREATE DOMAIN deditiondate AS
  TIMESTAMP DEFAULT CURRENT_TIMESTAMP(0);

CREATE DOMAIN dcreationdate AS
  TIMESTAMP DEFAULT CURRENT_TIMESTAMP(0);

CREATE DOMAIN ddocumentdate AS
  DATE NOT NULL
  CHECK (VALUE BETWEEN '01.01.1900' AND '31.12.2099');

CREATE DOMAIN ddocumentnumber AS
  VARCHAR(20) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL;

CREATE DOMAIN dblob1024 AS 
  BLOB SUB_TYPE 0 SEGMENT SIZE 1024;

CREATE DOMAIN dsubtype AS 
  VARCHAR(31) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dgdcname AS 
  VARCHAR(64) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN daccountalias
  AS VARCHAR(40) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL;

CREATE DOMAIN dfixlength 
  AS INTEGER CHECK ((VALUE IS NULL) OR (VALUE > 0 AND VALUE <= 20));

COMMIT;

CREATE TABLE fin_versioninfo
(
  id            dintkey,
  versionstring dversionstring,
  releasedate   ddate NOT NULL,
  comment       dtext254
);

ALTER TABLE fin_versioninfo ADD CONSTRAINT fin_pk_versioninfo_id
  PRIMARY KEY (id);

COMMIT;

GRANT SELECT ON fin_versioninfo TO startuser;

COMMIT;

SET TERM ^ ;

CREATE PROCEDURE fin_p_ver_getdbversion
  RETURNS (ID INTEGER, VersionString VARCHAR(20),
    ReleaseDate DATE, Comment VARCHAR(255) CHARACTER SET WIN1251)
AS
BEGIN
  SELECT id, versionstring, releasedate, comment
  FROM fin_versioninfo
  WHERE id = (SELECT MAX(id) FROM fin_versioninfo)
  INTO :ID, :VersionString, :ReleaseDate, :Comment;
END
^

SET TERM ; ^

COMMIT;

GRANT EXECUTE ON PROCEDURE fin_p_ver_getdbversion TO startuser;

COMMIT;

INSERT INTO fin_versioninfo
  VALUES (1, '0000.0000.0001.0000', '01.02.1999', 'Начало...');

INSERT INTO fin_versioninfo
  VALUES (2, '0000.0000.0001.0001', '07.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (3, '0000.0000.0001.0002', '08.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (4, '0000.0000.0001.0003', '11.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (5, '0000.0000.0001.0004', '18.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (6, '0000.0000.0001.0005', '27.02.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (7, '0000.0000.0001.0006', '03.03.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (8, '0000.0000.0001.0007', '22.04.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (9, '0000.0000.0001.0008', '23.07.1999', NULL);

INSERT INTO fin_versioninfo
  VALUES (10, '0000.0000.0001.0009', '30.07.1999', 'Phone tables added');

INSERT INTO fin_versioninfo
  VALUES (11, '0000.0000.0001.0010', '03.08.1999', 'Icon tables added');

INSERT INTO fin_versioninfo
  VALUES (12, '0000.0001.0000.0001', '19.06.2000', 'Gedemin started');

INSERT INTO fin_versioninfo
  VALUES (13, '0000.0001.0000.0002', '24.06.2000', 'Andreik added ON DELETE clause to FOREIGN KEY defenitions');

INSERT INTO fin_versioninfo
  VALUES (14, '0000.0001.0000.0003', '27.06.2000', '...');

INSERT INTO fin_versioninfo
  VALUES (15, '0000.0001.0000.0004', '10.07.2000', 'Audit levels added by Andreik');

INSERT INTO fin_versioninfo
  VALUES (16, '0000.0001.0000.0005', '03.08.2000', 'Першы кандыдат да выпуску адраснай кнiгi');

INSERT INTO fin_versioninfo
  VALUES (17, '0000.0001.0000.0006', '08.08.2000', 'Другi кандыдат да выпуску адраснай кнiгi');

INSERT INTO fin_versioninfo
  VALUES (18, '0000.0001.0000.0007', '09.08.2000', 'Views added');

INSERT INTO fin_versioninfo
  VALUES (19, '0000.0001.0000.0008', '15.08.2000', 'Functions (macros) added');

INSERT INTO fin_versioninfo
  VALUES (20, '0000.0001.0000.0009', '17.08.2000', 'Payment order added');

INSERT INTO fin_versioninfo
  VALUES (21, '0000.0001.0000.0010', '18.08.2000', 'New version');

INSERT INTO fin_versioninfo
  VALUES (22, '0000.0001.0000.0011', '20.08.2000', 'Generators names changed');

INSERT INTO fin_versioninfo
  VALUES (23, '0000.0001.0000.0012', '27.08.2000', 'Next release');

INSERT INTO fin_versioninfo
  VALUES (24, '0000.0001.0000.0014', '28.08.2000', 'Order by added in gd_p_getfolderelement');

INSERT INTO fin_versioninfo
  VALUES (25, '0000.0001.0000.0015', '31.08.2000', 'Some bug base fields added');

INSERT INTO fin_versioninfo
  VALUES (26, '0000.0001.0000.0016', '08.09.2000', 'Interval trees implemented');

INSERT INTO fin_versioninfo
  VALUES (27, '0000.0001.0000.0017', '14.09.2000', 'Desktops implemented');

INSERT INTO fin_versioninfo
  VALUES (28, '0000.0001.0000.0018', '18.09.2000', 'Goods added');

INSERT INTO fin_versioninfo
  VALUES (29, '0000.0001.0000.0019', '28.09.2000', '...');

INSERT INTO fin_versioninfo
  VALUES (30, '0000.0001.0000.0020', '22.10.2000', 'Filters added');

INSERT INTO fin_versioninfo
  VALUES (31, '0000.0001.0000.0021', '26.10.2000', 'First launch of new phone!!!');

INSERT INTO fin_versioninfo
  VALUES (32, '0000.0001.0000.0022', '14.11.2000', 'Berioza 2');

INSERT INTO fin_versioninfo
  VALUES (33, '0000.0001.0000.0023', '30.11.2000', 'Berioza 3');

INSERT INTO fin_versioninfo
  VALUES (34, '0000.0001.0000.0024', '04.12.2000', 'Bank statements to Berioza');

INSERT INTO fin_versioninfo
  VALUES (35, '0000.0001.0000.0025', '27.12.2000', 'Big clean up!');

INSERT INTO fin_versioninfo
  VALUES (36, '0000.0001.0000.0026', '12.02.2001', 'My birthday :)');

INSERT INTO fin_versioninfo
  VALUES (37, '0000.0001.0000.0027', '11.03.2001', 'Bankstatement fields added. Upgrade is mandatory.');

INSERT INTO fin_versioninfo
  VALUES (38, '0000.0001.0000.0028', '24.04.2001', 'Cattle tables added.');

INSERT INTO fin_versioninfo
  VALUES (39, '0000.0001.0000.0029', '10.11.2001', 'New operations');

INSERT INTO fin_versioninfo
  VALUES (40, '0000.0001.0000.0030', '12.02.2002', 'My birthday again :(');

INSERT INTO fin_versioninfo
  VALUES (41, '0000.0001.0000.0031', '08.07.2002', 'Triggers for system tables added');

INSERT INTO fin_versioninfo
  VALUES (42, '0000.0001.0000.0032', '08.11.2002', 'GD_JOURNAL has got its final state');

INSERT INTO fin_versioninfo
  VALUES (43, '0000.0001.0000.0033', '13.01.2003', 'ST_SETTINGSTATE for installer was added');

INSERT INTO fin_versioninfo
  VALUES (44, '0000.0001.0000.0034', '04.02.2003', 'Support financial report (add tables gd_tax..)');

INSERT INTO fin_versioninfo
  VALUES (45, '0000.0001.0000.0035', '23.04.2003', 'WG_POSITION added');

INSERT INTO fin_versioninfo
  VALUES (46, '0000.0001.0000.0036', '08.06.2003', 'employee becomes a children to department');

INSERT INTO fin_versioninfo
  VALUES (47, '0000.0001.0000.0045', '18.08.2003', 'Changed domain DGOLDQUANTITY');

INSERT INTO fin_versioninfo
  VALUES (48, '0000.0001.0000.0046', '22.08.2003', 'Changed trigger INV_AU_MOVEMENT ');

INSERT INTO fin_versioninfo
  VALUES (49, '0000.0001.0000.0047', '03.09.2003', 'Added fields into AT_SETTING');

INSERT INTO fin_versioninfo
  VALUES (50, '0000.0001.0000.0048', '20.09.2003', 'Computed indice added');

INSERT INTO fin_versioninfo
  VALUES (51, '0000.0001.0000.0049', '22.09.2003', 'Additional fields into gd_company added');

INSERT INTO fin_versioninfo
  VALUES (52, '0000.0001.0000.0052', '10.10.2003', 'Block');

INSERT INTO fin_versioninfo
  VALUES (53, '0000.0001.0000.0061', '09.12.2003', 'Additional fields into inv_balanceoption added');

INSERT INTO fin_versioninfo
  VALUES (54, '0000.0001.0000.0062', '19.12.2003', 'DataType field into gd_const added');

INSERT INTO fin_versioninfo
  VALUES (55, '0000.0001.0000.0063', '07.01.2004', 'Some triggers removed');

INSERT INTO fin_versioninfo
  VALUES (56, '0000.0001.0000.0064', '12.01.2004', 'Column RATE was added in BN_BANKSTATEMENT');

INSERT INTO fin_versioninfo
  VALUES (57, '0000.0001.0000.0066', '12.01.2004', 'Column ACCOUNTKEY was added in BN_BANKSTATEMENTLINE');

INSERT INTO fin_versioninfo
  VALUES (58, '0000.0001.0000.0068', '18.01.2004', 'Column FIXLENGTH was added in GD_LASTNUMBER');

INSERT INTO fin_versioninfo
  VALUES (59, '0000.0001.0000.0085', '17.06.2004', 'New general ledger');

INSERT INTO fin_versioninfo
  VALUES (60, '0000.0001.0000.0086', '28.06.2004', 'FIX gd_taxtype');

INSERT INTO fin_versioninfo
  VALUES (61, '0000.0001.0000.0087', '28.07.2004', 'Add EQ');

INSERT INTO fin_versioninfo
  VALUES (62, '0000.0001.0000.0090', '08.12.2004', 'Fix inv_price');

INSERT INTO fin_versioninfo
  VALUES (63, '0000.0001.0000.0091', '10.02.2005', 'Modify block triggers');

INSERT INTO fin_versioninfo
  VALUES (64, '0000.0001.0000.0092', '01.03.2005', 'Sync triggers procedures changed');

INSERT INTO fin_versioninfo
  VALUES (65, '0000.0001.0000.0093', '22.03.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (66, '0000.0001.0000.0094', '22.03.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (67, '0000.0001.0000.0095', '22.03.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (68, '0000.0001.0000.0096', '12.04.2005', 'Fixed some errors');

INSERT INTO fin_versioninfo
  VALUES (69, '0000.0001.0000.0097', '10.10.2005', 'Minor changes');

INSERT INTO fin_versioninfo
  VALUES (70, '0000.0001.0000.0098', '10.01.2006', 'Minor changes');

INSERT INTO fin_versioninfo
  VALUES (71, '0000.0001.0000.0099', '15.03.2006', 'Tables for SQL monitor added');

INSERT INTO fin_versioninfo
  VALUES (72, '0000.0001.0000.0100', '17.03.2006', 'Type of description field of goodgroup has been changed');

INSERT INTO fin_versioninfo
  VALUES (73, '0000.0001.0000.0101', '17.04.2006', 'Bankbranch field added');

INSERT INTO fin_versioninfo
  VALUES (74, '0000.0001.0000.0102', '04.05.2006', 'Bankbranch field added to bankstatement');

INSERT INTO fin_versioninfo
  VALUES (75, '0000.0001.0000.0103', '30.05.2006', 'Employee branch added into Explorer');

INSERT INTO fin_versioninfo
  VALUES (76, '0000.0001.0000.0104', '18.09.2006', 'Ability to exclude some document types from block period added');

INSERT INTO fin_versioninfo
  VALUES (77, '0000.0001.0000.0105', '31.07.2006', 'Add fields from AC_RECORD into AC_ENTRY');

INSERT INTO fin_versioninfo
  VALUES (78, '0000.0001.0000.0106', '15.09.2006', 'Change StoredProc AC_CIRCULATIONLIST');

INSERT INTO fin_versioninfo
  VALUES (79, '0000.0001.0000.0107', '27.10.2006', 'Исправлена процедура AC_ACCOUNTEXSALDO');

INSERT INTO fin_versioninfo
  VALUES (80, '0000.0001.0000.0108', '09.11.2006', 'Возвращены изменения триггеров - параметр ROWCOUNT - возрващал неверное значение');

INSERT INTO fin_versioninfo
  VALUES (81, '0000.0001.0000.0109', '12.11.2006', 'Добавлена процедура INV_GETCARDMOVEMENT для ускорения вывода остатков на дату');

INSERT INTO fin_versioninfo
  VALUES (82, '0000.0001.0000.0110', '24.11.2006', 'Пересчитываем складские остатки после восстановления складских триггеров');

INSERT INTO fin_versioninfo
  VALUES (84, '0000.0001.0000.0112', '03.01.2007', 'Fixed triggers for FireBird 2.0');

INSERT INTO fin_versioninfo
  VALUES (85, '0000.0001.0000.0113', '20.01.2007', 'Stripped security descriptors from rp_reportgroup');

INSERT INTO fin_versioninfo
  VALUES (86, '0000.0001.0000.0114', '22.01.2007', 'surname field of gd_people became not null');

INSERT INTO fin_versioninfo
  VALUES (87, '0000.0001.0000.0115', '24.01.2007', 'Fixed block and GD_AU_DOCUMENT triggers');

INSERT INTO fin_versioninfo
  VALUES (88, '0000.0001.0000.0116', '28.01.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (89, '0000.0001.0000.0117', '31.01.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (90, '0000.0001.0000.0118', '04.02.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (91, '0000.0001.0000.0119', '26.02.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (92, '0000.0001.0000.0120', '22.04.2007', 'GD_P_GETRUID changed');

INSERT INTO fin_versioninfo
  VALUES (93, '0000.0001.0000.0121', '02.05.2007', 'RUID changed');

INSERT INTO fin_versioninfo
  VALUES (94, '0000.0001.0000.0122', '07.05.2007', 'Some internal changes');

INSERT INTO fin_versioninfo
  VALUES (95, '0000.0001.0000.0123', '30.06.2007', 'Add generators');

INSERT INTO fin_versioninfo
  VALUES (96, '0000.0001.0000.0124', '3.08.2007', 'Add barcode indices');

INSERT INTO fin_versioninfo
  VALUES (97, '0000.0001.0000.0125', '4.10.2007', 'Add check constraints');

INSERT INTO fin_versioninfo
  VALUES (98, '0000.0001.0000.0126', '22.10.2007', 'GD_AU_DOCUMENT');

INSERT INTO fin_versioninfo
  VALUES (100, '0000.0001.0000.0127', '16.01.2008', 'inv_balanceoption');

INSERT INTO fin_versioninfo
  VALUES (101, '0000.0001.0000.0128', '10.06.2008', 'FastReport4');

/*
INSERT INTO fin_versioninfo
  VALUES (102, '0000.0001.0000.0134', '09.07.2008', 'Добавлены RPL таблицы');

INSERT INTO fin_versioninfo
  VALUES (103, '0000.0001.0000.0135', '15.10.2008', 'Добавлен расчет сальдо по проводкам');

INSERT INTO fin_versioninfo
  VALUES (104, '0000.0001.0000.0136', '19.12.2008', 'Добавлено поле OKULP в таблицу GD_COMPANYCODE');

INSERT INTO fin_versioninfo
  VALUES (105, '0000.0001.0000.0137', '12.01.2009', 'Добавлено поле ISINTERNAL в таблицу AC_TRANSACTION для определения внутренних проводок');

INSERT INTO fin_versioninfo
  VALUES (106, '0000.0001.0000.0138', '25.04.2009', 'Проставлены пропущенные гранты');
*/

INSERT INTO fin_versioninfo
  VALUES (107, '0000.0001.0000.0139', '07.09.2009', 'GD_SQL_HISTORY table added and other changes');

INSERT INTO fin_versioninfo
  VALUES (108, '0000.0001.0000.0140', '09.07.2008', 'Добавлены RPL таблицы');

INSERT INTO fin_versioninfo
  VALUES (109, '0000.0001.0000.0141', '15.10.2008', 'Добавлен расчет сальдо по проводкам');

INSERT INTO fin_versioninfo
  VALUES (110, '0000.0001.0000.0142', '19.12.2008', 'Добавлено поле OKULP в таблицу GD_COMPANYCODE');

INSERT INTO fin_versioninfo
  VALUES (111, '0000.0001.0000.0143', '12.01.2009', 'Добавлено поле ISINTERNAL в таблицу AC_TRANSACTION для определения внутренних проводок');

INSERT INTO fin_versioninfo
  VALUES (112, '0000.0001.0000.0144', '25.04.2009', 'Проставлены пропущенные гранты');


INSERT INTO fin_versioninfo
  VALUES (114, '0000.0001.0000.0145', '25.09.2009', 'Storage being converted into new data structures');
  
INSERT INTO fin_versioninfo
  VALUES (115, '0000.0001.0000.0146', '08.03.2010', 'Editorkey and editiondate fields were added to storage table');

INSERT INTO fin_versioninfo
  VALUES (116, '0000.0001.0000.0147', '26.04.2010', 'Storage tree is not a lb-rb tree any more');
  
INSERT INTO fin_versioninfo 
  VALUES (117, '0000.0001.0000.0148', '27.04.2010', 'Добавлен индекс на ac_entry_balance.accountkey');

INSERT INTO fin_versioninfo 
  VALUES (118, '0000.0001.0000.0149', '22.05.2010', 'Make all LB indices non unique');

INSERT INTO fin_versioninfo 
  VALUES (119, '0000.0001.0000.0150', '06.06.2010', 'Add FK manager metadata');

INSERT INTO fin_versioninfo
  VALUES (120, '0000.0001.0000.0151', '22.06.2010', 'Added locking into LBRB tree');

INSERT INTO fin_versioninfo
  VALUES (121, '0000.0001.0000.0152', '26.07.2010', 'Added DEFAULT 0 to boolean domains');

INSERT INTO fin_versioninfo
  VALUES (122, '0000.0001.0000.0153', '12.08.2010', 'IsCheckNumber now allows 4 possible values');

INSERT INTO fin_versioninfo
  VALUES (123, '0000.0001.0000.0154', '23.08.2010', 'Correct rp_x_reportgroup_lrn index');

INSERT INTO fin_versioninfo
  VALUES (124, '0000.0001.0000.0155', '23.08.2010', 'Correct rp_x_reportgroup_lrn index #2');

INSERT INTO fin_versioninfo
  VALUES (125, '0000.0001.0000.0156', '30.09.2010', 'Strategy for LB-RB tree widening has been changed');

INSERT INTO fin_versioninfo
  VALUES (126, '0000.0001.0000.0157', '05.11.2010', 'Relation field BN_BANKSTATEMENTLINE.COMMENT has been extended');

INSERT INTO fin_versioninfo
  VALUES (127, '0000.0001.0000.0158', '08.11.2010', 'Replacing references to xdeStart, xdeFinish components across macros');

INSERT INTO fin_versioninfo
  VALUES (128, '0000.0001.0000.0159', '16.11.2010', 'Replacing references to xdeStart, xdeFinish components across macros #2');

INSERT INTO fin_versioninfo
  VALUES (129, '0000.0001.0000.0160', '17.11.2010', 'Fixed field constraint_uq_count in GD_REF_CONSTRAINTS');

INSERT INTO fin_versioninfo
  VALUES (130, '0000.0001.0000.0161', '19.11.2010', 'Change gd_user_storage trigger');

INSERT INTO fin_versioninfo
  VALUES (131, '0000.0001.0000.0162', '24.03.2011', 'Check to GD_RUID table added.');

INSERT INTO fin_versioninfo
  VALUES (132, '0000.0001.0000.0163', '28.03.2011', 'Modify GD_P_GETRUID procedure.');

INSERT INTO fin_versioninfo
  VALUES (133, '0000.0001.0000.0164', '02.04.2011', 'Check for GD_RUID table modified.');

INSERT INTO fin_versioninfo
  VALUES (134, '0000.0001.0000.0165', '10.05.2011', 'Delete lbrb tree elements from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (135, '0000.0001.0000.0166', '11.05.2011', 'Refined triggers for AC_ENTRY, AC_RECORD.');

INSERT INTO fin_versioninfo
  VALUES (136, '0000.0001.0000.0167', '12.01.2012', 'Add field modalpreview to the table rp_reportlist.');

INSERT INTO fin_versioninfo
  VALUES (137, '0000.0001.0000.0168', '17.01.2012', 'ALTER DOMAIN USR$FA_CORRECTCOEFF.');

INSERT INTO fin_versioninfo
  VALUES (138, '0000.0001.0000.0169', '07.03.2012', 'Add runonlogin field to evt_macroslist table.');

INSERT INTO fin_versioninfo
  VALUES (139, '0000.0001.0000.0170', '09.03.2012', 'Add runonlogin field to evt_macroslist table. Part #2.');

INSERT INTO fin_versioninfo
  VALUES (140, '0000.0001.0000.0171', '14.03.2012', 'Trigger AC_AIU_ACCOUNT_CHECKALIAS added.');

INSERT INTO fin_versioninfo
  VALUES (141, '0000.0001.0000.0172', '14.03.2012', 'Trigger AC_AIU_ACCOUNT_CHECKALIAS added. Part #2.');

INSERT INTO fin_versioninfo
  VALUES (142, '0000.0001.0000.0173', '04.04.2012', 'Trigger GD_AU_DOCUMENTTYPE_MOVEMENT added.');

INSERT INTO fin_versioninfo
  VALUES (143, '0000.0001.0000.0174', '04.04.2012', 'Some minor changes.');

INSERT INTO fin_versioninfo
  VALUES (144, '0000.0001.0000.0175', '04.04.2012', 'Protect system good groups.');

INSERT INTO fin_versioninfo
  VALUES (145, '0000.0001.0000.0176', '05.04.2012', 'Issue 2764.');

INSERT INTO fin_versioninfo
  VALUES (146, '0000.0001.0000.0177', '11.04.2012', 'Delete system triggers of prime tables from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (147, '0000.0001.0000.0178', '16.04.2012', 'Delete system metadada of simple tables from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (148, '0000.0001.0000.0179', '16.04.2012', 'Delete system triggers of prime tables from at_settingpos. #2');

INSERT INTO fin_versioninfo
  VALUES (149, '0000.0001.0000.0180', '16.04.2012', 'Delete system metadada of simple tables from at_settingpos. #2');

INSERT INTO fin_versioninfo
  VALUES (150, '0000.0001.0000.0181', '16.04.2012', 'Delete system triggers of tabletotable tables from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (151, '0000.0001.0000.0182', '16.04.2012', 'Delete system metadada of tree tables from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (152, '0000.0001.0000.0183', '20.04.2012', 'Contractorkey field added to the bn_statementline table.');

INSERT INTO fin_versioninfo
  VALUES (153, '0000.0001.0000.0184', '25.04.2012', 'Delete BI5, BU5 triggers.');

INSERT INTO fin_versioninfo
  VALUES (154, '0000.0001.0000.0185', '23.05.2012', 'Delete system metadada of set type from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (155, '0000.0001.0000.0186', '23.05.2012', 'Delete system domains from at_settingpos.');

INSERT INTO fin_versioninfo
  VALUES (156, '0000.0001.0000.0187', '31.05.2012', 'Correct gd_ai_goodgroup_protect trigger.');

INSERT INTO fin_versioninfo
  VALUES (157, '0000.0001.0000.0188', '18.07.2012', 'Correct ac_companyaccount triggers.');
  
INSERT INTO fin_versioninfo
  VALUES (158, '0000.0001.0000.0189', '26.09.2012', 'Change way of reports being called from Explorer tree.');  

INSERT INTO fin_versioninfo
  VALUES (159, '0000.0001.0000.0190', '17.10.2012', 'Delete InvCardForm params from userstorage.');
  
INSERT INTO fin_versioninfo
  VALUES (160, '0000.0001.0000.0191', '19.10.2012', 'Corrected inv_bu_movement trigger.');

INSERT INTO fin_versioninfo
  VALUES (161, '0000.0001.0000.0192', '29.10.2012', 'Trigger AC_AIU_ACCOUNT_CHECKALIAS modified.');

INSERT INTO fin_versioninfo
  VALUES (162, '0000.0001.0000.0193', '14.11.2012', 'Delete cbAnalytic from script.');

INSERT INTO fin_versioninfo
  VALUES (163, '0000.0001.0000.0194', '11.04.2013', 'Namespace tables added.');

INSERT INTO fin_versioninfo
  VALUES (164, '0000.0001.0000.0195', '06.05.2013', 'Issue 2846.');

INSERT INTO fin_versioninfo
  VALUES (165, '0000.0001.0000.0196', '08.05.2013', 'Issue 2688.');

INSERT INTO fin_versioninfo
  VALUES (166, '0000.0001.0000.0197', '11.05.2013', 'Added unique constraint on xid, dbid fields to gd_ruid table.');

INSERT INTO fin_versioninfo
  VALUES (167, '0000.0001.0000.0198', '14.05.2013', 'Drop FK to gd_ruid in at_object.');

INSERT INTO fin_versioninfo
  VALUES (168, '0000.0001.0000.0199', '16.05.2013', 'Move subobjects along with a head object.');

INSERT INTO fin_versioninfo
  VALUES (169, '0000.0001.0000.0200', '17.05.2013', 'Added MODIFIED field to AT_OBJECT.');

INSERT INTO fin_versioninfo
  VALUES (170, '0000.0001.0000.0201', '17.05.2013', 'Constraint on at_object changed.');

INSERT INTO fin_versioninfo
  VALUES (171, '0000.0001.0000.0202', '18.05.2013', 'Added unique constraint on xid, dbid fields to gd_ruid table. Attempt #2.');

INSERT INTO fin_versioninfo
  VALUES (172, '0000.0001.0000.0203', '19.05.2013', 'Curr_modified field added to at_object.');

INSERT INTO fin_versioninfo
  VALUES (173, '0000.0001.0000.0204', '20.05.2013', 'Missed editiondate fields added.');

INSERT INTO fin_versioninfo
  VALUES (174, '0000.0001.0000.0205', '05.06.2013', 'Corrections for NS triggers.');

INSERT INTO fin_versioninfo
  VALUES (175, '0000.0001.0000.0206', '08.06.2013', 'Add missing edition date fields #2.');

INSERT INTO fin_versioninfo
  VALUES (176, '0000.0001.0000.0207', '13.06.2013', 'Added trigger to at_object.');

INSERT INTO fin_versioninfo
  VALUES (177, '0000.0001.0000.0208', '14.06.2013', 'Revert last changes.');

INSERT INTO fin_versioninfo
  VALUES (178, '0000.0001.0000.0209', '10.08.2013', 'Added check for account activity.');

INSERT INTO fin_versioninfo
  VALUES (179, '0000.0001.0000.0210', '11.08.2013', 'Added check for account activity #2.');

INSERT INTO fin_versioninfo
  VALUES (180, '0000.0001.0000.0211', '19.08.2013', 'gd_object_dependencies table added.');

INSERT INTO fin_versioninfo
  VALUES (181, '0000.0001.0000.0212', '20.08.2013', 'Issue 1041.');

INSERT INTO fin_versioninfo
  VALUES (182, '0000.0001.0000.0213', '22.08.2013', 'Issue 3218.');

INSERT INTO fin_versioninfo
  VALUES (183, '0000.0001.0000.0214', '31.08.2013', 'Added NS sync tables.');

INSERT INTO fin_versioninfo
  VALUES (184, '0000.0001.0000.0215', '02.09.2013', 'Generator added.');

INSERT INTO fin_versioninfo
  VALUES (185, '0000.0001.0000.0216', '08.09.2013', 'Drop constraint AT_FK_NAMESPACE_SYNC_NSK.');

INSERT INTO fin_versioninfo
  VALUES (186, '0000.0001.0000.0217', '10.09.2013', 'Drop constraint AT_FK_NAMESPACE_SYNC_NSK. Attempt #2.');

INSERT INTO fin_versioninfo
  VALUES (187, '0000.0001.0000.0218', '12.09.2013', 'Modified check constraint on GD_RUID.');

INSERT INTO fin_versioninfo
  VALUES (188, '0000.0001.0000.0219', '14.09.2013', 'Second attempt to drop constraint AT_FK_NAMESPACE_SYNC_NSK.');

INSERT INTO fin_versioninfo
  VALUES (189, '0000.0001.0000.0220', '16.09.2013', 'Change PK on gd_object_dependencies.');

INSERT INTO fin_versioninfo
  VALUES (190, '0000.0001.0000.0221', '23.09.2013', 'Added missed indices to at_namespace tables.');

INSERT INTO fin_versioninfo
  VALUES (191, '0000.0001.0000.0222', '18.10.2013', 'Delete cbAnalytic from Acc_BuildAcctCard.');

INSERT INTO fin_versioninfo
  VALUES (192, '0000.0001.0000.0223', '11.11.2013', 'Change FK for AC_LEDGER_ACCOUNTS.');

INSERT INTO fin_versioninfo
  VALUES (193, '0000.0001.0000.0224', '12.11.2013', 'Corrected triggers for EVT_OBJECT.');

INSERT INTO fin_versioninfo
  VALUES (194, '0000.0001.0000.0225', '26.11.2013', 'RUIDs for gd_storage_data objects.');

INSERT INTO fin_versioninfo
  VALUES (195, '0000.0001.0000.0226', '27.11.2013', 'Add Triggers command into the Explorer tree.');

INSERT INTO fin_versioninfo
  VALUES (196, '0000.0001.0000.0227', '29.11.2013', 'Field changed added to at_namespace.');

INSERT INTO fin_versioninfo
  VALUES (197, '0000.0001.0000.0228', '13.12.2013', 'Help folders added.');

INSERT INTO fin_versioninfo
  VALUES (198, '0000.0001.0000.0229', '12.01.2014', 'Correct old gd_documenttype structure.');

INSERT INTO fin_versioninfo
  VALUES (199, '0000.0001.0000.0230', '10.02.2014', 'New triggers for AC_ENTRY, AC_RECORD.');

INSERT INTO fin_versioninfo
  VALUES (200, '0000.0001.0000.0231', '11.02.2014', 'Restrictions for document date.');

INSERT INTO fin_versioninfo
  VALUES (201, '0000.0001.0000.0232', '24.02.2014', 'Some entry queries have been corrected.');

INSERT INTO fin_versioninfo
  VALUES (202, '0000.0001.0000.0233', '03.03.2014', 'Issue 3323.');

INSERT INTO fin_versioninfo
  VALUES (203, '0000.0001.0000.0234', '05.03.2014', 'Issue 3323. Attempt #2.');
  
INSERT INTO fin_versioninfo
  VALUES (204, '0000.0001.0000.0235', '11.03.2014', 'Issue 3301.');

INSERT INTO fin_versioninfo
  VALUES (205, '0000.0001.0000.0236', '17.03.2014', 'Issue 3330.');

INSERT INTO fin_versioninfo
  VALUES (206, '0000.0001.0000.0237', '17.03.2014', 'Issue 3330. #2.');

INSERT INTO fin_versioninfo
  VALUES (207, '0000.0001.0000.0238', '17.03.2014', 'Triggers for protection of system storage folders.');

INSERT INTO fin_versioninfo
  VALUES (208, '0000.0001.0000.0239', '31.03.2014', 'Introducing AC_INCORRECT_RECORD GTT.');

INSERT INTO fin_versioninfo
  VALUES (209, '0000.0001.0000.0240', '31.03.2014', 'AC_TC_RECORD.');

INSERT INTO fin_versioninfo
  VALUES (210, '0000.0001.0000.0241', '03.04.2014', 'Get back "incorrect" field for ac_record.');

INSERT INTO fin_versioninfo
  VALUES (211, '0000.0001.0000.0242', '04.04.2014', 'Missed grant for AC_INCORRECT_RECORD.');

INSERT INTO fin_versioninfo
  VALUES (212, '0000.0001.0000.0243', '29.04.2014', 'Issue 3373.');

INSERT INTO fin_versioninfo
  VALUES (213, '0000.0001.0000.0244', '22.05.2014', 'Document class can not include a folder.');

INSERT INTO fin_versioninfo
  VALUES (214, '0000.0001.0000.0245', '16.06.2014', 'Add GD_WEBLOG, GD_WEBLOGDATA tables.');

INSERT INTO fin_versioninfo
  VALUES (215, '0000.0001.0000.0246', '02.09.2014', 'gd_x_currrate_fordate index added.');

INSERT INTO fin_versioninfo
  VALUES (216, '0000.0001.0000.0247', '03.09.2014', 'Added command for TgdcCheckConstraint.');

INSERT INTO fin_versioninfo
  VALUES (217, '0000.0001.0000.0248', '06.09.2014', 'MD5 field added to namespace table.');
  
INSERT INTO fin_versioninfo
  VALUES (218, '0000.0001.0000.0249', '28.04.2015', 'Add GD_AUTOTASK, GD_AUTOTASK_LOG tables.');

INSERT INTO fin_versioninfo
  VALUES (219, '0000.0001.0000.0250', '05.06.2015', 'Added COMPUTER field to GD_AUTOTASK.');
  
INSERT INTO fin_versioninfo
  VALUES (220, '0000.0001.0000.0251', '05.06.2015', 'Added PULSE field to GD_AUTOTASK.');
  
INSERT INTO fin_versioninfo
  VALUES (221, '0000.0001.0000.0252', '25.06.2015', 'Added GD_SMTP table.');
  
INSERT INTO fin_versioninfo
  VALUES (222, '0000.0001.0000.0253', '22.07.2015', 'Modified GD_AUTOTASK and GD_SMTP tables.');
  
INSERT INTO fin_versioninfo
  VALUES (223, '0000.0001.0000.0254', '03.08.2015', 'Modified GD_AUTOTASK and GD_SMTP tables. Attempt #2');  
  
INSERT INTO fin_versioninfo
  VALUES (224, '0000.0001.0000.0255', '09.08.2015', 'SMTP servers command has been added to the Explorer.');  

INSERT INTO fin_versioninfo
  VALUES (225, '0000.0001.0000.0256', '17.08.2015', 'Adjust some db fields.');  

INSERT INTO fin_versioninfo
  VALUES (226, '0000.0001.0000.0257', '20.08.2015', 'Check constraint expanded.');  
  
INSERT INTO fin_versioninfo
  VALUES (227, '0000.0001.0000.0258', '31.08.2015', 'GD_DOCUMENTTYPE_OPTION');  
  
INSERT INTO fin_versioninfo
  VALUES (228, '0000.0001.0000.0259', '02.09.2015', 'Correction for GD_DOCUMENTTYPE_OPTION');  
  
INSERT INTO fin_versioninfo
  VALUES (229, '0000.0001.0000.0260', '04.09.2015', 'Correction for GD_DOCUMENTTYPE_OPTION #2');  

INSERT INTO fin_versioninfo
  VALUES (230, '0000.0001.0000.0261', '01.10.2015', 'Correction for GD_DOCUMENTTYPE_OPTION #3');  
  
INSERT INTO fin_versioninfo
  VALUES (231, '0000.0001.0000.0262', '20.10.2015', 'Client address is added to GD_JOURNAL.');  

INSERT INTO fin_versioninfo
  VALUES (232, '0000.0001.0000.0263', '23.10.2015', 'Edition date to GD_DOCUMENTTYPE_OPTION.');  
  
INSERT INTO fin_versioninfo
  VALUES (233, '0000.0001.0000.0264', '09.11.2015', 'XLSX type added.'); 
  
INSERT INTO fin_versioninfo
  VALUES (234, '0000.0001.0000.0265', '14.11.2015', 'Added Reload auto task.');   

INSERT INTO fin_versioninfo
  VALUES (235, '0000.0001.0000.0266', '27.11.2015', 'Added seqid field to gd_object_dependencies table.');   
  
INSERT INTO fin_versioninfo
  VALUES (236, '0000.0001.0000.0267', '02.12.2015', 'https://github.com/GoldenSoftwareLtd/GedeminSalary/issues/208');   
  
INSERT INTO fin_versioninfo
  VALUES (237, '0000.0001.0000.0268', '20.12.2015', 'Delete a record from GD_RUID when deleting AT_NAMESPACE.');   
  
INSERT INTO fin_versioninfo
  VALUES (238, '0000.0001.0000.0269', '21.12.2015', 'Some fixes for CHANGED flag of AT_OBJECT.');   
  
INSERT INTO fin_versioninfo
  VALUES (239, '0000.0001.0000.0270', '29.12.2015', 'AT_OBJECT triggers.');     
  
INSERT INTO fin_versioninfo
  VALUES (240, '0000.0001.0000.0271', '02.01.2016', 'Add edition date field to TgdcSimpleTable.');     
  
INSERT INTO fin_versioninfo
  VALUES (241, '0000.0001.0000.0272', '09.01.2016', 'Second try. Now with triggers disabled.');     
  
INSERT INTO fin_versioninfo
  VALUES (242, '0000.0001.0000.0273', '17.01.2016', 'Nullify objects in at_relation_fields.');     
  
INSERT INTO fin_versioninfo
  VALUES (243, '0000.0001.0000.0274', '24.01.2016', 'Issue when RUIDs of DT differ from GD_RUID record.');     
  
INSERT INTO fin_versioninfo
  VALUES (244, '0000.0001.0000.0275', '28.01.2016', 'Trigger to prevent namespace cyclic dependencies.');     
  
COMMIT;

CREATE UNIQUE DESC INDEX fin_x_versioninfo_id
  ON fin_versioninfo (id);

COMMIT;

CREATE TABLE gd_link
(
  id            dintkey,
  objectkey     dintkey,
  linkedkey     dintkey,
  linkedclass   dclassname NOT NULL,
  linkedsubtype dclassname,
  linkedname    dname,
  linkedusertype dtext20,
  linkedorder   INTEGER,

  CONSTRAINT gd_pk_link_id PRIMARY KEY (id)
);

COMMIT;

/*

  Copyright (c) 2000-2015 by Golden Software of Belarus, Ltd

  Script

    gd_security.sql

  Abstract

    An Interbase script for access.

  Author

    Andrey Shadevsky (27.04.00)

  Revisions history

    Initial  27.04.00  JKL    Initial version
    add table gd_classes  27.05.2002 Nick

  Status


*/

/****************************************************

   Таблица для хранения пользователей.

*****************************************************/

CREATE DOMAIN dallowaudit
  AS SMALLINT DEFAULT 0 NOT NULL;

COMMIT;

CREATE TABLE gd_user
(
  id               dintkey,                     /* Первичный ключ                                    */
  name             dusername,                   /* имя                                               */
  passw            dpassword,                   /* пароль                                            */
  ingroup          dinteger DEFAULT 1 NOT NULL, /* группы, в которые входит пользователь             */
  fullname         dtext180,                    /* полное имя                                        */
  description      dtext180,                    /* описание                                          */
  ibname           dusername,                   /* имя пользователя IB                               */
  ibpassword       dpassword,                   /* пароль IB                                         */
  contactkey       dintkey,                     /* ссылка на запись в таблице контактов              */
  externalkey      dforeignkey,                 /* внешняя ссылка, например на справочник сотрудников*/
  disabled         dboolean DEFAULT 0 NOT NULL, /* отключен                                          */
  lockedout        dboolean DEFAULT 0,          /* запись заблокирована                              */
  mustchange       dboolean DEFAULT 0,          /* при входе пользователь должен изменить пароль     */
  cantchangepassw  dboolean DEFAULT 1,          /* пользователь не может менять пароль               */
  passwneverexp    dboolean DEFAULT 1,          /* срок действия пароля никогда не истекает          */
  expdate          ddate,                       /* дата истечения срока действия пароля              */
  workstart        dtime,                       /* начало рабочего дня                               */
  workend          dtime,                       /* окончание рабочего дня                            */
  allowaudit       dallowaudit,                 /* будут ли операции этого пользователя заноситься   */
                                                /* в журнал                                          */
  editiondate      deditiondate,
  editorkey        dforeignkey,

  icon             dinteger,                    /* пиктограмка для данного пользователя              */
  reserved         dinteger,                    /* зарезервировано                                   */

  CHECK (((workstart IS NULL) AND (workend IS NULL)) OR (workstart < workend)),
  CHECK (ingroup <> 0)
);

ALTER TABLE gd_user ADD CONSTRAINT gd_pk_user
  PRIMARY KEY (id);

/* имя пользователя должно быть уникальным */
CREATE UNIQUE ASC INDEX gd_x_user_name ON gd_user
  (name);

/*
CREATE UNIQUE INDEX gd_x_user_ibname ON
  gd_user (ibname);
*/  

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_user FOR gd_user
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  /* значения по умолчанию */
  IF (NEW.ingroup IS NULL) THEN
    NEW.ingroup = 0;
  IF (NEW.disabled IS NULL) THEN
    NEW.disabled = 0;
  IF (NEW.mustchange IS NULL) THEN
    NEW.mustchange = 0;
  IF (NEW.cantchangepassw IS NULL) THEN
    NEW.cantchangepassw = 1;
  IF (NEW.passwneverexp IS NULL) THEN
    NEW.passwneverexp = 1;
  IF (NEW.lockedout IS NULL) THEN
    NEW.lockedout = 0;
END
^

CREATE EXCEPTION gd_e_invaliduserupdate 'At least one user must be enabled'^

CREATE OR ALTER TRIGGER gd_bu_user FOR gd_user
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF ((NEW.disabled = 1) AND (OLD.disabled = 0) AND
      (SINGULAR (SELECT * FROM gd_user WHERE disabled = 0))) THEN
    EXCEPTION gd_e_invaliduserupdate;
END
^

CREATE EXCEPTION gd_e_invaliduserdelete 'Can not delete all users'^

CREATE TRIGGER gd_bd_user FOR gd_user
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  /* выдаліць адміністратара немагчыма */
  IF (OLD.ID = 150001) THEN
    EXCEPTION gd_e_invaliduserdelete;
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения подсистем.

*****************************************************/

CREATE TABLE gd_subsystem
(
  id               dintkey,             /* Первичный ключ                       */
  name             dusername,           /* имя                                  */
  description      dtext180,            /* описание                             */
  groupsallowed    dintkey DEFAULT 1,   /* группы, которым разрешен доступ      */

  auditlevel       dsmallint DEFAULT 2, /* уровень аудита, по-умолчанию средний */
  auditcache       dsmallint DEFAULT 1, /* использовать кэширование, да         */
  auditmaxdays     dsmallint DEFAULT 0, /* удалят записи, по-умолчанию нет      */

  disabled         dboolean DEFAULT 0,  /* отключена                            */
  reserved         dinteger,            /* зарезервировано                      */

  CHECK(auditlevel >= 0 AND auditlevel <= 3),
  CHECK(auditcache >= 0 AND auditcache <= 1),
  CHECK(auditmaxdays >= 0)
);

ALTER TABLE gd_subsystem ADD CONSTRAINT gd_pk_subsystem
  PRIMARY KEY (id);

/* имя пользователя должно быть уникальным */
CREATE UNIQUE ASC INDEX gd_x_subsystem_name
  ON gd_subsystem (name);

SET TERM ^ ;

CREATE TRIGGER gd_bi_subsystem FOR gd_subsystem
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE EXCEPTION gd_e_invalidsubsystemdelete 'Cannt delete all subsystem'^

CREATE TRIGGER gd_bd_subsystem FOR gd_subsystem
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (NOT EXISTS(SELECT * FROM gd_subsystem WHERE id <> OLD.id)) THEN
    EXCEPTION gd_e_invalidsubsystemdelete;
END
^

SET TERM ; ^

COMMIT;


/****************************************************/
/**                                                **/
/**  Группы пользователей                          **/
/**                                                **/
/****************************************************/

CREATE TABLE gd_usergroup
(
  id              dintkey,              /* уникальный идентификатор    */
  disabled        dboolean DEFAULT 0,   /* группа отключена            */
  name            dusergroupname,       /* наименование                */
  description     dtext180,             /* описание                    */
  icon            dinteger,             /*                             */
  reserved        dinteger              /* зарезервировано             */
);

ALTER TABLE gd_usergroup
  ADD CONSTRAINT gd_pk_usergroup PRIMARY KEY (id);

ALTER TABLE gd_usergroup
  ADD CONSTRAINT gd_chk_usergroup_id CHECK (id BETWEEN 1 AND 32);

ALTER TABLE gd_usergroup
  ADD CONSTRAINT gd_chk_usergroup_name CHECK (name > '');

CREATE UNIQUE ASC INDEX gd_x_usergroup_name ON gd_usergroup
  (name);

COMMIT;

CREATE GENERATOR gd_g_session_id;
SET GENERATOR gd_g_session_id TO 1;

SET TERM ^ ;

CREATE EXCEPTION gd_e_cantaddusergroup 'New Id cannt be more than 32'^

CREATE PROCEDURE gd_p_getnextusergroupid
  RETURNS(NextID INTEGER)
AS
  DECLARE VARIABLE N INTEGER;
BEGIN
  NextID = 7;
  FOR
    SELECT id
    FROM gd_usergroup
    WHERE id >= 7
    ORDER BY id
    INTO :N
  DO BEGIN
    IF (:NextID < :N) THEN
    BEGIN
      EXIT;
    END

    NextID = :NextID + 1;

    IF (:NextID > 32) THEN
    BEGIN
      EXCEPTION gd_e_cantaddusergroup;
    END
  END
END
^

CREATE TRIGGER gd_bi_usergroup FOR gd_usergroup
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
  BEGIN
    EXECUTE PROCEDURE gd_p_getnextusergroupid
      RETURNING_VALUES NEW.id;
  END
END
^

CREATE EXCEPTION gd_e_canteditusergroup 'Can''t edit reserved user group'^

CREATE TRIGGER gd_bu_usergroup FOR gd_usergroup
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF ((OLD.ID < 7) AND (OLD.name <> NEW.name)) THEN
    EXCEPTION gd_e_canteditusergroup;
END
^

CREATE EXCEPTION gd_e_cantdeleteusergroup 'Cannt delete user group'^

CREATE TRIGGER gd_bd_usergroup FOR gd_usergroup
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.ID < 7) THEN
    EXCEPTION gd_e_cantdeleteusergroup;
END
^

CREATE TRIGGER gd_ad_usergroup FOR gd_usergroup
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE MASK INTEGER;
  DECLARE VARIABLE I INTEGER;
BEGIN
  MASK = 1;
  I = 1;
  WHILE (I < OLD.id) DO
  BEGIN
    MASK = BIN_SHL(:MASK, 1);
    I = :I + 1;
  END

  /* пользователей, которые входили только в удаленную группу */
  /* переведем в стандартную группу Пользователи              */
  UPDATE gd_user SET ingroup = 4 WHERE ingroup = :MASK;

  /* исключим пользователей из удаленной группы               */
  UPDATE gd_user SET ingroup = BIN_AND(ingroup, BIN_NOT(:MASK))
    WHERE BIN_AND(ingroup, :MASK) <> 0;
END
^

CREATE TRIGGER gd_biu_user FOR gd_user
  BEFORE INSERT OR UPDATE
  POSITION 100
AS
  DECLARE VARIABLE I INTEGER;
  DECLARE VARIABLE MASK INTEGER;
  DECLARE VARIABLE M BIGINT;
BEGIN
  I = 1;
  M = 1;
  MASK = 0;
  WHILE (I < 32) DO
  BEGIN
    IF (EXISTS (SELECT * FROM gd_usergroup WHERE id = :I)) THEN
      MASK = BIN_OR(:MASK, :M);
    M = BIN_SHL(:M, 1);
    I = :I + 1;
  END

  NEW.ingroup = BIN_AND(NEW.ingroup, :MASK);
END
^

SET TERM ; ^


/* визуальные настройки */


COMMIT;

SET TERM ^ ;

/*--------------------------------------------------------

  gd_p_sec_getgroupsforuser

  На вход передается: идентификатор пользователя
  На выходе: строка, список групп, в которые входит этот пользователь

----------------------------------------------------------*/

CREATE PROCEDURE gd_p_sec_getgroupsforuser(UserKey INTEGER)
  RETURNS(GroupsForUser VARCHAR(2048))
AS
  DECLARE VARIABLE UGK INTEGER;
  DECLARE VARIABLE GroupName VARCHAR(2048);
  DECLARE VARIABLE C1 INTEGER;
  DECLARE VARIABLE C2 INTEGER;
  DECLARE VARIABLE IG INTEGER;
BEGIN
  SELECT ingroup FROM gd_user WHERE id = :UserKey INTO :IG;

  C2 = 1;
  C1 = 1;
  GroupsForUser = '';
  WHILE (:C1 <= 32) DO
  BEGIN
    IF (BIN_AND(:C2, :IG) > 0) THEN
    BEGIN
      GroupName = '';
      SELECT gg.name
      FROM gd_usergroup gg
      WHERE gg.id = :C1
      INTO :GroupName;

      IF (:GroupName <> '') THEN
        GroupsForUser = :GroupsForUser || ', ' || :GroupName;
    END

    C1 = :C1 + 1;

    IF (:C1 < 32) THEN
      C2 = :C2 * 2;
  END
END
^

SET TERM ; ^

GRANT EXECUTE ON PROCEDURE gd_p_sec_getgroupsforuser TO startuser;
GRANT SELECT ON gd_user TO PROCEDURE gd_p_sec_getgroupsforuser;
GRANT SELECT ON gd_usergroup TO PROCEDURE gd_p_sec_getgroupsforuser;

COMMIT;

CREATE TABLE gd_journal
(
  id               dintkey,
  contactkey       dforeignkey,
  clientaddress    CHAR(15),
  operationdate    dtimestamp_notnull,
  source           dtext40,
  objectid         dforeignkey,
  data             dblobtext80_1251
);

COMMIT;

ALTER TABLE gd_journal ADD CONSTRAINT gd_pk_journal
  PRIMARY KEY (id);

/* фореін кей не ставіцца з мэтай хукага дабаўленьня запісаў */

COMMIT;

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_journal FOR gd_journal
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE OR ALTER TRIGGER gd_bi_journal2 FOR gd_journal
  BEFORE INSERT
  POSITION 2
AS
BEGIN
  IF (NEW.operationdate IS NULL) THEN
    NEW.operationdate = CURRENT_TIMESTAMP;

  IF (NEW.contactkey IS NULL) THEN
    NEW.contactkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY'); 
    
  IF (NEW.clientaddress IS NULL) THEN
    NEW.clientaddress = RDB$GET_CONTEXT('SYSTEM', 'CLIENT_ADDRESS');  
END
^

SET TERM ; ^

COMMIT;

/*

  Спроба зрабіць манітор SQL запытаў.

*/

CREATE TABLE gd_sql_statement
(
  id               dintkey,
  crc              INTEGER NOT NULL UNIQUE,
  kind             SMALLINT NOT NULL,          /* 0 -- sql, 1 -- params */
  data             dblobtext80_1251 not null,
  editiondate      deditiondate
);

ALTER TABLE gd_sql_statement ADD CONSTRAINT gd_pk_sql_statement
  PRIMARY KEY (id);

/* фореін кей не ставіцца з мэтай хукага дабаўленьня запісаў */

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_sql_statement FOR gd_sql_statement
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE gd_sql_log
(
  statementcrc     INTEGER NOT NULL,
  paramscrc        INTEGER,
  contactkey       dintkey,
  starttime        dtimestamp_notnull,
  duration         INTEGER NOT NULL
);

COMMIT;

ALTER TABLE gd_sql_log ADD CONSTRAINT gd_fk_sql_log_scrc
  FOREIGN KEY (statementcrc) REFERENCES gd_sql_statement (crc)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_sql_log ADD CONSTRAINT gd_fk_sql_log_pcrc
  FOREIGN KEY (paramscrc) REFERENCES gd_sql_statement (crc)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

/*
ALTER TABLE gd_sql_log ADD CONSTRAINT gd_fk_sql_log_ckey
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
*/

COMMIT;

/*--------------------------------------------------------

  gd_p_sec_loginuser

  На вход передаются: имя пользователя и пароль
  (пока не в зашифрованном виде). Эти значения пользователь вводит
  при входе в систему.

  На выходе:
    result = 1          -- все нормально
    result = 2          -- все нормально, сменить пароль
    result = -1001      -- нет такой подсистемы
    result = -1002      -- подсистема заблокирована
    result = -1003      -- пользователя нет
    result = -1004      -- пароль неверен
    result = -1005      -- пользователь заблокирован или истек срок
    result = -1006      -- вход в не рабочее время
    result = -1007      -- пользователь не имеет прав на вход в подсистему
    result = -1008      -- все группы пользователя для входа в подсистему заблокированы

    Если все нормально, то userkey, ibname, ibpassw -- ключ пользователя,
    имя пользователя Interbase и пароль Interbase соответственно.
    Иначе, значения переменных неопределены.

  ВНИМАНИЕ! Мы поменяли смысл ДБверсионИД -- теперь это
  уникальный идентификатор базы данных (значение соответствующего
  генератора).

----------------------------------------------------------*/

SET TERM ^ ;

CREATE PROCEDURE gd_p_sec_loginuser (username VARCHAR(20), passw VARCHAR(20), subsystem INTEGER)
  RETURNS (
    result        INTEGER,
    userkey       INTEGER,
    contactkey    INTEGER,
    ibname        VARCHAR(20),
    ibpassword    VARCHAR(20),
    ingroup       INTEGER,
    session       INTEGER,
    subsystemname VARCHAR(60),
    groupname     VARCHAR(2048),
    dbversion     VARCHAR(20),
    dbreleasedate DATE,
    dbversionid   INTEGER,
    dbversioncomment VARCHAR(254),
    auditlevel    INTEGER,
    auditcache    INTEGER,
    auditmaxdays  INTEGER,
    allowuseraudit SMALLINT
  )
AS
  DECLARE VARIABLE PNE INTEGER;
  DECLARE VARIABLE MCH INTEGER;
  DECLARE VARIABLE WS TIME;
  DECLARE VARIABLE WE TIME;
  DECLARE VARIABLE ED DATE;
  DECLARE VARIABLE UDISABLED INTEGER;
  DECLARE VARIABLE UPASSW VARCHAR(20);
BEGIN
  UDISABLED = NULL;

  SELECT id, disabled, passw, workstart, workend, expdate, passwneverexp,
    contactkey, ibname, ibpassword, ingroup, mustchange, allowaudit
  FROM gd_user
  WHERE UPPER(name) = UPPER(:username)
  INTO :userkey, :UDISABLED, :UPASSW, :WS, :WE, :ED, :PNE,
    :contactkey, :ibname, :ibpassword, :ingroup, :MCH, :AllowUserAudit;

  IF (:userkey IS NULL) THEN
  BEGIN
    result = -1003;
    EXIT;
  END

  IF (:UDISABLED <> 0) THEN
  BEGIN
    result = -1005;
    EXIT;
  END

  IF ((CURRENT_DATE >= :ED) AND (:PNE = 0)) THEN
  BEGIN
    result = -1005;
    EXIT;
  END

  IF (
    (NOT :WS IS NULL) AND
    (NOT :WE IS NULL) AND
    ((CURRENT_TIME < :WS) OR (CURRENT_TIME > :WE))
  ) THEN
  BEGIN
    result = -1006;
    EXIT;
  END

  IF (:UPASSW <> :passw) THEN
  BEGIN
    result = -1004;
    EXIT;
  END

  IF (:contactkey IS NULL) THEN
    contactkey = -1;

  EXECUTE PROCEDURE gd_p_sec_getgroupsforuser(:userkey)
    RETURNING_VALUES :groupname;

  result = IIF(:MCH = 0, 1, 2);

  /* унiкальны нумар сэсii */
  session = GEN_ID(gd_g_session_id, 1);

  /* бягучы нумар вэрс__ базы _ дата выхаду */
  SELECT FIRST 1 versionstring, releasedate, /*id,*/ comment
  FROM fin_versioninfo
  ORDER BY id DESC
  INTO :dbversion, :dbreleasedate, /*:dbversionid,*/ :dbversioncomment;

  dbversionid = GEN_ID(gd_g_dbid, 0);
END
^

/*

  Возвращает список таблиц из базы данных, у которых есть
  дескрипторы безопасности. Кроме этого показывает какие именно
  дескрипторы присутствуют в той или иной таблице (0 или 1
  в соответствующей колонке результирующего набора).

*/
CREATE PROCEDURE gd_p_gettableswithdescriptors
RETURNS (relationname VARCHAR(32), aview INTEGER, achag INTEGER, afull INTEGER)
AS
BEGIN
  FOR
    SELECT
      DISTINCT rf.rdb$relation_name
      FROM rdb$relation_fields rf
        LEFT JOIN rdb$view_relations vr ON vr.rdb$view_name = rf.rdb$relation_name
      WHERE rf.rdb$field_name IN ('AVIEW', 'ACHAG', 'AFULL')
        AND vr.rdb$view_name IS NULL
      INTO :RelationName
  DO
  BEGIN
    IF (EXISTS (SELECT * FROM rdb$relation_fields WHERE rdb$relation_name=:RelationName AND
          rdb$field_name='AVIEW')) THEN aview = 1; ELSE aview = 0;
    IF (EXISTS (SELECT * FROM rdb$relation_fields WHERE rdb$relation_name=:RelationName AND
          rdb$field_name='ACHAG')) THEN achag = 1; ELSE achag = 0;
    IF (EXISTS (SELECT * FROM rdb$relation_fields WHERE rdb$relation_name=:RelationName AND
          rdb$field_name='AFULL')) THEN afull = 1; ELSE afull = 0;
    SUSPEND;
  END
END
^

SET TERM ; ^

GRANT EXECUTE ON PROCEDURE gd_p_sec_loginuser TO startuser;
GRANT SELECT ON gd_user TO PROCEDURE gd_p_sec_loginuser;
GRANT SELECT ON gd_subsystem TO PROCEDURE gd_p_sec_loginuser;
GRANT SELECT ON gd_usergroup TO PROCEDURE gd_p_sec_loginuser;
GRANT SELECT, UPDATE, DELETE ON gd_journal TO PROCEDURE gd_p_sec_loginuser;

/****************************************************

   Таблицы веб сервера

*****************************************************/

CREATE DOMAIN gd_dipaddress
  VARCHAR(15) NOT NULL
  CHECK (VALUE SIMILAR TO
    '(([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-6]).){3}([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-6])');

CREATE TABLE gd_weblog
(
  id           dintkey,
  ipaddress    gd_dipaddress,
  op           CHAR(4) NOT NULL,
  datetime     TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

  CONSTRAINT gd_pk_weblog PRIMARY KEY (id)
);

COMMIT;

CREATE TABLE gd_weblogdata
(
  logkey       dintkey,
  valuename    dname,
  valuestr     dtext254,
  valueblob    BLOB SUB_TYPE 1 CHARACTER SET WIN1251 COLLATE PXW_CYRL,

  CONSTRAINT gd_pk_weblogdata PRIMARY KEY (logkey, valuename),
  CONSTRAINT gd_fk_weblogdata_logkey FOREIGN KEY (logkey)
    REFERENCES gd_weblog (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_weblog FOR gd_weblog
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/*

   0 прочее
  10 страна
  20 область
  30 район
  40 населенный пункт
  50 район в нас пункте
  60 улица
  70 дом

*/

CREATE DOMAIN dplacetype
  AS VARCHAR(10) CHARACTER SET WIN1251
  DEFAULT ''
  NOT NULL
  COLLATE PXW_CYRL;

CREATE TABLE gd_place (
  id          dintkey,
  parent      dparent,
  lb          dlb,
  rb          drb,
  name        dname,
  placetype   dplacetype,
  telprefix   dtext8,           /* телефонный код места (города ) */
  code        dtext8,           /* код местности*/
  editiondate deditiondate
);

COMMIT;

ALTER TABLE gd_place ADD CONSTRAINT gd_pk_place
  PRIMARY KEY (id);

ALTER TABLE gd_place ADD CONSTRAINT gd_fk_place_parent
  FOREIGN KEY (parent)
  REFERENCES gd_place (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

CREATE EXCEPTION gd_e_placeexists 'Place already exists';

SET TERM ^ ;

CREATE TRIGGER gd_bi_place FOR gd_place
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (EXISTS(SELECT * FROM gd_place WHERE COALESCE(parent, 0) = COALESCE(NEW.parent, 0)
    AND UPPER(name) = UPPER(NEW.name))) THEN
  BEGIN
    EXCEPTION gd_e_placeexists;
  END
END
^

CREATE TRIGGER gd_bu_place FOR gd_place
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (EXISTS(SELECT * FROM gd_place WHERE COALESCE(parent, 0) = COALESCE(NEW.parent, 0)
    AND UPPER(name) = UPPER(NEW.name)
    AND ID <> NEW.id)) THEN
  BEGIN
    EXCEPTION gd_e_placeexists;
  END
END
^

SET TERM ; ^

COMMIT;
/****************************************************/
/**   Справочник валют                             **/
/****************************************************/

CREATE TABLE gd_curr
(
  id             dintkey,                      /* уникальный идентификатор                               */
  disabled       ddisabled,                    /* используется эта валюта или нет                        */
  isNCU          dboolean DEFAULT 0,           /* является ли эта валюта национальной денежной ед.       */
  isEq           dboolean DEFAULT 0,           /* является ли эта валюта эквивалентом       */
  code           dalias,                       /* код валюты (по банковскому классификатору)             */
  name           dname,                        /* полное наименование                                    */
  shortname      dalias,                       /* краткое наименование                                   */
  sign           dalias,                       /* знак валюты                                            */
  place          dboolean DEFAULT 0,           /* местоположение знака, TRUE -- до, FALSE -- после числа */
  decdigits      ddecdigits DEFAULT 2,         /* количество десятичных знаков                           */
  fullcentname   dtext40,                      /* полное наименование центов                             */
  shortcentname  dtext40,                      /* краткое наименование центов                            */
  centbase       dsmallint DEFAULT 10 NOT NULL, /* база дробных единиц (почти всегда 10)                  */
  icon           dinteger,
  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,
  ISO            dISO,
  name_0         dtext60, /* В родительном падеже, если заканчивается на 0, 5-9*/
  name_1         dtext60, /* В родительном падеже, если заканчивается на 2-4 */
  centname_0     dtext60, /* В родительном падеже, если заканчивается на 0, 5-9*/
  centname_1     dtext60, /* В родительном падеже, если заканчивается на 2-4 */
  editiondate    deditiondate,
  reserved       dreserved
);

COMMIT;

ALTER TABLE gd_curr ADD CONSTRAINT gd_pk_curr
  PRIMARY KEY (id);

CREATE UNIQUE ASC INDEX gd_x_currfullname ON gd_curr
  (name);

CREATE UNIQUE ASC INDEX gd_x_currshortname ON gd_curr
  (shortname);

SET TERM ^ ;

CREATE TRIGGER gd_bi_curr FOR gd_curr
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE ATTRKEY INTEGER;
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.code IS NULL) THEN
    NEW.code = '';

  /* НДЕ может быть только одна */
  IF (NEW.isNCU = 1) THEN
    UPDATE gd_curr SET isNCU = 0 WHERE isNCU = 1;

  /* Эквивалент может быть только один */
  IF (NEW.isEq = 1) THEN
    UPDATE gd_curr SET isEq = 0 WHERE isEq = 1;
END
^

CREATE TRIGGER gd_bu_curr FOR gd_curr
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE ATTRKEY INTEGER;
BEGIN
  /* НДЕ может быть только одна */
  IF (NEW.isNCU = 1 AND NEW.isNCU <> OLD.isNCU) THEN
    UPDATE gd_curr SET isNCU = 0 WHERE id <> NEW.id;

  /* Эквивалент может быть только один */
  IF (NEW.isEq = 1 AND NEW.isEq <> OLD.isEq) THEN
    UPDATE gd_curr SET isEq = 0 WHERE id <> NEW.id;
END
^


SET TERM ; ^

COMMIT;

/****************************************************/
/**   Справочник курсов валют                      **/
/****************************************************/

CREATE DOMAIN dcurrrate AS
  DECIMAL(15, 10)
  NOT NULL;

COMMIT;

CREATE TABLE gd_currrate
(
  id             dintkey,
  fromcurr       dintkey,
  tocurr         dintkey,
  fordate        ddate NOT NULL,
  coeff          dcurrrate,
  editiondate    deditiondate
);

COMMIT;

SET TERM ^ ;


CREATE TRIGGER gd_bi_currrate FOR gd_currrate ACTIVE
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

ALTER TABLE gd_currrate ADD CONSTRAINT gd_pk_currrate
  PRIMARY KEY (id);

ALTER TABLE gd_currrate ADD CONSTRAINT gd_uk_currrate
  UNIQUE (fromcurr, tocurr, fordate);

ALTER TABLE gd_currrate ADD CONSTRAINT gd_fk1_currrate
  FOREIGN KEY (fromcurr) REFERENCES gd_curr (id) ON UPDATE CASCADE;

ALTER TABLE gd_currrate ADD CONSTRAINT gd_fk2_currrate
  FOREIGN KEY (tocurr) REFERENCES gd_curr (id) ON UPDATE CASCADE;

ALTER TABLE gd_currrate ADD CONSTRAINT gd_chk1_currrate
  CHECK(fromcurr <> tocurr);

CREATE DESC INDEX gd_x_currrate_fordate ON gd_currrate(fordate);

COMMIT;
/*

  Copyright (c) 2000-2016 by Golden Software of Belarus, Ltd

  Script


  Abstract


  Author


  Revisions history


  Status

    Draft

*/

RECREATE TABLE wg_position
(
  id           dintkey,
  name         dname UNIQUE,
  editiondate  deditiondate,
  reserved     dreserved,

  CONSTRAINT wg_pk_position_id PRIMARY KEY (id)
);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER wg_bi_position FOR wg_position
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

RECREATE TABLE wg_holiday
(
  id          dintkey,
  holidaydate ddate NOT NULL UNIQUE,
  name        dname,
  editiondate deditiondate,
  disabled    ddisabled,

  CONSTRAINT wg_pk_holiday_id PRIMARY KEY (id)
);

COMMIT;


RECREATE TABLE wg_tblcal
(
  id         dintkey,
  name       dname,

  /* працоўныя дні тыдня */
  mon        dboolean_notnull DEFAULT 1,
  tue        dboolean_notnull DEFAULT 1,
  wed        dboolean_notnull DEFAULT 1,
  thu        dboolean_notnull DEFAULT 1,
  fri        dboolean_notnull DEFAULT 1,
  sat        dboolean_notnull DEFAULT 0,
  sun        dboolean_notnull DEFAULT 0,

  /*Праздничные дни по умолчанию нерабочие*/
  holidayiswork  dboolean_notnull DEFAULT 0,

  /* інтэрвалы працоўнага часу */
  w1_offset   dinteger DEFAULT 0,
  w1_start1   dtime_notnull DEFAULT '00:00:00',
  w1_end1     dtime_notnull DEFAULT '00:00:00',
  w1_start2   dtime_notnull DEFAULT '00:00:00',
  w1_end2     dtime_notnull DEFAULT '00:00:00',
  w1_start3   dtime_notnull DEFAULT '00:00:00',
  w1_end3     dtime_notnull DEFAULT '00:00:00',
  w1_start4   dtime_notnull DEFAULT '00:00:00',
  w1_end4     dtime_notnull DEFAULT '00:00:00',

  w2_offset   dinteger DEFAULT 0,
  w2_start1   dtime_notnull DEFAULT '00:00:00',
  w2_end1     dtime_notnull DEFAULT '00:00:00',
  w2_start2   dtime_notnull DEFAULT '00:00:00',
  w2_end2     dtime_notnull DEFAULT '00:00:00',
  w2_start3   dtime_notnull DEFAULT '00:00:00',
  w2_end3     dtime_notnull DEFAULT '00:00:00',
  w2_start4   dtime_notnull DEFAULT '00:00:00',
  w2_end4     dtime_notnull DEFAULT '00:00:00',

  w3_offset   dinteger DEFAULT 0,
  w3_start1   dtime_notnull DEFAULT '00:00:00',
  w3_end1     dtime_notnull DEFAULT '00:00:00',
  w3_start2   dtime_notnull DEFAULT '00:00:00',
  w3_end2     dtime_notnull DEFAULT '00:00:00',
  w3_start3   dtime_notnull DEFAULT '00:00:00',
  w3_end3     dtime_notnull DEFAULT '00:00:00',
  w3_start4   dtime_notnull DEFAULT '00:00:00',
  w3_end4     dtime_notnull DEFAULT '00:00:00',

  w4_offset   dinteger DEFAULT 0,
  w4_start1   dtime_notnull DEFAULT '00:00:00',
  w4_end1     dtime_notnull DEFAULT '00:00:00',
  w4_start2   dtime_notnull DEFAULT '00:00:00',
  w4_end2     dtime_notnull DEFAULT '00:00:00',
  w4_start3   dtime_notnull DEFAULT '00:00:00',
  w4_end3     dtime_notnull DEFAULT '00:00:00',
  w4_start4   dtime_notnull DEFAULT '00:00:00',
  w4_end4     dtime_notnull DEFAULT '00:00:00',

  w5_offset    dinteger DEFAULT 0,
  w5_start1    dtime_notnull DEFAULT '00:00:00',
  w5_end1      dtime_notnull DEFAULT '00:00:00',
  w5_start2    dtime_notnull DEFAULT '00:00:00',
  w5_end2      dtime_notnull DEFAULT '00:00:00',
  w5_start3    dtime_notnull DEFAULT '00:00:00',
  w5_end3      dtime_notnull DEFAULT '00:00:00',
  w5_start4    dtime_notnull DEFAULT '00:00:00',
  w5_end4      dtime_notnull DEFAULT '00:00:00',

  w6_offset    dinteger DEFAULT 0,
  w6_start1    dtime_notnull DEFAULT '00:00:00',
  w6_end1      dtime_notnull DEFAULT '00:00:00',
  w6_start2    dtime_notnull DEFAULT '00:00:00',
  w6_end2      dtime_notnull DEFAULT '00:00:00',
  w6_start3    dtime_notnull DEFAULT '00:00:00',
  w6_end3      dtime_notnull DEFAULT '00:00:00',
  w6_start4    dtime_notnull DEFAULT '00:00:00',
  w6_end4      dtime_notnull DEFAULT '00:00:00',

  w7_offset    dinteger DEFAULT 0,
  w7_start1    dtime_notnull DEFAULT '00:00:00',
  w7_end1      dtime_notnull DEFAULT '00:00:00',
  w7_start2    dtime_notnull DEFAULT '00:00:00',
  w7_end2      dtime_notnull DEFAULT '00:00:00',
  w7_start3    dtime_notnull DEFAULT '00:00:00',
  w7_end3      dtime_notnull DEFAULT '00:00:00',
  w7_start4    dtime_notnull DEFAULT '00:00:00',
  w7_end4      dtime_notnull DEFAULT '00:00:00',

  /* перад святочны дзень */
  w8_offset    dinteger DEFAULT 0,
  w8_start1    dtime_notnull DEFAULT '00:00:00',
  w8_end1      dtime_notnull DEFAULT '00:00:00',
  w8_start2    dtime_notnull DEFAULT '00:00:00',
  w8_end2      dtime_notnull DEFAULT '00:00:00',
  w8_start3    dtime_notnull DEFAULT '00:00:00',
  w8_end3      dtime_notnull DEFAULT '00:00:00',
  w8_start4    dtime_notnull DEFAULT '00:00:00',
  w8_end4      dtime_notnull DEFAULT '00:00:00',

  editiondate  deditiondate,

  CONSTRAINT wg_pk_tblcal PRIMARY KEY (id)
);

COMMIT;

RECREATE TABLE wg_tblcalday
(
  id         dintkey,
  tblcalkey  dintkey,
  theday     ddate_notnull,
  workday    dboolean_notnull DEFAULT 1,
  wstart1    dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wend1      dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wstart2    dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wend2      dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wstart3    dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wend3      dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wstart4    dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wend4      dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',

  editiondate deditiondate,

  WDURATION  COMPUTED BY (G_M_ROUNDNN(((wend1 - wstart1) + (wend2 - wstart2) + (wend3 - wstart3) + (wend4 - wstart4))*24, 0.01)),

  dow COMPUTED BY (EXTRACT(weekday FROM theday)),

  CONSTRAINT wg_pk_tblcalday PRIMARY KEY (id),
  CONSTRAINT wg_fk_tblcalday_tblcal FOREIGN KEY (tblcalkey) REFERENCES wg_tblcal (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT wg_unq_tblcalday_1 UNIQUE (tblcalkey, theday),
  CONSTRAINT wg_chk_tblcalday_1 CHECK (wend1 >= wstart1),
  CONSTRAINT wg_chk_tblcalday_2 CHECK (wend2 >= wstart2),
  CONSTRAINT wg_chk_tblcalday_3 CHECK (wend3 >= wstart3),
  CONSTRAINT wg_chk_tblcalday_4 CHECK (wend4 >= wstart4),
  CONSTRAINT wg_chk_tblcalday_5 CHECK ((wstart2 = '1900-01-01 00:00:00') OR (wstart2 >= wend1)),
  CONSTRAINT wg_chk_tblcalday_6 CHECK ((wstart3 = '1900-01-01 00:00:00') OR (wstart3 >= wend2)),
  CONSTRAINT wg_chk_tblcalday_7 CHECK ((wstart4 = '1900-01-01 00:00:00') OR (wstart4 >= wend3))

);

SET TERM ^ ;

CREATE TRIGGER wg_bi_holiday FOR wg_holiday
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER wg_bi_tblcal FOR wg_tblcal
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER wg_bi_tblcalday FOR wg_tblcalday
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;



CREATE EXCEPTION gd_e_nofolder 'There is no any folder';

CREATE DOMAIN daddrcontacttype
  AS SMALLINT NOT NULL;

CREATE TABLE gd_contact
(
  id            dintkey,


  /* Левая (верхняя) граница. Одновременно может использоваться */
  /* как второй уникальный индекс, если группы и список */
  /* находятся в разных таблицах */
  lb            dlb,
  rb            drb,          /* Правая (нижняя) граница */

  parent        dparent,
  contacttype   daddrcontacttype, /* 0 - папка, 1 - группа, 2 - человек, 3 - клиент, 4 - подразделение, 5 - банк        */
                              /*
                                Для проекта department
                                100 - Реализующие организации
                                101 - Уполномоченные органы
                                102 - финансовые органы
                                103 - Главный уполномоченный орган
                               */

  name          dname,        /* Імя для паказу                                                           */
  address       dtext60,      /* Адрэс                                                                    */
  district      dtext20,
  city          dtext20,      /* Горад                                                                    */
  region        dtext20,      /* Вобласць                                                                 */
  ZIP           dtext20,      /* Індэкс                                                                   */
  country       dtext20,      /* Краіна                                                                   */
  placekey      dforeignkey,
  note          dblobtext80_1251, /* Камэнтар                                                                 */
  externalkey   dforeignkey,
  email         dtext60,
  url           dtext40,
  pobox         dtext40,
  phone         dtext40,
  fax           dtext40,

  creatorkey    dforeignkey,
  creationdate  dcreationdate,

  editorkey     dforeignkey,
  editiondate   deditiondate,

  afull         dsecurity,
  achag         dsecurity,
  aview         dsecurity,

  disabled      ddisabled,
  reserved      dreserved
);

COMMIT;

ALTER TABLE gd_contact ADD CONSTRAINT gd_pk_contact
  PRIMARY KEY (id);

/* калі выдаляецца бацькоўскі кантакт, выдаляем і ўсіх дзяцей */
ALTER TABLE gd_contact ADD CONSTRAINT gd_fk_contract_parent
  FOREIGN KEY (parent) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_contact ADD CONSTRAINT gd_fk_contact_placekey
  FOREIGN KEY (placekey) REFERENCES gd_place (id)
  ON UPDATE CASCADE;

ALTER TABLE gd_contact ADD CONSTRAINT gd_chk_contact_contacttype
  CHECK(contacttype IN (0, 1, 2, 3, 4, 5, 100, 101, 102, 103));

ALTER TABLE gd_contact ADD CONSTRAINT gd_chk_contact_parent
  CHECK((contacttype IN (0, 1)) OR (NOT (parent IS NULL)));

ALTER TABLE gd_user ADD CONSTRAINT gd_fk_user_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE gd_contact ADD CONSTRAINT gd_fk_contact_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_contact(id) 
  ON UPDATE CASCADE;

ALTER TABLE gd_contact ADD CONSTRAINT gd_fk_contact_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

CREATE ASC INDEX gd_x_contact_name ON gd_contact (name);

COMMIT;

CREATE TABLE gd_people
(
  contactkey     dintkey,
  firstname      dtext20,      /* Імя                                                            */
  surname        dtext20 NOT NULL,/* Прозвішча                                                      */
  middlename     dtext20,      /* Імя па бацьку                                                  */
  nickname       dtext20,      /* Кароткае імя                                                   */
  rank           dtext20,      /* Званіе                                                         */

  /* Хатнія дадзеныя */
  hplacekey      dforeignkey,
  haddress       dtext60,     /* Адрас                                                          */
  hcity          dtext20,     /* Горад                                                          */
  hregion        dtext20,     /* Вобласць                                                       */
  hZIP           dtext20,     /* Індэкс                                                         */
  hcountry       dtext20,     /* Краіна                                                         */
  hdistrict      dtext20,
  hphone         dtext20,

  /* Працоўныя дадзеныя */
  wcompanykey    dforeignkey,
  wcompanyname   dtext60,     /* Кампанія                                                       */
  wdepartment    dtext20,     /* Падраздзяленьне                                                */
  wpositionkey   dforeignkey,

  /* Пэрсанальныя дадзеныя */
  spouse         dtext20,     /* Супруг/супруга                                                 */
  children       dtext20,     /* Дзеткі                                                         */
  sex            dgender,     /* Пол                                                            */
  birthday       ddate,        /* Дата нараджэньня                                               */

  /* Пашпартныя дадзеныя */
  passportnumber dtext40,     /* нумар пашпарту */
  /*passportdate   ddate,*/       /* ??? */
  passportexpdate ddate,      /* тэрмін дзеяння пашпарту */
  passportissdate ddate,      /* дата выдачы */
  passportissuer dtext40,     /* хто выдаў */
  passportisscity dtext20,    /* дзе выдадзены */
  personalnumber dtext40,     /* пэрсанальны номер */

  /*Угодкі*/

  /* Дадатковая інфармацыя */
  visitcard      dBMP,        /* Візітная картка                                                */
  photo          dBMP         /* Фота                                                           */
);

ALTER TABLE gd_people
  ADD CONSTRAINT gd_pk_people PRIMARY KEY (contactkey);

ALTER TABLE gd_people ADD CONSTRAINT gd_fk_people_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

/* калі выдаляецца кампанія на якую спасылаецца чалавек */
/* нічога страшнага -- ануліруем гэную спасылку і ўсё   */
ALTER TABLE gd_people ADD CONSTRAINT gd_fk_people_companykey
  FOREIGN KEY (wcompanykey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE gd_people ADD CONSTRAINT gd_fk_people_positionkey
  FOREIGN KEY (wpositionkey) REFERENCES wg_position(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE gd_people ADD CONSTRAINT gd_fk_people_hplacekey
  FOREIGN KEY (hplacekey) REFERENCES gd_place(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_people FOR gd_people
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  NEW.rank = NULL;
  SELECT SUBSTRING(name FROM 1 FOR 20) FROM wg_position WHERE id = NEW.wpositionkey
    INTO NEW.rank;

  IF (NOT NEW.wcompanykey IS NULL) THEN
  BEGIN
    SELECT name FROM gd_contact WHERE id = NEW.wcompanykey
      INTO NEW.wcompanyname;
  END
END
^

CREATE TRIGGER gd_bu_people FOR gd_people
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  NEW.rank = NULL;
  SELECT SUBSTRING(name FROM 1 FOR 20) FROM wg_position WHERE id = NEW.wpositionkey
    INTO NEW.rank;

  IF (NOT NEW.wcompanykey IS NULL) THEN
  BEGIN
    SELECT name FROM gd_contact WHERE id = NEW.wcompanykey
      INTO NEW.wcompanyname;
  END
END
^

CREATE OR ALTER TRIGGER gd_biu_people_pn FOR gd_people
  ACTIVE
  BEFORE INSERT OR UPDATE
  POSITION 32000
AS
BEGIN
  IF (CHAR_LENGTH(NEW.personalnumber) > 0
    AND (INSERTING OR NEW.personalnumber IS DISTINCT FROM OLD.personalnumber)) THEN
  BEGIN
    NEW.personalnumber = UPPER(TRIM(NEW.personalnumber));
    NEW.personalnumber =
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(
                    REPLACE(
                      REPLACE(
                        REPLACE(
                          REPLACE(
                            NEW.personalnumber,
                            'Х', 'X'),
                          'Т', 'T'),
                        'С', 'C'),
                      'Р', 'P'),
                    'О', 'O'),
                  'Н', 'H'),
                'М', 'M'),
              'К', 'K'),
            'Е', 'E'),
          'А', 'A'),
        'В', 'B');
  END
  
  IF (CHAR_LENGTH(NEW.passportnumber) > 0
    AND (INSERTING OR NEW.passportnumber IS DISTINCT FROM OLD.passportnumber)) THEN
  BEGIN
    NEW.passportnumber = UPPER(TRIM(NEW.passportnumber));
    NEW.passportnumber =
      REPLACE(
        REPLACE(
          REPLACE(
            REPLACE(
              REPLACE(
                REPLACE(
                  REPLACE(
                    REPLACE(
                      REPLACE(
                        REPLACE(
                          REPLACE(
                            NEW.personalnumber,
                            'Х', 'X'),
                          'Т', 'T'),
                        'С', 'C'),
                      'Р', 'P'),
                    'О', 'O'),
                  'Н', 'H'),
                'М', 'M'),
              'К', 'K'),
            'Е', 'E'),
          'А', 'A'),
        'В', 'B');
  END
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE gd_company
(
  contactkey        dintkey,     /* Контакт  */
  companyaccountkey dforeignkey, /* Расчетный счет */
  headcompany       dforeignkey, /* Головная компания */
  /* пав?нна быць першым тэкставым полем */
  fullname          dtext180,    /* Полное наименовние */
  companytype       dtext20,     /* Тип компании */
  directorkey       dforeignkey,
  chiefaccountantkey dforeignkey,
  logo              dBMP         /* Логотип */
);

ALTER TABLE gd_company
  ADD CONSTRAINT gd_pk_company PRIMARY KEY (contactkey);

ALTER TABLE gd_company ADD CONSTRAINT gd_fk_company_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_company ADD CONSTRAINT gd_fk_company_headcompany
  FOREIGN KEY (headcompany) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE gd_company ADD CONSTRAINT gd_fk_company_directorkey
  FOREIGN KEY (directorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE gd_company ADD CONSTRAINT gd_fk_company_chiefacckey
  FOREIGN KEY (chiefaccountantkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;


CREATE TABLE gd_companycode
(
  companykey    dintkey,
  legalnumber   dtext20,
  taxid         dtext20,
  okulp         dtext20,
  okpo          dtext20,
  oknh          dtext20,
  soato         dtext20,
  soou          dtext20,
  licence       dtext40
);

ALTER TABLE gd_companycode
  ADD CONSTRAINT gd_pk_companycode PRIMARY KEY (companykey);

/* коды -- дадатковая інфармацыя для кампаніі, таму, калі */
/* выдаляецца кампанія выдалім і коды                     */
ALTER TABLE gd_companycode ADD CONSTRAINT gd_fk_companycode_contackey
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

CREATE TABLE gd_bank
(
  bankkey     dintkey,      /*                           */
  bankcode    dtext20 NOT NULL,
  bankbranch  dtext20,
  bankMFO     dtext20,
  SWIFT       dtext20
);

COMMIT;

ALTER TABLE gd_bank ADD CONSTRAINT gd_pk_bank
  PRIMARY KEY (bankkey);

ALTER TABLE gd_bank ADD CONSTRAINT gd_fk_bank_bankkey
  FOREIGN KEY (bankkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

CREATE UNIQUE INDEX gd_x_bank_bankcode
  ON gd_bank (bankcode, bankbranch);

COMMIT;

/* Типы счетов*/
CREATE TABLE GD_COMPACCTYPE
(
  id          dintkey,
  name        dname,
  editiondate deditiondate
);

COMMIT;

ALTER TABLE gd_compacctype ADD CONSTRAINT gd_pk_compacctype_id
  PRIMARY KEY (id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_compacctype FOR gd_compacctype
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

CREATE TABLE gd_companyaccount
(
  id             dintkey,            /* унікальны ідэнтыфікатар                   */
  companykey     dmasterkey,         /* кампанія, якой належыць рахунак           */
  bankkey        dintkey,            /* спасылка на банк                          */
  payername      dtext60,            /* назва кліента для плацёжных дакументаў    */
  account        dbankaccount NOT NULL,       /* рахунак                                   */
  currkey        dforeignkey,        /* валюта, ў якой адкрыты рахунак            */
  accounttypekey dforeignkey,        /* код тыпа рахунку (разліковы, ссудны...)   */
  disabled       dboolean DEFAULT 0,

  accounttype    dtext20,            /* для совместимости с предыдущей версией    */
  editiondate    deditiondate
);

ALTER TABLE gd_companyaccount ADD CONSTRAINT gd_pk_companyaccount
  PRIMARY KEY (id);

ALTER TABLE gd_companyaccount ADD CONSTRAINT gd_fk_companyaccount_bankkey
  FOREIGN KEY (bankkey) REFERENCES gd_bank(bankkey);

ALTER TABLE gd_companyaccount ADD CONSTRAINT gd_fk_companyaccount_currkey
  FOREIGN KEY (currkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_companyaccount ADD CONSTRAINT gd_fk_companyaccount_acctypekey
  FOREIGN KEY (accounttypekey) REFERENCES gd_compacctype(id)
  ON UPDATE CASCADE;

/* рахункі -- дадатковая інфармацыя для кампаніі, таму, калі */
/* выдаляецца кампанія выдалім і коды                        */
ALTER TABLE gd_companyaccount ADD CONSTRAINT gd_fk_companyaccount_companykey
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_company ADD CONSTRAINT gd_fk_company_companyaccountkey
  FOREIGN KEY (companyaccountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;
  
SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_aiu_companyaccount FOR gd_companyaccount
  AFTER INSERT OR UPDATE
  POSITION 30000
AS
BEGIN
  IF (EXISTS(
    SELECT
      b.bankcode, b.bankbranch, a.account, COUNT(*)
    FROM
      gd_companyaccount a JOIN gd_bank b 
        ON b.bankkey = a.bankkey
    WHERE
      a.account = NEW.account
    GROUP BY
      b.bankcode, b.bankbranch, a.account
    HAVING
      COUNT(*) > 1)) THEN
  BEGIN      
    EXCEPTION gd_e_exception 'Дублируется номер банковского счета!'; 
  END
END
^

SET TERM ; ^
  
COMMIT;

CREATE TABLE gd_contactlist
(
  groupkey      dintkey,
  contactkey    dintkey,
  reserved      dinteger

);

COMMIT;

ALTER TABLE gd_contactlist
  ADD CONSTRAINT gd_pk_contactlist PRIMARY KEY (groupkey, contactkey);

ALTER TABLE gd_contactlist ADD CONSTRAINT gd_fk_contract_contactlist
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

/* калі выдаляецца группа -- выдалім і ўсе звязкі кантактаў з ёй */
ALTER TABLE gd_contactlist ADD CONSTRAINT gd_fk_group_contactlist
  FOREIGN KEY (groupkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/* набор контактов, входящих в список контактов */

CREATE VIEW GD_V_CONTACTLIST
(
  ID, CONTACTNAME, CONTACTTYPE,
  GROUPNAME, GROUPID, GROUPLB, GROUPRB, GROUPTYPE
) AS
SELECT
  P.ID, P.NAME, P.CONTACTTYPE, C.NAME, C.ID, C.LB, C.RB, C.CONTACTTYPE

FROM
  GD_CONTACT C
    JOIN GD_CONTACTLIST CL ON (C.ID = CL.CONTACTKEY)
    JOIN GD_CONTACT P ON (CL.GROUPKEY = P.ID)

GROUP BY
  P.ID, P.NAME, P.CONTACTTYPE, C.NAME, C.ID, C.LB, C.RB, C.CONTACTTYPE;

COMMIT;


SET TERM ^ ;


CREATE PROCEDURE gd_p_SetCompanyToPeople(Department INTEGER)
AS
  DECLARE VARIABLE companykey INTEGER;
BEGIN

  SELECT MIN(comp.id)
    FROM gd_contact comp,
         gd_contact dep
    WHERE dep.id = :Department AND comp.lb <= dep.lb AND
      comp.rb >= dep.rb AND comp.contacttype = 3 INTO :companykey;

  IF (:COMPANYKEY IS NOT NULL) THEN
    UPDATE gd_people p
    SET wcompanykey = :companykey
    WHERE contactkey in
    (SELECT contactkey FROM gd_contactlist cl WHERE groupkey = :Department)
    AND (p.wcompanykey IS NULL);

END
^


CREATE TRIGGER gd_bi_companyaccount FOR gd_companyaccount
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE EXCEPTION gd_e_invalid_contact_parent 'Invalid contact parent'
^

CREATE OR ALTER TRIGGER gd_bi_contact FOR gd_contact
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.name IS NULL) THEN
    NEW.name = '<' || NEW.id || '>';

  IF (NEW.CONTACTTYPE = 0 OR NEW.CONTACTTYPE = 4) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA', '100');
  ELSE
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA', '1');
END
^

/*

  Для однажды созданного контакта нельзя изменять
  его тип.

*/

CREATE EXCEPTION gd_e_cannot_change_contact_type 'Can not change contact type'
^

CREATE TRIGGER gd_bu_contact_3 FOR gd_contact
  BEFORE UPDATE
  POSITION 3
AS
BEGIN
  IF (NEW.contacttype <> OLD.contacttype) THEN
  BEGIN
    EXCEPTION gd_e_cannot_change_contact_type;
  END
END
^

CREATE EXCEPTION gd_e_invalid_contact_type 'Invalid contact type'
^

CREATE TRIGGER gd_bi_company_1000 FOR gd_company
  BEFORE INSERT
  POSITION 1000
AS
BEGIN
  IF (EXISTS(SELECT contacttype FROM gd_contact WHERE id=NEW.contactkey AND contacttype<3)) THEN
  BEGIN
    EXCEPTION gd_e_invalid_contact_type;
  END
END
^

/*
 *  Мы паставілі сартыроўку па назве непасрэдна ў тэксце
 *  працэдуры. !!!
 *
 */

CREATE PROCEDURE gd_p_getfolderelement(parent Integer)
RETURNS
(
  id          INTEGER,
  contacttype INTEGER,
  name        VARCHAR(60),
  phone       VARCHAR(60),
  address     VARCHAR(60),
  email       VARCHAR(60),

  afull       INTEGER,
  achag       INTEGER,
  aview       INTEGER
)
AS
  DECLARE VARIABLE N INTEGER;
BEGIN
  FOR SELECT id, contacttype, name, phone, address, email, afull, achag, aview
    FROM gd_contact
    WHERE parent = :parent
    ORDER BY name
    INTO :id, :contacttype, :name, :phone, :address, :email, :afull, :achag, :aview DO
  BEGIN
    IF (:contacttype = 0) THEN
    BEGIN
      N = :ID;
      FOR
        SELECT id, contacttype, name, phone, address, email, afull, achag, aview
          FROM gd_p_getfolderelement(:N)
          INTO :id, :contacttype, :name, :phone, :address, :email, :afull, :achag, :aview
      DO
        SUSPEND;
    END
    ELSE
      SUSPEND;
  END
END
^

SET TERM ; ^

/* Хранит связку холдинговой компании и входящих в нее компаний */

CREATE TABLE gd_holding (
  holdingkey dintkey,
  companykey dintkey
);

ALTER TABLE gd_holding ADD CONSTRAINT gd_pk_holding
  PRIMARY KEY (holdingkey, companykey);

ALTER TABLE gd_holding ADD  CONSTRAINT gd_fk_holding_companykey
  FOREIGN KEY (companykey) REFERENCES gd_company (contactkey)
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE gd_holding ADD  CONSTRAINT gd_fk_holding_holdingkey
  FOREIGN KEY (holdingkey) REFERENCES gd_company (contactkey)
  ON DELETE CASCADE ON UPDATE CASCADE;

COMMIT;

CREATE VIEW GD_V_COMPANY(
    ID,
    COMPNAME,
    COMPFULLNAME,
    COMPANYTYPE,
    COMPLB,
    COMPRB,
    AFULL,
    ACHAG,
    AVIEW,
    ADDRESS,
    CITY,
    COUNTRY,
    PHONE,
    FAX,
    ACCOUNT,
    BANKCODE,
    BANKMFO,
    BANKNAME,
    BANKADDRESS,
    BANKCITY,
    BANKCOUNTRY,
    TAXID,
    OKULP,
    OKPO,
    LICENCE,
    OKNH,
    SOATO,
    SOOU)
AS
SELECT
  C.ID, C.NAME, COMP.FULLNAME, COMP.COMPANYTYPE, 
  C.LB, C.RB, C.AFULL, C.ACHAG, C.AVIEW,
  C.ADDRESS, C.CITY, C.COUNTRY, C.PHONE, C.FAX,
  AC.ACCOUNT, BANK.BANKCODE, BANK.BANKMFO,
  BANKC.NAME, BANKC.ADDRESS, BANKC.CITY, BANKC.COUNTRY,
  CC.TAXID, CC.OKULP, CC.OKPO, CC.LICENCE, CC.OKNH, CC.SOATO, CC.SOOU

FROM
    GD_CONTACT C
    JOIN GD_COMPANY COMP ON (COMP.CONTACTKEY = C.ID)
    LEFT JOIN GD_COMPANYACCOUNT AC ON COMP.COMPANYACCOUNTKEY = AC.ID
    LEFT JOIN GD_BANK BANK ON AC.BANKKEY = BANK.BANKKEY
    LEFT JOIN GD_COMPANYCODE CC ON COMP.CONTACTKEY = CC.COMPANYKEY
    LEFT JOIN GD_CONTACT BANKC ON BANK.BANKKEY = BANKC.ID;

COMMIT;
/*
 *  Данная таблица содержит список ссылок на компании
 *  по которым ведется учет в программе.
 */
CREATE TABLE gd_ourcompany
(
  companykey   dintkey,
  afull        dsecurity,
  achag        dsecurity,
  aview        dsecurity,

  disabled     dboolean  DEFAULT 0
);

COMMIT;

ALTER TABLE gd_ourcompany ADD CONSTRAINT gd_companykey_ourcompany
  PRIMARY KEY (companykey);

ALTER TABLE gd_ourcompany ADD CONSTRAINT gd_fk_oc_companykey
  FOREIGN KEY (companykey) REFERENCES gd_contact(id) ON UPDATE CASCADE;

COMMIT;

/*  Список компаний, по которым ведется учет */

CREATE VIEW GD_V_OURCOMPANY
(
  ID,
  COMPNAME,
  COMPFULLNAME,
  COMPANYTYPE,
  COMPLB,
  COMPRB,
  AFULL,
  ACHAG,
  AVIEW,
  ADDRESS,
  CITY,
  COUNTRY,
  PHONE,
  FAX,
  ACCOUNT,
  BANKCODE,
  BANKMFO,
  BANKNAME,
  BANKADDRESS,
  BANKCITY,
  BANKCOUNTRY,
  TAXID,
  OKULP,
  OKPO,
  LICENCE,
  OKNH,
  SOATO,
  SOOU
)
AS
SELECT
  C.ID, C.NAME, COMP.FULLNAME, COMP.COMPANYTYPE,
  C.LB, C.RB, O.AFULL, O.ACHAG, O.AVIEW,
  C.ADDRESS, C.CITY, C.COUNTRY, C.PHONE, C.FAX,
  AC.ACCOUNT, BANK.BANKCODE, BANK.BANKMFO,
  BANKC.NAME, BANKC.ADDRESS, BANKC.CITY, BANKC.COUNTRY,
  CC.TAXID, CC.OKULP, CC.OKPO, CC.LICENCE, CC.OKNH, CC.SOATO, CC.SOOU

FROM
  GD_OURCOMPANY O
    JOIN GD_CONTACT C ON (O.COMPANYKEY = C.ID)
    JOIN GD_COMPANY COMP ON (COMP.CONTACTKEY = O.COMPANYKEY)
    LEFT JOIN GD_COMPANYACCOUNT AC ON COMP.COMPANYACCOUNTKEY = AC.ID
    LEFT JOIN GD_BANK BANK ON AC.BANKKEY = BANK.BANKKEY
    LEFT JOIN GD_COMPANYCODE CC ON COMP.CONTACTKEY = CC.COMPANYKEY
    LEFT JOIN GD_CONTACT BANKC ON BANK.BANKKEY = BANKC.ID;

COMMIT;


/*
 *  У каждого пользователя системы есть своя фирма
 *  "по-умолчанию".
 */
CREATE TABLE gd_usercompany
(
  userkey	dintkey,
  companykey	dforeignkey
);

ALTER TABLE gd_usercompany
  ADD CONSTRAINT gd_pk_usercompany PRIMARY KEY (userkey);

ALTER TABLE gd_usercompany ADD CONSTRAINT gd_fk_uc_userkey
  FOREIGN KEY (userkey) REFERENCES gd_user(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_usercompany ADD CONSTRAINT gd_fk_uc_companykey
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany(companykey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;



CREATE TABLE gd_ruid
(
  id         dintkey,
  xid        dintkey,
  dbid       dintkey,
  modified   TIMESTAMP NOT NULL,
  editorkey  dforeignkey,

  CONSTRAINT gd_pk_ruid_id PRIMARY KEY (id),
  CONSTRAINT gd_fk_ruid_ek FOREIGN KEY (editorkey)
    REFERENCES gd_people (contactkey)
    ON UPDATE CASCADE
    ON DELETE SET NULL 
);

ALTER TABLE gd_ruid ADD CONSTRAINT gd_chk_ruid_etalon
  CHECK(
    (id >= 147000000 AND xid >= 147000000)
    OR
    (id < 147000000 AND dbid = 17 AND id = xid)
  );

ALTER TABLE gd_ruid ADD CONSTRAINT gd_uniq_ruid
  UNIQUE (xid, dbid);

COMMIT;

SET TERM ^ ;

CREATE OR ALTER PROCEDURE GD_P_GETRUID(ID INTEGER)
  RETURNS (XID INTEGER, DBID INTEGER)
AS
BEGIN
  XID = NULL;
  DBID = NULL;

  IF (NOT :ID IS NULL) THEN
  BEGIN
    IF (:ID < 147000000) THEN
    BEGIN
      XID = :ID;
      DBID = 17;
    END ELSE
    BEGIN
      SELECT xid, dbid
      FROM gd_ruid
      WHERE id=:ID
      INTO :XID, :DBID;

      IF (XID IS NULL) THEN
      BEGIN
        XID = ID;
        DBID = GEN_ID(gd_g_dbid, 0);

        INSERT INTO gd_ruid(id, xid, dbid, modified, editorkey)
          VALUES(:ID, :XID, :DBID, CURRENT_TIMESTAMP, NULL);
      END
    END
  END

  SUSPEND;
END
^

CREATE EXCEPTION gd_e_invalid_ruid 'Invalid ruid specified'
^

CREATE OR ALTER PROCEDURE GD_P_GETID(XID INTEGER, DBID INTEGER)
  RETURNS (ID INTEGER)
AS
BEGIN
  ID = NULL;

  SELECT id
  FROM gd_ruid
  WHERE xid=:XID AND dbid=:DBID
  INTO :ID;

  IF (ID IS NULL) THEN
  BEGIN
    EXCEPTION gd_e_invalid_ruid 'Invalid ruid. XID = ' ||
      :XID || ', DBID = ' || :DBID || '.';
  END

  SUSPEND;
END
^

SET TERM ; ^

CREATE DOMAIN drelationtype
  AS CHAR(1)
  NOT NULL
  CHECK (VALUE IN ('T', 'V'));

COMMIT;

/*
 *
 * Таблица таблиц. Содержит список всех таблиц
 * базы данных. Необходима для поддержки
 * системы атрибутов.
 *
 */

CREATE TABLE at_relations (
  id              dintkey,

  relationname    dtablename NOT NULL,

  relationtype    drelationtype,                    /* тып: T -- table,  V -- view */


  lname           dname,                            /* локализованное имя                    */
  lshortname      dname,                            /* локализованное короткое имя           */
  description     dtext180,                         /* описание                              */

  afull           dsecurity,                        /* права доступа                         */
  achag           dsecurity,
  aview           dsecurity,

  referencekey    dforeignkey,                      /* ссылка на таблицу,
                                                       по которой устанавливается связь ключевого поля  */
  branchkey       dforeignkey,                      /* ветка вызова из проводника */
  listfield       dfieldname,                       /* поле для отображения */
  extendedfields  dtext254,                         /* поля для расширенного отображения, без пробелов через запятую */

  editiondate     deditiondate,                     /* Дата последнего редактирования */
  editorkey       dintkey,                          /* Ссылка на пользователя, который редактировал запись*/
  reserved        dinteger                          /* зарезервировано для будущих поколений */
);

COMMIT;

ALTER TABLE at_relations ADD CONSTRAINT at_pk_relations_id
  PRIMARY KEY (id);


ALTER TABLE at_relations ADD  CONSTRAINT at_fk_relations_referencekey
 FOREIGN KEY (referencekey) REFERENCES at_relations (id);


ALTER TABLE at_relations ADD CONSTRAINT at_fk_relations_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

CREATE UNIQUE INDEX at_x_relations_rn ON at_relations
  (relationname);

CREATE UNIQUE INDEX at_x_relations_ln ON at_relations
  (lname);

CREATE UNIQUE INDEX at_x_relations_lsn ON at_relations
  (lshortname);

COMMIT;

/*
 * Таблица, где регистрируются все домены, типы полей.
 * Связь 1-к-1 к таблице rdb$fields.
 * Данная таблица необходима нам для локализации,
 * установки прав доступа, установки визуальных настроек.
 *
 */
CREATE DOMAIN dvisible
  AS SMALLINT
  DEFAULT 1
  CHECK ((VALUE IS NULL) OR (VALUE IN (0, 1)));

CREATE DOMAIN dcolwidth
  AS SMALLINT
  DEFAULT 20
  CHECK ((VALUE IS NULL) OR (VALUE >= 0));

COMMIT;

CREATE TABLE at_fields(
  id              dintkey,

  fieldname       dfieldname NOT NULL,              /* наименование домена                 */

  lname           dname,                            /* локализованное наименование         */
  description     dtext180,                         /* комментарий                         */

  reftable        dtablename,                       /* для типа элемент множества */
  reflistfield    dfieldname,                       /* наименование поля, которое выводится при выборе элемента множества */
  refcondition    dtext255,                          /* условие ограничения множества       */

  reftablekey     dforeignkey,                          /* для типа элемент множества */
  reflistfieldkey dforeignkey,

  settable        dtablename,                       /* для типа множество                     */
  setlistfield    dfieldname,                       /*                                        */
  setcondition    dtext255,                          /* условие ограничения множества       */

  settablekey     dforeignkey,                          /* для типа множество                     */
  setlistfieldkey dforeignkey,

  /* Визуальные настройки по умолчанию для полей данного типа */

  alignment       dtextalignment,                   /* выравнивание по умолчанию           */
  format          dtext60,                          /* формат отображения                  */
  visible         dvisible,                         /* видимое поле или нет                */
  colwidth        dcolwidth,                        /* ширина колонки, при отобр. в гриде  */

  readonly        dboolean DEFAULT 0,               /* запрещено ли визуальное редактирование поля */

  gdclassname     dtext60,                          /* наименование класса */
  gdsubtype       dtext60,                          /* подтип класса */

  numeration      dnumerationblob,                  /* хранит значения перечисления */

  disabled        dboolean DEFAULT 0,               /* не используется                     */
  editiondate     deditiondate,                     /* Дата последнего редактирования */
  editorkey       dintkey,                          /* Ссылка на пользователя, который редактировал запись*/
  reserved        dinteger
);

COMMIT;

ALTER TABLE at_fields ADD CONSTRAINT at_pk_fields_id
  PRIMARY KEY (id);

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_rt
  FOREIGN KEY (reftablekey) REFERENCES at_relations (id)
  ON UPDATE CASCADE;

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_st
  FOREIGN KEY (settablekey) REFERENCES at_relations (id)
  ON UPDATE CASCADE;

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE at_fields ADD CONSTRAINT at_chk_fields_numeration
  CHECK ((NUMERATION IS NULL) OR (OCTET_LENGTH(NUMERATION) > 0));

COMMIT;

CREATE UNIQUE INDEX at_x_fields_fn ON at_fields (fieldname);

COMMIT;

/* правило удаления для полей-ссылок */
CREATE DOMAIN ddeleterule AS
VARCHAR(11) CHARACTER SET WIN1251
COLLATE PXW_CYRL;

/*
 *  Таблица хранит поля для каждой таблицы в системе.
 *
 *
 *
 */

CREATE TABLE at_relation_fields(
  id              dintkey,

  fieldname       dfieldname NOT NULL,              /* наименование поля в IB                 */

  relationname    dtablename NOT NULL,              /* ссылка на таблицу                      */
  fieldsource     dfieldname,                       /* ссылка на тип поля (домен)             */

  crosstable      dtablename,                       /* для типа множество                     */
  crossfield      dfieldname,                       /*                                        */


  relationkey     dmasterkey,                       /* ссылка на таблицу                      */
  fieldsourcekey  dintkey,                          /* ссылка на тип поля (домен)             */

  crosstablekey   dforeignkey,                      /* для типа множество                     */
  crossfieldkey   dforeignkey,                      /*                                        */

  lname           dname,                            /* локализованное наименование поля       */
  lshortname      dtext20,                          /* локализованное наименование поля       */
  description     dtext180,                         /* описание назначения поля               */

  /* Визуальные настройки для поля */

  visible         dboolean,                         /* видимое поле                           */
  format          dtext60,                          /* формат вывода                          */
  alignment       dtextalignment,                   /* выравнивание                           */
  colwidth        dsmallint,                        /* ширина поля в гриде                    */

  readonly        dboolean DEFAULT 0,               /* запрещено ли визуальное редактирование поля */

  gdclassname     dtext180,                         /* наименование класса */
  gdsubtype       dtext180,                         /* подтип класса */

  afull           dsecurity,                        /* права доступа                          */
  achag           dsecurity,
  aview           dsecurity,

  objects         dblobtext80_1251,                 /* список бизнес-объектов, для которых это поле вытягивается */
  deleterule      ddeleterule,                      /* правило удаления для полей ссылок */
  editiondate     deditiondate,                     /* Дата последнего редактирования */
  editorkey       dintkey,                          /* Ссылка на пользователя, который редактировал запись*/
  reserved        dinteger                           /* зарезервировано для будущих поколений  */
);

COMMIT;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_pk_relation_fields_id
  PRIMARY KEY (id);

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_rn
  FOREIGN KEY (relationkey) REFERENCES at_relations (id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_fs
  FOREIGN KEY (fieldsourcekey) REFERENCES at_fields (id) ON UPDATE CASCADE;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_ct
  FOREIGN KEY (crosstablekey) REFERENCES at_relations (id) ON UPDATE CASCADE;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_cf
  FOREIGN KEY (crossfieldkey) REFERENCES at_relation_fields (id) ON UPDATE CASCADE;

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

CREATE UNIQUE INDEX at_x_relation_fields_fr ON at_relation_fields
  (fieldname, relationname);

CREATE INDEX at_x_relation_fields_rn ON at_relation_fields
   (relationname);

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_rlf
  FOREIGN KEY (reflistfieldkey) REFERENCES at_relation_fields (id) 
  ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE at_fields ADD CONSTRAINT at_fk_fields_slf
  FOREIGN KEY (setlistfieldkey) REFERENCES at_relation_fields (id) 
  ON UPDATE CASCADE ON DELETE SET NULL;


COMMIT;

/*
 *
 *  Транзакции необходимы, если операции с метаданными
 *  протекают при более чем с одним подлючением.
 *
 */

CREATE TABLE at_transaction(
  trkey           dintkey,                           /* ключ транзакции */
  numorder        dsmallint NOT NULL,                /* номер по порядку */
  script          dscript,                         /* скрипт, который нужно выполнить */
  successfull     dboolean DEFAULT 0                 /* удачно ли прошла операция */
);

ALTER TABLE at_transaction ADD CONSTRAINT at_pk_transaction_tr
  PRIMARY KEY (trkey, numorder);

COMMIT;

/*
 *
 *  Для каждого поля типа множество необходимо создать промежуточную
 *  таблицу и тригеры.
 *  Для генерации имен этих тригеров мы будем использовать генератор.
 *
 */

CREATE GENERATOR gd_g_triggercross;
SET GENERATOR gd_g_triggercross TO 10;

/*
 *
 *  При изменении содержимого таблиц ATFIELD, AT_RELATION
 *  T_RELATION_FIELD изменяем этот генератор.
 *  Генератор необходим для отслеживания версий атрибутов
 *
 */

CREATE GENERATOR gd_g_attr_version;
SET GENERATOR gd_g_attr_version TO 12;

COMMIT;

SET TERM ^ ;


/*
 *
 *  Триггеры для таблицы полей
 *
 */


CREATE TRIGGER at_bi_fields FOR at_fields
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

END
^

CREATE TRIGGER at_ai_fields FOR at_fields
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_au_fields FOR at_fields
  AFTER UPDATE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_ad_fields FOR at_fields
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_fields5 FOR at_fields
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER at_bu_fields5 FOR at_fields
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

/*
 *
 *  Триггеры для таблицы таблиц
 *
 */

CREATE TRIGGER at_bi_relations FOR at_relations
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

END
^

CREATE TRIGGER at_ai_relations FOR at_relations
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_au_relations FOR at_relations
  AFTER UPDATE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_ad_relations FOR at_relations
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_relations5 FOR at_relations
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER at_bu_relations5 FOR at_relations
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

/*
 *
 *  Триггеры для таблицы полей таблиц
 *
 */

CREATE OR ALTER TRIGGER at_bi_rf FOR at_relation_fields
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);
END
^

CREATE OR ALTER TRIGGER at_biu_rf FOR at_relation_fields
  BEFORE INSERT OR UPDATE
  POSITION 1000
AS
BEGIN
  SELECT relationname FROM at_relations WHERE id = NEW.relationkey
  INTO NEW.relationname;
  
  IF (NEW.crossfield = '') THEN 
  BEGIN  
    NEW.crossfield = NULL;
    NEW.editiondate = CURRENT_TIMESTAMP(0);
  END
  
  IF (NEW.crosstable = '') THEN 
  BEGIN
    NEW.crosstable = NULL;
    NEW.editiondate = CURRENT_TIMESTAMP(0);
  END  
  
  NEW.objects = TRIM(NEW.objects);
  
  IF (NEW.objects = '' OR NEW.objects LIKE 'TgdcBase%' OR NEW.objects LIKE '(Blob)%') THEN
  BEGIN
    NEW.objects = NULL;
    NEW.editiondate = CURRENT_TIMESTAMP(0);
  END
END
^

CREATE OR ALTER TRIGGER at_aiud_relation_field FOR at_relation_fields
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_relation_fields5 FOR at_relation_fields
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER at_bu_relation_fields5 FOR at_relation_fields
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

/*
 *
 * Процедура, осуществляющая формирование строки
 * форматов таблиц базы данных
 * Расчитано 6400 таблиц как минимум.
 *
 */

/*06.09.02 Удалить за ненадобностью */
CREATE PROCEDURE GD_P_RELATION_FORMATS
RETURNS
  (
    RELATION_ID VARCHAR(32000),
    RELATION_FORMAT VARCHAR(32000)
  )
AS
  DECLARE VARIABLE REL_ID INTEGER;
  DECLARE VARIABLE REL_FORMAT INTEGER;

BEGIN
  RELATION_ID = '';
  RELATION_FORMAT = '';

  FOR
    SELECT
      RDB$RELATION_ID, RDB$FORMAT
    FROM
      RDB$RELATIONS
    WHERE
      RDB$SYSTEM_FLAG = 0
    ORDER BY
      RDB$RELATION_ID
  INTO
    :REL_ID, :REL_FORMAT
  DO BEGIN
    RELATION_ID = RELATION_ID || '_' || CAST(REL_ID AS VARCHAR(4));
    RELATION_FORMAT = RELATION_FORMAT || '_' || CAST(REL_FORMAT AS VARCHAR(4));
  END

  SUSPEND;
END
^


SET TERM ; ^

COMMIT;


CREATE DOMAIN ddescription AS
BLOB SUB_TYPE 1 SEGMENT SIZE 80 CHARACTER SET WIN1251 ;

CREATE DOMAIN dexceptionname AS
VARCHAR(31) CHARACTER SET WIN1251
NOT NULL
COLLATE PXW_CYRL;

CREATE DOMAIN dmessage AS
VARCHAR(78) CHARACTER SET WIN1251
COLLATE PXW_CYRL;

COMMIT;

/* Таблица исключений */
CREATE TABLE at_exceptions (
  id               dintkey NOT NULL, /* идентификатор */
  exceptionname    dexceptionname    /* наименование исключения */
                   NOT NULL collate PXW_CYRL,
  lmessage         dtext80          /* локализованное сообщение */
                   collate PXW_CYRL,
  editiondate      deditiondate,    /* Дата последнего редактирования */
  editorkey        dintkey          /* Ссылка на пользователя, который редактировал запись*/
                   );

COMMIT;

ALTER TABLE at_exceptions ADD CONSTRAINT at_pk_exceptions PRIMARY KEY(id);

CREATE UNIQUE INDEX at_x_exceptions_en ON at_exceptions
   (exceptionname);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER at_ad_exceptions FOR at_exceptions
AFTER DELETE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_ai_exceptions FOR at_exceptions
AFTER INSERT POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_au_exceptions FOR at_exceptions
AFTER UPDATE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_exceptions FOR at_exceptions
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

END
^

CREATE TRIGGER at_bi_exceptions5 FOR at_exceptions
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER at_bu_exceptions5 FOR at_exceptions
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^
SET TERM ; ^

COMMIT;

/*Таблица чеков */
CREATE TABLE AT_CHECK_CONSTRAINTS (
  id                dintkey,
  checkname         dtablename NOT NULL,
  msg               dtext80 COLLATE PXW_CYRL,
  editiondate       deditiondate
);

COMMIT;

ALTER TABLE AT_CHECK_CONSTRAINTS ADD CONSTRAINT AT_PK_CHECK_CONSTRAINTS 
  PRIMARY KEY (ID);

CREATE UNIQUE INDEX AT_X_CONSTRAINTS_IN 
  ON AT_CHECK_CONSTRAINTS (CHECKNAME);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER AT_AIUD_CHECK_CONSTRAINTS FOR AT_CHECK_CONSTRAINTS
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER AT_BI_CHECK_CONSTRAINTS FOR AT_CHECK_CONSTRAINTS
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE at_generators (
  id               dintkey,
  generatorname    dtablename NOT NULL,
  editiondate      deditiondate,
  editorkey        dintkey
);

COMMIT;

ALTER TABLE at_generators ADD CONSTRAINT at_pk_generators
  PRIMARY KEY(id);

ALTER TABLE AT_GENERATORS ADD CONSTRAINT AT_FK_GENERATORS_EDITORKEY
  FOREIGN KEY (EDITORKEY) REFERENCES GD_PEOPLE (CONTACTKEY) ON UPDATE CASCADE;

CREATE UNIQUE INDEX at_x_generators_en
  ON at_generators (generatorname);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER at_aiud_generators FOR at_generators
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_generators FOR at_generators
  ACTIVE
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER at_bu_generators FOR at_generators
  ACTIVE
  BEFORE UPDATE
  POSITION 27000
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

CREATE DOMAIN dindexname AS VARCHAR(31)
  CHARACTER SET WIN1251 COLLATE WIN1251;

COMMIT;

CREATE DOMAIN dprocedurename AS VARCHAR(31)
  CHARACTER SET WIN1251 COLLATE WIN1251;

/*Таблица для сторед-процедур*/
CREATE TABLE AT_PROCEDURES (
  id              dintkey NOT NULL,        /* идентификатор */
  procedurename   dprocedurename NOT NULL  /* наименование процедуры */
                  collate WIN1251,
  proceduresource dblobtext80_1251,        /* хранит тело процедуры. Используется
                                              только при сохранении в поток
                                             (т.к. мы не можем сохранить нормально параметры процедуры ) */
  editiondate     deditiondate,            /* Дата последнего редактирования */
  editorkey       dintkey                  /* Ссылка на пользователя, который редактировал запись*/
);

ALTER TABLE at_procedures ADD CONSTRAINT pk_at_procedures PRIMARY KEY (id);

CREATE UNIQUE INDEX at_x_procedures_pn ON at_procedures
   (procedurename);

ALTER TABLE at_procedures ADD CONSTRAINT at_fk_procedures_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER at_ad_procedures FOR at_procedures ACTIVE
AFTER DELETE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_ai_procedures FOR at_procedures ACTIVE
AFTER INSERT POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_au_procedures FOR at_procedures ACTIVE
AFTER UPDATE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER at_bi_procedures FOR at_procedures ACTIVE
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

END
^

CREATE TRIGGER at_bi_procedures5 FOR at_procedures
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER at_bu_procedures5 FOR at_procedures
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE at_indices(
  id                  dintkey,                /* идентификатор */
  indexname           dindexname              /* наименование индекса */
                      NOT NULL,

  relationname        dtablename              /* наименование таблицы */
                      NOT NULL,

  fieldslist          dtext255,               /* список полей */

  relationkey         dmasterkey              /* идентификатор таблицы */
                      NOT NULL,

  unique_flag         dboolean DEFAULT 0,     /* 0-неуникальный индекс, 1-уникальный */

  index_inactive      dboolean DEFAULT 0,     /* 0-активный индекс, 1-неактивный*/
  editiondate         deditiondate,           /* Дата последнего редактирования */
  editorkey           dintkey                 /* Ссылка на пользователя, который редактировал запись*/
);

COMMIT;

ALTER TABLE at_indices ADD CONSTRAINT at_pk_indices PRIMARY KEY(id);

ALTER TABLE at_indices ADD CONSTRAINT at_fk_indices_relationkey FOREIGN KEY(relationkey)
REFERENCES at_relations(id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX at_x_indices_rn ON at_indices
   (relationname);

CREATE UNIQUE INDEX at_x_indices_in ON at_indices
   (indexname);

ALTER TABLE at_indices ADD CONSTRAINT at_fk_indices_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;


SET TERM ^ ;

/* Triggers definition */



CREATE TRIGGER at_ad_indices FOR at_indices
AFTER DELETE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_au_indices FOR at_indices
AFTER INSERT POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_ai_indices FOR at_indices
AFTER UPDATE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_bi_indices FOR at_indices
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (g_s_trim(NEW.relationname, ' ') = '') THEN
  BEGIN
    SELECT relationname FROM at_relations WHERE id = NEW.relationkey
    INTO NEW.relationname;
  END
END
^

CREATE TRIGGER at_bi_indices5 FOR at_indices
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER at_bu_indices5 FOR at_indices
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^
COMMIT;


CREATE DOMAIN dtriggername AS
VARCHAR(31) CHARACTER SET WIN1251
COLLATE WIN1251;

CREATE TABLE at_triggers(
  id                  dintkey,                /* идентификатор */
  triggername         dtriggername            /* наименование триггера */
                      NOT NULL,

  relationname        dtablename              /* наименование таблицы */
                      NOT NULL,

  relationkey         dmasterkey              /* идентификатор таблицы */
                      NOT NULL,

  trigger_inactive    dboolean DEFAULT 0,     /* 0-активный индекс, 1-неактивный*/
  editiondate         deditiondate,           /* Дата последнего редактирования */
  editorkey           dintkey                 /* Ссылка на пользователя, который редактировал запись*/

);

COMMIT;

ALTER TABLE at_triggers ADD CONSTRAINT at_pk_triggers PRIMARY KEY(id);

ALTER TABLE at_triggers ADD CONSTRAINT at_fk_trigger_relationkey FOREIGN KEY(relationkey)
REFERENCES at_relations(id) ON UPDATE CASCADE ON DELETE CASCADE;

CREATE INDEX at_x_triggers_rn ON at_triggers
   (relationname);

ALTER TABLE at_triggers ADD CONSTRAINT at_fk_triggers_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

CREATE UNIQUE INDEX at_x_triggers_tn ON at_triggers
   (triggername);

COMMIT;

SET TERM ^ ;

/* Triggers definition */



CREATE TRIGGER at_ad_triggers FOR at_triggers
AFTER DELETE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_ai_triggers FOR at_triggers
AFTER INSERT POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_au_triggers FOR at_triggers
AFTER UPDATE POSITION 0
AS
  DECLARE VARIABLE VERSION INTEGER;
BEGIN
  VERSION = GEN_ID(gd_g_attr_version, 1);
END
^


CREATE TRIGGER at_bi_triggers FOR at_triggers
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id =  GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (g_s_trim(NEW.relationname, ' ') = '') THEN
  BEGIN
    SELECT relationname FROM at_relations WHERE id = NEW.relationkey
    INTO NEW.relationname;
  END
END
^

CREATE TRIGGER at_bi_triggers5 FOR at_triggers
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER at_bu_triggers5 FOR at_triggers
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

COMMIT ^



/*@DECLARE MACRO ATTR_TRG(%TableName%, %TableAlias%)

CREATE TRIGGER gd_ai_%TableAlias% FOR %TableName%
  AFTER INSERT
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER gd_au_%TableAlias% FOR %TableName%
  AFTER UPDATE
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER gd_ad_%TableAlias% FOR %TableName%
  AFTER DELETE
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^

END MACRO*/

/*@UNFOLD MACRO ATTR_TRG(RDB$FIELDS, RDB_FIELDS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_FIELDS FOR RDB$FIELDS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_FIELDS FOR RDB$FIELDS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_FIELDS FOR RDB$FIELDS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$RELATIONS, RDB_RELATIONS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_RELATIONS FOR RDB$RELATIONS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_RELATIONS FOR RDB$RELATIONS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_RELATIONS FOR RDB$RELATIONS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@.CALL MACRO ATTR_TRG(RDB$RELATION_FIELDS, RDB_RELATION_FIELDS)*/
/*@UNFOLD MACRO ATTR_TRG(RDB$TRIGGERS, RDB_TRIGGERS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_TRIGGERS FOR RDB$TRIGGERS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_TRIGGERS FOR RDB$TRIGGERS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_TRIGGERS FOR RDB$TRIGGERS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$PROCEDURES, RDB_PROCEDURES)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_PROCEDURES FOR RDB$PROCEDURES
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_PROCEDURES FOR RDB$PROCEDURES
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_PROCEDURES FOR RDB$PROCEDURES
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$PROCEDURE_PARAMETERS, RDB_PROCEDURE_PARAMETERS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_PROCEDURE_PARAMETERS FOR RDB$PROCEDURE_PARAMETERS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_PROCEDURE_PARAMETERS FOR RDB$PROCEDURE_PARAMETERS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_PROCEDURE_PARAMETERS FOR RDB$PROCEDURE_PARAMETERS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$INDICES, RDB_INDICES)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_INDICES FOR RDB$INDICES
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_INDICES FOR RDB$INDICES
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_INDICES FOR RDB$INDICES
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/
/*@UNFOLD MACRO ATTR_TRG(RDB$INDEX_SEGMENTS, RDB_INDEX_SEGMENTS)*/
/*M*/
/*M*/CREATE TRIGGER gd_ai_RDB_INDEX_SEGMENTS FOR RDB$INDEX_SEGMENTS
/*M*/  AFTER INSERT
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_au_RDB_INDEX_SEGMENTS FOR RDB$INDEX_SEGMENTS
/*M*/  AFTER UPDATE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*M*/CREATE TRIGGER gd_ad_RDB_INDEX_SEGMENTS FOR RDB$INDEX_SEGMENTS
/*M*/  AFTER DELETE
/*M*/  POSITION 1000
/*M*/AS
/*M*/  DECLARE VARIABLE I INTEGER;
/*M*/BEGIN
/*M*/  I = GEN_ID(gd_g_attr_version, 1);
/*M*/END
/*M*/^
/*M*/
/*END MACRO*/


CREATE TRIGGER gd_ai_rdb_relation_fields FOR rdb$relation_fields
  AFTER INSERT
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^
/*  При подключении IBExpert-ом, IBExpert пытается изменить поле
  rdb$description таблицы rdb$database вызывая при этом триггер и
  соответвсенно, увеличивая генератор */
CREATE TRIGGER gd_au_rdb_relation_fields FOR rdb$relation_fields
  AFTER UPDATE
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  IF ((NEW.rdb$field_name <> OLD.rdb$field_name)
    OR (NEW.rdb$relation_name <> OLD.rdb$relation_name))
  THEN
    I = GEN_ID(gd_g_attr_version, 1);
END
^

CREATE TRIGGER gd_ad_rdb_relation_fields FOR rdb$relation_fields
  AFTER DELETE
  POSITION 1000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_attr_version, 1);
END
^

SET TERM ; ^

COMMIT;

/*
 *
 *   FKManager
 *
 */

CREATE EXCEPTION gd_e_fkmanager 'Exception in FK manager code';

CREATE DOMAIN d_fk_metaname AS CHAR(31) CHARACTER SET unicode_fss;

CREATE TABLE gd_ref_constraints (
  id               dintkey,
  constraint_name  d_fk_metaname UNIQUE,
  const_name_uq    d_fk_metaname,
  match_option     char(7)  character set none,
  update_rule      char(11) character set none,
  delete_rule      char(11) character set none,

  constraint_rel   d_fk_metaname,
  constraint_field d_fk_metaname,
  ref_rel          d_fk_metaname,
  ref_field        d_fk_metaname,

  ref_state        char(8) character set none,
  ref_next_state   char(8) character set none,

  constraint_rec_count COMPUTED BY ((
    SELECT
      iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5))
    FROM
      rdb$indices i
      JOIN rdb$relation_constraints rc
        ON rc.rdb$index_name = i.rdb$index_name
      WHERE
        rc.rdb$relation_name = constraint_rel
        AND rc.rdb$constraint_type = 'PRIMARY KEY')),

  constraint_uq_count COMPUTED BY ((
    SELECT
      iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5))
    FROM
      rdb$indices i
      JOIN rdb$index_segments iseg
        ON iseg.rdb$index_name = i.rdb$index_name
      JOIN rdb$relation_constraints rc
        ON rc.rdb$index_name = i.rdb$index_name
    WHERE
      iseg.rdb$field_name = constraint_field
      AND i.rdb$segment_count = 1
      AND rc.rdb$constraint_name = constraint_name
      AND rc.rdb$constraint_type = 'FOREIGN KEY'
  )),

  ref_rec_count COMPUTED BY ((
    SELECT
      iif(i.rdb$statistics = 0, 0, Trunc(1/i.rdb$statistics + 0.5))
    FROM
      rdb$indices i
      JOIN rdb$relation_constraints rc
        ON rc.rdb$index_name = i.rdb$index_name
    WHERE
      rc.rdb$relation_name = ref_rel
      AND rc.rdb$constraint_type = 'PRIMARY KEY')),

  CONSTRAINT gd_pk_ref_constraint PRIMARY KEY (id),
  CONSTRAINT gd_chk1_ref_contraint CHECK (ref_state IN ('ORIGINAL', 'TRIGGER')),
  CONSTRAINT gd_chk2_ref_contraint CHECK (ref_next_state IN ('ORIGINAL', 'TRIGGER'))
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_ref_constraints FOR gd_ref_constraints
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE OR ALTER TRIGGER gd_bd_ref_constraints FOR gd_ref_constraints
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.ref_state <> 'ORIGINAL') THEN
    EXCEPTION gd_e_fkmanager 'Ref constraint is not in ORIGINAL state';
END
^

SET TERM ; ^

CREATE TABLE gd_ref_constraint_data (
  constraintkey    dintkey,
  value_data       INTEGER,

  CONSTRAINT gd_pk_ref_constraint_data PRIMARY KEY (value_data, constraintkey),
  CONSTRAINT gd_fk_ref_constraint_data FOREIGN KEY (constraintkey)
    REFERENCES gd_ref_constraints (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_biu_ref_constraint_data FOR gd_ref_constraint_data
  BEFORE INSERT OR UPDATE
  POSITION 0
AS
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'REF_CONSTRAINT_UNLOCK') IS DISTINCT FROM '1') THEN
    EXCEPTION gd_e_fkmanager 'Constraint data is locked';
END
^

SET TERM ; ^

COMMIT;

CREATE GLOBAL TEMPORARY TABLE gd_object_dependencies (
  sessionid         dintkey,
  seqid             dintkey,
  masterid          dintkey,
  reflevel          dinteger_notnull,
  relationname      dtablename NOT NULL,
  fieldname         dfieldname NOT NULL,
  crossrelation     dboolean_notnull,
  refobjectid       dintkey,
  refobjectname     dname,
  refrelationname   dname,
  refclassname      dname,
  refsubtype        dname,
  refeditiondate    TIMESTAMP,

  CONSTRAINT gd_pk_object_dependencies PRIMARY KEY
    (sessionid, seqid)
)
  ON COMMIT DELETE ROWS;

COMMIT;





/*

  Copyright (c) 2000-2014 by Golden Software of Belarus

  Script

    gd_const.sql

  Abstract

    Константы

  Author

    Anton Smirnov (15.09.2001)

  Revisions history

    Initial  15.09.2001  SAI    Initial version

  Status

    Draft

*/

/* 1 бит - 1 - периодичная */
/* 2 бит - 1 - привязан к пользователю */
/* 3 бит - 1 - привязан к клиенту */

CREATE DOMAIN dconsttype
  AS SMALLINT
  DEFAULT 0
  NOT NULL
  CHECK ((VALUE >= 0) AND (VALUE <= 7));

COMMIT;

/* Справочник переменных */

CREATE TABLE gd_const
(
  id               dintkey,
  name             dname,
  comment          dtext120,
  consttype        dconsttype,
  datatype         CHAR(1), /* NULL, S -- string, N -- numeric, D -- Date, Time */

  editorkey        dforeignkey,     /* Кто создал или изменил запись */
  editiondate      deditiondate,    /* Когда создана или изменена запись */

  afull            dsecurity,
  achag            dsecurity,
  aview            dsecurity,

  reserved         dreserved
);

ALTER TABLE gd_const
  ADD CONSTRAINT gd_pk_const PRIMARY KEY (id);

ALTER TABLE gd_const ADD CONSTRAINT gd_fk_editor_const
  FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

CREATE UNIQUE INDEX gd_x_const_name ON gd_const
  /*COMPUTED BY (UPPER(name));*/
  (name);

/*ALTER TABLE gd_const ADD CONSTRAINT gd_uq_name_const
  UNIQUE (name);*/

/* Значения переменных */

CREATE TABLE gd_constvalue
(
  id            dintkey,
  userkey       dforeignkey,
  companykey    dforeignkey,
  constkey      dintkey,
  constdate     date,
  constvalue    dtext120,
  editorkey     dforeignkey,     /* Кто создал или изменил запись */
  editiondate   deditiondate    /* Когда создана или изменена запись */
);

ALTER TABLE gd_constvalue
  ADD CONSTRAINT gd_pk_constvalue PRIMARY KEY (id);

ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_user_constvalue
  FOREIGN KEY (userkey) REFERENCES gd_contact(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_oc_constvalue
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany(companykey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_vn_constvalue
  FOREIGN KEY (constkey) REFERENCES gd_const(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_constvalue ADD CONSTRAINT gd_fk_ek_constvalue
  FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
  ON DELETE SET NULL
  ON UPDATE CASCADE;

SET TERM ^ ;

CREATE EXCEPTION gd_e_invalidconstname 'Constant already exists'
^

CREATE TRIGGER gd_bi_const FOR gd_const
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (EXISTS (SELECT * FROM gd_const WHERE UPPER(name) = UPPER(NEW.name))) THEN
  BEGIN
    EXCEPTION gd_e_invalidconstname;
  END
END
^

CREATE TRIGGER gd_bu_const FOR gd_const
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_const WHERE UPPER(name) = UPPER(NEW.name)
    AND id <> NEW.id)) THEN
  BEGIN
    EXCEPTION gd_e_invalidconstname;
  END
END
^

CREATE TRIGGER gd_bi_constvalue FOR gd_constvalue
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE OR ALTER TRIGGER gd_aiu_constvalue FOR gd_constvalue
  AFTER INSERT OR UPDATE
  POSITION 0
AS
  DECLARE VARIABLE F DOUBLE PRECISION;
  DECLARE VARIABLE T TIMESTAMP;
  DECLARE VARIABLE D CHAR(1);
BEGIN
  SELECT datatype FROM gd_const
  WHERE id = NEW.constkey
  INTO :D;

  IF (:D = 'D') THEN
    T = CAST(NEW.constvalue AS TIMESTAMP);
  IF (:D = 'N') THEN
    F = CAST(NEW.constvalue AS DOUBLE PRECISION);
END
^

SET TERM ; ^

COMMIT;

/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    gd_script.sql

  Abstract

    An Interbase script for script control.

  Author

    Romanovski Denis (01.08.00)

  Revisions history

    Initial  01.08.00  Dennis    Initial version

  Status

*/

/****************************************************

   Таблица для хранения пользователей

*****************************************************/

/*
  DFUNCTIONTYPE
  домен для хранения типа функции:
  это Макрос или Обработчик события (Event)
*/
CREATE DOMAIN DFUNCTIONTYPE
  AS CHAR(1)
  CHECK ((VALUE IS NULL) or (VALUE IN ('E', 'M')));

CREATE DOMAIN DINHERITEDRULE AS 
  SMALLINT 
  CHECK (VALUE IN (0, 1, 3) OR VALUE IS NULL);
  
CREATE TABLE gd_function
(
  id               dintkey,                     /* Первичный ключ */
  module           dtext40,                     /* Модуль */
  language         dtext10,                     /* Язык программирования */
  name             dlongname,                   /* Наименование функции */
  comment          dtext180,                    /* Комментарий к функции */
  script           dscript,                     /* Текст функции */
  displayscript    dscript,                     /* Видимый текст функции *//*Данное поле можно удалить*/

  afull            dsecurity,                   /* Права доступа полные *//*Данное поле можно удалить*/
  achag            dsecurity,                   /* Права доступа на изменения *//*Данное поле можно удалить*/
  aview            dsecurity,                   /* права доступа на просмотр *//*Данное поле можно удалить*/
  modifydate       dtimestamp,                  /*Данное поле можно удалить*/

  testresult       dblob80,                     /* Поле для отчетов. Для хранения пустой структуры. */
  ownername        dtext40,                     /*Данное поле можно удалить*/
  functiontype     dfunctiontype,               /*Данное поле можно удалить*/
  event            dtext40,

  localname        dtext40,                      /* Название функции на русском языке *//*Данное поле можно удалить*/
  publicfunction   dboolean DEFAULT 1 NOT NULL,  /* Внутрення или внешняя функция *//*Данное поле можно удалить*/
  shortcut         dtext10,                       /* Горячая клавиша *//*Данное поле можно удалить*/
  groupname        dtext20,                      /* Название группы *//*Данное поле можно удалить*/

  modulecode       dinteger NOT NULL,            /* код модуля */
  enteredparams    dblob80,
  reserved         dinteger,                      /* Зарезервировано */
  inheritedrule    dinheritedrule,                /*Поле для событий указывает на момент
                                                  перекрытия. Оно может принимать три значения:
                                                    0 - перекрывать полностью;
                                                    1 - вызывать родительский обработчик до скрипт-функции;
                                                    2 - вызывать обработчик после выполнения скрипт-функции.*//*Данное поле можно удалить*/
/*  preparedbyparser dboolean,                      если TRUE то скрипт функции был подготовлен парсером
                                                   данное поле уже не нужно */
  breakpoints      dblob80,                        /* Поле хранит информацию о точках прерывания*/
  usedebuginfo     dboolean,                       /* Указывает на необходимость использования отладчика при запуске функции*//*Данное поле можно удалить*/
  editorstate      dblob80,                        /* Хранится положение курсора редактора, закладки и т.п.*/
  editiondate      deditiondate,                   /* Дата последнего редактирования */
  editorkey        dintkey                         /* Ссылка на пользователя, который редактировал запись*/
);

ALTER TABLE gd_function ADD CONSTRAINT gd_pk_function
  PRIMARY KEY (id);

/* пакуль што мы падтрымлiваем 1 мову */
ALTER TABLE gd_function ADD CONSTRAINT gd_chk_function_language
  CHECK (language IN ('JScript', 'VBScript'));

/* назва функцыi павiнна быць унiкальнай */
/* у межах аднаго модулю                 */
CREATE UNIQUE INDEX gd_x_function_name ON gd_function
  (name, modulecode);

CREATE INDEX gd_x_function_module ON gd_function
  (module);

ALTER TABLE gd_function ADD CONSTRAINT gd_fk_function_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

CREATE GENERATOR gd_g_functionch;
SET GENERATOR gd_g_functionch TO 1;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_function_ad_ch FOR gd_function
AFTER DELETE POSITION 32000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_functionch, 1);
END
^

CREATE TRIGGER gd_bi_function FOR gd_function
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

/*  NEW.modifydate = 'NOW';*/

  IF (NEW.modulecode IS NULL) then
    NEW.modulecode = 1010001;/*ид апликатион*/
  IF (NEW.publicfunction IS NULL) then
    NEW.publicfunction = 0;
END
^


CREATE TRIGGER gd_bu_function FOR gd_function
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
/*  NEW.modifydate = 'NOW';*/
  IF (NEW.modulecode IS NULL) then BEGIN
    IF (OLD.modulecode IS NULL) THEN
      NEW.modulecode = 1010001;
    ELSE
      NEW.modulecode = OLD.modulecode;            
  END
  IF (NEW.publicfunction IS NULL) then BEGIN
    IF (OLD.publicfunction IS NULL) THEN          
      NEW.publicfunction = 0;                     
    ELSE                                          
      NEW.publicfunction = OLD.publicfunction;    
  END
END
^  

CREATE TRIGGER gd_bi_function5 FOR gd_function
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER gd_bu_function5 FOR gd_function
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE gd_function_log (
  id          dintkey,
  functionkey dintkey,
  revision    INTEGER,
  script      dscript,
  editorkey   dintkey,
  editiondate deditiondate
);

ALTER TABLE gd_function_log ADD CONSTRAINT gd_pk_function_log_id
  PRIMARY KEY (id);

ALTER TABLE gd_function_log ADD CONSTRAINT gd_fk_function_log_fk
  FOREIGN KEY (functionkey) REFERENCES gd_function (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_function_log ADD CONSTRAINT gd_fk_function_log_ek
  FOREIGN KEY (editorkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

SET TERM ^ ;

CREATE TRIGGER gd_bi_function_log FOR gd_function_log
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE R INTEGER;
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  R = 0;
  SELECT MAX(revision) FROM gd_function_log WHERE functionkey = NEW.functionkey
    INTO :R;
  NEW.revision = COALESCE(:R, 0) + 1;    
END
^

CREATE TRIGGER gd_bu_function_log FOR gd_function_log
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (OLD.revision <> COALESCE(NEW.revision, 0)) THEN
    NEW.revision = OLD.revision;
END
^

CREATE TRIGGER gd_function_au_ch FOR gd_function
AFTER UPDATE POSITION 32000
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  I = GEN_ID(gd_g_functionch, 1);

  IF ((OLD.EDITIONDATE <> NEW.EDITIONDATE) AND (OLD.SCRIPT <> NEW.SCRIPT)) THEN
  BEGIN
    IF (NOT EXISTS (SELECT L.ID FROM GD_FUNCTION_LOG L WHERE L.FUNCTIONKEY = OLD.ID)) THEN
    BEGIN
      INSERT INTO GD_FUNCTION_LOG (functionkey, script, editorkey, editiondate)
        VALUES (OLD.ID, OLD.SCRIPT, OLD.EDITORKEY, OLD.EDITIONDATE);

      INSERT INTO GD_FUNCTION_LOG (functionkey, script, editorkey, editiondate)
        VALUES (NEW.ID, NEW.SCRIPT, NEW.EDITORKEY, NEW.EDITIONDATE);
    END ELSE
      INSERT INTO GD_FUNCTION_LOG (functionkey, script, editorkey, editiondate)
        VALUES (NEW.ID, NEW.SCRIPT, NEW.EDITORKEY, NEW.EDITIONDATE);
  END
END
^

SET TERM ; ^

COMMIT;
CREATE EXCEPTION GD_E_DOCUMENTTYPE_RUID
  'Document of this type already exists!';

CREATE EXCEPTION GD_E_DOCUMENTTYPE_NAME
  'Document of this type already exists!';

/*
 *  Значение позиции типового
 *  документа:
 *  B - branch (ветка)
 *  D - document (документ)
 *
 */

CREATE DOMAIN ddocumenttype
  AS CHAR(1)
  NOT NULL
  CHECK (VALUE IN ('B', 'D'));

/* Тип документа */
CREATE TABLE gd_documenttype
(
  id                      dintkey,
  parent                  dparent,
  lb                      dlb,
  rb                      drb,

  name                    dname,
  description             dtext180,

  classname               dclassname,
  documenttype            ddocumenttype DEFAULT 'D',

  options                 DBLOB1024,
  headerrelkey            dforeignkey,
  linerelkey              dforeignkey,

  afull                   dsecurity,
  achag                   dsecurity,
  aview                   dsecurity,

  editiondate             deditiondate,

  disabled                dboolean DEFAULT 0,
  ruid                    druid,                     /* Хранит руид документа  */
  branchkey               dforeignkey,               /* Ветка в исследователе */
  reportgroupkey          dforeignkey,               /* Группа отчетов */
  reserved                dreserved,
  iscommon                dboolean DEFAULT 0,
  ischecknumber           SMALLINT DEFAULT 0,        /* Дублирование номеров: 0 -- не проверять, 1 -- всегда, 2 -- в теч года, 3 -- в теч м-ца */
  headerfunctionkey       dforeignkey,
  headerfunctiontemplate  dblob80,
  linefunctionkey         dforeignkey,
  linefunctiontemplate    dblob80,

  CONSTRAINT gd_chck_icn_documenttype CHECK (ischecknumber BETWEEN 0 AND 3)
);

COMMIT;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_pk_documenttype
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_parent
  FOREIGN KEY (parent) REFERENCES gd_documenttype(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_header
  FOREIGN KEY (headerrelkey) REFERENCES at_relations (id)
  ON UPDATE CASCADE;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_line
  FOREIGN KEY (linerelkey) REFERENCES at_relations (id)
  ON UPDATE CASCADE;

ALTER TABLE GD_DOCUMENTTYPE ADD CONSTRAINT FK_GD_DOCUMENTTYPE_HF
  FOREIGN KEY (HEADERFUNCTIONKEY) REFERENCES GD_FUNCTION (ID)
  ON DELETE SET NULL
  ON UPDATE CASCADE;

ALTER TABLE GD_DOCUMENTTYPE ADD CONSTRAINT FK_GD_DOCUMENTTYPE_LF
  FOREIGN KEY (LINEFUNCTIONKEY) REFERENCES GD_FUNCTION (ID)
  ON DELETE SET NULL
  ON UPDATE CASCADE;
COMMIT;

CREATE INDEX gd_x_documenttype_ruid
  ON gd_documenttype(ruid);

CREATE UNIQUE INDEX gd_x_documenttype_name ON gd_documenttype
  (name);

COMMIT;

CREATE EXCEPTION gd_e_cannotchangebranch 'Can not change branch!';

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_au_documenttype FOR gd_documenttype
  ACTIVE
  AFTER UPDATE
  POSITION 20000
AS
  DECLARE VARIABLE new_root dintkey;
  DECLARE VARIABLE old_root dintkey;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    SELECT id FROM gd_documenttype
    WHERE parent IS NULL AND lb <= NEW.lb AND rb >= NEW.rb
    INTO :new_root;

    SELECT id FROM gd_documenttype
    WHERE parent IS NULL AND lb <= OLD.lb AND rb >= OLD.rb
    INTO :old_root;

    IF (:new_root <> :old_root) THEN
    BEGIN
      IF (:new_root IN (804000, 805000) OR :old_root IN (804000, 805000)) THEN
        EXCEPTION gd_e_cannotchangebranch;
    END
    
    IF (NEW.documenttype = 'B') THEN
    BEGIN
      IF (EXISTS (SELECT * FROM gd_documenttype WHERE documenttype <> 'B' AND id = NEW.parent)) THEN
        EXCEPTION gd_e_exception 'Document class can not include a folder.';
    END
  END
END
^

CREATE OR ALTER TRIGGER gd_aiu_documenttype FOR gd_documenttype
  ACTIVE
  AFTER INSERT OR UPDATE
  POSITION 20001
AS
  DECLARE VARIABLE P INTEGER;
  DECLARE VARIABLE XID INTEGER;
  DECLARE VARIABLE DBID INTEGER;
BEGIN
  IF (NEW.documenttype = 'B') THEN
  BEGIN
    IF (EXISTS (SELECT * FROM gd_documenttype WHERE documenttype <> 'B' AND id = NEW.parent)) THEN
      EXCEPTION gd_e_exception 'Document class can not include a folder.';
  END ELSE
  BEGIN
    IF ((INSERTING OR (NEW.ruid <> OLD.ruid))
      AND (NEW.ruid SIMILAR TO '([[:DIGIT:]]{9,10}\_[[:DIGIT:]]+)|([[:DIGIT:]]+\_17)' ESCAPE '\')) THEN
    BEGIN
      P = POSITION('_' IN NEW.ruid);
      XID = LEFT(NEW.ruid, :P - 1);
      DBID = RIGHT(NEW.ruid, CHAR_LENGTH(NEW.ruid) - :P);

      UPDATE OR INSERT INTO gd_ruid (id, xid, dbid, modified, editorkey)
      VALUES (NEW.id, :XID, :DBID, NEW.editiondate, RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY'))
      MATCHING(id);
    END
  END
END
^

SET TERM ; ^

CREATE TABLE gd_documenttype_option (
  id                    dintkey,
  dtkey                 dintkey,
  option_name           dname,
  bool_value            dboolean,
  relationfieldkey      dforeignkey,
  contactkey            dforeignkey,
  currkey               dforeignkey,
  editiondate           deditiondate, 
  disabled              ddisabled,
  
  CONSTRAINT gd_pk_dt_option PRIMARY KEY (id),
  CONSTRAINT gd_fk_dt_option_dtkey FOREIGN KEY (dtkey)
    REFERENCES gd_documenttype (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT gd_fk_dt_option_relfkey FOREIGN KEY (relationfieldkey)
    REFERENCES at_relation_fields (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT gd_fk_dt_option_contactkey FOREIGN KEY (contactkey)
    REFERENCES gd_contact (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT gd_fk_dt_option_currkey FOREIGN KEY (currkey)
    REFERENCES gd_curr (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

ALTER TABLE gd_documenttype_option ADD CONSTRAINT gd_uq_dt_option 
  UNIQUE (dtkey, option_name, relationfieldkey, contactkey, currkey);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_documenttype_option FOR gd_documenttype_option
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^    

CREATE OR ALTER TRIGGER gd_aiu_documenttype_option FOR gd_documenttype_option
  AFTER INSERT OR UPDATE
  POSITION 0
AS
  DECLARE VARIABLE I INTEGER = 0;
BEGIN
  IF (EXISTS(
    SELECT
      option_name,
      COUNT(option_name)
    FROM
      gd_documenttype_option
    WHERE
      dtkey = NEW.dtkey AND bool_value IS NOT NULL
    GROUP BY
      option_name
    HAVING
      COUNT(option_name) > 1)) THEN
  BEGIN
    EXCEPTION gd_e_exception 'Duplicate boolean option name';
  END
  
  IF (POSITION('.', NEW.option_name) > 0) THEN
  BEGIN
    IF (NEW.bool_value = 0) THEN
      EXCEPTION gd_e_exception 'Invalid enum type value'; 
      
    SELECT COUNT(*) FROM gd_documenttype_option
    WHERE dtkey = NEW.dtkey 
      AND option_name STARTING WITH LEFT(NEW.option_name, CHARACTER_LENGTH(NEW.option_name) - POSITION('.', REVERSE(NEW.option_name)) + 1)
      AND NEW.bool_value IS NOT NULL
    INTO :I;
    
    IF (:I > 1) THEN
      EXCEPTION gd_e_exception 'Multiple enum type values';          
  END    
END
^    

SET TERM ; ^

/* Нумерация документов */

CREATE TABLE gd_lastnumber
(
  documenttypekey       dintkey,
  ourcompanykey         dintkey,

  lastnumber            dinteger, /* Последний номер */
  addnumber             dinteger, /* Увеливать на */
  mask                  dtext80,  /* маска */
  fixlength             dfixlength, /* фиксированная длина номера */

  disabled              dboolean DEFAULT 0
);

ALTER TABLE gd_lastnumber ADD CONSTRAINT gd_pk_lastnumber
  PRIMARY KEY (documenttypekey, ourcompanykey);

ALTER TABLE gd_lastnumber ADD CONSTRAINT gd_fk_ln_documenttypekey
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_lastnumber ADD CONSTRAINT gd_fk_ln_ourcompanykey
  FOREIGN KEY (ourcompanykey) REFERENCES gd_ourcompany(companykey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;


/**********************************************************

  Документ

  Мы планируем хранить документы и позиции по ним в одной
  таблице. Связь между документом и позицией будет устанав-
  ливаться через ссылку Parent.

***********************************************************/

CREATE TABLE gd_document
(
  id              dintkey,             /* Ідэнтыфікатар дакумента         */
  parent          dforeignkey,         /* Спасылка ад пазіцыі да дакумента*/

  documenttypekey dintkey,             /* Тып дакумента                   */
  trtypekey       dforeignkey,         /* Привязка документа к операции   */
  transactionkey  dforeignkey,         /* Привязка документа к новой операции   */

  number          ddocumentnumber,     /* нумар дакумента                 */
  documentdate    ddocumentdate,       /* дата дакумента                  */
  description     dtext180,            /* каментарый                      */
  sumncu          dcurrency,           /* сума ў НГА                      */
  sumcurr         dcurrency,           /* сума ў валюце                   */
  sumeq           dcurrency,           /* сума ў эквіваленце              */
                                       /* УВАГА! гэтыя сумы выключна для  */
                                       /* даведкі. Заўсёды трэба браць су-*/
                                       /* му з адпаведнай табліцы         */

  delayed         dboolean,            /* отложенный документ             */
                                       /* документ оформлен, но в учете не*/
                                       /* фигурирует                      */

  afull           dsecurity,           /* права доступа                   */
  achag           dsecurity,
  aview           dsecurity,

  currkey         dforeignkey,         /* валюта дакумента                */
  companykey      dintkey,             /* фірма, калі ўлік вядзецца па    */
                                       /* некалькіх фірмах                */

  creatorkey      dintkey,             /* хто стварыў дакумент            */
  creationdate    dcreationdate,       /* дата і час стварэньня           */
  editorkey       dintkey,             /* хто рэдактаваў                  */
  editiondate     deditiondate,        /* дата і час рэдактаваньня        */

  printdate       ddate,               /* дата последней печати документа */

  disabled        ddisabled,
  reserved        dreserved
);

ALTER TABLE gd_document
  ADD CONSTRAINT gd_pk_document PRIMARY KEY (id);

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_doc_parent
  FOREIGN KEY (parent) REFERENCES gd_document(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_doc_doctypekey
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_document_currkey
  FOREIGN KEY (currkey) REFERENCES gd_curr(id) ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_document_companykey
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany(companykey)
  ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_document_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_document_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

CREATE DESC INDEX gd_x_document_documentdate
  ON gd_document(documentdate);

CREATE  INDEX gd_x_document_number
  ON gd_document(number);


COMMIT;

SET TERM ^ ;

/****************************************************/
/**                                                **/
/**   Триггер обрабатывающий добавление нового     **/
/**   элемента дерева, проверяет диапозон,         **/
/**   вызывает процедуру сдвига если надо          **/
/**                                                **/
/****************************************************/
CREATE TRIGGER gd_bi_documenttype FOR gd_documenttype
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (EXISTS(SELECT id FROM gd_documenttype WHERE ruid = NEW.ruid)) THEN
  BEGIN
    EXCEPTION gd_e_documenttype_ruid;
  END

  IF (EXISTS(SELECT id FROM gd_documenttype WHERE UPPER(name) = UPPER(NEW.name))) THEN
  BEGIN
    EXCEPTION gd_e_documenttype_name;
  END
END
^

/*
  При вставке и обновлении записи автоматически инициализируем
  поля Дата создания и Дата редактирования, если программист не
  присвоил их самостоятельно.
*/

CREATE TRIGGER gd_bi_document FOR gd_document
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  /*
  теперь эти поля заполняются в бизнес-объекте

  IF (NEW.creationdate IS NULL) THEN
    NEW.creationdate = CURRENT_TIMESTAMP(0);

  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
  */
END
^

CREATE TRIGGER GD_AU_DOCUMENT FOR GD_DOCUMENT
  AFTER UPDATE 
  POSITION 0
AS
BEGIN
  IF (NEW.PARENT IS NULL) THEN
  BEGIN
    IF ((OLD.documentdate <> NEW.documentdate) OR (OLD.number <> NEW.number) 
      OR (OLD.companykey <> NEW.companykey)) THEN
    BEGIN
      IF (NEW.DOCUMENTTYPEKEY <> 800300) THEN
        UPDATE gd_document SET documentdate = NEW.documentdate,
          number = NEW.number, companykey = NEW.companykey
        WHERE (parent = NEW.ID)
          AND ((documentdate <> NEW.documentdate)
           OR (number <> NEW.number) OR (companykey <> NEW.companykey));
      ELSE                                                                  
        UPDATE gd_document SET documentdate = NEW.documentdate,
          companykey = NEW.companykey
        WHERE (parent = NEW.ID)
          AND ((documentdate <> NEW.documentdate)
          OR  (companykey <> NEW.companykey));
    END
  END ELSE
  BEGIN
    IF (NEW.editiondate <> OLD.editiondate) THEN
      UPDATE gd_document SET editiondate = NEW.editiondate,
        editorkey = NEW.editorkey
      WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate);
  END

  /* просто игнорируем все ошибки */
  WHEN ANY DO
  BEGIN
  END
END
^

CREATE TRIGGER GD_AD_DOCUMENT FOR GD_DOCUMENT
  AFTER DELETE
  POSITION 0
AS
BEGIN
  IF (NOT (OLD.PARENT IS NULL)) THEN
  BEGIN
    UPDATE gd_document SET editiondate = 'NOW'
    WHERE ID = OLD.parent;
  END
END
^

CREATE TRIGGER GD_AI_DOCUMENT FOR GD_DOCUMENT
  AFTER INSERT
  POSITION 0
AS
BEGIN
  IF (NOT (NEW.PARENT IS NULL)) THEN
  BEGIN
    UPDATE gd_document SET editiondate = NEW.editiondate,
      editorkey = NEW.editorkey
    WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate);
  END
END
^

/*

  На вход процедуры передается идентификатор
  типа документа.

  На выходе:

    1 -- документ такого типа не подлежит блокировке.
    0 -- документ может быть заблокирован (если он
         входит в заблокированный период).

*/

CREATE PROCEDURE gd_p_exclude_block_dt(DT INTEGER)
  RETURNS(F INTEGER)
AS
BEGIN
  F = 0;
END
^

CREATE TRIGGER gd_bi_document_block FOR gd_document
  INACTIVE
  BEFORE INSERT
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((NEW.documentdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    EXECUTE PROCEDURE gd_p_exclude_block_dt (NEW.documenttypekey)
      RETURNING_VALUES :F;

    IF (:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

CREATE TRIGGER gd_bu_document_block FOR gd_document
  INACTIVE
  BEFORE UPDATE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (((NEW.documentdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) 
      OR ((OLD.documentdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0))) THEN
  BEGIN
    EXECUTE PROCEDURE gd_p_exclude_block_dt (NEW.documenttypekey)
      RETURNING_VALUES :F;

    IF (:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

CREATE TRIGGER gd_bd_document_block FOR gd_document
  INACTIVE
  BEFORE DELETE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((OLD.documentdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    EXECUTE PROCEDURE gd_p_exclude_block_dt (OLD.documenttypekey)
      RETURNING_VALUES :F;

    IF (:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

SET TERM ; ^

COMMIT;


/********************************************************************/
/*   Таблица хранит коды связанных документов                       */
/*   GD_DOCUMENTLINK                                                */
/********************************************************************/

CREATE TABLE gd_documentlink(
  sourcedockey         dintkey,   /* Документ источник              */
  destdockey           dintkey,   /* Документ назначение            */
                                                                    
  sumncu               dcurrency, /* Сумма в НДЕ                    */
  sumcurr              dcurrency, /* Сумма в валюте                 */
  sumeq                dcurrency, /* Сумма в эквиваленте            */

  reserved             dinteger 
);

COMMIT;

ALTER TABLE gd_documentlink ADD CONSTRAINT gd_pk_documentlink
  PRIMARY KEY (sourcedockey, destdockey);

ALTER TABLE gd_documentlink ADD CONSTRAINT gd_fk_documentlink_source
  FOREIGN KEY (sourcedockey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_documentlink ADD CONSTRAINT gd_fk_documentlink_dest
  FOREIGN KEY (destdockey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/*

  гэтая працэдура с_нхран_зуе змесц_ва табл_цаў at_fields, at_relations, at_relation_fields
  з рэальнай структурай базы дадзеных.

  1. выдаляе ўсё, што ўжо не _снуе
  2. дадае новае
  3. актуал_зуе _нфармацыю

*/
SET TERM ^ ;

CREATE OR ALTER PROCEDURE AT_P_SYNC 
AS
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE ID1 INTEGER;
  DECLARE VARIABLE FN VARCHAR(31);
  DECLARE VARIABLE FS VARCHAR(31);
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE NFS VARCHAR(31);
  DECLARE VARIABLE VS BLOB SUB_TYPE 0 SEGMENT SIZE 80;
  DECLARE VARIABLE EN VARCHAR(31);
  DECLARE VARIABLE DELRULE VARCHAR(20);
  DECLARE VARIABLE WASERROR SMALLINT;
  DECLARE VARIABLE GN VARCHAR(64);
BEGIN 
 /* пакольк_ каскады не выкарыстоўваюцца мус_м */ 
 /* п_льнавацца пэўнага парадку                */ 
  
 /* выдал_м не _снуючыя ўжо пал_ табл_цаў      */ 
   FOR 
     SELECT fieldname, relationname 
     FROM at_relation_fields LEFT JOIN rdb$relation_fields 
       ON fieldname=rdb$field_name AND relationname=rdb$relation_name 
     WHERE 
       rdb$field_name IS NULL 
     INTO :FN, :RN 
   DO BEGIN 
     DELETE FROM at_relation_fields WHERE fieldname=:FN AND relationname=:RN; 
   END 
  
 /* дададз_м новыя дамены */ 
   MERGE INTO at_fields trgt
     USING rdb$fields src
     ON trgt.fieldname = src.rdb$field_name
     WHEN NOT MATCHED THEN
       INSERT (fieldname, lname, description)
       VALUES (TRIM(src.rdb$field_name), TRIM(src.rdb$field_name), TRIM(src.rdb$field_name)); 

   /* 
   INSERT INTO AT_FIELDS (fieldname, lname, description)
   SELECT trim(rdb$field_name), trim(rdb$field_name),
     trim(rdb$field_name)
   FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname
     WHERE fieldname IS NULL;
   */ 
  
 /* для _снуючых палёў аднав_м _нфармацыю аб тыпе */ 
   FOR 
     SELECT fieldsource, fieldname, relationname 
     FROM at_relation_fields 
     INTO :FS, :FN, :RN 
   DO BEGIN 
     SELECT rf.rdb$field_source, f.id 
     FROM rdb$relation_fields rf JOIN at_fields f ON rf.rdb$field_source = f.fieldname 
     WHERE rdb$relation_name=:RN AND rdb$field_name = :FN 
     INTO :NFS, :ID; 
  
     IF (:NFS <> :FS AND (NOT (:NFS IS NULL))) THEN 
     UPDATE at_relation_fields SET fieldsource = :NFS, fieldsourcekey = :ID 
     WHERE fieldname = :FN AND relationname = :RN; 
   END 
  
 /* выдал_м з табл_цы даменаў не _снуючыя дамены */ 
   DELETE FROM at_fields f WHERE
   NOT EXISTS (SELECT rdb$field_name FROM rdb$fields
     WHERE rdb$field_name = f.fieldname);

  
 /*Теперь будем аккуратно проверять на несуществующие уже таблицы и существующие 
 домены, которые ссылаются на эти таблицы. Такая ситуация может возникнуть из-за 
 ошибки при создании мета-данных*/ 
  
   WASERROR = 0; 
  
   FOR 
 /*Выберем все поля и удалим*/ 
     SELECT rf.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN at_fields f ON r.id = f.reftablekey 
     LEFT JOIN at_relation_fields rf ON rf.fieldsourcekey = f.id 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     WASERROR = 1; 
     DELETE FROM at_relation_fields WHERE id = :ID; 
   END 
  
   FOR 
 /*Выберем все домены и удалим*/ 
     SELECT f.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN at_fields f ON r.id = f.reftablekey 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     WASERROR = 1; 
     DELETE FROM at_fields WHERE id = :ID; 
   END 
  
   FOR 
 /*Выберем все поля и удалим*/ 
     SELECT rf.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN at_fields f ON r.id = f.settablekey 
     LEFT JOIN at_relation_fields rf ON rf.fieldsourcekey = f.id 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     WASERROR = 1; 
     DELETE FROM at_relation_fields WHERE id = :ID; 
   END 
  
   FOR 
 /*Выберем все домены и удалим*/ 
     SELECT f.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN at_fields f ON r.id = f.settablekey 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     WASERROR = 1; 
     DELETE FROM at_fields WHERE id = :ID; 
   END 
  
   FOR 
/*выберем все документы, у которых шапка ссылается на несуществующие таблицы и удалим*/ 
     SELECT dt.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN gd_documenttype dt ON dt.headerrelkey =r.id 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     DELETE FROM gd_documenttype WHERE id = :ID; 
   END 
 
   FOR 
/*выберем все документы, у которых позиция ссылается на несуществующие таблицы и удалим*/ 
     SELECT dt.id 
     FROM at_relations r 
     LEFT JOIN rdb$relations rdb ON rdb.rdb$relation_name = r.relationname 
     LEFT JOIN gd_documenttype dt ON dt.linerelkey =r.id 
     WHERE rdb.rdb$relation_name IS NULL 
     INTO :ID 
   DO BEGIN 
     DELETE FROM gd_documenttype WHERE id = :ID; 
   END 
   IF (WASERROR = 1) THEN 
   BEGIN 
 /* Перечитаем домены. Теперь те домены, которые были проблемными добавятся без ошибок */ 
     INSERT INTO AT_FIELDS (fieldname, lname, description)
     SELECT g_s_trim(rdb$field_name, ' '), g_s_trim(rdb$field_name, ' '),
       g_s_trim(rdb$field_name, ' ')
     FROM rdb$fields LEFT JOIN at_fields ON rdb$field_name = fieldname
       WHERE fieldname IS NULL;
   END 
  
 /* выдал_м табл_цы, як_х ужо няма */ 
   DELETE FROM at_relations r WHERE
   NOT EXISTS (SELECT rdb$relation_name FROM rdb$relations
     WHERE rdb$relation_name = r.relationname );
  
 /* дададз_м новыя табл_цы */ 
 /* акрамя с_стэмных  */ 
   FOR 
     SELECT rdb$relation_name, rdb$view_source 
     FROM rdb$relations LEFT JOIN at_relations ON relationname=rdb$relation_name 
     WHERE (relationname IS NULL) AND (NOT rdb$relation_name CONTAINING 'RDB$') 
     INTO :RN, :VS 
   DO BEGIN 
     RN = g_s_trim(RN, ' '); 
     IF (:VS IS NULL) THEN 
       INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description) 
       VALUES (:RN, 'T', :RN, :RN, :RN); 
     ELSE 
       INSERT INTO at_relations (relationname, relationtype, lname, lshortname, description) 
       VALUES (:RN, 'V', :RN, :RN, :RN); 
     END 
  
 /* дадаем новыя пал_ */ 
   FOR 
     SELECT 
       rr.rdb$field_name, rr.rdb$field_source, rr.rdb$relation_name, r.id, f.id 
     FROM 
       rdb$relation_fields rr JOIN at_relations r ON rdb$relation_name = r.relationname 
     JOIN at_fields f ON rr.rdb$field_source = f.fieldname 
     LEFT JOIN at_relation_fields rf ON rr.rdb$field_name = rf.fieldname 
     AND rr.rdb$relation_name = rf.relationname 
     WHERE 
       (rf.fieldname IS NULL) AND (NOT rr.rdb$field_name CONTAINING 'RDB$') 
     INTO 
       :FN, :FS, :RN, :ID, :ID1 
   DO BEGIN 
     FN = g_s_trim(FN, ' '); 
     FS = g_s_trim(FS, ' '); 
     RN = g_s_trim(RN, ' '); 
     INSERT INTO at_relation_fields (fieldname, relationname, fieldsource, lname, description, 
       relationkey, fieldsourcekey, colwidth, visible) 
     VALUES(:FN, :RN, :FS, :FN, :FN, :ID, :ID1, 20, 1); 
   END 
  
 /* обновим информацию о правиле удаления для полей ссылок */ 
   FOR 
     SELECT rf.rdb$delete_rule, f.id 
     FROM rdb$relation_constraints rc 
     LEFT JOIN rdb$index_segments rs ON rc.rdb$index_name = rs.rdb$index_name 
     LEFT JOIN at_relation_fields f ON rc.rdb$relation_name = f.relationname 
     AND  rs.rdb$field_name = f.fieldname 
     LEFT JOIN rdb$ref_constraints rf ON rf.rdb$constraint_name = rc.rdb$constraint_name 
     WHERE 
     rc.rdb$constraint_type = 'FOREIGN KEY' 
     AND ((f.deleterule <> rf.rdb$delete_rule) 
     OR ((f.deleterule IS NULL) AND (rf.rdb$delete_rule IS NOT NULL)) 
     OR ((f.deleterule IS NOT NULL) AND (rf.rdb$delete_rule IS NULL))) 
     INTO :DELRULE, :ID 
   DO BEGIN 
     UPDATE at_relation_fields SET deleterule = :DELRULE WHERE id = :ID; 
   END 
  
 /* выдал_м не _снуючыя ўжо выключэннi */ 
   FOR 
     SELECT exceptionname 
     FROM at_exceptions LEFT JOIN rdb$exceptions 
     ON exceptionname=rdb$exception_name 
     WHERE 
       rdb$exception_name IS NULL 
     INTO :EN 
   DO BEGIN 
     DELETE FROM at_exceptions WHERE exceptionname=:EN; 
   END 
  
 /* дадаем новыя выключэннi */ 
   INSERT INTO at_exceptions(exceptionname)
   SELECT g_s_trim(rdb$exception_name, ' ')
   FROM rdb$exceptions
   LEFT JOIN at_exceptions e ON e.exceptionname=rdb$exception_name
   WHERE e.exceptionname IS NULL;

 /* выдал_м не _снуючыя ўжо працэдуры */ 
   FOR 
     SELECT procedurename 
     FROM at_procedures LEFT JOIN rdb$procedures 
       ON procedurename=rdb$procedure_name 
     WHERE 
       rdb$procedure_name IS NULL 
     INTO :EN 
   DO BEGIN 
     DELETE FROM at_procedures WHERE procedurename=:EN; 
   END 
  
 /* дадаем новыя працэдуры */ 
   INSERT INTO at_procedures(procedurename)
   SELECT g_s_trim(rdb$procedure_name, ' ')
   FROM rdb$procedures
   LEFT JOIN at_procedures e ON e.procedurename = rdb$procedure_name
   WHERE e.procedurename IS NULL;
       
 /* удалим не существующие уже генераторы */ 
   GN = NULL; 
   FOR  
     SELECT generatorname 
     FROM at_generators 
     LEFT JOIN rdb$generators ON generatorname=rdb$generator_name 
     WHERE rdb$generator_name IS NULL 
     INTO :GN  
   DO  
   BEGIN 
     DELETE FROM at_generators WHERE generatorname=:GN;  
   END 
       
 /* добавим новые генераторы */  
   INSERT INTO at_generators(generatorname)
   SELECT G_S_TRIM(rdb$generator_name, ' ')
   FROM rdb$generators
   LEFT JOIN at_generators t ON t.generatorname=rdb$generator_name
   WHERE t.generatorname IS NULL;
       
 /* удалим не существующие уже чеки */ 
   EN = NULL; 
   FOR 
     SELECT T.CHECKNAME 
     FROM AT_CHECK_CONSTRAINTS T 
     LEFT JOIN RDB$CHECK_CONSTRAINTS C ON T.CHECKNAME = C.RDB$CONSTRAINT_NAME 
     WHERE C.RDB$CONSTRAINT_NAME IS NULL 
     INTO :EN 
   DO 
   BEGIN 
     DELETE FROM AT_CHECK_CONSTRAINTS WHERE CHECKNAME = :EN; 
   END 
       
 /* добавим новые чеки */
 /*
   INSERT INTO AT_CHECK_CONSTRAINTS(CHECKNAME)
   SELECT TRIM(C.RDB$CONSTRAINT_NAME)
   FROM RDB$TRIGGERS T
   LEFT JOIN RDB$CHECK_CONSTRAINTS C ON C.RDB$TRIGGER_NAME = T.RDB$TRIGGER_NAME
   LEFT JOIN AT_CHECK_CONSTRAINTS CON ON CON.CHECKNAME = C.RDB$CONSTRAINT_NAME
   WHERE T.RDB$TRIGGER_SOURCE LIKE 'CHECK%'
     AND CON.CHECKNAME IS NULL;
 */    

   MERGE INTO at_check_constraints cc
   USING
     (
       SELECT DISTINCT TRIM(c.rdb$constraint_name) AS c_name
       FROM rdb$triggers t
         JOIN rdb$check_constraints c ON c.rdb$trigger_name = t.rdb$trigger_name
       WHERE
         t.rdb$trigger_source LIKE 'CHECK%'
     ) AS new_constraints
   ON (cc.checkname = new_constraints.c_name)
   WHEN NOT MATCHED THEN INSERT (checkname) VALUES (new_constraints.c_name);
END
^

COMMIT^


CREATE PROCEDURE AT_P_SYNC_INDEXES (
    RELATION_NAME VARCHAR (31))
AS
  DECLARE VARIABLE FN VARCHAR(31);
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE I_N VARCHAR(31);
  DECLARE VARIABLE FP SMALLINT;
  DEClARE VARIABLE FLIST VARCHAR(255);
  DEClARE VARIABLE FL VARCHAR(255);
  DEClARE VARIABLE INDEXNAME VARCHAR(31);
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE UF SMALLINT;
  DECLARE VARIABLE II SMALLINT;
BEGIN

  /* выдал_м не _снуючыя ўжо iндэксы */
  FOR
    SELECT indexname
    FROM at_indices LEFT JOIN rdb$indices
      ON indexname=rdb$index_name
    WHERE
      rdb$index_name IS NULL AND relationname = :RELATION_NAME
    INTO :I_N
  DO BEGIN
    DELETE FROM at_indices WHERE indexname=:I_N;
  END


 /* дадаем новыя iндэксы */
  FOR
    SELECT rdb$relation_name, rdb$index_name,
      rdb$index_inactive, rdb$unique_flag, r.id
    FROM rdb$indices LEFT JOIN at_indices i
      ON i.indexname=rdb$index_name
    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname
    WHERE
     i.indexname IS NULL AND rdb$relation_name = :RELATION_NAME
    INTO :RN, :I_N, :II, :UF, :ID
  DO BEGIN
    IF (II IS NULL) THEN
      II = 0;
    IF (UF IS NULL) THEN
      UF = 0;
    IF (II > 1) THEN
      II = 1;
    IF (UF > 1) THEN
      UF = 1;
    RN = g_s_trim(RN, ' ');
    I_N = g_s_trim(I_N, ' ');
    INSERT INTO at_indices(relationname, indexname, relationkey, unique_flag, index_inactive)
    VALUES (:RN, :I_N, :ID, :UF, :II);
  END

  /* проверяем индексы на активность и уникальность*/
  FOR
    SELECT ri.rdb$index_inactive, ri.rdb$unique_flag, ri.rdb$index_name
    FROM rdb$indices ri
    LEFT JOIN at_indices i ON ri.rdb$index_name = i.indexname
    WHERE ((i.unique_flag <> ri.rdb$unique_flag) OR
    (ri.rdb$unique_flag IS NULL AND i.unique_flag = 1) OR
    (i.unique_flag IS NULL) OR (i.index_inactive IS NULL) OR
    (i.index_inactive <> ri.rdb$index_inactive) OR
    (ri.rdb$index_inactive IS NULL AND i.index_inactive = 1)) AND
    (ri.rdb$relation_name = :RELATION_NAME)
    INTO :II, :UF, :I_N
  DO BEGIN
    IF (II IS NULL) THEN
      II = 0;
    IF (UF IS NULL) THEN
      UF = 0;
    IF (II > 1) THEN
      II = 1;
    IF (UF > 1) THEN
      UF = 1;
    UPDATE at_indices SET unique_flag = :UF, index_inactive = :II WHERE indexname = :I_N;
  END



  /* проверяем не изменился ли порядок полей в индексе*/

  FLIST = ' ';
  INDEXNAME = ' ';
  FOR
    SELECT isg.rdb$index_name, isg.rdb$field_name, isg.rdb$field_position
    FROM rdb$index_segments isg LEFT JOIN rdb$indices ri
      ON isg.rdb$index_name = ri.rdb$index_name
    WHERE ri.rdb$relation_name = :RELATION_NAME
    ORDER BY isg.rdb$index_name, isg.rdb$field_position
    INTO :I_N, :FN, :FP
  DO BEGIN
    IF (INDEXNAME <> I_N) THEN
    BEGIN
      IF (INDEXNAME <> ' ') THEN
      BEGIN
        SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL;
        IF ((FL <> FLIST) OR (FL IS NULL)) THEN
          UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME;
      END
      FLIST = g_s_trim(FN, ' ');
      INDEXNAME = I_N;
    END
    ELSE
      FLIST = FLIST || ',' || g_s_trim(FN, ' ');
  END
  IF (INDEXNAME <> ' ') THEN
    BEGIN
      SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL;
      IF ((FL <> FLIST) OR (FL IS NULL)) THEN
        UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME;
  END

END
^

CREATE PROCEDURE AT_P_SYNC_TRIGGERS (
    RELATION_NAME VARCHAR (31))
AS
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE TN VARCHAR(31);
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE TI SMALLINT;
BEGIN

  /* удалим не существующие уже триггеры */
  FOR
    SELECT triggername
    FROM at_triggers
      LEFT JOIN rdb$triggers
        ON triggername=rdb$trigger_name
          AND relationname=rdb$relation_name
    WHERE
      rdb$trigger_name IS NULL AND relationname = :RELATION_NAME
    INTO :TN
  DO BEGIN
    DELETE FROM at_triggers WHERE triggername=:TN;
  END


 /* добавим новые триггеры */
  FOR
    SELECT rdb$relation_name, rdb$trigger_name,
      rdb$trigger_inactive, r.id
    FROM rdb$triggers LEFT JOIN at_triggers t
      ON t.triggername=rdb$trigger_name
    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname
    WHERE
     t.triggername IS NULL AND rdb$relation_name = :RELATION_NAME
    INTO :RN, :TN, :TI, :ID
  DO BEGIN
    RN = G_S_TRIM(RN, ' ');
    TN = G_S_TRIM(TN, ' ');
    IF (TI IS NULL) THEN
      TI = 0;
    IF (TI > 1) THEN
      TI = 1;
    INSERT INTO at_triggers(
      relationname, triggername, relationkey, trigger_inactive)
    VALUES (
      :RN, :TN, :ID, :TI);
  END

  /* проверяем триггеры на активность*/
  FOR
    SELECT ri.rdb$trigger_inactive, ri.rdb$trigger_name
    FROM rdb$triggers ri
    LEFT JOIN at_triggers t ON ri.rdb$trigger_name = t.triggername
    WHERE ((t.trigger_inactive IS NULL) OR
    (t.trigger_inactive <> ri.rdb$trigger_inactive) OR
    (ri.rdb$trigger_inactive IS NULL AND t.trigger_inactive = 1)) AND
    (ri.rdb$relation_name = :RELATION_NAME)
    INTO :TI, :TN
  DO BEGIN
    IF (TI IS NULL) THEN
      TI = 0;
    IF (TI > 1) THEN
      TI = 1;
    UPDATE at_triggers SET trigger_inactive = :TI WHERE triggername = :TN;
  END

END
^


CREATE PROCEDURE AT_P_SYNC_INDEXES_ALL
AS
  DECLARE VARIABLE FN VARCHAR(31);
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE I_ID INTEGER;
  DECLARE VARIABLE I_N VARCHAR(31);
  DECLARE VARIABLE FP SMALLINT;
  DEClARE VARIABLE FLIST VARCHAR(255);
  DEClARE VARIABLE FL VARCHAR(255);
  DEClARE VARIABLE INDEXNAME VARCHAR(31);
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE UF SMALLINT;
  DECLARE VARIABLE II SMALLINT;
BEGIN

  /* выдал_м не _снуючыя ўжо iндэксы */
  FOR
    SELECT id
    FROM at_indices LEFT JOIN rdb$indices
      ON indexname=rdb$index_name
    WHERE
      rdb$index_name IS NULL
    INTO :I_ID
  DO BEGIN
    DELETE FROM at_indices WHERE id=:I_ID;
  END


 /* дадаем новыя iндэксы */
  FOR
    SELECT rdb$relation_name, rdb$index_name,
      COALESCE(rdb$index_inactive, 0), COALESCE(rdb$unique_flag, 0), r.id
    FROM rdb$indices LEFT JOIN at_indices i
      ON i.indexname=rdb$index_name
    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname
    WHERE
      (i.indexname IS NULL) AND (r.id IS NOT NULL)
    INTO :RN, :I_N, :II, :UF, :ID
  DO BEGIN
    RN = trim(RN);
    I_N = trim(I_N);
    IF (II <> 0) THEN
      II = 1;
    IF (UF <> 0) THEN
      UF = 1;
    INSERT INTO at_indices(relationname, indexname, relationkey, unique_flag, index_inactive)
    VALUES (:RN, :I_N, :ID, :UF, :II);
  END

  /* проверяем индексы на активность и уникальность*/
  FOR
    SELECT COALESCE(ri.rdb$index_inactive, 0), COALESCE(ri.rdb$unique_flag, 0), ri.rdb$index_name
    FROM at_indices i
    LEFT JOIN rdb$indices ri ON ri.rdb$index_name = i.indexname
    WHERE ((i.unique_flag <> ri.rdb$unique_flag) OR
    (ri.rdb$unique_flag IS NULL AND i.unique_flag = 1) OR
    (i.unique_flag IS NULL) OR (i.index_inactive IS NULL) OR
    (i.index_inactive <> ri.rdb$index_inactive) OR
    (ri.rdb$index_inactive IS NULL AND i.index_inactive = 1))
    INTO :II, :UF, :I_N
  DO BEGIN
    IF (II <> 0) THEN
      II = 1;
    IF (UF <> 0) THEN
      UF = 1;
    UPDATE at_indices SET unique_flag = :UF, index_inactive = :II WHERE indexname = :I_N;
  END



  /* проверяем не изменился ли порядок полей в индексе*/

  FLIST = ' ';
  INDEXNAME = ' ';
  FOR
    SELECT isg.rdb$index_name, isg.rdb$field_name, isg.rdb$field_position
    FROM rdb$index_segments isg LEFT JOIN rdb$indices ri
      ON isg.rdb$index_name = ri.rdb$index_name
    ORDER BY isg.rdb$index_name, isg.rdb$field_position
    INTO :I_N, :FN, :FP
  DO BEGIN
    IF (INDEXNAME <> I_N) THEN
    BEGIN
      IF (INDEXNAME <> ' ') THEN
      BEGIN
        SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL;
        IF ((FL <> FLIST) OR (FL IS NULL)) THEN
          UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME;
      END
      FLIST = UPPER(trim(FN));
      INDEXNAME = I_N;
    END
    ELSE
      FLIST = FLIST || ',' || UPPER(trim(FN));
  END
  IF (INDEXNAME <> ' ') THEN
    BEGIN
      SELECT fieldslist FROM at_indices WHERE indexname = :INDEXNAME INTO :FL;
      IF ((FL <> FLIST) OR (FL IS NULL)) THEN
        UPDATE at_indices SET fieldslist = :FLIST WHERE indexname = :INDEXNAME;
  END

END
^

CREATE PROCEDURE AT_P_SYNC_TRIGGERS_ALL
AS
  DECLARE VARIABLE RN VARCHAR(31);
  DECLARE VARIABLE TN VARCHAR(31);
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE TI SMALLINT;
BEGIN

  /* удалим не существующие уже триггеры */
  FOR
    SELECT triggername
    FROM at_triggers LEFT JOIN rdb$triggers
      ON triggername=rdb$trigger_name
        AND relationname=rdb$relation_name
    WHERE
      rdb$trigger_name IS NULL
    INTO :TN
  DO BEGIN
    DELETE FROM at_triggers WHERE triggername=:TN;
  END


 /* добавим новые триггеры */
  FOR
    SELECT rdb$relation_name, rdb$trigger_name,
      rdb$trigger_inactive, r.id
    FROM rdb$triggers LEFT JOIN at_triggers t
      ON t.triggername=rdb$trigger_name
    LEFT JOIN at_relations r ON rdb$relation_name = r.relationname
    WHERE
     (t.triggername IS NULL) and (r.id IS NOT NULL)
    INTO :RN, :TN, :TI, :ID
  DO BEGIN
    RN = G_S_TRIM(RN, ' ');
    TN = G_S_TRIM(TN, ' ');
    IF (TI IS NULL) THEN
      TI = 0;
    IF (TI > 1) THEN
      TI = 1;
    INSERT INTO at_triggers(relationname, triggername, relationkey, trigger_inactive)
    VALUES (:RN, :TN, :ID, :TI);
  END

  /* проверяем триггеры на активность*/
  FOR
    SELECT ri.rdb$trigger_inactive, ri.rdb$trigger_name
    FROM rdb$triggers ri
    LEFT JOIN at_triggers t ON ri.rdb$trigger_name = t.triggername
    WHERE ((t.trigger_inactive IS NULL) OR
    (t.trigger_inactive <> ri.rdb$trigger_inactive) OR
    (ri.rdb$trigger_inactive IS NULL AND t.trigger_inactive = 1))
    INTO :TI, :TN
  DO BEGIN
    IF (TI IS NULL) THEN
      TI = 0;
    IF (TI > 1) THEN
      TI = 1;
    UPDATE at_triggers SET trigger_inactive = :TI WHERE triggername = :TN;
  END

END
^
SET TERM ; ^
COMMIT;

/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    filter.sql

  Abstract

    An Interbase script for "universal" filter.

  Author

    Andrey Shadevsky (26.06.00)

  Revisions history

    Initial  26.06.00  JKL    Initial version

  Status 
    
    Draft

*/

/****************************************************

   Таблица для регистрации компонент фильтрации в БД.

*****************************************************/

CREATE TABLE flt_componentfilter
(
  id                dintkey,            /* идентификатор */
  filtername        dtext20,            /* наименование компонента */
  formname          dtext20,            /* наименование владельца компонента */
  applicationname   dtext20,            /* наименование приложения */
  crc               dinteger,           /* crc поля fullname */
  fullname          dtext255,           /* полное наименование компонента:
                                           наименование приложения + \ +
                                           наименование владельца + \ +
                                           имя компоненты фильтра (Добавлено из-за
                                           предыдущего органичения на имя фильтра 20 символов)*/
  editiondate       deditiondate                                            
);

ALTER TABLE flt_componentfilter
  ADD CONSTRAINT flt_pk_componentfilter PRIMARY KEY (id);

CREATE INDEX flt_x_componentfilter_comp 
  ON flt_componentfilter(filtername, formname, applicationname);

CREATE INDEX flt_x_componentfilter_crc 
  ON flt_componentfilter(crc);

COMMIT;

/****************************************************

   Таблица для хранения процедур созданных в фильтрах.
   Наверное от ее можно будет избавиться потом.

*****************************************************/

CREATE TABLE flt_procedurefilter
(
  name          dname,
  componentkey  dintkey,
  description   dtext180,
  aview          dsecurity,
  disabled      dboolean DEFAULT 0,
  reserved      dinteger
);

ALTER TABLE flt_procedurefilter ADD CONSTRAINT flt_pk_procedurefilter
  PRIMARY KEY (name);

ALTER TABLE flt_procedurefilter ADD CONSTRAINT flt_fk_procedurefilter_compkey 
  FOREIGN KEY (componentkey) REFERENCES flt_componentfilter(id)
  ON UPDATE CASCADE;

COMMIT;

CREATE EXCEPTION FLT_E_INVALIDFILTERNAME 
  'You made an attempt to save filter with duplicate name.';

/****************************************************

   Таблица для хранения фильтра пользователя.

*****************************************************/

CREATE TABLE flt_savedfilter
(
  id            dintkey,
  name          dname,
  userkey       dforeignkey,
  componentkey  dintkey,
  description   dtext180,
  lastextime    dtime,
  readcount     dinteger DEFAULT 0,

  data          dfilterdata,

  aview         dsecurity,
  achag         dsecurity,
  afull         dsecurity,

  disabled      dboolean DEFAULT 0,
  editiondate   deditiondate,   /* Дата последнего редактирования */
  editorkey     dintkey,        /* Ссылка на пользователя, который редактировал запись*/
  reserved      dinteger
);

ALTER TABLE flt_savedfilter ADD CONSTRAINT flt_pk_savedfilter
  PRIMARY KEY (id);

ALTER TABLE flt_savedfilter ADD CONSTRAINT flt_fk_savedfilter_userkey
  FOREIGN KEY (userkey) REFERENCES gd_user(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE flt_savedfilter ADD CONSTRAINT flt_fk_savedfilter_componentkey
  FOREIGN KEY (componentkey) REFERENCES flt_componentfilter(id)
  ON UPDATE CASCADE;

ALTER TABLE flt_savedfilter ADD CONSTRAINT flt_fk_savedfilter_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;
     
COMMIT;

SET TERM ^ ;

CREATE TRIGGER flt_bi_savedfilter FOR flt_savedfilter
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  if (NEW.readcount IS NULL) then
    NEW.readcount = 0;
END
^



/* Trigger: FLT_BI_SAVEDFILTER1 */
CREATE TRIGGER flt_bi_savedfilter1 FOR flt_savedfilter
BEFORE INSERT POSITION 1
AS
BEGIN
  IF (EXISTS
       (SELECT *
        FROM flt_savedfilter
        WHERE name = NEW.name AND componentkey = NEW.componentkey
        AND (userkey = NEW.userkey OR userkey IS NULL AND NEW.userkey IS NULL))
      )
  THEN
    EXCEPTION flt_e_invalidfiltername;
END
^


/* Trigger: FLT_BU_SAVEDFILTER1 */
CREATE TRIGGER flt_bu_savedfilter1 FOR flt_savedfilter
BEFORE UPDATE POSITION 1
AS
BEGIN
  IF (EXISTS
       (SELECT *
        FROM flt_savedfilter
        WHERE name = NEW.name AND componentkey = NEW.componentkey
        AND (userkey = NEW.userkey OR userkey IS NULL AND NEW.userkey IS NULL) AND id <> NEW.id)
      )
  THEN
    EXCEPTION flt_e_invalidfiltername;
END
^

CREATE TRIGGER flt_bi_component FOR flt_componentfilter
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER flt_bi_savedfilter5 FOR flt_savedfilter
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER flt_bu_savedfilter5 FOR flt_savedfilter
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения ссылки на последний фильтр.

*****************************************************/

CREATE TABLE flt_lastfilter
(
  componentkey         dintkey,
  userkey              dintkey,
  lastfilter           dintkey,
  crc32                dinteger,
  dbversion            dtext20
);

ALTER TABLE flt_lastfilter ADD CONSTRAINT flt_pk_lastfilter 
  PRIMARY KEY (componentkey, userkey);

ALTER TABLE flt_lastfilter ADD CONSTRAINT flt_fk_lastfilter_userkey 
  FOREIGN KEY (userkey) REFERENCES gd_user(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE flt_lastfilter ADD CONSTRAINT flt_fk_lastfilter_componentkey 
  FOREIGN KEY (componentkey) REFERENCES flt_componentfilter(id)
  ON UPDATE CASCADE;

ALTER TABLE flt_lastfilter ADD CONSTRAINT flt_fk_lastfilter_lastfilter 
  FOREIGN KEY (lastfilter) REFERENCES flt_savedfilter(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    bn_bankstatement.sql

  Abstract

    Банковские выписки

  Author

    Anton Smirnov,
    Julia Teryokhina

  Revisions history

    Initial  09.08.2000  SAI    Initial version
             11.01.2002  Julie  Modification

  Status

    Draft

*/

/*
 *
 *   Банковская выписка
 *
 *   Заметьте, мы храним в выписке сумму по дебету и кредиту всех
 *   позиций выписки, а также количество строк.
 *   Данные значения обновляются через систему триггеров.
 *
 */

CREATE TABLE bn_bankstatement
(
  documentkey          dintkey,               
  accountkey           dintkey,

  dsumncu              dcurrency DEFAULT 0 NOT NULL,
  csumncu              dcurrency DEFAULT 0 NOT NULL,

  dsumcurr             dcurrency DEFAULT 0 NOT NULL,
  csumcurr             dcurrency DEFAULT 0 NOT NULL,

  linecount            dinteger DEFAULT 0 NOT NULL,
  rate                 dcurrency, /* курс валютной выписки */ 

  CHECK(linecount >= 0)
);

COMMIT;

ALTER TABLE bn_bankstatement
  ADD CONSTRAINT bn_pk_bankstatement PRIMARY KEY (documentkey);

ALTER TABLE bn_bankstatement ADD CONSTRAINT bn_fk_bs_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE bn_bankstatement ADD CONSTRAINT bn_fk_bs_accountkey
  FOREIGN KEY (accountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

COMMIT;

/*
 *
 *   Позиция банковской выписки
 *
 */

CREATE TABLE bn_bankstatementline
(
  id                   dintkey,      /* унікальны ідэнтыфікатар стракі выпіскі      */

  documentkey          dforeignkey,  /* платежное требование или поручение          */
                                     /* или чек, или другой документ, который привя-*/
                                     /* зан к позиции выписки                       */
  bankstatementkey     dmasterkey,   /* спасылка на выпіску                         */
  trtypekey            dforeignkey,  /* ссылка на операцию                          */

  companykey           dforeignkey,  /* клиент, реальный плательщик или получатель  */
  contractorkey        dforeignkey,  /* клиент, перед которым или у которого        */
                                     /* возникает  долг                             */

  dsumncu              dcurrency,    /* дебет, сума ў НГА                           */
  dsumcurr             dcurrency,    /* дебет, сума ў валюце                        */

  csumncu              dcurrency,    /* крэдзіт, сума ў НГА                         */
  csumcurr             dcurrency,    /* крэдзіт, сума ў валюце                      */
                                     /* заўважце, што ключ валюты прывязаны да      */
                                     /* рахунка, па якім ідзе выпіска               */

                                     /* как определны для банковских выписок:       */
  paymentmode          dtext8,       /* форма рассчета                              */
  operationtype        dtext8,       /* вид операции                                */

                                     /* переносим эти поля с бумажной выписки:      */
  account              dbankaccount, /* рассчетный счет клиента                     */
  bankcode             dbankcode,    /* код банка клиента                           */
  bankbranch           dbankcode,    /* номер отделения банка */
  docnumber            dtext20,      /* номер документа(платежки)                   */

  comment              dblobtext80_1251,      /* каментар                                    */
                                     /* например, назначение платежа                */
  accountkey           dforeignkey,  /* ссылка на ac_account */

  /* адначасова можа быць альбо сума па крэдзіце, альбо дзебіце */
  CHECK(((dsumncu IS NULL) AND (csumncu > 0)) OR ((csumncu IS NULL) AND (dsumncu > 0)))
);

COMMIT;

ALTER TABLE bn_bankstatementline ADD CONSTRAINT bn_pk_bankstatementline
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE bn_bankstatementline ADD CONSTRAINT bn_fk_bsl_id
  FOREIGN KEY (id) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_bankstatementline ADD CONSTRAINT bn_fk_bsl_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_bankstatementline ADD CONSTRAINT bn_fk_bsl_companykey
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE bn_bankstatementline ADD CONSTRAINT bn_fk_bsl_contractorkey
  FOREIGN KEY (contractorkey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE bn_bankstatementline ADD CONSTRAINT bn_fk_bsl_bankstatementkey
  FOREIGN KEY (bankstatementkey) REFERENCES bn_bankstatement(documentkey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

/*
  После добавления позиции по выписке надо обновить
  суммарные значения в самой выписке.
*/

CREATE TRIGGER bn_ai_bsl FOR bn_bankstatementline
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE ndsumncu NUMERIC(15, 4);
  DECLARE VARIABLE ncsumncu NUMERIC(15, 4);
  DECLARE VARIABLE ndsumcurr NUMERIC(15, 4);
  DECLARE VARIABLE ncsumcurr NUMERIC(15, 4);
BEGIN
  IF (NEW.dsumncu IS NULL) THEN
    ndsumncu = 0;
  ELSE
    ndsumncu = NEW.dsumncu;

  IF (NEW.csumncu IS NULL) THEN
    ncsumncu = 0;
  ELSE
    ncsumncu = NEW.csumncu;

  IF (NEW.dsumcurr IS NULL) THEN
    ndsumcurr = 0;
  ELSE
    ndsumcurr = NEW.dsumcurr;

  IF (NEW.csumcurr IS NULL) THEN
    ncsumcurr = 0;
  ELSE
    ncsumcurr = NEW.csumcurr;

  UPDATE bn_bankstatement
    SET linecount = linecount + 1,
        dsumncu = dsumncu + :ndsumncu,
        csumncu = csumncu + :ncsumncu,
        dsumcurr = dsumcurr + :ndsumcurr,
        csumcurr = csumcurr + :ncsumcurr
    WHERE documentkey = NEW.bankstatementkey;

  UPDATE gd_document SET
  number = case when NEW.docnumber IS NULL then 'б\н' else NEW.docnumber end
  WHERE id = NEW.id;

END
^

/*

  После удаление позиции по выписке надо обновить сумарные значения
  в самой выписке.

*/
CREATE TRIGGER bn_ad_bsl FOR bn_bankstatementline
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE old_dsumncu NUMERIC(15, 4);
  DECLARE VARIABLE old_csumncu NUMERIC(15, 4);
  DECLARE VARIABLE old_dsumcurr NUMERIC(15, 4);
  DECLARE VARIABLE old_csumcurr NUMERIC(15, 4);
BEGIN
  old_dsumncu = COALESCE(OLD.dsumncu, 0);
  old_csumncu = COALESCE(OLD.csumncu, 0);
  old_dsumcurr = COALESCE(OLD.dsumcurr, 0);
  old_csumcurr = COALESCE(OLD.csumcurr, 0);

  UPDATE bn_bankstatement
    SET linecount = linecount - 1,
        dsumncu = dsumncu - :old_dsumncu,
        csumncu = csumncu - :old_csumncu,
        dsumcurr = dsumcurr - :old_dsumcurr,
        csumcurr = csumcurr - :old_csumcurr
    WHERE documentkey = OLD.bankstatementkey;
END
^

/*

  Данная процедура позволяет пересчитать суммарные значения
  для выписки заданной ключем.

*/
CREATE PROCEDURE bn_p_update_bankstatement(BK INTEGER)
AS
  DECLARE VARIABLE dsumncu NUMERIC(15, 4);
  DECLARE VARIABLE csumncu NUMERIC(15, 4);
  DECLARE VARIABLE dsumcurr NUMERIC(15, 4);
  DECLARE VARIABLE csumcurr NUMERIC(15, 4);
  DECLARE VARIABLE linecount INTEGER;
BEGIN
  SELECT SUM(dsumncu), SUM(csumncu), SUM(dsumcurr), SUM(csumcurr), COUNT(*)
  FROM bn_bankstatementline WHERE bankstatementkey = :BK
  INTO :dsumncu, :csumncu, :dsumcurr, :csumcurr, :linecount;

  IF (:dsumncu IS NULL) THEN dsumncu = 0;
  IF (:csumncu IS NULL) THEN csumncu = 0;
  IF (:dsumcurr IS NULL) THEN dsumcurr = 0;
  IF (:csumcurr IS NULL) THEN csumcurr = 0;

  UPDATE bn_bankstatement SET
    dsumncu = :dsumncu, csumncu = :csumncu, dsumcurr = :dsumcurr, csumcurr = :csumcurr,
    linecount = :linecount
  WHERE documentkey = :BK;
END
^

/*

  Данная процедура пересчитывает суммарные значения для всех выписок.

*/
CREATE PROCEDURE bn_p_update_all_bankstatements
AS
  DECLARE VARIABLE DK INTEGER;
BEGIN
  FOR
    SELECT documentkey FROM bn_bankstatement INTO :DK
  DO
  BEGIN
    EXECUTE PROCEDURE bn_p_update_bankstatement(:DK);
  END
END
^

/*

  После изменения строки по выписке пересчитаем суммарные значения для
  этой выписки.

*/
CREATE TRIGGER bn_au_bsl FOR bn_bankstatementline
  AFTER UPDATE
  POSITION 0
AS
  DECLARE VARIABLE change_csumcurr SMALLINT;
  DECLARE VARIABLE change_csumncu  SMALLINT;
  DECLARE VARIABLE change_dsumcurr SMALLINT;
  DECLARE VARIABLE change_dsumncu  SMALLINT;
BEGIN
  IF ((NEW.csumcurr IS NULL AND OLD.csumcurr IS NULL) OR
     (NEW.csumcurr = OLD.csumcurr)) THEN
    change_csumcurr = 0;
  ELSE
    change_csumcurr = 1;
    
  IF ((NEW.csumncu IS NULL AND OLD.csumncu IS NULL) OR
     (NEW.csumncu = OLD.csumncu)) THEN
    change_csumncu = 0;
  ELSE
    change_csumncu = 1;
  
  IF ((NEW.dsumcurr IS NULL AND OLD.dsumcurr IS NULL) OR
     (NEW.dsumcurr = OLD.dsumcurr)) THEN
    change_dsumcurr = 0;
  ELSE
    change_dsumcurr = 1;
    
  IF ((NEW.dsumncu IS NULL AND OLD.dsumncu IS NULL) OR
     (NEW.dsumncu = OLD.dsumncu)) THEN
    change_dsumncu = 0;
  ELSE
    change_dsumncu = 1;
  
  IF ((change_csumcurr = 1) OR
  (change_csumncu = 1) OR
  (change_dsumcurr = 1) OR
  (change_dsumncu = 1)) THEN
  EXECUTE PROCEDURE bn_p_update_bankstatement(NEW.bankstatementkey);

  UPDATE gd_document SET
  number = case when NEW.docnumber IS NULL then 'б\н' else NEW.docnumber end
  WHERE id = NEW.id;

END
^

CREATE TRIGGER bn_bi_bsl FOR bn_bankstatementline
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/**********************************************************

  Картатэка. Сьпіс неаплочаных дакументаў, якія знаходзяцца ў банке,
  якія трэба аплаціць. Па кожнаму ўказваецца сумма, якую яшчэ трэба
  пералічыць.

  Картатэкі захоўваюцца ў табліцы БН_БАНККАТАЛОГ, пазыцыі -- у
  табліцы БН_БАНККАТАЛОГЛАЙН.

  У БН_БАНККАТАЛОГ мы захоўваем сумарныя значэньні па пазіцыёх.

***********************************************************/

CREATE TABLE bn_bankcatalogue
(
  documentkey          dintkey,                      /* спасылка на дакумент       */
  accountkey           dintkey,                      /* спасылка на рахунак        */
  cataloguetype        dtext8,                       /* від картатэкі, К1, К2...   */
  sumncu               dcurrency DEFAULT 0 NOT NULL, /* сума па картатэцы          */
  sumcurr              dcurrency DEFAULT 0 NOT NULL  /* сума па картатэцы ў валюце */
);

COMMIT;

COMMIT;

ALTER TABLE bn_bankcatalogue ADD CONSTRAINT bn_pk_bankcatalogue
  PRIMARY KEY (documentkey);

ALTER TABLE bn_bankcatalogue ADD CONSTRAINT bn_fk_bankcatalogue_dc
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_bankcatalogue ADD CONSTRAINT bn_fk_bankcatalogue_accountkey
  FOREIGN KEY (accountkey) REFERENCES gd_companyaccount (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/*

  Пазіцыя банкаўскай картатэкі.

*/

CREATE TABLE bn_bankcatalogueline
(
  documentkey          dintkey,      /* унікальны ідэнтыфікатар стракі                 */
                                     /* ён жа спасылка на дакумент                     */
  bankcataloguekey     dintkey,      /* спасылка на картатэку                          */
                                     /* звярніце ўвагу, як спасылачная цэласнасць      */
                                     /* адсочваецца праз трыгеры                       */
  companykey           dforeignkey,  /* клиент, реальный получатель                    */
                                     /* кому на счет уходят деньги                     */
  linkdocumentkey      dforeignkey,  /* платежное требование или поручение             */
                                     /* или чек, или другой документ, который привя-   */
                                     /* зан к позиции                                  */
                                     /* который оплачивается по частям или с           */
                                     /* опозданием, т.е. который помещен на картотеку  */

  sumncu               dcurrency,    /* сумма в рублях                                 */
  sumcurr              dcurrency,    /* сумма в валюте                                 */
                                     /* сама валюта тут не указывается, потому что она */
                                     /* привязана к счету, а он к картотеке            */

  paymentdest          dalias,       /* код назначения платежа                         */
  acceptdate           ddate,        /* дата акцепта                                   */
  fine                 dcurrency,    /* сумма пени                                     */

                                     /* переносим эти поля с бумажной выписки:         */
  account              dbankaccount NOT NULL, /* рассчетный счет                                */
  bankcode             dbankcode NOT NULL,    /* код банка                                      */
  docnumber            dtext20,      /* номер документа                                */
  queue                dqueue,       /* очередность платежа */

  comment              dtext80,      /* каментар                                       */
                                     /* например, назначение платежа                   */

  reserved             dinteger,

  CHECK((sumncu > 0) OR (sumcurr > 0))
);

COMMIT;

ALTER TABLE bn_bankcatalogueline ADD CONSTRAINT bn_pk_bankcatalogueline
  PRIMARY KEY (documentkey);

ALTER TABLE bn_bankcatalogueline ADD CONSTRAINT bn_fk_bcl_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_bankcatalogueline ADD CONSTRAINT bn_fk_bcl_bankcataloguekey
  FOREIGN KEY (bankcataloguekey) REFERENCES bn_bankcatalogue (documentkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_bankcatalogueline ADD CONSTRAINT bn_fk_bcl_companykey
  FOREIGN KEY (companykey) REFERENCES gd_company (contactkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_bankcatalogueline ADD CONSTRAINT bn_fk_bcl_linkdocumentkey
  FOREIGN KEY (linkdocumentkey) REFERENCES gd_document (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE EXCEPTION bn_e_invalid_reference 'Invalid reference value'
^

CREATE TRIGGER bn_ai_bankcatalogueline FOR bn_bankcatalogueline
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE SN NUMERIC(15, 4);
  DECLARE VARIABLE SC NUMERIC(15, 4);
BEGIN
  IF (NEW.sumncu IS NULL) THEN
    SN = 0;
  ELSE
    SN = NEW.sumncu;

  IF (NEW.sumcurr IS NULL) THEN
    SC = 0;
  ELSE
    SC = NEW.sumcurr;

  UPDATE bn_bankcatalogue SET sumncu = sumncu + :SN, sumcurr = sumcurr + :SC
    WHERE documentkey = NEW.bankcataloguekey;
END
^

CREATE TRIGGER bn_ad_bankcatalogueline FOR bn_bankcatalogueline
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE SN NUMERIC(15, 4);
  DECLARE VARIABLE SC NUMERIC(15, 4);
BEGIN
  IF (OLD.sumncu IS NULL) THEN
    SN = 0;
  ELSE
    SN = OLD.sumncu;

  IF (OLD.sumcurr IS NULL) THEN
    SC = 0;
  ELSE
    SC = OLD.sumcurr;

  UPDATE bn_bankcatalogue SET sumncu = sumncu - :SN, sumcurr = sumcurr - :SC
    WHERE documentkey = OLD.bankcataloguekey;
END
^

CREATE TRIGGER bn_au_bankcatalogueline FOR bn_bankcatalogueline
  AFTER UPDATE
  POSITION 0
AS
  DECLARE VARIABLE SN NUMERIC(15, 4);
  DECLARE VARIABLE SC NUMERIC(15, 4);
BEGIN
  IF (NEW.sumncu IS NULL) THEN
    SN = 0;
  ELSE
    SN = NEW.sumncu;

  IF (NEW.sumcurr IS NULL) THEN
    SC = 0;
  ELSE
    SC = NEW.sumcurr;

  IF (NOT OLD.sumncu IS NULL) THEN
    SN = :SN - OLD.sumncu;

  IF (NOT OLD.sumcurr IS NULL) THEN
    SC = :SC - OLD.sumcurr;

  UPDATE bn_bankcatalogue SET sumncu = sumncu + :SN, sumcurr = sumcurr + :SC
    WHERE documentkey = OLD.bankcataloguekey;
END
^

SET TERM ; ^

COMMIT;



/**********************************************************

  gd_v_user_generators

  Returns list of names of non-system generators.

***********************************************************/

CREATE VIEW gd_v_user_generators (generator_name)
  AS SELECT rdb$generator_name     
     FROM rdb$generators
     WHERE (rdb$system_flag = 0) OR (rdb$system_flag IS NULL);


/**********************************************************

  gd_v_user_triggers

  Returns list of names of active non-system user defined 
  triggers.

***********************************************************/

CREATE VIEW gd_v_user_triggers (trigger_name)
  AS SELECT rdb$trigger_name 
     FROM rdb$triggers 
     WHERE (rdb$trigger_name NOT IN (SELECT rdb$trigger_name FROM rdb$check_constraints)) 
       AND ((rdb$system_flag = 0) OR (rdb$system_flag IS NULL)) 
       AND ((rdb$trigger_inactive = 0) OR (rdb$trigger_inactive IS NULL));

/**********************************************************

  gd_v_foreign_keys

  Returns list of foreign keys names together with
  corresponding index name and relation name.

***********************************************************/


CREATE VIEW gd_v_foreign_keys (constraint_name, index_name, relation_name)
  AS SELECT rdb$constraint_name, rdb$index_name, rdb$relation_name 
     FROM rdb$relation_constraints 
     WHERE rdb$constraint_type = 'FOREIGN KEY';


/**********************************************************

  gd_v_primary_keys

  Returns list of primary keys names together with
  corresponding index name and relation name.

***********************************************************/


CREATE VIEW gd_v_primary_keys (constraint_name, index_name, relation_name)
  AS SELECT rdb$constraint_name, rdb$index_name, rdb$relation_name 
     FROM rdb$relation_constraints 
     WHERE rdb$constraint_type = 'PRIMARY KEY';


/**********************************************************

  gd_v_user_indices

  Returns list of names of active non-system user defined 
  indices.

***********************************************************/

CREATE VIEW gd_v_user_indices (index_name)
  AS SELECT rdb$index_name 
     FROM rdb$indices
     WHERE ((rdb$system_flag = 0) OR (rdb$system_flag IS NULL))       
       AND (rdb$index_inactive = 0);



/**********************************************************

  gd_v_tables_wblob

  Returns list of names of all non-system tables
  which have at least one BLOB field.

***********************************************************/

create view gd_v_tables_wblob as
select distinct rf.rdb$relation_name
from
  rdb$relation_fields rf join rdb$fields f
    on rf.rdb$field_source = f.rdb$field_name
where
  f.rdb$field_type = 261
  and (not rf.rdb$relation_name LIKE 'RDB$%');

COMMIT;

/*
 *  Усе памылкі і пажаданьні да праграмы мы збіраем у табліцы
 *  bug_bugbase.
 *
 *
 *
 *
 */

CREATE TABLE bug_bugbase
(
  /* ідэнтыфікатар памылкі/пажаданьня */
  id             dintkey,

  /* назва падсістэмы                 */
  subsystem      dtext20 NOT NULL,

  /* вэрсія падсістэмы                */
  versionfrom    dtext20,
  versionto      dtext20,

  /* прыярытэт памылкі                */
  priority       dsmallint,

  /* вобласць памылкі/пажаданьня      */
  /* магчымыя значэньні:              */
  /*                                  */
  bugarea        dtext20 NOT NULL,
  /* тып памылкі/пажаданьня           */
  /* магчымыя значэньні:              */
  /*   ЗРАБІЦЬ                        */
  /*   ТРЭБА ЗРАБІЦЬ                  */
  /*   НЕДАХОП                        */
  /*   ПАМЫЛКА                        */
  /*   КАТАСТРОФА                     */
  bugtype        dtext20 NOT NULL,
  /* частата з'яўленьня               */
  /* магчымыя значэньні:              */
  /*   НІКОЛІ                         */
  /*   ЗРЭДКУ                         */
  /*   ЧАСАМ                          */
  /*   ЧАСТА                          */
  /*   ЗАЎСЁДЫ                        */
  /*   НЕ ПРЫКЛАДАЕЦЦА                */
  bugfrequency   dtext20 NOT NULL,
  /* апісаньне памылкі                */
  bugdescription dtext1024 NOT NULL,
  /* як вызваць памылку               */
  buginstruction dtext1024,

  /* хто знайшоў памылку              */
  founderkey     dintkey,
  /* калі ўнесена ў базу              */
  raised         ddate DEFAULT CURRENT_DATE NOT NULL,

  /* хто адказны                      */
  responsiblekey  dintkey,

  /* стан запісу                      */
  /* магчымыя значэньні:              */
  /*   АДКРЫТА                        */
  /*   ЗРОБЛЕНА                       */
  /*   САСТАРЭЛА                      */
  /*   АДХІЛЕНА                       */
  /*   ЧАСТКОВА                       */
  decision       dtext20 NOT NULL,
  /* калі выпраўлена                  */
  decisiondate   ddate,
  /* хто выправіў/прыняў рашэньне     */
  fixerkey       dforeignkey,
  /* каментар да рашэньня/выпраўленьня */
  fixcomment     dtext1024,

  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,

  reserved       dinteger
);

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_pk_bugbase_id
  PRIMARY KEY (id);

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_fk_bugbase_founderkey
  FOREIGN KEY (founderkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_fk_bugbase_responsiblekey
  FOREIGN KEY (responsiblekey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_fk_bugbase_fixerkey
  FOREIGN KEY (fixerkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_bugtype
  CHECK (bugtype IN ('ЗРАБІЦЬ', 'ТРЭБА ЗРАБІЦЬ', 'НЕДАХОП', 'ПАМЫЛКА', 'КАТАСТРОФА'));

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_bugfrequency
  CHECK (bugfrequency IN ('НІКОЛІ', 'ЗРЭДКУ', 'ЧАСАМ', 'ЧАСТА', 'ЗАЎСЁДЫ', 'НЕ ПРЫКЛАДАЕЦЦА'));

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_decision
  CHECK (decision IN ('АДКРЫТА', 'ЗРОБЛЕНА', 'САСТАРЭЛА', 'АДХІЛЕНА', 'ЧАСТКОВА', 'ВЫДАЛЕНА'));

/* калі стан запісу іншы за АДКРЫТА, трэба каб было пазначана хто */
/* выправіў памылку, альбо прыняў рашэньне і калі                 */
ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_fixerkey
  CHECK ((decision = 'АДКРЫТА' AND fixerkey IS NULL AND decisiondate IS NULL) OR (decision <> 'АДКРЫТА' AND NOT fixerkey IS NULL AND NOT decisiondate IS NULL));

/* нельга выправіць памылку раней, чым яна была ўнесена ў базу    */
ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_ddate
  CHECK ((decisiondate IS NULL) OR (decisiondate >= raised));

ALTER TABLE bug_bugbase ADD CONSTRAINT bug_chk_bugbase_priority
  CHECK ((priority IS NULL) OR (priority IN (0, 1, 2, 3, 4, 5)));

SET TERM ^ ;

CREATE TRIGGER bug_bi_bugbase FOR bug_bugbase
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  NEW.bugtype = UPPER(NEW.bugtype);
  NEW.bugfrequency = UPPER(NEW.bugfrequency);
  NEW.decision = UPPER(NEW.decision);
END
^

CREATE EXCEPTION bug_e_canntdelete 'Can not delete record not marked for deletion'^

CREATE TRIGGER bug_bd_bugbase FOR bug_bugbase
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.decision <> 'ВЫДАЛЕНА') THEN
    EXCEPTION bug_e_canntdelete;
END
^

SET TERM ; ^

COMMIT;
CREATE TABLE gd_command (
  id          dintkey,                      /* унікальны ідэнтыфікатар */
  parent      dparent,                      /* спасылка на бацьку      */

  name        dname,                        /* імя элементу            */
  cmd         dtext20,                      /* каманда                 */
  cmdtype     dinteger DEFAULT 0 NOT NULL,
  hotkey      dhotkey,                      /* гарачая клявіша         */
  imgindex    dsmallint DEFAULT 0 NOT NULL, /* індэкс малюнка          */
  ordr        dinteger,                     /* парадак                 */
  classname   dclassname,                   /* имя класса              */
  subtype     dtext40,                      /* подтип класса           */

  aview       dsecurity,                    /* бяспека                 */
  achag       dsecurity,
  afull       dsecurity,

  editiondate deditiondate,

  disabled    ddisabled,
  reserved    dreserved
);

COMMIT;

ALTER TABLE gd_command ADD CONSTRAINT gd_pk_command_id
  PRIMARY KEY (id);

ALTER TABLE gd_command ADD CONSTRAINT gd_fk_command_parent
  FOREIGN KEY (parent) REFERENCES gd_command (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_branchkey
  FOREIGN KEY (branchkey) REFERENCES gd_command (id) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE at_relations ADD  CONSTRAINT at_kk_relations_branchkey
  FOREIGN KEY (branchkey) REFERENCES gd_command (id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

COMMIT;

SET TERM ^ ;

/*

  Два наступныя трыгеры кантралююць каб у дзяцей былі тыя ж правы, што
  і ў бацькоўскага запісу.

*/

CREATE TRIGGER gd_bi_command FOR gd_command
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER gd_aiu_command FOR gd_command
  AFTER INSERT OR UPDATE
  POSITION 100
AS
BEGIN
  UPDATE gd_command SET aview = NEW.aview, achag = NEW.achag, afull = NEW.afull
  WHERE classname = NEW.classname
    AND COALESCE(subtype, '') = COALESCE(NEW.subtype, '')
    AND ((aview <> NEW.aview) OR (achag <> NEW.achag) OR (afull <> NEW.afull))
    AND id <> NEW.id;
END
^

SET TERM ; ^

/*

  Мы прывязываем настройкі працоўнага месца да карыстальніка і
  экраннага разрашэньня (шырыня экрану ў пікселах, памножаная на вышыню).

*/

CREATE TABLE gd_desktop (
  id          dintkey,
  userkey     dintkey,
  screenres   dinteger,
  name        dname,
  saved       dtimestamp DEFAULT 'NOW' NOT NULL,
  dtdata      dblob4096,

  reserved    dinteger
);

COMMIT;

ALTER TABLE gd_desktop ADD CONSTRAINT gd_pk_desktop_id
  PRIMARY KEY (id);

ALTER TABLE gd_desktop ADD CONSTRAINT gd_fk_desktop_userkey
  FOREIGN KEY (userkey) REFERENCES gd_user (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_desktop ADD CONSTRAINT gd_chk_desktop_name
  CHECK (name > '');

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_desktop FOR gd_desktop
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER gd_bu_desktop FOR gd_desktop
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  NEW.saved = 'NOW';
END
^

SET TERM ; ^

COMMIT;

COMMIT;

/*
 *  глябальныя настройкі,
 *  ў табліцы захоўваецца
 *  толькі адзін запіс
 *
 */

CREATE TABLE gd_globalstorage (
  id          dintkey,
  data        dblob4096,
  modified    dtimestamp NOT NULL
);

COMMIT;

ALTER TABLE gd_globalstorage ADD CONSTRAINT gd_pk_globalstorage_id
  PRIMARY KEY (id);

SET TERM ^ ;

CREATE TRIGGER gd_bi_gs FOR gd_globalstorage
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  NEW.id = 880000;
  IF (NEW.modified IS NULL) THEN
    NEW.modified = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER gd_bu_gs FOR gd_globalstorage
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  NEW.id = 880000;
  IF (NEW.modified IS NULL) THEN
    NEW.modified = CURRENT_TIMESTAMP;

  IF ((NEW.data IS NULL) OR (CHAR_LENGTH(NEW.data) = 0)) THEN
  BEGIN
    NEW.data = OLD.data;

    INSERT INTO gd_journal (source)
      VALUES ('Попытка удалить глобальное хранилище.');
  END
END
^

CREATE EXCEPTION gd_e_cannot_delete_gs
  'Cannot delete global storage'
^

CREATE TRIGGER gd_bd_gs FOR gd_globalstorage
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.id = 880000) THEN
  BEGIN
    EXCEPTION gd_e_cannot_delete_gs;
  END
END
^

SET TERM ; ^

COMMIT;

/*
 *  настройки для каждого пользователя
 *  хранится по одной записи для каждого пользователя
 *
 */

CREATE TABLE gd_userstorage (
  userkey      dintkey,
  data         dblob4096,
  modified     dtimestamp NOT NULL
);

ALTER TABLE gd_userstorage ADD CONSTRAINT gd_pk_userstorage_uk
  PRIMARY KEY (userkey);

ALTER TABLE gd_userstorage ADD CONSTRAINT gd_fk_userstorage_uk
  FOREIGN KEY (userkey) REFERENCES gd_user (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

/*
 *  настройки для каждой нашей фирмы
 *  хранится по одной записи для каждой фирмы
 *
 */

CREATE TABLE gd_companystorage (
  companykey   dintkey,
  data         dblob4096,
  modified     dtimestamp NOT NULL
);

ALTER TABLE gd_companystorage ADD CONSTRAINT gd_pk_companystorage_ck
  PRIMARY KEY (companykey);

ALTER TABLE gd_companystorage ADD CONSTRAINT gd_fk_companystorage_ck
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany (companykey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE DOMAIN dstorage_data_type AS CHAR(1) NOT NULL
  CHECK(VALUE IN (
    'G',   /* корень глобального хранилища                                      */
    'U',   /* корень пользовательского хранилища, int_data -- ключ пользователя */
    'O',   /* корень хранилища компании, int_data -- ключ компании              */
    'T',   /* корень хранилища р.стола, int_data -- ключ р.стола                */
    'F',   /* папка                                                             */
    'S',   /* строка                                                            */
    'I',   /* целое число                                                       */
    'C',   /* дробное число                                                     */
    'L',   /* булевский тип                                                     */
    'D',   /* дата и время                                                      */
    'B'    /* двоичный объект                                                   */
  ));

CREATE TABLE gd_storage_data (
  id             dintkey,
  parent         dparent,
  name           dtext120 NOT NULL,
  data_type      dstorage_data_type,
  str_data       dtext120,
  int_data       dinteger,
  datetime_data  dtimestamp,
  curr_data      dcurrency,
  blob_data      dblob4096,
  editiondate    deditiondate,
  editorkey      dintkey,

  CONSTRAINT gd_pk_storage_data_id PRIMARY KEY (id),
  CONSTRAINT gd_fk_storage_data_parent FOREIGN KEY (parent)
    REFERENCES gd_storage_data (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CHECK ((NOT parent IS NULL) OR (data_type IN ('G', 'U', 'O', 'T')))
);

CREATE EXCEPTION gd_e_storage_data '';

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_biu_storage_data FOR gd_storage_data
  BEFORE INSERT OR UPDATE
  POSITION 0
AS
  DECLARE VARIABLE FID INTEGER = -1;
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.data_type IN ('G', 'U', 'O', 'T')) THEN
  BEGIN
    NEW.parent = NULL;
  END

  IF (NEW.data_type IN ('G', 'F')) THEN
  BEGIN
    NEW.int_data = NULL;
  END

  IF (NEW.data_type IN ('G', 'U', 'O', 'T', 'F')) THEN
  BEGIN
    NEW.str_data = NULL;
    NEW.curr_data = NULL;
    NEW.datetime_data = NULL;
    NEW.blob_data = NULL;
  END

  IF (NEW.data_type = 'S') THEN
  BEGIN
    NEW.curr_data = NULL;
    NEW.datetime_data = NULL;
    NEW.blob_data = NULL;
    NEW.int_data = NULL;
    NEW.str_data = COALESCE(NEW.str_data, '');
  END

  IF (NEW.data_type IN ('I', 'L')) THEN
  BEGIN
    NEW.str_data = NULL;
    NEW.curr_data = NULL;
    NEW.datetime_data = NULL;
    NEW.blob_data = NULL;
    NEW.int_data = COALESCE(NEW.int_data, 0);
  END

  IF (NEW.data_type = 'C') THEN
  BEGIN
    NEW.str_data = NULL;
    NEW.datetime_data = NULL;
    NEW.blob_data = NULL;
    NEW.int_data = NULL;
    NEW.curr_data = COALESCE(NEW.curr_data, 0);
  END

  IF (NEW.data_type = 'D') THEN
  BEGIN
    NEW.str_data = NULL;
    NEW.curr_data = NULL;
    NEW.blob_data = NULL;
    NEW.int_data = NULL;
    NEW.datetime_data = COALESCE(NEW.datetime_data, CURRENT_TIMESTAMP);
  END

  IF (NEW.data_type = 'B') THEN
  BEGIN
    NEW.str_data = NULL;
    NEW.curr_data = NULL;
    NEW.datetime_data = NULL;
    NEW.int_data = NULL;
  END


  IF (NEW.parent IS NULL) THEN
  BEGIN
    FOR
      SELECT id FROM gd_storage_data WHERE parent IS NULL
        AND data_type = NEW.data_type AND int_data IS NOT DISTINCT FROM NEW.int_data
        AND id <> NEW.id
      INTO :FID
    DO
      EXCEPTION gd_e_storage_data 'Root already exists. ID=' || :FID;
  END ELSE
  BEGIN
    FOR
      SELECT id FROM gd_storage_data WHERE parent = NEW.parent
        AND UPPER(name) = UPPER(NEW.name) AND id <> NEW.id
      INTO :FID
    DO
      EXCEPTION gd_e_storage_data 'Duplicate name. ID=' || :FID;

    IF (NEW.data_type = 'F') THEN
    BEGIN
      FOR
        SELECT id FROM gd_storage_data WHERE id = NEW.parent
          AND data_type IN ('S', 'I', 'C', 'L', 'D', 'B')
        INTO :FID
      DO
        EXCEPTION gd_e_storage_data 'Invalid parent. ID=' || :FID;
    END ELSE
    BEGIN
      FOR
        SELECT id FROM gd_storage_data WHERE id = NEW.parent
          AND data_type <> 'F'
        INTO :FID
      DO
        EXCEPTION gd_e_storage_data 'Invalid parent. ID=' || :FID;
    END
  END
END
^

CREATE OR ALTER TRIGGER gd_au_storage_data FOR gd_storage_data
  ACTIVE
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  IF (
    (OLD.data_type = 'F')
    AND
    (
      (OLD.name IS DISTINCT FROM NEW.name)
      OR
      (OLD.parent IS DISTINCT FROM NEW.parent)
    )
  ) THEN
  BEGIN
    IF (UPPER(OLD.name) IN ('DFM', 'NEWFORM', 'OPTIONS', 'SUBTYPES')) THEN
    BEGIN
      IF (EXISTS (SELECT * FROM gd_storage_data WHERE id = OLD.parent AND data_type = 'G')) THEN
        EXCEPTION gd_e_storage_data 'Can not change system folder ' || OLD.name;
    END

    IF (
      EXISTS (
        SELECT *
        FROM
          gd_storage_data f
          JOIN gd_storage_data p ON f.parent = p.id
          JOIN gd_storage_data pp ON p.parent = pp.id
        WHERE f.id = OLD.id AND UPPER(p.name) = 'DFM'
          AND pp.data_type = 'G')
    ) THEN
      EXCEPTION gd_e_storage_data 'Can not change system folder ' || OLD.name;
  END
END
^

CREATE OR ALTER TRIGGER gd_bd_storage_data FOR gd_storage_data
  ACTIVE
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (UPPER(OLD.name) IN ('DFM', 'NEWFORM', 'OPTIONS', 'SUBTYPES')) THEN
  BEGIN
    IF (EXISTS (SELECT * FROM gd_storage_data WHERE id = OLD.parent AND data_type = 'G')) THEN
      EXCEPTION gd_e_storage_data 'Can not delete system folder ' || OLD.name;
  END

  IF (OLD.data_type = 'F') THEN
  BEGIN
    IF (
      EXISTS (
        SELECT *
        FROM
          gd_storage_data f
          JOIN gd_storage_data p ON f.parent = p.id
          JOIN gd_storage_data pp ON p.parent = pp.id
          JOIN gd_storage_data v ON v.parent = f.id
        WHERE f.id = OLD.id AND UPPER(p.name) = 'DFM'
          AND pp.data_type = 'G')
    ) THEN
      EXCEPTION gd_e_storage_data 'System folder is not empty ' || OLD.name;
  END
END
^

SET TERM ; ^

COMMIT;

/*

  Гісторыю SQL запытаў у акне SQL рэдактара будзем захоўваць
  у базе дадзеных, а не ў сховішчы.

*/

CREATE TABLE gd_sql_history (
  id               dintkey,
  sql_text         dblobtext80_1251 not null,
  sql_params       dblobtext80_1251,
  bookmark         CHAR(1),
  creatorkey       dintkey,
  creationdate     dcreationdate,
  editorkey        dintkey,
  editiondate      deditiondate,
  exec_count       dinteger_notnull DEFAULT 1
);

ALTER TABLE gd_sql_history ADD CONSTRAINT gd_pk_sql_history
  PRIMARY KEY (id);

ALTER TABLE gd_sql_history ADD CONSTRAINT gd_fk_sql_history_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_contact (id)
  ON DELETE NO ACTION
  ON UPDATE CASCADE;

ALTER TABLE gd_sql_history ADD CONSTRAINT gd_fk_sql_history_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_contact (id)
  ON DELETE NO ACTION
  ON UPDATE CASCADE;

SET TERM ^ ;

CREATE TRIGGER gd_bi_sql_history FOR gd_sql_history
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER gd_bu_sql_history FOR gd_sql_history
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.editiondate <> OLD.editiondate) THEN
    NEW.exec_count = NEW.exec_count + 1;
END
^

SET TERM ; ^

CREATE EXCEPTION gd_e_block_old_storage 'Изменение старых данных хранилища заблокировано';

SET TERM ^ ;

CREATE TRIGGER gd_biud_globalstorage FOR gd_globalstorage
  BEFORE INSERT OR UPDATE OR DELETE
  POSITION 0
AS
BEGIN
  EXCEPTION gd_e_block_old_storage 'Изменение старых данных глобального хранилища заблокировано';
END
^

CREATE TRIGGER gd_biu_userstorage FOR gd_userstorage
  BEFORE INSERT OR UPDATE /* OR DELETE */
  POSITION 0
AS
BEGIN
  EXCEPTION gd_e_block_old_storage 'Изменение старых данных пользовательского хранилища заблокировано';
END
^

CREATE TRIGGER gd_biu_companystorage FOR gd_companystorage
  BEFORE INSERT OR UPDATE /* OR DELETE */
  POSITION 0
AS
BEGIN
  EXCEPTION gd_e_block_old_storage 'Изменение старых данных хранилища компании заблокировано';
END
^

SET TERM ; ^

COMMIT;
/*

  Copyright (c) 2000-2013 by Golden Software of Belarus

  Script

    gd_good.sql

  Abstract

    An Interbase script for access.

  Author

    Andrey Shadevsky (30.05.00)

  Revisions history

    Initial  30.05.00  JKL    Initial version
    2.00     07.09.00  MSH
    2.01     08.09.00  MSH    Add gd_goodbarcode table

  Status 
    
*/


/****************************************************

   Таблица для хранения групп товаров.

*****************************************************/

CREATE TABLE gd_goodgroup
(
  id               dintkey,                     /* Первичный ключ          */
  parent           dparent,                     /* родитель                */
  lb               dlb,                         /* левая граница           */
  rb               drb,                         /* правая граница          */

  name             dname,                       /* имя                     */
  alias            dnullalias,                  /* Код группы              */
  description      dblobtext80_1251,            /* описание                */

  creatorkey       dforeignkey,
  creationdate     dcreationdate,

  editorkey        dforeignkey,                 /* Кто         изменил запись */
  editiondate      deditiondate,                /* Когда      изменена запись */

  disabled         ddisabled,                   /* отключен                */
  reserved         dreserved,                   /* зарезервировано         */

  afull            dsecurity,                   /* Полные права доступа    */
  achag            dsecurity,                   /* Изменения права доступа */
  aview            dsecurity                    /* Просмотра права доступа */
);

ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_pk_goodgroup
  PRIMARY KEY (id);

ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_parent
  FOREIGN KEY (parent) REFERENCES gd_goodgroup (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

COMMIT;

CREATE EXCEPTION gd_e_cannotchange_goodgroup 'Can not change good group!';

SET TERM ^ ;

CREATE TRIGGER gd_bi_goodgroup FOR gd_goodgroup
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE OR ALTER TRIGGER gd_ad_goodgroup_protect FOR gd_goodgroup
  ACTIVE
  AFTER DELETE
  POSITION 0
AS
BEGIN
  IF (UPPER(OLD.name) IN ('ТАРА', 'СТЕКЛОПОСУДА', 'ДРАГМЕТАЛЛЫ')) THEN
    EXCEPTION gd_e_cannotchange_goodgroup  'Нельзя удалить группу ' || OLD.Name;
END
^

CREATE OR ALTER TRIGGER gd_ai_goodgroup_protect FOR gd_goodgroup
  ACTIVE
  AFTER INSERT
  POSITION 0
AS
BEGIN
  IF (UPPER(NEW.name) IN ('ТАРА', 'СТЕКЛОПОСУДА', 'ДРАГМЕТАЛЛЫ')) THEN
  BEGIN
    IF (EXISTS (SELECT * FROM gd_goodgroup WHERE id <> NEW.id AND UPPER(name) = UPPER(NEW.name))) THEN
      EXCEPTION gd_e_cannotchange_goodgroup  'Нельзя повторно создать группу ' || NEW.Name;
  END
END
^

CREATE OR ALTER TRIGGER gd_au_goodgroup_protect FOR gd_goodgroup
  ACTIVE
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  IF ((UPPER(NEW.name) IN ('ТАРА', 'СТЕКЛОПОСУДА', 'ДРАГМЕТАЛЛЫ'))
    OR (UPPER(OLD.name) IN ('ТАРА', 'СТЕКЛОПОСУДА', 'ДРАГМЕТАЛЛЫ'))) THEN
  BEGIN
    IF (NEW.name <> OLD.name OR NEW.parent IS DISTINCT FROM OLD.parent) THEN
      EXCEPTION gd_e_cannotchange_goodgroup  'Нельзя изменять стандартную группу ' || NEW.Name;
  END
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения единиц измерения.

*****************************************************/

CREATE TABLE gd_value
(
  id            dintkey,        /* Первичный ключ                  */
  name          dname,          /* Наименование                    */
  description   dtext80,        /* Описание                        */
  goodkey       dforeignkey,    /* Ссылка на ТМЦ по данной ед.изм. */
  ispack        dboolean,       /* Используется для упаковки       */
  editiondate   deditiondate
);

ALTER TABLE gd_value ADD CONSTRAINT gd_pk_value
  PRIMARY KEY (id);

COMMIT;


SET TERM ^ ;

CREATE TRIGGER gd_bi_value FOR gd_value
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения справочника ТНВД.

*****************************************************/

CREATE TABLE gd_tnvd
(
  id            dintkey,        /* Первичный ключ               */
  name          dname,          /* Наименование                 */
  description   dtext180,       /* Описание                     */
  editiondate   deditiondate
);

ALTER TABLE gd_tnvd ADD CONSTRAINT gd_pk_tnvd
  PRIMARY KEY (id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_tnvd FOR gd_tnvd
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения товаров.

*****************************************************/

CREATE TABLE gd_good
(
  id               dintkey,                     /* Первичный ключ             */
  groupkey         dmasterkey,                  /* Принадлежность к группе    */
  name             dname,                       /* имя                        */
  alias            dnullalias,                  /* Шифр товара                */
  shortname        dtext40,                     /* Краткое наименование       */
  description      dtext180,                    /* описание                   */

  barcode          dbarcode,                    /* Штрих код                  */
  valuekey         dintkey,                     /* Базовая единица измерения  */
  tnvdkey          dforeignkey,                 /* Ссылка на код ТНВД         */
  discipline       daccountingdiscipline,       /* Вид учета ТМЦ              */                  

  isassembly       dboolean,                    /* Является ли комплектом     */

  creatorkey       dforeignkey,
  creationdate     dcreationdate,

  editorkey        dforeignkey,                 /* Кто         изменил запись */
  editiondate      deditiondate,                /* Когда      изменена запись */

  reserved         dreserved,                   /* Зарезервированно           */
  disabled         ddisabled,                   /* Отключено                  */

  afull            dsecurity,                   /* Полные права доступа       */
  achag            dsecurity,                   /* Изменения права доступа    */
  aview            dsecurity                    /* Просмотра права доступа    */
);

ALTER TABLE gd_good ADD CONSTRAINT gd_pk_good
  PRIMARY KEY (id);

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_groupkey
  FOREIGN KEY (groupkey) REFERENCES gd_goodgroup(id) 
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_valuekey
  FOREIGN KEY (valuekey) REFERENCES gd_value(id) 
  ON UPDATE CASCADE;

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_tnvdkey
  FOREIGN KEY (tnvdkey) REFERENCES gd_tnvd(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

CREATE ASC INDEX gd_x_good_name
  ON gd_good (name);

CREATE ASC INDEX gd_x_good_barcode
  ON gd_good (barcode);

ALTER INDEX gd_x_good_barcode INACTIVE;

COMMIT;

ALTER TABLE gd_value ADD CONSTRAINT gd_fk_value_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id);  

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_good FOR gd_good
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE ATTRKEY INTEGER;
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE EXCEPTION gd_e_good 'Error'
^

CREATE OR ALTER TRIGGER gd_aiu_good FOR gd_good
  AFTER INSERT OR UPDATE
  POSITION 0
AS
BEGIN
  IF (INSERTING OR (UPDATING AND NEW.groupkey <> OLD.groupkey)) THEN
  BEGIN
    IF (EXISTS(SELECT * FROM gd_goodgroup WHERE id = NEW.groupkey AND COALESCE(disabled, 0) <> 0)) THEN
      EXCEPTION gd_e_good 'Нельзя добавлять/изменять товар в отключенной группе.';
  END
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения комплектов.

*****************************************************/

CREATE TABLE gd_goodset
(
  goodkey       dintkey,        /* Ссылка на товар(комплект)    */
  setkey        dintkey,        /* Ссылка на комплект           */
  goodcount     dpositive       /* Количество товара            */
);

ALTER TABLE gd_goodset ADD CONSTRAINT gd_pk_goodset
  PRIMARY KEY (setkey, goodkey);

ALTER TABLE gd_goodset ADD CONSTRAINT gd_fk_goodset_setkey
  FOREIGN KEY (setkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodset ADD CONSTRAINT gd_fk_goodset_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

/****************************************************

   Таблица для привязки к товару дополнительных единиц измерения.

*****************************************************/

CREATE TABLE gd_goodvalue
(
  goodkey       dintkey,        /* Ссылка на товар              */
  valuekey      dintkey,        /* Ссылка на единицу измерения  */
  scale         dpercent,       /* Коэффициент пересчета        */
  discount      dcurrency,      /* Скидка на товар              */
  decdigit      ddecdigits      /* Количество десятичных        */
);

ALTER TABLE gd_goodvalue ADD CONSTRAINT gd_pk_goodvalue
  PRIMARY KEY (goodkey, valuekey);

ALTER TABLE gd_goodvalue ADD CONSTRAINT gd_fk_goodvalue_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodvalue ADD CONSTRAINT gd_fk_goodvalue_valuekey
  FOREIGN KEY (valuekey) REFERENCES gd_value(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

/****************************************************

   Таблица для хранения налогов.

*****************************************************/

CREATE TABLE gd_tax
(
  id            dintkey,        /* Ключ уникальный              */
  name          dname,          /* Наименование                 */
  shot          dtext20,        /* Наименование переменной      */
  rate          dtax,           /* Ставка                       */
  editiondate   deditiondate
);

ALTER TABLE gd_tax ADD CONSTRAINT gd_pk_tax
  PRIMARY KEY (id);

CREATE UNIQUE INDEX gd_x_tax_name ON gd_tax
  (name);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_tax FOR gd_tax
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для привязки к налогов.

*****************************************************/

CREATE TABLE gd_goodtax
(
  goodkey       dintkey,        /* Ссылка на товар              */
  taxkey        dintkey,        /* Ссылка на налог              */
  datetax       ddate NOT NULL,  /* Дата принятия налога         */
  rate          dcurrency       /* Ставка                       */
);

ALTER TABLE gd_goodtax ADD CONSTRAINT gd_pk_goodtax
  PRIMARY KEY (goodkey, taxkey, datetax);

ALTER TABLE gd_goodtax ADD CONSTRAINT gd_fk_goodtax_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodtax ADD CONSTRAINT gd_fk_goodtax_taxkey
  FOREIGN KEY (taxkey) REFERENCES gd_tax(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_goodtax FOR gd_goodtax
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.rate IS NULL) THEN
    SELECT rate FROM gd_tax
    WHERE id = NEW.taxkey INTO NEW.rate;

  IF (NEW.datetax IS NULL) THEN
    NEW.datetax = 'NOW';

END;^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для вспомогательных штрих-кодов.

*****************************************************/

CREATE TABLE gd_goodbarcode
(
  id            dintkey,           /* Ключ уникальный              */
  goodkey       dintkey,           /* Ссылка на товар              */
  barcode       dbarcode NOT NULL, /* Штрих код                    */
  description   dtext180           /* Описание                     */
);

ALTER TABLE gd_goodbarcode ADD CONSTRAINT gd_pk_goodbarcode_id
  PRIMARY KEY (id);

ALTER TABLE gd_goodbarcode ADD CONSTRAINT gd_fk_goodbarcode_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

CREATE ASC INDEX gd_x_goodbarcode_barcode
  ON gd_goodbarcode (barcode);

ALTER INDEX gd_x_goodbarcode_barcode INACTIVE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_goodbarcode FOR gd_goodbarcode
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

END;^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения драг. металлов.

*****************************************************/

CREATE TABLE gd_preciousemetal
(
  id            dintkey,        /* Ключ уникальный              */
  name          dname,          /* Наименование                 */
  description   dtext180,       /* Описание */
  editiondate   deditiondate
);

ALTER TABLE gd_preciousemetal ADD CONSTRAINT gd_pk_preciousemetal
  PRIMARY KEY (id);

COMMIT;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_preciousemetal FOR gd_preciousemetal
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
      
END;^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для привязки драгметалов.

*****************************************************/

CREATE TABLE gd_goodprmetal
(
  goodkey       dintkey,          /* Ссылка на товар              */
  prmetalkey    dintkey,          /* Ссылка на драгметалл         */
  quantity      dgoldquantity DEFAULT 0 /* Количество                   */
);

ALTER TABLE gd_goodprmetal ADD CONSTRAINT gd_pk_goodprmetal
  PRIMARY KEY (goodkey, prmetalkey);

ALTER TABLE gd_goodprmetal ADD CONSTRAINT gd_fk_goodprmetal_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodprmetal ADD CONSTRAINT gd_fk_goodprmetal_prmetalkey
FOREIGN KEY (prmetalkey) REFERENCES gd_preciousemetal(id)
  ON UPDATE CASCADE;

COMMIT;
/*
 *
 *  Активность счета
 *  A - (active) активный
 *  P - (passive) пассивный
 *  B - (both) активно-пассивный
 *
 *  NULL - для групп счетов, планов счетов
 *
 */

CREATE DOMAIN daccountactivity
  AS CHAR(1)
  CHECK (VALUE IN ('A', 'P', 'B'));

/*
 *
 *  Часть плана счетов
 *  C - (chart of account) план счетов
 *  F - (folder) папка (группа) счетов
 *  A - (account) счет
 *  S - (subaccount) субсчет
 *
 */

CREATE DOMAIN dchartofaccountpart
  AS CHAR(1)
  NOT NULL
  CHECK (VALUE IN ('C', 'F', 'A', 'S'));

/*
 *
 *  Список планов бухгалтерских счетов, состоящих
 *  из групп счетов, счетов и субсчетов
 *
 */


CREATE TABLE ac_account
(
  id               dintkey,             /* Идентификатор */
  parent           dparent,             /* Родительская ветка */

  lb               dlb,                 /* Левая граница */
  rb               drb,                 /* Правая граница */

  name             dtext180,            /* Наименование счета */
  alias            daccountalias,       /* Код счета */

  analyticalfield  dforeignkey,         /* аналитическое поле для активно-пассивных счетов */  

  activity         daccountactivity,    /* Активность счета */

  accounttype      dchartofaccountpart, /* Часть плана счетов */

  multycurr        dboolean DEFAULT 0,  /* Является ли счет валютным */
  offbalance       dboolean DEFAULT 0,  /* Забалансовый счет */

  afull            dsecurity,           /* Дескрипторы безопасности */
  achag            dsecurity,
  aview            dsecurity,

  editiondate      deditiondate,

  fullname         COMPUTED BY (COALESCE(ALIAS, '') || ' ' || COALESCE(NAME, '')),

  description      dblobtext80_1251,

  disabled         dboolean DEFAULT 0,
  reserved         dinteger,

  CONSTRAINT ac_chk_account_activity CHECK(
    (activity IS NULL AND accounttype IN ('C', 'F')) OR (activity IS NOT NULL)
  )
);

COMMIT;

ALTER TABLE ac_account
  ADD CONSTRAINT ac_pk_account PRIMARY KEY (id);

ALTER TABLE ac_account ADD CONSTRAINT ac_fk_account_parent
  FOREIGN KEY (parent) REFERENCES ac_account(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_account ADD CONSTRAINT ac_fk_account_anltcf
  FOREIGN KEY (analyticalfield) REFERENCES at_relation_fields(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE bn_bankstatementline ADD CONSTRAINT BN_FK_BSL_ACCOUNTKEY
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE;

CREATE ASC INDEX ac_x_account_alias
  ON ac_account(alias);

COMMIT;

CREATE EXCEPTION ac_e_invalidaccount 'Invalid account!';
CREATE EXCEPTION ac_e_duplicateaccount 'Duplicate account!';

SET TERM ^;

CREATE OR ALTER TRIGGER AC_AIU_ACCOUNT_CHECKALIAS FOR AC_ACCOUNT
  ACTIVE
  AFTER INSERT OR UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE P CHAR(1) = NULL;
  DECLARE VARIABLE A daccountalias;
BEGIN
  IF (INSERTING OR (NEW.alias <> OLD.alias)) THEN
  BEGIN
    IF (EXISTS
        (SELECT
           root.id, UPPER(TRIM(allacc.alias)), COUNT(*)
         FROM ac_account root
           JOIN ac_account allacc ON allacc.lb > root.lb AND allacc.rb <= root.rb
         WHERE
           root.parent IS NULL
         GROUP BY
           1, 2
         HAVING
           COUNT(*) > 1)
        )
      THEN
        EXCEPTION ac_e_duplicateaccount 'Дублируется наименование ' || NEW.alias;

    IF (NEW.accounttype = 'A' AND (POSITION('.' IN NEW.alias) <> 0)) THEN
      EXCEPTION ac_e_invalidaccount 'Номер счета не может содержать точку. Счет: ' || NEW.alias;

    IF (COALESCE(NEW.disabled, 0) = 0) THEN
    BEGIN
      IF (NEW.accounttype = 'S') THEN
      BEGIN
        SELECT alias FROM ac_account WHERE id = NEW.parent INTO :A;

        IF (POSITION(:A IN NEW.alias) <> 1) THEN
          EXCEPTION ac_e_invalidaccount 'Номер субсчета должен начинаться с номера вышележащего счета/субсчета. Субсчет: ' || NEW.alias;
      END
    END  
  END

  IF (INSERTING OR (NEW.parent IS DISTINCT FROM OLD.parent)
    OR (NEW.accounttype <> OLD.accounttype)) THEN
  BEGIN
    SELECT accounttype FROM ac_account WHERE id = NEW.parent INTO :P;
    P = COALESCE(:P, 'Z');

    IF (NEW.accounttype = 'C' AND NOT (NEW.parent IS NULL)) THEN
      EXCEPTION ac_e_invalidaccount 'План счетов не может входить в другой план счетов или раздел.';

    IF (NEW.accounttype = 'F' AND NOT (:P IN ('C', 'F'))) THEN
      EXCEPTION ac_e_invalidaccount 'Раздел должен входить в план счетов или другой раздел.';

    IF (NEW.accounttype = 'A' AND NOT (:P IN ('C', 'F'))) THEN
      EXCEPTION ac_e_invalidaccount 'Счет должен входить в план счетов или раздел.';

    IF (NEW.accounttype = 'S' AND NOT (:P IN ('A', 'S'))) THEN
      EXCEPTION ac_e_invalidaccount 'Субсчет должен входить в счет или субсчет.';
  END
END
^

SET TERM ; ^

COMMIT;

/*
 *
 *  Список планов счетов, используемых теми или иными
 *  организациями. Каждая организация имеет только один
 *  активный план счетов.
 */

CREATE TABLE ac_companyaccount
(
  companykey       dintkey,             /* Ключ рабочей компании */
  accountkey       dintkey,             /* Ключ плана счетов */

  isactive         dboolean DEFAULT 0,  /* Активен ли план счетов для организации */

  reserved         dinteger
);

COMMIT;

ALTER TABLE ac_companyaccount
  ADD CONSTRAINT ac_pk_companyaccount PRIMARY KEY (companykey, accountkey);

ALTER TABLE ac_companyaccount ADD CONSTRAINT ac_fk_companyaccount_accnt
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_companyaccount ADD CONSTRAINT ac_fk_companyaccount_compny
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany(companykey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/*
 *
 *  Список типовых операций.
 *
 */

CREATE TABLE ac_transaction
(
  id               dintkey,             /* Идентификатор */
  parent           dparent,             /* Родительская ветка */

  lb               dlb,                 /* Левая граница */
  rb               drb,                 /* Правая граница */

  name             dname,               /* Наименование операции  */
  description      dtext180,            /* Описание операции */

  companykey       dforeignkey,         /* Компания, которой принадлежит операция */
                                        /* Но может быть пустым - тогда общая операция*/
  isinternal       dboolean,            /* Внтуренняя операция */

  afull            dsecurity,           /* Дескрипторы безопасности */
  achag            dsecurity,
  aview            dsecurity,

  editiondate      deditiondate,

  disabled         dboolean DEFAULT 0,
  reserved         dinteger,
  AUTOTRANSACTION  DBOOLEAN  /*Признак автоматической операции*/
);

COMMIT;

ALTER TABLE ac_transaction
  ADD CONSTRAINT ac_pk_transaction PRIMARY KEY (id);

ALTER TABLE ac_transaction ADD CONSTRAINT ac_fk_transaction_parent
  FOREIGN KEY (parent) REFERENCES ac_transaction(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_transaction ADD CONSTRAINT ac_fk_transaction_compn
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_document ADD CONSTRAINT gd_fk_doc_transactionkey
  FOREIGN KEY (transactionkey) REFERENCES ac_transaction(id) ON UPDATE CASCADE;

COMMIT;

/*
 *  Часть счета
 *  D - дебит
 *  C - кредит
 */

CREATE DOMAIN daccountpart
  AS CHAR(1)
  NOT NULL
  CHECK (VALUE IN ('D', 'C'));

/*
 *
 *  Список типовых проводок по
 *  типовой операции.
 *
 */

CREATE TABLE ac_trrecord (
  id               dintkey,             /* Идентификатор */
  transactionkey   dmasterkey,          /* Ключ типовой операции */

  description      dtext180,            /* Описание проводки */
  issavenull       dboolean,            /* Сохранять нулевую проводку */
  accountkey       dforeignkey,         /* План счетов */

  afull            dsecurity,           /* Дескрипторы безопасности */
  achag            dsecurity,
  aview            dsecurity,

  editiondate      deditiondate,

  disabled         dboolean DEFAULT 0,
  reserved         dinteger,
  functionkey      dforeignkey,         /* Ключ функции*/
  documenttypekey  dforeignkey,         /* Тип документа проводки */
  functiontemplate dblob80,             /*шаблон функции*/
  documentpart     dtext10              /*тип оброботки документа*/
);

ALTER TABLE ac_trrecord
  ADD CONSTRAINT ac_pk_trrecord PRIMARY KEY (id);

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_tr
  FOREIGN KEY (transactionkey) REFERENCES ac_transaction(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_function
  FOREIGN KEY (functionkey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_documenttype
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_ak
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;


COMMIT;

/*
 *
 *  Бухгалтерская проводка.
 *
 */

CREATE TABLE ac_record(
  id               dintkey,             /* Идентификатор */

  trrecordkey      dintkey,             /* Ключ типовой проводки */
  transactionkey   dintkey,             /* Ключ типовой операции */

  recorddate       ddate NOT NULL,      /* Дата проводки */
  description      dtext180,            /* Описание проводки */

  documentkey      dmasterkey,          /* Ключ документа, по которому создана проводка */
  masterdockey     dintkey,             /* Ключ шапки документа */
  companykey       dintkey,             /* Ключ фирмы по которой сформирована проводка */

/* Сумма по проводке используются для проверки корректности самой проводки */

  debitncu         dcurrency,           /* Сумма проводки по дебету в НДЕ */
  debitcurr        dcurrency,           /* Сумма проводки по дебету в вал */

  creditncu        dcurrency,           /* Сумма проводки по кредиту в НДЕ */
  creditcurr       dcurrency,           /* Сумма проводки по кредиту в вал */

  delayed          dboolean DEFAULT 0,  /* Отложенная проводка или нет */
  incorrect        dboolean DEFAULT 0,  /* Некорректная проводка */

  afull            dsecurity,           /* Дескрипторы безопасности */
  achag            dsecurity,
  aview            dsecurity,

  disabled         dboolean DEFAULT 0,
  reserved         dinteger
);

ALTER TABLE ac_record
  ADD CONSTRAINT ac_pk_record PRIMARY KEY (id);

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_trrec
  FOREIGN KEY (trrecordkey) REFERENCES ac_trrecord(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_tr
  FOREIGN KEY (transactionkey) REFERENCES ac_transaction(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_doc
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_mdoc
  FOREIGN KEY (masterdockey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_record ADD CONSTRAINT ac_fk_record_compn
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE;

/*
 *
 *  Список бухгалтерских проводок
 *
 */


CREATE TABLE ac_entry(
  id               dintkey,             /* Идентификатор */
  recordkey        dmasterkey,          /* Ключ проводки */
  entrydate        ddate,               /* Дата проводки */

  transactionkey   dintkey,             /* Ключ типовой операции */
  documentkey      dmasterkey,          /* Ключ документа, по которому создана проводка */
  masterdockey     dintkey,             /* Ключ шапки документа */
  companykey       dintkey,             /* Ключ фирмы по которой сформирована проводка */


  accountkey       dintkey,             /* Код бухгалтерского счета */

  accountpart      daccountpart,        /* Часть счета D - дебет, K - кредит */

  debitncu         dcurrency,           /* Сумма по дебету в рублях */
  debitcurr        dcurrency,           /* Сумма по дебету в валюте */
  debiteq          dcurrency,           /* Сумма по дебету в эквиваленте */

  creditncu        dcurrency,           /* Сумма по кредиту в рублях */
  creditcurr       dcurrency,           /* Сумма по кредиту в валюте */
  crediteq         dcurrency,           /* Сумма по кредиту в эквиваленте */

  currkey          dintkey,             /* Ключ валюты */

  disabled         dboolean DEFAULT 0,
  reserved         dinteger,
  issimple         DBOOLEAN_NOTNULL NOT NULL  /*Тру казывает на то что
                   данная часть проводки является простой*/
);

COMMIT;

ALTER TABLE ac_entry
  ADD CONSTRAINT ac_pk_entry PRIMARY KEY (id);

ALTER TABLE ac_entry ADD CONSTRAINT ac_fk_entry_rk
  FOREIGN KEY (recordkey) REFERENCES ac_record(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_entry ADD CONSTRAINT gd_fk_entry_ac
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE;

ALTER TABLE ac_entry ADD CONSTRAINT gd_fk_entry_curr
  FOREIGN KEY (currkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

ALTER TABLE AC_ENTRY ADD CONSTRAINT AC_FK_ENTRY_COMPANYKEY
  FOREIGN KEY (COMPANYKEY) REFERENCES GD_COMPANY (CONTACTKEY)
  ON UPDATE CASCADE;

ALTER TABLE AC_ENTRY ADD CONSTRAINT AC_FK_ENTRY_DOCKEY
  FOREIGN KEY (DOCUMENTKEY) REFERENCES GD_DOCUMENT (ID)
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE AC_ENTRY ADD CONSTRAINT AC_FK_ENTRY_MASTERDOCKEY
  FOREIGN KEY (MASTERDOCKEY) REFERENCES GD_DOCUMENT (ID)
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE AC_ENTRY ADD CONSTRAINT AC_FK_ENTRY_TRANSACTIONKEY
  FOREIGN KEY (TRANSACTIONKEY) REFERENCES AC_TRANSACTION (ID)
  ON UPDATE CASCADE;  


COMMIT;

CREATE INDEX AC_ENTRY_ACKEY_ENTRYDATE ON AC_ENTRY (ACCOUNTKEY, ENTRYDATE);
CREATE INDEX AC_ENTRY_ENTRYDATE ON AC_ENTRY (ENTRYDATE);
CREATE INDEX AC_ENTRY_RECKEY_ACPART ON AC_ENTRY (RECORDKEY, ACCOUNTPART);
COMMIT;

/*
* В генератор заносится дата последнего рачета сльдо по проводкам 
* (разница в днях между датой расчета и 17.11.1858)
*/
CREATE GENERATOR gd_g_entry_balance_date;
SET GENERATOR GD_G_ENTRY_BALANCE_DATE TO 0;

/*
*
* Сальдо по проводкам на дату (из генератора gd_g_entry_balance_date)
*  Поля идетичны ac_entry (за исключением неиспользуемых).
*
*/

CREATE TABLE ac_entry_balance (
  id                      dintkey,
  companykey              dintkey, 
  accountkey              dintkey,
  currkey                 dintkey,
  
  debitncu                dcurrency, 
  debitcurr               dcurrency, 
  debiteq                 dcurrency, 
  creditncu               dcurrency, 
  creditcurr              dcurrency, 
  crediteq                dcurrency
);

COMMIT;

ALTER TABLE ac_entry_balance ADD CONSTRAINT pk_ac_entry_bal PRIMARY KEY (id);
ALTER TABLE ac_entry_balance ADD CONSTRAINT gd_fk_entry_bal_ac FOREIGN KEY (accountkey) REFERENCES ac_account (id) ON UPDATE CASCADE;
CREATE INDEX ac_entry_balance_accountkey ON ac_entry_balance (accountkey);

COMMIT;

SET TERM ^;

CREATE OR ALTER TRIGGER ac_bi_entry_balance FOR ac_entry_balance
  ACTIVE
  BEFORE INSERT
  POSITION 0 
AS 
BEGIN 
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0); 
  IF (NEW.debitncu IS NULL) THEN 
    NEW.debitncu = 0; 
  IF (NEW.debitcurr IS NULL) THEN
    NEW.debitcurr = 0; 
  IF (NEW.debiteq IS NULL) THEN
    NEW.debiteq = 0;
  IF (NEW.creditncu IS NULL) THEN 
    NEW.creditncu = 0; 
  IF (NEW.creditcurr IS NULL) THEN 
    NEW.creditcurr = 0; 
  IF (NEW.crediteq IS NULL) THEN 
    NEW.crediteq = 0; 
END
^
SET TERM ;^


/*
 *
 *  Вид скрипта для типовых
 *  проводок:
 *  B - скрипт выполняется перед запуском набора других скриптов
 *  A - скрипт выполняется после запуска набора других скриптов
 *  E - скрипт выполняется только для конкретной позиции проводки
 *
 */

CREATE DOMAIN daccountingscriptkind
  AS CHAR(1)
  CHECK (VALUE IN ('B', 'A', 'E'));

SET TERM ^ ;

CREATE TRIGGER ac_bi_account FOR ac_account
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*
 *
 *  Если изменился активный план счетов
 *  другие счета автоматически делаем не активными.
 */

CREATE OR ALTER TRIGGER ac_bi_companyaccount FOR ac_companyaccount
  BEFORE INSERT OR UPDATE
  POSITION 0
AS
  DECLARE VARIABLE ActiveID INTEGER = NULL;
BEGIN
  SELECT FIRST 1 accountkey FROM ac_companyaccount
    WHERE companykey = NEW.companykey AND isactive = 1
    INTO :ActiveID;

  IF (:ActiveID IS NULL) THEN
    NEW.isactive = 1;
  ELSE
    IF ((:ActiveID <> NEW.accountkey) AND (NEW.isactive = 1)) THEN
      UPDATE ac_companyaccount SET isactive = 0
      WHERE companykey = NEW.companykey AND accountkey = :ActiveID;
END
^

CREATE OR ALTER TRIGGER ac_ad_companyaccount FOR ac_companyaccount
  AFTER DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.isactive = 1) THEN
    UPDATE ac_companyaccount SET isactive = 1
    WHERE companykey = OLD.companykey AND accountkey <> OLD.accountkey
    ROWS 1;
END
^

CREATE OR ALTER TRIGGER ac_entry_do_balance FOR ac_entry
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 15
AS
BEGIN
  IF (GEN_ID(gd_g_entry_balance_date, 0) > 0) THEN
  BEGIN
    /* Триггер обновляет данные в таблице ac_entry_balance в соответсвии с изменениями в ac_entry */
    IF (INSERTING AND ((NEW.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN
    BEGIN
      INSERT INTO ac_entry_balance
        (companykey, accountkey, currkey,
         debitncu, debitcurr, debiteq,
         creditncu, creditcurr, crediteq)
      VALUES
     (NEW.companykey,
      NEW.accountkey,
      NEW.currkey,
      NEW.debitncu,
      NEW.debitcurr,
      NEW.debiteq,
      NEW.creditncu,
      NEW.creditcurr,
      NEW.crediteq);
    END
    ELSE
    IF (UPDATING AND ((OLD.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN
    BEGIN
      INSERT INTO ac_entry_balance
        (companykey, accountkey, currkey,
         debitncu, debitcurr, debiteq,
         creditncu, creditcurr, crediteq)
      VALUES
        (OLD.companykey,
         OLD.accountkey,
         OLD.currkey,
         -OLD.debitncu,
         -OLD.debitcurr,
         -OLD.debiteq,
         -OLD.creditncu,
         -OLD.creditcurr,
         -OLD.crediteq);
      IF ((NEW.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0)) THEN
        INSERT INTO ac_entry_balance
          (companykey, accountkey, currkey,
           debitncu, debitcurr, debiteq,
           creditncu, creditcurr, crediteq)
         VALUES
           (NEW.companykey,
            NEW.accountkey,
            NEW.currkey,
            NEW.debitncu,
            NEW.debitcurr,
            NEW.debiteq,
            NEW.creditncu,
            NEW.creditcurr,
            NEW.crediteq);
    END
    ELSE
    IF (DELETING AND ((OLD.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_entry_balance_date, 0))) THEN
    BEGIN
      INSERT INTO ac_entry_balance
        (companykey, accountkey, currkey,
         debitncu, debitcurr, debiteq,
         creditncu, creditcurr, crediteq)
      VALUES
       (OLD.companykey,
        OLD.accountkey,
        OLD.currkey, 
        -OLD.debitncu, 
        -OLD.debitcurr, 
        -OLD.debiteq,
        -OLD.creditncu, 
        -OLD.creditcurr,
        -OLD.crediteq);
    END 
  END
END
^

CREATE TRIGGER ac_bi_transaction FOR ac_transaction
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*****************************************************/
/*                                                   */
/*    ac_trrecord                                    */
/*    Триггеры и хранимые процедуры                  */
/*                                                   */
/*****************************************************/

CREATE TRIGGER ac_bi_trrecord FOR ac_trrecord
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE EXCEPTION AC_E_CANTDELETETRENTRY 'Can not delete entry'
^

CREATE TRIGGER ac_bd_trrecord FOR ac_trrecord
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  /* Нельзя удалять зарезервированную операцию  */
  IF (OLD.ID < 147000000) THEN
    EXCEPTION AC_E_CANTDELETETRENTRY;
END
^

/*****************************************************/
/*                                                   */
/*    ac_record                                      */
/*    Триггеры и хранимые процедуры                  */
/*                                                   */
/*****************************************************/

CREATE GLOBAL TEMPORARY TABLE ac_incorrect_record (
  id    dintkey,
  CONSTRAINT ac_pk_incorrect_record PRIMARY KEY (id)
)
  ON COMMIT DELETE ROWS
^

CREATE EXCEPTION ac_e_invalidentry 'Invalid entry'
^

CREATE OR ALTER TRIGGER ac_bi_record FOR ac_record
  BEFORE INSERT
  POSITION 31700
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  NEW.debitncu = 0;
  NEW.debitcurr = 0;
  NEW.creditncu = 0;
  NEW.creditcurr = 0;

  INSERT INTO ac_incorrect_record (id) VALUES (NEW.id);
END
^

CREATE OR ALTER TRIGGER ac_bu_record FOR ac_record
  BEFORE UPDATE
  POSITION 31700
AS
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK') IS NULL) THEN
  BEGIN
    NEW.debitncu = OLD.debitncu;
    NEW.creditncu = OLD.creditncu;
    NEW.debitcurr = OLD.debitcurr;
    NEW.creditcurr = OLD.creditcurr;
  END

  IF (NEW.debitncu IS DISTINCT FROM OLD.debitncu OR
    NEW.creditncu IS DISTINCT FROM OLD.creditncu) THEN
  BEGIN
    IF (NEW.debitncu IS DISTINCT FROM NEW.creditncu) THEN
      UPDATE OR INSERT INTO ac_incorrect_record (id) VALUES (NEW.id)
        MATCHING (id);
    ELSE
      DELETE FROM ac_incorrect_record WHERE id = NEW.id;
  END

  IF (NEW.recorddate <> OLD.recorddate
    OR NEW.transactionkey <> OLD.transactionkey
    OR NEW.documentkey <> OLD.documentkey
    OR NEW.masterdockey <> OLD.masterdockey
    OR NEW.companykey <> OLD.companykey) THEN
  BEGIN
    WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK');
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK', 1);
    UPDATE ac_entry e
    SET e.entrydate = NEW.recorddate,
      e.transactionkey = NEW.transactionkey,
      e.documentkey = NEW.documentkey,
      e.masterdockey = NEW.masterdockey,
      e.companykey = NEW.companykey
    WHERE
      e.recordkey = NEW.id;
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK', NULL);
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE OR ALTER TRIGGER ac_ad_record FOR ac_record
  AFTER DELETE
  POSITION 31700
AS
BEGIN
  DELETE FROM ac_incorrect_record WHERE id = OLD.id;
END
^

CREATE OR ALTER TRIGGER ac_tc_record
  ACTIVE
  ON TRANSACTION COMMIT
  POSITION 9000
AS
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE STM VARCHAR(512);
  DECLARE VARIABLE DNCU DCURRENCY;
  DECLARE VARIABLE CNCU DCURRENCY;
  DECLARE VARIABLE OFFBALANCE INTEGER;
  DECLARE VARIABLE EID INTEGER;
BEGIN
  IF (EXISTS (SELECT * FROM ac_incorrect_record)) THEN
  BEGIN
    STM =
      'SELECT r.id, r.debitncu, r.creditncu, a.offbalance, e.id ' ||
      'FROM ac_record r ' ||
      '  JOIN ac_incorrect_record ir ON ir.id = r.id ' ||
      '  LEFT JOIN ac_entry e ON e.recordkey = r.id ' ||
      '  LEFT JOIN ac_account a ON a.id = e.accountkey';

    FOR
      EXECUTE STATEMENT (:STM)
      INTO :ID, :DNCU, :CNCU, :OFFBALANCE, :EID
    DO BEGIN
      IF ((:EID IS NULL)
        OR ((:OFFBALANCE IS DISTINCT FROM 1) AND (:DNCU <> :CNCU))) THEN
      BEGIN
        EXCEPTION ac_e_invalidentry 'Попытка сохранить некорректную проводку с ИД: ' || :ID;
      END
    END
  END
END
^

/****************************************************/
/**                                                **/
/**   Перед сохранением проверяем уникальный       **/
/**   идентификатор и значение суммовых полей      **/
/**                                                **/
/****************************************************/

CREATE OR ALTER TRIGGER ac_bi_entry FOR ac_entry
  BEFORE INSERT
  POSITION 31700
AS
  DECLARE VARIABLE Cnt INTEGER = 0;
  DECLARE VARIABLE Cnt2 INTEGER = 0;
  DECLARE VARIABLE WasSetIsSimple INTEGER;
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.accountpart = 'C') THEN
  BEGIN
    NEW.debitncu = 0;
    NEW.debitcurr = 0;
    NEW.debiteq = 0;
    NEW.creditncu = COALESCE(NEW.creditncu, 0);
    NEW.creditcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.creditcurr, 0));
    NEW.crediteq = COALESCE(NEW.crediteq, 0);
  END ELSE
  BEGIN
    NEW.creditncu = 0;
    NEW.creditcurr = 0;
    NEW.crediteq = 0;
    NEW.debitncu = COALESCE(NEW.debitncu, 0);
    NEW.debitcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.debitcurr, 0));
    NEW.debiteq = COALESCE(NEW.debiteq, 0);
  END

  SELECT recorddate, transactionkey, documentkey, masterdockey, companykey
  FROM ac_record
  WHERE id = NEW.recordkey
  INTO NEW.entrydate, NEW.transactionkey, NEW.documentkey, NEW.masterdockey, NEW.companykey;

  SELECT
    COALESCE(SUM(IIF(accountpart = NEW.accountpart, 1, 0)), 0),
    COALESCE(SUM(IIF(accountpart <> NEW.accountpart, 1, 0)), 0)
  FROM ac_entry
  WHERE recordkey = NEW.recordkey
  INTO :Cnt, :Cnt2;

  IF (:Cnt > 0 AND :Cnt2 > 1) THEN
    EXCEPTION ac_e_invalidentry;

  IF (:Cnt = 0) THEN
    NEW.issimple = 1;
  ELSE BEGIN
    NEW.issimple = 0;
    IF (:Cnt = 1) THEN
    BEGIN
      WasSetIsSimple = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE');
      IF (:WasSetIsSimple IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', 1);
      UPDATE ac_entry SET issimple = 0
      WHERE recordkey = NEW.recordkey AND accountpart = NEW.accountpart
        AND id <> NEW.id;
      IF (:WasSetIsSimple IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
    EXCEPTION;
  END
END
^

CREATE OR ALTER TRIGGER ac_ai_entry FOR ac_entry
  AFTER INSERT
  POSITION 31700
AS
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', 1);
  UPDATE
    ac_record
  SET
    debitncu = debitncu + NEW.debitncu,
    creditncu = creditncu + NEW.creditncu,
    debitcurr = debitcurr + NEW.debitcurr,
    creditcurr = creditcurr + NEW.creditcurr
  WHERE
    id = NEW.recordkey;
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE OR ALTER TRIGGER ac_bu_entry FOR ac_entry
  BEFORE UPDATE
  POSITION 31700
AS
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE') IS NOT NULL) THEN
    EXIT;

  NEW.recordkey = OLD.recordkey;

  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_UNLOCK') IS NULL) THEN
  BEGIN
    NEW.entrydate = OLD.entrydate;
    NEW.transactionkey = OLD.transactionkey;
    NEW.documentkey = OLD.documentkey;
    NEW.masterdockey = OLD.masterdockey;
    NEW.companykey = OLD.companykey;
    NEW.issimple = OLD.issimple;
  END

  IF (NEW.currkey IS NULL) THEN
  BEGIN
    NEW.creditcurr = 0;
    NEW.debitcurr = 0;
  END

  IF (NEW.accountpart <> OLD.accountpart) THEN
  BEGIN
    IF (NEW.accountpart = 'C') THEN
    BEGIN
      NEW.debitncu = 0;
      NEW.debitcurr = 0;
      NEW.debiteq = 0;
      NEW.creditncu = COALESCE(NEW.creditncu, 0);
      NEW.creditcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.creditcurr, 0));
      NEW.crediteq = COALESCE(NEW.crediteq, 0);
    END ELSE
    BEGIN
      NEW.creditncu = 0;
      NEW.creditcurr = 0;
      NEW.crediteq = 0;
      NEW.debitncu = COALESCE(NEW.debitncu, 0);
      NEW.debitcurr = IIF(NEW.currkey IS NULL, 0, COALESCE(NEW.debitcurr, 0));
      NEW.debiteq = COALESCE(NEW.debiteq, 0);
    END
  END
END
^

CREATE OR ALTER TRIGGER ac_au_entry FOR ac_entry
  AFTER UPDATE
  POSITION 31700
AS
  DECLARE VARIABLE WasUnlock INTEGER;
  DECLARE VARIABLE WasSetIsSimple INTEGER;
  DECLARE VARIABLE Cnt INTEGER;
  DECLARE VARIABLE Cnt2 INTEGER;
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE') IS NOT NULL) THEN
    EXIT;

  IF ((OLD.debitncu <> NEW.debitncu) or (OLD.creditncu <> NEW.creditncu) or
      (OLD.debitcurr <> NEW.debitcurr) or (OLD.creditcurr <> NEW.creditcurr))
  THEN BEGIN
    WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK');
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', 1);
    UPDATE ac_record SET debitncu = debitncu - OLD.debitncu + NEW.debitncu,
      creditncu = creditncu - OLD.creditncu + NEW.creditncu,
      debitcurr = debitcurr - OLD.debitcurr + NEW.debitcurr,
      creditcurr = creditcurr - OLD.creditcurr + NEW.creditcurr
    WHERE
      id = OLD.recordkey;
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);
  END

  IF (NEW.accountpart <> OLD.accountpart) THEN
  BEGIN
    SELECT
      COALESCE(SUM(IIF(accountpart = NEW.accountpart, 1, 0)), 0),
      COALESCE(SUM(IIF(accountpart = OLD.accountpart, 1, 0)), 0)
    FROM ac_entry
    WHERE recordkey = NEW.recordkey AND id <> NEW.id
    INTO :Cnt, :Cnt2;

    IF (:Cnt > 1 AND :Cnt2 > 1) THEN
      EXCEPTION ac_e_invalidentry;

    WasSetIsSimple = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE');
    IF (:WasSetIsSimple IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', 1);
    UPDATE ac_entry SET
      issimple = IIF(accountpart = NEW.accountpart,
        IIF(:Cnt > 1, 0, 1),
        IIF(:Cnt2 > 1, 0, 1))
    WHERE recordkey = NEW.recordkey;
    IF (:WasSetIsSimple IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
    EXCEPTION;
  END
END
^

CREATE OR ALTER TRIGGER ac_ad_entry FOR ac_entry
  AFTER DELETE
  POSITION 31700
AS
  DECLARE VARIABLE Cnt INTEGER = 0;
  DECLARE VARIABLE WasSetIsSimple INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NOT EXISTS(SELECT id FROM ac_entry WHERE recordkey = OLD.recordkey)) THEN
    DELETE FROM ac_record WHERE id = OLD.recordkey;
  ELSE BEGIN
    WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK');
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', 1);
    UPDATE ac_record SET
      debitncu = debitncu - OLD.debitncu,
      creditncu = creditncu - OLD.creditncu,
      debitcurr = debitcurr - OLD.debitcurr,
      creditcurr = creditcurr - OLD.creditcurr
    WHERE
      id = OLD.recordkey;
    IF (:WasUnlock IS NULL) THEN
      RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);

    IF (OLD.issimple = 0) THEN
    BEGIN
      SELECT COUNT(*) FROM ac_entry
      WHERE recordkey = OLD.recordkey AND accountpart = OLD.accountpart
      INTO :Cnt;

      IF (:Cnt = 1) THEN
      BEGIN
        WasSetIsSimple = RDB$GET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE');
        IF (:WasSetIsSimple IS NULL) THEN
          RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', 1);
        UPDATE ac_entry SET issimple = 1
        WHERE recordkey = OLD.recordkey AND accountpart = OLD.accountpart;
        IF (:WasSetIsSimple IS NULL) THEN
          RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_RECORD_UNLOCK', NULL);
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AC_ENTRY_SET_ISSIMPLE', NULL);
    EXCEPTION;
  END
END
^

CREATE TRIGGER ac_bi_entry_block FOR ac_entry
  INACTIVE
  BEFORE INSERT
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((NEW.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
      JOIN ac_record r ON r.documentkey = d.id
    WHERE
      r.id = NEW.recordkey
    INTO
      :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END  
  END
END
^

CREATE TRIGGER ac_bu_entry_block FOR ac_entry
  INACTIVE
  BEFORE UPDATE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (((NEW.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0))
      OR ((OLD.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0))) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
      JOIN ac_record r ON r.documentkey = d.id
    WHERE
      r.id = NEW.recordkey
    INTO
      :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

CREATE TRIGGER ac_bd_entry_block FOR ac_entry
  INACTIVE
  BEFORE DELETE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((OLD.entrydate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
      JOIN ac_record r ON r.documentkey = d.id
    WHERE
      r.id = OLD.recordkey
    INTO
      :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

/* Болванка процедуры для создания оборотной ведомости */

CREATE PROCEDURE AC_ACCOUNTEXSALDO (
    DATEEND DATE,
    ACCOUNTKEY INTEGER,
    FIELDNAME VARCHAR(60),
    COMPANYKEY INTEGER,
    ALLHOLDINGCOMPANIES INTEGER,
    INGROUP INTEGER,
    CURRKEY INTEGER)
RETURNS
    (DEBITSALDO NUMERIC(15,4),
    CREDITSALDO NUMERIC(15,4),
    CURRDEBITSALDO NUMERIC(15,4),
    CURRCREDITSALDO NUMERIC(15,4),
    EQDEBITSALDO NUMERIC(15,4),
    EQCREDITSALDO NUMERIC(15,4))
AS
BEGIN
  DEBITSALDO = 0;
  CREDITSALDO = 0;
  CURRDEBITSALDO = 0; 
  CURRCREDITSALDO = 0;
  EQDEBITSALDO = 0;
  EQCREDITSALDO = 0;
  SUSPEND;
END
^

/* Вспомогательная процедура для создания оборотной ведомости с помощью расчитанного сальдо */

CREATE OR ALTER PROCEDURE AC_ACCOUNTEXSALDO_BAL (
    DATEEND DATE,
    ACCOUNTKEY INTEGER,
    FIELDNAME VARCHAR(60),
    COMPANYKEY INTEGER,
    ALLHOLDINGCOMPANIES INTEGER,
    CURRKEY INTEGER)
RETURNS ( 
    DEBITSALDO NUMERIC(15, 4),
    CREDITSALDO NUMERIC(15, 4),
    CURRDEBITSALDO NUMERIC(15, 4),
    CURRCREDITSALDO NUMERIC(15, 4),
    EQDEBITSALDO NUMERIC(15, 4),
    EQCREDITSALDO NUMERIC(15, 4))
 AS
   DECLARE VARIABLE SALDO NUMERIC(15, 4); 
   DECLARE VARIABLE SALDOCURR NUMERIC(15, 4); 
   DECLARE VARIABLE SALDOEQ NUMERIC(15, 4); 
   DECLARE VARIABLE TEMPVAR varchar(60); 
   DECLARE VARIABLE CLOSEDATE DATE; 
   DECLARE VARIABLE CK INTEGER; 
   DECLARE VARIABLE SQLStatement VARCHAR(2048);
   DECLARE VARIABLE HoldingList VARCHAR(1024) = '';
   DECLARE VARIABLE CurrCondition_E VARCHAR(1024) = '';
   DECLARE VARIABLE CurrCondition_Bal VARCHAR(1024) = '';
 BEGIN 
   DEBITSALDO = 0; 
   CREDITSALDO = 0; 
   CURRDEBITSALDO = 0; 
   CURRCREDITSALDO = 0; 
   EQDEBITSALDO = 0; 
   EQCREDITSALDO = 0; 
   CLOSEDATE = CAST((CAST('17.11.1858' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); 
 
   IF (:AllHoldingCompanies = 1) THEN
   BEGIN
     SELECT LIST(h.companykey, ',')
     FROM gd_holding h
     WHERE h.holdingkey = :companykey
     INTO :HoldingList; 
     HoldingList = COALESCE(:HoldingList, '');
   END

   HoldingList = :CompanyKey || IIF(:HoldingList = '', '', ',' || :HoldingList);

   IF (:CurrKey > 0) THEN
   BEGIN
     CurrCondition_E =   ' AND (e.currkey   = ' || :currkey || ') ';
     CurrCondition_Bal = ' AND (bal.currkey = ' || :currkey || ') ';
   END
 
   IF (:dateend >= :CLOSEDATE) THEN 
   BEGIN 
     sqlstatement = 
       'SELECT 
         main.' || FIELDNAME || ', 
         SUM(main.debitncu - main.creditncu), 
         SUM(main.debitcurr - main.creditcurr), 
         SUM(main.debiteq - main.crediteq), 
         main.companykey 
       FROM 
       ( 
         SELECT 
           bal.' || FIELDNAME || ', 
           bal.debitncu, bal.creditncu, 
           bal.debitcurr, bal.creditcurr, 
           bal.debiteq, bal.crediteq, 
           bal.companykey 
         FROM 
           ac_entry_balance bal 
         WHERE 
           bal.accountkey = ' || CAST(:accountkey AS VARCHAR(20)) || ' 
             AND (bal.companykey IN (' || :HoldingList || '))' 
            || :CurrCondition_Bal || '
 
         UNION ALL 
 
         SELECT 
           e.' || FIELDNAME || ', 
           e.debitncu, e.creditncu, 
           e.debitcurr, e.creditcurr, 
           e.debiteq, e.crediteq, 
           e.companykey 
         FROM 
           ac_entry e 
         WHERE 
           e.accountkey = ' || CAST(:accountkey AS VARCHAR(20)) || ' 
           AND e.entrydate >= ''' || CAST(:closedate AS VARCHAR(20)) || ''' 
           AND e.entrydate < ''' || CAST(:dateend AS VARCHAR(20)) || ''' 
           AND (e.companykey IN (' || :HoldingList || '))'
          || :CurrCondition_E || '
 
       ) main 
       GROUP BY 
         main.' || FIELDNAME || ', main.companykey'; 
   END 
   ELSE 
   BEGIN 
     sqlstatement = 
       'SELECT 
         main.' || FIELDNAME || ', 
         SUM(main.debitncu - main.creditncu), 
         SUM(main.debitcurr - main.creditcurr), 
         SUM(main.debiteq - main.crediteq), 
         main.companykey 
       FROM 
       ( 
         SELECT 
           bal.' || FIELDNAME || ', 
           bal.debitncu, bal.creditncu, 
           bal.debitcurr, bal.creditcurr, 
           bal.debiteq, bal.crediteq, 
           bal.companykey 
         FROM 
           ac_entry_balance bal 
         WHERE 
           bal.accountkey = ' || CAST(:accountkey AS VARCHAR(20)) || ' 
             AND (bal.companykey IN (' || :HoldingList || '))'
            || :CurrCondition_Bal || '
 
         UNION ALL 
 
         SELECT 
           e.' || FIELDNAME || ', 
          - e.debitncu, - e.creditncu, 
          - e.debitcurr, - e.creditcurr, 
          - e.debiteq, - e.crediteq, 
          e.companykey 
         FROM 
           ac_entry e 
         WHERE 
           e.accountkey = ' || CAST(:accountkey AS VARCHAR(20)) || ' 
           AND e.entrydate >= ''' || CAST(:dateend AS VARCHAR(20)) || ''' 
           AND e.entrydate < ''' || CAST(:closedate AS VARCHAR(20)) || ''' 
           AND (e.companykey IN (' || :HoldingList || '))'
           || :CurrCondition_E || '
        ) main 
       GROUP BY 
         main.' || FIELDNAME || ', main.companykey'; 
   END 
 
   FOR 
     EXECUTE STATEMENT 
       sqlstatement 
     INTO 
       :TEMPVAR, :SALDO, :SALDOCURR, :SALDOEQ, :CK 
   DO 
   BEGIN 
     SALDO = COALESCE(:SALDO, 0); 
     IF (SALDO > 0) THEN 
       DEBITSALDO = DEBITSALDO + SALDO; 
     ELSE 
       CREDITSALDO = CREDITSALDO - SALDO; 
     SALDOCURR = COALESCE(:SALDOCURR, 0); 
     IF (SALDOCURR > 0) THEN 
       CURRDEBITSALDO = CURRDEBITSALDO + SALDOCURR; 
     ELSE 
       CURRCREDITSALDO = CURRCREDITSALDO - SALDOCURR; 
     SALDOEQ = COALESCE(:SALDOEQ, 0); 
     IF (SALDOEQ > 0) THEN 
       EQDEBITSALDO = EQDEBITSALDO + SALDOEQ; 
     ELSE 
       EQCREDITSALDO = EQCREDITSALDO - SALDOEQ; 
   END 
   SUSPEND; 
 END
^

/* Процедура для создания оборотной ведомости */
CREATE PROCEDURE AC_CIRCULATIONLIST (
    datebegin date,
    dateend date,
    companykey integer,
    allholdingcompanies integer,
    accountkey integer,
    ingroup integer,
    currkey integer,
    dontinmove integer)
returns (
    alias varchar(20),
    name varchar(180),
    id integer,
    ncu_begin_debit numeric(15,4),
    ncu_begin_credit numeric(15,4),
    ncu_debit numeric(15,4),
    ncu_credit numeric(15,4),
    ncu_end_debit numeric(15,4),
    ncu_end_credit numeric(15,4),
    curr_begin_debit numeric(15,4),
    curr_begin_credit numeric(15,4),
    curr_debit numeric(15,4),
    curr_credit numeric(15,4),
    curr_end_debit numeric(15,4),
    curr_end_credit numeric(15,4),
    eq_begin_debit numeric(15,4),
    eq_begin_credit numeric(15,4),
    eq_debit numeric(15,4),
    eq_credit numeric(15,4),
    eq_end_debit numeric(15,4),
    eq_end_credit numeric(15,4),
    offbalance integer)
as
  DECLARE VARIABLE ACTIVITY CHAR(1);
  DECLARE VARIABLE SALDO NUMERIC(15,4);
  DECLARE VARIABLE SALDOCURR NUMERIC(15,4);
  DECLARE VARIABLE SALDOEQ NUMERIC(15,4);
  DECLARE VARIABLE FIELDNAME VARCHAR(60);
  DECLARE VARIABLE LB INTEGER;
  DECLARE VARIABLE RB INTEGER;
BEGIN
  /* Procedure Text */
 
  SELECT c.lb, c.rb FROM ac_account c                                                                  
  WHERE c.id = :ACCOUNTKEY 
  INTO :lb, :rb;                                                                                       
                                                                                                       
  FOR                                                                                                  
    SELECT a.ID, a.ALIAS, a.activity, f.fieldname, a.Name, a.offbalance                                
    FROM ac_account a LEFT JOIN at_relation_fields f ON a.analyticalfield = f.id
    WHERE                                                                                              
      a.accounttype IN ('A', 'S') AND                                                                  
      a.LB >= :LB AND a.RB <= :RB AND a.alias <> '00'                                                  
    INTO :id, :ALIAS, :activity, :fieldname, :name, :offbalance                                        
  DO                                                                                                   
  BEGIN                                                                                                
    NCU_BEGIN_DEBIT = 0;                                                                               
    NCU_BEGIN_CREDIT = 0;                                                                              
    CURR_BEGIN_DEBIT = 0;                                                                              
    CURR_BEGIN_CREDIT = 0;                                                                             
    EQ_BEGIN_DEBIT = 0;                                                                                
    EQ_BEGIN_CREDIT = 0;  
                                                                                                       
    IF ((activity <> 'B') OR (fieldname IS NULL)) THEN                                                 
    BEGIN  
      IF ( ALLHOLDINGCOMPANIES = 0) THEN  
      SELECT                                                                                           
        SUM(e.DEBITNCU - e.CREDITNCU),                                                                 
        SUM(e.DEBITCURR - e.CREDITCURR),  
        SUM(e.DEBITEQ - e.CREDITEQ)                                                                    
      FROM                                                                                             
        ac_entry e                                                                                     
      WHERE  
        e.accountkey = :id AND e.entrydate < :datebegin AND                                            
        (e.companykey = :companykey) AND  
        ((0 = :currkey) OR (e.currkey = :currkey))  
      INTO :SALDO,                                                                                     
        :SALDOCURR, :SALDOEQ;                                                                          
      ELSE  
      SELECT
        SUM(e.DEBITNCU - e.CREDITNCU),                                                                 
        SUM(e.DEBITCURR - e.CREDITCURR),                                                               
        SUM(e.DEBITEQ - e.CREDITEQ)                                                                    
      FROM                                                                                             
        ac_entry e                                                                                     
      WHERE 
        e.accountkey = :id AND e.entrydate < :datebegin AND                                            
        (e.companykey = :companykey or e.companykey IN ( 
          SELECT                                                                                       
            h.companykey                                                                               
          FROM                                                                                         
            gd_holding h                                                                               
          WHERE                                                                                        
            h.holdingkey = :companykey)) AND  
        ((0 = :currkey) OR (e.currkey = :currkey))  
      INTO :SALDO,                                                                                     
        :SALDOCURR, :SALDOEQ;                                                                          
                                                                                                       
      IF (SALDO IS NULL) THEN                                                                          
        SALDO = 0;                                                                                     
                                                                                                       
      IF (SALDOCURR IS NULL) THEN  
        SALDOCURR = 0;                                                                                 
                                                                                                       
      IF (SALDOEQ IS NULL) THEN                                                                        
        SALDOEQ = 0;                                                                                   
                                                                                                       
                                                                                                       
      IF (SALDO > 0) THEN                                                                              
        NCU_BEGIN_DEBIT = SALDO;
      ELSE                                                                                             
        NCU_BEGIN_CREDIT = 0 - SALDO;                                                                  
                                                                                                       
      IF (SALDOCURR > 0) THEN                                                                          
        CURR_BEGIN_DEBIT = SALDOCURR;                                                                  
      ELSE                                                                                             
        CURR_BEGIN_CREDIT = 0 - SALDOCURR;                                                             
                                                                                                       
      IF (SALDOEQ > 0) THEN                                                                            
        EQ_BEGIN_DEBIT = SALDOEQ;                                                                      
      ELSE                                                                                             
        EQ_BEGIN_CREDIT = 0 - SALDOEQ;                                                                 
    END                                                                                                
    ELSE                                                                                               
    BEGIN                                                                                              
      SELECT                                                                                           
        DEBITsaldo,                                                                                    
        creditsaldo  
      FROM 
        AC_ACCOUNTEXSALDO(:datebegin, :ID, :FIELDNAME, :COMPANYKEY,                                    
          :allholdingcompanies, :INGROUP, :currkey) 
      INTO                                                                                             
        :NCU_BEGIN_DEBIT,                                                                              
        :NCU_BEGIN_CREDIT;                                                                             
    END  
                                                                                                       
    IF (ALLHOLDINGCOMPANIES = 0) THEN  
    BEGIN 
      IF (DONTINMOVE = 1) THEN 
        SELECT
          SUM(e.DEBITNCU), 
          SUM(e.CREDITNCU), 
          SUM(e.DEBITCURR), 
          SUM(e.CREDITCURR), 
          SUM(e.DEBITEQ), 
          SUM(e.CREDITEQ) 
        FROM 
          ac_entry e 
        WHERE 
          e.accountkey = :id AND e.entrydate >= :datebegin AND 
          e.entrydate <= :dateend AND (e.companykey = :companykey) AND 
          ((0 = :currkey) OR (e.currkey = :currkey)) AND 
          NOT EXISTS( SELECT e_m.id FROM  ac_entry e_m 
              JOIN ac_entry e_cm ON e_cm.recordkey=e_m.recordkey AND 
               e_cm.accountpart <> e_m.accountpart AND 
               e_cm.accountkey=e_m.accountkey AND 
               (e_m.debitncu=e_cm.creditncu OR 
                e_m.creditncu=e_cm.debitncu OR 
                e_m.debitcurr=e_cm.creditcurr OR 
                e_m.creditcurr=e_cm.debitcurr) 
              WHERE e_m.id=e.id) 
        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, EQ_CREDIT; 
      ELSE 
        SELECT 
          SUM(e.DEBITNCU), 
          SUM(e.CREDITNCU), 
          SUM(e.DEBITCURR), 
          SUM(e.CREDITCURR), 
          SUM(e.DEBITEQ), 
          SUM(e.CREDITEQ)
        FROM 
          ac_entry e 
        WHERE 
          e.accountkey = :id AND e.entrydate >= :datebegin AND 
          e.entrydate <= :dateend AND (e.companykey = :companykey) AND 
          ((0 = :currkey) OR (e.currkey = :currkey)) 
        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, EQ_CREDIT; 
    END 
    ELSE 
    BEGIN 
      IF (DONTINMOVE = 1) THEN 
        SELECT 
          SUM(e.DEBITNCU), 
          SUM(e.CREDITNCU), 
          SUM(e.DEBITCURR), 
          SUM(e.CREDITCURR), 
          SUM(e.DEBITEQ), 
          SUM(e.CREDITEQ) 
        FROM 
          ac_entry e 
        WHERE 
          e.accountkey = :id AND e.entrydate >= :datebegin AND 
          e.entrydate <= :dateend AND 
          (e.companykey = :companykey or e.companykey IN ( 
          SELECT h.companykey FROM gd_holding h 
           WHERE h.holdingkey = :companykey)) AND 
          ((0 = :currkey) OR (e.currkey = :currkey)) AND 
          NOT EXISTS( SELECT e_m.id FROM  ac_entry e_m 
              JOIN ac_entry e_cm ON e_cm.recordkey=e_m.recordkey AND 
               e_cm.accountpart <> e_m.accountpart AND
               e_cm.accountkey=e_m.accountkey AND 
               (e_m.debitncu=e_cm.creditncu OR 
                e_m.creditncu=e_cm.debitncu OR 
                e_m.debitcurr=e_cm.creditcurr OR 
                e_m.creditcurr=e_cm.debitcurr) 
              WHERE e_m.id=e.id) 
        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, :EQ_CREDIT; 
      ELSE 
        SELECT 
          SUM(e.DEBITNCU), 
          SUM(e.CREDITNCU), 
          SUM(e.DEBITCURR), 
          SUM(e.CREDITCURR), 
          SUM(e.DEBITEQ), 
          SUM(e.CREDITEQ) 
        FROM 
          ac_entry e 
        WHERE 
          e.accountkey = :id AND e.entrydate >= :datebegin AND 
          e.entrydate <= :dateend AND 
          (e.companykey = :companykey or e.companykey IN ( 
          SELECT h.companykey FROM gd_holding h 
           WHERE h.holdingkey = :companykey)) AND 
          ((0 = :currkey) OR (e.currkey = :currkey)) 
        INTO :NCU_DEBIT, :NCU_CREDIT, :CURR_DEBIT, CURR_CREDIT, :EQ_DEBIT, :EQ_CREDIT; 
    END 
                                                                                                             
    IF (NCU_DEBIT IS NULL) THEN                                                                        
      NCU_DEBIT = 0;                                                                                   

    IF (NCU_CREDIT IS NULL) THEN                                                                       
      NCU_CREDIT = 0;                                                                                  
  
    IF (CURR_DEBIT IS NULL) THEN                                                                       
      CURR_DEBIT = 0;                                                                                  
                                                                                                       
    IF (CURR_CREDIT IS NULL) THEN                                                                      
      CURR_CREDIT = 0;                                                                                 
                                                                                                       
    IF (EQ_DEBIT IS NULL) THEN  
      EQ_DEBIT = 0;                                                                                    
                                                                                                       
    IF (EQ_CREDIT IS NULL) THEN                                                                        
      EQ_CREDIT = 0;                                                                                   
                                                                                                       
    NCU_END_DEBIT = 0;                                                                                 
    NCU_END_CREDIT = 0;                                                                                
    CURR_END_DEBIT = 0;                                                                                
    CURR_END_CREDIT = 0;                                                                               
    EQ_END_DEBIT = 0;                                                                                  
    EQ_END_CREDIT = 0;                                                                                 
                                                                                                       
    IF ((ACTIVITY <> 'B') OR (FIELDNAME IS NULL)) THEN                                                 
    BEGIN                                                                                              
      SALDO = NCU_BEGIN_DEBIT - NCU_BEGIN_CREDIT + NCU_DEBIT - NCU_CREDIT;                             
      IF (SALDO > 0) THEN 
        NCU_END_DEBIT = SALDO;                                                                         
      ELSE 
        NCU_END_CREDIT = 0 - SALDO;                                                                    

      SALDOCURR = CURR_BEGIN_DEBIT - CURR_BEGIN_CREDIT + CURR_DEBIT - CURR_CREDIT;                     
      IF (SALDOCURR > 0) THEN                                                                          
        CURR_END_DEBIT = SALDOCURR;                                                                    
      ELSE                                                                                             
        CURR_END_CREDIT = 0 - SALDOCURR;                                                               
  
      SALDOEQ = EQ_BEGIN_DEBIT - EQ_BEGIN_CREDIT + EQ_DEBIT - EQ_CREDIT;                               
      IF (SALDOEQ > 0) THEN                                                                            
        EQ_END_DEBIT = SALDOEQ;                                                                        
      ELSE                                                                                             
        EQ_END_CREDIT = 0 - SALDOEQ;                                                                   
    END                                                                                                
    ELSE  
    BEGIN  
      IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR  
        (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR  
        (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR  
        (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0) OR  
        (EQ_BEGIN_DEBIT <> 0) OR (EQ_BEGIN_CREDIT <> 0) OR  
        (EQ_DEBIT <> 0) OR (EQ_CREDIT <> 0)) THEN  
      BEGIN  
        SELECT  
          DEBITsaldo, creditsaldo,  
          CurrDEBITsaldo, Currcreditsaldo,  
          EQDEBITsaldo, EQcreditsaldo  
        FROM AC_ACCOUNTEXSALDO(:DATEEND + 1, :ID, :FIELDNAME, :COMPANYKEY,  
          :allholdingcompanies, :INGROUP, :currkey)  
        INTO :NCU_END_DEBIT, :NCU_END_CREDIT, :CURR_END_DEBIT, :CURR_END_CREDIT, :EQ_END_DEBIT, :EQ_END_CREDIT;  
      END  
    END
    IF ((NCU_BEGIN_DEBIT <> 0) OR (NCU_BEGIN_CREDIT <> 0) OR  
      (NCU_DEBIT <> 0) OR (NCU_CREDIT <> 0) OR  
      (CURR_BEGIN_DEBIT <> 0) OR (CURR_BEGIN_CREDIT <> 0) OR  
      (CURR_DEBIT <> 0) OR (CURR_CREDIT <> 0) OR  
      (EQ_BEGIN_DEBIT <> 0) OR (EQ_BEGIN_CREDIT <> 0) OR  
      (EQ_DEBIT <> 0) OR (EQ_CREDIT <> 0)) THEN  
    SUSPEND;  
  END  
END^

/* Процедура для создания оборотной ведомости с помощью расчитанного сальдо */
CREATE OR ALTER PROCEDURE ac_circulationlist_bal(
  datebegin DATE,
  dateend DATE,
  companykey INTEGER,
  allholdingcompanies INTEGER,
  accountkey INTEGER,
  currkey INTEGER,
  dontinmove INTEGER)
RETURNS (
  alias VARCHAR(20),
  name VARCHAR(180),
  id INTEGER,
  ncu_begin_debit NUMERIC(15,4),
  ncu_begin_credit NUMERIC(15,4),
  ncu_debit NUMERIC(15,4),
  ncu_credit NUMERIC(15,4),
  ncu_end_debit NUMERIC(15,4),
  ncu_end_credit NUMERIC(15,4),
  curr_begin_debit NUMERIC(15,4),
  curr_begin_credit NUMERIC(15,4),
  curr_debit NUMERIC(15,4),
  curr_credit NUMERIC(15,4),
  curr_end_debit NUMERIC(15,4),
  curr_end_credit NUMERIC(15,4),
  eq_begin_debit NUMERIC(15,4),
  eq_begin_credit NUMERIC(15,4),
  eq_debit NUMERIC(15,4),
  eq_credit NUMERIC(15,4),
  eq_end_debit NUMERIC(15,4),
  eq_end_credit NUMERIC(15,4),
  offbalance INTEGER)
AS
  DECLARE VARIABLE activity CHAR(1);
  DECLARE VARIABLE saldo NUMERIC(15, 4); 
  DECLARE VARIABLE saldocurr NUMERIC(15, 4); 
  DECLARE VARIABLE saldoeq NUMERIC(15, 4); 
  DECLARE VARIABLE fieldname VARCHAR(60); 
  DECLARE VARIABLE lb INTEGER; 
  DECLARE VARIABLE rb INTEGER; 
  DECLARE VARIABLE closedate DATE; 
BEGIN 
  closedate = CAST((CAST('17.11.1858' AS DATE) + GEN_ID(gd_g_entry_balance_date, 0)) AS DATE); 
  
  SELECT 
    c.lb, c.rb 
  FROM 
    ac_account c 
  WHERE 
    c.id = :accountkey
  INTO 
    :lb, :rb; 
  
  FOR 
    SELECT 
      a.id, a.alias, a.activity, f.fieldname, a.name, a.offbalance 
    FROM 
      ac_account a 
      LEFT JOIN at_relation_fields f ON a.analyticalfield = f.id 
    WHERE 
      a.accounttype IN ('A', 'S') 
      AND a.lb >= :lb AND a.rb <= :rb AND a.alias <> '00' 
    INTO 
      :id, :alias, :activity, :fieldname, :name, :offbalance 
  DO 
  BEGIN 
    ncu_begin_debit = 0; 
    ncu_begin_credit = 0; 
    curr_begin_debit = 0; 
    curr_begin_credit = 0; 
    eq_begin_debit = 0; 
    eq_begin_credit = 0; 
  
    IF ((activity <> 'B') OR (fieldname IS NULL)) THEN 
    BEGIN 
      IF (:closedate <= :datebegin) THEN 
      BEGIN 
        SELECT 
          SUM(main.debitncu - main.creditncu), 
          SUM(main.debitcurr - main.creditcurr),
          SUM(main.debiteq - main.crediteq) 
        FROM 
        ( 
          SELECT 
            bal.debitncu, 
            bal.creditncu, 
            bal.debitcurr, 
            bal.creditcurr, 
            bal.debiteq, 
            bal.crediteq 
          FROM 
            ac_entry_balance bal 
          WHERE 
            bal.accountkey = :id 
            AND (bal.companykey + 0 = :companykey 
              OR (:allholdingcompanies = 1 
                AND bal.companykey + 0 IN ( 
                  SELECT 
                    h.companykey 
                  FROM 
                    gd_holding h 
                  WHERE 
                    h.holdingkey = :companykey))) 
            AND ((0 = :currkey) OR (bal.currkey = :currkey)) 
  
          UNION ALL 
  
          SELECT 
            e.debitncu, 
            e.creditncu,
            e.debitcurr, 
            e.creditcurr, 
            e.debiteq, 
            e.crediteq 
          FROM 
            ac_entry e 
          WHERE 
            e.accountkey = :id 
            AND e.entrydate >= :closedate 
            AND e.entrydate < :datebegin 
            AND (e.companykey + 0 = :companykey 
              OR (:allholdingcompanies = 1 
              AND e.companykey + 0 IN ( 
                SELECT 
                  h.companykey 
                FROM 
                  gd_holding h 
                WHERE 
                  h.holdingkey = :companykey))) 
            AND ((0 = :currkey) OR (e.currkey = :currkey)) 
        ) main 
        INTO 
          :saldo, :saldocurr, :saldoeq; 
      END 
      ELSE 
      BEGIN 
        SELECT 
          SUM(main.debitncu - main.creditncu), 
          SUM(main.debitcurr - main.creditcurr), 
          SUM(main.debiteq - main.crediteq)
        FROM 
        ( 
          SELECT 
            bal.debitncu, 
            bal.creditncu, 
            bal.debitcurr, 
            bal.creditcurr, 
            bal.debiteq, 
            bal.crediteq 
          FROM 
            ac_entry_balance bal 
          WHERE 
            bal.accountkey = :id 
            AND (bal.companykey + 0 = :companykey 
              OR (:allholdingcompanies = 1 
                AND bal.companykey + 0 IN ( 
                  SELECT 
                    h.companykey 
                  FROM 
                    gd_holding h 
                  WHERE 
                    h.holdingkey = :companykey))) 
            AND ((0 = :currkey) OR (bal.currkey = :currkey)) 
 
          UNION ALL 
 
          SELECT 
            - e.debitncu, 
            - e.creditncu, 
            - e.debitcurr,
            - e.creditcurr, 
            - e.debiteq, 
            - e.crediteq 
          FROM 
            ac_entry e 
          WHERE 
            e.accountkey = :id 
            AND e.entrydate >= :datebegin 
            AND e.entrydate < :closedate 
            AND (e.companykey + 0 = :companykey 
              OR (:allholdingcompanies = 1 
              AND e.companykey + 0 IN ( 
                SELECT 
                  h.companykey 
                FROM 
                  gd_holding h 
                WHERE 
                  h.holdingkey = :companykey))) 
            AND ((0 = :currkey) OR (e.currkey = :currkey)) 
        ) main 
        INTO 
          :saldo, :saldocurr, :saldoeq; 
      END 
 
      IF (saldo IS NULL) THEN 
        saldo = 0; 
      IF (saldocurr IS NULL) THEN 
        saldocurr = 0;  
      IF (saldoeq IS NULL) THEN 
        saldoeq = 0;
  
      IF (saldo > 0) THEN 
        ncu_begin_debit = saldo; 
      ELSE 
        ncu_begin_credit = 0 - saldo; 
      IF (saldocurr > 0) THEN 
        curr_begin_debit = saldocurr; 
      ELSE 
        curr_begin_credit = 0 - saldocurr; 
      IF (saldoeq > 0) THEN 
        eq_begin_debit = saldoeq; 
      ELSE 
         eq_begin_credit = 0 - saldoeq; 
    END 
    ELSE 
    BEGIN 
      SELECT 
        debitsaldo, 
        creditsaldo 
      FROM 
        ac_accountexsaldo_bal(:datebegin, :id, :fieldname, :companykey, :allholdingcompanies, :currkey) 
      INTO 
        :ncu_begin_debit, 
        :ncu_begin_credit; 
    END 
  
    IF (allholdingcompanies = 0) THEN 
    BEGIN 
      IF (dontinmove = 1) THEN 
        SELECT
          SUM(e.debitncu), 
          SUM(e.creditncu), 
          SUM(e.debitcurr), 
          SUM(e.creditcurr), 
          SUM(e.debiteq), 
          SUM(e.crediteq) 
        FROM 
          ac_entry e 
        WHERE 
          e.accountkey = :id 
          AND e.entrydate >= :datebegin 
          AND e.entrydate <= :dateend 
          AND e.companykey + 0 = :companykey 
          AND ((0 = :currkey) OR (e.currkey = :currkey)) 
          AND NOT EXISTS ( 
            SELECT 
              e_cm.id 
            FROM 
              ac_entry e_cm 
            WHERE 
              e_cm.recordkey = e.recordkey 
              AND e_cm.accountpart <> e.accountpart 
              AND e_cm.accountkey=e.accountkey 
              AND (e.debitncu=e_cm.creditncu 
                OR e.creditncu=e_cm.debitncu 
                OR e.debitcurr=e_cm.creditcurr 
                OR e.creditcurr=e_cm.debitcurr)) 
        INTO 
          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, eq_credit; 
      ELSE
        SELECT 
          SUM(e.debitncu), 
          SUM(e.creditncu), 
          SUM(e.debitcurr), 
          SUM(e.creditcurr), 
          SUM(e.debiteq), 
          SUM(e.crediteq) 
        FROM 
          ac_entry e 
        WHERE 
          e.accountkey = :id 
          AND e.entrydate >= :datebegin 
          AND e.entrydate <= :dateend 
          AND e.companykey + 0 = :companykey 
          AND ((0 = :currkey) OR (e.currkey = :currkey)) 
        INTO 
          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, eq_credit; 
    END 
    ELSE 
    BEGIN 
      IF (dontinmove = 1) THEN 
        SELECT 
          SUM(e.debitncu), 
          SUM(e.creditncu), 
          SUM(e.debitcurr), 
          SUM(e.creditcurr), 
          SUM(e.debiteq), 
          SUM(e.crediteq) 
        FROM 
          ac_entry e
        WHERE 
          e.accountkey = :id 
          AND e.entrydate >= :datebegin 
          AND e.entrydate <= :dateend 
          AND (e.companykey + 0 = :companykey 
            OR e.companykey + 0 IN ( 
              SELECT 
                h.companykey 
              FROM 
                gd_holding h 
              WHERE 
                h.holdingkey = :companykey)) 
          AND ((0 = :currkey) OR (e.currkey = :currkey)) 
          AND NOT EXISTS ( 
            SELECT 
              e_cm.id 
            FROM 
              ac_entry e_cm 
            WHERE 
              e_cm.recordkey = e.recordkey 
              AND e_cm.accountpart <> e.accountpart 
              AND e_cm.accountkey=e.accountkey 
              AND (e.debitncu=e_cm.creditncu 
                OR e.creditncu=e_cm.debitncu 
                OR e.debitcurr=e_cm.creditcurr 
                OR e.creditcurr=e_cm.debitcurr)) 
        INTO 
          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, :eq_credit; 
      ELSE 
        SELECT
          SUM(e.debitncu), 
          SUM(e.creditncu), 
          SUM(e.debitcurr), 
          SUM(e.creditcurr), 
          SUM(e.debiteq), 
          SUM(e.crediteq) 
        FROM 
          ac_entry e 
        WHERE 
          e.accountkey = :id 
          AND e.entrydate >= :datebegin 
          AND e.entrydate <= :dateend 
          AND (e.companykey + 0 = :companykey 
            OR e.companykey + 0 IN ( 
              SELECT 
                h.companykey 
              FROM 
                gd_holding h 
              WHERE 
                h.holdingkey = :companykey)) 
          AND ((0 = :currkey) OR (e.currkey = :currkey)) 
        INTO 
          :ncu_debit, :ncu_credit, :curr_debit, curr_credit, :eq_debit, :eq_credit; 
    END 
  
    IF (ncu_debit IS NULL) THEN 
      ncu_debit = 0;  
    IF (ncu_credit IS NULL) THEN 
      ncu_credit = 0; 
    IF (curr_debit IS NULL) THEN
      curr_debit = 0; 
    IF (curr_credit IS NULL) THEN 
      curr_credit = 0; 
    IF (eq_debit IS NULL) THEN 
      eq_debit = 0; 
    IF (eq_credit IS NULL) THEN 
      eq_credit = 0; 
  
    ncu_end_debit = 0; 
    ncu_end_credit = 0; 
    curr_end_debit = 0; 
    curr_end_credit = 0; 
    eq_end_debit = 0; 
    eq_end_credit = 0; 
  
    IF ((activity <> 'B') OR (fieldname IS NULL)) THEN 
    BEGIN 
      saldo = ncu_begin_debit - ncu_begin_credit + ncu_debit - ncu_credit; 
      IF (saldo > 0) THEN 
        ncu_end_debit = saldo; 
      ELSE 
        ncu_end_credit = 0 - saldo; 
  
      saldocurr = curr_begin_debit - curr_begin_credit + curr_debit - curr_credit; 
      IF (saldocurr > 0) THEN 
        curr_end_debit = saldocurr; 
      ELSE 
        curr_end_credit = 0 - saldocurr; 
  
      saldoeq = eq_begin_debit - eq_begin_credit + eq_debit - eq_credit;
      IF (saldoeq > 0) THEN 
        eq_end_debit = saldoeq; 
      ELSE 
        eq_end_credit = 0 - saldoeq; 
    END 
    ELSE 
    BEGIN 
      IF ((ncu_begin_debit <> 0) OR (ncu_begin_credit <> 0) OR 
        (ncu_debit <> 0) OR (ncu_credit <> 0) OR 
        (curr_begin_debit <> 0) OR (curr_begin_credit <> 0) OR 
        (curr_debit <> 0) OR (curr_credit <> 0) OR 
        (eq_begin_debit <> 0) OR (eq_begin_credit <> 0) OR 
        (eq_debit <> 0) OR (eq_credit <> 0)) THEN 
      BEGIN 
        SELECT 
          debitsaldo, creditsaldo, 
          currdebitsaldo, currcreditsaldo, 
          eqdebitsaldo, eqcreditsaldo 
        FROM 
          ac_accountexsaldo_bal(:dateend + 1, :id, :fieldname, :companykey, :allholdingcompanies, :currkey) 
        INTO 
          :ncu_end_debit, :ncu_end_credit, :curr_end_debit, :curr_end_credit, :eq_end_debit, :eq_end_credit; 
      END 
    END 
    IF ((ncu_begin_debit <> 0) OR (ncu_begin_credit <> 0) OR 
      (ncu_debit <> 0) OR (ncu_credit <> 0) OR 
      (curr_begin_debit <> 0) OR (curr_begin_credit <> 0) OR 
      (curr_debit <> 0) OR (curr_credit <> 0) OR 
      (eq_begin_debit <> 0) OR (eq_begin_credit <> 0) OR 
      (eq_debit <> 0) OR (eq_credit <> 0)) THEN
      SUSPEND; 
  END 
END
^

COMMIT ^


CREATE PROCEDURE AC_GETSIMPLEENTRY (
    ENTRYKEY INTEGER,
    ACORRACCOUNTKEY INTEGER)
RETURNS (
    ID INTEGER,
    DEBIT NUMERIC(15,4),
    CREDIT NUMERIC(15,4),
    DEBITCURR NUMERIC(15,4),
    CREDITCURR NUMERIC(15,4),
    DEBITEQ NUMERIC(15,4),
    CREDITEQ NUMERIC(15,4))
AS
BEGIN
  ID = :ENTRYKEY; 
  SELECT
    SUM(iif(corr_e.issimple = 0, corr_e.creditncu, e.debitncu)),
    SUM(iif(corr_e.issimple = 0, corr_e.debitncu, e.creditncu)),
    SUM(iif(corr_e.issimple = 0, corr_e.creditcurr, e.debitcurr)),
    SUM(iif(corr_e.issimple = 0, corr_e.debitcurr, e.creditcurr)),
    SUM(iif(corr_e.issimple = 0, corr_e.crediteq, e.debiteq)),
    SUM(iif(corr_e.issimple = 0, corr_e.debiteq, e.crediteq))
  FROM
    ac_entry e
    JOIN ac_entry corr_e on e.recordkey = corr_e.recordkey and
      e.accountpart <> corr_e.accountpart
  WHERE
    e.id = :entrykey AND
    corr_e.accountkey + 0 = :acorraccountkey
  INTO :DEBIT,
       :CREDIT,
       :DEBITCURR,
       :CREDITCURR,
       :DEBITEQ,
       :CREDITEQ;
  SUSPEND;
END
^

SET TERM ; ^

COMMIT;

/******************************************************************************/
/***                                 Tables                                 ***/
/******************************************************************************/

CREATE TABLE AC_AUTOTRRECORD (
    ID                DINTKEY,
    SHOWINEXPLORER    DBOOLEAN,
    IMAGEINDEX        DINTEGER,
    FOLDERKEY         DFOREIGNKEY
);

ALTER TABLE AC_AUTOTRRECORD ADD
  PRIMARY KEY (ID);
ALTER TABLE AC_AUTOTRRECORD ADD CONSTRAINT FK_AC_AUTOTRRECORD_FOLDER
  FOREIGN KEY (FOLDERKEY) REFERENCES GD_COMMAND (ID)
  ON DELETE SET NULL
  ON UPDATE SET NULL;
ALTER TABLE AC_AUTOTRRECORD ADD CONSTRAINT FK_AC_AUTOTRRECORD_ID
  FOREIGN KEY (ID) REFERENCES AC_TRRECORD (ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE AC_AUTOENTRY (
    ID             DINTKEY NOT NULL,
    ENTRYKEY       DINTKEY NOT NULL,
    TRRECORDKEY    DINTKEY NOT NULL,
    BEGINDATE      DDATE_NOTNULL NOT NULL,
    ENDDATE        DDATE_NOTNULL NOT NULL,
    CREDITACCOUNT  DINTKEY NOT NULL,
    DEBITACCOUNT   DINTKEY NOT NULL,
    EDITIONDATE    DEDITIONDATE
);

ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT PK_AC_AUTOENTRY
  PRIMARY KEY (ID);
ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_CREDIT
  FOREIGN KEY (CREDITACCOUNT) REFERENCES AC_ACCOUNT (ID);
ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_DEBIT
  FOREIGN KEY (DEBITACCOUNT) REFERENCES AC_ACCOUNT (ID);
ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_ENTRYKEY
  FOREIGN KEY (ENTRYKEY) REFERENCES AC_ENTRY (ID) ON DELETE CASCADE;
ALTER TABLE AC_AUTOENTRY ADD CONSTRAINT FK_AC_AUTOENTRY_TRRECORDKEY
  FOREIGN KEY (TRRECORDKEY) REFERENCES AC_TRRECORD (ID) ON DELETE CASCADE;

COMMIT;

/*Таблица для хранения настроек главной книги*/

CREATE TABLE AC_GENERALLEDGER (
    ID             DINTKEY NOT NULL,
    NAME           DNAME NOT NULL COLLATE PXW_CYRL,
    DEFAULTUSE     DBOOLEAN,
    INNCU          DBOOLEAN,
    INCURR         DBOOLEAN,
    NCUDECDIGITS   DINTEGER_NOTNULL,
    NCUSCALE       DINTEGER_NOTNULL,
    CURRDECDIGITS  DINTEGER_NOTNULL NOT NULL,
    CURRSCALE      DINTEGER_NOTNULL NOT NULL,
    CURRKEY        DFOREIGNKEY,
    ACCOUNTKEY     DFOREIGNKEY,
    ENHANCEDSALDO  DBOOLEAN,
    EDITIONDATE    DEDITIONDATE
);

ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT PK_AC_GENERALLEDGER
  PRIMARY KEY (ID);
ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT FK_AC_GENERALLEDGER_ACKEY
  FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID);
ALTER TABLE AC_GENERALLEDGER ADD CONSTRAINT FK_AC_GENERALLEDGER_CURRKEY
  FOREIGN KEY (CURRKEY) REFERENCES GD_CURR (ID);

CREATE UNIQUE INDEX ac_x_generalledger_name ON ac_generalledger
  (name);

COMMIT;

/*Таблица для хранения связки настройки главной книги и счетов*/
CREATE TABLE AC_G_LEDGERACCOUNT (
    LEDGERKEY   DFOREIGNKEY NOT NULL,
    ACCOUNTKEY  DFOREIGNKEY NOT NULL
);

ALTER TABLE AC_G_LEDGERACCOUNT ADD CONSTRAINT PK_AC_G_LEDGERACCOUNT PRIMARY KEY (LEDGERKEY, ACCOUNTKEY);
ALTER TABLE AC_G_LEDGERACCOUNT ADD CONSTRAINT FK_AC_G_LEDGERACCOUNT_AKEY FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID);
ALTER TABLE AC_G_LEDGERACCOUNT ADD CONSTRAINT FK_AC_G_LEDGERACCOUNT_LKEY FOREIGN KEY (LEDGERKEY) REFERENCES AC_GENERALLEDGER (ID);
/* Privileges of roles */


COMMIT;

CREATE TABLE AC_ACCT_CONFIG (
    ID              DINTKEY,
    NAME            DTEXT32 NOT NULL,
    CLASSNAME       DTEXT60 NOT NULL,
    CONFIG          DBLOB,
    SHOWINEXPLORER  DBOOLEAN,
    FOLDER          DFOREIGNKEY,
    IMAGEINDEX      DINTEGER,
    EDITIONDATE     DEDITIONDATE
);

ALTER TABLE AC_ACCT_CONFIG ADD CONSTRAINT PK_AC_ACCT_CONFIG_ID PRIMARY KEY (ID);
ALTER TABLE AC_ACCT_CONFIG ADD CONSTRAINT FK_AC_ACCT_CONFIG_FOLDER
  FOREIGN KEY (FOLDER) REFERENCES GD_COMMAND (ID)
  ON DELETE SET NULL
  ON UPDATE CASCADE;

COMMIT;

/****************************************************

  Таблица связка счета с ед.измерения

*****************************************************/

CREATE TABLE ac_accvalue
(
  id          dintkey  PRIMARY KEY,
  accountkey  dmasterkey,
  valuekey    dintkey
 );

COMMIT;

CREATE UNIQUE INDEX ac_idx_accvalue
  ON ac_accvalue (accountkey, valuekey);

COMMIT;

ALTER TABLE ac_accvalue ADD CONSTRAINT fk_ac_accvalue_account
  FOREIGN KEY (accountkey) REFERENCES ac_account(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_accvalue ADD CONSTRAINT fk_ac_accvalue_value
  FOREIGN KEY (valuekey) REFERENCES gd_value(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/****************************************************

  Таблица количестенных показателей проводки

*****************************************************/

CREATE TABLE ac_quantity
(
  id          dintkey  PRIMARY KEY,
  entrykey    dmasterkey,
  valuekey    dintkey,
  quantity    dcurrency
 );

COMMIT;

CREATE UNIQUE INDEX ac_idx_quantity
  ON ac_quantity (entrykey, valuekey);

COMMIT;

ALTER TABLE ac_quantity ADD CONSTRAINT fk_ac_quantity_entry
  FOREIGN KEY (entrykey) REFERENCES ac_entry(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE ac_quantity ADD CONSTRAINT fk_ac_quantity_accvalue
  FOREIGN KEY (valuekey) REFERENCES gd_value(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

CREATE TABLE AC_LEDGER_ACCOUNTS (
    ACCOUNTKEY  DFOREIGNKEY NOT NULL,
    SQLHANDLE   DINTEGER_NOTNULL NOT NULL
);

COMMIT;

ALTER TABLE AC_LEDGER_ACCOUNTS ADD CONSTRAINT PK_AC_LEDGER_ACCOUNTS
  PRIMARY KEY (ACCOUNTKEY, SQLHANDLE);

ALTER TABLE AC_LEDGER_ACCOUNTS ADD CONSTRAINT FK_AC_LEDGER_ACCOUNTS
  FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

CREATE TABLE AC_LEDGER_ENTRIES (
    ENTRYKEY   DINTKEY NOT NULL,
    SQLHANDLE  DINTKEY NOT NULL
);

COMMIT;

ALTER TABLE AC_LEDGER_ENTRIES ADD CONSTRAINT PK_AC_LEDGER_ENTRIES
  PRIMARY KEY (SQLHANDLE, ENTRYKEY);

ALTER TABLE AC_LEDGER_ENTRIES ADD CONSTRAINT FK_AC_LEDGER_ENTRIES
  FOREIGN KEY (ENTRYKEY) REFERENCES AC_ENTRY (ID)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^;

CREATE PROCEDURE AC_L_S (
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    currkey integer)
returns (
    entrydate date,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin numeric(15,4),
    crediteqbegin numeric(15,4),
    debiteqend numeric(15,4),
    crediteqend numeric(15,4),
    forceshow integer)
as
declare variable o dcurrency;
declare variable saldobegin dcurrency;
declare variable saldoend dcurrency;
declare variable ocurr dcurrency;
declare variable oeq dcurrency;
declare variable saldobegincurr dcurrency;
declare variable saldoendcurr dcurrency;
declare variable saldobegineq dcurrency;
declare variable saldoendeq dcurrency;
declare variable c integer;
BEGIN 
  IF (:SQLHANDLE = 0) THEN 
  BEGIN 
    SELECT
      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0), 
      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0), 
      IIF(NOT SUM(e1.debiteq - e1.crediteq) IS NULL, SUM(e1.debiteq - e1.crediteq), 0) 
    FROM 
      ac_entry e1 
    WHERE 
      (e1.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e1.companykey  + 0 IN ( 
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      ((0 = :currkey) OR (e1.currkey = :currkey)) AND 
      e1.entrydate < :abeginentrydate 
    INTO :saldobegin, 
         :saldobegincurr, 
         :saldobegineq; 
 
    IF (saldobegin IS NULL) THEN 
      saldobegin = 0; 
    IF (saldobegincurr IS NULL) THEN 
      saldobegincurr = 0; 
    IF (saldobegineq IS NULL) THEN 
      saldobegineq = 0; 
 
    C = 0; 
    FORCESHOW = 0;
    FOR 
      SELECT 
        e.entrydate, 
        SUM(e.debitncu - e.creditncu), 
        SUM(e.debitcurr - e.creditcurr), 
        SUM(e.debiteq - e.crediteq) 
      FROM 
        ac_entry e 
      WHERE 
        (e.companykey + 0 = :companykey OR 
        (:ALLHOLDINGCOMPANIES = 1 AND 
        e.companykey + 0 IN ( 
          SELECT 
            h.companykey 
          FROM 
            gd_holding h 
          WHERE 
            h.holdingkey = :companykey))) AND 
        ((0 = :currkey) OR (e.currkey = :currkey)) AND 
         e.entrydate <= :aendentrydate AND 
        e.entrydate >= :abeginentrydate 
 
      GROUP BY e.entrydate 
      INTO :ENTRYDATE, 
           :O, 
           :OCURR, 
           :OEQ 
    DO 
    BEGIN 
      DEBITNCUBEGIN = 0;
      CREDITNCUBEGIN = 0; 
      DEBITNCUEND = 0; 
      CREDITNCUEND = 0; 
      DEBITCURRBEGIN = 0; 
      CREDITCURRBEGIN = 0; 
      DEBITCURREND = 0; 
      CREDITCURREND = 0; 
      DEBITEQBEGIN = 0; 
      CREDITEQBEGIN = 0; 
      DEBITEQEND = 0; 
      CREDITEQEND = 0; 
      SALDOEND = :SALDOBEGIN + :O; 
      if (SALDOBEGIN > 0) then 
        DEBITNCUBEGIN = :SALDOBEGIN; 
      else 
        CREDITNCUBEGIN =  - :SALDOBEGIN; 
      if (SALDOEND > 0) then 
        DEBITNCUEND = :SALDOEND; 
      else 
        CREDITNCUEND =  - :SALDOEND; 
      SALDOENDCURR = :SALDOBEGINCURR + :OCURR; 
      if (SALDOBEGINCURR > 0) then 
        DEBITCURRBEGIN = :SALDOBEGINCURR; 
      else 
        CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
      if (SALDOENDCURR > 0) then 
        DEBITCURREND = :SALDOENDCURR; 
      else 
        CREDITCURREND =  - :SALDOENDCURR; 
      SALDOENDEQ = :SALDOBEGINEQ + :OEQ;
      if (SALDOBEGINEQ > 0) then 
        DEBITEQBEGIN = :SALDOBEGINEQ; 
      else 
        CREDITEQBEGIN =  - :SALDOBEGINEQ; 
      if (SALDOENDEQ > 0) then 
        DEBITEQEND = :SALDOENDEQ; 
      else 
        CREDITEQEND =  - :SALDOENDEQ; 
      SUSPEND; 
      SALDOBEGIN = :SALDOEND; 
      SALDOBEGINCURR = :SALDOENDCURR; 
      C = C + 1; 
    END 
    /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
    IF (C = 0) THEN 
    BEGIN 
      ENTRYDATE = :abeginentrydate; 
      IF (SALDOBEGIN > 0) THEN 
      BEGIN 
        DEBITNCUBEGIN = :SALDOBEGIN; 
        DEBITNCUEND = :SALDOBEGIN; 
      END ELSE 
      BEGIN 
        CREDITNCUBEGIN =  - :SALDOBEGIN; 
        CREDITNCUEND =  - :SALDOBEGIN; 
      END 
   
      IF (SALDOBEGINCURR > 0) THEN 
      BEGIN 
        DEBITCURRBEGIN = :SALDOBEGINCURR;
        DEBITCURREND = :SALDOBEGINCURR; 
      END ELSE 
      BEGIN 
        CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
        CREDITCURREND =  - :SALDOBEGINCURR; 
      END 
 
      IF (SALDOBEGINEQ > 0) THEN 
      BEGIN 
        DEBITEQBEGIN = :SALDOBEGINEQ; 
        DEBITEQEND = :SALDOBEGINEQ; 
      END ELSE 
      BEGIN 
        CREDITEQBEGIN =  - :SALDOBEGINEQ; 
        CREDITEQEND =  - :SALDOBEGINEQ; 
      END 
   
      FORCESHOW = 1; 
      SUSPEND; 
    END 
  END 
  ELSE 
  BEGIN 
    SELECT 
      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0), 
      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0), 
      IIF(NOT SUM(e1.debiteq - e1.crediteq) IS NULL, SUM(e1.debiteq - e1.crediteq), 0) 
    FROM 
      ac_ledger_accounts a JOIN 
      ac_entry e1 ON a.accountkey = e1.accountkey AND e1.entrydate < :abeginentrydate
      AND a.sqlhandle = :sqlhandle  
    WHERE 
      (e1.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e1.companykey  + 0 IN ( 
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      ((0 = :currkey) OR (e1.currkey = :currkey)) 
    INTO :saldobegin, 
         :saldobegincurr, 
         :saldobegineq; 
 
    IF (saldobegin IS NULL) THEN 
      saldobegin = 0; 
    IF (saldobegincurr IS NULL) THEN 
      saldobegincurr = 0; 
    IF (saldobegineq IS NULL) THEN 
      saldobegineq = 0; 
 
    C = 0; 
    FORCESHOW = 0; 
    FOR 
      SELECT 
        e.entrydate, 
        SUM(e.debitncu - e.creditncu), 
        SUM(e.debitcurr - e.creditcurr),
        SUM(e.debiteq - e.crediteq) 
      FROM 
        ac_ledger_accounts a 
        JOIN ac_entry e ON a.accountkey = e.accountkey AND 
            e.entrydate <= :aendentrydate AND 
            e.entrydate >= :abeginentrydate 
            AND a.sqlhandle = :sqlhandle  
      WHERE 
        (e.companykey + 0 = :companykey OR 
        (:ALLHOLDINGCOMPANIES = 1 AND 
        e.companykey + 0 IN ( 
          SELECT 
            h.companykey 
          FROM 
            gd_holding h 
          WHERE 
            h.holdingkey = :companykey))) AND 
        ((0 = :currkey) OR (e.currkey = :currkey)) 
      GROUP BY e.entrydate 
      INTO :ENTRYDATE, 
           :O, 
           :OCURR, 
           :OEQ 
    DO 
    BEGIN 
      DEBITNCUBEGIN = 0; 
      CREDITNCUBEGIN = 0; 
      DEBITNCUEND = 0; 
      CREDITNCUEND = 0; 
      DEBITCURRBEGIN = 0;
      CREDITCURRBEGIN = 0; 
      DEBITCURREND = 0; 
      CREDITCURREND = 0; 
      DEBITEQBEGIN = 0; 
      CREDITEQBEGIN = 0; 
      DEBITEQEND = 0; 
      CREDITEQEND = 0; 
      SALDOEND = :SALDOBEGIN + :O; 
      if (SALDOBEGIN > 0) then 
        DEBITNCUBEGIN = :SALDOBEGIN; 
      else 
        CREDITNCUBEGIN =  - :SALDOBEGIN; 
      if (SALDOEND > 0) then 
        DEBITNCUEND = :SALDOEND; 
      else 
        CREDITNCUEND =  - :SALDOEND; 
      SALDOENDCURR = :SALDOBEGINCURR + :OCURR; 
      if (SALDOBEGINCURR > 0) then 
        DEBITCURRBEGIN = :SALDOBEGINCURR; 
      else 
        CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
      if (SALDOENDCURR > 0) then 
        DEBITCURREND = :SALDOENDCURR; 
      else 
        CREDITCURREND =  - :SALDOENDCURR; 
      SALDOENDEQ = :SALDOBEGINEQ + :OEQ; 
      if (SALDOBEGINEQ > 0) then 
        DEBITEQBEGIN = :SALDOBEGINEQ; 
      else 
        CREDITEQBEGIN =  - :SALDOBEGINEQ;
      if (SALDOENDEQ > 0) then 
        DEBITEQEND = :SALDOENDEQ; 
      else 
        CREDITEQEND =  - :SALDOENDEQ; 
      SUSPEND; 
      SALDOBEGIN = :SALDOEND; 
      SALDOBEGINCURR = :SALDOENDCURR; 
      SALDOBEGINEQ = :SALDOENDEQ; 
      C = C + 1; 
    END 
    /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
    IF (C = 0) THEN 
    BEGIN 
      ENTRYDATE = :abeginentrydate; 
      IF (SALDOBEGIN > 0) THEN 
      BEGIN 
        DEBITNCUBEGIN = :SALDOBEGIN; 
        DEBITNCUEND = :SALDOBEGIN; 
      END ELSE 
      BEGIN 
        CREDITNCUBEGIN =  - :SALDOBEGIN; 
        CREDITNCUEND =  - :SALDOBEGIN; 
      END 
 
      IF (SALDOBEGINCURR > 0) THEN 
      BEGIN 
        DEBITCURRBEGIN = :SALDOBEGINCURR; 
        DEBITCURREND = :SALDOBEGINCURR; 
      END ELSE 
      BEGIN
        CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
        CREDITCURREND =  - :SALDOBEGINCURR; 
      END 
 
      IF (SALDOBEGINEQ > 0) THEN 
      BEGIN 
        DEBITEQBEGIN = :SALDOBEGINEQ; 
        DEBITEQEND = :SALDOBEGINEQ; 
      END ELSE 
      BEGIN 
        CREDITEQBEGIN =  - :SALDOBEGINEQ; 
        CREDITEQEND =  - :SALDOBEGINEQ; 
      END 
 
      FORCESHOW = 1; 
      SUSPEND; 
    END 
  END 
END^

COMMIT ^

CREATE PROCEDURE AC_L_S1 (
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    param integer,
    currkey integer)
returns (
    dateparam integer,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin numeric(15,4),
    crediteqbegin numeric(15,4),
    debiteqend numeric(15,4),
    crediteqend numeric(15,4),
    forceshow integer)
as
declare variable o dcurrency;
declare variable saldobegin dcurrency;
declare variable saldoend dcurrency;
declare variable ocurr dcurrency;
declare variable saldobegincurr dcurrency;
declare variable saldoendcurr dcurrency;
declare variable oeq dcurrency;
declare variable saldobegineq dcurrency;
declare variable saldoendeq dcurrency;
declare variable c integer;
BEGIN 
  IF (:SQLHANDLE = 0) THEN 
  BEGIN
    SELECT 
      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0), 
      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0), 
      IIF(NOT SUM(e1.debiteq - e1.crediteq) IS NULL, SUM(e1.debiteq - e1.crediteq), 0) 
    FROM 
      ac_entry e1 
    WHERE 
      (e1.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e1.companykey + 0 IN ( 
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      ((0 = :currkey) OR (e1.currkey = :currkey)) AND 
      e1.entrydate < :abeginentrydate 
    INTO :saldobegin, 
         :saldobegincurr, 
         :saldobegineq; 
    if (saldobegin IS NULL) then 
      saldobegin = 0; 
    if (saldobegincurr IS NULL) then 
      saldobegincurr = 0; 
    if (saldobegineq IS NULL) then 
      saldobegineq = 0; 
 
    C = 0; 
    FORCESHOW = 0;
    FOR 
      SELECT 
        SUM(e.debitncu - e.creditncu), 
        SUM(e.debitcurr - e.creditcurr), 
        SUM(e.debiteq - e.crediteq), 
        g_d_getdateparam(e.entrydate, :param) 
      FROM 
        ac_entry e 
      WHERE 
        (e.companykey + 0 = :companykey OR 
        (:ALLHOLDINGCOMPANIES = 1 AND 
        e.companykey + 0 IN ( 
          SELECT 
            h.companykey 
          FROM 
            gd_holding h 
          WHERE 
            h.holdingkey = :companykey))) AND 
        ((0 = :currkey) OR (e.currkey = :currkey)) AND 
          e.entrydate <= :aendentrydate AND 
          e.entrydate >= :abeginentrydate 
      group by 4 
      INTO :O, 
           :OCURR, 
           :OEQ, 
           :dateparam 
    DO 
    BEGIN 
      DEBITNCUBEGIN = 0; 
      CREDITNCUBEGIN = 0;
      DEBITNCUEND = 0; 
      CREDITNCUEND = 0; 
      DEBITCURRBEGIN = 0; 
      CREDITCURRBEGIN = 0; 
      DEBITCURREND = 0; 
      CREDITCURREND = 0; 
      DEBITEQBEGIN = 0; 
      CREDITEQBEGIN = 0; 
      DEBITEQEND = 0; 
      CREDITEQEND = 0; 
      SALDOEND = :SALDOBEGIN + :O; 
      if (SALDOBEGIN > 0) then 
        DEBITNCUBEGIN = :SALDOBEGIN; 
      else 
        CREDITNCUBEGIN =  - :SALDOBEGIN; 
      if (SALDOEND > 0) then 
        DEBITNCUEND = :SALDOEND; 
      else 
        CREDITNCUEND =  - :SALDOEND; 
      SALDOENDCURR = :SALDOBEGINCURR + :OCURR; 
      if (SALDOBEGINCURR > 0) then 
        DEBITCURRBEGIN = :SALDOBEGINCURR; 
      else 
        CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
      if (SALDOENDCURR > 0) then 
        DEBITCURREND = :SALDOENDCURR; 
      else 
        CREDITCURREND =  - :SALDOENDCURR; 
      SALDOENDEQ = :SALDOBEGINEQ + :OEQ; 
      if (SALDOBEGINEQ > 0) then
        DEBITEQBEGIN = :SALDOBEGINEQ; 
      else 
        CREDITEQBEGIN =  - :SALDOBEGINEQ; 
      if (SALDOENDEQ > 0) then 
        DEBITEQEND = :SALDOENDEQ; 
      else 
        CREDITEQEND =  - :SALDOENDEQ; 
      SUSPEND; 
      SALDOBEGIN = :SALDOEND; 
      SALDOBEGINCURR = :SALDOENDCURR; 
      SALDOBEGINEQ = :SALDOENDEQ; 
      C = C + 1; 
    END 
    /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
    IF (C = 0) THEN 
    BEGIN 
      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param); 
      IF (SALDOBEGIN > 0) THEN 
      BEGIN 
        DEBITNCUBEGIN = :SALDOBEGIN; 
        DEBITNCUEND = :SALDOBEGIN; 
      END ELSE 
      BEGIN 
        CREDITNCUBEGIN =  - :SALDOBEGIN; 
        CREDITNCUEND =  - :SALDOBEGIN; 
      END 
     
      IF (SALDOBEGINCURR > 0) THEN 
      BEGIN 
        DEBITCURRBEGIN = :SALDOBEGINCURR;
        DEBITCURREND = :SALDOBEGINCURR; 
      END ELSE 
      BEGIN 
        CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
        CREDITCURREND =  - :SALDOBEGINCURR; 
      END 
 
      IF (SALDOBEGINEQ > 0) THEN 
      BEGIN 
        DEBITEQBEGIN = :SALDOBEGINEQ; 
        DEBITEQEND = :SALDOBEGINEQ; 
      END ELSE 
      BEGIN 
        CREDITEQBEGIN =  - :SALDOBEGINEQ; 
        CREDITEQEND =  - :SALDOBEGINEQ; 
      END 
 
      FORCESHOW = 1; 
      SUSPEND; 
    END 
  END 
  ELSE 
  BEGIN 
    SELECT 
      IIF(NOT SUM(e1.debitncu - e1.creditncu) IS NULL, SUM(e1.debitncu - e1.creditncu),  0), 
      IIF(NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL, SUM(e1.debitcurr - e1.creditcurr), 0), 
      IIF(NOT SUM(e1.debiteq - e1.crediteq) IS NULL, SUM(e1.debiteq - e1.crediteq), 0) 
    FROM 
      ac_ledger_accounts a 
      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND e1.entrydate < :abeginentrydate
      AND a.sqlhandle = :sqlhandle  
    WHERE 
      (e1.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e1.companykey + 0 IN ( 
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      ((0 = :currkey) OR (e1.currkey = :currkey)) 
    INTO :saldobegin, 
         :saldobegincurr, 
         :saldobegineq; 
    if (saldobegin IS NULL) then 
      saldobegin = 0; 
    if (saldobegincurr IS NULL) then 
      saldobegincurr = 0; 
    if (saldobegineq IS NULL) then 
      saldobegineq = 0; 
 
    C = 0; 
    FORCESHOW = 0; 
    FOR 
      SELECT 
        SUM(e.debitncu - e.creditncu), 
        SUM(e.debitcurr - e.creditcurr), 
        SUM(e.debiteq - e.crediteq), 
        g_d_getdateparam(e.entrydate, :param)
      FROM 
        ac_ledger_accounts a 
        JOIN ac_entry e ON a.accountkey = e.accountkey AND 
             e.entrydate <= :aendentrydate AND 
             e.entrydate >= :abeginentrydate 
      AND a.sqlhandle = :sqlhandle  
      WHERE 
        (e.companykey + 0 = :companykey OR 
        (:ALLHOLDINGCOMPANIES = 1 AND 
        e.companykey + 0 IN ( 
          SELECT 
            h.companykey 
          FROM 
            gd_holding h 
          WHERE 
            h.holdingkey = :companykey))) AND 
        ((0 = :currkey) OR (e.currkey = :currkey)) 
      group by 4 
      INTO :O, 
           :OCURR, 
           :OEQ, 
           :dateparam 
    DO 
    BEGIN 
      DEBITNCUBEGIN = 0; 
      CREDITNCUBEGIN = 0; 
      DEBITNCUEND = 0; 
      CREDITNCUEND = 0; 
      DEBITCURRBEGIN = 0; 
      CREDITCURRBEGIN = 0;
      DEBITCURREND = 0; 
      CREDITCURREND = 0; 
      DEBITEQBEGIN = 0; 
      CREDITEQBEGIN = 0; 
      DEBITEQEND = 0; 
      CREDITEQEND = 0; 
      SALDOEND = :SALDOBEGIN + :O; 
      if (SALDOBEGIN > 0) then 
        DEBITNCUBEGIN = :SALDOBEGIN; 
      else 
        CREDITNCUBEGIN =  - :SALDOBEGIN; 
      if (SALDOEND > 0) then 
        DEBITNCUEND = :SALDOEND; 
      else 
        CREDITNCUEND =  - :SALDOEND; 
      SALDOENDCURR = :SALDOBEGINCURR + :OCURR; 
      if (SALDOBEGINCURR > 0) then 
        DEBITCURRBEGIN = :SALDOBEGINCURR; 
      else 
        CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
      if (SALDOENDCURR > 0) then 
        DEBITCURREND = :SALDOENDCURR; 
      else 
        CREDITCURREND =  - :SALDOENDCURR; 
      SALDOENDEQ = :SALDOBEGINEQ + :OEQ; 
      if (SALDOBEGINEQ > 0) then 
        DEBITEQBEGIN = :SALDOBEGINEQ; 
      else 
        CREDITEQBEGIN =  - :SALDOBEGINEQ; 
      if (SALDOENDEQ > 0) then
        DEBITEQEND = :SALDOENDEQ; 
      else 
        CREDITEQEND =  - :SALDOENDEQ; 
      SUSPEND; 
      SALDOBEGIN = :SALDOEND; 
      SALDOBEGINCURR = :SALDOENDCURR; 
      SALDOBEGINEQ = :SALDOENDEQ; 
      C = C + 1; 
    END 
    /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
    IF (C = 0) THEN 
    BEGIN 
      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param); 
      IF (SALDOBEGIN > 0) THEN 
      BEGIN 
        DEBITNCUBEGIN = :SALDOBEGIN; 
        DEBITNCUEND = :SALDOBEGIN; 
      END ELSE 
      BEGIN 
        CREDITNCUBEGIN =  - :SALDOBEGIN; 
        CREDITNCUEND =  - :SALDOBEGIN; 
      END 
 
      IF (SALDOBEGINCURR > 0) THEN 
      BEGIN 
        DEBITCURRBEGIN = :SALDOBEGINCURR; 
        DEBITCURREND = :SALDOBEGINCURR; 
      END ELSE 
      BEGIN 
        CREDITCURRBEGIN =  - :SALDOBEGINCURR;
        CREDITCURREND =  - :SALDOBEGINCURR; 
      END 
 
      IF (SALDOBEGINEQ > 0) THEN 
      BEGIN 
        DEBITEQBEGIN = :SALDOBEGINEQ; 
        DEBITEQEND = :SALDOBEGINEQ; 
      END ELSE 
      BEGIN 
        CREDITEQBEGIN =  - :SALDOBEGINEQ; 
        CREDITEQEND =  - :SALDOBEGINEQ; 
      END 
 
      FORCESHOW = 1; 
 
      SUSPEND; 
    END 
   
  END 
END^

COMMIT^

CREATE PROCEDURE AC_Q_S (
    valuekey integer,
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    currkey integer)
returns (
    entrydate date,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldobegin numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
BEGIN 
  IF (:sqlhandle = 0) THEN 
  BEGIN 
    SELECT 
      IIF(SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) - 
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) > 0, 
        SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) - 
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)), 0) 
    FROM 
      ac_entry e1 
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id 
    WHERE 
      (e1.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e1.companykey + 0 IN (
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      q.valuekey = :valuekey AND 
      ((0 = :currkey) OR (e1.currkey = :currkey)) AND 
      e1.entrydate < :abeginentrydate  
    INTO :saldobegin; 
    if (saldobegin IS NULL) then 
      saldobegin = 0; 
 
    C = 0; 
    FOR 
      SELECT 
        e.entrydate, 
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) - 
          SUM(IIF(e.accountpart = 'C', q.quantity, 0)) 
      FROM 
        ac_entry e 
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND 
          q.valuekey = :valuekey 
      WHERE 
        (e.companykey + 0 = :companykey OR 
        (:ALLHOLDINGCOMPANIES = 1 AND 
        e.companykey + 0 IN ( 
          SELECT 
            h.companykey 
          FROM
            gd_holding h 
          WHERE 
            h.holdingkey = :companykey))) AND 
        ((0 = :currkey) OR (e.currkey = :currkey)) AND 
          e.entrydate <= :aendentrydate AND 
          e.entrydate >= :abeginentrydate 
      GROUP BY e.entrydate 
      INTO :ENTRYDATE, 
           :O 
    DO 
    BEGIN 
      IF (O IS NULL) THEN O = 0; 
      DEBITBEGIN = 0; 
      CREDITBEGIN = 0; 
      DEBITEND = 0; 
      CREDITEND = 0; 
      DEBIT = 0; 
      CREDIT = 0; 
      IF (O > 0) THEN 
        DEBIT = :O; 
      ELSE 
        CREDIT = - :O; 
   
      SALDOEND = :SALDOBEGIN + :O; 
      if (SALDOBEGIN > 0) then 
        DEBITBEGIN = :SALDOBEGIN; 
      else 
        CREDITBEGIN =  - :SALDOBEGIN; 
      if (SALDOEND > 0) then 
        DEBITEND = :SALDOEND;
      else 
        CREDITEND =  - :SALDOEND; 
      SUSPEND; 
      SALDOBEGIN = :SALDOEND; 
      C = C + 1; 
    END 

    /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
    IF (C = 0) THEN 
    BEGIN 
      ENTRYDATE = :abeginentrydate; 
      IF (SALDOBEGIN > 0) THEN 
      BEGIN 
        DEBITBEGIN = :SALDOBEGIN; 
        DEBITEND = :SALDOBEGIN; 
      END ELSE 
      BEGIN 
        CREDITBEGIN =  - :SALDOBEGIN; 
        CREDITEND =  - :SALDOBEGIN; 
      END 
      SUSPEND; 
    END 
 
  END 
  ELSE 
  BEGIN 
 
    SELECT 
      IIF(SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) - 
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) > 0,
        SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) - 
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)), 0) 
    FROM 
      ac_ledger_accounts a 
      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND 
        e1.entrydate < :abeginentrydate 
      AND a.sqlhandle = :sqlhandle  
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id 
    WHERE 
      (e1.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e1.companykey + 0 IN ( 
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      q.valuekey = :valuekey AND 
      ((0 = :currkey) OR (e1.currkey = :currkey)) 
    INTO :saldobegin; 
    if (saldobegin IS NULL) then 
      saldobegin = 0; 
   
    C = 0; 
    FOR 
      SELECT 
        e.entrydate, 
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) - 
          SUM(IIF(e.accountpart = 'C', q.quantity, 0))
      FROM 
        ac_ledger_accounts a 
        JOIN ac_entry e ON a.accountkey = e.accountkey AND 
          e.entrydate <= :aendentrydate AND 
          e.entrydate >= :abeginentrydate 
          AND a.sqlhandle = :sqlhandle  
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND 
          q.valuekey = :valuekey 
      WHERE 
        (e.companykey + 0 = :companykey OR 
        (:ALLHOLDINGCOMPANIES = 1 AND 
        e.companykey + 0 IN ( 
          SELECT 
            h.companykey 
          FROM 
            gd_holding h 
          WHERE 
            h.holdingkey = :companykey))) AND 
        ((0 = :currkey) OR (e.currkey = :currkey)) 
      GROUP BY e.entrydate 
      INTO :ENTRYDATE, 
           :O 
    DO 
    BEGIN 
      IF (O IS NULL) THEN O = 0; 
      DEBITBEGIN = 0; 
      CREDITBEGIN = 0; 
      DEBITEND = 0; 
      CREDITEND = 0; 
      DEBIT = 0;
      CREDIT = 0; 
      IF (O > 0) THEN 
        DEBIT = :O; 
      ELSE 
        CREDIT = - :O; 
   
      SALDOEND = :SALDOBEGIN + :O; 
      if (SALDOBEGIN > 0) then 
        DEBITBEGIN = :SALDOBEGIN; 
      else 
        CREDITBEGIN =  - :SALDOBEGIN; 
      if (SALDOEND > 0) then 
        DEBITEND = :SALDOEND; 
      else 
        CREDITEND =  - :SALDOEND; 
      SUSPEND; 
      SALDOBEGIN = :SALDOEND; 
      C = C + 1; 
    END 
    /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
    IF (C = 0) THEN 
    BEGIN 
      ENTRYDATE = :abeginentrydate; 
      IF (SALDOBEGIN > 0) THEN 
      BEGIN 
        DEBITBEGIN = :SALDOBEGIN; 
        DEBITEND = :SALDOBEGIN; 
      END ELSE 
      BEGIN 
        CREDITBEGIN =  - :SALDOBEGIN;
        CREDITEND =  - :SALDOBEGIN; 
      END 
      SUSPEND; 
    END 
 
  END 
END^


COMMIT ^

CREATE PROCEDURE AC_L_Q (
    ENTRYKEY INTEGER,
    VALUEKEY INTEGER,
    ACCOUNTKEY INTEGER,
    AACCOUNTPART CHAR(1))
RETURNS (
    DEBITQUANTITY NUMERIC(15,4),
    CREDITQUANTITY NUMERIC(15,4))
AS
DECLARE VARIABLE ACCOUNTPART CHAR(1);
DECLARE VARIABLE QUANTITY NUMERIC(15,4);
begin
  SELECT
    e.accountpart,
    q.quantity
  FROM
    ac_entry e
    LEFT JOIN ac_entry e1 ON e1.recordkey = e.recordkey AND
      e1.accountpart <> e.accountpart
    LEFT JOIN ac_quantity q ON q.entrykey = iif(e.issimple = 1 and e1.issimple = 1,
      e.id, iif(e.issimple = 0, e.id, e1.id))
  WHERE
    e.id = :entrykey AND
    q.valuekey = :valuekey AND
    e1.accountkey = :accountkey
  INTO
    :accountpart,
    :quantity;
  IF (quantity IS NULL) THEN
    quantity = 0;

  debitquantity = 0;
  creditquantity = 0;
  IF (accountpart = 'D') THEN
    debitquantity = :quantity;
  ELSE
    creditquantity = :quantity;

  suspend;
END^


CREATE PROCEDURE AC_Q_S1 (
    valuekey integer,
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    param integer,
    currkey integer)
returns (
    dateparam integer,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldobegin numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
BEGIN 
  IF (:sqlhandle = 0) THEN 
  BEGIN 
    SALDOBEGIN = 0; 
    SELECT 
      SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) - 
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) 
    FROM 
      ac_entry e1 
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id 
    WHERE 
      e1.entrydate < :abeginentrydate AND 
      (e1.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND
      e1.companykey + 0 IN ( 
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      q.valuekey = :valuekey AND 
      ((0 = :currkey) OR (e1.currkey = :currkey)) 
    INTO :saldobegin; 
 
    if (SALDOBEGIN IS NULL) THEN 
      SALDOBEGIN = 0; 
   
    C = 0; 
    FOR 
      SELECT 
        g_d_getdateparam(e.entrydate, :param), 
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) - 
          SUM(IIF(e.accountpart = 'C', q.quantity, 0)) 
      FROM 
        ac_entry e 
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey 
      WHERE 
        e.entrydate <= :aendentrydate AND 
        e.entrydate >= :abeginentrydate AND 
        (e.companykey + 0 = :companykey OR 
        (:ALLHOLDINGCOMPANIES = 1 AND 
        e.companykey + 0 IN ( 
          SELECT
            h.companykey 
          FROM 
            gd_holding h 
          WHERE 
            h.holdingkey = :companykey))) AND 
        ((0 = :currkey) OR (e.currkey = :currkey)) 
      GROUP BY 1 
      INTO :dateparam, 
           :O 
    DO 
    BEGIN 
      IF (O IS NULL) THEN O = 0; 
      DEBITBEGIN = 0; 
      CREDITBEGIN = 0; 
      DEBITEND = 0; 
      CREDITEND = 0; 
      DEBIT = 0; 
      CREDIT = 0; 
      IF (O > 0) THEN 
        DEBIT = :O; 
      ELSE 
        CREDIT = - :O; 
 
      SALDOEND = :SALDOBEGIN + :O; 
      if (SALDOBEGIN > 0) then 
        DEBITBEGIN = :SALDOBEGIN; 
      else 
        CREDITBEGIN =  - :SALDOBEGIN; 
      if (SALDOEND > 0) then 
        DEBITEND = :SALDOEND;
      else 
        CREDITEND =  - :SALDOEND; 
      SUSPEND; 
      SALDOBEGIN = :SALDOEND; 
      C = C + 1; 
    END 
    /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
    IF (C = 0) THEN 
    BEGIN 
      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param); 
      IF (SALDOBEGIN > 0) THEN 
      BEGIN 
        DEBITBEGIN = :SALDOBEGIN; 
        DEBITEND = :SALDOBEGIN; 
      END ELSE 
      BEGIN 
        CREDITBEGIN =  - :SALDOBEGIN; 
        CREDITEND =  - :SALDOBEGIN; 
      END 
      SUSPEND; 
    END 
  END 
  ELSE 
  BEGIN 
 
    SALDOBEGIN = 0; 
    SELECT 
      SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) - 
        SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) 
    FROM
      ac_ledger_accounts a 
      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND 
        e1.entrydate < :abeginentrydate 
        AND a.sqlhandle = :sqlhandle  
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id 
    WHERE 
      (e1.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e1.companykey + 0 IN ( 
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      q.valuekey = :valuekey AND 
      ((0 = :currkey) OR (e1.currkey = :currkey)) 
    INTO :saldobegin; 
   
    if (SALDOBEGIN IS NULL) THEN 
      SALDOBEGIN = 0; 
   
    C = 0; 
    FOR 
      SELECT 
        g_d_getdateparam(e.entrydate, :param), 
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) - 
          SUM(IIF(e.accountpart = 'C', q.quantity, 0)) 
      FROM 
        ac_ledger_accounts a
        JOIN ac_entry e ON a.accountkey = e.accountkey AND 
          e.entrydate <= :aendentrydate AND 
          e.entrydate >= :abeginentrydate 
          AND a.sqlhandle = :sqlhandle  
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey 
      WHERE 
        (e.companykey + 0 = :companykey OR 
        (:ALLHOLDINGCOMPANIES = 1 AND 
        e.companykey + 0 IN ( 
          SELECT 
            h.companykey 
          FROM 
            gd_holding h 
          WHERE 
            h.holdingkey = :companykey))) AND 
        ((0 = :currkey) OR (e.currkey = :currkey)) 
      GROUP BY 1 
      INTO :dateparam, 
           :O 
    DO 
    BEGIN 
      IF (O IS NULL) THEN O = 0; 
      DEBITBEGIN = 0; 
      CREDITBEGIN = 0; 
      DEBITEND = 0; 
      CREDITEND = 0; 
      DEBIT = 0; 
      CREDIT = 0; 
      IF (O > 0) THEN 
        DEBIT = :O;
      ELSE 
        CREDIT = - :O; 
   
      SALDOEND = :SALDOBEGIN + :O; 
      if (SALDOBEGIN > 0) then 
        DEBITBEGIN = :SALDOBEGIN; 
      else 
        CREDITBEGIN =  - :SALDOBEGIN; 
      if (SALDOEND > 0) then 
        DEBITEND = :SALDOEND; 
      else 
        CREDITEND =  - :SALDOEND; 
      SUSPEND; 
      SALDOBEGIN = :SALDOEND; 
      C = C + 1; 
    END 
    /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
    IF (C = 0) THEN 
    BEGIN 
      DATEPARAM = g_d_getdateparam(:abeginentrydate, :param); 
      IF (SALDOBEGIN > 0) THEN 
      BEGIN 
        DEBITBEGIN = :SALDOBEGIN; 
        DEBITEND = :SALDOBEGIN; 
      END ELSE 
      BEGIN 
        CREDITBEGIN =  - :SALDOBEGIN; 
        CREDITEND =  - :SALDOBEGIN; 
      END 
      SUSPEND;
    END 
 
  END 
END^

CREATE PROCEDURE AC_Q_G_L (
    valuekey integer,
    datebegin date,
    dateend date,
    companykey integer,
    allholdingcompanies integer,
    sqlhandle integer,
    ingroup integer,
    currkey integer)
returns (
    m integer,
    y integer,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldobegin numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
begin 
  SELECT
    IIF(SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) - 
      SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) > 0, 
      SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) - 
      SUM(IIF(e1.accountpart = 'C', q.quantity, 0)), 0) 
  FROM 
      ac_entry e1 
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id 
  WHERE 
    e1.entrydate < :datebegin AND 
    e1.accountkey IN ( 
      SELECT 
        a.accountkey 
      FROM 
        ac_ledger_accounts a 
      WHERE 
        a.sqlhandle = :sqlhandle) AND 
    (e1.companykey = :companykey OR 
    (:ALLHOLDINGCOMPANIES = 1 AND 
    e1.companykey IN ( 
      SELECT 
        h.companykey 
      FROM 
        gd_holding h 
      WHERE 
        h.holdingkey = :companykey))) AND 
    q.valuekey = :valuekey AND 
    ((0 = :currkey) OR (e1.currkey = :currkey)) 
  INTO :saldobegin; 
  if (saldobegin IS NULL) then 
    saldobegin = 0;
 
  C = 0; 
  FOR 
    SELECT 
      EXTRACT(MONTH FROM e.entrydate), 
      EXTRACT(YEAR FROM e.entrydate), 
      SUM(IIF(e.accountpart = 'D', q.quantity, 0)) - 
        SUM(IIF(e.accountpart = 'C', q.quantity, 0)) 
    FROM 
      ac_entry e 
      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND 
        q.valuekey = :valuekey 
    WHERE 
      e.entrydate <= :dateend AND 
      e.entrydate >= :datebegin AND 
      e.accountkey IN ( 
        SELECT 
          a.accountkey 
        FROM 
          ac_ledger_accounts a 
        WHERE 
          a.sqlhandle = :sqlhandle 
      ) AND 
      (e.companykey = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e.companykey IN ( 
        SELECT 
          h.companykey 
        FROM 
          gd_holding h
        WHERE 
          h.holdingkey = :companykey))) AND 
      ((0 = :currkey) OR (e.currkey = :currkey)) 
    GROUP BY 1, 2 
    ORDER BY 2, 1 
    INTO :M, :Y, :O 
  DO 
  BEGIN 
    IF (O IS NULL) THEN O = 0; 
    DEBITBEGIN = 0; 
    CREDITBEGIN = 0; 
    DEBITEND = 0; 
    CREDITEND = 0; 
    DEBIT = 0; 
    CREDIT = 0; 
    IF (O > 0) THEN 
      DEBIT = :O; 
    ELSE 
      CREDIT = - :O; 
 
    SALDOEND = :SALDOBEGIN + :O; 
    if (SALDOBEGIN > 0) then 
      DEBITBEGIN = :SALDOBEGIN; 
    else 
      CREDITBEGIN =  - :SALDOBEGIN; 
    if (SALDOEND > 0) then 
      DEBITEND = :SALDOEND; 
    else 
      CREDITEND =  - :SALDOEND; 
    SALDOBEGIN = :SALDOEND;
    C = C + 1; 
    SUSPEND; 
  END 
  /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
  IF (C = 0) THEN 
  BEGIN 
    M = EXTRACT(MONTH FROM :datebegin); 
    Y = EXTRACT(YEAR FROM :datebegin); 
    IF (SALDOBEGIN > 0) THEN 
    BEGIN 
      DEBITBEGIN = :SALDOBEGIN; 
      DEBITEND = :SALDOBEGIN; 
    END ELSE 
    BEGIN 
      CREDITBEGIN =  - :SALDOBEGIN; 
      CREDITEND =  - :SALDOBEGIN; 
    END 
    DEBIT = 0; 
    CREDIT = 0; 
    SUSPEND; 
  END 
END^

CREATE PROCEDURE AC_G_L_S (
    abeginentrydate date,
    aendentrydate date,
    sqlhandle integer,
    companykey integer,
    allholdingcompanies integer,
    ingroup integer,
    currkey integer,
    analyticfield varchar(60))
returns (
    m integer,
    y integer,
    begindate date,
    enddate date,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin dcurrency,
    crediteqbegin dcurrency,
    debiteqend dcurrency,
    crediteqend dcurrency,
    forceshow integer)
as
declare variable o dcurrency;
declare variable ocurr dcurrency;
declare variable oeq dcurrency;
declare variable saldobegindebit dcurrency;
declare variable saldobegincredit dcurrency;
declare variable saldoenddebit dcurrency;
declare variable saldoendcredit dcurrency;
declare variable saldobegindebitcurr dcurrency;
declare variable saldobegincreditcurr dcurrency;
declare variable saldoenddebitcurr dcurrency;
declare variable saldoendcreditcurr dcurrency;
declare variable saldobegindebiteq dcurrency;
declare variable saldobegincrediteq dcurrency;
declare variable saldoenddebiteq dcurrency;
declare variable saldoendcrediteq dcurrency;
declare variable sd dcurrency;
declare variable sc dcurrency;
declare variable sdc dcurrency;
declare variable scc dcurrency;
declare variable sdeq dcurrency;
declare variable sceq dcurrency;
declare variable c integer;
declare variable accountkey integer;
declare variable d date;
declare variable dayinmonth integer;
BEGIN 
  saldobegindebit = 0; 
  saldobegincredit = 0; 
  saldobegindebitcurr = 0; 
  saldobegincreditcurr = 0; 
 
  IF (ANALYTICFIELD = '') THEN 
  BEGIN 
    SELECT 
      IIF((NOT SUM(e1.debitncu - e1.creditncu) IS NULL) AND 
        (SUM(e1.debitncu - e1.creditncu) > 0), SUM(e1.debitncu - e1.creditncu),  0), 
      IIF((NOT SUM(e1.creditncu - e1.debitncu) IS NULL) AND 
        (SUM(e1.creditncu - e1.debitncu) > 0), SUM(e1.creditncu - e1.debitncu),  0), 
      IIF((NOT SUM(e1.debitcurr - e1.creditcurr) IS NULL) AND
        (SUM(e1.debitcurr - e1.creditcurr) > 0), SUM(e1.debitcurr - e1.creditcurr),  0), 
      IIF((NOT SUM(e1.creditcurr - e1.debitcurr) IS NULL) AND 
        (SUM(e1.creditcurr - e1.debitcurr) > 0), SUM(e1.creditcurr - e1.debitcurr),  0), 
      IIF((NOT SUM(e1.debiteq - e1.crediteq) IS NULL) AND 
        (SUM(e1.debiteq - e1.crediteq) > 0), SUM(e1.debiteq - e1.crediteq),  0), 
      IIF((NOT SUM(e1.crediteq - e1.debiteq) IS NULL) AND 
        (SUM(e1.crediteq - e1.debiteq) > 0), SUM(e1.crediteq - e1.debiteq),  0) 
    FROM 
      ac_ledger_accounts a 
      JOIN ac_entry e1 ON a.accountkey = e1.accountkey AND e1.entrydate < :abeginentrydate 
        AND a.sqlhandle = :sqlhandle 
    WHERE 
      (e1.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e1.companykey + 0 IN ( 
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      ((0 = :currkey) OR (e1.currkey = :currkey)) 
    INTO :saldobegindebit, 
         :saldobegincredit, 
         :saldobegindebitcurr, 
         :saldobegincreditcurr, 
         :saldobegindebiteq, 
         :saldobegincrediteq; 
  END ELSE 
  BEGIN
    FOR 
      SELECT 
        la.accountkey 
      FROM 
        ac_ledger_accounts la 
      WHERE 
        la.sqlhandle = :sqlhandle 
      INTO :accountkey 
    DO 
    BEGIN 
      SELECT 
        a.DEBITSALDO, 
        a.CREDITSALDO, 
        a.CURRDEBITSALDO, 
        a.CURRCREDITSALDO, 
        a.EQDEBITSALDO, 
        a.EQCREDITSALDO 
      FROM 
        ac_accountexsaldo(:abeginentrydate, :accountkey, :analyticfield, :companykey, 
          :allholdingcompanies, -1, :currkey) a 
      INTO :sd, 
           :sc, 
           :sdc, 
           :scc, 
           :sdeq, 
           :sceq; 
 
      IF (sd IS NULL) then SD = 0; 
      IF (sc IS NULL) then SC = 0; 
      IF (sdc IS NULL) then SDC = 0;
      IF (scc IS NULL) then SCC = 0; 
 
      saldobegindebit = :saldobegindebit + :sd; 
      saldobegincredit = :saldobegincredit + :sc; 
      saldobegindebitcurr = :saldobegindebitcurr + :sdc; 
      saldobegincreditcurr = :saldobegincreditcurr + :scc; 
      saldobegindebiteq = :saldobegindebiteq + :sdeq; 
      saldobegincrediteq = :saldobegincrediteq + :sceq; 
    END 
  END 
 
  C = 0; 
  FORCESHOW = 0; 
  FOR 
    SELECT 
      SUM(e.debitncu - e.creditncu), 
      SUM(e.debitcurr - e.creditcurr), 
      SUM(e.debiteq - e.crediteq), 
      EXTRACT(MONTH FROM e.entrydate), 
      EXTRACT(YEAR FROM e.entrydate) 
    FROM 
      ac_ledger_accounts a 
      JOIN ac_entry e ON a.accountkey = e.accountkey AND 
           e.entrydate <= :aendentrydate AND 
           e.entrydate >= :abeginentrydate 
    AND a.sqlhandle = :sqlhandle  
    WHERE 
      (e.companykey + 0 = :companykey OR 
      (:ALLHOLDINGCOMPANIES = 1 AND 
      e.companykey + 0 IN (
        SELECT 
          h.companykey 
        FROM 
          gd_holding h 
        WHERE 
          h.holdingkey = :companykey))) AND 
      ((0 = :currkey) OR (e.currkey = :currkey)) 
    group by 4, 5 
    ORDER BY 5, 4 
    INTO :O, :OCURR, :OEQ, :M, :Y 
  DO 
  BEGIN 
    begindate = CAST(:Y || '-' || :M || '-' || 1 as DATE); 
    IF (begindate < :abeginentrydate) THEN 
    BEGIN 
      begindate = :abeginentrydate; 
    END 
 
    DAYINMONTH = EXTRACT(DAY FROM g_d_incmonth(1, CAST(:Y || '-' || :M || '-' || 1 as DATE)) - 1); 
 
    D = CAST(:Y || '-' || :M || '-' || :dayinmonth as DATE); 
 
    IF (D > :aendentrydate) THEN 
    BEGIN 
      D = :aendentrydate; 
    END 
    ENDDATE = D; 
    DEBITNCUBEGIN = 0; 
    CREDITNCUBEGIN = 0; 
    DEBITNCUEND = 0;
    CREDITNCUEND = 0; 
    DEBITCURRBEGIN = 0; 
    CREDITCURRBEGIN = 0; 
    DEBITCURREND = 0; 
    CREDITCURREND = 0; 
    DEBITEQBEGIN = 0; 
    CREDITEQBEGIN = 0; 
    DEBITEQEND = 0; 
    CREDITEQEND = 0; 
    IF (analyticfield = '') THEN 
    BEGIN 
      IF (:saldobegindebit - :saldobegincredit + :o > 0) THEN 
      BEGIN 
        SALDOENDDEBIT = :saldobegindebit - :saldobegincredit + :o; 
        SALDOENDCREDIT = 0; 
      END ELSE 
      BEGIN 
        SALDOENDDEBIT = 0; 
        SALDOENDCREDIT =  - (:saldobegindebit - :saldobegincredit + :o); 
      END 
 
      IF (:saldobegindebitcurr - :saldobegincreditcurr + :ocurr > 0) THEN 
      BEGIN 
        SALDOENDDEBITCURR = :saldobegindebitCURR - :saldobegincreditCURR + :ocurr; 
        SALDOENDCREDITCURR = 0; 
      END ELSE 
      BEGIN 
        SALDOENDDEBITCURR = 0; 
        SALDOENDCREDITCURR =  - (:saldobegindebitcurr - :saldobegincreditcurr + :ocurr); 
      END
 
      IF (:saldobegindebiteq - :saldobegincrediteq + :oeq > 0) THEN 
      BEGIN 
        SALDOENDDEBITEQ = :saldobegindebiteq - :saldobegincrediteq + :oeq; 
        SALDOENDCREDITEQ = 0; 
      END ELSE 
      BEGIN 
        SALDOENDDEBITEQ = 0; 
        SALDOENDCREDITEQ =  - (:saldobegindebiteq - :saldobegincrediteq + :oeq); 
      END 
    END ELSE 
    BEGIN 
      saldoenddebit = 0; 
      saldoendcredit = 0; 
      saldoenddebitcurr = 0; 
      saldoendcreditcurr = 0; 
      saldoenddebiteq = 0; 
      saldoendcrediteq = 0; 
 
      FOR 
        SELECT 
          la.accountkey 
        FROM 
          ac_ledger_accounts la 
        WHERE 
          la.sqlhandle = :sqlhandle 
        INTO :accountkey 
      DO 
      BEGIN 

        SELECT 
          a.DEBITSALDO, 
          a.CREDITSALDO, 
          a.CURRDEBITSALDO, 
          a.CURRCREDITSALDO, 
          a.EQDEBITSALDO, 
          a.EQCREDITSALDO 
        FROM 
          ac_accountexsaldo(:d + 1, :accountkey, :analyticfield, :companykey, 
            :allholdingcompanies, -1, :currkey) a 
        INTO :sd, 
             :sc, 
             :sdc, 
             :scc, 
             :sdeq, 
             :sceq; 
 
        IF (sd IS NULL) then SD = 0; 
        IF (sc IS NULL) then SC = 0; 
        IF (sdc IS NULL) then SDC = 0; 
        IF (scc IS NULL) then SCC = 0; 
        IF (sdeq IS NULL) then SDEQ = 0; 
        IF (sceq IS NULL) then SCEQ = 0; 
 
        saldoenddebit = :saldoenddebit + :sd; 
        saldoendcredit = :saldoendcredit + :sc; 
        saldoenddebitcurr = :saldoenddebitcurr + :sdc; 
        saldoendcreditcurr = :saldoendcreditcurr + :scc; 
        saldoenddebiteq = :saldoenddebiteq + :sdeq; 
        saldoendcrediteq = :saldoendcrediteq + :sceq;
      END 
    END 
 
    DEBITNCUBEGIN = :SALDOBEGINDEBIT; 
    CREDITNCUBEGIN =  :SALDOBEGINCREDIT; 
    DEBITNCUEND = :SALDOENDDEBIT; 
    CREDITNCUEND =  :SALDOENDCREDIT; 
 
    DEBITCURRBEGIN = :SALDOBEGINDEBITCURR; 
    CREDITCURRBEGIN =  :SALDOBEGINCREDITCURR; 
    DEBITCURREND = :SALDOENDDEBITCURR; 
    CREDITCURREND =  :SALDOENDCREDITCURR; 
 
    DEBITEQBEGIN = :SALDOBEGINDEBITEQ; 
    CREDITEQBEGIN =  :SALDOBEGINCREDITEQ; 
    DEBITEQEND = :SALDOENDDEBITEQ; 
    CREDITEQEND =  :SALDOENDCREDITEQ; 
 
    SUSPEND; 
 
    SALDOBEGINDEBIT = :SALDOENDDEBIT; 
    SALDOBEGINCREDIT = :SALDOENDCREDIT; 
 
    SALDOBEGINDEBITCURR = :SALDOENDDEBITCURR; 
    SALDOBEGINCREDITCURR = :SALDOENDCREDITCURR; 
 
    SALDOBEGINDEBITEQ = :SALDOENDDEBITEQ; 
    SALDOBEGINCREDITEQ = :SALDOENDCREDITEQ; 
 
    C = C + 1;
  END 
  /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
  IF (C = 0) THEN 
  BEGIN 
    M = EXTRACT(MONTH FROM :abeginentrydate); 
    Y = EXTRACT(YEAR FROM :abeginentrydate); 
    DEBITNCUBEGIN = :SALDOBEGINDEBIT; 
    CREDITNCUBEGIN =  :SALDOBEGINCREDIT; 
    DEBITNCUEND = :SALDOBEGINDEBIT; 
    CREDITNCUEND =  :SALDOBEGINCREDIT; 
 
    DEBITCURRBEGIN = :SALDOBEGINDEBITCURR; 
    CREDITCURRBEGIN =  :SALDOBEGINCREDITCURR; 
    DEBITCURREND = :SALDOBEGINDEBITCURR; 
    CREDITCURREND =  :SALDOBEGINCREDITCURR; 
 
    DEBITEQBEGIN = :SALDOBEGINDEBITEQ; 
    CREDITEQBEGIN =  :SALDOBEGINCREDITEQ; 
    DEBITEQEND = :SALDOBEGINDEBITEQ; 
    CREDITEQEND =  :SALDOBEGINCREDITEQ; 
 
    BEGINDATE = :abeginentrydate; 
    ENDDATE = :abeginentrydate; 
 
    FORCESHOW = 1; 
 
    SUSPEND; 
  END 
END^

CREATE PROCEDURE AC_E_L_S (
    abeginentrydate date,
    saldobegin dcurrency,
    saldobegincurr dcurrency,
    saldobegineq dcurrency,
    sqlhandle integer,
    currkey integer)
returns (
    entrydate date,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin numeric(15,4),
    crediteqbegin numeric(15,4),
    debiteqend numeric(15,4),
    crediteqend numeric(15,4),
    forceshow integer)
as
declare variable o dcurrency;
declare variable saldoend dcurrency;
declare variable ocurr dcurrency;
declare variable oeq dcurrency;
declare variable saldoendcurr dcurrency;
declare variable saldoendeq dcurrency;
declare variable c integer;
BEGIN 
  IF (saldobegin IS NULL) THEN 
    saldobegin = 0; 
  IF (saldobegincurr IS NULL) THEN 
    saldobegincurr = 0; 
  IF (saldobegineq IS NULL) THEN 
    saldobegineq = 0; 
  C = 0; 
  FORCESHOW = 0; 
  FOR 
    SELECT 
      e.entrydate, 
      SUM(e.debitncu - e.creditncu), 
      SUM(e.debitcurr - e.creditcurr), 
      SUM(e.debiteq - e.crediteq) 
    FROM 
      ac_ledger_entries le 
      LEFT JOIN ac_entry e ON le.entrykey = e.id 
    WHERE 
      le.sqlhandle = :sqlhandle AND 
      ((0 = :currkey) OR (e.currkey = :currkey)) 
    group by e.entrydate 
    INTO :ENTRYDATE, 
         :O, 
         :OCURR, 
         :OEQ 
  DO 
  BEGIN 
    DEBITNCUBEGIN = 0; 
    CREDITNCUBEGIN = 0;
    DEBITNCUEND = 0; 
    CREDITNCUEND = 0; 
    DEBITCURRBEGIN = 0; 
    CREDITCURRBEGIN = 0; 
    DEBITCURREND = 0; 
    CREDITCURREND = 0; 
    DEBITEQBEGIN = 0; 
    CREDITEQBEGIN = 0; 
    DEBITEQEND = 0; 
    CREDITEQEND = 0; 
    SALDOEND = :SALDOBEGIN + :O; 
    if (SALDOBEGIN > 0) then 
      DEBITNCUBEGIN = :SALDOBEGIN; 
    else 
      CREDITNCUBEGIN =  - :SALDOBEGIN; 
    if (SALDOEND > 0) then 
      DEBITNCUEND = :SALDOEND; 
    else 
      CREDITNCUEND =  - :SALDOEND; 
    SALDOENDCURR = :SALDOBEGINCURR + :OCURR; 
    if (SALDOBEGINCURR > 0) then 
      DEBITCURRBEGIN = :SALDOBEGINCURR; 
    else 
      CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
    if (SALDOENDCURR > 0) then 
      DEBITCURREND = :SALDOENDCURR; 
    else 
      CREDITCURREND =  - :SALDOENDCURR; 
    SALDOENDEQ = :SALDOBEGINEQ + :OEQ; 
    if (SALDOBEGINEQ > 0) then
      DEBITEQBEGIN = :SALDOBEGINEQ; 
    else 
      CREDITEQBEGIN =  - :SALDOBEGINEQ; 
    if (SALDOENDEQ > 0) then 
      DEBITEQEND = :SALDOENDEQ; 
    else 
      CREDITEQEND =  - :SALDOENDEQ; 
    SUSPEND; 
    SALDOBEGIN = :SALDOEND; 
    SALDOBEGINCURR = :SALDOENDCURR; 
    SALDOBEGINEQ = :SALDOENDEQ; 
    C = C + 1; 
  END 
  /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
  IF (C = 0) THEN 
  BEGIN 
    ENTRYDATE = :abeginentrydate; 
    IF (SALDOBEGIN > 0) THEN 
    BEGIN 
      DEBITNCUBEGIN = :SALDOBEGIN; 
      DEBITNCUEND = :SALDOBEGIN; 
    END ELSE 
    BEGIN 
      CREDITNCUBEGIN =  - :SALDOBEGIN; 
      CREDITNCUEND =  - :SALDOBEGIN; 
    END 
 
    IF (SALDOBEGINCURR > 0) THEN 
    BEGIN 
      DEBITCURRBEGIN = :SALDOBEGINCURR;
      DEBITCURREND = :SALDOBEGINCURR; 
    END ELSE 
    BEGIN 
      CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
      CREDITCURREND =  - :SALDOBEGINCURR; 
    END 
 
    IF (SALDOBEGINEQ > 0) THEN 
    BEGIN 
      DEBITEQBEGIN = :SALDOBEGINEQ; 
      DEBITEQEND = :SALDOBEGINEQ; 
    END ELSE 
    BEGIN 
      CREDITEQBEGIN =  - :SALDOBEGINEQ; 
      CREDITEQEND =  - :SALDOBEGINEQ; 
    END 
 
    FORCESHOW = 1; 
    SUSPEND; 
  END
END^

CREATE PROCEDURE AC_E_L_S1 (
    abeginentrydate date,
    saldobegin dcurrency,
    saldobegincurr dcurrency,
    saldobegineq integer,
    sqlhandle integer,
    param integer,
    currkey integer)
returns (
    dateparam integer,
    debitncubegin numeric(15,4),
    creditncubegin numeric(15,4),
    debitncuend numeric(15,4),
    creditncuend numeric(15,4),
    debitcurrbegin numeric(15,4),
    creditcurrbegin numeric(15,4),
    debitcurrend numeric(15,4),
    creditcurrend numeric(15,4),
    debiteqbegin numeric(15,4),
    crediteqbegin numeric(15,4),
    debiteqend numeric(15,4),
    crediteqend numeric(15,4),
    forceshow integer)
as
declare variable o dcurrency;
declare variable saldoend dcurrency;
declare variable ocurr dcurrency;
declare variable saldoendcurr dcurrency;
declare variable oeq dcurrency;
declare variable saldoendeq dcurrency;
declare variable c integer;
BEGIN 
  IF (saldobegin IS NULL) THEN 
    saldobegin = 0; 
  IF (saldobegincurr IS NULL) THEN 
    saldobegincurr = 0; 
  IF (saldobegineq IS NULL) THEN 
    saldobegineq = 0;
  C = 0; 
  FORCESHOW = 0; 
  FOR 
    SELECT 
      SUM(e.debitncu - e.creditncu), 
      SUM(e.debitcurr - e.creditcurr), 
      SUM(e.debiteq - e.crediteq), 
      g_d_getdateparam(e.entrydate, :param) 
    FROM 
      ac_ledger_entries le 
      LEFT JOIN ac_entry e ON le.entrykey = e.id 
    WHERE 
      le.sqlhandle = :sqlhandle AND 
      ((0 = :currkey) OR (e.currkey = :currkey)) 
    group by 4 
    INTO :O, 
         :OCURR, 
         :OEQ, 
         :dateparam 
  DO 
  BEGIN 
    DEBITNCUBEGIN = 0; 
    CREDITNCUBEGIN = 0; 
    DEBITNCUEND = 0; 
    CREDITNCUEND = 0; 
    DEBITCURRBEGIN = 0; 
    CREDITCURRBEGIN = 0; 
    DEBITCURREND = 0; 
    CREDITCURREND = 0; 
    DEBITEQBEGIN = 0;
    CREDITEQBEGIN = 0; 
    DEBITEQEND = 0; 
    CREDITEQEND = 0; 
    SALDOEND = :SALDOBEGIN + :O; 
    if (SALDOBEGIN > 0) then 
      DEBITNCUBEGIN = :SALDOBEGIN; 
    else 
      CREDITNCUBEGIN =  - :SALDOBEGIN; 
    if (SALDOEND > 0) then 
      DEBITNCUEND = :SALDOEND; 
    else 
      CREDITNCUEND =  - :SALDOEND; 
    SALDOENDCURR = :SALDOBEGINCURR + :OCURR; 
    if (SALDOBEGINCURR > 0) then 
      DEBITCURRBEGIN = :SALDOBEGINCURR; 
    else 
      CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
    if (SALDOENDCURR > 0) then 
      DEBITCURREND = :SALDOENDCURR; 
    else 
      CREDITCURREND =  - :SALDOENDCURR; 
    SALDOENDEQ = :SALDOBEGINEQ + :OEQ; 
    if (SALDOBEGINEQ > 0) then 
      DEBITEQBEGIN = :SALDOBEGINEQ; 
    else 
      CREDITEQBEGIN =  - :SALDOBEGINEQ; 
    if (SALDOENDEQ > 0) then 
      DEBITEQEND = :SALDOENDEQ; 
    else 
      CREDITEQEND =  - :SALDOENDEQ;
    SUSPEND; 
    SALDOBEGIN = :SALDOEND; 
    SALDOBEGINCURR = :SALDOENDCURR; 
    SALDOBEGINEQ = :SALDOENDEQ; 
    C = C + 1; 
  END 
  /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
  IF (C = 0) THEN 
  BEGIN 
    DATEPARAM = g_d_getdateparam(:abeginentrydate, :param); 
    IF (SALDOBEGIN > 0) THEN 
    BEGIN 
      DEBITNCUBEGIN = :SALDOBEGIN; 
      DEBITNCUEND = :SALDOBEGIN; 
    END ELSE 
    BEGIN 
      CREDITNCUBEGIN =  - :SALDOBEGIN; 
      CREDITNCUEND =  - :SALDOBEGIN; 
    END 
 
    IF (SALDOBEGINCURR > 0) THEN 
    BEGIN 
      DEBITCURRBEGIN = :SALDOBEGINCURR; 
      DEBITCURREND = :SALDOBEGINCURR; 
    END ELSE 
    BEGIN 
      CREDITCURRBEGIN =  - :SALDOBEGINCURR; 
      CREDITCURREND =  - :SALDOBEGINCURR; 
    END 

    IF (SALDOBEGINEQ > 0) THEN 
    BEGIN 
      DEBITEQBEGIN = :SALDOBEGINEQ; 
      DEBITEQEND = :SALDOBEGINEQ; 
    END ELSE 
    BEGIN 
      CREDITEQBEGIN =  - :SALDOBEGINEQ; 
      CREDITEQEND =  - :SALDOBEGINEQ; 
    END 
 
    FORCESHOW = 1; 
    SUSPEND; 
  END 
END^

CREATE PROCEDURE AC_E_Q_S (
    valuekey integer,
    abeginentrydate date,
    saldobegin numeric(15,4),
    sqlhandle integer,
    currkey integer)
returns (
    entrydate date,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
BEGIN 
  C = 0; 
  if (saldobegin IS NULL) then 
    saldobegin = 0; 
 
  FOR 
    SELECT 
      e.entrydate, 
      SUM(IIF(e.accountpart = 'D', q.quantity, 0)) - 
        SUM(IIF(e.accountpart = 'C', q.quantity, 0)) 
    FROM 
      ac_ledger_entries le 
      LEFT JOIN ac_entry e ON le.entrykey = e.id 
      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey 
    WHERE 
      le.sqlhandle = :SQLHANDLE AND 
      ((0 = :currkey) OR (e.currkey = :currkey)) 
    GROUP BY e.entrydate 
    INTO :ENTRYDATE, 
         :O 
  DO 
  BEGIN 
    IF (O IS NULL) THEN O = 0; 
    DEBITBEGIN = 0; 
    CREDITBEGIN = 0; 
    DEBITEND = 0; 
    CREDITEND = 0;
    DEBIT = 0; 
    CREDIT = 0; 
    IF (O > 0) THEN 
      DEBIT = :O; 
    ELSE 
      CREDIT = - :O; 
 
    SALDOEND = :SALDOBEGIN + :O; 
    if (SALDOBEGIN > 0) then 
      DEBITBEGIN = :SALDOBEGIN; 
    else 
      CREDITBEGIN =  - :SALDOBEGIN; 
    if (SALDOEND > 0) then 
      DEBITEND = :SALDOEND; 
    else 
      CREDITEND =  - :SALDOEND; 
    SUSPEND; 
    SALDOBEGIN = :SALDOEND; 
    C = C + 1; 
  END 
  /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
  IF (C = 0) THEN 
  BEGIN 
    ENTRYDATE = :abeginentrydate; 
    IF (SALDOBEGIN > 0) THEN 
    BEGIN 
      DEBITBEGIN = :SALDOBEGIN; 
      DEBITEND = :SALDOBEGIN; 
    END ELSE 
    BEGIN
      CREDITBEGIN =  - :SALDOBEGIN; 
      CREDITEND =  - :SALDOBEGIN; 
    END 
    SUSPEND; 
  END 
END^

CREATE PROCEDURE AC_E_Q_S1 (
    valuekey integer,
    abeginentrydate date,
    saldobegin numeric(15,4),
    sqlhandle integer,
    param integer,
    currkey integer)
returns (
    dateparam integer,
    debitbegin numeric(15,4),
    creditbegin numeric(15,4),
    debit numeric(15,4),
    credit numeric(15,4),
    debitend numeric(15,4),
    creditend numeric(15,4))
as
declare variable o numeric(15,4);
declare variable saldoend numeric(15,4);
declare variable c integer;
BEGIN 
  C = 0; 
  if (SALDOBEGIN IS NULL) THEN 
    SALDOBEGIN = 0;
 
  FOR 
    SELECT 
      g_d_getdateparam(e.entrydate, :param), 
      SUM(IIF(e.accountpart = 'D', q.quantity, 0)) - 
        SUM(IIF(e.accountpart = 'C', q.quantity, 0)) 
    FROM 
      ac_ledger_entries le 
      LEFT JOIN ac_entry e ON le.entrykey = e.id 
      LEFT JOIN ac_quantity q ON q.entrykey = e.id AND q.valuekey = :valuekey 
    WHERE 
      le.sqlhandle = :SQLHANDLE AND 
      ((0 = :currkey) OR (e.currkey = :currkey)) 
    GROUP BY 1 
    INTO :dateparam, 
         :O 
  DO 
  BEGIN 
    IF (O IS NULL) THEN O = 0; 
    DEBITBEGIN = 0; 
    CREDITBEGIN = 0; 
    DEBITEND = 0; 
    CREDITEND = 0; 
    DEBIT = 0; 
    CREDIT = 0; 
    IF (O > 0) THEN 
      DEBIT = :O; 
    ELSE 
      CREDIT = - :O; 

    SALDOEND = :SALDOBEGIN + :O; 
    if (SALDOBEGIN > 0) then 
      DEBITBEGIN = :SALDOBEGIN; 
    else 
      CREDITBEGIN =  - :SALDOBEGIN; 
    if (SALDOEND > 0) then 
      DEBITEND = :SALDOEND; 
    else 
      CREDITEND =  - :SALDOEND; 
    SUSPEND; 
    SALDOBEGIN = :SALDOEND; 
    C = C + 1; 
  END 
  /*Если за указанный период нет движения то выводим сальдо на начало периода*/ 
  IF (C = 0) THEN 
  BEGIN 
    DATEPARAM = g_d_getdateparam(:abeginentrydate, :param); 
    IF (SALDOBEGIN > 0) THEN 
    BEGIN 
      DEBITBEGIN = :SALDOBEGIN; 
      DEBITEND = :SALDOBEGIN; 
    END ELSE 
    BEGIN 
      CREDITBEGIN =  - :SALDOBEGIN; 
      CREDITEND =  - :SALDOBEGIN; 
    END 
    SUSPEND; 
  END 
END^

SET TERM ; ^
COMMIT;

CREATE EXCEPTION AC_E_AUTOTRCANTCONTAINTR 'Can`t move transaction into autotransaction';
CREATE EXCEPTION AC_E_TRCANTCONTAINAUTOTR 'Can`t move autotransaction into transaction';

SET TERM ^;

CREATE OR ALTER TRIGGER AC_TRANSACTION_BU0 FOR AC_TRANSACTION
  ACTIVE
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE a SMALLINT = NULL;
begin
  IF ((NOT NEW.parent IS NULL)
    AND (NEW.autotransaction IS DISTINCT FROM OLD.autotransaction)) THEN
  BEGIN
    SELECT autotransaction
    FROM ac_transaction
    WHERE id = new.parent
    INTO :a;

    a = COALESCE(:a, 0);
    NEW.autotransaction = COALESCE(NEW.autotransaction, 0);

    IF (NEW.autotransaction <> a) THEN
    BEGIN
      IF (a = 1) THEN
        EXCEPTION ac_e_autotrcantcontaintr;
      ELSE
        EXCEPTION ac_e_trcantcontainautotr;
    END
  END
END^

CREATE OR ALTER TRIGGER AC_TRANSACTION_BI0 FOR AC_TRANSACTION
  ACTIVE
  BEFORE INSERT
  POSITION 0
AS
  DECLARE a SMALLINT;
begin
  if (not new.parent is null) then
  begin
    select autotransaction
    from ac_transaction
    where id = new.parent
    into :a;
    new.autotransaction = COALESCE(:a, 0);
  end
end^

commit ^
CREATE PROCEDURE AC_Q_CIRCULATION (
    VALUEKEY INTEGER,
    DATEBEGIN DATE,
    DATEEND DATE,
    COMPANYKEY INTEGER,
    ALLHOLDINGCOMPANIES INTEGER,
    ACCOUNTKEY INTEGER,
    INGROUP INTEGER,
    CURRKEY INTEGER)
RETURNS (
    ID INTEGER,
    DEBITBEGIN NUMERIC(15,4),
    CREDITBEGIN NUMERIC(15,4),
    DEBIT NUMERIC(15,4),
    CREDIT NUMERIC(15,4),
    DEBITEND NUMERIC(15,4),
    CREDITEND NUMERIC(15,4))
AS
DECLARE VARIABLE O NUMERIC(15,4);
DECLARE VARIABLE SALDOBEGIN NUMERIC(15,4);
DECLARE VARIABLE SALDOEND NUMERIC(15,4);
DECLARE VARIABLE C INTEGER;
DECLARE VARIABLE LB INTEGER;
DECLARE VARIABLE RB INTEGER;
begin
  id = :accountkey;
  SELECT
    IIF(SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
      SUM(IIF(e1.accountpart = 'C', q.quantity, 0)) > 0,
      SUM(IIF(e1.accountpart = 'D', q.quantity, 0)) -
      SUM(IIF(e1.accountpart = 'C', q.quantity, 0)), 0)
  FROM
      ac_entry e1
      LEFT JOIN ac_record r1 ON r1.id = e1.recordkey
      LEFT JOIN ac_quantity q ON q.entrykey = e1.id
    WHERE
      e1.entrydate < :datebegin AND
      e1.accountkey = :id AND
      (r1.companykey = :companykey OR
      (:ALLHOLDINGCOMPANIES = 1 AND
      r1.companykey IN (
        SELECT
          h.companykey
        FROM
          gd_holding h
        WHERE
          h.holdingkey = :companykey))) AND
      G_SEC_TEST(r1.aview, :ingroup) <> 0 AND
      q.valuekey = :valuekey AND
      ((0 = :currkey) OR (e1.currkey = :currkey))
    INTO :saldobegin;
    if (saldobegin IS NULL) then
      saldobegin = 0;

    C = 0;
    FOR
      SELECT
        SUM(IIF(e.accountpart = 'D', q.quantity, 0)) -
          SUM(IIF(e.accountpart = 'C', q.quantity, 0))
      FROM
        ac_entry e
        LEFT JOIN ac_record r ON r.id = e.recordkey
        LEFT JOIN ac_quantity q ON q.entrykey = e.id AND
          q.valuekey = :valuekey
      WHERE
        e.entrydate <= :dateend AND
        e.entrydate >= :datebegin AND
        e.accountkey = :id AND
        (r.companykey = :companykey OR
        (:ALLHOLDINGCOMPANIES = 1 AND
        r.companykey IN (
          SELECT
            h.companykey
          FROM
            gd_holding h
          WHERE
            h.holdingkey = :companykey))) AND
        G_SEC_TEST(r.aview, :ingroup) <> 0 AND
        ((0 = :currkey) OR (e.currkey = :currkey))
      INTO :O
    DO
    BEGIN
      IF (O IS NULL) THEN O = 0;
      DEBITBEGIN = 0;
      CREDITBEGIN = 0;
      DEBITEND = 0;
       CREDITEND = 0;
      DEBIT = 0;
      CREDIT = 0;
      IF (O > 0) THEN
        DEBIT = :O;
      ELSE
        CREDIT = - :O;

      SALDOEND = :SALDOBEGIN + :O;
      if (SALDOBEGIN > 0) then
        DEBITBEGIN = :SALDOBEGIN;
      else
        CREDITBEGIN =  - :SALDOBEGIN;
      if (SALDOEND > 0) then
        DEBITEND = :SALDOEND;
      else
        CREDITEND =  - :SALDOEND;
      SALDOBEGIN = :SALDOEND;
      C = C + 1;
    END
    /*Если за указанный период нет движения то выводим сальдо на начало периода*/
    IF (C = 0) THEN
    BEGIN
      IF (SALDOBEGIN > 0) THEN
      BEGIN
        DEBITBEGIN = :SALDOBEGIN;
        DEBITEND = :SALDOBEGIN;
      END ELSE
      BEGIN
        CREDITBEGIN =  - :SALDOBEGIN;
        CREDITEND =  - :SALDOBEGIN;
      END
    END
  SUSPEND;
end^

COMMIT^

SET TERM ;^



CREATE TABLE msg_box (
  id             dintkey,
  parent         dparent,
  lb             dlb,
  rb             drb,
  name           dname,
  afull          dsecurity,
  reserved       dreserved
);

ALTER TABLE msg_box ADD CONSTRAINT msg_pk_box_id
  PRIMARY KEY (id);

ALTER TABLE msg_box ADD CONSTRAINT msg_fk_parent
  FOREIGN KEY (parent) REFERENCES msg_box (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

SET TERM ^ ;


CREATE TRIGGER msg_bi_box FOR msg_box
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;


COMMIT;

CREATE TABLE msg_message (
  id            dintkey,
  boxkey        dintkey,
  msgtype       dmsgtype,

  msgstart      dtimestamp NOT NULL,
  msgstartdate  COMPUTED (CAST (msgstart AS date)),
  msgstartmonth COMPUTED BY (g_d_formatdatetime('yyyy.mm', msgstart)),
  msgend        dtimestamp,

  subject       dtext254,
  header        dblobtext80,
  body          dblobtext80_1251,
  bdata         dblob4096,

  messageid     dtext60,
  fromid        dtext120,
  fromcontactkey dforeignkey,

  copy          dblobtext80,
  bcc           dblobtext80,

  toid          dtext120,
  tocontactkey  dforeignkey,

  operatorkey   dintkey,

  replykey      dforeignkey,

  cost          dcurrency,      /* кошт тэлефоннага званка */

  attachmentcount smallint,

  afull         dsecurity,
  achag         dsecurity,
  aview         dsecurity,

  reserved      dreserved,

  CHECK (msgtype IN ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'))
);

/*
входящий звонок	A
исходящий звонок	B
входящее электронное письмо	C
исходящее электронное письмо	D
входящий факс	E
исходящий факс	F
входящее письмо	G
исходящее письмо	H
*/

ALTER TABLE msg_message ADD CONSTRAINT msg_pk_message_id
  PRIMARY KEY (id);

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_boxkey
  FOREIGN KEY (boxkey) REFERENCES msg_box (id)
  ON UPDATE CASCADE;

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_fromck
  FOREIGN KEY (fromcontactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_tock
  FOREIGN KEY (tocontactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_ok
  FOREIGN KEY (operatorkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE msg_message ADD CONSTRAINT msg_fk_message_replykey
  FOREIGN KEY (replykey) REFERENCES msg_message (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

CREATE INDEX msg_x_message_messageid ON msg_message
  (messageid);

CREATE DESC INDEX msg_x_message_msgstart_d ON msg_message
  (msgstart);

CREATE ASC INDEX msg_x_message_msgstart_a ON msg_message
  (msgstart);

SET TERM ^ ;

CREATE TRIGGER msg_bi_message FOR msg_message
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF ((NEW.id IS NULL) OR (NEW.id = -1)) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.attachmentcount IS NULL) THEN
    NEW.attachmentcount = 0;
END
^


SET TERM ; ^

COMMIT;

CREATE TABLE msg_target
(
  messagekey  dintkey,
  contactkey  dintkey,
  viewed      dboolean DEFAULT 0 NOT NULL
);

ALTER TABLE msg_target ADD CONSTRAINT msg_pk_target
  PRIMARY KEY (messagekey, contactkey);

ALTER TABLE msg_target ADD CONSTRAINT msg_fk_target_mk
  FOREIGN KEY (messagekey) REFERENCES  msg_message (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE msg_target ADD CONSTRAINT msg_fk_target_ck
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE msg_attachment (
  id           dintkey,
  messagekey   dmasterkey,
  filename     dtext254,
  bdata        dblob4096,

  reserved     dinteger
);

ALTER TABLE msg_attachment ADD CONSTRAINT msg_pk_attachment_id
  PRIMARY KEY (id);

ALTER TABLE msg_attachment ADD CONSTRAINT msg_fk_attachment_mk
  FOREIGN KEY (messagekey) REFERENCES msg_message (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER msg_bi_attachment FOR msg_attachment
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF ((NEW.id IS NULL) OR (NEW.id = -1)) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER msg_ai_attachment FOR msg_attachment
  AFTER INSERT
  POSITION 1000
AS
BEGIN
  UPDATE msg_message SET attachmentcount = attachmentcount + 1
    WHERE id = NEW.messagekey;
END
^

CREATE TRIGGER msg_au_attachment FOR msg_attachment
  AFTER UPDATE
  POSITION 1000
AS
BEGIN
  IF (NEW.messagekey <> OLD.messagekey) THEN
  BEGIN
    UPDATE msg_message SET attachmentcount = attachmentcount + 1
      WHERE id = NEW.messagekey;

    UPDATE msg_message SET attachmentcount = attachmentcount - 1
      WHERE id = OLD.messagekey;
  END
END
^

CREATE TRIGGER msg_ad_attachment FOR msg_attachment
  AFTER DELETE
  POSITION 1000
AS
BEGIN
  UPDATE msg_message SET attachmentcount = attachmentcount - 1
    WHERE id = OLD.messagekey;
END
^

SET TERM ; ^

COMMIT;

/*   */

CREATE TABLE msg_account (
  id           dintkey,
  name         dname,
  userkey      dintkey,
  displayname  dname,
  emailaddress dname,
  pop3server   dtext40,
  pop3port     dSMALLINT DEFAULT 110 NOT NULL,
  smtpserver   dtext40,
  smtpport     dSMALLINT DEFAULT 25 NOT NULL,
  accname      dname,
  accpassword  dname,
  rempassword  dboolean DEFAULT 1 NOT NULL,
  autoreceive  dboolean DEFAULT 1 NOT NULL,
  deleteafter  dboolean DEFAULT 0 NOT NULL,

  reserved     dinteger
);

COMMIT;

ALTER TABLE msg_account ADD CONSTRAINT msg_pk_account_id
  PRIMARY KEY (id);

ALTER TABLE msg_account ADD CONSTRAINT msg_fk_account_uk
  FOREIGN KEY (userkey) REFERENCES gd_user (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER msg_bi_account FOR msg_account
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF ((NEW.id IS NULL) OR (NEW.id = -1)) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE msg_messagerules (
  id             dintkey,
  ruleorder      dSMALLINT,
  name           dname,
  data           dblob80,

  reserved       dinteger
);

ALTER TABLE msg_messagerules ADD CONSTRAINT msg_pk_messagerules
  PRIMARY KEY (id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER msg_bi_messagerules FOR msg_messagerules
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE I INTEGER;
BEGIN
  IF ((NEW.id IS NULL) OR (NEW.id = -1)) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.ruleorder IS NULL) THEN
  BEGIN
    SELECT MAX(ruleorder) FROM msg_messagerules INTO :I;
    IF (:I IS NULL) THEN
      I = 0;
    NEW.ruleorder = :I + 1;
  END
END
^

SET TERM ; ^

COMMIT;

/*

CREATE TABLE msg_feedback (
  id              dintkey,
  
  msgstate        dinteger NOT NULL,
  
  msgtype         dinteger NOT NULL,
  subject
  msgbody
  rating          dinteger,
  
  prevkey
  
  companyname     dname,
  companyid       druid,
  
  contactkey      dforeignkey, 
  contactid       druid,
  contactname     dname,
  contactphone    dphone,
  
  userkey         dforeignkey,
  username        dname,
  
  callback        dboolean_notnull,
  
  toname
  toid
  
  hostname        dname,
  
  posted
  sent
  
  creationdate
  creatorkey
  
  editiondate
  editorkey
  
  CONSTRAINT msg_pk_feedback PRIMARY KEY (id),
  CONSTRAINT msg_fk_feedback_contactkey FOREIGN KEY (contactkey)
    REFERENCES gd_contact (id)
    ON UPDATE CASCADE,
  CONSTRAINT msg_fk_feedback_userkey FOREIGN KEY (userkey)
    REFERENCES gd_user (id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT msg_chk_feedback_rating CHECK (rating BETWEEN 0 AND 10)    
);

*/

/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    rp_registry.sql

  Abstract

    Print registry.

  Author

    Anton Smirnov (13.12.2000)

  Revisions history

    Initial  13.12.2000  SAI    Initial version

  Status

    Draft

*/

CREATE TABLE rp_registry
(
  id	     DINTKEY,	/*      Уникальный ключ. Целое больше нуля.*/
  parent     dinteger,
  name	     dtext60,	/*	Наименование реестра */
/*  reporttype VARCHAR(1),	/*	CHAR(1)	G-группа, R - реестр, O - печать текущей записи */
/*  issystem   dboolean,	/*	dboolean	Если создана программистом, то "1",
                                если пользователем - "0". Пользователь может удалять
                                только записи = "0". */
  filename   dtext254,	/*	dtext255	Файл - шаблон */
/*  lastdate   DATE,	/*	Дата последнего обновления. */
  template   dRTF,	/*	Шаблон */
/* userkey    dforeignkey,	/*	Шаблон для конкретного пользователя */
  hotkey     dhotkey,   /*	Горячая клавиша для вызова */
  isregistry dboolean,  /*      Используется как реестр    */
  isquick    dboolean,  /*      Используется xFastReport    */
  isPrintPreview dboolean,  /*  Выводит окно просмотра перед печатью */
  afull      dsecurity,
  achag      dsecurity,
  aview      dsecurity,
  reserved   dinteger
);

ALTER TABLE rp_registry
  ADD CONSTRAINT rp_pk_registry PRIMARY KEY (id);

ALTER TABLE rp_registry ADD CONSTRAINT rp_fk_registry_parent
  FOREIGN KEY (parent) REFERENCES rp_registry(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER rp_bi_registry FOR rp_registry
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;



/*

  Copyright (c) 2000-2016 by Golden Software of Belarus, Ltd

  Script

    rp_report.sql

  Abstract

    An Interbase script for "universal" report.

  Author

    Andrey Shadevsky (__.__.__)

  Revisions history

    Initial  18.12.00  JKL    Initial version

  Status 
    
*/

/****************************************************

   Таблица для хранения шаблонов отчетов.

*****************************************************/

CREATE TABLE rp_reporttemplate
(
  id             dintkey,
  name           dname,
  description    dtext180,
  templatedata   dreporttemplate,
  templatetype   dtemplatetype,
  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,
  editiondate    deditiondate,           /* Дата последнего редактирования */
  editorkey      dintkey,                /* Ссылка на пользователя, который редактировал запись*/
  reserved       dinteger
);

ALTER TABLE rp_reporttemplate
  ADD CONSTRAINT rp_pk_reporttemplate PRIMARY KEY (id);

COMMIT;

CREATE EXCEPTION rp_e_invalidreporttemplate 'Unknown template type';

CREATE UNIQUE INDEX rp_x_reporttemplate_name ON rp_reporttemplate
  (name);

ALTER TABLE rp_reporttemplate ADD CONSTRAINT rp_fk_reporttemplate_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

SET TERM ^ ;

CREATE TRIGGER rp_bi_reporttemplate FOR rp_reporttemplate
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  NEW.templatetype = UPPER(NEW.templatetype);
  IF ((NEW.templatetype <> 'RTF') AND (NEW.templatetype <> 'FR') AND
   (NEW.templatetype <> 'XFR') AND (NEW.templatetype <> 'GRD') AND (NEW.templatetype <> 'FR4')) THEN
    EXCEPTION rp_e_invalidreporttemplate;
END
^

CREATE TRIGGER rp_bi_reporttemplate5 FOR rp_reporttemplate
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER rp_bu_reporttemplate5 FOR rp_reporttemplate
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения групп отчетов.

*****************************************************/

CREATE TABLE rp_reportgroup
(
  id             dintkey,
  parent         dforeignkey,
  name           dname,
  description    dtext180,
  lb             dlb,
  rb             drb,
  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,
  editiondate    deditiondate,
  usergroupname  dname DEFAULT '',
  reserved       dinteger
);

ALTER TABLE rp_reportgroup
  ADD CONSTRAINT rp_pk_reportgroup PRIMARY KEY (id);

CREATE UNIQUE INDEX rp_x_reportgroup_ugn ON rp_reportgroup
  (usergroupname);

CREATE UNIQUE INDEX rp_x_reportgroup_lrn ON
  rp_reportgroup (name, parent);

ALTER TABLE rp_reportgroup ADD CONSTRAINT rp_fk_reportgroup_parent
  FOREIGN KEY (parent) REFERENCES rp_reportgroup(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_rpgroupkey
  FOREIGN KEY (reportgroupkey) REFERENCES rp_reportgroup (id) ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER rp_before_insert_reportgroup FOR rp_reportgroup
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
    
  IF (NEW.usergroupname IS NULL) THEN
    NEW.usergroupname = CAST(NEW.id AS varchar(60));

  RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA', '100');
END
^
SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения списка отчетов.

*****************************************************/

CREATE TABLE rp_reportlist
(
  id                dintkey,                 /* идентификатор                      */
  name              dname,                   /* наименование отчета                */
  description       dtext180,                /* комментарий                        */
  frqrefresh        dinteger DEFAULT 1,      /* частота обновления в днях          */
  reportgroupkey    dintkey,
  paramformulakey   dforeignkey,
  mainformulakey    dintkey,
  eventformulakey   dforeignkey,
  templatekey       dforeignkey,
  IsRebuild         dboolean,
  afull             dsecurity,
  achag             dsecurity,
  aview             dsecurity,
  serverkey         dforeignkey,
  islocalexecute    dboolean DEFAULT 0,
  preview           dboolean DEFAULT 1,
  modalpreview      dboolean_notnull DEFAULT 0,
  globalreportkey   dinteger,               /* Глобальный идентификатор отчета     */
                                            /* Должен задаваться программистом     */
  editiondate       deditiondate,           /* Дата последнего редактирования */
  editorkey         dintkey,                /* Ссылка на пользователя, который редактировал запись*/
  displayinmenu     dboolean DEFAULT 1,     /* Отображать в меню формы */
  reserved          dinteger,
  folderkey         dforeignkey
);

ALTER TABLE rp_reportlist
  ADD CONSTRAINT rp_pk_reportlist PRIMARY KEY (id);

ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_groupkey
  FOREIGN KEY (reportgroupkey) REFERENCES rp_reportgroup(id)
  ON UPDATE CASCADE;

CREATE UNIQUE INDEX rp_x_reportlist_namerpgroup
  ON rp_reportlist(name, reportgroupkey);

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_paramfkey
  FOREIGN KEY (paramformulakey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_mainfkey
  FOREIGN KEY (mainformulakey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_eventfkey
  FOREIGN KEY (eventformulakey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_templatefkey
  FOREIGN KEY (templatekey) REFERENCES rp_reporttemplate(id)
  ON UPDATE CASCADE;

ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE RP_REPORTLIST ADD CONSTRAINT FK_RP_REPORTLIST_FOLDERKEY
  FOREIGN KEY (FOLDERKEY) REFERENCES GD_COMMAND (ID)
  ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

SET TERM ^ ;

CREATE TRIGGER rp_before_insert_reportlist FOR rp_reportlist
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  IF (NEW.islocalexecute IS NULL) THEN
    NEW.islocalexecute = 0;
END
^

CREATE TRIGGER rp_bi_reportlist5 FOR rp_reportlist
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE TRIGGER rp_bu_reportlist5 FOR rp_reportlist
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE OR ALTER TRIGGER rp_ad_reportlist FOR rp_reportlist
  ACTIVE
  AFTER DELETE 
  POSITION 32000
AS
  DECLARE VARIABLE RUID VARCHAR(21) = NULL;
BEGIN
  SELECT xid || '_' || dbid
  FROM gd_ruid
  WHERE id = OLD.id
  INTO :RUID;
  
  IF (COALESCE(:RUID, '') <> '') THEN
  BEGIN
    DELETE FROM gd_command WHERE cmdtype = 2 AND cmd = :RUID;
  END
END
^

CREATE OR ALTER TRIGGER gd_ad_documenttype FOR gd_documenttype
  ACTIVE
  AFTER DELETE
  POSITION 20000
AS
BEGIN
  IF (NOT EXISTS(
    SELECT *
    FROM gd_documenttype
    WHERE id <> OLD.id
      AND reportgroupkey = OLD.reportgroupkey)) THEN
  BEGIN
    IF (EXISTS(
      SELECT *
      FROM rp_reportlist l
        JOIN rp_reportgroup g ON l.reportgroupkey = g.id
        JOIN rp_reportgroup g_up ON g.lb >= g_up.lb AND g.rb <= g_up.rb
      WHERE
        g_up.id = OLD.reportgroupkey)) THEN
    BEGIN
      EXCEPTION gd_e_exception 'Перед удалением типа документа следует ' ||
        'удалить или переместить в другую группу связанные с ним отчеты.';
    END

    DELETE FROM rp_reportgroup WHERE id = OLD.reportgroupkey;
  END
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения результатов выполнения функций.

*****************************************************/

CREATE TABLE rp_reportresult
(
  functionkey              dintkey,
  crcparam                 dinteger NOT NULL,
  paramorder               dinteger DEFAULT 0 NOT NULL,
  paramdata                dblob,
  resultdata               dblob,
  createdate               dtimestamp,
  executetime              dtime,
  lastusedate              dtimestamp,
  reserved                 dinteger
);

ALTER TABLE rp_reportresult
  ADD CONSTRAINT rp_pk_reportresult PRIMARY KEY (functionkey, crcparam, paramorder);

COMMIT;

ALTER TABLE rp_reportresult ADD CONSTRAINT rp_fk_reportresult_functionkey
  FOREIGN KEY (functionkey) REFERENCES gd_function(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/****************************************************

   Таблица для хранения параметров серверов.

*****************************************************/

CREATE TABLE rp_reportserver
(
  id                      dintkey,
  computername            dtext20 NOT NULL,
  resultpath              dtext255,
  starttime               dtime,
  endtime                 dtime,
  frqdataread             dtime,
  actualreport            dinteger DEFAULT 1,
  unactualreport          dinteger DEFAULT 2,
  ibparams                dtext255,
  localstorage            dboolean DEFAULT 1,
  usedorder               dinteger,
  serverport              dintkey DEFAULT 2048,
  reserved                dinteger
);

ALTER TABLE rp_reportserver
  ADD CONSTRAINT rp_pk_reportserver PRIMARY KEY (id);

CREATE UNIQUE INDEX RP_X_REPORTSERVER_NAME
  ON RP_REPORTSERVER (COMPUTERNAME);

ALTER TABLE rp_reportserver ADD CONSTRAINT rp_chk_reportserver_act
  CHECK(actualreport <= unactualreport);

ALTER TABLE rp_reportlist ADD CONSTRAINT rp_fk_reportlist_serverkey
  FOREIGN KEY (serverkey) REFERENCES rp_reportserver(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER rp_before_insert_reportserver FOR rp_reportserver
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF ((NEW.frqdataread < '1:00:00') OR (NEW.frqdataread IS NULL)) THEN
    NEW.frqdataread = '1:00:00';

  IF (NEW.starttime IS NULL) THEN
  BEGIN
    NEW.starttime = '18:00:00';
    NEW.endtime = '21:00:00';
  END

  IF (NEW.endtime IS NULL) THEN
    NEW.endtime = NEW.starttime + 2;
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для привязки сервера отчетов к клиенту.
   Для подключения по умолчанию.

*****************************************************/

CREATE TABLE rp_reportdefaultserver
(
  serverkey                dintkey,
  clientname               dtext20 NOT NULL,
  reserved                 dinteger
);

ALTER TABLE rp_reportdefaultserver
  ADD CONSTRAINT rp_pk_reportdefaultserver PRIMARY KEY (serverkey, clientname);

ALTER TABLE rp_reportdefaultserver ADD CONSTRAINT rp_fk_reportdefaultserver_sk
  FOREIGN KEY (serverkey) REFERENCES rp_reportserver(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/****************************************************

   Таблица для привязки сервера отчетов к клиенту.
   Для подключения по умолчанию.

*****************************************************/

CREATE TABLE rp_additionalfunction
(
  mainfunctionkey                dintkey,
  addfunctionkey                 dintkey,
  reserved                       dinteger
);

ALTER TABLE rp_additionalfunction
  ADD CONSTRAINT rp_pk_additionalfunction PRIMARY KEY (mainfunctionkey, addfunctionkey);

ALTER TABLE rp_additionalfunction ADD CONSTRAINT rp_fk_additionalfunction_mfk
  FOREIGN KEY (mainfunctionkey) REFERENCES gd_function(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE rp_additionalfunction ADD CONSTRAINT rp_fk_additionalfunction_afk
  FOREIGN KEY (addfunctionkey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

COMMIT;

/*

  Copyright (c) 2000-2015 by Golden Software of Belarus

  Script

    evt_script.sql

  Abstract

    An Interbase script for "universal" report.

  Author

    Andrey Shadevsky (__.__.__)

  Revisions history

    Initial  29.11.01  JKL    Initial version

  Status 
    
    Draft

*/

/****************************************************

   Таблица для хранения объектов.

*****************************************************/

CREATE TABLE evt_object
(
  id             dintkey,
  name           dgdcname,
  description    dtext180,
  parent         dforeignkey,
  lb             dlb,
  rb             drb,
  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,
  objecttype     dsmallint,     /* 0-object; 1-class */
  reserved       dinteger,
  macrosgroupkey dforeignkey,
  parentindex    dinteger NOT NULL,
  reportgroupkey dforeignkey,
  classname      dgdcname,
  objectname     dgdcname,
  subtype        dsubtype,
  editiondate    deditiondate,  /* Дата последнего редактирования */
  editorkey      dintkey        /* Ссылка на пользователя, который редактировал запись*/
);

ALTER TABLE evt_object
  ADD CONSTRAINT evt_pk_object PRIMARY KEY (id);

/* !!! Никаких каскад делете быть не должно !!!*/

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_parent
  FOREIGN KEY (parent) REFERENCES evt_object (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_function ADD CONSTRAINT gd_fk_function_modulecode
  FOREIGN KEY (modulecode) REFERENCES evt_object (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_reportgrkey
  FOREIGN KEY (reportgroupkey) REFERENCES rp_reportgroup (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

CREATE ASC INDEX evt_x_object_objectname_upper
  ON evt_object
  COMPUTED BY (UPPER(objectname));

COMMIT;

CREATE EXCEPTION EVT_E_RECORDFOUND
  'Object or Class with such a parameters is already exist';

CREATE EXCEPTION EVT_E_RECORDINCORRECT
  'Do not insert or update this data.';

CREATE EXCEPTION EVT_E_INCORRECTVERSION
  'Incorrect version Gedemin for insert in evt_object Table.';

COMMIT;

SET TERM ^ ;

CREATE OR ALTER TRIGGER evt_bi_object FOR evt_object
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  NEW.parentindex = COALESCE(NEW.parent, 1);
END
^

CREATE OR ALTER TRIGGER evt_bi_object1 FOR evt_object
  ACTIVE
  BEFORE INSERT OR UPDATE
  POSITION 1
AS
BEGIN
  IF ((NOT NEW.name IS NULL) AND
     (NEW.objectname IS NULL) AND
     (NEW.classname IS NULL) AND
     (NEW.subtype IS NULL))
  THEN
    EXCEPTION  EVT_E_INCORRECTVERSION;

  NEW.objectname = COALESCE(NEW.objectname, '');
  NEW.classname = COALESCE(NEW.classname, '');
  NEW.subtype = COALESCE(NEW.subtype, '');

  IF
    (
    ((NEW.objectname = '') AND (NEW.classname = '')) OR
    ((NEW.subtype <> '') AND ((NEW.objectname <> '') OR
     (NEW.classname = '')))
    ) THEN
  BEGIN
    EXCEPTION EVT_E_RECORDINCORRECT;
  END
END
^

CREATE OR ALTER TRIGGER evt_bi_object2 FOR evt_object
  ACTIVE
  BEFORE INSERT OR UPDATE
  POSITION 2
AS
BEGIN
  /* Проверяет уникальность объекта или класса с подтипом*/
  IF
    (EXISTS(SELECT * FROM evt_object
    WHERE
    (UPPER(objectname) = UPPER(NEW.objectname))  AND
    (UPPER(classname) = UPPER(NEW.classname)) AND
    (parent IS NOT DISTINCT FROM NEW.parent) AND
    (UPPER(subtype) = UPPER(NEW.subtype)) AND
    (id <> NEW.id)))
  THEN
  BEGIN
    EXCEPTION EVT_E_RECORDFOUND;
  END

  /* Заполняет поля name, objecttype для поддержки */
  /* старой версии Гедемина */
  IF (NEW.classname = '') THEN
  BEGIN
    NEW.objecttype = 0;
    NEW.name = NEW.objectname;
  END ELSE
    BEGIN
      NEW.objecttype = 1;
      IF (NEW.subtype = '') THEN
      BEGIN
        NEW.name = NEW.classname;
      END ELSE
        NEW.name = NEW.classname || NEW.subtype;
    END
END
^

CREATE OR ALTER TRIGGER evt_bu_object FOR evt_object
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  NEW.parentindex = COALESCE(NEW.parent, 1);
END
^

CREATE OR ALTER TRIGGER evt_bi_object5 FOR evt_object
  BEFORE INSERT
  POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');

  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE OR ALTER TRIGGER evt_bu_object5 FOR evt_object
  BEFORE UPDATE
  POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

/****************************************************

   Таблица для событий и ссылок на функции.

*****************************************************/

CREATE TABLE evt_objectevent
(
  id             dintkey,
  objectkey      dintkey,
  eventname      dname,
  functionkey    dforeignkey,
  afull          dsecurity,
  reserved       dinteger,
  disable        dboolean,
  editiondate    deditiondate,  /* Дата последнего редактирования */
  editorkey      dintkey        /* Ссылка на пользователя, который редактировал запись*/
);

/* Primary keys definition */

ALTER TABLE EVT_OBJECTEVENT ADD CONSTRAINT EVT_PK_OBJECTEVENT_ID PRIMARY KEY (ID);

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE evt_objectevent ADD CONSTRAINT evt_fk_object_fk
  FOREIGN KEY (functionkey) REFERENCES gd_function (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_objectevent ADD CONSTRAINT evt_fk_object_objectkey
  FOREIGN KEY (objectkey) REFERENCES evt_object(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE evt_objectevent ADD CONSTRAINT evt_fk_objectevent_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

/* Indices definition */

CREATE UNIQUE INDEX evt_idx_objectevent ON evt_objectevent (eventname, objectkey);

COMMIT;

SET TERM ^ ;
CREATE OR ALTER TRIGGER evt_bi_objectevent5 FOR evt_objectevent
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE OR ALTER TRIGGER evt_bu_objectevent5 FOR evt_objectevent
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************/
/**                                                **/
/**   Таблица для хранения дерева макросов         **/
/**                                                **/
/****************************************************/

CREATE TABLE evt_macrosgroup (
  id             dintkey,      /* Уникальный ключ */
  parent         dforeignkey,  /* Парент на родителя */
  lb             dlb,
  rb             drb,
  name           dname,        /* Наименование поле для примера */

  isglobal       dboolean,

  description    dblobtext80,  /*  Описание группы */
  editiondate    deditiondate, /* Дата последнего редактирования */
  editorkey      dintkey,      /* Ссылка на пользователя, который редактировал запись*/

  reserved       dblob         /*Зарезервированно*/
);

ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_pk_macrosgroup_id
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_mrsgroupkey
  FOREIGN KEY (macrosgroupkey) REFERENCES evt_macrosgroup (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_fk_macrosgroup_parent
  FOREIGN KEY (parent) REFERENCES evt_macrosgroup (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_fk_macrosgroup_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

CREATE INDEX evt_x_macrosgroup_isglobal ON evt_macrosgroup (isglobal);  

COMMIT;

SET TERM ^ ;

CREATE OR ALTER TRIGGER evt_bi_macrosgroup5 FOR evt_macrosgroup
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE OR ALTER TRIGGER evt_bu_macrosgroup5 FOR evt_macrosgroup
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

/****************************************************/
/**                                                **/
/**    Таблица для хранения макросов               **/
/**                                                **/
/****************************************************/

CREATE TABLE evt_macroslist (
  id              dintkey,      /* Уникальный ключ */
  macrosgroupkey  dforeignkey,  /*  Ключ группы макросов */
  functionkey     dforeignkey,  /*  Ключ макроса */
  name            dname,        /* Наименование поле для примера */
  serverkey       dforeignkey,
  islocalexecute  dboolean,
  isrebuild       dboolean,
  executedate     dtext254,
  shortcut        dinteger,
  editiondate     deditiondate,  /* Дата последнего редактирования */
  editorkey       dintkey,       /* Ссылка на пользователя, который редактировал запись*/
  displayinmenu   dboolean DEFAULT 1,  /* Отображать в меню формы */
  /*runonlogin      dboolean_notnull DEFAULT 0,*/
  achag           dsecurity,
  afull           dsecurity,
  aview           dsecurity
);

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_pk_macroslist_id
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macroslist_mrsgroupkey
  FOREIGN KEY (macrosgroupkey) REFERENCES evt_macrosgroup(id)
  ON UPDATE CASCADE;

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macros_functionkey
  FOREIGN KEY (functionkey) REFERENCES gd_function (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macroslist_rpserver
  FOREIGN KEY (serverkey) REFERENCES rp_reportserver(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macroslist_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

CREATE UNIQUE INDEX EVT_MACROSLIST_IDX
  ON EVT_MACROSLIST
  (NAME, MACROSGROUPKEY);

CREATE UNIQUE INDEX EVT_X_MACROSLIST_FUNCTIONKEY
  ON EVT_MACROSLIST
  (FUNCTIONKEY);

COMMIT;

SET TERM ^ ;

CREATE OR ALTER TRIGGER evt_bi_macroslist5 FOR evt_macroslist
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

CREATE OR ALTER TRIGGER evt_bu_macroslist5 FOR evt_macroslist
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);
END
^

SET TERM ; ^

COMMIT;


/*

  Copyright (c) 2000-2012 by Golden Software of Belarus


  Script

    inv_movement.sql

  Abstract

    Таблицы для учета движения товарно-материальных
    ценностей и услуг.

  Author

    Mikle Shoihet    (16.07.2001)
    Leonid Agafonov
    Teryokhina Julia
    Romanovski Denis

  Revisions history

    1.0    Julia    23.07.2001    Initial version.
    2.0    Dennis   03.08.2001    Initial version.

  Status


*/

CREATE EXCEPTION INV_E_INVALIDMOVEMENT 'The movement was made incorrect!';

COMMIT;

/*
 *
 *  Список карточек движения ТМЦ
 *
 */

CREATE TABLE inv_card
(
  id                    dintkey,              /* идентификатор */
  parent                dforeignkey,          /* ссылка на родительскую карточку */

  goodkey               dintkey,              /* ссылка на товар */

  documentkey           dintkey,              /* ссылка на документ создавший карту */
  firstdocumentkey      dintkey,              /* ссылка на первый докуиент создавший карточку */

  firstdate             ddate NOT NULL,       /* дата первого появления карточки */

  companykey            dintkey,              /* ссылка на нашу компанию */

  reserved              dreserved             /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_card ADD CONSTRAINT inv_pk_card
  PRIMARY KEY (id);

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_mk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_fmk
  FOREIGN KEY (firstdocumentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_companykey
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany (companykey)
  ON UPDATE CASCADE;

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_parent
  FOREIGN KEY (parent) REFERENCES inv_card (id)
  ON UPDATE CASCADE;


COMMIT;


/*
 *
 *  Движение ТМЦ
 *
 */


CREATE TABLE inv_movement
(
  id                    dintkey,              /* идентификатор */
  movementkey           dintkey,              /* идентификатор движения */

  movementdate          ddate NOT NULL,       /* дата движения */

  documentkey           dintkey,              /* ссылка на документ */
  contactkey            dintkey,              /* ссылка на контакт */

  cardkey               dintkey,              /* ссылка на карточку */
  goodkey               dintkey,              /* ссылка на товар */

  debit                 dquantity DEFAULT 0,  /* приход ТМЦ (услуг) в количественном выражении */
  credit                dquantity DEFAULT 0,  /* расход ТМЦ (услуг) в количественном выражении */

  disabled              dboolean DEFAULT 0,   /* отключена ли запись */
  reserved              dreserved             /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_movement ADD CONSTRAINT inv_pk_movement
  PRIMARY KEY (id);

ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_dk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_ck
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_cardk
  FOREIGN KEY (cardkey) REFERENCES inv_card (id)
  ON UPDATE CASCADE;

ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_goodk
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON UPDATE CASCADE;


COMMIT;

CREATE INDEX INV_X_MOVEMENT_CCD ON INV_MOVEMENT (
  CARDKEY, CONTACTKEY, MOVEMENTDATE);

COMMIT;

CREATE INDEX INV_X_MOVEMENT_MK ON INV_MOVEMENT (
  MOVEMENTKEY);

COMMIT;

/*
 *
 *  Рассчитанные остатки по
 *  определенной карточке.
 *
 */

CREATE TABLE inv_balance
(
  cardkey               dintkey,              /* ссылка на карточку */
  contactkey            dintkey,              /* ссылка на контакт */

  balance               dcurrency NOT NULL,   /* остаток на карточке */
  goodkey               dintkey,              /* ссылка на товар */

  reserved              dreserved             /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_balance ADD CONSTRAINT inv_fk_balance_ck
  FOREIGN KEY (cardkey) REFERENCES inv_card (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_balance ADD CONSTRAINT inv_fk_balance_contk
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_balance ADD CONSTRAINT inv_fk_balance_gk
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;


ALTER TABLE inv_balance ADD CONSTRAINT inv_pk_balance
  PRIMARY KEY (cardkey, contactkey);

COMMIT;

CREATE INDEX INV_X_BALANCE_CB ON INV_BALANCE (
  CONTACTKEY, BALANCE);

COMMIT;


SET TERM ^ ;

CREATE PROCEDURE inv_makerest                               
AS                                               
  DECLARE VARIABLE CONTACTKEY INTEGER;           
  DECLARE VARIABLE CARDKEY INTEGER;              
  DECLARE VARIABLE GOODKEY INTEGER;
  DECLARE VARIABLE BALANCE NUMERIC(15, 4);       
BEGIN                                            
  DELETE FROM INV_BALANCE;                      
  FOR                                           
    SELECT m.contactkey, m.goodkey, m.cardkey, SUM(m.debit - m.credit) 
      FROM                                                  
        inv_movement m                                      
      WHERE disabled = 0                                    
    GROUP BY m.contactkey, m.goodkey, m.cardkey                        
    INTO :contactkey, :goodkey, :cardkey, :balance                    
  DO                                                        
    INSERT INTO inv_balance (contactkey, goodkey, cardkey, balance)  
      VALUES (:contactkey, :goodkey, :cardkey, :balance);             
END 
^

SET TERM ; ^

COMMIT;

CREATE TABLE inv_balanceoption(
  id                      DINTKEY,
  name                    DNAME,
  viewfields              DBLOBTEXT80,
  sumfields               DBLOBTEXT80,
  GOODVIEWFIELDS          DBLOBTEXT80,
  GOODSUMFIELDS           DBLOBTEXT80,
  branchkey               dforeignkey,               /* Ветка в исследователе */                                 
  usecompanykey           dboolean,
  ruid                    DRUID
);

COMMIT;

ALTER TABLE inv_balanceoption ADD CONSTRAINT inv_pk_balanceoption
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE inv_balanceoption ADD CONSTRAINT gd_fk_balanceoption_branchkey 
  FOREIGN KEY (branchkey) REFERENCES gd_command (id) ON UPDATE CASCADE;

COMMIT;


CREATE GENERATOR inv_g_balancenum;
SET GENERATOR inv_g_balancenum TO 0;

COMMIT;


SET TERM ^ ;

CREATE TRIGGER inv_bi_balanceoption FOR inv_balanceoption
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE id INTEGER;
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
    
END
^



/*
 *  Триггер создания уникального кода
 */

CREATE TRIGGER inv_bi_card FOR inv_card
  BEFORE INSERT
  POSITION 0
  AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END;
^

CREATE TRIGGER inv_bu_card FOR inv_card
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE firstdocumentkey INTEGER;
  DECLARE VARIABLE firstdate DATE;
BEGIN

  IF ((OLD.parent <> NEW.parent) OR (OLD.parent IS null and NEW.parent IS NOT NULL)) THEN
  BEGIN
    SELECT firstdocumentkey, firstdate FROM inv_card
    WHERE id = NEW.parent
    INTO :firstdocumentkey, :firstdate;

    NEW.firstdocumentkey = :firstdocumentkey;
    NEW.firstdate = :firstdate;
  END

  IF ((OLD.firstdocumentkey <> NEW.firstdocumentkey) OR
       (OLD.firstdate <> NEW.firstdate)) THEN
    UPDATE inv_card SET
      firstdocumentkey = NEW.firstdocumentkey,
      firstdate = NEW.firstdate
    WHERE
      parent = NEW.id;

END;
^

CREATE TRIGGER inv_bu_card_goodkey FOR inv_card
  BEFORE UPDATE
  POSITION 1
AS
BEGIN
  IF (NEW.GOODKEY <> OLD.GOODKEY) THEN
  BEGIN
    UPDATE inv_movement SET goodkey = NEW.goodkey
    WHERE cardkey = NEW.id;

    UPDATE inv_balance SET goodkey = NEW.goodkey
    WHERE cardkey = NEW.id;
  END
END;
^


CREATE TRIGGER INV_BD_CARD FOR INV_CARD
ACTIVE BEFORE DELETE POSITION 0
AS
BEGIN
  DELETE FROM INV_CARD
    WHERE
      PARENT = OLD.ID AND DOCUMENTKEY = OLD.DOCUMENTKEY;
END;
^

CREATE TRIGGER inv_bi_card_block FOR inv_card
  INACTIVE
  BEFORE INSERT
  POSITION 28017
AS
  DECLARE VARIABLE D DATE;
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (GEN_ID(gd_g_block, 0) > 0) THEN
  BEGIN
    SELECT doc.documentdate, doc.documenttypekey
    FROM gd_document doc
    WHERE doc.id = NEW.documentkey
    INTO :D, :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      IF ((D - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
      BEGIN
        BG = GEN_ID(gd_g_block_group, 0);
        IF (:BG = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END ELSE
        BEGIN
          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
            INTO :IG;
          IF (BIN_AND(:BG, :IG) = 0) THEN
          BEGIN
            EXCEPTION gd_e_block;
          END
        END
      END
    END
  END
END
^

CREATE TRIGGER inv_bu_card_block FOR inv_card
  INACTIVE
  BEFORE UPDATE
  POSITION 28017
AS
  DECLARE VARIABLE D DATE;
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (GEN_ID(gd_g_block, 0) > 0) THEN
  BEGIN
    SELECT doc.documentdate, doc.documenttypekey
    FROM gd_document doc
    WHERE doc.id = NEW.documentkey
    INTO :D, :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      IF ((D - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
      BEGIN
        BG = GEN_ID(gd_g_block_group, 0);
        IF (:BG = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END ELSE
        BEGIN
          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
            INTO :IG;
          IF (BIN_AND(:BG, :IG) = 0) THEN
          BEGIN
            EXCEPTION gd_e_block;
          END
        END
      END
    END
  END
END
^

CREATE TRIGGER inv_bd_card_block FOR inv_card
  INACTIVE
  BEFORE DELETE
  POSITION 28017
AS
  DECLARE VARIABLE D DATE;
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (GEN_ID(gd_g_block, 0) > 0) THEN
  BEGIN
    SELECT doc.documentdate, doc.documenttypekey
    FROM gd_document doc
    WHERE doc.id = OLD.documentkey
    INTO :D, :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      IF ((D - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
      BEGIN
        BG = GEN_ID(gd_g_block_group, 0);
        IF (:BG = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END ELSE
        BEGIN
          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
            INTO :IG;
          IF (BIN_AND(:BG, :IG) = 0) THEN
          BEGIN
            EXCEPTION gd_e_block;
          END
        END
      END
    END
  END
END
^

/*
 *
 *  После добавлением движения
 *  осуществляем расчет сальдо
 *
 */


CREATE TRIGGER inv_ai_movement FOR inv_movement
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE NEWBALANCE NUMERIC(10, 4);
BEGIN
  /* если запись с остатком есть - изменяем ее, если нет - создаем */
  IF (EXISTS(
    SELECT BALANCE
    FROM INV_BALANCE
    WHERE CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY)
  )
  THEN BEGIN
    UPDATE INV_BALANCE
    SET
      BALANCE = BALANCE + (NEW.DEBIT - NEW.CREDIT)
    WHERE
      CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY;
  END ELSE BEGIN
    INSERT INTO INV_BALANCE
      (CARDKEY, CONTACTKEY, BALANCE)
    VALUES
      (NEW.CARDKEY, NEW.CONTACTKEY, NEW.DEBIT - NEW.CREDIT);
  END
END;
^


/*
 *
 *  После изменения движения
 *  осуществляем расчет сальдо
 *
 */

CREATE TRIGGER INV_AU_MOVEMENT FOR INV_MOVEMENT
  ACTIVE
  AFTER UPDATE
  POSITION 0
AS
  DECLARE VARIABLE existscontaccard INTEGER;
BEGIN
  /* если запись с остатком есть - изменяем ее, если нет - создаем */
  existscontaccard = 1;
  IF (OLD.disabled = 0) THEN
  BEGIN
    IF (EXISTS(
      SELECT BALANCE
      FROM INV_BALANCE
      WHERE CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY))
    THEN BEGIN
      UPDATE INV_BALANCE
      SET
        BALANCE = BALANCE - (OLD.DEBIT - OLD.CREDIT)
      WHERE
        CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY;
    END
    ELSE
      existscontaccard = 0;
  END
  
  IF (NEW.disabled = 0) THEN
  BEGIN
    IF (
       (NEW.contactkey <> OLD.contactkey) AND
       (NEW.cardkey = OLD.cardkey) AND
       (NEW.debit = OLD.debit) AND
       (NEW.credit = OLD.credit) AND
       (OLD.disabled = 0) AND
       (existscontaccard = 0)
       )
    THEN
      existscontaccard = 0;
    ELSE
    IF (EXISTS(
        SELECT BALANCE
        FROM INV_BALANCE
        WHERE CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY))
    THEN BEGIN
      UPDATE INV_BALANCE
      SET
        BALANCE = BALANCE + (NEW.DEBIT - NEW.CREDIT)
      WHERE
        CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY;
    END ELSE BEGIN
        INSERT INTO INV_BALANCE
          (CARDKEY, CONTACTKEY, BALANCE)
        VALUES
          (NEW.CARDKEY, NEW.CONTACTKEY, NEW.DEBIT - NEW.CREDIT);
    END
  END
END;
^

/*
 *
 *  После изменения движения
 *  осуществляем расчет сальдо
 *
 */

CREATE TRIGGER inv_ad_movement FOR inv_movement
  AFTER DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.disabled = 0) THEN
  BEGIN
    /*
    эта проверка тут излишняя.

    IF (EXISTS(
      SELECT BALANCE
      FROM INV_BALANCE
      WHERE CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY))
    THEN BEGIN
    */
      UPDATE INV_BALANCE
      SET
        BALANCE = BALANCE - (OLD.DEBIT - OLD.CREDIT)
      WHERE
        CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY;
    /*
    END
    */
  END

END;
^

CREATE EXCEPTION inv_e_movementchange 'Can not change documentkey in movement'^

CREATE TRIGGER INV_BI_MOVEMENT FOR INV_MOVEMENT
ACTIVE BEFORE INSERT POSITION 0
AS
  DECLARE VARIABLE balance NUMERIC(15, 4);
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.debit IS NULL) THEN
    NEW.debit = 0;

  IF (NEW.credit IS NULL) THEN
    NEW.credit = 0;

  IF (NEW.credit > 0) THEN
  BEGIN
    SELECT balance FROM inv_balance
    WHERE
      contactkey = NEW.contactkey
       AND cardkey = NEW.cardkey
    INTO :balance;
    IF (:balance IS NULL) THEN
      balance = 0;
    IF ((:balance > 0) AND (:balance < NEW.credit)) THEN
    BEGIN
      EXCEPTION INV_E_INVALIDMOVEMENT;
    END
  END

END;
^

CREATE TRIGGER INV_BI_MOVEMENT_GOODKEY FOR INV_MOVEMENT
ACTIVE BEFORE INSERT POSITION 1
AS
BEGIN
  SELECT goodkey FROM inv_card
  WHERE id = NEW.cardkey
  INTO NEW.goodkey;
END;
^

CREATE TRIGGER INV_BU_MOVEMENT FOR INV_MOVEMENT
  ACTIVE
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE balance NUMERIC(15, 4);
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'GD_MERGING_RECORDS') IS NULL) THEN
  BEGIN
    IF (NEW.documentkey <> OLD.documentkey) THEN
      EXCEPTION inv_e_movementchange;

    IF ((NEW.disabled = 1) OR (NEW.contactkey <> OLD.contactkey) OR (NEW.cardkey <> OLD.cardkey)) THEN
    BEGIN
      IF (OLD.debit > 0) THEN
      BEGIN
        SELECT balance FROM inv_balance
        WHERE contactkey = OLD.contactkey
          AND cardkey = OLD.cardkey
        INTO :balance;
        IF (COALESCE(:balance, 0) < OLD.debit) THEN
          EXCEPTION INV_E_INVALIDMOVEMENT;
      END
    END ELSE
    BEGIN
      IF (OLD.debit > NEW.debit) THEN
      BEGIN
        SELECT balance FROM inv_balance
        WHERE contactkey = OLD.contactkey
          AND cardkey = OLD.cardkey
        INTO :balance;
        balance = COALESCE(:balance, 0);
        IF ((:balance > 0) AND (:balance < OLD.debit - NEW.debit)) THEN
          EXCEPTION INV_E_INVALIDMOVEMENT;
      END ELSE
      BEGIN
        IF (NEW.credit > OLD.credit) THEN
        BEGIN
          SELECT balance FROM inv_balance
          WHERE contactkey = OLD.contactkey
            AND cardkey = OLD.cardkey
          INTO :balance;
          balance = COALESCE(:balance, 0);
          IF ((:balance > 0) AND (:balance < NEW.credit - OLD.credit)) THEN
            EXCEPTION INV_E_INVALIDMOVEMENT;
        END
      END
    END
  END
END;
^

CREATE TRIGGER INV_BU_MOVEMENT_GOODKEY FOR INV_MOVEMENT
ACTIVE BEFORE UPDATE POSITION 1
AS
BEGIN
  IF ((NEW.cardkey <> OLD.cardkey) OR (NEW.goodkey IS NULL)) THEN
    SELECT goodkey FROM inv_card
    WHERE id = NEW.cardkey
    INTO NEW.goodkey;
END;
^


CREATE TRIGGER INV_BD_MOVEMENT FOR INV_MOVEMENT
BEFORE DELETE POSITION 0
AS
  DECLARE VARIABLE DOCKEY INTEGER;
  DECLARE VARIABLE FIRSTDOCKEY INTEGER;
  DECLARE VARIABLE CONTACTTYPE INTEGER;
  DECLARE VARIABLE BALANCE NUMERIC(15, 4);
BEGIN
  /* Trigger body */
  IF ((OLD.disabled = 0) AND NOT EXISTS(SELECT * FROM INV_MOVEMENT WHERE DOCUMENTKEY = OLD.DOCUMENTKEY AND DISABLED = 1)) THEN
  BEGIN
  
    SELECT documentkey, firstdocumentkey FROM inv_card WHERE id = OLD.cardkey
    INTO :dockey, :firstdockey;
  
    IF (:dockey = OLD.documentkey) THEN
    BEGIN
      IF (EXISTS (SELECT id FROM inv_movement m WHERE m.cardkey = OLD.cardkey AND m.documentkey <> OLD.documentkey)) THEN
        EXCEPTION INV_E_INVALIDMOVEMENT;
    END
    ELSE
      IF (OLD.debit > 0) THEN
      BEGIN
        SELECT contacttype FROM gd_contact WHERE id = OLD.contactkey
        INTO :contacttype;
        IF (:contacttype = 2 or :contacttype = 4) THEN
        BEGIN
          SELECT balance FROM inv_balance
          WHERE
            contactkey = OLD.contactkey
            AND cardkey = OLD.cardkey
          INTO :balance;
          IF (:balance IS NULL) THEN
            balance = 0;
          IF (:balance < OLD.debit) THEN
          BEGIN
            EXCEPTION INV_E_INVALIDMOVEMENT;
          END
        END
      END
      
  END

END;
^

CREATE PROCEDURE INV_P_GETCARDS (
    PARENT INTEGER)
RETURNS (
    ID INTEGER)
AS
BEGIN

  FOR
    SELECT ID FROM INV_CARD WHERE PARENT = :PARENT
    INTO :ID
  DO
  BEGIN
    SUSPEND;
    FOR
      SELECT ID FROM INV_P_GETCARDS(:ID)
      INTO :ID
    DO
      SUSPEND;
  END
END;
^

CREATE OR ALTER PROCEDURE INV_GETCARDMOVEMENT (
    CARDKEY INTEGER,
    CONTACTKEY INTEGER,
    DATEEND DATE)
RETURNS (
    REMAINS NUMERIC(15, 4))
AS
BEGIN
  REMAINS = 0;
  SELECT SUM(m.debit - m.credit)
  FROM inv_movement m
  WHERE m.cardkey = :CARDKEY AND m.contactkey = :CONTACTKEY
    AND m.movementdate > :DATEEND AND m.disabled = 0
  INTO :REMAINS;
  IF (REMAINS IS NULL) THEN
    REMAINS = 0;
  SUSPEND;
END
^

CREATE TRIGGER INV_BI_BALANCE_GOODKEY FOR INV_BALANCE
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
  SELECT goodkey FROM inv_card
  WHERE id = NEW.cardkey
  INTO NEW.goodkey;
END;
^

CREATE TRIGGER INV_BU_BALANCE FOR INV_BALANCE
ACTIVE BEFORE UPDATE POSITION 0
AS
  DECLARE VARIABLE quantity NUMERIC(15, 4);
BEGIN
/*Тело триггера*/
  IF (NEW.contactkey <> OLD.contactkey) THEN
  BEGIN
    /*
    IF (EXISTS (SELECT * FROM inv_balance WHERE contactkey = NEW.contactkey AND
      cardkey = NEW.cardkey))
    THEN
    BEGIN
    */
      quantity = NULL;
      SELECT balance
        FROM inv_balance
        WHERE contactkey = NEW.contactkey AND cardkey = NEW.cardkey
        INTO :quantity;
      IF (NOT (:quantity IS NULL)) THEN
      BEGIN
        DELETE FROM inv_balance
        WHERE
          contactkey = NEW.contactkey AND cardkey = NEW.cardkey;

        NEW.balance = NEW.balance + :quantity;
      END
    /*
    END
    */
  END
END
^

CREATE TRIGGER INV_BU_BALANCE_GOODKEY FOR INV_BALANCE
  ACTIVE
  BEFORE UPDATE
  POSITION 1
AS
BEGIN
  IF ((NEW.cardkey <> OLD.cardkey) OR (NEW.goodkey IS NULL)) THEN
    SELECT goodkey FROM inv_card
    WHERE id = NEW.cardkey
    INTO NEW.goodkey;
END;
^

CREATE TRIGGER inv_bi_movement_block FOR inv_movement
  INACTIVE
  BEFORE INSERT
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((NEW.movementdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
    WHERE d.id = NEW.documentkey
    INTO :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

CREATE TRIGGER inv_bu_movement_block FOR inv_movement
  INACTIVE
  BEFORE UPDATE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (((NEW.movementdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) 
      OR ((OLD.movementdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0))) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
    WHERE d.id = NEW.documentkey
    INTO :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

CREATE TRIGGER inv_bd_movement_block FOR inv_movement
  INACTIVE
  BEFORE DELETE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((OLD.movementdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
    WHERE d.id = OLD.documentkey
    INTO :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

SET TERM ; ^

COMMIT;

/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    inv_price.sql

  Abstract

    Таблицы для учета прайс-листов.

  Author

    Denis Romanovski (19 october 2001)

  Revisions history

    Initial  19.10.2001  Dennis    Initial version

  Status

    Draft

*/

CREATE TABLE inv_price
(
  documentkey      dintkey,                 /* Ссылка на документ */

  name             dname,                   /* Наименвоание прайс-листа */
  description      dtext180,                /* Описание прайс-листа */

  relevancedate    ddate NOT NULL,          /* Дата актуальности (начала действия) */

  reserved         dinteger                 /* Зарезервировано */
);

COMMIT;

ALTER TABLE inv_price ADD CONSTRAINT inv_pk_price_dk
  PRIMARY KEY(documentkey);

ALTER TABLE inv_price ADD CONSTRAINT inv_fk_price_dk
  FOREIGN KEY(documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

CREATE TABLE inv_priceline
(
  documentkey      dintkey,                 /* Ссылка на позицию документа */
  pricekey         dmasterkey,                 /* Ссылка на шапку прайс-листа */

  goodkey          dintkey,                 /* Ссылка на ТМЦ */

  reserved         dinteger                 /* Зарезервировано */
);

COMMIT;

ALTER TABLE inv_priceline ADD CONSTRAINT inv_pk_priceline_dk
  PRIMARY KEY(documentkey);

ALTER TABLE inv_priceline ADD CONSTRAINT inv_fk_priceline_dk
  FOREIGN KEY(documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE inv_priceline ADD CONSTRAINT inv_fk_priceline_pk
  FOREIGN KEY(pricekey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE inv_priceline ADD CONSTRAINT inv_fk_priceline_gk
  FOREIGN KEY(goodkey) REFERENCES gd_good(id)
  ON UPDATE CASCADE;

COMMIT;


/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    gd_tax.sql

  Abstract

    An Interbase script for script control.           

  Author

    Dubrovnik Alexander (24.01.03)

  Revisions history

    Initial  24.01.03  DAlex    Initial version

  Status

*/


/****************************************************

   Таблицы для расчета функций отчетов бухгалтерии

*****************************************************/

/* Таблица типов отчетов бухгалтерии */

CREATE TABLE gd_taxtype
(
  id          dintkey  PRIMARY KEY,
  name        dname,
  editiondate deditiondate
 );

CREATE UNIQUE INDEX gd_idx_taxtype ON gd_taxtype
  (name);

COMMIT;

INSERT INTO gd_taxtype(id, name)
  VALUES (350001, 'За месяц');

INSERT INTO gd_taxtype(id, name)
  VALUES (350002, 'За квартал');

INSERT INTO gd_taxtype(id, name)
  VALUES (350003, 'За период');

COMMIT;

CREATE EXCEPTION gd_e_taxtype 'Can not change data in GD_TAXTYPE table';

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_taxtype FOR gd_taxtype
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  EXCEPTION gd_e_taxtype;
END ^

CREATE TRIGGER gd_bd_taxtype FOR gd_taxtype
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  EXCEPTION gd_e_taxtype;
END ^

CREATE TRIGGER gd_bu_taxtype FOR gd_taxtype
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  EXCEPTION gd_e_taxtype;
END ^

SET TERM ; ^

COMMIT;

/* таблица имен бух.отчетов */
CREATE TABLE GD_TAXNAME (
    ID              DINTKEY,
    NAME            DNAME,
    TRANSACTIONKEY  DFOREIGNKEY NOT NULL,
    ACCOUNTKEY      DFOREIGNKEY NOT NULL,
    EDITIONDATE     DEDITIONDATE
);

ALTER TABLE GD_TAXNAME ADD
  PRIMARY KEY (ID);
ALTER TABLE GD_TAXNAME ADD CONSTRAINT FK_GD_TAXNAME
  FOREIGN KEY (TRANSACTIONKEY) REFERENCES AC_TRANSACTION (ID);
ALTER TABLE GD_TAXNAME ADD CONSTRAINT FK_GD_TAXNAME_ACCOUNTKEY
  FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID);
CREATE UNIQUE INDEX GD_IDX_TAXNAME
  ON GD_TAXNAME (NAME);

COMMIT;

/* таблица актуальности налогов */

CREATE TABLE GD_TAXACTUAL (
    ID              DINTKEY,
    TAXNAMEKEY      DINTKEY,
    ACTUALDATE      DDATE NOT NULL,
    REPORTGROUPKEY  DINTKEY,
    REPORTDAY       DSMALLINT NOT NULL,
    TYPEKEY         DINTKEY,
    DESCRIPTION     DTEXT120,
    TRRECORDKEY     DFOREIGNKEY NOT NULL,
    EDITIONDATE     DEDITIONDATE
);

ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT CHK_GD_TAXACTUAL_RD
  CHECK (0 < reportday AND reportday < 32);
ALTER TABLE GD_TAXACTUAL ADD PRIMARY KEY (ID);
ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT FK_GD_TAXACTUAL
  FOREIGN KEY (TAXNAMEKEY) REFERENCES GD_TAXNAME (ID)
  on update CASCADE;
ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT FK_GD_TAXACTUAL_T
  FOREIGN KEY (TYPEKEY) REFERENCES GD_TAXTYPE (ID)
  on update CASCADE;
ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT FK_GD_TAXACTUAL_TRG
  FOREIGN KEY (REPORTGROUPKEY) REFERENCES RP_REPORTGROUP (ID)
  on update CASCADE;
ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT FK_GD_TAXACTUAL_TRRECORD
  FOREIGN KEY (TRRECORDKEY) REFERENCES AC_TRRECORD (ID)
  on update CASCADE;

CREATE UNIQUE INDEX GD_IDX_TAXACTUAL
  ON GD_TAXACTUAL (TAXNAMEKEY, ACTUALDATE);

COMMIT;

/* таблица расчетных дат по налогу */

CREATE TABLE GD_TAXDESIGNDATE (
    DOCUMENTKEY   DINTKEY,
    TAXNAMEKEY    DINTKEY,
    TAXACTUALKEY  DINTKEY
);

COMMIT;

ALTER TABLE GD_TAXDESIGNDATE ADD PRIMARY KEY (DOCUMENTKEY);
ALTER TABLE GD_TAXDESIGNDATE ADD CONSTRAINT FK_GD_TAXDESIGNDATE FOREIGN KEY (TAXNAMEKEY) REFERENCES GD_TAXNAME (ID);
ALTER TABLE GD_TAXDESIGNDATE ADD CONSTRAINT FK_GD_TAXDESIGNDATE_ADDD FOREIGN KEY (TAXACTUALKEY) REFERENCES GD_TAXACTUAL (ID);
ALTER TABLE GD_TAXDESIGNDATE ADD CONSTRAINT FK_GD_TAXDESIGNDATE_DDD FOREIGN KEY (DOCUMENTKEY) REFERENCES GD_DOCUMENT (ID) ON DELETE CASCADE ON UPDATE CASCADE;

COMMIT;

/* таблица результов функций */

CREATE TABLE GD_TAXRESULT (
    DOCUMENTKEY       DINTKEY,
    TAXDESIGNDATEKEY  DINTKEY,
    RESULT            DTEXT255,
    NAME              DTEXT60 COLLATE PXW_CYRL,
    DESCRIPTION       DTEXT1024 COLLATE PXW_CYRL
);

COMMIT;

ALTER TABLE GD_TAXRESULT ADD PRIMARY KEY (DOCUMENTKEY);
ALTER TABLE GD_TAXRESULT ADD CONSTRAINT FK_GD_TAXRESULT_D FOREIGN KEY (DOCUMENTKEY) REFERENCES GD_DOCUMENT (ID) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE GD_TAXRESULT ADD CONSTRAINT FK_GD_TAXRESULT_DD FOREIGN KEY (TAXDESIGNDATEKEY) REFERENCES GD_TAXDESIGNDATE (DOCUMENTKEY);

COMMIT;


/*

  Copyright (c) 2000-2015 by Golden Software of Belarus

  Script

    at_setting.sql

  Abstract

    Репозиторий настроек БД

  Author

    Julia Teryokhina

  Revisions history

    Initial  27.05.2002  Julia    Initial version

*/

/* Таблица настроек*/

CREATE TABLE at_setting (
  id              dintkey NOT NULL,  /* идентификатор */
  name            dname NOT NULL     /* наименование настройки */
                  collate PXW_CYRL,
  data            DBLOB4096,         /* данные объекта, сохраненные в поток */
  storagedata     DBLOB4096,         /* данные хранилища, сохраненные в поток */
  disabled        dboolean DEFAULT 0,/* активная / неактивная настройка */
  modifydate      dtimestamp,        /* дата сохранения настройки в базу */
  settingsruid    dblobtext80_1251,  /* хранит руиды настроек, от которых зависит данная натсройка*/
  version         dinteger,          /* версия настройки, возрастает при каждом сохранении настройки в базу */ 
  minexeversion   dtext20,           /* min версия Exe-файла для работы настройки */
  mindbversion    dtext20,           /* min версия БД для работы настройки */
  ending          dboolean,           /* конечная/промежуточная настройка */
  description     dtext255           /* описание настройки */
);

ALTER TABLE at_setting ADD CONSTRAINT at_pk_setting PRIMARY KEY (id);

SET TERM ^ ;

CREATE OR ALTER TRIGGER at_bi_setting FOR at_setting
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);
END
^

SET TERM ; ^

COMMIT;

/* Таблица позиций настроек */
/* Поля категория объекта и наименование объекта используются чисто для
   отображения содержимого настройки, при этом поля мастера могут
   содержать информацию о мастрее сохраняемого объекта, опять-таки
   только для просмотра содержимого настройки. Например, мы сохраняем
   поле usr$newfield таблицы usr$newtable. Мастер-категория - таблица,
   мастер-наименование - usr$newtable, категория объекта - поле,
   наименование объекта - usr$newfield. */

CREATE TABLE at_settingpos (
  id              dintkey,                   /* идентификатор */
  settingkey      dmasterkey,       /* ссылка на настройку */
  mastercategory  dtext20 collate PXW_CYRL,  /* категория местера */
  mastername      dtext60 collate PXW_CYRL,  /* наименование мастера */
  objectclass     dclassname NOT NULL        /* класс сохраняемого объекта */
                  collate PXW_CYRL,
  subtype         dtext40 collate PXW_CYRL,  /* сабтайп сохраняемого объекта */
  category        dtext20 collate PXW_CYRL,  /* категория сохраняемого объекта */
  objectname      dname NOT NULL             /* наименование сохраняемого объекта */
                  collate PXW_CYRL,
  xid             dinteger NOT NULL,         /* идентификатор сохраняемого объекта
                                                (из базы-родителя) */
  dbid            dinteger NOT NULL,         /* идентификатор базы родителя */
  objectorder     dinteger NOT NULL,         /* порядок следования объектов в настройке */
  withdetail      dboolean_notnull default 0 /* считывать все детальные объекты для данного объекта */
                  NOT NULL,
  needmodify      dboolean_notnull default 1 /* модифицировать объекты при активации настройки */
                  NOT NULL,
  autoadded       DBOOLEAN_NOTNULL DEFAULT 0 /* позиция добавлена автоматически */
                  NOT NULL

);

ALTER TABLE at_settingpos ADD CONSTRAINT at_pk_settingpos PRIMARY KEY (id);

ALTER TABLE at_settingpos ADD CONSTRAINT at_uk_settingpos
 UNIQUE (settingkey, xid, dbid);

ALTER TABLE at_settingpos ADD  CONSTRAINT at_fk_settingpos_settinkey
FOREIGN KEY (settingkey) REFERENCES at_setting (id)
ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX AT_SETTINGPOS_XID_DBID ON AT_SETTINGPOS (XID, DBID);
SET TERM ^ ;

CREATE TRIGGER at_bi_settingpos FOR at_settingpos
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);
  IF (NEW.objectorder IS NULL) THEN
    NEW.objectorder = NEW.id;

END
^
SET TERM ; ^

COMMIT;

/* Таблица для хранения веток реестра в настройках*/

CREATE TABLE at_setting_storage
(
  id           dintkey,                 /* идентификатор */
  settingkey   dmasterkey,              /* ссылка на настройку*/
  branchname   dblobtext80_1251,        /* наименование ветки стораджа */
  valuename    dtext255,                /* наименование параметра.
                                           Если пустое, значит сохранена вся ветка*/
  crc          dinteger
);

COMMIT;

ALTER TABLE at_setting_storage ADD
CONSTRAINT at_pk_setting_storage PRIMARY KEY (id);

ALTER TABLE at_setting_storage ADD
CONSTRAINT at_fk_setstorage_settingkey
FOREIGN KEY (settingkey) REFERENCES at_setting (id)
ON DELETE CASCADE ON UPDATE CASCADE;

SET TERM ^ ;

CREATE TRIGGER at_bi_setting_storage FOR at_setting_storage
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);
END
^

SET TERM ; ^

CREATE TABLE at_namespace (
  id            dintkey,
  name          dtext255 NOT NULL UNIQUE,
  caption       dtext255,
  filename      dtext255,
  filetimestamp TIMESTAMP,
  version       dtext20 DEFAULT '1.0.0.0' NOT NULL,
  dbversion     dtext20,
  optional      dboolean_notnull DEFAULT 0,
  internal      dboolean_notnull DEFAULT 1,
  comment       dblobtext80_1251,
  settingruid   VARCHAR(21),
  filedata      dscript,
  changed       dboolean_notnull DEFAULT 1,
  md5           CHAR(32), 

  CONSTRAINT at_pk_namespace PRIMARY KEY (id)
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER at_biu_namespace FOR at_namespace
  ACTIVE
  BEFORE INSERT OR UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (TRIM(COALESCE(NEW.caption, '')) = '') THEN
    NEW.caption = NEW.name;
END
^

CREATE OR ALTER TRIGGER at_ad_namespace FOR at_namespace
  ACTIVE
  AFTER DELETE
  POSITION 0
AS
BEGIN
  DELETE FROM gd_ruid WHERE id = OLD.id;
END
^

SET TERM ; ^

CREATE TABLE at_object (
  id              dintkey,
  namespacekey    dintkey,
  objectname      dname,
  objectclass     dclassname NOT NULL,
  subtype         dtext60,
  xid             dinteger_notnull,
  dbid            dinteger_notnull,
  objectpos       dinteger,
  alwaysoverwrite dboolean_notnull DEFAULT 0,
  dontremove      dboolean_notnull DEFAULT 0,
  includesiblings dboolean_notnull DEFAULT 0,
  headobjectkey   dforeignkey,
  modified        TIMESTAMP,
  curr_modified   TIMESTAMP,

  CONSTRAINT at_pk_object PRIMARY KEY (id),
  CONSTRAINT at_fk_object_namespacekey FOREIGN KEY (namespacekey)
    REFERENCES at_namespace (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT at_fk_object_headobjectkey FOREIGN KEY (headobjectkey)
    REFERENCES at_object (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT at_chk_object_hk CHECK (headobjectkey IS DISTINCT FROM id)
);

CREATE UNIQUE INDEX at_x_object
  ON at_object (xid, dbid, namespacekey);

SET TERM ^ ;

CREATE OR ALTER TRIGGER at_bi_object FOR at_object
  ACTIVE
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF ((NEW.xid < 147000000 AND NEW.dbid <> 17) OR
    (NEW.xid >= 147000000 AND NOT EXISTS(SELECT * FROM gd_ruid 
      WHERE xid = NEW.xid AND dbid = NEW.dbid))) THEN
  BEGIN
    EXCEPTION gd_e_invalid_ruid 'Invalid ruid. XID = ' ||
      NEW.xid || ', DBID = ' || NEW.dbid || '.';
  END

  IF (NEW.objectpos IS NULL) THEN
  BEGIN
    SELECT MAX(objectpos)
    FROM at_object
    WHERE namespacekey = NEW.namespacekey
    INTO NEW.objectpos;
    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1;
  END ELSE
  BEGIN
    IF (EXISTS(SELECT * FROM at_object WHERE objectpos = NEW.objectpos 
      AND namespacekey = NEW.namespacekey)) THEN
    BEGIN
      UPDATE at_object SET objectpos = objectpos + 1
        WHERE objectpos >= NEW.objectpos AND namespacekey = NEW.namespacekey;
    END    
  END
END
^

/*

CREATE OR ALTER TRIGGER at_au_object FOR at_object
  ACTIVE
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.namespacekey <> OLD.namespacekey) THEN
  BEGIN
    IF (COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK'), 0) = 0) THEN
    BEGIN
      IF (EXISTS(SELECT * FROM at_object WHERE id = NEW.headobjectkey
        AND namespacekey <> NEW.namespacekey)) THEN
      BEGIN
        EXCEPTION gd_e_exception 'Нельзя перемещать подчиненный объект.';
      END
    END  
  END
END
^

*/

CREATE OR ALTER TRIGGER at_aiud_object FOR at_object
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 20000
AS
BEGIN
  IF (INSERTING) THEN
    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
      AND n.id = NEW.namespacekey;

  IF (DELETING) THEN
    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
      AND n.id = OLD.namespacekey;
      
  IF (UPDATING) THEN
  BEGIN
    IF (NEW.namespacekey <> OLD.namespacekey) THEN
      UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
        AND n.id IN (NEW.namespacekey, OLD.namespacekey);
    
    IF (NEW.objectname <> OLD.objectname
      OR NEW.objectclass <> OLD.objectclass
      OR NEW.subtype IS DISTINCT FROM OLD.subtype
      OR NEW.xid <> OLD.xid
      OR NEW.dbid <> OLD.dbid
      OR NEW.objectpos IS DISTINCT FROM OLD.objectpos
      OR NEW.alwaysoverwrite <> OLD.alwaysoverwrite
      OR NEW.dontremove <> OLD.dontremove
      OR NEW.includesiblings <> OLD.includesiblings
      OR NEW.headobjectkey IS DISTINCT FROM OLD.headobjectkey
      OR NEW.modified IS DISTINCT FROM OLD.modified
      OR NEW.curr_modified IS DISTINCT FROM OLD.curr_modified) THEN
    BEGIN  
      UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
        AND n.id = NEW.namespacekey;
    END         
  END  
END
^

CREATE OR ALTER TRIGGER gd_ad_documenttype_option FOR gd_documenttype_option
  ACTIVE
  AFTER DELETE
  POSITION 32000
AS
  DECLARE VARIABLE xid  INTEGER = -1;
  DECLARE VARIABLE dbid INTEGER = -1;
BEGIN  
  FOR
    SELECT xid, dbid FROM gd_ruid WHERE id = OLD.id
    INTO :xid, :dbid  
  DO BEGIN
    DELETE FROM at_object WHERE xid = :xid AND dbid = :dbid;
    DELETE FROM gd_ruid WHERE id = OLD.id;
  END  
END
^

CREATE OR ALTER TRIGGER gd_au_ruid FOR gd_ruid 
  ACTIVE
  AFTER UPDATE
  POSITION 32000
AS
BEGIN
  IF (NEW.xid <> OLD.xid OR NEW.dbid <> OLD.dbid) THEN
    UPDATE at_object SET xid = NEW.xid, dbid = NEW.dbid
      WHERE xid = OLD.xid AND dbid = OLD.dbid;
END 
^ 

SET TERM ; ^

CREATE TABLE at_namespace_link (
  namespacekey   dintkey,
  useskey        dintkey,

  CONSTRAINT at_pk_namespace_link PRIMARY KEY (namespacekey, useskey),
  CONSTRAINT at_fk_namespace_link_nsk FOREIGN KEY (namespacekey)
    REFERENCES at_namespace (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT at_fk_namespace_link_usk FOREIGN KEY (useskey)
    REFERENCES at_namespace (id)
    ON UPDATE CASCADE
    ON DELETE NO ACTION,
  CONSTRAINT at_chk_namespace_link CHECK (namespacekey <> useskey)
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER at_aiud_namespace_link FOR at_namespace_link
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 20000
AS
BEGIN
  IF (INSERTING) THEN
    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
      AND n.id = NEW.namespacekey;

  IF (UPDATING) THEN
  BEGIN
    IF (NEW.namespacekey <> OLD.namespacekey OR NEW.useskey <> OLD.useskey) THEN
      UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
        AND (n.id = NEW.namespacekey OR n.id = OLD.namespacekey);
  END

  IF (DELETING) THEN
    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
      AND n.id = OLD.namespacekey;
END
^

CREATE OR ALTER TRIGGER at_aiu_namespace_link FOR at_namespace_link
  ACTIVE
  AFTER INSERT OR UPDATE
  POSITION 20001
AS
BEGIN
  IF (EXISTS(
    WITH RECURSIVE tree AS
    (
      SELECT 
        namespacekey AS initial, namespacekey, useskey
      FROM
        at_namespace_link
      WHERE
        namespacekey = NEW.namespacekey AND useskey = NEW.useskey      
     
      UNION ALL
     
      SELECT
        IIF(tr.initial <> tt.namespacekey, tr.initial, -1) AS initial,
        tt.namespacekey,
        tt.useskey
      FROM
        at_namespace_link tt JOIN tree tr ON
          tr.useskey = tt.namespacekey AND tr.initial > 0
     
    )
    SELECT * FROM tree WHERE initial = -1)) THEN
  BEGIN
    EXCEPTION gd_e_exception 'Обнаружена циклическая зависимость ПИ.';
  END
END
^  

CREATE OR ALTER TRIGGER at_bu_object FOR at_object
  ACTIVE
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE depend_id dintkey;
  DECLARE VARIABLE p INTEGER;
  DECLARE VARIABLE hopos INTEGER;
BEGIN
  IF ((NEW.xid < 147000000 AND NEW.dbid <> 17) OR
    (NEW.xid >= 147000000 AND NOT EXISTS(SELECT * FROM gd_ruid 
      WHERE xid = NEW.xid AND dbid = NEW.dbid))) THEN
  BEGIN
    EXCEPTION gd_e_invalid_ruid 'Invalid ruid. XID = ' ||
      NEW.xid || ', DBID = ' || NEW.dbid || '.';
  END

  IF (NEW.namespacekey <> OLD.namespacekey) THEN
  BEGIN       
    IF (COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK'), 0) = 0) THEN
    BEGIN
      IF (NEW.objectpos IS DISTINCT FROM OLD.objectpos) THEN
        EXCEPTION gd_e_exception 'Can not change object position and namespace simultaneously.';      
    
      IF (NEW.headobjectkey IS DISTINCT FROM OLD.headobjectkey) THEN
        EXCEPTION gd_e_exception 'Can not change head object and namespace simultaneously.';      
    
      IF (NEW.headobjectkey IS NOT NULL) THEN
      BEGIN
        SELECT objectpos
        FROM at_object
        WHERE id = NEW.headobjectkey
        INTO :hopos;        
      
        IF (:hopos > NEW.objectpos) THEN
        BEGIN
          /* prevent cycling */      
          DELETE FROM at_namespace_link
          WHERE namespacekey = NEW.namespacekey AND useskey = OLD.namespacekey;        
          
          /* transfer links from old to new */
          MERGE INTO at_namespace_link AS l
          USING (SELECT useskey FROM at_namespace_link 
            WHERE namespacekey = OLD.namespacekey AND useskey <> NEW.namespacekey) AS u
          ON l.namespacekey = NEW.namespacekey AND l.useskey = u.useskey
          WHEN NOT MATCHED THEN INSERT (namespacekey, useskey) VALUES (NEW.namespacekey, u.useskey);
        
          /* setup link from old to new */
          UPDATE OR INSERT INTO at_namespace_link (namespacekey, useskey)
          VALUES (OLD.namespacekey, NEW.namespacekey)
            MATCHING (namespacekey, useskey); 
        END 
        ELSE IF (:hopos < NEW.objectpos) THEN
        BEGIN
          UPDATE OR INSERT INTO at_namespace_link (namespacekey, useskey)
          VALUES (NEW.namespacekey, OLD.namespacekey)
            MATCHING (namespacekey, useskey); 
        END        
               
        NEW.headobjectkey = NULL; 
      END  
    END
  
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK',
      COALESCE(CAST(RDB$GET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK') AS INTEGER), 0) + 1);

    FOR
      SELECT id
      FROM at_object
      WHERE (headobjectkey = NEW.id OR id = NEW.id) 
        AND namespacekey = OLD.namespacekey
      ORDER BY objectpos
      INTO :depend_id
    DO BEGIN
      p = NULL;   
      SELECT MAX(objectpos)
      FROM at_object
      WHERE namespacekey = NEW.namespacekey
      INTO :p;
      p = COALESCE(:p, 0) + 1;
        
      IF (:depend_id = NEW.id) THEN
      BEGIN
        NEW.objectpos = :p;
      END ELSE
      BEGIN     
        UPDATE at_object SET namespacekey = NEW.namespacekey, objectpos = :p
          WHERE id = :depend_id;
      END    
    END

    RDB$SET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK',
      CAST(RDB$GET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK') AS INTEGER) - 1);
  END
  ELSE IF (NEW.objectpos IS NULL) THEN
  BEGIN
    SELECT MAX(objectpos)
    FROM at_object
    WHERE namespacekey = NEW.namespacekey
    INTO NEW.objectpos;
    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1;
  END
END
^

CREATE OR ALTER PROCEDURE at_p_findnsrec (InPath VARCHAR(32000),
  InFirstID INTEGER, InID INTEGER)
  RETURNS (OutPath VARCHAR(32000), OutFirstID INTEGER, OutID INTEGER)
AS
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE NAME VARCHAR(255);
BEGIN
  FOR
    SELECT l.useskey, n.name
    FROM at_namespace_link l JOIN at_namespace n
      ON n.id = l.useskey
    WHERE l.namespacekey = :InID
    INTO :ID, :NAME
  DO BEGIN
    IF (POSITION(:ID || '=' || :NAME || ',' IN :InPath) > 0) THEN
    BEGIN
      OutPath = :InPath || :ID || '=' || :NAME;
      OutID = :ID;
      OutFirstID = :InFirstID;
      SUSPEND;
    END ELSE
    BEGIN
      FOR
        SELECT OutPath, OutFirstID, OutID
        FROM at_p_findnsrec(:InPath || :ID || '=' || :NAME || ',', :InFirstID, :ID)
        INTO :OutPath, :OutFirstID, :OutID
      DO BEGIN
        IF (:OutPath > '') THEN
          SUSPEND;
      END
    END
  END
END
^

CREATE OR ALTER PROCEDURE at_p_del_duplicates (
  DeleteFromID INTEGER,
  CurrentID INTEGER,
  Stack VARCHAR(32000))
AS
  DECLARE VARIABLE id INTEGER;
  DECLARE VARIABLE nsid INTEGER;
BEGIN
  IF (:DeleteFromID <> :CurrentID) THEN
  BEGIN
    FOR
      SELECT o1.id
      FROM at_object o1 JOIN at_object o2
        ON o1.xid = o2.xid AND o1.dbid = o2.dbid
      WHERE o1.NAMESPACEKEY = :DeleteFromID
        AND o2.NAMESPACEKEY = :CurrentID
        AND o1.headobjectkey IS NULL
        AND o2.headobjectkey IS NULL
      INTO :id
    DO BEGIN
      DELETE FROM at_object WHERE id = :id;
    END
  END

  FOR
    SELECT l.useskey
    FROM at_namespace_link l
    WHERE l.namespacekey = :CurrentID
      AND POSITION(('(' || l.useskey || ')') IN :Stack) = 0
    INTO :nsid
  DO BEGIN
    EXECUTE PROCEDURE at_p_del_duplicates (:DeleteFromID, :nsid,
      :Stack || '(' || :nsid || ')');
  END
END
^

SET TERM ; ^

CREATE GENERATOR at_g_file_tree;

CREATE GLOBAL TEMPORARY TABLE at_namespace_file (
  filename      dtext255,
  filetimestamp TIMESTAMP,
  filesize      dinteger,
  name          dtext255 NOT NULL UNIQUE,
  caption       dtext255,
  version       dtext20,
  dbversion     dtext20,
  optional      dboolean_notnull DEFAULT 0,
  internal      dboolean_notnull DEFAULT 1,
  comment       dblobtext80_1251,
  xid           dinteger,
  dbid          dinteger,
  md5           CHAR(32),

  CONSTRAINT at_pk_namespace_file PRIMARY KEY (filename)
)
  ON COMMIT DELETE ROWS;

CREATE INDEX at_x_namespace_file_ruid ON at_namespace_file
  (xid, dbid);

CREATE GLOBAL TEMPORARY TABLE at_namespace_file_link (
  filename      dtext255 NOT NULL,
  uses_xid      dintkey,
  uses_dbid     dintkey,
  uses_name     dtext255 NOT NULL,

  CONSTRAINT at_pk_namespace_file_link
    PRIMARY KEY (filename, uses_xid, uses_dbid),
  CONSTRAINT at_fk_namespace_file_link_fn
    FOREIGN KEY (filename) REFERENCES at_namespace_file (filename)
      ON UPDATE CASCADE
      ON DELETE CASCADE
)
  ON COMMIT DELETE ROWS;

CREATE INDEX at_x_namespace_file_link_ur ON at_namespace_file_link
  (uses_xid, uses_dbid);

CREATE GLOBAL TEMPORARY TABLE at_namespace_sync (
  namespacekey  dforeignkey,
  filename      dtext255,
  operation     CHAR(2) DEFAULT '  ' NOT NULL,

  CONSTRAINT at_fk_namespace_sync_fn
    FOREIGN KEY (filename) REFERENCES at_namespace_file (filename)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  CONSTRAINT at_chk_namespace_sync_op
    CHECK (operation IN ('  ', '< ', '> ', '>>', '<<', '==', '=>', '<=', '! ', '? '))
)
  ON COMMIT DELETE ROWS;

GRANT ALL     ON at_namespace             TO administrator;
GRANT ALL     ON at_object                TO administrator;
GRANT ALL     ON at_namespace_link        TO administrator;
GRANT ALL     ON at_namespace_file        TO administrator;
GRANT ALL     ON at_namespace_file_link   TO administrator;
GRANT ALL     ON at_namespace_sync        TO administrator;
GRANT EXECUTE ON PROCEDURE at_p_findnsrec TO administrator;
GRANT EXECUTE ON PROCEDURE at_p_del_duplicates TO administrator;

COMMIT;

CREATE DOMAIN DFILETYPE AS CHAR(1) NOT NULL CHECK (VALUE IN('D','F'));

COMMIT;

CREATE TABLE gd_file
(
  id              dintkey,
  /* Левая (верхняя) граница. Одновременно может использоваться */
  /* как второй уникальный индекс, если группы и список */
  /* находятся в разных таблицах */
  lb              dlb,
  rb              drb,          /* Правая (нижняя) граница */

  parent          dparent,
  filetype        dfiletype,    /* D - директория, F - файл  */
  name            dfilename NOT NULL, /* _мя файла без пуцi     */
  datasize        dinteger,          /* размер файла */
  data            dblob4096,         /* данные сжатые */
  crc             dinteger,          /* код для проверки содержимого файла */
  description     dtext80,           /* описание сод файла */
 
  afull           dsecurity,           /* права доступа                   */
  achag           dsecurity,
  aview           dsecurity,

  creatorkey      dintkey,             /* хто стварыў дакумент            */
  creationdate    dcreationdate,       /* дата _ час стварэньня           */
  editorkey       dintkey,             /* хто рэдактаваў                  */
  editiondate     deditiondate,        /* дата _ час рэдактаваньня        */
  reserved        dreserved

);


COMMIT;

ALTER TABLE gd_file
  ADD CONSTRAINT gd_pk_file PRIMARY KEY (id);

ALTER TABLE gd_file ADD CONSTRAINT gd_fk_file_parent
  FOREIGN KEY (parent) REFERENCES gd_file(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_file ADD CONSTRAINT gd_fk_file_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE gd_file ADD CONSTRAINT gd_fk_file_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;


COMMIT;

CREATE EXCEPTION gd_e_invalidfilename 'You entered invalid file name!';

COMMIT;

SET TERM ^ ;

/*
  При вставке и обновлении записи автоматически инициализируем
  поля Дата создания и Дата редактирования, если программист не
  присвоил их самостоятельно.
*/

CREATE TRIGGER gd_bi_file FOR gd_file
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE id INTEGER;
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.creatorkey IS NULL) THEN
    NEW.creatorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.creationdate IS NULL) THEN
    NEW.creationdate = CURRENT_TIMESTAMP(0);

  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = RDB$GET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY');
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP(0);

  IF (NEW.parent IS NULL) THEN
  BEGIN
    SELECT id FROM gd_file
    WHERE parent IS NULL AND UPPER(name) = UPPER(NEW.name)
    INTO :id;
  END
  ELSE
  BEGIN
    SELECT id FROM gd_file
    WHERE parent = NEW.parent AND UPPER(name) = UPPER(NEW.name)
    INTO :id;
  END

  IF (:id IS NOT NULL) THEN
    EXCEPTION gd_e_InvalidFileName;

END
^

CREATE TRIGGER gd_bu_file FOR gd_file
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE id INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    SELECT id FROM gd_file
    WHERE parent IS NULL AND UPPER(name) = UPPER(NEW.name)
    AND id <> NEW.id
    INTO :id;
  END
  ELSE
  BEGIN
    SELECT id FROM gd_file
    WHERE parent = NEW.parent AND UPPER(name) = UPPER(NEW.name)
    AND id <> NEW.id
    INTO :id; 
  END

  IF (:id IS NOT NULL) THEN
    EXCEPTION gd_e_InvalidFileName;

END
^

SET TERM ; ^

COMMIT;
/*

  Copyright (c) 2001-2012 by Golden Software of Belarus


  Script

    gd_block_rule.sql

  Abstract
  
    Таблицы, триггеры, хранимые процедуры 
    механизма блокировки периода

  Author

*/

CREATE TABLE GD_BLOCK_RULE 
(
  ID                    DINTKEY,                     /*Первичный ключ*/
  NAME                  DNAME,                       /*Наименование правила*/
  ORDR                  DINTEGER_NOTNULL,            /*Порядковый номер правила*/
  DISABLED              DDISABLED DEFAULT 0,         /*Правило отключено*/
  EDITIONDATE           DEDITIONDATE
);

COMMIT;

ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT UNQ1_GD_BLOCK_RULE UNIQUE (ORDR);

ALTER TABLE GD_BLOCK_RULE ADD CONSTRAINT PK_GD_BLOCK_RULE PRIMARY KEY (ID);

GRANT ALL ON GD_BLOCK_RULE TO ADMINISTRATOR;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER GD_BI_BLOCK_RULE FOR GD_BLOCK_RULE
ACTIVE BEFORE INSERT POSITION 0
AS
begin
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
end
^

SET TERM ; ^

COMMIT;
/****************************************************

   Таблица для хранения списка баз
   участвующих в обмене данными.

*****************************************************/

CREATE TABLE rpl_database (
    id         DINTKEY,
    name       DNAME,
    isourbase  DBOOLEAN,

    CONSTRAINT rpl_pk_database_id PRIMARY KEY (id)
);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER rpl_bi_database FOR rpl_database
  ACTIVE 
  BEFORE INSERT 
  POSITION 0
AS
BEGIN
  IF (new.id IS NULL) THEN
    new.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения ссылок на РУИДы записей,
   пересылаемых между соответствующими базами,
   и состояние их пересылки.

*****************************************************/

CREATE TABLE rpl_record (
    id           DINTKEY,
    basekey      DINTKEY,
    editiondate  DTIMESTAMP,
    state        SMALLINT,

    CONSTRAINT rpl_pk_record_id PRIMARY KEY (id, basekey),
    CONSTRAINT rpl_fk_record_basekey FOREIGN KEY (basekey)
      REFERENCES rpl_database (id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
    CONSTRAINT rpl_fk_record_id FOREIGN KEY (ID)
      REFERENCES GD_RUID (ID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

COMMIT;
  CREATE TABLE gd_smtp
  (
    id               dintkey,                     /* первичный ключ          */
    name             dname,                       /* имЯ                     */
    description      dtext180,                    /* описание                */
    email            dname,                       /* адрес электронной почты */
    login            dname,                       /* логин                   */
    passw            VARCHAR(256) NOT NULL,       /* пароль                  */
    ipsec            dtext8,                      /* протокол безопасности   SSLV2, SSLV23, SSLV3, TLSV1 */
    timeout          dinteger_notnull DEFAULT -1,
    server           dtext80 NOT NULL,            /* SMTP Sever */
    port             dinteger_notnull DEFAULT 25, /* SMTP Port */
    principal        dboolean_notnull,

    creatorkey       dforeignkey,
    creationdate     dcreationdate,
    editorkey        dforeignkey,
    editiondate      deditiondate,
    afull            dsecurity,
    achag            dsecurity,
    aview            dsecurity,
    disabled         ddisabled,

    CONSTRAINT gd_pk_smtp PRIMARY KEY (id),
    CONSTRAINT gd_fk_smtp_ck
      FOREIGN KEY (creatorkey) REFERENCES gd_contact (id)
      ON UPDATE CASCADE,
    CONSTRAINT gd_fk_smtp_ek
      FOREIGN KEY (editorkey) REFERENCES gd_contact (id)
      ON UPDATE CASCADE,
    CONSTRAINT gd_smtp_chk_timeout CHECK (timeout >= -1),
    CONSTRAINT gd_smtp_chk_ipsec CHECK(ipsec IN ('SSLV2', 'SSLV23', 'SSLV3', 'TLSV1')),
    CONSTRAINT gd_smtp_chk_server CHECK (server > ''),
    CONSTRAINT gd_smtp_chk_port CHECK (port > 0 AND port < 65536)
  );

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_smtp FOR gd_smtp
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE OR ALTER TRIGGER gd_aiu_smtp FOR gd_smtp
  AFTER INSERT OR UPDATE
  POSITION 32000
AS
BEGIN
  IF (NEW.principal = 1) THEN
    UPDATE gd_smtp SET principal = 0 
	WHERE principal = 1 AND id <> NEW.id;
END
^

SET TERM ; ^
 
COMMIT;CREATE TABLE gd_autotask
 (
   id               dintkey,
   name             dname,
   description      dtext180,
   functionkey      dforeignkey,      /* если задано -- будет выполняться скрипт-функция */
   autotrkey        dforeignkey,      /* если задано -- будет выполняться автоматическая хозяйственная операция */
   reportkey        dforeignkey,      /* если задано -- будет выполняться построение отчета */
   emailgroupkey    dforeignkey,
   emailrecipients  dtext1024,
   emailsmtpkey     dforeignkey,
   emailexporttype  VARCHAR(4),
   cmdline          dtext255,         /* если задано -- командная строка для вызова внешней программы */
   backupfile       dtext255,         /* если задано -- имя файла архива */
   reload           dboolean,
   userkey          dforeignkey,      /* учетная запись, под которой выполнять. если не задана -- выполнять под любой*/
   computer         dtext60,
   atstartup        dboolean,
   exactdate        dtimestamp,       /* дата и время однократного выполнения выполнения. Задача будет выполнена НЕ РАНЬШЕ указанного значения */
   monthly          dinteger,
   weekly           dinteger,
   daily            dboolean,
   starttime        dtime,            /* время начала интервала для выполнения */
   endtime          dtime,            /* время конца интервала для выполнения  */
   priority         dinteger_notnull DEFAULT 0, 
   pulse            dinteger,    
   creatorkey       dforeignkey,
   creationdate     dcreationdate,
   editorkey        dforeignkey,
   editiondate      deditiondate,
   afull            dsecurity,
   achag            dsecurity,
   aview            dsecurity,
   disabled         ddisabled,
   CONSTRAINT gd_pk_autotask PRIMARY KEY(id),
   CONSTRAINT gd_fk_autotask_esk
     FOREIGN KEY (emailsmtpkey) REFERENCES gd_smtp(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_fk
     FOREIGN KEY (functionkey) REFERENCES gd_function(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_atrk
     FOREIGN KEY (autotrkey) REFERENCES ac_transaction(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_rk
     FOREIGN KEY (reportkey) REFERENCES rp_reportlist(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_uk
     FOREIGN KEY (userkey) REFERENCES gd_user(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_ck
     FOREIGN KEY (creatorkey) REFERENCES gd_contact(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_fk_autotask_ek
     FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
     ON UPDATE CASCADE,
   CONSTRAINT gd_chk_autotask_emailrecipients CHECK(emailrecipients > ''),
   CONSTRAINT gd_chk_autotask_recipients CHECK((emailrecipients > '') OR (emailgroupkey IS NOT NULL)),
   CONSTRAINT gd_chk_autotask_monthly CHECK (monthly BETWEEN -31 AND 31 AND monthly <> 0),
   CONSTRAINT gd_chk_autotask_weekly CHECK (weekly BETWEEN 1 AND 7),
   CONSTRAINT gd_chk_autotask_priority CHECK (priority >= 0),
   CONSTRAINT gd_chk_autotask_time CHECK((starttime IS NULL AND endtime IS NULL) OR (starttime < endtime)),
   CONSTRAINT gd_chk_autotask_cmd CHECK(cmdline > ''),
   CONSTRAINT gd_chk_autotask_backupfile CHECK(backupfile > ''),
   CONSTRAINT gd_chk_autotask_pulse CHECK(pulse >= 0),
   CONSTRAINT gd_chk_autotask_exporttype CHECK(emailexporttype IN ('DOC', 'RTF', 'XLS', 'PDF', 'XML', 'TXT', 'HTM', 'ODS', 'ODT'))
 );
 
SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_autotask FOR gd_autotask
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^ 

CREATE OR ALTER TRIGGER gd_biu_autotask FOR gd_autotask
  BEFORE INSERT OR UPDATE
  POSITION 27000
AS
BEGIN
  IF (NOT NEW.atstartup IS NULL) THEN
  BEGIN
    NEW.exactdate = NULL;
    NEW.monthly = NULL;
    NEW.weekly = NULL;
    NEW.daily = NULL;
  END

  IF (NOT NEW.exactdate IS NULL) THEN
  BEGIN
    NEW.atstartup = NULL;
    NEW.monthly = NULL;
    NEW.weekly = NULL;
    NEW.daily = NULL;
  END

  IF (NOT NEW.monthly IS NULL) THEN
  BEGIN
    NEW.atstartup = NULL;
    NEW.exactdate = NULL;
    NEW.weekly = NULL;
    NEW.daily = NULL;
  END

  IF (NOT NEW.weekly IS NULL) THEN
  BEGIN
    NEW.atstartup = NULL;
    NEW.exactdate = NULL;
    NEW.monthly = NULL;
    NEW.daily = NULL;
  END

  IF (NOT NEW.daily IS NULL) THEN
  BEGIN
    NEW.atstartup = NULL;
    NEW.exactdate = NULL;
    NEW.monthly = NULL;
    NEW.weekly = NULL;
  END

  IF (NEW.reload <> 0) THEN
  BEGIN
    NEW.functionkey = NULL;
    NEW.autotrkey = NULL;
    NEW.reportkey = NULL;
    NEW.cmdline = NULL;
    NEW.backupfile = NULL;
    NEW.emailgroupkey = NULL;
    NEW.emailrecipients = NULL;
    NEW.emailsmtpkey = NULL;
    NEW.emailexporttype = NULL;
  END
  
  IF (NOT NEW.functionkey IS NULL) THEN
  BEGIN
    NEW.autotrkey = NULL;
    NEW.reportkey = NULL;
    NEW.cmdline = NULL;
    NEW.backupfile = NULL;
    NEW.reload = 0; 
    NEW.emailgroupkey = NULL;
    NEW.emailrecipients = NULL;
    NEW.emailsmtpkey = NULL;
    NEW.emailexporttype = NULL;
  END

  IF (NOT NEW.autotrkey IS NULL) THEN
  BEGIN
    NEW.functionkey = NULL;
    NEW.reportkey = NULL;
    NEW.cmdline = NULL;
    NEW.backupfile = NULL;
    NEW.reload = 0; 
    NEW.emailgroupkey = NULL;
    NEW.emailrecipients = NULL;
    NEW.emailsmtpkey = NULL;
    NEW.emailexporttype = NULL;
  END

  IF (NOT NEW.reportkey IS NULL) THEN
  BEGIN
    NEW.functionkey = NULL;
    NEW.autotrkey = NULL;
    NEW.cmdline = NULL;
    NEW.backupfile = NULL;
    NEW.reload = 0; 
  END

  IF (NOT NEW.cmdline IS NULL) THEN
  BEGIN
    NEW.functionkey = NULL;
    NEW.autotrkey = NULL;
    NEW.reportkey = NULL;
    NEW.backupfile = NULL;
    NEW.reload = 0; 
    NEW.emailgroupkey = NULL;
    NEW.emailrecipients = NULL;
    NEW.emailsmtpkey = NULL;
    NEW.emailexporttype = NULL;
  END

  IF (NOT NEW.backupfile IS NULL) THEN
  BEGIN
    NEW.functionkey = NULL;
    NEW.autotrkey = NULL;
    NEW.reportkey = NULL;
    NEW.reload = 0; 
    NEW.cmdline = NULL;
    NEW.emailgroupkey = NULL;
    NEW.emailrecipients = NULL;
    NEW.emailsmtpkey = NULL;
    NEW.emailexporttype = NULL;
  END
END
^ 

SET TERM ; ^
 
CREATE TABLE gd_autotask_log
(
  id               dintkey,
  autotaskkey      dintkey,
  eventtext        dtext255 NOT NULL,   
  connection_id    dinteger DEFAULT CURRENT_CONNECTION, 
  client_address   dtext60,  
  creatorkey       dforeignkey,
  creationdate     dcreationdate,
  CONSTRAINT gd_pk_autotask_log PRIMARY KEY (id),
  CONSTRAINT gd_fk_autotask_log_autotaskkey
    FOREIGN KEY (autotaskkey) REFERENCES gd_autotask (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT gd_fk_autotask_log_ck
    FOREIGN KEY (creatorkey) REFERENCES gd_contact (id)
    ON UPDATE CASCADE
 );
 
CREATE INDEX gd_x_autotask_log_cnid ON gd_autotask_log (connection_id);
CREATE DESC INDEX gd_x_autotask_log_cd ON gd_autotask_log (creationdate);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_autotask_log FOR gd_autotask_log
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
    
  IF (NEW.client_address IS NULL) THEN
    NEW.client_address = RDB$GET_CONTEXT('SYSTEM', 'CLIENT_ADDRESS');  
END
^ 

SET TERM ; ^
 
COMMIT;
/*******************************/
/** Begin LB-RB Tree Metadata **/
/*******************************/

SET TERM ^ ;

CREATE PROCEDURE AC_p_el_ACCOUNT (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM AC_ACCOUNT
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM AC_ACCOUNT WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE AC_ACCOUNT SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE AC_ACCOUNT SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE AC_ACCOUNT SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE AC_ACCOUNT SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE AC_p_gchc_ACCOUNT (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM AC_ACCOUNT
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE AC_p_gchc_ACCOUNT (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE AC_ACCOUNT SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE AC_p_restruct_ACCOUNT
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM AC_ACCOUNT
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE AC_p_gchc_ACCOUNT (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER AC_bi_ACCOUNT10 FOR AC_ACCOUNT
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM AC_ACCOUNT WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE AC_p_el_ACCOUNT (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER AC_bu_ACCOUNT10 FOR AC_ACCOUNT
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM AC_ACCOUNT
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table AC_ACCOUNT.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM AC_ACCOUNT WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE AC_ACCOUNT SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE AC_p_el_ACCOUNT (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX AC_x_ACCOUNT_lb
  ON AC_ACCOUNT (lb)
^

CREATE DESC INDEX AC_x_ACCOUNT_rb
  ON AC_ACCOUNT (rb)
^

ALTER TABLE AC_ACCOUNT ADD CONSTRAINT AC_chk_ACCOUNT_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE AC_p_el_ACCOUNT TO administrator
^

GRANT EXECUTE ON PROCEDURE AC_p_gchc_ACCOUNT TO administrator
^

GRANT EXECUTE ON PROCEDURE AC_p_restruct_ACCOUNT TO administrator
^

CREATE PROCEDURE AC_p_el_TRANSACTION (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM AC_TRANSACTION
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM AC_TRANSACTION WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE AC_TRANSACTION SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE AC_TRANSACTION SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE AC_TRANSACTION SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE AC_TRANSACTION SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE AC_p_gchc_TRANSACTION (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM AC_TRANSACTION
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE AC_p_gchc_TRANSACTION (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE AC_TRANSACTION SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE AC_p_restruct_TRANSACTION
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM AC_TRANSACTION
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE AC_p_gchc_TRANSACTION (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER AC_bi_TRANSACTION10 FOR AC_TRANSACTION
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM AC_TRANSACTION WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE AC_p_el_TRANSACTION (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER AC_bu_TRANSACTION10 FOR AC_TRANSACTION
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM AC_TRANSACTION
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table AC_TRANSACTION.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM AC_TRANSACTION WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE AC_TRANSACTION SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE AC_p_el_TRANSACTION (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX AC_x_TRANSACTION_lb
  ON AC_TRANSACTION (lb)
^

CREATE DESC INDEX AC_x_TRANSACTION_rb
  ON AC_TRANSACTION (rb)
^

ALTER TABLE AC_TRANSACTION ADD CONSTRAINT AC_chk_TRANSACTION_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE AC_p_el_TRANSACTION TO administrator
^

GRANT EXECUTE ON PROCEDURE AC_p_gchc_TRANSACTION TO administrator
^

GRANT EXECUTE ON PROCEDURE AC_p_restruct_TRANSACTION TO administrator
^

CREATE PROCEDURE EVT_p_el_MACROSGROUP (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM EVT_MACROSGROUP
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM EVT_MACROSGROUP WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE EVT_MACROSGROUP SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE EVT_MACROSGROUP SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE EVT_MACROSGROUP SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE EVT_MACROSGROUP SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE EVT_p_gchc_MACROSGROUP (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM EVT_MACROSGROUP
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE EVT_p_gchc_MACROSGROUP (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE EVT_MACROSGROUP SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE EVT_p_restruct_MACROSGROUP
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM EVT_MACROSGROUP
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE EVT_p_gchc_MACROSGROUP (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER EVT_bi_MACROSGROUP10 FOR EVT_MACROSGROUP
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM EVT_MACROSGROUP WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE EVT_p_el_MACROSGROUP (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER EVT_bu_MACROSGROUP10 FOR EVT_MACROSGROUP
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM EVT_MACROSGROUP
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table EVT_MACROSGROUP.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM EVT_MACROSGROUP WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE EVT_MACROSGROUP SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE EVT_p_el_MACROSGROUP (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX EVT_x_MACROSGROUP_lb
  ON EVT_MACROSGROUP (lb)
^

CREATE DESC INDEX EVT_x_MACROSGROUP_rb
  ON EVT_MACROSGROUP (rb)
^

ALTER TABLE EVT_MACROSGROUP ADD CONSTRAINT EVT_chk_MACROSGROUP_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE EVT_p_el_MACROSGROUP TO administrator
^

GRANT EXECUTE ON PROCEDURE EVT_p_gchc_MACROSGROUP TO administrator
^

GRANT EXECUTE ON PROCEDURE EVT_p_restruct_MACROSGROUP TO administrator
^

CREATE PROCEDURE EVT_p_el_OBJECT (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM EVT_OBJECT
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM EVT_OBJECT WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE EVT_OBJECT SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE EVT_OBJECT SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE EVT_OBJECT SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE EVT_OBJECT SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE EVT_p_gchc_OBJECT (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM EVT_OBJECT
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE EVT_p_gchc_OBJECT (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE EVT_OBJECT SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE EVT_p_restruct_OBJECT
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM EVT_OBJECT
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE EVT_p_gchc_OBJECT (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER EVT_bi_OBJECT10 FOR EVT_OBJECT
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM EVT_OBJECT WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE EVT_p_el_OBJECT (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER EVT_bu_OBJECT10 FOR EVT_OBJECT
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM EVT_OBJECT
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table EVT_OBJECT.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM EVT_OBJECT WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE EVT_OBJECT SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE EVT_p_el_OBJECT (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX EVT_x_OBJECT_lb
  ON EVT_OBJECT (lb)
^

CREATE DESC INDEX EVT_x_OBJECT_rb
  ON EVT_OBJECT (rb)
^

ALTER TABLE EVT_OBJECT ADD CONSTRAINT EVT_chk_OBJECT_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE EVT_p_el_OBJECT TO administrator
^

GRANT EXECUTE ON PROCEDURE EVT_p_gchc_OBJECT TO administrator
^

GRANT EXECUTE ON PROCEDURE EVT_p_restruct_OBJECT TO administrator
^

CREATE PROCEDURE GD_p_el_CONTACT (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM GD_CONTACT
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM GD_CONTACT WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE GD_CONTACT SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE GD_CONTACT SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE GD_CONTACT SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE GD_CONTACT SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE GD_p_gchc_CONTACT (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM GD_CONTACT
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE GD_p_gchc_CONTACT (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE GD_CONTACT SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE GD_p_restruct_CONTACT
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM GD_CONTACT
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE GD_p_gchc_CONTACT (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER GD_bi_CONTACT10 FOR GD_CONTACT
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM GD_CONTACT WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE GD_p_el_CONTACT (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER GD_bu_CONTACT10 FOR GD_CONTACT
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM GD_CONTACT
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table GD_CONTACT.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM GD_CONTACT WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE GD_CONTACT SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE GD_p_el_CONTACT (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX GD_x_CONTACT_lb
  ON GD_CONTACT (lb)
^

CREATE DESC INDEX GD_x_CONTACT_rb
  ON GD_CONTACT (rb)
^

ALTER TABLE GD_CONTACT ADD CONSTRAINT GD_chk_CONTACT_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE GD_p_el_CONTACT TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_gchc_CONTACT TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_restruct_CONTACT TO administrator
^

CREATE PROCEDURE GD_p_el_DOCUMENTTYPE (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM GD_DOCUMENTTYPE
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM GD_DOCUMENTTYPE WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE GD_DOCUMENTTYPE SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE GD_DOCUMENTTYPE SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE GD_DOCUMENTTYPE SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE GD_DOCUMENTTYPE SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE GD_p_gchc_DOCUMENTTYPE (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM GD_DOCUMENTTYPE
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE GD_p_gchc_DOCUMENTTYPE (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE GD_DOCUMENTTYPE SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE GD_p_restruct_DOCUMENTTYPE
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM GD_DOCUMENTTYPE
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE GD_p_gchc_DOCUMENTTYPE (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER GD_bi_DOCUMENTTYPE10 FOR GD_DOCUMENTTYPE
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM GD_DOCUMENTTYPE WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE GD_p_el_DOCUMENTTYPE (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER GD_bu_DOCUMENTTYPE10 FOR GD_DOCUMENTTYPE
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM GD_DOCUMENTTYPE
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table GD_DOCUMENTTYPE.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM GD_DOCUMENTTYPE WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE GD_DOCUMENTTYPE SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE GD_p_el_DOCUMENTTYPE (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX GD_x_DOCUMENTTYPE_lb
  ON GD_DOCUMENTTYPE (lb)
^

CREATE DESC INDEX GD_x_DOCUMENTTYPE_rb
  ON GD_DOCUMENTTYPE (rb)
^

ALTER TABLE GD_DOCUMENTTYPE ADD CONSTRAINT GD_chk_DOCUMENTTYPE_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE GD_p_el_DOCUMENTTYPE TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_gchc_DOCUMENTTYPE TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_restruct_DOCUMENTTYPE TO administrator
^

CREATE PROCEDURE GD_p_el_FILE (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM GD_FILE
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM GD_FILE WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE GD_FILE SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE GD_FILE SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE GD_FILE SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE GD_FILE SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE GD_p_gchc_FILE (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM GD_FILE
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE GD_p_gchc_FILE (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE GD_FILE SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE GD_p_restruct_FILE
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM GD_FILE
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE GD_p_gchc_FILE (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER GD_bi_FILE10 FOR GD_FILE
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM GD_FILE WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE GD_p_el_FILE (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER GD_bu_FILE10 FOR GD_FILE
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM GD_FILE
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table GD_FILE.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM GD_FILE WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE GD_FILE SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE GD_p_el_FILE (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX GD_x_FILE_lb
  ON GD_FILE (lb)
^

CREATE DESC INDEX GD_x_FILE_rb
  ON GD_FILE (rb)
^

ALTER TABLE GD_FILE ADD CONSTRAINT GD_chk_FILE_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE GD_p_el_FILE TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_gchc_FILE TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_restruct_FILE TO administrator
^

CREATE PROCEDURE GD_p_el_GOODGROUP (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM GD_GOODGROUP
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM GD_GOODGROUP WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE GD_GOODGROUP SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE GD_GOODGROUP SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE GD_GOODGROUP SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE GD_GOODGROUP SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE GD_p_gchc_GOODGROUP (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM GD_GOODGROUP
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE GD_p_gchc_GOODGROUP (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE GD_GOODGROUP SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE GD_p_restruct_GOODGROUP
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM GD_GOODGROUP
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE GD_p_gchc_GOODGROUP (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER GD_bi_GOODGROUP10 FOR GD_GOODGROUP
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM GD_GOODGROUP WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE GD_p_el_GOODGROUP (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER GD_bu_GOODGROUP10 FOR GD_GOODGROUP
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM GD_GOODGROUP
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table GD_GOODGROUP.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM GD_GOODGROUP WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE GD_GOODGROUP SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE GD_p_el_GOODGROUP (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX GD_x_GOODGROUP_lb
  ON GD_GOODGROUP (lb)
^

CREATE DESC INDEX GD_x_GOODGROUP_rb
  ON GD_GOODGROUP (rb)
^

ALTER TABLE GD_GOODGROUP ADD CONSTRAINT GD_chk_GOODGROUP_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE GD_p_el_GOODGROUP TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_gchc_GOODGROUP TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_restruct_GOODGROUP TO administrator
^

CREATE PROCEDURE GD_p_el_PLACE (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM GD_PLACE
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM GD_PLACE WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE GD_PLACE SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE GD_PLACE SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE GD_PLACE SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE GD_PLACE SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE GD_p_gchc_PLACE (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM GD_PLACE
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE GD_p_gchc_PLACE (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE GD_PLACE SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE GD_p_restruct_PLACE
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM GD_PLACE
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE GD_p_gchc_PLACE (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER GD_bi_PLACE10 FOR GD_PLACE
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM GD_PLACE WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE GD_p_el_PLACE (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER GD_bu_PLACE10 FOR GD_PLACE
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM GD_PLACE
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table GD_PLACE.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM GD_PLACE WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE GD_PLACE SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE GD_p_el_PLACE (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX GD_x_PLACE_lb
  ON GD_PLACE (lb)
^

CREATE DESC INDEX GD_x_PLACE_rb
  ON GD_PLACE (rb)
^

ALTER TABLE GD_PLACE ADD CONSTRAINT GD_chk_PLACE_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE GD_p_el_PLACE TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_gchc_PLACE TO administrator
^

GRANT EXECUTE ON PROCEDURE GD_p_restruct_PLACE TO administrator
^

CREATE PROCEDURE MSG_p_el_BOX (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM MSG_BOX
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM MSG_BOX WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE MSG_BOX SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE MSG_BOX SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE MSG_BOX SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE MSG_BOX SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE MSG_p_gchc_BOX (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM MSG_BOX
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE MSG_p_gchc_BOX (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE MSG_BOX SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE MSG_p_restruct_BOX
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM MSG_BOX
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE MSG_p_gchc_BOX (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER MSG_bi_BOX10 FOR MSG_BOX
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM MSG_BOX WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE MSG_p_el_BOX (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER MSG_bu_BOX10 FOR MSG_BOX
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM MSG_BOX
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table MSG_BOX.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM MSG_BOX WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE MSG_BOX SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE MSG_p_el_BOX (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX MSG_x_BOX_lb
  ON MSG_BOX (lb)
^

CREATE DESC INDEX MSG_x_BOX_rb
  ON MSG_BOX (rb)
^

ALTER TABLE MSG_BOX ADD CONSTRAINT MSG_chk_BOX_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE MSG_p_el_BOX TO administrator
^

GRANT EXECUTE ON PROCEDURE MSG_p_gchc_BOX TO administrator
^

GRANT EXECUTE ON PROCEDURE MSG_p_restruct_BOX TO administrator
^

CREATE PROCEDURE RP_p_el_REPORTGROUP (Parent INTEGER, LB2 INTEGER, RB2 INTEGER)
  RETURNS (LeftBorder INTEGER, RightBorder INTEGER)
AS
  DECLARE VARIABLE R     INTEGER = NULL;
  DECLARE VARIABLE L     INTEGER = NULL;
  DECLARE VARIABLE Prev  INTEGER;
  DECLARE VARIABLE LChld INTEGER = NULL;
  DECLARE VARIABLE RChld INTEGER = NULL;
  DECLARE VARIABLE Delta INTEGER;
  DECLARE VARIABLE Dist  INTEGER;
  DECLARE VARIABLE Diff  INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (:LB2 = -1 AND :RB2 = -1) THEN
    Delta = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
  ELSE
    Delta = :RB2 - :LB2;

  SELECT lb, rb
  FROM RP_REPORTGROUP
  WHERE id = :Parent
  INTO :L, :R;

  IF (:L IS NULL) THEN
    EXCEPTION tree_e_invalid_parent 'Invalid parent specified.';

  Prev = :L + 1;
  LeftBorder = NULL;

  FOR SELECT lb, rb FROM RP_REPORTGROUP WHERE parent = :Parent ORDER BY lb ASC INTO :LChld, :RChld
  DO BEGIN
    IF ((:LChld - :Prev) > :Delta) THEN 
    BEGIN
      LeftBorder = :Prev;
      LEAVE;
    END ELSE
      Prev = :RChld + 1;
  END

  LeftBorder = COALESCE(:LeftBorder, :Prev);
  RightBorder = :LeftBorder + :Delta;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
     RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  IF (:RightBorder >= :R) THEN
  BEGIN
    Diff = :R - :L;
    IF (:RightBorder >= (:R + :Diff)) THEN
      Diff = :RightBorder - :R + 1;

    IF (:Delta < 1000) THEN
      Diff = :Diff + :Delta * 10;
    ELSE
      Diff = :Diff + 10000;

    /* Сдвигаем все интервалы справа */
    UPDATE RP_REPORTGROUP SET lb = lb + :Diff, rb = rb + :Diff
      WHERE lb > :R;

    /* Расширяем родительские интервалы */
    UPDATE RP_REPORTGROUP SET rb = rb + :Diff
      WHERE lb <= :L AND rb >= :R;

    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      IF (:LB2 > :R) THEN
      BEGIN
        LB2 = :LB2 + :Diff;
        RB2 = :RB2 + :Diff;
      END
      Dist = :LeftBorder - :LB2;
      UPDATE RP_REPORTGROUP SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END ELSE
  BEGIN
    IF (:LB2 <> -1 AND :RB2 <> -1) THEN
    BEGIN
      Dist = :LeftBorder - :LB2;
      UPDATE RP_REPORTGROUP SET lb = lb + :Dist, rb = rb + :Dist 
        WHERE lb > :LB2 AND rb <= :RB2;
    END
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE PROCEDURE RP_p_gchc_REPORTGROUP (Parent INTEGER, FirstIndex INTEGER)
  RETURNS (LastIndex INTEGER)
AS
  DECLARE VARIABLE ChildKey INTEGER;
BEGIN
  LastIndex = :FirstIndex + 1;

  /* Изменяем границы детей */
  FOR
    SELECT id
    FROM RP_REPORTGROUP
    WHERE parent = :Parent
    INTO :ChildKey
  DO
  BEGIN
    EXECUTE PROCEDURE RP_p_gchc_REPORTGROUP (:ChildKey, :LastIndex)
      RETURNING_VALUES :LastIndex;
  END

  LastIndex = :LastIndex + CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER) - 1;

  /* Изменяем границы родителя */
  UPDATE RP_REPORTGROUP SET lb = :FirstIndex + 1, rb = :LastIndex
    WHERE id = :Parent;
END
^

CREATE PROCEDURE RP_p_restruct_REPORTGROUP
AS
  DECLARE VARIABLE CurrentIndex INTEGER;
  DECLARE VARIABLE ChildKey INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  CurrentIndex = 1;

  WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);

  /* Для всех корневых элементов ... */
  FOR
    SELECT id
    FROM RP_REPORTGROUP
    WHERE parent IS NULL
    INTO :ChildKey
  DO
  BEGIN
    /* ... меняем границы детей */
    EXECUTE PROCEDURE RP_p_gchc_REPORTGROUP (:ChildKey, :CurrentIndex)
      RETURNING_VALUES :CurrentIndex;
  END

  IF (:WasUnlock IS NULL) THEN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
END
^

CREATE TRIGGER RP_bi_REPORTGROUP10 FOR RP_REPORTGROUP
  BEFORE INSERT
  POSITION 32000
AS
  DECLARE VARIABLE D    INTEGER;
  DECLARE VARIABLE L    INTEGER;
  DECLARE VARIABLE R    INTEGER;
  DECLARE VARIABLE Prev INTEGER;
BEGIN
  IF (NEW.parent IS NULL) THEN
  BEGIN
    D = CAST(COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_DELTA'), '10') AS INTEGER);
    Prev = 1;
    NEW.lb = NULL;

    FOR SELECT lb, rb FROM RP_REPORTGROUP WHERE parent IS NULL ORDER BY lb INTO :L, :R
    DO BEGIN
      IF ((:L - :Prev) > :D) THEN 
      BEGIN
        NEW.lb = :Prev;
        LEAVE;
      END ELSE
        Prev = :R + 1;
    END

    NEW.lb = COALESCE(NEW.lb, :Prev);
    NEW.rb = NEW.lb + :D;
  END ELSE
  BEGIN
    EXECUTE PROCEDURE RP_p_el_REPORTGROUP (NEW.parent, -1, -1)
      RETURNING_VALUES NEW.lb, NEW.rb;
  END
END
^

CREATE TRIGGER RP_bu_REPORTGROUP10 FOR RP_REPORTGROUP
  BEFORE UPDATE
  POSITION 32000
AS
  DECLARE VARIABLE OldDelta  INTEGER;
  DECLARE VARIABLE D         INTEGER;
  DECLARE VARIABLE L         INTEGER;
  DECLARE VARIABLE R         INTEGER;
  DECLARE VARIABLE Prev      INTEGER;
  DECLARE VARIABLE WasUnlock INTEGER;
BEGIN
  IF (NEW.parent IS DISTINCT FROM OLD.parent) THEN
  BEGIN
    /* Делаем проверку на зацикливание */
    IF (EXISTS (SELECT * FROM RP_REPORTGROUP
          WHERE id = NEW.parent AND lb >= OLD.lb AND rb <= OLD.rb)) THEN
      EXCEPTION tree_e_invalid_parent 'Attempt to cycle branch in table RP_REPORTGROUP.';

    IF (NEW.parent IS NULL) THEN
    BEGIN
      D = OLD.rb - OLD.lb;
      Prev = 1;
      NEW.lb = NULL;

      FOR SELECT lb, rb FROM RP_REPORTGROUP WHERE parent IS NULL ORDER BY lb ASC INTO :L, :R
      DO BEGIN
        IF ((:L - :Prev) > :D) THEN 
        BEGIN
          NEW.lb = :Prev;
          LEAVE;
        END ELSE
          Prev = :R + 1;
      END

      NEW.lb = COALESCE(NEW.lb, :Prev);
      NEW.rb = NEW.lb + :D;

      /* Определяем величину сдвига */
      OldDelta = NEW.lb - OLD.lb;
      /* Сдвигаем границы детей */
      WasUnlock = RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK');
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', 1);
      UPDATE RP_REPORTGROUP SET lb = lb + :OldDelta, rb = rb + :OldDelta
        WHERE lb > OLD.lb AND rb <= OLD.rb;
      IF (:WasUnlock IS NULL) THEN
        RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    END ELSE
      EXECUTE PROCEDURE RP_p_el_REPORTGROUP (NEW.parent, OLD.lb, OLD.rb)
        RETURNING_VALUES NEW.lb, NEW.rb;
  END ELSE
  BEGIN
    IF ((NEW.rb <> OLD.rb) OR (NEW.lb <> OLD.lb)) THEN
    BEGIN
      IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK') IS NULL) THEN
      BEGIN
        NEW.lb = OLD.lb;
        NEW.rb = OLD.rb;
      END
    END
  END

  WHEN ANY DO
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'LBRB_UNLOCK', NULL);
    EXCEPTION;
  END
END
^

CREATE ASC INDEX RP_x_REPORTGROUP_lb
  ON RP_REPORTGROUP (lb)
^

CREATE DESC INDEX RP_x_REPORTGROUP_rb
  ON RP_REPORTGROUP (rb)
^

ALTER TABLE RP_REPORTGROUP ADD CONSTRAINT RP_chk_REPORTGROUP_tr_lmt
  CHECK (lb <= rb)
^

GRANT EXECUTE ON PROCEDURE RP_p_el_REPORTGROUP TO administrator
^

GRANT EXECUTE ON PROCEDURE RP_p_gchc_REPORTGROUP TO administrator
^

GRANT EXECUTE ON PROCEDURE RP_p_restruct_REPORTGROUP TO administrator
^


SET TERM ; ^

/*******************************/
/** End LB-RB Tree Metadata   **/
/*******************************/


/*

  Copyright (c) 2000-2015 by Golden Software of Belarus

  Script

    Constants.sql

  Abstract

    An Interbase script with Constants for GEDEMIN system.

  Author

    Nikolai Kornachenko (18.05.00)

  Revisions history

    Initial  18.05.00  NK    Initial version

  Status

    Draft

*/

-- gd_usergroup
-- 1..32

INSERT INTO gd_usergroup (id, name, description)
  VALUES (1, 'Администраторы', 'Системные администраторы');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (2, 'Опытные пользователи', 'Опытные пользователи');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (3, 'Пользователи', 'Обычные пользователи');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (4, 'Операторы архива', 'Операторы архива');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (5, 'Операторы печати', 'Операторы печати');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (6, 'Гости', 'Гости системы');


-- gd_subsystem
-- 99..50000

INSERT INTO gd_subsystem(id, name, description, reserved)
  VALUES (1000, 'Администрирование', 'Администрирование системы', NULL);


-- GD_USER
-- 150001..200000

INSERT INTO gd_contact(id, contacttype, name)
    VALUES(650001, 0, 'Контакты');
INSERT INTO gd_contact(id, parent, contacttype, name)
    VALUES(650002, 650001, 2, 'Администратор');
INSERT INTO gd_people(contactkey, surname) VALUES(650002, 'Администратор');

INSERT INTO gd_user (id, name, passw, ingroup, fullname, description, ibname,
                      ibpassword, externalkey, lockedout, mustchange,
                      cantchangepassw, passwneverexp, expdate, workstart,
                      workend, icon, reserved, contactkey)
VALUES (150001, 'Administrator', 'Administrator', -1, 'Администратор', 'Администратор системы',
          'SYSDBA', 'masterkey', NULL, 0, 0, 0, 1, NULL, NULL, NULL, NULL, NULL, 650002);


-- gd_curr
-- 200001..250000

INSERT INTO gd_curr
  (id, disabled, isNCU, code, name, shortname, sign, place, decdigits,
     fullcentname, shortcentname, centbase, icon, reserved, name_0, name_1, centname_0, centname_1)
  VALUES (200010, 0, 1, 'BYR', 'Белорусский рубль', 'BYR', 'Br',
     1, 0, '', '', 1, NULL, NULL, 'белорусских рублей', 'белорусских рубля', '', '');

INSERT INTO gd_curr
  (id, disabled, isNCU, isEq, code, name, shortname, sign, place, decdigits,
     fullcentname, shortcentname, centbase, icon, reserved, name_0, name_1, centname_0, centname_1)
  VALUES (200020, 0, 0, 1, 'USD', 'Доллар США', 'USD', '$',
     0, 2, 'цент', 'ц.', 1, NULL, NULL, 'долларов США', 'доллара США', 'центов', 'цента');

INSERT INTO gd_curr
  (id, disabled, isNCU, code, name, shortname, sign, place, decdigits,
     fullcentname, shortcentname, centbase, icon, reserved, name_0, name_1, centname_0, centname_1)
  VALUES (200040, 0, 0, 'EUR', 'Евро', 'EUR', 'EUR',
     1, 2, 'евроцент', 'ц.', 1, NULL, NULL, 'евро', 'евро', 'евроцентов', 'евроцента');

INSERT INTO gd_curr
  (id, disabled, isNCU, code, name, shortname, sign, place, decdigits,
     fullcentname, shortcentname, centbase, icon, reserved, name_0, name_1, centname_0, centname_1)
  VALUES (200050, 0, 0, 'RUB', 'Российский рубль', 'RUB', 'р.',
     1, 2, 'копейка', 'к.', 1, NULL, NULL, 'российских рублей', 'российских рубля', 'копеек', 'копейки');


-- ac_account
-- 300001..399999

INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300001, NULL, 'План счетов', 'План счетов', 'A', 'C', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (399000, 300001, 'Балансовые счета', 'Балансовые счета', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300002, 300001, 'Забалансовые счета', 'Забалансовые счета', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300003, 300002, 'Остатки', '00', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300010, 399000, 'I. ДОЛГОСРОЧНЫЕ АКТИВЫ', 'I. ДОЛГОСРОЧ. АКТИВЫ', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (310000, 399000, 'II. ПРОИЗВОДСТВЕННЫЕ ЗАПАСЫ', 'II. ПРОИЗВОД. ЗАПАСЫ', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (320000, 399000, 'III. ЗАТРАТЫ НА ПРОИЗВОДСТВО', 'III. ЗАТРАТЫ НА ПРОИЗВОД.', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (340000, 399000, 'IV. ГОТОВАЯ ПРОДУКЦИЯ И ТОВАРЫ', 'IV. ГОТОВАЯ ПРОД. И ТОВАРЫ', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (350000, 399000, 'V. ДЕНЕЖНЫЕ СРЕДСТВА И КРАТКОСРОЧНЫЕ ФИНАНСОВЫЕ ВЛОЖЕНИЯ', 'V. ДЕН. СР-А И КР. ФИН. ВЛОЖ.', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (360000, 399000, 'VI. РАСЧЕТЫ', 'VI. РАСЧЕТЫ', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380000, 399000, 'VII. СОБСТВЕННЫЙ КАПИТАЛ', 'VII. СОБСТВЕННЫЙ КАПИТАЛ', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385000, 399000, 'VIII. ФИНАНСОВЫЕ РЕЗУЛЬТАТЫ', 'VIII. ФИНАНСОВЫЕ РЕЗУЛЬТАТЫ', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300100, 300010, 'Основные средства', '01', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300101, 300100, 'Собственные основные средства', '01.01', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300102, 300100, 'Выбытие основных средств', '01.02', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300200, 300010, 'Амортизация основных средств', '02', 'P', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300201, 300200, 'Амортизация собственных основных средств', '02.01', 'P', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300202, 300200, 'Амортизация основных средств, полученных в лизинг', '02.02', 'P', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300300, 300010, 'Доходные вложения в материальные активы', '03', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300301, 300300, 'Инвестиционная недвижимость', '03.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300302, 300300, 'Предметы финансовой аренды (лизинга)', '03.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300400, 300010, 'Нематериальные активы', '04', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300500, 300010, 'Амортизация нематериальных активов', '05', 'P', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300700, 300010, 'Оборудование к установке и строительные материалы', '07', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300701, 300700, 'Оборудование к установке на складе', '07.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300702, 300700, 'Оборудование к установке, переданное в монтаж', '07.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300800, 300010, 'Вложения в долгосрочные активы', '08', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300801, 300800, 'Приобретение и создание основных средств', '08.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300802, 300800, 'Приобретение и создание инвестиционной недвижимости', '08.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300803, 300800, 'Приобретение предметов финансовой аренды (лизинга)', '08.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300804, 300800, 'Приобретение и создание иных долгосрочных активов', '08.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300805, 300800, 'Затраты, не увеличивающие стоимости основных средств', '08.05', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300806, 300800, 'Приобретение нематериальных активов', '08.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300807, 300800, 'Перевод молодняка эивотных в основное стадо', '08.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300808, 300800, 'Приобретение взрослых животных', '08.08', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300809, 300800, 'Выполнение научно-исследовательских, опытно-конструкторских и технологических работ', '08.09', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311000, 310000, 'Материалы', '10', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311001, 311000, 'Сырье и материалы', '10.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311002, 311000, 'Покупные полуфабрикаты и комплектующие изделия', '10.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311003, 311000, 'Топливо', '10.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311004, 311000, 'Тара и тарные материалы', '10.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311005, 311000, 'Запасные части', '10.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311006, 311000, 'Прочие материалы', '10.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311007, 311000, 'Материалы, переданные в переработку на сторону', '10.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311008, 311000, 'Временные сооружения', '10.08', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311009, 311000, 'Инвентарь и хозяйственные принадлежности, инструменты', '10.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311100, 310000, 'Животные на выращивании и откорме', '11', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311010, 311000, 'Специальная оснастка и специальная одежда на складе', '10.10', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311011, 311000, 'Специальная оснастка и специальная одежда в эксплуатации', '10.11', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311400, 310000, 'Резервы под снижение стоимости запасов', '14', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311500, 310000, 'Заготовление и приобретение материалов', '15', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311600, 310000, 'Отклонение в стоимости материалов', '16', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393001, 300002, 'Аредованные основные средства', '001', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311900, 310000, 'Налог на добавленную стоимость по приобретенным товарам, работам, услугам', '18', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311901, 311900, 'НДС по приобретенным ОС', '18.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311902, 311900, 'НДС по приобретенным нематериальным активам', '18.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393002, 300002, 'Имущество, принятое на ответственное хранение', '002', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393003, 300002, 'Материалы, принятые в переработку', '003', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393004, 300002, 'Товары, принятые на комиссию', '004', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322000, 320000, 'Основное производство', '20', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322100, 320000, 'Полуфабрикаты собственного производства', '21', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322300, 320000, 'Вспомогательные производства', '23', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322500, 320000, 'Общепроизводственные расходы', '25', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322600, 320000, 'Общехозяйственные расходы', '26', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322800, 320000, 'Брак в производстве', '28', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322900, 320000, 'Обслуживающие производства и хозяйства', '29', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (323100, 385000, 'Расходы будущих периодов', '97', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393005, 300002, 'Оборудование, принятое для монтажа', '005', 'A', 'A', 0, 1, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344000, 340000, 'Выпуск продукции работ, услуг', '40', 'A', 'A', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344100, 340000, 'Товары', '41', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344101, 344100, 'Товары на складах', '41.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344102, 344100, 'Товары в розничной торговле', '41.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344103, 344100, 'Тара под товаром и порожняя', '41.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344104, 344100, 'Покупные изделия', '41.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344200, 340000, 'Торговая наценка', '42', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344201, 344200, 'Торговая наценка (скидка, накидка)', '42.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344202, 344200, 'Скидка поставщиков', '42.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344300, 340000, 'Готовая продукция', '43', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344400, 340000, 'Расходы на реализацию', '44', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344500, 340000, 'Товары отгруженные', '45', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344501, 344500, 'Товары отгруженные в учетных ценах', '45.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344502, 344500, 'Товары отгруженные в отпускных ценах', '45.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344600, 385000, 'Доходы и расходы по текущей деятельности', '90', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344700, 385000, 'Прочие доходы и расходы', '91', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355000, 350000, 'Касса', '50', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355100, 350000, 'Расчетные счета', '51', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355200, 350000, 'Валютные счета', '52', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355201, 355200, 'Внутри страны', '52.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355202, 355200, 'За рубежем', '52.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355500, 350000, 'Специальные счета в банках', '55', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355501, 355500, 'Депозитные счета', '55.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355502, 355500, 'Счета в драгоценных металлах', '55.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355700, 350000, 'Денежные средства в пути', '57', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355800, 350000, 'Краткосрочные финансовые вложения', '58', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355801, 355800, 'Краткосрочные финансовые вложения в ценные бумаги', '58.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355802, 355800, 'Предоставленные краткосрочные займы', '58.02', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355803, 355800, 'Предоставленные займы', '58.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355804, 355800, 'Прочее', '58.04', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366000, 360000, 'Расчеты с поставщиками и подрядчиками', '60', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366200, 360000, 'Расчеты с покупателями и заказчиками', '62', 'A', 'A', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366201, 366200, 'Расчеты в порядке инкассо', '62.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366202, 366200, 'Расчеты плановыми платежами', '62.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366203, 366200, 'Векселя полученные', '62.03', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366800, 360000, 'Расчеты с бюджетом', '68', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366900, 360000, 'Расчеты по социальному страхованию и обеспечению', '69', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366901, 366900, 'Расчеты по соц. страхованию', '69.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366902, 366900, 'Расчеты по пенсионному обеспечению', '69.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367000, 360000, 'Расчеты с персоналом по оплате труда', '70', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393006, 300002, 'Бланки строгой отчетности', '006', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367100, 360000, 'Расчеты с подотчетными лицами', '71', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367300, 360000, 'Расчеты с персоналом по прочим операциям', '73', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367301, 367300, 'Расчеты по предоставленным займам', '73.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367302, 367300, 'Расчеты по возмещению ущерба', '73.02', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367303, 367300, 'Расчеты по возмещ. мат. ущерба', '73.03', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367500, 360000, 'Расчеты с учредителями', '75', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367501, 367500, 'Расчеты по вкладам в уставный капитал', '75.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367502, 367500, 'Расчеты по выплате дивидендов и других доходов', '75.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367600, 360000, 'Расчеты с разными дебиторами и кредиторами', '76', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367900, 360000, 'Внутрихозяйственные расчеты', '79', 'A', 'A', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367901, 367900, 'По выделенному имущетву', '79.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367902, 367900, 'По текущим операциям', '79.02', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380001, 385000, 'Прибыли и убытки', '99', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380002, 380000, 'Собственные акции (доли в уставном капитале)', '81', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380004, 360000, 'Резервы по сомнительным долгам', '63', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380005, 385000, 'Доходы будущих периодов', '98', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380006, 385000, 'Недостачи и потери от порчи имущества', '94', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385001, 380000, 'Уставный капитал', '80', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385002, 380000, 'Резервный капитал', '82', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385012, 380000, 'Добавочный капитал', '83', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385003, 380000, 'Нераспределенная прибыль (непокрытый убыток)', '84', 'A', 'A', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385004, 385000, 'Внереализационные доходы и расходы', '92', 'A', 'A', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385005, 385000, 'Резервы предстоящих платежей', '96', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (390001, 360000, 'Расчеты по краткосрочным кредитам и займам', '66', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (390007, 360000, 'Расчеты по долгосрочным кредитам и займам', '67', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (390005, 380000, 'Целевое финансирование', '86', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322001, 322000, 'Промышленное производство', '20.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322002, 322000, 'Сельскохозяйственное производство', '20.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322003, 322000, 'Эксплуатация транспорта и средств связи', '20.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322004, 322000, 'Производство строительных и монтажных работ', '20.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322005, 322000, 'Производство проектных и изыскательных работ', '20.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322006, 322000, 'Производство геологоразведочных работ', '20.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322007, 322000, 'Производство научно технических и конструкторских работ', '20.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322008, 322000, 'Содержание и ремонт автомобильных дорог', '20.08', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322009, 322000, 'Общественное питание', '20.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322301, 322300, 'Обслуживание различными видами энергии', '23.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322302, 322300, 'Внутризаводское транспортное обслуживание', '23.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322303, 322300, 'Ремонт основных средств', '23.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322304, 322300, 'Изготовление инструментов, штампов, запасных частей, строительных деталей и конструкций', '23.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322305, 322300, 'Эксплуатация мелких транспортных хозяйств', '23.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322306, 322300, 'Возведение временных (нетитульных) сооружений', '23.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322307, 322300, 'Добыча нерудных материалов', '23.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322308, 322300, 'Лесозаготовки и лесопиление', '23.08', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322309, 322300, 'Переработка сельскохозяйственной продукции', '23.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322901, 322900, 'Жилищно-коммунальные хозяйства', '29.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322902, 322900, 'Подсобные сельские хозяйства', '29.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322903, 322900, 'Бытовое обслуживание', '29.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322904, 322900, 'Содержание детских дошкольных учреждений', '29.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322905, 322900, 'Содержание домов отдыха, санаториев и других учреждений оздоровительного назначения', '29.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322906, 322900, 'Содержание учреждений культуры', '29.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322907, 322900, 'Содержание подразделений общественного питания', '29.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344203, 344200, 'Налог на добавленную стоимость в цене товаров', '42.03', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344204, 344200, 'Налог с продаж', '42.04', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344401, 344400, 'Коммерческие расходы', '44.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344402, 344400, 'Издержки обращения', '44.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355001, 355000, 'Касса организации', '50.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355002, 355000, 'Операционная касса', '50.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355003, 355000, 'Денежные документы', '50.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355004, 355000, 'Валютная касса', '50.04', 'A', 'S', 1, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355005, 355000, 'Касса филиалов', '50.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355503, 355500, 'Специальный счет денежных средств целевого назначения', '55.03', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355504, 355500, 'Депозитные счета в иностранной валюте', '55.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355505, 355500, 'Специальный счет целевого финансирования', '55.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355506, 355500, 'Текущий счет филиала', '55.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355507, 355500, 'Банковские карты', '55.07', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355701, 355700, 'Инкассированные денежные средства', '57.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355702, 355700, 'Денежные средства для приобретения иностранной валюты', '57.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355703, 355700, 'Денежные средства в иностранных валютах для реализации', '57.03', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355704, 355700, 'Переводы в пути по банковским картам', '57.04', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (392000, 350000, 'Резервы под обесценение краткосрочных финансовых вложений', '59', 'A', 'A', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366204, 366200, 'Авансы полученные', '62.04', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366801, 366800, 'Расчеты по налогам и сборам, относимым на затраты по производству и реализации продукции, товаров, работ, услуг', '68.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366802, 366800, 'Расчеты по налогам и сборам, исчисляемым из выручки от реализации продукции, товаров, работ, услуг', '68.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366803, 366800, 'Расчеты по налогам и сборам, исчисляемым из прибыли (дохода)', '68.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366804, 366800, 'Расчеты по подоходному налогу', '68.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366805, 366800, 'Расчеты по прочим платежам в бюджет', '68.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367601, 367600, 'Расчеты по исполнительным документам', '76.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367602, 367600, 'Расчеты по имущественному и личному страхованию', '76.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367603, 367600, 'Расчеты по претензиям', '76.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367604, 367600, 'Расчеты по причитающимся дивидендам и другим доходам', '76.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367605, 367600, 'Расчеты по депонированным суммам', '76.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367606, 367600, 'Расчеты по договору доверительного управления имуществом', '76.06', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367903, 367900, 'Расчеты по договору доверительного управления имуществом', '79.03', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344601, 344600, 'Выручка от реализации продукции, товаров, работ, услуг', '90.01', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344602, 344600, 'Себестоимость реализации', '90.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344603, 344600, 'Налог на добавленную стоимость', '90.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344604, 344600, 'Акцизы', '90.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344605, 344600, 'Прочие налоги и сборы из выручки', '90.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344606, 344600, 'Экспортные пошлины', '90.06', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344609, 344600, 'Прибыль (убыток) от текущей деятельности', '90.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344701, 344700, 'Прочие доходы', '91.01', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344702, 344700, 'Операционные расходы', '91.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344703, 344700, 'Налог на добавленную стоимость', '91.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344704, 344700, 'Прочие налоги и сборы из операционных доходов', '91.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344709, 344700, 'Сальдо операционных доходов и расходов', '91.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386001, 385004, 'Внереализационные доходы', '92.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386002, 385004, 'Внереализационные расходы', '92.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386003, 385004, 'Налог на добавленную стоимость', '92.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386004, 385004, 'Прочие налоги и сборы из внереализационных доходов', '92.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386009, 385004, 'Сальдо внереализационных доходов и расходов', '92.09', 'A', 'S', 0, 0, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393007, 300002, 'Списанная безнадежная к получению дебиторская задолженность', '007', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393008, 300002, 'Обеспечения обязательств полученные', '008', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311903, 311900, 'НДС по приобретенным товарно-материальным ценностям, работам, услугам', '18.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311904, 311900, 'НДС по приобретенным товарам', '18.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344105, 344100, 'Товары, переданные для подготовки на сторону', '41.05', 'A', 'S', 0, 0, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (391000, 340000, 'Выполненные этапы по незавершенным работам', '46', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393010, 300002, 'Амортизационный фонд воспроизводства основных средств', '010', 'A', 'A', 0, 1, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393011, 300002, 'Основные средства, сданные в аренду', '011', 'A', 'A', 0, 1, -1, -1, -1);
/*
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393012, 300002, 'Нематериальные активы, полученные в пользование', '012', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393013, 300002, 'Амортизационный фонд воспроизводства нематериальных активов', '013', 'A', 'A', 0, 1, -1, -1, -1);
*/
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393014, 300002, 'Потеря стоимости основных средств', '014', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393009, 300002, 'Обеспечения обязательств выданные', '009', 'A', 'A', 0, 1, -1, -1, -1);


-- msg_box
-- 450001..500000

INSERT INTO msg_box (id, parent, name) VALUES (450010, NULL, 'inbox');
INSERT INTO msg_box (id, parent, name) VALUES (450020, NULL, 'outbox');
INSERT INTO msg_box (id, parent, name) VALUES (450025, NULL, 'sent');
INSERT INTO msg_box (id, parent, name) VALUES (450030, NULL, 'draft');
INSERT INTO msg_box (id, parent, name) VALUES (450040, NULL, 'trash');


-- gd_contact
-- 650001..700000

INSERT INTO GD_CONTACT
  (ID,PARENT,CONTACTTYPE,NAME)
  VALUES
  (650010,650001,3,'<Ввести наименование организации>');

INSERT INTO GD_COMPANY
  (CONTACTKEY,FULLNAME)
  VALUES
  (650010,'<Ввести наименование организации>');

INSERT INTO GD_OURCOMPANY
  (COMPANYKEY)
  VALUES
  (650010);

INSERT INTO GD_CONTACT
  (ID,PARENT,CONTACTTYPE,NAME)
  VALUES
  (650015,650001,5,'<Ввести наименование банка>');

INSERT INTO GD_COMPANY
  (CONTACTKEY,FULLNAME)
  VALUES
  (650015,'<Ввести наименование банка>');

INSERT INTO GD_BANK
  (BANKKEY,BANKCODE)
  VALUES
  (650015,'<Ввести код банка>');


-- gd_command
-- 700001..800000

  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex, aview)
    VALUES (
      710000,
      NULL,
      'Исследователь',
      'explorer',
      NULL,
      0,
      1
    );

  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      714000,
      710000,
      'Бухгалтерия',
      'accountancy',
      NULL,
      0
    );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730300,
        714000,
        'План счетов',
        'ref_card_account',
        'TgdcAcctAccount',
        NULL,
        219
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730700,
        714000,
        'Типовые хоз. операции',
        'ref_tr_type',
        'TgdcAcctTransaction',
        NULL,
        59
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714050,
        714000,
        'Автоматические хоз. операции',
        '',
        'Tgdc_frmAutoTransaction',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714010,
        714000,
        'Журнал хозяйственных операций',
        'acc_journal',
        'TgdcAcctViewEntryRegister',
        NULL,
        53
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714022,
        714000,
        'Журнал-ордер',
        '',
        'Tgdv_frmAcctLedger',
        NULL,
        186
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714030,
        714000,
        'Анализ счета',
        '',
        'Tgdv_frmAcctAccReview',
        NULL,
        220
      );

    INSERT INTO GD_COMMAND (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,
       CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
       VALUES (
         714098,
         714000,
         'Карта счета',
         'acc_AccountCard',
         0,
         NULL,
         220,
         NULL,
         'Tgdv_frmAcctAccCard',
         NULL,
         -1,
         -1,
         -1,
         0,
         NULL);

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714025,
        714000,
        'Главная книга',
        '',
        'Tgdv_frmGeneralLedger',
        NULL,
        85
      );
      
      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714200,
        714000,
        'Переход на новый месяц',
        '',
        'TfrmCalculateBalance',
        NULL,
        87
      );

/*    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714020,
        714021,
        'Настройка журнал-ордера',
        '',
        'TgdcLedger',
        NULL,
        0
      );*/

    INSERT INTO GD_COMMAND
      (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
    VALUES
      (714090,714000,'Оборотная ведомость','acc_CirculationList',0,NULL,61,NULL,'Tgdv_frmAcctCirculationList',NULL,-1,-1,-1,0,NULL);

    INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      715000,
      710000,
      'Банк',
      'bank',
      NULL,
      104
    );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        715020,
        715000,
        'Выписки по р/с',
        'bn_bank_statement',
        'TgdcBankStatement',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        715025,
        715000,
        'Картотека по р/с',
        'bn_bank_catalogue',
        'TgdcBankCatalogue',
        NULL,
        0
      );


  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      730000,
      710000,
      'Справочники',
      'references',
      NULL,
      7
    );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730100,
        730000,
        'Клиенты',
        'ref_contact',
        'TgdcBaseContact',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730110,
        730100,
        'Организации',
        '',
        'TgdcCompany',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730115,
        730110,
        'Банки',
        '',
        'TgdcBank',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730117,
        730110,
        'Расчетные счета',
        '',
        'TgdcAccount',
        NULL,
        0
      );

      /*
    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730119,
        730110,
        'Рабочие организации',
        '',
        'TgdcOurCompany',
        NULL,
        0
      );
      */

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730120,
        730100,
        'Люди',
        '',
        'TgdcContact',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730130,
        730100,
        'Группы',
        '',
        'TgdcGroup',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730900,
        730110,
        'Подразделения',
        'ref_department',
        'TgdcDepartment',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730902,
        730110,
        'Сотрудники',
        'ref_employee',
        'TgdcEmployee',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730200,
        730000,
        'Курсы валют',
        'ref_curr_rate',
        'TgdcCurrRate',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730210,
        730200,
        'Валюты',
        '',
        'TgdcCurr',
        NULL,
        0
      );

    /*
    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730600,
        730000,
        'Рабочие организации',
        'ref_work_company',
        'TgdcOurCompany',
        NULL,
        0
      );
    */

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730800,
        730000,
        'Справочник ТМЦ',
        'ref_dir_good',
        'TgdcGood',
        NULL,
        181
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730805,
        730800,
        'Группы ТМЦ',
        '',
        'TgdcGoodGroup',
        NULL,
        142
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730810,
        730800,
        'Драгметаллы',
        '',
        'TgdcMetal',
        NULL,
        165
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730820,
        730800,
        'Налоги',
        '',
        'TgdcTax',
        NULL,
        185
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730830,
        730800,
        'Коды ТНВД',
        '',
        'TgdcTNVD',
        NULL,
        75
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730840,
        730800,
        'Единицы измерения',
        '',
        'TgdcValue',
        NULL,
        201
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730950,
        730000,
        'Адм.-терр. единицы',
        'ref_place',
        'TgdcPlace',
        NULL,
        147
      );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        731050,
        730000,
        'Типы банковских счетов',
        'ref_compacctype',
        'TgdcCompanyAccountType',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        731100,
        730000,
        'График рабочего времени',
        'ref_tablecalendar',
        'TgdcTableCalendar',
        NULL,
        92
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        731150,
        730000,
        'Государственные праздники',
        'ref_holiday',
        'TgdcHoliday',
        NULL,
        236
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        731200,
        730000,
        'Должности',
        'ref_position',
        'TgdcWgPosition',
        NULL,
        0
      );

  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      740000,
      710000,
      'Сервис',
      'service',
      NULL,
      144
    );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740050,
        740000,
        'Администратор',
        'srv_administrator',
        '',
        NULL,
        155,
        1 /* только администратору доступно */
      );

      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740055,
          740050,
          'Пользователи',
          'adm_user',
          'TgdcUser',
          NULL,
          0,
          1 /* только администратору доступно */
        );

      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740060,
          740050,
          'Группы пользователей',
          'adm_user_group',
          'TgdcUserGroup',
          NULL,
          0,
          1 /* только администратору доступно */
        );

      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740065,
          740050,
          'Операции',
          'adm_operation',
          'TgdcOperation',
          NULL,
          0,
          1 /* только администратору доступно */
        );

      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740070,
          740050,
          'Журнал событий',
          'srv_eventlog',
          'TgdcJournal',
          NULL,
          256,
          1
        );
		
      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview, achag, afull)
        VALUES (
          740075,
          740050,
          'Автозадачи',
          '',
          'TgdcAutoTask',
          NULL,
          256,
          1, 1, 1
        );

     /* 
      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740080,
          740050,
          'Блокировка изменений',
          '',
          'TgdcBlockRule',
          NULL,
          256,
          1
        );
      */

        /*
    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740100,
        740000,
        'Регистрация ошибок',
        'srv_bugbase',
        'TgdcBugBase',
        NULL,
        0
      );
        */

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740300,
        740000,
        'Хранилище',
        'srv_storage',
        'Tst_frmMain',
        NULL,
        255,
        1
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740302,
        740300,
        'Хранилище (б/о)',
        'srv_storage_new',
        'TgdcStorage',
        NULL,
        255,
        1
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740350,
        740000,
        'Фильтры',
        'TgdcComponentFilter',
        'TgdcComponentFilter',
        NULL,
        20,
        1
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740400,
        740000,
        'Атрибуты',
        'srv_attribute',
        '',
        NULL,
        0,
        1
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740500,
        740000,
        'Региональные установки',
        'regionalsettings',
        'TdlgRegionalSettings',
        NULL,
        154
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740600,
        740000,
        'Типовые документы',
        'documenttypes',
        'TgdcDocumentType',
        NULL,
        0
      );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740900,
        740000,
        'Константы',
        'constants',
        'TgdcConst',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740910,
        740000,
        'Файлы',
        'Files',
        'TgdcFile',
        NULL,
        85
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740915,
        740000,
        'Прикрепления',
        'LinkedObjects',
        'TgdcLink',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740920,
        740000,
        'Исследователь',
        'explorer',
        'TgdcExplorer',
        NULL,
        260
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740925,
        740000,
        'Почтовые сервера',
        'SMTP',
        'TgdcSMTP',
        NULL,
        160
      );

/*
  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      750000,
      710000,
      'Сообщения',
      'TgdcBaseMessage',
      'TgdcBaseMessage',
      NULL,
      0
    );
  */


  /*
  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      760000,
      710000,
      'Реализация',
      'realization',
      NULL,
      0
    );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760100,
        760000,
        'Прайс-лист',
        'ref_price',
        'TfrmPrice',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760150,
        760000,
        'Счета-фактуры',
        'bill_uni',
        'TfrmBills',
        NULL,
        0
      );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760200,
        760000,
        'Накладная на отпуск ТМЦ',
        'billgood',
        'TfrmRealizationBill',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760300,
        760000,
        'Формирование требований',
        'makedemand',
        'TfrmMakeDemand',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760400,
        760000,
        'Договора',
        'contractsell',
        'TfrmContractSell',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760500,
        760000,
        'Накладная на возврат',
        'returnsell',
        'TfrmReturnBill',
        NULL,
        0
      );
  */

  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      770000,
      710000,
      'Отчеты',
      'report',
      'Tgdc_frmReportList',
      NULL,
      15
    );

INSERT INTO GD_COMMAND
  (ID,CMD,CMDTYPE,PARENT,HOTKEY,NAME,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED)
VALUES
  (741101,'gdcField',0,740400,NULL,'Домены',250,NULL,'TgdcField',NULL,1,1,1,0,NULL);

INSERT INTO GD_COMMAND
  (ID,CMD,CMDTYPE,PARENT,HOTKEY,NAME,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED)
VALUES
  (741102,'gdcTable',0,740400,NULL,'Таблицы',251,NULL,'TgdcTable',NULL,1,1,1,0,NULL);

INSERT INTO GD_COMMAND
  (ID,CMD,CMDTYPE,PARENT,HOTKEY,NAME,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED)
VALUES
  (741103,'gdcView',0,740400,NULL,'Представления',252,NULL,'TgdcView',NULL,1,1,1,0,NULL);

INSERT INTO GD_COMMAND
  (ID,CMD,CMDTYPE,PARENT,HOTKEY,NAME,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED)
VALUES
  (741104,'gdcStoredProc',0,740400,NULL,'Процедуры',253,NULL,'TgdcStoredProc',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741105,740400,'Исключения','gdcExceptions',0,NULL,254,NULL,'TgdcException',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741106,740400,'Настройки','gdcSetting',0,NULL,80,NULL,'TgdcSetting',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741107,740400,'Генераторы','gdcGenerator',0,NULL,236,NULL,'TgdcGenerator',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741108,740400,'Пространства имен','gdcNamespace',0,NULL,80,NULL,'TgdcNamespace',NULL,1,1,1,0,NULL);

INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
VALUES (
  741109,
  740400,
  'Синхронизация ПИ',
  '',
  'Tat_frmSyncNamespace',
  NULL,
  0
);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741115,740400,'Индексы','gdcIndex',0,NULL,206,NULL,'TgdcIndex',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741117,740400,'Триггеры','gdcTrigger',0,NULL,253,NULL,'TgdcTrigger',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741118,740400,'Ограничения','gdcCheckConstraint',0,NULL,214,NULL,'TgdcCheckConstraint',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741120,740400,'Внешние ключи','gdcFKManager',0,NULL,228,NULL,'TgdcFKManager',NULL,1,1,1,0,NULL);
  
  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      790000,
      710000,
      'Материальный склад',
      '790000_17',
      NULL,
      0
    );
  
-- gd_documenttype
-- 800001..850000

INSERT INTO gd_documenttype(id, ruid, name, description, documenttype)
  VALUES (800001, '800001_17', 'Выписка и картотека', 'Выписка и картотека', 'B');

INSERT INTO gd_documenttype(id, ruid, parent, name, description)
  VALUES (800300, '800300_17', 800001, 'Банковская выписка', 'Банковская выписка');

INSERT INTO gd_documenttype(id, ruid, parent, name, description)
  VALUES (800350, '800350_17', 800001, 'Банковская картотека', 'Банковская картотека');

INSERT INTO gd_documenttype(id, ruid, name, description, documenttype, classname, editiondate)
  VALUES (801000, '801000_17', 'Документ пользователя', 'Документ пользователя', 'B', 'TgdcUserDocumentType', '01.01.2000');

/* Складские документы */

INSERT INTO gd_documenttype(id, ruid, name, description, documenttype, classname)
  VALUES (804000, '804000_17', 'Складские документы',
    'Документы по приему, перемещению и передаче ТМЦ и услуг', 'B', 'TgdcInvDocumentType');

INSERT INTO gd_documenttype(id, ruid, name, description, documenttype, classname)
  VALUES (805000, '805000_17', 'Прайс-листы', 'Список прайс-листов', 'B', 'TgdcInvPriceListType');

/* Бухгалтерские документы */

INSERT INTO gd_documenttype(id,
    ruid,
    name,
    description,
    documenttype,
    classname)
  VALUES (806000,
    '806000_17',
    'Бухгалтерские документы',
    'Документы для бухгалтерии',
    'B',
    'TgdcDocumentType');

INSERT INTO gd_documenttype(id, ruid, parent, name, description, documenttype, classname)
  VALUES (806001, '806001_17', 806000,
    'Хозяйственная операция', 'Документы для отражения произвольных хозяйственных операций', 'D', '');

/* Отчеты бухгалтерии */

INSERT INTO gd_documenttype(id, parent, ruid, name, description, documenttype)
  VALUES (807005, 806000, '807005_17', 'Отчеты бухгалтерии', 'Документы для расчета налогов отчетов бухгалтерии', 'D');

/* Типовые проводки */

INSERT INTO ac_transaction(id, name, editiondate) VALUES (807001, 'Произвольные проводки', '01.01.2000');
INSERT INTO ac_transaction(id, name, editiondate) VALUES (807002, 'Налоги', '01.01.2000');


INSERT INTO ac_trrecord(id, transactionkey, documenttypekey, description)
  VALUES (807100, 807001, 806001, 'Произвольная проводка');


-- gd_storage_data
-- 990000..999999

INSERT INTO gd_storage_data (id, name, data_type, editiondate, editorkey)
  VALUES (990000, 'GLOBAL', 'G', '01.01.2000', 650002);
INSERT INTO gd_storage_data (id, name, data_type, int_data, editiondate, editorkey)
  VALUES (990010, 'USER - Administrator', 'U', 150001, '01.01.2000', 650002);
INSERT INTO gd_storage_data (id, name, data_type, int_data, editiondate, editorkey)
  VALUES (990020, 'COMPANY - <Ввести наименование организации>', 'O', 650010, '01.01.2000', 650002);


-- evt_macrosgroup

/***********************************************************/
/*     Корень глобальных макросов                          */
/***********************************************************/

INSERT INTO EVT_MACROSGROUP (ID, LB, RB, NAME, ISGLOBAL, EDITORKEY)
  VALUES (1020001, 1, 2, 'Глобальные макросы', 1, 650002);

INSERT INTO EVT_OBJECT (ID, NAME, LB, RB, AFULL, ACHAG, AVIEW, OBJECTTYPE, MACROSGROUPKEY, OBJECTNAME, EDITORKEY)
  VALUES (1010001, 'APPLICATION', 1, 2, -1, -1, -1, 0, 1020001, 'APPLICATION', 650002);


-- gd_compacctype
-- 1799900..1799999

INSERT INTO gd_compacctype (id, name)
   VALUES(1799900, 'Расчетный счет');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799910, 'Ссудный счет');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799920, 'Депозитный счет');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799930, 'Бюджетный счет');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799940, 'Кассовый счет');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799950, 'Транзитный счет');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799960, 'Корреспондентский счет');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799970, 'Чековая книжка');

INSERT INTO GD_COMPANYACCOUNT
  (ID, COMPANYKEY, BANKKEY, ACCOUNT, ACCOUNTTYPEKEY, CURRKEY)
  VALUES
  (650100, 650010, 650015, '<Ввести счет>', 1799900, 200010);

UPDATE GD_COMPANY
  SET COMPANYACCOUNTKEY = 650100
  WHERE CONTACTKEY = 650010;


-- rp_reportgroup
-- 2000000..3000000

INSERT INTO rp_reportgroup (id, name, usergroupname)
  VALUES (2000100, 'Банковская выписка', '2000100');

INSERT INTO rp_reportgroup (id, name, usergroupname)
  VALUES (2000101, 'Картотека', '2000101');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000500, NULL, 'Справочники', '2000500');
INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000510, 2000500, 'Клиенты', '2000510');
INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000520, 2000500, 'Товары', '2000520');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname, editiondate)
  VALUES (1020002, NULL, 'Бухгалтерский отчет', 'TGDCTAXNAME', '01.01.2000');

/* Банк                */

INSERT INTO rp_reportgroup (id, name, usergroupname)
  VALUES (2000300, 'Банковские документы', '2000300');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000310, 2000300, 'Поручение на перевод валюты', '2000310');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000311, 2000300, 'Договор на продажу валюты', '2000311');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000312, 2000300, 'Поручение на продажу валюты', '2000312');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000313, 2000300, 'Реестр распределения валюты', '2000313');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000314, 2000300, 'Договор на покупку валюты', '2000314');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000315, 2000300, 'Контракт на конвертацию валют', '2000315');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000201, 2000300, 'Платежное поручение', '2000201');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000202, 2000300, 'Платежное требование', '2000202');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000203, 2000300, 'Платежное требование - поручение', '2000203');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000204, 2000300, 'Инкасовое распоряжение', '2000204');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000206, 2000300, 'Реестр чеков', '2000206');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000207, 2000300, 'Сводное платежное поручение', '2000207');

/* Бухгалтерия */

INSERT INTO rp_reportgroup (id, name, usergroupname)
  VALUES (2000600, 'Бухгалтерия ', '2000600');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000601, 2000600, 'План счетов', '2000601');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000602, 2000600, 'Остатки', '2000602');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000603, 2000600, 'Журнал хозяйственных операций', '2000603');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000604, 2000600, 'Типовые операции', '2000604');


-- gd_value

INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000001, 'шт.', 'Штука', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000002, 'кг', 'Килограмм', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000003, 'кв.м.', 'Квадратный метр', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000004, 'куб.м.', 'Кубический метр', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000005, 'т', 'Тонна', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000006, 'л', 'Литр', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000007, 'пачка', 'Пачка', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000008, 'мешок', 'Мешок', 1);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000009, 'уп.', 'Упаковка', 1);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000010, 'комп.', 'Комплект', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000011, 'туб', 'Туба', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000012, 'ящик', 'Ящик', 1);

-- gd_file

INSERT INTO gd_file
  (id, parent, filetype, name, creatorkey, creationdate, editorkey, editiondate)
VALUES
  (4000001, NULL, 'D', '_Справка', 650002, '01.01.2000', 650002, '01.01.2000');

INSERT INTO gd_file
  (id, parent, filetype, name, creatorkey, creationdate, editorkey, editiondate)
VALUES
  (4000002, 4000001, 'D', '_Классы', 650002, '01.01.2000', 650002, '01.01.2000');

INSERT INTO gd_file
  (id, parent, filetype, name, creatorkey, creationdate, editorkey, editiondate)
VALUES
  (4000003, 4000002, 'D', '_Система', 650002, '01.01.2000', 650002, '01.01.2000');

INSERT INTO gd_file
  (id, parent, filetype, name, creatorkey, creationdate, editorkey, editiondate)
VALUES
  (4000004, 4000002, 'D', '_Пользователь', 650002, '01.01.2000', 650002, '01.01.2000');

COMMIT;

COMMIT;




/*

  Copyright (c) 2000-2015 by Golden Software of Belarus, Ltd

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
GRANT ALL ON GD_DOCUMENTTYPE_OPTION TO administrator;

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
GRANT ALL ON GD_AUTOTASK TO administrator;
GRANT ALL ON GD_AUTOTASK_LOG TO administrator;
GRANT ALL ON GD_SMTP TO administrator;

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
/*GRANT EXECUTE ON PROCEDURE INV_INSERT_CARD TO ADMINISTRATOR;*/

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
GRANT ALL ON ac_incorrect_record TO administrator;

COMMIT;

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_db_connect
  ACTIVE
  ON CONNECT
  POSITION 0
AS
  DECLARE VARIABLE ingroup INTEGER = NULL;
  DECLARE VARIABLE userkey INTEGER = NULL;
  DECLARE VARIABLE contactkey INTEGER = NULL;
BEGIN
  SELECT FIRST 1 id, contactkey, ingroup 
  FROM gd_user 
  WHERE ibname = CURRENT_USER
  INTO :userkey, :contactkey, :ingroup;
  RDB$SET_CONTEXT('USER_SESSION', 'GD_USERKEY', COALESCE(:userkey, 150001));
  RDB$SET_CONTEXT('USER_SESSION', 'GD_CONTACTKEY', COALESCE(:contactkey, 650002));
  RDB$SET_CONTEXT('USER_SESSION', 'GD_INGROUP', COALESCE(:ingroup, 0));
END
^

SET TERM ; ^

COMMIT;
