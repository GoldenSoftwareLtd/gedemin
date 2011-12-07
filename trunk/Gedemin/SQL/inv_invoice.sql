
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus


  Script

    inv_invoice.sql

  Abstract

    Скрипт для учета накладных

  Author

    Romanovski Denis (23.07.2001)

  Revisions history

    1.0    Julia    23.01.2001    Initial version.

  Status 


*/

/*
 *
 *  Приходная накладная на получение товаров
 *  от поставщика.
 *
 */

CREATE TABLE inv_incomeinvoice
(
  documentkey               dintkey,               /* связь с документом */

  supplierkey               dintkey,               /* поставщик */
  inventorykey              dintkey,               /* склад */

  reserved                  dinteger               /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_incomeinvoice ADD CONSTRAINT inv_fk_incomeinvoice_dk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_incomeinvoice ADD CONSTRAINT inv_fk_incomeinvoice_sk
  FOREIGN KEY (supplierkey) REFERENCES gd_contact (id);

ALTER TABLE inv_incomeinvoice ADD CONSTRAINT inv_fk_incomeinvoice_ik
  FOREIGN KEY (inventorykey) REFERENCES gd_contact (id);

ALTER TABLE inv_incomeinvoice ADD CONSTRAINT inv_pk_incomeinvoice
  PRIMARY KEY (documentkey);

COMMIT;

/*
 *
 *  Позиции приходной накладной.
 *
 */

CREATE TABLE inv_incomeinvoiceline
(
  documentkey               dintkey,               /* ссылка на позицию документа */
  invoicekey                dintkey,               /* связь с накладной */

  reserved                  dinteger               /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_incomeinvoiceline ADD CONSTRAINT inv_fk_incomeinvoiceline_dk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_incomeinvoiceline ADD CONSTRAINT inv_pk_incomeinvoiceline
  PRIMARY KEY (documentkey);

ALTER TABLE inv_incomeinvoiceline ADD CONSTRAINT inv_fk_incomeinvoiceline_ik
  FOREIGN KEY (invoicekey) REFERENCES inv_incomeinvoice (documentkey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;


/*
 *
 *  Расходная накладная на отпуск товаров
 *  на сторону.
 *
 */

CREATE TABLE inv_outlayinvoice
(
  documentkey               dintkey,               /* связь с документом */
  optionkey                 dintkey,               /* связь с опцией накладной */

  receiverkey               dintkey,               /* покупатель */

  reserved                  dinteger               /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_outlayinvoice ADD CONSTRAINT inv_fk_outlayinvoice_dk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_outlayinvoice ADD CONSTRAINT inv_fk_outlayinvoice_rk
  FOREIGN KEY (receiverkey) REFERENCES gd_contact (id);

ALTER TABLE inv_outlayinvoice ADD CONSTRAINT inv_pk_outlayinvoice
  PRIMARY KEY (documentkey);

ALTER TABLE inv_outlayinvoice ADD CONSTRAINT inv_fk_outlayinvoice_ok
  FOREIGN KEY (optionkey) REFERENCES inv_option (id);

COMMIT;

/*
 *
 *  Позиции расходной накладной.
 *
 */

CREATE TABLE inv_outlayinvoiceline
(
  documentkey               dintkey,               /* идентификатор позиции */
  invoicekey                dintkey,               /* связь с накладной */

/*  inventorykey              dintkey,*/               /* связь со складом */

  reserved                  dinteger               /* зарезервировано */
);

COMMIT;

ALTER TABLE inv_outlayinvoiceline ADD CONSTRAINT inv_fk_outlayinvoiceline_pk
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE inv_outlayinvoiceline ADD CONSTRAINT inv_pk_outlayinvoiceline
  PRIMARY KEY (documentkey);

/*ALTER TABLE inv_outlayinvoiceline ADD CONSTRAINT inv_fk_outlayinvoiceline_ink
  FOREIGN KEY (inventorykey) REFERENCES gd_contact (id);*/

ALTER TABLE inv_outlayinvoiceline ADD CONSTRAINT inv_fk_outlayinvoiceline_ik
  FOREIGN KEY (invoicekey) REFERENCES inv_outlayinvoice (documentkey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;



SET TERM ^ ;

/*
 *  Триггер удаления документа при удалении позиции приходной накладной
 */

CREATE TRIGGER inv_ad_incomeinvoiceline FOR inv_incomeinvoiceline
  AFTER DELETE
  POSITION 0
  AS
BEGIN
  DELETE FROM
    gd_document
  WHERE
    id = OLD.documentkey;
END;
^

/*
 *  Триггер удаления документа при удалении позиции расходной накладной
 */

CREATE TRIGGER inv_ad_outlayinvoiceline FOR inv_outlayinvoiceline
  AFTER DELETE
  POSITION 0
  AS
BEGIN
  DELETE FROM
    gd_document
  WHERE
    id = OLD.documentkey;
END;
^


/*
 *
 *  Осуществляем группировку данных о расходе ТМЦ и возвращаем
 *  результат в виде набора записей.
 *
 */

CREATE PROCEDURE inv_p_outlayinvoiceline (INVOICEKEY INTEGER)
RETURNS
  (
    GOODKEY INTEGER,
    DOCUMENTKEY INTEGER,
    INVENTORYKEY INTEGER,
    QUANTITY DECIMAL(15, 4),
    SUMNCU DECIMAL(15, 4),
    SUMCURR DECIMAL(15, 4),
    SUMEQ DECIMAL(15, 4),
    CARDKEY INTEGER
  )
AS
BEGIN
  IF (:INVOICEKEY IS NOT NULL) THEN
    FOR
      SELECT
        G.ID, M.DOCUMENTKEY, M.CONTACTKEY, SUM(M.CREDIT), SUM(M.SUMNCU),
        SUM(M.SUMCURR), SUM(M.SUMEQ), MIN(C.ID)
      FROM
        GD_DOCUMENT D
          JOIN INV_MOVEMENT M ON (D.ID = M.DOCUMENTKEY) AND (M.DEBIT = 0)
          JOIN INV_CARD C ON (C.ID = M.CARDKEY)
          JOIN GD_GOOD G ON (G.ID = C.GOODKEY)
      WHERE
        D.PARENT = :INVOICEKEY
      GROUP BY
        G.ID, M.DOCUMENTKEY, M.CONTACTKEY
      INTO
        GOODKEY, DOCUMENTKEY, INVENTORYKEY,
        QUANTITY, SUMNCU, SUMCURR, SUMEQ, CARDKEY
    DO
      SUSPEND;
END;
^

SET TERM ; ^

COMMIT;
