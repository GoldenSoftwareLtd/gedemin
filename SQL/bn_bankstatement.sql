
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    bn_bankstatement.sql

  Abstract

    ���������� �������

  Author

    Anton Smirnov,
    Julia Teryokhina

  Revisions history

    Initial  09.08.2000  SAI    Initial version
             11.01.2002  Julie  Modification

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

/*
 *
 *   ���������� �������
 *
 *   ��������, �� ������ � ������� ����� �� ������ � ������� ����
 *   ������� �������, � ����� ���������� �����.
 *   ������ �������� ����������� ����� ������� ���������.
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
  rate                 dcurrency, /* ���� �������� ������� */ 

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
 *   ������� ���������� �������
 *
 */

CREATE TABLE bn_bankstatementline
(
  id                   dintkey,      /* �������� ������������� ����� �����      */

  documentkey          dforeignkey,  /* ��������� ���������� ��� ���������          */
                                     /* ��� ���, ��� ������ ��������, ������� �����-*/
                                     /* ��� � ������� �������                       */
  bankstatementkey     dmasterkey,   /* �������� �� ������                         */
  trtypekey            dforeignkey,  /* ������ �� ��������                          */

  companykey           dforeignkey,  /* ������, �������� ���������� ��� ����������  */
                                     
  dsumncu              dcurrency,    /* �����, ���� � ���                           */
  dsumcurr             dcurrency,    /* �����, ���� � ������                        */

  csumncu              dcurrency,    /* ������, ���� � ���                         */
  csumcurr             dcurrency,    /* ������, ���� � ������                      */
                                     /* �������, ��� ���� ������ ��������� ��      */
                                     /* �������, �� ��� ���� ������               */

                                     /* ��� ��������� ��� ���������� �������:       */
  paymentmode          dtext8,       /* ����� ��������                              */
  operationtype        dtext8,       /* ��� ��������                                */

                                     /* ��������� ��� ���� � �������� �������:      */
  account              dbankaccount, /* ���������� ���� �������                     */
  bankcode             dbankcode,    /* ��� ����� �������                           */
  bankbranch           dbankcode,    /* ����� ��������� ����� */	
  docnumber            dtext20,      /* ����� ���������(��������)                   */

  comment              dblobtext80_1251,      /* ��������                                    */
                                     /* ��������, ���������� �������                */
  accountkey           dforeignkey,  /* ������ �� ac_account */

  /* ���������� ���� ���� ����� ���� �� �������, ����� ������ */
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

ALTER TABLE bn_bankstatementline ADD CONSTRAINT bn_fk_bsl_bankstatementkey
  FOREIGN KEY (bankstatementkey) REFERENCES bn_bankstatement(documentkey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

/*
ALTER TABLE bn_bankstatementline ADD CONSTRAINT bn_fk_bsl_trtypekey
  FOREIGN KEY (trtypekey) REFERENCES gd_listtrtype(id)
  ON UPDATE CASCADE;
*/


COMMIT;

SET TERM ^ ;

/*
  ����� ���������� ������� �� ������� ���� ��������
  ��������� �������� � ����� �������.
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
  number = case when NEW.docnumber IS NULL then '�\�' else NEW.docnumber end
  WHERE id = NEW.id;

END
^

/*
  ����� �������� ������� �� ������� ���� �������� �������� ��������
  � ����� �������.
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
  IF (OLD.dsumncu IS NULL) THEN
    old_dsumncu = 0;
  ELSE
    old_dsumncu = OLD.dsumncu;

  IF (OLD.csumncu IS NULL) THEN
    old_csumncu = 0;
  ELSE
    old_csumncu = OLD.csumncu;

  IF (OLD.dsumcurr IS NULL) THEN
    old_dsumcurr = 0;
  ELSE
    old_dsumcurr = OLD.dsumcurr;

  IF (OLD.csumcurr IS NULL) THEN
    old_csumcurr = 0;
  ELSE
    old_csumcurr = OLD.csumcurr;

  UPDATE bn_bankstatement
    SET linecount = linecount - 1,
        dsumncu = dsumncu - :old_dsumncu,
        csumncu = csumncu - :old_csumncu,
        dsumcurr = dsumcurr - :old_dsumcurr,
        csumcurr = csumcurr - :old_csumcurr
    WHERE documentkey = OLD.bankstatementkey;

    /*
  DELETE FROM gd_entrys WHERE documentkey = OLD.bankstatementkey AND
      positionkey = OLD.id;
    */  

END
^

/*

  ������ ��������� ��������� ����������� ��������� ��������
  ��� ������� �������� ������.

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

  ������ ��������� ������������� ��������� �������� ��� ���� �������.

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

  ����� ��������� ������ �� ������� ����������� ��������� �������� ���
  ���� �������.

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
  number = case when NEW.docnumber IS NULL then '�\�' else NEW.docnumber end
  WHERE id = NEW.id;

END
^

SET TERM ; ^

/*

  ������ ������� ��������� ��������� ���������. ��������, ����������
  ����� �� ����������. ���� ��� ���� �������, �� ���������� � ������� �����
  ��������. � ������� ������� ����� ���� ������� �� ��� �����. ���
  ���� ������� ��� ������ ������� � ����������� �� ������� ������ ��������.

  ��� ����� ������ ������� bn_bslinedocument

*/

/*CREATE TABLE bn_bslinedocument
(
  bslinekey            dintkey,
  documentkey          dintkey,
  sumncu               dcurrency,
  sumcurr              dcurrency */ /* ������ ��������� � ������� �������, � ������������� */
                                  /* � ������� �����, �� �������� �������� �������       */
/*);

COMMIT;*/

/* ������ ������� ����� ���� ��������� ������ �� ������ ���� */
/*ALTER TABLE bn_bslinedocument
  ADD CONSTRAINT bn_pk_bslinedocument PRIMARY KEY (bslinekey);

ALTER TABLE bn_bslinedocument ADD CONSTRAINT bn_fk_bsld_bslinekey
  FOREIGN KEY (bslinekey) REFERENCES bn_bankstatementline(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE bn_bslinedocument ADD CONSTRAINT bn_fk_bsld_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;*/

SET TERM ^ ;

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

  ���������. ���� ����������� ���������, ��� ����������� � �����,
  ��� ����� ��������. �� ������� ���������� �����, ���� ���� �����
  ���������.

  �������� ���������� � ������ ��_�����������, ������� -- �
  ������ ��_���������������.

  � ��_����������� �� �������� �������� �������� �� �������.

***********************************************************/

CREATE TABLE bn_bankcatalogue
(
  documentkey          dintkey,                      /* �������� �� ��������       */
  accountkey           dintkey,                      /* �������� �� �������        */
  cataloguetype        dtext8,                       /* �� ��������, �1, �2...   */
  sumncu               dcurrency DEFAULT 0 NOT NULL, /* ���� �� ���������          */
  sumcurr              dcurrency DEFAULT 0 NOT NULL  /* ���� �� ��������� � ������ */
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

  ������ ��������� ��������.

*/

CREATE TABLE bn_bankcatalogueline
(
  documentkey          dintkey,      /* �������� ������������� �����                 */
                                     /* �� �� �������� �� ��������                     */
  bankcataloguekey     dintkey,      /* �������� �� ���������                          */
                                     /* ������� �����, �� ����������� ����������      */
                                     /* ����������� ���� �������                       */
  companykey           dforeignkey,  /* ������, �������� ����������                    */
                                     /* ���� �� ���� ������ ������                     */
  linkdocumentkey      dforeignkey,  /* ��������� ���������� ��� ���������             */
                                     /* ��� ���, ��� ������ ��������, ������� �����-   */
                                     /* ��� � �������                                  */
                                     /* ������� ������������ �� ������ ��� �           */
                                     /* ����������, �.�. ������� ������� �� ���������  */

  sumncu               dcurrency,    /* ����� � ������                                 */
  sumcurr              dcurrency,    /* ����� � ������                                 */
                                     /* ���� ������ ��� �� �����������, ������ ��� ��� */
                                     /* ��������� � �����, � �� � ���������            */

  paymentdest          dalias,       /* ��� ���������� �������                         */
  acceptdate           ddate,        /* ���� �������                                   */
  fine                 dcurrency,    /* ����� ����                                     */

                                     /* ��������� ��� ���� � �������� �������:         */
  account              dbankaccount NOT NULL, /* ���������� ����                                */
  bankcode             dbankcode NOT NULL,    /* ��� �����                                      */
  docnumber            dtext20,      /* ����� ���������                                */
  queue                dqueue,       /* ����������� ������� */

  comment              dtext80,      /* ��������                                       */
                                     /* ��������, ���������� �������                   */

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

