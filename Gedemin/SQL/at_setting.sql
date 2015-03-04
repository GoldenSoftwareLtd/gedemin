
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

CREATE OR ALTER TRIGGER at_bi_setting FOR at_setting
  BEFORE INSERT
  POSITION 0
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
  settingkey      dmasterkey,       /* ������ �� ��������� */
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
  id           dintkey,                 /* ������������� */
  settingkey   dmasterkey,              /* ������ �� ���������*/
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
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);
END
^

SET TERM ; ^

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
  filedata      dscript,
  changed       dboolean_notnull DEFAULT 1,

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

  IF (TRIM(COALESCE(NEW.caption, '')) = '') THEN
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
  alwaysoverwrite dboolean_notnull DEFAULT 0,
  dontremove      dboolean_notnull DEFAULT 0,
  includesiblings dboolean_notnull DEFAULT 0,
  headobjectkey   dforeignkey,
  modified        TIMESTAMP,
  curr_modified   TIMESTAMP,

  CONSTRAINT at_pk_object PRIMARY KEY (id),
  CONSTRAINT at_fk_object_namespacekey FOREIGN KEY (namespacekey)
    REFERENCES at_namespace (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT at_fk_object_headobjectkey FOREIGN KEY (headobjectkey)
    REFERENCES at_object (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT at_chk_object_hk CHECK (headobjectkey IS DISTINCT FROM id)
);

CREATE UNIQUE INDEX at_x_object
  ON at_object (xid, dbid, namespacekey);

SET TERM ^ ;

CREATE OR ALTER TRIGGER at_bi_object FOR at_object
  ACTIVE
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_offset, 0) + GEN_ID(gd_g_unique, 1);

  IF ((NEW.xid < 147000000 AND NEW.dbid <> 17) OR
    (NEW.xid >= 147000000 AND NOT EXISTS(SELECT * FROM gd_ruid WHERE xid = NEW.xid AND dbid = NEW.dbid))) THEN
  BEGIN
    EXCEPTION gd_e_invalid_ruid 'Invalid ruid. XID = ' ||
      NEW.xid || ', DBID = ' || NEW.dbid || '.';
  END

  IF (NEW.objectpos IS NULL) THEN
  BEGIN
    SELECT MAX(objectpos)
    FROM at_object
    WHERE namespacekey = NEW.namespacekey
    INTO NEW.objectpos;
    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1;
  END ELSE
  BEGIN
    UPDATE at_object SET objectpos = objectpos + 1
    WHERE objectpos >= NEW.objectpos AND namespacekey = NEW.namespacekey;
  END
END
^

CREATE OR ALTER TRIGGER at_bu_object FOR at_object
  ACTIVE
  BEFORE UPDATE
  POSITION 0
AS
  DECLARE VARIABLE depend_id dintkey;
BEGIN
  IF ((NEW.xid < 147000000 AND NEW.dbid <> 17) OR
    (NEW.xid >= 147000000 AND NOT EXISTS(SELECT * FROM gd_ruid WHERE xid = NEW.xid AND dbid = NEW.dbid))) THEN
  BEGIN
    EXCEPTION gd_e_invalid_ruid 'Invalid ruid. XID = ' ||
      NEW.xid || ', DBID = ' || NEW.dbid || '.';
  END

  IF (NEW.namespacekey <> OLD.namespacekey) THEN
  BEGIN
    RDB$SET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK',
      COALESCE(CAST(RDB$GET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK') AS INTEGER), 0) + 1);

    FOR
      SELECT id
      FROM at_object
      WHERE headobjectkey = NEW.id AND objectpos <= OLD.objectpos
      ORDER BY objectpos
      INTO :depend_id
    DO BEGIN
      UPDATE at_object SET namespacekey = NEW.namespacekey
        WHERE id = :depend_id;
    END

    SELECT MAX(objectpos)
    FROM at_object
    WHERE namespacekey = NEW.namespacekey
    INTO NEW.objectpos;
    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1;

    FOR
      SELECT id
      FROM at_object
      WHERE headobjectkey = NEW.id AND objectpos > OLD.objectpos
      ORDER BY objectpos
      INTO :depend_id
    DO BEGIN
      UPDATE at_object SET namespacekey = NEW.namespacekey
        WHERE id = :depend_id;
    END

    RDB$SET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK',
      CAST(RDB$GET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK') AS INTEGER) - 1);
  END
  ELSE IF (NEW.objectpos IS NULL) THEN
  BEGIN
    SELECT MAX(objectpos)
    FROM at_object
    WHERE namespacekey = NEW.namespacekey
    INTO NEW.objectpos;
    NEW.objectpos = COALESCE(NEW.objectpos, 0) + 1;
  END
END
^

CREATE OR ALTER TRIGGER at_au_object FOR at_object
  ACTIVE
  AFTER UPDATE
  POSITION 0
AS
BEGIN
  IF (NEW.namespacekey <> OLD.namespacekey) THEN
  BEGIN
    IF (COALESCE(RDB$GET_CONTEXT('USER_TRANSACTION', 'AT_OBJECT_LOCK'), 0) = 0) THEN
    BEGIN
      IF (EXISTS(SELECT * FROM at_object WHERE id = NEW.headobjectkey
        AND namespacekey <> NEW.namespacekey)) THEN
      BEGIN
        EXCEPTION gd_e_exception '������ ���������� ����������� ������.';
      END
    END  
  END
END
^

CREATE OR ALTER TRIGGER at_aiud_object FOR at_object
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 20000
AS
BEGIN
  IF (INSERTING OR UPDATING) THEN
    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
      AND n.id = NEW.namespacekey;

  IF (UPDATING OR DELETING) THEN
    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
      AND n.id = OLD.namespacekey;
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

SET TERM ^ ;

CREATE OR ALTER TRIGGER at_aiud_namespace_link FOR at_namespace_link
  ACTIVE
  AFTER INSERT OR UPDATE OR DELETE
  POSITION 20000
AS
BEGIN
  IF (INSERTING) THEN
    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
      AND n.id = NEW.namespacekey;

  IF (UPDATING) THEN
  BEGIN
    IF (NEW.namespacekey <> OLD.namespacekey OR NEW.useskey <> OLD.useskey) THEN
      UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
        AND (n.id = NEW.namespacekey OR n.id = OLD.namespacekey);
  END

  IF (DELETING) THEN
    UPDATE at_namespace n SET n.changed = 1 WHERE n.changed = 0
      AND n.id = OLD.namespacekey;
END
^

CREATE OR ALTER PROCEDURE at_p_findnsrec (InPath VARCHAR(32000),
  InFirstID INTEGER, InID INTEGER)
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

CREATE OR ALTER PROCEDURE at_p_del_duplicates (
  DeleteFromID INTEGER,
  CurrentID INTEGER,
  Stack VARCHAR(32000))
AS
  DECLARE VARIABLE id INTEGER;
  DECLARE VARIABLE nsid INTEGER;
BEGIN
  IF (:DeleteFromID <> :CurrentID) THEN
  BEGIN
    FOR
      SELECT o1.id
      FROM at_object o1 JOIN at_object o2
        ON o1.xid = o2.xid AND o1.dbid = o2.dbid
      WHERE o1.NAMESPACEKEY = :DeleteFromID
        AND o2.NAMESPACEKEY = :CurrentID
        AND o1.headobjectkey IS NULL
        AND o2.headobjectkey IS NULL
      INTO :id
    DO BEGIN
      DELETE FROM at_object WHERE id = :id;
    END
  END

  FOR
    SELECT l.useskey
    FROM at_namespace_link l
    WHERE l.namespacekey = :CurrentID
      AND POSITION(('(' || l.useskey || ')') IN :Stack) = 0
    INTO :nsid
  DO BEGIN
    EXECUTE PROCEDURE at_p_del_duplicates (:DeleteFromID, :nsid,
      :Stack || '(' || :nsid || ')');
  END
END
^

SET TERM ; ^

CREATE GENERATOR at_g_file_tree;

CREATE GLOBAL TEMPORARY TABLE at_namespace_file (
  filename      dtext255,
  filetimestamp TIMESTAMP,
  filesize      dinteger,
  name          dtext255 NOT NULL UNIQUE,
  caption       dtext255,
  version       dtext20,
  dbversion     dtext20,
  optional      dboolean_notnull DEFAULT 0,
  internal      dboolean_notnull DEFAULT 1,
  comment       dblobtext80_1251,
  xid           dinteger,
  dbid          dinteger,

  CONSTRAINT at_pk_namespace_file PRIMARY KEY (filename)
)
  ON COMMIT DELETE ROWS;

CREATE INDEX at_x_namespace_file_ruid ON at_namespace_file
  (xid, dbid);

CREATE GLOBAL TEMPORARY TABLE at_namespace_file_link (
  filename      dtext255 NOT NULL,
  uses_xid      dintkey,
  uses_dbid     dintkey,
  uses_name     dtext255 NOT NULL,

  CONSTRAINT at_pk_namespace_file_link
    PRIMARY KEY (filename, uses_xid, uses_dbid),
  CONSTRAINT at_fk_namespace_file_link_fn
    FOREIGN KEY (filename) REFERENCES at_namespace_file (filename)
      ON UPDATE CASCADE
      ON DELETE CASCADE
)
  ON COMMIT DELETE ROWS;

CREATE INDEX at_x_namespace_file_link_ur ON at_namespace_file_link
  (uses_xid, uses_dbid);

CREATE GLOBAL TEMPORARY TABLE at_namespace_sync (
  namespacekey  dforeignkey,
  filename      dtext255,
  operation     CHAR(2) DEFAULT '  ' NOT NULL,

  CONSTRAINT at_fk_namespace_sync_fn
    FOREIGN KEY (filename) REFERENCES at_namespace_file (filename)
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  CONSTRAINT at_chk_namespace_sync_op
    CHECK (operation IN ('  ', '< ', '> ', '>>', '<<', '==', '=>', '<=', '! ', '? '))
)
  ON COMMIT DELETE ROWS;

GRANT ALL     ON at_namespace             TO administrator;
GRANT ALL     ON at_object                TO administrator;
GRANT ALL     ON at_namespace_link        TO administrator;
GRANT ALL     ON at_namespace_file        TO administrator;
GRANT ALL     ON at_namespace_file_link   TO administrator;
GRANT ALL     ON at_namespace_sync        TO administrator;
GRANT EXECUTE ON PROCEDURE at_p_findnsrec TO administrator;
GRANT EXECUTE ON PROCEDURE at_p_del_duplicates TO administrator;

COMMIT;
