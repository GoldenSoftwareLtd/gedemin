
/****************************************************/
/****************************************************/
/**                                                **/
/**   Gedemin project                              **/
/**   Copyright (c) 1999-2000 by                   **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

CREATE TABLE gd_command (
  id         dintkey,                      /* унікальны ідэнтыфікатар */
  parent     dparent,                      /* спасылка на бацьку      */

  name       dname,                        /* імя элементу            */
  cmd        dtext20,                      /* каманда                 */
  cmdtype    dinteger DEFAULT 0 NOT NULL,
  hotkey     dhotkey,                      /* гарачая клявіша         */
  imgindex   dsmallint DEFAULT 0 NOT NULL, /* індэкс малюнка          */
  ordr       dinteger,                     /* парадак                 */
  classname  dclassname,                   /* имя класса              */
  subtype    dtext40,                      /* подтип класса           */

  aview      dsecurity,                    /* бяспека                 */
  achag      dsecurity,
  afull      dsecurity,

  disabled   ddisabled,
  reserved   dreserved
);

COMMIT;

ALTER TABLE gd_command ADD CONSTRAINT gd_pk_command_id
  PRIMARY KEY (id);

ALTER TABLE gd_command ADD CONSTRAINT gd_fk_command_parent
  FOREIGN KEY (parent) REFERENCES gd_command (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_documenttype ADD CONSTRAINT gd_fk_documenttype_branchkey
  FOREIGN KEY (branchkey) REFERENCES gd_command (id) ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE at_relations ADD  CONSTRAINT at_kk_relations_branchkey
  FOREIGN KEY (branchkey) REFERENCES gd_command (id)
  ON UPDATE CASCADE
  ON DELETE SET NULL;

COMMIT;

SET TERM ^ ;

/*

  Два наступныя трыгеры кантралююць каб у дзяцей былі тыя ж правы, што
  і ў бацькоўскага запісу.

*/

CREATE TRIGGER gd_bi_command FOR gd_command
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER gd_aiu_command FOR gd_command
  AFTER INSERT OR UPDATE
  POSITION 100
AS
BEGIN
  UPDATE gd_command SET aview = NEW.aview, achag = NEW.achag, afull = NEW.afull
  WHERE classname = NEW.classname
    AND COALESCE(subtype, '') = COALESCE(NEW.subtype, '')
    AND ((aview <> NEW.aview) OR (achag <> NEW.achag) OR (afull <> NEW.afull))
    AND id <> NEW.id;
END
^

SET TERM ; ^

/*

  Мы прывязываем настройкі працоўнага месца да карыстальніка і
  экраннага разрашэньня (шырыня экрану ў пікселах, памножаная на вышыню).

*/

CREATE TABLE gd_desktop (
  id          dintkey,
  userkey     dintkey,
  screenres   dinteger,
  name        dname,
  saved       dtimestamp DEFAULT 'NOW' NOT NULL,
  dtdata      dblob4096,

  reserved    dinteger
);

COMMIT;

ALTER TABLE gd_desktop ADD CONSTRAINT gd_pk_desktop_id
  PRIMARY KEY (id);

ALTER TABLE gd_desktop ADD CONSTRAINT gd_fk_desktop_userkey
  FOREIGN KEY (userkey) REFERENCES gd_user (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_desktop ADD CONSTRAINT gd_chk_desktop_name
  CHECK (name > '');

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_desktop FOR gd_desktop
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER gd_bu_desktop FOR gd_desktop
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  NEW.saved = 'NOW';
END
^

SET TERM ; ^

COMMIT;

COMMIT;

/*
 *  глябальныя настройкі,
 *  ў табліцы захоўваецца
 *  толькі адзін запіс
 *
 */

CREATE TABLE gd_globalstorage (
  id          dintkey,
  data        dblob4096,
  modified    dtimestamp NOT NULL
);

COMMIT;

ALTER TABLE gd_globalstorage ADD CONSTRAINT gd_pk_globalstorage_id
  PRIMARY KEY (id);

SET TERM ^ ;

CREATE TRIGGER gd_bi_gs FOR gd_globalstorage
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  NEW.id = 880000;
  IF (NEW.modified IS NULL) THEN
    NEW.modified = CURRENT_TIMESTAMP;
END
^

CREATE TRIGGER gd_bu_gs FOR gd_globalstorage
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  NEW.id = 880000;
  IF (NEW.modified IS NULL) THEN
    NEW.modified = CURRENT_TIMESTAMP;

  IF ((NEW.data IS NULL) OR (CHAR_LENGTH(NEW.data) = 0)) THEN
  BEGIN
    NEW.data = OLD.data;

    INSERT INTO gd_journal (source)
      VALUES ('Попытка удалить глобальное хранилище.');
  END
END
^

CREATE EXCEPTION gd_e_cannot_delete_gs
  'Cannot delete global storage'
^

CREATE TRIGGER gd_bd_gs FOR gd_globalstorage
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.id = 880000) THEN
  BEGIN
    EXCEPTION gd_e_cannot_delete_gs;
  END
END
^

SET TERM ; ^

COMMIT;

/*
 *  настройки для каждого пользователя
 *  хранится по одной записи для каждого пользователя
 *
 */

CREATE TABLE gd_userstorage (
  userkey      dintkey,
  data         dblob4096,
  modified     dtimestamp NOT NULL
);

ALTER TABLE gd_userstorage ADD CONSTRAINT gd_pk_userstorage_uk
  PRIMARY KEY (userkey);

ALTER TABLE gd_userstorage ADD CONSTRAINT gd_fk_userstorage_uk
  FOREIGN KEY (userkey) REFERENCES gd_user (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

/*
 *  настройки для каждой нашей фирмы
 *  хранится по одной записи для каждой фирмы
 *
 */

CREATE TABLE gd_companystorage (
  companykey   dintkey,
  data         dblob4096,
  modified     dtimestamp NOT NULL
);

ALTER TABLE gd_companystorage ADD CONSTRAINT gd_pk_companystorage_ck
  PRIMARY KEY (companykey);

ALTER TABLE gd_companystorage ADD CONSTRAINT gd_fk_companystorage_ck
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany (companykey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;

CREATE TABLE gd_storagebackup (
  id           dintkey,
  userkey      dforeignkey,
  companykey   dforeignkey,
  data         dblob4096,
  modified     dtimestamp NOT NULL
);

ALTER TABLE gd_storagebackup ADD CONSTRAINT gd_pk_storagebackup
  PRIMARY KEY (id);

ALTER TABLE gd_storagebackup ADD CONSTRAINT gd_fk_storagebackup_ck
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany (companykey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_storagebackup ADD CONSTRAINT gd_fk_storagebackup_uk
  FOREIGN KEY (userkey) REFERENCES gd_user (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

SET TERM ^ ;

CREATE TRIGGER gd_bi_storagebackup FOR gd_storagebackup
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER gd_bu_globalstorage FOR gd_globalstorage
  BEFORE UPDATE
  POSITION 100
AS
BEGIN
  INSERT INTO gd_storagebackup (data, modified) VALUES (OLD.data, OLD.modified);
END
^

CREATE TRIGGER gd_bu_userstorage FOR gd_userstorage
  BEFORE UPDATE
  POSITION 100
AS
BEGIN
  INSERT INTO gd_storagebackup (userkey, data, modified) VALUES (OLD.userkey, OLD.data, OLD.modified);
END
^

CREATE TRIGGER gd_bu_companystorage FOR gd_companystorage
  BEFORE UPDATE
  POSITION 100
AS
BEGIN
  INSERT INTO gd_storagebackup (companykey, data, modified) VALUES (OLD.companykey, OLD.data, OLD.modified);
END
^

SET TERM ; ^

COMMIT;
