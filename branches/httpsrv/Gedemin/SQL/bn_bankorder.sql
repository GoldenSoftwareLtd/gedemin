
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    bn_bankorder.sql

  Abstract

    ������� ����������-�������� ����� ��� �������������
    ������������ �������� � ������������ ��������� ����������.

  Author

    Denis Romanovski

  Revisions history

    Initial  30.11.2000  Dennis    Initial version
    Modification 24.07.2001 Julia

*/

/*
 *   ������_� ������_����� �������.
 *   ��������������� � ��������� �����������.
 *
 */

CREATE TABLE bn_wording
(
  id         dintkey,
  text       dtext180 NOT NULL
);

ALTER TABLE bn_wording
  ADD CONSTRAINT bn_pk_wording PRIMARY KEY (id);


/*
 *
 *  ���� ���������� ��������� ��������
 *
 */

CREATE TABLE bn_destcode
(
  id                dintkey,      /* ���������� �������������  */
  code              dtext20,      /* ��� ���������� */
  description       dtext180,      /* �������� ���������� */

/*  afull             dsecurity,
  achag             dsecurity,
  aview             dsecurity,*/

  disabled          dboolean DEFAULT 0,
  reserved          dinteger
);

ALTER TABLE bn_destcode
  ADD CONSTRAINT bn_pk_destcode PRIMARY KEY (id);

/* ����� ��� ���� ��������� 
 * C - (common) - �����
 * P - (pressing) - �������
 */

CREATE DOMAIN dpaymentkind AS 
VARCHAR(1)
CHECK ((VALUE IS NULL) OR (VALUE = 'C') OR (VALUE = 'P'));

/* ����� ��� �������� �� �������� 
 * P - (payer) - ����������,
 * B - (beneficiary) - ����������,
 * O - (other) - ������
 */

CREATE DOMAIN dexpenseaccount AS 
VARCHAR(1)
CHECK ((VALUE IS NULL) OR (VALUE = 'P') OR (VALUE = 'B') OR (VALUE = 'O'));


/* ����� ��� ������� 
 * 0 - ��� �������,
 * 1 - � ��������
 */

CREATE DOMAIN daccept AS 
VARCHAR(1)
CHECK ((VALUE IS NULL) OR (VALUE = '0') OR (VALUE = '1'));


/*
 *
 *  ����� ������� ��� ��������� ���������,
 *  ��������� ����������, ����������-���������.
 *
 */

CREATE TABLE bn_demandpayment
(
  /* ����� ����� */
  documentkey       dintkey,      /* ������ �� ������� ����������  */
/*  companykey        dintkey,  */    /* ��������-���������� */
  accountkey        dintkey,      /* ��������� ���� ����������� */

  corrcompanykey    dintkey,      /* ���������������� ��������, � ������� ���� ������ */
  corraccountkey    dintkey,      /* ����������������� ���� */

  owncomptext       dtext180,     /* ����������� �������� (��������� ���-���) */

  owntaxid          dtext20,      /* ����������� ��� */
  owncountry        dtext20,      /* ������ */

  ownbanktext       dtext180,     /* ����� �������� ����� */
  ownbankcity       dtext20,      /* ����� */
  ownaccount        dbankaccount,      /* ���� */
  ownaccountcode    dtext20,      /* ��� ����� */


  corrcomptext      dtext180,     /* ����������������� �������� (��������� ���-���) */

  corrtaxid         dtext20,      /* ��� */
  corrcountry       dtext20,      /* ������ */

  corrbanktext      dtext180,     /* ����� �������� ����� */
  corrbankcity      dtext20,      /* ����� */
  corraccount       dbankaccount,      /* ���� */
  corraccountcode   dtext20,      /* ��� ����� */
  corrsecacc        dtext20,      /* ������ ���� */

  amount            dcurrency,    /* ����� �� ���������                                */
                                  /* �� ���������� ��������� ����� ��������� ��� ����� */
                                  /* ��������, ������ -- ����� �� ������ �����         */
                                  /* ������ �� ����� �� ������� ��� ���� �� sumncu, �  */
                                  /* amount -- ��� ����� �����                         */
                                  /* ������ ����� ��������� � ���� secondamount        */

  proc              dtext20,      /* ��� ��������� */
  oper              dtext20,      /* ��� �������� */
  queue             dqueue,       /* ����������� ������� */
  destcodekey       dforeignkey,  /* ���������� ������� (���) */
  destcode          dtext20,      /* ���������� ������� ����� */
  term              ddate,        /* ���� ������� */
  destination       dtext1024,    /* ���������� ������� */

  /* ����� �������� */
  secondaccountkey  dforeignkey,  /* ����������������� ���� ��� ���. ����� */
  secondamount      dcurrency,    /* ���. ����� �� ��������� */

  enterdate         dtext20,      /* ���� ��������� ������, �������� ������ ��� ��. ����� */
  specification     dtext60,      /* ��������� ������� (������� ������, � ���� ���������...) */
  percent           dpercent,     /* ������� ����  */

  /* ����� ���������� */
  cargosender       dtext180,     /* ���������������� */
  cargoreciever     dtext180,     /* ��������������� */
  contract          dtext40,      /* ������� �������� */
  paper             dtext60,      /* � ��������� �������� */
  cargosenddate     ddate,        /* ���� �������� */
  papersenddate     ddate,      /* ���� �������� ���������� */
/*  afull             dsecurity,    /* ������ ����� */
/*  achag             dsecurity,    /* ����� �� ��������� */
/*  aview             dsecurity,    /* ����� �� �������� */

  kind              dpaymentkind, /* ��� ���������: �������, ������� */
  expenseaccount    dexpenseaccount, 
                                  /* ������� �� ��������: �� ���� ����������� (P)
				   * �� ���� ����������� (B), 
                                   * ������ (O)
                                   */
  midcorrbanktext      dtext255,  /* ����� �������� �������������� ����� ����������, ��� ��������� */
  withacceptance       dboolean, 
  withaccept           daccept    /* � ��������(1) ��� ���(0), ��� ������ */ 

);


ALTER TABLE bn_demandpayment
  ADD CONSTRAINT bn_pk_pmntordr PRIMARY KEY (documentkey);

ALTER TABLE bn_demandpayment ADD CONSTRAINT bn_fk_pmntordr_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id) 
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE bn_demandpayment ADD CONSTRAINT bn_fk_dmndpmt_accountkey
  FOREIGN KEY (accountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_demandpayment ADD CONSTRAINT bn_fk_dmndpmt_corrcompanykey
  FOREIGN KEY (corrcompanykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE bn_demandpayment ADD CONSTRAINT bn_fk_dmndpmt_corraccountkey
  FOREIGN KEY (corraccountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_demandpayment ADD CONSTRAINT bn_fk_dmndpmt_secondaccountkey
  FOREIGN KEY (secondaccountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_demandpayment ADD CONSTRAINT bn_fk_dmndpmt_destcodekey
  FOREIGN KEY (destcodekey) REFERENCES bn_destcode(id)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER bn_bi_destcode FOR bn_destcode
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER bn_bi_wording FOR bn_wording
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

