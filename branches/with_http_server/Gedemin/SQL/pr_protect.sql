
/*

  Copyright (c) 2000 by Golden Software of Belarus


  Script


  Abstract


  Author


  Revisions history


  Status 

    
*/

/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2000 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/*
 * при продаже каждой программы будем присваивать ей
 * уникальный регистрационный номер и сохранять в базе
 * данных.
 *
 */

CREATE TABLE pr_regnumber
(
  id             dintkey,
  companykey     dintkey,              /* компания-покупатель */
  goodkey        dintkey,              /* программа */
  regnumber      VARCHAR(20) NOT NULL, /* регистрационный номер */
  regnumberdate  ddate DEFAULT CURRENT_DATE,
  contactkey     dforeignkey,          /* контактное лицо */
  operatorkey    dintkey,
  reserved       dinteger,
  comment        DTEXT1024 collate PXW_CYRL,  /* Комментарий клиента */
  KEYCOUNT       dinteger  
);

ALTER TABLE pr_regnumber ADD CONSTRAINT pr_pk_regnumber_id
  PRIMARY KEY (id);

ALTER TABLE pr_regnumber ADD CONSTRAINT pr_fk_regnumber_ck
  FOREIGN KEY (companykey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

ALTER TABLE pr_regnumber ADD CONSTRAINT pr_fk_regnumber_gk
  FOREIGN KEY (goodkey) REFERENCES gd_good (id)
  ON UPDATE CASCADE;

ALTER TABLE pr_regnumber ADD CONSTRAINT pr_fk_regnumber_ok
  FOREIGN KEY (operatorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

/*
  Один клиент покупает только одну программу
  а как быть с сетевыми??
*/

CREATE UNIQUE INDEX pr_x_regnumber_ckgk
  ON pr_regnumber
(
  companykey,
  goodkey
);

SET TERM ^ ;

CREATE TRIGGER pr_bi_regnumber FOR pr_regnumber
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

/*

  Каждое обращение пользователя за ключем будем фиксировать в базе.

*/

CREATE TABLE pr_key
(
  regnumberkey     dintkey,
  code             VARCHAR(20) NOT NULL, /* код, который нам прислал пользователь */
  licence          VARCHAR(20) NOT NULL, /* лицензия, которую он получил */
  licencedate      DDATE NOT NULL,       /* дата, когда сгенерирована лицензия */
  operatorkey      dintkey
);

ALTER TABLE pr_key ADD CONSTRAINT pr_fk_key_regnumberkey
  FOREIGN KEY (regnumberkey) REFERENCES pr_regnumber (id);

ALTER TABLE pr_key ADD CONSTRAINT pr_fk_key_ok
  FOREIGN KEY (operatorkey) REFERENCES gd_contact(id)
  ON UPDATE CASCADE;

COMMIT;

