
/****************************************************/
/****************************************************/
/**                                                **/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/****************************************************/
/**   ���������� �����                             **/
/****************************************************/

CREATE TABLE gd_curr
(
  id             dintkey,                      /* ���������� �������������                               */
  disabled       ddisabled,                    /* ������������ ��� ������ ��� ���                        */
  isNCU          dboolean DEFAULT 0,           /* �������� �� ��� ������ ������������ �������� ��.       */
  isEq           dboolean DEFAULT 0,           /* �������� �� ��� ������ ������������       */
  code           dalias,                       /* ��� ������ (�� ����������� ��������������)             */
  name           dname,                        /* ������ ������������                                    */
  shortname      dalias,                       /* ������� ������������                                   */
  sign           dalias,                       /* ���� ������                                            */
  place          dboolean DEFAULT 0,           /* �������������� �����, TRUE -- ��, FALSE -- ����� ����� */
  decdigits      ddecdigits DEFAULT 2,         /* ���������� ���������� ������                           */
  fullcentname   dtext40,                      /* ������ ������������ ������                             */
  shortcentname  dtext40,                      /* ������� ������������ ������                            */
  centbase       dsmallint DEFAULT 10 NOT NULL, /* ���� ������� ������ (����� ������ 10)                  */
  icon           dinteger,
  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,
  ISO            dISO,
  name_0         dtext60, /* � ����������� ������, ���� ������������� �� 0, 5-9*/
  name_1         dtext60, /* � ����������� ������, ���� ������������� �� 2-4 */
  centname_0     dtext60, /* � ����������� ������, ���� ������������� �� 0, 5-9*/
  centname_1     dtext60, /* � ����������� ������, ���� ������������� �� 2-4 */
  reserved       dreserved
);

COMMIT;

ALTER TABLE gd_curr ADD CONSTRAINT gd_pk_curr
  PRIMARY KEY (id);

CREATE UNIQUE ASC INDEX gd_x_currfullname ON gd_curr
  /*COMPUTED BY (UPPER(name));*/
  (name);

CREATE UNIQUE ASC INDEX gd_x_currshortname ON gd_curr
  /*COMPUTED BY (UPPER(shortname));*/
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

  /* ��� ����� ���� ������ ���� */
  IF (NEW.isNCU = 1) THEN
    UPDATE gd_curr SET isNCU = 0 WHERE isNCU = 1;

  /* ���������� ����� ���� ������ ���� */
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
  /* ��� ����� ���� ������ ���� */
  IF (NEW.isNCU = 1 AND NEW.isNCU <> OLD.isNCU) THEN
    UPDATE gd_curr SET isNCU = 0 WHERE id <> NEW.id;

  /* ���������� ����� ���� ������ ���� */
  IF (NEW.isEq = 1 AND NEW.isEq <> OLD.isEq) THEN
    UPDATE gd_curr SET isEq = 0 WHERE id <> NEW.id;
END
^


SET TERM ; ^

COMMIT;

/****************************************************/
/**   ���������� ������ �����                      **/
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
  coeff          dcurrrate
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

COMMIT;

/* COMMIT; */
