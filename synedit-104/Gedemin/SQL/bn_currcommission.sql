
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    bn_currcommission.sql

  Abstract

    Поручение на перевод валюты

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
  documentkey       dintkey,      /* ссылка на таблицу документов  */
  accountkey        dintkey,      /* расчетный счет плательщика */

  corrcompanykey    dintkey,      /* корреспонирующая компания, с которой идет расчет */
  corraccountkey    dintkey,      /* корреспондирующий счет */
  owncomptext       dtext180,     /* собственная компания (текстовая инф-ция) */

  owntaxid          dtext20,      /* собственный УНН */
  owncountry        dtext20,      /* страна */

  ownbanktext       dtext180,     /* текст названия банка */
  ownbankcity       dtext20,      /* город */
  ownaccount        dbankaccount,      /* счет */
  ownaccountcode    dtext20,      /* код банка */

  corrcomptext      dtext180,     /* корреспондирующая компания (текстовая инф-ция) */

  corrtaxid         dtext20,      /* УНН */
  corrcountry       dtext20,      /* страна */

  corrbanktext      dtext180,     /* текст названия банка */
  corrbankcity      dtext20,      /* город */
  corraccount       dbankaccount,      /* счет */
  corraccountcode   dtext20,      /* код банка */

  amount            dcurrency,    /* сумма по поручению */
  destination       dtext1024,    /* назначение платежа */
  kind              dpaymentkind, /* вид поручения: Обычный, Срочный */
  expenseaccount    dexpenseaccount, 
                                  /* Расходы по переводу: за счет плательщика (P)
				   * за счет бенефициара (B), 
                                   * другое (O)
                                   */
  midcorrbanktext   dtext255,     /* текст названия корреспондента банка получателя, его реквизиты */
  queue             dqueue,       /* очередность платежа */
  destcodekey       dforeignkey,  /* назначение платежа (код) */
  destcode          dtext20       /* назначение платежа текст */
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
/*   Типовая заявка договор на продажу валюты                           */
/*   bn_currsellcontract                                                */
/************************************************************************/

CREATE TABLE bn_currsellcontract
(
  documentkey       dintkey,
  
  currkey           dintkey,      /*  Продаваемая валюта   */ 
  amount            dcurrency,    /*  Сумма валюты         */
  minrate           dcurrency,    /*  Минимальный курс     */

  bankkey           dintkey,      /*  Банк */
  bankaccountkey    dintkey,      /*  Счет банка для вознаграждения */
  ownaccountkey     dintkey,      /* счет для зачисления средств в НДЕ */

  banktext          dtext180,     /*  Наименование банка            */
  bankcode          dtext20,      /*  Код банка */
   

  owncomptext       dtext180,     /* собственная компания (текстовая инф-ция) */
  owntaxid          dtext20,      /* собственный УНН */
  owncountry        dtext20,      /* страна */
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
/*   Поручение продажу валюты                                           */
/*   bn_currcommisssell                                                  */
/************************************************************************/

CREATE TABLE bn_currcommisssell 
(
  documentkey       dintkey,

  bankkey           dintkey,       /*  Банк */  
  percent           dpercent,      /*  Процент от суммы      */
  amountcurr        dcurrency,     /*  Сумма валюты          */

  accountkey        dintkey,       /*  Транзитный счет       */

  timeint           dinteger,      /*  В течении дней        */
  compercent        dpercent,      /*  Процент комиссионого  */

  toaccountkey      dforeignkey,   /*  Счет для зачисления   */

  tocurraccountkey  dforeignkey,   /*  Счет для валюты, оставшейся */
                                   /*  после обязательной продажи  */

  datevalid         ddate          /*  Поручение действительно до  */         

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
/*   Реестр распределения валюты                                        */
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
/*   Договор на покупку валюты                                          */
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
/*   Контракт на конверсию валюты                                       */
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
