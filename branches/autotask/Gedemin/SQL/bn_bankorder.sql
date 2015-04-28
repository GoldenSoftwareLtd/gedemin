
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    bn_bankorder.sql

  Abstract

    Таблицы документов-приказов банку для осуществления
    определенных операций с безналичными денежными средствами.

  Author

    Denis Romanovski

  Revisions history

    Initial  30.11.2000  Dennis    Initial version
    Modification 24.07.2001 Julia

*/

/*
 *   Даведн_к фармул_ровак плацежоў.
 *   Выкарыстоўваецца ў плацёжных даручэньнях.
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
 *  Коды назначений платежных операций
 *
 */

CREATE TABLE bn_destcode
(
  id                dintkey,      /* уникальный идентификатор  */
  code              dtext20,      /* код назначения */
  description       dtext180,      /* описание назначения */

/*  afull             dsecurity,
  achag             dsecurity,
  aview             dsecurity,*/

  disabled          dboolean DEFAULT 0,
  reserved          dinteger
);

ALTER TABLE bn_destcode
  ADD CONSTRAINT bn_pk_destcode PRIMARY KEY (id);

/* Домен для вида поручения 
 * C - (common) - общий
 * P - (pressing) - срочный
 */

CREATE DOMAIN dpaymentkind AS 
VARCHAR(1)
CHECK ((VALUE IS NULL) OR (VALUE = 'C') OR (VALUE = 'P'));

/* Домен для расходов по переводу 
 * P - (payer) - плательщик,
 * B - (beneficiary) - бенефициар,
 * O - (other) - другое
 */

CREATE DOMAIN dexpenseaccount AS 
VARCHAR(1)
CHECK ((VALUE IS NULL) OR (VALUE = 'P') OR (VALUE = 'B') OR (VALUE = 'O'));


/* Домен для акцепта 
 * 0 - без акцепта,
 * 1 - с акцептом
 */

CREATE DOMAIN daccept AS 
VARCHAR(1)
CHECK ((VALUE IS NULL) OR (VALUE = '0') OR (VALUE = '1'));


/*
 *
 *  Общая таблица для платежных поручений,
 *  платежных требований, требований-поручений.
 *
 */

CREATE TABLE bn_demandpayment
(
  /* Общая часть */
  documentkey       dintkey,      /* ссылка на таблицу документов  */
/*  companykey        dintkey,  */    /* компания-плательщик */
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
  corrsecacc        dtext20,      /* второй счет */

  amount            dcurrency,    /* сумма по поручению                                */
                                  /* по платежному поручению могут проходить две суммы */
                                  /* например, вторая -- сумма за услуги банка         */
                                  /* именно по этому мы назвали это поле не sumncu, а  */
                                  /* amount -- это общая сумма                         */
                                  /* вторая сумма находится в поле secondamount        */

  proc              dtext20,      /* вид обработки */
  oper              dtext20,      /* вид операции */
  queue             dqueue,       /* очередность платежа */
  destcodekey       dforeignkey,  /* назначение платежа (код) */
  destcode          dtext20,      /* назначение платежа текст */
  term              ddate,        /* срок платежа */
  destination       dtext1024,    /* назначение платежа */

  /* часть платежки */
  secondaccountkey  dforeignkey,  /* корреспондирующий счет для доп. суммы */
  secondamount      dcurrency,    /* доп. сумма по поручению */

  enterdate         dtext20,      /* дата получения товара, оказания услуги или др. текст */
  specification     dtext60,      /* уточнение платежа (срочный платеж, в счет удеражния...) */
  percent           dpercent,     /* процент пени  */

  /* часть требования */
  cargosender       dtext180,     /* грузоотправитель */
  cargoreciever     dtext180,     /* грузополучатель */
  contract          dtext40,      /* договор поставки */
  paper             dtext60,      /* № документа отправки */
  cargosenddate     ddate,        /* дата отгрузки */
  papersenddate     ddate,      /* дата отправки документов */
/*  afull             dsecurity,    /* полные права */
/*  achag             dsecurity,    /* права на изменения */
/*  aview             dsecurity,    /* права на просмотр */

  kind              dpaymentkind, /* вид поручения: Обычный, Срочный */
  expenseaccount    dexpenseaccount, 
                                  /* Расходы по переводу: за счет плательщика (P)
				   * за счет бенефициара (B), 
                                   * другое (O)
                                   */
  midcorrbanktext      dtext255,  /* текст названия корреспондента банка получателя, его реквизиты */
  withacceptance       dboolean, 
  withaccept           daccept    /* с акцептом(1) или без(0), или пустое */ 

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

