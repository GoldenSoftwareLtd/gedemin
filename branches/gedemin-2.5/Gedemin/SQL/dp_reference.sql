
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    dp_reference.sql

  Abstract

    Справочники для проекта Department.

  Author

    Anton Smirnov (15.12.2000)

  Revisions history

    Initial  15.12.2000  SAI    Initial version

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

/* Справочник уполномоченных органов
   Предназначен для хранения информации по уполномоченным органам.
   Должен предусматривать возможность их разделения на иерархические группы
   (например, по территориальному признаку). */

CREATE TABLE dp_authority
(
  companykey	     dintkey,	/*  Уникальный ключ.           */
  financialkey       dforeignkey,    /*  Ссылка на финансовый орган */
  mainkey            dforeignkey /* главный уп. орган */
);

ALTER TABLE dp_authority
  ADD CONSTRAINT dp_pk_authority PRIMARY KEY (companykey);

ALTER TABLE dp_authority ADD CONSTRAINT dp_fk_ath_companykey
  FOREIGN KEY (companykey) REFERENCES gd_company(contactkey)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE dp_authority ADD CONSTRAINT dp_fk_ath_financialkey
  FOREIGN KEY (financialkey) REFERENCES gd_company(contactkey);

ALTER TABLE dp_authority ADD CONSTRAINT dp_fk_ath_mainkey
  FOREIGN KEY (mainkey) REFERENCES gd_company(contactkey);


/*
  Вид использования имущества
  Предназначен для хранения информации по статьям передачи имущест-ва
*/

CREATE TABLE dp_assetdest
(
  id	      dintkey,	/*  Уникальный ключ.           */
  name        dname,
  description dtext254,
  typeasset   dinteger DEFAULT 0, /*Тип вида использования */
                        /*
                          0 - по умолчанию
                          1 - передано в реализацию (за выче-том торговой скидки)
                          2 - Передано для иного использова-ния
                          3 - Передано безвозмездно
                        */
  afull       dsecurity,
  achag       dsecurity,
  aview       dsecurity,

  disabled    dboolean DEFAULT 0,
  reserved    dinteger

);

ALTER TABLE dp_assetdest
  ADD CONSTRAINT dp_pk_assetdest PRIMARY KEY (id);

/*
  Основание
  Предназначен для хранения информации об указах, постановлениях и пр.,
  на основании которых производится изъятие или обращение имуще-ства в
  доход государства
*/

CREATE TABLE dp_decree
(
  id	      dintkey,              /*  Уникальный ключ.           */
  name        dname,
  decreedate  ddate,
  description dtext254,
  percent     dpercent DEFAULT 100, /*Процент*/
  afull       dsecurity,
  achag       dsecurity,
  aview       dsecurity,

  disabled    dboolean DEFAULT 0,
  reserved    dinteger
);

ALTER TABLE dp_decree
  ADD CONSTRAINT dp_pk_decree PRIMARY KEY (id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER dp_bi_assetdest FOR dp_assetdest
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER dp_bi_decree FOR dp_decree
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
