
/*

  Copyright (c) 2000-2013 by Golden Software of Belarus

  Script

    at_setting.sql

  Abstract

    Репозиторий настроек БД

  Author

    Julia Teryokhina

  Revisions history

    Initial  27.05.2002  Julia    Initial version

*/

/* Таблица настроек*/

CREATE TABLE at_setting (
  id              dintkey NOT NULL,  /* идентификатор */
  name            dname NOT NULL     /* наименование настройки */
                  collate PXW_CYRL,
  data            DBLOB4096,         /* данные объекта, сохраненные в поток */
  storagedata     DBLOB4096,         /* данные хранилища, сохраненные в поток */
  disabled        dboolean DEFAULT 0,/* активная / неактивная настройка */
  modifydate      dtimestamp,        /* дата сохранения настройки в базу */
  settingsruid    dblobtext80_1251,  /* хранит руиды настроек, от которых зависит данная натсройка*/
  version         dinteger,          /* версия настройки, возрастает при каждом сохранении настройки в базу */ 
  minexeversion   dtext20,           /* min версия Exe-файла для работы настройки */
  mindbversion    dtext20,           /* min версия БД для работы настройки */
  ending          dboolean,           /* конечная/промежуточная настройка */
  description     dtext255           /* описание настройки */
);


ALTER TABLE at_setting ADD CONSTRAINT at_pk_setting PRIMARY KEY (id);

SET TERM ^ ;

CREATE TRIGGER at_bi_setting FOR at_setting
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

END
^
SET TERM ; ^

COMMIT;

/* Таблица позиций настроек */
/* Поля категория объекта и наименование объекта используются чисто для
   отображения содержимого настройки, при этом поля мастера могут
   содержать информацию о мастрее сохраняемого объекта, опять-таки
   только для просмотра содержимого настройки. Например, мы сохраняем
   поле usr$newfield таблицы usr$newtable. Мастер-категория - таблица,
   мастер-наименование - usr$newtable, категория объекта - поле,
   наименование объекта - usr$newfield. */

CREATE TABLE at_settingpos (
  id              dintkey,                   /* идентификатор */
  settingkey      dmasterkey NOT NULL,       /* ссылка на настройку */
  mastercategory  dtext20 collate PXW_CYRL,  /* категория местера */
  mastername      dtext60 collate PXW_CYRL,  /* наименование мастера */
  objectclass     dclassname NOT NULL        /* класс сохраняемого объекта */
                  collate PXW_CYRL,
  subtype         dtext40 collate PXW_CYRL,  /* сабтайп сохраняемого объекта */
  category        dtext20 collate PXW_CYRL,  /* категория сохраняемого объекта */
  objectname      dname NOT NULL             /* наименование сохраняемого объекта */
                  collate PXW_CYRL,
  xid             dinteger NOT NULL,         /* идентификатор сохраняемого объекта
                                                (из базы-родителя) */
  dbid            dinteger NOT NULL,         /* идентификатор базы родителя */
  objectorder     dinteger NOT NULL,         /* порядок следования объектов в настройке */
  withdetail      dboolean_notnull default 0 /* считывать все детальные объекты для данного объекта */
                  NOT NULL,
  needmodify      dboolean_notnull default 1 /* модифицировать объекты при активации настройки */
                  NOT NULL,
  autoadded       DBOOLEAN_NOTNULL DEFAULT 0 /* позиция добавлена автоматически */
                  NOT NULL

);

ALTER TABLE at_settingpos ADD CONSTRAINT at_pk_settingpos PRIMARY KEY (id);

ALTER TABLE at_settingpos ADD CONSTRAINT at_uk_settingpos
 UNIQUE (settingkey, xid, dbid);

ALTER TABLE at_settingpos ADD  CONSTRAINT at_fk_settingpos_settinkey
FOREIGN KEY (settingkey) REFERENCES at_setting (id)
ON DELETE CASCADE ON UPDATE CASCADE;

CREATE INDEX AT_SETTINGPOS_XID_DBID ON AT_SETTINGPOS (XID, DBID);
SET TERM ^ ;

CREATE TRIGGER at_bi_settingpos FOR at_settingpos
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);
  IF (NEW.objectorder IS NULL) THEN
    NEW.objectorder = NEW.id;

END
^
SET TERM ; ^

COMMIT;

/* Таблица для хранения веток реестра в настройках*/

CREATE TABLE at_setting_storage
(
  id           dintkey NOT NULL,         /* идентификатор */
  settingkey   dmasterkey NOT NULL,     /* ссылка на настройку*/
  branchname   dblobtext80_1251,        /* наименование ветки стораджа */
  valuename    dtext255,                /* наименование параметра.
                                           Если пустое, значит сохранена вся ветка*/
  crc          dinteger
);

COMMIT;

ALTER TABLE at_setting_storage ADD
CONSTRAINT at_pk_setting_storage PRIMARY KEY (id);

ALTER TABLE at_setting_storage ADD
CONSTRAINT at_fk_setstorage_settingkey
FOREIGN KEY (settingkey) REFERENCES at_setting (id)
ON DELETE CASCADE ON UPDATE CASCADE;

SET TERM ^ ;

CREATE TRIGGER at_bi_setting_storage FOR at_setting_storage
BEFORE INSERT POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);
END
^

SET TERM ; ^

/*

CREATE TABLE at_namespace (
  id            dintkey,
  name          dtext255 NOT NULL UNIQUE,
  caption       dtext255,
  filename      dtext255,
  filetimestamp TIMESTAMP,
  version       dtext20 DEFAULT '1.0.0.0' NOT NULL,
  dbversion     dtext20,
  optional      dboolean_notnull DEFAULT 0,
  internal      dboolean_notnull DEFAULT 1,
  comment       dblobtext80_1251,
  settingruid   VARCHAR(21),

  CONSTRAINT at_pk_namespace PRIMARY KEY (id)
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER at_biu_namespace FOR at_namespace
  ACTIVE
  BEFORE INSERT OR UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (NEW.caption IS NULL) THEN
    NEW.caption = NEW.name;
END
^

SET TERM ; ^

CREATE TABLE at_object (
  id              dintkey,
  namespacekey    dintkey,
  objectname      dname,
  objectclass     dclassname NOT NULL,
  subtype         dtext60,
  xid             dinteger_notnull,
  dbid            dinteger_notnull,
  objectpos       dinteger,
  alwaysoverwrite dboolean_notnull DEFAULT 1,
  dontremove      dboolean_notnull DEFAULT 0,
  includesiblings dboolean_notnull DEFAULT 0,
  headobjectkey   dforeignkey,

  CONSTRAINT at_pk_object PRIMARY KEY (id),
  CONSTRAINT at_uk_object UNIQUE (namespacekey, xid, dbid),
  CONSTRAINT at_fk_object_namespacekey FOREIGN KEY (namespacekey)
    REFERENCES at_namespace (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT at_fk_object_headobjectkey FOREIGN KEY (headobjectkey)
    REFERENCES at_object (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER at_biu_object FOR at_object
  ACTIVE
  BEFORE INSERT OR UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF (NEW.objectpos IS NULL) THEN
  BEGIN
    SELECT MAX(objectpos) + 1
    FROM at_object
    WHERE namespacekey = NEW.namespacekey
    INTO NEW.objectpos;

    IF (NEW.objectpos IS NULL) THEN
      NEW.objectpos = 0;
  END ELSE
  IF (INSERTING) THEN
  BEGIN
    UPDATE at_object SET objectpos = objectpos + 1
    WHERE objectpos >= NEW.objectpos and namespacekey = NEW.namespacekey;
  END
END
^

SET TERM ; ^

CREATE TABLE at_namespace_link (
  namespacekey   dintkey,
  useskey        dintkey,

  CONSTRAINT at_pk_namespace_link PRIMARY KEY (namespacekey, useskey),
  CONSTRAINT at_fk_namespace_link_nsk FOREIGN KEY (namespacekey)
    REFERENCES at_namespace (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT at_fk_namespace_link_usk FOREIGN KEY (useskey)
    REFERENCES at_namespace (id)
    ON UPDATE CASCADE
    ON DELETE NO ACTION,
  CONSTRAINT at_chk_namespace_link CHECK (namespacekey <> useskey)
);

CREATE GLOBAL TEMPORARY TABLE at_namespace_gtt(
  id            dintkey,
  name          dtext255 NOT NULL UNIQUE,
  caption       dtext255,
  filename      dtext255,
  filetimestamp TIMESTAMP,
  version       dtext20 DEFAULT '1.0.0.0' NOT NULL,
  dbversion     dtext20,
  optional      dboolean_notnull DEFAULT 0,
  internal      dboolean_notnull DEFAULT 1,
  comment       dblobtext80_1251,
  settingruid   VARCHAR(21),
  operation     dinteger,

  CONSTRAINT at_pk_namespace_gtt PRIMARY KEY (id)
) ON commit preserve rows;

SET TERM ^ ;

CREATE OR ALTER TRIGGER at_bi_namespace_gtt FOR at_namespace_gtt
  ACTIVE
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
  BEGIN
    SELECT MAX(id) + 1
    FROM at_namespace_gtt
    INTO NEW.id;

    IF (NEW.id IS NULL) THEN
      NEW.id = 1;
  END
END
^

SET TERM ; ^

CREATE GLOBAL TEMPORARY TABLE at_namespace_link_gtt(
  namespaceruid   VARCHAR(21),
  usesruid        VARCHAR(21),

  CONSTRAINT at_uk_object_link_gtt UNIQUE (namespaceruid, usesruid)
) ON COMMIT PRESERVE ROWS;

SET TERM ^ ;

CREATE OR ALTER PROCEDURE at_p_findnsrec (InPath VARCHAR(32000), InFirstID INTEGER, InID INTEGER)
  RETURNS (OutPath VARCHAR(32000), OutFirstID INTEGER, OutID INTEGER)
AS
  DECLARE VARIABLE ID INTEGER;
  DECLARE VARIABLE NAME VARCHAR(255);
BEGIN
  FOR
    SELECT l.useskey, n.name
    FROM at_namespace_link l JOIN at_namespace n
      ON n.id = l.useskey
    WHERE l.namespacekey = :InID
    INTO :ID, :NAME
  DO BEGIN
    IF (POSITION(:ID || '=' || :NAME || ',' IN :InPath) > 0) THEN
    BEGIN
      OutPath = :InPath || :ID || '=' || :NAME;
      OutID = :ID;
      OutFirstID = :InFirstID;
      SUSPEND;
    END ELSE
    BEGIN
      FOR
        SELECT OutPath, OutFirstID, OutID
        FROM at_p_findnsrec(:InPath || :ID || '=' || :NAME || ',', :InFirstID, :ID)
        INTO :OutPath, :OutFirstID, :OutID
      DO BEGIN
        IF (:OutPath > '') THEN
          SUSPEND;
      END
    END
  END
END
^

SET TERM ; ^

GRANT ALL     ON at_namespace             TO administrator;
GRANT ALL     ON at_object                TO administrator;
GRANT ALL     ON at_namespace_link        TO administrator;
GRANT ALL     ON at_namespace_gtt         TO administrator;
GRANT ALL     ON at_namespace_link_gtt    TO administrator;
GRANT EXECUTE ON PROCEDURE at_p_findnsrec TO administrator;

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741108,740400,'Пространства имен','gdcNamespace',0,NULL,80,NULL,'TgdcNamespace',NULL,1,1,1,0,NULL);

INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
  VALUES (
    741109,
    740400,
    'Синхронизация ПИ',
    '',
    'Tat_frmSyncNamespace',
    NULL,
    0
  );

*/

COMMIT;
