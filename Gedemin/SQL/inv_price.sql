
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    inv_price.sql

  Abstract

    Таблицы для учета прайс-листов.

  Author

    Denis Romanovski (19 october 2001)

  Revisions history

    Initial  19.10.2001  Dennis    Initial version

  Status

    Draft

*/

CREATE TABLE inv_price
(
  documentkey      dintkey,                 /* Ссылка на документ */

  name             dname,                   /* Наименвоание прайс-листа */
  description      dtext180,                /* Описание прайс-листа */

  relevancedate    ddate NOT NULL,          /* Дата актуальности (начала действия) */

  reserved         dinteger                 /* Зарезервировано */
);

COMMIT;

ALTER TABLE inv_price ADD CONSTRAINT inv_pk_price_dk
  PRIMARY KEY(documentkey);

ALTER TABLE inv_price ADD CONSTRAINT inv_fk_price_dk
  FOREIGN KEY(documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

CREATE TABLE inv_priceline
(
  documentkey      dintkey,                 /* Ссылка на позицию документа */
  pricekey         dmasterkey,                 /* Ссылка на шапку прайс-листа */

  goodkey          dintkey,                 /* Ссылка на ТМЦ */

  reserved         dinteger                 /* Зарезервировано */
);

COMMIT;

ALTER TABLE inv_priceline ADD CONSTRAINT inv_pk_priceline_dk
  PRIMARY KEY(documentkey);

ALTER TABLE inv_priceline ADD CONSTRAINT inv_fk_priceline_dk
  FOREIGN KEY(documentkey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE inv_priceline ADD CONSTRAINT inv_fk_priceline_pk
  FOREIGN KEY(pricekey) REFERENCES gd_document(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE inv_priceline ADD CONSTRAINT inv_fk_priceline_gk
  FOREIGN KEY(goodkey) REFERENCES gd_good(id)
  ON UPDATE CASCADE;

COMMIT;

