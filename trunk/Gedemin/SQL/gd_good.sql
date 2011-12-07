
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

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

   ������� ��� �������� ����� �������.

*****************************************************/

CREATE TABLE gd_goodgroup
(
  id               dintkey,                     /* ��������� ����          */
  parent           dparent,                     /* ��������                */
  lb               dlb,                         /* ����� �������           */
  rb               drb,                         /* ������ �������          */

  name             dname,                       /* ���                     */
  alias            dnullalias,                  /* ��� ������              */
  description      dblobtext80_1251,            /* ��������                */

  creatorkey       dforeignkey,
  creationdate     dcreationdate,

  editorkey        dforeignkey,                 /* ���         ������� ������ */
  editiondate      deditiondate,                /* �����      �������� ������ */

  disabled         ddisabled,                   /* ��������                */
  reserved         dreserved,                   /* ���������������         */

  afull            dsecurity,                   /* ������ ����� �������    */
  achag            dsecurity,                   /* ��������� ����� ������� */
  aview            dsecurity                    /* ��������� ����� ������� */
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

/*
ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_chk_goodgroup_tree_limit
  CHECK ((lb <= rb) or ((rb is NULL) and (lb is NULL)));

CREATE DESC INDEX gd_x_goodgroup_rb
  ON gd_goodgroup(rb);

CREATE ASC INDEX gd_x_goodgroup_lb
  ON gd_goodgroup(lb);
*/

COMMIT;


COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_goodgroup FOR gd_goodgroup
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* ���� ���� �� ��������, ����������� */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*
CREATE TRIGGER gd_bi_goodgroup_2 FOR gd_goodgroup
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
    FROM GD_GOODGROUP C
    WHERE C.ID = NEW.Parent
    INTO :AFULL, :ACHAG, :AVIEW;
    NEW.AFULL = g_b_or(g_b_and(NEW.AFULL, :AFULL), 1);
    NEW.ACHAG = g_b_or(g_b_and(NEW.ACHAG, :ACHAG), 1);
    NEW.AVIEW = g_b_or(g_b_and(NEW.AVIEW, :AVIEW), 1);
  END
END
^
*/

SET TERM ; ^

COMMIT;

/****************************************************

   ������� ��� �������� ������ ���������.

*****************************************************/

CREATE TABLE gd_value
(
  id            dintkey,        /* ��������� ����                  */
  name          dname,          /* ������������                    */
  description   dtext80,        /* ��������                        */
  goodkey       dforeignkey,    /* ������ �� ��� �� ������ ��.���. */
  ispack        dboolean        /* ������������ ��� ��������       */
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

   ������� ��� �������� ����������� ����.

*****************************************************/

CREATE TABLE gd_tnvd
(
  id            dintkey,        /* ��������� ����               */
  name          dname,          /* ������������                 */
  description   dtext180        /* ��������                     */
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

   ������� ��� �������� �������.

*****************************************************/

CREATE TABLE gd_good
(
  id               dintkey,                     /* ��������� ����             */
  groupkey         dmasterkey,                  /* �������������� � ������    */
  name             dname,                       /* ���                        */
  alias            dnullalias,                  /* ���� ������                */
  shortname        dtext40,                     /* ������� ������������       */
  description      dtext180,                    /* ��������                   */

  barcode          dbarcode,                    /* ����� ���                  */
  valuekey         dintkey,                     /* ������� ������� ���������  */
  tnvdkey          dforeignkey,                 /* ������ �� ��� ����         */
  discipline       daccountingdiscipline,       /* ��� ����� ���              */                  

  isassembly       dboolean,                    /* �������� �� ����������     */

  creatorkey       dforeignkey,
  creationdate     dcreationdate,

  editorkey        dforeignkey,                 /* ���         ������� ������ */
  editiondate      deditiondate,                /* �����      �������� ������ */

  reserved         dreserved,                   /* ����������������           */
  disabled         ddisabled,                   /* ���������                  */

  afull            dsecurity,                   /* ������ ����� �������       */
  achag            dsecurity,                   /* ��������� ����� �������    */
  aview            dsecurity                    /* ��������� ����� �������    */
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

SET TERM ; ^

COMMIT;

/****************************************************

   ������� ��� �������� ����������.

*****************************************************/

CREATE TABLE gd_goodset
(
  goodkey       dintkey,        /* ������ �� �����(��������)    */
  setkey        dintkey,        /* ������ �� ��������           */
  goodcount     dpositive       /* ���������� ������            */
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

   ������� ��� �������� � ������ �������������� ������ ���������.

*****************************************************/

CREATE TABLE gd_goodvalue
(
  goodkey       dintkey,        /* ������ �� �����              */
  valuekey      dintkey,        /* ������ �� ������� ���������  */
  scale         dpercent,       /* ����������� ���������        */
  discount      dcurrency,      /* ������ �� �����              */
  decdigit      ddecdigits      /* ���������� ����������        */
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

   ������� ��� �������� �������.

*****************************************************/

CREATE TABLE gd_tax
(
  id            dintkey,        /* ���� ����������              */
  name          dname,          /* ������������                 */
  shot          dtext20,        /* ������������ ����������      */
  rate          dtax            /* ������                       */
);

ALTER TABLE gd_tax ADD CONSTRAINT gd_pk_tax
  PRIMARY KEY (id);

COMMIT;

CREATE UNIQUE INDEX gd_x_tax_name ON gd_tax
  /*COMPUTED BY (UPPER(name));*/
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
      
END;^

SET TERM ; ^

COMMIT;

/****************************************************

   ������� ��� �������� � �������.

*****************************************************/

CREATE TABLE gd_goodtax
(
  goodkey       dintkey,        /* ������ �� �����              */
  taxkey        dintkey,        /* ������ �� �����              */
  datetax       ddate NOT NULL,  /* ���� �������� ������         */
  rate          dcurrency       /* ������                       */
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

   ������� ��� ��������������� �����-�����.

*****************************************************/

CREATE TABLE gd_goodbarcode
(
  id            dintkey,           /* ���� ����������              */
  goodkey       dintkey,           /* ������ �� �����              */
  barcode       dbarcode NOT NULL, /* ����� ���                    */
  description   dtext180           /* ��������                     */
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

   ������� ��� �������� ����. ��������.

*****************************************************/

CREATE TABLE gd_preciousemetal
(
  id            dintkey,        /* ���� ����������              */
  name          dname,          /* ������������                 */
  description   dtext180        /* �������� */
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

   ������� ��� �������� �����������.

*****************************************************/

CREATE TABLE gd_goodprmetal
(
  goodkey       dintkey,          /* ������ �� �����              */
  prmetalkey    dintkey,          /* ������ �� ����������         */
  quantity      dgoldquantity DEFAULT 0 /* ����������                   */
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