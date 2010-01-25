
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    bn_currcommission.sql

  Abstract

    ��������� �� ������� ������

  Author

    Anton Smirnov

  Revisions history

    Initial       09.02.2001  Anton    Initial version
    Modification  30.07.2001  Julia

*/

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

CREATE TABLE bn_currcommission
(
  documentkey       dintkey,      /* ������ �� ������� ����������  */
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

  amount            dcurrency,    /* ����� �� ��������� */
  destination       dtext1024,    /* ���������� ������� */
  kind              dpaymentkind, /* ��� ���������: �������, ������� */
  expenseaccount    dexpenseaccount, 
                                  /* ������� �� ��������: �� ���� ����������� (P)
				   * �� ���� ����������� (B), 
                                   * ������ (O)
                                   */
  midcorrbanktext   dtext255,     /* ����� �������� �������������� ����� ����������, ��� ��������� */
  queue             dqueue,       /* ����������� ������� */
  destcodekey       dforeignkey,  /* ���������� ������� (���) */
  destcode          dtext20       /* ���������� ������� ����� */
);


ALTER TABLE bn_currcommission
  ADD CONSTRAINT bn_pk_currcommission PRIMARY KEY (documentkey);

ALTER TABLE bn_currcommission ADD CONSTRAINT bn_fk_cc_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id) 
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE bn_currcommission ADD CONSTRAINT bn_fk_cc_accountkey
  FOREIGN KEY (accountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_currcommission ADD CONSTRAINT bn_fk_cc_corrcompanykey
  FOREIGN KEY (corrcompanykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE;

ALTER TABLE bn_currcommission ADD CONSTRAINT bn_fk_cc_corraccountkey
  FOREIGN KEY (corraccountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_currcommission ADD CONSTRAINT bn_fk_currcomm_destcodekey
  FOREIGN KEY (destcodekey) REFERENCES bn_destcode(id)
  ON UPDATE CASCADE;

COMMIT;

/************************************************************************/
/*   ������� ������ ������� �� ������� ������                           */
/*   bn_currsellcontract                                                */
/************************************************************************/

CREATE TABLE bn_currsellcontract
(
  documentkey       dintkey,
  
  currkey           dintkey,      /*  ����������� ������   */ 
  amount            dcurrency,    /*  ����� ������         */
  minrate           dcurrency,    /*  ����������� ����     */

  bankkey           dintkey,      /*  ���� */
  bankaccountkey    dintkey,      /*  ���� ����� ��� �������������� */
  ownaccountkey     dintkey,      /* ���� ��� ���������� ������� � ��� */

  banktext          dtext180,     /*  ������������ �����            */
  bankcode          dtext20,      /*  ��� ����� */
   

  owncomptext       dtext180,     /* ����������� �������� (��������� ���-���) */
  owntaxid          dtext20,      /* ����������� ��� */
  owncountry        dtext20,      /* ������ */
  ownaccount        dtext20
);

COMMIT;

ALTER TABLE bn_currsellcontract ADD CONSTRAINT bn_pk_currsellcontract_doc
  PRIMARY KEY (documentkey);

ALTER TABLE bn_currsellcontract ADD CONSTRAINT bn_fk_currsellcontract_doc
  FOREIGN KEY (documentkey) REFERENCES gd_document(id) 
  ON UPDATE CASCADE
  ON DELETE CASCADE;
  
ALTER TABLE bn_currsellcontract ADD CONSTRAINT bn_fk_currsellcontract_curr
  FOREIGN KEY (currkey) REFERENCES gd_curr(id);

ALTER TABLE bn_currsellcontract ADD CONSTRAINT bn_fk_currsellcontract_bank
  FOREIGN KEY (bankkey) REFERENCES gd_bank(bankkey);

ALTER TABLE bn_currsellcontract ADD CONSTRAINT bn_fk_currsellcontract_bacc
  FOREIGN KEY (bankaccountkey) REFERENCES gd_companyaccount(id);

ALTER TABLE bn_currsellcontract ADD CONSTRAINT bn_fk_currsellcontract_acc
  FOREIGN KEY (ownaccountkey) REFERENCES gd_companyaccount(id);


COMMIT;

/************************************************************************/
/*   ��������� ������� ������                                           */
/*   bn_currcommisssell                                                  */
/************************************************************************/

CREATE TABLE bn_currcommisssell 
(
  documentkey       dintkey,

  bankkey           dintkey,       /*  ���� */  
  percent           dpercent,      /*  ������� �� �����      */
  amountcurr        dcurrency,     /*  ����� ������          */

  accountkey        dintkey,       /*  ���������� ����       */

  timeint           dinteger,      /*  � ������� ����        */
  compercent        dpercent,      /*  ������� ������������  */

  toaccountkey      dforeignkey,   /*  ���� ��� ����������   */

  tocurraccountkey  dforeignkey,   /*  ���� ��� ������, ���������� */
                                   /*  ����� ������������ �������  */

  datevalid         ddate          /*  ��������� ������������� ��  */         

);

COMMIT;

ALTER TABLE bn_currcommisssell ADD CONSTRAINT bn_pk_currcommisssell_doc
  PRIMARY KEY (documentkey);

ALTER TABLE bn_currcommisssell ADD CONSTRAINT bn_fk_currcommisssell_doc
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_currcommisssell ADD CONSTRAINT bn_fk_currcommisssell_acc
  FOREIGN KEY (accountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_currcommisssell ADD CONSTRAINT bn_fk_currcommisssell_toacc
  FOREIGN KEY (toaccountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_currcommisssell ADD CONSTRAINT bn_fk_currcommisssell_tocacc
  FOREIGN KEY (tocurraccountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

COMMIT;

/************************************************************************/
/*   ������ ������������� ������                                        */
/*   bn_currlistallocation                                               */
/************************************************************************/

CREATE TABLE bn_currlistallocation
(
  documentkey   dintkey,
  
  currkey       dforeignkey,
  amountcurr    dcurrency,
  dateenter     ddate,
  accountkey    dforeignkey,
   
  amountnotpay  dcurrency,
  amountpay     dcurrency,
  amountpayed   dcurrency,
  basetext      dtext180
);

COMMIT;

ALTER TABLE bn_currlistallocation ADD CONSTRAINT bn_pk_currlistallocation_doc
  PRIMARY KEY (documentkey);

ALTER TABLE bn_currlistallocation ADD CONSTRAINT bn_fk_currlistallocation_doc
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_currlistallocation ADD CONSTRAINT bn_fk_currlistallocation_curr
  FOREIGN KEY (currkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_currlistallocation ADD CONSTRAINT bn_fk_currlistallocation_acc
  FOREIGN KEY (accountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

COMMIT;

/************************************************************************/
/*   ������� �� ������� ������                                          */
/*   bn_currbuycontract                                                 */
/************************************************************************/

CREATE TABLE bn_currbuycontract
(
  documentkey    dintkey,
  
  currkey        dintkey,
  amountcurr     dcurrency,
  maxrate        dcurrency,
  amountncu      dcurrency,
  percent        dpercent,
  destination    dtext1024,

  accountkey     dforeignkey,

  corrcompkey    dforeignkey
  
);

COMMIT;

ALTER TABLE bn_currbuycontract ADD CONSTRAINT bn_pk_currbuycontract_doc
  PRIMARY KEY(documentkey);

ALTER TABLE bn_currbuycontract ADD CONSTRAINT bn_fk_currbuycontract_doc
  FOREIGN KEY(documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_currbuycontract ADD CONSTRAINT bn_fk_currbuycontract_curr
  FOREIGN KEY(currkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_currbuycontract ADD CONSTRAINT bn_fk_currbuycontract_comp
  FOREIGN KEY(corrcompkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_currbuycontract ADD CONSTRAINT bn_fk_currbuycontract_acc
  FOREIGN KEY(accountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;


COMMIT;

/************************************************************************/
/*   �������� �� ��������� ������                                       */
/*   bn_currconvcontract                                                */
/************************************************************************/

CREATE TABLE bn_currconvcontract
(
  documentkey     dintkey,

  fromcurrkey     dintkey,
  fromaccountkey  dintkey,
  fromamountcurr  dcurrency,
 
  tocurrkey       dintkey,
  toaccountkey    dintkey,
  toamountcurr    dcurrency,

  rate            dcurrency


);

COMMIT;

ALTER TABLE bn_currconvcontract ADD CONSTRAINT bn_pk_currconvcontract_doc
  PRIMARY KEY(documentkey);

ALTER TABLE bn_currconvcontract ADD CONSTRAINT bn_fk_currconvcontract_doc
  FOREIGN KEY(documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE bn_currconvcontract ADD CONSTRAINT bn_fk_currconvcontract_fcurr
  FOREIGN KEY(fromcurrkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_currconvcontract ADD CONSTRAINT bn_fk_currconvcontract_facc
  FOREIGN KEY(fromaccountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

  
ALTER TABLE bn_currconvcontract ADD CONSTRAINT bn_fk_currconvcontract_curr
  FOREIGN KEY(tocurrkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

ALTER TABLE bn_currconvcontract ADD CONSTRAINT bn_fk_currconvcontract_acc
  FOREIGN KEY(toaccountkey) REFERENCES gd_companyaccount(id)
  ON UPDATE CASCADE;

COMMIT;
