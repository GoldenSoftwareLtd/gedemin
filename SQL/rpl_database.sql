
/****************************************************/
/****************************************************/
/**                                                **/
/**                                                **/
/**   Copyright (c) 2008 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/****************************************************

   Таблица для хранения списка баз
   участвующих в обмене данными.

*****************************************************/

CREATE TABLE rpl_database (
    id         DINTKEY,
    name       DNAME,
    isourbase  DBOOLEAN,

    CONSTRAINT rpl_pk_database_id PRIMARY KEY (id)
);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER rpl_bi_database FOR rpl_database
  ACTIVE 
  BEFORE INSERT 
  POSITION 0
AS
BEGIN
  IF (new.id IS NULL) THEN
    new.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения ссылок на РУИДы записей,
   пересылаемых между соответствующими базами,
   и состояние их пересылки.

*****************************************************/

CREATE TABLE rpl_record (
    id           DINTKEY,
    basekey      DINTKEY,
    editiondate  DTIMESTAMP,
    state        SMALLINT,

    CONSTRAINT rpl_pk_record_id PRIMARY KEY (id, basekey),
    CONSTRAINT rpl_fk_record_basekey FOREIGN KEY (basekey)
      REFERENCES rpl_database (id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,
    CONSTRAINT rpl_fk_record_id FOREIGN KEY (ID)
      REFERENCES GD_RUID (ID)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

COMMIT;
