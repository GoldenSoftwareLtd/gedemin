
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus


  Script

    inv_movement.sql

  Abstract

    Таблицы для учета движения товарно-материальных
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

CREATE EXCEPTION INV_E_INVALIDMOVEMENT 'The movement was made incorrect!';

COMMIT;

/*
 *
 *  Список карточек движения ТМЦ
 *
 */

CREATE TABLE inv_card
(
  id                    dintkey,              /* идентификатор */
  parent                dforeignkey,          /* ссылка на родительскую карточку */

  goodkey               dintkey,              /* ссылка на товар */

  documentkey           dintkey,              /* ссылка на документ создавший карту */
  firstdocumentkey      dintkey,              /* ссылка на первый докуиент создавший карточку */

  firstdate             ddate NOT NULL,       /* дата первого появления карточки */

  companykey            dintkey,              /* ссылка на нашу компанию */

  reserved              dreserved             /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_card ADD CONSTRAINT inv_pk_card
  PRIMARY KEY (id);

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_mk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_fmk
  FOREIGN KEY (firstdocumentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_companykey
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany (companykey)
  ON UPDATE CASCADE;

ALTER TABLE inv_card ADD CONSTRAINT inv_fk_card_parent
  FOREIGN KEY (parent) REFERENCES inv_card (id)
  ON UPDATE CASCADE;


COMMIT;


/*
 *
 *  Движение ТМЦ
 *
 */


CREATE TABLE inv_movement
(
  id                    dintkey,              /* идентификатор */
  movementkey           dintkey,              /* идентификатор движения */

  movementdate          ddate NOT NULL,       /* дата движения */

  documentkey           dintkey,              /* ссылка на документ */
  contactkey            dintkey,              /* ссылка на контакт */

  cardkey               dintkey,              /* ссылка на карточку */
  goodkey               dintkey,              /* ссылка на товар */

  debit                 dquantity DEFAULT 0,  /* приход ТМЦ (услуг) в количественном выражении */
  credit                dquantity DEFAULT 0,  /* расход ТМЦ (услуг) в количественном выражении */

  disabled              dboolean DEFAULT 0,   /* отключена ли запись */
  reserved              dreserved             /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_movement ADD CONSTRAINT inv_pk_movement
  PRIMARY KEY (id);

ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_dk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_ck
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id)
  ON UPDATE CASCADE;

ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_cardk
  FOREIGN KEY (cardkey) REFERENCES inv_card (id)
  ON UPDATE CASCADE;

ALTER TABLE inv_movement ADD CONSTRAINT inv_fk_movement_goodk
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON UPDATE CASCADE;


COMMIT;

CREATE INDEX INV_X_MOVEMENT_CCD ON INV_MOVEMENT (
  CARDKEY, CONTACTKEY, MOVEMENTDATE);

COMMIT;

CREATE INDEX INV_X_MOVEMENT_MK ON INV_MOVEMENT (
  MOVEMENTKEY);

COMMIT;

/*
 *
 *  Рассчитанные остатки по
 *  определенной карточке.
 *
 */

CREATE TABLE inv_balance
(
  cardkey               dintkey,              /* ссылка на карточку */
  contactkey            dintkey,              /* ссылка на контакт */

  balance               dcurrency NOT NULL,   /* остаток на карточке */
  goodkey               dintkey,              /* ссылка на товар */

  reserved              dreserved             /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_balance ADD CONSTRAINT inv_fk_balance_ck
  FOREIGN KEY (cardkey) REFERENCES inv_card (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_balance ADD CONSTRAINT inv_fk_balance_contk
  FOREIGN KEY (contactkey) REFERENCES gd_contact(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_balance ADD CONSTRAINT inv_fk_balance_gk
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;


ALTER TABLE inv_balance ADD CONSTRAINT inv_pk_balance
  PRIMARY KEY (cardkey, contactkey);

COMMIT;

CREATE INDEX INV_X_BALANCE_CB ON INV_BALANCE (
  CONTACTKEY, BALANCE);

COMMIT;


SET TERM ^ ;

CREATE PROCEDURE inv_makerest                               
AS                                               
  DECLARE VARIABLE CONTACTKEY INTEGER;           
  DECLARE VARIABLE CARDKEY INTEGER;              
  DECLARE VARIABLE GOODKEY INTEGER;
  DECLARE VARIABLE BALANCE NUMERIC(15, 4);       
BEGIN                                            
  DELETE FROM INV_BALANCE;                      
  FOR                                           
    SELECT m.contactkey, m.goodkey, m.cardkey, SUM(m.debit - m.credit) 
      FROM                                                  
        inv_movement m                                      
      WHERE disabled = 0                                    
    GROUP BY m.contactkey, m.goodkey, m.cardkey                        
    INTO :contactkey, :goodkey, :cardkey, :balance                    
  DO                                                        
    INSERT INTO inv_balance (contactkey, goodkey, cardkey, balance)  
      VALUES (:contactkey, :goodkey, :cardkey, :balance);             
END 
^

SET TERM ; ^

COMMIT;

CREATE TABLE inv_balanceoption(
  id                      DINTKEY,
  name                    DNAME,
  viewfields              DBLOBTEXT80,
  sumfields               DBLOBTEXT80,
  GOODVIEWFIELDS          DBLOBTEXT80,
  GOODSUMFIELDS           DBLOBTEXT80,
  branchkey               dforeignkey,               /* Ветка в исследователе */                                 
  usecompanykey           dboolean,
  ruid                    DRUID,
  restrictremainsby       DTEXT32
);

COMMIT;

ALTER TABLE inv_balanceoption ADD CONSTRAINT inv_pk_balanceoption
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE inv_balanceoption ADD CONSTRAINT gd_fk_balanceoption_branchkey 
  FOREIGN KEY (branchkey) REFERENCES gd_command (id) ON UPDATE CASCADE;

COMMIT;


CREATE GENERATOR inv_g_balancenum;
SET GENERATOR inv_g_balancenum TO 0;

COMMIT;


SET TERM ^ ;

CREATE TRIGGER inv_bi_balanceoption FOR inv_balanceoption
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE id INTEGER;
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
    
END
^



/*
 *  Триггер создания уникального кода
 */

CREATE TRIGGER inv_bi_card FOR inv_card
  BEFORE INSERT
  POSITION 0
  AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END;
^

CREATE TRIGGER inv_bu_card FOR inv_card
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE firstdocumentkey INTEGER;
  DECLARE VARIABLE firstdate DATE;
BEGIN

  IF ((OLD.parent <> NEW.parent) OR (OLD.parent IS null and NEW.parent IS NOT NULL)) THEN
  BEGIN
    SELECT firstdocumentkey, firstdate FROM inv_card
    WHERE id = NEW.parent
    INTO :firstdocumentkey, :firstdate;

    NEW.firstdocumentkey = :firstdocumentkey;
    NEW.firstdate = :firstdate;
  END

  IF ((OLD.firstdocumentkey <> NEW.firstdocumentkey) OR
       (OLD.firstdate <> NEW.firstdate)) THEN
    UPDATE inv_card SET
      firstdocumentkey = NEW.firstdocumentkey,
      firstdate = NEW.firstdate
    WHERE
      parent = NEW.id;

END;
^

CREATE TRIGGER inv_bu_card_goodkey FOR inv_card
  BEFORE UPDATE
  POSITION 1
AS
BEGIN
  IF (NEW.GOODKEY <> OLD.GOODKEY) THEN
  BEGIN
    UPDATE inv_movement SET goodkey = NEW.goodkey
    WHERE cardkey = NEW.id;

    UPDATE inv_balance SET goodkey = NEW.goodkey
    WHERE cardkey = NEW.id;
  END
END;
^


CREATE TRIGGER INV_BD_CARD FOR INV_CARD
ACTIVE BEFORE DELETE POSITION 0
AS
BEGIN
  DELETE FROM INV_CARD
    WHERE
      PARENT = OLD.ID AND DOCUMENTKEY = OLD.DOCUMENTKEY;
END;
^

CREATE TRIGGER inv_bi_card_block FOR inv_card
  INACTIVE
  BEFORE INSERT
  POSITION 28017
AS
  DECLARE VARIABLE D DATE;
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (GEN_ID(gd_g_block, 0) > 0) THEN
  BEGIN
    SELECT doc.documentdate, doc.documenttypekey
    FROM gd_document doc
    WHERE doc.id = NEW.documentkey
    INTO :D, :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      IF ((D - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
      BEGIN
        BG = GEN_ID(gd_g_block_group, 0);
        IF (:BG = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END ELSE
        BEGIN
          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
            INTO :IG;
          IF (BIN_AND(:BG, :IG) = 0) THEN
          BEGIN
            EXCEPTION gd_e_block;
          END
        END
      END
    END
  END
END
^

CREATE TRIGGER inv_bu_card_block FOR inv_card
  INACTIVE
  BEFORE UPDATE
  POSITION 28017
AS
  DECLARE VARIABLE D DATE;
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (GEN_ID(gd_g_block, 0) > 0) THEN
  BEGIN
    SELECT doc.documentdate, doc.documenttypekey
    FROM gd_document doc
    WHERE doc.id = NEW.documentkey
    INTO :D, :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      IF ((D - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
      BEGIN
        BG = GEN_ID(gd_g_block_group, 0);
        IF (:BG = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END ELSE
        BEGIN
          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
            INTO :IG;
          IF (BIN_AND(:BG, :IG) = 0) THEN
          BEGIN
            EXCEPTION gd_e_block;
          END
        END
      END
    END
  END
END
^

CREATE TRIGGER inv_bd_card_block FOR inv_card
  INACTIVE
  BEFORE DELETE
  POSITION 28017
AS
  DECLARE VARIABLE D DATE;
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (GEN_ID(gd_g_block, 0) > 0) THEN
  BEGIN
    SELECT doc.documentdate, doc.documenttypekey
    FROM gd_document doc
    WHERE doc.id = OLD.documentkey
    INTO :D, :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      IF ((D - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
      BEGIN
        BG = GEN_ID(gd_g_block_group, 0);
        IF (:BG = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END ELSE
        BEGIN
          SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
            INTO :IG;
          IF (BIN_AND(:BG, :IG) = 0) THEN
          BEGIN
            EXCEPTION gd_e_block;
          END
        END
      END
    END
  END
END
^

/*
 *
 *  После добавлением движения
 *  осуществляем расчет сальдо
 *
 */


CREATE TRIGGER inv_ai_movement FOR inv_movement
  AFTER INSERT
  POSITION 0
AS
  DECLARE VARIABLE NEWBALANCE NUMERIC(10, 4);
BEGIN
  /* если запись с остатком есть - изменяем ее, если нет - создаем */
  IF (EXISTS(
    SELECT BALANCE
    FROM INV_BALANCE
    WHERE CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY)
  )
  THEN BEGIN
    UPDATE INV_BALANCE
    SET
      BALANCE = BALANCE + (NEW.DEBIT - NEW.CREDIT)
    WHERE
      CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY;
  END ELSE BEGIN
    INSERT INTO INV_BALANCE
      (CARDKEY, CONTACTKEY, BALANCE)
    VALUES
      (NEW.CARDKEY, NEW.CONTACTKEY, NEW.DEBIT - NEW.CREDIT);
  END
END;
^


/*
 *
 *  После изменения движения
 *  осуществляем расчет сальдо
 *
 */

CREATE TRIGGER INV_AU_MOVEMENT FOR INV_MOVEMENT
  ACTIVE
  AFTER UPDATE
  POSITION 0
AS
  DECLARE VARIABLE existscontaccard INTEGER;
BEGIN
  /* если запись с остатком есть - изменяем ее, если нет - создаем */
  existscontaccard = 1;
  IF (OLD.disabled = 0) THEN
  BEGIN
    IF (EXISTS(
      SELECT BALANCE
      FROM INV_BALANCE
      WHERE CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY))
    THEN BEGIN
      UPDATE INV_BALANCE
      SET
        BALANCE = BALANCE - (OLD.DEBIT - OLD.CREDIT)
      WHERE
        CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY;
    END
    ELSE
      existscontaccard = 0;
  END
  
  IF (NEW.disabled = 0) THEN
  BEGIN
    IF (
       (NEW.contactkey <> OLD.contactkey) AND
       (NEW.cardkey = OLD.cardkey) AND
       (NEW.debit = OLD.debit) AND
       (NEW.credit = OLD.credit) AND
       (OLD.disabled = 0) AND
       (existscontaccard = 0)
       )
    THEN
      existscontaccard = 0;
    ELSE
    IF (EXISTS(
        SELECT BALANCE
        FROM INV_BALANCE
        WHERE CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY))
    THEN BEGIN
      UPDATE INV_BALANCE
      SET
        BALANCE = BALANCE + (NEW.DEBIT - NEW.CREDIT)
      WHERE
        CARDKEY = NEW.CARDKEY AND CONTACTKEY = NEW.CONTACTKEY;
    END ELSE BEGIN
        INSERT INTO INV_BALANCE
          (CARDKEY, CONTACTKEY, BALANCE)
        VALUES
          (NEW.CARDKEY, NEW.CONTACTKEY, NEW.DEBIT - NEW.CREDIT);
    END
  END
END;
^

/*
 *
 *  После изменения движения
 *  осуществляем расчет сальдо
 *
 */

CREATE TRIGGER inv_ad_movement FOR inv_movement
  AFTER DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.disabled = 0) THEN
  BEGIN
    /*
    эта проверка тут излишняя.

    IF (EXISTS(
      SELECT BALANCE
      FROM INV_BALANCE
      WHERE CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY))
    THEN BEGIN
    */
      UPDATE INV_BALANCE
      SET
        BALANCE = BALANCE - (OLD.DEBIT - OLD.CREDIT)
      WHERE
        CARDKEY = OLD.CARDKEY AND CONTACTKEY = OLD.CONTACTKEY;
    /*
    END
    */
  END

END;
^

CREATE EXCEPTION inv_e_movementchange 'Can not change documentkey in movement'^

CREATE TRIGGER INV_BI_MOVEMENT FOR INV_MOVEMENT
ACTIVE BEFORE INSERT POSITION 0
AS
  DECLARE VARIABLE balance NUMERIC(15, 4);
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  IF (NEW.debit IS NULL) THEN
    NEW.debit = 0;

  IF (NEW.credit IS NULL) THEN
    NEW.credit = 0;

  IF (NEW.credit > 0) THEN
  BEGIN
    SELECT balance FROM inv_balance
    WHERE
      contactkey = NEW.contactkey
       AND cardkey = NEW.cardkey
    INTO :balance;
    IF (:balance IS NULL) THEN
      balance = 0;
    IF ((:balance > 0) AND (:balance < NEW.credit)) THEN
    BEGIN
      EXCEPTION INV_E_INVALIDMOVEMENT;
    END
  END

END;
^

CREATE TRIGGER INV_BI_MOVEMENT_GOODKEY FOR INV_MOVEMENT
ACTIVE BEFORE INSERT POSITION 1
AS
BEGIN
  SELECT goodkey FROM inv_card
  WHERE id = NEW.cardkey
  INTO NEW.goodkey;
END;
^

CREATE TRIGGER INV_BU_MOVEMENT FOR INV_MOVEMENT
  ACTIVE
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE balance NUMERIC(15, 4);
BEGIN
  IF (RDB$GET_CONTEXT('USER_TRANSACTION', 'GD_MERGING_RECORDS') IS NULL) THEN
  BEGIN
    IF (NEW.documentkey <> OLD.documentkey) THEN
      EXCEPTION inv_e_movementchange;

    IF ((NEW.disabled = 1) OR (NEW.contactkey <> OLD.contactkey) OR (NEW.cardkey <> OLD.cardkey)) THEN
    BEGIN
      IF (OLD.debit > 0) THEN
      BEGIN
        SELECT balance FROM inv_balance
        WHERE contactkey = OLD.contactkey
          AND cardkey = OLD.cardkey
        INTO :balance;
        IF (COALESCE(:balance, 0) < OLD.debit) THEN
          EXCEPTION INV_E_INVALIDMOVEMENT;
      END
    END ELSE
    BEGIN
      IF (OLD.debit > NEW.debit) THEN
      BEGIN
        SELECT balance FROM inv_balance
        WHERE contactkey = OLD.contactkey
          AND cardkey = OLD.cardkey
        INTO :balance;
        balance = COALESCE(:balance, 0);
        IF ((:balance > 0) AND (:balance < OLD.debit - NEW.debit)) THEN
          EXCEPTION INV_E_INVALIDMOVEMENT;
      END ELSE
      BEGIN
        IF (NEW.credit > OLD.credit) THEN
        BEGIN
          SELECT balance FROM inv_balance
          WHERE contactkey = OLD.contactkey
            AND cardkey = OLD.cardkey
          INTO :balance;
          balance = COALESCE(:balance, 0);
          IF ((:balance > 0) AND (:balance < NEW.credit - OLD.credit)) THEN
            EXCEPTION INV_E_INVALIDMOVEMENT;
        END
      END
    END
  END
END;
^

CREATE TRIGGER INV_BU_MOVEMENT_GOODKEY FOR INV_MOVEMENT
ACTIVE BEFORE UPDATE POSITION 1
AS
BEGIN
  IF ((NEW.cardkey <> OLD.cardkey) OR (NEW.goodkey IS NULL)) THEN
    SELECT goodkey FROM inv_card
    WHERE id = NEW.cardkey
    INTO NEW.goodkey;
END;
^


CREATE TRIGGER INV_BD_MOVEMENT FOR INV_MOVEMENT
BEFORE DELETE POSITION 0
AS
  DECLARE VARIABLE DOCKEY INTEGER;
  DECLARE VARIABLE FIRSTDOCKEY INTEGER;
  DECLARE VARIABLE CONTACTTYPE INTEGER;
  DECLARE VARIABLE BALANCE NUMERIC(15, 4);
BEGIN
  /* Trigger body */
  IF ((OLD.disabled = 0) AND NOT EXISTS(SELECT * FROM INV_MOVEMENT WHERE DOCUMENTKEY = OLD.DOCUMENTKEY AND DISABLED = 1)) THEN
  BEGIN
  
    SELECT documentkey, firstdocumentkey FROM inv_card WHERE id = OLD.cardkey
    INTO :dockey, :firstdockey;
  
    IF (:dockey = OLD.documentkey) THEN
    BEGIN
      IF (EXISTS (SELECT id FROM inv_movement m WHERE m.cardkey = OLD.cardkey AND m.documentkey <> OLD.documentkey)) THEN
        EXCEPTION INV_E_INVALIDMOVEMENT;
    END
    ELSE
      IF (OLD.debit > 0) THEN
      BEGIN
        SELECT contacttype FROM gd_contact WHERE id = OLD.contactkey
        INTO :contacttype;
        IF (:contacttype = 2 or :contacttype = 4) THEN
        BEGIN
          SELECT balance FROM inv_balance
          WHERE
            contactkey = OLD.contactkey
            AND cardkey = OLD.cardkey
          INTO :balance;
          IF (:balance IS NULL) THEN
            balance = 0;
          IF (:balance < OLD.debit) THEN
          BEGIN
            EXCEPTION INV_E_INVALIDMOVEMENT;
          END
        END
      END
      
  END

END;
^

CREATE PROCEDURE INV_P_GETCARDS (
    PARENT INTEGER)
RETURNS (
    ID INTEGER)
AS
BEGIN

  FOR
    SELECT ID FROM INV_CARD WHERE PARENT = :PARENT
    INTO :ID
  DO
  BEGIN
    SUSPEND;
    FOR
      SELECT ID FROM INV_P_GETCARDS(:ID)
      INTO :ID
    DO
      SUSPEND;
  END
END;
^

CREATE OR ALTER PROCEDURE INV_GETCARDMOVEMENT (
    CARDKEY INTEGER,
    CONTACTKEY INTEGER,
    DATEEND DATE)
RETURNS (
    REMAINS NUMERIC(15, 4))
AS
BEGIN
  REMAINS = 0;
  SELECT SUM(m.debit - m.credit)
  FROM inv_movement m
  WHERE m.cardkey = :CARDKEY AND m.contactkey = :CONTACTKEY
    AND m.movementdate > :DATEEND AND m.disabled = 0
  INTO :REMAINS;
  IF (REMAINS IS NULL) THEN
    REMAINS = 0;
  SUSPEND;
END
^

CREATE TRIGGER INV_BI_BALANCE_GOODKEY FOR INV_BALANCE
ACTIVE BEFORE INSERT POSITION 0
AS
BEGIN
  SELECT goodkey FROM inv_card
  WHERE id = NEW.cardkey
  INTO NEW.goodkey;
END;
^

CREATE TRIGGER INV_BU_BALANCE FOR INV_BALANCE
ACTIVE BEFORE UPDATE POSITION 0
AS
  DECLARE VARIABLE quantity NUMERIC(15, 4);
BEGIN
/*Тело триггера*/
  IF (NEW.contactkey <> OLD.contactkey) THEN
  BEGIN
    /*
    IF (EXISTS (SELECT * FROM inv_balance WHERE contactkey = NEW.contactkey AND
      cardkey = NEW.cardkey))
    THEN
    BEGIN
    */
      quantity = NULL;
      SELECT balance
        FROM inv_balance
        WHERE contactkey = NEW.contactkey AND cardkey = NEW.cardkey
        INTO :quantity;
      IF (NOT (:quantity IS NULL)) THEN
      BEGIN
        DELETE FROM inv_balance
        WHERE
          contactkey = NEW.contactkey AND cardkey = NEW.cardkey;

        NEW.balance = NEW.balance + :quantity;
      END
    /*
    END
    */
  END
END
^

CREATE TRIGGER INV_BU_BALANCE_GOODKEY FOR INV_BALANCE
  ACTIVE
  BEFORE UPDATE
  POSITION 1
AS
BEGIN
  IF ((NEW.cardkey <> OLD.cardkey) OR (NEW.goodkey IS NULL)) THEN
    SELECT goodkey FROM inv_card
    WHERE id = NEW.cardkey
    INTO NEW.goodkey;
END;
^

CREATE TRIGGER inv_bi_movement_block FOR inv_movement
  INACTIVE
  BEFORE INSERT
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((NEW.movementdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
    WHERE d.id = NEW.documentkey
    INTO :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

CREATE TRIGGER inv_bu_movement_block FOR inv_movement
  INACTIVE
  BEFORE UPDATE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF (((NEW.movementdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) 
      OR ((OLD.movementdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0))) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
    WHERE d.id = NEW.documentkey
    INTO :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

CREATE TRIGGER inv_bd_movement_block FOR inv_movement
  INACTIVE
  BEFORE DELETE
  POSITION 28017
AS
  DECLARE VARIABLE IG INTEGER;
  DECLARE VARIABLE BG INTEGER;
  DECLARE VARIABLE DT INTEGER;
  DECLARE VARIABLE F INTEGER;
BEGIN
  IF ((OLD.movementdate - CAST('17.11.1858' AS DATE)) < GEN_ID(gd_g_block, 0)) THEN
  BEGIN
    SELECT d.documenttypekey
    FROM gd_document d
    WHERE d.id = OLD.documentkey
    INTO :DT;

    EXECUTE PROCEDURE gd_p_exclude_block_dt (:DT)
      RETURNING_VALUES :F;

    IF(:F = 0) THEN
    BEGIN
      BG = GEN_ID(gd_g_block_group, 0);
      IF (:BG = 0) THEN
      BEGIN
        EXCEPTION gd_e_block;
      END ELSE
      BEGIN
        SELECT ingroup FROM gd_user WHERE ibname = CURRENT_USER
          INTO :IG;
        IF (BIN_AND(:BG, :IG) = 0) THEN
        BEGIN
          EXCEPTION gd_e_block;
        END
      END
    END
  END
END
^

SET TERM ; ^

COMMIT;
