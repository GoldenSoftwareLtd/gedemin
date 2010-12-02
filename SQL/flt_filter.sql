
/*

  Copyright (c) 2000 by Golden Software of Belarus

  Script

    filter.sql

  Abstract

    An Interbase script for "universal" filter.

  Author

    Andrey Shadevsky (26.06.00)

  Revisions history

    Initial  26.06.00  JKL    Initial version

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

/****************************************************

   Таблица для регистрации компонент фильтрации в БД.

*****************************************************/

CREATE TABLE flt_componentfilter
(
  id                dintkey,            /* идентификатор */
  filtername        dtext20,            /* наименование компонента */
  formname          dtext20,            /* наименование владельца компонента */
  applicationname   dtext20,            /* наименование приложения */
  crc               dinteger,           /* crc поля fullname */
  fullname          dtext255            /* полное наименование компонента:
                                           наименование приложения + \ +
                                           наименование владельца + \ +
                                           имя компоненты фильтра (Добавлено из-за
                                           предыдущего органичения на имя фильтра 20 символов)*/
);

ALTER TABLE flt_componentfilter
  ADD CONSTRAINT flt_pk_componentfilter PRIMARY KEY (id);

CREATE INDEX flt_x_componentfilter_comp 
  ON flt_componentfilter(filtername, formname, applicationname);

CREATE INDEX flt_x_componentfilter_crc 
  ON flt_componentfilter(crc);

COMMIT;

/****************************************************

   Таблица для хранения процедур созданных в фильтрах.
   Наверное от ее можно будет избавиться потом.

*****************************************************/

CREATE TABLE flt_procedurefilter
(
  name          dname,
  componentkey  dintkey,
  description   dtext180,
  aview          dsecurity,
  disabled      dboolean DEFAULT 0,
  reserved      dinteger
);

ALTER TABLE flt_procedurefilter ADD CONSTRAINT flt_pk_procedurefilter
  PRIMARY KEY (name);

ALTER TABLE flt_procedurefilter ADD CONSTRAINT flt_fk_procedurefilter_compkey 
  FOREIGN KEY (componentkey) REFERENCES flt_componentfilter(id)
  ON UPDATE CASCADE;

COMMIT;

CREATE EXCEPTION FLT_E_INVALIDFILTERNAME 
  'You made an attempt to save filter with duplicate name.';

/****************************************************

   Таблица для хранения фильтра пользователя.

*****************************************************/

CREATE TABLE flt_savedfilter
(
  id            dintkey,
  name          dname,
  userkey       dforeignkey,
  componentkey  dintkey,
  description   dtext180,
  lastextime    dtime,
  readcount     dinteger DEFAULT 0,

  data          dfilterdata,

  aview         dsecurity,
  achag         dsecurity,
  afull         dsecurity,

  disabled      dboolean DEFAULT 0,
  editiondate   deditiondate,   /* Дата последнего редактирования */
  editorkey     dintkey,        /* Ссылка на пользователя, который редактировал запись*/
  reserved      dinteger
);

ALTER TABLE flt_savedfilter ADD CONSTRAINT flt_pk_savedfilter
  PRIMARY KEY (id);

ALTER TABLE flt_savedfilter ADD CONSTRAINT flt_fk_savedfilter_userkey
  FOREIGN KEY (userkey) REFERENCES gd_user(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE flt_savedfilter ADD CONSTRAINT flt_fk_savedfilter_componentkey
  FOREIGN KEY (componentkey) REFERENCES flt_componentfilter(id)
  ON UPDATE CASCADE;

ALTER TABLE flt_savedfilter ADD CONSTRAINT flt_fk_savedfilter_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;
     
COMMIT;

SET TERM ^ ;

CREATE TRIGGER flt_bi_savedfilter FOR flt_savedfilter
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
  if (NEW.readcount IS NULL) then
    NEW.readcount = 0;
END
^



/* Trigger: FLT_BI_SAVEDFILTER1 */
CREATE TRIGGER flt_bi_savedfilter1 FOR flt_savedfilter
BEFORE INSERT POSITION 1
AS
BEGIN
  IF (EXISTS
       (SELECT *
        FROM flt_savedfilter
        WHERE name = NEW.name AND componentkey = NEW.componentkey
        AND (userkey = NEW.userkey OR userkey IS NULL AND NEW.userkey IS NULL))
      )
  THEN
    EXCEPTION flt_e_invalidfiltername;
END
^


/* Trigger: FLT_BU_SAVEDFILTER1 */
CREATE TRIGGER flt_bu_savedfilter1 FOR flt_savedfilter
BEFORE UPDATE POSITION 1
AS
BEGIN
  IF (EXISTS
       (SELECT *
        FROM flt_savedfilter
        WHERE name = NEW.name AND componentkey = NEW.componentkey
        AND (userkey = NEW.userkey OR userkey IS NULL AND NEW.userkey IS NULL) AND id <> NEW.id)
      )
  THEN
    EXCEPTION flt_e_invalidfiltername;
END
^

CREATE TRIGGER flt_bi_component FOR flt_componentfilter
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER flt_bi_savedfilter5 FOR flt_savedfilter
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER flt_bu_savedfilter5 FOR flt_savedfilter
  BEFORE UPDATE POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   Таблица для хранения ссылки на последний фильтр.

*****************************************************/

CREATE TABLE flt_lastfilter
(
  componentkey         dintkey,
  userkey              dintkey,
  lastfilter           dintkey,
  crc32                dinteger,
  dbversion            dtext20
);

ALTER TABLE flt_lastfilter ADD CONSTRAINT flt_pk_lastfilter 
  PRIMARY KEY (componentkey, userkey);

ALTER TABLE flt_lastfilter ADD CONSTRAINT flt_fk_lastfilter_userkey 
  FOREIGN KEY (userkey) REFERENCES gd_user(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE flt_lastfilter ADD CONSTRAINT flt_fk_lastfilter_componentkey 
  FOREIGN KEY (componentkey) REFERENCES flt_componentfilter(id)
  ON UPDATE CASCADE;

ALTER TABLE flt_lastfilter ADD CONSTRAINT flt_fk_lastfilter_lastfilter 
  FOREIGN KEY (lastfilter) REFERENCES flt_savedfilter(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

COMMIT;

