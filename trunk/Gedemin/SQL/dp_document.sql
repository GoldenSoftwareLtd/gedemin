
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    dp_document.sql

  Abstract

    ��������� ��� ������� Department.

  Author

    Anton Smirnov (15.12.2000)
    Teryokhina Julia

  Revisions history

    Initial  16.12.2000  SAI    Initial version
             11.01.2002  Julie  Modification   

  Status

    Draft

*/

ALTER TABLE bn_destcode ADD
  desttype dinteger DEFAULT 0;

/*
  1. ���������� ������
  2. �����������, ������������
  3. ��������
  0. ������
*/

/* ��� ����� � ������  */

CREATE TABLE dp_inventory
(
  documentkey	     dintkey,	/*  ���������� ����.           */
  incomedate         ddate,     /* ���� ��������� � ����� ����������� */
  decreekey          dintkey,   /* ������ �� ���� */
  authoritykey       dintkey,   /* ������ �� �������������� ����� */
  contactkey         dforeignkey, /* �����������, � ��� ������������ */
  accountkey         dforeignkey  /* �.�. ������������ */
);

ALTER TABLE dp_inventory
  ADD CONSTRAINT dp_pk_inventory PRIMARY KEY (documentkey);

ALTER TABLE dp_inventory ADD CONSTRAINT dp_fk_inv_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE dp_inventory ADD CONSTRAINT dp_fk_inv_decreekey
  FOREIGN KEY (decreekey) REFERENCES dp_decree(id);

ALTER TABLE dp_inventory ADD CONSTRAINT dp_fk_inv_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id);

ALTER TABLE dp_inventory ADD CONSTRAINT dp_fk_inv_authoritykey
  FOREIGN KEY (authoritykey) REFERENCES dp_authority(companykey);

ALTER TABLE dp_inventory ADD CONSTRAINT dp_fk_inv_accountkey
  FOREIGN KEY (accountkey) REFERENCES gd_companyaccount(id);


/* ���� �������� ��������� � ���������� ��� ���� ������������� */

CREATE TABLE dp_transfer
(
  documentkey	     dintkey,	/*  ���������� ����.           */
  assetdestkey       dintkey,  /* ��� ��������� */
  companykey         dintkey,
  inventorykey       dintkey,
  sumncustart        dcurrency  /* ��� ����� ��������, �� ��� */
);

ALTER TABLE dp_transfer
  ADD CONSTRAINT dp_pk_transfer PRIMARY KEY (documentkey);

ALTER TABLE dp_transfer ADD CONSTRAINT dp_fk_transfer_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE dp_transfer ADD CONSTRAINT dp_fk_transfer_assetdestkey
  FOREIGN KEY (assetdestkey) REFERENCES dp_assetdest(id);

ALTER TABLE dp_transfer ADD CONSTRAINT dp_fk_transfer_companykey
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey);

ALTER TABLE dp_transfer ADD CONSTRAINT dp_fk_tran_inventorykey
  FOREIGN KEY (INVENTORYKEY) REFERENCES dp_inventory(documentkey);

/* ��� ���������� */

CREATE TABLE dp_revaluation
(
  documentkey	     dintkey,	/*  ���������� ����.           */
  transferkey        dintkey,   /* ��� �������� */
  sumncuadd          dcurrency,
  sumncudel          dcurrency
);

ALTER TABLE dp_revaluation
  ADD CONSTRAINT dp_pk_revaluation PRIMARY KEY (documentkey);

ALTER TABLE dp_revaluation ADD CONSTRAINT dp_fk_rev_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE dp_revaluation ADD CONSTRAINT dp_fk_rev_transferkey
  FOREIGN KEY (transferkey) REFERENCES dp_transfer(documentkey);

/* ��� �������� ������� */

CREATE TABLE dp_withdrawal
(
  documentkey     dintkey,
  authoritykey    dintkey,
  contactkey      dforeignkey
);

ALTER TABLE dp_withdrawal
  ADD CONSTRAINT dp_pk_withdrawal PRIMARY KEY (documentkey);

ALTER TABLE dp_withdrawal ADD CONSTRAINT dp_fk_wthd_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE dp_withdrawal ADD CONSTRAINT dp_fk_wthd_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id);

ALTER TABLE dp_withdrawal ADD CONSTRAINT dp_fk_wthd_authoritykey
  FOREIGN KEY (authoritykey) REFERENCES dp_authority(companykey);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER dp_bi_rev FOR dp_revaluation
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.SUMNCUADD IS NULL) THEN
    NEW.SUMNCUADD = 0;
  IF (NEW.SUMNCUDEL IS NULL) THEN
    NEW.SUMNCUDEL = 0;
END
^

CREATE TRIGGER dp_bu_rev FOR dp_revaluation
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.SUMNCUADD IS NULL) THEN
    NEW.SUMNCUADD = 0;
  IF (NEW.SUMNCUDEL IS NULL) THEN
    NEW.SUMNCUDEL = 0;
END
^


CREATE PROCEDURE DP_CALC_DEBTS_FOR_ACTS (
    INVENTORYKEY INTEGER,
    SUMNCU DECIMAL (15, 4))
RETURNS (
    HAS_DEBTS DOUBLE PRECISION)
AS
  DECLARE VARIABLE tempsumncu DOUBLE precision;
BEGIN
  has_debts = sumncu;
  
  SELECT SUM(r.sumncuadd - r.sumncudel)
  FROM dp_revaluation r
  JOIN dp_transfer t ON r.transferkey = t.documentkey
  WHERE
    t.inventorykey = :inventorykey
  INTO :tempsumncu;
  
  IF (tempsumncu IS NOT NULL) THEN
    has_debts = has_debts + tempsumncu;
    
  SELECT SUM(bsld.sumncu)
  FROM dp_transfer t
  JOIN bn_bslinedocument bsld ON bsld.documentkey = t.documentkey
  WHERE
    t.inventorykey = :inventorykey
  INTO :tempsumncu;

  IF (tempsumncu IS NOT NULL) THEN
    has_debts = has_debts - tempsumncu;
    
  SUSPEND;
END
^


SET TERM ; ^

COMMIT;

