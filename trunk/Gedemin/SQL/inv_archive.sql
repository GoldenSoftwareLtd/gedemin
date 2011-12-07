
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus


  Script

    inv_archive.sql

  Abstract

    Архивные таблицы для учета движения товарно-материальных
    ценностей и услуг.

  Author

    Mikle Shoihet    (16.07.2001)
    Leonid Agafonov
    Teryokhina Julia
    Romanovski Denis

  Revisions history

    1.0    Julia    23.07.2001    Initial version.
    2.0    Dennis   03.08.2001    Initial version.

  Status


*/

/*
 *
 *  Движение ТМЦ
 *
 */


CREATE TABLE inv_a_movement
(
  id                    dintkey,              /* идентификатор */
  movementkey           dintkey,              /* идентификатор движения */

  movementdate          ddate NOT NULL,       /* дата движения */

  documentkey           dintkey,              /* ссылка на документ */
  contactkey            dintkey,              /* ссылка на контакт */

  cardkey               dintkey,              /* ссылка на карточку */

  debit                 dquantity DEFAULT 0,  /* приход ТМЦ (услуг) в количественном выражении */
  credit                dquantity DEFAULT 0,  /* расход ТМЦ (услуг) в количественном выражении */

  disabled              dboolean DEFAULT 0,   /* отключена ли запись */
  reserved              dreserved             /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_a_movement ADD CONSTRAINT inv_pk_a_movement
  PRIMARY KEY (id);

ALTER TABLE inv_a_movement ADD CONSTRAINT inv_fk_a_movement_dk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_a_movement ADD CONSTRAINT inv_fk_a_movement_ck
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE inv_a_movement ADD CONSTRAINT inv_fk_a_movement_cardk
  FOREIGN KEY (cardkey) REFERENCES inv_card (id)
  ON UPDATE CASCADE;

COMMIT;

CREATE INDEX INV_X_A_MOVEMENT_CCD ON INV_A_MOVEMENT (
  CARDKEY, CONTACTKEY, MOVEMENTDATE);

COMMIT;

CREATE INDEX INV_X_A_MOVEMENT_MK ON INV_A_MOVEMENT (
  MOVEMENTKEY);

COMMIT;


/*
 *  Триггер создания уникального кода
 */

CREATE TRIGGER inv_bi_movement FOR inv_a_movement
  BEFORE INSERT
  POSITION 0
  AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.debit IS NULL) THEN
    NEW.debit = 0;

  IF (NEW.credit IS NULL) THEN
    NEW.credit = 0;
END;
^


CREATE TRIGGER inv_bu_movement FOR inv_a_movement
  BEFORE UPDATE
  POSITION 0
AS
 DECLARE VARIABLE balance NUMERIC(15, 4);
BEGIN
  EXCEPTION inv_e_movementchange;
END;
^

SET TERM ; ^

COMMIT;

