
/*
 *
 *  Набор мелких справочников, необходимых для
 *  заполнения накладной и квитанции приходования
 *  скота.
 *
 */

CREATE TABLE ctl_reference (
  id             dintkey,                         /* идентификатор */
  parent         dforeignkey,                     /* родительская ветвь */

  name           dname,                           /* номер накладной */
  alias          dalias,                          /* краткое наименование */
  description    dtext180,                        /* описание */

  formula        dtext254,                        /* формула расчета */

  afull          dsecurity,                       /* права доступа */
  achag          dsecurity,
  aview          dsecurity,

  disabled       dboolean DEFAULT 0,              /* не используется */
  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_reference ADD CONSTRAINT ctl_pk_reference
  PRIMARY KEY (id);

ALTER TABLE ctl_reference ADD CONSTRAINT ctl_fk_reference_parent
  FOREIGN KEY (parent) REFERENCES ctl_reference (id)
  ON UPDATE CASCADE ON DELETE CASCADE;

COMMIT;

/*
 *
 *  Приемная квитанция на оприходование скота
 *
 */

CREATE TABLE ctl_receipt (
  documentkey    dintkey,                         /* ключ документа */

  registersheet  dtext20,                         /* гуртовая ведомость */

/*  oncosts        dcurrency,  */                     /* организационно-накладные расходы */

  sumtotal       dcurrency,                       /* сумма */
  sumncu         dcurrency,                       /* итого к оплате */

  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_receipt ADD CONSTRAINT ctl_pk_receipt
  PRIMARY KEY (documentkey);

ALTER TABLE ctl_receipt ADD CONSTRAINT ctl_fk_receipt_documentkey
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON UPDATE CASCADE 
  ON DELETE CASCADE;

COMMIT;

/*
 *
 *  Домен для определение вида закупки:
 *  G - государство, C - частная компания, P - отдельный человек
 *
 */

CREATE DOMAIN dcattlepurchase
  AS VARCHAR(1)
  CHECK (VALUE IN ('G', 'C', 'P'));

/*
 *
 *  Вид поставки: C - центровывоз, S - самовызов,
 *  P - самовывоз разгрузочный пост
 *
 */

CREATE DOMAIN ddeliverykind
  AS VARCHAR(1)
  CHECK (VALUE IN ('C', 'S', 'P'));

/*
 *
 *  Вид накладной:
 *  C - на скот, M - на мясо,
 *
 */

CREATE DOMAIN dcattleinvoicekind
  AS VARCHAR(1)
  CHECK (VALUE IN ('C', 'M'));

/*
 *
 *  Отвес-накладная на оприходование скота
 *
 */

CREATE TABLE ctl_invoice(
  documentkey    dintkey,                         /* ключ документа */
  receiptkey     dforeignkey,                     /* []ключ квитанции */

  ttnnumber      dtext20,                         /* номер ТТН */

  kind           dcattleinvoicekind,              /* вид накладной: скот, мясо */

  departmentkey  dintkey,                         /* []подразделение */
  purchasekind   dcattlepurchase,                 /* вид закупки: гос-во, население, частный */

  supplierkey    dintkey,                         /* []поставщик */
  facekey        dforeignkey,                     /* []физическое лицо */
  deliverykind   ddeliverykind,                   /* вид поставки: центровывоз, самовызов, самовывоз разгрузочный пост */

  receivingkey   dintkey,                         /* []вид приемки */
  forceslaughter dboolean,                        /* вынужденный убой */
  wastecount     dinteger,                        /* кол-во бракованных голов */

  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_pk_invoice
  PRIMARY KEY (documentkey);

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_document
  FOREIGN KEY (documentkey) REFERENCES gd_document (id)
  ON UPDATE CASCADE 
  ON DELETE CASCADE;

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_receipt
  FOREIGN KEY (receiptkey) REFERENCES ctl_receipt (documentkey)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_department
  FOREIGN KEY (departmentkey) REFERENCES gd_contact (id);

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_supplier
  FOREIGN KEY (supplierkey) REFERENCES gd_contact (id);

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_face
  FOREIGN KEY (facekey) REFERENCES gd_contact (id);

ALTER TABLE ctl_invoice ADD CONSTRAINT ctl_fk_invoice_receiving
  FOREIGN KEY (receivingkey) REFERENCES ctl_reference (id);

COMMIT;

/*
 *
 *  Позиция отвес-накладной на приемку
 *  скота
 *
 */

CREATE TABLE ctl_invoicepos(
  id             dintkey,                         /* идентификатор */

  invoicekey     dintkey,                         /* []ключ накладной */
  goodkey        dintkey,                         /* []вид, группа, упитанность */

  quantity       dinteger,                        /* количество голов*/

  /* приходование животных: liveweight, realweight */
  /* приходование мяса: meatweight, realweight */

  meatweight     dcurrency,                       /* общий вес мяса */
  liveweight     dcurrency,                       /* общий вес живой */
  realweight     dcurrency,                       /* живой вес за вычетом скидки */

  destkey        dintkey,                         /* []назначение */

  pricekey       dforeignkey,                     /* []ключ прайс-листа */
  price          dcurrency,                       /* цена */
  sumncu         dcurrency,                       /* сумма */

  afull          dsecurity,                       /* права доступа */
  achag          dsecurity,
  aview          dsecurity,

  disabled       dboolean DEFAULT 0,              /* не используется */
  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_invoicepos ADD CONSTRAINT ctl_pk_invoicepos
  PRIMARY KEY (id);

ALTER TABLE ctl_invoicepos ADD CONSTRAINT ctl_fk_invoicepos_invoice
  FOREIGN KEY (invoicekey) REFERENCES ctl_invoice (documentkey)
  ON UPDATE CASCADE 
  ON DELETE CASCADE;

ALTER TABLE ctl_invoicepos ADD CONSTRAINT ctl_fk_invoicepos_good
  FOREIGN KEY (goodkey) REFERENCES gd_good (id);

ALTER TABLE ctl_invoicepos ADD CONSTRAINT ctl_fk_invoicepos_dest
  FOREIGN KEY (destkey) REFERENCES ctl_reference (id);

COMMIT;

/*
 *
 *  Таблица скидок/наценок на определенные
 *  группы скота.
 *
 */


CREATE TABLE ctl_discount(
  goodkey        dintkey,                         /* ключ группы скота */

  discount       dpercent,                        /* процент скидки при перещете из мяса в живой вес */

  minweight      dcurrency,                       /* минимальный вес */
  maxweight      dcurrency,                       /* максимальный вес */

  coeff          dcurrency,                       /* коэфф пересчета из жив веса в мясо */

  reserved       dinteger
);

COMMIT;

ALTER TABLE ctl_discount ADD CONSTRAINT ctl_pk_discount_goodkey
  PRIMARY KEY (goodkey);

COMMIT;

ALTER TABLE ctl_discount ADD CONSTRAINT ctl_fk_discount_goodkey
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON UPDATE CASCADE 
  ON DELETE CASCADE;

COMMIT;


/*
 *  Расстояние
 */

CREATE DOMAIN ddistance
  AS DECIMAL(15, 4);

/*
 *  Класс груза
 */

CREATE DOMAIN dcargoclass
  AS SMALLINT;

/*
 *
 *  Таблица автомобильных тарифов
 *  для определения транспортных расходов.
 *
 */

CREATE TABLE ctl_autotariff(
  cargoclass     dcargoclass NOT NULL,            /* класс груза */
  distance       ddistance NOT NULL,              /* расстояние */

  tariff_500     dpositive,                       /* тариф до 500 км */
  tariff_1000    dpositive,                       /* тариф до 1000 км */
  tariff_1500    dpositive,                       /* тариф до 1500 км */
  tariff_2000    dpositive,                       /* тариф до 2000 км */
  tariff_5000    dpositive,                       /* тариф до 5000 км */
  tariff_S5000   dpositive,                       /* тариф свыше 5000 км */

  reserved       dinteger                         /* зарезервировано */
);

COMMIT;

ALTER TABLE ctl_autotariff ADD CONSTRAINT ctl_pk_autotariff
  PRIMARY KEY (cargoclass, distance);

COMMIT;


SET TERM ^ ;


/*
 *
 *  Триггеры на таблицу ctl_reference.
 *
 */

CREATE TRIGGER ctl_bi_reference FOR ctl_reference
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*
 *
 *  Триггеры на таблицу ctl_receipt
 *
 */

CREATE EXCEPTION ctl_e_period_locked 'Period zablokirovan'
^

COMMIT
^

CREATE TRIGGER ctl_bd_receipt FOR ctl_receipt
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_document WHERE id = OLD.documentkey
    AND documentdate < '01.04.2002')) THEN
  BEGIN
    EXCEPTION ctl_e_period_locked;
  END


  DELETE FROM gd_document WHERE id = OLD.documentkey;
END
^

CREATE TRIGGER ctl_bu_receipt FOR ctl_receipt
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_document WHERE id = OLD.documentkey
    AND documentdate < '01.04.2002')) THEN
  BEGIN
    EXCEPTION ctl_e_period_locked;
  END
END
^


/*
 *
 * Триггеры на таблицу ctl_invoice
 *
 */


/*

Гэта цалкам нармалёвыя паводзіны -- выдаляць квітанцыю разам з адвес накладной.

CREATE EXCEPTION ctl_e_delete_invoice 'Can not delete invoice. It is used in receipt!'
^

*/

CREATE TRIGGER ctl_bd_invoice FOR ctl_invoice
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_document WHERE id = OLD.documentkey
    AND documentdate < '01.04.2002')) THEN
  BEGIN
    EXCEPTION ctl_e_period_locked;
  END


  DELETE FROM gd_document WHERE id = OLD.documentkey;
  DELETE FROM gd_document WHERE id = OLD.receiptkey;

  /*
  IF (EXISTS (SELECT DOCUMENTKEY FROM CTL_RECEIPT WHERE
    DOCUMENTKEY = OLD.RECEIPTKEY))
  THEN
    EXCEPTION ctl_e_delete_invoice;
  */
END
^

CREATE TRIGGER ctl_bu_invoice FOR ctl_invoice
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF (EXISTS (SELECT * FROM gd_document WHERE id = OLD.documentkey
    AND documentdate < '01.04.2002')) THEN
  BEGIN
    EXCEPTION ctl_e_period_locked;
  END
END
^


CREATE TRIGGER ctl_au_invoice FOR ctl_invoice
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  DELETE FROM gd_document WHERE id = OLD.receiptkey;
END
^


/*
 *
 *  Триггеры на таблицу ctl_invoicepos
 *
 */


CREATE TRIGGER ctl_bi_invoicepos FOR ctl_invoicepos
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*
  данная процедура пройдется по всем отвес-накладным и
  произведет перерасчет веса мяса и веса живого со скидкой
  по коэффициенту.

  Внимание! квитанции она не затрагивает, так что их лучше удалить
  и после перерасчета перестроить заново.
*/


CREATE PROCEDURE CTL_P_RECALCWEIGHT 
AS
  DECLARE VARIABLE kind       VARCHAR(1);
  DECLARE VARIABLE coeff      DECIMAL(15, 4);
  DECLARE VARIABLE meatweight DECIMAL(15, 4);
  DECLARE VARIABLE realweight DECIMAL(15, 4);
  DECLARE VARIABLE id         INTEGER;
BEGIN
  FOR
    SELECT
      i.kind,
      d.coeff,
      ip.meatweight,
      ip.realweight,
      ip.id
    FROM
      ctl_invoice i
        JOIN ctl_invoicepos ip ON i.documentkey = ip.invoicekey
        JOIN ctl_discount d ON ip.goodkey = d.goodkey
    INTO
      :kind, :coeff, :meatweight, :realweight, :id
  DO
  BEGIN
    IF (kind = 'M') then
      UPDATE ctl_invoicepos
      SET realweight = g_m_Round(:meatweight / :coeff + 0.000001), liveweight = 0
      WHERE id = :id;
    ELSE
      UPDATE ctl_invoicepos
      SET meatweight = g_m_Round(:realweight * :coeff + 0.000001)
      WHERE id = :id;
  END
END
^

SET TERM ; ^