
/*

  Copyright (c) 2000-2013 by Golden Software of Belarus

  Script

    evt_script.sql

  Abstract

    An Interbase script for "universal" report.

  Author

    Andrey Shadevsky (__.__.__)

  Revisions history

    Initial  29.11.01  JKL    Initial version

  Status 
    
    Draft

*/

/****************************************************

   Таблица для хранения объектов.

*****************************************************/

CREATE TABLE evt_object
(
  id             dintkey,
  name           dgdcname,
  description    dtext180,
  parent         dforeignkey,
  lb             dlb,
  rb             drb,
  afull          dsecurity,
  achag          dsecurity,
  aview          dsecurity,
  objecttype     dsmallint,     /* 0-object; 1-class */
  reserved       dinteger,
  macrosgroupkey dforeignkey,
  parentindex    dinteger NOT NULL,
  reportgroupkey dforeignkey,
  classname      dgdcname,
  objectname     dgdcname,
  subtype        dsubtype,
  editiondate    deditiondate,  /* Дата последнего редактирования */
  editorkey      dintkey        /* Ссылка на пользователя, который редактировал запись*/
);

ALTER TABLE evt_object
  ADD CONSTRAINT evt_pk_object PRIMARY KEY (id);

/* !!! Никаких каскад делете быть не должно !!!*/

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_parent
  FOREIGN KEY (parent) REFERENCES evt_object (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_function ADD CONSTRAINT gd_fk_function_modulecode
  FOREIGN KEY (modulecode) REFERENCES evt_object (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_reportgrkey
  FOREIGN KEY (reportgroupkey) REFERENCES rp_reportgroup (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

CREATE ASC INDEX evt_x_object_objectname_upper
  ON evt_object
  COMPUTED BY (UPPER(objectname));

COMMIT;

CREATE EXCEPTION EVT_E_RECORDFOUND
  'Object or Class with such a parameters is already exist';

CREATE EXCEPTION EVT_E_RECORDINCORRECT
  'Do not insert or update this data.';

CREATE EXCEPTION EVT_E_INCORRECTVERSION
  'Incorrect version Gedemin for insert in evt_object Table.';

COMMIT;

SET TERM ^ ;

CREATE OR ALTER TRIGGER evt_bi_object FOR evt_object
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  NEW.parentindex = COALESCE(NEW.parent, 1);
END
^

CREATE OR ALTER TRIGGER evt_bi_object1 FOR evt_object
  ACTIVE
  BEFORE INSERT OR UPDATE
  POSITION 1
AS
BEGIN
  IF ((NOT NEW.name IS NULL) AND
     (NEW.objectname IS NULL) AND
     (NEW.classname IS NULL) AND
     (NEW.subtype IS NULL))
  THEN
    EXCEPTION  EVT_E_INCORRECTVERSION;

  NEW.objectname = COALESCE(NEW.objectname, '');
  NEW.classname = COALESCE(NEW.classname, '');
  NEW.subtype = COALESCE(NEW.subtype, '');

  IF
    (
    ((NEW.objectname = '') AND (NEW.classname = '')) OR
    ((NEW.subtype <> '') AND ((NEW.objectname <> '') OR
     (NEW.classname = '')))
    ) THEN
  BEGIN
    EXCEPTION EVT_E_RECORDINCORRECT;
  END
END
^

CREATE OR ALTER TRIGGER evt_bi_object2 FOR evt_object
  ACTIVE
  BEFORE INSERT OR UPDATE
  POSITION 2
AS
BEGIN
  /* Проверяет уникальность объекта или класса с подтипом*/
  IF
    (EXISTS(SELECT * FROM evt_object
    WHERE
    (UPPER(objectname) = UPPER(NEW.objectname))  AND
    (UPPER(classname) = UPPER(NEW.classname)) AND
    (parent IS NOT DISTINCT FROM NEW.parent) AND
    (UPPER(subtype) = UPPER(NEW.subtype)) AND
    (id <> NEW.id)))
  THEN
  BEGIN
    EXCEPTION EVT_E_RECORDFOUND;
  END

  /* Заполняет поля name, objecttype для поддержки */
  /* старой версии Гедемина */
  IF (NEW.classname = '') THEN
  BEGIN
    NEW.objecttype = 0;
    NEW.name = NEW.objectname;
  END ELSE
    BEGIN
      NEW.objecttype = 1;
      IF (NEW.subtype = '') THEN
      BEGIN
        NEW.name = NEW.classname;
      END ELSE
        NEW.name = NEW.classname || NEW.subtype;
    END
END
^

CREATE OR ALTER TRIGGER evt_bu_object FOR evt_object
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  NEW.parentindex = COALESCE(NEW.parent, 1);
END
^

CREATE OR ALTER TRIGGER evt_bi_object5 FOR evt_object
  BEFORE INSERT
  POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;

  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE OR ALTER TRIGGER evt_bu_object5 FOR evt_object
  BEFORE UPDATE
  POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
  IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

SET TERM ; ^

/****************************************************

   Таблица для событий и ссылок на функции.

*****************************************************/

CREATE TABLE evt_objectevent
(
  id             dintkey,
  objectkey      dintkey,
  eventname      dname,
  functionkey    dforeignkey,
  afull          dsecurity,
  reserved       dinteger,
  disable        dboolean,
  editiondate    deditiondate,  /* Дата последнего редактирования */
  editorkey      dintkey        /* Ссылка на пользователя, который редактировал запись*/
);

/* Primary keys definition */

ALTER TABLE EVT_OBJECTEVENT ADD CONSTRAINT EVT_PK_OBJECTEVENT_ID PRIMARY KEY (ID);

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE evt_objectevent ADD CONSTRAINT evt_fk_object_fk
  FOREIGN KEY (functionkey) REFERENCES gd_function (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_objectevent ADD CONSTRAINT evt_fk_object_objectkey
  FOREIGN KEY (objectkey) REFERENCES evt_object(id)
  ON UPDATE CASCADE
  ON DELETE CASCADE;

ALTER TABLE evt_objectevent ADD CONSTRAINT evt_fk_objectevent_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

COMMIT;

/* Indices definition */

CREATE UNIQUE INDEX evt_idx_objectevent ON evt_objectevent (eventname, objectkey);

COMMIT;

SET TERM ^ ;
CREATE OR ALTER TRIGGER evt_bi_objectevent5 FOR evt_objectevent
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE OR ALTER TRIGGER evt_bu_objectevent5 FOR evt_objectevent
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

/****************************************************/
/**                                                **/
/**   Таблица для хранения дерева макросов         **/
/**                                                **/
/****************************************************/

CREATE TABLE evt_macrosgroup (
  id             dintkey,      /* Уникальный ключ */
  parent         dforeignkey,  /* Парент на родителя */
  lb             dlb,
  rb             drb,
  name           dname,        /* Наименование поле для примера */

  isglobal       dboolean,

  description    dblobtext80,  /*  Описание группы */
  editiondate    deditiondate, /* Дата последнего редактирования */
  editorkey      dintkey,      /* Ссылка на пользователя, который редактировал запись*/

  reserved       dblob         /*Зарезервированно*/
);

ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_pk_macrosgroup_id
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE evt_object ADD CONSTRAINT evt_fk_object_mrsgroupkey
  FOREIGN KEY (macrosgroupkey) REFERENCES evt_macrosgroup (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_fk_macrosgroup_parent
  FOREIGN KEY (parent) REFERENCES evt_macrosgroup (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_macrosgroup ADD CONSTRAINT evt_fk_macrosgroup_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

CREATE INDEX evt_x_macrosgroup_isglobal ON evt_macrosgroup (isglobal);  

COMMIT;

SET TERM ^ ;

CREATE OR ALTER TRIGGER evt_bi_macrosgroup5 FOR evt_macrosgroup
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE OR ALTER TRIGGER evt_bu_macrosgroup5 FOR evt_macrosgroup
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

/****************************************************/
/**                                                **/
/**    Таблица для хранения макросов               **/
/**                                                **/
/****************************************************/

CREATE TABLE evt_macroslist (
  id              dintkey,      /* Уникальный ключ */
  macrosgroupkey  dforeignkey,  /*  Ключ группы макросов */
  functionkey     dforeignkey,  /*  Ключ макроса */
  name            dname,        /* Наименование поле для примера */
  serverkey       dforeignkey,
  islocalexecute  dboolean,
  isrebuild       dboolean,
  executedate     dtext254,
  shortcut        dinteger,
  editiondate     deditiondate,  /* Дата последнего редактирования */
  editorkey       dintkey,       /* Ссылка на пользователя, который редактировал запись*/
  displayinmenu   dboolean DEFAULT 1,  /* Отображать в меню формы */
  runonlogin      dboolean_notnull DEFAULT 0,
  achag           dsecurity,
  afull           dsecurity,
  aview           dsecurity
);

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_pk_macroslist_id
  PRIMARY KEY (id);

COMMIT;

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macroslist_mrsgroupkey
  FOREIGN KEY (macrosgroupkey) REFERENCES evt_macrosgroup(id)
  ON UPDATE CASCADE;

/* Для ниже перечисленных констрейнов НЕЛЬЗЯ СТАВИТЬ     DELETE CASCADE */
ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macros_functionkey
  FOREIGN KEY (functionkey) REFERENCES gd_function (id)
  ON UPDATE CASCADE;

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macroslist_rpserver
  FOREIGN KEY (serverkey) REFERENCES rp_reportserver(id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

ALTER TABLE evt_macroslist ADD CONSTRAINT evt_fk_macroslist_editorkey
  FOREIGN KEY(editorkey) REFERENCES gd_people(contactkey)
  ON UPDATE CASCADE;

CREATE UNIQUE INDEX EVT_MACROSLIST_IDX
  ON EVT_MACROSLIST
  (NAME, MACROSGROUPKEY);

CREATE UNIQUE INDEX EVT_X_MACROSLIST_FUNCTIONKEY
  ON EVT_MACROSLIST
  (FUNCTIONKEY);

COMMIT;

SET TERM ^ ;

CREATE OR ALTER TRIGGER evt_bi_macroslist5 FOR evt_macroslist
  BEFORE INSERT POSITION 5
AS
BEGIN
  IF (NEW.editorkey IS NULL) THEN
    NEW.editorkey = 650002;
 IF (NEW.editiondate IS NULL) THEN
    NEW.editiondate = CURRENT_TIMESTAMP;
END
^

CREATE OR ALTER TRIGGER evt_bu_macroslist5 FOR evt_macroslist
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

