
/****************************************************/
/****************************************************/
/**                                                **/
/**   Gedemin project                              **/
/**   Copyright (c) 1999-2000 by                   **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/* домен для первичных ключей */
CREATE DOMAIN dintkey
  AS INTEGER NOT NULL
  CHECK (VALUE > 0);

/* будем использовать этот домен для всех полей ссылок */
CREATE DOMAIN dforeignkey
  AS INTEGER;

CREATE DOMAIN dinteger
  AS INTEGER;

CREATE DOMAIN dname
  AS VARCHAR(60) CHARACTER SET WIN1251 NOT NULL COLLATE PXW_CYRL;

CREATE DOMAIN dtext20
  AS VARCHAR(20) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dtext180
  AS VARCHAR(180) CHARACTER SET WIN1251 COLLATE PXW_CYRL;

CREATE DOMAIN dboolean
  AS SMALLINT
  CHECK ((VALUE IS NULL) OR (VALUE IN (0, 1)));

CREATE DOMAIN dreserved
  AS INTEGER;

CREATE DOMAIN dsecurity
  AS INTEGER DEFAULT (-1) NOT NULL;

CREATE DOMAIN dtime
  AS TIME;

CREATE DOMAIN dfilterdata
  AS BLOB SUB_TYPE 0 SEGMENT SIZE 512;

COMMIT;

