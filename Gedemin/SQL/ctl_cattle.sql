
/*
 *
 *  ����� ������ ������������, ����������� ���
 *  ���������� ��������� � ��������� ������������
 *  �����.
 *
 */

CREATE TABLE ctl_reference (
  id             dintkey,                         /* ������������� */
  parent         dforeignkey,                     /* ������������ ����� */

  name           dname,                           /* ����� ��������� */
  alias          dalias,                          /* ������� ������������ */
  description    dtext180,                        /* �������� */

  formula        dtext254,                        /* ������� ������� */

  afull          dsecurity,                       /* ����� ������� */
  achag          dsecurity,
  aview          dsecurity,

  disabled       dboolean DEFAULT 0,              /* �� ������������ */
  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_reference ADD CONSTRAINT ctl_pk_reference
  PRIMARY KEY (id);

ALTER TABLE ctl_reference ADD CONSTRAINT ctl_fk_reference_parent
  FOREIGN KEY (parent) REFERENCES ctl_reference (id)
  ON UPDATE CASCADE ON DELETE CASCADE;

COMMIT;

/*
 *
 *  �������� ��������� �� ������������� �����
 *
 */

CREATE TABLE ctl_receipt (
  documentkey    dintkey,                         /* ���� ��������� */

  registersheet  dtext20,                         /* �������� ��������� */

/*  oncosts        dcurrency,  */                     /* ��������������-��������� ������� */

  sumtotal       dcurrency,                       /* ����� */
  sumncu         dcurrency,                       /* ����� � ������ */

  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_receipt ADD CONSTRAINT ctl_pk_receipt
  PRIMARY KEY (documentkey);

ALTER TABLE ctl_receipt ADD CONSTRAINT ctl_fk_receipt_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON UPDATE CASCADE 
  ON DELETE CASCADE;

COMMIT;

/*
 *
 *  ����� ��� ����������� ���� �������:
 *  G - �����������, C - ������� ��������, P - ��������� �������
 *
 */

CREATE DOMAIN dcattlepurchase
  AS VARCHAR(1)
  CHECK (VALUE IN ('G', 'C', 'P'));

/*
 *
 *  ��� ��������: C - �����������, S - ���������,
 *  P - ��������� ������������ ����
 *
 */

CREATE DOMAIN ddeliverykind
  AS VARCHAR(1)
  CHECK (VALUE IN ('C', 'S', 'P'));

/*
 *
 *  ��� ���������:
 *  C - �� ����, M - �� ����,
 *
 */

CREATE DOMAIN dcattleinvoicekind
  AS VARCHAR(1)
  CHECK (VALUE IN ('C', 'M'));

/*
 *
 *  �����-��������� �� ������������� �����
 *
 */

CREATE TABLE ctl_invoice(
  documentkey    dintkey,                         /* ���� ��������� */
  receiptkey     dforeignkey,                     /* []���� ��������� */

  ttnnumber      dtext20,                         /* ����� ��� */

  kind           dcattleinvoicekind,              /* ��� ���������: ����, ���� */

  departmentkey  dintkey,                         /* []������������� */
  purchasekind   dcattlepurchase,                 /* ��� �������: ���-��, ���������, ������� */

  supplierkey    dintkey,                         /* []��������� */
  facekey        dforeignkey,                     /* []���������� ���� */
  deliverykind   ddeliverykind,                   /* ��� ��������: �����������, ���������, ��������� ������������ ���� */

  receivingkey   dintkey,                         /* []��� ������� */
  forceslaughter dboolean,                        /* ����������� ���� */
  wastecount     dinteger,                        /* ���-�� ����������� ����� */

  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_pk_invoice
  PRIMARY KEY (documentkey);

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_document
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON UPDATE CASCADE 
  ON DELETE CASCADE;

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_receipt
  FOREIGN KEY (receiptkey) REFERENCES ctl_receipt (documentkey)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_department
  FOREIGN KEY (departmentkey) REFERENCES gd_contact (id);

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_supplier
  FOREIGN KEY (supplierkey) REFERENCES gd_contact (id);

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_face
  FOREIGN KEY (facekey) REFERENCES gd_contact (id);

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_receiving
  FOREIGN KEY (receivingkey) REFERENCES ctl_reference (id);

COMMIT;

/*
 *
 *  ������� �����-��������� �� �������
 *  �����
 *
 */

CREATE TABLE ctl_invoicepos(
  id             dintkey,                         /* ������������� */

  invoicekey     dintkey,                         /* []���� ��������� */
  goodkey        dintkey,                         /* []���, ������, ����������� */

  quantity       dinteger,                        /* ���������� �����*/

  /* ������������ ��������: liveweight, realweight */
  /* ������������ ����: meatweight, realweight */

  meatweight     dcurrency,                       /* ����� ��� ���� */
  liveweight     dcurrency,                       /* ����� ��� ����� */
  realweight     dcurrency,                       /* ����� ��� �� ������� ������ */

  destkey        dintkey,                         /* []���������� */

  pricekey       dforeignkey,                     /* []���� �����-����� */
  price          dcurrency,                       /* ���� */
  sumncu         dcurrency,                       /* ����� */

  afull          dsecurity,                       /* ����� ������� */
  achag          dsecurity,
  aview          dsecurity,

  disabled       dboolean DEFAULT 0,              /* �� ������������ */
  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_invoicepos ADD CONSTRAINT ctl_pk_invoicepos
  PRIMARY KEY (id);

ALTER TABLE ctl_invoicepos ADD CONSTRAINT ctl_fk_invoicepos_invoice
  FOREIGN KEY (invoicekey) REFERENCES ctl_invoice (documentkey)
  ON UPDATE CASCADE 
  ON DELETE CASCADE;

ALTER TABLE ctl_invoicepos ADD CONSTRAINT ctl_fk_invoicepos_good
  FOREIGN KEY (goodkey) REFERENCES gd_good (id);

ALTER TABLE ctl_invoicepos ADD CONSTRAINT ctl_fk_invoicepos_dest
  FOREIGN KEY (destkey) REFERENCES ctl_reference (id);

COMMIT;

/*
 *
 *  ������� ������/������� �� ������������
 *  ������ �����.
 *
 */


CREATE TABLE ctl_discount(
  goodkey        dintkey,                         /* ���� ������ ����� */

  discount       dpercent,                        /* ������� ������ ��� �������� �� ���� � ����� ��� */

  minweight      dcurrency,                       /* ����������� ��� */
  maxweight      dcurrency,                       /* ������������ ��� */

  coeff          dcurrency,                       /* ����� ��������� �� ��� ���� � ���� */

  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_discount ADD CONSTRAINT ctl_pk_discount_goodkey
  PRIMARY KEY (goodkey);

COMMIT;

ALTER TABLE ctl_discount ADD CONSTRAINT ctl_fk_discount_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON UPDATE CASCADE 
  ON DELETE CASCADE;

COMMIT;


/*
 *  ����������
 */

CREATE DOMAIN ddistance
  AS DECIMAL(15, 4);

/*
 *  ����� �����
 */

CREATE DOMAIN dcargoclass
  AS SMALLINT;

/*
 *
 *  ������� ������������� �������
 *  ��� ����������� ������������ ��������.
 *
 */

CREATE TABLE ctl_autotariff(
  cargoclass     dcargoclass NOT NULL,            /* ����� ����� */
  distance       ddistance NOT NULL,              /* ���������� */

  tariff_500     dpositive,                       /* ����� �� 500 �� */
  tariff_1000    dpositive,                       /* ����� �� 1000 �� */
  tariff_1500    dpositive,                       /* ����� �� 1500 �� */
  tariff_2000    dpositive,                       /* ����� �� 2000 �� */
  tariff_5000    dpositive,                       /* ����� �� 5000 �� */
  tariff_S5000   dpositive,                       /* ����� ����� 5000 �� */

  reserved       dinteger                         /* ��������������� */
);

COMMIT;

ALTER TABLE ctl_autotariff ADD CONSTRAINT ctl_pk_autotariff
  PRIMARY KEY (cargoclass, distance);

COMMIT;


SET TERM ^ ;


/*
 *
 *  �������� �� ������� ctl_reference.
 *
 */

CREATE TRIGGER ctl_bi_reference FOR ctl_reference
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*
 *
 *  �������� �� ������� ctl_receipt
 *
 */

CREATE EXCEPTION ctl_e_period_locked 'Period zablokirovan'
^

COMMIT
^

CREATE TRIGGER ctl_bd_receipt FOR ctl_receipt
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_document WHERE id = OLD.documentkey
    AND documentdate < '01.04.2002')) THEN
  BEGIN
    EXCEPTION ctl_e_period_locked;
  END


  DELETE FROM gd_document WHERE id = OLD.documentkey;
END
^

CREATE TRIGGER ctl_bu_receipt FOR ctl_receipt
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_document WHERE id = OLD.documentkey
    AND documentdate < '01.04.2002')) THEN
  BEGIN
    EXCEPTION ctl_e_period_locked;
  END
END
^


/*
 *
 * �������� �� ������� ctl_invoice
 *
 */


/*

���� ������ ��������� �������� -- �������� �������� ����� � ����� ���������.

CREATE EXCEPTION ctl_e_delete_invoice 'Can not delete invoice. It is used in receipt!'
^

*/

CREATE TRIGGER ctl_bd_invoice FOR ctl_invoice
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_document WHERE id = OLD.documentkey
    AND documentdate < '01.04.2002')) THEN
  BEGIN
    EXCEPTION ctl_e_period_locked;
  END


  DELETE FROM gd_document WHERE id = OLD.documentkey;
  DELETE FROM gd_document WHERE id = OLD.receiptkey;

  /*
  IF (EXISTS (SELECT DOCUMENTKEY FROM CTL_RECEIPT WHERE
    DOCUMENTKEY = OLD.RECEIPTKEY))
  THEN
    EXCEPTION ctl_e_delete_invoice;
  */
END
^

CREATE TRIGGER ctl_bu_invoice FOR ctl_invoice
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_document WHERE id = OLD.documentkey
    AND documentdate < '01.04.2002')) THEN
  BEGIN
    EXCEPTION ctl_e_period_locked;
  END
END
^


CREATE TRIGGER ctl_au_invoice FOR ctl_invoice
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  DELETE FROM gd_document WHERE id = OLD.receiptkey;
END
^


/*
 *
 *  �������� �� ������� ctl_invoicepos
 *
 */


CREATE TRIGGER ctl_bi_invoicepos FOR ctl_invoicepos
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*
  ������ ��������� ��������� �� ���� �����-��������� �
  ���������� ���������� ���� ���� � ���� ������ �� �������
  �� ������������.

  ��������! ��������� ��� �� �����������, ��� ��� �� ����� �������
  � ����� ����������� ����������� ������.
*/


CREATE PROCEDURE CTL_P_RECALCWEIGHT 
AS
  DECLARE VARIABLE kind       VARCHAR(1);
  DECLARE VARIABLE coeff      DECIMAL(15, 4);
  DECLARE VARIABLE meatweight DECIMAL(15, 4);
  DECLARE VARIABLE realweight DECIMAL(15, 4);
  DECLARE VARIABLE id         INTEGER;
BEGIN
  FOR
    SELECT
      i.kind,
      d.coeff,
      ip.meatweight,
      ip.realweight,
      ip.id
    FROM
      ctl_invoice i
        JOIN ctl_invoicepos ip ON i.documentkey = ip.invoicekey
        JOIN ctl_discount d ON ip.goodkey = d.goodkey
    INTO
      :kind, :coeff, :meatweight, :realweight, :id
  DO
  BEGIN
    IF (kind = 'M') then
      UPDATE ctl_invoicepos
      SET realweight = g_m_Round(:meatweight / :coeff + 0.000001), liveweight = 0
      WHERE id = :id;
    ELSE
      UPDATE ctl_invoicepos
      SET meatweight = g_m_Round(:realweight * :coeff + 0.000001)
      WHERE id = :id;
  END
END
^

SET TERM ; ^