
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    gd_iteminvent.sql

  Abstract

    Общие таблицы по движению ТМЦ

  Author

    Michael Shoihet (23 december 2000)

  Revisions history

    Initial  23.12.00  MSH    Initial version

  Status

    Draft

*/

/*********************************************************/
/*    Таблица для хранения карты учета ТМЦ               */
/*    gd_inventitemcard                                  */
/*********************************************************/

CREATE TABLE gd_inventitemcard(
  id               dintkey,                 /* Уникальный ключ                     */
  goodkey          dintkey,                 /* Ссылка на позицию в справочнике ТМЦ */
  contactkey       dintkey,                 /* Ссылка на позицию в контактах       */
  quantity         dquantity,               /* Количество ТМЦ                      */
  sumncu           dcurrency,               /* Сумма в НДЕ                         */
  sumcurr          dcurrency,               /* Сумма в валюте                      */
  currkey          dforeignkey,                 /* Ссылка на валюту                    */

  disabled         dboolean DEFAULT 0,      /* Отключено                           */
  afull            dsecurity
);

COMMIT;

ALTER TABLE gd_inventitemcard ADD CONSTRAINT gd_pk_inventitemcard_id
  PRIMARY KEY (id);

ALTER TABLE gd_inventitemcard ADD CONSTRAINT gd_fk_inventitemcard_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_inventitemcard ADD CONSTRAINT gd_fk_inventitemcard_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_inventitemcard ADD CONSTRAINT gd_fk_inventitemcard_currkey
  FOREIGN KEY (currkey) REFERENCES gd_curr(id)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_inventitemcard FOR gd_inventitemcard
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
/*       Таблица хранения контрагентов                   */
/*       gd_doccontact                                   */
/*********************************************************/

CREATE TABLE gd_doccontact(
  id               dintkey,          /* Уникальный ключ                        */
  documentkey      dintkey,          /* Ссылка на документ                     */
  contactkey       dintkey,          /* Ссылка на контакт                      */
  contacttype      dcontacttype,     /* Тип контрагента D - дебитор,К -кредитор*/

  afull            dsecurity
);

COMMIT;

ALTER TABLE gd_doccontact ADD CONSTRAINT gd_pk_doccontact_id
  PRIMARY KEY(id);

ALTER TABLE gd_doccontact ADD CONSTRAINT gd_fk_doccontact_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_doccontact ADD CONSTRAINT gd_fk_doccontact_contactkey
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_doccontact FOR gd_doccontact
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

/***************************************************************/

/*********************************************************/
/*       Таблица хранения позиций по движению ТМЦ        */
/*       gd_goodposition                                 */
/*********************************************************/

CREATE TABLE gd_goodposition(
  id               dintkey,          /* Уникальный ключ                        */
  documentkey      dintkey,          /* Ссылка на документ                     */
  sourcecardkey    dforeignkey,          /* Ссылка на карту учета ТМЦ (источник)   */
  destcardkey      dforeignkey,          /* Ссылка на карту учета ТМЦ (получатель) */
  quantity         dquantity,        /* Количество                             */
  sumncu           dcurrency,        /* Сумма в НДЕ                            */
  sumcurr          dcurrency,        /* Сумма в валюте                         */
  currkey          dforeignkey,          /* Ссылка на валюту                       */

  reserved         dinteger
);

COMMIT;

ALTER TABLE gd_goodposition ADD CONSTRAINT gd_pk_goodposition_id
  PRIMARY KEY (id);

ALTER TABLE gd_goodposition ADD CONSTRAINT gd_fk_goodposition_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_goodposition ADD CONSTRAINT gd_fk_goodposition_sourcecard
  FOREIGN KEY (sourcecardkey) REFERENCES gd_inventitemcard(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_goodposition ADD CONSTRAINT gd_fk_goodposition_destcard
  FOREIGN KEY (destcardkey) REFERENCES gd_inventitemcard(id)
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_goodpos FOR gd_goodposition
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
