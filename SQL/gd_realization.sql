
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    gd_realization.sql

  Abstract

    ������� ��� ����� ���������� ������� � �����.

  Author

    Michael Shoihet (23 december 2000)

  Revisions history

    Initial  23.12.00  MSH    Initial version

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

/****************************************************/
/*       ������� ��� �������� ����� ������          */
/*       gd_price                                   */
/****************************************************/

CREATE TABLE gd_price(
  id               dintkey,                 /* ���������� ����                */
  name             dname,                   /* ������������ ������            */
  description      dtext180,                /* �������� ������                */
  relevancedate    ddate,                    /* ���� ������������ ������       */
  pricetype        dpricetype,              /* ��� ����� ����� P - ���������� */
                                            /*                 � - ���������� */
  contactkey       dforeignkey,                                          

  disabled         dboolean DEFAULT 0,      /* ��������                       */
  reserved         dinteger,                 /* ���������������                */

  afull            dsecurity,               /* ������ ����� �������           */
  achag            dsecurity,               /* ��������� ����� �������        */
  aview            dsecurity                /* ��������� ����� �������        */
);

COMMIT;

ALTER TABLE gd_price ADD CONSTRAINT gd_pk_price_id
  PRIMARY KEY(id);

ALTER TABLE gd_price ADD CONSTRAINT gd_fk_price_contactkey
  FOREIGN KEY(contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_price FOR gd_price
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

/****************************************************/
/*    ������� ��� ������� ����� ������              */
/*    gd_pricepos                                   */
/*    ������ ������� ��������� � �����������        */
/*    ������������ � ��� �� �������������           */
/*    ���������� �������������� ���������           */
/****************************************************/

CREATE TABLE gd_pricepos(
  id               dintkey,                 /* ���������� ����                */
  pricekey         dintkey,                 /* ������ �� ����� ����           */
  goodkey          dintkey                  /* ������ �� ������� ���          */
);

COMMIT;

ALTER TABLE gd_pricepos ADD CONSTRAINT gd_pk_pricepos_id
  PRIMARY KEY(id);

ALTER TABLE gd_pricepos ADD CONSTRAINT gd_fk_pricepos_pricekey
  FOREIGN KEY (pricekey) REFERENCES gd_price(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_pricepos ADD CONSTRAINT gd_fk_pricepos_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_pricepos FOR gd_pricepos
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

/*********************************************************/
/*       ������� �������� ������ �����  � �����-�����    */
/*       gd_priceposoption                               */
/*********************************************************/


CREATE TABLE gd_pricecurr(
  pricekey         dintkey,                 /* ������ �� ����� ����           */
  currkey          dintkey,                 /* ������ �� ������               */
  rate             dcurrency                /* ���� ������                    */
);

ALTER TABLE gd_pricecurr ADD CONSTRAINT gd_pk_pricecurr
  PRIMARY KEY(pricekey, currkey);

ALTER TABLE gd_pricecurr ADD CONSTRAINT gd_fk_pricecurr_pricekey
  FOREIGN KEY (pricekey) REFERENCES gd_price(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_pricecurr ADD CONSTRAINT gd_fk_pricecurr_currkey
  FOREIGN KEY (currkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

COMMIT;

/*********************************************************/
/*       ������� �������� ��������� ��� � �����-�����    */
/*       gd_priceposoption                               */
/*********************************************************/

CREATE TABLE gd_priceposoption(
  fieldname        rdb$field_name NOT NULL, /* �������� ����                  */
  currkey          dforeignkey,                 /* ������ �� ������               */
  expression       dtext254,                /* ������� ������� ����           */

  disabled         dboolean DEFAULT 0,      /* ��������                       */
  reserved         dinteger                  /* ���������������                */
);

COMMIT;

ALTER TABLE gd_priceposoption ADD CONSTRAINT gd_pk_priceposoption_fieldname
  PRIMARY KEY(fieldname);

ALTER TABLE gd_priceposoption ADD CONSTRAINT gd_fk_priceposoption_currkey
  FOREIGN KEY (currkey) REFERENCES gd_curr(id);

COMMIT;

/***********************************************************************/
/*       ������� ��������� ����� �����-����� �� ����������� �������    */
/*       gd_pricefieldrel                                              */
/***********************************************************************/

CREATE TABLE gd_pricefieldrel(
  fieldname        rdb$field_name NOT NULL, /* �������� ����                  */
  contactkey       dintkey,                 /* ������ �� �������              */
  issublevel       dboolean,                /* ���� ��������� ������� - ����� */
                                            /* �� �������� �� ��������� ����� */

  reserved         dinteger                  /* ���������������                */
);

COMMIT;

ALTER TABLE gd_pricefieldrel ADD CONSTRAINT gd_pk_pricefieldrel_fieldname
  PRIMARY KEY(fieldname, contactkey);

ALTER TABLE gd_pricefieldrel ADD CONSTRAINT gd_fk_pricefieldrel_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id);

ALTER TABLE gd_pricefieldrel ADD CONSTRAINT gd_fk_pricefieldrel_fieldname
  FOREIGN KEY (fieldname) REFERENCES gd_priceposoption(fieldname)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

/***********************************************************************/
/*       ������� ��������� ����� ��������������� �������� �            */
/*       �������� ��� �����                                            */
/*       gd_pricedocrel                                                */
/***********************************************************************/

CREATE TABLE gd_pricedocrel(
  fieldname        dfieldname NOT NULL,     /* �������� ����                  */
  documenttypekey  dintkey,                 /* ��� ���������                  */
  relationname     dtablename NOT NULL,     /* �������� �������, �������      */
                                            /* ��������� � �������            */
  docfieldname     dfieldname NOT NULL,     /* �������� ����                  */
  valuetext        dtext180,                /* �������� ����                  */

  reserved         dinteger                  /* ���������������                */
);

COMMIT;

ALTER TABLE gd_pricedocrel ADD CONSTRAINT gd_pk_pricedocrel
  PRIMARY KEY (fieldname, documenttypekey, relationname, docfieldname);

ALTER TABLE gd_pricedocrel ADD CONSTRAINT gd_fk_pricedocrel_fieldname
  FOREIGN KEY (fieldname) REFERENCES gd_priceposoption(fieldname)
  ON UPDATE CASCADE
  ON DELETE CASCADE;


ALTER TABLE gd_pricedocrel ADD CONSTRAINT gd_fk_pricedocrel_doctype
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id)
  ON UPDATE CASCADE;
/*
ALTER TABLE gd_pricedocrel ADD CONSTRAINT gd_fk_pricedocrel_relation
  FOREIGN KEY (relationname) REFERENCES at_relations (relationname)
  ON UPDATE CASCADE
  ON DELETE CASCADE;
*/
COMMIT;


/*******************************************************************************/
/*       ������� ��� �������� ��������� ��������� �� ������ ������� � �����    */
/*       gd_docrealization                                                     */
/*******************************************************************************/

CREATE TABLE gd_docrealization(
  documentkey         dintkey,                 /* ������ �� ��������           */
  tocontactkey        dintkey,                 /* ������ �� �������, ��������  */
                                               /* ���� ������                  */
  fromcontactkey      dintkey,                 /* ������ �� ������� �� ����    */
                                               /* ���� ������                  */
  rate                dcurrency,               /* ����                         */

  fromdocumentkey     dforeignkey,             /* ������ �� ��������� �� ���������, ������� */
                                               /* ������� ������� ���������                 */
  isrealization       dboolean DEFAULT 1,      /* �������� �� ��������� ����������� */
  ispermit            dboolean DEFAULT 0,      /* �������� �������� � ������   */

  transsumncu         dcurrency,               /* ����� ������������ � ���     */
  transsumcurr        dcurrency,               /* ����� ������������ � ������  */             

  pricekey            dforeignkey,             /* �����-����, ������� ������������� ��� ���� */
  pricefield          rdb$field_name,          /* ���� �����-����� �� �������� ������� ���� */

  typetransport       dtypetransport           /* ��� ������: C - �����������  */
                                               /*             S - ���������    */
                                               /*             R - ������������ */
                                               /*             O - ������       */


);

COMMIT;

ALTER TABLE gd_docrealization ADD CONSTRAINT gd_pk_docreal_documentkey
  PRIMARY KEY(documentkey);

ALTER TABLE gd_docrealization ADD CONSTRAINT gd_fk_docreal_documentkey
  FOREIGN KEY(documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_docrealization ADD CONSTRAINT gd_fk_docreal_tocontactkey
  FOREIGN KEY(tocontactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealization ADD CONSTRAINT gd_fk_docreal_fromcontactkey
  FOREIGN KEY(fromcontactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealization ADD CONSTRAINT gd_fk_docreal_fromdocumentkey
  FOREIGN KEY(fromdocumentkey) REFERENCES gd_docrealization(documentkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_docrealization ADD CONSTRAINT gd_fk_docreal_pricekey
  FOREIGN KEY(pricekey) REFERENCES gd_price(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealization ADD CONSTRAINT gd_fk_docreal_pricefield
  FOREIGN KEY(pricefield) REFERENCES gd_priceposoption(fieldname)
  ON UPDATE CASCADE;

COMMIT;

/*******************************************************************************/
/*       ������� ��� �������� ������� �� ��������� �� ������ ������� � �����   */
/*       gd_docrealpos                                                         */
/*******************************************************************************/

CREATE TABLE gd_docrealpos(
  id                  dintkey,                 /* ���������� ����              */
  documentkey         dintkey,                 /* ������ �� ��������           */
  goodkey             dintkey,                 /* ������ �� ��� ��� ������     */
  trtypekey           dforeignkey,             /* ������ �� ��������           */ 
  
  quantity            dquantity,               /* ���������� � ������� ��.���. */
  mainquantity        dquantity,               /* ���������� � �������� ��.���.*/
  performquantity     dquantity DEFAULT 0,     /* ������������ ���-�� (��� �\� */
                                               /*   ���-�� ��������� ������)   */

  amountncu           dcurrency,               /* ����� ������� � ���          */
  amountcurr          dcurrency,               /* ����� ������� � ������       */
  amounteq            dcurrency,               /* ����� ������� � �����������  */

  valuekey            dintkey,                 /* ������ �� ��.���.� �������   */
                                               /* ���� ������                  */

  weightkey           dforeignkey,             /* ������ �� ��. ���.,          */
                                               /* � �������  ����������� ���   */
  weight              dquantity,               /* ����� ��� �������            */

  packkey             dforeignkey,             /* ������ �� ��.���. � �������  */
                                               /* ����������� ��������         */

  packinquant         dquantity,               /* ���������� � ��������        */                                             
  packquantity        dinteger,                /* ���������� ��������          */

  reserved            dinteger,                /* ���������������              */

  printgrouptext      dtext80,                 /* �������� ������ ��� ������   */
  orderprint          dinteger,                /* ������� ��� ������           */
  varprint            dtext20,                 /* ���������� ��� ������        */


  afull               dsecurity,               /* ������ ����� �������         */
  achag               dsecurity,               /* ��������� ����� �������      */
  aview               dsecurity                /* ��������� ����� �������      */

);

COMMIT;

ALTER TABLE gd_docrealpos ADD CONSTRAINT gd_pk_docrealpos_id
  PRIMARY KEY(id);

ALTER TABLE gd_docrealpos ADD CONSTRAINT gd_fk_docrealpos_documentkey
  FOREIGN KEY(documentkey) REFERENCES gd_docrealization(documentkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_docrealpos ADD CONSTRAINT gd_fk_docrealpos_goodkey
  FOREIGN KEY(goodkey) REFERENCES gd_good(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealpos ADD CONSTRAINT gd_fk_docrealpos_valuekey
  FOREIGN KEY(valuekey) REFERENCES gd_value(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealpos ADD CONSTRAINT gd_fk_docrealpos_weightkey
  FOREIGN KEY(weightkey) REFERENCES gd_value(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealpos ADD CONSTRAINT gd_fk_docrealpos_packkey
  FOREIGN KEY(packkey) REFERENCES gd_value(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealpos ADD CONSTRAINT gd_fk_docrealpos_trtypekey
  FOREIGN KEY(trtypekey) REFERENCES gd_listtrtype(id)
  ON UPDATE CASCADE;

COMMIT;


SET TERM ^ ;

CREATE TRIGGER gd_bi_docrealpos FOR gd_docrealpos
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*
CREATE TRIGGER gd_bd_docrealpos FOR gd_docrealpos
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  DELETE FROM gd_entrys WHERE documentkey = OLD.documentkey AND
      positionkey = OLD.id;
END
^
*/

SET TERM ; ^

COMMIT;

/*****************************************************************************/
/*    ������� ��� �������� ��������� �� ������� ���                          */
/*    gd_contract                                                            */
/*****************************************************************************/

CREATE TABLE gd_contract
  (
   documentkey     dintkey,
   
   contactkey      dintkey,

   percent         dpercent,         /* ���� �� �������� */

   textcontract    dblobtext80_1251,

   reserved        dinteger
  );

COMMIT;

ALTER TABLE gd_contract ADD CONSTRAINT gd_pk_contract_documentkey
  PRIMARY KEY(documentkey);

ALTER TABLE gd_contract ADD CONSTRAINT gd_fk_contract_documentkey
  FOREIGN KEY(documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_contract ADD CONSTRAINT gd_fk_contract_contactkey
  FOREIGN KEY(contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

COMMIT;


/*******************************************************************************/
/*       ������� ��� �������� �������������� ���������� �� ���������           */
/*       gd_docrealinfo                                                        */
/*******************************************************************************/

CREATE TABLE gd_docrealinfo(
  documentkey         dintkey,                 /* ������ �� ��������           */
  cargoreceiverkey    dforeignkey,             /* ���������������              */
  car                 dtext60,                 /* ����������                   */
  carownerkey         dforeignkey,             /* �������� ����������          */
  driver              dtext40,                 /* ��������                     */
  loadingpoint        dtext60,                 /* ����� ��������               */
  unloadingpoint      dtext60,                 /* ����� ���������              */
  route               dtext60,                 /* �������                      */
  readdressing        dtext60,                 /* �������������                */
  hooked              dtext20,                 /* ������                       */
  waysheetnumber      dtext20,                 /* ����� �������� �����         */
  surrenderkey        dforeignkey,             /* ��� ���� ����                */
  reception           dtext60,                 /* ��� ������ ����              */
  warrantnumber       dtext20,                 /* ����� ������������           */
  warrantdate         ddate,                   /* ���� ������������            */
  contractkey         dforeignkey,             /* ������ �� �������            */
  contractnum         dtext40,                 /* ���� ��������                */
  datepayment         ddate,                   /* ���� ��������                */
  forwarderkey        dforeignkey,             /* ����������                   */
  garage              dtext40,                 /* �����                        */  
  
  typetransport       dtypetransport           /* ��� ������: C - �����������  */
                                               /*             S - ���������    */
                                               /*             R - ������������ */
                                               /*             O - ������       */
);

COMMIT;

ALTER TABLE gd_docrealinfo ADD CONSTRAINT gd_pk_docrealinfo_documentkey
  PRIMARY KEY(documentkey);

ALTER TABLE gd_docrealinfo ADD CONSTRAINT gd_fk_docrealinfo_documentkey
  FOREIGN KEY(documentkey) REFERENCES gd_docrealization (documentkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_docrealinfo ADD CONSTRAINT gd_fk_docrealinfo_cargoreckey
  FOREIGN KEY(cargoreceiverkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealinfo ADD CONSTRAINT gd_fk_docrealinfo_carownerkey
  FOREIGN KEY(carownerkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealinfo ADD CONSTRAINT gd_fk_docrealinfo_surrenderkey
  FOREIGN KEY(surrenderkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealinfo ADD CONSTRAINT gd_fk_docrealinfo_forwarderkey
  FOREIGN KEY(forwarderkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_docrealinfo ADD CONSTRAINT gd_fk_docrealinfo_contractkey
  FOREIGN KEY(contractkey) REFERENCES gd_contract(documentkey)
  ON UPDATE CASCADE;

COMMIT;

/******************************************************************************/
/*       ������� ��� �������� ��������� ������� �� ���������                  */
/*       gd_docrealposoption                                                  */
/******************************************************************************/

CREATE TABLE gd_docrealposoption(
  fieldname        rdb$field_name NOT NULL, /* �������� ����                  */
  relationname     dtablename NOT NULL,
  taxkey           dforeignkey,
  rate             dcurrency,
  expression       dtext180,
  includetax       dboolean,
  iscurrency       dboolean,
  rounding         dcurrency
);

COMMIT;

ALTER TABLE gd_docrealposoption ADD CONSTRAINT gd_pk_docrealposoption_fn
  PRIMARY KEY(fieldname, relationname);
/*
ALTER TABLE gd_docrealposoption ADD CONSTRAINT gd_fk_docrealposoption_rn
  FOREIGN KEY(relationname) REFERENCES at_relations (relationname)
  ON UPDATE CASCADE;
*/
ALTER TABLE gd_docrealposoption ADD CONSTRAINT gd_fk_docrealposoption_tk
  FOREIGN KEY (taxkey) REFERENCES gd_tax(id)
  ON UPDATE CASCADE;

COMMIT;

/*****************************************************************************/
/*   ������� ������ ������� ������-������ �� ������� ������������ ������     */
/*   gd_docrealposrel                                                        */
/*****************************************************************************/

CREATE TABLE gd_docrealposrel(
  sourcerealposkey  dintkey,
  destrealposkey    dintkey,
  quantity        dquantity
);

ALTER TABLE gd_docrealposrel ADD CONSTRAINT gd_pk_docrealposrel
  PRIMARY KEY(sourcerealposkey, destrealposkey);

ALTER TABLE gd_docrealposrel ADD CONSTRAINT gd_fk_docrealposrel_source
  FOREIGN KEY(sourcerealposkey) REFERENCES gd_docrealpos(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_docrealposrel ADD CONSTRAINT gd_fk_docrealposrel_dest
  FOREIGN KEY(destrealposkey) REFERENCES gd_docrealpos(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_ai_docrealposrel FOR gd_docrealposrel
  AFTER INSERT
  POSITION 0
AS
BEGIN
  UPDATE gd_docrealpos
  SET performquantity = performquantity + NEW.quantity
  WHERE id = NEW.sourcerealposkey;
END
^

CREATE TRIGGER gd_au_docrealposrel FOR gd_docrealposrel
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  UPDATE gd_docrealpos
  SET performquantity = performquantity - OLD.quantity + NEW.quantity
  WHERE id = NEW.sourcerealposkey;
END
^

CREATE TRIGGER gd_ad_docrealposrel FOR gd_docrealposrel
  AFTER DELETE
  POSITION 0
AS
BEGIN
  UPDATE gd_docrealpos
  SET performquantity = performquantity - OLD.quantity
  WHERE id = OLD.sourcerealposkey;
END
^

SET TERM ; ^

COMMIT;

/*****************************************************************************/
/*    View ��� ��������� ���������� ���������� � ����� �������� �����������  */
/*    gd_v_docrealcentr                                                      */
/*****************************************************************************/

CREATE VIEW GD_V_DOCREALCENTR(
    ID,
    NUMBER,
    DOCUMENTDATE)
AS
  SELECT d.id, d.number, d.documentdate
  FROM
    gd_docrealization dr
    LEFT JOIN gd_document d
         ON d.id = dr.documentkey

  WHERE
    dr.typetransport = 'C' and
    dr.fromdocumentkey IS NULL and
    d.documenttypekey = 802001;

COMMIT;

/*****************************************************************************/
/*    View ��� ������ ���������                                              */
/*    gd_v_doccontract                                                       */
/*****************************************************************************/


CREATE VIEW GD_V_DOCCONTRACT(
    ID,
    NUMBER,
    DOCUMENTDATE,
    COMPANYKEY)
AS
  SELECT d.id, d.number, d.documentdate, c.contactkey
  FROM gd_contract c JOIN gd_document d 
  ON c.contactkey = d.id;

COMMIT;
