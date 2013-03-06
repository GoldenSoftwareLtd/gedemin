
/*

  Copyright (c) 2000-2013 by Golden Software of Belarus

  Script

    at_setting.sql

  Abstract

    ����������� �������� ��

  Author

    Julia Teryokhina

  Revisions history

    Initial  27.05.2002  Julia    Initial version

*/

/* ������� ��������*/

CREATE TABLE at_setting (
  id              dintkey NOT NULL,  /* ������������� */
  name            dname NOT NULL     /* ������������ ��������� */
                  collate PXW_CYRL,
  data            DBLOB4096,         /* ������ �������, ����������� � ����� */
  storagedata     DBLOB4096,         /* ������ ���������, ����������� � ����� */
  disabled        dboolean DEFAULT 0,/* �������� / ���������� ��������� */
  modifydate      dtimestamp,        /* ���� ���������� ��������� � ���� */
  settingsruid    dblobtext80_1251,  /* ������ ����� ��������, �� ������� ������� ������ ���������*/
  version         dinteger,          /* ������ ���������, ���������� ��� ������ ���������� ��������� � ���� */ 
  minexeversion   dtext20,           /* min ������ Exe-����� ��� ������ ��������� */
  mindbversion    dtext20,           /* min ������ �� ��� ������ ��������� */
  ending          dboolean,           /* ��������/������������� ��������� */
  description     dtext255           /* �������� ��������� */
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

/* ������� ������� �������� */
/* ���� ��������� ������� � ������������ ������� ������������ ����� ���
   ����������� ����������� ���������, ��� ���� ���� ������� �����
   ��������� ���������� � ������� ������������ �������, �����-����
   ������ ��� ��������� ����������� ���������. ��������, �� ���������
   ���� usr$newfield ������� usr$newtable. ������-��������� - �������,
   ������-������������ - usr$newtable, ��������� ������� - ����,
   ������������ ������� - usr$newfield. */

CREATE TABLE at_settingpos (
  id              dintkey,                   /* ������������� */
  settingkey      dmasterkey NOT NULL,       /* ������ �� ��������� */
  mastercategory  dtext20 collate PXW_CYRL,  /* ��������� ������� */
  mastername      dtext60 collate PXW_CYRL,  /* ������������ ������� */
  objectclass     dclassname NOT NULL        /* ����� ������������ ������� */
                  collate PXW_CYRL,
  subtype         dtext40 collate PXW_CYRL,  /* ������� ������������ ������� */
  category        dtext20 collate PXW_CYRL,  /* ��������� ������������ ������� */
  objectname      dname NOT NULL             /* ������������ ������������ ������� */
                  collate PXW_CYRL,
  xid             dinteger NOT NULL,         /* ������������� ������������ �������
                                                (�� ����-��������) */
  dbid            dinteger NOT NULL,         /* ������������� ���� �������� */
  objectorder     dinteger NOT NULL,         /* ������� ���������� �������� � ��������� */
  withdetail      dboolean_notnull default 0 /* ��������� ��� ��������� ������� ��� ������� ������� */
                  NOT NULL,
  needmodify      dboolean_notnull default 1 /* �������������� ������� ��� ��������� ��������� */
                  NOT NULL,
  autoadded       DBOOLEAN_NOTNULL DEFAULT 0 /* ������� ��������� ������������� */
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

/* ������� ��� �������� ����� ������� � ����������*/

CREATE TABLE at_setting_storage
(
  id           dintkey NOT NULL,         /* ������������� */
  settingkey   dmasterkey NOT NULL,     /* ������ �� ���������*/
  branchname   dblobtext80_1251,        /* ������������ ����� �������� */
  valuename    dtext255,                /* ������������ ���������. 
                                           ���� ������, ������ ��������� ��� �����*/
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
    UPDATE at_object SET
	  objectpos = objectpos + 1
    WHERE 
      objectpos >= NEW.objectpos and namespacekey = NEW.namespacekey; 	
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

CREATE global TEMPORARY TABLE at_namespace_gtt(
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
ACTIVE BEFORE INSERT POSITION 0
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

CREATE global TEMPORARY TABLE at_namespace_link_gtt(
  namespaceruid   VARCHAR(21),
  usesruid        VARCHAR(21),
  
  CONSTRAINT at_uk_object_link_gtt UNIQUE (namespaceruid, usesruid)
) ON commit preserve rows;

*/

COMMIT;
