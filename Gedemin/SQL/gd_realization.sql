
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    gd_realization.sql

  Abstract

    Таблицы для учета реализации товаров и услуг.

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
/*       Таблица для хранения прайс листов          */
/*       gd_price                                   */
/****************************************************/

CREATE TABLE gd_price(
  id               dintkey,                 /* Уникальный ключ                */
  name             dname,                   /* Наименование прайса            */
  description      dtext180,                /* Описание прайса                */
  relevancedate    ddate,                    /* Дата актуальности прайса       */
  pricetype        dpricetype,              /* Тип прайс листа P - поставщика */
                                            /*                 С - покупателя */
  contactkey       dforeignkey,                                          

  disabled         dboolean DEFAULT 0,      /* отключен                       */
  reserved         dinteger,                 /* зарезервировано                */

  afull            dsecurity,               /* Полные права доступа           */
  achag            dsecurity,               /* Изменения права доступа        */
  aview            dsecurity                /* Просмотра права доступа        */
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
/*    Таблица для позиций прайс листов              */
/*    gd_pricepos                                   */
/*    Данная таблица создается в минимальной        */
/*    конфигурации и для ее использовнаия           */
/*    необходима дополнительная настройка           */
/****************************************************/

CREATE TABLE gd_pricepos(
  id               dintkey,                 /* Уникальный ключ                */
  pricekey         dintkey,                 /* Ссылка на прайс лист           */
  goodkey          dintkey                  /* Ссылка на позицию ТМЦ          */
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
/*       Таблица хранения курсов валют  в прайс-листе    */
/*       gd_priceposoption                               */
/*********************************************************/


CREATE TABLE gd_pricecurr(
  pricekey         dintkey,                 /* Ссылка на прайс лист           */
  currkey          dintkey,                 /* Ссылка на валюту               */
  rate             dcurrency                /* Курс валюты                    */
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
/*       Таблица хранения настройки цен в прайс-листе    */
/*       gd_priceposoption                               */
/*********************************************************/

CREATE TABLE gd_priceposoption(
  fieldname        rdb$field_name NOT NULL, /* Название поля                  */
  currkey          dforeignkey,                 /* Ссылка на валюту               */
  expression       dtext254,                /* Формула расчета цены           */

  disabled         dboolean DEFAULT 0,      /* отключен                       */
  reserved         dinteger                  /* зарезервировано                */
);

COMMIT;

ALTER TABLE gd_priceposoption ADD CONSTRAINT gd_pk_priceposoption_fieldname
  PRIMARY KEY(fieldname);

ALTER TABLE gd_priceposoption ADD CONSTRAINT gd_fk_priceposoption_currkey
  FOREIGN KEY (currkey) REFERENCES gd_curr(id);

COMMIT;

/***********************************************************************/
/*       Таблица настройки полей прайс-листа на необходимый контакт    */
/*       gd_pricefieldrel                                              */
/***********************************************************************/

CREATE TABLE gd_pricefieldrel(
  fieldname        rdb$field_name NOT NULL, /* Название поля                  */
  contactkey       dintkey,                 /* Ссылка на контакт              */
  issublevel       dboolean,                /* Если выбранный контакт - папка */
                                            /* то включать ли вложенные папки */

  reserved         dinteger                  /* зарезервировано                */
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
/*       Таблица настройки полей соответствующий документ и            */
/*       значения его полей                                            */
/*       gd_pricedocrel                                                */
/***********************************************************************/

CREATE TABLE gd_pricedocrel(
  fieldname        dfieldname NOT NULL,     /* Название поля                  */
  documenttypekey  dintkey,                 /* Тип документа                  */
  relationname     dtablename NOT NULL,     /* Название таблицы, которое      */
                                            /* участвует в условии            */
  docfieldname     dfieldname NOT NULL,     /* Название поля                  */
  valuetext        dtext180,                /* Значение поля                  */

  reserved         dinteger                  /* зарезервировано                */
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
/*       Таблица для хранения заголовка документа на отпуск товаров и услуг    */
/*       gd_docrealization                                                     */
/*******************************************************************************/

CREATE TABLE gd_docrealization(
  documentkey         dintkey,                 /* Ссылка на документ           */
  tocontactkey        dintkey,                 /* Ссылка на контакт, которому  */
                                               /* идет отпуск                  */
  fromcontactkey      dintkey,                 /* Ссылка на контакт от куда    */
                                               /* идет отпуск                  */
  rate                dcurrency,               /* Курс                         */

  fromdocumentkey     dforeignkey,             /* Ссылка на накладную на основании, которой */
                                               /* создана текущая накладная                 */
  isrealization       dboolean DEFAULT 1,      /* Является ли накладная реализацией */
  ispermit            dboolean DEFAULT 0,      /* Документ разрешен к выдаче   */

  transsumncu         dcurrency,               /* Сумма транспортных в НДЕ     */
  transsumcurr        dcurrency,               /* Сумма транспотрных в валюте  */             

  pricekey            dforeignkey,             /* Прайс-лист, который использовался для цены */
  pricefield          rdb$field_name,          /* Поле прайс-листа из которого выбрана цена */

  typetransport       dtypetransport           /* Тип вывоза: C - Центровывоз  */
                                               /*             S - Самовывоз    */
                                               /*             R - Арендованный */
                                               /*             O - Прочее       */


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
/*       Таблица для хранения позиций по документу на отпуск товаров и услуг   */
/*       gd_docrealpos                                                         */
/*******************************************************************************/

CREATE TABLE gd_docrealpos(
  id                  dintkey,                 /* Уникальный ключ              */
  documentkey         dintkey,                 /* Ссылка на документ           */
  goodkey             dintkey,                 /* Ссылка на ТМЦ или услугу     */
  trtypekey           dforeignkey,             /* Ссылка на операцию           */ 
  
  quantity            dquantity,               /* Количество в текущей ед.изм. */
  mainquantity        dquantity,               /* Количество в основной ед.изм.*/
  performquantity     dquantity DEFAULT 0,     /* Обработанное кол-во (для с\ф */
                                               /*   кол-во выданного товара)   */

  amountncu           dcurrency,               /* Сумма отпуска в НДЕ          */
  amountcurr          dcurrency,               /* Сумма отпуска в валюте       */
  amounteq            dcurrency,               /* Сумма отпуска в эквиваленте  */

  valuekey            dintkey,                 /* Ссылка на ед.изм.в которой   */
                                               /* идет отпуск                  */

  weightkey           dforeignkey,             /* Ссылка на ед. изм.,          */
                                               /* в которой  учитывается вес   */
  weight              dquantity,               /* Общий вес позиции            */

  packkey             dforeignkey,             /* Ссылка на ед.изм. в которой  */
                                               /* учитывается упаковка         */

  packinquant         dquantity,               /* Количество в упаковке        */                                             
  packquantity        dinteger,                /* Количество упаковок          */

  reserved            dinteger,                /* зарезервировано              */

  printgrouptext      dtext80,                 /* название группы для печати   */
  orderprint          dinteger,                /* порядок при печати           */
  varprint            dtext20,                 /* переменная для печати        */


  afull               dsecurity,               /* Полные права доступа         */
  achag               dsecurity,               /* Изменения права доступа      */
  aview               dsecurity                /* Просмотра права доступа      */

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
/*    Таблица для хранения договоров на закупку ТМЦ                          */
/*    gd_contract                                                            */
/*****************************************************************************/

CREATE TABLE gd_contract
  (
   documentkey     dintkey,
   
   contactkey      dintkey,

   percent         dpercent,         /* Пеня по договору */

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
/*       Таблица для хранения дополнительной информации по накладной           */
/*       gd_docrealinfo                                                        */
/*******************************************************************************/

CREATE TABLE gd_docrealinfo(
  documentkey         dintkey,                 /* Ссылка на документ           */
  cargoreceiverkey    dforeignkey,             /* Грузополучатель              */
  car                 dtext60,                 /* Автомобиль                   */
  carownerkey         dforeignkey,             /* Владелец транспорта          */
  driver              dtext40,                 /* Водитель                     */
  loadingpoint        dtext60,                 /* Пункт погрузки               */
  unloadingpoint      dtext60,                 /* Пункт разгрузки              */
  route               dtext60,                 /* Маршрут                      */
  readdressing        dtext60,                 /* Переадресовка                */
  hooked              dtext20,                 /* Прицеп                       */
  waysheetnumber      dtext20,                 /* Номер путевого листа         */
  surrenderkey        dforeignkey,             /* Кто сдал груз                */
  reception           dtext60,                 /* Кто принял груз              */
  warrantnumber       dtext20,                 /* Номер доверенности           */
  warrantdate         ddate,                   /* Дата доверенности            */
  contractkey         dforeignkey,             /* Ссылка на контрат            */
  contractnum         dtext40,                 /* Дата договора                */
  datepayment         ddate,                   /* Дата отсрочки                */
  forwarderkey        dforeignkey,             /* Экспедитор                   */
  garage              dtext40,                 /* Гараж                        */  
  
  typetransport       dtypetransport           /* Тип вывоза: C - Центровывоз  */
                                               /*             S - Самовывоз    */
                                               /*             R - Арендованный */
                                               /*             O - Прочее       */
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
/*       Таблица для хранения настройки налогов по документу                  */
/*       gd_docrealposoption                                                  */
/******************************************************************************/

CREATE TABLE gd_docrealposoption(
  fieldname        rdb$field_name NOT NULL, /* Название поля                  */
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
/*   Таблица хранит позиции счетов-фактур по которым осуществлена выдача     */
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
/*    View для просмотра документов реализации с типом отгрузки центровывоз  */
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
/*    View для выбора договоров                                              */
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
