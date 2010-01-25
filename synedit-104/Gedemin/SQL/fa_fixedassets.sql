CREATE DOMAIN damortchipher AS
  VARCHAR(6) NOT NULL;

CREATE DOMAIN damortpercent AS
  NUMERIC(5, 2) NOT NULL
  CHECK(VALUE >= 0.00 AND VALUE <= 100.00);

/*
 * Справочник шифров амортизации
 *
 *
 */

CREATE TABLE fa_chiper (
  id          dintkey,
  parent      dforeignkey,
  chipher     damortchipher UNIQUE, 
  percent     damortpercent,
  name        dname,
  reserved    dreserved 
);

ALTER TABLE fa_chipher ADD CONSTRAINT  fa_pk_chipher
  PRIMARY KEY (id);

ALTER TABLE fa_chipher ADD CONSTRAINT fa_fk_chipher_parent
  FOREIGN KEY (parent) REFERENCES fa_chipher(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

CREATE TRIGGER fa_bi_chipher FOR fa_chipher
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

/*

На каждый объект основных средств заводится инвентарная карточка.
Так же, одна инвентарная карточка может быть открыта для группы
однородных, однотипных основных средств, приобретенных одновременно
по одной и той же цене и имеющих одинаковую норму амортизационных 
отчислений.

В существующей программе Средства Анжелики фактически спутаны два
Разных понятия. В ней инвентарная карточка одновременно представляла 
И объект основных средств и действие – ввод инвентарной карточки, 
Фактически оприходывание основного средства на предприятие.

В одной записи хранилась информация о характеристиках объекта (шифр
Амортизации, процент, вес, размеры) и информация о действии (дата
Ввода, дата выбытия и пр.)

В новой системе необходимо разделить: fa_asset – хранит информацию об
Объекте основных средств.


*/

 
CREATE TABLE fa_asset (
  goodkey           dintkey,

  amortchipher      dforeignkey,   /* ссылка на шифр амортизации      */
  amortpercent      damortpercent, /* процент ежемесячной амортизации */
  correctioncoeff   dcorrectioncoeff, /* повышающий коэффициент       */

  
);


