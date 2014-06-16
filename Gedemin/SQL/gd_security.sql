
/*

  Copyright (c) 2000-2014 by Golden Software of Belarus

  Script

    gd_security.sql

  Abstract

    An Interbase script for access.

  Author

    Andrey Shadevsky (27.04.00)

  Revisions history

    Initial  27.04.00  JKL    Initial version
    add table gd_classes  27.05.2002 Nick

  Status


*/

/****************************************************

   ������� ��� �������� �������������.

*****************************************************/

CREATE DOMAIN dallowaudit
  AS SMALLINT DEFAULT 0 NOT NULL;

COMMIT;

CREATE TABLE gd_user
(
  id               dintkey,                     /* ��������� ����                                    */
  name             dusername,                   /* ���                                               */
  passw            dpassword,                   /* ������                                            */
  ingroup          dinteger DEFAULT 1 NOT NULL, /* ������, � ������� ������ ������������             */
  fullname         dtext180,                    /* ������ ���                                        */
  description      dtext180,                    /* ��������                                          */
  ibname           dusername,                   /* ��� ������������ IB                               */
  ibpassword       dpassword,                   /* ������ IB                                         */
  contactkey       dintkey,                     /* ������ �� ������ � ������� ���������              */
  externalkey      dforeignkey,                 /* ������� ������, �������� �� ���������� �����������*/
  disabled         dboolean DEFAULT 0 NOT NULL, /* ��������                                          */
  lockedout        dboolean DEFAULT 0,          /* ������ �������������                              */
  mustchange       dboolean DEFAULT 0,          /* ��� ����� ������������ ������ �������� ������     */
  cantchangepassw  dboolean DEFAULT 1,          /* ������������ �� ����� ������ ������               */
  passwneverexp    dboolean DEFAULT 1,          /* ���� �������� ������ ������� �� ��������          */
  expdate          ddate,                       /* ���� ��������� ����� �������� ������              */
  workstart        dtime,                       /* ������ �������� ���                               */
  workend          dtime,                       /* ��������� �������� ���                            */
  allowaudit       dallowaudit,                 /* ����� �� �������� ����� ������������ ����������   */
                                                /* � ������                                          */
  editiondate      deditiondate,
  editorkey        dforeignkey,

  icon             dinteger,                    /* ����������� ��� ������� ������������              */
  reserved         dinteger,                    /* ���������������                                   */

  CHECK (((workstart IS NULL) AND (workend IS NULL)) OR (workstart < workend)),
  CHECK (ingroup <> 0)
);

ALTER TABLE gd_user ADD CONSTRAINT gd_pk_user
  PRIMARY KEY (id);

/* ��� ������������ ������ ���� ���������� */
CREATE UNIQUE ASC INDEX gd_x_user_name ON gd_user
  (name);

/*
CREATE UNIQUE INDEX gd_x_user_ibname ON
  gd_user (ibname);
*/  

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_user FOR gd_user
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);

  /* �������� �� ��������� */
  IF (NEW.ingroup IS NULL) THEN
    NEW.ingroup = 0;
  IF (NEW.disabled IS NULL) THEN
    NEW.disabled = 0;
  IF (NEW.mustchange IS NULL) THEN
    NEW.mustchange = 0;
  IF (NEW.cantchangepassw IS NULL) THEN
    NEW.cantchangepassw = 1;
  IF (NEW.passwneverexp IS NULL) THEN
    NEW.passwneverexp = 1;
  IF (NEW.lockedout IS NULL) THEN
    NEW.lockedout = 0;
END
^

CREATE EXCEPTION gd_e_invaliduserupdate 'At least one user must be enabled'^

CREATE OR ALTER TRIGGER gd_bu_user FOR gd_user
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF ((NEW.disabled = 1) AND (OLD.disabled = 0) AND
      (SINGULAR (SELECT * FROM gd_user WHERE disabled = 0))) THEN
    EXCEPTION gd_e_invaliduserupdate;
END
^

CREATE EXCEPTION gd_e_invaliduserdelete 'Can not delete all users'^

CREATE TRIGGER gd_bd_user FOR gd_user
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  /* ������� ������������ ��������� */
  IF (OLD.ID = 150001) THEN
    EXCEPTION gd_e_invaliduserdelete;
END
^

SET TERM ; ^

COMMIT;

/****************************************************

   ������� ��� �������� ���������.

*****************************************************/

CREATE TABLE gd_subsystem
(
  id               dintkey,             /* ��������� ����                       */
  name             dusername,           /* ���                                  */
  description      dtext180,            /* ��������                             */
  groupsallowed    dintkey DEFAULT 1,   /* ������, ������� �������� ������      */

  auditlevel       dsmallint DEFAULT 2, /* ������� ������, ��-��������� ������� */
  auditcache       dsmallint DEFAULT 1, /* ������������ �����������, ��         */
  auditmaxdays     dsmallint DEFAULT 0, /* ������ ������, ��-��������� ���      */

  disabled         dboolean DEFAULT 0,  /* ���������                            */
  reserved         dinteger,            /* ���������������                      */

  CHECK(auditlevel >= 0 AND auditlevel <= 3),
  CHECK(auditcache >= 0 AND auditcache <= 1),
  CHECK(auditmaxdays >= 0)
);

ALTER TABLE gd_subsystem ADD CONSTRAINT gd_pk_subsystem
  PRIMARY KEY (id);

/* ��� ������������ ������ ���� ���������� */
CREATE UNIQUE ASC INDEX gd_x_subsystem_name
  ON gd_subsystem (name);

SET TERM ^ ;

CREATE TRIGGER gd_bi_subsystem FOR gd_subsystem
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE EXCEPTION gd_e_invalidsubsystemdelete 'Cannt delete all subsystem'^

CREATE TRIGGER gd_bd_subsystem FOR gd_subsystem
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (NOT EXISTS(SELECT * FROM gd_subsystem WHERE id <> OLD.id)) THEN
    EXCEPTION gd_e_invalidsubsystemdelete;
END
^

SET TERM ; ^

COMMIT;


/****************************************************/
/**                                                **/
/**  ������ �������������                          **/
/**                                                **/
/****************************************************/

CREATE TABLE gd_usergroup
(
  id              dintkey,              /* ���������� �������������    */
  disabled        dboolean DEFAULT 0,   /* ������ ���������            */
  name            dusergroupname,       /* ������������                */
  description     dtext180,             /* ��������                    */
  icon            dinteger,             /*                             */
  reserved        dinteger              /* ���������������             */
);

ALTER TABLE gd_usergroup
  ADD CONSTRAINT gd_pk_usergroup PRIMARY KEY (id);

ALTER TABLE gd_usergroup
  ADD CONSTRAINT gd_chk_usergroup_id CHECK (id BETWEEN 1 AND 32);

ALTER TABLE gd_usergroup
  ADD CONSTRAINT gd_chk_usergroup_name CHECK (name > '');

CREATE UNIQUE ASC INDEX gd_x_usergroup_name ON gd_usergroup
  (name);

COMMIT;

CREATE GENERATOR gd_g_session_id;
SET GENERATOR gd_g_session_id TO 1;

SET TERM ^ ;

CREATE EXCEPTION gd_e_cantaddusergroup 'New Id cannt be more than 32'^

CREATE PROCEDURE gd_p_getnextusergroupid
  RETURNS(NextID INTEGER)
AS
  DECLARE VARIABLE N INTEGER;
BEGIN
  NextID = 7;
  FOR
    SELECT id
    FROM gd_usergroup
    WHERE id >= 7
    ORDER BY id
    INTO :N
  DO BEGIN
    IF (:NextID < :N) THEN
    BEGIN
      EXIT;
    END

    NextID = :NextID + 1;

    IF (:NextID > 32) THEN
    BEGIN
      EXCEPTION gd_e_cantaddusergroup;
    END
  END
END
^

CREATE TRIGGER gd_bi_usergroup FOR gd_usergroup
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
  BEGIN
    EXECUTE PROCEDURE gd_p_getnextusergroupid
      RETURNING_VALUES NEW.id;
  END
END
^

CREATE EXCEPTION gd_e_canteditusergroup 'Can''t edit reserved user group'^

CREATE TRIGGER gd_bu_usergroup FOR gd_usergroup
  BEFORE UPDATE
  POSITION 0
AS
BEGIN
  IF ((OLD.ID < 7) AND (OLD.name <> NEW.name)) THEN
    EXCEPTION gd_e_canteditusergroup;
END
^

CREATE EXCEPTION gd_e_cantdeleteusergroup 'Cannt delete user group'^

CREATE TRIGGER gd_bd_usergroup FOR gd_usergroup
  BEFORE DELETE
  POSITION 0
AS
BEGIN
  IF (OLD.ID < 7) THEN
    EXCEPTION gd_e_cantdeleteusergroup;
END
^

CREATE TRIGGER gd_ad_usergroup FOR gd_usergroup
  AFTER DELETE
  POSITION 0
AS
  DECLARE VARIABLE MASK INTEGER;
  DECLARE VARIABLE I INTEGER;
BEGIN
  MASK = 1;
  I = 1;
  WHILE (I < OLD.id) DO
  BEGIN
    MASK = BIN_SHL(:MASK, 1);
    I = :I + 1;
  END

  /* �������������, ������� ������� ������ � ��������� ������ */
  /* ��������� � ����������� ������ ������������              */
  UPDATE gd_user SET ingroup = 4 WHERE ingroup = :MASK;

  /* �������� ������������� �� ��������� ������               */
  UPDATE gd_user SET ingroup = BIN_AND(ingroup, BIN_NOT(:MASK))
    WHERE BIN_AND(ingroup, :MASK) <> 0;
END
^

CREATE TRIGGER gd_biu_user FOR gd_user
  BEFORE INSERT OR UPDATE
  POSITION 100
AS
  DECLARE VARIABLE I INTEGER;
  DECLARE VARIABLE MASK INTEGER;
  DECLARE VARIABLE M BIGINT;
BEGIN
  I = 1;
  M = 1;
  MASK = 0;
  WHILE (I < 32) DO
  BEGIN
    IF (EXISTS (SELECT * FROM gd_usergroup WHERE id = :I)) THEN
      MASK = BIN_OR(:MASK, :M);
    M = BIN_SHL(:M, 1);
    I = :I + 1;
  END

  NEW.ingroup = BIN_AND(NEW.ingroup, :MASK);
END
^

SET TERM ; ^


/* ���������� ��������� */


COMMIT;

SET TERM ^ ;

/*--------------------------------------------------------

  gd_p_sec_getgroupsforuser

  �� ���� ����������: ������������� ������������
  �� ������: ������, ������ �����, � ������� ������ ���� ������������

----------------------------------------------------------*/

CREATE PROCEDURE gd_p_sec_getgroupsforuser(UserKey INTEGER)
  RETURNS(GroupsForUser VARCHAR(2048))
AS
  DECLARE VARIABLE UGK INTEGER;
  DECLARE VARIABLE GroupName VARCHAR(2048);
  DECLARE VARIABLE C1 INTEGER;
  DECLARE VARIABLE C2 INTEGER;
  DECLARE VARIABLE IG INTEGER;
BEGIN
  SELECT ingroup FROM gd_user WHERE id = :UserKey INTO :IG;

  C2 = 1;
  C1 = 1;
  GroupsForUser = '';
  WHILE (:C1 <= 32) DO
  BEGIN
    IF (BIN_AND(:C2, :IG) > 0) THEN
    BEGIN
      GroupName = '';
      SELECT gg.name
      FROM gd_usergroup gg
      WHERE gg.id = :C1
      INTO :GroupName;

      IF (:GroupName <> '') THEN
        GroupsForUser = :GroupsForUser || ', ' || :GroupName;
    END

    C1 = :C1 + 1;

    IF (:C1 < 32) THEN
      C2 = :C2 * 2;
  END
END
^

SET TERM ; ^

GRANT EXECUTE ON PROCEDURE gd_p_sec_getgroupsforuser TO startuser;
GRANT SELECT ON gd_user TO PROCEDURE gd_p_sec_getgroupsforuser;
GRANT SELECT ON gd_usergroup TO PROCEDURE gd_p_sec_getgroupsforuser;

COMMIT;

CREATE TABLE gd_journal
(
  id               dintkey,
  contactkey       dforeignkey,
  operationdate    dtimestamp_notnull,
  source           dtext40,
  objectid         dforeignkey,
  data             dblobtext80_1251
);

COMMIT;

ALTER TABLE gd_journal ADD CONSTRAINT gd_pk_journal
  PRIMARY KEY (id);

/* ����� ��� �� ������� � ����� ������ ���������� ����� */

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_journal FOR gd_journal
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER gd_bi_journal2 FOR gd_journal
  BEFORE INSERT
  POSITION 2
AS
BEGIN
  IF (NEW.operationdate IS NULL) THEN
    NEW.operationdate = 'NOW';

  IF (NEW.contactkey IS NULL) THEN
  BEGIN
    SELECT contactkey FROM gd_user
    WHERE ibname = CURRENT_USER
    INTO NEW.contactkey;
  END
END
^

SET TERM ; ^

COMMIT;

/*

  ������ ������ ������ SQL ������.

*/

CREATE TABLE gd_sql_statement
(
  id               dintkey,
  crc              INTEGER NOT NULL UNIQUE,
  kind             SMALLINT NOT NULL,          /* 0 -- sql, 1 -- params */
  data             dblobtext80_1251 not null,
  editiondate      deditiondate
);

ALTER TABLE gd_sql_statement ADD CONSTRAINT gd_pk_sql_statement
  PRIMARY KEY (id);

/* ����� ��� �� ������� � ����� ������ ���������� ����� */

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_sql_statement FOR gd_sql_statement
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

CREATE TABLE gd_sql_log
(
  statementcrc     INTEGER NOT NULL,
  paramscrc        INTEGER,
  contactkey       dintkey,
  starttime        dtimestamp_notnull,
  duration         INTEGER NOT NULL
);

COMMIT;

ALTER TABLE gd_sql_log ADD CONSTRAINT gd_fk_sql_log_scrc
  FOREIGN KEY (statementcrc) REFERENCES gd_sql_statement (crc)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_sql_log ADD CONSTRAINT gd_fk_sql_log_pcrc
  FOREIGN KEY (paramscrc) REFERENCES gd_sql_statement (crc)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

/*
ALTER TABLE gd_sql_log ADD CONSTRAINT gd_fk_sql_log_ckey
  FOREIGN KEY (contactkey) REFERENCES gd_contact (id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
*/

COMMIT;

/*--------------------------------------------------------

  gd_p_sec_loginuser

  �� ���� ����������: ��� ������������ � ������
  (���� �� � ������������� ����). ��� �������� ������������ ������
  ��� ����� � �������.

  �� ������:
    result = 1          -- ��� ���������
    result = 2          -- ��� ���������, ������� ������
    result = -1001      -- ��� ����� ����������
    result = -1002      -- ���������� �������������
    result = -1003      -- ������������ ���
    result = -1004      -- ������ �������
    result = -1005      -- ������������ ������������ ��� ����� ����
    result = -1006      -- ���� � �� ������� �����
    result = -1007      -- ������������ �� ����� ���� �� ���� � ����������
    result = -1008      -- ��� ������ ������������ ��� ����� � ���������� �������������

    ���� ��� ���������, �� userkey, ibname, ibpassw -- ���� ������������,
    ��� ������������ Interbase � ������ Interbase ��������������.
    �����, �������� ���������� ������������.

  ��������! �� �������� ����� ����������� -- ������ ���
  ���������� ������������� ���� ������ (�������� ����������������
  ����������).

----------------------------------------------------------*/

SET TERM ^ ;

CREATE PROCEDURE gd_p_sec_loginuser (username VARCHAR(20), passw VARCHAR(20), subsystem INTEGER)
  RETURNS (
    result        INTEGER,
    userkey       INTEGER,
    contactkey    INTEGER,
    ibname        VARCHAR(20),
    ibpassword    VARCHAR(20),
    ingroup       INTEGER,
    session       INTEGER,
    subsystemname VARCHAR(60),
    groupname     VARCHAR(2048),
    dbversion     VARCHAR(20),
    dbreleasedate DATE,
    dbversionid   INTEGER,
    dbversioncomment VARCHAR(254),
    auditlevel    INTEGER,
    auditcache    INTEGER,
    auditmaxdays  INTEGER,
    allowuseraudit SMALLINT
  )
AS
  DECLARE VARIABLE PNE INTEGER;
  DECLARE VARIABLE MCH INTEGER;
  DECLARE VARIABLE WS TIME;
  DECLARE VARIABLE WE TIME;
  DECLARE VARIABLE ED DATE;
  DECLARE VARIABLE UDISABLED INTEGER;
  DECLARE VARIABLE UPASSW VARCHAR(20);
BEGIN
  UDISABLED = NULL;

  SELECT id, disabled, passw, workstart, workend, expdate, passwneverexp,
    contactkey, ibname, ibpassword, ingroup, mustchange, allowaudit
  FROM gd_user
  WHERE UPPER(name) = UPPER(:username)
  INTO :userkey, :UDISABLED, :UPASSW, :WS, :WE, :ED, :PNE,
    :contactkey, :ibname, :ibpassword, :ingroup, :MCH, :AllowUserAudit;

  IF (:userkey IS NULL) THEN
  BEGIN
    result = -1003;
    EXIT;
  END

  IF (:UDISABLED <> 0) THEN
  BEGIN
    result = -1005;
    EXIT;
  END

  IF ((CURRENT_DATE >= :ED) AND (:PNE = 0)) THEN
  BEGIN
    result = -1005;
    EXIT;
  END

  IF (
    (NOT :WS IS NULL) AND
    (NOT :WE IS NULL) AND
    ((CURRENT_TIME < :WS) OR (CURRENT_TIME > :WE))
  ) THEN
  BEGIN
    result = -1006;
    EXIT;
  END

  IF (:UPASSW <> :passw) THEN
  BEGIN
    result = -1004;
    EXIT;
  END

  IF (:contactkey IS NULL) THEN
    contactkey = -1;

  EXECUTE PROCEDURE gd_p_sec_getgroupsforuser(:userkey)
    RETURNING_VALUES :groupname;

  result = IIF(:MCH = 0, 1, 2);

  /* ��i������ ����� ���ii */
  session = GEN_ID(gd_g_session_id, 1);

  /* ������ ����� ����__ ���� _ ���� ������*/
  SELECT FIRST 1 versionstring, releasedate, /*id,*/ comment
  FROM fin_versioninfo
  ORDER BY id DESC
  INTO :dbversion, :dbreleasedate, /*:dbversionid,*/ :dbversioncomment;

  dbversionid = GEN_ID(gd_g_dbid, 0);
END
^

/*

  ���������� ������ ������ �� ���� ������, � ������� ����
  ����������� ������������. ����� ����� ���������� ����� ������
  ����������� ������������ � ��� ��� ���� ������� (0 ��� 1
  � ��������������� ������� ��������������� ������).

*/
CREATE PROCEDURE gd_p_gettableswithdescriptors
RETURNS (relationname VARCHAR(32), aview INTEGER, achag INTEGER, afull INTEGER)
AS
BEGIN
  FOR
    SELECT
      DISTINCT rf.rdb$relation_name
      FROM rdb$relation_fields rf
        LEFT JOIN rdb$view_relations vr ON vr.rdb$view_name = rf.rdb$relation_name
      WHERE rf.rdb$field_name IN ('AVIEW', 'ACHAG', 'AFULL')
        AND vr.rdb$view_name IS NULL
      INTO :RelationName
  DO
  BEGIN
    IF (EXISTS (SELECT * FROM rdb$relation_fields WHERE rdb$relation_name=:RelationName AND
          rdb$field_name='AVIEW')) THEN aview = 1; ELSE aview = 0;
    IF (EXISTS (SELECT * FROM rdb$relation_fields WHERE rdb$relation_name=:RelationName AND
          rdb$field_name='ACHAG')) THEN achag = 1; ELSE achag = 0;
    IF (EXISTS (SELECT * FROM rdb$relation_fields WHERE rdb$relation_name=:RelationName AND
          rdb$field_name='AFULL')) THEN afull = 1; ELSE afull = 0;
    SUSPEND;
  END
END
^

SET TERM ; ^

GRANT EXECUTE ON PROCEDURE gd_p_sec_loginuser TO startuser;
GRANT SELECT ON gd_user TO PROCEDURE gd_p_sec_loginuser;
GRANT SELECT ON gd_subsystem TO PROCEDURE gd_p_sec_loginuser;
GRANT SELECT ON gd_usergroup TO PROCEDURE gd_p_sec_loginuser;
GRANT SELECT, UPDATE, DELETE ON gd_journal TO PROCEDURE gd_p_sec_loginuser;

/****************************************************

   ������� ��� �������

*****************************************************/

CREATE DOMAIN gd_dipaddress
  VARCHAR(15) NOT NULL
  CHECK (VALUE SIMILAR TO
    '(([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-6]).){3}([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-6])');

CREATE TABLE gd_weblog
(
  id           dintkey,
  ipaddress    gd_dipaddress,
  op           CHAR(4) NOT NULL,
  datetime     TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,

  CONSTRAINT gd_pk_weblog PRIMARY KEY (id)
);

COMMIT;

CREATE TABLE gd_weblogdata
(
  logkey       dintkey,
  valuename    dname,
  valuestr     dtext254,
  valueblob    BLOB SUB_TYPE 1 CHARACTER SET WIN1251 COLLATE PXW_CYRL,

  CONSTRAINT gd_pk_weblogdata PRIMARY KEY (logkey, valuename),
  CONSTRAINT gd_fk_weblogdata_logkey FOREIGN KEY (logkey)
    REFERENCES gd_weblog (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_weblog FOR gd_weblog
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;
