
/*

  Copyright (c) 2000-2013 by Golden Software of Belarus

  Script

    gd_good.sql

  Abstract

    An Interbase script for access.

  Author

    Andrey Shadevsky (30.05.00)

  Revisions history

    Initial  30.05.00  JKL    Initial version
    2.00     07.09.00  MSH
    2.01     08.09.00  MSH    Add gd_goodbarcode table

  Status 
    
*/


/****************************************************

   Таблица для хранения групп товаров.

*****************************************************/

CREATE TABLE gd_goodgroup
(
  id               dintkey,                     /* Первичный ключ          */
  parent           dparent,                     /* родитель                */
  lb               dlb,                         /* левая граница           */
  rb               drb,                         /* правая граница          */

  name             dname,                       /* имя                     */
  alias            dnullalias,                  /* Код группы              */
  description      dblobtext80_1251,            /* описание                */

  creatorkey       dforeignkey,
  creationdate     dcreationdate,

  editorkey        dforeignkey,                 /* Кто         изменил запись */
  editiondate      deditiondate,                /* Когда      изменена запись */

  disabled         ddisabled,                   /* отключен                */
  reserved         dreserved,                   /* зарезервировано         */

  afull            dsecurity,                   /* Полные права доступа    */
  achag            dsecurity,                   /* Изменения права доступа */
  aview            dsecurity                    /* Просмотра права доступа */
);

ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_pk_goodgroup
  PRIMARY KEY (id);

ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_parent
  FOREIGN KEY (parent) REFERENCES gd_goodgroup (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_goodgroup ADD CONSTRAINT gd_fk_goodgroup_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

COMMIT;

CREATE EXCEPTION gd_e_cannotchange_goodgroup 'Can not change good group!';

SET TERM ^ ;

CREATE TRIGGER gd_bi_goodgroup FOR gd_goodgroup
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  /* Если ключ не присвоен, присваиваем */
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE OR ALTER TRIGGER gd_ad_goodgroup_protect FOR gd_goodgroup
  ACTIVE
  AFTER DELETE
  POSITION 0
AS
BEGIN
  IF (UPPER(OLD.name) IN ('ТАРА', 'СТЕКЛОПОСУДА', 'ДРАГМЕТАЛЛЫ')) THEN
    EXCEPTION gd_e_cannotchange_goodgroup  'Нельзя удалить группу ' || OLD.Name;
END
^

CREATE OR ALTER TRIGGER gd_ai_goodgroup_protect FOR gd_goodgroup
  ACTIVE
  AFTER INSERT
  POSITION 0
AS
BEGIN
  IF (UPPER(NEW.name) IN ('ТАРА', 'СТЕКЛОПОСУДА', 'ДРАГМЕТАЛЛЫ')) THEN
  BEGIN
    IF (EXISTS (SELECT * FROM gd_goodgroup WHERE id <> NEW.id AND UPPER(name) = UPPER(NEW.name))) THEN
      EXCEPTION gd_e_cannotchange_goodgroup  'Нельзя повторно создать группу ' || NEW.Name;
  END
END
^

CREATE OR ALTER TRIGGER gd_au_goodgroup_protect FOR gd_goodgroup
  ACTIVE
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  IF ((UPPER(NEW.name) IN ('ТАРА', 'СТЕКЛОПОСУДА', 'ДРАГМЕТАЛЛЫ'))
    OR (UPPER(OLD.name) IN ('ТАРА', 'СТЕКЛОПОСУДА', 'ДРАГМЕТАЛЛЫ'))) THEN
  BEGIN
    IF (NEW.name <> OLD.name OR NEW.parent IS DISTINCT FROM OLD.parent) THEN
      EXCEPTION gd_e_cannotchange_goodgroup  'Нельзя изменять стандартную группу ' || NEW.Name;
  END
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения единиц измерения.

*****************************************************/

CREATE TABLE gd_value
(
  id            dintkey,        /* Первичный ключ                  */
  name          dname,          /* Наименование                    */
  description   dtext80,        /* Описание                        */
  goodkey       dforeignkey,    /* Ссылка на ТМЦ по данной ед.изм. */
  ispack        dboolean,       /* Используется для упаковки       */
  editiondate   deditiondate
);

ALTER TABLE gd_value ADD CONSTRAINT gd_pk_value
  PRIMARY KEY (id);

COMMIT;


SET TERM ^ ;

CREATE TRIGGER gd_bi_value FOR gd_value
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения справочника ТНВД.

*****************************************************/

CREATE TABLE gd_tnvd
(
  id            dintkey,        /* Первичный ключ               */
  name          dname,          /* Наименование                 */
  description   dtext180,       /* Описание                     */
  editiondate   deditiondate
);

ALTER TABLE gd_tnvd ADD CONSTRAINT gd_pk_tnvd
  PRIMARY KEY (id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_tnvd FOR gd_tnvd
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения товаров.

*****************************************************/

CREATE TABLE gd_good
(
  id               dintkey,                     /* Первичный ключ             */
  groupkey         dmasterkey,                  /* Принадлежность к группе    */
  name             dname,                       /* имя                        */
  alias            dnullalias,                  /* Шифр товара                */
  shortname        dtext40,                     /* Краткое наименование       */
  description      dtext180,                    /* описание                   */

  barcode          dbarcode,                    /* Штрих код                  */
  valuekey         dintkey,                     /* Базовая единица измерения  */
  tnvdkey          dforeignkey,                 /* Ссылка на код ТНВД         */
  discipline       daccountingdiscipline,       /* Вид учета ТМЦ              */                  

  isassembly       dboolean,                    /* Является ли комплектом     */

  creatorkey       dforeignkey,
  creationdate     dcreationdate,

  editorkey        dforeignkey,                 /* Кто         изменил запись */
  editiondate      deditiondate,                /* Когда      изменена запись */

  reserved         dreserved,                   /* Зарезервированно           */
  disabled         ddisabled,                   /* Отключено                  */

  afull            dsecurity,                   /* Полные права доступа       */
  achag            dsecurity,                   /* Изменения права доступа    */
  aview            dsecurity                    /* Просмотра права доступа    */
);

ALTER TABLE gd_good ADD CONSTRAINT gd_pk_good
  PRIMARY KEY (id);

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_groupkey
  FOREIGN KEY (groupkey) REFERENCES gd_goodgroup(id) 
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_valuekey
  FOREIGN KEY (valuekey) REFERENCES gd_value(id) 
  ON UPDATE CASCADE;

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_tnvdkey
  FOREIGN KEY (tnvdkey) REFERENCES gd_tnvd(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_editorkey
  FOREIGN KEY (editorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE gd_good ADD CONSTRAINT gd_fk_good_creatorkey
  FOREIGN KEY (creatorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

CREATE ASC INDEX gd_x_good_name
  ON gd_good (name);

CREATE ASC INDEX gd_x_good_barcode
  ON gd_good (barcode);

ALTER INDEX gd_x_good_barcode INACTIVE;

COMMIT;

ALTER TABLE gd_value ADD CONSTRAINT gd_fk_value_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id);  

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_good FOR gd_good
  BEFORE INSERT
  POSITION 0
AS
  DECLARE VARIABLE ATTRKEY INTEGER;
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE EXCEPTION gd_e_good 'Error'
^

CREATE OR ALTER TRIGGER gd_aiu_good FOR gd_good
  AFTER INSERT OR UPDATE
  POSITION 0
AS
BEGIN
  IF (INSERTING OR (UPDATING AND NEW.groupkey <> OLD.groupkey)) THEN
  BEGIN
    IF (EXISTS(SELECT * FROM gd_goodgroup WHERE id = NEW.groupkey AND COALESCE(disabled, 0) <> 0)) THEN
      EXCEPTION gd_e_good 'Нельзя добавлять/изменять товар в отключенной группе.';
  END
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения комплектов.

*****************************************************/

CREATE TABLE gd_goodset
(
  goodkey       dintkey,        /* Ссылка на товар(комплект)    */
  setkey        dintkey,        /* Ссылка на комплект           */
  goodcount     dpositive       /* Количество товара            */
);

ALTER TABLE gd_goodset ADD CONSTRAINT gd_pk_goodset
  PRIMARY KEY (setkey, goodkey);

ALTER TABLE gd_goodset ADD CONSTRAINT gd_fk_goodset_setkey
  FOREIGN KEY (setkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodset ADD CONSTRAINT gd_fk_goodset_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

/****************************************************

   Таблица для привязки к товару дополнительных единиц измерения.

*****************************************************/

CREATE TABLE gd_goodvalue
(
  goodkey       dintkey,        /* Ссылка на товар              */
  valuekey      dintkey,        /* Ссылка на единицу измерения  */
  scale         dpercent,       /* Коэффициент пересчета        */
  discount      dcurrency,      /* Скидка на товар              */
  decdigit      ddecdigits      /* Количество десятичных        */
);

ALTER TABLE gd_goodvalue ADD CONSTRAINT gd_pk_goodvalue
  PRIMARY KEY (goodkey, valuekey);

ALTER TABLE gd_goodvalue ADD CONSTRAINT gd_fk_goodvalue_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodvalue ADD CONSTRAINT gd_fk_goodvalue_valuekey
  FOREIGN KEY (valuekey) REFERENCES gd_value(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

/****************************************************

   Таблица для хранения налогов.

*****************************************************/

CREATE TABLE gd_tax
(
  id            dintkey,        /* Ключ уникальный              */
  name          dname,          /* Наименование                 */
  shot          dtext20,        /* Наименование переменной      */
  rate          dtax,           /* Ставка                       */
  editiondate   deditiondate
);

ALTER TABLE gd_tax ADD CONSTRAINT gd_pk_tax
  PRIMARY KEY (id);

CREATE UNIQUE INDEX gd_x_tax_name ON gd_tax
  (name);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_tax FOR gd_tax
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для привязки к налогов.

*****************************************************/

CREATE TABLE gd_goodtax
(
  goodkey       dintkey,        /* Ссылка на товар              */
  taxkey        dintkey,        /* Ссылка на налог              */
  datetax       ddate NOT NULL,  /* Дата принятия налога         */
  rate          dcurrency       /* Ставка                       */
);

ALTER TABLE gd_goodtax ADD CONSTRAINT gd_pk_goodtax
  PRIMARY KEY (goodkey, taxkey, datetax);

ALTER TABLE gd_goodtax ADD CONSTRAINT gd_fk_goodtax_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodtax ADD CONSTRAINT gd_fk_goodtax_taxkey
  FOREIGN KEY (taxkey) REFERENCES gd_tax(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_goodtax FOR gd_goodtax
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.rate IS NULL) THEN
    SELECT rate FROM gd_tax
    WHERE id = NEW.taxkey INTO NEW.rate;

  IF (NEW.datetax IS NULL) THEN
    NEW.datetax = 'NOW';

END;^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для вспомогательных штрих-кодов.

*****************************************************/

CREATE TABLE gd_goodbarcode
(
  id            dintkey,           /* Ключ уникальный              */
  goodkey       dintkey,           /* Ссылка на товар              */
  barcode       dbarcode NOT NULL, /* Штрих код                    */
  description   dtext180           /* Описание                     */
);

ALTER TABLE gd_goodbarcode ADD CONSTRAINT gd_pk_goodbarcode_id
  PRIMARY KEY (id);

ALTER TABLE gd_goodbarcode ADD CONSTRAINT gd_fk_goodbarcode_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

CREATE ASC INDEX gd_x_goodbarcode_barcode
  ON gd_goodbarcode (barcode);

ALTER INDEX gd_x_goodbarcode_barcode INACTIVE;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_goodbarcode FOR gd_goodbarcode
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

END;^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения драг. металлов.

*****************************************************/

CREATE TABLE gd_preciousemetal
(
  id            dintkey,        /* Ключ уникальный              */
  name          dname,          /* Наименование                 */
  description   dtext180,       /* Описание */
  editiondate   deditiondate
);

ALTER TABLE gd_preciousemetal ADD CONSTRAINT gd_pk_preciousemetal
  PRIMARY KEY (id);

COMMIT;

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_preciousemetal FOR gd_preciousemetal
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
      
END;^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для привязки драгметалов.

*****************************************************/

CREATE TABLE gd_goodprmetal
(
  goodkey       dintkey,          /* Ссылка на товар              */
  prmetalkey    dintkey,          /* Ссылка на драгметалл         */
  quantity      dgoldquantity DEFAULT 0 /* Количество                   */
);

ALTER TABLE gd_goodprmetal ADD CONSTRAINT gd_pk_goodprmetal
  PRIMARY KEY (goodkey, prmetalkey);

ALTER TABLE gd_goodprmetal ADD CONSTRAINT gd_fk_goodprmetal_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_goodprmetal ADD CONSTRAINT gd_fk_goodprmetal_prmetalkey
FOREIGN KEY (prmetalkey) REFERENCES gd_preciousemetal(id)
  ON UPDATE CASCADE;

COMMIT;