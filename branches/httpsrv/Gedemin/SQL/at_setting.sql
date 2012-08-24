
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

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

/* По идее, здесь должен быть уникальный ключ,
   но возникает проблема  при сортировке, поэтому пока убрано */
/* ALTER TABLE at_settingpos ADD CONSTRAINT at_uk_settingpos_order
 UNIQUE (settingkey, objectorder); */

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
