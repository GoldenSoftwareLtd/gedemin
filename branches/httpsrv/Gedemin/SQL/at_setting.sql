
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

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

/* �� ����, ����� ������ ���� ���������� ����,
   �� ��������� ��������  ��� ����������, ������� ���� ������ */
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
