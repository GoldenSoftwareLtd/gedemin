
/****************************************************/
/****************************************************/
/**                                                **/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

CREATE EXCEPTION gd_e_nofolder 'There is no any folder';

CREATE DOMAIN daddrcontacttype
  AS SMALLINT NOT NULL;

CREATE TABLE gd_contact
(
  id            dintkey,


  /* ����� (�������) �������. ������������ ����� �������������� */
  /* ��� ������ ���������� ������, ���� ������ � ������ */
  /* ��������� � ������ �������� */
  lb            dlb,
  rb            drb,          /* ������ (������) ������� */

  parent        dparent,
  contacttype   daddrcontacttype, /* 0 - �����, 1 - ������, 2 - �������, 3 - ������, 4 - �������������, 5 - ����        */
                              /*
                                ��� ������� department
                                100 - ����������� �����������
                                101 - �������������� ������
                                102 - ���������� ������
                                103 - ������� �������������� �����
                               */

  name          dname,        /* ��� ��� ������                                                           */
  address       dtext60,      /* �����                                                                    */
  district      dtext20,
  city          dtext20,      /* �����                                                                    */
  region        dtext20,      /* ��������                                                                 */
  ZIP           dtext20,      /* ������                                                                   */
  country       dtext20,      /* �����                                                                   */
  placekey      dforeignkey,
  note          dblobtext80_1251, /* ��������                                                                 */
  externalkey   dforeignkey,
  email         dtext60,
  url           dtext40,
  pobox         dtext40,
  phone         dtext40,
  fax           dtext40,

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

/* ��� ���������� �������� �������, �������� � ��� ������ */
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


CREATE ASC INDEX gd_x_contact_name ON gd_contact (name);

COMMIT;

CREATE TABLE gd_people
(
  contactkey     dintkey,
  firstname      dtext20,      /* ���                                                            */
  surname        dtext20 NOT NULL,/* ��������                                                      */
  middlename     dtext20,      /* ��� �� ������                                                  */
  nickname       dtext20,      /* �������� ���                                                   */
  rank           dtext20,      /* �����                                                         */

  /* ����� �������� */
  hplacekey      dforeignkey,
  haddress       dtext60,     /* �����                                                          */
  hcity          dtext20,     /* �����                                                          */
  hregion        dtext20,     /* ��������                                                       */
  hZIP           dtext20,     /* ������                                                         */
  hcountry       dtext20,     /* �����                                                         */
  hdistrict      dtext20,
  hphone         dtext20,

  /* �������� �������� */
  wcompanykey    dforeignkey,
  wcompanyname   dtext60,     /* �������                                                       */
  wdepartment    dtext20,     /* ���������������                                                */
  wpositionkey   dforeignkey,

  /* ������������ �������� */
  spouse         dtext20,     /* ������/�������                                                 */
  children       dtext20,     /* �����                                                         */
  sex            dgender,     /* ���                                                            */
  birthday       ddate,        /* ���� �����������                                               */

  /* ���������� �������� */
  passportnumber dtext40,     /* ����� �������� */
  /*passportdate   ddate,*/       /* ??? */
  passportexpdate ddate,      /* ����� ������� �������� */
  passportissdate ddate,      /* ���� ������ */
  passportissuer dtext40,     /* ��� ���� */
  passportisscity dtext20,    /* ��� ��������� */
  personalnumber dtext40,     /* ����������� ����� */

  /*�����*/

  /* ���������� ���������� */
  visitcard      dBMP,        /* ³����� ������                                                */
  photo          dBMP         /* ����                                                           */
);

ALTER TABLE gd_people
  ADD CONSTRAINT gd_pk_people PRIMARY KEY (contactkey);

ALTER TABLE gd_people ADD CONSTRAINT gd_fk_people_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

/* ��� ���������� ������� �� ���� ����������� ������� */
/* ����� ��������� -- �������� ����� �������� � ��   */
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

SET TERM ; ^

COMMIT;

CREATE TABLE gd_company
(
  contactkey        dintkey,     /* �������  */
  companyaccountkey dforeignkey, /* ��������� ���� */
  headcompany       dforeignkey, /* �������� �������� */
  /* ���?��� ���� ������ ��������� ����� */
  fullname          dtext180,    /* ������ ����������� */
  companytype       dtext20,     /* ��� �������� */
  directorkey       dforeignkey,
  chiefaccountantkey dforeignkey,
  logo              dBMP         /* ������� */
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


/*
 *
 *  ������� �������������� ������� ���������.
 *  �������������� �������� ��������� ����������� ����� ��������
 *
 */


/*CREATE TABLE gd_contactprops
(
  contactkey     dintkey,                       * / /* ���� ������� */
/*  reserved       dinteger                      */   /* ��������������� */
/*);


COMMIT;

ALTER TABLE gd_contactprops ADD CONSTRAINT gd_pk_contactprops_contact
  PRIMARY KEY (contactkey);

COMMIT;

ALTER TABLE gd_contactprops ADD CONSTRAINT gd_fk_contactprops_contact
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE ON DELETE CASCADE;
*/

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

/* ���� -- ���������� ���������� ��� ������, ����, ��� */
/* ���������� ������� ������ � ����                     */
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

/* ���� ������*/
CREATE TABLE GD_COMPACCTYPE
(
  id   dintkey,
  name dname
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
  id             dintkey,            /* �������� �������������                   */
  companykey     dmasterkey,         /* �������, ���� �������� �������           */
  bankkey        dintkey,            /* �������� �� ����                          */
  payername      dtext60,            /* ����� ������ ��� ��������� ���������    */
  account        dbankaccount NOT NULL,       /* �������                                   */
  currkey        dforeignkey,        /* ������, � ���� ������� �������            */
  accounttypekey dforeignkey,        /* ��� ���� ������� (��������, ������...)   */
  disabled       dboolean DEFAULT 0,

  accounttype    dtext20             /* ��� ������������� � ���������� �������    */
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

/* ������ -- ���������� ���������� ��� ������, ����, ��� */
/* ���������� ������� ������ � ����                        */
ALTER TABLE gd_companyaccount ADD CONSTRAINT gd_fk_companyaccount_companykey
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_company ADD CONSTRAINT gd_fk_company_companyaccountkey
  FOREIGN KEY (companyaccountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

/*
���� ������ �� ����� ��� ��� ���������� ��������:

gd_uk_companyaccount

CREATE INDEX gd_x_companyaccount_acc
  ON gd_companyaccount (account);
*/

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

/* ��� ���������� ������ -- ������ � ��� ����� �������� � �� */
ALTER TABLE gd_contactlist ADD CONSTRAINT gd_fk_group_contactlist
  FOREIGN KEY (groupkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/* ����� ���������, �������� � ������ ��������� */

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

CREATE TRIGGER gd_bi_contact FOR gd_contact
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.name IS NULL) THEN
    NEW.name = '';
END
^

/*
CREATE TRIGGER gd_bi_contact_2 FOR gd_contact
  BEFORE INSERT
  POSITION 2
AS
  DECLARE VARIABLE AFULL INTEGER;
  DECLARE VARIABLE ACHAG INTEGER;
  DECLARE VARIABLE AVIEW INTEGER;
BEGIN
  IF (NEW.parent IS NOT NULL) THEN
  BEGIN
    SELECT C.AFULL, C.ACHAG, C.AVIEW
    FROM GD_CONTACT C
    WHERE C.ID = NEW.Parent
    INTO :AFULL, :ACHAG, :AVIEW;
    NEW.AFULL = g_b_or(g_b_and(NEW.AFULL, :AFULL), 1);
    NEW.ACHAG = g_b_or(g_b_and(NEW.ACHAG, :ACHAG), 1);
    NEW.AVIEW = g_b_or(g_b_and(NEW.AVIEW, :AVIEW), 1);
  END
END
^
*/

/*

  ��� ��������� ���� ������� � ������� ��� �������������� ��� �
  ������ ����� �����������, ��� � ���� �������� � ���� ��������
  ����� ����� ����� �� ��� ������, �� �� ������.

*/

/*
CREATE TRIGGER gd_bu_contact_2 FOR gd_contact
  BEFORE UPDATE
  POSITION 2
AS
  DECLARE VARIABLE AFULL INTEGER;
  DECLARE VARIABLE ACHAG INTEGER;
  DECLARE VARIABLE AVIEW INTEGER;
BEGIN
  IF ((NEW.parent IS NOT NULL) AND (NEW.parent <> OLD.parent)) THEN
  BEGIN
    SELECT C.AFULL, C.ACHAG, C.AVIEW
    FROM GD_CONTACT C
    WHERE C.ID = NEW.Parent
    INTO :AFULL, :ACHAG, :AVIEW;
    NEW.AFULL = g_b_or(g_b_and(NEW.AFULL, :AFULL), 1);
    NEW.ACHAG = g_b_or(g_b_and(NEW.ACHAG, :ACHAG), 1);
    NEW.AVIEW = g_b_or(g_b_and(NEW.AVIEW, :AVIEW), 1);
  END

  IF ((NEW.afull <> OLD.afull) OR (NEW.achag <> OLD.achag) OR (NEW.aview <> OLD.aview)) THEN
  BEGIN
    UPDATE GD_CONTACT C
    SET
      C.AFULL = g_b_or(g_b_and(NEW.AFULL, C.AFULL), 1),
      C.ACHAG = g_b_or(g_b_and(NEW.ACHAG, C.ACHAG), 1),
      C.AVIEW = g_b_or(g_b_and(NEW.AVIEW, C.AVIEW), 1)
    WHERE
      C.Parent = New.ID;
  END
END
^
*/

/*

  ��� ������� ���������� �������� ������ ��������
  ��� ���.

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
 *  �� ������� ��������� �� ����� ���������� � ������
 *  ���������. !!!
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




/*

  ������ ��������� ��� �������� �������� �������� ����������
  ������ ������������� � �����������, ���, ��� ���� ������ ����� ���-
  ������� � ������.

*/

/*
CREATE GENERATOR gd_g_contact_virt_id
^
SET GENERATOR gd_g_contact_virt_id TO 2147483646
^

CREATE PROCEDURE gd_p_people_and_departments (Master INTEGER)
  RETURNS (
    id INTEGER,
    parent INTEGER,
    name VARCHAR(60),
    origid INTEGER,
    origparent INTEGER,
    contacttype INTEGER
  )
AS
  DECLARE VARIABLE GK INTEGER;
BEGIN
  id = 2147483646;

  FOR
    SELECT d.id, d.parent, d.name, d.id, d.parent, 4
    FROM gd_contact d
      JOIN gd_contact p ON d.lb >= p.lb AND d.rb <= p.rb AND p.id=:Master
    WHERE d.contacttype=4 AND (NOT d.disabled=1)
    INTO :id, :parent, :name, :origid, :origparent, :contacttype
  DO BEGIN
    SUSPEND;

    Parent = :ID;
    GK = :OrigID;

    FOR
      SELECT GEN_ID(gd_g_contact_virt_id, -1), c.name, c.id, c.parent, 2
      FROM gd_contact c
        JOIN gd_contactlist l ON l.contactkey=c.id AND l.groupkey=:GK
      WHERE c.contacttype=2 AND (NOT c.disabled=1)
      INTO :id, :name, :origid, :origparent, :contacttype
    DO BEGIN
      SUSPEND;
    END
  END

  IF (:id < 1000000000) THEN
  BEGIN
    FOR
      SELECT GEN_ID(gd_g_contact_virt_id, 1147483646)
      FROM rdb$database
      INTO :id
    DO BEGIN
      id = 1;
    END
  END
END
^
*/

SET TERM ; ^

/* ������ ������ ����������� �������� � �������� � ��� �������� */

CREATE TABLE gd_holding (
  holdingkey dintkey NOT NULL,
  companykey dintkey NOT NULL);

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
