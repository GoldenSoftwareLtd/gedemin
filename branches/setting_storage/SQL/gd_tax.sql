
/*

  Copyright (c) 2000 by Golden Software of Belarus

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

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/****************************************************

   ������� ��� ������� ������� ������� �����������

*****************************************************/

/* ������� ����� ������� ����������� */

CREATE TABLE gd_taxtype
(                               
  id       dintkey  PRIMARY KEY,
  name     dname
 );

COMMIT;

CREATE UNIQUE INDEX gd_idx_taxtype ON gd_taxtype
  /*COMPUTED BY (UPPER(name));*/
  (name);

COMMIT;

INSERT INTO gd_taxtype(id, name)
  VALUES (350001, '�� �����');

INSERT INTO gd_taxtype(id, name)
  VALUES (350002, '�� �������');

INSERT INTO gd_taxtype(id, name)
  VALUES (350003, '�� ������');

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

/* ������� ���� ���.������� */
CREATE TABLE GD_TAXNAME (
    ID              DINTKEY,
    NAME            DNAME,
    TRANSACTIONKEY  DFOREIGNKEY NOT NULL,
    ACCOUNTKEY      DFOREIGNKEY NOT NULL
);
COMMIT;
ALTER TABLE GD_TAXNAME ADD PRIMARY KEY (ID);
ALTER TABLE GD_TAXNAME ADD CONSTRAINT FK_GD_TAXNAME FOREIGN KEY (TRANSACTIONKEY) REFERENCES AC_TRANSACTION (ID);
ALTER TABLE GD_TAXNAME ADD CONSTRAINT FK_GD_TAXNAME_ACCOUNTKEY FOREIGN KEY (ACCOUNTKEY) REFERENCES AC_ACCOUNT (ID);
COMMIT;
CREATE UNIQUE INDEX GD_IDX_TAXNAME ON GD_TAXNAME (NAME);
COMMIT;

/* ������� ������������ ������� */

CREATE TABLE GD_TAXACTUAL (
    ID              DINTKEY,
    TAXNAMEKEY      DINTKEY,
    ACTUALDATE      DDATE NOT NULL,
    REPORTGROUPKEY  DINTKEY,
    REPORTDAY       DSMALLINT NOT NULL,
    TYPEKEY         DINTKEY,
    DESCRIPTION     DTEXT120,
    TRRECORDKEY     DFOREIGNKEY NOT NULL
);

COMMIT;

ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT CHK_GD_TAXACTUAL_RD CHECK (0 < reportday AND reportday < 32);
ALTER TABLE GD_TAXACTUAL ADD PRIMARY KEY (ID);
ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT FK_GD_TAXACTUAL FOREIGN KEY (TAXNAMEKEY) REFERENCES GD_TAXNAME (ID) on update CASCADE;
ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT FK_GD_TAXACTUAL_T FOREIGN KEY (TYPEKEY) REFERENCES GD_TAXTYPE (ID) on update CASCADE;
ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT FK_GD_TAXACTUAL_TRG FOREIGN KEY (REPORTGROUPKEY) REFERENCES RP_REPORTGROUP (ID) on update CASCADE;
ALTER TABLE GD_TAXACTUAL ADD CONSTRAINT FK_GD_TAXACTUAL_TRRECORD FOREIGN KEY (TRRECORDKEY) REFERENCES AC_TRRECORD (ID) on update CASCADE;

COMMIT;

CREATE UNIQUE INDEX GD_IDX_TAXACTUAL ON GD_TAXACTUAL (TAXNAMEKEY, ACTUALDATE);

COMMIT;

/* ������� ��������� ��� �� ������ */

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

/* ������� ��������� ������� */

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



