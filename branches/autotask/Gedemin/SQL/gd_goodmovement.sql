
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus


  Script

    gd_goodmovement.sql

  Abstract

    Скрипт для учета накладных

  Author

    Mikle Shoihet    (16.07.2001)
    Teryokhina Julia
    Romanovski Denis

  Revisions history

    1.0    Julia    23.01.2001    Initial version.

  Status


*/

/*
 *
 *  Список карточек движения ТМЦ
 *
 */

CREATE TABLE gd_goodcard
(
  id                    dintkey,
  goodkey               dintkey
);

COMMIT;

ALTER TABLE gd_goodcard ADD CONSTRAINT gd_pk_goodcard
  PRIMARY KEY (id);

ALTER TABLE gd_goodcard ADD CONSTRAINT gd_fk_goodcard_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good (id);

COMMIT;


/*
 *
 *  Вид движения
 *  I - (income) приход
 *  E - (expense) расход
 *  M - (movement) движение
 *
 */

CREATE DOMAIN dgoodmovementkind
  AS VARCHAR(1)
 CHECK ((VALUE = 'I') OR (VALUE = 'E') OR (VALUE = 'M'));

/*
 *
 *  Движение ТМЦ
 *
 */


CREATE TABLE gd_goodmovement
(
  id                    dintkey,
  goodentryid           dintkey,

  documentkey           dintkey,
  contactkey            dintkey,

  cardkey               dintkey,

  kind                  dgoodmovementkind,

  debet                 dquantity,
  credit                dquantity,

  sumncu                dcurrency

);

COMMIT;

ALTER TABLE gd_goodmovement ADD CONSTRAINT gd_pk_goodmovement
  PRIMARY KEY (id);

ALTER TABLE gd_goodmovement ADD CONSTRAINT gd_fk_goodmovement_dk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodmovement ADD CONSTRAINT gd_fk_goodmovement_ck
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id);

ALTER TABLE gd_goodmovement ADD CONSTRAINT gd_fk_goodmovement_cardk
  FOREIGN KEY (cardkey) REFERENCES gd_goodcard (id);

CREATE ASC INDEX
  gd_x_goodmovement_goodentryid
ON
  gd_goodmovement (goodentryid);

COMMIT;

/*
 *
 *  Первое появление карточки
 *
 */

CREATE TABLE gd_goodcardappear
(
  cardkey               dintkey,
  movementkey           dintkey,
  firstmovementkey      dforeignkey
);

COMMIT;

ALTER TABLE gd_goodcardappear ADD CONSTRAINT gd_fk_goodcardapper_ck
  FOREIGN KEY (cardkey) REFERENCES gd_goodcard (id);

ALTER TABLE gd_goodcardappear ADD CONSTRAINT gd_fk_goodcardapper_mk
  FOREIGN KEY (movementkey) REFERENCES gd_goodmovement (id);

ALTER TABLE gd_goodcardappear ADD CONSTRAINT gd_fk_goodcardapper_fmk
  FOREIGN KEY (firstmovementkey) REFERENCES gd_goodmovement (id);

COMMIT;

SET TERM ^ ;


/*
 *
 *  Если в списке появлений новых карточек нет записи -
 *  осуществляем вставку новой записи с ключом карточки
 *  и движения, при котором она появилась.
 *
 */

CREATE TRIGGER gd_ai_goodmovement FOR gd_goodmovement
  AFTER INSERT
  POSITION 0
as
  DECLARE VARIABLE CardExists INTEGER;

  DECLARE VARIABLE PositionKey INTEGER;
  DECLARE VARIABLE CardKey INTEGER;
  DECLARE VARIABLE FirstMovementKey INTEGER;
  
BEGIN
  IF (EXISTS
    (
      SELECT
        a.cardkey
      FROM
        gd_goodcardappear a
      WHERE
        a.cardkey = NEW.cardkey
    ))
  THEN
    CardExists = 1;
  ELSE
    CardExists = 0;

  /* Приход ТМЦ */

  IF (NEW.kind = 'I') THEN
  BEGIN

    /* Если карточка еще не зарегистрирована */

    IF (:CardExists = 0) THEN
      INSERT INTO
        gd_goodcardappear
          (cardkey, movementkey, firstmovementkey)
      VALUES
        (NEW.cardkey, NEW.id, NEW.id);
  END ELSE

  /* Перемещение или изменение свойств ТМЦ */

  IF (NEW.kind = 'M') THEN
  BEGIN

    /* Если карточка еще не зарегистрирована */

    IF (:CardExists = 0) THEN
    BEGIN
      PositionKey = NULL;
      CardKey = NULL;

      /* Если первый внесен дебет */
      IF (NEW.debet IS NULL) THEN
      BEGIN
        SELECT
          m.id, m.cardkey
        FROM
          gd_goodmovement m
        WHERE
          m.goodentryid = NEW.goodentryid
            AND
          m.credit IS NULL
        INTO :PositionKey, :CardKey;

        /* Если запись по дебету уже внесена */

        IF (:PositionKey IS NOT NULL) THEN
        BEGIN
          /* получаем первое движение по старой карточке */
          SELECT
            a.firstmovementkey
          FROM
            gd_goodcardappear a
          WHERE
            a.cardkey = NEW.cardkey
          INTO :FirstMovementKey;

          /* вносим запись в таблицу появлений карточек */
          INSERT INTO gd_goodcardappear
            (cardkey, movementkey, firstmovementkey)
          VALUES
            (:CardKey, :PositionKey, :FirstMovementKey);
        END

      END ELSE

      /* Если первый внесен кредит */
      IF (NEW.credit IS NULL) THEN
      BEGIN
        SELECT
          m.id, m.cardkey
        FROM
          gd_goodmovement m
        WHERE
          m.goodentryid = NEW.goodentryid
            AND
          m.debet IS NULL
        INTO :PositionKey, :CardKey;

        /* Если запись по кредиту уже внесена */

        IF (:PositionKey IS NOT NULL) THEN
        BEGIN
          /* получаем первое движение по старой карточке */
          SELECT
            a.firstmovementkey
          FROM
            gd_goodcardappear a
          WHERE
            a.cardkey = :CardKey
          INTO :FirstMovementKey;

          /* вносим запись в таблицу появлений карточек */
          INSERT INTO gd_goodcardappear
            (cardkey, movementkey, firstmovementkey)
          VALUES
            (NEW.cardkey, NEW.id, :FirstMovementKey);
        END
      END
    END
  END
END;^

CREATE EXCEPTION gd_e_goodmovementchange 'Can not change movementkey'^


/*
 *
 *  Триггер запрета изменения ключа проводки для товаров.
 *
 */

CREATE TRIGGER gd_bu_goodcard FOR gd_goodmovement
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.goodentryid <> OLD.goodentryid) THEN
    EXCEPTION gd_e_goodmovementchange;
END
^

SET TERM ; ^

COMMIT;
